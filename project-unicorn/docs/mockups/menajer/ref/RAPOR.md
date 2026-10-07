# Project Unicorn arayüzü: araştırma ve karar raporu

2026-10-01. Girdi: altı araştırma kolu (spor menajerliği, işletme ve tycoon, strateji, diegetik ve malzeme, canlı dünya üstünde arayüz, tasarım ilkeleri) ve bugünkü üç ekranın piksel ölçümlü eleştirisi. Yaklaşık 70 oyun ve kaynak. Ham notlar aynı klasörde: `fm.md`, `tycoon.md`, `strategy.md`, `diegetic.md`, `isometric.md`, `principles.md`, `critique.md`.

Etiketler:
- **[G]** Ekran görüntüsünde gözle doğrulandı (ben ya da araştırmacı açıp baktı).
- **[K]** Geliştiricinin kendi kaynağı: dev diary, blog, sunum, yama notu.
- **[İ]** İnceleme ya da oyuncu yorumu.
- **[?]** Yalnız arama özetinden ya da benim çıkarımım. Doğrulanmadı.

## Özet

1. Sorun renk ya da doku değil. Bugünkü ekran bir web yönetim paneli dilinde konuşuyor: hazır Lucide ikonları, hap çipler, 1 px çizgiler, 9-13 px büyük harf mono. Bu dilin 3B ofisle hiçbir ortak noktası yok. Klasör varyantları bu dili yeniden boyadı. Ekip ve Satış'ta piksellerin yalnız %15-17'si, olay ekranında %6-9'u değişti.
2. Türün iyi örnekleri karakteri pencere dokusundan almıyor. Üç kaynaktan alıyor: dünyanın kendi çizgisi (Two Point), pencerenin konusunun resmi (CK3, Frostpunk, Victoria 3) ve yalnız çerçeveye konan tek malzeme (Victoria 3, Against the Storm). Her pencereyi kâğıda saran tek büyük örnek Tropico 6; incelemeler onu "cluttered" diye anıyor.
3. Hangi yön seçilirse seçilsin değişmeyen bir taban var. Veri yazısı orantılı sans ve tabular rakamla dizilir. Yazı 1080p'de okunur boyda olur. Vurgu rengi tek bir işe ayrılır. Yıldız dizisinin yerini sayı ve renk bandı alır. Olay kartında bedel en büyük yazıdır. Üst bar ölümcül kaynağı süre olarak yazar.
4. Dört yön öneriyorum ve önerim **Yön 1 "Oyuncak Ofis"**: arayüz dilini 3B ofisten türetmek, yani Two Point Campus çizgisi. Dürüst not: bu bir tema değişimi değil. Yerleşim, sanat (ikon seti, büstler) ve ofis kodu ister.
5. Kararı senin gözün vermeli. Bölüm 5'teki görsel seçkiden üç numara seçmen yeter.

---

## 1. Bugünkü ekranın asıl sorunları

Not: baseline görüntüleri renk körü paletiyle çekildi. Mavi görünen her şey (moral çubukları, NET, "Artıda", SAĞLIKLI) varsayılan palette yeşildir.

### 1.1 Öncelik sırasıyla

| # | Sorun | Kanıt (ölçüm) | Ağırlık |
|---|---|---|---|
| 1 | **Ekranda bu oyuna ait hiçbir şey yok.** Arayüz ofisin çizgisini, şeklini ve rengini paylaşmıyor. | Ray ikonları hazır Lucide seti (`assets/icons/tabs/LICENSE-lucide.txt`). Ofiste yaklaşık 2 px koyu kontur ve 0,31 ortalama doygunluk var; pencere içinde doygunluk 0,06, çizgiler 1 px ve 1,43:1. Frank'in portresi 24×24 px, kadro avatarları 32 px. İllüstrasyon, çizilmiş ikon ya da imza şekli yok. | Yüksek |
| 2 | **Hiyerarşi ters: acil olan en sessiz öğe.** | Selin Kaya'nın uyarı şeridi (moral 22, AYRILABİLİR) #F5ECE2 zemin üstünde ve kenar kontrastı yaklaşık 1,3:1. Moral çubuğu alarm rengi değil, kahverengi amber (#B36B00). Satırın en ağır yazısı maaş (yaklaşık 16-17 px kalın), isim yaklaşık 13 px. Göz sırası: sarı düğme, ofis tuğlası, maaş sütunu, yıldız tarlası. | Yüksek |
| 3 | **İkincil yazı rollerinin hepsi aynı sesle konuşuyor:** 9-13 px, büyük harf, harf aralıklı JetBrains Mono. | Ölçülen büyük harf yükseklikleri: pencere başlığı 18, isim 9, sütun başlığı 8, üst bar etiketi 7, olay etki çipi 7 px. Skala 9/10/11/12/13'ten sonra 16'dan 22/24/26'ya atlıyor. Kontrast: üst bar etiketleri 2,49:1, INK_DIM 3,59:1, INK_FAINT 2,46:1. Xbox erişilebilirlik tabanı PC'de 1080p için 18 px gövde ve 4,5:1. | Yüksek |
| 4 | **Olay modalı:** Frank'in ilk çeki kadro penceresiyle aynı krem formda. | 780×490 modal. Portre 24 px ve konuşmanın altında. Bedel çipi ("NAKİT +$25K · FRANK'E %4 HİSSE") yaklaşık 7 px büyük harf ve 3,91:1; kazanç ile hisse kaybı aynı renkte. Gövde yaklaşık 15 px. Sinematik koyu register (DIALOGUE_*) ve QuoteBox bu ekranda kullanılmıyor. | Yüksek |
| 5 | **Pencere ofisi duvar kâğıdına çeviriyor.** | Ekip 1200×720, Satış 1280×760: karenin %42-47'si. Gölge yok, köşe 4 px. Krem pencere, krem ve turuncu ağırlıklı sıcak ofisin üstünde duruyor; figür zeminden ayrılmıyor. | Orta |
| 6 | **Çerçeve içerikten ağır, üst barda kahraman sayı yok.** | 54 px siyah üst bar, 34 px siyah haber şeridi ve sekiz ayrı kutulu ray karosu var. Üst bardaki yedi rakam aynı boy ve ağırlıkta (yaklaşık 15 px mono). x≈800-1370 arası boş siyah. Logo turuncu bir ColorRect. | Orta |
| 7 | **Tek vurgu rengi dağılmış.** | Aynı ekranda beş ayrı amber ya da turuncu var: logo #FFA028, CTA #F4C430, yıldız ve başlık #9A6A12, moral 38 çubuğu #C9962E, moral 22 çubuğu #B36B00. Yetmiş beş yıldız amber. Renk körü modunda "olumsuz" turuncusu vurgu rengine yapışıyor. | Orta |
| 8 | **Ekip tablosu karşılaştırmayı zorlaştırıyor.** | 3 beceri × 5 yıldız × 5 satır = 75 yıldız; yarım yıldızlar 11 px. DENEYİM sütunu her satırda %0. TRAIT sütunu etiketsiz bir ikon. Mert'in satırı yaklaşık 6 px sola kaymış, "Test ediyor" ortalanmış, maaş çubuğa 2 px mesafede. | Orta |
| 9 | **Satış'ta birincil eylem enflasyonu var.** | Aynı anda dört sarı birincil düğme görünüyor: iki "Görüşmeye git", bir "İlgilen", bir "Değerlendir". KPI rakamı yaklaşık 11 px, kart ismiyle aşağı yukarı aynı boy. RİSK ALTINDA ile BÜYÜMEK İSTİYOR aynı amber çipte. Pencerenin altında 65-130 px boşluk kalıyor. | Orta |
| 10 | **Yüzen öğeler dağınık, dil ihlalleri var.** | Build kartı, "Ofisi taşı" hapı ve toast üç ayrı stilde. Haber şeridi x=0'dan başlıyor ve sağda kelime ortasında kesiliyor. TR ekranda "TRAIT", "NEUTRAL", "Operating Partner", "UX/UI DESİGNER", "NORDİCA" geçiyor. Bu LANGUAGE INTEGRITY LAW ihlali; düzeltmesi TR onayı ister. | Düşük |

### 1.2 Üç klasör varyantı (evrak, dosya, gazete) neden tutmadı

- **Yeniden tasarım değil, yeniden boyamaydı.** Piksel farkı Ekip'te %16,2 / %14,7 / %27,7, Satış'ta %17,1 / %15,3 / %31,3, olay ekranında %9,2 / %6,0 / %21,2. Yerleşim, hiyerarşi, yıldızlar, çipler, çubuklar, Lucide ikonları, kaydırma çubuğu ve modal yapısı birebir aynı kaldı.
- **Lab hattı arayüzün çoğuna ulaşamıyordu.** `sandbox/ui_lab/README.md`'deki "Temanın ulaşamadıkları" bölümü şunları sayıyor: TopBar, ray etiketleri, şeridin rengi, pencere boyutları, Ekip çizgileri, çipler, moral çubuğu, Satış rozetleri, modal perdesi. Aynı bölüm damganın gerçek ekranda "hiç görünmediğini" söylüyor. Hiyerarşi ve yoğunluk sorunlarının hepsi bu yüzden üç varyantta da aynen durdu.
- **Metafor kabı sardı, içeriği değil.** Pencerenin çevresine 14-16 px manila ya da çelik bant geldi, içeride aynı SaaS satırları kaldı. Klasör metaforu klasör içeriği ister: form, ataşlı fotoğraf, not, kararda damga. Hiçbiri tasarlanmadı.
- **Dokunun işi yoktu.** Papers, Please'te kâğıt oyunun kendisidir; belgeyi masada sürükler, karşılaştırır, damgalarsın (Pope: "The gameplay is really about procedure"). Bizim tablomuz okunur, elle tutulmaz. Kâğıt kılığı bir fiil getirmedi.
- **Metaforlar üst üste bindi.** İzometrik oyuncak ofis, kâğıt klasör, terminal mono, siyah haber şeridi ve SaaS çipleri aynı ekranda. Gazete varyantı oyun sonunun özel adası olan "Ekonomi Postası"nı bütün arayüze yayıp o sürprizi harcadı.
- **Vurgular anlamı bozdu.** Evrak'ta CTA ve rozetler damga kırmızısı (#B0281C), yani "olumsuz" ailesinden; işe alım düğmesi alarm gibi okunuyor. Dosya'da CTA lacivert #17273F, mürekkep ve üst barla aynı renk; birincil eylem vurgu olmaktan çıkıyor.
- **Paletler dünyayla çatıştı.** Dosya'nın soğuk çelik kâğıdı sıcak tuğla sahnede tek soğuk yüzey kaldı. Gazete'nin gri kâğıdı ofisin yanında kirli durdu. Evrak'ın manilası en uyumlusuydu, ama tam da bu yüzden baseline'dan ayırt edilmedi.
- **Yazı yanlış yöne gitti.** Dosya, Frank'in konuşmasını IBM Plex Mono'ya taşıdı; okuması yavaşladı, sesi düzleşti. Space Grotesk başlıklar 2020'lerin teknoloji sitesi yüzü.
- **Gerileme:** Gazete'de kilitli Pazarlama karosu siyah rayda etiketi görünmeyen gri bir levhaya döndü.
- **Önünde araştırma yoktu.** Referans çalışılmadan seçilmiş üç stil karosuydu: palet, üç font, beş bileşen.

Sahadan iki kanıt:
- **Tropico 6 bu fikri oyuna koydu.** Her pencere spiral ciltli, köşeleri filigranlı bir defter sayfası; olaylarda ataşla tutturulmuş sepya fotoğraf var. İncelemeler "cluttered, far from user-friendly" (Wccftech) ve "Cluttered and not userfriendly UI" (TechSpot) diyor. Steam'de 4K'da yazının çok küçük olduğu ve ölçek ayarının yalnız küçülttüğü söyleniyor. [İ] [G]
- **Against the Storm "fazla sade, karaktersiz" eleştirisine yeni bir metaforla cevap vermedi.** Pencere ve panel zeminine toprak yeşili bir deri dokusu ekledi, çerçeveleri genişletti; yerleşim ve satırlar aynı kaldı. Geliştiricinin sözü: "We now know that the handcrafted, warm feeling is what you miss the most". [K]

### 1.3 Korunacaklar

- **3B izometrik ofis.** Oyunun tek sahipli varlığı. Two Point'in baş sanatçısı Mark Smart'ın anlattığı tıknaz, yuvarlak ve okunur dil ("slightly chunky, and a lot more rounded and soft") bizim ofiste zaten var. Arayüz ondan türemeli.
- **Anlatı için krem okuma yüzeyi ve serif.** #FBF7EE üstünde #2B2722 13,87:1 veriyor; Source Serif 4 başlık ve Frank metni için doğru ses.
- **Pencere başına tek birincil eylem kuralı.** Ekip'te doğru uygulanıyor, Satış bozuyor.
- **Bilgi mimarisinin çoğu yerinde:**
  - departmana göre gruplanmış kadro ve risk şeridi,
  - boru hattı ile portföyün ayrılması,
  - seçenekteki etki çipleri ve gerekçeli kilitli seçenek,
  - üst barın rakam kümesi ve "Artıda" durumu.
- **Token ve tema hattı ile UI lab** (UiTokens, build_theme.gd, deterministik çekimler). Tek şart: bir sonraki tur yalnız token'ı değil yerleşimi, bileşeni ve sanatı da değiştirebilmeli.
- **Renk körü paleti ve yerel sayı biçimi** ($10.000, %56).
- **"Ekonomi Postası"nın özel gazete adası olması.**
- **Her çalışan ve Frank için hazır karakterler ve büstler.** Okunur boyda gösterilmeyi bekliyorlar.

---

## 2. Referans panosu

Referanslar çözdükleri soruna göre gruplandı. Her maddede sırasıyla dört şey var: ne yaptığı, neden işe yaradığı, bizim alacağımız şey ve kaynak ile görsel.

### 2.1 Üst bar ve KPI'lar

**Frostpunk 2 (11 bit, 2024): ölümcül kaynak süre olarak yazılır** [G]
- Ne yapıyor: Sol üstte üç satır duruyor. "WHITEOUT ARRIVING IN", altında büyük amber serif "24 WEEKS", onun altında "Stockpiles ready in 146 weeks at current rate". Üst şeritte gelir ve giderler işaretli sayılar, altlarında küçük işaret renkli çubuklar var.
- Neden işliyor: Koşuyu bitirecek sayı oran olarak değil süre olarak okunuyor, "bu hızla" tahmini de hemen yanında.
- Alacağımız: RUNWAY yuvası "Artıda" ya da "19 hafta · 12 Ağustos'ta biter (bu hızla)" yazar. Kepenk sayacı başlayınca aynı yuva kırmızıya ve hafta sayımına döner.
- Kaynak: https://www.gameuidatabase.com/gameData.php?id=1965
- Görsel: https://www.gameuidatabase.com/uploads/Frostpunk-209262024-104957-45092.jpg

**Frostpunk (2018): "Coal will last for: 2h 44m"** [G araştırmacı]
- Ne yapıyor: Ekonomi sekmesindeki tabloda verim çubukları ile günlük yeşil ve kırmızı çipler var. Tablonun altında amber tek cümle kömürün ne kadar yeteceğini söylüyor.
- Alacağımız: Finans penceresinde runway düz bir cümle olur; her gider kalemi haftalık işaretli çip taşır.
- Kaynak: https://www.gameuidatabase.com/gameData.php?id=38
- Görsel: https://www.gameuidatabase.com/uploads/Frostpunk07162020-062411-40871.jpg

**Crusader Kings III (Paradox, 2020): değerin altında gri delta** [G araştırmacı]
- Ne yapıyor: Üst bar ince çizgilerle bölümlere ayrılmış. Her bölümde ikon, büyük değer ve altında daha küçük gri aylık değişim var; değişim yalnız negatifken kırmızı.
- Neden işliyor: Oran ayrı bir sütun istemiyor. Renk yalnız kötü haber olduğunda harcanıyor.
- Alacağımız: Ayrı NET sütunu kalkar; KASA'nın altında gri "+$2,5K / hafta" yazar, eksiye dönünce kırmızı olur.
- Kaynak: https://store.steampowered.com/app/1158310/
- Görsel: https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1158310/0ed600e9f23f5fd9eebaa4bc16e883b5fbc12d46/ss_0ed600e9f23f5fd9eebaa4bc16e883b5fbc12d46.1920x1080.jpg

**Victoria 3 (Paradox, 2022): akış satırı, stok satırı, saat kadranı** [G]
- Ne yapıyor: Üst barın ilk satırında beş ana oran işaretli büyük sayı ve ince çubukla duruyor, ikinci satırda stoklar. Sağda tarih, dolan bir haftanın günü çubuğu ("Thursday") ve hız için Roma rakamlı bir saat kadranı var.
- Alacağımız:
  - Akışlar (MRR, burn, net) ile stoklar (kasa, marka, itibar) iki ayrı katta durur.
  - Beş hız düğmesi tek bir alete dönüşür.
  - Haftanın ilerleyişi dolan bir çubukla gösterilir.
- Kaynak: https://forum.paradoxplaza.com/forum/developer-diary/victoria-3-dev-diary-30-user-interface-overview.1507166/
- Görsel: https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/529340/ee3c20b6e34c83fa3f0784ec890e98214cb1affb/ss_ee3c20b6e34c83fa3f0784ec890e98214cb1affb.1920x1080.jpg

**FM24, OOTP 26 ve F1 Manager 24: zaman düğmesi sıradakini söyler** [G] [K]
- Ne yapıyor:
  - FM24'te sağ üstte tek bir doygun düğme var ve etiketi duruma göre değişiyor (CONTINUE, INBOX). Yanıt bekleyen önemli bir mesaj varsa "Must Respond" oluyor ve zaman ilerlemiyor.
  - OOTP'de yeşil CONTINUE'nun altında ne yapacağını söyleyen bir alt satır ("Auto-play until next week") ve DÜN / BUGÜN / YARIN şeridi var.
  - F1M24'te sağ üstteki Continue sıradaki durağı ve uzaklığını yazıyor ("To Sponsor Negotiation, 6 days").
- Alacağımız: Hız aletinin yanına bir "Sıradaki: Ege Sigorta toplantısı · Perşembe 10:00" satırı gelir. Karar bekleyen bir olay varken aynı blok "Cevap bekliyor" durumuna geçer.
- Kaynaklar: https://community.sports-interactive.com/sigames-manual/football-manager-2024/inbox-and-news-r4956/ · https://digitalchumps.com/out-of-the-park-baseball-26-review-pc/ · https://www.artstation.com/artwork/XJe96L
- Görseller: https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/2252570/ce6e4238dd12ec17f43ad48882f7a72f8e10cddf/ss_ce6e4238dd12ec17f43ad48882f7a72f8e10cddf.1920x1080.jpg · https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/3116890/ss_6abcee8d0289cce167f41c07995fab5f7eda27e1.1920x1080.jpg · https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/2591280/ss_063927908ddd1ce983e5868774ae2bf9f53995f7.1920x1080.jpg

**Offworld Trading Company ve Two Point Campus: tek kahraman sayı** [G] [İ]
- Ne yapıyor:
  - Offworld'de sol sütunun tepesinde nakit büyük beyaz rakamla ("$ 312K") yazıyor, altında kırmızı bir borç satırı var. Her satırda fiyat en büyük öğe; değişim oranı küçük yeşil ya da kırmızı. RPS'in cümlesi: "Offworld is played in the numbers at the side of the screen."
  - Two Point Campus'ta sağ altta nakit çok büyük kalın rakamla duruyor (görselde 416,137).
- Alacağımız: KASA üst barın en büyük rakamı olur, diğerleri bir boy küçük kalır.
- Kaynaklar: https://www.rockpapershotgun.com/offworld-trading-company-review · https://www.gameuidatabase.com/gameData.php?id=2390
- Görseller: https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/271240/ss_fdb1d1301e763bd7cdbed153a2e83a2801bbdc67.1920x1080.jpg · https://www.gameuidatabase.com/uploads/Two-Point-Campus-MouseKeyboard04262026-070137-29318.jpg

**Suzerain ve Manor Lords: sayının nedeni, üstüne gelince** [K]
- Ne yapıyor: Suzerain'in istatistik ipucu sayıyı nedenlerine ayırıyor: yeşil "(+1) per turn from X", kırmızı "(-3) per turn from Y". 3.1 yamasında bu döküm "to reduce clutter and improve readability" gerekçesiyle yeniden düzenlendi. Manor Lords üst kaynak çubuğunu üstüne gelince genişletiyor.
- Alacağımız: KASA ve BURN'ün üstüne gelince haftalık döküm açılır: maaşlar, altyapı, gelir kalemleri.
- Kaynaklar: https://store.steampowered.com/news/app/1207650/view/509578043853897957 · https://steamcommunity.com/app/1363080/discussions/0/598539452432936012/

