# A1: Mikrodan makroya: birinci saat ile yirminci saatin farklı olduğu oyunlar

Tarih: 2026-10-19
Arama sayısı: 13 (WebSearch bütçesi tamamen kullanıldı; araç hata vermedi; 1 arama alakasız spor sonuçları döndürdü, boşa gitti). Ek olarak Steam mağaza sayfaları, Steam yorum API'si, Wikipedia, geliştirici forumu ve wiki sayfaları WebFetch ile okundu; bunlar arama sayılmaz.

Okuma notları:
- Yorum sayıları ve olumlu oranlar Steam API'sinden, İngilizce yorumlar, 2026-10-19 [5]. Mağaza sayfasındaki sayılar bundan biraz farklı olabilir (önbellek, dil).
- Steam yorum alıntıları yerel bir betikle API'nin ham JSON'undan doğrulandı (Big Ambitions, Frostpunk 2, Plutocracy, Civ VII, Software Inc., Startup Company, Mad Games Tycoon 2, Game Dev Tycoon, Factorio, Victoria 3, Stellaris). Parantez içi: oyuncunun toplam oyun saati, yorumun "yararlı" oyu, yorum tarihi. Oyuncu adı yazmıyoruz.
- Wikipedia, mağaza sayfaları ve basın yazıları WebFetch'in özetleyici modeli üzerinden okundu. Bu kaynaklardan gelen alıntılar kelimesi kelimesine kontrol edilmedi; yanlarında "(özetleyici)" yazar.
- Yorum örneklemleri küçük: her oyun için son 365 günün ya da tüm zamanların ilk 100 yorumu. Temsil gücü sınırlıdır.
- Steam puanı oyunun aşama geçişini değil genel memnuniyeti ölçer. Aşama geçişi puana karışan birçok etkenden yalnız biridir.

## Kısa cevaplar

1. Katman değiştiren oyunlar var ve en sevilenler eski katmanı açık bırakıyor. Factorio (%98), Kenshi (%95), Software Inc. (%94), Big Ambitions (%91) oyuncuyu hiçbir yere zorlamaz; yeni katman eskinin üstüne eklenir [5][15][33][8][1]. Katmanı zorla değiştirenler düşük puanlı: Civ VII %50, Frostpunk 2 %78 (birinci oyun %93) [5][29][19]. Hep mikroda kalanlar (Startup Company %80, Game Dev Tycoon %95, Mad Games Tycoon 2 %93) yorumlarda "iki saat sonra aynı iş" şikâyeti alıyor [5][12][13][14].
2. Geçişi çoğunlukla oyuncunun seçimi ve bir bina ya da para eşiği tetikler. Big Ambitions'ta yöneticiler masa ve bilgisayar ister, bu yüzden merkez ofis gerekir [1]. Software Inc.'te lideri işe alır, İK eğitimi verir, altı ay beklersin [9]. Spore'da aşamanın hedefi bitince ilerleme seçeneği açılır ama aşamada kalabilirsin [27]. Devredilen şey hep rutin iştir: fiyat, sipariş, maaş, şikâyet. Yeni fiiller: atamak, kural koymak, rapor okumak, siyaset yapmak.
3. Başarısızlıkların beş kalıbı var. (a) Son katman sığ kalıyor: Spore'un aşamaları, Bannerlord'un krallık katmanı. (b) Sevilen katman gidiyor: Frostpunk 2, Civ VII. (c) Otomasyon ya hiç çalışmıyor ya da kararı siliyor: Big Ambitions'ta merkez "kendi kendine işliyor", Software Inc.'te pazarlama "sonsuza dek" sürüyor. (d) Menüden yönetim sıkıyor: "bir kareye tıkla, onay işaretine tıkla, çubuğun dolmasını bekle". (e) Geç oyunda para birikiyor ama yapacak iş kalmıyor. Plutocracy ayrıca bizim için özel bir uyarı: siyaset var ama sonucu değiştirmiyor ve olaylar zar atmaya benziyor.
4. "Kendin kodla, sonra yönet, sonra lobi ve diplomasi" vaadini tek pakette veren bir oyun bulamadım. Yarılar var: Software Inc. ve Big Ambitions (kurucu ve yönetici), Plutocracy (lobi ve siyaset, ama zayıf), Capitalism Lab (yapay zekâ CEO'lu iştirakler), mobilde Founder Sim (Seed'den Series C'ye turlar ve CXO'lar). Alan boş görünüyor ama aramam sınırlıydı; "kesin boş" denmez [1][8][36][37][40].
5. 40-60 dakikalık demoda geçişi hissettirmenin kanıtlı bir örneğini bulamadım. Bulduğum: Next Fest'in en iyi 50 demosu "uzun yatay dilim" yapıyor (tüm ana mekanikler, az bölüm) ve yavaş açılan oyunlar listede yok [44]. Factorio demosu ayrı uygulama; 2019'da 2 saatten yaklaşık 10 saate çıkarıldı [17]. Mağaza sayfası düzeyinde Big Ambitions, Spore ve Bannerlord büyümeyi aşama aşama anlatıyor [1][26][34].

## Bulgular

### Soru 1: Hangi oyunlar birinci saatte ve yirminci saatte farklı iş yaptırıyor?

Tablo: Steam İngilizce yorum, 2026-10-19 [5]

