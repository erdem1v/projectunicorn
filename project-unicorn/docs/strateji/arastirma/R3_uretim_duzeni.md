# R3: Küçük ekip üretim düzeni, yeniden açılan işler ve temel kaynaklar

Arama sayısı: 18

Tarih: 2026-10-19

Not (kapsam): 18 aramanın hepsi kullanıldı, bütçe doldu. Arama araçları sayfa özeti döndürüyor. Bazı kaynaklara yalnız arama özetinden baktım, sayfayı açmadım. Bunları kaynak listesinde "(arama özeti)" diye işaretledim. Bir arama (Software Inc geliştirici notları) boşa gitti. Software Inc, Game Dev Tycoon, Kenshi ve Papers Please için geliştirici günlüğü ya da sonsöz bulamadım. Bu oyunlar için yalnız kronoloji var, süreç anlatısı yok. Kitaplar için (Game Production Handbook, Designing Games'in içeriği, Agile Game Development'ın bölümleri) birincil sayfa 403 verdi ya da hiç bulunmadı.

Kaynaksız hiçbir şeyi bulgu diye yazmadım. Model bilgisinden gelen satırlar "Kaynaksız (model bilgisi):" ile başlıyor.

## Kısa cevaplar

1. Aşamalar: Kaynaklar aynı sırayı veriyor: kavram, prototip, dikey kesit, alfa (özellikler tamam), beta (içerik tamam), altın sürüm. Ama bulduğum çıkış ölçütleri tek kişilik ekip için değil, bir araç satıcısının blogundan ve büyük stüdyo kılavuzlarından geliyor [14]. 1-5 kişilik ekipler için sayısal ölçüt bulamadım.
2. Yeniden açma: Örneklerde hep var. Lucas Pope dikey kesitinin "hiç ölçeklenmediğini" yazdı [10]. Mini Metro arayüzü baştan kurdu [6]. Ama "hangi aşamaya kadar normal" diye ölçen bir kaynak bulamadım. Bu bir yorum (aşağıda Görüş).
3. Planlama: Tek kişilik ekip için kaynaklar Kanban ve tek sayfalık, büyüyen bir tasarım belgesi diyor [16][27]. Ama bunlar araç satıcısı blogları, kanıtı zayıf. Clinton Keith'in kitabı ise 2-4 haftada bir oynanabilir sürüm istiyor [23].
4. Yönetim oyunları: Hepsi erken çıktı ve oyunculara açık geliştirdi. Mini Metro prototipten 5 ay sonra tarayıcı alfa verdi [6]. RimWorld duyurudan 7 hafta sonra alfa verdi [12]. Software Inc 2015'ten beri Erken Erişimde ve %94 olumlu [9]. Rewrite sayıları çoğunlukla yok. Factorio'nun Java'dan C++'a 12 günde geçişi bilinen tek net örnek [3].
5. Başarısızlar: Gerçek ve doğrulanabilir tek örnek Spacebase DF-9. Sonu belli olmayan üretim planı, geç gelen temel sistemler ve sessizlik [17][18]. Başarısız projelerin çoğu sonsöz yazmaz, bu yüzden veri eğik (Görüş).
6. İncil adayları: Tek kişilik yönetim simülasyonu için en uygun üçü: Derek Yu'nun makalesi (kapsam), Tynan Sylvester'ın kitabı (tasarım) ve Chris Zukowski (pazarlama). Agile Game Development daha çok çok disiplinli stüdyolar için.

## Bulgular

### Soru 1. Aşamalar ve çıkış ölçütleri