### 2.2 Navigasyon ve ray

**Football Manager 24'ten 26'ya, 26'dan 27'ye: türün en pahalı dersi** [K] [İ]
- **FM24:** Hep görünen, ikon ve etiketli 18 hedefli bir sol kenar çubuğu vardı. Bugün hâlâ "en iyi görünen FM" diye savunuluyor.
- **FM26:** Kenar çubuğu kaldırıldı. Yerine üstte altı kategorili, üzerine gelince açılan menüler geldi. Ekranlar "karo"lara bölündü ve karolar "kart"lara açılıyordu.
  - Oyuncular: "death by dropdown", bir lig tablosu tek tıktan beş tıka çıktı, "big buttons, massive spacing, tiny text".
  - Steam'de Mostly Negative (%22 olumlu), günlük oyuncu yaklaşık 85 binden yaklaşık 32 bine indi.
  - SI sonradan karoların iki işi birden yaptığını kabul etti: "the presentation of information and navigation".
- **FM27 düzeltmesi:**
  - Karolar yalnız bilgi taşıyor.
  - Üstte iki sabit menü var ve her ana madde doğrudan ana ekrana gidiyor; oyuncu açılış ekranını seçebiliyor.
  - Her bölümün tepesinde o alanın ana eylemlerini toplayan bir "control panel" var.
  - Default, Detailed ve Condensed adlı üç yoğunluk kipi eklendi.
- Alacağımız: Etiketli sol ray kalır ve derinlik hover'a gömülmez. Her pencere kendi ana listesiyle açılır; tepesinde 2-4 eylemlik bir kontrol şeridi olur (Ekip: işe al, mesai; Satış: fiyat duruşu).
- Kaynaklar: https://www.footballmanager.com/fm27/features/fm27-clearer-interface-smoother-navigation · https://www.invenglobal.com/articles/23673/fm26-developer-why-we-had-to-change-the-ui · https://gamerant.com/football-manager-26-steam-reviews-mostly-negative/ · https://www.operationsports.com/football-manager-26-is-tracking-as-the-lowest-steam-performer-in-over-a-decade/
- Görseller: https://cdn.footballmanager.com/site/2026-09/2-SquadScreen.png · https://cdn.footballmanager.com/site/inline-images/2%20Portal%20Example_opt.jpg

**Motorsport Manager (2016): ekranın ne işe yaradığını söyleyen tek satır** [G araştırmacı] [İ]
- Ne yapıyor: Üst barda büyük harfle ekran adı var, altında tek satır açıklama ("HEADQUARTERS / Build something, or upgrade your base of operations."). Alt navigasyonda ikon ve etiketli maddeler kırmızı sayı rozetleri taşıyor; en sonda tarih ve turuncu Continue duruyor. İnceleme: "All of the pertinent information is within reach".
- Alacağımız: Her pencere başlığının altına bir satırlık amaç cümlesi gelir. Rozetler sayı taşır.
- Kaynaklar: https://www.digitallydownloaded.net/2016/11/review-motorsport-manager-pc.html · https://store.steampowered.com/app/415200/Motorsport_Manager/
- Görsel: https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/415200/ss_49297131e20d1919ecf867710d4c7723e823fde7.1920x1080.jpg

**Kısayollar ve geri gitme: olmayınca şikâyet konusu** [İ] [K]
- Mad Games Tycoon 2'de F1-F6, Industries of Titan'da 1-6 tuşları ana menüleri açıyor.
- Startup Panic incelemesi "we don't even have keyboard shortcuts" diyor; Big Ambitions ve Mad Games Tycoon 2 geri dönüş olmadığı için eleştiriliyor.
- Josh Bycer'ın strateji arayüzü kuralı: neredeyse her şeye kısayol ver ve kısayolu arayüzde göster.
- Alacağımız: Ray karolarında 1-8 kısayol numaraları görünür; pencerede geri tuşu çalışır.
- Kaynaklar: https://www.magicgameworld.com/mad-games-tycoon-2-controls-hotkeys/ · https://www.gamedeveloper.com/design/ui-strategy-game-design-dos-and-don-ts

**Victoria 3 düğme ailesi: gitmek başka, yapmak başka** [K]
- Ne yapıyor: Bütün düğmeler zümrüt yeşili ahşap dokulu ama iki tonda: biri gezinme, biri eylem için. Eylem düğmelerinin ince altın kenarı var, öncelikli olanların köşesi süslü (DD30).
- Alacağımız: Satış'taki dört sarı düğme sorununun ilacı bu. Her görünür alanda bir birincil eylem olur, gezinme düğmeleri ikincil kalır.
- Kaynak: https://forum.paradoxplaza.com/forum/developer-diary/victoria-3-dev-diary-30-user-interface-overview.1507166/
- Görsel: https://forumcontent.paradoxplaza.com/public/783323/DD30%201.png

### 2.3 Canlı dünya üstünde pencereler

**Two Point Campus: liste solda, kampüs sağda canlı** [G]
- Ne yapıyor:
  - Tam genişlik turkuaz başlık şeridi ("STAFF LIST") ve kırmızı bir kapatma X'i var.
  - Liste ekranın sol yarısına yaslanmış ve bir katlama sekmesi taşıyor; sağ yarıda kampüs canlı duruyor.
  - Filtre sekmeleri ikonlu ve sayılı.
  - Her satırda portre, isim, durum ikonu, sayılı nitelik ikonları, gülen yüzlü mutluluk çubuğu ve şimşekli enerji çubuğu var. Satırda sayı yok, durum çubuk ve ikonla okunuyor.
  - Satıra tıklayınca sağda kişi kartı açılıyor ve < > ile kişiler arasında geziliyor.
- Neden işliyor: Liste ve dünya aynı anda görünüyor, satırlar tek bakışta okunuyor.
- Alacağımız: Ekip penceresinin doğrudan şablonu.
- Kaynaklar: https://www.gameuidatabase.com/gameData.php?id=2390 · https://gamingbolt.com/two-point-museum-review-carefully-curated-oddity
- Görseller: https://www.gameuidatabase.com/uploads/Two-Point-Campus-MouseKeyboard04262026-070137-29318.jpg · https://www.gameuidatabase.com/uploads/Two-Point-Campus-MouseKeyboard04262026-070140-3338.jpg

**Planet Zoo ve Planet Coaster: pencere aşağıda solda, dünyanın üst üçte biri canlı** [G araştırmacı] [İ]
- Ne yapıyor: Yönetim pencereleri ekranın yaklaşık %60 genişliğinde ve üçte iki yüksekliğinde, sol alta yaslanıyor. Üstteki dünya şeridi hep görünür. Planet Zoo'da her pencerenin sol üst köşesinden taşan renkli bir bayrak sekmesi başlık işi görüyor. Tablolarda renkli durum kelimeleri var ("High Demand" kırmızı).
- Uyarı: Planet Coaster 2 iç içe alt menülere geçti ve "plays hide and seek with basic information" diye eleştirildi (COGconnected).
- Kaynaklar: https://www.gameuidatabase.com/gameData.php?id=1025 · https://cogconnected.com/review/planet-coaster-2-review/
- Görsel: https://www.gameuidatabase.com/uploads/Planet-Zoo11162021-123847-52486.jpg

**Hearts of Iron IV (Paradox, 2016): tam ekran yok, küçük pencere** [K]
- Ne yapıyor: Paradox'un baştan UX tasarımcısıyla yaptığı ilk oyun. DD53: "We skipped the fullscreens and went for smaller windows instead for example, this way you can still keep an eye on the map". Pencereler "gritty and dark" ki doygun ikonlar öne çıksın.
- Alacağımız: Pencereler daralır ve ofis okunur kalır.
- Kaynak: https://thearmoredpatrol.com/2016/04/22/hearts-of-iron-iv-development-diary-53-2d-art/

**F1 Manager 24 (Frontier): 3B sahne önünde yüzen paneller için tasarlanmış perde** [K] [G]
- Ne yapıyor: Associate UI Design Lead Aaron Rawlinson'un ArtStation sunumunda dört karar var.
  - Takım yönetimi ekranlarında "unnecessary nested levels" azaltıldı.
  - "floating components" eklendi.
  - Ortak arka planlara hafif hareket ve vurgu şekilleri kondu.
  - Bir "DARK ACCENT VISUAL" katmanı tanımlandı: "overlay a background where needed and gradiate off to transparency ... typically when a panel is floating with 3D content behind it".
- Neden işliyor: Bizim sorunumuzun aynısı. Panel ile 3B sahne arasında bilinçli tasarlanmış bir geçiş var.
- Alacağımız: Pencerenin arkasında kenara doğru saydamlaşan bir perde ve gerçek bir gölge.
- Kaynak: https://www.artstation.com/artwork/XJe96L
- Görseller: https://cdnb.artstation.com/p/assets/images/images/078/489/081/large/aaron-rawlinson-f1m24-cg-01.jpg · https://cdnb.artstation.com/p/assets/images/images/078/489/087/large/aaron-rawlinson-f1m24-cg-03.jpg

**Pencere açılınca dünya susar: Cities Skylines II, Rise of Industry, Parkitect, Victoria 3** [K] [G araştırmacı]
- Cities Skylines II bilgi görünümlerinde şehri dokusuz beyaz ve gri "kil"e çeviriyor; yalnız veri renkli kalıyor. Aynı oyunun 2026 bakımı cam saydam panelleri geri çekti ve bir panel opaklık ayarı ekledi.
- Rise of Industry bir bina paneli açıkken haritayı griye çeviriyor; yalnız seçili bina, rotası ve bağlı binalar renkli kalıyor.
- Parkitect personel kipinde parkı kile çeviriyor. Ayrıca imleç pencereden çıkınca pencereyi küçültmeyi deniyor ("can get in the way").
- Victoria 3'te bir panel açılınca harita o panelin veri kipine geçiyor.
- Alacağımız: Ekip açılınca ofis hafifçe soluklaşır ve yalnız ekip masaları renkli kalır. İleride bir "moral merceği" olabilir. Buzlu cam panel yapmayız.
- Kaynaklar: https://www.paradoxinteractive.com/games/cities-skylines-ii/news/upcoming-visual-updates · https://www.paradoxinteractive.com/games/cities-skylines-ii/news/patch-notes-spring-cleaning · https://www.gameuidatabase.com/gameData.php?id=237 · https://themeparkitect.tumblr.com/post/157367279687/devlog-update-134
- Görseller: https://www.gameuidatabase.com/uploads/Rise-of-Industry07132020-010411-59760.jpg · https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/949230/c2092a2047a684f24faaaa47e58dc1dc1d3a57e6/ss_c2092a2047a684f24faaaa47e58dc1dc1d3a57e6.1920x1080.jpg

**Dünya kendi durumunu söyler: Motorsport Manager, Startup Company, Mad Games Tycoon 2, Game Dev Tycoon, Prison Architect** [G araştırmacı]
- Motorsport Manager'ın 3B merkezinde binaların üstünde sahne içi etiketler var ("DESIGN CENTRE, Max Level Reached").
- Startup Company her masanın üstünde isim, renkli ilerleme çipleri ve o anki işi gösteriyor ("INPUT MODULE (85%)", "WAITING FOR TICKET").
- Mad Games Tycoon 2'de her odanın üstünde ikon, "[3/5]" doluluk, iş adı ve ilerleme çubuğu olan bir rozet var; aynı oyun üstünde çalışan odaları renkli çizgiler bağlıyor.
- Game Dev Tycoon'da puan baloncukları çalışanlardan yükselip sayaçlara uçuyor.
- Prison Architect oda adlarını zemine şablon harfle boyuyor; acil durum yazısı kutusuz, doğrudan dünyanın üstünde.
- Alacağımız: Bugün 3B ofisimiz hiçbir veri taşımıyor. Masaların üstüne isim, iş ve moral rozeti gelir; satış kapanınca ilgili masadan üst bara para yükselir.
- Görseller: https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/415200/ss_cfa613ab902191e4c167aeb5741b38a89d12e626.1920x1080.jpg · https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/606800/ss_74de0b0d767febb4e7d11406b38e199884f3d678.1920x1080.jpg · https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1342330/ss_cae936ed7a0cef533ce6d471e5289085cce5eb95.1920x1080.jpg

**Uyarılar: türün en yakın akrabaları neden eleştirildi** [İ] [K]
- **Startup Company (en yakın tema):** Bizim gibi aynı anda tek pencere açıyor. Oyuncu yorumu: "you can only have one window open at one time making for a lot of useless clicking". Başka bir yorum görünüşü "pesky mobile style. Everything is big and blobby" diye anlatıyor (103 oy).
- **Startup Panic (iskeleti bizimkiyle neredeyse aynı):** Görev paneli "can cover more of the office than is appropriate".
- **Software Inc:** Üst üste yüzen beyaz pencereler için "looks like a demo UI that you just kept on adding to" deniyor.
- **Frostpunk 2:** Beyaz tonlu arayüz karlı dünyanın üstünde kontrast kaybediyor (New Game Network: "the entire UI has a white tint"). Bizim krem pencere de sıcak kremli ofisin üstünde aynı tuzakta.
- Kaynaklar: https://steamcommunity.com/profiles/76561198029900005/recommended/606800/ · https://store.steampowered.com/app/1045610/Startup_Panic/ · https://steamcommunity.com/profiles/76561198142195723/recommended/362620/ · https://www.newgamenetwork.com/article/2813/frostpunk-2-review/

### 2.4 Yoğun tablolar ve kişi listeleri

**Football Manager: 1-20 tamsayı ve renk bandı** [G] [K]
- Ne yapıyor:
  - Nitelikler üç sütunda 1-20 tamsayı. Değerler kırmızıdan griye ve beyaza, oradan parlak yeşile bantlanıyor; renkleri oyuncu değiştirebiliyor.
  - Seçili rol için önemli nitelikler renkli bir bantla vurgulanıyor.
  - FM27'nin kadro tablosu yaklaşık 20 px satırda yaklaşık 11 sütun taşıyor.
- Neden işliyor: Beş satırda üç beceriyi göz tek taramada kıyaslıyor. İkonun tek başına anlam taşıması eleştiriliyor (FM21'in yüz ikonlu morali, FM26'nın "essentially invisible" sakatlık ikonu).
- Alacağımız: 75 yıldız yerine her beceri için bir sayı ve renk bandı. Satırın rolüyle ilgili beceri vurgulanır.
- Kaynaklar: https://www.footballmanager.com/fm27/features/fm27-clearer-interface-smoother-navigation · https://community.sports-interactive.com/forums/topic/611878-fm27-uiux-faq/
- Görseller: https://cdn.footballmanager.com/site/2026-09/2-SquadScreen.png · https://cdn.footballmanager.com/site/2026-09/6-1-Scaling.png

**Out of the Park Baseball 26: sayı, çubuk, bugün ve potansiyel** [G araştırmacı] [İ]
- Ne yapıyor: Derecelendirmeler sayı ve değere göre renklenen çubukla gösteriliyor. Mevcut ve potansiyel değer çift olarak duruyor, yanında yüzdelik noktaları var. Ayarlarda renkli çubuk ya da düz sayı seçilebiliyor.
- İnceleme: "There's so much thrown at you, yet the information is nicely organized and easily understood".
- Uyarı: OOTP 27 nitelik sırasını değiştirdiği için eleştirildi ("muscle memory"). Sütun sırası bir kez sabitlenir.
- Kaynaklar: https://digitalchumps.com/out-of-the-park-baseball-26-review-pc/ · https://forums.ootpdevelopments.com/showthread.php?p=5279128

**Neden listesi: Software Inc "Thoughts" ve Good Company** [G araştırmacı] [İ]
- Software Inc'in çalışan penceresinde memnuniyetin her nedeni tek satır sade dille yazılıyor ve yanında kırmızı ya da yeşil bir çubuk var ("There is nowhere to sit", "I'm very happy with my salary").
- Good Company'nin çalışan kartında o kişinin canlı 3B render'ı duruyor. İpucu "neden (değer): etki (değer)" düzeninde. Mutluluk çubuğunda görünür bir eşik çentiği var.
- Nedeni göstermeyen oyunlar tam bundan eleştiriliyor. Mad Games Tycoon 2 için: "lack of useful info about why my employees remain unhappy".
- Alacağımız: Selin'in satırında moral 22'nin yanında ayrılma eşiğine çentik olur; kişi kartında bir "neden" listesi açılır. Portre olarak bizde zaten olan 3B karakterin büstü kullanılır.
- Kaynaklar: https://steamcommunity.com/profiles/76561198046113626/recommended/1342330/ · https://www.escapistmagazine.com/work-doesnt-suck-in-management-sim-good-company/
- Görseller: https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/362620/ss_a3008f0189f7ee81f9c9fbf6cb8edccaf42c3223.1920x1080.jpg · https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/911430/ss_f010e82143194c77c2640e8675777bef482ac5b2.1920x1080.jpg

**This Is the Police: bir portre, bir sayı, bir durum şeridi** [G]
- Ne yapıyor: Her memur bir kart: üstte isim, altında tek bir başlık sayısı (★290), büyük portre ve altta durum şeridi (yeşil). Tam istatistik sayfası tıklayınca açılıyor.
- Alacağımız: Bu, Ekip için tablonun alternatifi değil, tamamlayıcısı: kişi kartı ve olay kartındaki "etkilenen kişi" yuvaları için model.
- Kaynak: https://www.gameuidatabase.com/gameData.php?id=852
- Görsel: https://www.gameuidatabase.com/uploads/This-Is-the-Police-206082021-101933-16944.jpg

**Crusader Kings III: sekmede sayı, portrede rozet** [G araştırmacı]
- Ne yapıyor: Sekmeler sayı taşıyor ("Family 12 / Courtiers 19 / Subjects 62"). Portrelerin üstünde ilişki verisi rozet olarak duruyor (görüş +23 / -36, kurukafa, küçük arma).
- Alacağımız: KADRO ve GÖREVLER sekmelerinde sayı olur; portre rozetleri YENİ, AYRILABİLİR, İZİNDE durumlarını gösterir. Bugünkü metin çipleri bu işe dönüşür.
- Kaynak: https://www.pcgamesn.com/crusader-kings-3/review-ck3
- Görsel: https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1158310/927b699bb755884d14c31ccdfc7ffe2211730ca7/ss_927b699bb755884d14c31ccdfc7ffe2211730ca7.1920x1080.jpg

**Satış satırı: Capitalism Lab, Planet Zoo, Industries of Titan, Europa Universalis V** [G araştırmacı] [K]
- Capitalism'in ürün raporunda satır başına şunlar var: ürün görseli, 12 aylık satış sparkline'ı, iki pazar payı pastası, fiyat, kalite ve marka için "sen / ortalama" sütunları.
- Planet Zoo durumu renkli kelimeyle yazıyor ("High Demand" kırmızı).
- Industries of Titan'ın tasarımcısı Ben Humphreys: kirliliği ham sayıdan "low, medium and high with colour" yapmak sistemi "way easier to understand" hale getirdi.
- EU5'in diplomasi kartlarında değer çipleri aynı zamanda o değeri değiştiren düğmeler.
- Alacağımız: Müşteri satırı MRR sparkline'ı, koltuk / plan oranı ve renkli bir sağlık kelimesi taşır. Kelimeler ayrı renklerde olur: RİSK ALTINDA kırmızı, BÜYÜMEK İSTİYOR yeşil. Çip aynı zamanda eylem düğmesi olabilir.
- Kaynaklar: https://benui.ca/about/industries-of-titan · https://forum.paradoxplaza.com/forum/developer-diary/tinto-talks-76-13th-of-august-2025.1855048/
- Görseller: https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/638200/ss_1b742d5371c8a628963490deef376336f482ad81.1920x1080.jpg · https://forumcontent.paradoxplaza.com/public/1339294/country_list.png

**Uyarı ve tipografi kuralı: FM26 kartlaştırması, Butterick, IBM Carbon** [K] [İ]
- FM26 tabloları karolara çevirdi; bir bakışta görünen sütunlar kayboldu ve "I feel like I'm in a maze of screens" dendi.
- Butterick'in kuralları:
  - Aynı anlamdaki rakamlar dikey hizalanır, miktarlar sağa yaslanır, tabular rakam kullanılır.
  - Tabloda önce bütün hücre çizgileri kapatılır, gerektikçe geri açılır.
  - Yoğun tabloyu okunur yapmanın en iyi yolu hücre içi boşluğu artırmaktır.
