# Faz E planı · Pazaryeri (B2C'nin tek ürünü)
Planlayıcı: Opus, 2026-10-16. Girdiler: `ORTAK.md`, `E_GOREV.md`, `E_ARASTIRMA.md`, `ERDEM_TUR2_YORUM.md`, karar defteri,
`TUR2_SUNUM.md`, `KAPSAM.md`, `../sprint/` (T2_5b §1, §3B, §7; T2_6; T2_CONTRACT; BRIEF 1b), `PRD_URUN_DERINLIK.md` §3, §8, §10, §11.
Kod okuması HEAD `1faeb82`. A ve B şu an uygulanıyor, C ve D benden önce gelecek: onlara dayanan her varsayım
**"A/B/C varsayımı"** diye işaretli; plan uygulamadan önce güncel koda karşı tazelenir.
Ölçüm: bugünkü B2C botu iki tohumla koşuldu (`--run-log=full_run_b2c:110:sim:1|2`, ayrı APPDATA); sayılar §4'te.

---

## 0. Özet
- **Ne değişiyor:** B2C'nin tek ürünü pazaryeri olur. Not ve video uygulaması silinir. Ürün iki taraflı kurulur:
  sprintte alıcı tarafı (Keşif, Sepet ve Ödeme, Siparişlerim) ve satıcı tarafı (Ürün Yükleme, Satıcı Paneli) ayrı
  alanlar olarak görünür.
- **Ekonomi:** Alıcı kitlesi bugünkü motorla büyür. Yeni olanlar: aktif mağaza sayısı, mağaza memnuniyeti, sipariş,
  satış hacmi ve iki gelir: komisyon (satış hacmi × oran) ve üyelik (üye × aylık ücret). Aylık gelir bu ikisinin toplamıdır.
- **Satış sekmesi B2C'de "Pazaryeri" olur:** Mağazalar, Alıcılar ve Gelir tek sayfada. Komisyon ve üyelik ücreti
  önizlemeyle değişir, "Uygula" ile kesinleşir.
- **Oyuncu ne hisseder:** Erken dönemde düşük komisyonla mağaza toplar, kitle büyüdükçe oranı artırıp hasat eder; ama
  her artış mağazaları sarsar, küçük pazaryerinde sert, büyükte yumuşak. Üyelik ücretinde de kazanç ile üye sıklığı
  arasında gerçek bir takas vardır.
- **Kapsam:** Demoda komisyon ve üyelik. Premium mağaza, reklam, paketler ve sezon tepeleri Erken Erişim'de.
- **Hızı korur:** Alıcı başına aylık gelir bugünkü kullanıcı başına gelirin (~$4,4) düzeyine kurulur: pazaryerinde
  $4,6–4,8 [ÇALIŞMA] (inceleme: iki sayı tek cümlede eşitlenmiş gibi yazılıydı); Frank çeki, seed ve Seri A haftaları
  bugünkü pencerede kalmak zorunda (ölçüm kapısı).
- **6 commit**, üç parça: ekonomi çekirdeği ve kayıt (E1–E3), sayfa ve kollar (E4–E5), bağlar ve içerik (E6).
- **Süre:** Ajan işi yaklaşık 23 saat (16 saat kod, 4,5 saat kapı ve çekim, 2,5 saat inceleme); sıralı yürüdüğü için
  üç iş günü.

---

## 1. Bugünkü akış
**Oyuncu ne görüyor**
- Tür seçicide B2C'nin iki ürünü var: Not & Bilgi Aracı ve Video Klip Aracı. Pazaryeri yok.
- Ürün abonelikle satılır. v1.0'dan sonra "Ücretli plan" kartı çıkınca kullanıcıların bir kısmı ödemeye başlar; gelir
  "ödeyen × fiyat". Botun koşusunda dönüşüm %50'nin üstünde: kitlenin yarısı ödüyor.
- Satış sekmesi B2C'de dört sayı ve bir eğri gösterir (kullanıcı, ödeyen, dönüşüm, plan fiyatı). v1.0'dan önce boştur.
  Sol menüde adı "Satış"tır; pazaryerinde satıcı da satış ekibi de yoktur, ad yanıltır.
- Fiyatı değiştirecek bir düğme yok: fiyat kartın açıldığı anda bir kez konur. Önizleme hesabı kodda var ama ekrana
  hiç bağlanmadı.

**Neden yetersiz**
- Erdem'in kararı B2C'nin yalnız pazaryeri olması: üçüncü taraf mağazalar ve alıcılar, tek bir mağaza değil.
- Mağaza, komisyon, sipariş, satış hacmi kavramlarının hiçbiri kodda yok. Mağaza tarafı hiç yok.
- Oyuncunun B2C'de çektiği tek kol (fiyat) ekranda değil; Satış sekmesi seyirlik.
- "Kullanıcının yarısı öder" pazaryeri gerçeğine uymaz: pazaryerinde herkes alışveriş yapar, üye azınlıktır.

---

## 2. Hedef akış

### 2.1 Tür seçimi
- B2C yolunda tek oynanabilir kart: **Pazaryeri**. Öteki üç kilitli kart (AI ürünleri) olduğu gibi kalır.
- Kart metni:
  - Ad: "Pazaryeri" / "Marketplace"
  - Söz: "Bağımsız mağazaların herkese sattığı pazaryeri." / "The marketplace where independent stores sell to everyone."
  - Takas: "Alıcı mağazanın, mağaza alıcının olduğu yere gider. Bir tarafı elle başlatmak gerekir." / "Buyers go where
    the stores are and stores go where the buyers are. One side has to be started by hand."

