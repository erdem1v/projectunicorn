# A2 · Oyun dökümü 2: iş önceliği, devretme ve gerçek ekiplerde kapasite planlama

Faz D, Atama araştırması, adım A2. Tarih: 2026-10-20. Yalnız okuma ve web araştırması yapıldı; oyun koduna, CSV'ye, data'ya dokunulmadı.
Kapsam: RimWorld, Oxygen Not Included (ONI), Football Manager (FM), gerçek ekipler (Scrum, Kanban, DeMarco, kuyruk kuramı, Brooks, kısıt kuramı). Ek olarak, kaldırılan/değişen atama sistemleri araması sırasında Dwarf Fortress'in otomatik iş dağıtımı (DFHack autolabor) kısaca bakıldı.

Etiketler: [S#] kaynaklı olgu. (varsayım A#) varsayım. [BOŞLUK] kanıtsız yük taşıyan iddia. [SIÇRAMA] kanıttan çıkmayan sonuç. [DEĞERLENDİREMEM] elimdeki kanıtla hüküm veremem. [GÖRÜŞ] benim yargım.

Okuma uyarısı (dürüstlük notu): web arama aracı sonuçları kendi içinde özetleyerek veriyor. Sayfayı kendim açıp okuduğum kaynaklar sicilde "açıldı" diye işaretli; yalnızca arama özetinden bildiğim kaynaklar "yalnız arama özeti" diye işaretli ve bunlara dayanan cümleler zayıf sayılmalı. Sayfa okuma bütçesi (25) doldu; şüpheci doğrulamanın ikinci elden açılış kısmı bu yüzden Bölüm 7'de sınırlı.

---

## 0) Erdem için özet (10 madde)

1. İki "atama zihniyeti" var. RimWorld ve ONI'de oyuncu kişi başına bir kalıcı öncelik tablosu kurar (hangi iş türünü hangi sırayla yapsın), iş kişiye tek tek atanmaz, kişi kendisi çeker. RimWorld'de her iş türü için 1-4 öncelik, eşitlikte soldaki sütun önce; ONI'de kişi başına kategori önceliği ve ayrıca bina/iş başına alt öncelik 1-9 [S101][S102][S103]. Senin tarifin ise kart başına kişi seçen "it" modeli; bu ikisi farklı şeyler (aşağıda GÖRÜŞ).
2. Büyük koloniye geçince bu oyunlardaki ölçek çaresi "kişi başı elle ayar" değil "politika": ONI wiki "gizli öncelikler küçük koloniler için, Enable Proximity büyük koloniler için daha iyi" diyor [S102]; oyuncular ONI'de ~100. döngüde yönetimin mikro yönetime döndüğünü ve boşta duplikant yığıldığını yazıyor [S110].
3. RimWorld'de oyuncu-tarafı ders: ağır kuralın tuzağı var. Taşıma önceliği 1 yapılırsa koloniciler "verimliliği umursamadan" her şeyi taşır [S101]; çiftçi olan bir kişi hiç ekmediği için koloninin açlıktan öldüğü bir vaka var [S106]. Yani öncelik sistemi güçlüyse yanlış kurulması da pahalı.
4. RimWorld'de "5 kişiden az koloni mikro yönetimsiz olamaz" ve "koloni büyüdükçe öncelik dengelemek kolaylaşır" görüşü var [S105] (oyuncu görüşü, tek ileti). Bu, küçük ekipte elle atamanın zaten doğal olduğu sezgisini destekliyor, ama tek iletiyle sağlam kanıt değil.
5. FM'de devretme oyunun resmî ve temel çözümü: Sorumluluklar ekranında her görevin yanında bir personel, açılır listeden seçilir; devir kalitesi o personelin özniteliklerine bağlı; oyuncu da hesap sorulan kişi olarak kalır [S112][S113]. Yeni oyuncular "çok karmaşık" dediğinde cevap "çoğunu personele ver" oluyor; bir tane eğlenceli işi elinde tut, her sezon biraz geri al [S114].
6. FM'de devir tamamen sorunsuz değil: devredilen asistan antrenmanda yine onay istiyor [S113]; devredilen kategoride Teknik Direktör sormadan sözleşme teklif etmiş [S115, yalnız arama özeti]. Ders: devir sınırı oyuncuya net söylenmeli, sürpriz kızdırıyor.
7. Boşta kalma: RimWorld ve ONI'de "boşta işçi" bir mekanik değil, bir arıza belirtisi olarak yaşanıyor (yanlış iş sekmesi, yaralı, alan çakışması; ONI'de iş biten ekibin boşta kalması) [S109 yalnız arama özeti][S110]. DeMarco, kuyruk kuramı ve kısıt kuramı ise "herkesi %100 meşgul tutmak" hedefinin zararlı olduğunu savunuyor [S122][S124][S129]. Bu, "kimse boşta kalmaz" kuralının oyuncuya angarya yaptırmaması gerektiği anlamına geliyor [GÖRÜŞ].
8. Darboğaz gösterimi: Kanban'ın standardı, bir sütunun WIP sınırını aşmasını görünür yapmak ve birikim grafiğinde şişen şeridi göstermek [S120][S121] (satıcı belgesi, Düşük güven). Oyunlarda doğrudan "bu planda darboğaz var" uyarısı bulamadım; DF'nin otomatik dağıtıcısı bile atamaları gösteren bir ekrana sahip değil, "ne yaptıklarını izlemelisiniz" diyor [S131].
9. İki kişiyi tek işe koymak bedelsiz değil: Brooks yasası iş bölünemiyorsa eklenen kişinin yardım etmediğini, iletişim ve eğitim yükü getirdiğini söylüyor [S126, ikincil kaynak]. Tarifindeki "tek kişinin yetmediği işe iki kişi" kuralı kart türüne göre bölünebilirliği tanımlamak zorunda [GÖRÜŞ].
10. Senin tarifin (uzman en zor işe, yeten en düşük beceri küçük işe, kimse boşta kalmaz) kitaptan-benzeri iki kavramla uyumlu: Scrum'da ekip kimin neyi yapacağına kendisi karar verir, dışarıdan atanmaz [S117]; T-şekilli ekip yazıları "uzmanı pahalı işe sakla, genelciyi esnek kullan" diyor (Düşük güven) [S127][S128]. Ama oyunlarda "yetecek en düşük beceriyi bul" kuralının oyuncu tarafından görünür olması şart; yoksa RimWorld'deki gibi gizli mantık ("neden oraya gitti?") soruna dönüşür [S106 yapı olarak]. [GÖRÜŞ]

---

## 1) Kaynak sicili (S101-S199)

