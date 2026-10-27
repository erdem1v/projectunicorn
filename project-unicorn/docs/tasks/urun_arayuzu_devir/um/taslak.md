# UM taslağı: modül ve hat adları (ERP)

Durum: taslak, yardımcı yönetmene gider. Tüm TR/EN değerler "onay bekliyor". Yalnız CSV değeri değişir, anahtar değişmez.
Okunan ağaç B = `scratchpad/base/project-unicorn` (değişmeyen kopya). CSV'ye, koda, veriye dokunulmadı.

Kaynak kısaltmaları (hepsi `docs/tasks/faz_cde/pazar2/out/` altında):
SENTEZ = `SENTEZ_ERP_PAZARI.md` §3.1; A1/A2/A3 = ilgili araştırma dosyaları; M = `tur2/M_modul_sayilari.md` (görevde adı geçen üç dosyada gerçek modül adı çok az çıktığı için, aynı klasör ailesindeki bu dosyayı da okudum; M'nin içeriği "Düşük/Orta" güvenli, tek yayıncı ya da arama özeti).
"kaynakta yok" = A1, A2, A3, M, SENTEZ'de o ad ya da o İngilizce karşılık geçmiyor; yeni web araması yapılmadı.

## 0. Doğrulananlar

- Ledger'ın adımları kaynakta aynen böyle: `PROD_STEP_ERP_LEDGER_K1/K2/K3` = Ön Muhasebe / Hesap Planı / Otomatik Mutabakat (EN: Basic Bookkeeping / Chart of Accounts / Automatic Reconciliation). Adım anahtarı `product_lines.gd:177` ile `PROD_STEP_<HAT>_K<n>` diye türüyor (hat kimliğinden `line_` atılıp büyütülerek); hat adı anahtarı `product_lines.gd:290`, `PROD_LINE_<HAT>`.
- Alan listesi `data/product/sprint.json` `areas` bloğunda, süzgeç `SprintCatalog.areas_for(subtype, market)` (`sprint_catalog.gd:43`, `market in a.markets`). ERP B2B'dir: Çekirdek, İlk kullanım, Entegrasyonlar, Güven (dört). B2C beşini görür: Çekirdek, İlk kullanım, Büyüme, Güven, Gelir; B2C'ye özgü olanlar Büyüme ve Gelir (iki).
- Alan başına hatlar (`sprint.json`): Çekirdek = ERP'nin beş kimlik hattı (hat listesi `lines: []`, `identity: true`; hatlar `ProductLines`'tan gelir); İlk kullanım = paylaşılan Mobil + gizli Kendi Kendine Servis; Entegrasyonlar = paylaşılan Entegrasyonlar; Güven = paylaşılan Güvenlik + Dayanıklılık; Büyüme (B2C) = paylaşılan Entegrasyonlar; Gelir (B2C) = ücretli plan.
- Alanın kısa adı cümlelerde (`area_short`), tam adı satırda ve `PRODUCT_TIP_CARD_MODULE` ipucunda (`area_name`) okunur. Bu yüzden bu taslakta alanların KISA adı hiç değişmiyor; yalnız tam ad ("&" kalkıyor) ve TR mono.
- `loc` tarafı: `docs/design/localization_glossary.md` satır 79: "İlk Kullanım ve Erişim" TR adı sahip kararıyla 2026-10-17'de değişti; bu yüzden dokunmuyorum, yalnız mono ve "&".
- TAB_FINANCE = "Finans / Finance" ürünün Finans sekmesidir (şirketin parası). Bu, "Finans" kelimesini bir modül adına koymanın riskini belirler (Bölüm 4).

## 1. Tablo 1: Alanlar (ekranda MODÜLLER)

Hücre biçimi: tam / kısa / mono. Anahtarlar: `PRODUCT_AREA_<X>`, `_SHORT`, `_MONO`.

