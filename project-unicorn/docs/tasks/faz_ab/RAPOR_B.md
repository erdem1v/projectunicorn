# RAPOR B · Olaylar
Faz B bitti. Bütün kod `main`'de commit'li, push yok. Görev: `PRD_FAZ_B_OLAYLAR.md`. Çalışma dosyaları
`docs/tasks/faz_ab/b_taslak/` altında; bu klasör izlenmiyor. Adım defteri `b_taslak/R_DEFTER.md`, ölçüm raporu
`b_taslak/B6m_OLCUM.md`.

Erdem 2026-10-17 00:10'da "yazım dalgalarının hepsini şimdilik onaylı say, bütün işleri bitir, sabaha commit'lenmiş
olsun" dedi. Bu yüzden W1, W2 ve W3 metinleri onaylı gibi bayt bayt bağlandı. Hepsi commit mesajlarında **"TR/EN onay
bekliyor"** diye işaretli. Sabitler de **onay bekliyor** (§3). Tek istisna kesinti kademe çarpanıdır: yerel 1,0, bulut
0,5, kurumsal 0,25. Bunu Erdem onayladı. §1 "önce bakılacaklar"dır: cevabı oyunu değiştiren sorular.

**Erdem'in cevabı (2026-10-18).** Faz B'nin işi onaylı; metinlere göz attı, metinler onaylı. Soru 29 (gelmeyen
kâğıtlar için tanı turu): açılmayacak. Soru 12: cevap gelince ekip karta döner. Düzeltildi: `_clear_decision`
haftanın atamasını baştan yapar (`_staff_week(false)`), `crunch_finishes` aynı kuralı oynar, smoke
`sprint_decision_blocks_progress` üç kolla. Commit'lenip push edildi (§5).

---

## 1. Önce bakılacaklar (cevabın oyunu değiştirdiği sorular)
1. **A'nın hedefi olaylar açıkken tutmuyor (§4.11 ❌).** A'nın 16 koşusu (iki pazar × dört kol × tohum 7 ve 11, 104
   hafta) olaylar açıkken yeniden koşuldu. Aynı kollar bir de "Sprinti durdur" hiç seçilmeden koşuldu (`_free`). 40
   hedeften 6'sı tutmuyor; A'nın kendi tabanında 4'tü.
   - `fix_due` B2C erken düzeltme payı %50 → **%75** (hedef ≤ %30).
   - `fix_due` B2C erken hata sprinti %26 → **%52** (≤ %15); üst üste iki hata sprinti %10 → **%32** (≤ %1).
   - B2B'de yeni iki MISS: `fix_due` erken hata sprinti %8,7 → **%19** (≤ %15); üst üste iki hata sprinti %0 → **%10,5**
     (≤ %1).
   - `fix_worst` B2C erken payı A'daki gibi %50.
   - `_free` aynı sayıları verdi, yani sebep "Sprinti durdur" seçimi değil. Farkı A'dan bu yana hangi değişikliğin
     yarattığı ölçülmedi.
   - Örneklem küçük: iki tohum, erken dönem 19–21 sprint.
   - Churn hedeflerinin sekizi de tuttu. Sayılar PRD gereği sana geliyor; sabit oynatılmadı.
2. **A'nın tablo betiğinde hata var; RAPOR_A'nın bir satırı yanlış.** `fix_tables.py` `bug_sprint=true`'yu `"True"`
   ile karşılaştırıyor, Godot küçük harf yazıyor. Hata sprinti ve "üst üste iki hata sprinti" satırları her koşuda 0
   çıkıyordu. RAPOR_A §4'teki "Hata sprinti oranı / üst üste iki: 0 / 0" boş bir okumadır. Düzeltilmiş okumayla A'nın
   tabanı 2 değil 4 MISS'tir: `fix_due` B2C erken hata sprinti %26, üst üste iki %9,5. Düzeltilmiş kopya:
   `scratchpad/b6m/fix_tables_fixed.py`. Betik izlenmeyen klasörde olduğu için A'nınki düzeltilmedi.