Erişim tarihi hepsi için 2026-10-20. "Açıldı" = sayfayı WebFetch ile okudum. "Yalnız arama özeti" = sayfayı açmadım, arama aracının özetine güveniyorum.

| S# | URL | Yayıncı | Yayın tarihi | Durum | Güven |
|---|---|---|---|---|---|
| S101 | https://rimworldwiki.com/wiki/Work | RimWorld Wiki | son düzenleme 2026-06-23 (sayfa "taslak" işaretli) | açıldı | Orta |
| S102 | https://oxygennotincluded.wiki.gg/wiki/Priority | ONI Wiki (wiki.gg) | belirtilmemiş | açıldı | Orta |
| S103 | https://oxygennotincluded.wiki.gg/wiki/Versions/OC-253538 | ONI Wiki, sürüm notu | güncelleme 2018-02-01 | açıldı | Orta |
| S104 | https://oxygennotincluded.wiki.gg/wiki/Skills | ONI Wiki | belirtilmemiş | açıldı | Orta |
| S105 | https://steamcommunity.com/app/294100/discussions/0/3279191623106894422 | Steam, RimWorld tartışma "Balancing priorities (especially hauling and farming)" | 2022-04-05 | açıldı | Orta (oyuncu görüşü) |
| S106 | https://steamcommunity.com/app/294100/discussions/0/2381701715727097818 | Steam, RimWorld tartışma "Is there anyway to actually prioritize work?" | 2017-10-23, yanıtlar 2024-07-31'e dek | açıldı | Orta (oyuncu görüşü) |
| S107 | https://github.com/DingoDjango/DDWorkTab | GitHub, DD Work Tab modu | belirtilmemiş | yalnız arama özeti | Düşük |
| S108 | https://steamcommunity.com/sharedfiles/filedetails/comments/2029596262 | Steam Atölye, "Work Manager" modu yorumları | belirtilmemiş | yalnız arama özeti (iki açma denemesi HTTP 429) | Düşük |
| S109 | https://steamcommunity.com/app/294100/discussions/0/1743346190293605633/ (ve arama sonucundaki diğer RimWorld "idle colonist" iletileri) | Steam, RimWorld tartışmaları | belirtilmemiş | yalnız arama özeti | Düşük |
| S110 | https://steamcommunity.com/app/457140/discussions/0/5051317596394504333 | Steam, ONI "Mid-Late game interest loss" | 2021-01-15 | açıldı | Orta (oyuncu görüşü) |
| S111 | https://steamcommunity.com/app/457140/discussions/0/592884947430211421 | Steam, ONI "How do you handle long commutes..." | 2024-12-30 | açıldı | Orta (oyuncu görüşü) |
| S112 | https://www.footballmanager.com/the-dugout/delegating-success-football-manager-26 | Football Manager (resmî), The Dugout | 2026-01-09 | açıldı | Yüksek (resmî kural anlatımı; pazarlama tonu var) |
| S113 | https://steamcommunity.com/app/2252570/discussions/0/5715692378857437753 | Steam, FM24 "Delegate Training" | 2023-11-16 | açıldı | Orta (oyuncu görüşü) |
| S114 | https://steamcommunity.com/app/2252570/discussions/0/3957035999324108595 | Steam, FM24 "It's too complicated for me" | 2023-11-08, yanıtlar 2025-03-22'ye dek | açıldı | Orta (oyuncu görüşü) |
| S115 | https://www.fmscout.com/q-21877-Assistant-manager-making-subs-during-games.html (ve Steam FM24 tartışması 3957035999332611526) | FM Scout forum, Steam | belirtilmemiş | yalnız arama özeti | Düşük |
| S116 | https://videogamer.com/features/someone-got-so-tired-of-their-assistant-manager-they-made-their-own-one | VideoGamer | belirtilmemiş | yalnız arama özeti (sayfa HTTP 404 verdi) | Düşük |
| S117 | https://scrumguides.org/scrum-guide.html | Scrum Guide, Schwaber ve Sutherland (2020 sürümü) | 2020-11 | açıldı | Yüksek |
| S118 | https://www.smartsheet.com/content/agile-sprint-scrum-capacity-planning | Smartsheet (satıcı) | belirtilmemiş | yalnız arama özeti | Düşük |
| S119 | https://xebia.com/articles/capacity-planning-in-an-agile-scrum-environment/ | Xebia (danışmanlık) | belirtilmemiş | yalnız arama özeti | Düşük |
| S120 | https://learn.microsoft.com/en-us/azure/devops/boards/boards/kanban-overview?view=azure-devops | Microsoft Learn, Azure Boards (satıcı belgesi) | ms.date 2026-06-08 | açıldı | Düşük (satıcı) |
| S121 | https://processgroup.com/kanban-what-it-is-and-using-it-with-agile-or-cmmi/ | The Process Group (danışmanlık) | belirtilmemiş | yalnız arama özeti | Düşük |
| S122 | https://lenholgate.com/blog/2003/05/slack---tom-demarco.html | Len Holgate, kişisel blog; Tom DeMarco'nun "Slack" kitabının özeti | 2003-05-23 | açıldı (DeMarco'dan doğrudan alıntı yok, ikinci el) | Orta/Düşük |
| S123 | https://www.fastcompany.com/43479/slack | Fast Company (DeMarco yazısı) | belirtilmemiş | yalnız arama özeti | Düşük |
| S124 | https://en.wikipedia.org/wiki/Kingman%27s_formula | Vikipedi; kaynak: J. Kingman, "The single server queue in heavy traffic", 1961 | 1961 (makale) | açıldı | Orta |
| S125 | https://taborsky.cz/posts/2021/kingman-formula/ (ve arama sonucundaki diğer pratisyen yazıları) | Michal Táborský, blog | 2021 | yalnız arama özeti | Düşük |
| S126 | https://lawsofsoftwareengineering.com/laws/brooks-law/ | Laws of Software Engineering (derleme site); kaynak: F. Brooks, "The Mythical Man-Month", 1975 | 1975 (kitap) | açıldı | Orta/Düşük (ikincil) |
| S127 | https://agilepainrelief.com/blog/specialists-are-overrated/ | Agile Pain Relief (danışman blogu) | belirtilmemiş | yalnız arama özeti | Düşük |
| S128 | https://alexkondov.com/the-t-shaped-engineer/ | Alex Kondov, kişisel blog | belirtilmemiş | yalnız arama özeti | Düşük |
| S129 | https://www.antoinebuteau.com/the-goal-book-summary/ (Goldratt, "The Goal" özeti) ve arama sonucundaki satıcı blogları | Antoine Buteau, kişisel blog | belirtilmemiş | yalnız arama özeti | Düşük |
| S130 | https://tezara.org/theses/109761 | Tez, kısıt kuramı ve zaman tamponu | belirtilmemiş | yalnız arama özeti | Orta/Düşük |
| S131 | https://docs.dfhack.org/en/latest/docs/tools/autolabor.html | DFHack belgeleri (Dwarf Fortress eklentisi) | belirtilmemiş | açıldı | Orta (araç belgesi) |
| S132 | https://dwarffortresswiki.org/Job | Dwarf Fortress Wiki | belirtilmemiş | yalnız arama özeti | Orta/Düşük |

