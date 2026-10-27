# R10 · Testte bulunan hata, sprint içinde düzeltme, "bilinen hatayla gönder mi, bekle mi" kararı

Tarih: 2026-10-17. Hazırlayan: araştırma alt ajanı. Kod, B dosyaları ve oyun dosyalarına dokunulmadı; Godot koşturulmadı. Tek yazılan dosya bu rapor (oyuncak simülasyon scratchpad'dedir, `python -I` ile koştu).

Bağlam: Erdem'in kararı (ERDEM_CDQ_CEVAP.md, D2): kartta "hata ihtimali %35" yazmayacak; sprint içinde "testçiler N hata buldu, M'si düzeltildi" görünecek; sprint sonunda "bu kartlarda N bilinen hata bulundu, M'sini çözdük; bu haliyle gönderelim mi, sonraki sprinte mi atalım" sorusu sorulacak; en iyi testçinin %43'ü kaçırması fazla bulundu. Bugünkü model: H = 0,03 × S × tür × (1 − 0,25 hazırlık) × yapım kalitesi (`D_MODEL_v2.md:361`), yakalama C = 0,40 × √Y(Test), en çok 1 (`:371`), tablo 0★ %28 ... 5★ %57 (`:379-381`), kaçan E = H × (1 − C), kapanışta Poisson çekilişi (`:383-385`), ekranda "Hata ihtimali" (`:387`).

## 0. Özet

1. **%57 tavanı gerçek verinin "tek test aşaması" tavanıdır, sprint kalitesinin tavanı değildir.** Capers Jones'a göre tek test aşaması ortalama %35-45, en iyi durumda %55 yakalar (sistem testi 27/42/55, bağımsız test 15/35/42; min/ort/maks). Aynı veri dört aşamalı klasik zincir için toplam %85 verir; inceleme ve statik analizle %95-99. Bizim "Test" aşaması tek aşama gibi modellendi ama gerçek takımda bir sprintte yazanın kendi denemesi, akran gözü ve testçi birlikte çalışır. Erdem'in itirazı veriyle uyumlu (§2.1, §4.1).
2. **Öneri: yakalamayı zincir yap.** C = 1 − (1 − 0,38) × (1 − t(★)): yazanın kendi kontrolü %38 (Jones elle birim testi ortalaması) ve testçinin aşaması t. İki ayar önerilir. P (Jones ortalaması): 1★ %57, 3★ %64, 5★ %72. Q (deneye dayalı test uzmanı, Jones ortalama %75, maks %85): 1★ %60, 3★ %71, 5★ %81. Testi kısalt: C = %38 (bugünkü 0 değil). Testçisiz, test kutusu olan kimse yok: kart bekler (bugünkü davranış, değişmez) (§4.1).
3. **Yakalama yükselince H büyümeli.** Kaçan hata A'nın hedefinde kalsın diye H katsayısı 0,03'ten yaklaşık 0,047 (P) ile 0,056 (Q) arasına çıkar (simülasyonda 1,5-1,9 kat). Bunun iyi yan etkisi: "bulunan hata" sayısı ekranda anlamlı olur. Sprintte bulunan hata: 6 kişide ~2,4, 12 kişide ~5, 25 kişide ~12, 50 kişide ~25 (P). Tek kurucuda sprint başına 0,6: çoğu sprint "0 hata bulundu" yazar (§4.2, §5).
4. **Bulunan hatanın düzeltmesi pahalı değil, kuyruklu.** 171 projelik gerçek veride (Menzies ve diğerleri, 2017) bir hatanın düzeltme süresi medyan 8-15 dakika, 90. yüzdelik 31-126 dakika; hatayı geç bulmak "10-100 kat" pahalı değil (erken/geç oranı 1,1; gecikme etkisi bulunamadı). Gerçek geç bedel müşteri tarafında. Oyunda sprint içi düzeltmenin dev kapasitesine yükü küçük (kapasitenin %3-4'ü, 1,3 puan/hata varsayımıyla); bilinen hata kalmasının asıl nedeni "geç bulundu, zaman yok" ve "ağır hata". Bu yüzden maliyet ağır kuyruklu olmalı (§2.5, §4.4).
5. **Düzeltme kapasitesi kartı yapan geliştiricilerin sprint zamanından düşer**, test eden kişi yeniden test payı öder (0,3 puan, tahmin). Scrum Guide: Done olmayan iş sprint sonunda backlog'a geri döner; uygulama yazını: sprintte bulunan hata kartın parçasıdır (§2.3, §4.4).
6. **Hiçbir oyunda zorunlu "gönder mi" sorusu yok.** GDT, Mad Games Tycoon 2 ve Game Dev Story'de varsayılan "hata ayıklama kendiliğinden sürer"; Software Inc'te oyun hiçbir şey sormaz, oyuncu kendi kuralını koyar. Erken çıkış oyuncunun başlattığı bir eylemdir (düğme, ilerleme sekmesine dokunmak, kendi kuralı). Erdem'in sprint sonu sorusu yeni bir kalıp; sıkıcı olma riski bu yüzden gerçek (§3, §4.3).
7. **Mutlak eşik ölçekte kırılır; oransal eşik kırılmaz.** Oyuncak simülasyonda "en az 1 bilinen hata varsa sor" kuralı 1 kişide sprintlerin %7'sinde, 50 kişide %71-94'ünde (düzeltme maliyetine göre) soru çıkarır. "Bilinen hata bulunanın %25'ini aşıyorsa sor" kuralı her ölçekte %5-30 bandında kalır (§4.3).
8. **Soru sıkmasın diye:** sprint başına en çok bir toplu soru; yeşil durumda sessiz gönderim (yalnız bir mail satırı); bir kerelik "sürüm politikası" ayarı; soru yalnız gerçek bedeli varsa (söz tarihi, müşteri isteği) çıksın; aynı cevap art arda verilince politika öner. Dış kanıt: ilaç uyarılarının %49-96'sı geçiliyor (alarm yorgunluğu); MGT2 oyuncuları tekrarlayan "ücretsiz güncelleme" kararı için otomasyon istiyor (§4.3).
9. Aşağıda 8 madde tasarımcıya.

## 1. Kaynak durumu

- WebSearch: 12 (sınır). WebFetch: ~27. Başsız Chrome ile 2 deneme.
- **GDT Fandom (Bugs, Review Algorithm)**: bu turda Cloudflare doğrulama sayfası döndü (WebFetch 402, başsız Chrome 2 kez "Bir dakika lütfen"). GDT sayısal bilgisi `R3_GDT_MGT2.md` §7.1'den alındı (aynı gün başsız Chrome ile açılmış, sürüm 1.3.9 uyarılı); bu turda yeniden doğrulanmadı. (R3 sürüm uyarısı geçerli.)
- **Mad Games Tycoon 2 Fandom**: kapalı (R3). Steam konuları açıldı.
- **Myers 1978** (ACM) 403; yalnız IBM/ACM kayıt sayfaları ve arama özeti. "%38 yakaladı" iddiası doğrulanamadı; kullanılmadı.
- **Basili ve Selby 1987** sayıları bulunamadı. **Itkonen 2014** (Springer) kimlik doğrulama yönlendirmesi; yalnız arama özeti.
- Reddit denenmedi (önceki turlarda engelli). Software Inc wiki "Bugs" sayfası 404.
- arXiv 1401.8069 (birleşik hata yakalama) PDF'si okunabilir metin vermedi ve kalitesiz görünüyor (yazar alanı anlamsız); kullanılmadı.
- Çıkarım ve tahminler ayrıca "(tahmin)" ya da "(kaynaksız)" işaretli.

## 2. Gerçek pratik

### 2.1 Tek aşama ve toplam yakalama (Jones DRE)

Kaynak: Capers Jones, "Raising Defect Removal Efficiency (DRE) Levels", PDF (bu turda `pdftotext` ile okundu): https://www.ppi-int.com/wp-content/uploads/2021/01/Software-Defect-Removal-Efficiency.pdf (Tablo 2). R4 aynı tablonun bir bölümünü vermişti; burada eksik satırlar eklendi.

| Aşama | Min | Ort. | Maks |
|---|---|---|---|
| Deneye dayalı test (experiment-based) | %60 | **%75** | %85 |
| Riske dayalı test | %55 | **%70** | %80 |
| Güvenlik testi | %50 | %65 | %80 |
| Sistem testi | %27 | %42 | %55 |
| Fonksiyon testi | %33 | %40 | %55 |
| Birim testi (otomatik / elle) | %20 / %15 | %40 / %38 | %50 / %50 |
| Bağımsız test | %15 | %35 | %42 |
| Kabul testi | %15 | %35 | %40 |
| Regresyon testi | %35 | %35 | %45 |
| Akran incelemesi (gayriresmî) | %35 | %50 | %60 |
| İkili programlama | %40 | %55 | %65 |
| Masabaşı kontrol (desk checking) | %25 | %45 | %55 |
| Biçimsel kod incelemesi | %60 | %85 | %96 |

- Sayfanın kendi ortalaması: test aşamaları ortalama %44 (maks ortalaması %55); inceleme ve statik analiz grubu %69.
- Toplam: dört aşamalı klasik test (birim %38, fonksiyon %40, regresyon %35, sistem %42, hatalı düzeltmeler %7 enjekte) = **%85,3**; inceleme + statik analiz + testle **%98,3** (aynı PDF, Tablo 3 ve 4). "Bu birleşim %95'i aşmanın bilinen tek yolu."
- **Hatalı düzeltme (bad fix)**: düzeltmelerin %7'si (düşük kalite) ya da %3,5'i (yüksek kalite) yeni hata sokar. D modelindeki düzeltme türü çarpanı 0,3 (`D_MODEL_v2.md:367`) bunun karşılığı.
- Çıkarım (tahmin): Maks. %55 sütunu "tek bir aşama, çok iyi uygulanmış" tavanıdır. Deneye dayalı test satırı (%75, maks %85) tek bir aşama değil, kişinin keşif yapan bir strateji yürütmesidir; Jones bunu ayrı tutuyor. Yani 5★ bir testçinin tek geçişte %70-80'e çıkması veriyle çelişmiyor.

### 2.2 Tek kişinin yakalaması ve kişi sayısı

- Myers (1978, CACM), 59 deneyimli profesyonelle 7 yöntem: **birbirinden bağımsız çalışıp bulgularını birleştiren testçi çifti** en etkili yöntem; denekler arasında büyük değişkenlik. Doğrulanan yer: arama özeti; kayıt sayfaları https://researcher.watson.ibm.com/publications/a-controlled-experiment-in-program-testing-and-code-walkthroughsinspections ve https://cacmb4.acm.org/magazines/1978/9/11171-a-controlled-experiment-in-program-testing-and-code-walkthroughs-inspections . Sayısal ortalama doğrulanamadı.
- Itkonen, Mäntylä ve Lassenius: 79 öğrenci, 90 dakikalık iki oturum; keşif testi ile senaryolu test **hata bulmada anlamlı fark yok**, senaryolu test anlamlı ölçüde daha çok yanlış hata raporu üretti. Kaynak (arama özeti): https://www.academia.edu/21718390/Defect_detection_efficiency_Test_case_based_vs_exploratory_testing . Bize dersi: yakalamayı belirleyen kişi ve strateji, test senaryosu sayısı değil.
- Testçi:geliştirici oranı: R4 oranların sektöre bağlı olduğunu verdi (Microsoft 1:1, düzenlemeli sektör 4-7:1). Ganssle sayfası "Microsoft'ta 1:1 deniyor" der ve oranı hata yakalama ile **bağlamaz** (https://ganssle.com/rants/testertodeveloperratio.html). Capture-recapture yazını (Petersson ve diğerleri) aynı hatayı birden çok kişinin bulmasını kalan hata tahmini için kullanıyor; kişi başına marjinal kazancı ölçen bir çalışma **bulunamadı** (arama özeti: https://ebse.webspace.durham.ac.uk/ebse-bibliography/capture-recapture-in-software-inspections-after-10-years-research-theory-evaluation-and-application/ ).
- Sonuç: oranın etkisi büyük olasılıkla yakalamada değil **kuyruk ve zaman** üzerindedir. D_SIM zaten bunu gösteriyor: 5★ testçi kart başı kaçanı %32 düşürüyor ama testçi hızlandığı için ekipte açık hata ve düzeltme payı aynı kalıyor (`D_SIM.md:284`).

### 2.3 "Done" tanımı ve sprint içi düzeltme

- Scrum Guide: Definition of Done, Artırımın ürün için gereken kalite ölçülerini karşıladığı durumun biçimsel tanımıdır; DoD'yi karşılamayan öğe "yayınlanamaz, hatta Sprint Review'da sunulamaz", **Product Backlog'a geri döner**. Sprint boyunca "kalite düşmez". https://scrumguides.org/scrum-guide.html (bu turda açıldı, alıntı doğrulandı).
- Uygulama yazını (arama özeti, Scrum.org ve Atlassian topluluk cevapları): sprintte bulunan hata mümkünse aynı sprintte düzeltilir; yetişmezse hikâye tamamlanmamış sayılıp backlog'a döner ya da hatayla ilgili ayrı iş açılır; sprint kapandıktan sonra bulunan hata yeni backlog öğesidir. https://www.scrum.org/node/6654 , https://www.scrum.org/node/40798 , https://www.infoq.com/news/2009/07/coping-with-bugs . (Pratisyen görüşleri; resmî kural değil.)
- Bize dersi: Erdem'in "gönder / sonraki sprinte at" sorusu Scrum'daki "Done değilse backlog'a döner" kuralının oyuncuya bırakılmış hâli. Scrum'da seçenek yoktur, kural DoD'dir. Oyunda bu seçim oyuncunun elinde olacağı için varsayılan ve eşik gerekir (§4.3).

### 2.4 Bilinen hatayla yayın: triage, go/no-go

- **Mozilla (Firefox 4 triage)**: bir hatanın sürümü bloklayıp bloklamayacağı "bileşen liderleri ve ürün sürücülerinin yargısı"; blok adayı olarak sunarken "neden bloklamalı, düzeltmemenin riski, düzeltmenin riski, nedeni" yazılır; blok edici sayılanlar: önceki sürümden regresyon, yeni kararsızlık kaynağı, yeniden üretilebilir çökme; sonuç: düzelt, geçersiz, düzeltilmeyecek ya da gereksinimi sonraki kilometre taşına ertele. https://wiki.mozilla.org/Firefox/4/Triage (arama özeti; sayfa bu turda açılmadı). Firefox 3 sayfası P1-P5 katmanı: P1 mutlak blok, P3 "etkisi bilinen, gönderilmeye razı olunan hata" (özet, aynı kaynak türü): https://wiki.mozilla.org/Firefox3/Drivers/Triage .
- **Eşik tabanlı go/no-go**: sürüm yönetimi araçları "en düşük geçme oranı, en çok açık hata, en düşük kanıt kapsaması" eşikleriyle EVET/HAYIR verir; eşik tutmazsa hangi ölçüt düştüğünü gösterir (satıcı sayfası, zayıf kaynak): https://testcollab.com/features/release-management-tool . Bilinen hata tablosunda "geçici çözüm" ve "bloklayıcı mı" sütunları, geri alma yolu (satıcı/topluluk şablonu, zayıf): https://claudeskills.info/skill/qa-release-signoff/ .
- **Google SRE hata bütçesi**: yayın hızını tek tek toplantı değil bir bütçe sürer; ölçülen çalışma süresi SLO'nun üstündeyken yeni sürümler çıkar, bütçe bitince yayın durur ve ekip test ve dayanıklılığa yatırım yapar; "güvenilirlikte her ek iyileştirme bir öncekinden 100 kat pahalı olabilir." https://sre.google/sre-book/embracing-risk/ (bu turda açıldı).
- Bize dersi: gerçek pratikte karar (a) önem derecesine (blok edici/değil), (b) bir eşik ya da bütçeye, (c) belgelenmiş etki ve geri dönüş yoluna dayanıyor; "her sürümde herkes oy verir" değil. Oyun için en yakın model eşik/bütçe + yalnız sınırdaki durumda insan kararı.

### 2.5 Bulunan hatayı düzeltmenin eforu

- Menzies, Nichols, Shull, Layman, "Are Delayed Issues Harder to Resolve?", Empirical Software Engineering 22(4), 2017: https://arxiv.org/abs/1609.04886 (PDF bu turda `pdftotext` ile okundu). 171 TSP projesi (2006-2014; medyan ekip 7, en çok 40; medyan süre 46 gün). Hata düzeltme süresi **medyan 8-15 dakika** (kodda doğan hata: kod incelemesinde 10, sistem testinde 13 dakika; bir satırda 24); **90. yüzdelik 31-126 dakika**. "Hatayı sistem testinde düzeltmek tasarım incelemesinde düzeltmeye göre yalnız 1,11 kat." Yazarlar gecikmenin maliyeti üstel artırdığına dair kanıt bulamadı ("we found no evidence for the delayed issue effect"). Eski 1:117 ve 1:137 oranları (Toshiba, IBM çalıştayı) ham veri verilmediği için doğrulanamıyor. NASA JSC verisinde kritik olmayan hatalar: erken 1,2 saat, geç 1,5 saat. Sınır: TSP disiplinli takımlardır, küçük proje; çok geç ve büyük bulgular için genelleme yapılamaz.
- Açık kaynak izleyici verileri (medyan 7,4 saat ile 5,3 gün) **takvim süresidir**, efor değil; kuyruk süresi içerir (https://arxiv.org/pdf/2006.00586 , https://arxiv.org/pdf/2103.11518 , arama özeti). Efor olarak kullanılmadı.
- Jones'un 3,5-7% hatalı düzeltme enjeksiyonu (§2.1): düzeltmenin kendisi risk taşır, bu yüzden "yeniden test" payı gerekir.
- Bize dersi: hatayı sprintte düzeltmenin dev maliyeti küçük ve ağır kuyruklu (medyan 10 dakika, p90 ~1-2 saat). Geç düzeltmenin asıl bedeli geliştirici saati değil, müşteriye etkisi (A'nın memnuniyet ve itibar mekanizması). Oyunda "geç düzeltme" saati 5-10 kat şişirmek veriyle desteklenmiyor; bugünkü A düzeltme kartı (5 ve 10 puan, `D_MODEL_v2.md:696`) bir hata için 1,25-5 puan/hata, sprint içi 1,3 puana göre 1-4 kat; bu verinin üst sınırında.

## 3. Oyunlar

Her oyunda: sayı, ekran, karar sıklığı, varsayılan, şikâyet.

### 3.1 Game Dev Tycoon
- **Kural** (R3 §7.1, `R3_GDT_MGT2.md:162-164`; Fandom'dan başsız Chrome ile alındı, sürüm 1.3.9, bu turda yeniden doğrulanamadı): her doğan Tech/Design puanı için hata olasılığı = 1 − (0,44 + 0,5 × Q), Q çalışan kalitesi; seviye 1 çalışan %31, seviye 4 çalışan ve seviye 3 yönetici %6 (taban); ayrıca %5 rastgele hata puanı. Yani **hata, üretilen puanla orantılı** (büyük oyun, çok hata) ve **kalite faktörüne bağlı**. Hatalar geliştirmenin son aşaması "Finishing"te kendiliğinden silinir ("birkaç haftadan bir aya kadar"); hız çalışanın Speed niteliğine bağlı.
- **Puana etkisi**: oran r = 1 − 0,8 × (hata × 100 / (Tech + Design)), 0-100'e kırpılır. r < 0,9: "Too many bugs"; r ≤ 0,6: "Riddled with bugs". Ölçü **göreli** (puanın yüzdesi), büyük oyun mutlak sayıyla cezalanmaz.
- **Ekran**: hatalar kırmızı baloncuk olarak çıkar; ayrı bir hata sayısı gösterilip gösterilmediği kaynaklarda yok (R3 yalnız "hatalar toplam puanın yüzdesi" der). Oyuncu "hata düzeltmeyi bırak, çıkar" diyebilir; hatalı oyun çıkarılabilir ve kötü puan alır, zorlama yok (https://www.tekrevue.com/game-dev-tycoon-review-minor-flaws-dont-kill-the-fun/ , arama özeti).
- **Yayın sonrası yama**: çıkışta gizli kalmış hatalar oyuncularca bulunursa bir yama istemi çıkar; tek çalışan ister; hayran kazandırır, satışta küçük sıçrama yapar (R3).
- **Karar sıklığı ve varsayılan**: oyun başına bir "çıkar" anı; varsayılan "düzeltme kendiliğinden sürer".
- **Şikâyet**: Steam'de "bugs" araması 758 sonuç; incelenen on tanesinin hepsi oyunun kendi teknik hataları (çökme, kayıt), hata mekaniği hakkında şikâyet görülmedi (https://steamcommunity.com/app/239820/discussions/search?q=bugs). Bu bir yokluk kanıtıdır, "memnun" kanıtı değil.
- **Ölçekte**: hata puanla büyür ama oran r ile cezalanır; büyük oyun kendiliğinden cezalanmaz. Tek önemli ders: **göreli ölçüt**.

### 3.2 Software Inc.
- **Kural** (R1 `R1_SOFTWARE_INC.md:109-115`): hata sayısı Alpha 9'dan beri **gizli**; alfa/beta'da hatalar temizlenir; beta uzunluğu oyuncu seçimi (tipik 3-6 ay); yayın sonrası destek ekibi kalan hataları bulur. Hata düzeltme kapasitesi "göreve atanmış tüm ekiplerdeki en yetenekli kişi"ye bağlı (Eylül 2024). Hata kaliteyi bozmaz, iade ve destek yükü olarak döner.
- **Oyuncu sayıları** (Steam, 2017-2018): beta'da düzeltilen hata 100-300 tipik, bir ekip yıl boyu ~1000; destek yayından sonra 500-1500 hata daha buluyor; birim kod başına ~50 hata (oyuncu tahmini); 600 bin satışta ~25 bin iade, 1 milyon satışta 71 iade; "hataları düzelttiğin sürece satışı öldürmez, etkisi belirsiz". https://steamcommunity.com/app/362620/discussions/0/1470841715955280426 ve https://steamcommunity.com/app/362620/discussions/0/1696043263502958919 .
- **Karar**: "ne zaman yayınlayayım" oyuncunun kendi kuralıyla verilir: "hata keşfi yavaşlayınca" (günlük düzeltilen hata sayısını takip ederek), ya da rakiple yarış için erken. Oyun bir eşik ya da öneri vermiyor.
- **Şikâyet**: gizli toplam yüzünden "ne zaman çıkaracağım" belirsizliği (konular: "Amount of bugs", "Beta / bugs / fixed", https://steamcommunity.com/app/362620/discussions/search?q=bugs+beta+release ); 2022 konusunda beta'nın dengesiz, hata düzeltme özelliğinin dengesiz bulunması. Bu bizim için gizli toplamın riskidir (R1 §5).
- **Ölçekte**: büyük ürün yüzlerce hata; destek ekibi boğulabilir (oyuncu).

### 3.3 Mad Games Tycoon 2
- **Kural/ekran** (Steam konuları, 2021-2023; wiki kapalı): oyun bitince "hiçbir zaman pazara hazır değildir"; **dört seçenek**, sonuncusu "Polish": hata siler, QA odasının işini tamamlar; QA odası hata düzeltmeye atanabilir. Hata sayısı **görünür** ("bir sayı"), QA odasında "bulunacak kalan hata" çubuğu var. https://steamcommunity.com/app/1342330/discussions/0/3114770279409920182/ , https://steamcommunity.com/app/1342330/discussions/0/5358712989073876926/ .
- **Bedel**: hatalı çıkış "potansiyel satışı" düşürür, derecelendirme düşer, "sour fans" olayı tüm satışı vurur; "ücretsiz güncelleme" ile çıkış sonrası düzeltme cilalamadan **çok daha hızlı** (oyuncu: "highly exploitable in the early game"), ama puan düşer. https://steamcommunity.com/app/1342330/discussions/0/3766732716814125281/ (Ocak 2023).
- **Karar sıklığı**: oyun başına bir "cilala mı, çıkar mı"; ayrıca her güncelleme ayrı karar. **Şikâyet**: bir oyuncu "kaç ücretsiz güncelleme yapıldığını takip etmek zor" diye otomatik ayar istiyor; bir topluluk modu bunu otomatikleştiriyor (kararsız). Genel inceleme özeti: orta/geç oyun menü yönetimi monotonluğu, otomasyon eksikliği (https://vaporlens.app/app/1342330/mad_games_tycoon_2.md , otomatik özet). Yani **tekrarlayan elle karar sıkıcı bulunuyor**.
- **Oyuncu önerisi (oyunda yok)**: gizli hata + QA'nın kademeli bulması; "geliştirici hataların ~%10'unu, QA %95'ine kadar bulsun" (morph113, 24 Ocak 2021, https://steamcommunity.com/app/1342330/discussions/0/3114770279410380903/). Başkaları "bulunmayan hata düzeltilemez" ve "toplam bilinmesin" konusunda ayrışıyor: bir oyuncu bilinmeyen sayıyı "ihtiyacım olmayan bir veri" buluyor. Not: bu sayılar bir oyuncunun önerisi, oyunun kuralı değil.
- **Varsayılan**: "Polish" seçeneği kalan hatayı otomatik silen devam eden süreç; zorunlu soru yok.

### 3.4 Game Dev Story (Kairosoft)
- https://kairosoft.wiki.gg/wiki/Creating_games_(Game_Dev_Story) (bu turda açıldı). Hata, üretim sırasında Fun/Creativity/Graphics/Sound puanlarıyla birlikte **ara sıra** düşer; başarısız "Boost" büyük yığın yaratır; %25 noktasında "oyunu iyileştir" olayı başarısızsa **20-30 hata** ekler. Sayı alt çubukta puanlarla birlikte (adet).
- Oyun bitince **Debugging** aşaması: çalışanlar hataları yavaş siler; süre hata sayısına ve program becerisine bağlı. Atlanabilir ("tavsiye edilmez"): ilerleme sekmesine dokununca erken çıkış; eleştirmen hata bulursa puan düşer (4 eleştirmen × 10; Hall of Fame için 32), kaybedilen miktar yazılı değil. **Silinen her hata 1-3 araştırma puanı verir**: düzeltme bir ödül.
- Karar sıklığı: oyun başına, oyuncunun başlattığı. Varsayılan: Debugging kendiliğinden çalışır.
- Şikâyet: bulunamadı (iCulture topluluk tavsiyesi: "hatayla çıkarma", doğrulanmamış).

### 3.5 Öbürleri
- **Startup Company**: R2'de hata mekaniği bulunamadı; kalite = özellik seviyesi ve memnuniyet (`R2_STARTUP_COMPANY.md:99,226`). Bu turda yeniden aranmadı.
- **City Game Studio, Game Dev Studio, Software Tycoon**: arama yaptım, hata mekaniği anlatan kaynak çıkmadı (yalnız oyunların kendi çalışma hataları); mekanik varlığı/yokluğu **bulunamadı**.
- Kairosoft'un öbür oyunlarında (Mega Mall vb.) hata ayıklama kavramı yok (kaynaksız).

### 3.6 Karşılaştırma

| Oyun | Oyuncuya sayı | Ölçü | Karar | Varsayılan | Bedel |
|---|---|---|---|---|---|
| GDT | hata baloncuğu (sayı belirsiz) | göreli (puanın %'si) | çıkış anında, oyun başına | düzeltme sürer | puan düşer, mesaj |
| Software Inc | gizli toplam; düzeltilen sayısı | mutlak | oyuncunun kendi kuralı | yok | iade, destek yükü |
| MGT2 | görünür sayı + QA çubuğu | mutlak | 4 seçenekli, oyun başına | Polish sürer | potansiyel satış, sour fans |
| Game Dev Story | adet | mutlak | oyuncu dokunuşuyla erken çıkış | Debugging sürer | puan, araştırma ödülü kaybı |

Ortak: **sayı (varsa) adet olarak gösterilir, yüzde olarak değil** (Erdem'in tercihiyle uyumlu; GDT'nin yüzdesi yalnız içeride, puan formülündedir); varsayılan "düzeltme kendiliğinden sürer" (Software Inc hariç); zorunlu bir "gönder mi" kapısı yok.

## 4. Sentez

### 4.1 Yakalama aralığı

Erdem %57'yi az buldu. Gerekçe: o sayı tek geçişlik test aşamasının, Jones'un klasik aşama tavanı (%55) ile uyumlu değeri. Ama bir sprintte yakalama zinciri: yazanın kendi kontrolü + testçi (+ akran gözü, bu rapor onu zincire koymuyor).

**Formül:** C(★) = 1 − (1 − c_kendi) × (1 − t(★)), c_kendi = 0,38 (Jones elle birim testi ortalaması, aralık %15-50), t testçinin aşama yakalaması.
- **P (Jones ortalaması):** t = 0,24 + 0,062 × ★ (1★ 0,30; 3★ 0,43; 5★ 0,55 = Jones klasik aşama maks.).
- **Q (deneye dayalı test uzmanı):** t = 0,35 + 0,0875 × (★ − 1) (1★ 0,35; 3★ 0,525; 5★ 0,70; Jones ort. %75, maks %85'in altı).

| Testi yapan | Bugün (tek geçiş) | P | Q | Kaçan (bugün → P → Q) |
|---|---|---|---|---|
| Test yok (kutu yok) | kart bekler | kart bekler | kart bekler | (değişmez) |
| Testi kısalt (kayıt kesilir) | %0 | **%38** | %38 | (kendi kontrolü kalır) |
| Kurucu 0★ | %28 | %53 | %54 | %72 → %47 → %46 |
| 1★ | %32 | %57 | %60 | %68 → %43 → %40 |
| 2★ | %37 | %61 | %65 | %63 → %39 → %35 |
| 3★ | %43 | %64 | %71 | %57 → %36 → %29 |
| 4★ | %50 | %68 | %76 | %50 → %32 → %24 |
| 5★ | %57 | %72 | %81 | %43 → %28 → %19 |

(Hesap: `1 − 0,62 × (1 − t)`; bugünkü sütun `D_MODEL_v2.md:379-381`.) Kaçan sütunu Erdem'in "%43'ü kaçırıyor" itirazının sayısıdır.
- İkincil rolde test eden geliştirici: hız çarpanı 0,7 (D'nin uyumu), yakalama kendi Test yıldızına göre aynı tablodan okunur; D'deki "uyum hızı keser, kaliteyi kesmez" ilkesi (`D_MODEL_v2.md:376`) korunur. Yani 2-3★ test kutulu geliştirici %61-64 (P).
- Üst sınır yine var (%72-81): Jones'a göre testle %95'e çıkılmaz, inceleme ve statik analiz gerekir. Oyunda bu ileride bir "kod incelemesi/otomasyon" yeteneği olabilir (R4 §2.3 de aynı yöne işaret ediyordu); bu raporun kapsamı dışı.
- **Tutarlılık**: gerçek zincirde bile (Jones 4 aşama) toplam %85; bizim zincirimiz 2 halkalı (kendi + testçi), bu yüzden P/Q'nun toplamı %85'in altında kalıyor; bu bilinçli (inceleme yok).
- Oran karşılaştırması: tek testçi 5★'ın %72-81'i, Jones'un "deneye dayalı test" ortalaması %75 ile örtüşüyor.

**H'ye etkisi**: yakalama yükselince kaçan hata düşer (3★ testçide kart başı kaçan 0,57 H → 0,36 H (P) ya da 0,29 H (Q), yani %38-49 düşüş). A'nın hedefleri (açık hata, düzeltme payı) bugünkü kaçan hataya göre kalibre; aynı kaçanı korumak için H katsayısı 0,03'ten büyür. Simülasyonda (§5) kalibrasyon katsayısı P'de 1,52-1,59 (H0 ≈ 0,046-0,048), Q'da 1,57-1,88 (H0 ≈ 0,047-0,056). Bu, A'ya dokunmadan yeni H0'ın seçilebileceği anlamına gelir. **Tasarım sabiti, onay bekliyor**; D_SIM bu zincirle yeniden koşulmalı.

### 4.2 Sprint içi akış: bulunan, düzeltilen, bilinen

Öneri (Scrum ve GDT/GDS yapısıyla uyumlu):
1. Test aşaması hata **bulur**: bulunan sayı n ~ H' × C (tohumlu, deterministik; kart ve sprint kimliğinden).
2. Bulunan hata kartın **geliştirme aşamasına geri döner**: n × (düzeltme puanı) iş, ardından n × 0,3 puan yeniden test (§4.4).
3. Sprint süresi yetmediyse (kart sprintin sonuna yakın test edildi, ya da hata ağır) kalan hata **bilinen hata** olur: kartın bilgisinde "N bulundu, M düzeltildi, K bilinen".
4. Sprint sonu: K > 0 ise gönder/beklet (§4.3). Gönderilen K hata, A'nın hattına **açık hata** olarak yazılır (Hat panelinde zaten görünür, A K6); gönderilmeyen K hata kartla birlikte sonraki sprintte düzeltme işi olarak devreden gelir (A'nın 5/10 puanlık düzeltme kartı yerine kartın kendi hatası; ya da aynı düzeltme kartı; seçim tasarımcıda).
5. Hâlâ **bulunmamış** (kaçan) hata E = H' × (1 − C): ekrana hiç çıkmaz, yayından sonra A'nın akışıyla "açık hata" olarak belirir (Poisson yerine tohumlu kesir biriktirme de olur: GDT 0,6 eşiği gibi, R3 `:157`).

Ekran örnekleri (oyuncuya görünen, tire yok):
- Kart satırında sprint içi: "Test: 3 hata bulundu, 2'si düzeltildi."
- Sprint özeti: "Testçiler bu sprintte 11 hata buldu. 7'si düzeltildi, 4'ü bilinen olarak kaldı."
- Soru: "Bu sprintin kartlarında 4 bilinen hata kaldı. Bu haliyle gönderelim mi, yoksa sonraki sprinte mi bırakalım?" Düğmeler: "Gönder" ve "Sonraki sprinte bırak". Sonuç satırı: "Gönderirsen: Hat paneline 4 açık hata yazılır. Bırakırsan: kart bir sprint daha sürer."

**Prensip uyumları**: Prensip 5: sprint içi bulunan sayı olay olarak çıkar, plan ekranı bulunan hata sayısını **vaat etmez** (yalnız darboğaz ve kapasite). Bu D_MODEL §3.6'daki "ekran tam sayı vaat etmemeli" notuyla (`:389-392`) uyumlu. Prensip 3: gizli kalan tek şey kaçan (bulunmamış) hata; sonucu yayından sonra görünür, bugünkü A akışından farkı yok.

### 4.3 "Gönder / beklet" sorusunu sıkıcı olmaktan çıkarmak

Oyuncak simülasyon (§5 yöntemi): bir sprintte bilinen hata K ve soru sıklığı, üç kural için, bulunan hatanın sprint içi düzeltme maliyetine (1,3 / 3 / 6 puan) göre. P zinciri, tohum 1-6, D_SIM modeliyle koşturulan kart bitiş zamanları üzerinde (21-60. hafta penceresi):

| Ekip | Sprintte bulunan F | Soru çıkar: K ≥ 1 (1,3 / 3 / 6 puan) | Soru çıkar: K ≥ bulunanın %25'i (1,3 / 3 / 6 puan) |
|---|---|---|---|
| 1 kişi | 0,6 | %7 / %7 / %16 | %7 / %7 / %16 |
| 3 kişi (S2) | 1,2 | %5 / %16 / %26 | %5 / %16 / %26 |
| 6 kişi (S3) | 2,4 | %14 / %29 / %47 | %14 / %28 / %46 |
| 12 kişi (S4) | 4,9 | %20 / %46 / %72 | %6 / %28 / %62 |
| 25 kişi (S5) | 12,5 | %42 / %74 / %95 | %6 / %28 / %70 |
| 50 kişi (S6) | 24,6 | %71 / %94 / %99 | %5 / %30 / %73 |

Okuma: "bir tane bile bilinen hata kalırsa sor" kuralı 50 kişide hemen her sprint soru çıkarır (**ölçekte kırılır**, ilke 1). Oransal kural düşük düzeltme maliyetinde (1,3 puan) %5-14, orta maliyette (3 puan) 12 kişiden sonra **%28-30** civarında düz kalır: yaklaşık dört sprintte bir. Düzeltme çok pahalıysa (6 puan/hata, yani ağır hataya kaymış model) oran kuralı da sıklaşır; bu yüzden bilinen hatanın bir kısmı ağır sınıfta tutulmalı ve eşik oranı oyunda ayarlanmalı. (Oyuncak model: aşağıda sınırlar.)

Sıkmamak için seçenekler (kanıtlı):
1. **Sessiz yeşil yol.** K = 0 ise soru yok: "Bu sprint 9 hata bulundu, hepsi düzeltildi" mail satırı ve gönderim. Kanıt: Scrum'da Done olan iş zaten gider; kimse "gönderelim mi" diye sormaz.
2. **Oransal eşik + önem sınıfı.** Soru yalnız bilinen hata bulunanın belli oranını geçince ya da **ağır** sınıfta hata kalınca çıksın. Ağır hata oranı için tek ölçülmüş sayı: Jones'un düşük kalite örneğinde teslim edilen 613 hatanın 110'u (%18) yüksek önem (`Software-Defect-Removal-Efficiency.pdf`, Tablo 3). Mozilla'nın P1/P3 ayrımı ve blok edici ölçütü aynı mantık.
3. **Bir kerelik sürüm politikası.** Üç ön ayar: "Temkinli" (ağır hata ya da %10'un üstü bilinen hata varsa beklet), "Dengeli" (yalnız ağır varsa ya da %25'in üstündeyse sor), "Hızlı" (hep gönder). Kanıt: Software Inc oyuncuları kendi kuralını icat ediyor ("hata keşfi yavaşlayınca çıkar"); SRE hata bütçesi politikası, yayını bütçe belirliyor; sürüm araçları eşiği ayar olarak veriyor.
4. **Toplu soru.** Kart başına değil sprint başına **en çok bir** soru; kartlar bir tabloda, düğmeler varsayılan seçili; "Hepsini gönder / Hepsini beklet / Kart kart seç". Kanıt: MGT2 oyuncuları tekrarlayan tekil karardan otomasyon istedi (Ocak 2023 konusu).
5. **Gerçek bedelli soru.** Soru yalnız cevabın bedeli varsa çıksın: bir müşteriye verilen sözün tarihi bu sprinte denk geliyorsa (PromiseRegistry), B2B isteği kartta duruyorsa, bir demo/toplantı yaklaşıyorsa. Yoksa politika kendiliğinden gönderir ya da bekletir. (Kod iddiası: PromiseRegistry autoload'u `CLAUDE.md` §6'da; soru bağını kurmak tasarım işi.)
6. **Aynı cevabı gördükçe otomasyon öner.** Dış kanıt: ilaç uyarılarının %49-96'sı geçiliyor, oran yüksek olunca uyarı gürültü sayılıyor (van der Sijs ve diğerleri, JAMIA 2006; 2019 derlemesi %46-96): https://pmc.ncbi.nlm.nih.gov/articles/PMC1447540 (arama özeti). Pratik ölçüt: art arda 3 sorunun aynı cevabı alması durumunda "bunu politika yapalım mı" teklifi.
7. **Varsayılan.** GDT, MGT2 ve Game Dev Story'de varsayılan "düzeltme sürer", erken çıkış oyuncunun eylemi. Eşdeğeri: soru çıktığında vurgulu varsayılan **"Sonraki sprinte bırak"** (Scrum'ın kuralı), ya da politika "Temkinli" ise bu; "Hızlı" ise "Gönder".

### 4.4 Düzeltme maliyeti kimin kapasitesinden düşmeli

Seçenekler:
- **(a) Kartı yapan geliştiriciler (önerilen).** Test hatayı bulunca kart geliştirme aşamasına döner; hata düzeltme işi o kartın dev aşamasına eklenir; sprint kapasitesinden düşer. Kanıt: Scrum (sprintte bulunan hata kartın parçasıdır); GDT (hata puanları aynı çalışanların Bug-Fixing aşamasında silinir, `R3 :157`); Game Dev Story (çalışanlar siler); Menzies (düzeltmeyi hatayı sokan kişi/takım yapar). Sınır: tek kurucuda bu, kurucunun kendi zamanından düşer.
- **(b) Ayrılmış sprint payı.** Kapasitenin %X'i hata düzeltmeye; boş kalırsa israf, çok küçükse yetmez. A'nın "düzeltme payı" zaten bir oran; ama bu A'nın sürüm sonrası düzeltme kartları için. Sprint içi düzeltme için ayrıca sabit pay ölçekte iki yönlü bozulur (1 kişide %3'lük pay anlamsız).
- **(c) Testçi düzeltir.** MGT2'de QA odası hata düzeltebilir; D modelinde testçinin geliştirme becerisi ikincil (D_SIM betiğinde testçi eng = qa − 1); gerçekçi değil, ve testçi darboğazını büyütür (D_SIM zaten Test'in sık darboğaz olduğunu gösteriyor).
- **Yeniden test payı:** düzeltmeden sonra testçi hata başına 0,3 puan öder (tahmin). Karşılaştırma: D'nin düzeltme kartında dev:test oranı 3:2 ve 7:3 (`D_MODEL_v2.md:696`), yani tam bir düzeltme kartının testi dev işinin yaklaşık 0,4-0,7 katı; sprint içi yeniden test daha hafif tutuldu çünkü senaryo zaten bilinen.

**Bedel büyüklüğü (öneri, tahmin):** bulunan hatanın düzeltmesi = **hafif ~1 puan**, **ağır 4-6 puan, ağır payı ~%18** (Jones oranı). Gerekçe: Menzies verisi medyanın küçük, kuyruğun 3-8 kat olduğunu gösteriyor (§2.5). 1 puan ≈ 2-3 saat (tahmin: kurucu haftada 20 puan, ~40-50 saat), yani gerçek medyan 10 dakika "0,1 puan" bile eder; oyunda alt sınır 1 puana yuvarlandı çünkü hata bulma/çoğaltma/yeniden test yükü dahil. Böylece ortalama hata maliyeti ~1,7-1,9 puan, simülasyondaki "1,3" ve "3" duyarlılık koşuları arasında kalır.

**Geç düzeltme (sürüm sonrası):** A'nın düzeltme kartı bir hata için 1,25-5 puan; sprint içi 1-1,7 puan; oran 1-4 kat. Gerçek veri geç düzeltmenin eforunun 1,1-1,5 kat olduğunu söylüyor; yani sürüm sonrası düzeltme eforu şişirilmemeli; "bedel" memnuniyet ve itibar tarafında zaten kuruluyor (A).

## 5. Ölçek kontrolü (oyuncak simülasyon)

Yöntem: `dsim.py` (D_MODEL_v2 §6'nın birebir kopyası, D_SIM'in betiği) üzerine `r10sim.py` ile her tamamlanan özellik kartı için H, kartı yapanların Test payı, test bitiş zamanı alındı; yeni yakalama (P ve Q), bulunan hata n ~ Poisson(H' × C), düzeltme süresi n × maliyet / 10 puan/hafta, sprintte kalan süre içinde düzeltilebilen oranla ikiye bölme. H' = H × kalibrasyon katsayısı (kaçan hata bugünküyle aynı). 6 tohum, 60 hafta, 21-60 penceresi. **Bu, D modelinin bir uzantısı değil bir oyuncak analizdir**: bulunan hatanın sprint içi akışı motorda yok, düzeltme süresi kuralı ve 10 puan/hafta varsayımdır. Çıktılar yön ve büyüklük sırası içindir.

| Ekip | Kart/sprint | Yakalama C (P/Q, ortalama) | H katsayısı | Bulunan F | Düzeltilen M | Bilinen K | Düzeltme yükü (kapasite %) |
|---|---|---|---|---|---|---|---|
| 1 kişi | 1,1 | 0,53 / 0,54 | 1,52 / 1,57 | 0,6 | 0,5 | 0,1 | 4,0 |
| 3 kişi | 1,3 | 0,53 / 0,54 | 1,52 / 1,57 | 1,2 | 1,1 | 0,1 | 2,5 |
| 6 kişi | 2,7 | 0,59 / 0,63 | 1,57 / 1,74 | 2,4 | 2,2 | 0,2 | 3,0 |
| 12 kişi | 5,8 | 0,60 / 0,65 | 1,57 / 1,77 | 4,9 | 4,7 | 0,2 | 3,1 |
| 25 kişi | 12,8 | 0,62 / 0,68 | 1,58 / 1,84 | 12,5 | 11,7 | 0,8 | 3,4 |
| 50 kişi | 24,8 | 0,63 / 0,69 | 1,59 / 1,88 | 24,6 | 22,8 | 1,8 | 3,4 |

(1,3 puan/hata, P zinciri; K ve soru sıklığı için §4.3 tablosuna bakın; 3 ve 6 puan/hata koşuları aynı betiğin `R10_FIXPT` ayarıdır. Düzeltme yükü 3 puanda %6-9, 6 puanda %12-18.)

Uç bileşimler:
- **Hepsi geliştirici, Test kutulu (S8 benzeri)**: 1,9 kart/sprint, F 1,9, K 0,1; soru %8 (K ≥ 1). Yakalama C 0,61 (P): kutulu geliştirici testi iş görüyor.
- **Küçük karta çok testçi (S7: 2 geliştirici, 5 testçi; S7_1test: aynı ekip, 1 testçi)**: S7 1,4 kart/sprint, F 1,6, K 0,2, C 0,67; S7_1test 1,2 kart, F 1,4, K 0,2, C 0,63; soru her ikisinde %7-9. Dört testçi eklemek bulunan sayıyı ve yakalamayı yalnız küçük artırıyor, çünkü D'de testçiler kartın test işini **paylaşıyor** (Σ pay × yakalama, en çok 1), bağımsız ikinci göz değil. Myers'ın "bağımsız testçi çifti birleşince daha çok bulur" bulgusu bu modelde yok; eklenirse (örn. ikinci testçi (1 − C₁) × t₂ × (1 − örtüşme)) örtüşme sayısı için kaynak **bulunamadı**; elle değer uydurulmadı.
- **PM'siz ve testçisiz**: D'de testçisiz (kutu işaretsiz) kart test aşamasında bekler (D_SIM S11); sprint içi hata akışına hiç girmez. Yakalama zinciri bunu değiştirmez.
- **Tek kurucu**: kendi testi 0★ (P: %53); F 0,6, çoğu sprint "0 hata bulundu" yazar. Soru %7 (1,3 puan) ile %16 (6 puan) arası: yaklaşık altı ile on dört sprintte bir kez.

Sınırlar: (1) bilinen hata yalnız "test geç bitti" ve maliyete bağlı; ağır/hafif ayrımı ve kuyruk bu koşuya girmedi. (2) Planın "kalan süre" kuralı tek geliştirici hızıyla (10 puan/hafta); gerçekte birden çok geliştirici paralel düzeltir, K'yı düşürür. (3) Kartlar bağımsız, hatalar rastgele hatta düşmüyor. (4) Poisson tohumu simülasyona özgü; oyunda tohumlu çekiliş motorun yazacağı bir işlev.

## 6. Bulunamayanlar ve riskler

- GDT'nin güncel (1.7.x) hata formülü ve MGT2'nin hata oranı/QA hızı formülü; her ikisi için yalnız oyuncu tarifi/eski wiki.
- Tek testçinin hata yakalamasının doğrudan deneysel ölçümü (Myers %'si, Basili ve Selby sayıları) doğrulanamadı.
- İki testçinin örtüşme oranı için sayı yok; kişi başı marjinal kazanç modellenemedi.
- "Testçisiz" takımın gerçek kaçış oranı (R4 de bulamamıştı): %38 sayısı Jones'un elle birim testi ortalaması, kıyas olarak kullanıldı.
- Software Inc'in iadeye hata etkisi formülü yok; oyuncu sayıları 2017-2018 sürümlerinden.
- Menzies verisi TSP takımlarıdır (disiplinli, küçük); oyun ölçeğine genelleme tahmindir.

## Tasarımcıya 8 madde

1. **Yakalamayı zincir yap, tek geçişi kaldır.** C = 1 − 0,62 × (1 − t(★)). P: 1★ %57, 3★ %64, 5★ %72; Q: 1★ %60, 3★ %71, 5★ %81. Testi kısalt: %0 değil %38 (yazanın kendi kontrolü). Test yapacak kimse yoksa mevcut davranış (kart bekler) kalsın. %57 tavanı tek aşama tavanıydı (Jones sistem testi maks %55); Erdem'in itirazı veriyle uyumlu.
2. **H katsayısını yeni yakalamaya göre yeniden kalibre et** (0,03 → yaklaşık 0,046-0,056; kaçan hata A'nın hedefinde kalsın) ve D_SIM'i bu zincirle yeniden koş. Bu "tasarım sabiti, onay bekliyor". Yan faydası: "bulunan hata" sayıları ekranda anlamlı olur (6 kişi ~2,4, 50 kişi ~25 / sprint).
3. **Sprint içi akış:** test hata bulur (deterministik, tohumlu); hata kartın geliştirme aşamasına döner, sprint zamanı yetmezse "bilinen hata" kalır. Kartta sayı olarak "3 hata bulundu, 2'si düzeltildi"; yüzde yok. Plan ekranı bulunacak hata sayısını vaat etmez, yalnız kapasite ve darboğaz.
4. **Düzeltme maliyetini ağır kuyruklu kur ve kartı yapan geliştiricilere yükle.** Hafif ~1 puan, ağır 4-6 puan (~%18); yeniden test 0,3 puan testçiden. Sprint içi düzeltme kapasitenin ~%3-4'ü (1,3 puan) ile %6-9'u (3 puan) arası. Sürüm sonrası düzeltme eforunu şişirme (gerçek veride 1,1-1,5 kat, "10-100 kat" doğrulanamıyor); geç bedel memnuniyet ve itibar tarafında kalsın.
5. **Sorunun kuralını mutlak sayıyla değil oranla ve önemle yaz.** "En az 1 bilinen hata" 1 kişide %7, 50 kişide %71-94 soru çıkarır; "bulunanın %25'ini aşan ya da ağır" her ölçekte yaklaşık %5-30. Ağır hata payı ~%18 (Jones). Eşik oranları [ÇALIŞMA] olarak tek sabitte dursun.
6. **Soruyu sıkıcı olmaktan çıkar:** sprint başına en çok bir toplu soru; yeşil yolda sessiz gönderim (mail satırı); bir kerelik üç ön ayarlı sürüm politikası (Temkinli, Dengeli, Hızlı); aynı cevap art arda gelirse politika öner; varsayılan vurgu "sonraki sprinte bırak" (Scrum kuralı). Hiçbir referans oyunda zorunlu bir sprint sonu kapısı yok; bu yeni bir kalıp, ilk playtest'te cevap dağılımı ölçülsün (aynı cevap %80'i geçerse otomasyon).
7. **Soruya gerçek bedel bağla:** söz tarihi (PromiseRegistry), kartta duran B2B isteği, yaklaşan toplantı. Bedeli olmayan soru kendiliğinden politikayla kapansın. Gönderilen bilinen hata A'nın Hat panelinde açık hata olarak görünür (zaten var); GDT'nin göreli ölçüsü gibi ceza kullanıcı tabanına oranlı olsun, mutlak sayıya değil.
8. **Düzeltmeyi cezadan çıkar:** Game Dev Story silinen her hataya 1-3 araştırma puanı veriyor; benzeri küçük bir ilerleme duygusu (örn. "düzeltilen hata" sayacı, geçmişte görünür) Erdem'in "oyuncu bıkmasın" kaygısına yardım eder. Ayrıca gizli toplam riski: Software Inc'te "toplam hata bilinmiyor" belirsizliği şikâyet; bizde kaçan (bulunmamış) hata gizli kalır, bu A'nın bugünkü akışıyla aynı; sonucu görünür kalsın ve ilk playtest'te "neden yeni hata çıktı" sorusu izlensin.

## Kaynaklar (özet)

Jones DRE PDF: https://www.ppi-int.com/wp-content/uploads/2021/01/Software-Defect-Removal-Efficiency.pdf · Menzies ve diğerleri: https://arxiv.org/abs/1609.04886 · Scrum Guide: https://scrumguides.org/scrum-guide.html · Google SRE: https://sre.google/sre-book/embracing-risk/ · Mozilla triage: https://wiki.mozilla.org/Firefox/4/Triage , https://wiki.mozilla.org/Firefox3/Drivers/Triage · Ganssle: https://ganssle.com/rants/testertodeveloperratio.html · Game Dev Story: https://kairosoft.wiki.gg/wiki/Creating_games_(Game_Dev_Story) · Software Inc Steam: https://steamcommunity.com/app/362620/discussions/0/1470841715955280426 , https://steamcommunity.com/app/362620/discussions/search?q=bugs+beta+release · MGT2 Steam: https://steamcommunity.com/app/1342330/discussions/0/3114770279409920182/ , .../5358712989073876926/ , .../3766732716814125281/ , .../3114770279410380903/ · GDT: https://gamedevtycoon.fandom.com/wiki/Bugs , .../Review_Algorithm (R3 üzerinden) · Alarm yorgunluğu: https://pmc.ncbi.nlm.nih.gov/articles/PMC1447540
