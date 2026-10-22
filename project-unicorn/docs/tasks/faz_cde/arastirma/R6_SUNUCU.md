# R6 — Sunucu, kapasite ve doluluk (Faz C)

Hazırlanış: 2026-10-17. Kaynak kuralı: her iddianın yanında URL var. "(kaynaksız, model bilgisi)" yazanlar kaynağı olmayan bilgidir. "(hesap)" yazanlar kaynaklı sayılardan benim yaptığım aritmetiktir. Fandom wiki'leri (Startup Company ve Software Inc. wiki'si) 402 verdi, Reddit ve web.archive.org araçta kapalıydı; bu yüzden oyun mekaniği Steam forum konularından ve rehberinden derlendi. Ayrıntı "Bulunamayanlar" bölümünde.

## 1. Özet

1. **Doluluk iki oyunda var, ikisinde de ana bulmaca; ama en çok mikro yönetim şikâyetini de o üretiyor.** Startup Company'de üç sunucu türünü (Web/Cache/DB) dengelemek ve ısıyı yönetmek zorunlu. Geliştirici bunu bilerek "gerçek dünyayı simüle etmek için" bırakmış, oyuncular otomatik denge istiyor. Game Dev Tycoon, Mad Games Tycoon ve Mad Games Tycoon 2'de doluluk yok, yalnızca yinelenen bakım gideri var.
2. **Hiçbir oyunda gerçek otomatik ölçekleme bulunamadı.** En yakını Startup Company'deki "Centralized Clockrate Controller" (yarı otomatik) ve Software Inc.'deki sunucuları kabloyla birleştirme. Oyuncular yük dengelemeyi istek olarak yazmış.
3. **Doluluğun cezası iki oyunda da "bir şey bozulur" değil, "yanıt süresi artar, müşteri/sözleşme kaybedilir" biçiminde.** Startup Company'de %120-130 yükte 700-800 ms; Software Inc.'de dağıtım kanalı çalışmıyor. Kesinti olasılığını doluluktan hesaplayan bir formül hiçbir kaynakta bulunamadı; bu sizin tasarım kararınız olacak.
4. **Gerçek dünyada altyapı gelirin %8-20'si civarı (satıcı blogu rehberi, bağımsız doğrulanmamış).** a16z'nin kamuya açık yazılım şirketleri için bulduğu "bulut harcaması maliyet kaleminin %50'si" ile brüt marj %65-72 birleşince (hesap) gelirin yaklaşık %14-17'si çıkıyor; iki kaynak birbirini tutuyor.
5. **Sizin sayılarınız gerçeğe göre ucuz.** B2C'de altyapı gelirin %0,8-1,9'u, B2B'de %1,7-4,0'ı (hesap). Gerçek rehber değerleri B2C benzeri düşük hesaplı ürünlerde %8-15, B2B kurumsal müşteri başına %1-6. Yani B2B Kurumsal makul, B2C yaklaşık 4-19 kat ucuz.
6. **Kesinti çarpanı gerçeğe göre çok yumuşak.** SLA kademeleri arasında izin verilen kesinti süresi 99,5 → 99,9 arası 5 kat, 99,9 → 99,99 arası 10 kat azalıyor. Heroku Postgres'te kademe başına 4 kat (aylık 4 saat / 1 saat / 15 dakika). 1,0 / 0,8 / 0,5 yalnızca 2 kat. Gerçekçi aralık yaklaşık 1,0 / 0,25-0,4 / 0,06-0,15 (kademe başına 2,5-4 kat; model önerisi).
7. **Maliyet de kademeyle birlikte basamaklı artıyor:** Heroku'da paylaşımlı Standard-1X 25 dolar, ayrılmış Performance-M 250 dolar (10 kat). Google SRE kitabı bir sonraki "dokuz"un bir öncekinden 100 kat pahalı olabileceğini söylüyor. Sizin fiyat adımınız 1,5 kat; "ne alaka" diyecek kişi buna takılır.
8. **Ölçekte kırılma:** Software Inc.'de "Huge Server rack" geç oyunda yetmedi, 22.000 sunuculu kayıt 10 dakikada açıldı; Startup Company'de "bir admin işe al, kur, kov" istismarı raporlandı. Birim boyutu ve fiyat ölçekle büyümeli, sabit yüzdeler değil.

## 2. Mekanik döküm

### 2.1 Startup Company (Hovgaard Games, Steam 606800)

Kaynak notu: Fandom wiki açılmadı. Aşağıdakiler Steam forum konuları ve tek rehberden.

**Sunucu türleri ve darboğaz kuralı.** Her proje için Web, Cache ve Database sunucusu gerekir; her türün en az biri şart. "Toplam verim her zaman üç sayının en düşüğüdür." En basit modellerde verim: Web 200, Cache 500, DB 300. Örnek: 5 Web (1000), 2 Cache (1000), 3 DB (900) → toplam 900, DB'ye takılır. Kaynak: https://steamcommunity.com/app/606800/discussions/0/4038106323497193164/ . Rehber de aynısını söylüyor: "kullanılabilir çıktı üç grubun en düşüğüne eşit, biri geride kalırsa diğerlerinin fazlası boşa gider." Kaynak: https://steamcommunity.com/sharedfiles/filedetails/?id=2504405550

**Raflar ve fiyatlar.** Rafın üç boyutu var: 10 slot 1.600 dolar, 20 slot 3.500 dolar, 42 slot 12.000 dolar (aynı rehber). Sunucular "U" cinsinden genişlik kaplar (2U, 4U, 8U), her biri güç tüketir ve %'lik hız aşırtma (overclock; 1 = %100, 1,5 = %150) ile ayarlanır.

