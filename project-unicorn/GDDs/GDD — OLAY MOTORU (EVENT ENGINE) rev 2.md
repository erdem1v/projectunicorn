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

History koşu boyunca budanmaz. Yumuşak tavana kadar süren bir koşu 104 tiktir (`EndingsSystem.SOFT_CAP_WEEK`); 1×'te varsayılan mesaide bu yaklaşık 2,6 gerçek saat eder. Böyle bir koşuda ~150-400 satır beklenir; bellek ve save boyutu ihmal edilebilir.

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
- **Maksimum 4 satır.** Fazlası "ve diğerleri" olarak toplanır.
- Sayısal döküm yalnızca dev overlay'de.
```
kalır %58        ← farklı renk tonu, hover edilebilir

  (hover)
  ▲ morali iyi
  ▲ ekipte sekiz ay
  ▼ maaşı bandın altında
  ▼ üst üste mesai
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

Oyunun maksimum hızı **4×**'tür. Hız merdiveni oyun saati başına gerçek saniyedir (`TimeModel.SECONDS_PER_HOUR`: duraklat, 10, 5, 10/3, 2,5). Hafta 08:00'de başlar ve ofis boşalınca gece atlanır; varsayılan 09-17 mesaide bir hafta 1×'te 90, 2×'te 45, 3×'te 30, 4×'te 22,5 sn sürer (`TimeModel.seconds_per_tick`).

4× bir ara modal yoğunluğu sebebiyle kaldırılmıştı: gün modelinde 3×'te bir oyun günü 3 sn sürüyordu. Haftalık modelde 4×'te bile bir hafta 22,5 sn sürdüğü için geri geldi (§27.9). Tempo bütçesi tik (hafta) bazlıdır; hız yalnız bütçenin gerçek zamandaki sıklığını değiştirir, fazlası kağıda düşer (I4).

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

**Katman 4 — Tik tavanı** Tik (hafta) başına max **2 interrupt** (`MAX_INTERRUPTS_PER_DAY`; ad korunur, bir oyun günü bir tiktir). Üçüncüsü kağıda düşer. Tavan dolarsa 1×'te 3 gerçek dakika iki hafta, yani 4 kesinti eder; bu, §13.7 çapasının (3) üstüdür. Harness bunu her hız için ölçer ve raporlar (§19.3).

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

Gerçek zaman ile oyun zamanı arasındaki bağ `TimeModel.seconds_per_tick`'tir. Varsayılan mesaide bir hafta 1×'te 90 sn sürdüğü için 3 dakika 1×'te 2, 2×'te 4, 3×'te 6, 4×'te 8 haftadır. Harness pencereyi her hız için ayrı hesaplar ve çapayı dört basamakta ayrı raporlar.

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
| MTTH (mean time to happen) | Red | CK3 kendisi terk etti (performans + istatistiksel anomali); bizim ölçekte zaten anlamsız |
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
duraklat, 10, 5, 10/3, 2,5). Varsayılan 09-17 mesaide bir hafta 1×'te 90, 4×'te 22,5 sn sürer.

*Neden.* Gün modelinde 3×'te bir oyun günü 3 sn sürüyordu. Haftalık modelde 4×'te bile bir hafta 22,5 sn sürer.
Tempo bütçesi tik başınadır; 4×'teki gerçek zaman yoğunluğunu harness her basamakta ayrı raporlar (§13.7, §19.3).

**7. Tempo sayılarının haftalık hâli ölçülmedi.**

*Belge ne diyordu.* Gün cinsinden: kart boşluğu 30, özne boşluğu 14 / 30, taban 5, ark zaman aşımı 14, varsayılan
cooldown 30; harness 50 günde bir kayıt, 365 günlük koşu.

*Ne yapıldı.* 4, 2 / 4, 1, 2, 4 hafta; harness 7 haftada bir kayıt, 52 haftalık koşu. Tik tavanı tik başına 2 kaldı.

*Neden.* Gün değeri 7'ye bölünüp anlamlı en yakın haftaya yuvarlandı; sıfıra düşen süre en az 1 hafta oldu. §13.8
geçerlidir: hiçbiri ölçülmedi. Tavan dolarsa 1×'te 3 gerçek dakika (iki hafta) 4 kesinti eder, §13.7 çapasının (3)
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
  `destek.can_start_fix_run`, `rival.leader`. Planın `rival.segment_leader` adı lint'in gerçek marka listesine
  (`EvLint.FORBIDDEN_TERMS`, "segment", §17.8) takıldı: liste kart gövdesini `{seam:}` jetonlarıyla birlikte tarar. Planın
  `urun.decision_card_left_pct`'i okuyucusu kalmayınca silindi. `sales.growth_band` çevrilmiş sözcük yerine bant id'si
  döndürür (`melting | flat | steady | fast`).
- Seçiciler: customer `largest` (en yüksek MRR), employee `most_senior` (en yüksek seviye, eşitlikte en eski işe alım).
- Fiil: nötr `fix_run_start` DESTEK'in düzeltme koşusunu başlatır (`SupportSystem.start_fix_run`), açılamazsa ret
  gerekçesini döndürür; sabit çipi `EFFECT_FIX_RUN_STARTS`.
- `EvSignals.BINDINGS`'e slotsuz `axis_floor_warning` ve `axis_floor_crossed` eklendi; B2C taban kartları onlarla
  tetiklenir.

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
satırları çarpılır ve çarpım 0,50 ile 1,30 arasına kenetlenir (`HRSystem.event_pace`). `HRSystem.productivity(c)` moral
bandı (kurucuda 1) × bu çarpımdır; `SprintSystem._points` ve `HRSystem.effective_skill` moral bandının yerinde onu
okur. Satış masası (`SalesRepSystem.close_chance`) yalnız `event_pace`'i okur: moral bandını bugün okumadığı için
verim satırındaki moral satırı satışta etkisizdir (onay bekliyor, ACIK_KARARLAR 103). Satır, son
haftası işlendiği tikte, haftayı okuyan sistemlerden sonra (günlük dağıtımda satıştan sonra) düşer. Lint §17.1: `pct` sıfır olamaz ve fiil bir arkın `on_invalidate`'inde duramaz (orada kart yoktur). Çip `EFFECT_PACE`,
`EFFECT_PACE_FOUNDER`, `EFFECT_PACE_TEAM` (bedel ya da kazanç rengi; kırmızı değil). Ekip penceresinin satır ipucu
ve ekip dosyasının VERİM bölümü verimi ve imzalı sebeplerini (`HRSystem.productivity_lines`) gösterir.

*Neden.* Sahibin verim kararları 1, 3, 4 ve 5. Satır yokken sayılar bayt bayt aynıdır: moral bandı yalnız yer
değiştirdi.

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