Not: S132 yalnız çalışma-ayrıntısı (work details) kipleri için kullanıldı.

---

## 2) Konu konu döküm

### 2.1 RimWorld

Kural (kim atar, nasıl): İki kip var. Standart kipte kolonici yalnız kendisine açık iş türlerini yapar ve soldaki iş türü sağdakinden önce gelir. Elle öncelik kipinde her iş türüne 1 (en yüksek) ile 4 arası değer verilir ya da boş bırakılır; boş iş yapılmaz. Aynı öncelikte soldaki sütun önce yapılır. Daha yüksek öncelikli iş, hazır olduğu sürece düşüğünden önce tamamen bitirilir [S101]. Yani atamayı oyuncu kart/iş bazında yapmıyor; her kişiye "şu iş türlerini şu sırayla yap" der ve kişi çeker. Sayfa, oyunun bir işi hangi kolonici seçtiğini anlatmıyor [S101]. Tek seferlik doğrudan atama da var: hedefe sağ tıkla "önceliklendir"; bedeli, kolonicinin yemeyi/dinlenmeyi unutabilmesi ve ruh halinin düşmesi [S106 (2024 yanıtı)].

Neden var (yazılı gerekçe): Bulunamadı. [DEĞERLENDİREMEM] (wiki bir gerekçe vermiyor [S101]). Oyuncu tarafından anlatılan fayda: kıt iş gücünü uzmanlaştırma [S105].

Ekran (oyuncu neyi görüyor): Beceri kutuları kırmızıdan (en kötü) beyaza, parlak sarıya (en iyi) renk skalasıyla gösteriliyor; tutku alev simgesi olarak; becerisi düşük birini o işe atayınca "çıtırtı sesi" çıkıyor; bir işi hiç yapamayan kişinin kutusu yok [S101]. Yani "bu kişi bu iş için ne kadar iyi" kararı, kişiyi işe bağlarken ekranda görünür.

Boşta kalan: Resmî sayfa boşta kolonicileri anlatmıyor [S101]. Oyuncu iletilerinde (yalnız arama özeti) boşta kalmanın nedenleri: iş sekmesi yanlış, kolonici yaralı/bağlı, mahkum alanı koloni alanıyla çakışıyor, taşıma öncelik listesinin altına indirilince bekleme; bir yanıt "iş yoksa kolonici dolaşmaya düşmeli, saatlerce duruyorsa bu hata" diyor [S109]. Ayrı bir kullanım: bazı oyuncular düşük öncelikleri (4) "boştayken yapılacak yedek iş" olarak kullanıyor (örnek: yedek doktor 4) [S106]. Resmî bir "boşta kolonici" uyarısı var mı: bulunamadı, [DEĞERLENDİREMEM].

Darboğaz: Oyun içi darboğaz gösterimi bulunamadı. Oyuncu tarafı: işlerin yığıldığını gözle görmek (örnek: tarlada çürüyen ürün) ve çare olarak taşıma önceliğini kısa süreli yükseltmek [S105]. Bir oyuncu "tüm kolonide geçici öncelik ezme düğmesi" istiyor [S105].

