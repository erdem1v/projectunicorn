# A3 · Hangi sektör hangi ERP modüllerini ister

Pazar 2 araştırması, kol A3. Erişim tarihi bütün kaynaklarda 2026-10-20. Arama: 10 WebSearch (bütçe doldu), ek olarak
WebFetch ile birincil/ikincil sayfalar okundu. Oyun koduna dokunulmadı.

Etiketler: [BOŞLUK] kanıt bulunamadı · [SIÇRAMA] kaynaktan oyuna çıkarım · [DEĞERLENDİREMEM] kaynak yetersiz ·
[GÖRÜŞ] benim yorumum · [ÇELİŞKİ] kaynaklar çelişiyor · (varsayım) kaynaksız.

## 0. Okuma uyarısı (önce bunu bilin)

- Sektör x modül verisinin büyük kısmı tek bir yerden geliyor: ERP Research sitesinin sektör sayfaları [S1-S9]. Bu site
  bağımsız karşılaştırma görünümünde ama satıcı listeleyip yönlendirme yapan bir sitedir; güveni Düşük saydım. Sayfalar
  birbiriyle tutarlı olduğu için "hangi modül hangi sektörde öne çıkar" sorusuna yön verir, ölçü vermez.
- Sektör başına "yüzde kaç firma bu modülü kullanır" gibi bağımsız anket verisi bulunamadı. Panorama'nın yıllık raporu modül
  kırılımı yayımlıyor olabilir ama arama sonucunda yalnız form arkasındaki özet çıktı [BOŞLUK]. Bu yüzden aşağıdaki
  matris (Zorunlu/Sık/Nadir) bir ÖLÇÜM değil, kaynak listelerinden yapılmış bir SINIFLAMADIR [GÖRÜŞ].
- Kaynakların tamamı 2026 durumunu anlatır. Oyun 2012'de başlıyor. Çok kanallı sipariş, pazaryeri bağlantısı, bulut ve
  mevzuat (KVKK 2016, e-belge eşikleri) 2012'de aynı değildi. Bu bir [SIÇRAMA]; çözümü bölüm 6'daki "yıla bağlı kilit".

## 1. Her sektörün çekirdeği (herkesin istediği)

Bütün sektör sayfalarında ortak çıkan dört parça: finans/muhasebe (genel defter, borç, alacak), faturalama, satın alma ve
İK/bordro.

- ERP'nin tipik modül listesi: finansal muhasebe, yönetim muhasebesi, İK, üretim, sipariş işleme, tedarik zinciri, proje
  yönetimi, CRM, tedarikçi ilişkileri, sözleşme yönetimi [S18, Orta]. Yani "çekirdek + sektör eki" yapısı ERP'nin tanımında var.
- Sektör sayfalarının hepsinde çok varlıklı (multi-entity) finans ve konsolidasyon geçiyor: perakende [S2], hizmet [S4],
  inşaat [S7], sağlık [S6], kamu [S8]. Küçük müşteri için bu "nadir", dev müşteri için "zorunlu" olur [GÖRÜŞ]; kaynak
  büyüklüğe göre ayırmıyor [BOŞLUK].
- Türkiye'de çekirdeğe e-belge de eklenir (bölüm 4): fatura, arşiv faturası, e-defter. Bu, "fatura" modülünün Türkiye'de
  mevzuatla gelen bir ek seviyesi demektir [S10, S11].

Oyuna ders:
- Çekirdek dört parça ayrı satılan modül olmamalı; "Temel paket" olarak her müşteride vardır. Oyuncu bunu her satışta
  yeniden seçmez, her satışta bir kez bakar. Karar sıklığı: yalnız ürün geliştirirken (hangi derinlik), satışta değil.
- Çekirdek zayıfsa her sektör yaşar-ölür: bu, sektör modüllerinden önce gelen en sık "yenilemede şart" konusu olabilir [GÖRÜŞ].

## 2. Sektör sektör bulgular

### 2.1 İmalat
- Çekirdek ekler: MRP (MRP/MRP II mantığı, kapasite, talep tahmini), çok seviyeli ürün ağacı ve rota, atölye emirleri,
  kalite (giriş ve süreç içi muayene, uygunsuzluk, CAPA), izlenebilirlik (lot/seri, parti soy ağacı), maliyetleme ve
  entegrasyon (MES, PLM, EDI) [S1].
- Üç alt tür: ayrık (iş emri, seri takip), süreç (reçete, verim, raf ömrü, alerjen) ve karma [S1]. Karmaşık, çok çeşitli
  üreticiler ve düzenlemeli sektörler ERP'nin yanında ayrı bir MES'e ihtiyaç duyabilir [S1]. Yani tek ERP her şeyi karşılamaz.
- Başarısız örnek: Haribo 2018, go-live sonrası stok ve hammadde izlenemedi, satışlar yaklaşık yüzde 25 düştü [S16].
  Revlon 2018: işlev sorunları yüzünden talebi karşılayacak ürün üretilemedi, yaklaşık 64 milyon dolarlık net satış etkilendi [S16].
  (İkisi de SAP; kaynak "sektöre özgü işlev eksikti" demiyor, süreç haritalama eksikliği ve işlev sorunlarını söylüyor.)

Oyuna ders: üretim modülü imalatta "hepsi ya da hiç" değildir; MRP, kalite ve izlenebilirlik üç ayrı derinlik olarak
okunabilir. Oyuncu kararı: sprintte hangisini geliştireceği (haftalar sürer, sprint başına bir kart). Müşteri isteği
sıklığı: büyük imalat hesabı yılda 1-2 kez [GÖRÜŞ].

### 2.2 Dağıtım ve lojistik
- Zorunlu çekirdek (sayfanın "temel yetenekler" listesi): lot/seri/son kullanma izleme, EDI çekirdek seti (850/855/856/810),
  nakliye ve navlun (taşıyıcı fiyatı, yönlendirme, navlun maliyeti dağıtımı), müşteri fiyatlaması, gerçek zamanlı ATP,
  doğrudan sevkiyat [S3].