- Wayline blogu (19 Kas 2025) aşamaları şöyle sıralıyor: kavram belgesi, oynanabilir prototip, dikey kesit, alfa, beta, altın sürüm, çıkış sonrası [14]. Yazı süre vermiyor [14].
- Prototip çıkış ölçütü: "temel oyun döngüsü doğrulanır", yani oyunun eğlenceli olup olmadığını sınamak için gereken en az özellik [14].
- Dikey kesit: Küçük bir bölüm "neredeyse son kalite"de; sanat, ses, arayüz ve oynanış birlikte [14]. Arama özeti, dikey kesiti "temsilî olsun, kapsamlı değil" diye anlatıyor; bu cümlenin hangi sayfadan geldiği belirsiz [26].
- Alfa: "Alfa, tüm temel özellikler uygulandığında gelir; hatalı ve cilasız olsa bile." Oyun baştan sona oynanır [14].
- Beta: Tüm içerik girmiş, oyun geniş test için yeterince kararlı; hata, denge ve performans işi biter [14].
- Altın sürüm: Yeni özellik yok; yerelleştirme ve son testler biter [14].
- Aynı arama, gerçek stüdyo kılavuzlarında kapı mantığını anlatıyor: her kapıdan geçmeden sonrakine geçilmez ve her kapı daha çok yatırım ister (Sony dönemi sunumu) [26]. Süre tablosu tek bir blogun tahmini: ön üretim 2-6 ay, üretim 6-18 ay, alfa ve beta 1-3 ay [26]. Bu sayıları tek kaynaktan, doğrulanmamış diye alın.
- Gerçek küçük ekip örnekleri bu aşamaları adıyla izlemiyor:
  - RimWorld: duyuru 15 Eyl 2013, Kickstarter 2 Eki 2013 (CA$268.132, 30 günde), ilk halka açık alfa 4 Kas 2013, beta 18 Kas 2017, 1.0 17 Eki 2018 [12]. Ekip 2013-2018 arası 2-3 geliştirici [12].
  - Kenshi: tek kişi, 2006-2008 civarında başladı, Erken Erişim Mart 2013, tam sürüm 6 Ara 2018 [7].
  - Factorio: ilk commit 2012, Erken Erişim 25 Şub 2016, 1.0 14 Ağu 2020 [3][28].
  - Mini Metro: prototip Nisan 2013 (Ludum Dare 26), tarayıcı alfası Eylül 2013, Erken Erişim Ağu 2014 [6].
- Yani bu oyunlarda "alfa" ve "erken erişim" oyunculara açık bir üretim yöntemiydi, kapalı bir kilit noktası değildi [6][12][7].
- Görüş: Tek kişilik ekipte "kilitlenen şey" aşamadan çok oyuncunun ne gördüğüdür. Prototipte kilitlenen tek şey çekirdek döngü, dikey kesitte arayüz dili ve görsel stil, alfada özellik listesi olmalı. Bu kaynaklardan çıkan bir tasarım önerisi, bulgu değil.

### Soru 2. "Bitti" denen sistemin yeniden açılması

- Lucas Pope, Return of the Obra Dinn için 5 Nis 2016 günlüğünde: dikey kesiti "tam oyuna hiç ölçeklenmedi" [10]. Kesit sağlamdı ama arayüz, araç ve sistemleri tam oyun için büyütürken "her şeyi bozdu" [10].
- Sonuç: Yaklaşık 1,5 ay, eski yapıda zaten olan işlevleri yeniden kurmakla gitti. Kendi sözü: GDC demosu eski geliştirme yapısından "net olarak 1,5 yıl daha iyi" değil [10]. Bunu "gevşek, yinelemeli" çalışma tarzına bağladı [10].
- Pope bunu daha önce de yaşadığını yazıyor: "X ayda sağlam bir dikey kesit çıkarmak, sonra tam oyun için araç ve sistemleri büyütürken her şeyi kötü bozmak" [10].
- Factorio ilk sürümü Java'da yazdı. Kovarex: "12 gün sürdü" ve C++'a geçti [3]. Erken bir yeniden yazım, ucuz.
- Mini Metro: Arayüz yeniden tasarımı "tam bir grafik elden geçirmeye" büyüdü, arayüz hem masaüstü hem mobil için baştan kuruldu [6]. Alfa döneminin çoğu hangi özelliğin kalacağına karar vermekle gitti [29] (arama özeti).
- Mini Metro'da biçimsel plan yoktu; "özellik büyümesi" oldu ve kalan iş sürekli az tahmin edildi [6]. Noel 2013 hedefi kaçtı [6].
- RimWorld'e gelmeden Tynan Sylvester birkaç prototipi bıraktı: Project Zomboid benzeri roguelike (oynadıkça sıkıcılaştı), Smash TV benzeri arena (Animus), bir paralı asker yönetimi [13][12]. Bu bilgi Wikipedia ve ikincil bir röportaj özetinden, birincil metni açmadım [13].
- Cultist Simulator: Ekip, oyun tasarımına aykırı olduğu için öğretici istemedi. Sonradan metinlere ipuçları eklemek zorunda kaldı [4]. Yani onboarding açığı geç kapandı.
- Önleme yolları için kaynaklar:
  - Derek Yu: "oynanabilir bir şeyi erken yap, elindeki araçla" [1]. Prototip fikrin zayıf olduğunu gösterebilir ya da daha iyisini [1].
  - Derek Yu: kod dağınık diye baştan başlama; yavaşlatan kısmı temizle, devam et [1].
  - Derek Yu: yeni fikirleri, tüm projeyi yeniden yaptıracaksa, bir sonraki oyuna sakla [1].
  - Özellik kilidi, sistem sınırları ve atılabilir prototip için ayrı bir kaynak bulamadım. Bunlar mühendislik uygulamaları; oyun sektörü kaynağı olarak bulgu yok.
