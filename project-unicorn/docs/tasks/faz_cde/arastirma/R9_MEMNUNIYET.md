# R9: B2B müşteri memnuniyeti, oyuncunun okuyamayacağı nedenle düşmemeli (Faz C, C6)

Tarih: 2026-10-17. Hazırlayan: araştırma ajanı. Koda dokunulmadı, Godot koşturulmadı; simülasyon yalnız Python (`python -I`).

**Okuma notu (önce bunu okuyun).**
- Kaynak bütçesi: 12 WebSearch kullanıldı (12/12) ve 31 WebFetch denemesi yapıldı. 9'u boş döndü: Software Inc wiki Marketing sayfası 404, Startup Company Change Log 402, Forrester blogu 404, tez sitesi 403, Football Manager board-confidence sayfası 404, SI forumu DNS yok, ACSI sitesi 403 (ve bir yönlendirme), GamesRadar ipucu yazısı gövdesiz geldi. Reddit hiç denenmedi (önceki turlarda engelli).
- Gerçek dünya yarısı zayıf: "memnuniyeti ne düşürür, ayrılmadaki payı nedir" sorusuna **tek bir sağlam, birincil, yöntemi yayımlanmış kaynak bulunamadı**. Bulunanlar satıcı blogları, danışmanlık sayfaları ve birbirini alıntılayan özetler. Sayıları "yön gösterici" okuyun; çelişkileri çelişki olarak yazdım.
- Oyun yarısı da eksik: FM, Startup Company, Cities: Skylines ve Software Inc için yüzeysel mekanik okundu; MGT2 fan mekaniği, Planet Coaster, SimCity 4 / 2013 onay oranı, Two Point Hospital gösterimi ve Capitalism Lab marka sadakati **bulunamadı** (§6). Model bilgisini "(kaynaksız)" diye işaretledim.
- §5'teki simülasyon bir **şekil karşılaştırmasıdır**, kalibrasyon değil. Her parametre varsayımdır. Betik ve çıktı §8'de, yeniden koşulabilir.
- Karar vermiyorum: tasarımcıya seçenek ve kanıt veriyorum (§7).

---

## 1. Özet

