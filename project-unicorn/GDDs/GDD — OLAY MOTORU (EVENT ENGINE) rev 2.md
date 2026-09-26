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

- günde verilen bir kararın 90. günde görünür bir sonucu olmalı, ve oyuncu bu bağı **kendisi kurabilmeli**.
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
- **Faz geçişi ve son koşulları.** Motor onları taşır, tanımlamaz. Tasarlandıklarında bağlama işi o modülün task'ına yazılır (§23 A1).
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
| Damga (stamp) | Kalıcı gün işareti. days_since_flag bunun üzerinden çalışır. |
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
| FlagStore | Bayraklar, süreli bayraklar, gün damgaları. | Evet |
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
tick                zorunlu: daily | hourly | scheduled | signal
class               zorunlu: interrupt | paper | info | ambient
tags                opsiyonel: [critical, quiet, promise, terminal_warning,
                                tutorial, ...]

trigger             ne zaman aday olur (§5)
condition           koşul ağacı (§5)
scope               isimli kapsam slotları ve tipleri (§4.3)
guards              bağlam kısıtları: market, faz, alt-tip, portföy
allowed_hours       opsiyonel; tanımsızsa 08:00-20:00 (§20 B10)

latch               one_shot | max_fires:N | cooldown_days:N
                    varsayılan: cooldown_days: 30
latch_key           run | entity        (varsayılan: run)
min_gap_days        havuz freni, varsayılan 30 (§13.3 Katman 1)
weight              havuz ağırlığı, varsayılan 1.0

expires_days        yalnızca class:paper için. §12.
on_expire           süre dolumunda çalışan etkiler. paper ise ZORUNLU.
expire_note         süre dolumunda ticker'a yazılan satır. ZORUNLU.

options[]           seçenek listesi (§3.3)
arc                 opsiyonel: bu kart hangi arkın adımı
```

### 3.2 Metin bloğu (locale başına)

text:

```
  tr:
    title, body
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

### 3.3 Seçenek şeması

```
id                  zorunlu, kart içinde benzersiz. Metinden bağımsız.
requires            opsiyonel koşul ağacı. Karşılanmazsa seçenek KİLİTLİ.
cost                opsiyonel: {cash, days, morale, ...}
effects[]           etki listesi (§8)
check               opsiyonel zar (§9.2)
outcome_id          history'ye ve outcome_lines'a yazılan sonuç anahtarı
```

**Kilitli seçenek asla gizlenmez.** Gri görünür, tıklanamaz, ve `locked_reasons` metnini gösterir. Koşul ağacının her yaprağı kendi "karşılanmadı" gerekçesini üretebilmek zorundadır (§5.4).

## 4. TEK KAPI

### 4.1 Hat

sinyal / tik / ark adımı / schedule

```
        ↓
  Gate.propose(event_id, context)      ← TEK PUBLIC GİRİŞ
        ↓
  ═══════════ KAPI ═══════════
   G1  içerik geçerli mi (id katalogda var mı)
   G2  sürüm kapsamı (demo / EA / full) + tutorial suppression (§11.6)
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
- `{"days_since_flag": <ad>, "op": ">=", "value": N}` ← **Frank korpusunun istediği generic primitive**
- `{"flag_expires_within": <ad>, "days": N}`
**Geçmiş**

- `{"history": "fired", "event": <id>}`
- `{"history": "fire_count", "event": <id>, "op": "<", "value": N}`
- `{"history": "chose", "event": <id>, "option": <id>}` ← callback'lerin temeli
- `{"history": "days_since", "event": <id>, "op": ">=", "value": N}`
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
day                 mutlak oyun günü
resolution          chosen | expired | dropped | forced
option_id           chosen ise dolu, aksi halde null
outcome_id          zar sonucu dahil nihai sonuç anahtarı
entities            {slot: {type, id}}  çözüm anındaki kapsam
deltas              uygulanan etkilerin özeti (debug + son ekranı için)
arc_id              varsa
```

### 7.2 Neden bu kadar kritik

