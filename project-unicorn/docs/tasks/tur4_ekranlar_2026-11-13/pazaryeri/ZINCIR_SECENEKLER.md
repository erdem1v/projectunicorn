# Pazaryeri: tek kurucunun zinciri ve çekten sonrası

PAZARYERI, 15 Kasım 2026 gece. Yardımcı yönetmenin istediği belge; Erdem'in 16 Kasım sabahki kararı için. Bütün sayılar
özel kopyada, oyunun kendi koduyla ve oynayan bir botla ölçüldü; hiçbir şey inmedi, commit yok. §1–§6'nın 19 koşusu HEAD
`441735eb` üstünde (15 Kasım akşamı), §7'nin 17 koşusu HEAD `4066c9f5` üstünde (16 Kasım 02:05; OLAYLAR'ın c6'sı ve URUN'un
X7'si içinde, yani playtest 2'nin oynayacağı yapı). Sayılar [WORKING]; ince ayar bu belgenin konusu değil.

## Sonuç

1. **Oynayan bir kurucu kendi kasasıyla Frank'in çekine varabiliyor, ama geç ve yalnız reklamla:** haftada 200 dolar reklamla
   72. hafta, 500 dolarla 53. hafta. Reklamsız ya da haftada 100 dolarla 104 haftada varamıyor.
2. **Hiçbir seçenekte, hiçbir kolda seed'e varılmıyor.** Ölçülen 19 koşunun en iyisinde aylık gelir 6.900 dolarda tepe
   yapıyor; seed kapısı 20.000 dolar. Oyun 104. haftada kapanıyor.
3. **Zinciri kıran her seçenek çeki öne alıyor (72. haftadan 51–69. haftaya) ve ikinci bir duvarı görünür kılıyor:** çekin
   25.000 dolarıyla alınan iki kişi şirketi 30–45 hafta içinde batırıyor. Bugün bu iflas görünmüyor, çünkü çek geç geldiği
   için oyun ondan önce bitiyor.
4. **Önerim:** playtest 2 bu hâliyle oynansın (seçenek 0) ve Erdem oynamadan önce şunu bilsin: pazaryerinde bugünkü sayılarla
   seed gelmez; playtest çeke kadar olan oyunu ve çekten sonraki ilk kararları ölçer. E2'nin "A" cevabı (seçenek 3) playtest'ten
   sonra, çekten sonrasının ayarıyla birlikte insin. Gerekçe §4'te.
5. **Gece ölçümü (§7):** (a) dikkatli oyuncunun var olan hamlesi (iş kalmayınca Geliştirme'yi bırakıp Destek'i almak) zinciri
   kırmıyor; (b) çekten sonra tek bir işe alım şirketi batırmıyor ama bir yılda kendini de ödemiyor, iki işe alım batırıyor;
   (c) **gelir ya da ziyaret üç katına çıkınca seed 104. haftanın hemen dışında kalıyor, beş katında 55. haftada geliyor; "A"
   ile birlikte üç kat yetiyor (65. hafta).** Mağaza kazanımını hızlandırmak tek başına işe yaramıyor.