- Genişlik ve derinlik karşılaştırması: Hiçbir kaynakta doğrudan "genişlik önce" ile "derinlik önce"yi karşılaştıran sayısal bir çalışma bulamadım. Dolaylı kanıt: Pope'un dikey kesiti (tek dilimi derin yapmak) ölçeklenmedi [10]. Spacebase DF-9'da güç reaktörü gibi temel sistem geç geldi ve üstüne kurulan her şeyi geciktirdi [17].
- Görüş: Bu iki kanıt birlikte, "dikey kesit" ile "derinlemesine modül bitirme"nin aynı şey olmadığını gösteriyor. Dikey kesit tüm katmanları (veri, arayüz, ses) ince bir dilimde birleştirir. Modül modül derinlik ise dilimsiz, tek sistemi bitirir. Pope'un sorunu ikincisinin araç ve boru hattı kısmıydı.
- Maliyet: Pope için ~1,5 ay [10]. Daha fazlası için sayı yok.
- "Hangi aşamaya kadar normal" sorusuna dayanak yok. Tahmin: Prototip ve dikey kesitte yeniden açma beklenir; alfadan sonra (özellik kilidi sonrası) aynı şey oyunun ana döngüsünü bozuyorsa pahalıdır. Bu sayılara dayanmayan bir çıkarım.

### Soru 3. Planlama, belge, playtest

- Kanban ve Scrum: Wayline'ın solo geliştirici yazısı "çoğu solo geliştirici için cevap Kanban" diyor; Scrum rolleri bir kişide toplanıyor [16]. Kanban'da yapılan iş sınırı (WIP) 1 öneriliyor [16]. Uyarı: Wayline kendi araçlarını satan bir şirket; yazılar tanıtım amaçlı [16].
- Aynı aramada bir 2019 akademik çalışma (DOI 10.1080/1206212X.2019.1621463) Scrum, Kanban ve Scrumban'ı bağımsız oyun geliştiricileri için inceliyor. Yalnız özetini gördüm; Kanban'ın değişikliğe her an izin verdiği çıkıyor [16].
- Tasarım belgesi: Bir rehber solo ve küçük oyun için tek sayfalık özet öneriyor; ekip büyüdükçe 5-15 sayfalık yalın, yaşayan bir belgeye çıkıyor [27]. Tek sayfa şunları içeriyor: fikir, tasarım direkleri, çekirdek döngü, ana mekanik, görünüm, platform [27]. Bu da blog düzeyinde; kontrollü karşılaştırma yok [27].
- Clinton Keith'in Agile Game Development with Scrum kitabı, oyunu her 2-4 haftada, hatta günlük oynanabilir tutan yinelemeli teknikleri anlatıyor [23]. Kitap bütçe şişmesi, imkânsız takvim ve aşırı mesaiyi hedef alıyor [23]. Yazar 15 yıldan fazla oyun yapmış, 7 yılını Scrum ile [23]. Bölüm içeriğini (O'Reilly) açamadım, 403.
- Playtest: Mini Metro'da biçimsel playtest süreci yok. Herkese açık tarayıcı alfa, Erken Erişim topluluğu, fuar standı ve Steam sayfası geri bildirimi kullanıldı [6]. Ders olarak "erken doğrula" yazılmış [6].
- RimWorld: Arkadaşlar prototipi oynadı ve evden çıkmak istemedi; konsept böyle oturdu [13] (Wikipedia özeti).
- Tynan Sylvester (Ludeon, 1 Tem 2015): "Oyun, vaatler yerine getirildiğinde ve tasarımda boşluk kalmadığında biter" [11]. Bu bir "bitti" tanımı.
- Dışarıdan oyuncuya ne zaman gösterilir:
  - Zukowski: Steam sayfasını, oyunu paylaşmaya karar verdiğin an aç. "İstek listeleri yaşlanmaz." Tür ya da ton ciddi değişirse değer düşebilir [19].
  - Zukowski: Sayfadan önce bir tür seç, sanat stilini sabitle, en az üç farklı ortam göster, kapsül görseli için profesyonel sanatçı tut, fragmana oyun içi görüntüyle başla [19].
  - Next Fest için: demonuyu festival sırasında ilk kez çıkarma; ilk gün hata çıkarsa iş biter (arama özeti, bir haber sitesi) [20].
  - Erken Erişim fiilen gerçek çıkıştır; hazırlıksız girmek zor kurtarılan kötü yorum getirir (arama özeti) [20].