| Oyun | Katman değişimi | Olumlu / yorum | Kaynak |
|---|---|---|---|
| Factorio | Elle üretim, otomasyon, lojistik, robot; sonra Space Age | %98 / 146.918 | [15][18] |
| Kenshi | Hiçbir gücü olmayan kişi, ekip, üs, fraksiyon | %95 / 57.109 | [33] |
| Software Inc. | Kurucu, ekipler, takım lideri, rakip alımı, hisse | %94 / 5.814 | [8][9] |
| Spore | Hücre, yaratık, kabile, medeniyet, uzay | %93 / 41.881 | [26][27] |
| Big Ambitions | Kendi elinle çalış, çalışan, merkez ofis ve yöneticiler, ithalat, fabrika, yatırım | %91 / 6.491 | [1][2][3] |
| Bannerlord | Tek kahraman, klan, krallık | %87 / 116.321 | [34] |
| Tropico 6 | Dört çağ (çağ içi fark kaynakta yok) | %87 / 13.680 | [35] |
| Stellaris | Erken keşif, geç kriz; sektör ve vali ile bölgesel yönetim | %86 / 105.992 | [32] |
| Plutocracy | Şirket al ve birleştir, müdür ata, lobici tut | %79 / 828 | [36] |
| Frostpunk 1, sonra 2 | Tek bina ve ısı düzeni, sonra bölge, fraksiyon, konsey | %93 / 46.640, sonra %78 / 11.851 | [22][19][20] |
| Good Company | Garajda elle üretim, lojistik, tam otomatik makine | %70 / 899 | [38] |
| Victoria 3 | Hiç mikro yok: kanun, ekonomi, nüfus grupları | %68 / 28.284 | [31] |
| Civ VII | Üç çağ, çağ sonunda zorunlu geçiş | %50 / 38.340 | [29][30] |
| Universal Paperclips | Tıkla, otomat, pazar, dünya, uzay | (web oyunu) | [28] |
| Capitalism Lab | Tek şirket, DLC ile iştirak ve yapay zekâ CEO | Steam'de yok | [37] |

Karşı örnekler (rol aynı kalır, yalnız ölçek büyür):
- Game Dev Tycoon: garaj, kendi ofis, daha büyük oyun. %95 / 25.302. Mağaza metni üç aşama sayar: garaj, kendi ofis, daha büyük oyun [13][5].
- Startup Company: CEO olarak site kurar, personel alır, rakip satın alır. %80 / 3.103 [11][5].
- Mad Games Tycoon 2: garajdan dev şirkete. %93 / 2.352. Mağaza metni otomasyon ya da devir anmıyor [14][5].

Başka bulduklarım: Mount & Blade II Bannerlord ve Kenshi (tabloda), Good Company, Capitalism Lab, Plutocracy, Universal Paperclips. Mobilde Founder Sim (Soru 4).

Görüş: Tablo bir örüntü gösteriyor. %90 ve üstü olanların (Factorio, Kenshi, Software Inc., Spore, Game Dev Tycoon, Mad Games Tycoon 2) ortak noktası, hiçbirinin oyuncuyu eski katmandan zorla çıkarmaması. %50-78 arası olanlar (Civ VII, Frostpunk 2, Victoria 3) oyuncunun elindeki bir şeyi aldı. Bunun nedeni geçiş olmayabilir; başka etkenler karışır.

### Soru 2: Geçişi ne tetikliyor, ne devrediliyor, oyuncular nasıl karşıladı?

**Big Ambitions** (kendin çalış, sonra yönetici, sonra imparatorluk)
- Tetikleyici: para ve bina eşiği. Mağaza metnine göre yöneticiler masa ve bilgisayar ister, bu yüzden merkez ofis gerekir (özetleyici) [1].
- Devredilen: İK, lojistik, satın alma. 1.0'da fiyat müdürü geldi: "update prices of all items in an entire neighborhood at once". Yatırımlar günlük otomatik yapılabiliyor [2].
- Yeni fiiller: ithalat, depo ağı, fabrika, yatırım fonu, gayrimenkul, lüks mülk [1][3].
- Eski katman: açık. Basın yazısı, tek mağazada kalabileceğini söylüyor [3].
- Karşılama (olumlu): "You sit in the chair and delegate your managers from your cell-phone." (101,5 sa, 0 oy, 2026-10-10) [4].
- Karşılama (olumlu ama eleştirili): merkez "automates itself, which doesn't really give into the whole CEO fantasy" (125,8 sa, 0 oy, 2026-10-08) [4].
- Karşılama (olumsuz): "i dont get the point of being able to hire a logistics and purchasing manager when i still have to manually do it myself" (76,2 sa, 7 oy, 2026-09-03) [4].
- Karşılama (olumsuz): "eventually all you do is make phone calls from your house" (43,9 sa, 11 oy, 2026-09-05) [4].
- Geliştirici notu: fabrika özelliği "didn't land well", yeniden yapılıyor [7].

**Software Inc.** (kurucu, ekip, lider)
- Tetikleyici: oyuncu kurar. Lider işe al, İK eğitimi ver, altı ay bekle, rolünü lider yap [9].
- Devredilen: geliştirme döngüsü, maaş ve şikâyet yönetimi. Wiki: "After about 3 to 4 contracts, they should start going on their own." [9] Mağaza: liderlere görev devri anılıyor (özetleyici) [8].
- Eski katman: açık; istersen kendin yönetirsin. Wiki sayfası "devam eden çalışma" işaretli, otomasyonun tam kapsamını yazmıyor [9].
- Karşılama (olumlu, %94): "later on it's just doing the same stuff all the time and managing growing team becomes just tedious" (60,7 sa, 2 oy, 2026-09-27) [10].
- Karşılama (olumsuz): "if building wide and not making use of automation it's micromanagement hell" (152,2 sa, 17 oy, 2025-06-08) [10].
- Karşılama (olumsuz): sistemlerin sonradan eklenmesi ve kapatılamaması: "there is no way to opt out of these mechanics" (469,3 sa, 56 oy, 2026-04-21) [10].
- Karşılama (olumsuz): "no longer a game about developing software, its become a HR/corporate greed simulator" (109,0 sa, 6 oy, 2024-01-30) [10].
- Not: Kaynaklarımda "kurucu kendisi kod yazar" ifadesi doğrulanmadı. Mağaza yalnız kurucunu özelleştirmeni söylüyor [8].

