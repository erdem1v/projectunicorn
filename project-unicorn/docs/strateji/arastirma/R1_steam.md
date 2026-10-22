# Steam mağaza sayfası, demo ve yapay zekâ beyanı kuralları (R1, 2026-10-19)

Arama sayısı: 16 (bütçe 18; arama aracı çalıştı). Ek olarak 30 kadar WebFetch yapıldı; Steamworks sayfalarının çoğu doğrudan okundu.

Okuma notu: Arama aracı sonuçları özetleyerek döndürüyor. Doğrudan açıp okuduğum sayfalar "birincil" ya da "okundu" diye geçer. Yalnız arama özetinden gelen bilgiyi "(arama özeti, açılamadı)" diye işaretledim. Model bilgisinden yazdığım satır yoktur; bulunamayanlar en altta.

## Kısa cevaplar

1. Mağaza sayfası önce Valve incelemesine gider (genelde 3-5 iş günü; en az 7 gün önceden gönder). Onaydan sonra "Post as Coming Soon" düğmesine sen basarsın, yani sayfa onaylı hâlde bekletilebilir. Steam Direct ücreti oyun başına 100 USD, 1.000 USD brüt gelirden sonra geri ödenir. [1][2][4][5]
2. Onaydan sonra sayfayı kendin "Publish" sekmesiyle serbestçe güncellersin; Valve aynı oyunu yeniden incelemez. İstisna: oyun adı kilitlenir, yalnız destek talebiyle (ya da Profile Features açıksa) değişir. Diğer alanlarda alan alan açık bir "yeniden inceleme ister" listesi bulamadım. [2][6][7]
3. Ekran görüntüleri yalnız oyun içi görüntü olmalı (konsept çizim, ön-render sinematik yasak). Kapsülde oyun adı dışında yazı, ödül, yorum alıntısı yok. Fragman için sert bir "oyun içi yüzdesi" kuralı yok, ama ilk fragmanın ağırlıkla oyun içi olması tavsiye. Görsellerin "güncel" olması ayrı bir kural değil; inceleme "yalnız çıkışta mevcut özellikler" şartını arar. [2][8][9][11]
4. Çıkıştan önce Coming Soon sayfası en az 2 hafta açık kalmalı. Çıkış tarihini değiştirme sayısına üst sınır yazmıyor; tarih çıkıştan 2 hafta önce kilitlenir. [1][3][12]
5. Ocak 2024 kuralı: beyan formu, "önceden üretilmiş" ve "canlı üretilen" yapay zekâ içeriği ayırır; Valve beyanın büyük kısmını mağaza sayfasında gösterir. Ocak 2026 yeniden yazımı: kod yardımcıları gibi iş akışı araçları beyan dışı; oyunda, mağaza sayfasında ve pazarlama materyalinde çıkan üretken yapay zekâ çıktısı beyana girer. [13][14][15]
6. Demo ayrı bir uygulamadır (ayrı App ID), isteğe bağlı kendi mağaza sayfası ve ayrı yorumları olur, güncellenebilir ve devre dışı bırakılabilir. Next Fest: oyun başına yalnız bir kez, canlı demo şart, sayfa herkese açık olmalı. Şubat 2027: 22 Şubat-1 Mart, kayıt 10 Ocak 2027'de kapanır. [17][18][19][20]
7. Erken Erişim: oynanabilir olmalı, geliştirme bitmişse girilmez, gelecek için kesin söz verilmez, soruların hepsi cevaplanır. Çıkınca Coming Soon'a ya da Erken Erişim'e geri dönülmez. [16]
8. Sayfa açıldıktan sonra kapsül, ad ve etiket değiştirip sonucu yazan az sayıda örnek buldum, hepsi tek vaka. Kingdom Workshop (kapsül+ad+etiket, günlük wishlist 5'ten 20'ye) ve Son of a Witch (ad+anahtar görsel, satış %306 arttı) başarılı örnekler. Köklü sanat dili değişikliğinin rakamlı örneğini bulamadım. [24][26]

