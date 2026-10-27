# A1 · ERP ürünleri nasıl gelişti, "sektör standardı" nasıl oluştu (2005-2026, 2030 öngörüsü)

Tarih: 2026-10-20. Arama: 20/20 WebSearch kullanıldı (bütçe bitti), çok sayıda WebFetch ve yerel PDF okuması. Oyun koduna ve repoya yazılmadı.
Okunan ama tekrar edilmeyen önceki iş: `beklenti/SENTEZ_BEKLENTI.md` ("Pazar merdiveni"; yalnız oyun mekaniği çerçevesindeydi, bu belge gerçek pazar verisi getirir).

Gösterim: `[S#]` kaynak sicilinin (en sonda) numarası. `(varsayım)` kanıtsız kabul. Etiketler: [BOŞLUK] bulunamadı, [SIÇRAMA] kanıttan çıkmayan sonuç, [DEĞERLENDİREMEM], [GÖRÜŞ] benim yargım, (hesap) benim aritmetiğim. "bulunamadı" yazan yerde uydurma yok; bütçe bittiği için model bilgisiyle doldurulmadı, bu yerler "belirsiz (kanıtsız)".

Önemli sınır: Wikipedia kaynaklarının çoğu Orta güvendir ve sorulan olguların bir kısmını içermez; bu yüzden bazı satırlar (ör. SAP HANA yılı, Fiori, AppExchange) tabloda yoktur. Nüanslı sayılar mümkünse birincil belgeden (SAP 2024 entegre rapor, NetSuite 10-K, Logo faaliyet raporu, Panorama raporları) alındı.

---

## 0. Özet (15 satır)

