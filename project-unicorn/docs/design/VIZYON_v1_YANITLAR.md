# Oyun Vizyonu v1: Yanıtlar ve Evrim Stratejisi

Tarih: 24 Eylül 2026 · Hazırlayan: Claude · Statü: ÖNERİ (Erdem onayı bekler)

## Bağlam

Erdem'in "Oyun Vizyonu v1" belgesi (31 Ağu 2026), §9'da 12 çalışma kararını onaya sunuyor. Buna ek olarak "oyunu en başarılı şekilde nasıl evrimleştiririz" sorusunu soruyor. Bu turda implementasyon yok; istenen, gerekçeli yanıtlar. Yanıtları repodaki gerçek duruma dayandırdım: kod, GDD v2 bölümleri, modül GDD'leri, audit'ler ve raporlar. Her önerinin yanında kanıtı var.

Bugün 24 Eylül 2026. Ocak kapısına yaklaşık 14 hafta kaldı. Son commit (`33c5323`, 31 Ağu), vizyondan beri kod tarafında iş olmadığını gösteriyor.

---

## 0. Kısa cevap

1. **Vizyonun yönü doğru ve mevcut altyapının büyük kısmı ona hazır.** Frank çeki, seed basamağı, 730 günlük tavan, SaveManager, toplantı sahnesi, paylaşılabilir son gazetesi ve kurucunun kod yazıp satışa gitmesi zaten çalışıyor.
2. **Belgenin fiyatlamadığı bir engel var: bugün seed de Series A da oynanarak ulaşılamıyor.** Ölçülen tepe MRR 11.9K$. Seed kapısı 20K$, Series A eşiği 120K$ (`scripts/systems/sales_system.gd:52-62`). Perde 1 kilometre taşı bile gelir eğrisine bağlı. Bu yüzden 0. oturum gelir eğrisi olmalı.
3. **Vizyon bazı kilitli kanonları eziyor ama bunu yazılı olarak söylemiyor.** Çakışanlar: CLAUDE.md'deki Release Scope ve kalibrasyon eşiği, Frank'in sahnede görünmemesi, kurucunun enerji barı, çalışan yüzü, ekip tavanı, "v1'de gerçek zamanlı 3D yok" kuralı. CLAUDE.md ajanlara "çelişkide dur ve sor" diyor. Tek bir "Kanon v3" uzlaştırma commit'i atılmazsa ajan hattı bloklanır.
4. **12 kararın 9'u onay** (bazıları düzeltmeyle), **2'si koşullu** (#2 sanat yönü spike'a, #12 tükenmişlik ark biçimine bağlı), **1'i zaten yasa** (#11).
5. **Evrim stratejisi dört adım.** Önce temel (gelir eğrisi, ölçüm botları, 730 delikleri). Sonra Perde 1'i dikey dilim olarak bitirmek. 3D'yi paralel ve zaman kutulu yürütmek. EA lansmanını Perde 1–2 ile açıp Perde 3'ü EA güncellemesi olarak getirmek.

---

## 1. Belgeyi değiştiren üç bulgu

### 1.1 Gelir eğrisi: Series A ve seed bugün erişilemez
- Series A eşiği `TRACTION_MRR_TARGET := 120_000`. Kodun kendi yorumu: "full_run:730:sim peaks at MRR $11,911 … series_a_close is not reachable in a played run today" (`sales_system.gd:52-59`). Aynı ölçüme göre `b2c_keep:730` 1.8K$'da tepe yapıyor.
- Seed kapısı `DOOR_MRR := 20_000` (`seed_constants.gd:23`). FUNDING_LADDER §4'e göre o da erişilemez.
- Sebep: B2B prospect havuzu 25 hesapla sınırlı ve plato yapıyor. Satış sonrası yaşam döngüsü (yenileme, sözleşme nesnesi) park halinde (`Customer.renewal_day` rezerve, `oda_view.gd:1431`).
- **Hiçbir test bunu görmüyor.** Barla ilgili smoke vakaları MRR'ı `TRACTION_MRR_TARGET + 1000`'e doğrudan ayarlayıp geçiyor.
- Vizyonun "Series A'ya naif kazanma %60–70" hedefi ölçülemiyor. Naif-politika kazanma oranı hiç ölçülmemiş.

### 1.2 Kilitli kanonla çatışmalar

Her satır Kanon v3'te açıkça yeniden yazılmalı.

| Vizyon | Çakıştığı kural | Kaynak |
|---|---|---|
| IPO Perde 3'te bir son; hedef IPO'ya kadar | "IPO is OUT of EA … visible-locked"; EA = sonsuz akış | CLAUDE.md RELEASE SCOPE; ch14 §3–5 |
| Series B Perde 3'te | CLAUDE.md'ye göre EA milestone, ch14 §5'e göre FULL | iki belge kendi içinde de çelişiyor |
| Frank'in sandalyesi, kapıdan girmesi, board'da oturması | "sahne Frank'i asla göstermez — kanalı telefon" | Frank v6 sahneleme kuralı |
| Tükenmişlik sonu (kurucu morali) | "Enerji barı yoktur ve olmayacaktır"; kurucunun morali yok | Ekip GDD §2, §17.6 |
| Çalışanlara yüz | "Employees: no faces. Initials + colour." | ch14 §7 (ch14 §6'daki "AI faces never" kuralına 3D render zaten uyuyor) |
| Gerçek zamanlı 3D karakter | "no real-time 3D in v1" | ch12 |
| Ofis cap'i | "Ekip büyüklüğü tavanı yoktur" | Ekip GDD |
| Hız: pause / 1x / 2x / 4x | 4x 2026-08-19'da kaldırıldı; ladder 1×/2×/3× | `time_manager.gd:47` |
| "Perde" terimi | Satış toplantısında "Perde 1 İKNA / Perde 2 PAZARLIK" | `negotiation_scene.gd:25`, Satış GDD §5 |
| Naif Series A %60–70 hedefi | CLAUDE.md'ye göre naif *politikanın* >%60–70 kazanması "ekonomi çöktü" demek | Calibration Laws tripwire |
| "Frank korpusu 23 yüzey" | 23 bir yüzey *numarası*. Sayım: 26 oluşum, 18 canlı Frank kartı | FRANK_VOICE_INVENTORY §5 |

### 1.3 730 uyarı zincirinde iki uyarısız-kayıp deliği (koddan doğrulandı)
- **(a)** `data/events/arcs/soft_cap_stretch.json`, `phase.series_a_signal == "open"` olduğunda sönüyor (`invalidate_when`). 08-27 yaması açılış kartını faz 2'de açık sinyalle ateşliyor, ama ark hemen sönüyor. Sonuç: yorum ve hüküm hiç gelmiyor.
- **(b)** Faz 3'te sinyal hep açık. `final_stretch_press` koşulu bu yüzden hiç doğmuyor. Canlı teklifi olmayan bir Hunt oyuncusu hiç uyarı almıyor; `last_answer` kartı canlı teklif istiyor.
- `endings_system.gd:281-284` bunu zaten "untelegraphed" diye logluyor ama engellemiyor. Motorun I3 yasası ("telgrafsız kayıp yoktur") ihlal ediliyor.

---

## 2. §9'daki 12 çalışma kararına yanıtlar

### #1 Perde sınırları: ONAY, üç düzeltmeyle
- **Perde geçişini funding olayına bağla, taşınmaya değil.**
  - Seed imzası ya da bilinçli bootstrap kararı Perde 2'yi açar. Series A imzası Perde 3'ü açar.
  - Gerekçe: Mühürlü #6 ofisi round'dan ayırdı. §2.5'teki "taşınma günü = perde geçişi" bununla çelişiyor.
  - Perde (saat, baskı, grammar) funding'le değişir. Mekân (ev → ofis) nakit ve cap ile değişir. "Kalabalık" duygusu taşınınca gelir; Frank'in "ofis vakti" nudge'ı iki anı birbirine yaklaştırır.
- **`act` saklanan bir değişken değil, türetilmiş bir seam olsun (`act.current`).**
  - Funding defterinden hesaplanır: angel, seed ve Series A imzaları ile bootstrap kararı. Böylece tek gerçek kaynak kalır ve save şeması değişmez.
  - SEAM_REGISTRY'ye ve event engine'e named scope slot olarak girer.
  - Eşleme: P1 = Bootstrap + Traction'ın seed'e kadar olan kısmı (seed kapısı bugün faz 2'de). P2 = seed sonrası Traction + Hunt. P3 = yeni fazlar.
- **Bootstrap yolu için seed reddi açılmalı.**
  - Bugün seed masasından kalkmak "ZOR MOD" kilidinde (FUNDING_LADDER §3). v6 "seed isteğe bağlı değil" diyor, ch09 §9 "skip seed: yes" diyor.
  - Vizyon bootstrap'ı meşru bir yol yapıyor. Öyleyse seed reddi zor moddan ayrılıp normal oyunda açılmalı.
- **Ek iki not:**
  - Series A imzası bugün run'ı bitiriyor (`vc_pitch_system.gd:479-496` → `series_a_close`). Perde 3 için bu bir geçişe dönüşür. Demo/fest build'inde bir build bayrağıyla son olarak kalır.
  - "Perde N" etiketi ekranda hiç görünmesin. Satış toplantısındaki "Perde" adıyla çakışıyor. Geçiş mekânla ve törenle hissedilmeli.

### #2 Sanat yönü (birleşik stilize 3D, portre = render): KOŞULLU ONAY, nihai karar spike'tan sonra
- **Yön doğru.**
  - Çalışanlar ilk kez yüz kazanır; bu pillar 1'in gereği.
  - ch14 §6'daki "AI faces never" kuralına uyar.
  - Mevcut portreler AI ürünüyse Steam'deki AI beyanı da ortadan kalkar. Repoda MetaAI kaynak kaydı yok; portreler elle konmuş `.webp` dosyaları (`assets/art/founders/` altında 11 dosya, `assets/art/investors/`).
- **Belgenin fiyatlamadığı iki risk:**
  - (a) **Ton.** Quaternius/Kenney CC0 bedenleri oyuncak görünümlü. Oyunun sesi Disco/Frostpunk kuruluğunda, ODA da PBR + LightmapGI. Oyuncak figür ile ciddi ton yan yana gelince tonal kırılma olur.
  - (b) **Portre ölçeği.** Low-poly yüz oda mesafesinde iyi durur, büst kadrajında zayıflar. Portreler ise yakın plandır.
- **Spike kabul kriterleri** (dördü de geçmeli):
  1. Aynı karakter hem ODA'da oda mesafesinde hem 512px büstte okunuyor.
  2. Preset kiti en az 20 ayırt edilebilir yüz üretiyor. Çalışanlar prosedürel olarak bu kitten doğuyor.
  3. Büst render'ı, portre ışık rig'i ve stilize shader ile yatırımcı portrelerinin yanında "aynı oyun" gibi görünüyor.
  4. Yeni bir karakterin maliyeti en fazla yarım gün.
- **Kriterler geçmezse** belgedeki ucuz alternatife geçilir: yüzsüz siluet ve mevcut portreler. Bu durumda ch14 §7 kanonu olduğu gibi kalır.
- **Frank'e oda modeli gerekmez**, çünkü sahnede görünmüyor (bkz. §3-C). Yalnız portre büstü gerekir.

### #3 3D kapsam kademeleri: ONAY (OUT kilidi dahil), üç ekle
- **Teknik yol hibrit olsun; spike'ın ilk sorusu bu.**
  - ODA runtime'ı bugün 2D: 3840×2160 PNG katmanları (`oda_view.gd:12-45`), `scenes/oda3d/` sahnesinden offline bake ediliyor.
  - Öneri: plakalar arka plan olarak kalır. Karakterler aynı kamera parametreleriyle bir SubViewport'ta şeffaf zeminle render edilip katmanların arasına bindirilir.
  - Masa ve duvar gibi örtücüler karakter viewport'unda görünmez "holdout" mesh olarak durur. Karakter ışığı aynı sahnede bake edilmiş probe'lardan gelir.
  - "Masa odağı" iki şeyle yapılır: 4K plakada 2D kırpma ve karakter kamerasında eşleşen FOV/lens kaydırması.
  - **Kazanç:** `--theme-audit=oda` kapısı, dondurulmuş tema, hover ve telefon katmanları dokunulmadan kalır. Serbest kamera zaten OUT olduğu için hibrit mümkün.
- **MV'den çıkar:** "Frank'in sandalyesi / kapıdan girmesi" (Frank kanonu).
- **OUT'a ekle:** ofis kademesi başına birden fazla 3D oda (bkz. #7).
- **Zaman kutusu (kill date):**
  - Spike 1 hafta.
  - MV partner hattında en fazla 6 hafta.
  - MV 1 Aralık'ta kabul kapısından geçmezse Ocak kapısına plakalar ve yüzsüz figürlerle girilir.
  - Belgenin kendi tespit ettiği "sonsuz cila" riskine karşı tek gerçek sigorta bu tarih.

### #4 Kişisel runway: ONAY, ayrı cüzdan olmadan
- **Mevcut yapı bunu zaten yapıyor.**
  - `STARTING_CASH 10000` birikimdir (ch09: "savings ~$10K").
  - Burn tablosunda `"founder": 50/gün` (≈1.5K$/ay) kurucunun yaşam gideri olarak tanımlı (`finance_system.gd:34-43`).
  - Kurucunun maaşı 0 (`game_state.gd:1140`).
- **İkinci bir nakit havuzu kurma.** İki runway, iki bar, write-through yükü ve okunabilirlik kaybı getirir.
- **Öneri:**
  - Perde 1'de nakit "Birikim", founder satırı "Kira + yaşam" olarak *sunulur*. Bu yalnız bir çerçeve değişikliği.
  - Seed imzasında bir karar anı gelir: **"Kendine maaş bağla?"** Yaşam gideri bordroya geçer ve yatırımcı bunu görür. Bu bir Para/Kontrol takası.
  - Perde 1 iflası yeni bir son değil, mevcut bankruptcy'nin bir varyantı olarak yazılır: "Birikim bitti, işe geri dönüş".
- Ayrı kişisel servet ancak Perde 3'te gerekir (Series B secondary, IPO net değeri). O zaman kurulur.

### #5 730 gün, Perde 2'nin saati: ONAY, saat gün 1'e demirli kalsın
- **Zaten inşa edilmiş.** `SOFT_CAP_DAY := 730` gün 1'den sayıyor (`endings_system.gd:41`) ve `arc_final_stretch` var.
- **Seed'den saymamak için üç sebep:**
  - Bootstrap oyuncusunun saati olmaz.
  - Toplam koşu uzar.
  - Mevcut ark yeniden yazılır.
- **Gün 1 demiri okunabilir:** "şirketin ikinci yaşı". Kalibrasyon hedefi P1 medyanı ≈ gün 150–200. Böylece P2'ye ≈18 ay kalır; bu gerçek bir seed→A penceresi.
- **Gün 730'da ne olur:**
  - Şirket kârlıysa `profitable_bootstrap`.
  - Değilse "Pencere kapandı": `running_on_fumes`'un yeni kopyası.
- **Önce §1.3'teki iki delik kapanır.** Vizyonun "uyarısız-kayıp bug'ı bu tasarımla kapanır" varsayımı tek başına yetmez; delikler ayrıca yamanmalı.
- **Uyarının sesi:**
  - Vizyon "Frank değil" diyor. En doğal ses **seed yatırımcısı**; harsh bantta zaten koltuk ve veto alıyor (§3-E).
  - Bootstrap oyuncusuna uyarı basından gelir.
- **Perde 3'te 730 kapalıdır.** P3'ün saati board eğrisi.

### #6 Remote çalışan formülü ve cap: ONAY, formül değişikliğiyle
- **−%15'i "odak"a koyma.** §4.5'te odak "tek iş / iki iş" anlamına geliyor (1,0 / 0,5).
  - Ayrı bir çarpan ekle: **koordinasyon** (1,0 / 0,85).
  - −%15 moral tabanıyla aynı sayı; ikisi üst üste binince çıktı 0,72'ye düşer. Kabul edilebilir ama ölçülmeli.
- **"Liderlik telafi eder" iddiası tutmuyor.** Liderlik bonusu yarım yıldız başına +%1, 5 yıldızda yaklaşık +%10 eder; −%15'i kapatmaz.
  - Öneri: Liderlik remote cezasını doğrudan azaltsın (ör. yarım yıldız başına +1,5 puan, tavan 0). Global bonusla üst üste binmesin.
- **Pusulada "kontrol" maliyeti eksik.** −%15 bir hız maliyeti, kontrol maliyeti değil. Kontrol maliyeti şöyle olsun:
  - Remote çalışanın morali odada görünmez; okuma gecikmeli ya da bantlı gelir.
  - Poaching ve istifa riski daha yüksektir.
  - "Uzaktakinin ne düşündüğünü bilmezsin" hem gerçekçi hem Perde 1'in yalnızlığına uyuyor.
- **Cap:** P1'de 2 (ev tek masa: sen + iki ekran). Sonra lider +2, VP +N. Remote cap olmazsa ofis merdiveni yük taşımaz; belge bu noktada haklı.
- **Kanon değişikliği:** Ekip GDD'deki "ekip tavanı yoktur" maddesi düşer.

### #7 Ofis kataloğu: YAPI ONAY, değerler kalibrasyona; "cap = Marker3D" RED
- **Game Dev Tycoon modeli doğru.** Tekrar eden kira zayıf bir baskı: Ofis 1 kirası 8–10 kişilik bordronun ≈%7–10'u. Asıl darbe depozito + fit-out götürüsü. Bu gerçekçi ve taşınmayı "şimdi mi?" kararına dönüştürüyor.
- **Seçenekleri ucuz yap.** Her seçenek ayrı bir 3D oda olursa sanat maliyeti 3 katına çıkar.
  - Kademe başına **tek oda mesh'i** olsun. Seçenekler bir konum etiketi ve parametreler olsun (Kadıköy / Levent / Maslak): kira, Atlas aday kalitesi, B2B toplantısında güven, pencere manzarası plakası.
  - Yeni bir "prestij" stat'ı icat etme; mevcut kaldıraçlara bağla.
- **§4.5'i ters çevir: cap ofis katalog verisinde dursun.** Bunun iki sebebi var:
  - Calibration Law "tek tuning yüzeyi" istiyor.
  - Headless sim ve harness'ler (`--run-log=…:sim`, `--event-harness`) 3D sahne yüklemeden cap'i bilmek zorunda.
  - Bir lint, Marker3D sayısının katalog cap'ine eşit olduğunu doğrular.
- `finance_system.gd:39`'daki `"office": 0` hook'u bunun yeri. 04_finans audit'indeki "hook'u sil" önerisi iptal edilir.

### #8 İK rolü: ONAY, Perde 3 başına
- **Telegraf zaten var.** Atlas'ta "in-house İK" kilitli ve görünür duruyor (Ekip GDD §10.6); vizyon bu telegrafı ödüyor.
- **Değer işe alım hızına bağlı olsun.** Atlas komisyonu, yani bir aylık maaşın %50'si (`hr_constants.gd:1065`), yıllık hire sayısıyla çarpıldığında İK maaşını geçtiği an İK anlamlı olur. 10 kişide gereksiz, 25'te değerli olur. Böylece "her zaman al" optimum olmaz (Calibration Law 4).
- **Kademe kaydırma önerisi.** Kademe 1 (takım lideri) "Ofis 1 dolarken" değil, **Ofis 2 / Perde 3 ile** açılsın.
  - Ofis 1 cap'i 8–10 kişi; Ekip rev 11 bu ölçeği taşıyor.
  - Bu, delegasyon katmanının tamamını Ocak kapısı kapsamından çıkarır.

### #9 Run kartı ilk build'e: GÜÇLÜ ONAY, yarıdan fazlası zaten var
- **Mevcut parçalar:** `ending_scene.gd:503-536` "GAZETEYİ PAYLAŞ" ile PNG export yapıyor, `get_run_ledger()` (`game_state.gd:809-892`) istatistikleri veriyor.
- **Run kartı = bu gazete + eklenenler:** zaman çizgisi şeridi (ODA → Ofis 1 → …), headcount, MRR, kontrol yüzdesi, gün.
- **Eksikler:**
  - Son başına illüstrasyonlar (`assets/endings/README.md`).
  - Boş wishlist URL'si (`ending_scene.gd:26`). Coming Soon açılınca doldurulur.
- **Ek öneri: tohum kodu.** RNG zaten tohumlu ve deterministik. Karta tohum kodu konursa "aynı tohumla oyna" meydan okuması neredeyse bedavaya gelir; yayıncılar ve topluluk için iyi bir kanca.

### #10 Teknik borcun Perde 3'te dönmesi: ONAY, tohumu Perde 1'de ekilir
- Calibration Law 3 sebebin okunur olmasını istiyor. P3'teki "yeniden yaz mı?" anı ancak borç P1–P2'de *görünür biçimde* birikmişse adil olur.
- `urun.tech_debt` seviyesi bugün YOK durumunda (SEAM_REGISTRY §7).
- **Öneri:**
  - Borç sayacı ve ürün ekranındaki tek satır, P1'de MVP kapsamı ve hotfix kararlarıyla başlasın. Bu ucuz.
  - Bedel P3'te tek bir karar anı olarak gelsin.

### #11 Sektör etkinlik isimlerinin kurgulanması: karar değil, mevcut yasa
- **Yasa zaten var:** ch14 §6, motor GDD D6 ("release blocker") ve `scripts/events/tools/lint.gd` içindeki `FORBIDDEN_TERMS`.
- **Yerleşik kurgu isimler:** Meridyen (YC), Vitrin (Product Hunt), Ekonomi Postası, TeknoGündem, Girişim Bülteni, Sektör Telgrafı, Atlas.
- **Yapılacaklar:**
  - Lint bugün yalnız event kartlarını tarıyor. Rakip ve şirket kataloğunu, haberleri ve `strings.csv`'yi de tarayacak şekilde genişlet.
  - PROJECT_SPEC §3.3'teki "TC Disrupt / YC Demo Day" ifadelerini temizle.

### #12 Tükenmişlik sonu: METRE olarak RED, ARK olarak ONAY (düşük öncelik)
- **Kanon ne diyor:**
  - Ekip GDD: "Enerji barı yoktur ve olmayacaktır". Kurucunun morali de yok.
  - Motor GDD I3 ise "kurucu tükenmesi"ni telgraflı kayıp kapsamında sayıyor.
- **Öneri: tükenmişlik, mevcut gözlenebilir durumdan beslenen bir ark olsun.** Girdiler:
  - kurucunun çalışma saati ayarı (üç kapsamlı saatler modali var),
  - kurucunun elindeki iş sayısı,
  - haftalarca izin yapılmamış olması.
- **Telgraf üç adımlı:** beden/uyku → yakın biri → çöküş. Yeni bar ya da stat yok.
- **Yeri:** P1–P2, kurucunun her şeyi kendisinin yaptığı dönem. Ocak kapısına sığmazsa ilk kesilen son budur.

---

## 3. §9'da olmayan ama karar gerektirenler

**A. Kapsam yasası (en acil).**
- CLAUDE.md RELEASE SCOPE ve ch14 vizyonla çelişiyor (bkz. §1.2). Önerim:
  - **Demo (opsiyon):** P1 + P2. Series A zafer ekranıyla biter; bugünkü davranış bir bayrakla korunur.
  - **EA lansmanı:** P1–P2 tam, P3 görünür-kilitli ("yol haritasında"). P3, EA'nın büyük güncellemeleriyle gelir.
  - **1.0:** IPO'ya kadar. Perde 4 telegraf olarak kalır.
- "Sonsuz sandbox EA" tanımı emekliye ayrılır. P3'ün board eğrisi zaten o akışın baskı motoru; IPO ya da kovulma ona son verir.
- **Gerekçe:**
  - 2 kişilik ekip ve 14 hafta var.
  - İlk 2 saat kuralı zaten P1–P2'yi öne alıyor.
  - EA incelemeleri dürüst bir yol haritasını affeder, cilasız bir ilk saati affetmez.
- Mühürlü #2 ("hedef oyunun tamamı") ile çelişmez. Hedef aynı kalıyor; değişen yalnız EA'nın kesim çizgisi.

**B. Gelir eğrisi = 0. tasarım oturumu (blocker).**
- Prospect havuzu (F1) ile satış sonrası yaşam döngüsü (yenileme, sözleşme nesnesi) aynı iş. Vizyon ikincisine "artık zorunlu" diyor.
- **Kalibrasyon aracı:** naif-politika botları (her zaman kabul et / hep B2B / bootstrap) × N tohum ile kazanma oranları ölçülür.
  - `--run-log` sim ve `--event-harness` zaten var. Eksik olan politika katmanı ve toplu koşu.
- **"Naif" kelimesini ikiye ayır:**
  - İlk-run insan hedefi: Series A'ya %50–65.
  - Aptal bot politikası: %25–30'un altında.
  - Böylece CLAUDE.md tripwire'ı ile vizyonun hedefi çakışmaz.

**C. Frank sahnede.**
- v6 kanonunu koru: odada Frank'in *boş* sandalyesi ve telefonun titremesi yeter.
- Tek istisna yazar kararı olsun: tüm oyunda tek fiziksel görünüş (ör. kovulma oylaması ya da halka arz günü). Kıtlık değer üretir; aforizma bütçesinin mantığı da bu.
- Board'da Frank: %4'lük melek hissesi koltuk vermez. Gözlemci koltuğu gerçekçi.

**D. Zor mod.**
- **Şu an dört ayrı tanım var:**
  - Frank reddi (ch01).
  - Normal + Hard modu (ch14 §2).
  - "Az sermaye, sert rakip" (PROJECT_SPEC §3.6).
  - Tek save slotu (motor GDD).
- `hard_mode_unlocked` bayrağına hiçbir kod yazmıyor (`game_state.gd:169`), yani reddet seçeneği hiçbir zaman açılamıyor.
- **Öneri:**
  - Zor mod = çek anında Frank'i reddetmek. Onboarding'de seçilmez; seçim anında iki kez teyit edilir.
  - İçerik maliyetini düşüren kanon: v6 "Frank yalnız hissesi olduğu yerde kalır" diyor. Reddedilince Frank susar; bu yalnızlık perdesine de uyuyor.
  - Vizyonun "hard mode'da tek düşman" fikri için ucuz ve güçlü bir yol: reddedilen çek bir rakibe gider ve Frank P3'te o rakibin board'unda oturur. Yazar kararı.

**E. Seed koltuğu saklanmıyor.**
- Koltuk ve veto teklif ediliyor (`seed_constants.gd:68-72`), ama `seed_round_system.gd` içindeki `accept()` bunları kaydetmiyor.
- Board sistemi ve 730 uyarısının sesi buna dayanıyor. P1'de kapanmalı.

**F. Rakipler P2'de en az bir hamle yapmalı.**
- Rakipler bugün yalnız stat eğrisi (`rival_registry.gd`): "Nothing in the codebase lets a rival act".
- "Rakip pazarı aldı" sonu ve ch14'ün demo şartı en az bir hamle istiyor.
- **Öneri:** P2'ye minimal bir hamle destesi (fiyat kesme + basın). Rakip savaşı P3'te.

**G. İçerik darboğazı.**
- **Bugün:** 30 canlı kart (18 Frank + 12). B2C 120 günde yalnız 2 kart görüyor. Sessiz taban (§13.6) boş.
- **Hedef:** 90–110 olay + Frank yüzeyleri + arklar.
- **Sorun:** Erdem hem tasarımcı hem TR kanonik yazar. Tek iş parçacığı; kabaca 100 olay × ~1 saat düzeltme ≈ 100 saat.
- **Öneri:**
  - Ajan, ark spec'inden bir TR iskelet taslağı çıkarır; Erdem düzeltir; EN literary ajan çevirir.
  - Haftalık kota: P1'in 25–30 olayı Kasım başında bitmiş olsun.

**H. Steam Coming Soon sayfası.**
- 3D'yi bekleme. Sayfayı mevcut ODA plakaları ve UI ekranlarıyla aç; wishlist ilk günden birikir.
- Kapsül görseli ve trailer 3D MV'den sonra güncellenir.
- Mevcut portreler AI üretimiyse sayfa AI beyanı ister. Ya beyan ver ya da ekran görüntülerinde portresiz kareler kullan.

---

## 4. Evrimi en başarılı şekilde yapmak: ilkeler ve sıra

**Beş ilke:**
1. **Önce temel.** Gelir eğrisi, ölçüm botları ve 730 delikleri kapanmadan yeni perde inşa edilmez.
2. **Kanon tek commit'te uzlaşır (Kanon v3).** CLAUDE.md Release Scope, ch12, ch14 §7, Ekip GDD (tavan, remote) ve Frank v6 sahneleme kuralı birlikte güncellenir. Aksi halde ajanlar "çelişkide dur" kuralıyla bloklanır.
3. **Dikey dilim.** P1 uçtan uca bitip cilalanır; ilk 2 saat oradadır.
4. **3D paralel ve zaman kutulu yürür.** 1 haftalık spike, 1 Aralık MV kapısı, fallback hazır.
5. **Dış playtest erken yapılır.** TR kurucu topluluğu hem "tanınma" dalgası hem veri kaynağı (Steam Playtest).

**Revize tasarım oturumu sırası:**
- **0. Gelir eğrisi + kalibrasyon** (yeni)
- 1. Perde yapısı
- 2. Funding grameri
- 3. Ofis + 3D (spike hemen başlar)
- **4. Rakipler: minimal P2 destesi** (öne alındı)
- 5. Yetki devri (P3)
- 6. Haber motoru (P3)
- 7. IPO

**Takvim önerisi:**

| Dönem | Erdem (tasarım + içerik) | Partner + ajanlar |
|---|---|---|
| Eyl sonu – Eki 1. hafta | Kanon v3 kararları, gelir eğrisi oturumu | 3D spike, kalibrasyon bot harness'i, 730 delikleri |
| Ekim | Funding grameri GDD, P1 olayları (25–30) | P1: Birikim çerçevesi, remote + cap, seed'in P1 sonuna taşınması ve reddi, `act` seam'i, seed koltuğu, run kartı v1; spike sonrası F5 sanat kararı |
| Kasım başı | **P1 kilometre taşı** + dış playtest | Steam Coming Soon |
| Kasım – Aralık | Ofis GDD, P2 olayları, minimal rakip destesi | Ofis sistemi (Ofis 0–1), satış sonrası yaşam döngüsü, 3D MV (1 Ara kabul), options |
| Ocak | **Ocak kapısı** (vizyon §8'deki şartlarla) | |
| 2027 | P3: board ve eğri, Series B, delegasyon, rakip savaşı, haber, IPO | |

---

## 5. Doğrulama: yanıtların doğru olduğunu nasıl bileceğiz

- **Bot harness** her kalibrasyon turunda şunları raporlar: P1 medyan günü, seed'e ulaşma oranı, Series A oranı, 730'da kayıp oranı, kararlar arası süre dağılımı (90 sn'yi aşan boşluk sayısı).
- **Telgraf yasası:** `endings_system.gd:426-445`'teki "untelegraphed" logu tüm harness koşularında sıfır olmalı (assert).
- **3D:** #2'deki dört spike kriteri geçmeli. `--theme-audit=oda` çıktısı bayt-aynı kalmalı.
- **İlk 2 saat:** 5–10 TR kurucuyla dış playtest. Ölçülenler: 2. saatten önce bırakan oldu mu, "bu bana oldu" anları nerede, ilk ofis anı nerede.

---

## 6. Bu belgenin statüsü

Bu belge bir öneridir, karar değildir. Kod değişikliği içermez. Yanıtların hiçbiri Erdem'in F5 onayı olmadan kanona girmez. Onaylananlar tek bir "Kanon v3" commit'iyle CLAUDE.md'ye, ilgili GDD v2 bölümlerine, Ekip GDD'ye ve Frank v6'ya işlenir (bkz. §4 ilke 2).