- WMS ölçeğe bağlı: yaklaşık 50 toplayıcının altında ERP'nin kendi depo modülü yeter; yaklaşık 100 toplayıcı üstünde ya da
  otomasyonla ayrı WMS genelde daha iyi [S3]. İthalatçıda "maliyete katılan masraf" (landed cost: navlun, gümrük, sigorta)
  zorunluya yaklaşır [S3]. Rota teslimatı uzman, ikincil [S3].
- Türkiye: e-İrsaliye ana düzenleme alanı (bölüm 4). Yıllık brüt satışı 10 milyon TL ve üstü e-Fatura mükellefi e-İrsaliye'ye
  geçer; demir-çelik, akaryakıt, maden, şeker, gübre, meyve-sebze toptancısı gibi sektörlerde eşik aranmaz [S11, S10].

Oyuna ders: dağıtımda "depo" modülünün gereksinimi şirket büyüklüğüne göre derinleşir. Bu, Erdem'in "kural 1 kişide de 50
kişide de kırılmaz, oranla ölçeklenir" ilkesine doğrudan uyar: aynı modül küçük hesapta yeter, büyük hesapta "standardın
altı" sayılır [S3, GÖRÜŞ].

### 2.3 Perakende (mağaza)
- Temel yetenekler: POS ile gün sonu mutabakatı, çok lokasyonlu gerçek zamanlı stok, mağazalar arası transfer, fire/kayıp
  raporu, mağaza bazlı min/maks ikmal, BOPIS ve mağazadan sevkiyat için sipariş yönlendirme, alım siparişi otomasyonu, promosyon
  ve indirim yönetimi, sadakat entegrasyonu, çok varlıklı konsolidasyon [S2].
- EDI ve sadakat platformları sayfanın SSS bölümünde "ikincil" geçer; POS, e-ticaret ve 3PL/WMS en yüksek öncelikli
  entegrasyonlar [S2]. Sayfa kendi içinde sadakat konusunda çelişiyor [ÇELİŞKİ, S2].
- Başarısız örnek: Lidl 2011-2018, yaklaşık 580 milyon dolar kayıp; sistem satış fiyatıyla stok değerlerken Lidl alış fiyatıyla
  yönetiyordu, Lidl süreçlerini değiştirmek istemedi [S16]. Ders: perakende gibi alışılmış bir iş modeli "standart" ile
  çatışabilir.

Oyuna ders: perakendeci POS ve stok isteyen sektördür; üretim ya da proje ister gibi görünmemeli. Oyuncu kararı: POS
entegrasyonuna yatırım yapmak çoğu hesabı birden etkiler (sık, ama tek bir yatırım).

### 2.4 Hizmet ve danışmanlık
- Proje muhasebesi (proje bazlı gelir, maliyet, kârlılık; WIP, iş maliyeti, kazanılmış değer), zaman ve gider takibi,
  kaynak yönetimi (becerilere göre atama, planlanan/gerçekleşen/faturalanan doluluk; sayfa danışmanlık ve BT hizmetleri için
  yüzde 70-80 faturalanabilir doluluk hedefi anıyor), gelir tanıma (ASC 606 / IFRS 15) ve faturalama (kilometre taşı, saat
  bazlı, sabit ücret, abonelik, ilerleme) [S4].
- Sayfa "zorunlu/ikincil" ayırmıyor. Zorlu sorun listesi: kaynak kullanımı, proje kârlılığı, gelir tanıma, zaman/gider ve
  çok varlıklı konsolidasyon [S4].
- Stok, üretim, depo bu sektörde anlamsızdır [GÖRÜŞ].

Oyuna ders: hizmet sektörü modül olarak "zaman + proje" ister, "stok" istemez. Bu, "sektör ya ad olarak kalır ya modüllerle
anlam kazanır" sorusunda en temiz örnektir: bu müşteri kataloğunda stok modülü hiç çıkmamalı.

### 2.5 Sağlık
- ERP hastanın bakımını yönetmez; Epic, Oracle Health, Meditech gibi EHR ile gerçek zamanlı bağlanır (HL7 FHIR, arayüz
  motoru). Veri alışverişi: ücret yakalama, malzeme ana veri senkronu, maliyet merkezi, çalışan verisi [S6].
- ERP tarafı modüller: HIPAA uyumlu finans (rol bazlı erişim, denetim izi), fon muhasebesi (kâr amacı gütmeyen için), sağlık
  tedarik zinciri (sözleşme uyumu, GPO, ameliyathane malzeme tercih kartları, birim-kullanım barkod/RFID, emanet ve implant
  stoku), İK (yeterlilik/lisans takibi, vardiya, mesai, ajans personeli), biyomedikal ekipman bakımı ve kalibrasyon, gelir
  döngüsü entegrasyonu [S6].
- Düzenleme: HIPAA (korunan sağlık verisi varsa), 340B ilaç fiyatlaması, bilgisayar sistemi doğrulaması (CSV), FASB ASC 958 [S6].
  İlaç ve tıbbi cihaz üretimi ayrı: 21 CFR Part 11 ve 211, GxP/GMP, DSCSA seri numaralandırma, 21 CFR Part 820, AB MDR, UDI
  [S9]. Bunlar ABD/AB düzenlemeleri; Türkiye karşılığı [BOŞLUK] (bulunamadı).
- Türkiye: SGK ile sözleşmeli sağlık kurumları ve tıbbi malzeme tedarikçileri e-Fatura'ya SGK'ya fatura kesmeden önce geçmek
  zorunda [S11]; sağlık ve ilaç sektörü eşiksiz e-belge sayılan sektörler arasında [S10]. KVKK md. 6 özel nitelikli kişisel veri listesinde "sağlığı" ve "cinsel hayatı" sayar (ırk, din, mezhep, kılık kıyafet, dernek
  üyeliği, ceza mahkûmiyeti gibi başlıklarla birlikte) [S14]; bu verinin işlenme koşulları (md. 6 fıkra 2-3) okunmadı [DEĞERLENDİREMEM].