3. **Yazılan içeriğin yarısından fazlası gerçek koşuda hiç gelmiyor (§4.12 ⚠️).** 20 bot koşusunda (A'nın kolları,
   tohum 1–10, 104 hafta) 46 kâğıdın 27'si hiç gelmedi:
   - tasarımcı kâğıtlarının 8/8'i;
   - PM kâğıtlarının 6/7'si;
   - testçi kâğıtlarının 6/9'u;
   - `sprint_late` ve `sprint_late_solo`.

   Gelenler: yazılımcı 99, kurucu 34, testçi 5, PM 1, tasarımcı 0. B2C botunun kadrosunda tasarımcı var, yine de hiç
   tasarımcı kâğıdı gelmedi. Sprint probunda tasarımcı kâğıdı geliyor; yol çalışıyor, bot koşusunda tetikleyen durum
   oluşmuyor. Nedeni ölçülmedi.

   Acil durum ve söz tarafında:
   - `regression` 0 (Soru 4'ün beklenen sonucu);
   - `promise_due` 0: B2B botu koşu başına yaklaşık 42 söz veriyor, hiçbiri son haftada yetişmeyen karta düşmedi;
   - `review_storm` 1, `month_close` 2.
4. **Kâğıt beklenenden çok daha seyrek.** 1.506 sprintin 147'sinde kâğıt geldi (%9,8). Yapılandırılmış ihtimal 2
   haftalık sprintte 0,5. Sprintlerin 956'sı kartlar erken bitince 1 tikte kapandı. Kâğıt zarı ilk haftanın sonunda
   atıldığı için bu sprintlere hiç kâğıt gelmedi. 2 tikte kapanan sprintlerde oran %27,7. "Sprintlerin en az üçte biri
   kâğıtsız" hedefi rahat tutuyor (%90,2). Asıl soru bunun tersi: koşu başına ortalama 7 kâğıt az mı?
5. **B2C ekonomisi A'nın gerisinde.** Sekiz B2C koşusunun yedisinde son MRR A'dan %9–31 geride.
   - `fix_none` tohum 7: %77 geride (kitle 56.239 → 13.136).
   - B2B A'nın yakınında: çoğunlukla ±%8, `fix_worst` tohum 11 −%24.
   - Kaynak araştırılmadı.
6. **Olay sayısı alt sınırın altında kalabiliyor (§4.1 ⚠️).** 20 koşuda 84 acil durum oldu: koşu başına 1–7, medyan
   4,5. Önerilen "koşu başına 4–14" hedefi 13/20 koşuda tuttu; 7 koşu altta kaldı (1, 1, 2, 2, 3, 3, 3). Smoke ölçütü
   tutuyor: en küçük aralık 4 hafta, 4–6 dışı aralık payı %75.
7. **Kâğıt kartı bekletir, kart o haftayı kaybeder** (Soru 12). Cevap hemen gelse de ekip karta dönmüyor.
8. **Ödeme olayının çipi gövdeyle çelişiyor** (Soru 3). **Küçük memnuniyet izleri çipte görünmüyor ya da artış gibi
   okunuyor** (Soru 2).

Tam soru listesi §7'de.

---

## 2. Kabul ölçütleri (§4)
| # | Ölçüt | Durum | Kanıt |
|---|---|---|---|
| 4.1 | Olay aralığı | ⚠️ | Smoke ✅: `incident_gap_and_spread` 300 hafta. Yerel kademe 46 olay, en küçük aralık 4, 4–6 dışı %40; bulut ve kurumsal da geçti. Rapor (B6m §2): 20 koşu, 84 olay, koşu başına 1–7, en küçük aralık 4, 4–6 dışı %75. Önerilen 4–14 hedefi 13/20 koşuda tuttu |
| 4.2 | Bedel | ✅ | `event_amount_seam`, `event_trust_delta_lasting`, `event_morale_payers` (B2). `incident_scale` (B3): kredi %10/%15/%25, kasa yalnız kredi kadar azalır, `mrr` değişmez, B2C kaybı süreyle orantılı. `incident_checkout_fix_card`, `incident_defer_ends_with_line` (B4). `paper_card_trim`, `paper_card_effects`, `paper_trust_until_ships` (B6). ⚠️ W1'in ödeme çipi bağlanmadı, yerine "Kitle −N" çıkıyor (Soru 3) |
| 4.3 | Gece | ✅ | `incident_night_hold_resumes`: 00:00'da istek yok; kart ilk tam saatte açılır; süresi dolmak üzere kâğıt varken de açılan kart acil durum kartıdır; karardan sonra 08:00'e kadar kart açılmaz. Üç mutasyonla düşürüldü. Ay sonu kartı 23:00'te açılır (`incident_month_close_window`) |
| 4.4 | 00:00 mailleri | ✅ | `inbox_no_night_stamp`: 104 hafta, iki pencere (08–17, 11–24); falsification ile 754 damga pencere dışı çıkar. `mail_pending_survives_save`, şema 17. `--inbox-shot` gece sonrası sabah kareleri TR ve EN. Yeni üreticiler aynı vakadan geçti (B3, B5, B7, B8). ⚠️ Kenar durum: `EvEngine._unannounced` kayda girmez |
| 4.5 | Kâğıt sıklığı | ⚠️ | Hedefler tutuyor (B6m §5): 1.506 sprintte birden çok kâğıt olan sprint yok; kâğıtsız %90,2, 2 tikte kapananlarda %72,3; aynı kâğıt en çok 2 kez, iki geliş arası ≥ 53 hafta; adsız uyuşmazlık 0. Birden çok kesintili 16 sprintin hepsi izinli bileşim (kâğıt + kesinti ya da ödeme). Uyarılar: probun `team=3`'ünde testçi yok (kurucu, yazılımcı, tasarımcı); PRD'nin tam spec'i tohum başına 3–5 sprint oynuyor, 104 haftayı ölçmüyor; söz bileşimi sınanmadı (`promise_due` gelmedi); gerçek kâğıt oranı %9,8 (§1 madde 4) |
| 4.6 | Konuşan ve bedeli ödeyen | ⚠️ | `paper_speaker_is_assignee` (üç falsification); `event_morale_payers`: yalnız Destek'teki kişi ödemez, atama değişince adlar değişir. ⚠️ Ödeyen küme 2'de tasarımcı ve PM de var (Soru 1). A'nın ataması PM'e kart veriyor (Soru 13) |
| 4.7 | Tahmin ile sonuç | ✅ | Prob adsız uyuşmazlık 0. Prob düzeltmesi ve `889b9b8`'den sonra: düz prob 2 ve 1 haftalık, `incident=` ile beş tür, `promise=1`, B2C. "Sprinti durdur" probta koşuldu (`storm@13`, `checkout@17`, `month_close@12` REPRED ile). ⚠️ "Testi kısalt" probta hiç açılmadı (bot fazla mesaiyi seçti); kanıt yalnız smoke `promise_cut_test_escape`. Koşular PRD'nin `team=3`'ü yerine `team=4` ile |
| 4.8 | Yatırımcı hazırlığı | ✅ | `cb5f51c`. Kod, metin, kayıt ve smoke'ta iz yok (yalnız yükte düşürme satırı ve onun vakası). `MEETING_CHIP_PREP` satışta çalışıyor. `full_run_vc_cautious` `series_a_close` ile bitiyor. Ölçüm 10 tohum: hazırlıklı imza 10/10, hazırlıksız 9/10. Odaklanan soru `PREP_BONUS` ile 0,60 → 0,80, dürüst 0,30 → 0,50 |
| 4.9 | Kapılar | ✅ | Birleşik ağaçta: lint 0 hata; `loc_residue` temiz; her yeni kart `--why-fire`'dan geçti (istek kartları G4'te, beklenen); plausibility 40 koşu 0 fail, LONG 4 koşu 0 fail; `run_gate` 3/3, 0 `ERROR`. Ekonomi kayması §4'te |
| 4.10 | Görsel kabul | ⚠️ | Her yeni kart TR ve EN çekildi ve kareler tek tek açıldı. 40 kâğıt (B6v, 80 kare), dört acil durum kartı ve B2C bozulma varyantı, söz olayı, teşekkür notu, B2C yorum bölümü, gece kartı ve gelen kutusu saatleri. Hiçbir karede taşma, kesilme, yanlış dil ya da tire yok; loglarda parse hatası yok. ⚠️ 1: B6b'nin 21 kâğıdından 17'si kurulu bir sprint dünyasında çekilemedi. Kart koşulu canlı dünyada tutmadığı için kâğıt gelmedi; bu kartlar sprint dünyası olmadan (`--event-shot`) çekildi. Karelerde kart ya da hat adı boş, "Kitle 0", ham `{customer}` görünüyor. Oyunda kart yalnız slotları bağlanınca gelir; metin, dil ve taşma doğrulandı, çip sayıları doğrulanmadı. Çipler smoke'ta sınanıyor (`paper_cards_render`, `paper_card_effects`). Kurulu dünyada çekilenler 4/21: `dev_shorter_path`, `dev_contractor`, `untested_own_code`, `solo_license`. ⚠️ 2: `pm_two_accounts` ve üç B2C PM kâğıdı uykuda (Soru 14); çekim dünyası üç B2C PM kâğıdında `main.gd:920`'de SCRIPT ERROR veriyor (debug çekim kodu, oyun değil). Kareler `scratchpad/b6v/png/` |
| 4.11 | A'nın hedefi | ❌ | §1 madde 1 ve 2; B6m §3. Botun seçimi fiile göre: durdurma satırı olan kartlarda (ödeme, ay sonu, fırtına) `worst`, `due` ve `off` durdurdu, `fix_none` erteledi. `fix_none` B2C'de 5 kez durdurdu: ödeme kartında erteleme satırı servis çökükken kilitli, bot PRD'nin "kilitliyse ilk açık seçenek" kuralını uyguladı. Kesinti kartlarında durdurma satırı yok. `_free` kolları hiç durdurmadı |
| 4.12 | Her tür gelir | ⚠️ | §1 madde 3; B6m §4. Hiç gelmeyenler: `regression`, `promise_due`, `sprint_late`, tasarımcı kâğıtları; PM 1, testçi 5. Pazar dışı tür hiç gelmedi |