- Cultist Simulator: Kickstarter Eylül 2017'de, oynanabilir alfa ile açıldı; bir JS prototipi 2017 başından [4]. 31 Mayıs çıkış tarihi erken söz verildi [4]. Yayından sonra eleştiri hacmi tasarımcıyı yordu [4].

### Soru 4. Yönetim ve simülasyon oyunları

RimWorld (Tynan Sylvester, Ludeon)
- Kronoloji yukarıda [12]. Steam Erken Erişim için Temmuz 2015'te "Temmuz sonu ya da Ağustos başı" planlıyordu [11]. Aynı gönderide Eylül'den itibaren yaklaşık altı ay ara vereceğini yazdı; yorumlarda Steam çıkışını geri dönünceye kadar bekletmeyi düşündü [11].
- Arama özeti, Steam Erken Erişim tarihini 15 Tem 2016 diye veriyor; Ludeon yazısıyla çelişiyor, tarihi sayfayla doğrulamadım [13].
- Satış: Şubat 2018'de 1 milyonun üzerinde; 2020 Ağustos'ta tahmini gelir 100 milyon dolar üstü [12].
- Sylvester'ın Designing Games kitabı (2013) tasarımı geniş çerçevede, "deneyim mühendisliği" olarak anlatıyor: karar, ödül zamanlaması, yineleme ve ekip yönetimi. Bu bir kitap incelemesine dayanıyor, kitabın metnine değil [24]. Kitabın içinde RimWorld'ün hikâye üreticisi geçtiğine dair kaynak bulamadım.

Game Dev Tycoon (Greenheart Games)
- Kardeşler Patrick ve Daniel Klug, şirketi Temmuz 2012'de kurdu; oyun 10 Ara 2012'de çıktı [8]. Geliştirme süresini ve ekip büyüklüğünü sayfa vermiyor [8]. Greenheart sonsözü bulamadım.
- Tahmin: Şirket kuruluşu ile geliştirme başlangıcı aynı tarih olmayabilir; "5 ayda yapıldı" diye okumayın.
- Ünlü korsan deneyi: Patrick Klug, kırılmış bir sürümü kendisi torrente yükledi; oyuncunun parası tükeniyor [8].
- Not: Notebookcheck'e göre stüdyo 12 yıl sonra Tavern Keeper'ı Erken Erişimde çıkardı (arama özeti) [30].

Software Inc (Coredumping)
- Steam sayfası: Erken Erişim, 1 Mayıs 2015; "tek kişilik bir iş"; 5.638 İngilizce yorumun %94'ü olumlu (sayfa 2026-10-19'da okundu) [9]. Geliştirici "Bu bir yarış değil" diyor ve fiyatın tam sürüme doğru artacağını söylüyor [9].
- Geliştirme notu, yeniden yazım sayısı ya da ilk oynanabilir sürümün tarihi yok. Wikipedia'da sayfa bulunamadı (404).

Factorio (Wube, Friday Facts)
- İlk sürüm Java'da; kovarex 12 günde C++'a geçti. "Bugün ilk commit'ten tam 5 yıl" (Mar 2017) [3]. Haftalık blog (Friday Facts) 438. sayıya kadar sürdü, son sayı 22 Kas 2024 [31] (arama özeti).
- İlk oynanabilir sürümün ne kadar erken çıktığı sorusuna bu kaynaktan cevap yok. Tahmin: Pre-alpha 0.1 sürümü yayında [3] ama tarihini vermiyor.

Cultist Simulator (Weather Factory)
- Yukarıda [4]. Kartların sanat bütçesini düşük tuttuğunu Alexis Kennedy söylemiş (arama özeti) [5]. Yapımcı Lottie Bevan: yayın sonrası pazarlama planı satışları daha uzun tutabilirdi; oyun Steam ön sayfa kitlesi için tasarlanmamıştı; arayüz/UX cilası iyileştirilecek alandı (arama özeti) [5].

Papers, Please (Lucas Pope)
- Pope'un TIGForums günlüğüne göre bagaj araması, mühür için UV kontrolü ve ara sıra silahlı çatışma sürümden çıkarıldı (arama özeti, Kill Screen) [32]. Yani kesme, tasarımın parçasıydı.
- Geliştirme süresi için bir hayran vikisi "dokuz ay, 2012-2013" diyor; doğrulanmadı [32].