Haftada 200 dolar reklam veren kurucu, seçeneklere göre (tam tablo §5'te):

| Seçenek | Çek | Seed | Son | Kullanıcı memnuniyeti (ort.) | Yeni kullanıcının tavsiyeden gelen payı | Gelirin tepesi |
|---|---|---|---|---|---|---|
| 0. Bugün (değiştirme) | 72. hafta | yok | 104. hafta, kasa 5.600 dolar ve eriyor | 56 | %2 | 3.300 |
| 0b. Bugün + oyuncu iade süresini 30 güne çeker (var olan kaldıraç) | 64 | yok | 104. haftada iflas | 61 | %7 | 3.750 |
| 1. Tavsiye 40'ta başlar | 59 | yok | 93. haftada iflas | 57 | %13 | 3.000 |
| 2. Tek kurucu Destek'e de bakar | 69 | yok | 101. haftada iflas | 63 | %5 | 3.300 |
| 1 + 2 birlikte | 61 | yok | 96. haftada iflas | 63 | %18 | 3.850 |
| 3. E2 "A" (tavsiye 40 + kategori genişliği) | 51 | yok | 98. haftada iflas | 58 | %17 | 5.800 |

## 1. Zincir, oyuncunun ekranından

Pazaryerini seçen oyuncu 9. haftada v1.0'ı yayınlar, Moda'yı açar, kendini mağaza kazanımına atar. Sonra şunlar olur:

- **Kurucunun iki işi dolar.** Geliştirme ve Satış (mağaza kazanımı Satış işini verir). Ekip'te bir kişi en çok iki sürekli iş
  tutar (`MAX_JOBS_PER_PERSON`), o yüzden kurucu Destek masasını alamaz; oyun üçüncü işi "iş tavanı" diye reddeder.
- **Bildirimler birikir.** Destek'e bakan yok; çeke kadar 46 bildirim bekler. Bir haftalık bildirimden fazlası bekleyince
  kullanıcı defterine "Destek birikti" satırı −10 yazar (satır hemen tavanına varır: tek bir cevapsız bildirim de −10'dur).
- **Kullanıcı memnuniyeti 49–56'da kalır.** 70 taban; defterde üç satır duruyor (gece koşularında basıldı): Destek birikti
  −10, geç teslimat −4, geciken talep −4. İlk Müşteri Temsilcisi gelince 62'ye çıkıyor (ölçüldü). Geç teslimat, teslim oranı
  yüzde 90'ın altındayken yazılıyor; koddan okuduğum sebep oranın Sipariş ve Entegrasyon kademelerine bağlı olması ve o
  adımların Ar-Ge kilidinde durması (doğrulanmadı). Geciken talep satırı konusunun kademesi çıkınca kalkmaz, sıradaki
  konunun adına döner; altı ek özellik konusunun oyunda kartı olmadığı için satır iki tarafta da kalıcıdır (16 Kasım
  düzeltmesi, §9; ilk yazdığım "Talepler'den kart alınınca kalkar" cümlesi yanlıştı).
- **Tavsiye sıfırdır.** Memnun kullanıcının kullanıcı getirmesi 55'in altında sıfır, 100'de tam. 52'de sıfır, 62'de bile
  tamın yüzde 16'sı. Ölçüm: yeni kullanıcının yüzde 0 ile 2'si tavsiyeden. Tür ekranı "Ağ etkisi: her yeni kullanıcı..." der;
  oyunda bu yok.
- **Çekten önce kimse işe alınamaz.** Başlangıç kasası 10.000 dolar; bir Junior ayda 2.900–3.400 dolar. Mağazayı yalnız kurucu
  getirir (haftada 2), kategoriden kategoriye taşınır.
- **30. haftadan sonra geliştirecek iş kalmaz.** Bütün hatların sıradaki adımı Ar-Ge ya da beceri kilidindedir (Sprint'te
  9 kilitli, 0 açık). Olay da gelmez: 30. haftadan çeke kadar 23–36 hafta hiç olay yok.

**Eşikler görünür mü?** Hayır. Oyuncu memnuniyet sayısını ve en ağır satırı görür ("Destek birikti"); tavsiyenin 55'te
başladığını ve mağaza memnuniyetinin 60'ın üstünde hiçbir şeyi değiştirmediğini hiçbir yerde görmez. Bu ölçümlerde mağaza
memnuniyeti 66–70'te kaldı, 60'ın altına hiç inmedi; yani hiçbir etkisi olmadı (OLAYLAR'ın bulgusu doğru).

**Oyuncu kullanıcı memnuniyetini bugün neyle yükseltir?** Destek'e birini koymak +10 (tekken ancak Geliştirme'yi ya da Satış'ı
bırakarak); iade süresi 14 gün +2, 30 gün +4 (mağaza defterine −3 ve −6; mağaza 60'ın üstünde kaldığı için bedeli fiilen yok);
kayıtlı mağaza şartı +3 (Yorumlar ikinci kademede açılır, mağaza kazanımını yavaşlatır); karşılanan talep sekiz hafta +3.

## 2. Seçenekler

### 0. Değiştirme, playtest'te gör

- **Oyuncu ne görür, ne karar verir:** bugünkü oyun. Kararları: reklama ne kadar para, hangi iki iş (Geliştirme, Satış,
  Destek'ten ikisi), iade süresi, hangi kategori ne zaman.
- **Ölçüm:** reklamsız ve 100 dolar: çek yok. 200 dolar: çek 72. 500 dolar: çek 53, kasa on dokuz kez 3.000 doların altına
  inip reklamı durdurdu. İade süresini 30 güne çeken 200 dolarlık kol: çek 64, memnuniyet 61.
- **Dikkatli oyuncunun hamlesi (gece ölçüldü, §7.1):** geliştirecek iş kalmayınca kurucu Geliştirme'yi bırakıp Destek'i alır,
  kart açılınca döner. Zinciri kırmıyor: memnuniyet 54–56'da kalıyor (seçenek 2'de 63), çek 200 dolarlık kolda 77. hafta.
  Sebep: araştırma ve düzeltme kartları birkaç haftada bir açıldığı için kurucu Destek'te bir hafta kalıp dönüyor (104 haftada
  8–20 değişim) ve bildirim yine birikiyor. Yani seçenek 2'nin verdiğini var olan hamle vermiyor.
- **Kod:** yok.
- **Bedeli:** playtest'te Erdem büyük ihtimalle çeke 50–70. haftada varır, seed'e varamaz. Playtest çeke kadar olan oyunu
  ölçer; "seed'e kadar tempo" sorusu cevaplanmaz ama cevabı zaten bu belgede.

### 1. Tavsiye 40'ta başlar (zincirin dördüncü halkası)

- **Kural:** memnun kullanıcının kullanıcı getirmesi 40'ta başlar, 80'de tam olur (bugün 55 ve 100). Bu koşularda kullanıcı
  memnuniyeti 49–70 arasında gezdi; bugünkü eşik neredeyse hep kapalı.
- **Oyuncu ne görür:** aynı ekran; "kendiliğinden gelen" ziyaret çubuğu kullanıcı sayısıyla birlikte büyür. Memnuniyet 52'de
  de tavsiye çalışır (tamın yüzde 30'u). Yeni karar yok; memnuniyeti yükseltmenin karşılığı artar.
- **Ölçüm:** reklamsız çek yok; 100 dolar çek 89; 200 dolar çek 59 ve 93. haftada iflas. Tavsiye payı yüzde 10–13.
- **Kod:** `data/product/marketplace.json` iki sayı, PRD §3'te bir satır, `marketplace_probe.gd`'de beklenen değerler. Sahibi
  PAZARYERI. E2'nin hazır değişikliğinin yarısı. Bir günde iner. Sabit değişikliği: onay bekliyor.
- **Bedeli:** oyunu biraz kolaylaştırır (çek 13 hafta öne). Destek'i ihmal etmenin cezası hafifler: 52'de de büyüyorsun.

### 2. Tek kurucu Destek'e de bakar (birinci halka)

- **Kural:** şirkette çalışan yokken kurucu, işleri ne olursa olsun gelen bildirimleri okur (bugün yalnız hiçbir işi yokken
  okuyor). İlk çalışan gelince bu biter: Destek'e biri atanmazsa bildirim birikir.
- **Oyuncu ne görür:** tekken "Destek birikti" satırı çıkmaz, kullanıcı memnuniyeti 62–63'te durur. İlk işe alımda yeni bir
  karar doğar: ilk kişi Destek'e mi, Satış'a mı? Bugün bu karar yok, çünkü ceza ilk günden beri zaten yazılı.
- **Ölçüm:** reklamsız çek yok; 100 dolar çek 99; 200 dolar çek 69 ve 101. haftada iflas. Memnuniyet 63, tavsiye payı yüzde 5
  (eşik 55'te kaldığı için 63'te bile tavsiye zayıf). İlk yıl gelir bugünkünden düşük (52. haftada 1.640'a karşı 2.040);
  olası sebep okunan bildirimlerin düzeltme kartı açması ve kurucunun sprint'inin onlara gitmesi (doğrulanmadı).
- **Kod, iki yol:** (a) `support_system.gd` `founder_passive_care` tek satır; Destek'in sahibi URUN; ERP'yi de değiştirir
  (tek kurucu ERP'de de bildirim okur), `support_*` vakaları ve `run_gate` ister. (b) Yalnız pazaryerinde:
  `marketplace_system.gd` `world()` içinde tek satır ("çalışan yokken cevapsız pay 0"); sahibi PAZARYERI, ERP'ye dokunmaz;
  ölçülmedi (bildirimler yine birikir, yalnız ceza yazılmaz). İkisi de bir günde iner.
- **Bedeli:** tek başına tempoyu neredeyse değiştirmiyor (çek 72'den 69'a). Değeri adalet: bugün tek kurucu bu −10'dan ancak
  bir işini bırakarak kaçabiliyor. Ama bu bir karar da sayılabilir ("hangi iki iş"); playtest'te Erdem'in "Destek birikti"yi
  görüp ne yaptığı bunu söyler.

### 3. E2 "A": tavsiye 40'ta başlar ve kategori açmak siparişi artırır

- **Kural:** seçenek 1 ile birlikte, dolu her yeni kategori kullanıcının haftalık siparişini büyütür (küp kök). Erdem'in
  sayfasında cevap bekleyen soru bu; önerim "A" idi.
- **Oyuncu ne görür:** ikinci kategoriyi doldurunca Moda'nın siparişi düşmez, toplam sipariş artar; tavsiye çalışır.
- **Ölçüm:** reklamsız çek 103; 100 dolar çek 63 ve 90. haftada iflas; 200 dolar çek 51 ve 98. haftada iflas; 500 dolar
  çek 46 ve 93. haftada iflas. Tavsiye payı yüzde 10–17. Gelirin tepesi 5.800–6.900 dolar: ölçülenlerin en yükseği, yine
  seed'in üçte biri.
- **Kod:** hazır (beş dosyada 24 değişiklik, altı bozma yazılı), bugünkü HEAD'e uygulanıyor. Sahibi PAZARYERI. Doğrulaması
  (pazaryeri ölçüm betiği, hedefli vakalar, inceleme) bir kapı geçişi ister; bir günde iner.
- **Bedeli:** en çok kolaylaştıran seçenek (çek 21 hafta öne). İflası 104 haftanın içine çeker: çekten sonrası ayarlanmadan
  inerse oyuncunun gördüğü "takıldım" değil "battım" olur.

## 3. İkinci duvar: çekten sonra

**200 dolarlık kol "A" ile neden 98. haftada iflas etti?** Büyüdü ama gidere yenildi; "A"nın kendisinden değil.

- 51. haftada çek geldi (25.000 dolar). Bot 52. haftada bir Müşteri Temsilcisi (ayda 3.050), 53. haftada bir Satış Temsilcisi
  (ayda 3.375) aldı. Botun kuralı: kasa altı aylık gideri karşılıyorsa al.
- Aylık gider 1.100'den 7.800 dolara çıktı (iki maaş, reklam, sunucu). Aylık gelir 2.530'du; 86. haftada 5.820'ye çıktı.
  Gelir gideri hiç geçmedi.
- Kasa 32.600'den 86. haftada 2.600'e indi; reklam durdu, gelir 5.340'a geriledi; 93. haftada kasa eksiye düştü, dört
  haftalık sayaçtan sonra 98. haftada iflas.
- "A"sız aynı iki işe alım 73 ve 74. haftada geldi; oyun 104. haftada kasada 5.600 dolarla ve haftada 1.000 dolar eriyerek
  bitti. Oyun sürseydi kasa 110. hafta dolayında biterdi. "A" iflası yaratmadı; çeki öne aldığı için iflas oyunun içine girdi.

**Ölçek sorunu.** Bir kullanıcı ayda 2 ile 4 dolar komisyon getiriyor. Bir Junior'ın maaşı 900–1.500 kullanıcının geliri.
Koşuların sonunda 600–1.600 kullanıcı var. Seed için 20.000 dolar, yani 5.000–8.000 kullanıcı gerekiyor; en iyi koşu
haftada 20 kullanıcı kazanıyor. Bu fark oyuncunun ustalığıyla kapanacak gibi durmuyor [GÖRÜŞ]: bot zayıf bir oyuncu (§6), iyi
bir insan çeki öne alır, ama seed için gelirin üç ile beş kat olması gerekiyor.

Bu belgedeki seçeneklerin hiçbiri bu duvara dokunmuyor. Bu, playtest'ten sonraki ayarın (Erdem'in "kalibrasyon playtest'te"
kararı) asıl konusu: gelirin ölçeği, çekin büyüklüğü, işe alımın geri dönüşü. Buraya sayı önermiyorum.

## 4. Önerim

**Playtest 2 seçenek 0 ile, bugünkü hâliyle oynansın; E2 "A" playtest'ten sonra, çekten sonrasının ayarıyla birlikte insin.**

- Hiçbir seçenek seed'i getirmiyor; playtest'in cevaplayabileceği soru her seçenekte aynı: çeke kadar olan oyun.
- Çeki öne alan her seçenek iflası oyunun içine çekiyor. Çekten sonrası ayarlanmadan bunlardan birini indirmek playtest'i
  daha iyi yapmaz, yalnız sonunu değiştirir.
- Yarın sabah kapı OLAYLAR'ın c6 ve c8'i ile URUN'un X7'si için gerekli; onlar oyuncunun gördüğü yanlış metinleri kapatıyor.
- Erdem "kalibrasyon playtest'te" dedi; bu ölçüm playtest'in neye bakacağını söylüyor, playtest'in yerini tutmuyor.

**Erdem yine de playtest'ten önce bir şey isterse:** seçenek 3 ("A"). En büyük etki onda, kod hazır, soru zaten onun
masasında ve tür ekranının "ağ etkisi" vaadini gerçek yapıyor. Seçenek 1 onun yarısı; seçenek 2 tempoyu değiştirmiyor.

**Ne yapmayacağız:** çek ve seed eşiklerini pazaryeri için oynatmak (Erdem'in kararı: kapılar aylık gelirde kalır; sayı
ayarı playtest'ten sonra), iş tavanını değiştirmek, çekten önce işe alım için yeni bir mekanik.

## 5. Playtest için soru ve bütün koşular

Erdem'e oynamadan önce söylenecek tek cümle: "Pazaryerinde bugünkü sayılarla seed gelmiyor; çeke kadar olan oyuna ve çek
geldikten sonra parayı neye harcadığına bak."

Sorular: (1) "Destek birikti" satırını gördün mü, ne yaptın? (2) 30. haftadan çeke kadar ne yaptın, sıkıldın mı? (3) Çek
geldiğinde ilk kimi aldın, neden; kasanın eridiğini ne zaman fark ettin? (4) Takıldığını ne zaman ve neyden anladın?

Bütün koşular (104 hafta, hata satırı hepsinde 0; "yok" varılmadı demek; gelir aylık, dolar):

| Seçenek | Reklam | Çek | Seed | Son | Kull. memn. | Tavsiye payı | İlk işe alım | Gelir 52. hf | Gelir tepe | Olay | En uzun olaysız |
|---|---|---|---|---|---|---|---|---|---|---|---|
| Bugün | pasif (tek kategori) | yok | yok | 104 | 53,8 | ölçülmedi | yok | 701 | 836 | 16 | 36 hf |
| Bugün | 0 | yok | yok | 104 | 53,7 | %0,1 | 99 | 871 | 1.710 | 16 | 36 |
| Bugün | 100 | yok | yok | 104 | 53,4 | %0,0 | 101 | 1.545 | 2.393 | 16 | 36 |
| Bugün | 200 | 72 | yok | 104 | 56,4 | %2,4 | 73 | 2.039 | 3.286 | 20 | 36 |
| Bugün | 500 | 53 | yok | 104 | 53,4 | %0,0 | yok | 2.360 | 4.240 | 21 | 23 |
| Bugün + iade 30 gün | 200 | 64 | yok | 104 iflas | 61,2 | %6,6 | 65 | 2.055 | 3.750 | 20 | 34 |
| 1. Tavsiye 40 | 0 | yok | yok | 104 | 54,0 | %9,6 | 96 | 905 | 1.917 | 16 | 36 |
| 1. Tavsiye 40 | 100 | 89 | yok | 104 | 54,5 | %10,6 | 90 | 1.697 | 2.676 | 21 | 36 |
| 1. Tavsiye 40 | 200 | 59 | yok | 93 iflas | 57,2 | %12,6 | 60 | 2.177 | 2.983 | 15 | 30 |
| 2. Tek kurucu Destek | 0 | yok | yok | 104 | 63,1 | %4,8 | 102 | 587 | 1.832 | 18 | 38 |
| 2. Tek kurucu Destek | 100 | 99 | yok | 104 | 63,0 | %5,2 | 100 | 1.233 | 2.638 | 19 | 38 |
| 2. Tek kurucu Destek | 200 | 69 | yok | 101 iflas | 63,0 | %5,3 | 70 | 1.643 | 3.286 | 24 | 38 |
| 1 + 2 | 0 | yok | yok | 104 | 63,1 | %16,8 | 97 | 608 | 2.240 | 18 | 38 |
| 1 + 2 | 100 | 77 | yok | 104 | 63,0 | %17,5 | 78 | 1.375 | 3.883 | 22 | 38 |
| 1 + 2 | 200 | 61 | yok | 96 iflas | 63,1 | %18,2 | 62 | 1.928 | 3.847 | 21 | 34 |
| 3. E2 "A" | 0 | 103 | yok | 104 | 54,9 | %10,4 | 87 | 1.040 | 2.538 | 17 | 36 |
| 3. E2 "A" | 100 | 63 | yok | 90 iflas | 56,5 | %12,4 | 64 | 1.951 | 4.229 | 20 | 33 |
| 3. E2 "A" | 200 | 51 | yok | 98 iflas | 58,3 | %17,0 | 52 | 2.528 | 5.822 | 18 | 21 |
| 3. E2 "A" | 500 | 46 | yok | 93 iflas | 56,1 | %13,1 | 69 | 3.373 | 6.906 | 24 | 19 |

Eşikler: çek 2.500 dolar aylık gelirde gelir ve 25.000 dolar getirir; seed kapısı 20.000 dolar. Karşılaştırma için eski not
uygulamasının koşusu (kapının bugün koştuğu): çek 13. hafta, seed 33. hafta, 65 olay, en uzun olaysız dönem 5 hafta.

## 6. Ölçüm, botun sınırları, düzeltmeler

**Bot ne oynar:** v1.0'da ilk kategoriyi açar; bütün açık kategoriler mağazasını bulunca sıradakini açar; kurucuyu ve Satış
Temsilcilerini mağazası eksik kategoriye koyar; kurucuyla tek bir arama reklamı yürütür (kolun bütçesi; kasa 3.000 doların
altındayken durur; haftalık komisyonun yüzde 30'u daha büyük bir basamak alıyorsa onu verir); çekten sonra sırayla Müşteri
Temsilcisi (bildirim birikmişse), Satış Temsilcisi, geliştirici alır (kasa altı aylık gideri karşılıyorsa).

**Bot ne oynamaz (insan daha iyisini yapabilir):** Talepler'den kart almaz (karşılanan talebin +3'ü hiç yok; geciken talep
−4'ünü insan da kapatamıyor, §9); komisyona ve politikalara dokunmaz (iade süresi kolu dışında); kampanya açmaz; ikinci reklam satırı açmaz
(kurucu yalnız birini yürütebiliyor); işe alımın geri dönüşünü hesaplamaz, kasası erirken kimseyi çıkarmaz; kurucunun işini
değiştirmez.

**Düzeltmeler.** (1) `AG_ETKISI_SECENEKLER.md`'deki "çek yayından 25, seed 71 hafta sonra" ve "A ile 23 / 55 / 79" sayıları
kasayı saymayan sabit bir plandan geliyordu (çekten önce haftada 500 dolar reklam ve 16. haftada temsilci varsayıyordu).
Gerçek kasayla çek yayından 44–63 hafta sonra, seed yok. O belgedeki seçeneklerin sıralaması değişmedi, haftaları geçersiz.
(2) Kapının `full_run_b2c` koşusu pazaryerini oynamıyor (botunda türü hâlâ not uygulaması); `run_gate`'in üç koşusu bugüne
kadar hiç pazaryeri oynamadı. Pazaryerini kapıya sokan bot değişikliği playtest'ten sonra ilk inecek iş.

**Kayıt.** Ham kayıtlar repoda değil; ölçümü yapan oturumun geçici çalışma klasöründeydi:
koşular `kosu_<varyant>_<kol>.probe` ve `.log` (varyantlar `a3` bugün, `d30`, `t40`, `tk`, `iki`, `e2`; pasif koşu `mp1`, not
uygulaması `not1`), bot yaması `aktif_bot.py`, yalnız ölçüm ekleri `olcum_ek.py`, varyant yamaları `v_ortak.py`, koşucular
`bot_kosu.sh`, `varyant.sh`, `pencere.sh`, özet `ozet.py`. Tavsiye payı, her haftanın kendiliğinden gelen yeni kullanıcısı ×
o haftaki tavsiye ziyaretinin kendiliğinden gelen ziyaretteki payı olarak hesaplandı (yaklaşık; modelin kendi formülüyle).

## 7. Gece ölçümleri (16 Kasım 02:05, HEAD `4066c9f5`)

17 koşu, hepsi 104 hafta, hata satırı 0, haftada 200 dolar reklam (7.1'in ilk iki satırı dışında). Kıyas satırları §5'te, bir
önceki HEAD'de ölçüldü; c6 olay dizisini değiştirdiği için birkaç haftalık farkı gürültü sayın.

### 7.1 Dikkatli oyuncu: kurucu iş kalmayınca Destek'e geçer (kod değişmeden)

| Reklam | Çek | Seed | Kull. memn. | Tavsiye payı | Kurucunun iş değişimi | Gelir 52. hf | Gelir 104. hf | Olay | En uzun olaysız |
|---|---|---|---|---|---|---|---|---|---|
| 0 | yok | yok | 54,2 | %0,4 | 18 kez | 867 | 1.649 | 17 | 23 hf |
| 100 | yok | yok | 53,9 | %0,2 | 20 kez | 1.540 | 2.401 | 17 | 23 |
| 200 | 77 | yok | 56,0 | %2,3 | 8 kez (78. haftada temsilci geldi) | 2.031 | 3.361 | 17 | 23 |

Sonuç: var olan hamle seçenek 2'nin yerini tutmuyor. Ölçmediğim uç: kurucunun Geliştirme'yi tamamen bırakması (araştırma ve
düzeltme kartlarını da koşmaması). Olay sayısı c6'dan sonra da aynı düzeyde (17 olay; en uzun olaysız dönem 36 haftadan 23'e indi).

### 7.2 Çekten sonraki ilk işe alım ("A" üstünde: çek 51. hafta, sonrasında 53 hafta gözlem)

| İlk ve tek işe alım (52. hafta) | Gelir 104. hf | Kasa 104. hf | Kullanıcı 104. hf | Kull. memn. | Son |
|---|---|---|---|---|---|
| Kimse | 4.950 | 67.000 | 1.280 | 53,4 | ayakta |
| Satış Temsilcisi | 6.480 | 35.400 | 1.650 | 58,4 | ayakta |
| Müşteri Temsilcisi | 6.160 | 33.100 | 1.570 | 58,6 | ayakta |
| Geliştirici | 5.950 | 23.800 | 1.520 | 56,8 | ayakta |
| İkisi birden: Müşteri + Satış (§5'in "A" satırı) | 5.340 | iflas | | 58,3 | 98. haftada iflas |

- Tek işe alım şirketi batırmıyor. Ama bir yılda kendini de ödemiyor: en iyisi (Satış Temsilcisi) aylık geliri 1.530 dolar
  artırıyor, maaşı 3.375 dolar; 53 haftada kasa "kimseyi alma" koluna göre 31.600 dolar geride.
- İki işe alım ayda ortalama 3.500 dolar açık veriyor (başta 5.300, gelir büyüdükçe 2.000); çekle dolan kasa buna dokuz ay
  dayanıyor.
- Oyuncunun ekranında: çek gelir, işe alırsın, gelir artar ama Finans'ta net her ay eksidir; bunu çekten önce görmenin yolu yok.

### 7.3 Ölçek: ne kaç kat olursa seed gelir (bugünkü kod, haftada 200 dolar reklam)

| Ne ölçeklendi | Kat | Çek | Seed | Gelir 104. hf | Kasa 104. hf | Batış | Kullanıcı 104. hf | Olay |
|---|---|---|---|---|---|---|---|---|
| Hiçbiri (§5) | 1 | 72 | yok | 3.290 | 5.600 | yok, eriyor | 1.250 | 20 |
| **Gelir** (her siparişin sepeti) | 2 | 40 | yok | 6.160 | −3.200 | 104'te kasa eksi | 1.250 | 24 |
| Gelir | 3 | 30 | yok (17.500 ile eşiğin dibinde) | 17.520 | 4.900 | yok | 2.200 | 24 |
| Gelir | 5 | 25 | **55** | 70.900 | 239.000 | yok | 4.170 | 44 |
| **Ziyaret** (taban ilgi, reklamın getirdiği ziyaret) | 2 | 39 | yok | 6.240 | 800 | sınırda | 2.530 | 24 |
| Ziyaret | 3 | 30 | yok (17.800) | 17.780 | 8.200 | yok | 6.740 | 26 |
| Ziyaret | 5 | 24 | **56** | 67.600 | 199.000 | yok | 20.350 | 44 |
| **Mağaza kazanımı** (temsilcinin haftalık mağazası) | 2 | 53 | yok | 2.960 | iflas | 93. haftada iflas | 1.190 | 15 |
| Mağaza kazanımı | 3 | 48 | yok | 2.930 | 2.400 | sınırda | 1.170 | 19 |
| Mağaza kazanımı | 5 | 46 | yok | 3.350 | 12.500 | yok | 1.270 | 24 |
| **"A" + gelir** | 3 | 30 | **65** | 83.200 | 217.000 | yok | 5.270 | 39 |

**Aralık.** Seed'in 104 haftanın içine girmesi için gelirin ya da ziyaretin **üç ile beş kat** olması gerekiyor: üç katta seed
tavanın hemen dışında (104. haftada 17.500 dolar), beş katta 55. haftada. "A" ile birlikte **üç kat** yetiyor (65. hafta).
İki kat hiçbir şeyi çözmüyor: çek 40. haftaya geliyor, sonra şirket işe alımların gideriyle kasayı bitiriyor. Series A (120.000
dolar) hiçbir koşuda 104. haftaya kadar gelmedi; en yakını "A" + gelir × 3 ile 83.200 dolar.

**Her ölçeğin oyuncunun ekranında değiştirdiği:**
- **Gelir:** Kategoriler'de sepet tutarı ve satış hacmi, Finans'ta komisyon büyür; kullanıcı, ziyaret ve mağaza sayıları aynı
  kalır. Gerçeklik bedeli: Moda'nın 38 dolarlık sepeti üç katta 114 dolar olur. Aynı geliri komisyon oranı ya da sipariş
  sıklığı da verir; onlar ölçülmedi (komisyon mağazayı zorlar, sıklık sipariş ve mağaza başına sipariş sayılarını değiştirir).
- **Ziyaret:** ziyaret çubuğu, kullanıcı ve sipariş sayıları büyür (beş katta 104. haftada 20.000 kullanıcı); reklam doları aynı
  parayla daha çok ziyaret alır; sepet aynı kalır. Bildirim ve sunucu yükü de kullanıcıyla büyür. Küçük sayılar sorunu ("0
  sipariş", "6 kullanıcı") ilk haftalarda hafifler.
- **Mağaza kazanımı:** kategoriler daha çabuk dolar (çek 72'den 46–53'e gelir), sonra hiçbir şey değişmez: kullanıcı ve gelir
  aynı yerde düzleşir. Darboğaz mağaza değil, kullanıcı.

**Yan gözlem (olay).** Ölçek büyüyünce olay da geliyor: beş katlı kollarda 104 haftada 44 olay, en uzun olaysız dönem 9–19 hafta
(bugün 17–20 olay, 23–36 hafta). Olay havuzunun inceliği büyük ölçüde ilerlemenin yavaşlığından.

**Bu tablo ne değildir:** bir ayar önerisi değil. Kat sayıları tek bir düğmenin kaba adımları; gerçek ayar birkaç sayıyı birlikte
oynatır (sepet, sıklık, taban ilgi, tıklama bedeli, maaş, çekin tutarı, eşikler) ve playtest'in bulgusuyla yapılır. Kayıt:
`bot\kosu_<etiket>_full_run_b2c.probe` (etiketler `swap`, `ha_yok`, `ha_satis`, `ha_destek`, `ha_gelistirici`, `sepet2/3/5`,
`ziyaret2/3/5`, `magaza2/3/5`, `e2sepet3`), listeler `bot\liste_gece.txt`, koşucu `bot\pencere_liste.sh`.

## 8. Playtest ayarı "P": hazırlık (16 Kasım gece; Godot'suz, commit yok)

Yardımcı yönetmen Erdem'e iki seçenek götürüyor: **0** (bugünkü hâl) ve **P** ("A" + gelir × 3; §7.3'te ölçülen: çek 30, seed 65,
batış yok). Bu bölüm P seçilirse sabahın kaybedilmemesi için hazırlık. Hiçbir şey inmedi; kod yalnız çalışma klasöründe.

### 8.0 Benim görüşüm: 0 mı, P mi

Akşam 0'ı üç gerekçeyle önermiştim; ikisi artık geçerli değil. Çeki öne alan her seçenek şirketi batırıyordu: P batırmıyor. Kapı
c6 ve X7 için gerekliydi: ikisi de indi. Geriye kalan gerekçem şu: **P tek bir bot kolunda, tek gecede bulunmuş bir sayı ve
oyuncunun gördüğü her pazaryeri sayısını playtest günü değiştiriyor.** Bot zayıf bir oyuncu (Talepler'den kart almıyor,
kampanya ve komisyon kullanmıyor); o bile P'de oyunu 217.000 dolar kasayla bitiriyor. Erdem bottan iyi oynar; P'de "para
yağıyor, karar kalmadı" hissine varabilir ve o zaman playtest bu kez ters yönden aynı sayı sorununu ölçer. İkinci çekincem
gerçeklik: gelir × 3 Moda'nın sepetini 114, Elektronik'inkini 285 dolar yapar; Erdem'in "gerçek sektör" kuralına ters düşen
tek sayı bu olur. **Yine de 0'da ısrar etmiyorum.** 0'ın bedeli süre değil kapsam: Erdem 3× hızda çölü beş dakikada geçer, ama
pazaryerinde işe alımı, seed'i ve olayların çoğunu hiç görmez. P'ye şu iki şartla katılırım: (1) düğme sepet değil ziyaret olsun
(sepet ve sipariş sıklığı gerçek kalır; ölçeklenen iki sayı PRD'nin zaten "playtest kalibrasyon girdisi" dediği taban ilgi ve
tıklama bedelidir; ilk haftaların "6 kullanıcı, 0 sipariş" sorunu da hafifler); (2) inmeden önce "A" + ziyaret × 3 üç reklam
koluyla ölçülsün (ölçülmedi; beş koşu, dört dakika). Şartlar tutmazsa ya da iniş öğleden sonraya sarkarsa 0.

### 8.1 "Gelir × 3" oyunda hangi sabit

Botun düğmesi oyunun kendi sabitidir: altı kategorinin `basket` değeri (`data/product/categories.json:3–13`; 38, 95, 32, 22, 28,
45 dolar; üç katı 114, 285, 96, 66, 84, 135). Yan etkileri: (a) mağazanın kargo payı küçülür (kargo ücreti 3 dolar sabit:
`marketplace_model.gd:216, 224`), mağazalar daha rahat bölgede durur; (b) kampanya bedeli ve Premium indirimi de üç kat olur
(`marketplace_model.gd:1263, 1020`); (c) reklam doları üç kat gelir getirir, yani E2 belgesinde "korunan gerilim" dediğim "reklam
ilk aylarda zarardır" kalkar (ilk kademede 0,74'ten yaklaşık 2,2'ye; hesap, ölçülmedi). Aynı geliri veren öbür sabitler
ölçülmedi: başlangıç komisyonu (`start_commission_pct`; mağazayı zorlar) ve sipariş sıklığı (`order_freq`; yılda 7,5 siparişi
22'ye çıkarır).

"Ziyaret × 3"ün sabitleri: `base_interest` ve `ad_pool` (`data/product/categories.json:4–14`) üç kat, altı reklam türünün `cpc`
değeri üçte bir (`data/marketing/channels.json:8–13`). (c) maddesi bunda da geçerli: reklam doları üç kat ziyaret alır.

### 8.2 Kopyada hazır olan

İki anlık görüntü, bugünkü HEAD'e (`4066c9f5`) göre tabanlarıyla (çalışma klasöründe `e2\`):
- `snap_p_gelir` + `base_p_gelir` + `snap_p_gelir.liste`: "A"nın beş dosyası (24 değişiklik) + `categories.json` (altı sepet × 3).
- `snap_p_ziyaret` + `base_p_ziyaret` + `snap_p_ziyaret.liste`: "A" + `categories.json` (taban ilgi ve reklam havuzu × 3) +
  `channels.json` (altı tıklama bedeli ÷ 3: 0,1 · 0,083 · 0,05 · 0,117 · 0,1 · 0,167).
Sabitler [WORKING]; commit mesajı "playtest ayarı, onay bekliyor" diye yazılır ve playtest'ten sonra ya onaylanır ya geri alınır.
Yalnız "A" isteyen için `snap_e2` ayrıca duruyor.

### 8.3 Hangi vakalar kırılır, iniş kaç dakika

- **Dün akşamki 83'ün içinden kırılacak vaka görünmüyor:** o liste pazaryeri ekonomisini okumuyor. Pazaryerini okuyan 25 smoke
  vakası (`marketplace_*`) dün kapıda koşan 42'nin içindeydi.
- **25 pazaryeri vakası:** okuduğum kadarıyla para beklentileri ya fikstürün kendi yazdığı sayılar ya da sepeti config'ten
  okuyan hesaplar (`endgame_smoke.gd:3710`); sepet ya da ziyaret değişince kırılacak sabit bir sayı bulamadım. Kesin değil:
  okuyarak, koşmadan.
- **Pazaryeri ölçüm betiği (`marketplace_probe.gd`, 70 beklenti):** "A"nın kendi 11 beklentisi hazır. Sepet değişirse kargo
  payını sabit oranla bekleyen maddeler (300, 366–368, 382. satırlar çevresi) oynayabilir; ziyaret değişirse taban ilgiyi sabit
  sayıyla bekleyen maddeler. Kesin liste tek bir koşuyla çıkar (bir dakika).
- **Pazarlama vakaları (sahibi DUZELTME):** ziyaret seçeneği tıklama bedelini değiştirir; kanal vakalarında sabit ziyaret sayısı
  bekleyen varsa kırılır. Sepet seçeneği onlara dokunmaz.
- **Süre (Erdem 09:00'da "P" derse):** taze kopya ve içe aktarma 6 dk · ölçüm betiği ve 25 vaka 20 dk · beklenti düzeltmesi
  15 dk · "A"nın altı bozması 10 dk · botla üç kol 3 dk · tek inceleme ve düzeltme turu (yuva dışında) 20 dk · kapı geçişi
  28 dk · `run_gate` 3 dk. **Yuvada yaklaşık 70 dakika, duvar saatiyle iki saat: 11:00–11:30'da iner**, yuva sıra beklemezse.
  `run_gate` etkilenmez (botu pazaryerini oynamıyor).

### 8.4 Ekranda ne değişir

- **P (gelir):** Kategoriler'de sepet ve satış hacmi, Finans'ta komisyon üç kat; çek 72. hafta yerine 30. hafta dolayında gelir.
  **Kullanıcı sayısı ilk aylarda aynı küçük sayılarda kalır** (yayından sekiz hafta sonra 6–40 kullanıcı, haftada 2–13 sipariş);
  yalnız "0 sipariş ama 2 dolar" satırı "6 dolar" olur. Kullanıcı sonradan büyür (104. haftada 5.300), çünkü gelir reklama ve
  işe alıma döner.
- **P (ziyaret):** ziyaret çubuğu, kullanıcı ve sipariş sayıları baştan üç kat; sepet ve sıklık aynı. Tek başına ölçümü §7.3'te
  (çek 30, seed yok, 104. haftada 6.700 kullanıcı); **"A" ile birlikte ölçülmedi.** Sepet ile ziyaret tek başlarına her katta
  neredeyse aynı sonucu verdi (6.160'a 6.240, 17.520'ye 17.780, 70.900'e 67.600), o yüzden "A" + ziyaret × 3'ün "A" + gelir × 3'e
  (seed 65) yakın çıkmasını bekliyorum, ama bu tahmin; "A" tavsiyeyi kullanıcı sayısına bağladığı için daha hızlı da çıkabilir.
- **Bu eksik ölçüm yapıldı, sonucu §8.5'te.** İlk hâli: "A" + ziyaret × 3 üç kolla (reklamsız, 100, 200) ve "A" + gelir × 3'ün
  eksik iki kolu (reklamsız, 100). Reklam vermeyen oyuncunun P'de de takılıp takılmadığını ancak bu söyler.

### 8.5 P'nin iki düğmesi "A" ile ölçüldü (16 Kasım 02:22, HEAD `4066c9f5`; altı koşu, hata satırı 0)

| Düğme | Reklam | Çek | Seed | 104. hf kasa | Kasa ÷ aylık gider | Gelir 104. hf (aylık gider) | Çalışan | Olay | En uzun olaysız | Yayından 8 hf sonra: kullanıcı / haftalık sipariş |
|---|---|---|---|---|---|---|---|---|---|---|
| **"A" + ziyaret × 3** | 0 | 43 | yok | 5.700 | 0,3 | 13.650 (17.100) | 5 | 30 | 15 hf | 19 / 8 |
| "A" + ziyaret × 3 | 100 | 34 | **63** | 177.900 | 3,9 | 77.900 (45.700) | 10 | 45 | 10 | 76 / 27 |
| "A" + ziyaret × 3 | 200 | 30 | **64** | 252.500 | 6,0 | 83.100 (42.200) | 10 | 39 | 13 | 126 / 44 |
| **"A" + gelir × 3** | 0 | 49 | yok | 5.300 | 0,3 | 18.250 (16.000) | 5 | 26 | 19 | 6 / 2 |
| "A" + gelir × 3 | 100 | 36 | **66** | 237.500 | 5,5 | 82.300 (43.400) | 10 | 44 | 12 | 23 / 8 |
| "A" + gelir × 3 | 200 | 30 | **65** | 217.300 | 5,0 | 83.200 (43.600) | 10 | 39 | 24 | 39 / 13 |
| Bugün (§5, §7.1) | 0 / 200 | yok / 72 | yok | 15.700 / 5.600 | | 1.120 / 3.290 | 2 | 16–20 | 23–36 | 6 / 2 ve 39 / 13 |

Hepsi 104. haftada kapanıyor; iflas yok. Series A (120.000) hiçbir kolda gelmedi.

- **İki düğme "A" ile aynı tempoyu veriyor** (reklamlı kollarda çek 30–36, seed 63–66). Tahminim tuttu; fark ekranda.
- **Ziyaret düğmesi ilk haftaların küçük sayılarını üç kat büyütüyor, tam çözmüyor:** yayından sekiz hafta sonra reklamsız
  oyuncuda 6 kullanıcı ve haftada 2 sipariş yerine 19 kullanıcı ve 8 sipariş; 200 dolarlık kolda 39 / 13 yerine 126 / 44. Gelir
  düğmesinde bu sayılar bugünküyle aynı kalıyor. 104. haftada ziyarette 15.000–16.000, gelirde 5.200 kullanıcı.
- **Reklam vermeyen oyuncu P'de takılmıyor ama seed'e de varamıyor:** çek 43–49. hafta, beş kişilik ekip, 104. haftada gelir
  13.650–18.250 (eşik 20.000), kasa bir haftalık gider kadar. Yani P'de de reklam bir seçim değil zorunluluk.
- **"Para yağıyor" ölçüsü.** Reklamlı kollarda seed'den sonra gelir gideri geçiyor; 104. haftada gelir giderin iki katı, kasa
  4–6 aylık gider, her ay 32.000–41.000 dolar artıyor. Botun işe alım merdiveni on kişide bittiği için son 15–20 haftada kasa
  bir karara bağlanmadan büyüyor (100.000'den 250.000'e). Botun hamlesiz geçen en uzun dönemi iki hafta (reklamsız gelir
  kolunda çekten önce sekiz hafta); yani "karar kalmadı" dönemi yok, ama son çeyrekte baskı da yok. İnsan bu parayı Series A
  için işe alıma ve reklama yatırır; yatırmazsa "kasa artıyor" hissi doğar. Playtest sorusu: "seed'den sonra kasan büyürken
  ne yaptın, baskı hissettin mi?"
- **Olay:** P'de 26–45 olay, en uzun olaysız dönem 10–24 hafta (bugün 16–20 olay, 23–36 hafta).

**Tıklama bedeli yalnız pazaryerini mi etkiler?** Evet. `channels.json:8–13` `market.kinds` bloğunun içindedir ve onu yalnız
pazaryeri yolu okur (`marketing_system.gd:470` `base_click_cost`, `:477` `ad_slots`, `:482`, `:549`). ERP'nin Pazarlama'sı ayrı
bloğu okur (`erp.*`: `marketing_system.gd:116–383`). `base_interest` ve `ad_pool` zaten pazaryerinin kategori dosyasındadır.
Ölçeği sınırlamak için ek iş gerekmiyor.

**DUZELTME'nin kanal vakaları.** Tıklama bedelini ya da kanalın ziyaretini okuyan dört vaka var:
`marketing_market_saturation_raises_cost`, `marketing_market_visits_reach_close`, `marketing_market_quality_weighs_visits`,
`marketing_market_content_builds_and_fades`. Okuduğum kadarıyla beklentileri sabit sayı değil, sıralama ve config'ten okunan
oranlar (ör. `base * 0.8`, `ziyaret == satın alınan × nitelik`); reklam havuzu ile tıklama bedeli birlikte ölçeklendiği için
doyum payı da aynı kalır. Kırılmalarını beklemiyorum; koşmadan söylüyorum, inişten önce dördü de koşulur.

**Benim iki şartım (§8.0):** ikisi de karşılandı. Düğme olarak ziyaret öneriyorum: tempo aynı, sepet ve sıklık gerçek kalıyor,
ilk haftaların sayıları büyüyor. Kalan çekincem "tek gecede bulunmuş sayı" ve son çeyrekteki baskısızlık; ikisi de playtest'in
ölçeceği şeyler. Kopya hazır: `e2\snap_p_ziyaret`.

### 8.6 Ön doğrulama ve inceleme (16 Kasım 06:52–07:07, HEAD `50715a3b`; hiçbir şey inmedi)

**Ön doğrulama (HEAD'in taze kopyası + P, test1'de tek tutuş).** Isınma temiz. Pazaryeri ölçüm betiği: 45 denetimin 45'i geçti;
ziyaret × 3 için okuyarak güncellenen beş beklenti tuttu. Kapı listesinin 30 vakası 30/30 (25 pazaryeri vakası, DÜZELTME'nin
dört kanal vakası, c8'in `incident_free_month_by_market` vakası). Altı bozmanın altısı yakalandı. Erdem "P" derse kalan iş kareler
ve kapıdır.

**İnceleme (§9, ayrı ajan, yalnız fark): dört düzeltme, iki not. Formül ve sabit değişmedi.**

1. PRD memnuniyet katsayısının aralığını "55 ile 85" yazıyordu; doğrusu 40'ta sıfır, 80'de tam. Düzeltildi.
2. PRD "hangi kategori hangi sırayla dolarsa dolsun toplam sipariş düşmez" diyordu. Bu yalnız **dolu** kategorilerde doğru.
   Yeni açılan kategori **dolarken** geri gelen kullanıcının siparişi geçici olarak düşüyor (aşağıdaki tablo). PRD'ye,
   `_breadth`'in yorumuna ve commit mesajına yazıldı.
3. Ölçüm betiğinin bir mesajındaki beklenen sayı eskiydi (2081,7 → 2981,7); denetimin kendisi doğruydu.
4. İçerik ve SEO reklam havuzunu okuyor (`marketing_system.gd:513`), yani onun da dolar başına ziyareti üç kat oluyor; kendi
   sabiti değişmedi. Bırakıldı ve yazıldı: bütün ziyaret kaynakları aynı oranda büyür, kanalların birbirine göre dengesi
   değişmez. (Verimi üçte bire indirmek İçerik'i öbür kanallara göre üç kat zayıflatırdı; bunu kimse kararlaştırmadı.)

Notlar: PRD üssü 1/3, config 0,3333 yazıyor (PRD'ye eklendi); tıklama bedelinin üçte birindeki yuvarlama zararsız (birim bedelde
en çok yüzde 0,4). İncelemeden ayrı bir eksik: PRD'nin kategori tablosunda taban ilgi ve reklam havuzu eski sayılarla kalmıştı,
düzeltildi.

**Kategori dolarken sipariş (geri gelen kullanıcı; kâğıt hesabı, gerçek sıklıklarla, `e2\genislik_denetim.py`).** Pay sıklık ×
seçenek ile bölünür ve sepet adımı da seçenekle çarpılır: kullanıcı siparişinin bir kısmını mağazası az kategoriye verir, orada
az bulur.

| Durum | Bugün (HEAD) | P ("A") |
|---|---|---|
| Moda dolu, Elektronik dolarken en derin | −%19 | −%2,5 (seçenek 0,37'de; 0,74'te başa döner) |
| Moda dolu, Elektronik dolunca | **−%19, kalıcı** | **+%4,6** |
| Moda dolu, Ev ve Yaşam dolarken en derin | −%10 | −%7,8 (0,30'da; 0,65'te başa döner) |
| Moda dolu, Ev ve Yaşam dolunca | −%3, kalıcı | +%20 |
| En kötü çift, dolarken | −%45 | −%14 (Elektronik dolu, Anne ve Bebek dolarken; 0,29'da başa döner) |
| Dolu bir kategori eklenince toplamın düştüğü durum sayısı (186 durumda) | 82 (en kötü −%44) | 0 |

- **Oyuncunun gördüğü:** ikinci kategoriyi açtığı ilk haftalarda geri gelen kullanıcının siparişi birkaç puan düşebilir, kategori
  üçte ikiye dolunca başladığı yeri geçer. Bugünkü hâlde düşüş kalıcıydı; P bunu düzeltiyor ama dolma dönemindeki çukur kalıyor.
  **Playtest sorusu:** "İkinci kategoriyi açınca ne oldu, siparişin düştüğünü fark ettin mi?"
- **Playtest sonrası aday (kâğıtta, ölçülmedi, karar yok):** pay `sıklık × seçenek²` olursa çukur tamamen kalkıyor (186 durumun
  hiçbirinde düşüş yok) ve dolu kategorilerdeki sonuç "A" ile aynı kalıyor. Kodda tek satır, ölçüm betiğinde bir denetim; botla
  yeniden ölçülmeden önerilmez.

### 8.7 Karar (16 Kasım 09:00, yardımcı yönetmenin aktarımı)

Erdem kalibrasyon ayarlarına girmeden önce bugünkü hâliyle playtest yapacak: **P inmedi.** Anlık görüntü, kareler ve hazır commit
mesajı özel kopyada bekliyor; playtest'ten sonra yeniden konuşulacak. Playtest'te bakılacak üç şey yardımcı yönetmende: ilk
haftaların boşluğu, 10'un altındaki kesirli sayılar, ikinci kategori dolunca geri gelen kullanıcının siparişindeki kalıcı düşüş
(§8.6 tablosunun "Bugün" sütunu). Kareler: aynı fikstürde yayından dört hafta sonra bugün 1 kullanıcı ve haftada 0,5 sipariş,
P'de 2 ve 1,4; 42. haftada 129 kullanıcı ve 24 sipariş, P'de 487 ve 85.

## 9. Düzeltme (16 Kasım, playtest sırasında; koddan okundu, koşulmadı): kartı olmayan talepler

OLAYLAR'ın Talepler adım 14 hazırlığında sorduğu bir sorudan çıktı; yardımcı yönetmen de ayrıca okuyup doğruladı.

- **Oyuncunun ekranında:** yayından sonraki ilk biletten sekiz hafta sonra iki memnuniyetin defterine "Geciken talep: <konu>"
  −4 yazılır. Konu önce bir modül kademesidir (kullanıcıda Vitrin'in ikinci kademesi, mağazada Ürün Yükleme'nin ikinci kademesi).
  Oyuncu o kademeyi çıkarınca satır kalkmaz, sıradaki konunun adına döner: "Beden tablosu", "Renk ve beden seçeneği". Bu ek
  özelliklerin oyunda kartı yoktur; satır oyunun sonuna kadar iki tarafta da −4 kalır.
- **Neden:** 13 konunun 7'si kademesiz ek özelliktir (`data/product/marketplace.json` `topics.catalog`). Model bunların yayında
  olup olmadığını dünyanın `features` listesinden okur (`marketplace_model.gd` `_topic_live`); `MarketplaceSystem.world()` o
  listeyi vermez ve sprint kataloğunda ek özellik kartı yoktur. Altısı bilet alır ve gecikir; yedincisi (Kupon suistimali)
  yalnız rapordan açılır, bugün açan yok.
- **İkinci, görünmeyen etki:** üç ek özellik yayında sayılmadığı için adımları kalıcı kısar (`_feature_mult`): sepet ×0,96 (Beden
  tablosu 0,97 × Favoriler 0,99), ödeme ×0,95 (Üyeliksiz alışveriş). Teslim edilen sipariş ulaşılabilir olandan yüzde 8,8 azdır
  ve Pazaryeri › Genel'de bu iki adımın çubuğu ince işarete hiçbir oyunda varamaz.
- **Bu belgedeki sayılara etkisi:** bütün ölçümler bu hâlle yapıldı; "geciken talep −4" her koşuda vardı ve ölçülen kullanıcı
  memnuniyetinin (49–66) içindedir. Sıralamalar değişmez. K1 satırı kaldırmaz, kapatılabilir yapar: satır istenen kademe
  konularının hepsi çıkınca kalkar (kullanıcıda beş kademe konusu, mağazada bir). Bot koşularında kullanıcı tarafında Vitrin'in
  ikinci kademesi beceri kilidinde kaldığı için satır yine durur; mağaza tarafında Ürün Yükleme'nin ikinci kademesi çıkınca kalkar.
- **Düzeltme adayları (karar yok):** K1 kartı olmayan konu bilet açmaz ve gecikmiş sayılmaz; sayı değişmez, adım kısıntısı
  aynen kalır. K2 kartı olmayan ek özellik adımı da kısmaz; sipariş yüzde 9,6 artar, bir sayı değişikliğidir. Yardımcı
  yönetmenin 16 Kasım kararı: K1 hazırlanır ve playtest bitince kapıya ilk o girer; K2 P ile birlikte Erdem'e gider. Kalıcı
  çözüm ek özellik kartlarıdır (Talepler adım 14).
