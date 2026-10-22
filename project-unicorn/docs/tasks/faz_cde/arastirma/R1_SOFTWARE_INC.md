# R1 — Software Inc. (Coredumping): ekip, iş, hata ve kalite modeli

Faz D (ekip modeli) için ana referans. Rapor 2026-10-17'de yazıldı.

Kaynak notu: Resmi wiki (softwareinc.coredumping.com) ince ve büyük ölçüde 2019 tarihli (Alpha 10.5.1 / 10.10). "Employees" sayfası yok (404). Formül düzeyindeki bilgi çoğunlukla oyuncu forumlarından, geliştiricinin forum cevaplarından ve Steam duyuru/patch notlarından geliyor. Bu yüzden her iddianın yanında kaynağın türü (wiki / geliştirici / oyuncu / kod okuyan oyuncu) belirtildi. Oyunun kodunu veya iç formüllerini doğrulayan resmi bir belge bulunamadı. Sayıların büyük kısmı bu yüzden "oyuncu gözlemi" ya da "niteliksel" kalıyor.

Steam duyurularını Steam'in haber API'sinden okudum (tarih aralığına göre): `https://api.steampowered.com/ISteamNews/GetNewsForApp/v0002/?appid=362620&count=N&maxlength=M&enddate=UNIX&format=json`. Aşağıda "Steam duyurusu" dediğim her şey buradandır. Geliştirici blogu itch.io'da da yayımlıyor: https://coredumping.itch.io/software-inc/devlog

---

## 1. Özet