Mini Metro (Dinosaur Polo Club)
- Hafta sonu prototip, Greenlight'a ~10 ay, sonra çıkışa 16 ay [6].
- İyi giden: Sıkı kapsam kısıtları (elle yapılmış seviye yok, ağır sanat yok, ses içeriğine bağımlılık yok), ücretsiz tarayıcı sürümü, Erken Erişim, tek bakışta anlaşılan fikir [6].
- Kötü giden: Resmî plan yok, özellik büyümesi, masaüstü bitmeden mobile başlamak, Unity'nin sağladığı şeyler için özel eklenti yazmak, iki kurucunun farklı hedefleri [6].

Kenshi (Chris Hunt)
- Tek kişi; ilk yıllarda yarı zamanlı güvenlik görevlisi olarak çalıştı; 2013'te küçük bir ekip kurdu [7]. 12 yıl [7]. Yeniden yazım ya da teknik sorun bilgisi sayfada yok [7].

### Soru 5. Başarısız projelerin süreç hataları

- Spacebase DF-9 (Double Fine, yönetim simülasyonu): Tim Schafer, ekibin "açık uçlu bir üretim planıyla" başladığını, beş aylık işin bir buçuk yıla uzayacağının anlaşıldığını ve stüdyonun kazandığından fazla harcadığını yazdı (arama özeti) [18].
- Planlanan zaman yolculuğu, holodek, hukuk sistemi, çok katlı üs, ışınlanma ve cenaze gibi özellikler atıldı; oyun 1.0'a çoğu özellik olmadan çıktı, modlara bırakıldı [18].
- Schafer: en büyük ders iletişim; oyunculara oyunun durumu hakkında daha çok bilgi vermek gerekirdi (arama özeti) [18].
- Game-Wisdom (Josh Bycer): Double Fine'ın ilk aylardan sonra susması satışı ve güveni vurdu; bitiş noktası olmayan plan ilerlemeyi görünmez, özellik listesini şişkin yaptı; temel sistemler (güç reaktörleri) geç geldi; çok proje aynı anda ekibi zorladı [17].
- Mini Metro'nun kendi hataları da başarısızlık kalıbı: plan yok, özellik büyümesi, iş yetersiz tahmin, ana oyun bitmeden mobil [6].
- Derek Yu'nun listesi: menüler, geçişler ve kayıt sistemi zaman yer; son yüzde 10 aslında yüzde 90 ("the last 10 percent is really 90 percent") [1].
- Wayline'ın "başarısız sonsöz" yazıları gerçek stüdyolardan değil; bir tanesi açıkça "Project Phoenix"in gerçek adı olmadığını söylüyor [15]. Yinelenen dersleri (küçük eklemeler, altı aydan on sekize uzayan takvim, sessiz kalan playtest yapanlar) yalnız fikir olarak alın, kanıt olarak değil [15].
- Hayatta kalan yanılgısı konusunda: Bulabildiğim gerçek örnekler (RimWorld, Factorio, Kenshi, Software Inc, Mini Metro, Cultist) hep çıkmış oyunlar. Hiç çıkmamış gerçek bir yönetim oyunu sonsözü bulamadım. Görüş: Bunun nedeni muhtemelen çıkmayan projelerin sonsöz yazmaması, yani kanıtın kendisi eğik.
- Başarılı örneklerin de sorunları var: Pope'un ölçeklenmeyen kesiti [10], Mini Metro'nun gecikmesi [6], Cultist'in geç onboarding'i [4], Kenshi'nin 12 yılı [7], RimWorld'ün 5 yıllık Erken Erişimi [12]. Başarılı olmak sorunsuz süreç demek değil.

### Soru 6. "İncil" adayları