Mevcut motorun en yıkıcı kusuru buydu: `_history` yazılıyor ama `get_history()` **sıfır kez** çağrılıyordu. Yani hiçbir kart "bu daha önce oldu" diyemiyordu. Callback yok, ark yok, vaat-ödeme yok. §0.2'deki tez ölüydü.

### 7.3 Sorgu arayüzü

§5.2'deki `history` yaprakları bu tablodan okur. Ayrıca:

- **Son ekranı** history'yi okuyup koşunun anlatısını çıkarabilir.
- **Ticker** son çözümlerden satır üretebilir (§18).
- **Debug paneli** tam kaydı gösterir.

### 7.4 Dil bağımsızlığı

History **yalnızca id** saklar (`option_id`, `outcome_id`). Etiket saklamaz. Oyuncu 10. günde Türkçe, 90. günde İngilizce oynasa da callback çalışır.

### 7.5 Budama yok

History koşu boyunca budanmaz. 3-5 saatlik bir koşuda ~150-400 satır beklenir; bellek ve save boyutu ihmal edilebilir.

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
  set_timed_flag(name, days)
  stamp_day(name)               days_since_flag'in kaynağı
```

ZAMANLAMA

```
  schedule_event(id, delay_days, context?, arc_id?)
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
  ticker_push(line_key, priority)   §18
```

DIŞ SİSTEM

```
  open_negotiation(type, context)   §9.4
```

TERMİNAL

```
  trigger_ending(id)