## Bulgular

### 1. Mağaza sayfası süreci

- Adımlar: belgeleri imzala, uygulama ücretini öde, banka-vergi-kimlik doğrulamasını bitir, sonra mağaza sayfasını kur. Vergi doğrulaması 30 güne kadar sürebilir. [4]
- Ücret: "$100 USD (or equivalent) fee for each product" [4]. Geri ödeme: brüt gelir 1.000 USD'ye ulaşınca sonraki ödemede geri verilir; ücret iade edilmez. [5]
- İlk inceleme: Valve mağaza sayfasını ve ürün sürümünü ayrı ayrı inceler. Mağaza sayfası tipik 3-5 iş günü; en az 7 gün önceden gönder. Önce sayfa gönderilir, sonra build. [2][12]
- Onboarding sayfası inceleme için "1-5 gün" yazıyor ve ilk birkaç oyun için ücretten sonra 21 günlük bekleme ile en az iki haftalık Coming Soon istiyor. [4] Release Process sayfası 21 günü anmıyor. [12] Çelişki var; hesabın yeni olduğu için 21 gün geçerli olabilir. (Görüş: Steamworks hesabı sende açıkken kendi panelinde görüne bak.)
- Sayfa kontrolleri: yalnız çıkışta mevcut özellikler, okunur ad/logo, yalnız oyun içi ekran görüntüsü, sağlam açıklama, başka sitelere bağlantı yok. [2]
- Coming Soon'a geçiş: inceleme onayından sonra yeşil "Post as Coming Soon" düğmesi. Bu, Topluluk Merkezi'ni ve wishlist'i açar. [1]
- Bekletme: Coming Soon'u kendin yayınlarsın; onaylı sayfa kendiliğinden yayına girmez. Yayın da düğmeyle: "Approved titles will not release themselves." [1][12] Mağaza sayfasında "Save" yalnız taslak kaydeder, "Publish" yayına alır. [6]
- Valve'in kendi tavsiyesi: "Wait until your art direction and core features are fairly settled", çünkü büyük değişiklikler erken wishlist'çileri şaşırtır (özet; sayfadan kısaltılmıştır). [1]

### 2. Sayfa yayına girdikten sonra ne değişir (tablo)

Not: Valve belgeleri alan alan bir "yeniden inceleme" listesi vermiyor. Review Process sayfası: onaydan sonra oyun yeniden incelemeye girmez, serbestçe güncellenir; hangi değişiklik istisna olduğu listelenmemiş. [2] Aşağıdaki tablo okuduğum sayfaların söylediğidir; söylemeyen hücreyi "belge yok" diye bıraktım.