**Factorio** (el emeğinden otomasyona)
- Tetikleyici: oyuncunun seçimi ve araştırma. Mağaza: önce "chopping trees, mining ores and crafting mechanical arms and transport belts by hand", sonra "industrial powerhouse" (özetleyici) [15].
- Devredilen: üretimin kendisi makineye geçer. Oyuncu tasarımcı kalır; fiil hep "inşa et" olarak sürer.
- Karşılama: "Every time I thought I had things under control, the game found a new way to challenge me." (382,9 sa, 15 oy, 2026-10-06) [18].
- Karşılama: "Even after you've beaten the game, the factory yearns for more" (342,6 sa, 2026-10-05) [18].
- Karşılama: 350 saatte doymak da var: "after almost 350 hours, I've had my fill of Factorio" (348,2 sa, olumlu, 2026-10-16) [18].

**Frostpunk 1'den 2'ye** (seri düzeyinde mikrodan makroya)
- Geçiş: aynı oyuncu bir oyundan diğerine geçerken ölçek değişti. Bina yerine bölge kurulur, zaman günler yerine haftalarla akar, 100 üyeli konsey oy verir (özetleyici) [20]. Oyun ilk oyundan 30 yıl sonra geçer [23].
- Eski katman: yok. Bölgenin içinde bina seçilir ama ızgara düzeni gitti [24].
- Karşılama (olumsuz): "it's just a non-stop fight against your own people" (22,8 sa, 15 oy, 2026-10-05) [21].
- Karşılama (olumsuz): "the politics became more intimidating than the cold" (19,8 sa, 2 oy, 2026-09-26) [21].
- Karşılama (olumsuz): "You have alot less control over the specifics of game play compared to the first game" (19,8 sa, 2026-09-26) [21].
- Karşılama (olumlu): "the voting system gives a more Roman Senate vibe than the authoritarian system of FP1" (14,9 sa, 2026-10-03) [21].
- Karşılama (olumlu): "placing a philosophical/political cost on every decision you make" (12,6 sa, 2026-10-08) [21].
- Puan: birinci oyun %93, ikinci oyun %78 [5]. Metacritic PC puanı 85 (özetleyici) [20]; eleştirmen puanı Steam puanından yüksek.
- Bir eleştirmene göre ilk görev siyaset sistemini öğretmeyecek kadar basit (özetleyici) [24].

**Spore** (beş aşama)
- Tetikleyici: aşamanın ana hedefi bitince ilerleme seçeneği açılır; aşamada kalmak serbest [27].
- Devir: her aşama sonunda üç "sonuç özelliği" (saldırgan ya da barışçıl oynayışa göre) sonraki aşamayı şekillendirir [27].
- Yeni fiiller: ye ve kaç, sosyalleş ya da saldır, kabileyi yönet (RTS), şehir kur, gezegen yönet [27].
- Karşılama: Steam %93 [5]. Eleştirmenler aşamaları sığ buldu. Eurogamer: aşamalar "too fleeting"; GameSpot: "individual gameplay elements are extremely simple" (Wikipedia aktarımı, özetleyici) [27].
- Mağaza tek cümlelik vaat veriyor: "From Single Cell to Galactic God" (özetleyici) [26].

**Civ VII** (zorunlu çağ geçişi)
- Tetikleyici: çağ biter, "kriz olayları" gelir; oyuncu yeni uygarlık seçer ya da sürdürür. 1.4 güncellemesi (2026-05) tüm kampanyayı tek uygarlıkla oynamaya izin veriyor (özetleyici) [29]. Yani geliştirici geri adım attı.
- Karşılama: %50 / 38.340 [5]. "It feels like three shorter games taped together" (102,7 sa, 9 oy, 2026-10-01) [30].
- Karşılama: "Nobody likes being halfway into a war or about to settle to just be forced into a new age." (18,0 sa, 6 oy, 2026-10-03) [30].
- Karşılama: "era transitions feel like natural disasters that happen to your civilisation" (38,6 sa, 3 oy, 2026-09-25) [30].

**Victoria 3 ve Stellaris** (dolaylı yönetim)
- Victoria 3: kontrol kanun, ekonomi ve nüfus grupları üzerinden; mağaza metni birim ya da bina kontrolünden söz etmiyor (özetleyici) [31]. %68 / 28.284 [5].
- Victoria 3 yorumu: "you just assign a general and watch a UI progress bar go back and forth" (436,2 sa, 1 oy, 2026-10-18) [31].
- Stellaris: sektör, idari bölgedir; her sektörün lideri olabilir ve etkileri o sektördeki tüm koloniye uygulanır (Paradox wiki, sayfanın yalnız ilk kısmı okundu) [32].
- Stellaris yorumu: "devolves into waiting simulator for hours unless you force things to happen" (9,8 sa, 3 oy, 2026-10-15) [32].
- Stellaris yorumu: "A very well made piece of spreadsheeting software" (265,6 sa, 2026-10-18) [32].