```

### 8.2 Yürütme kuralları

- **Sıralı.** Liste sırasıyla, atomik değil.
- **Geri alınamaz.** Ama her etki history'nin `deltas` alanına loglanır.
- **Kaskad aynı tikte olmaz.** Bir etkinin doğurduğu yeni koşul, **bir sonraki tikte** değerlendirilir. Sonsuz döngü riski böyle kapanır.
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

**Sayı metne gömülmez.** `SHUTTER_DAYS` gibi değerler seam'de yaşar, kart metni interpolasyonla okur. Mevcut `END_META_BANKRUPTCY_FRANK` "yedi gün" derken `SHUTTER_DAYS` 30 olduğu için bayat — bu kural o hata sınıfını kapatır.

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
| Çalışma saati / mesai yükü | 5-11 saat, >8h ×1.5 moral decay | VAR |
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
  fire: { delay_days: N }  |  { condition: {...} }  |  { signal: <ad> }
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

**`reassign`** **zaman aşımı:** `awaiting_subject` durumu **14 gün** sürerse politika otomatik `close`'a düşer. Ark sonsuza kadar askıda kalmaz.

**Örnek —** **`reassign`****:** Zeynep bir araştırma hattını yürütüyor. Zeynep gidiyor. Ark ölmüyor; masaya bir kağıt geliyor: "Zeynep'in yürüttüğü araştırma sahipsiz kaldı. Kim devam edecek?" Oyuncu birini atıyor, ark kaldığı adımdan devam ediyor. Bu, Ar-Ge rev1.4 §5.0'ın "atamalar silinmez, duraklar" kuralıyla birebir hizalıdır.

### 10.6 I-ARK — Vaat arkında on_invalidate zorunlu

`type: promise` taşıyan bir arkın `on_invalidate.policy` alanı `fade` **olamaz** ve `effects` boş **olamaz**. Boşsa **E-lint**.

**Gerekçe:** Bizim tezimiz "10. gün 90. günü etkiler." Vaat edilen bir şey sessizce buharlaşırsa oyuncu bunu bug sanır ve tez çürür.

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
| interrupt | Blocking modal | Durur | Kriz, ark dönüm noktası, süresi dolan teklifin son uyarısı, terminal telgraf |
| paper | ODA masasında kağıt | Akar | Karar gerektiren ama acil olmayan |
| info | Sekme rozeti / rapor | Akar | Aylık Ar-Ge notu, terfi uygunluğu bildirimi |
| ambient | News ticker | Akar | Rakip haberi, dünya gürültüsü, ark fade izi |

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

### 11.3 Modal kuralları

- **Aynı anda tek modal.** İkincisi kuyrukta bekler.
- **Modal SceneTree'yi durdurur.** Gün dönüşü modal kapanana kadar bekler.
- **`process_mode = ALWAYS (3)`** **zorunlu.** GameShell ve tüm interaktif çocukları. Agent varsayılanı `INHERIT`'tir ve bu bug runtime testi olmadan görünmez.
- Karar anında oto-yavaşlama uygulanır (mevcut davranış korunur).

### 11.4 ODA masası

- Masa kağıtları taşır, **kapasite sınırı yoktur** (§12.1 sebebiyle gereksiz).
- Kağıt açıldığında modal gibi davranır (zaman durur), kapatıldığında masaya döner.
- Kağıdın kalan süresi kağıdın üzerinde **görünür**. Son 3 günde görsel vurgu.
- Günlük-tik kartlarında saat gösterilmez (mühürlü kural).

### 11.5 Maksimum hız

Oyunun maksimum hızı **3x**'tir (4x kaldırıldı — modal yoğunluğu sebebiyle). Tempo bütçesi oyun-günü bazlıdır; 3x'te doğal olarak sıklaşır, fazlası kağıda düşer (I4).

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

| Yüzey | Gün | Cevapsız kalırsa |
|---|---|---|
| VC teklifi | 30 | Otomatik red (mühürlü) |
| Satın alma teklifi | 30 | Otomatik red |
| Rakip teklifi (çalışan) | 7 | Çalışan gider — "bekletildi" |
| Zam talebi | 7 | Moral düşer, ayrılabilir riski artar |
| Müşteri şikayeti | 7 | Memnuniyet düşer |
| Frank'in düşük-bahisli kartları | 14 | Sessiz kapanır, ceza yok |

**Varsayılan: 7 gün.** Para masası 30. Düşük bahisli 14.

### 12.3 Yaz izni kağıt değildir

Yaz izni talebi `class: interrupt`'tır. Erteleme kağıt zamanlayıcısıyla değil, **kartın içinde bir seçenek** olarak yaşar (Ekip rev11: ertele = −5 moral + 30 gün sonra tekrar, max 2 kez). Karşında duran bir insana "sonra bakarım" demek bir karardır, zaman aşımı değil.

### 12.4 Süre dolumu semantiği

gün == expires_on:

```
  on_expire.effects çalışır
  history: resolution = "expired"
  expire_note ticker'a yazılır (oyuncu-sonucu önceliğiyle, §18)
  kağıt masadan kalkar
