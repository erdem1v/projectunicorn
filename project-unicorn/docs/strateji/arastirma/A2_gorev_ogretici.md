# A2 - Yönetim oyunlarında öğretici ve görev sistemleri

Arama notu (en başta): 11 WebSearch çağrısı yaptım (kural: en çok 11). Biri reddit.com alan adı filtresi yüzünden hata verdi; bu bütçe hatası değildi, filtreyi çıkarınca çalıştı. 10 çağrı sonuç verdi. 11. çağrıdan sonra arama yapmadım. Gerisi WebFetch, Steam'in herkese açık Yorum ve Duyuru API'leri [102][103] ve yerel dosyalarla yapıldı. Kaynaksız satır varsa "Kaynaksız (model bilgisi):" diye işaretli.

Arama sayısı: 11

Tarih: 2026-10-19. Yöntem: (1) Steam yorumları: her oyun için 300-750 İngilizce yorum (en yararlı ve en yeni) çekilip "tutorial, milestone, quest" gibi sözcüklerle süzüldü [102]. Bu örnek bir sıklık ölçüsü değildir; hangi övgü ve şikâyetlerin var olduğunu gösterir. Yorumdaki POS/NEG etiketi oyuncunun oyuna verdiği oydur, öğreticiye değil. (2) Geliştirici duyuruları: Steam duyuru API'si [103]. (3) Sayfalar: WebFetch. Okunamayanlar "Bulunamayanlar"da. EL_KITABI.md'yi tekrar etmedim.

## Kısa cevaplar

1. Öğretici yaklaşımları: (a) akıl hocası + telefon görev zinciri: Big Ambitions'ta Uncle Fred [2][3]; (b) yatırımcı/danışman + kilometre taşı: Startup Company'de yatırımcının danışmanı, geliştiricinin sözüyle "tutorial mode in disguise" [18][19]; (c) öğretici seviye: Two Point Hospital'da Hogsport [35], Project Hospital'da ayrı öğretici senaryolar [74]; (d) açılıp kapanan ipuçları: Software Inc, Game Dev Tycoon [29][31]; (e) hiç öğretici yok: Oxygen Not Included yorumları [96]. İlk 15 dakika dökümü Bulgular 1'de.
2. Serbest oyunda görev: oyuncu, görev isteğe bağlı, süresiz ve kapatılabilirse seviyor. Big Ambitions bunu yapıyor ve %91 olumlu [1][12][13]. Kızdığı yerler: liste hiç bitmeyip oyunun kendisi olunca [60], hedef nedensiz bir sayı olunca [86], görev sırası bozulunca [4][5][6]. Kuram da uyarıyor: görünür listedeki isteğe bağlı hedef fiilen zorunlu olur [45].
3. Yatırımcı şartı görev olarak: en yakın emsal Startup Company. Kilometre taşları hem rehber hem para [17]. Football Manager'da yönetim kurulu hedefleri ve güveni var, yönetici kovulabilir [43][44]. İki yerde de şikâyet: bir oyuncuya göre şartlar öz sermaye satmaya zorlayıp geri dönüşsüz oluyor [24]; eşikler keyfî görünüyor [101].
4. Öğretici şikâyetleri altı grupta toplanıyor: duvar gibi metin, öğretici batırıyor, takılma ve hata, çok uzun, hiç yok ya da yarıda bırakıyor, "neden olmuyor" cevapsız. En sert örüntü: öğreticiyi harfiyen izleyip batanlar; örneklemde dört yorum, üç oyun [49][61][62][66].
5. Öğreticiden sonra hedefi kim veriyor: oyuna göre değişiyor. Big Ambitions'ta pratikte kimse: geliştirici hesabına göre sonraki görevler "daha çok iş, daha çok para" demek [12]; sonucu geç oyunda tavan ve yapacak şey kalmadı şikâyeti [50][54]. Startup Company'de yatırımcı kilometre taşları #1'e kadar sürüyor, sonra emeklilik fonu hedefi [23]. Two Point'te yıldızlar [33]. Cities'te nüfus ve XP kilometre taşları [37][38]. Satisfactory'de HUB kilometre taşları [85]. Plutocracy'de boşluk: "now what" [97].

## Bulgular

### Soru 1 - Yaklaşımlar ve ilk 15 dakika

