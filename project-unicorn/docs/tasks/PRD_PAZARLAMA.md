# PRD · Pazarlama

**Kim çalıştırır:** bir geliştirici ajanı oturumu. Başlatma cümlesi: "project-unicorn/docs/tasks/PRD_PAZARLAMA.md dosyasını oku ve
uygula."
**Durum:** TASLAK 2, DUZELTME 2026-11-14; Erdem'in tur 4 yorumu (`tur4_ekranlar_2026-11-13/ERDEM_YORUMU_TUR4.md` §3, §4 ekran 60–72),
yardımcı yönetmenin kararları ve bir Opus incelemesi (`tur4_ekranlar_2026-11-13/pazarlama/elestirmen/prd_inceleme.md`, işlenişi §15).
İkinci tur kareleri `tur4_ekranlar_2026-11-13/pazarlama/kareler/`. §13'teki dört soru Erdem'de; cevaplar gelince PRD güncellenir, sonra
kod. Sayılar başlangıç değeridir, [WORKING] ve "onay bekliyor" diye iner.
**Ne zaman:** `pazaryeri/ORTAK_ARAYUZLER.md` §3'ün dalgalarıyla: ERP hâli (§7) dalga 3, pazaryeri hâli (§3, §5, §6) dalga 5, yani
PAZARYERI'nin sistem paketinden sonra. Ortak dosyalarda önce bu PRD, sonra PAZARYERI.
**Tek cümle:** oyuncu pazarlamayı sprintten ayrı yönetir: kanallara haftalık bütçe koyar ve her kanalın getirdiğini gerçek reklam
araçlarının diliyle (bütçe, yeni kullanıcı, kullanıcı başı, MRR katkısı) okur; kanalı ekibinden birine yürütür, ekibin yükünü görür;
hazır şablondan kampanya başlatır ve sonucunu beklenenle karşılaştırır. Kapıyı organik büyüme açar, pazarlama onu hızlandırır.

## 1. Kurallar