| Alan | Durum | Kaynak |
|---|---|---|
| Oyun adı | İncelemeden sonra kilitli. Destek talebiyle ya da Profile Features açıksa değişir. Yerelleştirilmiş ad da aynı kuralda. | [7][22] |
| Kapsül görselleri (header, small, main, vertical) | Kendin değiştirirsin (Publish). Kurallara uymayan kapsülün görünürlüğü sınırlanabilir. Yeniden inceleme gerektiğine dair belge yok. | [6][8][9] |
| Kütüphane görselleri (capsule, hero, logo, header) | Yalnız yayınlanmış mağaza sayfası olan uygulamalarda görünür. Sonradan değiştirme adımı sayfada yok. Geçici kapsül için "Artwork Override" var (yalnız yeni içerik, süreli, otomatik geri döner). | [10][23] |
| Ekran görüntüleri | Kendin değiştirirsin. En az 5 gerekli, 1920x1080, oyun içi. | [8] |
| Fragmanlar | Kendin yüklersin. Çıkış, fragman dönüştürülürken yapılamaz. | [11] |
| Kısa/uzun açıklama | Kendin güncellersin. Başka sitelere bağlantı yasak. | [2] |
| Etiketler | Tag Wizard ile "at any time". Çıkıştan önce en az 5, en çok 20 görünür. | [21] |
| Tür | Tag Wizard içinde seçilir; ayrı bir kısıt yazmıyor. | [21] |
| Desteklenen diller | Belge yok (inceleme/serbestlik yazmıyor). Yeni dil sonradan güncellemeyle eklenebilir. | [22] |
| Sistem gereksinimleri | Belge yok. Build, listelenen işletim sistemlerinde açılmak zorunda. | [2] |
| Çıkış tarihi | Kendin değiştirirsin; çıkıştan 2 hafta önce kilitlenir. Gösterim: tam tarih, ay-yıl, çeyrek, yıl ya da tarihsiz "Coming Soon". Dahili tam tarih zorunlu. | [3] |
| "Coming soon" metni | Tarihsiz gösterim seçeneği; ayrıca düzenleme kuralı yok. | [3] |
| Fiyat | Belge yok. Erken Erişim'de sürekli indirim yasak, zam sonrası 30 gün indirim yok. | [16] |
| Erken Erişim soruları | Cevaplanması zorunlu; sonradan değişiklik kuralı bu sayfada yok. | [2][16] |
| YZ beyanı formu | Onaydan sonra bazı sorular destek olmadan düzenlenemez; değişiklik özetini destek ile paylaşman gerekir. | [13] |

### 3. Ekran görüntüsü, fragman, kapsül

- Ekran görüntüsü: oyun görüntüsü; konsept çizim, ön-render sinematik, ödül ve pazarlama yazısı olan görsel yok. Menü ekranı yalnız oyunun benzersiz parçasıysa olur. [8] En az 4 tanesini "tüm yaşlara uygun" işaretle. [8]
- Kapsül: yalnız oyun sanatı, oyun adı ve resmî alt başlık. Yorum puanı, ödül, indirim yazısı, "Wishlist now" gibi çağrı, başka ürün tanıtımı yasak. "Do not include quotes or other strings of text beyond the title of your game." [8][9]
- Kütüphane hero görseli: hiç yazı yok. Logo: şeffaf zemin üzerinde yalnız logotype. [9][10]
- Kurallar 1 Eylül 2022'den beri geçerli; uymayanın mağaza görünürlüğü sınırlanabilir, öne çıkarma dışı kalabilir. [9]
- Fragman: Valve ilk fragmanın "primarily gameplay" olmasını önerir, ama yüzde ya da süre kuralı yok. Teknik: en çok 1920x1080, en az 5.000 Kbps. [11]
- Görüntüler güncel hâli göstermezse: inceleme listesi "Only features and content available at launch" ister; bitmemiş ekran görüntüsü ve fragman kaldırılmalı, açıklamadaki gelecek planı "henüz yayınlanmadı" diye yazılmalı. [2] "Güncel olmayan sanat" için ayrı yaptırım yazısı bulmadım.
- Görüş: Zukowski'nin özetinde, son oyun gelince gerçek olacaksa ekran görüntüsü ve fragmanda maket kullanmak kabul edilebilir diye geçiyor. [25] Bu, Valve'in "yalnız oyun içi" kuralıyla gerilim taşır; Valve'in metni önceliklidir.

### 4. Coming Soon süresi ve tarih

- "For new products, you must have a Coming Soon page up for at least two weeks before releasing." [1] Release Process: onaydan sonra "at least 2 weeks". [12]
- Tarih: kendi çıkış tarihini sınırsız kez değiştirebilirsin ama çıkıştan 2 hafta önce kilitlenir; bu pencerede oyun "upcoming releases" listelerinde daha çok görünür. [3]
- Hafta sonu çıkış mümkün ama önerilmez (destek yok). [3]
- Çıkış ancak sen "Release" düğmesine basınca olur. [12]