- Big Ambitions (Steam: %91, 6.249 İngilizce yorum [1]). Açılış "amcanın yardımıyla bir daire ve ilk iş" [1]. Öğretici Uncle Fred: telefondaki bir kişi [13], hedefler sırayla gelir, parmak simgesi yönü gösterir [2][6]. Oyuncu ilk işi (El Gato ya da teslimat şoförlüğü [2]), ucuz yatağı [7], sonra mağaza, depo ve merkez kurmayı öğrenir [12][50]. Bir yorumcu: Fred'in görevleri iş kurmayı, şirket yönetmeyi, depo-fabrika ve lojistiği öğretiyor; "Once you complete those steps one by one, you are entirely on your own." [50]. Fred 2022'den beri atlanabiliyor [3]; 2025'te öğretici baştan yazıldı: oyuncunun kurduğu mağazaya göre görev ayarlıyor, bağlama göre yan görev çıkarıyor (ilk rakip saldırısında Fred durumu anlatıyor) [2]; yan görevler rakip, acil kredi gibi olaylara bağlı [9].
- Two Point Hospital: ilk hastane Hogsport, geliştirici duyurusunda "tutorial level" diye geçer [35]. Adımlar: resepsiyon, pratisyen odası, oda boyutu ve prestij [36]. Ekranda sürekli hedef kutusu ve altta bir danışman var [33]. Stüdyodan Mark Smart hedefleri şöyle anlatıyor: "a way of getting people through the game and making it so you've got a sense of urgency." [34]. Bir yıldız sonraki hastaneyi açar [33].
- Startup Company (Steam: %80, 2.898 İngilizce yorum [16]): yatırımcı seçilir; yatırımcı para ve tavsiye verir, geliştirici bunu "tutorial mode" diye adlandırır [19]. Danışman, sıradaki kilometre taşını nasıl yapacağını mesajla söyler: "tutorial mode in disguise" [18]. Kilometre taşı yatırımcının beklentisidir, ulaşınca sabit para ödenir [17]. Oyuncular danışmanı adıyla anıyor: "doing what Pam tells you to do" [25].
- Software Inc: öğreticiler açılıp kapanıyor ("if tutorials are enabled") [29]; tasarım belgesi öğreticisi basit/ileri/tam diye üçe bölünmüş [28]; öğreticiye geri dönülebiliyor [30]; geliştirici 2019'da "öğreticileri yeniden yazmalıyım" diyor [27]. Olaya bağlı ders: "Office dangers" öğreticisi, öğretici açıksa kayıt başına bir hırsızlık veya yangını engelliyor [29].
- Game Dev Tycoon: garajda başlar, yeni seçenekler oyun yaptıkça açılır [32]. İlerleme ipuçları 2018'de "şirket kilometre taşları" olarak kategorilendi ve varsayılan açık geliyor [31]. Bir yorumcu yine de oyunun neden zarar ettiğini anlatmadığını söylüyor [70].
- Plutocracy: 2021'de "New tutorial system" yayınladı [47]; yorumda "Tutorials are information rich, but insight poor." [100].
- Project Hospital: ayrı öğretici seviyeleri. Övgü: "The tutorials are excellent." [77]; "I only played the tutorials and then went straight to building my personal hospital in the sandbox mode." [78]. Şikâyet: öğretici 2'de 30 dakika, öğretici 3'te 1 saat takılma [74], "weird softlocks" [75].
- Frostpunk: ana senaryo üç perde, ilki hayatta kalma temellerini öğretir [39]. Yorumlar bölünmüş: "Lack of a tutorial but ... you can probably figure it out?" [81] ve "You have to manually click on some tiny pop-up" [79].
- Cities: Skylines: nüfus eşikleri okul, itfaiye gibi hizmetleri açar; öğretici eleştirmenlerce övülmüş [37]. Bir yorumcu temel bilgiden sonra bırakıldığını yazıyor [83].
- Tropico 6: yalnız ilk görev (Penultimo ile tanışma) ve son görev doğrusal, ara görevlerin zaman çizelgesinde sabit yeri yok [41]. Yorum: "Missions teach you each of the sub systems" [91]. Democracy 4: politika sürgüleri; olay, ikilem, durum diye üç tür istem [42]; bir yorum "definitely use the tutorial, it's pretty good" [94], başka biri öğretici bulamayıp "drops you in with LOTS of information" diyor [93].
- Kerbal Space Program: Kariyerde sözleşmeler: zamanında bitirmek para ve itibar kazandırır, itibar daha zor sözleşmeleri açar [40]. Yorum: ilk sözleşmeler "very simple and achievable" [90]; öğretici ise "buried under a massive tutorial" [89].

### Soru 2 - Serbest oyunda görev sistemi: seviyorlar mı, kızıyorlar mı

- Sevdikleri: Big Ambitions'ta bir oyuncu "There's no time limit on anything he asks you to do" diyor ve istekler ilerlemek için gerekli değil; geliştirici hesabı, depo ve merkez görevlerinden sonra Fred'i boş verebileceğini, sonraki görevlerin "make more businesses and more money!" olduğunu yazıyor [12]. Telefonla "dur" denir, sonra geri açılır, başarımlar korunur [13]; bir yorumcu aynı şeyi "You can call your tutor to turn off the tutorial" diye anlatıyor [57]. Geliştirici: "if you already know the basics, you're safe to skip it." [15]. Oyuncu: "do not get in the way, as you can just ignore them" [53]; en çok oy alan olumsuz yorum bile "the tutorial is not in your face" diyor [59]; "one of the best tutorials I've ever played in my 25 years of gaming" [51].
- BA'nın bedeli bakım (1.0 öncesi Fred, bir görev tamamen atlanınca diyaloğunu iki kez tekrarlıyordu [11]): 2023'te adımları sırasız yaparsan bazen yeniden yapmak gerekiyordu [6]; 2025'te Fred'in tavsiyesine tam uymayan ya da işleri erken yapan oyuncu için ayar [4]; 2025'te ofis (Office işletmesi) alınca teslimat görevi otomatik tamamlanır oldu [10]; 2026'da görevleri erken yapınca GPS yanlış mağazayı gösteriyordu [5]; 1.0'dan sonra bile "tutorial issues" ve "tutorial events could misfire" düzeltmeleri [7][8]. Görevler başarımlara da bağlı: "Your Best Friend - Gold" Fred'in 90 hedefini ister [14].
- Kızdıkları 1 - listenin kendisi oyun olunca: Startup Company yorumu: "the tutorial isn't even the tutorial I found out. IT'S THE ACTUAL GAME." ve "When you look at the milestones it keeps going till you become #1." [60]. Geliştirici zamanla kuralları yumuşattı: yalnız sıradaki kilometre taşı açılır [21], ödemeler artırıldı [20], son oyun kilometre taşları eklendi [22].
- Kızdıkları 2 - hedef nedensiz sayı olunca: Satisfactory'de (Steam: %97, 138.342 yorum [48]) iki yüz birden: "You never feel like you have no idea what to do next." [85] ve "No driving force to push you towards the next milestone besides 'here is a number to achieve'." [86]. Bir yorumcu uzay asansörü aşaması bitince ödül olmadığını yazıyor [88]. Kilometre taşı zinciri aslında öğretici: "The tutorial takes most people 60 hours" [87].
- Kızdıkları 3 - hedef şişmesi: Two Point'te üç yıldız için 400 hasta, sonra 500 hasta daha [71]; bir yıldızla sonraki hastaneyi açmak için her seferinde aynı kurulumu tekrarlamak [72]. Hedefi "very simple to achieve but just take so much time" bulan da var [107].
- Tropico'da görevler hem övülüyor [91] hem "missions ... just end when you beat one" [92]; bir eleştirmen hedef tasarımındaki belirsizliği "source of frustration" bulmuş [41].
- Kuram: Nikhil Murthy (Game Developer, 2017): görünür listede isteğe bağlı hedef koyarsan oyuncu "bitmemiş liste"nin "nagging itch"ini yaşar, hedef fiilen zorunlu olur; ya hepsini yapar (seçim anlamsız) ya hiçbirini (hedef gereksiz) [45]. Önerisi: isteğe bağlı hedefi seçmek bir bedel taşısın [45].