**Isı.** Raf içine soğutucu konur. Örnek yerleşimler: 4U orta kademe rafta her sunucu arasında 2 soğutucu; Web %100 yükte 22 derece, DB %125 yükte 28 derece. 8U üst kademede Web %100 yükte 30 derece, DB %140 yükte 42 derece. Kaynak: https://steamcommunity.com/app/606800/discussions/0/1744521326156951129/ . Bir oyuncu bir rafta 4'ten fazla sunucunun tam yükte aşırı ısındığını yazıyor: https://steamcommunity.com/app/606800/discussions/0/1742229167229810064/

**Dengeleme sayıları (oyuncu hesabı).** 4U düzeninde 1 rafta 8 Web, 1 rafta 4 Cache + 5 DB: Web, Cache, DB'nin her biri 20.000 verim, toplam yaklaşık 280 bin CU. 8U düzeninde 3 klima gerekir, yaklaşık 2,94 milyon CU. 2U sunucularda Web 650 / Cache 1200 verir ve dengelemek zordur (aynı kaynak). CU'nun tanımı konularda yapılmamış.

**Yanıt süresi (ms).** Ürünün sağladığı hizmetin yanıt süresi ms olarak görünür. Oyuncu "sunucu kullanımı %26 iken bile ms 300'ün üstünde" diyor; geliştirici cevabı: "tek yol verimliliği (efficiency) yükseltmek." Kaynak: https://steamcommunity.com/app/606800/discussions/0/1742227264199106852/ . Başka bir oyuncuya "yanıt süresi yüksekse kullanıcı kaybedersin" deniyor: https://steamcommunity.com/app/606800/discussions/0/3491891042511325489/ . Aşırı yük: "sunucular sürekli %120-130 yüklü, ms 700-800" (cevapsız): https://steamcommunity.com/app/606800/discussions/0/5144805327243249786/

**Merkezi kontrol.** Her web sitesine ayrılan "server charge" elle ayarlanır. Geliştirici Jonas "Centralized Clockrate Controller" öneriyor; oyuncu bunun siteler arası kaynağı dengelemediğini söylüyor: https://steamcommunity.com/app/606800/discussions/0/1742267141099892410/

**SysAdmin.** Bir oyuncuya göre mekanik, bir admin işe almayı, birkaç şey kurmayı, kaynak stoklamayı ve sonraki dalgaya kadar admini kovmayı ödüllendiriyor (aynı konu). Gerçek sistem yönetiminin çoğu bakım olduğunu da ekliyor. Kullanıcı başına yük, hosting maliyeti rakamları ve bulut-vs-kendi sunucu seçimi bulunamadı (bu oyunda yalnızca kendi sunucu var görünüyor, doğrulanamadı).

### 2.2 Software Inc. (Coredumping, Steam 362620)

**Yapı.** Sunucular ayrı kulelerdir; birbirine "wiremode" kablosuyla bağlanınca tek birleşik sunucu olur. Geliştirici: "wiremode" düğmesi build mode düğmesinin yanındadır. Kaynaklar: https://steamcommunity.com/app/362620/discussions/0/613957600543300759/ , https://steamcommunity.com/app/362620/discussions/0/613956964600255703/

**Yük.** Her sunucuda bant genişliği "x/50 Mbps" biçiminde gösteriliyor (örn. 57/50 aşım). Her sunucuya bir "fallback" sunucu atanabilir ama oyuncuya göre bu yükü paylaştırmaz: https://steamcommunity.com/app/362620/discussions/0/1872875054774703459/ . Bir oyuncu 1,7 GB/s'ye ihtiyaç duyup 1 GB/s'ye sahipken kümelemeyle 30, sonra 106 sunucuya çıkan bir yapıdan söz ediyor: https://steamcommunity.com/app/362620/discussions/0/1499000547486328618/

**Maliyet.** Geliştirici: sunucular kullandıkları bant genişliğine göre internet maliyeti de doğurur. Elektrik ayrı gider. Bir oyuncuya göre elektrik yalnızca kullanımdayken ücretlendirilir, boşta sunucu bedava (bu, istismar kapısı): https://steamcommunity.com/app/362620/discussions/0/355043117523289847 . Yükün çoğu dağıtımdan değil yayın sonrası destekten gelir; 60 milyon aktif kullanıcıda "saçma miktarda" bant genişliği: https://steamcommunity.com/app/362620/discussions/0/133256080240773413

**Rakamlar.** "Huge Server rack" modlardan alınmıştı ve geç oyunda yetmedi; geliştirici 4 Şubat'ta büyük rafı 100 GB'a ayarladı, 50 TB yine de yaklaşık 500 sunucu demek: aynı konu. Bir oyuncu 14 sunucu × 5 TB ile aylık 3,2 milyar kazanıyor, büyük hosting anlaşmaları 20 TB'a kadar bant kullanıyor, bir anlaşma 250 milyon çalıştırma maliyetiyle aylık 2 milyarın üstünde gelir getiriyor (355043117523289847 konusu).

**Aşırı yük.** Bir dağıtım kanalının sunucuları yetmeyince "Your servers can't deal with the load" uyarısı çıkar ve işletim sistemi gibi ürün üretilemez; bir oyuncu 158 kule sunucuyla bile yetmediğini bildirdi: https://steamcommunity.com/app/362620/discussions/0/405691491125056338/ . Yük bazen %40'tan %100'ün üstüne çıkıyor ("sözleşmelere göre"), kullanıcı sözleşme kaybettiğini yazıyor (133256080240773413).