### 5. Yapay zekâ beyanı

- Ocak 2024 (PCGamesN, 10 Ocak 2024): beyan bölümü zorunlu; Valve "include much of your disclosure on the Steam store page". Oyuncular overlay'den üretken yapay zekâ içeriğini raporlayabilir. [15] Valve'in kendi duyurusu "AI Content on Steam" Steamworks'te var; gövdesini açamadım. [33 arama özeti]
- İçerik anketi tanımı: önceden üretilmiş içerik, oyunla gelip oyuncunun tükettiği her türlü yapay zekâ destekli içeriktir (sanat, ses, anlatı, yerelleştirme); canlı üretilen içerik oyun çalışırken üretilendir ve ek olarak "guardrails" tarifi ister. Yetişkin cinsel içerikli canlı üretim şu an istenmiyor. [13]
- Önceden üretilen içerik, yapay zekâ olmayan içerikle aynı incelemeden geçer (yasallık, pazarlamayla uyum). [13]
- Ocak 2026 yeniden yazımı (Game Developer, 16 Ocak 2026): iş akışı için yapay zekâ araçları (kod yardımcıları) beyan gerektirmez; oyunda ve ilgili materyalde (pazarlama, mağaza sayfası) çıkan üretken yapay zekâ içeriği ile oyun sırasında üretilen içerik beyan edilir. Araçları anlatan bir metin kutusu ve oyun içi üretim için bir kutucuk var. [14]
- Mağaza sayfasında nasıl görünür: 2024'te Valve "büyük kısmı" göstereceğini söyledi [15]; 2026 yeniden yazımının görünümünü kaynak anlatmıyor. [14]
- Kod yardımcıları: Steamworks anket sayfası "Efficiency gains ... is not the focus of this section" der (özet) [13]; Game Developer haberi kod yardımcılarını açıkça beyan dışı sayar. [14]

### 6. Demo ve Next Fest

- Demo ayrı App ID'dir, "Demo" tipinde ve temel oyunun ID'sine bağlanır. Kendi mağaza sayfası isteğe bağlı: yalnız demo içeriği, fragman ve en az 5 demo ekran görüntüsü. Demonun topluluk merkezi yok. [17]
- Demo sayfası varsa oyuncular demoya yorum yazabilir. [17] İkincil kaynağa göre demo yorumları tam oyundan ayrı puanlanır ve kötü demo kalıcı iz bırakır. [27]
- Wishlist bildirimi: demo ilk oynanabilir olunca ilk 2 hafta içinde bir bildirim; aynı uygulama için 2 hafta bekleme. [17]
- Güncelleme: demonun kendi App ID'sine build yüklenir. Kaldırma: "Deactivate Demo" (sahipler görür ama başlatamaz); temel sayfadaki demo düğmesi "Associated Demos"tan silinerek kalkar. [17]
- Next Fest kuralları: yalnız bir Next Fest ("ONE"), hesap iyi durumda, temel oyun sayfası herkese açık, oyun bir önsöz/kısa sürüm olmayacak, fest başlarken herkese açık oynanabilir demo canlı, oyun fest bitiminden sonra çıkacak. Kayıt oyundan yapılır, demodan değil. [18]
- Ekim 2026: 19-26 Ekim, kayıt 31 Ağustos 2026'da bitti. [19]
- Şubat 2027: 22 Şubat 10:00 PST - 1 Mart 10:00 PST. Kayıt 10 Ocak 2027 23:59 PST. Demo+sayfa incelemesi Basın Önizlemesi için 25 Ocak; tüm öğeler 8 Şubat; Press Preview 11 Şubat. [20]
- Haziran 2027: 14-21 Haziran (arama özeti, açılamadı; Valve sayfasını bulamadım). [29]
- Haziran 2027 ve sonrasının resmî sayfası: Şubat sayfası "next edition is in June 2027" der. [20]
- İkincil veri (Zukowski anketi, 182 oyun, kendi bildirimli): fest öncesi wishlist ile fest kazancı r=0,825; demosu fest'ten aylar önce canlı olanlar medyan wishlist'te yaklaşık 2,5 kat. Medyan fest kazancı 800-1.100 wishlist. Tek ihtiyat: demo çok kısa/uzun ya da çıkışa 6-8 hafta kala çıkmışsa zarar verebilir. [27]
- Başarısız örnek: Bramble Royale (Mart 2025 çıkış) Eylül 2024'te demo çıkardı, Next Fest'te yalnız ~800 wishlist aldı; çıkış öncesi 4.117 wishlist, ilk hafta 703 adet. Neden: "The game lacked a marketable hook", tür yorgunluğu, ilk bakışta öğrenmesi zor görünüm. Yazı kapsül ya da sanatı sorun saymıyor. [28]