### Soru 3 - Yatırımcı ya da patron şartı görev olarak

- Startup Company: Venture Capital sekmesi eski "Goals" özelliğinin yerine geldi; kilometre taşları yatırımcıların oyuncudan beklentisini koyar, ulaşınca sabit para ödenir [17]. Sonradan: yalnız sıradaki kilometre taşı [21]; "yeni ürün" şartı tam satın alma yerine 15 kilometre taşına indirildi [21]; ödemeler artırıldı [20]. Oyuncu tarafı (konu özeti): bir kilometre taşı ürünün yaklaşık %25'ini satmayı gerektirmiş, ödül 1 milyon dolar, geri alma 150 milyon [24]. Başka bir oyuncu, bir yatırımcının "around $10 billion" istediğini yazıyor [26]. Geliştirici "satın alma kasıtlı zor, biraz gerçekçi olsun" diyor ve eğriyi "less steep" yapmak için üç kilometre taşı daha eklemeyi planlıyor [24]. Başka bir konuda: "if you miss two check points in a row its done." [25]. Yorum: "investment opportunities are pretty much useless by the time you have the capital" [65].
- Üst hedef: 2019'da CEO oyun içinde yaşlanıyor, 67'de emekli oluyor ve oyun bitiyor; "ana hedef" parayı emeklilik fonuna aktarmak [23].
- Football Manager: yönetim kurulu güveni (hedefler finansal veya stratejik) ve taraftar güveni ayrı [43]. Güven ekranı beş başlık: sonuçlar, finans, maç geri bildirimi, transfer, oyuncu performansı [44]. Olumsuz geri bildirime rağmen sürekli talep edersen "could even be sacked" [44]; reddedilirsen ültimatom çekebilirsin [44]. Şikâyet: 302 saatlik bir yorum yönetim kurulunun "arbitrary thresholds" ile ölçtüğünü söylüyor [101]. FM'nin güncel hedef mekaniği okunamadı (Bulunamayanlar).
- Democracy 4: seçimden önce iki söz verilir; bozmak seçmen şüpheciliğini artırır [42]. Kerbal: sözleşme + itibar [40].

### Soru 4 - Öğretici şikâyetleri (Steam yorumlarından)

- Duvar gibi metin, yetersiz: Software Inc "walls of dry, boring text" [67]; "tutorials are very opaque" [68]; "new users frequently have to watch hours of youtube footage" [69]. Plutocracy "Tutorials are information rich, but insight poor." [100]. Frostpunk: "they don't tell you why things aren't working" [80].
- Öğretici batırıyor: Startup Company "The tutorial led me to bankruptcy." [61]; "I've played this game EXCATLY as the tutorial points out only to constantly be going bankrupt." [62]; Software Inc "Terrible tutorials ... caused me to over extend and bankrupt." [66]; Big Ambitions "The tutorial actually sets you up to fail." [49]. Biri 1,1 saatte iade etmiş: öğretici "tells you to build your second website feature, and then leaves you to rot" [63].
- Takılma ve hata: Project Hospital [74][75]; Big Ambitions'ta öğretici GPS ve olay hataları yamayla düzeltiliyor [5][8]; Tropico'da öğreticinin istediği kamera eğme çalışmayınca oyuncu bırakmış: "the 'Tilt Camera' required in the tutorial" [104].
- Çok uzun ya da ağır: KSP "buried under a massive tutorial" [89]; Startup Company "the extended tutorial has you doing things without explaining and half the time is spent idling" [105]; Satisfactory kilometre taşı zinciri 60 saat [87] ama o yorum şikâyet değil, övgü.
- Hiç yok ya da yarıda bırakıyor: Game Dev Tycoon "left to figure everything out" [70]; Democracy 4 [93]; Mad Games Tycoon 2 "no tutorial but also just nothing to do" [95]; Cities "Tutorials explain the most basic information, then tell you nothing about how the main mechanics work" [83].
- Bilerek öğreticisiz: Oxygen Not Included "there's no tutorial and it will gladly let you die repeatedly... very rewarding" [96]; aynı çizgi başka oyuncuyu kaçırıyor: "I hate having to look up tutorials on how to run every part of my colony" [106].
- Ne yapacağını bilememe: Project Hospital'da bir yorumcu "knowing what to build and how to do it" için öğretici yardımı bulamamış [76].
- Erken kayıp: Startup Company "It needs better tutorials and/or easier goals at first" (1 saatlik, 13 oy) [64]. Cities'te kilidi açılmamış kredi yüzünden çıkmaza giren oyuncu: "I also can't progress to unlock loans because I'm never bleeding less than $1,200 weekly." [83].

### Soru 5 - Öğreticiden sonra hedefi kim veriyor

