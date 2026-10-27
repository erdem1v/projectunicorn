# R4 — Gerçek yazılım şirketlerinde ekip pratiği (Faz D için)

Tarih: 2026-10-17. Kapsam: dual-track agile, geliştirici:testçi oranı, hata kaçışı (DRE), küçük işe çok testçi, ekip büyüklüğü, darboğaz.

Kaynak notu. Bu raporda 8 WebSearch ve 39 WebFetch çağrısı yapıldı (bütçe sonuna kadar kullanıldı; bazı çağrılar 404 ya da okunamayan PDF döndü, aşağıda belirtildi). Üç PDF (Capers Jones, Scrum Guide 2017, Porter vd.) WebFetch'in okuyamadığı sıkıştırılmış ikili olarak geldi; bunları yerel `pdftotext` ile okudum, yani o sayılar birincil metinden doğrudan alındı. İşaretler: **[K]** = kaynağı satırın yanında verilmiş ve sayfadan okunmuş; **[A]** = arama sonucu özetinden, sayfa açılmadan alınmış (daha zayıf); **[M]** = kaynaksız, model bilgisi; **[T]** = benim türettiğim hesap ya da öneri, bir kaynak iddiası değil.

---

## 1. Özet

1. **Hata yakalama tek aşamada ~%40'tır, tek testçi hataların yarısını bile bulamaz.** Capers Jones'a göre çoğu test aşaması %50'nin altında verimli: birim testi ort. %38–40, fonksiyon testi %40, sistem testi %42 (en iyi durumda %55–60). Dört aşamalı klasik test zinciri toplamda ~%85 DRE verir (ABD ortalaması); %95 üstü için test yetmez, inceleme ve statik analiz şart. Oyun için: "en iyi testçi bile hataların bir kısmını kaçırır" tabanı bir aşamada ~%45'tir. (Bölüm 2.3)
2. **Birden çok testçi hızla azalan getiri verir.** Nielsen: tek değerlendirici sorunların %31'ini bulur, 5 kişi ~%84. Porter vd. (gerçek şirket deneyi): 2 gözden geçirici 1'den iyi, 4 gözden geçirici 2'den farklı değil. Simülasyon: 2–4 kişi verimli, 7'den sonra kazanç yok. (Bölüm 2.4)
3. **Ekip büyüklüğünde en güçlü ampirik kanıt QSM'den:** 4 kişi ve altı ekipler 5+ kişilik ekiplere göre 3–4 kat ucuz, 2–3 kat az hatalı; büyük ekip zamanı yalnızca %6–24 (2012) ya da ~%30 (2018) kısaltıyor. Scrum Kılavuzu 3–9, Amazon "<10", Putnam "3–7". Koordinasyon kaybı her şeyden önce **ekip içinde** n(n−1)/2 kanalla büyür; şirketler bunu büyüyünce ekibi bölerek aşar. (Bölüm 2.5)
4. **Gerçek şirketlerde PM sayısı çalışan sayısıyla orantılı büyümez.** Pave (233 bin kişi, 4.195 şirket): küçük şirkette (1–100 kişi) mühendis başına ~5:1 PM, 3.000+ kişilik şirkette ~11:1. Yani sabit "PM başına N geliştirici" yerine kademeli bir oran gerekir. (Bölüm 2.5)
5. **Dual-track'te keşif/tasarım teslimin 1–2 sprint önündedir, ama usta kaynaklar bunu "geçiş modeli" sayar.** Patton ve Cagan sayı vermez; Gothelf aşamalı (staggered) sprinti uzun vadede önermez. Scrum Kılavuzu: backlog iyileştirme (refinement) geliştirme ekibi kapasitesinin en çok %10'u. (Bölüm 2.1)
6. **Test darboğazı gerçekte iki çözümle yönetilir:** WIP limiti ve geliştiricinin testlere yardım etmesi; uzun vadede büyük şirketler (Microsoft 2014, Google) ayrı test rolünü kaldırıp testi geliştiriciye verdi. Oran 1:1'den 2:1'e, Google tarzı ekiplerde 10:1+ (gözlem). (Bölüm 2.2, 2.6)
7. **Sabit kuralları ölçeğe karşı koruma:** her şeyi "kişi başına %X" yerine ya ekip düzeyinde (ekip boyutuna bağlı kanal sayısı) ya da sönümlü (1−(1−p)^n) biçimde yazın. Önerilen formüller Bölüm 5'te.
8. **Bulunamayanlar:** "hiç ayrı test yokken" kaçış oranı için tek bir birincil sayı; tasarımcı:geliştirici oranı; küçük/büyük iş için hazırlık süresi farkı; bkz. Bölüm 6.

---

## 2. Mekanik döküm

### 2.1 Dual-track agile / ürün keşfi

**Temel kural.** Keşif (discovery) doğrulanmış backlog maddesi üretir; teslim (delivery) yayınlanabilir yazılım üretir. Cagan: PM, tasarımcı ve baş mühendis yan yana çalışıp backlog maddelerini üretip doğrular; "mini-şelale" (PM gereksinim yazar, tasarımcı wireframe çizer, ekip yapar) bundan farklı. Cagan, zaman kutulu "Discovery Sprint" terimini bıraktığını söylüyor çünkü bu adımları ardışık faz gibi gösteriyor. Sayfada sayı yok. [K] https://www.svpg.com/dual-track-agile/

**Eşzamanlılık.** Patton: "Keşif işi geliştirme ile eşzamanlı ve sürekli yapılır." Keşif döngüleri birkaç saat ile birkaç gün arası zaman kutulu; "tipik 2 haftalık sprint içine çok sayıda keşif öğrenme döngüsü sığar." Bu iki ayrı ekip değil, "tek sürecin iki parçası." Tasarımcıların bazen taktik tasarımı bitirmek için geliştirmenin önünde çalışması gerektiği açıkça yazıyor; ama geliştiriciyle her gün konuşmaları şart. [K] https://www.jpattonassociates.com/dual-track-development/

