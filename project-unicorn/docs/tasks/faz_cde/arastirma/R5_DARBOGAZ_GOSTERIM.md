# R5 — Sprintte darboğazı oyuncuya göstermek

Tarih: 2026-10-17. Yöntem notu: 8 WebSearch bütçesi tamamen kullanıldı. Fandom (402), wiki.gg (401/404), Reddit ve web.archive.org araçtan engelli çıktığı için Software Inc., Startup Company, Two Point Hospital, Satisfactory, Big Ambitions, Anno ve Project Hospital wiki sayfaları OKUNAMADI. Bu oyunlar için Steam tartışmaları, Steam rehberleri ve Steam yama notları okundu. Kaynağı olmayan her bilgi "(kaynaksiz, model bilgisi)" ile işaretlidir. Ekran görüntüsü adresleri sayfaların göreli yollarından türetilmiştir; tarayıcıda açılıp doğrulanmamıştır.

---

## 1. Özet

1. Azure DevOps, kapasiteyi "kişi başına günlük saat × sprint günü − izin günü" olarak kurar ve bunu kalan işle kişi başına ve takım başına çubukla karşılaştırır. Asama (Activity) alanı kişiye atanır; yani "Test kapasitesi" testçilerin kapasitelerinin toplamıdır. Aşım ayrı bir "kapasite aşıldı" göstergesiyle çizilir (https://learn.microsoft.com/en-us/azure/devops/boards/sprints/set-capacity?view=azure-devops).
2. Sahibin cümlesine en yakın gerçek örnek Startup Company: Beta 22 yama notunda üretim darboğazı için "bottleneck alert" eklendi; amacı oyuncuya "neyi artırırsam üretim artar" sorusunu cevaplatmak (https://store.steampowered.com/news/posts/?appids=606800&appgroupname=Startup+Company&enddate=1559490911).
3. Linear kapasiteyi sabit sayıdan değil, son 3 tamamlanan döngünün hızından (velocity) türetir; geçmiş yoksa takım üye sayısından kabaca tahmin eder (https://linear.app/docs/use-cycles). Ölçekte sabit sayı sorununa karşı en temiz yaklaşım budur.
4. Software Inc.'in tahmini bitiş süresi "işçiler %100 verimle, mola vermeden çalışır" varsayımıyla hesaplanır; oyuncular bu yüzden tahminin tutmadığını söyler (https://steamcommunity.com/app/362620/discussions/0/358417008728912137). Tahmin = sonuç istiyorsak varsayımları da göstermeliyiz.
5. Oyuncular darboğazı çoğu oyunda ekranın söylediğinden değil, kuyruk uzunluğundan ve boş duran kişiden bulur (Two Point Hospital: https://steamcommunity.com/app/535930/discussions/0/1742220359690056713). Sadece rapor yetmez; "nerede birikiyor" görünmeli.
6. Aşırı eleman almak çözüm değildir: Software Inc.'te önerilen takım boyutu 12 iken 18 kişi hızlandırmadı (https://steamcommunity.com/app/362620/discussions/0/365163686064884721/). Bizde "testçi ekle" cevabı yıldız ve rol bazlı çalışmalı, yoksa kafa karışır.
7. Azure DevOps'un hata tavanı (bug cap) kişi başına 3 hata gibi kişi sayısıyla ölçeklenir: 10 kişi → 30 hata (https://learn.microsoft.com/en-us/azure/devops/boards/sprints/best-practices-scrum?view=azure-devops). Bizim açık hata sayacına ölçek-güvenli bir model.
8. Önerim: "aşama × beceri kapasite şeridi" (Azure DevOps) + tek cümlelik darboğaz uyarısı (Startup Company) + kapasite kadranı (Linear) birlikte. Gantt biçimi referanssızdır.

---

## 2. Mekanik döküm

### 2.1 Azure DevOps — aktivite başına kapasite

- Kapasite "gerçek iş süresine" karşılık gelir; saat ya da gün olarak girilir; tatil, izin ve çalışılmayan günler hesaba katılır. Her sprint için ayrı girilir (https://learn.microsoft.com/en-us/azure/devops/boards/sprints/set-capacity?view=azure-devops).
- Kişi başına: "Capacity per day" (örn. 6 saat/gün tasarım için) ve bir Activity/Discipline değeri. Bir kişi birden fazla aktiviteye bölünebilir (örnek: Jamal Deployment ve Development arasında). Aynı sayfa.
- Hesap: sayfa formül vermiyor, ama "günlük kapasite × sprint iş günü − izin günü" olduğu çıkarılır (sayfadan türetilmiş, açık formül yok). Takım günleri izin olarak girilirse hepsine yansır.
- "Capacity bars track the remaining work against the capacity for each team member and the entire team." Yani çubuk = kalan iş / kapasite. Aynı sayfa.
- Önceki sprintten kopyalama: yalnız günlük kapasite ve aktivite kopyalanır, izinler kopyalanmaz.
- "Add all team members" en çok 100 kişi getirir (aynı sayfa): ölçek sınırı.
- Aşım nasıl çizilir: Azure DevOps "Adjust work" sayfasında "over capacity indicators" ekran görüntüsü var; metin renk söylemiyor (https://learn.microsoft.com/en-us/azure/devops/boards/sprints/adjust-work?view=azure-devops). Kırmızı aşım göstergesi (kaynaksiz, model bilgisi).
- Aşım çözümü: işi sprintten at, ya da görevi başka kişinin kapasite çubuğuna sürükle; çubuklar anında güncellenir (aynı sayfa).
- Aktivite (Development/Testing/Design) bazında takım toplamı çubuğu: sayfada yalnız kişi başına aktivite atamasından bahsediliyor; "takım toplamı aktivite çubuğunun" ayrıca çizildiğini bu sayfadan doğrulayamadım. Sağ panelde aktivite grafiği olduğunu biliyorum (kaynaksiz, model bilgisi).
- Önerilen pratik: görevi 1 gün ya da daha kısa tut; belirsizlik küçük görevle azalır (set-capacity sayfası).
- Hız (velocity) ayrı kavram: "Velocity is always counted in the sprint when work is completed" ve ortalama hız gelecekteki kapasite için kullanılır (örnek: 25, 30, 28 puan → ortalama 28) (https://learn.microsoft.com/en-us/azure/devops/report/dashboards/team-velocity?view=azure-devops). Varsayılan 6 sprint, en çok 15.

### 2.2 Jira / Advanced Roadmaps (Plans)

- Capacity report: sprint başına free capacity, planned capacity, capacity usage; takım ya da üye süzgeci (https://confluence.atlassian.com/display/advancedroadmapsserver0327/Capacity+report).
- Beceriye (skill) göre kapasite karşılaştırması: bulunamadı. Yalnız bir üçüncü taraf yazı "Design Capacity (hours)" gibi özel alanı öneriyor; Plans'ın bunu okuduğu belirtilmiyor (https://www.resolution.de/post/jira-capacity-planning/).
- Atlassian topluluk gönderisi: bireysel kapasite planlamasının Premium/Enterprise'da olduğu, haftalık sabit 40 saat ve üst düzey tahsisle çalıştığı söyleniyor; resmi belge değil (arama sonucu özeti: https://community.atlassian.com/forums/Jira-questions/Capacity-by-team-member/qaa-p/3263438). Bu "sabit 40 saat" ölçekte bizim endişemizin canlı örneği: sayı kişiye bakmadan sabit.
- Atlassian'ın resmi destek sayfaları (what-is-capacity, view-and-manage-capacity) 404 verdi.

### 2.3 Linear — döngü kapasitesi

- Başlamamış döngüde "capacity dial": takımın döngüye eklenen işleri bitirip bitiremeyeceğini tahmin eder. Kapasite, önceki 3 tamamlanan döngünün hızı (issue sayısı ya da puan). Hiç döngü yoksa "takımdaki üye sayısından kabaca tahmin" (https://linear.app/docs/use-cycles).
- Tamamlanan döngünün grafiği ve istatistiği tamamlanma anında anlık görüntü olarak saklanır; sonradan iş taşınsa bile eski grafik değişmez. Aynı sayfa.
- Döngü grafiği: gri çizgi toplam kapsam; mavi noktalı çizgi hedef (toplam puan kalan günlere eşit dağıtılır, hafta sonu düzleşir); sarı çizgi başlamış işler; düz mavi çizgi biten işler; mavi çubuklar bitişleri gösterir. İlerleme çizgisi hedefin üstündeyse yolundasın (https://linear.app/docs/cycle-graph). Ayrı bir "tahmin çizgisi" yok.

### 2.4 ClickUp / Monday iş yükü görünümü

- ClickUp Workload ve Monday Workload yardım sayfaları 403 verdi; mekanik ayrıntı okunamadı. Bulunamadı.

### 2.5 Kanban WIP sınırı ve darboğaz

- Her adımın tutabileceği iş sayısı sınırlıdır; sınıra gelince yeni iş giremez ve tıkanıklık tahtada görünür, bir önceki adımdaki kişiler yardıma çağrılır (https://en.wikipedia.org/wiki/Kanban_(development)). Renk ayrıntısı sayfada yok.
- Atlassian'ın kümülatif akış diyagramı ve WIP sayfaları 404 verdi; bantların genişlemesi darboğazı gösterir (kaynaksiz, model bilgisi).

### 2.6 Software Inc.

- Tasarım belgesinde "önerilen takım sayısı" vardır; geliştirici: "The estimated team number is how many should be working on it at any one time" (https://steamcommunity.com/app/362620/discussions/0/530649887200832574).
- Geliştirici önerisi: iş başına bir takım; istisna geliştirme, orada sanatçı ve programcı aynı takımda (aynı kaynak). Aynı iş için birden fazla takım "ilerideki bir güncelleme" diye anılmış (eski, 2016-17).
- Tahmini bitiş süresi "işçilerin %100 verimle çalıştığı" ilkesinden hesaplanır; mola, stres, uyumluluk uzatır (oyuncu kuramı, doğrulanmamış): https://steamcommunity.com/app/362620/discussions/0/358417008728912137.
- Proje ekranındaki daire grafik gerçek iş dağılımını gösterir; erken tasarım sanatçı, sonra programcı ister (aynı kaynak). Tasarım belgesinde ayrıca projenin istediği uzmanlık dairesi var (https://steamcommunity.com/app/362620/discussions/0/365163686064884721/).
- Aşırı kadro: önerilen 12 iken 18 kişi hızlandırmadı (aynı kaynak). Ek takım, bir çalışan kadar sayılır, yani (takım1 + takım2) + (takımSayısı − 1) kabaca (oyuncu hesabı, doğrulanmamış).
- Bir rehberde: tasarım/geliştirme önerilen boyutta, pazarlama/destek serbestçe ölçeklenir; tasarım ve geliştirmede önerilen kadrodan fazlası kaliteyi düşürür (arama özeti: https://steamcommunity.com/sharedfiles/filedetails/?id=1198857114 ve ilgili tartışmalar).
- Süre ayarı: oyuncular bitmiş kalite için geliştirme süresini %110–120 yapmayı gerekli buluyor, başka bir rehber oyun ve işletim sistemi için %300 kullanıyor (https://steamcommunity.com/app/362620/discussions/0/2119355556482487720/ ve https://steamcommunity.com/sharedfiles/filedetails/?id=2349892329). Yani "tahmin" ile "kaliteyi tutturan gerçek süre" ayrı.
- Boyut: 10–12 kişilik takım önerilir; 3 takım × 10 kişi 30 kişilik proje için "büyük sorun değil" (rehber, Alpha dönemi; https://steamcommunity.com/sharedfiles/filedetails/?id=1198857114). 80 kişiden az ile tüm oyun türleri üretilebilir (oyuncu iddiası: https://steamcommunity.com/app/362620/discussions/0/5829413623767242744/).
- Destek: normal bir destek takımına 10–15 görev atamak olağan (https://steamcommunity.com/app/362620/discussions/0/4303823318963259112/).

### 2.7 Startup Company

- Roller: geliştirici temel bileşen, lider geliştirici bunları modüle birleştirir (1 tasarımcı bileşeni + 1 geliştirici bileşeni), tasarımcı ayrı tür bileşen üretir; yönetici hız bonusu verir (arama özeti, doğrudan sayfa okunamadı: https://steamcommunity.com/app/606800/discussions/0/1736589519997369074/).
- Oran hesabı: topluluk hesaplayıcısı her bileşenin rol saatlerini toplar ve oranı çıkarır. Örnek: Landing Page yükseltmesi tasarımcı 6 saat + geliştirici 6 saat → 1:1 (https://steamcommunity.com/app/606800/discussions/0/1777136225034602644/). Bileşen saatleri: BlueprintComponent tasarımcı 2s, GraphicsComponent tasarımcı 4s, BackendComponent geliştirici 4s, UiComponent geliştirici 2s.
- Beta 22 (15 Mart 2019): "Improved hosting stats" içinde "A 'bottleneck alert' has also been added to make it easier to understand what to increase in order to increase produced CU." Ayrıca üretim kuyruğu tek "Infinite Repeating Queue" oldu, boyutu 10, geliştirilmekte olan bileşen mavi arka planla işaretli (https://store.steampowered.com/news/posts/?appids=606800&appgroupname=Startup+Company&enddate=1559490911).
- "Üretim planı" (production plan) şikâyeti: yönetici planı körü körüne izler, çalışan "missing requirements" ile takılır; geliştirici çözüm olarak temel bileşenlere modüllerden yüksek asgari stok vermeyi önerdi; oyuncu iç içe bağımlılıkta çalışanların günlerce boşta kaldığını yazdı (https://steamcommunity.com/app/606800/discussions/0/2913220877917005713/). Ders: uyarı "ne eksik" demeli, yoksa boş çalışan sorunu çıkar.
- Bir pencere "stokta var" derken çalışan "eksik" diye bekliyor: iki ekranın tutarsızlığı şikâyeti (https://steamcommunity.com/app/606800/discussions/0/1736589519997369074/, Aceman_1984, 10 Haz 2020). Bizim için: plan ekranı ile gerçek sonuç aynı sayıdan beslenmeli.

### 2.8 Factorio

- Üretim istatistiği: Items/Fluids sekmeleri, her ürün için üretilen ve tüketilen; zaman ölçeği 5 saniyeden tüm zamana; kısa ölçek az örnek yüzünden yanlış olabilir; ürün süzgeci (demir/bakır çok yer kaplar) (https://wiki.factorio.com/Production_statistics). Sayfa darboğaz analizi anlatmaz; "üretilen > tüketilen birikir" yorumu sayfada yok, benim çıkarımım.
- Uyarılar: ikon doğrudan varlığın üstünde durur ve durum değişene kadar kalır; alarm (alert) ise ekranda sağ üstte, kısa süreli (5–30 sn), tıklanınca ilgili yere götürür; tür bazında kapatılabilir (https://wiki.factorio.com/Alerts). Eksik cephane, yakıt, sıvı, düşük güç, tükenen maden, dolu depo gibi durumlar ikonla gösterilir.

### 2.9 Two Point Hospital

- Oyuncular darboğazı oda önündeki kuyruk uzunluğundan, hastaların teşhis çubuğundan ve kadrosuz odalardan bulur; "kuyruk 15" gibi okuma; kuyruk nerede birikiyorsa orada oda/personel artırılır (https://steamcommunity.com/app/535930/discussions/0/1742220359690056713).
- Başka tartışmalar: kuyruk gördüğün odada daha çok oda ve personel; önceden işe alma önerilmiyor; "bu darboğazı bulmak için sayfa"lar finans ve hastalık sekmeleri (arama özeti: https://steamcommunity.com/app/535930/discussions/0/2590022385668749214 ve ilgili başlıklar; sayfalar tek tek okunmadı).
- Kuyruk tutarlılığına göre sayı: 100 hastaya 6–7 GP odası ve 8–9 GP bir başlangıç noktası; harita bağımlı (oyuncu görüşü, arama özeti).

### 2.10 Football Manager

- Kadro Planlayıcı (Squad Planner): mevcut taktiğin formasyon grafiği; her rol için en çok 3 oyuncu, Yardımcı Antrenör'ün derecelendirmesiyle sıralı; bu sezon, gelecek sezon ve ondan sonraki sezon için ayrı planlayıcı; derinlik eksikliği görsel olarak anlaşılır (https://www.fmscout.com/a-fm23-squad-planner.html). Sayısal derinlik çubuğu ya da özel "eksik pozisyon" uyarısı sayfada tarif edilmiyor.
- Deneyim Matrisi: Important / Squad Depth / Youth renk kodu (aynı kaynak; renkler belirtilmemiş).

### 2.11 Oyun dışı: tahmin ve belirsizlik

- Basecamp Hill Chart: iş iki aşamadır; sol yokuş "nasıl yapılacağını çözüyoruz", tepe "bilinmeyen kalmadı", sağ yokuş "uygulama". Noktaları kişiler elle yerleştirir; hesaplanan ölçü değil (https://basecamp.com/hill-charts). Belirsizliği göstermenin yolu bu.
- Azure DevOps hız grafiği "Planned" (günün sonunda atananlar) ile "Completed / Completed Late / Incomplete" yan yana verir; yani plan-sonuç farkı her sprint görünür (team-velocity sayfası).
- Dawn of Man: iş yükü = bekleyen görevlerin toplam insana oranı; %100 insanlar 24 saat meşgul demek; yaklaşık %70'te bile gecikme çıkabilir; yol uzunluğu iş yükünü artırır; aşırı yük verimi düşürür (https://steamcommunity.com/sharedfiles/filedetails/?id=2246881517). Tek sayılık bir "yük yüzdesi" ve eşik örneği.

---

## 3. Oyuncuya gösterim

| Kaynak | Ekran | Ekran görüntüsü |
|---|---|---|
| Azure DevOps kapasite çubukları ve aşım | Kişi başına ve takım başına kalan iş / kapasite çubuğu | https://learn.microsoft.com/en-us/azure/devops/boards/sprints/media/ic795969.png (aşım göstergeleri), https://learn.microsoft.com/en-us/azure/devops/boards/sprints/media/capacity/work-details.png, https://learn.microsoft.com/en-us/azure/devops/boards/sprints/media/capacity/add-activity-to-capacity-planning.png, https://learn.microsoft.com/en-us/azure/devops/boards/sprints/media/adjust-work/load-balance-work.png (göreli yollardan türetildi) |
| Linear döngü grafiği | Kapsam (gri), hedef (mavi noktalı), başlayan (sarı), biten (mavi) | https://webassets.linear.app/images/ornj730p/production/d9c776ab4f3b38a56b22df4974c8719edc5557fb-1052x584.png?q=95&auto=format&dpr=2 |
| Linear kapasite kadranı | Başlamamış döngüde kadran | Görsel bulunamadı |
| Jira kapasite raporu | Sprint başına serbest / planlı kapasite | https://confluence.atlassian.com/advancedroadmapsserver0327/files/1003524795/1003524796/1/1587705019592/capacity-report.png (alan adı varsayıldı) |
| Startup Company barındırma istatistiği ve darboğaz uyarısı | Ekranın altında istatistik şeridi | https://steamcdn-a.akamaihd.net/steamcommunity/public/images/clans/28693489/319d5ec1aa1384f404b0d4495515939431dbf267.jpg |
| Startup Company üretim kuyruğu | Kuyruk, aktif bileşen mavi | https://steamcdn-a.akamaihd.net/steamcommunity/public/images/clans/28693489/47c402100580e0903bfa6b80a24adcce584e0ee3.gif |
| Software Inc. takım ve beceri | Mağaza görseli | https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/362620/extras/64403df9471c5737ed9c873ad8280afc.avif?t=1763102408 |
| Factorio üretim penceresi | Üretim / tüketim grafiği | https://wiki.factorio.com/images/thumb/Production_Window.png/300px-Production_Window.png |
| Factorio uyarı ikonları | Yakıt, güç, cephane vb. | https://wiki.factorio.com/images/Fuel-icon-red.png, https://wiki.factorio.com/images/Electricity-icon-red.png, https://wiki.factorio.com/images/Ammo-icon-red.png |
| Football Manager Kadro Planlayıcı | Formasyon + rol başına 3 oyuncu | https://www.fmscout.com/datas/users/014-squad-planner-depth_1.png, https://www.fmscout.com/datas/users/016-squad-planner-current-season_1.png |
| Basecamp Hill Chart | Tepe grafiği | https://basecamp.com/assets/images/hill-charts/hill-chart-hero.gif, https://basecamp.com/assets/images/hill-charts/uncertainty-certainty.svg |

Software Inc. proje ekranı, Two Point Hospital kuyruk ekranı, Satisfactory, Shapez, Anno, Project Hospital, Big Ambitions: ekran görüntüsü adresi bulunamadı (wiki erişimi kapalı).

---

## 4. Ölçek ve sorunlar

- Sabit sayı kırılması: Jira'da bireysel kapasite sabit 40 saatlik haftaya dayanır (topluluk gönderisi, resmi değil; https://community.atlassian.com/forums/Jira-questions/Capacity-by-team-member/qaa-p/3263438). Azure DevOps kapasiteyi kişi başına girdirir, yani doğrusal ölçeklenir ama 100 kişiden sonra otomatik ekleme yok. Linear kapasiteyi hızdan türetir, böylece takım büyüyünce kendini ayarlar ancak ilk sprintlerde üye sayısıyla kaba tahmin yapar.
- Aşırı kadro doymaya götürür: Software Inc.'te 12 yerine 18 kişi hızlandırmadı; ek takım koordinasyon yükü ekler (oyuncu hesabı).
- Software Inc. oyuncu şikâyetleri: tasarım belgesi kafa karıştırıcı, ETA'nın tasarım mı geliştirme mi olduğu belirsiz (https://steamcommunity.com/app/362620/discussions/0/530649887200832574); proje süreleri "sonsuz" (https://steamcommunity.com/app/362620/discussions/0/358417008728912137); takım düzeni zor, "I have no idea how it works" (https://steamcommunity.com/app/362620/discussions/0/2119355556482487720/). Çıkarım: tahmin ekranı tek bir sayı verirse ve varsayımı gizlerse güven kaybolur.
- Startup Company: bağımlılık zinciri derinleştikçe çalışanlar boş bekliyor; "missing requirements" (https://steamcommunity.com/app/606800/discussions/0/2913220877917005713/). Yama sonrası bile geliştirici "geliştirme sona erdi" dedi, yani çözülmedi.
- Startup Company'de büyük kadro oranı örnekleri (112 geliştirici, 116 lider, 230 tasarımcı) yalnızca arama özetinde geçti; okunan sayfalarda doğrulanamadı, güvenmeyin.
- Azure DevOps: kapasiteyi aşan işi sprintten çıkarmak ve görevi başka kişinin çubuğuna sürüklemek ana dengeleme hamlesi; "Sprint review'da hedef tutturuldu mu en önemli soru, kaç hikâye bittiği ikinci" (best-practices-scrum sayfası). Yani plan başarısı sayıyla değil hedefle ölçülüyor.
- Hata biriktirme tavanı: kişi başına 3 hata; 10 kişide 30; aşılınca yeni özellik durur (best-practices-scrum sayfası). Ölçeğe duyarlı kural örneği.
- Kuyruk görünürlüğü: Two Point Hospital'de oyuncular darboğazı ilk önce görmek için sistem dışı yöntemlere (finans/hastalık sekmeleri, tek tek hasta) başvuruyor; yani yerleşik bir "darboğaz bu" göstergesi yoktu ya da yetersizdi (oyuncu iddiası, sürüm farkı olabilir).
- İstismar: bu çalışmada Software Inc. / Startup Company için kaynaklı istismar bulgusu okunamadı. "Takımı tek rolle sınırla, lider mikro yönetsin" stratejisi (Software Inc. oyuncu önerisi: https://steamcommunity.com/app/362620/discussions/0/2119355556482487720/) bir optimizasyon örneği.

---

## 5. Bizim için

Alınacak:
1. Aşama × beceri şeridi (Azure DevOps): Tasarım, Geliştirme, Test için ayrı çubuk; kalan iş ile o aşamayı yapabilen kişilerin yıldız ağırlıklı kapasitesi. Gerekçe: sahibin "testçi yok" cümlesinin doğrudan cevabı; kişi toplamı kişi sayısıyla kendiliğinden ölçeklenir.
2. Darboğaz cümlesi (Startup Company "bottleneck alert"): "Test aşaması yetişmiyor: 3 kart testte bekler, 1 testçi var." Gerekçe: oyuncuya neyi artıracağını söyler.
3. Kapasiteyi hızdan türet (Linear): son 3 sprintin gerçek çıktısı, geçmiş yoksa ekip kişi ve yıldız sayısından kaba tahmin. Gerekçe: "çalışan başına %5" türü sabitleri önler.
4. Kişi sayısıyla ölçeklenen kural (Azure DevOps hata tavanı): hata sınırı "kişi başına N" biçiminde, ama N rolün yıldız ağırlıklı kapasitesinden gelsin.

Uyarlanacak:
- Plan ekranı çubukları "kalan iş / kapasite" yüzdesi olmalı (0–100+), böylece 3 testçili ve 30 testçili şirket aynı ekranı okur. Dawn of Man'ın tek yük yüzdesi ve ~%70 gecikme eşiği buna benzer bir kural örneği; eşik değerini kendi dengemizde belirleriz (sayı almıyoruz).
- Tahmin sonuç ilişkisi: Software Inc. varsayımı gizleyince tahmin tutmuyor. Bizde ekran, sonucu belirleyen aynı hesaptan beslenmeli ve varsayımları (ör. izinli kişi, açık hata yükü) satır olarak göstermeli.

Alınmayacak:
- Jira'nın sabit 40 saatlik bireysel haftası: ölçekte kırılır.
- Basecamp'in elle yerleştirilen tepe noktaları: bizde sistem hesaplar; oyuncu elle belirsizlik girmez. Yine de belirsizliği "tahmin aralığı" olarak göstermek için fikir olarak kalır.
- Startup Company'nin üretim planı ve yönetici davranışı: bağımlılık zincirinde takılmayı göstermeyen planı oyuncular beğenmedi.

---

## 6. Bulunamayanlar

- Software Inc., Startup Company, Two Point Hospital, Project Hospital, Big Ambitions, Anno, Satisfactory, Shapez wiki sayfaları: fandom (402), wiki.gg (401/404), Reddit ve web.archive.org araçtan engelli; yalnız Steam tartışma ve rehberleri okundu.
- Software Inc. ilerleme çubuğunun biçimi ve rengi, takım iş yükünün ekranı: bulunamadı.
- Satisfactory, Shapez, Anno üretim istatistiği ve darboğaz ekranları: bulunamadı.
- Big Ambitions personel darboğazı: bulunamadı. Project Hospital: arama hiç sonuç vermedi.
- Football Manager "eksik pozisyon" uyarısı: bulunamadı; yalnız Kadro Planlayıcı tarifi var.
- Jira Plans'ta beceri (skill) bazlı kapasite ve aşım rengi: bulunamadı; Atlassian resmi yardım sayfaları 404.
- ClickUp ve Monday iş yükü görünümleri: 403.
- Linear kapasite kadranı ekran görüntüsü: bulunamadı.
- Azure DevOps takım düzeyinde aktivite başına toplam çubuk, aşım rengi ve forecast sayfası: metinle doğrulanamadı (forecast sayfası 404).
- Atlassian CFD ve WIP sayfaları (404): kümülatif akış diyagramı okunamadı.
- Startup Company "bottleneck alert"in tam ekranı ve eşiği: yalnız yama notu cümlesi ve bir ekran görüntüsü adresi bulundu.
- Tahmin = sonuç olan oyun örnekleri (Into the Breach'in düşman niyetleri, Slay the Spire niyet ikonları, Kerbal manevra düğümü): okunmadı; yalnız model bilgisi, kaynaksız.
- Oyuncu istismarı bulgusu: bu konuda doğrudan kaynak bulunamadı.

---

## 7. Gösterim yönleri (bizim plan ekranı için)

**Yön A — Aşama × beceri kapasite şeridi.** Planın üstünde Tasarım / Geliştirme / Test için üç yatay çubuk; dolgu = kalan iş / yıldız ağırlıklı kapasite, %100'ü geçen kısım ayrı renkte taşar ve adını yazar ("Test %140"). Referans: Azure DevOps kapasite çubukları (ekran görüntüsü: https://learn.microsoft.com/en-us/azure/devops/boards/sprints/media/ic795969.png; ek: https://learn.microsoft.com/en-us/azure/devops/boards/sprints/media/capacity/work-details.png). Güçlü: sahibin cümlesinin birebir karşılığı, ölçekte yüzde olduğu için kırılmaz. Zayıf: hangi kartın yetişmeyeceğini söylemez, yalnız hangi aşamanın dar olduğunu.

**Yön B — Darboğaz cümlesi + ikon.** Aşırı yüklü aşamanın yanında tek satır: "Test yetişmiyor: 3 kart bekler, 1 testçi var", ilgili kişilerin üstünde kırmızı ikon; tıklayınca ilgili kartlara götürür. Referans: Startup Company "bottleneck alert" (Beta 22, ekran görüntüsü: https://steamcdn-a.akamaihd.net/steamcommunity/public/images/clans/28693489/319d5ec1aa1384f404b0d4495515939431dbf267.jpg) ve Factorio uyarı ikonları (https://wiki.factorio.com/images/Fuel-icon-red.png). Güçlü: oyuncuya ne yapacağını söyler. Zayıf: tıklayınca yalnız "ne eksik" diyen uyarı Startup Company'de iç içe bağımlılıkta yetersiz kaldı; sadece uyarıya güvenen oyuncu nedeni gizli bulur.

**Yön C — Kart başına aşama zinciri ve bitiş kolu (Gantt benzeri).** Her kartın tasarım → geliştirme → test parçaları sprint haftalarının üstüne dizilir; testi sprint sonunu aşan kartın test parçası taşar ve "sonraki sprint" etiketi alır. Referanssız: Gantt biçimi için ekran görüntüsü adresi bulunamadı (Linear'ın hedef çizgisi kavramı yakın ama farklı: https://webassets.linear.app/images/ornj730p/production/d9c776ab4f3b38a56b22df4974c8719edc5557fb-1052x584.png?q=95&auto=format&dpr=2). Güçlü: "bu iş yapılır ama testi yetişmez" cümlesini kart bazında doğrudan gösterir, tahmin = sonuç için en güçlü ifade. Zayıf: Software Inc.'te benzer ETA'lar varsayımı gizleyince güven kaybetti; kart sayısı artınca ekran kalabalıklaşır.

**Yön D — Kapasite kadranı (hız türetmeli).** Sprint başlamadan önce tek kadran: "bu sprintte N karttan M tanesi biter", son 3 sprintin gerçekleşmesinden türetilir; geçmiş yoksa kişi ve yıldız sayısından kaba tahmin ve "belirsiz" etiketi. Referans: Linear capacity dial (kadran görseli bulunamadı; grafik görseli yukarıda; kural: https://linear.app/docs/use-cycles). Güçlü: ölçekte sabit sayı yok, kendini ayarlar. Zayıf: ilk sprintlerde güvenilmez, oyuncu nedenini göremez (yalnız sonuç).

Önerilen birleşim: A + B her zaman ekranda, C kartın ayrıntısında, D sprint başlatma onayında.


---

## 8. Tamamlama (2026-10-17, başsız Chrome)

(Bu raporda 7 numaralı bölüm zaten "Gösterim yönleri" olduğu için tamamlama 8 olarak numaralandı.) Kaynak durumu: Startup Company ve Game Dev Tycoon wiki'leri başsız Chrome ile açıldı; Software Inc ve Startup Company için mağaza ekran görüntülerinin içeriğine gözle bakıldı; Software Inc Steam rehberleri okundu. Fandom wiki'lerinde ayrı bir "bottleneck" sayfası yok.

### 8.1 Startup Company: ofiste kim neyi bekliyor (kapanan boşluk: darboğaz ekranları, kısmen)

- Ofis ekranında her çalışanın üstünde tek satırlık durum ve ilerleme yüzdesi var: "FIREWALL (0%)", "INPUT MODULE (85%)", "GRAPHICS COMPONENT (0%)", "WAITING FOR TICKET" (boşta, bilet bekliyor), "RESEARCHING", "MANAGING 3 EMPLOYEES", "CONTRACT #16"; yanında "güncel/tavan" hız sayısı ve ruh hali yüzdesi. Darboğaz tek bir uyarıyla değil, bütün çalışanların üstündeki etiket sürüsünden okunuyor; aynı bileşende birçok kişinin "(0%)" etiketi taşıması tıkanmayı gösteriyor (örnekte birçok "GRAPHICS COMPONENT (0%)" ve "FIREWALL (0%)" yan yana). Kaynak: https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/606800/ss_74de0b0d767febb4e7d11406b38e199884f3d678.1920x1080.jpg?t=1727681373
- Lead Developer penceresi, bir işin neden beklediğini ikonlarla söylüyor: modül ızgarasında her modülün üstünde envanter stok sayısı (143, 144, 142...; kilitli modüller "Locked" ve 0), işin ilerleme çubuğu (%66) ve gereken bileşen ikonları "1 (566)" ve "1 (562)" ("1" gereken adet, parantez içi depodaki stok). Yani gereksinim "adet (stok)" biçiminde, bileşen başına tek rozet. Kaynak: https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/606800/ss_8dac9adb157819ab46d7d360ac63f8f61b75e5c1.1920x1080.jpg?t=1727681373
- Bileşen/modül başına talep, tüketim, üretim gösterimi (Beta 27) için ekran görüntüsü bu turda bulunamadı; "bottleneck alert" ekranı mağaza görüntülerinde yok. Wiki'de de ayrı sayfa yok (Special:AllPages: https://startupcompany.fandom.com/wiki/Special:AllPages). Önceki bölümdeki "yalnız yama notu cümlesi" hâlâ tek kaynak.
- Üretim planı seçeneği: "hedefe ulaşınca aynı oranda üretmeye devam" ve "ön koşul eksikse o modülü atla, yoksa çalışan bekler" (https://startupcompany.fandom.com/wiki/Production_plan). Yani tıkanma davranışı (bekle ya da atla) oyuncunun seçeceği bir ayar.
- Sunucu darboğazı: ürün Stats penceresinde yarım daire kadran (%39) ve "Response Time 204ms" (https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/606800/ss_60b0b2a8fb13081564c418913f9afbebe78c3562.1920x1080.jpg?t=1727681373); Hosting sekmesinde Total CU, Used CU, Free CU, Peak CU (RESET düğmeli), kadran %41, kırmızı-sarı-yeşil dikey şerit "Critical / Unstable / Stable" ve ok, "Response Time 210ms" (https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/606800/ss_12d04b8d057121d1ce7214576367925bb2ea32aa.1920x1080.jpg?t=1727681373). Yani kapasite aşımı üç kademeli etiket ve gecikme sayısıyla gösteriliyor.

### 8.2 Software Inc: üstte "Issues" listesi, çalışan başına verim çubuğu

- Ekran: https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/362620/ss_a3008f0189f7ee81f9c9fbf6cb8edccaf42c3223.1920x1080.jpg?t=1763102408 Üst sol köşede "Issues" paneli, bir satırda "An employee is having trouble finding a place to sit (3)" (sayı kaç kişiyi etkilediğini gösteriyor, yanında göz ikonu). Çalışan penceresinde "Work affecters" altında "Effectiveness" ve "Team Compatibility" çubukları; "Thoughts" altında "Satisfaction" çubukları cümleyle (örnek "There is nowhere to sit" kırmızı, "I'm very happy with my salary" yeşil). Tasarım belgesinde "Recommended designers 6/3" (anlamı yazmıyor; önerilen/atanan olabilir, benim yorumum) ve "ETA: Less than a year". Yani verim kaybının nedeni çalışan başına cümle olarak listelenmiş, oyuncu sayı yerine neden okuyor.
- Önerilen ekip büyüklüğü özellik sayısıyla büyüyor: Beta 1.6 rehberinde 2010 için "Base" ve "Complete" iki sütun var (örnek Ofis yazılımı 2/2/1 ve 8/12/5; Bilgisayar OS 5/8/0 ve 13/24/1). Kaynak: https://steamcommunity.com/sharedfiles/filedetails/?id=2991702551 (oyuncu). Ayrıntı R1 §7.2'de.
- Destek bileti darboğazı (oyuncu stratejisi): iki destek ekibini "am" ve "pm" vardiyaya böl, ikisini birden port ya da hata ayıklamaya atama, çünkü bilet kaçar. Kaynak: https://steamcommunity.com/sharedfiles/filedetails/?id=1971495059

### 8.3 Game Dev Tycoon: aşırı yük ve boşa kullanım farklı cezalanır, çalışanın altında yük çubuğu

- Slider atama ekranında her çalışanın adının altında, çalışanın o projede ne kadar "kullanıldığını" gösteren bir ilerleme çubuğu var; kimse ciddi aşırı yüklenmezse %30 deneyim bonusu verilir ("Good Management"); aşırı yük Design/Tech puanını azaltır. Kaynak: https://gamedevtycoon.fandom.com/wiki/Game_Development (sürüm 1.4.5).
- Formül (wiki, sürüm 1.3.9): kullanım = (Etkin yük / 100) - 1, -1 ile +1 arasında; ceza çarpanı: 0 ise 1, pozitifse (aşırı yük) 1 - 0,75 x kullanım, negatifse (boşa kullanım) 1 - 0,25 x |kullanım|. Yani aşırı yük, boşta kalmaktan üç kat daha çok cezalanıyor; bu, "hepsini doldur ama taşırma" ilkesinin sayısal örneği. Kaynak: https://gamedevtycoon.fandom.com/wiki/Tech_and_Design_Points_Generation_Algorithm
- GDT'de hangi kişinin hangi alana atandığı "kim neyi taşıyor" tablosu olarak slider ekranının kendisi; ayrı bir darboğaz uyarısı wiki'de anılmıyor.

### 8.4 Two Point Hospital: kuyruk uyarısı

- Wiki: "oda üstündeki kuyruk uyarılarına dikkat edin; bir odanın üstüne gelince kuyruktaki insanlar vurgulanır." Hastane büyüdükçe kuyruk uzar, çözüm daha çok oda (GP ofisi) ve personel. Kaynak: https://two-point-hospital.fandom.com/wiki/Hospitals

### 8.5 Bu tamamlamanın §6 listesine etkisi

- Kapandı: Software Inc ekranı (verim çubukları, Issues listesi), Startup Company ofis etiketleri, "adet (stok)" gösterimi, sunucu kadranı.
- Hâlâ bulunamadı: Startup Company "bottleneck alert" ekranı ve eşiği, Satisfactory/Shapez/Anno üretim istatistikleri, Big Ambitions personel darboğazı (wiki.gg açılmadı), FM "eksik pozisyon" uyarısı, Jira/Azure/Linear/ClickUp/Monday ekranları (bu turun kapsamı dışında kaldı).