### 2.2 Sprint: iki taraflı ağaç
Ürün penceresinin Sprint görünümünde B2C'de "Çekirdek" yerine iki alan durur: **Alıcı** ve **Satıcı**. Öteki alanlar
(Onboarding, Büyüme, Güven, Gelir) aynı kalır; Onboarding'in adı C'nin kararıdır. (inceleme: C planı §2.10 alanı
"İlk Kullanım ve Erişim", Ar-Ge düğümünü "İlk Açılış Akışı" yapıyor; E'nin oyuncu metinleri bu adları kullanır.)

| Taraf | Hat | Eksen | K1 | K2 | K3 (Ar-Ge) |
|---|---|---|---|---|---|
| Alıcı | Keşif / Discovery | Yenilik | Kategori ve Arama | Filtre ve Sıralama | Kişisel Öneriler (Semantik İndeks) |
| Alıcı | Sepet ve Ödeme / Cart and Checkout | Kararlılık | Kartla Ödeme | Kayıtlı Kart ve Taksit | Dolandırıcılık Kalkanı (Güvenlik Sertifikası) |
| Alıcı | Siparişlerim / My Orders | Deneyim | Sipariş Durumu | Kargo Takibi ve İade | Teslimat Tahmini (Analitik Motoru) |
| Satıcı | Ürün Yükleme / Listings | Yenilik | Tek Tek Yükleme | Toplu Yükleme | Katalog Eşleme (AI Engine) |
| Satıcı | Satıcı Paneli / Seller Panel | Deneyim | Sipariş Listesi ve Kargo Etiketi | Hakediş ve Fatura | Mağaza Vitrini (Tasarım Sistemi) |

- Paylaşılan dört hat (Entegrasyonlar, Güvenlik & Yetki, Dayanıklılık, Mobil & Erişim) aynı; açıklamaları pazaryerine
  göre yazılır (kargo hesabı bağlama, mağaza yetkileri, yarıda kalan siparişin geri alınması…).
- **v1.0 için:** üç K1, alıcı ve satıcı tarafından en az birer tane. Sprint başlığındaki satır "v1.0 · Alıcı ve satıcı
  2/3" der; ipucu: "v1.0 için alıcı ve satıcı tarafından en az birer özellik gerekir."
- **Hatların ekonomideki karşılığı** (oyuncu kart açıklamasında görür, sayılar §5'te):
  - Sepet ve Ödeme K1: siparişler platformdan geçer, komisyon başlar. K2 (taksit): sepet ortalaması %12 [ÇALIŞMA] artar.
  - Satıcı hatları (Ürün Yükleme, Satıcı Paneli) her kademede mağaza memnuniyetini artırır.
  - Bütün kimlik hatları ve paylaşılan hatlar kaliteyi besler: kalite alıcı büyümesini ve üye oranını yükseltir.
- Gelir alanındaki kart: **Üyelik programı** (bugünkü "Ücretli plan" kartının yeri). Kilit: canlı ürün ve Sepet ve Ödeme K1.
- **Erken Erişim'e kalan hatlar:** Yorumlar, Ürün Sayfası, Kampanya Araçları, ayrı Hakediş hattı, Satıcı Başvurusu;
  gelir kartları Premium Mağaza ve Öne Çıkan Ürünler; Paketler ekranı; Kara Cuma ve Yılbaşı.

### 2.3 Sol menü
- Tür seçilmeden satır "SATIŞ"tır. B2C türü seçilince ad **"PAZARYERİ"**, ikon bir dükkân tentesi olur. B2B'de "SATIŞ"
  kalır. Sıra değişmez. Dar menüde (yalnız ikon) ipucu "Pazaryeri" der.

### 2.4 Pazaryeri sayfası, v1.0 öncesi
```
┌ PAZARYERİ ──────────────────────────────────────────────────────── ✕ ┐
│                                                                      │
│                              [dükkân glifi]                          │
│                  Pazaryeri v1.0 yayınlanınca açılır.                 │
│                       Açılışta 12 mağaza hazır                       │
│                                                                      │
│   KOMİSYON                       [−]  %10  [+]                      │
│                                                                      │
│   ÜYELİK ÜCRETİ                  Canlı ürün gerekli                 │
└──────────────────────────────────────────────────────────────────────┘
```
- Açılış komisyonu v1.0'dan önce de ayarlanabilir; ilk karar budur. Önizleme yalnız mağaza tarafını söyler:
  "%10 → %6 · Yeni mağaza girişi +%29 · Gelir Sepet ve Ödeme yayınlanınca başlar". [ÇALIŞMA] (inceleme: §5.2'deki
  esneklik 0,5 ile; eski +%67 esneklik 1'den geliyordu)
- "12 mağaza" kurucunun ağından açılışa hazır gelen mağazalardır; v1.0 anında aktif olurlar.

### 2.5 Pazaryeri sayfası, v1.0 sonrası (52. hafta civarı, örnek [ÇALIŞMA])
```
┌ PAZARYERİ ───────────────────────────────────────────────────────────────────── ✕ ┐
│ MAĞAZALAR                                 │ ALICILAR                               │
│ Aktif mağaza                        184   │ Aktif alıcı                    12.400  │
│ Bu ay katılan                       +22   │ Üye                      1.050 · %8,5  │
│ Bu ay ayrılan                        −6   │ Ücretsiz                       11.350  │
│ Mağaza memnuniyeti                   56   │                                        │
│ ───────────────────────────────────────── │ ────────────────────────────────────── │
│ KOMİSYON                [−]  %10  [+]     │ ÜYELİK ÜCRETİ        [−]  $7/ay  [+]  │
├───────────────────────────────────────────┴────────────────────────────────────────┤
│ GELİR                               BU AY         GEÇEN AY        DEĞİŞİM          │
│ Komisyon                          $50.300          $46.100           +%9           │
│ Üyelik                             $7.350           $6.900           +%7           │
│ Toplam                            $57.650          $53.000           +%9           │
│ Satış hacmi                      $503.000         $461.000           +%9           │
│ Sipariş                            12.580           11.530           +%9           │
│ Sepet ortalaması                      $40              $40            %0           │
│ ▁▂▂▃▃▄▄▅▅▅▆▆▆▇▇▇█  (26 haftalık alıcı sütunları; üye payı koyu)                  │
└─────────────────────────────────────────────────────────────────────────────────────┘
```
- **Bu ay** bu ayın aylık hızıdır (bugünkü durumdan aylık gelir), **Geçen ay** kapanan ayın kapanış hızıdır, **Değişim**
  ikisinin farkıdır. İlk ay "Geçen ay" ve "Değişim" boş çizgi gösterir.
- Kalıcı açıklama satırı yok. İpuçları:
  - Mağaza memnuniyeti: "Araçlar +8 · Satışlar +3 · Komisyon 0 · Açık hata −4". (Nedenler, Erdem'in B2B'de istediği
    "üstüne gelince nedenler" kalıbıyla.)
  - Üye: "Üye oranı %8,5: kalite ×0,85 · ücret ×1,00". Üye oranının kaliteye bağlı olduğu burada okunur.
  - Komisyon başlığı: "Pazaryerleri kategoriye göre %5 ile %25 arası komisyon alır." (Gerçek bilgi; öneri değil.)
  - Toplam: "Satış hacminin %11,4'ü platforma kalır."
- Aynı sayı iki yerde çizilmez: üst şeritte KPI yok; B2B'nin dört KPI'ı B2C'de gizli kalır.

### 2.6 Komisyon önizlemesi
Oyuncu [+] ile %10'u %12 yapar. Satırın altında önizleme açılır; "Uygula" tek amber düğmedir:
```
│ KOMİSYON                [−]  %12  [+]                                    │
│   Gelir ayda +$10.060 şimdi · 3 ay sonra +$5.400                         │
│   Mağaza memnuniyeti 56 → 53 · Yeni mağaza girişi −%9                    │
│   3 ayda yaklaşık 14 mağaza eksik                  [Vazgeç]  [Uygula]    │
```
- (inceleme) Gelir satırı iki sayı taşır: bugünkü mağazalarla hemen gelen fark ve 13 hafta sonraki fark (mağaza kaybı
  düşülmüş). Tek "+$10.060" kalıcı kazanç gibi okunuyordu; 3 ay sonra mağaza azaldıkça farkın yarısı geri gider.
- "Uygula" sonrası: memnuniyet hemen 3 puan düşer (sarsıntı, trafiğe göre ölçekli), sonra haftada en çok 3 puan hızla
  yeni dengesine (52) yürür. Yeni mağaza girişi %9 azalır. Memnuniyet 40'ın altına inerse ayrılan mağaza sayısı artar.
- Aynı +2 puan v1.0'dan hemen sonra (12 mağaza, 500 alıcı) çok daha serttir (inceleme: §5.2'deki trafik toleransıyla):
  memnuniyet ~49'dan 42'ye iner, hedef 41 olur; +3 puan 40'ın altına iter ve mağazalar ayrılmaya başlar. 12.400
  alıcıda aynı artışın memnuniyet bedeli bunun yarısından azdır (`tol` 1,6'ya karşı 0,67).
- İndirim anında bir memnuniyet hediyesi getirmez; memnuniyet yeni dengesine haftalar içinde tırmanır.
  (İnip çıkan oranla oyun oynanmasın diye; gerçekte de güven yavaş döner.)
- Karar kâğıdı açıkken (Olaylar'da cevap bekleyen olay) [−], [+] ve "Uygula" kapalıdır.

### 2.7 Üyelik ücreti önizlemesi
Oyuncu $7'yi $9 yapar:
```
│ ÜYELİK ÜCRETİ        [−]  $9/ay  [+]                                    │
│   Gelir ayda +$425                                                      │
│   Üye oranı %8,5 → %7,3 · Üye 1.050 → 900          [Vazgeç]  [Uygula]   │
```
- Üyelik temel alışverişi kilitlemez: üye olmayan alıcı aynı ürünleri aynı fiyatla alır. Üye daha sık alışveriş yapar
  (aylık 1,6 sipariş, ücretsiz alıcı 1,0) [ÇALIŞMA]. Bu yüzden üye kaybı komisyonu da düşürür; önizlemedeki gelir
  ikisinin net toplamıdır ($768 üyelikten, −$343 komisyondan).
- Ücret artınca üyeliği bırakan alıcı pazaryerini bırakmaz, ücretsiz alıcı olur.
- Üyelik programı kartı çıkmadan satırda "Üyelik programı gerekli" yazar; kart çıktığında ücret $7 [ÇALIŞMA] ile açılır.

### 2.8 İlan dönemi (v1.0 çıktı, Sepet ve Ödeme henüz yok)
- MVP'de Sepet ve Ödeme yoksa alıcılar ve mağazalar gelir, ama siparişler platform dışında yapılır: komisyon yoktur.
- Komisyon satırı ayarlanabilir kalır; önizlemenin gelir satırı "Gelir Sepet ve Ödeme yayınlanınca başlar" der.
  Sipariş, Satış hacmi ve Sepet ortalaması satırları boş çizgi gösterir.
- Üyelik satırı "Sepet ve Ödeme gerekli" der.

### 2.9 Diğer ekranlara düşenler
- Ürün penceresi başlığında canlı B2C ölçüleri "Alıcı" ve "Üye" olur (başlığın kendisi C'nin, C varsayımı).
- Genel Bakış'ın İş özeti (C) B2C'de "MRR $57.650 · 12.400 alıcı · 184 mağaza ›" okur. (inceleme: C planı aynı satırı
  "Satış hacmi $193K · 184 mağaza" diye çiziyordu ve sayısı E'nin örneğiyle uyuşmuyordu; C §2.9 MRR'yi ortak dil
  tutar. Biçim C'nindir; E `figures()` ile dört sayıyı verir. C'nin `OV_BIZ_B2C` metnindeki "dönüşüm" pazaryerinde
  yoktur, E6'da değişir.)
- Düzeltme kartı (A) satıcı hattında kullanıcı yerine mağaza sayar: "Ürün Yükleme düzelt · 3 hata · 14 mağaza".
- "Ödeme alınamıyor" olayı (B) yarım kalan sepeti gerçek sipariş akışından türetir: "Son 3 saatte 52 sepet yarıda
  kaldı" (aylık 12.580 sipariş / 730 saat ≈ 17 sepet/saat × 3). (inceleme: eski "225" bu hesapla tutmuyordu; B'nin
  "212 sepet" örneği de bu akışta ~12 saatlik kesintiye denk gelir. B tazelemesi kupon seçeneğinin bu ölçekte bedavaya
  yakın kalıp kalmadığını yeniden ölçer.)
- Haftalık destek raporunda (C) satıcı istekleri ayrı başlık altında mağaza sayısıyla yazar: "Toplu yükleme
  (11 mağaza)"; alıcı istekleri yorum sayısıyla: "Kargo takibi (38 yorum)".
- Frank'in çek listesinde B2C adımı "İlk ödeyen müşteri" yerine "İlk gelir" olur.

---

## 3. İzlenebilirlik

### 3.1 Karar defteri (Faz E)
| Karar | Planda | Commit |
|---|---|---|
| B2C'de Satış "Pazaryeri" olur; yeni anahtar ve ikon; sıra değişmez | §2.3; anahtar `TAB_MARKETPLACE`, ikon `rail/marketplace.svg`; satırın sahnedeki anahtarı ve sırası aynı, smoke kilidi bozulmaz | E4 |
| Pazaryeri sıfırdan kurulur; not ve video için öneri | Silinir (§5.8); GDD ch03 §12.11 GUNCELLEMELER ile güncellenir; soru 1 | E1, E2 |
| Mağazalar: aktif, katılan, ayrılan, memnuniyet | §2.5, §5.2 | E3, E4 |
| Komisyon önizlemeli; artış girişi ve memnuniyeti düşürür, churn yapar; detaylı kurgu | §2.6, §5.2 (sarsıntı + giriş çarpanı + memnuniyete bağlı ayrılma + trafik toleransı); soru 4 | E3, E5 |
| Alıcılar: aktif, üye, ücretsiz | §2.5 | E4 |
| Üyelik ücreti önizlemeli | §2.7 | E5 |
| Üye oranı kaliteye bağlı | §5.3 (kalite çarpanı, ipucunda görünür) | E3 |
| Gelir: komisyon, üyelik, toplam; bu ay, geçen ay, değişim | §2.5, §5.5 | E3, E4 |
| GMV ve sepet ortalaması | "Satış hacmi" ve "Sepet ortalaması" satırları; GMV kısaltması ekranda yok | E4 |
| Satıcı istekleri ayrı | Her hattın tarafı veride; C'nin istek verisi tarafı okur, birim mağaza (C varsayımı) | E1, E6 |
| Demo: komisyon ve üyelik; EA: premium mağaza, reklam, paketler | §2.2 son madde, §5.9 | — |
| Eski PRD'nin ağacı ve gelir kuralları yeniden kullanılır | Ağaçtan 5 hat demoya, 5 hat EA'ya; kurallar: üyelik kilitlemez ✔, önizleme ve Uygula ✔, "önerilen" yok ✔, tek akım ≤%65 → yalnız 4 akım varken (EA), demoda gerekçe §4 sonu; (inceleme) kuralı kaldırmak sahibin kararı, soru 5 | E1, E5 |
| Tur 2'nin pazaryeri bölümü yeniden kullanılır | Tek sayfa (tur 2'nin ucuz yedeği), alıcı = bugünkü kitle motoru, üye = ücretli planın yeri, satıcı tohumu 12, komisyon %10, sepet $38→$40, üye sipariş katı; satıcı çağrısı ve mağaza eğrisi alınmadı (§3.3) | E3, E4 |

### 3.2 Görev yazısının soruları
| Soru | Cevap |
|---|---|
| Çekirdek ekonomi: giriş/çıkış, alıcı, GMV = sipariş × sepet, gelir = komisyon + üyelik | §5.1–§5.5 |
| Kalite bağları; SalesSystem mi yeni sistem mi | §5.6, §5.7 |
| İki taraflı ağaç; demo ve EA; sprint ve aşamaya oturuş | §2.2, §5.8 |
| Tek sayfa ASCII: komisyon önizleme, üyelik önizleme, v1 öncesi | §2.4–§2.8 |
| B'nin ödeme ve yorum olayları, A'nın etkilenen kullanıcısı, C'nin İş özeti ve sunucu birimi | §5.10 okuma noktaları |
| Aylık gelire çevirme | §5.5 |
| Kayıt şeması | §5.11 |
| Bot ve probe | §7 "Bot" |
| Not ve video ne olur | Silinir; soru 1 |

### 3.3 Erdem'in sözleri ve geçmiş kararlar
| Söz ya da karar | Planda |
|---|---|
| "Amazon/Trendyol gibi; tek bir mağaza değil", üçüncü taraf satıcılar ve alıcılar | Mağaza sayısı ayrı bir nüfus (§5.2) |
| Mağaza sayısı, komisyon yönetimi, dönen hacim, ücretli katman (kaliteye bağlı), birden çok gelir türü | §2.5; demoda iki gelir türü, EA'da dört |
| "Komisyonu arttırırsak aktif mağaza ve memnuniyet düşer, churn'e sebep olabilir… detaylı kurgulanması lazım" | §5.2: dört etki (sarsıntı, giriş, ayrılma, sipariş bulunurluğu) ve trafik toleransı; araştırma §4.2 |
| "Aktif 12 bin, paid 1050 fena olmayabilir" | Örnek %8,5 üye oranı; MEMBER_BASE bunu kalite 42 civarında verir |
| "Üyelik ücretini önizlemeyle ayarlayabiliriz" | §2.7 |
| "Pazar yerinin tamamen yeniden yapılması gerekecek" | Yeni sistem `MarketplaceSystem`, eski fiyat makinesi silinir |
| Mağaza puanı yok | Hiçbir yerde puan yok; memnuniyet mağazaların bize dair memnuniyetidir, alıcıya gösterilen bir not değildir |
| Depo, 3PL, dropship yok; kargo satıcının işi | Platform kargo taşımaz; Satıcı Paneli K1 kargo etiketi basar, Siparişlerim K2 takip numarasını gösterir |
| Sezon tepeleri beğenildi | EA'ya (soru 5). Gerekçe: mevsimli gelir aylık gelire girerse kapılar tek haftada açılır; ayrı "mevsimsiz gelir" kuralı ister |
| İki taraflı geliştirme | Alıcı ve Satıcı alanları (§2.2) |
| Oyuncu gelir türüne odak seçer, finans raporu hissi | Gelir tablosu; komisyonla üyelik arasındaki takas (§2.6–§2.7); EA'da dört akım |
| Ücretsiz/ücretli katmanda hangi özelliğin ücretli olacağını oyuncu seçer | Paketler ekranı, EA (karar defteri) |
| B2C'de Satış sekmesi satıcı ve alıcı tarafını yönetir | Pazaryeri sayfası iki tarafı tek sayfada yönetir |
| Tur 2: satıcı çağrısı | Pazarlama modülüne. Gerekçe: bugünkü pazarlama itişi kartlarla gelir; satıcıya yönelik itiş pazarlama modülünün işi |
| Tur 2: 26 haftalık mağaza eğrisi | Alınmadı; sayfada tek grafik (alıcı) kalır. Sakin ekran |
| Tur 2: "bir kerelik −8 mağaza" | Anında kayıp yerine sarsıntı ve hızlanan ayrılma (araştırma §4.2); önizleme "3 ayda yaklaşık 14 mağaza eksik" der. Soru 4 |

### 3.4 Kalıcı kurallar
| Kural | Planda |
|---|---|
| Sakin ekran, kalıcı açıklama satırı yok | Gerekçeler ipucunda; kilitler tek satır "X gerekli" |
| El tutan öneri yok | "Önerilen" komisyon ya da ücret yok; komisyon ipucunda yalnız sektör aralığı bilgisi |
| Sayılar sayı olarak | Her satır sayı; "büyüyor" gibi kelime yok |
| En az yeni sistem | Tek yeni sistem (`MarketplaceSystem`); alıcı motoru, MRR kanalı, ay defteri, seam'ler yeniden kullanılır |
| Bedel yaz | §7 her commit S/M/L ve yeni durum, yeni ekran |
| Bedel olaydan türer | B'nin olaylarına gerçek sipariş akışı ve sepet ortalaması sağlanır (§5.10) |
| B2B memnuniyet deltası kalıcı değil | Pazaryerinde ilgisiz; mağaza memnuniyeti hedefe yürüyen ayrı bir durumdur, sarsıntı bilerek geçicidir |
| Tasarım sabitleri "onay bekliyor", deneme sayıları [ÇALIŞMA] | §5.12 tek liste |
| Metin önce İngilizce, tire yok, gerçek marka yok, hüküm yok | §6; rakip adları ad taramasına girer |
| Reddedilenler geri gelmez (satıcı ödeme ikizi, müşteri görüşmesi, "Büyümeye açık", "Onboarding" etiketi) | Hiçbiri yok |

---

## 4. Araştırma bulguları
Kaynaklar `E_ARASTIRMA.md`'de; çoğu satıcı blogu ve kendi aralarında çelişiyor. Sayılar aralık olarak kullanıldı.

1. **Komisyon aralığı.** Trendyol %8–28, Hepsiburada %5–22 (üç kademe), Amazon tipik %8–15, eBay ~%13, Etsy %6,5 + ödeme
   işleme ~%3 (tsoft.com.tr, saasant.com, ecomcalctools.com, craftybase.com). Yeni pazaryeri için doğrudan kaynak yok;
   hacimle düşen kademe yaygın (Steam %30/25/20, Epic %0/12).
   → Varsayılan %10, aralık %0–25, adım 1 puan. Komisyon ipucu "%5 ile %25 arası" der. Kademeli oran EA.
2. **Artışa tepki.** Etsy 2022: %5 → %6,5; 14.000+ dükkân bir haftalık greve katıldı, 5,3 milyon satıcının küçük bir
   kısmı; sonraki çeyrekte aktif satıcı yine arttı, gelir +%10,6 (TechCrunch, NPR, investors.etsy.com). Amazon
   satıcılarının çoğu ücretten şikâyet ediyor ama payını azaltmıyor ("paradoxical dependence", Marketplace Pulse 2026).
   → Artış **anında kayıp üretmez**: anlık memnuniyet sarsıntısı + yavaş, memnuniyete bağlı ayrılma. Trafik toleransı
   "Satışlar" teriminde: mağaza başına sipariş yüksekse memnuniyet yüksek kalır, artış katlanılır; küçük pazaryerinde
   aynı artış mağazaları ayrılma eşiğinin altına iter.
3. **Üyelik.** Prime üyesi yılda ~$1.100–1.200, üye olmayan ~$500–600 harcıyor; fark sepet büyüklüğünden değil
   sıklıktan (CIRP). Walmart+ ~%17 hane, Hepsiburada Premium iki yılda 3 milyon abone. Üye olmayan alışverişe devam
   ediyor; ilkemiz (üyelik kilitlemez) doğrulandı, seçilim yanlılığı olabilir.
   → Üye sipariş katı 1,6 (araştırmanın 1,5–2 aralığı), sepet ortalaması üyede aynı. Üye oranı demoda %4–11
   (Türkiye verisi yok; ABD %17 üst sınır sayıldı). Ücret artışında giden üye ücretsiz alıcı olur.
4. **Pazaryeri ölçüleri.** GMV, take rate (gelir / GMV), aktif alıcı ve satıcı, sepet, tekrar alım; sağlıklı take rate
   %10–30 (upgrowth.in). Etsy'de satıcı/alıcı ~1/13 (çok satıcılı el yapımı pazar); erken evrede yüzlerce satıcı,
   binlerce alıcı. Soğuk başlangıç: önce bir tarafı elle doldur (raftlabs.com, xplainerr).
   → Açılışta 12 hazır mağaza (elle doldurulan taraf). Mağaza başına hedef alıcı 65 [ÇALIŞMA] (genel pazaryeri; Etsy'den
   yoğun). Take rate ipucunda. Likidite iç değişkendir, ekranda adıyla yok; etkisi sipariş ve alıcı büyümesinde.
5. **Oyunlar.** Big Ambitions ve Startup Company'de üçüncü taraf satıcılı pazaryeri mekaniği bulunamadı. Mekanik görece
   özgün; risk önizleme ve ölçüm kapısıyla yönetilir.

**Kendi ölçümüm (bugünkü kod, `full_run_b2c`, tohum 1 ve 2, 110 hafta):** Frank çeki 17. hafta (ikisinde de), seed 39 ve
40, Seri A kapısı 70 ve 77; plan fiyatı $8, dönüşüm 0,48–0,60 → kullanıcı başına aylık gelir ≈ $4,4. 52. haftada kitle
~11–12 bin, MRR ~$50 bin.
→ Pazaryerinde alıcı başına aylık gelir aynı düzeye kurulur: (0,915 × 1,0 + 0,085 × 1,6) sipariş × $40 × %10 + %8,5 ×
$7 ≈ $4,8. Böylece B2C'nin kalibre edilmiş temposu (ACIK 97) korunur; sapma ölçüm kapısıyla yakalanır.

**Eski PRD'nin %65 kuralı:** Dört akım için yazılmıştı. Demoda iki akım var; gerçek pazaryerlerinde üyelik geliri
komisyonun yanında ikincil (araştırma 3). Demoda hedef: varsayılan oyunda komisyon payı 52. haftada %75–92. Kural EA'da
dört akımla geri gelir. (inceleme) Bu, eski PRD'deki ve görev yazısındaki bir kuralı demoda kaldırmaktır; planlayıcı
kendi başına kaldıramaz. Açık soru 5'e taşındı. Ölçüye göre üyelik tavanı (kalite 1,6 ve tepe ücret $10,5'te) alıcı
başına ~$1,3'tür; komisyon sıfırlanmadıkça üyelik toplamın ~%25'ini geçemez.

---

## 5. Model

### 5.1 Alıcılar (bugünkü kitle motoru)
- Aktif alıcı = bugünkü B2C kitle sayısı. Motor aynı: taban büyüme, kalite, marka, itibar, ilgi, ağızdan ağıza, aşınma.
- Tek değişiklik: fiyat çarpanının yerine **seçenek çarpanı** girer (üyelik ücreti büyümeyi yavaşlatmaz, çünkü
  alışverişi kilitlemez).
  - `sel_raw = mağaza × BPS_TARGET / max(alıcı, 1)` (yeterli mağaza var mı)
  - Büyüme çarpanı = `SEL_GROWTH_K × clamp(sel_raw, SEL_MIN, SEL_MAX)`.
  - `SEL_GROWTH_K` bugünkü botta fiyat çarpanının ortalamasıdır (~1,5); E3 öncesi taban koşusundan ölçülerek konur.
- Aşım cezası, ağızdan ağıza, pazarlama itişi olduğu gibi kalır. A'nın hatadan doğan B2C kaybı alıcıya işler
  (A/B/C varsayımı: A'nın B2C churn'ü kitle üzerinden yazar).

### 5.2 Mağazalar
**Durum:** aktif mağaza (ondalıklı), mağaza memnuniyeti (0–100), komisyon (tam sayı, %), koşu boyu katılan ve ayrılan
toplamları.

**v1.0 anında:** mağaza = `STORE_SEED` (12); memnuniyet = o anki hedef.

**Haftalık (günlük tik = bir hafta):**
- Hedef mağaza `T = alıcı / BPS_TARGET × fee_mult(c)`, `fee_mult(c) = clamp((C_REF / max(c, 1)) ^ FEE_ELAST, 0,4, 1,8)`.
  - (inceleme) Esneklik 1 iken (`C_REF / c`) dengede mağaza sayısı komisyonla ters orantılı olur; sipariş mağazayla
    orantılı olduğu için `komisyon geliri ∝ c × fee_mult(c)` sabit kalır. %8 ile %25 arasında her oran uzun vadede aynı
    komisyon gelirini verir, artış yalnız büyümeyi ve memnuniyeti düşürür; §0'daki "hasat" yalnız ~6 haftalık bir geçiş
    olurdu ve artış her durumda kötü seçenek olurdu. `FEE_ELAST` 0,5 ile %16 oran dengede ~%26 fazla komisyon geliri,
    ~%21 az mağaza ve daha yavaş alıcı büyümesi verir: gerçek bir takas.
- Katılan = `JOIN_BASE × fee_mult(c) + max(0, T − mağaza) × JOIN_PULL`.
- Ayrılan = `mağaza × (CHURN_BASE + CHURN_UNHAPPY × max(0, SAT_LEAVE − memnuniyet) / SAT_LEAVE)`.
- Memnuniyet hedefe haftada en çok `SAT_DRIFT` puan yürür.

**Memnuniyet hedefi:**
```
hedef = clamp(SAT_BASE
        + TOOLS_W × araçlar                     # araçlar = satıcı hatlarının canlı kademe toplamı / 6
        + SALES_W × clamp(log2(ops / OPS_REF), −1, 1)   # ops = mağaza başına aylık sipariş
        − FEE_W × tol × (c − C_REF)
        − min(BUG_CAP, BUG_W × satıcı hatlarındaki açık hata), 0, 100)
tol = clamp(TOL_HI − TOL_SLOPE × log2(max(alıcı, 1) / TOL_REF), TOL_LO, TOL_HI)   # (inceleme) trafik toleransı
```
- (inceleme) `tol`: 500 alıcıda 1,6; 2.000'de 1,2; 8.000'de 0,8; 16.000 ve üstünde 0,6. Neden: dengede mağaza başına
  sipariş (`ops`) yapı gereği sabittir (`sel_raw` < 1,2 iken ops ≈ BPS_TARGET × 1,05 ≈ 68); "Satışlar" terimi büyük
  pazaryerinde artıyı taşımaz. Araştırmanın "trafik güçlüyse satıcı katlanır" bulgusu (§4.2) ancak bu terimle modelde
  vardır.
- Açık hata sayısını A'nın hat okumasından alır: `ProductState.open_bugs_by_line()`, yalnız `side == "seller"` hatları
  toplanır (A/B/C varsayımı; A planı §5 adı).
- İpucundaki dört parça bu terimlerdir.

**Komisyon değişince (`set_commission`):**
- Artış: memnuniyet hemen `SHOCK_PER_PT × tol × artış` düşer; giriş çarpanı ve hedef yeni orandan okunur.
- İndirim: anında değişiklik yok; hedef yükselir, memnuniyet haftalarca tırmanır.

**Neden bu şekil (Erdem'in "detaylı kurgu"su):**
1. Giriş düşer (`fee_mult`): kayıt olacak mağaza vazgeçer.
2. Memnuniyet düşer (sarsıntı + hedef): protesto.
3. Ayrılma artar ama yalnız memnuniyet 40'ın altına inince: yavaş çıkış, aylar içinde.
4. Mağaza azalınca alıcı aradığını daha az bulur: sipariş ve alıcı büyümesi düşer (`sel`), gelir geri tepmeye başlar.
5. Trafik toleransı: büyük pazaryerinde komisyon cezası ve sarsıntı `tol` ile küçülür, artış katlanılır (inceleme:
   eski metin bunu "Satışlar" terimine yüklüyordu, o terim dengede sabittir).
- Sonuç oyunda bir yay çizer: erken dönemde düşük oranla mağaza toplamak, kitle büyüyünce oranı artırmak; artış her
  seferinde bedel öder. `SEL_MAX` 1,2 olduğu için ~%8'in altına inmek ek büyüme getirmez: doğal bir tatlı nokta.

### 5.3 Üyeler
```
üye oranı = clamp(MEMBER_BASE × q_mult × fee_mult_m × arge, MEMBER_MIN, MEMBER_MAX)
q_mult     = clamp(q / 50, 0,4, 1,6)        # q = rakibe göre kalite (50 = startup ligiyle başa baş), bugünkü okuma
fee_mult_m = clamp(1 + FEE_SLOPE × (FEE_REF − ücret) / FEE_REF, 0,1, 1,5)
arge       = 1,15 Onboarding Akışı Ar-Ge düğümü bitince, yoksa 1,0 (bugünkü düğüm etkisi taşınır)
üye = round(alıcı × üye oranı); ücretsiz = alıcı − üye
```
- Üyelik kapalıyken (kart çıkmadı) üye 0.
- Ücret ile üye oranı doğrusal; üyelik geliri $10–11 civarında tepe yapar, ama her kaybedilen üye sipariş sıklığını
  da götürür. Takas gerçek ve oyuncunun durumuna bağlı (çok alıcılı, düşük komisyonlu pazaryerinde düşük ücret, yüksek
  komisyonlu pazaryerinde yüksek ücret daha iyi).
- Hatanın dönüşüme etkisi yok (Erdem: hata dönüşümü etkilemez, churn'ü etkiler; A bunu kaldırır, A/B/C varsayımı).

### 5.4 Sipariş ve satış hacmi
```
sel_ord        = min(sel_raw, SEL_MAX)                       # tabansız: mağaza yoksa sipariş yok
aylık sipariş  = alıcı × sel_ord × (F_FREE × (1 − üye oranı) + F_FREE × MEMBER_ORDER_MULT × üye oranı)
sepet ort.     = AOV × (CHECKOUT_K2_AOV, Sepet ve Ödeme K2 canlıysa; yoksa 1)
satış hacmi    = aylık sipariş × sepet ort.
```
- Sepet ve Ödeme K1 canlı değilse siparişler platform dışıdır: hacim ve sipariş hesaplanır (mağaza memnuniyetinin
  "Satışlar" terimi onları okur) ama gelir sıfırdır ve sayfada boş çizgi görünür.

### 5.5 Gelir ve aylık gelir
```
komisyon geliri (aylık) = satış hacmi × c / 100        (Sepet ve Ödeme K1 yoksa 0)
üyelik geliri (aylık)   = üye × ücret
aylık gelir (MRR)       = komisyon geliri + üyelik geliri
```
- Her oyun saatinde türetilir (bugünkü `_derive_b2c_mrr` yeri). Tek B2C kaydına yazılır: koltuk = üye, MRR = toplam.
  `reflect_mrr` kanalı, üst bar, Finans, fon kapıları ve sonlar aynı sayıyı okur. Biçim (aylık mı, yıllık mı) C'nin;
  E yalnız sayıyı verir.
- B2C kaydı ilk gelir anında kurulur (bugün ücretli plan açılınca kuruluyordu); tohum memnuniyeti kuralı aynı.
- **Bu ay / geçen ay:** "Bu ay" o anki aylık hız. Ay kapanışında hızlar kapanan ayın kaydına yazılır: komisyon,
  üyelik, satış hacmi, sipariş (dört tam sayı). "Geçen ay" son kaydı okur.
- **Bu ay katılan / ayrılan:** koşu boyu toplamlar ve ay açılışında alınan taban (bugünkü "bu ay kazanılan hesap"
  kalıbı).

### 5.6 Kalite bağları (özet)
| Ürün tarafı | Bağlandığı sayı |
|---|---|
| Bütün hatlar (eksen puanları → kalite) | Alıcı büyümesi ve aşınma (bugünkü), ağızdan ağıza (deneyim ekseni → alıcı memnuniyeti), üye oranı (q_mult) |
| Satıcı hatları (Ürün Yükleme, Satıcı Paneli) | Mağaza memnuniyeti "Araçlar" (kademe başına +2,5 puan) |
| Sepet ve Ödeme K1 / K2 | Komisyon açılır / sepet ortalaması ×1,12 |
| Satıcı hatlarındaki açık hata | Mağaza memnuniyeti "Açık hata" |
| Alıcı ve paylaşılan hatlardaki açık hata | A'nın B2C kaybı (alıcı) |
| Onboarding Akışı (Ar-Ge) | Üye oranı ×1,15 |
- Kalite modeli değişmez: kimlik hatları 5 (2 yenilik, 1 kararlılık, 2 deneyim) + 4 paylaşılan, GDD'nin "eksen başına 3
  hat" kuralı korunur. Eski PRD'nin 14 hatlık ağacı ve "iki tarafın ortalaması" kalite seçeneği bu yüzden alınmadı:
  kalite zincirini ve onu okuyan ~16 yeri yeniden açardı.

### 5.7 Sistem: yeni `MarketplaceSystem`
- **Karar:** Yeni statik sistem `scripts/systems/marketplace_system.gd`. `SalesSystem` alıcı motorunu ve tek MRR
  kanalını tutar.
- **Gerekçe:** Mağaza, memnuniyet, sipariş, iki gelir ve iki önizleme kendi içinde bütün; `SalesSystem` B2B ile B2C'yi
  zaten taşıyor (548 satır). Eski fiyat makinesi (dönüşüm, fiyat çarpanı, değer algoritması, artış tepkisi, fiyat
  önizlemesi; ~130 satır) silinince `SalesSystem`'in B2C kısmı incelir, pazaryeri tek dosyada okunur. Durum
  `GameState` bayraklarındadır; sistem statik durum tutmaz, `reset_all_owners`'a girmez.
- **API (WRITE-THROUGH):**
  - Yazarlar: `set_commission(c)`, `set_member_fee(ücret)` (bugünkü `apply_b2c_price`'ın yerine), `open_membership(ücret)`
    (kart ve fikstür ortak yolu; bugünkü `open_b2c_paid_tier` ve `open_paid_plan`'ın fiyat kısmı), `open_market()` (v1.0).
  - Tik: `weekly_tick()` (`SalesSystem.daily_tick` B2C kolundan), `derive_mrr()` (saatlik).
  - Okumalar: `figures()` tek sözlük (sayfa, probe, C'nin İş özeti), `estimate_commission(c)` ve `estimate_fee(ücret)`
    (saf; alıcı sabit tutulup `PREVIEW_WEEKS` hafta adımlanır), `side_of(hat)`, `affected(hat, pay)`,
    `orders_in_hours(h)`, `aov()`, `month_close_fields()`.
- **Silinir:** `SalesSystem.conversion_rate`, `churn_fraction`, `audience_growth_multiplier`, `estimate_price_change`,
  `apply_b2c_price`, `open_b2c_paid_tier`, `product_value`, `rnd_conversion_mult` (pazaryerine taşınır), sabitleri
  (`B2C_PRICE_DEFAULT`, `VALUE_*`, `TENDENCY_MULT`, `CONVERSION_*`, `BUG_CONV_*` A silmediyse, `CHURN_MAX`,
  `AUD_PRICE_MULT_*`); `ProductCatalog.price_tendency` alanı ve `get_price_tendency`. Gerekçe: yerini alan kod eskisini
  aynı commit'te siler (CLAUDE §8); GDD ch03'ün "canlı fiyat paneli" B2C'de Pazaryeri kollarına döner (GUNCELLEMELER).

### 5.8 Ağaç: veri ve sprint
- **Hat dosyası** `data/product/lines/marketplace.json`: bugünkü `lines[5]` biçimi; her hatta yeni `side` alanı
  (`buyer` | `seller`). Doğrulayıcıya tek kural: alt tür B2C ise iki taraf da en az bir hatla var. Eksen 2/1/2, 3 kademe,
  efor bantları ve K3 Ar-Ge kuralları bugünkü gibi. Eski PRD'nin `groups[]` biçimi alınmadı (EA'da beş yeni hat "modül"
  grubu olarak gelir).
- **Sayılar** (not aracının aralığında; efor K1 5–6, K2 7–8, K3 10–11; eksen puanı 4/9/12; kullanım ağırlığı 0/1/3):
  | Hat | K2 kişi şartı | K3 Ar-Ge ve kişi şartı |
  |---|---|---|
  | Keşif | Yazılım ★2 | `semantic_index`; Yazılım ★2, Ürün ★1 |
  | Sepet ve Ödeme | Yazılım ★2, Test ★1 | `security_cert`; Test ★2 |
  | Siparişlerim | Tasarım ★2 | `analytics_engine`; Tasarım ★1, Yazılım ★2 |
  | Ürün Yükleme | Yazılım ★2 | `ai_engine` (`ai: true`); Ürün ★2 |
  | Satıcı Paneli | Tasarım ★2, Ürün ★1 | `design_system`; Tasarım ★2 |
  - `ai_engine` böylece B2C'de bir kademe açmaya devam eder (bugün yalnız not ve videonun AI kademelerini açıyor).
  - K3 adları dönem tarafsızdır (2012'de anlamlı).
  - (inceleme) `license_cost` ve öbür kademe alanları not aracının dosyasındaki aynı kademe sırasıyla taşınır (bugün
    K2'lerde $800 gibi); yazılmazsa B2C'nin "Araçlar ve servis gideri" kalibrasyonu (ACIK 96) sessizce düşer.
  - (inceleme) **D varsayımı:** D kart puanını kademe × eksen tablosundan okur (×5 ölçek, K1 15 / K2 25 / K3 40) ve
    kartın `effort`/`shares` alanlarını kaldırır. Yukarıdaki efor bantları D'den önceki biçimdir; `marketplace.json`
    D'nin bıraktığı hat biçimine uyar (0b tazelemesi). Eksen seçimi D'nin ihtiyaç payını belirler: Sepet ve Ödeme
    (Kararlılık) teste ağır, Keşif ve Ürün Yükleme (Yenilik) geliştirmeye ağır, Siparişlerim ve Satıcı Paneli (Deneyim)
    tasarıma ağır. Üyelik programı kartı D'nin `need.paid_plan` satırını (2 / 10 / 3) kullanır.
  - (inceleme) GDD §12.9'un işlenmiş örneği ve §12.10'un tek başına ulaşılabilir K3 çapası bugün not aracının
    hatlarına yazılı (`card_math_matches_gdd_example`, `line_note_tool_linking_k3`). E2 bu iki vakayı bir pazaryeri
    hattına taşır (öneri: Siparişlerim K2 efor 8, Deneyim; Keşif K3 çapa) ve GUNCELLEMELER'e iki örneğin yeni yerini yazar.
- **Alt tür kaydı:** `{"id": "marketplace", "sectors": ["consumer", "retail", "ecommerce"], "market_type": "b2c"}` "saas"
  haber havuzunda; eksen ağırlıkları not aracınınkiyle aynı başlar. `TYPE_SCREEN.b2c.playable = ["marketplace"]`.
- **Alanlar** (`sprint.json`): `core` yalnız B2B'ye kalır; B2C'ye `buyer` ve `seller` gelir (`identity: true`, `side`).
  `SprintCatalog.capabilities` kimlik hatlarını tarafa göre süzer; "tek kimlik alanı" varsayan beş yer (MVP sayacı ve
  adayları, MVP tahmini `mvp_eta`, basın satırı, ürün modelinin MVP satırı, alan cümlesi) "kimlik alanları" okumasına
  geçer. Yeni `mvp_min_per_side: 1`.
- **Rakipler:** `rivals.json`'a pazaryeri bloğu (3 rakip, 10 hattın kademe tablosu, sprint takvimli çıkışlar; Ödeme ve
  Ürün Yükleme hatlarında yoğun). `RivalCatalog.NAMES.marketplace` 8 parodi ad. Piyasa'nın sektör yuvası
  `sector_slots.marketplace` halka açık üç şirket. Rakip olmadan kalite terimi başa baş okunamaz; bu yüzden E1'de.
- **Silinenler (E2):** `note_tool.json`, `video_clip.json`, iki alt tür kaydı, rakip blokları, ad satırları, sektör
  yuvaları, 112 metin anahtarı, `full_run_b2c_video`. Not ve videoyu adıyla anan Ar-Ge metinleri yeniden yazılır (§6.4).
  Piyasa'daki şirketler (Elephanta, Bitwaltz…) halka açık şirket olarak kalır.

### 5.9 Erken Erişim (bu fazda yazılmaz)
Premium mağaza, Öne çıkan ürünler (reklam), Paketler ekranı, beş ek hat (Yorumlar, Ürün Sayfası, Kampanya Araçları,
Hakediş, Satıcı Başvurusu), kategori komisyonu ve hacim kademesi, sezonlar (Kara Cuma, Yılbaşı, mevsimsiz gelir kuralı),
satıcı çağrısı (pazarlama modülü), mağaza yükünün sunucuya ve desteğe yazılması, dört akımlı %65 kuralı.

### 5.10 Öteki fazların okuma noktaları (E tek yazar)
| Okuyan | Neyi | Nereden | Not |
|---|---|---|---|
| A, düzeltme kartı ve hat ipucu | Etkilenen sayı | (inceleme) A'nın okuma noktası `SprintCatalog.line_impact(hat)` kalır; B2C kolu bugün `{users}` = kitle × (1 + ağırlık) / Σ(1 + ağırlık) döndürür. E bu kola alıcı yerine `MarketplaceSystem` sayısını verir; satıcı hattında aynı pay mağazaya uygulanır ve `{stores}` döner. Ayrı bir `affected()` API'si kurulmaz | Yeni anahtarlar `PRODUCT_FIX_STORES` ve A'nın `PRODUCT_BUGS_TIP_B2C` ikizi `PRODUCT_BUGS_TIP_STORES` ("{stores} mağaza etkileniyor") |
| A, kullanım çarpanı | Hata akışı çarpanı `1 + kitle/2000` (`support_system.gd:184`, GDD ch03 §8) | Alıcı sayısı, değişmez | (inceleme) A bu çarpanı "E ile birlikte gözden geçirilir" diye bıraktı; E'nin cevabı: alıcıda kalır, mağaza yükü EA |
| B, "Ödeme alınamıyor" | Yarım kalan sepet | `orders_in_hours(h)` = aylık sipariş / 730 × h (inceleme: "ayın saati" tanımsızdı; saat oyuncunun okuduğu saat olduğu için gerçek ayın 730 saati); seam `sales.mkt_orders_week` | Olay yalnız Sepet ve Ödeme canlıyken: seam `sales.mkt_checkout_live` |
| B, kupon telafisi | Kupon büyüklüğü | `aov()` × kullanıcı sayısı × B'nin oranı | B/C varsayımı: B kuponu etkilenen sayı × tutar olarak hesaplar |
| B, kesinti iadesi ve fırtına özrü | Üye payı ve üyelik ücreti | (inceleme) `figures().members / figures().buyers` ve `figures().member_fee`; seam `sales.mkt_members`, `sales.b2c_price` (anlamı üyelik ücreti) | B'nin "ödeyen × aylık ücret" formülü E'de "üye × üyelik ücreti" olur (B incelemesinin ana oturuma notu). Üyelik açılmadıysa iade seçeneği çıkmaz; B tazelemesi o durumda seçenek setini değiştirir |
| B, "Yorum fırtınası" | Alıcı sayısı | `sales.b2c_audience` (değişmez) | — |
| B, söz olayının B2C ikizi | Mağaza sayısı, memnuniyet | seam `sales.mkt_stores`, `sales.mkt_store_satisfaction` | B'nin yeniden yazdığı ikiz mağazaya dokunuyorsa |
| C, İş özeti | Alıcı, üye, mağaza, aylık gelir | `figures()` | C varsayımı: İş özetinin B2C kolu tek fonksiyonda |
| C, sunucu birimi | Yük | Bugünkü gibi alıcı sayısı (`served_count`) | Mağaza yükü EA. C birimi değiştirirse yalnız C'nin kodu değişir |
| C, istekler | Tarafa göre birim | `side_of(hat)`: satıcı isteği mağaza sayısıyla, alıcı isteği yorum sayısıyla. (inceleme) Satıcı isteği = round(mağaza × `SELLER_ASK_RATE` × pay), C'nin alıcı formülünün (kitle × 0,004 × pay) ikizi; C'nin `b2c_asks()` satıcı hattında bu formülü çağırır | C varsayımı: C'nin B2C istek verisi hat kimliği taşır (C §5.5) |
| Son kâğıdı (ch13) | Nüfus satırı | (inceleme) Koşu defteri `paying_users` yerine `members` ve yeni `stores` taşır; `endings_copy.gd` B2C'de "alıcı · üye · mağaza" yazar | Planda yoktu; GDD ch13 B2C'de "kitle + ödeyen" ister, pazaryerinde "ödeyen" üyedir ve mağaza sayısı eksik kalırdı. E3'te; GUNCELLEMELER ch13 girdisi |
| C, ürün başlığı | Alıcı, üye | `figures()` | C varsayımı: başlık ölçüleri C'de kalıyorsa yalnız etiket değişir |
| Olay motoru | Pazaryeri durumu | Yeni seam'ler: `sales.mkt_stores`, `sales.mkt_members`, `sales.mkt_store_satisfaction`, `sales.mkt_orders_week`, `sales.mkt_commission`, `sales.mkt_checkout_live`, `sales.mkt_revenue_started` | `--event-vocab` yeniden üretilir |

### 5.11 Kayıt
- **E2 (silme):** `SCHEMA_VERSION` +1 (A ya da B şemayı artırdıysa onun bir fazlası; A/B/C varsayımı) ve
  `MIN_LOADABLE_VERSION := SCHEMA_VERSION`. Silinen alt türün kaydı yüklenirse hat listesi boş döner; seçerek düşürmek
  ERP göç zincirini yaşatmayı ister. Sürüm 0.1.0, yayımlanmış yapı yok. Aynı commit erişilemez kalan göçleri siler
  (`_migrate_sales_rev6`, `_migrate_13`, `_migrate_14`, `_migrate_15` ve v10 öncesi zincir) ve onları sınayan vakaları
  emekliye ayırır (onay bekliyor). `SAVE_ERR_TOO_OLD` iddiası hayatta kalan vakaya taşınır. Soru 2.
- **E3 (ekonomi):** şema artmaz. Yeni bayraklar `FLAG_TYPES`'a anlamlı varsayılanla: `mkt_stores` (float, 0),
  `mkt_store_sat` (float, 0), `mkt_commission` (int, 10), `mkt_stores_joined` (float, 0), `mkt_stores_left` (float, 0).
  Yeniden kullanılan: `b2c_audience` (alıcı), `b2c_price` (üyelik ücreti), `b2c_paid_tier_open` (üyelik açık);
  adları değişmez, `FLAG_TYPES` yorumu anlamlarını söyler. Ay açılışı `stores_joined` ve `stores_left` tabanını, ay
  kapanışı `mkt_commission`, `mkt_membership`, `mkt_gmv`, `mkt_orders` tam sayılarını yazar; eski kayıtta yoksa 0.
  Haftalık örnek dizisine `stores` eklenir. `initialize_run` yeni bayrakları zaten bayrak sözlüğüyle sıfırlar.

### 5.12 Sabitler (hepsi onay bekliyor, hepsi [ÇALIŞMA])
| Sabit | Değer | Anlamı |
|---|---|---|
| STORE_SEED | 12 | v1.0'da hazır mağaza |
| BPS_TARGET | 65 | Mağaza başına hedef alıcı |
| C_REF | 10 | Komisyonun nötr noktası (%) |
| FEE_ELAST (inceleme) | 0,5 | Mağaza hedefinin komisyona esnekliği; 1 olursa komisyon geliri orandan bağımsızlaşır (§5.2) |
| TOL_HI, TOL_LO, TOL_SLOPE, TOL_REF (inceleme) | 1,6, 0,6, 0,2, 500 alıcı | Trafik toleransı (§5.2) |
| SELLER_ASK_RATE (inceleme) | 0,15 | Satıcı isteğinde mağaza payı (184 mağaza × 0,15 × pay 0,4 ≈ 11) |
| Ayın saati (inceleme) | 730 | `orders_in_hours` böleni |
| Komisyon | varsayılan 10, aralık 0–25, adım 1 | |
| fee_mult sınırları | 0,4–1,8 | `C_REF / c` |
| JOIN_BASE | 0,5 mağaza/hafta | Kitleden bağımsız giriş |
| JOIN_PULL | 0,15 | Hedefle fark kapanma hızı (haftalık) |
| CHURN_BASE | %0,6/hafta | Taban ayrılma |
| CHURN_UNHAPPY | %4/hafta | Memnuniyet 0'daki ek ayrılma |
| SAT_LEAVE | 40 | Ayrılmanın hızlandığı memnuniyet |
| SAT_BASE, TOOLS_W, SALES_W | 50, 15, 15 | Memnuniyet hedefi |
| OPS_REF | 60 sipariş/mağaza/ay | "Satışlar" teriminin sıfır noktası |
| FEE_W | 2,5 puan / komisyon puanı | |
| BUG_W, BUG_CAP | 2 puan/hata, 20 | Satıcı hatlarındaki açık hata |
| SAT_DRIFT | 3 puan/hafta | |
| SHOCK_PER_PT | 2 puan | Yalnız artışta |
| SEL_MIN, SEL_MAX | 0,5, 1,2 | Seçenek çarpanı (büyümede); siparişte taban yok |
| SEL_GROWTH_K | ~1,5 (ölçülür) | Bugünkü fiyat çarpanının ortalaması |
| F_FREE | 1,0 sipariş/alıcı/ay | |
| MEMBER_ORDER_MULT | 1,6 | |
| AOV | $40 | |
| CHECKOUT_K2_AOV | 1,12 | Taksit |
| MEMBER_BASE | 0,10 | |
| q_mult sınırları | 0,4–1,6 | `q / 50` |
| FEE_REF, FEE_SLOPE | $7, 0,5 | |
| Üyelik ücreti | açılış $7, aralık $1–30, adım $1 | |
| MEMBER_MIN, MEMBER_MAX | 0,005, 0,25 | |
| Onboarding Akışı | ×1,15 üye oranı | Bugünkü değer, yeni hedef |
| PREVIEW_WEEKS | 13 | "3 ayda" önizlemesi |
| Ölçüm kapısı pencereleri | §7 | |

**Örnek hesap (52. hafta, [ÇALIŞMA]):** alıcı 12.400, q 42,5 → üye oranı %8,5 → 1.050 üye. Mağaza 184 (hedef 191).
sel 0,965. Sipariş 12.400 × 0,965 × 1,051 = 12.580. Hacim $503.000. Komisyon $50.300, üyelik $7.350, toplam $57.650
(%87 komisyon). Mağaza memnuniyeti: 50 + 7,5 (araçlar 3/6) + 2,8 (ops 68) − 0 − 4 (2 açık hata) = 56.

---

## 6. Metin taslakları
Hepsi taslak, "TR/EN onay bekliyor". Önce İngilizce yazıldı. Özel adlar çevrilmez.

### 6.1 Tür (E1)
| Anahtar | EN | TR |
|---|---|---|
| PROD_TYPE_MARKETPLACE_NAME | Marketplace | Pazaryeri |
| PROD_TYPE_MARKETPLACE_CATEGORY | Shopping | Alışveriş |
| PROD_TYPE_MARKETPLACE_DESC | Stores · buyers · payment on one platform. | Mağaza · alıcı · ödeme tek platformda. |
| PROD_TYPE_MARKETPLACE_TRADEOFF | Buyers go where the stores are and stores go where the buyers are. One side has to be started by hand. | Alıcı mağazanın, mağaza alıcının olduğu yere gider. Bir tarafı elle başlatmak gerekir. |
| PROD_TYPE_MARKETPLACE_BET | Small sellers have no place of their own online. Give them one and bring the buyers to it. | Küçük satıcının internette kendi yeri yok. Ona bir yer açıp alıcıyı oraya getir. |
| PROD_TYPE_MARKETPLACE_PITCH | The marketplace where independent stores sell to everyone. | Bağımsız mağazaların herkese sattığı pazaryeri. |
| PROD_PATH_B2C_DESC (değişir) | You bring stores and buyers together. Both sides arrive and leave, and the numbers swing. | Mağazalarla alıcıları buluşturursun. İki taraf da gelir, gider; sayılar dalgalanır. |

### 6.2 Hatlar ve kademeler (E1)
Hat anahtarı `PROD_LINE_MARKETPLACE_<HAT>`, kademe `PROD_STEP_MARKETPLACE_<HAT>_K<n>`, açıklama `…_DESC`.

| Hat (EN / TR) | Kademe EN / TR | Açıklama EN | Açıklama TR |
|---|---|---|---|
| Discovery / Keşif | K1 Category and Search / Kategori ve Arama | Products sit in categories and a search box finds them by name. | Ürünler kategorilere oturur, arama kutusu onları adıyla bulur. |
| | K2 Filters and Sorting / Filtre ve Sıralama | Price, size, brand. A buyer narrows a thousand results down to twenty. | Fiyat, beden, marka. Alıcı bin sonucu yirmiye indirir. |
| | K3 Personal Picks / Kişisel Öneriler | The home page is different for every buyer. What they looked at last week shapes what they see today. | Ana sayfa her alıcıda başka. Geçen hafta baktığı şey bugün gördüğünü belirler. |
| Cart and Checkout / Sepet ve Ödeme | K1 Card Payment / Kartla Ödeme | The cart becomes an order with a card. The money now passes through us. | Sepet kartla siparişe döner. Para artık bizim üstümüzden geçer. |
| | K2 Saved Cards and Instalments / Kayıtlı Kart ve Taksit | The card is remembered and the bill can be split into instalments. Bigger baskets stop stalling at the last step. | Kart hatırlanır, tutar taksitlere bölünür. Büyük sepetler son adımda takılmaz. |
| | K3 Fraud Shield / Dolandırıcılık Kalkanı | Stolen cards are caught before the order goes through. The chargeback letters stop arriving. | Çalıntı kart sipariş geçmeden yakalanır. Ters ibraz yazıları gelmez olur. |
| My Orders / Siparişlerim | K1 Order Status / Sipariş Durumu | The buyer sees where the order stands without writing to the store. | Alıcı siparişin ne durumda olduğunu mağazaya yazmadan görür. |
| | K2 Tracking and Returns / Kargo Takibi ve İade | The tracking number sits in the order and a return starts with one button. The seller still does the shipping. | Takip numarası siparişin içinde durur, iade tek düğmeyle başlar. Gönderiyi yine satıcı yapar. |
| | K3 Delivery Estimate / Teslimat Tahmini | Before paying, the buyer sees the day it will arrive. The estimate comes from how that store really ships. | Alıcı ödemeden önce hangi gün geleceğini görür. Tahmin o mağazanın gerçek gönderilerinden çıkar. |
| Listings / Ürün Yükleme | K1 Single Listing / Tek Tek Yükleme | A seller adds products one at a time, with photos and a price. | Satıcı ürünleri fotoğrafı ve fiyatıyla tek tek ekler. |
| | K2 Bulk Upload / Toplu Yükleme | A spreadsheet goes in and four hundred products come out. Large stores start to look our way. | Bir tablo yüklenir, dört yüz ürün çıkar. Büyük mağazalar bize bakmaya başlar. |
| | K3 Catalog Matching / Katalog Eşleme | A new listing is matched to the product already in the catalog. The same phone stops appearing forty times. | Yeni ilan katalogdaki aynı ürünle eşleşir. Aynı telefon kırk kez görünmez olur. |
| Seller Panel / Satıcı Paneli | K1 Orders and Labels / Sipariş Listesi ve Kargo Etiketi | New orders land in one list and the shipping label prints from there. | Yeni siparişler tek listeye düşer, kargo etiketi oradan basılır. |
| | K2 Payouts and Invoices / Hakediş ve Fatura | Every week the seller sees what sold, what we kept and what was paid out. The invoice is ready. | Satıcı her hafta neyin satıldığını, bizim payımızı ve hesabına geçeni görür. Fatura hazırdır. |
| | K3 Storefront / Mağaza Vitrini | A store gets a page of its own, with its own banner and its own order of products. | Mağazanın kendi sayfası olur; kendi afişi, kendi ürün dizilişi. |

Paylaşılan ve gizli hatların pazaryeri açıklamaları (`PROD_STEP_SHARED_<HAT>_K<n>_MARKETPLACE_DESC`,
`PROD_STEP_HIDDEN_SELF_SERVE_K<n>_MARKETPLACE_DESC`):
| Kademe | EN | TR |
|---|---|---|
| Entegrasyonlar K1 | Stores connect one courier account. Labels and tracking numbers come from there. | Mağazalar bir kargo hesabı bağlar. Etiket ve takip numarası oradan gelir. |
| Entegrasyonlar K2 | Several couriers and the stores' accounting software connect at once. | Birden çok kargo firması ve mağazaların muhasebe programı aynı anda bağlanır. |
| Entegrasyonlar K3 | Stores with systems of their own send stock and price over an open interface. | Kendi sistemi olan mağazalar stok ve fiyatı açık bir arayüzden gönderir. |
| Güvenlik K1 | Buyers and sellers sign in to separate accounts. A store cannot see another store's orders. | Alıcı ve satıcı ayrı hesaplarla girer. Bir mağaza ötekinin siparişini göremez. |
| Güvenlik K2 | A store owner opens the orders to the warehouse clerk and keeps the payouts to themselves. | Mağaza sahibi depocuya siparişleri açar, hakedişi kendine saklar. |
| Güvenlik K3 | Every change to a price or a payout account is recorded with a name and a time. | Fiyattaki ve hakediş hesabındaki her değişiklik, yapanın adı ve saatiyle kayda geçer. |
| Dayanıklılık K1 | A closed tab does not take the cart with it. The buyer comes back and it is still there. | Kapanan sekme sepeti götürmez. Alıcı döndüğünde sepet yerinde durur. |
| Dayanıklılık K2 | An order that failed halfway is either completed or rolled back. Nobody pays for something that never left. | Yarıda kalan sipariş ya tamamlanır ya geri alınır. Kimse yola çıkmayan bir şeyin parasını ödemez. |
| Dayanıklılık K3 | The site stays up on the busiest night of the year. The servers double without anyone being woken. | Yılın en yoğun gecesinde de site ayakta kalır. Sunucular kimse uyandırılmadan iki katına çıkar. |
| Mobil K1 | The pages fit a phone screen. Buying works there; selling is still done at a desk. | Sayfalar telefon ekranına sığar. Alışveriş olur, satış hâlâ masada yapılır. |
| Mobil K2 | Buyers get an app. Most orders start in a pocket from now on. | Alıcının uygulaması olur. Siparişlerin çoğu artık cepte başlar. |
| Mobil K3 | Sellers answer orders from their phones too. A store can be run from behind the counter. | Satıcı da siparişleri telefondan cevaplar. Mağaza tezgâhın arkasından yönetilir. |
| Kendi Kendine Servis K1 | The questions buyers ask most are answered on the order page. | Alıcıların en çok sorduğu sorular sipariş sayfasında cevaplanır. |
| Kendi Kendine Servis K2 | A help library for buyers and a separate one for stores. | Alıcılar için bir yardım kütüphanesi, mağazalar için ayrı bir tane. |
| Kendi Kendine Servis K3 | A buyer cancels, changes the address or opens a return without writing to anyone. | Alıcı kimseye yazmadan siparişi iptal eder, adresi değiştirir ya da iade açar. |

### 6.3 Alanlar ve MVP (E1)
| Anahtar | EN | TR |
|---|---|---|
| PRODUCT_AREA_BUYER, _SHORT | Buyers | Alıcı |
| PRODUCT_AREA_BUYER_WEAK | Buyers struggle to find what they came for | Alıcılar aradığını bulmakta zorlanıyor |
| PRODUCT_AREA_BUYER_ENOUGH | Buyers find what they want and pay without trouble | Alıcılar aradığını bulup sorunsuz ödüyor |
| PRODUCT_AREA_BUYER_STRONG | Buyers come back on their own and bring friends | Alıcılar kendiliğinden geri geliyor, arkadaşlarını da getiriyor |
| PRODUCT_AREA_SELLER, _SHORT | Sellers | Satıcı |
| PRODUCT_AREA_SELLER_WEAK | Stores spend more time on our tools than on selling | Mağazalar satıştan çok bizim araçlarımızla uğraşıyor |
| PRODUCT_AREA_SELLER_ENOUGH | Stores list and ship without calling us | Mağazalar bizi aramadan ürün yüklüyor ve gönderiyor |
| PRODUCT_AREA_SELLER_STRONG | Stores move their whole catalog to us | Mağazalar bütün kataloglarını bize taşıyor |
| PRODUCT_RESEARCH_VOICE_BUYER | The buyers we talked to want to find things faster | Görüştüğümüz alıcılar aradığını daha çabuk bulmak istiyor |
| PRODUCT_RESEARCH_VOICE_SELLER | The stores we talked to want to spend less time on listings | Görüştüğümüz mağazalar ürün yüklemeye daha az vakit ayırmak istiyor |
| PRODUCT_GOAL_BUYER | half of buyers come back within a month | alıcıların yarısı bir ay içinde geri gelsin |
| PRODUCT_GOAL_SELLER | half of stores list without asking us | mağazaların yarısı bize sormadan ürün yüklesin |
| PRODUCT_AREA_IDENTITY_MKT_SHORT | Buyers and sellers | Alıcı ve satıcı |
| PRODUCT_MVP_SIDES_TIP | v1.0 needs at least one buyer feature and one seller feature. | v1.0 için alıcı ve satıcı tarafından en az birer özellik gerekir. |
| PROD_LOCK_LINE | {line} needed | {line} gerekli |

### 6.4 Değişen metinler (E2, E3)
| Anahtar | EN | TR |
|---|---|---|
| PRODUCT_CAP_PAID_PLAN | Membership program | Üyelik programı |
| EFFECT_PAID_TIER | Membership opens | Üyelik açılır |
| SALES_B2C_USERBASE | {product} buyers | {product} alıcıları |
| PRODUCT_RELEASE_USERS (_ONE) | {n} buyers in the first week | İlk hafta {n} alıcı |
| CHEQUE_STEP_REVENUE (yeni) | First revenue | İlk gelir |
| PROD_RND_NODE_AI_ENGINE_UNLOCK | The catalog matching tier in Marketplace. | Pazaryeri'nin katalog eşleme kademesi. |
| PROD_RND_NODE_SEMANTIC_INDEX_UNLOCK | The personal picks tier in Marketplace, and the document reading tier in ERP. | Pazaryeri'nin kişisel öneri kademesi, ERP'nin belge okuma kademesi. |
| PROD_RND_NODE_SCALABLE_BACKEND_UNLOCK | The last tier of the Durability line · collections in ERP. The same hardware carries more users now. | Dayanıklılık hattının son kademesi · ERP'de tahsilat. Aynı donanım artık daha çok kullanıcı taşıyor. |
| PROD_RND_NODE_ANALYTICS_ENGINE_UNLOCK | The cash forecast tier in ERP, and the delivery estimate tier in Marketplace. | ERP'nin nakit öngörüsü kademesi, Pazaryeri'nin teslimat tahmini kademesi. |
| PROD_RND_NODE_SECURITY_CERT_UNLOCK | The last tier of the Security and Access line, and the fraud shield in Marketplace. | Güvenlik & Yetki hattının son kademesi, Pazaryeri'nin dolandırıcılık kalkanı. |
| PROD_RND_NODE_ONBOARDING_FLOW_UNLOCK | We shape the first five minutes now, and more buyers take up membership. | İlk beş dakikayı artık biz kuruyoruz; alıcılar üyeliğe daha sık geçiyor. |
| PROD_RND_NODE_ONBOARDING_FLOW_DISCOVERY | New arrivals got stuck on the first screen and never came back. For a week we rewrote the first five minutes. More buyers take up membership now. | Yeni gelenler ilk ekranda takılıp bir daha dönmüyordu. Bir hafta boyunca ilk beş dakikayı baştan yazdık. Alıcılar artık üyeliğe daha sık geçiyor. |
| PRODUCT_FIX_STORES (_ONE) (yeni; A'nın kartı) | {n} stores | {n} mağaza |

Silinen: `SALES_EMPTY_B2C_PRE`, `SALES_B2C_CONVERSION`, `SALES_B2C_PLAN_CLOSED`, `SALES_B2C_CURVE`,
`SALES_B2C_PLAN_HINT` (E4), not ve video anahtarları (E2).

### 6.5 Pazaryeri sayfası (E4, E5)
| Anahtar | EN | TR |
|---|---|---|
| TAB_MARKETPLACE | Marketplace | Pazaryeri |
| MKT_STORES | Stores | Mağazalar |
| MKT_BUYERS | Buyers | Alıcılar |
| MKT_REVENUE | Revenue | Gelir |
| MKT_STORES_ACTIVE | Active stores | Aktif mağaza |
| MKT_STORES_JOINED | Joined this month | Bu ay katılan |
| MKT_STORES_LEFT | Left this month | Bu ay ayrılan |
| MKT_STORE_SAT | Store satisfaction | Mağaza memnuniyeti |
| MKT_COMMISSION | Commission | Komisyon |
| MKT_BUYERS_ACTIVE | Active buyers | Aktif alıcı |
| MKT_MEMBERS | Members | Üye |
| MKT_FREE | Free | Ücretsiz |
| MKT_MEMBER_FEE | Membership fee | Üyelik ücreti |
| MKT_MEMBERSHIP | Membership | Üyelik |
| MKT_TOTAL | Total | Toplam |
| MKT_GMV | Sales volume | Satış hacmi |
| MKT_ORDERS | Orders | Sipariş |
| MKT_AOV | Average basket | Sepet ortalaması |
| MKT_COL_THIS | This month | Bu ay |
| MKT_COL_LAST | Last month | Geçen ay |
| MKT_COL_CHANGE | Change | Değişim |
| MKT_CURVE | Weekly buyers | Haftalık alıcı |
| MKT_EMPTY_PRE | The marketplace opens when {version} ships. | Pazaryeri {version} yayınlanınca açılır. |
| MKT_SEED | {n} stores ready at launch | Açılışta {n} mağaza hazır |
| MKT_PART_TOOLS | Tools {v} | Araçlar {v} |
| MKT_PART_SALES | Sales {v} | Satışlar {v} |
| MKT_PART_FEE | Commission {v} | Komisyon {v} |
| MKT_PART_BUGS | Open bugs {v} | Açık hata {v} |
| MKT_TIP_RATE | Member rate {pct}: quality ×{q} · fee ×{f} | Üye oranı {pct}: kalite ×{q} · ücret ×{f} |
| MKT_TIP_COMMISSION | Marketplaces charge between 5% and 25% depending on the category. | Pazaryerleri kategoriye göre %5 ile %25 arası komisyon alır. |
| MKT_TIP_TAKE | The platform keeps {pct} of sales volume. | Satış hacminin {pct} kadarı platforma kalır. |
| MKT_PREV_REVENUE (inceleme) | Revenue {now} a month now, {later} in 3 months | Gelir ayda {now} şimdi, 3 ay sonra {later} |
| MKT_PREV_REVENUE_LATER | Revenue starts when {line} ships | Gelir {line} yayınlanınca başlar |
| MKT_PREV_SAT | Store satisfaction {from} → {to} | Mağaza memnuniyeti {from} → {to} |
| MKT_PREV_ENTRY | New stores {pct} | Yeni mağaza girişi {pct} |
| MKT_PREV_STORES_FEWER (_ONE) | About {n} fewer stores in 3 months | 3 ayda yaklaşık {n} mağaza eksik |
| MKT_PREV_STORES_MORE (_ONE) | About {n} more stores in 3 months | 3 ayda yaklaşık {n} mağaza fazla |
| MKT_PREV_RATE | Member rate {from} → {to} | Üye oranı {from} → {to} |
| MKT_PREV_MEMBERS | Members {from} → {to} | Üye {from} → {to} |
| MKT_APPLY | Apply | Uygula |
- "Vazgeç" `SYS_CANCEL`, "/ay" `SALES_PER_MONTH`, kilitler `PROD_LOCK_LINE` ve `PRODUCT_LOCK_LIVE` ile.
- Sözlüğe (`localization_glossary.md`): Pazaryeri/Marketplace, Mağaza/Store, Alıcı/Buyer, Üye/Member,
  Üyelik/Membership, Komisyon/Commission, Satış hacmi/Sales volume, Sepet ortalaması/Average basket. Ekranda "GMV"
  kısaltması yok.

### 6.6 Rakip adları (E1, ad taraması onay bekliyor)
`RivalCatalog.NAMES.marketplace`: Stitchery, Wishwell, Plushmark, Jetsam, Bazaarly, Haggle, Stallway, Tradepost (ASCII,
uluslararası parodi; Rakip Dünyası kuralı). Gerçek bir pazaryeri ya da bilinen markayla çakışan çıkarılır. Piyasa
sektör yuvası önerisi: `bidwell`, `dealflock`, `shopstead` (halka açık, `companies.json`'da var); devler (Orinoco,
Sindbad) yuvaya girmez.

### 6.7 Olay kartlarının pazaryeri okuması (E6)
- `product.paid_tier` (Frank, "Fiyat meselesi"): Frank'in satırı ve metni değişmez. Koşul "ücretli plan konmadı"
  yerine "gelir başlamadı" (`sales.mkt_revenue_started == false`), gidilen sekme Pazaryeri. Yalnız ilan döneminde
  çıkar. Erdem onayı gerekir (Frank külliyatı).
- `world.app_placement`, `world.b2c_creator_feature`, `customer.b2c_refunds`: metinleri pazaryerinde okunur mu diye
  bakılır; "uygulama" pazaryeri için de doğru (alıcı uygulaması). Değişmesi gereken cümle varsa taslak olarak Erdem'e.
  (inceleme) `sales.b2c_audience` okuyan dört kart daha taramaya girer: `funding.portfolio_vendor`,
  `product.launch_leak`, `rival.shutdown_notice`, `team.wiped_table`.

### 6.8 B'nin E'ye bıraktığı metinler (inceleme)
B planı şu pazaryeri metinlerini açıkça E'ye erteledi; E planında karşılıkları yoktu. Hepsi önce İngilizce, TR/EN onay
bekliyor; yazım Opus'ta (adım 6w).
- **Sürüm sonrası öne çıkan yorumlar** (B §6.5): beş pazaryeri hattına 2 olumlu, 2 olumsuz kısa yorum (20); kaynak
  etiketi alıcı hatlarında "Sosyal medya" ya da "Uygulama mağazası", satıcı hatlarında `REVIEW_SOURCE_SHOP` "Mağaza".
  Karar defterinin "son kullanıcıdan ve mağazadan birer ikişer" kuralının mağaza yarısı budur.
- **Olay belirtileri ve alıntıları** (B §6.1, Olay 5 ve 6): beş pazaryeri hattına birer `{belirti}` ve fırtına
  `{alıntı}`'sı.
- **Sprint ortası kâğıtlarının pazaryeri varyantları** (B §6.2 son not), Erdem'in beğendiği testçi kâğıdı dahil:
  "indirim kodu ve taksit birlikte seçilince toplam yanlış çıkıyor". Miktarlar D'nin ×5 ölçeğinde yazılır.
- **Reddedilen ikiz geri gelmez:** Satıcı Paneli K2 (Hakediş) için yazılan hiçbir belirti, alıntı ya da kâğıt
  "satıcılar günlerdir ödemelerini alamıyor" kalıbına dönmez (karar defteri, reddedilenler listesi). Hakediş
  belirtisi faturanın ya da dökümün yanlış görünmesi gibi ekran düzeyinde kalır.

---

## 7. Uygulama dilimleri
Her commit: `--event-lint` → `loc_residue` → `loc_csv_integrity` → dokunulan vakalar → ölçüm kapısı → (görünen
değişiklikte) görsel kabul → Opus incelemesi → commit. TR metni taşıyan mesaj "TR/EN onay bekliyor", sabit taşıyan
"onay bekliyor" der. Dosyalar her commit'ten önce taze okunur (A–D aynı dosyalara dokunmuş olacak).

**Ölçüm protokolü (B2C bot kapısı, her dilimin sonunda):** repo dışı betik (scratchpad), Haiku koşar.
- `full_run_b2c` tohum 1–8, 110 hafta; E3'ten sonra `full_run_b2c_fee_high` ve `full_run_b2c_fee_low` tohum 1–4;
  `run_gate.sh` 3/3. Her koşu ayrı süreç ve ayrı APPDATA, en çok iki paralel, `CASE_TIMEOUT=300`.
- Tablo: son, iflas, Frank çeki / seed / Seri A haftası (en küçük, ortanca, en büyük), 52. ve 90. haftada alıcı, üye
  oranı, mağaza, alıcı/mağaza, mağaza memnuniyeti, komisyon payı, aylık gelir.
- **Taban (adım 0):** A–D commit'lendikten sonraki main'de aynı tablo.

### Parça 1 · Ekonomi çekirdeği ve kayıt
Ağacın iskeleti ekonomiden önce gelmek zorunda: komisyon kilidi Sepet ve Ödeme hattına, mağaza memnuniyeti satıcı
hatlarına bağlı. Oyuncu metni doğarken anahtarıyla doğduğu için hat ve alan adları da iskeletle gelir; "içerik" son
parçada kalan bağlar ve metin düzeltmeleridir.

**E1 · Pazaryeri türü ve iki taraflı ağaç (eski abonelik ekonomisiyle)** · L; yeni durum yok; yeni ekran yok
- Ne: `marketplace.json` (5 hat, `side`), alt tür kaydı; `TYPE_SCREEN.b2c.playable` = `marketplace`, `note_tool`,
  `video_clip` (E2'de ikisi çıkar; `line_subtypes_match_type_screen` için bu commit'te üçü birlikte); `sprint.json`
  alanları (`buyer`, `seller`, `core` yalnız B2B), `mvp_min_per_side`; doğrulayıcının taraf kuralı; "tek kimlik alanı"
  varsayan beş yer; rakip bloğu, adlar, sektör yuvası; §6.1–§6.3 anahtarları; fikstür taşıma: `run_probe.gd` B2C
  preset'leri, `_seed_b2c_world`, `main.gd` 7 tohum yeri (`live:b2c_mvp`, `live:b2c_live`, `--sales-shot=b2c_live`
  dahil; debug ürün adı "Tezgah"), `sprint_probe.gd` 2 yer, smoke'taki not aracı fikstürleri (~25 vaka). Bot MVP'ye
  Sepet ve Ödeme K1'i koyar (harness).
- Dosyalar: `data/product/lines/marketplace.json` (yeni), `data/product/sprint.json`, `data/product/rivals.json`,
  `data/market/companies.json`, `scripts/systems/{product_catalog,product_lines,sprint_catalog,sprint_system,sprint_bridges,rival_catalog}.gd`,
  `scripts/tabs/product/product_model.gd`, `scripts/debug/{run_probe,sprint_probe,endgame_smoke}.gd`, `scripts/main/main.gd`,
  `localization/strings.csv`.
- Kapılar: `product_lines_catalog_loads`, `line_ladder_rules`, `line_k3_locked_without_research`,
  `line_subtypes_match_type_screen`, `market_catalog_lint`, `sprint_*` fikstür vakaları, `card_math_matches_gdd_example`;
  yeni vaka `mkt_mvp_needs_both_sides` (falsifikasyon: taraf şartını kaldır → FAIL); `--sprint-probe=hours=40:cards=2:ticks=8`
  PRED=CLOSE; ölçüm: Frank çeki ortancası tabanın ±4 haftası, seed ±6, Seri A ±8, iflas ≤ taban.
- Görsel kabul: `--product-shot=live:pick` (tür seçici), `live:plan` (Alıcı ve Satıcı alanları), `live:b2c_mvp` (MVP
  satırı ve ipucu), TR/EN, 1920 ve `--shot-scale=1.25`.
- Risk: beş "core" okuması gözden kaçarsa MVP tahmini ve sprint probe kırılır; `rg '"core"'` listesi incelemeye girer.

**E2 · Not ve video silinir; kayıt şeması kırılır** · M; yeni durum yok
- Ne: §5.8 silinenler; `SCHEMA_VERSION` +1, `MIN_LOADABLE_VERSION := SCHEMA_VERSION`; erişilemeyen göçler ve onların
  vakaları (onaylı liste); `engine_probe.gd`'nin şema iğnesi; Ar-Ge metinleri (§6.4); `ISLER.md`'de not ve video rakip
  adları maddesi kapanır; `GDDs/GUNCELLEMELER.md` girdisi (ch03 §12.11 demo alt tipleri: Pazaryeri · ERP; Ar-Ge §4.1
  ai_engine artık Pazaryeri'nin Katalog Eşleme kademesini açar).
  (inceleme) GUNCELLEMELER girdisi eksikti, şunlar da girer: ch01 §2 "Product subtypes: 2 B2B + 2 B2C" (artık 1 B2C);
  ch03 §12.9 işlenmiş örneği ve §12.10 çapası yeni hatta; Ar-Ge GDD'sinde `semantic_index` ve `ai_engine`'in açtığı
  not aracı K3'leri. `card_math_matches_gdd_example` ve §12.10 çapa vakası pazaryeri hattına taşınır (§5.8).
  Kapı: `rg "note_tool|video_clip|NOTE_TOOL|VIDEO_CLIP"` `scripts/`, `data/`, `localization/` altında 0 satır; 0b'nin
  çıkardığı vaka listesi (not ve video adını anan her `_case_*`) adıyla koşulur.
- Dosyalar: `data/product/lines/{note_tool,video_clip}.json` (silinir), `rivals.json`, `companies.json`,
  `scripts/systems/{product_catalog,rival_catalog,sales_archetypes}.gd`, `scripts/autoload/save_manager.gd`,
  `scripts/debug/{endgame_smoke,engine_probe,run_probe}.gd`, `localization/strings.csv`, `docs/ACIK_ISLER/ISLER.md`,
  `GDDs/GUNCELLEMELER.md`.
- Kapılar: `loc_csv_integrity`, kayıt vakaları (`save_backup_fallback`, gidiş dönüş), `--menu-shot=continue` ve `load`
  (eski yuva açılabilir görünmez; ayrı APPDATA); ölçüm: `full_run_b2c` E1 ile `^PROBE` bayt-eş beklenir; ERP
  `full_run` tohum 1–4, 40 hafta bayt-eş ya da fark yalnız rakip tohumundan (raporlanır).
- Risk: rakip kayıt defteri bütün türleri tohumluyorsa ERP koşusu bayt-eş olmaz; fark nedeniyle raporlanır, kapı
  "son ve hata satırı" olur.

**E3 · Pazaryeri ekonomisi** · L; yeni durum (5 bayrak, ay kayıt alanları); yeni ekran yok
- Ne: `MarketplaceSystem` (§5.1–§5.7); `SalesSystem`'in B2C kolu (saatlik `derive_mrr`, haftalık `weekly_tick`, seçenek
  çarpanı, haftalık örneğe `stores`); eski fiyat makinesinin silinmesi; `SprintBridges.open_paid_plan` →
  `open_membership`; Üyelik kartının Sepet ve Ödeme kilidi (`gate_reason`); `_go_public(1)` → `open_market()`;
  `SummarySystem` ay açılışı ve kapanışı; `FLAG_TYPES`; `cheque_read` B2C adımı "İlk gelir"; seam'ler (§5.10) ve
  `--event-vocab`; `run_probe`: `PROBE MKT` satırı (`PROBE B2C`'nin yerine: alıcı, üye, oran, mağaza, katılan, ayrılan,
  memnuniyet, komisyon, ücret, sipariş, sepet, hacim, iki gelir, aylık gelir, sel, q; destek alanları korunur),
  preset'ler `full_run_b2c_fee_high` (30. haftada %10 → %16) ve `full_run_b2c_fee_low` (açılıştan %6); fikstürler
  (`open_b2c_paid_tier` → `open_membership`); CLAUDE.md §6 "Gelir" cümlesi ve HARITA Satış/Ürün girdileri; §6.4'ün E3
  satırları; ACIK_KARARLAR'a yeni madde (ACIK 97'nin B2C kümesi yeniden açıldı; §5.12 sabitleri onay bekliyor).
  (inceleme) Ayrıca: koşu defterine `members` ve `stores`, son kâğıdının B2C nüfus satırı (§5.10); GUNCELLEMELER
  girdileri: ch01 "Bootstrap → Traction: B2C paid tier live with paying users" → "pazaryerinde ilk gelir"; ch03 §3 ve
  §10 "fiyatın tek evi" (B2C'de v1 fiyat adımı yerine açılış komisyonu ve Pazaryeri kolları); ch03 monitör alanları
  ("canlı ödeyen" → üye); ch13 B2C nüfusu; Ar-Ge GDD "ücretsiz→ücretli dönüşüm ×1,15" → üye oranı ×1,15.
  `PROBE MKT` satırı A'nın `PROBE B2C`'ye koyduğu `open_bugs=` alanını korur.
- Önce: taban koşusundan `SEL_GROWTH_K` ölçülür (bugünkü fiyat çarpanının 10–90. hafta ortalaması), rapora yazılır.
- Dosyalar: `scripts/systems/marketplace_system.gd` (yeni), `scripts/systems/{sales_system,sprint_bridges,sprint_catalog,sprint_system,summary_system,cheque_read,product_catalog}.gd`,
  `scripts/autoload/game_state.gd`, `scripts/events/seams/seams_sales.gd`, `docs/content/events_draft/_vocabulary.md`
  (üretilir), `scripts/debug/{run_probe,endgame_smoke}.gd`, `scripts/main/main.gd`, `localization/strings.csv`,
  `CLAUDE.md`, `docs/HARITA.md`, `docs/ACIK_ISLER/ACIK_KARARLAR.md`.
- Yeni vakalar (hepsi falsifikasyonlu): `mkt_mrr_is_commission_plus_membership` (üyelik toplamdan çıkarılırsa FAIL),
  `mkt_commission_needs_checkout` (kilit kaldırılırsa FAIL), `mkt_raise_shocks_cut_does_not` (indirim de sarsarsa ya da
  artış sarsmazsa FAIL), `mkt_estimates_are_pure` (önizleme bir bayrağı değiştirirse FAIL),
  `mkt_month_close_and_save_roundtrip`. Güncellenen ya da emekli (onay): `b2c_value_reads_live_lines` (değer algoritması
  silindi, emekli), `sprint_paid_plan_opens_paid_tier` (üyelik $7 ile açılır, ödeme kilidi), `sprint_lead_offers_paid_plan_b2c`,
  `cheque_read_steps`, `gate1_b2c`, `conversion_bug_penalty` (A sildiyse yok).
- Ölçüm kapısı: tabana göre Frank çeki ortancası ±4 hafta, seed ±6, Seri A ±8, iflas ≤ taban; 52. haftada komisyon payı
  %75–92, üye oranı %4–11, alıcı/mağaza 45–90, mağaza memnuniyeti 40–70; `fee_high`: 52. haftada mağaza varsayılanın
  ≤ %85'i ve memnuniyet daha düşük, (inceleme) komisyon geliri 52. haftada varsayılandan en az %10 yüksek (esneklik
  kapısı: tutmazsa `FEE_ELAST` hatası); `fee_low`: mağaza ≥ varsayılan, komisyon geliri < varsayılan.
  (inceleme) Yeni preset `full_run_b2c_listing` (MVP'de Sepet ve Ödeme yok, ilk v1 sonrası sprintte gelir) tohum 1–4:
  Frank çeki ortancası varsayılandan en çok 6 hafta geç, iflas ≤ taban. Bot hep Sepet ve Ödeme'yi MVP'ye koyduğu için
  ilan dönemi yolu başka hiçbir koşuda ölçülmüyordu. Pencere dışı çıkan
  sabit commit'lenmez, "onay bekliyor" diye rapora yazılır (±%50 ayar penceresi içinde bir tur ayar serbest).
- Risk: tempo kayması (en büyük risk, §7 sonu).

### Parça 2 · Sayfa ve kollar
**E4 · Sol menü ve Pazaryeri sayfası** · M; yeni ekran (sayfa); yeni durum yok
- Ne: `LeftTabs._paint` B2C türünde `TAB_MARKETPLACE` ve `rail/marketplace.svg` (dükkân tentesi, öbür ray ikonlarının
  çizgi dilinde); tür seçilince ve kayıt yüklenince ray yeniden boyanır; Satış penceresinin başlığı ve boş hâli pazara
  göre; yeni `scripts/tabs/sales/marketplace_view.gd` (§2.4, §2.5, §2.8; koyu dil, yalnız `D_*`); `sales_tab.gd`'nin
  B2C kolu ve anahtarları silinir; ürün başlığı etiketleri (C varsayımı); `--sales-shot=mkt_pre|mkt_listing|mkt_live`
  (`b2c` ve `b2c_live` türlerinin yerine); CLAUDE.md §12 ve HARITA'da çekim türleri.
- Dosyalar: `scripts/ui/components/left_tabs.gd`, `assets/icons/rail/marketplace.svg` (yeni), `scripts/tabs/sales_tab.gd`,
  `scripts/tabs/sales/marketplace_view.gd` (yeni), `scripts/ui/components/window_layer.gd` (yalnız gerekirse: açık Satış
  penceresi tür seçilince yeniden kurulur), `scripts/main/main.gd`, `localization/strings.csv`, `CLAUDE.md`, `docs/HARITA.md`.
- Kapılar: `rail_tabs_match_scene_order` (sahne anahtarı değişmediği için yeşil kalmalı); (inceleme) yeni vaka
  `rail_label_follows_market` (B2C türünde satırın adı `TAB_MARKETPLACE` ve ikonu `marketplace.svg`, B2B ve tür
  seçilmeden `TAB_SALES`; falsifikasyon: `_paint`'teki pazar kolunu kaldır → FAIL; sıra kilidi adı denetlemediği
  için bu değişikliği hiçbir vaka tutmuyordu), `--theme-contrast-audit`,
  `glyph_audit.gd`; ölçüm: `full_run_b2c` tohum 1–4 ve `full_run` tohum 1, E3 ile `^PROBE` bayt-eş (yalnız arayüz).
- Görsel kabul: `--sales-shot=mkt_pre`, `mkt_listing`, `mkt_live` ve `--tab-shot=sales` (ray etiketli ve dar), TR/EN,
  1920 ve `--shot-scale=1.25`. Kontrol: satır başına tek sayı, taşma yok, "Geçen ay" ilk ay boş çizgi, ipuçları açılıyor.
- Risk: pencere sabit yükseklikte sığmazsa (`fit_height`) sayfa kayar; Gelir tablosu altı satırla sınırlı.

**E5 · Kollar: komisyon ve üyelik önizlemesi** · M; yeni durum yok
- Ne: iki satırda [−] değer [+], önizleme bloğu (§2.6, §2.7, §2.4'ün açılış komisyonu, §2.8'in gelir satırı), "Vazgeç"
  ve "Uygula"; karar açıkken kapalı (`EventGate.active_id() != ""`); `work_hours_modal.gd`'deki `_stepper`
  `UiFactory.D_stepper` olarak paylaşılan eve taşınır (iki kullanıcı oldu); `--sales-shot=mkt_preview_fee|mkt_preview_member|mkt_gate`.
- Dosyalar: `scripts/tabs/sales/marketplace_view.gd`, `scripts/theme/ui_factory.gd`, `scripts/modals/work_hours_modal.gd`,
  `scripts/main/main.gd`, `localization/strings.csv`.
- Kapılar: `mkt_estimates_are_pure` (E3) yeşil; önizlemenin "Uygula" sonrası ilk tikteki sayıyla tutarlılığı çekimde
  (önizlemedeki "şimdi" = uygula anındaki aylık gelir farkı; (inceleme) "3 ay sonra" ve mağaza satırı, alıcı sabit
  tutulmuş fikstürde 13 haftalık gerçek akışla ±%10 içinde); ölçüm: E4 ile `^PROBE` bayt-eş.
- Görsel kabul: üç çekim, TR/EN, 1920 ve 1,25; `work_hours` modalının çekimi (stepper taşındı, görünüm aynı).
- Risk: önizlemenin "3 ayda" satırı alıcıyı sabit tutar; Opus incelemesi metnin "yaklaşık" dediğini ve sayının
  gerçek akışla aynı yönde olduğunu kontrol eder.

### Parça 3 · Bağlar ve içerik
**E6 · Öteki fazlara bağlar, olay okumaları, belgeler** · M; yeni durum yok
- Ne: A'nın düzeltme kartında satıcı hattı birimi (`affected`, `PRODUCT_FIX_STORES`); B'nin "Ödeme alınamıyor" ve
  kupon hesabının `orders_in_hours` ve `aov` okuması, olayın Sepet ve Ödeme koşulu; C'nin İş özeti B2C kolu, haftalık
  rapordaki satıcı isteklerinin mağaza birimi; Frank `paid_tier` kartının koşulu (§6.7, onaydan sonra); B2C kartlarının
  metin taraması; `PROD_PATH_B2C_DESC`; sözlük; HARITA'nın kalan girdileri.
  (inceleme) Ayrıca: B'nin iade ve özür formülünün üye okuması (§5.10); C'nin `OV_BIZ_B2C` metni ("dönüşüm" yerine
  alıcı ve mağaza); §6.8'deki B'den kalan metinler (yazımı adım 6w'de Opus yapar, bu adım yalnız bağlar).
- Dosyalar: A/B/C'nin ilgili dosyaları (tazelemede adlanır), `data/events/cards/product/paid_tier.json`,
  `localization/strings.csv`, `docs/design/localization_glossary.md`, `docs/HARITA.md`.
- Kapılar: `--event-lint`, `event_chip_coverage`, `bash tools/plausibility_run.sh` fails=0, `--why-fire=product.paid_tier`,
  (inceleme) `loc_residue` ve `--event-shot` ile en az bir pazaryeri sprint ortası kâğıdı ve bir "Mağaza" kaynaklı yorum;
  ölçüm: `full_run_b2c` tohum 1–8 E5 tablosuyla aynı pencere (olay okuması değiştiği için bayt-eş beklenmez).
- Görsel kabul: `--event-shot` ile "Ödeme alınamıyor" (pazaryeri sayılarıyla), düzeltme kartı (`--product-shot=live:b2c_live`,
  satıcı hattında hata), C'nin Genel Bakış'ı (`--product-shot` C'nin türü), TR/EN.
- Risk: A, B, C'nin gerçek arayüzleri bu plandaki varsayımlardan farklıysa E6 büyür; tazeleme adımında yeniden boyutlanır.

### En büyük riskler
1. **Tempo kayması.** Abonelik ekonomisinden komisyon ekonomisine geçiş Frank çekini, seed'i ve Seri A'yı kaydırabilir;
   ACIK 97'nin B2C kümesi yeniden açılır. Önlem: alıcı başına gelirin bugünkü düzeye kurulması, `SEL_GROWTH_K`'nın
   ölçülerek konması, her dilimde pencere kapısı.
2. **Geniş dokunuş.** Fikstür taşıma ve silme (~30 smoke vakası, 64 başvuru, `main.gd` çekimleri, probe preset'leri,
   rakipler, Piyasa yuvaları, Ar-Ge metinleri, şema kırılması) A–D'nin de dokunduğu dosyalarda. Önlem: E1 ve E2 ayrı,
   her commit'ten önce taze okuma, kapı listesi vakaları adıyla sayar.
3. **Fazlar arası varsayımlar.** A'nın hat başına açık hata okuması, B'nin etkilenen sayı formülü, C'nin İş özeti ve
   istek verisi bu planın tahmini. Önlem: uygulama öncesi tazeleme (adım 0b); E6 son dilimde.

---

## 8. Açık sorular
(inceleme) Sorular B incelemesinin 7. sorusuyla birleştirildi ve %65 kuralı eklendi; en çok 6.
1. **Not ve video uygulaması silinsin mi?** GDD ch03 §12.11 onları demo alt tipi olarak mühürlü sayıyor; 11 Ekim'de
   "silinir" demiştin (PRD_URUN_DERINLIK S1). Öneri: **evet**, sil. Bedeli: GUNCELLEMELER'e beş GDD girdisi (ch01 alt
   tip sayısı, ch03 §12.11, §12.9 örneği, §12.10 çapası, Ar-Ge K3'leri); ~30 smoke vakası taşınır; 112 metin anahtarı
   gider; B2C'de tek oynanabilir tür kalır. EA'da tutmak iki B2C ekonomisini birlikte yaşatmayı ister. Bağlı karar (B
   incelemesi soru 7): evet ise B not ve video uygulamasına özel ~40 metni yazmaz, pazaryerinin yorum, belirti ve
   kâğıtları E'de yazılır (§6.8).
2. **Eski kayıtlar açılmasın mı?** Öneri: **evet**; şema kırılır, bugünkü test kayıtların (ERP dahil) "çok eski" diye
   görünür. Seçerek düşürmek (yalnız not ve video kayıtlarını reddetmek) ölü göç zincirini yaşatır; sürüm henüz
   yayımlanmadı. (inceleme) Bedeli: A'nın (şema 16) ve D'nin (×5 ölçek) aynı turda yazdığı göçler ve onları sınayan
   vakalar E2'de emekli olur; o göçlerin işi bir hafta içinde boşa gider.
3. **İlan dönemi kalsın mı?** Komisyon Sepet ve Ödeme yayınlanınca başlar; v1.0'da bu hat zorunlu değil, ama her
   taraftan en az bir hat zorunlu. Öneri: **evet**; MVP sırası oyuncunun kararı kalır, "önce kitle sonra para" gerçek
   bir yol. Hayırsa v1.0 Sepet ve Ödeme K1'i zorunlu kılar.
4. **Komisyon artışında anında mağaza kaybı olmasın mı?** Tur 2'de "bir kerelik −8 mağaza" vardı. Öneri: **evet, anında
   kayıp yok**; anlık memnuniyet sarsıntısı, giriş düşüşü ve memnuniyet 40'ın altına inince hızlanan ayrılma; önizleme
   "3 ayda yaklaşık 14 mağaza eksik" der. Gerekçe Etsy 2022: grev oldu, satıcı sayısı düşmedi.
5. **(inceleme, yeni) "Tek gelir türü toplamın %65'ini geçmez" kuralı demoda kalksın mı?** Demoda iki akım var ve
   komisyon 52. haftada gelirin ~%87'si; üyelik model gereği ~%25'i geçemez. Öneri: **evet, demoda kalkar, EA'da dört
   akımla geri gelir**; gerçek pazaryerlerinde de üyelik geliri ikincil. Bedeli: "oyuncu gelir türüne odak seçer"
   hissi demoda zayıf kalır; seçim komisyon ile üyelik arasındaki takasa iner. Hayırsa üyeliği komisyon kadar büyütmek
   gerekir (ücret ve üye oranı gerçek dışı yükselir).
6. **Kara Cuma ve sezon tepeleri Erken Erişim'e mi?** Öneri: **evet**; demoda sezon yok. Mevsimli gelir aylık gelire
   girerse fon kapıları tek haftada açılır, ayrı bir "mevsimsiz gelir" kuralı ve gelir defteri satırı gerekir.

---

## 9. Uygulama adım tablosu
| Adım | Ne | Kim | Model | Düşünme | Süre | Neden |
|---|---|---|---|---|---|---|
| 0 | Taban ölçümü: A–D commit'li main'de ölçüm protokolü (B2C 8 tohum + `run_gate`), `SEL_GROWTH_K` için fiyat çarpanı ortalaması | Alt ajan | Haiku | düşük | 30 dk | Koşu ve tablo işi; karar yok |
| 0b | Planı güncel koda karşı tazele: A–D'nin dosya ve arayüz değişiklikleri, "A/B/C varsayımı" satırları, şema numarası; (inceleme) not ve video adını anan smoke vakalarının ad listesi (E1/E2 kapı listesi), D'nin hat ve kart biçimi, B'nin gerçek seam ve fiil adları | Alt ajan | Sonnet | yüksek | 25 dk | Fark kontrolü; bozulan varsayım Opus'a döner |
| 1 | E1 kodu (veri, katalog, alanlar, MVP, rakipler, anahtarlar, fikstürler) | Alt ajan | Sonnet | xhigh | 2,5 sa | Geniş ama mekanik olmayan dokunuş; beş "core" okuması dikkat ister |
| 1g | E1 kapıları, sprint probe, ölçüm, üç ürün çekimi | Alt ajan | Haiku | düşük | 40 dk | Koşturma |
| 1r | E1 kıdemli inceleme (diff + kapı çıktısı + çekimler) | Alt ajan | Opus | yüksek | 20 dk | Commit öncesi kural |
| 2 | E2 kodu (silme, şema, göçler, Ar-Ge metinleri, GUNCELLEMELER) | Alt ajan | Sonnet | xhigh | 1,5 sa | Silmenin kenarları (vakalar, iğneler) |
| 2g | E2 kapıları, menü çekimleri, bayt-eş karşılaştırma | Alt ajan | Haiku | düşük | 30 dk | Koşturma |
| 2r | E2 inceleme | Alt ajan | Opus | yüksek | 15 dk | Commit öncesi kural |
| 3 | E3 kodu (MarketplaceSystem, SalesSystem B2C kolu, ay defteri, seam'ler, bot, vakalar, belgeler) | Alt ajan | Sonnet | max | 4 sa | Fazın çekirdeği; ekonomi ve kayıt |
| 3g | E3 ölçüm protokolü (8 tohum + iki komisyon preset'i + `run_gate`), yeni vakalar | Alt ajan | Haiku | düşük | 1 sa | Uzun koşular |
| 3r | E3 inceleme ve ölçüm tablosunun değerlendirmesi; pencere dışıysa tek ayar turu ya da "onay bekliyor" | Alt ajan | Opus | yüksek | 30 dk | Kalibrasyon yargısı |
| 4 | E4 kodu (ray, ikon, sayfa, çekim türleri, belgeler) | Alt ajan | Sonnet | xhigh | 3 sa | Yeni ekran, koyu dil |
| 4g | E4 çekimleri (TR/EN, 1920 ve 1,25), tema ve glif denetimi, bayt-eş | Alt ajan | Haiku | düşük | 40 dk | Ekranlı koşular sırayla |
| 4r | E4 inceleme (çekimlerle görsel kabul) | Alt ajan | Opus | yüksek | 25 dk | Sakin ekran ölçütü |
| 5 | E5 kodu (iki kol, önizleme, Uygula, `D_stepper` taşıma) | Alt ajan | Sonnet | xhigh | 2,5 sa | Durumlu arayüz |
| 5g | E5 çekimleri ve bayt-eş | Alt ajan | Haiku | düşük | 30 dk | Koşturma |
| 5r | E5 inceleme | Alt ajan | Opus | yüksek | 20 dk | Commit öncesi kural |
| 6w | (inceleme) §6.8 metinleri: 20 yorum, 5 belirti, 5 alıntı, pazaryeri sprint ortası kâğıtları; EN önce, TR yeniden yazım | Alt ajan | Opus | yüksek | 45 dk | Erdem'in en sert eleştirisi yazım; B'nin yazım adımı (2w) da Opus'ta. 6'dan önce ya da paralel; metin dosyası, kod yok |
| 6 | E6 kodu ve içerik (A/B/C bağları, Frank kartı koşulu, kart taraması, 6w metinlerinin bağlanması, sözlük, HARITA) | Alt ajan | Sonnet | xhigh | 2,5 sa | Fazlar arası bağlar |
| 6g | E6 lint, plausibility, olay ve ürün çekimleri, ölçüm | Alt ajan | Haiku | düşük | 40 dk | Koşturma |
| 6r | E6 inceleme | Alt ajan | Opus | yüksek | 20 dk | Commit öncesi kural |
| 7 | Erdem'e rapor: madde başına ✅/⚠️/❌, ölçüm tabloları (taban, E1, E3, E6), çekimler, onay bekleyen sabitler ve metinler, açılan ACIK maddesi | Ana | Opus (ana) | orta | 15 dk | Sentez |

- Push yalnız Erdem "push et" deyince; tam smoke Erdem isterse.
- (inceleme) Her "r" adımı: Opus kıdemli inceleme düzeltme hakkıyla yapar (doğrudan düzeltir, yeniden kapı koşturur);
  onay verirse commit'i ana oturum atar. Commit başına en çok bir inceleme ve bir düzeltme turu; E3r'nin ayar turu bu
  tek düzeltmedir, ikinci tur yerine sabit "onay bekliyor" diye rapora yazılır.
- Toplam: Sonnet ~16 sa, Haiku ~4,5 sa, Opus ~3,3 sa; sıralı yürür, ekranlı koşular paralel değil.