**Önde çalışma süresi (sayı).**
- Pop Pays: keşif teslimin "bir ila iki sprint" önünde, yani teslim ekibinin önünde hep doğrulanmış iş bekliyor. Desiree Sy modeli: tasarımcı bir döngü önde, geliştirici bir önceki döngüde doğrulanan işi yapıyor. [K, ikincil] https://radar.zurb.com/article/dual-track-is-two-kinds-of-work-not-two-teams
- Sy ve Miller (2007) "staggered sprints": tasarım bir sprint önde. Gothelf bunu "geçiş olarak iyi, hedef olarak kötü" buluyor: ekip hiçbir zaman aynı iş üzerinde aynı anda çalışmaz, fizibilite devir anına kadar anlaşılmaz, tasarım boşa gidebilir. Örnekte tasarımcı yeniden işi "en az 2–3 gün". Önerisi: tasarımcı sprint planlamaya katılır, haftalık kullanıcı araştırması (geri bildirim en fazla 5 iş günü eski). [K] https://oreilly.com/content/integrating-lean-ux-and-agile
- Torres: haftada en az bir müşteri teması; PM + tasarımcı + mühendis üçlüsü ("product trio") keşfi birlikte yürütür; proje tabanlı araştırmada tipik 6–12 müşteri. Sürekli keşif "bir faz" değil. [K] https://www.producttalk.org/continuous-discovery/

**Definition of Ready (DoR) ve refinement.**
- DoR: ekip, hikâyelerin bir iterasyona alınması için karşılaması gereken ölçütleri açık ve görünür yapar; ölçütler genelde INVEST'e dayanır; resmî ilk tanım Ekim 2008, sonra Scrum eğitim materyaline girdi. Ölçüt listesi sayfada yok. [K] https://www.agilealliance.org/glossary/definition-of-ready/
- Scrum Kılavuzu 2017 (PDF metninden): "Refinement genellikle Geliştirme Ekibi kapasitesinin %10'unu aşmaz." Geliştirme ekibi 3'ten az olursa etkileşim ve verim kazancı düşer, 9'dan fazlası "çok fazla koordinasyon" ister. Sprint en fazla bir ay. DoR kılavuzda tanımlı değil, ekibin kendi pratiği. [K] https://scrumguides.org/docs/scrumguide/v2017/2017-Scrum-Guide-US.pdf
- Airfocus (arama özeti): DoR tanımına göre ayrıntılı tasarımın bir kısmı teslim hattında yapılabilir; yani "tasarım bitmeden hazır sayılmaz" kuralı ekibe göre değişir. [A] https://airfocus.com/product-learn/what-is-dual-track-agile/

**Küçük ve büyük iş için hazırlık süresi farkı.** Birincil kaynakta sayı bulunamadı. Tek dolaylı veri: tasarım sprintleri ~5 gün, ~10 kişi (Gothelf) ve keşif ticket'ı birkaç saat–birkaç gün (Patton/Zurb). Oyun için türetim Bölüm 5'te [T].

### 2.2 Geliştirici:testçi oranı

Tabloda "G:T" geliştirici sayısı : testçi sayısı.

| Bağlam | G:T | Kaynak |
|---|---|---|
| Microsoft, 2014'e kadar SDE:SDET | 2:1 yaygın (Skype Xbox One ekibi 2012: 12 SDE, 6 SDET, 2 PM, 1 EM) | [K] https://newsletter.pragmaticengineer.com/p/how-big-tech-does-qa |
| Microsoft, 2008 (Whittaker) | ~1:1'den iki-üç katına | [K] https://learn.microsoft.com/en-us/archive/blogs/james_whittaker/google-v-microsoft-and-the-devtest-ratio-debate |
| Google, 2008 | "tek testçi çok geliştirici", sayı verilmemiş | aynı kaynak |
| Bir anket (Rice, konferans oturumu, örneklem belirsiz) | en yaygın 3:1 | [K] https://www.infoq.com/news/2009/01/tester-to-developer-ratio |
| LogiGear anketi | %63 oranında 2–5:1, %9 oranında 1:1 | [A] arama özeti, sayfa açılmadı |
| Kuzey Karolina'da şirket anketi (90'lar ortası, Velocity Partners yazarı) | 2:1 – 12:1; sağlıklı aralık 2–5:1; 7–8:1 üstü kaliteyi sıkıştırır | [K] https://velocitypartners.net/blog/2014/06/17/magic-ratios-silver-bullet-or-bunk/ |
| Aynı yazar, 2000'ler ortası | Google tarzı çevik ekiplerde 10:1 – 30:1+ (testçiler SDET'e dönüştü); düzenlemeli finans 4–7:1 | aynı (yazarın gözlemi) |
| Aynı yazar, iContact | hedef 5:2, çoğu ekipte 5:1; testçileri çıkarılan ekipte 7:0, hız düştü, geliştiriciler testçileri geri istedi | aynı |
| Amazon | 10:1 ve kimi anlatımda daha yüksek | [A] ByteByteGo, doğrulanmadı |

**Rakamın anlamsızlığı.** Kaner, Hendrickson ve Smith-Brock oranları "şaşırtıcı biçimde anlamsız" buluyor; etkenler: gelen güvenilirlik, yapılandırma çeşitliliği, test edilebilirlik, araçlar, deneyim, kalite standardı. [K] https://www.infoq.com/news/2009/01/tester-to-developer-ratio

**Bir hesaplama (Ganssle, Jones ve Bonsignour verisiyle).** Test başına 35 dk yazma + 15 dk koşma + 84 dk hata düzeltme/yeniden koşma = 134 dk; 55 test/FP ve C'de FP başına ~120 satır ile yaklaşık 2 satırda 1 test; geliştirici ayda 200–300 satır üretirse test yükü ayda ~1,4–2,1 testçi. Statik analiz ve inceleme hataların %97'sini testten önce temizlerse bu 0,8 testçiye iner. Yani **oran, kod kalitesine bağlı**: temiz kod, daha az testçi. [K] https://ganssle.com/rants/testertodeveloperratio.html

