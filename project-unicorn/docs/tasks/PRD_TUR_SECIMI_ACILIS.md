# PRD: Tür seçim ekranı ve açılış arka planı

Sahip: ARAYUZ. Girdi: Erdem'in tur 4 yorumu (`tur4_ekranlar_2026-11-13/ERDEM_YORUMU_TUR4.md` §2, §3, §4 ARAYUZ), tur 4
teslimi (`tur4_ekranlar_2026-11-13/secim_ekrani/TESLIM.md`, `DIL_ONERISI.md`, `ELESTIRMEN.md`), URUN'un ERP notu
(2026-11-13). Kareler `tur4_ekranlar_2026-11-13/secim_ekrani/kareler/R2_*` (bu PRD'nin kareleri). Durum: taslak; §9'daki
sorular Erdem'de, oyuncu metni TR ve EN onay bekliyor (§10).

## 1. Oyuncu ne yapar

Demet koşunun ilk kararını verir: Pazaryeri mi, ERP mi. Koşuda bir kez, ilk dakikada; geri alınmaz. Sonucu her yerde:
Ürün'ün modülleri, satış ya da pazaryeri sayfaları, üst barda Frank'in çeki. Ekran her türün ne olduğunu gerçek tanımıyla,
nasıl para kazandığını, kime sattığını ve yolun açacağı masaları gösterir. Oyuncu seçmeden "bu yol beni şunlarla
uğraştıracak" der.

## 2. Kapsam

İçinde:
- Tür seçim ekranının B yönüyle yeniden yazımı (`scripts/tabs/product/type_picker.gd`) ve Ürün penceresinde tam gövde
  (`scripts/tabs/product_tab.gd`).
- Tür glifleri: Pazaryeri, ERP, iki pazar (`assets/icons/type/`, `docs/mockups/menajer/system/icons/glyphs.py` ile).
- Türün metin ve masa verisi (§4).
- Açılışın arka plan sahnesi: ofissiz (§6).

Dışında:
- Not & Bilgi Aracı ve Video Klip Aracı'nın oyundan silinmesi (tür, hat, aday, kart). Erdem'in kararı; iş PAZARYERI'nin
  paket planında (`pazaryeri/TEKNIK_KESIF.md`, "sil" paketi).
- Pazaryeri türünün kataloğa girmesi (PAZARYERI paket 1). Bu ekran katalogdan okur; tür girmeden kartı yoktur.
- ERP'nin modül şeması ve yıllık sözleşmenin ekonomisi (URUN, `erp_tasarim_2026-11-12/MODUL_SEMASI.md`).
- Üst barın Frank'in çeki listesi: değişmez. Yalnız bu ekranda görünmez.

## 3. Ekran

Kareler: `R2_B_pazaryeri.png`, `R2_B_erp.png` (TR), `R2_B_pazaryeri_en.png`, `R2_B_erp_en.png` (EN).
İki türde dosyanın alt yarısı boş kalır (Frank'in çeki kalktı); alt satır pencerenin dibinde sabit durur, dosya
dikey ortalanmaz.

**Yerleşim.** Ürün penceresinin gövdesi iki sütundur: solda liste (540 px), sağda seçilenin dosyası (kalan genişlik).
Bugünkü 640 piksellik ortalanmış sütun (`D_W_PICKER`, `CenterContainer`) kalkar.

**Liste.**
- Başlık "Yolunu seç", `TitleH2`.
- Pazar başına bir grup: pazar glifi (18 px) ve grup etiketi `Eyebrow` ("Kitleye satarsın", "Şirketlere satarsın").
- Tür satırı `PickCard`: glif (40 px), ad `OptionLabel`, tek satır `BodyMuted` ("Çok mağazalı e-ticaret sitesi",
  "Kurumsal kaynak planlaması").
- Seçili satır `PickCardSelected` ve `D_mark`. Kilitli ve henüz gelmeyen tür listede yoktur (soru 2).

**Dosya** (`SprintColumn`):
1. Üst: glif (96 px); pazarın grup etiketi `Eyebrow`; ad `DisplayName`; gerçek tanım `LeadText`.
2. Ayraç.
3. İki olgu, glif ve kalın değer (`ValueTextStrong`); olgunun adı (Gelir, Müşterin) ipucunda.
4. "BU YOLDA YÖNETECEKLERİN" (`KeySmall`) ve masalar. Masa çerçeveli bir kutudur, değer boyunda; ipucu masanın oyuncuya ne
   yaptırdığını tek satırla söyler.
5. Artı ve eksi: kavramın adı (artı ve eksi glifiyle, `ValueTextStrong`); kavramın tanımı ipucunda (soru 1).
6. Alt satır: kilit glifi ve "Sonradan değişmez" (`NoteMuted`), ürün adı alanı, birincil düğme "Onayla ve başlat"
   (`PrimaryButtonDark`). Düğme ad ve tür seçilmeden kapalıdır.

**Ölçek.** Erken Erişim türleri gelince liste aşağı uzar, dosya aynı kalır (tur 4 karesi `B3`, Erdem beğendi).

## 4. Veri ve anahtarlar

Tür kaydı (`ProductCatalog`) türün masalarını ve iki kavramını kimlikle taşır. Metin CSV'dedir (iki dilde aynı anahtar).
- Türün metni: `PROD_TYPE_<ID>_NAME` (var), `_SHORT`, `_DEF`, `_EARN`, `_WHO` (yeni).
- Masa: kayıtta `desks: [<masa kimliği>…]`; metni `PROD_DESK_<ID>` ve `PROD_DESK_<ID>_TIP`. İki türün ortak masası tek
  anahtardır (ör. ürün geliştirme ve modüller ayrı adlarla kalırsa ayrı anahtar).
- Kavram: kayıtta `plus`, `minus`; metni `PROD_CONCEPT_<ID>` ve `PROD_CONCEPT_<ID>_TIP`.
- Ekranın kendi anahtarları: `PROD_PATH_TITLE` (var), `PROD_PATH_B2C`, `PROD_PATH_B2B` (değeri "Kitleye satarsın",
  "Şirketlere satarsın" olur), `PROD_PATH_FINAL` (yeni), `PROD_DESKS_LABEL` (yeni), `PROD_NAME_LABEL`,
  `PROD_CONFIRM_START` (var).
- Silinenler (yerini alan aynı commit'te, CLAUDE.md §8): `PROD_PATH_SUB`, `PROD_PATH_B2C_DESC`, `PROD_PATH_B2B_DESC`,
  ERP'nin `_CATEGORY`, `_DESC`, `_TRADEOFF`, `_BET`, `_PITCH` anahtarları; okuyucusu kalmayan
  `ProductCatalog.type_category`, `type_desc`, `type_tradeoff`; `UiTokens.D_W_PICKER`. Not ve video türünün anahtarları
  silme paketiyle gider.
- ERP'nin müşteri satırı katalogdaki sektörlerle aynı olmalı. Bugün kayıt `manufacturing`, `retail`, `logistics` taşıyor
  (`product_catalog.gd:29`); satırdaki inşaat ve toptan ticaret URUN'un sektör süzgecinden (`MODUL_SEMASI.md` §6). Satır
  kaydın sektörlerinden kurulmaz, ama ikisi aynı commit dizisinde eşitlenir (sahibi URUN).
- Masa kutusu yeni bir tema varyasyonudur (`build_theme.gd`, `THEME_STAMP` artar, iki tema yeniden üretilir). `PickCard`
  kullanılmaz: `type_picker_one_screen` smoke'u kartları bu varyasyonla sayar.

## 5. Metinler (taslak, TR ve EN onay bekliyor)

| Anahtar | TR | EN |
|---|---|---|
| Pazaryeri `_SHORT` | Çok mağazalı e-ticaret sitesi | A multi-store e-commerce site |
| Pazaryeri `_DEF` | Birçok mağazanın ürünlerini tek bir sitede sattığı e-ticaret türü. | A type of e-commerce site where many third-party stores sell their products. |
| Pazaryeri `_EARN` | Mağazadan komisyon, kullanıcıdan üyelik | Commission from stores, membership from users |
| Pazaryeri `_WHO` | Mağazalar ve kullanıcılar | Stores and users |
| Pazaryeri masaları | Ürün geliştirme · Kategori yönetimi · Memnuniyet politikaları · Premium üyelik · Kampanyalar | Product development · Category management · Satisfaction policies · Premium membership · Campaigns |
| Pazaryeri artı / eksi | Ağ etkisi / Tavuk ve yumurta sorunu | Network effect / Chicken-and-egg problem |
| ERP `_SHORT` | Kurumsal kaynak planlaması | Enterprise resource planning |
| ERP `_DEF` | İşletmenin muhasebe, stok, satın alma ve satış süreçlerini tek bir yazılımda birleştiren yönetim sistemi. | Management software that brings a company's accounting, stock, purchasing and sales into one integrated system. |
| ERP `_EARN` | Yıllık sözleşme, aylık ödeme | Yearly contract, paid monthly |
| ERP `_WHO` | Üretim, lojistik ve perakende şirketleri (bugünkü katalog sektörleri; URUN sektörleri genişletince satır da genişler) | Manufacturing, logistics and retail companies |
| ERP masaları | Modüller · Satış: adaylar ve görüşmeler · Müşteri istekleri ve sözler · Yenileme ve destek | Modules · Sales: leads and meetings · Customer requests and promises · Renewal and support |
| ERP artı / eksi | Geçiş maliyeti yüksek / Uzun satış döngüsü | High switching cost / Long sales cycle |
| `PROD_PATH_TITLE` | Yolunu seç (bugünkü gibi) | Choose your path (bugün "Choose your road") |
| `PROD_PATH_FINAL` | Sonradan değişmez | You can't change this later |

İpuçları (masaların ve kavramların) prototipte; PRD onaylanınca CSV'ye aynı metinle girer. Tanımların kaynağı: Vikipedi,
"Kurumsal kaynak planlaması" (TR), "Online marketplace" ve "Enterprise resource planning" (EN). ERP'nin sözleşmesi ve
sektörleri URUN'un önerisidir: kodda sözleşme bugün 52 hafta (`data/product/sprint.json` `request.contract_weeks`), ödeme
ve MRR aylık. "Yenileme ve destek" masasının ipucu ("Memnun olmayan hesap yenilemede gider") URUN'un PRD'sindeki yenileme
kuralına bağlıdır, o kural onay bekliyor.

## 6. Açılış arka planı

Erdem: hiçbir ofis görünmez; şehir olabilir ya da başka bir sahne. Adım 1'de panel ekranın çoğunu örter; arka plandan üst
bar ile sekmeler arasındaki ~270 piksellik şerit görünür, sahne orada okunmalı.

| Kare | Sahne | Hangi hikâye başlıyor | Bedel |
|---|---|---|---|
| `R2_D1_sehir_gece` | Şehir, 21:30, kimse yok (menünün kadrajı) | "Bu şehirde bir şirket kuracaksın." Menüden yeni oyuna geçiş kesintisiz. | Yok: menünün sahnesi; 21:30 için bir plaka (menünün 19:30 plakası da kullanılabilir) |
| `R2_D6_sahil_vapur` | Şehrin sahili, 19:00, iskelede vapur ve tekneler | "Şehir akşama dönüyor." Menüden ayrışan tek aday; şehri yaşayan bir yer gibi gösterir. | Küçük: kamera, menünün gizlediği tekneler görünür, bir plaka; vapurun yürümesi istenirse ofis şehrinin `steer_ferry`'si bağlanır |
| `R2_D7_kule` | Görüşmelerin kulesi, gece, tacı yanık | Hedefi göstermek istedi: yatırımcıların kulesi. Okunmuyor: taç sıradan bir çatı gibi duruyor. | Önerilmez |
| `R2_D8_safak` | Menünün kadrajı, 06:30 | Ocakta 06:30 hâlâ karanlık; gece şehirden ayrışmıyor. | Önerilmez |

**Öneri: D1** (Erdem: "şehir görünümü daha iyi"). Ayrışan seçenek D6. Erdem'in "daha farklı bir sahne" yolu (ör. çizilmiş
bir illüstrasyon ya da yeni bir 3B set) bu turda kurulmadı; bedeli büyük (sanat üretimi ve plaka), istenirse ayrı iş.

**Kod.** `onboarding_flow.gd` sahneyi `STAGE_OFFICE` ve `MENU_STAGE_MINUTE` ile kurar; değeri şehir ve seçilen saat olur,
kurucu figürü gönderilmez. `menu_backdrop.gd`'nin şehir kadrajı seçilen adayın kamerasını alır (sabitler `[WORKING]`).
Ofis sahnesi ve figür yolu (`set_figure`, `_stand_figure`, `MENU_STAGE_ZOOM`, `MENU_STAGE_POS`, `MENU_STAGE_FEET`, ofis
kadraj dalı) okuyucusu kalmadığı için aynı commit'te silinir; ev plakası (`assets/art/menu/backdrop_home_1930.png`)
de. Yeni plaka `--menu-shot=bake_plate:city:<HHMM>` ile fırınlanır; düşük ön ayarda yalnız plaka durur.

## 7. İniş sırası (kaba, 3 ile 4 commit, yaklaşık bir oturum günü)

1. Tür glifleri (dört glif, import ölçeği).
2. Tür seçim ekranı: `type_picker.gd`, `product_tab.gd`, katalog kaydının alanları, CSV anahtarları, tema varyasyonu,
   smoke'ların güncellenmesi. PAZARYERI paket 1'den sonra (pazaryeri türü kataloğa girmiş olmalı); not ve video silinmeden
   de iner (liste katalogdan okur).
3. Açılış arka planı ve plaka.

## 8. Kabul ve test

- Görsel kabul (`--screen 2`, 1920×1080, TR ve EN): `--product-shot=live:pick`, `live:pick_named` (seçilen tür artık
  ERP ya da Pazaryeri; bugün `main.gd` Not'u seçiyor), `live:pick_relang`; `--onboard-shot=1`, `2`, `3`; menüden yeni oyuna
  geçiş. Kontrol: metin taşmıyor, ipucu açılıyor, logda hata yok.
- Smoke: `loc_product_derived_keys` (bugün türün `_CATEGORY`, `_DESC`, `_TRADEOFF`, `_BET`, `_PITCH` anahtarlarını arıyor;
  yeni küme `_NAME`, `_SHORT`, `_DEF`, `_EARN`, `_WHO`, masalar ve kavramlarla aynı commit'te değişir),
  `type_picker_one_screen` (kart sayısı oynanabilir tür sayısı; masa kutusu sayılmaz), `type_screen_matches_line_content`
  (yol başına üç kilitli kart kuralını taşıyor; soru 2'nin cevabına göre değişir), `loc_csv_integrity`, `all_scripts_load`.
  Yeni smoke yok (arayüz görsel kabulle doğrulanır, CLAUDE.md §10).
- Kalibrasyon: playtest'te.

## 9. Açık sorular (Erdem'e)

1. **Artı ve eksi kalsın mı?** Demet Pazaryeri'ne tıklar; dosyada "+ Ağ etkisi" ve "− Tavuk ve yumurta sorunu" yazar, üzerine
   gelince tanımı açılır. ERP'de "+ Geçiş maliyeti yüksek", "− Uzun satış döngüsü". Uydurma cümle değil, adı olan gerçek
   kavramlar; ikisi de oyunda çalışan bir mekaniğe denk (iki tarafın birbirini büyütmesi; yıllık sözleşme ve 2 ile 12 haftalık
   anlaşma). Önerim: kalsın. Kalmazsa dosya olgular ve masalarla biter.
2. **Kilitli türler.** GDD bugün tür ekranında yol başına üç kilitli kart gösteriyor (`GDDs/GUNCELLEMELER.md`, Ürün GDD
   §12.11, "mühürlü"; smoke da bunu sınıyor). Tur 4'ün dili ve envanter kuralı "seçim ekranında henüz gelmeyen içerik
   gösterilmez" diyor; B'nin karelerinde kilitli tür yok. Demet ya yalnız Pazaryeri ve ERP'yi görür ya da altlarında
   "Kurumsal Arama · Erken Erişim'de" gibi soluk satırlar görür. Önerim: gösterilmesin, GDD maddesi güncellensin.
3. **Açılış sahnesi.** Demet yeni oyuna basar; panelin üstünde menünün gece şehri sürer (D1) ya da şehrin sahili
   görünür, iskelede bir vapur (D6). Önerim D1: geçiş kesintisiz, bedeli yok. D6 şehre hayat katar, bedeli küçük.
4. **Tek ad.** Aynı karar ekranda "Yolunu seç", üst barda ve çekin ilk adımında "Ürün tipini seç". Önerim: tek ad, iki yerde
   de (ör. "Ürününü seç"). Erdem tur 4'te "Yolunu seç"i beğendi; o kalırsa üst bar da "Yolunu seç" olur.

## 10. Onay bekleyenler

- §5'teki bütün metinler ve ipuçları (TR ve EN).
- URUN'un yenileme kuralı (onun PRD'si); "Yenileme ve destek" ipucu ona bağlı.
- GDD maddesi (soru 2'nin cevabıyla).