- IBM Carbon'un satır merdiveni 24/32/40/48/64 px; tablo metni 14 px.
- Alacağımız: Ekip ve Satış tabloları yoğun kalır ama satır kartları ve iç içe çerçeveler kalkar.
- Kaynaklar: https://www.thickaccent.com/2025/10/24/maze-of-screens-fm26-beta-sparks-backlash-over-controversial-new-ui/ · https://practicaltypography.com/grids-of-numbers.html · https://practicaltypography.com/tables.html · https://carbondesignsystem.com/components/data-table/style/

### 2.5 Olay kartları ve modallar

**Frostpunk 2: dikey kart, kişi üstte, bedel tek kalın satırda** [G]
- Ne yapıyor:
  - Ekranın tam boyunda ortalanmış dikey bir sütun duruyor.
  - Tepede olaydaki kişinin boyanmış resmi var ve aşağı doğru buzlu cama karışıyor.
  - Altta serif büyük harf başlık ("AGAINST THE ELEMENTS") ve kategori ("SQUALOR"), sonra iki kısa serif paragraf geliyor.
  - Ardından tek kalın sans satırda somut talep ("Provide more Materials to reduce Squalor before it harms our people."), altında mavi bir sonuç satırı ("Relations marginally improve with: Wanderers").
  - En altta tirelerle çerçevelenmiş bir "DON'T ADDRESS THIS RIGHT NOW" seçeneği var. Dünya arkada bulanık ve açılmış.
- Neden işliyor: Kim, ne istiyor ve bedeli ne sorularının cevabı hiyerarşiyle sıralanmış.
- Alacağımız: Frank'in teklif kartının iskeleti bu.
- Kaynak: https://www.gameuidatabase.com/gameData.php?id=1965
- Görsel: https://www.gameuidatabase.com/uploads/Frostpunk-209262024-104909-18387.jpg

**This Is the Police: kategori sekmesi, resim, kişi yuvaları, tam genişlik karar çubuğu** [G]
- Ne yapıyor:
  - Kartın başında sarı bir kategori sekmesi var ("DISORDERLY CONDUCT (5-16)"), altında olay yerinin geniş bir illüstrasyonu.
  - Ortada gönderilecek kişiler portre yuvaları halinde duruyor; her yuvada isim ve ★ puanı var.
  - En altta ikiye bölünmüş tam genişlik karar çubuğu var: sarı SEND ve siyah CLOSE. Metin sağdaki ayrı sütunda.
  - Arkadaki harita bulanık ve karartılmış.
- Alacağımız: İK olaylarında etkilenen çalışanın portresi, satış olaylarında müşteri yetkilisi yuva olarak görünür. Karar düğmeleri tam genişlik olur ve bedel düğmenin içinde yazar.
- Kaynak: https://www.gameuidatabase.com/gameData.php?id=852
- Görsel: https://www.gameuidatabase.com/uploads/This-Is-the-Police-206082021-101933-16944.jpg

**Victoria 3: resim ve metin kartı, olayın yeri, küçültme** [G]
- Ne yapıyor:
  - Kırmızı damask başlık plakasında olayın adı ve yeri yazıyor ("Event in Île-de-France").
  - Solda büyük bir resim, sağda yarı saydam bir kart var. Kartta önce kalın soru, bir süs çizgisi, sonra italik gri alıntı geliyor.
  - Seçenek altın kenarlı zümrüt bir düğme.
  - Sağ üstte olay küçültülüp bekletilebiliyor.
- Alacağımız: Frank'in sözleri alıntı olarak dizilir. Karar kartı "sonra" diye küçültülüp üst bardaki zaman bloğunda bekletilebilir. Olayın yeri ofiste gösterilebilir (toplantı odası, kurucu masası).
- Kaynak: https://forum.paradoxplaza.com/forum/developer-diary/victoria-3-dev-diary-29-user-experience.1506484/
- Görsel: https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/529340/ee3c20b6e34c83fa3f0784ec890e98214cb1affb/ss_ee3c20b6e34c83fa3f0784ec890e98214cb1affb.1920x1080.jpg

**Dikkatin katmanları: Crusader Kings III ve RimWorld** [K]
- CK3 dikkat gerektiren şeyleri katmanlara ayırıyor ve her katmanın kuralı ayrı:
  - Üst bar uyarıları yalnız düzeltilebilecek şeyler için çıkıyor ve tıklayınca doğrudan eyleme götürüyor.
  - Ardından mini uyarılar, kapatılabilir öneriler ve az sayıda, kendiliğinden küçülen bildirimler geliyor.
  - Toast'lar üstte tek tek çıkıyor ve üzerine gelince sayaçları duruyor. Sonuçlar "without throwing up a huge event window" gösteriliyor.
- RimWorld'de olayların çoğu sağ kenarda bir mektup zarfı: mavi iyi, gri nötr, sarı kötü, kırmızı tehdit. Oyun yalnız seçim gerektiren olaylarda duruyor.
- Alacağımız: Frank ve pazar anlarının çoğu kenarda mektup ya da toast olur; ortadaki modal yalnız gerçek kararlar içindir. Sağ alttaki "Büyüme talebi masada" toast'ı bu sistemin tohumu.
- Kaynaklar: https://forum.paradoxplaza.com/forum/developer-diary/ck3-dev-diary-16-tutorials-and-tooltips-and-encyclopedias-oh-my.1345581/ · https://rimworldwiki.com/wiki/Events
- Görsel: https://forumcontent.paradoxplaza.com/public/537575/toasts.gif

**Terra Invicta: düğme zamana ne olacağını söyler** [G araştırmacı]
- Ne yapıyor: Bildirim penceresindeki üç düğmenin her biri zamanın ne olacağını gösteren bir ikon taşıyor: "CONTINUE" (oyun sürer), "CLOSE" (duraklı kalır), "TAKE ME THERE" (oraya gider ve durur). Bir türün ilk bildirimi, sonrakilerin nereye düşeceğini söylüyor.
- Alacağımız: Olay ve toplantı düğmelerinde zaman etkisi yazar. Bugünkü "SEÇİM KALICIDIR · OYUN DURAKLATILDI" satırı düğmelerin üstüne taşınır.
- Kaynak: https://store.steampowered.com/app/1176470/
- Görsel: https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1176470/2fc05e2ce502d85a0bb46acf260896b24cd5ae7e/ss_2fc05e2ce502d85a0bb46acf260896b24cd5ae7e.1920x1080.jpg

**Into the Breach ve Old World: bedel ya görünür ya yoktur** [K] [İ]
- Justin Ma: "we would sacrifice cool ideas for the sake of clarity every time."
- Old World incelemesi seçenek etkilerinin yalnız ipucunda olmasına kızıyor: "I have no idea why this information is not simply included on the relevant button instead."
- Alacağımız: Bizim EFFECT-VISIBILITY kuralı doğru. Sorun sunumda: 7 px'lik çip seçeneğin en büyük verisi olmalı, kazanç ve kayıp ayrı renkte yazmalı.
- Kaynaklar: https://www.gamedeveloper.com/design/-i-into-the-breach-i-dev-on-ui-design-sacrifice-cool-ideas-for-the-sake-of-clarity-every-time- · https://www.ancientworldmagazine.com/reviews/old-world-2021/

**Two Point ve Tennis Manager: danışman büstü dünyanın üstünde konuşur** [G araştırmacı]
- Ne yapıyor: Two Point'te danışmanın 3B büstü alttan yükseliyor. Uzun bir konuşma bandı çıkıyor ve cümlenin içindeki önemli sayılar renkli. Tennis Manager'da gerçek bir koçun benzeri olan mentor, portre ve metin kutusuyla 3B akademinin üstünde konuşuyor ve tek bir ok düğmesi var.
- Alacağımız: Frank'in karar olmayan anları bir büst ve konuşma bandı olur; oyun durmaz. Karar anları dikey kart olarak kalır.
- Kaynaklar: https://www.gameuidatabase.com/gameData.php?id=99 · https://www.gameuidatabase.com/gameData.php?id=169
- Görseller: https://www.gameuidatabase.com/uploads/TwoPointHospital04252020-104044.jpg · https://www.gameuidatabase.com/uploads/Tennis-Manager07162020-072923-67084.jpg

**Malzeme fiille gelir: Papers, Please, Hearthstone, Shadows of Doubt** [K]
- Papers, Please: damga fare basıldığı anda bir "THUNK" sesiyle iner; ret damgası geri alınamaz. Pope, tıklayıp belge görmeyi "a bit lifeless" buldu ve sürükle bırakmaya geçti.
- Hearthstone'da Jason Perry'nin sözü: "The biggest success of Hearthstone's interface is how it feels SOLID and REAL." Kartlar gölge düşürüyor, büyük yaratıklar tahtayı çatlatıyor, her kartın sesi var.
- Shadows of Doubt'ta ipi rengi suçlama gücünü, kalınlığı güvenilirliği taşıyor. Cole'un önerisi: "satisfying sound design (eg. rustles of paper, or the stamp sound)".
- Alacağımız: Malzeme geri dönüşü olmayan anlarda kullanılır: Frank'in çekini kabul, term sheet imzası, işten çıkarma. Bu anlarda hareket ve ses olur, doku tek başına yetmez.
- Kaynaklar: https://fguillen.github.io/PapersPleaseDevlogScrap/ · https://www.gamedeveloper.com/design/video-designing-an-immersive-user-interface-for-i-hearthstone-i- · http://web.archive.org/web/20260321022150/https://colepowered.com/shadows-of-doubt-devblog-4-case-folders-cork-boards/

**Startup Panic: bizim iskeletle karakterli olay kartı** [G araştırmacı] [İ]
- Ne yapıyor: Üstte KPI kartları, solda ikon rayı, ortada ofis var; iskelet bizimkinin aynısı. Olay kartında kırmızı sekmeli başlık ("The hacking"), büyük bir piksel illüstrasyon, dört satır metin ve tek tam genişlik "Confirm" var. Konuşmalarda çizilmiş bir danışman ve büyük bir karakter büstü görünüyor.
- Neden önemli: Aynı ekran iskeleti, olay bir resim ve bir konuşan taşıyınca karakter kazanıyor.
- Kaynak: https://store.steampowered.com/app/1045610/Startup_Panic/
- Görsel: https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1045610/ss_e7449058778a1085a7555913b141a1b46b969262.1920x1080.jpg

### 2.6 Haber şeridi ve bildirimler

**Offworld Trading Company: renkli isimli haber akışı ve tek satır flaş** [G araştırmacı] [İ]
- Ne yapıyor: Olay günlüğü bir haber ajansı gibi akıyor ve oyuncu adları kendi kimlik renklerinde ("Draginol bought out Silas Crichton..."). Büyük haber üst ortada tek satır sarı bir "NEWSFLASH". Satışlar haritanın üstünde "+$23K Silicon sold offworld" diye yüzüyor.
- Alacağımız: Şeritte her müşteri ve rakip kendi sabit renginde yazar. Büyük piyasa haberi modal olmaz, tek satır flaş olur.
- Kaynaklar: https://darkzero.co.uk/game-reviews/offworld-trading-company-pc/ · https://steamcommunity.com/app/271240/discussions/0/1319961868325686534/
- Görsel: https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/271240/ss_fdb1d1301e763bd7cdbed153a2e83a2801bbdc67.1920x1080.jpg

**Stellaris DD417: aciliyete göre gruplanmış günlük** [K]
- Ne yapıyor: Durum günlüğü aciliyet sırasına göre katlanabilir kategorilere ayrıldı; oyuncu kendi öncelikli maddelerini sabitleyebiliyor. Çok sık gelen ama acil olmayan bulgular ayrı bir "Findings" sekmesine taşındı: "So no longer will crises be hidden under many many first contacts".
- Alacağımız: Olaylar sekmesinde kepenk sayacı ve churn riski en üstte sabit durur; haber ve rakip hamleleri ayrı sekmeye gider.
- Kaynak: https://steamstore-a.akamaihd.net/news/externalpost/steam_community_announcements/1830797770232806

**Bildirim hacmi bir ayar: Victoria 3 DD74, FM24, EU5** [K]
- Victoria 3'ün mesaj ayarları penceresi bildirimleri yaklaşık %50 azalttı.
- FM24'ün sosyal akışında Minimal / Normal / Extensive sıklık ayarı ve her mesajda "why am I seeing this" ikonu var.
- EU5'te her mesaj türü günlüğe, duraklatan pop-up'a, duraklatmayan pop-up'a ya da harita yazısına yönlendirilebiliyor.
- Alacağımız: Olay türlerine göre "duraklat / duraklatma / yalnız şeride yaz" ayarı.
- Kaynaklar: https://www.paradoxinteractive.com/games/victoria-3/news/dev-diary-74-ux-improvements · https://forum.paradoxplaza.com/forum/developer-diary/tinto-talks-77-20th-of-august-2025.1856053/

**Gazete sonuç kanalıdır, kaplama değil: Suzerain, Hitman Blood Money, Papers, Please, Headliner** [G araştırmacı] [K]
- Suzerain'de her gazetenin kendi başlık yazısı ve sekmesi var.
- Blood Money her görevin sonunda yaptıklarını haber yapıyor. Manşet ve 47'nin robot resmi ün arttıkça netleşiyor.
- Papers, Please her güne bir gazete sayfasıyla başlıyor. Pope: "I use newspaper headlines to relay story points".
- Headliner'ın haber kartında fotoğraf, serif manşet, gövde ve portreli yazar imzası var.
- Alacağımız: "Ekonomi Postası" oyun sonuna özel ada kalır ve oynayışa tepki verir. Şeritteki yayınlar (Sektör Telgrafı, TeknoGündem...) kendi küçük başlık yazılarını taşır.
- Kaynaklar: https://en.wikipedia.org/wiki/Hitman:_Blood_Money · https://store.steampowered.com/app/918820/
- Görseller: https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1207650/c854b48f451cc3500db00d0f524aedfb6bb14f30/ss_c854b48f451cc3500db00d0f524aedfb6bb14f30.1920x1080.jpg · https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/918820/ss_7718dfb7afc0e6544104985a8fecfb89083e66f0.1920x1080.jpg

**Mad Games Tycoon 2: ikonlu ve küçük resimli bildirim kartı** [G araştırmacı]
- Ne yapıyor: Üst ortada, durum şeridinin altında bildirim kartları üst üste diziliyor. Her kartta ikon, iki satır metin, küçük resim ve kapatma X'i var.
- Alacağımız: Tek satırlık toast yerine konuşanın ya da şirketin küçük resmini taşıyan kart.
- Görsel: https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1342330/ss_7580feaaa02773e8634b9b8059e1eaa785d8eb50.1920x1080.jpg

### 2.7 Tipografi ve sayılar

**Xbox Accessibility Guidelines 101 ve 102: ölçülebilir taban** [K]
- Metin boyu gövde yüksekliğiyle ölçülür (üst çıkıntıdan alt çıkıntıya). PC'de 1080p için en az 18 px, konsolda 26 px. Metin %200'e kadar ölçeklenebilmeli, en az bir sans seçeneği olmalı, metin satırları cümle düzeninde yazılmalı.
- Kontrast: standart metin 4,5:1, büyük ya da pasif metin 3:1, yüksek kontrast kipi 7:1. Anlam yalnız renkle verilmez.
- Bizdeki durum: skala 9-16 px'de, tamamı bu tabanın altında. En zayıf tier tam da bugünkü "görünümü" taşıyan küçük gri aralıklı mono büyük harfler.
- Not: gövde yüksekliği ile punto aynı şey değil. Kabaca 16-18 px punto demek; kesin değer font başına ölçülür. [?]
- Kaynaklar: https://learn.microsoft.com/en-us/xbox/accessibility/xbox-accessibility-guidelines/101 · https://learn.microsoft.com/en-us/gaming/accessibility/xbox-accessibility-guidelines/102

**Butterick: mono, büyük harf ve rakamlar** [K]
- "Compared to proportional fonts, monospaced fonts are harder to read". Mono'nun meşru işi kod ve hizalı sayıdır; hizalı sayıyı tabular rakamlı orantılı font da yapar.
- Büyük harf yalnız kısa etiketler içindir ve her zaman harf aralığı açılır.
- Kaynaklar: https://practicaltypography.com/monospaced-fonts.html · https://practicaltypography.com/all-caps.html · https://practicaltypography.com/alternate-figures.html

**Türün gözlemi: menajerlik oyunlarında mono arayüz metni yok** [G araştırmacı]
- FM23/24/26/27, OOTP 26/27, Motorsport Manager 1-2, Eastside Hockey Manager, F1M24 ve Tennis Manager görüntülerinin hepsinde gövde ve tablo metni orantılı sans, rakamlar sağa yaslı. Başlıklar kalın ya da dar büyük harf display yüzü. Mono arayüz metnine hiç rastlanmadı. Bu bir gözlem, kural değil.

**Bloomberg Terminal: mono bir miras, amber bir kimlik** [K] [?]
- Görsel tasarım lideri Ali Jeffery: "Amber is our base font color"; "You can see it across the trading floor. You know which application is Bloomberg."
- Monospace bitmap font orijinal donanımdan piksel piksel kopyalandı; font değişikliği binlerce şikâyet aldı [?].
- Alacağımız: Siyah üst bar ve şerit, ekranda tek "sahipli" görünen öğe. Mono orada kalabilir, ama bu bir kimlik kararıdır ve krem pencerelerin içine taşınmaz.
- Kaynaklar: https://digitalcontentnext.org/blog/2017/05/15/bloombergs-customer-centric-design-ethos/ · https://ted-merz.com/2021/06/26/amber-on-black/

**Suzerain 2.0: yalnız serif de sorun** [K] [İ]
- 2.0'da oyuncular yalnız serifli, iri ve çift satır aralıklı metni reddetti. Torpor font seçenekleri (OpenDyslexic dahil), eksiye inen UI ölçeği ekledi ve sans seçeneğini geri getirdi.
- Alacağımız: Serif anlatı ve başlıkta kalır; veri ve etiket sans olur.
- Kaynak: https://steamcommunity.com/app/1207650/discussions/0/3806156528939612945/

**Persona 5: kimlik kararlarının sırası** [K]
- CEDEC 2017 panelinde karar sırası şöyle anlatılıyor: önce ana renk (P5 kırmızı), sonra logo, sonra "key font", en son en fazla bir yardımcı renk. Parlak ışık yüksek önceliği, loş ışık düşük önceliği gösteriyor.
- Alacağımız: Önce bir sahipli renk seçilir, sonra logo (bugün yer tutucu kare), sonra font.
- Kaynak: https://personacentral.com/persona-5-panel-concept-development-ui/

**Finans ürünlerinin eşleştirmesi: Robinhood ve Linear** [K]
- Robinhood 2024 kimliği: sıcak bir serif manşet (Martina Plantijn), karakterli bir sans (RH Phonic), siyah, beyaz, olgun nötrler ve tek bir imza vurgu (Robin Neon). "When it comes to standing out in a sea of fintech sameness, less is more."
- Linear: başlıkta Inter Display, gövdede Inter. 2026 bakımında kenar çubuğu birkaç kademe soluklaştırıldı: "Don't compete for attention you haven't earned".
- Kaynaklar: https://www.portorocha.com/robinhood · https://linear.app/now/behind-the-latest-design-refresh

**Bizim fontlar hakkında ölçüm** (bu rapor için fontTools ile)
- IBM Plex Sans'ın rakamları varsayılan olarak tabular: on rakamın hepsinin ilerlemesi 600. Tabloya ek ayar gerektirmez.
- Source Serif 4 hem tnum hem pnum taşıyor.
- Aday fontların lisansı OFL (google/fonts `ofl/` dizininde): Rubik, Barlow Condensed, IBM Plex Sans Condensed, Inter, Figtree, Nunito Sans, Bricolage Grotesque. İlk altısının dosyasında ğ Ğ ı İ ş Ş ç Ç ö Ö ü Ü gliflerini tek tek kontrol ettim, hepsi tam. Bricolage Grotesque'te yalnız Google'ın latin-ext alt kümesini gördüm. Rubik, Barlow Condensed ve Inter'de tnum özelliği var; Plex Sans Condensed ve Nunito Sans'ın rakamları varsayılan tabular.
- Hatırlatma: 2026-08-03 Font Duruşması'nda mevcut üçlü (Source Serif 4 / IBM Plex Sans / JetBrains Mono) kanon seçildi. Mono'yu veri alanından çıkarmak bu kararı yeniden açar. Aile eklemek ya da değiştirmek de öyle.

### 2.8 Renk ve malzeme

