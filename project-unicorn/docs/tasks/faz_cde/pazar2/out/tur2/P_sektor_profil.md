# P · Sektör profilleri: 13 sektör, 10 modül, kaç profil

Tarih: 2026-10-20 (gece). Konu P (Erdem soru 1: B modül profili). Oyun koduna, CSV'ye, `data/`'ya yazılmadı.
Makine okunur karşılığı: `tur2/P_profiles.json`. Ölçü betiği: `tur2/p_olcu.py` (profil tablosu ve metrikler) ve `tur2/p_json.py` (JSON üretimi); ikisi de `python -I`, oyun kodunu okumaz.
Arama: 14 WebSearch (bütçe doldu). Açılan sayfa sayısı ve açılamayanlar en sonda ("Okunanlar ve okunamayanlar").

---

## ÖZET

**Bulgular (kaynaklı)**
1. Sektöre göre paket gerçek bir ürün pratiğidir ama sektör listesi satıcıya göre değişir: NetSuite'in FY2012 10-K'sında beş sektör sürümü (toptan dağıtım, imalat, profesyonel hizmet, perakende, yazılım) [S1]; Business Central'da yedi (toptan dağıtım, perakende, profesyonel hizmet, imalat, inşaat, enerji, kâr amacı gütmeyen) [S2]; Mikro'da sekiz (Perakende, İnşaat, Kırtasiye, Kimya, Lojistik, Metal, Mobilya, Otomotiv) [S3]; Odoo mağazasında sekiz sektör kategorisi, gayrimenkul ile inşaat aynı kategoride, hukuk "Consulting" altında, sigorta ve finans yok [S5]. Hepsi satıcı sayfası (Düşük); tabloda ancak iki bağımsız satıcı aynı işleve işaret ederse K sayıldı. [V2 uyarı, KISMEN: NetSuite 10-K'daki beş sürüm ve ilk on sektör sırası, Eurostat ve profil aritmetiği (47 K / 43 V; 4,69 / 2,94 / 1,42) doğrulandı; Business Central'ın yedi sektörlük listesi Microsoft'un kendi sayfasından doğrulanamadı.]
2. Finans ve sigorta için hiçbir satıcı dikey modül kurmamış (Mikro, BC, Odoo, NetSuite sürümleri) ama NetSuite'in 2012 gelir listesinde (10-K'daki diziliş sırasıyla) "Financial Services" 8. ve "Healthcare Services" 9. sırada [S1]: bu sektörler ERP alıyor, ERP onlar için arka ofistir. Gartner pazarı "ürün merkezli" ve "hizmet merkezli" diye ikiye ayırır; hizmet tarafının tipik sektörleri sağlık, finansal hizmetler, telekom [S6].
3. Modül düzeyinde sektör verisi bağımsız kaynakta yok. Eurostat yalnız büyüklüğe göre verir: 10+ çalışanlı AB işletmelerinde ERP kullanımı küçükte %38, büyükte %86 (2023) [S19]; 2025'te küçük %41,08, orta %69,93, büyük %88,71 [S20]. NACE kırılımı alınamadı. Akademik: imalatçıların temel modülleri finans, malzeme, üretim planlama, satış-dağıtım, kontrol; hizmet sektöründe ERP paketinin her modülü kullanılamaz [S9] (22 kuruluşla görüşme, 2004).
4. Başarısız örnek tarafı zayıf: "sektöre özgü eksik yüzünden kaybedilen satış" bulunamadı. En yakın: Lidl (süreç uyumsuzluğu) ve Waste Management (satıcının vaadi yanlış çıktı) [S11]; IFS/Mint Jutras anketinde %60 "sektöre özgü özellik eksikliğinden işlev boşluğu" (satıcı sponsorlu, Düşük) [S10]; Panorama 2012: katılımcıların %70'i yazılımda küçük-orta değişiklik yaptı [S12]. SAP ByDesign 2007'de 10.000 müşteri hedefledi, 2010'da hedefi onda birine indirdi, Ekim 2013'te 785 müşteri [S13] (sektör yenilgisi değil, kimliği belirsiz tek ürün örneği [SIÇRAMA]).
5. Tablonun 90 hücresinin (9 profil × 10 modül) 47'si K, 43'ü V. "Her zaman" (Z) hücrelerinden V olan yalnız üç tane: Dağıtım × Satın Alma, Sağlık × Stok, Gayrimenkul × Fatura.

**Ölçü (hesap, `p_olcu.py`)**
6. Önerilen 9 profilde 10 modül: 9 profilin 9'u ayırt edilir, çift başına ortalama 4,69 modülde fark, en az 2. 7 modülde 7 ayırt edilir (ortalama 2,94; İmalat ile Dağıtım özdeş). 5 modülde 5 ayırt edilir (ortalama 1,42; 7 özdeş çift).
7. Eski 7 profilli gruplama (Hizmet = teknoloji, hukuk, medya, finans, sigorta; İnşaat+Gayrimenkul tek) 3 saçma hücre üretir: bankaya "Proje ve Zaman her zaman" (2 sektörde) ve emlakçıya "Stok sık". 9 profilde saçma hücre 0.
8. Hiçbir sette ölü modül yok (her modülü en az bir profil "her zaman" ister).

**Oyuna ders**
- 13 sektör adını 9 profile bağla (7 değil): Mali Hizmetler ayrı, Gayrimenkul ayrı. Etkisi: aday kartındaki "istediği modüller" her görüşmede inandırıcı kalır (banka zaman çizelgesi istemez); oyuncunun "hangi sektöre odaklanayım" kararı (yılda 1-2) 9 anlamlı seçenek olur.
- Modül sayısı 5 ise sektör seçimi oynanışı çöker: 9 profilden yalnız 5'i ayırt edilir, İmalat, Dağıtım, Perakende ve Sağlık aynı beş modülü ister; "hangi sektöre satayım" kararı yoktur. 7'de iki eksen kalır (hizmet ve ticaret) ve Perakende/E-ticaretin imzası (Mağaza ve Kanal) düşer. 10'da her profilin kendi imzası var (altı modül sektör ayırır; dördü temel). Karar Erdem'in, tablo §7.
- Sektör içi kimlik profilden değil "önemli modül"den gelir (13 satır, 1-2 aday): tekstilin önemlisi Stok (beden-renk varyantı), hukukun Proje ve Zaman (saat bazlı), lojistiğin Depo ve Sevkiyat. Etkisi: aynı profildeki iki aday farklı cümle kurar; oyuncu her görüşmede neye bakacağını bilir.
- Sağlık ve Mali Hizmetler "imza modülü"süz kalır (hiçbir modülü ≤2 profille paylaşmaz); kimlikleri eksik modül listesi ve mevzuat şartıdır (sağlıkta KVKK özel nitelikli veri [A3-S14], SGK e-Fatura eşiksiz [A3-S11]). Etkisi: bu iki sektörde ayrım yenileme şartlarından gelir, satış cümlesinden değil.
- Z sayısı yıldızın modül sayısından fazlaysa (1★ 2-3 modül ister, İmalat'ın 6 Z'si var) sıra: önemli modül, Finans, sonra sektör imzası. Etkisi: 1★ aday hep küçük ve okunur kalır.
- Başarısız örneklerden ders: eksik modül ceza değil bilgi (zaten öyle); asıl gerçek kayıp "süreç uyumsuzluğu + aşırı söz". Etkisi: "özel yaparım" kararı yılda 1-2 kez, mevcut söz mekaniğine bağlanır.

---

## 0. Okuma notu

