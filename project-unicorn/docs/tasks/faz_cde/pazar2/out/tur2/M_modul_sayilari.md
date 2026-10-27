# M · Gerçek ERP'lerde çekirdek modül sayısı ve "modül" kavramı (Erdem soru 2: 5 / 7 / 10)

Tarih: 2026-10-20 (erişim tarihi hepsi için). Hazırlayan: araştırma ajanı M. Oyun koduna, CSV'ye, `data/`'ya yazılmadı.
Arama: 10 WebSearch (hepsi kullanıldı, hatayla dönen yok). Açılan sayfa: yaklaşık 50 WebFetch denemesi (yarısından azı sonuç verdi; geri kalanı 403/404/402, arşiv engeli ya da konuyla ilgisiz sayfa).
Not: WebFetch küçük bir model üzerinden özet döndürür; sayfa metnini harfi harfine görmedim. Sayıları "sayfa şöyle özetlendi" diye okuyun.

---

## ÖZET

1. **Gerçek dünyada "ERP'nin şu kadar modülü var" diye tek bir sayı yok.** Sayı, kimin nasıl saydığına bağlı: SAP Business One için 15 [S7, Düşük] ve 9 [S8, Düşük]; Sage Intacct için 8 çekirdek + 10 ek = 18 [S11]; Dynamics NAV 2013 R2 için 10 iş alanı ve 44 işlev alanı [S6, Orta-Yüksek]; Odoo için 50 uygulama [S2, Düşük]; SAP S/4HANA için sayı verilmeden 9 adlı alan [S9]. 5, 7 ya da 10 sayılarından hiçbiri gerçek bir "standart"a dayanmıyor; üçü de bir soyutlama tercihidir.
2. **Her listede çıkan çekirdek dardır.** Baktığım 10 katalogda (Odoo, SAP B1, NAV, BC, Acumatica, Intacct, S/4HANA, NetSuite, Mikro, Logo) Finans 10/10'da, Satın Alma, Üretim ve Proje 8/10'da, Stok 6/10'da var. İK, Depo, Mağaza ve Varlık-Bakım 10 katalogun yarısında ya da daha azında adıyla geçiyor (hesap, §2 tablosu; "adı geçmiyor" = okuduğum sayfada geçmiyor, üründe yok demek değil).
3. **Fatura ayrı modül mü?** Çoğunda Finans ya da Satış içinde (SAP B1, NAV, BC, Acumatica); yalnız Odoo (Invoicing uygulaması) ve Türk satıcılar (e-Dönüşüm ürün ailesi: ETA'da 12, Mikro'da 7 öğe) ayırıyor [S2, S14, S15]. "Fatura ve e-Belge" ayrı modül olması Türkiye dönem verisine bağlı bir tercihtir.
4. **Satıcılar modülü büyüklüğe ve sektöre göre paketliyor, tek sayıyla değil.** Mikro: Run (1-5 çalışan), Jump (5-50), Fly (50+) [S15]; Acumatica: 6 paket (Genel, İmalat, İnşaat, Dağıtım, Hizmet, Perakende) [S12]; BC: Essentials 7 alan, Premium +Hizmet +Üretim [S5]. Bu, Erdem'in B profil fikrine (soru 1) ve "5★ daha çok modül ister" kuralına gerçek dünyadan yön verir; sayı vermez.
5. **KOBİ küçük başlar.** 2011 Panorama anketinde en çok kurulan modüller: muhasebe/finans, satış-sipariş-stok, bordro/İK [S20, Orta-Düşük, sayfa açılmadı, arama özetinden]. Danışmanlar "önce finans, kalanını sonra" diyor [S30, Düşük]. Yani müşteri başına modül sayısı, kataloğun büyüklüğünden ayrı bir sayıdır.
6. **"Çok modül = kullanılmayan lisans" eleştirisi var ama zayıf kanıtlı.** Panorama (2025): "sistemin yaklaşık üçte biri atıl"; hiçbir veri dayanağı verilmiyor [S19, Düşük]. Mead & Moore ve Thirdstage'de tek örnek anekdotları var [S21, Düşük, sayfalar açılmadı]. Nicel, bağımsız bir "atıl modül oranı" bulunamadı.
7. **2012 ile bugün:** 2012 civarı yayımlanmış tek resmî belge NAV 2013 R2 (2013-12-11): 10 iş alanı [S6]. Bugünün Business Central'ı da 7+2 = 9 alan [S5]. İş alanı sayısı 13 yılda sabit kalmış gibi; büyüyen şey her alanın derinliği ve ek uygulama sayısı (Odoo: 50 uygulama [S2]) [SIÇRAMA: iki ürün ailesi aynı şirketin ardışık ürünüdür ama aynı sayma yöntemi değil].
8. **Oyun karşılaştırması:** üç yönetim oyunu da neredeyse aynı beğeni oranında: Software Inc 94% (5.638 İngilizce yorum), Game Dev Tycoon 94% (22.236), Mad Games Tycoon 2 93% (2.229) [S24, S25, S26]. Yani kalem sayısı tek başına beğeniyi açıklamıyor. Kalem sayısını yazan bir kaynak bulunamadı (ne GDT'nin konu/tür sayısı ne Software Inc'in ürün türü sayısı).
9. **Olumsuz yorum örneğinde şikâyetin türü oyuna göre değişiyor** (en yararlı 50 kadar olumsuz yorum, sınıflama benim/model tahminim, Düşük) [S27]: Software Inc'de yaklaşık 25/51 yorum karmaşık, bunaltıcı ya da angarya; Game Dev Tycoon'da yaklaşık 8/50 angarya ama yaklaşık 25/50 sığ ya da tekrarlı; Mad Games Tycoon 2'de yaklaşık 12/49 bunaltıcı, yaklaşık 15/49 sığ. Yorumlar yalnız olumsuz ve "en yararlı" sırasıyla: tüm oyuncuyu temsil etmez [SIÇRAMA uyarısı].

