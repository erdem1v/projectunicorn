# V · Şüpheci doğrulama (Pazar 2): A1, A2, A3, B1, B2, K

Tarih: 2026-10-20. Arama: 12/12 WebSearch kullanıldı. Ayrıca WebFetch ve elle indirip okuma (SEC, PDF, Wikipedia). Oyun koduna yazılmadı; K için yalnız okuma/grep yapıldı.
Etiketler: DOĞRULANDI (kaynağı açıp okudum, rakam tutuyor) · KISMEN (tutuyor ama yorum/atıf/kapsam kaymış) · YANLIŞ · AÇILAMADI (birincil kaynağa ulaşamadım ya da bulamadım). "Birincil" = yasa/10-K/20-F/Eurostat/Microsoft fiyat sayfası/ham rapor. Not: WebFetch PDF'leri çözemedi; PDF'leri diske alıp `pdftotext` ile okudum (Ebsta, Grant Thornton, KPMG).

---

## 0. Bir bakışta (ilk 12 satır)

1. **En ağır hata A1'de, mevzuat zaman çizelgesinde.** "2014: e-Fatura/e-Defter ZORUNLU (421 sıra no), brüt satış ≥ 10 milyon TL" YANLIŞ. 421 sayılı tebliğ 14.12.2012'de çıktı ve yalnız dar gruplara zorunluluk getirdi; ≥ 10 milyon TL genel grubu 454 sayılı tebliğle (20.06.2015) geldi ve fiilen 1 Ocak 2016'dan başladı. Oyun 1 Ocak 2012'de başladığı için "ERP'ye e-fatura modülü ne zaman şart olur" kilidi tam bu yıllara bağlı (madde 2).
2. A1'in ve A2'nin "Panorama 2026: ortanca proje 9 ay, 170 yanıt" iddiası AÇILAMADI. Panorama'nın basın bülteni yalnız "dörtte birinden fazlası bütçeyi aştı, ilk neden ek teknoloji ihtiyacı" diyor. 9 ay ve 170 yanıt yalnız bir danışman rehberinde (Rework, Düşük) geçiyor; ben iki ayrı aramada tutarlı bir doğrulama bulamadım (madde 7).
3. Sayısal olarak sağlam çıkanlar: SAP 2024 (Ar-Ge 6.514 M€, %19,1, 37.590 FTE), NetSuite FY2015 10-K (741,1 M$, 4.603 çalışan, ürün geliştirme 135,5 M$), Ebsta "altın dönem" ve "2 katı = %3", Eurostat ERP oranları (%38 / %86), Business Central fiyatları, Birmingham 19 → 144,4 M£, OpenTTD eskime/2050 dondurma, Sunshine Mills 61,4 M$.
4. **Koltuk bantları, kazanma oranları (yıldız başına), satışçı yıldızı etkileri, yenilemede koltuk değişimi, sektör x modül matrisi: gerçek ERP verisiyle doğrulanamıyor.** A2 ve A3 bunu kendileri de itiraf ediyor; ben bağımsız aramada da ERP'ye özgü koltuk, yenileme ve genişleme verisi bulamadım. Bunlar "türetilmiş varsayım" olarak kalmalı, "gerçek dünyada böyle" diye sunulmamalı.
5. Sektör x modül matrisinin tamamı tek yayıncıdan (ERP Research) geliyor. Yayıncı kendini "bağımsız" ilan ediyor ama sayfada satıcı/ortak eşleştirme formu ve reklam bağlantısı var; 50/100 toplayıcı eşiğinin veri dayanağı sayfada yok. Dış doğrulama: yalnız NetSuite'in beş dikey sürümü (madde 13).
6. Capitalism Lab yetişme formülü doğru aktarılmış, ama sayfa formülün AI rakiplere de uygulandığını söylemiyor. B1 ve B2'nin "herkese aynı kural" yorumu dayanaksız (madde 18).
7. Eski veri güncelmiş gibi kullanılanlar: Software Inc geliştirici sözü 2016 (alfa dönemi; oyun 2025'te hâlâ yama alıyor), SAP destek ücreti %22 (2008), Panorama 2010 ve 2015, SaaS Capital elde tutma verisi 2020, Verbeke meta-analizi 1982-2008 verisi. A2 çoğunu yıl etiketiyle vermiş; ama tasarım önerilerinde aynı ağırlıkla kullanılmış.
8. Tek satıcı kaynağı taşıyanlar: Ebsta (kendi yazılımını satıyor; örnek geniş: 3,2 milyon fırsat), ERP Research (sektör matrisi), NetSuite/SYSPRO anketleri, A2'deki fiyat blogları.
9. Başarısız örnekler gerçekten var ve kaynaklı (Sunshine Mills, Birmingham, Haribo, Revlon, Lidl, Hershey, Waste Management). Ama Panorama'nın kendi cümlesi: hiçbir vaka sektöre özgü işlev eksikliğine bağlanmıyor. Yani "sektörde modül eksik diye başarısız oldu" örneği yok; A3 bunu doğru not etmiş.
10. K (kod haritası): kontrol ettiğim her noktada kodla birebir tuttu (madde 19).
11. Tasarıma doğrudan etkisi olan düzeltmeler: (a) e-fatura kilidi tarihleri (madde 2); (b) "9 ay" gerçeklik dayanağı olarak kullanılmamalı; (c) S/4HANA ECC "%39" ifadesi yanlış okunmaya açık (madde 3); (d) NetSuite "bulut tam suit yok" ifadesi satıcının inancı ve "büyük rakipler" için (madde 5).
12. Önerilen kullanım: bölümlerdeki "DOĞRULANDI" satırlarına tasarımda dayanılabilir; "KISMEN" satırlar yalnız yön olarak; "AÇILAMADI" ve türetilmiş sayılar [WORKING] sabit olarak kalibrasyona gider.

---

## 1. Tablo

| # | İddia (nerede) | Karar | Kısa kanıt |
|---|---|---|---|
| 1 | Satış döngüsü "altın dönem": küçük 31-60, orta 61-90, büyük 150-180 gün; ortalama döngünün 2 katı açık kalan fırsatın kapanma şansı %3 (A2 S10) | DOĞRULANDI | Ebsta PDF'i metne çevirdim. |
| 2 | e-Fatura/e-Defter 2014'te zorunlu, ≥10 milyon TL, 421 sıra no (A1 tablo + §3.2 + §8) | YANLIŞ (atıf ve yıl) | Grant Thornton 2015/64 ve KPMG 2013 PDF'leri. |
| 3 | SAP ECC: ~35.000 müşteri, %39 (A1 S6) | KISMEN | Yalnız ikincil (CIO/Gartner aktarımı). |
| 4 | SAP 2024: Ar-Ge 6.514 M€, %19,1, 37.590 FTE, %34, bulut 17,1 mlr € (A1 S5) | DOĞRULANDI | SAP 20-F FY2024. |
| 5 | NetSuite FY2015: 741,1 M$, 4.603 çalışan, ürün geliştirme 135,5 M$; "bulut kapsamlı suit sunan yok" (A1 S10) | rakamlar DOĞRULANDI, beyan KISMEN | 10-K metni. |
| 6 | Odoo: 282 M€ gelir (+%33), 2.200+ çalışan, 5,26 mlr $ değerleme (A1 S14) | DOĞRULANDI (Wikipedia, Orta) | 17.0 tarihi doğrulanmadı. |
| 7 | Panorama 2026: ortanca 9 ay, 170 yanıt, bulut sabit (A1 S36, A2 S3) | AÇILAMADI | Bülten bunları içermiyor. |
| 8 | Eurostat 2023: ERP kullanan küçük işletme %38, büyük %86 (A2 S18) | DOĞRULANDI | Eurostat sayfası. |
| 9 | Business Central: Essentials 80, Premium 110, Team Member 8 $/ay (A2 S15) | DOĞRULANDI | Microsoft fiyat sayfası. |
| 10 | Birmingham: 19 M£ → 144,4 M£ (A1 S33); Sunshine Mills 61,4 M$ (A2 S21); Haribo/Revlon/Lidl/Hershey (A3 S16) | DOĞRULANDI | Register, Computerworld, Panorama. |
| 11 | GP 31 Ara 2029 / 30 Nis 2031; SL Temmuz 2028 (A1 S13) | DOĞRULANDI (nüansla) | Microsoft yaşam döngüsü özeti. |
| 12 | Verbeke 2011 β değerleri (A2 S33) | DOĞRULANDI (özet düzeyi) | "Deneyim" iddiası doğrulanmadı. |
| 13 | Sektör x modül eşikleri: 50/100 toplayıcı; matris (A3) | KISMEN (tek yayıncı) | ERP Research sayfası. |
| 14 | OpenTTD: 1-2 yıl yükseliş, "on-yirmi yıl" düşüş, 2050'de dondurma, 0-511 gün rastgele (B2) | DOĞRULANDI | OpenTTD wiki, NewGRF spec. |
| 15 | Game Dev Tycoon 35 yıl, süre sonrası puan + platform çıkışı durur (B2 S1) | DOĞRULANDI | Greenheart SSS. |
| 16 | Big Ambitions: geliştirici "7 kat olmamalı", "büyük bir etken" (B1 S5) | DOĞRULANDI | Steam konusu. |
| 17 | Software Inc: AI hisseyi yalnız iflastan kurtulmak için kullanır; "yalnız başarılı şirketler" (B1 S24) | DOĞRULANDI ama ESKİ (2016) | Steam konusu. |
| 18 | Capitalism Lab yetişme formülü; rakiplere de uygulanır gibi (B1 S2, B2 S38) | formül DOĞRULANDI, rakiplere uygulama AÇILAMADI | Resmî sayfa. |
| 19 | K: yıldız tavanı 3, SEAT_BAND, START_DATE 2012, rivals [3,5,6], CLOSE_CURVE vb. | DOĞRULANDI | Kod. |
| 20 | Koltuk bantları (3-10 … 300-1000), yıldız başına kapanış %, satışçı yıldızı etkileri (A2 §1.3, §3.4, §4.2) | AÇILAMADI (türetilmiş) | Bağımsız ERP verisi yok. |

---

## 2. e-Fatura / e-Defter tarihleri (A1 §2, §3.2, §8; A3 §4) · YANLIŞ

Neden yük bindiriyor: oyun 1 Ocak 2012'de başlıyor; "mevzuat kilidi" hangi yılda hangi müşteriye "e-fatura çıktısı yoksa yenilemem" dedirtir, buna bağlı.

Açıp okuduklarım:
- 397 sıra no: Resmî Gazete 5 Mart 2010, sayı 27512; e-Fatura ilk aşamada gönüllü, pilot (bazı telekom ve doğalgaz şirketleri). TÜRMOB özeti üzerinden (arama sonucu, tebliğ metnini açmadım).
- Elektronik Defter Genel Tebliği (Sıra No: 1): Resmî Gazete 13 Aralık 2011, sayı 28141; başlangıçta mükellefin ihtiyarında (gönüllü). A1'in "13 Aralık 2011" tarihi tutuyor; "1 Ocak 2012 fiilen başlar" kısmı doğrulanmadı.
- 421 sıra no: **14.12.2012**, RG 28497 (KPMG 2013 özeti). İlk ZORUNLULUK budur ve dardır: madeni yağ lisansı sahipleri ile bunlardan mal alan ve 31/12/2011 itibarıyla asgari 25 milyon TL brüt satışı olanlar; ÖTV (III) sayılı liste mallarını (kolalı gazoz, tütün, alkollü içecek) imal/inşa/ithal edenler ile bunlardan mal alan ve asgari 10 milyon TL brüt satışı olanlar. Geçiş: e-Fatura 2013 takvim yılı (1/9/2013'e kadar başvuru), e-Defter 2014.
- 454 sıra no: **20.06.2015**, RG 29392 (Grant Thornton sirküleri, PDF'ten okudum): 421'e ek olarak "2014 veya müteakip hesap dönemleri brüt satış hasılatı 10 Milyon TL ve üzeri olan mükellefler" (+ EPDK ÖTV I lisanslıları + ÖTV III imalatçıları). 2014 hesap döneminde bu eşiği sağlayanlar **01/01/2016**'dan, 2015 ve sonrasında sağlayanlar ilgili beyanname tarihini izleyen hesap döneminin başından itibaren geçmek zorunda. İhracat faturaları 01/01/2016'dan e-Fatura.

Sonuç: A1 "2014 · ZORUNLU (421) · ≥10 milyon TL" satırı iki şeyi karıştırmış: eşik 454'ten, tarih 2016'dan; 421 ise 2012'de çıkan ve dar bir gruba 2013'te zorunluluk koyan tebliğ. Doğru çizelge:
- 2010 Mart: gönüllü e-Fatura (397). 2011 Aralık: gönüllü e-Defter. Oyunun başladığı Ocak 2012'de hiçbir müşteriye zorunlu değil.
- 2012 Aralık / 2013-2014: dar gruplara zorunlu (yağ, tütün/alkol zinciri).
- 2015 Haziran duyuru, 2016 Ocak başlangıç: ≥10 milyon TL genel grup ve ihracat. ERP için gerçek "olmazsa olmaz" dönüm noktası bu.
- 2018-2022 arası eşik 5 → 4 → 3 milyon TL ve e-ticaret 1 milyon → 500 bin TL: Paraşüt blogu (Düşük-Orta, birincil değil) böyle diyor; aldığım parça: "2022 ve müteakip hesap dönemleri için 3 Milyon TL ve üzeri", "2022'den itibaren 500 Bin TL", e-Defter "2025 itibarıyla bilanço usulü tüm mükellefler", e-Defter/e-Fatura'ya bağlı olanlar 1 Ocak 2026. Paraşüt kendi içinde tarih tutarsızlığı taşıyor (A3 de bunu not etmişti). A3'ün "e-Fatura 2010 mu 2014 mü" açık sorusu (§8 madde 5) yanıtlandı: 2010'da gönüllü başladı, 2014'te "zorunlu oldu" cümlesi yanlış.
- A3'ün tablo satırındaki "10 milyon TL" e-İrsaliye için (Paraşüt: "e-İrsaliye bölümünde 2021 ve sonrası e-Fatura kullanıcıları") ayrı bir eşik; e-Fatura ile karıştırılmamalı.

Birincil metinlerin (GİB/Resmî Gazete) kendisini açamadım; yukarıdakiler iki bağımsız danışmanlık özetinin (Grant Thornton, KPMG) örtüşmesine dayanıyor. Orta-Yüksek güven.

Tasarım etkisi: "dönemde birkaç kez, hepsi öngörülür" önerisi (A1 §3.2) tutuyor; ama ilk büyük mevzuat kilidi oyunun 3. yılına (2015 duyuru, 2016 geçiş) denk gelir, 2014'e değil. Not: oyunun bir oyun yılı yaklaşık 52 tik.

---

## 3. SAP ECC "35.000 müşteri / %39" (A1 §0 madde 3, §3.5) · KISMEN

- Arama sonucu: aynı sayılar CIO'nun Gartner aktarımına dayanan bir blogda ("yaklaşık 35.000 ECC müşterisi; 2024 sonunda yaklaşık %39'u S/4HANA'ya geçmişti; mevcut hızla 2027'de ~17.000 geride kalacak"). Birincil Gartner veya SAP belgesi bulunamadı; arama aracı da öyle belirtti.
- **Yorum hatası riski:** A1 "hâlâ ~35.000 ECC müşterisinin %39'u geçmemişti" yazıyor. Kaynağa göre %39 geçmişti (%61 geride). Cümle "%39'u bile geçmemişti" gibi okunabilir; düzeltilmeli.
- ECC ana bakım 2027, uzatılmış destek 2030'a kadar +%2 destek ücreti primiyle: ikincil kaynakta tutarlı.
- Birincil rakamlar (SAP 20-F): 2024'te bulut geliri 17.141 M€ (+%25), Cloud ERP Suite 14.166 M€ (+%33). Yani A1'in "17,1 mlr" doğru.

---

## 4. SAP 2024 ölçek rakamları (A1 §1.1, §5) · DOĞRULANDI

SAP SE Form 20-F FY2024'ü indirip okudum: Ar-Ge -6.514 M€ (2023: 6.324), IFRS Ar-Ge oranı %19,1 (2023: %20,3), geliştirmede tam zamanlı eşdeğer çalışan 37.590 (2023: 36.444), toplam çalışanın %34'ü. Düzeltme: A1'in "2024'te 107.155 çalışan" değeri **ay sonu ortalaması**; yıl sonu başka bir satırda 107.602. Fark küçük, gelir/çalışan 319 bin € hesabını etkilemez.

Çıkarım uyarısı: "%18-27 Ar-Ge oranı üç ölçekte" (SAP %19,1 yıl 2024; NetSuite %18,3 yıl 2015; Logo %27 yıl 2021): ilk ikisini doğruladım (NetSuite: 135,5 / 741,1 = %18,3); Logo'yu (Wikipedia) açmadım. Üç farklı yıl, üç farklı ölçüm tanımı, üç örnek; A1'in kendisi de "SIÇRAMA riski" diyor. Rakip şirkete "gelirin ~%20'si Ar-Ge" demek makul bir başlangıç ama kalibrasyon girdisi olarak kalmalı.

---

## 5. NetSuite 10-K FY2015 (A1 §1.2, §6) · rakamlar DOĞRULANDI, beyan KISMEN

10-K'yi (SEC, a2015netsuiteform10-k.htm) indirip okudum: gelir 741,1 M$ (2004: 17,7 M$); çalışan 4.603 (ürün geliştirmede 1.058); ürün geliştirme gideri 135,5 / 106,7 / 78,3 M$ (2015/2014/2013); kurulduğu yıl 1998; "aşamalı sürüm süreci" doğru; beş endüstri sürümü: toptan/dağıtım, üretim, profesyonel hizmetler, perakende, yazılım. (A1 "kâr amacı gütmeyen, hizmetler" de ekliyor; bu parçayı metinde bulamadım, KISMEN.)

Beyan: A1 özette "bulut tam suit sunan başka kimse yok" diyor. 10-K'nın cümlesi: "Although **we believe** that none of our **larger** competitors currently offer a cloud-based comprehensive business management suite, we face significant competition ...". Yani (a) satıcının kendi inancı, (b) yalnız "daha büyük rakipler" için, (c) aynı cümlede "bazı büyük rakipler benzer ürünler duyurdu" deniyor. A1 §1.2'de yaklaşık doğru anlatmış, özet satırında kısaltmış. Hüküm: "NetSuite devin bulutta eksiğini hedefledi" hikâyesi 10-K'dan çıkar; "sektörde başka bulut suit yoktu" çıkmaz.

---

## 6. Odoo (A1 §1.2) · DOĞRULANDI (Orta)

Wikipedia: 2023 geliri 282 M€ (+%33), 2.200+ çalışan; Kasım 2024'te ikincil hisse turu, değerleme 5,26 mlr $'a kadar (500 M$ tur); 2019'da 90 M$; 2021'de 5 milyon+ kullanıcı; 2005 TinyERP; 19.0 sürümü 18 Eylül 2025. 17.0 tarihi (Kasım 2023) bu sayfada yok, açılmadı (A1 resmî belge diyor: S15, ben açmadım). Wikipedia ikincil; şirketin kendi açıklamasına dayanıyor olabilir.

---

## 7. Panorama 2026: "ortanca 9 ay, 170 yanıt" (A1 §7.1, A2 §3.1) · AÇILAMADI

- Panorama'nın 4 Mart 2026 basın bülteni ve rapor sayfası: yalnız "dörtte birinden fazlası bütçeyi aştı", "ek teknoloji ihtiyacı birinci neden", "iş zekâsı en yaygın dijital girişim, %55,3". Yanıt sayısı, süre ve bulut payı bu sayfalarda yok (rapor indirme formunun arkasında).
- İki aramada çelişik özet: biri "9 ay 2025 raporunda ortalama olarak 15,5 aydan düştü" dedi; ikincisi aynı iddiayı bulamadı ve 15,5 ayı **2023** raporunun ortancası olarak bir rehbere atfetti. Hiçbirini birincil kaynakta göremedim.
- A1 "15,7 aydan 9 aya" karşılaştırması 2015 raporunun 5 yıllık ortalaması ile belirsiz bir 2026 ortancasını karıştırıyor; A1 bunu "örneklem/tanım değişti" diye kendisi de işaretlemiş.
- Hüküm: "kurulum süresi büyüklükle büyür" (A2 §3.1: küçük 3-6 ay … kurumsal 12-24 ay) için gerçek dünya dayanağı yalnız Düşük güvenli danışman blogları (ERP Research, Rework). Oyun içi kurulum süresi kalibrasyon girdisidir.

---

## 8. Eurostat (A2 §1.1) · DOĞRULANDI

"2023'te ERP yazılımı kullanan işletme oranı küçük (10-49 çalışan) işletmelerde %38, büyüklerde (250+) %86." Orta işletme değeri yalnız grafikte, metinde yok. AB tanımı sınıfları (mikro <10, küçük <50, orta <250) Komisyon sayfasından; açmadım ama bilinen resmî tanım.

---

## 9. Business Central fiyatları (A2 §1.2, §2) · DOĞRULANDI

Microsoft fiyat sayfası: Essentials 80 $, Premium 110 $, Team Member 8 $ / kullanıcı / ay, yıllık faturalı; sayfa "yalnız bilgi amaçlı, ödemede gerçek fiyat görünür" diyor. A2'nin çıkarımı "gerçek ERP'de koltuk tek tip değil; sınırlı kullanıcı tam kullanıcının yaklaşık onda biri" tutuyor. Fiyat ABD liste fiyatı ve bugünün fiyatı; 2012 için değil (NAV 2013 eşzamanlı kullanıcı lisansı geçişi ayrı olgu, açılmadı).

---

## 10. Başarısız örnekler (A1 §7, A2 §6, A3 §6) · DOĞRULANDI

- **Birmingham / Oracle:** The Register (29 Ocak 2026): konsey yazılı yanıtı, 2027/28'e kadar toplam öngörü 144,4 M£, ilk tahmin 19 M£ + 1 M£ yedek. Dikkat: bu bir **öngörü**, kesin toplam değil; başka haberlerde 171 M£ ve "20 M£'den 170 M£+'a" çıkıyor. 2024'te 2018/19-2025/26 için onaylanan bütçe 131 M£. Suçun ağırlığı konseyin özelleştirmesinde/yönetiminde (A1 böyle yazmış).
- **Sunshine Mills / Ross (Computerworld, 6 Aralık 2010):** jüri 61,4 M$ (16,4 tazminat + 45 cezai), proje 2005'te başladı, davacının avukatına göre demolar "ayarlandı" ("Murrayware"), "depolama ve dağıtım maliyetini %50'ye kadar düşürür" vaadi; Ross dolandırıcılığı reddediyor. Davacı iddiası ile jüri kararı ayrı: A2 doğru ayırmış.
- **Panorama "10 başarısız ERP" (9 Eylül 2025, Bill Baumann):** Haribo satış "yaklaşık %25" düştü; Revlon "yaklaşık 64 M$ net satış"; Lidl "yaklaşık 580 M$ toplam kayıp, yedi yıl", neden olarak eski süreçleri değiştirmeme (sayfa "iptal edildi" demiyor; A1 "iptal 2018, 500 M€" başka kaynak S32'den, onu açmadım); Waste Management 2008'de 100 M$ dava, sonra 500 M$'a çıkarıldı, 2010'da mahkeme dışı uzlaşma; Hershey Ekim 1999, 100 M$ sipariş, hisse %8; National Grid toparlanma 585 M$ (A2'nin "Wipro 75 M$ uzlaşma" ayrı bir olgu, IEEE Spectrum, açılmadı).
- Kritik cümle: sayfa **hiçbir başarısızlığı sektöre özgü işlev eksikliğine bağlamıyor** (nedenler: eski süreç direnci, gerçekçi olmayan takvim, zayıf test, satıcının yanlış çıkan iddiası). A3'ün aynı tespiti doğru. Sonuç: "bu sektöre uygun modülü olmayan ürün satıldı ve patladı" türünde bir başarısız örnek bulunamadı; bu bir BOŞLUK, kanıt değil.

---

## 11. Microsoft/SAP destek bitiş tarihleri (A1 §3.5) · DOĞRULANDI (nüansla)

Arama (Microsoft yaşam döngüsü sayfaları özetleri): Dynamics GP ürün geliştirme, vergi güncellemesi, teknik destek 31 Aralık 2029; güvenlik yamaları 30 Nisan 2031 (sayfa önceki 30 Eylül 2029 tarihini bunun yerine koyduğunu söylüyor). Dynamics SL: ana akım destek 11 Temmuz 2023'te bitti; **genişletilmiş (güvenlik) destek** 11 Temmuz 2028'e kadar. A1 "SL 2018 genişletilmiş destek Temmuz 2028" diyor: doğru, ama "destek bitişi" diye okunmamalı, yalnız güvenlik. AX 2012 R3 Ocak 2023 ve NAV tarihlerini açmadım. ECC 2027/2030: madde 3.

---

## 12. Verbeke ve ark. 2011 (A2 §4.1) · DOĞRULANDI (özet), çıkarım KISMEN

JAMS 39(3):407-428, DOI 10.1007/s11747-010-0211-8, 1982-2008 çalışmaları. Beş anlamlı alt kategori: satışla ilgili bilgi β=0,28; uyum yeteneği 0,27; rol belirsizliği -0,25; bilişsel yetenek 0,23; işe bağlılık 0,23. A2'nin "deneyim bu beş arasında değil" cümlesi özetle uyumlu ama "deneyim anlamsız" demek için tabloları görmem gerekirdi (açılamadı). Ayrıca bu **genel** satış performansı meta-analizi, ERP satışı değil, 18 yıllık bir veri aralığı. A2 bunu "kıdem tek başına zayıf belirleyici" için kullanmış; yorum, [SIÇRAMA]: A2 zaten "varsayım" diye etiketlemiş.

---

## 13. Sektör x modül (A3) · KISMEN (tek yayıncı)

Açtığım sayfa: ERP Research "dağıtım" sayfası.
- 50/100 toplayıcı: sayfada var ("fewer than roughly 50 pickers → ERP-native warehouse module usually sufficient"; "100+ pickers, zone or wave picking, automation → dedicated WMS typically better"). 50-100 arası belirsiz bırakılmış; başka koşullar da sayılmış. **Sayfada bu eşiklerin veri dayanağı yok**, "WMS ile kâğıt toplama farkı %25-40" için de kaynak yok. Yayıncı "bağımsız karşılaştırma, satıcıdan bağımsız, sıralama satın alınmaz" diyor, ama sayfada "gereksinimlerinizi paylaşın, sizi satıcı ve ortaklarla eşleştirelim", "ERP Research bilgilerinizi dizindeki uygulama ortaklarıyla paylaşabilir", "Find Partners", "Get Pricing", "Advertise With Us" var: lead-generation yapısı. Gelir modeli sayfada yazmıyor; bu kısım çıkarım.
- A3 matrisi ("Z/S/N") kaynak listelerinden yapılmış **sınıflama**; A3 bunu açıkça yazıyor. Ben dokuz sayfanın yalnız birini açtım; diğer sekizi açılmadı (imalat, perakende, hizmet, e-ticaret, sağlık, inşaat, kamu, hastane).
- Dış doğrulama: NetSuite'in beş endüstri sürümü (madde 5) bu sektör ailelerinden dördüyle örtüşüyor (dağıtım, üretim, hizmet, perakende) + yazılım. Yani "sektöre göre modül paketi" fikri gerçek bir ürün pratiği; ama hangi modülün hangi sektörde zorunlu/sık/nadir olduğu için bağımsız ölçüm yok. Panorama'nın modül kırılımı (A3 BOŞLUK) hâlâ yok.
- "Sağlık firması lojistik modülü almaz" (Erdem örneği) için kanıt: hastane sayfasını açmadım; kısmen A3 sağlık tedarik zincirinin (malzeme, ilaç) olduğunu söylüyor. Mantık olarak makul, ölçüm yok.

---

## 14. OpenTTD ve eskime (B2 §2.6) · DOĞRULANDI

- Wiki (Manual/Vehicles): yeni model düşük azami güvenilirlikle başlar, "bir iki yıl" yükselir, tepede uzun süre kalır, "bir iki on yıl düşüşten sonra" (metin: "after a decade or two of decline") satıştan çekilir; başlangıç, tepe ve son değerler her oyunda rastgele; "2050 yılında tüm modellerin azami güvenilirliği oyun sonuna dek dondurulur"; "Never expire vehicles" açıksa her modelin azamisi tepe değerinde donar. Prototip olarak başlayanlar daha düşük başlar.
- NewGRF spec: tanıtım tarihine her yeni oyunda 0-511 gün eklenir ("OpenTTD r16929'dan beri oyunun ilk iki yılında rastgeleleştirilmez"); model ömrüne 31 ay ile 17 yıl arası rastgele süre eklenir. Bunlar NewGRF **özellik tanımı**; yani her araç seti (GRF) kendi tarihini yazar, rastgele pay motor tarafından eklenir. B2 bunu "yıl kilidine ±511 gün" önerisinin dayanağı yapmış: makul ama oyunun ilk iki yılında rastgele pay yok.
- "Oyuncular eskimeyi kapatan ayar yazmış" (B2 özet 6): ayar var; oyuncu tepkisi sayfada yok. [SIÇRAMA], B2 de "neden eskitildiği yazmıyor [BOŞLUK]" demiş. Hüküm: ayarın varlığı = bir kısım oyuncunun eskimeyi istemediği çıkarımı; tepkinin boyutu bilinmiyor.

---

## 15. Game Dev Tycoon (B2 §2.1) · DOĞRULANDI

Greenheart SSS: "Can I play longer than 35 years?" sorusu 35 yılın varsayılan olduğunu ima ediyor; süre dolunca puan hesaplanır, platform çıkışı durur, oynama ve açma sürer; süre ayarı kayıtta değişmez. "301. yıl" yapımcı satırı (Steam) açılmadı.

---

## 16. Big Ambitions (B1 §4) · DOĞRULANDI (geliştirici satırı), tetik mekaniği AÇILMADI

Steam konusu: geliştirici 4 Tem 2024: rakip mağazalar biraz daha optimize olabilir ama "7 kat fark olmamalı, hayır"; fiyatlar oyuncununkine ve özel rakiplere tepki veriyor; 5 Tem: rakip fiyatlar gece yarısı eski haline dönmeye çalışıyor, günler sürebilir; 11 Tem: "rakip satışlarını saçma yükselten büyük bir etken bulduk", EA 0.6'da düzeltilecek. Geliştirici "rakipler oyuncuyla aynı kurallara tabi" demiyor; bunu B1 de doğru aktarmış. "Üç mağaza açınca büyük rakip aktif olur" (B1 S4) GamesHorizon rehberinden; açmadım.

---

## 17. Software Inc (B1 §1) · DOĞRULANDI ama ESKİ

Geliştirici Coredumping, 11 Ocak 2016: "oyun yalnız 'başarılı' şirketleri simüle ediyor", AI hisseyi "yalnızca kendini iflastan kurtarmak için" kullanıyor, çok hissesi olan şirket onu satın almaya çalışır. B1 bunu bugünkü tasarım gibi sunmuş. Aynı sayfa 2016, oyun o zaman erken erişimdeydi; B1'in kendi kaynak sicilinde 2025'te (1.8.31) yorum sisteminin değiştiği yazıyor. Yani kural bugün aynı olabilir de olmayabilir de; "eski veri güncelmiş gibi" örneği. Football Manager sayfası için (B1 §5): sayfa "AI kulüpler de aynı finans kurallarına tabi" demiyor, B1 de bunu "yazıda geçmiyor" diye doğru kaydetmiş.

---

## 18. Capitalism Lab yetişme formülü (B1 §2, B2 §2.7) · formül DOĞRULANDI, kapsam AÇILAMADI

Resmî Digital Age DLC sayfası: "Ek teknoloji kazancı = temel kazanç × (en yüksek seviye − seninki) ÷ en yüksek seviye", örnek 50 / 500 / 30 → 27 → toplam 57; tetik "rakibin seviyesi 100'ü aşınca ve seninki belirgin düşükken". Sayfa yalnız yazılım ve internet şirketleri (DLC içeriği) hakkında; AI rakiplere aynı formülün uygulandığı yazılı değil. B1 "herkes için aynı formül gibi anlatılıyor" ve B2 "rakip ve oyuncu aynı kart listesini farklı hızla yürütürken geride kalan için" diyor: sayfada ikisi de yok. Tasarım notu: bu bir **oyuncu tarafı** yetişme çarpanı; Erdem'in "kopyalama yok" kararıyla çelişmez ama rakiplere de uygulandığına dair kanıt yok.

---

## 19. K · Kod haritası · DOĞRULANDI

Grep ve dosya okumasıyla kontrol ettim (HEAD ile aynı ağaç): `ProductQuality.STAR_MAX := 3` (product_quality.gd:21), `SalesConstants.STAR_MAX := 3` (sales_constants.gd:45), `SEAT_BAND` 1-3 (5-10, 15-30, 40-70; :115-119), `DEAL_BASE_WEEKS` 1..5 (2, 3, 6, 8, 12; :152), `START_DATE` 2012-01-01 (game_state.gd:8), `TIER_MAX := 3` ve `steps.size() != TIER_MAX` doğrulaması (product_lines.gd:20, :155-156), `rivals.json` erp `rivals = [3, 5, 6]` ve 11 çıkış sprint numarası [4, 7, 10, 13, 17, 21, 25, 30, 35, 41, 47]; `NAMES["erp"]` sırası ile [3,5,6] = Ardenna, Raketenhaus, Sumpter (hepsi startup, dev ve yerleşikler çıkış tablosunda yok); `CLOSE_CURVE := [[40,0.30],[55,0.60],[70,0.85],[80,0.95]]` (product_quality.gd:30); `"late"` yalnız sprint_bridges.gd:30'da yazılıyor, okuyan ceza yok (scripts altında başka `"late"` okuması bulunamadı; debug dışı). Sayısal ayrıntılar (tolerans formülü, SOFT_CAP_WEEK 104, `HRConstants.STAR_MAX := 5`) K dosyasında; `STAR_MAX` farkı (HR 5, satış/ürün 3) doğrulandı.

---

## 20. Yük taşıyan ama kaynaksız kalanlar (A2 §1.3, §3.4, §4.2, §5.5; A3 §7) · AÇILAMADI

- **Koltuk bantları (3-10 / 10-30 / 30-100 / 100-300 / 300-1000).** A2: "türetme, varsayım." Dayanakları: AB sınıfları (Yüksek), "ERP kullanan çalışan oranı ~%26" (NetSuite sayfası, 403, Düşük, yöntemsiz) ve Erdem'in uç değerleri. Benim aramam da ERP'ye özgü "şu büyüklük şu kadar koltuk" tablosu bulamadı. Kod bugünkü bantları (5-10, 15-30, 40-70) 3 yıldız için farklı sayılar taşıyor (K §2.1); yeni bantlar kodla değil Erdem'in kararlarıyla uyumlu olmalı, gerçek-dünya "doğrulaması" yok.
- **Yıldıza göre temel kapanış ihtimali (%30/27/24/20/16) ve döngü hafta aralıkları.** Yalnız bir hücre (küçük anlaşma, 1-3 ilişki, %29) Ebsta'dan; Ebsta'nın "küçük/orta/büyük" kategorileri her şirketin kendi anlaşma boyutlarına göre göreli, ERP ya da müşteri yıldızı değil (PDF'te anlaşma sınıfı tanımı: şirket içi). Orta/kurumsal %22-28 / %15-20 ve %12-18 / %8-15 değerleri satıcı blogundan (Prospeo/RepVue aktarımı, Düşük, doğrulanmadı). 12 aramanın birinde de ERP satış döngüsü ya da kazanma oranı bulmadım (ayrıca aranmadı; A2'nin BOŞLUK listesi geçerli).
- **Yenilemede koltuk değişimi / genişleme sıklığı.** İki kaynak da (A2 ve benim aramam) ERP'ye özgü veri bulamadı. A2'nin SaaS Capital (2020, medyan net %100, brüt %90) rakamı özel B2B SaaS için; ben bu sayfayı açmadım, ikincil özetler "NRR medyanı %100-106, SMB ~%97, kurumsal ~%118" diyor, yön tutarlı, ERP'ye özgü değil. "Yenilemede koltuk % kaç değişir" tamamen oyun tasarımı sabiti olacak.
- **Satışçı yıldızı etkileri (×1,10 / ×0,60 / -%5 / +%20).** A2 "yön kaynaklı, büyüklükler varsayım" diyor. Doğrulayabildiğim "yön" Ebsta'nın hız farkı (satışçıların %16'sı gelirin %83'ünü getirdi, A2 S11) ve Bridge Group kotası; ikisi de genel SaaS, satışçı **yıldızı**-hesap yıldızı uyumunun kapanış ihtimaline etkisini ölçen bir çalışma değil. Ramp süresi aralıkları (1-3 / 3-6 / 6-12 ay) Düşük (Boomerang sözlüğü).
- **Gerçek ERP tavanı ve çıtası.** "SAP gibi yıllar süren" (Erdem 6): Fusion 2005 duyuru → 2011 çıkış (A1) iki kaynakta (Oracle/Wikipedia) tutarlı, ben açmadım; S/4HANA 3 Şubat 2015 duyurusu açılmadı. Birincil olarak yalnız SAP'ın bugünkü ölçeği (madde 4) doğrulandı.

---

## 21. Açılmayan / yalnız arama özetinden bilinenler

SAP "35.000 / %39" ve Gartner (madde 3); Panorama 2015 (SaaS %4 → %33), 2010, 2012, 2023 rapor rakamları; Gartner/ISG/DSAG anketleri; Trovarit sistem yaşı; Forrester 2008 SAP destek %22 (2008 verisi, A2 de eski diye işaretlemiş); SYSPRO/NetSuite-YouGov anketleri (satıcı sponsorlu, Düşük); Bridge Group 2017/2024, Starr Conspiracy; Logo faaliyet raporu ve Wikipedia rakamları (Ar-Ge %27); Nebim, Mikro, Uyumsoft satıcı beyanları; Verbeke tablo düzeyi; Hershey/Nike/HP vakalarının birincil kaynağı; Civilization VII Steam %51 (anlık değer, değişken); MM, FM, Offworld, Startup Company, MGT2 Steam konuları; IEEE Spectrum (Wipro 75 M$); GİB/Resmî Gazete metinlerinin kendisi.

---

## 22. Dört soruya kısa cevap

- **Eski veri güncelmiş gibi mi:** evet, dört yerde: Software Inc AI kuralı (2016), SAP destek %22 (2008), Panorama 2010/2015, SaaS Capital 2020. A2 çoğunu yıl etiketiyle verdi; bunlar tasarım gerekçesinde "bugünkü gerçek" gibi okunmamalı.
- **Tek satıcı kaynağı taşıyan:** Ebsta (kendi ürününü satıyor, ama örnek büyük ve rakamlar PDF'te tutuyor), ERP Research (A3'ün tüm sektör matrisi), NetSuite 10-K'daki "kimse sunmuyor" beyanı, Prospeo/Stealth Agents/Rework blogları.
- **Başarısız örnek gerçekten var mı:** ERP alıcı tarafında evet (Sunshine Mills, Birmingham, Lidl, Haribo, Revlon, Hershey, Waste Management), ikisi bağımsız basın/mahkeme kaynaklı. Oyun mekaniği tarafında: Software Inc "rakip pasif" ve Startup Company "dinamik rakip saçmaladı" (Steam geliştirici satırı, B1 S22 açılmadı ama aynı türden doğrulanan Software Inc/Big Ambitions satırlarıyla uyumlu). Bulunamayan: "sektöre özgü modül eksikliği yüzünden ERP projesi battı" örneği.
- **Hangi sayılar sağlam, hangileri oyun sabiti:** sağlam: madde 1, 4, 5, 8, 9, 10. Oyun sabiti olarak kalmalı: koltuk bantları, yıldız başına kapanış %, satışçı yıldızı çarpanları, yenileme/genişleme oranları, sektör x modül ağırlıkları, kurulum süreleri.
