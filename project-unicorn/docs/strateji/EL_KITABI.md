# Project Unicorn el kitabı
2026-10-19 · Okuyucu: Erdem ve yardımcı yönetmen oturumu.

Nasıl okunur:
- Her iddianın yanında kaynak etiketi var. [R1 9] = R1 raporunun 9 numaralı kaynağı. [R7 §2] = iç inceleme, bölüm 2. [V] = kaynak denetimi.
- Denetimin düzelttiği iddia burada düzeltilmiş hâliyle yazıldı. Denetimin "doğrulanamadı" dediği iddia "(doğrulanamadı)" diye işaretli.
- "Görüş:" ile başlayan satır benim çıkarımımdır, kanıt değildir.
- Raijin, Gamalytic ve VG Insights sayıları tahmindir; denetim yalnız doğru aktarıldıklarını gösterir [V].
- Ayrıntı ham raporlardadır; bağlantılar ekte.

Erdem'in sonradan verdiği kararlar (2026-10-19):
- Steamworks hesabı onaylı, 100 USD ödendi; sayfa istendiği an incelemeye gönderilebilir. Bölüm 1.5 ve 7.1'deki "hesabı aç" adımı kapandı.
- B2C demoda kalır. Bölüm 7.3 madde 2 ve K2'deki "yalnız B2B" önerisi geçersiz; B2C'nin orta oyunu (kartsız haftalar, fiyat kolu) demonun önündeki bir iş olur.

---

## 0. Kısa cevaplar

**1. Steam sayfası elimizi kolumuzu bağlar mı?**
Hayır, çoğu şey bağlanmaz. Valve sayfayı bir kez inceler; onaydan sonra kapsülü, ekran görüntülerini, fragmanı, açıklamayı ve etiketleri sen değiştirirsin, yeniden inceleme yok [R1 2][V]. Kilitlenenler: oyun adı (incelemeden sonra), çıkıştan önceki son 2 haftada tarih, yapay zekâ anketinin bazı soruları, oyun başına tek Next Fest [R1 7][R1 3][R1 13][R1 18][V]. Asıl bağ yumuşaktır: tür ya da sanat yönü kökten değişirse erken wishlist'çiler şaşırır, değer düşer [R1 1][R3 19][V].

**2. "Bitti" denen her şeye geri dönmek doğal mı?**
Kısmen doğal: başarılı oyunlarda da dilim büyütülünce sistemler bozuldu (Pope, ~1,5 ay kayıp), Mini Metro arayüzü baştan kurdu [R3 10][R3 6][V]. Ama bizim kayıtta 17 yeniden açılışın 11'i yeni modülden değil, kod yazıldıktan sonra verilen zevk ya da playtest kararından doğmuş; entegrasyon kaynaklı olan yalnız 1-2 tane [R7 §2]. Görüş: Erdem'in tarif ettiği "yeni modül eskisini açar" deseni gerçek ama azınlık; çoğunluk düzenimizden doğuyor ve önlenebilir.

**3. 3-5 kişilik ekipler nasıl çalışır, dağılıyor muyuz?**
Kaynaklar sıkı aşama kapısı kullanan küçük ekip göstermiyor; ortak nokta, oynanabilir sürümün çok erken dış oyuncuya gitmesi (Mini Metro prototipten 5 ay sonra tarayıcıda, RimWorld duyurudan 7 hafta sonra alfa) [R3 6][R3 12][V]. Biz 115 günde 404 commit ve 20 görev belgesi ürettik ama 14. haftanın ötesini oynayan insan oturumu yok, dış oyuncu hiç yok [R7 §0][R7 §5.3]. Görüş: evet, dağılıyoruz; kapsam büyüyor (Rakip Dünyası, mahalle, Piyasa, 13 sektör), demo tanımı üç yerde üç farklı [R7 §5.1][R7 §7.10].

**4. Neredeyiz?**
Çekirdek döngü uçtan uca çalışıyor: bot koşuları sona varıyor, kayıt geri geliyor [R7 §5.2]. Ama prototipin çıkış ölçütü olan "döngü eğlenceli mi" insanla sınanmadı, görsel dil kilitlenmedi, ses tek MP3 ve SFX yok, doruk formalite [R3 14][R7 §5.3]. Görüş: prototip ile dikey kesit arasındayız; 7 Ekim'deki dört kırık alandan biri kapandı [R7 §5.3].

**5. Nasıl ayrışırız?**
Kanıta göre oyuncu yapay zekâyı değil görünür kestirmeyi cezalandırıyor (Vapor World, %36) ve "asset flip" etiketi tek paketten değil bütünüyle jenerik görünümden doğuyor [R4 10][R4 16][V]. En ucuz yüksek etkili adım kapsülü dış sanatçıya vermek ($250 ile birkaç bin dolar) [R4 5][V]. Görüş: font ailesi kaynakların önerdiği türden; zayıflık büyük ihtimalle hiyerarşi, boyut ve izleme ayarında. Blender MCP için bağımsız kalite kanıtı yok; kritik yolda olmamalı [R4 23][V].

**6. Yol haritası ve "İncil" var mı?**
Tek kaynak yok. Aşama kılavuzları büyük stüdyolar ya da araç satıcıları için; 1-5 kişi için sayısal ölçüt bulunamadı [R3]. Görüş: 6 kaynağın birleşimi (bölüm 8) ve bölüm 7'deki koşullu harita. Takvimi Next Fest tarihleri belirler [R1 20][V].

**7. Başarılılar ile başarısızları ayıran ne?**
Başarılılar: tek cümlelik kanca, çıkıştan önce büyük wishlist ve içerik üreticisi hazırlığı, oynanabilir çekirdek, düzenli güncelleme (Big Ambitions: 93 bin wishlist, ~1.000 içerik üreticisi) [R2a 38][V]. Başarısızlar: bozuk ya da tekrar eden döngü, kancasızlık, az wishlist, sessizlik ve terk [R2a 25][R1 28][R2b 32][R3 17]. Pazar acımasız: 2025 çıkışlarının %48,7'si 10 yorumun altında, kötü başlangıçtan kurtulma ~%0,2 [R2b 2][R2b 28][V].