Etiketler: [BOŞLUK] · [SIÇRAMA] · [DEĞERLENDİREMEM] · [GÖRÜŞ] · (varsayım) · (hesap) benim aritmetiğim · [WORKING] kalibrasyon girdisi.
Kaynak sicili dosyanın sonunda (S1-S23; A3'ten taşınanlar `[A3-S#]`, o dosyanın 21 kaynağı).

**K ve V kuralı (hücre kanıt düzeyi).** Bir hücre K sayılır ancak ve ancak (a) bu işi ya da dosyayı açıp okuduğum en az bir Orta ya da üstü kaynak o sektörde o işlevi adıyla söylüyorsa, ya da (b) birbirinden bağımsız iki Düşük kaynak (farklı yayıncı, farklı aile) söylüyorsa. Arama özetinden öğrendiğim ama sayfasını açamadığım kaynaklar K'ya sayılmadı. A3'ün ERP Research sayfaları tek aile sayılır (V bunu tek yayıncı saydı [V #13]). Tüm sektörlerde ortak çıkan dört temel modül (Finans, Fatura, Satın Alma, İK) ERP'nin genel tanımından K'dır [S15, A3-S18]. Hücre "-" (hiç istemez) K sayılır yalnız bir kaynak o sektör sınıfının ürün merkezli işlevleri taşımadığını söylüyorsa (Gartner hizmet merkezli sınıfı [S6]).

**Değer anlamı** (SENTEZ §3.2 ile aynı): Z = her zaman ister; S = sık ister; N = nadir ister; - = hiç istemez. Olasılık ağırlıkları S %40-60, N %5-15 [WORKING, A3 §7.7, varsayım].

**Sınırlar.** Hiçbir bağımsız kaynak sektöre göre modül kullanım yüzdesi vermiyor. Hücreler sınıflamadır, ölçüm değildir. Oyun 2012'de başlıyor; sayfaların çoğu 2026 durumunu anlatır (bölüm 6).

---

## 1. Kaynaklar ne söylüyor

### 1.1 Gartner: ürün merkezli ve hizmet merkezli
- Hizmet merkezli bulut ERP (Gartner 2023): finansal yönetim, order-to-cash, source-to-pay, insan sermayesi ve "diğer idari ERP işlevleri"nden (planlama, hizmet satın alma, proje yönetimi) en az üçünü kapsayan bütünleşik takım; tipik sektörler sağlık, finansal hizmetler, telekom [S6]. Gartner'ın kendi metni açılamadı; CX Today özeti ikincil (Orta).
- Ürün merkezli: fiziksel mal üreten, satan, dağıtan şirketler; imalat ve teslimat/servis [S6'nın karşılaştırması]. "EAM, configure-to-order, PLM, field service" gibi özel modüller sayıldığı yönündeki ifade yalnız arama özetinde, sayfa 403 [S7]; K saymadım.
- Bu ayrım profil kümesini doğrular: hizmet tarafı (Hizmet, Mali Hizmetler, Sağlık) Üretim, Depo ve Sevkiyat, Mağaza ve Kanal taşımaz; ürün tarafı (İmalat, Dağıtım, Perakende, E-ticaret) taşır. İnşaat ve Gayrimenkul Gartner'ın örnek listelerinde geçmiyor; bunlar için sektör sayfaları, Odoo ve BC kullanıldı.
- "Sağlık hizmet merkezli" demek hastanenin stok modülü almayacağı demek değildir: Gartner'ın üç sektörlü listesinde stok işlevi aranmıyor; hastane tedarik zinciri başka kaynaktan geliyor (bölüm 4.5).

Oyuna ders: sınıf ayrımı "hangi profil hangi üç modülü hiç istemez" cümlesini gerçek bir ayrıma bağlar (Üretim, Depo ve Sevkiyat, Mağaza ve Kanal hizmet tarafta "-"). Etkisi: oyuncunun görüşmede "bu aday bana ne sormaz" okuması otomatikleşir; her satışta bir bakış.

### 1.2 Satıcıların resmî sektör paketleri
| Satıcı | Sektör listesi (sayfada adıyla) | Kaynak, güven |
|---|---|---|
| NetSuite FY2012 10-K | Beş sektör sürümü: toptan/dağıtım, imalat, profesyonel hizmet, perakende, yazılım; her sürüm "çekirdeğe ek sektöre özgü işlev, en iyi uygulama şablonları, uzman satış ve hizmet ekibi" taşır. Modüller: finansal/ERP, CRM, e-ticaret (SuiteCommerce), OneWorld, PSA (OpenAir), Retail Anywhere (POS). 2012 gelirine göre ilk on sektör: dağıtım ve toptan; profesyonel, danışmanlık ve diğer hizmetler; yazılım; e-ticaret ve perakende; imalat; bilgisayar ve BT hizmetleri; telekom; finansal hizmetler; sağlık hizmetleri; eğitim | S1, 10-K'nın ilk 100.000 karakteri okundu (193.417 karakterden); ürün tanımı Düşük, gelir sıralaması Orta |
| Business Central | Toptan dağıtım (envanter dengeleme, satın alma, depolama, karşılama); perakende ve tüketim malı (POS, ticaret, tamamlama); profesyonel hizmet (proje yönetimi, iş maliyeti, kaynak, bütçe); imalat (üretim planlama, ürün ağacı, üretim emri); inşaat (proje muhasebesi, satın alma, iş maliyeti, işçilik, malzeme, ekipman, alt yüklenici); enerji ve altyapı; kâr amacı gütmeyen (fon muhasebesi). Modül adları: finans, tedarik zinciri, imalat, proje yönetimi, hizmet yönetimi, depo, satış. Varlık/sabit kıymet modülü sayfada yok, İK yok | S2, Düşük |
| Mikro | "Sektörel" başlığı altında sekiz çözüm: Perakende, İnşaat, Kırtasiye, Kimya, Lojistik, Metal, Mobilya, Otomotiv; modül listesi sayfada yok | S3, Düşük |
| Nebim | Hazır giyim ("beden, renk, koleksiyon ve sezon yönetimi"); halı, çeyiz, mobilya, züccaciye ("takip ve sevkiyat çözümleri"); üretim ("reçete, fire, fason, kapasite planlama, maliyet"); optik; ticari. Perakende için "bütünleşik perakende", mağaza yönetimi | S4, Düşük |
| Odoo uygulama mağazası | Perakende; Yiyecek ve konaklama; Gayrimenkul (acenta, mimarlık, inşaat, mülk yönetimi, bahçıvanlık, site yönetimi); Danışmanlık (muhasebe, pazarlama, hukuk bürosu, denetim); İmalat (tekstil, metal, mobilya, gıda); Sağlık ve fitness (eczane, optik); Esnaf; Diğer. Süzgeçte ayrıca "Supply Chain". Lojistik, sigorta, finans, medya adlı kategori yok | S5, Düşük |

Bu tablodan çıkanlar:
- Satıcılar ortak dilde şu sektör ailelerini ayırıyor: imalat, toptan/dağıtım, perakende, profesyonel hizmet, inşaat. Sağlık, finans, sigorta, medya, gayrimenkul için ayrı dikey paket sunan satıcı bu örneklemde yok (Odoo gayrimenkulü sunuyor; Logo ve SAP Business One sayfaları açılamadı, aşağıda).
- Türkiye'de Mikro sektörleri ürün grubuna göre kesiyor (kırtasiye, kimya, metal, mobilya, otomotiv): bunlar bizim "imalat/dağıtım" ailesinin içinde alt dallar, ayrı profil gerektirmez.
- Logo: ana sayfa dört kategori verdi (Ön Muhasebe, Perakende Satış Yönetimi, e-Dönüşüm, Finansal Teknolojiler); Tiger/Netsis sektör paketleri sayfada adlandırılmadı [S23]. SAP Business One (403) ve Odoo'nun kendi sayfası (404) açılamadı: bu iki satıcı için sektör listesi **bulunamadı**.

Oyuna ders: satıcıların kendi sektör kümeleri 5-8 adet; 9 profil bu aralığın biraz üstünde, 13 ad onun da üstünde. Etkisi: oyuncuya 13 ayrı sektör "modül tablosu" öğretmek gerekmez; 9 profil + sektör başına "önemli modül" (bölüm 3) yeter. Dokuzdan fazlası okunmaz (A3 §7.2 uyarısı da aynı).

### 1.3 Bağımsız veri
- Eurostat: ERP kullanımı 10+ çalışanlı işletmelerde; küçük (10-49) %38, büyük (250+) %86 (2023) [S19]; 2025 AB ortalaması %46,45, küçük %41,08, orta %69,93, büyük %88,71 [S20]. Sektör (NACE) kırılımı bu sayfalarda yok; veri tabanı (isoc_eb_iip) API çağrıları 400 döndü, **bulunamadı**.
- Computer Economics, ABD, Ocak 2005: imalatçıların %40'ı ERP kullanıyor (süreç imalatı ayrıkdan biraz önde); bankacılık ve finansın artması, federal hükümet, sigorta ve sağlığın daha yavaş benimsemesi bekleniyor; rakam yok, neden yok [S8]. 21 yıllık veri: yön, ölçü değil.
- Akademik (ICEIS 2004, 22 kuruluşla görüşme, Tayland): imalatta temel modüller finans, malzeme, üretim planlama, satış ve dağıtım, kontrol; "hizmet sektörünün ERP kullanması mümkündür ama paketin gelen her modülü kullanılamaz" [S9].
- Panorama'nın modül/sektör kırılımı yayımlanan özette yok [A3 BOŞLUK, teyit]: bulunamadı.

Oyuna ders: hizmet sektöründe ERP'nin bir kısmı kullanılmaz (S9) ve finans/sağlık yavaş benimser (S8). Etkisi: bu profillerin "her zaman" listesi kısa (Mali Hizmetler'de 2 Z), oyuncunun bu adaylara satışta "az modül, derin Finans" oynayacağı anlamına gelir.

---

## 2. Güncellenmiş tablo: sektör → profil → modül

Önerilen 9 profil. Hücre: değer ve kanıt düzeyi (ZK = Z ve kaynaklı, SV = S ve varsayım). Modüller: FIN Finans ve Muhasebe · FAT Fatura ve e-Belge · SAL Satın Alma · İK İK ve Bordro · STK Stok · ÜRT Üretim · DEP Depo ve Sevkiyat · MAĞ Mağaza ve Kanal · PRJ Proje ve Zaman · VAR Varlık ve Bakım.

| Profil | Sektörler | FIN | FAT | SAL | İK | STK | ÜRT | DEP | MAĞ | PRJ | VAR |
|---|---|---|---|---|---|---|---|---|---|---|---|
| İmalat | manufacturing, textile | ZK | ZK | ZK | ZK | ZK | ZK | SV | NV | -V | SV |
| Dağıtım ve Lojistik | logistics | ZK | ZK | ZV | ZK | ZK | -V | ZK | NV | -V | SV |
| Perakende | retail | ZK | ZK | ZK | ZK | ZK | -V | SK | ZK | -V | NV |
| E-ticaret | ecommerce | ZK | ZK | SV | ZK | ZK | -V | ZK | ZK | -V | -V |
| Hizmet | technology, legal, media | ZK | ZK | SV | ZK | -V | -V | -V | -V | ZK | -V |
| Mali Hizmetler | finance, insurance | ZK | SV | SV | ZK | -V | -K | -K | -K | NV | NV |
| İnşaat | construction | ZK | ZK | ZK | ZK | SV | -V | NV | -V | ZK | ZK |
| Gayrimenkul | real_estate | ZK | ZV | SV | ZK | -V | -V | -V | -V | SV | ZK |
| Sağlık | health | ZK | ZK | ZK | ZK | ZV | -K | -V | -V | NV | SV |

İK her profilde Z, ama 1★ (3-10 koltuk) hesapta İK istenmez (SENTEZ §3.2: "2★ ve üstü"). "Hiç" hücresi oyunda aday kartında hiçbir zaman görünmez ("sağlık firması Depo ve Sevkiyat almaz": Sağlık × DEP "-" Erdem'in örneği, kaynak değil sahip kararı, o yüzden V).

**Z olup V olan hücreler** (kalibrasyon önceliği): Dağıtım × Satın Alma (toptan alım doğal ama kaynak sayfası söylemiyor), Sağlık × Stok (ERP Research S6/S9 tek aile, Erdem yönergesi; açılmayan üç arama özeti aynı yönde [S21a]), Gayrimenkul × Fatura (kira bedeli faturası mantık, kaynak yok).

**Hücre kaynakları** (K'lar):
- Temel dört (FIN, FAT, SAL, İK): ERP tipik modül listesi [S15, A3-S18]; Fatura için ayrıca Türkiye e-Fatura/e-İrsaliye mevzuatı [A3-S11 Orta, A3-S10]; sağlıkta SGK sözleşmeli kurumlar e-Fatura'ya geçmek zorunda [A3-S11].
- İmalat STK, ÜRT: Esichaikul [S9]; BC üretim emri ve ürün ağacı [S2]; NetSuite imalat sürümü [S1]; Mikro Metal, Kimya, Mobilya, Otomotiv [S3]; Computer Economics imalat önde [S8].
- Perakende MAĞ: BC POS [S2], NetSuite Retail Anywhere [S1], Nebim [S4], A3-S2. E-ticaret MAĞ ve DEP: NetSuite "Ecommerce & Retail" ve SuiteCommerce [S1], BC Shopify bağlayıcısı, karşılama ve iade [S2], A3-S5.
- Hizmet PRJ: Wikipedia PSA "avukatlar, denetçiler, BT danışmanları": proje, zaman takibi, faturalama, kaynak kullanımı [S16] (Orta); NetSuite yazılım ve profesyonel hizmet sürümleri ve OpenAir [S1]; BC proje yönetimi, iş maliyeti [S2]; A3-S4.
- İnşaat PRJ, VAR, SAL: BC inşaat (proje muhasebesi, iş maliyeti, ekipman, alt yüklenici) [S2]; A3-S7; IFS/Mint Jutras (EPC ve varlık ağırlıklı işlerde sektöre özgü işlev ihtiyacı en keskin) [S10, Düşük]. Gayrimenkul VAR: Wikipedia EAM "varlıklar: binalar, araçlar, gemiler" [S17, Orta] ve Odoo "Property Management" kategorisi [S5].
- Mali Hizmetler ÜRT, DEP, MAĞ "-": hizmet merkezli sınıf [S6].

---

## 3. 13 sektör eşlemesi

| Kod | Profil | Önemli modül adayları (aday kartında "önemli" işaretlenir) | Sektörün notu |
|---|---|---|---|
| manufacturing | İmalat | Üretim | Üretim derinliği: MRP, kalite, izlenebilirlik [A3 §2.1] |
| textile | İmalat | Stok (beden-renk varyantı), Üretim | Nebim: "beden, renk, koleksiyon, sezon" [S4]; fason üretim [S4]; bağımsız ikinci kaynak yok, V |
| logistics | Dağıtım ve Lojistik | Depo ve Sevkiyat, Varlık ve Bakım | Taşıma yönetimi, filo |
| retail | Perakende | Mağaza ve Kanal, Stok | POS, çok mağazalı stok |
| ecommerce | E-ticaret | Mağaza ve Kanal, Depo ve Sevkiyat | Kanal, pazaryeri, iade |
| technology | Hizmet | Proje ve Zaman, Fatura | Abonelik faturası, proje |
| legal | Hizmet | Proje ve Zaman | Saat bazlı zaman ve faturalama |
| media | Hizmet | Proje ve Zaman | Proje bazlı iş maliyeti (V) |
| finance | Mali Hizmetler | Finans | Arka ofis |
| insurance | Mali Hizmetler | Finans | Arka ofis (poliçe, hasar başka sistemde [S21c]) |
| construction | İnşaat | Proje ve Zaman, Varlık ve Bakım | İş maliyeti, hakediş, ekipman |
| real_estate | Gayrimenkul | Varlık ve Bakım, Fatura | Mülk ve kira bedeli |
| health | Sağlık | Stok, Varlık ve Bakım | Tıbbi malzeme, lot ve son kullanma, biyomedikal |

Kural: profil hücresi hangi modüllerin aday kartına girebileceğini söyler; "önemli modül" sektörden çekilir. Yani sektör adı hâlâ oyuncuya görünür ve farkı yaratır (Ege Medikal ile bir klinik zinciri aynı profilde ama önemli modülleri farklı olabilir). Etkisi: 13 adın hiçbiri "sadece etiket" kalmaz; profil sayısı 9'da tutulur.

### 3.1 Hangi sektör çiftleri aynı profilde kalabilir, hangileri ayrılmalı
Sektör düzeyi 10 modüllük matriste (13 sektör, 78 çift; ölçü `p_olcu.py`), farklı hücre sayısı (Z-kümesi farkı):
- Aynı kalmalı (0-1 hücre): technology ile legal (0), finance ile insurance (0), technology/legal ile media (1). Ortalama sektör çifti farkı 4,59 hücre.
- Yakın ama ayrı kalmalı (2 hücre): manufacturing ile textile (aynı Z kümesi, fark Mağaza ve Varlık seviyesi: tek profilde kalabilir, önemli modül ayırır); manufacturing ile logistics (ÜRT ile DEP yer değiştirir, Z kümeleri farklı); textile ile retail (Üretim ile Mağaza); technology/legal ile real_estate (Varlık ve Bakım Z'si).
- media ile real_estate (1 hücre): sayıca yakın ama anlamca ayrı; media Hizmet'te, real_estate ayrı kalır çünkü Varlık ve Bakım onun "her zaman" modülü. **Gayrimenkul bu tablonun en zayıf kanıtlı noktasıdır** (K yalnız FIN, İK, VAR; geri kalanı V). İki yol: ayrı profil (önerilen) ya da Hizmet'e bağlama (tek fark Varlık ve Bakım Z'si; 5 ve 7 modülde zaten Hizmet'le özdeşleşir, bölüm 7).
- Ayrılması gereken (Z kümesi farkı ≥ 2 ya da anlam): retail ile ecommerce (3 hücre: Satın Alma ve Depo seviyesi), construction ile real_estate (4), health ile logistics (3: tek Z farkı Depo ve Sevkiyat ve bu Erdem'in örneği), finance ile technology (3: Proje ve Zaman).
- Eski gruplamanın hataları: Hizmet'e finance ve insurance'ı koymak (PRJ Z ile N arası 2 basamak fark, FAT 1 basamak: 3 saçma/uyuşmayan hücre); İnşaat ve Gayrimenkul'ü birleştirmek (real_estate × STK: profilde S, sektörde "-"; DEP, SAL, PRJ 1 basamak). Ölçü: eski 7 profil 13 uyuşmayan hücre, 3'ü ≥2 basamak; önerilen 9 profil 3 uyuşmayan hücre (textile × MAĞ, textile × VAR, media × PRJ), 0'ı ≥2 basamak.

Oyuna ders: iki sektörü tek profile bağlamanın ölçütü "uyuşmayan hücre ≤1 basamak" olmalı. Etkisi: tasarımcı yeni sektör eklerken (kamu, gıda) aynı ölçüyü kullanır; kod tarafında profil tablosu 9 satırlık tek veri dosyası kalır.

---

## 4. 13 sektörün gerçek modül ihtiyacı

### 4.1 Lojistik: filo, varlık bakımı, taşıma yönetimi
- Satıcı tarafı: BC "toptan dağıtım" envanter dengeleme, satın alma, depolama, karşılama [S2]; NetSuite'in en büyük gelir sektörü "dağıtım ve toptan" [S1]; Mikro'nun adlı "Lojistik" çözümü var ama sayfada modül yok [S3]. Taşıma yönetimi (rota, taşıyıcı seçimi, navlun maliyeti) A3'te ERP Research'ten [A3-S3].
- Taşıma yönetimi ve ERP ayrımı: arama özetlerine göre TMS yük planlama, rota ve müşteri faturalamayı, ERP envanter, satın alma ve muhasebeyi taşır; ikisi de araç sağlığı ve sürücü saatlerini genellikle izlemez, filo bakımı boşluk kalır [S21b]. Hepsi satıcı blogu (Düşük), sayfalar açılmadı: K sayılmadı.
- Wikipedia EAM varlıklar arasında "araçlar, gemiler"i sayıyor [S17], ama bunun lojistik şirketlerine uygulanması bu kaynakta yazmıyor.
- Karar: Dağıtım ve Lojistik × Depo ve Sevkiyat = Z (K); Varlık ve Bakım = S (V, filo); Stok = Z (K, toptan dağıtımcı); Mağaza ve Kanal = N (V). **A3 farkı:** A3'ün "dağıtım" sayfası toptan dağıtımcıyı anlatıyordu (WMS 50/100 toplayıcı eşiği V tarafından dayanaksız bulundu [V #13]; bu eşiği kullanmadım). Kodda `logistics` kimliği iki okumaya açık (taşımacı/3PL ve toptancı); profil adı "Dağıtım ve Lojistik". Oynanış etkisi: lojistik adayı "Depo ve Sevkiyat" önemli der, oyuncu filo/varlık kartını (Varlık ve Bakım) sık sık görmez; bu modülü seçmek lojistik, inşaat ve gayrimenkul müşterisini birlikte kazandırır (üç profilde S/Z).
- A3 BOŞLUK: lojistik firmasının ERP'den ne beklediğini ölçen bağımsız kaynak bulunamadı.

### 4.2 Tekstil ve moda: beden-renk varyantı
- Nebim sayfasında hazır giyim için "beden, renk, koleksiyon ve sezon yönetimi" ve üretim için "reçete, fire, fason, kapasite planlama, maliyet" [S4]; Odoo mağazasında imalat altında Textile [S5]. Başka bağımsız kaynak yok: V.
- Beden-renk varyantı ayrı modül değil Stok'un bir kademesidir (bir ürün kodunun çok varyantı). Karar: textile İmalat profiline bağlı; "önemli modül" Stok (varyant), ikincisi Üretim; Mağaza ve Kanal profilde N olduğu için markalı tekstil nadiren Mağaza ister (textile sektöründe S, V).
- Oynanış etkisi: oyuncu Stok'un "varyant" kademesini geliştirirse tekstil adayları (ve perakende moda) önemli sorusunda yanıt alır; ayrı sektör kartı açmadan sektör kimliği doğar.
- Nebim sayfası tekstil üreticisi ile moda perakendecisini ayırmıyor. Kodun `textile` kimliği için "imalat" okuması benim yargım [GÖRÜŞ].

### 4.3 Hukuk, medya, teknoloji: proje, zaman, faturalama
- PSA tanımı: avukat, denetçi, BT danışmanı; proje, zaman takibi, faturalama, kaynak kullanımı; muhasebe, CRM ve bordro ile bütünleşir [S16]. NetSuite hizmet ve yazılım sürümleri ve OpenAir [S1]; BC proje yönetimi, iş maliyeti, kaynak [S2]; A3-S4 faturalanabilir doluluk %70-80.
- Medya: sektör sayfası veya satıcı paketi yok; Odoo "marketing agency" Danışmanlık altında [S5]. media × PRJ = S (V).
- Karar: Hizmet profili PRJ = Z (K), hukuk ve teknolojide önemli modül Proje ve Zaman; teknolojide ikinci Fatura (abonelik).
- Oynanış etkisi: aynı Hizmet profili hukuk büronuza (saat bazlı faturalama) da, yazılım şirketine (abonelik) da satılır; fark aday kartında önemli modül cümlesinde: "Zaman çizelgesinden faturalama bizim için önemli" ve "Abonelik faturası bizim için önemli".

### 4.4 Finans ve sigorta: ERP'nin arka ofis rolü
- NetSuite'in 2012 gelirinde finansal hizmetler 8. sırada [S1]; Gartner hizmet merkezli sınıfın tipik sektörü [S6]; hiçbir satıcının finans veya sigorta dikeyi yok (Mikro, BC, Odoo, NetSuite sürümleri) [S1-S5]; Computer Economics: finans artacak, sigorta ve sağlık daha yavaş [S8, 2005].
- Sigorta çekirdek sistemleri (poliçe yönetimi, hasar, prim faturalama) ERP'den ayrı ürün sınıfı; bir satıcı bunu "insurance ERP" diye adlandırıyor (Sapiens TIA, arama özeti) [S21c]: yani satıcı dilinde "ERP" bazen çekirdek sistemin kendisidir; bizim ERP ürünü yalnız arka ofis (defter, hesaplar, İK, idari satın alma) olur [GÖRÜŞ, S21c özetleri açılmadı].
- Karar: Mali Hizmetler yalnız FIN ve İK Z; FAT ve SAL S (V), PRJ/VAR N. Üç ürün merkezli modülün "-" hücresi K (Gartner sınıfı).
- Oynanış etkisi: banka ya da sigortacı adayı "iki modül ister, ikisi de derin" cümleleri kurar; oyuncunun ürünü Finans'ta güçlüyse bu adaylar kolay, fakat satışın getirisi (kaç modül, MRR) küçüktür: büyük koltuk, az modül.
- Mevzuat farkı (BDDK, SPK, sigorta mevzuatı, TFRS 17): **bulunamadı**, araştırma bütçesi yetmedi; kaynaksız bir cümle yazılmadı.

### 4.5 Sağlık: stok ve varlık
- Hastane ERP'si EHR ile gerçek zamanlı bağlanır, hasta bakımını yönetmez; ERP tarafı finans, tedarik zinciri (sözleşme uyumu, implant ve emanet stoku, ameliyathane malzeme tercih kartı), İK (yeterlilik/lisans, vardiya), biyomedikal bakım ve kalibrasyon [A3-S6, ERP Research, Düşük]. Üç arama özeti de aynı ayrımı söylüyor: ERP finans, tedarik, İK, faturalamayı taşır; klinik kayıt EHR'de [S21a, açılamadı: Wipfli 429, diğerleri özet].
- Türkiye: SGK sözleşmeli kurumlar ve tıbbi malzeme tedarikçileri e-Fatura'ya geçmek zorunda; sağlık ve ilaç eşiksiz e-belge sektörleri arasında [A3-S11 Orta, A3-S10]. KVKK md. 6'da "sağlık" özel nitelikli kişisel veri [A3-S14 Yüksek].
- ABD/AB'ye özgü düzenleme (HIPAA, GxP, DSCSA) Türkiye karşılığı bulunamadı [A3 §2.5]; kullanmadım.
- Karar: Sağlık × Stok = Z (V), Varlık ve Bakım = S (V; A3'ün Z'si K şartını karşılamadı), Depo ve Sevkiyat = "-" (Erdem'in örneği), Proje ve Zaman = N (V). Sağlık, "yeni modül" değil mevcut modüllerin düzenlemeli derinliğiyle ayrılır (yeterlilik takibi İK'da, lot ve son kullanma Stok'ta, biyomedikal Varlık'ta) [A3 §2.5 dersi].
- Oynanış etkisi: sağlık adayı Depo ve Sevkiyat sorusunu hiç sormaz; ürünün Stok'u lot ve son kullanmada zayıfsa sağlık hesabı yenilemede adlı şart koyar (Stok kademesi). Aynı Stok kademesi tekstil varyantı kadar özel: iki sektörü tek modülle ayırır.

### 4.6 Gayrimenkul: kira ve mülk
- 10 modüllük kümede "Kira ve Mülk" modülü yok. Kira bedeli Fatura'ya, mülkün kendisi Varlık ve Bakım'a düşer. Odoo mağazasında Gayrimenkul altında "Property Management" ve "Property Owner Association" var [S5]; ERP'de kira yaşam döngüsü (başvuru, yenileme, artış, depozito, geç ücret) arama özetlerinde geçiyor ama sayfalar açılmadı [S21e, özet]. Wikipedia EAM binaları varlık sayıyor [S17].
- Karar: Gayrimenkul × VAR = Z (K), × FAT = Z (V). Kira modülü gerekiyorsa 11. modül olur, ben önermiyorum (basitlik). Bunu açık bırakmak yerine: Fatura'nın "dönemsel kira faturası" kademesi Gayrimenkul'ü ayırır [GÖRÜŞ].

### 4.7 İnşaat, e-ticaret, perakende, imalat (kısa)
- İnşaat: iş maliyeti, hakediş (AIA ABD'ye özgü), ekipman, alt yüklenici [S2, A3-S7]; en çok "genel ERP'nin kaçırdığı" sektör [A3 §2.6; IFS: EPC işlerinde sektöre özgü özellik ihtiyacı en keskin, S10].
- E-ticaret: kanal, pazaryeri, iade, 3PL [S1, S2, A3-S5]; 2012 için pazaryeri entegrasyonları erken (varsayım, A3).
- Perakende: POS, çok mağaza stok [S1, S2, S4, A3-S2].
- İmalat: üretim derinliği üç ayrı kademe (MRP, kalite, izlenebilirlik) [A3-S1].

---

## 5. SENTEZ §3.2 tablosundan değişenler

| Değişiklik | Eski | Yeni | Neden |
|---|---|---|---|
| Profil sayısı | 7 | 9 | Mali Hizmetler ve Gayrimenkul ayrıldı; ölçü: saçma hücre 3'ten 0'a (bölüm 3.1) |
| Hizmet | teknoloji, hukuk, medya, finans, sigorta | teknoloji, hukuk, medya | Bankaya proje ve zaman sorulmaz |
| Mali Hizmetler | yok | FIN, İK Z; FAT, SAL S | Gartner sınıfı [S6], satıcıların dikeyi yok [S1-S5] |
| İnşaat ve Gayrimenkul | tek | İnşaat; Gayrimenkul | Stok, Proje ve Zaman, Satın Alma farkları |
| Dağıtım × Mağaza ve Kanal | S | N | Mağaza taşımacıya özgü değil (V) |
| Dağıtım × Varlık ve Bakım | yok (N) | S | Filo bakımı (V); Erdem'in araştırma yönergesi |
| Sağlık × Varlık ve Bakım | Z | S | K şartı karşılanmadı (tek Düşük aile) |
| Sağlık × Proje ve Zaman | yok | N | A3 matrisi N; V |
| İmalat × Mağaza ve Kanal | - | N | Tekstil markası için; sektör farkını 1 basamakta tutmak |
| Her profil × İK | Z | Z (2★ ve üstü) | Değişmedi |

Değişmeyenler: İmalat, Perakende, E-ticaret satırları (İK dışında) SENTEZ ile aynı.

---

## 6. Dönem eğilimi ve mevzuat farkı

**2012'de bulut ERP'yi kim alıyordu.**
- NetSuite'in 2012 gelir sıralamasında ilk on sektörden yedisi hizmet/yazılım/BT/telekom/finans/sağlık/eğitim, üçü ürün tarafı (dağıtım, e-ticaret ve perakende, imalat) [S1]. Yalnız NetSuite'in müşterisi: seçilim yanlılığı, genel pazara taşınamaz [SIÇRAMA].
- Panorama 2012 raporu (Ekim 2012; 246 katılımcı): bulut/SaaS payı 2011'de %6, 2012'de %18; sektör kırılımı yok [S12].
- Aberdeen 2011'den ikincil blog özeti (finansal hizmetler %22 SaaS, sağlık %42 SaaS "bulutu en çok düşünenler"): özet arama sonucunda gördüm, kaynağı açılamadı, kullanmadım [S21d, DEĞERLENDİREMEM].
- 2012 başında sektör bazlı ERP benimseme yüzdesi: **bulunamadı**.

**2012-2035 artış.** Kaynaklı veri **bulunamadı**. Çalışma varsayımı (varsayım): 2012'de imalat, dağıtım, hizmet, perakende ağırlıklı; e-ticaret 2015 sonrası artar (A3'ün aynı varsayımı: pazaryeri entegrasyonları 2012 için erken [A3 §2.8]); sağlık ve mali hizmetler yavaş benimsemeyle (Computer Economics 2005 yönüyle uyumlu [S8]) ilk yıllarda seyrek, sonra eşitlenir. Bu bir "aday gelme ağırlığı × yıl" sütunudur, profil tablosu değil; sim kalibre eder.

**Mevzuat farkı.**
- Sağlık: KVKK özel nitelikli veri [A3-S14 Yüksek, 6698 sayılı Kanun, kabul 24/03/2016, RG 07/04/2016]; SGK e-Fatura eşiksiz [A3-S11]. İkisi de oyunda yenileme ya da satış "şartı" olarak gelir; KVKK 2016'dan önce hiçbir müşteride çıkmamalı.
- Finans ve sigorta: **bulunamadı** (BDDK/SPK/sigorta mevzuatı araştırılmadı).
- e-Fatura takvimi V dosyasının #2 düzeltmesine bağlı [V #2]; bu belgenin işi değil.

Oyuna ders: dönem eğilimi profil tablosuna yazılmaz, aday üretim ağırlığına yazılır; mevzuat tablosu profilden bağımsız bir "şart" katmanı kalır (A3 §4 dersi). Etkisi: 2012'de ilk 30 haftada gelen adaylar hizmet/dağıtım/imalat ağırlıklı olur; sağlık ve e-ticaret oyuncusu sonra gelir, oyuncunun "hangi sektöre odaklanayım" kararı yıllar içinde değişir.

---

## 7. Ayrışma ölçüsü: 5, 7 ve 10 modül

### 7.1 İndirgeme kuralı (10 → 7 ve 10 → 5)
| Modül (10) | 7 modül | 5 modül |
|---|---|---|
| Finans ve Muhasebe | Finans | Finans |
| Fatura ve e-Belge | Fatura | Fatura |
| Satın Alma | Satın Alma | Satın Alma |
| İK ve Bordro | İK | İK |
| Stok | Stok | Stok |
| Üretim | Tedarik (üretim ve sevkiyat birlikte) | düşer |
| Depo ve Sevkiyat | Tedarik | düşer |
| Mağaza ve Kanal | düşer | düşer |
| Proje ve Zaman | Proje ve Zaman | düşer |
| Varlık ve Bakım | düşer | düşer |

Tedarik hücresi = Üretim ve Depo ve Sevkiyat hücrelerinin yüksek olanı (sıra Z > S > N > -). Profil başına 7 ve 5 modülde kaybedilen (profilin Z ya da S istediği) modül:

| Profil | 7 modülde kaybeder | 5 modülde kaybeder |
|---|---|---|
| İmalat | Varlık ve Bakım (S) | Üretim (Z), Depo (S), Varlık (S) |
| Dağıtım ve Lojistik | Varlık ve Bakım (S) | Depo (Z), Varlık (S) |
| Perakende | Mağaza ve Kanal (Z, imza) | Mağaza (Z, imza), Depo (S) |
| E-ticaret | Mağaza ve Kanal (Z, imza) | Mağaza (Z), Depo (Z) |
| Hizmet | hiçbir şey | Proje ve Zaman (Z, imza) |
| Mali Hizmetler | hiçbir şey | hiçbir şey |
| İnşaat | Varlık ve Bakım (Z) | Proje (Z), Varlık (Z) |
| Gayrimenkul | Varlık ve Bakım (Z, imza) | Proje (S), Varlık (Z) |
| Sağlık | Varlık ve Bakım (S) | Varlık (S) |

### 7.2 Ölçü tablosu (9 profil, önerilen gruplama; hesap `p_olcu.py`)
| Ölçü | 10 modül | 7 modül | 5 modül |
|---|---|---|---|
| Ayırt edilebilir profil (aynı "her zaman" kümesini paylaşan tek sayılır) | 9 / 9 | 7 / 9 | 5 / 9 |
| Ayırt edilebilir profil (tüm hücre vektörü) | 9 / 9 | 8 / 9 | 5 / 9 |
| Profil çifti başına ortalama farklı hücre (36 çift) | 4,69 | 2,94 | 1,42 |
| En az farklı hücre | 2 | 0 | 0 |
| Özdeş çiftler | yok | İmalat ile Dağıtım | İmalat/Dağıtım/Perakende/Sağlık (altı çift), Hizmet/Gayrimenkul |
| "Her zaman" kümesi farkı, çift başına ortalama | 3,11 | 2,22 | 1,33 |
| Ölü modül (hiçbir profilin "her zaman" istemediği) | yok | yok | yok |
| Ölü modül (Z ve S ikisi de yok) | yok | yok | yok |

İmza modülü (profilin Z istediği ve en çok bir profille paylaştığı):
- 10 modül: İmalat 1 (ÜRT), Dağıtım 1 (DEP), Perakende 1 (MAĞ), E-ticaret 2 (DEP, MAĞ), Hizmet 1 (PRJ), Mali Hizmetler 0, İnşaat 2 (PRJ, VAR), Gayrimenkul 1 (VAR), Sağlık 0.
- 7 modül: Hizmet 1 (PRJ), İnşaat 1 (PRJ), diğer yedisi 0.
- 5 modül: hepsi 0.
Z ve S birlikte sayılınca (≤2 profil): 10 modülde İmalat 1, Perakende 1, E-ticaret 1, öbürleri 0.

### 7.3 Karşılaştırma gruplamaları
| Gruplama | Profil | Ayırt edilir (Z kümesi) 10 / 7 / 5 | Ortalama fark 10 / 7 / 5 | Saçma hücre (≥2 basamak) |
|---|---|---|---|---|
| Eski 7 profil (SENTEZ) | 7 | 7 / 5 / 4 | 4,38 / 2,48 / 1,00 | 3 (13 uyuşmayan hücre) |
| Önerilen 9 profil | 9 | 9 / 7 / 5 | 4,69 / 2,94 / 1,42 | 0 (3 uyuşmayan) |
| 13 sektör ayrı | 13 | 10 / 7 / 5 | 4,59 / 2,87 / 1,44 | 0 |

13 sektörün ayrı profil olması yalnız iki sektör çiftini özdeş yapar (technology/legal; finance/insurance) ve ayırt edilebilir sayıyı artırmaz; 9 profil aynı bilgiyi daha az satırla taşır.

### 7.4 Okunuş
- 10 → 7: Mağaza ve Kanal ile Varlık ve Bakım düşer. Perakende ve E-ticaret imzalarını, İnşaat ve Gayrimenkul bir Z'sini kaybeder; Gayrimenkul 7 modülde Hizmet'e tek hücre (Proje seviyesi, Z ile S) kadar yaklaşır. İmalat ile Dağıtım özdeşleşir (ikisi de Tedarik Z, Varlık düşer): "Üretim sormayan imalatçı" ile "Depo soran dağıtımcı" aynı modül setini ister.
- 10 → 5: dokuz profilin dördü aynı beş modülü ister (İmalat, Dağıtım, Perakende, Sağlık); Hizmet ile Gayrimenkul özdeş; yalnız Mali Hizmetler, E-ticaret, Hizmet/Gayrimenkul, İnşaat kendi başına durur. Sektör seçimi oyuncunun kararı olmaz.
- Ölü modül yok: bu 10 modülün her biri en az bir profilin "her zaman" modülüdür. Z kümesi büyüklüğü: İmalat 6, Dağıtım 6, Perakende 6, E-ticaret 6, Hizmet 4, Mali 2, İnşaat 6, Gayrimenkul 4, Sağlık 5 (10 modül).
- Z sayısının 6 olması 5★ hesapta (7-10 modül ister) tam, 2★ hesapta (3-5 modül) fazla. Sıra kuralı: önemli modül, Finans, sektör imzası, sonra kalan Z'ler; S'ler 3★ ve üstünde olasılıkla [WORKING].

Oyuna ders (bölüm sonu): ayrım gücü için kritik modül sayısı 7'nin altına inmemeli; 7 ile 10 arasındaki fark "İmalat ile Dağıtım ayrı" ve "Perakende, E-ticaret imza", yani sektör çiftlerinin üçünün kimliği. Etkisi: 7 modülle bile oyun oynanır ama "hangi sektörde lider olayım" kararının yarısı (altı sektörün Varlık ve Mağaza kimliği) yok olur; 10 modül ek içerik (kart ve Ar-Ge) ve rakiplerin de 10 modülü yürütmesi demektir (SENTEZ §8: aynı katalog).

---

## 8. Oyunda sektörler ne kadar farklı oynar (cümleler)

10 modül, 9 profil:
- "Sağlık adayı Depo ve Sevkiyat sormaz; lojistik adayı onu önemli modül diye söyler: Depo kartına yatırım yaparsan lojistik ve e-ticaret kapılarını açarsın, sağlık ve hizmet kapılarını açmaz."
- "Hukuk ve yazılım adayları aynı cümleyi kurar (Proje ve Zaman), banka ve sigortacı ise yalnız Finans'a bakar: Proje ve Zaman kartı hizmet ve inşaat müşterilerini birlikte ilgilendirir, mali hizmetleri hiç."
- "Perakendeci Mağaza ve Kanal'ı bir yatırımla alır; imalatçı aynı modülü nadiren ister; bu yüzden bu karta yatırım iki profilin (Perakende, E-ticaret) kapısını açar."
- "Varlık ve Bakım inşaat, gayrimenkul ve sağlıkta aranır; imalat ve lojistikte sık, perakendede nadir: sektör çeşitliliği isteyen oyuncunun en geniş etkili kartı."

7 modül:
- "İmalatçı ile dağıtımcı aynı modül setini ister; fark yalnız önemli modül cümlesinde ('Üretim' / 'Depo')."
- "Mağaza ve Kanal yok: perakende ile e-ticaret yalnız Stok ve Tedarik'te ayrışır."

5 modül:
- "Dört sektörde aynı beş modül 'her zaman'; sektöre satış kararı kalmaz, her aday aynı ürünü ister."

Her cümle bir oynanış kararını (kart yatırımı, hedef sektör) ve bir sıklığı (görüşme başına, yılda 1-2 stratejik) taşır.

---

## 9. Aday kartında oyuncunun göreceği örnekler

Metin SENTEZ §3.2'deki sözcükleri kullanır ("istediği seviyede", "bir adım eksik", "çok eksik", "bizde yok"). Mock; yerleşim bu belgenin işi değil.

**Ege Medikal** · Sağlık · 12 koltuk (2★)
İstediği modüller:
- Stok · ÖNEMLİ · bir adım eksik
- Finans ve Muhasebe · istediği seviyede
- Fatura ve e-Belge · istediği seviyede
- Satın Alma · bizde yok

Depo ve Sevkiyat, Üretim, Mağaza ve Kanal satırı hiçbir zaman görünmez. Oyuncunun kararı: Satın Alma'sız teklif vermek (SENTEZ §5.2 uyum çarpanı ×0,5) ya da geçmek; Stok "önemli" olduğu için bir adım eksik ×0,6. İpucu satırı: "Tıbbi malzeme, lot ve son kullanma izlemesi bizim için önemli."

**Akdeniz Lojistik** · Dağıtım ve Lojistik · 45 koltuk (3★)
- Depo ve Sevkiyat · ÖNEMLİ · istediği seviyede
- Finans ve Muhasebe · istediği seviyede
- Fatura ve e-Belge · istediği seviyede
- Satın Alma · bir adım eksik
- Varlık ve Bakım · çok eksik (filo bakımı)

**Kuzey Hukuk Bürosu** · Hizmet · 6 koltuk (1★)
- Proje ve Zaman · ÖNEMLİ · istediği seviyede
- Finans ve Muhasebe · bir adım eksik

(1★ iki modül ister; İK 2★'dan başlar.)

---

## 10. Başarısız ve eleştirilmiş örnekler

Arama: "vertical ERP acquired", "lost deals missing industry functionality", "industry-specific ERP gaps survey" ve tek ürün ByDesign sorgusu (4 arama). Sonuç: istenen deseni doğrudan gösteren vaka **bulunamadı**; en yakınları:

1. **Tek ürün, kimliği belirsiz: SAP Business ByDesign.** 19 Eylül 2007'de duyuruldu [S14]; hedef 10.000 müşteri, 2010'da hedef on kat düşürüldü, 22 Ekim 2013'te 785 müşteri ve "artık büyük özellik güncellemesi yok" [S13]. Constellation Research: kimlik krizi, satış ekibinin Business One'ı tercih etmesi (arama özeti, sayfa açılamadı [S22]). Çelişki: Wikipedia 2021 SAP blogundan "yaklaşık 10.000 şirket" [S14]; 2013'ün 785'iyle aynı anda doğru olabilir (sekiz yıl, farklı sayım) ya da değil: [DEĞERLENDİREMEM]. Bu "tüm sektörlere tek ürün yenilgisi" diye okunamaz: kaynaklar sektör odağından söz etmiyor [SIÇRAMA]. Gartner 2023'te ByDesign'ı niş oyuncu sayıyor [S6].
2. **Genel satıcı dikeyi satın alıyor: Microsoft 2009.** Dynamics AX için Fullscope (imalat), Computer Generated Solutions (profesyonel hizmet), LS Retail ve Columbus IT (perakende) yazılım hakları satın alındı; sebep "müşterilere geliştirme geleceği konusunda kesinlik"; bazı sektör bileşenleri ürüne yazılıyor, eklenti olarak satılmıyor [S18]. Bağımsız analist yorumu yok; "dikey genel ERP'ye yenildi" değil, genelin dikeyi içine alması.
3. **Satın alma sonrası pişmanlık: IFS/Mint Jutras 2011** (200+ yönetici, satıcı sponsorlu): %67 sektöre özgü işlevi önemli sayıyor, %60 sektöre özgü özellik eksikliğinden işlev boşluğu yaşıyor, ihtiyaç en çok EPC/inşaat, hizmet yoğun ve varlık getirisi odaklı işlerde [S10]. Kayıp satış değil; satın alma sonrası bir hoşnutsuzluk. Düşük güven.
4. **Büyük projeler: Panorama top 10 (2025).** Lidl: ERP satış fiyatıyla çalışıyordu, Lidl alış fiyatıyla; "daha çok eski süreçleri değiştirme isteksizliği". Waste Management: satıcı "ABD standartlarına uyarlı" dedi, değildi. Haribo: seçimden önce süreç haritalaması eksik. Revlon: işlev sorunları [S11]. Hiçbiri açıkça sektöre özgü modül eksikliğine bağlanmıyor [A3-S16, teyit].
5. **Değişiklik yükü.** Panorama 2012: katılımcıların %70'i ERP yazılımında küçük-orta değişiklik yaptı [S12]; TRG 2016: dikeye gitmek özelleştirmeyi çarpıcı azaltır ama ~%90 proje yine de özelleştirme ister [A3-S17].

**Oyuna ders.** (a) Eksik modül ceza değil bilgidir (zaten öyle); gerçek kayıp satıcının söz vermesi ve teslimidir: sektöre özgü eksik için "yaparım" sözü (mevcut söz mekaniği) tek ek karar, yılda 1-2 kez. (b) Tek ürünle her sektöre satmak tek başına yenilgi kanıtı değildir (kaynak yok): oyunda bu "çok profile az derinlik" riski olarak kalır, yani her profilde Z modüllerini düzgün yapmayan oyuncu çok aday kaybeder ama ceza ayrı yazılmaz. (c) Büyük hesap "dikey bile olsa özelleştirme ister" (%70 ve %90) → sektör müşterisinin tek derinlik cümlesiyle tatmin edilememesi, istek mekanizması (SENTEZ §7) bunu zaten karşılar.

---

## 11. Boşluklar

- Sektör × modül kullanım yüzdesi: bağımsız kaynakta yok. Eurostat NACE kırılımı API'den alınamadı.
- Logo (Tiger/Netsis) ve SAP Business One sektör listesi: açılamadı. ETA ve Uyumsoft'a hiç bakılmadı.
- Gartner'ın kendi metni, Gartner/IDC/Forrester "industry cloud" tanımı: açılamadı; yalnız CX Today özeti. "Industry cloud" için kaynak bulunamadı.
- Finans/sigorta mevzuatı ve Türkiye'ye özgü bankacılık ERP rolü: bulunamadı.
- Sağlık, lojistik, gayrimenkul için açılan tek bağımsız (Orta+) kaynak yok; hepsi satıcı/danışman sayfası veya arama özeti.
- 2012 sektör bazlı bulut ERP benimsemesi: bulunamadı (NetSuite gelir listesi tek şirket).
- Gıda ve kamu kodda sektör değil; bu belgede profile bağlanmadı (A3: gıda imalata bağlı, kamu ilk sürümde yok).

---

## Okunanlar ve okunamayanlar (evidence)

**Açılıp okundu:** NetSuite FY2012 10-K (ilk 100.000 / 193.417 karakter), Microsoft Business Central sayfası, Mikro ana sayfa, Nebim ana sayfa, Odoo uygulama mağazası sektör kategorileri, CX Today Gartner 2023 hizmet merkezli özeti, IndustryWeek 2005, Esichaikul ve Nuankhieo 2004, IFS/Mint Jutras (aeroweb), techpartner.news (Microsoft 2009), The Register 2013 (ByDesign), Wikipedia (ByDesign, ERP, PSA, EAM), IT Jungle 2013 (Panorama 2012), Panorama top 10 (2025), Eurostat haber ve "Digital economy and society statistics" sayfaları, Logo ana sayfa.
**Açılamadı (403/404/400/429):** NetSuite sektör sayfası, SAP Business One, Odoo kendi sayfası, Microsoft sektör sayfası, Eurostat API (NACE kırılımı, 4 deneme), SCMR (IFS çalışmasının orijinali), Forrester 2009, The Manufacturer (UK KOBİ modül anketi), Solutions Review (Gartner ürün merkezli tanım), Wipfli sağlık ERP, Gartner'ın kendisi.
**Yalnız arama özeti (açılmadı, K'ya sayılmadı):** Gartner ürün merkezli tanım ve "EAM" ifadesi; Constellation (ByDesign); sağlık ERP (Attract, Wipfli, ERPFocus); TMS/ERP bölünmesi (PCSsoft, Freightfox, FleetRabbit); sigorta çekirdek sistemleri (Decerto, Sapiens, KPMG/Appian); Aberdeen 2011; Plex/MPI 2013; GoodFirms; ecosire/ddg gayrimenkul sayfaları.
**WebSearch:** 14 (Gartner; Eurostat; NetSuite 10-K; Odoo; Mikro/lojistik; ERP sektör benimseme; dikey satın alma; sektör boşluğu anketi; sigorta çekirdek; lojistik TMS; ByDesign; bulut 2012; gayrimenkul; sağlık).

---

## Kaynak sicili

Erişim tarihi hepsinde 2026-10-20. A3'ten taşınan kaynaklar `[A3-S#]` ile anılır (`A3_sektor_modul.md` sicili); burada yeniden numaralandırılmadı.

| S# | URL | Yayıncı | Yayın tarihi | Güven | Not |
|---|---|---|---|---|---|
| S1 | https://www.sec.gov/Archives/edgar/data/0001117106/000111710613000006/a2012netsuiteform10-k.htm | NetSuite Inc., ABD SEC 10-K (FY2012) | 2013 | Orta (gelir sıralaması); Düşük (ürün tanımı) | beş sektör sürümü, ilk on sektör |
| S2 | https://www.microsoft.com/en-us/dynamics-365/products/business-central | Microsoft | yayın tarihi yok (canlı sayfa) | Düşük | yedi sektör ve modül listesi |
| S3 | https://www.mikro.com.tr/ | Mikro Yazılım | yayın tarihi yok | Düşük | sekiz "sektörel" çözüm adı |
| S4 | https://www.nebim.com.tr/ | Nebim | yayın tarihi yok | Düşük | hazır giyim, üretim, ticari |
| S5 | https://apps.odoo.com/apps/industries | Odoo S.A. | yayın tarihi yok | Düşük | sektör taksonomisi |
| S6 | https://www.cxtoday.com/customer-analytics-intelligence/gartner-magic-quadrant-for-cloud-erp-for-service-centric-enterprises-2023-the-rundown/ | CX Today | 2023-09-11 | Orta (ikincil) | Gartner hizmet merkezli tanım |
| S7 | https://solutionsreview.com/enterprise-resource-planning/whats-changed-2020-gartner-magic-quadrant-for-cloud-erp-for-product-centric-enterprises | Solutions Review | 2020 | Düşük | 403, yalnız arama özeti |
| S8 | https://www.industryweek.com/archive/manufacturing-most-likely-use-erp-health-care-insurance-least-likely | IndustryWeek (Computer Economics) | 2005-01-13 | Orta | imalat %40; sağlık, sigorta yavaş |
| S9 | https://scitepress.org/Papers/2004/25939/pdf/index.html | ICEIS 2004, Esichaikul ve Nuankhieo (AIT, Tayland) | 2004 | Orta | 22 kuruluş görüşmesi |
| S10 | https://www.aeroweb-fr.net/depeches/2011/11/67-of-erp-users-want-more-industry-specific-functionality-ifs-study-reveals | Business Wire aktarımı, IFS/Mint Jutras | 2011-11-11 | Düşük | satıcı sponsorlu, 200+ yönetici |
| S11 | https://www.panorama-consulting.com/top-10-erp-failures/ | Panorama Consulting (Bill Baumann) | 2025-09-09 | Orta | Lidl, Waste Management, Haribo, Revlon |
| S12 | https://www.itjungle.com/2013/02/05/fhs020513-story06/ | IT Jungle (Alex Woodie) | 2013-02-05 | Orta | Panorama 2012 raporu: bulut %6 → %18, %70 değişiklik |
| S13 | https://www.theregister.com/2013/10/22/sap_end_of_development_business_by_design/ | The Register (Gavin Clarke) | 2013-10-22 | Orta | ByDesign 785 müşteri, hedef 10.000 → 1.000 |
| S14 | https://en.wikipedia.org/wiki/SAP_Business_ByDesign | Wikipedia | canlı | Orta | duyuru 2007-09-19, 2021'de ~10.000 şirket |
| S15 | https://en.wikipedia.org/wiki/Enterprise_resource_planning | Wikipedia | canlı | Orta | ERP tipik modül listesi |
| S16 | https://en.wikipedia.org/wiki/Professional_services_automation | Wikipedia | canlı | Orta | PSA: avukat, denetçi, BT danışmanı |
| S17 | https://en.wikipedia.org/wiki/Enterprise_asset_management | Wikipedia | canlı | Orta | EAM varlık türleri |
| S18 | https://www.techpartner.news/news/microsoft-spends-big-on-vertical-erp-software-156465 | techpartner.news (Brett Winterford) | 2009-09-23 | Orta-Düşük | Microsoft dört dikey ISV |
| S19 | https://ec.europa.eu/eurostat/web/products-eurostat-news/w/ddn-20240516-2 | Eurostat | 2024-05-16 (URL) | Yüksek | 2023 ERP: küçük %38, büyük %86 |
| S20 | https://ec.europa.eu/eurostat/statistics-explained/index.php?title=Digital_economy_and_society_statistics_-_enterprises | Eurostat | 2025 verisi | Yüksek | ERP %46,45; küçük %41,08, orta %69,93, büyük %88,71 |
| S21 | arama özetleri: (a) https://www.wipfli.com/insights/articles/hc-tc-7-challenges-that-drive-erp-modernization-in-healthcare ve https://attractgroup.com/blog/healthcare-erp-software/; (b) https://pcssoft.com/blog/erp-tms/ ve https://www.freightfox.ai/blog/transportation-management-system-vs-erp ve https://fleetrabbit.com/industry/transportation-and-logistics/tms-erp-integration-trucking-fleets; (c) https://www.decerto.com/post/transforming-insurance-with-core-software-solutions ve https://www.appsruntheworld.com/customers-database/products/view/sapiens-tia; (d) https://softwarestrategiesblog.com/2012/01/02/how-cloud-computing-and-erp-mobility-are-reordering-gartners-hype-cycle-for-erp/amp/ (Aberdeen aktarımı); (e) https://ecosire.com/hi/industries/real-estate ve https://ddg.wcroc.umn.edu/?p=35813 | satıcı ve danışman blogları | 2012-2025, tarih kayıtsız | Düşük | sayfalar açılmadı (Wipfli 429); K'ya sayılmadı |
| S22 | https://www.constellationr.com/insights/news/sap-doubles-down-business-bydesign-cloud-erp | Constellation Research | tarih okunmadı | Orta-Düşük | yalnız arama özeti; ByDesign kimlik krizi |
| S23 | https://www.logo.com.tr/ | Logo Yazılım | yayın tarihi yok | Düşük | dört kategori; sektör modülü listelenmedi |
