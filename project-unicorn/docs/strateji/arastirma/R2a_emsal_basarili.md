# R2a: Türdeki emsaller ve ortak noktaları (başarılılar ve başarısızlar)

Tarih: 2026-10-19
Arama sayısı: 18 (WebSearch bütçesi tamamen kullanıldı). Arama aracı çalıştı. Ek olarak Steam'in herkese açık API'leri ve Raijin sayfaları WebFetch ile okundu; bunlar arama sayılmaz.

Okuma notları:
- Satış ve gelir rakamlarının hepsi Raijin tahminidir ("medium confidence"), veri tarihi 2026-10-18. Gamalytic gibi araçlar da kendi tahminini kendi doğrular; bu yüzden rakamlar kaba okunmalı [55]. Gamalytic, VG Insights ve SteamDB sayfalarına doğrudan ulaşılamadı.
- Yorum sayısı ve olumlu oran Raijin ve Steam API'sinden gelir. Bunlar tahmin değil, Steam'in sayımıdır.
- "Kaynaksız (model bilgisi):" ile başlayan satırlar doğrulanmadı.
- Yorum temaları 12-20 yorumluk örneklemlerden çıktı (Steam API, son 365 gün, en yararlı sırasıyla). Temsil gücü sınırlıdır.

## Kısa cevaplar

1. Türdeki başarılılar (Software Inc., Game Dev Tycoon, Mad Games Tycoon 2, Big Ambitions) %92-95 olumlu ve tahminen 170 bin ile 920 bin kopya arasında. Startup Company (%81) ve Good Company (%73) aynı türde olup %90'ın altında kaldı [1][2][3][4][5][6]. Ekipler küçük (Big Ambitions 4 kişi, Software Inc. başta tek kişi), Erken Erişim uzun [45][39].
2. Olumlu yorumlar derinlik, serbestlik, tekrar oynanabilirlik ve sürekli güncellemeyi över. Olumsuzlar hep aynı beş şeyi söyler: kötü ilk saat/öğretici, kalabalık arayüz, geç oyunda döngünün çökmesi, mikro yönetim yorgunluğu ve anlaşılmaz puanlama [19]-[24].
3. %90 üstü alan küçük ekip oyunlarının ortak noktası: tek cümleyle anlatılan döngü, çok uzun Erken Erişim ya da yıllarca süren iyileştirme, sürekli yeni içerik ve güçlü topluluk. İstisna: Cultist Simulator %80; "%90 üstü" listesine girmez [17].
4. Büyüme genelde yıllar süren Erken Erişim, sonra yıllık genişleme paketleriyle oldu. Örnek: RimWorld 1.0'dan sonra yaklaşık yılda bir büyük sürüm [36]; Big Ambitions 3,5 yılda 11 Erken Erişim sürümü [33].
5. Başarısızlar da var ve sessiz. Tech Executive Tycoon %15 olumlu, ~1.100 kopya [7]. Erken Erişim'in ilk ayı 1.0 çıkışından çoğunlukla büyüktür [40].

## Bulgular

### Soru 1: Emsal tablosu

Tablo A: satış ve yorum (hepsi tahmin, Raijin, 2026-10-18)

| Oyun | Çıkış (EA / tam) | Fiyat | Steam yorum ve olumlu | Tahmini kopya | Tahmini brüt gelir |
|---|---|---|---|---|---|
| Software Inc. | EA 2015-05-01 [1][28]; hâlâ Beta [31] | $22.99 | 7.881, %94 [18] | 174 bin | ~$2,4 M [1] |
| Game Dev Tycoon | 2013-08-29 [4] | $9.99 | 45.193, %95 | 923 bin | ~$7,4 M [4] |
| Startup Company | Steam duyuruları 2017-05'ten [34]; tam 2020-04-10 [5] | $12.99 | 6.228, %81 | 134 bin | ~$1,04 M [5] |
| Mad Games Tycoon 2 | EA tarihi bulunamadı; tam 2023-05-31 [2] | $24.99 | 7.847, %94 | 169 bin | ~$2,5 M [2] |
| Big Ambitions | EA 2023-03-10; 1.0 2026-08-28 [3][33] | $25.99 | 14.989, %92 | 329 bin | ~$5,1 M [3] |
| Good Company | EA ~2020 öncesi (ilk duyuru 2019-02) [35]; tam 2022-06-21 [6] | $24.99 | 1.792, %73 | 34 bin | ~$0,51 M [6] |