```

**`expire_note`** **zorunludur.** Sessiz süre dolumu yoktur. Örnek çıktı:

Zeynep bugün ayrıldı. Teklifi bekletmiştin.

**Son uyarı:** son 1 günde kalan kağıt için `class: interrupt` bir uyarı kartı ateşlenir ve tempo bütçesi tanımaz (§13.5).

### 12.5 Kayıt/yükleme

`expires_on` **mutlak gün** olarak saklanır, "kalan gün" olarak değil. Yüklemede gün geçmişse anında çözülür.

## 13. TEMPO

### 13.1 Teşhis

Sorun sayı değil, **benzerlik**. Haftada beş farklı konuda kart normal bir şirket haftasıdır. Haftada üç Nordica kartı bir bug gibi hissettirir. 4x hızın kaldırılmasının sebebi de buydu.

### 13.2 I4 — Hiçbir kart düşürülmez

Bütçe aşıldığında kart **atılmaz**, sunum sınıfı düşer:

interrupt → paper → [ASLA silinmez]

Kağıda inen her şeyin bir cevap süresi vardır (§12), yani unutulmaz.

`class: info` ve `class: ambient` zaten bütçe tüketmez.

### 13.3 Dört katmanlı fren

**Katman 1 — Aynı kart (****`min_gap_days`****)** Bir kart ateşlendikten sonra N gün desteye dönmez. **Varsayılan 30.** Kart override edebilir (nadir).

**Katman 2 — Aynı özne** Aynı çalışan / müşteri hakkında havuz kartı sıklık freni:

- Çalışan: **14 gün**
- Müşteri: **30 gün**
**KRİTİK MUAFİYET:** Bu katman **yalnızca havuz kartlarına** uygulanır. `tag: critical` kartları ve **ark adımları muaftır.** Bir ark aynı çalışan hakkında art arda kartlar ateşleyebilir — arkın anlamı budur.

**Katman 3 — Kategori kotası (kayan 7 gün)**

| Kategori | 7 günde max |
|---|---|
| Ekip | 2 |
| Müşteri (B2B/B2C) | 2 |
| Ürün & canlı | 2 |
| Rakip & dünya | 1 |
| Yatırım / Frank | 1 |
| Kurucu | 1 |

Yan fayda: kota çeşitliliği zorlar. Müşteri kotası dolduysa motor başka kategoriye bakmak zorundadır; oyuncunun haftası tek renk olmaz.

**Katman 4 — Günlük tavan** Günde max **2 interrupt**. Üçüncüsü kağıda düşer.

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

- 5 oyun-günü boyunca hiçbir `interrupt` veya `paper` gelmedi, **VE**
- Masada cevaplanmamış kağıt **yok** (varsa ölü zaman yok; oyuncu erteliyor), **VE**
- Aktif bir modal yok
**Davranış:**

- Yalnızca **sessiz havuzdan** (`tag: quiet`) çekilir.
- Sessiz havuz kartları **kendi koşullarını geçmek zorundadır.** Kapı atlanmaz.
- **Hiçbiri uymuyorsa hiçbir şey ateşlenmez.** Sessizlik saçmalıktan iyidir.
- Katman 3 kotası tanınmaz; Katman 1 (`min_gap_days`) tanınır.
- `tutorial_active` iken devre dışı (§11.6).
**Sessiz kart yazım kuralları:**

- Mevcut duruma bakmak **zorundadır** (gerçek bir çalışan, gerçek bir müşteri, gerçek runway). Genel geçer olamaz.
- **Ekonomik etki taşıyamaz** (I2 zaten yasaklar).
- En fazla 2 seçenek, ikisi de düşük bahisli.
**Boş taban raporlanır.** Taban art arda 3 kez tetiklenip hiçbir kart bulamazsa, harness bunu **içerik açığı** olarak raporlar. Rastgelelikle örtülmez. Not: kart sayısı arttıkça tabanın tetiklenme ihtimali doğal olarak düşer; sessiz havuz için ayrı bir hacim hedefi konmamıştır.

### 13.7 Kalibrasyon çapası

Normal hızda ortalama **2-3 dakikada bir** karar yüzeyi. Hiçbir 3 dakikalık dilimde **3'ten fazla** interrupt yok.

Bu çapa auto-play harness'ında otomatik ölçülür (§19.3): binlerce koşuda "en yoğun 3 dakika" ve "en uzun sessizlik" raporlanır. Kalibrasyon gözle değil, veriyle yapılır.

### 13.8 ⚠️ ÖLÇÜLMEDİ

§13.3, §13.4 ve §13.6'daki tüm sayılar **çalışma değerleridir ve hiçbiri ölçülmemiştir.** Kategori kotaları, faz çarpanları, 5 günlük taban eşiği, 30/14 günlük fren pencereleri — hepsi playtest'te değişecektir. §13.7 çapası bir ölçüm aracıdır, bir tasarım kanıtı değil. Bu sayılara mimari bağımlılık kurulmaz; hepsi tek bir tuning yüzeyinde toplanır.

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
  papers[]           {event_id, context, expires_on, opened_before}
  budgets            {name: kalan}
  tempo_window       son 7/30 günün ateşleme kayıtları
  ticker_queue       §18
```

### 16.2 Zamanlanmış geri çağrı ASLA fonksiyon değildir