Doğrulanan:
- Derek Yu, "Finishing a Game" (makale, 2010): Kapsam, özellik büyümesi, erken prototip, son cila. Ücretsiz ve kısa [1]. Kendi alıntıları: "çekirdeğin en kenarına gelene kadar kesmeye devam et", "elinde ne varsa onunla önce prototip yap" [1].
- Jesse Schell, The Art of Game Design: A Book of Lenses: 100'ü aşkın "mercek" (Eğlence, Akış, Risk gibi) ile tasarımı sınamak için kontrol listesi. Platformdan bağımsız [22]. Baskı yılını sayfa vermiyor.
- Tynan Sylvester, Designing Games (2013): Büyük resim; ödül zamanlaması, yineleme, ekip yönetimi [24] (kitap incelemesi). RimWorld'ün yazarı olduğu için yönetim simülasyonu yapan biri için en alakalı tasarım kitabı olması muhtemel (Görüş).
- Clinton Keith, Agile Game Development with Scrum: oyun üretimi için Scrum; 2-4 haftada oynanabilir sürüm [23]. Çok disiplinli ekibe göre yazılmış.
- Chris Zukowski, How To Market A Game: Steam sayfası, istek listesi, demo [19][20].
- Joao Queirós (13 Ağu 2026), yapay zekâ ile oyun geliştirme günlüğü: "brif, yap, oyna, ölç, belgele, kontrol noktası, gözden geçir, yeni biriyle test et". Tek yapıya dair kendi bildirimi, kontrollü değil [21].