**Plutocracy** (şirket, müdür, lobi)
- Mağaza: sıfırdan başla, şirket al ve birleştir, kartel kur, şirketleri doğrudan ya da atanan müdürlerle yönet, lobici tut, kampanya finanse et (özetleyici) [36]. Erken Erişim 2019-11-21'den beri, tam sürüm 2026 için planlı [36].
- Karşılama: %79 / 828 [5]. Olumlu bir oyuncu, tek tek ilişki kurmanın geç oyunda bıktırdığını yazıyor: "managing characters one-by-one becomes incredibly tedious in the mid-to-late game" (252,3 sa, 0 oy, 2026-10-01) [36].
- Karşılama (olumsuz): "Every single aspect which includes politics does not really change any outcome." (20,6 sa, 5 oy, 2024-11-02) [36].
- Karşılama (olumsuz): "EVERY event is just rolling the dice on how screwed you get this quarter." (15,2 sa, 0 oy, 2026-10-11) [36].
- Karşılama (olumsuz): olaylar "bribe or do nothing" şıkkına iniyor ve ikisi de aynı sonuca varıyor (15,2 sa, 2026-10-11, özet) [36].
- Karşılama (olumsuz): "The lobbying system is overly difficult and impossible to win." (49,1 sa, 2 oy, 2025-05-25) [36].

**Capitalism Lab, Kenshi, Bannerlord, Good Company, Paperclips** (kısa)
- Capitalism Lab: iştirak DLC'si "multiple subsidiary companies with AI CEOs at the helm" kurar ve borsaya açar; "Assign Firm Manager" arayüzü var. Şehir DLC'si belediye başkanlığı verir ("basically playing an indirect city builder") [37]. Oyun Steam'de değil, kendi sitesinde satılıyor [37].
- Kenshi: "not the chosen one" başlangıcı, üs, fraksiyon. Wikipedia'da PC Gamer, arayüzün grup büyüdükçe "cumbersome" olduğunu söylüyor (özetleyici) [33].
- Bannerlord: kahraman, klan, krallık [34]. IGN: "The actual kingdom-management strategy is weak" (Wikipedia aktarımı, özetleyici) [34].
- Good Company: "Turn a garage into your first manufacturing headquarters", sonra lojistik ve "fully automated machines" (özetleyici) [38].
- Universal Paperclips: tıklama, otomat, pazarlama, tekel, dünya, uzay; her aşama sonunda büyüme düzleşir ve bir atılım gerekir [28].

### Soru 3: Başarısızlık kalıpları

**(a) Aşama sığ kalıyor**
- Spore: eleştirmenler aşamaları sığ buldu ama hangisinin en sığ olduğunda anlaşamadılar. Zero Punctuation'a göre oyun, her biri başka bir oyunun sığ hâli olan beş oyun olmaya çalışıyor (Wikipedia aktarımı, özetleyici) [27].
- Bannerlord: krallık yönetimi zayıf, dünya yağmalanmak için var (IGN aktarımı, özetleyici) [34].
- Startup Company: "Like an idle game with extra steps.." (67,3 sa, 2 oy, 2025-05-25) [12].
- Big Ambitions: "The supposed rivals do absolutely nothing to crush you" (98,8 sa, 3 oy, 2026-09-15) [4]. Rakip katmanı boş.

**(b) Oyuncu sevdiği katmanı kaybediyor**
- Frostpunk 2: soğuk ana tehdit olmaktan çıktı, oyuncular bunu "own people" savaşı olarak yaşadı [21]. Mikro katman (ızgara, bina yerleştirme) gitti.
- Civ VII: uygarlık kimliği çağ sonunda siliniyor; 1.4 ile geri alma yolu açıldı [29][30].
- Software Inc.: sistemler eklendikçe oyun başka bir şeye dönüştü: "I want the older versions back..." (109,0 sa, 2024-01-30) [10].

**(c) Otomasyon kararı yok ediyor ya da çalışmıyor**
- Big Ambitions: merkez kendi kendine işleyince "CEO fantasy" kayboluyor [4]. Öte yandan yönetici alıp yine elle sipariş yazmak da şikâyet [4]. Yani iki yönde de hata var: devir ya gerçek olmuyor ya da boş bırakıyor.
- Software Inc.: otomatik pazarlama "seems to want to market forever" (55,3 sa, 0 oy, 2026-09-26) [10].
- Geliştirici görüşü: Arcen'in kurucusu, 2014: "Automation is how most 4x titles solve this, as you note, but I'm not a fan of that." Başka bir forum üyesi: "AI Governor is not a solution, it is a band-aid on a design issue." [41]
- Bir strateji bloggerı (2016): vekile devir ağır yükü hafifletiyor ama oyun "ultimately about growing big" olarak kalıyor, otomasyon bunu çözmüyor (özetleyici) [42].

**(d) Menüden yönetim sıkıyor**
- Frostpunk 2: "I hate the fact I have to click on a tile click the check mark and then wait for a progress bar" (0,8 sa, 36 oy, 2026-09-22) [21].
- Startup Company: "you don't actually make decisions, or design a company, you just move the numbers up" (19,0 sa, 5 oy, 2026-04-02) [12].
- Game Dev Tycoon: "a waiting simulator" (2,3 sa, 2 oy, 2026-01-05) [13].
- Stellaris: "spreadsheeting software" [32]. Victoria 3: "UI progress bar" [31].

**(e) Geç oyunda boşluk**
- Big Ambitions: "the money keeps coming and you build more stuff until there is nothing you can do anymore" (98,8 sa, 3 oy, 2026-09-15) [4]. "...basically becomes a waiting game" (85,0 sa, 0 oy, 2026-10-01) [4].
- Mad Games Tycoon 2: "No more challenges, no more surprises, just repetitive clicking and random review scores." (161,7 sa, 5 oy, 2024-05-23) [14].
- Game Dev Tycoon: "completed the game earning millions without ever implementing any research" (22,1 sa, 11 oy, 2026-03-21) [13]. Sistemlerin çoğu oyun sonunda gereksizleşiyor.
- Plutocracy: olaylar hep olumsuz ve zar gibi; siyaset sonucu değiştirmiyor [36].
- Frostpunk 2: dengesi bozuk geç oyun ve kısa kampanya yorumları var (özetleyici) [21].