### 2.3 Game Dev Tycoon, Mad Games Tycoon, Mad Games Tycoon 2

**Game Dev Tycoon.** MMO'nun bakım gideri oyuncular tarafından "kullanıcıya doğrusal bağlı olmayan, artan" olarak anlatılıyor: bir oyuncu üç yılda aylık yaklaşık 1 milyar dolara çıkan bakımla iflas ettiğini yazmış. Aynı konuda "sunucu başına 10.000 oyuncu, lansmanda 100.000 oyuncu → 10-20 sunucu" gibi örnek rakamlar var ama bunlar oyuncunun gerçek dünya varsayımı, oyun mekaniği değil. Bir yanıt MMO'ların 2013'te "uzun vadede kâr etmesin diye" değiştirildiğini iddia ediyor. Kaynak: https://steamcommunity.com/app/239820/discussions/0/3307213006836087670

**Mad Games Tycoon.** Sunucuların haftalık/aylık yinelenen maliyeti var, sunucu odası ya tamamen açık ya tamamen kapalı ("It's the entire room or none of them"); oyuncular büyük bir boş oda yerine kapatılabilen küçük odalar öneriyor, ücretsiz oyunlar az oyuncuda bile maliyet doğurmaya devam ediyor. Kaynak: https://steamcommunity.com/app/341000/discussions/0/359543951728364630

**Mad Games Tycoon 2.** Sunucu odası var (ürün açıklaması); bir oyuncu sunucu odasını "oynanışa zarar vermeden atlayabileceğiniz odalar" arasında sayıyor. Kapasite, kullanıcı başına yük ya da maliyet rakamı bulunamadı. Kaynak: https://steamcommunity.com/app/1342330/discussions/0/4737210531938532878

### 2.4 Doluluk bir karar mı, angarya mı?