**Whittaker'ın iki kutbu.** 1:1 bağımsızlığı korur ve geliştiriciyi serbest bırakır, ama geliştiriciye "kalite benim işim değil" bahanesi verir. Çok:1 geliştiriciyi kaliteye zorlar ama testçiyi ince yayar. Yorumcu: 4:1 üstü "yönetilemez" (anonim yorum, kanıt değil). [K] yukarıdaki Microsoft Learn bağlantısı

**Testçisiz ekipler.** Microsoft 2014'te SDET rolünü emekli etti: Skype for Web günlük yayın yaptığı için ayrı test rolünü bıraktı, Bing izledi, Temmuz 2014'te rol kaldırıldı (aynı dönemde 127.000 kişiden 18.000 işten çıkarma). Visual Studio Team Services'te testçilerin yazdığı on binlerce testin tam koşusu "günün çoğunu" alıyordu; birleşmeden sonra test karışımı uçtan uca testlerden birim/entegrasyon testlerine döndü ve eski testlerin çoğu değiştirildi. Google'da testi geliştirici sahiplenir ("testing is everyone's job"), test karışımı sayıya göre yaklaşık %80 birim, %15 entegrasyon, %5 uçtan uca; manuel test keşif amaçlı ve kalite değerlendiricilerle sınırlı. [K] https://newsletter.pragmaticengineer.com/p/how-big-tech-does-qa ve https://abseil.io/resources/swe-book/html/ch11.html

**Şirket büyüdükçe oran.** Elimizde tek bir şirketin zaman serisi yok. Kanıt: Microsoft 1:1–2:1 → birleşik mühendislik; Google tarzı → 10:1+; düzenlemeli sektör → 4–7:1. Yani oran büyüklükten çok **sektör, test otomasyonu ve yayın sıklığına** bağlı. [T özet]

### 2.3 Hata kaçışı: DRE

**Tanım (Capers Jones, 2011).** DRE = teslimden önce bulunan ve giderilen hata yüzdesi; ölçüm: teslimden 90 gün sonra müşteri hataları iç hatalara eklenip hesaplanır (ISBSG 30 gün kullanır, bu yüzden daha yüksek çıkar). ABD ortalaması 2011'de ~%85; en iyi proje %99'u aşabilir; gözlenen en düşük %80 altı. "Yüksek DRE yalnız testle sağlanamaz; %95 üstü için testten önce inceleme ve statik analiz şart." [K] https://www.ppi-int.com/wp-content/uploads/2021/01/Software-Defect-Removal-Efficiency.pdf

**Hata potansiyeli (FP başına, ABD ort. 13.000+ proje).** Gereksinim 1,00 (%77 giderim), tasarım 1,25 (%85), kod 1,75 (%95), doküman 0,60 (%80), kötü düzeltme 0,40 (%70). Toplam 5,00; teslimde 0,75 hata/FP kalır (%85). Aralık: küçük projede ~2,0, 10.000 FP'lik büyükte ~7,0. Not: "Kötü düzeltme" = bir hatayı düzeltirken yeni hata sokma; sayfada %7 (düşük kalite örneği) ve %3,5 (yüksek kalite örneği) kullanılıyor. [K] aynı

**Aşama bazında verimlilik (min / ort. / maks).**

| Aşama | Min | Ort. | Maks |
|---|---|---|---|
| Biçimsel tasarım incelemesi | %65 | %87 | %97 |
| Biçimsel kod incelemesi | %60 | %85 | %96 |
| Statik analiz | %65 | %85 | %95 |
| İkili programlama | %40 | %55 | %65 |
| Gayriresmî akran incelemesi | %35 | %50 | %60 |
| Birim testi (otomatik) | %20 | %40 | %50 |
| Birim testi (elle) | %15 | %38 | %50 |
| Fonksiyon testi | %33 | %40 | %55 |
| Regresyon testi | %35 | %35 | %45 |
| Sistem testi | %27 | %42 | %55 |
| Bağımsız test | %15 | %35 | %42 |
| Kabul testi | %15 | %35 | %40 |
| Harici beta | %30 | %40 | %50 |

Test aşamalarının ortalaması %44; inceleme/analiz grubu %69. [K] aynı PDF, Tablo 2.