**Oyuna ders**
- **D1. 5 / 7 / 10 sorusunu "gerçek dünya kaç diyor" diye çözmeyin; gerçek dünya bunu söylemiyor.** Kanıt yalnız şunu söylüyor: Finans her yerde, Satın Alma, Üretim, Proje çoğunda, Stok yarıdan fazlasında var; İK, Depo, Mağaza, Varlık satıcıdan satıcıya değişiyor. Karar tasarım kararıdır, oyuncuya göstermek için sayılar §4'te.
- **D2. Katalog büyüklüğü ile müşteri başına modül sayısı iki ayrı karardır.** Oyuncuyu etkileyen sayı her adayda göreceği satır sayısıdır (1★ 2-3, 5★ 7-10; SENTEZ §4.1); katalog 5 ise 5★'ın "7-10 modül ister" kuralı kurulamaz.
- **D3. Sektör profilleri ancak 10'da tam kurulur.** Benim hesabıma göre (SENTEZ §3.2'nin 7 profil tablosuyla): 5 modülle 7 profilden en çok 1'i tam karşılanır, 7 modülle en çok 3'ü, 10 modülle 7'si (§4.1). Bu hesap SENTEZ'in kendi tablosuna dayanır (döngüsel, [WORKING]).
- **D4. Fatura ayrı modül kalacaksa gerekçesi dönemdir (e-Belge 2016 sonrası), "gerçek ERP'ler de ayırıyor" değil.** Çoğu satıcı faturayı Finans ya da Satış içinde tutuyor.
- **D5. Çok kalemin zararı 1 kişi/50 kişi ölçeğinde bakılmalı:** katalog 10 ve ekip 50 kişiyse modül başına ortalama 5 kişi; katalog 5 ise 10 kişi (hesap). Angarya riskini kataloğun büyüklüğü değil, oyuncunun her hafta tek tek bakması gereken modül sayısı belirler (Software Inc'de en sık şikâyet bu) [S27].
- **D6. Ölçülemeyen yer:** hiçbir kaynak "oyuncu aynı anda kaç kalemi angarya hissetmeden yönetir" sorusuna sayı vermiyor. Bu bir playtest sorusudur (sayı yazılmaz).

---

## 1. Gerçek ERP çekirdek modül sayıları

"Sayı" sütunu kaynağın verdiği sayıdır; "Nasıl sayıldı" sütunu o sayının neyi kapsadığını söyler. 2012 ile bugün ayrı satırlarda; 2012 satırı yoksa "bulunamadı" yazıldı.

| Satıcı / ürün | Dönem | Sayı | Nasıl sayıldı | Kaynak | Güven |
|---|---|---|---|---|---|
| Wikipedia "ERP" | 2026 (pazar tahmini yılı) | Sayı yok | "Birçok ERP sisteminde bu alanlar ERP modülü olarak gruplanır": finansal muhasebe, yönetim muhasebesi, İK, imalat, sipariş işleme, tedarik zinciri, proje yönetimi, CRM (ERP sayılması tartışmalı), SRM, diğer. Kaç modül olduğu yazmıyor. | [S1] | Orta |
| Odoo (OpenERP 7.0) | Aralık 2012 | Resmî uygulama sayısı bulunamadı. Ocak 2013 haberi: "2.800'den fazla modül ve topluluk uygulaması" (resmî + topluluk karışık). Standart modül kategorileri: muhasebe ve finans, İK, yerelleştirme, imalat, proje yönetimi, satın alma, satış, araçlar, depo | Haber metni (yalnız arama özeti, sayfa açılmadı) | [S22] | Orta-Düşük |
| Odoo (eski sürüm forumu) | tarihsiz | Bir kurulumda "178 uygulama/modül" | Bir kullanıcının Settings > Apps ekranı; sürüm yazılmamış; resmî sayı değil | [S23] | Düşük |
| Odoo 17/18 (bugün) | Odoo 18 belgeleri (sürüm 18, 2024 sonu); tarihsiz "All apps" sayfası | **50 uygulama** (All apps, 9 kategori: Website 6, Sales 5, Finance 7, Inventory & Manufacturing 6, HR 7, Marketing 6, Services 6, Productivity 6, Customization 1). Belge kenar çubuğu: Finans 4, Satış 6, Web 6, Tedarik zinciri 8, İK 10, Pazarlama 7, Hizmetler 5, Verimlilik 12 giriş | "One need, one app" bölümündeki kutuların sayımı; belgede bazı girişler uygulama değil rehber | [S2, S3] | Düşük (satıcı) |
| Odoo (genel bilgi) | 2025 | Çekirdek + resmî uygulama + topluluk modülü; 19.0 Eylül 2025'te çıktı; "18 çekirdek bileşen" (CRM, muhasebe, envanter, proje yönetimi vb., tarihsiz liste) | Wikipedia | [S4] | Orta |
| SAP Business One | 2022 | **15** (Administration, Financials, CRM, Sales A/R, Purchasing A/P, Opportunities, Banking, Business Partners, Production, Resources, Inventory, Project Management, MRP, Service, Human Resources) | Bir SAP iş ortağının blog sayımı | [S7] | Düşük |
| SAP Business One | 2024 | **9** (Finance and Controlling, CRM, Sales, Purchasing, Banking, Inventory, Production, HR, Reports); yazı "ondan fazla ana modül" diyor ama dokuz sayıyor | Danışman blog | [S8] | Düşük |
| SAP Business One (2012) | 2012 | Bulunamadı | | | |
| SAP S/4HANA | 2015 çıkış (şubat 2015 şirket içi, mayıs 2015 bulut); bugün | Sayı verilmez. Adlı işlev alanları 9: finans, muhasebe, kontrolling, satın alma, satış, imalat, tesis bakımı, proje sistemi, ürün yaşam döngüsü. İK ve tedarik zinciri ayrı ürünlere bağlı (SuccessFactors, SCM) | Wikipedia cümlesi | [S9] | Orta |
| Oracle NetSuite | bugün | Sayı yok. Çekirdek finans (GL, AP, AR, nakit, vergi, satın alma, sabit kıymet, gelir tanıma, bütçe, abonelik faturalama); isteğe bağlı: CRM, e-ticaret, İK ve iş gücü, bordro, PSA, depo yönetimi, tedarik zinciri, OneWorld | Wikipedia | [S10] | Orta |
| NetSuite | FY2015 | 5 dikey sürüm (SENTEZ A1-S10 ve V #5'ten devralındı; bu turda yeniden açılmadı) | | A1-S10 | V doğruladı |
| Microsoft Dynamics NAV | NAV 2013 R2 belgesi, 2013-12-11 (2012 dönemine en yakın resmî belge; "NAV 2012" adlı sürüm kaynaklarda geçmedi: bulunamadı) | **10 iş alanı, 44 işlev alanı**: Finans Yönetimi 6, Satış ve Pazarlama 5, Satın Alma 5, Depo 5, İmalat 6, İşler (Jobs) 4, Kaynak Planlama 4, Hizmet 4, İK 3, BT Yönetimi 2 | Microsoft'un arşiv belgesi tablosu; toplamı ben topladım | [S6] | Orta-Yüksek |
| Dynamics AX | bugünkü Wikipedia anlatımı | "19 çekirdek modül" | Wikipedia | [S5] | Orta |
| Dynamics 365 Business Central | bugün | Essentials: finans, satış, pazarlama, satın alma, envanter, depo, proje yönetimi = 7 alan. Premium: +Hizmet yönetimi, +İmalat = 9 alan | Wikipedia (NAV sayfası) | [S5] | Orta |
| Sage Intacct | bugün | **18 işlev alanı: 8 çekirdek + 10 ek** (çekirdek: hesap borç, alacak, nakit, işbirliği, defter, sipariş, satın alma, rapor; ek: sözleşme/abonelik faturalama, gelir yönetimi, sabit kıymet, envanter, çoklu şirket, proje muhasebesi, proje faturalama, vergi, zaman-gider, tedarikçi ödeme) | Wikipedia | [S11] | Orta |
| Acumatica | bugün | **6 paket**: Genel İş, İmalat, İnşaat, Dağıtım, Profesyonel Hizmet, Perakende; modüller paketler arasında tekrarlıyor (ör. CRM, finans) | Satıcı sayfası, paket başlıkları | [S12] | Düşük |
| Epicor, Infor | bugün | Bulunamadı (Wikipedia'da modül listesi yok; resmî sayfalar 403/404 döndü) | | | |
| Sage 50 | | Bulunamadı (açılmadı) | | | |
| Logo (Tiger, Go, Netsis) | bugün | Tam modül listesi bulunamadı. Netsis Wings Entegre: satın alma, üretim (isteğe bağlı), muhasebe ve finans, bankacılık, sabit kıymet, satış temsilcisi, seri/lot, raporlama. Açılan "Edge N-Series" sayfasında ek modüller: maliyet muhasebesi, e-Dönüşüm, üretim, ileri üretim planlama, MRP, makine bakımı, dış ticaret, POS | Arama özeti + ürün sayfası; Edge N-Series Tiger/Go/Netsis değil, başka bir ürün serisi | [S18] | Düşük |
| Mikro | bugün | Modül sayısı yok. **Üç boyut sürümü**: Run (1-5 çalışan), Jump (5-50), Fly (50+); Jump Basic ERP "stok, finans, satış, e-dönüşüm". 8 çözüm alanı (gelir-gider, stok, e-dönüşüm, üretim, tahsilat, e-ticaret, perakende, raporlama); 7 e-dönüşüm bileşeni; 8 sektör çözümü | Satıcı sayfası | [S15] | Düşük (olgu: sürüm adları ve aralıkları Orta) |
| ETA | bugün | 3 ana ürün (V.11 PRO, V.11, V.11 SB), 8 çözüm (CRM, İK, restoran, iş zekâsı vb.), 12 e-dönüşüm ürünü. Modül adları ana sayfada yok | Satıcı sayfası | [S14] | Düşük |
| Nebim | bugün | 3 ana ürün (V3 ERP, ERA, yapay zekâ), 5 adlı modül/çözüm (CRM, taksitli satış, optik, üretim, çok uluslu operasyon); 5 sektör odağı (hazır giyim, halı-mobilya-züccaciye, üretim, optik, ticaret) | Satıcı sayfası | [S17] | Düşük |
| Uyumsoft | bugün | ERP programı altında 3 ürün (LioX ERP, LioX HR, LioX CRM); modül sayısı verilmiyor | Satıcı sayfası | [S16] | Düşük |
| Zirve | | Açılmadı | | | |
| ERP Research (toplayıcı) | 2026 | Kendi sabit 14 modül sınıflaması: Finans ve muhasebe, satış, envanter, imalat, tedarik zinciri, e-ticaret, İK ve bordro, proje yönetimi, satın alma, depo, kalite, saha hizmeti, iş zekâsı, varlık yönetimi. Odoo 14/14, SAP B1 13/14, NAV 14/14 (3 güçlü, 7 orta, 4 temel), NetSuite 14/14 (7 güçlü) | Satıcı eşleştirme sitesi; V #13 "tek yayıncı" | [S13] | Düşük |

**Okuma (benim yorumum, [GÖRÜŞ]):** sayılar 6'dan 82'ye kadar değişiyor çünkü üç farklı şeyi "modül" diye sayıyorlar: (a) iş alanı (NAV'ın 10'u, BC'nin 9'u, S/4HANA'nın 9'u, Acumatica'nın 6 paketi), (b) satın alınan uygulama/lisans kalemi (Odoo'nun 50'si, Intacct'ın 18'i), (c) yayıncının kendi sınıflaması (ERP Research'ün 14'ü). Oyundaki "hat" kavramı en çok (a)'ya benziyor: bir müşterinin "bu alanı ister mi" diye baktığı birim. Aynı sınıfta gerçek sayı **6 ile 10 arası** (NAV 10, BC 9, S/4HANA 9, Acumatica 6, Mikro 8 çözüm alanı) [hesap, S5 S6 S9 S12 S15]. Bu 5, 7 ve 10'un üçünü de aşağı yukarı kapsayan aralık: "10 gerçekçi değil" ya da "5 yetersiz" diyemeyiz.

**Oyuna ders (§1):** Sayı hangi birimi sayıyorsunuz sorusuna bağlıdır. Oyunda "modül" bir müşterinin satın alıp memnuniyetini ölçtüğü iş alanı olacaksa gerçek karşılığı 6-10 arasıdır; 18-50'lik sayılar lisans kalemleridir ve oyuna karşılık gelmez. Bu, kararı etkilemez: 5, 7 ve 10'un hepsi "iş alanı" birimiyle savunulabilir.

---

## 2. Ortak çekirdek ve SENTEZ §3.1'in 10 modülüyle örtüşme

Aşağıdaki tablo benim eşlemem ([GÖRÜŞ]): her hücre okuduğum sayfaya bakarak ✓ (modül adıyla ya da açık karşılığıyla var), ~ (başka modülün içinde ya da yakın karşılığı), – (okuduğum sayfada adı geçmiyor; üründe olmadığı anlamına gelmez). Kısaltmalar: Fin = Finans ve Muhasebe, Fat = Fatura ve e-Belge, Sat = Satın Alma, İK = İK ve Bordro, Stok, Üre = Üretim, Depo = Depo ve Sevkiyat, Mağ = Mağaza ve Kanal, Proje = Proje ve Zaman, Var = Varlık ve Bakım.

| Katalog | Fin | Fat | Sat | İK | Stok | Üre | Depo | Mağ | Proje | Var | Dayanak |
|---|---|---|---|---|---|---|---|---|---|---|---|
| Odoo (bugün) | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ~ | ✓ | ✓ | ✓ | S2, S3 |
| SAP Business One (2022 listesi) | ✓ | ~ | ✓ | ✓ | ✓ | ✓ | – | – | ✓ | – | S7 |
| Dynamics NAV 2013 R2 | ✓ | ~ | ✓ | ~ (izin ve çalışan; bordro adı yok) | ~ | ✓ | ✓ | – | ✓ | ~ (sabit kıymet) | S6 |
| Business Central | ✓ | ~ | ✓ | – | ✓ | ✓ | ✓ | – | ✓ | – | S5 |
| Acumatica | ✓ | ~ | ✓ | ~ (bordro) | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | S12 |
| Sage Intacct | ✓ | ✓ | ✓ | – | ✓ | – | – | – | ✓ | ~ | S11 |
| SAP S/4HANA | ✓ | ~ | ✓ | – | – | ✓ | – | – | ✓ | ✓ | S9 |
| NetSuite | ✓ | ~ | ✓ | ✓ | ~ | – | ✓ | ✓ | ✓ | ~ | S10 |
| Mikro | ✓ | ✓ | – | – | ✓ | ✓ | – | ✓ | – | – | S15 |
| Logo (Edge N-Series sayfası) | ✓ | ✓ | – | – | – | ✓ | – | ~ | – | ✓ | S18 |
| **✓ sayısı (10 katalogdan)** | **10** | **4** (+6 ~) | **8** | **3** (+2 ~) | **6** (+2 ~) | **8** | **4** (+1 ~) | **4** (+1 ~) | **8** | **4** (+3 ~) | |

(Toplamları ben hesapladım. Sayfaların bir kısmı ana sayfa özeti olduğu için "–" hücreleri eksik okuma olabilir; özellikle Mikro, Logo, S/4HANA ve Intacct satırları.)

**Ne çıkıyor:**
- **Her listede çıkan çekirdek:** Finans (10/10). Satın Alma, Üretim, Proje 8/10. Stok 6/10 (+2 yakın). Bu dört-beş kalem Wikipedia'nın ERP tanımıyla da uyuşuyor: finans, imalat, sipariş işleme, tedarik zinciri, proje [S1].
- **İK her yerde zayıf:** adı geçen 3 katalogda bile ERP Research onu "temel" ya da "orta" derecelendiriyor; SAP B1'de 4 belgelenmiş yetenek, Odoo'da 2, NAV'da "temel" [S13]. S/4HANA'da İK ayrı ürün (SuccessFactors) [S9], Logo'da bordro ayrı program [S18 menü]. SENTEZ'in "İK ve Bordro, 2★ ve üstü herkes ister" kuralı müşteri davranışı olarak savunulabilir, ama bir ERP modülü olarak gerçek ürünlerde zayıf ve sıklıkla ayrı bir ürün [GÖRÜŞ].
- **Depo, Mağaza, Varlık-Bakım en az evrensel olanlar** (4/10). Depo, NAV, BC, Acumatica, NetSuite'te ayrı; Odoo, SAP B1'de Envanter içinde. Mağaza ve Kanal yalnız Odoo, Acumatica, NetSuite, Mikro'da. Bu üçü sektör profili modülleridir; zaten SENTEZ onları "profile göre" yapıyor.
- **Fatura ayrı uygulama olarak yalnız Odoo, Intacct, Mikro, Logo'da;** NAV, BC, SAP B1'de Satış/Alacak ve Finans içinde [S2, S6, S7, S5]. Türk satıcılar e-Belge'yi ayrı paket yapıyor: ETA 12, Mikro 7 e-dönüşüm öğesi [S14, S15]. 2012 için Türk e-Belge sayısı: bulunamadı.

### 2.1 5 / 7 / 10 kümelerinin örtüşmesi

**Sınırlama:** Soru 2'nin A ve B kümelerinin içeriği SENTEZ'de açık yazılı değil (yalnız "A ve B, C'nin alt kümesi" [SENTEZ §3.1]). Burada her sayı için iki ölçüt koydum: (1) gerçek katalogların ortak çekirdeği, (2) SENTEZ §3.2'deki 7 sektör profilinin "her zaman ister" sütunu. Küme içeriğini ben seçtim (varsayım); kimin seçtiğinden bağımsız olarak profillere kaç tanesinin tam oturduğunu gösteriyorum.

Bugünkü oyunda ERP'nin beş kimlik hattı var: Nakit Akışı, Veri Girişi, Defter, Stok, Fatura; 5 × 3 kademe = 15 kademe [K §3.4, satır 148]. SENTEZ bunları gerçek dünya adlarına çevirince dört modül çıkıyor: Defter ile Nakit Akışı "Finans ve Muhasebe"de birleşiyor, Veri Girişi "Satın Alma" oluyor [SENTEZ §3.1]. Yani "5" seçeneği bugünkü beş hattı koruyorsa bu, gerçek ERP adlarıyla 4 modül demektir. Bu fark Erdem'e gösterilmeli.

Benim hesabım (python ile 10 modülün tüm alt kümelerini taradım; İK her sette zorunlu; "tam karşılanan" = profilin "her zaman ister" listesinin tamamı sette):

| Küme boyutu | En iyi küme (profil kapsamı için) | Tam karşılanan profil (7 üzerinden) | Ortalama kapsam | Hangi profiller eksik kalır |
|---|---|---|---|---|
| 5 | Fin, Fat, Sat, İK, Proje | 1 (Hizmet) | %66 | İmalat Üretim'siz, Dağıtım Stok ve Depo'suz, Perakende, E-ticaret, İnşaat Varlık'sız, Sağlık Stok ve Varlık'sız |
| 7 | Fin, Fat, Sat, İK, Stok, Proje, Varlık | 3 (Hizmet, İnşaat, Sağlık) | %86 | İmalat (Üretim yok), Dağıtım (Depo yok), Perakende ve E-ticaret (Mağaza yok) |
| 10 | hepsi | 7 | %100 | yok |

Alternatif 7: Fin, Fat, Sat, İK, Stok, Depo, Mağ: 3 profil tam (Dağıtım, Perakende, E-ticaret), %84. Hangi 7 seçilirse seçilsin üç profile kadar [hesap]. Bu hesabın döngüsel olduğunu unutmayın: profil tablosunun "her zaman ister" sütunu SENTEZ'in kendi [WORKING] sınıflaması, kaynağı tek yayıncı [V #13].

**Ayrıca iki ölçek hesabı (hesap):**
- Kademe yükü: bugünkü kademe üst sınırı 3 [K §3.4]; 5 modül 15, 7 modül 21, 10 modül 30 kademe. SENTEZ K1-K10 öneriyor [WORKING, SENTEZ §3.3]; o zaman 50, 70, 100 kademe, her biri bir kart ve Ar-Ge kapısı gerektirir. Rakipler de aynı kataloğu yürüttüğü için standart (medyan) hesabı da modül sayısıyla orantılı büyür.
- Ekip başına düşen modül: 1 kişide 3-4 modül SENTEZ'e göre oynanabilir [SENTEZ §3.4]; 50 kişide 10 modül modül başına ortalama 5 kişi, 5 modül başına 10 kişi (eşit dağıtım varsayımı).

**Oyuna ders (§2):** 10, SENTEZ'in 7 sektör profilini gerçekten ayırt edebilen tek sayı; 7'de en çok üç profil tam kurulur, 5'te en çok bir. Buna karşı gerçek dünyada çekirdeği oluşturan ortak küme 5 modüle bile gerekmiyor (Finans, Satın Alma, Stok, Üretim, Proje). Yani "5" gerçek çekirdeğe yakın ama "sektör seç" kararını (soru 1, B profili) taşımaz; "10" sektör kararını taşır ama gerçek dünya katalogları aynı anda 10'u evrensel saymıyor.

---

## 3. Oyunlardaki kalem sayıları ve oyuncu tepkisi

**Kalem sayısı bulunamadı.** Game Dev Tycoon'un konu, tür, motor özelliği sayısı; Software Inc'in ürün türü ve özellik sayısı; Mad Games Tycoon 2'nin motor özelliği sayısı: arama (1) ve Wikipedia/Steam sayfaları sayı vermedi; fandom wiki 402 döndü. Hiçbir sayıyı model bilgisiyle yazmadım.

Bulunan olgular:
- **Game Dev Tycoon** (2013-08-29): konu, tür, platform, motor seçilir; araştırmayla yeni konu ve tür açılır [S29, arama özeti S31]. Steam 94% olumlu (22.236 İngilizce yorum); Metacritic PC 68 [S25, S29]. Yani bu, az kalemli bir oyun.
- **Software Inc** (2015-05-01, erken erişim): ofis 10 kata kadar, kişiler ekiplere bölünür, ürünler, markalar, sunucular, destek personeli yönetilir; kalem sayısı yazılmıyor. Steam 94% (5.638 İngilizce yorum) [S24].
- **Mad Games Tycoon 2** (2023-05-31): 1976-2020 arası başlangıç, oyun türleri (MMO, ücretsiz, mobil, arcade, eklenti, devam, remaster, port), lisans, IP, motor, donanım, ofis, 100 rakibe kadar. Steam 93% (2.229 İngilizce yorum) [S26].

**Oyuncu tepkisi (en yararlı olumsuz yorumlar; Steam API, 100 istendi, yanıt kısaldı: Software Inc 51, GDT 50, MGT2 49 yorum okunabildi; sınıflama benim/model tahminim; yaklaşık sayılar):**

| Oyun | Yorum | Bunaltıcı / angarya / karmaşık | Sığ / tekrarlı | Hata | Belirsiz, ne işe yaradığı belli değil | UI / öğretici |
|---|---|---|---|---|---|---|
| Software Inc | 51 | ~25 | ~15 | ~6 | | ~18 |
| Game Dev Tycoon | 50 | ~8 | ~25 | 2 | ~14 | |
| Mad Games Tycoon 2 | 49 | ~12 | ~15 | ~9 | ~11 | |

[S27]. Örnek alıntılar (oynama süresiyle): Software Inc: "the extreme level of micromanagement renders this too overwhelming and boring for me" (78 sa), "it can feel extremely tedious to do" (33 sa); GDT: "There's no depth to management and nothing meaningful you can do when designing games" (28 sa), "It feels more like solving a Soduko than developing games" (26 sa); MGT2: "It's really tedious and unimaginative" (32 sa), "I really don't know what I need, what is important and what the hell is this for?" (19 sa). 
**Dikkat:** (1) yalnız olumsuz yorumlar, "en yararlı" sırasıyla; (2) sınıflamayı bir model yaptı, sayılar ±birkaç; (3) tüm oyuncuyu temsil etmez [SIÇRAMA]. Olumsuz oran: Software Inc ~%6, GDT ~%6, MGT2 ~%7 (100 − olumlu). Mesela Software Inc'de yaklaşık yarısı karmaşıklık şikâyeti olsa bile bu ~%3 oyuncu demektir (hesap, örneklemin temsiliyeti varsayımıyla).

Üçüncü taraf özet (AI üretimi, Düşük): Software Inc'de "yeni başlayan için bunaltıcı karmaşıklık, karışık arayüz, etkisiz öğretici" [S28]. Tek anekdot: 2019'da bir oyuncu "iki ekipte 12 kişiyi yönetmek kâbus" diyor, başka biri rutin kurunca kolaylaşıyor diyor (arama özeti, sayfa açılmadı; Düşük).

**Okuma ([GÖRÜŞ]):**
- Az kalemli oyunda (GDT) olumsuzun yarısı "sığ ya da tekrar", kalem çok oyunda (Software Inc) yarısı "karmaşık, bunaltıcı, UI". Bu iki uç, "az kalem = derinlik yok" ve "çok kalem = angarya" korkusunun ikisinin de gerçek oyuncu şikâyeti olduğunu gösteriyor, ama ikisi de oyunun %6'sında ortaya çıkıyor ve beğeni oranı üçünde de 93-94%.
- Şikâyet "kalem sayısı"ndan çok **kalemin ne işe yaradığının belli olmaması** (GDT ve MGT2'de "unclear/unexplained") ve **arayüzün yoğunluğu** (Software Inc'de UI ~18/51) etrafında. Kalem sayısının kendisini suçlayan yorum azınlıkta.
- Software Inc'de en bunaltıcı bulunan yer kalemin sayısı değil sürekli yönetim ihtiyacı: "there is no way to opt out of these mechanics" [S27]. Yani opt-out edilebilirlik angaryayı belirliyor, sayı değil [SIÇRAMA: tek alıntıdan].

**Oyuna ders (§3):** Kataloğun 5 mi 10 mu olduğu, oyuncunun hissedeceği angaryayı tek başına belirlemez; belirleyen, (a) her modülün ne işe yaradığını müşteri cümlesinin söylemesi (SENTEZ zaten böyle tasarlamış), (b) oyuncunun bakmak zorunda olmaması (opt-out), (c) arayüz yoğunluğu. Az kalem riski: "derinlik yok", özellikle 104 hafta sonrasında; çok kalem riski: ilk 20 hafta bunaltı. Hangisinin ağır bastığı playtest sorusu.

---

## 4. Oyuna ders: 5 mi 7 mi 10 mu

### 4.1 Kanıtın söylediği

1. **Gerçek dünyada sayı sabit değil; birime bağlı** (§1). Aynı sınıfta (iş alanı) 6-10 arası [S5, S6, S9, S12, S15]. 5, 7, 10'un hepsi bu sınıfın içinde ya da hemen yanında.
2. **Çekirdek dar:** Finans her yerde, Satın Alma, Üretim, Proje çoğu yerde, Stok yarıdan fazlasında (§2).
3. **Küçük müşteri az modülle başlar:** Panorama 2011'de finans, satış-sipariş-stok, bordro [S20]; Mikro'nun en küçük sürümü Basic ERP: stok, finans, satış, e-dönüşüm (4 öğe) [S15]; BC Essentials 7 alan [S5]. Bu, "1★ 2-3 modül" kuralını destekler (yön; ERP'ye özgü sayı yok).
4. **Büyük müşteri çok alanlı paket alır:** NAV 10 iş alanı, Acumatica 6 paket, Odoo 50 uygulama (§1). "5★ 7-10 modül" kuralı kataloğun en az 10 olmasını ister; 7'lik katalogda 5★ "tüm modüller" demek olur.
5. **Sektör paketleme gerçek:** Acumatica, Mikro, Nebim sektör odaklı sunuyor [S12, S15, S17]; NetSuite'in 5 dikey sürümü ([A1-S10]). Bu soru 1'in B profili için gerçek dünya dayanağıdır.

### 4.2 Kanıtın söylemediği

1. **Hangi sayının daha iyi oyun olduğunu söylemez.** Kalem sayısı üzerine oyun verisi (konu sayısı, özellik sayısı) bulunamadı; oyun yorumları yalnız şikâyet türünü gösteriyor.
2. **5 modül + 7 sektör profili birlikte nasıl çalışır** sorusunu gerçek veri yanıtlamıyor: sektör × modül matrisi tek yayıncıdan [V #13].
3. **Türkiye 2012:** Logo Tiger/Go, Zirve, Uyumsoft'un 2012 modül listesi bulunamadı; e-Belge öncesi Türk ERP'sinde Fatura'nın ayrı modül olup olmadığı belirsiz (kanıtsız).
4. **Atıl modül oranı:** "üçte bir" iddiası veri taşımıyor [S19]; bağımsız bir oran bulunamadı. Dolayısıyla "çok modül karmaşıklık yaratır" oyuncu için doğru olabilir ama gerçek dünya verisi bunu ölçmedi.
5. **Playtest bilgisi:** bir oyuncunun kaç kalemi angarya hissetmeden yönettiği hiçbir kaynakta yok.
6. **İçerik hacmi:** kodun bugünkü ERP tavanı 15 kademe [K §3.4]; 10 modül × K10 ise 100 kademe. Bu kaynaktan değil planlamadan gelen bir hesaptır ve D fazına bağımlıdır (SENTEZ pre-mortem); kanıt bu konuda bir şey söylemez.

### 4.3 Erdem'e sunulacak seçenek tablosu (yardımcı yönetmen için; ben soru sormuyorum)

Her satır "bu seçenek oyunda neyi değiştirir" sorusuna cevap. Sayılar §2.1 ve SENTEZ'den.

| | 5 modül | 7 modül | 10 modül |
|---|---|---|---|
| Gerçek dünya karşılığı | Çekirdeğe yakın (Fin, Sat, Stok, Üre, Proje) ama sektör ayrımı yok | BC Essentials (7 alan) ile aynı büyüklük [S5] | NAV 2013 R2 (10 iş alanı) ile aynı büyüklük [S6] |
| Bugünkü hatlardan fark | Bugünkü 5 hat gerçek adlarla 4 modül; 1 yeni modül | 4 + 3 yeni | 4 + 6 yeni |
| Sektör kararı ("hangi sektöre odaklanayım") | 7 profilin en çok 1'i tam kurulur → sektör seçimi bir etiket, modül ihtiyacını ayırmaz | En çok 3 profil tam; kalan 4 profil eksik modülle "yaklaşık" | 7 profilin 7'si tam |
| 5★ "7-10 modül ister" kuralı | Kurulamaz (en çok 5) | 7'ye kadar | Kurulur |
| Oyuncunun aday kartında göreceği satır | 2-5 | 2-7 | 2-10 |
| Kademe/kart/Ar-Ge içerik hacmi | 15 kademe (3'lü) ya da 50 (K10) | 21 ya da 70 | 30 ya da 100 |
| 50 kişide modül başına ekip | ~10 kişi | ~7 kişi | ~5 kişi |
| Angarya riski | Düşük; tekrar ve "derinlik yok" riski yüksek (GDT örneği) | Orta | Başta bunaltı, UI yoğunluğu (Software Inc örneği) |
| İçerik riski | En küçük | Orta | En büyük; D'ye bağımlı |

**Hesap eşliği:** tablodaki profil kapsamı §2.1'in sonucudur; hesap yöntemi ve girdisi orada. "Hangi 7" seçeneği ayrıca sorulmalı (iki farklı 7 yukarıdaki gibi farklı profilleri kurtarıyor).

### 4.4 Benim yorumum ([GÖRÜŞ], karar Erdem'in)

- Kanıt 10'u gerçek dünyaya aykırı bulmuyor; 5'i tek başına sektör kararını taşıyamaz çünkü sektör profilleri (soru 1) farklı modül kümeleri üzerinde duruyor.
- 7, "hangi 7" sorusunu açar ve en çok 3 profil kurar; bu yüzden ara değer olarak zayıf bir seçenek görünüyor, ama 7 profili 4'e indirirsek (örn. hizmet, imalat, ticaret [dağıtım+perakende+e-ticaret], inşaat+sağlık) 7 modül yeterli olabilir. Bunu hesaplamadım (profil birleştirme Erdem'in soru 1 kararına bağlı).
- Gerçek ERP'lerin kendisi de "çekirdek + eklenti" yapıyor (Intacct 8+10, BC Essentials+Premium); oyunda "çekirdek 5 + sektör eki" iki katmanı sayıyı 5/7/10 ikilemini aşar: 5 modül her hesap için çekirdek, kalan 5 sektör eki. Bu bir üretim çözümü önerisi, kanıtın söylediği değil [GÖRÜŞ].

---

## Kaynak sicili

Hepsi erişim 2026-10-20. "açılmadı" = yalnız arama özetinde gördüm, sayfayı açmadım.

| S# | URL | Yayıncı | Yayın tarihi | Güven |
|---|---|---|---|---|
| S1 | https://en.wikipedia.org/wiki/Enterprise_resource_planning | Wikipedia | sürekli güncel; 2026 pazar tahmini içeriyor | Orta |
| S2 | https://www.odoo.com/page/all-apps | Odoo S.A. (satıcı) | tarihsiz; sürüm yazmıyor | Düşük (özellik sayımı olgusu Orta) |
| S3 | https://www.odoo.com/documentation/18.0/applications.html | Odoo S.A. belgeleri | Odoo 18 (sürüm tarihi sayfada yok) | Orta |
| S4 | https://en.wikipedia.org/wiki/Odoo | Wikipedia | sürekli güncel; 19.0 Eylül 2025 | Orta |
| S5 | https://en.wikipedia.org/wiki/Microsoft_Dynamics_NAV | Wikipedia | sürekli güncel | Orta |
| S6 | https://learn.microsoft.com/pt-br/previous-versions/dynamicsnav-2013r2/dd338912(v=nav.71) (kanonik: learn.microsoft.com/en-us/previous-versions/dynamicsnav-2013r2/dd338912(v=nav.71)) | Microsoft Learn arşivi | ms.date 2013-12-11 | Orta-Yüksek |
| S7 | https://blog.nbs-us.com/what-are-the-modules-in-sap-b1 | Navigator Business Solutions (SAP iş ortağı) | 2022-06-14 | Düşük |
| S8 | https://www.hco.com/insights/exploring-the-sap-modules-a-comprehensive-list | H&CO (danışman) | 2024-02-08 (güncelleme 2024-03-14) | Düşük |
| S9 | https://en.wikipedia.org/wiki/SAP_S/4HANA | Wikipedia | sürekli güncel; çıkış 2015-02-03 / 2015-05-06 | Orta |
| S10 | https://en.wikipedia.org/wiki/NetSuite | Wikipedia | sürekli güncel | Orta |
| S11 | https://en.wikipedia.org/wiki/Sage_Intacct | Wikipedia | sürekli güncel | Orta |
| S12 | https://www.acumatica.com/cloud-erp-software/ | Acumatica (satıcı) | tarihsiz | Düşük |
| S13 | https://www.erpresearch.com/erp/microsoft-dynamics-nav/modules, .../odoo/modules, .../sap-business-one/modules, .../oracle-netsuite/modules | ERP Research (satıcı eşleştirme sitesi) | 2026 (yalnız yıl) | Düşük (V #13) |
| S14 | https://www.eta.com.tr | ETA (satıcı) | tarihsiz | Düşük |
| S15 | https://www.mikro.com.tr | Mikro Yazılım (satıcı) | tarihsiz | Düşük (sürüm adları Orta) |
| S16 | https://www.uyumsoft.com | Uyumsoft (satıcı) | tarihsiz | Düşük |
| S17 | https://www.nebim.com.tr | Nebim (satıcı) | tarihsiz | Düşük |
| S18 | https://www.logo.com.tr/en/product/logo-netsis-wings (açılan sayfa Edge N-Series'i anlattı); Netsis Wings özeti arama sonuçlarından: https://www.logo.com.tr/en/urun/logo-netsis-wings | Logo Yazılım (satıcı) | tarihsiz | Düşük |
| S19 | https://www.panorama-consulting.com/unlocking-value-from-unused-erp-modules/ | Panorama Consulting Group (danışman) | 2025-09-10 | Düşük (veri yok; danışman hizmeti satıyor) |
| S20 | https://www.lemondeinformatique.fr/actualites/lire-les-entreprises-plutot-satisfaites-de-leur-erp-selon-un-rapport-de-panorama-48115.html (açılmadı) | LeMondeInformatique, Panorama 2011 anketini aktarıyor (246 şirket, 64 ülke) | 2011 anketi | Orta-Düşük |
| S21 | https://blog.meadenmoore.com/blog/erp/erp-enterprise-requirements-planning-or-expense-regret-pain ; https://thirdstage-consulting.com/?p=13502 (ikisi de açılmadı) | Mead & Moore; Thirdstage Consulting (danışman) | tarihsiz | Düşük |
| S22 | https://thejournal.com/articles/2013/01/08/openerp-7,-d-,0-adds-google-docs-integration-customer-portal.aspx (açılmadı) | The Journal / Campus Technology | 2013-01-08 | Orta-Düşük |
| S23 | https://www.odoo.com/forum/help-1/not-showing-all-modules-15438 (açılmadı) | Odoo topluluk forumu | tarihsiz | Düşük |
| S24 | https://store.steampowered.com/app/362620/Software_Inc/ | Steam / Coredumping | mağaza sayfası, erişim günü | Orta (yorum sayıları) |
| S25 | https://store.steampowered.com/app/239820/Game_Dev_Tycoon/ | Steam / Greenheart Games | çıkış 2013-08-29 | Orta |
| S26 | https://store.steampowered.com/app/1342330/Mad_Games_Tycoon_2/ | Steam / Eggcode | çıkış 2023-05-31 | Orta |
| S27 | https://store.steampowered.com/appreviews/362620?json=1&filter=all&language=english&review_type=negative&purchase_type=all&num_per_page=100&cursor=*&day_range=9223372036854775807 (aynı kalıp 239820 ve 1342330 için) | Steam yorum API'si | erişim günü | Orta (yorumların varlığı), Düşük (sınıflama sayıları: model tahmini, en yararlı sırasıyla ilk ~50) |
| S28 | https://vaporlens.app/app/362620/software_inc/stats/details (açılmadı) | vaporlens (YZ üretimli özet) | tarihsiz | Düşük |
| S29 | https://en.wikipedia.org/wiki/Game_Dev_Tycoon | Wikipedia | sürekli güncel | Orta |
| S30 | https://epiqinfo.com/erp-modules-the-complete-guide-for-2026/ (açılmadı); https://www.optimumhq.com/blog/modular-erp-system-benefits-challenges (açılmadı) | EPIQ; OptimumHQ (danışman) | 2026 | Düşük |
| S31 | https://www.redbrick.me/review-game-dev-tycoon/ (açılmadı) | Redbrick | tarihsiz | Düşük |

Başka belgelerden devralınanlar (bu turda yeniden açılmadı): [A1-S10] NetSuite FY2015 beş dikey sürüm (V #5 doğruladı); [V #13] ERP Research tek yayıncı hükmü; [K §3.4, satır 148] kod haritası, HEAD e4e7e9b9 (satır numaraları kayabilir); [SENTEZ §3.1-§3.4, §4.1] modül listesi, profiller, yıldız-modül sayısı tablosu.

## Bulunamayanlar ve açılamayanlar (özet)

- SAP Business One, Dynamics NAV, Odoo için 2012'ye ait resmî modül sayısı: NAV 2013 R2 hariç bulunamadı; "NAV 2012" adlı sürüm kaynaklarda geçmedi.
- Epicor, Infor, Sage 50, Zirve, Logo Tiger/Go: modül listesi açılamadı ya da bulunamadı (sayfalar 403/404 döndü ya da özet vermedi).
- SAP Business One resmî sayfası (403), NetSuite ve Oracle resmî sayfaları (403), Microsoft Learn BC sayfaları (404) açılamadı.
- Oyunlarda kalem sayısı (GDT konu/tür, Software Inc ürün türü, MGT2 motor özelliği): bulunamadı; fandom wikileri 402.
- Nicel, bağımsız "atıl modül" oranı: bulunamadı.
- KOBİ'nin ilk satın aldığı modül sayısı: sayı bulunamadı; yalnız sıralama (finans, satış-stok, bordro) [S20] ve Mikro'nun 4 öğelik Basic sürümü [S15].
