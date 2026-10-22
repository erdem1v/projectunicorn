# R11: B2B sektörleri yazılım alırken hangi ürün alanına bakar, Çekirdek her yerde baskın mı

Tarih: 17 Ekim 2026. Soru (Erdem, `ERDEM_CDQ_CEVAP.md`, Q3): "her B2B tipi tek alanı önemser" yanlış bulundu; lojistik Güven, teknoloji
Çekirdek, sigorta Entegrasyonlar eşlemesi isabetsiz görünüyor; Çekirdek her sektörde ağır basmalı, sektörün daha çok
baktığı alanlar yalnız ek ağırlık olmalı. Kod değişmedi, oyun koşturulmadı. Tek koşan şey `python -I` ile küçük bir
hesap (§7.2).

## 0. Özet

1. Bugünkü eşleme sektör düzeyinde değil, 3 alıcı tipi düzeyinde. On üç sektörden on tanesi üç arketipe dağıtılmış
   (`sales_archetypes.gd:51,76,99`), üçü (Sağlık, Tekstil, Medya) hiçbir arketipte yok. O üçü hiç lead üretmiyor (faucet
   sektörü arketipin listesinden seçiyor, `sales_faucet_system.gd:212`), ama şirket havuzunda, mail metinlerinde ve
   Sağlık için tolerans payında duruyor (§1.2).
2. Bugünkü grup, sektör kanıtıyla örtüşmüyor. Aynı arketipin içine düşen sektörlerin kanıtlı vurguları farklı:
   `ops_cautious` içindeki lojistik Entegrasyonlar'a, inşaat saha ve Onboarding'e, üretim Entegrasyonlar'a işaret ediyor;
   hepsi bugün "Güven" okuyor. `tech_exacting` içindeki teknoloji Entegrasyonlar'a, e-ticaret ve finans Güven'e işaret ediyor;
   hepsi bugün "Çekirdek" okuyor.
3. Kanıtın kalitesi düşük ve eşit değil. Alıcı anketleri sektör kırılımı vermiyor. Sektöre özgü sağlam dayanak yalnız
   düzenlemelerden geliyor (Sağlık, Finans, Sigorta için Güven). Geri kalan sektörlerde uzman rehberi ya da kaynaksız
   bilgi var. Her satırda güven düzeyi yazılı; üç sektör "orta", gerisi "düşük" (§5).
