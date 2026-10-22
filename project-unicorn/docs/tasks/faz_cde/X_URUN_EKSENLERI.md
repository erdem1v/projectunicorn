# X: Ürün eksenleri (Kararlılık, Deneyim, İnovasyon) ne olacak

Tarih: 17 Ekim 2026. Durum: öneri, Erdem'in onayını bekliyor. Kod değişmedi; bu belge yalnız okuma, ölçüm kayıtları ve
araştırma raporlarından (R1, R3, R8) yazıldı. C ve D tasarımcıları bu belgeyi sonra okuyacak; §8 onlar için yazıldı.

## 0. Özet

1. Oyunda bugün iki ayrı kalite modeli var. Biri görünür (sprint ekranındaki ALANLAR: Çekirdek, Onboarding, Entegrasyonlar, Güven ve Ölçek, Gelir; her biri "Yok, Zayıf, Yeterli, Güçlü" ve bir cümle), biri görünmez (üç EKSEN).
2. Ekonomiyi görünmez olan taşıyor: B2B memnuniyet hedefi, B2C kitle büyümesi, B2C memnuniyeti, fiyat önerisi, satış görüşmesi, VC soruları ve dört olay kartı eksenden okuyor. Görünür alanlar hiçbir ekonomik sayıyı değiştirmiyor.
3. Oyuncu ekseni hiçbir ekranda göremiyor; yalnız VC "{eksen} tarafın zayıf" ve kayıp müşteri "Kararlılık bizim için hâlâ açık bir soru" diyor. Oyuncu bu adları bulabileceği bir yer yok.
4. Ölçülmüş tuzak (A'nın K5 bot koşuları): ERP v1.0 Kararlılık 0 ile çıkıyor, B2C kullanıcı memnuniyeti 25 hafta boyunca 14'te çakılı kalıyor. Oyuncu nedenini göremiyor.
5. Eksen bugün üç farklı ölçekte okunuyor (ham 0-43, normalize 0-100, pazar çıtasına göre 0-120); VC ve yatırım masası ham değeri 0-100 eşiğiyle karşılaştırıyor.
6. Sprint öncesi Ürün ekranı üçgen grafik, üç eksen çubuğu, "zayıf yanın X" ipucu ve hat başına eksen kazancı gösteriyordu; sprint geçişinde hepsi silindi, ekonomi eksende kaldı.
7. Üç seçenek inceledim: (a) eksenleri kaldırmak, (b) eksenleri göstermek, (c) görünür alanları ürünün tek kalitesi yapmak.
8. Öneri (c): alan seviyesi ile pazarın beklentisi arasındaki oran ekonominin tek kalite girdisi olur, her müşteri tipi kendi önemsediği alana bakar. Görünen ile hesaplanan aynı şey olur; sabit "kişi başı" sayı yoktur.
9. Kapsam önerisi: C'den önce ekransız ayrı bir faz (motor, veri, kalibrasyon; kaba 36-49 saat; (inceleme) "küçük"
   değil: D'nin 30-35 saatinden büyük). Görünür kısımlar C'nin Genel Bakış'ına ve D'nin kartına zaten düşüyor.
10. C ve D için iki seçenekte de çalışan bir arayüz tarif ettim (§8): C "ürün durumu satırları" ve "ürün uyumu terimi" okur, D kartın aşama payını hattın "iş profili"nden okur, hiçbiri ekseni doğrudan okumaz.

---

## 1. Erdem ne dedi (birebir, `ERDEM_CD_YORUM.md`)

- "Biz sprint döngüsüne geçerken ... sprint düzeninde ürün kararlılığını vesaireyi oyuncu hiçbir yerde görmüyor. Herhangi
  bir değerlendirme vesaire görmüyor. ... üründe bakıp ürünün nerede eksik olduğunu ... burada şu anda oyuncunun
  görebildiği kararlılık diye bir şey yok."
- "Deneyim kartı, inovasyon kartı, kararlılık kartı diyoruz da bunlar oyunda oyuncuya hiçbir yerde görünmüyor. Şu anda
  neyi temsil ettiğini ben bile bilmiyorum."
- Kalıcı kural: "Sabitlerle mi ilerlenmeli, dinamik mi ... Geriye dönüp bunları fixlemekle uğraşmamalıyız."
- C için: memnuniyet ipucundaki terimler "okey olabilir", "Sadece şundan emin değilim. Ürün kararlılığı kısmı".
- C için: "bu müşterilerin memnuniyet başlangıcını yukarıdan başlatmamız lazım ... %70'ler".

---

## 2. Bugün kodda eksenler

### 2.1 Nasıl hesaplanıyor

Zincir tek yönlü ve kısa:

1. Her hat veride tek bir eksene aittir (`data/product/lines/*.json`, alan `axis`). Kademe başına eksen puanı K1 4,
   K2 9, K3 12 (`axis_points`); iki K3 kademenin ikincil puanı var (ERP Kayıt K3 Deneyim +3, Stok K3 Kararlılık +3).
2. Alt tür başına kimlik hatları 2 İnovasyon, 1 Kararlılık, 2 Deneyim; paylaşılan dört hatla her eksende üç hat olur
   (`product_lines.gd:49` `IDENTITY_AXIS_SHAPE`, doğrulama `product_lines.gd:124-133`).
3. Eksenin ham değeri = Σ (canlı kademenin puanı × kademe katsayısı K1 1,0 · K2 0,8 · K3 1,2 × gerçekleşme damgası)
   (`quality_model.gd:178-206`, katsayılar `product_lines.gd:22`). Kendi hattı hiç açılmamış eksenin ikincil puanı
   ×0,6 (`quality_model.gd:204-205`).
4. Her sürümde `SprintBridges.push_axes` (`sprint_bridges.gd:115-118`) bu ham değerleri `mvp_innovation`,
   `mvp_stability`, `mvp_experience` bayraklarına yazar. Ekonominin çoğu bu bayrakları okur
   (`quality_model.gd:94-110`).

Ölçü karışıklığı. Aynı kavram üç ölçekte okunuyor:

| Ölçek | Nerede | Aralık |
|---|---|---|
| Ham | `dims_from_flags` (`quality_model.gd:94`) | 0 ile yaklaşık 43 (eksen başına üç hat K3'te) |
| Normalize | `axis_score` / `shipped_normalized` (`quality_model.gd:85`, `:103`), yarı doygunluk 25 (`:29`) | 0-100; ham 12 → 32, ham 43 → 63 |
| Okuma | `axis_reading` (`quality_model.gd:209`), çıta faz 1/2/3'te 12 / 13,2 / 14,5 (`:130`) | 0-120; 100 "pazar çıtası" |

Ölü parçalar (bugün hiçbir şey yazmıyor ya da çağırmıyor):
- Gerçekleşme damgası (`product_state.gd:94` `stamp_step`): canlı yazarı yok, yalnız ekran çekimi düzeneği yazıyor
  (`main.gd:3316`). Yani ekibin becerisi ürün kalitesine bugün hiç girmiyor; kalite yalnız "hangi kademe yayında".
- Kapı üstü bonusu (`line_gates.gd:132` `above_gate_bonus`): çağıran yok.
- Önde / hizada / geride kelimesi (`product_read.gd:18-33`): tasarım gereği hiçbir ekranda basılmıyor.
- Rakip sıralaması (`rival_registry.gd:75`): eski Ürün ekranından beri çağıran yok.

### 2.2 Kim okuyor

| # | Okuyan | Dosya:satır | Ölçek | Oyuncu görüyor mu |
|---|---|---|---|---|
| 1 | B2B hesabın memnuniyet hedefi (sağlık terimi) | `b2b_sales_system.gd:135` | normalize Kararlılık | Yalnız sonucu: "Ayrılabilir" |
| 2 | B2B imza anı memnuniyeti | `sales_system.gd:414-418` | normalize (Kararlılık + Deneyim) / 2 | Hayır |
| 3 | Açık hatanın etkilediği B2B hesaplar | `b2b_sales_system.gd:151-155`, `sprint_catalog.gd:386-389`, `sales_archetypes.gd:141` (eşik 0,25) | eksen üyeliği | "3 hesap" sayısı görünür, neden o hesaplar olduğu görünmez |
| 4 | B2C kitle büyümesi ve aşınma | `sales_system.gd:177`, `:202`, rakip köprüsü `:211-224` | normalize bileşik, rakip ortalamasına göre | Hayır |
| 5 | B2C memnuniyet tohumu ve hedefi | `sales_system.gd:244`, `:426` | normalize Deneyim | Memnuniyet sayısı görünür, nedeni görünmez |
| 6 | Ürün değeri (önerilen fiyat) | `sales_system.gd:441` | normalize bileşik | Fiyat önerisi görünür, nedeni görünmez |
| 7 | B2B aday yıldız karışımı | `sales_faucet_system.gd:166-174` | okuma / taban | Hayır |
| 8 | Satış görüşmesinde ikna (ürün uyumu) | `sales_meeting_system.gd:136-142` | okuma / taban × müşteri tipinin eksen ağırlığı (`sales_archetypes.gd:57`, `:81`, `:105`) | Zar ipucunda "ürün uyumu" satırı; eksen adı yok |
| 9 | Görüşme kaybı nedeni ve kapı kilidi | `sales_meeting_system.gd:338` (< 40), `sales_ledger.gd:338` (≥ 55) | okuma Kararlılık | Metin görünür: "Kararlılık bizim için hâlâ açık bir soru." Sayı hiçbir yerde yok |
| 10 | VC soru kartı | `vc_pitch_system.gd:1329-1338`, metin `:1233` | ham, eşik 40 | Metin görünür: "{eksen} tarafın zayıf. Sektörü bilen biri bunu ilk bakışta görür." |
| 11 | Yatırım masası ürün uyumu | `term_sheet_table_system.gd:548` | ham en zayıf, eşik 40 | Hayır |
| 12 | Taban merdiveni (uyarı ve kayıp) | `product_read.gd:116-136`, kenarlar `:163-181` | okuma; B2B İ25 · K40 · D30, B2C İ35 · K20 · D35 | B2C olay kartı "aynı zayıflık" diyor, adını söylemiyor |
| 13 | Olay kartları | `launch_leak.json:39`, `password_rule.json:82` (Kararlılık < 10), `b2c_floor_signal.json`, `b2c_floor_churn.json`; kapılar `seams_product.gd:73-77` | okuma | Kart görünür, koşulu görünmez |
| 14 | Ar-Ge "Tasarım sistemi" Deneyim kademelerinin eforunu %20 indirir | `sprint_catalog.gd:190`, `product_lines.gd:36` | eksen üyeliği | Efor görünür, nedeni "Deneyim" diye hiçbir yerde yazmıyor |
| 15 | D planının aşama payı ve PM hazırlığı | `D_PLAN.md:83-96`, `:194-200`, `:469`, `:498-504` | eksen üyeliği | Planlanan; Erdem'in "deneyim kartı" itirazı buraya |
| 16 | E planının pazaryeri kalite bağları | `E_PLAN.md:402`, `:408`, `:449-456` | eksen | Planlanan |

Ayrıca `scripts/debug/endgame_smoke.gd` içinde 101, `run_probe.gd` içinde 21 eksen satırı var; her seçenek bunlara
dokunur.

### 2.3 Oyuncu ekseni nerede görüyor

Hiçbir ekranda görmüyor. Ürün sekmesinin bugünkü dosyalarında (`scripts/tabs/product/`) eksen okuyan tek satır yok.
Oyuncunun eksenle karşılaştığı üç yer, ekseni adlandırıp sayısını vermeyen metinler:
- VC sorusu: "{eksen} tarafın zayıf" (`VC_Q_WEAK_DIM`). Ham değer 40'ın altında olduğu sürece (bot koşusunda yaklaşık
  44. haftaya kadar her eksen) bu soru hep "zayıf" der.
- Kayıp müşteri: "Kararlılık bizim için hâlâ açık bir soru." Kapı 55 okumada açılır; oyuncu 55'e ne kadar uzak
  olduğunu göremez.
- B2C taban kartları: "Son yorumlar hep aynı zayıflığa dönüyor." Zayıflığın adı yok.

### 2.4 Ölçülen tuzaklar (A'nın K5 koşuları, `docs/tasks/faz_ab/a_calisma/K5_runs/`)

B2B bot (`full_run_fix_due_7.log`), ham değerler, "day" = hafta:

| Hafta | Sürüm | Kararlılık | İnovasyon | Deneyim |
|---|---|---|---|---|
| 7 | v1.0 | 0 | 8 | 4 |
| 11 | v1.2 | 4 | 12 | 4 |
| 23 | v1.7 | 18,4 | 18,4 | 4 |
| 37 | v2.4 | 36 | 28,8 | 4 |
| 45 | v2.9 | 43,2 | 43,2 | 7,6 |

- Neden v1.0'da Kararlılık 0: MVP Çekirdek'ten üç K1 ister (`sprint.json` `mvp_lines: 3`). Kartların eforu veriden
  değil `sprint.json`'dan okunur (`sprint_catalog.gd:185-192`, hepsi K1 = 3), eşitlikte kimlik sırası kazanır:
  Nakit akışı, Kayıt, Fatura seçilir, tek Kararlılık hattı olan Muhasebe defteri dördüncü kalır. Oyuncu aynı yolu
  seçerse aynı sonucu alır ve bunu hiçbir yerde görmez.
- Sonuç: 20. haftada toleransı 46 olan en büyük hesabın (aylık $2.142) hedefi 31; hesap riskte. Oyuncunun gördüğü
  tek şey "Ayrılabilir".

B2C bot (`full_run_b2c_fix_due_7.log`): Deneyim 4'te kalıyor; kullanıcı memnuniyeti 10. ve 20. haftada 14, 30.
haftada 24, 50. haftada 53. Memnuniyet ağızdan ağıza büyümeyi böldüğü için (`sales_system.gd:188-191`) ürünün
ilk yarım yılı görünmez bir frenle geçiyor. (Not ve video ürünleri E'de siliniyor; ama pazaryeri aynı modeli devralır.)

### 2.5 Paralel görünür model: ALANLAR

Sprint ekranının sol sütunu bugün ürünü alan alan değerlendiriyor (`sprint_catalog.gd:111-175`, ekran
`product_model.gd:146-165`):
- Alan seviyesi = alandaki hatların kademe ortalaması, yarıma yuvarlı, 0-3.
- Beklenti = faz 1'de 1, faz 2 ve 3'te 2; o alanda son pencerede çıkış yapan rakip başına +0,5 (en çok +1); alanın
  ulaşabileceği kademeyi aşmaz.
- Kelime: 0 Yok, beklentinin altı Zayıf, beklenti ile +0,5 arası Yeterli, +1 ve üstü Güçlü.
- Cümle: alan × kelime şablonu ("Veri kaybı ve kesinti korkusu var", "Yeni kullanıcıların çoğu ilk hafta bırakıyor")
  artı açık hata, sunucu aşımı, rakip çıkışı.
- Kart: etki satırı "Güven Zayıf → Yeterli" (`sprint_catalog.gd:321-348`). PM'in çeyrek hedefi en zayıf alandır
  (`sprint_catalog.gd:503`).
- B2B istekleri zaten müşteri tipine göre alan seçiyor (`sprint.json` `archetypes`: teknik alıcı → Çekirdek, finans
  alıcısı → Entegrasyonlar, operasyon alıcısı → Güven; `sprint_bridges.gd:32-40`).

Ama bu model hiçbir ekonomik sayıyı değiştirmiyor (okuyucuları yalnız ekran, basın haberi ve sürüm sonucu:
`sprint_bridges.gd:99`, `:145`, `sprint_system.gd:1023`, `:1077`, `:1138`). Cümleler ise bir etki iddia ediyor:
"Yeni kullanıcıların çoğu ilk hafta bırakıyor" yazarken onboarding seviyesi hiçbir hesaba girmiyor; etki, başka bir
sınıflamayla (Mobil hattının Deneyim puanı üzerinden) ve görünmeden geliyor.

ERP'de iki sınıflama aynı hatları farklı kesiyor:

| Hat | Alan | Eksen |
|---|---|---|
| Nakit akışı, Kayıt | Çekirdek | İnovasyon |
| Muhasebe defteri | Çekirdek | Kararlılık |
| Stok, Fatura | Çekirdek | Deneyim |
| Mobil (ve Ar-Ge'nin açtığı Self servis) | Onboarding | Deneyim |
| Entegrasyonlar | Entegrasyonlar | İnovasyon |
| Güvenlik, Dayanıklılık | Güven ve Ölçek | Kararlılık |

Yani oyuncu "Güven ve Ölçek Yeterli" görürken Kararlılık ekseni Muhasebe defteri yüzünden düşük olabilir; ya da
tersi.

---

## 3. Sprint öncesi Ürün ekranı ve geçişte kaybolanlar

Kaynak: `git show 1abbb7e^:project-unicorn/scripts/tabs/product/detail_view.gd` (786 satır),
`feature_lines_view.gd`, `product_ui_shared.gd`.

Eski "Ürün Detayı" kabaca şöyleydi:

```
ÜRÜN PROFİLİ                                   DURUM
   △ üçgen grafik      ● İnovasyon  ████░ 74    Müşteri 9 · MRR $14.200/ay
                       ● Kararlılık ███░░ 61    Memnuniyet 52 · Kayıp %11
                       ● Deneyim    ██░░░ 48    İlgi 63 · Açık hata 7
   Hata riski: Orta                             ETKİN KARARLILIK 54 / 61
   [7 hata · artıyor] [v4 · 3 haftadır yayında] DESTEK ...
YATIRIMCI İŞTAHI ...                            SÖZLER ...
Pazar payı %2,1 · Defterix %4,8 · Defterix seni geçti
Zayıf yanın Deneyim. v5 sürümünde onu güçlendir; Defterix önünde.
```

- Üçgen ve üç çubuk: okuma ölçeği (0-120, 100 pazar çıtası) (`detail_view.gd:236-267`, `:608-613`).
- Etkin kararlılık: hatayla aşınmış kararlılık ve okuma yan yana (`:663-667`). A'nın K5 commit'i aşınmayı sildi;
  bu satırın karşılığı artık yok.
- İpucu şeridi: en zayıf eksen, rakip ve sonraki sürüm (`product_ui_shared.gd` `product_tip`, metinler
  `PROD_TIP_WEAK`, `PROD_TIP_GOOD`; CSV'de hâlâ duruyorlar, okuyanı yok).
- Sürüm planındaki hat listesi eksen başlıkları altında gruplanıyordu ve her kademe "Efor 8 · Deneyim 7,2 (+3,2)"
  gibi ağırlıklı eksen kazancını yazıyordu (`feature_lines_view.gd:74-110`, `:209-210`).
- Pazar payı satırı ve "seni geçti" uyarısı.

Geçişte kaybolanlar: eksenin her görünümü (üçgen, çubuklar, ipucu, kademe başına eksen kazancı), "en zayıf yer"
cümlesi, rakibe göre konum. Kalanlar: sürüm listesi, hata satırları (A ile yenilendi), sözler. Yerine gelen: alan
kelimesi ve cümlesi. Yani sprint geçişi görünür kaliteyi eksenden alana taşıdı ama ekonomiyi eksende bıraktı. Erdem'in
"ne kadar kötü bir iş yaptığımızın kanıtı" dediği boşluk tam olarak bu ayrışma.

Doğru kaybolan bir şey de var: üçgenin sayıları oyuncuya ne yapacağını söylemiyordu. R8 §4, Mad Games Tycoon 2'nin
dört alt puanı gösterip toplamı gizlemesinin "rating system confusing" şikâyeti getirdiğini aktarıyor. Eski ekranı
geri getirmek çözüm değil.

---

## 4. Oyunlar kaliteyi nasıl gösteriyor (R8, R1 ve R3'ün tamamlama bölümleri)

- Software Inc: "innovation / stability / usability" resmi bir veri alanı değil; wiki'de yalnız QA özelliğinin
  açıklamasında bir cümle (R8 §7.1, R1 §7.1). Bizim eksenlerin kaynağı muhtemelen bu cümle; yani oyunda karşılığı
  olmayan bir modeli taşıyoruz. Gerçek veri alanı "alt pazar" oranı: her özellik üç alt pazarı ne kadar doyurduğunu
  taşır, ekranda "Market satisfaction" çubukları olarak görünür (R8 §7.1). Kalite etiketleri 2025'te "dinamik müşteri
  yorum sistemi" ile değiştirildi (R1 §2.5). Hata kaliteyi değil destek yükünü ve satışı etkiler (R1 §2.4).
- Game Dev Tycoon: puan oyuncunun kendi önceki en iyisine göre ölçülür, hedef her rekorla yaklaşık %10-24 yükselir
  (R3 §7.2). Hata toplam puanın yüzdesi olarak ölçülür, mutlak sayı değil (R3 §7.1, R8 §7.2). Oyuncu nedeni etiketli
  cümlelerden öğrenir ("good balance", "shouldn't forget about X", "Too many bugs"); puanın kaç düştüğü söylenmez
  (R3 §7.2). Şikâyet: söylenen cümle az ve rastgele (R3 §3).
- Mad Games Tycoon 2: dört alt puan; toplam en zayıfa ağır basar; eşikler yıl ve türle yükselir (R8 §2.3). Toplamın
  nasıl hesaplandığı şeffaf değil, oyuncular dış wiki'ye gidiyor (R8 §4).
- Startup Company: tek memnuniyet rozeti (örneğin %70), kırılım ekranı yok (R8 §7.3); kapalı özelliklerin
  memnuniyeti sessizce düşürmesi oyuncu şikâyeti ve geliştirici özrü getirdi (R8 §4: "gizli ceza").
- Two Point Hospital: itibar bileşenleri ve her olayın ağırlığı yazılı (başarılı tedavi +1, ölüm -2), bantlar
  Very Poor ile Great arası (R8 §7.4). Oyuncu dış kaynağa bakmadan neyin itibarı oynattığını bilir.

Ortak ders (R8 §5): toplam bir durum, alt kırılım ve eyleme dönüşen bir neden; eşik sabit değil, döneme ya da
rakibe göre. Kaçınılacak: çıplak eksen sayısı, gizli toplam, gizli ceza. Bizim görünür alan modelimiz bu kalıbın
çoğunu zaten taşıyor (kelime beklentiye göre, cümle neden söylüyor, beklenti rakiple yükseliyor); eksik olan tek
şey, alanın ekonomide bir karşılığı olması.

---

## 5. Üç seçenek

Her seçenek için aynı başlıklar: oyuncu ne görür, kartlar nasıl bağlanır, hangi kod etkilenir, kaba bedel, ölçekte
davranış, C ve D ile ilişki.

### 5.1 (a) Eksenleri kaldırmak

Ne: Üç eksen, eksen puanları, taban merdiveni ve müşteri tipinin eksen ağırlıkları silinir. Ekonominin kalite
girdisi tek bir sayı olur: yayındaki toplam kademe / beklenen toplam kademe. Alanlar ekranda kalır ama yine
ekonomiye bağlanmaz (bağlanırsa bu (c) olur).

Oyuncu ne görür: Bugünkü sprint ekranı aynen. Genel Bakış'ta "Ürün kapsamı %72" gibi tek bir sayı. Memnuniyet
ipucunda "Ürün kapsamı 50". VC "Ürün henüz ince" der.

Kartlar: Her kademe kartı kapsamı aynı ölçüde artırır. "Hangi kart" sorusu ekonomide yalnız hata ve istek
üzerinden anlam taşır.

Etkilenen kod: §2.2'deki 16 okuyucunun hepsi; `QualityModel`'in eksen zinciri, `ProductRead` tabanları, `mvp_*`
bayrakları ve kayıt göçü, `SalesArchetypes` eksen ağırlıkları, dört olay kartı, `ProductLines` doğrulayıcısı. D'nin
aşama payı yine bir kaynağa ihtiyaç duyar (§8.3).

Bedel (kaba): 28-40 saat. Motor ve okuyucular 10-14, veri ve doğrulayıcı 2-3, olaylar 2-3, smoke 6-8, kalibrasyon
6-10, D için iş profili alanı 2.

Ölçekte: Ekip büyüklüğünden bağımsız (oran). Ama müşteri farkı kaybolur: lojistik firması ile teknoloji firması
aynı ürüne aynı gözle bakar. 50 kişilik ekip her şeyi K3'e çıkarınca kapsam %100'de doyar.

C ve D: C'nin "Sürüm" bloğu tek satıra iner. D'nin aşama payı eksenden okunamaz, yeni alan gerekir.

Zayıf yan: Erdem'in "nerede eksik" sorusuna cevap vermez; alan cümleleri yine ekonomiyle bağsız kalır, yani bugünkü
"cümle bir şey iddia ediyor ama hesap başka yerden geliyor" sorunu sürer.

### 5.2 (b) Eksenleri oyuncuya anlamlı göstermek

Ne: Eksenler kalır, görünür olur. R8 §5'in (b) önerisi: her eksen bir kelime ve bir nedenle gösterilir, toplam
kuralı açıkça yazılır, eşik göreli olur.

Oyuncu ne görür (kaba taslak, gösterim C'nin):
```
┌ SÜRÜM ─────────────────────────────────────────────────┐
│ v1.4 · 3 hafta önce · Sonraki v1.5 · Sprint 9           │
│ Kararlılık  Zayıf    Muhasebe defteri ve yedek eksik    │
│ Deneyim     Yeterli                                     │
│ İnovasyon   Güçlü    Defterix'ten önde                  │
│ Lojistik hesapların en çok Kararlılığa bakıyor.         │
└─────────────────────────────────────────────────────────┘
```
Kartta ek çip: "Kararlılık +4". Hat listesinde eksen başlıkları geri gelir. Sprint ekranının sol sütunu alanları
göstermeye devam eder.

Kartlar: Her kademe kartı bir alan ve bir eksen taşır ("Güvenlik K2 · Güven ve Ölçek · Kararlılık +7,2").

Etkilenen kod: Üç ölçek tek okumaya indirilir (§2.1 tablosu); VC ve yatırım masasının ham eşikleri düzeltilir; MVP
tuzağı için kural (örneğin her eksenden en az bir hat) eklenir; Genel Bakış, kart ve ipucu için yeni gösterim;
metinler (TR ve EN); Claude Design maketi.

Bedel (kaba): 32-43 saat. Ölçek birleştirme 6-8, MVP ve B2C tuzakları 3-4, gösterim 12-16 (maket hariç), metin 2-3,
kalibrasyon 6-8, smoke 3-4.

Ölçekte: Puanlar kademe başına sabit (4/9/12), çıta faza göre büyür; ekip büyüklüğünden bağımsız. Eksen başına üç hat
K3'e çıkınca okuma 120'de kesilir.

C ve D: C'nin bugünkü taslağı (`C_PLAN.md:98-99`, `:115`, `:135`) neredeyse olduğu gibi kalır. D'nin eksen payı
tablosu (`D_PLAN.md:87-91`) geçerli kalır, ama Erdem'in "deneyim kartı ne demek" itirazını cevaplamak için kart
eksenini adıyla göstermek zorunda kalır.

Zayıf yan: Oyuncu aynı hatları iki ayrı sınıflamada görür (alan ve eksen; §2.5 tablosu). "Güven Yeterli ama
Kararlılık Zayıf" gibi çelişen iki cümle aynı ekranda durabilir. R8 §4'teki "rating system confusing" şikâyetinin
yapısal nedeni tam bu. Ayrıca rakip için iki ayrı kalite sistemi (eksenli `RivalRegistry` ve alanlı `rivals.json`)
yaşamaya devam eder.

### 5.3 (c) Alanlar ürünün tek kalitesi olur

Ne: Eksenler ve eksen puanları ekonomiden çıkar. Kalitenin tek kaynağı oyuncunun zaten gördüğü alan seviyesi ve
beklentisidir. Ekonomi alan seviyesinin beklentiye oranını okur. Her müşteri tipi alanlara farklı ağırlık verir
(bugün istekleri seçen eşleme genişletilir). "Kararlılık" bir hat özelliği olmaktan çıkar; açık hata (A) ve kesinti
(C'nin sunucusu) zaten ölçülen kararlılıktır.

Oyuncu ne görür:

Sprint ekranı bugünkü gibi; değişen tek şey, gördüğü kelimelerin artık sonuç doğurması.

Genel Bakış "Sürüm" bloğu (kaba taslak, gösterim C'nin):
```
┌ SÜRÜM ─────────────────────────────────────────────────┐
│ v1.4 · 3 hafta önce · Sonraki v1.5 · Sprint 9           │
│ Çekirdek         Yeterli  ■■■■■□□□□□                     │
│ Güven ve Ölçek   Zayıf    ■■□□□□□□□□                     │
│ Entegrasyonlar   Yeterli  ■■■■■□□□□□                     │
│ Onboarding       Güçlü    ■■■■■■■□□□                     │
│ En zayıf yer Güven ve Ölçek. Lojistik ve inşaat          │
│ hesapların (4 hesap) en çok buna bakıyor.                │
└─────────────────────────────────────────────────────────┘
```
Kareler bugünkü hedef çubuğunun ölçeğidir (`sprint.json` `pm.goal_squares 10`, `goal_mark 5`: beşinci kare
beklentidir).

B2B hesap memnuniyeti ipucu (C'nin taslağının "Ürün kararlılığı" satırı yerine):
```
Memnuniyet 52, hedef 49
  Ürün uyumu · Güven Zayıf, Çekirdek Yeterli     55
  Kullandığı hatlarda açık hata                  −6
  Söz ve kesintiler                               0
Ayrılma eşiği 36
```

Kayıp müşteri: "Yedekleme ve yetki sizde henüz zayıf. Güven tarafı düzelince yeniden konuşalım." VC: "Güven ve
Ölçek tarafın zayıf. Sektörü bilen biri bunu ilk bakışta görür." B2C taban kartı: "Son yorumlar hep aynı yere
dönüyor: yeni gelenler ilk hafta bırakıyor." Hepsi oyuncunun sprint ekranında gördüğü kelimeyi adlandırır.

Kartlar: Bugünkü etki satırı ("Güven Zayıf → Yeterli") olduğu gibi kalır ve artık doğru söyler. Kartta eksen çipi
yoktur. D kartın aşama ihtiyacını sayıyla gösterir ("Tasarım 3 · Geliştirme 13 · Test 9"); "kararlılık kartı" diye
bir kavram kalmaz, kartın neye ağırlık verdiği sayılardan okunur.

Etkilenen kod:
- Yeni tek okuma yüzü (çalışma adı `ProductQuality`): alan oranı, müşteri tipine göre uyum, en zayıf alan, ekran
  satırları. `QualityModel`'in eksen zinciri ve `push_axes` silinir ya da bu yüzün arkasına çekilir.
- §2.2'deki 1-14 numaralı okuyucular bu yüze taşınır.
- Veri: `sales_archetypes.gd` eksen ağırlıkları yerine alan ağırlıkları; hat verisine "iş profili" alanı (§8.3);
  `axis` ve `axis_points` alanları ile `IDENTITY_AXIS_SHAPE` doğrulaması kalkar.
- B2C göreli kalite rakip eksenleri yerine beklentiyi okur (beklenti zaten rakip çıkışıyla yükseliyor);
  `RivalRegistry`'nin eksen alanları ekonomiden düşer (Piyasa ve pazar payı gösterimi ayrıca kontrol edilecek).
- Olaylar: taban kartları ve iki "Kararlılık < 10" kapısı alan kelimesine bağlanır; `urun.axis_*` kapıları yerine
  alan kapıları.
- Kayıt: `mvp_*` eksen bayrakları okunmaz olur, göç yalnız temizlik.

Bedel (kaba): 36-49 saat. Okuma yüzü 5-7, okuyucuların taşınması 10-12, veri 3-4, olaylar ve kapılar 3-4, kayıt 1-2,
smoke 6-8, kalibrasyon 8-12. Yeni ekran yok (alan paneli var; Genel Bakış ve ipucu C'nin işinde çiziliyor), bu yüzden
bu fazın kendisi Claude Design maketi beklemez.

Ölçekte: §6.6'da ayrıntılı. Kısaca oran ekip büyüklüğünden ve hesap sayısından bağımsız; beklenti fazla ve rakiple
yükselir; kademe tavanı 3 olduğu için Erken Erişim'de beklentinin büyümesi yeni kademe içeriği ister (bu her üç
seçenekte aynı).

C ve D: C'nin "Sürüm" bloğu eksen yerine alan satırları çizer ve memnuniyet ipucundaki ilk terim "Ürün uyumu" olur.
D'nin aşama payı eksen tablosu yerine hattın iş profilinden okunur; profilin başlangıç değerleri bugünkü eksen
eşlemesinden kopyalanır, yani D'nin sayıları değişmez (§8.3).

### 5.4 Karşılaştırma

| | (a) Kaldır | (b) Göster | (c) Alan tek kalite |
|---|---|---|---|
| "Nerede eksik?" cevabı | Yok (tek yüzde) | Var, iki sınıflamayla | Var, tek sınıflamayla |
| Görünen = hesaplanan | Kısmen | Evet, ama iki model | Evet |
| Müşteri tipi farkı | Kaybolur | Kalır (eksen) | Kalır (alan) |
| Alan cümleleri doğru mu | Hayır | Hayır | Evet |
| Rakip kalite sistemi | Bir | İki | Bir |
| Yeni ekran işi | Az | Çok (eksen gösterimi) | Yok (C ve D zaten çiziyor) |
| Kaba bedel | 28-40 sa | 32-43 sa | 36-49 sa |
| Kalibrasyon riski | Orta | Düşük | Orta-yüksek |
| E'ye etkisi | Kalite bağları yeniden | Değişmez | Pazaryeri hatları alana bağlanır |

### 5.5 Öneri: (c)

Gerekçe:
1. Erdem'in iki cümlesini birden cevaplayan tek seçenek bu. Oyuncu ürüne bakınca nerede eksik olduğunu görür (alan
   kelimesi ve cümlesi) ve gördüğü şey sonuç doğurur (memnuniyet, büyüme, satış). "Deneyim kartı ne demek" sorusu
   ortadan kalkar, çünkü öyle bir kavram kalmaz.
2. Oyuncunun göremediği model kurulmaz kuralını en temiz karşılayan seçenek. (b) görünür kılar ama iki model bırakır;
   (a) görünmezliği kaldırır ama ekonomiyi kör bir yüzdeye bağlar.
3. Bugün yazılmış olanın çoğu yeniden kullanılır: alan seviyesi, beklenti, rakip çıkışıyla yükselme, cümleler, kart
   etki satırı, müşteri tipine göre istek eşlemesi. Yeni kavram yazmıyoruz, var olanı bağlıyoruz.
4. Göreli eşik (R8 §5 "alınacak"; Game Dev Tycoon R3 §7.2, Mad Games Tycoon 2 R8 §2.3) zaten alan modelinde var:
   kelime beklentiye göre, beklenti faza ve rakibe göre. Sabit sayı yerine oran.
5. Görünmez ceza (Startup Company dersi, R8 §4) ve tuzaklar (§2.4) görünür seçime dönüşür: MVP'yi Güven'siz çıkaran
   oyuncu "Güven ve Ölçek: Yok · Ne yedek var ne yetki" görür ve lojistik müşterisinin buna baktığını ipucunda okur.
6. Bedeli (b)'den biraz yüksek ama tek seferlik; (b) ise iki sınıflamayı her yeni ürün türünde (E'nin pazaryeri,
   Erken Erişim'in ikinci ürünü) yeniden dengelemeyi gerektirir.

Riskler ve bedeli §9'da.

---

## 6. (c) için kurallar (öneri)

Her sabit "[ÇALIŞMA] onay bekliyor"; kalibrasyonda botla ölçülecek.

### 6.1 Alan oranı
- Kural: alan oranı = alan seviyesi / alan beklentisi. Seviye ve beklenti bugünkü tanımlarıyla (`sprint_catalog.gd:111-
  125`); ekonomi yarıma yuvarlanmamış seviyeyi okur, ekran yuvarlanmışı ve kelimeyi gösterir. Oran en çok 1,5'te
  kesilir. [ÇALIŞMA]
- Neden var: Kalite mutlak değil, pazarın o anki beklentisine göre ölçülmeli; aksi halde faz 3'te faz 1'in ürünü hâlâ
  "iyi" sayılır. Oran olduğu için hesap sayısı ya da ekip büyüklüğüyle kaymaz.
- Neden kesilir: Bir alanda aşırı yatırım başka alanın eksiğini sınırsız kapatmasın (Mad Games Tycoon 2'nin "en zayıf
  ağır basar" dersi, R8 §2.3; Startup Company'nin denge kuralı, R8 §2.4).
- Oyuncu neden görsün: Kelime ve kareler bu oranın kendisi; ekranda gördüğü kare sayısı ekonominin okuduğu sayıdır.

### 6.2 Müşteri tipinin alan ağırlığı
- Kural: B2B müşteri tipi başına ağırlık. Önerim: önemsediği alan %50, Çekirdek %30 (herkes çekirdeği kullanır),
  pazarın kalan alanları %20'yi eşit böler. Önemsediği alan bugünkü istek eşlemesidir: operasyon alıcısı (lojistik,
  inşaat, üretim) Güven ve Ölçek, teknik alıcı (teknoloji, e-ticaret, finans) Çekirdek, finans alıcısı (sigorta,
  hukuk, perakende, emlak) Entegrasyonlar. Çekirdek'i önemseyen tipte Çekirdek %80 olur. [ÇALIŞMA]
- Neden var: Aynı ürün iki masada farklı okunmalı; satış görüşmesi ve memnuniyet bunu bugün eksen ağırlığıyla
  yapıyor, aynı işi oyuncunun gördüğü alanla yapar.
- Neden yalnız bir önemli alan: Oyuncunun ipucunda tek cümleyle okuyabileceği kadar sade; istekler de zaten tek alandan
  geliyor, ikisi aynı hikâyeyi anlatır.
- B2C: tek kitle, ağırlık pazarın alanlarına eşit; Gelir alanı (ücretli plan) kaliteye girmez, fiyatın konusudur.

### 6.3 B2B "Ürün uyumu" terimi
- Kural: hesabın memnuniyet hedefindeki ürün terimi = 70 × Σ (ağırlık × alan oranı). Bütün alanlar beklentide
  (Yeterli) ise 70. [ÇALIŞMA] Öteki terimler C'nin listesiyle aynı: açık hata (A), söz ve kesintiler, kurumsal sunucu
  şartı. (inceleme) "İlk 4 hafta tabanı" C'nin güncel içeriğinde kalktı (`C_ICERIK_v2.md` §2.5.1), listeden çıkarıldı.
  (yönetmen, 17 Ekim) Bu cümle C incelemesinden önce yazıldı. C'nin son hâlinde taban KALIR: ilk 4 hafta hedefin tabanı
  70'tir, sonraki 8 haftada hesabın kendi hedefine iner (`C_ICERIK_v2.md` §2.5.1). Sebep: memnuniyet hedefe haftada 21
  puana kadar kayıyor (`SAT_DRIFT_STEP` günlük 3 × 7), yalnız başlangıç değeri ilk tikte silinir. Taban bu terimin
  yanında, listede durur.
- Neden var: Hesabın memnuniyeti ürünün ona ne kadar uyduğundan gelmeli. Bugünkü terim yalnız Kararlılık eksenini
  okuyor ve oyuncu onu göremiyor.
- Neden 70: (inceleme, düzeltildi) Erdem'in sözü (17 Ekim) yeni hesabın memnuniyetinin **başladığı** yer içindir: %50'den
  değil, %70'ler civarından. Başlangıç C'nindir ve her hesapta sabit 70'tir (`C_ICERIK_v2.md` §2.5.1, öneri). Buradaki 70
  ayrı bir öneridir: beklentiyi tam karşılayan ürünün hesabı başladığı yerde kalır, zayıf ürünün hesabı oradan aşağı
  kayar. İmza anı memnuniyeti bu terimden değil C'nin sabit başlangıcından okunur; bugünkü ayrı imza formülü
  (`sales_system.gd:414-418`) kalkar.
- (inceleme) Üst sınır: oran 1,5'te kesildiği için terim 105'e kadar çıkar. C'nin A ceza tavanı önerisi (20 → 40, "hiç
  düzeltilmeyen ürün en iyi ürün terimindeki hesabı bile eşiğin altına itebilmeli", `C_ICERIK_v2.md` §2.5.2) en iyi
  ürün terimini 67 sayarak hesaplandı; 105 − 40 = 65 eşiğin çok üstündedir. Terimin tavanı ile C'nin ceza tavanı aynı
  ölçümde seçilmeli [ÇALIŞMA].
- Ölçek: hesap başına ayrı ama formül hesap sayısından bağımsız; 330 hesapta da her biri kendi ağırlığıyla aynı oranı
  okur.

### 6.4 B2C kalite ve memnuniyet
- Kural: B2C kalite terimi = 50 × ağırlıklı alan oranı (en çok 100; (inceleme) oran 1,5'te kesildiği için fiilen en çok 75); bugünkü "rakibe göre 50 merkezli" terimin yerine
  geçer. Beklenti rakip çıkışıyla zaten yükseldiği için rakip baskısı korunur. Kullanıcı memnuniyetinin hedefi =
  70 × (Çekirdek ve Onboarding oranlarının ortalaması). [ÇALIŞMA]
- Neden var: Kitle büyümesi ve memnuniyet ürünün beklentiyi karşılamasından gelmeli. Onboarding'in "Yeni kullanıcıların
  çoğu ilk hafta bırakıyor" cümlesi böylece doğru olur.
- Neden 50: Bugünkü terimin "rakiple başa baş" noktası 50; geçiş sürekliliği korur, kalibrasyonu küçültür.

### 6.5 Öteki okuyucular
| Bugün | (c)'de |
|---|---|
| Ürün değeri (fiyat önerisi) normalize bileşik | B2C kalite terimi (§6.4) |
| Aday yıldız karışımı (okuma / taban) | B2B pazarının ağırlıklı alan oranı |
| Satış görüşmesi ürün uyumu | Adayın tipine göre §6.3 oranı; zar ipucu satırı "ürün uyumu · Güven Zayıf" |
| Kayıp nedeni "Kararlılık" (< 40) ve kapısı (≥ 55) | Adayın önemsediği alan Zayıf ya da Yok ise o alan; kapı alan Yeterli olunca açılır |
| VC ve yatırım masası en zayıf eksen (ham < 40) | En zayıf alan Zayıf ya da Yok ise o alan |
| Taban merdiveni (uyarı, kayıp) | Alan oranı 0,6'nın altına inince uyarı, 0,4'ün altında 4 hafta kalırsa kayıp [ÇALIŞMA] |
| "Kararlılık < 10" olay kapıları | Güven ve Ölçek seviyesi 0 |
| Açık hatanın etkilediği hesaplar | Hattın alanına ağırlığı %20 ve üstü olan hesaplar (Çekirdek hatları herkesi etkiler) [ÇALIŞMA] |
| Ar-Ge "Tasarım sistemi" Deneyim eforu −%20 | İş profili "tasarım ağırlıklı" hatlar (§8.3) |

### 6.5b Ekip becerisi kaliteye nasıl girer
- Kural: Beceri ürün seviyesini çarpmaz. Beceri hızı (D) ve hata ihtimalini (D, A) belirler; hata açık hata olarak
  görünür ve memnuniyetten düşer.
- Neden: Bugün de beceri kaliteye girmiyor (gerçekleşme damgası ve kapı üstü bonusu ölü, §2.1). Gizli bir "iyi ekip
  daha kaliteli kademe yazar" çarpanı, oyuncunun göremediği bir model olurdu. Software Inc'de de hata kaliteyi değil
  destek yükünü ve satışı etkiliyor (R1 §2.4). Ölü iki parça bu fazda silinir.

### 6.6 Ölçek testi

| Kadro | Ne değişir | Kalite modeli neden kırılmaz |
|---|---|---|
| 1 (kurucu) | Sprintte 1-2 kart | Oran ürünün durumuna bakar, kişiye değil |
| 3 | Daha çok kart | Aynı |
| 6 | Aynı alanda paralel kart | Seviye ortalamadır; aynı hatta iki kart yok |
| 12 | Bütün alanlar ilerler | Beklenti faz ve rakiple yükselir; "Güçlü" en çok +1'in üstü |
| 25 | Kademeler K3'e yaklaşır | Oran 1,5'te kesilir; aşırı yatırım sınırlı getiri |
| 50 (EA) | Tüm hatlar K3 | Beklenti alanın tavanını aşamadığı için alanlar doyar: her seçenekte aynı tavan; yeni kademe ya da hat içeriği ister (§9) |

Hiçbir kural "kişi başı" ya da "hesap başı" sabit taşımaz; 330 hesap ya da 50 kişi oranı değiştirmez.

---

## 7. Kapsam önerisi

Önerim: C'den önce ayrı, ekransız küçük bir faz (çalışma adı "Faz Q: ürün kalitesi"). Sıra A → B → Q → C → D → E.

Neden ayrı ve önce:
- C, D ve E üçü de kaliteyi okuyor: C'nin Genel Bakış bloğu ve memnuniyet terimi, D'nin aşama payı ve PM hazırlığı,
  E'nin pazaryeri kalite bağları. Q önce biterse üçü de hazır bir arayüze karşı uygulanır.
- Q ekransızdır (alan paneli var; görünür satırları C, kart sayılarını D çiziyor), bu yüzden Claude Design maketi
  beklemez ve C ile D'nin maket turuyla paralel yürüyebilir.
- C'nin içine konursa C'nin farkı ekonomiyi de yeniden dengeleyen çok büyük bir işe döner; kalibrasyon ile ekran
  kabulü aynı commit'lere karışır.
- D'nin içine konursa D'nin konusu (ekip modeli) ile ilgisi zayıf; D'nin yalnız iş profili alanına ihtiyacı var.

Q'nun adımları (kaba): (1) okuma yüzü ve veri, (2) okuyucuların taşınması, (3) olaylar ve kapılar, (4) bot
kalibrasyonu (B2B ve B2C, A'nın sekiz düzeltme kolu), (5) eski eksen kodunun ve ölü parçaların silinmesi, (6) smoke.
Q bitince oyuncunun ekranında görünür bir değişiklik çok az olur (VC ve kayıp cümleleri alan adını söyler); asıl
görünürlük C ile gelir. Bu yüzden Q ile C arasında uzun bir boşluk bırakılmamalı.

Erdem (b)'yi seçerse: ekran işi ağır basar ve Q'nun ayrı faz olmasına gerek kalmaz; ölçek birleştirme ve MVP tuzağı
C'nin ilk adımı olur, eksen gösterimi C'nin Genel Bakış'ında, kart çipi D'de yapılır.

---

## 8. C ve D'ye etkisi ve iki seçenekte de çalışan arayüz

C ve D tasarımcıları paralel çalışıyor ve Erdem'in kararını bilmeden ilerleyecek. Aşağıdaki üç sözleşme (b)'de de
(c)'de de aynı biçimde doldurulur; C ve D yalnız bunları okursa karar ne olursa olsun planları geçerli kalır.

### 8.1 "Ürün durumu satırları" (C'nin Genel Bakış "Sürüm" bloğu)
- Sözleşme: ürün durumu bir satır listesidir. Her satır: ad, kelime (Yok, Zayıf, Yeterli, Güçlü), ton (iyi, nötr,
  uyarı), kısa neden cümlesi (boş olabilir), kare doluluğu (0-10, beşinci kare beklenti). Ayrıca tek bir "en zayıf
  yer" cümlesi.
- (b)'de satırlar üç eksendir; (c)'de pazarın alanlarıdır (B2B 4, B2C 5, Gelir dahil değilse 4). C satır sayısını
  sabit varsaymamalı: 3 ile 5 arası çizebilmeli.
- C'nin bugünkü taslağındaki "Kararlılık 61 · İnovasyon 54 · Deneyim 48" satırı ve "eksen sırası pazara göre" kuralı
  (`C_PLAN.md:98-99`, `:115`, `:135-136`) bu sözleşmeye çevrilmeli; çıplak sayı yerine kelime ve kare.
- Tıklama: satır sprint ekranındaki alanı açar ((c)'de birebir; (b)'de en çok etkileyen alanı).

### 8.2 "Ürün uyumu" terimi (C'nin memnuniyet ipucu ve hedef terimleri)
- Sözleşme: hesap başına kalite terimi tek bir fonksiyondan gelir ve {etiket, değer, not} döndürür; C'nin
  `target_terms` listesinin ilk elemanı budur (`C_PLAN.md:705-712`).
- (b)'de etiket "Ürün kararlılığı" ya da hesabın tipine göre en ağır eksen; (c)'de "Ürün uyumu", not "Güven Zayıf,
  Çekirdek Yeterli".
- C'nin `SAT_TERM_QUALITY` anahtarı (`C_PLAN.md:931`) etiketi kendisi sabitlememeli; etiket bu fonksiyondan gelir.
- Memnuniyetin başlangıcı: (inceleme, düzeltildi) C'nin güncel içeriği başlangıcı her hesapta sabit 70 yapıyor ve ilk 4
  hafta tabanını kaldırıyor (`C_ICERIK_v2.md` §2.5.1). Bu terim başlangıcı değil, hesabın 70'ten kaydığı hedefi verir
  (§6.3).

### 8.3 "İş profili" (D'nin aşama payı ve PM hazırlığı)
- Sözleşme: her hattın veride bir iş profili alanı olur: tasarım ağırlıklı, geliştirme ağırlıklı, test ağırlıklı.
  D'nin kart ihtiyacı tablosu (`D_PLAN.md:87-91`: 35/45/20, 15/65/20, 10/55/35) ve hazırlık tablosu (`:196-200`)
  eksen yerine bu alanı okur. Kart ekranda profili adıyla değil, aşama sayılarıyla gösterir.
- Başlangıç değerleri bugünkü eksenden kopyalanır: Deneyim hattı → tasarım ağırlıklı, İnovasyon → geliştirme
  ağırlıklı, Kararlılık → test ağırlıklı. Böylece D'nin örnekleri ("Toplu Fatura 9 / 11 / 5") her iki seçenekte birebir
  aynı kalır.
- Neden eksenden ayrı: hattın ne tür iş istediği ile müşterinin ondan ne beklediği iki ayrı sorudur. Ayrı alan olunca
  bir hat örneğin "Güven alanında ama tasarım ağırlıklı" (yetki ekranı) olabilir. Bu, Erdem'in "özelliğe tasarım
  karmaşıklığı" fikrini (D_PLAN §2.2) eksen adına bağlamadan taşır.
- Ar-Ge "Tasarım sistemi" indirimi de bu alanı okur (bugün Deneyim eksenini okuyor, `sprint_catalog.gd:190`).
- D'nin uygulaması bu alanın varlığını varsayabilir; alan Q'da (c) ya da C'nin başında (b) eklenir. Q yoksa D kendi
  ilk adımında ekler; iş 2 saat.

### 8.4 C ve D'nin dokunmaması gerekenler
- Eksen adlarını yeni oyuncu metnine yazmayın ("Kararlılık 61", "deneyim kartı"). (b) seçilirse adlar ve
  açıklamaları tek yerden gelecek.
- `QualityModel` ya da `mvp_*` bayraklarını yeni kodda doğrudan okumayın; yukarıdaki üç sözleşmeyi okuyun.

---

## 9. E'ye ve geri kalanına etkisi, riskler

- E: Pazaryeri planı "kalite modeli değişmez" diyor ve hatları eksenle tanımlıyor (`E_PLAN.md:64-70`, `:402-408`).
  (c)'de pazaryeri hatları alanlara bağlanır (Alıcı ve Satıcı tarafı zaten iki gruptur; alan tanımı E'nin) ve
  "deneyim ekseni → alıcı memnuniyeti" bağı §6.4'ün kuralına döner. Hatların iş profili §8.3 ile eksenden kopyalanır.
  Tahmini ek iş E'de 3-5 saat belge ve veri.
- Kalibrasyon riski (en büyük risk): B2B kayıp ve B2C büyüme eğrileri bugün eksen değerleriyle dengelendi. Faz 1'de
  Çekirdek dışı alanların beklentisi 1 olduğu için MVP'de birçok alan "Yok" ya da "Zayıf" görünür; ilk 4 hafta tabanı
  ve beklenti tablosu birlikte ayarlanmalı. Önerim: faz 1'de beklenti Çekirdek için 1, öteki alanlar için 0,5.
  [ÇALIŞMA]
  (inceleme) Sayıyla: bot yolunun ERP MVP'si Çekirdek'in beş hattından üçünü K1'de çıkarıyor (seviye 0,6), öteki alanlar
  0. Bu önerilerle operasyon alıcısının ürün terimi 70 × (0,5 × 0 + 0,3 × 0,6) ≈ 13, teknik alıcınınki 70 × 0,8 × 0,6 ≈ 34.
  (yönetmen, 17 Ekim: bu cümledeki "taban kalktı" ve "haftada en çok 3 puan" C incelemesiyle eskidi; C'nin son hâlinde
  taban 4 hafta 70, sonra 8 haftada söner, kayma haftada 21'e kadar. Sonuç değişmez, yalnız mekanizma: hesap 12. haftaya
  dek tabanda tutulur, taban bitince bir iki tikte ürün terimine iner.) İlk 4 hafta tabanı da kalktığı için (C) hesap 70'ten haftada en çok 3 puan iner; ikisi de yaklaşık 11-12. haftada
  eşiğe (30-38) varır, operasyon alıcısı altına düşer, teknik alıcı eşiğin hemen çevresinde kalır. Yani bugünkü
  sayılarla, ürün MVP'den sonraki üç ayda büyümezse hemen her B2B hesap ayrılma eşiğine iner. Q'nun kalibrasyonu ilk iş olarak bunu ölçmeli; aksi hâlde Erdem'in "yukarıdan başlasın" isteği birkaç
  hafta sonra tersine döner.
- Kademe tavanı: Her alan en çok 3. Erken Erişim'in sonsuz koşusunda beklenti büyümeye devam edemez; alanlar bir
  noktada doyar. Bu her üç seçenekte aynı ve ürün içeriğinin (yeni kademe, Ar-Ge'nin açtığı gizli hatlar) konusu.
  Bu belge çözmüyor; EA tasarımına not.
- Görünürlük boşluğu: Q biter, C gecikirse oyuncu kalitenin yeni anlamını yalnız sprint ekranındaki alan paneli ve
  birkaç cümle üzerinden görür. Q ile C aynı tur içinde planlanmalı.
- Rakip: (c)'de rakibin ekonomik etkisi yalnız beklenti artışıyla gelir; `RivalRegistry`'nin eksenli rakip kalitesi
  ekonomiden düşer. Erdem C için rakip konusunu şimdilik kapsam dışı tuttu; Piyasa ekranının bu alanları okuyup
  okumadığı Q'nun ilk adımında kontrol edilmeli.
- Smoke yükü: `endgame_smoke.gd`'de eksen okuyan 101 satır var; vakaların bir kısmı silinip yeniden yazılır. A'nın
  smoke kurallarına göre (tam süit yalnız entegrasyonda) Q'nun sonunda bir tam koşu.

---

## 10. Sorular (Erdem için)

1. Ürün kalitesi için hangi yolu seçelim? Öneri: (c), yani sprint ekranında gördüğün alanlar (Çekirdek, Güven ve
   Ölçek, Entegrasyonlar, Onboarding) ürünün tek değerlendirmesi olsun ve müşteri memnuniyeti, büyüme, satış ve
   yatırımcı bunlara baksın. Alternatifler: (b) üç ekseni ekrana geri getirmek, (a) eksenleri silip tek bir "kapsam"
   yüzdesi bırakmak.
2. "Kararlılık" kelimesi oyunda kalsın mı? Öneri: evet, ama bir özellik grubu olarak değil, açık hata ve kesinti
   satırının başlığı olarak (Genel Bakış'ta "Kararlılık: 7 açık hata · son 4 haftada 1 kesinti"). Alternatif: hiç
   kullanılmasın.
3. Her B2B müşteri tipi tek bir alanı önemsesin mi (lojistik Güven'e, teknoloji Çekirdek'e, sigorta ve hukuk
   Entegrasyonlar'a bakar), yoksa iki alanı mı? Öneri: tek alan; ipucunda tek cümleyle okunur ve bugünkü istekler de
   aynı alandan geliyor.
4. Bu iş C'den önce ayrı ve ekransız bir faz olarak mı yapılsın (kaba 36-49 saat; (inceleme) "küçük" sözü çıkarıldı)? Öneri: evet (A → B → kalite → C → D → E); C ve D
   maket turlarıyla paralel yürüyebilir. Alternatif: C'nin ilk adımı olarak.

---

## Kaynaklar

- Erdem'in metni: `docs/tasks/faz_cde/ERDEM_CD_YORUM.md`.
- Kod: `scripts/systems/quality_model.gd`, `product_read.gd`, `product_state.gd`, `product_lines.gd`, `line_gates.gd`,
  `sprint_catalog.gd`, `sprint_bridges.gd`, `sprint_system.gd`, `sales_system.gd`, `b2b_sales_system.gd`,
  `sales_faucet_system.gd`, `sales_meeting_system.gd`, `sales_ledger.gd`, `sales_archetypes.gd`,
  `term_sheet_table_system.gd`, `vc_pitch_system.gd`, `scripts/events/seams/seams_product.gd`,
  `scripts/tabs/product/product_model.gd`; veri `data/product/sprint.json`, `data/product/lines/*.json`,
  `data/events/cards/product/{launch_leak,b2c_floor_signal,b2c_floor_churn}.json`,
  `data/events/cards/team/password_rule.json`.
- Eski ekran: `git show 1abbb7e^:project-unicorn/scripts/tabs/product/{detail_view,feature_lines_view,product_ui_shared}.gd`.
- Ölçüm: `docs/tasks/faz_ab/a_calisma/K5_runs/full_run_fix_due_7.log`, `full_run_b2c_fix_due_7.log` (PROBE SHIP,
  PROBE STATE, PROBE CUST satırları).
- Araştırma: `arastirma/R8_URUN_KALITESI.md` (§2, §4, §5, §7), `R1_SOFTWARE_INC.md` (§2.4, §2.5, §7.1),
  `R3_GDT_MGT2.md` (§3, §7.1, §7.2), `R2_STARTUP_COMPANY.md` (§2.4).
- Planlar: `C_PLAN.md` (:98-136, :285-303, :700-712, :931), `D_PLAN.md` (:83-96, :190-200, :469, :495-504),
  `E_PLAN.md` (:64-70, :396-410, :449-456).

---

## İnceleme notu
Kıdemli inceleme, 17 Ekim 2026 (Opus). Repo kodu değişmedi. Belgedeki her değişiklik "(inceleme)" diye işaretli.

1. **Sadakat.** Erdem'in kararlılık ve "deneyim kartı" sözleri birebir aktarılmış; (c) önerisi onaylı diye yazılmamış.
   Tek yanlış okuma: Erdem'in "%70'ler" sözü hesabın başlangıcı içindi, belge onu ürün teriminin değerine gerekçe
   yapıyordu. Düzeltildi (§6.3, §8.2).
2. **C ile çelişki giderildi.** Belge imza anı memnuniyetini bu terimden ve "ilk 4 hafta tabanı"nı C'nin terimi sayıyordu;
   `C_ICERIK_v2.md` başlangıcı sabit 70 yapıp tabanı kaldırıyor. X'in sözleşmesi buna çevrildi.
   (yönetmen, 17 Ekim) İki inceleme paralel koştu; C incelemesi sonra tabanı geri getirdi (70, 8 haftada söner). Geçerli
   olan `C_ICERIK_v2.md` §2.5.1'dir; §6.3 ve §9'a not düşüldü.
3. **Kalibrasyon riski sayıyla yazıldı (en önemli bulgu).** Bugünkü önerilerle MVP'deki ERP'de operasyon alıcısının ürün
   terimi ~13, teknik alıcınınki ~34; 70'ten başlayan hesap ~12. haftada eşiğe iner (§9). Q'nun ilk ölçümü budur.
4. **Terim tavanı ile C'nin ceza tavanı birbirini bilmiyor.** Oran 1,5'te kesildiği için B2B terimi 105'e çıkabilir; C'nin
   40'lık ceza tavanı en iyi terimi 67 sayıyor (§6.3). B2C terimi fiilen en çok 75 (§6.4).
5. **Araştırma.** R8 §2.3 (en zayıf alt puan sonucu çeker), R8 §4 ("rating system confusing", Startup Company'nin gizli
   cezası), R8 §7.1 (Software Inc'te eksen veri alanı yok), R3 §7.2 (hedef önceki en iyiye göre %10-24) ve R1 §1 madde 7
   (2025 yorum sistemi) raporlarda yazdığı gibi.
6. **Ölçek.** (c)'nin kuralları oran; kişi ve hesap sayısından bağımsız. Kademe tavanı (3) EA'da alanları doyurur; belge
   bunu açıkça EA'ya bırakıyor.
7. **Oyuncu.** Ekonominin okuduğu oran oyuncunun gördüğü kare ve kelimedir; görünmeyen model kalmıyor. Ekranda kod adı ya
   da İngilizce terim yok.
8. **D ile uyum.** İş profili sözleşmesi (§8.3) `D_MODEL_v2.md` §3.2 ile birebir; profil eşlemesi ve D'nin sayıları aynı.
9. **Rakip.** (c) rakibin ekonomik etkisini yalnız mevcut "beklenti rakip çıkışıyla yükselir" kuralında tutuyor, yeni rakip
   satırı eklemiyor; Erdem'in "rakip şimdilik kapsam dışı" sözüyle çelişmiyor.
10. **Kapsam sözü.** 36-49 saatlik iş "küçük faz" diye sunuluyordu; söz çıkarıldı (§0, §10).
11. **Sorular** 4'te kaldı, hepsi kapalı uçlu ve önerili; kod adı içermiyor.