**8. Ajan düzenimiz zarar veriyor mu?**
Kısmen. Doğrulama kapıları, taze bağlamlı inceleme ve tek yazarlı iş kanıtla destekleniyor [R8 1][R8 8][V]. Zarar veren: zevk kararının koddan sonra verilmesi (14 revizyon döngüsünün 6'sında ret oyun içinde geldi, en pahalı aşama) ve kapıların "çalışıyor mu"yu ölçüp "hissettiriyor mu"yu ölçmemesi [R7 §3][R7 §7.1]. Çare: zevk kararı koddan önce, iki katlı "bitti", her fazda Erdem'in oynadığı dilim (bölüm 4).

**9. Demo gecikmesi ve "slop" korkusu doğru mu?**
Korkunun yarısı haklı: demo yorumları kalıcı, kötü başlangıçtan kurtulma çok nadir [R5 2][R2b 27][V]. Yarısı değil: erken sayfanın kalıcı ceza getirdiğine örnek bulunamadı ve beklemek wishlist birikimini de bekletir; fest kazancı fest öncesi wishlist'le güçlü ilişkili [R5][R5 1][V]. Görüş: riski üçe ayır (sayfa düşük, demo orta, çıkış yüksek) ve her birine ayrı çıta koy; demonun önüne kapalı playtest koy.

---

## 1. Steam sayfası

### 1.1 Ne serbest, ne incelemeye tabi, ne kilitli

Genel kural: Valve sayfayı ve build'i ilk çıkıştan önce birer kez inceler. Onaydan sonra "yeniden incelemeye gerek yok, istediğin kadar güncelle" [R1 2][V]. Valve alan alan bir istisna listesi vermiyor; canlı sayfa düzenlemesinin incelemeye girip girmediğini belge söylemiyor [V].

| Alan | Durum | Kaynak |
|---|---|---|
| İlk mağaza sayfası | İncelemeye tabi. En az 7 iş günü önce gönder (~9-10 takvim günü); tipik 3-5 iş günü | [R1 1][R1 12][V] |
| İlk build | Ayrıca incelemeye tabi; "near-final build" uyarısı var | [R1 2][V] |
| Coming Soon'a geçiş | Onaydan sonra yeşil düğmeye sen basarsın. Onaylı sayfa basılmadan bekleyebilir | [R1 1][V] |
| Kapsül, ekran görüntüsü, fragman, açıklama | Serbest (Publish). Kurallara uymayan kapsülün görünürlüğü kısılır | [R1 6][R1 9] |
| Etiketler | Serbest, Tag Wizard "her an"; çıkıştan önce en az 5, görünür en çok 20 | [R1 21][V] |
| Dil ekleme | Güncellemeyle eklenir; onay süreci anılmıyor | [R1 22][V] |
| Çıkış tarihi | Serbest, sayı sınırı yok; çıkıştan 2 hafta önce kilitlenir | [R1 3][V] |
| Oyun adı | İncelemeden sonra kilitli. Yalnız destek talebi ya da Profile Features ile | [R1 7][V] |
| YZ içerik anketi | Onaydan sonra bazı sorular destek olmadan düzenlenmez (genel SSS kuralı) | [R1 13][V] |
| Next Fest | Oyun başına bir kez | [R1 18][V] |
| Erken Erişim (EA) | Çıkınca Coming Soon'a ya da EA'ya dönülmez; kalıcı indirim yok; fiyat artışından SONRAKİ 30 günde indirim yok; fiyat başka mağazadan yüksek olamaz | [R1 16][V] |

Erdem'in sorusu, "demo sonrası bir şey ekler ya da çıkarırsak?":
- Kural açısından serbest. Tek şart, sayfanın "yalnız çıkışta mevcut özellikleri" göstermesi; çıkan özelliğin ekran görüntüsü ve açıklaması kaldırılır [R1 2].
- Yumuşak bedel: Valve, sanat yönü ve çekirdek özellik seti oturana kadar beklemeyi tavsiye ediyor, çünkü büyük değişiklik erken wishlist'çileri şaşırtır [R1 1][V]. Zukowski: wishlist yaşlanmaz; istisna tür ya da tonun kökten değişmesi [R3 19][V].
- Sayfa açıkken ad ya da kapsül değiştirip satışı artıran vakalar var (Kingdom Workshop, Son of a Witch) ama tek vaka ve denetlenmedi (doğrulanamadı) [R1 24][R1 26][V]. Köklü sanat dili değişiminin rakamlı örneği bulunamadı [R1].

### 1.2 Ekran görüntüsü, kapsül, fragman

- Ekran görüntüsü: en az 5, 1920x1080, yalnız oyun içi; konsept çizim, ön-render sinematik, ödül ya da pazarlama yazısı yok. Menü ekranı yalnız oyunun benzersiz parçasıysa. En az 4'ü "tüm yaşlara uygun" işaretlenir [R1 8][V].
- Kapsül: yalnız oyun sanatı, oyun adı ve resmî alt başlık. Puan, ödül, indirim, "Wishlist now" gibi çağrı yasak. 1 Eylül 2022'den beri; ihlalde görünürlük kısılır, resmî indirim ve etkinliklerden dışlanır. Yeni içerik için en çok 1 aylık "Artwork Override" ayrı bir yol [R1 9][V].
- Kütüphane hero görselinde hiç yazı yok; logo şeffaf zeminde [R1 10][V].
- Fragman: ilk fragmanın "ağırlıkla oynanış" olması tavsiye, yüzde kuralı yok. 1920x1080, en az 5.000 Kbps [R1 11][V].
- Ekran görüntüsü sırası önerisi (pazarlama blogu, Valve verisi değil): 1) eylem anında çekirdek döngü, 2) kanca, 3) sistem ve arayüz, 4) ilerleme, 5) çeşitlilik. İlk görsel küçük boyda türü söylemeli [R4 6].
- Görüş: bizim için 1 = ofis ve sprint akarken, 2 = Frank ya da karar kâğıdı, 3 = yoğun sistem ekranı. Arayüz ağır görüntüler "menü yalnız benzersizse" sınırına yakın; ekranın oynanış anı olduğu görünmeli [R1 8].

### 1.3 Yapay zekâ beyanı: bizde ne beyan edilir

Kural (Ocak 2026 yeniden yazımı, en güncel metin) [R1 14][V]:
- Beyan dışı: iş akışı verimliliği araçları, örneğin kod yardımcıları.
- Beyan içi: oyunda, mağaza sayfasında ve pazarlama malzemesinde çıkan üretken YZ içeriği; oyun çalışırken üretilen içerik.
- Anket iki türü ayırır: "önceden üretilmiş" (oyunla gelir, oyuncu tüketir: sanat, ses, anlatı, yerelleştirme) ve "canlı üretilen" (oyun çalışırken) [R1 13][V].
- Beyan pazarlamayla tutarlı olmalı; ön incelemede kontrol edilir [V].
- Mağaza sayfasında nasıl göründüğünü güncel belge söylemiyor. 2024'te Valve'in "büyük kısmını sayfada göstereceğiz" dediği haber (doğrulanamadı) [V].

Bizim envanter (Görüş, Valve tanımına göre):

| İçerik | Beyan | Dayanak |
|---|---|---|
| GDScript kodu (Claude ajanları) | Hayır | [R1 14] |
| Olay metinleri, kâğıtlar, Frank'in sözleri, TR/EN yerelleştirme (ajan taslağı, Erdem düzeltisi) | Evet, önceden üretilmiş | [R1 13] |
| Mağaza açıklaması ajan yazdıysa | Evet | [R1 14] |
| Tek MP3 müzik (YZ aracıyla üretildi) | Evet, ses | [R7 §5.3][R1 13] |
| Quaternius CC0 karakterleri | Hayır, YZ değil | [R1] |
| Oyun çalışırken üretilen içerik | Yok | |

Etki verisi (hepsi ikincil, birincil rapor okunamadı): Game Oracle'a göre beyanlı oyunlar benzerlerinden ~%53 daha az YORUM alıyor; puan farkı küçük: %84,6 ile %88,3 (en az 100 yorumlu oyunlar). Nedensellik kanıtlanmadı [R4 12][V]. "Puan %53 düşük" ifadesi yanlıştır [V].
Görüş: beyanı dürüst ve tam yaz; form onaydan sonra kolay düzenlenmez [R1 13]. Oyuncular gizlenen kullanıma daha sert tepki veriyor (The Alters) [R6 17]. Savunma beyanı daraltmak değil, oyuncuya görünen yüzeyde görünür kestirme bırakmamaktır [R4 10].

### 1.4 Demo ve Next Fest kuralları

- Demo ayrı App ID'dir, temel oyuna bağlanır. Kendi sayfası isteğe bağlı (en az 5 demo ekran görüntüsü); sayfası varsa ayrı yorum alır [R1 17][V]. İkincil kaynağa göre demo yorumları kalıcı [R5 2][V].
- Wishlist'çilere bildirim: demo ilk oynanabilir olunca ilk 2 hafta içinde bir kez [R1 17][V].
- Demo güncellenir; "Deactivate Demo" ile kapatılır. Valve festten sonra demoyu açık bırakmayı önerir, kaldırılacaksa önceden duyurulmasını ister; süre şartı yok [R1 17][V].
- Next Fest koşulları: oyun başına bir kez; sayfa yayında ve herkese açık; fest başlarken herkese açık oynanabilir demo; oyun festten sonra çıkacak; kayıt oyundan yapılır [R1 18][V]. Şubat 2027 sayfası "çıkış tarihinden bağımsız" diye kendisiyle çelişiyor; destekle teyit edilmeli [V].
- Tarihler [V]:

| Fest | Fest | Kayıt son | Demo ve sayfa incelemeye | Tüm öğeler |
|---|---|---|---|---|
| Şubat 2027 | 22 Şub - 1 Mar | 10 Ocak 2027 23:59 PST | 25 Ocak | 8 Şubat (basın önizlemesi 11 Şubat) |
| Haziran 2027 | 14-21 Haz | 25 Nisan 2027 23:59 PDT | 17 Mayıs | 31 Mayıs |

### 1.5 Sayfayı ne zaman açmalı, açınca neye bağlanırız

Kanıt:
- Coming Soon çıkıştan en az 2 hafta önce açık olmalı [R1 1][V].
- Steam Direct ücreti uygulama başına 100 USD, 1.000 USD brüt gelirde mahsup edilir [R1 5][V]. Vergi doğrulaması 30 güne kadar sürebilir; onboarding sayfası ilk oyunlar için ücretten sonra 21 günlük bekleme yazar, Release Process yazmaz (çelişki gerçek) [R1 4][V].
- Zukowski (Mart 2025): beş koşul sağlanınca aç, geciktirme: tür sabit, sanat stili sabit (final olmak zorunda değil), üç farklı ortam, profesyonel kapsül, ~30 sn oynanış fragmanı. "Gri kutu ve hazır motor varlığıyla açma" [R5 5][V].
- Karşı görüş: San Filippo, cilasız görünen oyunun sayfasını açmak "neredeyse hiç iyi fikir değil" der [R5 6][V].
- "Çıkıştan 6-12 ay önce aç" sayısı (doğrulanamadı) [V].
- Fest kazancı fest öncesi wishlist'le güçlü ilişkili (Spearman r=0,825, Şubat 2026 verisi, ikincil) [V]. 1.000 altı wishlist'le başlayan hiçbir oyun festte 10.000+ katmanına çıkamadı; bu grubun medyan kazancı 462 [R5 1][V].

Açınca bağlandıklarımız: ad, topluluk merkezi ve wishlist'çilerin tür ve stil beklentisi, YZ beyanının pazarlamayla tutarlılığı. Gerisi değişir [R1 1][R1 7][V].

Görüş:
- Steamworks hesabını, vergiyi ve 100 USD'yi şimdi başlat. Bunlar kamuya açık değil ve 30+21 güne varan bekleme taşıyabilir.
- Sayfayı Zukowski'nin beş koşulu tutunca aç. Bizde iki koşul eksik: sabit sanat stili (font ve tema açık) ve profesyonel kapsül. Üç ortam (ev, İş hanı, plaza, loft) zaten var.
- Ad kararı sayfa gönderilmeden önce verilmeli; "Project Unicorn" çalışma adıysa inceleme sonrası destek talebi gerekir [R1 7].

---

## 2. Başarılı ve başarısız akışlar

### 2.1 Emsal tablosu

Başarılı ya da güçlü (satış ve gelir Raijin tahmini, 2026-10-18) [R2a][V]:

| Oyun | Ekip | Akış | Sonuç |
|---|---|---|---|
| Big Ambitions | 4 kişi | Sayfa EA'dan ~22 ay önce (haber akışından çıkarım); EA öncesi alfa ve beta sürümleri; EA'dan 1 ay önce 67 bin, 1 gün önce 93 bin wishlist; ~1.000 içerik üreticisine yazı, ~200 anahtar; EA'da 3,5 yıl, 11 sürüm, 2-6 ay aralıkla | %92, 14.989 yorum, ~329 bin kopya; ilk ~18-20 günde 150-163 bin [R2a 3][R2a 33][R2a 38][V] |
| Software Inc. | 2015'te tek kişi | ~6 ayda neredeyse tam oynanabilir sürüm, EA 2015; hâlâ Beta 1.8.42; yılda ~10 duyuru | %94, 7.881 yorum, ~174 bin [R2a 1][R2a 39][R2a 31][V] |
| Game Dev Tycoon | (ekip bulunamadı) | EA yok, doğrudan 1.0 | %95, 45 bin yorum, ~923 bin [R2a 4][V] |
| Mad Games Tycoon 2 | Eggcode | ~2 yıl EA (tahmin) | %94, ~169 bin [R2a 2][V] |
| RimWorld | 2-3 kişi | Duyurudan 7 hafta sonra alfa; ~5 yıl EA; 1.0'dan sonra yılda bir büyük sürüm | %98, ~4,8 M [R2a 10][R3 12][R2a 36][V] |
| Mini Metro | küçük | Prototipten 5 ay sonra tarayıcı alfası; resmî plan yoktu, özellik büyümesi, Noel hedefi kaçtı [R3 6][V] | %96 [R2a 14] (doğrulanamadı) |
| Cultist Simulator | 2 kişi | Bilerek zor ilk saat, öğretici yok, ipucu geç eklendi | %80 (%90 altı), ~£130K bütçe, ~3 bin kopyada başa baş [R2a 43][R3 4][V] |

Başarısız ya da zayıf:

| Oyun | Ne oldu | Sonuç |
|---|---|---|
| Tech Executive Tycoon | EA'da "oynanamaz", vaat edilen özellik yok, geliştirme 2 yıl durdu | %15, ~1,1 bin kopya [R2a 7][R2a 25][V] |
| Good Company | QoL eksikleri, 2023'te sıfır duyuru, "terk edilmiş" yorumu | %73, ~34 bin [R2a 6][R2a 24][V] |
| Startup Company | "Telefon idle oyunu gibi bekliyorsun", işe alım sıkıcı | %81 [R2a 5][R2a 20][V] |
| E-Startup, Startup Panic, Idle Startup, Shipping Manager | İçerik çabuk bitiyor, döngü tekrar ediyor, bug, eğitim yok, geliştirici bıraktı | %44-59 [R2b 10-13] |
| CEO Tycoon, E-Startup 2 | Yorum oranı iyi (%70-87) ama görünürlük yok | 247 ve ~2 bin kopya [R2a 8][R2a 9][V] |
| Spacebase DF-9 | Açık uçlu üretim planı, temel sistem son alfaya kadar gelmedi, ilk aylardan sonra sessizlik, özellikler modlara bırakıldı | Yarım çıkış [R3 17][V] |
| Bramble Royale | Eylül 2024'te demo, Next Fest'te yalnız ~800 wishlist; "pazarlanabilir kanca yoktu", tür yorgunluğu | 4.117 wishlist, ilk hafta 703 [R1 28] |
| Neko Ghost, Jump! | 17 bin wishlist; EA, indirim sonrası çıkış, az basın | İlk gün 100 kopya [R2b 30] |
| Lone Survivors | Next Fest'e ~100 wishlist'le girdi, az playtest, aile ve arkadaşa anahtar | 279 kopya, 9 yorum [R2b 32] |
| Extraneum | Gelirin çoğu EA'da, 1.0'da neredeyse satış yok | ~2.400 kopya (arama özeti) [R2b 43] |
| Indoorlands | Doğru tür, %82 puan | Maliyeti çıkmadı [R4 28] |
| Vapor World | YZ ara sahneleri, tutarsız karakter modeli | 64 yorumda %36; günler içinde yama [R4 10][V] |

Pazarın tabanı:
- 2025'te 20.282 oyun; %48,7'si 10 yorumun altında; yalnız %2,99'u 1.000+ yorum [R2b 2][V].
- Oyunların %40'ı 1.000 dolara varamadı, %8'i 100 bin doları geçti [R2b 1][V].
- Doğrulanmış medyan: 2019 kohortu brüt 1.136 dolar; 2025 için temiz medyan yok; "249-1.000 dolar" aralığı (doğrulanamadı) [V].
- Zayıf başlangıçtan (ilk 30 günde <150 yorum) 500+ yoruma dönen 2024 oyunu ~%0,156 [R2b 27][V].
- Düşük performanslıların çıkış öncesi süresi ortalama 411 gün, yüksekler 214 gün: uzun bekleme tek başına korumuyor [R2b 34][V].