Yalnızca `{event_id, fire_on_day, context, arc_id}`. Fonksiyon pointer'ı / closure serialize etmek dangling pointer ve kod-yükleme açığı üretir. Davranış id'den yeniden çözülür.

### 16.3 Zaman mutlak

Tüm gün alanları **mutlak oyun günü**dür, "kalan tik" değil. Save/load ve hız değişimleri zaman matematiğini bozmaz.

### 16.4 Migration

- Motor kendi bloğunu versiyonlar. Şema v9 → v10 geçişinde `event_engine` bloğu eklenir.
- Yüklemede katalogda olmayan `event_id` bulunursa: kayıttan temizlenir, error.log'a yazılır, **crash edilmez**.
- Öznesi olmayan ark yüklemede iptal edilir (`fade`), gösterimde crash etmez.
- Bilinmeyen bayrak = false (additive namespace).

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
- **W** Tanımsız bayrağa referans (yazım hatası yakalar)
- **W** Hiç okunmayan bayrak (ölü)

### 17.2 Ulaşılabilirlik

- **E** Ulaşılamaz koşul (`all: [flag X, flag_unset X]`)
- **W** Hiçbir yerden başlatılmayan ark (öksüz)
- **W** Hiç ateşlenemeyen kart (hiçbir tetikleyici/ark/sinyal göstermiyor)
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

- **E** `class: paper` fakat `expires_days` yok
- **E** `expires_days` var fakat `on_expire` yok
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
- **W** `min_gap_days` 7'nin altında (kasıtlıysa suppress edilir)

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

- Kendi **FIFO kuyruğu**, kapasite ~20, taşınca en eski düşer.
- Motor tek çağrıyla besler: `ticker_push(line_key, context, priority)`.
- Motoru **asla bloklamaz**, tempo bütçesi **tüketmez**.
- Kuyruk save'e yazılır (§16.1).

### 18.3 Üç öncelik

```
1. oyuncu-sonucu    expire_note, ark fade izi, karar sonrası teyit
2. dünya / rakip    rakip hamlesi, sektör haberi
3. atmosfer         genel gürültü
```

**Oyuncu-sonucu satırları asla düşürülmez.** Kuyruk doluysa önce atmosfer, sonra dünya satırı feda edilir.

## 19. ARAÇLAR

### 19.1 Katalog doğrulayıcı

§17'nin tamamını koşar. CI'da ve pre-commit'te. Baseline/suppress desteği (§17.10).

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

**Her iki modda ortak:** save/load her 50 günde bir enjekte edilir, koşu bozulmaz.

**Çıktı raporu:** kart bazında ateşleme sayısı, kategori dağılımı, ortalama karar aralığı, en yoğun/en seyrek dilimler, boş-taban sayacı.

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
| A6 | Aynı gün iki çalışandan zam talebi | Per-entity latch farklı anahtarlar; ikisi de geçerli. Katman 4 ikincisini kağıda düşürür |
| A7 | B2C koşusunda B2B selector | G6 guard. Kart market: b2b etiketli değilse kabul edilmez; selector tip-güvenli handle döndürür |
| A8 | Birden fazla ürün varken "ürün" belirsiz | Kapsam açık olmak zorunda. Belirsizse kabul edilmez |
| A9 | Kart öznesi kurucu | founder ayrı kapsam tipi; employee seçicisi asla kurucuyu döndürmez |
| A10 | Özne var ama uygun değil (izinde, atanmış) | Guard koşuluyla kart kendi uygunluk kriterini yazar |
| A11 | İki çalışan arasında çatışma kartı | İsimli slotlar (employee_a, employee_b). Aynı varlık iki slota atanamaz |
| A12 | Slot adları yazılmamış çoklu kapsam | E-lint (§17.12). Runtime'a hiç ulaşmaz |

### B. Zaman ve zamanlama