**İki örnek zincir (1.000 FP).**
- Düşük kalite: 5.000 hata, kötü düzeltme %7; birim %38 → fonksiyon %40 → regresyon %35 → sistem %42 ⇒ DRE %85,32; teslimde 613 hata (110'u ağır).
- Yüksek kalite (TSP + inceleme): 4.500 hata, kötü düzeltme %3,5; inceleme %85 → birim %42 → fonksiyon %45 → regresyon %40 → sistem %47 ⇒ DRE %98,33; teslimde 76 hata (14'ü ağır). [K] aynı

**Hiç ayrı test yokken.** Doğrudan sayı bulunamadı. Çıkarım [T]: yalnızca geliştiricinin kendi birim testi/elle denemesi varsa tek aşama ~%38–40 yakalar, yani ~%60 kaçar; bu, tablodaki "birim testi (elle)" ortalamasıdır, "testçisiz ekip" ölçümü değil.

**En iyi testçide taban.** Klasik aşama testlerinin (birim, fonksiyon, sistem, regresyon, kabul) maksimumu %45–55'tir. Deneye dayalı test (maks. %85) ve risk tabanlı test (maks. %80) bundan yüksektir, ama bunlar tek bir kişinin değil bir test stratejisinin sonucudur (Tablo 2). Dolayısıyla "kusursuz tek testçi" yoktur; klasik tek aşamada tavan ≈ %55, bunun kaçışı ≈ %45 [T].

**Maliyet (McConnell, özet).** Düzeltme/yeniden işleme toplam geliştirme maliyetinin %40–50'si (Jones 1986); gereksinim hatasını yayından sonra düzeltmek erkenkine göre 50–200 kat pahalı (Boehm ve Papaccio 1988); en düşük hata sayısı olan ürünler en kısa takvime sahip (IBM 1970'ler); %95 giderimle çıkan projeler en kısa takvim ve en az eforu alıyor (Jones 1991). Satırbaşı: hatayı geç bulmak kaybettirir, test "ek süre" değil, süre kazandırır. [K] https://www.stevemcconnell.com/articles/software-quality-at-top-speed/

**Başka bir ölçek (Google).** Google Web Server'da bir dönem üretim çıkışlarının %80'inden fazlası kullanıcıyı etkileyen hata içeriyordu; zorunlu otomatik testten sonra acil çıkışlar bir yıl içinde yarıya indi. Sızıntı hatalı test (flaky) oranı ~%0,15; ~%1 civarında testler değer kaybeder. [K] https://abseil.io/resources/swe-book/html/ch11.html

### 2.4 Küçük işe çok testçi ve çok geliştirici

**Sönümlü bulma modeli (Nielsen ve Landauer).** n bağımsız değerlendiricinin bulduğu oran = 1 − (1 − L)^n; L = tek kişinin bulduğu oran = %31. Değerler: 1 kişi %31, 3 kişi ~%67, 5 kişi ~%84, 15 kişi ~%99,6. 1→3 arası +36 puan, 3→5 arası +17, 5→15 arası yalnız +15 puan ama 3 kat kişi. (Bu kullanılabilirlik testi için; hata avcılığına doğrudan değil, ama mekaniği aynı: örtüşme.) [K] https://www.nngroup.com/articles/why-you-only-need-to-test-with-5-users/

**Yazılım incelemesinde gerçek deney (Porter, Siy, Toman, Votta, IEEE TSE 1997).** Şirket içi canlı geliştirmede 11 deneyimli geliştirici havuzundan rastgele; 1, 2 ya da 4 gözden geçirici. Bulgular: "1 kişilik < 2 kişilik, ama 2 kişilik = 4 kişilik"; iki küçük ekip kurmak büyük ekibe eşdeğer; hataları oturumlar arasında düzeltmek de fark yaratmadı; bazı kombinasyonlar yalnız **süreyi** (inspection interval) dramatik biçimde uzattı. [K] https://userweb.cs.txstate.edu/~rp31/papersSQ/PorterEtAl_TSE.pdf

**Simülasyon (arXiv 1402.5267).** Ekip büyüklüğü 1–10: efor ve süre dörtten fazla gözden geçiricide belirgin artıyor, bulunan hata sayısı ise yalnız "degressif" artıyor; 7'den fazlada anlamlı artış yok; efor ve süre bakımından en uygun 2–4 kişi. [K] https://arxiv.org/pdf/1402.5267 (Bölüm 6.2)

**Geliştirme tarafı: Brooks.** "Gecikmiş bir yazılım projesine insan eklemek onu daha da geciktirir." Üç neden: ramp-up (yeni kişi eğitim alır, eğitmeni de oyalar), iletişim kanalları n(n−1)/2 (50 kişi → 1.225), sınırlı bölünebilirlik ("dokuz kadın bir ayda bebek yapamaz"). Kanıt karışık: Hsia vd. 1999 sistem dinamiği: maliyeti hep artırır ama takvim payı varsa proje geç kalmayabilir; McConnell artık doğru bulmadığını, gecikmenin düşük tahminden geldiğini söylüyor; Berkun "eklenen emek eşit değil" diyor. [K] https://en.wikipedia.org/wiki/Brooks%27s_law ve https://en.wikipedia.org/wiki/The_Mythical_Man-Month

**Amdahl.** Hızlanma S = 1 / ((1−p) + p/s); p = hızlanabilen kısım; sınır 1/(1−p). Örnek: p = 0,3, s = 2 → 1,18. "Eklenen her işlemci öncekinden az kullanılabilir güç ekler." Yazılım işi için p = paralel yapılabilir iş payı: tek küçük kart için p küçük, dolayısıyla ikinci kişi neredeyse hiç kazandırmaz. [K] https://en.wikipedia.org/wiki/Amdahl%27s_law

**Brooks'un zaman payı kuralı** (1/3 planlama, 1/6 kod, 1/4 bileşen testi, 1/4 sistem testi; yani test toplam sürenin yaklaşık yarısı) **[M]**, kitabın Vikipedi sayfasında yok; doğrulanmadı.

### 2.5 Ekip büyüklüğü ve koordinasyon

**QSM (ekip büyüklüğü, 10.000+ proje veri tabanı).** [K] https://qsm.com/blog/2025/4-key-studies-team-size ve https://qsm.com/blog/2012/part-ii-small-teams-deliver-lower-cost-higher-quality
- Putnam 1997 (491 proje, 35–95 bin SLOC): en iyisi 3–7 kişi.
- Beckett 2006 (~600 BT projesi): en iyi sınıf ile en kötü sınıf karşılaştırması: takvim 5 kat hızlı, efor 15 kat az, ekip 4 kat küçük; medyan ekip 4 FTE ve 17 FTE.
- Armel 2012 (1.060 BT projesi, 2005–2011): "küçük" ≤4 FTE (ort. 2,1), "büyük" ≥5 FTE (medyan 8,5). Küçük iş (5.000 SLOC): büyük ekip %24 hızlı (~1 ay), maliyet 3 kat, hata yoğunluğu 2 kattan fazla. Büyük iş (50.000 SLOC): büyük ekip yalnız %6 hızlı (~12 gün), maliyet 4 kat, hata 3 kat.
- Putnam yeniden (2018, 390 uygulama, 10–20 bin satır): küçük <4 kişi, büyük ≥9 kişi: büyük ekip ~%30 daha kısa takvim, maliyet "%350 artış", test sırasında "%500 daha fazla hata". (Sayfadaki ifade; "%350 artış" 3,5 kat mı 4,5 kat mı olduğu belirsiz.)
- Karşı kanıt: Paul Below'un QSM analizi, proje büyüdükçe verimliliğin arttığını (büyük projeler daha çok efor, daha uzun süre, daha büyük ekip kullanır) gösteriyor [A] arama özeti. Yani "küçük ekip" bulgusu **aynı büyüklükteki iş** için; büyük iş yine büyük ekip ister.
- Uyarı: bunlar QSM'nin kendi blog yazıları, hakemli makale değil.

**İletişim kanalları.** n(n−1)/2: 3 kişi 3, 5 kişi 10, 8 kişi 28, 10 kişi 45, 20 kişi 190, 50 kişi 1.225. [K] Brooks, yukarıdaki Vikipedi sayfası.

**İki pizza.** Amazon: ekip "iki pizzadan fazlasını gerektirecek kadar büyük olmamalı", yani <10 kişi; her ekip tek ürün/hizmetin uçtan uca sahibi (mühendislik, test, ürün/program yönetimi, operasyon ekibin içinde); talep büyürse ekip **bölünür**, üye eklenmez. [K] https://aws.amazon.com/executive-insights/content/amazon-two-pizza-team/

**Team Topologies.** Dört ekip tipi (stream-aligned, enabling, complicated-subsystem, platform), üç etkileşim biçimi (işbirliği, hizmet olarak X, kolaylaştırma), ekip bilişsel yükü. Sitede ekip boyutu sayısı ve bölme yöntemi **yok**; "org şeması çizme yöntemi değil" deniyor. [K] https://teamtopologies.com/key-concepts

**Örgüt yapısı kaliteyi öngörür (Microsoft Research, Nagappan vd.).** Windows Vista'da örgütsel karmaşıklık metrikleri hata yatkınlığını kod metriklerinden (churn, karmaşıklık, kapsama, bağımlılık) anlamlı biçimde daha iyi öngördü. (Sayılar özet sayfasında yok.) [K] https://www.microsoft.com/en-us/research/publication/the-influence-of-organizational-structure-on-software-quality-an-empirical-case-study/

**5'ten 50'ye büyüme (örnek şirket: Grabyo).** ~5 mühendis: düz yapı, CTO insan yönetimi yapar. 10–12 mühendis: CTO'nun zamanı insan yönetimine gidiyor, VP Mühendislik eklendi, Scrum/Kanban kuruldu. Sonra takım liderleri (melez rol; yönetim işi hep ikinci plana düştü). ~20 mühendis: ilk saf Mühendislik Müdürü, 10–15 rapor (lidere göre 2–3). ~30: melez model. ~50 çalışana doğru: lider rolü kaldırıldı, her EM bir ekibin tamamına sahip. [K] https://about.grabyo.com/?p=45293

**Eşik önerileri (yazarın görüşü, veri değil).** 5–8 mühendis: her stand-up'ta olabilirsiniz; 9–14: lider tayin; 15–25: 5–9 kişilik 2–3 alt ekip; ilk yönetici ~12–15; katmanlı (ön/arka) bölme ancak 50+ mühendiste mantıklı, özellik alanına göre bölme tercih edilir; 25 kişide bir kişi konuşmaların yaklaşık %5'ine dahil olabilir. [K, görüş] https://www.techinterview.org/post/3233475014/scaling-engineering-team-5-to-25-em-playbook/?format=md

**Yönetici kapsamı (Pave).** 50 kişiden küçük erken aşama şirketlerde M5/M6 yöneticilerin örgütü ortalama ~4–10 kişi; 500 kişi altında M6'lar M5'lerden 3–7 kişi fazla, 1.000+'da 30+ fazla. [K] https://pave.com/blog-posts/exploring-engineering-manager-director-team-size

**PM ve mühendis oranı.**
- Pave: mühendis payı ~%70 → ~%80; PM payı %13 → %7; mühendis:PM ~5:1 (1–100 kişi) → ~11:1 (3.000+). [K] https://www.pave.com/blog-posts/research-development-org-structure-benchmarks
- Cagan 2007: 6–10 geliştirici başına 1 PM. [A] arama özeti; "1:7 yaygın ama kanıtsız" uyarısı da orada. https://www.bringthedonuts.com/newsletter/ideal-ratio-engineers-to-product-managers.html (açılmadı)
- Tasarımcı oranı: sağlam kaynak **bulunamadı**.

**Koordinasyon kaybı ekip mi, şirket mi?** Kanıtın söylediği: (a) ekip içinde kayıp n(n−1)/2 ile büyür ve 5–9'dan sonra QSM/Scrum/Amazon hepsinde keskin (maliyet ve hata kat kat artıyor); (b) şirketler bunu ekibi bölerek yönetir, yani ekipler arası kayıp ekip içi kayıptan **doğrusal ya da daha yavaş** büyür, ama sıfır değil: Nagappan'ın örgüt metrikleri hata öngörür; Team Topologies etkileşim biçimlerini (işbirliği pahalı, hizmet olarak X ucuz) ayırır; EM ve lider katmanı eklenir (Grabyo). Yani **kayıp temelde ekip başına**, şirket düzeyinde ise "ekip sayısı × bağımlılık" olarak eklenir [T özet].

### 2.6 Darboğaz: kısıtlar teorisi, WIP, Kanban

**Kısıtlar Teorisi (Goldratt).** Beş odak adımı: kısıtı belirle, kısıtı sömür, her şeyi kısıta tabi kıl, kısıtı yükselt, bozulduysa başa dön. "Akışı yalnızca kısıttan artırarak toplam verim artırılır." Drum-Buffer-Rope: davul = kısıtın hızı; tampon = kısıtın önünde zaman tamponu; halat = işi kısıttan bir tampon süresi önce serbest bırak (erken bırakırsan WIP artar, sistem yavaşlar). Tampon bölgeleri kırmızı/sarı/yeşil. Tampon yönetimi (envanter örneği): üst üçte birde bir tam yenileme süresi kalırsa tamponu 1/3 küçült; alt üçte birde (sürenin ~%20'si kadar) kalırsa 1/3 büyüt. [K] https://en.wikipedia.org/wiki/Theory_of_constraints

**Little yasası.** L = λW (sistemdeki ortalama iş = geliş hızı × sistemde kalış süresi). Kanban eşleştirmesi (Vikipedi bunu söylemiyor, çıkarım): W = WIP / verim. WIP'i yarıya indirirsen aynı verimde çevrim süresi yarıya iner. [K] https://en.wikipedia.org/wiki/Little%27s_law, Kanban eşleştirmesi [T]

**Kanban.** WIP sınırı kolon başlığının altında daire içinde gösterilir; sınır aşamanın hem "yapılıyor" hem "hazır" alt kolonlarına uygulanır; Vikipedi örneği: dağıtım aşaması 5 ile sınırlı ve dolu, bu yüzden kabul ekibi yeni epik'i alamıyor ve nedeni tahtada görüyor; dağıtım boşalınca dağıtım ekibi işsiz kalıyor ve kabule yardıma gidiyor. Sınırın nasıl belirleneceği o sayfada yok. [K] https://en.wikipedia.org/wiki/Kanban_(development)

**Test darboğazı pratikte.** Sinyaller ve çözümler (hepsi blog/forum/satıcı düzeyi, anekdotik): test kolonunda kart birikir; çözüm olarak WIP limiti, geliştiricinin yeni iş almak yerine teste yardım etmesi, hikâyeleri küçültüp teste erken başlamak, çevrim süresini kolon bazında ölçmek, çapraz eğitim. Bir Kanban ekibi limit koyunca "yazmadıkları QA işine yardım etmeye başladı." [A] https://www.scrum.org/forum/scrum-forum/103302/how-do-teams-actually-keep-testing-aligned-agile-projects, https://kanbantool.com/kanban-library/case-studies-devops/applying-kanban-to-it-processes-4-software-development, https://www.pmi.org/disciplined-agile/controlling-work-in-process-wip (üçü de açılmadı, yalnız arama özeti)

Microsoft'ta "ping-pong" biçimi: geliştirici özelliği SDET'e verir, SDET hata iade eder, tekrar. Yayın sıklığı yüksek ekipler (Skype for Web, günlük) ayrı testi önce bıraktı. [K] https://newsletter.pragmaticengineer.com/p/how-big-tech-does-qa

---

## 3. Oyuncuya gösterim

Bu konu gerçek dünya pratiği; oyun ekranı yok. Yine de bizim ekranlara ilham olabilecek gösterim biçimleri:

- Kanban tahtasında WIP sınırı kolon başlığının altında daire içinde sayı olarak gösterilir. (Vikipedi "Kanban (development)", yukarıdaki bağlantı, metin açıklaması; görsel URL'si alınmadı.)
- Kısıtlar Teorisi'nde tampon durumu kırmızı/sarı/yeşil boyanır; kırmızı öncelik alır. (Vikipedi TOC sayfası.)
- Google'da proje sağlığı "pH" 1 (en kötü) – 5 (en iyi) puanla gösterilir; önceki sistem "Test Certified" beş seviyeliydi ve 1.500'den fazla projeye uygulandı. (abseil.io ch11)
- Ekran görüntüsü / Steam galerisi URL'si: **toplanmadı**, bu rapor oyun incelemesi değil.

---

## 4. Ölçek ve sorunlar

**Küçük ekip.** Sınırlı beceri riski: Scrum Kılavuzu 3'ten az kişide "etkileşim ve verim kazancı düşer, beceri kısıtı doğar." İki kişilik QSM ekipleri (ort. 2,1 FTE) en ucuz ve en az hatalı; ama sadece aynı büyüklükteki iş için.

**Büyük ekip.** ≥9 kişi: takvimi ~%30 kısaltıyor, maliyeti kat kat artırıyor, test sırasında çok daha fazla hata (QSM 2018). 50 kişilik düz bir ekipte 1.225 kanal. Pratik çare: bölmek (Amazon, Grabyo).

**Test rolü.** Microsoft 2014'te SDET rolünü kaldırdı; büyük şirketler test mühendisini geliştirici kılığına çevirdi (Google SETI). Sorun: geliştirici rahatlığı ("başkası test eder") ve ping-pong; çözümün bedeli: test yükü geliştiriciye geçer. iContact'ta testçiler çıkarılınca hız düştü, geliştiriciler testçileri geri istedi (tek anekdot).

**Test aşamalarının tek başına tavanı.** Jones: yalnız testle %95 aşılamaz. Gerçek şirketlerin ders çıkardığı şey: erken yakalama (inceleme, statik analiz, otomatik birim test), test darboğazını WIP ile görünür kılma.

**Sonradan değişiklikler.** Microsoft: ayrı testten birleşik mühendisliğe (2014). Google: GWS'de zorunlu otomatik test sonrası acil çıkışlar yarıya indi. Scrum Kılavuzu: 2017'de "3–9" aralığı vardı, 2020 sürümünde sayısal aralık kalktı [M, indirilen 2017 metninde 3–9 doğrulandı, 2020 değişikliği doğrulanmadı].

**Oyuncu topluluğu şikâyetleri.** Bu konu gerçek dünya pratiği olduğu için ele alınmadı; ilgili oyun incelemesi R1–R3 raporlarında olmalı.

**İstismar edilen metrikler.** Bu araştırmada bulgu yok. Oran (G:T) verilerinin bilinen zayıflığı: sayma yöntemi (org şeması mı, fiilî mi), "test" ve "geliştirme"nin tanımı (Velocity Partners, Whittaker yorumları).

---

## 5. Bizim için

Aşağıdakiler benim önerim [T]; kaynaklı olgulara dayanır, kaynak değil. Tüm "çalışan başına %X" kurallarının yerine iki ölçek-güvenli kalıp öneriyorum: **sönümlü birleştirme** (1 − Π(1 − p_i)) ve **ekip bazlı kanal sayısı** (n(n−1)/2 ya da ekip sayısı).

### Alınacak

1. **Aşama başına tek vuruşluk yakalama olasılığı, bunların birleşimi.** Gerekçe: Jones'un tabloları tam olarak bunu yapar (ayrı aşamalar ayrı yüzdelerle çarpılır, kötü düzeltmeyle birlikte). Öneri: geliştiricinin kendi denemesi p_dev ≈ 0,38–0,42, testçi yıldıza göre p_test = 0,27 + (yıldız−1)/4 × (0,55−0,27) (sistem testi min–maks aralığını 1–5 yıldıza yaymak; 1★ ≈ %27, 3★ ≈ %41, 5★ ≈ %55). Kaçış oranı = Π(1 − p). Sonuç: testçisiz ≈ %60 kaçar; 3★ testçiyle 0,60 × 0,59 ≈ %35; 5★ testçiyle 0,60 × 0,45 ≈ %27. Tavan yok sayılmaz: tek testçiyle kaçış hiçbir zaman %25 altına inmez; daha aşağısı için başka aşama (inceleme/otomasyon) gerekir.
2. **Karta bağlı hata sayısı.** Hata sayısı kartın boyutuna göre ölçeklenir (Jones'un hata potansiyeli FP'ye bağlıdır, sabit değil; ~FP^1,25 ilişkisi Ganssle sayfasında "çoğu kuruluş için tipik" diye geçiyor, bu büyük iş yüzünden hata oranının büyüme eğilimini gösterir).
3. **Kanban gibi görünür WIP ve darboğaz göstergesi.** Test kolonunda biriken kart, WIP sınırı, "geliştirici teste yardım ediyor" durumu (Kanban Vikipedi örneği: boşta kalan ekip öbür aşamaya yardım eder).
4. **Hazırlık (tasarım) aşaması, teslimin 1–2 sprint önünde.** Gerekçe: Pop Pays / Sy ve Miller. Hazır olmayan kart (DoR) sprinte alınmaz; refinement için kapasite payı koyun (Scrum: ≤%10).

### Uyarlanacak

5. **Çok testçi, tek kart.** Gerçek veri açık: 1→2 kişi kazandırır, 2→4 kazandırmaz (Porter), yani **ikinci testçi değerli, üçüncüsü ve sonrası çok az**. Öneri: etkili olasılık = 1 − (1−p₁)(1−0,5·p₂)(1−0,2·p₃) (katsayılar benim tahminim; Porter'ın "2=4"ü ve Nielsen'in %31 örtüşmesi şeklinden esinli). Hız tarafında da sönüm: ikinci kişi süreyi ~%30–40, üçüncüsü ~%10 kısaltır [T, kaynaksız]. Küçük kart için p (paralel bölünebilir pay) düşük olduğundan Amdahl gereği ek kişi neredeyse hiç hız kazandırmaz.
6. **Geliştiriciye çok kişi ekleme.** Yeni kişinin ramp-up süresi (ilk sprint verimsiz) ve kart başına kişi sayısı arttıkça iletişim kaybı: Brooks'a göre eklenen kişi, kartın büyüklüğüne bağlı olmayan sabit bir iletişim vergisi getirir. Öneri: kart başına 2. geliştiricinin ek hızı ≤%40, 3. ≤%10; kart başına 3+ kişi neredeyse hiç kazandırmaz (Brooks, Amdahl).
7. **Ekip boyutu kuralı.** Şirketin tamamını tek ekip saymayın. Ekip eşiği 5 / 9 (Scrum 3–9, Putnam 3–7, Amazon <10); ekip içi iletişim vergisi n(n−1)/2 ile ölçeklensin (5 kişi 10 kanal, 9 kişi 36 kanal, 50 kişi 1.225). Büyük şirkette oyuncu ekipleri bölebilsin: bölününce vergi (ekip sayısı − 1) × sabit bağımlılık vergisi olarak yeniden başlasın (Amazon "böl, ekleme"; Nagappan: örgüt karmaşıklığı hata öngörür).
8. **Yönetim katmanı eşikleri.** 12–15 çalışandan itibaren yönetici/lider gerek (Grabyo 10–12 sorun, ~20 saf EM; techinterview görüşü 12–15). Ölçekte patlamayı önlemek için "yönetici başına rapor" sınırı koyun (4–10, Pave erken aşama); sınırı aşan ekibe koordinasyon cezası.
9. **PM oranı kademeli.** Küçük şirkette mühendis:PM ≈ 5:1 → büyük şirkette ≈ 11:1 (Pave). Oyunda sabit "PM başına N" yerine, N şirket büyüklüğüyle 5 → 11 arasında kayan bir değer olsun. Tasarımcı oranı için veri yok (Bölüm 6): R1–R3'ten oyun örnekleri bakılsın.
10. **Kart hazırlık süresi, büyük ve küçük iş.** Kaynak sayısal fark vermiyor. Öneri: hazırlık süresi kartın boyutuyla doğrusal değil karekök gibi büyüsün (K3 = K1'in ~2 katı, 3 katı değil) ve tasarımcı yıldızı süreyi kısaltsın. Bu bir tasarım tercihi, kanıt değil.
11. **Test darboğazı.** Test aşaması kapasiteyi aşınca kuyruk büyür (Little: bekleme = WIP/verim). Oyuncuya çözümler: testçi işe al, geliştiricilerin teste yardımı (verimi düşük), WIP sınırı (sprinte alınan kart sayısını sınırla), hata riskini kabul et.

### Alınmayacak

12. **Tek bir "ideal G:T oranı" sayısı.** Kaner/Hendrickson/Rice: oranlar "anlamsız", bağlama bağlı. Bunun yerine testçi sayısını gerçek iş yüküne (kuyruk) bağlayan mekanik, sabit oran hedefi koymayın.
13. **"Testçi her şeyi yakalar" ya da "%100 test" varsayımı.** Jones'a göre %95 üstü, testle değil inceleme + statik analizle mümkün; oyunda %25–30 altına inmek için ayrıca "kod incelemesi" ya da "otomasyon" aşaması gereksin.
14. **Brooks yasasını mutlak kural yapmak.** Kanıt karışık (McConnell, Hsia). Daha güvenlisi: ramp-up cezası + iletişim vergisi, ama "ekleme her zaman geciktirir" kuralı olmasın.
15. **Test oranını büyüdükçe otomatik artıran kural.** Microsoft/Google tersine gitti (testi geliştiriciye verdi). Bunu oyuna otomasyon yatırımı olarak koyun: otomasyon p_dev'i yükseltir ve testçi ihtiyacını düşürür (Ganssle'ın 134 dk → 52 dk hesabı: ön giderim ile test maliyeti %61 düşer).

### Sayısal özet (kolay referans)

| Konu | Değer | Kaynak sınıfı |
|---|---|---|
| Birim/fonksiyon/sistem testi tek aşama | %38 / %40 / %42 (maks %50 / %55 / %55) | Jones [K] |
| 4 aşama toplam (inceleme olmadan) | %85 | Jones [K] |
| İnceleme + test toplam | %95–99 | Jones [K] |
| Bağımsız değerlendirici başına bulma | %31 | Nielsen [K] |
| Gözden geçirici sayısı: 1 / 2 / 4 | 2 = 4 > 1 | Porter [K] |
| Verimli gözden geçirici sayısı | 2–4 (7 üstü kazanç yok) | arXiv simülasyonu [K] |
| Ekip boyutu | 3–7 (Putnam), 3–9 (Scrum), <10 (Amazon) | [K] |
| Küçük ekip kazancı | 3–4 kat ucuz, 2–3 kat az hata | QSM [K] |
| Mühendis:PM | 5:1 → 11:1 | Pave [K] |
| Refinement payı | ≤%10 kapasite | Scrum 2017 [K] |
| Keşif önde çalışma | 1–2 sprint (geçiş modeli) | Zurb/Gothelf [K] |
| Yönetici ilk eşik | 10–15 mühendis | Grabyo [K] / techinterview [görüş] |

---

## 6. Bulunamayanlar

- **Hiç ayrı test yokken** (yalnız geliştirici) defect escape oranı için birincil ölçüm. Elde yalnız "elle birim testi %38" ortalaması var; "testçisiz ekip %X kaçırır" doğrudan ölçülmemiş.
- **En iyi testçide gerçekçi taban.** Tek kişi için ölçüm yok; aşama düzeyinde tavan (%55–60) var.
- **Tasarımcı:geliştirici oranı** ve PM:tasarımcı oranı: sağlam kaynak yok.
- **Küçük ve büyük iş için hazırlık (tasarım) süresi farkı**: sayısal veri yok.
- **Brooks'un 1/3–1/6–1/4–1/4 takvim kuralı**: model bilgisi, doğrulanmadı.
- **QA/test oranının şirket büyüdükçe değişimi** için tek şirketin zaman serisi: yok. Microsoft ve Google geçişi ve sektör aralıkları var.
- **Atlassian DoR ve WIP sayfaları**: gövde metni alınamadı. **pnsqc (Jones 2013) ve QSM `team-size-can-be-key` sayfası**: 404. **Team Topologies Vikipedi**: 404.
- **Pave EM kapsamı ısı haritası** (şirket büyüklüğüne göre sayılar): görsel olduğu için okunamadı.
- Arama özetinden gelip sayfası açılmayanlar [A] olarak işaretlendi (LogiGear anketi, Cagan 6–10, Amazon 10:1, Below karşı kanıtı, kanban/test darboğazı blogları).
- Steam/ekran görüntüsü URL'leri: kapsam dışı.


---

## 7. Tamamlama (2026-10-17, başsız Chrome)

Bu raporun boşlukları gerçek yazılım ekibi literatürüne ait (makaleler, anketler); bu turda okunan kapalı siteler (Fandom, wiki.gg, Reddit, Steam rehberleri) onları kapatmıyor. Aşağıdakiler yalnızca OYUN VERİSİ: gerçek pratik değil, oyunların kendi ayarları; karşılaştırma ve kalibrasyon için not düşülmüştür.

### 7.1 §6'daki "tasarımcı:geliştirici oranı" için oyun verisi

- Software Inc (Beta 1.6, oyuncu rehberi, yalnız 2010; Tasarımcı/Programcı/Sanatçı): "Base" (ek özellik yok) kadrolar: Bilgisayar OS 5/8/0, Spor dışı oyun 2/3/2, Ofis yazılımı 2/2/1, 2D Editor 2/3/1; "Complete" (tüm ek özellikler): Bilgisayar OS 13/24/1, Spor dışı oyun 13/18/8, Ofis yazılımı 8/12/5, Audio Tool 10/19/2. Tasarımcı:programcı oranı yaklaşık 1:1,5 ile 1:2 arasında; sanatçı çoğu üründe en az pay alıyor. Max's Beginners Guide: 10-12 kişilik ekip; örnek çok rollü ekip 2 tasarımcı, 5 programcı, 1 sanatçı (1:2,5:0,5). Kaynaklar: https://steamcommunity.com/sharedfiles/filedetails/?id=2991702551 ve https://steamcommunity.com/sharedfiles/filedetails/?id=1198857114 . Bu, "gerçek pratik" değil, oyun tasarımcısının ürün tipine bağladığı kabul. Alpha 10 rehberi (2010, hepsini seç): Oyun 5-8-7, Ofis 4-8-2 (https://steamcommunity.com/sharedfiles/filedetails/?id=1327768314).
- Startup Company: yönetici kapasitesi Beginner 3, Intermediate 5, Expert 8 çalışan; İK Yöneticisi 3/5/8 yönetici yönetir (yani iki katmanlı bir yönetim kapsamı, gerçek yazılım şirketlerinde "yönetici başına 5-8 kişi" kuralıyla örtüşüyor). Kaynaklar: https://startupcompany.fandom.com/wiki/Manager ve https://startupcompany.fandom.com/wiki/HR_Manager
- Game Dev Tycoon: orta oyun için optimal ekip 2 (sürüm 1.3.9 sayfası) ya da 3 kişi yüksüz (sürüm 1.4.5 rehberi: orta 3, büyük 5, AAA 6 kişi). Kaynaklar: https://gamedevtycoon.fandom.com/wiki/Tech_and_Design_Points_Generation_Algorithm ve https://gamedevtycoon.fandom.com/wiki/Game_Development
- Software Inc: destek ekibini 30 kişinin altında tutmak (oyuncu ipucu) ve test/QA için ayrı rol yok; hata düzeltme kapasitesi en yetenekli kişiye bağlı (R1 §1 madde 4).

### 7.2 Hâlâ bulunamadı

- Hiç ayrı test yokken defect escape oranı, en iyi testçi için tek kişilik taban, QA oranının zaman serisi, Brooks'un 1/3-1/6-1/4-1/4 kuralı, Atlassian/QSM/pnsqc/Team Topologies sayfaları, Pave ısı haritası: bu turun kapsamı dışında; denenmedi.