4. "Çekirdek her sektörde ilk mi" sorusu: alıcı anketlerinde, beyan edilen tercih olarak hayır. G2 EMEA 2024'te ilk üç
   güvenlik, entegrasyon, kullanım kolaylığı; Gartner 2024'te fiyat %49, güvenlik %48. İşlevsellik üst beşte ama birinci
   değil. Buna karşılık işlevsellik eleme koşulu olarak çalışıyor (rehberler "olmazsa olmaz ve eleyici ölçüt" öneriyor,
   alıcıların %62'si son kararı deneme sürümüne bağlıyor). Yani kanıt "Çekirdek en yüksek ağırlık" değil, "Çekirdek giriş
   bileti" diyor. Bu çıkarım benim, kaynakta açık cümle olarak yok (§4).
5. Bu yüzden "Çekirdek baskın" kuralının en az kanıt zorlayan biçimi tavan: toplam uyum, Çekirdek oranının üstüne belli
   bir payın ötesine geçemez. Sabit yüksek ağırlık Erdem'in itirazını çözmüyor: Çekirdek oranı 0,3, öteki alanlar 1,5
   iken sabit ağırlık 63 puan veriyor (beklentide 70), tavan 38,5 (§7.2).
6. Önerilen eşleme (§6): Çekirdek herkeste baseline; sektör başına bir ya da iki ek vurgu alanı, sektör düzeyinde bir
   tabloda (arketipte değil).
7. Kritik veri uyarısı: alanların hat sayısı eşit değil (Çekirdek 5, Güven & Ölçek 2, Entegrasyonlar 1, Onboarding 1),
   yani aynı oran bir alanda tek karta, ötekinde beş karta bağlı (§6.3).

## 1. Kod: oyundaki sektörler, tipler, alanlar

### 1.1 Sektör, arketip, alan tablosu

| Sektör kimliği | Arketip (`sales_archetypes.gd`) | Alıcı tipi | Bugünkü eksen ağırlığı (`axis_weights`) | Bugünkü istek alanı (`sprint.json:55`) | Tolerans payı (`b2b_constants.gd:43`) | Şikâyet sesi (CSV) |
|---|---|---|---|---|---|---|
| logistics | ops_cautious (:51) | operasyon | Kararlılık .55 · Deneyim .30 · İnovasyon .15 (:57) | Güven & Ölçek | 0 | `B2B_COMPLAINT_LOGISTICS`: "Sevkiyat saatinde sistem donuyor" |
| construction | ops_cautious | operasyon | aynı | Güven & Ölçek | +5 | "Sahadaki ekip sisteme bağlanamıyor" |
| manufacturing | ops_cautious | operasyon | aynı | Güven & Ölçek | 0 | "Hat başında sistem takılıyor, üretim raporu tutmuyor" |
| technology | tech_exacting (:76) | teknik | İnovasyon .50 · Kararlılık .30 · Deneyim .20 (:81) | Çekirdek | 0 | "Sisteminiz sürekli hata veriyor" |
| ecommerce | tech_exacting | teknik | aynı | Çekirdek | 0 | "Kampanya saatinde sistem çöküyor, siparişleri kaybediyoruz" |
| finance | tech_exacting | teknik | aynı | Çekirdek | 0 | "Sistem gün içinde düşüyor, işlemler askıda kalıyor" |
| insurance | finance_brisk (:99) | finans | Deneyim .45 · Kararlılık .40 · İnovasyon .15 (:105) | Entegrasyonlar | +3 | "Sisteminiz son haftalarda sürekli düşüyor, poliçe işlerini yürütemiyoruz" |
| legal | finance_brisk | finans | aynı | Entegrasyonlar | 0 | "Dosyalara erişemiyoruz" |
| retail | finance_brisk | finans | aynı | Entegrasyonlar | 0 | "Yoğun saatte sistem kilitleniyor, kasa akmıyor" |
| real_estate | finance_brisk | finans | aynı | Entegrasyonlar | 0 | "Sistem sık sık kopuyor, ekip müşteriye dönemiyor" |
| health | yok | (düşer: `_row` ops_cautious okur, `:145`) | ops_cautious ağırlığı | Onboarding & Erişim (`area_of["default"]`, `sprint_bridges.gd:39`) | +5 | "Ekranlar sürekli çöküyor" |
| textile | yok | aynı | aynı | Onboarding & Erişim | 0 | "Sipariş ekranı sürekli hata veriyor" |
| media | yok | aynı | aynı | Onboarding & Erişim | 0 | "Yayın anında sistem donuyor" |

Sektör listesi `b2b_constants.gd:83-85` (13 kimlik). Fikstür sektörü `testing` (`:89`) listede yok. Alıcı tipi sabitleri
`sales_archetypes.gd:42-44`. Arketipe göre alan: `sprint.json:55` (`tech_exacting: core, finance_brisk: integrations,
ops_cautious: trust, default: onboarding`), okuyan `sprint_bridges.gd:32,39`. Yıldız aralığı: ops ve tech 1-3, finans 1-2
(`:53,:77,:101`). Yalnız `erp` alt türü B2B olarak yayında (`:52`).

Not: sorunun adı geçen üç eşlemesi (lojistik Güven, teknoloji Çekirdek, sigorta Entegrasyonlar) bu tablodan türüyor; yani
"lojistik" ve "teknoloji" kendi başına değil, arketipleri üzerinden bu alanları alıyor.

### 1.2 Ölü sektörler

Sağlık, Tekstil, Medya hiçbir arketipin `sectors` listesinde yok, bu yüzden `SalesFaucetSystem` onlardan lead çıkarmıyor
(`sales_faucet_system.gd:212-213`, sektör `SalesArchetypes.sectors(archetype)` listesinden seçilir). Buna rağmen
`CompanyCatalog` her biri için beş şirket (`company_catalog.gd:5`), CSV'de ikişer metin ve Sağlık için +5 tolerans taşıyor
(`b2b_constants.gd:43-45`). Smoke da lead sektörünün arketipin listesinde olmasını şart koşuyor
(`endgame_smoke.gd:6220`). Yeni sektör tablosu kurulacaksa bu üçünün akıbeti açık karar: arketipe ekle, ya da sil.

### 1.3 Ürün alanları ve hatlar (gerçek adlar)

Kaynak `data/product/sprint.json:56-63`, adlar `localization/strings.csv:2913-2923`, seviye `sprint_catalog.gd:644-651`
(alandaki hatların kademe ortalaması + cila, hat başına en çok hattın kademe tavanı; ekran yarıma yuvarlar, `:111`).

| Alan (TR / EN) | Pazar | Hatlar (ERP) | Hat sayısı | Beklenti (`sprint.json:30`) |
|---|---|---|---|---|
| Çekirdek / Core (`identity`) | B2C, B2B | Nakit Akışı, Veri Girişi, Defter, Stok, Fatura (`erp.json`) | 5 | evre 1: 1 · evre 2: 2 · evre 3: 2, rakip çıkışı başına +0,5 (en çok +1), alanın tavanını aşmaz |
| Onboarding & Erişim | B2C, B2B | Mobil & Erişim (+ Ar-Ge'nin açtığı gizli Self servis) | 1 (+1) | aynı |
| Entegrasyonlar | B2B | Entegrasyonlar | 1 | aynı |
| Güven & Ölçek | B2C, B2B | Güvenlik & Yetki, Dayanıklılık | 2 | aynı |
| Büyüme | B2C | Entegrasyonlar hattı | 1 | aynı |
| Gelir | B2C | Ücretli plan | 1 | tek kademe, tavanı 1 |

Hatların bugünkü eksenleri: Nakit Akışı ve Veri Girişi İnovasyon, Defter Kararlılık, Stok ve Fatura Deneyim, Entegrasyonlar
İnovasyon, Güvenlik ve Dayanıklılık Kararlılık, Mobil Deneyim (`data/product/lines/*.json`). Bu eksenler Q1 sonrası
ekonomiden çıkacak; alanlar kalacak.

Bir adlandırma uyarısı: "Onboarding & Erişim" alanının tek gerçek hattı Mobil. Alıcı anketlerinde "onboarding" çoğu
zaman satıcının kurulum ve eğitim süreci (G2: uygulama kalitesi), oyundaki alan ise ürünün mobil/erişim yüzü. İkisi aynı şey
değil; sektör tablosunda "Onboarding" yazarken bunun mobil/erişim olduğu akılda tutulmalı.

### 1.4 Eşlemenin bugün nerede okunduğu

- Satış görüşmesinde ürün uyumu: `sales_meeting_system.gd:134-141` (arketip ağırlığı × eksen okuması).
- Açık hatanın hangi hesabı etkilediği: `b2b_sales_system.gd:160-167`, `sprint_catalog.gd:386-389`, eşik `USE_AXIS_MIN`
  0,25 (`sales_archetypes.gd:34,141`).
- Hesabın memnuniyet hedefi: Kararlılık ekseni (herkes için aynı) eksi açık hata cezası (`b2b_sales_system.gd:135-149`).
  Sektör/arketip yalnız cezanın hangi hatlardan sayılacağını belirliyor (`:160-167`); ürün terimi sektörü okumuyor.
- İstek (müşteri talebi) alanı: `sprint_bridges.gd:32,39`.

## 2. Kaynak durumu

12 WebSearch kullanıldı (hepsi bu rapora girdi), 38 WebFetch denendi. Açılmayanlar:

- Gartner Digital Markets sayfaları (`gartner.com/.../2024-global-software-buying-trends`): 403; mirror `gcom.pdo.aws.gartner.com`
  kök sayfaya yönlendirdi; Ceros infografikleri içeriksiz döndü; BusinessWire haberi 403. 2024 rakamları (%49 fiyat,
  %48 güvenlik, %44 entegrasyon desteği) yalnız arama sonucu özetinden; sayfa açılmadı.
- Capterra (ABD, UK, AU Tech Trends sayfaları, AU blog), TrustRadius, efficient.app (429), Software Advice, Canadian Underwriter,
  HHS (403), Red Hat blog (404), web.archive.org (araç engelli): açılmadı. Bu kaynaklardan gelen her rakam arama özeti
  olarak işaretli.
- Fandom ve Reddit denenmedi (önceki raporlar 402 / engelli diyor). Oyun bilgisi resmi Software Inc wiki'sinden.
- Sektöre özgü alıcı anketi (bir sektörde alıcıların ölçüt sıralaması) hiçbir aramada çıkmadı. Bu raporun en büyük boşluğu bu.

"(kaynaksız)" işareti model bilgisidir.

## 3. Genel alıcı ölçütleri

| Çalışma | Sıralama | Not | Durum |
|---|---|---|---|
| G2 Buyer Behavior 2024, EMEA yorumu, 1.900+ alıcı | 1 güvenlik özellikleri, 2 mevcut araçlarla entegrasyon, 3 kullanım kolaylığı. İşlevsellik ayrı kalem değil | yüzde yok, boyut kırılımı yok | AÇILDI: https://company.g2.com/news/whats-top-of-mind-for-emea-software-buyers-in-2024 |
| G2 2023 | "değer, ölçeklenebilirlik ve kolaylık" ilk üç; öncelik şirket boyutuna göre kayıyor; %93 uygulama kalitesi yenileme kararını etkiliyor | sıralama yok | AÇILDI: https://research.g2.com/buyer-behavior-study |
| G2 2021 (N=756) | küçük işletmede entegrasyon ve güvenlik önde, kurumsalda güvenlik ve ölçeklenebilirlik | arama özeti | https://research.g2.com/buyer-behavior-study (özet, rakam doğrulanmadı) |
| Gartner Digital Markets 2024 | arama: fiyat %49, güvenlik %48. Üst beş: maliyet, güvenlik, özellik/işlevsellik, kullanım kolaylığı, entegrasyon. Değerlendirmede entegrasyon desteği %44, iş birliğine istek %42 | arama özeti, sayfa 403 | https://gcom.pdo.aws.gartner.com/en/digital-markets/insights/2024-global-software-buying-trends (arama sonucu) |
| Gartner Digital Markets 2025 (N=3.500) | deneme sürümü son kararda en kritik: %62; ilk listede satıcı itibarı %53, önceki deneyim %48; kısa listede müşteri yorumu %41 | ikincil kaynak üzerinden | AÇILDI (ikincil): https://2wtech.com/navigating-the-competitive-software-market/ |
| Capterra Avustralya | üst beş içinde özellik ve işlevsellik %38, güvenlik %38, kullanım kolaylığı %36; birincil ölçüt: güvenlik %35, kullanım kolaylığı %33, müşteri hizmeti %27 | arama özeti, sayfa 403 | https://www.capterra.com.au/blog/3399/software-trends-and-buyers-behaviour-australia |
| Capterra UK (251 yönetici) | güvenlik ve maliyet üst beşte %55 | arama özeti | https://www.capterra.co.uk/blog/3385/buyer-behaviour-and-technology-adoption |
| Küçük işletme anketi (kaynak adı özette yok) | kullanım kolaylığı %34, güvenlik %32, ürün özellikleri %31 | zayıf: kaynak doğrulanamadı | arama özeti |
| Capterra ABD 2024 | %58 alıcı en az bir satın almadan pişman; nedenler: beklenenden pahalı %35, kullanıcıları devreye almak ve eğitmek zor %34 | arama özeti | https://www.capterra.com/resources/us-tech-trends |

Okuma:
- Hiçbir çalışmada "işlevsellik" tek başına birinci değil. Güvenlik, kullanım kolaylığı ve entegrasyon aynı bantta.
- Pişmanlık nedenleri maliyet ve devreye alma zorluğu; "eksik işlev" ilk iki neden arasında çıkmadı (özette).
- Bu çalışmalar yatay: tüm sektörler karışık. Hiçbiri "sağlık alıcısı şunu, lojistik alıcısı bunu söyledi" demiyor.

## 4. Çekirdek işlev her sektörde ilk sırada mı

Kısa cevap: beyan edilen tercihte hayır, eleme koşulu olarak büyük olasılıkla evet, ve bu ikisi farklı şeyler.

Beyan sıralaması (§3): işlevsellik üst beşte ama güvenlik, entegrasyon ve kullanım kolaylığıyla aynı bantta. Çekirdek'in
"en yüksek ağırlık" olduğunu söyleyen bir alıcı anketi bulamadım.

Eleme koşulu lehine bulgular:
- Rehberler ölçütleri "olmazsa olmaz, olsa iyi olur ve eleyici" diye ayırmayı öneriyor (sağlık seçimi rehberi, arama
  özeti: https://www.capminds.com/vendor-comparison-matrix-how-to-score-your-top-3-healthcare-it-options/; sayfa açılmadı).
- Alıcıların %62'si son kararı deneme sürümüne bağlıyor (Gartner 2025, ikincil: https://2wtech.com/navigating-the-competitive-software-market/).
  Deneme sürümü ürünün temel işini yapıp yapmadığını sınar. Bu bir çıkarım.
- Lojistik TMS rehberi önce temel yetenekleri sayıyor (fiyat ve sözleşme yönetimi, çok modlu planlama, optimizasyon,
  rota), entegrasyonu "iş gerekçesinin parçası olarak test et" diye ayrıca ekliyor ve "mevcut özellik ile çalışan yetenek
  arasındaki fark uygulama, benimsetme ve yönetimdedir" diyor: https://logisticsviewpoints.com/2026/10/07/choosing-a-tms-what-logistics-leaders-should-evaluate-beyond-features/ (AÇILDI).
- Hukuk: 2.300+ kişilik MyCase/LawPay 2022 anketi "yazılım entegrasyonları ve uygulama alanına özel işlevsellik" üst
  öncelik diyor (AÇILDI, yüzdesiz): https://www.mycase.com/reports/2022-legal-industry-report/. Burada "uygulama alanına özel
  işlevsellik" bizim Çekirdek'imize denk.

Çekirdek'in baskın olmadığını gösteren tek şey: şikâyet ve pişmanlık nedenleri maliyet ve devreye almada (§3), yani
Çekirdek eksikliği değil, sonrası. Bu, Çekirdek'in "yeter ama yetmez" olduğunu söylüyor; Erdem'in cümlesiyle ("çekirdeği
kötü ürünü sırf güven ölçeği iyi diye satamamalıyız") uyumlu: eşik/kapı biçimi.

Kısıt: Bu bölümdeki "eleme koşulu" okuması kanıtla desteklenen bir çıkarım, anketlerin doğrudan ölçtüğü bir şey değil.

## 5. Sektör sektör kanıt

"Ek vurgu" Çekirdek dışındaki alanlardır (Çekirdek baseline). Güven: yüksek = yasa ya da çok kaynaklı; orta = en az bir
anket ya da çalışma; düşük = uzman rehberi ya da kaynaksız. Bu tabloda hiçbir sektör "yüksek" almadı çünkü sektöre özgü alıcı
anketi bulunamadı; en güçlü dayanak düzenleme.

| Sektör | Ek vurgu 1 | Ek vurgu 2 | Güven | Dayanak |
|---|---|---|---|---|
| Sağlık (health) | Güven & Ölçek (güvenlik hattı, erişilebilirlik) | Entegrasyonlar (birlikte çalışabilirlik) | 1: orta · 2: düşük | 1: HIPAA 45 CFR 164.306(a), kapsanan kuruluş ve iş ortağı ePHI'nin "gizliliğini, bütünlüğünü ve erişilebilirliğini" sağlamak zorunda, AÇILDI: https://www.law.cornell.edu/cfr/text/45/164.306 (ABD, yazılım satıcısı iş ortağı olur). 2: uzman rehberleri düzenleme/güvenlik, birlikte çalışabilirlik (HL7, FHIR) ve kullanılabilirliği öne çıkarıyor, anket değil, arama özeti: https://www.capminds.com/vendor-comparison-matrix-how-to-score-your-top-3-healthcare-it-options/ |
| Finans (finance) | Güven & Ölçek | Entegrasyonlar | 1: orta · 2: düşük | 1: AB DORA (2022/2554) madde 2 kapsamında kredi, ödeme, yatırım kuruluşları; madde 28: üçüncü taraf BT sağlayıcıdan uygun bilgi güvenliği standardı, risk bazlı denetim, fesih hakkı, çıkış planı, AÇILDI: https://www.digital-operational-resilience-act.com/Article_2.html ve https://www.digital-operational-resilience-act.com/Article_28.html. 2: kaynaksız (çekirdek bankacılık ve ödeme sistemleriyle bağ) |
| Sigorta (insurance) | Entegrasyonlar | Güven & Ölçek | 1: orta · 2: orta-düşük | 1: Forrester/Red Hat çalışması (arama özeti, sayfa 404): eski sistemlerle üst/alt akış entegrasyonu ve veri göçü ilk zorluklar; Novarica: yapılandırılabilirlik ve kullanılabilirlik satıcı seçimini etkiliyor (arama özeti); Celent, 141 P&C sigortacının %65'i çekirdek sistemi tümden değiştirmeyi tercih ediyor (AÇILDI): https://celent.com/insights/443658002. 2: DORA madde 2 "sigorta ve reasürans şirketleri"ni kapsıyor (AÇILDI, AB'de) |
| Hukuk (legal) | Entegrasyonlar | Güven & Ölçek | 1: orta · 2: düşük | 1: MyCase/LawPay 2022, 2.300+ katılımcı, entegrasyonlar ve uygulama alanına özel işlevsellik üst öncelik (AÇILDI, yüzde yok). 2: müvekkil gizliliği (kaynaksız) |
| Lojistik (logistics) | Entegrasyonlar | Güven & Ölçek | 1: orta-düşük · 2: düşük | 1: iki TMS rehberi (Inbound Logistics/Fortigo, arama özeti; Logistics Viewpoints 2026, AÇILDI) ERP/WMS ve taşıyıcı entegrasyonunu temel ölçüt sayıyor; gerçek zamanlı görünürlük bir yetenek olarak geçiyor. Anket yok. 2: kesintisiz gerçek zaman (kaynaksız); oyunun kendi şikâyet metni "sevkiyat saatinde donuyor" |
| İnşaat (construction) | Onboarding & Erişim (saha, mobil) | Güven & Ölçek (bağlantı) | 1: düşük-orta · 2: düşük | 1: JBKnowledge 2018, 786 yüklenici: teknoloji benimsemede engeller destek verecek personel eksikliği %41,5, bütçe %40,7, yönetim isteksizliği %33,2 (AÇILDI: https://nrca.net/RoofingNews/survey-examines-construction-industry-progress-with-adopting-technology.10-16-2018.7174/details/story); PlanRadar, 1.300+ profesyonel, 15 ülke: uygulama maliyeti UK'de %26, düşük yatırım getirisi algısı %28, alışkanlık (AÇILDI: https://www.intelligentcio.com/eu/2023/11/13/construction-survey-reveals-barriers-to-digitalisation-in-the-construction-and-real-estate-sectors/). Capterra inşaat kategorisinde mobil erişim değerli özellikler arasında ama özellik başına yorumcu sayısı 2 ile 13 arası (arama özeti). 2: saha bağlantısı (kaynaksız) |
| Üretim (manufacturing) | Entegrasyonlar | Güven & Ölçek | düşük | kaynaksız (ERP, saha makineleri ve planlama arasındaki veri akışı; hat durması maliyeti). Oyunun şikâyet metni "hat başında sistem takılıyor" |
| Tekstil (textile) | Entegrasyonlar | Onboarding & Erişim | düşük | kaynaksız. Sipariş ve üretim planı akışı; üretimle aynı aile |
| E-ticaret (ecommerce) | Güven & Ölçek (tepe yük, dayanıklılık) | Entegrasyonlar | 1: orta-düşük · 2: düşük | 1: Google/Deloitte, 37 marka sitesi, 30 milyon oturum: mobil hızda 0,1 sn iyileşme perakende dönüşümünü %8,4 artırıyor (AÇILDI: https://web.dev/case-studies/milliseconds-make-millions); hız ile dayanıklılık aynı şey değil, ama gelirin yük altında performansa bağlı olduğunu gösteriyor. 2: ödeme/kargo/pazaryeri bağlantıları (kaynaksız) |
| Perakende (retail) | Güven & Ölçek (yoğun saat) | Entegrasyonlar (POS, stok) | düşük | 1: aynı Google/Deloitte çalışması (perakende kolu); oyunun şikâyet metni "yoğun saatte kasa kilitleniyor". 2: kaynaksız |
| Emlak (real_estate) | Onboarding & Erişim (saha, mobil) | Entegrasyonlar (ilan ve müşteri kayıtları) | düşük | kaynaksız |
| Medya (media) | Güven & Ölçek (yayın anı) | Onboarding & Erişim | düşük | kaynaksız. Yayın anında kesinti kabul edilmez; oyunun şikâyet metni "yayın anında donuyor" |
| Teknoloji (technology) | Entegrasyonlar (API) | Güven & Ölçek (güvenlik) | 1: düşük · 2: orta-düşük | 1: kaynaksız; genel G2 bulgusu entegrasyonu ikinci sıraya koyuyor. 2: G2 EMEA 2024'te güvenlik birinci (AÇILDI), teknoloji alıcısı sektör kırılımı yok |

Sektöre özgü ek not: oyundaki "Güven & Ölçek" alanı iki ayrı kaygıyı taşıyor: güvenlik/yetki (uyum, gizlilik) ve dayanıklılık
(kesintisizlik, yük). Sağlık, finans, sigorta, hukuk birincisini; e-ticaret, perakende, medya ikincisini istiyor. Alan tek
olduğu için tablo "Güven & Ölçek" yazıyor; hat düzeyine inmek (Güvenlik hattı ya da Dayanıklılık hattı) daha doğru ama
daha fazla veri ve ekran demek (§8, madde 5).

## 6. Önerilen eşleme (oyundaki alan adlarıyla)

### 6.1 Tablo

Kural: Çekirdek her sektörde baseline. Sektör başına en çok iki ek vurgu, sektör tablosunda (arketipte değil).

| Sektör | Ek vurgu 1 | Ek vurgu 2 | Güven |
|---|---|---|---|
| Sağlık | Güven & Ölçek | Entegrasyonlar | orta |
| Finans | Güven & Ölçek | Entegrasyonlar | orta |
| Sigorta | Entegrasyonlar | Güven & Ölçek | orta |
| Hukuk | Entegrasyonlar | Güven & Ölçek | orta-düşük |
| Lojistik | Entegrasyonlar | Güven & Ölçek | orta-düşük |
| İnşaat | Onboarding & Erişim | Güven & Ölçek | düşük-orta |
| E-ticaret | Güven & Ölçek | Entegrasyonlar | orta-düşük |
| Perakende | Güven & Ölçek | Entegrasyonlar | düşük |
| Teknoloji | Entegrasyonlar | Güven & Ölçek | düşük |
| Üretim | Entegrasyonlar | Güven & Ölçek | düşük |
| Tekstil | Entegrasyonlar | Onboarding & Erişim | düşük |
| Emlak | Onboarding & Erişim | Entegrasyonlar | düşük |
| Medya | Güven & Ölçek | Onboarding & Erişim | düşük |

Bugünkü eşlemeye göre fark: lojistik Güven yerine Entegrasyonlar (Güven ikinci), teknoloji Çekirdek yerine Entegrasyonlar,
finans ve e-ticaret Çekirdek yerine Güven & Ölçek, inşaat Güven yerine Onboarding & Erişim, sigorta aynı kalıyor,
perakende Entegrasyonlar yerine Güven & Ölçek. Üç eşlemeden (lojistik, teknoloji, sigorta) lojistik ve teknoloji kanıtla desteklenmedi (bugünkü yerlerinde birinci
değiller), sigorta destekleniyor.

### 6.2 Dört kaygı ailesi (kanıt azken sade bir yol)

Kanıt on üç sektörü ayrı ayrı savunmaya yetmiyor. Daha az iddiayla aynı sonuç: sektörü dört kaygı ailesinden birine bağla,
oyuncuya aile cümlesini göster.

| Aile | Sektörler | Ek vurgu |
|---|---|---|
| Düzenleme ve veri hassasiyeti | sağlık, finans | Güven & Ölçek |
| Sistem zinciri ve mevcut sistemlere bağ | sigorta, hukuk, lojistik, üretim, tekstil, teknoloji | Entegrasyonlar |
| Saha ve ön cephe | inşaat, emlak | Onboarding & Erişim |
| Tepe yük ve canlılık | e-ticaret, perakende, medya | Güven & Ölçek |

Bedeli: aile içinde sektör farkı kalmaz (ör. sigorta ile üretim aynı). Güven & Ölçek iki ailede geçtiği için "uyum" ile
"canlılık" ayrımı ancak hat düzeyinde yapılabilir.

### 6.3 Alan boyutu asimetrisi (tasarımcının bilmesi gereken)

- Çekirdek 5 hat (ERP). Entegrasyonlar ve Onboarding & Erişim tek hat. Güven & Ölçek 2 hat (`sprint.json:56-63`).
- Seviye = hatların kademe ortalaması (`sprint_catalog.gd:644-651`). Tek hatlı alanda bir kart seviyeyi 1 kademe oynatır;
  beş hatlı Çekirdek'te bir kart 0,2 kademe. Aynı oranı yakalamak için Entegrasyonlar'da 1 kart, Çekirdek'te 5 kart gerekir.
- Beklenti evre 1'de 1, evre 2 ve 3'te 2 (`sprint.json:30`). Evre 1'de oran 0 / 1 / 1,5 (kesik) basamaklarında oynar; evre
  2'de 0 / 0,5 / 1.
- Sonuç: "Entegrasyonlar" ek vurgusu ucuz karşılanıyor, "Çekirdek baskın" doğal olarak pahalı. Bu istenen yön olabilir
  (Çekirdek zor), ama sektör vurgusunun tek kartlık bir alana bağlanması uyumu tek karta bağımlı kılar.

## 7. "Çekirdek baskın" kuralının biçimi

### 7.1 Seçenekler

Ortak tanım: r = alan oranı (seviye / beklenti, 1,5'te kesik, X belgesi §6.1). Ağırlıklar örnek ve [ÇALIŞMA]: Çekirdek 0,50,
vurgu 1 için 0,30, kalan iki alan 0,10'ar. Uyum terimi = 70 × uyum (X §6.3).

- A, sabit yüksek ağırlık. uyum = Σ ağırlık × r. Çekirdek ağırlığı yüksek tutulur, sektör ek ağırlık olarak eklenir.
  Artı: tek formül, oyuncuya "Çekirdek yarısı kadar sayılıyor" cümlesiyle anlatılır. Eksi: Çekirdek 0,3 iken öteki
  alanlar 1,5 olunca terim 63; zayıf Çekirdek diğer alanların fazlasıyla telafi edilir. Erdem'in itirazı tam bu.
- B, tavan. uyum = min(Σ ağırlık × r, Çekirdek oranı + pay). Çekirdek oranı tavan belirler, öteki alanlar tavana kadar
  doldurur, aşamaz. Pay örnek olarak 0,25. Artı: "çekirdeği kötü ürünü güven iyi diye satamazsın" kuralının birebir hâli;
  Çekirdek iyi iken davranış A ile aynı; MVP durumunda (Çekirdek 0,6, öteki 0) A ile aynı çıktı. Eksi: tavan devreye girince
  başka alana yapılan yatırım karşılıksız kalır; oyuncuya "bu hesap için Çekirdek'in sınırı" cümlesi gerekir.
- C, çarpımsal. uyum = Çekirdek^a × (Çekirdek dışı ağırlıklı ort.)^(1−a), a = 0,5. Artı: iki ayağın da yüksek olmasını ister,
  süreklidir. Eksi: herhangi biri 0 ise uyum 0 (MVP'de öteki alanlar 0 iken uyum 0 olur). Oyuncuya anlatması zor.

Üçünün ortak özelliği: kişi ya da hesap sayısı yok, yalnız oran. Ekip büyüklüğü (1, 3, 6, 12, 25, 50 kişi) oranı değiştirmez;
ekip yalnız kartların ne kadar hızlı kapandığını belirler. Uç bileşimler (hepsi testçi, PM'siz, aynı rolde 10 kişi) bu kural
katmanında hiç görünmez, çünkü kural yalnız yayındaki kademeye bakıyor; onlar D'nin kural alanı.

### 7.2 Sayıyla karşılaştırma (`python -I`, betik: `C:/Users/erdem/AppData/Local/Temp/claude/C--Users-erdem-Desktop-Project-Unicorn/3ef3b847-b97e-4e0a-b9b4-c8ae6a99e869/scratchpad/forms.py`)

Terim = 70 × uyum. Sütunlar: Çekirdek, vurgu 1, öteki iki alan oranları.

| Durum (Çekirdek / vurgu / öteki) | A sabit | B tavan | C çarpımsal |
|---|---|---|---|
| 1 / 1 / 1 (hepsi beklentide) | 70,0 | 70,0 | 70,0 |
| 0,6 / 0 / 0 (MVP'den hemen sonra) | 21,0 | 21,0 | 0,0 |
| 0,6 / 1,0 / 0,5 | 49,0 | 49,0 | 48,5 |
| 0,3 / 1,5 / 1,5 (güven iyi, çekirdek kötü) | 63,0 | 38,5 | 47,0 |
| 0,0 / 1,5 / 1,5 | 52,5 | 17,5 | 0,0 |
| 1,5 / 0 / 0 (yalnız Çekirdek) | 52,5 | 52,5 | 0,0 |
| 1,0 / 0 / 1,0 | 49,0 | 49,0 | 44,3 |
| 1,2 / 0,5 / 1,0 | 66,5 | 66,5 | 64,2 |

Okuma:
- Çekirdek hiç yokken A, 52,5 veriyor: ürün Çekirdek'siz neredeyse yarı yolda. B 17,5, C 0.
- Çekirdek iyi iken A ve B aynı; fark yalnız Çekirdek geride kalan ürünlerde. Bu, Erdem'in cümlesindeki yönle örtüşüyor.
- C, MVP anında 0 veriyor; X §9'daki "MVP'den sonra hesaplar eşiğe iniyor" kalibrasyon riskini bu biçim ağırlaştırır.
- Tavan payı 0,25 örnek; payı büyütmek B'yi A'ya yaklaştırır. Pay bir [ÇALIŞMA] sabiti.

## 8. Oyunlardan kısa not

- Software Inc: her yazılım türü üç alt pazar tanımlar (`SubmarketNames`, örnek "Gameplay; Graphics; Story"). Özellik üç
  değerli bir oran taşır ve normalize edilir (3,4,5 → 3/12, 4/12, 5/12). Kategori her alt pazarın tüketici payını verir (örnek [1;3;4]
  → %12,5 / %37,5 / %50). Seviye 2 özellik seviye 1'den çok doyurur, seviye 3 alt pazarı hiç doyurmaz. Kaynak (AÇILDI):
  https://softwareinc.coredumping.com/wiki/index.php/Data_Modding. Alt pazar adlarının gerçek karşılığı wiki sayfalarında
  yok. Bizim durumla paralel: aynı özellik listesi her segmente farklı oranda hizmet ediyor, yani "ortak çekirdek + segment payı"
  yapısı oyunun kendisinde var. Ölçekte: `OptimalDevTime` kaç özellik gerektiğini belirler, ekip büyüklüğüyle ölçeklenmez
  (R1).
- Startup Company: bu turda yeni kaynak açılmadı. Önceki bulgu (R8 §2.4): memnuniyet iki temel özelliğin dengeli olmasına
  bağlı; sektör ya da müşteri segmenti kırılımı bulunamadı.
- Sonuç: iki oyunda da "segmente özel ek ağırlık" var ama "segmente göre farklı baskın özellik" yok. Çekirdek'in
  baskınlığı oyunlarda varsayılan, tasarım sorusu olarak ayrı ele alınmamış.

## 9. Tasarımcıya 8 madde

1. Eşlemeyi arketip düzeyinden sektör düzeyine taşı (13 satır), çünkü aynı arketipin içindeki sektörlerin kanıtlı vurguları
   farklı (§1.1, §5). Müzakere ve mizaç alanları (sabır, hakaret payı, dürüstlük primi) arketipte kalabilir.
2. Çekirdek'i baseline yap, sektör vurgusunu yalnız ek ağırlık olarak göster ve oyuncuya tek cümle yaz ("Sigorta
   hesapları Entegrasyonlar'a ayrıca bakar", tire yok). Üç şüpheli eşlemeden lojistik ve teknoloji değişmeli; sigorta kalabilir.
3. "Çekirdek baskın" için tavan biçimini (B) önce dene: kanıt Çekirdek'i en yüksek ağırlık değil giriş bileti olarak okuyor
   (§4), tavan bunu karşılıyor, Çekirdek iyi iken davranışı sabit ağırlıkla aynı. Pay ve ağırlıklar [ÇALIŞMA]. Çarpımsal
   biçim MVP'de 0 verdiği için en riskli.
4. Güven düzeyini tasarıma taşı: tabloda "düşük" yazan sektörlerde (üretim, tekstil, emlak, medya, perakende, teknoloji) vurgu bir
   tasarım tahmini, veri değil. Bu sektörlere küçük ek ağırlık ver, ya da §6.2'deki dört aileden birine bağla.
5. Güven & Ölçek iki kaygıyı taşıyor (uyum/güvenlik ve canlılık/dayanıklılık). Ya sektör vurgusunu hat düzeyine indir
   (Güvenlik ya da Dayanıklılık), ya da alanı iki kaygıyla birlikte tek vurgu say ve bunu oyuncuya açıkla.
6. Alan hat sayıları eşit değil (Çekirdek 5, Güven 2, Entegrasyonlar 1, Onboarding 1). Oran tabanlı kural kısmen telafi
   ediyor ama tek hatlı alan tek karta bağlı; vurguyu tek hatlı alana koyuyorsan o alanda oranın basamak boyunu (§6.3) bilerek koy.
7. Ölü sektörler: Sağlık, Tekstil, Medya hiçbir arketipte yok, lead çıkarmıyor (§1.2). Yeni tabloda ya arketipe girerler
   ya da şirket havuzundan, CSV'den ve Sağlık'ın +5 tolerans payından silinirler. Sağlık düzenleme kanıtı en güçlü sektör
   olduğu için silmek yerine eklemek daha tutarlı olabilir.
8. Hesabın memnuniyet hedefinin ürün terimi bugün sektörü okumuyor (`b2b_sales_system.gd:135-149`: Kararlılık ekseni herkeste aynı; sektör yalnız hata cezasının hat kümesini seçiyor). Yeni
   "Ürün uyumu" terimi sektör ağırlığını okuyacaksa (C2), oyuncu "bu hesap neden böyle" sorusuna sektör cümlesiyle cevap
   alır; aynı cümle satış görüşmesindeki ürün uyumu satırında (`sales_meeting_system.gd:134-141`) da kullanılabilir, böylece
   iki yerde tek kural gösterilir.

## Kaynaklar

AÇILDI:
- https://company.g2.com/news/whats-top-of-mind-for-emea-software-buyers-in-2024
- https://research.g2.com/buyer-behavior-study
- https://2wtech.com/navigating-the-competitive-software-market/
- https://www.mycase.com/reports/2022-legal-industry-report/
- https://celent.com/insights/443658002
- https://nrca.net/RoofingNews/survey-examines-construction-industry-progress-with-adopting-technology.10-16-2018.7174/details/story
- https://www.intelligentcio.com/eu/2023/11/13/construction-survey-reveals-barriers-to-digitalisation-in-the-construction-and-real-estate-sectors/
- https://logisticsviewpoints.com/2026/10/07/choosing-a-tms-what-logistics-leaders-should-evaluate-beyond-features/
- https://web.dev/case-studies/milliseconds-make-millions
- https://www.digital-operational-resilience-act.com/Article_2.html
- https://www.digital-operational-resilience-act.com/Article_28.html
- https://www.law.cornell.edu/cfr/text/45/164.306
- https://softwareinc.coredumping.com/wiki/index.php/Data_Modding

ARAMA ÖZETİ (sayfa açılmadı veya engelli):
- https://gcom.pdo.aws.gartner.com/en/digital-markets/insights/2024-global-software-buying-trends
- https://www.capterra.com.au/blog/3399/software-trends-and-buyers-behaviour-australia
- https://www.capterra.co.uk/blog/3385/buyer-behaviour-and-technology-adoption
- https://www.capterra.com/resources/us-tech-trends
- https://www.capminds.com/vendor-comparison-matrix-how-to-score-your-top-3-healthcare-it-options/
- https://www.inboundlogistics.com/articles/how-to-choose-a-tms-vendor-thats-right-for-your-company/
- https://www.redhat.com/it/blog/core-modernization-leads-way-business-success (Forrester çalışması)
- https://www.canadianunderwriter.ca/insurance/insurer-cios-demand-configurability-in-core-technology-systems-survey-1003824321/ (Novarica)

Kod: `scripts/systems/sales_archetypes.gd`, `b2b_constants.gd`, `sales_faucet_system.gd`, `sprint_catalog.gd`, `sprint_bridges.gd`,
`sales_meeting_system.gd`, `b2b_sales_system.gd`, `company_catalog.gd`; veri `data/product/sprint.json`, `data/product/lines/*.json`;
metin `localization/strings.csv:685-726,2913-2923`.
