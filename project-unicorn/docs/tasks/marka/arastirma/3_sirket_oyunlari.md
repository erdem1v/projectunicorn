# Kol 3: Şirket, tycoon ve işletme simülasyonlarında marka / itibar / hayran / puan değerleri

Erişim tarihi: 2026-11-18. Numara bloğu S50–S79. Tasarım önerisi yok; olgu, sayı, ekran yapısı, şikâyet.

**Kota notu:** WebSearch kota hatası çıkmadı. 25 WebSearch çağrısı yapıldı (biri, reddit.com'u allowed_domains'e koyduğum için 400 hatasıyla reddedildi; 24'ü sonuç döndürdü). Reddit hiç açılamadı (WebFetch "unable to fetch from www.reddit.com"); bu yüzden Reddit alıntısı yok, şikâyet kanıtı Steam Community forumlarından. Fandom (GDT wiki) 402, planetcoaster.com 403, enlight.com forumu 403 verdi. Güven ve kaynak etiketleri bölüm 5'te.

**Okuma uyarısı:** "(arama özeti)" etiketi = sayfayı değil, WebSearch'ün döndürdüğü özeti okudum; sayfa kendisi açılmadı. "(model bilgisi, kaynak açılmadı)" etiketli cümle yok; bilgi bulunamadıysa "bulunamadı" yazıldı.

---

## 1. Oyun oyun döküm

### 1.1 Capitalism Lab / Capitalism II (zorunlu, en yakın emsal)

| Alan | Bulgu |
|---|---|
| Değer ne ölçer | "brand rating", iki parçanın toplamı: "The brand rating is the overall value of a brand, and it is the sum of two things:" brand awareness ve brand loyalty [S50]. |
| Ölçek ve gösterim | Awareness 0–100; iki boyutlu: şehir nüfusunun yüzde kaçı markayı biliyor + bilenlerin ortalama farkındalık düzeyi. Loyalty "Also 0 to 100, and also two dimensions": markaya sadık kişilerin yüzdesi + ortalama sadakat düzeyi [S50]. Loyalty negatife gidebilir (müşteri markadan kaçınır) [S50]. |
| Girdiler | Awareness: reklam ("Advertising is how a business raises it.") [S50]. Loyalty: (a) awareness ("Loyalty cannot exist before purchase and use."), (b) ürün kalitesi, tutarlı olmalı ("Loyalty also requires consistent quality, not merely high quality once."), (c) marka kapsamı: çok ürün sınıfına yayılmak sadakati düşürür [S50]. Oyuncu analizi (Düşük): 100.000 reklam yatırımı, rating 33 ve CPM 2,1 olan medya firmasında "will increase the brand rating by an average of 4 points per month"; satıştan gelen doğal artış "approximately 1 point of brand rating every 7-8 months"; daha yüksek CPM'li medyada marka daha yavaş artar [S52]. |
| Erime / tabana dönüş | Resmî kılavuz erime kuralı vermiyor (bulunamadı, bkz. bölüm 4). Tek oyuncu raporu (arama özeti): corporate brand ile awareness 60, loyalty 65'e çıktıktan sonra "in one year the awareness stays but the brand loyalty drops down to 37" [S53]. Loyalty'nin aşağı gitmesi kaliteden/kapsamdan mı, zamandan mı belli değil. Strateji değişirse tüm ürünlerin marka puanı sıfırlanır [S50][S52]. |
| Neyi etkiler | Gerçek girdi→çıktı sistemi. Ürünün "overall rating"i fiyat + kalite + marka bileşenlerinden oluşur; ağırlıklar ürün sınıfına göre değişir: Cigarettes "60% of their rating comes from branding while only 15% is based on quality and the remaining 25% on pricing"; Frozen Meats "only rely on branding for 20% of its rating (and 40% each for quality and pricing)"; Mobile Phones "40% of the rating ... is determined by quality" [S51]. Rating düşükse satış az: örnek araç "the Brand is zero, the Quality is only 35 and the price is too high", overall rating 6 [S51]. Oyuncu pratiği (Düşük): rakiplerin yerel ürünlerine benzer overall rating yeterliyse satış aylarca durağan kalır; fiyat düşürülerek rating açığı kapatılabilir [S52]. |
| Döküm gösteriliyor mu | Evet, çubuk/grafik düzeyinde: kılavuzda "Consumer concern breakdowns (the percentage split for branding, quality, and price) appear as charts" ve satış ayrıntı ekranları ürünün marka/kalite/fiyat bileşenlerini gösterir [S51] (kılavuz metni; ekran görüntüleri okunamadı). Marka stratejisi: Corporate Detail Report > Brand bölümü, sol üstte üç düğme (Corporate / Range / Unique), değiştirirken uyarı çıkar [S50]. Ürünün "brand concern" yüzdesi (ör. 31) oyuncu rehberinde geçiyor [S52]. Belirli satır/ipucu yapısı bulunamadı. |
| Kaldıraçlar ve bedel | Reklam (para; medya firması seçimi, CMO bütçe sınırıyla otomatik yönetebilir [S51]); kalite (Ar-Ge, hammadde); marka stratejisi (başta seç; sonradan değiştirmek sıfırlar). Bedel: unique brand'de her ürün kendi reklamını ister [S50]; reklam yatırımı 7 ay geri dönmez (oyuncu) [S52]. Rakip aynı ürünü satarsa kurduğun markadan yararlanır (oyuncu) [S52]. |
| Oyun başı / geç oyun | Resmî: "Decide at the start of the game." [S50]. Geç oyun davranışı (tavanda mı) için kaynak bulunamadı. |

### 1.2 Software Inc.

Dört ayrı değer var; birbirine karışıyor: (a) business reputation (yıldız, 0–6), (b) şirket "fans/followers" (ürün başına takipçi/aktif kullanıcı), (c) hype, (d) IP'nin kendi takibi.

| Alan | Bulgu |
|---|---|
| Resmî belge durumu | Wiki (softwareinc.coredumping.com/wiki) yalnız modlama sayfaları içeriyor; reputation/fans/hype/marketing sayfası yok [S60]. Aşağıdaki mekanik bilgi oyuncu forumlarından; geliştirici ifadeleri yama notlarında. |
| Ölçek ve gösterim | Yıldız göstergesi, "stars below money" (oyuncu, 2025) [S56]. Tam ölçek: bir oyuncu "i think it's on the scale of 0 to 1f" diyor, doğrulanmamış [S57]. |
| Girdiler (itibar) | Sözleşme (contract) ana kaynak: "Easiest way to gain Rep is doing Contracts." [S57]. Hatasız ve erken teslim; en küçük sözleşmeler (<10K) büyükler kadar itibar verebilir: "go always with the smallest contracts, that are less than 10K" [S56]. Kod okumasına dayanan oyuncu anlatımı (Düşük): "reputation gains from all deals are calculated daily"; deal itibarı mevcut itibarla çarpılıyor; hosting kazancı yalnız bant genişliği aşılmıyorsa [S57]. Destek anlaşmasında cevaplanmamış biletler itibarı "drop VERY quickly" düşürür; 3+ anlaşmada gece kaybı gündüz kazancı geçer [S58]. |
| Girdiler (fans/hype) | Oyuncu teorileri (2016–2017, Düşük): "Hype is what you do to reduce the amount of followers dropping."; pazarlama departmanı büyüdükçe takipçi düşüş hızı yavaşlar; press release her kullanımda etkisi azalır; "Marketing after release will increase buyer each months" [S59]. |
| Erime | Takipçi düşer ("the amount of followers dropping"), hype düşüşü yavaşlatır [S59]. İtibar için erime kuralı net değil; oyuncular "You need to constantly be pushing products out to keep the rep up." diyor [S55]. |
| Neyi etkiler | Yıldız: daha yüksek ödemeli sözleşmeler ve alt şirket sayısı ("5 Subs max" 6 yıldızda) [S56]. Fans: "the more followers you get, the more the product will sell" (oyuncu) [S59]. |
| Geliştirici beyanı (yama, 2026-10-04 "Final Overhaul update" yazısı) | "Added hype stat, that can increase pre-marketing effectiveness but risks increased refunds and bad reviews"; "Entire IPs can now gain their own following, separate from the companies' fans"; "You can now gain business reputation from licenses, patents, frameworks, publishers and awards"; "Contracts now have capped business reputation gain based on scope"; "Overhauled pre-marketing tasks and removed press releases and builds" [S60]. |
| Geliştirici beyanı (eski yamalar, arama özeti) | Alpha 11.5.10: "Added 'Glitchy' to contract quality assesment, to clarify when reputation goes down for seemingly no reason"; Alpha 10.6.9: "Rebalanced marketing deal and hosting deal reputation effect and made companies cancel deals with bad player performance"; Alpha 11.4.2: "Reduced business rep from support deals and disabled bug fixing" [S61]. |
| Döküm gösteriliyor mu | Sözleşme kalitesi etiketleri var (ör. "Glitchy" [S61]); itibarın tek bir döküm paneli olduğuna dair kaynak bulunamadı. Oyuncular tam da "no info as to why" diyor (bölüm 2). |
| Kaldıraçlar ve bedel | Sözleşme (zaman, hata), ürün çıkarma, destek/hosting anlaşmaları, pazarlama ekibi. Bedel: destek anlaşması ihmalinde hızlı kayıp [S58]. |
| Oyun başı / geç oyun | Erken: sözleşme taşı ile 6 yıldız "within one year" / "in the second year" [S56][S57]. Geç: "Searry: millions but 1 on the right ... impossible to raise this" (sıkışma örneği) [S56]. Bir oyuncu tam yıldız için 20,5 yıl ve 10 milyar dolar bildiriyor, çoğu Outstanding ürünle [S57]. Yani iki uçlu: ya hızla tavan ya sıkışma; oyuncular yolu bilince tavan. |

### 1.3 Game Dev Tycoon (kısa)

| Alan | Bulgu |
|---|---|
| Kaynak durumu | Fandom wiki 402 verdi; resmî belge bulunamadı. Tek kaynak: sahibi belirsiz bir Google Sites wikisi [S64] (Düşük). |
| Girdiler | Hype: "generated by your Marketing budget and by creating Sequels to high-scoring games"; 8/10 ve üstü oyunun devamı yapılabilir ve otomatik hype bonusu alır; yayımlanan oyun skoru, hype ve piyasaya göre "will generate sales and attract new fans"; DLC "provides an immediate injection of cash and fans" [S64]. |
| Neyi etkiler | "More hype leads to more sales."; mevcut hayranlar "will contribute to the initial sales of your new games" [S64]. |
| Erime | Sayfa hayran/hype kaybından söz etmiyor [S64]. Bulunamadı. |
| Döküm / oyuncu şikâyeti | Bulunamadı (arama özeti: bir inceleme "oyun hype'ın satışa etkisini net göstermiyor" diyor; kaynak sayfası açılmadı, kayda alınmadı). |

### 1.4 Mad Games Tycoon 2

| Alan | Bulgu |
|---|---|
| Değerler | Fans, hype, IP değeri/derecesi, stüdyo gücü, kullanıcı yorumu skoru, şirket değeri. |
| Girdiler / sınırlar (geliştirici yama notları, Eggcode, Early Access) | "Star designers can only create a hype of maximum 50." (2022.02.05A); "The hype of budget games, GOTY editions and addon bundles decreases the older the game is." (2022.07.06A–08A); "Bonus hype for spin-offs is now taken from the latest game of the IP." (2021.12.22A); "Your consoles will now also generate fans." (2022.12.24A/2023.01.07A); "Hype now has a significantly higher effect for own consoles." (2023.04.21A) [S62]. |
| Neyi etkiler | "BALANCE: Fans now have more influence on the sales figures of games." (2021.08.25A) [S62]. Oyuncu: "Your fans act as a multiplier to sales, the more fans you have, the more copies you'll sell" (Kyouko Tsukino, 2024-12-20) [S63]. Aynı oyuncu: "Fans don't seem to extend lifetime either" [S63]. |
| Erime / ihmal | "IP rating did not drop if you neglected your IP" (hata, 2022.07.06A düzeltildi); IP menüsü "Neglect"e göre sıralanabilir ve IP ipucu son oyundan bu yana geçen hafta sayısını gösterir (2022.01.10A); "BUG: If you had a lot of fans, it could happen that all fans disappeared." (2022.04.26A); iflasta fans/IP artıyordu (2023.04.11A) [S62]. IP değerinin üst sınırı 200.000.000 dolar ve yıla göre ölçekleniyor (2023.03.08B) [S62]. |
| Döküm gösteriliyor mu | Kısmen: ihmal haftası ipucu ve sıralama var [S62]. Kullanıcı yorum skoru için oyuncu: "I still do not understand how is this value calculated ?" (nosedigger, 2024-12-04); "user reviews are something that may be up to RNG, it does not seem to have an obvious reason behind the numbers" (Kyouko Tsukino, 2024-12-10); "99% and 100% are determined by random chance" [S63]. |
| Oyun başı / geç oyun | Oyuncu: "If you have less than 100k fans by 1985, you could be in trouble." [S63] (fan eşiği oyun yılına bağlanıyor). IP değeri yıla göre ölçekleniyor [S62]. Geç oyun "tavanda mı" sorusu için kaynak bulunamadı. |

### 1.5 RollerCoaster Tycoon 1–2 (park rating; OpenRCT2 kaynak kodu)

| Alan | Bulgu |
|---|---|
| Ölçek | 0–999; sonuç sonda 0–999'a kırpılır [S65]. |
| Formül (OpenRCT2 `CalculateParkRating`, arama/okuma özeti) | Başlangıç 1150 (zor parkta 1050) [S65][S66]. Misafir sayısı terimi: −150…+3 (misafir sayısı/13, 2000'de tavan) [S66]. Mutlu misafir: −500…0 ("If more than 83% of your peeps is happy, you will lose no points of park rating") [S66]. Kayıp misafir (çıkış bulamayan): ilk 25 ücretsiz, sonrası her biri −7, üst sınır yok [S66]. Ride uptime: −200…0 [S66]. Ortalama heyecan/yoğunluk: en çok −100; toplam heyecan/yoğunluk: en çok −200 [S66]. Çöp: parça başı −4, en çok −600; yalnız ≥7680 tick yaşlı çöp sayılır [S65][S66]. Ölüm/boğulma ve kaza cezası: boğulma −25, kaza +200 ceza, zamanla azalır [S66]. |
| Sıklık | `currentTicks % 512 == 0` ile yeniden hesaplanır, kodun yorumuna göre "Every ~13 seconds"; özetlenen kodda hedefe adım adım yaklaşma yok, hesaplanan değer doğrudan atanır [S65] (okuma özeti; kodun ham metni bende yok, bu satırı kodla doğrulamadan tasarım girdisi yapma). Haftalık geçmiş kaydı `ratingHistory` [S65]. |
| Neyi etkiler | Rating arttıkça yeni misafir doğma olasılığı artar [S66] (arama özeti). Senaryo hedefi olarak kullanılır (örn. "600 park rating", Extreme Heights'ta 700 üstü) (arama özeti, S66 ile aynı sonuç kümesi). |
| Döküm gösteriliyor mu | Oyun içinde tek sayı; bileşen dökümü oyun arayüzünde yok gibi, topluluk kaynak koddan çıkarmış [S66]. Oyun içi döküm var mı konusunda kaynak bulunamadı. |
| Sömürü ve ders | Rehber: kayıp-misafir cezası muhtemelen oyuncular çıkışı afişle tıkamasın diye var [S66] (geliştirici niyeti değil, rehber yazarının yorumu). Çöp temizlemek ve misafir dışarı atmak formülden doğan kaldıraçlar; oyuncu taktiği olarak bu yönde belgelenmiş kaynak bulunamadı. Ters yönde: "Park Rating Plummet Bug": rating 999'dan bir ayda 400 altına düşüyor; sebep "guests that 'want to go home' with very low happiness scores hang around the park"; bu misafirleri çıkışa taşıyınca "right back up to 999" (TheWaxyCactus, 2019-04-08/10) [S67]. Yani tek sayıyı toplu bir nüfus özelliği (düşük mutluluk) bir ay içinde çökertebiliyor ve oyuncu nedenini ancak elle araştırarak buluyor. |
| Oyun başı / geç oyun | Başlangıç 1150 üzerinden çıkarmalarla gidiyor: boş park en iyi durumda, ceza yoksa 999'a kırpılır [S65][S66]; yani sağlıklı parkta tavan, ceza yedikçe düşer. |

### 1.6 Two Point Hospital

| Alan | Bulgu |
|---|---|
| Değer | Hospital reputation (yüzde ve yıldız hedefleri). |
| Girdiler (Gamepressure rehberi, Orta) | Artıranlar: bina ve dolap sayısı ("The more buildings and cabinets you have the greater the reputation is."), oda değeri/prestiji, memnun hastanın tavsiyesi, tamamlanan acil durum (hastaların ≥%50'si zamanında tedavi), memnun VIP, pazarlama (kampanya bitince itibar artar). Azaltanlar: hasta ölümü ("If a patient dies in your hospital, your reputation will decrease."), başarısız acil durum, memnun gitmeyen VIP. Etki: "The higher the reputation of your hospital is, the more patients you have and the greater the income you receive." Rehber sayısal puan vermiyor [S68]. |
| Oyuncu verileri (Düşük) | "good outcomes raise reputation about twice as much as bad ones lower it. For example, a cure gives two points and a death takes away one." (Realty13, 2018-09-10) [S69]. Fiyat artışı itibarı çökertir ve geri gelmesi çok uzun sürer: "once rep tanks down to price hikes, it takes a loong time to get repaired." (squeezleprime, 2019-09-05) [S70]. |
| Erime | Rehberde yok; fiyat sonrası toparlanma yavaş [S70]. |
| Döküm | Rehber sayı vermiyor [S68]; oyun içi döküm yapısı için kaynak bulunamadı. |
| Geç oyun | Başlık: "Can you actually lower your reputation?" ve oyuncu "I often keep zero reputation and don't see a difference from max" (özet, sh3riff) [S69]; ayrıntı bölüm 2. |

### 1.7 Planet Coaster / Planet Coaster 2

| Alan | Bulgu |
|---|---|
| Resmî belge | planetcoaster.com rehber ve haber sayfaları 403 verdi; açılamadı. |
| Yapı (arama özeti, Düşük) | PC2: guest experience → Park Reputation → Park Rating; park rating "determined by your lowest performing area"; dört büyük istatistikten biri Attraction Prestige; rating misafir çekimini etkiler [S78]. |
| Oyuncu şikâyeti | PC2 "Luxury stat stuck at 8%": Parks and Restoration hedefi için gereken 4,5 park rating'e luxury yüzünden varılamıyor; çözüm olarak parkı kapatıp 3000 misafir çıkana kadar beklemek (PingZoo, 2024-11-08): "I closed the park, waited until the 3000 guests were outside."; "It seems the guest are bugged and they don´t improve over time." (Bruno_Malta, 2024-11-08) [S76]. PC1 "Coaster Ratings Changing": "'Testing' is rather useless, if the numbers will wildly change through the usage of the ride." (ImHelping, 2016-12-05); "The real problem is that the game doesn't explain how the scoring works" (Voilodion özeti) [S77]. |

### 1.8 Tropico 6 (approval)

| Alan | Bulgu |
|---|---|
| Değer | Citizen approval/support; seçim sonucunu öngörür: "an indicator that shows the number of potential voters" [S72]. |
| Girdiler | Vatandaş memnuniyeti (Almanac'ta göstergelere ayrılıyor), hizip memnuniyeti, art arda seçim isteğini reddetmek, hazine (borç onayı düşürür) [S72]. |
| Döküm | Var: "The Almanac gives a complete overview of the indicators that affect approval. Its faction tab also lists each faction's leader." [S72]. Oyuncu: "It actually tells you in the almanac what is effecting it, you an also just buy approval from the broker." (Kunovega, 2019-07-21) [S71]. |
| Kaldıraçlar | Zayıf göstergeyi düzeltmek, hizip ilişkisi, hizip liderine rüşvet, bütçeyi pozitif tutmak [S72]; "buy approval from the broker" [S71]. |
| Erime / şikâyet | "Citizen approval level is kinda rigged to me." (gigamelon1981, 2019-07-21); "They're not as fast as the approval decay." (araçlar erimeyi karşılayamıyor); "Any positives you get from building things they like will only be temporary from what I've observed." (Vermillion Cardinal) [S71]. Oyuncu açıklaması: "Your over all support is based on how happy your citizens are in comparison to the other Caribbean nations near by." (jlking3rd) [S71] (doğrulanmamış oyuncu iddiası). Arama özeti: "73% overall happiness, I have 4% support" tarzı raporlar (kaynağı açılmadı, kayda alınmadı). |

### 1.9 Project Highrise

| Alan | Bulgu |
|---|---|
| Değer | Geliştirici yazısı "influence/cachet" diyor, "prestige" ve "buzz" terimlerini kullanmıyor [S73]. |
| Girdiler | "Influence comes from having important tenants in your building"; mutlu tutulmalı [S73]. |
| Neyi etkiler | Danışmanları (interior designer, lobbyist, building manager) açar; sonra "building improvements, amazing artworks, or valuable exemptions to city regulations" [S73]. Yani gerçek bir kapı mekaniği. |
| Prestige/Buzz resmî dökümü, erime | Bulunamadı (arama özeti: bir IGN incelemesi "buzz" ile medya kampanyası satın alındığını söylüyor; kaynak sayfası açılmadı, kayda alınmadı). |

### 1.10 Tavern Tycoon ve Old Market Simulator (itibar → müşteri akışı, "neden düştü" örnekleri)

- Tavern Tycoon: oyuncu "the net reputation is negative due to how long they have remained in my tavern." Geliştirici (Peter, 2019-03-22): "Remember staying at the tavern doesn't make them angry or lose happiness, waiting for services do." Sonra (2019-04-08): "I've made some changes to the feedback system so that it shows exactly why the guest is leaving." [S74]. Tasarım olgusu: geliştirici, opaklık şikâyetini misafir başına "neden ayrılıyor" geri bildirimiyle çözdü.
- Old Market Simulator, "Reputation is unbalanced." (2025-05-05…08): "The reputation drops greatly as soon as one product is empty." (AgeOfBacon); "it dropped to 20 because I didn't have all the fancy Christmas goods in stock" (raid; 103'ten 20'ye); "The only time my reputation significantly shrank was when I forgot to lower prices!" (Dantalion) [S75]. Süpürülen ölçek: tek bir stok kalemi tüm değeri çökertiyor ve oyuncu nedenini forumda öğreniyor.

### 1.11 Seçmeli: kısa notlar

- Cities: Skylines 2 (arama özeti, Düşük): "Citizen Happiness ... is the combination of their Well-being and Health and affects the citizen's behavior and their ability to work"; global mutluluk konut/sanayi/ticaret/ofis mutluluk ortalaması [S79]. Dökümü ayrıntılı, ancak sayfa açılmadı.
- Kairosoft Game Dev Story, Startup Company, Big Ambitions, Good Company, Planet Zoo: kullanılabilir döküm bulunamadı (bölüm 4).

---

## 2. Şikâyetler ve başarısızlar (alıntılı)

Not: Reddit açılamadığı için tüm alıntılar Steam Community forumlarından; hepsi Düşük güven (tek forum yazısı), geliştirici beyanı olanlar ayrıca işaretli.

### 2.1 Opaklık: "neden düştüğünü anlamıyorum"

1. Software Inc., "Alpha 11 - Development Deals always destroy my reputation?" (Traslo, 2020-07-20): "every time no matter what I get a massive loss of reputation with literally no info as to why." Hata düzeltme isteği: "Is this just unfinished content that lacks feedback or am I doing something completely wrong" [S54].
   - Geliştirici cevabı yamada: Alpha 11.5.10 "Added 'Glitchy' to contract quality assesment, to clarify when reputation goes down for seemingly no reason" [S61]. Tasarım dersi: oyun yapımcısı, "sebepsiz düşen itibar" şikâyetini sebep etiketiyle yanıtlamış (arama özeti; yama satırı sayfadan açılmadı).
2. Software Inc., "reputation just dropping?" (TheOrangeTaco, 2015-05-10): "is just lowering for some reason, I have not put out a bad product and my servers are not overloaded?"; geliştirici Coredumping (2015-05-13): "I'm aware of this. Old saves and games where there is more than one day per month will exhibit this behavior in alpha 4.3." [S55]. Yani şikâyet gerçek bir hataymış; oyuncu hata ile tasarımı ayıramıyor.
3. Software Inc., "Reputation" (Scabadus, 2015-12-02): "I think I've tracked it down to the deals you unlock with a receptionist."; cevaplanmamış biletler "drop VERY quickly" [S58]. Oyuncular itibar kayıp nedenini kendi başlarına tahminle çıkarmış.
4. Mad Games Tycoon 2, "User Reviews (and Sales) ?" (nosedigger, 2024-12-04): "I still do not understand how is this value calculated ?"; (Kyouko Tsukino, 2024-12-10): "user reviews are something that may be up to RNG, it does not seem to have an obvious reason behind the numbers" [S63].
5. Old Market Simulator (2025-05): "I have a huge drop in reputation because I don't have ALL the product in my market." (AgeOfBacon) [S75].
6. Tropico 6, "Finding the game is too hard" (gigamelon1981, 2019-07-21): "Citizen approval level is kinda rigged to me." Karşı görüş: "It actually tells you in the almanac what is effecting it" (Kunovega) [S71]. Yani döküm varken de şikâyet sürüyor: döküm var ama düzeltme hızı erimeyi geçmiyor ("They're not as fast as the approval decay.").
7. Planet Coaster 1, "Coaster Ratings Changing" (2016-12-04…06): "Is this a bug?" (burritonator); "The real problem is that the game doesn't explain how the scoring works" (Voilodion, özet) [S77].
8. Tavern Tycoon (2019-03-22): oyuncu net itibarın neden negatif olduğunu anlamıyor; geliştirici (2019-04-08) "I've made some changes to the feedback system so that it shows exactly why the guest is leaving." [S74].

### 2.2 Anlamsız / etkisiz: "tavanda ya da hiç fark etmiyor"

1. Two Point Hospital, "Can you actually lower your reputation?" (2018-09-10) [S69]. Devilfish: yüzlerce hastayı kızgın gönderince itibarın gözle görülür değişmediği, sistemin "it doesn't seem to work that way" olduğu (özet). sh3riff: "there is no punishment for NOT having reputation so why care" (özet; "Often keeps zero reputation and doesn't see a difference from max"). Seed5050: daha zor bir oyun, ölümün ve öfkenin daha çok vurması istiyor (özet). Kaynak sayfasında 125 karakter alıntı sınırı nedeniyle çoğu satır özettir; harfi harfine olan yalnız tırnaklı ifadeler.
2. Software Inc. 2025: Searry (2025-06-12): "millions but 1 on the right" ve "impossible to raise this" [S56] (mevcut itibar yıldızı para varken bile yükselmiyor). Aynı sayfada nosedigger: sözleşme ile "can get you to 6 BP reputation within one year" [S56]. Yani erken hızlı tavan, ters yönde sıkışma.
3. Software Inc. (Hunter, 2016-04-06): tam yıldıza "20 1/2 years and $10 Billion in cash" [S57].

### 2.3 Angarya / grind

1. Software Inc.: "go always with the smallest contracts, that are less than 10K" çünkü "can give same boost as higher level Contracts" (nosedigger, 2025-06-13) [S56]. Küçük sözleşme döngüsü optimum strateji olunca itibar için angarya tekrar doğuyor.
2. Software Inc., "How to build reputation?": McKay (2016-04-07): "Easiest way to gain Rep is doing Contracts."; Macros: "I've finally started gaining decent reputation after taking 40+ hosting deals." [S57]. 40+ hosting anlaşması = angarya örneği.
3. Software Inc. geliştirici yaması, 2026-10-04: "Contracts now have capped business reputation gain based on scope" [S60]. Küçük sözleşme sömürüsünü ölçeğe bağlı üst sınırla kapattığı okunabilir; geliştirici gerekçe yazmıyor (bu çıkarım benim; kaynak yalnız satırı veriyor).

### 2.4 Sömürülen puanlar

- RCT park rating için belgelenmiş bir hile/sömürü bulunamadı (sorgular bölüm 4). Bulunan yakın örnek: OpenRCT2 rehberinin, kayıp-misafir cezasını oyuncular çıkışı afişle tıkamasın diye var olduğunu düşünmesi [S66] (yorum). Mad Games Tycoon 2: "BUG: Company value of NPC studios could increase infinitely." ve iflasta fans/IP'nin artması hatası [S62] (geliştirici yama notu; sömürü değil hata ama aynı türden "değer ters çalıştı").
- Planet Coaster 2: parkı kapatıp misafirleri çıkarıp yeniden açmak rating hedefini geçiriyor (PingZoo, 2024-11-08) [S76]; yani "eskimiş misafir durumu"nu sıfırlamak iş görüyor (kural sömürüsü değil, hata çözümü).

### 2.5 İtibar sistemini düzelten / yeniden yazan geliştirici örnekleri

- Software Inc. Final Overhaul update (2026-10-04): hype stat eklendi, IP'ye ayrı takip, ek itibar kaynakları, sözleşme itibar üst sınırı, "Overhauled pre-marketing tasks and removed press releases and builds" [S60]. Press release/build kaldırılması, oyuncuların "press build" patlaması stratejisini bitirir ("Drop this Nuke at around 80-90% of the project so you get crazy amount of followers." (POTATOMAN19, 2017) [S59]); geliştirici gerekçesi bulunamadı, topluluk tepkisi bulunamadı.
- Mad Games Tycoon 2: ihmal edilen IP'nin derecesinin düşmemesi hatası düzeltildi; IP ipucuna son oyundan bu yana hafta sayısı eklendi [S62].
- Tavern Tycoon geliştiricisi misafir ayrılış nedenini gösterir hale getirdi [S74].

### 2.6 Erimeye ("decay") tepki

- Sevilmeyen: Tropico 6 oyuncusu, hizip araçları erimeyi karşılayamıyor: "They're not as fast as the approval decay." [S71]. Software Inc. oyuncusu itibarın "just dropping" olduğunu ve "You need to constantly be pushing products out to keep the rep up." [S55] (2015, hata bağlamı).
- Sevilen: kaynak bulunamadı. Hiçbir forumda decay'in "güzel" bulunduğuna dair açık bir yazı yakalanmadı. Software Inc.'te hype'ın takipçi düşüşünü yavaşlatan bir araç olarak anlaşılması [S59] ve pazarlama ekibi büyüklüğünün düşüş hızını yavaşlatması (POTATOMAN19) [S59] nötr-olumlu okuma, ama hoşnutluk beyanı değil.
- Arama "hate that reputation decays ... have to keep doing marketing" sonucu: forum şikâyeti bulunamadı; yalnız genel sektör yazıları döndü (kayda alınmadı).

---

## 3. Karşılaştırma tablosu

### 3a. İşleyen örnekler (gerçek girdi→çıktı; döküm ya da düzeltme yolu var)

| Oyun · değer | Girdiler | Erime | Etkisi | Döküm var mı | Oyuncu ne diyor |
|---|---|---|---|---|---|
| Capitalism Lab · brand rating (awareness + loyalty, 0–100) [S50] | Reklam→awareness; kalite tutarlılığı, awareness, kapsam→loyalty [S50] | Resmî yok; oyuncu: loyalty 65→37 bir yılda [S53] | Overall rating'de ağırlık 15–60% (ürün sınıfına göre) [S51] | Evet, bileşen grafikleri ve satış ayrıntısı [S51] | Rehber oyuncular fiyat/kalite/marka dengesi kuruyor [S52]; belirgin şikâyet bulunamadı |
| Tropico 6 · approval [S72] | Memnuniyet göstergeleri, hizipler, hazine [S72] | "approval decay" oyuncuya göre hızlı [S71] | Seçim sonucu [S72] | Evet, Almanac [S72][S71] | Hem "kinda rigged" hem "it tells you in the almanac" [S71] |
| Project Highrise · influence [S73] | Önemli kiracılar [S73] | Bulunamadı | Danışmanları ve iyileştirmeleri açar [S73] | Bulunamadı | Bulunamadı |
| RCT · park rating 0–999 [S65][S66] | Dokuz bileşen, formülü açık [S66] | Cezalar yoksa tavan; bir ayda çökebilir [S67] | Misafir doğma olasılığı [S66] | Oyunda tek sayı; döküm topluluk kodundan [S66] | "Plummet Bug" [S67] |
| Mad Games Tycoon 2 · fans/hype/IP [S62] | Oyun çıkışı, konsol, spin-off [S62] | IP ihmali (hafta sayısı ipucuda) [S62] | Satışta çarpan [S63] | Kısmen [S62] | Yorum skoru için "I still do not understand" [S63] |

### 3b. Şikâyet alan örnekler

| Oyun · değer | Girdiler | Erime | Etkisi | Döküm var mı | Oyuncu ne diyor |
|---|---|---|---|---|---|
| Software Inc. · business reputation (yıldız) [S56][S57] | Sözleşme, deal'ler, ürün [S57] | Net değil; kayıplar anlaşılmıyor [S54] | Sözleşme kalitesi, alt şirket sayısı [S56] | Sınırlı; "Glitchy" etiketi [S61] | "literally no info as to why" [S54]; "millions but 1" [S56] |
| Two Point Hospital · reputation [S68] | Bina sayısı, ölüm, acil, VIP, pazarlama [S68] | Fiyat sonrası yavaş toparlanma [S70] | Hasta akışı [S68] | Sayı verilmiyor [S68] | "there is no punishment for NOT having reputation so why care" [S69] |
| Mad Games Tycoon 2 · kullanıcı yorumu skoru [S63] | Bilinmiyor [S63] | — | Satış [S63] | Yok | "may be up to RNG" [S63] |
| Planet Coaster 1/2 · coaster rating, park rating [S76][S77] | Ride davranışı, misafir durumu | Misafir durumu birikiyor [S76] | Park rating hedefi [S76] | Test ekranı var ama kullanımda değişiyor [S77] | "doesn't explain how the scoring works" [S77] |
| Old Market Simulator · reputation [S75] | Stok, fiyat, temizlik [S75] | Geri gelir (oyuncu) [S75] | — | Yok gibi | Nedenini forumda öğreniyorlar [S75] |
| Tavern Tycoon · reputation [S74] | Misafir mutluluğu [S74] | — | — | Geliştirici sonradan ekledi [S74] | Net itibar negatif şikâyeti [S74] |

---

## 4. Bulunamadı listesi

| Aranan | Durum | Denenen sorgular / yol |
|---|---|---|
| Capitalism Lab: reklam etkisinin, awareness'ın ve loyalty'nin resmî sayısal formülü, erime kuralı | Bulunamadı (resmî sayfalar "not covered") | "Capitalism Lab manual brand awareness brand loyalty brand rating advertising"; "Capitalism Lab product rating quality price brand weights consumer purchase formula forum"; "Capitalism Lab brand loyalty advertising awareness decay product rating"; capitalismlab.com/?p=4374, /resources/gameplay-faq/brand/, /beginners-guide-gameplay-basics/ açıldı; enlight.com forum 403. |
| Capitalism Lab: ürün ayrıntı penceresindeki çubukların tam yerleşimi | Bulunamadı (kılavuz metni yalnız "charts" diyor, ekran görüntüleri okunamadı) | Aynı sayfalar. |
| Software Inc. resmî wiki'de reputation/fans/hype | Wiki yalnız modlama [S60]; Steam rehber/forumlar kullanıldı | "Software Inc wiki reputation fans hype marketing"; softwareinc.coredumping.com/wiki/, /wiki/index.php/Main_Page. |
| Software Inc. "Final Overhaul update" yazısının tam metni, topluluk tepkisi | Yalnız özet satırlar bulundu [S60] | coredumping.itch.io/software-inc/devlog (ilgili yazı yok); "Software Inc final overhaul update hype pre-marketing removed press releases reaction". |
| Software Inc. Reddit tartışması (pazarlama başlığı) | Açılamadı | reddit.com WebFetch ve allowed_domains reddit.com reddedildi (axebps-redlib.hf.space "Preparing Space"). |
| Game Dev Tycoon: fan kaybı/hype erimesi, resmî wiki | Bulunamadı | "Game Dev Tycoon fans hype how fans are gained lost wiki"; gamedevtycoon.fandom.com/wiki/Fans ve /Hype ve ?action=raw 402. |
| Mad Games Tycoon 2: stüdyo puanı/hype resmî formülü | Bulunamadı | "Mad Games Tycoon 2 fans hype studio reputation how it works". |
| RCT park rating sömürüsü ("park rating hileleri"), tasarım dersi kaynağı | Belgelenmiş sömürü bulunamadı; yalnız kodda kayıp-misafir cezasının gerekçesine dair rehber yorumu [S66] | "RollerCoaster Tycoon park rating formula explained exploit 999 rating wiki"; "RollerCoaster Tycoon park rating exploit trick raise rating cheat guests spawn rate price gate"; forums.rctgo.com tid=2619 (RCT3 hile başlığı, park rating'i yükselten hile yok) ve tid=18378. |
| OpenRCT2 park rating değişimi: adım adım hedefe yaklaşma var mı | Özetlenen kod doğrudan atama gösteriyor; ham kod okunmadı | raw.githubusercontent.com/OpenRCT2/OpenRCT2/develop/src/openrct2/world/Park.cpp (özet). |
| Two Point Hospital/Campus: hasta akışı formülü, yıldız eşikleri | Bulunamadı | "Two Point Hospital reputation how it works hospital reputation affects patients per day wiki". |
| Planet Coaster resmî park rating/reputation/prestige formülü | Bulunamadı; planetcoaster.com 403 | "Planet Coaster park rating guest happiness how calculated ..."; planetcoaster.com/player-guides/park-management ve haber sayfası 403. |
| Project Highrise "prestige/buzz" resmî dökümü | Bulunamadı; geliştirici yalnız "influence" diyor [S73] | "Project Highrise prestige buzz tenants satisfaction how it works official". |
| Big Ambitions itibar sistemi | Bulunamadı | "Big Ambitions reputation customer satisfaction business rating how it works wiki" (alakasız sonuçlar). |
| Startup Company, Good Company, Kairosoft Game Dev Story fan/hype mekaniği | Bulunamadı (yalnız genel pazarlama yazıları ya da Game Dev Tycoon'a ait ipuçları) | "Startup Company game reputation hype brand customers how it works steam guide"; "Game Dev Story Kairosoft fans hype research points how fans work guide". |
| Tropico 6 hizip memnuniyetinin resmî formülü | Bulunamadı; Almanac'ın var olduğu ve etkenleri gösterdiği biliniyor [S72][S71] | "Tropico 6 approval rating breakdown factions loyalty how approval calculated election". |
| "Hep 100"/"her zaman tavanda" itibar şikâyetini doğrudan söyleyen Steam olumsuz yorumu | Bulunamadı; yakın örnek Two Point Hospital "no punishment" [S69] | "Two Point Hospital reputation 'doesn't matter' OR 'pointless' OR 'always 5 stars' late game steam discussion"; "tycoon game reputation system 'no idea why' reputation dropped opaque ...". |
| İtibar sistemini baştan yazan başka tycoon (Software Inc. dışında) ve yama notu | Yalnız Software Inc. [S60][S61] ve MGT2 [S62] örnekleri | "patch notes reputation system reworked tycoon management game 'reputation' overhaul developer update decay". |
| Decay'e sevilen tepki | Bulunamadı | "hate that reputation decays over time have to keep doing marketing grind management game forum 'decay' popularity fans lose" (yalnız genel sektör yazıları döndü). |
| Cities: Skylines mutluluk dökümü (resmî) | Yalnız arama özeti [S79]; sayfa açılmadı | "Cities Skylines happiness explained factors wiki land value health education wellbeing happiness effect". |
| Steam olumsuz *ürün* yorumları (ürün sayfasındaki olumsuz yorumlar) | Okunmadı; forum konuları kullanıldı | Steam olumsuz yorum filtresine WebSearch ile doğrudan erişilemedi. |

---

## 5. Kaynak sicili

Erişim hepsi 2026-11-18. WebSearch kullanımı: 25 çağrı (biri hata).

| ID | URL | Yayıncı | Yayın | Güven | Not |
|---|---|---|---|---|---|
| S50 | https://www.capitalismlab.com/?p=4374 ; https://www.capitalismlab.com/resources/gameplay-faq/brand/ | Enlight Software (Capitalism Lab resmî sitesi) | güncel wiki | Yüksek | İki sayfa aynı içeriği veriyor (brand rating = awareness + loyalty, stratejiler, UI). Formül/erime yok, kılavuz kendi söylüyor. |
| S51 | https://www.capitalismlab.com/beginners-guide-gameplay-basics/ | Enlight Software | güncel wiki | Yüksek | Ürün sınıfına göre fiyat/kalite/marka ağırlıkları; ekran görüntüleri okunamadı. |
| S52 | https://steamcommunity.com/sharedfiles/filedetails/?id=2969285443 | Krikraker (Steam rehber yazarı) | 2023-04-30, güncelleme 2023-05-29 | Düşük | Tek oyuncu rehberi; sayılar oyuncu gözlemi. |
| S53 | https://www.enlight.com/forum/viewtopic.php?f=11&t=574 ; http://www.enlight.com/forum/viewtopic.php?f=2&t=685 | Enlight forum kullanıcıları | tarih bilinmiyor | Düşük | Sayfalar 403 verdi; yalnız WebSearch özeti okundu (arama özeti). |
| S54 | https://steamcommunity.com/app/362620/discussions/0/2792745783013631007 | Steam Community, Traslo ve diğerleri | 2020-07-20…26 | Düşük | "Alpha 11 - Development Deals always destroy my reputation?" |
| S55 | https://steamcommunity.com/app/362620/discussions/0/613957600540956367 | Steam Community, Coredumping (geliştirici) ve oyuncular | 2015-05-10…14 | Orta | Geliştirici hata teyidi içeriyor; kalan yazılar Düşük. |
| S56 | https://steamcommunity.com/app/362620/discussions/0/838346066654921590/ | Steam Community, nosedigger, Searry | 2025-06-12…13 | Düşük | "Where's a good reputation guide?" |
| S57 | https://steamcommunity.com/app/362620/discussions/0/365163686061359755/ | Steam Community, Hunter, McKay, kotae, Macros | 2016-04-06…07 | Düşük | "How to build reputation?" (kotae: kod okuması). |
| S58 | https://steamcommunity.com/app/362620/discussions/0/485623406958884072/ | Steam Community, Scabadus ve diğerleri | 2015-11-30…2016-02-17 | Düşük | "Reputation" başlığı. |
| S59 | https://steamcommunity.com/app/362620/discussions/0/357286663692763958/ | Steam Community, Pazox, POTATOMAN19, Luciferci | 2016-05-24…2017-07-15 | Düşük | "How does marketing work?" |
| S60 | https://softwareinc.coredumping.com/ ; https://softwareinc.coredumping.com/wiki/index.php/Main_Page | Coredumping (Software Inc. resmî sitesi ve wikisi) | "Final Overhaul update" yazısı 2026-10-04; wiki güncel | Yüksek | Yama notu satırları; wiki yalnız modlama sayfaları. Sürüm numarası yazıda görünmüyor. |
| S61 | https://store.steampowered.com/news/posts/?feed=steam_community_announcements&appids=362620 (arama sonucu bağlantıları; "Patch notes for Alpha 11.7.54": https://store.steampowered.com/news/app/362620/view/3065238927508765853) | Coredumping, Steam News | Alpha 10.6.9, 11.4.2, 11.5.10, 11.7.54 (tarihler bilinmiyor) | Orta | Yama notları yalnız arama özetinde okundu; Steam News sayfası açılmadı. Geliştirici kaynağı olsa da ikincil okuma olduğu için Orta. |
| S62 | https://steamcommunity.com/app/1342330/discussions/0/3114770279403190837 | Eggcode Games (geliştirici), Steam Community | 2021-01-22 başlangıç; kayıtlar 2021.08–2023.05 | Yüksek | "Patchnotes - Early Access"; sayfa metninin yalnız ilk 100.000 karakteri okundu (185.000 karakterin). |
| S63 | https://steamcommunity.com/app/1342330/discussions/0/4632611455209870802/?ctp=2 | Steam Community, nosedigger, Kyouko Tsukino, JD_Mortal, Chenza | 2024-12-04…20 | Düşük | "User Reviews (and Sales) ?" |
| S64 | https://sites.google.com/ecsd.us/fluffs-store/wiki/game-dev-tycoon-2-0-wiki | Sahibi belirsiz Google Sites ("fluffs-store") | bilinmiyor | Düşük | Kendini wiki olarak tanıtıyor; geliştirici bağlantısı yok. |
| S65 | https://raw.githubusercontent.com/OpenRCT2/OpenRCT2/develop/src/openrct2/world/Park.cpp | OpenRCT2 projesi | develop dalı, erişim günü | Yüksek | Kaynak kod; yalnız WebFetch özeti okundu (ham metin bende yok). |
| S66 | https://forums.openrct2.org/topic/2798-guide-how-to-calculate-park-rating | OpenRCT2 forumu (arşivlenmiş), rehber | tarih bilinmiyor | Orta | Yöntemi yazan analiz; bazı satırlar (guest spawn olasılığı) arama özetinden. |
| S67 | https://steamcommunity.com/app/285330/discussions/0/1812044473330641239 | Steam Community, TheWaxyCactus | 2019-04-08 (2021-05-31'e kadar) | Düşük | "Park Rating Plummet Bug", RCT2 Triple Thrill Pack. |
| S68 | https://www.gamepressure.com/two-point-hospital/reputation/zbb40e | Gamepressure | tarih bilinmiyor | Orta | Rehber; sayısal değer yok. |
| S69 | https://steamcommunity.com/app/535930/discussions/0/2590022385669363819 | Steam Community, Devilfish, sh3riff, Realty13 | 2018-09-10 | Düşük | "Can you actually lower your reputation?" Alıntılar 125 karakter sınırı yüzünden kısmen özet. |
| S70 | https://steamcommunity.com/app/535930/discussions/0/1635292137555692123 | Steam Community, squeezleprime, kakugo, milkygirl | 2019-09-05 | Düşük | "Negative reputation? How to fix?" |
| S71 | https://steamcommunity.com/app/492720/discussions/0/1644295067080451456?l=danish | Steam Community, gigamelon1981, Kunovega, jlking3rd | 2019-07-21…2021-04-16 | Düşük | "Finding the game is too hard", Tropico 6. |
| S72 | https://www.gamepressure.com/tropico-6/how-to-increase-the-approval-rating/z1c185 | Gamepressure | tarih bilinmiyor | Orta | Onay oranı rehberi, formül yok. |
| S73 | https://www.kasedogames.com/post/2016/03/30/project-highrise-march-2016-architect-s-notes | Kasedo Games (yayıncı) | 2016-03-30 | Yüksek | "influence/cachet"; prestige/buzz terimleri kullanılmıyor. |
| S74 | https://steamcommunity.com/app/439340/discussions/6/1850323802575671396 | Steam Community, Peter (geliştirici), Particularly Pyrate | 2019-03-22…2019-04-08 | Orta | Geliştirici yanıtı içeriyor. |
| S75 | https://steamcommunity.com/app/2878420/discussions/0/592896329446908813 | Steam Community, AgeOfBacon, raid, Dantalion | 2025-05-05…08 | Düşük | "Reputation is unbalanced." |
| S76 | https://steamcommunity.com/app/2688950/discussions/0/4634860720019810611 | Steam Community, Spades707, PingZoo | 2024-11-07…19 | Düşük | "Luxury stat stuck at 8%", Planet Coaster 2. |
| S77 | https://steamcommunity.com/app/493340/discussions/0/152390648094532075 | Steam Community, burritonator, ImHelping, Voilodion | 2016-12-04…06 | Düşük | "Coaster Ratings Changing", Planet Coaster. |
| S78 | WebSearch sonuç kümesi (https://sportskeeda.com/esports/what-attraction-prestige-planet-coaster-2-improve ; https://cms.zaonce.net/en-GB/node/6215) | Sportskeeda; Frontier (cms.zaonce.net) | bilinmiyor | Düşük | Yalnız arama özeti; sayfalar açılmadı; planetcoaster.com 403. |
| S79 | WebSearch sonuç kümesi (https://mp1st.com/news/cities-skylines-2-citizen-simulation-and-lifepath-deep-dive-released-game-features-its-own-version-of-twitter) | MP1st | bilinmiyor | Düşük | Yalnız arama özeti; Cities: Skylines 2 için. |