**Against the Storm (Eremite, 2022): "jenerik" şikâyetinin belgelenmiş tedavisi** [K] [G araştırmacı]
- Ne yapıyor: Süslü ama okunmaz ilk arayüz ("pretty, but a bit unreadable") sadeleştirildi: koyu zemin, okunur fontlar, daha az süs. Oyuncular bu kez karakterin kaybolduğunu söyledi. Stüdyo "we want to meet you halfway" dedi ve pencere ile panel zeminine toprak yeşili bir deri dokusu, daha geniş ve süslü çerçeveler ekledi. Canlı renkleri kıstı. Yerleşimi ve satırları değiştirmedi.
- Neden önemli: Senin şikâyetinin en yakın akrabası. Çözüm yeni bir metafor değil, çerçeveye tek malzemeydi.
- Kaynaklar: https://eremitegames.com/interface-update/ · https://eremitegames.com/devlog-april-2022/
- Görseller: https://eremitegames.com/wp-content/uploads/2022/04/UI-Improvements-Before.jpg · https://eremitegames.com/wp-content/uploads/2022/04/UI-Improvements-After.jpg

**Victoria 3 DD30: süs yalnız çerçevede, başlıkta ve düğmede** [K]
- Ne yapıyor: Sanat ilkeleri "Prestigious", "Vintage and Idyllic", "Detailed yet Approachable" ("intricate elements but used sparingly"). Art Nouveau süsü yalnız çerçevelerde, kenarlarda ve başlıklarda; veri alanı düz. İkonlar üç kademeli: mallar ayrıntılı illüstrasyon, olaylar render nesne, istatistikler sade siluet.
- Kaynak: https://forum.paradoxplaza.com/forum/developer-diary/victoria-3-dev-diary-30-user-interface-overview.1507166/
- Görsel: https://forumcontent.paradoxplaza.com/public/783323/DD30%201.png

**Tropico 6: "dosya" fikrinin yayımlanmış hali** [G] [İ]
- Ne yapıyor: Her pencere nane kremi kâğıtlı, sol kenarı spiral ciltli, lacivert çerçeveli ve altın köşeli bir defter sayfası. Olaylarda ataşlı sepya fotoğraf var. Büyük sayfanın küçük bir kısmı metin, geri kalanı boş.
- İncelemeler: "cluttered, far from user-friendly" (Wccftech), "Cluttered and not userfriendly UI" (TechSpot).
- Neden önemli: Kâğıt çerçeve boş alanın etrafında bir resim çerçevesine dönüşüyor, veri küçük kalıyor.
- Kaynaklar: https://www.gameuidatabase.com/gameData.php?id=408 · https://wccftech.com/review/tropico-6-review/ · https://www.techspot.com/products/pc-games/tropico-6.200921/
- Görsel: https://www.gameuidatabase.com/uploads/Tropico-612222020-070118-97944.jpg

**Two Point: kâğıt ekran başına bir kez** [G araştırmacı]
- Ne yapıyor: Kâğıt her ekranda en fazla bir nesne olarak görünüyor. Banka dökümü traktör delikli nokta vuruşlu bir çıktı, aylık kâr bir fiş, yapı tepsisi dizili dizin kartları, tarih bir masa takvimi. Geri kalan her şey düz arayüz.
- Alacağımız: Finans'ta ay kapanışı bir fiş olabilir, Frank'in çeki bir çek, term sheet imzalı bir sayfa. Pencere kaplaması kâğıt olmaz.
- Kaynaklar: https://www.gameuidatabase.com/gameData.php?id=99
- Görsel: https://www.gameuidatabase.com/uploads/TwoPointHospital04252020-105012.jpg

**Anno 1800 ve Anno 117 (Ubisoft): kalıcı olan koyu, geçici olan parlak; seçime tek renk** [K] [İ]
- Anno 1800 devblog'unda "form follows function" ve "minimal amount of ornamentation, materials, and textures" var; aksi halde "UI itself would start competing with the actual game". Kalıcı HUD göz yormasın diye koyu, pop-up ve bildirimler dikkat çeksin diye daha parlak. Yeni HUD tam bir bar değil, üst kenarda yüzen üç ayrı kapsül; dünya aralarından görünüyor.
- Anno 117'de Tyrian moru yalnız "seçili" durumuna ayrıldı. Oyuncular siyah beyaz ikonların "place holders widgets" gibi durduğunu söyledi; bu bizim hazır Lucide ikonlarımıza doğrudan uyarı.
- Kaynaklar: https://www.anno-union.com/devblog-user-interface-2/ · https://steamcommunity.com/app/3274580/discussions/0/604166319349331285/
- Görsel: https://www.anno-union.com/wp/wp-content/uploads/2018/06/DevBlog_UI_UX_HUD-1.jpg

**Jenerik kaplamanın bedeli: Mad Games Tycoon 1 ve 2, Software Inc, Production Line, Hearts of Iron IV** [İ] [K]
- MGT2 için bir oyuncu, senin şikâyetini başka bir oyunun ağzından söylüyor: "The first games UI was a bit kiddy but it worked and had its own style. The UI here just...gets the job done".
- Software Inc için "looks like a demo UI", Capitalism için "outdated" deniyor.
- Cliff Harris (Production Line): estetiğe duyarlı oyuncular "coder art" görünce oyunu amatör sanıp geçiyor. Stüdyo sonunda profesyonel bir arayüz tasarımcısı tuttu. Big Pharma (Fully Illustrated) ve Offworld (iki özel arayüz geliştiricisi) de aynı yoldan gitti.
- HOI4'ün erken konsept sayfasında sanatçı aşırı bombeli bir çerçeveye "UGGLY" yazmış. Ağır krom denenip reddedildi.
- Kaynaklar: https://steamcommunity.com/profiles/76561198339275668/recommended/1342330/ · https://www.positech.co.uk/cliffsblog/2017/05/09/gui-updates/ · https://thearmoredpatrol.com/2016/04/22/hearts-of-iron-iv-development-diary-53-2d-art/
- Görsel: https://i.imgur.com/LmoT5Sf.jpg

**Temanın doğal malzemesi yazılımdır: Big Ambitions, The Operator, Her Story** [K] [İ] [?]
- Big Ambitions'ta yönetim, oyun içi telefon ve bilgisayardaki kurgusal uygulamalarla yapılıyor (BizMan, MarketInsider, MyEmployees, "Voogle Maps"). Uyarı: yorumlar bilginin "buried 4 clicks down" gömüldüğünü söylüyor. Metafor tek başına bilgiyi açığa çıkarmıyor.
- The Operator'ün tasarımcısı Giafferi: "My goal was to mimic a real OS ... for each part, I tried to think about how the software would actually work".
- Her Story'nin 90'lar masaüstünü öğrenmek için hiçbir şey gerekmiyor.
- Benim çıkarımım [?]: 2026'da bir kurucunun malzemesi kâğıt klasör değil, laptop ve telefon. Klasör varyantlarının "yanlış" hissettirmesinin bir nedeni bu olabilir.
- Kaynaklar: https://big-ambitions.fandom.com/wiki/Apps · https://www.gamedeveloper.com/design/the-operator-is-a-crime-solving-game-delivered-entirely-with-ui · https://www.bfi.org.uk/features/her-story-10-years
- Görseller: https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1331550/4a96de4472260ad97ccb53977d8d3e8c6a56e15a/ss_4a96de4472260ad97ccb53977d8d3e8c6a56e15a.1920x1080.jpg · https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1771980/ss_152c464d71afa7bf2a0546cab74008d0e91b20c8.1920x1080.jpg

**Renk sistemi: Stripe ve Radix** [K]
- Stripe'ın yaptığı denetimde siyah dışındaki hiçbir küçük metin rengi 4,5:1'i tutmuyordu. Palet CIELAB'da yeniden kuruldu ve bir kural kondu: "Any two colors are guaranteed to have sufficient contrast for small text if they are at least five levels apart". Rozetler aynı kuralla tonlu zemine geçti.
- Radix 12 basamaklı ölçekte her basamağa bir iş veriyor: 1-2 zemin, 3-5 bileşen durumu, 6-8 kenar, 9-10 dolgu, 11-12 metin.
- Alacağımız: UiTokens paleti elle seçilmiş adlı renkler yerine birkaç algısal rampa olarak üretilir: krem nötr, tek vurgu, 2-3 anlam rengi. Kontrast kuralı rampanın içinde durur.
- Kaynaklar: https://stripe.com/blog/accessible-color-systems · https://www.radix-ui.com/colors/docs/palette-composition/understanding-the-scale

---

## 3. İlkeler

Canlı ofis arka planlı bir girişim menajerliği için referanslardan süzdüğüm on bir ilke:

1. **Ofis sahnedir, pencere onun önünde bir alettir.**
   - Pencere bir kenara yaslanır ve ofisten canlı bir şerit bırakır.
   - Açılan pencere ofisi susturur (soluklaştırma ya da perde), ofis de pencerenin konusunu gösterir.
   - Kaynaklar: Two Point Campus, Planet Zoo, HOI4, F1M24, Cities Skylines II, Victoria 3.
2. **Karakter dünyanın çizgisinden ve konunun resminden gelir, pencere dokusundan gelmez.**
   - Arayüz ofisin kontur kalınlığını, yuvarlaklığını ve sıcaklığını paylaşır.
   - Her pencere konusunun resmini taşır: kişi, oda, müşteri.
   - Kaynaklar: Two Point, CK3, Frostpunk, Good Company, Rise of Industry.
3. **Malzeme yalnız çerçevede ve başlıkta durur; veri alanı düz, sessiz ve yüksek kontrastlıdır.**
   - Kaynaklar: Victoria 3 DD30, Against the Storm, Anno, Tufte, Butterick. Karşı örnek: Tropico 6.
4. **Malzeme ancak bir fiil ya da tepki taşıyorsa girer.**
   - İmza, damga, çek, telefon çalması: hareket ve sesle.
   - Gazete oyun sonunun adası olarak kalır.
   - Kaynaklar: Papers, Please, Hearthstone, Shadows of Doubt, Blood Money.
5. **Tek kahraman sayı vardır ve ölümcül kaynak süre olarak yazılır.**
   - KASA en büyük rakamdır. Değişim altında gri durur, yalnız kötüleşince kırmızıya döner.
   - RUNWAY hafta ve tarihle yazılır.
   - Kaynaklar: Frostpunk 1 ve 2, CK3, Offworld, Two Point.
6. **Her sayının yanında bir hüküm kelimesi ve üstüne gelince nedeni olur.**
   - Moral 22'nin yanında "Ayrılma eşiğinde" yazar, nedenler listelenir.
   - Kaynaklar: FM karoları ("Excellent"), F1M24 ("Biggest Issue: Facilities"), Software Inc Thoughts, Suzerain dökümü.
7. **Yoğunluk korunur.**
   - Yıldız dizisi yerine sayı ve renk bandı kullanılır, tablolar karta çevrilmez, sütun sırası sabitlenir.
   - Kaynaklar: FM24/27, OOTP, IBM Carbon. Karşı örnek: FM26.
8. **Olaylar ağırlığına göre yönlendirilir.**
   - Ortadaki modal yalnız karar içindir; gerisi mektup, toast ya da şerit olur.
   - Karar kartı kişiyi gösterir. Bedel düğmenin üstündeki en büyük veridir. Düğme zaman etkisini söyler.
   - Kaynaklar: CK3, RimWorld, Frostpunk 2, This Is the Police, Terra Invicta, Into the Breach.
9. **Vurgu renginin tek bir işi vardır; anlam renkleri kıt kullanılır ve şekille desteklenir.**
   - Amber yalnız birincil eylemdir. Kırmızı yalnız gerçek tehlike içindir (eksi kasa, kepenk, ayrılma).
   - Kaynaklar: Persona 5, Anno 117, Hodent, XAG 102.
10. **Yazı tabanı ölçülür.**
    - Veri orantılı sans ve tabular rakamla dizilir; mono en fazla koyu terminal şeritlerinde kalır.
    - En küçük metin 12 px, veri 14-15 px, gövde 16 px ve üstü olur. Kontrast en az 4,5:1'dir.
    - Kaynaklar: XAG, Butterick, türün ekran gözlemi.
11. **Gezinme düz, etiketli ve kısayolludur; zaman aleti sıradakini söyler.**
    - Hover menü yok, karodan gezinme yok.
    - Kaynaklar: FM24'ün FM26'ya karşı durumu, FM27, Motorsport Manager, Mad Games Tycoon 2.

Süreç için bir ek kural var ve bu bir tasarım ilkesi değil: **stil karosuna değil, gerçek ekrana bakılarak karar verilir.** Steph Chow keşif süresinin yaklaşık yarısını dünya ve rakip araştırmasına ayırıyor. Linear yüzlerce tam ekran keşfi gerçek üründe, bayrak arkasında deniyor. Edd Coates şöyle diyor: "UI/UX mistakes are often made early in development, simply from a lack of useful data."

---

## 4. Yön önerileri

### 4.0 Önce: her yönde aynı kalan taban (Faz 0)

Bu maddeler hangi yön seçilirse seçilsin yapılır. Tek başlarına şikâyetini çözmezler. Klasör turu gösterdi ki yalnız tema değiştiren iş ekranın %6-17'sini oynatıyor ve göze "aynı ekran" gibi geliyor.

- **Yazı merdiveni yukarı çıkar:** en küçük metin 12 px, tablo verisi 14-15 px, gövde 16 px, başlık 22 px ve üstü. Büyük harf yalnız bir iki kelimelik etiketlerde kalır. Not: satır yükseklikleri ve pencere içi yerleşim etkilenir, bu yüzden saf token işi değildir.
- **Veri yazısı IBM Plex Sans olur** (rakamları zaten tabular). Mono veri alanından çıkar. Bu, Set A kararını yeniden açar; Soru 7.
- **Soluk yazı kalkar.** İkincil mürekkep #5E564C (kremde 6,75:1), INK_DIM ve INK_FAINT'in yerini alır.
- **Amber yalnız birincil eylemde kalır.** Yıldızlar, bölüm başlıkları ve rozetler amber olmaktan çıkar.
- **Beceriler yıldız yerine sayı ve renk bandıyla gösterilir.** Soru 5.
- **Satış'ta her kartta en fazla bir birincil düğme olur.**
- **Olay kartında etki çipi seçeneğin en büyük verisi olur;** kazanç ve kayıp ayrı renkte yazar.
- **Dil ihlalleri düzeltilir** (TRAIT, NEUTRAL, Operating Partner, UX/UI DESİGNER, NORDİCA). Metin değişikliği olduğu için TR onayı bekler.
- **Pencereye gerçek bir gölge ve kenara doğru saydamlaşan bir perde eklenir** (F1M24).
- **Build kartı yerinde kalır, yalnız dili pencere diline uyar.** Yerini ya da boyunu değiştirmek ayrı bir karardır ve ekran görüntüsüyle sorulur.

Aşağıdaki dört yön bu tabanın üstüne kurulur. Her yön somut; renk kontrastları hesaplandı (WCAG).

---

### Yön 1: "Oyuncak Ofis" (önerim)

**Çapa:**
- Two Point Campus'un sola yaslı kadro listesi ve alttan yükselen danışman büstü
- Good Company'nin canlı 3B portresi ve "neden" ipucu
- Startup Company ile Mad Games Tycoon 2'nin masa ve oda rozetleri
- Game Dev Tycoon'un masadan sayaca uçan puanları
- Frostpunk 2 ile This Is the Police'in olay kartı
- FM'in sayı bantları

Arayüz 3B ofisin dilinden türer: kalın koyu kontur, yuvarlak köşe, sert gölge, sıcak renk.

- **Yerleşim** (değişir):
  - Tab pencereleri sol kenara yaslanır ve yaklaşık 1000-1100 px genişlikte kalır; ofisin sağdaki yaklaşık %40'ı canlı durur.
  - Kişi ve müşteri kartı sağ kenara yaslanır, < > ile gezilir.
  - Pencere açılınca ofis hafifçe soluklaşır, pencerenin konusu renkli kalır (Ekip'te ekip masaları, Satış'ta toplantı odası).
  - Ofiste masa rozetleri olur: isim, iş, moral ikonu.
