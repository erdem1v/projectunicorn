<!--
  KAYNAK VE YÜRÜRLÜK
  ------------------
  Bu dosya `GDDs/GDD — OLAY MOTORU (EVENT ENGINE) rev 2.docx`'in birebir markdown
  çevirisidir ve motorun YÜRÜRLÜKTEKİ tek kaynağıdır. .docx ağaçtan kaldırıldı;
  yazıldığı hâli git geçmişinde durur (`6e3e190`).

  Neden taşındı: motor task'ı §2.2 uyarınca "koddan sapma çıkarsa GDD dosyasının
  KENDİSİ güncellenir" diyor. Ağaçta grep'lenebilen, diff'lenebilen ve inşa
  notlarını taşıyabilen bir dosya bunun tek pratik hâlidir. Aynı desen Ürün rev 6.1
  §24'te ("İNŞA NOTLARI — kod tarafından yazıldı") zaten kurulmuştur.

  Çeviri kaybı yok: 27 bölüm, 63 kenar-durum satırı, bütün tablolar ve şema
  listeleri korunmuştur. Şema listeleri .docx'te boşlukla hizalanmış düz metindi;
  burada kod bloğu olarak çitlenmiştir — okunuş aynı, biçim daha dürüst.

  İNŞA SIRASINDA GDD ÖNCÜDÜR. İNŞA BİTTİĞİNDE KOD ÖNCÜDÜR (Ürün §24'ün kuralı).
  Yapılanın belgeden ayrıldığı her yer §27'ye yazılır.
-->

# GDD — OLAY MOTORU (EVENT ENGINE) rev 2

**Proje:** Project Unicorn **Durum:** İNŞA SÜRÜMÜ — implementasyona hazır **Tarih:** 25 Ağustos 2026 **Kapsam:** Motorun tamamı. Mevcut `EventManager` emekliye ayrılır, yerine bu doküman inşa edilir. **Bağımlılıklar:** Ekip rev11 (mühürlü) · Ürün rev6.1 (mühürlü) · Ar-Ge rev1.4 (mühürlü) **rev1 → rev2 farkı:** §26'da

## 0. AMAÇ VE İLKELER

### 0.1 Motorun tek cümlelik tanımı

Motor bir gösterici değildir. **Kabul + hafıza + yüklem katmanıdır.** Sekiz modülün ortak konuşma dilidir. İçerik sistemlere asla doğrudan dokunmaz; yalnızca motorun sözlüğünden konuşur.

### 0.2 Motorun hizmet ettiği oyun tezi

- 2. haftada verilen bir kararın 13. haftada görünür bir sonucu olmalı, ve oyuncu bu bağı **kendisi kurabilmeli**.

Bir tik bir oyun günüdür, bir oyun günü bir haftadır (§1). Tezin gün modelindeki hâli "10. gün 90. günü etkiler" idi; haftalık modelde aynı mesafe 2. haftadan 13. haftayadır.

Bu tez motorun her tasarım kararını yönetir. Bir özellik bu teze hizmet etmiyorsa motorda yeri yoktur; bu teze zarar veriyorsa reddedilir.

### 0.3 Yedi motor invariant'ı

Bunlar tasarım tavsiyesi değil, **derleme kuralıdır**. İhlali build'i durdurur.

| # | Invariant | Zorlanma yeri |
|---|---|---|
| I1 | Tek kabul kapısı. Bir kartın gösterilmesinin başka yolu yoktur. | Mimari + lint |
| I2 | Ekonomik delta yalnızca oynanmış bir karardan doğar. | Lint (§17.3) |
| I3 | Telgrafsız kayıp yoktur. | Lint + runtime assert (§17.4) |
| I4 | Hiçbir kart düşürülmez; yalnızca sunum sınıfı düşer. | Mimari (§13.2) |
| I5 | Tetikleyici asla GDScript'e taşınmaz. Kart dosyası ne zaman ateşlendiği konusunda daima doğruyu söyler. | Lint (§17.1) |
| I6 | Zar öldürmez. Hiçbir olasılık dalı terminal olamaz. | Lint (§17.5) |
| I7 | Her modifier satırının arkasında isimli bir seam vardır. Seam yoksa modifier yoktur. | Lint (§17.11) |

### 0.4 Kapsam dışı

- **Pazarlık mantığı.** Motor pazarlık sahnesini açar, içini bilmez (§9.4).
- **Faz geçişi ve son koşulları.** Motor onları taşır, tanımlamaz. Faz kapısını PhaseGateSystem sınar; sonlar tasarlandığında bağlama işi o modülün task'ına yazılır (§23 A1).
- **Metin kalitesi.** Motor iki dilli metin bloğunu taşır; içeriğin sesi yazım turunun işidir.
- **Ekonomi formülleri.** Motor seam'lerden okur, formül yazmaz.
- **Tutorial akışı.** Motor bir suppression kancası taşır (§11.6), akışı tasarlamaz.

## 1. TERİMLER

| Terim | Anlam |
|---|---|
| Kart (event) | Atomik içerik birimi. Bir id, bir koşul, bir gövde, seçenekler, etkiler. |
| Ark (arc) | Kalıcı, bağımsız yaşayan çok adımlı yapı. Kendi değişkenlerini tutar, öznesi olabilir. |
| Kapı (gate) | Kabul hattı. Bir kartın gösterilebilir hale gelmesinin tek yolu. |
| Seam | Bir sistemin dışarıya açtığı isimli, salt-okunur sorgu. |
| Latch | Tekrar freni (one_shot / cooldown / max_fires). Motorda yaşar. |
| Kağıt | ODA masasındaki ertelenebilir karar yüzeyi. |
| Sınıf | Kartın sunum yüzeyi: kesinti / kağıt / bilgi / atmosfer. |
| Havuz | critical etiketi taşımayan kartların kümesi. |
| Sessiz havuz | Ölü zaman tabanının çektiği özel alt küme (tag: quiet). |
| Tik (oyun günü) | Motorun zaman birimi. Bir oyun günü bir haftadır; hafta sonu yoktur. Her tik 24 saatlik tik ve bir günlük tik taşır. Adında `day` geçen alanlar tik sayar (§27.9). |
| Damga (stamp) | Kalıcı tik işareti. weeks_since_flag bunun üzerinden çalışır. |
| Kapsam slotu | Kartın ihtiyaç duyduğu isimli varlık yuvası (employee_a, customer_main). |
| DELTA | Bir içerik yazım partisinin motordan talep ettiği yeni kalemler listesi (§21). |

## 2. NESNE MODELİ

Motor dokuz parçadan oluşur. Her parçanın tek bir sorumluluğu vardır.

| Parça | Sorumluluk | Kalıcı mı |
|---|---|---|
| EventCatalog | Tüm kart tanımları. Salt okunur, oyun başında yüklenir. | Hayır (içerik) |
| ArcCatalog | Tüm ark tanımları. Salt okunur. | Hayır (içerik) |
| Gate | Kabul hattı. Tek public giriş. | Hayır (stateless) |
| Queue | Kabul edilmiş, henüz gösterilmemiş kartlar. Dondurulmuş bağlamla. | Evet |
| History | Her çözümün kaydı + içeriğin okuyabildiği sorgu arayüzü. | Evet |
| FlagStore | Bayraklar, süreli bayraklar, tik damgaları. | Evet |
| Schedule | Bekleyen zamanlanmış kartlar. Saf data. | Evet |
| ArcRuntime | Aktif arkların durumu. | Evet |
| Presenter | Kartı hangi yüzeye koyacağına karar veren katman. | Kısmen (masa durumu) |

Ek olarak üç kayıt (registry) ve bir besleme kanalı:

- **SeamRegistry** — sistemlerin açtığı isimli sorgular (§6).
- **SignalManifest** — hangi sistem neyi yayar, kim dinler (§15). Statik.
- **EffectExecutor** — etki sözlüğünü yürüten tek yer (§8).
- **TickerFeed** — atmosfer ve teyit kanalı (§18). Motor besler, sahiplenmez.

### 2.1 Ark neden ayrı nesne

Kartların birbirini id ile çağırması uzun zincirlerde kırılır: bir halka koparsa geri kalanı yetim kalır ve kimse bilmez. Ark, zincirin **sahibi**dir. Kart ölür, ark yaşar. Öznesi giderse ark bunu bilir ve bir politika uygular (§10.5). Bu, §0.2'deki tezin taşıyıcısıdır.

## 3. KART ŞEMASI

Kart iki bloğa ayrılır. **Motor yalnızca mantık bloğunu görür.**

### 3.1 Mantık bloğu (dilsiz)

```
id                  zorunlu, benzersiz, namespace'li: kategori.isim
                    örn: hr.rakip_teklifi, funding.seed_kapisi
category            zorunlu. §13.3 Katman 3'teki kategori listesinden.
tick                zorunlu: daily | hourly | scheduled | signal | request
                    daily: tikin 00:00 devrinde süpürülür (gece
                    atlamasının içinde); kart 08:00'de, haftanın
                    başında görünür
                    hourly: her oyun saatinde süpürülür; gece
                    saatlerinde yalnız critical kart kabul edilir
                    request: hiçbir saat süpürmez; kartı yalnız adını
                    tek kapıdan veren bir sistem önerir (§4.1)
class               zorunlu: interrupt | paper | info | ambient
sender              opsiyonel: frank | self | employee | contact |
                    investor | press | desk. Gelen kutusundaki
                    gönderenin türü; yoksa kapsamdan ve kategoriden
                    türetilir (§27.14)
tags                opsiyonel: [critical, quiet, promise, terminal_warning,
                                tutorial, ...]
version_scope       opsiyonel: demo | ea | full   (varsayılan: demo)
                    G2 süzer (§4.1). fixture yalnız testtir, hiçbir
                    build'de gönderilmez

trigger             ne zaman aday olur (§5)
condition           koşul ağacı (§5)
scope               isimli kapsam slotları ve tipleri (§4.3)
guards              bağlam kısıtları: market, faz, alt-tip, portföy
allowed_hours       opsiyonel; tanımsızsa 08:00-20:00 (§20 B10). Gece
                    (mesai bitiminden 08:00'e) critical olmayan saatlik
                    kart için her zaman kapalıdır

latch               one_shot | max_fires:N | cooldown_weeks:N
                    varsayılan: cooldown_weeks: 4
latch_key           run | entity        (varsayılan: run)
min_gap_weeks       havuz freni, varsayılan 4 (§13.3 Katman 1)
weight              havuz ağırlığı, varsayılan 1.0

expires_weeks       her interrupt ve paper kartında ZORUNLU (§17.7).
                    Kartın bekleyebileceği hafta; kart kağıt olarak
                    masaya düştüğünde okunur. §12.
on_expire           süre dolumunda çalışan etkiler. paper ise ZORUNLU.
expire_note         süre dolumunda ticker'a yazılan satırın ADI. Satır
                    metin bloğundadır (§3.2). ZORUNLU.

options[]           seçenek listesi (§3.3)
arc                 opsiyonel: bu kart hangi arkın adımı
```

**Süreler haftadır.** Kart JSON'unda süre ya da sayaç taşıyan her alan hafta sayar (`cooldown_weeks`, `min_gap_weeks`, `expires_weeks`, `deadline_weeks`, `delay_weeks`). Gün adlı bir anahtar E-lint'tir (§17.1): okuyucular eski anahtarı görmeyince sessizce varsayılana düşerdi.

**Şema v3 — makullük bloğu.** `schema: 3` taşıyan kart mantık bloğuna aşağıdaki alanları ekler: kart hangi evrede, hangi kadroda, hangi kıdemde ve hangi ürün durumunda yaşadığını kendisi söyler. Motor bloğu yüklemede sıradan koşul yapraklarına derler (§27.20); yazar yalnız JSON yazar, kural tek yerde durur. Blok eksikse lint durdurur (§17.13).

| Alan | Tür | Zorunlu | Anlam ve derleme |
|---|---|---|---|
| `schema` | `3` | evet | Göç işareti. Yoksa P2, ve kartın öbür v3 kuralları hiç sorulmaz: v2 kartına v2'de olmayan alanı sormak olurdu |
| `system` | bool | hayır (`false`) | Kartın zamanını bir oyun sistemi verir (kapı, Frank, seed, sheet, kepenk, istifa, sistem istekleri). `critical` etiketini yalnız `system` ya da `terminal_warning` kart taşıyabilir (C1); ayrılmış fiili yalnız `system` kart kullanabilir (V2); `system` kart oyuncuya bedel borçlu değildir (O1, O2) ve kıdem süzgeci almaz |
| `plausibility.phase_band` | liste ⊂ {`bootstrap_solo`, `bootstrap_team`, `traction`, `series_a`} | evet, boş olamaz | `bootstrap_solo` = `phase.current == 1 ∧ hr.headcount == 0`; `bootstrap_team` = `phase.current == 1 ∧ hr.headcount >= 1`; `traction` = `phase.current == 2`; `series_a` = `phase.current == 3`. Koşul ağacına `any` olarak girer |
| `plausibility.headcount` | `[min, max]` (`max` `null` = sınırsız) | evet | `hr.headcount` aralığı (kurucu ve mentor hariç). Sıfır taban ve sınırsız tavan yaprak yazmaz: her karta hep doğru bir yaprak asmak `--why-fire`'ın raporunu gömerdi |
| `plausibility.subject_tenure_weeks` | int ≥ 0 | `system` olmayan kartta `select`li her employee/customer slotu varsa evet | Slotun `where`'ine `hr.tenure_weeks >=` ya da `musteri.tenure_weeks >=` yaprağı; değer kartın kendi sayısıyla ailesinin tabanının (`EvTuning.FAMILY_SUBJECT_TENURE`) büyüğüdür. Slot başına: `subject_tenure_by_slot: {rep: 4}`. Süzgeç seçiciye uygulanır, karta değil: kart kıdemli adayı BAĞLAR, herkesi bağlayıp kapıda reddetmez. `system` kartta derlenmez; verilen özne G5'te reddedilse istek kaybolurdu |
| `plausibility.fresh_reason` | string | `subject_tenure_weeks == 0` ise evet | Taze öznenin neden makul olduğu (ör. yenileme kartının onboarding sesi) |
| `plausibility.product` | `pre_launch` \| `live` \| `any` | evet | `urun.is_live` yaprağı; `any` yaprak yazmaz. `guards.product_live` varsa aynı değeri söylemek zorundadır (P1) |
| `plausibility.modules` | liste (`UiTokens.TABS` id'leri) | evet (boş olabilir) | Her biri bir `build.module_unlocked.<id> == true` yaprağı (§27.22) |
| `plausibility.min_week` | int ≥ 0 | evet | `time.week >= N`. Demo penceresinin (130 hafta) dışındaysa P3 |
| `family` | string | evet | Aile kimliği; Katman 1b ve 2b'nin freni (§13.3) |
| `family_subject` | `{"once": true}` \| `{"cooldown_weeks": N}` | hayır | Aynı aileden bir kart aynı özne için bir kez ya da N haftada bir |
| `follows` | kart id | hayır | Zincir düğümü: ebeveyn ya kartı `schedule_event` ile zamanlar ya da kartın koşulu ebeveynin `history` yaprağını okur (P1). Katman 1b'den muaf, 2b'den değil |
| `delay_weeks` | `[N, M]`, 0 ≤ N ≤ M ≤ 26 (lint aralığı denetlemez) | `system` değilse evet | Koşul ilk tuttuğu hafta pencere kurulur; kart `N..M` hafta sonra aday olur (§27.19) |
| `delay_reason` | string | `delay_weeks == [0,0]` ise evet | Neden anında geliyor (sinyal tepkisi, sprint haftası, dar pencere, zincir, sessiz taban) |
| `delay_mult` | `[{<koşul yaprağı>, "factor": f}]` | hayır | Kurulum anında tutan her yaprak beklemeyi `f` ile çarpar (ör. moral < 40 → 0,5) |
| seçenek `status_quo_reason` | string | etkisiz seçenekte evet | "Hiçbir şey değiştirme" seçeneğinin neden gerçek bir hamle olduğu (O1) |

`version_scope` ayrıca `retired` alır: kart hiçbir build'de gönderilmez (G2) ama katalogda kalır, eski kaydın geçmiş satırı ve mandalı çözülsün diye (§22.1). Derlenmiş yapraklar `"_from": "plausibility"` taşır; `--why-fire` ve lint onları yazılmış yapraklardan böyle ayırır.

### 3.2 Metin bloğu (locale başına)

text:

```
  tr:
    title, body     body: düz metin, anahtar ya da { by_seam, variants }
    options:        { <option_id>: label }
    locked_reasons: { <option_id>: metin }
    modifier_lines: { <seam_adı>: metin }        §9.6
    expire_note
    outcome_lines:  { <outcome_id>: metin }
  en:
    (aynı yapı, aynı id kümesi)
```

**Kural:** Motor hiçbir aşamada metne dokunmaz. Metin yalnızca Presenter'da, gösterim anında, `text[aktif_dil][id]` lookup'ı olarak çözülür. Kuyruk **asla render edilmiş metin saklamaz.** Dil koşu ortasında değişebilir; masadaki açık kağıt diğer dilde görünür ve hiçbir şey bozulmaz.

**Dil paritesi:** iki blokta **aynı** option id, outcome id, modifier anahtarı kümesi bulunmak zorundadır. Farklıysa E-lint (§17.8).

**Varyant gövde.** `body` bir sözlük olabilir: `{by_seam, variants}`. Varyant, seam'in tamsayı değerine göre seçilir: değere eşit ya da ondan küçük en büyük anahtar; her anahtar değerden büyükse en küçük anahtar. Yazılan aralığın dışına çıkan seam böylece boş kart vermez. Tamsayı olmayan varyant anahtarı E-lint'tir.

**Anahtar metin.** Çıplak büyük harfli bir değer (`VC_EV_DECISION_TITLE` gibi, `^[A-Z][A-Z0-9_]{2,}$`) `localization/strings.csv`'nin anahtarıdır: Presenter onu canlı dilde `TranslationServer` ile çözer, sonra yer tutucuları doldurur. Kural metnin çözüldüğü her yerde geçerlidir: `title`, `body` (her varyant dahil), `options`, `locked_reasons`, `expire_note` satırı ve ticker'a giden satırlar. Neden: taşınan içeriğin gözden geçirilmiş metni CSV'dedir; blokta kopyalamak bir metne iki ev verirdi.

**Metindeki yer tutucular.** `{slot}` bağlanan varlığın görünen adını, `{seam:ad.soyad}` bir seam'in değerini basar (§8.4'ün mekanizması).

**`expire_note`.** Kartın üst düzeyindeki `expire_note` (§3.1) bu bloktaki satırın adıdır. Süre dolumunda motor satırı canlı dilin bloğundan alır ve kartın slotlarıyla doldurur; blokta o ad yoksa değer satırın kendisi sayılır.

### 3.3 Seçenek şeması

```
id                  zorunlu, kart içinde benzersiz. Metinden bağımsız.
requires            opsiyonel koşul ağacı. Karşılanmazsa seçenek KİLİTLİ.
cost                opsiyonel: {cash, weeks, morale, ...}
effects[]           etki listesi (§8)
check               opsiyonel zar (§9.2)
outcome_id          history'ye ve outcome_lines'a yazılan sonuç anahtarı
```

**Kilitli seçenek asla gizlenmez.** Gri görünür, tıklanamaz, ve `locked_reasons` metnini gösterir. Koşul ağacının her yaprağı kendi "karşılanmadı" gerekçesini üretebilmek zorundadır (§5.4).

## 4. TEK KAPI

### 4.1 Hat

sinyal / tik / ark adımı / schedule / havuz / taban / request / force

```
        ↓
  EvGate.propose(event_id, origin, context)      ← TEK KABUL YOLU
        ↓
  ═══════════ KAPI ═══════════
   G1  içerik geçerli mi (id katalogda var mı)
   G2  sürüm kapsamı (version_scope, §3.1) + tutorial suppression (§11.6)
   G3  latch (one_shot / cooldown / max_fires), anahtar §3.1
   G4  tick uyumu ve pencere (faz, allowed_hours, build-safe)
   G5  kapsam çözümü (slotlar dolabiliyor mu, tipleri doğru mu)
   G6  guards (market, alt-tip, portföy, faz)
   G7  condition ağacı
   G8  tempo bütçesi (§13) — REDDETMEZ, SINIF DÜŞÜRÜR
        ↓
  admit → Queue (bağlam DONDURULMUŞ yazılır)
        ↓
  gösterim anında ═══ YENİDEN DOĞRULAMA ═══ (G5, G6, G7)
        ↓
  Presenter → sınıfa göre yüzey
        ↓
  oyuncu seçer
        ↓
  seçenek hâlâ karşılanabilir mi (cost + requires)
        ↓
  zar (varsa) → EffectExecutor → History → Ark ilerlet → Sinyal yay
```

**Sistemlerin tek public girişi** statik `EventGate.request(event_id: String, context: Dictionary = {})`'tir. Sistem kartın adını verir, kartı kurmaz. `context` §4.3'e göre çözülür: G5 verilen id'yi tip denetiminden geçirir. Verilen id bağlanamazsa (varlık gitmiş, tipi yanlış ya da başka slota bağlı) kart G5'te gerekçesiyle reddedilir; seçiciye düşülmez. İstek `Origin.REQUEST` kökeniyle kapıya girer. İstenen örneğin kağıdı masada bekliyorsa istek kapıya gitmeden o kağıdı açar (§11.4).

**`Origin.REQUEST` G4'ün tick eşleşmesini atlar;** hourly kartta `allowed_hours` ve build-safe denetimi yine uygulanır. `tick` kartı kimin süpürdüğünü söyler, adını kimin verebileceğini değil. `tick: request` kartını hiçbir saat süpürmez; `tick: daily` bir kartın adını da bir sistem verebilir.

**G2 — sürüm kapsamı.** Kartın `version_scope`'u bu build'in gönderdiği kapsamlar arasında değilse kart reddedilir. Kapsamlar tek, birikimli bir merdivenden okunur: demo → [demo], ea → [demo, ea], full → [demo, ea, full]; her build bir öncekine ekler. Merdivenin tek evi `EndingsSystem.SHIPPED_SCOPES_BY_BUILD`'dir, `EvTuning.SHIPPED_SCOPES` ondan kurulur. Build sabitlenince (smoke, probe) kart havuzu da sabitlenir; `fixture` kapsamını listeye yalnız smoke ve probe ekler.

### 4.2 enqueue() ve enqueue_front() silinir

Mevcut motorun iki kapısı vardı; ikincisi tüm suppression'ı atlıyordu ve history'ye yazmıyordu. Canlı 71 seçimin 40'ı yalnızca o yoldan geliyordu. Bu fonksiyonlar **silinir**, ikame edilmez. Silindikten sonra çağrı denemesi E-lint (§17.9).

### 4.3 Kapsam (scope) çözümü — isimli slotlar

Kart hangi varlıklara ihtiyaç duyduğunu **isimli slotlarla** yazar:

scope:

```
  employee_a: { type: employee, required: true }
  employee_b: { type: employee, required: true }
  customer:   { type: customer, required: false }
```

**Slot adlandırma kuralı:**

- Aynı tipten **tek** varlık varsa slot adı yazılmayabilir; tip adı slot adı olur.
- Aynı tipten **birden fazla** varlık varsa slot adları **zorunludur**; yoksa E-lint (§17.12).
Bu kural, iki çalışan arasındaki çatışma gibi çoklu-özne kartlarını baştan destekler.

**Çözüm sırası:**

- Çağıran bağlamda verdiyse (sinyal `employee_id` taşıyorsa) o kullanılır.
- Verilmediyse motor seçici çalıştırır. **Seçici tip-güvenlidir**: `employee` slotu asla `customer` almaz.
- Aynı varlık iki slota atanamaz (`employee_a != employee_b`).
- Çözülemezse kart **kabul edilmez** (hata değil, sessiz red, log'a yazılır).
**Asla tahmin edilmez.** Belirsiz kapsam = red. Yanlış varlık silmenin tek sebebi tahmindir.

**Seçiciler.** Slot `select` ile bir seçici adlandırabilir; adlandırmayan slot tipinin varsayılanını alır (kimliğe göre ilk boştaki varlık). Seçici yalnız başka slota bağlanmamış varlıklar arasından seçer; uygun varlık yoksa slot dolmaz.

```
  employee   lowest_morale · newest_hire
             most_senior    en yüksek seviye, eşitlikte en eski işe alım
             account_rep    bağlı `customer` slotundaki hesabın temsilcisi
             support_lead   destek sıralamasının ilk temsilcisi
  customer   at_risk · escalated · expansion_ready · open_request
             largest        en yüksek MRR · smallest   en düşük MRR
  investor   expiring_sheet (süresi en az kalan teklif) · decision_sheet (karar
             günü gelmiş teklif) · seed_lead
```

`founder`, `prospect` ve `rival` seçici almaz. Koşul bağlanan tek özneye karşı sınanır (slot süzgeci `where`: §27.16); hangi özneye sorulacağını seçici söyler (gerekçe §27.4).

**Seçici önceki slotları görür (`bound`).** Önce zorunlu slotlar, sonra opsiyoneller, her grup bildirim sırasıyla çözülür; her seçici o ana kadar bağlanmış slotları okur. `account_rep` böyle çalışır: temsilciyi kartın zaten bağladığı hesaptan bulur.

**Kurucu ayrı tiptir.** `founder` kendi kapsam tipidir; `employee` seçicisi asla kurucuyu döndürmez. Kurucu bir işgücü birimi değildir (GDD02§5 rulingi).

### 4.4 Yeniden doğrulamanın gerekçesi

Kabul ile gösterim arasında günler geçebilir. Bir kart kuyruğa girdiğinde koşulu doğruydu; gösterildiğinde çalışan istifa etmiş, sözleşme bitmiş, faz geçmiş olabilir. Gösterim anında G5–G7 tekrar koşar. Düşerse kart sessizce iptal olur, history'ye `dropped` yazılır.

**G3 (latch) yeniden koşmaz** — bir kez kabul edilmiş kart cooldown'ı zaten tüketmiştir. **G8 (tempo) yeniden koşmaz** — sınıf kabul anında belirlenir.

### 4.5 force_fire() — tek istisnalı yol

Debug ve smoke testleri için. G3, G4, G8'i atlar. **G1, G2, G5, G6, G7'yi atlamaz.** History'ye `forced: true` yazar. Release build'de erişilemez.

## 5. KOŞUL SÖZLÜĞÜ

### 5.1 Biçim

İç içe JSON dict'i. Parser yok, lexer yok, `Expression` yok. Recursive değerlendirme.

**Düğümler:** `all` (AND) · `any` (OR) · `none` (hiçbiri) · `not` (tek çocuk)

**Yapraklar — beş tip:**

{"seam": "hr.headcount", "op": ">=", "value": 3}

{"flag": "frank_seed_taken"}

{"flag_unset": "acquisition_declined"}

{"history": "chose", "event": "funding.seed_kapisi", "option": "accept"}

{"arc": "active", "id": "arc_zeynep_yan_proje"}

### 5.2 Zorunlu primitive listesi

Bunların hepsi v1'de bulunur. Eksiği tetikleyiciyi GDScript'e kaçırır (I5 ihlali).

**Seam sorguları**

- `{"seam": <ad>, "op": ">=|>|<=|<|==|!=", "value": <sayı|string>}`
- `{"seam": <ad>, "op": "in", "value": [<liste>]}`
**Bayrak ve damga**

- `{"flag": <ad>}` / `{"flag_unset": <ad>}`
- `{"weeks_since_flag": <ad>, "op": ">=", "value": N}` ← **Frank korpusunun istediği generic primitive**
- `{"flag_expires_within": <ad>, "weeks": N}`
**Geçmiş**

- `{"history": "fired", "event": <id>}`
- `{"history": "fire_count", "event": <id>, "op": "<", "value": N}`
- `{"history": "chose", "event": <id>, "option": <id>}` ← callback'lerin temeli
- `{"history": "weeks_since", "event": <id>, "op": ">=", "value": N}`
- `{"history": "resolution", "event": <id>, "value": "expired|dropped|chosen"}`
**Ark**

- `{"arc": "active", "id": <id>}`
- `{"arc": "at_step", "id": <id>, "step": N}`
- `{"arc": "ended", "id": <id>, "outcome": <id>}`
- `{"arc": "awaiting_subject", "id": <id>}`
**Varlık**

- `{"entity_exists": <slot>}`
- `{"entity_count": <tip>, "op": ">=", "value": N}`
- `{"entity_seam": "employee.morale", "scope": "employee_a", "op": "<", "value": 50}`
`scope` alanı: aynı tipten tek slot varsa opsiyonel, birden fazlaysa **zorunlu** (§17.12).

**Zaman okuyan yapraklar hafta sayar.** `weeks_since_flag`, `flag_expires_within` ve `history: weeks_since` tik farkını okur; bir tik bir haftadır. Hiç damgalanmamış bayrak, canlı olmayan süreli bayrak ya da hiç çözülmemiş kart -1 döner ve yaprak FALSE olur: "olmadı", "çok uzun zaman önce oldu" sayılmaz.

### 5.3 Değerlendirme kuralları

- Boş `all` = true. Boş `any` = false. Boş `none` = true.
- Bilinmeyen seam adı = **lint hatası** (build'e girmez). Runtime'da olursa false + error.log.
- Tanımsız bayrak = false. (Additive namespace; eski save'ler yeni bayrağı bilmez, sorun değil.)
- Kısa devre yapılır: `all` ilk false'ta durur.
- **Yan etki yasak.** Koşul değerlendirmesi hiçbir durumu değiştiremez.

### 5.4 Yapısal red gerekçesi

Koşul değerlendirmesi `false` değil, **yapılandırılmış sonuç** döndürür:

{ passed: false, failed_leaf: {...}, reason_key: "requires_series_a" }

Bu, kilitli seçeneğin neden kilitli olduğunu göstermenin ve "bu kart neden ateşlenmedi" panelinin (§19.2) temelidir.

## 6. SEAM REGISTRY

### 6.1 Sözleşme

- **Salt okunur.** Mutasyon `EffectExecutor`'ın işidir.
- **Namespace'li:** `hr.` `product.` `sales.` `finance.` `rnd.` `investor.` `phase.` `rival.` `founder.` `time.`
- **Anlamı değişirse yeni isim.** Sessiz semantik değişikliği yasak.
- **Manifest lint edilir.** Registry'de olmayan seam adı = build hatası.
- **Mock'lanabilir.** İçeriğin sistemlerden bağımsız test edilmesinin tek yolu.

### 6.2 Kayıt formatı

```
seam_name       tip      aralık/enum    sahibi modül   versiyon   durum
hr.headcount    int      0..∞           HR             1          VAR
hr.morale_avg   float    0..100         HR             1          VAR
```

### 6.3 Envanter, motor task'ının ilk teslimatıdır

Ajan Aşama 1'e başlamadan **önce** HR / Ürün / Ar-Ge / Finans / Satış kodunu okur ve `docs/SEAM_REGISTRY.md` üretir. Her satır üç durumdan birini taşır:

| Durum | Anlam | Aksiyon |
|---|---|---|
| VAR | İsimli ve okunabilir | Registry'ye kaydedilir |
| OKUNUYOR | Değer erişilebilir ama isimli seam değil | Motor task'ı sarmalar |
| YOK | Hiç yok | Sahibi modülün açık işi olarak dosyalanır |

Bu bir audit değildir, **motorun kendi ön koşuludur.** Ajan o kodu zaten okuyacaktır; çıktıyı bir dosyaya yazması ek maliyet doğurmaz.

### 6.4 Seam sözleşmesi — her modül task'ına giren standart madde

Bu metin, bugünden sonra yazılacak **her modül task'ına** aynen konur:

**SEAM SÖZLEŞMESİ:** Bu modül şu isimli, salt-okunur sorguları açar: [liste]. Seam'ler `SeamRegistry`'ye kaydedilir ve `docs/SEAM_REGISTRY.md`'ye işlenir. Modül "bitti" sayılmaz eğer seam'leri kayıtlı değilse.

Böylece Pazarlama, Yatırım, Ar-Ge devamı — hangi modül gelirse gelsin motora bağlanabilir halde doğar. Retrofit yoktur.

### 6.5 v1 tabanı

Ekip rev11'in **15 isimli query seam'i** registry'nin ilk kaydıdır ve olduğu gibi taşınır.

## 7. HAFIZA / HISTORY SÖZLEŞMESİ

### 7.1 Kayıt formatı

Her çözümde tek satır yazılır:

event_id

```
day                 mutlak tik (bir oyun günü = bir hafta); ad korunur
resolution          chosen | expired | dropped | forced
option_id           chosen ise dolu, aksi halde null
outcome_id          zar sonucu dahil nihai sonuç anahtarı
entities            {slot: {type, id}}  çözüm anındaki kapsam
deltas              uygulanan etkilerin özeti (debug + son ekranı için)
arc_id              varsa
names               {slot: ad} çözüm anında; özel ad metin, B2C kitlesi {key, arg} (§27.12)
```

### 7.2 Neden bu kadar kritik

Mevcut motorun en yıkıcı kusuru buydu: `_history` yazılıyor ama `get_history()` **sıfır kez** çağrılıyordu. Yani hiçbir kart "bu daha önce oldu" diyemiyordu. Callback yok, ark yok, vaat-ödeme yok. §0.2'deki tez ölüydü.

### 7.3 Sorgu arayüzü

§5.2'deki `history` yaprakları bu tablodan okur. Ayrıca:

- **Olaylar gelen kutusu** cevaplanan ve süresi dolan satırları seçilen seçenek, delta çipleri ve damgayla gösterir; `forced` satırı ve ambient kart listeye girmez (§27.14).
- **Son ekranı** history'yi okuyup koşunun anlatısını çıkarabilir.
- **Ticker** son çözümlerden satır üretebilir (§18).
- **Debug paneli** tam kaydı gösterir.

### 7.4 Dil bağımsızlığı

History **yalnızca id** saklar (`option_id`, `outcome_id`). Etiket saklamaz. Oyuncu 2. haftada Türkçe, 13. haftada İngilizce oynasa da callback çalışır.

### 7.5 Budama yok

History koşu boyunca budanmaz. Yumuşak tavana kadar süren bir koşu 104 tiktir (`EndingsSystem.SOFT_CAP_WEEK`); 1×'te varsayılan mesaide bu yaklaşık 39 gerçek dakika eder. Böyle bir koşuda ~150-400 satır beklenir; bellek ve save boyutu ihmal edilebilir.

## 8. ETKİ SÖZLÜĞÜ

### 8.1 Tam liste

DURUM

```
  add_cash, add_mrr, add_brand, add_reputation
  change_morale(scope, delta)
  set_seam_backed(...)          modül-özel mutasyonlar
```

BAYRAK

```
  set_flag(name)
  clear_flag(name)
  set_timed_flag(name, weeks)
  stamp_day(name)               weeks_since_flag'in kaynağı; tiki damgalar
  set_game_flag(name, value = true)
                                GameState.flags'e tek kapı; beyaz listeli
```

İlk dört fiil yalnız motorun kendi hafızasına (`EvFlags`) yazar; `flag`, `flag_unset`, `weeks_since_flag` ve `flag_expires_within` yaprakları da (§5.2) yalnız onu okur. `GameState.flags` sistem durumudur: içerik ona yalnız `set_game_flag` ile, beyaz listedeki adlara yazar (`tech_debt_birikti`, `critical_bug_unfixed`); `value` verilmezse `true` yazılır, `false` bayrağı indirir. Başka her sistem durumu sahibinin adlı fiiliyle ya da seam'iyle değişir. Beyaz listeye satır eklemek bir tasarım kararıdır.

ZAMANLAMA

```
  schedule_event(id, delay_weeks, context?, arc_id?)
  cancel_scheduled(id)
```

ARK

```
  start_arc(id, subject?)
  advance_arc(id, step?)
  set_arc_var(id, key, value)
  abort_arc(id, reason)
  end_arc(id, outcome)
```

VARLIK

```
  fire_employee(scope)
  employee_leaves(scope, reason)
  churn_customer(scope)
  add_customer(...)
  damage_product(scope, amount)
  assign_to(scope, job)
```

NAVİGASYON

```
  goto_tab(tab_id)              7 kartın beklediği modifier
```

KİLİT

```
  unlock_content(id)            Ar-Ge gizli hatları, EA kapıları
```

BÜTÇE

```
  spend_budget(name)            Frank aforizması vb. koşu-başı kıt kaynak
```

TİCKER

```
  EvTicker.push(line_key, priority, context)   §18
```

DIŞ SİSTEM

```
  open_negotiation(type, context)   §9.4
  open_term_table                   bağlı yatırımcının Series A masasını açar
  open_seed_table                   tek seed teklifinin masasını açar
  decline_offer                     süresi dolmuş Series A teklifini kapatır;
                                    fon kalıcı olarak kapanır
```

Üçü de para oynatmaz. Seed ve Series A parası masadaki imzada, oynanan anda hareket eder. Masayı açan istek aşamayı taşır (seed ya da Series A).

TERMİNAL

```
  trigger_ending(id)
```

### 8.2 Yürütme kuralları

- **Sıralı.** Liste sırasıyla, atomik değil.
- **Geri alınamaz.** Ama her etki history'nin `deltas` alanına loglanır.
- **Kaskad aynı tikte olmaz.** Bir etkinin doğurduğu yeni koşul, **bir sonraki tikte** değerlendirilir. Sonsuz döngü riski böyle kapanır. Saatlik kart için bir sonraki tik bir sonraki oyun saatidir; günlük kart için haftanın sonundaki 00:00 devridir ve oyuncu o kartı yeni haftanın başında, 08:00'de görür.
- **Hedef yoksa no-op.** `churn_customer` çözülmemiş kapsamda çalışmaz, sessizce atlar ve error.log'a yazar.

### 8.3 I2 — Ekonomik delta yalnız oynanmış karardan

`add_cash`, `add_mrr`, `add_customer`, `add_brand` **yalnızca bir seçeneğin** **`effects`** **listesinden** çağrılabilir.

Çağrılamayacağı yerler: ambient tik, ark oto-adımı, sinyal handler'ı, `on_expire`, `on_invalidate`.

**Lint zorlar.** Bu, "sistem olayı = ekonomik sonuç" hatamızın yapısal ölümüdür.

**İstisna:** `on_expire` **negatif** delta uygulayabilir (cevap vermemenin bedeli). Pozitif ekonomik delta asla.

### 8.4 I3 — Telgrafsız kayıp yok

`trigger_ending` ve `is_loss_risk: true` işaretli her etki şunu taşımak zorundadır:

requires_telegraph: <flag_adı | event_id>

Motor, bu telgraf geçmişte ateşlenmemişse etkiyi **uygulamaz** ve error.log'a yazar. Lint aynı kuralı derleme zamanında koşar.

Kapsam: iflas, yumuşak tavan, kurucu tükenmesi, ürün ölümü, şirket kapanışı.

**Sayı metne gömülmez.** `SHUTTER_WEEKS` gibi değerler seam'de yaşar (`finance.shutter_weeks_total`), kart metni interpolasyonla okur. `END_META_BANKRUPTCY_FRANK` bir zamanlar "yedi gün" diyordu, kepenk ise 30 gündü: düzyazıdaki sayı bayatlamıştı ve bu kural o hata sınıfını kapatır. Metin bugün sayıyı `{days}` yer tutucusundan alır. Frank'in onaylı cümlesi gün söylediği için `EndingsSystem` ona haftalık kepengin gün karşılığını verir: `SHUTTER_WEEKS` 4 × 7 = 28.

### 8.5 Bütçeler

`spend_budget(name)` — koşu başına kıt anlatı kaynağı. Bütçe bittiğinde o etkiyi taşıyan seçenek **kilitlenir** ve gerekçesini gösterir.

```
v1 bütçeleri: frank_aphorism: 2
```

## 9. ZAR

### 9.1 Duruş

Belirsizlik "zar tuttu mu"da değil, **hangi sonucun geleceğinde ve ne zaman geleceğinde** yaşar. Zar yalnızca fiction'ın zorunlu kıldığı yerde bulunur.

**Üç şart. Üçü birden sağlanmıyorsa zar konulmaz:**

- Olasılık karar öncesi görünür.
- Oyuncunun seçimi olasılığı **görünür şekilde** değiştirir.
- Hiçbir dal terminal değildir (I6).
**Tek zar tipi vardır:** **`check`****.** rev1'deki `band` tipi kaldırılmıştır (§9.4).

### 9.2 Kontrol (check)

check:

```
  odds_seam: hr.retention_odds        oranı hesaplayan seam
  on_pass: [effects]
  on_fail: [effects]
```

Seçenek başına ayrı `check` bulunur; yani her seçenek kendi oranını taşır.

**Nerede:** çalışan tutma, müşteri elde tutma, kritik olmayan tutma anları.

### 9.3 Deterministik türetme

zar = hash(run_seed, day, event_id, option_id)

**`option_id`****'nin hash'e girmesi zorunludur.** Sonuç:

- Aynı seçenek tekrar denenirse → **aynı sonuç.** Zar balıkçılığı imkânsız.
- Farklı seçenek denenirse → **gerçekten farklı zar**, ama farklı maliyet.
Yani reload'un tek getirisi daha iyi (ve daha pahalı) bir teklif yapmaktır. Bu sömürü değil, öğrenmedir.

`day` tiktir. Bir tik bir hafta olduğu için aynı seçenek aynı hafta içinde hangi saatte denenirse denensin aynı sonucu verir.

Havuz çekilişi de aynı şekilde deterministiktir: `hash(run_seed, day, "pool", n)`.

### 9.4 Pazarlık motorun dışındadır

effect: open_negotiation(type, context)

Motor sahneyi açar, sonucu bir kart çıktısı gibi işler. Müzakerenin içini bilmez.

**Dönüş sözleşmesi (GEÇİCİ — sahibi §23 A4):**

{ outcome_id, values: {...}, effects_to_apply: [...] }

Motor bu yapının içeriğini doğrulamaz; yalnızca `effects_to_apply` listesini kendi sözlüğüne göre yürütür. Pazarlık tasarlandığında sözleşme kesinleşir; motorda değişiklik gerekmez.

**`band`** **neden kaldırıldı:** Bir teklifin $180K–$340K aralığında nereye düşeceği pazarlık sisteminin mekaniğidir, motorun zar tipi değil. Aralığın oyuncuya telgraf olarak gösterilmesi bir sunum detayıdır. Motora ikinci bir zar tipi eklemek gereksiz karmaşıklıktı.

### 9.5 I6 zorlaması

- `check` dallarının hiçbiri `trigger_ending` içeremez (E-lint).
- `check` varsa oran gösterimi kapatılamaz (E-lint).

### 9.6 Modifier gösterimi

**Görünüm kuralı:**

- Yüzde **her zaman görünür**, ama **farklı bir renk tonuyla** — hover edilebilir olduğunu söyleyen bir affordance taşır.
- Modifier listesi **yalnızca hover'da** açılır. Karar ekranı sakin kalır; isteyen derine iner.
**Liste kuralları:**

- **Sayısız.** Aritmetik gösterilmez.
- **İşaretli** (▲ lehte / ▼ aleyhte).
- **Büyüklüğe göre sıralı.**
- **Büyük harfle başlar.** Her satır (etiket, beceri adı, katlanan satır) büyük harfle başlar.
- **Maksimum 4 satır.** Fazlası işaretsiz, nötr bir "+N etken daha" satırında toplanır (`EV_MODIFIERS_MORE`; N kalan satır sayısıdır, büyüklük değil); satır kalanları aynı biçimde (işaret ve etiket) `rest`'inde taşır (`EvDice.modifier_lines`); satış görüşmesinde iğnenin İkna ipucu bütün satırları sıralar. Kart yazarının `modifier_lines` sözlüğü en çok 4 anahtar taşır (E-lint), bu yüzden kartta katlama oluşmaz.
- Sayısal döküm yalnızca dev overlay'de.
```
kalır %58        ← farklı renk tonu, hover edilebilir

  (hover)
  ▲ Morali iyi
  ▲ Ekipte sekiz ay
  ▼ Maaşı bandın altında
  ▼ Üst üste mesai
```

**Gerekçe:** Sayı vermek insan anını hesap tablosuna çevirir. Hiçbir şey vermemek kararı kör bırakır. Hover'a saklamak ikisini de çözer: yüzey sakin, derinlik mevcut.

### 9.7 I7 — Modifier = seam

**Her modifier satırının arkasında isimli bir seam olmak zorundadır. Seam yoksa modifier yoktur.**

Bir yazar "rakibin teklifi ciddi" yazamaz, çünkü `rival.offer_seriousness` diye bir seam yoktur. Yazmak isterse önce o seam'in açılması gerekir — ki bu bir tasarım kararıdır, bir metin süsü değil.

`modifier_lines` sözlüğünün her anahtarı `SeamRegistry`'de var olmak zorundadır (E-lint §17.11).

**Ekip rev11'de bugün mevcut olan modifier kaynakları** (çalışan tutma kontrolü için referans):

| Modifier | Dayanağı | Durum |
|---|---|---|
| Moral bandı | 80-100 / 50-80 / <50 / <35 "Ayrılabilir" | VAR |
| Kıdem | Kıdem tazminat kademelerinin dayandığı alan | VAR |
| Çalışma saati / mesai yükü | 5-16 saat, bitiş en geç 00:00; 8 saati aşan her saat moral kaymasını hızlandırır (16 saatte ×2,5) | VAR |
| Seviye | Junior / Mid / Senior | VAR |
| Trait | Kart başına tek trait | VAR |
| Kurucu Karizma | Kurucu-özel stat | VAR |
| Maaşın banda göre konumu | §9.1 maaş tablosu var, karşılaştırma seam'i yok | YOK → HR açık işi |
| Terfi uygunluğu | employee_eligible_for_promotion deklare, ateşlenmiyor | YOK → §15.2 |

## 10. ARK

### 10.1 Şema

```
id                  benzersiz, koşu başına tekil
type                promise | character | world | assignment
subject             {type, id} | null
step                aktif adım (int)
vars                {} serbest anahtar-değer
```

started_day

```
state               active | awaiting_subject | ended
steps[]             adım tanımları
invalidate_when[]   koşul listesi
on_invalidate       { policy, effects[], note_key }
restartable         bool, varsayılan false
allow_concurrent    bool, varsayılan false
parent_arc          opsiyonel, iç içe ark için
```

### 10.2 Adım tanımı

step:

```
  id
  fire: { delay_weeks: N }  |  { condition: {...} }  |  { signal: <ad> }
  event_id
  optional: true|false     false ise ark bu adımı beklemek zorunda
```

### 10.3 Yaşam döngüsü

start_arc → state:active, step:0, started_day damgalanır

```
          → ilk adım Schedule'a ya da koşul izlemeye girer
```

adım ateşlenir → kart Gate'e proposal olarak gider

kart çözülür → advance_arc

son adım → end_arc(outcome) → state:ended, history'ye yazılır

**Ark adımları tempo bütçesi tanımaz** (§13.5). Ark ilerlemesi kesintiye uğramaz.

### 10.4 İptal koşulları

invalidate_when:

```
  - {"not": {"entity_exists": "employee"}}      öznesi gitti
  - {"seam": "phase.current", "op": "==", "value": "series_a"}
  - {"flag": "product_cancelled"}
```

Her tikte kontrol edilir. Tetiklenirse `on_invalidate` politikası uygulanır.

**Özneli arkta** **`invalidate_when`** **boş bırakılamaz** (E-lint §17.6).

### 10.5 Üç iptal politikası

| Politika | Davranış | Kullanım |
|---|---|---|
| reassign | Ark ölmez, durur. state: awaiting_subject. Schedule dondurulur. Yeni özne isteyen bir kart ateşlenir. | Atama gerektiren işler: araştırma, destek hattı, satış hesabı |
| close | Ark görünür bir kartla kapanır. on_invalidate.effects koşar. | Vaat arkları |
| fade | Ticker satırı, kart yok. | Öznesiz dünya arkları |

**`reassign`** **zaman aşımı:** `awaiting_subject` durumu **2 hafta** (`ARC_AWAITING_SUBJECT_TIMEOUT_WEEKS`) sürerse politika otomatik `close`'a düşer. Ark sonsuza kadar askıda kalmaz. Duraklayan arkın zamanlanmış adımları göreli hafta olarak (`remaining_weeks`) donar ve ark yeniden özne bulunca kaldıkları yerden sayar.

**Örnek —** **`reassign`****:** Zeynep bir araştırma hattını yürütüyor. Zeynep gidiyor. Ark ölmüyor; masaya bir kağıt geliyor: "Zeynep'in yürüttüğü araştırma sahipsiz kaldı. Kim devam edecek?" Oyuncu birini atıyor, ark kaldığı adımdan devam ediyor. Bu, Ar-Ge rev1.4 §5.0'ın "atamalar silinmez, duraklar" kuralıyla birebir hizalıdır.

### 10.6 I-ARK — Vaat arkında on_invalidate zorunlu

`type: promise` taşıyan bir arkın `on_invalidate.policy` alanı `fade` **olamaz** ve `effects` boş **olamaz**. Boşsa **E-lint**.

**Gerekçe:** Bizim tezimiz "2. hafta 13. haftayı etkiler" (§0.2). Vaat edilen bir şey sessizce buharlaşırsa oyuncu bunu bug sanır ve tez çürür.

### 10.7 Özne başına ark limiti

Varsayılan: bir özne aynı anda **1 aktif ark** taşır. İkinci ark `deferred` olur ve birincisi bitince yeniden proposal'a girer.

Override: `allow_concurrent: true`. Nadir olmalı.

### 10.8 İç içe ark

- **İzinlidir, maksimum derinlik 2.** Daha derini E-lint.
- Çocuk arkın iptali **ebeveyni öldürmez.**
- Ebeveyn arkın iptali çocuklarını da iptal eder (kendi politikalarıyla).

### 10.9 Tekrar başlatma ve tekillik

- **Ark id'leri koşu başına tekildir.** Aktif bir arkı yeniden başlatma girişimi **no-op + W-log**.
- **Biten ark yeniden başlatılamaz**, `restartable: true` yazılmadıkça.
- Özne geri gelirse (eski çalışan tekrar işe alındı) **yeni varlık = yeni id**; ark yeniden bağlanmaz.

### 10.10 Ark adımı havuza giremez

Bir ark adımı olan kart **havuza giremez** (`tag: critical` gibi davranır, ağırlıklı çekilişe katılmaz).

**Gerekçe:** Aksi halde kart ark dışında ateşlenir, `one_shot` latch'ini yakar, ve ark o adımı bir daha çalıştıramayacağı için **kilitlenir.** Bu sessiz bir ölüm türüdür ve E-lint ile kapatılır (§17.6).

## 11. SUNUM SINIFLARI

### 11.1 Dört sınıf

| Sınıf | Yüzey | Zaman | Ne zaman |
|---|---|---|---|
| interrupt | Karar kapısı: Olaylar gelen kutusu kartın üstünde açılır | Durur (saat tutulur) | Kriz, ark dönüm noktası, süresi dolan teklifin son uyarısı, terminal telgraf |
| paper | Gelen kutusunda kağıt (masa); ofisin bildirim yığını önizler | Akar | Karar gerektiren ama acil olmayan |
| info | Sekme rozeti / gelen kutusunda mesaj | Akar | 4 haftada bir Ar-Ge notu (`report_period_weeks`), terfi uygunluğu bildirimi |
| ambient | News ticker | Akar | Rakip haberi, dünya gürültüsü, ark fade izi |

Karar olmayan anlar (Frank'in tanışması, dönem özeti, Ar-Ge notu ve keşfi, haftalık satış raporu) kart değildir:
gelen kutusunda mesajdır ve motorun dışında `GameState.messages`'ta durur (§27.13, §27.14).

### 11.2 Öncelik sırası

Kuyrukta birden fazla geçerli kart varsa:

1. terminal (son, terminal telgraf)

2. süresi dolmak üzere olan kağıdın son uyarısı

3. tag:critical (ark dönüm noktası, faz)

4. interrupt

5. paper

6. info

7. ambient

Aynı seviyede: **en eski kabul edilen önce.** Eşitlikte `event_id` alfabetik (deterministik, seed'e bağlı değil).

### 11.3 Karar kapısı kuralları

- **Aynı anda tek karar.** İkincisi kuyrukta bekler; gelen kutusu kuyruğu tek satırda sayı olarak, üst çubuk
  "{n} karar bekliyor" diye gösterir.
- **Karar saati tutar.** Kart ekrana gelince `main` saati tutar (`TimeManager.hold_clock("event")`); motor yalnız
  duyurur (`EventBus.modal_requested`), kabuk kurmayan koşu (smoke, probe) bu yüzden donmaz. Tutuş SceneTree'yi
  durdurur ve toplu adımı keser: tik dönüşü (gece atlamasının içindeki 00:00 devri) kart cevaplanana kadar bekler.
  Tutuş varken hız tuşları reddedilir, üst çubuktaki kapı yuvası yanıp söner. Cevap ya da masadan açılan kağıdın
  kenara konması tutuşu bırakır ve kartın bulduğu hızı geri verir; kuyrukta kart varsa saat durmaya devam eder.
- **`process_mode = ALWAYS (3)`** **zorunlu.** GameShell ve tüm interaktif çocukları. Agent varsayılanı `INHERIT`'tir ve bu bug runtime testi olmadan görünmez.
- **Kapı açıkken başka her şey yalnız okunur.** Tek yüklem `EventGate.active_id() != ""`'dır. Olaylar dışındaki
  pencerede başlığın altında karara dönen şerit belirir ve sayfa gövdesine tıklama ulaşmaz; tekerlek ve kaydırma
  çubuğu geçer. Panel katmanı kapanır ve yeni panel açılmaz; ofis taşıma ve şehir haritası kapalıdır, kişiye tıklama
  dosyayı yalnız okunur açar. `main` pitch, onay, satış ve sprint isteklerini ve term sheet masasını (kartın kendi
  seçeneğinin açtığı hariç) reddeder; çalan telefon açılmaz. Kayıt kapalıdır; sistem menüsü gerekçeyi yazar. Esc üstteki pencereyi kapatır;
  pencere kalmamışsa Olaylar'ı kartın üstünde karar başına bir kez yeniden açar, sonraki Esc sistem menüsünü açar.
- **Kartın istediği sekme kapı kapanınca açılır** (`goto_tab`). Dönüm noktası kâğıdı da kapıyı bekler: kâğıt gece
  atlamasını durdurur, o atlamanın kabul ettiği kart altında açılırsa kâğıt karara yer açar ve kapı kapanınca geri
  gelir. Kuyruktaki kartların hepsi yeniden doğrulamada düşerse (§4.4) saat ve bekleyenler pompadan sonra döner.
- **Toplantı saati durdurur, bitince saati ileri atlatır.** Satış toplantısı, VC ve seed pitch'i ve term sheet masası açıkken saat durur. Oturum kapanınca saat oturumun süresi kadar ileri gider: satış 2 saat (`SalesConstants.MEETING_SKIP_HOURS`), pitch 2 saat (`PitchConstants.MEETING_HOURS`; birinci vuruşta çekilen VC toplantısı yarısı, 1 saat), masa 1 saat (`TERM_TABLE_HOURS`; koşuyu bitiren imzada atlama olmaz). Atlanan saatler silinmez: `TimeManager.advance_hours` her birinin saatlik tikini koşar. Atlama kurucunun mesai bitiminde, en geç 23:00'te durur ve gece yarısını geçmez; kalan saatleri gece atlaması taşır.
- **Toplu adımda kart gösterilmez.** Toplantı atlaması ya da gece atlaması sürerken (`TimeManager.is_batching()`) `EvEngine.pump()` hiçbir kart göstermez; adım bitince (`EventBus.clock_batch_ended`) bir kez pompalanır. Kart gösterileceği saatte yeniden doğrulanır (§4.4), en önemlisi önce gelir (§11.2) ve açık bir kart 00:00 autosave'ini engellemez.

### 11.4 Masa

- Masa kağıtları taşır, **kapasite sınırı yoktur** (§12.1 sebebiyle gereksiz).
- Masa gelen kutusunda görünür: her kağıt bir satırdır (gönderen, konu, ilk satır, kalan hafta). Ofisin bildirim
  yığını en yeni satırları önizler; tıklanan satır kutuyu o kağıtta açar.
- Kağıt okunurken zaman akar. "Cevapla" kağıdı açar; açılan kağıt karar gibi davranır (saat tutulur). Esc, × ya da
  başka sekmeye geçmek onu cevapsız masaya döndürür (§27.12).
- Masa kağıtları örnek anahtarıyla tutar (§20 E2). Bir sistem masada bekleyen örneği `EventGate.request` ile isterse o kağıt açılır.
- Kağıdın kalan haftası kağıdın üzerinde **görünür**. Son haftasında görsel vurgu (`expiring`), yalnız ömrü bir haftadan uzun kağıtta. Ömrü tek hafta olan kağıt baştan "bu hafta" der (§12.4).
- Günlük-tik kartlarında saat gösterilmez (mühürlü kural).

### 11.5 Maksimum hız

Oyunun maksimum hızı **4×**'tür. Hız merdiveni oyun saati başına gerçek saniyedir (`TimeModel.SECONDS_PER_HOUR`: duraklat, 2,5, 1,25, 2,5/3, 0,625). Hafta 08:00'de başlar ve ofis boşalınca gece atlanır; varsayılan 09-17 mesaide bir hafta 1×'te 22,5, 2×'te 11,25, 3×'te 7,5, 4×'te 5,625 sn sürer (`TimeModel.seconds_per_tick`).

4× bir ara modal yoğunluğu sebebiyle kaldırılmıştı: gün modelinde 3×'te bir oyun günü 3 sn sürüyordu. Haftalık modelde 4×'te bir hafta 22,5 sn sürdüğü için geri geldi (§27.9); sahip kararıyla (2026-10-09) merdiven dört kat hızlandı ve 4×'te bir hafta 5,625 sn sürer. Tempo bütçesi tik (hafta) bazlıdır; hız yalnız bütçenin gerçek zamandaki sıklığını değiştirir, fazlası kağıda düşer (I4).

### 11.6 Tutorial kancası

Motor tutorial akışını tasarlamaz, ama bir suppression modu taşır:

```
tag: tutorial          — bu kart tutorial akışının parçası
```

flag: tutorial_active  — aktifken:

```
                          · havuz tamamen susar
                          · yalnızca tag:tutorial kartları G2'yi geçer
                          · tempo bütçesi tanınmaz
                          · taban (§13.6) devre dışı
```

**Gerekçe:** Bir suppression modunu sonradan eklemek pahalıdır; şimdi ayırmak bedavadır. Tutorial tasarlandığında motorda değişiklik gerekmez — bu bizim "forward-compatible data shape" kalıbımızın aynısıdır.

## 12. SÜRE DOLUMU

### 12.1 Temel kural

**Her ODA kağıdının bir cevap süresi vardır. Süresi olmayan şey kağıt değildir.**

Kağıt = birinin senden cevap beklediği şey. Kimse beklemiyorsa o bir karar değil, bilgidir — ve bilgi sekmeye ya da ticker'a gider.

Bu kural masa dağınıklığını kendiliğinden çözer; kapasite tavanına gerek kalmaz.

### 12.2 Süre tablosu

Süre haftadır. Bekleyebilen her kart kendi süresini `expires_weeks` alanında taşır; süre kartın anlattığı durumun doğasına göre seçilir (sahibin örneği: çalışan ya da müşteri talebi 2 hafta). Değer, kart masaya kağıt olarak düştüğünde okunur: `class: paper` kartlarda ve tempo bütçesinin kağıda düşürdüğü kesintilerde (§13.2). Lint alanı her `interrupt` ve `paper` kartında zorunlu kılar (§17.7).

| Kart | Sınıf | Hafta | Cevapsız kalırsa |
|---|---|---|---|
| `customer.request_complaint`, `customer.request_feature`, `customer.request_renewal` | paper | 2 | Hesabın memnuniyeti 5 puan düşer |
| `customer.expansion` | paper | 2 | Genişleme geri çevrilmiş sayılır |
| `funding.seed_stalled` | paper | 2 | Kapanır, ceza yok |
| `world.final_stretch_press` | paper | 4 | Son düzlük arkı yine başlar (§27.7) |
| `customer.retention` | interrupt, düşebilir | 1 | Riskteki hesap görmezden gelinmiş sayılır |
| `sales.price_break` | interrupt, düşebilir | 1 | Fiyat konusu kapanır |

**Düşmeyen kesintiler.** Tempo bütçesi tanımayan kesintiler (`critical`, `terminal_warning`, ark adımı; §13.5) hiç kağıda düşmez, hemen cevaplanır. Lint onlardan da `expires_weeks` ister: o haftaya bağlı olanlarda 1, duyurularda 2, para masasında 4 (`funding.frank_cheque`, `funding.seed_offer`). Bu değerleri bugün okuyan yoktur (§27.9). Satın alma teklifi de bu gruptadır: kartı (`funding.acquisition_offer`) kritik bir kesintidir, penceresi `EndingsSystem.ACQ_CARD_WINDOW_WEEKS` (1 hafta).

**Geri düşüş.** Alanı taşımayan kart için motorun tablosu (`EvEngine._expiry_weeks`): varsayılan 1 hafta (`EXPIRY_DEFAULT_WEEKS`), para masası (`money_table` etiketi) 4 (`EXPIRY_MONEY_WEEKS`), düşük bahisli (`low_stakes`) 2 (`EXPIRY_LOW_STAKES_WEEKS`). Gün modelindeki 7 / 30 / 14 günün haftalık karşılığıdır.

**Kartı henüz yazılmamış yüzeyler.** Tasarımın iki yüzeyinin kartı yoktur. Çalışana gelen rakip teklifi cevapsız kalırsa çalışan gider ("bekletildi"); zam talebi cevapsız kalırsa moral düşer ve ayrılabilir riski artar. Süreleri kartları yazılırken aynı kuralla seçilir.

**Series A term sheet'i bir motor kağıdı değildir.** Süresini yatırım sistemi tutar: teklif 3 hafta geçerlidir (`PitchConstants.SHEET_VALIDITY_WEEKS`; K5'in 10 iş günü haftalık modelde 3 hafta oldu). Uyarı kartı ve TopBar çipi son 2 haftada (`WARNING_WEEKS`), son cevap (`funding.last_answer`) son haftada gelir. Süre dolunca teklif kapanmaz, karar haftası gelmiş olarak kalır ve `funding.sheet_decision` kartı cevap ister. Kart `interrupt` ve `critical`'dır, ertelenemez; iki seçeneği vardır: masaya otur (Series A masası açılır) ya da reddet (fon kalıcı olarak kapanır) (K10). Kart yalnız masanın açılabileceği bir saatte sorar (`funding.table_sitting_open`: gece değildir ve kurucunun mesai bitimine en az masanın süresi kadar vardır). Süresi aynı haftada dolan iki teklifin kartları sırayla gelir.

### 12.3 Yaz izni kağıt değildir

Yaz izni talebi `class: interrupt`'tır. Erteleme kağıt zamanlayıcısıyla değil, **kartın içinde bir seçenek** olarak yaşar (Ekip rev11 §11.4: ertele = −5 moral + 4 hafta sonra tekrar, max 2 kez; Ekip'in yazdığı 30 gün haftalık modelde 4 haftadır, `HRConstants.LEAVE_DEFER_WEEKS`). Karşında duran bir insana "sonra bakarım" demek bir karardır, zaman aşımı değil.

### 12.4 Süre dolumu semantiği

tik ≥ expires_on (günlük tikin başında):

```
  on_expire.effects çalışır
  history: resolution = "expired"
  expire_note ticker'a yazılır (oyuncu-sonucu önceliğiyle, §18)
  kağıt masadan kalkar
```

**`expire_note`** **zorunludur.** Sessiz süre dolumu yoktur. Örnek çıktı:

Zeynep bu hafta ayrıldı. Teklifi bekletmiştin.

**Bir hafta, haftanın sonuna kadardır.** Süre haftanın sonundaki 00:00 devrinde, günlük tikin başında dolar. Hafta içinde masaya düşen 1 haftalık kağıt yalnız o haftanın kalan saatlerinde bekler; 2 haftalık kağıt o haftayı ve bir sonrakini.

**Son uyarı (son hafta kuralı):** son haftasına giren kağıt (`weeks_left == 1`) kuyruğa `class: interrupt` olarak yeniden girer ve tempo bütçesi tanımaz (§13.5). Uyarı yalnız ömrü bir haftadan uzun kağıda gelir (`EXPIRY_URGENT_WEEKS`, 1). Ömrü tek hafta olan kağıt baştan "bu hafta" der ve ayrı uyarı almaz. Uyarı haftanın başında gelir, dolum bir sonraki tikte (§20 B11).

### 12.5 Kayıt/yükleme

`expires_on` **mutlak tik** olarak saklanır, "kalan hafta" olarak değil. Yüklemede tik geçmişse anında çözülür.

## 13. TEMPO

### 13.1 Teşhis

Sorun sayı değil, **benzerlik**. Haftada beş farklı konuda kart normal bir şirket haftasıdır. Haftada üç Nordica kartı bir bug gibi hissettirir. 4× hız bir ara bu sebeple kaldırılmıştı; haftalık modelde geri geldi (§11.5). Bir tik bir hafta olduğu için "hafta" burada motorun kendi birimidir: frenlerin hepsi tik sayar.

### 13.2 I4 — Hiçbir kart düşürülmez

Bütçe aşıldığında kart **atılmaz**, sunum sınıfı düşer:

interrupt → paper → [ASLA silinmez]

Kağıda inen her şeyin bir cevap süresi vardır (§12), yani unutulmaz.

`class: info` ve `class: ambient` zaten bütçe tüketmez.

### 13.3 Dört katmanlı fren

**Katman 1 — Aynı kart (****`min_gap_weeks`****)** Bir kart ateşlendikten sonra N hafta desteye dönmez. **Varsayılan 4** (`MIN_GAP_WEEKS_DEFAULT`). Kart override edebilir (nadir).

**Katman 2 — Aynı özne** Aynı çalışan / müşteri hakkında havuz kartı sıklık freni:

- Çalışan: **2 hafta** (`SUBJECT_GAP_EMPLOYEE_WEEKS`)
- Müşteri: **4 hafta** (`SUBJECT_GAP_CUSTOMER_WEEKS`)
**KRİTİK MUAFİYET:** Bu katman **yalnızca havuz kartlarına** uygulanır. `tag: critical` kartları ve **ark adımları muaftır.** Bir ark aynı çalışan hakkında art arda kartlar ateşleyebilir — arkın anlamı budur.

**Katman 1b — Aynı aile** Kart `family` taşır (§3.1). Aynı aileden BAŞKA bir kart N hafta desteye dönmez: **varsayılan 6** (`FAMILY_GAP_WEEKS_DEFAULT`), aile başına tablo `FAMILY_GAP_WEEKS`'te — ritim aileleri kısa, para aileleri uzun. Bir çalışanın para istediği üç ayrı kart bir ay içinde, haftanın hissi bakımından tek karttır. Kartın KENDİ dönüşü bu katmanın değil, Katman 1'in ve mandalın işidir. `follows` taşıyan zincir düğümü 1b'den muaftır: ebeveynine cevap verir, ailesinin ritmine değil.

**Katman 2b — Aynı aile, aynı özne** Kart `family_subject` taşırsa aynı aile aynı kişi ya da hesap hakkında bir kez (`{"once": true}`) ya da N haftada bir (`{"cooldown_weeks": N}`) konuşur. Bir aile iki kez haklı olabilir, ama aynı kişi hakkında iki kez haklı olması ayrı bir iddiadır.

**Köken muafiyeti.** 1b ve 2b'yi havuz, sessiz taban, sinyal ve zamanlama öder; ark, istek, `force_fire` ve `critical` kartları taşıyan tik süpürmesi bu iki katmanı hiç sormaz. Katman 1-3 yalnız havuzun kapısıdır.

**Erteleme — sinyal bir kez konuşur.** 1b, 2b ya da başlangıç koruması (§27.21) bir sinyal ya da zamanlama önerisini reddederse beat düşmez, TARİHLENİR: frenin kalan haftası kadar ileriye bir `SCHEDULE_DELAYED` girdisi kurulur (§27.19). Düşürmek, aralığın içinde riske giren ikinci hesabı kartsız bırakırdı. İstek muaftır, çünkü isteyen sistem reddedilen isteği haftaya yeniden açar; oradaki düzeltme kartta değil sistemdedir.

**Katman 3 — Kategori kotası (hafta başına, `CATEGORY_QUOTA_WEEK`)**

Pencere tek tiktir: kota yalnız bu tikin (bu haftanın) kabullerini sayar.

| Kategori | Haftada max |
|---|---|
| Ekip | 2 |
| Müşteri (B2B/B2C) | 2 |
| Ürün & canlı | 2 |
| Rakip & dünya | 1 |
| Yatırım / Frank | 1 |
| Kurucu | 1 |

Yan fayda: kota çeşitliliği zorlar. Müşteri kotası dolduysa motor başka kategoriye bakmak zorundadır; oyuncunun haftası tek renk olmaz.

**Katman 4 — Tik tavanı** Tik (hafta) başına max **2 interrupt** (`MAX_INTERRUPTS_PER_DAY`; ad korunur, bir oyun günü bir tiktir). Üçüncüsü kağıda düşer. Tavan dolarsa 1×'te 3 gerçek dakika sekiz hafta, yani 16 kesinti eder; bu, §13.7 çapasının (3) üstüdür. Harness bunu her hız için ölçer ve raporlar (§19.3).

### 13.4 Faz çarpanı

| Faz | Çarpan |
|---|---|
| Bootstrap | ×1.0 |
| Traction | ×1.3 |
| Series A Hunt | ×1.6 |

Katman 3 ve 4'e uygulanır. Katman 1 ve 2 sabittir (tekrar her zaman kötüdür).

### 13.5 Bütçe tanımayan üç şey

- `tag: critical` (omurga, ark dönüm noktaları, faz geçişleri)
- Terminal telgraflar
- Süresi dolmak üzere olan kağıdın son uyarısı

### 13.6 Taban — ölü zaman

**Tetiklenme koşulu (üçü birden):**

- 1 hafta (`FLOOR_QUIET_WEEKS`) boyunca hiçbir `interrupt` veya `paper` gelmedi (pencere tek tik olduğu için bu, günlük tikin kendi adımlarının hiçbir kart kabul etmemesi demektir), **VE**
- Masada cevaplanmamış kağıt **yok** (varsa ölü zaman yok; oyuncu erteliyor), **VE**
- Aktif bir modal yok
**Davranış:**

- Yalnızca **sessiz havuzdan** (`tag: quiet`) çekilir. Sessiz kart sıradan havuza girmez; her biri kendi `cooldown_weeks`'ini taşır (§27.11).
- Sessiz havuz kartları **kendi koşullarını geçmek zorundadır.** Kapı atlanmaz.
- **Hiçbiri uymuyorsa hiçbir şey ateşlenmez.** Sessizlik saçmalıktan iyidir.
- Katman 3 kotası tanınmaz; Katman 1 (`min_gap_weeks`) tanınır.
- `tutorial_active` iken devre dışı (§11.6).
**Sessiz kart yazım kuralları:**

- Mevcut duruma bakmak **zorundadır** (gerçek bir çalışan, gerçek bir müşteri, gerçek runway). Genel geçer olamaz.
- **Ekonomik etki taşıyamaz** (I2 zaten yasaklar).
- En fazla 2 seçenek, ikisi de düşük bahisli.
**Boş taban raporlanır.** Taban art arda 3 kez tetiklenip hiçbir kart bulamazsa, harness bunu **içerik açığı** olarak raporlar. Rastgelelikle örtülmez. Not: kart sayısı arttıkça tabanın tetiklenme ihtimali doğal olarak düşer; sessiz havuz için ayrı bir hacim hedefi konmamıştır.

### 13.7 Kalibrasyon çapası

Normal hızda ortalama **2-3 dakikada bir** karar yüzeyi. Hiçbir 3 dakikalık dilimde **3'ten fazla** interrupt yok.

Bu çapa auto-play harness'ında otomatik ölçülür (§19.3): binlerce koşuda "en yoğun 3 dakika" ve "en uzun sessizlik" raporlanır. Kalibrasyon gözle değil, veriyle yapılır.

Gerçek zaman ile oyun zamanı arasındaki bağ `TimeModel.seconds_per_tick`'tir. Varsayılan mesaide bir hafta 1×'te 22,5 sn sürdüğü için 3 dakika 1×'te 8, 2×'te 16, 3×'te 24, 4×'te 32 haftadır. Harness pencereyi her hız için ayrı hesaplar ve çapayı dört basamakta ayrı raporlar.

### 13.8 ⚠️ ÖLÇÜLMEDİ

§13.3, §13.4 ve §13.6'daki tüm sayılar **çalışma değerleridir ve hiçbiri ölçülmemiştir.** Kategori kotaları, faz çarpanları, 1 haftalık taban eşiği, 4/2 haftalık fren pencereleri: hepsi playtest'te değişecektir. Haftalık çeviri de ölçülmedi: gün değerleri 7'ye bölünüp anlamlı en yakın haftaya yuvarlandı (5 günlük taban 1 haftaya, kayan 7 günlük kota penceresi tek tike indi). §13.7 çapası bir ölçüm aracıdır, bir tasarım kanıtı değil. Bu sayılara mimari bağımlılık kurulmaz; hepsi tek bir tuning yüzeyinde toplanır.

## 14. SEÇİM VE HAVUZ

### 14.1 Tek mekanizma, iki davranış

Yazarın vereceği tek karar: **bu kart omurga mı, değil mi?**

```
tag: critical    → koşul sağlandığında gelir. Ağırlık yok, kota yok, atlanamaz.
(etiketsiz)      → havuza girer. weight varsayılan 1.0.
```

`weight` yazmak **zorunlu değildir.** Korpusun büyük çoğunluğunda boş kalır. Bir kartın belirgin şekilde daha nadir/sık olması istendiğinde tek satır eklenir.

**Ark adımları havuza giremez** (§10.10).

**"Bu hafta hiçbir şey."** Günlük çekiliş havuzun yanında sanal bir aday taşır: `POOL_NOTHING_WEIGHT` faz başına tek bir ağırlıktır (Bootstrap 1,5 · Traction 1,0 · Series A 0,6 [ÇALIŞMA]) ve zar ona düşerse o hafta havuzdan kart gelmez. Olmadığında deste kendini her sessiz haftaya boşaltır ve bir eşik ateşlenme tarihi gibi okunur; Bootstrap'in destesi ince olduğu için haftaları nefes almalı, Series A haftası kendi başına doludur. Saatlik çekiliş onu taşımaz: boş geçen bir saat her saattir, ağırlık ise hafta başına bir sayıdır. Taban bu ağırlığa tabi değildir: çekilen boş hafta masayı temiz bırakır, temiz masa da sessiz havuzun işidir (§13.6).

### 14.2 Neden bu ölçekleniyor

Demo ~30 kart → havuz ~20. EA ~50 → havuz ~35. Full 80+ → havuz ~60. Mekanizma hiç değişmez, yalnızca havuz büyür. `weight` alanının ilk gün yazılmamış olması sorun değildir; havuz büyüdükçe kendiliğinden değer kazanır. **Retrofit yoktur.**

**Yazım yükü: sıfır.** Bir tag, o da yazarın zaten bildiği bir ayrım.

### 14.3 Çekiliş

1. Kapıyı geçen havuz kartları toplanır

2. Katman 1/2/3 frenleri uygulanır

3. weight ile ağırlıklı çekiliş: hash(run_seed, day, "pool", n)

4. Seçilen kart Gate.admit'e gider

### 14.4 Tekrar oynanabilirlik nereden gelir

Kart sırasından **değil**. Oyuncunun kararlarının açtığı farklı ark ağaçlarından: alt-tip seçimi, işe alım havuzu, market tipi, hangi hatları yükselttiği. Havuz bunu tekrarlamaya çalışmaz.

## 15. SİNYAL KATMANI

### 15.1 Manifest

Her sinyal statik olarak kaydedilir:

```
signal_name              yayıcı modül       dinleyici(ler)      payload
hr.raise_requested       HR                 EventEngine         {employee_id}
product.shipped          Product            EventEngine, Ticker {product_id}
```

### 15.2 Lint kuralı

- Deklare edilmiş her sinyalin **en az bir emit noktası** olmalı.
- İçeriğin `{"signal": ...}` tetikleyicisi manifest'te var olmalı.
**Bugün canlı iki ihlal:** `raise_requested` ve `employee_eligible_for_promotion` deklare edilmiş ama hiç ateşlenmiyor. v1 bu ikisini kapatır.

### 15.3 Performans

Sinyal maliyeti ihmal edilebilir (~2300 emisyon = 1ms). Ancak **her frame poll yasaktır.** Kart uygunluğu yalnızca bağımlı olduğu bir seam değiştiğinde yeniden değerlendirilir (dirty-flag). Değerlendirme tik granülerliğinde koşar, frame'de değil.

## 16. KAYIT / ŞEMA

### 16.1 Serialize edilenler

event_engine:

```
  version: 1
  run_seed
  queue[]            {event_id, context, admitted_day, class}
  history[]          §7.1
  flags              {name: true}
  timed_flags        {name: expires_on_day}
  stamps             {name: stamped_day}
  schedule[]         {event_id, fire_on_day, context, arc_id}
  arcs[]             §10.1 tam durum
  papers             {örnek_anahtarı: {event_id, context, expires_on,
                      arc_id, opened_before, admitted_day, names}}   §20 E2, §27.12
  budgets            {name: kalan}
  tempo_window       en geniş fren penceresi kadar geriye (bugün 4 hafta)
                     ateşleme kayıtları
  held               §18 oyuncu-sonucu satırları
```

Adında `day` geçen alanlar ve `expires_on` tik tutar (bir oyun günü bir haftadır). Adlar kayıt uyumu için korunur (§27.9).

### 16.2 Zamanlanmış geri çağrı ASLA fonksiyon değildir

Yalnızca `{event_id, fire_on_day, context, arc_id}`. Fonksiyon pointer'ı / closure serialize etmek dangling pointer ve kod-yükleme açığı üretir. Davranış id'den yeniden çözülür.

### 16.3 Zaman mutlak

Tüm zaman alanları **mutlak tik**tir, "kalan hafta" değil. Bir tik bir oyun günüdür, bir oyun günü bir haftadır. Tek istisna yeni özne bekleyen arkın dondurulmuş adımlarıdır: onlar göreli hafta olarak (`remaining_weeks`) saklanır ve ark sürünce yeniden mutlak tike çevrilir (§10.5). Save/load, hız değişimi, toplantı atlaması ve gece atlaması zaman matematiğini bozmaz: atlamalar saatleri silmez, `TimeManager.advance_hours` ve `skip_night` ile simüle eder.

### 16.4 Migration

- Motor kendi bloğunu versiyonlar: `event_engine` kayıt şeması v10'da doğdu ve kendi `version`'ını (1) taşır. v10 öncesi kayıt taşınmaz; yükleyici onu açık mesajla reddeder (`SAVE_ERR_TOO_OLD`). Sürümü tutmayan blok boş motorla başlar, error.log'a yazar, crash etmez (C9).
- Yüklemede katalogda olmayan `event_id` bulunursa: kayıttan temizlenir, error.log'a yazılır, **crash edilmez**.
- Öznesi olmayan ark yüklemede iptal edilir (`fade`), gösterimde crash etmez.
- Bilinmeyen bayrak = false (additive namespace).
- v13 kayıtlarının motor bloğu `SaveManager._migrate_14`'ten geçer (`GDDs/GDD — ZAMAN MODELİ.md` §10): gün damgaları tike çevrilir, `frozen_schedule[].remaining_days` → `remaining_weeks` olur, `tempo_window` temizlenir. Bloğun kendi sürümü 1 kalır.

### 16.5 Ironman

Zor modda: tek slot, **karar anında oto-kayıt**. Modal açılmadan hemen önce kayıt alınır. Normal modda serbest quicksave/quickload.

**Modal içindeyken oyun kapatılırsa** (alt+F4 dahil): son kayıt modal öncesi olduğu için **karar tekrar sorulur.** Bu kabul edilmiş davranıştır.

## 17. LINT KURALLARI

Build'i durduran (**E**) ve uyaran (**W**) kurallar.

### 17.1 Yapı

- **E** Bilinmeyen seam adı
- **E** Bilinmeyen sinyal adı
- **E** Bilinmeyen event_id referansı (`schedule_event`, ark adımı, `history` yaprağı)
- **E** Bilinmeyen ark id'si
- **E** Tip uyuşmazlığı (employee effect'i customer slotuna)
- **E** GDScript'te hardcode tetikleyici (I5) — statik tarama
- **E** Kart ya da ark JSON'unda gün adlı anahtar ya da tanımlayıcı değer (`_days`, `days_since`, çıplak `days`). Süreler haftadır (§3.1)
- **E** Metinde presenter'ın çözemediği ya da kayıtlı olmayan seam'i okuyan `{seam:}` jetonu (§8.4)
- **E** Etiketsiz ya da `FinanceSystem.ONE_TIME_LABELS`'ta olmayan etiketli `add_cash` (§27.11)
- **W** Tanımsız bayrağa referans (yazım hatası yakalar)
- **W** Hiç okunmayan bayrak (ölü)

### 17.2 Ulaşılabilirlik

- **E** Ulaşılamaz koşul (`all: [flag X, flag_unset X]`)
- **W** Hiçbir yerden başlatılmayan ark (öksüz)
- **W** Hiç ateşlenemeyen kart (hiçbir tetikleyici/ark/sinyal göstermiyor). `tick: request` kartı, kodda bir sistem adını veriyorsa ulaşılabilirdir; adını hiçbir yerin vermediği request kartı ulaşılamazdır
- **W** Sonuca ulaşmayan ark adımı

### 17.3 Ekonomi (I2)

- **E** `add_cash` / `add_mrr` / `add_customer` / `add_brand` seçenek dışında
- **E** `on_expire` içinde pozitif ekonomik delta
- **E** `tag: quiet` kartında herhangi bir ekonomik delta

### 17.4 Telgraf (I3)

- **E** `trigger_ending` `requires_telegraph` olmadan
- **E** `is_loss_risk` etkisi `requires_telegraph` olmadan
- **E** Referans edilen telgraf event/flag katalogda yok

### 17.5 Zar (I6)

- **E** `check` dalında `trigger_ending`
- **E** `check` varken oran gösterimi kapalı

### 17.6 Ark

- **E** `type: promise` arkında `policy: fade`
- **E** `type: promise` arkında boş `on_invalidate.effects`
- **E** `invalidate_when` boş bırakılmış özneli ark
- **E** Ark adımı olan kart havuzda (§10.10)
- **E** İç içe ark derinliği 2'yi aşıyor
- **W** Biten arkı `restartable` olmadan yeniden başlatma çağrısı

### 17.7 Kağıt (§12)

- **E** `class: paper` ya da `class: interrupt` fakat `expires_weeks` yok
- **E** `class: paper` ya da tempo bütçesinin kağıda düşürebileceği interrupt, fakat `on_expire` yok
- **E** `on_expire` var fakat `expire_note` yok

### 17.8 Metin (iki dilde birden koşar)

- **E** `tr` veya `en` bloğu eksik
- **E** İki dilde farklı seçenek / outcome / modifier id kümesi (parite)
- **E** Eksik `locked_reasons` (kilitlenebilir seçenek için)
- **E** Yasaklı marka adı (Asana, Stripe, Slack, Product Hunt, X, ...) — **release blocker**
- **E** Kart gövdesinde tire (em/en/cümle-arası)
- **E** `tick: daily` kartında saat ifadesi
- **W** Metin uzunluğu UI eşiğini aşıyor

### 17.9 Suppression

- **E** `enqueue` / `enqueue_front` çağrısı (silinmiş API)
- **W** `min_gap_weeks` 1'in altında (kasıtlıysa suppress edilir)

### 17.10 Suppression iş akışı

Linter **baseline dosyası** destekler. Bilinen ve kabul edilmiş uyarılar `lint_baseline.json`'a yazılır; yalnızca yeni bulgular build'i keser. Aksi halde ekip linter'ı görmezden gelmeyi öğrenir.

### 17.11 Modifier (I7)

- **E** `modifier_lines` anahtarı `SeamRegistry`'de yok
- **E** `check` var ama `modifier_lines` boş
- **W** 4'ten fazla modifier tanımlı (fazlası gösterilmeyecek)

### 17.12 Kapsam slotları

- **E** Aynı tipten birden fazla slot var ama slot adları yazılmamış
- **E** `entity_seam` çoklu slot durumunda `scope` alanı taşımıyor
- **E** Effect hedefi tanımsız slota işaret ediyor

### 17.13 Makullük bloğu (şema v3)

- **E** `P2` Kartta `schema` alanı yok, yani §3.1'in makullük bloğu eksik. Kart öbür v3 kurallarına hiç sorulmaz
- **E** `P1` Blok `phase_band`, `headcount`, `product`, `modules` ya da `min_week`'i yazmamış; `phase_band` boş; `headcount` `[min, max]` değil; bant, `product` değeri ya da modül adı tanınmıyor
- **E** `P1` `family` yok — aile freninin tutacağı bir şey yok
- **E** `P1` `plausibility.product` ile `guards.product_live` farklı şey söylüyor
- **E** `P1` `system` olmayan kartta `delay_weeks` yok; `delay_weeks` `[0,0]` ama `delay_reason` yok
- **E** `P1` Kendi öznesini seçen employee ya da customer slotu var ama `subject_tenure_weeks` yok; taban 0 ama `fresh_reason` yok
- **E** `P1` `follows` bilinmeyen kartı adlandırıyor, ya da adlandırdığı kart bu kartı ne zamanlıyor ne de kart onun geçmişini okuyor
- **W** `P3` `min_week` demo penceresinin (130 hafta) dışında; `trigger.condition` yazılmış — motor onu değerlendirmez, kapı `condition`'ı okur

`version_scope` `fixture` ya da `retired` olan kart §17.13-17.15'ten muaftır, yalnız §17.1'in yapı kuralları koşar: fikstür bir kuralı bilerek kırmak için vardır, emekli kart yalnız eski kaydın kendi geçmişini okuması için durur.

### 17.14 Fiil yetkisi

- **E** `C1` `critical` etiketi `system` ya da `terminal_warning` olmayan kartta
- **E** `V1` Yazılamaz fiil: `EvEffects._apply`'da çalışan kolu ya da `EvChips`'te etiketi olmayan fiil. Seçeneğin verdiği söz ile oyuncunun gördüğü ve inen şey aynı olmak zorundadır
- **E** `V2` Ayrılmış fiil (`system` kartının fiili: faz, masa, ark, son) hikâye kartında. Koşuyu renklendiren kart koşuya karar vermez
- **E** `V3` `sprint_card_*` `tick: request` olmayan kartta

### 17.15 Seçenekler ve tekrar

- **E** `O1` Etkisi ve zarı olmayan seçenekte `status_quo_reason` yok (tek seçenekli kart ve `system` kart hariç)
- **E** `O2` Etkisi olan seçeneğin bedeli yok; bedava çıkış seçenek değildir
- **E** `O3` Tek kişilik kart (kurucu kartı ya da tek employee slotu) ekibin saatini ya da ekibin moralini harcıyor
- **E** `O4` Seçenek kartın anlattığı özneye hiçbir şey düşürmüyor
- **E** `O5` Modül harcayan fiil demo kartında, ya da modülün açıklığını `requires` etmeyen seçenekte
- **E** `T1` `employee_hired` kartı koşu kapsamlı `one_shot` taşıyor ya da `hr.run_hires` yaprağı okumuyor: onuncu işe alımda birincideki kadar yeni görünür
- **E** `T2` Çalışan hakkındaki kart `family_subject`'te `once` ya da en az 26 hafta cooldown istemiyor
- **E** `T3` `newest_hire` seçen slotun kıdem tabanı 8 haftadan az

`O2`, `O4`, `O5`, `T2` ve `T3`, şema v3 indiğinde ağaçta olan hikâye kartlarında uyarıdır: liste `tools/lint_v3_frozen.json`'dadır, büyümez, yeniden yazılan kart listeden çıkar. Sonradan yazılan kartta hepsi hatadır.

## 18. TICKER SÖZLEŞMESİ

### 18.1 Temel kural

**Ticker hiçbir bilginin TEK kanalı değildir.**

Anlamlı bir sonuç ticker'a düşüyorsa, aynı sonuç **history'ye de yazılmıştır**, ve vaat arkıysa ayrıca bir kart taşır. Ticker atmosfer ve **teyit**tir, teslimat kanalı değil. Aksi halde oyuncu kayarken kaçırdığı şeyi bir daha göremez.

### 18.2 Mekanik

- Motor tek çağrıyla besler: `EvTicker.push(line_key, priority, context)`. Satır `EventBus.headline_added` ile yayılır.
- Motorun **kendi kuyruğu ve kapasitesi yoktur**; kanalı haber akışı taşır. Ekrandaki şerit (`news_ticker.gd`) satırı hemen gösterir ve en yeni 6 canlı satırı tutar (`MAX_LIVE_LINES`).
- `NewsFeedSystem` aynı satırı "biz" tamponuna alır: 10 satır (`BIZ_BUFFER_CAP`), haftalık akışa (tik başına 3-5 satır, `WEEKLY_LINES_MIN/MAX`) en eskiden başlayarak ve akışın en çok beşte biri oranında (`BIZ_HARD_CAP`) boşaltılır. Tampon doluyken gelen **en yeni** satır tampona girmez (`biz_dropped` sayar); canlı şeritte zaten görünmüştür.
- **Yalnız canlı satırlar.** Ay kapanışı satırı (`MONTH_CLOSED_TICKER`: kapanan ay, MRR, nakit farkı) ve runway eşik satırı (`RUNWAY_CROSS_TICKER`) `EventBus.ticker_live_line` ile yayılır: şerit onları bir kez gösterir, "biz" tamponuna girmezler. `SummarySystem` ikisini günlük dağıtımın son yuvasında, sonların taramasından sonra yayar; koşu bittiyse yaymaz. Neden: tampon akışın en çok beşte biri oranında boşalır, haftalık tikte ise bir haftanın satırları birikir; ay satırı arşive sırası gelmeden taşardı.
- Oyuncu-sonucu satırları ayrıca `EvTicker`'da tutulur ve hiç düşmez (§18.3).
- Motoru **asla bloklamaz**, tempo bütçesi **tüketmez**.
- Save'e yazılan: `EvTicker`'ın tuttuğu oyuncu-sonucu satırları (§16.1 `held`) ve haber akışının durumu (`GameState.news_feed`: tampon ve akış).

### 18.3 Üç öncelik

```
1. oyuncu-sonucu    expire_note, ark fade izi, karar sonrası teyit
2. dünya / rakip    rakip hamlesi, sektör haberi
3. atmosfer         genel gürültü
```

**Oyuncu-sonucu satırları asla düşürülmez.** Tampon doluyken öncelik ayırt edilmez, en yeni satır arşive girmez (§18.2); oyuncu-sonucu satırı `EvTicker`'da kalır.

## 19. ARAÇLAR

### 19.1 Katalog doğrulayıcı

§17'nin tamamını koşar. CI yoktur: doğrulayıcı (`--event-lint`) elle koşulan kapı sırasının ilk adımıdır. `.githooks/pre-commit` onu koşar ama kanca etkin değildir; etkinleştirmek açık karardır (ACIK_KARARLAR). Baseline/suppress desteği (§17.10): kabul edilen bulgu gerekçesiyle `tools/lint_baseline.json`'a girer; o dosyayı yalnız `--event-lint=baseline` yazar, doğrulamada koşulmaz.

### 19.2 "Bu kart neden ateşlenmedi" paneli

Herhangi bir `event_id` için:

- Hangi kapı adımı düştü (G1–G8)
- Düşen koşul yaprağı ve o anki seam değerleri (§5.4'ün yapısal red gerekçesi)
- Latch durumu: son ateşleme günü, kalan cooldown
- Bekliyorsa: hangi sinyali, hangi arkı, hangi günü bekliyor
- Sinyal hiç emit edilmediyse **açıkça söyler**
- Ark adımıysa: arkın durumu, adımı, öznesi
Bu panel, kalibrasyon turunun ön koşuludur.

### 19.3 Auto-play harness — iki mod

Rastgele seçim uzun koşullu arkları asla tamamlayamaz; tek modlu harness ark tamamlanmasını ölçemez. Bu yüzden iki mod:

| Mod | Ne yapar | Ne assert eder |
|---|---|---|
| Rastgele | Binlerce koşu, rastgele seçim, seed'li | Crash yok · dangling ref yok · telgrafsız kayıp yok · tempo çapası tutuyor (§13.7). Kapsama bir W-raporudur, hata değil |
| Güdümlü | Her kritik ark için "niyet betiği": arkı tamamlamaya yönelen seçimleri yapar | %99 ark tamamlanma (E) · sıfır-ziyaretli ark adımı (E) |

**Niyet betiği** ark tanımından neredeyse otomatik türetilir: adım listesi + her adımda hangi `option_id`'nin ilerlettiği.

**Her iki modda ortak:** save/load her 7 haftada bir (`SAVE_EVERY_WEEKS`) enjekte edilir, koşu bozulmaz.

**Harness hafta hafta yürür.** Her hafta günlük tiki koşar, sonra varsayılan mesainin içinde üç saatte saatlik kartları süpürür (`SWEEP_HOURS`: 9, 13, 16; 17:00 varsayılan 09-17 mesaide gecedir ve kapı kritik olmayan saatlik kartı orada reddeder). Çağrı `--event-harness=random:seeds=N:weeks=M`; varsayılan koşu 52 haftadır.

**Çıktı raporu:** kart bazında ateşleme sayısı, kategori dağılımı, ortalama karar aralığı, en yoğun/en seyrek dilimler, boş-taban sayacı. Tempo çapası (§13.7) dört hız basamağının (1×, 2×, 3×, 4×) her biri için ayrı raporlanır, çünkü 3 gerçek dakika her basamakta farklı sayıda haftadır.

**Bilinen sınır:** rastgele mod gerçek oyuncu davranışını temsil etmez ve false positive üretir. Harness ulaşılabilirlik ve teknik bütünlük içindir; **denge için değildir.**

### 19.4 Adversarial konfigürasyonlar

Smoke'a eklenen sınır koşulları:

```
TEST_NO_EMPLOYEES     TEST_NO_CUSTOMERS     TEST_NO_PRODUCT
TEST_BROKE            TEST_MORALE_FLOOR     TEST_SOLO_FOUNDER
```

TEST_ALL_ARCS_ACTIVE  TEST_LANG_SWITCH_MID_RUN

TEST_TUTORIAL_ACTIVE

### 19.5 İşlenmiş örnekler

Motor task'ı **üç işlenmiş kart** teslim eder: bir `interrupt`, bir `paper`, bir ark adımı — her biri iki dilli metin bloğuyla tam.

Bunlar de facto şablon olur, ve daha önemlisi **şemanın gerçekten yazılabilir olduğunu kanıtlar.** Şema kâğıtta çalışıp pratikte tıkanırsa bunu ajanın plan aşamasında görmek isteriz, kart 12'de değil.

**Önden resmi şablon yazılmaz.** Gerçek şablon ilk birkaç kart yazıldıktan sonra, yazım turunda oluşur.

## 20. EDGE CASE MATRİSİ

### A. Kapsam ve varlık

| # | Vaka | Motorun cevabı |
|---|---|---|
| A1 | Kabul ile gösterim arasında çalışan istifa etti | Gösterim yeniden doğrulaması düşürür. History: dropped |
| A2 | Gösterim ile çözüm arasında özne kayboldu (save/load araya girdi) | Çözüm anında son varlık kontrolü. Düşerse kart kapanır, bilgi satırı bırakır |
| A3 | Ark öznesi ark ortasında gitti | §10.5 politikası: reassign / close / fade |
| A4 | İki ark aynı özneyi istiyor | Özne başına 1 aktif ark. İkincisi deferred, birincisi bitince proposal'a döner |
| A5 | Sıfır çalışan varken HR kartı | entity_count("employee") >= 1 guard'ı. Kurucu-tek koşusu için ayrı kart seti |
| A6 | Aynı tikte (aynı hafta) iki çalışandan zam talebi | Per-entity latch farklı anahtarlar; ikisi de geçerli. Katman 4 ikincisini kağıda düşürür |
| A7 | B2C koşusunda B2B selector | G6 guard. Kart market: b2b etiketli değilse kabul edilmez; selector tip-güvenli handle döndürür |
| A8 | Birden fazla ürün varken "ürün" belirsiz | Kapsam açık olmak zorunda. Belirsizse kabul edilmez |
| A9 | Kart öznesi kurucu | founder ayrı kapsam tipi; employee seçicisi asla kurucuyu döndürmez |
| A10 | Özne var ama uygun değil (izinde, atanmış) | Guard koşuluyla kart kendi uygunluk kriterini yazar |
| A11 | İki çalışan arasında çatışma kartı | İsimli slotlar (employee_a, employee_b). Aynı varlık iki slota atanamaz |
| A12 | Slot adları yazılmamış çoklu kapsam | E-lint (§17.12). Runtime'a hiç ulaşmaz |

### B. Zaman ve zamanlama

| # | Vaka | Cevap |
|---|---|---|
| B1 | Zamanlanmış tiki geçmişte kaldı (eski save) | fire_on_day <= bu tik → hemen proposal'a girer. Atlanmaz |
| B2 | Tek tikte birden fazla geçerli kart | §11.2 öncelik sırası. Deterministik |
| B3 | Bir etkinin sonucu başka kartın koşulunu doğru yapıyor | Kaskad bir sonraki tike ertelenir. Sonsuz döngü kapanır |
| B4 | Modal açıkken tik döndü | Modal zamanı durdurur; gece atlaması ve içindeki 00:00 devri modal kapanana kadar bekler |
| B5 | Faz geçişi ark ortasında | Ark faz-agnostik yaşar. Ölmesi gerekiyorsa invalidate_when açıkça yazılır |
| B6 | Koşu bitiyor (iflas) ama bekleyen ödemeler var | Terminal her şeyi keser. Schedule temizlenir, history korunur (son ekranı okur) |
| B7 | Build sürerken kurucuyu başka işe geçiren kart | Build bar auto-pause zaten kural. Kart bunu gövdesinde söyler; sürpriz olmaz |
| B8 | Hız 4×'te tempo | Bütçe tik (hafta) bazlı. 4×'te gerçek zamanda doğal olarak sık gelir; fazlası kağıda düşer |
| B9 | Aynı tikte hem schedule hem sinyal aynı kartı öneriyor | Latch tekilleştirir. İkincisi sessizce düşer |
| B10 | Gece saatlerinde interrupt | Mesai bitiminden 08:00'e kadarki saatler gecedir ve atlanır: G4 critical olmayan saatlik kartı gecede reddeder. Gündüz saatlerinde allowed_hours guard'ı; tanımsızsa 08:00-20:00 varsayılan (varsayılan 09-17 mesaide 17:00 ve sonrası zaten gecedir) |
| B11 | Kağıdın son uyarısı ile süre dolumu aynı tike denk geldi | Uyarı önce (öncelik 2), dolum bir sonraki tikte. Uyarı ateşlenemezse dolum yine de çalışır |
| B12 | Toplantı kapanınca saat ileri atlıyor (satış 2, pitch 2, masa 1 saat) | Saatler silinmez: `TimeManager.advance_hours` her atlanan saatin saatlik tikini koşar. Atlama kurucunun mesai bitiminde, en geç 23:00'te durur, gece yarısını geçmez; kalanını gece atlaması taşır. Atlama sürerken kart gösterilmez, adım bitince bir kez pompalanır (§11.3) |
| B13 | Ofis boşaldı, gece atlanıyor | Mesai bitiminden 08:00'e kadarki saatler tek toplu adımda simüle edilir (`TimeManager.skip_night`); 00:00 devri, günlük tik, ay dönmüşse ay kapanışı ve autosave bunun içindedir. Günlük tikte kabul edilen kartlar 08:00'de, en önemlisi önce gösterilir. Bir tutma alınırsa (kilometre taşı kağıdı) atlama durur, tutma kalkınca sürer |

### C. Kayıt ve şema

| # | Vaka | Cevap |
|---|---|---|
| C1 | Modal açıkken save | Kart dondurulmuş bağlamıyla serialize. Load'da yeniden doğrulanır (ya da A1) |
| C2 | Ark ortasında save/load | Ark nesnesi tam serialize: step, vars, subject, state, parent |
| C3 | İçerik güncellendi, eski save'de olmayan bayrak | Additive namespace; yok = false |
| C4 | Save'de artık olmayan event_id | Migration temizler, error.log, crash yok |
| C5 | Zamanlanmış geri çağrı | Asla fonksiyon. Sadece data |
| C6 | Save scumming | Zar hash(seed, day, event_id, option_id). Aynı seçenek = aynı sonuç. Ironman'de zaten tek slot |
| C7 | v10 öncesi kayıt | Taşınmaz. Yükleyici açık mesajla reddeder (SAVE_ERR_TOO_OLD) |
| C8 | Kağıt süresi save sırasında doldu | expires_on mutlak tik. Load'da geçmişse anında çözülür |
| C9 | Bozuk/eksik motor bloğu | Boş motorla başlar, error.log, crash yok. Koşu devam eder |
| C10 | Ironman'de modal içinde alt+F4 | Kayıt modal öncesi. Karar tekrar sorulur. Kabul edilmiş davranış |

### D. İçerik doğruluğu

| # | Vaka | Cevap |
|---|---|---|
| D1 | Olmayan seam | E-lint |
| D2 | Olmayan bayrak | W-lint |
| D3 | Ulaşılamaz koşul | E-lint |
| D4 | Öksüz ark / ölü kart | W-lint + harness raporu |
| D5 | Sinyal deklare, emit yok | E-lint (bugün 2 canlı ihlal) |
| D6 | Gerçek marka adı | E-lint. Release blocker motorda kapanır |
| D7 | Günlük-tik kartında saat | E-lint |
| D8 | Gövdede tire | E-lint |
| D9 | Dil paritesi bozuk | E-lint |
| D10 | Telgrafsız kayıp | E-lint + runtime assert |
| D11 | Seam'i olmayan modifier satırı | E-lint (I7) |
| D12 | check var ama modifier listesi boş | E-lint |

### E. Ekonomi ve sömürü

| # | Vaka | Cevap |
|---|---|---|
| E1 | K2 sınıfı bug (latch unutuldu, sonsuz kazanç) | Latch motorda. Yapısal olarak imkânsız |
| E2 | Aynı kart taze instance ile iki kez sırada | Örnek anahtarı bazlı dedupe: run anahtarlı kartta event_id, entity anahtarlı kartta event_id@özne. Aynı kartın iki öznedeki örnekleri yan yana durur (A6), aynı özne için örnek tektir. Kağıdı masada bekleyen örnek yeniden önerilirse reddedilir, mandalı harcanmaz |
| E3 | Ambient tikten para | I2 + lint |
| E4 | Gösterimde karşılanabilirdi, tıklamada değil | Çözüm öncesi son kontrol. Seçenek grileşir ve nedenini yazar |
| E5 | Kilitli seçenek neden kilitli | §5.4 yapısal red gerekçesi → locked_reasons |
| E6 | Zar balıkçılığı | option_id hash'te. Aynı seçenek = aynı sonuç |
| E7 | Kağıdı bekletip bedava avantaj | Her kağıdın süresi var; on_expire bedel uygular |
| E8 | Bütçe tükendi ama seçenek görünüyor | Bütçe kontrolü requires içinde; seçenek kilitlenir |

### F. Sunum ve UI

| # | Vaka | Cevap |
|---|---|---|
| F1 | Pause'dayken modal tıklanamıyor | process_mode = ALWAYS (3) — her spec'te zorunlu satır |
| F2 | Aynı anda iki modal | Tek modal; ikincisi kuyrukta |
| F3 | Masada çok kağıt birikti | Her kağıdın süresi var; kendiliğinden temizlenir |
| F4 | Demo'da kilitli kategori kartı geçerli oldu | G2 reddeder. Görünür-kilitli telgraf UI işi, ark değil |
| F5 | goto_tab hedefi kilitli | No-op + W-lint |
| F6 | Dil koşu ortasında değişti | Kuyruk metin saklamaz. Masadaki kağıt yeni dilde görünür |
| F7 | Modifier listesi 4 satırı aştı | En büyük 4 gösterilir, kalanı "ve diğerleri" |
| F8 | Ticker'a aynı anda çok satır | Haber akışı taşır (§18.2); tampon doluyken en yeni satır arşive girmez, oyuncu-sonucu `EvTicker`'da kalır |
| F9 | Oyuncu yüzdeyi hover etmiyor | Yüzde zaten görünür. Modifier bilgisi opsiyonel derinliktir |
| F10 | tutorial_active iken normal kart geçerli oldu | G2 reddeder. Havuz ve taban susar |

### G. Ark özel

| # | Vaka | Cevap |
|---|---|---|
| G1 | Ark adımı tempo kotasına takıldı | Ark adımları bütçe tanımaz (§13.5) |
| G2 | awaiting_subject sonsuza kadar sürüyor | 2 hafta sonra otomatik close |
| G3 | Ark iptal oldu ama zamanlanmış adımı Schedule'da | abort_arc kendi schedule girdilerini temizler |
| G4 | İki ark aynı bayrağı yazıyor | Bayraklar global. Ark-özel durum arc.vars'ta yaşar |
| G5 | Ark öznesi geri geldi (eski çalışan tekrar işe alındı) | Yeni varlık = yeni id. Ark yeniden bağlanmaz (§10.9) |
| G6 | Vaat arkı faz geçişiyle anlamsızlaştı | invalidate_when yazar; close politikası görünür kartla kapatır |
| G7 | Aynı ark id'si iki kez başlatıldı | No-op + W-log. Ark id'leri koşu başına tekil |
| G8 | Biten ark yeniden başlatılmak isteniyor | Reddedilir, restartable: true yoksa |
| G9 | İç içe ark: çocuk iptal oldu | Ebeveyn yaşamaya devam eder |
| G10 | İç içe ark: ebeveyn iptal oldu | Çocuklar da iptal edilir, her biri kendi politikasıyla |
| G11 | Ark adımı olan kart havuzda ateşlendi | Mümkün değil — E-lint (§10.10) build'de keser |

## 21. İÇERİK ↔ MOTOR ARAYÜZÜ: DELTA

### 21.1 Kural

Her event yazım partisi bir **DELTA çıktısı** üretir:

DELTA — <parti adı>

```
  Yeni seam ihtiyacı:      [liste, sahibi modülle birlikte]
  Yeni effect fiili:       [liste]
  Yeni ark tipi/politika:  [liste]
  Yeni sinyal:             [liste]
  Yeni kategori/tag:       [liste]
```

### 21.2 Neden

İçeriğin motordan **sessizce** özellik talep etmesini engeller. İçerik "bunu istiyorum" der, motor "tamam, şu kalem eklenir" der. İkisi arasındaki arayüz bu listedir.

Aksi halde yazar bir kart yazar, kart bir seam ister, seam yoktur, ve ya kart susar ya da biri tetikleyiciyi GDScript'e taşır (I5 ihlali).

### 21.3 İş akışı

kart yazımı → DELTA → motor task'ı (kalem ekle) → kart implementasyonu

DELTA boşsa doğrudan implementasyona geçilir.

## 22. EMEKLİLİK VE GÖÇ

### 22.1 İlke

Yeni mühürlü metin eski kartın **yerine geçer**, yanında çalışmaz. Bir anın iki versiyonu varsa biri unutulur.

### 22.2 Adımlar

- **Envanter.** Mevcut tüm çağıran ve seçim noktalarının taze sayımı. (6 Ağustos audit'i bayat: o günden bu yana Ürün rev6.1, Ekip rev11, Ar-Ge rev1.4 indi.)
- **Sınıflandırma.** Her mevcut kart: `taşı` / `yeniden yaz` / `sil`.
- **Taşıma.** Yeni şemaya çevir, id ver, latch'i motora devret, hardcode tetikleyiciyi koşula çevir.
- **Smoke repoint.** Emekli kartlar üzerinden sonlara ulaşan smoke case'leri yeni kartlara yönlendirilir, **silinmez**.
- **`enqueue`** **silme.** Son adım. Silindikten sonra lint E-kuralı devreye girer.

### 22.3 Bilinen göç yükleri

- 12 çağıranın elle yazdığı private latch → motora devir
- K2 (Büyüt: bir tık, sonsuz +$720 MRR/gün) → latch + I2 ile kapanır
- `mvp_market_type` günlük yol boşluğu → G6 guard'ı
- Gerçek marka adları (RivalCatalog + event copy) → D6 lint
- `END_META_BANKRUPTCY_FRANK` "yedi gün" ↔ `SHUTTER_DAYS: 30` (bugün `SHUTTER_WEEKS` 4) → seam interpolasyonu
- `raise_requested` ve `employee_eligible_for_promotion` sinyalleri → emit noktaları açılır

## 23. AÇIK MADDELER

Bu GDD'nin **bilinçli boşlukları**. Hiçbiri motorun inşasını bloklamaz.

| # | Madde | Durum | Motorla ilişkisi |
|---|---|---|---|
| A1 | Sonlar (slot 8/9) | Tasarlanmadı | Motor tag: critical ark iskeletini taşır. Tasarlandığında o modülün task'ına "motora bağla" maddesi konur. Motorda değişiklik gerekmez. Faz geçişleri ve Series A kapısı bağlıdır: PhaseGateSystem kapıyı günlük tikte sınar ve mandallar; critical kartlar `funding.gate_traction` ve `funding.gate_series_a` mandalı seam'lerden okur (`phase.gate_ready`, `funding.gate_pending_phase`); geçiş oyuncunun kartta onayıyla `GameState.advance_phase()`'ten olur. Series A kapısının tek şartı `finance.mrr ≥ SalesSystem.TRACTION_MRR_TARGET`'tır (K1–K2) |
| A2 | Tam seam envanteri | Motor task'ının ilk teslimatı (§6.3) | Ajan docs/SEAM_REGISTRY.md üretir; eksikler modüllere dosyalanır |
| A3 | Seed round tasarımı | Frank surface 12 metinsiz | Yatırım arkının omurgası; ark iskeleti hazır |
| A4 | Pazarlık sistemi | Ayrı sistem | open_negotiation sözleşmesi GEÇİCİ damgalı (§9.4). Tasarlandığında motorda değişiklik yok |
| A5 | Ürün §15 talep üreteci, §14 taban merdiveni | Bu pakete ait, ele alınmadı | Etki sözlüğüne kalem ekleyebilir → DELTA (§21) |
| A6 | Kalibrasyon sayıları | ⚠️ ÖLÇÜLMEDİ (§13.8) | Playtest turu. Tek tuning yüzeyi |
| A7 | Tutorial akışı | Tasarlanmadı | Motor kancayı taşır (§11.6). Tasarlandığında motorda değişiklik yok |
| A8 | Kart yazım şablonu | Bilinçli olarak yazılmadı | Üç işlenmiş örnek (§19.5) de facto şablondur; gerçek şablon yazım turunda oluşur |
| A9 | B2C destek hattı | Park edilmiş tasarım | "Olay canlı bug düzeltir" (K3) etki kalemi doğuracak → DELTA |
| A10 | Modifier UI görseli | Mockup fazının işi | §9.6 davranışı tanımlar; görsel gerçek ekran → Claude Design → F5 → piksel-sadık uygulama zincirinden geçer |

## 24. İNŞA SIRASI

| Aşama | İçerik | Bitiş testi |
|---|---|---|
| 0 — Envanter | docs/SEAM_REGISTRY.md (§6.3) | Beş modülün seam durumu VAR/OKUNUYOR/YOK olarak listelenmiş |
| 1 — Omurga | Tek kapı, latch, history, koşul sözlüğü, isimli slotlar | İçerik chose(ev_x, opt_y) sorabiliyor; enqueue yok |
| 2 — Ark ve erteleme | Ark nesnesi, üç iptal politikası, iç içe ark, Schedule, seam registry, sinyal manifest | 10. gündeki seçim 90. günde kart doğuruyor; arada save/load var; ark hayatta |
| 3 — Sunum ve tempo | Presenter, 4 sınıf, ODA masası, süre dolumu, 4 katman fren, taban, kilitli seçenek, telgraf invariant'ı, ticker, tutorial kancası | Tam koşuda ne ölü zaman ne modal spam |
| 4 — Zar | check, deterministik türetme, modifier gösterimi (hover) | Reload aynı sonucu veriyor; farklı seçenek farklı sonuç |
| 5 — Araçlar | Linter (baseline'lı), "neden ateşlenmedi" paneli, iki modlu harness, üç işlenmiş örnek | Güdümlü modda kritik arklar %99+; rastgele modda crash/dangling/telgraf temiz |
| 6 — Göç | Envanter, taşıma, smoke repoint, enqueue silme | Eski motor kaldırıldı, mevcut smoke suite yeşil |

**Aşama 2'nin bitiş testi geçilmeden Aşama 3'e geçilmez.** O test oyunun tezinin kanıtıdır.

## 25. RAPORDAN BİLİNÇLİ SAPMALAR

Araştırma raporunun önerdiği ama reddettiğimiz kalemler. Kayda geçsin ki ileride "bu neden yok" sorusu tekrar açılmasın.

| Rapor önerisi | Karar | Gerekçe |
|---|---|---|
| Rimworld-tarzı storyteller / director | Red | Gerilim eğrimiz faz + ekonomide. Dinamik yoğunluk ayarı "kararım oyunu değiştiriyor" hissini bozar; kalibrasyon yasası 3'e aykırı |
| MTTH (mean time to happen) | Kısmen | Haftalık şans reddedildi: CK3 kendisi terk etti (performans + istatistiksel anomali). Yerinde deterministik gecikme penceresi var (§27.19): bekleme kart kurulurken bir kez çekilir, her hafta zar atılmaz |
| Paradox-tarzı custom DSL + parser | Red | JSON ağacı aynı işi yapıyor, onda bir iş |
| Türkçe suffix helper | Red | İki dili elle yazıyoruz; yazım disiplini daha temiz metin üretir |
| ODA masası kapasite tavanı | Red | §12.1 (her kağıdın süresi var) sorunu zaten çözüyor |
| Deste doldurma / dinamik zorluk | Red | Görünmez zorluk ayarı opaktır; kalibrasyon yasası 1'e aykırı |
| İki zar tipi (check + band) | Red | band pazarlık sisteminin mekaniği, motorun zar tipi değil (§9.4) |

## 26. rev1 → rev2 DEĞİŞİKLİK KAYDI

| # | Değişiklik |
|---|---|
| 1 | I7 eklendi: modifier = seam. Seam'i olmayan modifier yazılamaz (§9.7, §17.11) |
| 2 | Modifier gösterimi hover'a alındı. Yüzde görünür + farklı renk tonu; liste hover'da (§9.6) |
| 3 | band zar tipi kaldırıldı. Tek tip: check. Aralık gösterimi sunum detayı (§9.4) |
| 4 | İsimli kapsam slotları eklendi. Çoklu-özne kartları baştan destekli (§4.3, §5.2, §17.12) |
| 5 | Seam envanteri motor task'ının ilk teslimatı oldu (§6.3); seam sözleşmesi her modül task'ına standart madde olarak girdi (§6.4) |
| 6 | Harness ikiye ayrıldı: rastgele (kapsama = uyarı) + güdümlü (ark tamamlanma = hata) (§19.3) |
| 7 | Ticker sözleşmesi yeni bölüm oldu (§18). Ticker asla tek kanal değildir |
| 8 | Tutorial kancası eklendi (§11.6). Akış tasarlanmadı, suppression modu ayrıldı |
| 9 | Dört ark kuralı eklendi: iç içe max 2 (§10.8), tekillik + restartable (§10.9), ark adımı havuza giremez (§10.10) |
| 10 | §21 DELTA arayüzü yeni bölüm. İçerik motordan sessizce özellik talep edemez |
| 11 | §19.5 üç işlenmiş örnek motor task'ının teslimatı oldu; önden şablon yazılmayacağı kayda geçti |
| 12 | §13.8 ÖLÇÜLMEDİ damgası eklendi. Kalibrasyon sayılarına mimari bağımlılık kurulmaz |
| 13 | §25 bilinçli sapmalar bölümü eklendi |
| 14 | §26 değişiklik kaydı eklendi |
| 15 | Edge case matrisi 51 → 63 vaka (A11-A12, B11, C10, D11-D12, F9-F10, G7-G11) |
| 16 | Açık madde listesi güncellendi: Z2 (faz), Z3 (sessiz havuz hacmi), Z7 (modifier UI), Z12 (alt+F4) kapandı; A7 (tutorial), A8 (şablon), A10 (modifier UI) yeni girdi |
| 17 | Ironman + alt+F4 davranışı yazıldı (§16.5, C10) |
| 18 | Maksimum hız 3x olarak kayda geçti (§11.5) |

rev 2 — 25 Ağustos 2026 — İNŞA SÜRÜMÜ

---

# 27. İNŞA NOTLARI (kod tarafından yazılır)

Bu bölüm İNŞA SIRASINDA doldurulur ve kuralı Ürün rev 6.1 §24'ünkiyle aynıdır:
**inşa sırasında GDD öncüdür, inşa bittiğinde KOD öncüdür.** Aşağıdaki maddeler,
yapılanın belgeden ayrıldığı ya da belgenin sessiz kaldığı her yeri kaydeder.
Yalnız bu belgeyi okuyan biri motorun ne yaptığını buradan da öngörebilmelidir.

Her madde şu üçünü taşır: **belge ne diyordu · ne yapıldı · neden.**

*(Aşama 0'da açıldı; maddeler inşa ilerledikçe eklenir.)*

### §27.4 · Şemaya eklenenler (inşa sırasında, gerekçeli)

Bunlar GDD'nin §3.1 kart şemasında YOKTU ve inşa sırasında eklendi. Her biri, olmadığında
motorun ya bir davranışı kaybettiği ya da bir yalanı temsil edebildiği bir yeri kapatıyor.
Kuralları artık gövdededir (§3.1, §3.2, §4.1, §4.3, §11.4, §16.1, §20 E2); burada gerekçeleri durur.

**`tick: "request"` — hiçbir saatin süpürmediği kart.** Beş kart ailesi, yalnız bir SİSTEMİN
görebildiği bir kenarda ateşleniyor: destek talebinin yaşlanması, sürümün yayına çıkması,
tasarım turunun bitmesi. Bunlar için sinyal de havuz da yanlış cevap — sinyal, kartın kendi
sonucunun yaydığı sinyali beklemek anlamına geliyordu (bkz. §27.5); havuz ise otoriter bir
beat'i ağırlıklı çekilişe bırakmak. `tick: "request"` "beni hiçbir saat süpürmez, adımı veren
bir çağıran tek kapıdır" demektir. Süpürme ve havuz onu zaten dizge eşleşmemesiyle atlıyor, o
yüzden ek kod gerekmedi; eklenen tek şey `Origin.REQUEST` ve G4'te ONA AİT BOŞ KOL.

**`Origin.REQUEST` G4'ün tick eşleşmesini ATLAR** (`allowed_hours` ve build-safe yine uygulanır). `tick`, kartı KİMİN SÜPÜRDÜĞÜNÜ söyler,
kartın adını kimin verebileceğini değil. Satış sekmesinin iki düğmesi `tick: daily` bir kartın
adını verir ve vermelidir; aksi hâlde adı verilen her kartın ayrıca süpürülmesi gerekirdi, ki
bu tam olarak yeniden inşanın sildiği İKİNCİ KABUL YOLU'dur.

**`text.<locale>.body` bir SÖZLÜK olabilir: `{by_seam, variants}`.** Series A kapısı kendi
gövdesini reddetme sayısına göre yeniden yazıyordu (eski `_refresh_gate_copy`), yani varyant
metin şema onun için bir kelimeye sahip olmadan ÖNCE oyunda vardı. EVENT_POOL_DESIGN_v1 §5.7'nin
dar teslimi: genel bir tesis değil, ihtiyacı olan tek kart için. Seçim kuralı §3.2'dedir: aralığı
aşan seam son gövdede kalır, aralığın altındaki ilk gövdeyi alır; hiçbiri boş kart vermez.

**`{seam:ad.soyad}` metin içinde.** §8.4'ün mekanizması. Sebebi yayınlanmış bir hata:
`END_META_BANKRUPTCY_FRANK` "Yedi gün kırmızıda kaldın" diyor, `SHUTTER_DAYS` ise Frank v6'dan
beri 30. Düzyazıya yazılmış bir sayı sessizce bayatlar ve hiçbir kapı bunu yakalayamaz.
Seam'den okunan sayı bayatlayamaz. B2B ailesi aynı şeye DÜZYAZI için ihtiyaç duyuyor: şikâyet
gövdesi sektöre göre değişiyor, o yüzden tek kart `{seam:musteri.complaint_voice}` taşıyor —
her biri bir sektörün cümlesini gömen on beş neredeyse-aynı kart yerine.

**`scope.<slot>.select` seçicileri.** §4.3 hiçbir seçici adlandırmıyordu; inşa on iki tane ekledi
(liste §4.3'te): `lowest_morale` ve `newest_hire` Ekip §17.3'ün adlandırdıklarıdır, öbürleri
kartların ihtiyacından doğdu (`escalated`, `open_request`, `decision_sheet` …). Gerekçe yapısal: **koşul, BAĞLANMIŞ
TEK özneye karşı sınanır.** "En mutsuz hesabı seç, sonra tırmandırılmış mı diye sor" — bu iki
farklı müşteri olduğu her gün sessizce hiç ateşlenmez ve hiçbir yer bunu söylemez. Seçici,
koşulun soramayacağı soruyu sorar: hangi özne.

**`_select` artık ÖNCEKİ slotları görür (`bound`).** `account_rep` "bu kartın zaten bağladığı
müşterinin temsilcisi" demektir ve bunu söylemenin başka yolu, çağıranın seçimi kendisinin
yapmasıdır — §4.3'ün durdurmak için var olduğu şey.

**Bir kartın örneği mandal anahtarıyla tanınır.** Belge: §20 E2 "aynı kart taze instance ile iki
kez sırada → id bazlı dedupe"; A6 "aynı gün iki çalışandan zam talebi → ikisi de geçerli, Katman
4 ikincisini kağıda düşürür"; §16.1 `papers[] {event_id, …}`. Yapılan: kuyruk, masa, günün
kabulleri ve `force_fire` işareti kartı `EvLatches.key_of` ile tanır (run anahtarlı kartta
`event_id`, entity anahtarlı kartta `event_id@özne`); E2'deki "id" bu anahtar olarak okunur ve
masa anahtar → {event_id, …} olarak saklanır. Kağıdı masada bekleyen örneği sinyal, tarama ya da
havuz yeniden önerirse reddedilir, çünkü §13.5'in bütçe muafiyeti yalnız kağıdın son gün
uyarısınındır; `EventGate.request` aynı örneği isterse bekleyen kağıt açılır (§11.4). Neden:
`event_id` kimliği A6'nın ikinci öznesini yutuyordu; aynı gün Risk'e giren ikinci hesabın elde
tutma kartı, aynı tikte istifa eden ikinci çalışanın kartı kayboluyordu. §27.5 madde 2'deki kişi
başı mandal da ancak bu kimlikle tam çalışır: `event_id` kimliğinde, birinci yatırımcının
uyarısı beklerken önerilen ikincisinin örneği kuyrukta yine yutulurdu.

**Üst düzey `expire_note`, metin bloğundaki satırın ADIDIR.** Belge: §3.1 kartın üst düzeyinde
`expire_note`'u "süre dolumunda ticker'a yazılan satır" diye tanımlıyor, §3.2 aynı adı locale başına
metin bloğuna koyuyor; ikisinin ilişkisini yazmıyor. Yapılan: kartın üst düzeydeki `expire_note` alanı,
metin bloğundaki (§3.2) satırın adıdır. Motor satırı canlı dilde çözer ve kartın slotlarıyla doldurur.
Bloğunda o ad yoksa değer satırın kendisi sayılır. Neden: üst düzey alan dilsizdir; satır iki dilde ve
`{customer}` gibi slotlarla yazılır, ticker'a ham ad düşmemelidir (§12.4).

---

### §27.5 · Portun açığa çıkardığı, motora ait OLMAYAN kusurlar

Bunlar taşıma sırasında bulundu. Hiçbiri yeni motorun kusuru değil; her biri eski motorun
biçiminin sakladığı bir şeydi.

1. **Kendi sonucunun yaydığı sinyalle tetiklenen dört kart.** `employee_departed`,
   `CharacterRegistry.remove` tarafından yayılır — `team.resignation`'ın kendi seçeneğinin
   ÇAĞIRDIĞI şey. `version_shipped`, `ship_active_build`'in SONUNDA yayılır. Her biri, koşu
   boyunca bir adım geç ateşlenirdi.
2. **`_build_expiry_warning_event` SABİT bir id yazıyordu.** İki canlı term sheet varken ikinci
   uyarı kuyruğun dedupe'ında sessizce yutuluyor ve hayatta kalan kart YANLIŞ yatırımcının son
   tarihini söylüyordu. Kart artık bir yatırımcı slotu bağlıyor ve mandalı KİŞİ BAŞINA.
3. **`funding.last_answer`'ın portu bir açımlamaydı.** `sheets_live > 0 AND days_left <= 1`
   makul görünüyor ve yanlış: iki masa canlıyken de doğru — yani cümlenin söylenmemesi gereken
   TEK durumda. Yüklem `VCPitchSystem.is_last_answer_moment()` olarak sistemde kaldı.
4. **Kart metinlerinin 41 anahtarı yazım sırasında yeniden adlandırılmıştı**, hiçbirinin CSV
   satırı yoktu. Ekranda 41 ham BÜYÜK_HARF token'ı. 34'ü zaten var olan satırlara geri
   yöneltildi, 7'si iki dilde yazıldı.
5. **Söz ve indirim satırları kilitsiz taşındı.** Eski kurucular satırı KURMAYARAK saklıyordu;
   kart artık veri, dolayısıyla satır var ve KİLİTLENMELİ (§17.5). Kilitsiz hâlde üç talep
   kartı, retention kartının kapattığı kanaldan sınırsız söz ve sınırsız indirim üretirdi.
6. **`churn_customer` `remove`'a düzleştirilmişti.** Eski yürütücünün B2C kolu vardı: B2C tek
   toplu kayıttır, churn KİTLEYİ aşındırır. Düzleşmiş hâliyle tek bir tüketici şikâyeti bütün
   B2C işini silerdi.
7. **`event_modal._describe_modifier` `type` okuyordu; kartlar `verb` taşıyor.** Kırk kartın
   her çipi boş çıkardı — EFFECT-VISIBILITY kuralının tek seferde kırk ihlali, ve onu yakalayacak
   hiçbir şey yoktu. Artık `verb` önce okunuyor, altı yeniden adlandırma için takma ad tablosu
   var, ve `SILENT_VERBS` listesi "tabloda yok" demeyi bir HATA hâline getiriyor:
   `event_chip_coverage` case'i her kart satırını yürüyor.


---

### §27.6 · §17'ye eklenen üç kural (inşa sırasında, gerekçeli)

**§17.3'ün DÖRDÜNCÜ maddesi — `class: ambient` bir kart para taşıyamaz.** Yürütücünün köken
tabloları I2'nin duvarıdır, ama tablolar efekt listesinin NEREDEN geldiğine bakar: bir
seçeneğin efektleri, kartın sınıfı ne olursa olsun, her zaman `played` olarak koşar. `ambient`
bir kart ise ticker satırıdır — oyuncu ona cevap VERMEZ — yani üstündeki seçenek hiç
oynanmaz, dolayısıyla üstündeki para kararı olmayan paradır. Yürütücü bunu göremez; gördüğü
şey herhangi bir seçenek listesidir. I2'nin lint olmak ZORUNDA olan tek yarısı budur ve bunu
söylemek, duvarın tam olduğunu varsaymaktan iyidir.

**§17.9 kendi tanımını raporlamaz.** Silinen kabul API'sini arayan tarama yorum satırlarını
atlıyordu — dört tarihsel anmayı raporun dışında tutan da buydu — ama iğneyi TANIMLAYAN satırı
atlamıyordu. Kural silahlandığında linter temiz bir ağaçta yalnız kendi kaynak satırını
raporlardı, ki bu bir ekibe linter'ı görmezden gelmeyi öğretmenin en hızlı yoludur (§17.10'un
var olma sebebi). `res://scripts/events/tools/` taramadan çıkarıldı.

**§17.2 `tick: request` kartını ulaşılabilir sayar — bir sistem onun adını veriyorsa.** Bu
kartın sözleşmesinin tamamı budur: onu bir çağıran ADLANDIRIR. Ulaşılabilirlik sorusu bu yüzden
KOD hakkında bir sorudur, ve silinen API'yi bulan aynı statik tarama onu da cevaplayabilir.
Adını hiçbir yerin vermediği bir request kartı GERÇEKTEN ulaşılamazdır ve kural bunu hâlâ
söyler.

---

### §27.7 · Linter'ın ilk koşusunun bulduğu şey

**YUMUŞAK TAVAN MERDİVENİ HİÇ KOŞAMAZDI.** `world.final_stretch_press` hem
`arc_final_stretch`'in BİRİNCİ ADIMI hem de o arkı başlatabilecek tek şeydi. §10.10 bir ark
adımını havuzun dışında tutar: adım, ark başlamadan ateşlenemez; ark, adım ateşlenmeden
başlayamaz. Linter bunu "ark hiçbir kart tarafından başlatılmıyor" diye bildirdi — aynı kilit,
öbür taraftan söylenmiş hâli.

Bu, görevin özellikle yapılmasını istediği tasarım kararının (kusur 8) TAMAMININ ağaçta
ulaşılamaz içerik olarak durması demekti. Üç kapı, bir probe ve 278 vakalık bir süit, hiç
ateşlenemeyecek bir beat'in üstünden geçti; §17.2'nin ulaşılabilirlik kuralı onu ilk koşusunda
buldu. Linter'ın niye var olduğunun en açık kanıtı budur ve deftere böyle geçer.

Çözüm: gazete kartı adım listesinden ÇIKAR ve arkın AÇICISI olur — okunduğunda da, okunmadan
süresi dolduğunda da arkı başlatır. Sektörün yoluna devam etmesi, kurucunun bunu okumasına
bağlı değildir.

---

### §27.8 · Seam envanteri (§6.3) inşada tamamlandı; güncel liste üretiliyor

**Belge ne diyordu.** §6.3, Aşama 1'den önce ajanın ürettiği bir envanter istiyor:
`docs/SEAM_REGISTRY.md`, her satırda VAR / OKUNUYOR / YOK; YOK satırları sahibi modülün açık işi
olarak dosyalanır. §6.4'ün sözleşme maddesi, §23'ün A2 satırı ve §24'ün Aşama 0 satırı aynı
dosyayı anıyor.

**Ne yapıldı.** Envanter inşa sırasında tamamlandı. Seam'ler kodda `scripts/events/seams/`
altında (`EvSeams`) kayıtlıdır. Güncel seam listesi elle tutulmaz: `--event-vocab` onu bu
kayıttan üretir ve `docs/content/events_draft/_vocabulary.md` §b'ye ("Seams — everything a
condition may read") yazar. `docs/SEAM_REGISTRY.md` ağaçtan kaldırıldı; son hâli git
geçmişindedir (`git show 6e3e190:project-unicorn/docs/SEAM_REGISTRY.md`).

**Neden.** Elle tutulan dosyayı hiçbir kapı kodla karşılaştırmıyordu; üretilen liste her
`--event-vocab` koşusunda koddan yeniden yazılır. §6.3, §6.4, §23 ve §24'ün metni değiştirilmedi.
§b'de VAR / OKUNUYOR / YOK sütunu yoktur: listede yalnız kayıtlı seam'ler durur. Envanterin hâlâ
açık YOK satırları `docs/ACIK_ISLER/ACIK_KARARLAR.md`'dedir.

---

### §27.9 · Haftalık zaman modeli: bir tik bir haftadır

Zaman modelinin tek kaynağı `GDDs/GDD — ZAMAN MODELİ.md`'dir. Motor sabitlerinin gün → hafta çevirisi onun
§4.8'inde, kart başına bekleme süreleri §4.10'undadır, gün damgalı (v13) kayıtların çevrilmesi §10'undadır. Bu
belgenin gövdesi haftalık modele göre yerinde güncellendi (§0.2, §1, §2, §3.1, §3.3, §5.2, §7, §8, §9.3, §9.6, §10,
§11, §12, §13, §16, §17, §18.2, §19.3, §20, §22.3). Aşağıdakiler, kodun eski metinden ayrıldığı ya da metnin yeniden
yazıldığı yerlerdir. §26 tarihçedir ve değişmedi; oradaki "maksimum hız 3x" satırının bugünkü karşılığı madde 6'dadır.
§24 inşa sırasıdır ve o da değişmedi: Aşama 2'nin bitiş testi (10. gün → 90. gün) bugün `--event-probe`'da 2. hafta
→ 13. hafta olarak koşar.

**1. Adında "gün" kalan alanlar tik sayar.**

*Belge ne diyordu.* Motorun zaman birimi oyun günüydü: §7.1 `day`'i, §16.3 bütün zaman alanlarını "mutlak oyun
günü" diye tanımlıyordu; süreler gün adlı alanlardaydı (`cooldown_days`, `min_gap_days`, `expires_days`,
`delay_days`, `days_since_flag`).

*Ne yapıldı.* Bir oyun günü bir haftadır ve motor tik sayar. Mutlak damgalar adlarını korur: `admitted_day`,
`fire_on_day`, `set_day`, `started_day`, `last_day`, history ve `held` satırlarının `day`'i, kağıdın ve süreli
bayrağın `expires_on`'u. `EvTuning.MAX_INTERRUPTS_PER_DAY` ve `stamp_day` fiili de adını korur. Süre ve sayaç anlatan
adlar haftaya döndü: kart JSON'unda `cooldown_weeks`, `min_gap_weeks`, `expires_weeks`, `deadline_weeks`,
`delay_weeks` (hem `schedule_event` alanı hem ürün gecikme fiili), `set_timed_flag.weeks`, `weeks_since_flag`,
`flag_expires_within.weeks`, `history: weeks_since`; ark dondurmasında `remaining_weeks`; seam'lerde `time.week` ve
`*_weeks_*`. Süre okuyan her yer `TimeModel.ticks()` kapısından geçer.

*Neden.* Damga adı bir kayıt alanıdır. Adını değiştirmek göç ister, "oyun günü" kavramı ise yerinde durur: tik hâlâ
bir oyun günüdür, yalnız süresi bir haftadır. Süre adları değişmek zorundaydı, çünkü okuyucu eski anahtarı görmeyince
sessizce varsayılana düşer: `sales.price_break`'in 0 haftalık cooldown'ı varsayılan 4 haftaya dönerdi,
`days_since_flag` yaprağı tanınmayan yaprak sayılıp FALSE olurdu. Bu yüzden gün adlı anahtar artık E-lint'tir
(§17.1).

**2. Kategori kotasının penceresi tek tiktir.**

*Belge ne diyordu.* §13.3 Katman 3: kayan 7 gün.

*Ne yapıldı.* `EvTuning.CATEGORY_QUOTA_WEEK` yalnız bu tikin kabullerini sayar (`EvTempo._category_count`). Kota
değerleri değişmedi.

*Neden.* Haftalık tikte kayan 7 gün bu haftayla geçen haftayı birlikte sayardı. Eski sayım (`>= day - 7`) ayrıca 7
değil 8 gün sayıyordu.

**3. Kağıdın süresi kart başınadır; vurgu ve son uyarı son haftadadır.**

*Belge ne diyordu.* §3.1 süreyi yalnız `class: paper` için istiyordu. §12.2 süreyi yüzey türüne göre veriyordu
(varsayılan 7 gün, para masası 30, düşük bahisli 14). §11.4 son 3 günde vurgu, §12.4 son 1 günde uyarı istiyordu.
§17.7'nin ikinci kuralı "`expires_days` var fakat `on_expire` yok" idi.

*Ne yapıldı.* Her `interrupt` ve `paper` kartı kendi `expires_weeks`'ini taşır (sahip kararı; §17.7). Eski tablo
yalnız geri düşüştür: 1 / 4 / 2 hafta (`EXPIRY_DEFAULT_WEEKS`, `EXPIRY_MONEY_WEEKS`, `EXPIRY_LOW_STAKES_WEEKS`).
Değer yalnız kart masaya kağıt olarak düştüğünde okunur (`EvEngine._expiry_weeks` → `EvPapers.place`). Vurgu ve son
uyarı tek kurala bağlandı: ömrü `EXPIRY_URGENT_WEEKS`'ten (1) uzun kağıdın son haftası (`EvPapers.is_expiring`). Ömrü
tek hafta olan kağıt baştan "bu hafta" der ve ayrı uyarı almaz. §17.7'nin ikinci kuralı "kağıt ya da düşürülebilir
interrupt, fakat `on_expire` yok" oldu.

*Neden.* Süre durumun doğasından gelir (sahibin örneği: çalışan ya da müşteri talebi 2 hafta); tek bir varsayılan her
kartı aynı sabra zorlardı. Son uyarı tikin başında, `EvPapers.take_expired`'dan hemen önce koşar ve tek haftalık
kağıdın kalan haftası o anda hiçbir zaman 1 değildir: "son gün" kuralının birebir çevirisi 1 haftalık kağıdı
uyarısız düşürürdü. §17.7'nin eski ikinci kuralı ise her interrupt artık `expires_weeks` taşıdığı için `on_expire`'ı
olmayan bütün kritik kesintileri hataya çevirirdi.

*Açık.* Tempo bütçesi tanımayan kesintiler (`critical`, `terminal_warning`, ark adımı) hiç kağıda düşmez; onların
`expires_weeks` değerini, bilgi kartı `sales.weekly_summary`'ninkini de, bugün okuyan yoktur. Lint kesintilerde yine
de ister; bilgi kartında istemez.
Kuralın yalnız düşürülebilir kartları kapsaması sahibin kararıdır.

**4. Gecede saatlik kart reddedilir; masa kartı saatliktir.**

*Belge ne diyordu.* §3.1 ve §20 B10 gece için yalnız `allowed_hours`'u (varsayılan 08:00-20:00) sayıyordu.

*Ne yapıldı.* G4, mesai bitiminden 08:00'e kadarki saatlerde (`TimeManager.is_night()`) critical olmayan saatlik
kartı reddeder. Harness'ın saatlik tarama saatleri 9, 13, 16'dır. Masa kartı (`funding.sheet_decision`) saatlik
süpürülür, `allowed_hours` [0, 23] taşır ve oturum kapısını koşulunda okur (`funding.table_sitting_open`). VC
görüşmesini kart açmaz: görüşme haftasında fon arar ve ofiste telefon çalar (`VCPitchSystem.call_waiting`, Zaman
Modeli §8.6).

*Neden.* Gecenin saatleri kimsenin izlemediği tek toplu adımda geçer. Varsayılan pencere 17:00 sonrasını da kapsadığı
için kritik olmayan saatlik kart o saatlerde kabul edilip sabaha yığılırdı. Günlük süpürme 00:00'da, gecenin içinde
koşar ve oturum kapısı orada hep kapalıdır: kapıyı koşulunda okuyan günlük kart hiç geçemezdi. Saatlik süpürme kartı
haftanın ilk uyanık saatinde, 08:00'de önerir.

**5. Toplu adımda gösterim ertelenir.**

*Belge ne diyordu.* §11.3 saati motorun dışında ileri taşıyan bir yol tanımıyordu; motor her tikin sonunda hemen
pompalıyordu.

*Ne yapıldı.* Toplantı kapanışı ve gece atlaması saatleri `TimeManager.advance_hours` ve `skip_night` ile tek toplu
adımda simüle eder. Adım sürerken (`TimeManager.is_batching()`) `EvEngine.pump()` hiçbir kart göstermez;
`EventBus.clock_batch_ended` onu bir kez çağırır (`EvSignals` bağlar).

*Neden.* Kart gösterileceği saatte yeniden doğrulanır ve kurulur, en önemlisi önce gelir, açık kart 00:00
autosave'ini engellemez. Günlük tikin bütün kartları böylece 08:00'de, haftanın başında ekrana gelir.

**6. 4× geri geldi.**

*Belge ne diyordu.* §11.5: maksimum hız 3x, 4x modal yoğunluğu sebebiyle kaldırıldı (§26 madde 18).

*Ne yapıldı.* Hız merdiveni oyun saati başına gerçek saniyedir ve beş basamaklıdır (`TimeModel.SECONDS_PER_HOUR`:
duraklat, 2,5, 1,25, 2,5/3, 0,625). Varsayılan 09-17 mesaide bir hafta 1×'te 22,5, 4×'te 5,625 sn sürer.

*Neden.* Gün modelinde 3×'te bir oyun günü 3 sn sürüyordu. Haftalık modelde 4×'te bir hafta 22,5 sn sürüyordu.
Sahip kararı (2026-10-09): koşu fazla uzundu; eski 4×'ün temposu 1× oldu, her basamak dört kat hızlandı.
Tempo bütçesi tik başınadır; 4×'teki gerçek zaman yoğunluğunu harness her basamakta ayrı raporlar (§13.7, §19.3).

**7. Tempo sayılarının haftalık hâli ölçülmedi.**

*Belge ne diyordu.* Gün cinsinden: kart boşluğu 30, özne boşluğu 14 / 30, taban 5, ark zaman aşımı 14, varsayılan
cooldown 30; harness 50 günde bir kayıt, 365 günlük koşu.

*Ne yapıldı.* 4, 2 / 4, 1, 2, 4 hafta; harness 7 haftada bir kayıt, 52 haftalık koşu. Tik tavanı tik başına 2 kaldı.

*Neden.* Gün değeri 7'ye bölünüp anlamlı en yakın haftaya yuvarlandı; sıfıra düşen süre en az 1 hafta oldu. §13.8
geçerlidir: hiçbiri ölçülmedi. Tavan dolarsa 1×'te 3 gerçek dakika (sekiz hafta) 16 kesinti eder, §13.7 çapasının (3)
üstü; harness bunu ölçer ve raporlar.

### §27.10 · Ürün rev 7: yapım motoru silindi, sprint dikişleri eklendi

Sahip kararı 2026-10-01 eski ürün yapım motorunu (Konsept, tasarım turları, geliştirme, beta, yayın) sildi; ürün
sprint sprint geliştirilir (`GDDs/GUNCELLEMELER.md` "Ürün rev 7"). Motorun yapıma bağlı yerleri aşağıdadır.

**1. G4'ün build-safe denetimi yok.**

*Belge ne diyordu.* §4.1: G4 tick uyumu ve pencereyle birlikte build-safe denetler; `Origin.REQUEST` tick eşleşmesini
atlasa da `allowed_hours` ve build-safe yine uygulanır (ayrıca §27.4). Bir sürüm yapılırken yalnız `build_safe`
etiketli ya da o yapım fazına kapsamlı kart kesebiliyordu.

*Ne yapıldı.* Denetim G4'ten ve kartların `build_safe` etiketi kart JSON'larından silindi. Sprint sürerken G4 kartı
yalnız tick ve pencereyle süzer.

*Neden.* Denetimin okuduğu aktif yapım yoktur. Sprint bir yapım fazı değildir ve PRD sprint süresince kartları
susturmaz.

**2. Ürün fiilleri değişti.**

*Belge ne diyordu.* Ürün kartlarının fiilleri aktif yapıma yazıyordu: `dimension_delta`, `bug_delta`, `delay_weeks`
(ürün gecikmesi; §27.9 madde 1'deki adın ürün yarısı), `ship_active_build`, `enter_development`, `enter_beta`.

*Ne yapıldı.* Bu altı fiil ve çipleri silindi. Yerlerine dört nötr fiil geldi (`EvEffects.NEUTRAL_VERBS`):
`sprint_card_effort {amount}` ve `sprint_card_progress {amount}` bekleyen karar kartının eforunu ve ilerlemesini,
`sprint_card_carry` onu sonraki sprinte devreder, `sprint_hours {mult}` koşan sprintin çalışma saatini çarpar. Hedef
yoksa (bekleyen karar ya da koşan sprint) fiil `_no_target` yoluyla reddedilir. Çipleri `event_modal._describe_modifier`
kurar; efor çipi kartın gerçekten değişecek eforunu yazar (`SprintSystem.effort_change`).

*Neden.* Kartın sonucu oyuncunun gördüğü yere düşmeli: sprint ekranında görünen şey kartın eforu, ilerlemesi ve
sprintin kapasitesidir.

**3. Ürün seam'leri ve sinyalleri değişti.**

*Belge ne diyordu.* Üretilmiş seam ve sinyal listesi (§27.8) yapım okumalarını (`urun.phase`, `urun.build_active`,
`urun.build_progress`, `urun.build_paused`, `urun.iteration_round`) ve yapım sinyallerini (`build_started`,
`build_paused`, `build_resumed`, `build_iteration_decision_pending`) taşıyordu.

*Ne yapıldı.* Bunlar silindi. Yeni seam'ler `urun.sprint_number`, `urun.sprint_week`, `urun.sprint_running`,
`urun.decision_card`; yeni sinyaller EventBus'ın Sprint bölümündedir (`sprint_planned`, `sprint_started`,
`card_phase_changed`, `card_done`, `card_carried_over`, `sprint_closed`, `card_decision_requested`,
`sprint_auto_started`, `product_state_changed`). `version_shipped` ve `build_phase_changed("shipped")` sürüm çıkaran
sprint kapanışında yayılır. Hiçbir kart sprint sinyaliyle tetiklenmez; `EvSignals.BINDINGS`'e satır eklenmedi. Güncel
liste `docs/content/events_draft/_vocabulary.md` ve `docs/EVENT_SIGNAL_MANIFEST.md`'dedir.

*Neden.* Okunacak yapım yoktur; sprintin okunur durumu numara, hafta, koşuyor mu ve bekleyen karardır.

**4. Sprint karar kartları.**

*Belge ne diyordu.* Sistemlerin kartı adıyla istemesi (§4.1) bir sprint kartına bağlı karar tanımlamıyordu.

*Ne yapıldı.* `SprintSystem`, koşan bir kart için sprintin 2. haftasının tikinde deterministik hash'le
(`data/product/sprint.json` `decision.rate`) `decision.cards`'tan bir kartı `EventGate.request` ile ister. Kabul
edilirse kart karar bekler ve ilerlemez; "Karar ver" kağıdı açar. Seçim `event_resolved` ile kartı hemen serbest
bırakır; süresi dolan kağıdın `on_expire`'ı motorun kendi yolundan koşar ve kart sonraki tikte serbest kalır. Kağıdın
masada durup durmadığını okuyan bir seam olmadığı için sistem `EventGate.desk_papers`'ı tarar. Liste bugün gerçek
kartlardır (§27.11 madde 4).

*Neden.* PRD §3.3 kart kapsamlı olayı ve dört sonuç değiştiricisini ister.

**5. Eski ürün kartları havuzdan çıktı.**

*Ne yapıldı.* `product.first_ship`, `product.version_ship` ve `product.design_round_intro` `cards/unwired/`'a taşındı;
yükleyici o dizine girmez, metinleri korunur.

*Neden.* Seçenekleri silinen fiilleri kullanıyordu; sürüm anını artık sprint ekranının sürüm notu taşır.

### §27.11 · Ürün rev 7 kalibrasyon turu (sahip kararı 2026-10-02)

Kalibrasyon turu (`GDDs/GUNCELLEMELER.md` "Kalibrasyon turu · ürün rev 7") desteye 27 kart ekledi ve motorun beş
yerini değiştirdi. Kartların sayıları ve onay bekleyen değerler `docs/ACIK_ISLER/ACIK_KARARLAR.md` 97'dedir.

**1. Sessiz kart sıradan havuza girmez.**

*Belge ne diyordu.* §13.6: taban yalnız sessiz havuzdan çeker. Sessiz kartın sıradan havuza girip girmediğini
söylemiyordu; kodda havuz (`EvCatalog.pool_candidates`) yalnız ark adımlarını ve `critical` kartları dışarıda
bırakıyordu.

*Ne yapıldı.* Havuz `quiet` etiketli kartı da almaz; sessiz kart yalnız taban tetiklendiğinde, boş geçen haftayı
doldurur. Taban her boş haftada çalıştığı için her sessiz kart kendi `cooldown_weeks`'ini taşır (4, 6 ya da 8 hafta).
Destede altı sessiz kart var; MVP öncesinde taban art arda boş dönmez (`quiet_cards_fill_empty_floor`).

*Neden.* §13.6 sessiz havuzu ölü zamanın alt kümesi sayar. Havuzdan çekilen sessiz kart dolu bir haftada
cooldown'unu harcıyor, boş hafta yine boş kalıyordu.

**2. `add_cash` deftere yazılır; etiket zorunludur.**

*Belge ne diyordu.* §8.1 `add_cash`'i durum fiili sayar, §8.3 yalnız seçenekten çağrılmasını ister; paranın hangi
deftere yazıldığını söylemez. Kod kasayı doğrudan yazıyordu: tutar ay defterine, kâr serisine ve işlem listesine
girmiyordu.

*Ne yapıldı.* Eksi tutar `FinanceSystem.apply_one_time_cost`, artı tutar `apply_one_time_income` olur. Fiil `label`
ister; etiket `FinanceSystem.ONE_TIME_LABELS`'tan gelir (her biri bir `FIN_ONETIME_*` anahtarıdır) ve işlem listesinde o
satır okunur. §17.1'e kural eklendi: etiketsiz ya da bilinmeyen etiketli `add_cash` **E**'dir. Artı tutar tek seferlik
gelirdir: işlem listesine yazılır, ay gelirine yazılmaz.

*Neden.* Kartın parası oyuncunun Finans'ta gördüğü yere düşmeli; kâr serisini kesen harcama ay defterinde görünmeli.

**3. Yeni seam'ler, seçiciler, fiil ve sinyal bağları.**

*Ne yapıldı.*
- Seam'ler: `musteri.broke_promise` (hesaba verilen söz kırılalı `PROMISE_RELOCK_WEEKS` olmadı mı), `musteri.promise_fits`
  (hesabın istediği adım planlanabilir sprintin boş puanına sığar mı; `SprintSystem.fits_plannable`),
  `urun.decision_card_late`, `urun.decision_card_effort`, `urun.capacity_state`, `urun.enterprise_trust`,
  `destek.can_start_fix_run` (sonradan kaldırıldı, §27.26), `rival.leader`. Planın `rival.segment_leader` adı lint'in gerçek marka listesine
  (`EvLint.FORBIDDEN_TERMS`, "segment", §17.8) takıldı: liste kart gövdesini `{seam:}` jetonlarıyla birlikte tarar. Planın
  `urun.decision_card_left_pct`'i okuyucusu kalmayınca silindi. `sales.growth_band` çevrilmiş sözcük yerine bant id'si
  döndürür (`melting | flat | steady | fast`).
- Seçiciler: customer `largest` (en yüksek MRR), employee `most_senior` (en yüksek seviye, eşitlikte en eski işe alım).
- Fiil (sonradan kaldırıldı, §27.26): nötr `fix_run_start` DESTEK'in düzeltme koşusunu başlatır (`SupportSystem.start_fix_run`), açılamazsa ret
  gerekçesini döndürür; sabit çipi `EFFECT_FIX_RUN_STARTS`.
- `EvSignals.BINDINGS`'e slotsuz `axis_floor_warning` ve `axis_floor_crossed` eklendi; B2C taban kartları onlarla
  tetiklenir (sinyaller sonradan eksen değil alan kimliği taşır, §27.36).

*Neden.* Yeni kartların okuduğu durumun seam'i yoktu; içerik durumu yalnız seam'den okur (§6).

**4. Sprint karar kartları gerçek destede.**

*Belge ne diyordu.* §27.10 madde 4: karar listesinde yalnız `_fixtures/` kartları vardı; normal koşuda G2 onları
reddediyor, karar çıkmıyordu.

*Ne yapıldı.* `sprint.json` `decision.cards` `product.sprint_two_paths`, `product.sprint_late`,
`product.sprint_contractor`'dır; oran 0,35; zar koşu tohumunu da okur (`GameState.run_seed`). `SprintSystem` kartın ve
sprintin karar alanını `EventGate.request`'ten **önce** yazar, çünkü kartın koşulu bekleyen karar kartını
`urun.decision_card*` ile okur; istek reddedilirse alanı siler ve listedeki sıradaki kartı dener. `product.sprint_late`
yalnız kart ekibin hızıyla sprintte bitmeyecekse gelir (`urun.decision_card_late` kalan haftaları motorun kendi atama
ve iş adımıyla, karar kilidi kalkmış kopyalarda oynar); öbür ikisi kart eforu en az 5 iken. Fikstürler `_fixtures/`'tan
silindi.

*Neden.* PRD §3.3'ün karar anı oyunda yoktu. Kartın koşulu kararın konusu olan kartı okuyabilmeli, bu yüzden alan
istekten önce yazılır.

**5. `sprint_hours` çarpımla yığılır.**

*Belge ne diyordu.* §27.10 madde 2: `sprint_hours {mult}` koşan sprintin çalışma saatini çarpar. Kod çarpanı
yazıyordu: aynı sprintte ikinci kart birincisini sessizce eziyordu.

*Ne yapıldı.* Yeni çarpan mevcut olanla çarpılır ve `sprint.json` `hours_mult` aralığına (0,5–1,5) kenetlenir
(`SprintSystem.hours_after`); çip kenetlenmiş sonucu yazar.

*Neden.* İki kartın bedeli de oyuncunun gördüğü kapasiteye düşmeli.

### §27.12 · Gelen kutusunun motor hazırlığı (Menajer Masası Faz E1)

Olaylar gelen kutusu olacak (sahip kararı 2026-10-02, `GDDs/GUNCELLEMELER.md` ch12). Kutu bir görünümdür; motorun
bugünkü kayıtlarını okur. Bu adım kutunun okuyacağı ve kağıdın kapanacağı yerleri hazırlar; ekranda değişen yalnız etki
çipleri (renk, melek çekinin iki parçası) ve konuşmacının ilişki sözcüğüdür.

**1. Açılan kağıt cevapsız masaya döner.**

*Belge ne diyordu.* §11.4: kağıt açıldığında modal gibi davranır, kapatıldığında masaya döner. Kodda kapatma yolu yoktu:
açılan kağıt cevaplanmadan kapanamıyordu.

*Ne yapıldı.* `EventGate.set_aside()` yalnız masadan açılan kartta çalışır (`EvQueue.set_active` kartın masadan gelip
gelmediğini taşır; yalnız `open_paper` doğru verir). Kartı etkin olmaktan çıkarır, geçmişe satır yazmaz, kağıt saatiyle
masada kalır, `EventBus.event_set_aside` yayılır ve sonra pompalanır. Kesme kartı kenara konamaz; cevaplanır.
`SaveManager` engellenen autosave'i bu sinyalde de dener.

*Neden.* Kenara koymak bir karar değildir: geçmiş satırı yalnız çözülen, süresi dolan ya da düşen kartındır (§7.1).

**2. Aynı örnek iki kez çözülmez.**

*Belge ne diyordu.* §20 E2 örneği tek tutar. Gece adımında pompa ertelenir ve autosave alınır; kayıt kağıdın son
uyarısını kuyrukta, kağıdı masada birlikte taşıyabiliyordu. Yüklemeden sonra hiçbir şey pompalamıyordu; oyuncu kağıdı
masadan açıp cevaplayınca kuyruktaki uyarı aynı kartı yeniden gösteriyor, etkiler iki kez uygulanıyordu (I2).

*Ne yapıldı.* `open_paper` örneği kuyruktan da alır (`EvQueue.take`). `resolve`'un alması gerekmez: kart etkin olurken
kuyruktan çıkar (pompa ya da `open_paper`) ve etkinken kuyruğa yeniden giremez (`EvQueue.holds` etkin kartı da sayar).
`main` yüklemeden sonra `EventGate.pump()` çağırır; kuyrukta bekleyen kart hemen gösterilir.

*Neden.* Masadaki kağıt ile kuyruktaki son uyarısı aynı örnektir; biri cevaplanınca öbürü de cevaplanmıştır.

**3. Geçmiş satırı ve kağıt konusunun adını tutar; deltalar gerçekleşen tutarı yazar.**

*Belge ne diyordu.* §7.1 `entities` yalnız kimlik tutar; §7.4 satırda etiket olmaz. Satır, etkiler koştuktan sonra
yazılıyordu: müşteriyi kaybettiren ya da çalışanı ayıran seçenek varlığı silmiş oluyordu ve satır adı yalnız ham
kimlikle verebiliyordu. Masadaki kağıt da konusu ayrılınca başlığında ham kimlik gösteriyordu.

*Ne yapıldı.* `resolve` etkilerden ve süre dolumu cezalardan önce bağlı varlıkların adını dondurur
(`EvPresenter.freeze_names`) ve `EvHistory.record`'a isteğe bağlı `names` olarak geçer. Özel ad metindir, çevrilmez;
B2C kitlesinin adı `{key, arg}` olarak saklanır ve gösterildiği dilde kurulur. `EvPapers.place` de kağıdın konusunun
adını dondurur; süresi dolan kağıt kendi adlarıyla satıra geçer. `b2b_retain_discount` deltası gerçekleşen MRR farkını
(`amount`), `b2b_expand` deltası eklenen koltukları (`seats`) ve MRR farkını (`amount`) yazar. `sprint_card_effort`
deltası uygulanan efor değişikliğini (`amount`), `sprint_hours` deltası sprintin vardığı çarpanı (`hours`) yazar: çipin
gösterdiği kenetlenmiş değer (§27.11).

*Neden.* Kutu geçmiş kararları sonuçlarıyla gösterir (ch11 §6). Satır gövdeyi yeniden çizmez (`{seam:}` canlı çözülür);
başlık, seçilen seçenek ve delta çipleriyle okunur. Bunun için adın ve tutarın satırda kalması gerekir.

**4. Tek çip kurucusu `EvChips`.**

*Ne yapıldı.* Etki çipini kuran tek yer `EvChips.describe(item, ctx, names, is_delta)`'dır
(`scripts/events/present/chips.gd`). Kart etkisini, kartın bağlı kapsamına göre motorun uygulayacağı biçimde; geçmiş
deltasını kaydedilen tutarla okur. İmzalı parçalar döner: `{label, value, polarity, glyph}`; `polarity` kazanç, bedel,
tehlike ya da nötrdür. Kırmızı yalnız tehlikedir (ayrılan çalışan, kaybedilen müşteri, kapanan yol, koşunun sonu); harcanan
para, indirim ve hisse bedeldir. Melek çeki iki parça olur: nakit kazançtır, Frank'e giden hisse dilim glifli bedeldir. `SILENT_VERBS`,
`FIXED_CHIPS` ve kaynak rozeti (`source_tag`) de buradadır. Statik olduğu için metni `TranslationServer` ile okur.

*Neden.* Kutunun okuma bölmesi, geçmiş satırı ve olay kartı aynı çipi aynı kuralla göstermeli.

**5. Masa değişikliği sinyali.**

*Ne yapıldı.* `EvPapers` her yerleştirmede, kaldırmada, süre dolumunda ve ark düşüşünde `EventBus.desk_changed` yayar;
masa yüzeyleri (`DeskPapers.connect_changes`) onu dinler.

*Neden.* Kağıt saatlik tikte de gelir; yalnız gün sonunda yenilenen yüzey bayat masa gösteriyordu.

### §27.13 · Haftalık satış özeti motordan çıktı (Menajer Masası Faz E2)

Gelen kutusu motor kartlarını `EvHistory`'den, etkin karttan ve masadan okur. Karar olmayan anlar (Frank'in tanışması,
dönem özeti, Ar-Ge notu ve keşfi, haftalık satış özeti) motorun dışında `GameState.messages`'ta durur; yalnız
`MessageSystem` yazar ve mesaj metin değil anahtar ve argümandır.

*Belge ne diyordu.* §11.1: bilgi kartı rozette ya da raporda akar, zamanı durdurmaz. Canlı tek bilgi kartı
`sales.weekly_summary`'ydi. Motor kağıt olmayan her kartı kuyruğa alıyordu; bilgi kartı da pompada etkin kart olup saati
durduruyor, arkasındaki kartı bekletiyordu. Gövdesi `{seam:sales.weekly_closes}` ve `{seam:sales.account_count}` ile
gösterildiği anda okunuyordu; geç gösterilen kart sonraki haftanın kapanışlarını sayabiliyordu (§27.9'daki
`expires_weeks` notu bu kartı da anar).

*Ne yapıldı.* `SalesRepSystem` haftanın kapanış satırlarını ve defterdeki hesap sayısını, yazıldığı anki hâliyle mesaj
olarak gönderir (`sales_week`). Masanın kapanış satırı kapatan temsilcinin adını taşır (kurucununki boş); rapor onun
sesiyle gelir ve temsilci ayrılsa da ad satırda kalır. Kart, `sales.weekly_closes` seam'i ve `--b2b-shot=weekly`
silindi. Canlı içerikte `info` sınıflı kart kalmadı; sınıf ve motor yolu durur.

*Neden.* Rapor karar değildir: kuyruğa girmez, pompayı tutmaz, saati durdurmaz. Satırlar yazıldığı haftanındır.

*Yan etki.* §13.2'ye göre `info` ve `ambient` bütçe tüketmez. Kodda tüketiyor: `EvTempo.assign` her kabulü, bilgi kartı
dahil, tempo penceresine yazar ve katman 3 (§13.3) penceredeki her kaydı sayar. Haftalık rapor bu yüzden müşteri
kategorisinin haftalık kotasından bir yer tutuyordu. Rapor motordan çıkınca o yer havuzdaki müşteri kartlarına kalır;
kotası dolu haftalarda büyüme kağıdı (`customer.expansion`) daha sık gelir. Bu, §13.2'nin istediği davranıştır; ayrılık
ise kodda durur: sınıf ve motor yolu kaldığı için ileride bağlanan her `info` ya da `ambient` kart yine kategori kotası
tüketir (`docs/ACIK_ISLER/ISLER.md`, Olay motoru).

### §27.14 · Gelen kutusu ve karar kapısı (Menajer Masası Faz E3)

Olaylar penceresi koyu gelen kutusu oldu (sahip kararı 2026-10-02, `GDDs/GUNCELLEMELER.md` ch12 §1). Kart metni
değişmedi: konu kartın başlığıdır, gönderen kartın bağlamından türetilir.

**1. Kart modal değil, kutuda seçili karar.**

*Belge ne diyordu.* §11.1: interrupt engelleyen modaldır; §11.3 modalın saati durdurduğunu söyler; §11.4 kağıdı ODA
masasında gösterir.

*Ne yapıldı.* `EventModal` silindi. `EventBus.modal_requested` adını korur; `main` onu dinler, saati
`hold_clock("event")` ile tutar, panel katmanını ve şehir haritasını kapatır ve Olaylar'ı kartın üstünde açar. Okuma
bölmesi (`scripts/tabs/events/mail_pane.gd`) kartı `EvPresenter.build_view` ile kurar ve seçimi `EventGate.resolve`'a
verir. Tutuş cevapta ve kenara koymada bırakılır (`main._on_gate_closed`). Kartın açtığı oturum (pitch, masa) tutuşu
bırakır ve kartın hızını devralır. Motorun yeni okuması yalnız `EvEngine.resolving()`'dir: bir seçeneğin açtığı term
sheet masasını kapının reddettiği istekten ayırır.

*Neden.* Hız 0 tuşla açılır; tutuş açılmaz ve toplu adımı keser. Yalnız okunur pencereler kararı görünür tutar:
oyuncu kartı cevaplamadan başka bir kararı başlatamaz.

**2. Gönderen.**

*Ne yapıldı.* Kart isteğe bağlı `sender` taşır (`frank | self | employee | contact | investor | press | desk`,
`EvPresenter.SENDERS`; bilinmeyen değer E-lint §17.1). Yoksa kutu gönderi kartın kapsamından (çalışan, müşteri, VC) ve
kategorisinden türetir. Alanı dört kart taşır: `customer.frank_intro` ve `product.paid_tier` (`frank`),
`product.working_parts` ve `team.first_weeks` (`self`).

*Neden.* Kapsamı olmayan Frank sahnesi ya da kurucunun kendi anı, kategorisinden yanlış gönderen alırdı.

**3. Mesajlar kutuda açılır.**

*Ne yapıldı.* `MentorIntroModal`, `MonthSummaryModal` ve `RnDCardModal` silindi. Tanışma ve dönem özeti kutuda
kendiliğinden açılır ve oyunu hız 0 ile duraklatır (tutuş değil); kutudan çıkınca hız döner. Haftalık satış raporu ve
Ar-Ge notu durdurmaz. `RnDSystem`'in ilk not modalı bayrağı ve `EventBus.rnd_card_requested` silindi; keşif mesajı
keşfi yapan kişinin adını ve rolünü taşır.

**4. Masa yüzeyi.**

*Ne yapıldı.* `DeskPapers` yerine `Inbox` (`scripts/ui/components/inbox.gd`) kutunun satırlarını kurar: etkin kart,
kuyruk sayısı, masa, hatırlatmalar, mesajlar ve geçmiş. `EvPresenter.desk_papers` kağıdın kabul haftasını ve açılıp
açılmadığını da verir. `EventBus.desk_changed`'ı kutu, ofisin bildirim yığını ve ray rozeti dinler (§27.12 madde 5).

**5. `goto_tab` kapı kapanınca.**

*Ne yapıldı.* Etki `EventBus.goto_tab_requested` yayar; `main` hedefi saklar ve kapı kapanınca açar.

*Neden.* Sekme kartın altında açılırsa oyuncu cevaplamadan kartı kaybeder.

### §27.15 · Yazar pilotu kartları için üç fiil ve iki sinyal tetiği (sahip kararı 2026-10-08)

Sahip yazar pilotu kartlarının istediği motor parçalarının işe katılmasını istedi; verim kararları
`docs/ACIK_ISLER/ACIK_KARARLAR.md` 103'tedir. Bütün sayılar [WORKING] ve sahibi olan sistemin sabitlerinde durur.

**1. `productivity_mod` (nötr).**

*Belge ne diyordu.* §8.1'de kişinin hızına yazan fiil yok; Ekip GDD §2.2 kısmi kapasiteyi, §8.4 ayrı hız çarpanını
dışarıda bırakıyor.

*Ne yapıldı.* `{"verb": "productivity_mod", "scope": "<employee slotu> | founder | team", "pct": -20, "weeks": 4}`
kişiye süreli bir verim satırı yazar (`Character.productivity_mods`: `{pct, until_day, card_id, title_key}`,
kart başına bir satır, `title_key` kartın başlık anahtarı; motor fiile kartın kimliğini `EvEffects.run_played`, `run_expire` ve `run_check_branch`'in
`card_id`'siyle verir). `founder` kartın `founder` tipli slotudur; `team` koşan sprintin ekibidir
(`SprintSystem.team()`), sprint yoksa hedef yoktur ve kart seçeneği `urun.sprint_running` ile `EV_LOCK_NO_SPRINT`
üstünden kilitlenir. Sınırlar `HRConstants.PACE_*`: satır −%50 ile +%30 arası, 1 ile 8 hafta; tek başına kurucuya
(ekip 0) yazılan eksi satır en çok −%30 ve 2 hafta. Aynı kartın ikinci satırı süreyi tazeler, farklı kartların
satırları çarpılır ve çarpım 0,50 ile 1,30 arasına kenetlenir (`HRSystem.event_pace`). `HRSystem.productivity(c)` gün
başı verimidir: (1 + moral payı) × bu çarpım (`HRConstants.MORALE_PACE_STEPS`; kurucunun moral payı yoktur);
`SprintSystem._points` ve `HRSystem.effective_skill` onu okur, günün saatleri sonra gün içi verim eğrisinden geçer
(`HRConstants.hours_output_mult`: her mesai saati %2, sekizi aşan saat %3 düşer, taban %50; sekiz saatlik gün 1,0'dır).
Satış masasında anlaşmanın planı açılırken satıcının verimine (`HRSystem.productivity`) bölünür
(`SalesRepSystem._desk_halfweeks`): verim satırındaki moral satırı satışta da geçerlidir (sahip kararı
2026-10-11). Satır, son
haftası işlendiği tikte, haftayı okuyan sistemlerden sonra (günlük dağıtımda satıştan sonra) düşer. Lint §17.1: `pct` sıfır olamaz ve fiil bir arkın `on_invalidate`'inde duramaz (orada kart yoktur). Çip `EFFECT_PACE`,
`EFFECT_PACE_FOUNDER`, `EFFECT_PACE_TEAM` (bedel ya da kazanç rengi; kırmızı değil). Ekip penceresinin satır ipucu
ve ekip dosyasının VERİM bölümü verimi ve imzalı sebeplerini (`HRSystem.productivity_lines`) gösterir.

*Neden.* Sahibin verim kararları 1, 3, 4 ve 5. Satır yokken çarpım 1'dir ve gün başı verimi yalnız moral payından
gelir; moral payı ve gün içi eğri moral bandının hız çarpanlarının yerini aldı (`docs/tasks/PRD_EKIP_VERIM_DESTEK.md`
§3 V1).

**2. `investor_strain` (nötr).**

*Ne yapıldı.* `{"verb": "investor_strain", "scope": "<investor slotu>", "amount": 8, "weeks": 26}` fonun
durumuna (`GameState.vc_states`: `strain`, `strain_from`, `strain_until`) bir kırgınlık yazar. Fonun seed ve
Series A odası `amount` puan düşük başlar; ceza doğrusal söner ve sıfırlanır (`VCPitchSystem.strain`); odanın sebep
satırı `VC_WHY_STRAIN`. Sınırlar `PitchConstants.STRAIN_*`: 1 ile 15 puan, 4 ile 52 hafta. İkinci kırgınlık
toplanmaz: bugünkü cezayla yenisinin büyüğü, iki bitişin geç olanına kadar söner. Çip `EFFECT_INVESTOR_STRAIN`.

*Neden.* Reddedilen yatırımcıyla ilişki süreli soğur (portfolio_vendor_trial notu).

**3. `marketing_push` (ekonomik).**

*Belge ne diyordu.* `FinanceSystem`'in `marketing` gider kalemi sıfır değerli bir kancaydı; §8.3'ün `on_expire`
istisnası negatif deltayı tanır, harcamayla büyüme alan bir fiili tanımaz.

*Ne yapıldı.* `{"verb": "marketing_push", "burn_pct": 25, "growth_pct": 15, "weeks": 8}` `marketing` kalemini
seçim anındaki pazarlama hariç burn'ün `burn_pct`'i kadar sabit bir tutara çeker; aynı süre B2C kitlesinin büyüme
terimi (taban kazanım ve ağızdan ağıza artı yönü; erime değil) `1 + growth_pct/100` ile çarpılır
(`FinanceSystem.marketing_growth_mult`). Durum `GameState.marketing_push`'tadır (`{growth_pct, until_day}`, boş
sözlük kampanya yok demektir), tutar gider kalemindedir. Kampanya son haftasını tahsil eden finans tikinde biter;
yenisi süren kampanyanın yerini alır. Sınırlar `FinanceSystem.MARKETING_*`: burn %5 ile %50, büyüme %5 ile %50, 2
ile 12 hafta. `on_expire`'da motor reddeder (`EvEffects._is_negative`) ve lint §17.3 hata verir. Çip iki parçadır:
`EFFECT_MARKETING_BURN` (bedel) ve `EFFECT_MARKETING_GROWTH` (kazanç).

*Neden.* Pazarlama harcaması ekonomiyi oynatır ve şirketle ölçeklenmelidir (shutdown_notice notu).

**4. Yatırım teklifi tetikleri.**

*Ne yapıldı.* `sheet_granted` (Series A term sheet) ve `seed_sheet_granted` (seed teklifi) `EvSignals.BINDINGS`'e
`investor` slotuyla girdi; manifest (`docs/EVENT_SIGNAL_MANIFEST.md`) yeniden üretildi.

*Neden.* Herhangi bir yatırım teklifi geldiği anda kart ateşlenebilmelidir (closing_docs notu).

**5. Küçük parçalar.** `hr.job` varlık seam'i: kişinin ilk işi (`build | test | support | accounts | sales |
research`, işsizse boş). `add_cash` etiketleri `legal`, `pay_cut` (pozitif tutarla tek seferlik tasarruf) ve
`data_purchase` (`FinanceSystem.ONE_TIME_LABELS`). Customer seçicisi `smallest`: en düşük MRR'lı etkin hesap
(eşitlikte kimlik).

### §27.16 · Slotun aday süzgeci `where`

*Belge ne diyordu.* §4.3: seçici bir özne seçer, koşul o tek özneye karşı sınanır.

*Ne yapıldı.* Slot isteğe bağlı `where` taşır: kart koşulunun dilinde, yaprakları yalnız bu slotun `entity_seam`'i
olan bir ağaç (`{"entity_seam": "hr.job", "scope": "employee", "op": "==", "value": "build"}`). `EvScope.resolve`
seçiciyi yalnız ağacın tuttuğu adaylar üstünde koşar: her aday geçici bağlamayla `EvCondition.eval`'den geçer,
tutmayan seçiciye bağlanmış gibi görünmez. Verilen slot (sinyal, zamanlama, ark bağlamı, gösterimdeki yeniden
doğrulama) süzülmez ama sınanır: ağacı tutmayan verilen özne, yanlış tipteki özne gibi kartı reddeder. Aynı gruptaki
(zorunlu ya da opsiyonel) slotlar bildirim sırasıyla bağlanır; önce bildirilen süzgeçsiz slot, sonraki aynı tipteki
`where` slotunun istediği tek adayı alabilir. `where`'i olmayan slot önceki gibi bağlanır. `EvCatalog` ağacın
değerlerini yüklemede seam tipine çevirir, bilinmeyen seam'i yükleme hatasına yazar. Lint §17.1: `where` boş olmayan
bir ağaçtır, her yaprağı bu slotu adlandıran ve slotun tipine ait bir `entity_seam`'dir, seam'leri kayıtlıdır.

*Neden.* Seçici ile koşul ayrıyken "en kıdemli kişi, eğer yapım ekibindeyse" türü kart, yapım ekibinde biri varken
bile en kıdemli kişi orada olmadığı için hiç ateşlenmez; küçük hesabı anlatan kart en büyük ya da en küçük hesabı
bağlayıp bandın dışında kalır. Süzgeç kartın anlattığı özneyi bağlar.

### §27.17 · Tek seçenekli beat notu ve donmuş seam değerleri

Sahip kararı 2026-10-10: tek düğmeli beat kartı saati tutmaz, nota döner, geçmişte gövdesi kalır.

**1. Not kuralı.**

*Belge ne diyordu.* §11.1: interrupt karar kapısıdır; kutu kartın üstünde açılır ve saat tutulur (§27.14). Seçeneği
tek ve etkisiz olan kart da (`founder.company_of_one`, `founder.savings_note`, `founder.unseen_build`,
`product.working_parts`) saati durdurup pencereyi kaplıyordu; taban (§13.6) bu kartları bir sessiz haftada getirir.

*Ne yapıldı.* Kart tek seçenekliyse, o seçenekte `effects` (boş liste etkisiz sayılır), `check` ve `requires` yoksa,
kart `critical` değilse ve sınıfı `paper` değilse nottur (`EvPresenter.is_note`; motor ve harness aynı yerden okur).
`quiet` etiketi gerekmez. Kural bugün yukarıdaki dört kartı tutar; `critical` kartlar (Frank'in yaklaşma kartları,
`gate_traction`, `hire_nudge`, `paid_tier`, `frank_intro`, `resignation`) ve kâğıt `funding.seed_stalled` karar kalır.

`_admit` notu ne kuyruğa ne masaya koyar. Mandal harcanır; geçmişe tek seçeneğin `chosen` satırı yazılır (`outcome_id`
seçeneğinki, `deltas` boş, `names` = `freeze_names` ile madde 2'nin donmuş seam değerleri) ve satır `note: true`,
`unread: true` taşır (`EvHistory.record`'un `note` parametresi). `EventBus.modal_requested` ve `event_resolved`
yayılmaz: kapı açılmaz, saat tutulmaz, `has_pending()` notu görmez, otomatik kayıt onu beklemez; satır kayda girer.
Not kutuya ve ofis yığınına `EventBus.event_triggered` ile duyurulur. Duyuru bir sonraki pompadadır; toplu saat
adımında (gece, toplantı atlaması) pompa adımın sonuna ertelendiği için dinleyiciler adımın içinde koşmaz. Not yolu
yalnız `_admit`'tir (istek, havuz, taban, takvim, ark adımı, sinyal); tarama yalnız `critical` kart önerdiği için not
getirmez, `force_fire` `_admit`'i atlar ve kartı kapıda gösterir. Ark adımı olan not, `resolve` gibi arkını bir adım
ilerletir: tek seçeneğinde ark fiili yoktur.

Bütçe ve taban: not `_today_admissions`'a girmez, `EvTempo` penceresine yazılmaz; tikin kesinti tavanından (§13.3
katman 4) ve kategori kotasından (katman 3) pay almaz. Not tabanın sessiz haftasını bitirmez: yalnız not gelen hafta
taban için sessizdir (§13.6). Taban seçtiğinde kendi sayacını sıfırlar ve quiet kartın kendi `cooldown_weeks`
mandalı onu seyreltir; bu yüzden not her hafta yeniden gelmez. `fire_count` not satırını sayar; mandal ve `history`
yaprakları için not bir çözümdür.

Kutu: not listede okunmamış sayılmaz (liste noktası ve Okunmamış süzgeci saymaz); okunmamışlığını `note_unread`
alanından yalnız ofisin bildirim yığını gösterir (`Inbox.unread_discovery` en yeni okunmamış keşfi ve en yeni
okunmamış notu verir; `EvHistory.newest_unread_note` geçmişi sondan tarar). Ray rozeti kuyruğu ve masayı sayar,
notu saymaz. Not kutuda okununca `EventGate.mark_read(i)` (`i`, satırın `history()`'deki yeri) satırı okundu yapar ve
`EventBus.messages_changed` yayar. Listede notun ikinci satırı gövdenin ilk satırıdır, damgası yoktur; okuma
bölmesinin türü karar değil mesajdır (`MAIL_KIND_MESSAGE`), "Seçimin" kutusu ve damga yerine tek düğme vardır:
kartın seçenek etiketi, kutuyu kapatır.

Harness `modal_requested`'i sayar: not kartı kapıyı isterse `BEAT_MODAL <id> <n>` basar ve koşu `HARNESS FAIL` olur.
Harness kararı yalnız etkin kartta saydığı için not karar sayılmaz; `CARDS`, `TEMPO` ve sessizlik değerleri değişir,
not kartları `COVERAGE`'da hiç ateşlenmemiş görünür. Ark adımını ise motorun `event_triggered` duyurusunda sayar;
not olan adım da ziyaret edilmiş sayılır.

*Neden.* Karar olmayan an saati durdurmaz (§27.13'teki rapor gibi); gövdesi geçmişte okunur kalır.

**2. Seam değerleri satırda donar.**

*Belge ne diyordu.* §27.12 madde 3: satır gövdeyi yeniden çizmez, `{seam:}` canlı çözülür. Okuma bölmesi geçmiş
gövdesini yalnız `{seam:}` taşımayan düz metinde çiziyordu; `{seam:}` ya da `by_seam` varyantı taşıyan her kartın
gövdesi geçmişte düşüyordu.

*Ne yapıldı.* `EvPresenter.freeze_seams(card, context)` kartın iki dildeki başlık ve gövdesinin okuduğu her seam'i
(varyant metninin `by_seam` seçicisi ve varyantlarındaki seam'ler dahil) `names["seam:<ad>"]` olarak verir. Sayı
`str(değer)`, bool `"0"` ya da `"1"` olarak donar; varlık seam'i bağlamın bağladığı özneden okunur. TYPE_STRING seam
donmaz: satır çevrilmiş metin taşımaz (§7.4). Dondurma çözümde (`resolve`, etkilerden önce), süre dolumunda (cezalardan
önce ve yalnız kâğıdın öznesi hâlâ varken: bekleyişte ayrılan öznenin seam'i yedek değeri okurdu; satır adını
kâğıttan alır, seam okuyan gövdesi çizilmez) ve not yazılırken olur. `_interpolate` ve `_resolve_variant` önce
`names`'e bakar; varyant donmuş değeri `int()` ile okur. Okuma bölmesi geçmiş satırın gövdesini, gövdenin okuduğu
her seam satırda donmuşsa çizer (`EvPresenter.seams_of`); donmayan seam'li gövde ve dondurmadan önce yazılmış
satırlar gövdesiz kalır. Katalogda gövdesi donan 12 kart vardır (dört not ve varlık seam'i `musteri.seats` ile
`customer.new_owner` dahil); TYPE_STRING seam taşıyan 15 kartın gövdesi geçmişte düşmeye devam eder.

*Neden.* Geçmiş kartın yazıldığı haftayı söyler; canlı okunan sayı bugünü söylerdi.

**3. Kayıt.** Şema 15 kalır. Yeni alanlar satırın içindedir (`note`, `unread`, `names["seam:*"]`); eski satır
`row.get("note", false)` ile not sayılmaz, göç yoktur.

### §27.18 · Kritik kartın mandal iadesi

Karar 2026-10-10: kuyrukta koşulu bozulup düşen kritik kart mandalını geri alır.

*Belge ne diyordu.* §4.4: mandal kabulde harcanır, gösterimde G3 yeniden koşmaz; kuyruktaki kart gösterileceği saatte
G5, G6 ve G7'yi yeniden geçer, geçemezse `dropped` satırıyla sessizce düşer. Düşen `one_shot` kartın mandalı harcanmış
kalıyordu: `funding.frank_cheque` gece 00:00'da kabul edilip gece atlamasının sonunda gösterilene dek B2C'nin MRR'ı
eşiğin altına inerse çek koşu boyunca bir daha gelmiyordu; kepenk başladığında kuyrukta bekleyen `gate_traction` da öyle.

*Ne yapıldı.* `EvEngine.pump` kuyruktaki kartı G7'de (koşul ağacı) düşürdüğünde kart `critical` etiketli ve mandalı
`one_shot` ise mandalı `EvLatches.refund(key)` ile geri verir: `spend`'in tersidir, `fires` bir azalır, sıfıra inen
kayıt silinir (`clear_one` yalnız debug ve smoke içindir). `dropped` satırı yine yazılır. G5 (özne gitti) ve G6 (koruma)
düşüşü iade etmez; `resolve`'un G5 düşüşü, `open_paper`'ın masadan açarken düşüşü ve mandal harcamayan `force_fire`
örneğinin (yalnız debug) düşüşü de etmez. Kritik `one_shot` kâğıdın son haftasında kuyruğa giren son uyarısı (§12.4)
pompada G7'de düşerse kâğıt masadan kalkar ve mandalı iade edilir; koşul yeniden tutunca kâğıt taze süreyle masaya
döner. Kartı öneren yol (günlük tarama ya da ark adımı) koşul yeniden tuttuğunda onu tekrar kabul eder. Koşul kabul ile
gösterim arasında her gece bozulursa her gece bir `dropped` satırı yazılır; her yeniden kabul o hafta `EvTempo`
penceresinde sayılır (§13.3) ve tabanın sessiz hafta sayacını sıfırlar (§13.6). `fire_count` ve `history` yaprakları
düşüşü çözüm sayar; çek listesi düşüşte açık kalır, yalnız `chosen` ve `expired` satırı kapatır. Mandalı okuyan araçlar
(`--why-fire`, smoke'un `_card_fired`'ı) iadeden sonra kartı hiç ateşlenmemiş görür. Şema 15 kalır. Smoke
`event_critical_drop_refunds_latch`.

*Neden.* Kritik kart koşunun omurgasıdır (para, faz kapısı, Frank); oyuncunun görmediği birkaç saatlik dalgalanma onu
koşudan silmemeli.

### §27.19 · Gecikme penceresi ve `SCHEDULE_DELAYED`

*Belge ne diyordu.* §14.1 havuzu düz ağırlıkla çekiyor, §25 MTTH'yi reddediyor; ikisi arasında zamanlamanın
nerede yaşadığına dair bir katman yok.

*Ne yapıldı.* Kart `delay_weeks: [N, M]` taşır (§3.1). Koşulun ilk tuttuğu hafta bir pencere kurulur
(`EvDelays.touch`, kapıdan sonra ve frenlerden önce): `d0 = GameState.day`, bekleme
`N + floor(EvDice.unit("delay", d0, kart, özne) × (M − N + 1))`, kurulum anında tutan her `delay_mult` yaprağı
beklemeyi çarpar, sonuç yuvarlanıp `[N, M]`'e kenetlenir. `d0 + bekleme` gelmeden kart aday değildir. Pencere örnek
başınadır (`EvLatches.key_of`): aynı kartın iki hesabı ayrı bekler. Koşul art arda `EvTuning.DISARM_WEEKS`
(4) haftadan uzun süre tutmazsa pencere atılır ve bir dahaki tutuşta yeniden çekilir; altındaki boşluklar penceresini
korur, çünkü sprint biçimli koşullar tam böyle gidip gelir. Okumak (`EvDelays.window`) ne kurar ne söker:
`--why-fire` havuzun sorduğu soruyu sorar ve cevabı değiştirmemelidir.

Sinyal kartı anında kabul edilmez, TARİHLENİR: `_propose` kapıdan sonra `_deferral_weeks`'i sorar ve penceresi olan
sinyal önerisini `EvDelays.draw_weeks` ile vadesine kurar (`EvSchedule.add(..., delayed = true)`), kabul etmez;
`_step_signal_drain` zaten tarihlenmiş örneği (`EvSchedule.has_dated_for`) ikinci kez önermez; `_step_schedule` o
girdiyi yeni `EvGate.Origin.SCHEDULE_DELAYED` köken koduyla önerir. G4'ün o kolu `signal`, `scheduled` ve `daily`
tick'ini kabul eder, çünkü gecikmiş girdi bir sinyal kartını taşıdığı kadar bir zamanlama kartını da taşır ve kart
hâlâ `tick: signal` der. Aynı yol frenlerin ve başlangıç korumasının ertelemesini de taşır (§13.3); bekleme bir kez
çekilir, geri dönen girdi yeniden çekmez. Pencereler, modül görüntüsü ve en son açılan modül
`EvDelays.to_dict/from_dict` ile olay bloğunda durur; eski kayıtta boş açılır.

*Neden.* Eşik bir tarih değil, bir kapıdır. İnce havuzda "uygun" ile "ateşlendi" tek olaydı: `conference_trip`
ölçülen koşuların ikisinde de tam kıdem 12'de geldi, oyuncu şirketi değil takvimi öğrenir. Zar
`EvDice`'ın hash'i olduğu için yeniden yükleme yeni bir atış almaz; MTTH'nin haftalık yazı-turası alırdı.

### §27.20 · Makullük bloğu bir derleyicidir

*Belge ne diyordu.* §3.1 koşulu tamamen yazarın ağacına bırakıyor; §5 evre, kadro, kıdem ve ürün durumu için
primitive veriyor ama hiçbirini zorunlu kılmıyor.

*Ne yapıldı.* `schema: 3` kartında `EvCatalog._normalise_card` makullük bloğunu §3.1'in tablosundaki
yapraklara derler ve `condition`'ı `{"all": [<yazılmış ağaç>, <derlenmiş yapraklar>]}` yapar; derleme
`_coerce_conditions`'dan önce koşar, böylece yeni yapraklar da yazılanlar gibi seam tipine çevrilir. Kıdem
yaprağı koşula değil slotun `where`'ine girer (§27.16): kart kıdemli adayı bağlar, herkesi bağlayıp kapıda
reddetmez. Taban kartın kendi sayısıyla ailesinin tabanının büyüğüdür (`EvTuning.FAMILY_SUBJECT_TENURE`).
Tanınmayan bant, `product` değeri ya da `[min, max]` olmayan `headcount` hiç yaprak yazmaz ve lint'in P1'idir:
boş bir `all` TRUE okunacağı için (§5.3) tahmin, bulgunun tam tersini yapardı. Her derlenmiş yaprak
`"_from": "plausibility"` taşır.

*Neden.* Makullük yazarın değil şemanın işidir. Blok zorunlu olunca unutmak bir lint hatasıdır, kural motorda
tek yerde yaşar, ve kapı, lint ile `--why-fire` yaprak okumaya devam ettiği için hiçbiri bloğun varlığını
bilmek zorunda kalmaz.

### §27.21 · Aile frenleri ve başlangıç koruması

*Belge ne diyordu.* §13.3 üç fren tanıyor: aynı kart, aynı özne, kategori kotası. Bir "aile" kavramı yok ve
koşunun ilk haftalarına dair bir kural yok.

*Ne yapıldı.* Katman 1b (aynı aileden başka bir kart) ve 2b (aynı aile, aynı özne) `EvTempo.family_brake`'te,
`pool_blocked_reason`'dan ayrı sorulur: sinyal, zamanlama ve taban kökenleri bu iki katmanı havuzun üçünü
ödemeden öder, ve iki katmanın reddi bir süre döndürdüğü için sinyal düşürülmek yerine tarihlenir (§13.3).
Başlangıç koruması G4'tedir (`EvGate.start_immunity_weeks_left`): ilk `EvTuning.START_IMMUNITY_WEEKS` (3)
haftada havuz konuşmaz. Muaf olanlar: `system` kart, `tutorial` ve `terminal_warning` etiketi, REQUEST,
ARC_STEP ve FLOOR kökenleri; FORCE soruyu hiç görmez (§4.5). Sessiz taban muafiyeti bilinçlidir: koruma onu
da tutsaydı oyuncuya üç boş hafta düşerdi ve tabanın içerik açığı uyarısı boşa çalardı (§13.6). Not (§27.17)
pencereye yazılmaz ama ailesinin gününü yazar (`EvTempo.record_family`): tabanın kurucu kartları nottur ve
`founder_solitude` ile `founder_money` aralıkları onlar içindir.

*Neden.* Bulgular: aynı çalışan iki kez para istedi ve yedi kart korumanın yerine kendi `time.week >= N`
satırını yazmıştı. Aile, "haftanın hissi" ile "kartın kimliği" arasındaki boşluğu kapatır; koruma, ilk
haftada tesadüfen uygun olan havuz kartının açılışı çalmasını engeller — açılış öğreticinin ve kendi anını
adlandıran sistemlerindir.

### §27.22 · Modül kilidi, iki HR seam'i ve iki kanca

*Belge ne diyordu.* §6.5'in seam tabanında modülün açık olup olmadığını okuyan bir seam yok; §15.1'in
manifestinde modül açılışının sinyali yok, `customer_added` de bağlı değil.

*Ne yapıldı.* `build.module_unlocked.<id>` (GLOBAL, bool) `UiTokens.TABS`'taki her modül için kayıtlıdır;
değerin tek evi `scripts/systems/module_locks.gd`'dir (`ModuleLocks.is_open`), rayın `_is_locked`'ı da oraya
devreder — kilit build üstüne bir kuraldır, tek bir sistemin durumu değil. Smoke için `set_override`. Yanında
`build.last_unlocked_module` (GLOBAL, string) ve HR'ın iki sayacı: `hr.weeks_since_last_hire` (en genç etkin
çalışanın kıdemi, kimse yoksa −1) ve `hr.run_hires`.

Kancalar: `customer_added` `EvSignals.BINDINGS`'e `customer` slotuyla girdi ("ilk müşteri" deseni
`customer_added` + `musteri.count == 1`'dir). `EventBus.module_unlocked(module_id)` yeni bir sinyaldir ve onu
yayan motorun kendisidir: günlük tikte, sinyal boşaltmasından önce `_step_module_watch` `ModuleLocks.is_open`
görüntüsünü dünküyle karşılaştırır ve kapalıdan açığa dönen her id için sinyali yayar. Görüntü boşsa (yeni
koşu, eski kayıt) ilk tik onu sessizce tohumlar ve kimseyi adlandırmaz: açılışta açık olan her şey hep
açıktı. Kart hangi modülün açıldığını `build.last_unlocked_module` seam'inden okur, çünkü modül bir varlık
değildir ve bağlanacak bir slotu yoktur.

*Neden.* Modül açılışı içeriğin bağlanabileceği bir beat'ti ve kimse onu yaymıyordu; "ilk müşteri" ise motorun
en çok istenen tetiğiydi ve sinyali bağlı olmadığı için yazılamıyordu.

### §27.23 · `critical` daraltıldı, emeklilik yolu `retired`

*Belge ne diyordu.* §14.1 `critical`'i yazarın tek kararı olarak veriyor ("bu kart omurga mı"); §13.5 onu
bütçeden, §13.3 Katman 2'den muaf tutuyor.

*Ne yapıldı.* `critical` yalnız `system` ya da `terminal_warning` kartın etiketi olabilir (lint C1). Frenleri
ve kotayı atlamak koşunun kendi anlarının hakkıdır; hikâye kartı havuzda sırasını bekler. `version_scope`
yeni bir değer alır: `retired` kart hiçbir build'de gönderilmez (G2) ama katalogda kalır, eski kaydın geçmiş
satırı ve mandalı çözülebilsin diye (§22.1).

*Neden.* 26 kart `critical` taşıyordu ve üçü hikâye kartıydı (`customer.cs_escalation`,
`world.analyst_guide`, `world.newsletter_slot`): ateşlendiklerinde haftanın kotası ve özne freni yok
sayılıyordu, yani havuzun ritmi tek bir etiketle delinebiliyordu. Emeklilikte dosyayı silmek eski kaydın
okuyamadığı bir geçmiş satırı bırakırdı.

### §27.24 · Lint'in v3 kuralları ve dondurulmuş liste

*Belge ne diyordu.* §17 yapıyı, ulaşılabilirliği, ekonomiyi ve metni denetliyor; şıkkın gerçek bir hamle olup
olmadığını, fiili kimin yazabileceğini ve kartın makul olup olmadığını sormuyor.

*Ne yapıldı.* Üç yeni kural ailesi: §17.13 makullük bloğu (P1-P3), §17.14 fiil yetkisi (C1, V1-V3), §17.15
şıklar ve tekrar (O1-O5, T1-T3). Kimlikler `17.13`, `17.14`, `17.15`'tir ve her ileti kural adıyla başlar
("O2: ..."), böylece baseline'ın parmak izi kuralı adlandırır. Fikstür ve `retired` kart muaftır. Göçün kart
kart sağlayamadığı beş kural (`O2`, `O4`, `O5`, `T2`, `T3`) `tools/lint_v3_frozen.json`'daki kartlarda
uyarıdır; liste büyümez, yeniden yazılan kart listeden çıkar, sonradan yazılan kart hatayı alır. Yazılabilir
fiil kümesi lint'te durur (`WRITER_VERBS` 30, `SYSTEM_VERBS` 18): bir fiil ancak `EvEffects._apply`'da çalışan
bir kolu VE `EvChips`'te bir etiketi varsa yazılabilir.

*Neden.* Lint eskiden yalnız fiilin listede olmasını soruyordu; listedeki 63 fiilin 15'i ya kolsuz ya
çipsizdi, yani kart yazarının elinde çalışmayan bir söz vardı. Şıkların bedeli ve öznesi de kural olmadan
denetlenemiyordu: bedava çıkış ve "kartın anlattığı kişiye hiçbir şey düşmeyen" şık sessizce geçiyordu.

### §27.25 · Tükenmişlik kartının iki fiili, iki seam ve koşu sürerken susan hata yığını

*(`destek.fix_run_active` ve `product.bug_pile` Faz A'da kaldırıldı, §27.26; tükenmişlik kartının iki fiili ve `hr.leave_cooldown_left` yürürlüktedir.)*

*Belge ne diyordu.* §8.1'de çalışanı izne gönderen ya da mesaisini değiştiren yazılabilir bir fiil yok:
`send_on_leave` dağıtımda vardı ama kolsuz ve çipsizdi (§27.24). `product.bug_pile` düzeltme koşusunun açık olup
olmadığını okuyamıyordu.

*Ne yapıldı.* `{"verb": "send_on_leave", "scope": "<employee slotu>", "weeks": 1}` dosyanın izin eyleminin kapısından
geçer (`HRActions.apply_leave`: izindeki, eğitimdeki, ayrılmakta olan ve son iznin dönüşünden
`HRConstants.LEAVE_COOLDOWN_WEEKS` geçmemiş kişi reddedilir); kayıt dönüşte gelecek morali (`gain`) taşır. Yeni nötr fiil
`{"verb": "work_hours", "scope": "<employee slotu>", "hours": 8}` kişinin mesai istisnasını yazar
(`WorkHoursSystem.set_person_hours`). İkisi yazılabilir (`WRITER_VERBS` 32) ve özneye düşer (`SUBJECT_VERBS`). Çipler:
`EFFECT_LEAVE` (bedel) ve dönüş morali `HR_ROW_MORALE_RETURN` (kazanç), `EFFECT_WORK_HOURS` (nötr). Yeni seam'ler
`destek.fix_run_active` (GLOBAL, bool) ve `hr.leave_cooldown_left` (ENTITY, int: oyuncunun kişiyi yeniden izne
gönderebilmesine kalan hafta). `product.bug_pile`'ın koşuluna `destek.fix_run_active == false` girdi. Yeni sistem kartı
`team.burnout` (`tick: request`, `latch_key: entity`): sekizi aşan `HRConstants.BURNOUT_WEEKS` ardışık iş haftasında
`HRMoraleSystem.tick_burnout` onu o çalışan için ister; kabul edilen kartla sayım baştan başlar, reddedilen istek gelecek
hafta yinelenir (§13.3). Kurucu sayılmaz.

*Neden.* `docs/tasks/PRD_EKIP_VERIM_DESTEK.md` D4 ve V3: koşu sürerken hata yığını kartı oyuncuya zaten yaptığı işi
soruyordu; tükenmişlik kartının şıkları gerçek hamledir (izne gönder, mesaiyi indir, devam et ve bedelini öde) ve iki
hamlenin fiili yoktu.

### §27.26 · Faz A: tek açık hata deposu, düzeltme koşusunun ve hata yığını kartının kalkışı

*Belge ne diyordu.* §27.11 madde 3 ve §27.25: DESTEK'in düzeltme koşusunu başlatan nötr `fix_run_start` fiili (çipi
`EFFECT_FIX_RUN_STARTS`), `destek.can_start_fix_run` ve `destek.fix_run_active` seam'leri ve koşu sürerken susan
`product.bug_pile` kartı yürürlüktedir; ürünün hata okuması `urun.bugs_confirmed` (doğrulanmış hata sayacı) seam'idir.

*Ne yapıldı.* Hata tek depoya indi (hat başına açık hata, `ProductState`; GUNCELLEMELER "Faz A · tek hata sayısı") ve
düzeltme koşusu oyundan kalktı: düzeltme sprintin düzeltme kartının işidir.
- Silindi: iki `destek.*` seam'i, `fix_run_start` fiili ve çipi (`EvEffects`, `EvChips`), lint'te `WRITER_VERBS`'ten
  (32 → 31) ve `CONSEQUENCE_VERBS`'ten fiil, `product.bug_pile` kartı (dondurulmuş listedeki satırı, tek üyeli
  `product_quality` ailesi, beş `EV_PRODUCT_BUG_PILE_*` anahtarı).
- Değişti: `urun.bugs_confirmed` yerini `urun.open_bugs`'a bıraktı (bütün hatlardaki açık hata); `customer.b2c_refunds`
  yeni seam'i okur, eşik aynı (8). Yeni seam `urun.worst_line_bugs` en çok hatalı hattın sayısını okur.
- Eksen seam'leri (`urun.axis_stability` dahil) açık hatayla düşmez: Kararlılık okuması ham eksendir, hatanın bedeli
  müşteri kaybıdır. `urun.axis_stability` okuyan kartlar (`launch_leak`, `password_rule`) hata yüzünden eşiğe inmez
  (seam'ler sonradan kalktı, §27.36; kartlar `urun.trust_level` okur ve aynı kuralı korur).
- Yeni sinyal `EventBus.line_bugs_cleared(hat, n)` motora bağlı değildir; düzeltme kartı hattını temizleyince yayılır.
- Üretilen sayılar (`_vocabulary.md`): 197 → 196 seam, 64 → 63 fiil, 98 → 97 kart.
- Eski kayıt: `product.bug_pile` satırları (kuyruk, takvim, masa, geçmiş, etkin kart) `SaveManager._migrate_16`'da
  silinir; kart bir kaydın içinde kalırsa yükleyici hata basardı.

*Neden.* Faz A görevi (sahip kararı 2026-10-16, Karar 1 ve 12): oyuncu hata durumunu tek sayıdan okur, hata
düzeltmek sprintin küçük bir parçasıdır ve DESTEK'te ayrı bir düzeltme düğmesi yoktur; koşu olmayınca onu soran
seam'lerin ve onu bekleyen kartın okuyacağı durum kalmaz.

### §27.27 · Faz B1: mail ve bildirim saatleri, teslim kuralı

*Belge ne diyordu.* Kuyruk (§2), masa (§12) ve geçmiş (§7) gün damgası taşır; günlük tikte kabul edilen kart toplu adımın
sonunda, 08:00'de gösterilir (ZAMAN MODELİ §1.2); gelen kutusunun mesajı yalnız gün taşır, hatırlatıcının hiç saati yoktur
(§27.12 – §27.14). Gün 00:00'da dönünce günlük üreticilerin hepsi o anda yazar ve oyuncu sabah gece yarısı damgalı bir
yığın bulur.

*Ne yapıldı.* Saatin ürettiği mail, kâğıt, not, hatırlatıcı, Frank'in satırı ve haber bandının canlı satırı, acil değilse,
şirketin mesai penceresinde (`WorkHoursSystem.company_window()`) bir geliş saati alır ve ondan önce gösterilmez.
`MailClock` (statik, durumsuz) saati çeker: pencerede ya da acilse şimdi, değilse sonraki pencerenin ilk 4 saati içinde
`EvDice.unit("arrival", …)` ile bir tam saat (bir haftalık kâğıt için ilk 1 saat) [WORKING, onay bekliyor]. `at` mutlak
dakikadır (tik × 1440 + günün dakikası), -1 saatsizdir. Acil sayılan: `terminal_warning` ya da `urgent` etiketli kart,
kâğıdın son uyarısı, koşunun giriş notu, Frank'in satırını silen boş anahtar; oyuncunun kendi isteği (`EventGate.request`'in
`immediate` argümanı, hatırlatıcının düğmesi) de hemen gelir.
- Mesaj: `MessageSystem.post` pencere dışında mesajı `GameState.mail_outbox`'a yazar, `MailClock.hourly_tick` vakti gelince
  `messages`'a teslim eder (kimlik ve gün teslimde doğar). `summary_ready` ve `product_note_issued` teslim anında yayılır;
  yazan sistem yaymaz.
- Kart: `EvEngine._admit` geliş saatini çeker ve kuyruk girdisine (`at`, `urgent`), masa kâğıdına (`at`) ve not satırına
  yazar; cevap satırı cevabın verildiği saati, süre dolumu satırı çekilmiş bir geliş saatini taşır. Görünürlük okuma
  anında karar verilir: kuyruğun süzgeci tek yerdedir (`EvQueue._shown`), masanınki `EvPapers.visible`, notunki
  `EvHistory.newest_unread_note` ve `Inbox.items`. Varlığı soran okuyucular süzmez (`EvQueue.has/holds/ids`,
  `EvPapers.has/keys_of/is_empty`, `EventGate.instances_of/on_desk`, ark adımı, `SprintSystem._settle_decision`): gizli bir
  kâğıt hâlâ kartın beklediği kâğıttır. Kâğıt geliş gününden saymaya başlar; akşam gelen kâğıdın haftası ertesi tikte açılır.
  Toplu adımın sonundaki `pump` yalnız gelmiş kartı kurar. Not yazıldığı anda geçmişe girer ve geliş saatinde duyurulur;
  duyuru anında §4.4'ün yeniden doğrulaması koşar (`EvGate.revalidate`, kuyruktaki kartın kurulmadan önce geçtiği
  denetim) ve oyuncunun sabahki hamleleri dünyayı taşıdıysa not sessizce `dropped` satırına döner (`EvHistory.withdraw`),
  yoksa 00:00'da yazılmış bir not 10:00'da artık doğru olmayan bir dünyayı anlatırdı.
- Hatırlatıcı: durumdan türer (`MailClock.reminders()`: kapı, term sheet, aday dosyaları, Risk ve Genişleme'deki hesap,
  ayrılma riskindeki çalışan); ilk görüldükleri an `GameState.desk_arrivals`'a yazılır (günlük dağıtımın sonunda ve her
  saat), `Inbox.desk` yalnız gelmişi listeler. Frank'in satırı `GameState.mentor_line_at` gelince, haber bandının satırı
  pencere açılınca görünür.
- Saat: 00:00'ın saatlik dilimi `advance_day()`'den önce koşar; o dilimde `TimeManager.is_rolling_over()` doğrudur ve
  `MailClock.now()` yeni tiki sayar, yoksa dilimin okuması bir önceki günün geliş saatini görürdü.
- Kayıt: şema 17; `mail_outbox`, `desk_arrivals`, `mentor_line_at` ve girdilerin `at` alanı varsayılan taşır, eski kayıttaki
  öğe saatsiz açılır ve her zaman gösterilir. Göç yoktur.
- Ekran: gelen kutusunun liste satırı ve kart başlığı geliş saatini "ss:dd" yazar, şimdiki saati değil (`Inbox.date_text`).
- Kapsamda olmayanlar: sprint planının 08:00'deki tutuşu (kapı mail değil, günü başlatma eşiğidir), sol rayın rozet sayaçları
  (`attention_count`, durumdan okunur), ofis taşıma toast'ı. Açık: dönem özeti ve ilk Ar-Ge notu teslim anında gelen
  kutusunu kendiliğinden açıp saati durdurur, yani artık gece yarısı değil mesai içinde, çoğunlukla öğleye yakın bir
  saatte (`main._open_note`).

*Neden.* Faz B görevi (sahip kararı 2026-10-16, Karar 21 ve kabul 4.4): gün 00:00'da dönünce
sıradan bir mail gece yarısı düşüyor, oysa sabah 09:00 ya da 10:00'da gelmesi gerekir. Geliş saati bir kez çekilir ve saklanır;
görünürlük okuma anındadır, bu yüzden yükleme, toplu adım ve toplantı atlaması aynı kuralla doğru çalışır.

### §27.28 · Faz B2: tutarın seam'den gelmesi, kalıcı memnuniyet izi, kişiye moral

*Belge ne diyordu.* §8.1: bir etkinin tutarı kartta düz sayıdır (`amount`, `delta`, `value`); `satisfaction_delta`
hesabın görünen memnuniyetini yazar ve B2B'de bir tikte silinir (hedefe geri çekilir); moral `change_morale` ile tek
kişiye, `morale_all` ile bütün çalışanlara yazılır.

*Ne yapıldı.* Olayın bedeli olayın ölçeğinden türer ve oyuncunun gördüğü sayı uygulananla aynıdır.
- `amount_seam` + `amount_mult`: bir etkinin tutarı global seam'in değeri çarpı `amount_mult`'tur (seam büyüklük verir,
  çarpan işareti taşır); tek yardımcı `EvEffects.amount(e)` yürütücünün, `EvChips.describe`'ın, `on_expire` işaret
  denetiminin ve botun `_cash_delta_of`'unun okuduğu yerdir. Lint seam'in kayıtlı ve global olmasını ister; işaret
  denetimi seam yerine çarpana bakar.
- `trust_delta {amount, accounts, per_sprint, until}` (nötr): kalıcı iz `CustomerRegistry.set_trust_offset` üstünden
  yazılır (sınır `B2BConstants.clamp_trust`). `accounts` `slot` (kartın müşteri slotu) ya da `decision_line` (bekleyen
  sprint kararının hattını kullanan B2B hesapları, büyük hesap önce). Defter haftada 2,8 puan affedilir ve memnuniyet bir
  tikte en çok sprint adımı kadar yürür; çipin "to"su bu yüzden oyuncunun bir tik sonra okuyacağı değerdir
  (`B2BSalesSystem.satisfaction_next_tick`), `from` şimdiki değerdir: hesap hedefindeyken −6 → "58 → 55", −8 → "58 → 53";
  hedefin dışında yürüyen hesapta o yürüyüş de "to"ya girer. Tikte −3, −2 ve −1'in izi görünmez (bir sonraki tik sıfıra
  iner); bu bir tasarım sorusudur (R). Süren biçim tek yerde: `per_sprint` + `until` (`{line_cleared: hat}` ya da
  `{step_live: adım}`; değer düz kimlik ya da `EvEffects.DECISION`, bekleyen karar kartının kendi hattı ve adımı)
  `GameState.trust_drains`'e yazılır (tek yazıcı `B2BSalesSystem`, şema 17 içinde varsayılanla). Her sprint kapanışı
  (`SprintSystem._close`, `sprint_closed`'tan önce) biten satırı düşürür, kalanın miktarını hesapların defterine ekler;
  düzeltme kartı hattı kapanışta aynı `_close`'ta temizlediği için o sprint ücret almaz. Çip yalnız biçimin kendisini
  yazar ("her sprint sonunda memnuniyet −3").
- `morale_crew {crew, amount}` (nötr, kişiye moral): `crew` `incident_crew` (bedeli ödeyenler), `card_crew` (bekleyen karar
  kartının atananları) ya da `speaker` (kartın çalışan slotu); her kişiye `HRMoraleSystem.apply_delta`, kurucu moral
  almaz ve listeden düşer. Çip adları (ilk adlar) yazar, dört kişiyi geçince ilk iki ad ve `EFFECT_NAMES_MORE`
  ("ve {n} kişi"); geçmiş satırı adları saklar. Ödeyen kuralı (Karar 6) tek fonksiyondadır, `SprintSystem.payers(hat)`:
  önce koşan sprintte hattın kartlarına atanmış geliştirici ve testçiler (ürün ve tasarım rolü olmayanlar), yoksa Görevler
  matrisinde Yapım ya da Test işini tutan herkes, kurucu hariç ve tasarımcı ile PM dahil; ikisi de boşsa ödeyecek seçenek
  kilitlidir.
- Yeni fiiller dört yerde: `EvLint.WRITER_VERBS`, `EvEffects.NEUTRAL_VERBS`, `EvChips.describe`, `event_chip_coverage`
  (`fixture.b2_chips`'in fiilleri). `fixture.b2_chips` `--b2b-shot=chips`'in kartıdır.
- Vakalar `event_amount_seam`, `event_trust_delta_lasting`, `event_morale_payers`.

*Neden.* Faz B görevi (Karar 5, 6 ve 8): bedel olaydan türer, "ertelemeyi alışkanlık yapan kaybeder" kalıcı bir izle
mümkündür (görünen memnuniyet bir tikte silinir) ve yükü ekibin kimin üstüne düşeceği kişi kişi okunur.

### §27.29 · Faz B3: gecenin acil durumları, gece kapısı, ikinci tutuş

*Belge ne diyordu.* §11.2: karar sırası terminal uyarı, süresi dolan kâğıt, `critical`, sonra sınıf; §11.3: saati karar kapısı
tutar (kabuk, kart gösterilince). Kesinti tek kartın işiydi (`product.outage`: sunucu aşınca gelir, üç sabit şık, sabit $6.000
telafi), olasılığı havuzun zarıydı ve gece hiçbir kuralı yoktu.

*Ne yapıldı.* Gece kesintisi bir sistemin zarıdır; sistem kartı adıyla ister, gece yalnız o açılır.
- `IncidentSystem` (Ürün, HARITA): 00:00'ın günlük diliminde zar yalnız karar verir (olay var mı, gecenin hangi dakikasında
  başladı), kart başlangıçtan sonraki ilk tam saatin saatlik diliminde `EventGate.request` ile istenir. İstek reddedilirse olay
  başlamamıştır. Kabul edilirse `TimeManager.hold_clock("incident")` toplu gece adımını o saatte durdurur ve `clock_batch_ended`
  kartı açar (kartın damgası açılış saatidir); kabuğun kendi `event` tutuşu ayrıdır, ikisi de cevapta kalkar. Tutuş
  `event_resolved`'da, kart gösterilmeden düşerse batch sonunda bırakılır; başsız koşuda kabuk olmadığı için tutuşu yalnız
  bu sistem taşır ve cevaplamayan harness saati sonsuza dek durdurur (bu yüzden `IncidentSystem.rolls`).
- Gece kapısı: `EvQueue._shown` mesai penceresi dışında yalnız `night` girdisini görünür sayar (girdi alanı, `_admit` yazar:
  `urgent` etiketli kart ya da `immediate` istek; `force_fire` de); saatsiz girdi her zaman görünür. Kepenk kartı ve kâğıdın
  son uyarısı da mesai başına kadar bekler: "gece yalnız acil durum kartı açılır" kuralı onları da kapsar (B1'in
  "acil sayılır, 00:00'da kalır" satırı yalnız geliş saatini söylüyordu); sahibin onayı bekliyor. `EvQueue.rank`
  `urgent` etiketli kartı -1'e koyar, terminal uyarının (0) ve süresi dolan kâğıdın (1) önüne.
- `incident {act}` (ekonomik, sistem kartı): servisin açılacağı saat, hesapların kalıcı izi ya da kredisi, kitlenin kaybı ya da
  ücretsiz ay `IncidentSystem.plan(act)`'ten hesaplanır ve uygulanır; çip (`EvChips._incident_parts`), geçmiş satırı ve uygulama
  tek sözlüğü okur.
- `select: "asked"` (`EvScope`): slot yalnız isteyenin verdiği varlığa bağlanır; isteğe bağlı slot verilmezse boş kalır.
  Kartın `sender_desk` alanı çalışan slotu boşken gönderen adını (`MAIL_SENDER_SERVER_ALERT`) söyler.
- Lint: `system` kart O3 ve O4'ten muaftır; konuşan çalışan ve hesap kartın konusu değildir.
- `product.outage` ve `EV_PRODUCT_OUTAGE_*` kalktı; `product.incident_outage_b2b` ve `_b2c` geldi. Seam'ler `olay.*`.
- Vakalar `incident_gap_and_spread`, `incident_night_hold_resumes`, `incident_scale`, `incident_save_roundtrip`.

*Neden.* Faz B görevi (Acil durumlar ve Karar 21): acil durum seyrek, sürpriz ve gerçek gelir, her seçenek kime neye mal olacağını sayıyla
söyler ve gece yalnız acil durum açılır.

### §27.30 · Faz B7: söz olayı, testi kısaltma

*Belge ne diyordu.* §11 ve ch11: sprint karar kartları (`urun.decision_card_late`, `urun.crunch_finishes`) bekleyen karar
kartı üzerinden okunur; söz yalnız günlük süpürmeyle kırılır ya da kartın sürümde çıkmasıyla tutulur ve söz tarihi
yaklaşırken oyuncuya hiçbir kart gelmez. Kartın sürümde hatalı çıkma ihtimali tek sabitti (`faulty_chance`) ve yalnız test
rolü olmadan yapılan test onu açardı.

*Ne yapıldı.* Söz tarihi yaklaşınca oyuncu sıkıştırılır; kartı sistem ister.
- `SprintSystem.late_promise` sprintin son haftasında bu sprinte söz verilmiş (açık, `due_sprint` bu sprint) bir kademenin
  hiçbir kartı ekibin hızıyla yetişmiyorsa {kart, sözler, en büyük hesap} verir; `_ask_promise` haftanın ataması yapıldıktan
  sonra `product.promise_due`'yu ister (hesap `customer` slotunda, kartta çalışan ilk çalışan `employee` slotunda;
  yoksa gönderen kurucunun notudur, `inbox.card_sender`). Sprintin tek kesintisidir: `record_interrupt("promise")` yazılır
  ve o haftanın karar kâğıdı çekilmez (`_request_decision` `late_promise()` doluysa döner). Olayın kaydı
  `GameState.product.promise_due` kart istenmeden yazılır (koşullar ve metin `urun.promise_*` seam'lerini okur), motor
  reddederse silinir. Kart karar kartı değildir: kartı dondurmaz, `decision` alanı yazılmaz. Koşulu üç leaf'tir
  (`urun.sprint_running`, `urun.sprint_last_week`, `urun.promise_open >= 1`); kâğıt masada kalıp dünya ilerlerse gösterimde
  yeniden doğrulamada düşer.
- `decision_card_late` ve `crunch_finishes` kart kimliği alır (`card_late(id)`, `crunch_finishes(id)`); karar seam'leri karar
  kartının kimliğini verir. Atanmış kartın mesaisi, `_end_week` gibi, haftanın atamasını koruyarak oynanır
  (`_finish_sprint`); karar bekleyen kart, kâğıt cevaplanınca haftanın ataması baştan yapıldığı için, yeniden atanarak (`_play_out`).
- Yeni fiiller: `sprint_card_test {act: cut}` (nötr; söz olayının kartının kalan test işi yarıya iner: test payı düşer, kart
  `cut` olur), `promise_extend` (nötr; açık sözler `due_sprint + 1`, `Promise.extended`, bir kez; bedeli seçeneğin kendi
  `trust_delta {accounts: promise}`'ı, önce yazılır), `promise_break` (ekonomik; açık sözler `PromiseRegistry.break_promise`
  ile bugünkü yoldan kırılır; sprintin süpürmesi sözleri zaten kırdıysa kâğıdın süre dolumu bir şey yapmaz),
  `morale_crew {crew: promise_crew}` ve `sprint_hours {promise}` (çip saat yazmaz, "Söz tutulur" der). Üçü `SYSTEM_VERBS`'tadır.
- Testi kısaltmanın bedeli çipte yüzdeyle değil sonuçla yazılır ("kart: test işi yarıya iner"); hatalı çıkma ihtimali tek
  fonksiyondur, `SprintSystem.escape_chance(kart)` (testi test rolü olmadan yapılan kart `faulty_chance`, kısaltılmış kart en az
  sprint.json `promise.cut_test_escape` [WORKING]); `_close` zarı ondan okur.
- Memnuniyet çipleri oyuncunun bir tik sonra okuyacağı değerdir: ertelemede `trust_plan`, bırakmada
  `B2BSalesSystem.satisfaction_after_break` (anlık −20, iz −12, sonra hedefe yürüyüş).
- Vakalar `promise_due_fires_when_late`, `promise_cut_test_escape`, `promise_extend_once`, `promise_break_chain`.

*Neden.* Faz B görevi (Karar 14): söz tarihi yaklaşan oyuncu ya riske girer (test), ya takımı yorar (mesai), ya hesaba
bedel öder (ek süre) ya da sözü bırakır; hiçbiri bedelsiz değildir ve çipler bedeli sayıyla söyler.

### §27.31 · Faz B8: sürüm anının teşekkür notu, anahtar dönen metin seam'i

*Belge ne diyordu.* §27.17: seçeneği tek ve etkisiz kart nottur ve gövdesi geçmişte okunur kalır; ama metin (TYPE_STRING) seam'i
satırda donmaz, çünkü satır çevrilmiş söz taşımaz (§7.4). Gövdesi metin seam'i okuyan her kartın satırı gövdesiz kalıyordu.

*Ne yapıldı.* Sürüm çıkınca müşteri kısa bir teşekkür yazar; not, adını bir ürün kademesinden alır.
- `customer.release_thanks`: `class: info`, tek düğmeli not (`EvPresenter.is_note`; not yolu kota tüketmez, bu yüzden §27.13'ün "canlı içerikte `info`
  kart kalmadı" cümlesi eskir), `tick: request`, `latch_key: entity`, `system: true`; `SprintBridges.thank` sprint kapanışında hesap başına `EventGate.request(id, {customer})` ile ister. Gönderen
  hesabın `contact()`'ıdır, kart B1'in `at` kuralıyla mesai içinde gelir. Gövdesi `by_seam: musteri.thanks_variant` ile 14
  gövdeden biridir (söz tutuldu 5, istek karşılandı 4, acil durum hızla kapandı 5; ertelenmiş söze ve gündüz kapanan olaya uymayan
  gövdeler `SprintBridges._thanks_pool`'da elenir, aynı tetikleyicide son kullanılan dönmez).
- `musteri.met_feature` kademenin adının ANAHTARINI döner (`PROD_STEP_*`). `EvPresenter.freeze_seams` artık metin seam'ini
  boşsa ya da anahtarsa satırda tutar ve `_interpolate` anahtarı çizerken ekranın diline çevirir: satır dil taşımaz (§7.4), geçmiş
  gövdesi çizilir ve dil değişince yeni dilde okunur. Anahtar olmayan, boş olmayan metin seam'i eskisi gibi donmaz.
- Sürüm kaydı `thanks: [{customer, trigger, feature, variant}]` taşır (hesap başına en çok bir, sürümde en çok üç; öncelik söz,
  istek, acil durum), acil durum kaydı (`GameState.incident.open`) `act` taşır ve `IncidentSystem.quick_fix` hızla kapanan
  olayı yaşayan hesabı verir. B2C güncellemesinin yorumları sürümden bir tik sonra `_fill_actual`'da seçilir (`reviews`).
- Vakalar `release_thanks_each_kind`, `release_thanks_limits`, `release_thanks_incident_scope`, `release_reviews_pick`,
  `release_through_close`.

*Neden.* Faz B görevi (Karar 16 ve 17): sürüm anında müşteri teşekkür eder ya da kullanıcılar yorum yazar; teşekkür notu
oyuncunun gelen kutusunda okuyacağı tek şeydir, gövdesi geçmişte düşmemeli.

### §27.32 · Faz B4: ay sonu, ödeme, bozulma ve fırtına acil durumları, "Sprinti durdur"

*Belge ne diyordu.* §27.29: acil durum gece kesintisidir ve kartın damgası açılış saatidir; olay motoru sprintin kartlarına dokunmaz,
ertelenen hatanın kalıcı bedeli yoktur.

*Ne yapıldı.* `IncidentSystem` beş türü taşır (`outage`, `month_close`, `checkout`, `regression`, `storm`; ağırlıklar sprint.json
`incident.weights`). Zar yine 00:00'da yalnız karar verir; tür dünyanın izin verdikleri (`_allows`) arasından ağırlıkla seçilir ve
mail damgası türe göre çekilir: ay sonu kapanışı 22:10 ile 22:55 (kart 23:00), ödeme ve bozulma mesai başından 10 ile 50 dakika sonra,
fırtına 11:00 ile 16:00. Sürümü hatalı kritik hattı bozan hafta zarsız `regression` gelir (`_regression_line`: sürüm kaydının
`faulty`'si ile kritik hatların kesişimi).
- `EventGate.request(id, ctx, immediate, stamp)`: `stamp` kartın mailinin gelmiş sayıldığı mutlak dakikadır (şimdiden ileri olamaz);
  `EvEngine._admit` onu `MailClock.arrival` yerine kayıt `at`'ına yazar. Kesintinin damgası açılış saatidir ve parametre almaz.
- Kartlar `customer.incident_month_close`, `product.incident_checkout`, `product.incident_regression`,
  `product.incident_review_storm` (`system: true`, `tick: request`, etiketler `critical` `urgent` `incident`). Gövdesi hatta göre
  değişen kartlar `by_seam: olay.variant` varyantlarını taşır (ay sonu 3, fırtına 4, bozulma 18); lint gövde uzunluğunu en uzun
  varyanttan okur, çünkü panel bir varyant gösterir. Ay sonu kartı `sender_title` anahtarını taşır: `Inbox.contact` hesabın alıcısını
  o unvanla gönderen yapar (sektörün sabit unvanı yerine).
- Yeni fiil `sprint_fix_first {line, bugs}` (nötr, `SYSTEM_VERBS`): `line: "incident"` açık olayın hattıdır (`EvEffects.line_of`,
  `DECISION` ile aynı kalıp); `SprintSystem.fix_first(line, bugs)` hattın düzeltme kartını `put_first` ile koşan sprintin başına
  alır (sprintteyse başa taşır, ikinci kart açmaz), sürüm notundayken ve koşan sprintin son gecesi mesai bittikten sonra sonraki sprintin
  başına. `bugs` kendi hattı olmayan olayın (ödeme) hata deposuna düşürdüğü hatadır. Çip `fix_first_bumps` ile kayan kartın adını yazar
  (bugünkü sırada biten, kart başa girince bitmeyen ilk kart; yoksa çip yoktur: `SILENT_VERBS`); satır uygulananı saklar.
- `incident {act}` cevapları: `now`, `founder`, `evening`, `morning`, `morning_credit`, `morning_free_month`, `defer`,
  `defer_free_month`. Erteleme B2B'de etkilenen hesaplara `trust_delta`'nın süren biçimini yazar (hemen `defer.trust`, her sprint
  kapanışında `defer.per_sprint`, `until line_cleared`; hattı kapatan kapanış ücret almaz), B2C'de `GameState.incident.drains`'e
  haftalık kitle payı yazar (`daily_tick` önce onu öder, hattında hata kalmayan satırı düşürür). Ödemede kitle kaybı ödeyemeyen kişilerin
  payıdır ve çipe var olan kitle çipiyle yazılır.
- `morale_crew {crew: incident_crew}` ve `olay.payers` olayın hattını okur (ödeyen kuralı B2).
- Seam'ler `olay.version` (metin: sürüm etiketi; satırda donmaz, bu yüzden bozulma kartının geçmiş satırı en son açık olayın sürümünü
  okur, `olay.clock` gibi bilinen kısıt), `olay.affected_accounts`, `olay.line_users`, `olay.shares`, `olay.variant`.
- Bot: `RunProbe._pick_emergency` acil durum kartını fiile göre cevaplar (`fix_none` kolu erteler, öbürleri `sprint_fix_first` seçer;
  kilitliyse ilk açık seçenek); cevapladığı an `PROBE STOP` basar (düzeltme kartı başa girdikten sonraki yük). `*_free` preset'leri
  `no_stop` anahtarıyla "Sprinti durdur"u hiç seçmez. `--sprint-probe` `incident=<tür>@<tik>` her türü zorlar, türün ihtiyacı
  olan hatayı bir tik önce kurar ve cevaplanan olaydan sonra planı yeniden okur (`SPRINTPROBE REPRED`), kapanış onunla karşılaştırılır.
- Vakalar `incident_month_close_window`, `incident_gates`, `incident_regression_fixture`, `incident_checkout_fix_card`,
  `incident_defer_ends_with_line`, `incident_sprint_stop_moves_the_card`.

*Neden.* Faz B görevi (Karar 1, 8, 9 ve 20): beş acil durum seyrek ve gerçek gelir; her cevap kime neye mal olacağını sayıyla söyler,
"Sprinti durdur" bedelini sprintten kayan kartın adıyla öder ve ertelemek kalıcıdır ama hattı kapatan sprintte biter.

### §27.33 · Faz B5: kâğıt motoru, kâğıt sözleşmesi, kesinti sırası

*Belge ne diyordu.* §27.11 madde 4: `SprintSystem`, koşan bir kart için sprintin 2. haftasının tikinde deterministik hash'le
(`decision.rate`) `decision.cards`'tan bir kartı ister; kâğıdın konuşanı yoktur (gönderen kategoriden ya da kartın kendi
slotundan gelir); §3.1: mandalın `one_shot`, `max_fires` ve `cooldown_weeks` alanları birbirinin alternatifidir.

*Ne yapıldı.* Kâğıt sprint başına tek zarla gelir ve konuşanı kartta o fazda çalışan kişidir.
- `SprintSystem._request_decision`: sprintin kâğıt fırsatında (1 haftalık sprintte `_begin`, 2 haftalıkta ilk haftanın sonu) tek zar
  `EvDice.unit("paper", gün, "sprint")` atılır, ihtimal `sprint.json` `decision.sprint_chance` (`{"1": 0,3, "2": 0,5}`, bir ve iki haftalık sprintte
  ayrı [WORKING, onay bekliyor]; sprintlerin en az üçte biri kâğıtsız kalır). Zar atılan sprint `GameState.product.decision_sprint`'tedir
  (eski kayıtta `.get(…, -1)`): aynı sprintte ikinci kâğıt istenmez. Havuz `decision.cards` ağırlıklı sırayla denenir (ağırlık
  `1 / (1 + decision.seen_weight × EvLatches.fires)`, `seen_weight` 2 [WORKING, onay bekliyor]; sıra `u ^ (1 + seen_weight × görülme)`
  anahtarıyla, yani yerine koymadan ağırlıklı çekim) ve her kâğıt sprintin bitmemiş kartlarında sırayla; kartın koşulları bekleyen
  kartı okuduğu için `product.decision` (`{card_id, event_id, speaker}`) istekten önce yazılır, ret gelirse silinir. `decision.rate` ve kart
  başı haftalık `hash()` zarı kalktı; `--sprint-probe` `rate=` her iki süreye aynı ihtimali verir.
- Hafta ataması kâğıttan önce yapılır (`_staff_week`: `_assign`, sonra kâğıt, kâğıt gelirse yeniden `_assign`): konuşan istek anında yakalanır
  (kartın `assignees`'i dolu), kâğıt gelince kartı beklediği için `assignees`'i boşalır (`card_decision_requested` anında okunur).
- **Kâğıt sözleşmesi.** Kâğıt kartının JSON'unda `speaker_role` (karakterin rolü: `product_manager | designer | developer | tester |
  founder`), `stage` (`any | design | dev | test`: kartın o anki fazı, `SprintSystem.role_of`) ve `pool_group` (`pm | designer | developer |
  tester | no_tester | solo | system`: havuzun sayım grubu; motor okumaz). Konuşan `EventGate.request(id, {"employee": id})` ile bağlanır,
  kurucuysa `{"founder": id}`; kartın scope'unda o türden slot şarttır (lint §17.7: bilinmeyen rol, aşama, grup ya da slotsuz kâğıt hata).
  `_speaker`: kartın o haftaki `assignees`'inden rolü uyan ve fazı uyan ilk kişi; PM kâğıdında çeyreğin PM'i (`SprintCatalog.quarter_pm()`) ve
  konu sprintteki müşteri isteği kartıdır (`customer` slotu isteğin hesabıdır; PM'in atanması değişmez); payı Destek'te kalan kişi
  atanmadığı için konuşmaz, tasarımcı kâğıdını kartta atanmış PM söylemez. `speaker_role`'ü olmayan kâğıt konuşansızdır (`sprint_late` dahil
  bugünkü altı kâğıt B6'ya kadar böyle çalışır).
- **Kesinti sırası.** `record_interrupt("paper")` kâğıt gelince yazılır; söz olayı ya da acil durum gelen sprintte kâğıt gelmez
  (`_paper_blocked`; bugün saatini bekleyen öbür acil durumda da), kâğıt gelen sprintte `IncidentSystem.daily_tick` yalnız servisin
  çöktüğü türü (`SERVICE_DOWN`: kesinti, ödeme) yaşatır: öbür tür, seçilmiş hâliyle
  (hat, dakika) `GameState.incident.shifted`'e kalır ve kâğıtsız ilk sprintte `pending` olur (kaybolmaz).
- **Mandal.** `blocked_reason` `max_fires` ve `cooldown_weeks`'i birlikte uygular (koşuda en çok 3, 52 hafta); GDD §3.1'in "alternatifler"
  cümlesi kodda böyle değildir ve `latches.gd` yorumu düzeltildi. Kâğıtlarda `latch_key: run`.
- Prob: `SPRINTPROBE PAPER|<tohum>|<sprint>|<kâğıt>|<konuşan>` ve `PAPERSUM` (kâğıtsız sprint oranı).
- Vakalar `paper_speaker_is_assignee`, `decision_one_per_sprint`, `decision_no_fourth_show`, `paper_interrupt_order`, `paper_empty_sprint_ratio`;
  fikstür kâğıtları `data/events/cards/_fixtures/paper_*.json`.

*Neden.* Faz B görevi (Karar 10 ile 13): sprint başına en çok bir kâğıt gelir, bazı sprintlerde hiç gelmez, konuşan o kartta o aşamada çalışan
kişidir ve bir sprintte en çok bir kesinti olur.

### §27.34 · Faz B6b: yazılımcı, testçisiz ve tek kurucu kâğıtları, hattın yeniden yazımı, karar kartının testi

*Belge ne diyordu.* §27.33: `speaker_role` tek bir roldür ve `_speaker` ilk uyan kişiyi alır; konu hesap yalnız PM kâğıdında
bağlanır; `ProductState.line_blocked` hiçbir hattı kapatmaz; `damage_product` sözlükte vardır ama kolsuzdur; `sprint_card_test`
söz olayının kartının fiilidir ve yalnız sistem kartı yazabilir (V2); `product.sprint_late` konuşansız bir kâğıttır ve her geride
kalan kartta gelir; kâğıtlar sprintin kartına dokunan fiillerini "Efor +2" gibi kartın adını söylemeyen çiplerle gösterir.

*Ne yapıldı.* Havuza yazılımcı (10), testçisiz (3) ve tek kurucu (6) kâğıtları girdi; bedel seçeneğin kendisidir ve çip sayıyı söyler.
- `speaker_role` bir rol ya da rol listesidir: `_speaker` kartta çalışan, rolü listede olan ilk kişiyi alır (`sprint_untested_old_screens`
  yazılımcıyı ya da kurucuyu, `sprint_late` çalışan rollerinin hepsini söyler; konuşan kurucuysa `founder` slotuna bağlanır). Lint
  §17.7 listeyi öğe öğe sınar. O4 (her seçenek kartın konusuna dokunur) `speaker_role` taşıyan kartta uygulanmaz: kâğıdın konusu
  sprint kartıdır, slotları gönderen ve hesabı adlandırır. `sprint_card_test` ve `sprint_fix_first` `WRITER_VERBS`'e geçti
  (kâğıt yazabilir); `sprint_fix_first` O2 için sonuç fiilidir (başka kart kayar).
- Kâğıdın konusu hesap `customer` slotunun `select` kipidir (`SprintCatalog.paper_account`): `line_top` kartın hattını kullanan en
  büyük hesap, `line_newest` en yeni imzalayan (kartın `where`'i pencereyi daraltır), `request` kartı isteyen hesap (istek olmayan
  kartta boş: zorunlu slot kâğıdı o kartta getirmez); ikinci çalışan `employee` slotunun `sprint_dev` kipidir.
- `line_harden {line, weeks}` (nötr): `ProductState.harden_line` `mvp_line_harden` {hat: yeni hata düşmeyen son tik} yazar
  (`GameState.FLAG_TYPES`, tipli), `ProductState.line_blocked` okur; `weeks` yoksa `sprint.json` `paper.harden_weeks` [WORKING, 26].
  Zarla gelen hata (`SupportSystem.hourly_tick`'in bildirim çekilişi ve `SprintSystem._close`'un hatalı çıkma zarı) kapalı hattı
  atlar: çip "26 hafta yeni hata çıkmaz" der ve söz bu iki yol için doğrudur. Oyuncunun seçtiği hata düşer: kartı bilinen hatayla
  çıkarmak (`sprint_card_trim {bugs}`, `leaks`) da çipin yazdığı gibi yeniden yazılmış hatta açık hata olur. İkinci yeniden yazım
  süreyi uzatır, kısaltmaz.
  `damage_product {line, bugs}` (nötr; daha önce kolsuzdu; GDD'nin `damage_product(scope, amount)` imzası böyle okunur): hemen `ProductState.add_bugs`; oyuncunun kendi seçtiği bedel olduğu için
  yeniden yazılmış hatta da düşer. `line` `decision` (karar kartının hattı) ya da hat kimliğidir, paylaşılan hat temel kimlikle
  yazılır (`SprintCatalog.in_product`).
- `sprint_card_test {card: decision}` karar kâğıdının kartının testini yarılar (`SprintSystem.cut_test(kart)`: `cut_promise_test`'in
  yerine geçti, söz olayı kartını `promise_card()` ile verir). Çip yalnız "kart: test işi yarıya iner" der: yüzde yazmaz (sahip:
  "kart hata ihtimali yazmayalım") ve söz tutulmuş demez; hatalı çıkma ihtimali `SprintSystem.escape_chance`'tendir.
- Çipler: kartın puanı kartın adıyla yazılır (`EFFECT_CARD_POINTS`; eski `EFFECT_SPRINT_EFFORT` ve `EFFECT_SPRINT_PROGRESS` kalktı),
  yapılmış işi silmek `EFFECT_WORK_LOST` (kırmızı; tutar `urun.decision_card_done` seam'inden, çip ve uygulanan aynı sayı), anlık
  hata `EFFECT_NEW_BUGS`, yeniden yazım `EFFECT_LINE_HARDEN`, kâğıdın hattın düzeltmesini başa alması `EFFECT_FIX_FRONT`
  (`sprint_fix_first {front: true}`), kurucu tekken fazla mesai `EFFECT_SPRINT_HOURS_SOLO`. Fiil satırları kartı adlandıran alanları
  taşır (`of`, `SprintSystem.card_ref`): geçmiş satırı kart silinse de adı okur.
- `product.sprint_late` (ekip) ve `product.sprint_late_solo` (kurucu tek) `system: true` sistem kâğıtlarıdır; ikiye bölünmeleri, motorun
  bir seçeneği gizleyememesindendir (ekip ve kurucu fazla mesaisi ayrı seçeneklerdir, oyuncu yalnız kendisininkini görür). Koşul:
  karar kartı bir müşteri isteği (`urun.decision_kind`), sözü yok (`urun.decision_promised`), sprintin son haftasında bu hızla
  yetişmiyor ve fazla mesaiyle yetişiyor (`urun.decision_card_late`, `urun.crunch_finishes`). Fazla mesai sprintin saatini ×1,25
  yapar; ekipte `sprint_crew` (`SprintSystem.payers("")`: ekip, kurucu hariç) morali −5 alır, kurucu tekken kurucunun verimi 1 hafta
  −%15. `crunch_finishes` cevaptan sonraki atamayı oynar: kâğıt cevaplanınca ekip karta döner.
- Seam'ler (`seams_product.gd`): `urun.decision_{kind,line,line_name,tier,card_done,line_bugs,line_accounts,root_bugs,root_cause,
  test_untouched,line_first_version,promised,by_founder}`, `urun.sprint_has_tester`, `urun.durability_tier`,
  `urun.security_tier` (güncelleme kâğıdı yalnız kurulmuş Güvenlik hattına hata yazar), `urun.security_bugs`, `urun.security_fix_planned`, `urun.weeks_to_month_end`, `urun.paper_{server_bill,
  loss_small,loss_mid,signup_loss}`; `urun.decision_line` paylaşılan hattı temel kimlikle okur. Bedel sayıları `sprint.json` `paper`
  bloğunda [WORKING]: `b2c_loss`, `signup_loss`, `root_min`, `harden_weeks`.
- Üç takip kâğıdı (`sprint_rewrite_bugs`, `_owner`, `_reader`) ve "İki yol var" ile "Dışarıdan destek"in eski kartları kalktı; bedelleri
  yeni kartların seçeneklerine katlandı (inceleme kartı devreder, okuma kurucunun verimini yer, hemen geçiş 2 açık hata yazar).
- Vakalar `paper_line_harden`, `paper_card_effects`, `paper_seams`, `sprint_late_for_requests`; geride kalan kartın konuşansız kâğıdı
  rolünü, eski vakalarda `product.sprint_late`'in yerine, `fixture.paper_crunch` üstlendi.

*Neden.* Faz B görevi (Karar 10 ile 13; W2): her kâğıt kime neye mal olacağını sayıyla söyler, bedel A'nın hata deposundan geçer
(yeniden yazım ve anlık hata) ve kâğıt yalnız gerçekten sıkışmış kartta gelir.

### §27.35 · Faz B6a: PM, tasarımcı ve testçi kâğıtları, kartın işini sonraki sprinte bırakma

*Belge ne diyordu.* §27.33 ve §27.34: kâğıdın bedeli kartın puanı, silinen iş, hemen düşen hata ya da hattın yeniden yazımıdır; kartın işini
sonraki sprinte bırakmanın ve kartı bilinen hatayla çıkarmanın yolu yoktur; `trust_delta` ertelemenin "düzelene kadar" bedelini yazar ama
kademenin çıkmasına bağlayamaz; kâğıdın hesabı `customer` slotunda `line_top`, `line_newest` ve `request` kipleriyle bağlanır; bir seçenek
yalnız bir pazara aitse onu gizleyen yol yoktur (§3.3: kilitli seçenek görünür kalır); `expire_note` düz metindir; yenileme günü
`tick_requests`in içinde tek bir ifadedir.

*Ne yapıldı.* Havuza PM (6), tasarımcı (7) ve testçi (8) kâğıtları girdi (W2); bedel seçeneğin kendisidir ve çip sayıyı söyler.
- `sprint_card_trim` (nötr; `WRITER_VERBS`, O2 için sonuç fiilidir): `share` karar kartının `paper.trim_share` payını (yukarı yuvarlanır, yapılmış
  işin ve 1 puanın altına inmez) karttan alır, `amount` kartın hiç almadığı iştir, `follow` ikisini ve `paper.reopen_points`'i sonraki
  sprintin kartı yapar, `bugs` ve `line` kart çıkınca o hatta açık hata yazar. Takip kartı (`follow: true`) kademesi aynı özellik kartıdır:
  kademeyi tutmuş kartı silen `plan_next` onu silmez ve kademenin lisansı yeniden kesilmez. Hata `leaks`te bekler, kapanışta
  `pending_faulty`ye girer (ürün canlı olana dek bekler) ve sürümü hatalı saydırmaz. Plan (`SprintSystem.trim_plan`) çipin, geçmiş
  satırının ve uygulamanın tek kaynağıdır.
- `sprint_card_outlook` (nötr, etkisiz): çip kartın bu sprintte biter mi sorusunu planın oynatmasından (`SprintSystem.finishes_with`)
  okur, `amount` aynı seçeneğin öbür fiillerinin ekleyeceği puandır (`EFFECT_CARD_LATE`, `EFFECT_CARD_ON_TIME`); satır uygulanınca kartın
  bittiğini kaydeder. `sprint_card_first` kartı sprintin başına alır (`SprintSystem.decision_first`, `put_first`) ve çip yalnız kayan
  kartı yazar; `b2b_month_discount` hesabın aylık ücretinin `paper.renewal_discount` payını `retention` etiketiyle tek seferlik gider yazar.
  Dördü de `WRITER_VERBS`tedir; `sprint_card_trim`, `_outlook` ve `_first` O2 için `CONSEQUENCE_VERBS`tedir.
- `trust_delta`: `accounts: second` (aynı kademeyi isteyen öbür hesap, `SprintCatalog.second_account`) ve `until: {step_live}` kademe çıkana
  kadar her sprint sonunda yazar, çip `EFFECT_TRUST_UNTIL_SHIPS` der. Paylaşılan bir hat ya da kademe kart verisinde temel kimlikle
  yazılır (`line_shared_mobile_k1`) ve fiil onu ürünün kimliğine çevirir (`SprintCatalog.in_product`).
- Slot seçicileri (`EvScope`): `customer` `select: line_top | line_warehouse | line_newest | line_slow` karar kartının hattını kullanan
  hesaplardan seçer (`SprintCatalog.paper_account`; depo işi sektörleri ve koltuk eşiği `sprint.json` `paper` bloğunda), `employee`
  `select: sprint_dev` ekibin sprint payı en büyük yazılımcısını verir. Pazara özgü seçenekleri olan dört kâğıt B2B ve `_b2c` olarak iki
  karttır (`phone_too`, `spec_unclear`, `empty_state`, `slow_many`).
- `expire_note` bir varyant kümesi olabilir (`{by_seam, variants}`; `EvEngine` süre dolumunda çözer): renk kâğıdının ikinci gelişi başka bir cümleyle
  kapanır. Renk kâğıtları tek kartta birleşti (`product.sprint_design_customer_colors`); iki gelişi `urun.colors_again` ve fiyat seam'leridir
  (`colors_hand`, `colors_central`: ikinci gelişte her biri bir puan fazla), süre dolumu ilkinde memnuniyet −8, ikincide kart +3.
- `SprintBridges.next_renewal_day(hesap)` yenileme penceresinin gösterdiği yenileme günüdür ve talebin penceresiyle `pm_renewal` aynı
  ifadeyi okur; `urun.decision_renewal_saved` kart yetişmiyorken, yenileme bu sprintin kapanışından sonra ve sonrakinden önceyken ve kart başa girince
  bu sprintte bitiyorken doğrudur.
- Seam'ler `urun.decision_{second_account, request_votes, step, phase, trim_finishes, phone_late, renewal_saved, test_half}`,
  `urun.{cut_test_finishes, responsive_shipped, design_late, paid_plan_open, colors_*}`, `urun.paper_{phone_points, ask_silent,
  first_screen_loss, coupon_loss, test_phones}`; `urun.decision_request_votes` B2C istek verisi (C) gelene kadar 0 döner, o yüzden PM'in B2C kâğıtları
  (`_b2c` ikizleri ve `pm_core_first`) bugün gelmez; `urun.decision_second_account` bugün hiç dolmaz (bir kademeyi tek hesap isteyebilir), `pm_two_accounts`
  uykudadır. Sabitler `sprint.json` `paper` bloğunda [WORKING].
- Vakalar `paper_card_trim`, `paper_outlook_reads_the_plan`, `next_renewal_day_one_place`, `paper_renewal_card_first`,
  `paper_colors_two_arrivals`, `paper_trust_until_ships`, `paper_account_selectors`, `paper_cards_render`; görsel `--event-shot=<kâğıt>` kâğıdı
  `main._seed_paper_world`te kurar.

*Neden.* Faz B görevi (Karar 10 ile 13; W2): PM, tasarımcı ve testçi kâğıtlarında her seçenek kime neye mal olacağını sayıyla söyler (karta,
sonraki sprinte, hesaba, kitleye ya da kasaya) ve bedelsiz çıkış yoktur.

### §27.36 · Faz Q K5: taban merdiveni eksenden alana, eksen seam'leri kalktı

*Belge ne diyordu.* §27.26 ve Ürün §14: B2C taban kartları üç eksenin okumasına bağlıdır; `urun.axis_innovation`,
`urun.axis_stability`, `urun.axis_experience` ham eksen okumasını (0-120), `urun.floor_innovation`, `urun.floor_stability`,
`urun.floor_experience` her eksenin tabana göre durumunu (`''`, `warning`, `crossed`) verir; `launch_leak` ile `password_rule`
Kararlılık 10'un altındayken açılır; taban kartlarının gövdesi "aynı zayıflık" der ve adını söylemez. Çıta her faz geçişinde
`EventBus.phase_bar_raised` yayardı.

*Ne yapıldı.* Merdiven alana geçti (`docs/tasks/faz_cde/PRD_FAZ_Q_KALITE.md` Karar 12):
- `ProductRead.floor_ratios()` canlı B2C üründe Çekirdek ile U'ya giren üç alanın (Gelir yok) seviyesini kitlenin kendi referansına
  (`ProductQuality.expectation(alan, {"audience": true})`; ürün sayfası küçük kitlede 2★ tabanını okur, merdiven okumaz) böler; beklentisi 0 olan alan sayılmaz, B2B'de boştur (orada geride kalmanın
  dili satış kaybıdır). `floor_state(oran)`: `FLOOR_WARNING_RATIO` (0,6) altı `warning`, `FLOOR_CROSSED_RATIO` (0,4) altı `crossed`
  [WORKING] onay bekliyor. `worst_floor()` oranı en düşük alanı ve basamağını verir, eşitlikte `ProductQuality.weights` sırasında öndekini.
  Süre sayacı yoktur: bugünkü sıra (uyarı kartı, o kartın geçmişi, sonra kayıp kartı) kalır.
- `axis_floor_warning(area)` ve `axis_floor_crossed(area)` aynı adlarla alan kimliği taşır, alan başına kenarda bir kez yayılır
  (`ProductRead.emit_edges`); `EvSignals.BINDINGS` aynı kalır (slotsuz). `phase_bar_raised` ve yalnız onun için duran `_prev_phase` silindi.
- Silinen seam'ler: altı eksen seam'i (`urun.axis_*`, `urun.floor_innovation/stability/experience`). Yeni seam'ler: `urun.floor_state`
  (en kötü alanın basamağı), `urun.floor_area` (o alanın kısa adının yerelleştirme anahtarı, `PRODUCT_AREA_*_SHORT`; çevrilmiş metin
  değil, çünkü `freeze_seams` anahtarı saklar ve gövde dil değişince yeniden çevrilir), `urun.trust_level` (Güven & Ölçek seviyesi,
  ekranın yarım adımı).
- Kartlar: `b2c_floor_signal` ve `b2c_floor_churn` `urun.floor_state` okur, gövdeleri CSV anahtarı yerine kart JSON'unda satır içidir ve
  `{seam:urun.floor_area}` ile alanın adını söyler (CSV değerinde `{seam:}` olmaz; iki `EV_PRODUCT_B2C_FLOOR_*_BODY` anahtarı silindi);
  ikisi `tools/lint_v3_frozen.json`'dan çıktı (yeniden yazılan kart listeden çıkar) ve O2, O4, O5, T2, T3 onlarda artık hatadır.
  `shutdown_notice` ile `b2c_creator_feature` "hiçbir taban aşılmadı" koşulunu `urun.floor_state != crossed` olarak okur.
  `launch_leak` ile `password_rule` "Kararlılık < 10" yerine `urun.trust_level == 0` okur; `urun.enterprise_trust` koşulu aynı.
- "Açık hatayla düşmez" kuralı korunur: `urun.trust_level` hattın kademesini okur (`ProductQuality.level`), açık hata kademeyi indirmez;
  `launch_leak` ve `password_rule` hata yüzünden eşiğe inmez.
- Vaka `floor_ladder_areas`; `product_read_catalogue` yeni sinyal ve seam adlarını sınar.

*Neden.* Faz Q K5: ürünün tek kalitesi alan seviyesidir, eksen okuması kalkar; B2C taban kartı "aynı zayıflık" yerine alanın adını söyler,
böylece oyuncunun karşılığı olan hamle (o alana kart koymak) görünür olur.

### §27.37 · Faz Q K3b: satışçının kapanışı ürün uyumuna bağlandı, kayıp mailla gelir

*Belge ne diyordu.* §27.13: haftalık satış özeti bir gelen kutusu mesajıdır (`sales_week`) ve masanın kapanışlarını taşır; masa anlaşması planı
dolunca her zaman imzalanır.

*Ne yapıldı.* Masa satıcısının kapanışı (`SalesRepSystem._close`) ürüne bakar:
- Adayın baktığı bir alan beklentinin altındaysa (`ProductQuality.prospect_fit(aday).loss_area` dolu) plan dolunca adayın kendi zarı atılır
  (`SalesRepSystem.lost_area`: `SalesConstants.mix_unit` ile aday kimliği, alıcı tipi ve `SALT_REP_CLOSE`; yükleme ve okuma sayısı sonucu
  değiştirmez) ve `ProductQuality.close_chance` (adayın U'sundan `CLOSE_CURVE`, [WORKING] onay bekliyor) kadar ihtimalle imzalanır. Eksik alan yoksa
  zar yoktur. Kaybedilen anlaşma görüşmenin kaybıyla aynı yoldan geçer (`SalesFinalizer.lose`) ve `EventBus.rep_deal_lost(rep_id, prospect_id, area)`
  yayılır; sinyal motora bağlı değildir, kanalı ölçüm için taşır.
- Kayıp kurucuya haftada en çok bir mailla gelir: mesaj türü `sales_loss` (`{rep, company, area}`, `MessageSystem.post`, saati durdurmaz, mesai
  penceresinde gelir). Aynı haftanın öbür kayıpları `sales_weekly_loss_rows` bayrağında satır olur ve `sales_week` mesajının `lost` argümanıyla gider;
  özet yalnız kayıpla da açılır. Kurucu masadaysa kaybı mailsiz satırdır. Yeni bayraklar `FLAG_TYPES`'ta; şema aynı, eksik bayrak varsayılanla açılır.
- Hesabın hat üyeliği alıcı tipinin eksen ağırlığından sektörün alan ağırlığına geçti (`ProductQuality.used_areas`, `USE_AREA_MIN` 0,15: Çekirdek ve iki
  vurgu); `SprintCatalog.line_accounts` ve `B2BSalesSystem.account_bugs` bunu okur; onları okuyan olay seam'leri (`olay.affected_accounts`,
  `urun.decision_line_accounts`) ve kartların hesap sayıları değişmeden yeni üyelikle çalışır.
- Aday sektörü: Sağlık ve Tekstil ops_cautious'ın, Medya tech_exacting'in listesinin sonuna girdi; sektör çekimi tip çekiminden ayrı ikinci karıştırma
  turuyla yapılır. İstek alanı sektörün vurgu 1 alanıdır (`sprint.json`'daki `archetypes` bloğu silindi).

*Neden.* Faz Q Karar 14 (zar), Karar 3 ve Karar 10 (sektör ve üyelik): oyuncu zayıf alanı kuraldan değil satıştan öğrenir; satışçının kaybı da alanın adını
taşır ve bakılacak yeri gösterir.


### §27.38 · Faz Q K7b: eksen zinciri silindi, ürünün tek kalitesi alan seviyesi

*Belge ne diyordu.* §27.10 ve §27.36: ürünün ekonomiye bağlanan kalitesi hat kademelerinden türeyen üç ham eksen değeridir; sprint kapanışında
`SprintBridges.push_axes` onu GameState bayraklarına yazar, kademe damgası (`ProductState.stamp_step`) ve kapı-üstü bonusu onu çarpar,
`QualityModel` eksen okumasını, faz çıtasını ve doyum eğrisini hesaplar.

*Ne yapıldı.* Bütün okuyucular K3 ile K7a arasında alana taşındığı için zincir silindi:
- Hat verisi (`data/product/lines/*.json`, Ar-Ge'nin gizli hatları) eksen, eksen puanı ve ikincil eksen puanı taşımaz. `ProductLines` eksen doğrulamasını,
  K(n+1) ≥ 1,6 × K(n) denetimini, `axis_of`, `line_ids_by_axis`, `weighted_points`, `net_gain`, `KANO_COEF`, `AXIS_OWNER_AREA` ve `UPGRADE_RATIO_MIN`'i
  kaybetti; kademe kaydında `kano` yoktur. Kimlik hatlarının iş profili dağılımı (2 geliştirme · 1 test · 2 tasarım, `IDENTITY_PROFILE_SHAPE`) ve Ar-Ge'nin
  dört gizli hattınınki (1 · 2 · 1, `ResearchTree.HIDDEN_PROFILE_SHAPE`) yüklemede denetlenir. Ar-Ge `design_system` etkisinin iç adı `design_effort` oldu.
- `QualityModel` yalnız rakip matematiğidir (`grow`, `composite_quality`, `DEFAULT_AXES`); eksen okumaları, faz çıtası, doyum eğrisi ve `AXES` silindi.
  Rakip bileşkesinin ağırlıkları `ProductCatalog.QUALITY_AXES`'ten `RivalCatalog.COMPOSITE_AXES`'e taşındı (`Rival.composite()` argümansızdır) ve rakip
  sayıları değişmedi (`rival_composite_table`). `ProductCatalog.get_quality_axes`, `axis_label` ve `RivalRegistry.get_player_rank_in_startup_league` silindi.
  Rakip bileşkesinin üretimde okuyanı yoktur; rakip modeli de elden geçmelidir.
- `SprintBridges.push_axes` ve `SprintSystem._go_public`'taki çağrısı silindi; üç kalite ekseni bayrağı ve kademe damgası (`ProductState.STEP_REALIZATION`,
  `step_realization`, `stamp_step`, `line_realization`) `FLAG_TYPES`'tan çıktı. Bu dört bayrak eski kayıtta durur; `SaveCodec.RETIRED_PRODUCT_FLAGS`
  onları her yüklemede, göçler ham sözlükten okuduktan sonra düşürür ve `_migrate_15` damgadan cilayı eskisi gibi türetir
  (`save_retired_product_flags`, `save_v14_build_becomes_sprint_plan`).
- `ProductRead.axis_reading`, `market_word`, `WORD_*`, `MARKET_WORD_BAND`; `ProductState.axis_readings`, `axis_reading`, `realized_dims`;
  `LineGates.above_gate_bonus` silindi. Kapı-üstü basamakları yalnız `speed_bonus_for` için durur (henüz uygulanmaz).
- Ölü metin: `PROD_AXIS_INNOVATION`, `PROD_AXIS_STABILITY`, `PROD_AXIS_EXPERIENCE`. `PROD_RND_NODE_DESIGN_SYSTEM_UNLOCK` eksen dilinden tasarım
  profili diline yeniden yazıldı.
- Debug: `PROBE SHIP` eksen alanlarını basmaz. Shot fikstürleri eksen bayrağı yazmaz, kademe damgası kurmaz; tema, finans ve Ar-Ge fikstürleri hatsız
  `saas_ops` yerine ERP hatlarını kurar (`_ERP_SHIPPED_LINES`).
- Vakalar: silinenler `axis_reading_replaces_not_adds`, `above_gate_bonus_ladder`, `quality_half_sat_25`, `b2b_v1_lands_mid_band`; yeni
  `save_retired_product_flags` ve `rival_composite_table`; hat, profil, Ar-Ge ağacı, kayıt ve okuma yüzeyi vakaları profile ve alana göre yeniden yazıldı.

*Neden.* Faz Q Karar 1 ve 11: ürünün tek kalitesi alanların seviyesidir; eksen puanı, damga ve kapı-üstü bonusu ekonomiyi sürmüyordu ve okuyanı
kalmamıştı. Rakip modeli kendi üç boyutunu tutar ve ürünle bağı koptu.


### §27.39 · Faz Q K3a: görüşmenin ikna terimi ürün uyumunu okur, kayıp nedeni alan adı taşır

*Belge ne diyordu.* §9.6 ve Satış §5.1: görüşmenin kalıcı ikna terimleri motorun `{seam, delta}` biçimidir ve `EvDice.modifier_lines` ipucu listesini kurar;
ürün terimi `urun.axis_reading` adını taşıyordu ve ürünün eksen okumasından geliyordu. Alıcının ürün sorusu "kararlılık sicili"ydi
(`probe_stability_record`) ve eksik ürünün kayıp nedeni `LOSS_STABILITY`'ydi.

*Ne yapıldı.*
- Terim `urun.product_fit` oldu: `delta = W_PRODUCT_FIT × clamp(U ÷ FIT_SCALE − 1, −1, 1)`, U adayın `ProductQuality.prospect_fit`'idir. Etiketi sayı
  yazmaz (`SalesMeetingSystem._fit_line`: "Ürün uyumu · Çekirdek Zayıf", yani müşterinin eksik bulduğu alan, yoksa Çekirdek, ve bu masanın o alanı okuduğu
  sözcük); zar ipucundaki kategorisi `MEETING_CHIP_PREP`'tir. `urun.axis_reading` gibi `urun.product_fit` de `EvSeams`'e kayıtlı bir seam DEĞİLDİR: yalnız
  ipucu listesinin anahtarıdır ve kartlar onu okuyamaz.
- Kararlılık sorusu yerine her alıcı tipinin üç vurgu sorusu vardır (`probe_emphasis_trust`, `probe_emphasis_integrations`, `probe_emphasis_onboarding`;
  kriter sektörün vurgu 1 alanıdır, cevapların ortak tablosu `EMPHASIS_ANSWERS`). Güçlü cevabın kapısı vurgu alanının Yeterli ya da üstü olmasıdır; eksik
  alanı olan müşteri ilk soruyla bir kez itiraz eder.
- `LOSS_STABILITY` yerini `LOSS_WEAK_AREA`'ya bıraktı: hedefi müşterinin eksik bulduğu alanın kimliğidir. Görüşme kaybı ve pazarlıktan nedenli kalkış
  `SalesFinalizer.lose`'dan geçer; geri dönüş kapısı o alan adayın bağlamında Yeterli olunca açılır. `SaveManager._migrate_17` eski kararlılık
  kaybını (hesabın hafızası, kayıp günlüğü, aday) `weak_area` + `trust` yapar.
- Vakalar `sales_meeting_reads_fit`, `sales_emphasis_question`, `sales_weak_area_loss`.

*Neden.* Faz Q Karar 9: oyuncu görüşmede zayıf ürünü bir sayı olarak değil müşterinin ağzından, alanın adıyla duyar ve hamlesi (o alana kart koymak) görünür olur.


### §27.40 · Faz Q K14: dışarıdan iş mekaniği kalktı

*Belge ne diyordu.* §27.34 ve §27.35: yazılımcı, tek kurucu ve PM kâğıtlarının ve renk kâğıdının bir seçeneği işi dışarıya yaptırmaktı; bedeli
`sprint.json` `paper.contract_per_point` (puan başına $1.000) ve ondan türeyen `urun.paper_contract`, `urun.decision_contract_cost` ve
`urun.colors_cost` seam'leriyle `add_cash` (`contractor` etiketi) yazılırdı. `product.sprint_dev_contractor` kâğıdının konusu bu seçenekti.

*Ne yapıldı.*
- `paper.contract_per_point` ve üç seam silindi. Seçenek `sprint_dev_root_cause`, `sprint_pm_scope_grew`, `sprint_solo_backup`,
  `sprint_solo_rushed_code` ve `sprint_design_customer_colors`tan çıktı (kart ve metin bloğu); kalan seçenekler ve çipleri değişmedi.
- `product.sprint_dev_contractor` kâğıdı konusu kalmadığı için tümden silindi (kart, `decision.cards` adı; havuzda yazılımcı kâğıdı 10'dan 9'a,
  `paper_card_effects` toplamı 21'den 20'ye indi).
- Dışarıdan hizmetin kalan biçimleri (`contractor` etiketli kart giderleri, testçi kâğıdı, lisans kâğıdı) Faz Q K16'da kalktı (§27.42).
- Vaka `paper_colors_two_arrivals` fiyat dizisini `[2, 4]` ve `[3, 5]` okur.
- Makullük defteri (`plausibility.gd` `_plausibility_of`) bir slotun seçici düğümlerini yalnız slot bağlıyken sınar: isteğe bağlı
  slot boş kalınca (kurucunun söylediği `sprint_untested_old_screens`, `employee` bağsız) kıdem düğümünün öznesi yoktur ve kapı
  eskiden onu FAIL sayıyordu. Havuz değişince uzun koşunun dördüncü tohumunda göründü.

*Neden.* Faz Q Karar 24: mekanik tamamen kalkar; kodu, verisi ve metni temizlenir.


### §27.41 · Faz C C1: sunucunun doluluğu kesintinin şansını büyütür, kesinti kartı yükü söyler

*Belge ne diyordu.* §27.29 ve §27.32: gecenin zarı açık hatadan ve sunucu kademesinden gelir; sunucunun doluluğu zarda yoktu
(`IncidentSystem.load_mult` 1 dönerdi) ve kesinti kartının gövdesi yalnız `olay.night_accounts` varyantlarını taşırdı.

*Ne yapıldı.*
- Yük kesintinin şansına girer, başka hiçbir türün değil: `load_mult` (`sprint.json` `incident.load`: yük %90'a kadar 1, %100'e
  kadar 1,5, üstü ya da kapasitesiz canlı ürün 2,5) tavandan (`p_max`) sonra uygulanır ve yalnız kesintinin payına. `hazard`
  türlerin ağırlıklarını kesintininki yük katıyla çarpılmış (`_weights`) ve çarpılmamış toplamıyla orantılar: haftanın ihtimali
  `p × kademe × (W + (L − 1) w_kesinti) / W`, tür seçimi aynı ağırlıklarla; kesintinin haftalık şansı tam L katına çıkar, öbür
  türlerinki değişmez ve tavan katı yutmaz.
- Zar anındaki yük (`InfraSystem.load_percent`) kesintinin `pending.load`'ına, oradan `open.load`'a yazılır; yeni seam
  `olay.outage_load` (TYPE_INT, yüzde; başka tür için 0). `product.incident_outage_b2b` ve `_b2c` gövdesi `by_seam: olay.outage_load`
  varyantlarına bölünür (`0` düz gövde, `91` yük cümlesi eklenmiş gövde: yük %90'ın üstündeyken). B2B'de her `olay.night_accounts`
  varyantı kendi içinde ikiye bölünür: varyant metni `{by_seam, variants}` olabilir (`EvPresenter.resolve_text` özyinelemelidir,
  `seams_of` iç seam'leri de toplar, lint anahtarları iç içe de denetler).
- Vakalar `capacity_step_immediate`, `load_mult_steps`, `incident_gap_and_spread`.

*Neden.* Faz C Karar 1: dolu sunucu yalnız kesinti ihtimalini artırır; ekranda yazan kat aynen uygulanır (tavan yük çarpanını yutmaz).


### §27.42 · Faz Q K16: dışarıdan hizmetin her biçimi kalktı

*Belge ne diyordu.* §27.40'ın "Kalanlar" maddesi: K14'ten sonra `contractor` etiketi ve `FIN_ONETIME_CONTRACTOR` kâğıt olmayan kartların ve
testçi kâğıdının tek seferlik giderini yazıyordu; `urun.paper_tester_week` (`paper.outside_week_mult`) ve `urun.paper_license` ayrı kâğıtların
bedeliydi.

*Ne yapıldı.*
- Seçenek (kart bloğu, metin ve CSV satırı) düştü: `product.sprint_untested_own_code` "Bir haftalığına testçi tut", `product.launch_leak`
  "Açığı bulanı bir haftalığına tut", `product.support_overflow` "Mesajlar için saat ücretiyle birini tut", `team.password_rule` "Dışarıdan
  birine yaptır", `team.wiped_table` "Veri kurtarma uzmanı tut, {employee} kalsın". Kalan seçeneklerin kimliği, etkisi ve çipi değişmedi;
  beş kartın kalan her seçeneği bir kaynağa mal olur.
- `product.sprint_solo_license` kâğıdı konusu kalmadığı için tümden silindi (kart, `decision.cards` adı; havuzda tek kurucu kâğıdı 6'dan 5'e,
  `paper_card_effects` toplamı 20'den 19'a indi).
- Silindi: `SprintCatalog.outside_tester_week` ve `license_cost`, `sprint.json` `paper.outside_week_mult` ile `paper.license`, seam'ler
  `urun.paper_tester_week`, `urun.paper_license` ve `urun.decision_license_year`, `FinanceSystem.ONE_TIME_LABELS["contractor"]` ve
  `FIN_ONETIME_CONTRACTOR`.
- Eski kaydın işlem listesi (`GameState.transactions`) etiketi ham kimlikle saklar ve Finans sekmesi onu olduğu gibi çizerdi:
  `SaveCodec.RETIRED_TRANSACTION_LABELS` (`contractor`) her yüklemede, `apply_game_state`in sonunda o satırları düşürür; şema artmaz.
- Dokunulmayan: ürünün zorunlu lisans gideri (`ProductLines.sum_license_cost`, hat kademelerinin `license_cost` alanı, Ar-Ge'nin
  `license_cost` etkisi, sprint başında kademenin lisansının kesilmesi) oyuncunun seçtiği bir hizmet değil ürünün kendi giderleridir.
- Vakalar: `save_drops_retired_transaction_label` yeni; `paper_seams` ve `paper_card_effects` silinenleri bırakıp güncellendi;
  `sprint_decision_card_fires_shipped` tek kurucunun aceleyle yazılmış kod kâğıdıyla çalışır (tek kurucu kâğıtları arasında yalnız kartın eforunu okuyan lisans kâğıdıydı).

*Neden.* Faz Q Karar 13: dışarıdan hizmetin her biçimi kalkar; suistimal edilebilir.


### §27.43 · Faz C C7: haftalık destek raporu bir gelen kutusu mesajıdır

*Belge ne diyordu.* §27.13: karar olmayan anlar motorun dışında `GameState.messages`'ta durur ve yalnız `MessageSystem` yazar. Destek
tarafından oyuncuya haftalık bir özet giden bir yol yoktu: açık hata ve bildirim akışı yalnız DESTEK kartında ve Ürün penceresinde okunuyordu.

*Ne yapıldı.*
- `SupportSystem.weekly_report` (haftalık tik, `daily_tick`in sonu; sprint kapanışından sonra) mesaj türü `support_week`'i yazar
  (`{rep, week, lines, news, fix}`). Gönderen `CustomerRepSystem.ranked_reps()[0]`'dır (Müşteri İlişkileri'nin en yüksek puanlı
  temsilcisi); temsilci yoksa rapor yoktur. Haftada en çok bir rapor gelir ve okunmamış eski rapor yenisi gelince düşer
  (`MessageSystem.drop_unread`); okunmuş rapor kalır.
- "Yeni" son haftanın farkıdır (`SupportSystem.report_news`): hat Öncelikli eşiğine ulaştı (`SprintCatalog.is_priority_count`), hat
  boşaldı ya da bir düzeltmeyle azaldı ama doludur (açık hata yalnız düzeltmeyle azalır; iki satır ayrıktır, bir düzeltme tek satır
  yazar), en çok hatalı hat değişti, temsilci yetişemedi. Boşsa rapor yazılmaz. Önceki hafta hata defterinde
  (`mvp_report_bugs`) ve bildirim sayacında (`mvp_report_week`, `{in, done}`) durur; ikisi de rapor yazılsın yazılmasın her haftalık
  tikte yazılır. Eski kayıtta ikisi varsayılanla (boş) okunur: yüklemeden sonraki ilk rapor boş öncekiyle kıyaslanır.
- "Yetişemedim": haftanın gelen bildirimlerinin beşte biri ya da fazlası doğrulanmadan kaldıysa (`REPORT_BEHIND_ONE_IN` 5 [ÇALIŞMA], onay
  bekliyor); metin gelen ve doğrulanan sayıyı söyler.
- Gelen kutusu raporu tablo olarak çizer (`MailPane._support_report`): hat satırları Ürün penceresinin AÇIK HATALAR satırıyla aynıdır
  (`SprintUiShared.bug_line`), altında haftanın yenileri; düğme en kötü hattın alanını SPRINT'te açar (`SprintUiShared.open_product_area`).
  "En çok istenen" bölümü ve yeni istek satırı istek tasarımıyla gelir (C6).
- Vaka `support_report_quiet_week` yeni.

*Neden.* Faz C Karar 11 (PRD Karar 12): destek temsilcisi haftada bir, yalnız yeni bir şey varsa yazar; rapor karar değildir.

### §27.44 · Faz C C2b: `finance.runway_weeks` kasa eksiyken 0 okur, 9999 "saat yok"tur ve masada bekleyen kâğıt onu yazmaz

*Belge ne diyordu.* §8.4: gövdedeki sayı seam'den okunur ve bayatlayamaz; §3.2: varyant gövde seam'in tamsayı değerine göre seçilir.
Seam'in "bu sayının saati yok" değerini kartın nasıl karşılayacağı yazılı değildi ve kâğıdın gövdesinin donmadan önce canlı okunduğu belirtilmemişti.

*Ne yapıldı.*
- `finance.runway_weeks` üst barın okuduğu gibi tam haftadır (`TimeModel.whole_ticks`, aşağı yuvarlar; önceden yuvarlıyordu ve kart ekrandaki
  sayıdan bir hafta fazla vaat edebiliyordu). Kasa eksiyse net akış ne olursa olsun 0 okur (önceden 9999 okuyordu: aynı seam kasa sıfıra
  inerken 0, sıfırın altında 9999'du ve `founder.savings_note` ile `founder.side_contract` tam kepenk anında koşullarını kaybediyordu). Net akış
  eksi değilse saat yoktur ve 9999 okunur; koşul `<` ile yazılır, `>` ile asla.
- Masada bekleyen kâğıt yalnız adları taşır (`EvPapers.names_of`); seam değerlerini cevapta ve süre dolumunda dondurur (`EvPresenter.freeze_seams`),
  bekledikçe canlı okur. `funding.monthly_update` runway 2 ile 11 hafta arasındayken gelir ve bir hafta bekleyebilir: bu sürede şirket kâra geçerse
  gövde "9999 hafta" yazardı. Gövde artık `by_seam: finance.runway_weeks` varyantıdır: `0` anahtarı runway cümlesini, `9999` anahtarı runway'den
  söz etmeyen cümleyi taşır (TR/EN onay bekliyor). Başlık ve seçenek metinleri değişmedi; başlık varyantı desteklenmiyor (`lint.gd` başlığı
  düz metin okur).
- `--event-shot` `founder.savings_note` ve `founder.side_contract`'ı birikimi biten kurucuda, `funding.monthly_update`'i kasası aylık akışının
  8,5 haftasına inmiş şirkette çeker (`:runway=profit` aynı şirketi giderini karşılarken çeker). Vaka `runway_weeks_seam` yeni.

*Neden.* Faz C Karar 7 ve 2026-10-20 seçimi: runway yalnız net akış eksideyken yazılır; kârdaki şirketin kartı hiçbir yerde saat yokken saat sayısı yazmaz.