- Big Ambitions: geliştirici hesabına göre bir noktadan sonra görevler "make more businesses and more money!" olur [12]. Sonuç: "Once you truly progress ... there's not much left to do." [50]; "I've hit the ceiling towards the endgame" ve "a few massively expensive supergoals" önerisi [54]; "I hope they added more quest in the storyline especially the main quest with Fred." [55]; "It will require you to find yourself something to do starting early-midgame." [56]. Rakip mekaniği "very shallow: you buy their businesses" bulunmuş [58]. 0.9 güncellemesi geç oyunu "ilerleme" kısıtlarıyla yavaşlattı: en kârlı ürünler için fabrika şart [2].
- Startup Company: yatırımcı kilometre taşları (2018'de toplam 20 [108]), 2019'da geç oyun kilometre taşları [22], emeklilik hedefi [23].
- Two Point: yıldızlar; Ben Hymers: "Stars are just a natural mechanic to award you for doing that" (önceki hastaneye dönmek için) [34]. Yorum: "levels are always easy enough to '1 star' ... and unlock the next hospital" [73].
- Cities: Skylines: kilometre taşı = nüfus eşiği; Colossal Order'ın kendi tespiti: eşikler "varied depending on the buildable land", yani tek yol "daha çok konut" [38]. Cities II'de XP: nüfus, mutluluk ve eylemlerden; 20 kilometre taşı para, hizmet, politika ve yönetim seçeneği açar [38]; bir yorumcu bunu "earn XP based on citizen happiness and population growth" diye övüyor [84].
- Plutocracy'nin Steam özeti: %79 olumlu, 1.321 yorum [46]. Software Inc: açık bir "sıradaki hedef" listesi bulamadım; bir yorumcu "it really needs some improvements especially for the late game" yazıyor [109]. Plutocracy: "Make money, influence people, play the market ... and then what." [97]; "my reward for the early game was an incredibly mindless and monotonous lategame" [98]; bir oyuncunun önerisi: erken oyun daha kısıtlı olsun, bir kaç başarıdan sonra serbestlik gelsin, kilometre taşlarında rakip açılsın [99]. Frostpunk: "the ending left me feeling lost instead of motivated" [82].
- Football Manager: hedef verici yönetim kurulu, her sezon [43][44]. Kerbal: sözleşmeler [40].

## Project Unicorn için dersler

Görüş: Bu bölümün tamamı benim çıkarımımdır; dayanak köşeli parantezde.

1. Görüş: "Frank'le görev mantığı" mantıklı, ama Frank'in iki rolü görünürde ayrı olmalı. (a) Öneri: isteğe bağlı, süresiz, tek tuşla "Frank'i sustur / geri çağır". Big Ambitions tam böyle ve %91 olumlu [1][12][13][15] (neden-sonuç kanıtı değil, yalnız emsal). (b) Çek şartı: bağlayıcı, kasaya bağlı, her zaman görünür. Aynı listede ikisini karıştırırsan isteğe bağlı olan zorunluya döner [45]. Startup Company'nin yatırımcı kilometre taşı çizgisi (b)'ye en yakın emsal [17].
2. Görüş: Görev listesi yerine durum yüklemleri yaz. "Ev ofisi kuruldu mu, ilk satış yapıldı mı" gibi dünya durumuna bakan hedefler; oyuncu erken yaptıysa otomatik tamamlansın. Big Ambitions bunu yıllar içinde yamayla öğrendi (2023'ten 2026'ya) [4][5][6][10]. Bizde ev -> İş hanı taşınması hedefleri bozabilir; BA'da buna "Tutorial now points to your house even if you move" düzeltmesi var [8].
3. Görüş: Öğretici batırmamalı; kapı olarak "harfiyen izleyen bot batmaz" testi koy. Dört yorum, üç oyun (Startup Company, Software Inc, Big Ambitions) tam bu hatayı yaşıyor [49][61][62][66]. Kuruluş kasası $10.000 mi $50.000 mi sorusu bu botun sonucuyla verilebilir; bu araştırmada kasa miktarına dair doğrudan veri yok. Kaynaksız (model bilgisi): Steam iadesi 14 gün ve 2 saat içinde yapılabilir; ilk iki saatteki öğretici hatası doğrudan iadeye gider (bir yorum 1,1 saatte iade etmiş [63]).
4. Görüş: Öğretici bir kez biter ve "mezuniyet" anı olur; sonra hedefi başka bir ses verir. Big Ambitions'ta öğretici bitince "entirely on your own" [50] ve geç oyunda tavan ile yapacak şey kalmadı şikâyeti çıkıyor [50][54]; Plutocracy'de "now what" [97]; Startup Company'de ise tersi: kilometre taşı listesi bitmediği için oyuncu öğreticiyi oyunun kendisi sanıyor [60]. Önerilen sıra: Frank (mentor) -> tohum yatırımı şartları (seed) -> Series A kurul hedefleri -> Series B'de VP raporları. Football Manager'ın yönetim kurulu hedefi + güven modeli [43][44] son iki basamak için emsal.
5. Görüş: Olay yazımı en güçlü öğretici katman olabilir. Erdem'in "uzaktaki çalışan bilgisayar ister" örneği, öğretici metni olmadan bir maliyet dersi veriyor. Emsal: Software Inc'in "Office dangers" öğreticisi bağlama bağlı ve tek sefer [29]; Big Ambitions'ın ilk rakip saldırısı yan görevi Fred'i bağlama göre konuşturuyor [2][9]. Öneri: her yeni sistem için "ilk karşılaşma" olayı listesi (ilk uzak işe alım, ilk maaş günü, ilk sprint kaybı, ilk müşteri ayrılışı); ilk görünüşü garanti, sonrası rastgele; Frank gerekirse tek cümleyle yorumlar.
6. Görüş: Kilometre taşı bir sayı değil, yeni bir kaldıraç açmalı. Satisfactory'de "here is a number to achieve" şikâyeti [86]; Cities II her kilometre taşında para, hizmet, politika, yönetim seçeneği veriyor [38]; Two Point'te yıldız sonraki hastaneyi açar [33]. Bizde bu kaldıraç tam "mikrodan makroya" geçişin kendisi: planlamayı PM'e devretmek, ilk departman başkanı, ofis. Cities'in tek ölçütlü nüfus eşiği tek yol dayatıyordu [38]; seed/ofis/PM açılışlarını birden çok koşula bağla.
7. Görüş: Çek şartı ölüm sarmalı olmamalı. Startup Company şartı öz sermaye satmaya zorlayıp geri dönüşü yok etti [24], "iki kontrol noktasını kaçırırsan bitti" [25]; geliştirici sonra yalnız sıradakini açtı, ödemeleri artırdı [20][21]. Football Manager'da "arbitrary thresholds" şikâyeti var [101]. Öneri: eşik görünür; bir kaçırma uyarıdır, ikincisi ceza; ödül net.
8. Görüş: Hedef şişmesinden kaçın. Two Point'te üç yıldız 400, sonra 500, 1000 hasta [71]; yeni hastane = aynı kurulumun tekrarı [72]. Dönem hedefleri her seferinde farklı eksen olsun (ürün, satış, ekip, nakit); Two Point'in geliştiricisi, ikinci yıldız hedeflerinin oyuncuyu odaları yeniden düzenlemeye itebileceğini söylüyor [34].
9. Görüş: Demo'da "ilk saat ile 20. saat farkı" tek bir sahnelenmiş an ile gösterilmeli. Big Ambitions yorumcusu farkı kendisi anlatıyor: öğretici hedeflerini yaparsan "barely have to leave your house" noktasına varıyorsun [52]. Bizde bu an PM'e planlama devri olabilir; Frank'in görevi o ana kadar götürür, devirden sonra "önce/sonra" ekranda görünür. Tahmin: mağaza sayfası mesajı da aynı an olur.
10. Görüş: Bakım maliyetini hesaba kat. Big Ambitions Fred'in diyaloglarını 2022'de yeniledi [3], öğreticiyi 2025'te baştan yazdı [2] ve 1.0 sonrasında bile yama aldı [7][8]. Öğretici akışını smoke setine koy: "Frank'i izle", "Frank'i sustur", "görevleri erken yap", "ev ile ofis arası taşın" senaryoları.
11. Tahmin (doğrulanmadı): Big Ambitions'ta öğreticiyi kapatınca oyun öğreticiyi bitirmiş sayıyor ve çalışanlar sağlık güvencesi istemeye başlıyor [Bulunamayanlar]. Ders: öğretici sırasına kilitli mekanik olmasın; atlayan oyuncuda tüm mekanikler açık kalsın.
12. Kapsam dışı yan not: "Series A'ya kadar rakip firma" sorusunu bu rapor yanıtlamıyor. Yan bulgular: Big Ambitions'ta rakipler sığ bulunmuş [58], ama ilk rakip saldırısı bağlamsal ders olarak işe yarıyor [2]; Plutocracy oyuncusu kilometre taşında rakip açılmasını öneriyor [99].

## Bulunamayanlar

- İlk 15 dakikanın dakika dakika dökümü yalnız Big Ambitions ve Two Point için kısmen var. Game Dev Tycoon, Cities, Democracy 4, Tropico, Frostpunk için yalnız Wikipedia ve yorum düzeyi. Software Inc için son arama ilgisiz sonuç döndürdü, yeni arama yapılmadı (bütçe).
- Big Ambitions geliştirici röportajı yok: Game*Spark röportajı okundu, öğretici ve hedef içermiyor. Geliştiricinin tasarım gerekçesi yalnız duyuru metinlerinden ve forum cevaplarından.
- Football Manager Club Vision (FM20'den beri) ve güncel hedef mekaniği: resmî sayfa 2022 tarihli ve ayrıntısız [43]; fmscout eski sürüme ait [44]; passion4fm sayfası açılmadı. Hedef kaçırma sonuçları bilinmiyor.
- Big Ambitions'ta öğreticiyi kapatmanın yan etkisi (sağlık güvencesi isteği): yalnız arama özeti, hangi başlıkta olduğu doğrulanmadı.
- Software Inc'te oyuncuya "sıradaki hedefi" gösteren bir sistem bulamadım (aramada ve yorumlarda çıkmadı); yokluğu kesin değil.
- Steam yorum örneklemi İngilizce ve yalnız en yararlı ile en yeni yorumlardan; Türkçe oyuncu ve ortadaki yorumlar yok. Football Manager 24 örneklemi "board/objective" sözcüklerinde sonuç vermedi.
- Juul'un "Without a Goal" makalesi (isteğe bağlı hedefli oyunlar) ve FDG 2011'de isteğe bağlı hedeflerin davranışa etkisi çalışması: bulundu ama makale metni okunamadı (blog duyurusu ve forum bağlantısı 403).
- Steam yorumları için sıklık ölçülemedi: API metin araması vermiyor; örnekler yalnız hangi görüşlerin var olduğunu gösterir. Reddit erişilemedi (alan adı engeli).
- Ürün yaşam döngüsünü çalışanlara devretme (Series B sonrası) ve "Plutocracy gibi lobicilik" bu raporun konusu değildi; Plutocracy'den yalnız öğretici ve hedef yorumları alındı.

## Kaynaklar

1. Big Ambitions, Steam mağaza sayfası (%91 olumlu / 6.249 İngilizce; EA 10 Mart 2023, 1.0: 28 Ağustos 2026) - https://store.steampowered.com/app/1331550/Big_Ambitions/ - 2026-10-19 okundu
2. Big Ambitions, "EA 0.9 - The Struggle" duyurusu (yeni öğretici, yan görevler, ilerleme güncellemesi) - https://steamstore-a.akamaihd.net/news/externalpost/steam_community_announcements/1811772772408660 - 2025-09-30
3. Big Ambitions, "Here comes Beta 6!" (öğretici/Fred'i atlama, Custom Game; metin "Beta 5 içeriği" diyor) - https://steamstore-a.akamaihd.net/news/externalpost/steam_community_announcements/4589754330746620444 - 2022-09-26
4. Big Ambitions, EA 0.9 Preview Build 3204 notları (Fred'in tavsiyesine uymayan oyuncu) - https://steamstore-a.akamaihd.net/news/externalpost/steam_community_announcements/1809869180066224 - 2025-09-05
5. Big Ambitions, EA 0.10 Preview Build 3456 notları (GPS yanlış mağaza) - https://steamstore-a.akamaihd.net/news/externalpost/steam_community_announcements/1826362059933232 - 2026-03-10
6. Big Ambitions, "EA 0.4 - Optimization #1" (adımlar sırasız yapılırsa yeniden yapma; "A Fresh Start") - https://steamstore-a.akamaihd.net/news/externalpost/steam_community_announcements/5397065151385990573 - 2023-12-13
7. Big Ambitions, 1.0 Build 3672/3674 notları (öğretici ucuz yatağa yönlendiriyor) - https://steamstore-a.akamaihd.net/news/externalpost/steam_community_announcements/1842212951313875 - 2026-09-01
8. Big Ambitions, Build 3680 Patch 2 notları (öğretici taşınsan bile eve yönlendirir) - https://steamstore-a.akamaihd.net/news/externalpost/steam_community_announcements/1844115010489503 - 2026-09-16
9. Big Ambitions, "EA 0.11 - The Workshop Awakens" (yan görevler: rakipler, acil kredi, Mr. Ternity) - https://steamstore-a.akamaihd.net/news/externalpost/steam_community_announcements/1835871199304726 - 2026-06-18
10. Big Ambitions, EA 0.9 Build 3233/3234 notları (görev otomatik tamamlanır; Fred'i kapatma) - https://steamstore-a.akamaihd.net/news/externalpost/steam_community_announcements/1817483467036364 - 2025-11-27
11. Big Ambitions, "Full Release is TWO WEEKS AWAY" (Fred diyaloğu, rehber parmakları) - https://steamstore-a.akamaihd.net/news/externalpost/steam_community_announcements/1840944183780461 - 2026-08-14
12. Big Ambitions Steam konusu, Fred'in görevleri zorunlu mu (geliştirici David Estes Creations cevabı) - https://steamcommunity.com/app/1331550/discussions/0/3823034639974793833 - 2026-10-19 okundu
13. Big Ambitions Steam konusu, "Achievements without Fred?" (telefonla kapatma, başarımlar) - https://steamcommunity.com/app/1331550/discussions/0/684113073641952519/ - 2026-10-19 okundu
14. Big Ambitions Steam konusu, "When to end the tutorial?" ("Your Best Friend - Gold": 90 hedef) - https://steamcommunity.com/app/1331550/discussions/0/4416425017211417294/ - 2026-10-19 okundu
15. Big Ambitions Steam konusu, "campaign/tutorial is recommended?" (geliştirici: yeni oyuncuya öneri, bilen atlasın) - https://steamcommunity.com/app/1331550/discussions/0/591759268792807370/ - 2026-10-19 okundu
16. Startup Company, Steam mağaza sayfası (%80 olumlu / 2.898 İngilizce) - https://store.steampowered.com/app/606800/Startup_Company/ - 2026-10-19 okundu
17. Startup Company, Devlog #11 (Venture Capital ve kilometre taşları) - https://steamstore-a.akamaihd.net/news/externalpost/steam_community_announcements/2361446846769839057 - 2018-02-23
18. Startup Company, Devlog #12 (danışman = "tutorial mode in disguise") - https://steamstore-a.akamaihd.net/news/externalpost/steam_community_announcements/2363699913374454372 - 2018-03-09
19. Startup Company, Beta 15 duyurusu (yatırımcı seçimi, "tutorial mode") - https://steamstore-a.akamaihd.net/news/externalpost/steam_community_announcements/2394102381817730401 - 2018-04-12
20. Startup Company, Devlog #15 (kilometre taşı ödemeleri artırıldı) - https://steamstore-a.akamaihd.net/news/externalpost/steam_community_announcements/2758894130316205468 - 2018-04-20
21. Startup Company, Devlog #21 (sıradaki kilometre taşı; yeni ürün şartı 15 kilometre taşı) - https://steamstore-a.akamaihd.net/news/externalpost/steam_community_announcements/2499943313684531196 - 2018-07-06
22. Startup Company, Beta 23 duyurusu (geç oyun kilometre taşları) - https://steamstore-a.akamaihd.net/news/externalpost/steam_community_announcements/3763229740660998180 - 2019-04-16
23. Startup Company, Beta 27 duyurusu (67 yaşında emeklilik, emeklilik fonu hedefi) - https://steamstore-a.akamaihd.net/news/externalpost/steam_community_announcements/2451574645865797519 - 2019-11-02
24. Startup Company Steam konusu, "Feedback: venture capital" (geliştirici Jonas cevabı) - https://steamcommunity.com/app/606800/discussions/0/1727575977545256862/ - 2018-06, 2026-10-19 okundu
25. Startup Company Steam konusu, "Bankrupt" (danışman Pam; "iki kontrol noktası") - https://steamcommunity.com/app/606800/discussions/0/3790380616240034578/ - 2023-03, 2026-10-19 okundu
26. Startup Company Steam konusu, "Does ownership matter?" (satın alma bedeli) - https://steamcommunity.com/app/606800/discussions/0/1741090666219816630/ - 2018, 2026-10-19 okundu
27. Software Inc, Alpha 11 final progress update (öğreticileri yeniden yazma) - https://steamstore-a.akamaihd.net/news/externalpost/steam_community_announcements/2416665403776479697 - 2019-08-24
28. Software Inc, Alpha 11.3.1 notları (öğretici basit/ileri/tam) - https://steamstore-a.akamaihd.net/news/externalpost/steam_community_announcements/2468465044723762488 - 2019-11-23
29. Software Inc, Alpha 11.4 notları ("Office dangers" öğreticisi) - https://steamstore-a.akamaihd.net/news/externalpost/steam_community_announcements/2600199781650668700 - 2020-01-12
30. Software Inc, Beta 1.8.3 notları (öğreticiye geri dönme) - https://steamstore-a.akamaihd.net/news/externalpost/steam_community_announcements/5842939267346075982 - 2024-07-07
31. Game Dev Tycoon, v1.6 notları (ipuçları "company milestones") - https://steamstore-a.akamaihd.net/news/externalpost/steam_community_announcements/2363699913371527403 - 2018-03-08
32. Wikipedia, Game Dev Tycoon - https://en.wikipedia.org/wiki/Game_Dev_Tycoon - 2026-10-19 okundu
33. Wikipedia, Two Point Hospital (hedefler, yıldızlar, danışman, eleştiri) - https://en.wikipedia.org/wiki/Two_Point_Hospital - 2026-10-19 okundu
34. The Sixth Axis, Two Point Hospital röportajı (Hymers, Huskins, Smart) - https://www.thesixthaxis.com/?p=318888 - 2026-10-19 okundu (yayın tarihi sayfada yok)
35. Two Point Hospital, R.E.M.I.X duyurusu (Hogsport "tutorial level") - https://steamstore-a.akamaihd.net/news/externalpost/steam_community_announcements/3183419193845692296 - 2020-02-18
36. ludo.guide, Two Point Hospital Hogsport yol haritası - https://www.ludo.guide/guide/two-point-hospital/level-1-hogsport - 2026-10-19 okundu
37. Wikipedia, Cities: Skylines (nüfus eşikleri, öğretici övgüsü) - https://en.wikipedia.org/wiki/Cities:_Skylines - 2026-10-19 okundu
38. Colossal Order, Cities: Skylines II Development Diary 10 - Game progression - https://colossalorder.fi/news/development-diary-10-game-progression/ - 2026-10-19 okundu
39. Wikipedia, Frostpunk (senaryolar, perdeler) - https://en.wikipedia.org/wiki/Frostpunk - 2026-10-19 okundu
40. Wikipedia, Kerbal Space Program (kariyer, sözleşmeler) - https://en.wikipedia.org/wiki/Kerbal_Space_Program - 2026-10-19 okundu
41. Wikipedia, Tropico 6 (doğrusal olmayan görevler, eleştiri) - https://en.wikipedia.org/wiki/Tropico_6 - 2026-10-19 okundu
42. Wikipedia, Democracy 4 (istem türleri, seçim sözleri) - https://en.wikipedia.org/wiki/Democracy_4 - 2026-10-19 okundu
43. Football Manager, "Supporter Confidence" (yönetim kurulu ve taraftar güveni, FM23) - https://www.footballmanager.com/features/supporter-confidence - 2022, 2026-10-19 okundu
44. FM Scout, Confidence ekranı - https://www.fmscout.com/confidence.htm - 2026-10-19 okundu (eski sürüm)
45. Nikhil Murthy, "The Anti-Pattern of Optional Goals in Tasklists", Game Developer - https://www.gamedeveloper.com/design/the-anti-pattern-of-optional-goals-in-tasklists - 2017-10-20
46. Plutocracy, Steam mağaza sayfası (%79 olumlu / 1.321) - https://store.steampowered.com/app/754500/Plutocracy/ - 2026-10-19 okundu
47. Plutocracy, "The Stock Market ..." duyurusu ("New tutorial system") - https://steamstore-a.akamaihd.net/news/externalpost/steam_community_announcements/4186652357025383275 - 2021-10-29
48. Satisfactory, Steam mağaza sayfası (%97 olumlu / 138.342) - https://store.steampowered.com/app/526870/Satisfactory/ - 2026-10-19 okundu
49. Steam yorumu, Big Ambitions, olumsuz, 50 sa - https://steamcommunity.com/profiles/76561198040736440/recommended/1331550/ - 2026-09-02
50. Steam yorumu, Big Ambitions, olumlu, 66 sa - https://steamcommunity.com/profiles/76561198882838812/recommended/1331550/ - 2026-09-12
51. Steam yorumu, Big Ambitions, olumlu, 55 sa - https://steamcommunity.com/profiles/76561198007848472/recommended/1331550/ - 2026-09-26
52. Steam yorumu, Big Ambitions, olumsuz, 34 sa - https://steamcommunity.com/profiles/76561197961937605/recommended/1331550/ - 2026-09-03
53. Steam yorumu, Big Ambitions, olumlu, 28 sa - https://steamcommunity.com/profiles/76561198043019232/recommended/1331550/ - 2026-08-29
54. Steam yorumu, Big Ambitions, olumlu, 125 sa - https://steamcommunity.com/profiles/76561197994968317/recommended/1331550/ - 2026-09-18
55. Steam yorumu, Big Ambitions, olumlu, 81 sa - https://steamcommunity.com/profiles/76561198292847622/recommended/1331550/ - 2026-09-07
56. Steam yorumu, Big Ambitions, olumlu, 38 sa - https://steamcommunity.com/profiles/76561198053744094/recommended/1331550/ - 2026-09-04
57. Steam yorumu, Big Ambitions, olumlu, 332 sa ("call your tutor") - https://steamcommunity.com/profiles/76561198105175289/recommended/1331550/ - 2026-09-09
58. Steam yorumu, Big Ambitions, olumlu, 109 sa (rakipler sığ) - https://steamcommunity.com/profiles/76561198000309714/recommended/1331550/ - 2026-07-30
59. Steam yorumu, Big Ambitions, olumsuz, 18 sa, 232 oy - https://steamcommunity.com/profiles/76561198022174402/recommended/1331550/ - 2026-09-02
60. Steam yorumu, Startup Company, olumsuz, 1 sa - https://steamcommunity.com/profiles/76561198297035006/recommended/606800/ - 2024-02-01
61. Steam yorumu, Startup Company, olumsuz, 1 sa - https://steamcommunity.com/profiles/76561198031651555/recommended/606800/ - 2025-07-11
62. Steam yorumu, Startup Company, olumlu, 196 sa - https://steamcommunity.com/profiles/76561198112977686/recommended/606800/ - 2025-03-30
63. Steam yorumu, Startup Company, olumsuz, 1,1 sa (iade) - https://steamcommunity.com/profiles/76561197969380116/recommended/606800/ - 2026-10-07
64. Steam yorumu, Startup Company, olumsuz, 1 sa, 13 oy - https://steamcommunity.com/profiles/76561198867854647/recommended/606800/ - 2026-03-30
65. Steam yorumu, Startup Company, olumsuz, 20 sa - https://steamcommunity.com/profiles/76561198417497190/recommended/606800/ - 2024-09-22
66. Steam yorumu, Software Inc, olumsuz, 24 sa - https://steamcommunity.com/profiles/76561198085748198/recommended/362620/ - 2026-05-02
67. Steam yorumu, Software Inc, olumsuz, 3 sa - https://steamcommunity.com/profiles/76561198010655337/recommended/362620/ - 2026-08-16
68. Steam yorumu, Software Inc, olumlu, 125 sa - https://steamcommunity.com/profiles/76561198092479195/recommended/362620/ - 2026-06-18
69. Steam yorumu, Software Inc, olumsuz, 9 sa - https://steamcommunity.com/profiles/76561199871946952/recommended/362620/ - 2026-03-29
70. Steam yorumu, Game Dev Tycoon, olumlu, 0 sa - https://steamcommunity.com/profiles/76561198749446079/recommended/239820/ - 2026-10-03
71. Steam yorumu, Two Point Hospital, olumsuz, 200 sa, 21 oy - https://steamcommunity.com/profiles/76561198012513286/recommended/535930/ - 2026-04-02
72. Steam yorumu, Two Point Hospital, olumlu, 80 sa - https://steamcommunity.com/profiles/76561198255268920/recommended/535930/ - 2026-08-20
73. Steam yorumu, Two Point Hospital, olumlu, 182 sa - https://steamcommunity.com/profiles/76561198058172406/recommended/535930/ - 2026-06-28
74. Steam yorumu, Project Hospital, olumsuz, 18 sa - https://steamcommunity.com/profiles/76561198325208300/recommended/868360/ - 2026-02-10
75. Steam yorumu, Project Hospital, olumsuz, 1 sa - https://steamcommunity.com/profiles/76561198047416976/recommended/868360/ - 2026-08-23
76. Steam yorumu, Project Hospital, olumsuz, 11 sa, 14 oy - https://steamcommunity.com/profiles/76561198295417869/recommended/868360/ - 2026-05-25
77. Steam yorumu, Project Hospital, olumlu, 36 sa - https://steamcommunity.com/profiles/76561198006188124/recommended/868360/ - 2026-09-27
78. Steam yorumu, Project Hospital, olumlu, 179 sa - https://steamcommunity.com/profiles/76561199509350930/recommended/868360/ - 2026-04-23
79. Steam yorumu, Frostpunk, olumsuz, 0 sa - https://steamcommunity.com/profiles/76561198116930297/recommended/323190/ - 2026-09-22
80. Steam yorumu, Frostpunk, olumsuz, 0 sa - https://steamcommunity.com/profiles/76561197989999855/recommended/323190/ - 2026-09-22
81. Steam yorumu, Frostpunk, olumsuz, 10 sa, 17 oy - https://steamcommunity.com/profiles/76561198027259399/recommended/323190/ - 2026-07-30
82. Steam yorumu, Frostpunk, olumsuz, 11 sa - https://steamcommunity.com/profiles/76561199247534659/recommended/323190/ - 2026-09-24
83. Steam yorumu, Cities: Skylines, olumsuz, 0 sa - https://steamcommunity.com/profiles/76561198239220770/recommended/255710/ - 2026-09-01
84. Steam yorumu, Cities: Skylines II, olumlu, 76 sa - https://steamcommunity.com/profiles/76561198298269873/recommended/949230/ - 2026-08-14
85. Steam yorumu, Satisfactory, olumlu, 129 sa - https://steamcommunity.com/profiles/76561198279868438/recommended/526870/ - 2026-09-21
86. Steam yorumu, Satisfactory, olumsuz, 86 sa - https://steamcommunity.com/profiles/76561198099001888/recommended/526870/ - 2026-10-03
87. Steam yorumu, Satisfactory, olumlu, 1008 sa - https://steamcommunity.com/profiles/76561198100333150/recommended/526870/ - 2026-09-28
88. Steam yorumu, Satisfactory, olumlu, 158 sa - https://steamcommunity.com/profiles/76561198025783534/recommended/526870/ - 2026-09-21
89. Steam yorumu, Kerbal Space Program, olumsuz, 0 sa - https://steamcommunity.com/profiles/76561199040972881/recommended/220200/ - 2026-10-01
90. Steam yorumu, Kerbal Space Program, olumlu, 6 sa - https://steamcommunity.com/profiles/76561198095027549/recommended/220200/ - 2026-10-04
91. Steam yorumu, Tropico 6, olumlu, 395 sa - https://steamcommunity.com/profiles/76561197975309551/recommended/492720/ - 2026-06-24
92. Steam yorumu, Tropico 6, olumsuz, 13 sa - https://steamcommunity.com/profiles/76561198974053526/recommended/492720/ - 2026-08-30
93. Steam yorumu, Democracy 4, olumsuz, 3 sa - https://steamcommunity.com/profiles/76561198128017328/recommended/1410710/ - 2025-10-21
94. Steam yorumu, Democracy 4, olumsuz, 3 sa - https://steamcommunity.com/profiles/76561197977747224/recommended/1410710/ - 2026-04-05
95. Steam yorumu, Mad Games Tycoon 2, olumsuz, 17 sa, 21 oy - https://steamcommunity.com/profiles/76561199302902979/recommended/1342330/ - 2026-02-25
96. Steam yorumu, Oxygen Not Included, olumlu, 84 sa - https://steamcommunity.com/profiles/76561198402415385/recommended/457140/ - 2026-09-20
97. Steam yorumu, Plutocracy, olumsuz, 13 sa - https://steamcommunity.com/profiles/76561198053521425/recommended/754500/ - 2024-09-29
98. Steam yorumu, Plutocracy, olumsuz, 26 sa, 45 oy - https://steamcommunity.com/profiles/76561198124942118/recommended/754500/ - 2024-01-19
99. Steam yorumu, Plutocracy, olumsuz, 100 sa - https://steamcommunity.com/profiles/76561198065854752/recommended/754500/ - 2023-12-26
100. Steam yorumu, Plutocracy, olumlu, 30 sa - https://steamcommunity.com/profiles/76561198093350925/recommended/754500/ - 2025-09-12
101. Steam yorumu, Football Manager 26, olumsuz, 302 sa - https://steamcommunity.com/profiles/76561197961922479/recommended/3551340/ - 2026-09-14
102. Steam Reviews API (yorum örnekleme yöntemi; örnek çağrı) - https://store.steampowered.com/appreviews/1331550?json=1&language=english&filter=all - 2026-10-19
103. Steam duyuru API'si (ISteamNews, geliştirici duyuruları) - https://api.steampowered.com/ISteamNews/GetNewsForApp/v2/?appid=1331550 - 2026-10-19
104. Steam yorumu, Tropico 6, olumsuz, 34 sa ("Tilt Camera") - https://steamcommunity.com/profiles/76561198352076865/recommended/492720/ - 2026-07-21
105. Steam yorumu, Startup Company, olumsuz, 4 sa ("extended tutorial") - https://steamcommunity.com/profiles/76561198083472159/recommended/606800/ - 2026-06-23
106. Steam yorumu, Oxygen Not Included, olumsuz, 29 sa - https://steamcommunity.com/profiles/76561198241478302/recommended/457140/ - 2026-10-17
107. Steam yorumu, Two Point Hospital, olumsuz, 7 sa ("very simple to achieve") - https://steamcommunity.com/profiles/76561198023625437/recommended/535930/ - 2026-04-14
108. Startup Company, Devlog #25 (yatırımcı kilometre taşları toplam 20) - https://steamstore-a.akamaihd.net/news/externalpost/steam_community_announcements/2444779293765288700 - 2018-08-17
109. Steam yorumu, Software Inc, olumlu, 60 sa (geç oyun iyileştirme) - https://steamcommunity.com/profiles/76561197988204300/recommended/362620/ - 2026-09-27