### 7. Erken Erişim

- Oynanabilir olmalı; en az gameplay fragmanı. "Don't launch in Early Access if you are finished with development." [16]
- Soru formu: neden Erken Erişim, tahmini süre, tam sürümden farkı, bugün ne alınır, fiyat, topluluk katılımı. [16]
- Gelecek için kesin tarih/özellik sözü verilmez; çapraz satışta fiyat Steam'den yüksek olamaz; kalıcı indirim yok; zamdan sonra 30 gün indirim yok. [16]
- Çıkış: build yükle, "View Release Options" ile Release. Bir kez çıkınca Coming Soon'a ya da Erken Erişim'e geri dönülmez. 1.0'a varılmadan çıkılırsa Valve oyunu etiketsiz tutabilir, kalıcı. [16]
- İkincil (Zukowski, VG Insights verisi, arama özeti, açılamadı): yalnız normal çıkışlı oyunların medyan geliri 613 USD, EA'den 1.0'a varanların 2.874 USD (ortalamalar 360.000 ve 523.000 USD); 1.0 ikinci bir çıkış sağlar. [30]
- Başarısız örnek (arama özeti, açılamadı): Extraneum gelirinin çoğunu Erken Erişim'de yaptı, 1.0'da neredeyse kimse almadı. [31]

### 8. Sayfa açıldıktan sonra ad, kapsül ya da sanat dili değiştiren örnekler