**(f) Başarıyı gösteren ortak örüntü**
- Görüş: Eski katmanı koruyan, yeni katmanı ekleyen oyunlar (Factorio, Kenshi, Software Inc., Big Ambitions) en yüksek puanlı. Ama bu oyunlar da geç oyun yorgunluğundan kurtulmuyor (Factorio'da 350 saatte "doydum", Software Inc.'te "aynı işi yapıyorsun") [18][10].

### Soru 4: "Kendin kodla, yönet, lobi ve diplomasi" veren oyun var mı? Alan boş mu?

| Oyun | Kurucu işi | Yönetim ve devir | Siyaset, lobi | Not |
|---|---|---|---|---|
| Software Inc. | Kurucu özelleştirilir; elle kod doğrulanmadı | Ekip, takım lideri | Yok; rakip alımı, patent, hisse var | %94 [8] |
| Startup Company | CEO olarak site kurar | Personel, ofis | Yok; rakip birleştirme var | %80; Hovgaard Games'in ilk oyunu [11][6] |
| Big Ambitions | Dünyada fiziksel dolaşan karakter; her işi kendin yaparsın | Merkez ofis yöneticileri | Yok | Aynı geliştirici; mağaza "Startup Company"yi anıyor [1][6] |
| Game Dev Tycoon, Mad Games Tycoon 2 | Garaj | Personel | Yok | Rol aynı kalır [13][14] |
| Plutocracy | Yok (tarihî sermayeyle başlar) | Müdür atama | Var: lobici, kampanya | %79 / 828; siyaset sonuç değiştirmiyor [36] |
| Capitalism Lab | Yok | Yapay zekâ CEO'lu iştirak (DLC) | Belediye başkanlığı (DLC) | Steam dışı [37] |
| Good Company | Garajda elle | Lojistik, otomat | Yok | %70 / 899 [38] |
| Venture Capital Tycoon | Yok (yatırımcı tarafı) | Fon kurma, personel | Yok | 2026-09-01 çıktı, 1 yorum [39] |
| Founder Sim (mobil) | CEO olarak başlar | CXO'lar departmanı otomatikleştirir | Yok; Seed-Series C turları, hisse seyrelmesi, M&A var | 2026-04-06; 26 puan, 1.000'den az indirme [40] |
| E-Startup 2, Software Company | Ürün şirketi ve oyun stüdyosu | Personel | Yok | %67 / 87 ve %37 / 16 yorum [39] |

- Sonuç: Kaynaklarımda üç adımı (kod, yönetim, lobi) birleştiren bir oyun yok. Her biri bir yarıyı veriyor.
- Steam mağaza arama API'si ("startup tycoon", "venture capital", "software company", "ceo simulator", "capitalism") ve üç WebSearch ile tarandı [46]. Tarama dar; Steam etiket sayfaları ve 2026 çıkışlarının hepsi taranmadı.
- Tahmin: Alan boş çünkü iki yarı farklı türlerde: tycoon (süreç) ve büyük strateji (siyaset). Plutocracy ikisini birleştirmeye çalıştı ve yorumlar siyasetin "sonuç değiştirmediğini" söylüyor [36]. Bu, birleştirmenin kolay olmadığını gösterir; boşluk talep olmadığı anlamına da gelebilir.
- Bağlı not: Big Ambitions ve Startup Company aynı ekibin. Geliştirici Startup Company'nin "satış açısından yetişemediğini" yazıyor [6]. Bu ekip tür içinde ayrışmak için birinci şahıs yaşam simülasyonuna gitti.

### Soru 5: Geçiş 40-60 dakikalık demoda nasıl hissettirilir?

Bulduklarım (kanıtlı):
- Demolar nasıl yapılıyor: Haziran 2024 Next Fest'in en iyi 50 demosunda yazar 10 demo oynadı ve demoların "long horizontal slices of gameplay" olduğunu yazdı: tüm ana mekanikler var, bölüm ve ortam sayısı sınırlı. İlk 50'de yavaş açılan ya da boşta bekleyen oyun yok; yazar bunun nedenini tahmin ediyor [44].
- Valve'in ipuçları: demoyu festivalden önce yayına al, geri bildirim kanalı ekle, demonun ne zaman kapanacağını yaz. Süre ya da kanca önerisi yok [45].
- Factorio: demo ayrı bir uygulama [15]. 2019'da eski demo yaklaşık 2 saatti; yeni demo "about 10 hours of stuff to do" olarak tasarlandı. Eski demonun zamanlı final görevi çok zor bulunduğu için kaldırıldı. Geliştirici: "We don't want someone to pay for the game, just to see if they like it." [17] Resmi sayfa: demo "teach the very basic game mechanics" amacıyla yapılmış [16].
- Big Ambitions, Software Inc. ve Frostpunk 2 için Steam API'de demo kaydı yok [46]. Good Company'nin demosu var ama içeriği sayfada anlatılmıyor [38].

Mağaza sayfası düzeyinde "oyun büyüyor" anlatısı:
- Big Ambitions: metin sırayla anlatıyor: kredi çek, bina kirala, logo tasarla, mal yığ, personel al; sonra İK, lojistik, satın alma yöneticileri ve merkez ofis; sonra ithalat, depo ağı, yatırım fonu, şehri parça parça al (özetleyici) [1]. 1.0 duyurusu: "grow from rags to riches in New York City" [2]. Basın: "turbo-charged life sim where growth is the name of the game" [3].
- Spore: iki uç cümle ("From Single Cell to Galactic God") ve "Each stage has its own unique style, challenges, and goals" (özetleyici) [26].
- Bannerlord: kahraman, klan kurucu, krallık hükümdarı sırası (özetleyici) [34].
- Kenshi: "chosen one" olmayan başlangıç, üs, fraksiyon (özetleyici) [33].
- Önemli: Big Ambitions ve Software Inc. demosuz Erken Erişim'de büyüdü [46]; yani bu türün başarılı örnekleri demo yoluyla başarılı olmadı. Bizim demo bir seçim.

