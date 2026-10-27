# R2 - Startup Company (Hovgaard Games): ekip ve üretim zinciri

Tarih: 2026-10-17. Hazırlayan: araştırma ajanı (WebSearch 7, WebFetch yaklaşık 54 çağrı; bunların yaklaşık 40'ı başarılı).

## Okuma notu: kaynakların durumu

- Oyunun asıl bilgi kaynağı olan topluluk wiki'si (startupcompany.fandom.com) bu ortamdan okunamadı. Sayfa "402 Payment Required" ve bot doğrulaması döndürdü. Archive.org ve Reddit'e de erişim engelliydi. Chrome eklentisi bağlı değildi.
- Bu yüzden rapor üç kaynağa dayanıyor: (a) geliştiricinin Steam duyuruları ve devlog'ları (Steam News API'den tam metin), (b) Steam tartışma konuları ve rehberleri, (c) iki oyun incelemesi.
- Wiki'deki rol tabloları, özellik (trait) listesi ve bileşen sayıları bulunamadı. Aşağıda "bulunamadı" diye işaretledim, uydurmadım.
- Steam News API tek bir URL'den 30'dan fazla duyurunun tam metnini veriyor: https://api.steampowered.com/ISteamNews/GetNewsForApp/v0002/?appid=606800&count=100&maxlength=0&format=json (metin 380 bin karakter; aşağıda "News API" diye anıyorum ve duyuru başlığını yazıyorum).
- Mağaza sayfası: https://store.steampowered.com/app/606800/Startup_Company/ . Geliştirici: Hovgaard Games. Tam sürüm: 10 Nisan 2020.

---

## 1. Özet

