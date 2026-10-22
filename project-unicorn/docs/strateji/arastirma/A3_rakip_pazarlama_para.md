# A3: Rakip, pazarlama, kazanılan para, ofis baskısı ve başlangıç zorluğu (iş simülasyonlarından kanıt)

Tarih: 2026-10-19
Arama sayısı: 9 (WebSearch; bütçe 13'tü, arama aracı hata vermedi). Ek olarak Steam'in herkese açık yorum ve duyuru API'si, Steam forum başlıkları, Designer Notes ve Game Developer yazıları WebFetch ya da curl ile okundu; bunlar arama sayılmaz. Raporun sonunda Steam API'si hız sınırına (429) takıldı; o noktadan sonra yeni veri çekilmedi.

Okuma notları:
- Yüzdeler İngilizce Steam yorumlarıdır, 2026-10-19'da çekildi [1]. Başlıca sayılar: Software Inc. %94,3 (5.814), Game Dev Tycoon %94,5 (25.302), Mad Games Tycoon 2 %93,1 (2.352), Big Ambitions %91,2 (6.491), Startup Company %80,5 (3.103), Offworld %77,7 (4.174), Capitalism 2 %79,6 (339), Good Company %70,3 (899), Tech Executive Tycoon 6 olumlu / 38 [1].
- "Örneklem" dediğim şey Steam API'sinden benim çektiğim yorumlardır: Software Inc. son 3.700, Startup Company tümü (3.103), Big Ambitions son 3.600 yorum, ayrıca her oyundan yararlılığa göre ilk sayfalar. Konu sayımları anahtar sözcükle yapıldı. Kaba tahmindir, kesin oran değildir.
- Fandom, wiki.gg, Rock Paper Shotgun ve Reddit'e erişilemedi (402/403/404). Wiki bilgisi yerine geliştirici duyurularını ve forumları kullandım.
- Her satırın sonundaki [n] kaynak numarasıdır. "Görüş:" ve "Tahmin:" ile başlayan satırlar benim yorumumdur. Kaynaksız model bilgisi kullanmadım.

## Kısa cevaplar

1. Rakip. İşe yarayan iki model var: adlı, kişilikli ve oyuncuya saldıran rakip (Big Ambitions) ve oyuncuyla aynı kurallarla oynayan düşman piyasa (Offworld) [14][72][73]. İşe yaramayan model, adı olan ama hiçbir şey yapmayan rakip. Startup Company'de rakip "orada duruyor, satın alınmayı bekliyor" diye yazıldı ve geliştirici daha zorlu rekabet sözü verdi [76][55]. Ama Big Ambitions'ta bile 19 rakipten 15'i "dolgu" bulundu [59].
2. Pazarlama. Oyuncu kitle, kanal ve söz verme arasında seçim yapıyorsa gerçek karar sayılıyor [78][10]. Her ay aynı reklam sözleşmesini yenilemek ise angarya sayılıyor [74][75]. Software Inc. geliştiricisi on yılda satış sonrası pazarlamayı tatmin edici biçimde yeniden yapamadığını yazdı [11].
3. Kazanılan para. Hisse, satın alma ve yatırım sistemleri çoğu oyunda "kolay para"ya dönüyor. "Endgame yok" ve "para var, ne yapacağım" en sık şikâyet [40][41][68][81]. Gerçek ve görünür risk en çok Offworld'de var: borç hisse fiyatını düşürür ve rakip seni satın alabilir [72][30]. Software Inc.'te risk yalnız büyüme aşamasında var [53].
4. Ofis. En sert örnek Game Dev Tycoon: oyuncular garajdan 1 ile 5 milyon dolara kadar çıkmıyor, çünkü erken taşınan aylık 32 bin ile 70 bin dolar gidere batıyor [63][64]. Öbür oyunlarda ofis ya da kira ilk dakikada başlıyor ve kademeli büyüyor [24][37][32].
5. Başlangıç. Birçok oyun zorluk ya da başlangıç parasını oyuncuya açıyor. Yine de yeni oyuncu çok batıyor: Software Inc.'te "100 oyunun 99'unda iflas" [44]. En çok işe yarayan çözümler: kolay mod, kredi ekranı, hikâyeli başlangıç kredisi, tutorial atlama [3][7][12][32].
6. Ana bulgu (vaadimizle ilgili). İki oyunda olumsuz yorumların üçte biri tekrar, sıkıcılık ya da mikro yönetimden yakınıyor: Startup Company %32, Big Ambitions 1.0 sonrası %32 [1]. Para bir kez bolluğa döndüğünde hedef değişmiyorsa oyun bitiyor [41].

## Bulgular

### Soru 1: Rakip

Karşılaştırma (bu bölümdeki kaynaklardan):

| Oyun | Rakip nasıl kurulmuş | Oyuncu tepkisi |
|---|---|---|
| Software Inc. | Simüle piyasa, yapay zekâ şirketleri, hisse, satın alma, yan kuruluş; CEO'lar 2026'da eklendi [6][11] | Seviliyor ama "anonim", "hep kaybediyor" [1][42] |
| Startup Company | Rakip listesi, rakip hissesi, birleşme [20][23] | "Sadece isim", "bir şey yapmıyor" [76][54] |
| Big Ambitions | 4 adlı özel rakip + 15 küçük rakip, 4 saldırı türü, liderlik tablosu [14] | Özel rakipler karakterli; küçükler "dolgu" [59] |
| Mad Games Tycoon 2 | En çok 100 şirket, zamanla piyasaya girer, satın alınabilir [24][25] | Yapay zekâ iki yönde de eleştirildi [70] |
| Offworld | Rakip yapay zekâ oyuncuyla aynı kurallarla oynar; ekonomi savaşın kendisi [73][30] | Basın puanı yüksek (Metacritic 78, PC Gamer 88), Steam %77,7 [30][1] |
| Game Dev Tycoon | Yapay zekâ rakip yok; konsol ve sektör olayları var [31][39] | 755 yorumun yalnız 3'ü rakipten söz ediyor [1] |
| Good Company | Pazar evrimini oyuncu belirler | "Başka şirketten meydan okuma yok, sıkıcı" [1] |

Software Inc.
- Piyasa simülasyonu rastgele ve her oyunda farklı; oyuncu rakipleri hisse ve satın almayla ele geçirebilir [37]. Alpha 9'da (2017) satın alınan şirket kapanmadan yan kuruluş olarak kalabiliyor ve oyuncu onun fonunu yönetiyor [6]. Alpha 10'da yan kuruluşun yayınlarını ve görevlerini de yönetiyor [7].
- 2026-10-04 duyurusu: yapay zekâ şirketlerine CEO geldi. CEO'nun becerisi şirketin hangi alanda iyi olacağını belirler; emeklilik, yan kuruluş ya da hissedar oyuyla değişir. "CEOs can also cause controversy, to add some interest in the stock system." [11]
- Oyuncular bu yaşayan ekonomiyi övüyor: "There's an AI economy with AI companies that you have to work with and learn their releases." (2022) [1]. Aynı oyuncular rakiplerin pasifliğinden yakınıyor: "the other companies are too anonymous" ve "AI sucks... They never win" (2023) [42].
- 2021'de bir oyuncu, oyundaki diğer şirketlerin paralarının bitmesinden sıkıldığını yazdı [41]. Ölçüm: yararlılığa göre ilk yorumların %9'u rakip ya da yapay zekâ şirketinden söz ediyor; 45 yorumdan yalnız 3'ü olumsuz [1].

Startup Company (başarısız örnek: %80,5)
- Geliştirici 2017'de "rakip ürünleri görme" isteğini ve "borsa" isteğini tek özellikte topladı [20].
- Eleştiri açık: "Competition: + It exists - it is just there and does nothing besides waiting for you to bought up" (2020, 103 faydalı oy) [76]. Bir oyuncu 45-50 saatte tekel kurdu: "the other companies just randomly tank their profits and dont grow. Wish they did so you actually had to compete." [54]
- Geliştirici ana mesajda cevap verdi: "I also plan on adding more milestones and more challenging competition" (2019) [55]. Beta 16'da rakip satın alma, yatırım teklifleri ve hedefler geldi, beta 17'de pazarlama baştan yazıldı (2018) [23]; yine de 2020 yorumunda rakip hâlâ "sadece orada".
- Gözlem: bu oyunda ana şikâyet rakip değil tekrar. Olumsuz yorumların %32'si sıkıcı, tekrarlı ya da mikro yönetim diyor; rakip yalnız %3 [1].

Big Ambitions (rakip 2024'te eklendi)
- EA 0.5 (2024-04-18): dört özel rakip her biri bir mahallede egemen (Thierry Moreau, Huang Guo, Jessica Johnson, Ingrid Schneider). Saldırılar: kiralamayı reddetme, fiyat kırma, benzer mağaza açarak talebi düşürme, çalışan çalma. Şiddet oyun zorluğuna bağlı. Ayrıca 15 küçük rakip çalışan çalıyor, telefonda "Rivals" uygulaması ve ilk 20 liderlik tablosu var [14].
- Oyuncunun karşı hamlesi var: rakibin fiyatını kır, benzer mağaza aç, onun çalışanını çal. Haftalık gelir düşünce rakibin işletme değeri düşer ve satın alması ucuzlar [14]. Özel Oyun'da rakipler "0"a çekilip kapatılabiliyor [15].
- Forumda ilk tepki: "The four main rivals have character... The rest is pure filler" (2025) ve "rivals need to do more and matter more". Oyuncu, rakiplerin kapanıp yenilerinin doğmasını istiyor ve Mad Games Tycoon ile Software Inc.'i örnek veriyor [59].
- Oyuncular rakibi bir yapboz gibi çözüyor: "bir bölgede en çok 2 mağaza aç, rakibi uyandırma" [61], "fiyat kırıp işletmeyi ucuza al" [60]. Görüş: rakip planlama yaratıyor ama sistem hızla çözülüyor.
- İnceleme: "the mechanics for that are very shallow: you buy their businesses or the buildings they hired for their businesses" (2026-07) [82].
- Ölçüm (3.600 yorum): "rival" sözcüğü EA 0.5'ten önce yorumların %1,2'sinde, sonra %3,2'sinde. Rakipten söz edenlerin %88'i olumlu; genel oran %89. Görüş: rakipler konuşuluyor ama puanı belirgin değiştirmedi [1].

Mad Games Tycoon 2
- Yıldönümü duyurusu: erken başlangıç yılı seçince piyasaya sürekli yeni şirket giriyor: "You may start with 10 or 20 competitors but by the end be competing against all 90+!" Rakipler zor seviyelerde listelerde ve yıl sonu ödüllerinde yarışıyor [24].
- Şirket satın alma 2022'de geldi: oyuncu satın aldığı şirkete tür, konsol, süre emri veriyor [25].
- Yapay zekâ ayarı iki yönden şikâyet aldı. Forumda bir oyuncu, rakiplerin eskiden "flawless machines of game-making" olduğunu, şikâyetler üzerine "dumbed down" yapıldığını anlatıyor. Sandbox'ta rakip oyun kalitesi artık zorluktan ayrı ayarlanıyor [70][26].
- Oyuncu yorumu: "Bought all my competitors" ve piyasayı ele geçirmek (2024) [1]. Görüş: rakip satın alma hedefi olmuş ama yenmesi kolay.

Offworld Trading Company (%77,7)
- Çatışma silahla değil piyasayla. Kazanma koşulu rakip şirketin çoğunluk hissesini almak; kaybetmek, şirketin çoğunluğunu kaybetmek ya da pahalı bir düşman devralmasına uğramak. Birinin satın almaya gücü yetince diğerleri uyarılıyor ama kimin olduğunu bilmiyor [30].
- Yapay zekâ aynı kurallarla oynuyor: "AI players follow the same rules as human players." (2019; oyuncular bunu tekrar kayıtlarından izlemiş) [73]. Bir forum yanıtı, "Manager" seviyesinde yapay zekânın bonus almadığını yazıyor [72].
- Geliştirici yapay zekâdaki boşlukları oyuncuların günlük meydan okuma videolarını izleyerek buldu ve her gün yeni derleme yayınladı [29].
- Satın alma kuralı Erken Erişim'de iki şekilde denendi: "Destroy Buyout" yerine yan kuruluş sistemi kondu, "Majority Buyout" standart oldu [28][29].
- Şikâyet: bir yorumcu tüm oyunların "Stock Buyout Races"e dönüştüğünü yazdı (2015, 213 faydalı oy) [1]. Erken Erişim yorumları puanı 80'in iki puan altında tuttu, ayrıca öğretici ve içerik eksikliği eleştirildi [28].

Capitalism ailesi
- Capitalism 2'de rakiplerin adlı CEO'ları var: "Brad Breca, the CEO of my main competitor, was still crowding me out" (örneklem) [1]. Steam'de %79,6. Capitalism Lab Steam'de satılmıyor, kendi sitesinde satılıyor; sitede "AI CEO'lu yan kuruluşlar" DLC'si anılıyor [34][35]. Oyuncu verisi bulunamadı.

Görüş: Desen. Rakip, davranışı oyuncunun kararına cevap veriyorsa (fiyat kır, çalışan çal, kira reddet) konuşuluyor. Bekleyen sabit liste ise şikâyet çıkıyor. Dolgu rakipler "karakter" eksikliği olarak okunuyor. Piyasaya yeni girenler ve kapananlar hem Software Inc. hem Mad Games'te var, Big Ambitions oyuncuları da bunu istiyor [59].

### Soru 2: Pazarlama

Software Inc. (on yıllık iterasyon)
- Alpha 7 (2016): ön pazarlama normal pazarlamadan ayrıldı; ön pazarlama benzer ürünlerin satışını da etkiliyor [4]. Alpha 9 planı: basın bülteni, basın sürümü ve fuar; "post-marketing" için "you'll have to actively compete by throwing as much money as possible at marketers and ads" [5].
- Alpha 9 duyurusu: oyun "ilerleme çubuğundan çok risk yönetimi ve pazarlama planlamasına" döndü [6].
- 2026-06 planı: ön pazarlama baştan, satış sonrası pazarlamaya bir mekanik [9]. 2026-08 taslağı: üç hedef kitle (iade, fiyat duyarlılığı ve destek bileti eğilimi farklı), hype, 4-8 mesaj güncellemesi. "Hype will increase total audience reach, but also audience expectations, so you better not make too many promises!" [10].
- 2026-10-04: "After years of iterations, I've decided that I won't be able to come up with a satisfactory overhaul of the post-marketing system." Satış sonrası pazarlama değişmeden kalacak [11].
- Oyuncu şikâyeti sürekli: "Marketing and Market Recognition is nonsensical." (2026) [49]; "I can not get marketing to work properly - ever... I get maybe 14 on my first press release." (2022) [48]. Bir yorum: "Marketing exists in Software Inc., but only in a basic fashion." (örneklem) [1].

Startup Company (B2C'ye en yakın örnek)
- Beta 17 (2018): kampanyayı yeniden yazdı. Artık sürekli yeniden başlatılmıyor; başarı doğru hedef kitleyi bulmaya bağlı [23]. Olumlu yorum: "The marketing functionality is like the real world... success will be based on your ability to correctly target the relevant audience." [78]
- Aynı oyunda olumsuz yorumlar: "All you have to do is keep Hype level... high by clicking either Update or Marketing buttons." (2017, 220 faydalı oy) [75]; "the only thing you really do is juggle between advertisement contracts" (2019, 100) [74]; "Boring like the rest... There is no real startegy behind that." (2020) [76].
- Para baskısı gerçek: bir yorumcuya göre 30. günde aylık gider 200-300 bin işçi, 100-150 bin pazarlama; "lowering this only means that its slower to get more users" [74]. Bu hesaba göre pazarlama ikinci büyük gider ve düşürmek ölüm değil yavaşlama getiriyor. Forumda da "niş kitle seçersen erişim yavaşlar, bütçeyi artırırsan hızlanır" diye öğreniliyor [57].
- Görüş: baskı kuruluyor ama kararlar ince kalınca (en uygun reklamı al, yenile) angarya oluyor.

Mad Games Tycoon 2
- Pazarlama kampanyaları, demo, fuar ve geri tepebilen sahte inceleme seçeneği var. Yorum: "The type of marketing you can do feels right" ve sahte incelemenin "backlash" riski (2023, 45 faydalı oy) [1]. Fuarın hype kazancı zorluğa bağlı [2].
- Rastgele olay: oyun hype'ını vuran bir olay, pazarlama bölümü olmadan "make or break" (örneklem) [1].

Game Dev Tycoon
- Pazarlama dört paket: dergi, dergi+demo, küçük, büyük kampanya. Oyuncular çoğu kez nasıl çalıştığını anlamıyor; "bir oyun için tek tür yeterli, fazlası hype tavanını aşmaz" [67]. Bir yorum: "Marketing should have more options instead of price tiers." (örneklem) [1]. Görüş: fiyat basamağı karar derinliği vermiyor, ama pazarlama oyunun merkezinde olmadığı için oyun yine de %94,5 olumlu [1].

Big Ambitions
- Reklam ve tabela var ama yorumlar tutarlı: "marketing is meh" ve "with some marketing, you just start making money instantly" (2026) [1]. Görüş: mağaza oyununda pazarlama zorunlu vergi değil, kolay bonus gibi okunuyor.

Görüş: Özet. Pazarlama "karar" olduğu yerlerde: hedef kitle seçimi (Startup Company beta 17), söz verip tutmama (Software Inc. hype ve beklenti), açığa çıkma riski (Mad Games sahte inceleme). "Vergi" olduğu yerlerde: yenileme angaryası, fiyat basamağı, ya da etkisi görünmeyen bütçe.

### Soru 3: Kazanılan parayı değerlendirme ve risk

Software Inc.
- Hisse: oyuncu başka şirketlerin hissesini alır, temettü alır, tamamını alırsa yan kuruluş yapar [50][6]. 2023'te vergi eklendi, oyuncu vergiyi atlatıp yurtdışı hesapta para saklayabiliyor ve kredi maliyetleri ile banka kredisi yeniden yapıldı [8].
- Kolay para kanıtı: "Buy stocks from other companies as subsidiaries when you have 150k. They always go bankrupt... bought a sub for 18k$ resold it for 4M$." (2018) [46]. Görüş: bu tarif hisseyi piyango gibi gösteriyor.
- Hisse sistemi yorumları: "huge potential but is very lacking" (örneklem, 2017) [1]; temettünün kârın bir yüzdesi gibi çalıştığı anlatılıyor [50].
- "Endgame?" başlığı (2024): "After some years in this game you are absolutely loaded... Is there any risks?" Cevap: "Buy the competition, delegate, rake in even more money. Yes, there's no endgame." [40]
- "what am i supposed to do?" (2021): "i run out of steam as soon as i get rich". Cevap yazan oyuncu: iş simülasyonları "have no other motivation beyond the making of money" ve Megaquarium örneğini verdi: "money is tight in the beginning, but, mid game the focus is on research and late game the focus is on maintaining prestige" [41].
- Zorluk yükseltmek çözüm değil: "the problem isn't solved by increasing difficulty... all that does is defer the point when you've made it" [41]. Başka konu: "lack of consequence for anything you do kinda of ruins the game"; yayıncılık anlaşmasını bozma cezası 50.000 dolar ve gülünç bulundu [51].
- Tersi de var: "$10 million can evaporate like water" (2016); büyürken bir proje hata verirse günde milyonlar gidebilir [53]. Görüş: risk genişleme aşamasında gerçek.

Startup Company
- Yatırımcı sistemi oyunun omurgası: "small amount of seed capital, in return for a 40% share" ve yatırımcı hedefler bağlıyor (kullanıcı sayısı, reklam geliri, pazarlama, kendi barındırma) [77]. Yatırımcıyı erken satın alırsan hedefleri kaybedersin; emeklilik fonuna aktarılan paradan yatırımcı hisseye oranla pay alıyor [58].
- Ama geç oyunda para fazla: "40 billion in my bank. Nothing to really do" (2018) [54]; "with shares, apps and instant contracts, you can be popping half a million every 10-15 seconds" (2017) [56]; geliştirici "Yes :-(" diye teyit etti [54].
- "You swim in money and have nowhere to spend it (except buying all your competitors haha)." (2019, örneklem) [1].

Mad Games Tycoon 2
- "There's no place to spend a lot of money." (2022). Cevap: bu oyunun bilinen sorunu; erken oyun bu yüzden zorlaştırıldı ama 1990'dan sonra "a lot of money and no way to lose". Öneriler: enflasyon, vergi, dava, PR krizi, satın alma [68].
- "soon enough you have $4 billion and nothing to really spend it on" (2022) [1].

Big Ambitions
- Mağaza sayfası yatırım fonlarını ve gayrimenkul alımını sunuyor [36]. Yorumlar: "The current investment system is just for show." ve borsayı "iflas edebileceğimiz gerçek bir borsa" yapma isteği (2026-03) [79].
- Para harcayacak yer: "there's nothing to really do with your money" (2026-02) [81]. Başka yorum: haftanın çoğu uyuyup hızlı ilerleyerek geçiyor: "most of the week is skipped with sleeping and other fast-forward activities" (2026-04) [80].
- Gizli gider tepkisi: aynı olumsuz yorum 300 gün sorun yaşamadan sonra gelen 70 bin dolarlık ani vergiyi ve her pazartesi 7 bin dolarlık "negative interest" kesintisini "lack of transparency" diye eleştirdi [79]. Not: Software Inc. de vergi ekledi ama atlatma yolu verdi [8].

Offworld
- Para-risk bağı kurulmuş: borç hisse fiyatını düşürür; düşük hisse fiyatı rakibin seni devralmasını kolaylaştırır [72]. Risk simetrik ve görünür [30]. Şikâyet: kısa süreli yarışa dönüşüyor, "Stock Buyout Races" [1].
- Capitalism 2: "The stock market is so realistic, it's scary." ve "boom-bust cycles to the stock market and P/E ratio" öğretir denmiş (örneklem) [1]. Ama oyun %79,6 ve öğrenme eğrisi dik [1].

Görüş: Desen. Para bir hedef değil araçsa, oyun zenginleşince bitiyor [41]. Riskli yatırım yalnız şu koşulla gerçek olur: kayıp görünür, geri dönüşü zor, kazanç oyuncunun hamlesine bağlı. Aksi hâlde piyango (Software Inc.'te 18 bin dolara alıp 4 milyona satmak) ya da gösteriş (Big Ambitions'ın yatırım sistemi) olur.

### Soru 4: Ofis ve sabit gider baskısı

Game Dev Tycoon (basamaklı ofis)
- Garajda başlıyorsun; "erken başarıdan sonra kendi ofisine taşınırsın" [39]. 2018 forum: "Stay in the garage until you have multiple millions, don't move after only 1m, because the 32k costs a month will likely bury you" [63]. Aynı konuda biri 5 milyon dolar ve 20 bin hayranla taşındığını yazdı [63].
- 2023 forum: oyuncu 1,5 milyonda taşındı, bir iki çalışanla "suddenly I am losing 70k+ a Month and go Bankrupt", 4-5 milyonu bekleyip beklemeyeceğini soruyor [64]. 2014: "I havent hit any issues until the second office" [65]. 2026 yorum: "I was just one week away from bankruptcy after moving offices" (örneklem) [1].
- Geliştirici rehberi: "Save up a good amount of money before moving on to level 2." ve "staff members are expensive" [27].
- Görüş: forum başlıklarına bakılırsa ofis taşıma oyunun en çok batılan anlarından biri; buna rağmen oyun %94,5 olumlu [1].

Mad Games Tycoon 2 (kademesiz)
- Birinci oyundaki taşınma kaldırıldı: "No longer do you have to move (like in the original Mad Games Tycoon) when you've outgrown your studio." Kampüs haritaları var, yeni bina bir tık. Sandbox'ta baştan dev bina [24].
- Mağaza sayfası kira anmıyor, "Build your own offices" diyor [38]. Başlangıç parası 500 bin dolar, bir oyuncu "way too much" buluyor [69].

Software Inc.
- Başlangıçta küçük kiralık oda ya da kendi arsa [1]. Alpha 10 (2018): oda kiralama, şirketi taşıma, yeni arsa sistemi [7]. 2015 forumunda küçük kurulum "günde 50-60 dolar"; oyuncular milyona kadar ofis kurmayı ertelemeyi öneriyor [52].
- Görüş: ofis baskısı kademeli ve ertelenebilir; ilk saatte zorunlu değil.

Startup Company
- Ofis oyunun başında seçilir ve kiralanır [77][37]. Bina kademeleri ilerleme kapısı: beta 13 gökdelen (80 iş istasyonu) [21]; beta 16.6'da ilk oyuncuların yanlış bina kiralamasın diye bir bodrum barındırma binası 10 bin yerine 20 bin dolara çıkarıldı [22]. Yorum: "largest office space is also far too small to accomodate the full 50 workstations" [1].

Big Ambitions
- Daire amcadan, işyeri kiralanır; mağaza yeri seçimi kritik: PC Gamer yazarı trafiği düşük yeri seçip mağazasını kapatmak zorunda kaldı [32]. Öğretici görevlerinden biri "Rent a Building with 40% Traffic" [17]. Rakip, sahibi olduğu binayı sana kiralamayı reddedebilir [14]. Bir oyuncu, geliştiricilerin kirayı gelir olmasın diye ucuz tuttuğunu yazıyor [61].
- Ofisin tuvaleti şart: EA 0.9'da büyüklüğe göre tuvalet olmazsa ofis para kazanmıyor [16].

İlk ofis ne zaman geliyor? Startup Company, Software Inc., Mad Games Tycoon 2 ve Big Ambitions'ta oyunun başında ya da ilk saatinde. Yalnız Game Dev Tycoon'da garaj var ve geçiş milyonlarla ölçülüyor.

### Soru 5: Başlangıç zorluğu ve kasa

Software Inc.
- 2015: oyuncular "son güncellemeden sonra medium'da bile tek çalışan alamıyorum" dedi. Foruma yazılan yanıt kolay modu "almost impossible to bankrupt" yapacağını söylüyor [43]. Haziran 2015 yaması bunu uyguladı: kolay mod satışı, iş hızını ve beceri etkisini artırıyor; %0-100 beceri arka planda %25-100 oluyor [3].
- 2018 (Alpha 10): "Removed scenarios and added ability to take out loans in new game screen" [7]. Oyuncu tepkisi: "We used to have a option to start with 100,000... now we have to take a loan which sucks" [47].
- Yeni oyuncu iflası sürüyor: "Out of about 100 played games on A11, I went bankrupt 99 times" (2019) [44]; "Two bankrupt companies after 14 hours" ve geliştirici cevabı [45]. Topluluk önerisi: yalnız kurucuyla sözleşme yapıp 30 bin sonra 150 bin biriktir, sonra çalışan al [46][52].
- Ölçüm: son 3.700 yorumda olumsuzların %24'ü öğretici ya da öğrenme eğrisinden, %9'u iflas ya da krediden yakınıyor [1]. Geliştirici bu yüzden 1.0 için kampanya modu yaptığını yazdı [9].

Game Dev Tycoon
- Sürekli iflas başlıkları: "keep going bankrupt" (2014) [65], "This game is way too hard" (2013, 30 yanıt) [66]. Oyun yine %94,5 olumlu; en yararlı 755 yorumun %3'ü iflas, kredi ya da zorluk anahtar sözcüklerini içeriyor [1].
- Geliştirici 2024'te bile "The biggest challenge is avoiding bankruptcy" diye rehber yazdı ve "Pirate Mode"u ultra zor mod olarak tuttu [27][31]. Görüş: iflas oyunun parçası ve geri dönüşü hızlı (yeniden başla).
- Forumdaki kurtarma ipucu: şirketin %90'ına kadarını satmak ve sonra geri almak [63].

Startup Company
- Para bitince oyun zorla kredi aldırıyor, kredi bitene kadar [21]. Başlangıç: yatırım firması %40 hisse karşılığı küçük tohum parası verir [77].
- Finansman eleştirisi: yatırımcısız en çok 950 bin dolar kredi %30 faizle; 15 çalışanlı şirket bunu 3 ayda yer [74]. Bir oyuncuya göre ilk 30 dakika talepkâr, sonra sığ [56].

Big Ambitions
- Amcadan daire, ikinci el araba ve 15.000 dolarlık kredi [32]. Zorluk seviyeleri rekabeti ve vergi oranlarını değiştirir; Özel Oyun'da başlangıç parası ve açılışlar ayarlanır; tutorial atlanabilir [12]. Rakip şiddeti zorluğa bağlı [14].
- 2025'te (EA 0.9 "The Struggle") geliştirici başlangıcı zorlaştırdı: "you could previously start the game and be making millions if you create the right store in the right neighborhood." Kolay modda ücretsiz müşteri artışı eklendi [16]. Yeni öğretici rakibin ilk saldırısı gibi olaylara göre yan görevler çıkarıyor [17].
- Dengesizlik şikâyeti (2023): bir oyuncu 5 saatte ilerleyemedi, başka biri günde 100 bin kazandığını yazdı [62]. Görüş: aynı oyunda sonuçlar oyuncuya göre çok değişiyor.
- Ölçüm: 1.0 çıkışından sonra (2026-08-28 sonrası) %85 olumlu (646 yorum). Olumsuzların %32'si tekrar ya da mikro yönetim, %13'ü geç oyunda yapacak şey kalmaması [1].

Mad Games Tycoon 2
- Başlangıç 500 bin dolar ve oyuncular "çok fazla, her zor modda bile kolay başlangıç" buluyor [69]. Legendary modda ise iflas ayrı bir konu: "How to not go bankrupt in legendary?" (35 yanıt) [71].
- Geliştirici sandbox'ta ayar yelpazesini genişletti: rakip kalitesi, çalışan başvuru sayısı, çalışma hızı [26].

Başarısızlar
- Good Company (%70,3): "On the very first level after the tutorial levels you're already looking at potential bankruptcy" ve "change the rules on a fly to make your working line to be bankrupt in an instant without telling you what the rules are" [1]. Görüş: gizli kural ve erken iflas birlikte çok kötü okunuyor.
- Tech Executive Tycoon (6 olumlu / 38): yorumlar erken çıkış, öğretici penceresi kapatılamıyor, çökmeler [1].

Görüş: Desen. Başarılı oyunlar (Software Inc., Game Dev Tycoon, Mad Games, Big Ambitions) ya iflası bir öğrenme döngüsü olarak kabul ediyor ya da zorluk/başlangıç parasını oyuncuya veriyor. Başarısızlar kuralı gizliyor ya da öğretici olmadan iflas ettiriyor.

## Project Unicorn için dersler

1. Görüş: Rakip dünyası "sos" kalabilir ama davranışı olmalı. Startup Company'nin dersi: adlı ama pasif rakip, sabit bir satın alma hedefine dönüyor [76][54]. Big Ambitions'ın dersi: az sayıda adlı ve karakterli rakip iyi, çok sayıda isimsiz doldurucu kötü [59]. Öneri: 4-6 adlı rakip; her biri oyuncunun kararına cevap veren birkaç hamle yapsın (müşterini çel, çalışanını çal, fon topla, Ar-Ge kumarı, kapan). Erdem'in remote çalışan örneği doğal bir rakip hamlesi de olabilir: "rakip senin yazılımcını çaldı". Kapanan rakibin yerine yeni girişim doğsun [59][24]. Offworld'de hile şüphesi çıkıyor ama kural eşitliği tekrar kayıtlarıyla gösterilerek yanıtlanıyor [73]; rakibin kuralı görünür olmalı.
2. Görüş: B2C pazarlama. Runway baskısı için Startup Company'nin yapısı işe yarıyor: pazarlama maaştan sonra ikinci kalem, kısınca ölmüyor ama büyüme yavaşlıyor [74]. Kararı derin tutan şeyler: kitle seçimi (niş / geniş), söz verme (hype beklentiyi de büyütür [10]), zamanlama. Angarya olanlar: aynı reklamı her ay yenilemek [74]. Software Inc. 10 yılda satış sonrası pazarlamayı çözemedi [11]; biz de ilk sürümde küçük ve okunur kalmalıyız. B2B için pazarlama yerine fuar, referans ve olay mantığı daha doğal.
3. Görüş: Para, ilk saat ile 20. saat arasındaki farkı yaratmalı. Kanıt çok net: para amaç olarak kalırsa oyun zenginleşince bitiyor [41][40][68]. Megaquarium kalıbı (erken para, orta Ar-Ge, geç prestij) bu yüzden kopyalanacak bir örnek [41]. Bizde karşılığı: para (runway) → itibar ve müşteri güveni → değerleme → insanlar ve diplomasi. Yatırım sistemi eklenecekse kaybı görünür ve geri alınması zor olsun (Offworld) [72]; yoksa piyango (18 bine alıp 4 milyona satmak) ya da gösteriş olur [46][79].
4. Görüş: Delegasyon yeni karar türü getirmeli. Software Inc.'te "delegate, rake in even more money, no endgame" [40]; Big Ambitions'ta HQ kurup "nothing to do" [80][81]. VP'lere devretme ancak oyuncuya yeni bir iş veriyorsa (olay, diplomasi, itibar) işe yarar; yoksa Startup Company'nin "print money" fazı olur [75].
5. Görüş: Ofis geçişi basamak değil önizlemeli olmalı. Game Dev Tycoon oyuncuları taşınmayı milyonlar birikene kadar erteliyor çünkü yeni aylık gider (32-70 bin) kasayı batırıyor [63][64]. İş hanı $4.000 → Plaza $8.000 → Loft $18.000 basamakları bu riski taşıyor. Taşınma ekranında "yeni aylık gider / mevcut runway" gösterilmesi, Software Inc. gibi erteleme ve Mad Games gibi ek bina seçeneği düşünülebilir. Ofis geçişini seed sonrasına bağlamak Game Dev Tycoon'un "milyonları bekle" kuralının oyun içi karşılığıdır; Startup Company ise yatırımcı parasıyla ofisi ilk gün veriyor ve hedeflere bağlıyor [77]. İkisi de çalışan modeller. Evde başlayıp 1-2 uzak çalışan almak bu spektrumun ortası.
6. Görüş: Başlangıç parası. Karşılaştırma için kesin bir "doğru rakam" bulunamadı. Gördüğüm: oyunlar parayı zorluk ayarı yapıyor [12][26]; kolay modu "neredeyse iflas edilemez" yapmak geliştirici kararı oldu [43][3]; iflas yüzünden bırakma şikâyeti en çok öğretici zayıfken ve kural gizliyken çıkıyor [1]. Öneri: $10.000 / $50.000 kararını rakamla değil "kaç ay runway" ile ver ve bunu oyuncuya Frank üzerinden anlat (amca kredisi gibi hikâyeli başlangıç, Big Ambitions'ta 15.000 dolar [32]). Erken iflasta "hisse sat, devam et" gibi bir can simidi (Game Dev Tycoon forumunda %90'a kadar satış anlatılıyor [63]) Frank'in tek çekini ve seed'i doğal bir kurtarma yapabilir.
7. Görüş: Gizli gider testi. Erdem'in bilgisayar olayı iyi çünkü bir karar veriyor: "gönder / harçlık ver / kendi cihazıyla çalışsın". Big Ambitions'ta ani 70 bin dolar vergi ve her pazartesi "negative interest" öfke yarattı çünkü görünmüyor ve karar yok [79]. Software Inc. vergiyi ekledi ama atlatma yolu verdi [8]. Olay tasarımı için üç soru: gider önceden görülebilir miydi? Oyuncunun en az iki adlı seçeneği var mı? Seçimin sonucu sonraki haftalarda hatırlanıyor mu?
8. Görüş: Öğretici ve görev. Big Ambitions amca ile görev zinciri kurdu ve 0.9'da olaylara göre yan görevler ekledi (rakip ilk saldırdığında amca açıklıyor) [17]; tutorial atlanabiliyor [12]. Software Inc. kampanya modunu yeni oyuncuyu oyuna alıştırmak için yapıyor [9]. Bunun bizim 2026-10-06 tarihli "görev yok" kararıyla çelişip çelişmediği Erdem'in kararı.
9. Görüş: Demo vaadi. Veri şunu söylüyor: tekrar ve mikro yönetim türün ana olumsuzu (Startup Company %32, Big Ambitions 1.0 sonrası %32) [1]. Bu yüzden "ilk saat ile 20. saat farklı" vaadi Steam'de %90 hedefiyle doğrudan bağlantılı. Demoda bunu 60 dakikada göstermek için aynı sistemlerin iki farklı fazı (kurucu her şeyi yapar → PM planlar) görünür olmalı. Bunu test eden oyuncu verisi bende yok.

## Bulunamayanlar

- Capitalism Lab: Steam'de yok, oyuncu yorum verisi bulunamadı. Yalnız resmi site ve bir arama özeti var [34][35]. Yapay zekâ davranışı ve borsa tepkisi doğrulanamadı.
- Wikipedia'da Software Inc. sayfası yok (404). Fandom/wiki.gg/Reddit/RPS erişimi engelli; mekanik sayılar (temel kira, başlangıç parası) oyuncu aktarımı ve geliştirici duyurusundan geliyor, resmi tablo yok.
- Game Dev Tycoon'un başlangıç parası ve ofis kira rakamı için kaynak bulunamadı; forumdaki aylık 32 bin ve 70 bin dolar oyuncu beyanıdır [63][64]. Hype röportajının riskli yapısı arama özetinde geçti ama sayfası açılamadı; kullanmadım.
- Mad Games Tycoon 2'nin 500 bin dolarlık başlangıcı oyuncu beyanı [69]; resmi sayfada rakam yok [38].
- Mikrodan makroya geçişin (kurucu → VP → lobicilik) iyi çalışan örneği bu raporun sorularının dışındaydı; yalnız delegasyonun başarısız hâlini buldum [40][41]. Plutocracy ya da benzeri bir oyunun kanıtı yok.
- Yorum içeriğine dayalı konu yüzdeleri anahtar sözcük sayımıdır; yanlış pozitif içerir. Steam API'si son aşamada 429 verdi; MGT2, Software Inc. ve Game Dev Tycoon yorumlarının bazıları için tek tek bağlantı çekilemedi, bunlar [1] altında anılıyor.
- Offworld Designer Notes yazısının yayın tarihi sayfada görünmedi.
- Tekrar edilmedi: Steam kuralları, genel emsal tablosu ve satış tahminleri için EL_KITABI.md ve R2a/R2b raporlarına bakın.

## Kaynaklar

[1] Steam Reviews API, herkese açık: https://store.steampowered.com/appreviews/<appid>?json=1&language=english (appid: Software Inc. 362620, Game Dev Tycoon 239820, Mad Games Tycoon 2 1342330, Startup Company 606800, Big Ambitions 1331550, Offworld 271240, Capitalism 2 638200, Good Company 911430, Tech Executive Tycoon 274960). Çekim ve hesap: 2026-10-19.
[2] Steam News API (geliştirici duyuru metinleri): https://api.steampowered.com/ISteamNews/GetNewsForApp/v2/?appid=<appid>&count=400&maxlength=0. 2026-10-19. (Mad Games Tycoon 2 yama notu 2021-01-26 bu kaynaktan okundu.)
[3] Software Inc., Small difficulty update, 2015-06-12: https://steamcommunity.com/games/362620/announcements/detail/499118981896547100
[4] Software Inc., Alpha 7 officially out!, 2016-01-23: https://steamcommunity.com/games/362620/announcements/detail/341513287009312949
[5] Software Inc., Alpha 9 plans and patch release, 2016-07-27: https://steamcommunity.com/games/362620/announcements/detail/252584317718145810
[6] Software Inc., Alpha 9 out officially, 2017-09-06: https://steamcommunity.com/games/362620/announcements/detail/2127244445193959774
[7] Software Inc., Alpha 10 officially out, 2018-08-11: https://steamcommunity.com/games/362620/announcements/detail/2454911758748566987
[8] Software Inc., Taxes and accounting officially out, 2023-04-12: https://steamcommunity.com/games/362620/announcements/detail/5132456474583108375
[9] Software Inc., The overhauls will continue until morale improves, 2026-06-08: https://steamcommunity.com/games/362620/announcements/detail/1834602721199696
[10] Software Inc., Overhaul update, 2026-08-05: https://steamcommunity.com/games/362620/announcements/detail/1840310314338984
[11] Software Inc., Final Overhaul update, 2026-10-04: https://steamcommunity.com/games/362620/announcements/detail/1845383656391730
[12] Big Ambitions, Here comes Beta 6!, 2022-09-26: https://steamcommunity.com/games/1331550/announcements/detail/4589754330746620444
[13] Big Ambitions, Studio & Future Insights, 2023-08-19: https://steamcommunity.com/games/1331550/announcements/detail/5127964289180343918
[14] Big Ambitions, EA 0.5 - The Rivalry Begins, 2024-04-18: https://steamcommunity.com/games/1331550/announcements/detail/5762994032390244458
[15] Big Ambitions, EA 0.5 Preview, 2024-03-27: https://steamcommunity.com/games/1331550/announcements/detail/5749481331433201339
[16] Big Ambitions, EA 0.9 - The Struggle: Preview, 2025-08-12: https://steamcommunity.com/games/1331550/announcements/detail/1807332909730250
[17] Big Ambitions, EA 0.9 - The Struggle, 2025-09-30: https://steamcommunity.com/games/1331550/announcements/detail/1811772772408660
[18] Big Ambitions, Studio & Future Insights #4, 2025-12-04: https://steamcommunity.com/games/1331550/announcements/detail/1818118366173165
[19] Big Ambitions, 1.0 FULL RELEASE, 2026-08-28: https://steamcommunity.com/games/1331550/announcements/detail/1842212951303861
[20] Startup Company, Competitors & Stocks, 2017-07-16: https://steamcommunity.com/games/606800/announcements/detail/2472890725407174894
[21] Startup Company, Beta 13 Released, 2017-12-01: https://steamcommunity.com/games/606800/announcements/detail/2152021858900112360
[22] Startup Company, Devlog #21, 2018-07-06: https://steamcommunity.com/games/606800/announcements/detail/2499943313684531196
[23] Startup Company, Development Recap 2018, 2018-12-30: https://steamcommunity.com/games/606800/announcements/detail/2417769111319906976
[24] Mad Games Tycoon 2, First Year Anniversary, 2022-01-21: https://steamcommunity.com/games/1342330/announcements/detail/4237325463675656030
[25] Mad Games Tycoon 2, Company Acquisitions!, 2022-04-28: https://steamcommunity.com/games/1342330/announcements/detail/4348798430274738151
[26] Mad Games Tycoon 2, Development Update for 2024, 2024-01-17: https://steamcommunity.com/games/1342330/announcements/detail/5510784213094558022
[27] Game Dev Tycoon, How to avoid bankruptcy in GDT, 2024-01-10: https://steamcommunity.com/games/239820/announcements/detail/5510783579247039069
[28] Designer Notes, Offworld Trading Company Early Access Postmortem (tarih sayfada yok): https://www.designer-notes.com/offworld-trading-company-early-access-postmortem/
[29] Game Developer, Postmortem: Offworld Trading Company's early access campaign (tarih okunmadı): https://www.gamedeveloper.com/business/postmortem-i-offworld-trading-company-i-s-early-access-campaign
[30] Wikipedia, Offworld Trading Company, okundu 2026-10-19: https://en.wikipedia.org/wiki/Offworld_Trading_Company
[31] Wikipedia, Game Dev Tycoon, okundu 2026-10-19: https://en.wikipedia.org/wiki/Game_Dev_Tycoon
[32] PC Gamer, "I'm completely hooked on this open world business sandbox sim", 2023-04-03: https://www.pcgamer.com/im-completely-hooked-on-this-open-world-business-sandbox-sim-and-im-not-alone/
[33] GGRecon, Early Hours: Big Ambitions (tarih okunmadı): https://www.ggrecon.com/articles/big-ambitions-early-hours/
[34] Legacy of Games, Capitalism Lab, 2025-11-13 (yalnız arama özeti, sayfa açılmadı): https://legacyofgames.com/2025/11/13/capitalism-lab
[35] Capitalism Lab resmi sitesi, 2026-10-19: https://www.capitalismlab.com/
[36] Steam mağaza sayfası, Big Ambitions, 2026-10-19: https://store.steampowered.com/app/1331550/Big_Ambitions/
[37] Steam mağaza sayfaları, Startup Company ve Software Inc., 2026-10-19: https://store.steampowered.com/app/606800/Startup_Company/ ve https://store.steampowered.com/app/362620/Software_Inc/
[38] Steam mağaza sayfası, Mad Games Tycoon 2, 2026-10-19: https://store.steampowered.com/app/1342330/Mad_Games_Tycoon_2/
[39] Steam mağaza sayfası, Game Dev Tycoon, 2026-10-19: https://store.steampowered.com/app/239820/Game_Dev_Tycoon/
[40] Software Inc. forum, "Endgame?", 2024-07-07: https://steamcommunity.com/app/362620/discussions/0/4407417835485279397/
[41] Software Inc. forum, "what am i supposed to do?", 2021-02-20: https://steamcommunity.com/app/362620/discussions/0/3117024613289520969
[42] Software Inc. forum, "IMPROVE AI?", 2023-02-25: https://steamcommunity.com/app/362620/discussions/0/3779120349290477936/
[43] Software Inc. forum, "Large change in difficulty", 2015-06-09: https://steamcommunity.com/app/362620/discussions/0/615086038687074153/
[44] Software Inc. forum, "Bankrupt Again?", 2019-11-06: https://steamcommunity.com/app/362620/discussions/0/1639801448908234733/
[45] Software Inc. forum, "Two bankrupt companies after 14 hours...", 2016-09-20: https://steamcommunity.com/app/362620/discussions/0/343786746017531224/
[46] Software Inc. forum, "Starting Tips", 2018-02-22: https://steamcommunity.com/app/362620/discussions/0/1692662302106901231/
[47] Software Inc. forum, "Increase Starting money", 2018-05-27: https://steamcommunity.com/app/362620/discussions/0/1694922526909738324/
[48] Software Inc. forum, "Marketing", 2022-03-24: https://steamcommunity.com/app/362620/discussions/0/3176733459032348748/
[49] Software Inc. forum, "Marketing and Market Recognition is nonsensical." (yıl başlıkta yok, 2026-08-27 sayıldı): https://steamcommunity.com/app/362620/discussions/0/591813764140124572/
[50] Software Inc. forum, "Stock Market Overhaul", 2017-12-16: https://steamcommunity.com/app/362620/discussions/0/2549465882924940322/
[51] Software Inc. forum, "Far too easy to make money and far too hard to roleplay", 2021-08-22: https://steamcommunity.com/app/362620/discussions/0/3046109410085015044/
[52] Software Inc. forum, "Some tips for start?", 2015-05-03: https://steamcommunity.com/app/362620/discussions/0/613956964596417077
[53] Software Inc. forum, "Too easy getting rich?", 2016-03-26: https://steamcommunity.com/app/362620/discussions/0/385429254940027788/
[54] Startup Company forum, "What next?", 2018-08-08: https://steamcommunity.com/app/606800/discussions/0/1744468917519116491/
[55] Startup Company forum, "Late Game Needs Work", 2019-02-24: https://steamcommunity.com/app/606800/discussions/0/1796278072841553872/
[56] Startup Company forum, "Is this game too easy right now? Or Am i the only one", 2017-08-18: https://steamcommunity.com/app/606800/discussions/0/2579854400740583907/
[57] Startup Company forum, "Marketing", 2019-11-27: https://steamcommunity.com/app/606800/discussions/0/1740008504955175289/
[58] Startup Company forum, "How do I reduce Investor's Cut for retirement fund?", 2024-01-15: https://steamcommunity.com/app/606800/discussions/0/6273018183379702083/
[59] Big Ambitions forum, "Thoughts on rivals", 2025-08-27: https://steamcommunity.com/app/1331550/discussions/0/591780787069733585/
[60] Big Ambitions forum, "How do you defeat a Rival?", 2025-01-05: https://steamcommunity.com/app/1331550/discussions/0/600766744405006657/
[61] Big Ambitions forum, "Rival Strategies", 2024-05-02: https://steamcommunity.com/app/1331550/discussions/0/4357872216491604185/
[62] Big Ambitions forum, "The Game is not balanced", 2023-03-14: https://steamcommunity.com/app/1331550/discussions/0/3825284144447141073/
[63] Game Dev Tycoon forum, "Any tips for pirate mode?", 2018-03-18: https://steamcommunity.com/app/239820/discussions/0/2949168687319084666
[64] Game Dev Tycoon forum, "Best time to move to the office?", 2023-08-29: https://steamcommunity.com/app/239820/discussions/0/3825299103413571355/
[65] Game Dev Tycoon forum, "keep going bankrupt", 2014-01-29: https://steamcommunity.com/app/239820/discussions/0/558746089931212105/
[66] Game Dev Tycoon forum, "This game is way too hard", 2013-11-10: https://steamcommunity.com/app/239820/discussions/0/666825525257120781/
[67] Game Dev Tycoon forum, "How does marketing work?", 2019-01-18: https://steamcommunity.com/app/239820/discussions/0/154645539344636637
[68] Mad Games Tycoon 2 forum, "There's no place to spend a lot of money.", 2022-02-23: https://steamcommunity.com/app/1342330/discussions/0/3192493519700283368
[69] Mad Games Tycoon 2 forum, "Lower Starting Money", 2021-05-14: https://steamcommunity.com/app/1342330/discussions/0/5625537320586645983/
[70] Mad Games Tycoon 2 forum, "Competitors / difficulty", 2023-07-20: https://steamcommunity.com/app/1342330/discussions/0/3811784760597703444/
[71] Mad Games Tycoon 2 forum, "How to not go bankrupt in legendary?", 2025-05-22: https://steamcommunity.com/app/1342330/discussions/0/600779252329095472/
[72] Offworld forum, "AI Cheats ?", 2015-06-18: https://steamcommunity.com/app/271240/discussions/0/598198356187564855/
[73] Offworld forum, "Fairer enemy AI", 2019-03-18: https://steamcommunity.com/app/271240/discussions/0/3247565033770831021/
[74] Steam yorumu, Startup Company, 2019-02-03 (olumsuz): https://steamcommunity.com/profiles/76561198024646136/recommended/606800/
[75] Steam yorumu, Startup Company, 2017-08-15 (olumsuz): https://steamcommunity.com/profiles/76561197995217408/recommended/606800/
[76] Steam yorumu, Startup Company, 2020-10-03 (olumsuz): https://steamcommunity.com/profiles/76561197997164615/recommended/606800/
[77] Steam yorumu, Startup Company, 2020-04-11 (olumlu, oyun yapısı özeti): https://steamcommunity.com/profiles/76561198132476688/recommended/606800/
[78] Steam yorumu, Startup Company, 2018-06-26 (olumlu, pazarlama): https://steamcommunity.com/profiles/76561197971724802/recommended/606800/
[79] Steam yorumu, Big Ambitions, 2026-03-24 (olumsuz, vergi/faiz/borsa): https://steamcommunity.com/profiles/76561198819349353/recommended/1331550/
[80] Steam yorumu, Big Ambitions, 2026-04-03 (olumsuz, boş geç oyun): https://steamcommunity.com/profiles/76561197983740606/recommended/1331550/
[81] Steam yorumu, Big Ambitions, 2026-02-21 (olumsuz-nötr, "Then what?"): https://steamcommunity.com/profiles/76561198021576047/recommended/1331550/
[82] Steam yorumu, Big Ambitions, 2026-07-30 (olumlu, rakip sığ): https://steamcommunity.com/profiles/76561198000309714/recommended/1331550/
