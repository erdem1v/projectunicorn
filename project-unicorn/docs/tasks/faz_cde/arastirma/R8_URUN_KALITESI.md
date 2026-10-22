# R8 — Ürün kalitesinin ve eksik yerinin oyuncuya gösterilmesi

Tarih: 2026-10-17. Konu: Faz C ve D'yi kesen soru. "Kararlılık, Deneyim, İnovasyon" eksenlerini ne yapacağız?

Kaynak notu (okumadan önce): Fandom wiki'leri (Software Inc, Game Dev Tycoon, Startup Company, Two Point Hospital) ve Reddit bu ortamda açılmadı (HTTP 402 veya engelli). Wayback de engelli. Bu yüzden mekanik bilgisinin büyük kısmı Steam topluluk tartışmalarından, geliştirici cevaplarından ve resmi Software Inc wiki'sinden geliyor. Steam tartışmaları oyuncu gözlemidir, resmi formül değildir; her yerde bunu belirttim. Formülü bulunamayan yerde "bulunamadı" yazdım.

---

## 1. Özet

- Hiçbir referans oyun "üç eksen" modelini oyuncuya olduğu gibi göstermiyor. En yakın örnek Mad Games Tycoon 2: dört alt puan (gameplay, graphics, sound, tech) gösteriliyor ve toplam puan alt puanların ortalaması değil, en zayıfa ağır basan bir bileşik. Kaynak: Steam tartışmaları, aşağıda 2.3.
- Software Inc'de "innovation / stability / usability" kelimelerini oyunun kendi wiki'sinde yalnızca QA özelliğinin açıklamasında buldum: "stability ve usability artar, geliştirme süresi ve innovation pahasına". Eksenlerin sayısal formülünü ve oyuncuya nasıl gösterildiğini bulamadım. Yani bizim eksenlerin kaynağı büyük olasılıkla burası, ama doğrulayamadım.
- Game Dev Tycoon'da eksenler iki tane (Design, Technology) ve puan "kendi önceki en iyi oyununu ne kadar geçtin" ölçüsüne bağlı. Bu, sabit sayının ölçekte kırılması sorununa verilmiş bir cevap. Kaynak: 2.2.
- Mad Games Tycoon 2'de her alt puanın eşiği yıla ve türe göre yükseliyor (1976'da yüzler, 2015'te binler). Yani eşikler sabit değil, dönemle büyüyor. Kaynak: 2.3.
- "Eyleme dönüşen neden" kalıbı: oyuncu eksiği ya bir uyum işaretinden (Game Dev Tycoon'da "+++" kombinasyonları), ya bir rapordan (Game Report ipuçları açar), ya da bir uyarı rengi/rakamdan (Startup Company'de yeşil cevap süresi) öğreniyor. Hiçbirinde "ürünün kararlılığı 4" gibi çıplak bir eksen değeri yok.
- Startup Company'de memnuniyet iki temel özelliğin seviyesinin dengeli olmasından geliyor: biri 10 ise öteki de 10 olmalı. Bu "bir eksik, öteki bol" durumunu cezalandıran bir kalıp, bizim eksenlere uyarlanabilir. Kaynak: 2.4.
- Gerçek dünyadan iki hazır çerçeve var: ISO/IEC 25010 (kalite özellikleri: işlevsel uygunluk, güvenilirlik, kullanılabilirlik vb.) ve Kano modeli (zorunlu / doğrusal / çekici özellik). İkincisi "bir özellik eksikse ne olur" sorusuna doğrudan cevap veriyor.
- Tavsiye (karar Erdem'in): b ya da b ile c'nin karışımı. Ayrıntı bölüm 5'te.

---

## 2. Mekanik döküm

### 2.1 Software Inc (Coredumping)

Ne bulundu:
- Her yazılım türünün bir QA özelliği var ve açıklaması şöyle: "This QA feature will improve stability and usability at the cost of development time and innovation." Sayısal etki verilmemiş. Kaynak: https://softwareinc.coredumping.com/wiki/index.php?title=Software_Types
- Özelliklerin üç kilit tipi var: yıla bağlı, başka yazılımın özelliğine bağlı, bağımlılık ağacı (eski özelliğin yerine geçen evrim; birini seçersin). Aynı kaynak.
- Özellik tanımında (modlama sayfası) `CodeArt` alanı var: 1 = yalnız programcı, 0 = yalnız sanatçı, arası karışım. `DevTime` ay cinsinden. `Server` aktif kullanıcı başına Mbps ve zamanla `1+log10(yıl-1969)` ile ölçekleniyor. Kaynak: https://softwareinc.coredumping.com/wiki/index.php?title=Data_Modding
- Aynı sayfada alt pazar (submarket) memnuniyeti var: alt özellikler alt pazarları daha etkili doyurur, seviye 2 özellik seviye 1'den çok doyurur, seviye 3 özellik alt pazar doyurmaz. `IdealPrice`, "%100 kalite ve ilgide ürünün ideal fiyatı" diye tanımlı. Kaynak: aynı sayfa. Bu, "kalite" kavramının resmi olarak bir 0-100 yüzde olduğunu gösteriyor.
- Oyuncu gözlemi (resmi değil): kod/sanat birim sayısı için tahmini hedef var ('i' simgesiyle görünür), aşmak kaliteyi yükseltmiyor gibi. Kalite çoğunlukla çalışanların toplu becerisinden geliyor. Hatalar kaliteyi yalnız basın incelemesinde bahsedilecek kadar kötüyse etkiliyor; asıl etkisi destek yükü. Kaynak: https://steamcommunity.com/app/362620/discussions/0/1697167803862010528 ve https://steamcommunity.com/app/362620/discussions/0/1696043263502958919
- Hata sayısı gözlemi: orta beceride yaklaşık kod birimi başına 50 hata; Beta'da hatalar önce hızla bulunur, sonra "sürünmeye" başlar. Aynı ikinci kaynak. Resmi değil.
- Hatalar satışı etkiliyor: resmi hızlı başlangıç rehberi "Bugs make people unhappy with the final product and will affect sales/contract payment" diyor. Kaynak: https://softwareinc.coredumping.com/wiki/index.php?title=Quickstart_Guide (rehberin kendisi "güncel olmayabilir" uyarısı taşıyor).
- İnceleme (review) düğmesi ürün kartında: ekip içi veya dışarıdan. Ekip içi "yanlı ve güvenilmez", dışarıdan olan güvenilir sayılıyor. Alfa'da kaliteyi anlamak için kullanılıyor. Oyuncu bir örnekte 7/10 alıp 17 kopya satmış; "7 civarı iyi satmak için gerekli" diyen de var. Kaynak: 1697167803862010528 ve https://steamcommunity.com/app/362620/discussions/0/133263024016652886

Bulunamadı: innovation / stability / usability'nin özellik başına değerleri, ürün kalitesinin formülü, oyuncuya bu üç değerin nasıl gösterildiği. Model bilgisine göre oyunda "kalite" tek bir ölçek olarak (Bad...Outstanding) görünüyor ve Software Inc'de kalite eksen kırılımı olarak değil, tek bir düzey olarak sunuluyor (kaynaksız, model bilgisi). Resmi wiki'de kalite sayfası yok.

### 2.2 Game Dev Tycoon

- Puan, "Design" ve "Technology" toplamlarına dayanıyor. Oyun bitince bir tally ekranı iki toplamı gösteriyor, ardından XP ve inceleme geliyor. Bir oyuncuya göre inceleme ekranı bu tally'yi tekrar ediyor ("gerilim yaratıcı"). Kaynak: https://steamcommunity.com/app/239820/discussions/0/1639788130290877045 (ve aşağıdaki konu özeti)
- İnceleme puanı o oyuncunun daha önce çıkardığı en iyi oyuna göre ölçülüyor: bir rekor yeni 8-9, ikisinde de belirgin rekor 10 verir; 11 "şans". Bu, sabit eşik yerine göreli eşik. Kaynaklar: https://steamcommunity.com/app/239820/discussions/0/1639788130290877045 ve https://steamcommunity.com/app/239820/discussions/0/530646080854935183 (oyuncu gözlemi, resmi değil).
- Altı etken sayılıyor: konu+tür uyumu, geliştirme kaydırıcıları, platform, hedef kitle, motor özellikleri, tech/design dengesi. Kaynak: https://www.cubix.co/blog/guide-for-game-dev-tycoon/ (ticari rehber, resmi değil).
- Uyum işaretleri: Konu-Tür, Konu-Kitle, Tür-Sistem, Sistem-Kitle çiftleri "+++" yaklaşmalı. Oyuncu eksiği buradan okuyor. Kaynak: 530646080854935183.
- Tür başına ideal tech/design dengesi var (RPG daha çok Design, Aksiyon/Yarış daha çok Tech). Kaynak: cubix.
- Yorgun çalışanlar daha az puan üretiyor. Kaynak: cubix.
- Oyuncu bir sonraki oyunda neyi düzelteceğini nasıl öğreniyor: "Game Report" ipuçları açıyor. Bir oyuncu raporun kaydırıcı önceliklerini sıralamak için kullanıldığını söylüyor (en önemli ikisini %100 ve %75, gerisini 0). Kaynak: https://steamcommunity.com/app/239820/discussions/0/648814845094626052 (oyuncu gözlemi) ve cubix.
- Önceki yüksek puanlı kombinasyonun arka arkaya tekrarı cezalı olduğu yönünde oyuncu raporu var; hızlı devam oyunu da cezalı. Kaynak: arama sonucu, steamcommunity.com/app/239820/discussions/0/1471967615877561199 (gözlem).
- Şansın büyüklüğü tartışmalı: "9.75 sık, 10 yirmi saatte 2-3 kez" gibi raporlar var. Kaynak: 530646080854935183.

Bulunamadı: elestirmen yorum metinleri ("grafikler daha iyi olabilirdi" türü). Oyunun resmi wiki'sine ulaşılamadı (Fandom engelli). Aradığım yorum biçimini hiçbir kaynakta doğrulayamadım. Game Report'un içeriği de bulunamadı.

### 2.3 Mad Games Tycoon 2 (Eggcode)

- Her oyunun dört puan toplamı var: Gameplay, Graphics, Sound, Tech. Oyuncular bunları "82/91/99/99 = %88" gibi yazıyor. Toplam basit ortalama değil: "95/99/99/99" %97 veriyor; en zayıf alt puan sonucu çekiyor, birinin fazlası diğerinin eksiğini kapatmıyor. Kaynak: https://steamcommunity.com/app/1342330/discussions/3/3058491773346971759 ve https://steamcommunity.com/app/1342330/discussions/0/3833172420306649053
- Her alt puanın 90%+ için asgari değeri var ve zamanla yükseliyor: bir oyuncu 1976'da Ses ve Grafik için en az 100, Gameplay için 200 kestiriyor; 1977'de neredeyse iki katı; 2015'te binlerce. Yarış türü Ses/Grafik'i daha çok istiyor (kabaca 150/120). Kaynak: 3833172420306649053 (oyuncu tahmini, resmi değil).
- Deneyim "yıldızları": her konu, tür, platform, oyun özelliği ve motor özelliği yıldıza sahip. Eksik her yıldız puana karşı sayılıyor; 3 yıldızın altı zarar veriyor. Zorluk, yıldız eksiğine toleransı belirliyor. Aynı kaynak.
- Çalışan başına saniyede puan üretimi var: kadro büyüklüğü çıktıyı doğrudan büyütüyor. Özel odalar (Grafik, Ses) puanı artırıyor; kurulumu pahalı (tabanda toplam kabaca 1,2 milyon $). Kaynak: 3833172420306649053 ve https://steamcommunity.com/app/1342330/discussions/0/3882722797150504122
- Kaydırıcılar toplam etkinin yalnız bir parçası (bir oyuncuya göre yaklaşık %20). Aynı kaynak.
- Hatalar: hatalı çıkış inceleme puanını düşürüyor, çok hatalı çıkış satışta bir "debuff" yaratıyor; QA personeli hataları geliştirme biterken eritiyor. Kaynak: 3833172420306649053 ve 3882722797150504122.
- Oyuncuya gösterim: QA odası iş yükü kırılımını gösteriyor; oyuncular "gameplay raporu"nda alt puanların ve "sıfır hata"nın en yüksekte olduğu anı bekleyip çıkıyor. Kaynak: 3058491773346971759. Bir oyuncu, gösterilen ortalamanın dört kategorinin ortalamasıyla uyuşmadığını yazıyor (3833172420306649053) — yani toplamın nasıl hesaplandığı şeffaf değil.
- Oyuncu geri bildirimi: "rating system confusing", veri gösterimi kötü, öğretici yok, oyuncular dış wiki'ye bağımlı. Kaynak: https://vaporlens.app/app/1342330/mad_games_tycoon_2.md (oyuncu yorumlarının özeti, ikincil kaynak). Geç oyunda 150+ çalışanda lag ve uzun yükleme raporu da orada.
- Zorluk: yüksek zorlukta eleştirmenler daha talepkâr. Kaynak: 3833172420306649053.

Bulunamadı: bileşik puan formülü (oyuncu gözlemi dışında), "Control" alt puanı. Aradığım ikinci oyunda dört puanın "Gameplay, Graphics, Sound, Tech" olduğu görülüyor; "Control" adlı bir alt puanı hiçbir kaynakta görmedim, bu görevdeki adlandırma muhtemelen birinci MGT'den ya da hatalı.

### 2.4 Startup Company (Hovgaard Games)

- Memnuniyet, iki temel özelliğin seviyesinin dengelenmesinden geliyor. Geliştirici: "evening out the level of both your base features"; örnek: biri seviye 10 ise öteki de 10 olmalı. Kaynak: https://steamcommunity.com/app/606800/discussions/0/1769259642872479689/ (2019, değişmiş olabilir).
- Potansiyel kullanıcı sayısı özellik örneklerinin kalitesinden geliyor (Lead Developer ile yükseltilir); pazarlama potansiyele kadar kullanıcı getirir. Kaynak: https://steamcommunity.com/app/606800/discussions/0/2906376154322956011/
- Cevap süresi üç şeye bağlı: çevrimiçi kullanıcı, örnek verimliliği, sunucu kapasitesi. Özelliği açmak ve kalitesini artırmak kullanıcı başına cevap süresini artırıyor; verimlilik düşürüyor. Cevap süresi "yeşil" tutulmalı. Kaynak: https://steamcommunity.com/app/606800/discussions/0/1489992713701253878/ (formül verilmemiş).
- Oyuncunun şikayeti: kapalı tutulan geliştirme aşamasındaki özellikler bile güncellemeden sonra memnuniyeti düşürmüş; reklam eklemek memnuniyeti düşürmüş; bir oyuncu 1 milyar kullanıcıdan 19 milyona düşmüş. Geliştirici "Beta 16'dan 17'ye dönüşüm fazla sertti" diyor. Kaynak: https://steamcommunity.com/app/606800/discussions/0/1734336452589045402/

Bulunamadı: özellik seviyesi-memnuniyet formülü, memnuniyet kırılımı ekranı, "ürün kalitesi" kavramının tam adı. Kullanıcının istediği "memnuniyet kırılımı"nı doğrulayamadım.

### 2.5 Two Point Hospital

- İtibar bileşenleri (oyuncu listesi): Medical Reputation, Patient Happiness, Pricing, Staff Skill, Media Publicity. Dört bileşen yüksekse fiyat +%20'nin tek başına "Great"in altına indirmediği söyleniyor. Kaynak: https://steamcommunity.com/app/535930/discussions/0/1737715419911378648 (oyuncu gözlemi).
- Fiyat itibarı: bir oyuncu, -%10 ve altı fiyatın zamanla bir puan artırdığını, +%10 ve üstünün düşürdüğünü iddia ediyor (doğrulanmamış); başka oyuncular -%80 ile -%10 arasında fark görmediğini yazıyor. Aynı kaynak.
- Yıldız hedefleri: örnek bir senaryoda hastane değeri hedefi 2 milyon, itibar hedefi %80 üzeri. Aynı kaynak.
- Oda yıldızı 1-5: dekorla yükselir; hastanenin çekiciliği hasta mutluluğunu etkiler ama doğrudan hasta getirmez. Kaynak: https://steamcommunity.com/app/535930/discussions/0/3362406825545786254
- Yeni hasta sayısı hastaların memnuniyetine ve genel itibara bağlı. Kaynak: https://www.gamepressure.com/two-point-hospital/

Bulunamadı: itibarın bileşenlerinin ağırlıkları ve resmi formül. Kaynaklar yalnız oyuncu anekdotu.

### 2.6 Big Ambitions

Bulunamadı. Wiki'ye ulaşılamadı (HTTP 401). Steam tartışma listesinde "işletme puanı" konulu bir başlık görünmedi (ilk 15 başlık). Model bilgisi: işletme başına müşteri memnuniyeti ve itibar gösteriliyor (kaynaksız, model bilgisi). Bu soruya kanıtlı cevap yok.

### 2.7 Gerçek dünya çerçeveleri

- ISO/IEC 25010 (9126'nın yerini aldı): ürün kalitesi sekiz özellikte toplanır; 9126'daki altı grup: işlevsellik, güvenilirlik, kullanılabilirlik, verimlilik, bakım yapılabilirlik, taşınabilirlik. 25010 "işlevsel uygunluk" ve "performans verimliliği" adlarını getirdi. Kaynak: https://en.wikipedia.org/wiki/ISO/IEC_25010. Bizim eksenlere eşleme (benim yorumum): Kararlılık ≈ güvenilirlik, Deneyim ≈ kullanılabilirlik, İnovasyon ≈ işlevsel uygunluk (en zayıf eşleşme).
- Kano modeli: özellikler zorunlu (eksikse güçlü memnuniyetsizlik, varsa yalnız nötr), doğrusal (iyi yapıldıkça memnuniyet artar), çekici (varsa sevindirir, yoksa sorun olmaz), ilgisiz, ters (aşırısı kötü). Kaynak: https://en.wikipedia.org/wiki/Kano_model

---

## 3. Oyuncuya gösterim

| Oyun | Ne gösteriliyor | Kaynak |
|---|---|---|
| Game Dev Tycoon | Bitişte Design ve Technology tally'si, sonra inceleme puanı; seçim sırasında konu-tür-kitle-sistem çiftlerinde "+++" uyum işaretleri; Game Report ipucu açar | 1639788130290877045, 530646080854935183, 648814845094626052 |
| Mad Games Tycoon 2 | Dört alt puan (ör. 82/91/99/99), QA odasında iş yükü kırılımı, "gameplay raporu"; toplam alt puanların ortalaması değil | 3058491773346971759, 3833172420306649053 |
| Software Inc | Ürün kartında İnceleme düğmesi (ekip/dış), 'i' simgesinde tahmini kod/sanat hedefi, ürün kartında hata sayısı | 1697167803862010528 |
| Startup Company | Cevap süresi göstergesi (yeşil/sarı/kırmızı), memnuniyet kullanıcı verisi | 1489992713701253878 |
| Two Point Hospital | İtibar çubuğu ve alt çubuklar (tıbbi itibar, hasta mutluluğu, fiyat...) | 1737715419911378648 |

Ekran görüntüsü URL'leri: Steam mağaza galerisi sayfalarına erişemedim (store.steampowered.com ana sayfa döndü ve doğru sayfa açılmadı), Fandom görselleri engelli. Bu yüzden ekran görüntüsü listesi bulunamadı. Elle bakılacak yerler: https://store.steampowered.com/app/1342330 (MGT2), https://store.steampowered.com/app/239820 (Game Dev Tycoon), https://store.steampowered.com/app/362620 (Software Inc), https://store.steampowered.com/app/535930 (Two Point Hospital) — bu dört sayfa açılıp doğrulanmadı, yalnız uygulama kimlikleri Steam URL'lerinden (tartışma bağlantıları) çıkarıldı.

Oyuncunun ne yapacağını anlaması hakkında ortak gözlem: hepsinde oyuncu eksiği bir sayıdan değil bir uyum/uyarı işaretinden ya da bir rapordan çıkarıyor. MGT2'de ise oyuncular dış wiki'ye gidiyor ve puanın şeffaf olmadığından şikâyet ediyor (vaporlens özeti).

---

## 4. Ölçek ve sorunlar

- Sabit eşiğin kırılması: MGT2'de alt puan eşikleri yıl içinde yüzlerden binlere çıkıyor; yani oyun bunu eşiği sabitlemek yerine döneme göre büyüterek çözüyor. Game Dev Tycoon'da puan, oyuncunun kendi önceki en iyisine göre ölçülüyor; bu da sabit sayıyı gereksiz kılıyor. Ama Game Dev Tycoon'da "rekor kırmazsan 5-6 alırsın" yaklaşımı oyuncuları tutarsız ve şansa bağlı hissettiriyor ("yirmi saatte 2-3 kez 10"). Kaynaklar: 3833172420306649053, 1639788130290877045, 530646080854935183.
- Çalışan sayısı: MGT2'de her çalışan saniyede puan üretiyor, yani kadro büyüdükçe çıktı doğrusal büyüyor; eşik de büyümezse puan taşar. 150+ çalışanda performans (lag) şikâyeti var. Kaynak: 3833172420306649053 ve vaporlens.
- Toplam puanın şeffaf olmaması: MGT2'de gösterilen ortalama dört alt puanın ortalamasıyla uyuşmuyor ve "rating system confusing" yorumu var. Bu, bizim sorunumuzun aynısı: eksenler var ama oyuncu anlamıyor. Kaynak: 3833172420306649053, vaporlens.
- İnceleme güvenilirliği: Software Inc'de ekip içi inceleme "yanlı", oyuncular dış incelemeyi tercih ediyor. Kaynak: 1697167803862010528.
- Gizli ceza: Startup Company'de oyuncu kapalı özelliklerin ve reklamın memnuniyeti sessizce düşürdüğünü yazmış; geliştirici güncellemenin "fazla sert" olduğunu kabul etmiş. Kaynak: 1734336452589045402. Ders: eksen etkisi görünmezse oyuncu cezayı kendisi bulamıyor.
- İstismar: Two Point Hospital'da fiyatı çok düşürmenin ya da yükseltmenin itibara etkisi konusunda oyuncular çelişiyor (-%80 ile -%10 aynı); yani ölçeğin iki ucunda doymuş etki. Kaynak: 1737715419911378648.
- Game Dev Tycoon: aynı kombinasyonun art arda tekrarı cezalı (oyuncu gözlemi) — "sürekli aynı şeyi yap" istismarına karşı bir önlem. Kaynak: arama sonucu / 1471967615877561199.

Patch notu: Startup Company Beta 16→17 dönüşümü ve sonraki hotfix (yeni ürün için en az 15 kilometre taşı) bulundu, ama ayrıntı için yalnız arama özeti var. Kaynak: https://steamcommunity.com/app/606800/discussions/0/1734336452589045402/

---

## 5. Bizim için

Hatırlatma: bu bölüm referansların ışığında benim yorumum. Karar Erdem'in.

### Ortak kalıp (bulgulardan)

Toplam puan + kırılım + eyleme dönüşen neden. Ama bulduğum hiçbir oyun bunu eksiksiz yapmıyor: Game Dev Tycoon neden için uyum işaretleri ve rapor kullanıyor, Mad Games Tycoon 2 kırılımı veriyor ama toplamı şeffaf değil, Startup Company yalnız bir uyarı göstergesi veriyor. Kalitenin özellik kartlarıyla bağı: Game Dev Tycoon'da seçilen özellik/kombinasyon puana, Mad Games Tycoon 2'de her özellik bir alt puana (yeşil/sarı renk ve maliyet rehber), Startup Company'de özelliğin seviyesi doğrudan memnuniyete bağlanıyor.

### Seçenek (a): Eksenleri kaldırmak

- Referans: Startup Company (özellik seviyesi tek ölçü; ürün başına tek "kalite/memnuniyet" yönü) ve Software Inc'in tek kalite düzeyi (model bilgisi).
- Güçlü yan: oyuncunun hiçbir yerde göremediği bir şeyi taşımayız; kod ve içerik sadeleşir; "ne temsil ediyor" sorusu ortadan kalkar. Hata sistemi (Faz A'da kurulan açık hata) zaten ayrı bir kalite kanalı.
- Zayıf yan: "nerede eksik" sorusunun cevabı kalkar; oyuncu hangi hatta yatırım yapacağını yalnız satış rakamından çıkarır. Kartlar arası fark silinir (K1/K2/K3 tek yöne iner).

### Seçenek (b): Eksenleri oyuncuya anlamlı göstermek

- Referans: Mad Games Tycoon 2 (dört alt puan, en zayıf olan ağır basar), Game Dev Tycoon (uyum işaretleri, Game Report), Kano (hangi eksik ne kadar acıtır).
- Nerede: ürün ekranında hat başına küçük bir kırılım; her hatta ve her sürüm notunda; müşteri/pazar tarafında "şunu istiyorlar". Ürün ekranı, hat paneli ve sürüm notu zaten var.
- Nasıl: sabit sayı yerine göreli ölçü. Eksik değeri, o pazar dilimi veya rakip beklentisine göre gösterilmeli (Game Dev Tycoon "kendi en iyin", MGT2 "döneme göre eşik" kalıbı). Böylece 20-50 çalışanda sayı bozulmaz. Eksenin adı bir sayı değil bir cümle taşımalı: "Kararlılık: yeterli. Deneyim: kurumsal müşteriler için zayıf."
- Ne söyleyerek: Kano mantığıyla eksiği iki türe ayırmak. "Zorunlu" eksik (kararlılık) müşteriyi kaybettirir, çekici eksik (inovasyon) sadece büyümeyi sınırlar. Referans: Kano modeli.
- Güçlü yan: kullanıcının asıl isteğini ("nerede eksik") doğrudan cevaplar; mevcut eksen altyapısı kullanılır.
- Zayıf yan: MGT2'nin başına gelen: toplam şeffaf olmazsa "rating system confusing" şikâyeti geliyor. Üç eksen az sayıda ama toplama kuralı (en zayıf mı, ortalama mı) açıkça yazılmak zorunda. Eksenler özelliklere bağlandığı için hatta tek eksene yığılan kart seti dengesizlik yaratır (Startup Company'nin iki temel özellik dengesi kuralı bunun cevabı).

### Seçenek (c): Başka bir kalite modeli

- Referans 1: Startup Company'de iki temel özelliğin seviye dengesi. Kalite ekseni yerine "bu hattın K1/K2/K3 seviyesi dengeli mi" sorusu.
- Referans 2: Software Inc alt pazar mantığı; özellik hangi pazar dilimini ne kadar doyuruyor. Bizde pazar dilimi = B2B müşteri tipi / B2C kitle segmenti. Ürün kalitesi tek sayı değil, segment başına doyurulma.
- Referans 3: Kano modeli, kalite eksenleri yerine kartların kendisini sınıflamak (zorunlu / doğrusal / çekici).
- Güçlü yan: "kalite" doğrudan satışla ilgili tek bir şeye bağlanır (hangi müşteri tipi memnun), eksen adlandırma sorunu kalmaz.
- Zayıf yan: yeni bir veri modeli (segment talepleri) ve yeniden dengeleme gerekir; Faz C ve D kapsamını büyütür.

### Alınacak, alınmayacak, uyarlanacak

- Alınacak: kırılımın göreli olması (kendi önceki en iyi ya da dönem/segment beklentisi); kalite eksiğinin bir cümleyle yazılması (referans: Game Dev Tycoon'un uyum işaretleri, Mad Games Tycoon 2'nin sert dersi).
- Alınmayacak: çıplak eksen sayısını tek başına göstermek ve toplamı gizli bırakmak (MGT2 şikâyeti); gizli ceza (Startup Company şikâyeti); sabit ve yıla bağlı olmayan eşik (MGT2'nin bile eşiği döneme göre büyüttüğü görüldü).
- Uyarlanacak: dengeyi bozan ceza (Startup Company'nin iki özellik seviyesi dengesi) bizde "bir ekseni diğerlerinden çok geride bırakma" kuralına çevrilebilir; en zayıf ekseni öne çıkaran toplam (MGT2) uygulanırsa 20-50 çalışanda da bozulmaz çünkü orantı korunur.

Kişisel eğilim (kanıta göre): (b), ama toplam kuralı ekranda açıkça yazılı ve göreli eşikle. (a) en ucuz ama kullanıcının asıl sorusunu cevapsız bırakır. (c) en temiz ama en pahalı; Faz C/D için ayrı bir tasarım turu ister.

---

## 6. Bulunamayanlar

- Software Inc: özellik başına innovation/stability/usability değerleri, kalite formülü, bu değerlerin oyuncuya gösterimi. Resmi wiki'de kalite sayfası yok; Fandom engelli.
- Game Dev Tycoon: eleştirmen yorum metinleri ve Game Report içeriği. Resmi wiki (Fandom) engelli.
- Mad Games Tycoon 2: bileşik puan formülü; "Control" alt puanı hiçbir yerde görülmedi.
- Startup Company: özellik seviyesi-memnuniyet formülü, memnuniyet kırılımı ekranı. Konular 2018-2019 tarihli.
- Big Ambitions: işletme puanı kırılımı; hiçbir kaynak bulunamadı.
- Two Point Hospital: itibar bileşen ağırlıkları, resmi formül.
- Ekran görüntüsü URL'leri: hiçbiri doğrulanamadı.
- Yöntem sınırı: WebSearch bütçesi 8 aramaya ulaştı (biri hata verdi), bu yüzden sonrasında bildiğim Steam URL'lerini WebFetch ile okudum. Fandom wiki'leri, Reddit ve Wayback bu ortamda açılmadı. Steam sayfalarından biri 429 verdi.
- Ek not: Steam tartışma kaynaklarının çoğu oyuncu anekdotu; resmi mekanik olarak okunmamalı.


---

## 7. Tamamlama (2026-10-17, başsız Chrome)

Kaynak durumu: Software Inc resmi wiki'sinin sayfa listesi ve veri modlama sayfası, Game Dev Tycoon wiki'si (Review Algorithm, Bugs, Critics), Startup Company wiki'si (Change Log, Researcher), Two Point Hospital wiki'si ve ekran görüntüleri okundu. Big Ambitions (wiki.gg) açılmadı (üç denemede HTTP 401 ve boş sayfa).

### 7.1 Software Inc: üç eksen resmi veri alanı değil (kapanan boşluk, olumsuz yönde)

- Resmi wiki'de özellik tanımı alanları: Name, Spec, Description, Dependencies, Unlock, DevTime, Submarkets (üç değerli alt pazar oranı), CodeArt, Server, Optional, SoftwareCategories, Features; alt özellikte Level. "Innovation", "Usability" ve "Stability" alanı YOK. Wiki'nin tamamında bu üç kelime yalnız QA özelliğinin açıklamasında geçiyor: "stabilite ve kullanılabilirliği artırır, geliştirme süresi ve yenilik pahasına." Kaynaklar: https://softwareinc.coredumping.com/wiki/index.php/Data_Modding , https://softwareinc.coredumping.com/wiki/index.php/Software_Types , https://softwareinc.coredumping.com/wiki/index.php/Special:AllPages (30 sayfa, Quality ya da Bugs sayfası yok). Düzeltme: §1'de "bizim eksenlerin kaynağı büyük olasılıkla burası" cümlesi zayıf; kaynak yalnızca bir tooltip cümlesi. Alt pazar oranı ("Submarkets", üç değer) ise gerçek bir veri: özelliğin üç alt pazarı ne kadar tatmin ettiğini belirliyor; ekranda üç köşeli üçgen olarak görünüyor (benim eşlemem, görüntüde "Submarkets" yazmıyor): "Market targeting" üçgeninin köşeleri Simplicity, Security, Customization (bir işletim sistemi tasarım belgesinde), altında "Market satisfaction" çubukları. Kaynak: https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/362620/ss_a3008f0189f7ee81f9c9fbf6cb8edccaf42c3223.1920x1080.jpg?t=1763102408
- Oyuncuya gösterim: çalışan penceresi "Effectiveness" ve "Team Compatibility" çubukları ve "Satisfaction" cümleleri; tasarım belgesi pazar memnuniyeti çubukları. Ürün kalitesi için tek bir ekran görüntüsünde sayı yok. Kaynak: https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/362620/ss_a3008f0189f7ee81f9c9fbf6cb8edccaf42c3223.1920x1080.jpg?t=1763102408
- Hata: resmi wiki'de hata sayfası yok; veri modlama örneğinde bir betik yorumu "her 100. aktif kullanıcı için üründen 1 hata sil" diyor (mod örneği). Oyuncu rehberi: sözleşmelerde hata başına ceza var; dış inceleme ürün başına 100 birim ve yayın öncesi kalite okuması verir (https://steamcommunity.com/sharedfiles/filedetails/?id=1198857114).

### 7.2 Game Dev Tycoon: kalite çarpanları ve hata oranı (kapanan boşluk: Game Report ve eleştirmen içeriği)

- Oyun puanı g = (Design + Tech) / (2 x boyut çarpanı) x q x p x o x r x t: q tasarım kararları ve denge kalitesi, p platform-tür, o konu-hedef kitle, r hata oranı, t trend. Hata oranı r = 1 - 0,8 x [hata x 100 / (Tech + Design)] (köşeli parantez 0-100'e kırpılır). r < 0,9 "Too many bugs", r <= 0,6 "Riddled with bugs" mesajı. Yani hata, toplam puanın yüzdesi olarak ölçülüyor (mutlak sayı değil) ve tek başına çarpan. Kaynak: https://gamedevtycoon.fandom.com/wiki/Review_Algorithm (sürüm 1.3.9, "Outdated" şablonlu)
- Eleştirmen yorumu üç kuyruktan seçiliyor: iyi mesajlar, kötü mesajlar (hesaplama sırasında üretilir), standart mesajlar. Mesajlar nedeni etiketli cümlelerle söylüyor: "good balance"/"bad balance", "focus on X served game well", "focus on X is a bit odd", "shouldn't forget about X", "Strange combination", "Great combination", "Genre does not work well on Platform", "Theme is an horrible theme for Audience", "Too many bugs". Puan > 2 ise bir olasılıkla iyi mesaj, puan < 6 ise kötü ya da standart mesaj çıkar. Yani oyuncu hangi çarpanın düştüğünü cümleyle öğreniyor ama puan etkisini sayıyla öğrenmiyor. Kaynak: aynı sayfa
- Dört yayın: Star Games, Informed Gamer, Game Hero, All Games; sonuncusu "adaletsiz" bulunduğu için oyuncu şikâyeti almış. Kaynak: https://gamedevtycoon.fandom.com/wiki/Critics . "Game Report" için ayrı sayfa yok.
- Hata üretimi: her Tech/Design puanı için hata olasılığı seviye 1 çalışanda %31, seviye 1 yöneticide %16, taban %6; hatalar "Finishing" aşamasında birkaç haftadan bir aya sürede silinir. Kaynak: https://gamedevtycoon.fandom.com/wiki/Bugs
- Bu, §4/§5'teki "kalite eksenlerini tek sayı yerine cümleyle gösterme" önerisini doğruluyor: GDT zaten çarpan başına etiketli cümle kullanıyor, puanı gizli tutuyor.

### 7.3 Startup Company: memnuniyet ve özellik etkisi (kapanan boşluk: kısmen)

- Wiki'de memnuniyet için ayrı sayfa yok. Change Log (Beta 17.0, 24 Ağustos 2018): "ürün memnuniyeti eklendi", "gelire dayalı özellikler eklendi: abonelikle gelir, reklam alanı satarak gelir", "sözleşme işi kaldırıldı", "memnuniyet değişkeninin getirdiği ürün ilerleme kaybı dengelendi". Milestone 8: "en az %75 memnuniyet". Kaynak: https://startupcompany.fandom.com/wiki/Change_Log ve https://startupcompany.fandom.com/wiki/Milestones
- Her özelliğin bir "hype" yüzdesi var (Landing Page +%10, Login System +%14, Comment +%18, Payment System +%20, Chat System +%28, Live Streaming +%45, Intrusion Prevention System +%50); yani özellik değeri ürünün kullanıcı çekme gücüne ("hype") yazılıyor; Beta 17 sonrası model olarak temel özellikler memnuniyet, gelir özellikleri memnuniyetsizlik üretiyor (R2 §2.4). Kaynak: https://startupcompany.fandom.com/wiki/Researcher
- Ürün kartı ekranı: ürün kartında sıra (#44), %100, %39 (Stats ekranındaki sunucu kadranıyla aynı), kalabalık ikonlu %70 (anlamı yazılı değil, memnuniyet olabilir) ve değişim (+2) rozeti; Stats penceresinde "Registered Users", "Potential Users" ve "Valuation". Memnuniyet kırılımı ekranı yok; yalnız %70 gibi tek bir rozet (https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/606800/ss_74de0b0d767febb4e7d11406b38e199884f3d678.1920x1080.jpg?t=1727681373 sağ üst kart ve https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/606800/ss_60b0b2a8fb13081564c418913f9afbebe78c3562.1920x1080.jpg?t=1727681373).

### 7.4 Two Point Hospital: itibar kırılımı (kapanan boşluk)

- Wiki: itibar "her başarılı tedaviyle artar, bir tedavi başarısız olursa, özellikle hasta ölürse azalır; hastanedeki insanların mutluluğuna, aldığınız fiyatlara ve hastanenin gördüğü tanıtıma da bağlı." Olay etkileri: Successful Treatment +1; Patient Sent Home -0,25; Ineffective Treatment -1; Patient Rage Quits -0,5; Patient Death -2; Patient Waited Too Long -0,25. Bantlar: Very Poor, Poor, Fine (%50-60), Good (%73), Great (%86-100). Yüksek itibar daha çok hasta ve daha iyi personel çeker. Hastane seviyesi (Hospital Level, azami 30) odalara, personele ve odaların prestijine bağlı; seviye 1'de her pozisyon için 3, seviye 5'te 4, seviye 10'da 5, seviye 15'te 6 aday çıkar. Kaynak: https://two-point-hospital.fandom.com/wiki/Hospitals . Bu, "kalite bileşenlerini etkinlik başına sabit bir artı/eksi puanla göstermek" için somut bir örnek; her bileşen ağırlığı yazılı (oyuncunun dış kaynağa bakmasına gerek yok).
- Yıldız derecelendirme (Star Rating) hedeflerle (Objectives) kazanılır, formül değil; ödül para, Kudosh, yeni oda ve hastane. Aynı kaynak.

### 7.5 Mad Games Tycoon: puan kırılımı (kısmen)

- MGT1'de (farklı oyun): "grafik, kontrol ve ses ölçülür, ortalaması alınır, değiştiriciler eklenir, rastgele -%9 ile +%7 oynatılır"; MGT2 için arama özeti dördüncü puanın "Technical" olduğunu söylüyor (doğrulanamadı, kapalı wiki). Kaynaklar: https://mad-games-tycoon.fandom.com/wiki/Game_Development ve R3 §7.3. "Control" alt puanı için MGT2 kaynağı hâlâ yok.

### 7.6 Ekran görüntüleri

- Software Inc, Startup Company, MGT2, Game Dev Tycoon ve Football Manager 26 mağaza sayfalarından alınan URL'ler: Software Inc ve Startup Company R1 §7.4 ve R2 §7.7'de (içerikleri gözle okunmuş); GDT ve MGT2 R3 §7.4'te (yalnız URL); Football Manager 26 (Steam uygulama no 3551340, 10 görüntü, içeriği görülmedi):
https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/3551340/f306d9f41c4a1a037ae6cecf4b105442fc1065fd/ss_f306d9f41c4a1a037ae6cecf4b105442fc1065fd.1920x1080.jpg?t=1781176251
https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/3551340/e38bb87786e442e3da9820f5139d7572d8dbe244/ss_e38bb87786e442e3da9820f5139d7572d8dbe244.1920x1080.jpg?t=1781176251
https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/3551340/52aaa51b9b4519b05dd11234135091638e193ae7/ss_52aaa51b9b4519b05dd11234135091638e193ae7.1920x1080.jpg?t=1781176251
https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/3551340/fa75547d1aa686774c07f54e45b159ff9b752b2e/ss_fa75547d1aa686774c07f54e45b159ff9b752b2e.1920x1080.jpg?t=1781176251
https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/3551340/b5af1724ed14754e8b40d083539a65955e0d6417/ss_b5af1724ed14754e8b40d083539a65955e0d6417.1920x1080.jpg?t=1781176251
https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/3551340/e47dc2155cfca688d2ba0e4f5efbeaa58d0ac7dd/ss_e47dc2155cfca688d2ba0e4f5efbeaa58d0ac7dd.1920x1080.jpg?t=1781176251
https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/3551340/005a1c1b6b3c19132f2b00fc28c0665f1b1c38c8/ss_005a1c1b6b3c19132f2b00fc28c0665f1b1c38c8.1920x1080.jpg?t=1781176251
https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/3551340/2e541308b27a73bee6fbed4fdc47eb261c4f0eb1/ss_2e541308b27a73bee6fbed4fdc47eb261c4f0eb1.1920x1080.jpg?t=1781176251
https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/3551340/90d8938f09dac1452d1439d1ced434a31796326c/ss_90d8938f09dac1452d1439d1ced434a31796326c.1920x1080.jpg?t=1781176251
https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/3551340/0f9eb2837c5e2dbf514156ebdad8a3c5894ab611/ss_0f9eb2837c5e2dbf514156ebdad8a3c5894ab611.1920x1080.jpg?t=1781176251

### 7.7 Bu tamamlamanın §6 listesine etkisi

- Kapandı: GDT hata oranı ve inceleme mesaj yapısı (Game Report yerine inceleme mesaj kuyruğu), TPH itibar bileşen ağırlıkları (olay başına puan), Software Inc eksen alanlarının resmi olmadığı, ekran görüntüsü URL'leri.
- Hâlâ bulunamadı: Software Inc özellik başına innovation/usability/stability sayıları (resmi veride yok), MGT2 "Control" ve bileşik puan formülü, Startup Company memnuniyet formülü ve kırılım ekranı, Big Ambitions işletme puanı kırılımı.