1. **Bugünkü model "gizli hedefe kayma + kısa ömürlü bir mini defter"tir.** Hedef ürünün kararlılık ekseninden, açık hatadan ve güven defterinden çıkar; memnuniyet hedefe günde 3, tikte 21 puan yürür (`b2b_sales_system.gd:87-118`, `b2b_constants.gd:30`). Erdem'in itirazı kodla örtüşüyor: 25 puanlık fark 2 tikte kapanır, 10 puanlık fark 1 tikte (§2). Defter (söz, kesinti) 12 puanı 4,3 haftada siler (`b2b_constants.gd:268`), yani "kalıcı iz" yaklaşık bir ay sürer.
2. **Gerçek dünyada memnuniyet olaysız da düşer, ama nedeni "ilgisizliktir", saat değil.** Kaynaklar (zayıf) üç şeyde birleşiyor: ilk değer anından sonra satıcı ilgisini keserse müşteri unutur; yenilemeye 3-6 ay kala temas seyrekleşir; beklenti deneyimle yükselir (Oliver 1980, Bhattacherjee 2001). Yani "durup dururken düşüş" gerçekte "kimse aramadı, ürün de değişmedi"dir. Oyunda bunun dürüst yüzü görünür bir sayaçtır ("son güncelleme 31 hafta önce"), gizli bir kayma değil.
3. **Ürüne bağlı olmayan ayrılma gerçek ve küçük ama sayısı kaynaktan çıkmıyor.** İki kaynak çelişiyor: kapanma/küçülme/bütçe payı %8 (Recurly/ChartMogul alıntısı) ile bütçe kesintisi %34 (Visionary, n=38). Fark sayıdan çok tanımdan geliyor: "bütçe" çoğu kez düşük algılanan değeri örtüyor (R7 §2.1). BLS: yeni açılan işyerlerinin %79'u 1 yıl, ~%50'si 5 yıl yaşıyor; bu **olgun** müşteri için üst sınırdır, doğrudan oran değil.
4. **Oyunlarda ortak desen: memnuniyet bir nedenler listesidir, tek sayı değil.** CS2 bir hanenin mutluluğunun üstüne gelince katkıları listeler; FM güven çubuğunu beş bölüme ayırır; Software Inc 2025'te etiketten "müşteri yorumu"na geçti. Tersi de var: Startup Company'de memnuniyet gizli ve hızlı düşünce oyuncu "sessizce kullanıcı kaybettim" dedi, geliştirici "dönüşüm fazla sertti" dedi (§4.3).
5. **Üç ailenin ayrımı beklenenden küçük.** Simülasyonda (§5) donmuş bir ürünün kaderi üç ailede de aynı çıktı (780 hesap-haftasının 468-654'ü eşik altı): kaderi aile değil **pazar çıtasının yükselmesi** belirliyor. Ailelerin gerçek farkları üç yerde: (a) geçişin biçimi (yalnız (i) "olaysız hafta" kuyruğu üretir: 6 hafta), (b) ürün emeğinin ne zaman ödüllendiği ((iii) 52 haftaya erteler), (c) faz geçişi uçurumu ((ii) bir haftada 47 puan düşürebilir).
6. **Üç ailenin de ortak açığı:** ürün tavana ulaşıp bakıma geçince hiçbiri müşteriyi kaybetmiyor. Simülasyonda düzenli oyuncu 42. haftada tavana çıkıp 220 hafta sürüm çıkarmadığında üç ailede de eşik altı hafta **sıfır**. "Uzun süre güncelleme almama" ancak ayrı, görünür bir girdiyle ekonomiye girer (§5.4).
7. **İstismar:** sonsuza dek memnun tutma açığı (madde 6) ve (iii)'te tersi: yenileme öncesi tek büyük sürümle yenileme okumasını "satın almak".

---

## 2. Bugünkü model (kod gerçeği) ve Erdem'in itirazının ölçümü

**Hedef** (`b2b_sales_system.gd:140-152`): `hedef = kararlılık ekseni skoru − min(0,3 × hesabın hatlarındaki açık hata, 20) + güven defteri`, en az `eşik + 2` ilk 4 hafta (`b2b_constants.gd:15-16`). Eksen oyuncunun görmediği gizli eksendir (X §6.3, Q1 ile kalkıyor).
**Kayma** (`:87-118`): günlük 3 puan, ilk 4 hafta ×1,5; tik 7 gün olduğundan 21 (onboarding'de 35) puan/tik. Aşağı yönde hesabın sahibinin müşteri başarısı becerisi yavaşlatır (`cs_dampen`), huy bonusu ayrıca.
**İmza değeri** (`sales_system.gd:368`): `max(eşik + 10, 50)`.
**Defter** (`b2b_sales_system.gd:449-470`, `incident_system.gd:231`): tutulan söz +6, kısmi −2, bozulan −12; kesinti de aynı deftere yazar. Defter günde 0,4 puan affeder (`b2b_constants.gd:268`), yani 12 puanlık iz 30 günde (4,3 tik) kalkar.

**Erdem'in sorusu: "70'ten başlayan müşteri hedefi niye 45 olsun, niye ertesi hafta 45'e düşüyor?"** Kod bunu yapar. Hedefe uzaklığa göre kaç tikte kapanır (21 puan/tik; ilk 4 hafta 35, ama o dönemde taban tutar):

| Başlangıç → hedef | Fark | Süre |
|---|---|---|
| 70 → 62 | 8 | 1 tik |
| 70 → 55 | 15 | 1 tik |
| 70 → 45 | 25 | 2 tik (21, sonra 4) |
| 70 → 31 | 39 | 2 tik (21, sonra 18) |

(Hesap: `ceil(fark / 21)`; kod `_drift`, `clampi(gap, -step, +step)`.) Yani "balayı" yok; 70 başlangıcı ilk haftada silinir. C v2 bunu zaten saptamış (`C_ICERIK_v2.md` §2.5.1). Asıl sorun hız değil, **imza değeriyle hedefin iki ayrı fonksiyondan gelmesidir**: oyuncu 70'i imzada görür, hedefi hiç görmez.

**Beklenti çıtası** zamanla değil olayla yükselir: `sprint.json:30` Bootstrap 1, Traction 2, Series A 2; rakip çıkışı başına +0,5, en çok +1; alanın en yüksek kademesini aşmaz (`sprint_catalog.gd:117-125`). Bu §5'in simülasyonunda kullanıldı.

---

## 3. Gerçek dünya

### 3.1 Memnuniyeti/sağlığı ne düşürür, ne yükseltir; ayrılmadaki payı

| Etken | Yön | Ayrılmadaki payı (kaynak) | Kaynak kalitesi |
|---|---|---|---|
| Ürün beklenen değeri vermiyor / ürün-pazar uyumsuzluğu | düşürür | %28 (Recurly/ChartMogul alıntısı, R7 §2.1); %24 (Visionary, n=38) | ikincil, yöntem yok |
| Düşük kullanım | düşürür | %24 (Recurly/ChartMogul alıntısı); yenilemeden 60 gün önce kullanımı alt dilimde olan 4-6 kat çok ayrılıyor | aynı |
| Fiyat / değer algısı | düşürür | %21 genel; SMB %26, orta %18, kurumsal %11 | aynı |
| Rakibe geçiş | düşürür | %14 (Recurly/ChartMogul alıntısı); %18 "daha iyi alternatif" (Visionary) | aynı |
| Kapanma / küçülme / bütçe | düşürür, ürünle ilgisiz | %8 (Recurly/ChartMogul alıntısı) ama %34 "bütçe kesintisi" (Visionary) | **çelişiyor** |
| Onboarding başarısızlığı | düşürür | %5 (aynı alıntı); ilk ~90 günde ilk beklenen çıktı verilmezse risk (CustomerThink) | zayıf |
| Şampiyon / yönetici sponsor ayrılması | düşürür | 12 ay içinde ayrılma ihtimali %51 (şampiyon), %65 (yönetici sponsor); kaynak Sturdy/ChurnZero sunumu, birincil rapor doğrulanamadı | **tek zincir**, birçok sayfa aynı sayıyı tekrarlıyor |
| Satın alınma | düşürür | **ayrı pay bulunamadı** (bir ajans blogunun "%10" dediği belirsiz, kaynağı yok; kullanılmadı) | yok |
| Destek / hata | düşürür | **"%80 kötü destek yüzünden gider" tipi iddialar kaynaksız**; güvenilir pay bulunamadı. Kalitatif: açık biletler ve tırmandırılmış ama çözülmeyen sorunlar güveni aşındırıyor (CustomerThink vaka) | yok |
| Kesinti / SLA | düşürür | **ayrılma payı bulunamadı**; sözleşmesel yolu var (kredi, tekrarlayan ihlalde fesih hakkı; R7 §2.2). Veri ihlali sonrası "ayrılma %7'ye kadar artar" iddiası adsız kaynaktan, kesinti için değil | yok |
| Verilen sözün tutulmaması / yol haritasının kaçması | düşürür | Tek vaka: kaçırılan yol haritası tarihleri, önceden haber verilmemesi, çözülmeyen biletler → "ihanet", ayrılma arttı (CustomerThink). Pay yok | tek vaka |
| Ürünün güncellenmemesi / geride kalması | düşürür | **ayrılma payı bulunamadı**. Kalitatif: "ilk getirideki hedef tutturulduktan sonra satıcı işi bitmiş sayarsa müşteri geri çekilmeyi kötü hizmet okur" (CustomerThink) | yok |
| Fiyat artışı | düşürür | "B2B ayrılma olaylarının %29'u" (Gitnux, kaynaksız); R7: yenilemede tavansız %8-12 artış normal, NRR'ye +6 puan | zayıf |
| Müşteri başarısı görüşmesi / yenileme öncesi kullanım incelemesi | yükseltir | fiyat hassasiyeti beyanı %30-40 düşüyor (R7 §2.1, ChartMogul alıntısı) | ikincil |

Kaynak URL'leri: https://research.stripo.email/enterprise-saas-churn-rate-benchmarks-2026 (şampiyon/sponsor, Sturdy/ChurnZero alıntısı), https://customerthink.com/what-causes-b2b-customers-to-churn-three-things-and-price-isnt-one-of-themand-none-of-them-is-price/ (üç boyut: çıktı, güven, ilgi; vaka), https://stealthagents.com/research/saas-churn-rate-statistics-2026 ve https://visionary-marketing.co.uk/blog/saas-churn-benchmarks-2026 (R7'den; yeniden açılmadı), https://www.usercall.co/post/why-customers-leave (12 neden listesi, yüzde yok; "şampiyon ayrıldı" ve "rakip inandırıcı bir teklif verdi" ayrı nedenler; sayfa ikincisinin çoğunlukla zaten memnuniyetsiz müşteriye işlediğini söylüyor).

**Sonuç (kaynak zayıflığına rağmen tutan şey):** düşürenlerin hemen hepsi **adlı olaydır ya da adlı bir eksikliktir** (kullanılmama, ilgisizlik, kaçan söz). "Ürün hiç değişmedi, kimse aramadı, müşteri yine de aşağı kaydı" varsa bunun adı "ilgisizlik/unutulma"dır ve satıcı davranışına bağlıdır, zamana değil.

### 3.2 Memnuniyet olaysız kendiliğinden düşer mi; zamanla sabit mi; yıllar içinde beklenti

- **Beklenti-onay kuramı:** memnuniyet, deneyimin baştaki beklentiyle karşılaştırılmasıdır; beklentiyi aşan memnuniyeti artırır, aşılmayan azaltır (Oliver 1977, 1980). Bilgi sistemlerinde sürdürme kararı için uyarlaması Bhattacherjee 2001 (MIS Quarterly 25(3)). Wikipedia özeti beklentinin kullanımdan sonra nasıl güncellendiğini **anlatmıyor**; "yıllar içinde beklenti yükselir" bu yüzden kuramın söylediği değil, yorumdur: https://en.wikipedia.org/wiki/Expectation_confirmation_theory
- **Tüketici genişbant verisi (B2B değil):** Calix, aboneler arası puanların kurulumdan sonraki ilk 2 yılda en yüksek olduğunu, sonra "pasifleşip düştüğünü" yazıyor; sayı, örneklem ve yöntem yok: https://www.calix.com/resources/market-insights/subscriber.html
- **B2B:** SiriusDecisions analistinin blogu (2016, 450+ B2B yönetici ve kullanıcı anketine dayanıyor) ilişkinin üçüncü aşamasında memnuniyetin kaydığını, müşterilerin tam yenileme kararında sonuçtan memnun olmadığını söylüyor. **Sayfa açılmadı (404); yalnız arama özeti**, bu cümleyi yazarın görüşü sayın: https://www.forrester.com/blogs/dangercustomerretentioncurvesahead
- **CustomerThink (makale + yorumlar):** ilk beklenen çıktı için yaklaşık 90 gün; ilk getiri alındıktan sonra satıcı çekilirse müşteri bunu kötü hizmet sayıyor; SaaS'ta temas yenilemeden 3-6 ay önceye kadar "seyrek" (**bir okur yorumundan**, makale değil); "hassle factor": tek bir sorun değil küçük sürtünme birikimi (**okur yorumu**). Aynı sayfa.
- **ACSI** (ulusal memnuniyet endeksinin onlarca yıl dar bantta durduğu) bilgisi **kaynaksız**: site 403 verdi.
- Sürekli bir "olaysız kayma"yı destekleyen **sayılı bir B2B kaynağı bulunamadı**.

### 3.3 Ürüne bağlı olmayan ayrılma (iflas, satın alınma, bütçe)

- BLS işyeri hayatta kalma tablosu: 1994-2024 açılış kohortlarında 1 yıl sonra %75-81, 2 yıl %63-72, 5 yıl %45-52, 10 yıl %32-35 hayatta. Tablo **işyerlerini** ölçer (firma değil) ve yalnız yeni açılış kohortlarını izler: https://www.bls.gov/bdm/us_age_naics_00_table7.txt . Olgun bir B2B müşterisi için yıllık kapanma bu rakamlardan çok daha küçüktür ama **sayı bulunamadı**.
- Vitally'nin Recurly 2025 alıntısı: B2B SaaS ayrılması %3,5 (%2,6 gönüllü, %0,8 gönülsüz; dönem bu alıntıda yazmıyor). Gönülsüz çoğunlukla ödeme hatası, kapanışı ayrı saymıyor: https://www.vitally.io/post/saas-churn-benchmarks
- Segment ayrılması çelişkili: ChartMogul alıntısı (R7) kurumsal %2-5 yıllık logo kaybı, Optifai 2026 (n=939, Stripo'dan) kurumsal (>100K ACV) %8,1, orta pazar ~%22-23 (Stripo'nun aylıktan bileşik hesabı). Kapsam ve tanım farklı.
- Satın alınma için ayrı oran **bulunamadı**.

---

## 4. Oyunlar (oyun oyun mekanik dökümü)

### 4.1 Football Manager (yönetim güveni, taraftar güveni)

- **Kural/formül:** yok (sayı yayımlanmamış). Yönetim güveni **beş bölüm + özet** olarak çubukla gösterilir: yarışmalardaki performans, finans kontrolü, tek tek maç geri bildirimi, transfer piyasası, mevcut oyuncuların performansı. Sayı yok; "dolu çubuk mutlu yönetim". Kaynak (FM Scout, sürümü sayfada yazmıyor): https://www.fmscout.com/confidence.htm
- **Taraftar güveni:** Taraftar Profili ile başlar (Hardcore, Core, Family, Fair Weather, Corporate, Casual). Düşük ligde küme düşme mücadelesi veren kulübün Fair Weather taraftarı az, yavaş ilerlemeye daha hoşgörülü. Kulüp kimliği (nasıl oynadığı), büyük rakiplere karşı sonuçlar, bireysel performanslar etkiler. Kaynak (resmi FM23): https://www.footballmanager.com/features/supporter-confidence
- **Neyle hareket eder:** sonuçlar ve finans (yönetim); sonuçlar, büyük isim imzası, ilan edilip gerçekleşmeyen hedefler, basın toplantısı cevapları (taraftar). Yönetime yapılan istekler (zaman, transfer bütçesi, maaş havuzu, tesis) olumsuz geri bildirimde tekrarlanırsa itibarı yıpratır ve kovulmaya götürebilir; ret edilirse ültimatom: itibarı, başarıyı ve işi riske atmak. Kaynak: FM Scout confidence sayfası.
- **Kendiliğinden kayar mı:** iki sayfa da **söylemiyor**. "(kaynaksız) FM'de güven olaysız bekleyişte sabit kalmaz çünkü sezon boyunca her maç bir olaydır" gibi bir genelleme yapılabilir, ama zamana bağlı bir bozunma belgelenmedi.
- **Ekranda gerekçe:** Kulüp Vizyonu'nda yönetim ve taraftar güveni yan yana; Performans açılırında Maç Performansı, Transfer, Taktik, Kadro; maç öncesi haberde yönetimin ve taraftarın beklentisi (farklı olabilir); basın toplantısı soruları taraftar durumunu yansıtır; çevrimiçi hava değişince gelen kutusuna mesaj düşer. Beklenti ve gerekçe kelimedir.
- **Oyuncu şikâyetleri:** bulunamadı (Reddit/forum engelli; resmi forum DNS vermedi).
- **Ölçekte:** kulüp boyutu beklentiyi belirler; Taraftar Profili bunun ayarıdır. Ölçekten bağımsız tek kural: güven beklentiye göre.

### 4.2 Software Inc

- **Kural:** her ürün kategorisinin kendi Market Recognition (MR) değeri vardır; kaliteli ürün ve devam sürümleri MR'yi artırır; IP satın alınca popülerlik taşınmaz, ama "nefret" taşınır (oyuncu iddiası). Yüksek MR hem satışı hem hızını artırır (oyuncu iddiası). **MR'nin zamanla bozunduğuna dair bir kural bulunamadı.** Kaynak: https://steamcommunity.com/app/362620/discussions/0/594013058474480747
- **Eskime:** oyuncu stratejisi: güncel ve popüler sürümü tam güncelle, eskilere daha az güncelle; "yükseltmeyi bırak, hataları düzeltmeye devam et, kullanıcı sıfıra inene dek bekle, sonra arşivle". Kullanıcılar ürünü esas olarak hata bildirmek için destekle temas ederek izler. Yeni işletim sistemine port etmek kullanıcıyı artırır. **Hepsi oyuncu anlatımı**, doğrulanmış kural değil. Aynı sayfa.
- **Hata:** Quickstart (eski, "bakımda" uyarılı): hatalar insanları mutsuz eder ve satış/sözleşme ödemesini etkiler. Oyuncu uzlaşması: hata kaliteyi bozmaz, destek yükü ve basın incelemesine döner; hata sayısı baştan bilinmiyor (R1 §3). Kaynak: https://softwareinc.coredumping.com/wiki/index.php/Quickstart_Guide
- **Ekran:** Kasım 2025'te "kalite/yaratıcılık etiketleri" yerini **dinamik müşteri yorum sistemine** bıraktı; ayrıntı yayımlanmamış (R1, itch.io 1.8.31 notu). Tasarım belgesi ekranında "Market satisfaction" çubukları (R8 §7). Yani oyun kendi eksenlerini kaldırıp kelimeyle konuşmaya gidiyor.
- **Ölçek ve şikâyet:** ölçekte şikâyet bulunamadı.

### 4.3 Startup Company

- **Kural (R2):** Beta 17'de "memnuniyet" eklendi: pazarlama dönüşümünü ve organik büyümeyi etkiler; ücret ve etkilenen özellik arttıkça düşer; Beta 25'ten beri temel özellikler memnuniyet, gelir özellikleri (reklam) memnuniyetsizlik üretir; toplam = temel özelliklerin ortalaması − gelir özelliklerinin memnuniyetsizliği. Destek biletleri 36 saatte çözülmezse destek memnuniyeti düşer ve toplamdan çıkar (R2 §2.4). Bir geliştirici cevabı: iki temel özelliğin **dengeli** seviyesi memnuniyeti belirler (biri 10'sa ötekinin de 10 olması gerekir): https://steamcommunity.com/app/606800/discussions/0/1769259642872479689/
- **Bu model "durum fonksiyonu"dur:** memnuniyet mevcut özelliklerin anlık bir fonksiyonu, geçmiş yok, kayma hızı belgelenmemiş.
- **Oyuncu şikâyeti (en öğretici kanıt):** Beta 17 sonrası bir oyuncu kapalı tuttuğu iki özellik ve eklediği reklamla birlikte kullanıcının ~1 milyardan 19 milyona düştüğünü yazdı, "fark ettiğimde çoktan kullanıcı kaybediyordum", "geri kazanmak kaybetmekten çok daha zor", çözüm olarak canlıyı etkilemeyen bir beta seçeneği önerdi. Geliştirici: "Beta 16'dan 17'ye dönüşüm fazla sertti", çözüm zamanı yok: https://steamcommunity.com/app/606800/discussions/0/1734336452589045402/
- **Ekranda:** ürün kartında tek bir yüzde rozeti (anlamı yazılı değil), nedenlerin dökümü yok (R8 §7.3). Wiki'de ayrı memnuniyet sayfası yok. Change Log 402 verdi; bu yüzden Beta 17 satırı R2/R8'den.
- **Ölçekte:** 1 milyar kullanıcı ölçeğinde bile aynı kural çalıştı ve oyuncuyu şaşırttı: gizli ve hızlı bir durum fonksiyonu, "nedensiz çöküş" hissi veriyor. Bizim sorunumuzun doğrudan emsali.

### 4.4 Mad Games Tycoon 2

- **Kural:** "Fan" sayısı satışta en büyük etken (oyuncu iddiası); fan sayısı arttıkça büyük medya (IGN) röportajı çıkar. En kötü oyun ödülü "kaybedecek fanın olmadığı erken oyunda" alınabilir, yani fan kaybedilebilir. **Fanın ne zaman ve nasıl düştüğü, zamanla bozunup bozunmadığı bulunamadı.** Hype'ı NPC yayıncıların reklam kampanyaları 80-100'e çıkarabiliyor (5 yıldızlı yayıncıda). Yayıncı ilişkisi (yıldız) bulunamadı. Kaynaklar: https://steamcommunity.com/app/1342330/discussions/0/3833172952657307613 ve arama özeti (başka başlıklar).
- **Ekran ve şikâyet:** bulunamadı. R8 §2.3: bileşik puan kırılımı var ama toplamı şeffaf değil.

### 4.5 Cities: Skylines ve SimCity (onay oranı, hedefe kayma)

- **Cities: Skylines (1):** mutluluk Konut, Ticaret, Sanayi, Ofis olarak dört kategoride tutulur; küresel mutluluk "kategori başına bina sayısına göre ağırlıklı ortalama"dır. Etkenler yalnız niteliksel: hizmetler, işsizlik, kirlilik, trafik/tedarik zinciri, vergi, politikalar, suç. Sayısal değer, taban değer ve kayma kuralı sayfada yok (sürüm 1.16, "güncel olmayabilir" uyarılı). Mutluluk bina seviye atlamasını ve alınabilecek vergiyi etkiler. Başarım "Popüler Olmayan Belediye Başkanı": küresel mutluluk %15; "Mutlu Kasaba": %95 üstü, 5 yıl. Kaynak: https://skylines.paradoxwikis.com/Happiness
- **Cities: Skylines II:** mutluluk = İyi oluş (well-being) + Sağlık; **bir hanenin mutluluğunun üstüne gelince katkıda bulunan etkenleri gösterir** (eğitim, boş zaman, eğlence, sağlık, posta, internet, gürültü, servet, konut büyüklüğü, vergi). Düşük iyi oluş "Rahatsız" durumu yaratıp mutluluğu ve işe katkıyı düşürür. Sayısal artı/eksi değer ve yumuşatma yok. Kaynak: https://cs2.paradoxwikis.com/Happiness
- **Hedefe kayma mı?** Belgelenmiş bir kayma hızı yok. Model, **anlık durum fonksiyonu + gerekçe listesi** gibi görünüyor (kaynaksız yorum). Bir Steam başlığında oyuncu binaların neden seviye atlamadığını soruyor (mutluluk seviye atlamayı etkiler); cevaplar "hizmetlere, parklara, eğitime bak" listesi veriyor, formül değil: https://steamcommunity.com/app/255710/discussions/0/2970649384340975014
- **SimCity (2013) / SimCity 4 onay oranı:** bulunamadı (kaynaksız: SC4'te "başkan puanı" simleri etkenlerle ölçer).
- **Ölçek:** kategori bazlı ağırlıklı ortalama ölçekten bağımsız.

### 4.6 Two Point Hospital ve Planet Coaster ("mutluluk nedenleri listesi")

- **Two Point Hospital:** hastalar tedavinin etkinliğini, tuvalet sayısını, temizliği, yiyecek-içecek erişimini sürekli yargılar; yeni hasta sayısı memnuniyet ve itibara bağlı; memnun hasta başkasına önerir. Kaynak: https://www.gamepressure.com/two-point-hospital/ . Oyuncu anlatımı: düşük mutluluk hastanın öfkeyle gitmesine ve ödemeyi azaltmasına yol açar; "olağanüstü oda" +%30 mutluluk. **Ekran ("düşünce balonu" vb.) ve olaysız değişim bu kaynaktan teyit edilemedi.**
- **Planet Coaster:** aranmadı; **bulunamadı**.

### 4.7 Capitalism Lab (marka sadakati)

- Resmi site ve bir inceleme: ürün başına kalite/marka ağırlığı farklı (giyim marka tanınırlığını ödüllendirir, ekmek ve yumurta fiyat ve kaliteyi); ağırlıkların zamanla değişimi, marka sadakatinin bozunması ve ekranı **anlatılmıyor**. Kaynak: https://legacyofgames.com/2025/11/13/capitalism-lab . Öğrenilen: ağırlık bir **müşteri tipi özelliği**dir (R8/X Q3 ile aynı yönde), sadakatin zamansal davranışı kaynaksız.

### 4.8 Oyunlardan çıkan ortak ders

1. Gerekçe **liste** olarak gösterilir (CS2 üstüne gelince, FM bölümlü çubuk, Software Inc yorum). Tek sayı + gizli neden olan tek örnek (Startup Company) oyuncu şikâyetinin kaynağı.
2. Hiçbir okunan kaynak "sırf zaman geçti diye" düşen bir memnuniyet kuralı belgelemiyor. Tek zayıf işaret Software Inc oyuncu anlatımı: güncellemeyi bırakınca kullanıcı sıfıra iner. Kural doğrulanmadı.
3. Oyuncu "kaybı fark edememe" ve "geri kazanmanın pahalılığı"ndan şikâyet etti; yani yalnız düşüşün sebebi değil **düşüşün haberi** de gerek.

---

## 5. Sentez: üç model ailesi

Tanımlar (bu rapor için):
- **(i) Gizli hedefe kayma (bugünkü):** hedef girdilerden hesaplanır, memnuniyet 21 puan/tik ile hedefe yürür.
- **(ii) Olay defteri:** imzada değer = o anki ürün uyumu. Sonra yalnız adlı olaylar değiştirir: sürüm/çıta değişimi kalıcı fark, hata faturası/kesinti/söz solan olay (26 ve 13 hafta). Hedef yok; memnuniyet defterin toplamıdır.
- **(iii) Çapa + olay:** ürünün açık ölçüsü yalnız imzada ve her yenilemede (52 haftada bir) okunur; arada sadece olaylar (hata faturası, kesinti, söz).

### 5.1 Simülasyon (şekil karşılaştırması)

Kurulum (hepsi varsayım; betik §8): tek hesap, imza hafta 10, eşikler 36/45/54, 260 hafta. Ürün uyumu = `70 × min(seviye / çıta, 1,5)`. Seviye 1,0'da başlar (MVP çıtayı karşılar). Çıta: hafta 26'dan itibaren 2 (Traction), hafta 70 ve 120'de rakip çıkışıyla +0,5 (`sprint.json:30-32`). Oyuncular: **A** düzenli (8 haftada +0,5, tavan 3, hata yoğunluğu 0,4), **B** donmuş (1,5'te durur, yoğunluk 0,1), **C** hızlı ama özensiz (5 haftada +0,5, yoğunluk 0,4'ten 3'e), **D** 40. haftada durur, 120'de devam eder. Kesinti hafta 40/90/150 (−6), bozulan söz hafta 50 (−12). "Olaysız düşüş" = o hafta sürüm, çıta, kesinti, söz, fatura ya da yenileme okuması yokken ≥5 puan düşüş.

**Güncelleme-yaşı kuralı KAPALI** (hesabın memnuniyeti, imzadan 1/4/12/26/52/104/208 hafta sonra, eşik 45; sonra: üç eşiğin toplamında eşik altı hesap-haftası (en çok 780), olaysız düşüş haftası, en büyük tek hafta düşüşü):

| Oyuncu | Aile | Memnuniyet @ 1/4/12/26/52/104/208 | Eşik altı (3 eşik toplamı) | Olaysız düşüş (3 eşik toplamı) | En büyük düşüş |
|---|---|---|---|---|---|
| A düzenli | (i) | 68 / 68 / 100 / 85 / 100 / 82 / 68 | 0 | 3 | −21,0 |
| | (ii) | 70 / 70 / 100 / 88 / 100 / 84 / 70 | 0 | 0 | −30,0 |
| | (iii) | 70 / 70 / 70 / 70 / 100 / 84 / 70 | 0 | 0 | −16,5 |
| B donmuş | (i) | 69 / 69 / 100 / 52 / 52 / 41 / 34 | 595 | 6 | −21,0 |
| | (ii) | 70 / 70 / 100 / 52 / 51 / 42 / 35 | 602 | 0 | −47,5 |
| | (iii) | 70 / 70 / 70 / 70 / 51 / 42 / 35 | 468 | 0 | −16,3 |
| C özensiz | (i) | 67 / 66 / 99 / 95 / 87 / 66 / 52 | 150 | 0 | −21,0 |
| | (ii) | 70 / 69 / 100 / 100 / 93 / 72 / 59 | 3 | 0 | −23,4 |
| | (iii) | 70 / 69 / 68 / 66 / 93 / 72 / 59 | 7 | 0 | −23,1 |
| D durgun | (i) | 68 / 68 / 100 / 85 / 85 / 68 / 68 | 0 | 3 | −21,0 |
| | (ii) | 70 / 70 / 100 / 88 / 86 / 70 / 70 | 0 | 0 | −30,0 |
| | (iii) | 70 / 70 / 70 / 70 / 86 / 70 / 70 | 0 | 0 | −17,3 |

**Güncelleme-yaşı kuralı AÇIK** (26 haftadan sonra her 4 haftada −1, en çok −15, her sürümle silinir; "sürüm" = seviye artışı):

| Oyuncu | Aile | Memnuniyet @ 104 / 208 | Eşik altı |
|---|---|---|---|
| A düzenli | (i) / (ii) / (iii) | 71 / 53, 73 / 55, 73 / 55 | 146 / 22 / 6 |
| B donmuş | (i) / (ii) / (iii) | 26 / 19, 27 / 20, 27 / 20 | 645 / 654 / 579 |
| C özensiz | (i) / (ii) / (iii) | 52 / 37, 58 / 44, 58 / 44 | 318 / 235 / 172 |
| D durgun | (i) / (ii) / (iii) | 55 / 53, 57 / 55, 57 / 55 | 80 / 16 / 0 |

### 5.2 Simülasyondan çıkan beş gözlem (sınırları ile)

1. **Donmuş ürünün kaderini aile belirlemiyor, çıta belirliyor.** B oyuncusu üç ailede de 208. haftada 34-35 (eşiğin altı). İyi niyetli bir olay defteri bile ürünün pazarın gerisinde kalmasını gizleyemez; çıtanın yükselişi ürün terimine girdiği sürece. (Sınır: çıta bu simülasyonda faz ve rakip olayıyla zıplıyor, oyunun gerçek takvimi farklı.)
2. **Yalnız (i) "olaysız hafta" üretiyor.** Üç eşik koşusunun toplamı 3-6 hafta (koşu başına 1-2): bir olayın (çıta zıplaması) ardından hedefe giden yolun ikinci ayağı. Bu, Erdem'in şikâyetinin tanımıdır: o hafta ekranda hiçbir şey olmadı, sayı düştü. (ii) ve (iii)'te olay anında bütün düşüş yazılıdır; olaysız hafta 0. (Sınır: "olaysız" tanımım dar; (i)'in gerçek ekranında ipucu hedefi ve nedenleri zaten gösteriyorsa bu kuyruk "hedefe gidiyor" diye okunabilir.)
3. **(ii) faz geçişinde uçurum yaratabilir.** B oyuncusunda çıta 1'den 2'ye çıkınca tek haftada 100 → 52 (−47,5). (i) bunu 21 puanlık adımlarla 3 haftaya, (iii) yenilemeye yayar. Olay defterinde çıta yükselişi için rampa ya da "pazar çıtası yükseldi" olayının 8 haftada işlenmesi gerekir. (Sınır: ürün terimi 1,5 oranla 105'e çıkıp 100'e kırpıldığı için sayı biraz abartılı; yön doğru.)
4. **(iii) ürün emeğini geç ödüllendirir.** C oyuncusu (yoğun sürüm) (iii)'te ilk yenilemeye (52. hafta) kadar 66-70'te kalıyor, (i) ve (ii)'de 95-100'e çıkıyor. Oyuncu "ürünü iyileştirdim, hesaplar neden aynı" der. Çözüm ipucunda "yenilemede okunacak ürün uyumu: 82" satırıdır; kaynak yok, tasarım tahmini.
5. **Ürün tavanına ulaşan oyuncu üç ailede de sonsuz memnun kalıyor** (A ve D, kural kapalı, eşik altı 0, A'da 220 hafta sürümsüz). "Uzun süre güncelleme almama" bu yüzden ayrı bir girdi ister.

### 5.3 Üç aile, dört ölçüt

| Ölçüt | (i) Gizli hedefe kayma | (ii) Olay defteri | (iii) Çapa + olay |
|---|---|---|---|
| **Oyuncuya açıklanabilirlik** | Düşüşün hızını ve gecikmesini açıklamak zor: "hedef" iki katmanlı soyut kavram. İpucu hedefi ve terimleri listeleyebilir, ama imza değeri ile hedef iki ayrı yerden gelir (§2). Startup Company'deki şikâyet tam bu türden. | En kolay: her puan tarihli bir satır ("12 Mar, kesinti, −6, 26 haftada silinir"). Toplam = satırların toplamı. Ürün terimi ayrı bir kalıcı satır olmalı. | Kolay, ama iki tür sayı var: çapa ve olay toplamı; yenileme öncesi "okunacak ürün uyumu" ayrı gösterilir. |
| **1-50 kişi, uzun koşu** | Hata cezası sayıya bağlıysa ölçekte kırılır (C §2.5.2 uyarısı); yoğunluğa (açık hata / yayındaki grup) çevrilirse sağlam. 260 haftada kuyruk gürültüsü sürer. | Olay tutarları ekip büyüklüğüne değil olayın cinsine bağlı kalırsa ölçekten bağımsız. Hata faturası yoğunluğa bağlanmalı. Defter 260 hafta sonra büyür (olay sayısı), ama solan olaylar toplamı sınırlar. | Aynı; ayrıca yenileme sıklığı (12 ay) hesap sayısından bağımsız. 330 hesapta yenileme okuması haftalık yük dağıtır. |
| **İstismar** | Ürün tavanında sonsuz memnun (gözlem 5). Düşük tolerans için kayma hızı, hızlı bakımla (CS becerisi) sönümlenebilir. | Pozitif olaylar kalıcıysa spam sürümle şişirilebilir; yalnız **gerçek seviye artışı** sürüm sayılırsa kapanır. Ürün terimi kalıcı farkla tek satırda tutulur, çifte sayım yok. | Yenileme öncesi tek büyük sürümle okumayı "satın almak" mümkün. Önlem seçeneği: okuma son 26 haftanın ortalamasını alır ya da sürümle okuma arasında en az N hafta şartı. |
| **"Uzun süre güncelleme almama" nasıl görünür neden olur** | Hedefe bir eksi terim olarak eklenir; terim gizliyse aynı sorun. Görünür sayaç hedefi açıklar ama düşüşü anlık yapmaz (gecikme). | Tarihli satır: "Son güncelleme 31 hafta önce, −1 (her 4 haftada)". Sürümle silinen satırlar listede kalır ve "kapandı" yazar. | Aynı satır, ama yenilemede toplu okunur: "yenileme: güncelleme yaşı −7" tek kalemde. |

### 5.4 "Uzun süre güncelleme almama" için seçenekler (kanıt: §3.2, §5.2 gözlem 5)

Kanıt: gerçek dünyada bu etken kalitatif (CustomerThink, SiriusDecisions özeti); ayrılma payı bulunamadı. Oyun emsali yok. Simülasyonda 26 hafta eşik, her 4 haftada −1, tavan −15 şu etkileri verdi: tavana ulaşmış düzenli oyuncu 208. haftada 53-55'e iner (36 ve 45 eşikli hesapları tutar, 54 eşikli hesap sınırda kalır); donmuş oyuncu 19-20'ye iner.

Seçenekler (kodu olmayan, tasarım seçimi):
- **Saat neyi sıfırlar:** (a) seviye artışı (simülasyondaki), (b) hesabın kullandığı bir alana dokunan her sprint kartı (hata düzeltme dahil), (c) herhangi bir sürüm. (a) EA'da kademe tavanı 3 olduğundan tavandan sonra herkesi cezalandırır (sonu olmayan bir koşu); (c) kuralı etkisiz yapar. (b) ikisinin arasıdır.
- **Zaman bazlı olduğu için ölçekten bağımsız:** 1 kişilik ekip de 50 kişilik ekip de aynı sayaçla karşılaşır; fakat 50 kişilik ekibin her alanı sık güncellemesi kolay olabilir.
- **Ek sayaç "son temas":** hesap sahibi temas etmediyse (`cs_dampen`'in zaten bir "bakım" kavramı var), ikinci bir görünür neden. Bu, gerçek dünyanın "ilgisizlik" etkenine karşılık gelir; ama yeni sistem demektir.

---

## 6. Bulunamayanlar

1. B2B SaaS'ta ayrılma nedenlerinin **birincil, yöntemi yayımlı** dökümü (hata, kesinti, destek, güncelleme eksikliği ayrı ayrı).
2. Kesinti ve SLA ihlalinin ayrılmaya doğrudan etkisini ölçen bir çalışma.
3. Olgun bir B2B müşterisinin yıllık iflas ve satın alınma oranı (BLS işyeri tablosu yeni açılışlara baskın).
4. Satın alınma kaynaklı ayrılmanın ayrı payı.
5. Memnuniyetin tenure ile B2B ölçeğinde düşüşünü gösteren sayılı kaynak (Calix tüketici genişbant, sayısız; Forrester blogu 404).
6. ACSI ulusal endeksi (403) ve "yıllar içinde beklenti artar" için ölçüm.
7. FM: yönetim güveninin kendiliğinden kayıp kaymadığı, çubuğun sayısal karşılığı, oyuncu şikâyetleri.
8. Software Inc: MR bozunması, Kasım 2025 müşteri yorum sistemi, hata→satış formülü.
9. MGT2: fan kaybı ve bozunması, yayıncı ilişkisi.
10. SimCity (2013) ve SimCity 4 onay oranı; Cities: Skylines'ta kayma hızı ve oyuncu tepkisi (sayısal).
11. Two Point Hospital ve Planet Coaster mutluluk ekranı; Capitalism Lab marka sadakati zamansal davranışı.
12. Startup Company Change Log (402) ve memnuniyet formülü, kırılım ekranı.
13. Reddit hiç denenmedi; oyuncu tepkileri Steam başlıklarıyla sınırlı.

---

## 7. Tasarımcıya 8 madde

Her madde: seçenek, kanıt, sınır. Karar yok.

**1. İmza değeri ile hedef tek fonksiyondan gelsin.**
- Seçenek A: imza değeri = o günkü ürün uyumu (Erdem: "direkt o şekilde başlasın"). Seçenek B: 70 sabit başlangıç + ilk 4 hafta taban + 8 haftada sönüm (C v2 §2.5.1).
- Kanıt: §2 tablosu (70 → 45 iki tikte iner); B'nin 12 haftalık sönümü yine bir gizli düşüş yaratır; Startup Company vakası (§4.3).
- Sınır: A'da zayıf ürün düşük başlar, imza kapısı bunu önceden filtrelemiyorsa erken kayıp artar; "70'ler" isteği o durumda yalnız iyi üründe tutar.

**2. Memnuniyetin düşüşünün tek geçerli biçimi "adlı olay"dır; geçişin yolu da gösterilsin.**
- Seçenek: (ii) olay defteri, (iii) çapa + olay ya da (i) + her düşüş satırında tarih. Üçü de nedeni listeleyebilir.
- Kanıt: §5.2 gözlem 2: yalnız (i) olaysız hafta üretiyor (3-6); oyunlarda gerekçe listesi ortak desen (§4.8).
- Sınır: ipucu listesi (i)'i de açıklanabilir yapabilir; sorun hız ve gecikmedir, liste yetmez.

**3. Çıta yükselişi bir olaydır ve rampa ister.**
- Seçenek: faz geçişinde tek haftalık düşüş yerine 8 haftalık yayılma; ya da çıtayı yükseltmeden önce haber ("Traction'da pazar Güven alanında Yeterli ister, 8 hafta içinde").
- Kanıt: §5.2 gözlem 3: (ii) 100 → 52 (−47,5); gözlem 1: donmuş ürünü batıran çıtadır.
- Sınır: faz geçişini oyuncu kendisi tetikliyor; bu yüzden düşüş "oyuncu eylemine bağlı" sayılabilir.

**4. Sonsuz memnuniyet açığı için görünür bir "güncelleme yaşı" girdisi.**
- Seçenek: simülasyondaki 26/4/15 [tahmin] ya da hesap bazlı eşik; saat neyi sıfırlar (§5.4: seviye artışı, dokunulan alanda her kart, her sürüm).
- Kanıt: §5.2 gözlem 5 (220 hafta sürümsüz, sıfır kayıp); §3.1 güncellenmemenin ayrılma payı bulunamadı, yalnız kalitatif.
- Sınır: kural bir sprint tredmilidir; EA'da kademe tavanından sonra yeni içerik olmadan herkesi cezalandırmaması için (b) ya da (c) gerekir. Ayrılma payı bilinmediği için büyüklük tahmin.

**5. Ürün terimi yalnız görünür alanlardan gelir (Q1) ve çıta ile birlikte okunur.**
- Seçenek: `70 × min(seviye / çıta, 1,5)` (X §6.3) ya da kırpmasız.
- Kanıt: donmuş ürünün sonu üç ailede aynı (§5.2 gözlem 1); gizli eksen oyuncudan saklı olduğu için ayrı bir itirazın konusu (X §2.1).
- Sınır: 1,5 kırpma ürün terimini 105'e çıkarıyor; ceza tavanı 40 ile birlikte aynı ölçümde seçilmeli (X §6.3 notu).

**6. Aile seçimi, ödül zamanı ve istismar penceresi arasında bir takas.**
- (iii): düşüş az ama ürün emeği 52 hafta bekler, yenileme öncesi "satın alma" penceresi açılır.
- (ii): ödül anında, ama faz uçurumu ve spam sürüm riski (yalnız gerçek seviye artışı sayılırsa kapanır).
- (i): mevcut kod, en az iş; gürültü ve gecikme kalır.
- Kanıt: §5.1 tabloları (C satırı: (iii) 52. haftada 66-70, ötekiler 99-100), §5.3.
- Sınır: simülasyon tek hesap ve varsayımsal parametreli.

**7. Ölçek: hata cezası yoğunluğa, olay tutarı olayın cinsine bağlansın.**
- Seçenek: ceza = `k × açık hata / yayındaki özellik grubu` (D5 ile aynı yön); olay tutarları (kesinti, söz) ekip büyüklüğüne değil olayın cinsine.
- Kanıt: C §2.5.2 kendi ölçek uyarısını yazıyor (50 kişide açık hata 19, ceza 6, tavandan uzak); sayıya bağlı ceza ekip 10 katına çıkınca 10 katına çıkar, yoğunluk değişmez (akıl yürütme, ölçüm değil). Simülasyonda hata faturasının d≥0,5 eşiği olay defterinde doğrusal ceza ile çelişir; eşik ve ölçek birlikte seçilmeli.
- Sınır: ölçüm yok; K5 kapısı büyük ekip koluyla yeniden koşulmalı.

**8. Ürüne bağlı olmayan ayrılma ayrı kanal, nedeni mailde yazılı, memnuniyete dokunmaz.**
- Seçenek: yenileme anında düşük ihtimalle "bütçe/kapanış/satın alma" kararı (Erdem C5 ek); isteğe bağlı adlı olay "şampiyon ayrıldı" (ihtimali yükseltir, memnuniyeti değil).
- Kanıt: §3.3: kapanma/bütçe payı %8 ile %34 arasında çelişiyor; BLS yalnız yeni işletmeler için üst sınır. Sayı için güvenilir kaynak yok: yıllık oran **tahmin** ve kalibrasyonla seçilmeli; şampiyon ayrılması %51/%65 sayıları doğrulanamayan tek zincir.
- Sınır: memnuniyetten bağımsız bu kanal "iyi oynadım, yine de kaybettim" hissi verebilir; mailin nedeni ve "ürün dışı" etiketi kayıp ekranında ayrı görünmeli.

---

## 8. Ek: simülasyon betiği ve yöntem

Betik (`python -I sat_sim.py`, yalnız standart kitaplık), §5.1 çıktısını üretir. Parametreler yukarıdaki kurulum paragrafında. Sınırlar: tek hesap; seviye tek sayı (alan ayrımı yok); çıta olayları sabit hafta; hata fatura eşiği ve kesinti büyüklükleri varsayım; (ii) ve (iii) için yenileme/okuma kuralı basitleştirilmiş; ürün terimi 100'e kırpılıyor (kırpma öncesi birikim (ii)'de uçurum sayısını büyütür); "olaysız düşüş" tanımı dar.

Gerçek kodla farklar: (i) satırı bugünkü kod değil, "bugünkü şekil + C'nin ürün terimi" (gizli eksen yerine alan oranı); hata cezası tavanı 40 (C §2.5.2 önerisi), 20 değil; defter kayıtları hafta tabanlı.

```python
"""R9: memnuniyet model ailelerinin tek-hesap simulasyonu. Yalniz Python (python -I).
Her parametre [varsayim]; kod sabiti degil. Amac sayi vermek degil, ailelerin sekil farkini gostermek."""
import math

WEEKS = 270
SIGN = 10
TOLS = [36, 45, 54]
OUTAGES = {40: 6.0, 90: 6.0, 150: 6.0}
BROKEN_AT = 50


def expectation(t):
    e = 1.0 if t < 26 else 2.0
    return min(e + 0.5 * (t >= 70) + 0.5 * (t >= 120), 3.0)


def level(arch, t):
    k = lambda per, cap: min(cap, 1.0 + 0.5 * math.floor(max(0, t - SIGN) / per))
    if arch == "A": return k(8, 3.0)
    if arch == "B": return k(8, 1.5)
    if arch == "C": return k(5, 3.0)
    if arch == "D":
        if t < 40: return k(8, 3.0)
        base = 1.0 + 0.5 * math.floor(30 / 8)
        return base if t < 120 else min(3.0, base + 0.5 * math.floor((t - 120) / 8))


def density(arch, t):
    return {"A": 0.4, "B": 0.1, "C": min(3.0, 0.4 + 0.05 * max(0, t - SIGN)), "D": 0.4}[arch]


def prod(arch, t):
    return 70.0 * min(level(arch, t) / expectation(t), 1.5)


def bug_level_pen(d):
    return min(6.0 * d, 40.0)


def last_release(arch, t):
    last = SIGN
    for u in range(SIGN + 1, t + 1):
        if level(arch, u) > level(arch, u - 1): last = u
    return last


def stale_steps(arch, t):
    w = t - last_release(arch, t)
    return min(15, max(0, (w - 26) // 4)) if w > 26 else 0


def events_at(arch, t, stale):
    """(hafta, tutar, solma) ; solma>0 doğrusal haftalar, 0 = urunle silinene dek kalici (stale)."""
    out = []
    if t in OUTAGES: out.append((t, -OUTAGES[t], 26, "kesinti"))
    if t == BROKEN_AT: out.append((t, -12.0, 13, "soz"))
    d = density(arch, t)
    if (t - SIGN) % 4 == 0 and d >= 0.5: out.append((t, -1.0 * d, 26, "hata"))
    return out


def fade(e, t):
    wk, amt, f, _ = e
    return amt * max(0.0, 1 - (t - wk) / f)


def simulate(model, arch, tol, stale):
    sat = None
    prev = None
    ledger = []
    sat0 = None
    dp_sum = 0.0
    anchor = None
    below = unexpl = 0
    maxdrop = 0.0
    trace = {}
    for t in range(SIGN, WEEKS):
        age = t - SIGN
        lv, ex = level(arch, t), expectation(t)
        released = t > SIGN and lv > level(arch, t - 1)
        exp_up = t > SIGN and ex > expectation(t - 1)
        evs = events_at(arch, t, stale) if t > SIGN else []
        stale_tick = False
        if stale and t > SIGN:
            w = t - last_release(arch, t)
            if w > 26 and (w - 26) % 4 == 0 and (w - 26) // 4 <= 15:
                stale_tick = True
        had = bool(evs) or released or exp_up or stale_tick
        if model == "i":
            trust = -12.0 * max(0.0, 1 - (t - BROKEN_AT) * 2.8 / 12.0) if t >= BROKEN_AT else 0.0
            out = sum(-a * max(0.0, 1 - (t - o) / 4.0) for o, a in OUTAGES.items() if t >= o)
            target = prod(arch, t) - bug_level_pen(density(arch, t)) + trust + out
            if stale: target -= stale_steps(arch, t)
            if age < 4: target = max(target, tol + 2)
            target = min(100.0, max(0.0, target))
            if sat is None:
                sat = float(max(tol + 10, 50))
            else:
                up = 35 if age < 4 else 21
                dn = 35 if age < 4 else 21
                sat += max(-dn, min(up, target - sat))
        else:
            if t == SIGN:
                sat0 = prod(arch, t)
                anchor = sat0
            else:
                ledger.extend(evs)
                if model == "ii":
                    dp_sum += prod(arch, t) - prod(arch, t - 1)
                else:
                    if age % 52 == 0:
                        anchor = prod(arch, t)
                        had = True
            ev_sum = sum(fade(e, t) for e in ledger)
            st = -float(stale_steps(arch, t)) if stale else 0.0
            if model == "ii":
                sat = sat0 + dp_sum + ev_sum + st
            else:
                sat = anchor + ev_sum + st
            sat = min(100.0, max(0.0, sat))
        if prev is not None:
            dl = sat - prev
            maxdrop = min(maxdrop, dl)
            if dl <= -5 and not had: unexpl += 1
        prev = sat
        if sat < tol: below += 1
        trace[age] = sat
    return trace, unexpl, maxdrop, below


def main():
    names = {"i": "(i) gizli hedefe kayma", "ii": "(ii) olay defteri", "iii": "(iii) capa+olay"}
    an = {"A": "A duzenli", "B": "B donmus", "C": "C hizli-ozensiz", "D": "D durgun-sonra-doner"}
    for stale in (False, True):
        print(f"\n===== 'GUNCELLEME GELMIYOR' KURALI {'ACIK' if stale else 'KAPALI'} =====")
        print("sat@hafta(imzadan) 1/4/12/26/52/104/208 (esik 45) | esik-alti hafta (3 esik toplam, 260 hafta) | olaysiz dusus>=5 hafta | en buyuk haftalik dusus")
        for arch in "ABCD":
            for m in ("i", "ii", "iii"):
                bl = un = 0
                worst = 0.0
                row = None
                for tol in TOLS:
                    tr, u, md, b = simulate(m, arch, tol, stale)
                    bl += b; un += u; worst = min(worst, md)
                    if tol == 45: row = [round(tr[w]) for w in (1, 4, 12, 26, 52, 104, 208)]
                print(f"{an[arch]:21s} {names[m]:24s} {str(row):34s} {bl:4d} {un:3d} {worst:6.1f}")


if __name__ == "__main__":
    main()
```