- Sağlık firması lojistik/dağıtım modülü almaz (Erdem'in örneği) [GÖRÜŞ]; ama sağlık tedarik zinciri (malzeme, ilaç) alır.

Oyuna ders: sağlıkta ayırt edici olan YENİ bir modül değil, mevcut modüllerin düzenlemeli derinliği (yeterlilik takibi İK'da,
ekipman bakımı varlıkta, izlenebilirlik stokta). Yani sektör "yeni modül" yerine "yeni gereksinim seviyesi" ile anlam kazanabilir.

### 2.6 İnşaat
- Zorunlu (sayfanın temel listesi): iş (job) maliyeti kod ve faz bazlı, değişiklik emri, tamamlanma maliyeti tahmini ve WIP
  fazla/eksik faturalama uyarısı, kesinti/teminat (retainage) alacak ve borçta, AIA G702/G703 ilerleme faturası, ekipman sahiplik
  ve işletme maliyeti, şantiye için mobil günlük rapor ve zaman girişi, sendikalı/sendikasız bordro ile sertifikalı bordro ve
  prevailing wage raporu, alt yüklenici uyum takibi ve lien waiver [S7].
- Satıcı ayrıntısı: Sage 300 CRE iş maliyeti, retainage, certified payroll, AIA faturalamayı yerleşik taşıyor [arama özeti, ayrı
  kaynak değil, S7 ile tutarlı]; Foundation Software certified payroll ve prevailing wage'de güçlü [aynı]. Viewpoint ayrıntısı
  bulunamadı [BOŞLUK].
- Genel amaçlı ERP'nin sık kaçırdığı şeyler olarak iş maliyeti, retainage, AIA faturalama ve WIP raporu sayılıyor [S7 ile arama
  özeti]. Bu, dikey ERP'nin değer önerisinin tam yeri.
- AIA, lien waiver, prevailing wage ABD'ye özgü; Türkiye karşılığı [BOŞLUK]. Türkiye'de inşaat demiri izleme sistemi
  yükümlüsü ve brüt satışı 1 milyon TL ve üstü olan mükellef e-İrsaliye'ye geçer [S11].

Oyuna ders: inşaat "proje maliyeti" modülünün en derin istenildiği sektördür; hizmetle aynı modül ailesi ama farklı derinlik
(retainage, WIP). Bu iki sektörü AYNI "Proje" modülüne, farklı derinlik seviyeleriyle bağlamak oyunda modül sayısını artırmadan
iki ayrı sektör kimliği verir [GÖRÜŞ].

### 2.7 Gıda
- Süreç imalat: reçete/formül yönetimi, parti izleme, verim, FEFO (ilk biten ilk çıkar), alerjen ve raf ömrü, HACCP/FSMA uyumu [S1].
- FSMA 204 Gıda İzlenebilirlik Kuralı: Gıda İzlenebilirlik Listesi'ndeki gıdalar için izlenebilirlik lot kodu, Kritik İzleme
  Olayları (hasat, soğutma, ilk paketleme, ilk karaya alış, sevkiyat, alış, dönüşüm) ve Anahtar Veri Öğeleri; kayıtlar
  FDA'ya 24 saat içinde verilmeli [S15]. Uyum tarihi FDA sayfasında 20 Ocak 2026 yazıyor, ama aynı sayfa 30 aylık erteleme önerisini
  (20 Temmuz 2028) ve Kongre'nin bu tarihten önce uygulama yapılmamasını söylediğini belirtiyor [S15]; sayfa ikisini uzlaştırmıyor
  [ÇELİŞKİ, S15]. Kural belirli bir teknoloji şart koşmuyor ama 24 saat şartı fiilen elektronik sistem gerektirir (arama özeti,
  ikincil) [S15 ile].
- Türkiye: meyve-sebze toptancı ve komisyoncularında e-İrsaliye ve e-Müstahsil Makbuzu (hal sistemi) [S11, S10]. e-Müstahsil:
  tarım ürünü alan e-Fatura mükellefi 1 Temmuz 2022'den beri elektronik [S10].

Oyuna ders: gıda, imalatın "kalite ve izlenebilirlik" derinliğini en yüksek isteyen alt türüdür. Ayrı sektör mü, imalat alt türü
mü: modül kümesi imalatla yüzde 70-80 örtüşür (varsayım). Başlangıçta ayrı sektör olarak açmak yerine imalata bağlı bir
"izlenebilirlik şartı" olarak başlaması daha ucuz [GÖRÜŞ].