| # | Vaka | Cevap |
|---|---|---|
| B1 | Zamanlanmış günü geçmişte kaldı (3x hız, eski save) | fire_on_day <= bugün → hemen proposal'a girer. Atlanmaz |
| B2 | Tek tikte birden fazla geçerli kart | §11.2 öncelik sırası. Deterministik |
| B3 | Bir etkinin sonucu başka kartın koşulunu doğru yapıyor | Kaskad bir sonraki tike ertelenir. Sonsuz döngü kapanır |
| B4 | Modal açıkken gün döndü | Modal zamanı durdurur; gün dönüşü bekler |
| B5 | Faz geçişi ark ortasında | Ark faz-agnostik yaşar. Ölmesi gerekiyorsa invalidate_when açıkça yazılır |
| B6 | Koşu bitiyor (iflas) ama bekleyen ödemeler var | Terminal her şeyi keser. Schedule temizlenir, history korunur (son ekranı okur) |
| B7 | Build sürerken kurucuyu başka işe geçiren kart | Build bar auto-pause zaten kural. Kart bunu gövdesinde söyler; sürpriz olmaz |
| B8 | Hız 3x'te tempo | Bütçe oyun-günü bazlı. 3x'te doğal olarak sık gelir; fazlası kağıda düşer |
| B9 | Aynı gün hem schedule hem sinyal aynı kartı öneriyor | Latch tekilleştirir. İkincisi sessizce düşer |
| B10 | Gece saatlerinde interrupt | allowed_hours guard'ı. Tanımsızsa 08:00–20:00 varsayılan |
| B11 | Kağıdın son uyarısı ile süre dolumu aynı güne denk geldi | Uyarı önce (öncelik 2), dolum ertesi gün. Uyarı ateşlenemezse dolum yine de çalışır |

### C. Kayıt ve şema

| # | Vaka | Cevap |
|---|---|---|
| C1 | Modal açıkken save | Kart dondurulmuş bağlamıyla serialize. Load'da yeniden doğrulanır (ya da A1) |
| C2 | Ark ortasında save/load | Ark nesnesi tam serialize: step, vars, subject, state, parent |
| C3 | İçerik güncellendi, eski save'de olmayan bayrak | Additive namespace; yok = false |
| C4 | Save'de artık olmayan event_id | Migration temizler, error.log, crash yok |
| C5 | Zamanlanmış geri çağrı | Asla fonksiyon. Sadece data |
| C6 | Save scumming | Zar hash(seed, day, event_id, option_id). Aynı seçenek = aynı sonuç. Ironman'de zaten tek slot |
| C7 | Şema v9 → v10 | event_engine bloğu eklenir, migration zorunlu |
| C8 | Kağıt süresi save sırasında doldu | expires_on mutlak gün. Load'da geçmişse anında çözülür |
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
| E2 | Aynı kart taze instance ile iki kez sırada | id bazlı dedupe |
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
| F8 | Ticker'a aynı anda çok satır | §18 FIFO + öncelik. Oyuncu-sonucu düşürülmez |
| F9 | Oyuncu yüzdeyi hover etmiyor | Yüzde zaten görünür. Modifier bilgisi opsiyonel derinliktir |
| F10 | tutorial_active iken normal kart geçerli oldu | G2 reddeder. Havuz ve taban susar |

### G. Ark özel

| # | Vaka | Cevap |
|---|---|---|
| G1 | Ark adımı tempo kotasına takıldı | Ark adımları bütçe tanımaz (§13.5) |
| G2 | awaiting_subject sonsuza kadar sürüyor | 14 gün sonra otomatik close |
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
- `END_META_BANKRUPTCY_FRANK` "yedi gün" ↔ `SHUTTER_DAYS: 30` → seam interpolasyonu
- `raise_requested` ve `employee_eligible_for_promotion` sinyalleri → emit noktaları açılır

## 23. AÇIK MADDELER

Bu GDD'nin **bilinçli boşlukları**. Hiçbiri motorun inşasını bloklamaz.

| # | Madde | Durum | Motorla ilişkisi |
|---|---|---|---|
| A1 | Faz geçişleri + Series A kapısı + Sonlar (slot 8/9) | Tasarlanmadı | Motor tag: critical ark iskeletini taşır. Tasarlandığında o modülün task'ına "motora bağla" maddesi konur. Motorda değişiklik gerekmez |
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