Tablo B: başarısız ya da zayıf kalan aynı tür oyunlar (hayatta kalan yanılgısına karşı)

| Oyun | Çıkış | Fiyat | Yorum ve olumlu | Tahmini kopya | Tahmini gelir |
|---|---|---|---|---|---|
| Tech Executive Tycoon | EA 2018-12-21 | $19.99 | 53, %15 | 1,1 bin | ~$13,7 bin [7] |
| E-Startup 2: Business Tycoon | 2024-05-14 | $12.99 | 92, %70 | 1,97 bin | ~$15,3 bin [9] |
| CEO Tycoon: My Game Studio | 2024-07-05 | $0.99 | 15, %87 | 247 | ~$196 [8] |

- Not: CEO Tycoon'un yüksek oranı satışa dönmedi; yorum yüzdesi tek başına başarı göstermez [8].
- Not: Startup Company'nin Steam'deki yorumları zamanla %81'e indi; 2017-2020 Beta döneminde Steam duyurusu sıklığı çok yüksekti [34][5].
- Genel taban: 2020-2023 arasında Steam'de çıkan oyunların %50'si $500 ya da altında kazandı (Gamalytic raporu, 2023) [55].

Tablo C: ekip, süre, Erken Erişim, sayfa/demo, stil

| Oyun | Ekip | Geliştirme ve EA süresi | İlk sayfa ve demo | Görsel stil |
|---|---|---|---|---|
| Software Inc. | 2015'te tek kişi [39]; bugünkü ekip bulunamadı | Plan: ~2 yıl [39]. Gerçek: 11+ yıl, hâlâ Beta 1.8.42 (2026-08) [31] | Greenlight sayfası 2015 [39]; Steam verisinde demo alanı yok [28] | Kaynaksız (model bilgisi): 3B, düşük poligon, kuş bakışı ofis |
| Game Dev Tycoon | Bulunamadı (Kaynaksız: iki kişilik stüdyo) | EA yok, doğrudan 1.0 [4] | Bulunamadı | Kaynaksız (model bilgisi): piksel sanat |
| Startup Company | Bulunamadı | ~2 yıl 10 ay Steam Beta (2017-05 → 2020-04) [34] | Bulunamadı | Kaynaksız (model bilgisi): 2B piksel |
| Mad Games Tycoon 2 | Eggcode, bağımsız Alman stüdyo, büyüklük bulunamadı [50] | EA ilk planı 2020 Q4 [50]; Steam duyuruları 2021-01'den [32]; tam 2023-05 (Tahmin: ~2 yıl 4 ay) | Steam verisinde demo alanı yok [30] | Kaynaksız (model bilgisi): 3B, düşük poligon |
| Big Ambitions | Hovgaard Games, 4 kişi [45] | EA 2023-03-10 → 1.0 2026-08-28, ~3,5 yıl [33]; Steam sayfası 2021-05, ~22 ay önce [33][34] | Demo alanı yok [29]; EA öncesi Alfa 10 (2022-03) ve Beta 9 (2023-02) sürümleri duyuruldu [33] | Kaynaksız (model bilgisi): gerçekçi 3B, New York |
| Good Company | Chasing Carrots [6]; büyüklük bulunamadı | v0.6 2020-04 → 1.0 2022-06, ~2 yıl 2 ay [35] | Demo sayfası var: "Good Company Demo" (ID 2009690, Steam arama API'si) | Kaynaksız (model bilgisi): sevimli, stilize 3B |

Ek bulgu, Big Ambitions'ın çıkış hazırlığı (GameDiscoverCo, 2023-04-05) [38]:
- Çıkıştan bir ay önce 67 bin, bir gün önce 93 bin istek listesi.
- İlk ~20 günde 163 bin kopya; tahmini toplamın (329 bin) yaklaşık yarısı [38][3] (Tahmin: hesap bana ait).
- Yaklaşık 1.000 etkileyiciye mesaj, yaklaşık 200 anahtar. Haber siteleri beklenenden az etki etti, ağırlık etkileyicilere kaydı [38].
- Sloganlar: "Grand Theft Auto meets Cities Skylines" ve "House Flipper meets Two-Point Hospital" [38].
- Aynı yayında "Startup Company oynayanlar" hedef kitle olarak seçildi [38]. Yani önceki oyunun kitlesi taşındı.
- Basın duyurusu: 14 günde 150 bin kopya, stüdyo "4 kişilik" [45].

Ek bulgu, Software Inc. tek kişilik uzun süreli yaklaşım:
- Geliştirici 2015'te "I don't have a lot of money to sink in to this project" diyerek EA seçti; ~6 ayda neredeyse tamamlanmış oynanabilir sürüm [39].
- Fiyat planı: $10 ön-alfa, $18 çıkışta [39]. Şimdi $22.99 [28].

### Soru 2: Olumlu ve olumsuz yorum temaları (örneklem: 12-20 yorum/oyun)

Software Inc. [19]
- Olumlu: derinlik, çok farklı oynama biçimi, yıllarca süren ücretsiz güncelleme, mod desteği, çoklu oyuncu. "Software Inc. is a masterpiece of the genre." (2025-11-15, 137 saat)
- Olumsuz: mekanik şişkinliği, arayüz, kötü öğretici, yazılım geliştirme derinliği. "Over time, the game has added more and more mechanics that pull attention away from actually developing software." (2026-04-21, 469 saat)
- Olumsuz: "literally the worst UI any any game i have ever played, so cluttered and so hard to use." (2026-03-03, 11 saat)
- Olumsuz: öğretici bile batırıyor: "Terrible tutorials that ended up making learning worse as using them caused me to over extend and bankrupt." (2026-05-02)

Game Dev Tycoon [21]
- Olumlu: bağımlılık yapan döngü, tekrar oynanabilirlik, ucuz. "The progression from a lone developer in a garage to a massive studio is rock solid." (2026-09-19, 212 saat)
- Olumsuz: gizli puan formülü, tekrar, hata. "Game scores are calculated using hidden, arbitrary rules and formulas which are impossible to keep track of." (2026-07-14)
- Olumsuz: Netflix sürümü tartışması (satın alanlar daha eksik sürümü alıyor).

Startup Company [20]
- Olumlu: sevimli görsel, temiz arayüz, sezgisel öğrenme. "Highly addictive sandbox simulation game with beautiful and accessible UI" (2026-05-14)
- Olumsuz: bekleme, tekrar, zor öğretici, kayıt hatası. "your basically just waiting for stuff, almost like an idle game on your phone." (2026-03-08)
- Olumsuz: "hiring new people, which you will do a lot, is soooo boring." (2026-07-28)

Mad Games Tycoon 2 [22]
- Olumlu: yayıncı modu, bağımlılık yapan döngü, ilk oyuna göre yükseltme. "A true upgrade compared to the first game in almost every aspect." (2025-11-30)
- Olumsuz: kaydırıcı ve puan sistemi keyfî, öğretici yetersiz, eşya yerleştirme can sıkıcı. "The same dumb sliders and arbitrary rating system that plagues all these games." (2026-08-22)
- Olumsuz: yapay zekâ kullanımına tepki (oyun dışı) [22].

Big Ambitions [23]
- Olumlu: derin ama ulaşılır; güncellemeler; öğretici kendi hızında. "The developers are good about updates and bug fixes and I've enjoyed watching the project grow over the years." (2026-08-28, 1.628 saat)
- Olumsuz: erken oyundan sonra döngü çöküyor, boş zaman, mikro yönetim. "The second you pass that point in the beginning, the loop completely falls apart." (2026-01-30, 53 saat)
- Olumsuz: "there's no reason to go anywhere or do anything." (2026-03-10)

Good Company [24]
- Olumlu: üretim ve lojistik derinliği, bağımlılık yapan döngü, sevimli görsel. "The loop of planning, tweaking, and watching everything flow smoothly is incredibly addictive." (2026-07-18)
- Olumsuz: terk edilmiş hissi, kalite-yaşam eksikleri, öğretici kilitleniyor. "it feels clunky, lacks a lot of QOL, and is abandoned by developers." (2026-10-08, 171 saat). Duyuru akışı: 2023'te sıfır, 2024'te iki duyuru [35].

Tech Executive Tycoon (başarısız örnek) [25]
- 15 olumsuz yorumun yaklaşık 9'u "oynanamaz / erken çıkmış". "As of right now the game is completely unplayable." (2018-12-22, 38 dk)
- Eksik vaat: "You can't even delete walls!" (2018-12-23)
- Terk edilmişlik: "he stopped development for 2 years" (2023-01-02) [25]

Beş ortak olumsuz tema (Görüş: yorumlardan çıkardığım sentez): öğretici/ilk saat [19][22][23][24], arayüz [19][24][25], geç oyunda döngü çöküşü ve bekleme [20][23], mikro yönetim [19][20][23], gizli ya da keyfî puanlama [21][22].

### Soru 3: %90 üstü küçük ekip yönetim ve simülasyon oyunlarının ortak noktaları

Tablo D: Raijin, 2026-10-18

| Oyun | Ekip | Olumlu | Tahmini kopya | Tahmini gelir |
|---|---|---|---|---|
| RimWorld | Ludeon; Kickstarter'da tek kişi [42] | %98, 248 bin yorum | 4,81 M | ~$101 M [10] |
| Factorio | Wube; 2012'de tek kişi, 2024'te 31 kişi [41] | %98, 236 bin | 4,60 M | ~$96,6 M [11] |
| Oxygen Not Included | Klei | %97, 145 bin | 3,19 M | ~$47,8 M [12] |
| Papers, Please | Lucas Pope, tek kişi [48] | %97, 81 bin | 1,68 M (Steam) | ~$13,5 M [13] |
| Mini Metro | Dinosaur Polo Club | %96, 16,8 bin | 313 bin | ~$2,5 M [14] |
| Kingdoms and Castles | Lion Shield, iki kurucu [47] | %94, 31,5 bin | 694 bin | ~$8,3 M [15] |
| Dorfromantik | Toukana, 4 mezun [46] | %96, 29,7 bin | 524 bin | ~$4,4 M [16] |
| Cultist Simulator | Weather Factory, 2 kişi [43] | %80, 14,3 bin | 282 bin | ~$3,4 M [17] |

Notlar ve çelişkiler:
- Cultist Simulator listede %90 üstü değil; %80 [17]. Çıkışta bilerek bölücü olduğunu stüdyo da söyledi: Steam ana sayfasına çıkınca daha çeşitli kitle geldi, olumsuz yorum arttı [43][53].
- Papers, Please için 10. yıl duyurusu 5 milyon üstü kopya der (tüm platformlar) [48]; Raijin yalnız Steam'i sayar. Kıyas yaparken ikisini karıştırma.
- Kingdoms and Castles için bir basın duyurusu "1,3 milyon kopya" der [47]; Raijin 694 bin der. Çelişki var, ikisini de tahmin say.
- Raijin sayfaları RimWorld ve Factorio için tam sürüm tarihini gösterir (2018-10-17, 2020-08-14), EA tarihini göstermez [10][11].

Çekirdek döngü
- Papers, Please: ilk planı 6 ay, sürdü 9 ay; tek kişi [48]. Döngü tek cümle: sınırda evrak kontrol et.
- Cultist Simulator, Dorfromantik, Mini Metro: tek cümlelik döngü (kart ve masa; döşeme koy; hat çiz). Dorfromantik'in olumsuzları döngünün tekrarını söyler: "it's just more of the same with different colour palettes." (2026-02-17) [27].
- Görüş: bu oyunlarda döngü küçük, derinlik çok katmanlı; yönetim oyunlarında (Software Inc., Big Ambitions) olumsuz yorumlar tam bu katmanlar arası kopukluğu söyler.

İlk saat
- Cultist Simulator: "You need to waste 10+ hours of frustrating gameplay, with a wiki open on another device" (2026-10-08) [26]. Yani zor ilk saat %80 getirdi.
- Big Ambitions: pozitif yorumcu öğreticiyi övüyor: "lets you do it at your own pace" [23]. Software Inc.: öğretici batırıyor [19].
- Görüş: ilk saat öğretici kalitesi türün %90 duvarındaki en tutarlı ayrım noktası.

Derinlik ve güncelleme
- Klei ONI için EA'da "4-6 haftada bir" güncelleme planladı [51]; 2026'da hâlâ oyun güncellemesi ve DLC çıkıyor (Aquatic Planet Pack 2026-06-11) [37].
- RimWorld: sonraki genişlemeler 2021-07 Ideology, 2022-10 Biotech, 2024-04 Anomaly, 2025-07 Odyssey, 2026-10 sürüm 1.7 [36].
- Factorio: Space Age genişlemesi ve ücretsiz 2.0 aynı gün, 2024-10-21; 2026-06'da "2.1 son büyük güncelleme" duyuruldu [41].

Topluluk
- Dorfromantik ekibi: EA'yı planlanandan 6 ay erken açtı; "ilk haftalar yalnız topluluk yönetimi" yaptılar [46] (arama özeti, tam metne ulaşılamadı).
- Cultist Simulator ekibi: "pazarlamayı birinin tam zamanlı işi yap" dersi [43].
- Big Ambitions: foruma ve etkileyicilere bağımlı büyüme [38].

### Soru 4: Gelişim akışı (ilk sürümden sonra nasıl büyüdüler)

Tablo E: Erken Erişim ve güncelleme sıklığı

| Oyun | EA süresi | Güncelleme ritmi (kaynaklı) |
|---|---|---|
| RimWorld | Kickstarter EA 2013-11, Steam EA 2015 planı, 1.0 2018-10-17 (~5 yıl) [42] | Alfa 16 2016-12, Alfa 17 2017-05, 1.0 2018-10, sonra yılda ~1 büyük sürüm [36] |
| Factorio | 2016-02-25 → 2020-08-14 (~4,5 yıl) [41] | Haftalık "Friday Facts" yazıları (#360'a 1.0'da ulaşıldı) [41] |
| Oxygen Not Included | 2017-02 → 2019-07-30 (~2,5 yıl) [51] | Plan 4-6 haftada bir [51] |
| Software Inc. | 2015-05 → hâlâ Beta [31] | Steam duyurusu yılda ~10 (2023: 10, 2024: 11, 2025: 10, 2026: 9) [31] |
| Big Ambitions | 2023-03-10 → 2026-08-28 (~3,5 yıl) [33] | 11 numaralı EA sürümü; aralık 2-6 ay: 0.2 2023-05, 0.3 2023-08, 0.4 2023-12, 0.5 2024-04, 0.6 2024-10, 0.7 2024-12, 0.8 2025-05, 0.9 2025-09, 0.10 2026-03, 0.11 2026-06 [33] |
| Startup Company | Steam'de ~2 yıl 10 ay Beta [34] | Beta 23-29 arası ~6-7 haftada bir (2019-04 → 2020-02) [34] |
| Good Company | ~2 yıl [35] | v0.6.1-v0.12 arası 1-3 ayda bir (2020-04 → 2021-12), 1.0 2022-06, 1.1 2024-07 [35] |
| Mad Games Tycoon 2 | ~2 yıl (Tahmin) | Duyuru sayısı 2021'de 13, 2022'de 5, 2023'te 5, 2024'te 2 [32] |

Gözlemler
- Görüş: başarılı örneklerde sürüm numaralı, düzenli duyuru ritmi var; ritim bozulunca "terk edilmiş" yorumu çıkıyor (Good Company: 2023'te sıfır duyuru [35][24]).
- Erken Erişim'den 1.0'a geçişte satış çoğunlukla düşer. GameDiscoverCo (2025 çıkışları, EA satışı ≥5.000 olanlar): yalnız %20-21 oyun 1.0'ın ilk 30 gününde EA'nın ilk ayından fazla kazandı; medyan oran %40 [40]. Supermarket Simulator %95 düştü [40].
- Big Ambitions bu kalıba uydu: ilk 20 günde tahmini toplamın ~yarısı [38][3] (Tahmin).
- Academia: School Simulator (6 kişi, aylık gider ~$7.500) EA 2017 sonunda açıldı, 2019 sonuna ~$1 M brüt, ama ilk gün yalnız ~1.100 kopya ve istek listesi ~1.500 idi; uzun kuyruk güncellemelerle ve YouTube'la sürdü [44].
- Kingdoms and Castles: Fig'den $108.767, ~7 ayda Steam'e [47]; çıkıştan yıllar sonra bile her gün birkaç yüz oyuncu [47]; sonraki oyun Nova Roma 2026-03-26'da "proto-erken-erişim" diye açılacaktı [47].

### Başarısızlık örnekleri ve nedenleri (hayatta kalan yanılgısına karşı)

- Tech Executive Tycoon: temel oyun bozuk, vaat edilen özellikler eksik, geliştirme 2 yıl durmuş [25][7].
- Good Company: %73. Yorumlarda kalite-yaşam eksikleri, terk edilmişlik [24][6]. Satış 34 bin, gelir ~0,5 M $.
- CEO Tycoon ve E-Startup 2: %70-87 olumlu ama 247 ve ~2.000 kopya [8][9]. Kalite yorumu yetmedi; görünürlük yoktu.
- Generation Exile (şehir kurma): 35 bin istek listesi ve popüler demoya rağmen EA'da başarısız; geliştirici "paketleme ve kafa karıştıran fragman" ve EA şüpheciliğini suçladı. Kaynak yalnız arama özeti, tam metin 403 verdi [52].
- İstek listesi güvence değil: bir EA oyunu 17 bin istek listesiyle ilk gün ~100 kopya sattı (dönüşüm ~%0,7) [52]; bir diğeri 138 bin istek listesiyle ilk hafta 581 [52]. Bunlar aynı türden değil, sadece uyarı.
- GameDiscoverCo örnek tablosunda 10.000 istek listesi için ilk hafta 0,2 satış/istek varsayımı kullanır (2.000 kopya) [40].

## Bize dersler

Görüş: aşağıdakiler bulgulardan benim çıkarımımdır.

1. Türdeki %90 üstü emsaller cilalı sanatla değil derinlik, serbestlik ve düzenli güncellemeyle kazanmış. Software Inc.'in arayüzü bile yorumlarda "worst UI" diye anılırken %94 [19][18]. Ama taban var: temel döngü çalışmazsa %15'e düşersin [25]. Erdem'in "cilalı küçük kapsam" hedefi türde alışılmış değil; yani riski yüksek bir fark yaratma yolu, ama doğrulanmış bir yol değil.
2. Beş tekrarlayan olumsuz tema Project Unicorn'un kontrol listesi olmalı: (a) öğretici ve ilk saat, (b) arayüz yoğunluğu, (c) geç oyunda döngü çöküşü ve bekleme, (d) mikro yönetim yorgunluğu, (e) gizli ya da keyfî puan. Sprint kartları, kalite alanları ve Frank'in sözleri bu beşe karşı sınanmalı.
3. Gizli formül yorumu iki emsalde çıktı [21][22]. Projedeki yıldız ve uyum hesabının oyuncuya okunur olması bu yüzden değerli.
4. 5.000 satış hedefi başarılı emsallerin (130 bin-920 bin) çok altında, başarısızların (~1-2 bin) üstünde [3][7][9]. Cultist Simulator'da başa baş noktası ~3.000 kopyaydı (bütçe ~£130K) [43]. Yani hedef gerçekçi, ama görünürlük işi gerektiriyor; yorum puanı satış getirmiyor [8].
5. Demo ya da Next Fest, bu türün başarılılarının yolu olmadı; Steam verisinde demo alanı yok (Big Ambitions, Mad Games Tycoon 2) [29][30]. Onlar etkileyici ağı ve istek listesiyle çıktı [38]. Bizim için demo bu yüzden bir seçim, zorunluluk değil; ama etkileyici hedeflemesini (önceki türdeki oyuncular) Big Ambitions'tan öğrenebiliriz [38].
6. Erken Erişim'in ilk ayı ana gelir anı; 1.0 çoğunlukla zayıf [40]. Bu, "ilk sayfa ve çıkış cilası"nın kazanç hesabını destekler. Aksi yön de var: terk edilmişlik algısı yorumları öldürür [24].
7. Uzun bir kuyruk istiyorsak Software Inc. ve RimWorld modeli: aylık-yıllık net bir ritim ve yıllık genişleme [31][36]. Tek kişilik ekip için ritim, kapsamdan daha önemli olabilir (Görüş).
8. Cultist Simulator dersi: bilerek zor ve bölücü ilk saat %80 getirdi [26][43]. Hedef %90 ise ilk saat yumuşak olmalı.

## Bulunamayanlar

- Gamalytic, VG Insights ve SteamDB'den doğrudan sayılar (sayfalara ulaşılamadı; Raijin kullanıldı).
- Mad Games Tycoon 2'nin Erken Erişim başlangıç tarihi ve Eggcode'un ekip büyüklüğü.
- Game Dev Tycoon, Startup Company, Software Inc. (bugün), Good Company ekip büyüklükleri.
- Hiçbir türdeki oyun için ilk Steam sayfası tarihi ve demo tarihi (Big Ambitions sayfası ~2021-05, haber akışından çıkarım; Good Company demo sayfası var ama tarihi bilinmiyor).
- Mini Metro, Dorfromantik, Kingdoms and Castles için yayınlanmış sürüm sıklığı verisi (Steam haber akışı bu oyunlar için okunmadı).
- Dorfromantik röportajının tam metni (zaman aşımı); yalnız arama özeti kullanıldı.
- ONI Erken Erişim ekip büyüklüğü.
- Başarısız yönetim oyunlarının yayımlanmış ölüm sonrası (postmortem) yazıları: arama bulamadı; başarısız örnekler Raijin ve Steam yorumlarından geldi.
- Görsel stil: kaynaklı doğrulama yapılmadı, tabloda "Kaynaksız" işaretli.

## Kaynaklar

Raijin tahminleri (tümü veri tarihi 2026-10-18):
1. https://raijin.gg/app/362620/Software_Inc (Software Inc.)
2. https://raijin.gg/app/1342330/Mad_Games_Tycoon_2
3. https://raijin.gg/app/1331550/Big_Ambitions
4. https://raijin.gg/app/239820/Game_Dev_Tycoon
5. https://raijin.gg/app/606800/Startup_Company
6. https://raijin.gg/app/911430/Good_Company
7. https://raijin.gg/app/274960/Tech_Executive_Tycoon
8. https://raijin.gg/app/2945420/CEO_Tycoon_My_Game_Studio
9. https://raijin.gg/app/2547750/E-Startup_2
10. https://raijin.gg/app/294100/RimWorld
11. https://raijin.gg/app/427520/Factorio
12. https://raijin.gg/app/457140/Oxygen_Not_Included
13. https://raijin.gg/app/239030/Papers_Please
14. https://raijin.gg/app/287980/Mini_Metro
15. https://raijin.gg/app/569480/Kingdoms_and_Castles
16. https://raijin.gg/app/1455840/Dorfromantik
17. https://raijin.gg/app/718670/Cultist_Simulator

Steam API (okuma tarihi 2026-10-19):
18. https://store.steampowered.com/appreviews/362620?json=1&num_per_page=0&language=all&purchase_type=all (7.429 olumlu, 452 olumsuz)
19. https://store.steampowered.com/appreviews/362620?json=1&num_per_page=20&language=english&review_type=negative&filter=all&day_range=365 (olumlu için review_type=positive)
20. https://store.steampowered.com/appreviews/606800?json=1&num_per_page=20&language=english&review_type=negative&filter=all&day_range=365 (olumlu için review_type=positive)
21. https://store.steampowered.com/appreviews/239820?json=1&num_per_page=20&language=english&review_type=negative&filter=all&day_range=365 (olumlu için review_type=positive)
22. https://store.steampowered.com/appreviews/1342330?json=1&num_per_page=20&language=english&review_type=negative&filter=all&day_range=365 (olumlu için review_type=positive)
23. https://store.steampowered.com/appreviews/1331550?json=1&num_per_page=20&language=english&review_type=negative&filter=all&day_range=365 (olumlu için review_type=positive)
24. https://store.steampowered.com/appreviews/911430?json=1&num_per_page=20&language=english&review_type=negative&filter=all&day_range=365 (olumlu için review_type=positive)
25. https://store.steampowered.com/appreviews/274960?json=1&num_per_page=15&language=english&review_type=negative&filter=all
26. https://store.steampowered.com/appreviews/718670?json=1&num_per_page=20&language=english&review_type=negative&filter=all&day_range=365
27. https://store.steampowered.com/appreviews/1455840?json=1&num_per_page=15&language=english&review_type=negative&filter=all&day_range=365
28. https://store.steampowered.com/api/appdetails?appids=362620&cc=us&l=english
29. https://store.steampowered.com/api/appdetails?appids=1331550&cc=us&l=english
30. https://store.steampowered.com/api/appdetails?appids=1342330&cc=us&l=english
31. https://api.steampowered.com/ISteamNews/GetNewsForApp/v2/?appid=362620&count=40&maxlength=100&feeds=steam_community_announcements (2023-09 → 2026-10)
32. https://api.steampowered.com/ISteamNews/GetNewsForApp/v2/?appid=1342330&count=300&maxlength=1&feeds=steam_community_announcements
33. https://api.steampowered.com/ISteamNews/GetNewsForApp/v2/?appid=1331550&count=300&maxlength=1&feeds=steam_community_announcements
34. https://api.steampowered.com/ISteamNews/GetNewsForApp/v2/?appid=606800&count=300&maxlength=1&feeds=steam_community_announcements
35. https://api.steampowered.com/ISteamNews/GetNewsForApp/v2/?appid=911430&count=300&maxlength=1&feeds=steam_community_announcements
36. https://api.steampowered.com/ISteamNews/GetNewsForApp/v2/?appid=294100&count=300&maxlength=1&feeds=steam_community_announcements
37. https://api.steampowered.com/ISteamNews/GetNewsForApp/v2/?appid=457140&count=300&maxlength=1&feeds=steam_community_announcements

Makaleler ve basın:
38. GameDiscoverCo, Big Ambitions derin inceleme, 2023-04-05: https://newsletter.gamediscover.co/p/deep-dive-how-big-ambitions-hit-it
39. Software Inc. geliştirici blogu, "Fifteenth update – Early access", 2015-02: https://softwareinc.coredumping.com/2015/02/
40. WN Hub, GameDiscoverCo EA ve 1.0 verisi, 2025-12-10: https://wnhub.io/news/stores-and-publishing/item-49521
41. Wikipedia, Factorio (okuma 2026-10-19): https://en.wikipedia.org/wiki/Factorio
42. Wikipedia RimWorld https://en.wikipedia.org/wiki/RimWorld ; Ludeon blogu, 2015-07: https://ludeon.com/blog/2015/07/on-the-upcoming-steam-release
43. Alexis Kennedy, Cultist Simulator çıkış değerlendirmesi, 2018-06-11: https://www.gamedeveloper.com/game-platforms/after-the-dawn-a-mini-retrospective-on-cultist-simulator
44. Simon Carless, Academia: School Simulator vaka çalışması, 2020-02-26: https://www.gamedeveloper.com/business/steam-sales-case-study-academia-school-simulator-
45. Big Ambitions basın duyurusu, 150.000 kopya / 14 gün (2023): https://gamespress.com/Sandbox-Sim-Big-Ambitions-Sells-150000-Copies-In-14-Days
46. Dorfromantik geliştirici röportajı (yalnız arama özeti): https://www.digitec.ch/en/page/dorfromantik-developer-success-has-opened-a-lot-of-doors-for-us-23775
47. Kingdoms and Castles: https://gamingonlinux.com/2026/01/city-builder-nova-roma-from-the-devs-of-kingdoms-and-castles-delayed-until-march ; https://gamespress.com/Kingdoms-and-Castles-patch-daily-deal (arama özeti)
48. Papers, Please 10. yıl, 5 milyon: https://www.gamingonlinux.com/2023/08/papers-please-turns-10-and-hits-5-million-sales ; Reason, 2013-09-26: https://reason.com/2013/09/26/papers-please-politics-in-games-and-the/
49. Dinosaur Polo Club röportajı (Pocket Gamer, arama özeti): https://www.pocketgamer.biz/interview/72525/indie-spotlight-dinosaur-polo-club-mini-motorways/
50. Eggcode / Mad Games Tycoon 2 bilgisi: https://www.gamepressure.com/games/series.asp?ID=3818 ; https://automaton-media.com/articles/newsjp/20200612-127206/
51. ONI EA ve çıkış: https://www.gamingonlinux.com/2019/07/space-colony-sim-oxygen-not-included-to-leave-early-access-on-july-30th ; https://kleiforums.com/forums/topic/104004-oxygen-not-included-roadmap-march-2019/
52. İstek listesi ve EA başarısızlıkları (arama özetleri): https://gameworldobserver.com/2022/01/17/why-indie-platformer-neko-ghost-jump-only-sold-100-units-at-launch-despite-getting-17000-wishlists ; https://www.inkl.com/news/7-years-and-35-000-wishlists-later-one-of-steam-s-most-popular-city-builder-demos-failed-miserably-enough-at-early-access-for-its-creator-to-question-everything-none-of-this-means-we-were-owed-anything
53. PC Gamer, Cultist Simulator 100.000 kopya: https://pcgamer.com/cultist-simulator-has-sold-over-100000-copies
54. (boş bırakıldı)
55. Gamalytic yöntemi ve 2023 raporu: https://www.steampageanalyzer.com/blog/gamalytic-vs-vg-insights ; https://wnhub.io/news/stores-and-publishing/item-42136
