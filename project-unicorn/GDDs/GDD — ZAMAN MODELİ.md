# GDD · ZAMAN MODELİ

**YÜRÜRLÜK: rev 1 · İNŞA SÜRÜMÜ · 2026-09-28**

**Proje:** Project Unicorn · **Kapsam:** oyun zamanı, tempo, süre ve oran birimleri, takvim, ay kapanışı ve özet,
gece atlaması, toplantıların saat bütçesi, mesai, kayıt göçü · **Kaynak:** sahip kararları 2026-09-27 ve 2026-09-28

## Bu belgenin yeri

Bu belge zaman modelinin tek kaynağıdır. Bir GDD bir süreyi gün, iş günü ya da takvim ayı olarak yazıyorsa ve bu
belge aynı süreyi haftayla veriyorsa bu belge geçerlidir. .docx GDD'lerde değişen maddelerin tek tek kaydı
[`GUNCELLEMELER.md`](GUNCELLEMELER.md)'dedir; olay motorunun md'si yerinde düzenlenir.

Başlıca yerine geçtiği yerler:

- ch01 §1: yumuşak tavan "24 game months soft cap [WORKING 730 days]" → 104 hafta (§4.8).
- ch08 §4 "Monthly close (one screen)": ay kapanışı ekran açmaz; özet ekranı oyuncunun seçtiği sıklıkta gelir (§6).
- ch08 §6 ve ch13 §1: 30 günlük kepenk → 4 hafta (§4.8).
- ch09 §4: VC toplantısı saati durdurur ve kapanışta kendi süresi kadar atlatır (§8).
- ch12 §2: hız merdiveni 1×/2×/3× → dört basamak, 1× ile 4× arası (§2).
- Ekip §8.1, §8.2, §8.4 ve §17.5'in "Kurucunun uzun gün verimi" park maddesi: mesai (§9).
- Satış §5.0 (günde bir toplantı, atlanan saatlerde kurucu katkısı sıfır), §7.2 (işleme süresi), §7.6 (fiyat-kırma
  penceresi): §8 ve §4.5.

İşaretler: [WORKING], [ÇALIŞMA] ve [K] aynı sınıftır; işaretli sayı kalibrasyon girdisidir ve kodda tek bir ayar
sabitinde durur (sabitin adı tablodadır). ⚑ işaretli satırda haftaya yuvarlama bir ayrımı siler; not sütunu hangisini
söyler.

## 1. Çekirdek

### 1.1 Tik, oyun günü ve hafta

- Bir oyun günü bir haftadır. Hafta sonu yoktur; gün haftanın temsili iş günüdür. İş günü kavramı (iş günü sayacı,
  iş günü ekleme, hafta sonu atlama) yoktur.
- `GameState.day` tik sayar. `daily_tick`, `day_advanced` ve `day_tick_completed` adlarını korur: bu adlardaki "gün"
  oyun günü, yani tiktir.
- Her tik 24 saatlik tik ve bir günlük tik taşır. Sıra: 00:00'ın saatlik tiki → `advance_day()` → günlük tik.
- Saatlerin bir kısmı görünür oynanır; gerisi gece atlamasında (§7) ya da toplantı atlamasında (§8) simüle edilir.
  Atlama saatleri silmez, gerçek zamanlarını atlar: mekanik her hızda ve her atlamada aynıdır.

### 1.2 Saatin kapısı (SENKRON KURALI)

- Üretim kodunda saati dışarıdan ileri taşıyan iki kapı vardır: `TimeManager.advance_hours(n)` (toplantı kapanışı,
  smoke, probe) ve `TimeManager.skip_night()` (gece). İkisi de aynı saatlik adımdan geçer ve her adımda akümülatörü
  saate eşitler, çünkü 00:00 autosave'i adımın içinde yazılır.
- Toplu adım her adımda koşunun sürdüğüne ve tutma olmadığına bakar. Koşu biterse (sonun kâğıdı) ya da bir tutma
  alınırsa (kilometre taşı kâğıdı) durur. Gece türetildiği için tutma kalkınca kalan gece sürer.
- Toplu adım sürerken olay kartı gösterilmez. Motorun gösterimi toplu adımın sonunda (`clock_batch_ended`) bir kez
  koşar: kart 08:00'de yeniden doğrulanıp kurulur, en önemli kart önce gelir, aktif kart 00:00 autosave'ini engellemez.
- `freeze_clock(neden)` / `thaw_clock(neden)` yalnız saatin birikimini durdurur; ağaç ve hız yürür (ofisteki
  yürüyüş, asansör, trafik sürer). `hold_clock` ağacı da duraklatır.

### 1.3 Adlandırma

- Süreler ve geri sayımlar hafta verisidir: sabitler `*_WEEKS`, alanlar ve seam'ler `*_weeks*`. Süre okuyan her yer
  `TimeModel.ticks()` kapısından geçer.
- Mutlak damgalar `_day` ekini korur ve değerleri tiktir: `hire_day`, `expires_on_day`, `granted_day`.
- Günlük oranlar gün verisidir, adları `*_PER_DAY` kalır (§3.2).
- Kart JSON alanları: `cooldown_weeks`, `expires_weeks`, `deadline_weeks`, `min_gap_weeks`, `delay_weeks`,
  `set_timed_flag.weeks`, `weeks_since_flag`, `flag_expires_within.weeks`, `history: weeks_since`. Ürün gecikme fiili
  de `delay_weeks`'tir.
- Lint kuralı 17.1: kart ve ark JSON'unda gün adı taşıyan her anahtar ve tanımlayıcı değer (`_days` ya da
  `days_since` içeren ya da çıplak `days`) hatadır. Eski anahtarı okuyan kalmadığı için sessizce varsayılana düşerdi.
- Süre bildiren seam'ler haftadır: `time.week`, `urun.weeks_since_launch`, `funding.sheet_weeks_left`,
  `funding.acq_weeks_open`, `funding.angel_weeks_since_accept`, `funding.seed_weeks_since_close`,
  `finance.runway_weeks`, `finance.shutter_weeks_left`, `finance.shutter_weeks_total`, `hr.tenure_weeks`,
  `musteri.tenure_weeks`, `hr.raise_cooldown_left`. Her tik Perşembe'ye düştüğü için haftanın günü seam'i yoktur.
- `funding.sheet_days_left` gün değerlidir ve yalnız `funding.sheet_expiry` gövdesini besler; Frank'in hafta
  cümlesi onaylanana kadar kalır.
- Kart JSON'u sabit okuyamaz. `world.final_stretch_verdict` 103'ü (`SOFT_CAP_WEEK - 1`), `funding.acquisition_offer`
  1'i (`ACQ_CARD_WINDOW_WEEKS`) literal yazar; literal sabitle eşit tutulur.

## 2. Ayar bloğu ve tempo

Günün süresi ve birimler tek dosyadadır: `scripts/systems/time_model.gd` (`TimeModel`).

| sabit | değer | anlamı |
|---|---|---|
| `SECONDS_PER_HOUR` | `[0.0, 10.0, 5.0, 10.0 / 3.0, 2.5]` [WORKING] | oyun saati başına gerçek saniye: duraklat, 1×, 2×, 3×, 4× |
| `WEEK_START_HOUR` | 8 | hafta 08:00'de başlar |
| `WORKDAY_LATEST_END` | 24 | mesai en geç 00:00'da biter |
| `OVERTIME_HOUR_YIELD` | 0,5 [WORKING] | sekizi aşan her saatin verimi (§9) |
| `WEEK_WORK_HOURS` | 40 [WORKING] | toplantının kurucu çıktı payı = saat / 40 (§8.4) |
| `DAYS_PER_TICK` | 7 | tik başına takvim günü |
| `DAYS_PER_MONTH` | 30 | ekonomi ayı (oranlar ve runway) |
| `HOURS_PER_DAY` | 24 | tik başına saatlik tik |
| `WEEKS_PER_YEAR` | 52 | kıdem yılı (kıdem tazminatı) |

**Tempo.** Günün gerçek süresi = (mesai bitişi - 08:00) × sn/saat. Varsayılan 09:00-17:00 mesaide 9 görünen saat
vardır (`TimeModel.seconds_per_tick(hız)`):