**`tick: "request"` — hiçbir saatin süpürmediği kart.** Beş kart ailesi, yalnız bir SİSTEMİN
görebildiği bir kenarda ateşleniyor: destek talebinin yaşlanması, sürümün yayına çıkması,
tasarım turunun bitmesi. Bunlar için sinyal de havuz da yanlış cevap — sinyal, kartın kendi
sonucunun yaydığı sinyali beklemek anlamına geliyordu (bkz. §27.5); havuz ise otoriter bir
beat'i ağırlıklı çekilişe bırakmak. `tick: "request"` "beni hiçbir saat süpürmez, adımı veren
bir çağıran tek kapıdır" demektir. Süpürme ve havuz onu zaten dizge eşleşmemesiyle atlıyor, o
yüzden ek kod gerekmedi; eklenen tek şey `Origin.REQUEST` ve G4'te ONA AİT BOŞ KOL.

**`Origin.REQUEST` G4'ün saat eşleşmesini ATLAR.** `tick`, kartı KİMİN SÜPÜRDÜĞÜNÜ söyler,
kartın adını kimin verebileceğini değil. Satış sekmesinin iki düğmesi `tick: daily` bir kartın
adını verir ve vermelidir; aksi hâlde adı verilen her kartın ayrıca süpürülmesi gerekirdi, ki
bu tam olarak yeniden inşanın sildiği İKİNCİ KABUL YOLU'dur.

**`text.<locale>.body` bir SÖZLÜK olabilir: `{by_seam, variants}`.** Series A kapısı kendi
gövdesini reddetme sayısına göre yeniden yazıyordu (eski `_refresh_gate_copy`), yani varyant
metin şema onun için bir kelimeye sahip olmadan ÖNCE oyunda vardı. EVENT_POOL_DESIGN_v1 §5.7'nin
dar teslimi: genel bir tesis değil, ihtiyacı olan tek kart için. Eksik varyant EN KÜÇÜK anahtara
düşer, böylece aralığı aşan bir seam boş kart değil ilk gövdeyi verir.

**`{seam:ad.soyad}` metin içinde.** §8.4'ün mekanizması. Sebebi yayınlanmış bir hata:
`END_META_BANKRUPTCY_FRANK` "Yedi gün kırmızıda kaldın" diyor, `SHUTTER_DAYS` ise Frank v6'dan
beri 30. Düzyazıya yazılmış bir sayı sessizce bayatlar ve hiçbir kapı bunu yakalayamaz.
Seam'den okunan sayı bayatlayamaz. B2B ailesi aynı şeye DÜZYAZI için ihtiyaç duyuyor: şikâyet
gövdesi sektöre göre değişiyor, o yüzden tek kart `{seam:musteri.complaint_voice}` taşıyor —
her biri bir sektörün cümlesini gömen on beş neredeyse-aynı kart yerine.

**`scope.<slot>.select` için altı yeni seçici.** `escalated`, `expansion_ready`,
`open_request` (müşteri); `account_rep`, `support_lead` (çalışan); `expiring_sheet`,
`meeting_pending` (yatırımcı). Gerekçe yapısal ve §4.3'ün söylemediği bir şey: **koşul, BAĞLANMIŞ
TEK özneye karşı sınanır.** "En mutsuz hesabı seç, sonra tırmandırılmış mı diye sor" — bu iki
farklı müşteri olduğu her gün sessizce hiç ateşlenmez ve hiçbir yer bunu söylemez. Seçici,
koşulun soramayacağı soruyu sorar: hangi özne.

**`_select` artık ÖNCEKİ slotları görür (`bound`).** `account_rep` "bu kartın zaten bağladığı
müşterinin temsilcisi" demektir ve bunu söylemenin başka yolu, çağıranın seçimi kendisinin
yapmasıdır — §4.3'ün durdurmak için var olduğu şey.

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