### 2.2 Ayıran etkenler

| Etken | Başarılılarda | Başarısızlarda | Kaynak |
|---|---|---|---|
| Kanca | Tek cümle: "GTA meets Cities Skylines" | "Pazarlanabilir kanca yoktu" | [R2a 38][R1 28] |
| Wishlist ve içerik üreticisi | 93 bin wishlist, ~1.000 içerik üreticisi; önceki oyunun kitlesi taşındı | Fest'e ~100 wishlist; görünürlük yok | [R2a 38][R2b 32][R2a 8] |
| Çekirdek döngü | Çalışıyor, derin, tekrar oynanabilir | Oynanamaz ya da 2-5 saatte tekrar | [R2a 21][R2a 25][R2b 10-12] |
| İlk saat | Kendi hızında öğretici | Öğretici batırıyor ya da yok | [R2a 23][R2a 19] |
| Ritim | Numaralı sürüm, 2-6 ayda bir | Sessizlik, terk | [R2a 33][R2a 35][R3 17] |
| Plan | (bulgu yok) | Bitiş noktası olmayan plan | [R3 17] |

Türün beş tekrar eden olumsuz teması (12-20 yorumluk örneklemden sentez, Görüş): ilk saat ve öğretici, kalabalık arayüz, geç oyunda döngü çöküşü ve bekleme, mikro yönetim yorgunluğu, gizli ya da keyfî puanlama [R2a 19-24].

### 2.3 Bize dersler

Görüş:
1. Cila gerekli ama yeterli değil. Software Inc. arayüzü yorumlarda "en kötü UI" diye anılırken %94 [R2a 19]; Indoorlands %82 ile batmış [R4 28]. Türde %90'ı derinlik, serbestlik ve düzenli güncelleme getirmiş [R2a].
2. Tek cümlelik kancayı sayfadan önce yaz ve birkaç kişiye sor [R2b]. Bugün elimizde yazılı bir kanca cümlesi yok.
3. 5.000 satış medyan değil, üst dilim sonucu [R2b 1][R2b 2]. Kaba hesap (tahmin): ilk hafta medyan dönüşüm 0,10-0,15 kat [R2b 34][V] ve modellenen 5.000 wishlist ≈ 1.000 ilk hafta satışı [R5 8]; 6 ayda 5.000 için çıkışta 10-20 bin wishlist gerekebilir [R2b].
4. Beş olumsuz tema bizim kontrol listemiz. Gizli puan şikâyeti iki emsalde var [R2a 21][R2a 22]; yıldız ve uyum hesabının oyuncuya okunur olması bu yüzden değerli.
5. Türdeki iki büyük başarı (Big Ambitions, MGT2) demo alanı olmadan çıktı [R2a 29][R2a 30]. Demo bir seçim; içerik üreticisi ağı zorunluluk.
6. Sessizlik öldürür; tek kişilik ekipte ritim kapsamdan önemli olabilir [R2a 35][R3 17].

---

## 3. Üretim düzeni

### 3.1 Sektör aşamaları ve kilit noktaları

Kaynaklar aynı sırayı veriyor, ama kanıtı zayıf (bir araç satıcısının blogu ve büyük stüdyo kılavuzları) [R3 14][R3 26]:

| Aşama | Çıkış ölçütü | Görüş: kilitlenen |
|---|---|---|
| Prototip | Çekirdek döngünün eğlenceli olduğu doğrulandı | Çekirdek döngü |
| Dikey kesit | Küçük bir bölüm neredeyse son kalitede: sanat, ses, arayüz, oynanış birlikte | Arayüz dili, görsel stil, ton |
| Alfa | Tüm temel özellikler var, baştan sona oynanır, cilasız olabilir | Özellik listesi |
| Beta | Tüm içerik var, kararlı; hata, denge, performans | İçerik |
| Altın | Yeni özellik yok | Her şey |

- Gerçek küçük ekipler bu adları sıkı kapı olarak kullanmadı; alfa ve EA oyunculara açık bir üretim yöntemiydi [R3 6][R3 12][R3 7].
- Agile Game Development (Clinton Keith): 2-4 haftada bir oynanabilir sürüm [R3 23]. Kanban ve iş sınırı 1 (WIP 1) önerisi araç satıcısı blogundan, zayıf [R3 16].
- Sylvester'ın "bitti" tanımı: "vaatler yerine getirildi, tasarımda boşluk kalmadı" [R3 11].
- Derek Yu: oynanabilir şeyi erken yap; dağınık kod yüzünden baştan başlama; projeyi baştan yaptıracak fikri sonraki oyuna sakla; "son %10 aslında %90" [R3 1].
- "Hangi aşamaya kadar yeniden açmak normal" sorusunu ölçen kaynak yok [R3].

### 3.2 Bizim düzen ve farkı