- **Üst bar:**
  - Siyah bant kalkar. Yerine ofisin üstünde yüzen, kalın konturlu, yuvarlak köşeli üç krem kapsül gelir (Anno 1800 kapsülleri ve Two Point'in karışımı).
  - Sol kapsül: logo ve şirket adı.
  - Orta kapsül: büyük KASA, altında gri haftalık delta; MRR ve BURN bir boy küçük; RUNWAY süre ve tarih olarak.
  - Sağ kapsül: tarih, dolan hafta çubuğu, hız aleti ve "Sıradaki" satırı; karar bekleyen bir olay varken burası "Cevap bekliyor" olur.
- **Ray:**
  - Sekiz yuva aynı kalır. Ama ikonlar ofis çizgisinde yeniden çizilir: 2 px kontur, iki ton dolgu, yuvarlak uçlar.
  - Etiketler 12 px sans olur, kısayol numarası ve sayılı rozet taşır. Ayrı ayrı kutulanmış karolar kalkar, tek bir ray kapsülü olur.
- **Pencereler:**
  - 2 px mürekkep kontur, 12 px köşe, mürekkebin %25'i opaklıkta 0/6 px sert ofset gölge.
  - Başlık şeridi ana renk petrolde, başlık Rubik ile yazılır, yanında konunun ikonu durur. Altında tek satır amaç cümlesi ve 2-4 eylemlik kontrol şeridi var.
  - İçerik düz krem.
- **Tablolar:**
  - Ekip satırı 56-64 px: 48 px büst render, 15 px isim, rol altta ikincil mürekkeple yazar.
  - Beceriler renk bandında sayı olur. Moral çubuğunda ayrılma eşiği çentiği ve ikon var.
  - Filtre sekmeleri sayılı (Two Point Campus). Kişi kartında "neden" listesi açılır (Software Inc).
  - Satış satırı: şirket logosu, MRR sparkline'ı, koltuk / plan oranı, renkli sağlık kelimesi, tek birincil eylem.
- **Olay modalı** (iki kademe):
  - Karar olmayan Frank anları: alttan yükselen Frank büstü ve konuşma bandı çıkar, sayılar cümle içinde renklenir, oyun durmaz (Two Point, Tennis Manager).
  - Kararlar: dikey kart. Tepede Frank'in 3B sahnesi okunur boyda durur. Sonra serif başlık, kısa metin (alıntı olarak) ve tek kalın satırda bedel gelir. Seçenekler tam genişlik düğmelerdir, bedel düğmenin içinde en büyük veri olarak yazar, altında zaman etkisi yazar. Ofis arkada bulanık durur (Frostpunk 2, This Is the Police).
- **Haber şeridi:** Alt kenarda krem bir kapsül ya da ince koyu bir şerit olabilir (Soru 3'e bağlı). Metin orantılı sans olur, kenar boşluğu bırakılır, her yayın kendi rengindeki başlığıyla yazar.
- **Tipografi:**
  - Rubik (OFL, Türkçe tam, tnum var): başlık, isim, düğme ve üst bar rakamları. Hafif yuvarlak köşeleri ofisin diliyle konuşur. Google'daki dosyası değişken fonttur; ya statik yüzler gömülür ya da Godot'taki INT-tag tuzağına dikkat edilir.
  - IBM Plex Sans: tablo, gövde ve veri.
  - Source Serif 4: Frank ve anlatı.
  - JetBrains Mono çıkar.
- **Renk:**

| Rol | Renk | Kontrast |
|---|---|---|
| Kâğıt (pencere gövdesi) | #FBF7EE | zemin |
| Mürekkep (metin ve 2 px kontur) | #2B2722 | 13,87:1 |
| İkincil mürekkep | #5E564C | 6,75:1 |
| Ana renk petrol: başlık şeridi, aktif ray, seçili | #1E5B63 | üstünde krem 7,19:1 |
| Birincil eylem dolgusu (yalnız bu) | #F2B53A | üstünde mürekkep 8,08:1 |
| Olumlu (şekille) | #2E7D4F | 4,72:1 |
| Olumsuz (şekille) | #B3261E | 6,11:1 |
| Uyarı (şekille) | #9A6700 | 4,55:1 |

  Petrol bilinçli seçildi: ofisin tuğla ve turuncusunun tamamlayıcısı, ofisin cam mavisiyle de akraba. Renk körü paleti bu rollerin üstüne yeniden kurulur.
- **Malzeme:** Doku yok. Malzeme ofisin plastik oyuncak dili: kontur, gölge, yuvarlaklık. Kâğıt ekran başına en fazla bir nesne olur: Finans'ta ay kapanışı fişi, Frank'in çeki.
- **Hareket:**
  - Pencere raydan kayarak gelir (200 ms'den kısa); sekme değişimi anlıktır.
  - Pencere açılınca ofis 250 ms'de soluklaşır.
  - Satış kapanınca ilgili masadan üst bara para yükselir (Game Dev Tycoon).
  - İmza ve kabul anlarında kısa bir ses çalar.
- **Maliyet:** Büyük. Dört ayrı iş var:
  - Tema: font, renk, stylebox.
  - Yerleşim: yaslanan pencere, kişi kartı, üst kapsüller, olay yönlendirmesi.
  - Sanat: yaklaşık 30 ikon ve büst render hattı; oda3d yakalama rig'ine benzer bir düzen zaten var.
  - Ofis kodu: soluklaştırma, masa rozetleri, uçan para.
- **Risk:** "mobil oyun" ya da şişkin görünüm. Startup Company'ye "big and blobby", Game Dev Tycoon'a "Feels like a mobile/online flash game" dendi. Önlem: ferahlık yalnız çerçevede kalır, tablo yoğunluğu FM düzeyinde tutulur.

---

### Yön 2: "Menajer Masası"

**Çapa:**
- FM24'ün yoğunluğu ve "Must Respond" kapısı
- FM27'nin kontrol şeridi ve konu renkli mesajları
- OOTP'nin sayı ve çubuk gösterimi ile CONTINUE alt satırı
- F1 Manager 24'ün 3B sahne önünde koyu vurgu katmanı
- Eastside Hockey Manager'ın nesne renginde başlık bandı

Profesyonel, koyu, yoğun bir yön.

- **Yerleşim** (orta düzeyde değişir):
  - Pencereler koyu olur ve arkalarında F1M24 tipi bir perde bulunur. Boyut ve konum bugünküne yakın kalabilir, ya da pencere sol yarıya yaslanır.
  - Olaylar sekmesi FM tarzı bir gelen kutusu olur: gönderen, konu, konu rengi hapı, zaman, mesaj içinde eylem.
  - Olay modalı yalnız karar için kalır.
- **Üst bar:** Koyu bar kalır ve kimlik taşır: iki kat (akış ve stok), büyük KASA, sağda amber bir zaman bloğu. Blok sıradakini yazar ve gerektiğinde "Cevap bekliyor" kapısına döner.
- **Ray:** FM24 tarzı; etiketli, ikonlu ve sayılı.
- **Pencereler:** Koyu panel, dar büyük harf başlık, tepede kontrol şeridi. Müşteri ve VC pencerelerinde o şirketin kimlik rengi başlık bandına geçer (EHM, FM21).
- **Tablolar:** FM yoğunluğu, yaklaşık 28-32 px satır. Beceriler 1-20 ya da 1-10 sayı olarak renk bandında durur. Rolle ilgili sütun vurgulanır. Ayarlarda Default / Detailed / Condensed yoğunluk kipi olur.
- **Olay modalı:** Koyu kart, solda portre ve sahne, sağda metin (Victoria 3 düzeni). Seçenek düğmelerinde bedel ve zaman etkisi yazar.
- **Haber şeridi:** Koyu kalır. Yayın adları kendi renginde, metin orantılı sans.
- **Tipografi:**
  - Barlow Condensed SemiBold (OFL, Türkçe tam, tnum): büyük harf başlık, gezinme, KPI etiketleri.
  - IBM Plex Sans: gövde ve tablo; dar sütunlarda IBM Plex Sans Condensed.
  - Source Serif 4: yalnız Frank alıntıları.
  - JetBrains Mono çıkar.
- **Renk:**

| Rol | Renk | Kontrast (#1A2128 üstünde) |
|---|---|---|
| Perde (kenara doğru saydamlaşır) | #0B0F13 %70 | |
| Panel / panel 2 / çizgi | #1A2128 / #222B33 / #2E3944 | |
| Metin / ikincil / soluk | #E9E4DA / #A7B0B8 / #8C96A0 | 12,83 / 7,39 / 5,41 |
| Amber: yalnız zaman bloğu ve seçili | #F2B53A | 8,86 (üstünde koyu 9,82) |
| Değer bandı, 5 basamak | #EC6A5E / #E8913A / #B9C0C6 / #9CC45A / #4FD27A | 5,25 / 6,61 / 8,84 / 8,09 / 8,38 |
| Kimlik renkleri (müşteri, VC) | veri, token değil | |

- **Malzeme:** Yok. Karakter portrelerden ve kimlik renklerinden gelir.
- **Hareket:** Az ve hızlı. Sekme değişimi anlık (Big Pharma yavaş geçişler için eleştirildi). Değişen sayı kısa bir sayma animasyonuyla yerine oturur. Kapı açıkken zaman bloğu yavaşça nabız atar.
- **Maliyet:** Orta. Koyu token ailesi (Chrome*) zaten var. İşler: tema, üst bar zaman bloğu, gelen kutusu, kontrol şeridi, tablolar. Sanat ihtiyacı düşük; büstler yine gerekir.
- **Risk:** Motorsport Manager incelemesi bu yönün tuzağını tarif ediyor: "the menu screen looks a lot like commercial business management software rather than a game". Bu yön tek başına "jenerik" şikâyetini çözmez. Üstelik koyu, profesyonel bir arayüz oyuncak ofisin önünde iki ayrı oyun gibi durabilir.

---

### Yön 3: "Sahneli Editoryal"

**Çapa:**
- Victoria 3: süs yalnız çerçevede; olay resim ve metin kartı; küçültme düğmesi.
- CK3: panel konusunun sahnesiyle açılır, bağlama göre değişen arka planlar, mavi kavram ipuçları.
- Against the Storm: tek malzeme çerçevede.
- Frostpunk 1: bina paneli resimli bir başlıkla açılır.
- Anno 1800: kalıcı olan koyu, geçici olan açık.

Bugünkü krem ve serif korunur, Set A fontları değişmez.

- **Yerleşim** (en az değişir): Sabit yuvalar kalır, pencereler biraz daralır (HOI4). Her pencerenin başına 120-160 px'lik bir sahne bandı gelir: ofisten sabit kamerayla alınmış ilgili köşe (Ekip: ekip masaları, Satış: toplantı odası, Finans: kurucu masası). Bandın üstünde koyu bir plaka ve serif başlık durur. Gövde düz krem.
- **Üst bar:** Siyah kalır, Bloomberg gibi sahipli bir terminal kimliği olarak. İki katlı olur (akış ve stok), KASA büyük yazar. Mono yalnız burada ve şeritte kalır, rakamları büyür.
- **Ray:** Plaka renginde tek parça bir sütun olur. İkonlar özel çizilir ya da en azından tek bir çizgi kalınlığına getirilir. Etiketler 12 px sans.
- **Pencereler:** Koyu plaka başlık, ince kazıma çizgili çerçeve, krem gövde, gölge ve perde.
- **Tablolar:** Faz 0 kuralları geçerli. Metinde bir renk grameri kurulur: ipucu taşıyan kavramlar (MRR, churn, runway) mavi, kişi ve şirket adları kiremit, değerler kalın mürekkep, işaret yeşil ya da kırmızı (Victoria 3, CK3). İç içe ipuçları eklenir.
- **Olay modalı:** Victoria 3 düzeni. Plakada başlık ve olayın yeri, solda Frank'in sahnesi okunur boyda, sağda kartta önce soru, sonra alıntı, sonra seçenekler. Bedel düğmede yazar. Küçültme düğmesi var.
- **Haber şeridi:** Siyah kalır. Kenar boşluğu eklenir, yayın başlıkları renklenir, gövde Plex Sans'la yazar.
- **Tipografi:** Set A kalır, roller değişir. Source Serif 4 başlık ve anlatıda (22-44 px), IBM Plex Sans bütün veri ve etiketlerde (cümle düzeninde), JetBrains Mono yalnız üst bar ve şeritte. Font kararı yeniden açılmaz.
- **Renk:**

| Rol | Renk | Kontrast |
|---|---|---|
| Kâğıt / mürekkep / ikincil | #FBF7EE / #2B2722 / #5E564C | 13,87 / 6,75 |
| Plaka (başlık, ray, üst bar ailesi) | #23303A | üstünde krem 12,63:1 |
| Kavram (ipuçlu terim) | #2F5D8A | 6,43:1 |
| Ad (kişi, şirket) | #7A2E1F | 8,78:1 |
| Birincil eylem | #F2B53A | üstünde mürekkep 8,08:1 |

- **Malzeme:** Tek malzeme başlıktaki ofis görüntüsünün kendisi (CK3'ün bağlama duyarlı arka planları gibi) ve plaka kenarındaki ince kazıma çizgisi. Klasör yok, kâğıt dokusu yok.
- **Hareket:** Sahne bandı yumuşak geçişle gelir. İmza anında damga ve ses var.
- **Maliyet:** Orta ile düşük arası. İşler: tema, sahne bandı hattı (ofis kamerasından sabit kareler), olay kartı yerleşimi, ipucu grameri.
- **Risk:** Pencere hâlâ ofisi örtüyor; perde yardım eder ama sorunu çözmez. Görünüm bugünküne en yakın yön olduğu için senin gözünde yeterince farklı durmayabilir.

---

### Yön 4: "Kurucunun Ekranı"

**Çapa:**
- Big Ambitions: yönetim telefondaki ve bilgisayardaki kurgusal uygulamalarla yapılır.
- The Operator: kurgusal işletim sistemi ve kalıcı sohbet sütunu.
- Her Story: bilgisayar kurgusu öğrenme bedeli istemez.
- Bloomberg: siyah üstünde amber tek renkli kimlik.
- Bizde zaten olan telefon daveti ve harita yolculuğu.

- **Yerleşim** (büyük ölçüde değişir):
  - Kabuk kurucunun laptopudur. Üst bar işletim sisteminin menü çubuğuna döner: saat, banka bakiyesi, bildirimler.
  - Ray bir uygulama dock'u olur. Her sekme kendi adı, ikonu ve rengi olan kurgusal bir uygulamadır: Kadro (İK), Boru (CRM), Kasa (banka), Posta (olaylar), Yol Haritası (Ar-Ge).
  - Pencereler başlık çubuklu uygulama pencereleri olur.
  - Frank telefonla arar. Olaylar posta ya da çağrı olarak gelir. Haber şeridi bir haber uygulamasının akışı olur.
- **Tablolar:** Her uygulama inandırıcı bir yazılımı taklit eder ama sade ve yoğun kalır (The Operator'ün zebra satırları).
- **Olay modalı:** Karar anları telefon ya da posta kartı olarak gelir. Büyük anlar (term sheet) tam ekran imza sayfası olur.
- **Tipografi:**
  - Inter (OFL, Türkçe tam, tnum): işletim sistemi arayüzü. Not: Inter değişken fonttur ve Godot'taki INT-tag tuzağı geçerlidir.
  - JetBrains Mono: menü çubuğu ve banka ekranı.
  - Bricolage Grotesque: yalnız kurgusal uygulama logoları.
- **Renk:**

| Rol | Renk | Kontrast |
|---|---|---|
| Menü çubuğu / amber metin | #0B0D10 / #FFB000 | 10,62:1 |
| Uygulama penceresi / metin / ikincil | #F5F6F7 / #1F2328 / #59636E | 14,6 / 5,65 |
| Uygulama kimlik renkleri | yalnız ikon ve başlık çubuğunda | |

- **Malzeme:** Ekranın kendisi; kâğıt yok.
- **Hareket:** Pencereler dock'tan büyüyerek açılır. Bildirimler sağ üstten kayar. Telefon titrer.
- **Maliyet:** Büyük. İşler: uygulama kimlikleri (logo, ikon, renk), pencere kromu, olayların posta ve telefon kanalına taşınması.
- **Risk:** En yüksek riskli yön. Şikâyetin "SaaS paneli gibi" olmasıysa, bu yön bilerek SaaS çiziyor. Ancak her uygulama kendi parodi kimliğini taşırsa ve cihaz çerçevesi görünürse işler. Big Ambitions yorumları da bilginin "buried 4 clicks down" kaldığını söylüyor.

---

### 4.5 Karşılaştırma

| | Yön 1 Oyuncak Ofis | Yön 2 Menajer Masası | Yön 3 Sahneli Editoryal | Yön 4 Kurucunun Ekranı |
|---|---|---|---|---|
| "Jenerik, karaktersiz" şikâyetini çözer mi | Evet: dil ofisten gelir | Kısmen: portre ve renk şart | Kısmen: sahne bandı taşır | Evet, ama SaaS'a yakın |
| Okunurluk ve yoğunluk | İyi (dikkat ister) | En iyi | İyi | İyi |
| Ofisle bağ | En güçlü | Zayıf (koyu önde) | Orta (başlıkta) | Zayıf (ofis arka plan) |
| Yalnız tema mı | Hayır: yerleşim, sanat, ofis kodu | Kısmen: tema, üst bar, gelen kutusu | Çoğu tema; başlık hattı ve olay kartı | Hayır: kabuk baştan |
| Maliyet | Büyük | Orta | Orta ile düşük arası | Büyük |
| En büyük risk | Mobil ve şişkin görünme | "İş yazılımı gibi" | Yeterince farklı olmama | Şikâyeti büyütme |

### 4.6 Önerim ve nedeni

**Yön 1, Yön 2'nin veri kurallarıyla birlikte.** Üç nedenim var:
1. Oyunun tek sahipli varlığı ofis. Türde karakterini dünyasından alan oyunlar övülüyor (Two Point, Frostpunk). Jenerik kaplama taşıyanlar ise oyun sevilse bile incelemede adıyla anılıyor ("demo UI", "gets the job done", "outdated").
2. En yakın tür ve sanat akrabası Two Point Campus, ve kadro listesi bizim Ekip penceremizin birebir karşılığı.
3. Klasör turu ve Tropico 6 aynı şeyi söylüyor: yalnız tema değiştirmek bu şikâyeti çözmüyor.

Dürüst not: **Yön 1 bir tema değil.** Pencere yerleşimi, kişi kartı, olay yönlendirmesi, ikon seti, büst render'ları ve ofis tarafında soluklaştırma ile masa rozetleri gerekiyor. Bu bir tur değil, birkaç turluk iş.

Sanat ve kod bütçesi yoksa yedek yön **Yön 3**. Mevcut fontları ve yuvaları korur, olay kartında ve pencere başlığında gerçek fark yaratır. Ama pencerenin ofisi örtme sorununu çözmez.

Önerdiğim sıra (her adım tek ekran, senin F5'inle kapanır):
1. Faz 0 tabanı.
2. Seçtiğin yönde Ekip penceresi ve Frank'in teklif kartı, önce Claude Design'da gerçek ofis görüntüsünün üstünde 1:1 maket olarak. Stil karosu değil.
3. Onaydan sonra motorda Ekip.
4. Olay kartı.
5. Üst bar.
6. Satış.
7. Ofis katmanı: soluklaştırma, masa rozetleri, uçan para.

---

## 5. Erdem'e sorular

Kısa cevap yeter. Harf ya da numara yazman kâfi.

**S1. Görsel seçki.** Aşağıdakilerden "evet, bu" dediğin üç numarayı ve "asla" dediğin bir numarayı yaz.
1. Two Point Campus, kadro listesi solda, kampüs sağda: https://www.gameuidatabase.com/uploads/Two-Point-Campus-MouseKeyboard04262026-070137-29318.jpg
2. Two Point Hospital HUD'u: https://www.gameuidatabase.com/uploads/TwoPointHospital04252020-100938.jpg
3. F1 Manager 24, 3B üstünde koyu yüzen paneller: https://cdnb.artstation.com/p/assets/images/images/078/489/081/large/aaron-rawlinson-f1m24-cg-01.jpg
4. FM27 kadro tablosu: https://cdn.footballmanager.com/site/2026-09/2-SquadScreen.png
5. OOTP 26: https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/3116890/ss_6abcee8d0289cce167f41c07995fab5f7eda27e1.1920x1080.jpg
6. Frostpunk 2 olay kartı: https://www.gameuidatabase.com/uploads/Frostpunk-209262024-104909-18387.jpg
7. This Is the Police olay kartı: https://www.gameuidatabase.com/uploads/This-Is-the-Police-206082021-101933-16944.jpg
8. Victoria 3 olayı: https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/529340/ee3c20b6e34c83fa3f0784ec890e98214cb1affb/ss_ee3c20b6e34c83fa3f0784ec890e98214cb1affb.1920x1080.jpg
9. Against the Storm, düzeltme sonrası: https://eremitegames.com/wp-content/uploads/2022/04/UI-Improvements-After.jpg
10. Big Ambitions, kurgusal uygulama: https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1331550/4a96de4472260ad97ccb53977d8d3e8c6a56e15a/ss_4a96de4472260ad97ccb53977d8d3e8c6a56e15a.1920x1080.jpg
11. Startup Panic (bizim iskelet): https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1045610/ss_e7449058778a1085a7555913b141a1b46b969262.1920x1080.jpg
12. Tropico 6, kâğıt defter pencere (karşı örnek): https://www.gameuidatabase.com/uploads/Tropico-612222020-070118-97944.jpg

**S2. Pencereler açık mı, koyu mu?** (a) krem kalsın (b) koyu olsun (c) ikisini de maketle göreyim.

**S3. Pencere açıkken ofis ne kadar görünsün?** (a) pencere sol yarıda, sağ yarıda canlı ofis (b) pencere büyük, ofis arkada bulanık (c) bugünkü gibi.

**S4. Frank ekranda karakter olarak görünsün mü?** Karar kartında okunur boyda sahne ve büst, küçük anlarda alttan yükselen büst. (evet / hayır)

**S5. Beceriler:** (a) yıldız kalsın ama büyüsün (b) sayı ve renk bandı.

**S6. Sanat işi:** Lucide yerine ofis çizgisinde yaklaşık 30 ikon ve çalışan büst render'ları için iş ayıralım mı? (evet / şimdilik hayır)

**S7. Font:** 2026-08-03'teki Set A kararını yeniden açmaya razı mısın? Mono veri alanından çıkar; Yön 1'de Rubik, Yön 2'de Barlow Condensed girer. Yön 3 Set A'yı korur. (evet / hayır)

**S8. Olaylar:** Karar olmayan olaylar modal olmaktan çıkıp oyun durmadan gelen mektup, toast ya da şerit olsun, modal yalnız kararlar için kalsın mı? (evet / hayır)

**S9. Pazarlama (YAKINDA)** rayda kalsın mı, yoksa hazır olana kadar gizlensin mi?

---

## 6. Kaynaklar

Görseller ilgili satırın sonunda "G:" ile verildi.

**Football Manager 24 / 23**
- https://community.sports-interactive.com/sigames-manual/football-manager-2024/inbox-and-news-r4956/
- https://realsport101.com/article/football-manager-27-deep-dive-ui-fixes-offer-hope-but-fm-24-shadows-loom
- https://coffeehousefm.com/fmrensieblog/fm24-rensie-custom-skin
- https://www.fmscout.com/c-fm21-skins.html
- https://store.steampowered.com/app/2252570/
- G:
  - https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/2252570/ce6e4238dd12ec17f43ad48882f7a72f8e10cddf/ss_ce6e4238dd12ec17f43ad48882f7a72f8e10cddf.1920x1080.jpg
  - https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/2252570/ss_b2d729b4d4ac31c6f05134ab88b2b11d61f8cac8.1920x1080.jpg
  - https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/2252570/ss_c61172e8694630ce6a22c74aa826341c80975d8d.1920x1080.jpg
  - https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/2252570/8fca1244111d1fde9e7793db2de60e83148a3e61/ss_8fca1244111d1fde9e7793db2de60e83148a3e61.1920x1080.jpg
  - https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1904540/ss_a10d66d39ed53279185fddb6a9d3dd22dbf0606e.1920x1080.jpg
  - https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1904540/ss_48ed70e7d2cceeb71a97d311dc6ee4f7a583b0e1.1920x1080.jpg
  - https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1904540/ss_649336c523b42322daf381cde1083583ad2f481a.1920x1080.jpg

**Football Manager 26**
- https://www.footballmanager.com/fm26/features/fm26s-reimagined-user-interface
- https://www.footballmanager.com/the-dugout/mastering-fm26-ui
- https://www.invenglobal.com/articles/23673/fm26-developer-why-we-had-to-change-the-ui
- https://www.absolutegeeks.com/reviews/football-manager-26-review-a-beautiful-game-trapped-in-an-ugly-interface/
- https://www.operationsports.com/football-manager-26-review-a-brilliant-game-trapped-in-a-clunky-shell/
- https://www.altchar.com/reviews/football-manager-2026-review-a-disappointing-step-backwards-a6QHj3y0USb4
- https://steamcommunity.com/app/3551340/discussions/0/603044859897728127/
- https://steamcommunity.com/app/3551340/discussions/0/670600125430831095/
- https://www.operationsports.com/fm-26-26-1-2-patch-brings-navigation-enhancements-and-stability-fixes/
- https://www.operationsports.com/football-manager-26-is-tracking-as-the-lowest-steam-performer-in-over-a-decade/
- https://www.operationsports.com/development-on-football-manager-26s-ui-was-apparently-outsourced/
- https://www.operationsports.com/sports-interactive-breaks-down-the-football-manager-26-ui-overhaul/
- https://gamerant.com/football-manager-26-steam-reviews-mostly-negative/
- https://www.thickaccent.com/2025/10/24/maze-of-screens-fm26-beta-sparks-backlash-over-controversial-new-ui/
- https://www.galaxus.at/en/page/football-manager-26-is-floundering-in-an-interface-labyrinth-40507
- G:
  - https://cdn.footballmanager.com/site/inline-images/1%20Mitoma_opt.jpg
  - https://cdn.footballmanager.com/site/inline-images/2%20Portal%20Example_opt.jpg
  - https://cdn.footballmanager.com/site/2025-09/UI%20Feature%20-%2016x9%20watermarked_1.jpg
  - https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/3551340/0f9eb2837c5e2dbf514156ebdad8a3c5894ab611/ss_0f9eb2837c5e2dbf514156ebdad8a3c5894ab611.1920x1080.jpg
  - https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/3551340/2e541308b27a73bee6fbed4fdc47eb261c4f0eb1/ss_2e541308b27a73bee6fbed4fdc47eb261c4f0eb1.1920x1080.jpg
  - https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/3551340/005a1c1b6b3c19132f2b00fc28c0665f1b1c38c8/ss_005a1c1b6b3c19132f2b00fc28c0665f1b1c38c8.1920x1080.jpg
  - https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/3551340/52aaa51b9b4519b05dd11234135091638e193ae7/ss_52aaa51b9b4519b05dd11234135091638e193ae7.1920x1080.jpg

**Football Manager 27**
- https://www.footballmanager.com/fm27/features/fm27-clearer-interface-smoother-navigation
- https://community.sports-interactive.com/forums/topic/611878-fm27-uiux-faq/
- https://goosed.ie/news/fm27-rebuilds-the-interface-fm26-broke/
- https://www.thesixthaxis.com/2026/09/22/football-manager-27s-first-deep-dive-video-is-all-about-the-ui-and-navigation/
- G:
  - https://cdn.footballmanager.com/site/2026-09/2-SquadScreen.png
  - https://cdn.footballmanager.com/site/2026-09/4-Messages.png
  - https://cdn.footballmanager.com/site/2026-09/EN_5-1a-TablesHD.png
  - https://cdn.footballmanager.com/site/2026-09/EN_5-2a-Tables4K_0.png
  - https://cdn.footballmanager.com/site/2026-09/3-3-Cards.png
  - https://cdn.footballmanager.com/site/2026-09/6-1-Scaling.png
  - https://cdn.footballmanager.com/site/2026-09/1-1-portal.png
  - https://cdn.footballmanager.com/site/2026-09/1-2-subnav.png
  - https://cdn.footballmanager.com/site/2026-09/8-Bookmarks.png

**Out of the Park Baseball 26 / 27**
- https://digitalchumps.com/out-of-the-park-baseball-26-review-pc/
- https://newbaseballmedia.com/out-of-the-park-baseball-ootp-26-review/
- https://forums.ootpdevelopments.com/showthread.php?p=5279128
- https://wiki.ootpdevelopments.com/index.php?title=OOTP_Baseball%3AScreens_and_Menus%2FFile_Menu%2FSettings
- https://www.sportsgamersonline.com/games/baseball/ootp-27-road-to-release-episode-4-ux-difficulty-settings/
- https://store.steampowered.com/app/3116890/Out_of_the_Park_Baseball_26/
- G:
  - https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/3116890/ss_6abcee8d0289cce167f41c07995fab5f7eda27e1.1920x1080.jpg
  - https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/3116890/ss_2469182ab55bf8c1c31ecef66938dc8a23084785.1920x1080.jpg
  - https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/3116890/ss_4ad1a2365e99974c7821cd8994b3ffa1f7fac4db.1920x1080.jpg
  - https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/3116890/ss_79f7bf887defcad981a0ac10826c6413f08bfd41.1920x1080.jpg
  - https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/4045750/b32cb8827b73fb0c9bd2d4a1ef483e8b7d9c5a09/ss_b32cb8827b73fb0c9bd2d4a1ef483e8b7d9c5a09.1920x1080.jpg

**Motorsport Manager 1 ve 2**
- https://www.digitallydownloaded.net/2016/11/review-motorsport-manager-pc.html
- https://www.cubed3.com/games/reviews/pc/motorsport-manager
- https://www.overtake.gg/threads/motorsport-manager-the-rd-review.128483/
- https://store.steampowered.com/app/415200/Motorsport_Manager/
- https://store.steampowered.com/app/4745600/
- G:
  - https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/415200/ss_49297131e20d1919ecf867710d4c7723e823fde7.1920x1080.jpg
  - https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/415200/ss_cfa613ab902191e4c167aeb5741b38a89d12e626.1920x1080.jpg
  - https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/415200/ss_a18ee0c707fb2b4b3bc4ba13986b38b3ea33f085.1920x1080.jpg
  - https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/415200/ss_f7204b853ff940221f8b34b8e7a487ff252f7a95.1920x1080.jpg
  - https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/4745600/5fb3732b4891dc662e4d88241f7237500fee181a/ss_5fb3732b4891dc662e4d88241f7237500fee181a.1920x1080.jpg
  - https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/4745600/5c205f6e9d162728bad223bc5416dfadc82230b5/ss_5c205f6e9d162728bad223bc5416dfadc82230b5.1920x1080.jpg
  - https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/4745600/4c0c4e61f87ccde0057bf74a997759ef6873692d/ss_4c0c4e61f87ccde0057bf74a997759ef6873692d.1920x1080.jpg

**Eastside Hockey Manager**
- https://gmgames.org/eastside-hockey-manager-ehm-version-1/review/
- https://store.steampowered.com/app/301120/Eastside_Hockey_Manager/
- https://en.wikipedia.org/wiki/Eastside_Hockey_Manager_(video_game)
- G:
  - https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/301120/ss_8765aac9b2406c50eeeaa23d1d14da2c92198e65.1920x1080.jpg
  - https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/301120/ss_86a158974928b74915bfdc11863fb0a42b213182.1920x1080.jpg
  - https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/301120/ss_76a3d1c13f66785980f08b7f43fa6feb4fed5183.1920x1080.jpg
  - https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/301120/ss_c976dc78aaa00f1f89dd317d46f397a964a381d8.1920x1080.jpg
  - https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/301120/ss_5d08bd239fdb1e9958ee23bea49f4b5418e30bc9.1920x1080.jpg

**F1 Manager 24**
- https://www.artstation.com/artwork/XJe96L
- https://www.artstation.com/projects/XJe96L.json
- https://store.steampowered.com/app/2591280/
- https://www.thesixthaxis.com/2024/07/29/f1-manager-24-review/
- https://traxion.gg/f1-manager-24-review-third-times-the-charm/
- G:
  - https://cdnb.artstation.com/p/assets/images/images/078/489/081/large/aaron-rawlinson-f1m24-cg-01.jpg
  - https://cdnb.artstation.com/p/assets/images/images/078/489/087/large/aaron-rawlinson-f1m24-cg-03.jpg
  - https://cdna.artstation.com/p/assets/images/images/078/489/084/large/aaron-rawlinson-f1m24-cg-02.jpg
  - https://cdnb.artstation.com/p/assets/images/images/078/489/091/large/aaron-rawlinson-f1m24-cg-05.jpg
  - https://cdnb.artstation.com/p/assets/images/images/078/489/093/large/aaron-rawlinson-f1m24-cg-06.jpg
  - https://cdnb.artstation.com/p/assets/images/images/078/489/097/large/aaron-rawlinson-f1m24-cg-07.jpg
  - https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/2591280/ss_063927908ddd1ce983e5868774ae2bf9f53995f7.1920x1080.jpg
  - https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/2591280/ss_94927e87a54233b2afee0a82c3dfd819b1661985.1920x1080.jpg

**Tennis Manager 2019**
- https://www.gameuidatabase.com/gameData.php?id=169
- G:
  - https://www.gameuidatabase.com/uploads/Tennis-Manager07162020-072923-67084.jpg
  - https://www.gameuidatabase.com/uploads/Tennis-Manager07162020-072924-1933.jpg
  - https://www.gameuidatabase.com/uploads/Tennis-Manager07162020-072926-46019.jpg
  - https://www.gameuidatabase.com/uploads/Tennis-Manager07162020-073001-47367.jpg
  - https://www.gameuidatabase.com/uploads/Tennis-Manager07162020-073002-76133.jpg
  - https://www.gameuidatabase.com/uploads/Tennis-Manager07162020-073003-36075.jpg
  - https://www.gameuidatabase.com/uploads/Tennis-Manager07162020-072925-65895.jpg

**Offworld Trading Company**
- https://www.rockpapershotgun.com/offworld-trading-company-review
- https://darkzero.co.uk/game-reviews/offworld-trading-company-pc/
- https://www.gamereactor.eu/offworld-trading-company-review/
- https://bestofama.com/amas/4hhdk6
- https://steamcommunity.com/app/271240/discussions/0/1319961868325686534/
- https://steamcommunity.com/profiles/76561197973202743/recommended/271240/
- https://steamcommunity.com/profiles/76561198425289323/recommended/271240/
- G:
  - https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/271240/ss_fdb1d1301e763bd7cdbed153a2e83a2801bbdc67.1920x1080.jpg
  - https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/271240/ss_5aeb9171396080d02276a67b3566400aa08cfd09.1920x1080.jpg

**Rise of Industry**
- https://www.gameuidatabase.com/gameData.php?id=237
- https://steamcommunity.com/profiles/76561198042130595/recommended/671440/
- https://steamcommunity.com/profiles/76561198075188482/recommended/671440/
- https://steamcommunity.com/profiles/76561198086481026/recommended/671440/
- https://steamcommunity.com/profiles/76561198017282938/recommended/671440/
- G:
  - https://www.gameuidatabase.com/uploads/Rise-of-Industry07132020-010411-59760.jpg
  - https://www.gameuidatabase.com/uploads/Rise-of-Industry07132020-010413-3024.jpg
  - https://www.gameuidatabase.com/uploads/Rise-of-Industry07132020-010412-14513.jpg
  - https://www.gameuidatabase.com/uploads/Rise-of-Industry07132020-010320-92206.jpg
  - https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/671440/ss_2b769ca82a50bd798c9b5d67871f32f1a3d6bf2a.1920x1080.jpg

**Industries of Titan**
- https://benui.ca/about/industries-of-titan
- https://www.cbgamedev.com/blog/2022/4/9/quick-dev-insights-03-creating-ui-for-games-ben-humphreys
- https://www.pcgamer.com/industries-of-titan-is-a-promising-foundation-for-a-new-breed-of-city-builder/
- https://www.mentalhealthgaming.com/industries-of-titan-early-access/
- https://www.chalgyr.com/2021/07/review-pc-industriesoftitan.html
- https://steamcommunity.com/profiles/76561198019032959/recommended/427940/
- https://steamcommunity.com/profiles/76561198075086879/recommended/427940/
- G:
  - https://benui.ca/assets/about/titan-1.webp
  - https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/427940/ss_b6c5286bdd657faf9decbb6b1e4e6f1373cc8fcb.1920x1080.jpg
  - https://images.squarespace-cdn.com/content/v1/5c368ddaaa49a1fd962acb3d/4fdb01f2-0541-4892-b09d-f6277c313414/titan-1.jpg

**Big Pharma**
- https://fullyillustrated.com/portfolio/design/big-pharma/
- https://steamcommunity.com/profiles/76561198017779328/recommended/344850/
- https://steamcommunity.com/profiles/76561198069562608/recommended/344850/
- https://steamcommunity.com/profiles/76561197998492446/recommended/344850/
- https://steamcommunity.com/profiles/76561198040359300/recommended/344850/
- G:
  - https://fullyillustrated.com/wp-content/uploads/2017/10/big-pharma-game-ui-design-768x1744.jpg
  - https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/344850/ss_1791627c95df678db6ddd177cbde14954cc88a08.1920x1080.jpg
  - https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/344850/ss_7b8fa51881ab5be9f49316cce90841a9fac20758.1920x1080.jpg
  - https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/344850/ss_09a204bd83991a0eeccc88610946072d84ea1539.1920x1080.jpg

**Production Line**
- https://www.positech.co.uk/cliffsblog/2017/05/09/gui-updates/
- https://www.positech.co.uk/cliffsblog/2017/11/10/designing-a-user-interface-for-variable-screen-size/
- https://www.positech.co.uk/cliffsblog/2017/09/05/production-line-gui-usability-issues/
- https://www.positech.co.uk/cliffsblog/2018/05/25/the-unintuitive-gui/
- https://steamcommunity.com/profiles/76561197989246480/recommended/591370/
- https://steamcommunity.com/profiles/76561198213582201/recommended/591370/
- https://steamcommunity.com/profiles/76561198136935092/recommended/591370/
- G:
  - https://positech.co.uk/cliffsblog/wp-content/uploads/2017/11/1280.png
  - https://www.positech.co.uk/cliffsblog/wp-content/uploads/2017/05/screenshot_09-05-2017_13-41-00.png
  - https://www.positech.co.uk/cliffsblog/wp-content/uploads/2017/05/screenshot_09-05-2017_13-51-55-1.png
  - https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/591370/ss_d5b76e61273697666d040de33442d570a3913cf8.1920x1080.jpg
  - https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/591370/ss_236a09a73373ad5c59a83f886285a12204fcb024.1920x1080.jpg

**Software Inc.**
- https://steamcommunity.com/app/362620/discussions/0/1743355067111562083/
- https://steamcommunity.com/profiles/76561198015312570/recommended/362620/
- https://steamcommunity.com/profiles/76561198142195723/recommended/362620/
- https://steamcommunity.com/profiles/76561198025321447/recommended/362620/
- https://steamcommunity.com/profiles/76561199871946952/recommended/362620/
- https://steamcommunity.com/profiles/76561198010655337/recommended/362620/
- https://steamcommunity.com/profiles/76561197970854203/recommended/362620/
- https://www.indiedb.com/games/software-inc/news/going-full-time
- G:
  - https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/362620/ss_a3008f0189f7ee81f9c9fbf6cb8edccaf42c3223.1920x1080.jpg
  - https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/362620/ss_af63b804af54dcf0edeb90cc1171cf62b88a920f.1920x1080.jpg

**Startup Company**
- https://github.com/hovgaardgames/startupcompany/wiki
- https://steamcommunity.com/profiles/76561197997164615/recommended/606800/
- https://steamcommunity.com/profiles/76561198029900005/recommended/606800/
- https://steamcommunity.com/profiles/76561198074330497/recommended/606800/
- https://steamcommunity.com/profiles/76561198417497190/recommended/606800/
- https://steamcommunity.com/profiles/76561198010478278/recommended/606800/
- G:
  - https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/606800/ss_74de0b0d767febb4e7d11406b38e199884f3d678.1920x1080.jpg
  - https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/606800/ss_60b0b2a8fb13081564c418913f9afbebe78c3562.1920x1080.jpg
  - https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/606800/extras/86db72dd5402fa38a0faa2c2092de36f.webp?t=1727681373
  - https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/606800/extras/3dc952cb3666ed97195b82f857776452.webp?t=1727681373

**Startup Panic**
- https://store.steampowered.com/app/1045610/Startup_Panic/
- https://steamcommunity.com/profiles/76561198052192000/recommended/1045610/
- https://steamcommunity.com/profiles/76561197994308012/recommended/1045610/
- https://steamcommunity.com/profiles/76561198135749530/recommended/1045610/
- https://steamcommunity.com/profiles/76561198114704951/recommended/1045610/
- https://steamcommunity.com/profiles/76561198100412031/recommended/1045610/
- G:
  - https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1045610/ss_e7449058778a1085a7555913b141a1b46b969262.1920x1080.jpg
  - https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1045610/ss_f37d5c47b9721f058a40eed95be82ecac6a7668c.1920x1080.jpg
  - https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1045610/ss_f3caea532faaa095e43ace380ca060d10c29d0b0.1920x1080.jpg

**Game Dev Tycoon**
- https://gamecritics.com/tayo-stalnaker/game-dev-tycoon-review/
- https://www.gamegrin.com/reviews/game-dev-tycoon-review/
- https://github.com/greenheartgames/greenworks
- https://steamcommunity.com/profiles/76561198367471798/recommended/239820/
- https://steamcommunity.com/profiles/76561197999810037/recommended/239820/
- https://steamcommunity.com/profiles/76561199569671624/recommended/239820/
- G:
  - https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/239820/ss_33e784062b2b61901280956b96b72815888cd860.1920x1080.jpg
  - https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/239820/ss_96e6ab31f1bcd3a879bf7f96fe7e660682c31eef.1920x1080.jpg
  - https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/239820/ss_2ede7e75780d8b6b48a42a13008fc6602c8ab5b8.1920x1080.jpg

**Mad Games Tycoon 2**
- https://www.magicgameworld.com/mad-games-tycoon-2-controls-hotkeys/
- https://steamcommunity.com/profiles/76561198038716051/recommended/1342330/
- https://steamcommunity.com/profiles/76561198067424870/recommended/1342330/
- https://steamcommunity.com/profiles/76561198046113626/recommended/1342330/
- https://steamcommunity.com/profiles/76561198094731109/recommended/1342330/
- https://steamcommunity.com/profiles/76561198339275668/recommended/1342330/
- G:
  - https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1342330/ss_cae936ed7a0cef533ce6d471e5289085cce5eb95.1920x1080.jpg
  - https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1342330/ss_7580feaaa02773e8634b9b8059e1eaa785d8eb50.1920x1080.jpg

**Good Company**
- https://www.chasing-carrots.com/goodcompany-changelog-004-way-to-utrecht/
- https://www.escapistmagazine.com/work-doesnt-suck-in-management-sim-good-company/
- https://screenrant.com/good-company-game-review/
- https://steamcommunity.com/profiles/76561198032428599/recommended/911430/
- https://steamcommunity.com/profiles/76561198025321447/recommended/911430/
- G:
  - https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/911430/ss_f010e82143194c77c2640e8675777bef482ac5b2.1920x1080.jpg
  - https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/911430/ss_5f0ecc0111385a639e15ef972c71a696706aea03.1920x1080.jpg

**Capitalism 2 / Capitalism Lab**
- https://www.capitalism2.com/forum/viewtopic.php?t=5784
- https://www.moddb.com/mods/capitalism-lab-dark-mod/addons/caplab-12-dark
- https://steamcommunity.com/profiles/76561197970761123/recommended/638200/
- https://steamcommunity.com/profiles/76561197994966378/recommended/638200/
- https://steamcommunity.com/profiles/76561198029084117/recommended/638200/
- G:
  - https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/638200/ss_1b742d5371c8a628963490deef376336f482ad81.1920x1080.jpg
  - https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/638200/ss_7d8d83de5c8f269aff26cb56f20ffd8d91f73ac0.1920x1080.jpg

**Airline Tycoon Deluxe**
- https://airlinetycoon.fandom.com/wiki/Filofax
- https://airlinetycoon.fandom.com/wiki/Notebook
- https://steamcommunity.com/profiles/76561198004006644/recommended/331920/
- https://steamcommunity.com/profiles/76561197979803586/recommended/331920/
- G:
  - https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/331920/ss_ba08582fd027aae0b7acd6aed962e97681a158aa.1920x1080.jpg
  - https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/331920/ss_de41c04e0359dcb33b3269be95aa888f2a27fe36.1920x1080.jpg
  - https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/331920/ss_c1812c1e8cd40e31882613a54e72b3bde1820602.1920x1080.jpg

**Big Ambitions**
- https://big-ambitions.fandom.com/wiki/BizMan
- https://big-ambitions.fandom.com/wiki/Apps
- https://steamcommunity.com/profiles/76561198022174402/recommended/1331550/
- https://steamcommunity.com/profiles/76561198040736440/recommended/1331550/
- https://steamcommunity.com/profiles/76561197961937605/recommended/1331550/
- https://steamcommunity.com/profiles/76561198002272460/recommended/1331550/
- G:
  - https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1331550/4a96de4472260ad97ccb53977d8d3e8c6a56e15a/ss_4a96de4472260ad97ccb53977d8d3e8c6a56e15a.1920x1080.jpg
  - https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1331550/a6a3b450dc80ccfc72fc660fea745256f327d1d2/ss_a6a3b450dc80ccfc72fc660fea745256f327d1d2.1920x1080.jpg
  - https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1331550/1e6b509b43027c2e991dcd65f46f854b26f5dd3f/ss_1e6b509b43027c2e991dcd65f46f854b26f5dd3f.1920x1080.jpg

**Victoria 3**
- https://forum.paradoxplaza.com/forum/developer-diary/victoria-3-dev-diary-29-user-experience.1506484/
- https://forum.paradoxplaza.com/forum/developer-diary/victoria-3-dev-diary-30-user-interface-overview.1507166/
- https://store.steampowered.com/news/app/529340/view/3118180956264055546
- https://api.steampowered.com/ISteamNews/GetNewsForApp/v2/?appid=529340
- https://www.paradoxinteractive.com/games/victoria-3/news/dev-diary-74-ux-improvements
- https://www.pcgamesn.com/victoria-3/nested-tooltip-system
- https://streamsofconsciousness.blog/2025/02/24/victoria-3-has-the-worst-ui-ive-ever-seen/
- https://store.steampowered.com/app/529340/
- G:
  - https://forumcontent.paradoxplaza.com/public/783323/DD30%201.png
  - https://forumcontent.paradoxplaza.com/public/780905/DD29%2002%20numbers%20v2.png
  - https://forumcontent.paradoxplaza.com/public/780906/DD29%2003%20menu%20tooltip.png
  - https://forumcontent.paradoxplaza.com/public/780907/DD29%2004%20Graph.png
  - https://forumcontent.paradoxplaza.com/public/780912/DD29%2007%20Building%20details.png
  - https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/529340/677898aa35dbc404ac08a23c190f7534c547b80a/ss_677898aa35dbc404ac08a23c190f7534c547b80a.1920x1080.jpg
  - https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/529340/ee3c20b6e34c83fa3f0784ec890e98214cb1affb/ss_ee3c20b6e34c83fa3f0784ec890e98214cb1affb.1920x1080.jpg
  - https://clan.akamai.steamstatic.com/images/40579353/b8da1452f6378490650ddd090fe3639691538c46.png
  - https://clan.akamai.steamstatic.com/images/40579353/6271fed92b1204691b676adde1615182dc878834.png
  - https://clan.akamai.steamstatic.com/images/40579353/5122832498d0b8f95d805ad70bc40da51ce973d4.png
  - https://clan.akamai.steamstatic.com/images/40579353/f2a14e9914a7d189ed3485ecb24188af78de623b.png
  - https://clan.akamai.steamstatic.com/images/40579353/0b5938dbf9175b540e8ddc85b0b9ba7a5cd7c8e2.png
  - https://clan.akamai.steamstatic.com/images/40579353/73e78e5d32ed23b3cf98f8b6a5c74285eb4b4747.png
  - https://clan.akamai.steamstatic.com/images/40579353/5223d4e1a25e6e49adec61975ccc10fdcc336fd6.png

**Frostpunk 1 ve 2**
- https://www.gameuidatabase.com/gameData.php?id=38
- https://www.gameuidatabase.com/gameData.php?id=1965
- https://www.artstation.com/artwork/RKX6Re
- https://www.artstation.com/artwork/BXbKyr
- https://www.pcgamesn.com/frostpunk-2/ui-improvements
- https://gagadget.com/en/494135-intuitive-and-clear-frostpunk-2s-game-director-talked-about-the-main-changes-in-the-interface-and-visual-design-of-the-game/
- https://www.newgamenetwork.com/article/2813/frostpunk-2-review/
- https://www.gamewatcher.com/reviews/frostpunk-2-review/13431
- https://www.gamedeveloper.com/design/the-simple-most-difficult-challenge-of-bringing-frostpunk-to-consoles
- https://steamcommunity.com/app/323190/discussions/0/2999920878451538907/
- https://steamcommunity.com/app/1601580/discussions/0/7845908683579905746
- https://steamcommunity.com/app/1601580/discussions/0/7845908683579627378
- https://store.steampowered.com/app/323190/
- https://gamedesignthinking.com/tag/frostpunk/
- G:
  - https://www.gameuidatabase.com/uploads/Frostpunk-209262024-104909-18387.jpg
  - https://www.gameuidatabase.com/uploads/Frostpunk-209262024-104957-45092.jpg
  - https://www.gameuidatabase.com/uploads/Frostpunk-209262024-104909-43620.jpg
  - https://www.gameuidatabase.com/uploads/Frostpunk-209262024-104909-89990.jpg
  - https://www.gameuidatabase.com/uploads/Frostpunk-209262024-104913-28972.jpg
  - https://www.gameuidatabase.com/uploads/Frostpunk-209262024-105001-73477.jpg
  - https://cdna.artstation.com/p/assets/covers/images/084/143/728/large/wix-polojko-wix-polojko-img-2291.jpg
  - https://www.gameuidatabase.com/uploads/Frostpunk07162020-062408-27161.jpg
  - https://www.gameuidatabase.com/uploads/Frostpunk07162020-062548-37867.jpg
  - https://www.gameuidatabase.com/uploads/Frostpunk07162020-062551-76829.jpg
  - https://www.gameuidatabase.com/uploads/Frostpunk07162020-062411-40871.jpg
  - https://www.gameuidatabase.com/uploads/Frostpunk07162020-062411-32252.jpg
  - https://www.gameuidatabase.com/uploads/Frostpunk07162020-062542-23011.jpg
  - https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/323190/ss_03fc3089daf0785e3bf34b32c385e80defefaeb4.1920x1080.jpg
  - https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/323190/ss_680799fc8f335607924c5703e10eb62780f91d97.1920x1080.jpg
  - https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/323190/ss_5f9c9d5944a98b68b3b57c418f4267a459c757f8.1920x1080.jpg
  - https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/323190/ss_710aea3085400765ce450261ecb405ab1207552c.1920x1080.jpg
  - https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1601580/c6ef7c158fb7021f840c9ef00331265b9a34ecf1/ss_c6ef7c158fb7021f840c9ef00331265b9a34ecf1.1920x1080.jpg
  - https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1601580/5fcef70d6bc626f4c0cfc74826c3a27125bd1376/ss_5fcef70d6bc626f4c0cfc74826c3a27125bd1376.1920x1080.jpg
  - https://interfaceingame.com/wp-content/uploads/frostpunk/frostpunk-book-of-laws.jpg
  - https://interfaceingame.com/wp-content/uploads/frostpunk/frostpunk-heating.jpg

**Crusader Kings III**
- https://forum.paradoxplaza.com/forum/developer-diary/ck3-dev-diary-16-tutorials-and-tooltips-and-encyclopedias-oh-my.1345581/
- https://forum.paradoxplaza.com/forum/threads/ckiii-dev-diary-28-art-focus.1393627/
- https://forum.paradoxplaza.com/forum/developer-diary/ck3-dev-diary-97-event-illustration-showcase-and-workflow.1524206/
- https://ck3.paradoxwikis.com/Event_modding
- https://www.gamedeveloper.com/design/deep-dive-refreshing-the-crusader-kings-iii-tutorial-mode-through-optimized-ux
- https://www.pcgamesn.com/crusader-kings-3/review-ck3
- https://philip.design/blog/tooltips-in-tooltips/
- https://store.steampowered.com/app/1158310/
- G:
  - https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1158310/0ed600e9f23f5fd9eebaa4bc16e883b5fbc12d46/ss_0ed600e9f23f5fd9eebaa4bc16e883b5fbc12d46.1920x1080.jpg
  - https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1158310/927b699bb755884d14c31ccdfc7ffe2211730ca7/ss_927b699bb755884d14c31ccdfc7ffe2211730ca7.1920x1080.jpg
  - https://forumcontent.paradoxplaza.com/public/537566/tooltip_in_tooltip.png
  - https://forumcontent.paradoxplaza.com/public/537570/issues.png
  - https://forumcontent.paradoxplaza.com/public/537575/toasts.gif
  - https://forumcontent.paradoxplaza.com/public/569145/DD28_Character_Screen.png
  - https://forumcontent.paradoxplaza.com/public/569148/DD28_letter.jpg
  - https://forumcontent.paradoxplaza.com/public/569126/DD28_events_01.jpg

**Anno 1800 / Anno 117**
- https://www.anno-union.com/devblog-user-interface-2/
- https://www.anno-union.com/devblog-the-user-interface-team-and-a-deeper-dive-into-the-visuals/
- https://www.gameuidatabase.com/gameData.php?id=1118
- https://steamcommunity.com/app/3274580/discussions/0/604166319349331285/
- https://steamcommunity.com/app/3274580/discussions/0/505068966120582687/
- G:
  - https://www.anno-union.com/wp/wp-content/uploads/2018/06/DevBlog_UI_UX_HUD-1.jpg
  - https://www.gameuidatabase.com/uploads/Anno-180008172021-101846-68526.jpg
  - https://www.gameuidatabase.com/uploads/Anno-180008172021-101846-10131.jpg
  - https://www.gameuidatabase.com/uploads/Anno-180008172021-101847-15561.jpg
  - https://www.gameuidatabase.com/uploads/Anno-180008172021-101843-29830.jpg
  - https://www.anno-union.com/wp/wp-content/uploads/2026/03/Image_9.png
  - https://www.anno-union.com/wp/wp-content/uploads/2026/03/Image_13.png

**Against the Storm**
- https://eremitegames.com/interface-update/
- https://eremitegames.com/devlog-april-2022/
- https://store.steampowered.com/app/1336490/
- G:
  - https://eremitegames.com/wp-content/uploads/2022/04/UI-Improvements-Before.jpg
  - https://eremitegames.com/wp-content/uploads/2022/04/UI-Improvements-After.jpg
  - https://eremitegames.com/wp-content/uploads/2022/04/Smithy-Before.webp
  - https://eremitegames.com/wp-content/uploads/2022/04/Smithy-After.webp
  - https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1336490/ss_c5e7f55444d87f26921736f2d228c092f4dda5f2.1920x1080.jpg

**Europa Universalis V / IV**
- https://forum.paradoxplaza.com/forum/developer-diary/tinto-talks-77-20th-of-august-2025.1856053/
- https://forum.paradoxplaza.com/forum/developer-diary/tinto-talks-76-13th-of-august-2025.1855048/
- https://steamcommunity.com/app/3450310/discussions/0/667222425710107354/
- https://store.steampowered.com/app/3450310/
- G:
  - https://forumcontent.paradoxplaza.com/public/1339294/country_list.png
  - https://forumcontent.paradoxplaza.com/public/1344486/tooltip_conditions.png
  - https://forumcontent.paradoxplaza.com/public/1344484/tooltip_table.png
  - https://forumcontent.paradoxplaza.com/public/1339296/battle_1.png
  - https://forumcontent.paradoxplaza.com/public/1344497/hints.png
  - https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/3450310/6959abf137586597c9b7843111a26ba13aa86665/ss_6959abf137586597c9b7843111a26ba13aa86665.1920x1080.jpg
  - https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/236850/ss_5f121c7e811451deee1fa15b3fcfd95ea072f6b2.1920x1080.jpg

**Hearts of Iron IV**
- https://thearmoredpatrol.com/2016/04/22/hearts-of-iron-iv-development-diary-53-2d-art/
- https://store.steampowered.com/app/394360/
- G:
  - https://i.imgur.com/LmoT5Sf.jpg
  - https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/394360/ss_679ae0d56f3a3b33591262839588c4b1dc6bef12.1920x1080.jpg

**Stellaris**
- https://steamstore-a.akamaihd.net/news/externalpost/steam_community_announcements/1830797770232806
- https://store.steampowered.com/app/281990/
- G:
  - https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/281990/ss_ee82888c27afb4174cf4cae6298b54c7c1e2a682.1920x1080.jpg
  - https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/281990/ss_f844372cc220e3858aa17205e9fec0ae79a4e665.1920x1080.jpg

**Old World**
- https://www.ancientworldmagazine.com/reviews/old-world-2021/
- https://store.steampowered.com/app/597180/
- G:
  - https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/597180/ss_beac7b76f069fa349b4c0821923467fe7b7af04c.1920x1080.jpg
  - https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/597180/ss_0575d38f40f4f991a9c3946b9fbf56d5865bfb2f.1920x1080.jpg

**Terra Invicta**
- https://turnbasedlovers.com/review/terra-invicta-1-0-impressions/
- https://store.steampowered.com/app/1176470/
- G:
  - https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1176470/2fc05e2ce502d85a0bb46acf260896b24cd5ae7e/ss_2fc05e2ce502d85a0bb46acf260896b24cd5ae7e.1920x1080.jpg

**Humankind**
- https://www.gameuidatabase.com/gameData.php?id=1154
- https://community.amplitude-studios.com/amplitude-studios/humankind/forums/169-game-design/threads/43919-my-biggest-gripe-is-the-ui
- https://culturedvultures.com/humankind-pc-review/
- G:
  - https://www.gameuidatabase.com/uploads/Humankind08292021-083721-22032.jpg
  - https://www.gameuidatabase.com/uploads/Humankind08292021-083719-68013.jpg
  - https://www.gameuidatabase.com/uploads/Humankind11212021-124347-65155.jpg

**Papers, Please**
- https://dukope.com/devlogs/papers-please/mobile/
- https://dukope.com/devlogs/papers-please/tig-00/
- https://fguillen.github.io/PapersPleaseDevlogScrap/
- https://x.com/dukope/status/543010159727886336
- https://medium.com/@sam.cuevasp/papers-please-ux-review-672a151969e
- https://store.steampowered.com/app/239030/
- G:
  - https://3909.co/dev/pp/img/Mobile-RegionsDesktop.png
  - https://3909.co/dev/pp/img/Mobile-NoDesk.png
  - https://3909.co/dev/pp/img/Mobile-InspectDesktop.gif
  - https://3909.co/dev/pp/img/Mobile-StampDesktop.gif
  - https://i.imgur.com/xmeNqBR.png
  - https://i.imgur.com/BhXlv19.png
  - https://i.imgur.com/6OTH0NO.png
  - https://i.imgur.com/vqdTc.png
  - https://i.imgur.com/33vofyF.png
  - http://eigen.pri.ee/images/paperspleaselayout.png
  - https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/239030/ss_d24155eecb65aaff7367b791bc7d4910fe59b303.1920x1080.jpg
  - https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/239030/ss_958285f31774906eb4def9d98a83e7926ceb3be2.1920x1080.jpg
  - https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/239030/ss_6c095a8ff86f9ebf8f796d23b1186c176fd21991.1920x1080.jpg
  - https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/239030/ss_4cd77e3ef5b147b011a5cf8f96b8bcbcd79b3e15.1920x1080.jpg

**Suzerain**
- https://store.steampowered.com/news/app/1207650/view/509578043853897957
- https://steamcommunity.com/app/1207650/discussions/0/3806156528939612945/
- https://www.jumpdashroll.com/article/suzerain-review
- https://en.wikipedia.org/wiki/Suzerain_(video_game)
- G:
  - https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1207650/70f4f58cd7814f4acf6e6bcf9839d3bc9720d99f/ss_70f4f58cd7814f4acf6e6bcf9839d3bc9720d99f.1920x1080.jpg
  - https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1207650/6b0128309ffeca8ce112990b35e0e1300e9fa7fe/ss_6b0128309ffeca8ce112990b35e0e1300e9fa7fe.1920x1080.jpg
  - https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1207650/407b096728a93c3afc66cf0ae152c1c9f6ab71ea/ss_407b096728a93c3afc66cf0ae152c1c9f6ab71ea.1920x1080.jpg
  - https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1207650/c854b48f451cc3500db00d0f524aedfb6bb14f30/ss_c854b48f451cc3500db00d0f524aedfb6bb14f30.1920x1080.jpg
  - https://clan.steamstatic.com/images/36373165/68bae565b4f516dfbb6950dc9cf56bd8c0076e35.png
  - https://clan.steamstatic.com/images/36373165/bac56ae5244f3e49673c0b43c3ff9aa7c34bd58d.jpg
  - https://clan.steamstatic.com/images/36373165/3abe93b85eb62196d4a599afa4938278d6dde0b0.jpg

**This Is the Police**
- https://www.gamepressure.com/thisisthepolice/interface/z19080
- https://www.gamepressure.com/editorials/reviews/this-is-the-police-review-game-about-police-weve-all-been-waiting/zad6
- https://www.gameuidatabase.com/gameData.php?id=852
- https://store.steampowered.com/app/443810/
- G:
  - https://www.gameuidatabase.com/uploads/This-Is-the-Police-206082021-101933-16944.jpg
  - https://www.gameuidatabase.com/uploads/This-Is-the-Police-206082021-101933-1333.jpg
  - https://www.gameuidatabase.com/uploads/This-Is-the-Police-206082021-101930-99950.jpg
  - https://www.gameuidatabase.com/uploads/This-Is-the-Police-206082021-101930-88650.jpg
  - https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/443810/ss_0df495f2580422586d682e3dc7cf9d9942bfa604.1920x1080.jpg
  - https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/443810/ss_ebc9d4cde411471d6f5074da9ca7952e2a6d07b6.1920x1080.jpg

**Cultist Simulator / Book of Hours**
- https://weatherfactory.biz/cultist-simulator-the-renewal-of-skin/
- https://weatherfactory.biz/cultist-simulator-the-retrospective/
- https://steamcommunity.com/app/718670/discussions/0/2521353993650229382/
- https://steamcommunity.com/app/718670/discussions/0/1697174779863329076/
- https://steamcommunity.com/app/1028310/discussions/0/3819669605967423995/
- https://www.the-gamers-lounge.com/sam-reader/2023/8/15/book-of-hours-review
- G:
  - https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/718670/ss_5206dd7f298f61caac7ef81018ae05c32060b242.1920x1080.jpg
  - https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/718670/ss_5c76c30252dc7d4ee71e7fafdab20933ff46f45c.1920x1080.jpg
  - https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1028310/ss_bc1d3a08eb54377ae3e78bae6d64efb9ff91b166.1920x1080.jpg
  - https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1028310/ss_0178a24cf186fc78c2bf8917564118bbf3e8e49a.1920x1080.jpg

**Disco Elysium**
- https://gamermatters.com/disco-elysiums-text-box-design-is-inspired-by-how-we-use-computers-and-twitter/
- https://80.lv/articles/disco-elysium-working-on-ui-design
- https://discoelysium.wiki.gg/wiki/Graphic_Assets
- https://www.gameuidatabase.com/gameData.php?id=374
- https://www.gamepressure.com/disco-elysium/user-interface/z5e3e8
- G:
  - https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/632470/ss_9125a718ee9ba85386ae5d4eb820f3266073fc97.1920x1080.jpg
  - https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/632470/ss_fc6969799ebf19fd2a2c8a986c9419e053606a17.1920x1080.jpg
  - https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/632470/ss_ab38615b3a1d0d4309f06772db4bd9db5c250ef7.1920x1080.jpg
  - https://www.gameuidatabase.com/uploads/Disco-Elysium12152020-102227-95845.jpg

**Return of the Obra Dinn**
- https://www.gameuidatabase.com/gameData.php?id=1460
- https://www.pointnthink.fr/en/the-art-of-return-of-the-obra-dinn/
- https://simonwillison.net/2017/Nov/23/return-of-the-obra-dinn/
- G:
  - https://www.gameuidatabase.com/uploads/Return-of-the-Obra-Dinn06202022-112301-78839.jpg
  - https://www.gameuidatabase.com/uploads/Return-of-the-Obra-Dinn06202022-112301-36261.jpg
  - https://www.gameuidatabase.com/uploads/Return-of-the-Obra-Dinn06202022-112301-97184.jpg
  - https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/653530/ss_7dd3476ace2170e134141e487f9491d4c9d094f3.1920x1080.jpg

**Her Story**
- https://www.bfi.org.uk/features/her-story-10-years
- https://kinglink-reviews.com/2020/09/01/her-story-design-review-revisiting-one-of-the-best-video-game-stories-of-all-time/
- https://store.steampowered.com/app/368370/
- G:
  - https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/368370/ss_47f0e58df778d9f10b3df40ddce8bba8e592b1fb.1920x1080.jpg
  - https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/368370/ss_9a5538329a233de7c86e14e331c3894a942b1693.1920x1080.jpg

**Orwell**
- https://www.gamedeveloper.com/design/game-design-deep-dive-decisions-that-matter-in-i-orwell-i-
- https://saveorquit.com/2017/03/29/review-orwell/
- https://www.gameuidatabase.com/gameData.php?id=473
- G:
  - https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/491950/ss_925264c65c464caeba82404bb99369a1f2655b77.1920x1080.jpg
  - https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/491950/ss_41885155e4509b08fc9f1d958c8d8818d296c29f.1920x1080.jpg
  - https://www.gameuidatabase.com/uploads/Orwell01022021-030516-21682.jpg

**Shadows of Doubt**
- http://web.archive.org/web/20260321022150/https://colepowered.com/shadows-of-doubt-devblog-4-case-folders-cork-boards/
- https://colepowered.itch.io/shadows/devlog/113594/shadows-of-doubt-devblog-19-designing-a-detective-toolkit
- https://store.steampowered.com/app/986130/
- G:
  - https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/986130/ss_6e8b247fbef7b2be4d87b4a7ef9d6bae191e39f8.1920x1080.jpg
  - http://web.archive.org/web/20260321022150im_/https://colepowered.com/wp-content/uploads/2018/06/corkboard.jpg
  - http://web.archive.org/web/20260321022150im_/https://colepowered.com/wp-content/uploads/2018/06/early_ui_screenshot.jpg

**The Operator**
- https://www.gamedeveloper.com/design/the-operator-is-a-crime-solving-game-delivered-entirely-with-ui
- https://adventuregamehotspot.com/review/4290/the-operator
- https://store.steampowered.com/app/1771980/
- G:
  - https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1771980/ss_152c464d71afa7bf2a0546cab74008d0e91b20c8.1920x1080.jpg
  - https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1771980/ss_b6af536af205fdcbb0a79172bacd7e22c38326a7.1920x1080.jpg
  - https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1771980/ss_5f9f8137d263ed2142a81c055aa785a08695e4cf.1920x1080.jpg

**Duskers**
- https://www.gamedeveloper.com/design/road-to-the-igf-misfits-attic-s-i-duskers-i-
- https://www.youtube.com/watch?v=kzQDVtysXjA (izlenmedi)
- G:
  - https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/254320/ss_fd7b606082fc64b9ac575635204a7ee5307cac72.1920x1080.jpg
  - https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/254320/ss_92a46c245f5d38e5ac654d50c6deff0153d2d0da.1920x1080.jpg

**Beholder**
- https://gamecritics.com/mike-suskie/beholder-review/
- https://www.geeksundergrace.com/gaming/review-beholder-pc-ios-android/
- https://store.steampowered.com/app/475550/
- G:
  - https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/475550/ss_53853f482ebca579986bfa8a33e15d551feeec56.1920x1080.jpg
  - https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/475550/ss_f4132e073a69be519c14c4286681b03eba90f251.1920x1080.jpg

**Not Tonight**
- https://kinglink-reviews.com/2023/02/04/not-tonight-review-probably-not-any-night/
- https://www.trustedreviews.com/reviews/not-tonight
- https://forum.quartertothree.com/t/not-tonight-a-papers-please-alike/136940
- G:
  - https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/733790/ss_b4368d78dd2c22c0ff6bffb1266cea17580c945e.1920x1080.jpg
  - https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/733790/ss_e2619521be0b85f8375713d4a5f011cb16aac000.1920x1080.jpg

**Headliner: NoviNews**
- https://fingerguns.net/reviews/2019/09/16/headliner-novinews-switch-review-fake-news-of-the-world/
- https://store.steampowered.com/app/918820/
- G:
  - https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/918820/ss_7718dfb7afc0e6544104985a8fecfb89083e66f0.1920x1080.jpg
  - https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/918820/ss_e3c9fbfd1b00de17b97d2c89f8e230854987d321.1920x1080.jpg

**Unpacking**
- https://www.gameuidatabase.com/gameData.php?id=1219
- G:
  - https://www.gameuidatabase.com/uploads/Unpacking11072021-123400-2909.jpg
  - https://www.gameuidatabase.com/uploads/Unpacking11072021-123400-92132.jpg
  - https://www.gameuidatabase.com/uploads/Unpacking11072021-123401-9650.jpg

**Hitman (IOI) ve Blood Money**
- https://fontsinuse.com/uses/64463/hitman-world-of-assassination-video-game
- https://www.gameuidatabase.com/gameData.php?id=688
- https://hitman.fandom.com/wiki/Newspaper
- https://en.wikipedia.org/wiki/Hitman:_Blood_Money
- G:
  - https://www.gameuidatabase.com/uploads/Hitman-303302021-115406-80108.jpg
  - https://www.gameuidatabase.com/uploads/Hitman-303302021-115359-10392.jpg
  - https://www.gameuidatabase.com/uploads/Hitman-303302021-115406-29129.jpg

**Two Point Hospital / Campus / Museum**
- https://www.gameuidatabase.com/gameData.php?id=99
- https://www.gameuidatabase.com/gameData.php?id=2390
- https://www.gameuidatabase.com/gameData.php?id=1508
- https://gamingbolt.com/two-point-museum-review-carefully-curated-oddity
- https://community.twopointcounty.com/two-point-studios/two-point-museum/forums/13-two-point-museum/threads/2532-controller-ui-suggestion-for-two-point
- https://en.wikipedia.org/wiki/Two_Point_Hospital
- https://hardcoregamer.com/features/interviews/mark-smart-discusses-bringing-quirky-hospitals-to-life-in-two-point-hospital/306412/
- https://www.pcgamesn.com/two-point-hospital/two-point-hospital-review
- G:
  - https://www.gameuidatabase.com/uploads/TwoPointHospital04252020-100938.jpg
  - https://www.gameuidatabase.com/uploads/TwoPointHospital04252020-105012.jpg
  - https://www.gameuidatabase.com/uploads/TwoPointHospital04252020-104138.jpg
  - https://www.gameuidatabase.com/uploads/TwoPointHospital04252020-104044.jpg
  - https://www.gameuidatabase.com/uploads/Two-Point-Campus-MouseKeyboard04262026-070137-29318.jpg
  - https://www.gameuidatabase.com/uploads/Two-Point-Campus-MouseKeyboard04262026-070140-3338.jpg
  - https://www.gameuidatabase.com/uploads/Two-Point-Campus-MouseKeyboard04262026-070031-27094.jpg
  - https://www.gameuidatabase.com/uploads/Two-Point-Campus-MouseKeyboard04262026-070305-8369.jpg
  - https://www.gameuidatabase.com/uploads/Two-Point-Campus-MouseKeyboard04262026-070206-77449.jpg
  - https://www.gameuidatabase.com/uploads/Two-Point-Campus09052022-113655-34058.jpg
  - https://www.pcgamesn.com/wp-content/uploads/2018/08/two-point-hospital-office-900x507.png
  - https://www.pcgamesn.com/wp-content/uploads/2018/08/two-point-hospital-interior-900x507.png

**Planet Coaster / Planet Zoo / Planet Coaster 2**
- https://www.gameuidatabase.com/gameData.php?id=527
- https://www.gameuidatabase.com/gameData.php?id=1025
- https://cogconnected.com/review/planet-coaster-2-review/
- https://gamingbolt.com/planet-coaster-2-ps5-review-all-down-hill
- https://steamdeckhq.com/game-reviews/planet-coaster-2/
- G:
  - https://www.gameuidatabase.com/uploads/Planet-Zoo11162021-123847-52486.jpg
  - https://www.gameuidatabase.com/uploads/Planet-Zoo11162021-123850-90844.jpg
  - https://www.gameuidatabase.com/uploads/Planet-Zoo11162021-123851-84407.jpg
  - https://www.gameuidatabase.com/uploads/Planet-Zoo11162021-123848-72904.jpg
  - https://www.gameuidatabase.com/uploads/Planet-Coaster01192021-114427-62504.jpg
  - https://www.gameuidatabase.com/uploads/Planet-Coaster01192021-114425-73862.jpg

**Cities: Skylines II**
- https://www.paradoxinteractive.com/games/cities-skylines-ii/news/upcoming-visual-updates
- https://www.paradoxinteractive.com/games/cities-skylines-ii/news/patch-notes-spring-cleaning
- https://vortexgaming.io/en/postdetail/656874
- https://techradar.com/gaming/consoles-pc/cities-skylines-2-review-road-to-success
- https://steamcommunity.com/app/949230/discussions/0/3877095833474934234
- https://steamcommunity.com/app/949230/discussions/0/3951406499785657461
- https://www.pcgamesn.com/cities-skylines-2/ui-menu-mod
- G:
  - https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/949230/c2092a2047a684f24faaaa47e58dc1dc1d3a57e6/ss_c2092a2047a684f24faaaa47e58dc1dc1d3a57e6.1920x1080.jpg
  - https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/949230/b90d72e3259a6e8b91aac61e1fa9dc948f97dce5/ss_b90d72e3259a6e8b91aac61e1fa9dc948f97dce5.1920x1080.jpg
  - https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/949230/59be27be2d94f0078b3e5e234011894ecee21357/ss_59be27be2d94f0078b3e5e234011894ecee21357.1920x1080.jpg
  - https://images.ctfassets.net/u73tyf0fa8v1/7vYLHnC7GCCdiV8jR3Tdqy/bd4af669f308fb19edfa2ea6ef3db068/Copy_of_Screenshot_2026-01-26_152525.webp
  - https://images.ctfassets.net/u73tyf0fa8v1/5ctqIJtjSvlhR0tYGbuC1T/e746238da6b9a8211fd0cedb0cc2c512/image4.webp

**RimWorld**
- https://rimworldwiki.com/wiki/User_interface
- https://rimworldwiki.com/wiki/Events
- https://steamcommunity.com/app/294100/discussions/0/3776868956630965500
- https://steamcommunity.com/app/294100/discussions/0/600779497610937366
- G:
  - https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/294100/80e383ef19353058791efe17a6485849246c9c17/ss_80e383ef19353058791efe17a6485849246c9c17.1920x1080.jpg
  - https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/294100/698ad21bff61006f31650270446d68cd1073c770/ss_698ad21bff61006f31650270446d68cd1073c770.1920x1080.jpg

**Project Hospital**
- https://www.gamedeveloper.com/design/making-i-project-hospital-i-a-realistic-approach-to-medical-simulation
- https://culturedvultures.com/project-hospital-pc-review/
- https://store.steampowered.com/app/868360/
- G:
  - https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/868360/ss_53d51fa45df80cfe7b1549c95355961979554b3b.1920x1080.jpg
  - https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/868360/ss_75b393df8c9b9251053bd90cee942a06ac934c83.1920x1080.jpg
  - https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/868360/ss_98a32e570a0e46558e4420b62a7bc3760dd29c1b.1920x1080.jpg

**Tropico 6**
- https://www.gameuidatabase.com/gameData.php?id=408
- https://wccftech.com/review/tropico-6-review/
- https://www.techspot.com/products/pc-games/tropico-6.200921/
- https://steamcommunity.com/app/492720/discussions/0/1771511442688137150/
- https://www.thumbsticks.com/tropico-6-ps4-review/
- G:
  - https://www.gameuidatabase.com/uploads/Tropico-612222020-070118-97944.jpg
  - https://www.gameuidatabase.com/uploads/Tropico-612222020-070114-95196.jpg
  - https://www.gameuidatabase.com/uploads/Tropico-612222020-070121-91014.jpg

**Manor Lords**
- https://steamcommunity.com/app/1363080/discussions/0/598539452432936012/
- https://steamcommunity.com/app/1363080/discussions/3/603036300513291591/
- https://steamcommunity.com/app/1363080/discussions/0/6513974610100080525/
- https://api.steampowered.com/ISteamNews/GetNewsForApp/v2/?appid=1363080&count=60&maxlength=0&feeds=steam_community_announcements
- https://www.pcgamesn.com/manor-lords/update-anniversary
- G:
  - https://clan.akamai.steamstatic.com/images/38221882/b5d8c80c3dd6deb66a2bffb3c2a60017d6dd536f.png

**Dwarf Fortress (Steam)**
- https://www.pcgamer.com/dwarf-fortress-review/
- https://www.pcgamesn.com/dwarf-fortress/menus
- https://www.pcgamer.com/the-new-dwarf-fortress-ui-looks-so-much-better/
- G:
  - https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/975370/539fd25e713be0c3f995b71256971d774934c41c/ss_539fd25e713be0c3f995b71256971d774934c41c.1920x1080.jpg
  - https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/975370/ss_f8aa4e5f896a8ecb7abf3a8c7c4ae176ba40f3ae.1920x1080.jpg

**SimCity (2013)**
- http://www.jasonhalvorson.com/simcity
- https://www.gdcvault.com/play/1022054/How-to-Implement-AAA-Game
- G:
  - https://images.squarespace-cdn.com/content/v1/55219337e4b0adb6986dc469/1434910445298-J2APFQA43CI7MDPTFMH7/Data05.png
  - https://images.squarespace-cdn.com/content/v1/55219337e4b0adb6986dc469/1434910518409-93ROMF0PYEU043X4M7QI/UI08.png
  - https://images.squarespace-cdn.com/content/v1/55219337e4b0adb6986dc469/1434910441746-8GEL4AQVKTD04NLFPY61/Data04.png

**Parkitect**
- https://themeparkitect.tumblr.com/post/157367279687/devlog-update-134
- https://steamcommunity.com/sharedfiles/filedetails/?id=2374206320
- G:
  - https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/453090/ss_3c7525c7155726de6a1406dc1732b6de66723f1b.1920x1080.jpg
  - https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/453090/ss_8c29e773f840994280aa53eb56782483d8ec1ed7.1920x1080.jpg

**Prison Architect**
- http://ryansumo.blogspot.com/2012/01/on-introversion-and-prison-architect.html
- https://forums.introversion.co.uk/viewtopic.php?t=59981
- https://www.gameuidatabase.com/gameData.php?id=603
- G:
  - https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/233450/ss_8fd05248e9f657baea9f26d2dbd154573c29b33e.1920x1080.jpg
  - https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/233450/ss_bc52fdefa87f4dd54f2e0c4268ebf6d3d859d682.1920x1080.jpg
  - https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/233450/ss_e2192114d3722f729b54caf5ca94b9d07ebf7bd8.1920x1080.jpg

**Into the Breach**
- https://www.gamedeveloper.com/design/-i-into-the-breach-i-dev-on-ui-design-sacrifice-cool-ideas-for-the-sake-of-clarity-every-time-
- https://www.gdcvault.com/play/1025772/-Into-the-Breach-Design
- G:
  - https://interfaceingame.com/wp-content/uploads/into-the-breach/into-the-breach-combat.png
  - https://interfaceingame.com/wp-content/uploads/into-the-breach/into-the-breach-enemy-turn.png
  - https://interfaceingame.com/wp-content/uploads/into-the-breach/into-the-breach-head-office.png

**Persona 5**
- https://personacentral.com/persona-5-panel-concept-development-ui/
- https://80.lv/articles/game-ui-database-collecting-references-to-inspire-designers
- G:
  - https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1687950/ss_663171dc3afce8fe987e57e8659f91b69faa39bc.1920x1080.jpg
  - https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1687950/ss_a3258aba84ae2f2ff13a02a160f7495bfc152adb.1920x1080.jpg

**Hearthstone**
- https://gdcvault.com/play/1022036/Hearthstone-How-to-Create-an
- https://www.gamedeveloper.com/design/video-designing-an-immersive-user-interface-for-i-hearthstone-i-
- https://medium.com/@matt.tsui/hearthstone-design-thinking-inside-the-box-78dbacb96040
- https://finalbossblues.com/on-hearthstones-ui/
- G:
  - https://interfaceingame.com/wp-content/uploads/hearthstone-heroes-of-warcraft/hearthstone-heroes-of-warcraft-main-menu.jpg
  - https://interfaceingame.com/wp-content/uploads/hearthstone-heroes-of-warcraft/hearthstone-heroes-of-warcraft-my-decks.jpg

**Erişilebilirlik ve tipografi**
- https://learn.microsoft.com/en-us/xbox/accessibility/xbox-accessibility-guidelines/101
- https://learn.microsoft.com/en-us/gaming/accessibility/xbox-accessibility-guidelines/102
- https://clkoerner.com/2019/08/02/small-type-in-a-big-game/
- https://practicaltypography.com/alternate-figures.html
- https://practicaltypography.com/grids-of-numbers.html
- https://practicaltypography.com/tables.html
- https://practicaltypography.com/monospaced-fonts.html
- https://practicaltypography.com/all-caps.html
- https://docs.godotengine.org/en/stable/tutorials/ui/gui_using_fonts.html
- https://docs.godotengine.org/en/stable/classes/class_fontvariation.html
- Font lisansları (OFL):
  - https://raw.githubusercontent.com/google/fonts/main/ofl/rubik/OFL.txt
  - https://raw.githubusercontent.com/google/fonts/main/ofl/barlowcondensed/OFL.txt
  - https://raw.githubusercontent.com/google/fonts/main/ofl/ibmplexsanscondensed/OFL.txt
  - https://raw.githubusercontent.com/google/fonts/main/ofl/inter/OFL.txt
  - https://raw.githubusercontent.com/google/fonts/main/ofl/bricolagegrotesque/OFL.txt

**Tasarım ilkeleri, süreç ve renk sistemleri**
- https://medium.com/refactoring-ui/7-practical-tips-for-cheating-at-design-40c736799886
- https://celiahodent.com/video-game-ux-psychology/
- https://medium.com/design-bootcamp/finding-a-framework-for-ux-in-gaming-key-takeaways-for-understanding-usability-in-celia-hodents-9c0fcfee85f7
- https://gdcvault.com/play/1025340/Immersing-a-Creative-World-into
- https://www.gamedeveloper.com/design/video-designing-great-ui-that-helps-immerse-players-in-your-game
- https://www.linkedin.com/pulse/creating-functional-ui-embodies-your-games-world-steph-chow
- https://odr.chalmers.se/server/api/core/bitstreams/fd267f70-c295-4eae-ae01-af5db676e61d/content
- https://www.researchgate.net/publication/277202228_Beyond_the_HUD_-_User_Interfaces_for_Increased_Player_Immersion_in_FPS_Games
- https://www.edwardtufte.com/notebook/sparkline-theory-and-practice-edward-tufte/
- https://stripe.com/blog/accessible-color-systems
- https://www.radix-ui.com/colors/docs/palette-composition/understanding-the-scale
- https://carbondesignsystem.com/components/data-table/style/
- https://linear.app/now/how-we-redesigned-the-linear-ui
- https://linear.app/now/behind-the-latest-design-refresh
- https://linear.app/changelog/2026-03-12-ui-refresh
- https://www.gamedeveloper.com/design/ui-strategy-game-design-dos-and-don-ts
- G:
  - https://images.stripeassets.com/fzn2n1nzq965/3ZPP6fI931onmKlwC7w373/c3a945f27ab6743d2fa2ca0563822729/uniform-contrast-values-text.png
  - https://images.stripeassets.com/fzn2n1nzq965/6adtkO2ouMiAMZRjBusR2C/5d6f76d0a5f8dac0a908bff95d7e63bc/badges.png
  - https://images.stripeassets.com/fzn2n1nzq965/5dAcbhS0qlqMFJdjyxbj6k/4fa90be503e5ae8adb0607491772a0fd/perceptually-uniform-color-space.png
  - https://webassets.linear.app/images/ornj730p/production/23839a6bacba4a7617728dada3d37a40dc3584aa-2352x1380.png

**Bloomberg Terminal**
- https://digitalcontentnext.org/blog/2017/05/15/bloombergs-customer-centric-design-ethos/
- https://ted-merz.com/2021/06/26/amber-on-black/
- https://uxmag.com/articles/the-impossible-bloomberg-makeover
- https://www.bloomberg.com/company/stories/how-bloomberg-terminal-ux-designers-conceal-complexity/
- https://www.bloomberg.com/ux/2021/10/14/designing-the-terminal-for-color-accessibility/
- G:
  - https://upload.wikimedia.org/wikipedia/commons/d/d8/Bloomberg_Terminal.jpg
  - https://upload.wikimedia.org/wikipedia/commons/c/c7/2012_Bloomberg_Terminal_by_jm3_-_Creative_Commons_licensed.jpg

**Robinhood**
- https://www.portorocha.com/robinhood
- https://robinhood.com/us/en/newsroom/a-visual-identity-that-better-reflects-our-vision/
- G:
  - https://images.prismic.io/portorocha/aQohL7pReVYa4Ck1_RH.jpg
  - https://images.ctfassets.net/1hpl803w8xsv/4kpnzDZOCFmNu5zv3TkKc8/5393e19c7140bf4c0ed457260117883f/RH_Lists.jpg

**Genel referans kaynakları**
- https://www.gameuidatabase.com/
- https://interfaceingame.com/games/frostpunk/