1. ERP'nin "standardı" tek kaynaktan çıkmıyor; üç ayrı mekanizma var: mevzuat (Türkiye'de e-fatura), satıcı duyurusu (bulut, YZ), ve alıcıların gecikmeli benimsemesi. Üçünün hızı çok farklı. [GÖRÜŞ, S24, S6, S35'ten]
2. Mevzuat standardı basamak gibi gelir: önceden ilan edilir, önce dar gruplara (421 sayılı tebliğ, 14.12.2012: madeni yağ ve ÖTV (III) zinciri; geçiş 2013/2014), sonra brüt satışı 10 milyon TL ve üzeri genel gruba (454 sayılı tebliğ, 20.06.2015; 1 Ocak 2016'dan zorunlu), sonra küçüğe iner (sonraki eşikler 3 milyon TL'ye kadar). Ocak 2012'de hiçbir müşteriye zorunlu değil. [V düzeltme] [S24, S25]
3. Satıcı standardı yavaş yayılır: SAP S/4HANA 2015'te çıktı; Q4 2024'te ~35.000 ECC müşterisinin %39'u S/4HANA'ya geçmişti, %61'i geride [V düzeltme; ikincil kaynak, birincil Gartner/SAP belgesi yok]; ECC ana bakımı 2027, uzatılmış destek 2030'da bitiyor. Yani "fark yaratan"dan "olmazsa olmaz"a geçiş 8-12 yıl sürüyor. [S2, S6]
4. Bulutta aynı örüntü: NetLedger/NetSuite 1999-2002'de bulut sundu; Panorama örnekleminde SaaS payı 2014 civarında %4'ten %33'e çıktı, 2023'te bulut %65, 2024'te daha yüksek. [S37, S10, S34, S35]
5. Tavan çok uzak: Oracle "Fusion"ı 2005'te duyurdu, 2011'de çıkardı; SAP 2024'te yalnız Ar-Ge'ye 6,5 milyar euro (gelirin %19,1'i) ve 37.590 tam zamanlı Ar-Ge çalışanı harcadı. [S30, S31, S5]
6. Yeni girişim devi iki yoldan yakaladı: NetSuite (1998 kuruluş, 2015'te 741 milyon dolar gelir; 10-K'da satıcının kendi inancı: daha büyük rakiplerinden hiçbiri bulut tabanlı kapsamlı suit sunmuyor [V düzeltme]) ve Odoo (açık çekirdek + uygulama pazarı, 2023'te 282 milyon euro gelir, 2.200 çalışan). İkisi de modül/dikey genişlik ve fiyat/hız ile girdi. [S10, S14]
7. Ar-Ge oranı üç farklı ölçekte şaşırtıcı biçimde yakın: SAP %19,1 (2024), NetSuite %18,3 (2015, hesap), Logo %27 (2021). [S5, S10, S18]
8. Gelir/çalışan: SAP ~319 bin euro (hesap), NetSuite ~161 bin dolar (hesap), Odoo ~128 bin euro (hesap). 50 kişilik bir şirketin gerçekçi cirosu kabaca 6-16 milyon (euro/dolar). [S3, S10, S14]
9. Başarısızlar çeşitli: ürün başarısız (Oracle Fusion gecikmesi, ByDesign'ın "kapatılıyor" söylentisi), alıcı başarısız (Hershey 1999, Lidl 2018 ~500 milyon euro, Birmingham 19 milyon poundluk iş 144,4 milyon pounda), satıcı çöktü/satıldı (Baan 700 milyon dolardan 135 milyona; PeopleSoft'un 11.000 çalışanının 6.000'i kovuldu). [S31, S32, S33, S29, S28]
10. Her geçişte yerel oyuncu kazandı ya da satıldı: Logo, Netsis'i aldı; Nebim 2024'te Param'a, Mikro 2023'te TeamSystem ortaklığına gitti. Türkiye'de e-fatura/e-defter yerel satıcıya mevzuat avantajı verdi. [S18, S19, S21, S22, S25]
11. Satıcılar eski sürümleri bilerek bitirir: Dynamics AX 2012 R3 Ocak 2023, GP 31 Aralık 2029, SL Temmuz 2028. Geliştirilmeyen ürünün cezası "destek bitti" tarihidir ve herkese önceden ilan edilir. [S13, S2]
12. Yazılım ritmi: SAP S/4HANA buluta yılda iki, yerinde yılda bir sürüm (2023'ten sonra 2 yıllık büyük döngü); Business Central yılda iki (2018'den); Odoo yılda bir büyük sürüm (13: Ekim 2019, 14: Ekim 2020 ... 17: Kasım 2023, 19: Eylül 2025). [S2, S8, S11, S14, S15]
13. 2030 öngörüsünde sağlam olan tek şey takvimli bitişler (ECC 2027/2030, GP 2029-2031, SAP geçiş seçeneği 2031-2033); "YZ ajanları" öngörüleri analist tahminidir. [S6, S1, S13, S5]
14. Oyuncuya "sektör standardı" göstermenin kanıtlı yolu: ilan edilmiş tarihler (destek bitişleri, mevzuat tarihleri) ve satıcı sürüm duyuruları; standardın anlık sayısal değeri hiçbir kaynakta görünür bir ölçü değil. [GÖRÜŞ]
15. Eksikler: Mikro/Nebim/Uyumsoft'un Ar-Ge harcaması bulunamadı; Netsis satın alma yılı ve bedeli çelişkili/bulunamadı; Panorama'nın bulut/yerinde başarı karşılaştırması bulunamadı; uzaktan çalışma 2020 ve API pazarları için ERP'ye özgü kaynak bulunamadı.

---

## 1. Dönem dönem hikâye

### 1.1 Büyük suit satıcılar (SAP, Oracle, Microsoft)

**SAP.** R/3 6 Temmuz 1992'de duyuruldu [S1]; ECC 2004'te R/3 Enterprise'ın yerini aldı, ERP 6.0 2006'da çıktı, ECC'nin son geliştirme paketi (EhP8) 2016'ydı [S1, S3]. Modüller (FI, CO, AA, SD, CRM, MM, PP, QM, PS, PM, HR, WM) listeleniyor; modül başına yıl bulunamadı [S1]. Küçük işletme ürünü Business One 2002'de TopManage alımıyla geldi [S3]; bulut-KOBİ ürünü ByDesign 19 Eylül 2007'de duyuruldu ve "yaklaşık 10.000 şirket, 140'tan fazla ülke" kullanıcısı olduğu söyleniyor; 2022'de ürünün kapatılacağı söylentisi çıktı, SAP Aralık 2022'de "son kullanma tarihsiz" diyerek yalanladı [S4]. S/4HANA 3 Şubat 2015'te New York borsasında duyuruldu; bulut sürümü 6 Mayıs 2015'te çıktı [S2]. Müşteri sayısı: 21 Nisan 2015'te 370, Ekim 2015'te 1.300'ün üstü, 2016 sonunda 5.400, 30 Haziran 2018'de 8.900 [S2]. Yerinde sürümler: 1503, 1511, 1605, 1610, 1709, 1809, 1909, 2020, 2021, 2022, 2023; bulut sürümü yılda iki (1603'ten 2602'ye) [S2]. Ekim 2023'te SAP iki yıllık büyük sürüm döngüsüne ve sürüm başına yedi yıl ana bakıma geçti [S2, S8]. Joule YZ yardımcısı Eylül 2023'te çıktı; S/4HANA Cloud'a 2024 başında geldi [S8]; 2024 sonunda "1.300 beceri" ile anılıyor [S5]. "RISE with SAP" mevcut müşterileri eski ERP'den taşımak, "GROW with SAP" yeni müşteriler için bulut ERP olarak tanımlanıyor [S5]; RISE'ın çıkış yılı bu çalışmada doğrulanamadı [BOŞLUK].

Ölçek (SAP 2024 entegre raporu, birincil [S5]): Ar-Ge gideri 6.514 milyon euro (2023: 6.324; 2022: 6.080); Ar-Ge/gelir %19,1; geliştirmedeki tam zamanlı çalışan 37.590, toplam çalışanın %34'ü; toplam gelir 34,2 milyar euro; bulut geliri 17,1 milyar euro (+%25). Çalışan sayısı 2013'te 66.572, 2024'te 107.155 (ay sonu ortalaması; yıl sonu 107.602) [S3] [V düzeltme].

**Oracle.** PeopleSoft'a düşmanca teklif Haziran 2003'te 13 milyar dolarla başladı, Aralık 2004'te ~10,3 milyar dolara anlaşıldı, 2005'te kapandı; bir ay sonra 11.000 çalışanın 6.000'i işten çıkarıldı [S28]. Fusion Applications 2005'te duyuruldu (E-Business Suite + JD Edwards + PeopleSoft + Siebel'in birleşimi), Eylül 2010'da tanıtıldı, OpenWorld 2011'de yayımlandı [S28, S30]. 2009 tarihli bir değerlendirme Oracle'ın 2006 Ocak'ta "yarıya geldik" dediğini, ama uygulamaların hâlâ çıkmadığını yazar [S31]. NetSuite'i Oracle 2016'da 9,3 milyar dolara aldı (anlaşma Kasım'da kapandı) [S9].

**Microsoft.** Navision'ı 11 Temmuz 2002'de aldı [S11]; Dynamics NAV adı Eylül 2005'te; NAV 2009 Aralık 2008'de .NET tabanlı RoleTailored istemciyi getirdi; NAV 2013 eşzamanlı kullanıcı lisansı getirdi [S11]. AX 7 (tarayıcı tabanlı) 2016'da, "Dynamics 365 for Operations" adıyla Ekim 2016'da, Dynamics 365 1 Kasım 2016'da duyuruldu; AX 2020'de Finance ve Supply Chain Management olarak bölündü [S11]. Business Central 2 Nisan 2018'de çıktı; yılda iki sürüm planı açıklandı; uzantı mağazası AppSource [S11]. "Dynamics 365 Copilot" 6 Mart 2023'te duyuruldu, satıcının kendi "CRM ve ERP'de ilk" iddiasıyla [S12; Düşük, yalnız tarih için]. Eski sürümlerin sonu: AX 2012 R3 Ocak 2023; SL 2018 genişletilmiş destek 11 Temmuz 2028; GP ürün geliştirme ve teknik destek 31 Aralık 2029, güvenlik güncellemeleri 30 Nisan 2031; NAV sürümleri kaynaklara göre farklı, 2026-2028 aralığı [S13].

### 1.2 Yükselen girişimler

**NetSuite.** 1998'de NetLedger olarak kuruldu, 2003'te NetSuite adı, 2007'de NYSE'de halka arz [S9]. Kendi başvurusu: ilk uygulama NetLedger 1999, e-ticaret 2000, CRM 2001, "yeni nesil suit" 2002 [S10]. Satın almalar: OpenAir 2008, QuickArrow 2009, 2013'te perakende/İK/sipariş/CMS (Retail Anywhere, TribeHR, Order Motion, LightCMS), 2014 Venda, eBizNET, 2015 Bronto, Monexa [S9]. FY2015 10-K'sı (birincil [S10]): gelir 741,1 milyon dolar; çalışan 4.603 (31 Aralık 2015); "ürün geliştirme" gideri 2013'te 78,3, 2014'te 106,7, 2015'te 135,5 milyon dolar. Dikey sürümler: toptan/dağıtım, üretim, profesyonel hizmetler, perakende, yazılım (ve kâr amacı gütmeyen, hizmetler) [V uyarı: son parça 10-K metninde bulunamadı]. Beyanı: "daha büyük rakiplerimizin hiçbirinin" bulut tabanlı kapsamlı bir işletme yönetim suiti sunmadığına inanıyoruz; bazı büyük rakipler benzer ürünler duyurmuş [V düzeltme: satıcının inancı, yalnız daha büyük rakipler için] SAP, Oracle ve Microsoft ana rakip olarak sayılıyor [S10]. SuiteSuccess ve yılda kaç sürüm çıktığı bu kaynaklarda bulunamadı [BOŞLUK]; 10-K "aşamalı sürüm süreci" diyor [S10].

**Odoo.** Şubat 2005'te TinyERP, 2008'de OpenERP, 2014'te Odoo adı; 2010'da 100'den fazla çalışan; 2013'te Odoo Community Association; 2019'da 90 milyon dolar yatırım; 2021'de 5 milyondan fazla kullanıcı; 2023 geliri 282 milyon euro (+%33), 2.200'den fazla çalışan, kârlı; Kasım 2024'te ikincil hisse turu, değerleme 5,26 milyar dolar [S14]. Topluluk sürümü LGPLv3, kurumsal sürüm tescilli uygulamalar ve destek içerir, üçüncü taraf uzantıları pazarda dağıtılır [S14]. Büyük sürümler uzun süreli destekli; birden çok sürüm paralel desteklenir; 19.0 18 Eylül 2025'te çıktı, 16.0'ın desteği Eylül 2025'te bitti [S14]. Resmî belgelere göre: 13.0 Ekim 2019, 14.0 Ekim 2020, 15.0 Ekim 2021, 16.0 Ekim 2022, 17.0 Kasım 2023 [V uyarı: 17.0 tarihi doğrulanmadı]; her sürümün desteği ~3 yıl [S15]. Not: üçüncü taraf bir blog 19'u Ekim 2025'e yazıyor, Wikipedia 18 Eylül 2025 diyor; çelişki var, Wikipedia'yı aldım [S14 vs. S15].

**Infor ve Epicor.** Infor 2002'de Agilisys adıyla SCT'den ayrıldı (1.300 müşteri), 2004'te Infor adını aldı, Baan, SSA Global, Geac, Lawson vb. alarak büyüdü; CloudSuite 2014'te (AWS tabanlı); Şubat 2017'de Koch 2,68 milyar dolara üçte iki hisse aldı, Şubat 2020'de kalan hisseyi aldı (değerleme 11 milyar dolar); gelir 3,2 milyar dolar (2019), 17.000 çalışan (2022) [S16]. Epicor 1972 Triad kökenli; 1999'da Epicor adı; 2011'de Apax, 2016'da KKR, 2020'de CD&R'ye 4,7 milyar dolara satıldı; FY2022 geliri 1,05 milyar dolar, 4.600 çalışan; ürünleri bulut ve yerinde sunuyor [S17]. Panorama 2026 raporuna göre Epicor, Kinetic, Prophet 21 ve BisTrack'in tüm yeni özelliklerinin yalnız Epicor Cloud'da geliştirileceğini, son yerinde sürümden sonra yerinde sürümlere yeni özellik gelmeyeceğini duyurdu [S36]. Epicor'un tarihi, sahibi üç kez değişen "satın alma zinciri" örneğidir; buna "gerileme" demek için kanıt yok [GÖRÜŞ].

### 1.3 Türkiye

**Logo.** 1984'te başladı, 1986'da tescil; Mayıs 2000'de halka arz [S18]; Logo'nun kendi faaliyet raporuna göre (31 Mart 2025) tarihçe: 1986-1999 Logo GOLD, Logo ERP; 2000 halka arz, 11.000 m² ürün geliştirme merkezi; 2001-2005 Tiger ile e-çözümler/tedarik zinciri, IBM işbirliği; 2006-2010 Unity on Demand, GO, Start, GO Plus, Tiger Plus, Tiger Enterprise; 2011-2015 Coretech, World BI (Logo BI), j-Platform, Logo Mobile, e-defter, e-fatura, Logo Store, Netsis, e-Logo, Intermat/Sempa/Vardar alımları; 2016-2017 Total Soft (Romanya), Logo Infosoft (Hindistan), "3 serisi ürünler", Wings ve e-irsaliye; 2018-2019 Tiger Wings Enterprise, Netsis Wings Enterprise, GO Wings, WMS; 2020-2021 Peoplise, j-Construction, Payroll, bulut tabanlı yetenek/doküman yönetimi [S19]. Netsis satın alma yılı: rapor 2011-2015 aralığına koyuyor; bir arama özeti 2013 faaliyet raporunda 2013 olarak geçtiğini söylüyor (doğrulanmadı), bir başka kaynak "2012'de edinildi" diyor (düşük güven); bedel bulunamadı [S19, S42] [BOŞLUK]. Wikipedia: j-Platform 2012'de Logo'nun ilk Java tabanlı ürünü; Aralık 2021'de 1.500'ün üstünde çalışan, 725'i Ar-Ge'de; Ar-Ge harcaması 232 milyon TL, toplam gelirin %27'si [S18]. Mart 2025'te Türkiye'de ortalama 933 personel (Aralık 2024: 989) [S19]. CEO röportajı: son beş yılda yıllık ortalama %44 satış büyümesi, sekiz birleşme/satın alma (2016) [S39]. Satıcı blogunda "Logo ~%40 orta pazar payı" iddiası bağımsız kaynağa dayanmıyor [S42, Düşük].

**Nebim.** 1966'da bir örme fabrikasının bilgi işlem merkezi, 1977'de bağımsız, 1988'de bağımsız yazılım satıcısı, 2000-2001 Nebim Winner, 2004'te yalnız yazılım, 2011'de V3 (2005'ten beri geliştirilen); 2010'da 10.000'den fazla müşteri şirketi ve 90.000 kullanıcı; 2017'de V3 ile 3.000'den fazla şirket, 40+ ülke, 16 dil (satıcının kendi sayfası) [S20, Düşük]. Ekim 2024'te fintek Param çoğunluk hissesini aldı; "8.000'den fazla şirket" kullanıyor; fiyat açıklanmadı [S21]. Not: 2010'daki 10.000 ile 2024'teki 8.000 farklı tanımlarla verilmiş olabilir, aralarındaki düşüş doğrulanmadı [DEĞERLENDİREMEM].

**Mikro, Uyumsoft.** Mikro 1988'de kurulmuş, Mikrogrup'a bağlı; sayfada başlıkta "100.000+ müşteri", metinde "45 bini aşkın işletme" (çelişkili); Ağustos 2023'ten beri TeamSystem ile ortaklık süreci [S22, Düşük]. Uyumsoft "29 yıllık deneyim" (yaklaşık 1996), 400+ çalışan, 500+ ERP projesi, 350+ iş ortağı [S23, Düşük]. Ar-Ge harcamaları bulunamadı [BOŞLUK].

---

## 2. Zaman çizelgesi (2005-2026 ve öncesi dönüm noktaları)

Sütunlar: yıl · olay · hangi modül/alan standart oldu veya hangi sınır değişti · kaynak.

| Yıl | Olay | Standart olan / etkisi | Kaynak |
|---|---|---|---|
| 1992 | SAP R/3 duyuruldu | İstemci/sunucu, modüler tam suit (FI, CO, SD, MM, PP...) | S1 |
| 1998 | Baan'da gelir şişirme ortaya çıkar | Büyüme hırsı/muhasebe çöküşü | S29 |
| 1999 | NetLedger (ilk bulut ERP çizgisi); Hershey SAP/Siebel/Manugistics çöküşü (~100 milyon dolar sipariş) | Bulut fikri doğdu; "kesme zamanı" dersi | S37, S10, S31 |
| 2000 | Baan Invensys'e 700 milyon dolara satıldı; Nike ~100 milyon dolar kayıp (400 milyon dolarlık proje); Gartner "ERP II" | Web erişimi çalışan/ortak için | S29, S31, S37 |
| 2002 | NetSuite suiti; SAP Business One; Microsoft-Navision; Infor kuruldu | Orta/küçük pazar için hazır paket; satın alma konsolidasyonu | S10, S3, S11, S16 |
| 2003 | PeopleSoft-JD Edwards birleşmesi; Oracle'ın düşmanca teklifi; Baan 135 milyon dolara SSA'ya | Orta pazar satıcıları birleşir | S28, S29 |
| 2004-2006 | SAP ECC 5.0 (2004), ERP 6.0 (2006) | ECC 6.0 on yıl standart yerinde ERP | S3, S1 |
| 2005 | Oracle PeopleSoft'u kapattı, 6.000 kişi çıkarıldı; Fusion duyuruldu; NAV adı Dynamics NAV | Satıcı sayısı azalır; "tek birleşik suit" vaadi | S28, S30, S11 |
| 2007 | NetSuite halka arz; SAP ByDesign duyuruldu | Bulut KOBİ ERP; büyük satıcı ilk resmî tepki | S9, S4 |
| 2008 | NAV 2009 (Aralık) RoleTailored istemci; NetSuite OpenAir (PSA) | Role göre arayüz; PSA modülü | S11, S9 |
| 2009 | Select Comfort SAP projesi 20 milyon dolar+ askıya | Proje maliyet baskısı | S31 |
| 2010 | e-Fatura TR (5 Mart, 397 sıra no); Fusion tanıtıldı; Nebim 10.000+ şirket | TR'de elektronik fatura başlangıcı (gönüllü) | S25, S30, S20 |
| 2011 | Fusion yayımlandı (OpenWorld); Nebim V3; e-Defter Resmî Gazete (13 Aralık) | Oracle'ın suit sürümü; TR'de e-defter yasası | S30, S20, S25 |
| 2012 | e-Defter tebliği gönüllü (1 Ocak 2012'de fiilen başlama doğrulanmadı [V uyarı]); 14 Aralık: 421 sıra no'lu tebliğ dar gruplara ilk zorunluluğu getirir [V düzeltme]; Logo j-Platform; SAP Ariba'yı 4,3 milyar dolara alır | TR'de yerli ERP'lerin e-dönüşüm modülü; satın alma yoluyla bulut | S25, S18, S3 |
| 2013 | NAV 2013 eşzamanlı lisans; NetSuite perakende/İK satın almaları; Gartner "postmodern ERP"; (Logo-Netsis 2011-2015 aralığı) | Çekirdek + bulut uygulamalar kompozisyonu fikri | S11, S9, S37, S19 |
| 2014 | 421 sıra no (14.12.2012) kapsamındaki dar gruplarda e-Defter geçişi (e-Fatura geçişi 2013): madeni yağ ve ÖTV (III) zinciri [V düzeltme]; Infor CloudSuite; OpenERP→Odoo | TR'de dar gruba zorunlu e-belge; ≥10 milyon TL genel grup henüz kapsamda değil (454 sıra no: 20.06.2015) [V düzeltme] | S24, S16, S14 |
| 2015 | S/4HANA (3 Şubat); 454 sıra no (20 Haziran): ≥10 milyon TL genel grup kapsama alınır, geçiş 1 Ocak 2016 [V düzeltme]; e-fatura kullanıcı sayısı 19.915, hedef 40-50 bin; Panorama: SaaS payı %4 → %33, yerinde %85 → %56 | Yeni çekirdek mimari; bulut mainstream'e girer | S2, S24, S34 |
| 2016 | Oracle NetSuite'i 9,3 milyar dolara alır; Dynamics 365 (1 Kasım); KVKK 6698 (7 Nisan); GDPR kabul (14 Nisan); e-fatura kapsamı genişledi: ≥10 milyon TL genel grup ve ihracat e-faturası zorunlu (1 Ocak) [V düzeltme]; SAP ECC EhP8 son | Bulut ERP "tamamlandı" işareti; kişisel veri alanı | S9, S11, S27, S26, S24, S1 |
| 2017 | Koch Infor'a 2,68 milyar dolar | Özel sermaye konsolidasyonu | S16 |
| 2018 | Business Central (2 Nisan, yılda iki sürüm); GDPR yürürlükte (25 Mayıs); KVKK uyum süresi bitti (7 Nisan); Lidl projeyi iptal eder (~500 milyon euro); Wings serisi (Logo, 2018-2019) | Yılda iki sürüm ritmi; veri koruma uyumu zorunlu; büyük alıcı da çöker | S11, S26, S27, S32, S19 |
| 2019 | Odoo 90 milyon dolar; TR e-Fatura/e-Defter yeni tarihler (1 Temmuz 2019 sonrası geçenler 1 Ocak 2020'de e-Defter) | Orta pazar yatırımı; mevzuat adım adım | S14, S25 |
| 2020 | AX → Finance + SCM; Koch Infor'u tamamen alır; CD&R Epicor'u 4,7 milyar dolara alır; e-Arşiv: 5.000 TL üstü portal zorunlu; Odoo 14 (Ekim); S/4HANA 2020 | Ürün aileleri bölünür; faturalama için küçük esnafa kadar iner | S11, S16, S17, S25, S15, S2 |
| 2021 | Odoo 5 milyon+ kullanıcı; Logo Peoplise, bulut yetenek yönetimi; Odoo 15 | KOBİ bulutu yaygın | S14, S19, S15 |
| 2022 | Birmingham Oracle go-live (Nisan); ByDesign kapanış söylentisi ve yalanlama (Aralık) | Büyük proje riski; ürün itibarı | S33, S4 |
| 2023 | Dynamics 365 Copilot (6 Mart); SAP Joule (Eylül) + S/4HANA 2023 iki yıllık döngü; AX 2012 R3 sonu (Ocak); Odoo 17 (Kasım); Panorama: bulut seçimi %65, SaaS %52; Birmingham "fiilen iflas" | YZ asistanı "duyuru" aşamasında; bulut çoğunluk | S12, S8, S2, S13, S15, S35, S33 |
| 2024 | SAP: Ar-Ge 6,5 milyar euro, bulut geliri 17,1 milyar euro; Panorama 2024: bulut payı %65'ten yukarı, YZ en az tercih edilen ama +%10,2; Nebim→Param (Ekim); Odoo değerleme 5,26 milyar dolar | YZ kabul görmeye başlar; bulut baskın | S5, S35, S21, S14 |
| 2025 | Joule/S/4HANA Cloud 2502 (YZ); Odoo 19 (Eylül); (SAP "Cloud ERP" adlandırması, zayıf kaynak) | Gömülü YZ yeni "çıta" adayı | S2, S14, S1 |
| 2026 | Panorama 2026: %25+ bütçe aşımı [V düzeltme: "ortanca proje 9 ay" AÇILAMADI, Panorama bülteninde yok]; Birmingham 144,4 milyon pound; DSAG: Alman konuşan ECC kullanıcılarının yarısı 2027'yi kaçıracak | Göç gecikir | S36, S33, S7 |
| 2027 | SAP ECC ana bakım sonu; Dynamics 365 uzantı/NAV 2017 sonu (kaynaklar farklı) | Takvimli "bitiş" | S6, S13 |
| 2028-2031 | SL 2018 genişletilmiş destek sonu (Temmuz 2028); GP geliştirme/teknik sonu 31 Ara 2029, güvenlik 30 Nis 2031; ECC uzatılmış destek 2030; SAP geçiş seçeneği 2031-2033 | Takvimli "bitiş" | S13, S6, S1 |

[BOŞLUK] Tabloda yok çünkü kaynak bulunamadı: SAP HANA yılı, Fiori ve mobil ERP kilometre taşları, API/entegrasyon pazarları (AppExchange benzeri), uzaktan çalışma 2020'nin ERP'ye etkisi, RISE with SAP çıkış yılı, SuiteSuccess yılı.

---

## 3. Bir özelliğin "fark yaratan"dan "olmazsa olmaz"a dönüşü

Bu bölüm yalnız kaynaklı örnekleri verir; geçiş süresi örnek sayısı küçük olduğu için aralık verilir.

### 3.1 Bulut

- 1999: NetLedger ilk bulut ERP çizgisi [S37]; 2002: NetSuite suiti [S10].
- 2014 civarı (Panorama 2015, veri Şubat 2014-Şubat 2015): yerinde seçen %85'ten %56'ya, SaaS %4'ten %33'e; %11 "bulut" seçti [S34].
- 2015 NetSuite 10-K: "daha büyük rakiplerimizin hiçbirinin bulut tabanlı kapsamlı suit sunmadığına inanıyoruz" (satıcının inancı) [S10] [V düzeltme]. 2014 Infor CloudSuite [S16].
- Panorama 2023 raporunda bulut seçimi %65, SaaS %52 [S35]; 2024 raporunda artıyor [S35]; 2026 raporunda "bulut sabit" [S36], ikincil özet %73,5 [S41, Düşük].
- TechTarget (Eylül 2023-Eylül 2024, 172 alıcı): bulut seçimi SAP %77,4, Oracle %75, Microsoft %73,3, Infor %92,9 [S38]. Gartner'a göre 2023'te ERP pazarı 45 → 51 milyar dolar, büyümenin %80'den fazlası buluttan [S38].
- Yerinde bırakan kural: satıcı yeni özelliği yalnız bulutta geliştirir (Epicor, 2026) [S36].
- Süre: 1999-2002'de çıkış → ~2015'te %33 → ~2023'te %65-70: "fark yaratan" 10-13 yıl sürdü, "çoğunluk" 20+ yıl sürdü. [GÖRÜŞ, S37, S34, S35]
- **Oyuna ders:** Bulut modülü ilk yıllarda satış kozu, orta yıllarda "müşteri soruyor", sonra "bulutta değilseniz gideriz" şartına dönüşür. Oyuncu bu kararı birkaç kez verir (dönemde 1-2), her seferinde "yeni müşteri" ve "yenileme" konuşmasında karşılaşır.

### 3.2 E-fatura / e-defter (Türkiye)

- 5 Mart 2010: e-Fatura başlar (397 sıra no) [S25]. 13 Aralık 2011: e-Defter tebliği (Sıra No: 1), mükellefin ihtiyarında, gönüllü [V düzeltme; "1 Ocak 2012 fiilen başlangıç" doğrulanmadı]. 5 Mart 2010 e-Fatura da ilk aşamada gönüllü/pilot. Ocak 2012'de hiçbir müşteriye zorunlu değil [S25].
- 421 sıra no'lu tebliğ (14.12.2012, RG 28497): ilk zorunluluk ve dardır: madeni yağ lisansı sahipleri ile bunlardan mal alıp 31/12/2011'de asgari 25 milyon TL brüt satışı olanlar; ÖTV (III) listesi mallarını imal/inşa/ithal edenler ile bunlardan mal alıp asgari 10 milyon TL brüt satışı olanlar. Geçiş: e-Fatura 2013, e-Defter 2014 [V düzeltme] [S24].
- 20 Haziran 2015 (454 sıra no, RG 29392): kapsam genişledi: 2014 veya sonraki hesap dönemlerinde brüt satış hasılatı 10 milyon TL ve üzeri mükellefler (2014 hesap döneminde eşiği sağlayanlar 1 Ocak 2016'dan zorunlu; 2015 ve sonrasında sağlayanlar ilgili beyanname tarihini izleyen hesap döneminin başından), EPDK ÖTV (I) lisanslıları, ÖTV (III) imalatçıları; ihracat faturaları 1 Ocak 2016'dan e-Fatura [V düzeltme] [S24]. Ağustos 2015'te e-Fatura/e-Defter kullanıcısı 19.915; hedef 40-50 bin [S24].
- 1 Ocak 2020: e-Arşiv'de 5.000 TL üstü fatura portal zorunlu [S25]. Blog kaynağa göre 2022'den sonra brüt satış hasılatı 3 milyon TL ve üzeri, 2025'te bilanço usulü defter tutan herkes e-Defter [S25; Düşük, doğrulanmadı; V uyarı: Paraşüt tarihleri kendi içinde tutarsız, birincil GİB/Resmî Gazete metni açılmadı].
- Logo'nun ürün çizgisi bu tarihlerle örtüşür: e-defter ve e-fatura ürünü 2011-2015 grubunda, e-irsaliye 2016-2017'de [S19]. Nebim, Mikro, Uyumsoft e-dönüşüm ürünlerini sayfalarında duyuruyor [S22, S23]; yılı belirtmiyor [BOŞLUK].
- **Örüntü:** önceden ilan edilir, eşik cirosuna göre basamak basamak aşağı iner, uyum için ~1-2 yıl süre verilir.
- **Oyuna ders:** Mevzuat kilidi "yılı belli, ciro eşiği olan" olaydır. Oyuncu takvimi önceden görebilir; zayıf modül varsa eşik firmaları "yenilerken şunu istiyoruz" der. Sıklık: dönem başına birkaç kez, hepsi öngörülür.

### 3.3 KVKK / GDPR

- GDPR 14 Nisan 2016'da kabul, 25 Mayıs 2018'de uygulanır; ceza üst sınırı 20 milyon euro ya da dünya cirosunun %4'ü [S26]. İlk büyük cezalar: Google 50 milyon euro (21 Ocak 2019) [S26].
- KVKK 6698: TBMM 24 Mart 2016, Resmî Gazete 7 Nisan 2016 (sayı 29677); 7 Nisan 2016 öncesi işlenen veriler için uyum süresi 7 Nisan 2018'de bitti [S27].
- ERP satıcılarının buna tepkisi (modül/özellik, yıl) bu çalışmada bulunamadı [BOŞLUK].
- **Oyuna ders:** Veri koruma, ERP alanlarından biri değil, tüm modüllere uygulanan "uyum şartı" olarak modellenebilir [GÖRÜŞ]. Ürün satışına etkisi: 2016-2018 arası yeni müşteri kontrol listesine satır eklenir.

### 3.4 Yapay zekâ (2023+)

- 6 Mart 2023 Dynamics 365 Copilot [S12, Düşük]; Eylül 2023 SAP Joule [S8]; 2025 Joule'da "1.300 beceri", amaç "ajanları orkestre etmek" [S5].
- Panorama 2024: YZ en az tercih edilen dijital girişim; bir önceki rapora göre %10,2 artış; önceki rapor ChatGPT öncesi verilerdi [S35].
- IDC alıntısı (SAP raporunda): "2027'ye kadar ajan iş akışları..." tahmin niteliğinde [S5, analist tahmini].
- McKinsey (Mayıs 2026) YZ'nin ERP'yi nasıl değiştireceğini tartışıyor, sonuç açık [S37] [DEĞERLENDİREMEM].
- **Oyuna ders:** "İlk atılımı yapan şirketlerden olmak" Erdem'in dönem hedefi; veri: Microsoft Mart, SAP Eylül 2023'te çıktı, yani büyükler aylar farkla çıktı ve benimsenme düşük. Önde olmanın değeri, benimsenme eğrisi yataya yakınken satış hikâyesi olmak [GÖRÜŞ]. Sıklık: bir kez, ~2023.

### 3.5 Eski sürümlerin bitişi

- SAP: ECC ana bakım 2027, uzatılmış destek %2 prim ile 2030, sonrası seçenek (2031-2033) [S6, S1]; Q4 2024'te 35.000 ECC müşterisinin %39'u S/4HANA'ya geçmişti, %61'i geride (CIO'nun Gartner aktarımı, ikincil) [V düzeltme] [S6]; ISG (200 karar verici): göçlerin ~%60'ı gecikmeli ve bütçe aşımlı, %49 az ya da hiç süreç yeniden tasarımı yapıyor [S6]; DSAG (198 yönetici): yarısı 2027'yi kaçıracak [S7].
- Microsoft: AX 2012 R3 Ocak 2023; GP 31 Aralık 2029; SL Temmuz 2028 [S13].
- **Oyuna ders (Erdem karar 8):** Geliştirilmeyen ürünün cezası, ilan edilmiş bir "destek bitiş" tarihidir ve müşteri kararı o tarihe yaklaştıkça yaşar. Ceza hataya değil "çıta" ile bağlanabilir: satıcı çıtayı yükseltir, yenilemede müşteri "bu sürümü artık desteklemiyorsanız ayrılırız" der. [GÖRÜŞ]

---

## 4. Sektör standardı nasıl oluşur ve nasıl büyür (Erdem karar 3)

Kanıtlı örüntüler:

1. **Mevzuat basamağı.** Önceden ilan, ciro eşiği, adım adım iner (bkz. 3.2). Standart, kuralın koyduğu tarihtir; satıcılar uyum modülünü zamanında çıkarır (Logo 2011-2015) [S24, S19].
2. **Lider satıcı duyurusu, geç benimseme.** SAP S/4HANA 2015, 2024 sonunda ECC müşterilerinin yalnız %39'u geçmiş, %61'i geride [V düzeltme]. Standart "çıtası" liderin yol haritasıdır, ama müşteri tabanı onunla 8-12 yıl farklı noktada kalır [S2, S6].
3. **Alıcı alışkanlığı.** Panorama 2015: kısa liste SAP %27, Oracle %19, Microsoft %13; kısa listeden seçilen: SAP %39, Microsoft %27, Oracle %26, Epicor %6 [S34]. Büyük satıcı kısa listenin başındadır; yeni giren için kısa listeye girmek ilk engel. (Panorama kendi sitesine gelen ve Mint Jutras anketini birleştiren 562 yanıtlı bir örnek; seçilim yanlılığı olabilir [S34].)
4. **Analist sınıflaması.** Gartner "ERP II" (2000), "postmodern ERP" (2013) [S37]. Standart bir kez adlandırılınca satış dilinde kullanılır [GÖRÜŞ].
5. **Satıcıların kendi yol haritası.** Epicor yalnız bulut (2026) [S36]; SAP iki yıllık sürüm döngüsü (2023) [S8].

[BOŞLUK] Standardın oyun içi ölçülebilir bir "değer" olarak nasıl büyüdüğüne dair sayısal kaynak yok. [SIÇRAMA] Bu yüzden önerim, standardı sayı değil olay dizisi olarak göstermek: duyurulmuş tarihler, satıcı sürümleri, mevzuat adımı.

**Oyuncuya nasıl gösterilir (kanıtlı seçenekler):**
- Takvimli bitişler (destek sonu, mevzuat): SAP, Microsoft zaten yıllar önce ilan ediyor [S6, S13, S25].
- Satıcı sürüm haberleri: "S/4HANA 2023" gibi adlandırılmış sürümler; Business Central dalga planı yılda iki [S2, S11].
- Büyük müşterinin sözü (yenileme şartı): satın alma kısa listesi örüntüsü [S34].

**Oyuna ders:** Standardı gizli bir sayı olarak değil, oyuncunun ay ay görebildiği duyurular ve tarihler olarak gösterin. Kanıtlı sıklık: büyük satıcı duyurusu yılda 1-2; mevzuat adımı birkaç yılda bir.

---

## 5. Sürüm ritmi, ekip ve Ar-Ge büyüklüğü

| Şirket | Sürüm ritmi | Çalışan / Ar-Ge | Kaynak |
|---|---|---|---|
| SAP S/4HANA | Yerinde: 2015-2019 yılda 1-2, 2020-2023 yılda 1 (Ekim); bulut: yılda 2; 2023'ten iki yıllık büyük sürüm, 7 yıl bakım | 2024: Ar-Ge 6.514 milyon euro (%19,1), 37.590 Ar-Ge FTE (%34); toplam ~107.155 | S2, S8, S5, S3 |
| NetSuite | "Aşamalı sürüm"; yılda kaç sürüm bulunamadı | 2015: 4.603 çalışan; ürün geliştirme 135,5 milyon dolar = gelirin %18,3 (hesap) | S10 |
| Business Central | Yılda iki dalga (Nisan/Ekim) | Ar-Ge bulunamadı | S11 |
| Odoo | Yılda bir büyük sürüm (Ekim/Kasım), 3 yıl destek, paralel LTS | 2023: 282 milyon euro gelir, 2.200+ çalışan (~128 bin euro/kişi, hesap) | S14, S15 |
| Infor | CloudSuite 2014; sürüm ritmi bulunamadı | 2019 gelir 3,2 milyar dolar; 2022 17.000 çalışan | S16 |
| Epicor | Sürüm ritmi bulunamadı; yeni özellikler yalnız bulutta | FY2022 gelir 1,05 milyar dolar; 4.600 çalışan | S17, S36 |
| Logo | Ürün jenerasyonları ~2-3 yıl (Tiger/GO Plus; 3 serisi 2016-17; Wings 2018-19) (grup kaydı) | 2021: 1.500+ çalışan, 725 Ar-Ge; Ar-Ge 232 milyon TL = gelirin %27; Mart 2025: TR'de ort. 933 personel | S18, S19 |
| Nebim | V3: 2005'ten geliştirilir, 2011'de yayın | 2010: 10.000+ şirket, 90.000 kullanıcı (satıcı beyanı) | S20 |
| Uyumsoft | bulunamadı | 400+ çalışan, 500+ ERP projesi (satıcı beyanı) | S23 |

Hesap: SAP gelir/çalışan 34,2 mlr € / 107.155 ≈ 319 bin €; NetSuite 741,1 M$ / 4.603 ≈ 161 bin $; Odoo 282 M€ / 2.200 ≈ 128 bin €. Ar-Ge oranları: SAP %19,1 [S5], NetSuite 135,5/741,1 ≈ %18,3, Logo %27 [S18]. Üç ölçekte (küçükten dev'e) %18-27 aralığı. [GÖRÜŞ] Oyundaki rakip şirket "gelirinin ~%20'sini Ar-Ge'ye koyar" için gerçek dünyada dayanak var, ama yalnız üç örnek [SIÇRAMA riski].

**Oyuna ders:** "Rakibin kart hızı = Ar-Ge çalışanı sayısı" ve "Ar-Ge çalışanı oranı ~%34 (SAP), Logo'da ~%48 (725/1.500)" gerçekçi bir aralık verir. Oyuncu için karar: ekibin ne kadarını Ar-Ge'ye ayıracağı, her ay (sürekli karar).

---

## 6. Yeni girişim devle nasıl yarıştı

**NetSuite (1998-2016).** Girdi: bulut olmayan rakiplere karşı "tam suit tek kayıt" (ERP+CRM+e-ticaret); satın alma ile modül genişletti (2008-2015); dikey sürümler; 2007 halka arz; 2015'te 741,1 milyon dolar ve %33 büyüme (gelir tablosu, bir basın açıklaması [S10 ve arama sonucu]); 2016'da Oracle'a 9,3 milyar dolara satıldı [S9, S10]. Rakip olarak SAP, Oracle, Microsoft, Epicor, Intuit, Sage, Salesforce, Workday anılıyor [S10]. Hikâye: NetSuite devin bulutta eksiğini hedefledi; ama "sektörde başka bulut suit yoktu" 10-K'dan çıkmaz, yalnız satıcının "daha büyük rakiplerimizden hiçbiri" inancı vardır [V düzeltme] [S10].

**Odoo (2005-2025).** Girdi: açık kaynak topluluk sürümü bedava, kurumsal sürüm ücretli, üçüncü taraf uzantı pazarı; 2008'den 2023'e 100 → 2.200 çalışan; kârlı; 5,26 milyar dolar değerleme [S14]. Resmî belge: yılda bir büyük sürüm [S15]. Hız: 18 yılda bir milyar eurolara yakın değil, 282 milyon euro [S14].

**Yerel dikey: Nebim (perakende/moda).** 2010'da hazır giyim, ayakkabı, zincir mağaza, optik yazılım liderlik beyanı [S20]; müşteri sayısı 2010'dan 2024'e düştü gibi görünüyor ama tanımlar farklı olabilir [S20, S21]. Dikey derinlik küçük satıcıya savunma verir [GÖRÜŞ].

**Yerel yasal uyum: Logo.** e-defter ve e-fatura ürünlerini 2011-2015 grubunda sundu; bir üst düzey ERP olan SAP'nin Türkiye pazar payı iddiası (2017'de %44,5) ancak e-ticaret satıcısı blogunda ve eski; güvenilmez [S42, Düşük]. Mevzuat avantajının ölçülmüş bir kanıtı yok [BOŞLUK].

**Oyuna ders:** Girişimin devi geçme yolları, kanıtlı iki rota: (a) devin sunmadığı yeni bir model/özellik (NetSuite: bulut, 1999-2007); (b) fiyat ve modüler açıklık (Odoo). Her ikisi de oyuncunun Ar-Ge/satış kararlarıyla örtüşür, ama zaman ölçeği 10+ yıl; 2012-2030 oyunu 18 yıl, yani uyumlu.

---

## 7. Başarısızlar ve eleştiriler (ayrı aramalarla bulundu)

### 7.1 Başarısız büyük projeler (alıcı tarafı)
- **Hershey 1999:** SAP + Siebel + Manugistics, ~100 milyon dolarlık Cadılar Bayramı siparişi yerine getirilemedi, hisse %8 düştü [S31, S40]. **Nike 2000:** ~100 milyon dolar satış kaybı; 400 milyon dolarlık birleşik proje [S31]. **HP 2004:** SAP, 160 milyon dolar sipariş birikimi ve kayıp [S31]. **Waste Management:** 2005 başlayan SAP kurulumu, 2008 dava [S31].
- **FoxMeyer:** SAP R/3 sonrası çöktü; mütevelli SAP'a 500 milyon dolarlık dava açtı, Andersen Consulting'e bir 500 milyon dava daha [S40, Düşük, yıl bilgisi eksik].
- **Lidl "eLWIS" (SAP for Retail/HANA), ~2011-2018:** yaklaşık yedi yıl, yaklaşık 500 milyon euro, 2018'de iptal; Lidl kendi Wawi sistemini sürdürmeyi seçti [S32]. Nedenler tahmin düzeyinde (envanter değerleme çatışmaları, artan maliyet) [S32, doğrulanmamış].
- **Birmingham City Council (Oracle Fusion):** 2018'de başladı; ilk tahmin 19 milyon pound + 1 milyon yedek; Nisan 2022'ye ertelenmiş go-live; 2027/28'e kadar tahmin 144,4 milyon pound (>7 kat); bankacılık mutabakat özelleştirmesi çalışmadı, denetlenebilir hesap çıkaramadı; kurum "kutudan çıktığı gibi" kullanmayı planlamıştı; sorun kurumun özelleştirmesine ve yönetimine atfediliyor [S33]. Denetçi Grant Thornton; kurumun 2023'teki "fiilen iflas" durumuna katkı [S33, arama özeti].
- **Panorama istatistikleri (bağımsız danışmanlık anketi, kendi seçilimli örneklem):** 2015 raporu (5 yıllık ortalama): maliyet ~6,1 milyon dolar, süre 15,7 ay, bütçe aşımı %58, süre aşımı %65, beklenen yararın yarısından azını alan %53 [S34]. 2023 raporu: bütçe aşımı %47, ortanca maliyet 625 bin dolar (TechTarget aktarımı, ikincil) [S35 özetlerinden]. 2024 raporu: yarıdan fazlası bütçe içinde, ortanca maliyet 450 bin dolar (arama özeti, rapor metni "yarıdan fazlası" der) [S35]. 2026 raporu: "dörtte birinden fazlası" bütçe aşımı [S36]. [V düzeltme: "170 yanıt" ve "ortanca proje 9 ay" AÇILAMADI, Panorama bülteninde yok, yalnız bir danışman rehberinde (Düşük); 15,7 aydan 9 aya karşılaştırması geçersiz].
- **SAP göçleri (ISG, 200 karar verici):** göçlerin ~%60'ı gecikmeli/bütçe aşımlı; %49 az ya da hiç yeniden tasarım [S6].

### 7.2 Satıcı çöküşleri, satın almaları, itibar kaybı
- **Baan:** 1995'te Amsterdam ve Nasdaq'ta halka arz, bir ara "yılda %91 büyüme" iddiası; 1998'de ilişkili distribütöre lisans "satışı" yazarak gelir şişirme ortaya çıktı; Haziran 2000'de yedi ardışık zarar çeyreği sonrası Invensys'e 700 milyon dolara; Haziran 2003'te 135 milyon dolara SSA Global'e; SSA 2006'da Infor'a [S29]. Yaklaşık sekiz yılda 700'den 135'e.
- **PeopleSoft/JD Edwards:** bağımsız ürün adları (EnterpriseOne, World) Oracle'da JD Edwards adıyla devam; 11.000 çalışandan 6.000'i çıkarıldı [S28].
- **Oracle Fusion gecikmesi:** 2005 duyuru → 2011 çıkış [S28, S30, S31]. Birinci çıkış tarihi ve "yarıya geldik" beyanı arasında beş yıl.
- **SAP ByDesign:** 2007'de duyuruldu, ~10.000 şirkete ulaştı; 2022'de kapanış söylentisi ve resmi yalanlama [S4]. 15 yıl sonra bile ürün itibarı tartışmalı [DEĞERLENDİREMEM].
- **Epicor:** 2011 Apax, 2016 KKR, 2020 CD&R 4,7 milyar dolar [S17]; **Infor:** 2002'den beri satın alma yığınları (Baan, SSA, Geac, Lawson...), Koch sahipliği [S16].
- **Yerli satıcılar:** Nebim 2024'te Param'a [S21], Mikro 2023'te TeamSystem ortaklığı [S22]; Logo satın alma zinciriyle büyüdü (8 satın alma / 5 yıl) [S39]. Bu satıcılardan hiçbirinin "çöktü" kaydı bulunamadı [BOŞLUK].
- **Eski sürümlerin zorla sonlandırılması:** AX tamamen kapandı (2012 R3 Ocak 2023), NAV/GP/SL tarihleri [S13]; SAP ECC 2027/2030 [S6].

### 7.3 Eleştiriler
- Gartner S/4HANA'yı "dönüşümsel" buldu, ama işlevsellik, kullanılabilirlik, fiyat ve göç sorunları üzerine soru işaretleri koydu [S2].
- "Satıcı değil müşteri" sorun: Birmingham ve Lidl'de eleştiri alıcının özelleştirme/yönetim kararlarına gidiyor; satıcı ürün kusuru değil [S33, S32].
- Panorama: "Bütçe aşımının en sık nedeni ek teknoloji ihtiyacı" [S36]; "gerçekçi olmayan takvim" süre aşımının başlıca nedeni [S34].

**Oyuna ders (7. bölüm):** Başarısızlık üç kaynaktan gelir ve her biri oyuncunun görebileceği bir karar zinciri verir: (1) acele edilmiş kesme zamanı (Hershey), (2) kapsam/özelleştirme şişmesi (Birmingham, Lidl), (3) satıcının kendi ürününün gecikmesi (Fusion). Oyuncuya mekanik: müşteri tarafı proje olayı, "özelleştirme istiyor mu, hazır paketle mi gidiyor" teklifinde; sıklık yenileme başına bir kez en fazla.

---

## 8. "2012'de başlayıp 2030'da biten bir oyunda dönem kilitleri ne olabilir"

Aşağıdaki, kanıtlı olayları oyun kilidi önerisine çevirir. Her satırın sağında kanıt gücü. "Kilit" = o yıldan önce alan/seviye açılamaz ya da müşteri şartı doğmaz.

| Dönem | Kilit / olay | Dayanak | Güven |
|---|---|---|---|
| 2012-2013 | Yerinde (sunucu) standart; bulut, "fark yaratan" yenilik (NetSuite tek örnek); TR'de e-defter gönüllü başlar | NetSuite 10-K 2015, Panorama 2015, e-Defter tebliği 13 Aralık 2011 (gönüllü; "1 Ocak 2012 fiilen başlar" doğrulanmadı) [V düzeltme] | Orta |
| 2013-2014 | e-Fatura (2013) ve e-Defter (2014) geçişi yalnız dar gruplarda zorunlu (421 sıra no, 14.12.2012: madeni yağ ve ÖTV (III) zinciri); ≥10 milyon TL genel grup henüz yok [V düzeltme] | S24 | Orta |
| 2015-2016 | Yeni çekirdek mimari (S/4HANA tipi) tanıtılır, ama müşteri geçişi çok geç; bulut mainstream'e girer; ≥10 milyon TL genel grup için e-fatura zorunluluğu (454 sıra no 20.06.2015 duyuru, 1 Ocak 2016 başlangıç; ilk büyük mevzuat kilidi) [V düzeltme] | S2, S24, S34 | Orta |
| 2016-2018 | Kişisel veri koruma (KVKK/GDPR) uyumu "şart satırı" olur | S26, S27 | Orta |
| 2018-2019 | Yılda iki sürüm ritmi (Business Central) = çıta; sektör haberleri sık | S11 | Orta |
| 2020 | E-arşiv eşiği 5.000 TL ve küçük işletmeye iner; ürün aileleri bölünür; uzaktan çalışma | S25, S11; uzaktan çalışma kanıtsız [BOŞLUK] | Düşük-Orta |
| 2021-2022 | Bulut "olağan", yerinde "özel durum"; bulut tabanlı İK/yetenek yönetimi | S19, S35 | Orta |
| 2023 | **YZ asistanı duyuruları** (Mart/Eylül); benimseme düşük | S12, S8, S35 | Orta |
| 2024-2026 | YZ yaygınlaşmaya başlar; bulut baskın; eski sürüm bitişleri gündemde | S35, S36, S6 | Orta |
| 2027 | ECC ana bakım sonu = bir "eski çıta" biter | S6 | Yüksek (satıcı takvimi) |
| 2028-2031 | SL, GP, ECC uzatılmış destek bitişleri | S13, S6, S1 | Yüksek (satıcı takvimi) |
| 2030 öngörüsü | Ajan tabanlı iş akışları, "her kullanıcı %30 daha verimli" hedefi (SAP kendi hedefi) | S5 (SAP beyanı, analist tahmini) | Düşük [GÖRÜŞ] |

**Tavan ve kilit zamanlaması (Erdem karar 6):**
- Oracle Fusion beş-altı yıl; SAP R/3'ten S/4HANA'ya 23 yıl (1992-2015); Navision 1987'den Business Central 2018'e 31 yıl [S28, S30, S1, S2, S11].
- SAP 2024'te yılda 6,5 milyar euro Ar-Ge ile bile ana ürünün çıtasını 2-3 yılda bir "sürüm" olarak yükseltir [S5, S2].
- Dolayısıyla "tavan" tek bir yıl değil, ardışık çıtalardır; 18 yıllık oyunda 6-8 büyük çıta mantıklı [GÖRÜŞ].
- Kanıtlı kilit örnekleri (yıl, tür): 1999-2002 bulut (oyun başlamadan önce), 2016 e-fatura (≥10 milyon TL genel zorunluluk; 2013-2014 yalnız dar gruplar) [V düzeltme], 2015 yeni çekirdek, 2018 KVKK/GDPR, 2023 YZ, 2027 eski sürüm bitişi.

**Rakip ve devin kilitleri (Erdem karar 2):** Rakip şirket "kopyalamaz"; gerçek dünyada da bulut ve YZ, birkaç büyük satıcıdan bağımsız ve neredeyse aynı yılda duyurulur (Mart/Eylül 2023) [S12, S8]. Bu, kopya yerine "aynı yol haritasını farklı hızda yürütme" fikrini destekler [GÖRÜŞ].

**Oyuna ders:** Kilitleri üç sınıfa ayırmak kanıtlı: mevzuat (yılı belli, eşikli), teknoloji çıtası (satıcı duyurusu, yıl belli, benimseme gecikmeli), bitiş/eski sürüm (takvimli). Oyuncu kararı: hangi çıtaya ne zaman yetişeceği; sıklık: 6-10 kez oyun boyunca.

---

## 9. Sektör ve modül (Erdem karar 4) için kanıt

- SAP modül listesi (FI, CO, AA, SD, CRM, MM, PP, QM, PS, PM, HR, WM) [S1]. NetSuite: ERP/Finans, OneWorld (çok şirketli), CRM, PSA (OpenAir), e-ticaret (SuiteCommerce, InStore POS, Bronto, LightCMS), HCM (TribeHR); ayrıca "ayrıca satılan eklenti modüller" [S10].
- NetSuite dikey sürümleri: toptan/dağıtım, üretim, profesyonel hizmetler, perakende, yazılım (ve kâr amacı gütmeyen, hizmetler) [S10]. Yani "sektör" ürün düzeyinde bir paket seçimidir ve modül listesi sektöre göre farklıdır.
- Odoo: "uygulama" bazlı mağaza, topluluk/kurumsal ayrımı [S14]. Business Central: AppSource uzantıları (raporlama, bordro, üretim) [S11].
- Nebim: dikey (moda/perakende/ayakkabı/optik) derinlik [S20]. Logo: GO (küçük), Tiger (orta), Netsis (orta-üst), j-Platform; bölgesel iş kolları (Logo j-Construction 2020-21) [S19].
- Satış görüşmesinde modül ve koltuk pazarlığı (Erdem karar 4): modül ve koltuk bazlı fiyatlama için ERP'ye özgü resmî fiyat örneği bulunamadı [BOŞLUK]. Business Central'ın 2013'te eşzamanlı kullanıcı lisansına geçtiği biliniyor (NAV 2013) [S11] — koltuk fikrinin ERP lisanslamasında tarihte yeri var.
- Koltuk artışı beklentiyi artırır mı (Erdem karar 5)? Bu soruya ERP'ye özgü kanıt bulunamadı [BOŞLUK]. Panorama'da "ortanca lisans sayısı 150,5" (2024 örneklemi) bir ölçek fikri veriyor [S35].

**Oyuna ders:** Sektör = hangi modüllerin gerekli olduğuna göre bir seçimdir; kanıtlı biçim "dikey sürüm / uzantı". Satışta sıklık: her satış görüşmesinde bir kez.

---

## 10. Oyuna dersler, toplu liste

1. **Beklenti bir istektir, ölçü değil:** mevzuat adımı (e-fatura), eski sürüm bitişi, satıcının yeni çıtası (bulut, YZ) hepsi "şuna ihtiyacımız var / yenilemede şu şart" cümlesine çevrilebilir. Sıklık: yenileme başına 0-1.
2. **Standardı takvimle gösterin:** ilan edilmiş tarihler (destek sonu, mevzuat) satıcının kendi bilinen davranışı; oyuncu ileriye bakıp yatırım yapabilir. Sıklık: yılda 1-2 duyuru.
3. **Geç benimseme kuralı:** liderin çıtası ile ortalama müşterinin çıtası arasında ~8-12 yıl fark vardır; "herkes aynı çıtada" modellenmemeli [S6, S34, S35].
4. **Dev satıcı yüksek başlar, yavaş döner:** SAP 6,5 milyar euro Ar-Ge'ye rağmen ürün sürümleri 1-2 yıl aralıkla çıkar; yeni rakip aynı çıtaya 5-6 yılda varabilir (Fusion) [S5, S2, S30].
5. **Ar-Ge oranı:** gelirin ~%18-27'si, çalışanların %34-48'i Ar-Ge [S5, S10, S18]; rakip simülasyonu için dayanak (yalnız üç örnek).
6. **Gelir/çalışan:** ~128-319 bin birim [S14, S10, S3]; 50 kişilik şirket için gelir aralığı 6-16 milyon (hesap).
7. **Başarısızlık kaynakları:** acele kesme, kapsam şişmesi, satıcı gecikmesi; oyuncuya "bu hesap özelleştirme istiyor" tipi karar [S31, S32, S33].
8. **Bitişler cezadır:** geliştirilmeyen ürün için görünür ceza, "destek bitiş tarihi" [S13, S6].
9. **Yerel mevzuat yerel oyuncuya avantaj verir** (kanıtlı örnek: yerli satıcıların e-defter ürünleri) ama ölçülmüş pay yok [S19, S25].
10. **Girişim yolları:** yeni model (NetSuite) ve açıklık (Odoo); ikisi de 10+ yıl [S10, S14].

---

## 11. Eksikler ve bulunamayanlar

- Mikro, Nebim, Uyumsoft, Netsis: Ar-Ge harcaması, ekip dağılımı, sürüm ritmi bulunamadı.
- Netsis satın alma yılı ve bedeli: Logo raporu aralık verir (2011-2015), diğer kaynaklar çelişkili.
- NetSuite SuiteSuccess yılı, yılda kaç sürüm; Business Central Ar-Ge harcaması; Microsoft 10-K ürün bazında rakam yok.
- RISE with SAP çıkış yılı, SAP HANA/Fiori yılı, SAP Business One müşteri sayısı.
- Uzaktan çalışma 2020'nin ERP'ye etkisi; API/entegrasyon pazarlarının ERP için tarihçesi.
- Panorama'da bulut/yerinde başarı karşılaştırması; 2023 raporunu doğrudan okuyamadım (TechTarget aktarımı ikincil).
- Koltuk artışı ve beklenti ilişkisi (karar 5) ve modül/koltuk bazlı ERP satış fiyatları.
- ERP satıcılarının KVKK/GDPR tepkileri (özellik, yıl).
- Oyunlarda olumsuz Steam yorumu: bu belgenin konusu dışında, ayrı ajanların işi.

---

## Kaynak sicili

Erişim tarihi hepsi için 2026-10-20. Wikipedia sayfalarında "yayın tarihi" sürekli güncellenen sürümdür (erişim anındaki sürüm). "Özet" notu: arama sonucu özetinden alınan kaynakta ilgili sayfayı kendim açmadım.

| S# | URL | Yayıncı | Yayın tarihi | Güven |
|---|---|---|---|---|
| S1 | https://en.wikipedia.org/wiki/SAP_ERP | Wikipedia | sürekli güncel | Orta |
| S2 | https://en.wikipedia.org/wiki/SAP_S/4HANA | Wikipedia (kendi uyarısı: 2025 bölümü kaynaksız iddialar içeriyor) | sürekli güncel | Orta |
| S3 | https://en.wikipedia.org/wiki/SAP | Wikipedia | sürekli güncel | Orta |
| S4 | https://en.wikipedia.org/wiki/SAP_Business_ByDesign | Wikipedia | sürekli güncel | Orta |
| S5 | https://ir-api.eqs.com/media/document/72b51d5c-6d29-4600-b313-5a29f95bee2d/assets/DE0007164600-JA-2024-EQ-E-00.pdf?disposition=inline (orijinal: irpages2.eqs.com/.../DE0007164600-JA-2024-EQ-E-00.pdf) | SAP SE, 2024 Entegre Rapor | 2025 (FY2024; kesin tarih okunmadı) | Yüksek |
| S6 | https://www.theregister.com/2026/02/05/sap_migrations_research/ | The Register | 2026-02-05 | Orta (Gartner ve ISG verisini aktarıyor) |
| S7 | https://www.theregister.com/2026/02/27/dsag_ecc_sap/ | The Register (özet) | 2026-02-27 | Orta (arama özeti) |
| S8 | https://www.constellationr.com/insights/news/sap-launches-joule-generative-ai-copilot-goes-2-year-s4hana-cloud-major-release-cycle | Constellation Research | 2023-09 | Orta (arama özeti) |
| S9 | https://en.wikipedia.org/wiki/NetSuite | Wikipedia | sürekli güncel | Orta |
| S10 | https://www.sec.gov/Archives/edgar/data/0001117106/000111710616000050/a2015netsuiteform10-k.htm | NetSuite Inc., SEC Form 10-K FY2015 | 2016 (FY2015) | Yüksek |
| S11 | https://en.wikipedia.org/wiki/Microsoft_Dynamics_365_Business_Central | Wikipedia (kendi uyarısı: bazı tarihler çelişiyor) | sürekli güncel | Orta |
| S12 | https://blogs.microsoft.com/blog/2023/03/06/introducing-microsoft-dynamics-365-copilot/ | Microsoft | 2023-03-06 | Düşük (satıcı duyurusu; yalnız tarih için) (arama özeti) |
| S13 | https://support.microsoft.com/help/17920 ; https://www.microsoft.com/en-us/dynamics-365/blog/?p=194353 | Microsoft (yaşam döngüsü politikası, GP blogu) | 2024-2025 (kesin tarih okunmadı) | Orta-Yüksek (resmî yaşam döngüsü), arama özeti |
| S14 | https://en.wikipedia.org/wiki/Odoo | Wikipedia | sürekli güncel | Orta |
| S15 | https://www.odoo.com/documentation/16.0/administration/supported_versions.html ; .../15.0/... ; .../14.0/... | Odoo S.A. dokümantasyonu | 2022-2024 | Orta-Yüksek (resmî belge), arama özeti |
| S16 | https://en.wikipedia.org/wiki/Infor | Wikipedia | sürekli güncel | Orta |
| S17 | https://en.wikipedia.org/wiki/Epicor | Wikipedia | sürekli güncel | Orta |
| S18 | https://en.wikipedia.org/wiki/Logo_Yazılım | Wikipedia (kendi uyarısı: ücretli düzenleme/atıf eksikliği) | sürekli güncel | Orta-Düşük |
| S19 | https://cdn.logo.com.tr/files/logocomtr/Uploads/Documents/Faaliyet_Raporu_31_Mart_2025.pdf | Logo Yazılım A.Ş., Faaliyet Raporu 31 Mart 2025 | 2025-05-07 (PDF üst verisi) | Orta-Yüksek (düzenlenmiş kamu açıklaması, şirketin kendi anlatımı) |
| S20 | https://www.nebim.com.tr/en/history | Nebim | sürekli güncel | Düşük (satıcının kendi sayfası) |
| S21 | https://webrazzi.com/2024/10/18/param-nebim-yazilim-in-cogunluk-hissesini-satin-aldi/ | Webrazzi | 2024-10-18 | Orta |
| S22 | https://www.mikro.com.tr/hakkimizda | Mikro Yazılım | sürekli güncel | Düşük (satıcı, kendi içinde çelişkili sayılar) |
| S23 | https://uyumsoft.com/hakkimizda | Uyumsoft | 2025 telif | Düşük (satıcı) |
| S24 | https://www.alomaliye.com/2015/08/25/e-fatura-ve-e-defter-uygulama-kapsami-genisliyor/ | AloMaliye | 2015-08-25 | Orta-Düşük (mali müşavir sitesi, tebliğleri aktarır) |
| S25 | https://www.parasut.com/blog/vergi-mevzuatinda-yeni-duzenlemeler ; https://vergiraporu.com.tr/upImage/org/2014-172-E-Fatura_Gonderme-Alma_Zorunlulugu_Duzenlemesi_Ile_Birlikte_Uygulamanin_Kapsami_Usul_Ve_Esaslari-Mustafa_Serhat_Kocak%20.pdf ; https://www.turmob.org.tr/arsiv/mbs/resmigazete/-VUK454.pdf | Paraşüt blog; Vergi Raporu; TÜRMOB (Resmî Gazete 454 sıra no. metni) | 2014-2025 | Düşük-Orta (arama özeti; TÜRMOB PDF'ini kendim okuyamadım, resmî tebliğ metni olmasına rağmen) |
| S26 | https://en.wikipedia.org/wiki/General_Data_Protection_Regulation | Wikipedia | sürekli güncel | Orta |
| S27 | https://tr.wikipedia.org/wiki/Kişisel_Verilerin_Korunması_Kanunu | Vikipedi | sürekli güncel | Orta |
| S28 | https://en.wikipedia.org/wiki/PeopleSoft | Wikipedia | sürekli güncel | Orta |
| S29 | https://en.wikipedia.org/wiki/Baan_Corporation | Wikipedia | sürekli güncel | Orta |
| S30 | https://en.wikipedia.org/wiki/Oracle_Fusion_Applications | Wikipedia | sürekli güncel | Orta |
| S31 | https://www.computerworld.com/article/2772084/10-famous-erp-disasters--dustups-and-disappointments.html | Computerworld / CIO.com (Thomas Wailgum) | 2009-03-30 | Orta |
| S32 | https://www.consultancy.uk/news/18243/lidl-cancels-sap-introduction-having-sunk-500-million-into-it ; https://www.retaildetail.eu/news/food/lidls-failed-it-project-cost-half-billion | Consultancy.uk; RetailDetail (Handelsblatt'a atıf) | 2018-08 | Orta (arama özeti) |
| S33 | https://www.theregister.com/2026/01/29/birmingham_oracle_latest/ | The Register | 2026-01-29 | Orta-Yüksek (denetçi raporuna dayanıyor) |
| S34 | https://www.panorama-consulting.com/wp-content/uploads/2016/07/2015-ERP-Report-3.pdf | Panorama Consulting Solutions (+Mint Jutras), 2015 ERP Report | 2015 | Orta (562 yanıt, seçilim yanlılığı olası) |
| S35 | https://4439340.fs1.hubspotusercontent-na1.net/hubfs/4439340/Reports/ERP%20Report/2024-erp-report-panorama-consulting-group.pdf | Panorama Consulting Group, 2024 ERP Report (131 yanıt) | 2024 | Orta |
| S36 | https://4439340.fs1.hubspotusercontent-na1.net/hubfs/4439340/Reports/ERP%20Report/2026-erp-report-panorama-consulting-group.pdf | Panorama Consulting Group, 2026 ERP Report (170 yanıt [V uyarı: AÇILAMADI]) | 2026 | Orta |
| S37 | https://en.wikipedia.org/wiki/Enterprise_resource_planning | Wikipedia | sürekli güncel | Orta |
| S38 | https://www.techtarget.com/searcherp/news/366616112/Cloud-ERP-is-deployment-choice-for-top-tier-systems | TechTarget (Gartner 2023 aktarımı + kendi anketi) | 2024-2025 | Orta (arama özeti) |
| S39 | https://www.ekonomist.com.tr/makale/bolgesel-guc-olma-adimlari-atiyoruz-1802 | Ekonomist (Logo CEO röportajı) | 2016 | Orta-Düşük (arama özeti) |
| S40 | https://www.thirdstage-consulting.com/?p=2070 ; https://whatfix.com/blog/?p=18031 | ERP danışmanlık ve yazılım satıcısı blogları (FoxMeyer, Hershey, Waste Management) | belirsiz | Düşük (ikincil, rakamlar çelişkili) |
| S41 | https://xorosoft.com/erp-implementation-statistics/ | Xorosoft (ERP satıcısı bloğu, Panorama 2026 özeti) | 2026 | Düşük |
| S42 | https://www.zunapro.com/turkey/tr/blog/muhasebe-programi-entegrasyonu-e-ticaret-rehberi | Zunapro (e-ticaret yazılımı, pazarlama içeriği) | belirsiz | Düşük (Logo pay iddiası, SAP %44,5 iddiası; bağımsız kaynağı yok) |