### 2.8 E-ticaret
- Sipariş yönetimi (kurala dayalı yönlendirme: 3PL, iç depo, doğrudan sevkiyat), pazaryeri entegrasyonları (Shopify, Amazon,
  eBay, BigCommerce, WooCommerce), tek stok havuzu ve kanal bazlı ayırma, iade ve ters lojistik, 3PL gerçek zamanlı durum (sayfa
  bunu çoğu zaman en riskli teknik parça sayıyor), satış vergisi motoru (ABD'ye özgü); destek: kanal gelir mutabakatı, landed cost,
  talep tahmini [S5].
- Türkiye: e-ticaret aracılıkları ve internetten reklam aracıları e-Fatura'ya faaliyete başladıktan 3 ay içinde; brüt satışı 500 bin
  TL ve üstü e-ticaret yapan mükellef 1 Temmuz 2025'e kadar [S11]. Eşik tarihçesi: 2020-2021 için 1 milyon TL, 2022'den itibaren 500
  bin TL [S10].
- Yıl kayması: pazaryeri ve platform entegrasyonları 2012 için erken (varsayım).

Oyuna ders: e-ticaretin imzası modül değil entegrasyondur (pazaryeri, 3PL). Entegrasyon "uyumluluk bayrağı" olarak okunabilir:
ürün x pazaryeri bağlantısı yok ise hesap almaz. Karar sıklığı: yılda 1-2 entegrasyon yatırımı [GÖRÜŞ].

### 2.9 Kamu
- Fon muhasebesi (GASB uyumlu, fonlar arası transfer ve konsolidasyon, CAFR), ödenek bütçeleme (yıl içi değişiklik, külfet/
  encumbrance, yıl sonu devir), hibe yaşam döngüsü, ihale/satın alma (rekabetçi teklif, tedarikçi portalı, PO encumbrance), kadro
  kontrolü ve toplu sözleşmeye bağlı bordro, emeklilik katkısı, kamuya özgü amortisman ve altyapı varlığı, denetim izi, bilgi edinme
  çıktıları, vatandaş portalı, FedRAMP/GovRAMP barındırma [S8].
- Seçim tavsiyesi (arama özeti, ikincil): genel işlev genişliğinden önce fon muhasebesi uyumuyla başla.
- Bunların hepsi ABD/Birleşik Krallık çerçevesi. Türk kamu muhasebesi ve ihale mevzuatı (örneğin hangi sistem kullanılır) [BOŞLUK],
  araştırılmadı. Türkiye'de B2G fatura e-Fatura zorunlu [S13].
- Kamuda uygulama başarısını ağırlıkla kültürel etkenlerin belirlediği, 2014 tarihli bir çalışmaya atıfla [S18, Orta].

Oyuna ders: kamu hesabı en uzun satış döngüsü, en katı gereksinim ve en sıkı sözleşmeyi getirir; oyuna "yıla bağlı geç kilit"
olarak girmesi uygun [GÖRÜŞ]. Modül açısından yeni olan tek şey bütçe/ödenek ve fon; gerisi çekirdek paketin kamu derinliğidir.

## 3. Sektör x modül matrisi [V uyarı: KISMEN, tek yayıncıya (ERP Research) dayanır; 50/100 toplayıcı eşiğinin veri dayanağı yok; dokuz sayfanın yalnız biri doğrulandı]

Z = zorunlu · S = sık · N = nadir · - = o sektörde istenmez. [GÖRÜŞ]: S1-S9 sayfalarındaki "temel yetenek" listelerinden
sınıflandırma; kaynakta açıkça "zorunlu" yazıyorsa Z, listede varsa ama koşullu ise S, yalnız söz edilmişse N. Kaynağın
dayanmadığı hücreler (varsayım).

Sütunlar: FİN finans/muhasebe · FAT fatura/e-belge · SAT satın alma · İK İK/bordro · STK stok · ÜRT üretim planlama · KAL
kalite/izlenebilirlik · DEP depo (WMS) · SEV sevkiyat/nakliye · POS mağaza/POS · KNL çok kanallı sipariş · PRJ proje/iş maliyeti ·
ZMN zaman ve kaynak · VAR ekipman/varlık bakımı · BÜT bütçe/ödenek/fon.

| Sektör | FİN | FAT | SAT | İK | STK | ÜRT | KAL | DEP | SEV | POS | KNL | PRJ | ZMN | VAR | BÜT |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| İmalat | Z | Z | Z | Z | Z | Z | Z | S | S | - | N | N | - | S(v) | - |
| Dağıtım/lojistik | Z | Z | Z | Z | Z | - | Z | S* | Z | N | S | - | - | N | - |
| Perakende | Z | Z | Z | Z | Z | - | N | S | S | Z | S | - | - | N | - |
| Hizmet/danışmanlık | Z | Z | S | Z | - | - | - | - | - | - | - | Z | Z | N | - |
| Sağlık | Z | Z | Z | Z | Z | - | S | S(v) | N | N | - | N | - | Z | N |
| İnşaat | Z | Z | Z | Z | N | - | S | N | N | - | - | Z | S | Z | - |
| Gıda | Z | Z | Z | Z | Z | Z | Z | S | S(v) | N | N | - | - | S | - |
| E-ticaret | Z | Z | S | S | Z | - | N | S | Z | - | Z | - | - | - | - |
| Kamu | Z | S | Z | Z | N | - | - | N | N | - | - | S | N | Z | Z |

* Dağıtımda DEP ölçeğe bağlı: yaklaşık 50 toplayıcının altında ERP'nin kendi depo modülü yeter, 100 üstünde ayrı WMS tercih edilir [S3].
(v) varsayım: kaynak o hücreyi ayrıca söylemiyor.

Hücre dayanakları (özet):
- İmalat: ÜRT/KAL/STK/maliyet [S1]. İnşaat: PRJ/VAR/FİN(retainage)/İK(sertifikalı bordro)/ZMN(mobil zaman girişi)/KAL(punch list) [S7].
- Dağıtım: STK/KAL(lot)/SEV [S3]. Perakende: POS/STK/KNL [S2]. Hizmet: PRJ/ZMN/FAT(çok biçimli faturalama) [S4].
- Sağlık: STK(birim-kullanım)/İK(yeterlilik)/VAR(biyomedikal)/KAL(geri çağırma) [S6]. Kamu: BÜT/SAT/İK/VAR [S8].
- Gıda: ÜRT/KAL/STK(FEFO) [S1, S15]. E-ticaret: KNL/STK/SEV(iade+3PL) [S5].
- FAT sütunu Türkiye'de zorunluluktan gelir (bölüm 4); kamu "S": B2G e-Fatura zorunlu ama kamu kurumları kendi faturalamasını yapmayabilir (varsayım).

Matristen çıkan gözlemler [GÖRÜŞ]:
- Hiçbir sektör 15 modülün hepsini istemez; en çok Z alan sektör (imalat ve gıda) 8-9, en az alan (hizmet) 5.
- Sektörleri ayıran sütunlar: ÜRT (imalat, gıda), POS (perakende), KNL (e-ticaret, kısmen perakende/dağıtım), PRJ+ZMN (hizmet, inşaat),
  BÜT (kamu), VAR (inşaat, sağlık, kamu). Sağlığı ayıran tek bir sütun yok; sağlık düzenleme derinliğiyle ayrılıyor.
- Hizmette stok hiç, perakendede üretim hiç çıkmıyor: "sağlık firması lojistik modülü almaz" ilkesi matriste "-" olarak
  yazılabiliyor.

## 4. Türkiye düzenleme şartları (oyun Türk oyuncuya, ama dönem 2012'den başlıyor)

| Belge/Kanun | Kim, ne zaman | Kaynak |
|---|---|---|
| e-Fatura | Brüt satışı 3 milyon TL ve üstü (2022 ve sonrası) mükellefler; e-ticaret ve gayrimenkul/araç alım-satım-kira için 500 bin TL (2022+); 509 sıra no'lu tebliğ; ÖTV (I)/(III) sayılı mallar, hal yasası kapsamındaki meyve-sebze, SGK ile sözleşmeli sağlık kurumları eşiksiz | [S10], [S11] |
| e-Arşiv | e-Fatura mükellefi e-Arşiv'e de geçer; e-Fatura mükellefi olmayan alıcıya kesilen fatura e-Arşiv; 1 Ocak 2026'dan itibaren tutar fark etmez; basit usul ve işletme hesabı için kâğıt 3.000 TL'ye kadar 31 Aralık 2026'ya dek, tam zorunluluk 1 Ocak 2027 | [S10] |
| e-Defter | Bilanço esasına göre defter tutanlar 2025'ten itibaren; e-Fatura/e-Arşiv mükellefleri e-Fatura'ya geçtikleri yılı izleyen yıl başından (kaynak 1 Ocak 2026 diyor); bağımsız denetime tabi şirketler 1 Ocak 2021'den | [S10]; S11 e-Defter için ayrı eşik/tarih vermiyor, e-Fatura'ya bağlıyor |
| e-İrsaliye | EPDK lisanslı akaryakıt/enerji, ÖTV (III), maden, şeker, demir-çelik (GTİP 72/73), gübre takip sistemi kullanıcıları, hal sistemi meyve-sebze; ayrıca 2024 ve sonrası brüt satışı 10 milyon TL ve üstü e-Fatura mükellefi (bir yıl yerleşme gecikmesiyle, kaynak 1 Temmuz 2025 diyor); inşaat demiri izleme sistemi yükümlüleri için 1 milyon TL | [S11], [S10] |
| e-İrsaliye (güncel kayma) | Arama özeti: 2024 veya 2025 hasılatı 10 milyon TL ve üstü olanlar için 1 Temmuz 2026; belge başına 17.000 TL özel usulsüzlük cezası (2026), yıllık üst sınır 17.000.000 TL | [S21, Düşük, birincil metin doğrulanmadı] |
| e-Müstahsil Makbuzu | Tarım ürünü alıp müstahsil makbuzu düzenleyen e-Fatura mükellefi 1 Temmuz 2022'den | [S10], [S11] |
| e-SMM (serbest meslek makbuzu) | Vergiden muaf olmayan serbest meslek erbabı, faaliyetten sonraki 3. ayın sonuna kadar | [S11] |
| KVKK (6698 sayılı Kanun) | Kabul 24/3/2016, Resmî Gazete 7/4/2016 sayı 29677. Veri Sorumluları Siciline kayıt yükümlülüğü (md. 16); kişisel verinin yurt dışına aktarımı için 2/3/2024 tarihli 7499 sayılı Kanun'la değişik 9. madde (yeterlilik kararı gerekli); idari para cezaları: aydınlatma yükümlülüğü 5.000-100.000 TL, veri güvenliği 15.000-1.000.000 TL, sicil 20.000-1.000.000 TL, yurt dışı aktarım bildirimi 50.000-1.000.000 TL (kanun metnindeki tutarlar; yeniden değerleme yoluyla güncellendiği için bugünkü tutar bu değildir) | [S14, Yüksek] |

Çelişkiler/boşluklar:
- e-Fatura'nın başlangıç yılı: ecosio sayfası aynı sayfada hem 2010 hem 2014 diyor [ÇELİŞKİ, S13]. [V düzeltme] 397 sayılı tebliğ 5 Mart 2010'da e-Fatura'yı gönüllü başlattı; 13 Aralık 2011 e-Defter tebliği gönüllüydü; 421 sayılı tebliğ 14.12.2012'de dar gruplara zorunluluk getirdi (geçiş 2013/2014); ≥10 milyon TL genel grup 454 sayılı tebliğ (20.06.2015) ile 1 Ocak 2016'dan zorunlu. Ocak 2012'de hiçbir müşteriye zorunlu değil.
- e-Defter tarihi: S10 "1 Ocak 2026", S11 ayrı tarih vermiyor [ÇELİŞKİ hafif].
- Sovos 2022 yazısı [S12] ve Özbek CPA 2026 yazısı [S11] eşik tarihlerini farklı yıllara bağlıyor: eşik yıllık kayarak ilerliyor;
  güncel tarihi GİB tebliğinden doğrulamak gerekir. Birincil metin (GİB 509 sıra no'lu VUK Genel Tebliği) okunamadı [BOŞLUK].
- Türkiye'de e-irsaliye/e-fatura karşılığı olmayan sektörler (kamu muhasebesi, KVKK'nın sağlık verisi ayrıntısı) [BOŞLUK].

Oyuna ders (mevzuat):
- Mevzuat modülden ayrı bir "şart" katmanıdır: müşteri "e-Fatura çıktısı olmayan ürüne yenileme vermem" der. Bu, Erdem'in 1. kararındaki
  "yenilemede şart" biçimine (standardın altındaki şunu getirin yoksa gideriz) birebir oturur [S10, S11, GÖRÜŞ].
- Yıla bağlı kilit: KVKK 2016'da (S14) çıkıyor; oyun 2012'de başlıyor. Yani KVKK şartı 2016'dan önce hiçbir müşteride çıkmamalı;
  e-Fatura/e-Defter/e-İrsaliye eşikleri 2020'ler boyunca düşüyor (3 milyon TL, 10 milyon TL, 500 bin TL; bölüm 4) [V uyarı: 10 milyon TL e-İrsaliye eşiğidir; e-Fatura'nın 10 milyon TL eşiği 454 sıra no ile 2016'da başladı, karıştırılmamalı]. Oyuncu kararı:
  yılda bir mevzuat güncellemesi geldiğinde ürünü uyarlamak (yılda ~1 kart) [S10, S14, GÖRÜŞ].
- Mevzuat olayı "hataya mı yeni özelliğe mi bağlı" sorusunda yeni özellik tarafında: müşteri onu istediği için, hata olduğu için değil [GÖRÜŞ].

## 5. Entegrasyon ihtiyaçları

| Sektör | Zorunlu entegrasyon | Kaynak |
|---|---|---|
| İmalat | MES, PLM, IoT sensörleri, EDI (müşteri programı) | [S1] |
| Dağıtım | EDI (850/855/856/810), taşıyıcı sistemleri, ayrı WMS (büyükte), 3PL için 940/945 | [S3] |
| Perakende | POS, e-ticaret, 3PL/WMS (en yüksek öncelik); sadakat ve EDI ikincil | [S2] |
| Hizmet | CRM'den projeye devir (ikincil), analitik | [S4] |
| Sağlık | EHR (Epic, Oracle Health, Meditech) gerçek zamanlı HL7 FHIR; 340B ayrıştırma yazılımı | [S6] |
| İnşaat | filo GPS, mobil şantiye uygulaması | [S7] |
| Gıda | izlenebilirlik veri paylaşımı (GS1 lot standartları, arama özeti) | [S15 ile] |
| E-ticaret | pazaryerleri, 3PL (en riskli), vergi motoru | [S5] |
| Kamu | hibe raporlama, güvenlik sertifikalı barındırma | [S8] |

Sağlık sayfasındaki öneri: satıcının EHR entegrasyon seviyesini imzadan önce doğrula (hazır bağlayıcı / elde yazılmış eşleme /
gece dosya aktarımı); gece dosyası özet kaydına yeter, gerçek zamanlı stok ve ücret yakalamaya yetmez [S6].

Oyuna ders: "Entegrasyon" iki şekilde modellenebilir: (a) her sektörün 1-2 entegrasyon bayrağı (ürünün o sektörün sistemiyle
konuşması) ya da (b) hiç modellememek. (a) oyuncuya "hangi entegrasyonu yaptım" kararı verir ama yeni UI ister. Basitlik
ilkesi için başlangıçta (b), sonra yalnız sağlık ve e-ticarette (a) önerilir [GÖRÜŞ].

## 6. Başarısızlar ve dikey/genel ERP

Bulunanlar:
- Panorama, SAP ağırlıklı on başarısızlık listesi (2025): MillerCoors 2015, LeasePlan 2006-2019 (~119 milyon dolar), Haribo 2018,
  Waste Management 2005-2010 (500 milyon dolara varan dava; satıcının "kutudan çıktığı gibi" iddiası yanlış çıktı), Revlon 2018,
  National Grid 2009-2012 (~585 milyon dolar), Lidl 2011-2018 (~580 milyon dolar), Hershey's 1999 (100 milyon dolarlık sipariş
  stoklanamadı, hisse yüzde 8 düştü), Nike 2000-2001 (~100 milyon dolar), ABD Donanması 1998 (1 milyar doları aştı) [S16].