- `CLAUDE.md` bağlayıcı: §3 (doğrudan main, push yok), §5 (önce İngilizce; yeni anahtarlar `MKT_`; TR "TR/EN onay bekliyor"),
  §8–§9 (her commit'e inceleme), §10, §11 (görsel kabul, --screen 2), §12 (kapılar).
- **WRITE-THROUGH.** Pazarlama `GameState.marketing`'i ve Finans'taki `marketing` kalemini (`FinanceSystem.set_burn_category`) yazar.
  Başka alana yalnız sahibinin seam'iyle: aday `SalesFaucetSystem.spawn` (sektör alan yeni isteğe bağlı parametreyle, §7 B1), kasa
  `FinanceSystem.apply_one_time_income` (`finance_system.gd:193`, hediye çeki), moral `CharacterRegistry` (adlı fonksiyon, §7 B3).
- **Erdem'in tur 4 ortak kuralları** her ekranda (ERDEM_YORUMU §3): uydurma açıklama cümlesi yok, oyuncunun bilemeyeceği bilgi yok,
  "kilitli" yerine şart, az bilgi, her sayı neye göre olduğunu söyler, angarya kurulum yok, deneme yanılma.
- Sözler: "kullanıcı", "mağaza", ödeyen taraf "Şirket" (ORTAK_ARAYUZLER; Politikalar'da Erdem'in "biz öderiz" önerisi PAZARYERI'nin
  sorusu, cevap gelince iki ekran aynı sözü kullanır); doyumun adı "Reklam doyumu" (yardımcı yönetmen; Kategoriler aynı sayıyı aynı
  adla gösterir). Araya giren değer ek almaz (CLAUDE.md §5): "Satışlara oranı: %2,5", "Yük: Ece Arslan %90",
  "haftalık reklam yeri: 82.000 · gösterildiğin: 34.000".
- Pazarlama sprint puanı üretmez (Erdem karar 3). Not ve video ürünü oyundan kalkıyor (Erdem, ERDEM_YORUMU §2): Pazarlama yalnız
  pazaryeri ve ERP içindir.

## 2. Oyuncu ne yapar ve sekmenin düzeni

Sekme dört bölümdür (kareler `P1_kanallar_pazaryeri`, `P3_kanallar_erp`):
1. **Başlık:** yeni kullanıcı, MRR katkısı, ücretli pay, haftalık harcama (altında "Satışlara oranı: %X"). ERP: bu hafta aday, satışa
   giden, eşik altında, haftalık harcama.
2. **Ekip şeridi:** Pazarlama'daki kişiler, her birinde yük çubuğu ve yüzde; boş yuva "+". ERP'de sağda devir eşiği.
3. **Kanallar:** etkin kanal satırları, "Kanal ekle", en altta salt okunur Organik.
4. **Sağ sütun:** Kampanya (hazırlıkta ya da sürmekte olan, "Kampanya kur"), Geçmiş (biten kampanyalar, tıklanınca sonuç kartı).
   ERP'de Fuar.

Oyuncu kanal ekler ve bütçesini koyar; satırı ekibinden birine yürütür; getiriyi okur; satırı açıp yalnız yürüttüğü kanalın son
12 haftasını görür; hazır şablondan kampanya başlatır; biten kampanyanın sonucunu beklenenle karşılaştırır.

## 3. Kanallar (M)

**Bugün kodda:** pazarlama yalnız kilitli "itki"dir (`finance_system.gd:158-176`, B2C kitle girişini çarpar `sales_system.gd:204`);
rayda Pazarlama `lock: "ea"` (`ui_tokens.gd:299`).

- **M1 Kanal kataloğu (2012).** Pazaryeri: Arama reklamı, Sosyal reklam, Görüntülü reklam, Fiyat karşılaştırma, Gelir ortaklığı,
  İçerik ve SEO, E-posta, Fenomen işbirliği, Radyo, Televizyon. Dayanak `pazarlama/arastirma/2a_kanallar_2012.md`: 2012'de dijital
  reklamın en büyük kalemi arama (448 milyon TL), sonra görüntülü (374 milyon TL; gelir ortaklığı dahil) [K1]; TV'ye giren e-ticaret
  siteleri ve fiyatları [K3, K4]. Sosyal reklam, fenomen ve radyo için maliyet kaynağı yok (`2a` "sabit olarak girmemesi
  gerekenler"): tasarım kararıdır. Satır yalnız eklenince görünür. "Kanal ekle" penceresi kanalın bedel tabanını ve karşılanmayan
  şartı yazar, beklenen sonucu yazmaz (ortak kural 9). Kabul: `P1_kanal_ekle`.
- **M2 Bütçe ve ölçek.** Satırın bütçesi haftalık dolar; − / + adımı 1, 2, 5 dizisinde yürür ($100, $200, $500, $1.000, $2.000 …).
  Kademe (Az, Orta, Çok) yok. Başlıkta "Haftalık harcama"nın altında "Satışlara oranı: %X" (satış = mağazaların bu hafta sattığı ürünlerin
  toplam tutarı, PAZARYERI'nin GMV'si); o hafta satış yoksa bu satır yazılmaz. Hepsiburada reklam giderini GMV'nin %2,3'ü diye
  raporluyor [M7]. Kabul: `P1_kanallar_pazaryeri` %2,5, `P1_buyuyen_ekip` %6.
- **M3 Satırın dört sayısı.** BÜTÇE · YENİ KULLANICI · KULLANICI BAŞI · MRR KATKISI. Google ve Meta'nın ortak çekirdeği harcama,
  sonuç ve sonuç başı maliyettir [M1, M4]; getiri GMV değil komisyondur [M10, M11]. Tanımlar (ipucunda, ortak kural 6):
  - kullanıcı başı = bu haftaki harcama ÷ bu hafta kanaldan gelen yeni kullanıcı;
  - **MRR katkısı = bu kanaldan son 12 haftada gelen kullanıcıların son dört haftada bıraktığı net komisyon** (aylık gelirin tanımı,
    ORTAK_ARAYUZLER: son dört haftanın net komisyonu). Gözlenen sayıdır, tahmin değil: kanal yeniyken küçüktür, haftalar geçtikçe dolar.
    Kaynak: Pazaryeri her hafta yeni kullanıcıyı kaynağıyla saklar (son 12 hafta, hafta hafta; kaynak "organic" ya da kanal ve
    kampanya kimliği) ve `MarketplaceSystem.source_revenue(kaynak)` o kaynaktan gelenlerin son dört haftadaki net komisyonunu döndürür
    (PAZARYERI, ORTAK_ARAYUZLER taslak 4). Bunun için `channel_visits` ziyareti kanal ve kampanya kimliğiyle anahtarlı verir.
  "Geri ödeme N hafta" yok (Erdem sorguladı).
- **M4 Formül (pazaryeri).** ziyaret = bütçe ÷ tıklama bedeli; tıklama bedeli = taban(kanal, kategori) × doyum çarpanı × görsel yaşı
  çarpanı × yük çarpanı ÷ marka araması çarpanı; yeni kullanıcı = ziyaret × dönüşüm (`MarketplaceSystem.channel_read(kategori)`).
  Sayılar `data/marketing/channels.json` [WORKING].
- **M5 Reklam doyumu.** Bu kategorideki aramalarda reklamın gösterilebileceği haftalık yerlerin yüzde kaçında gösterildiğimiz
  (AdWords'ün gösterim payı [M2]). Havuz kategorinin haftalık aramasıdır (PAZARYERI'nin kategori verisinden; Pazarlama hesaplar,
  `MarketingSystem.impression_share(kategori)`, Kategoriler okur). İpucu iki sayıyı yazar: "Moda aramalarında haftalık reklam
  yeri: 82.000 · gösterildiğin: 34.000." Havuzun başlangıç değerleri PRD_PAZARYERI §3.2'de (Moda 82.000). Doyum çarpanı payla artar: kalan yerler daha pahalıdır [WORKING]. Satırda yalnız yüksekken uyarı
  etiketi ("Moda reklam doyumu %86") ve Kategoriler bağı; açılan satırda etiketli çubuk. Yeni kategori yeni yer açar: aynı kanal ikinci
  kategoride ayrı satırdır. (PAZARYERI simülasyonunun "kategori doluluğu", `pazaryeri/OLCUM.md` §4b, mağaza ve kullanıcı tarafının ayrı
  terimidir; bu sayı değildir.) Kabul: `P1_kanal_acik` %41, `P1_buyuyen_ekip` %86.
- **M6 Açılan satır = yürütülenin performansı.** Son 12 hafta (ziyaret çubuğu, kullanıcı başı çizgisi, bütçe değişikliğinin işareti),
  dört olgu (ziyaret; dönüşüm "ziyaretlerin %1,5'i yeni kullanıcı oldu"; kullanıcı başı; MRR katkısı), doyum çubuğu, "Bir hafta
  durdur". Öbür bütçelerin sonucu yok (ortak kural 9). Kabul: `P1_kanal_acik`.
- **M7 Bir hafta durdur (deney).** Arama reklamının yeni kullanıcılarının bir payı zaten organik gelecekti (marka araması yapan);
  satır onları kendine yazar (son tıklama). Durdurma haftasında organik o payı geri alır, rapor farkı yazar: "Arama reklamı durunca
  yeni kullanıcı 30 değil 18 azaldı." [WORKING pay]. eBay deneyi marka anahtar kelimesindeki reklamın ölçülebilir kısa vadeli faydası
  olmadığını kanalı kapatarak gösterdi [M5].
- **M8 İçerik ve SEO.** Bütçe (serbest yazar) ve yürüten; ziyaret birikir, durunca yavaş söner (`1a` §2: içerik geri ödemesi 15 ay,
  SEO 12 ile 24 ay; oyun zamanına sıkıştırılmış [WORKING]).
- **M9 E-posta.** Bütçesiz; yürüten ister; yeni kullanıcı getirmez, geri dönüşü artırır (`MarketingSystem.return_lift()`, PAZARYERI
  okur) ve kampanyayı var olan kullanıcıya duyurur. CRM ilk müşteriler gelince en yüksek getirili iştir [T1].
- **M10 Marka kanalları (Radyo, Televizyon).** Yayın başı sabit bedel ("İki haftalık yayın, en az $25.000" [WORKING]); şart: seed ve
  Pazarlama Müdürü. Satırı dönüşüm göstermez: erişim ve marka araması artışı gösterir (tasarım kararı; Meta'nın marka modunun erişim ve
  sıklık olduğu `2b`'de [DEĞERLENDİREMEM]). Yayın haftası ve sonraki iki hafta marka araması artar ve M4'teki çarpanla arama satırının
  tıklama bedelini düşürür. TV bilinirlik ve güven getirir, alışverişe indirim ve ürünle döner [K3, K4; 2013 tezi `2a`]. Kabul: TV
  haftasında arama satırının kullanıcı başı düşer (çekirdek vaka `marketing_brand_lifts_search`).
- **M11 Görsel yorgunluğu.** Ücretli satırın görselleri yaşlanır; tıklama oranı önce düşer, kullanıcı başı iki üç hafta sonra bozulur,
  düşüş kademelidir [T4, T5a]; hız harcamayla artar [T4]. Satırda uyarı "Görseller yoruldu". Pazarlama'daki tasarımcı yeni görsel
  üretince yaş sıfırlanır. Kabul: `P1_buyuyen_ekip` Sosyal reklam satırı.
- **M12 Ücretli pay.** Başlıkta son dört haftada gelen yeni kullanıcıların reklam (arama, sosyal, görüntülü, fiyat karşılaştırma,
  gelir ortaklığı), kampanya ve kupondan gelen payı; İçerik, E-posta ve Organik ücretli sayılmaz. Yatırımcının sorusunun girdisi (§12).

## 4. Ekip (E)

- **E1 Roller ve kayıt.** Pazarlama Uzmanı ve Pazarlama Müdürü `HRConstants.EMPLOYEE_ROLES`'un **sonuna** eklenir (tohum indeksi
  `find()` ile türer, var olan rollerin indeksi korunur); `FUTURE_ROLES`'tan `marketing` çıkar (`hr_constants.gd:388`); kadro grubu
  `marketing` (`ROLE_GROUP`, `hr_constants.gd:326`). `endgame_smoke.gd:8401` rol sayısını 6 diye sınar: aynı commit'te güncellenir.
  Pazarlama yeni bir **iş**tir, yeni bir beceri alanı değildir: yürürlükteki kural "Pazarlama ve Operasyon alan değildir"
  (`GDDs/GUNCELLEMELER.md:43`); rolün anahtar ve ikincil alanı §13.4'ün sorusudur. Uygulama (yardımcı yönetmen 2026-11-14, Erdem'in
  cevabı bekleniyor): ana alan Satış, ikincil alan yok (Ekip §4.4; Tasarım ikincisi pazarlamacıyı sprint ekibine ve Ar-Ge'ye sokardı),
  müdürün etkisi Liderlik'ten. Yeni iş Pazarlama'yı yalnız iki pazarlama rolü ve kurucu tutar, alan aynasına yazmaz (pazarlamacı Satış
  masasında sayılmaz); pazarlamacı elle Satış işine konabildiği için aday eğrisi ve maaş bandı satışçınınkidir. Aynı commit `GDDs/GUNCELLEMELER.md`'ye iki ek yazar:
  ch14 §4'ün pazarlamayı EA'ya koyduğu yer Erdem'in karar 3'üyle demoya alındı (`GDDs/README.md:48`); Ekip: iki rol ve Pazarlama işi.
  `ACIK_KARARLAR.md:1370`'teki maddenin Pazarlama yarısı kapanır (karar 3 onaydır). Önce ve sonra tam paket, PROBE farkı commit mesajına.
  Kabul: `P6_atlas_sonra`.
- **E2 Atama.** Satırın yürüteni satırın kendisinde seçilir: kişi çipine tıklayınca Pazarlama işindeki kişiler ve kurucu listelenir.
  **Yürüteni olmayan satır yoktur:** Kanal ekle yürüteni seçtirerek ekler; Pazarlama'da kimse yoksa ve kurucunun payı doluysa Kanal ekle
  "Pazarlama Uzmanı gerekli" der. Kişi ayrılırsa satırları kurucuya geçer ve haftalık rapor yazar.
- **E3 Yük.** Kişinin haftasının yüzdesi [WORKING]: ücretli kanal satırı %50, İçerik ve SEO %50, E-posta %30, marka kanalının yayın
  haftası %40, kampanya hazırlığı süresince %40, çalışan kampanya %10; bütçe yükü değiştirmez. Kurucunun Pazarlama payı %50'dir.
  Tasarımcının yükü ücretli satır başına %20'dir. Kişinin yükü toplamdır; %100'ü aşan pay kadar o kişinin satırlarında tıklama bedeli
  artar (yük %140 ise ×1,4) ve satırın ipucu "Yük: Ece Arslan %140" der. Ekip şeridinde çip çubuk ve yüzde gösterir, ipucu döküm verir
  ("Arama reklamı · Moda %50, Yılbaşı hazırlığı %40"). "Bakımsız" etiketi yok (Erdem: pazarlamacı varken anlaşılmıyor). Kabul:
  `P1_kanallar_pazaryeri` %90, `P1_buyuyen_ekip` %140.
- **E4 Uzman ile müdürün farkı (Erdem sordu), oyunda.** Uzman satır yürütür. Müdür satır yürütmez:
  - Müdürlü ekipte oyuncu Pazarlama'nın **haftalık toplam bütçesini** koyar; müdür onu satırlara dağıtır: kullanıcı başı ucuz satıra
    kaydırır, doyumu %70'i geçen kategoride kısar; oyuncunun elle sabitlediği satıra dokunmaz. Dağıtımın isabeti müdürün Liderlik
    yıldızıyla artar. Müdürsüz ekipte her bütçe elle konur. Büyük ekipte satır satır bütçe angaryası böyle kalkar (ortak kural 8).
  - Radyo ve TV müdür ister.
  - Müdürsüz ekipte dördüncü uzmandan sonra her uzman için bütün satırların tıklama bedeli %10 artar [WORKING]; ipucu "Müdür yok". Bir
    müdür on uzmana yeter; on birincide ikincisi gerekir.
  - Gerçek dünyadaki karşılığı: müdür kanallar arası bütçeyi dağıtır ve uzmanları koordine eder, uzman kendi kanalının rakamını iter,
    müdür 2 ile 10 kişiyi çeker ve uzmandan %40–60 pahalıdır [T2]. Radyo ve TV şartı tasarım kararıdır.
  Kabul: `P1_buyuyen_ekip` (başlıkta "Toplam bütçe · Müdür dağıtıyor", sabitlenmiş satırda iğne).
- **E5 Ekibin büyüme yolu** (Demet, pazaryeri; tasarım önerisi, kaynaklar kadro sayısı vermiyor `2c` [DEĞERLENDİREMEM]):
  - 1 kişi: kurucu, Arama · Moda ve İçerik.
  - 5 kişi: 3 uzman (5 satır: iki kategoride arama, sosyal, içerik, e-posta), 1 tasarımcı, 1 müdür; seed sonrası ilk TV.
  - 15 kişi: 10 uzman (üç ile beş kategoride ~18 satır), 2 tasarımcı, 2 müdür, kampanya takvimi dolu.
  Artıları: aynı anda daha çok kanal ve kategori, taze görsel, CRM. Eksileri: maaş (Ekip'in üreticisinden), koordinasyon (müdür),
  doyum (aynı kategoriye daha çok para pahalı kullanıcı getirir). Fab'de kanıt kadro değil harcamaydı [T9].

## 5. Kampanyalar (K)

- **K1 Şablon galerisi.** "Kampanya kur" beş şablon gösterir; her şablon en çok iki ayar ve "İndirimi kim karşılar" ile gelir
  (istisna: İndirim günleri'nde Kargo); gerisi şablonun varsayılanıdır. Sağda "Beklenen" kartı (üç sonuç ve Net) ve ekip yükü değişimi;
  "Kampanyayı başlat". Trendyol'un satıcı paneli de şablon listesidir, kendi kampanyasını beş adımda kurar [H1, H2]. Şablonlar:
  - İlk siparişe özel: İndirim (serbest yüzde), Süre; varsayılan Şirket karşılar (tasarım kararı, kaynak yok `2d` B5).
  - İndirim günleri: Pencere, İndirim (serbest yüzde %5 ile 50), Kargo (Kurala göre · Bedava); varsayılan Yarı yarıya. Kategoriler:
    açık bütün kategoriler; katılım kategorinin marjına göre (Elektronik'te dar).
  - X Al Y Öde: Oran (3 al 2 öde · 2 al 1 öde), Pencere; varsayılan Mağazalar [H1].
  - Kupon: Tutar, Adet; Şirket öder; sepet alt sınırı tutarın dört katı, kart ve adres başına bir kupon varsayılandır [H1, D4].
  - Kurumsal hediye çeki: Paket, Kurumsal indirim (K6).
  "Kargo bedava eşiği" PAZARYERI'nin Politikalar'ındaki kargo kuralıdır, şablon değildir; "Arkadaşını davet et" derinlik listesinde
  (§14). Kabul: `P2_kampanya_sablonlar`, `P2_kampanya_indirim_gunleri`, `P2_kampanya_hediye_ceki`.
- **K2 Beklenen kartı.** Başlığı tabanını yazar: "Beklenen · geçmiş 2 kampanyaya göre"; ilk kampanyada aralık geniştir, tekrarladıkça
  daralır. Önizleme kararı tartmaya yeter (ortak kural 9: ayarların hepsinin tablosu değil).
- **K3 İndirimi kim karşılar.** "Mağazalar · Yarı yarıya · Şirket". Satıcı kendi kampanyasının indirimini öder; platform kampanyasında
  asgari indirimi yapar [H1, D4]; platformun payı kaynakta yok, oyuncunun kararıdır. Şirketin karşıladığı indirim ve kupon gelirden düşer
  (PAZARYERI ile, onay bekliyor §12). Soru §13.2.
- **K4 Takvim (2012).** Yılbaşı, Ocak sezon sonu, Sevgililer Günü, Anneler Günü, yaz sezon sonu, bayramlar, okula dönüş ve takvim dışı
  "Hemen" (rakibe cevap; hazırlık bir hafta, katılım düşük). Pencereler perakende kalıbıdır, 2012 e-ticaret kaynağı yok (`2d` B7).
  Kasım indirim günleri (Efsane Cuma, 11.11) 2012 kaynaklarında görünmüyor [H12, H14]; sonraki yıllarda "yeni gün" olarak gelebilir.
- **K5 Hazırlık.** Büyük pencerede (yılbaşı, sezon sonu) altı hafta, küçükte (Sevgililer Günü, Anneler Günü) üç, Hemen'de bir
  [WORKING]; hazırlık yürütenin yüküne %40 ekler (E3). `active_campaign()` hazırlığın yapılan ve toplam haftasını taşır; hazırlığı
  eksik kampanyada kargo darboğazı PAZARYERI'nin tarafıdır (ORTAK_ARAYUZLER).
- **K6 Kargo.** Yalnız İndirim günleri'nin "Kargo: Bedava" seçimi Politikalar'daki kargo ücreti kuralını süresince askıya alır,
  kargoyu Şirket öder (ORTAK_ARAYUZLER: ezen tek kampanya, ezdiği tek kural). Premium'un "Kargo bedava" ayrıcalığı açıksa üye
  siparişinin kargosu Premium'un satırına, kalanınki kampanyaya yazılır; kampanya raporundaki kargo gideri "üye olmayanın siparişi ×
  kargo bedeli"dir, çift yazım yok (PAZARYERI, ORTAK_ARAYUZLER).
- **K7 Kurumsal hediye çeki (demo; Erdem karar 3'te adıyla saydı).** Kampanya, kurucunun ya da satış temsilcisinin haftasından bir
  görüşme yuvası alarak kurumsal alıcılara teklif verir; kurumsal talep bayram ve yılbaşından önceki dört haftada yüksektir [WORKING].
  Satılan paketin parası bugün kasaya girer (`FinanceSystem.apply_one_time_income`), runway uzar; harcanmamış bakiye
  `GameState.marketing.gift_balance`'ta kullanıcıya borçtur; çek harcandıkça siparişin tutarı mağazaya gider, şirkete yalnız komisyon
  kalır ve PAZARYERI'nin haftalık kapanışında gelir olarak yazılır; kurumsal indirim komisyondan çıkar (%12 komisyonda %5 indirim
  kazancın ~%40'ı); süre dolunca harcanmayan pay şirkette kalır. Kapıyı açmaz. Muhasebe genel bilgidir, aranmadı. Kabul:
  `P2_kampanya_hediye_ceki` (Kasaya giren $14.250, MRR katkısı +$130/ay).
- **K8 Kupon suistimali.** Suistimal payı = aynı kart ya da adresle kullanılan kuponların payı; kart ve adres sınırı onu düşürür.

## 6. Raporlar (R)

- **R1 Kampanya sonuç kartı.** Biten kampanya Geçmiş'te tek ölçüyle (net) satırdır; tıklanınca sonuç kartı: dört kutu (yeni kullanıcı;
  "Hâlâ alışveriş yapan" haftası ve beklenen aralıkla; "Suistimal: %11" (kullanılan kuponlardan), beklenenle; maliyet ve net) ve karşı
  hamle düğmeleri ("Ürüne doğrulama ekle", "Yeniden kur"). Kart 12. haftaya kadar her hafta güncellenir; mail tekrar gelmez. Erdem kupon
  raporunun sunumunu "korkunç kötü" buldu; mail kısalır ("Net −$2.000. Suistimal %11, beklenen %4 ile 8." ve "Sonucu aç"). Kabul:
  `P5_kampanya_sonucu`.
- **R2 Doğrulama.** "Ürüne doğrulama ekle" Talepler'de "Kupon suistimali" konusunu PAZARYERI'nin seam'inden açar; plana alınırsa kademesiz
  istek kartı olarak Sepet ve Ödeme hattında sprinte girer, çıkınca suistimal payını düşürür (ne kadar: playtest). Ad ORTAK_ARAYUZLER'de
  de "Ürüne doğrulama ekle" olur.
- **R3 Haftalık rapor.** Destek raporunun kalıbı (haftada en çok bir, yalnız yeni bir şey varsa, saati durdurmaz; `SupportSystem
  .weekly_report` gibi): kullanıcı başı sıçradı, doyum, görsel yorgunluğu, yük %100'ü aştı, hazırlık başladı, deney sonucu, kişi
  ayrıldı. Düğme "Kanalları aç". Kabul: `P5_haftalik_rapor`.

## 7. ERP (B)

- **B0 Formül.** aday/hafta = bütçe ÷ aday bedeli(kanal) × ürün gücü (`SalesFaucetSystem.product_strength`,
  `sales_faucet_system.gd:165`); yıldız `star_mix_now()`'dan (`:148`) [WORKING]. Pazar kapalıyken (`market_open()` false, `:46`) ERP
  satırı eklenemez ve şartını yazar.
- **B1 Kanallar.** İçerik ve SEO (yavaş olgunlaşır: `1a` içerik 15 ay, SEO 12 ile 24 ay; aday bedeli ilk aylarda yüksektir), Arama
  reklamı (çoğunlukla 1★, durunca biter), Referans (bütçesiz, yürüten ister; haftalık aday memnuniyeti eşiğin üstündeki hesap sayısıyla
  orantılı; şartı "Memnun müşteri gerekli"), Hedef sektör (oyuncu ürünü alan sektörlerden birini seçer, URUN `erp_tasarim_2026-11-12/
  MODUL_SEMASI.md` §6; karışımı bir yıldız yukarı kaydırır [WORKING]; `spawn` isteğe bağlı sektör alır, Satış'ın seam'i, aynı commit).
  Fuar satır değildir: var olan `world/trade_fair` kartının adayları kaynak `mkt_event` taşır; dört hafta sonra rapor "Fuarın 6
  adayından 4'üyle görüşülmedi" der (fuar adaylarının çoğu takip edilmez, `1a` §5). Kaynaklar `mkt_content`, `mkt_ads`, `mkt_referral`,
  `mkt_target`, `mkt_event`; taban akış URUN'un `faucet`'i, adı "Organik".
- **B2 Satır sayıları.** BÜTÇE · ADAY/HAFTA · ADAY BAŞI · MRR KATKISI; MRR katkısı = bu kaynaktan gelip son 26 haftada imzalanan
  hesapların bugünkü MRR'ı (SQL'den kapanış ortalama 95 gün, `1a` madde 7).
- **B3 Satış'ta kaynak.** Aday satırında kaynak etiketi (Erdem beğendi, `P4_satis_sonra`); adayın sektörü ürünü alan sektörden gelir
  (URUN); aday satırında oyuncunun bilemeyeceği tanım yazmaz (ortak kural 2).
- **B4 Devir eşiği.** "Tümü · 2★ ve üstü · 3★"; yalnız pazarlama adaylarına uygulanır. Eşik altındaki adayı İçerik olgunlaştırır (dört
  haftada bir yıldız [WORKING]); olgunlaşmayan dört hafta sonra düşer ve sayılır. Bedeli morale yazar: gevşek eşikte satış temsilcisinin
  morali boşa giden görüşme başına −1 [WORKING], sıkı eşikte satırın yürüteninin morali düşen aday başına −1; seam `CharacterRegistry`.
  Başlıkta "Eşik altında N". Kabul: `P3_kanallar_erp`.

## 8. Ne kalkar

Pazarlama itkisi tek commit'te: `start_marketing_push`, `marketing_terms`, `marketing_growth_mult`, `GameState.marketing_push`
(`game_state.gd:158`, `:866`); `finance_system.gd:64-72` (sabitler) ve `:150-152` (süre sonu); `main.gd:3884` (gider karesinin
fikstürü); fiil, çip, lint, makullük, smoke: `effects.gd` :82, :89, :310; `chips.gd` :232; `lint.gd` :480, :522; `plausibility.gd`
:388; smoke :3036–3059 ve dağıtım satırı `endgame_smoke.gd:129`; iki kart (`funding/portfolio_vendor`, `rival/shutdown_notice`); motor
GDD §27.15 madde 3; kod haritası `05_fon_finans.md` (:62, :135, :187) ve `SEMBOLLER.tsv`.
- **Yeni fiil** `marketing_boost {channel, pct, weeks}`: kanalın tıklama bedelini süre boyunca düşürür, `MarketingSystem`'in seam'inden;
  çip "Arama reklamı 4 hafta %20 ucuz". İki kartın seçeneği ona bağlanır. O5 lint fikstürleri (`_bad_o5.json`, `_bad_o5_ea.json`) yeni
  fiile taşınır. Taslak commit'ten önce OLAYLAR'a gider (alan önde: `marketing_*`).
- **Ray.** `lock: "ea"` kalkar; ray kilitsiz. Sayfa Ar-Ge gibi kendi şartını yazar: "v1.0 yayında gerekli"; not ve video türlerinde
  (kalkana kadar) "Pazaryeri ya da ERP gerekli". `ModuleLocks` oyun durumu okumadığı için (`module_locks.gd:3-8`) şart sayfadadır.
  `_case_event_v3_seams` (Pazarlama'yı kapalı bekler) ve `build.last_unlocked_module` vakalarının beklentisi aynı commit'te değişir.

## 9. Sistem, kayıt, test

- `MarketingSystem` (statik `RefCounted`); durum `GameState.marketing` (kanallar, kampanyalar, geçmiş, `gift_balance`); anlamlı
  varsayılan (kanal yok); göç yok, şema artışı PAZARYERI'nin sistem commit'inde (ORTAK_ARAYUZLER).
- Tik: HR'den sonra (`time_manager.gd:408`), Satış'tan önce (`:409`), Finans'tan önce (`:416`); `marketing` kalemi her hafta, sıfır
  dahil, yeniden yazılır (gün başına).
- Okumalar: Pazarlama verir `channel_visits(kategori)` (kanal ve kampanya kimliğiyle anahtarlı), `return_lift()`, `active_campaign()`,
  `impression_share(kategori)`; PAZARYERI verir `channel_read(kategori)` (dönüşüm, aylık komisyon, organik, reklam havuzu) ve
  `source_revenue(kaynak)`; konu açma `MarketplaceSystem.open_topic`. Sinyaller `marketing_changed`, `marketplace_changed`.
- Çekirdek vakalar (CLAUDE.md §10): `marketing_burn_written_weekly` (kalem her hafta, sıfır dahil), `marketing_save_roundtrip`,
  `marketing_brand_lifts_search`, `marketing_erp_lead_source` (kaynak etiketi ve eşik).
- Bot: ERP botu seed'den sonra bir uzman alır, Arama ve İçerik satırlarını MRR'ın %5'iyle açar [WORKING]; pazaryeri botu PAZARYERI'nin
  paket 8'inde; her hafta `PROBE MKT week= spend= new= cac= mrr_add=`.
- Kare türü: `--marketing-shot=<durum>` (fikstür dünyaları: `market` 46. hafta 3 kişi, `growth` 58. hafta seed sonrası 9 kişi, `erp`
  30. hafta); durumlar §11'deki kabul tablosunda.

## 10. Commit sırası (12 commit)

1. Ekip: iki rol, Pazarlama işi, kadro grubu, GUNCELLEMELER ekleri, ACIK_KARARLAR kapanışı (§4 E1); PROBE önce ve sonra.
2. `MarketingSystem` çekirdeği: kanal, bütçe, atama, yük, Finans kalemi, kayıt, tik; çekirdek vakalar.
3. İtkinin silinmesi ve `marketing_boost` (§8), OLAYLAR'ın incelemesiyle (fiil bağlanacağı seam'den sonra iner; sıra yardımcı
   yönetmenin, 2026-11-14).
4. ERP kanalları, aday kaynağı, `spawn`'ın sektörü, devir eşiği, moral (§7); Satış'ta kaynak etiketi ve "Eşik altında".
5. Pazarlama sekmesi (ERP içeriği), ray ve sayfanın şartı.
6. Pazaryeri kanalları (dalga 5): formül, doyum, MRR katkısı, açılan satır, deney.
7. Kanal ekle, marka kanalları, görsel yorgunluğu.
8. Kampanya şablonları, `active_campaign()`, hazırlık, kargo ezmesi.
9. Kurumsal hediye çeki.
10. Sonuç kartı, haftalık rapor, doğrulama konusu.
11. Müdürün dağıtımı ve koordinasyon.
12. Bot pazarlamayı oynar; `run_gate`.
Görsel kabul arayüze dokunan commit'lerde (4–11); 2 ve 3 mantıktır (§11 muaf), kapıları koşar.

## 11. Kabul tablosu

| madde | kare | dünya | karede görülen |
|---|---|---|---|
| M1, M2, M3, E3 | `P1_kanallar_pazaryeri` | market | iki satır, "satışların %2,5'i", Ece %90 |
| M5, M6 | `P1_kanal_acik` | market | son 12 hafta, bütçe işareti, dört olgu, doyum %41, "Bir hafta durdur" |
| M1 | `P1_kanal_ekle` | market | sekiz kanal, Radyo ve TV'nin şartı |
| E3, E4, M5, M11 | `P1_buyuyen_ekip` | growth | müdür, Ece %140, toplam bütçe, iğne, doyum %86, görseller yoruldu |
| K1, K2 | `P2_kampanya_sablonlar` | market | beş şablon, iki ayar, beklenenin tabanı |
| K1, K5, K6 | `P2_kampanya_indirim_gunleri` | market | Ocak sezon sonu, Kargo, yük %90 → %130 |
| K7 | `P2_kampanya_hediye_ceki` | market | kasaya giren, MRR katkısı |
| B2, B4 | `P3_kanallar_erp` | erp | iki satır, eşik, "Eşik altında 5" |
| B3 | `P4_satis_once`, `P4_satis_sonra` | erp | kaynak etiketi; ERP alan sektörler |
| R3 | `P5_haftalik_rapor` | market | üç satır, "Kanalları aç" |
| R1 | `P5_kampanya_sonucu` | market | dört kutu, beklenen, iki düğme |
| E1 | `P6_atlas_once`, `P6_atlas_sonra` | market | iki rol |

## 12. Onay bekleyenler

- Yatırımcının "Bu büyüme kampanyadan mı?" sorusu (`vc_pitch_system.gd` `_sorgu_metrics`, `VC_Q_REPEATABLE` kalıbıyla; girdi M12) ve
  büyüme bandının ay sonu kapanışı değil ayın dört haftasının ortalamasını okuması (görüşme sistemi).
- Aylık gelirin son dört haftanın net komisyonu olması; şirketin karşıladığı indirimin ve kuponun gelirden düşmesi (PAZARYERI K12).
- Bütün [WORKING] sayılar: kanal bedelleri, doyum çarpanı, yük yüzdeleri, müdür eşiği ve çarpanı, hazırlık süreleri, TV ve radyo
  bedelleri, eşik süresi ve moral, deneyin organik payı, ERP aday bedelleri.

## 13. Açık sorular (Erdem'e)

1. **Pazaryerinde ilk büyüme işe alımı: satış temsilcisi mi, pazarlama uzmanı mı?** Önerimiz: satışçı mağaza bulur ve kurumsal hediye
   çeki satar, uzman kullanıcı bulur. Demet satışçı alırsa her hafta mağaza kazanır, kullanıcı organik büyür; uzman alırsa kullanıcı
   hızlı gelir, mağaza yavaş. Bu seçim kalsın mı?
2. **Kampanyada indirimi kim karşılar seçimi oyuncuda kalsın mı?** Önerimiz: şablonun varsayılanıyla gelir (İlk siparişe özel: Şirket;
   İndirim günleri: Yarı yarıya; X Al Y Öde: Mağazalar), oyuncu değiştirebilir. Demet Ocak sezon sonunda %20'nin yarısını karşılarsa
   mağazaların çoğu katılır ama o haftanın geliri büyümez; hiç karşılamazsa modada mağazaların yarısı katılır, elektronikte neredeyse
   hiçbiri.
3. **Derinlik listesinden (§14) hangileri demoya?** Önerimiz: kampanya haftasının trafiği ve sunucu, indirimde fiyat şişirme kuralı, B2B
   vaka çalışması. Üçü de var olan sistemlere bağlanır.
4. **Pazarlamacının yıldızı neyi ölçsün?** Bugün altı beceri var (Ürün, Tasarım, Yazılım, Test, Satış, Müşteri İlişkileri) ve kural
   "Pazarlama alan değildir". Önerimiz: Pazarlama yeni bir iş, beceri değil; uzmanın anahtar becerisi Satış, ikincisi Tasarım; müdürün
   etkisi Liderlik'ten. Demet'in 3★ Satış'lı uzmanı kullanıcıyı ucuza getirir. Yeni bir Pazarlama becerisi açarsak her kişi bir sayı daha
   taşır ve Ekip GDD'si değişir.

## 14. Derinlik listesi (gerçek dünyadan, karar doğuran ve bağlanan)

| mekanik | oyuncunun kararı | neye bağlanır | gerçek karşılığı | vay | bedel |
|---|---|---|---|---|---|
| Kampanya haftasının trafiği ve sunucu | kampanyayı TV'yle büyütmek; sunucuyu önden büyütmek ya da riski almak | ziyaret dalgası yükü artırır, %90'ın üstünde kesinti şansı büyür (`IncidentSystem.load_mult`) | kampanya haftasının trafik dalgası (`1b` E1, bugünkü ölçek); TV için aranmadı | yüksek | orta |
| Kampanya haftasında teslimat ve destek yükü | indirimin derinliği ve süresi | sipariş artınca Teslimat yavaşlar, iade ve destek bildirimi artar (`SupportSystem`) | stok biten ürün kampanyadan düşer (`1b` E3) | yüksek | orta |
| İndirimde fiyat şişirme kuralı | katılan mağazaya "son 30 günün en düşük fiyatı" kuralı koymak ya da koymamak | kural yoksa katılım artar ama haberle itibar krizi gelir (olay kartı) | Ticaret Bakanlığı uyarısı ve Reklam Kurulu cezaları (`2d` H7, H8, H10; 2021 sonrası) | yüksek | küçük |
| B2B vaka çalışması | memnun bir hesaptan vaka çalışması istemek; bedeli indirim ya da söz | o sektördeki adayların kapanış şansına yazar (`close_chance`); hesabın memnuniyeti düşerse çalışma geri çekilir | aranmadı | yüksek | orta |
| Çözüm ortağı ve mali müşavir ağı (ERP) | bayi ve mali müşavir programı kurmak; gelir payı vermek | ortağı kurucu ya da satışçı kazanır; uyumu yüksek aday getirir ama rakibi de satabilir | ortak referansı medyan 9 ayda geri öder (`1a` madde 8); bayi ağı (aranmadı) | yüksek | orta |
| Ajans mı ekip mi | bir kanalı ajansa vermek ya da uzman almak | ajans maaş yerine ücret ister, yük taşımaz, isabeti düşük | başa baş noktası kaynaklarda çelişiyor (`2c` B7) | orta | orta |
| Analist ve erken uyarı | analist almak | görsel yorgunluğunu ve kullanıcı başı sıçramasını bir hafta önce rapora yazar | analist yorgunluğu erken gösterir (`2c` T1) | orta | küçük |
| Arkadaşını davet et | davet kredisinin tutarı | iki taraflı kredi; suistimali çoklu hesap, kupon sınırıyla aynı kural | Airbnb'nin çift taraflı kredisi (`1b` E14) | orta | küçük |

## 15. İncelemenin işlenişi (Opus, 13 Kasım gece)

Karar "düzeltmeyle gönderilir"; on iki bulgunun hepsi işlendi: kareler ikinci tur olarak yeniden çekildi (1); atama, yük ve yürütensiz
satırın olmaması E2–E3 (2); müdürün oyundaki işi ve büyüme yolu E4–E5 (3); MRR katkısı gözlenen sayı, tek formül, sonuç kartında
"Hâlâ alışveriş yapan" (4); beceri sorusu §13.4, GUNCELLEMELER ve ACIK_KARARLAR E1'de (5); ERP formülü B0–B4 (6); reklam doyumunun
tanımı, marka çarpanı, deneyin son tıklama payı M4–M7, M10 (7); en çok iki ayar, "Şirket", kargo ORTAK'a uygun, tek hazırlık kuralı,
beklenenin tabanı K1–K6 (8); hediye çeki tam tanım K7, davet §14'e, WRITE-THROUGH §1 (9); silme listesi, ray, ara dönem, fiil §8 (10);
commit sırası, dalgalar, kabul tablosu, vakalar, bot, sekmenin düzeni §2, §9–§11 (11); kaynak atıfları, sayıların tabanı, iç tutarlılık,
derinlik listesi §14, ısınma kalktı (12). Alınmayan: hazırlık tek sayıya inmedi (büyük pencere altı, küçük üç, Hemen bir), çünkü kare
dünyası yılbaşı hazırlığının 46. haftada başladığını gösteriyor; ORTAK_ARAYUZLER bu sayıları `active_campaign()`'dan okur.