---

## 3. Onay bekleyenler
### 3.1 Sabitler
Hepsi kodda tek ayar yerinde ve `[WORKING]` işaretli. Kart içindeki sayılar kartın JSON'unda durur.

**Mail saatleri (B1, `MailClock`):**
- `SPREAD_HOURS` 4: geliş saati mesai penceresinin ilk 4 saatinden çekilir.
- `SHORT_LIVED_SPREAD_HOURS` 1: bir haftalık kâğıt pencerenin ilk saatinde gelir.

**Çip (B2):** `EvChips.NAMES_SHOWN` 4. Dört kişiyi geçen listede ilk iki ad yazılır, sonra "ve {n} kişi".

**Acil durum (`sprint.json` `incident`, B3 ve B4):**
- Taban ve sınırlar: `base` 0,10; `bug_cap` 12; `bug_div` 8; `p_max` 0,30. Onaylı kademelerle tavan bugün hiç
  bağlamıyor, en yüksek ihtimal 0,25. `min_gap` 4 hafta (kural Erdem'in). `launch_quiet` 3 hafta. `load_mult` 1 (C'ye
  kadar).
- Tür ağırlıkları: kesinti 1,0, ay sonu 1,5, ödeme 1,0, fırtına 1,5.
- Düzeltme süresi: kesinti 3, ay sonu 3, ödeme 2, bozulma 4, fırtına 3 saat; `crew_base` 0,75, `crew_per_star`
  0,125, `founder_slower` 1,5, adım 10 dk.
- Gece kesintisi: başlangıç 00:30–04:30, 10 dakikalık adımla. B2C'de olay için en az 1000 kişilik kitle gerekir. Gece
  vardiyalı sektörler lojistik, üretim ve sağlık. Vardiyasız hesabın gün başı 08:30.
- Kesinti kredisi: kapalı kalma 0, 7 ve 12 saatte sırayla aylık ücretin %10, %15, %25'i.
- Memnuniyet izi: saat başı 0,6, tavan 8. Kredi izin %85'ini siler.
- B2C kesintisi: deneme payı saatte %1,5, kayıp saatte %0,3, tavan %4. Ücretsiz ayda kayıp yarıya iner.
- Ay sonu: hatta 3 açık hata; damga 22:10–22:55; kart 23:00; hatlar fatura, defter, nakit akışı.
- Ödeme: başlangıç −120…240 dk; kart başlangıçtan 10–50 dk sonra; deneme payı saatte 0,0022; vazgeçme 0,25.
- Bozulma: B2B'de 7, B2C'de 4 kritik hat; kart mesai başından 10–50 dk sonra.
- Fırtına: hatta 7 açık hata; en az 2000 kişilik kitle; damga 11:00–16:00; pay 0,025.
- Erteleme: B2B'de hesaba hemen −6, düzelene kadar her sprint kapanışında −3; B2C'de kitle haftada %2, ücretsiz ayda
  %1.
- Kart sayıları:
  - gece düzeltmesinin morali −10;
  - ay sonu, bozulma ve fırtınada moral −7, ödemede −10;
  - "Kendin düzelt" verim −%15 · 1 hafta (kadro ≤ 2 iken açık);
  - ay sonu "Sabah düzelt" hesaba −3.
- **Onaylı (listeye girmez):** `tier` yerel 1,0 · bulut 0,5 · kurumsal 0,25. Kademe tavandan sonra çarpılır.

**Söz olayı (B7):**
- `promise.cut_test_escape` 0,15. Kısaltılmış testin hatalı çıkma ihtimali; D gelince onun kuralına bağlanır.
- Fazla mesainin morali −5, çarpanı 1,25 (`CRUNCH_MULT` ile aynı).
- Ek sürenin izi −6, söz başına bir kez.