Bulamadığım: bir demonun "oyun sonra değişiyor" vaadini doğrudan sattığı kanıtlı örnek (video fragmanlar okunamadı).

## Project Unicorn için dersler

Not: Bu bölümün tamamı Görüş'tür; yukarıdaki kanıtlara dayanır ama kanıt değildir.

1. Görüş: Vaat "rol merdiveni" olarak tanımlanmalı. Kurucu-yapımcı (satar, sprint planlar, işe alır), ekip lideri (ilk uzak çalışanlar, planı PM'e devreder), müdür (VP'ler rapor sunar), yönetici (olaylar, yatırımcı, diplomasi). Her basamakta ana fiil değişmeli. Spore ve Bannerlord'un dersi: son basamaklar sığ kalırsa vaat çöker [27][34]. Beş sığ basamak yerine üç derin basamak daha güvenli.
2. Görüş: Devir bir tören ve maliyet olmalı. Software Inc.'te lider altı ay eğitilir; Big Ambitions'ta yönetici için merkez ofis gerekir [9][1]. Bizde PM'e planlama devri bir kilometre taşı olsun: kurucu bunu seçer, ilk haftalar PM kötü planlar, kurucu raporu izlemeyi öğrenir. Devri geri almak mümkün ama maliyetli olsun.
3. Görüş: Eski katman açık kalsın ama zorunlu olmasın. Factorio, Kenshi, Software Inc., Big Ambitions böyle [15][33][8][1]. Zorla çağ geçişi (Civ VII) ve kaldırılan mikro (Frostpunk 2) puan düşürdü [30][21]. Software Inc.'te "no way to opt out" şikâyeti 56 oy aldı [10]: sonradan eklenen sistem kapatılabilir ya da ölçeklenebilir olmalı.
4. Görüş: Devredilen iş ya gerçekten gitmeli ya da hiç devredilmemeli. Big Ambitions'ta iki hata birden var: "hâlâ elle yapıyorum" ve "merkez kendi kendine işliyor" [4]. Çözüm: VP'nin raporu sayı listesi değil karar kuyruğu olsun; VP kural dışı durumu getirir, kurucu karar verir. Böylece otomasyon kararı silmez, kararı yukarı taşır.
5. Görüş: Geç oyun "para birikir" olmamalı. Big Ambitions'ın yorumları yatırım fonu varken bile "nothing you can do anymore" diyor [4]. Rakip de boş kalırsa baskı yok ("rivals do absolutely nothing") [4]. Erdem'in "kazandığın parayı değerlendirme, risk alma" fikri ve Series A'ya kadar alınacak bir rakip firma bu boşluğu doldurur. Kazanç bir karar olmalı (risk, hisse, satın alma), yalnız sayaç olmamalı.
6. Görüş: Siyaset ve diplomasi katmanı Plutocracy'nin hatasını yapmamalı. Yorumlarda üç şikâyet: siyaset sonucu değiştirmiyor, olaylar zar atışı, "bribe or do nothing" aynı yere varıyor [36]. Kural: her diplomasi hamlesi bir sonuç değiştirsin ve oyuncu bunu görsün; şıklar farklı yerlere varsın.
7. Görüş: Erdem'in uzak çalışan bilgisayarı olayı çıtayı doğru koyuyor. Bu olayın ayırt edici özellikleri: (a) olay oyuncunun kendi önceki kararından doğuyor (uzak işe alım), (b) ilk kez kurucu olmanın bilgi eksiğini kullanıyor, (c) bedel somut ve hemen kasadan çıkıyor, (d) şıklar gerçekten farklı yerlere gidiyor (cihaz gönder / kendi cihazıyla çalış ve riski al / aylık yardım ver). Plutocracy'nin "bribe or do nothing" olayları bunun tersi [36]. Her olay için sorulacak: bu olayı oyuncunun şimdiye kadarki kararları mı doğurdu, yoksa havadan mı geldi?
8. Görüş: Evden çalışırken uzak ilk 1-2 çalışan, "masa sayısı = işe alım tavanı" kuralını gevşetir ve ikinci basamağı (ekip) birinci saatin içine çeker. Big Ambitions'ta masa ve bilgisayar ihtiyacı merkez ofisi zorunlu kılıyor [1]; bizde uzak işe alım bu kapıyı ücretsiz açar. Seed'i yakına almak, ofis eşiği ile yönetici eşiğini ayırmayı kolaylaştırır. Bunu doğrudan kanıtlayan kaynak yok; çıkarım.
9. Görüş: En riskli geçiş Series B'de "ürün döngüsünün çalışanlara devri". Frostpunk 2 ve Civ VII, oyuncunun sevdiği işi elinden almanın en büyük puan kaybettirdiği yer olduğunu gösteriyor [21][30]. Bunu zorunlu yapmayın; ürün penceresi gözlem modunda açık kalsın, devir kademeli olsun.
10. Görüş: Başlangıç kasası (10.000 mi 50.000 mi), ofis kirası baskısı ve Seed'in zamanlaması için bu araştırmada kanıt yok. Bu kararlar kendi playtest ve probe ölçümleriyle verilmeli; Steam yorumlarından çıkarılamaz.
11. Görüş: Demo için "yatay dilim" 45 dakikada her basamaktan bir tat verir [44]. Taslak: ilk 15 dakika kurucu elle çalışır (satış, sprint); 15-30 dakikada ilk uzak çalışan ve bilgisayar olayı gelir; 30-45 dakikada ilk devir (PM'e plan) ve Frank'in tek çeki; son dakikada kilitli bir "VP raporu" ekranı kanca olur. Zaman haftalık ölçekte hızlandırılır. Bu bir tasarım önerisi; kanıtlı bir demo örneği yok.
12. Görüş: Mağaza sayfası vaadi sırayla anlatsın; Big Ambitions'ın metin ve sıralaması iyi bir kalıp [1]. Tek cümlelik iki uçlu bir vaat (Spore'un "From Single Cell to Galactic God" biçimi) bizde "Birinci saatte kod yazarsın, yirminci saatte şirketi yönetirsin" olabilir [26]. Ekran görüntüleri her basamaktan bir tane olsun.
13. Tahmin: Yavaş açılan oyunlar Next Fest'in ilk 50'sinde yok [44]. Demo vaadi 45 dakikada hissettirilemezse, bu bir pazarlama riskidir; mağaza sayfası ve kısa video vaadi taşımak zorunda kalır.