- **Startup Company: ikisi birden.** Karar: raf boyutu, 2U/4U/8U, hız aşırtma, soğutma. Angarya: üç kaynağı dengeleme, siteler arası elle ayar. Geliştirici açıkça savunuyor: "balancing everything would make configuration tedious... from a challenge to just an annoying task" (https://steamcommunity.com/app/606800/discussions/0/1742229167229810064/). Yani otomatik dengeye bilerek karşı. Oyuncu istekleri: otomatik yük dengeleme, +/- kontrol (https://steamcommunity.com/app/606800/discussions/0/1742267141099892410/).
- **Software Inc.: çoğunlukla angarya + ölçek sorunu.** Karar: kaç sunucu, hangisine ne atanır, kablolama. Şikâyetler: birleştirme arayüzünü bulamamak ("Server can't deal with the load" soruları 2015-2020 boyunca tekrarlanıyor), geç oyunda yeterli büyük birim olmaması, 22.000 sunuculu kaydın 10 dakikada yüklenmesi (https://steamcommunity.com/app/362620/discussions/1/1737715419901572864/ başlığı arama sonucundan; sayfa açılmadı).
- **GDT/MGT/MGT2: doluluk yok, kararsız gider.** Karar yalnızca "MMO'yu kapat/aç". Oyuncu şikâyeti "bakım giderinin kontrolsüz artması".
- **Otomatik ölçekleme yapan oyun bulunamadı.** Oyuncu talepleri var (Startup Company yük dengeleme, Software Inc. fallback zinciri), uygulayan örnek yok.

### 2.5 Gerçek dünya

**Altyapı maliyeti ve brüt marj.**
- a16z (Mayıs 2021, kaba tahmin): kamuya açık yazılım şirketlerinde taahhüt edilen bulut harcaması maliyet kaleminin (COR) ortalama %50'si; milyar dolarlık özel bir şirkette gerçek harcama COR'un %81'i; "COR'un %75-80'i yaygın." Taahhüt, gerçekleşenden tipik olarak %20 düşük. Dropbox brüt marjı 2015-2017'de %33'ten %67'ye çıktı (altyapı optimizasyonuyla). Kaynak: https://a16z.com/the-cost-of-cloud-a-trillion-dollar-paradox/
- Bessemer: bulut işletmelerinin ortalama brüt marjı %65-70, orta %50'lik dilim %60-80. Hosting'in gelire oranı verilmemiş, yalnızca COGS kalemleri arasında sayılmış. Kaynak: https://www.bvp.com/atlas/scaling-to-100-million
- Hesap: COR ≈ gelirin %28-35'i, bunun %50'si bulut → gelirin yaklaşık %14-17'si (a16z ve Bessemer birleşimi; kamuya açık şirket örneğinde).
- Satıcı blogu rehberi (belirtilen kaynaksız, yazarın kendi kılavuzu): bulut maliyeti gelirin yüzdesi olarak tohum aşaması %20-35, Seri A %15-25, Seri B %12-18, Seri C+ %10-15, halka açık %8-12. SaaS türüne göre: standart B2B %12-20, düşük hesaplı (CRM, proje yönetimi) %8-15, analitik %20-30. Müşteri başına aylık: KOBİ (gelir 50 dolar) 3-8 dolar, orta ölçek (500 dolar) 15-50 dolar, kurumsal (5.000 dolar) 50-300 dolar. Kaynak: https://wring.co/blog/cloud-costs-for-saas-companies . Sayılar yönlendirici, doğrulanmamış; yine de a16z hesabıyla uyumlu.

**Kapasite neyle ölçülür.** Bu bölüm model bilgisidir (kaynaksız, model bilgisi): gerçekte eşzamanlı kullanıcı, saniyedeki istek, CPU, bellek, depolama ve çıkış trafiği; "1.000 kullanıcı" ya da "50 koltuk" doğrudan fiziksel bir birim değil, ortalama etkin oran ve tepe katsayısıyla yüke çevrilen bir tahmin. Kaynaklı tek yön: Unity'nin oyun sunucusu belgeleri kapasiteyi makine sayısıyla değil çalışan sunucu işlemi sayısıyla tanımlıyor, "çıplak metal tabanı ucuz ama yavaş sağlanır, bulut makineleri dakikalar içinde eklenir" diyor (arama sonucu özeti, sayfa açılmadı): https://docs.unity.com/game-server-hosting/en/manual/legacy/server-capacity . Bir Hong Kong barındırma sağlayıcısı tepe eşzamanlılığa göre değil tipik yüke göre çekirdek kurup tepeler için ölçeklenebilir kaynak eklemeyi öneriyor (arama sonucu özeti, sayfa açılmadı): https://www.varidata.com/blog-en/game-server-capacity-assessment-for-hong-kong-servers/

**Otomatik ölçekleme ve rezerve kapasite.** AWS'de m6i.large (2 vCPU, 8 GiB): isteğe bağlı 0,096 dolar/saat (≈70 dolar/ay, hesap), 1 yıllık rezerve 0,064 (%33 indirim), 3 yıllık 0,044 (%54 indirim, hesap). Kaynak: https://instances.vantage.sh/aws/ec2/m6i.large (bölge/işletim sistemi sayfada doğrulanamadı). a16z: taahhütlü kullanım indirimi hesaplamada tipik %30-50: yukarıdaki a16z linki. Wring: Savings Plan indirimi Seri B'de %30-40, Seri C+'ta %50-60. Rezerve = taahhüt karşılığı ucuz taban; otomatik ölçekleme = pahalı ama esnek tepe. 37signals buluttan ayrılma: yıllık bulut faturası 3,2 milyon dolar, en az 1,5 milyon dolar/yıl tasarruf, ~500 bin dolarlık donanım 5 yıla yayılıyor. Kaynak: https://world.hey.com/dhh/we-have-left-the-cloud-251760fb . a16z: kendi sunucuya geçiş bulut maliyetinin üçte biri ile yarısı arası.

**Paylaşımlı / ayrılmış / kurumsal.**
- Heroku: Standard-1X 25 dolar, Standard-2X 50 dolar; Performance-M (ayrılmış hesaplama) 250 dolar, Performance-L 500 dolar; Private-S (özel alan) 125 dolar, Private-M 250 dolar; Shield-S 150 dolar, Shield-M 300 dolar (özel alanın %20 üstü). Kaynak: https://www.heroku.com/pricing . Postgres planlarında aylık azami kesinti: Essential 4 saat, Standard 1 saat, Premium 15 dakika (aynı sayfa).
- AWS Dedicated Instance: ayrılmış kiracılık için bölge başına saatte 2 dolar ek ücret (≈1.460 dolar/ay, hesap) + örnek ücreti. Kaynak: https://aws.amazon.com/ec2/pricing/dedicated-instances/
- Wring: çok kiracılı veritabanı müşteri başına tek kiracıdan "5-10 kat ucuz" (100 müşteri için 1.450 dolar/ay vs 190 dolar/ay örneği): wring linki. CloudZero tek kiracılıyı niteliksel olarak "daha pahalı, kaynaklar atıl kalır" diye tarif ediyor, yüzde vermiyor: https://www.cloudzero.com/blog/single-tenant-vs-multi-tenant

**SLA kademeleri ve gerçek kesinti.**
- AWS Well-Architected tablosu (yıllık azami kesinti): %99 → 3 gün 15 saat; %99,9 → 8 saat 45 dakika; %99,95 → 4 saat 22 dakika; %99,99 → 52 dakika; %99,999 → 5 dakika. Uygulama türü: %99,9 iç araçlar, %99,95 çevrimiçi ticaret, %99,99 video dağıtımı. Kaynak: https://docs.aws.amazon.com/wellarchitected/latest/reliability-pillar/availability.html
- Aynı sayfada bağımlılık formülü: ardışık zorunlu bağımlılıklarda erişilebilirlikler çarpılır (0,9999³ = %99,97); yedekli bileşenlerde 100% − (arıza oranları çarpımı) (iki %99,9 → %99,9999, teoride).
- AWS EC2 SLA: bölge düzeyi %99,99 hedefi, tek örnek düzeyi %99,5. Kredi: %10 / %30 / %100. Kaynak: https://aws.amazon.com/compute/sla/ . Google Workspace %99,9; kredi 3 / 7 / 15 gün: https://workspace.google.com/terms/sla.html
- Google SRE: güvenilirliğin "bir sonraki artışı bir öncekinden 100 kat pahalı olabilir"; kurumsal ürün için tipik hedef %99,9, tüketici ürünlerinde daha düşük hedef kabul edilebilir. Kaynak: https://sre.google/sre-book/embracing-risk/
- SLA hedef/tavandır; gerçekleşen sıklık ayrı. Gerçek kesinti sıklığının kademelere göre dağılımına dair kaynak bulunamadı (Uptime Institute raporu ücretli).

## 3. Oyuncuya gösterim

- **Startup Company:** sunucu odası ekranında altta Web / Cache / DB verim sayıları yan yana; eksik olanın yanında ünlem işareti ("An exclamation mark next to a number means you need more of that server type"). Ürün ekranında ms ve %kullanım. Kaynak: https://steamcommunity.com/app/606800/discussions/0/1744521326156951129/
- **Software Inc.:** sunucu başına "x/50 Mbps" çubuğu, aşımda uyarı mesajı "Your servers can't deal with the load of ...". Kaynak: https://steamcommunity.com/app/362620/discussions/0/1872875054774703459/
- **GDT/MGT:** sayısal yük göstergesi yok, yalnızca gider satırı.
- Ekran görüntüsü URL'leri: Steam mağaza sayfaları https://store.steampowered.com/app/606800/Startup_Company/ ve https://store.steampowered.com/app/362620/ ; galeri görsel URL'lerine erişilemedi (mağaza sayfası araçla ayrıştırılamadı). Wiki görselleri Fandom 402 yüzünden alınamadı.

## 4. Ölçek ve sorunlar

**Küçük şirket.** Startup Company'de en küçük site bile Web+Cache+DB üçlüsünü ister (minimum sabit taban). Gerçek dünyada da küçük ölçekte altyapı gelirin %20-35'i (wring), ölçek büyüdükçe %8-12'ye iniyor.

**Büyük şirket.**
- Software Inc.: "Huge rack" yetmedi, 100 GB'a ayarlandı; 50 TB için 500 sunucu; oyuncu 15.000-30.000 sunucuya çıkıp oyunu çökertti (30.000 üstünde oyun çöktü). Elektrik giderleri gelirle orantısızlaştı (bir oyuncunun 265 milyon gelire karşı 1,6 trilyon elektrik raporu, matematik hatası olabilir diye kendisi kabul etti). Kaynak: https://steamcommunity.com/app/362620/discussions/0/133256080240773413
- Startup Company: geç oyunda yeni sunucu kurmak ve DDoS'u engellemek çok kaynak istiyor; manuel "server charge" ayarı çok siteli oyunda zor; çözüm "hepsini aynı boyutta yap, 25% ver" (https://steamcommunity.com/app/606800/discussions/0/1742267141099892410/).
- GDT: MMO bakım gideri 3 yılda aylık 1 milyar dolara çıkıp iflas; "neden hepsi kapanıyor" sorusu (https://steamcommunity.com/app/239820/discussions/0/3307213006836087670).

**İstismarlar.**
- Software Inc.: boşta sunucu elektrik yemiyor → fazla kapasiteyi bedava tutmak mümkün; hosting anlaşmaları ana gelir kaynağına dönüşüyor (3,2 milyar/ay).
- Startup Company: admin işe al, kur, stokla, kov.
- Mad Games Tycoon: oda ya hep ya hiç → oyuncu tüm odayı kapatıp açıyor.

**Patch notları.** Software Inc. büyük raf değişikliği (geliştirici konuşması, 4 Şubat 2017) dışında patch notu bulunamadı.

## 5. Bizim için

**Alınacak**
- **Tek doluluk çubuğu ve eşik rengi (yeşil / %80 sarı / %100 aşım).** Startup Company'nin ms ve Software Inc.'in x/50 göstergesi gibi okunur, ama üç kaynak dengesi (Web/Cache/DB) alınmamalı: darboğaz = min(üç) kuralı oyuncu şikâyetlerinin tam merkezi, geliştirici bile "angarya olur" diyor.
- **Sabit taban + basamaklı birim.** Kapasite birimi satın alınır (Startup Company'deki raf: 10/20/42 slot fiyatı 1.600 / 3.500 / 12.000 dolar). Bizim hedef kitle 20-50 çalışan; birim boyutları şirketle büyümeli (Software Inc.'in "Huge rack yetmedi" dersi).
- **Boşta kapasite de para yesin.** Software Inc.'in "boşta bedava" istismarını tekrarlamayın; sabit kapasite ücreti dolulukla değişmesin, değişken kısım (bant/istek) kullanıma bağlı olsun.
- **Taahhüt = karar.** 12 aylık rezerve kapasite (gerçekte %33 / %54 indirim, hesap) ya da isteğe bağlı kapasite arasında seçim. 12 aylık B2B sözleşmeyle doğal eşleşir.
- **Otomatik ölçekleme kademe özelliği olsun.** Hiçbir oyunda yok, oyuncular istiyor. Ekonomik = elle yükseltme; Standart = yarı otomatik; Kurumsal = otomatik ölçekleme ve yedeklilik (daha pahalı birim). Böylece angarya olan iş para karşılığı kaldırılan bir karar olur.
- **SLA kredisi mekaniği (B2B).** Kesinti olunca kurumsal müşteriye sözleşmede yazan kredi (Google: 3/7/15 gün, AWS: %10/30/100): kesintinin bedeli müşteri memnuniyeti artı para.

**Alınmayacak**
- Startup Company'nin üç türlü sunucu dengesi ve ısı/klima yönetimi.
- Software Inc.'deki bant genişliği (GB, TB) birimleri ve elektrik fiyatı sistemi: ölçekte sayı patlaması (trilyonlar).
- GDT'nin "kullanıcıdan bağımsız artan bakım gideri" (oyuncuda haksızlık hissi).

**Uyarlanacak**
- **Fiyatlar (B2C 35/55/85, B2B 30/45/70).** Gelir içindeki payı: B2C Ekonomik %0,8, Standart %1,25, Kurumsal %1,9; B2B %1,7 / %2,6 / %4,0 (hesap: 35/1000 ÷ 4,4 gibi). Gerçek rehber (wring, doğrulanmamış): düşük hesaplı SaaS %8-15; B2B kurumsal müşteri başına %1-6. Öneri: B2B'yi büyük ölçüde koruyun (Kurumsal %4 makul, Ekonomik/Standart alt uçta), B2C'yi yaklaşık 4-8 kat artırın (1.000 kullanıcı başına yaklaşık 150-350 dolar; bu aralık %8-15'lik gelirin yarısı "yalnız sunucu" varsayımıyla kuruldu, model önerisi). Sektörden biri 1.000 kullanıcıya 35 dolara "ne alaka" der: bir m6i.large bile ayda yaklaşık 70 dolar, yani sizin B2B Kurumsal 50 koltuk fiyatı bir tek sanal makine kadar; B2C Ekonomik yarım makine (hesap).
- **Fiyat basamağı.** Mevcut kademe farkı 1,5 kat. Gerçek dünyada paylaşımlıdan ayrılmışa 10 kat (Heroku 25 → 250); kurumsal/ayrılmış kiracılık için tek örnek yüzde bulunamadı. Öneri: B2B'de Kurumsal 2,5-4 kat, ama yalnız ek kapasiteye değil yedekliliğe ve SLA'ya para ödetin.
- **Kesinti çarpanı.** Mevcut 1,0 / 0,8 / 0,5 (ya da 0,4). Kaynaklı referanslar: Heroku Postgres 4 saat / 1 saat / 15 dk (kademe başına 4 kat); AWS tek örnek %99,5 → bölge %99,99 (50 kat); AWS tablosu %99,9 → %99,95 → %99,99 (2 ve 5 kat). Öneri (model, kaynaksız): kesinti **olasılığına** 1,0 / 0,4 / 0,15 uygulanabilir (kademe başına yaklaşık 2,5 kat, oyun hissi için yumuşatılmış), kesinti **süresi** ayrıca kısalsın. 0,8 çarpanı ise gerçekte neredeyse fark yaratmayan %20 azalma; oyuncu Standart'ın değerini hissetmez.
- **Doluluk → kesinti olasılığı.** Kaynaklı formül yok; bu yüzden olasılığı iki çarpanın çarpımı yapın: taban(kademe) × f(doluluk). f parçalı: %70 altı 1,0; %70-80 arası 1,5-2; %80-100 arası 3-5; %100 üstü kesin bozulma (yanıt süresi/kayıp). Dayanak: Startup Company'de %120-130 yükte 700-800 ms; Software Inc.'de %100'de ürün üretilemiyor. Tasarım önerisi; kuyruk teorisinde gecikmenin yükün %70-80'inden sonra hızla artması model bilgisidir (kaynaksız, model bilgisi).
- **Bağımlılık zinciri.** AWS formülü doğrudan kullanılabilir: kademe = yedek sayısı; olasılık = q^n (tek örnek q, iki örnek q²). Gerçekte arızalar bağımsız değildir, teorik değerler iyimser kalır (kaynaksız, model bilgisi), o yüzden yedeklilik kazancı tavanlı olsun.
- **"1.000 kullanıcı" ve "50 koltuk" birimi.** İkisi de aslında insan sayısı; asıl yük eşzamanlı etkinliktir. Daha doğru birim: tek bir "yük birimi" (YB). B2C kullanıcı = az, B2B koltuk = çok YB (koltuk daha çok veri ve mesai saatinde yoğunlaşma, kaynaksız, model bilgisi). Maliyet = ceil(toplam YB ÷ birim kapasite) × kademe ücreti. Bu yaklaşım, çalışan sayısı 20-50'den büyüdüğünde de bozulmaz, çünkü yüzde değil basamaklı ceil kullanılır.
- **Ölçek indirimi.** Büyük şirkette birim başına maliyet düşmeli: gerçek dünyada bulut yüzdesi tohumdan halka açığa %20-35'ten %8-12'ye iniyor (wring), Dropbox'ta marj %33 → %67 (a16z).

## 6. Bulunamayanlar

- Startup Company ve Software Inc. Fandom/resmi wiki sayfaları (402 / 404): kullanıcı başına yük, sunucu modeli başına tam verim ve güç değerleri, hosting maliyet formülü, SysAdmin'in tam etkisi alınamadı. Rehberin bağlandığı hesap tablosu (OneDrive/Google Sheets) açılmadı.
- Startup Company'de bulut-vs-kendi sunucu seçimi ve "CU" tanımı.
- Software Inc.'de kullanıcı başına yük formülü ve "dağıtık hosting" kuralı; sunucu rafı tipleri ve fiyatları.
- Mad Games Tycoon 2 ve Game Dev Tycoon için sunucu maliyeti/kapasite rakamı (oyun mekaniği olarak); yalnızca oyuncu anlatımı. Game Dev Tycoon "sunucu başına 10.000" rakamı oyun kuralı değil oyuncu varsayımı.
- Otomatik ölçekleme yapan bir oyun.
- Bu oyunlar için patch notları (sunucu mekaniği değişiklikleri).
- B2B koltuk başına ve B2C kullanıcı başına aylık altyapı maliyeti için bağımsız/birincil kaynak (yalnızca satıcı blogu rehberi); B2C pazaryeri benzeri ürünlerin kullanıcı başına altyapı maliyeti.
- Tek kiracılı / ayrılmış barındırma için yüzde cinsinden fiyat farkı (sadece Heroku liste fiyatı ve AWS $2/saat bölge ücreti).
- SLA kademelerine göre gerçek kesinti sıklığı (Uptime Institute raporu ücretli; Wikipedia tier tablosu çıkarılamadı).
- Ekran görüntüsü URL'leri (galeri).
- WebSearch bütçesi (8) tamamen kullanıldı; sonrası WebFetch ile bilinen URL'lerle sürdürüldü.


---

## 7. Tamamlama (2026-10-17, başsız Chrome)

Kaynak durumu: Startup Company wiki'si (Servers, SysAdmin, Researcher, Change Log) ve mağaza ekran görüntüleri okundu; Software Inc'in resmi veri modlama sayfası ve bir Steam hata raporu okundu; Game Dev Tycoon MMO sayfası ve MGT2 oda tablosu okundu. Wiki sayfalarının sürümü eski (Startup Company wiki Change Log'u Beta 17.0'da, Ağustos 2018'de bitiyor); ekran görüntüleri güncel arayüz.

### 7.1 Startup Company: CU hesabı ve sunucu tablosu (kapanan boşluk: sunucu verimi, CU tanımı, maliyet)

- CU, Web, Database ve Cache sunucularının her birinin toplam veriminin EN KÜÇÜĞÜNÜN 14 katı. Bu, iki kaynağın uyumundan çıkardığım bir sonuç, wiki'de yazılı değil: wiki örneğinde 3 küçük Web (3x200=600), 2 küçük Database (2x300=600), 1 küçük Cache (500) "7000 CU" veriyor (en küçük 500 x 14 = 7000); Cache %20 aşırtılınca 600 olur ve 8400 CU çıkar (600 x 14). Güncel ekran görüntüsü de uyumlu: sunucu odası özeti "Webserver 1.400M | Cache 1.400M | Database 1.676M | Produced CU 19.60M" (1.400M x 14 = 19,6M) ve ikinci görüntüde 280.000K ile "Produced CU 3.92M" (280.000K x 14 = 3,92M). Kaynaklar: https://startupcompany.fandom.com/wiki/Servers , https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/606800/ss_0c096a49947a394216f9a51da8caf32943cce330.1920x1080.jpg?t=1727681373 , https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/606800/ss_ea1b02a0c8163011799d16b7216a4b1dd46dabc9.1920x1080.jpg?t=1727681373
- Sunucu türleri ve boyutları (wiki Servers): Web: Small 200 veri, 1U, $10.000, aylık güç $375; 2U 650, $25.000, $675; 4U Blade 2500, $150.000, $1200; 8U XServer 21.000, $800.000, $2100. Database: 300 / 800 / 4000 / 30.000 (8U). Cache: 500 / 1200 / 5000 / 42.000 (8U). Kurulum başına SysAdmin bileşeni adedi (Firewall, Virtual Hardware, Operating System her birinden): küçükte 2, 2U'da 4, 4U'da 15, 8U'da 32. Kaynak: https://startupcompany.fandom.com/wiki/Servers
- Doluluk ve aşım: bir ürün için CU kapasitesi (Total CU), kullanılan (Used CU), serbest (Free CU) ve dönem tepesi (Peak CU; RESET düğmesi) Hosting sekmesinde yazıyor; kadran doluluk yüzdesi (%41) ve üç kademeli "Critical / Unstable / Stable" şeridi ile "Response Time" ms olarak gösteriliyor (örnek 210 ms; %39 doluluğunda 204 ms). Aşım cezasının formülü hiçbir kaynakta yok; gösterilen sonuç yanıt süresi ve kararlılık kademesi. Kaynak: https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/606800/ss_12d04b8d057121d1ce7214576367925bb2ea32aa.1920x1080.jpg?t=1727681373 ve https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/606800/ss_60b0b2a8fb13081564c418913f9afbebe78c3562.1920x1080.jpg?t=1727681373
- Bulut seçeneği (güncel arayüz): FASTCLOUDS MINI cloud server +500 CU, $40/gün; PRO +1600 CU, $110/gün; ULTRA +15.000 CU, $900/gün; her biri "ADD INSTANCE / REMOVE INSTANCE" düğmeli, her adet SysAdmin bileşeni (örnek "2 (22)") gerektiriyor. Birim maliyet (benim bölmem): Mini yaklaşık $0,08/CU/gün, Pro yaklaşık $0,069, Ultra $0,06; büyük kademe CU başına ucuz. Kaynak: https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/606800/ss_12d04b8d057121d1ce7214576367925bb2ea32aa.1920x1080.jpg?t=1727681373
- Kendi sunucu ile bulut karşılaştırması (wiki, Beta 16 dönemi): "iki raf: 16.800 CU, günde $175; barındırma (hosted) seçeneği 15.000 CU için günde $900." Aynı güncel ekranda 15.000 CU Ultra bulut $900/gün; yani "bulut pahalı, kendi sunucu ucuz ama baştan yatırım ister" ilişkisi hâlâ geçerli görünüyor. Wiki'nin bu cümlesi tabloyla tam uzlaşmıyor (tablodaki aylık güç ve bant maliyetinden bu günlük rakam çıkmıyor); rakam sorgulanmalı. Kaynak: https://startupcompany.fandom.com/wiki/Servers
- Raf yükü ve ısı: "Large Rack" penceresinde Consumed Power 87.000 W, Rack Temperature 56 C, Total Web Server Throughput 10.000, Database 12.000, Cache 10.000; "DUPLICATE ($1,374,000)"; raf etiketi "42/42U" (yer doluluğu); sunucu odası altında sıcaklık göstergesi. Kaynak: https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/606800/ss_ea1b02a0c8163011799d16b7216a4b1dd46dabc9.1920x1080.jpg?t=1727681373
- Özelliklerin CU yükü: Researcher sayfasındaki tabloda her özelliğin yanında bir CU değeri var (Landing Page 50, Screen Capturing 100, Live Streaming 75, Server Redundancy 5, Intrusion Prevention System 25). Birimi yazmıyor; "kullanıcı başına yük" mü, ürüne bir defa eklenen yük mü belirsiz. Kaynak: https://startupcompany.fandom.com/wiki/Researcher
- Milestone'lar sunucuyu merdiven olarak kullanıyor: 10. "toplam CU 1000'e ulaş" ($20.000), 16. "hosting binası kirala" ($100.000), 17. "en az 2500 CU üret" ($100.000). Kaynak: https://startupcompany.fandom.com/wiki/Milestones
- Change Log: Beta 15.0'da sanal küme için sunucu gereksinimi azaltıldı, fiyatı artırıldı, "potansiyel kullanıcı kayıtlı kullanıcıdan düşükse kullanıcı kaybı hızı artırıldı"; Beta 16.0'da hosting binaları, raflar, sunucular eklendi; Beta 16.6'da bodrum hosting binası $10k'dan $20k'ya çıktı ("yeni oyuncuların yanlış binayı kiralamaması için"); Beta 17.0'da azami sanal sunucu sayısını aşma hatası düzeltildi. Kaynak: https://startupcompany.fandom.com/wiki/Change_Log

### 7.2 Software Inc: kullanıcı başına yük formülü ve hosting sözleşmesi

- Resmi veri modlama sayfası: özellikteki "Server" alanı "aktif kullanıcı başına kaç mbps; 1+log10(yıl-1969) ile zamanla ölçeklenir." MMO örneği 0,002 (2010'da 1 milyon kullanıcıda yaklaşık 5 gbps). Resmi wiki'de Hosting ya da Servers adlı sayfa yok (Special:AllPages, 30 sayfa). Kaynak: https://softwareinc.coredumping.com/wiki/index.php/Data_Modding ve https://softwareinc.coredumping.com/wiki/index.php/Special:AllPages . Not: formülün kendisi önceki §2'de zaten vardı; yeni olan, "dağıtık hosting kuralı" için ayrı wiki sayfası olmadığının doğrulanması.
- Steam hata raporu (Ocak 2021, Alpha 10.10.11, oyuncu ve moderatör): hosting sözleşmesinde "maksimum bant genişliği kullanımı" ürünün tam potansiyele ulaşırsa olacak değer; gerçek bant aktif kullanıcıyla dalgalanır; erken oyunda düşük bant ve yüksek ilk maliyet zarar yazar; sözleşme ödemesi iş itibarına bağlı; örnekte 43 sunucu, 600-900 Mbps, MB başına saatlik 2,53 ve 2,36. Kaynak: https://steamcommunity.com/app/362620/discussions/1/3016815718822912355/
- Oyuncu rehberlerinde: sunucu odası gürültülü, bodrumda olsun (Max's Beginners Guide); "Hosting hizmeti başlat, yıl 2000'den sonra daha çok müşteri gelir; iş itibarı anahtar"; dijital dağıtımda payı %6'dan başlayıp yükselt, %8 ve üstü kârlı (LatN). Kaynaklar: https://steamcommunity.com/sharedfiles/filedetails/?id=1198857114 ve https://steamcommunity.com/sharedfiles/filedetails/?id=1971495059
- Ekran: Software Inc üretim katı görüntüsünde "Main Server", "Source Control Server", "Backup Server" etiketli sunucu sıraları var (şirketin kendi sunucuları, müşteri hosting'i değil): https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/362620/ss_1d47fba62ef9deebdc531ca05560934e5a19f0bd.1920x1080.jpg?t=1763102408

### 7.3 Game Dev Tycoon ve Mad Games Tycoon 2 (kısmen)

- GDT MMO: yayınlanınca özel konsol gibi bakım gerektirir; sürekli gelir getirir ama zamanla düşer, bakım sabit kalır; geliri artırmak için genişleme paketi, aksi halde "Take off market". Sayı yok. "Sunucu başına 10.000" rakamı oyun kuralı değil, oyuncu varsayımı (önceki bölümle uyumlu). Kaynak: https://gamedevtycoon.fandom.com/wiki/MMO
- MGT2 (Steam rehberi, oyuncu): "Server room" odası metrekare başına $10.000 (en küçük 3x3), rastgele olay "Energy crisis: sunucu işletme maliyeti +%100". Başka sayı yok. Kaynak: https://steamcommunity.com/sharedfiles/filedetails/?id=2371634667

### 7.4 Bu tamamlamanın §6 listesine etkisi

- Kapandı: Startup Company CU tanımı, sunucu türü/boyutu/maliyeti tablosu, güncel bulut kademeleri ve CU başına maliyet, Software Inc kullanıcı başına yük formülünün resmî kaynağı, GDT MMO'nun nitel maliyet davranışı.
- Hâlâ bulunamadı: Startup Company'de kullanıcı başına CU yükü ve aşım cezası formülü; bulut-vs-kendi sunucu için resmi denge açıklaması; Software Inc dağıtık hosting kuralı ve raf fiyatları; MGT2 ve GDT için sayı; B2B koltuk başına ve B2C kullanıcı başına altyapı maliyeti ile SLA kesinti sıklığı (oyun dışı kaynaklar, bu turun kapsamı dışında).