**Sürüm anı (B8, `sprint.json` `thanks` / `reviews`):**
- Teşekkür notu: sürümde en çok 3, hesap başına 1.
- Hızlı kapanış sayılan cevaplar: şimdi, kurucu, akşam. Sınır hesabın gün başıdır.
- Yorumlar:
  - olumsuz yorum eşiği hatta 5 açık hata;
  - sürümde en az 2, en çok 3 yorum, en çok 1 olumsuz;
  - aynı yorum 52 hafta dönmez;
  - adlı yorum payı 0,7.
- Teşekkürün etkisi yok, yalnız mail.

**Kâğıt motoru (B5, `sprint.json` `decision`):**
- `sprint_chance`: 1 haftalık sprintte 0,3, 2 haftalıkta 0,5.
- `seen_weight` 2. Görülmüş kâğıdın ağırlığı 1 / (1 + 2 × görülme).
- Mandal: 52 hafta ve koşuda en çok 3. `sprint_late` için 26 hafta ve en çok 3.

**Kâğıt içeriği (B6a ve B6b, `sprint.json` `paper`):**
- Kartın işini sonraki sprinte bırakmak (`trim_share`): kartın %40'ı, yukarı yuvarlanır.
- Yeniden açılan kartın eki `reopen_points` +1.
- Hesabı sessiz bekletmenin çarpanı `ask_silent_mult` ×5.
- Telefon kartı `phone_points` +2.
- Dışarıdan işin puanı `contract_per_point` $1.000.
- B2C kayıpları %0,5 ve %1.
- Yenileme indirimi %20: bir ay, bir kez, `retention` etiketiyle.
- İlk ekran kaybı haftalık yeni kullanıcının %10'u × 8 hafta.
- Kupon kaybı kitlenin %1'i.
- Test telefonu $1.200.
- Yavaş hesap 15 koltuk. Depo sektörleri lojistik, üretim, perakende.
- Renk kâğıdı: elle 2, merkezî 4, ikinci gelişte +1.
- Yeniden yazılmış hat 26 hafta.
- Kök neden en az 3 hata.
- Kayıt kodu kaybı haftalık yeni kullanıcının 0,3'ü.
- Dış testçi haftası ×1,5 (örnek $1.400).
- Lisans: koltuk başı 6, kullanıcı başı 0,3, en az $1.200.
- Yenileme penceresi ayrı sabit değil: `request.before_renewal_weeks` 12.
- Kart içi sayılar `R_DEFTER.md` B6a ve B6b bölümlerinde tek tek listeli:
  - hesap izi −8 ve "kart çıkana kadar" −6 / −3;
  - verim −%10 … −%40;
  - moral +4 … −10;
  - efor ±1 … 3.

### 3.2 Kurallar
1. **Kesinti sırası (Karar 12).** Söz olayı ya da acil durum gelen sprintte kâğıt gelmez. Saatini bekleyen bir bozulma
   da kâğıdı kapatır. Kâğıtlı sprintte yalnız servisin çöktüğü acil durum gelir (gece kesintisi, ödeme). Öbür tür bir
   sprint sonra bütün hâliyle gelir. Kayan ay sonu takvim ayının sonuna denk gelmeyebilir.
2. **Gece kapısı (R soru 10).** Gece yalnız acil durum kartı açılır. Kepenk kartı ve kâğıdın son uyarısı da mesai
   başına kadar bekler. Mesai bitiminde kuyrukta kalan kart da ertesi sabaha kalır.
3. **Gece düzeltmesini kim öder (R soru 1).** PRD'nin harfiyen okuması uygulandı: hattın kartlarındaki atananlar, yoksa
   kurucu dışında bütün ekip. Tasarımcı ve PM de öder.
4. **Ödeme olayının bedeli (R soru 3, öneri a).** "Ödeyen −7 · MRR −$56" yazılamadı. Kayıp kitleye ödeyen ÷ dönüşüm
   oranıyla çevrilir ve çip "Kitle −N" der.
5. **Yeniden yazılmış hat (B6b; W2'nin açık sorusu).** Hatta 26 hafta zarla gelen hata (saatlik bildirim ya da kapanışın
   hatalı çıkma zarı) düşmez. Oyuncunun seçtiği hata yine düşer (çıkış hatası, hemen düşen hata).
6. **`sprint_late` zarla gelir.** Bekleyen istek kartı her geride kalışta kâğıt almaz, havuzun öbür kâğıtlarıyla
   yarışır.
7. **Acil durum teşekkürü (B8).** Not olaydan sonraki ilk sürümün kapanışında gider. W3 "sonraki mesai penceresi"
   diyordu. Sayaç sürüm başına olduğu için böyle oldu.