## Bulunamayanlar

- Frostpunk 2 geliştiricilerinin "neden mikrodan makroya" gerekçesi. Twinfinite ve God is a Geek 403 verdi, Edge (PressReader) ve GameStar 403 verdi, gamefile.news ücretli duvarlı. Yalnız PCGamesN'in kısa alıntıları okundu [23]. Arama özetindeki "başlangıç şehri birinci oyunun sonu kadar" gibi iddialar sayfadan doğrulanmadı, rapora alınmadı.
- Software Inc. lider ve otomasyon tasarım gerekçesi; resmi wiki sayfası "devam eden çalışma" ve otomasyon sayfası yok [9].
- Tropico 6'da çağ geçişinin oyuncuya ne değiştirdiği (mağaza ve Wikipedia anlatmıyor) [35].
- Stellaris sektör ve vali sisteminin gerekçesi ve oyuncu karşılaması; Paradox wiki sayfasının yalnız ilk 100.000 karakteri okundu [32].
- Mad Games Tycoon 2'nin departman ve personel devri ayrıntısı; mağaza metni bunları anmıyor [14].
- Capitalism Lab'ın bağımsız yorum puanı ve yapay zekâ CEO'ların işleyişi [37].
- Big Ambitions merkez ofis wiki'si (Fandom 402 verdi) ve Software Inc. Fandom sayfası.
- "Oyun sonra değişiyor" vaadini fragmanla ya da demoyla satan kanıtlı örnek. Video fragmanlar okunamadı; Zukowski'nin demo yazılarını aradığım WebSearch alakasız sonuç verdi.
- Başlangıç sermayesi (10.000 mi 50.000 mi), ofise geçiş şartı ve Seed'in zamanlaması hakkında kanıt. Okuduğum oyunların başlangıç parası yorumlarda yalnız dolaylı geçiyor.
- Reddit ve Steam forum tartışmaları (aracın kapsamında okunamadı); yalnız Steam yorumları, bir Arcen forum konusu ve bir blog var.
- Yorum örneklemleri: olumsuz yorumların son 365 günlük ilk 100'ü; küçük ve en yeni sürümü yansıtır.

## Kaynaklar