| hız | sn / oyun saati | varsayılan günün gerçek süresi |
|---|---|---|
| duraklat | 0 | durur |
| 1× | 10 | 90 sn |
| 2× | 5 | 45 sn |
| 3× | 3,33 | 30 sn |
| 4× | 2,5 | 22,5 sn |

- Hız yalnız gerçek zamanı değiştirir; oyun zamanındaki davranış her hızda aynıdır. Gece için hız hiç değişmez.
- 08:00'den şirket başlangıcına kadar ofis görünür ve boştur: 09:00 başlangıçta 1×'te 10 sn, 11:00'de 30 sn.
- Dört hız düğmesi vardır; 1-4 tuşları basamakları seçer. Kayıttaki son hız 1 ile 4 arasına kırpılır.
- Ölçüm: `--tempo-probe=<hız>` gerçek saatle 08:00'den 08:00'e ölçer; `:shell` eki ofisi kurar ve çıkış kapısının
  gerçek maliyetini de ölçer.

## 3. Dönüştürücü ve birim kuralları

| fonksiyon | yaptığı | okuyanlar |
|---|---|---|
| `ticks(weeks)` | hafta verisi → tik; birebir | süre okuyan her yer |
| `per_tick(rate_per_day)` | günlük oran × 7 | oranın uygulandığı yer |
| `days(ticks)` | tik → takvim günü | beta keşfi, rakip payı büyümesi, `funding.sheet_days_left`, kepenk gazetesinin Frank satırı |
| `months(ticks)` | tik → ekonomi ayı (× 7 / 30) | müşteri kıdemi, sonların ay sayısı |
| `seconds_per_tick(speed)` | varsayılan günün gerçek süresi | harness, tempo ölçümü |

### 3.1 Süre haftadır

- Gün cinsinden süre 7'ye bölünür ve anlamlı en yakın haftaya yuvarlanır. Sıfıra düşen süre en az 1 haftadır.
  Başka bir sabite bağlı süre o bağla türetilir (ör. "yumuşak tavandan bir önce" = `SOFT_CAP_WEEK - 1`).
- Tam haftaya yuvarlama yalnız geri sayım ve pencereler içindir. Onaylı değerler §4'tedir.

### 3.2 Oran gündür, tik başına 7 günlük uygulanır

- `*_PER_DAY` değerleri ve saatlik B2C katsayıları gün verisidir ve değişmez; tik başına `per_tick()` ile 7 günlük
  uygulanır. Takvimde her şey gün modelindeki hızında ilerler.
- ×7, oranın uygulandığı yerde yapılır. Eşikle ya da arayüzle paylaşılan fonksiyonun içinde yapılmaz:
  `SalesSystem.growth_band` saatlik farkı günlük eşiklerle (-0,1 / 0,15 / 0,6) karşılaştırır.
- Para için ×7'nin tek yeri `FinanceSystem.daily_tick`'tir (§6.1).

### 3.3 Tavan ve taban önce günlük değere uygulanır, sonra ×7

| kural | günlük | tik başına |
|---|---|---|
| memnuniyet zararı tavanı `DAMAGE_DAILY_CAP` | -2 | -14 |
| B2B memnuniyet kayması `SAT_DRIFT_STEP` | 3 (onboarding 5) | 21 (onboarding 35) |
| moral toparlanma adımı `MORALE_EASE_PER_DAY` | 3 | 21 |
| deneyim tabanı | 1 | en az 7 |

B2B bakım sönümü (müşteri temsilcisinin erimeyi yavaşlatması) günlük aşağı adıma uygulanır ve tamsayıya kesilir,
sonra ×7 alır: gün modelinin yedi günlük adımı aynen korunur. Yukarı yönlü hareket değişmez.

### 3.4 Sönen oranlar takvim günüyle integre edilir

- Sönen oran tik başına düz ×7 yapılmaz. BETA keşfi `BETA_BUG_FIND_PER_DAY` (6) × `BETA_FIND_DECAY`^⌊beta günü⌋'dür;
  oran beta günü içinde sabittir ve saatlik tikin kapsadığı takvim aralığında, gün sınırında bölünerek integre edilir.
- Gün modelinin kalibrasyonu aynen korunur: 0,85'te ilk hafta 27,18, ömür boyu 40 keşif; araştırmalı 0,90'da
  31,30 / 60. Düz ×7 ilk haftada 42 verirdi.

### 3.5 Sürekli zaman sabitleri tam bölünür

- `INFLOW_TAU` 21 gün → 3 hafta. `INTEREST_HALF_LIFE` 30 gün → 30 / 7 ≈ 4,29 hafta; yuvarlanmaz.
- Sürümün yaşı haftadır ve yayın saatinin kesrini taşır (yayın damgası tik + saat / 24).

### 3.6 Olasılıklı pencereler hafta tanesine göre kurulur

- İstifa: pencerenin ikinci haftasında tek zar atılır, zar dört günlük olasılığı biriktirir; üçüncü hafta istifa
  kesindir (§4.4).
- Temsilci işleme: süre yerine tik başına kapanma ihtimali (§4.5).

### 3.7 Orantılı terimler

Rakip payı büyümesi, rakip ivmesi ve B2C ağızdan ağıza gibi orantılı terimlerde ×7 birinci derece yaklaşıklıktır;
en kötü durumda churn'de %3 sapma kabul edilir. Takvim günü isteyen formül `days()`, ay isteyen `months()` okur.

### 3.8 Bildirim süreleri

- Anlık kart (kesinti) hemen cevaplanır.
- Bekleyebilen her kart, yani kâğıt ve tempo tarafından bildirime düşürülebilen her kesinti, kendi bekleme süresini
  `expires_weeks` olarak taşır. Süre durumun doğasına göre seçilir; tablo §4.10'dadır. `EvTuning.EXPIRY_*` değerleri
  yalnız geri düşüştür. Lint (17.7) `expires_weeks`'i her kesinti ve kâğıt kartında ister.
- Kritik kesinti ve bilgi kartı bildirime düşmez; taşıdıkları süre okunmaz. Kâğıt sınıfı kart kritik olsa da masaya
  düşer ve süresi okunur (`world.final_stretch_press`).
- Bildirim kalan haftayı gösterir. Son haftasında vurgulanır (`expiring`): kalan 1 hafta ve ömür 1 haftadan uzun
  (`EXPIRY_URGENT_WEEKS` 1). Son uyarı bir tik önce, dolum bir sonraki tikte gelir.
- Tek haftalık bildirim baştan "bu hafta" der ve ayrı son uyarı almaz.

## 4. Çeviri tablosu