Sayılar [R7]:
- 404 commit, 43 aktif gün, 115 gün. Son 10 günde 135 commit [R7 §1].
- PRD'den koda medyan 1 gün. İlk 2 günde geri alma ya da düzeltme turu 13 PRD'nin en az 5'inde (~%40, kaba) [R7 §6.3].
- 17 sistem yeniden açıldı. Baskın neden: a (Erdem'in playtest ya da zevk kararı) 11, b (entegrasyon) 1-2, c (hata) 2, d (görsel) 2 [R7 §2].
- En sık açılanlar: arayüz dili 5 yön (3 ayda), ürün ve sprint döngüsü en az 8, ekip modülü en az 8, olay motoru 6, hız merdiveni 6 [R7 §0].
- 14 revizyon döngüsünde ret anındaki durum: yalnız yazılı 5, maket 3, oyun içi 6. En ucuz çözülenler yazılı aşamada yakalananlar (Faz D modeli, Faz Q formülü) [R7 §3].
- 14. haftanın ötesini oynayan insan oturumu kayıtlı değil [R7 §5.3].
- `docs/tasks` altında 23.871 satır görev belgesi; 185 commit "onay bekliyor" taşıyor ve toplu kapanışı yok [R7 §1][R7 §5.2].
- Demo tanımı üç farklı bitiş (Series A sonucu, seed imzası, 130. hafta) ve iki süre (60-90 dk, 39 dk) taşıyor [R7 §5.1].

Sektörle fark (Görüş):
- Kilit sırası ters. Sektör sırası "döngü → stil → özellik"; biz stil kilitlenmeden ekran işi yaptık (Ekran F1-F9, Piyasa I1) ve her tema değişimi bütün yüzeyleri yeniden boyadı [R7 §7.5].
- Prototip kapısı insan değil bot. Prototipin tek ölçütü "eğlenceli mi"; bizde bu soruyu hiçbir kapı ölçmüyor [R3 14][R7 §7.1].
- Oynanabilir sürüm dışarı çıkmadı. Emsallerde 5 ay ile 7 hafta arası [R3 6][R3 12].

### 3.3 Yeniden açılmaların ne kadarı normal

Görüş (R7 sınıflarına dayanarak; normal oranı ölçen dış kaynak yok):

| Kaynak | Pay | Hüküm |
|---|---|---|
| Entegrasyon: yeni modül eskisine dokunur (#16 sprint erken kapanışı kâğıdı susturdu; #11 gider) | ~2-3 / 17 | Doğal. Pope ve Mini Metro'da da var [R3 10][R3 6] |
| Hata ve gizli model (#5 olay motoru, #12 memnuniyet) | ~2 / 17 | Doğal, ama erken insan oyunu yakalar |
| Zevk kararı koddan sonra (#13 açılış kilitleri, #14 menü, #17 Piyasa, #9 ekip) | çoğunluk | Düzenimizden doğuyor |
| Kilitlenmemiş yön (#1 tema, #15 ofis, #14 font) | 3 | Düzenimizden doğuyor; kilit sırası |

Kayıtta tekrar eden ret türleri: "araştırmasız üretim", "ağırlıksız ya da sahte seçim", "görünmeyen model". Her biri kural olarak yazıldı ama bir sonraki alanda yine yaşandı [R7 §0.7].

### 3.4 Ne değişmeli

Görüş:
1. Kilit sırası: yön → tipografi ve tema → ekran. Kilitlenmemiş yönde ekran kodu yazılmaz.
2. Her fazın içinde Erdem'in oynayabileceği 10-15 dakikalık dilim; faz "Erdem oynadı" olmadan kapanmaz [R8 5].
3. Sistem "bitti"si iki katlı (bölüm 4.3).
4. Demo tanımı tek satıra iner ve CLAUDE.md'ye girer (bölüm 7.3).
5. "Onay bekliyor" yığını haftada bir toplu kapanır; 185 açık onay sessiz varsayılan demek [R7 §1][R7 §7.2].
6. Kapsam dışı listesi: demoya girmeyen her şey (bölüm 7.3) ayrı bir "sonra" listesine taşınır; Derek Yu'nun "sonraki oyuna sakla" kuralı [R3 1].

---

## 4. Ajan düzeni

### 4.1 Bugünkü düzende işe yarayanlar

- PRD koda bir günde iniyor; üretim hızı darboğaz değil [R7 §6.3].
- Yazılı aşamadaki ret en ucuz: Faz D ve Faz Q formülü kod yazılmadan düzeldi [R7 §3].
- "Önce referans araştırması" kuralı UI Lab'deki ret türünü tekrarlatmadı [R7 §3 R2].
- Doğrulama kapıları ve ekran görüntüsü kanıtı: rehber "kanıt iste, iddia değil" der; kontrol yoksa ajan "bitti gibi görünüyor" diye durur [R8 1][V].
- Taze bağlamlı kıdemli inceleme: Cognition'ın inceleme ajanı PR başına ~2 hata buluyor, ~%58'i ciddi [R8 8][V].
- Model rolleri (Haiku mekanik, Sonnet kod, Opus inceleme): çoklu ajan sohbetin ~15 katı token yiyor, kodlamada gerçek paralel iş az; zorluğa göre model makul [R8 3][V].
- Q, C, D'nin sırayla kodlanması: paralel yazarların örtük kararları çatışır [R8 8][V].

### 4.2 Zarar verenler

| Yan | Kanıt |
|---|---|
| Zevk kararı koddan sonra veriliyor | 14 döngünün 6'sında ret oyun içinde, kod, çeviri ve kare harcandıktan sonra [R7 §3]. Darboğaz koddan "yön, değerlendirme ve zevke" kaydı (tek kaynak) [R3 21][V] |
| Kapılar his ölçmüyor | 07-03 paketi "35/35 harness PASS, görsel reddedildi"; yazar pilotu "16/18 kör kapıdan geçti", Erdem "ne alaka" [R7 §2]. Ajanlar kendi işini olumlu notluyor [R8 6][V] |
| ~150 ajan saati oynanmadan birikecek | Q, C, D sırayla kodlanıp sonra playtest (görev metni). Anthropic'in uzun iş koşumu her oturumda tek özellik ve uçtan uca doğrulama yapıyor [R8 5] |
| Gece ya da uzak teslimde ön onaylı soru | 10-17 gece teslimi sabah 6 hedef MISS ile döndü; 07-03'te cevapsız çatallar "önerilen" değerle uygulandı [R7 §7.2] |
| Küçük işe ağır adım tablosu | Rehber: "farkı tek cümleyle anlatabiliyorsan planı atla" [R8 1]; spec araçları küçük hatada 4 hikâye ve 16 ölçüt üretti, markdown "uzun ve sıkıcı", ajan yine bir kısmını görmezden geldi [R8 10][V] |
| Şişkin talimat | CLAUDE.md 347 satır, hafıza indeksi 80 kayıt [R7 §4][R7]. Rehber: şişkin dosyada ajan kuralların yarısını görmezden gelir [R8 1][V] |
| Kural metinde, kapıda değil | Bir yıllık deneyim: "fallback yok" kuralına 500+ ihlal; pre-commit hook çözdü [R8 13]. Projede pre-commit hook var ama etkin değil (CLAUDE.md §12) |
| Kural çelişkisi | 10-11 "Opus yalnız zor" ile 10-16 "Opus her commit öncesi" yan yana [R7 §7.8] |
| Revizyon ölçülmüyor | 23 kuralın neredeyse hepsi maliyet ve süreç; "kaç tur", "Erdem ilk açışta ne dedi" ölçülmüyor [R7 §7.7] |
| Hız algısı yanıltıcı | METR: YZ izni süreyi %19 uzattı, geliştiriciler %20 hızlandık sandı (erken-2025 araçları) [R8 11][V] |

Görüş: Erdem'in kod okumaması, başarısız vibe-coding örneğindeki "çıktıyı doğrulayamayan kullanıcı"ya benziyor [R8 12]. Fark: bizde çok kapı var. Ama kapılar "çalışıyor mu"yu ölçüyor; "hissettiriyor mu" yalnız Erdem'in oyununda ölçülüyor ve o oyun en sona kalıyor.

### 4.3 Önerilen düzen

Görüş (dayanaklar köşeli parantezde):

**Zevk kararı nerede:** Koddan önce. Görünen her iş (ekran, olay metni, sayısal his) için 2-3 seçenek, oyunun kendi arayüzünde birer kare ya da birer örnek kart; Erdem seçer; kabul ölçütü "uygulanan ekran seçilen kareyle eşleşir" [R8 1]. Bugünkü "arayüzde koddan önce maket" kuralının olay metnine ve dengeye yayılmış hâli.

**"Bitti" iki katlı:** [R8 5]
- Kat 1, ajan kapatır: lint, smoke, bot, ekran kapısı.
- Kat 2, yalnız Erdem kapatır: "oynadım, hissi kabul ettim". Ajan bu alanı değiştiremez.
- Sistem Kat 2 olmadan "bitti" sayılmaz ve yeni modül onun üstüne kurulmaz.

**Döngü ne kadar kısa:** Her faz içinde Erdem'in 10-15 dakikada oynayacağı dilim. Q, C, D arasında birer Erdem oturumu; ~150 saat tek blokta oynanmadan birikmez [R8 5][R8 10].

**Kim ne yapar:**

| Rol | İş | Yapmaz |
|---|---|---|
| Erdem | Yön, kod öncesi seçim, Kat 2 kabul, karar soruları | Kod okumak, sayıyı ajana tarif etmek (ayar panelinden kendisi dener) |
| Yardımcı yönetmen (Opus) | Tek sayfalık brif, seçenek kareleri, zevk rubriği, karar kaydı, faz dilimi planı | Erdem yerine zevk kararı |
| Uygulayıcı (Sonnet) | Kod; bir alanı aynı anda tek oturum yazar | Kendi işini notlamak |
| Haiku | Test, bot, ekran çekimi | Tasarım kararı |
| İnceleyici (Opus, taze bağlam) | Diff; "yalnız doğruluğu ve açık gereksinimi etkileyen bulgular" | Bulgu üretmek için bulgu [R8 1] |
| Değerlendirici (taze bağlam, rubrikli) | Oyuncuya görünen işi Erdem'den önce puanlar; eşiği geçmeyen Erdem'e gitmez | Kendini ikna edip onaylamak; ilk haftalarda günlükleri okunur [R8 6] |

**Ne kadar belge:**
- Brif tek sayfa: istenen; "oynarken şunu hissetmeli" cümlesi; kapsam dışı; kabul karesi ya da örnek kart; uçtan uca doğrulama adımı [R8 1][R3 21].
- Spec düşünmek içindir, işi başlatmak için değil; tam spec ajanı varsayım yığınına sokabiliyor [R8 14].
- Tek cümlelik düzeltme adım tablosuna girmez. Eşik: tek dosya ve tek cümle [R8 1][R8 10].
- CLAUDE.md ve hafıza indeksi budanır: her satır için "silersem ajan hata yapar mı" [R8 1]. Eski görev kayıtları arşive.

**Kapılar:** Kritik kurallar (CSV kesme, push, dil yasası, lint) hook ile zorlanır, metinle değil [R8 13]. `.githooks/pre-commit` etkinleştirmek Erdem'in kararı (CLAUDE.md §12).

**Maliyet:** Rubrikli değerlendirici pahalı: Anthropic'te tek ajan 20 dk/9 dolar, tam koşum 6 saat/200 dolar [R8 6][V]. Ölçmeden büyütme; birkaç ayda bir adım tablosundan bir adımı çıkarıp kalitenin düşüp düşmediğine bak [R8 6].

### 4.4 Revizyon döngüsünü kısaltmanın somut yolları

1. Zevk rubriği: 4-5 ölçüt; her biri için Erdem'in reddettiği ve beğendiği birer örnek (UI Lab'in üç yönü, ana menü arka planı, olay şıkları, Menajer seçimi). Anthropic öznel "güzel mi" sorusunu dört ölçüte (tasarım kalitesi, özgünlük, işçilik, işlev) çevirip örnekli değerlendiriciye verdi; puan kayması azaldı [R8 6][V].
2. Ret nedenlerini sözlüğe çevir: "araştırmasız", "sahte seçim", "görünmeyen model", "jenerik" [R7 §0.7]. Brif bu dört soruyu cevaplamadan yazılmaz.
3. İki başarısız düzeltmeden sonra oturum temizlenir, öğrenilen yeni brife yazılır [R8 1][V].
4. Ayar paneli: tempo, ağırlık, eşik gibi sayıları Erdem oyunda kendisi kaydırır; ajan yalnız bulunan değeri sabitler. (Kaynak yok, mühendislik çıkarımı [R8].)
5. Açık çatal varsa dur. Gece teslimlerinde "ön onaylı" soru yok [R7 §7.2].
6. Tur sayısını ölç: her görev için "ilk açışta Erdem ne dedi" ve tur sayısı tek satırla kaydedilir. Deneme: sıradaki tek ekranı bu yöntemle yaptır, turları say [R8].
7. Olay ve kâğıt havuzu için binlerce rastgele koşu: hiç gelmeyen ve aşırı gelen kartı say [R6 1][V]. Bugün 46 kâğıdın 27'si bot koşusunda hiç gelmiyor [R7 §5.3].

---

## 5. Neredeyiz

Aşamalara göre (Görüş, R3 ölçütleriyle):

| Aşama | Ölçüt | Durum | Kanıt |
|---|---|---|---|
| Prototip | Döngü eğlenceli mi doğrulandı | Mekanik olarak tamam, eğlence insanla doğrulanmadı | [R7 §5.2][R7 §5.3] |
| Dikey kesit | Bir dilim son kalitede | Yok: font ve tema açık, ses tek MP3, SFX 0, gazete sanatı yer tutucu | [R7 §5.3][R7 §3 R14] |
| Alfa | Tüm temel özellikler | Yok: Q sürüyor, C ve D yalnız PRD, doruk formalite, seed sonrası hedef yok, kayıp ekranı "ne öldürdü" demiyor | [R7 §5.3] |

Oyunun içi (bot ve hükümler) [R7 §5.3]:
- Satış görüşmesi en kötü cevapla %98 kazanılıyor.
- Traction'ın %94'ünde runway sonsuz: para baskısı yok.
- Series A: 10 tohumda 9 imza, masada 0 zorlama.
- B2C'de haftaların %65'i kartsız.
- Saat her karardan sonra elle başlıyor.
- 7 Ekim'in dört kırık alanından (ilk saat, orta oyun, doruk, vitrin) yalnız ilk saat kapandı.

Emsallere göre:
- Mini Metro prototipten 5 ay sonra, RimWorld duyurudan 7 hafta sonra dış oyuncuya açıldı; Software Inc. ~6 ayda neredeyse tam oynanabilirdi [R3 6][R3 12][R2a 39]. Biz 115. gündeyiz; dış oyuncu sıfır.
- Steam sayfası yok, wishlist 0 [R7 §0].
- Türün beş olumsuz temasına karşı (Görüş): orta oyunda para baskısının olmaması ve kartsız haftalar "geç oyunda döngü çöküşü ve bekleme" temasına; doruk formalitesi "karar kalmadı" hissine denk düşüyor [R2a][R7 §5.3].

Anlatı ve yazı:
- Türde şikâyet metinden çok döngü tekrarından geliyor; metni cilalamak tek başına "meh"i çözmez [R6 4-7].
- Mizah dünyaya bağlı gönderme ve parodi adla çalışıyor (GDT, MGT2) [R6 4][R6 6].
- Kısa, ima eden kart metni (Cultist, Reigns) bir model [R6 11][R6 22].
- Elimizde Frank külliyatı, 40 kâğıt ve TR/EN sistemi var; havuzun yarısından fazlası gelmiyor ve ses rehberi kart yazımında sürekli girdi değil [R7 §5.3].
- MGT2'de Türkçe çeviri şikâyetinin "sık" olduğu desteklenmiyor (tek not) [V].

Görüş, tek cümle: oyun mekanik olarak ayakta, ama "eğlenceli mi" ve "kim olduğu" henüz sınanmadı ve kilitlenmedi; demo, sayfa ve wishlist açısından sıfır noktasındayız.

---

## 6. Kimlik

### 6.1 Seçenekler, maliyet ve satışa etki

| Seçenek | Maliyet | Satışa etki (kanıt) | Görüş |
|---|---|---|---|
| Kapsül dış sanatçıya | $250 ile birkaç bin dolar; ilanlar $100'dan | Imagine Earth tek kapsül değişimiyle günde 0-3'ten 40-60'a (tek vaka); "kendi kapsülünü yapma" [R4 4][R4 5][V]. TıO ölçeği yöntemsiz blog [R4 3][V] | Yap. Sayfanın beş koşulundan biri |
| Mevcut fontlarla tipografi ayarı | Düşük | Barlow Condensed ve IBM Plex Sans yoğun ekran listelerinde; tabular rakam, ayrışan glif, küçük boyda izleme önemli [R4 18][R4 19] (satıcı blogu) | Önce bunu dene: hiyerarşi, boyut, izleme, `tnum` |
| Yeni font ailesi | Orta-yüksek: her tema değişimi yüzeyleri yeniden boyadı | Kanıt yok | Yalnız ayar turu yetmezse |
| Tek güçlü motif | Orta | Kaynaklı kanıt az; Frostpunk arayüzü "kâğıt, defter" malzemesiyle etiketli [R4 27]; Papers Please kimliği etkileşimin dokusundan [R4 20] | "Koyu sıcak ton + üç font" motif değil [R4]; masa ve kâğıt (karar kâğıdı, gazete, Frank) aday |
| Yoğun arayüzü koz yapmak | Düşük | "Karmaşık arayüz oyunun gerçekten yapıldığını gösterir" (ikinci el, birincil okunamadı) [R4 7] | Ekran görüntüsü 3. sırada sistem ekranı |
| Quaternius karakterlerine ortak palet, ışık, siluet kuralı | Düşük-orta | Oyuncuların bu paketi tanıdığına kanıt yok; asset flip etiketi "bütün jenerik" görünümden [R4 16][R4] | Ofis eşyalarında özel aset sürer |
| Blender MCP ile kendi asetlerimiz | Bilinmiyor | Yaratıcısı sonuçları "en iyisi değil" diyor; LLM'lerin 3B kavrayışı zayıf; bağımsız ölçüm yok; betikle üretilen paket "AI" diye okundu [R4 23][R4 25][V] | Kritik yolda değil. Demo kilitlendikten sonra 1-2 kahraman eşyada süreli deneme, Erdem önce/sonra çiftine bakar |
| Yazı: ses rehberi ve sözlük | Düşük | Küçük ekip önerisi; kanıt blog düzeyi [R6 24][R6 14] | Ajanlara her kart işinde girdi |
| Yazı: insan editör turu | Erdem zamanı | YZ'siz oyunlar da "AI slop" suçlaması alıyor (Shrine's Legacy); kalıpları yüzeyden silmek önerilmiyor [R4 11][R6 15][V] | Somut ve bu oyuna özgü ayrıntı (kim, hangi sayı, hangi ürün); kelime yasağı değil |

### 6.2 Font işinin zamanlaması

Kanıt:
- Valve ve Zukowski: sanat yönü ve stil sayfadan önce oturmalı [R1 1][R3 19][V].
- Bizde tema 3 ayda 5 kez yön değiştirdi; her seferinde yüzeyler yeniden boyandı. Font 08-03'te bir kez, 10-02'de bir kez seçildi, bugün yine zayıf bulunuyor [R7 §2 #1][R7 §3 R14].

Görüş: evet, tipografi C ve D'nin ekran maketlerinden ÖNCE kilitlenmeli. C (ürün sayfası) ve D (ekip ve sprint) tam da Erdem'in en zayıf bulduğu ekranlar. Kilit gelmeden yapılan maket, bir sonraki font kararında çöpe gider.
Ucuz yol: sprint ekranında tek tur; mevcut üç fontun ayarlı hâli dahil 3 seçenek, her biri tek kare, Erdem seçer (referans araştırması kuralıyla) [R7 §4 kural 12]. Bedel: C'nin maket işi bu tur kadar kayar.

### 6.3 Ayrışma üzerine

Görüş:
1. Risk "yapay zekâ yaptı" değil, "özensiz göründü". Bizde bunun karşılığı ilk beş dakika: ana menü, ilk ekranlar, ilk karar kâğıdı [R4 10].
2. Ayrışmanın kanıtlı kaldıraçları kanca, kapsül ve içerik üreticisi; arayüz cilası tek başına satış getirmiyor [R2a 38][R4 4][R4 28].
3. Twitter'daki 100-200 kopyalık demolar pazar tabanıyla uyumlu: medyan oyun 10 yorum bile almıyor [R2b 2]. Bizi oradan ayıracak olan, wishlist ve kanca hazırlığı olmadan çıkmamak.

---

## 7. Yol haritası

Takvimi iki sabit belirler: Next Fest tarihleri [V] ve "demo festten aylar önce açık olsun" kanıtı (~2,5 kat medyan wishlist) [R5 2][V]. Bugünden sayımla: Şubat 2027 fest kaydına 12 hafta, Haziran 2027 fest kaydına 27 hafta, Haziran festine 34 hafta var.

### 7.1 Aşamalar

Görüş (her aşamanın dayanağı satırında):

| # | Aşama | Çıkış ölçütü | Kilitlenen | Dayanak |
|---|---|---|---|---|
| 0 | Hemen, paralel: Steamworks hesabı, vergi, 100 USD; ad kararı; kanca cümlesi | Hesap hazır; ad ve tek cümle yazılı | Ad | [R1 4][R1 7][R2b] |
| 1 | Q, C, D + faz arası Erdem dilimleri | Her faz Kat 2 kabul aldı | Çekirdek döngü | [R8 5][R3 14] |
| 2 | Demo kapsamı ve ilk insan oyunu | Erdem bir tam demo koşusu oynadı (14. haftanın ötesi); beş olumsuz tema listesinden geçti | Demo kapsamı, demo bitişi | [R2a][R7 §5.3] |
| 3 | Kimlik kilidi (dikey kesit) | Tipografi ve tema kilitli; dış sanatçı kapsülü; 5+ ekran görüntüsü; ~30 sn oynanış fragmanı | Sanat stili, tür, ton | [R5 5][R1 8][R4 5] |
| 4 | Sayfa: incelemeye gönder, Coming Soon'a bas | Zukowski'nin beş koşulu | Ad, YZ beyanı | [R5 5][R1 1] |
| 5 | Kapalı playtest | 50-200 kişi (Görüş sayı); tamamlama oranı ve en sık 3 şikâyet ölçüldü | | [R5 2][R5] |
| 6 | Herkese açık demo, ayrı sayfa | Demo-wishlist dönüşümü %15-25 sağlıklı, %10 altı sorun işareti | | [R5 17][R5 2][V] |
| 7 | Next Fest (tek hak) | Festten önce en az birkaç bin wishlist; 1.000 altıyla girme | | [R5 1][V] |
| 8 | Çıkış (EA ya da 1.0) | Wishlist tabanı 5.000-7.000 (kaynaklar kendi içinde çelişir); festten 1-3 ay sonra | Fiyat kuralları (EA) | [R5 8][R5 3][V] |

### 7.2 Takvim seçenekleri

| Hedef fest | Ne gerektirir | Görüş |
|---|---|---|
| Şubat 2027 | Sayfa 10 Ocak'tan önce herkese açık (12 hafta); demo ve sayfa 25 Ocak'a kadar incelemede; "aylar önce demo" için demo Aralık civarı açık | ~150 ajan saatlik Q/C/D, playtest, revizyon, kimlik kilidi ve dış sanatçı kapsülü bu pencereye sığmaz. Sığdırılırsa demo festte ilk kez çıkar; Zukowski bunu açıkça önermiyor [R8 16][V] |
| Haziran 2027 (öneri) | Kayıt 25 Nisan (27 hafta), inceleme 17 Mayıs, öğeler 31 Mayıs, fest 14-21 Haziran | Sayfanın festten birkaç ay önce, demonun festten "aylar önce" açık olması bu pencerede mümkün |

Haziran 2027 için koşullu sıralama (Görüş; tarih değil koşul):
- Sayfa, aşama 3 biter bitmez açılır; fest öncesi wishlist birikimi için ne kadar erken o kadar iyi [R5 1][R3 19].
- Demo, kapalı playtestten sonra ve fest kaydından (25 Nisan) önce açık olmalı.
- Çıkış, festten 1-3 ay sonra (uygulayıcı deseni, ölçülmüş değil) [V]. Demo, çıkışa 6-8 haftadan yakın açılmamalı [R5 2][V].
- Koşul tutmazsa fest bir sonrakine kayar; fest hakkı tek olduğu için erken harcanmaz [R1 18].

Q, C, D ve playtest'in yeri: aşama 1 ve 2. Bugünkü plandan tek fark, playtest'in sona değil faz aralarına bölünmesi. ACIK_ISLER'in 17 maddesi aşama 2 sonrasına kalır; demo kapsamına girmeyenler "sonra" listesine taşınır.

### 7.3 Demo kapsamı önerisi

Kanıt:
- Demo süresi iki kaynakta çelişir: 20-40 dk ve 30-90 dk; oyuncuların %40'ından azı bitiriyorsa uzundur [R5 17][R5 2].
- "İlk içeriğini değil en iyi içeriğini göster"; gerilimli bir noktada kes, wishlist istemini bitiş ekranına koy [R5 17].
- Sim ve sistem türleri demodan zarar görmez [R5 2][R5 18].
- Bizde bot Series A'ya 21-27 dk saf saatte varıyor; hedef 60-90 dk; 104 hafta 1×'te 39 dk [R7 §5.1].
- Seed ve Series A doruğu formalite: 10 tohumda 9 imza, masada 0 zorlama [R7 §5.3].
- B2C'de haftaların %65'i kartsız [R7 §5.3].

Görüş:
1. Tek tanım: "Demo Bootstrap'tan başlar ve Series A görüşmesine davetin geldiği anda biter." Bitiş ekranında wishlist istemi. Formalite olan doruğu demoda göstermez; gerilim noktasında keser. Seed doruğu demoda kalır ve onun elden geçirilmesi (ACIK_ISLER #5) demo işidir.
2. Tek yol: B2B. Satış görüşmesi, Frank ve hesaplar türdeki rakiplerden ayıran anlar; B2C'nin orta oyunu boş. B2C "tam oyunda" diye sayfada anılır.
3. Sektörler Erdem'in kararıyla kalır; demo yalnız ERP çekirdek hattını gösterir (bugünkü durum) [R7 §5.2].
4. Hedef süre 40-60 dk; kapalı playtestte tamamlama oranıyla ayarlanır.

---

## 8. "İncil": temel kaynaklar

Görüş: tek bir İncil yok; aşama kılavuzları 1-5 kişilik ekip için sayısal ölçüt vermiyor [R3]. Aşağıdaki altı kaynak birbirini tamamlar. Sıra, uygulama sırasıdır.

| Sıra | Kaynak | Ne için | Ne zaman |
|---|---|---|---|
| 1 | Derek Yu, "Finishing a Game" (2010, kısa makale) | Kapsam, kesme, "son %10 aslında %90" [R3 1] | Demo kapsamı kararından önce, tek oturuşta |
| 2 | Anthropic, Claude Code best practices ve "Harness design for long-running application development" (24 Mart 2026) | Doğrulama, taze bağlam, değerlendirici ve rubrik, şişkin talimat [R8 1][R8 6][V] | Ajan düzeni değişmeden önce |
| 3 | Chris Zukowski, How To Market A Game (blog) | Sayfa koşulları, wishlist, demo, Next Fest takvimi [R3 19][R5 1][R5 5][V] | Aşama 3'ten önce; her pazarlama adımında |
| 4 | Steamworks belgeleri: Coming Soon, Review Process, Graphical Asset Rules, Demos, Next Fest, Early Access, Content Survey | Kurallar; tek birincil kaynak [R1 1-23][V] | Her Steam adımından hemen önce, güncel sürüm |
| 5 | Emily Short, "Beyond branching" (2016) | Olay havuzu, salience seçimi, binlerce rastgele koşuyla test [R6 1][V] | Kâğıt ve olay havuzu işinde |
| 6 | Tynan Sylvester, Designing Games (2013) | Deneyim mühendisliği, karar, ödül zamanlaması; RimWorld'ün yazarı [R3 24] | Playtest sonrası tasarım revizyonunda. Not: içerik yalnız bir kitap incelemesinden doğrulandı |

Doğrulanmadığı için listede olmayanlar: The Game Production Handbook, Blood, Sweat, and Pixels (kaynaksız) [R3]. Schell'in Book of Lenses kontrol listesi olarak kullanılabilir [R3 22]; Keith'in Agile Game Development'ı çok disiplinli ekip için [R3 23].

---

## 9. Karar soruları

**K1. Hedef Next Fest: Şubat 2027 mi, Haziran 2027 mi?**
Öneri: Haziran 2027 (kayıt 25 Nisan, fest 14-21 Haziran).
Satışa etki: Demonun festten aylar önce açık olması medyanda ~2,5 kat wishlist ile ilişkili; fest hakkı tek [R5 2][R1 18][V]. Şubat'ı zorlamak demoyu festte ilk kez çıkarmak demek.
Oynanışa etki: Q/C/D ve playtest için ~7 ay alan.

**K2. Demo kapsamı ve bitişi tek satır olsun mu?**
Öneri: "B2B, Bootstrap'tan Series A davetinin geldiği ana kadar; hedef 40-60 dk." CLAUDE.md §1'e yazılır, öbür iki tanım silinir.
Satışa etki: Gerilim noktasında kesen demo ve bitiş ekranındaki istem dönüşümü artırabilir (blog düzeyi) [R5 17].
Oynanışa etki: Formalite doruğu demoda görünmez; B2C demoda yok.

**K3. Tipografi C ve D maketlerinden önce kilitlensin mi?**
Öneri: Evet. Sprint ekranında 3 seçenek, tek kare, mevcut fontların ayarlı hâli dahil; Erdem seçer, sonra C ve D maketleri.
Satışa etki: Sanat stili sayfanın beş koşulundan biri [R5 5].
Oynanışa etki: Yoğun ekranlarda okunurluk (tabular rakam, izleme) [R4 18]. Bedel: C maketinin bir tur kayması.

**K4. "Bitti" iki katlı olsun ve Q, C, D arasına Erdem dilimleri girsin mi?**
Öneri: Evet. Kat 2 yalnız Erdem'in; faz Kat 2 olmadan kapanmaz.
Satışa etki: Dolaylı; "geç oyunda döngü çöküşü" ve "sahte seçim" gibi temaları kod birikmeden yakalar [R2a][R7 §7.1].
Oynanışa etki: Yeniden açılmaların çoğunluk sınıfını (a) ucuz aşamaya çeker [R7 §2][R7 §3]. Bedel: Q/C/D'nin bitişi faz başına bir oyun oturumu kadar uzar.

**K5. Oyun adı ve YZ beyanı ne zaman, nasıl?**
Öneri: Ad, sayfa gönderilmeden önce kesinleşir (incelemeden sonra kilitli) [R1 7]. Beyan: olay ve Frank metinleri, yerelleştirme, mağaza metni ve müzik "önceden üretilmiş içerik" diye dürüst yazılır; kod beyan dışı [R1 13][R1 14][V].
Satışa etki: Beyanlı oyunlar ~%53 daha az yorum alıyor (ikincil, nedensellik yok) [V]; gizlenen kullanım daha sert tepki getirdi (The Alters) [R6 17].
Oynanışa etki: Yok; ama oyuncuya görünen metin ve müzikte insan editörü ve görünür kestirme bırakmama işi demo kapsamına girer.

---

## Ek: kaynak dizini

| Etiket | Rapor | Konu | Arama / kaynak |
|---|---|---|---|
| R1 | [R1_steam.md](arastirma/R1_steam.md) | Steam sayfası, demo, YZ beyanı kuralları | 16 / 33 |
| R2a | [R2a_emsal_basarili.md](arastirma/R2a_emsal_basarili.md) | Türdeki başarılı emsaller | 18 / 53 |
| R2b | [R2b_emsal_basarisiz.md](arastirma/R2b_emsal_basarisiz.md) | Başarısızlar ve pazarın dağılımı | 18 / 53 |
| R3 | [R3_uretim_duzeni.md](arastirma/R3_uretim_duzeni.md) | Küçük ekip üretim düzeni, temel kaynaklar | 18 / 31 |
| R4 | [R4_kimlik.md](arastirma/R4_kimlik.md) | Görsel kimlik, font, kapsül, YZ algısı | 18 / 32 |
| R5 | [R5_pazarlama_demo.md](arastirma/R5_pazarlama_demo.md) | Pazarlama takvimi, demo, EA | 18 / 27 |
| R6 | [R6_yazi_anlati.md](arastirma/R6_yazi_anlati.md) | Yazı ve anlatı | 18 / 26 |
| R7 | [R7_bizim_durum.md](arastirma/R7_bizim_durum.md) | İç inceleme: yeniden açılmalar, revizyon, demo kapsamı (denetlenmedi) | 0 / 45 |
| R8 | [R8_ajan_duzeni.md](arastirma/R8_ajan_duzeni.md) | Ajanlarla geliştirme düzeni | 18 / 22 |
| V | [V_denetim.md](arastirma/V_denetim.md) | Kaynak denetimi: 87 iddia, 68 doğrulandı, 12 düzeltildi, 7 doğrulanamadı | |

Açık iş listesi: [faz_cde/ACIK_ISLER.md](../tasks/faz_cde/ACIK_ISLER.md).