[1] Big Ambitions, Steam mağaza sayfası. https://store.steampowered.com/app/1331550/Big_Ambitions/ (okundu 2026-10-19)
[2] Big Ambitions Steam duyuruları ("1.0 FULL RELEASE" 2026-08-27, "Full Release is TWO WEEKS AWAY" 2026-08-13). https://api.steampowered.com/ISteamNews/GetNewsForApp/v2/?appid=1331550&count=8&maxlength=9000&format=json
[3] PCGamesN, Big Ambitions 1.0 (2026-08-30). https://www.pcgamesn.com/big-ambitions/1-0-tycoon-life-sim
[4] Big Ambitions Steam yorumları (API; olumsuz son 365 gün ve tüm zamanların olumluları). https://store.steampowered.com/appreviews/1331550?json=1&language=english&filter=recent&review_type=negative&day_range=365 (okundu 2026-10-19)
[5] Steam yorum özetleri, tüm oyunlar (API, num_per_page=0; appid değişir). https://store.steampowered.com/appreviews/1331550?json=1&language=english&num_per_page=0&purchase_type=all (okundu 2026-10-19)
[6] Hovgaard Games geliştirici yazısı, Big Ambitions Steam forumu (2023-03-14). https://steamcommunity.com/app/1331550/discussions/0/3790381090379742936
[7] Codecks, Hovgaard Games ile özellik şişkinliği röportajı (2025). https://www.codecks.io/blog/2025/how-to-stop-feature-creep-from-killing-your-game-with-hovgaard-games
[8] Software Inc., Steam mağaza sayfası. https://store.steampowered.com/app/362620/Software_Inc/
[9] Software Inc. resmi wiki, Project Management. https://softwareinc.coredumping.com/wiki/index.php/Project_Management
[10] Software Inc. Steam yorumları (API). https://store.steampowered.com/appreviews/362620?json=1&language=english&filter=recent&review_type=negative&day_range=365
[11] Startup Company, Steam mağaza sayfası. https://store.steampowered.com/app/606800/Startup_Company/
[12] Startup Company Steam yorumları (API). https://store.steampowered.com/appreviews/606800?json=1&language=english&filter=recent&review_type=negative&day_range=365
[13] Game Dev Tycoon, mağaza ve yorumlar (API). https://store.steampowered.com/app/239820/Game_Dev_Tycoon/ ve https://store.steampowered.com/appreviews/239820?json=1&language=english&filter=recent&review_type=negative&day_range=365
[14] Mad Games Tycoon 2, mağaza ve yorumlar (API). https://store.steampowered.com/app/1342330/Mad_Games_Tycoon_2/ ve https://store.steampowered.com/appreviews/1342330?json=1&language=english&filter=recent&review_type=negative&day_range=365
[15] Factorio, Steam mağaza sayfası. https://store.steampowered.com/app/427520/Factorio/
[16] Factorio, resmi indirme ve demo sayfası. https://www.factorio.com/download
[17] Factorio Friday Facts #306, yeni demo (2019-08-02). https://direct.factorio.com/blog/post/fff-306
[18] Factorio Steam yorumları (API). https://store.steampowered.com/appreviews/427520?json=1&language=english&filter=all&review_type=all
[19] Frostpunk 2, Steam mağaza sayfası. https://store.steampowered.com/app/1601580/Frostpunk_2/
[20] Wikipedia, Frostpunk 2. https://en.wikipedia.org/wiki/Frostpunk_2
[21] Frostpunk 2 Steam yorumları (API; olumsuz ve olumlu, tüm zamanlar). https://store.steampowered.com/appreviews/1601580?json=1&language=english&filter=all&review_type=negative
[22] Frostpunk (1), Steam mağaza sayfası. https://store.steampowered.com/app/323190/Frostpunk/
[23] PCGamesN, Frostpunk 2 gameplay teaser. https://www.pcgamesn.com/frostpunk-2/gameplay-teaser
[24] Game Critics, Frostpunk 2 incelemesi. https://gamecritics.com/ali-arkani/frostpunk-2-review/
[25] Frostpunk 2 Steam duyuruları (yama ve genişleme notları). https://api.steampowered.com/ISteamNews/GetNewsForApp/v2/?appid=1601580&count=40&maxlength=6000&format=json
[26] Spore, Steam mağaza sayfası. https://store.steampowered.com/app/17390/SPORE/
[27] Wikipedia, Spore (2008). https://en.wikipedia.org/wiki/Spore_(2008_video_game)
[28] Wikipedia, Universal Paperclips. https://en.wikipedia.org/wiki/Universal_Paperclips
[29] Wikipedia, Civilization VII. https://en.wikipedia.org/wiki/Civilization_VII
[30] Civ VII Steam yorumları (API; olumsuz, tüm zamanlar). https://store.steampowered.com/appreviews/1295660?json=1&language=english&filter=all&review_type=negative
[31] Victoria 3, mağaza ve yorumlar (API). https://store.steampowered.com/app/529340/Victoria_3/ ve https://store.steampowered.com/appreviews/529340?json=1&language=english&filter=all&review_type=all
[32] Stellaris: Paradox wiki, Sectors, ve Steam yorumları (API). https://stellaris.paradoxwikis.com/Sectors ve https://store.steampowered.com/appreviews/281990?json=1&language=english&filter=all&review_type=negative
[33] Kenshi, mağaza ve Wikipedia. https://store.steampowered.com/app/233860/Kenshi/ ve https://en.wikipedia.org/wiki/Kenshi_(video_game)
[34] Mount & Blade II: Bannerlord, mağaza ve Wikipedia. https://store.steampowered.com/app/261550/Mount__Blade_II_Bannerlord/ ve https://en.wikipedia.org/wiki/Mount_%26_Blade_II:_Bannerlord
[35] Tropico 6, mağaza ve Wikipedia. https://store.steampowered.com/app/492720/Tropico_6/ ve https://en.wikipedia.org/wiki/Tropico_6
[36] Plutocracy, mağaza ve Steam yorumları (API). https://store.steampowered.com/app/754500/Plutocracy/ ve https://store.steampowered.com/appreviews/754500?json=1&language=english&filter=recent&review_type=negative&day_range=365
[37] Capitalism Lab, resmi satın alma sayfası (iştirak DLC'si) ve Legacy of Games incelemesi (2025-11-13). https://www.capitalismlab.com/buy-game ve https://legacyofgames.com/2025/11/13/capitalism-lab
[38] Good Company, mağaza sayfası ve Cosmocover basın bülteni (2020-03-10). https://store.steampowered.com/app/911430/Good_Company/ ve https://www.cosmocover.com/newsroom/start-as-a-visionary-become-a-leader-management-sim-good-company-launches-on-march-31st/
[39] Venture Capital Tycoon, E-Startup 2, Software Company, Business Simulator 2026 mağaza sayfaları. https://store.steampowered.com/app/4994070/ , https://store.steampowered.com/app/2547750/ , https://store.steampowered.com/app/1782810/ , https://store.steampowered.com/app/3098060/
[40] Founder Sim: Startup Game, Product Hunt ve mwm.ai. https://www.producthunt.com/products/founder-sim-startup-game ve https://mwm.ai/apps/founder-sim-startup-game/6761432505
[41] Arcen Games forumu, "Automation?" konusu (2014-07-19 ve 2014-09-13). https://forums.arcengames.com/stars-beyond-reach-this-world-is-mine/automation/
[42] Matchstick Eyes, Nobunaga's Ambition geç oyun ve yapay zekâ otomasyonu (2016-01-10). https://matchstickeyes.com/2016/01/10/nobunagas-ambition-late-game-observations-and-reflections-on-ai-automation
[43] Game Developer, Josh Bycer, "The Three Layers of Control in Strategy Games" (2012-03-02). https://www.gamedeveloper.com/design/the-three-layers-of-control-in-strategy-games-
[44] How To Market A Game, "Steam Next Fest June 2024: Top demos and genre" (2024-06-27). https://howtomarketagame.com/?p=3923
[45] Steamworks belgeleri, Next Fest ipuçları. https://partner.steamgames.com/doc/marketing/upcoming_events/nextfest/tips
[46] Steam mağaza arama API'si ve appdetails (demos alanı). https://store.steampowered.com/api/storesearch/?term=startup%20tycoon&cc=us&l=en ve https://store.steampowered.com/api/appdetails?appids=1601580&filters=demos (okundu 2026-10-19)