Gün modelinin değeri ile yürürlükteki değer. Oranlar (§3.2) tabloda yoktur, gün verisi olarak kalırlar. Saat
cinsinden sabitler (toplantı süreleri, giriş kesimi, kartların `allowed_hours`'u) değişmez. Tohum ya da hash olarak
kullanılan gün değişmez.

### 4.1 Çekirdek ve saat

| sabit | gün modeli | yürürlükte | not |
|---|---|---|---|
| `TimeManager.SECONDS_PER_DAY` → `TimeModel.SECONDS_PER_HOUR` | [0, 12, 6, 3] sn/gün | [0, 10, 5, 3,33, 2,5] sn/saat [WORKING] | varsayılan gün 90 / 45 / 30 / 22,5 sn; 4× vardır |
| `INITIAL_HOUR` → `WEEK_START_HOUR` | 9 | 8 | |
| `DAYS_PER_MONTH` | 30 (GameState) | 30 (`TimeModel`) | ekonomi ayı |
| `HOURS_PER_DAY` | 24 (TimeManager) | 24 (`TimeModel`) | `HOURS_PER_BUILD_DAY` yoktur |
| iş günü yardımcıları | 5 / 7 | yok | hafta sonu yoktur |

### 4.2 Ürün, Destek, Altyapı

| sabit | gün modeli (gün) | yürürlükte (hafta) | not |
|---|---|---|---|
| `ITER_ROUND_*` | 4 | 1 | tasarım turu bir tik sürer |
| `CANCEL_FREE_*` | 1 | 1 | yapımın başladığı tik içinde iptal bedelsiz |
| `MIN_SPRINT_*` / `MAX_SPRINT_*` → `SPRINT_WEEKS` | 1 / 7 | 1 | ⚑ sprint her zaman bir haftadır; test uzmanlığının sprint süresine bağı yoktur (`TESTER_SPRINT_PER_EXPERTISE` silindi) |
| `BUG_HISTORY_*` | 7 günlük örnek | 2 haftalık örnek | ⚑ trend bu hafta ile geçen haftayı karşılaştırır; `TREND_DELTA` 2 / `TREND_SPIKE` 4 aynı |
| `INFLOW_TAU` | 21 | 3 | §3.5 |
| `INTEREST_HALF_LIFE` | 30 | 30 / 7 ≈ 4,29 | §3.5 |
| `BETA_BUG_FIND_PER_DAY` / `BETA_FIND_DECAY` / `_RESEARCHED` | 6 / 0,85 / 0,90 | aynı, gün verisi | §3.4 |
| `DAMAGE_DAILY_CAP` | -2 / gün | -2 / gün, tik başına -14 | §3.3 |
| süre tahminleri (`estimate_*`) | gün, yukarı | hafta, yukarı | `ceil(efor / per_tick(oran))` |
| sonraki sürüm kartının tabanı | 3 gün | 1 hafta | |
| balayı H (Ürün §15) | 45 [K] | 6 [K] | talep üreteci bağlı değil; kodda sabiti yok |

### 4.3 Ar-Ge

| sabit | gün modeli | yürürlükte | not |
|---|---|---|---|
| `report_period_*` (`rnd_tree.json`) | 30 gün | 4 hafta | aylık not |
| `research_per_day` | gün başına | gün başına, tik başına ×7 | kurucu terimi × (1 - haftanın toplantı payı), §8.4 |
| araştırma tahmini (`*_estimate*`) | gün | hafta | |

### 4.4 Ekip

| sabit | gün modeli (gün) | yürürlükte (hafta) | not |
|---|---|---|---|
| `SEARCH_ARRIVAL_*` | 7 | 1 | aday dosyaları bir hafta sonra gelir |
| `NEW_HIRE_BADGE_*` | 14 | 2 | rozet alım tikinde ve ardından 2 tik görünür |
| `TRAINING_*` | 14 | 2 | |
| `RESIGN_WINDOW_MIN_*` / `MAX_*` | 10 / 14 | 2 / 3 | kaçma riski 2 hafta sürünce tek zar; 3. haftada istifa kesin |
| `RESIGN_CHANCE_PER_DAY` | 0,25 / gün | 0,25 / gün [WORKING] | zar `1 - (1 - 0,25 × huy çarpanı)^RESIGN_ROLL_DAYS` |
| `RESIGN_ROLL_DAYS` | yok | 4 | haftalık zarın biriktirdiği gün: çarpansız %68,4, SADIK (×0,6) %47,8, GÖZÜ YÜKSEKTE (×1,6) %87,0 |
| `LEAVE_*` | 14 | 2 | |
| `LEAVE_DEFER_*` | 30 | 4 | |
| `RAISE_COOLDOWN_*` | 180 | 26 | |
| `HRConstants.DAYS_PER_YEAR` → `TimeModel.WEEKS_PER_YEAR` | 365 | 52 | kıdem tazminatı |
| `EXPERIENCE_PER_WORKED_DAY` / `EXPERIENCE_BUILD_BONUS` | 2 / 1 gün başına | aynı, tik başına ×7 | taban 1 / gün → en az 7 / tik; yapımda 21 / tik |
| `MORALE_BASE_DRIFT_PER_DAY` | 0,25 | aynı, tik başına 1,75 | saat, yük ve huy ölçeklemesinden önce |
| `MORALE_EASE_PER_DAY` | 3 | aynı, tik başına 21 | §3.3 |
| mesai | Ekip §8.1 | §9 | |

### 4.5 Satış, B2B, B2C

| sabit | gün modeli | yürürlükte | not |
|---|---|---|---|
| `LEAD_LIFE_*` | 7 gün | 1 hafta [K] | süre dolumu temsilci masasından sonra süpürülür (`SalesFaucetSystem.expire_leads`): lead dolduğu tikte de temsilci masasına girebilir, hafta içinde doğan lead ertesi tikin masasına ulaşır |
| `RETURN_LOCK_*` | 30 gün | 4 hafta [K] | |
| `WALK_LOCK_*` | 30 gün | 4 hafta [ÇALIŞMA] | |
| `PROCESS_DAYS_OWN_LEAGUE` / `ONE_BELOW` / `TWO_BELOW` → `PROCESS_CLOSE_CHANCE` | [6, 7] / [3, 4] / [2, 3] gün | tik başına {kendi lig 0,50 · bir alt 0,75 · iki alt 1,00} [WORKING] | işleme tikinde tohumlu zar; beklenen süre 2 / 1,33 / 1 hafta |
| `PROCESS_PREMIUM_PENALTY` | süre ×1,3 | ihtimal ÷1,3 [K] | beklenen süre ×1,3 aynen |
| `PROCESS_MIN_DAYS`, `PROCESS_REFERENCE_OUTPUT`, `work_due_day` | var | yok | ⚑ temsilcinin etkin çıktısı süreyi etkilemez (Açık 1) |
| `PRICE_BREAK_TRIGGER_LAST_DAYS` / `PRICE_BREAK_CANT_SAY_NO_MULT` | son 2 gün / pencere ×1,6 | yok | ⚑ fiyat-kırma her işleme tikinde zardan önce, lead başına bir kez değerlendirilir; HAYIR DİYEMEZ bağı yok (Açık 2) |
| `WEEKLY_SUMMARY_INTERVAL_*` | 7 gün | 1 hafta [ÇALIŞMA] | haftalık satış kartı her tik |
| `FAUCET_BASE_PER_WEEK` / `FAUCET_PER_REP_PER_WEEK` / `ONE_STAR_FLOOR_PER_WEEK` | 3 / 2 / 1, gün başına ÷7 | 3 / 2 / 1, tik başına tam [K] | `DAYS_PER_WEEK` bölmesi yok |
| `FAUCET_DAILY_MAX` → `FAUCET_TICK_MAX` | 2 / gün | 14 / tik [K] | ⚑ lead'ler haftanın başında toplu gelir |
| `ONBOARDING_*` | 30 | 4 | |
| `RISK_TRIGGER_*` | 3 | 1 | tek riskli tik tetikler |
| `RISK_REENTRY_*` | 21 | 3 [WORKING] | |
| `CHURN_COUNTDOWN_*` | 7 | 2 | sahip kararı |
| `EXPANSION_MATURE_*` | 45 | 6 | |
| `RETAIN_DELAY_*` | 3 | 1 | |
| `PROMISE_DEADLINE_*` | 14 | 2 | |
| `CS_REQUEST_INTERVAL_*` / `CS_PHASE_STRIDE` | 22 / 9 | 3 [WORKING] / 2 | adım aralıkla aralarında asal |
| `CS_ESCALATION_WINDOW_*` / `CS_ESCALATE_AFTER_*` | 7 / 3 | 1 / 1 | haftalık tavan `CS_ESCALATION_WEEKLY_CAP` 2 aynı |
| `TRUST_OFFSET_DECAY_PER_DAY` | 0,4 / gün | aynı, tik başına 2,8 | |
| `CS_THROUGHPUT_BASE` / `_PER_PACE` | 0,5 / 0,15 gün başına | aynı, tik başına ×7 | banka tavanı aynı |
| B2C memnuniyet kayması | ±1 / gün | ±7 / tik | |
| B2C saatlik kitle katsayıları | saatlik adımda ×1 | saatlik adımda ×7 | `growth_band` eşikleri aynı |
| günde bir satış toplantısı | kural | haftada en fazla 4 (`MEETINGS_PER_WEEK` [WORKING]) + saat bütçesi | §8 |
| `MEETING_SKIP_HOURS` | 2 saat [K] | 2 saat [K] | §8 |
| `MEETING_ENTRY_CUTOFF_HOURS` | 2 saat [ÇALIŞMA] | 2 saat [ÇALIŞMA] | kurucunun mesai bitişine göre, §8.2 |
| müşteri kıdemi | (gün - kazanım) / 30 | `months(tik farkı)` | |

### 4.6 Finans

| sabit | gün modeli | yürürlükte | not |
|---|---|---|---|
| `CASH_HISTORY_CAP` | 760 günlük örnek | 110 haftalık örnek | yumuşak tavan 104 + pay |
| `WARN_SNOOZE_*` | 14 gün | 2 hafta [WORKING] | |
| grafik `RANGES` (pencere / ufuk) | 6 ay {180, 60}, 12 ay {360, 120}, tümü {0, 60} gün | {26, 9}, {52, 17}, {0, 9} hafta | x ekseni tiktir |
| 1 ayın altındaki runway | gün | hafta (`floor(ay × 30 / 7)`) | |
| `red_days` → `red_weeks` | eksi kapanan gün | eksi kapanan tik | |
| `RUNWAY_ALERT_MONTHS` | rozet 3 ay (literal) | [3, 1] ay [WORKING] | rozet ilkini, şerit satırı ikisini okur (§6.4) |
| `RUNWAY_ALERT_REARM_MONTHS` | yok | 0,5 ay | |
| runway çiftinin kırmızısı (`RUNWAY_PAIR_EPSILON`) | 0,05 ay farkı | yok | çift, basılan iki metin farklıysa değişmiş sayılır |

### 4.7 Fon (VC, seed, Frank)

| sabit | gün modeli | yürürlükte | not |
|---|---|---|---|
| `MEETING_LEAD_*` | 3 gün | 1 hafta | toplantı gelecek hafta; erteleme de bir bekleme süresi kadar kaydırır |
| `PREP_*` / `PREP_MIN_*_BEFORE` | 2 / 2 gün | 1 / 1 hafta | ⚑ hazırlık yalnız görüşmeye en az bir hafta varken başlar |
| `SHEET_VALIDITY_BUSINESS_DAYS` → `SHEET_VALIDITY_WEEKS` | 10 iş günü | 3 hafta | sahip kararı: teklif 3 tik canlıdır, karar 4. tikte |
| `WARNING_DAYS` → `WARNING_WEEKS` | 3 iş günü | 2 hafta | uyarı kartı ve TopBar çipi son 2 haftada, son cevap (`last_answer`) son haftada |
| `EXPECT_GRACE_*` | 60 gün | 9 hafta | |
| `MEETING_HOURS` | yok | 2 saat [WORKING] | seed ve Series A pitch'i; 1. vuruşta çekilme 1 saat |
| `TERM_TABLE_HOURS` | yok | 1 saat [WORKING] | term sheet masası |

### 4.8 Sonlar ve olay motoru

| sabit | gün modeli (gün) | yürürlükte (hafta) | not |
|---|---|---|---|
| `SHUTTER_*` | 30 | 4 [WORKING] | kepenk |
| `BRAND_COLLAPSE_WINDOW` | 30 | 4 [WORKING] | ad birim eki taşımaz |
| `SOFT_CAP_DAY` → `SOFT_CAP_WEEK` | 730 | 104 [WORKING] | |
| son düzlük kartları `time.day ≥` → `time.week ≥` | 640 / 700 / 729 | 91 / 100 / 103 | 103 = `SOFT_CAP_WEEK - 1` |
| `ACQ_CARD_WINDOW_*` | 10 | 1 [ÇALIŞMA] | kartta literal 1 |
| `EndingsCopy` `YEAR_*` / `OVER_YEAR_*` / `TWO_YEAR_*` / `OVER_TWO_YEAR_*` | 350 / 380 / 700 / 745 | 50 / 54 / 100 / 106 | |
| `ISSUE_PERIOD_*` | 7 | 1 [WORKING] | gazete sayısı = koşu haftası |
| kepenk gazetesinin Frank satırı `{days}` | 30 | 28 (4 hafta × 7) | Frank metni aynı kalır |
| `MIN_GAP_*_DEFAULT` (+ katalog varsayılanı) | 30 | 4 | |
| `SUBJECT_GAP_EMPLOYEE_*` / `CUSTOMER_*` | 14 / 30 | 2 / 4 | |
| `CATEGORY_QUOTA_7D` → `CATEGORY_QUOTA_WEEK` penceresi | 7 (fiilen 8) | 1 tik | değerler aynı: ekip 2, müşteri 2, ürün 2, rakip 1, fon 1, kurucu 1, dünya 1 |
| `MAX_INTERRUPTS_PER_DAY` | 2 / gün | 2 / tik | ad korunur: oyun günü tiktir |
| `FLOOR_QUIET_*` | 5 | 1 | |
| `FLOOR_EMPTY_REPORT_AFTER` | 3 | 3 | tetik sayısıdır |
| `EXPIRY_DEFAULT` / `MONEY` / `LOW_STAKES` / `URGENT` | 7 / 30 / 14 / 3 | 1 / 4 / 2 / 1 | yalnız geri düşüş, §3.8 |
| `ARC_AWAITING_SUBJECT_TIMEOUT_*` | 14 | 2 | |
| `DEFAULT_COOLDOWN_*` | 30 | 4 | |
| kart `cooldown` | 21, 14 ×3, 6, 5, 1 ×4, 0, 90 | 3, 2 ×3, 1, 1, 1 ×4, 0, 13 | cs_escalation; request_complaint, request_feature, request_renewal; weekly_summary; gate_series_a; retention, meeting_day, sheet_decision, version_ship; price_break; seed_stalled |
| kart `deadline` | 14 ×4 | 2 ×4 | cs_escalation, request_complaint, request_feature, retention |
| seam eşikleri | `sheet_days_left ≤ 3`, `angel ≥ 2`, `seed_close ≤ 1`, `acq ≤ 10`, `launch ≥ 1`, `history ≥ 1` | `sheet_weeks_left ≤ 2`, ≥ 1, ≤ 1, ≤ 1, ≥ 1, ≥ 1 | ⚑ `gate_series_a`'daki `history weeks_since ≥ 1` Frank'in kapı satırıyla karar kartı arasına tam bir hafta koyar |
| harness kayıt aralığı / varsayılan koşu | 50 / 365 gün | 7 / 52 hafta | tarama saatleri 9, 13, 16 (17:00 varsayılan mesaide gecedir) |

### 4.9 Haber, rakipler, ofis, kayıt

| sabit | gün modeli | yürürlükte | not |
|---|---|---|---|
| `DAILY_LINES_MIN/MAX` → `WEEKLY_LINES_MIN/MAX` | 3 / 5 günde | 3 / 5 haftada | ⚑ şerit 7,5 kat seyrek akar; döngü 30 satırla dolu kalır |
| `RIVAL_COOLDOWN_*` | 2 gün | 1 hafta | |
| `SHARE_MOVED_WINDOW_*` | 7 gün | 1 hafta | |
| `SHARE_GROWTH_PER_DAY` | 0,004 × gün | 0,004 × `days(tik)` | gün verisi |
| rakip ivmesi | gün başına | tik başına ×7 | |
| `MOVE_*` | 7 gün | 1 hafta [WORKING] | |
| autosave aralığı | gün / hafta / ay | kapalı / her hafta (1 tik) / her ay (ay kapanışı) [WORKING] | varsayılan her hafta |
| `AUTOSAVE_MIN_REAL_SECONDS` | 20 sn | 10 sn [WORKING] | 4×'te kısa gün 20 sn eder |
| `BIZ_BUFFER_CAP` / `MAX_LIVE_LINES` | 10 / 6 | aynı | sayılar aynı; tik başına 7 günün satırı birikir |

### 4.10 Kart başına bekleme süresi

Bildirim alanına düşen kart bu süreyle bekler: kâğıt sınıfı kart ve tempo bütçesinin kâğıda düşürdüğü kesinti. Kritik
kesinti ve bilgi kartı bildirime düşmez; değerleri lint ya da bilgi için taşınır ve okunmaz.

| kart | sınıf | bekleme (hafta) | gerekçe |
|---|---|---|---|
| `customer.request_complaint`, `request_feature`, `request_renewal` | kâğıt | 2 | talep bekletilebilir |
| `customer.expansion` | kâğıt | 2 | |
| `customer.cs_escalation`, `frank_intro` | kesinti, kritik | 1 | sayaç işliyor |
| `customer.retention` | kesinti | 1 | churn sayacı işliyor |
| `sales.price_break` | kesinti | 1 | teklifin son haftası |
| `sales.weekly_summary` | bilgi | 1 | haftalık özet |
| `funding.meeting_day`, `sheet_decision`, `last_answer`, `sheet_expiry` | kesinti, kritik | 1 | bu haftaya bağlı |
| `funding.acquisition_offer` | kesinti, kritik | 1 | `ACQ_CARD_WINDOW_WEEKS` |
| `funding.shutter_warning` | kesinti, kritik | 1 | hiç düşmez |
| `funding.frank_cheque`, `seed_offer` | kesinti, kritik | 4 | para masası (`EXPIRY_MONEY_WEEKS`) |
| `funding.frank_approach_close`, `_half`, `_near`, `frank_door_open`, `frank_office_move`, `gate_traction`, `gate_series_a`, `seed_door`, `seed_closed`, `hire_nudge` | kesinti, kritik | 2 | duyuru, bekleyebilir |
| `funding.seed_stalled` | kâğıt | 2 | |
| `product.design_round_intro`, `first_ship`, `version_ship`, `paid_tier` | kesinti, kritik | 1 | o haftanın olayı |
| `team.resignation` | kesinti, kritik | 1 | |
| `world.final_stretch_press` | kâğıt, kritik | 4 | |
| `world.final_stretch_comment`, `final_stretch_verdict` | kesinti, kritik | 1 | yumuşak tavana bağlı |

## 5. Takvim ve tarih satırı

- Tik N'in tarihi 1 Ocak 2026 + (N - 1) × 7 gündür (`GameState.get_date_dict`). 1 Ocak 2026 Perşembe olduğu için her
  tik bir Perşembe'ye düşer.
- Tikin ayı o Perşembe'nin gerçek takvim ayıdır; aylar 4 ya da 5 haftalıktır. Ekonomi ayı (`DAYS_PER_MONTH` 30)
  yalnız oranlar ve runway içindir, ay sınırını belirlemez.
- Hafta numarası tikin Perşembe'sinin ISO yıl-içi haftasıdır: (yılın günü - 1) / 7 + 1. Yılı takvim yılıdır; yıl
  başında 1'e döner.
- Ay sınırı: `ay(tik) != ay(tik - 1)` ise önceki ay kapanır (§6.2).
- Yaz izni haftası, Haziran ile Ağustos arasındaki Perşembe'lerin sırasından seçilir. Pencerede 2026 ve 2027'de 13,
  2028'de 14 tik vardır; izin haftası ilk 13'ünden biridir (`HRConstants.LEAVE_WEEK_COUNT` 13).
- Tarih satırı haftayı, ayı ve yılı okur (`DATE_LINE`, örnek: "Hafta 14 · Nisan 2026"). TopBar saati ekler
  ("Hafta 14 · Nisan 2026 · 09:00"); dar genişlikte kısa biçim (`TOPBAR_CLOCK_COMPACT`, "H14 · Nis · 09:00").
  Haftanın günü yazılmaz.
- "Hangi hafta" damgası taşıyan her yüzey aynı tarih satırını okur: kayıt yuvası, olay kartının karar ve okuma
  damgası, VC şeridi, gazete künyesi. Finans işlem tarihi kısa biçimi okur (`FIN_TX_DATE`, "H14 · Nis 2026").
- Süre sayaçları "N hafta" okur. Tike bağlı "bugün / yarın" "bu hafta / gelecek hafta" olur. Anlatının içindeki gün
  lafları dokunulmaz.
- Yeni ve değişen oyuncu metni önce İngilizce yazılır, Türkçe yerelleştirme ayrı adımdır; onaya kadar "TR/EN onay
  bekliyor" işaretini taşır. Frank satırlarının yeni hâli taslaktır; onaya kadar eski onaylı metin kalır. `{days}`
  yer tutucusu olan Frank satırına gün cinsinden değer (hafta × 7) verilir, cümle doğru kalır.

## 6. Ekonomi, ay kapanışı, özet, uyarılar

### 6.1 Para haftalık pay alır

- Aylık MRR, maaş ve gider günlük orana çevrilir (÷30); her tik bunun 7 günlük payını uygular: aylık × 7 / 30.
- `FinanceSystem.daily_tick` tik başına nakit += 7 × (round(MRR / 30) - günlük burn) uygular. Bu, ×7'nin paradaki
  tek yeridir.
- Maaş ÷30, `InfraSystem.daily_bill` ve ek mesai günlük oran olarak kalır (günlük burn'ün içindedir); kaynakta ×7
  yapılmaz. Tek seferlik giderler değişmez.
- Ay defteri aynı tik rakamlarını biriktirir: 7 × round(MRR / 30) ve 7 × günlük burn.
- Runway formülü değişmez: nakit / (-günlük net) / 30 ay.
- `cash_history` her tik bir örnek alır (tavan 110).
- İlk haftada nakit akışı yoktur: 1. günde finans tiki koşmaz. Kalibrasyon bunu bilir.

### 6.2 Ay kapanışı sessizdir

- Ay kapanışı muhasebe sınırıdır ve günlük dağıtımın başında, yuva 0'da koşar (`SummarySystem.begin_day`,
  `advance_day`'den hemen sonra, üründen önce). Böylece yeni ayın ilk haftasının akışı yeni aya yazılır. Ocak 2026 beş
  Perşembe'lidir, ama 1. günde finans tiki koşmadığı için 4 × 7 = 28 günlük akış taşır.
- Yuva 0'da kapanan ay `month_history`'ye girer, `month_ended` yayılır ve yeni ayın defteri açılır.
- Ay kapanışı modal açmaz. Defter kapanır, TopBar'ın aylık rakamları yenilenir ve yuva 10'da (sonların taramasından
  sonra) haber şeridine tek satır düşer (`MONTH_CLOSED_TICKER`): "{month} kapandı · MRR {mrr} · nakit {delta}". Satır
  yalnız canlıdır, "biz" arşivine girmez.
- `month_ended`'i dinleyenler kalır: finans görünümü, probe'un ay satırı, aylık autosave, TopBar.

### 6.3 Özet ekranı ve sıklığı

- Özet ekranının sıklığı Ayarlar'dan seçilir (`summary_frequency`): her hafta, her ay, her çeyrek, her yıl.
  Varsayılan her çeyrektir.
- Tetikler: haftalık her tik; aylık ay kapanışında; çeyreklik ay kapanışında yeni ay Ocak, Nisan, Temmuz ya da Ekim
  ise; yıllık ay kapanışında yeni ay Ocak ise.
- Dönemin açılış anlık görüntüsü `summary_ledger`'dadır: başlangıç tiki, MRR, nakit, ekip, marka. Para tahakkuk
  etmez. Dönemin öne çıkan olayı dönem kapanınca temizlenir.
- Özet yükü yuva 0'da kurulur, `summary_ready` yuva 10'da yalnız koşu sürüyorsa yayılır: aynı tik biten koşuda son
  kazanır. Süren kepenk özeti bastırmaz.
- Frank satırı: aylık kipte ay özetinin kuralları geçer. Diğer kiplerde yalnız döneme nötr satırlar
  (`MONTH_FRANK_BURNING_BUT_SELLING`, `MONTH_FRANK_SHRINKING`) gösterilir; "ay" diyen satır gösterilmez.
- Dönem içinde sıklık değişirse sayaç sıfırlanmaz: yeni sıklığın ilk sınırı dönemi kapatır.
- Smoke ve probe oyuncunun ayarını okumaz; sıklığı `SummarySystem.frequency_override` ile sabitler.

### 6.4 Uyarılar anında gelir, özet ayarından bağımsızdır

- Kepenk kartı ve TopBar kepenk sayacı.
- Finans rozeti: runway `RUNWAY_ALERT_MONTHS`'ın ilk eşiğinin (3 ay) altında.
- Finans sekmesinin başlığı ve mentor kartı: runway 6 ayın altında (`RUNWAY_WARN_MONTHS` [WORKING]).
- Runway şerit satırı: runway 3 ya da 1 ayın altına indiği tikte şeride tek satır düşer.
  - Yuva 10'da, sonlardan sonra hesaplanır. Koşu bittiyse ya da nakit eksideyse atlanır.
  - `runway_warn_band` yalnız aşağı yönde geçilen en düşük eşiği duyurur. Runway eşik + 0,5 ayın üstüne çıkınca ya da
    sonsuz olunca eşik yeniden kurulur. Koşu başında ve göçte sessizce ilklenir.
  - 6 ay eşiği yoktur: başlangıç runway'i her koşunun 3. haftasında onu geçerdi.
- TopBar'da burn ve net canlı aylık hızdır (`/ay`), `FinanceSystem.get_monthly_flow()`'dan gelir: gelir = MRR,
  gider = günlük burn × 30, net = günlük net × 30.

### 6.5 Autosave

- Seçenekler: kapalı, her hafta (her tik), her ay (`month_ended`). Varsayılan her hafta [WORKING]. Kayıtlı eski
  "her gün" değeri varsayılan olarak okunur.
- Autosave arası en az 10 gerçek saniyedir (`AUTOSAVE_MIN_REAL_SECONDS` [WORKING]).
- 00:00 autosave'i gece atlamasının içinde yazılır ve aktif kartla engellenmez (§1.2). Engellenen autosave, kart
  kuyruğu boşalınca `event_resolved`'da yeniden dener.

## 7. Günün akışı ve gece atlaması

### 7.1 Günlük dağıtım sırası

| yuva | sistem |
|---|---|
| 0 | ay kapanışı ve özet dönemi (`SummarySystem.begin_day`) |
| 1 | Ürün, Destek, Altyapı, ürün kenar sinyalleri |
| 2 | Ar-Ge |
| 3 | Ekip |
| 4 | Satış (MRR toplanır), rakipler |
| 5 | Finans (tikin net akışı) |
| | ofis taşınması, faz kapıları, seed |
| 6 | olaylar |
| 7 | haber şeridi |
| 8 | VC saatleri |
| 9 | sonların taraması |
| 10 | özet ve şerit satırları (`SummarySystem.daily_tick`) |

### 7.2 Hafta ve gece

- Hafta 08:00'de başlar. Kurucunun toplantı sayacı 08:00'de sıfırlanır; gece ve 00:00'ın günlük tiki biten haftayı
  okur.
- Gece: `saat >= mesai bitişi` ya da `saat < 08:00`. Bitiş anında gece başlar. 08:00 hiçbir zaman gece değildir
  (başlangıç ≥ 8, süre ≥ 5).
- Mesai bitişi `WorkHoursSystem.workday_end()`'dir: kurucunun bitişi taban, ofisteki her çalışanın bitişi onu
  uzatabilir, en geç 24. Değer oyun durumundan belirlenir, görünüme bağlı değildir.
- Gece her karede türetilir; bir saat sınırında bir kez tetiklenmez. Gece saatinde yüklenen kayıt ve 00:00'da yazılan
  autosave aynı kurala düşer.
- Bir karenin birden çok saat taşıdığı takılmada adım geceye inerse karenin kalan saatleri düşer: kare takılması
  mesai bitişini aşamaz.
- 24:00'te biten mesaide saat 23'ü gösterirken biriken saatin 24'e vardığı an da gecedir (`TimeManager.is_night`
  akümülatörü de okur). 23 → 0 devri gece atlamasına kalır; günlük tikin kartları 08:00'i bekler. Çıkış beklenirken
  ofisin ışığı 24:00'te durur, geri sarmaz (`TimeManager.day_minute` 24'te kırpılır).