1 kişi: Kişi başına öncelik anlamsız; tek kolonici her şeyi yapar. [GÖRÜŞ] Yorum olarak: "5 kişiden azsa mikro yönetim kaçınılmaz" [S105] 1 kişi için de geçerli (tek kişi zaten tek tek iş seçiyor).
3 kişi: Kaçınılmaz mikro yönetim bölgesi [S105]. Beceri/tutku görselleri en çok burada işe yarar (kimin neyi yapacağı net). [GÖRÜŞ]
6 kişi: Alttaki "5 kişiden az" eşiğinin üstünde; uzmanlaşma başlıyor [S105]. Ayrıntı yok [DEĞERLENDİREMEM].
12 kişi: Oyuncular 10-12 ya da 16-20 kolonici hedefliyor (yalnız arama özeti [S105'in çevresindeki ileti kümesi]); işin yığıldığı, taşıma ve çiftçilik önceliğinin tek tek dengelendiği ölçek [S105]. 1-3 kişiyi özel taşıma işine ayırma tavsiyesi [S105].
25 ve 50 kişi: Bu iki ölçek için RimWorld kaynaklarında doğrudan kanıt bulunamadı. Mod ekosistemi (Work Tab alt görev öncelikleri 1-9, sürükle-bırak DD Work Tab, saatte birkaç kez öncelikleri yenileyen Work Manager) vanilla'nın büyük kolonide yetersiz kaldığını dolaylı gösteriyor [S106][S107][S108] ama bu bir çıkarım [SIÇRAMA riski]: mod varlığı yetersizlik kanıtı değil, istek kanıtı.

Övgü: Elle öncelik kipi öğrenilince oyuncular onu kullanmayı tercih ediyor [S106]. Küçük, birkaç kademeli öncelik (ana iş 3, ikincil 2, yedek 4) yeterli bulunuyor [S106].
Şikâyet: Öncelik yükü ve donanım: "bir tarlada tek karo bile işlemedi, açlıktan öldük"; oyun çok ayrıntı, oyuncu "tembellik" yüzünden mikro yönetmek istemiyor [S106]; 300 saatten sonra bile ürünün dörtte üçünü çürümekten kurtarmanın tek yolu taşıma önceliğini azamiye çekmek [S105]. Work Manager modunda (yalnız arama özeti): doktor ataması hatası, iş türü kapatınca otomasyonun durması, "pawn'lara hep hiçbir şey atanıyor, boşta dolaşıyorlar" [S108, doğrulanmadı].

### 2.2 Oxygen Not Included

Kural: Her duplikant için her iş kategorisinde öncelik ayarlanır (L tuşu); kategori "devre dışı" olabilir ve devre dışıysa boşta bile olsa o işi yapmaz [S102]. En yüksek öncelikteki mevcut iş seçilir; eşit önceliklerde bina/iş başına alt öncelik (P tuşu, 1-9, yüksek önce) bakılır, o da eşitse gizli varsayılan sıra; "Enable Proximity" açılırsa en yakın iş seçilir [S102]. Öncelikler 2018-02-01 güncellemesinde 1-9 oldu; roller artık yalnız aynı öncelik düzeyi içinde sıralamayı etkiliyor, önceki sistemde bir rol daha düşük öncelikli işi öne alabiliyordu; geliştirici "öncelikleri daha sonra gözden geçirmeyi rafa kaldırdık" demiş [S103]. Beceriler bazı işleri açıyor ve öznitelik artırıyor; ilgi alanı deneyim kazanma hızını artırıyor, işi yapıp yapmamayı değil [S104].

Neden var: Wiki gerekçe vermiyor; ama "gizli öncelikler küçük koloniler için, Enable Proximity büyük koloniler için daha iyi" cümlesi ölçeğe göre varsayılanın değişmesi gerektiğini açıkça söylüyor [S102].

Ekran: Öncelik paneli (kişi x kategori tablosu), alt öncelik bindirmesi, kişisel ihtiyaçlar (tuvalet, yemek, uyku) önceliklerden bağımsız geliyor; Sarı/Kırmızı alarm programı ezer [S102]. "Idle" durumunu wiki anlatmıyor [S102].

Boşta kalan: Oyuncu raporları: ~100. döngüde "boşta duplikant yığını" ve "mikro yönetim" [S110]. Cevaplar: Proximity'yi aç, öncelikli işe birden çok duplikant ata [S110]; en önemli işi (inşaat) en üste, diğerlerini nötre/düşüğe çek ve proje önceliğini en fazla bir puan değiştir [S111]; koloniyi ~8 duplikantta tut, tek projeye odaklan [S111].
İletilerden biri (yalnız arama özeti, doğrulanamadı): 2017'de büyük kazı bitince fazla duplikantların boşta kalıp stresin yükseldiği iddiası; ilgili bağlantıyı açtığımda başka bir ileti çıktı, bu yüzden bu tek iddia [DEĞERLENDİREMEM] olarak kalıyor.

Darboğaz: Oyunda doğrudan darboğaz uyarısı bulunamadı. Oyuncu iletisi: seçili duplikantın iş listesini inceleyip sonraki işin ne ve neden olduğunu görmek (yalnız arama özeti, kaynak URL'si doğrulanmadı) [DEĞERLENDİREMEM]. Uzun gidip gelme süreleri darboğazın biçimi olarak anılıyor (yürüme süresi) [S110][S111].

1 kişi: Yok (oyun üç kişiyle başlar); kıyas için geçersiz.
3 kişi: Başlangıç ölçeği; "erken oyunda öncelikleri kurcalama" tavsiyesi (yalnız arama özeti) ve oyuncu "küçük koloni" tavsiyesi [S111]. Wiki: gizli öncelikler küçük koloni için daha iyi [S102].
6 kişi: Küçük koloni kategorisi (bir oyuncu 8'de tutuyor) [S111]. 
12 kişi: Geçiş bölgesi, kesin eşik yok [DEĞERLENDİREMEM].
25 ve 50 kişi: ONI bu ölçekleri düzenli olarak oynatmaz; oyuncu kaynaklarında büyük koloni ~16-20 hatch tarzı sayılar var ama duplikant sayısı değil [S111]. Bu ölçek için kanıt yetersiz [DEĞERLENDİREMEM]. En yakın veri: ~100. döngü şikâyetleri (kaç duplikant olduğu yazılmamış) [S110].

Övgü: Proximity ve çoklu duplikant ataması gibi araçlar işe yarıyor [S110]; öncelik sistemi derinlik veriyor (resmî yazı yok, oyuncu iletilerinde dolaylı).
Şikâyet: Proximity ayarı arayüzde gizli ("neden gizli?") [S110]; orta-geç oyunda iş "şehir kurmadan mikro yönetime" dönüyor ve boşta duplikant yığılıyor [S110].

### 2.3 Football Manager

Kural: Sorumluluklar ekranı her görevi bir personelle eşleştirir; açılır listeden seçilir. Görevler: hazırlık maçları, basın toplantıları, gözlemcilik atamaları ve rakip analizi, oyuncu ve personel sözleşme pazarlıkları, duran top rutinleri [S112]. Kalite: "en uygun özniteliğe sahip adayları" koy; örnek eşleşmeler (gözlemci: potansiyel/mevcut yetenek yargısı; futbol direktörü: yargı ve pazarlık; duran top: duran top ve taktik bilgisi) [S112]. Her sorumluluğun her personele açık olmadığı (yeterlilik şartı) arama özetinde geçiyor ama bu tek özetten, sayfa açılmadı (dotesports/fifauteam) [DEĞERLENDİREMEM]. Resmî yazı, asistanın bağımsız mı karar verdiğini ya da oyuncunun onay hakkını anlatmıyor [S112].

Neden var: Resmî çerçeve: "FM'de en etkili patron olmak için iyi devredici olmalısın" [S112]; yani devretme bir oyun ustalığı, kaçış değil. Oyuncu çerçevesi: karmaşıklığı azaltmak [S114].

Ekran: Sorumluluklar listesi, görev yanında isim; yeni sürümlerde kategoriye göre süzme (yalnız arama özeti). Sorumluluğu devretmenin sonucu, oyuncuya bildirim ve onay isteği olarak geri geliyor (örnek: antrenman riski uyarısı) [S113].

Boşta kalan: Kavram yok (kadro/personel için doluluk yerine yetkinlik önemli). Bulunamadı.
Darboğaz: Kavram yok. Bulunamadı.

1 kişi: Oyuncu tek başına yönetici; devir yok (personel hiç yoksa her şey oyuncuda) [S112 örtük].
3 kişi, 6 kişi: Küçük arka oda; en kritik rol başına bir kişi; "öznitelik eşleştirme" burada anlamlı [S112].
12, 25, 50 kişi: FM kulüp personeli onlarcadır; devir yapısı zaten kategori bazlı olduğundan ölçekle birlikte kırılmıyor, ama bunun kanıtı yok; oyuncu iletisi "çoğu işi personele verirsen sadece oyuncu alır ve kadro seçersin" [S114]. Ölçek davranışı üzerine ölçülmüş veri [DEĞERLENDİREMEM].

Övgü: Devir, yeni oyuncuyu kurtarıyor; "bir eğlenceli işi elinde tut, her sezon geri al" yaklaşımı (kademeli öğrenme) [S114]; "oyun çok şeyi devretmene izin veriyor, çok daha kolay olabilir" [S114].
Şikâyet: Oyun hâlâ çok karmaşık bulunuyor ("sadece sorumluluklar değil") [S114]; devredilince bile onay uyarıları kafa karıştırıyor ve oyuncu sorumluluğu devretmenin kendisine ait kalıp kalmadığını soruyor ("sonuçta takım senin, sorumlu sensin") [S113]; devredilen kategorilerde sürpriz kararlar (Teknik Direktör'ün sormadan sözleşme teklifi; asistanın kendiliğinden oyuncu değişikliği yapması) [S115, yalnız arama özeti]; asistan teknik kadro tavsiyeleri "yıllardır espri konusu" [S116, yalnız arama özeti; sayfa 404].

### 2.4 Gerçek ekipler

#### Scrum (sprint kapasite planlaması)
Kural: Scrum ekibi "özyönetimli": "kim neyi, ne zaman, nasıl yapacak" ekip içinde kararlaştırılır [S117]. Sprint planlamasında Geliştiriciler Ürün Sahibiyle konuşarak işleri seçer; Ürün Sahibi tavsiye eder ama atama yapmaz; "bunun nasıl yapılacağı yalnız Geliştiricilerin takdirindedir" [S117]. Geliştiriciler geçmiş performansı ve "yaklaşan kapasiteyi" bilince tahmin daha güvenilir olur [S117]. Ekip "işlevler arası": gerekli tüm becerilere sahip [S117].
Kapasite hesabı (Düşük güven, satıcı): kişi başı brüt saatten (2 haftada ~80) toplantı, izin, odak payını düşersin; ekip kapasitesi bireysel kapasitelerin toplamı; plan belirsizlik için %15-20 tampon bırakır [S118][S119]. Aynı arama sonucu, uzmanlık ağırlıklandırması için yöntem bulamadı; "kişi uzmanlığını göz önüne al" dışında bir şey yok [arama özeti] [BOŞLUK: uzman kapasitesinin sprint planında nasıl hesaplandığı].
Neden var: Takım kimin neye yeteceğini en iyi kendisi bilir (Scrum Guide mantığı) [S117]; gerekçe cümlesi aynen yok, yorumum [GÖRÜŞ].
Ölçek: Scrum Guide 10 kişi ya da daha azı önerir mi: bu sayfada okuduğum özette sayı geçmedi [DEĞERLENDİREMEM]. 1 kişi: "ekip" yok. 3-6 kişi: kural doğrudan uygulanır. 12 ve üstü: Scrum bu noktada ekibi bölmeyi öneriyor olabilir ama bu sayfadan çıkaramadım [DEĞERLENDİREMEM]. 25, 50: kanıt bulunamadı.

#### Kanban (WIP sınırı ve darboğaz görünürlüğü)
Kural/ekran: Pano sütunlarda iş kartlarını gösterir; WIP sınırı sütuna konur ve sınır aşılınca sütun öne çıkar, ekip darboğazı kaldırmaya yönelir [S120][S121 özet]. Birikimli akış grafiği (CFD) her durumdaki iş sayısını zamanla çizer; şeritler paralelse akış sağlıklı, bir şerit şişiyorsa darboğaz işaretidir [S120 + yalnız arama özeti]. "Bölünmüş sütunlar" özelliği, işin bir sonraki aşamaya itilmesiyle gerçekten başlamasının farklı olduğunu, kaç işin beklediğini göstermek için var [S120]. Bu, "boşta" olanı kişi yerine kuyruktaki iş olarak gösteriyor.
Neden var: Çok iş aynı anda açıkken bağlam değiştirme verim kaybettiriyor; WIP sınırı sürekli akışı korur [S120].
Ölçek: Küçük ekipte (1-3) sınır neredeyse kendiliğinden; büyük ekipte görünürlük şart. Bu bağlamda ölçüm yok [DEĞERLENDİREMEM].

#### DeMarco "Slack" ve kuyruk kuramı (boşta kalmanın yararı)
- DeMarco: "yüksek verimli" örgütler daha az esnek ve daha az etkili; biraz boşluk olmadan değişim imkansız; "meşguliyet işin yerini alır" [S122, ikinci el]. Kitap 2001-2002, Currency/Crown (arama özeti) [S123].
- Kingman (1961): ortalama bekleme süresi ≈ ρ/(1−ρ) × değişkenlik × hizmet süresi; kullanım ρ 1'e yaklaştıkça bekleme sınırsız büyür; formül özellikle doygunluğa yakın sistemlerde doğru [S124]. Pratisyenlerin eşik önerileri (yaklaşık %75-85 üstü sert artış) bu kaynaklarda kesin değil [S125].
- [SIÇRAMA uyarısı]: Kuyruk kuramı tek sunuculu fabrika hatlarına dayanır; bilgi işçisi için çıkarım analojidir [S125 arama notu]. Oyundaki "bir sprintte ekibi %100 dolu planlamak gecikmeyi artırır" iddiası bu yüzden kanıtlı bir sonuç değil, bir hipotez.
- Kısıt kuramı (Goldratt): darboğaz olmayan kaynağın %100 çalışması fazladan yarı mamul yığar; darboğazı besleyen bir tampon gerekir; "her düğümde kullanımı ölçüp ödüllendirmek aşırı üretimi teşvik eder" (yalnız arama özetleri, Düşük güven) [S129][S130].

#### Uzman/genelci ve T-şekilli ekip
Danışman/blog kaynaklarında (Düşük güven, yalnız arama özeti): uzman, talep olmayan işi üretmeye devam ederse envanter ve risk yığar; saf genelciler karmaşık işte yetersiz kalabilir; T-şekilli kişiler darboğaz kaynaklı beklemeyi azaltır ama yetişmeleri yıllar alır [S127][S128]. Kontrollü bir çalışma bulunamadı (arama kendisi de bunu söylüyor) [BOŞLUK].

#### Brooks yasası (iki kişiyi tek işe koymak)
"Geç kalmış bir yazılım projesine insan eklemek onu daha da geciktirir"; nedenler: yeni kişinin öğrenme yükü ve iletişim yollarının artması; yasa "insan eklemek asla yardımcı olmaz" demiyor [S126, ikincil]. Bölünemeyen işlerde eklenen kişi yardım etmez (arama özetinde örnek) [S126 özeti]. Ölçek: 2 kişilik takımda yük küçük; büyük ölçekte toplam iletişim yolu sayısı artar (sayfa formülü vermiyor) [S126].

#### Kaynak dengeleme (resource leveling)
Aranmadı ve bütçe doldu. [DEĞERLENDİREMEM]. Sicilde kaynak yok.

### 2.5 Ek bakış: Dwarf Fortress otomatik iş dağıtımı (DFHack autolabor)
Bu başlık görev listesinde yok; "otomatik atamanın aptallığı" aramasında çıktığı için kısaca eklendi.
- Kural: Eklenti talebe göre işgücü payını ayarlıyor; her iş için kişiler beceriye göre sıralanıyor, işi yapamayanlar dışlanıyor, ustalar başka işler için geriye atılıyor, en iyiler asgari sayıya kadar atanıyor; boşta olan ve sıfırdan büyük becerisi olanlar ek olarak ekleniyor; "mümkün olduğu kadar çok cüceyi meşgul tut" amaçlı, yine de uzmanlaşmaya izin veriyor [S131]. Bu, senin tarifinin ("en iyiler en zor işe, kalanlar yeten beceriyle, kimse boşta kalmaz") çok yakın bir otomatik karşılığı.
- Sınırlama: Belge "kendi sorumluluğunda kullan" diyor; algoritmaları DF 50 için güncellenmemiş; "cücelerin ne yaptığını ve yapmadığını izlemelisin"; atamaları gösteren yerleşik ekran yok, Dwarf Therapist öneriliyor [S131].
- Resmî çalışma ayrıntıları (work details): "yalnız seçilenler yapsın / herkes yapsın / kimse yapmasın" gibi kipler (yalnız arama özeti) [S132].

---

## 3) Başarısız ve eleştirilen örnekler (ayrı bölüm)

Aranan: mikro yönetim yorgunluğu, angarya, boşta işçi, otomatik atamanın aptallığı, kaldırılan/değiştirilen atama sistemleri.

| # | Ne olmuş | Kaynak | Güven/not |
|---|---|---|---|
| F1 | RimWorld: taşıma önceliği 1 yapılınca koloniciler "verimlilik umursamadan" her şeyi taşıyor | [S101] | wiki, taslak sayfa |
| F2 | RimWorld: tarım yapması gereken kişi hiç ekmediği için koloni açlıktan öldü; öncelik sistemi "çok sinir bozucu" bulundu, oyuncu mikro yönetmek istemedi | [S106] | oyuncu görüşü |
| F3 | RimWorld: 300 saat sonra bile hasadın dörtte üçü çürüyor, tek çare tüm koloninin taşıma önceliğini azamiye çekmek | [S105] | oyuncu görüşü |
| F4 | RimWorld: Work Manager modunda yanlış doktor ataması, iş türü kapatınca durma, "pawn'lara hep hiçbir şey atanıyor, boşta dolaşıyorlar" | [S108] | yalnız arama özeti, doğrulanmadı |
| F5 | ONI: ~100. döngüde yönetim mikro yönetime dönüyor, "ton boşta duplikant", seyahat süreleri | [S110] | oyuncu görüşü |
| F6 | ONI: Proximity ayarı arayüzde gizli, oyuncu bunu yıllardır merak etmiş | [S110] | oyuncu görüşü |
| F7 | ONI: 2018'de roller bir önceki sistemde daha düşük önceliği öne alabiliyordu; sürüm notuna göre sadece aynı öncelik düzeyini sıralıyor olarak değiştirildi; "öncelikleri sonra gözden geçireceğiz" | [S103] | kaldırılan/değişen sistem örneği; değişikliğin gerekçesi yazılı değil |
| F8 | FM: "oyun aşırı karmaşıklıkla bozulmuş", sadece sorumluluklarla da bitmiyor | [S114] | oyuncu görüşü |
| F9 | FM: devir sonrası bile onay uyarıları ve sürpriz kararlar | [S113][S115] | S115 yalnız arama özeti |
| F10 | FM: asistan tavsiyeleri "espri konusu", oyuncu kendi aracını yazmış | [S116] | yalnız arama özeti, sayfa 404 |
| F11 | DF: otomatik dağıtıcı "kendi sorumluluğunda kullan", izlemek zorundasın, atamayı gösteren ekran yok | [S131] | araç belgesi |
| F12 | Kısıt kuramı tuzağı: her istasyonda kullanımı ölçmek aşırı üretimi teşvik eder | [S129] | Düşük, yalnız arama özeti |

Aradım, bulunamadı:
- "<oyun> patch removed manual assignment" türü: RimWorld, ONI, FM için atama sistemini tamamen kaldıran bir yama bulamadım. Tek bulunan değişiklik F7 (ONI 2018).
- RimWorld'de oyun içi "boşta kolonici" uyarısının varlığı ya da yokluğu: kanıt bulamadım.
- FM'de "devretme sistemi kaldırıldı" türü şikâyet: bulunamadı.
- Boşta işçinin ONI'de "morali/stresi" doğrudan düşürdüğüne dair doğrulanmış kaynak: bulunamadı (tek iddia doğrulanamadı, bkz. 2.2).

---

## 4) Üç soruya dersler

### Soru 1: Atamayı kim yapar? (oyuncu / PM'e devir / sistem; ekibe göre değişir mi?)

Kanıt [S#]:
- RimWorld/ONI: sistem varsayılan sırayı verir (soldan sağa, gizli öncelik, yakınlık); oyuncu kişi başına kalıcı politika kurar, iş-iş atamaz. Büyük koloni için ONI'nin kendi wiki'si varsayılanı değiştirmeyi (yakınlık) öneriyor [S101][S102].
- FM: sorumluluğu yetkin personele devretme resmî kural; kalite personelin özniteliğine bağlı [S112]; oyuncu hesap veren kişi olarak kalıyor ve onay uyarıları geliyor [S113].
- Scrum: işi dışarıdan atamak değil, ekibin kendi içinde seçmesi [S117].
- DF autolabor: tam otomatik dağıtıcının da "izlemek zorundasın" ve görünür atama ekranı olmaması sorunu var [S131].
- Küçük ekipte elle yönetim doğal, büyüdükçe uzmanlaşma ve politika gerekiyor (tek oyuncu iletisi) [S105].

Ölçeğe göre kanıt:
- 1 kişi: seçilecek bir şey yok; sıra bile seçmek yeterli.
- 3 kişi: elle uygun [S105]. 6 kişi: elle hâlâ uygun gibi, ama kanıt zayıf [S105].
- 12 kişi: geçiş bölgesi, eşik [DEĞERLENDİREMEM].
- 25 ve 50 kişi: kanıt yok [DEĞERLENDİREMEM]; dolaylı ipucu: ONI büyük kolonide politika (yakınlık) öneriyor [S102].

[GÖRÜŞ]
- Senin ilk düşüncen (orta ekipte elle güzel olabilir) bu kaynaklarla çelişmiyor, ama RimWorld/ONI'de elle yapılan şey kart-kişi eşleştirmesi değil, kişi başına standing order. Kart-kişi eşleştirmesi (senin tarifin) her sprint yeniden yapılacak iş; 50 kişide 2 haftada onlarca kart demektir. Elle atama o ölçekte angarya olur.
- Kesin öneri yok ama öneri yönü: varsayılan olarak sistem senin tarifini uygulayıp tam bir plan önersin; oyuncu planı görsün, kartı tek tuşla bir kişiden diğerine çeksin (ezme). PM'e devir ise "PM'in yıldızı kadar iyi plan" kalitesiyle FM kalıbını izleyebilir; ama bu yeni bir sistem demek, "konuştukça yeni sistem ekleme" kuralınla çatışıyor. Ben PM devrini ilk sürümde eklemezdim; "PM'e bırak" kalitesi planı kuran kuralın PM yıldızına bağlı olması olabilir, bu ancak ilk sürüm oturunca düşünülmeli.
- Ölçek çizgisi: 1-3 kişide plan otomatik kurulsun ve oyuncu neredeyse hiç dokunmasın; 6-12'de oyuncu planı görüp ezsin (en çok keyif burada); 25-50'de ezme yalnızca istisna olsun (yoksa angarya, bkz. F5). Bu, FM'deki "çoğunu devret, bir tanesini elinde tut" (S114) ile uyumlu.

### Soru 2: Boşta kalma ve verim

Kanıt:
- RimWorld ve ONI'de boşta kalma bir ayar hatası ya da oyun sorunu olarak yaşanıyor, oyuncu bunu optimizasyon mekaniği olarak övmüyor [S109][S110]. Hiçbir kaynakta "boşta çalışanı doldurmak keyifli" diyen bir oyuncu yorumu bulamadım [BOŞLUK/bulunamadı].
- Gerçek ekiplerde: kuyruk kuramı doygunluğa yakın kullanımda bekleme süresinin sınırsız büyüdüğünü gösteriyor [S124]; DeMarco boşluk olmadan değişimin imkânsız olduğunu savunuyor [S122]; kısıt kuramı darboğaz olmayan kaynakta boşta zaman beklenmesi gerektiğini söylüyor [S129][S130]. Bunların hepsi bilgi işi için analoji [SIÇRAMA uyarısı].
- Kanban boşta olanı kişi olarak değil "bekleyen iş" olarak gösteriyor [S120].
- DF autolabor'un amacı "mümkün olduğu kadar çok kişiyi meşgul tut" ve ona bile "izle" uyarısı eşlik ediyor [S131].

Ölçeğe göre:
- 1 kişi: boşta kalma anlamsız (tek kişi her zaman bir şey yapar ya da yapacak iş yoktur).
- 3 kişi: boşta kalan biri hemen görünür; açık bir ek iş ya da yardıma gitme çözümü yeterli. Kanıt yok, mantık [GÖRÜŞ].
- 6-12 kişi: kısmi boşta kalma planlama hatasının işareti olabilir. Kanıt yok.
- 25-50 kişi: ONI'de boşta duplikant yığılması ve yönetim yükü bildirildi, ama ölçek belirsiz [S110].

[GÖRÜŞ]
- "Kimse boşta kalmaz" kuralını sistemin kendisi sağlamalı; oyuncu optimizasyonu olmamalı. Oyuncunun işi "ekibi dolu tut" değil "doğru kartları seç" olmalı. Gerekçe: bu iş oyuncuya karşı angarya olur (bkz. F5), kuyruk kuramı ve DeMarco da %100 doluluğu hedef olarak savunmuyor [S122][S124].
- Yeterince karta sahip olmayan bir sprintte boşta kalan kapasiteyi oyuncuya "ücretsiz kapasite" olarak göster; ceza değil bilgi olsun ("bu sprintte X kişilik boş kapasite var, düzeltme kartlarına ya da derinlik kartlarına kayabilir"). Yeni sistem olmadan, mevcut kart türleriyle çözülür.
- PM hazırlığı yetişmezse çalışan boşta mı kalıyor görünsün: evet görünsün, ama sebebi (hazır kart yok) bir cümleyle söylensin; RimWorld'de boşta sorunlarının çoğu "neden" bilinmediği için öfke yarattı [S109]. 
- "Böyle bir mekanik olmalı mı?" sorusuna cevabım: boşta kalma bir ceza ya da skor mekaniği olmasın; yalnız görünür bilgi olsun. Kanıtlı değil, görüş.

### Soru 3: Darboğaz gösterimi

Kanıt:
- Kanban: WIP sınırı aşılan sütun öne çıkar; CFD'de şişen şerit; bölünmüş sütunlar "bekleyen iş sayısını" gösterir [S120][S121].
- Scrum: kapasite ve plan karşılaştırması sprint planlamasında yapılır (toplam kapasite karşısına çekilen iş) [S117][S118]. 
- Oyunlar: RimWorld/ONI'de yerleşik darboğaz uyarısı bulunamadı; oyuncu işi çürüyen ürün ya da uzun yürüme süresi gibi dolaylı belirtilerden anlıyor [S105][S110][S111]. DF'de atamaları gösteren ekran bile yok [S131].

Ölçeğe göre:
- 1 kişi: darboğaz kişinin kendisi; "tek kişi hem tasarım hem geliştirme" sırası zaten sıralı iş. 
- 3, 6 kişi: darboğaz çoğunlukla tek bir aşamada (örneğin tek test elemanı) görünür; plan ekranında "Test aşamasında kapasite X, talep Y" tek satır yeter. Kanıt yok, [GÖRÜŞ].
- 12 kişi: aşamalar arası denge önemli.
- 25, 50 kişi: aşama başına kapasite ve talep toplamı ve PM hazırlık hattı için ayrı satır gerekir; elle kontrol imkânsız. Kanıt yok.

[GÖRÜŞ]
- Gösterim planın kendi sayılarından türetilebilir: her aşama (Tasarım, Geliştirme, Test) ve PM hazırlığı için "talep / kapasite" iki sayı; talep kapasiteyi aşan aşama kırmızı ve tek cümle ("Test aşaması 6 birimlik fazla yük taşıyor"). Yeni sistem değil, planın okunması. Kanban'ın "şişen sütun" fikriyle aynı [S120].
- Uyarı yalnız plan zayıfken çıksın, her zaman değil (RimWorld/FM'de çok uyarı bıkkınlık yaratıyor, bkz. FM onay uyarıları [S113]); ayrıca uyarı sayısı büyük ekipte tek satıra toplanmalı.
- Brooks uyarısı: "tek kişinin yetmediği işe iki kişi" kuralı, kart bölünebilir değilse işe yaramayabilir [S126]. Kartın bölünebilirliği (örneğin K3 mi, derinlik kartı mı) planlanmalı; bu kanıt değil, tasarım sorusu.

### Bonus: Erdem'in tarifine karşı uyarı listesi (GÖRÜŞ)
1. "Yeten en düşük beceri": uzmanı korumak [S127][S128] tarafında mantıklı, ama oyuncu "neden bu kişi?" sorusuna cevap bulamazsa gizli mantık şikâyeti doğar. Atama yanında tek cümle gerekçe.
2. "Kart bitene kadar kalır": RimWorld'deki doğrudan atama yan etkisine benziyor (kişi yemeyi/dinlenmeyi unutuyor) [S106]. Oyundaki karşılığı: uzun kartta kişinin başka bir şeye çekilememesi; ekibe bu istisna sınırı yazılmalı.
3. "Kimse boşta kalmaz": sistem sağlarsa iyi; oyuncuya yüklenirse angarya (F5).

---

## 5) Bulunamayanlar

- RimWorld'de oyun içi "boşta kolonici" uyarısı: bulunamadı [DEĞERLENDİREMEM].
- ONI'de boşta duplikantın stresi doğrudan artırdığına dair doğrulanmış kaynak: bulunamadı.
- FM'de atama/devretme sisteminin kaldırılması ya da yenilenmesi: bulunamadı.
- Kaynak dengeleme (resource leveling, PMBOK, kritik zincir): aranmadı, bütçe doldu.
- Kanban Rehberi (Scrum.org/Kanban Guide) birinci elden WIP ve darboğaz tanımı: ilk arama bulamadı, Scrum.org kapasite sayfası boş döndü (S-yok).
- Uzman kapasitesinin sprint planlamasında ağırlıklandırılması: arama sonuçlarında yöntem yok [BOŞLUK].
- Uzman/genelci ekip için kontrollü, hakemli çalışma: bulunamadı.
- RimWorld ve ONI'de 25 ve 50 kişilik koloniler için nicel davranış verisi: bulunamadı.
- Work Manager modunun resmî açıklaması ve sürüm notu: sayfa HTTP 429 verdi, okunamadı.

---

## 6) Arama günlüğü

Arama: 18 / 18 (bütçe doldu). Sayfa okuma: 25 / 25 (bütçe doldu; 4 başarısız: kleiforums 403, FM node/673 404, VideoGamer 404, Scrum.org boş, Steam Atölye 2 kez 429; bunlar sayıya dahil).

Aramalar:
1. RimWorld work tab priorities manual priorities wiki
2. Oxygen Not Included priorities screen duplicant job priority wiki idle duplicant
3. RimWorld micromanagement large colony work priorities tedious reddit
4. RimWorld Work Tab mod Fluffy features priorities per colonist overview
5. RimWorld colonist idle doing nothing wandering standing around why not working
6. ONI duplicants idle standing around nothing to do priorities micromanagement big colony complaint
7. Football Manager staff responsibilities delegate to assistant manager coaches training scouting
8. Football Manager delegation assistant manager bad decisions micromanagement too much admin complaint
9. Football Manager too much admin delegate everything game feels like spreadsheet
10. Scrum sprint capacity planning individual capacity skills specialists
11. Kanban WIP limits bottleneck visibility cumulative flow diagram
12. Tom DeMarco Slack busy-ness efficiency utilization queueing
13. specialists vs generalists software team bottleneck T-shaped skills trade-off
14. queueing theory utilization wait time nonlinear Kingman formula
15. Brooks's law adding manpower to a late software project
16. Dwarf Fortress labor management tedious Dwarf Therapist work details
17. Theory of Constraints Goldratt bottleneck non-bottleneck resources idle capacity
18. RimWorld Work Manager auto assign priorities mod problems colonists wrong job

Sayfa okumaları (özet): RimWorld Wiki Work; ONI Priority, Versions/OC-253538, Skills; Steam RimWorld (3279191623106894422, 2381701715727097818); kleiforums (2 deneme, başarısız); Steam ONI (5051317596394504333, 592884947430211421); FM Dugout FM26; FM node/673 (404); Steam FM24 (5715692378857437753, 3957035999324108595); VideoGamer (404); Scrum Guide; Scrum.org node 96826 (boş); Len Holgate blog; Kingman Vikipedi; Laws of Software Engineering Brooks; Microsoft Learn Kanban; DFHack autolabor (yönlendirme + açıldı); Steam Atölye Work Manager (2 deneme, 429).

Boş / başarısız aramalar: yok (hepsi sonuç döndürdü; ama sonuçların büyük kısmı özet).

---

## 7) Şüpheci doğrulama

Yük taşıyan 8 iddia ve durumu:

| # | İddia | Dayanak | Durum |
|---|---|---|---|
| V1 | RimWorld: 1-4 öncelik, eşitlikte soldaki önce, yüksek öncelik bitmeden alt öncelik başlamaz | S101 sayfa metni (açıldı) | Doğrulandı (sayfa taslak işaretli) |
| V2 | ONI: kişi başı kategori önceliği, alt öncelik 1-9, "gizli öncelikler küçük, yakınlık büyük koloni için" | S102 sayfa metni (açıldı) | Doğrulandı |
| V3 | ONI: öncelikler 1-9, roller yalnız aynı düzey içinde sıralıyor, 2018-02-01 | S103 (açıldı) | Doğrulandı |
| V4 | FM: devir kalitesi personel özniteliğine bağlı, devir listesi | S112 (açıldı) | Doğrulandı; "asistan bağımsız mı karar verir" sorusunu sayfa cevaplamıyor |
| V5 | FM: devredilince bile onay uyarısı, sorumluluk oyuncuda | S113 (açıldı) | Doğrulandı (oyuncu yorumu) |
| V6 | Scrum: ekip kim neyi yapacağına kendisi karar verir, dışarıdan atanmaz | S117 (açıldı) | Doğrulandı |
| V7 | Kingman: ρ/(1−ρ) terimi, doygunlukta bekleme sınırsız artar | S124 (açıldı) | Doğrulandı; "sınırsız" ifadesi formülden türetme, sayfa doğrudan söylemiyor |
| V8 | DF autolabor: mümkün olduğunca çok kişiyi meşgul tut; izlemek zorundasın, atama ekranı yok | S131 (açıldı) | Doğrulandı |

Çözülemeyen uyarılar (rapordaki zayıf noktalar):
- Sayfa okuma bütçesi dolduğu için doğrulama, ikinci kez açma yerine "doğrudan okunmuş mu / yalnız arama özeti mi" ayrımıyla yapıldı.
- S107, S108, S109, S115, S116, S118, S119, S121, S123, S125, S127-S130, S132 yalnız arama özeti; bunlara dayanan cümleler zayıf kabul edilmeli ve raporda ayrı işaretli. Kritik kararları bunlara dayandırma.
- ONI'de "büyük kazı bitince boşta kalan duplikantlar" iddiası ilgili bağlantıyla eşleşmedi, doğrulanamadı.
- DeMarco'nun kendi sözleri okunmadı; ikinci el özet [S122].
- 25 ve 50 kişi için hiçbir oyun/gerçek ekip kaynağında doğrudan veri yok; bu ölçekteki tüm öneriler [GÖRÜŞ].