| Alan | Pazar | Bugün TR | Bugün EN | Öneri TR | Öneri EN | Tabloya bağlı mı / sapma | Gerekçe |
|---|---|---|---|---|---|---|---|
| core | ERP + B2C | Çekirdek / Çekirdek / ÇK | Core / Core / CO | Çekirdek / Çekirdek / ÇK (değişmez) | Core / Core / CO (değişmez) | Tabloda alan adı yok: SENTEZ §3.1 alanı "beklenti birimi olmaktan çıkar, gruplama olarak kalabilir" diyor. Değişiklik yok. | ERP tanımının kendisi "çekirdek + sektör eki" (A3 §1, A3-S18); NetSuite'in çekirdeği "çekirdek finans" diye anılıyor (M, NetSuite satırı). ÇK ve CO'nun bildiğim başka anlamı yok. |
| onboarding | ERP + B2C | İlk Kullanım ve Erişim / İlk kullanım / **İK** | Onboarding & Access / Onboarding / ON | İlk Kullanım ve Erişim / İlk kullanım / **İE** | Onboarding and Access / Onboarding / ON | Tabloda yok. Sapma yalnız mono ve "&": TR ad sahip kararıdır (glossary satır 79), dokunulmadı. | "İK" insan kaynaklarıdır ve SENTEZ'in 10 modülü içinde "İK ve Bordro" var; aynı oyunda iki ayrı "İK" olur. "İE" bildiğim bir kısaltma değil, İlk + Erişim baş harfleri. Elenenler: "İL" (il = vilayet), "KU" (anlamsız, okuma ipucu yok). |
| integrations | ERP | Entegrasyonlar / Entegrasyonlar / **EN** | Integrations / Integrations / IN | Entegrasyonlar / Entegrasyonlar / **EG** | Integrations / Integrations / IN (değişmez) | Tabloda yok (alan); adı, tablodaki platform hattı "Entegrasyonlar" ile aynı kaldığı için tutarlı. Sapma yalnız mono. | "EN" Türkçede "en" (en çok, genişlik) ve İngilizce kısaltması. "EG" anlamsız (Entegrasyon'un 1. ve 5. harfi). Elenen: "ET" (et = meat), "ER" (er). Yedek: "NT". |
| growth | B2C | Büyüme / Büyüme / BÜ | Growth / Growth / GR | değişmez | değişmez | Tabloda yok (B2C, ERP tablosunun kapsamı dışı). | Karışma yok; B2C'ye özgü alan, bildiğim başka anlamı yok. |
| trust | ERP + B2C | Güven & Ölçek / Güven / GÜ | Trust & Scale / Trust / TS | **Güven ve Ölçek** / Güven / GÜ | **Trust and Scale** / Trust / TS | Tabloda yok. Sapma yalnız "&" yerine "ve/and". | Alan, Güvenlik ve Yetki ile Dayanıklılık hatlarını ve sunucu uyarısını (`infra_alert`) taşıyor. Gerçek üründe bu ada rastlamadım: kaynakta yok. Kısa ad (cümlelerde okunan) aynı kaldığı için ek riski yok. |
| revenue | B2C | Gelir / Gelir / GE | Revenue / Revenue / RV | değişmez | değişmez | Tabloda yok (B2C). | `SALES_B2C_PLAN_HINT` metni "Ürün'de Gelir alanındaki" diye adı düz yazıyor; ad değişmediği için dokunulmaz. |

Uzunluk: tam adlar en çok 22 karakter ("İlk Kullanım ve Erişim"); kısa adlar en çok 13 ("Entegrasyonlar").

## 2. Tablo 2: Hatlar

Anahtarlar: `PROD_LINE_ERP_*`, `PROD_LINE_SHARED_*`, `PROD_LINE_HIDDEN_*`. `note_tool` ve `video_clip` hatları dışarıda. Adım adları (K1, K2, K3) bugünkü TR / EN, değişmez.
Hat adı tek anahtardır (kısa/mono yok). Tam ad en çok 22 karakter: en uzunu "Kendi Kendine Servis" (20, değişmez).

| Hat | Alanı | Bugün TR / EN | Öneri TR / EN | Adımlar (bugünkü, K1 / K2 / K3) | Tabloya bağlı mı / sapma | Gerekçe ve gerçek ürün dayanağı |
|---|---|---|---|---|---|---|
| line_erp_ledger | core | Defter / Ledger | **Muhasebe / Accounting** | Ön Muhasebe, Hesap Planı, Otomatik Mutabakat · Basic Bookkeeping, Chart of Accounts, Automatic Reconciliation | Yarı bağlı: tabloda "Finans ve Muhasebe"nin ikinci yarısı. Tabloda ayrı satır yok; ikiye bölmek benim. Birleşme (C'nin parktaki işi) gelince iki hat tek "Finans ve Muhasebe / Finance and Accounting" olur. | TR "muhasebe" kaynakta var: Netsis Wings "muhasebe ve finans" (M, Logo/Netsis satırı), OpenERP 7.0 kategorisi "muhasebe ve finans" (M, Odoo satırı), ERP Research "Finans ve muhasebe" (M, ERP Research satırı), A3 §1 "finans/muhasebe (genel defter, borç, alacak)". EN "Accounting" olarak kaynakta yok (M'de SAP B1 için "Financials", "Finance and Controlling" geçiyor). K1 adımı "Ön Muhasebe" zaten bugünkü kapı; modül adı bir üst düzeyde "Muhasebe" olur, "Defter" modül adı olmaktan çıkar. |
| line_erp_cashflow | core | Nakit Akışı / Cash Flow | **Nakit Yönetimi / Cash Management** | Kasa Hareketleri, Nakit Akış Tablosu, Nakit Öngörüsü · Cash Movements, Cash Flow Statement, Cash Forecast | Yarı bağlı: tabloda "Finans ve Muhasebe"nin ilk yarısı ("defter, borç, alacak, nakit akışı"). Ayrı satır yok; bölme benim. | Bugünkü ad, K2 adımının adının (Nakit Akış Tablosu) neredeyse aynısı; modül değil rapor adı. "nakit" Sage Intacct'ın çekirdeğinde (M, Intacct satırı: "hesap borç, alacak, nakit...") ve NetSuite'in çekirdek finansında (M, NetSuite satırı: "GL, AP, AR, nakit..."). "Cash Management" bu yazımla kaynakta yok. "Finans" adını bilerek seçmedim: Finans sekmesiyle aynı kelime (Bölüm 4). |
| line_erp_intake | core | Veri Girişi / Data Entry | **Seçenek A (tablo): Satın Alma / Purchasing**<br>**Seçenek B (adımlara uyan): Veri Girişi / Data Capture** | Elle Giriş, Tablo İçe Aktarma, Belge Okuma · Manual Entry, Spreadsheet Import, Document Reading | A: tabloya bağlı (SENTEZ: "Satın Alma | sipariş, tedarikçi | `line_erp_intake` yeniden adlanır"). B: tablodan sapar; TR adı değişmez, EN "Data Entry" yerine "Data Capture". | A: "Satın Alma" 10 katalogdan 8'inde var (M §2: Odoo, SAP B1, NAV, BC, Acumatica, Intacct, S/4HANA, NetSuite); SAP B1 "Purchasing A/P" (M, SAP B1 satırı), Netsis Wings "satın alma" (M, Logo/Netsis satırı). Bedeli: K1/K2/K3 adımları sipariş ya da tedarikçi değil veri girişi (K1: "Her kalem klavyeden girilir", K3: "Fatura ve irsaliye taranır"), yani oyuncu "Satın Alma" altında "Elle Giriş" görür. Sektör profilleri de "Satın Alma" ister (SENTEZ §3.2: İmalat, Dağıtım, Perakende, İnşaat, Sağlık); adımlar değişmezse müşterinin istediği "Satın Alma"yı oyuncu veri girişiyle karşılar. B: adıyla adımları uyuşuyor. "Data Capture" kaynakta yok; "Veri Girişi" de bir modül adı olarak kaynakta yok ve Erdem'in "güzel olsun" ölçütünde en zayıf satır. |
| line_erp_stock | core | Stok / Stock | **Stok / Inventory** | Stok Sayacı, Depo ve Raf, El Terminali · Stock Count, Warehouse and Shelf, Handheld Scanner | TR bağlı (tabloda "Stok"). EN tablonun dışında (tablo yalnız TR); "Stock" yerine "Inventory". | EN "Inventory": SAP B1 listesinde (M, SAP B1 satırları), Odoo kategorisi "Inventory & Manufacturing" (M, Odoo 17/18 satırı); "Stock" bir modül adı olarak kaynakta yok. Bedeli: EN adımlar ("Stock Count") ve olay metni ("stock take") "stock" kelimesini taşımaya devam eder. Yedek: EN "Stock" değişmesin. |
| line_erp_invoicing | core | Fatura / Invoicing | **Fatura / Invoicing** (değişmez) | Fatura Kesme, Toplu Fatura, Tahsilat Döngüsü · Issuing Invoices, Batch Invoicing, Collection Cycle | Bağlı (UM kuralı invoicing -> Fatura). Tablonun tam adı "Fatura ve e-Belge"; e-Fatura, e-Arşiv, e-İrsaliye kademeleri dönemle gelecek (parkta), şimdiki üç adımda e-Belge yok, bu yüzden yalnız "Fatura". | "Invoicing" Odoo'nun uygulama adı (M, özet madde 3: "Odoo (Invoicing uygulaması)"); Türk satıcılar ayrı "e-Dönüşüm" ailesi yapıyor (M: ETA 12, Mikro 7 öğe). Bugünkü ad zaten uygun. |
| line_shared_integrations | integrations (B2C'de growth) | Entegrasyonlar / Integrations | **Entegrasyonlar / Integrations** (değişmez) | Tekil Bağlantı, Çoklu Entegrasyon, Açık API ve Webhook · Single Connection, Multiple Integrations, Open API and Webhooks | Bağlı (SENTEZ platform hattı listesi). Hat adında değişiklik yok. | Bir ERP'de "Integrations" modül adı olarak kaynakta yok (A1: "API/entegrasyon pazarları için ERP'ye özgü kaynak bulunamadı"); entegrasyon sektör şartı olarak var (A3 §5). Çoğul ad "Entegrasyonlar düzeltmesi" ve "Integrations is ..." (fiil uyumu) üretir; tablo böyle yazdığı için korundu. |
| line_shared_security | trust | Güvenlik & Yetki / Security and Access | **Güvenlik ve Yetki / Security and Access** | Hesap & Oturum, Roller ve İzinler, Denetim İzi & Şifreleme · Accounts and Sessions, Roles and Permissions, Audit Trail and Encryption | Bağlı (tabloda "Güvenlik ve Yetki"); değişiklik yalnız "&" -> "ve". EN zaten "and". | Adın kendisi gerçek üründe kaynakta yok. İçeriği kaynakta var: rol bazlı erişim ve denetim izi (A3 sağlık bölümü, "HIPAA uyumlu finans (rol bazlı erişim, denetim izi)"); NAV 2013 R2'nin "BT Yönetimi" iş alanı en yakın (M, NAV satırı). |
| line_shared_durability | trust | Dayanıklılık / Durability | **Dayanıklılık / Durability** (değişmez) | Otomatik Kayıt, Sürüm Geçmişi, Çevrimdışı Çalışma · Autosave, Version History, Offline Work | Bağlı (tablo aynen). | Kaynakta yok. Tablo böyle yazdığı için korundu; "real ERP'de görülür mü" ölçütünde bu setin en zayıfı (Bölüm 4). |
| line_shared_mobile | onboarding | Mobil & Erişim / Mobile and Access | **Mobil ve Erişim / Mobile and Access** | Duyarlı Arayüz, Mobil Uygulama, Çevrimdışı Mobil · Responsive Interface, Mobile App, Offline Mobile | Bağlı (tabloda "Mobil ve Erişim"); değişiklik yalnız "&" -> "ve". | Kaynakta yok; A1 "mobil ERP kilometre taşları" için BOŞLUK diyor. |
| line_hidden_self_serve | onboarding | Kendi Kendine Servis / Self Service | **Kendi Kendine Servis / Self Service** (değişmez) | Sık Sorulanlar, Bilgi Bankası, Yerinde Çözüm · Common Questions, Knowledge Base, Resolved in Place | Tabloda yok (gizli hat). Değişiklik önerilmiyor. | Kaynakta yok. "Yardım Merkezi / Help Center" doğal aday ama aynı iki sözcük Ar-Ge düğümünün adı (`PROD_RND_NODE_SELF_SERVICE`): iki ayrı şey aynı adı taşır. Düğüm de yeniden adlandırılırsa tekrar bakılabilir. |

Özet farklar: 4 ad değişir (ledger, cashflow, intake A ya da B, stock yalnız EN), 2 "&" düzeltmesi (security, mobile). Fatura, Entegrasyonlar, Dayanıklılık ve Kendi Kendine Servis değişmez.

## 3. Ad değişince taranacak metinler

Taranan: `localization/strings.csv` (3191 anahtar), `data/events/cards/**`, `data/product/**`, `scripts/**` (yalnız ad aramak için). CSV değerlerinde aranan: bugünkü TR/EN ad, adım adları, alan adları. Aşağıdaki liste eksiksiz değil ama bulduklarım hepsi bu.

### 3.1 Adı DÜZ yazanlar (ad değişince değer elle eşitlenmeli)

| Anahtar | TR değer | Neden riskli / işlem |
|---|---|---|
| SALES_REASON_STABILITY | ürün yeterince güvenilir değil (Güven & Ölçek) | Alanın tam adının kopyası, "&" içeriyor. Alan adı "Güven ve Ölçek" olunca değer de değişmeli (EN "(Trust & Scale)" -> "(Trust and Scale)"). |
| PROD_RND_NODE_SECURITY_CERT_UNLOCK | Güvenlik & Yetki hattının son kademesi. | Hat adı düz yazılı; "Güvenlik ve Yetki hattının ..." olmalı. EN zaten "Security and Access". |
| PROD_RND_NODE_DESIGN_SYSTEM_UNLOCK | Mobil & Erişim hattının son kademesi ve ürünün kendi tasarım kademelerinden biri. ... | Aynı: "Mobil ve Erişim". EN zaten "Mobile and Access". |
| PROD_RND_NODE_DATA_MODEL_UNLOCK | Entegrasyonlar hattının son kademesi. | Ad değişmiyor; kontrol. |
| PROD_RND_NODE_SCALABLE_BACKEND_UNLOCK | Dayanıklılık hattının son kademesi · ERP'de tahsilat, Video Klip'te ortak kurgu. | Ad değişmiyor; kontrol. "tahsilat" K3 adımına (Tahsilat Döngüsü) değil Dayanıklılık'a bağlı bir ifade. |
| PROD_RND_NODE_TEST_AUTOMATION_UNLOCK | Kendi Kendine Servis adında yeni bir özellik hattı. ... | Ad değişmiyor (gizli hat önerilmiyor); kontrol. Ar-Ge düğümü "Yardım Merkezi" ile aynı konuyu anlatıyor. |
| PROD_RND_NODE_ANALYTICS_ENGINE_UNLOCK | ERP'nin nakit öngörüsü kademesi. | Adım adı (K3), hat adı değil; adım adlarına dokunulmuyor. |
| SALES_B2C_PLAN_HINT | Gelir, Ürün'de Gelir alanındaki Ücretli plan kartıyla başlar. | B2C alan adı "Gelir" değişmiyor; kontrol. |

### 3.2 Hat adını şablona koyup TR ek ve cümle uyumu taşıyanlar (her yeni adla okunup doğrulanmalı)

`{capability}` ve `{line}` değerleri `SprintCatalog.cap_name` ile hat adını getirir. Önerilen adlar: Muhasebe, Nakit Yönetimi, Stok, Fatura, Satın Alma / Veri Girişi, Entegrasyonlar, Güvenlik ve Yetki, Dayanıklılık, Mobil ve Erişim, Kendi Kendine Servis. Ek alan kalıplar isim tamlaması (düzeltmesi, tarafında, hattındaki, kodunu); sondaki ünlüye göre ek ünlüsünü okuyarak doğrula.

| Anahtar | TR değer | Neden riskli |
|---|---|---|
| PRODUCT_FIX_CARD | {capability} düzeltmesi | Düzeltme kartının adı; sprint ekranında ve çiplerde okunur. "Nakit Yönetimi düzeltmesi", "Güvenlik ve Yetki düzeltmesi" tamlama olarak okunur; "Entegrasyonlar düzeltmesi" bugün de çoğul. |
| BUILD_SUPPORT_TIP | En çok açık hata: {capability} | İpucu; ek yok, güvenli. |
| SUPPORT_RPT_NEW_PRIORITY | {line} tarafında açık hata {n} oldu; artık Öncelikli. | "-nda" eki; ünlü uyumuna bakar (Muhasebe tarafında, Stok tarafında, Mobil ve Erişim tarafında doğru). EN "{line} is up to {n} open bugs" çoğul ad (Integrations) fiil uyumsuzluğu verir, bugün de öyle. |
| SUPPORT_RPT_NEW_CLEARED | {line} tarafında açık hata kalmadı. | Aynı. |
| SUPPORT_RPT_NEW_WORST | En çok sorun çıkan yer artık {line}. | Ek yok. EN "{line} is now where most of the trouble is." |
| SUPPORT_RPT_SHIPPED | {line} düzeltmesi yayında: {from} -> {to} açık hata. | Tamlama. |
| SUPPORT_RPT_BTN_FIX | {line} düzeltmesini aç | Tamlama + belirtme eki; uzun ad butonu taşırabilir ("Güvenlik ve Yetki düzeltmesini aç"). |
| EFFECT_SHIP_BUGS (+ _ONE) | {line}: çıkışta {n} açık hata | Olay çipi; ek yok, genişlik. |
| EFFECT_NEW_BUGS (+ _ONE) | {line}: {n} yeni açık hata | Aynı. |
| EFFECT_LINE_HARDEN | {line}: {weeks} hafta yeni hata çıkmaz | Aynı. |
| RND_NOTE_DEMAND_B2B_0..3 (ve _B2C_0..3) | ... {line}. ... / ... başlık açıldı: {line}. ... | Ar-Ge postası; ad iki nokta ya da nokta ile bitiyor, ek yok. B2B_3 "listenin başında tek başlık var: {line}". |
| RND_HIDDEN_LINE_OPENED | Yeni özellik hattı açıldı: {line} | Ek yok. |
| PRODUCT_TIP_CARD_MODULE | {card} ({module}) | {module} alanın TAM adıdır (`area_name`); "Güven ve Ölçek", "İlk Kullanım ve Erişim" parantezde uzun kalır. |

Kart gövdelerinde hat adı (`{seam:urun.decision_line_name}`, düzeltme kâğıtları) ek alır; üç kart:

| Kart | TR gövde parçası | Neden riskli |
|---|---|---|
| data/events/cards/product/sprint_dev_root_cause.json | {…} hatalarının {n} tanesi aynı yerden çıkıyor | "-ının" eki; ünlü uyumu kontrolü. EN "{n} of the {line} bugs". |
| data/events/cards/product/sprint_solo_rushed_code.json | {…} kodunu ilk sürüm için aceleyle yazmıştın | "-u" belirtme eki. EN "the {line} code". |
| data/events/cards/product/sprint_untested_old_screens.json | Bu kart {…} hattındaki eski ekranlara da dokunuyor | "hattındaki" eklenen yapı; "Satın Alma hattındaki", "Muhasebe hattındaki" doğal. EN "the old {line} screens". |

### 3.3 Adın sözlüğüyle yaşayan, ama adı yazmayan metinler (anlam uyumu)

| Anahtar | TR değer | Neden riskli |
|---|---|---|
| PROD_TYPE_ERP_DESC | Ön muhasebe · stok · fatura tek defterde. | Ürün seçim ekranında ERP'nin üç hattını sayıyor (EN: Bookkeeping · stock · invoicing in one ledger). Stok EN'de "Inventory" olursa EN "stock" ile uyumsuz; "tek defterde" / "in one ledger" mecaz, ama Erdem "Defter" kelimesini modül adı olarak istemiyor: mecaz kalacak mı sorusu. |
| PROD_TYPE_ERP_PITCH | Kasadan stoka işletmenin defterini tutan sistem. | Aynı mecaz; "stoka" / "stock" kelimesi. |
| PROD_TYPE_ERP_BET | Defter tutan herkes aynı üç şeyi arıyor. ... | "üç şey" = ön muhasebe, stok, fatura. ERP'nin beş hattı var, "üç şey" ön muhasebe, stok, fatura; bugün de böyle, ad değişince değişen bir şey yok. |
| data/events/cards/customer/incident_month_close.json | 3 TR/EN varyant: "Fatura kesemiyoruz ...", "Defter bankayla tutmuyor ...", "Kasa bakiyesi yanlış çıkıyor ..." | Varyant sırası `sprint.json` `incident.month_close.lines` (invoicing, ledger, cashflow). Müşteri belirtisini yazıyor, hat adını değil; "Defter bankayla" kelime olarak kalabilir ama "Muhasebe" adını duyan oyuncu aynı hattı tanır. |
| data/events/cards/product/incident_regression.json | 18 varyantın 8'i ERP: "faturalar iki kez kesiliyor", "stok sayımında", "dönem bakiyeleri bankayla tutmuyor", "kasa bakiyesi", "banka hareketleri deftere iki kez düşüyor" (EN: invoices, stock take, period balances, cash balance, ledger) | Aynı: belirti, ad değil. EN "stock take" Inventory adıyla yan yana durur. |
| PROD_STEP_SHARED_*_ERP_DESC ve PROD_STEP_HIDDEN_SELF_SERVE_K*_ERP_DESC | "Fatura ve stok ekranlarının yanında ..." (K1), "muhasebeci", "depocu" vb. | Adım açıklamaları ERP'nin sözcüklerini kullanıyor (fatura, stok, muhasebe, banka); ad değişince değişmez, yalnız EN "invoice and stock" ve "Inventory" ayrılığı. |
| PROD_STEP_ERP_*_DESC | Her hattın üç açıklaması | Hat adı geçmiyor; Muhasebe için "Gelir ve gider kaydedilir ..." doğal. |

Defter kelimesinin başka (alakasız) kullanımları, ad değişince dokunulmaz: END_ACQ_BOOK(_ONE), END_BS_BALANCED(_ONE), END_BS_STREAK, END_BS_AUDIENCE(_ONE), END_RF_REVENUE_SOME, VC_Q_REPEATABLE (+ _MONO), PERSONAL_MS_FOUNDING_NOTE, MAIL_RPT_BOOKS, PIYASA_ABOUT_FACEWALL / VENDITOR / DATENWALD / ELEPHANTA. Hepsi şirketin ya da müşteri tabanının "defteri"; ERP hattı ile ilgisi yok. Yalnız Erdem sözcüğü her yerden silmek isterse sorulur.

### 3.4 Oyuncu metni olmayan ama ad taşıyan yerler (commit'te elden geçirilmeli, kapıları etkilemez)

- `data/product/lines/erp.json`: `_telegraph` içinde "Güvenlik & Yetki" (satır `_telegraph`); `data/product/lines/shared.json`: `_nodes` içinde "Entegrasyonlar", "Dayanıklılık", "Güvenlik", "Mobil" (tarihçeli/not niteliğinde `_` alanları; CLAUDE.md §8: JSON `_` notları yorum kuralına tabidir).
- `scripts/debug/endgame_smoke.gd`: yorumlar (`Güvenlik & Yetki`, `Mobil & Erişim`, `Veri Girişi`, `Güven & Ölçek`, `İlk kullanım`, `Entegrasyonlar`) ve iki hata iletisi (satır 15259, 16123). Hiçbir vaka CSV değerini karşılaştırmıyor; `PRODUCT_AREA_ONBOARDING_SHORT` anahtarı kullanılıyor (satır 15168), değer değil. Satır 14204-14210 "Defter" bir test ürün adıdır, hatla ilgisi yok.
- `scripts/autoload/save_manager.gd:973`: yorumda "Güven & Ölçek".
- `docs/design/localization_glossary.md` satır 79 ("Onboarding & Access"), 66 ve 82'deki örnekler ("Fatura düzeltmesi", "Çekirdek Zayıf"): "Onboarding and Access" ve yeni hat adlarıyla eşitlenmeli.
- Kapılar: `loc_csv_integrity`, `loc_residue`, glif denetimi. Yeni değerlerde tire (— –) ve "&" yok; "İE", "EG" harfleri koyu yüzlerde (Archivo) mevcut (Latin ve Türkçe harfler).

## 4. Bilinen zayıflıklar ve sahibe sorular

Zayıflıklar:

1. Ledger/cashflow bölünmesi tabloda yok: "Muhasebe" ve "Nakit Yönetimi" benim bölmem; C'nin birleşmesi gelince ikisi tek "Finans ve Muhasebe" olur ve iki ad boşa gider. "Finans" adını cashflow'a vermedim çünkü Finans sekmesiyle aynı kelime; aynı risk tablonun kendi "Finans ve Muhasebe" adında da var (modül adı mı, şirketin Finans penceresi mi?). Birleşme günü bunu da görmek lazım.
2. İngilizce gerçek-ürün kanıtı zayıf: "Accounting", "Cash Management", "Data Capture", "Security and Access", "Durability", "Mobile and Access", "Self Service" kaynakta yok; yalnız "Inventory", "Invoicing", "Purchasing" kaynakta var. Türkçe tarafta "muhasebe", "nakit", "satın alma", "stok", "fatura" kaynakta var.
3. "Dayanıklılık" (otomatik kayıt, sürüm geçmişi, çevrimdışı) ve "Mobil ve Erişim" gerçek bir ERP modül adı gibi okunmuyor; tablo böyle yazdığı için korundu. İstenirse adaylar: "Veri Güvencesi" ya da "Süreklilik" (ikisi de kaynakta yok).
4. Ekrandaki "MODÜLLER" başlığı altında satır olan alanlar (Çekirdek, İlk kullanım, Entegrasyonlar, Güven) gerçek modül değil; gerçek modül adları (Muhasebe, Stok, Fatura) satırın içinde değil, düzeltme kartında, çipte ve postada okunuyor. Alan adı anahtarları ürünler arası ortak (B2C, ERP, Not Aracı, Video Klip), CSV değeri ürüne göre değişemez; ERP'ye özel alan adı yalnız kodla (ürün başına anahtar) olur.
5. Mono işaretleri ("İE", "EG") benim seçimim; anlam taraması yalnız kendi bilgimle yapıldı, ayrı bir sözlükle doğrulanmadı.
6. Üç paylaşılan hattın adımlarında da "&" var (TR: "Hesap & Oturum", "Denetim İzi & Şifreleme", "Açık API & Webhook"; EN karşılıkları "and"). UM yalnız hat adlarını kapsıyor; adım adları "&" kuralına aykırı kalıyor, aynı turda "ve" yapmak istenirse üç CSV değeridir (`PROD_STEP_SHARED_SECURITY_K1`, `_K3`, `PROD_STEP_SHARED_INTEGRATIONS_K3`).

Sahibe sorulacaklar (en çok üç):

1. Veri girişi hattı için hangisi: A) "Satın Alma / Purchasing" (tablo; ama hattın üç kademesi hâlâ veri girişi: Elle Giriş, Tablo İçe Aktarma, Belge Okuma) mı, B) "Veri Girişi / Data Capture" (adımlara uyar, ama "güzel modül adı" ölçütünde zayıf) mı? A seçilirse kademelerin sipariş ve tedarikçi adlarına çevrilmesi ayrı bir iş olarak açılır (UM adım adlarına dokunmuyor).
2. Defter ve Nakit Akışı şimdilik "Muhasebe" ve "Nakit Yönetimi" diye ayrı mı yazılsın, yoksa birleşme gelene kadar bugünkü adlarla (Defter, Nakit Akışı) mı kalsın? Erdem "Defter" modül adı olmasın demişti; ilki bu yüzden öneri.
3. İngilizce Stok adı "Inventory" (gerçek ürünlerde görülen) mı olsun, "Stock" (bugünkü; adımlar ve belirti metinleri "stock" der) mı kalsın?