- Kingdom Workshop (eski Dwarven Valley), Ekim 2020: ekran görüntülü kapsül yerine çizim cüce portresi, ad değişikliği, etiket düzeni, kapsülde "ADD TO WISHLIST". Günlük wishlist yaklaşık 5'ten 20'ye, başka tanıtım yok; trafik Discovery Queue'dan. Etiketleme sihirbazı sonrası istenmeyen etiketler (Indie, Action...) geri geldi ve wishlist düştü; destek talebi ile çözüldü. Tür çok popüler olduğu için sonuç her türde tekrarlanmayabilir. [24]
- Son of a Witch (eski My Mom is a Witch), ad 3 Temmuz 2017 (Erken Erişim'de): yeni ad + yeniden çerçevelenmiş anahtar görsel; yazara göre satış %306 arttı, 9 ay sonra da korundu. Bedel: eski adla yapılmış YouTube videoları yüzünden oyun YouTube aramasında neredeyse kayboldu; yalnız bir içerik üreticisi başlığı güncelledi. Mutlak sayı yok. [26]
- Ministry of Order (eski Diapers, Please!): Papers, Please benzerliğinden kaçınmak için yeniden adlandırdı ve yeni adla onay aldı; geliştirici wishlist istedi (arama özeti, açılamadı). [31]
- Citadelum önsözü (arama özeti, açılamadı): sayfa Valve yardımıyla demoya çevrilince önsöz wishlist'leri ana oyuna aktarılamadı. [31] Sayfa yapısı değişince wishlist'in kaybolabileceğine işaret ediyor; Valve belgesinde doğrulamadım.
- Zukowski (aktaran özet): sanat stilini ve türü sayfadan önce sabitle. Türde ani sapma (soulslike'tan hikâye macerasına) wishlist kaybettirir. "wishlists really don't age" diyor. [25]
- Kanıt eksiği: sayfa açıkken köklü sanat dili değiştiren bir oyunun rakamlı öncesi/sonrası verisini bulamadım. Bulunan örnekler küçük çaplı (kapsül, ad, anahtar görsel) ve tek vakalı.

## Bize dersler

Bunların hepsi Görüş:

- Görüş: Erdem yazı tipi ve arayüzü hâlâ zayıf buluyor. Valve'in kendi yönergesi "sanat yönü ve çekirdek özellikler oturana kadar bekle" der [1]; Zukowski da stili sayfadan önce sabitlemeyi söyler [25]. Sayfa Coming Soon'a girmeden hazırlanıp onaya gönderilebilir ve basılmadan bekletilebilir [1][6]. Yani "Steam sayfası olmadığı için acele et" baskısı Valve tarafında yok.
- Görüş: Sayfanın açılması gereken tek sert tarih Next Fest takvimi. Şubat 2027 fest'i için sayfa 10 Ocak 2027'den önce herkese açık olmalı, demo ve sayfa 25 Ocak'a kadar incelemeye girmeli [20]. Bu tarihleri kaçırırsak Haziran 2027 var, ama oyun başına yalnız bir Next Fest hakkı var [18]. Hangisini harcayacağımız bir strateji kararı.
- Görüş: Oyun adı sayfa incelendikten sonra kilitli [7]. Mevcut ad "Project Unicorn" ise, sayfayı göndermeden önce adı ve Steam aramasındaki çakışmaları bitirmek gerekir. Aksi hâlde destek talebi ya da Profile Features gerekir.
- Görüş: Kapsül ve logo: kapsülde yalnız ad olabilir [8]. Mevcut kapsülü okunur logo ve oyun içi sanatla küçük boyutta test et. Kingdom Workshop örneği kapsülün tek başına wishlist hızını değiştirebildiğini gösteriyor (tek vaka) [24].
- Görüş: Ekran görüntüleri oyun içi olmalı [8]. İzometrik ofis ve karar kâğıdı ekranları (EU4/CK3 dili) arayüz ağır görüntüdür; "menü yalnız benzersizse" sınırına dikkat. Arayüz değişecekse en az 5 ekran görüntüsü sayfa kurulmadan önce yeni arayüzle alınmalı. Sayfa yayınlandıktan sonra görüntü değiştirmek yasak değil [2].
- Görüş: Yapay zekâ beyanı bize uygulanır. Kod yazımı beyan dışı [14], ama oyuncunun okuduğu Türkçe/İngilizce olay metinleri, Frank'in sözleri, kâğıtlar ve yerelleştirme Claude ajanlarınca yazılıyorsa bunlar "oyunla gelip oyuncunun tükettiği yapay zekâ içeriği"dir [13]. Mağaza sayfası metni de aynı şekilde [14]. Quaternius CC0 paketi yapay zekâ değildir. Beyanı dürüst yap; form onaydan sonra düzenlenmeyi destek ister [13].
- Görüş: Demo ayrı uygulama, kendi yorumları var [17]. Kötü demo kalıcı iz bırakır [27]. Erdem'in "slop çıkmasın" kaygısı burada doğrudan geçerli: demoyu sayfa ve Next Fest'ten aylar önce, kapalı oyun testinden geçirerek çıkarmak. İkincil veri erken demoyu destekliyor [27].
- Görüş: Başarısızlık örnekleri hep cilanın değil "pazarlanabilir kanca" ve tür yorgunluğunun yetmemesinden geliyor (Bramble Royale) [28]. Cila gerekli ama yeterli değil. Yönetim/tycoon türünde referanslar (Software Inc. vb.) için ayrı bir kanca araştırması gerekir, bu raporun kapsamı dışında.
- Görüş: Erken Erişim ile demo+tam sürüm arasındaki karar kapsamı belirler. EA'ya girişte "geliştirme bitmedi" şartı ve sonradan geri dönülemezlik var [16]; ikinci bir çıkış avantajı ikincil kaynakta var [30]. Demo önce, EA ya da tam sürüm sonra planı Valve kurallarına uyuyor.

## Bulunamayanlar

- Alan alan "yeniden inceleme ister" listesi: Valve belgelerinde yok; yalnız "onaydan sonra yeniden incelenmez, serbestçe güncellenir" yazıyor [2]. Kapsül, dil, sistem gereksinimi, fiyat ve Erken Erişim sorularında sonradan değişiklik için belge bulunamadı. Kesin cevap için Valve desteğine sorulmalı.
- 21 günlük bekleme (ilk oyunlar için) yalnız onboarding sayfasında [4]; Release Process'te yok [12]. Hesabımıza uygulanıp uygulanmadığı belirsiz.
- Fragmanda "güncel oyunu göstermeli" kuralı: Trailer sayfasında yok [11].
- Valve'in Ocak 2024 "AI Content on Steam" duyurusunun tam metni açılamadı; 2024 bilgisi PCGamesN ve arama özetlerinden. Ocak 2026 yeniden yazımının Valve'in kendi sayfası da açılamadı; Game Developer haberine dayanıyor. 2025 içinde başka bir güncelleme aradım, bulamadım.
- Beyanın mağaza sayfasında tam nasıl göründüğü (etiket, metin yeri) hiçbir okuduğum kaynakta yok.
- Haziran 2027 Next Fest tarihlerinin Valve kaynağı (yalnız arama özeti).
- Wishlist'in ad/uygulama değişiminde ne olduğuna dair Valve belgesi.
- Sayfa açıkken köklü sanat dili değişiminin rakamlı vakası ve başarısız bir sanat değişimi örneği. Kapsül/isim değişiminde de olumsuz sonuçlu bir örnek bulamadım; bulduklarım başarı yanlısı (hayatta kalan yanılgısı riski).
- Tycoon/yönetim türünde başarısız Steam çıkışı postmortem'i; bu soruyu ayrı bir araştırmaya bırakıyorum.

## Kaynaklar

1. Steamworks, Coming Soon. https://partner.steamgames.com/doc/store/coming_soon (okundu 2026-10-19; tarih yok)
2. Steamworks, Review Process. https://partner.steamgames.com/doc/store/review_process (okundu 2026-10-19)
3. Steamworks, Release Dates. https://partner.steamgames.com/doc/store/release_dates (okundu 2026-10-19)
4. Steamworks, Onboarding. https://partner.steamgames.com/doc/gettingstarted/onboarding (okundu 2026-10-19)
5. Steamworks, Steam Direct Fee. https://partner.steamgames.com/doc/gettingstarted/appfee (okundu 2026-10-19)
6. Steamworks, Store Page, Building and Editing. https://partner.steamgames.com/doc/store/page ve https://partner.steamgames.com/doc/store/editing (okundu 2026-10-19)
7. Steamworks, Changing Your Game's Name. https://partner.steamgames.com/doc/store/editing/name (okundu 2026-10-19)
8. Steamworks, Store Graphical Assets. https://partner.steamgames.com/doc/store/assets/standard (okundu 2026-10-19)
9. Steamworks, Graphical Asset Rules. https://partner.steamgames.com/doc/store/assets/rules (kurallar 1 Eylül 2022'den; okundu 2026-10-19)
10. Steamworks, Library Assets. https://partner.steamgames.com/doc/store/assets/libraryassets (okundu 2026-10-19)
11. Steamworks, Trailers. https://partner.steamgames.com/doc/store/trailer (okundu 2026-10-19)
12. Steamworks, Release Process. https://partner.steamgames.com/doc/store/releasing (okundu 2026-10-19)
13. Steamworks, Content Survey (Generative AI). https://partner.steamgames.com/doc/gettingstarted/contentsurvey (okundu 2026-10-19; sayfada tarih yok)
14. Game Developer, "Valve tweaks and clarifies AI disclosure rules for Steam", 16 Ocak 2026. https://gamedeveloper.com/business/valve-tweaks-and-clarifies-ai-disclosure-rules-for-steam
15. PCGamesN, Steam AI içerik raporlama/beyan, 10 Ocak 2024. https://www.pcgamesn.com/steam/ai-content-reporting
16. Steamworks, Early Access. https://partner.steamgames.com/doc/store/earlyaccess (okundu 2026-10-19)
17. Steamworks, Demos. https://partner.steamgames.com/doc/store/application/demos (okundu 2026-10-19)
18. Steamworks, Steam Next Fest. https://partner.steamgames.com/doc/marketing/upcoming_events/nextfest (okundu 2026-10-19)
19. Steamworks, Next Fest Ekim 2026. https://partner.steamgames.com/doc/marketing/upcoming_events/nextfest/2026october (okundu 2026-10-19)
20. Steamworks, Next Fest Şubat 2027. https://partner.steamgames.com/doc/marketing/upcoming_events/nextfest/feb_2027 (okundu 2026-10-19)
21. Steamworks, Tags. https://partner.steamgames.com/doc/store/tags (okundu 2026-10-19)
22. Steamworks, Localization. https://partner.steamgames.com/doc/store/localization (okundu 2026-10-19)
23. Steamworks, Artwork Overrides. https://partner.steamgames.com/doc/store/assets/overrides (okundu 2026-10-19)
24. Chris Zukowski, "How to drastically increase your game's daily wishlist rate", 21 Aralık 2020. https://howtomarketagame.com/2020/12/21/how-to-increase-your-games-daily-wishlist-rate/
25. WN Hub, Zukowski: Steam sayfası açmadan önce yapılacaklar (özet, tarih sayfada yok). https://wnhub.io/news/stores-and-publishing/item-47311
26. Game Developer, "How changing my game image tripled the sales", 26 Nisan 2018 (Son of a Witch). https://gamedeveloper.com/business/how-changing-my-game-image-tripled-the-sales
27. Steam Page Analyzer, "Do Steam demos increase sales?" (Zukowski verisini aktarır; 2026). https://www.steampageanalyzer.com/blog/do-steam-demos-increase-sales
28. GameDiscoverCo, "Why did this excellent roguelike deckbuilder fail to scale?" (Bramble Royale, 2025). https://newsletter.gamediscover.co/p/why-did-this-excellent-roguelike
29. PC Gamer / Notebookcheck, 2027 ilk yarı Steam etkinlik takvimi (arama özeti, sayfa açılamadı; Temmuz 2026). https://www.pcgamer.com/games/steam-reveals-all-the-sale-dates-and-themed-events-for-the-first-half-of-2027/
30. WN Hub, Zukowski Erken Erişim analizi (arama özeti, açılamadı). https://wnhub.io/news/other/item-41362
31. Arama özetleri (açılamadı): Ministry of Order devlog https://voltekplay.itch.io/diapers-please/devlog/901651/big-news-our-steam-page-is-now-live ; Citadelum tartışması (Reddit, Mart 2026) https://reddit.sentinel-team.org/posts/1rp216y/snapshots/2026-03-10T21%3A13%3A46.25562Z ; Extraneum https://davidjalbert.itch.io/extraneum/devlog/1090186/extraneum-post-mortem-one-year-later
33. Valve, "AI Content on Steam" duyurusu (gövde açılamadı). https://steamcommunity.com/groups/steamworks/announcements/detail/3862463747997849619