- Aynı kaynak: "hiçbir vaka açıkça sektöre özgü işlev eksikliğine bağlanmıyor" [S16]. En yakın uyumsuzluk Lidl (iş modeli
  standartla çatıştı) ve Waste Management (satıcının uygunluk iddiası) [S16].
- TRG International (2016): dikeye gitmek özelleştirmeyi "çarpıcı biçimde azaltır" ama ERP projelerinin yaklaşık yüzde 90'ı yine
  de bir miktar özelleştirme ister; aynı sektör içinde bile ihtiyaç değişir: Ferrari, FCA'nın geri kalanı SAP'ye giderken Infor
  LN'yi seçti, çünkü siparişe özel kişiselleştirilmiş modeli daha çevik bir sistem istiyordu [S17, Düşük-Orta].
- 2025 basın bülteni (arama özeti, tam metin 403): SAP, Oracle, Microsoft Dynamics, Infor ve Epicor/IFS gibi büyük satıcılar sektöre
  özgü çözümlere ağırlık veriyor [S20, Düşük]. Yani genel ERP dikeye yaklaşıyor; "dikey genel ERP'ye kaybediyor" ya da tersi
  için ölçülmüş bir pazar payı verisi bulunamadı [BOŞLUK].
- Türk bağlamı: Logo Yazılım (1984'te kuruldu, Borsa İstanbul'da, 1.500+ çalışan Aralık 2021, KOBİ ERP'si) [S19, Düşük]. Genel
  KOBİ ERP'sinin sektör eklentileriyle satıldığı gözlemi kaynaksız [BOŞLUK].
- "Tek modülle tüm sektörlere satmaya çalışan" satıcı: bulunamadı [BOŞLUK]. En yakın kanıt: sektör sayfaları genel amaçlı ERP'nin
  inşaat için iş maliyeti/retainage/AIA'yı sık kaçırdığını söylüyor [S7] ve karmaşık imalatın ayrı MES istediğini söylüyor [S1].
- Oyunlarda olumsuz Steam yorumu (sektör/modül derinliği "ad kalıyor" şikâyeti): bu kol için arama yapılmadı, bütçe kullanılmadı [BOŞLUK].

Oyuna ders:
- Kendi kapasitenin dışındaki bir sektöre satmak "uyum oranı düşük" bir kapanış, ürün uyumsuzluğu olarak okunur; ama bunu bir
  CEZA değil bir BİLGİ yapmalı: oyuncu satış görüşmesinde "bu müşteri bizde olmayan modülü ister" der ve teklif vermeyi seçer ya da
  geçer. Frekans: her görüşme (satış başına bir okuma) [GÖRÜŞ].
- Lidl dersi: bir müşterinin iş modeli standarttan farklıysa, "özelleştirme" teklifi iki ucu keskin: kısa vadede satış, uzun
  vadede bakım yükü. Oyuna girerse bir kerelik karar: "özel yaparım mı?" (yılda 1-2 kez). Bu Erdem'in "kopyalama yok, hız ve verim
  farkı" ilkesine dokunmadan çalışır [S16, GÖRÜŞ].

## 7. Oyunda sektörler modüllerle nasıl anlam kazanır: kaç sektör, kaç modül yeter

Öneri (başlangıç değerleri ölçülmemiştir, kalibrasyon girdisidir):

1. Müşteri = sektör + büyüklük (yıldız 1-5). Sektör, hangi modülleri isteyebileceğini belirler (matristeki Z/S/N); büyüklük
   kaç modül isteyeceğini ve koltuk sayısını belirler.
   - Temel paket (FİN+FAT+SAT+İK) her müşteride; satışta bir kez sorulur, yıllar içinde derinlik olarak yenileme şartlarında çıkar.
   - Sektör modülleri: yıldız 1 (KOBİ, 3-10 koltuk) 1 modül; yıldız 3 yaklaşık 2-3; yıldız 5 (dev, 100-1.000 koltuk) 4-6. Bu, oranla
     ölçeklenir; 1 kişilik şirket de 50 kişilik şirket de aynı kuralla işler (varsayım).
2. Sektör sayısı: ilk sürümde 6. Önerilen: İmalat, Dağıtım, Perakende, Hizmet, İnşaat, Sağlık. Gerekçe: her birinin kendi
   imza sütunu veya derinliği var (ÜRT, DEP/SEV, POS, PRJ+ZMN, PRJ+VAR, sağlık için düzenleme derinliği). Sonradan yıla bağlı
   kilitle: E-ticaret (KNL; pazaryeri çağı), Gıda (imalata izlenebilirlik şartı olarak ya da ayrı sektör), Kamu (BÜT, geç ve zor).
   Dokuz sektör aynı anda açılırsa matris okunamaz; gıda ve imalat ile e-ticaret ve dağıtım zaten örtüşüyor [GÖRÜŞ].
3. Modül sayısı: toplam 12 = 4 çekirdek + 8 sektör modülü. Önerilen sektör modülleri: Stok, Üretim, Kalite ve İzlenebilirlik,
   Depo ve Sevkiyat, Mağaza/POS, Çok Kanallı Sipariş, Proje ve Zaman (iş maliyeti + zaman/kaynak tek aile), Varlık ve Bakım;
   Bütçe/Ödenek yalnız kamu açılınca 13. modül. Matristeki 15 sütun bu yüzden birleştirilir: DEP+SEV tek, PRJ+ZMN tek [GÖRÜŞ].
   - Neden bu kadar: her sektör 2-4 ayırt edici modüle sahip olmalı, ama modül başına bir Ar-Ge/sprint kartı maliyeti var;
     12'den fazlası oyuncunun kart listesini şişirir (CLAUDE.md "olabildiğince basit" ilkesi).
4. Müşterinin istediği modüller ve koltuk sayısı satış görüşmesinde söylenir; oyuncu teklif verir (Erdem 4. karar). "-"
   hücreleri hiçbir zaman söylenmez: sağlık firması Üretim istemez [S1-S9, GÖRÜŞ].
5. Sektöre özgü düzenleme "şart" katmanı olarak gelir (bölüm 4): yenilemede ya da yeni müşteri görüşmesinde "e-Fatura çıktısı
   yoksa almam" gibi. Yıla bağlı açılır.
6. Sektörler ve standart: aynı sektördeki rakip sürümleri o sektörün modül standardını belirler (Erdem 3. karar). Sektör
   standardı modül başına bir seviye olur; yeni müşteri "bu modül bizim için önemli, sizde istediğimiz seviyede değil" der
   (Erdem 1. karar) [S3 ölçek koşulunun mekaniği ile uyumlu].
7. Basit kalması için: sektör x modül tablosu veri dosyası olur (Z=her zaman, S=olasılıkla, N=nadiren, -=hiç), ayrı UI
   gerektirmez; müşteri kartında "ihtiyaçları" satırı yeterli. Başlangıç ağırlıkları (varsayım, ölçülmedi): Z her zaman, S yüzde
   40-60, N yüzde 5-15.

Oyuna ders (özet):
| Karar | Oyuncu ne seçer | Sıklık |
|---|---|---|
| Hangi sektöre odaklanayım | Sektör matrisi + rakip standardı okuyarak | Yılda 1-2 kez (stratejik) |
| Hangi modül derinliğini geliştireyim | Sprint kartı/Ar-Ge | Her sprintte (birkaç hafta) |
| Bu müşteriye teklif vereyim mi | Müşterinin istediği modüller ve koltuk sayısı | Her satış görüşmesinde |
| Mevzuat güncellemesini ürüne yedireyim mi | Yıl kilidi | Yılda ~1 |
| Özel yapayım mı (Lidl dersi) | Büyük/tuhaf müşteri | Yılda 1-2 |

## 8. Açık sorular (Erdem'e değil, yardımcı yönetmene)

1. Sağlık için ayrı bir sektör mü, yoksa "düzenleme derinliği" bayrağı olan genel bir sektör mü?
2. Gıda imalat alt türü mü, ayrı sektör mü?
3. Kamu ilk sürümde mi, yoksa Faz sonrası yıl kilidiyle mi?
4. Çok kanallı sipariş ve pazaryeri modülü hangi yıldan itibaren açılsın? Kaynaklar yalnız 2026 durumunu anlatıyor [SIÇRAMA].
5. e-Fatura 2012 başında gönüllü olarak vardı, hiçbir müşteriye zorunlu değildi [V düzeltme]; GİB/Resmî Gazete metninin kendisi hâlâ açılmadı, iki danışmanlık özetine dayanıyor [V uyarı].

## Kaynak sicili

Erişim tarihi hepsinde 2026-10-20. "Düşük" = satıcı/lead-gen/blog; "Orta" = danışmanlık/ikincil; "Yüksek" = mevzuat/resmî.

| S# | URL | Yayıncı | Yayın tarihi | Güven | Not |
|---|---|---|---|---|---|
| S1 | https://www.erpresearch.com/industries/manufacturing | ERP Research Team (karşılaştırma sitesi) | son inceleme 2026-08-27 | Düşük | imalat modülleri, ayrık/süreç/karma |
| S2 | https://www.erpresearch.com/en-us/erp-requirements-retail | ERP Research Team | 2026-08 (inceleme 2026-08-27) | Düşük | perakende |
| S3 | https://www.erpresearch.com/en-us/erp-requirements-distribution | ERP Research Team | 2026-08 | Düşük | dağıtım, WMS eşikleri |
| S4 | https://www.erpresearch.com/en-us/erp-requirements-professional-services | ERP Research Team | 2026-08 | Düşük | hizmet/PSA |
| S5 | https://www.erpresearch.com/erp-for/ecommerce | ERP Research Team | 2026-08-27 | Düşük | e-ticaret |
| S6 | https://erpresearch.com/industries/healthcare-life-sciences/hospitals | ERP Research Team | 2026-08 | Düşük | hastane ERP, EHR entegrasyonu |
| S7 | https://www.erpresearch.com/en-us/erp-requirements-construction | ERP Research Team | 2026-08 | Düşük | inşaat |
| S8 | https://www.erpresearch.com/en-us/erp-requirements-government | ERP Research Team | 2026-08 | Düşük | kamu, fon muhasebesi |
| S9 | https://www.erpresearch.com/industries/healthcare-life-sciences | ERP Research Team | 2026-08 | Düşük | GxP, 21 CFR, DSCSA |
| S10 | https://www.parasut.com/blog/vergi-mevzuatinda-yeni-duzenlemeler | Paraşüt (bulut muhasebe satıcısı) | yapılandırılmış veride 2024-01-17, değişiklik 2026-01-19 (sayfada 08.01.2025; tarihler tutarsız) | Düşük-Orta | 509 tebliğ özetleri; birincil metin değil |
| S11 | https://ozbekcpa.com/mandatory-transition-to-e-document-applications-in-turkiye/ | Özbek CPA (mali müşavirlik) | 2026-09-24 | Orta | e-belge kapsamları, sektör listesi |
| S12 | https://sovos.com/tr/blog/kdv/hangi-sektorler-e-belge-kullanmak-zorunda/ | Sovos (e-belge satıcısı) | 2022-06-24 | Düşük | 2022 tebliğ değişiklikleri |
| S13 | https://ecosio.com/en/compliance/turkiye/e-invoicing/ | ecosio (e-fatura satıcısı) | tarih yok | Düşük | sistem adları, entegratör şartı; 2010/2014 tutarsız |
| S14 | https://www.mevzuat.gov.tr/mevzuatmetin/1.5.6698.pdf | T.C. Mevzuat Bilgi Sistemi (6698 sayılı Kişisel Verilerin Korunması Kanunu) | Kabul 2016-03-24, RG 2016-04-07 sayı 29677; 7499 sayılı Kanunla 2024-03-02 değişikliği | Yüksek | birincil metin; PDF'den pdftotext ile okundu |
| S15 | https://www.fda.gov/food/food-safety-modernization-act-fsma/fsma-final-rule-requirements-additional-traceability-records-certain-foods | U.S. FDA | sayfada "güncel: 10/08/2026" yazıyor | Yüksek | FSMA 204; uyum tarihi iç çelişkili |
| S16 | https://www.panorama-consulting.com/top-10-erp-failures/ | Panorama Consulting Group (yazar Bill Baumann) | 2025-09-09 | Orta | 10 başarısız ERP projesi, rakamlar |
| S17 | https://trginternational.com/blog/should-your-erp-system-be-vertical-specific/ | TRG International (yazar Rick Yvanovich) | 2016-12-09 | Düşük-Orta | dikey ERP; "yüzde 90 özelleştirme", Ferrari/Infor LN örneği |
| S18 | https://en.wikipedia.org/wiki/Enterprise_resource_planning | Wikipedia | sayfa okunduğu an (erişim 2026-10-20) | Orta | ERP tanımı, tipik modül listesi, kamu çalışması |
| S19 | https://en.wikipedia.org/wiki/Logo_Yaz%C4%B1l%C4%B1m | Wikipedia | erişim 2026-10-20 | Düşük | sayfada bakım etiketleri (kaynak ve ücretli düzenleme uyarısı) |
| S20 | https://www.businesswire.com/news/home/20250918489150/en | Business Wire (basın bülteni) | 2025-09-18 | Düşük | tam metin 403; yalnız arama özeti okundu |
| S21 | https://mdpgroup.com/blog/kimler-e-irsaliye-mukellefidir/ | MDP Group (danışmanlık blogu) | tarih yok | Düşük | yalnız arama özeti; 2026 kayması ve ceza tutarı doğrulanmadı |

Arama özetlerine dayanan, ayrıca okunmamış kaynaklar (yalnız yön için): ERP Research genel sektör listesi, Acumatica/Sage/Foundation
satıcı özet sayfaları, Panorama ERP raporu arşiv sayfası (modül kırılımı yok [BOŞLUK]). Bunlar yukarıda yalnızca "arama özeti" olarak
anıldı.