8. **Uzatılmış söz tutulunca ödülün tamamı verilir** (W3'ün sorusu: tam mı, yarım mı).
9. **Yatırımcı hazırlığı için telafi yok** (Karar 18).
10. **Pazara özgü seçenek.** Dört kâğıdın B2C ikizi ayrı kart oldu, çünkü seçenek pazara göre gizlenemiyor. 21 kâğıt
    havuzda 25 kimliktir.
11. **B6b'nin W2'den sadeleştirmeleri:**
    - `solo_watch` her aşamada gelebilir.
    - `unasked_rewrite`'ı kartın ilk ≥12 haftalık yazılımcısı söyler.
    - `founder_test_pile`'daki "bir haftadır", testin hiç başlamamış olmasıdır.
    - `untested_own_code`'da "Testi sen yap" için izin kilidi yok.
    - "İlk sürüm" v1.0 ve öncesidir.
12. **B6a'nın yaklaştırmaları:**
    - depo sektörü kuralı;
    - `sprint_dev`: sprint payı en büyük yazılımcı;
    - `drawings_late` koşulu;
    - `dev_helps` ilerlemesi;
    - kupon yalnız Entegrasyonlar hattında ve ücretli plan açıkken.

### 3.3 Metinler (TR/EN onay bekliyor)
- **Dalgalardan bayt bayt bağlananlar:**
  - W1: altı acil durum kartı, gece kartı ve çipler (B2, B3, B4);
  - W2: 40 kâğıt ve çip şablonları (B6a, B6b);
  - W3: söz olayı, 14 teşekkür gövdesi, 28 yorum, kaynak etiketleri (B7, B8).
  - Eşlik kapısı her bağlama adımında `missing=0` verdi. B4'te bilerek bağlanmayan 8 varyant: bozulmanın B2B Veri
    Girişi ve Mobil varyantları; kritik hat olmadıkları için kart hiç sormaz.
- **Dalgada olmayan yeni metinler:**

| Anahtar | TR | EN | Adım |
|---|---|---|---|
| `EFFECT_NAMES_MORE` | ve {n} kişi | and {n} more | B2 |
| `MAIL_SENDER_SERVER_ALERT` | Sunucu uyarısı | Server alert | B3 |
| `FIN_ONETIME_OUTAGE_CREDIT` | Kesinti kredisi | Outage credit | B3 |
| `EFFECT_OUTAGE_CREDIT_ONE` | Kesinti kredisi · {n} hesap · %{pct} {v} | Outage credit · {n} account · {pct}% {v} | B3 |
| `MAIL_SENDER_FINANCE_MANAGER` | Finans Müdürü | Finance Manager | B4 |
| `EFFECT_TEST_CUT` | {card}: test işi yarıya iner | {card}: testing cut in half | B7 (Erdem D2: yüzde yazılmaz) |
| `PRODUCT_REVIEW_QUOTED` | "{review}" | "{review}" | B8 (düz tırnak; tipografik isteniyorsa karar Erdem'in) |
| `EFFECT_SPRINT_HOURS_SOLO` | Bu sprint çalışma saatin ×{v} | Your work hours ×{v} this sprint | B6b |
| `*_ONE` tekil biçimleri | TR aynı | EN tekil | B6a, B6b (`NEXT_SPRINT_WORK`, `SHIP_BUGS`, `CARD_POINTS`, `WORK_LOST`, `NEW_BUGS`) |

- **Kalkan metinler:**
  - eski `product.outage` kartı (`EV_PRODUCT_OUTAGE_*`, 6 anahtar);
  - hazırlığın 13 anahtarı;
  - eski renk kâğıtları (8 anahtar);
  - "İki yol var", "Dışarıdan destek", "Arayüz baştan yazılmış" ve üç takip kâğıdının anahtarları;
  - `EFFECT_SPRINT_EFFORT`, `EFFECT_SPRINT_PROGRESS`.

---

## 4. Ölçüm (B6m: §4.1, §4.5, §4.11, §4.12)
Tam rapor ve bütün tablolar: `b_taslak/B6m_OLCUM.md`. Loglar ve betikler: `scratchpad/b6m/`.

**Yöntem:**
- 56 headless koşu, aynı anda en çok bir Godot.
- 20 koşu A'nın iki preset'iyle, tohum 1–10 (§4.1, §4.5, §4.12).
- 16 koşu A'nın kollarıyla, olaylar açık; 12 koşu `_free` ikizleriyle (§4.11).
- 8 sprint probu.
- Kademe çarpanları onaylı değerlerle: 1,0 / 0,5 / 0,25.
- Koşuların bir kısmı `889b9b8`'den önce koştu (§9).

**§4.1:** tablo §1 madde 6'da. Koşuların hepsi 104. haftada bir sonla bitti, 0 `ERROR`.

**§4.11** (düzeltme payı medyanı, %; A / olaylar açık / `_free`):

| | B2B erken | B2B geç | B2C erken | B2C geç |
|---|---|---|---|---|
| `fix_worst` (erken ≤ 30, geç ≤ 15) | 8,2 / 12,5 / 12,5 | 4,8 / 5,0 / 5,0 | **50 / 50 / 50** | 10,2 / 10,6 / 11,0 |
| `fix_due` (erken ≤ 30, geç ≤ 20) | 0 / 3,7 / 3,7 | 4,9 / 6,3 / 6,3 | **50 / 75 / 75** | 10,6 / 14,3 / 14,1 |

**Churn** (toplam kayıp %, tohum 7 / 11):

| | `fix_none` | `fix_worst` | `fix_due` | `fix_off` |
|---|---|---|---|---|
| B2B, A → olaylar açık | 17,6 / 22,5 → 11,9 / 16,1 | 4,6 / 6,8 → 3,7 / 2,9 | 3,8 / 4,6 → 2,2 / 2,3 | 3,8 / 4,3 → 2,0 / 2,0 |
| B2C, A → olaylar açık | 18,8 / 21,1 → 31,8 / 21,2 | 7,7 / 8,0 → 7,6 / 8,3 | 3,9 / 4,2 → 5,4 / 5,1 | 0,6 / 0,8 → 0,7 / 1,0 |

**§4.12** (20 koşu, 104 hafta, kaç kez):

| Acil durum ve söz | B2B | B2C |
|---|---|---|
| Gece kesintisi | 42 | 24 |
| Ay sonu | 2 | pazar dışı |
| Ödeme | pazar dışı | 15 |
| Fırtına | pazar dışı | 1 |
| Bozulma | 0 | 0 |
| Söz olayı | 0 | pazar dışı |
| Teşekkür notu | 276 | pazar dışı |

| Kâğıt grubu | Gelen | Hiç gelmeyen kart |
|---|---|---|
| Yazılımcı | 91 | `multi_currency` |
| Tek kurucu | 34 | `license`, `signup_code` |
| Testçisiz | 16 | `founder_test_pile` |
| Testçi | 5 | 6/9 |
| PM | 1 | 6/7 |
| Tasarımcı | 0 | 8/8 |
| Sistem (`sprint_late`) | 0 | 2/2 |

**§4.5:** tablo §2 satır 4.5'te. Sprint başına kesinti bileşimi:

| Bileşim | Sprint |
|---|---|
| Kesinti yok | 1.291 |
| Yalnız kâğıt | 131 |
| Yalnız acil durum | 68 |
| Kâğıt + kesinti ya da ödeme (izinli) | 16 |
| Başka bileşim | 0 |

---

## 5. Commit listesi
| Commit | Adım | Ne |
|---|---|---|
| `05966f3` | B1 | Mail ve bildirim saatleri. Teslim kuralı, `MailClock`, şema 17 |
| `f4a623b` | B2 | Motor fiilleri. Tutar seam'den, kalıcı memnuniyet izi (`trust_delta` `per_sprint`/`until`), kişiye moral (`morale_crew`, `SprintSystem.payers`) |
| `7e168aa` | B3 | `IncidentSystem`, gece kapısı, gece kesintisi kartları (B2B, B2C) |
| `cb5f51c` | B9 | Yatırımcı hazırlığının kalkması |
| `ea3c20c` | B4, B5, B6a, B6b, B7, B8 | Kalan dört acil durum ve "Sprinti durdur"; kâğıt motoru; 40 kâğıt; söz olayı; sürüm anı. Tek commit, mesajda adım başına paragraf (§9) |
| `889b9b8` | B4 düzeltmesi | Son gece mesaiden sonra gelen acil durumda düzeltme kartı sonraki sprinte geçerken haftanın ataması yeniden yapılır; plan ile kapanış eşleşir (§9) |
| `fc6b392` | B5 düzeltmesi (Erdem 2026-10-18) | Kâğıt cevaplanınca haftanın ataması baştan yapılır, ekip karta döner; `crunch_finishes` aynı kuralı oynar. Kapı: 26/26 vaka, 6 prob adsız uyuşmazlık 0, run_gate 3/3. Push edildi (`1faeb82..fc6b392`) |

---

## 6. Bağlantılar ve belgeler (§6)
Bağlantı haritası kod yazılmadan çıkarıldı (`b_taslak/B0_HARITA.md`) ve Opus kodla doğruladı (`B0v_ADIM_EKLERI.md`).
- **A'nın noktaları:** B, A'nın deposuna yalnız RAPOR_A §6–§7'deki adlı noktalardan dokunur:
  - `ProductState.add_bugs`, `open_bugs`, `line_bugs`, `costed`, `line_blocked`;
  - `SprintSystem.fix_first`, `plan_outcome`;
  - `SprintCatalog.line_impact`.
  - Kendi hata sayacı ya da hesap süzgeci yok.
  - Eksik nokta B0'da ⚠️ olarak çıkmadı.
  - Tek ek: `line_blocked` bugün ilk kez bir kural tarafından okunuyor (`mvp_line_harden`, B6b).

**Belgeler:**

| Belge | Durum | Nerede |
|---|---|---|
| `docs/HARITA.md` | ✅ | Her adım kendi satırını yazdı: Ürün (`IncidentSystem`, Karar kâğıdı ve kâğıt sözleşmesi, kâğıt içeriği, sürüm anı, söz olayı), smoke önekleri (`incident_`, `paper_`, `decision_`, `promise_`, `release_`), sprint-probe alanları (`market`, `incident`, `promise`, `PAPER`, `PAPERSUM`) |
| Motor md §27 | ✅ | §27.27 B1 · §27.28 B2 · §27.29 B3 · §27.30 B7 · §27.31 B8 · §27.32 B4 · §27.33 B5 · §27.34 B6b · §27.35 B6a. Numaralar commit sırasına göre değil, yazılış sırasına göre |
| `_vocabulary.md` | ✅ | `--event-vocab` son ağaçta koşuldu: 264 seam, 75 fiil, 148 kart. Fark yok |
| Sinyal manifesti | ✅ | `gen_signal_manifest.py` son ağaçta koşuldu: 145 sinyal. Fark yok |
| `GUNCELLEMELER.md` | ✅ | Her adımın girdisi var. B9'un girdisi ZAMAN MODELİ §4.7/§8.6'yı ve Ekip GDD'deki hazırlık maddesini geçersiz kılar |
| CLAUDE.md §5 ve §6 | ✅ | §5 gün sınırı (kart saat yazmaz, mesai penceresinde gelir). §6 "Teslim saati", "Acil durum", "Söz olayı", "Karar kâğıdı", "Sürüm anı" maddeleri. Kayıt şeması 17. §12 probe satırları (`PROBE STOP`, `*_free`, `PAPER`, `PAPERSUM`) |
| ZAMAN MODELİ | ✅ | Kesinti kartları satırı ve kâğıt havuzu satırı güncel |
| ⚠️ `ACIK_KARARLAR.md` | dokunulmadı | Madde 78 fiilen B yönünde kapandı (B1). Madde 77 ve ~1219 hazırlığın eski adlarını anıyor (B9). CLAUDE.md §3 açık maddelere dokunmayı yasaklıyor; karar Erdem'in |

---

## 7. Erdem'e sorular (tam liste)
§1'dekiler burada da var. Her sorunun yanında bugün uygulanan yol yazılı.

**Acil durum**
1. **Gece düzeltmesini kim öder?** PRD harfiyen uygulandı: tasarımcı ve PM de öder, kurucu ödemez. Yalnız yazılımcı ve
   testçi mi olsun? Bugün harfiyen.
2. **Küçük memnuniyet izleri görünmüyor.** İz haftada 2,8 affediliyor. Karar 8'in sprint başı −3'ü, kesintide öbür
   hesapların −2'si ve kredili −1 çipte "70 → 70" okunuyor. Çipin "to"su bir tik sonraki sayıdır: hedefin dışındaki
   hesapta kaymayı da içerir. Örnekler:
   - ek süre çipi "72 → 51";
   - ay sonu sabah yolu "72 → 73" (bedel olduğu hâlde artış).

   Seçenekler:
   - (a) sayılar C'de eşikle birlikte ölçülsün (öneri);
   - (b) süren bedel affedilmeyen ayrı bir izde dursun;
   - (c) küçük izler en az −6 olsun.

   Bugün (a), dokunulmadı.
3. **Ödeme olayının çipi.** Gövde "45 kişi ödeme yapamadı" derken çip "Kitle −76" diyor. Bugün kayıp kitleye
   çevriliyor (öneri a). İstenen "Ödeyen −N · MRR −$X" ise yalnız ödeyeni düşüren bir yol gerekir, bu da yeni mekanik.
4. **Sürüm sonrası bozulma nadir.** Hatalı sürüm yalnız "Testi kısalt", "Ana akışları test et" ve kâğıdın "bilinen
   hatayla çıkar" seçeneğinden doğar; test aşamasında çalışan herkes test biliyor. D'ye kadar böyle mi kalsın? §4.12
   sayısı §4'te.
5. **`P_MAX` 0,30.** Onaylı kademelerle tavan bugün bağlamıyor. Ancak C'nin yük çarpanıyla anlam kazanır. Soru
   neredeyse konusuz.
6. **Tür karışımı.** Ağırlıklar kesinti 1,0, ay sonu 1,5, ödeme 1,0, fırtına 1,5. Gerçek karışım §4'teki §4.12
   tablosunda. Böyle kalsın mı?
7. **Gece kapısı.** Kepenk kartı ve son uyarı da mesai başına kadar bekliyor. Kabul mü?
8. **Finans satırı adları.**
   - Yenileme indirimi var olan "Bağlılık primi / Retention bonus" satırına yazılıyor.
   - Sunucu faturası "Kesinti gideri"ne, test telefonu `user_tests`'e yazılıyor.
   - Yeni "İndirim" satırı istenir mi?
9. **B2C ücretsiz ay ucuz** (W1 notu). Ay sonu sabah yoluna −3 (W1). Kalsın mı?
10. **Ertelenen acil kartın kayan kart çipi** yalnız ilk kayan kartı adlandırıyor. Son gece gelen olayda adlandırılan
    kart sonraki sprintin kartı oluyor. Yeterli mi?
11. **Seam sayıları binlik ayraçsız** ("2480 kişi"). Motorun genel davranışı, B'den önce de vardı. `Fmt` ile biçimlensin
    mi? Metin işi; ayrı tur.

**Kâğıtlar**

12. **Kâğıt kartı bekletir ve kart o haftayı kaybeder.** Kâğıt gelince ekip haftanın kalanında başka kartlara geçer.
    Oyuncu kâğıdı hemen cevaplasa da kart o hafta ilerlemez. Örnek: `sprint_dev_contractor`'da "Serbest çalışan getir"
    nakit öder, kart yine 0 puan alır (sprint probu, §9). B'den önce de böyleydi, ama artık 40 kâğıt var. Cevap gelince
    ekip karta dönsün mü?
13. **PM sprintte kart alıyor** (R soru 9). A'nın ataması PM'i tasarım aşamasına koyuyor. Karar 10 "PM kart almaz"
    der. Kâğıt tarafı bunu atlatıyor: PM tasarımcı kâğıdını söylemez. Atama değişsin mi?
14. **"İki hesap aynı kartı istedi" ve üç B2C PM kâğıdı hiç gelmez.** Talep verisi C'de gelecek. Uykuda bağlandı. Kabul
    mü?
15. **Tasarımcı kâğıdı 2 haftalık sprintte nadir** (B5'in notu). Konuşan, kartın kâğıt sorulduğu andaki fazından
    seçiliyor. Sayı §4.12'de.
16. **`sprint_late` zarla gelir.** Bekleyen istek kartı her geride kalışta kâğıt almaz. Kabul mü?
17. **Yeniden yazılmış hatta hangi hata düşer?** Bugün zarla gelen düşmez, oyuncunun seçtiği düşer.

**Söz ve sürüm anı**

18. **Uzatılmış söz tutulunca ödülün tamamı mı, yarısı mı?** Bugün tamamı.
19. **Aynı sprintte iki kademe yetişmiyorsa** yalnız en büyük hesabın olayı gelir. Öbür söz kapanışta sessizce kırılır.
    Kabul mü?
20. **Acil durum teşekkürü** sonraki sürümün kapanışında gidiyor, ertesi mesaide değil. Kabul mü?
21. **Yorum tırnağı düz** (`"…"`). Tipografik tırnak istenir mi?
22. **B2C söz eşdeğeri** açık. `ISLER.md`'de; Erdem "üstüne düşünmek lazım" dedi.

**Mail saatleri ve diğer**

23. **Dönem özeti ve ilk Ar-Ge notu** artık teslim anında, öğleye yakın bir saatte gelen kutusunu kendiliğinden açıp saati
    durduruyor (B1, R9). İstenen bu mu?
24. **Sessiz notlar bazen hiç görünmüyor.** Notlar teslimde yeniden doğrulanıyor. Ölçüm: fire 457 → 421, boş zemin
    haftaları 252 → 291 (40 koşu). Kabul mü?
25. **Yatırımcı hazırlığı kalkınca** cautious bot 10 tohumda imzayı 10/10'dan 9/10'a indiriyor. Telafi yok. Kabul mü?
26. **Onay bekleyen sabitler ve yeni metinler** §3'te.
27. **"Sprinti durdur" ya da "Sabah düzelt" son gece mesaiden sonra gelirse** düzeltme kartı sonraki sprinte gider. Kart
    zaten sprintte koşuyorsa da gidiyor ve o sprintte yapılan işi hızdan düşüyor (§9). Sprintteki kart sprintte mi
    kalsın? Öneri: evet.
28. **Kâğıt sıklığı.** Gerçek koşuda sprintlerin %9,8'inde kâğıt geliyor; koşu başına ortalama 7 kâğıt. Sebep: zar ilk
    haftanın sonunda atılıyor ve sprintlerin çoğu 1 tikte kapanıyor. İstenen bu mu, yoksa zar sprint başında mı atılsın?
29. **Gelmeyen içerik** (§1 madde 3). Tasarımcı, PM ve testçi kâğıtlarının çoğu, `sprint_late` ve söz olayı 20 bot
    koşusunda hiç gelmedi. Bir tanı turu açılsın mı? Önce botun kadrosu ve sprint uzunluğu, sonra kâğıtların koşulları.
30. **§4.11'in altı hedefi** (§1 madde 1). Hedefler mi gevşesin, yoksa kaynağı mı aransın? Kaynak A'dan bu yana B1–B9
    arasında.

**A'ya giden not:** B8'in kod ajanı A'nın kodunda bir sorun buldu ve düzeltmedi (A'nın alanı).
`sprint_bridges.gd` `tick_requests`'teki `absi(hash(...)) % steps.size()`, aday sayısı 3 ya da 6 olunca hep aynı
kademeyi seçiyor.

---

## 8. Dalga dosyalarında bağlamada değişen belirteçler
Metnin kelimesi değişmedi. Yalnız belirteç adları değişti; dalga dosyaları izlenmeyen klasörde ve güncel:
- **W1:** `{seam:olay.customer_users}` 42 yerde `{seam:musteri.seats}` oldu (B3).
- **W2:** iki testçi kâğıdında (`sprint_test_readonly_delete`, `sprint_test_too_much`) seçenek etiketindeki
  `{employee}` `{dev}` oldu (B6a). Konuşan testçi `employee` slotunda kalıyor. Seçenekte adı geçen yazılımcı ayrı `dev`
  slotunda. Ekranda görünen metin aynı.
- **W3:** 9 belirteç `{seam:urun.release_feature}` → `{feature}` oldu (B8).

---

## 9. Süreç notları
- **Altı adım tek commit'te (`ea3c20c`).** Erdem paralel çalışmayı istedi ("bu fazın diğer tasklarını paralelde koştur").
  B4, B7, B8, sonra B5, B6a ve B6b aynı ağaçta paralel yazıldı. Ortak dosyalarda değişiklikler satır düzeyinde iç içe
  geçti:
  - B6a, B4'ün `fix_first_bumps`'ını `first_bumps`'a indirdi;
  - B6b, B7'nin `cut_promise_test`'ini `cut_test` yaptı;
  - B6b, B7'nin kapanış zarı satırına `line_blocked` ekledi.

  Ara adım ağaçları hiç var olmadığı için parçaya ayırmak koşulmamış kod uydurmak olurdu. Altı adım tek commit'e girdi.
  Mesajda her adımın kendi paragrafı var. Kabul satırları adım adım `R_DEFTER.md`'de.
- **Birleşik ağacın kapısı (ana oturum, commit öncesi):**
  - lint 0 hata, 148 kart; `loc_residue` temiz;
  - altı adımın ve B7'nin `promise_*` ailesinin 71 hedefli vakası: 71/71 PASS;
  - `run_gate` 3/3, 0 `ERROR`: `full_run` 104. hafta, `full_run_b2c` 104. hafta, `full_run_vc_cautious` 68. haftada
    `series_a_close`;
  - plausibility 40 koşu, 512 kart, 0 fail; LONG 4 koşu, 404 kart, 0 fail;
  - `--event-vocab` ve manifest fark üretmedi;
  - W2 eşliği B6a önekleri 258/0, B6b önekleri ve çipleri 242/0.
- **Sprint probunda harness düzeltmesi.** İlk koşuda iki prob 1 ile çıktı: 3 adsız uyuşmazlık, hepsi
  `sprint_dev_contractor`'ın "Serbest çalışan getir" cevabı. Kâğıt kartı bekletiyor ve ekip haftanın kalanında başka
  kartlara geçiyor (Soru 12). Seçenek kartı değiştirmediği için prob sebebi yazamıyordu. Düzeltme: prob, kâğıdın
  sorulduğu sprintin uyuşmazlıklarına kâğıdın adını verir (`sprint_probe.gd`).
  - Sonra iki prob exit 0: 78/86 ve 86/95.
  - B4'ün beş acil durum probu, `promise=1` ve B2C de exit 0.
- **Probun bulduğu gerçek hata (`889b9b8`).** `incident=month_close@12` koşusu bir adsız uyuşmazlıkla düştü: ay sonu
  kartı koşan sprintin son gecesi 23:00'te "Sabah düzelt" ile cevaplandı. Düzeltme kartı doğru olarak sonraki sprinte
  geçti, ama `SprintSystem.put_first` haftanın atamasını yalnız kart sprintte kalınca yeniden yapıyordu. Sprintten çıkan
  kartın kişisinin o haftaki puanı hiçbir karta yazılmadı. Ürün ekranındaki plan kapanıştan 0,70 puan fazla gösterdi.
  - Düzeltme: atama iki durumda da yeniden yapılır.
  - Falsification: eski kodla prob 1 ile çıkıyor, düzeltmeyle 0.
  - 8 prob ve 5 vaka temiz; Opus incelemesi yalnız yorumu düzeltti.
  - Ölçüm (B6m) bu sırada koşuyordu; koşularının bir kısmı düzeltmeden önceki kodla koştu. Düzeltme yalnız son haftanın
    gecesinde gelen acil kartın haftalık atamasını etkiler.
- **İncelemenin ve tanının bulduğu, düzeltilmeyen B4 davranışı.** Probun örneğinde ay sonunun düzeltme kartı zaten
  sprintteydi; kurucu üstündeydi ve kart o gece bitecekti. "Sabah düzelt", son gece mesaiden sonra geldiği için kartı
  sonraki sprinte itti.
  - Koşmakta olan kart sonraki sütuna geçince `state` "running" kalır.
  - Bu sprintte yapılan iş hızdan ve yapılan puandan düşer, çünkü kart ne sprintte ne `carried_out`'ta.
  - `decision_carry` aynı durumda kartı `carried_out`'a ekliyor, `put_first` eklemiyor.

  Kural "kart zaten sprintteyse sprintte kalır" olmalı mı? Soru 27. Tasarım sorusu olduğu için dokunulmadı.
- **Onaylı metin dosyasına dokunuş.** Üç dalgada belirteç adları değişti (§8). Metnin kelimesi değişmedi.
- **B9'un commit mesajı ilk hâlinde trailer'sızdı.** Yalnız mesaj amend edildi (`20b5e55` → `cb5f51c`).
- **Godot sınırı.** Bellek dar olduğu için makinede en çok iki Godot süreci kuralı vardı. B9 ajanı kısa süre üç süreçle
  koştuğunu kendisi bildirdi. Yetim kalan bir smoke süreci kendi zaman aşımıyla kapandı; süreç öldürülmedi.
- **Tam smoke koşulmadı** (PRD §8). Her adım kendi hedefli vakalarını koştu. Birleşik ağaçta bütün adımların vakaları
  bir kez daha koşuldu (yukarıda).
- **Push yok.** Sözün Erdem'de.