1. Üretim zinciri üç basamaklı: Developer ve Designer "bileşen" (component) üretir; Lead Developer (Beta 23'ten beri Designer ve SysAdmin de) bileşenleri birleştirip "modül" yapar; modüller ve bileşenler web sitesinin özelliğini (feature) kurar veya seviyesini yükseltir. Üretim hep "elle sıraya koy" ile başladı; oyun yıllar içinde bunu otomasyona çevirdi (kuyruk, tekrar, üretim planı, yönetici, ortak plan).
2. Yönetici (Manager) hem hız bonusu verir hem de üretim planını yürütür. Bir yöneticinin kapasitesi seviyesine göre 3 / 5 / 8 kişi (Beginner / Intermediate / Expert). Bir oyuncu rehberi, yöneticiye atanan kişi başına bonusun azaldığını söylüyor; sayısı bulunamadı. Her çalışan en çok bir yöneticiye bağlı, her yönetici aynı anda tek üretim planı yürütür.
3. Yöneticinin üstünde İK Yöneticisi (HR Manager) var: izin günleri, çalışma saatleri, eğitim günleri ve çalışan maaş pazarlığı gibi "bakım" işlerini toplu yapar. Beta 24'ten beri CEO da İK yapabilir.
4. Oyunun en büyük şikayeti, ölçek büyüdükçe mikro yönetim: ruh hali, izin, ikramiye, sipariş yeniden atama. Geliştirici bunu sürekli otomasyon ekleyerek çözdü ama "ikramiye son çare, rutin olmamalı" diye bilinçli bir sınır koydu.
5. Çalışan memnuniyeti sayı olarak "ruh hali" (mood), isteğe (demand) bağlı. Karşılanan her istek hız bonusu verir ve mutluluğu uzatır. İkramiye ruh halini anında %100 yapar, 30 oyun günü bekleme süresi var.
6. Çalışan başına sabit bir yüzde yok; hız, beceri seviyesi (Beginner/Intermediate/Expert), tavan (potential) ve eğitimle büyüyor. Yani "kişi başına %5" yerine kişinin kendi hız yüzdesi ölçeklenir. Bu bizim için en kullanışlı fikir.
7. Ölçek: ofisler 8 / 20 / 50 masa, sonra gökdelen 180 -> 260, 400 kişilik iki katlı ofis, 500 kişilik plan. Bir inceleme yazarı oyunu hiç 38 kişiden fazla çalışanla oynamamış; bir oyuncu 180 çalışanla ikramiye tıklamaktan şikayet etmiş.
8. Bizim için: ürün-hat-kart zincirine "envanter: tüketim/talep/üretim" göstergesini, ortak üretim planını ve yönetici kapasitesini kademe sistemiyle (3/5/8) almak mantıklı. Sürekli hata düzeltme gibi tekrarlı işleri oyuncuya bırakmamak için "tekrarlayan kuyruk" fikri de alınmalı.

---

## 2. Mekanik döküm

### 2.1 Roller, seviyeler, hız, ruh hali

**Roller.** Bir oyuncunun Steam tartışmasındaki rol özeti (Nisan 2018, https://steamcommunity.com/app/606800/discussions/0/3211505894140617410):
- Developer: temel bileşen üretir.
- Lead Developer: bileşenleri modüle çevirir.
- Designer: ayrı türde bileşen üretir; bir Lead Developer bir tasarımcı ögesi ile birleştirip arayüz modülü yapar.
- Sales Executive: sözleşme (ad contract, sonradan dış kaynak/outsourcing) bulur.
- Researcher: araştırma puanı (RP) üretir; yalnızca özellik ve framework kilidi açar.
- DevOps (Beta 17'de SysAdmin adını aldı): sunucu kapasitesi için parça üretir.
- Marketer: reklam kampanyaları için parça üretir.
- Manager: diğer işçileri yönetir (yönetici ve İK hariç), hız bonusu verir.
- HR Manager: yöneticileri yönetir; izin günlerini ve saatleri toplu ayarlar.
- Eklenenler: Recruiter (Beta 21'den beri işe alım için şart; CEO da yapabilir), Supporter (Beta 21, destek bileti çözer), Outsourcing Executive (Beta 26).
- Bir önizleme "9 çalışan türü" diyor (https://www.keengamer.com/articles/previews/startup-company-preview/).

**Seviyeler.** Beginner, Intermediate, Expert. Her çalışanın bir "hız yüzdesi" (work speed) ve bir "tavan" (potential speed) var. Tavana kadar eğitilir, sonra "Upgrade" ile bir üst seviyeye geçer ve tavan yükselir (News API, "Beta 14 Released!").
- Bir oyuncunun tavsiyesi: işe alırken en az %120 (basic), %200 (intermediate), %340 (expert) hız ara (https://steamcommunity.com/app/606800/discussions/0/1471967615878120865 ; kişisel oyuncu görüşü, resmî tablo değil).
- Beginner için tavan en çok %200 civarı; başka bir oyuncu "tavanı yüksek beginner al, zamanla expert olur" diyor (https://steamcommunity.com/app/606800/discussions/0/3211505894140617410 ve .../3046104336679215068).
- Süperstar çalışan çok nadir, yalnızca expert Recruiter ile bulunur, çok yüksek maaş ister, temel hızı %900'e çıkabilir (News API, "Beta 27 is now available!").
- Maaş: eğitim saatleri verilirse düşük maaşla yüksek hız elde edilir (Beta 14). Seviye yükseltince maaş zammı 1500 dolardan 3000 dolara çıkarıldı, eğitim hızı %33 düşürüldü (News API, "Devlog #10"). Yükseltmede her seferinde bir yeni istek eklenir (Devlog #21 / Beta 16.3).
- Eğitim günü ayarı Expert İK gerektirir, izin günü Intermediate İK gerektirir (Beta 22).
- Emeklilik: 65'te (Beta 21), CEO 18 yaşında başlar 67'de emekli olur ve oyun biter (Beta 27, Devlog #54). Yaş hız ya da ruh halini etkilemez.

**Ruh hali ve istekler.**
- Önce "Work Environment Rating" (WER) vardı: her çalışanın istediği bir WER, eksikse hızla mutsuzlaşırdı. Beta 15'te WER kaldırıldı, yerine kişiye özel istekler (demands) geldi: belirli mobilya, yan hak, masa türü, kısa mesai (News API, "Devlog #10", "Devlog #13", "Beta 15 Released").
- Karşılanan her istek: hız bonusu + mutluluğun daha uzun sürmesi. Çalışan zamanla yeni istek üretir.
- Tatil ruh halini doldurur; 3 gün ruh halini %100 yapmaya yeter (Devlog #8). Oyuncular WER %30 civarında 9-12 günde bir tatil gerektiğini bildirdi (https://steamcommunity.com/app/606800/discussions/0/1471967615874402168).
- İkramiye (Beta 22): ruh halini anında %100 yapar; bedeli maaşa ve mevcut ruh haline bağlı; 30 oyun günü bekleme süresi. Geliştirici cevabı: ikramiye son çaredir; istekleri karşılayın, İK ile izin verin, "yönetilen ve tatmin olmuş ekip geceleyin ruh halini kendiliğinden doldurur" (https://steamcommunity.com/app/606800/discussions/0/1648791520844239734).
- Rakipler en iyi çalışanları çalmaya çalışır, çalışanlar zam ister yoksa ayrılır (Beta 18 rastgele olayları; yalnızca 100 bin kullanıcı üstünde).
- Kişilik özelliği (trait) listesi: bulunamadı. Duyurularda "personality, demands, feelings" geçiyor; ayrı bir özellik tablosu yok ya da okunamadı.

### 2.2 Üretim zinciri: bileşen -> modül -> özellik

- Bileşenler 3 kademeli (Beginner / Intermediate / Expert), her kademe araştırma puanıyla (RP) açılır (https://steamcommunity.com/sharedfiles/filedetails/?id=3693847796, PT-BR üretim rehberi; sayılar görsellerde, okunamadı).
- Modül 2 veya daha fazla bileşenden (bazen modülden de) yapılır. Modüllerin üretim süresi Beta 14.x'te iki katına çıkarıldı (Devlog #9).
- Kim ne üretir: Developer bileşen; Lead Developer modül; Beta 23'ten beri Designer ve SysAdmin de kendi bileşenlerini kendi modüllerine birleştirir. Yüksek seviyeli özellik yüksek seviyeli modül ister (News API, "Beta 23 Released!").
- Araştırma: "tüm açık bileşenleri/modülleri tek tıkla araştır" eklendi (Devlog #19).
- Bir özellik (feature) iki yönde yükselir: Seviye (kullanıcı tavanı) ve Verimlilik (kullanıcı başına sunucu yükü: CU ve MS). Yükseltme maliyeti, önkoşul bileşen/modülleri üretmek için harcanan çalışan saatiyle ölçülür; örnek 60 saat ve 90 saat (https://steamcommunity.com/app/606800/discussions/0/3211505894140617410, oyuncu açıklaması).
- Özellik eşiği (Beta 15, 17): framework'lerin sınırlı "özellik yuvası" var (Basic Framework: 3). Bir sonraki framework için mevcut framework'ün üç özelliği de azami seviyede olmalı (Devlog #22). Reklam türleri (metin, banner, video) ve abonelik de yuva kaplar.
- "Seviye" terimi: eski "Quality" adı Beta 15'te "Level" yapıldı. Özellik kullanımdayken yükseltilebilir.
- Özellik gereksinimini oyuncuya söyleme: özellik penceresi gereken bileşen/modül adetlerini listeler. Örnek adet biçimi ("UI Component x3") ve birebir ekran metni bulunamadı.
- Fiyatlar ve süreler (bir bileşen kaç saatte üretilir): bulunamadı.

**Envanter ve darbogaz.**
- Beta 27: her bileşen/modül için tüketim, talep ve üretim birlikte gösterilir; amaç fazla üretimi kesmek (News API, "Beta 27 is now available!" ve "Devlog #52").
- Başlangıçta oyuncu her çalışana elle ne üreteceğini atıyordu; bileşen bitince yeniden elle atamak zorundaydı (PT-BR rehber: "ana sorun bir bileşenin bitmesi").
- Beta 14: her bileşen/modül için "minimum stok" ayarlanır; limite ulaşınca çalışan durur. Otomatik tekrar tüm çalışanlar için açıldı (News API, "Beta 14 Released!").
- Beta 18: tüm üretim çalışanları için kuyruk + "Repeater". Beta 22: kuyruk ve tekrar birleştirildi, "sonsuz tekrar eden kuyruk", boyut 10.
- Üretim planı (production plan): envanter menüsünde ayrı sekme (v1.0). Plan, hedef adetleri tutar; yönetici planı yürütür. Beta 24: yöneticiler aynı planı paylaşabilir. Rehber önerisi: tampon için ihtiyaç duyulanın iki katını yaz.
- Pazar fiyatları menüsü (Beta 26): bileşen/modül talebi yeşil = düşük, kırmızı = yüksek. Dış kaynak (outsourcing): en çok 4 gereksinim, her biri en çok 500.

### 2.3 Yöneticiler

- İşi: görev atama + hız bonusu (News API, "Beta 14 Released!"). Bir oyuncu: "bir Intermediate yönetici iki developer ve iki designer'ı güçlendirir; yönetilen her ek kişi bonusu azaltır" (https://steamcommunity.com/app/606800/discussions/0/1471967615878120865). Bonus yüzdesi bulunamadı.
- Kapasite: Beginner 3, Intermediate 5, Expert 8 kişi (https://steamcommunity.com/sharedfiles/filedetails/?id=2140338455, bir modun rehberi; temel oyunla aynı olduğu varsayımı doğrulanamadı).
- Kural: her çalışan yalnız bir yöneticiye bağlı; bir yönetici aynı anda tek üretim planı yürütür; birden çok yönetici aynı planı çalıştırabilir. Yönetici satışı yönetmenin belirgin değeri yok denmiş.
- Satış yöneticisi mantığı (sözleşme lead'leri, Beta 22): tek başına 3 / 6 / 9 lead; bir yöneticiye bağlı takımda 9 / 18 / 27, takım lead paylaşır.
- Yöneticisiz çalışan: ilk oyunlarda elle atama + kuyruk (Beta 18 duyurusu: kuyruk "yönetici işe alamayan erken oyunda" çok yararlı). Yöneticisiz de otomatik tekrar var (Beta 14).
- Yönetici yönetici: İK Yöneticisi, yöneticileri yönetir. İK: tüm çalışanların programını toplu belirler, izin günü seçer (Beta 14); zam teklifini otomatik karşılama (v1.0); Beta 24'te CEO da İK yönetimi yapabilir.
- CEO: Beta 29'da CEO'nun geçmişi (developer / designer / manager) seçilir; yöneticiyse araştırmacıları yönetebilir (oyuncu notu: https://steamcommunity.com/app/606800/discussions/0/3211505894140617410).
- Masalar: Beta 19'da yöneticiler için "executive" masa türü eklendi.
- Takım kurma kuralı: ayrı bir "ekip" nesnesi yok; "bir yöneticiye bağlı kişiler" ekiptir. Bir inceleme, düşük seviye çalışanın yöneticiye, yöneticinin İK'ya ihtiyacı olduğunu yazıyor (keengamer).
- Verimlilik cezası: yöneticinin atadığı kişi sayısı arttıkça kişi başı bonus azalır (oyuncu görüşü, rakamsız). Yöneticisiz çalışanın cezası olduğuna dair kaynak bulunamadı; kaybı hız bonusu ve elle atama yüküdür.

### 2.4 Özellik kalitesi, memnuniyet, hata

- Beta 17'de "Satisfaction" eklendi: memnuniyet pazarlama dönüşüm oranını ve organik büyümeyi etkiler. Aylık ücret yükseldikçe ve etkilenen özellik arttıkça memnuniyet düşer. "Mutlu" eşiği %85'ten %70'e indirildi (17.3). Viral artış için memnuniyet %70 üstünde olmalı (Beta 18).
- Beta 25'ten beri model: temel özellikler yalnız memnuniyet üretir, gelir özellikleri (reklam vb.) yalnız memnuniyetsizlik üretir. Toplam = temel özelliklerin ortalaması - gelir özelliklerinin memnuniyetsizliği. Reklam engelleyici oranı küçük sitede düşük, kullanıcı arttıkça yükselir (News API, "Beta 25 Released!" ve "Devlog #48").
- Destek (Beta 21): biletler düşük / orta / yüksek karmaşıklıkta, 36 saat içinde çözülmeli, aksi halde destek memnuniyeti düşer ve bu doğrudan toplamdan çıkar. Supporter'lar aynı hızda çalışır; Intermediate ve Expert destekçi, kendi seviyesinin altındaki biletleri çözmek zorunda kalırsa mutsuzlaşır. Destek takımı fikri: üyeleri belirli karmaşıklıkla sınırlamak (Devlog #35, plan).
- Yazılım hatası (bug) mekaniği: bulunamadı; oyunda özellik "hatalı kapanır" kavramı yok. Kalite = seviye + verimlilik; kaybı memnuniyetsizlik ve sunucu yükü getirir.
- Sunucu: kullanıcı başına CU ve MS yükü; verimlilik üst sınırı %100 (Beta 22). Raf boyutları 10 / 20 / 42 yuva, sunucu gücü Web / Cache / DB'nin en düşüğüdür (https://steamcommunity.com/sharedfiles/filedetails/?id=2504405550).

---

## 3. Oyuncuya gösterim

- Çalışan penceresi: hız yüzdesi (yıldız), baz hız, tavan, maaş, ruh hali (surat ikonu: sarı/kırmızı), istekler (üzerine gelince), "Controlled by Manager" etiketi (Devlog #8).
- Çalışanlar menüsü (Beta 22): toplu işlem (masadan al, kov, 1-3 gün eve gönder, eğitimi başlat/durdur, yöneticiden çıkar), yaşa göre sıralama (Devlog #58), emeklilik uyarısı 1 yıl önceden, çalışan değiştirici.
- Envanter menüsü: bileşen/modül başına üretim - talep - tüketim; üretim planları ayrı sekme.
- Özellik sekmesi: fareyle üstüne gel -> Upgrade; ekran görüntüsü; seviye çarpanı ile tek tıkta birden çok seviye.
- Ekranlar: tek ofis ekranı, çoğu zaman menülerde geçiyor; çalışanlar yürümez, masalarında belirir ve kaybolur; "az/çok personel" sinyali yok (https://www.gamesasylum.com/?p=52532).
- Ekran görüntüsü URL'leri (Steam galerisi):
  - https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/606800/ss_74de0b0d767febb4e7d11406b38e199884f3d678.1920x1080.jpg?t=1727681373
  - https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/606800/ss_60b0b2a8fb13081564c418913f9afbebe78c3562.1920x1080.jpg?t=1727681373
  - https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/606800/ss_0c096a49947a394216f9a51da8caf32943cce330.1920x1080.jpg?t=1727681373
  - https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/606800/ss_ea1b02a0c8163011799d16b7216a4b1dd46dabc9.1920x1080.jpg?t=1727681373
  - https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/606800/ss_4c4ba1c4f5e041fbb10b29be458b9cbedec34df3.1920x1080.jpg?t=1727681373
  - https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/606800/ss_8dac9adb157819ab46d7d360ac63f8f61b75e5c1.1920x1080.jpg?t=1727681373
  - https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/606800/ss_8b07098ae4dfbdc86c9caebf44c498bf8b5bf71f.1920x1080.jpg?t=1727681373
  - https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/606800/ss_12d04b8d057121d1ce7214576367925bb2ea32aa.1920x1080.jpg?t=1727681373
  - https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/606800/ss_4a61b4efcb7cfd390e2433cb66db079349b7890c.1920x1080.jpg?t=1727681373
  Bu görüntülerin içeriğini göremedim; hangisinin hangi ekran olduğunu bilmiyorum.

---

## 4. Ölçek ve sorunlar

**Ölçek rakamları.**
- Masa sayıları: başlangıç 8, sonra 20 ve 50 masalı binalar (keengamer); gökdelen 180 (Devlog #11) -> 260 (Beta 19); iki katlı 400 kişilik ofis (Beta 22); 500 kişilik iki katlı ofis önizlemesi (Devlog #34).
- Performans: 200+ çalışanda çalışanlar menüsü yavaştı, Beta 22'de düzeltildi; Beta 19'da 200 çalışanda 27 -> 144 fps (WebGL'e geçiş).
- 20-60 çalışan aralığı: oyun bu aralıkta "yönetici + İK" katmanıyla oynanıyor. Bir inceleme yazarı hiç 38'den fazla çalışan gerekmediğini belirtti. Bu bir tek oyuncunun deneyimi; genelleme değil.

**Şikayetler.**
- "Gelişmiş tıklama oyunu" ve elle üretim atamasının sıkıcılığı (2018 konusu: https://steamcommunity.com/app/606800/discussions/0/1733216261946671541). Satış temsilcisi mikro yönetimi en çok anılan dert. Eğitim "ürkütücü" bulunmuş; üretimi ölçeklemek için çok fazla kişi eğitmek gerekiyor.
- Ruh hali mikro yönetimi: tatil/ikramiye döngüsü sıkıcı; bir oyuncu 180 çalışanla her biri için "ikramiye öde" tıklamaktan bıktı. Yöneticilerin kendisi ayrılmaya kalkıyor ve zam pazarlığını otomatik kabul etme isteniyor (https://steamcommunity.com/app/606800/discussions/0/1648791520844239734).
- Ruh hali çürümesi: oyuncular %15 daha yavaş çürüme istedi; geliştirici "yavaşlatalım mı?" diye sordu, cevap vermedi. Oyun ilerledikçe çürüme yavaşlıyor (oyuncu gözlemi).
- Erken oyun yavaş ve zor (https://steamcommunity.com/app/606800/discussions/0/3046104336679215068). Beta 17 geçişinde birçok şirket kısa sürede iflas etti (Devlog #26).
- Yorumlar: Steam'de 2.898 İngilizce yorumun %80'i olumlu (mağaza sayfası). Beta 14 döneminde puan %89'dan %64'e, Nisan 2018'de %76'dan %67'ye düştü (Devlog #8, #15).
- Konsol incelemesi: personel az/çok sinyali yok, olaylar az (gamesasylum).

**İstismarlar.** Doğrudan istismar yazısı bulunamadı. Dolaylı: oyuncular "yükseltme, yeni al" arasında yeni alımı seçiyor (yükseltilen çalışan pahalı ve talepkâr olur); toplu tatil/yedek stok ile ruh hali mikro yönetimi aşılıyor.

**Geliştiricinin yanıtları (tasarım gerekçeleri).**
- Beta 14 hedefi "tıklamayı azaltmak" (Beta 14 duyurusu). Devlog #15: "önce tıklamayı azaltıp otomasyon eklemek".
- WER karışıklık yarattığı için kaldırıldı, yerine "dilekler" geldi (Beta 15).
- İkramiye bilinçli olarak son çare; asıl çözüm istekleri karşılamak ve İK (yukarıdaki geliştirici cevabı).
- Yeni özellikler yönetici/İK katmanına yük bindirmek yerine onların yetkisini genişletti: toplu çalışan menüsü (Beta 22), ortak üretim planı ve CEO'nun İK yapabilmesi (Beta 24), toplu zam ve toplu ikramiye (Beta 26, v1.0), zam teklifinin İK'ya devri (v1.0).
- Geri bildirim kanalı: ideas.startupcompanygame.com (Conflux).

---

## 5. Bizim için

**Alınacak.**
1. Envanter göstergesi: "tüketim / talep / üretim" üçlüsü. Bizde hat ve kart için karşılığı: her hatta bekleyen iş yükü, kimin işi yükleniyor, hangi aşama (tasarım/geliştirme/test) tıkanıyor. Gerekçe: Startup Company bunu Beta 27'ye kadar geç ekledi ve en çok istenen şeylerden biri oldu.
2. Kapasiteyi seviye ile ölçeklemek: yönetici 3 / 5 / 8. Bizde PM için "kaç hattı/kaç kişiyi yürütür" yıldız (beceri/2) ile ilişkilendirilebilir. Sabit "çalışan başına %5" yerine kişinin seviyesinden türeyen tavan. Gerekçe: aynı roldeki 10 kişide sabit yüzde oyunu bozar; kademeli kapasite bunu önler.
3. Hız = kişinin kendi yüzdesi (baz hız, tavan, eğitimle büyüme). Bizim beceri 0-10 ölçeğiyle uyumlu.
4. İsteklerin (demands) ruh halini beslemesi ve ikramiyenin bekleme süresi (30 gün) olması: "bedava düzeltme" bırakmamak için. Bizde 1 tik = 1 hafta olduğundan bekleme süresi tik cinsine çevrilmeli (örn. ~4 tik); sayıyı bu araştırmadan çıkarmak doğru değil.
5. Ortak planı/tekrarlayan kuyruğu: oyuncunun her hafta aynı kararı yeniden vermesini önlemek için "sürekli sprint hattı" benzeri kalıcı ayar.

**Alınmayacak.**
1. Tek tek tıklanan ikramiye ve tek tek tatil: 180 çalışanda şikayet konusu oldu. Bizim ölçekte (20-50+) toplu işlem şart.
2. Her çalışan için elle üretim ataması: geliştiricinin kendisi bunu ilk yıllarda bırakmaya çalıştı.
3. Bileşen -> modül -> özellik zincirini birebir: bizim "hat -> K1/K2/K3 kart -> tasarım/geliştirme/test" yapımız zaten daha az ayrıntılı ve oyuncuya daha okunaklı. Startup Company'nin zinciri "malzeme tüketen bir fabrika"; bizim oyun karar odaklı bir yönetim oyunu.

**Uyarlanacak.**
1. Yönetici kuralları: bir çalışan en çok bir yöneticiye bağlı; yöneticinin üstünde bir "İK/müdür" katmanı. Bizim PM/destek/Ar-Ge rollerine çevirirken "bir kişi en çok 2 iş" kuralıyla çakışma olmasın diye tek bağlanma kuralını koruyun.
2. Yönetici başına bonus: rakamı bulunamadı. Biz kendi tablomuzu çıkarmalıyız; yönetilen kişi sayısı arttıkça kişi başı bonusun azalması fikri (oyuncu anlatımı) alınabilir ama formül tasarlanmalı.
3. Memnuniyet modeli: temel özellikler memnuniyet üretir, gelir özellikleri memnuniyetsizlik üretir (Beta 25). Bizim B2B/B2C memnuniyet düşüren açık hata modeliyle birlikte, "gelir tarafı özellik memnuniyeti düşürür" fikri koltuk fiyatı/üyelik için işe yarayabilir.
4. Destek biletleri: karmaşıklık sınıfı + çözüm süresi (36 saat) + uzman kişinin kolay işte mutsuzlaşması. Bizim destek rolü (müşteri temsilcisi) için doğrudan uyarlanabilir.

---

## 6. Bulunamayanlar

- Topluluk wiki'si (fandom) okunamadı: rol tabloları, özellik (trait) listesi, yönetici bonus yüzdeleri, bileşen ve modül süreleri, özelliklerin tam gereksinim listeleri.
- Yöneticinin hız bonusunun tam yüzdesi ve kişi başına azalma formülü.
- "UI Component x3" gibi gereksinim metninin ekrandaki birebir biçimi (mağaza ve rehberlerde görseller halinde).
- Yazılım hatası (bug) mekaniği: yok olduğu için bulunamadı; kesin değil.
- Reddit r/startupcompanygame içeriği (erişim engelli). Büyük çalışan sayılarında (60+) oynanış ayrıntısı bu yüzden zayıf.
- İstismar listesi.
- Steam rehberlerinden Rusça temel rehber (id=1622810145) ve Japonca rehber (id=3101509626) "429 Too Many Requests" döndürdü; okunamadı.
- Yönetici kapasitesi 3 / 5 / 8 bir mod rehberinden (TreePlan) geliyor; temel oyunla aynı olduğu doğrulanamadı.


---

## 7. Tamamlama (2026-10-17, başsız Chrome)

Kaynak durumu: startupcompany.fandom.com başsız Chrome ile açıldı (yaklaşık 25 sayfa okundu). Önceki bölümdeki "wiki okunamadı" notu artık geçerli değil. Uyarı: wiki'nin Change Log sayfası Beta 17.0'da (24 Ağustos 2018) bitiyor; yukarıdaki Steam duyuruları ise Beta 29'a kadar gidiyor. Yani wiki sayfaları 2018 civarının oyununu anlatıyor olabilir; aşağıda "wiki" diye işaretlenenler topluluk bilgisidir, resmi değildir. Sayfaların bazıları kendi içinde de tutarsız (aşağıda işaretli). Wiki'de ayrı bir Bugs, Satisfaction, Hosting-formülü ya da Traits sayfası yok (Special:AllPages listesi: https://startupcompany.fandom.com/wiki/Special:AllPages , 38 sayfa).

### 7.1 Yönetici ve lead kuralları (kapanan boşluk: bonus yüzdesi, kapasite)

- Yönetici kapasitesi wiki'de de aynı: Beginner 3, Intermediate 5, Expert 8 çalışan. Bu, §2.3'te "bir modun rehberinden, doğrulanamadı" dediğim sayıyı temel oyun için doğruluyor. Kaynak: https://startupcompany.fandom.com/wiki/Manager
- Bonusun biçimi (wiki, Manager sayfası): yönetici, kadrosundaki herkese bir üretkenlik bonusu verir; bu bonus yöneticinin o an fiilen yönettiği kişi sayısına eşit bölünür. Bonus yöneticinin kendi üretkenlik düzeyine bağlıdır. Sayfadaki örnek: üretkenliği %500 olan bir yönetici tek kişiyi yönetirse o kişiye %500, iki kişiyi yönetirse ikisine %250'şer verir. Yönetici evdeyse (izinde) bonus uygulanmaz. Kaynak: https://startupcompany.fandom.com/wiki/Manager . Bu, §2.3'teki "kişi başı bonus azalır, formül bulunamadı" cümlesini somutlaştırıyor: formül "yöneticinin bonusu / yönetilen kişi sayısı". Sayfa tek örnek veriyor; yöneticinin %500'ü nasıl oluştuğunu söylemiyor, güncel sürümde geçerli mi doğrulanamadı.
- Yöneticisiz durum (wiki): bir yöneticinin kadrosundaki üretim çalışanı, yöneticinin atadığı üretim planını izler; plan yoksa çalışan boşta bekler. Satış yöneticisi ve araştırmacı gibi üretim dışı çalışanların plana ihtiyacı yok. Yöneticisiz çalışanın ayrıca bir ceza aldığına dair bir şey yazmıyor; yalnız yönetici bonusunu kaybeder. Kaynak: https://startupcompany.fandom.com/wiki/Manager ve https://startupcompany.fandom.com/wiki/Employees
- Yönetici açılış koşulu: Tier 3, 400 RP. İK Yöneticisi: Tier 7; kapasitesi yönetici sayısı olarak Beginner 3, Intermediate 5, Expert 8. İK yöneticisi çalışanların çalışma saatini ve izinlerini toplu ayarlar. Kaynak: https://startupcompany.fandom.com/wiki/HR_Manager (aynı sayfada İK'nın tanımı yanlışlıkla "arayüz bileşeni üretir" diye geçiyor; sayfa kopyala-yapıştır hatası taşıyor, işlevi kısmı doğru).
- Çalışma saatinin ruh haline bedeli (wiki, İK ile ayarlanır): günlük ruh hali düşüşü 3 saatte %1,3; 4 saatte %1,8; 5 saatte %2,2; 6 saatte %2,6; 7 saatte %3,1; 8 saatte %5,1; 9 saatte %7,6; 10 saatte %10,4; 11 saatte %25,1; 12 saatte %30,9; 14 saatte %44,3; 16 saatte %60; 18 saatte %98,6; 24 saatte %182,9. Eğri 8 saatten sonra hızla dikleşiyor, 10'dan 11'e sıçrama var (%10,4 -> %25,1). Kaynak: https://startupcompany.fandom.com/wiki/Employees
- Çalışan üretkenliği dört terimin toplamı (wiki): işe alınırken sabit "baz hız" (sonradan değişmez), ofis bonusu (mobilya), yönetici bonusu (yönetici izinde değilse), ruh hali cezası ("en büyük etken"; izne gönderilince 0'a döner). Bir çalışan çıkarılınca diğer herkes çıkarılan başına -%5 ruh hali cezası alır. İzin: 3 gün, çalışan ayrıldığı saate döner ve duran işe devam eder. Kaynak: https://startupcompany.fandom.com/wiki/Employees
- Çalışan türleri (wiki, 12): Researcher, Developer, Designer, Lead Developer, SysAdmin, Sales Executive, Marketer, Manager, HR Manager, Supporter, Recruiter, Outsourcing Executive. Açılış kademeleri: Developer ve Sales Executive oyun başında, Designer Tier 2, Manager Tier 3, Lead Developer Tier 4, Researcher Tier 5, SysAdmin Tier 6, İK Yöneticisi Tier 7, Marketer Tier 8. Kaynak: ilgili sayfalar, örneğin https://startupcompany.fandom.com/wiki/Lead_Developer

### 7.2 Bileşen -> modül -> özellik zinciri: süreler ve gereksinim biçimi (kapanan boşluk: "Fiyatlar ve süreler bulunamadı")

Tüm süreler "baz üretim süresi"; Getting Started sayfasına göre gerçek süre = baz süre / çalışanın hız yüzdesi. Kaynak: https://startupcompany.fandom.com/wiki/Getting_Started

- Developer bileşenleri (seviye: süre): Beginner: UI (2 sa; sayfada adı boş kalmış ama Landing Page sayfası UI Component 2 sa diyor), Backend 4, Network 6, Database 4, Video 14. Intermediate: Semantic 3, SMTP 8, Encryption 8, Filesystem 4. Expert: I18n 4, Search Algorithm 12, Compression 8. Kaynak: https://startupcompany.fandom.com/wiki/Developer
- Designer bileşenleri: Beginner: Blueprint 2, Wireframe 3, Graphics 4, UI Element 6. Intermediate: UI Set 18, Responsive UI 18. Expert: Documentation 12, Design Guidelines 90. Kaynak: https://startupcompany.fandom.com/wiki/Designer
- Lead Developer modülleri: Beginner: Interface 15, Frontend 21, Backend 10, Input 6, Storage 8, Content Management 37, Video Playback 45. Intermediate: SEO 24, Email 12, Database 14, Notification 18, Authentication 22. Expert: Payment Gateway 76, Localization 25, Search 20, Bandwidth Compression 18, Code Optimization 90, ApiClient 40. Kaynak: https://startupcompany.fandom.com/wiki/Lead_Developer
- SysAdmin (eski adı DevOps) bileşenleri: Beginner: Virtual Hardware 4, Operating System 4, Firewall 4. Intermediate: Process Management 6, Continuous Integration 8, Cron Job 3. Expert: Virtual Container 25, Cluster 115, Swarm Management 140. Kaynak: https://startupcompany.fandom.com/wiki/SysAdmin
- Marketer bileşenleri: Beginner: Copywriting 4, Text Format 4, Image Format 4, User Feedback 8, Survey 4, Phone Interview 6. Intermediate: Video Format 8, Audio Format 8, Analytics Research 12. Expert: Contract Agreement 12, A/B Testing 10, Behavior Observation 12. Kaynak: https://startupcompany.fandom.com/wiki/Marketer
- Seviye kuralı: tabloda "Level Required" sütunu var; yani Beginner çalışan yalnız Beginner kalemleri üretir, Expert kalem Expert çalışan ister. Bu, "kişi seviyesi = hangi işi yapabileceği" için doğrudan bir kural örneği.
- Özellik gereksinimi ekranda nasıl yazılıyor (kapanan boşluk: "UI Component x3 biçimi"): wiki'nin özellik sayfaları üç düzeyli bir döküm veriyor ve sütunları "Nr | Required Modules | Employee | Base Prd. Time" (adet, gereken parça, kim üretir, baz süre). Örnek, Comment Functionality: Ana gereksinim "3 Backend Module (Lead Developer, 10 sa), 3 Input Module (Lead Developer, 6 sa)"; toplam bileşen dökümü: 6 Backend Component, 3 Network Component, 3 UI Component (Developer); toplam süre: Lead Developer 48 sa, Developer 48 sa. Kaynak: https://startupcompany.fandom.com/wiki/Comment_Functionality . Bir başka örnek: Video Functionality toplam süre Lead Developer 142 sa, Designer 105 sa, Developer 24 sa (https://startupcompany.fandom.com/wiki/Video_Functionality). Landing Page: 1 UI Component (Developer, 2 sa), 1 Backend Component (Developer, 4 sa), 1 Blueprint Component (Designer, 2 sa), 1 Graphics Component (Designer, 4 sa) (https://startupcompany.fandom.com/wiki/Landing_Page). Oyun içi ekranın görüntüsünü göremedim; bu, wiki'nin kendi dökümü. Göstermenin bize dersi: parça başına "kim üretir" ve "kaç saat" birlikte yazılıyor ve rol başına toplam saat ayrıca özetleniyor; yani kartın ihtiyacı rol bazında toplanıyor.
- Özellik araştırma tablosu (wiki, Researcher sayfası): her özellik bir "hype" yüzdesi ve bir CU yükü taşıyor, ayrıca araştırma çevrimi sayısı var. Örnekler: Landing Page +%10 hype, 50 CU, 28 çevrim; Login System +%14, 49 çevrim; Comment +%18, 66; Payment System +%20, 168; Video Functionality +%26, 184; Screen Capturing +%25 hype ve 100 CU, 435; Live Streaming +%45 hype ve 75 CU, 682; Server Redundancy +%15 ve 5 CU, 242; Intrusion Prevention System +%50 ve 25 CU, 693. "CU" sütununun birimi (kullanıcı başına mı, toplam mı) sayfada yazmıyor. Gereksinim listeleri de var (örneğin Payment System: 4 Backend Module, 2 Email Module, 4 Payment Gateway Module). Uyarı: bu sayfadaki Landing Page gereksinimi ("2 Frontend Module, 1 Input Module") Landing_Page sayfasındaki ("4 bileşen") ile uyuşmuyor; sayfalar farklı sürümlerden. Change Log, Beta 15.1 ve Beta 17.0'da özellik yükseltme gereksinimlerinin ve araştırma puanı gereksinimlerinin değiştirildiğini söylüyor. Kaynak: https://startupcompany.fandom.com/wiki/Researcher
- Framework tablosu (wiki): özellik yuvası ve azami seviye framework'e bağlı. Cute Framework Basic: lisans $0, 3 özellik, azami seviye 10, 0 RP. Cute Framework 1.0: $60.000, 3 özellik, seviye 40, 200 RP. Nitrosoft Platform 2005: $100.000, 3, 60, 300 RP. Cute Framework 2.0: $300.000, 6 özellik, seviye 500, 500 RP. Cute Framework 3.0: $780.000, 9 özellik, 2000, 1200 RP. Nitrosoft Platform 2008: $1,2 milyon, 9, 3500, 2500 RP. Cute Framework 4.0: $1,8 milyon, 9, 4000, 3500 RP. Nitrosoft Platform 2016: $4,9 milyon, 9, 5000, 6000 RP. Fusion Framework: $80 milyon, 12 özellik, 7000, 20.000 RP. (Sayfada iki satır aynı adı taşıyor, "Nitrosoft Platform 2005", ikincisi $500.000 / 6 özellik / 1000 / 700 RP; ad hatası olabilir.) Kaynak: https://startupcompany.fandom.com/wiki/Frameworks
- Üretim planı (wiki): plan, bileşen/modül başına en az ve göreli seviye belirler; aynı planı kullanan tüm yöneticiler ortak hedefe çalışır; plan çalışan türüne göre ya da özelliğe göre (çok disiplinli ekip) kurulabilir. Seçenekler: hedefe ulaşınca aynı oranda üretmeye devam; ön koşul eksikse o modülü atla, yoksa çalışan bekler. Kaynak: https://startupcompany.fandom.com/wiki/Production_plan

### 7.3 Sunucu ve hosting (R6 ile ortak; kapanan boşluk: sunucu tablosu, CU, maliyet)

- Altyapı modeli (wiki, Servers sayfası): üç sunucu türü (Web, Database, Cache), her türün dört boyutu. CU yalnız üç tür birlikte kullanılınca üretilir ve dengeli olmalı, yoksa fazlası boşa gider. Tablo ("Data it Produces" / raf birimi U / satın alma / kurulum başına "configuration cost" / aylık güç): Web: Small 200 / 1U / $10.000 / 2 / $375; 2U 650 / 2U / $25.000 / 4 / $675; 4U Blade 2500 / 4U / $150.000 / 15 / $1200; 8U XServer 21.000 / 8U / $800.000 / 32 / $2100. Database: Small 300 / 1U / $10.000; 2U 800 / $30.000; 4U 4000 / $150.000; 8U XServer 30.000 / $800.000 (sayfada bu satırın adı "48 Cache XServer" diye bozuk). Cache: Small 500 / $10.000; 2U 1200 / $30.000; 4U 5000 / $150.000; 8U 42.000 / $800.000. Aynı boyutta yapılandırma ve güç değerleri türler arasında aynı. "Configuration cost" SysAdmin bileşeni adedi gibi görünüyor: sayfadaki 6 küçük sunucu için "12 Firewall, 12 Virtual Hardware, 12 Operating System" gerekiyor (6 x 2). Kaynak: https://startupcompany.fandom.com/wiki/Servers
- Doluluk/aşım: sayfadaki "verimli başlangıç" örneği 3 küçük Web + 2 küçük Database + 1 küçük Cache: toplam $61.600 (küçük raf dahil), aylık güç $2250, bant genişliği $2800, 7000 CU; Cache'i %20 hız aşırtınca 8400 CU, güç $2325, bant $3360. Sayfa "web ve database'te 100'er boşa gider" diyor (üç türün en küçüğü sınırı belirliyor). İki raf: 16.800 CU, "günde $175"; barındırma (hosted) seçeneği 15.000 CU için günde $900. Uyarı: sayfa kendi içinde tutarsız ("Data it Produces" sayısıyla CU arasındaki çarpan açıklanmamış; tablodaki aylık güç ve bant rakamları günlük $175 ile uzlaşmıyor), ve Beta 16 raf modeline ait. Aşım cezası (kullanıcı CU'yu aşınca ne olur) wiki'de yok. Kaynak: https://startupcompany.fandom.com/wiki/Servers
- SysAdmin (wiki): ürünün kullanıcı tabanı büyüdükçe daha çok sanal sunucu gerekir; bu bileşenleri SysAdmin üretir; durum ürünün "Hosting" sekmesinden izlenir. Kaynak: https://startupcompany.fandom.com/wiki/SysAdmin . Getting Started: sağ kenardaki ürün listesi "ad, sıralama, hosting kullanımı, potansiyel kullanıcı, kullanıcı değişimi"ni tek bakışta gösteriyor; Stats sayfası büyüme, gelir ve sunucu kullanımını gösteriyor. Kaynak: https://startupcompany.fandom.com/wiki/Getting_Started
- Change Log'dan sunucu satırları: Beta 15.0 "sanal küme (virtual cluster) için sunucu gereksinimi azaltıldı, fiyat artırıldı", "potansiyel kullanıcı kayıtlı kullanıcıdan düşükse kullanıcı kaybı hızı artırıldı"; Beta 16.0 hosting binaları, raflar ve sunucular eklendi; Beta 16.2 "hosting ekipmanının ofise konabilmesi hatası" düzeltildi (ekipman hosting binasına ait); Beta 16.6 bodrum hosting binası $10k'dan $20k'ya çıktı; Beta 17.0 "izin verilen azami sanal sunucu sayısını aşma hatası" düzeltildi. Kaynak: https://startupcompany.fandom.com/wiki/Change_Log
- Hosting maliyeti ile kullanıcı başına yük formülü ve CPU/RAM ayrımı wiki'de de yok. Sayfalarda "CU" tek birimdir; CPU/RAM ayrımı bulunamadı.

### 7.4 Kullanıcı memnuniyeti, hata (kapanan boşluk: yok yanıtı doğrulandı)

- Wiki'de memnuniyet ya da hata için ayrı sayfa yok. Change Log yalnızca şunu söylüyor: Beta 17.0 "ürün memnuniyeti eklendi", "sözleşme işi kaldırıldı" (Contract Work), "memnuniyet değişkeninin getirdiği ürün ilerleme kaybı dengelendi". Milestone 8 "en az %75 memnuniyete ulaş" diye bir hedef taşıyor. Kaynak: https://startupcompany.fandom.com/wiki/Change_Log ve https://startupcompany.fandom.com/wiki/Milestones
- Bu yüzden §2.4'teki "Startup Company'de yazılım hatası mekaniği yok" cümlesi wiki ile çelişmiyor ama wiki da onu doğrulamıyor; yalnız bulunamadı. Wiki'deki "bug" geçen her satır oyunun kendi hataları için.
- Destek (wiki): Supporter, kendi bilet kuyruğundaki destek biletlerini çözer; erken oyunda bir destekçi yeter; oyun ipuçları farklı karmaşıklık için farklı seviyede destekçi ister. Kaynak: https://startupcompany.fandom.com/wiki/Supporter

### 7.5 Ekonomi, işe alım, ofis (bizim işimizle ilgili kısım)

- İlan maliyeti (wiki): işe alım ilanı seviyeye ve süreye göre. 1 gün: Beginner $1760, Intermediate $4000, Expert $9600. 3 gün: $5280 / $12.000 / $28.800. 7 gün: $12.320 / $28.000 / $67.200. Başvuran adaylar 24 saat işe alınabilir kalır; bir ilandan alınabilecek kişi sayısının üst sınırı yok. Intermediate ve Expert Beginner'dan çok daha nadir. Kaynak: https://startupcompany.fandom.com/wiki/Employees
- Pazarlık (wiki): aday ekranında aylık maaş ve imza ikramiyesi teklif edilir; aday kabul eder ya da karşı teklif yapar; adayın yanında bir yüz ifadesi var, ifade kötüleştikçe pazarlığa isteği azalır ve düşük teklif adayı kırar, yeterince düşerse aday gider. Önerilen strateji: karşı teklifin ve teklifin ortasından devam etmek. Beginner için başlangıç teklifi $4000-5000. Intermediate ve Expert için maaş beklentisi ve talepleri araştırılabilir. Kaynak: https://startupcompany.fandom.com/wiki/Negotiation . Bu, "kabul olasılığını sayıyla göstermeyip yüz ifadesiyle göstermek" için ilginç bir örnek (R7 ile ilişkili).
- Yan haklar (wiki, aylık çalışan başına maliyet / bonus): Small Retirement Plan $150 / %5 (Tier 3); Free Beverages $130 / %5 (Tier 5); Free Gym $30 / %2 (Tier 8); Extended Retirement $300 / %10 (Tier 9); Free Health Care $240 / %10 (Tier 11); Full Retirement $360 / %5 (Tier 13); Paid Transportation $210 / %3 (Tier 15). Ofis: Small $10.000 peşin, $3000/ay, 8 masa; Medium $35.000, $6000/ay, 20 masa; Large $100.000, $22.000/ay, 50 masa. Tier atlama XP'leri: Tier 2 için 200 XP, Tier 3 için 800, Tier 5 için 5000, Tier 10 için 90.000, Tier 20 için 500.000. Kaynak: https://startupcompany.fandom.com/wiki/Company_Profile . Ölçek notu: ofis tavanı 50 masa; §4'te anılan gökdelen ve 400 kişilik ofisler bu sayfada yok (sonraki sürüm).
- Krediler: Eazy Money $40.000, 365 gün, %30 faiz (günlük $128,20); Global Loans $70.000 (Tier 3); Fever Inc $120.000, %25 (Tier 5). Hesap -$10.000'ı geçerse oyun devam etmez. Kaynak: https://startupcompany.fandom.com/wiki/Finances
- Milestone ödülleri 25 hedefte $5.000'den $3.000.000'a büyüyor (örnek: kullanıcı sayısı 2000 -> $30.000; 100.000 kullanıcı -> $150.000; 1.000.000 kullanıcı -> $500.000; 10.000.000 kullanıcı -> $1.000.000). Hedef adımları "oyuncuyu sıradaki ölçeğe çeken" bir merdiven örneği. Kaynak: https://startupcompany.fandom.com/wiki/Milestones
- Satış yöneticisi (wiki): aynı anda yalnız bir sözleşmeyi yönetir; sözleşme bulur, oyuncu etkileşimi "Negotiate" ekranı (web sitesi, reklam türü, zaman dilimi, garanti edilen gösterim sayısı, süre). Sayfa kendisi "eksik, sayı ve denklem yok" diye işaretli. Kaynak: https://startupcompany.fandom.com/wiki/Sales_Executive

### 7.6 Bu tamamlamanın §6 listesine etkisi

- Kapandı: rol tabloları (türler, açılış kademeleri), yönetici kapasitesi ve bonus biçimi, bileşen/modül/özellik süreleri ve gereksinim biçimi, sunucu türleri ve maliyetleri, özellik yuvası/seviye tavanı.
- Hâlâ bulunamadı: trait listesi (wiki'de sayfa yok), yöneticinin bonus yüzdesinin sayısal kaynağı (örnek %500 nasıl çıkıyor), Beta 23 sonrası değişen kurallar (wiki 2018'de kalmış), sunucu CU aşım cezası ve kullanıcı başına CU yükü, memnuniyet formülü, Reddit içeriği (bu turda denenmedi), Steam rehberlerinin 429 veren üçü.

### 7.7 Ekran görüntüleri: Steam mağazasından, içerikleri gözle okundu (kapanan boşluk: "ekranın birebir biçimi")

Aşağıdaki sekiz görüntünün içeriğine baktım (dokuzuncuyu açmadım). Sıra mağaza sırası. Görüntüler Startup Company'nin güncel arayüzünü gösteriyor (gün 862, yıl 18). Hepsi 1920x1080.

1. Ofis ekranı: https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/606800/ss_74de0b0d767febb4e7d11406b38e199884f3d678.1920x1080.jpg?t=1727681373 . Her çalışanın masasının üstünde isim, rol ikonu, "hız" göstergesi (örnek "474/472", yani güncel/tavan), ruh hali yüzdesi (%100, %66, %94...) ve tek satır durum: "FIREWALL (0%)", "INPUT MODULE (85%)", "GRAPHICS COMPONENT (0%)", "MANAGING 3 EMPLOYEES", "WAITING FOR TICKET", "RESEARCHING", "CONTRACT #16". Yani ne üretildiği ve işin yüzde kaçta olduğu çalışanın üstünde okunuyor; yönetici etiketi kaç kişiyi yönettiğini söylüyor ("MANAGING 2 EMPLOYEES", "MANAGING 3 EMPLOYEES"); destekçi "WAITING FOR TICKET" (bilet bekliyor = boşta) diyor. Üst çubukta gün, saat, araştırma puanı ve para; sağda ürün kartı (sıra #44, %100, %0, kalabalık ikonlu %70 (anlamı yazılı değil, memnuniyet olabilir), değişim "0"; sonraki ekranda üçüncü rozet sunucu doluluğuyla birlikte %39 oluyor) ve "Next milestone: Acquire at least 1 competitor(s)".
2. Ürün Stats penceresi: https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/606800/ss_60b0b2a8fb13081564c418913f9afbebe78c3562.1920x1080.jpg?t=1727681373 . Sekmeler: Stats, Features, Hosting, Marketing, Venture C..., Support. "Right now 55,731 Online users", "Server Usage" yarım daire kadran %39 ve altında "Response Time 204ms" (yeşil), tahmini günlük gelir "$308.14K ($358.40K)", Registered Users 10,06M, Potential Users 14,33M, All Expenses -$50,260, Valuation $97,99M; altta Online users (saat bazında) ve Registered Users (gün bazında) grafikleri. Yani sunucu doluluğu tek kadran + gecikme (ms) olarak gösteriliyor.
3. Sunucu odası: https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/606800/ss_0c096a49947a394216f9a51da8caf32943cce330.1920x1080.jpg?t=1727681373 . Rafların üstünde "LARGE RACK 42/42U" etiketleri (yer doluluğu); altta "Webserver 1.400M | Cache 1.400M | Database 1.676M | Produced CU 19.60M | Temperature 4 C | RACKS" şeridi.
4. Raf penceresi: https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/606800/ss_ea1b02a0c8163011799d16b7216a4b1dd46dabc9.1920x1080.jpg?t=1727681373 . "Large Rack" (UPGRADE etiketli): Consumed Power 87.000 W, Rack Temperature 56 C, Total Web Server Throughput 10.000, Total Database Throughput 12.000, Total Cache Throughput 10.000; "ADD DEVICE" ve "DUPLICATE ($1,374,000)" düğmeleri. Altta sunucu odası özeti: Webserver 280.000K, Cache 280.000K, Database 328.000K, Produced CU 3,92M. Yani CU = üç türün en küçüğü (10.000, 12.000, 10.000 raf verimi) ve tür başına yük ayrı gösteriliyor.
5. Şehir haritası: https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/606800/ss_4c4ba1c4f5e041fbb10b29be458b9cbedec34df3.1920x1080.jpg?t=1727681373. Binalar adres etiketli; türü "OFFICE", "HOSTING", "INVESTMENT PROJECT".
6. Lead Developer penceresi: https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/606800/ss_8dac9adb157819ab46d7d360ac63f8f61b75e5c1.1920x1080.jpg?t=1727681373 . Başlıkta rol (LEAD DEVELOPER), hız yüzdesi (601%), güncel iş (INPUT MODULE); "Controlled by Peter Schultz" bandı (yöneticisi); modül ikonları ızgarası, her ikonun üstünde envanter sayısı (143, 144, 142...; kilitli olanlar "Locked" ve 0); altta güncel işin ilerleme çubuğu (%66) ve gereken bileşenler "1 (566)" ve "1 (562)" biçiminde: gereken adet ve parantez içinde depodaki stok. Bu, bizim "kartın ihtiyacını söylemek" sorusuna doğrudan cevap: gereksinim "adet (stok)" olarak ikonla gösteriliyor.
7. Satış yöneticisi pazarlık penceresi: https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/606800/ss_8b07098ae4dfbdc86c9caebf44c498bf8b5bf71f.1920x1080.jpg?t=1727681373 . Sol "TERMS": Website, Type (Banner Ads #2), Time slot, Impressions yesterday 31.202.833, Guaranteed impressions 22.000.000 (kaydırıcı), Contract length 10 days, Offer $6,60/CPM, Penalty Fee 20%, Daily Payment $145.200; düğmeler CANCEL, ACCEPT CONTRACT, NEGOTIATE. Sağ "NEGOTIATION": karşı tarafın teklifleri sohbet balonlarıyla ("MeetyMe offered $7.30/CPM", "$7.40", "$7.50") ve her teklifin yanında bir yüz ifadesi (yeşil gülen yüz, sonra nötr yüz) ; "You offered $9.40/CPM, $9.30/CPM"; teklif kaydırıcısı $9.30/CPM, altında "$204.600/day" ve Cheap / Average / Expensive üç renkli bir şerit; "ACCEPT OFFER" yeşil düğmesi karşı teklifin yanında; LEAVE NEGOTIATION ve SEND OFFER. Yani kabul olasılığı sayıyla değil yüz ifadesi ve "pahalı/ucuz" şeridiyle gösteriliyor.
8. Hosting sekmesi: https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/606800/ss_12d04b8d057121d1ce7214576367925bb2ea32aa.1920x1080.jpg?t=1727681373 . Total CU 2.680.600; Used CU 1.105.648; Free CU 1.574.952; Peak CU 1.295.087 (RESET düğmesi); kadran %41; sağda üç kademeli kırmızı-sarı-yeşil bir şerit "Critical / Unstable / Stable" ve ok "Stable"da; Response Time 210 ms. Altında bulut sunucu türleri: FASTCLOUDS MINI CLOUD SERVER (+500 CU, $40/gün), PRO (+1600 CU, $110/gün), ULTRA (+15000 CU, $900/gün); her biri "ADD INSTANCE / REMOVE INSTANCE" düğmeli, kaç adet olduğu ve her adedin gerektirdiği SysAdmin bileşenleri ikon+"gereken (stok)" biçiminde (örnek "2 (22)"). Bu, §7.3'teki wiki'nin "hosted: 15.000 CU günde $900" cümlesinin güncel karşılığı: ULTRA +15.000 CU, $900/gün. Kullanıcı başına CU yükü bu ekranlarda görünmüyor.
9. Dokuzuncu görüntü (açmadım): https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/606800/ss_4a61b4efcb7cfd390e2433cb66db079349b7890c.1920x1080.jpg?t=1727681373