### 7.3 Atlama

- Gece başlayınca saat donar (`freeze_clock("night")`). Ofis görünümü "ofis boş" yüklemini kaydetmişse gece onu her
  kare yoklar ve en fazla `OfficeConstants.NIGHT_WAIT_S` = 3,5 gerçek saniye [WORKING] bekler. Bekleme yalnız kare
  süresiyle sayılır; duraklatma sayacı da yürüyüşü de birlikte dondurur.
- Kayıtlı yüklem yoksa (headless, smoke, probe) atlama hemen olur.
- Atlamadan hemen önce gece yeniden okunur: oyuncu çıkış sırasında mesaiyi uzatmış olabilir.
- Atlama mutlak hedefe gider: bir sonraki 08:00. Bitiş E ise atlanan saatler E+1'den 23'e, 0 (devir, günlük tik, ay
  kapanışı, özet, autosave) ve 1'den 8'e kadardır; görünen saatlerle toplam 24 eder.
- Varış anında saat çözülür ve `night_skipped` yayılır.
- Gece saatlerinde kritik olmayan saatlik kart kapıdan geçmez; kritik kart atlamanın sonunda gösterilir.
- Haftanın saatlik değişiminin gecedeki payı tek karede iner (varsayılan mesaide 24 saatin 15'i); ilerleme çubukları
  sabahları zıplar.

### 7.4 Ofis görünümü

- Kişiler kendi yürüyüşlerinin süresine göre çıkar: çıkış yürüyüşü, yürüme süresinin `EXIT_SLACK` katı kadar önce
  başlar ve kapıdan tek tek geçilir. Sırası günün sonundan sonraya düşen ya da günü yürüyüşe yetmeyecek kadar kısa olan
  masasında kalır; gece yeni yürüyüş başlamaz, yüklem yalnız kapıya ya da yatağa yürüyenleri bekler, içeride kalan
  herkes kararma altında kesilir (`OfficePeople.CUT_FADE_S` kararması, sonra atlama).
- Kurucu şirket penceresini izler: pencere başında gelir, sonunda çıkar. Evde pencere dışı yeri yataktır.
- Atlamanın ardından kısa kararma ve 08:00 ışığı (`NIGHT_FADE_S` 0,6 sn [WORKING]).

## 8. Toplantılar

### 8.1 Saat bütçesi ve atlama

- Toplantı sahnesi açıkken saat durur. Kapanışta saat toplantının süresi kadar ileri atlar (`advance_hours(n)`): atlanan
  saatler simüle edilir, saatin kesri korunur (10:45 giriş 12:45'e iner).
- Atlama gece yarısını geçmez: n, `min(n, max(0, min(kurucu bitişi, 23) - saat))` ile kırpılır; kalan saatleri gece
  atlaması taşır. Kurucunun haftalık payına kırpılmış n yazılır (§8.4).
- Süreler:

| oturum | süre | sabit |
|---|---|---|
| satış toplantısı | 2 saat [K] | `SalesConstants.MEETING_SKIP_HOURS` |
| seed ve Series A pitch'i | 2 saat [WORKING] | `PitchConstants.MEETING_HOURS` |
| 1. vuruşta çekilinen pitch | yarı süre, 1 saat | `MEETING_HOURS / 2` |
| term sheet masası | 1 saat [WORKING] | `PitchConstants.TERM_TABLE_HOURS` |
| koşuyu bitiren imza | atlama yok | |

- Atlama sistemde durur, ana sahnede değil: satışta `SalesMeetingSystem.close()`, VC'de ve masada sahne kalktıktan
  sonra çağrılan `end_sitting()` atlamayı yapar. Probe aynı yoldan geçer.
- Oturumu kapatan sistem kurucuyu atlamadan önce serbest bırakır (satışta `close()`, VC'de ve masada `reset()`);
  saat kurucunun meşguliyetine dokunmaz.

### 8.2 Giriş kapısı

- Dört oturum için tek kural: gece ise ya da saat > kurucunun mesai bitişi - oturum saati ise giriş kapalıdır ve
  kilit nedenini gösterir. Kapının tek evi `WorkHoursSystem.sitting_open(saat)`'tir; satış toplantısının kapısı
  (`SalesLedger.meeting_block_reason`), Yatırım sekmesi ve iki seam (`funding.meeting_sitting_open`,
  `funding.table_sitting_open`) onu okur.
- Satışta kesim `MEETING_ENTRY_CUTOFF_HOURS` (2 [ÇALIŞMA]) saattir. Kapı sırası: gece ya da çok geç
  (`SALES_BLOCK_TOO_LATE`) → hafta dolu (`SALES_BLOCK_WEEK_FULL`).
- VC toplantı kartı ve term sheet karar kartı saatlik değerlendirilir ve oturum kapısı açıkken kabul edilir. Term
  sheet ve seed kartlarının "masaya otur" seçeneği, Yatırım sekmesinin düğmeleri ve masa kapalı kapıda nedenli
  kilitlidir (`VC_BLOCK_LATE`).

### 8.3 Haftalık tavan

- Haftada en fazla 4 satış toplantısı (`SalesConstants.MEETINGS_PER_WEEK` [WORKING]), mesai uzunluğundan bağımsız.
  Sayaç `sales_meetings_week` {tik, sayı}'dır; yeni tik sayacı sıfırlar.
- 09:00-17:00 mesaide haftaya tam 4 toplantı sığar: 08:00'den 8, 10, 12, 14; 09:00'dan 9, 11, 13, 15.
- VC, seed pitch'i ve term sheet masası tavana sayılmaz: randevuludur ve seyrektir.

### 8.4 Kurucunun toplantı maliyeti: haftalık pay

- Her toplantı kurucunun o haftaki çıktısından `toplantı saati / WEEK_WORK_HOURS` (40) payını alır. 2 saatlik toplantı
  haftalık kurucu çıktısının %5'idir; 4 toplantı %20.
- Saatlik sistemler (ürün yapımı, destek masası, BETA'da test) toplantı atlamasının saatlerinde kurucuyu
  `1 - HOURS_PER_DAY / WEEK_WORK_HOURS` = 0,4 katsayısıyla sayar. Atlanan her saat haftanın 1/24'ü olduğundan toplam
  kayıp tam saat / 40 eder.
- Günlük sistemler (Ar-Ge birikimi) kurucu terimini `1 - haftanın toplantı saati / 40` ile çarpar. Sayaç
  `founder_meeting_hours` (GameState) haftalık payın tek kaynağıdır.
- Aynı pay kuralı VC ve seed pitch'i ile term sheet masasına da uygulanır.
- Oturum boyunca (sahne açık, saat duruk) kurucu meşgul görünür (`HRSystem.founder_in_meeting`). Bayrak kayda girmez;
  oturumu kapatan her yol (satış kapanışı, VC bitişi ve çekilme, masada imza, yürüme, kalkma) onu temizler.

### 8.5 Kurucunun geçişi

Kurucunun dış toplantıya gidişi yürüyüş değil geçiştir. Geçiş yalnız ana sahnenin toplantı işleyicilerinde koşar;
mekanik ondan bağımsızdır ve headless güvenlidir.

1. Saat donar (`freeze_clock("travel")`); oturum geçişten önce açılır ve kurucu meşgul olur.
2. Pencere katmanı perdelenir; pencereler kapanmaz, dönüşte aynı pencere açık gelir.
3. Kurucu masadan kalkar ve çıkışa doğal hızla yürür; yürüyüş en fazla `EXIT_S` 1,5 sn [WORKING] izlenir.
4. Kısa kararma (her yarısı `FADE_S` 0,25 sn [WORKING]), sonra şehir haritası yol kipinde: kontrol yok, girdi
   kapalı, trafik akar.
5. Kamera ve iğne kurucunun ofisinden hedef binaya kayar (`DRIVE_TIME` 1,2 sn [WORKING]). Hedef binalar sahne
   verisidir (`OfficeConstants.MEETING_TARGET` [WORKING]).
6. Toplantı sahnesi takılır, saat duraklatılır, gezi donması çözülür.
7. Kapanışta saat toplantı süresi kadar atlar (§8.1), perde kalkar, hız geri gelir. Kurucu girişten masasına yürür;
   atlama mesai bitişine ya da ötesine indiyse yürüyüş olmaz, gece başlar.

- Geçiş sırasında gelen kart istekleri ertelenir ve toplantıdan sonra gösterilir; kart gösterildiği anda yeniden
  kurulur (`EventGate.active_card()`). Boşluk ve 1-4 tuşları geçişte yutulur, Ayarlar açılmaz. Tık ya da Esc geçişi
  atlar.
- Görsel kontrol: `--travel-shot=<ofis>` çıkış, harita, oda ve dönüş karelerini çeker. Shot ve harness koşularında
  geçiş yoktur.

### 8.6 VC randevusu

- Toplantı istemi bir hafta sonrasına düşer (`MEETING_LEAD_WEEKS` 1). Erteleme de bir bekleme süresi kadar kaydırır.
- Hazırlık 1 hafta sürer ve görüşmeye en az bir hafta varken başlar (`PREP_MIN_WEEKS_BEFORE` 1); bir haftalık
  randevuda bu, randevunun alındığı haftadır.
- İptal randevu masasını haftanın geri kalanında kapatır.

## 9. Mesai

| kural | değer |
|---|---|
| başlangıç | 08:00 ile 11:00 arası (`START_HOUR_MIN` = `WEEK_START_HOUR` 8, `START_HOUR_MAX` 11), varsayılan 09:00 |
| süre | 5 ile 16 saat arası (`WORK_HOURS_MIN` 5, `WORK_HOURS_MAX` 16), varsayılan 8, tam saat adımı |
| bitiş | başlangıç + süre, en geç 24 (00:00 yazılır) |
| moral çarpanı (`HOUR_MORALE_MULT`) | 5: -1,0 · 6: -0,5 · 7: 0 · 8: 1,0 · 9: 1,1 · 10: 1,3 · 11: 1,5 · 12: 1,7 · 13: 1,9 · 14: 2,1 · 15: 2,3 · 16: 2,5 |
| verim (`hours_output_mult`) | (min(s, 8) + max(s - 8, 0) × `OVERTIME_HOUR_YIELD`) / 8: 5 saat 0,625 · 8 saat 1,0 · 11 saat 1,1875 · 16 saat 1,5 |

- Başlangıç ve süre ayrı saklanır; süre okunurken `min(WORK_HOURS_MAX, 24 - başlangıç)` ile kırpılır
  (`WorkHoursSystem.max_hours(başlangıç)`; 11:00 başlangıç ile 16 saat 27'ye çıkmaz). Ücret, moral, verim, pencere ve
  modal aynı sayıyı okur; modalın taslak grup satırı da aynı çözümleyiciden geçer (`WorkHoursSystem.group_hours_in`).
- Azalan verim kurucuya da uygulanır: kurucunun uzun günü bedelsiz çıktı üretmez.
- Kapsam zinciri (şirket, grup, çalışan), ek mesai ücreti ve kısa günün moral kuralı Ekip §8'de kalır.
- Tavanın dayanağı oyun saatidir: gün 08:00'de başlar, mesai en geç 00:00'da biter.
- Mesai modalında sürgü ve bitiş saati 00:00'a kadar uzanır.
- Göç: eski kayıttaki 06:00 ya da 07:00 başlangıcı 08:00'e çekilir (`_migrate_14` yazar, `WorkHoursSystem.start_hour`
  okurken de kırpar); süre korunur, bitiş 1-2 saat kayar.

## 10. Kayıt göçü

- `SaveManager.SCHEMA_VERSION` 14, `MIN_LOADABLE_VERSION` 10. v13 → v14 göçü (`SaveManager._migrate_14`) merdivenin
  sonundadır; önceki göçlerin yazdığı gün değerleri de ondan geçer (ör. Satış rev 6 göçünün lead'e yazdığı vade).
- Göç saftır ve ucuzdur (yuva listesi de her kaydı ondan geçirir). JSON sayıları float gelir: damga, geri sayım ve
  seri tamsayıya çevrilip tamsayı yazılır; kesirli sayaç (R5) kesirli kalır.
- Alan adı değişiyorsa göç değeri yeni adla yazar, eski anahtarı siler (ör. `iteration_round_days` →
  `iteration_round_weeks`).
- Her damga tek fonksiyondan geçer (`_week_stamp`): bugünden sonraki gün R2, öbürü R1 alır. Motor bloğunun kendi
  sürümü (`EvSave.BLOCK_VERSION` 1) değişmez; bloğun gün değerlerini de bu göç çevirir.
- Smoke: `save_v13_day_stamps_migrate` gerçek bir kaydı v13'e yaşlandırır, her bloğa bilinen gün değerleri koyar,
  `read_slot`'un hafta değerlerini denetler ve göç edilmiş dünyayı yükleyip bir tik koşar.

**Kurallar** (`bugün` = eski `game_state.day`, `W(d) = (d - 1) / 7 + 1`):

| kural | uygulandığı değer | dönüşüm |
|---|---|---|
| R1 geçmiş damga | olmuş bir günün damgası | W(d); 0 ve altı nöbetçiler aynen kalır |
| R2 gelecek vade | d > bugün | W(bugün) + ceil((d - bugün) / 7); hiçbir bekleyen şey erken ateşlenmez; `NO_EXPIRY_DAY` dokunulmaz |
| R3 geri sayım | kalan gün | ceil(n / 7); 0 ve altı aynen |
| R4 ardışık seri | `flight_risk_days`, `risk_streak` | floor(n / 7), bağışlayıcı |
| R5 kesirli gün | birikmiş kesir | n / 7 |
| R7 örnek listeleri | `cash_history` | her haftanın son örneği |
| | `mvp_bug_history` | yalnız en yeni örnek |
| olay kütükleri | işlemler, satış ve kayıp kütüğü, istihdam geçmişi, sürüm geçmişi, haber akışı, motorun geçmiş satırları, şeridin bekleyen satırları | her satır kalır, `day` alanı damga olarak çevrilir |
| aynı-tik mandalı | `vc_meeting_cancel_day` | bugüne eşitse W(bugün), değilse -1 |
| silinenler | bayraklar `sales_meeting_used_day`, `sales_meeting_active`, `sales_weekly_closes`; lead'in `work_due_day`'i; `hr_search.started_day`; `month_ledger`'ın `mrr`, `employees`, `brand` anahtarları | işlemdeki lead bir sonraki tikte zara girer; ay defterinin üç anahtarı `summary_ledger`'a taşınır |
| türetilenler | `summary_ledger`, `runway_warn_band`, `company_start_hour` | dönem ayın açıldığı yerden açılır (başlangıç, nakit, MRR, ekip, marka); eşik bugünkü runway'den kurulur, yükleme satır duyurmaz; başlangıç en az 08:00 |
| varsayılanla doğanlar | `founder_meeting_hours`, `sales_meetings_week`, bayraklar `sales_weekly_close_rows` ve `sales_weekly_report_rows` (`[]`) | kayıtta yoksa tanımlı varsayılan |
| değişmeyenler | gün oranları (`daily_burn`, `burn_breakdown`, rakip ivmesi), mesai süresi, id içindeki günler, yaz izni haftası, sayaçlar, para | dokunulmaz |
| tempo penceresi | `event_engine.tempo_window` | temizlenir; yedi günü bir haftaya katlamak kesinti sayacını şişirirdi |

**Alanlar:**

- `meta`: `day`.
- `game_state`:
  - damgalar: `day`, `brand_low_since_day`, `seed_door_open_day`, `seed_closed_day`, `acq_road_over_day`,
    `bootstrap_milestone_day`, `office_move_day`, `cs_escalation_days[]`, `sales_return_locks` değerleri,
    `sales_account_memory.*.loss_day` / `insult_day`, `active_sheets[]` ve `seed_sheet`'in `granted_day` /
    `expires_day`'i, `pending_meeting.day`, `prep.done_day`, `hr_search.arrival_day`, `news_feed.recent_rivals`
    değerleri;
  - kütükler: `transactions[].day`, `sales_log[].day`, `sales_loss_log[].day`, `news_feed.stream[].day`;
  - `cash_history` (R7), `vc_meeting_cancel_day` (aynı-tik mandalı);
  - `shutter_days_left` → `shutter_weeks_left` (R3);
  - `month_history[]`: `start_day`, `end_day`, `red_days` → `red_weeks` (R3);
  - `month_ledger`: `start_day`, `red_days` → `red_weeks` (R3); `mrr`, `employees`, `brand` `summary_ledger`'a;
  - `summary_ledger`, `runway_warn_band`, `company_start_hour` (türetilir).
- `flags`: `mvp_launch_day`, `mvp_version_launch_day`, `sales_weekly_anchor_day` (0 = boş), `angel_seed_accepted_day`,
  `finance_runway_warn_snooze_until_day`, `mvp_version_history[].day`; `mvp_bug_history` (R7);
  `mvp_sprint_days_total` → `mvp_sprint_weeks_total` (R3); `mvp_sprint_days_elapsed` → `mvp_sprint_weeks_elapsed` (R5).
- `registries`:
  - karakter: `last_raise_day`, `last_promotion_day`, `hire_day`, `leave_until_day`, `employment_history[].day`;
    `flight_risk_days` → `flight_risk_weeks` (R4); `training_days_left` → `training_weeks_left` (R3);
  - müşteri: `acquired_on_day`, `onboarding_until`, `last_risk_exit_day`, `last_expansion_day`,
    `support_request_since_day`; `churn_countdown` (R3); `risk_streak` (R4); `cs_request_phase` → floor(faz / 7) mod
    `CS_REQUEST_INTERVAL_WEEKS`;
  - lead: `spawned_on_day`, `expires_on_day`, `work_started_day`;
  - söz: `deadline_day`.
- `systems`: `product.active_build`'in `start_day` ve `beta_entered_day`'i (0 = boş), `iteration_round_days` →
  `iteration_round_weeks` (R5); `rnd.note_last_day`.
- `event_engine`: `flags[].set_day`, `timed_flags[].expires_on` / `set_day`, `stamps[].day`, `latches[].last_day`,
  `held[].day` (şeridin bekleyen satırları), `rows[].day` ve `rows[].entities.*.bound_day`; `queue[]`, `schedule[]` ve
  `papers[]`'ın `admitted_day`, `fire_on_day`, `expires_on` alanları ve `context.*.bound_day`'i; `arcs[]`'ın
  `started_day`, `awaiting_since`, `subject.bound_day`'i, `frozen_schedule[].remaining_days` → `remaining_weeks` (R3)
  ve `frozen_schedule[].context.*.bound_day`; `tempo_window` temizlenir.

## Açık

Karar verilene kadar kod yukarıdaki hâliyle çalışır; sahip onayı bekleyen maddelerin yeri
`docs/ACIK_ISLER/ACIK_KARARLAR.md`'dir.

1. **Temsilcinin çıktısı işleme süresini etkilemiyor.** Satış §7.2'de moral, odak ve saat, `hr.effective_skill`
   üzerinden işleme süresini oynatır. Tik başına kapanma ihtimalinde bu bağ yoktur (`PROCESS_REFERENCE_OUTPUT`,
   `PROCESS_MIN_DAYS`, `work_due_day` silindi). Karar: bağ ihtimale geri kurulsun mu, nasıl?
2. **HAYIR DİYEMEZ'in fiyat-kırma etkisi yok.** Satış §7.6'da bu huydaki temsilcide kart daha sık düşer [K].
   Vade penceresi olmadığı için pencere çarpanı (`PRICE_BREAK_CANT_SAY_NO_MULT`) silindi; kart her işleme tikinde,
   lead başına bir kez değerlendirilir. Karar: huyun etkisi hafta tanesinde nasıl kurulur?
3. **Alt-hafta ayrımları tek tike çöküyor.** ⚑ satırlarında (sprint uzunluğu, hazırlık, lead'lerin toplu gelişi, bug
   trendi, haber şeridinin seyrekleşmesi) bir haftadan kısa süre tek tike iner. Alternatif, saat çözünürlüklü süre,
   ayrı karardır.
4. **Hafta içinde doğan lead ek hafta almıyor.** Sahip kararı ona bir hafta fazla ömür veriyordu; kod amacı sırayla
   karşılar: dolum temsilci masasından sonra süpürülür, lead ertesi tikin masasına ulaşır ama oyuncu onu yalnız
   doğduğu haftanın kalan saatlerinde görür (§4.5). Karar: sıra mı kalır, ek hafta mı gelir?
