# A1 · Oyun dökümü 1: yönetim ve tycoon oyunlarında atama

Faz D, Atama araştırması. Hazırlayan: araştırma ajanı (Sonnet 5.5), 2026-10-20. Erişim tarihi bütün kaynaklarda 2026-10-20.
Bütçe: 18 / 18 WebSearch kullanıldı (biri alan adı hatasıyla boş döndü, yine de sayıldı), 24 / 25 WebFetch kullanıldı (dördü hata verdi, biri boş sayfa döndü). Bütçe bitti, durdum. Kanıtsız kalan hükümler "belirsiz (kanıtsız)" yazıldı.

Etiketler: [BOŞLUK] kanıtsız yük taşıyan iddia, [SIÇRAMA] kanıttan çıkmayan sonuç, [DEĞERLENDİREMEM], [GÖRÜŞ] benim yargım. (varsayım A#) işaretli olgu yok; her olgu bir S# taşıyor.

ÖNEMLİ KANIT UYARISI: WebFetch çıktıları küçük bir model tarafından özetlenmiş sayfalardır, sayfanın kendisi değildir. Tırnak içi sözler bu özetlerden gelir; kelimesi kelimesine doğrulanmadı. "Düşük" güvenli kaynaklar yalnız arama özetidir, sayfa açılmadı. Bütün kaynaklar topluluk görüşü ya da topluluk wikisidir; hiçbiri bu oyunların resmi tasarım belgesi değildir (S21 ve S16 geliştirici cümlesi taşıyor, onlar da tek başlıktır).

---

## 0. Erdem için özet

1. Erdem'in tarifi (kart başına gereksinim, en iyi kişiler bitene kadar, en düşük yeterli beceri küçük işe, kimse boşta kalmaz) bu beş oyunda bire bir uygulanmış halde bulunamadı. İncelenen oyunlarda atamanın birimi "iş" değil: Software Inc'de takım ve rol ayarı [S2, S10, S9], Mad Games Tycoon 2'de oda [S21, S22], Two Point oyunlarında kişi başına "hangi oda tipinde çalışır" kısıtı [S25, S26], Game Dev Tycoon'da aşama başına kişi seçimi (yalnız orta ve büyük oyunlarda) [S14, S15]. Bu bir "yok" iddiası değil; bulduklarımın içinde yok.
2. Hepsinde ikili yapı var: oyuncu kaba birimi elle kurar, gerisini oyun yapar. MGT2'de odasız çalışanı yapay zeka dolaştırır, istemeyen odayı kilitler [S21]. Startup Company'de yönetici üretim planıyla çalışanları çalıştırır [S16, S17]. Software Inc'de lider işi takıma dağıtır [S10, S11 (Düşük)].
3. Devredilen katman her oyunda "neden çalışmıyor" sorusu üretiyor: Startup'ta yönetici boşta [S16, S18], Software Inc'de ikincil görev "çalışmıyor" [S4], MGT2'de çalışan başka odaya oturuyor [S23 (Düşük)]. Ortak neden: oyuncu devredilen şeyin kuralını göremiyor. [GÖRÜŞ] Erdem'in kuralı (en iyi kişi, en düşük yeterli beceri) yazıldığı için bu sorunu çözebilir; ama kuralın sonucu ekranda okunmalı.
4. Boşta kalma Software Inc'de yapısal ve maaşı ödenen bir şey; tasarımın doğal sonucu (tasarımcı ilk, programcı sonra çalışır) [S2, S6, S8]. Oyuncular boşluğun nedeni okunduğunda kabul ediyor ("sanatçılar aylarca kanepede uyusa sorun değil" [S7]), okunmadığında hata sanıyor (boşta tasarımcı "bug mı?" [S9], "çalışanlar şikâyet ediyor: yapacak iş yok" [S8]).
5. Boşta kalan çalışana ekran cezası/ipucu: Software Inc'de "Zzzz" baloncuğu [S1], "atanan işlere uygun değil" etiketi [S6], "kendini işe yaramaz hissediyor" cezası [S2]. Two Point Campus'ta Durum sütunu yalnız o anki işi gösteriyor [S25]. İleriye dönük "şu planda darboğaz olur" gösterimi bu oyunlarda bulunamadı; var olanlar sonradan teşhis: etiket, uyumluluk yüzdesi [S5], takım için önerilen rol sayısı [S2].
6. Ölçekte şikâyet "atama" değil "genel bakış yok / tek tek tıklama": Two Point Campus'ta "tek tek tıklayıp kaldırıyorum, toplu yok" ve TPH'deki Personel Çizelgesi'nin geri istenmesi [S25]; Software Inc'de vardiya ve iş kuyruğu için "çok tıklama ve mikro yönetim" [S3]; Startup'ta mikro yönetim yüzünden iade [S17]. Bu şikâyetlerin hepsi ekip ve iş sayısı büyüdüğünde ortaya çıkıyor (net kişi sayısı kaynaklarda yok).
7. Yapımcılar tepki verdi: Startup'ta kuyruk ve ortak üretim planı ve toplu eylemler eklendi [S19 (Düşük)]; MGT2'de oda kilidi anlatıldı, hareket kaydırıcısı istendi [S21]; Two Point Campus'a İş Atama ekranı yamayla geldi [S28 (Düşük)]. Software Inc ikincil görevinde geliştirici yanıtı bulunamadı [S4].
8. Ekip büyüklüğü sınırları oyunların içinde belirgin: Software Inc'de takım 10 ila 12 kişide verimli, 200 kişilik tek ekip zorlaşıyor [S2], oyuncular 2 ila 8 ya da 10 ila 15 kullanıyor [S5]; MGT2'de oda 10 civarı, 20+ odada yapay zeka yol bulmayı bozabilir [S22 (Düşük)]; Game Dev Tycoon'da 5 kişide kullanım %60 ila %90+ dağılıyor, bir kişiyi atınca %85 ila %110'a oturuyor (tartışmalı) [S12].
9. [GÖRÜŞ] Kanıt Erdem'in ilk düşüncesiyle (küçük ve orta ekipte elle, büyükte devret) uyumlu; ama eşik ve "devretmek" tanımı bu oyunlardan çıkmıyor. Devredilecek şeyin kendisi Erdem'in kuralı olabilir: "sistem" ve "PM" aynı kuralı çalıştırır, fark kimin tuşa bastığıdır [GÖRÜŞ, S21 kilit örneğine dayanarak].
10. Açık boşluklar: Reddit erişilemedi (alan adı hatası), Fandom wikileri 402 verdi, resmi Software Inc wikisi atamayı açıklamıyor ("iş kalemi ataması anlatılmıyor" [S2]). Game Dev Story ve Big Pharma için ayrıntı bulunamadı (bütçe).

---

## 1. Kaynak sicili

| S# | URL | Yayıncı | Yayın tarihi | Erişim | Güven |
|---|---|---|---|---|---|
| S1 | https://steamcommunity.com/app/362620/discussions/0/133259227517675456 | Steam forumu, Software Inc | 9 Mar 2017 ve 22-23 Tem 2017 | 2026-10-20 | Orta (oyuncu görüşü, dolaylı alıntı) |
| S2 | https://softwareinc.coredumping.com/wiki/index.php/Teams | Software Inc topluluk wikisi (Coredumping sitesinde), "WORK IN PROGRESS" | Alpha 10.5.1 için güncel | 2026-10-20 | Orta |
| S3 | https://steamcommunity.com/app/362620/discussions/0/1728701877496608523/ ("Shifts and Work Queues") | Steam forumu | 2 Tem 2018 | 2026-10-20 | Orta |
| S4 | https://steamcommunity.com/app/362620/discussions/0/1754654427605814281/ ("Secondary Tasks") | Steam forumu | 9 Mar 2020 ila 25 Ağu 2023 | 2026-10-20 | Orta |
| S5 | https://steamcommunity.com/app/362620/discussions/0/3043859512577102123/ ("How do you organize your teams?") | Steam forumu | 13 Eyl 2021 ila 19 Kas 2021 | 2026-10-20 | Orta |
| S6 | https://steamcommunity.com/app/362620/discussions/0/133256959375679794/ ("Problem with employees not qualified") | Steam forumu | 12-13 Şub 2017 | 2026-10-20 | Orta |
| S7 | https://steamcommunity.com/app/362620/discussions/0/2119355556482487720/ ("optimal team layout") | Steam forumu | 16-18 Haz 2017 | 2026-10-20 | Orta |
| S8 | https://steamcommunity.com/app/362620/discussions/0/2972901817712719181/ ("Employees always complain about 'There's nothing to do'") | Steam forumu | 28-29 Kas 2020 | 2026-10-20 | Orta |
| S9 | https://steamcommunity.com/app/362620/discussions/0/1699416432415903852/ ("Idle Employee") | Steam forumu | 8-13 Şub 2018 | 2026-10-20 | Orta |
| S10 | https://softwareinc.coredumping.com/wiki/index.php/Project_Management | Software Inc topluluk wikisi, "WORK IN PROGRESS" | Alpha 10.10 için güncel, son düzenleme 16 Mar 2019 | 2026-10-20 | Orta |
| S11 | https://softwareinc.coredumping.com/wiki/index.php/Staff , https://softwareinc.coredumping.com/wiki/index.php/Beginner's_Tips , https://softwareinc.coredumping.com/2015/01/ (yalnız arama özeti, sayfalar açılmadı) | Coredumping geliştirici blogu ve wiki | 2015 (blog) | 2026-10-20 | Düşük |
| S12 | https://steamcommunity.com/app/239820/discussions/0/864977564029712433 ("Game says I need to focus my team?") | Steam forumu, Game Dev Tycoon | 29 Ağu 2013 ila 7 Ağu 2016 | 2026-10-20 | Orta |
| S13 | https://steamcommunity.com/app/239820/discussions/0/4286936944582902295 (başlık özette yok) | Steam forumu, Game Dev Tycoon | 22-23 Mar 2024 ve 16-20 May 2024 | 2026-10-20 | Orta |
| S14 | https://steamcommunity.com/app/239820/discussions/0/2245553353026763840/ ("Can't assign workers to game?") | Steam forumu, Game Dev Tycoon | 22-29 May 2020 | 2026-10-20 | Orta |
| S15 | https://steamcommunity.com/app/239820/discussions/0/666827315571369354/ , https://steamcommunity.com/app/239820/discussions/0/864977564187720146/ , https://steamcommunity.com/app/239820/discussions/0/540743212931023727/ , https://steamcommunity.com/app/239820/discussions/0/312265327166338579/ (yalnız arama özeti) | Steam forumu, Game Dev Tycoon | yaklaşık 2013-2015 | 2026-10-20 | Düşük |
| S16 | https://steamcommunity.com/app/606800/discussions/0/2566438387959529340/ ("Managers always idle?") | Steam forumu, Startup Company; geliştirici Jonas (Hovgaard Games) yanıtı | 27-28 Haz 2020 | 2026-10-20 | Yüksek (geliştirici cümlesi, tek başlık) |
| S17 | https://steamcommunity.com/app/606800/discussions/0/4086396624006160021 ("Automation ?") | Steam forumu, Startup Company | 15-16 Nis 2020 | 2026-10-20 | Orta |
| S18 | https://steamcommunity.com/app/606800/discussions/0/1736589519997369074/ ("Tips and Tricks [OUTDATED]") | Steam forumu, Startup Company | 31 Ağu 2018 ila 10 Haz 2020 | 2026-10-20 | Orta (başlıkta "OUTDATED") |
| S19 | https://steamcommunity.com/games/606800/announcements/detail/1701691064582281128 (Beta 18), https://steamcommunity.com/games/606800/announcements/detail/3692292987278782680 (Devlog #40) ve arama sonucundaki öteki duyurular. Sayfa açılamadı (içerik boş geldi), yalnız arama özeti | Hovgaard Games, Steam duyuruları | 2017-2021 aralığı | 2026-10-20 | Düşük (resmi kaynak ama yalnız ikinci el özet) |
| S20 | https://steamcommunity.com/app/606800/discussions/0/1471967615884165418/ ("FEATURE/CHANGE REQUESTS"), https://steamcommunity.com/app/606800/discussions/0/1471967615878120865/ ("Starting Out Tips") (yalnız arama özeti) | Steam forumu, Startup Company | belirsiz | 2026-10-20 | Düşük |
| S21 | https://steamcommunity.com/app/1342330/discussions/0/3079873089690886002/ ("What is Employes controled by AI do ? Eggcode") | Steam forumu, Mad Games Tycoon 2; geliştirici Eggcode Games yanıtı | 24-25 Mar 2021 | 2026-10-20 | Yüksek (geliştirici cümlesi, tek başlık) |
| S22 | https://steamcommunity.com/app/1342330/discussions/0/4357870314534527235 , https://steamcommunity.com/app/1342330/discussions/0/3040481180142749588 , https://steamcommunity.com/app/1342330/discussions/0/3058492406517208479 , https://steamcommunity.com/app/1342330/discussions/0/4034727291135746253 (yalnız arama özeti) | Steam forumu, MGT2 | belirsiz | 2026-10-20 | Düşük |
| S23 | https://steamcommunity.com/app/1342330/discussions/0/5358712989057205022/ , https://steamcommunity.com/app/341000/discussions/0/154642857137193386/ ("Autoassign employees ? Make it stop !", ilk oyun) (yalnız arama özeti) | Steam forumu, MGT / MGT2 | belirsiz | 2026-10-20 | Düşük |
| S24 | https://steamcommunity.com/app/1342330/discussions/0/600777838736475223/ , https://steamcommunity.com/app/1342330/discussions/0/4632611455209870802/ , https://store.steampowered.com/app/1342330/Mad_Games_Tycoon_2/ (yalnız arama özeti) | Steam forumu ve mağaza sayfası | belirsiz | 2026-10-20 | Düşük |
| S25 | https://steamcommunity.com/app/1649080/discussions/0/3435704300832619229/ ("Assiging Staff to Rooms") | Steam forumu, Two Point Campus | 23 Ağu - 7 Eyl 2022 | 2026-10-20 | Orta |
| S26 | https://steamcommunity.com/app/535930/discussions/0/1737715419896822540/ ("Ability to assign staff to rooms?") | Steam forumu, Two Point Hospital | 31 Ağu 2018 | 2026-10-20 | Orta |
| S27 | https://steamcommunity.com/app/535930/discussions/0/2590022385667031315/ , https://steamcommunity.com/app/535930/discussions/0/4931994385946569702/ , https://steamcommunity.com/app/1649080/discussions/0/3461598818983991986/ (yalnız arama özeti) | Steam forumu, TPH ve TPC | belirsiz (TPC başlıkları 2024-2025 olarak özetlenmiş) | 2026-10-20 | Düşük |
| S28 | https://www.thesixthaxis.com/?p=401700 (TPC 1.5), https://mp1st.com/news/two-point-campus-update-1-17-released-for-fixes-this-march-27 (TPC 1.17, 27 Mar 2023) (yalnız arama özeti) | Haber siteleri | 1.17: 27 Mar 2023; 1.5: bulunamadı | 2026-10-20 | Düşük |
| S29 | https://kairosoft.wiki.gg/wiki/Careers_(Game_Dev_Story) , https://giantbomb.com/wiki/Games/Game_Dev_Story (yalnız arama özeti) | Topluluk wikileri | belirsiz | 2026-10-20 | Düşük |
| S30 | https://steamcommunity.com/app/535930/discussions/0/2590022385654139989/ , https://gameplay.tips/guides/2894-two-point-hospital.html (yalnız arama özeti) | Steam forumu, rehber sitesi | belirsiz | 2026-10-20 | Düşük |

Not: Fandom wikileri (softwareinc.fandom.com, gamedevtycoon.fandom.com) 402 verdi, softwareinc.coredumping.com/wiki/Teams ve Main_Page 404 verdi; gerçek adres `index.php/` içerenler (S2, S10).

---

## 2. Oyun oyun döküm

### 2.1 Software Inc. (Coredumping)

**Kural: işi kim atıyor?**
- Oyuncu ürünü bir veya birkaç takıma verir; takım içinde her çalışanın rol ayarı vardır: tek rol (programcı, sanatçı, tasarımcı) ya da "her iş" [S6, S9]. Aynı çalışana "programlama + tasarım" gibi birleşik rol verilemez ("oyun şimdilik hangi rolleri yapabileceğini seçtirmiyor", 2017) [S6]. Bu 2017 tarihli; sonraki sürümde ikincil rol eklendi [S4].
- Kimin neyi alacağını oyuncu takım ve rol ayarıyla dolaylı belirler; iş kalemine tek tek kişi atama görülmedi. Wiki iş kalemi atamasını açıklamıyor [S2, S10]. [DEĞERLENDİREMEM]: iç algoritma (kim hangi kalemi alır) hiçbir kaynakta anlatılmıyor.
- Lider (Lead) rolü: yalnız "Lider" ayarında lider odasında oturur, ofiste dolaşıp konuşur; "Lider (Hepsi)" ayarında işe de katılır [S1]. Wiki'nin Proje Yönetimi sayfası liderin maaş ve şikâyetleri yönetmesini ve işin takıma verilince "3-4 sözleşmeden sonra kendi kendine gitmesini" anlatıyor, işleyişi açıklamıyor [S10]. Geliştirici blogunun (arama özeti) liderin üretim döngüsünü devralıp seçilen takımlara görev dağıttığını söylediği bildirilmiş; sayfa açılmadı [S11 (Düşük)].
- Proje önceliği: her projenin yanında sıra numarası ve yukarı/aşağı okları var; oyuncu bunun "sıraya dizme mi, çabayı oranlama mı" olduğunu bilmiyor, bir oyuncu stresli projeleri duraklatıyor [S3].

**Ekran: oyuncu neyi görüyor?**
- Ofiste boşta lider "Zzzz" baloncuğuyla [S1].
- Rol ayarı olmayan işte çalışan "atanan işlere uygun değil" (not qualified) etiketiyle durur [S6].
- İşe alırken ve taşırken üstüne gelince uyumluluk yüzdesi görünür; bir oyuncu "125% ya da daha iyiyse taşırım" diyor [S5].
- Takım ayrıntı sekmesinde oyunun önerdiği tasarımcı-programcı-sanatçı sayısı yazar (örnek 1980 oyunu: 2-3-2) [S2].
- Genel bakış ya da "bu plan yetişmez" öngörüsü: bulunamadı.

**1 kişide:** Kurucu her rolü yapar; ayrıntı bulunamadı [BOŞLUK]. **10 kişide:** takımlar 10-12 kişi öneriliyor [S2]; oyuncular 2-8 ya da 10-15 [S5]. **50+ ve 200+ kişide:** "200 kişinin tek kod üzerinde çalışması giderek zor" [S2]; ayrı destek, pazarlama, hata düzeltme takımları ürünler arasında kaydırılıyor (3-7 ürün) [S5]; vardiya için ayrı takım gerekiyor, her değişiklik her vardiya takımında tekrarlanıyor [S3].

**Beceri/uzmanlık eşleşmesi:** Var. Rol bazlı; sanat "kazanması en zor, eksikliği en zararlı" [S2]. Karma rol çalışanları kötü işi "mahveder" [S6 (özet: "tüm roller" ayarı yeterli olmadıkları alanda kötü iş üretir)].

**Boşta kalan çalışan:** Görünür ve maaşı ödenir [S6]. Neden: faz sırası; tasarımcılar önce, programcılar sonra çalışır [S6, S8, S9]. Ceza: "kendini işe yaramaz hissediyor" cezası; yedek takım ve İK eğitimiyle azaltılabilir [S2]; sıkılma moral kaybı [S8]. Çözümler oyuncudan geliyor: dış sözleşme, çapraz eğitim, birden fazla proje [S5, S6, S8].

**Darboğaz öngörüsü:** Bulunamadı.

**Övülen:** Takım+rol ayarını "bir kere kur, gitsin" diye kullananlar var (örnek: 3 yıldızlı İK lideri uyumluluğa göre kendisi işe alıyor, uzmanlıkları dengeliyor [S5]). Ürün başına tek takım tavsiyesi [S7].
**Kızılan:** Boşta kalma mantığı yeni oyuncuya sezgisel gelmiyor [S7, S8]; vardiya ve iş kuyruğu için çok tıklama [S3]; ikincil görev takımı "yalnız kendine atanan işte çalışıyor, öteki takıma yardım etmiyor, fazla mikro yönetim" (2023) [S4]; ikincil görev özelliğinin kullanımı belirsiz ve hatalı olabilir, geliştirici yanıtı yok [S4].

**Neden var (tasarım gerekçesi):** Wiki ve forum bu konuda gerekçeyi açıkça söylemiyor. Faz sırası ve takım büyüklüğü verimi ürünün gerçekçilik hedefinden geliyor görünüyor [GÖRÜŞ; kaynak yok, S2'deki "diseconomies of scale" cümlesinden çıkarım].

**Yapımcı sonradan değiştirdi mi?** İkincil rol/görev eklendi (2020 civarı, test dalı 11.7.17 anılıyor) [S4]; "Lead (Any)" seçeneği 2017'de mevcut [S1]. Atamanın kaldırıldığı bir yama bulunamadı.

### 2.2 Game Dev Tycoon (Greenheart Games)

**Kural:** Küçük oyunlarda personel rol seçmeden katkı verir; orta ve büyük oyunlarda oyuncu aşamalara kişi yerleştirir [S12 (Avalanche, 2013), S14 (2020)]. Bir oyuncu "kimseyi seçemezsiniz" demiş (muhtemelen küçük oyun) [S12]. Her yuvaya bir kişi: arama özetinde var, açılmadı [S15 (Düşük)]. Alan uzmanlığı (tür ve konu) seviye 7 civarı açılıyor [S12].
**Ekran:** Personel çubuğu: "boş = kötü, dolu = iyi", boş çubuk tatil ister [S12]; kullanım yüzdesi (iş yükü).
**Ölçek:** 1 kişi: yalnız kurucu. Personel üst sınırı: 2024 başlığında "izin verilen dört çalışan" [S13] (kaynağa göre tavan değişebilir, kesin değil). 5 kişide kullanım %60 ila %90+ saçıldı, birini atınca %85 ila %110 [S12]; başka oyuncu bunu "yeni işe alınanlar birkaç oyunda alışır" diye açıklıyor [S12]. 10, 25, 50 kişi: bu oyunda yok.
**Beceri eşleşmesi:** Tasarım ağırlıklı personeli hikâye/diyalog, teknik ağırlıklıyı motor/yapay zekâya koy [S13]; eğitim şart [S12]; yeni işe alınan düşük beceriyle çok az üretir [S12].
**Boşta:** "tüm takımı odaklayın" uyarısı: orta ve büyük oyunda herkesin katkı vermesi gerekir [S12]. Uyarı bazı oyuncularda anlaşılmaz (hiçbir yan iş atamadan çıktı) [S12].
**Darboğaz öngörüsü:** Bulunamadı.
**Övülen:** Bulunamadı (yalnız strateji tavsiyeleri). **Kızılan:** personel çalışmıyor/katkı üretmiyor raporları (kayıt hatası ya da yorgunluk), %100 üstü iş yükünün sonucu görünmüyor [S15 (Düşük)].
**Neden var:** Kaynak bulunamadı.
**Yapımcı değişikliği:** Bulunamadı.

### 2.3 Startup Company (Hovgaard Games)

**Kural:** Oyuncu çalışana doğrudan iş (kuyruk/tekrar) verir; yönetici (Manager) bir "üretim planı" ve stok hedefleriyle çalışanları çalıştırır [S16, S17, S18]. Yönetici, gereken ara parçaları kendisi "otomatik atamaz" ("won't auto assign needed parts to be made"), oyuncu her kademe için stok hedefi ve ayrı üretim ekibi kurar ("4,2,1" düzeni) [S17]. Yöneticiyi iş türü başına (geliştirici için bir, baş geliştirici için bir) kurmak tavsiye [S18].
**Ekran:** Envanter ve stok penceresi; boşta çalışan işe geldiğinde evde ya da masada durur [S16]. Boşta nedeni teşhisi geliştirici tarafından üç madde: plan yöneticiye atanmamış, planda o çalışanın yapabileceği hedef yok (devkit açılmamış), girdi envanterde yok [S16].
**Ölçek:** 1 kişi: kurucu elle. 10-30 kişi: yönetici ve plan. 200 çalışan: bir oyuncu hepsine tek tuşla ikramiye istiyor [S20 (Düşük)]; toplu eylem listesi var: masadan al, kov, eve gönder, eğitimi başlat/durdur, yöneticiden çıkar (Beta 22) [S19 (Düşük)].
**Beceri eşleşmesi:** Var (geliştirici, baş geliştirici, tasarımcı, pazarlamacı rolleri; kademe: başlangıç, orta, uzman) [S17, S18].
**Boşta:** Görünür ve oyuncunun kovaladığı şey; bir veteranın başlangıç ipuçları "geliştiricileri asla boşta bırakma" diyor [S20 (Düşük, yalnız arama özeti)]. Yöneticiyi kullanınca boşta süresi yükselir (bir oyuncu) [S18].
**Darboğaz öngörüsü:** Bulunamadı.
**Övülen:** "Mikro yönetim oyunun asıl çekiciliği, yöneticiyi araştırmak yükü azaltır" [S17 (Bill)]. **Kızılan:** "Mikro yönetim fazlasıyla abartılı" diyerek iade eden oyuncu; eğitimi yetersiz buluyor [S17]. Bir oyuncu "stokta var ama boştayım" uyumsuzluğundan yakınıyor ("her zaman üretimi elle ayarlıyorum") [S18].
**Neden var:** Kaynak bulunamadı. Geliştirici cevapları teşhis veriyor, gerekçe vermiyor [S16].
**Yapımcı değişikliği:** Beta 18'de tüm üretim çalışanlarına kuyruk (yönetici alınamayan erken oyun için), Beta 22'de tekrar ve kuyruğun "Sonsuz Tekrarlayan Kuyruk"ta birleşmesi, Beta 24'te yöneticiler arasında paylaşılan üretim planı, 1.18'de üretim planları Envanter menüsünde ayrı sekme [S19 (Düşük, yalnız arama özeti; Beta 18 sayfası açıldığında içerik boştu)]. Sürüm 1 son içerik güncellemesi [S19].

### 2.4 Mad Games Tycoon 2 (Eggcode)

**Kural:** Oyuncu çalışanı odaya atar. Odaya atanmamış çalışanlar yapay zeka ile "odadan odaya koşup işleri yapar" (geliştirici: yalnız "çalışanlarınızı odalara atamak istemiyorsanız" gerekli) [S21]. Odayı kilitleyen oyuncu o odadaki çalışanları yapay zekadan çıkarır [S21]. Odalar birbirini "destekleyebilir"; 12 kişilik bir ekibi iki projeye bölmek için ikinci bir geliştirme odası kurmak gerekiyor [S22 (Düşük)]. Uzman odalarını yalnız uzmanla doldur tavsiyesi [S22 (Düşük)].
**Ekran:** Oda menüsü ve kilit simgesi; yapay zeka açma/kapama [S21, S23 (Düşük)]. Başka bir ekran bulunamadı.
**Ölçek:** 1 kişi: bulunamadı. Oda 10 kişiyle sınırlanıyor, 20+ oda "yapay zekânın yol bulmasını bozabilir" [S22 (Düşük)]. 500+ çalışanda düşük donanımlı PC'de gecikme [S24 (Düşük)]. Oyuncu kitle: 93% olumlu, 2170 inceleme (eski görüntü) [S24 (Düşük)].
**Beceri eşleşmesi:** Oda tipi (uzman oda); çalışan bazlı beceri eşleşmesi kaynakta bulunamadı.
**Boşta:** İlk oyunun yapay zekâsı "projesi olmayan odadaki boşta işçileri projesi olan odaya taşır" [S22, S23 (Düşük)]. MGT2'de de benzer biçimde odasız çalışanı yapay zekâ taşıyor [S21]. Bir oyuncu istenmeyen taşımayı ayarlamak için "hareket kaydırıcısı" önerdi (0% hiç gitmesin, 100% her zaman gitsin) [S21].
**Darboğaz öngörüsü:** Bulunamadı.
**Övülen:** Kilit özelliğini geliştirici anlatınca soran oyuncu teşekkür etti [S21]. **Kızılan:** başka odanın çalışanları atanmadıkları odada işe oturuyor (geliştiriciye göre "optimize edilmiş yapay zekâ" yüzünden) [S23 (Düşük)].
**Neden var:** Geliştirici yanıtı: yapay zekâ atamayı istemeyen oyuncu için [S21].
**Yapımcı değişikliği:** Kilit özelliği mevcut ve anlatılmış [S21]; kaydırıcı önerisine geliştirici yanıtı bulunamadı [S21].

### 2.5 Two Point Hospital ve Two Point Campus

**Kural (TPH, 2018):** Her kişinin "İşler" penceresi var; çalışan oda TİPİNE kısıtlanır, belirli bir odaya değil: "hemşireler yalnız koğuş, bazı doktorlar yalnız GP" [S26]. Boşta personel "boşta odadan çıkar" politikası kapatılarak odada tutulabilir [S27 (Düşük)]. En iyi personeli kritik odaya kısıtlamak oyuncu tavsiyesi [S30 (Düşük)].
**Kural (TPC, 2022):** Aynı kişi başı kısıt; asistanların çok işi var (revir, kütüphane, pastoral, işe alım...) [S25].
**Ekran:** TPH'de "Personel Çizelgesi" genel bakışı vardı ve oyuncular onu övüyor ("TPH'de gerçekten iyi çalışıyordu") [S25]. TPC'de (Ağustos 2022 başlığında) yok: Durum sütunu o anki işi gösterir, tüm atamaları göstermez [S25]. TPC Güncelleme 1.5 "İş Atama ekranı"nı ekledi (haber özeti; bunun TPH'deki çizelgeyle aynı olup olmadığı bilinmiyor) [S28 (Düşük)]. 1.17 yeni eğitimli personelde atamaların kapanması hatasını düzeltti [S28 (Düşük)].
**Ölçek:** 1 kişide: bulunamadı. Büyük kampüste: "kişi kişi tıklayıp kaldırıyorum, toplu seçim yok" [S25]. Çözüm: oda tipi başına bir asistan ayırmak [S25].
**Beceri eşleşmesi:** Eğitimle yetkinlik; atama kısıtla ayrı [S30 (Düşük)].
**Boşta:** Boşta personel odadan çıkıp yürür; hemşire revirden çıkıp kulüp işe alımına gidebiliyor, çünkü işe alım listenin altında işaretli kalmış [S25].
**Darboğaz öngörüsü:** Bulunamadı.
**Övülen:** TPH'nin atama çizelgesi [S25]. **Kızılan:** TPC'de genel bakış yokluğu, "can sıkıcı" (a pain), toplu seçim yok [S25]; atamadaki yanlış işaret yüzünden personelin yanlış iş yapması [S25].
**Neden var:** Bulunamadı.
**Yapımcı değişikliği:** Evet, TPC'ye yamayla iş atama ekranı geldi [S28 (Düşük)].

### 2.6 Yakın emsal: Game Dev Story (Kairosoft)

Personelin dört özelliği (programlama, senaryo, grafik, ses) var ve her biri gelişimin ayrı aşamasında işe yarıyor; %40 ve %80 noktasında grafik/ses için kişi seçilir; aynı kişiyi tekrar tekrar seçmek tükenmişlik yaratır [S29 (Düşük)]. Boşta personel kaynakta bulunamadı. Big Pharma: bütçe nedeniyle aranmadı.

---

## 3. Başarısız ve eleştirilen örnekler (ayrı bölüm)

Bu bölümdeki başlıklar ayrı sorgularla ve ayrı fetch'lerle toplandı (sorgular: 7, 8, 9, 10, 11, 12, 13, 15, 17, 18; sonuç sayıları arama günlüğünde).

1. Software Inc, ikincil görev: "tüm çalışanlarım ... ikincil iş bitince ya da uygun olmayınca boşta" (2020) ve "takım yalnız kendine atanan işte çalışıyor, fazla mikro yönetim" (2023). Geliştirici yanıtı yok [S4].
2. Software Inc, boşta çalışan: "uygun değil" etiketiyle 12 eğitimli çalışan boşta (2017) [S6]; maaş ödenirken boşta tutmak yerine bölmek daha pahalıya gelebilir [S6 (ploppo)]; yeni oyuncuya sezgisel değil [S7 (Jolii)]; "yapacak işleri yok" şikâyeti [S8]; bir boşta tasarımcı "bug" sanıldı, oysa faz bitmişti [S9].
3. Software Inc, çok iş/çoklu vardiya: kuyruk ve vardiya için "çok tıklama ve mikro yönetim" [S3].
4. Startup Company, yönetici/otomasyon: bir oyuncu mikro yönetim yüzünden oyunu iade etti [S17]; yönetici boşta ("plan atanmamış / hedef yok / girdi yok") [S16]; yönetici kullanınca boşta artıyor [S18]; "yönetici gerekli parçayı otomatik üretmez" [S17].
5. Mad Games Tycoon 2, yapay zekâ: atanmamış odaya oturma hatası; geliştirici "optimize edilmiş yapay zekâ" dedi [S23 (Düşük)]; çok büyük odalarda yol bulma [S22 (Düşük)]; atamayı bırakmak isteyen için "kilit" çözümü gerekti [S21].
6. Two Point Campus, atama arayüzü: genel bakış yokluğu, kişi kişi tıklama, listenin altında unutulan işaret yüzünden hemşirenin revirden çıkması [S25]. TPH'de "boşta odadan çık" politikası şikâyeti [S27 (Düşük)].
7. Game Dev Tycoon: "tüm takımı odaklayın" uyarısı anlaşılmıyor (2013) [S12]; bir oyuncunun beş kişilik ekipte verim dağılımı bozuk [S12].

Aranıp bulunamayan: "atama sistemi kaldırıldı / yamayla elle atama silindi" türü bir örnek; hiçbir oyun için bulamadım. "Otomatik atama aptal" için Software Inc'de iki yerde ima var ("Hepsi" ayarının kötü iş üretmesi [S6], Startup'ta yöneticinin ara parçayı üretmemesi [S17]) ama doğrudan "aptal" kelimesiyle şikâyet bulunamadı.

---

## 4. Üç soruya bu oyunlardan çıkan dersler

Ölçek notu: bu oyunlardan 1, 3, 6, 12, 25, 50 kişi için doğrudan veri yok. Aşağıda "kanıt" yalnız bulunan ölçekleri anlatır; eşlemeler [GÖRÜŞ].

### Soru 1: Atamayı kim yapar?

**Ders 1.1.** Dört oyunda da atama birimi kaba: takım+rol (Software Inc [S2, S6, S9]), oda (MGT2 [S21]), oda tipi kısıtı (Two Point [S26, S25]), aşama yuvası (Game Dev Tycoon [S14]). Hiçbirinde "kart başına kişi seç" bulunamadı.
- Ölçek kanıtı: Software Inc'de 10-12 kişilik takım önerisi [S2]; MGT2'de ~10 kişilik oda [S22 (Düşük)]. 1 kişi: kaynaklarda yok. 50 kişi: tek ekip değil çoklu takım/oda [S2, S5].
- [GÖRÜŞ] Unicorn'un bütün sprint planını tek atama olarak ele alması bu oyunlardan farklı ve daha ince bir birim; dolayısıyla bu oyunlardan "oyuncu elle yapabilir mi" sorusunun cevabı çıkmıyor [SIÇRAMA uyarısı: kanıt yok].

**Ders 1.2.** Otomatik katman her yerde "devret" tuşu ve çalışması için oyuncunun görmediği koşullar var; sorun çıktığında teşhis oyuncuya kalıyor: Startup'ta üç koşul [S16], Software Inc'de "uygun değil" [S6], MGT2'de yapay zekâ + kilit [S21].
- 1 kişi: devredilecek kimse yok (Startup'ta yönetici erken oyunda alınamadığı için kuyruk eklendi [S19 (Düşük)]).
- Küçük ekip: devir 2-3 çalışanlık planda bile boşta üretti (Startup [S16]); 12 kişilik veri bulunamadı.
- Büyük ekip (50 ve üstü için doğrudan veri yok): Startup'ta 200 çalışanlı oyuncu toplu eylem istedi [S20 (Düşük)], Software Inc'de 3 yıldızlı İK lideri işe alımı otomatikleştirdi [S5], TPC'de kişi kişi tıklamaktan şikâyet var [S25]. Yani büyük ekipte otomasyon isteniyor, genel bakış olmadan sinir bozuyor.
- [GÖRÜŞ] Erdem'in önerdiği "orta ekipte elle güzel olabilir; isteyen PM'e ya da sisteme bırakır" bu örüntüyle uyumlu. "Sistem" ve "PM" ayrı iki mekanik olmasın: ikisi de Erdem'in kuralını çalıştırsın; fark yalnız "kim çalıştırdı" ve PM'in yıldızına göre ne kadar iyi çalıştırdığı olsun (basitlik kuralı). Kaynak yok, ilke.

**Ders 1.3.** Oyuncu devri geri alabilmeli: MGT2'de oda kilidi, geliştirici bunu 2021'de açıkça anlatıyor [S21]; hareket kaydırıcısı talebi var [S21]. Software Inc'de "Lead" ve "Lead (Any)" ayrımı [S1]. [GÖRÜŞ] Kilit = "bu kart bitene kadar bu kişiler" Erdem'in kuralındaki "bitene kadar" kalma kuralıyla aynı şey olabilir.

### Soru 2: Boşta kalma ve verim

**Ders 2.1.** Software Inc'de boşta kalma tasarımın doğal sonucu (faz sırası) ve maaşı ödeniyor [S6, S8, S2]. Oyuncular bunu kabul ediyor, ama nedenini görebildikleri sürece ("sanatçılar kanepede uyuyabilir" [S7]); neden görünmeyince hata sanıyor [S9] veya şikâyet ediyor [S8].
- 1 kişi: boşta kalma yok sayılır (tek kişi her şeyi yapar), kaynak yok [BOŞLUK].
- 3-6: Software Inc'de küçük takımda tasarımcı bekler (örnek 2-3-2 takım [S2]); önerilen takım örneği 2-3-2, yani 7 kişi [S2].
- 12-25: oyuncular çapraz eğitim ve birden fazla proje ile boşluğu dolduruyor [S5, S6, S8].
- 50: yedek takım ve İK eğitimi "işe yaramaz hissetme" cezasını azaltıyor [S2].
- [GÖRÜŞ] Unicorn'da "kimse boşta kalmaz" kuralı var ve bu kural zaten Software Inc'deki en çok şikâyet edilen şeyi (nedeni görünmeyen boşluk) kapatıyor. Eğer kart sayısı/PM hazırlığı yetmez ve biri yine de boşta kalırsa, bunun nedenini ("bu hafta bu kişiye uygun kart yok") yazmak yeterli olabilir; yeni ceza mekaniği gerekmeyebilir. [DEĞERLENDİREMEM]: oyuncunun bunu "optimizasyon" olarak seveceğini gösteren bir kanıt bulamadım; Startup'ta "asla boşta bırakma" bir oyuncu alışkanlığı olarak var [S18] ama bunun keyifli mi angarya mı olduğu belirsiz (S17'de iade, S17'de "çekicilik" yan yana).

**Ders 2.2.** Verim kaybı, kişi sayısı arttıkça artıyor ve bu bilgi oyuncuya sayısal verilmiyor: Game Dev Tycoon'da 5 kişide kullanım dağılımı [S12], Software Inc'de takım büyüklüğü verimi [S2, S7: "tam önerilen sayı, fazlası kaliteyi düşürür"].
- [GÖRÜŞ] Bu Unicorn'da zaten düşünülmüş "ekip büyüdükçe verim" bahsine bağlanır; yeni sistem değil.

### Soru 3: Darboğaz gösterimi

**Ders 3.1.** İleriye dönük "bu planda darboğaz olur" gösterimi bu oyunlarda bulunamadı. Bulunanlar sonradan teşhis: "uygun değil" etiketi [S6], Startup'ta geliştirici teşhisi üç koşul [S16], takım için önerilen rol sayısı [S2], işe alırken uyumluluk yüzdesi [S5].
- [GÖRÜŞ] Boşluk bir fırsat olabilir: oyuncular tam da "nedeni bilmeden boşta" durumunda hata sanıyor [S9, S8, S16]. Ama gösterimin tek satırlık, mevcut plan ekranının içinde olması gerekir (Erdem'in "yeni sistem ekleme" kuralı). [DEĞERLENDİREMEM]: oyuncunun bunu isteyip istemediğine dair doğrudan kanıt bulamadım.
- Ölçek: 1 kişide gerek yok; 6+ kişide ilk anlamlı hâle gelir [GÖRÜŞ, kaynaksız eşleme]; 25-50'de genel bakış yokluğu şikâyeti zaten var [S25].

**Ders 3.2.** Genel bakış ekranının yokluğu ölçekle büyüyen en net şikâyet [S25, S3]. Two Point'te yapımcı bunu yama ile telafi etti [S28 (Düşük)]. [GÖRÜŞ] Unicorn'un atama kuralı kişi başı değil plan başı çalışıyorsa bu şikâyet kendiliğinden küçülebilir; ama plan sonucunun (kim hangi karta gitti) tek bakışta görünmesi gerekir.

---

## 5. Bulunamayanlar

- Atamayı iş (kart) bazında, gereksinime göre "en iyi kişi / yeten en düşük beceri" mantığıyla yapan bir oyun: bulunamadı.
- İleriye dönük darboğaz/yetişmeme öngörüsü gösteren tycoon oyunu: bulunamadı.
- Software Inc'de iş kalemini kimin aldığı (iç algoritma): resmi wiki anlatmıyor [S2, S10]; [DEĞERLENDİREMEM].
- Atama sisteminin kaldırıldığı ya da elle atamanın silindiği yama: aradım, bulunamadı.
- Reddit: erişilemedi (arama aracı alan adını reddetti); Reddit görüşü bu rapora dahil değil.
- Fandom wikileri (Software Inc, Game Dev Tycoon): 402 hatası.
- MGT2 ve Two Point için resmi wiki sayfası: açılmadı; atama kuralları forumlardan ve yalnız arama özetlerinden.
- Game Dev Tycoon'da 10+ kişi: oyun personel tavanı düşük (dört izinli [S13]); başka kaynak bu sayıyı farklı verebilir (özet bir incelemede "altı çalışan" dediğini söylüyor, sayfa açılmadı).
- Software Inc'de "250 kişilik şirket, kasıntı ve performans kötü" iddiası bir arama özetinde geçti; ilgili başlık kimliği doğrulanamadı, kullanılmadı.
- Big Pharma ve Game Dev Story'nin boşta/atama ayrıntısı: bütçe nedeniyle yok.
- MGT2 iki oyunun yapay zekâ ayarının 2021 sonrası değişip değişmediği: bulunamadı.

---

## 6. Arama günlüğü

Sorgu sayısı 18 (WebSearch). Sonuç sayıları ekrandaki bağlantı listesine göre.

| # | Sorgu (kısaltılmış) | Sonuç | Kullanılan S# |
|---|---|---|---|
| 1 | Software Inc wiki team leader work items assign employees skills automatically | 9 | S1 (dolaylı) |
| 2 | Game Dev Tycoon wiki staff assign design technology research hire employees | 9 | S12, S13 |
| 3 | Startup Company Hovgaard wiki tasks assign employees roles auto assign | 10 (hepsi alakasız) | yok |
| 4 | Mad Games Tycoon 2 wiki employees assign tasks team room | 9 | S22 |
| 5 | Two Point Hospital staff priorities wiki assign room staff training | 9 | S30 |
| 6 | Software Inc teams work items idle micromanagement ... (reddit.com ile) | hata (alan adı reddedildi) | yok |
| 7 | Software Inc teams work items employees idle micromanagement large company tedious | 10 | S2, S3, S4, S5, S6, S7 |
| 8 | Software Inc employees idle "feeling useless" ... | 10 | S6, S8, S9 |
| 9 | Game Dev Tycoon staff assign tasks too simple micromanagement ... | 10 | S14, S15, S12 |
| 10 | Startup Company game Steam discussion employees tasks assignment micromanagement idle workers feature request | 10 | S16, S17, S18, S20 |
| 11 | Mad Games Tycoon 2 employees idle not working assign task type room "auto" ... | 10 | S21, S23 |
| 12 | Two Point Campus staff job assignment tab priorities ... | 10 | S25, S27 |
| 13 | Two Point Hospital staff schedule screen job assignment grid ... | 10 | S26, S25, S27 |
| 14 | Startup Company patch notes manager production plan change ... | 10 | S19 |
| 15 | Mad Games Tycoon 2 review micromanagement tedious employees AI wander late game | 10 | S24 |
| 16 | Game Dev Story Kairosoft assign staff to tasks ... | 9 | S29 |
| 17 | Software Inc. Coredumping wiki employees roles "Lead" team leader ... | 10 | S10, S11 |
| 18 | Two Point Campus patch notes staff job assignment overview list added ... | 9 | S28 |

WebFetch (24 / 25): S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S12, S13, S14, S16, S17, S18, S19 (içerik boş geldi), S21, S25, S26; dört hatalı çağrı (Fandom x2 402, wiki /Teams 404, wiki /Main_Page 404).

### Şüpheci doğrulama notu
Bütçe yeniden açmaya yetmedi (WebFetch 24/25 kullanıldı, arama 18/18). Bunun yerine en çok yük taşıyan iddiaların her biri bir ikinci kaynakla çapraz denendi:
- "Hiçbir oyunda kart başı en iyi kişi ataması yok": çapraz kaynak yok, zaten "bulunamadı" olarak yazıldı.
- "Devredilen katman boşta üretir" (S16, S17, S18, S4, S23): beş farklı başlıkta tutarlı; yalnız S16 geliştirici kaynaklı.
- "Faz sırası boşluğu yapısal ve maaşlı" (S6, S8, S9, S2): dört başlık tutarlı.
- "TPC'de genel bakış şikâyeti" (S25): tek başlık, çok yazar; yamayla geldiği S28'de var ama Düşük (yalnız haber özeti) ve bunun TPH çizelgesiyle aynı şey olduğu doğrulanmadı.
- "Startup yapımcı değişiklikleri" (S19): yalnız arama özeti, Beta 18 sayfası boş açıldı; UYARI.
- "MGT2 kilit/yapay zekâ" (S21): tek geliştirici cümlesi, tek başlık; ilk oyunun davranışı (S23) ikinci oyunla karıştırılmamalı.
- "Game Dev Tycoon yuva ve oyun boyutu" (S14, S12): yalnız oyuncu beyanı, 2013-2020; güncel sürüm değişmiş olabilir.
Çözülmeyen: S11, S15, S19, S22, S23, S24, S27, S28, S29, S30 yalnız arama özeti; bu kaynaklara dayanan cümleler "(Düşük)" ile işaretli.