1. **Ekip büyüklüğü için "önerilen kadro" var ve proje başına hesaplanıyor.** Oyun her ürün tipi ve yıl için önerilen Tasarımcı-Programcı-Sanatçı sayısını gösteriyor (örnek: 2010'da Oyun 5-8-7, Ofis yazılımı 4-8-2). Önerilenin üstü azalan getiri, geliştiriciye göre "ekip çalışmayı yavaşlatırsa bu hatadır, ama ek kişilerin eskisi kadar etkili olmaması normaldir". (Wiki Teams; Steam konusu "Team Size", 2023.)
2. **Beceri iki katmanlı: taban beceri (hız) + uzmanlık (nitelik / hangi özelliğe dokunabileceği).** Alpha 11'den beri uzmanlık 3 yıldızlı seviyeler ve yıldız "kalite çarpanı" değil, hangi özelliklerin yapılabileceğini belirleyen bir kapı. Bu bizim "yıldız = beceri/2" modelimizden belirgin biçimde farklı. (Steam duyurusu, Mayıs 2019 ve Nisan 2021.)
3. **Hata sayısı oyuncudan gizli ve ürün büyüklüğüyle birlikte büyüyor.** Alpha 9'dan beri hata sayısı baştan bilinmiyor, destek görevleri "teorik olarak sonsuz". Hata kaliteyi doğrudan düşürmüyor; iade, destek yükü ve (şiddetliyse) basın eleştirisi olarak geri dönüyor. Bu bizim "açık hata → memnuniyet/kitle düşüşü" kurgumuzla uyumlu. (Oyuncu konuları; Steam duyurusu.)
4. **Hata düzeltme kapasitesi "bir ekibin en yetenekli kişisi"ne bağlıydı; 2024'te "göreve atanmış tüm ekiplerdeki en yetenekli kişi"ye çevrildi.** Yani düzeltme kapasitesi kişi sayısıyla değil en iyi kişiyle ölçekleniyor; kalabalık düzeltmeyi hızlandırmıyor. (Steam duyurusu, 29 Eylül 2024.)
5. **Ölçekte en büyük sorun: büyük ekip verimsiz, 20-30 kişi civarı bir tavan var.** Geliştirici 2015'te "büyük projelerde etkinlik 25 civarında doyuyor, sert sınır değil" dedi; 30 → 150 kişi denemesinde birçok görev kısalmak yerine uzadı (oyun motoru 16 → 29 ay). Wiki "10-12 kişilik ekipler" öneriyor. (Steam konusu 2015; wiki Teams.)
6. **Geç oyunda yönetim yükü otomasyona (Lider + HR + Proje Yönetimi) devrediliyor.** Bu sistem hâlâ tartışmalı: 2025 konularında "PM şu hâliyle işlevsel değil" ve "PM etkinliği düşünce hata yapıyor" şikâyetleri var. Geliştirici PM'yi "puan sistemi"nden "hata (mistake) sistemine" çevirdi ve PM'nin etkinlik kaybını aktif görev sayısına bağladı. (Steam duyuruları 2024-2025; Steam konusu Kasım 2025.)
7. **Ürün kalitesi 2025 Kasım'da "kalite/yaratıcılık etiketleri"nden "dinamik müşteri yorum sistemi"ne geçti.** Ayrıntısı yayımlanmamış. Öncesinde dahili inceleme gürültülüydü, dışarıdan (outsource) inceleme güvenilirdi (oyuncu iddiası). (itch.io 1.8.31.)
8. **Bize dersi:** Sabit "kişi başı %X" yerine "önerilen kadro (R) + üstü için azalan getiri" modeli kullanılabilir; hata düzeltme kapasitesini en yetenekli kişiye bağlamak ve ölçekte yönetim yükünü ayrı bir kaynak (lider/PM etkinliği) olarak modellemek alınabilir. Gizli hata sayısı ve yıldızı "kapı" yapmak bizim için riskli; bkz. bölüm 5.

---

## 2. Mekanik döküm

### 2.1 Çalışan modeli

**Roller.**
- Wiki Quickstart (eski, "under maintenance"): Lead, Programmer, Designer, Artist, Marketer. https://softwareinc.coredumping.com/wiki/index.php/Quickstart_Guide
- Alpha 10 (Ağustos 2018): "Çalışanlar artık birden fazla role sahip olabilir" ve "işe alım ve beceri sistemi baştan yazıldı". Steam duyurusu Alpha 10 / 10.6.x.
- Alpha 11 (Haziran 2019): Pazarlama rolü "Service" rolüne çevrildi; Pazarlama, Destek, Hukuk uzmanlıkları. Nisan 2021 notları: "Support rolü Support, Marketing ve Legal'e bölündü, her birinin kendi uzmanlık seviyesi var". Steam duyuruları.
- Liderler (Alpha 11): Kendi uzmanlıkları var, hangi yönetim görevlerini yapabileceklerini bu belirliyor. Nov 2019 notu: azami lider uzmanlığı 9, lider her görevden küçük beceri kazanır. Steam duyurusu 23 Kasım 2019. Hâlen bir "Automation" (yalnız PM için anlamlı) ve "Multitasking" uzmanlığı var; kaynak oyuncu cevabı: https://steamcommunity.com/app/362620/discussions/0/678483003218900873/
- Yardımcı (staff) roller: IT-Support, Maintenance, Cleaning, Cook, Courier, Receptionist; maaş tablosu wiki'de (örnek: Cleaning aylık $1.000, IT-Support $2.500). Yazılım üretimiyle ilgisi yok, ofis çevresini etkiler. https://softwareinc.coredumping.com/wiki/index.php/Staff

**Beceri: taban beceri ve uzmanlık.**
- Mart 2018 oyuncu yorumu: "taban beceri çalışma hızını, spesifik beceriler kaliteyi etkiler" (oyuncu tahmini, resmi değil). https://steamcommunity.com/app/362620/discussions/0/1694914736004945552
- Geliştirici, Mayıs 2019: "Ürün kalitesi artık çalışanın taban becerisiyle kontrol ediliyor. Geliştirme hızını çalışanın memnuniyeti kontrol ediyor." Uzmanlıklar "tek sürekli değer yerine üç ayrı seviye"; "her seviye yalnızca kalite çarpanı değil, oyun üzerinde büyük etki". Programcı ve sanatçı için seviye hangi özelliklerle çalışılabileceğini belirler. Alt özellikler 1-3 seviyeli; seviye 3 özellikler kaliteyi artırmak yerine oyunu değiştirir. Steam duyurusu, 3 Mayıs 2019 ("Alpha 11 progress update").
- Nisan 2021 (Alpha 11 çıkışı): "Eğitim uzmanlıkları 3 yıldıza bölündü, yıldızlar hangi özelliklerde çalışabileceklerini sınırlıyor". "Her rolde taban beceri, çalışanın etkinliğini ve ürüne ne kadar kalite kattığını belirler." Steam duyurusu, 16 Nisan 2021.
- Veri modlama sayfası aynı yapıyı doğrular: özellik seviyesi (0-3) eğitim şartını belirler; seviye 0 herkes yapabilir ama pazar memnuniyeti daha düşük. https://softwareinc.coredumping.com/wiki/index.php/Data_Modding
- Ocak 2020: "çalışan becerisinin kaliteye etkisi azaltıldı" (Steam duyurusu, 12 Ocak 2020). Alpha 9.10.5: "iyi olmadıkları özelliklerde çalışan kişilerin kaliteye negatif etkisi daha da azaltıldı".
- Beceri kazanımı: Geliştirici (2015): "Tüm beceriler çalıştıkça otomatik artar, yavaş da olsa." https://steamcommunity.com/app/362620/discussions/0/594821545174207165 Öncesinde (A9 öncesi) uzmanlık eğitimle hızla tavana çıkıyordu; sonraki sürümlerde eğitim "neredeyse işe yaramaz" bulundu (oyuncu, 2018): https://steamcommunity.com/app/362620/discussions/0/1694914736004945552 Eylül 2024'ten sonra Mentorluk: "çalışanlar diğerlerine mentorluk yapıp daha hızlı beceri kazandırabilir" (Beta 1.8.8, Steam duyurusu Ekim 2024).
- Yıldız ≠ beceri: Takım becerisi 0-100 çubuk olarak gösteriliyor; "çok sayıda genç, düşük yıldızlı kişi birkaç yüksek yıldızı geçebilir" (oyuncu, 2025). https://steamcommunity.com/app/362620/discussions/0/603029004750983220

**Verimlilik (effectiveness), ruh hali, stres.**
- Wiki Teams: verimliliği belirleyenler "ortam, kişilik özellikleri, liderlik, yan haklar, ekip kompozisyonu ve temel insani ihtiyaçlar". Sayısal formül verilmemiş. https://softwareinc.coredumping.com/wiki/index.php/Teams
- Her çalışanın tam iki kişilik özelliği (trait) var; iyi/kötü/nötr listesi: iyi (FastLearner, BigBrain, Capacitor, Humble...), kötü (Stressed, Hypochondriac, NervousBladder, Forgetful...), nötr (NightOwl, BornLeader, SuperFocus...). Kişilikler arası ilişki -1..1 ve ekip uyumuna giriyor. https://softwareinc.coredumping.com/wiki/index.php/Data_Modding
- Sayısal oyuncu gözlemleri (eski sürümler, doğrulanmamış): vardiya 11 saati geçince verim yaklaşık %30'a düşüyor; toplantı düşük memnuniyeti "%29'a kadar" toparlıyor; masalara uzak yürüyüş ve uyumsuz ekip düşük verim nedeni olarak sayıldı (Temmuz 2015). https://steamcommunity.com/app/362620/discussions/0/530647080131550342
- Şikâyet talepleri maaşın %25'iyle sınırlı (Alpha 11.7.6; Steam duyurusu Ekim 2020 civarı). Maaş tepkisi Nisan 2024'te yenilendi: "istediklerinden az alınca sürekli memnuniyetsiz kalıyorlar" (Steam duyurusu, 15 Nisan 2024). Emeklilik/hayat/sağlık sigortasının ruh hâline etkisi Ocak 2026'da yeniden dengelendi (Beta 1.8.33).
- Alpha 11.6.1: sandalye ergonomi puanı hasta izni, verimlilik ve ruh hâlini etkiliyor. Ruh hâli, pişmiş yemekle arttı (Mayıs 2024).
- Stres: Alpha 10.6.1 "stresli çalışan çok daha az stresli, tembel çalışan biraz daha stresli olacak şekilde yeniden dengelendi". Kurucu stresi %75 oranında (yemek/tuvalet molası almadığı için); PM'li projelerin sayısı lider stresini artırır (Eylül 2024). İş doyumu hasta olma şansını etkiliyor (10.6.4).
- Tanıklık stresi: hırsızlık veya yangına doğrudan tanık olan çalışanlar olumsuz etkilenir (Ocak 2024).
- Ekip uyumu (compatibility): ekip penceresi "ortalama" yerine "asgari uyumu" gösteriyor (Ocak 2020); uyumsuz iş arkadaşı cezası "biraz azaltıldı" (11.7.12); iki kişi birbirinden hoşlanmıyorsa uyarı çıkıyor (Alpha 10.6.x). Oyuncular hedef olarak %200-300 üstü ekip uyumundan bahsediyor (oyuncu kanısı, kaynak: https://steamcommunity.com/app/362620/discussions/0/1781640738624802204 ve https://steamcommunity.com/app/362620/discussions/0/365163686064884721/ ).

### 2.2 İş nasıl tanımlanıyor

**Aşamalar.** Wiki Quickstart (eski): Tasarım → Alpha → Bekleme (Delay) → Beta → Yayın. Tasarımda tasarımcılar yeşil çubukları doldurur; "tasarımda çok kalırsan ilerleme kaybedersin". Alpha'da programcılar (yeşil) ve sanatçılar (kırmızı) çalışır; çubuklar bitince oyuncu "Promote" der. Beta'da hatalar temizlenir. https://softwareinc.coredumping.com/wiki/index.php/Quickstart_Guide
- Mayıs 2019'dan beri: tasarım fazı %100'de biter (fazla tasarım yok), Delay fazı kaldırıldı; geliştirme yinelemeli (tasarım ve alpha arasında geri dönülebilir). Alpha incelemesinden sonra geliştirme durdurup tasarım iyileştirilebilir. Steam duyurusu 3 Mayıs ve 23 Haziran 2019.
- Proje Yönetimi (PM) tarafından ekip bu aşamaları otomatik yürütebiliyor; Ekim 2020: "bir faz süreden önce biterse proje hızlandırılır".

**Özellik ve iş miktarı.**
- Özellik: `DevTime` (ay), `CodeArt` (1 = yalnız programcı, 0 = yalnız sanatçı, 0.5 = ikisi), `Level` (0-3) ve alt pazar (submarket) katkıları; `Server` (aktif kullanıcı başına Mbps, `1+log10(yıl-1969)` ile ölçekli; MMO 0.002). https://softwareinc.coredumping.com/wiki/index.php/Data_Modding
- `OptimalDevTime` (oyunlar için 40, işletim sistemleri için 75 ay) "ekip büyüklüğüyle ölçeklenmez" ve kaç özellikle alt pazarların doyacağını da belirler. Aynı kaynak.
- Her yazılım türünde bir "QA" özelliği var: "stabilite ve kullanılabilirliği artırır; geliştirme süresi ve yenilik pahasına". https://softwareinc.coredumping.com/wiki/index.php/Software_Types
- Proje yönetimi ayarları (Alpha 8 dönemi, sonradan kaldırıldı): Zaman↔Yenilik, Zaman↔Kalite, Bütçe↔Kalite kaydırıcıları. Geliştirici Alpha 9'da bu kaydırıcıları kaldırdığını söyledi. https://steamcommunity.com/app/362620/discussions/0/152390014801166254
- İterasyon sayısı: oyuncular 3-4 tasarım iterasyonundan söz ediyor; "büyük yazılımda tasarım fazı anahtar, yaklaşık 3 iterasyon" (oyuncu önerisi, 2025). https://steamcommunity.com/app/362620/discussions/0/3830917450442200418/ ve https://steamcommunity.com/app/362620/discussions/0/603029004750983220

**Atanan ekibin çıktısı ilerlemeye nasıl dönüşüyor.** Resmi formül bulunamadı. Bulunabilenler:
- Bir projenin temel süresi özelliklerden gelir; ekip büyüklüğü bu süreyi çarpar, rol ve beceri de etkiler. Kaynak: 2016'da oyun kodunu okuyan bir oyuncu (kotae). https://steamcommunity.com/app/362620/discussions/0/365163686064884721/
- Hız = memnuniyet (geliştirici, Mayıs 2019); kalite = taban beceri. Birden fazla ekip atanırsa etkin kişi sayısı = `(takım1 + takım2) + (takım sayısı − 1)` (kotae; 8 kişi öneren iş için 4+4 = 9 görünür). Oyuncu kendi okumasını düzeltmişti ve sürüm eski (2016); "çoklu ekip zararlı değil" sonucuna vardı. Wiki da 2019'da "çoklu ekip cezası hafifletildi; 30 kişilik iş için 10'luk 3 ekip büyük sorun değil" diyor.
- Bir görevi yalnızca uzmanlık eşiğini geçenler yapıyor; eşiği altında olanlar "kod katmıyor". Takım "asgari uzmanlık" ayarı var (Alpha 10.3.1). Kaynak (oyuncu): https://steamcommunity.com/app/362620/discussions/0/3288067088097196186
- Çalışan görev öncelik sırası "ikincil görev/ikincil rol" ayrımına göre (Beta 1.8.36, Nisan 2026). Ekip başına eşzamanlı görev sınırı eklendi (Beta 1.7.24, Kasım 2023).

### 2.3 Ekip büyüklüğü

**Önerilen kadro tablosu** (Tasarımcı-Programcı-Sanatçı; wiki Teams, Alpha 10.5.1, 2019): https://softwareinc.coredumping.com/wiki/index.php/Teams

| Yazılım | 1980 | 1990 | 2000 | 2010 |
|---|---|---|---|---|
| İşletim sistemi (bilgisayar) | 4-8-1 | 7-14-1 | 8-16-1 | 8-16-1 |
| 2D editör | 2-3-1 | 3-5-2 | 4-6-2 | 4-6-2 |
| 3D editör | yok | 2-4-0 | 5-9-0 | 5-9-0 |
| Ses aracı | 2-3-0 | 2-4-2 | 3-5-3 | 3-5-3 |
| Oyun motoru | 2-3-1 | 3-5-2 | 4-7-2 | 4-7-2 |
| Oyun (spor hariç) | 2-3-2 | 2-4-2 | 4-8-7 | 5-8-7 |
| Ofis yazılımı | 4-6-1 | 4-7-2 | 4-8-2 | 4-8-2 |
| CMS (finans) | 2-3-1 | 3-5-2 | 3-5-2 | 3-5-2 |
| Antivirüs | yok | 2-3-1 | 3-5-1 | 3-5-1 |

(Wiki'de işletim sistemi için aynı etiketle ikinci bir satır var: 3-6-1 / 6-11-1 / 7-13-1 / 7-13-1; farkı belirtilmemiş. Toplam 1980 ve 1990 satırlarına bakılırsa kadro 4-10 kişi küçük ürün, 20-30 kişi işletim sistemi.) Güncel (Beta 1.6) için bir Steam rehberi var, yalnız 2010'u kapsıyor: https://steamcommunity.com/sharedfiles/filedetails/?id=2991702551 (bu rehber 429 hatasıyla okunamadı, içeriği doğrulanamadı).

**Önerilenin üstü.**
- Oyun içi ipucu (oyuncu aktarımı): "önerilenden fazla çalışan varsa hız artışı giderek küçülür (azalan getiri)". Moderatör: "Önerilenden fazla çalışanınız varsa verimlilik düşüşü olur"; "bu düşüşün tüm ekibe büyük etkisi olan bir hata var"; geliştirici: "Genel ilerleme yavaşlarsa bu hatadır. Eklenen kişilerin artık o kadar etkili olmaması mantıklı." (9 Temmuz 2023). https://steamcommunity.com/app/362620/discussions/0/3830917450442200418/ Oyuncu örneği: önerilen 4 iken 17 kişi atanmış, gösterge kırmızı.
- Geliştirici (Eylül 2015): "Etkinlik büyük projelerde 25 civarında doyuyor"; "25 sert sınır değil, biraz değişir"; "önerilen büyüklük bir global optimum, tavan değil; kişi eklemek etkinliği artırmaya devam eder ama bir noktadan sonra maliyet açısından verimsiz"; "eklenen insanlar birbirinin ayağına dolaşabilir"; "oyun bu kadar çok çalışan için optimize edilmedi." Oyuncu testi (debug menüsü, çalışan becerileri maksimum): çekirdek ekip 30 → 150 iken Görsel araç 9 → 13 ay, Ses aracı 9 → 15, Oyun motoru 16 → 29, Oyun 30 → 39; İşletim sistemi 3 → 2 yıl (hızlandı). https://steamcommunity.com/app/362620/discussions/1/517142253871554015/
- Wiki: "10-12 kişilik ekipler proje etkinliği için ideal", üstü kod tabanında "ölçek dezekonomisi" (200 kişi örneği); formül yok. Önerilen kadroya uyulmasını "marjinal maliyet = marjinal gelir" noktasına benzetiyor.
- Oyuncu uygulaması: geç oyunda "önerilen kadroyu ikiye katlayıp HR'a veriyorum" diyenler var (https://steamcommunity.com/app/362620/discussions/0/3159763879074407751). "Önerilenin üstü hızı düşürür, önerilen genelde en hızlısıdır" diyen bir oyuncu da var; bu ikinci söz yalnız arama sonucu özetinden geldi, ilgili konunun kendisi (arama sonucundaki 355043117514234776 değil, adı doğrulanmadı) okunmadı, bu yüzden kaynaksız say.

**Az kişi.** Başlangıçta tek kişi (kurucu) ile küçük ürün yapılabilir; "Easy'de tek geliştirici Good hatta Great bir ürün çıkarabilir" (wiki Beginner's Tips, 10.6.9). Uygulama ipucu: erken sözleşmelerde önerilen kadro 1. https://softwareinc.coredumping.com/wiki/index.php/Beginner%27s_Tips

**Takım liderleri ve yönetim yükü.**
- Takım için lider gerekli (wiki: tek-iki sanatçılık ekip açmayın, ayrı oda ve lider ister).
- Lider, tüm rollerde ve fazlarda yaklaşık %25 etkinlikle katkı veriyor (kotae'nin kod yorumu, doğrulanmamış; 2016): https://steamcommunity.com/app/362620/discussions/0/365163686064884721/
- Lider özel ofis bonusu 2024'te %50'den %25'e indirildi (Beta 1.7.27). Karşılanmayan "lead designer" talepleri kırmızı gösteriliyor (Beta 1.8.22).
- PM (Proje Yönetimi) lideri: etkinliği bir çubuk, alt çizginin altına düşünce hata yapıyor; "100'de başlar, yaklaşık 3 ay sonra alt çizgiye iner; gün içinde azalır, geceleri yaklaşık %80+ seviyesine toparlar" (oyuncu tarifi, Kasım 2025). https://steamcommunity.com/app/362620/discussions/0/678483003218900873/ Geliştirici: "PM etkinlik kaybı artık sabit değil, aktif görev sayısına bağlı ve sınırsız" (Beta 1.8.24, Eylül 2025) ve PM "puan sistemi" yerine "hata sistemi" (Eylül 2024).

**Oyuncuya nasıl gösteriliyor.** Tasarım belgesi penceresinin sağ altında "önerilen ekip" kutusu; gerçek sayı önerilenin üstündeyse kırmızı gösterge (kaynak: oyuncu ve moderatör, https://steamcommunity.com/app/362620/discussions/1/517142253871554015/ ve https://steamcommunity.com/app/362620/discussions/0/3830917450442200418/ ). Ekip penceresi asgari ekip uyumunu ve (Kasım 2025'ten beri) lider sütununu gösteriyor (Steam duyurusu).

### 2.4 Test ve hatalar

- Hata sayısı artık baştan bilinmiyor ("destek görevleri ve hata düzeltmeleri teorik olarak sonsuz"); Alpha 9 duyurusunun maddeleri (Steam duyurusu, özetlenen madde listesi).
- Alpha'da ve beta'da hatalar temizleniyor; beta'nın uzunluğu oyuncu seçimi: tipik 3-6 ay, rakibe göre erken çıkış veya uzatma. Oyuncu verileri: 100-300 hata düzeltmek tipik; işletim sisteminde geliştiriciler 1.000, destek 1.500+ hata buldu (satış 600 bin, iade 25 bin civarı). https://steamcommunity.com/app/362620/discussions/0/1470841715955280426
- Oyuncu tahmini: "orta becerili test ile yaklaşık her kod birimi için 50 hata"; 2D editör (yaklaşık 10 birim) ≈ 500, ses aracı (≈ 14 birim) ≈ 700 hata; beta'da 350/450 temizlendi, destek sonradan yaklaşık 500 daha buldu; hata keşfi önce hızlı, sonra aylarca yavaşlıyor. Bu, bir oyuncunun kendi sayımı ve kaba. https://steamcommunity.com/app/362620/discussions/0/1696043263502958919
- Hata üretimi: bulunan açık bir formül yok. Wiki sözleşmeler için "küçük proje ve sözleşmelerde azami hata sayısı düşürüldü" (Ekim 2019 notu) diyor. "Eş değerlendirme (peer review) hata sayısını ve kaliteyi etkiler" (Alpha 10.2.1). "Hata düzeltme hızı artık ortalama ekip programlama becerisine bağlı değil" (Kasım 2019, hata doğrulama).
- Bir görevi çok kişi test/düzeltebilir mi: Evet, ama kapasite "göreve atanmış tüm ekiplerdeki en yetenekli kişiye" bağlı (Eylül 2024), önceden "aynı ekipteki en yetenekli kişi". Yani paralellik sınırlı: kalabalık eklemek düzeltme kapasitesini artırmıyor, yalnız en iyi kişi belirleyici.
- Yayın sonrası: destek ekibi hataları buluyor; destek personeli eğitimsizse hata bulamıyor ve boğuluyor (oyuncu). Destek bilet simülasyonu Ağustos 2026'da destek görevinden ayrıldı; hedef kitle destek biletlerini artırıp azaltabiliyor (Steam duyurusu 5 Ağustos 2026). Destek ekibi büyüklüğü için wiki: "aktif kullanıcı ve beta'da düzeltilen hata sayısına göre, 30'un altında tutun".
- Hata ve kalite ilişkisi (oyuncu uzlaşması): "hata ürünü ne daha iyi ne daha kötü yapar; yayın sonrası kaç destek personeli gerektiğini etkiler"; şiddetliyse basın incelemesine girer. https://steamcommunity.com/app/362620/discussions/0/1696043263502958919 Wiki Quickstart: "hatalarla çıkarsanız müşteri memnuniyeti ve satış/sözleşme ödemesi düşer." Bir oyuncu: "Gizli hata sayısı destek yükünü, müşteri sorgularını ve incelemeleri etkiler."

### 2.5 Ürün kalitesi

- Yazılımın pazarı alt pazarlara (submarket) ayrılıyor; her özelliğin alt pazar katkıları normalize ediliyor (örnek 3,4,5 → 3/12, 4/12, 5/12). `OptimalDevTime` kaç özellik gerektiğini belirliyor. (Data Modding sayfası.) Geliştirici "yeterince özellik olmadan alt pazarlar doymaz" mantığını koruyor.
- Alpha'da "inceleme" alınabilir (kendi ekibi veya dışarıdan). Ocak 2024'ten beri alpha incelemeleri mevcut ilerlemeye göre ayarlanıyor. Dahili incelemeler gürültülü: aynı durumda 4.8 / 4.0 / 4.7, alt puanlar 0,9 ile 6,2 arası oynuyor; oyuncu iddiası: "dahili %10 doğru, dışarıdan %80" (kaynaksız oyuncu hatırası). https://steamcommunity.com/app/362620/discussions/0/2650805212044784447
- Kalite etiketleri: "Horrible ... Great ... Outstanding" gibi aralıklar; Beta 1.8.31 (20 Kasım 2025): "ürün kalitesi/yaratıcılık etiketleri, daha çok değişkeni hesaba katan dinamik müşteri yorum sistemiyle değiştirildi". https://itch.io/devlog/1119376/patch-notes-for-beta-1831.amp Ayrıntı yayımlanmamış, bulunamadı. Ocak 2024: "müşteriler geniş kapsamlı ürünlerin özelliklerine ve kalitesine daha duyarlı". Alpha 11.5.8: sözleşme kalite değerlendirmesine "Glitchy" etiketi eklendi (itibar kaybı açıklansın diye).
- Eksik nerede: Dışarıdan inceleme alt kalem puanlarını gösteriyor (oyuncu örneği: 3D sanat 9.6/10, ses 5/10; https://steamcommunity.com/app/362620/discussions/0/1290691308585991381). Tasarım belgesinde uzmanlık pasta grafiği kod/sanat olarak ayrı (10.6.2) ve hangi uzmanlıkların gerektiği görünür.
- Kalite eksenleri: Resmi olarak "innovation / usability / stability" benzeri üç eksen QA özelliğinin açıklamasında geçiyor (QA: "stabilite ve kullanılabilirliği artırır, geliştirme süresi ve yenilik pahasına"); "yaratıcılık/yenilik" etiketi Kasım 2025'e kadar vardı. Puanlama formülü bulunamadı.

### 2.6 Ölçek

- Geliştirici (Kasım 2017/2018 notları): "oyun binlerce çalışan için dengelenmedi" (10.4.2); HR tek seferde 300+ kişi işe alınca oyun donuyordu, düzeltildi (10.6.9). 2015 geliştirici: oyun çok çalışanda optimize değil.
- HR otomasyonu: lider HR becerisiyle işe alım/eğitim/maaş/şikâyet yönetimi (wiki Project Management: "Handle wages", "Handle complaints"; 4 programcı/3 sanatçı/2 tasarımcı hedefi örneği). "Alpha 10'da HR yeniden yazıldı". Beta 1.8.28: HR rol atama kontrolü; 1.8.33: HR atanmış role göre işe alabilir. Oyuncu: HR "eğitim seviyesi" kaydırıcısı kritik; ince ayarı kaldırdığı için bazıları kullanmıyor. https://steamcommunity.com/app/362620/discussions/0/1642042464744479084
- Proje Yönetimi (PM): hazır PM'e görev ekleyince destek, güncelleme, port ve pazarlama sürüyor (wiki: "3-4 sözleşmeden sonra ekip kendi başına sözleşme almaya başlar"); 2025 oyuncu: "PM halen işlevsel değil, atlayın" (nosedigger) fakat başka bir oyuncu kurulumla çalıştırıyor. https://steamcommunity.com/app/362620/discussions/0/603029004750983220
- Ekip kurulumları kaydedilip yüklenebiliyor (1.7.25), ekip başına görev sınırı (1.7.24), ekip başına yan haklar (1.8.15), global arama paneli (1.8.31), takım odası paylaşımı (aynı projedeki görevler > %50 ise; 1.8.31).
- Oyuncu uygulaması: 200 çalışanda "hangi çalışan hangi ekipte" izleme zor, emekli olan lider sessizce ekibi liderliksiz bırakır (2016 öneri konusu). https://steamcommunity.com/app/362620/discussions/0/355043117514234776

---

## 3. Oyuncuya gösterim

Gerçek ekran görüntüsü URL'si indiremedim (WebFetch ile görsel bağlantıları döndürülmedi). Yapı olarak okunabilenler:
- **Tasarım belgesi penceresi:** sağ altta "önerilen ekip" sayısı; kırmızı göstergeyle aşım uyarısı; üstte alt pazar ve özellik listesi; kod/sanat pasta grafiği. (Oyuncu ve moderatör aktarımı.)
- **Ekip penceresi:** ekip uyumu (asgari), lider sütunu, "eve gönder" düğmesi, çoklu ekip seçme; çalışan penceresinde aktif görevler listesi, uyumluluk listesi, durum sütunu "ne zaman gelecek".
- **Çalışan durumu:** ekranın sol altında seçilen çalışanın anlık durumu ("Not Working - Negatively affected by environment" gibi); stres kaplaması (heatmap, Ocak 2020); kişilik özellikleri etiketi renkli.
- **Steam mağaza sayfası** ekran görüntüleri için: https://store.steampowered.com/app/362620/Software_Inc/ (sayfa bu görevde açılıp doğrulanmadı; URL'nin doğru olduğu appid 362620'den biliniyor).
- Wiki Teams sayfasındaki öneri tablosu ve itch.io: https://coredumping.itch.io/software-inc

---

## 4. Ölçek ve sorunlar

**Küçük şirket.** Tek kurucu sözleşme yapar; erken sözleşmeler 1-2 kişi, 1-2 ay, düşük kalite şartı. İlk $50.000 hedefi (wiki). Eğitim erken oyunda 2 kişi, 3 ay; geç oyunda 3-4 kişi 6 ay (wiki ipucu).

**Büyük şirket.**
- 10-12 kişilik ekip ideal; geç oyunda destek ekibi 30'un altında tutulsun (wiki); 24+ kişi işletim sistemi ekibi, 10+ kişi oyun (oyuncu, 2016).
- 150 kişi 30 kişiden yavaş çıktı (2015 testi). 2023'te geliştirici: genel yavaşlama hatadır.
- Çoklu proje stresi: bir ekip iki projeyi stres olmadan götürür, "iyi bir lider ve ayrı toplantı odasıyla yaklaşık on göreve kadar" (oyuncu). "Küçük, odaklı ekipler en iyisi" (oyuncu). https://steamcommunity.com/app/362620/discussions/0/3288067088097196186 , https://steamcommunity.com/app/362620/discussions/0/1781640738624802204
- Ekip kurma tarzı tartışmalı: ürün bazlı ekipler (uyumu kolay), işlev bazlı ekipler, karma 7 kişilik, 20-26 kişilik karma. https://steamcommunity.com/app/362620/discussions/0/3159763879074407751

**Oyuncu şikâyetleri.**
- Proje süre tahminleri güvenilmez; yavaşlayan projede "neyi değiştireyim" bilgisi yok; fazla kişinin yavaşlatması. (Steam konusu 2016.) https://steamcommunity.com/app/362620/discussions/0/355043117514234776
- Lider emekliliği sessiz; maaş kaydırıcıları kaba; çok mikro yönetim.
- İşe alımda kayıt-yükleme: "oyun aday ararken kötü çıkıyor" ve "kaydet, aday ara, yükle" yöntemi (2025 oyuncu itirafı, https://steamcommunity.com/app/362620/discussions/0/603029004750983220 ). Geliştirici bunu "8 saatten kısa sürede kovmak aday çekiciliğini artık etkilemiyor" ile kısmen hafifletmiş görünüyor (Aralık 2023) — bu çıkarım benim, notta sebep belirtilmemiş.
- PM etkinliği ve hata sistemi: "PM'i boğuyor; verimlilik 0/100". (Kasım 2025.)
- HR otomatik işe alım yüksek maaşta bile kötü aday getiriyor; eğitim sonrası "hiçbir şey değişmiyor" (Temmuz 2019).
- Stres/vardiya: Düşük verim vakaları (%30 verim) eski sürümlerde vardiya uzunluğu ve ekip uyumuyla ilişkilendirildi.

**İstismarlar ve "kolay yollar" (oyuncu bildirimi).**
- Eğitim A9 öncesinde uzmanlığı kısa sürede tavana çıkarıyordu (sonra düzeltildi).
- Debug "max employee stats" testi bilinen bir zayıflık değil, yalnız test.
- Wiki: "Büyük bir rastgele ekip" boştaki çalışanları iki ay boyunca sürekli eğitimde tutup becerilerini yükseltmek (wiki Teams "That One Big Team of Randoms").
- Oyuncular "tüm yetenekler birbirine bağlı olduğundan her koda bir uzman" ile Great/Outstanding ürün garantili sayıyor (2018 oyuncu).

**Sonradan yapılan değişiklikler (tarih sırasıyla).**
- Alpha 9 (2017): hata sayısı gizlendi; PM kaydırıcıları kaldırıldı.
- Alpha 10 (Ağustos 2018): memnuniyet ve yan haklar baştan yazıldı; çoklu rol; HR baştan yazıldı.
- Alpha 11 (2019-2021): uzmanlık 3 yıldızlı kapı; kalite = taban beceri, hız = memnuniyet; tasarım fazı %100'de biter; Delay kaldırıldı; asgari ekip uyumu gösterimi; beceri-kalite etkisi azaltıldı.
- Beta 1.7 (2023-2024): ekip görev sınırı, kaydedilebilir ekip kurulumları; maaş tepkisi yenilendi (Nisan 2024).
- Beta 1.8 (2024-2026): PM hata sistemi (Eylül 2024); hata düzeltme kapasitesi en yetenekli kişi, tüm ekipler; mentorluk (Ekim 2024); PM etkinlik kaybı görev sayısına bağlı (Eylül 2025); müşteri yorum sistemi (Kasım 2025); oda paylaşımı; HR role göre işe alım (Ocak 2026); hedef kitle destek biletlerini etkiliyor (Ağustos 2026).

---

## 5. Bizim için

Hatırlatma: oyunumuzda yıldız = beceri/2 (1-5), kişi en çok 2 iş tutar, kartlar tasarım → geliştirme → test, hata hatta düşer, düzeltme kartı hattın hatalarını siler, hedef 20-50+ çalışan.

**Alınabilir**

1. **"Önerilen kadro" kavramı, kart bazında.** Software Inc.'te her projenin önerilen kişi sayısı, işin kapsamından hesaplanıyor ve oyuncuya açıkça gösteriliyor; üstü azalan getiri. Bizde her kart (K1/K2/K3) için bir R (önerilen kişi) olmalı; R, kartın iş miktarından gelmeli, sabit değil. Gerekçe: sahibin endişesi olan "çalışan başına %5" 10 kişide bozulur; R'ye göre tanımlanan bir model ölçekte kırılmaz. Önerilen yöntem (bizim uyarlamamız, kaynaklı değil): etkin işçi = n, n ≤ R ise; n > R ise R + (n−R)·0,5 gibi bir azalan getiri eğrisi veya log tabanlı. Sayıyı Faz D'de ölçümle seçmek gerekir; Software Inc.'in kendi sayısı bulunamadı.
2. **Kişilerin hata düzeltme kapasitesini "en yetenekli kişi"ye bağlamak.** Software Inc. 2024'te bunu "aynı ekipteki" yerine "göreve atanmış tüm ekiplerdeki en yetenekli kişi" yaptı. Düzeltme kartında efor, kartın hata sayısı ve atanmış kişilerin toplamı ile ilişkilendirilebilir; en iyi kişinin yıldızı süreyi belirler, kalabalık ekleme etkisi sınırlı. Bizim "Test" işine uygun: aynı hatta test eden çok kişi paralel çalışsın ama kapasite birinci kişinin yıldızı + ikincilerin küçük bir payı olsun (sayı bizim önerimiz).
3. **Hata → kalite ilişkisi.** Hata ürünün kalitesini bozmuyor, müşteri yüküne geri dönüyor (oyuncu uzlaşması). Bizim "açık hata B2B memnuniyetini ve B2C kitlesini düşürür" kurgumuzla örtüşüyor; ayrıca "hata sayısını yayın sonrası destek yüküne bağla" fikri (destek bilet simülasyonu ayrı, hedef kitle etkisi: Ağustos 2026) bizim Destek işi için doğrudan bir model: açık hata sayısı → bilet akışı → Destek kapasitesi.
4. **Yönetim yükünü kaynak yapmak.** PM'in etkinliğinin aktif görev sayısına bağlanıp bir "çubuk" olarak gösterilmesi (alt çizginin altında hata yapıyor), lider stresinin aktif proje sayısıyla artması. Bizde 20-50 kişide PM ve lider gibi roller tek kişinin aşırı yüklenmesine yol açar; "bir kişi en çok 2 iş" kuralı bunun ucuz bir karşılığı. Yönetim yükünü görünür bir ölçü yapmak (kaç kart/hat kim adına) sahibin "ölçekte sabit sayılar kırılır" endişesine cevap.
5. **Asgari uyum / asgari uzmanlık göstergesi.** Ekip uyumunda "ortalama" yerine "asgari" kullanmak (Ocak 2020 değişikliği) tek kötü eşleşmenin gizlenmesini önler. Bizde uyum modeli yoksa bile "eşleşmeyen tek kişi" fikri hat/kart düzeyinde uyarı olabilir.
6. **Mentorluk.** 2024'te eklendi; yeni nesil çalışan yetiştirmek için sabit ücretli eğitim yerine "yıldızı yüksek kişi diğerinin gelişimini hızlandırır". Büyük ölçekte ücretsiz hızlanma yaratacağı için sınırı (bir mentor en çok k kişi) şart; sayı bulunamadı.

**Alınmayacak**

1. **Gizli hata sayısı.** Software Inc.'te hata sayısı bilinmiyor, destek "sonsuz" ve oyuncular kafa karışıklığı (700+ hata, "ne zaman yayınlayayım") yaşıyor. Bizim kartlar hatlara hata düşürüyor ve düzeltme kartı hatayı siliyor; hatayı görünür tutmak (Hat paneli yazıyor) zaten doğru. Gizlemek Faz A'da kurduğumuz "N açık hata ›" gösterimine ters.
2. **Yıldızı "yalnız kapı" yapmak.** Alpha 11'de uzmanlık seviyesi hangi özelliklere dokunulabileceğini belirliyor (kalite çarpanı değil). Bizde yıldız 1-5 ve ekibin her kartta çalışabilmesi isteniyor; kapı koymak küçük ekipte kilitlenme riski taşır (oyuncular "1 yıldızlı herkes işe yaramaz, 3 yıldızlı iki kişi seç" yönünde özelleşme tavsiye ediyor). Bizim için daha uygun: yıldız hız/kalite etkiler, kapı yok ya da yalnız K3 gibi en üst kartta yıldız eşiği.
3. **Çok sayıda yumuşak etken** (ortam, sandalye ergonomisi, oda sıcaklığı, onlarca kişilik özelliği). Oyuncular bunu "bir sürü ayar ve kadran" olarak görüyor; bizim yönetim oyunumuzda odak kart/sprint olduğu için bu kapsam fazla.
4. **Ekip kurma ve oda sistemi.** Software Inc.'te bina düzeni ve oda paylaşımı verimi belirliyor; bizim tasarımda yok ve gerekmiyor.
5. **PM'in mevcut hâli.** 2025 oyuncu konuları PM'in işlevsel olmadığını söylüyor; otomasyonu bizim "Hesaplar/Satış/Test" işlerine bu şekilde taşımak risk.

**Uyarlanacak**

1. **Önerilenin üstü için sınır.** Geliştirici 25 civarı tavan dedi ve sert sınır olmadığını söyledi; bizim 20-50+ hedefimiz için kart başına R'yi 3-6 kişi gibi küçük tutmak, büyük şirkette aynı anda çok kart yürütmeyi (paralellik) teşvik eder, tek karta yığmayı değil. R'nin gerçek değeri Faz D ölçümüyle seçilmeli (bulunamadı).
2. **Çoklu ekip yerine çoklu kart.** Software Inc.'te birden çok ekip aynı projeye atanınca her ekip +1 "görünmez çalışan" ekliyordu (2016 okuması, güncel olmayabilir). Bizim modelde iki kart paralel yürütüldüğünde koordinasyon maliyeti olarak hat başına küçük bir sabit "ek kişi" eklemek bu mantığın yan etkisi: sabit sayı ama kişi sayısına göre ölçeklenmiyor, bu yüzden kabul edilebilir.
3. **Müşteri yorumu/inceleme.** Software Inc. 2025'te etiket yerine yorum sistemine geçti. Bizim için ürün kalitesinin ekranda "müşteri ne diyor" şeklinde açıklanması (memnuniyet, hata yükü) kalite etiketinden daha açıklayıcı olabilir; bkz. R8.
4. **Eğitim ve eski beceri artışı.** Çalıştıkça yavaş beceri artışı (geliştirici 2015) bizim yıldız sistemimize "kart bitirdikçe küçük puan" olarak uyarlanabilir; ayrıca eğitimin tavanını sınırlamak gerek (Software Inc. A9 öncesi tavanı hızla doldurma sorunu yaşadı).
5. **Önerilen kadro sayısını oyuncuya açıkça göstermek.** Software Inc.'te tasarım belgesinde yazıyor ama ipucu görünmez (oyuncular tooltip'te buldu). Bizde kartın üstünde "önerilen: 3 kişi, atanan: 5 (azalan getiri)" gibi doğrudan yazılmalı.

---

## 6. Bulunamayanlar

- Çalışan etkinliğinin (effectiveness) açık formülü: bulunamadı. Wiki "Employees" sayfası yok (404). Yalnız "ortam, özellikler, liderlik, yan haklar, ekip kompozisyonu, temel ihtiyaçlar" sayılıyor.
- Önerilenin üstü için azalan getirinin sayısal eğrisi: bulunamadı (yalnız "azalan getiri" ve "25 civarı tavan").
- Hata üretim formülü (kod miktarı, beceri, acele): bulunamadı. Yalnız oyuncu tahmini "orta beceride kod birimi başına yaklaşık 50 hata".
- Test/QA'nın kaç kişiyle paralelleştiği ve beta'da hata bulma oranı: yalnız oyuncu gözlemleri; hata düzeltme kapasitesinin en yetenekli kişiye bağlandığı biliniyor (resmi duyuru), kalanı bulunamadı.
- Yeni müşteri yorum sistemi (Kasım 2025) ayrıntıları: yayımlanmamış.
- Ekran görüntüsü URL'leri doğrulanmadı (Steam sayfası açılmadı).
- Kaynak okunamayanlar: SteamDB patch notları (403); Steam rehberleri "Recommended Team Sizes", "Mentoring", "LatN's Strategy", "Subsidiaries" (Steam 429 hız sınırı, tekrar denemelerde de açılmadı) — bu rehberlerin içeriği rapora girmedi. Reddit (r/SoftwareInc) WebFetch ile okunamadı.
- Alpha 11 duyurusundaki sayılar (örneğin "yıldız eşiği = hangi puan aralığı") bulunamadı; 3 yıldızın beceri aralığı hangi 0-100 değerlerine denk geldiği belli değil.
- Oyuncu iddialarının hepsi (özellikle 2015-2019 tarihli) sonraki sürümlerde (Beta 1.7-1.8) değişmiş olabilir; güncel sürüm için doğrulanmadılar.

## Kaynak listesi

- https://softwareinc.coredumping.com/wiki/index.php/Teams
- https://softwareinc.coredumping.com/wiki/index.php/Staff
- https://softwareinc.coredumping.com/wiki/index.php/Project_Management
- https://softwareinc.coredumping.com/wiki/index.php/Beginner%27s_Tips
- https://softwareinc.coredumping.com/wiki/index.php/Quickstart_Guide
- https://softwareinc.coredumping.com/wiki/index.php/Data_Modding
- https://softwareinc.coredumping.com/wiki/index.php/Software_Types
- https://softwareinc.coredumping.com/wiki/index.php/Code_Modding
- https://softwareinc.coredumping.com/wiki/index.php/Game
- https://softwareinc.coredumping.com/wiki/index.php/Special:AllPages
- https://api.steampowered.com/ISteamNews/GetNewsForApp/v0002/?appid=362620 (çeşitli tarih aralıkları)
- https://itch.io/devlog/1119376/patch-notes-for-beta-1831.amp
- https://coredumping.itch.io/software-inc/devlog
- Steam konuları: 1290691308585991381, 1470841715955280426, 1696043263502958919, 3159763879074407751, 355043117514234776, 1781640738624802204, 3288067088097196186, 152390014801166254, 1642042464744479084, 594821545174207165, 2650805212044784447, 1694914736004945552, 603029004750983220, 3830917450442200418, 4205868123785820338, 530647080131550342, 517142253871554015 (discussions/1/), 365163686064884721, 678483003218900873 — hepsi https://steamcommunity.com/app/362620/discussions/0/<id> biçiminde.
- https://steamcommunity.com/app/362620/guides/ (rehber listesi)


---

## 7. Tamamlama (2026-10-17, başsız Chrome)

Kaynak durumu: Steam rehberleri artık okundu (Recommended Team Sizes iki sürüm, Max's Beginners Guide, Mentoring, LatN's Strategy; Subsidiaries açıldı ama konumuzla ilgisi yok), resmi wiki'nin tam sayfa listesi alındı, Steam mağaza sayfasından ekran görüntüsü URL'leri çıkarıldı ve dört ekran görüntüsü gözle incelendi. Steam rehberlerinin hepsinde sayfa üstünde "bu öğe Steam şartlarını ihlal ettiği için kaldırıldı, Software Inc ile uyumsuz" uyarısı var; yani rehber sahibi dışında kimse görmüyor olabilir ve içerik güncel sürümle uyumlu olmayabilir. Hepsi OYUNCU bilgisidir, resmi değildir.

### 7.1 Resmi wiki'de neler yok (kapanan boşluk, olumsuz yönde)

- Resmi wiki'nin tam sayfa listesi (https://softwareinc.coredumping.com/wiki/index.php/Special:AllPages): 2D Editor, 3D Editor, Antivirus, Audio Tool, Beginner's Tips, CMS, Code Modding, Console, Contract Work, Data Modding, Deals, Furniture Modding, Game, Game Engine, Hardware Design, Main Page, Material Modding, Modding, Office Software, Operating System, Project Management, Quickstart Guide, SIPL, Software Types, Staff, Stocks, TYD (üç yazımla), Teams. Yani Features, Quality, Bugs, Hosting/Servers, Employees diye ayrı sayfa YOK. §6'daki "Employees 404" bu yüzden; "özelliklerin innovation/usability/stability değerleri" resmi wiki'de hiç yok.
- Veri modlama sayfasında özellik alanları şöyle tanımlı (https://softwareinc.coredumping.com/wiki/index.php/Data_Modding): Name, Spec (2D, 3D, Network...), Description, Dependencies, Unlock (açılış yılı), DevTime ("kaç ayda geliştirilir"), Submarkets (üç değerli alt pazar oranı), CodeArt ("1 yalnız programcı"), Server ("aktif kullanıcı başına kaç mbps; 1+log10(yıl-1969) ile zamanla ölçeklenir"), Optional, SoftwareCategories, Features. Alt özelliklerde ek olarak Level ("kim çalışabileceğini belirler"). Innovation, Usability, Stability, Research alanları bu sayfada tanımlı DEĞİL. Yani oyunun veri biçiminde özelliğin "yenilik/kullanılabilirlik/kararlılık" katkısı özellik başına sayı olarak yok; wiki'deki tek geçtiği yer QA özelliğinin açıklaması ("stabilite ve kullanılabilirliği artırır, geliştirme süresi ve yenilik pahasına", https://softwareinc.coredumping.com/wiki/index.php/Software_Types). Düzeltme: §2'deki "kalite eksenleri üç eksen" ifadesini resmi bir veri alanı gibi okumayın; bunlar yalnız bir tooltip cümlesi.
- Aynı sayfada MMO örneği: "MMO 0,002 kullanır; 2010'da 1 milyon kullanıcı için her an yaklaşık 5 gbps." Bu, Server alanıyla uyumlu (0,002 mbps x 1 milyon x [1+log10(2010-1969)=2,61] = yaklaşık 5,2 gbps). Betik yorumu: "her 100. aktif kullanıcı için üründen 1 hata sil" (bir mod betiği örneğinde geçiyor, genel kural olarak okumayın). Kaynak: Data_Modding.

### 7.2 Önerilen ekip büyüklüğü: iki sürüm ve özellik sayısına bağlılık (kapanan boşluk: "Recommended Team Sizes")

- Beta 1.6 rehberi, yalnız 2010 için, Tasarımcı/Programcı/Sanatçı biçiminde. "Base" (ek özellik yok): Bilgisayar işletim sistemi 5/8/0; Konsol ve telefon 4/6/0; 2D Editor 2/3/1; 3D Editor 2/2/2; Audio Tool 3/4/1; Spor oyunu 2/2/1; Spor dışı oyun 2/3/2; Ofis yazılımı 2/2/1; Antivirüs 1/2/0. "Complete" (yasadışı olmayan tüm ek özellikler): Bilgisayar 13/24/1; Konsol ve telefon 10/20/1; 2D Editor 8/13/3; 3D Editor 8/16/1; Audio Tool 10/19/2; Spor 10/13/7; Spor dışı oyun 13/18/8; Ofis 8/12/5; Antivirüs 5/10/1. Yazar 1980, 1990, 2000 sütunlarını sonraya bırakmış; veri toplama yöntemini söylemiyor. Kaynak: https://steamcommunity.com/sharedfiles/filedetails/?id=2991702551 (oyuncu).
- Alpha 10 rehberi (tüm özellikler seçili, lider sayılmaz): Bilgisayar OS 4-8-1 (1980), 7-14-1 (1990), 8-16-1 (2000, 2010); Konsol OS 3-6-1, 6-11-1, 7-13-1; Telefon OS yalnız 2000'den: 6-11-1; 2D Editor 2-3-1, 3-5-2, 4-6-2; 3D Editor 1990: 2-4-0, 2000: 5-9-0; Audio Tool 2-3-0, 2-4-2, 3-5-3; Game Engine 2-3-1, 3-5-2, 4-7-2; Oyun (spor dışı) 2-3-2, 2-4-2, 4-8-7, 2010: 5-8-7; Spor oyunu 2-2-1, 2-3-2, 4-6-5, 4-7-5; Ofis 4-6-1, 4-7-2, 4-8-2; CMS Web 2000: 2-4-2; CMS Financial 2-3-1 -> 3-5-2; CMS Workflow 2-4-1 -> 3-6-1; Antivirüs 1990: 2-3-1, 2000: 3-5-1. İpuçları: destek ekibi aktif kullanıcıya ve beta'da düzeltilen hataya göre büyür, 30 kişinin altında tutulmalı; pazarlama ekibinin her ürün için bir "altın sayısı" var; erken oyunda pazarlama ve destek ekiplerini ikiye bölün ya da izin aralığını genişletin ki aynı anda az kişi izinde olsun. Kaynak: https://steamcommunity.com/sharedfiles/filedetails/?id=1327768314 (oyuncu).
- 2024 notu (aynı Alpha 10 rehberinde): 2010'da tüm özellikleri seçmek kabaca 15 tasarımcı, 25 programcı, 5 sanatçı ve 25 yıl geliştirme ister; her şeyi seçmek beklenen ilgiyi %100'e getirir ama boşa giden ilgi %450 olur; yalnız beklenen ilgiyi yaklaşık %100'e çıkaran özellikleri seçin. Kaynak: aynı rehber.
- Bunlar §1 madde 1 ve §2'deki "önerilen kadro" için iki şey söylüyor. (a) Önerilen kadro seçilen özellik sayısıyla 4-6 kat değişiyor ("Base" ile "Complete" arasında: ofis yazılımı 2/2/1 ile 8/12/5, bilgisayar OS 5/8/0 ile 13/24/1). §1'deki "Oyun 5-8-7, Ofis 4-8-2" Alpha 10'un "hepsini seç" satırıydı; sabit bir sayı değil. (b) Üst sınır yok gibi: en büyüğü 13/25/1 yani yaklaşık 39 kişi (yasadışı özellikler dahil); wiki'nin "10-12 kişilik ekip" tavsiyesi bu kadroların ekip bölünmesi anlamına geliyor.
- Max's Beginners Guide: "ekipler projenin etkinliğini en yükseğe çıkarmak için yaklaşık 10-12 kişi olmalı"; örnek çok rollü ekip 2 tasarımcı, 5 programcı, 1 sanatçı; çoklu ekip cezaları azaltıldı, 30 kişilik iş için 10'ar kişilik üç ekip "büyük sorun değil"; tek rollü ekipler izin süresi en yükseğe alınarak %85-95 dolulukta tutulabilir. Lider: "liderin başkalarının etkinliğini artırma yeteneğini" etkiler, uzmanlığı yok, yalnız genel beceri kazanır; kendi odası varsa bonus alır. Sözleşmelerde hata başına ceza var; hızlı yayınla. Dış inceleme: ürün başına 100 birim, yayın öncesi kalite okuması verir. Hosting/sunucu yük formülü rehberde yok (yalnız sunucu odası gürültülü, bodrumda olsun). Kaynak: https://steamcommunity.com/sharedfiles/filedetails/?id=1198857114 (oyuncu).
- Mentorluk (sürüm 1.8.8'den): mentor rol panelinde "mentor" olarak ayarlanır; mentor işini bırakıp çalışanın yanına gider (sohbet davranışına benzer); mentorlanan çalışanın etkinliği o sırada düşer; mentorun ana rolü, mentorlanan çalışanın o anki iş türüyle eşleşmeli (ikincil rol yetmez). Beceri artış hızı, süre ve etkinlik kaybı için sayı verilmemiş; yazar "hız mentorun becerisine bağlı mı" sorusunu açık bırakmış. Kaynak: https://steamcommunity.com/sharedfiles/filedetails/?id=3346380182 (oyuncu).
- LatN's Strategy (Alpha 11.5 ve 11.7.26 dönemi, oyuncu stratejisi): destek ekibini iki vardiyaya böl ("Support am" ve "Support pm", her biri iki orta maaşlı iki yıldızlı çalışan), "iki destek ekibini aynı anda porta ya da hata ayıklamaya atama, bilet kaçırırsın"; sistem programlama becerili destek çalışanı port ekibi olarak da işe yarar; 100.000'den fazla aktif kullanıcıda bütün işletim sistemlerine port, öncelik 10. Beta'ya geçince hata ayıklamak için yayın tarihi 6-7 ay sonraya konur; sözleşmeyi eğitim için kullanırsan hata ayıklamaya 2-3 ay ayır. Liderler için HR, Automation, Socialization, Multitasking uzmanlıkları. Pazarlama için am ve pm takımları onar kişiye kadar büyütülüyor. Kaynak: https://steamcommunity.com/sharedfiles/filedetails/?id=1971495059 (oyuncu).

### 7.3 Hosting sözleşmesi (R6 ile ortak)

- Steam hata raporu (Ocak 2021, sürüm Alpha 10.10.11): oyuncu iki hosting sözleşmesiyle (MB başına saatlik 2,53 ve 2,36) 600-900 Mbps trafik için 43 sunucu gerekti, aylık yaklaşık 100.000 beklerken zarar etti; "maksimum bant genişliği kullanımı" ifadesi yanıltıcıydı (kullanım 82,8, sunucular yaklaşık on kat fazlasını taşıyor ama ek gelir yok); 1982-83'te iflas. Moderatör: oyuncu eski Alpha 10'daydı, beta dalı (Alpha 11.7) sözleşmeleri yeniden yazdı; "maksimum bant genişliği" ürün tam potansiyele ulaşırsa olacak değerdir ve oyun hiçbir zaman tam ulaşmaz; bant genişliği aktif kullanıcıyla dalgalanır; hosting erken oyunda düşük bant ve yüksek ilk maliyetle zarar yazar, geç oyunda kârlı olur; sözleşme ödemesi iş itibarına bağlı. Kaynak: https://steamcommunity.com/app/362620/discussions/1/3016815718822912355/ (oyuncu + moderatör).

### 7.4 Oyuncuya gösterim: ekran görüntüsünden okunan (kapanan boşluk: "özelliklerin oyuncuya gösterimi", kısmen)

Mağazadaki görüntülerden yedisinin içeriğine baktım; yalnız biri arayüz gösteriyor: https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/362620/ss_a3008f0189f7ee81f9c9fbf6cb8edccaf42c3223.1920x1080.jpg?t=1763102408 . Bu görüntüde (Şubat 1980):
- Çalışan penceresi: kişilik özellikleri ikon+etiket olarak ("This is fine", "Sunshine", "Stressed", "Slow eater"; yanında "Short-tempered, Naive" etiketleri); "Relationships" listesi iş arkadaşlarıyla uyumu yüzde olarak gösteriyor (Compatibility: 65%, 77,5%); "Thoughts" bölümünde "Satisfaction" çubukları cümleyle ("There is nowhere to sit" kırmızı, "I'm very happy with my salary" yeşil, "I dislike a team member" kırmızı, "I'm happy with my benefits" yeşil, "There's nothing to do"); altta "Work affecters" başlığı: "Effectiveness" ve "Team Compatibility" çubukları. Yani verim, nedenleri listelenmiş yeşil/kırmızı çubuklarla gösteriliyor, tek sayı yok.
- Tasarım belgesi: "Market targeting - Console Operating System" üçgeni (Simplicity, Security, Customization köşeleri), "Market satisfaction" çubukları (her eksen için ayrı), "ETA: Less than a year", "Recommended designers 6/3". Son ifade, önerilen kadro ile atanan kadroyu "6/3" biçiminde gösteriyor olabilir (benim yorumum; görüntüde etiketin anlamı yazmıyor). Üstte "Issues" listesi: "An employee is having trouble finding a place to sit (3)".
- Üretim zinciri: sağ altta donanım üretim ağı (Plastic, Drive, Case, Motherboard... Final assembly) her düğümde "Printers: 0/2 Cost: $10 8 minutes" ve "Assemblers 0/1 4 minutes".
- Diğer görüntüler: kurucu oluşturma ve harita seçimi ekranı (haritada "Talent pool: High", "Plot cost: Medium", "Internet provider cost: Low", "Utilities cost: Low"), Build mode ekranı (odanın "Effectiveness: -10%" etiketi, "Area 28 m2"), şehir ve ofis dış görünümleri, sunucu/üretim katı.
- URL listesi (Software Inc, mağaza sırasıyla; yukarıdaki arayüz görüntüsü dördüncü):
  1. https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/362620/ss_6949cb0d8e6428424c5466b866b7293002fde71f.1920x1080.jpg?t=1763102408 (küçük ofis kesiti, arayüzsüz)
  2. https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/362620/ss_5683ee45fd1627b7ed405361be2eee07a0395a88.1920x1080.jpg?t=1763102408 (bina dış görünüm, arayüzsüz)
  3. https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/362620/ss_ed2ed5c00cf6e6feb75faa3e27107c93eaab7aa6.1920x1080.jpg?t=1763102408 (Build mode)
  4. https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/362620/ss_a3008f0189f7ee81f9c9fbf6cb8edccaf42c3223.1920x1080.jpg?t=1763102408 (çalışan memnuniyeti, tasarım belgesi, üretim zinciri)
  5. https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/362620/ss_af63b804af54dcf0edeb90cc1171cf62b88a920f.1920x1080.jpg?t=1763102408 (kurucu ve harita seçimi)
  6. https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/362620/ss_1d47fba62ef9deebdc531ca05560934e5a19f0bd.1920x1080.jpg?t=1763102408 (sunucu/üretim katı; "Main Server", "Source Control Server", "Backup Server" etiketleri)
  7. https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/362620/ss_edd6dc85e955d2f50de8dd4fea7e2a91603cea69.1920x1080.jpg?t=1763102408 (şehir ve bina görünümü)
  (Mağaza sayfasında küçük 116x65 önizlemeler listeleniyor; yukarıdaki URL'lerde boyut son eki 1920x1080'e çevrildi, ilki HTTP 200 döndü.)

### 7.5 Bu tamamlamanın §6 listesine etkisi

- Kapandı: ekran görüntüsü URL'leri; Steam rehberleri (Recommended Team Sizes iki sürüm, Mentoring, LatN); resmi wiki'nin sayfa listesi.
- Hâlâ bulunamadı: çalışan etkinliği formülü, hata üretim formülü, test/QA paralelleşmesi sayıları, Alpha 11 yıldız eşikleri, Kasım 2025 müşteri yorum sistemi, Reddit (bu turda denenmedi), SteamDB patch notları. Oyun içi "Quality" ve "Bugs" kavramları için resmi bir doküman yok; wiki'nin 30 sayfalık listesi bunu kesinleştiriyor.