Kaynaksız (model bilgisi):
- Heather Chandler, The Game Production Handbook: üretim yönetimi, aşamalar, takvim, bütçe, ekip. Kaynak bulamadım; içeriğini doğrulamadım.
- Jason Schreier, Blood, Sweat, and Pixels: stüdyoların sorunlu üretim hikâyeleri (Stardew Valley, Diablo III gibi). Hayatta kalan yanılgısına karşı iyi bir okuma olabilir. Doğrulamadım.
- GDC Vault'ta Cultist Simulator konuşması var (Alexis Kennedy, 2019), "kısıtlar altında verilen kararlar" üzerine [4][25]. İçeriğini okumadım.
- Diğer GDC konuşmaları (örneğin Pope'un Obra Dinn konuşması) için bulduğum tek şey haber alıntıları [10].

## Bize dersler

Bu bölümün tamamı Görüş.

1. Sizin sorununuz "aşama" eksikliği değil. Yukarıdaki oyunların hiçbiri sıkı aşama kapısı kullanmadı [6][12][7]. Ortak nokta: oynanabilir bir şey çok erken oyunculara gitti. Mini Metro prototipten 5 ay sonra tarayıcıda [6]. RimWorld duyurudan 7 hafta sonra alfa [12]. Sizin demo aylardır "yaklaşıyor". Kaynaklarda hiçbir yerde demonun bu kadar uzadığı bir başarı örneği yok. Bu eksik kanıt, yokluk kanıtı değil.
2. Yeniden açılma normaldir ama pahalıdır. Pope'un deneyimi tam sizin durumunuz: dilim iyi, büyütünce sistemler bozuldu [10]. Bunu önlemenin kanıtlı yolu yok; kaynaklar yalnız "erken oyna" diyor [1].
3. "Bitti" için oynanabilir bir kapı koyun. Sylvester'ın tanımı: "vaatler yerine getirildi ve tasarımda boşluk yok" [11]. Bir sistem için: Erdem bir tam oyun oturumu oynayıp "hissi" onayladıktan sonra kapanır; sadece kodun testleri geçmesi yetmez. Üç revizyon turu ve "oyun hâlâ meh" hissi, kapının kodda olup oyunda olmamasından geliyor olabilir. Queirós aynısını yazıyor: kod incelemesi, yeni oyuncu için mekaniğin işleyip işlemediğini göstermez [21].
4. Yapay zekâ ajanlarıyla darboğaz yer değiştirir. Queirós: darboğaz "kod yazmaktan yön, değerlendirme ve zevke" kaydı; "yapay zekâ, bir insanın değerlendirebileceğinden hızlı sistem üretebilir" [21]. Bu sizin gözleminizle örtüşüyor: ajan hızlı üretiyor, siz pahalı olan yargıyı veriyorsunuz. Tek bir kaynak ve tek yapı, ama yön tutarlı.
5. Ajan düzeni için önerim (Queirós'un döngüsüne dayanarak [21]): Her görev "oynanabilir sonuç cümlesiyle" başlasın ("bunu oynarken şunu hissetmeli"). Revizyon turu başına tek hedef olsun. Her turda ajan, oyuncunun göreceği şeyi (ekran görüntüsü, oturum özeti) Erdem'e göstersin; kod özeti değil. Tasarım belgesi ajanlar için ortak hafıza olsun [21]. Bu bir öneri, kanıtlanmış bir düzen değil.
6. Kapsamı küçültmek bir tasarım kararıdır. Derek Yu: geride kalınca neyin önemli olduğuna karar ver, çekirdeğin kenarına kadar kes [1]. Pope özellikleri bilerek attı (bagaj, UV, silahlı çatışma) [32]. Spacebase DF-9 bitiş noktası olmayan plan yüzünden battı [17][18]. Project Unicorn'da B2B ve B2C iki yol, iki ürün, 13 sektör var. Hangisinin demoda yer alacağını kapatmak bir kesme kararı olur.
7. Steam sayfasını erken açın. Zukowski: istek listeleri yaşlanmaz; tür ve sanat stili sabit olmalı [19]. Fontu ve arayüzü zayıf buluyorsunuz; bu stil sabitleme için önce çözülmesi gereken bir şey, çünkü ciddi stil değişimi erken istek listelerini zayıflatabilir [19].
8. Kendi başına bir "slop" korkusu gerçek, ama kaynaklar cilanın ne zaman biteceğini söylemiyor. Derek Yu "son yüzde 10 aslında yüzde 90" diyor [1]. Cila için kalite ölçütü ve bitiş tarihi koyun; yoksa sonsuza gider.
9. Erken Erişim bir kaçış değil. Hazırlıksız girilen Erken Erişim kötü yorum getirir [20]; Software Inc (%94, 5.638 yorum) ve RimWorld'ün başarısı sürekli iletişime ve güncellemeye dayanıyor [9][12]. Spacebase'in sessizliği tersini gösterdi [17].
10. Moral için: Aylar süren yeniden açılma, başarılı örneklerde de var (Kenshi 12 yıl [7], RimWorld 5 yıl [12], Mini Metro'da kaçan Noel hedefi [6]). Bunu doğal kabul etmek yanlış olur ama olağanüstü de değil.

## Bulunamayanlar

- 1-5 kişilik ekipler için aşama başına sayısal çıkış ölçütü ve süre (yalnız araç satıcısı blogu [14] ve tek blog tahmini [26]).
- "Bitti denen sistem hangi aşamaya kadar yeniden açılır" sorusunu ölçen çalışma.
- Genişlik önce ile derinlik önce yaklaşımının doğrudan karşılaştırması.
- Özellik kilidi ve sistem sınırı uygulamalarının oyun sektörü kaynağı.
- Greenheart Games, Coredumping (Software Inc), Weather Factory dışında ve Lucas Pope'un Papers Please'i için geliştirici sonsözü ya da yeniden yazım bilgisi.
- Kenshi'de yeniden yazım bilgisi.
- RimWorld'ün Steam Erken Erişim tarihi (2015 planı ile 2016 iddiası çelişiyor).
- Factorio'nun ilk oynanabilir sürüm tarihi.
- The Game Production Handbook ve Designing Games'in birincil içerik sayfası (O'Reilly 403).
- Hiç çıkmamış gerçek yönetim simülasyonu projelerinin sonsözü; yalnız Spacebase DF-9 var ve o da çıktı (yarım).
- Agile Game Development kitabında dikey kesit ve yayıncı kilometre taşı bölümleri.
- Playtest sıklığı için sayı.
- Yapay zekâ ajanlarıyla oyun geliştirme için bağımsız, kontrollü çalışma; yalnız kişisel bloglar.
- Tycoon türünde gerçek başarısız oyun (Mad Games Tycoon 2, Big Ambitions) geliştirme süreçleri: aranmadı, bütçe yetmedi.

## Kaynaklar

1. Derek Yu, "Finishing a Game", Make Games, 2010. https://makegames.tumblr.com/post/1136623767/finishing-a-game (sayfa açıldı, özet)
2. (numara boş bırakıldı)
3. Friday Facts #184, "Five years of Factorio", Mart 2017. https://factorio.com/blog/post/fff-184
4. Lottie Bevan, "Cultist Simulator: the retrospective", Game Developer, 2018. https://www.gamedeveloper.com/business/cultist-simulator-the-retrospective
5. PC Games Insider, Cultist Simulator başarı hikâyesi (Bevan). https://www.pcgamesinsider.biz/success-story/67247/were-looking-forward-to-adding-to-cultist-simulator-for-a-good-while-yet (arama özeti, tarih belirsiz)
6. Dinosaur Polo Club, Mini Metro sonsözü, Game Developer, Haziran 2016. https://gamedeveloper.com/audio/postmortem-dinosaur-polo-club-s-i-mini-metro-i-
7. Kenshi, Wikipedia. https://en.wikipedia.org/wiki/Kenshi_(video_game) (okunma tarihi 2026-10-19)
8. Game Dev Tycoon, Wikipedia. https://en.wikipedia.org/wiki/Game_Dev_Tycoon (okunma tarihi 2026-10-19)
9. Software Inc, Steam mağaza sayfası. https://store.steampowered.com/app/362620/Software_Inc/ (okunma tarihi 2026-10-19)
10. Kill Screen, "Development of Papers, Please creator's next game hits rough seas", 5 Nisan 2016. https://www.killscreen.com/development-of-papers-please-creators-next-game-hits-rough-seas/
11. Tynan Sylvester, "On the upcoming Steam release", Ludeon blogu, 1 Temmuz 2015. https://ludeon.com/blog/?p=787
12. RimWorld, Wikipedia. https://en.wikipedia.org/wiki/RimWorld (okunma tarihi 2026-10-19)
13. RimWorld prototipleri ve arkadaşlarla test: Wikipedia özeti ve DualShockers. https://www.dualshockers.com/rimworld-developer-game-different/ (arama özeti)
14. Gemma Ellison, Wayline blogu, 19 Kasım 2025 (araç satıcısı). https://www.wayline.io/blog/setting-game-development-milestones-concept-launch
15. Wayline, "scope creep indie dream postmortem" (anonim/kurgusal vakalar). https://www.wayline.io/blog/scope-creep-indie-dream-postmortem (arama özeti)
16. Wayline, "When to Use Kanban Instead of Scrum for Solo Devs". https://www.wayline.io/blog/kanban-vs-scrum-solo-devs (arama özeti)
17. Game-Wisdom, "Spacebase DF-9's end and Lessons on Early Access". https://game-wisdom.com/critical/lessons-early-access
18. PC Gamer, "Tim Schafer explains Spacebase DF-9's unexpected v1.0 release", 2014. https://www.pcgamer.com/au/tim-schafer-explains-spacebase-df-9s-v1-0-release (arama özeti)
19. Game World Observer, Zukowski Steam sayfası rehberi, 11 Mart 2025. https://gameworldobserver.com/2025/03/11/steam-page-launch-guide-wishlists-zukowski
20. WN Hub, Steam sayfası öncesi yapılacaklar (Zukowski, Next Fest demosu). https://wnhub.io/news/stores-and-publishing/item-47314 (arama özeti, tarih belirsiz)
21. João Queirós, "AI Coding Agents / Librarian 2", 13 Ağustos 2026. https://www.ai.joaoqueiros.com/blog/librarian-2-ai-game-development-claude-code-codex
22. Schell Games, The Art of Game Design sayfası. https://www.schellgames.com/art-of-game-design
23. Mountain Goat Software, Agile Game Development with Scrum incelemesi. https://www.mountaingoatsoftware.com/reviews/agile-game-development-with-scrum (arama özeti)
24. BlogCritics, Designing Games incelemesi. https://blogcritics.org/book-review-designing-games-a-guide/ (arama özeti)
25. GDC Vault, Cultist Simulator konuşması, 2019. https://gdcvault.com/play/1025794/-Cultist-Simulator-Designing-an (arama özeti)
26. Aşama kılavuzları (Heathen, Game-Ace, Sony sunumu vb.). https://kb.heathen.group/old-kb/guides/tips-and-tricks/fundamentals/development-phases (arama özeti; hangi cümle hangi sayfadan geldiği belirsiz)
27. Generalist Programmer, "How to write a game design document", 2026. https://generalistprogrammer.com/tutorials/how-to-write-a-game-design-document (arama özeti)
28. Factorio vikisi (Erken Erişim 25 Şub 2016, 1.0 14 Ağu 2020). https://wiki.factorio.com/Factorio (arama özeti)
29. Indie-o-rama, Mini Metro ve Robert Curry. https://www.indieorama.com/mini-metro-and-robert-curry-the-minimalism-was-one-of-the-things-that-made-the-game-hard-to-make (arama özeti)
30. Notebookcheck, Greenheart Games yeni oyun (Tavern Keeper). https://www.notebookcheck.org/El-estudio-de-Game-Dev-Tycoon-vuelve-despues-de-12-anos-con-un-nuevo-juego-de-simulador-de-gestion-y-un-descuento-en-Acceso-anticipado.1157645.0.html (arama özeti)
31. Factorio blog arşivi (Friday Facts #438 son sayı). https://factorio.com/blog/search/expansion/2 (arama özeti)
32. Kill Screen, Papers, Please sahne arkası; TIGForums geliştirme günlüğü özeti. https://www.killscreen.com/peek-behind-scenes-papers-please-reveals-baggage-search-and-gun-fights/ (arama özeti)
