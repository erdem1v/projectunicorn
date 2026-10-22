# PRD · Ürün derinliği: Genel Bakış, pazaryeri ve ERP

**Kim çalıştırır:** bir geliştirici ajanı oturumu. Başlatma cümlesi: "project-unicorn/docs/tasks/PRD_URUN_DERINLIK.md dosyasını oku ve uygula."
Faz 1 bağımlılıkları main'e inince başlar (§9.1). Faz 2 ve Faz 3, §12.1'in cevaplarını ve §3.0'ın onaylı tasarım notunu bekler; ajan
kendiliğinden başlamaz.
**Durum:** yardımcı yönetmen taslağı 2026-10-11. Erdem'in aynı günkü dokuz kararı (§0.1) işlendi. Üç tasarım taslağı (pazaryeri, ERP, bilgi
sayfası) iki incelemeden geçti (sahip gözü, yapım maliyeti); her blocker ve major bulgu ya burada çözüldü ya §12.1'e önerisiyle taşındı (§0.2).
Kaynak okumasıdır; oyun, smoke ve probe koşulmadı. Her sayı başlangıç değeridir ve "onay bekliyor" diye iner (§8).
**Ne zaman:** Faz 1, PRD_EKIP_VERIM_DESTEK'in D1, D2, D3 ve S2'si main'e indikten sonra. Faz 2, Faz 1 + EKIP S1, S3, V1 + ana menünün kayıt
işi (AM5) + Rakip Dünyası I2 sıra kararından (§12.1 soru 7) sonra. Faz 3a, O19 ve UD7 main'deyken. Faz 3b, O22'nin evre arayüzü yazılınca.
**Tek cümle:** Ürün penceresine kullanıcıyı, ücretli ve ücretsiz ayrımını, gelir akımlarını ve sunucu kapasitesini okutan bir Genel Bakış gelir;
B2C yalnız iki taraflı bir pazaryeri olur (alıcı ve satıcı için ayrı özellik ağacı, komisyon, Üyelik, Premium satıcı planı, reklam, Kara Cuma);
ERP aynı derinliği modüller, Premium plan, kurulum hizmeti, ücretsiz deneme ve e-Fatura dönemiyle kazanır.
**Çıktı:** main'e 32 commit (UD1 ile UD32; push yok), her biri kendi kapısıyla; `tools/econ_protocol.sh` ölçüm aracı; yeni
`--product-shot=live:` türleri; faz başına önce/sonra ölçüm tablosu; Erdem'e ✅/⚠️/❌ listesi ve 1920/1536 TR/EN ekran görüntüleri.

Kod kanıtı `69f4786`; HEAD sonradan `a4db89a`'ya ilerledi (AM5). Belgedeki satır numaraları `69f4786`'nındır ve şu dosyalarda kayar: AM5'in
dokunduğu `game_state.gd` (`get_date_dict` `a4db89a`'da `:649`), `save_manager.gd`, `main.gd`, `endgame_smoke.gd` (TOO_OLD `a4db89a`'da `:8912` ve
`:14108-14113`), `strings.csv`; kirli `support_system.gd`, `product_state.gd`, `build_bar*.gd`; indekste duran O19 dosyaları `b2b_constants.gd`,
`b2b_sales_system.gd`, `sales_system.gd`, `sales_tab.gd`, `run_probe.gd`. Kayanı işlev adıyla bul. Girdiler repo dışıdır ve yalnız gerekçedir:
`C:/Users/erdem/AppData/Local/Temp/claude/C--Users-erdem-Desktop-project-steam/3ef3b847-b97e-4e0a-b9b4-c8ae6a99e869/scratchpad/urun/`
(D1 pazaryeri, D2 ERP, D3 bilgi sayfası, R1/R2 araştırma, U1/U2/U3 kod haritası). Repo dosyaları bu belgelere atıf yapmaz.

## Erdem için kısa özet
- **Ürün penceresine iki sayfa.** GENEL BAKIŞ: kullanıcılar (ücretli ve ücretsiz ayrı), ay ay gelir raporu, sunucu kapasitesi (ilk kez görünür,
  elle artırılıp azaltılır) ve destek. PAKETLER: hangi özelliğin ücretli pakette durduğunu oyuncu seçer.
- **B2C yalnız pazaryeri.** Not ve video ürünleri silinir. Ağaç iki taraflı: alıcı için 5 hat, satıcı için 5 hat, 4 ortak hat (bugün 9, yeni
  hâli 14). Her hattın ekonomide adı konmuş bir sonucu var ("Toplu yükleme: yeni satıcı ilk ürününü daha çabuk yükler").
- **Para dört kaynaktan.** Komisyon, alıcı Üyeliği, Premium satıcı planı, öne çıkan ürün reklamı. Her akımın kolu gelir raporunda kendi
  satırında. Hedef: tek akım gelirin %65'ini geçmez; yüksek komisyon, abonelik ağırlıklı ve reklam ağırlıklı stratejiler de Seri A'ya varır.
- **Üyelik temel alışverişi kilitlemez.** Filtre, kayıtlı kart, kargo takibi herkese açık. Üyelik ayrıcalık satar: üyeye özel fırsatlar,
  kampanyaya erken erişim, hızlı iade, kargo kuponu.
- **Kargo satıcının işi.** Platform etiketi, takibi ve kargo bağlantısını yazar; kuponda yalnız bedeli öder, kargoyu taşımaz.
- **İlan dönemi.** MVP'den sonra alıcı ve satıcı gelir, ama Ödeme ve Hakediş canlı olana kadar komisyon alınmaz.
- **Kara Cuma ve Yılbaşı.** Sipariş, sunucu yükü ve şikâyet artar; hazırlık kartı üç hafta önce gelir. Mevsim fon ve Seri A kapılarını
  oynatmaz: kapılar mevsimsiz geliri okur, fazlası kasaya girer.
- **ERP derinleşir.** Üç modül (Satın Alma, Bordro ve Personel, Müşteri İlişkileri), Premium plan, kurulum hizmeti, adı görünen firmalarla 2 ya
  da 4 haftalık ücretsiz deneme, e-Fatura dönemi. Gelir kalemleri ancak oyuncu kartını çıkarınca çalışır; o zamana kadar B2B ekonomisi bayt
  bayt aynı kalır.
- **Sıra.** Önce kısa ve salt okunur Genel Bakış, sonra pazaryeri, sonra ERP. Her fazın ölçüm tablosu var; sayılar senin onayını bekler.
- **Eski kayıtlar** pazaryeri commit'inden sonra açılmaz (sürüm 0.1.0, yayınlanmış yapı yok); bugünkü test kayıtların da buna dahil.
- **Senden yedi cevap lazım** (§12.1); her birinde önerim yazılı.

## 0. Kararlar ve bulgu → gereksinim

### 0.1 Sahip kararları (Erdem 2026-10-11)
| # | Karar | Gereksinim |
|---|---|---|
| S1 | B2B yalnız ERP; B2C yalnız pazaryeri (üçüncü taraf satıcılar alıcıya satar, tek mağaza değil); not ve video silinir; parodiler `companies.json`'da | §3; silme §3.10; rakipler §3.9 |
| S2 | Mağaza puanı yok; depo, 3PL, dropshipping yok; kargo açık, eğilim "satıcının işi" | Puan hiçbir yerde yok (yorum ürüne ait, §3.1); kargo §3.7; kupon soru 1 |
| S3 | Mevsim tepeleri sevildi (Kara Cuma, yıl sonu) | §3.7 (Kara Cuma ve Yılbaşı demoda); B2B yıl sonu §4.5 |
| S4 | İki taraflı geliştirme, geniş ağaç, demoda hepsi görülemez | §3.1 iki kimlik ailesi; ağaç ölçümü §11.2 |
| S5 | E-ticaret gelir modeli: komisyon, sipariş, satış hacmi, komisyon ve üyelik geliri, finans raporu gibi, birden çok akım, odak seçimi | §3.5, §3.8; strateji hedefi §3.0, §11.2 |
| S6 | Sprint dışında ürün bilgi sayfası: aktif kullanıcı, ücretsiz/ücretli, kapasite, gelir; politikalar burada ya da sonra | §2 (Faz 1), §3.8, §4.6; politikalar EA (§6) |
| S7 | Ücretsiz ve ücretli kademe; oyuncu özelliği pakete koyar, dönüşüm değişir | §3.6 Paketler (satıcı hat çipi, alıcı ayrıcalığı), §4.3 B2B |
| S8 | ERP'ye ücretsiz kademe ya da deneme; kitle kursun, aday getirsin | §4.4 deneme; freemium EA; soru 4 |
| S9 | ERP de aynı derinlikte | §4 |

### 0.2 İnceleme bulguları → çözüm
SG = sahip gözü incelemesi, YM = yapım maliyeti incelemesi.
| Kod | Bulgu | Çözüm |
|---|---|---|
| SG1 blocker | Alıcı Üyeliği filtre, kayıtlı kart, kargo takibi gibi temel kademeleri ücretliye taşıyordu | Kademe çipi yalnız satıcıda; Üyelik dört ayrıcalık satar, her biri bir hatta bağlı (§3.5.2) |
| SG2 blocker | Gelirin %84'ü komisyon; Öne çıkan kolsuz ve bedelsiz; "önerilen" fiyat cevabı ekrana yazıyor | Strateji hedefli simülasyon (§3.0), reklam yoğunluğu ve bedeli, "önerilen" yok (§3.5) |
| SG3 major | Kartların çoğu yalnız kalite puanı ekliyor | Her kimlik hattına adlı tek kol, kart satırında görünür (§3.4, §4.5) |
| SG4 major | MVP ödeme ve hakediş olmadan komisyon alıyor | İlan dönemi: komisyon Ödeme K1 ve Hakediş K1 ile başlar (§3.3.4; soru 3) |
| SG5 major | Satıcı tarafında oyuncunun doğrudan kolu yok | Satıcı çağrısı (pazarlama itişinin hedefi, §3.8.3); çapa satıcı adayları EA (§6) |
| SG6 major | ERP kararlarının etkisi görünmüyor; deneme adsız sayı | B2B Paketler önizlemesi, adlı deneme firmaları, 2 ya da 4 hafta kolu (§4.3, §4.4; soru 4) |
| SG7 major | Gizli Raporlama hattı derinlik hissi vermez | Demoda gizli hat yok; Raporlama EA'da görünür kilitli; kilitli kademe ağaçta adıyla görünür (§3.1, §6) |
| SG8 major | Faz 1 silinecek ürünlerin üstüne iş kuruyor | Faz 1 salt okunur; Paketler ve dönüşüm modeli Faz 2'de doğar (§2) |
| SG9 major | 24 sahip sorusu | 7 soru; gerisi ekip kararı ve tek onay tablosu (§12) |
| SG10 major | Uydurma ölçüler, beş plan adı, e-Arşiv | Bulma oranı iç değişken; NRR yerine "Mevcut hesaplardan büyüme"; iki ad (Üyelik, Premium); ekran adı Paketler; "E-Invoicing / e-Fatura" (§3.8, §4.6, §7; soru 5) |
| SG11 minor | Beş zaman ölçeği | Tek birim ay; hafta yalnız grafikte (§2.2) |
| SG12 minor | Kademe başına çip ve öğrenilecek kurallar | Hat başına tek çip; kilitli satır görünmez; yeni kademe hattın durumunu alır (§3.6) |
| SG13 minor | Otomatik büyüme kapasite kararını siliyor; Kara Cuma üç kanaldan | Otomatik/Elle seçici (§2.3); Kara Cuma tek kanal (kart), mevsim satırı kart kapanınca (§3.7) |
| SG14 minor | Bedava çıkışlı ya da muğlak seçenekler | `b2c_refunds` (c) kalıcı bedel; sahte ürün Belge doğrulamaya bağlı; `year_end_close` EA ve (b) somut (§5.3, §6) |
| SG15 minor | İki taslak yerleşimde çelişiyor | Kol akım satırında; koltuk fiyatı salt okunur bağlantı; ayrı PAZARYERİ görünümü yok (§3.8) |
| YM1 blocker | 14 hat tek ürün kalitesi varsayımını kırıyor; ~16 okuyucu | Seçenek A, ERP bayt-eş kabulüyle (§3.2) |
| YM2 blocker | Mevsimli komisyon MRR'a girince kapılar tek haftada açılır | Mevsimsiz MRR; fazlası kasaya; kabul vakası (§3.3.6) |
| YM3 blocker | `run_gate` iflası da bitmiş sayar; Faz 3'ün kabulü yok | Ölçüm protokolü ve sert kapılar (§11) |
| YM4 blocker | ERP gelir kalemleri bütün B2B tabanını oynatıyor | Atalet kuralı, bayt-eş kabul, kurulum bedeli gider karşılığı (§4.0, §4.2) |
| YM5 major | Şema numaraları üç taslakta çelişiyor | Tek kırılma UD9 (§10) |
| YM6 major | Faz 1 dönüşüm kalibrasyonu kurgu gereği tutmaz | Faz 1'de dönüşüm modeli yok (§2) |
| YM7 major | Satıcı akışı kendiliğinden doluyor; akım dengesi yok | Kod öncesi 104 haftalık simülasyon ve hedefler (§3.0); satıcı girişi alıcıya bağlı (§3.3.3) |
| YM8 major | Alıcı kitle motoru ve ACIK 97 kümesi sessizce yeniden açılıyor | Motor aynı; likidite 1,0'dan başlayan çarpan; kayıt ilk komisyonda; ACIK 97'nin açıldığı yazılı (§3.3.2) |
| YM9 major | Rakip Dünyası I2/I3 bağımlılığı yok; "Trendora" | Sıra sorusu, dönem tarafsız K3 adları, ad taraması, devler ayrı (§3.9, §9.1; soru 6, 7) |
| YM10 major | "Demoda ağaç bitmez" kanıtsız | Ağaç yüzdesi tablosu, hedef 104. haftada ≤ %60 (§11.2); kart eforu `sprint.json`'dan (§3.1) |
| YM11 major | Demo kapsamı "her şey" | Kesme listesi; fiil önce, kart sonra (§5, §9.3) |
| YM12 major | ERP derinliği O22'nin bilinmeyen arayüzüne bağlı | Faz 3a O22'den bağımsız; 3b yazılı arayüzle (§4.0, §4.7) |
| YM13 major | Test etkisi planı yok | Faz 2 iki aşamalı (UD8 mekanik, UD10 ekonomi); vaka tablosu (§11.3) |
| YM14 major | Kirli ağaçla dosya çakışmaları | Faz 1 EKIP'ten sonra; Destek bloğu salt okur, Hotfix BuildBar'da; dosya sırası (§9.1) |
| YM15 minor | Mevsim yükü kapasiteyi kalıcı büyütür; aşımda üç ceza | Mevsim yalnız doluluğun payında; pazaryerinde sipariş kaybı edinim cezasının yerine (§3.3.5, §3.7) |

### 0.3 Taslaklardan farklar
- Ayrı PAZARYERİ görünümü yok (tek Genel Bakış). "Planlar" adı yok (Paketler). Alıcı tarafında kademe ataması yok.
- Pazaryeri taslağının kalibrasyon sağlaması geçersizdir (komisyon %84); sabitler simülasyonla yeniden kurulur. `capacity_add` fiili yazılmaz.
- K3 adları dönem tarafsızdır, hiçbir yeni kademe `ai` taşımaz.
- ERP taslağının Raporlama hattı, `custom_module` ve `year_end_close` kartları EA'dadır. Kurulum bedeli koşulsuz nakit değil, kartla açılan gider
  karşılığıdır. Deneme havuzu sayı değil, adlı firma listesidir.
- Bilgi sayfası taslağının 16/17/18 şema dizisi ve Faz 1 Planlar/p modeli yoktur.

## 1. Kurallar
- `CLAUDE.md` bağlayıcı: §3 (doğrudan main; push yalnız Erdem "push et" deyince; tasarım sabiti "onay bekliyor"; TR metni "TR/EN onay bekliyor";
  Frank satırı yalnız taslak; ACIK maddelerine dokunulmaz), §5 (BILINGUAL BIRTH, önce İngilizce, tire yok, `static func` içinde `tr()` yok, kart
  metni kartın kendi bloklarında, `[VOCAB?]` fiili yazılmadan kart bağlanmaz, EFFECT-VISIBILITY), §6 (WRITE-THROUGH: her yeni durumun yazarı
  sahibinin seam'i), §7 (koyu yüzey yalnız `D_*`; yeni varyasyon `build_theme.gd` ve `THEME_STAMP` ile), §8, §9, §10 (yeni smoke yalnız çekirdek
  mantık için, falsifikasyonla), §11, §12 (kapı sırası). Yeni terim ekleyen commit sözlüğe (`docs/design/localization_glossary.md`) satırını ekler.
- **Model ve bütçe (Erdem 2026-10-11).** Kod yazımı Opus. İnceleme, ekran çekimi, görsel kabul, kapı ve smoke koşturma, belge ve CSV işi Sonnet ya
  da Haiku; seçimi işe bakarak sen yaparsın. Fable kullanılmaz. Commit başına en çok bir inceleme ajanı, yalnız diff okur; düzeltme en çok bir
  tur; bu PRD'nin istemediği ölçüm ya da ikinci inceleme turu yok.
- **Görsel kabul ciddi.** Ekrana giren her satırda sor: "Bu satır burada doğru mu, oyuncu anlıyor mu, yerinde mi, kalabalık mı?" Açıklama satırı
  ekleme, var olanı güncelle; blok başına en çok dört veri satırı. TR ve EN, 1920 ve 1536; ekrana fikstürle gel; en çok bir düzeltme turu, sonra
  ekran görüntüsüyle raporla ve commit etme.
- **Paylaşılan ağaç.** Başka oturumlar aynı klasöre commit'liyor (EKIP, A+B'nin O19-O22'si, ana menü). İşe `git status --short` ile başla; kirli
  dosyada yalnız kendi hunk'larını `git apply --cached` ile stage et, kapıları `git checkout-index` ile geçici dizine kurulan commit ağacında koş.
  `git checkout -- <yol>`, `reset --hard`, `stash`, `clean` yasak. Dosyayı her commit'ten önce taze oku.
- **Ekonomi ölçülür, sabit sessizce çevrilmez.** Her ekonomi commit'i §11.1 protokolünün önce/sonra tablosunu rapora koyar. ±%50 ayar
  penceresinin dışına çıkan ya da sert kapıyı düşüren değer commit'lenmez; rapora "onay bekliyor" diye yazılır.
- **Fiil önce, kart sonra.** Yeni etki fiili `effects.gd` kolu, `EvChips.describe` çipi, `_vocabulary.md` (`--event-vocab`) ve `event_chip_coverage`
  ile kendi commit'inde iner; onu kullanan kart sonraki commit'tedir.
- Pencereli koşular sırayla ve her biri kendi `APPDATA`'sında; ekran istemeyen her koşu `--headless`.

## 2. Faz 1 · Genel Bakış (salt okunur ve kapasite)
Amaç: sahibin asıl şikâyetini bugünkü veriyle kapatmak (kullanıcı, ücretli ve ücretsiz, kapasite, gelir). Ekonomi değişmez. Dönüşüm modeli,
Paketler ve akım kırılımı Faz 2'de pazaryeriyle bir kez doğar; silinecek ürünlerin üstüne kalibrasyon kurulmaz (SG8, YM6).

**GB1 · Yer, kilit, derin bağlantı.**
- Ne: Ürün penceresinde üçüncü görünüm: SPRİNT | ÇEYREK | GENEL BAKIŞ (`VIEW_KEYS`, `product_tab.gd:16`; görünüm listesi `:180`). Ürün canlı
  olana kadar `UiFactory.D_locked_tab` (`product_tab.gd:184` kalıbı) ve gerekçe `PRODUCT_VIEW_OVERVIEW_LOCK`. Sürüm notu açıkken görünüm
  SPRİNT'e döner (bugünkü kural). Yeni sinyal `EventBus.product_view_requested(view)` (`finance_subpage_requested` kalıbı); manifest
  `python tools/gen_signal_manifest.py` ile.
- Neden ray sekmesi değil: sekme altı yere dokunur (`UiTokens.TABS`, `LeftTabs.tscn` konum smoke'u, `TAB_` anahtarı, ikon, `window_layer.gd`
  `TAB_SCENES` ve `SPECS`, `--tab-shot`) ve aynı anda tek birincil pencere açık olduğu için yan yana görüş de vermez.
- Dosyalar: `scripts/tabs/product_tab.gd`; yeni `scripts/tabs/product/overview_view.gd` (çizim) ve `overview_model.gd` (saf okuyucu;
  `ProductModel.live()` şişmez); `scripts/autoload/event_bus.gd`.
- Tazeleme: açıkken `hour_changed`'de yalnız değer etiketleri boyanır, yeniden kurulum yok (ACIK 105 dersi); grafik `day_advanced`'de; Kapasite
  `infra_changed`'de (bugün dinleyicisiz, `event_bus.gd:141`; yayan `ProductState`, `product_state.gd:231,239`).

**GB2 · Düzen ve zaman birimi.**
- Finans Özet'in üç sütun ızgarası (`finance_ozet_view.gd`). Bloklar `D_card` ve başlık; blok başına en çok dört veri satırı; açıklama satırı
  yok; uyarı satırı yalnız eşik aşılınca.
- **Tek birim ay (SG11).** Tutarlar aylıktır: "Bu ay (sürüyor)" şu anki aylık hızdır, "Geçen ay" `month_history`'nin son kapanışıdır
  (`game_state.gd:164`), "Değişim". Hafta/Ay anahtarı yalnız grafikte.
- **B2C:** sol **Gelir raporu** (tek akım: Ücretli plan; plan kapalıyken satır "Kapalı" ve tek satır mevcut `SALES_B2C_PLAN_HINT`), altında 12
  aylık sütun (`month_history`). Orta **Kullanıcılar**: toplam, ücretli, ücretsiz (toplam eksi ücretli), dönüşüm (`SalesSystem.conversion_rate`,
  `sales_system.gd:448`); 26 haftalık sütun (`b2c_audience_history`). Sağ **Kapasite** (GB3) ve **Destek**.
- **B2B:** sol **Gelir raporu** (tek akım: Abonelik). Orta **Hesaplar**: hesap (`CustomerRegistry.account_count`, `customer_registry.gd:48`),
  koltuk (`get_total_seats`, `:75`), "Onboarding {a} · Aktif {b} · Risk {c}" (`lifecycle_phase`), ortalama memnuniyet; "Portföy" düğmesi
  Satış'ı açar. Sağ **Kapasite**, **Destek**, **Kayıplar** (bu ay kaybedilen hesap: `run_customers_lost` eksi `month_ledger` açılış anlığı; yeni
  durum yok).
- **Destek bloğu yalnız okur:** bu hafta gelen, doğrulanan, kaçırılan (EKIP D2), canlı hata; kaynak `BuildBarModel.derive`
  (`build_bar_model.gd:38`). Hotfix düğmesi BuildBar'da kalır, burada tekrar edilmez.

**GB3 · Kapasite görünür ve oyuncunun.**
- Doluluk çubuğu (%80 ve %100 işaretli), sağlayıcı ve birim, aylık fatura (`InfraSystem.monthly_bill`, `infra_system.gd:256`), servis gideri
  (`monthly_service`, `:267`). Renk yeni `UiTokens.D_utilization_color(u)`: %80'e kadar `D_INK_2`, sonra `D_WARN`, %100 üstü `D_NEG`; renk körü
  ikiziyle; `THEME_STAMP` artar.
- **Eksi ve artı birim:** `InfraSystem.adjust_capacity` (`:245`; bugün oyunda çağıranı yok); yanında fatura farkı ("ayda +$55").
- **Otomatik ya da Elle** iki konumlu seçici. Otomatik bugünkü kuraldır: her sürüm kapasiteyi doluluk %80'in altına inene kadar büyütür,
  küçültmez (`sprint_bridges.gd:115-119`). Oyuncu eksi ya da artıya basınca Elle olur; Elle'de sürüm büyütmez. Durum `infra_auto` bayrağı
  (`FLAG_TYPES`, bool, varsayılan `true`; şema artmaz); yazarı yeni `InfraSystem.set_auto(on)`.
- Aşımda tek uyarı satırı: Güven alanının aşım cümlesi (`PRODUCT_AREA_OVER_CAPACITY`, `area_sentence` içinde, `sprint_catalog.gd:163-164`; koşulu `_over_capacity`, `:628-629`); yeni anahtar yok.

**GB4 · Satış B2C sayfası özete iner.**
- `sales_tab.gd` `_paint_b2c` (`:257`) tek satıra iner: "{users} kullanıcı · {paying} ücretli · MRR {mrr}" ve "Ürün'de aç"
  (`product_view_requested("overview")`). Kullanıcı bilgisi tek yerde durur.
- Çek listesinin B2C para adımları (`cheque_read.gd:39,41`) Genel Bakış'a gider: C13'ün `"tab": "sales"` değeri B2C'de ürünün Genel Bakış'ına
  döner; B2B adımları Satış'ta kalır.

**GB5 · Kabul.**
- Ekonomi değişmez: `--run-log=full_run:40:sim:<1..8>` ve `full_run_b2c` aynı tohumlarla, UD1'in ebeveyn ağacına karşı `^PROBE` bayt-eş;
  `bash tools/run_gate.sh` 3/3.
- Yeni smoke `infra_manual_stops_autogrow`: Elle'de `on_release` sonrası `units()` değişmez (falsifikasyon: bayrak okumasını sil → FAIL).
  `cheque_read_steps` B2C hedefiyle güncellenir.
- Görsel: `--product-shot=live:overview_b2c|overview_b2b|overage|manual` (yeni türler), `--sales-shot=b2c_live` (özet satırı); TR/EN, 1920/1536;
  `--theme-contrast-audit`.

## 3. Faz 2 · Pazaryeri

### 3.0 Kod öncesi: simülasyon, taban, tasarım notu (PZ0)
Kod yazılmadan önce üç iş; çıktılar rapora, sayılar "onay bekliyor":
1. **Çevrimdışı simülasyon** (repo dışı betik, scratchpad'te): §3.3 ve §3.5 formülleri, haftalık adım, 104 hafta. Dört strateji (varsayılan;
   yüksek komisyon; düşük komisyon ve Premium satıcı; düşük komisyon ve reklam) ve iki yatırım profili (alıcı ağırlıklı, satıcı ağırlıklı).
   Hedefler:
   - Varsayılan oyunda 90. haftada hiçbir akım gelirin %65'ini geçmez.
   - Dört stratejinin en az üçü 120.000 MRR'a (Seri A çıtası, `sales_system.gd:39`) ACIK 97 penceresinde (70-95. hafta) varır; en hızlı ile en
     yavaş arası en çok 12 hafta.
   - Tek tarafa yatırım tıkanır: yalnız alıcı ya da yalnız satıcı profili 52. haftada dengeli profilin MRR'ının yarısından azında kalır. Alıcı
     büyümesi durunca satıcı sayısı düzleşir.
   - Erken oyun: melek eşiği (2.500 MRR, `angel_round_system.gd:27`) bugünkü B2C tabanının ±%50'sinde (17. hafta → 8-25).
2. **Ölçüm tabanı:** UD5'in `tools/econ_protocol.sh`'i bugünkü main'de koşulur (§11.1); tablo rapora.
3. **Tasarım notu:** simülasyonun seçtiği sabitler §8 tablosuna işlenir ve Erdem'e "onay bekliyor" diye gider. UD10 onaydan sonra başlar.

### 3.1 Özellik ağacı, hat biçimi, alanlar (PZ1)
**`groups[]` biçimi.**
- Hat dosyası `{subtype, groups: [{kind: "identity", side: "buyer" ya da "seller" ya da "", lines[5]}, {kind: "module", lines[n]}]}`. Eski
  `lines[5]` biçimi tek kimlik grubu (`side ""`) olarak okunur; `erp.json` UD21'e kadar değişmez.
- Doğrulayıcı (`product_lines.gd`) bugünkü kuralı kimlik grubu başına uygular: 5 hat (`:119`), eksen 2/1/2 (`:131`), hat başına 3 kademe, efor
  bantları (`:27`), ×1,6 (`:45`), Ar-Ge düğümü K3'te ve yalnız K3'te, kök ya da dal düğümü. Toplam hat `4 + 5 × kimlik grubu + modül hattı`;
  `LINES_PER_SUBTYPE` (`:51`) bu hesaba döner. Modül grubu: 3 kademe, aynı efor ve ×1,6 kuralı, `axis` ve `axis_points` taşımaz (§4.1).
- Kart eforu hat dosyasından değil `sprint.json` `effort`'tan gelir (3/5/8; `sprint_catalog.gd:203-210`). Hat dosyasındaki `effort` yalnız
  doğrulayıcı bandı ve destek akışının yeni kod girdisidir (`sprint_system.gd:971`).

**`data/product/lines/marketplace.json`.** K3 düğümleri kök ya da dal; adlar dönem tarafsız (2012'de de anlamlı); hiçbir kademe `ai` taşımaz,
Rakip Dünyası I3'ün göç yüzeyi büyümez. `axis_points` 4/9/12; efor ve `usage_weight` `note_tool.json` aralığında.

ALICI (`side: "buyer"`)
| Hat | Eksen | K1 | K2 | K3 · Ar-Ge |
|---|---|---|---|---|
| `line_mkt_discovery` Discovery / Keşif | inn | Browse and search / Kategori ve arama | Filters and sorting / Filtre ve sıralama | Recommendations / Kişisel öneriler · semantic_index |
| `line_mkt_reviews` Reviews / Yorumlar | inn | Ratings and reviews / Puan ve yorum | Photo reviews and questions / Fotoğraflı yorum ve soru | Most helpful first / En faydalı yorumlar · analytics_engine |
| `line_mkt_checkout` Checkout / Ödeme | sta | Cart and card payment / Sepet ve kartla ödeme | Saved cards / Kayıtlı kart | Fraud shield / Dolandırıcılık kalkanı · security_cert |
| `line_mkt_orders` My orders / Siparişlerim | exp | Order status / Sipariş durumu | Tracking and returns / Kargo takibi ve iade | Delivery estimate / Teslimat tahmini · analytics_engine |
| `line_mkt_product_page` Product page / Ürün sayfası | exp | Photos and details / Fotoğraf ve açıklama | Variants and sizes / Renk ve beden seçimi | Size advice / Beden önerisi · user_research |

SATICI (`side: "seller"`)
| Hat | Eksen | K1 | K2 | K3 · Ar-Ge |
|---|---|---|---|---|
| `line_mkt_listing` Listings / Ürün yükleme | inn | Single listing / Tek tek yükleme | Bulk upload / Toplu yükleme | Catalog matching / Katalog eşleme · data_model |
| `line_mkt_promotions` Promotions / Kampanya araçları | inn | Discounts and coupons / İndirim ve kupon | Campaign calendar / Kampanya takvimi | Automatic repricing / Otomatik fiyatlama · scalable_backend |
| `line_mkt_payouts` Payouts / Hakediş | sta | Weekly payouts / Haftalık hakediş | Invoices and reconciliation / Fatura ve mutabakat | Next day payouts / Ertesi gün hakediş · test_automation |
| `line_mkt_seller_panel` Seller panel / Satıcı paneli | exp | Order inbox and labels / Sipariş listesi ve kargo etiketi | Stock and prices / Stok ve fiyat | Storefront editor / Mağaza vitrini · design_system |
| `line_mkt_seller_signup` Seller signup / Satıcı başvurusu | exp | Short application / Kısa başvuru | Document check / Belge doğrulama | Guided first week / İlk hafta rehberi · onboarding_flow |

- Adım açıklamaları (`_DESC`) mevcut kayıtla yazılır: bir cümle, gözlem, hüküm yok (örnek `PROD_STEP_NOTE_TOOL_*_DESC`).
- Paylaşılan dört hat aynı (`shared.json`); yalnız alt tür betimleri yazılır (entegrasyonlar: "Accounting and carrier links / Muhasebe ve kargo
  bağlantıları").
- Yorumlar satıcının ürününe aittir; mağaza puanı yoktur (S2).
- Kilitli kademe ağaçta adı ve Ar-Ge gerekçesiyle görünür (`PRODUCT_LOCKED_NODE`); bugünkü davranışı yeni hatlarda doğrula (SG7).
- Hacim (hesap): 14 hat × 16 kart puanı + 3 gelir kartı × 3 = 233 puan (bugün 9 hat, 147). Tek kurucunun sprinti 4 puan (ACIK 97).

**Alanlar ve MVP.**
- `sprint.json` alanları (`:44-51`): pazaryerinde `core` yerine iki kimlik alanı, `buyer` ve `seller` (`identity: true`, `side`,
  `markets: ["b2c"]`); `core` yalnız b2b'ye kalır. onboarding, growth, trust ve revenue aynı. `SprintCatalog.capabilities` (`sprint_catalog.gd:63`)
  kimlik hatlarını `side`'a göre süzer; `_identity_area` (`:589`) liste döndürür.
- **MVP:** 3 kimlik hattı K1 ve her taraftan en az biri (`sprint.json` yeni `mvp_min_per_side: 1`; sayaç `mvp_cards_left`,
  `sprint_catalog.gd:442-447`). Gerekçe: satıcı aracı olmayan pazaryerine satıcı gelmez. Ödeme ve Hakediş MVP'yi değil komisyonu kilitler (§3.3.4).
- Alt tür kaydı (`product_catalog.gd:11`): `{"id": "marketplace", "sectors": ["consumer", "retail", "ecommerce"], "market_type": "b2c",
  "price_tendency": "volume"}`, haber havuzu "saas"; `QUALITY_AXES` inn 1,0 · sta 1,3 · exp 1,2; `TYPE_SCREEN` (`:53`) b2c oynanabilir listesi
  yalnız `marketplace`.

### 3.2 Kalite zinciri: seçenek A (PZ2; YM1)
Ekip kararı; kodda ve HARITA'da yazılır:
- `QualityModel.shipped_normalized()` (`quality_model.gd:117`) imzası ve `mvp_*` bayraklarının bugünkü okuyucuları (quality_model, sales_system,
  vc_pitch_system, term_sheet_table_system, b2b_sales_system, product_system, main.gd ve diğerleri) değişmez.
- İki taraflı alt türde `mvp_innovation`, `mvp_stability`, `mvp_experience` iki tarafın okumasının **ortalamasıdır**. Her taraf 9 hatlı bir ürün
  gibi okunur: kendi ailesinin 5 hattı ve 4 paylaşılan hat. `axis_bar` (`:180`) eksen başına 3 hat sayar; `BASELINE_LINES_PER_AXIS` 3 ve
  `NORMALIZE_HALF_SAT` 25 (`:31`) kalibrasyonu taraf başına korunur. `ProductLines.line_ids_by_axis(subtype, side := "")` tarafı süzer.
- `ProductState.lines_open(scope)` ve `usage_weight_total(scope)` (`product_state.gd:134,144`): değer okuması (`sales_system.gd:434-435`)
  pazaryerinde taraf kapsamıyla ve modülleri hiç saymadan okur; altyapı yükü (`infra_system.gd:161-164`) toplamı okur. Destek `usage_weight_total`
  okumaz: `SupportSystem.usage_multiplier` (`support_system.gd:172-175`) B2B hesap sayısını ya da B2C kitleyi sayar.
- Yeni `QualityModel.side_normalized(side)` yalnız `MarketplaceSystem` okur (satıcı akışı).
- Ortalama, minimum değil: MVP iki tarafı bilerek dengesiz çıkarır; minimum MVP'yi cezalandırırdı.
- Ürün sekmesinin eksen üçgeni ortalamayı gösterir; taraf okuması ekranda yok.
- **Kabul:** UD7'nin ebeveyn ağacına karşı ERP `--run-log=full_run:40:sim:<1..8>` `^PROBE` bayt-eş; pazaryeri için yük katsayısı
  (`InfraSystem.load_factor`) ve `product_value().optimal` "tek liste" ile "taraf kapsamı" yan yana tablo; `product_lines_catalog_loads`,
  `line_ladder_rules`, `axis_reading_replaces_not_adds` yeşil; yeni vaka `two_sided_quality_mean` (falsifikasyon: toplam alınırsa FAIL).

### 3.3 Ekonomi çekirdeği: `MarketplaceSystem` (PZ3)
Yeni statik sistem `scripts/systems/marketplace_system.gd` (SalesSystem kalıbı); durumun tamamı GameState'te, statik durum yok.
`SalesSystem.hourly_tick` (`sales_system.gd:149`) alt tür pazaryeriyse onu çağırır; `_derive_b2c_mrr` (`:226`) MRR'ı `revenue_streams()`'in
mevsimsiz toplamından yazar (`set_seats(üye)`, `set_mrr(toplam)`); `reflect_mrr` kanonu (`:160`) değişmez.

**3.3.1 Durum** (`FLAG_TYPES`, anlamlı varsayılanla): `mkt_sellers` float (0), `mkt_commission` int (10), `mkt_member_perks` Array,
`mkt_premium_fee` int, `mkt_ads_level` int (0), `plan_slots` Dictionary (hat id → "base" ya da "premium"; iki pazar ortak), `infra_auto` (Faz 1).
`b2c_price` ve `b2c_paid_tier_open` Üyelik ücreti ve açıklığı olarak kalır (yeniden adlandırma yok). Haftalık örnek dizisi
`GameState.product_history` (26 hafta: alıcı, üye, satıcı, Premium satıcı, sipariş, satış hacmi, akımlar, doluluk) `b2c_audience_history`'nin
yerini aynı commit'te alır.

**3.3.2 Alıcılar (YM8).**
- Kitle motoru olduğu gibi kalır (`_audience_delta_per_hour`, `:181`: taban büyüme, kalite, marka, itibar, ilgi, ağızdan ağıza, aşınma, churn,
  pazarlama). Tek fark: pazaryerinde fiyat çarpanının (`audience_growth_multiplier`, `:476`) yerine **likidite çarpanı**
  `clamp(find_rate / FIND_REF, LIQ_MIN, LIQ_MAX)` girer; FIND_REF, SELLER_SEED'deki bulma oranıdır, yani MVP'de çarpan 1,0. Üstüne reklam yükü
  `(1 - ADS_GROWTH_DRAG[seviye])`.
- `find_rate = S / (S + SELLER_HALF / keşif_katı)`: iç değişkendir, ekranda hiç görünmez.
- Bu değişiklik ACIK 97'nin birlikte kalibre edilmiş B2C kümesini (WOM_MULT_PIVOT ve SATISFACTION_DRIFT kenarda) ve Rakip Dünyası §5.5'in "şimdi
  dokunulmaz" listesini **yeniden açar**. ACIK 97 protokolü yeniden koşulur; rapor ve yeni ACIK maddesi bunu açıkça yazar.

**3.3.3 Satıcılar (YM7).**
- MVP sürümünde `mkt_sellers = SELLER_SEED` (kurucunun ağı).
- Haftalık giriş = `(S_BASE + S_DEMAND × min(alıcı / max(S, 1), BPS_CAP)) × c_katı × paywall × başvuru_katı × ilgi × satıcı_çağrısı`. Ana terim
  satıcı başına alıcıdır: alıcı gelmezse satıcı kendiliğinden dolmaz. Yeni satıcının bir kısmı ilk haftada aktifleşmez (Ürün yükleme kolu).
- `c_katı = clamp(C_REF / max(c, 1), 0,4, 1,8)` (fiyat çarpanıyla aynı dilbilgisi). Komisyon artınca bir kerelik satıcı kaybı `churn_fraction`
  (`:465`) dilbilgisiyle, optimal yerine C_REF ile.
- `paywall = (1 - PAYWALL_DRAG_S × p_s) / (1 - PAYWALL_DRAG_S × p_s0)`: varsayılan atamada 1,0 (§3.5).
- Haftalık çıkış = `S × (S_CHURN × hakediş_katı + S_CHURN_LOW × max(0, OPS_FLOOR - satıcı başına aylık sipariş) / OPS_FLOOR)`. OPS_FLOOR doğal
  işletme noktasının dışına konur; simülasyon seçer.
- Oyuncunun satıcı kolları: satıcı çağrısı (§3.8.3), komisyon, Premium paketi, Satıcı başvurusu ve Ürün yükleme hatları.

**3.3.4 Sipariş, satış hacmi, ilan dönemi (SG4).**
- Aylık sipariş = `(ücretsiz × F + üye × F × MEMBER_ORDER_MULT) × find_rate × hat katları × mevsim × (1 - ADS_ORDER_DRAG[seviye]) ×
  min(1, 1 / doluluk)`; tavanı `S × ORDER_CAP[Satıcı paneli kademesi]`, taşan sipariş kaybolur.
- Aylık satış hacmi = sipariş × AOV × Ürün sayfası katı.
- **İlan dönemi (öneri; soru 3):** Ödeme K1 ve Hakediş K1 canlı olana kadar siparişler platform dışında yapılır, komisyon ve reklam geliri
  sıfırdır. Siparişler bloğu "Platform dışı" der; Komisyon satırı tek satır kilit gerekçesi taşır. Toplu kayıt `co_b2c_userbase`
  (`_ensure_b2c_record`, `:237`) ücretli plan açılınca değil **ilk komisyon anında** kurulur; tohum memnuniyeti kuralı aynı.

**3.3.5 Aşım (YM15).**
- Pazaryerinde aşım edinim cezası (`OVERAGE_ACQUISITION_MULT` 0,6, `infra_system.gd:69`) uygulanmaz; yerine sipariş kaybı `min(1, 1 / doluluk)`
  gelir. Memnuniyet −0,8/gün ve GELEN ×1,5 kalır (`:66-68`).
- Satıcılar yük taşır: `served_count` (`:180`) pazaryerinde `S × SELLER_LOAD_EQ` ekler. Destekte `usage_multiplier`'a
  (`support_system.gd:172`) `S / SELLER_SUPPORT_DIV` eklenir (EKIP'in dosyası; yalnız çarpan).

**3.3.6 Mevsimsiz MRR (YM2).**
- `MarketplaceSystem.revenue_streams()` her akım için iki değer döndürür: `base` (mevsim katı 1,0 ile) ve `live` (mevsimle). `reflect_mrr`
  üzerinden `GameState.mrr` yalnız `base` toplamını görür. Melek (2.500), seed (20.000, `seed_constants.gd:21`), Seri A mandalı
  (`phase_gate_system.gd:145-169`), sonlar (`endings_system.gd:169, 209, 271`) ve kâr serisi mevsimle oynamaz.
- Mevsim fazlası (`live - base`; demodaki mevsimlerin hepsi 1'in üstünde) her hafta `FinanceSystem.apply_one_time_income(fazla, "season")`
  ile kasaya girer. Bu çağrı (`finance_system.gd:198-206`) yalnız `record_transaction` (50 satırlık günlük, `GameState.TRANSACTIONS_CAP`) ve
  `set_cash` çağırır; `month_ledger`'a hiç dokunmaz. Ayın geliri yalnız `accrue_month_flow(revenue, ...)` ile (`finance_system.gd:147`; `revenue`
  MRR'den türeyen tik rakamıdır) birikir; `game_state.gd:155-162` ve ACIK_KARARLAR 97 ajan kararı (e) ("Artı `add_cash` tek seferlik gelirdir, ay
  gelirine ve kâr serisine yazılmaz") tek seferlik geliri tahakkuk ettirmez. Gelir raporundaki çizgi altı "Sezon geliri" satırının bugün seam'i
  yoktur: UD10 yeni bir tahakkuk seam'i ekler; fazla açık ayın `streams` kaydına (§3.8.1) yazılır ve `month_history` kapanışına taşınır, ama
  `income`'a ve `net`'e girmez. Böylece kâr serisi mevsimle oynamaz (yukarıdaki cümle) ve 97 (e) bozulmaz. Negatif mevsim (Ocak durgunluğu)
  EA'dadır, çünkü negatif düzeltme seam'i ister.
- **Kabul vakası** `mkt_season_excluded_from_gates`: Kara Cuma haftasında `GameState.mrr` mevsimsiz toplama eşit; hiçbir kapı o hafta yalnız
  mevsimle açılmaz (falsifikasyon: `live` toplamını yaz → FAIL). Protokolde `GATE` günleri.

**3.3.7 Bot ve pazar payı.**
- `RunProbe` (`run_probe.gd:61-76`): B2C preset'leri `marketplace` okur. Strateji preset'leri: `full_run_b2c` (varsayılan),
  `full_run_b2c_commission`, `full_run_b2c_premium`, `full_run_b2c_ads`; `full_run_b2c_video` silinir. Bot kolları §8'de. Harness değişikliği
  serbest, ayrı raporlanır.
- Pazar payı pazaryerinde satış hacmiyle: aylık satış hacmi / `MARKET_TOTAL_GMV` (`rival_catalog.gd:90` `MARKET_TOTAL_MRR`'ın kardeşi; okuyucu
  `rival_registry.gd:180`).

### 3.4 Hat kolları (PZ4; SG3)
Her kimlik hattı ekonomide adı konmuş tek bir kolu çevirir ve kart açıklamasında tek satır olarak görünür ("Sepet ortalaması +%8"; anahtarlar
kol türüne göre, §7). Kalite puanı kalır ama tek kanal değildir. Değerler kademeye göre K0 · K1 · K2 · K3, hepsi onay bekliyor.
| Hat | Kol | K0 · K1 · K2 · K3 |
|---|---|---|
| Keşif | keşif katı (aynı satıcıyla daha çok eşleşme) | 0,8 · 1,0 · 1,25 · 1,5 |
| Yorumlar | alıcı başına sipariş katı | 1,0 · 1,06 · 1,12 · 1,18 |
| Ödeme | K1 komisyonu açar; sonra alıcı başına sipariş katı (sepette vazgeçen azalır) | kilit · 1,0 · 1,08 · 1,12 |
| Siparişlerim | iade anlaşmazlığı kartının şansı; K2 "Hızlı iade" ayrıcalığını açar | 1,0 · 1,0 · 0,7 · 0,5 |
| Ürün sayfası | sepet ortalaması katı | 0,9 · 1,0 · 1,08 · 1,15 |
| Ürün yükleme | yeni satıcının ilk hafta aktifleşme payı | 0,4 · 0,7 · 0,85 · 1,0 |
| Kampanya araçları | mevsimden alınan pay; K2 Öne çıkan ürünleri ve "Üyeye özel fırsatlar"ı açar | 0,5 · 0,7 · 0,85 · 1,0 |
| Hakediş | K1 komisyonu açar; sonra satıcı kaybı katı | kilit · 1,0 · 0,8 · 0,6 |
| Satıcı paneli | satıcı başına aylık sipariş tavanı | 20 · 60 · 150 · 400 |
| Satıcı başvurusu | satıcı girişi katı; K2 sahte ürün kartının şansını yarıya indirir | 1,0 · 1,15 · 1,3 · 1,45 |
- Paylaşılan hatlar kol taşımaz (kalite ve yük).
- Premium paketindeki kademenin kolu yalnız Premium satıcıya işler; ücretsiz satıcı o hattın ücretsiz kalan en üst kademesinin değerini alır.
  Ücretsizin deneyimi ile Premium dönüşümü arasındaki takas budur (S7).
- **Kabul:** vaka `mkt_line_levers_apply` (her kol kendi hattının kademesiyle değişir; falsifikasyon: bir kolu sabite bağla → FAIL);
  simülasyonun kol değerleriyle karşılaştırması rapora.

### 3.5 Gelir akımları ve stratejiler (PZ5; SG2)
**3.5.1 Dört akım** (aylık; `base` değerleri MRR'a girer)
| Akım | Formül | Kolu | Bedeli |
|---|---|---|---|
| Komisyon | satış hacmi × c | gelir satırında, %0-25 adımlı | Satıcı girişi `c_katı`; artışta bir kerelik kayıp |
| Üyelik | üye × ücret | gelir satırında ücret; ayrıcalıklar Paketler'de | Ayrıcalık giderleri; ücret artışında üye kaybı (`churn_fraction`) |
| Premium satıcı | S × Premium payı × ücret | gelir satırında ücret; hat çipleri Paketler'de | Ücretsiz satıcının araçları incelir; satıcı girişinde paywall |
| Öne çıkan ürünler | satış hacmi × ADS_RATE[seviye] | gelir satırında Kapalı, Az, Orta, Çok | Arama alakası düşer: alıcı başına sipariş ve alıcı büyümesi iner |
- Premium payı = `clamp(PREM_BASE × (0,3 + 1,4 p_s) / (0,3 + 1,4 p_s0) × clamp(PREM_FEE_REF / ücret, 0,4, 1,8), 0,02, 0,6)`. `p_s` Premium'daki
  canlı satıcı yükseltmelerinin `axis_points` payı, `p_s0` varsayılan atamanın payı (2/3; §3.6). `conversion_rate` (`:448`) dilbilgisi.
- Üye payı = `clamp(MEMBER_BASE × (1 + Σ ayrıcalık ağırlığı) × clamp(MEMBER_FEE_REF / ücret, 0,4, 1,8), 0,005, 0,25) × hata katı`.
- **"Önerilen" değer yok.** Değişen kolun yanında yalnız önizleme satırı ve "Uygula": "Komisyon %10 → %12 · satıcı girişi −%15 · bir kerelik −8
  satıcı · gelir ayda +$4.100". Kaynak saf `MarketplaceSystem.estimate_tiers(taslak)` (`estimate_price_change`, `:486` kalıbı). Sayfada tek amber.
- Yazarlar (WRITE-THROUGH): komisyon `MarketplaceSystem.set_commission(c)`; Üyelik ücreti `SalesSystem.apply_b2c_price` (`:502`, ilk kez
  arayüzden çağrılır); Premium ücreti `set_premium_fee`; reklam `set_ads_level`.
- **Açılış kartları** (Gelir alanı, tek kademe, efor 3, `cap_paid_plan` kalıbı, `sprint_catalog.gd:14`):
  - `cap_paid_plan`: kimlik korunur (kayıt ve rakip tablosu uyumu), adı Membership / Üyelik. Kilit: Ödeme K1 canlı.
  - `cap_seller_premium` Premium seller plan / Premium satıcı planı. Kilit: Satıcı paneli K1.
  - `cap_featured` Featured listings / Öne çıkan ürünler. Kilit: Kampanya araçları K2 ve 150 satıcı; açılınca seviye Kapalı başlar.

**3.5.2 Alıcı Üyeliği ayrıcalıkları (SG1).** Temel alışveriş herkese açıktır; Üyelik hiçbir kademeyi kilitlemez. Üyelik dört ayrıcalık satar;
her biri bir hatta bağlıdır ve kilidi açılmadan listede görünmez.
| Ayrıcalık | Kilit | Etkisi | Bedeli |
|---|---|---|---|
| Member deals / Üyeye özel fırsatlar | Kampanya araçları K2 | üye ağırlığı +0,25 | İndirimi satıcı öder: `c_katı` ×0,97 |
| Early access to sales / Kampanyaya erken erişim | Kampanya araçları K1 | +0,15; mevsimden önceki 3 haftada üye payı ayrıca +%20 | Ücretsiz alıcının mevsim siparişi ×0,95 |
| Fast returns / Hızlı iade | Siparişlerim K2 | +0,20 | İade kargosunu platform öder: üye siparişi × RETURN_SHARE × RETURN_COST |
| Shipping coupon / Kargo kuponu | Siparişlerim K1 | +0,50; üye siparişi ayrıca ×1,1 | Kargo bedelini platform öder: üye siparişi × COUPON_COST |
- Giderler yeni yakım kalemine yazılır: `perks` (`FinanceSystem.BURN_IDS`, `finance_system.gd:38`; `set_burn_category`, `:231`). Finans gider
  dağılımında "Üyelik ayrıcalıkları", gelir raporunda çizginin altında eksi satır. Platform kargoyu taşımaz, yalnız bedelini öder (S2).
- Kargo kuponunun demoda olup olmadığı soru 1'dir; kesilirse liste üç ayrıcalıkla kalır.

**3.5.3 Stratejiler** (bot preset'leri ve simülasyon hedefi): varsayılan (c %10, Premium varsayılan atama, reklam Orta, bütün ayrıcalıklar);
yüksek komisyon (c %18, reklam ve Premium kapalı); abonelik ağırlıklı (c %5, bütün yükseltmeler Premium'da, yüksek ücret); reklam ağırlıklı
(c %6, reklam Çok). Hedef §3.0, kapı §11.2.

### 3.6 Paketler ekranı (PZ6; S7, SG12)
- Ürün penceresinde dördüncü görünüm PAKETLER / PACKAGES (`VIEW_KEYS`); ilk ücretli kart çıkana kadar kilitli. Ad gerekçesi: fiyat kolları gelir
  satırına taşındığı için bu ekranda fiyat yok ("Fiyatlandırma" yanıltırdı); "Planlar" sprint planlamasıyla karışırdı.
- **Satıcı araçları (sol):** satır = Premium'a konabilen satıcı hattı (Ürün yükleme, Kampanya araçları, Satıcı paneli); hücre tek çip, Ücretsiz ya
  da Premium: hattın K2 ve K3'ü birlikte o pakettedir. Hakediş ve Satıcı başvurusu temel güvencedir, satır olmaz. Varsayılan atama: Ürün yükleme
  ve Kampanya araçları Premium'da, Satıcı paneli ücretsiz (`p_s0` = 2/3). Yeni yayınlanan kademe hattın durumunu alır. K2'si henüz olmayan hat
  ızgarada görünmez, bu yüzden gerekçe satırı gerekmez.
- **Alıcı Üyeliği (sağ):** dört ayrıcalığın açma kapama anahtarı; kilitli olan görünmez.
- Altta tek önizleme satırı (`estimate_tiers`): "Premium satıcı %18 → %24 · satıcı girişi −%5 · ücretsiz satıcının sipariş tavanı ayda 60 ·
  gelir ayda +$2.100". "Uygula" (tek amber) ve "Vazgeç" (`SYS_CANCEL`); karar kartı açıkken (`EventGate.active_id() != ""`) Uygula kapalı.
- Durum `plan_slots` (yazarı `SalesSystem.set_plan_slots(taslak)`) ve `mkt_member_perks`.
- **Kabul:** `--product-shot=live:packages_mkt` TR/EN, 1920/1536; vaka `mkt_estimate_tiers_pure` (çağrı hiçbir bayrağı değiştirmez;
  falsifikasyon: içine bir `set_game_flag` koy → FAIL).

### 3.7 Mevsimler, kapasite, kargo (PZ7; S3, SG13, YM15)
- Tablo `data/product/seasons.json`, pazar satırlarıyla (B2B satırları §4.5). Okuyucu `SeasonCalendar.current(market)` takvimi
  `GameState.get_date_dict` (`game_state.gd:646`) ile okur; kat bütün haftaya uygulanır.
| Mevsim | Hafta | Sipariş | Yük | Bildirim |
|---|---|---|---|---|
| Black Friday / Kara Cuma | Kasım 4. hafta | ×2,2 | ×2,0 | ×1,6 |
| Year end / Yılbaşı | Aralık 2. ve 3. hafta | ×1,5 | ×1,4 | ×1,3 |
- Sipariş katı Kampanya araçlarının payıyla işler: etkin kat = `1 + (kat - 1) × pay`.
- **Yük yalnız doluluğun payındadır** (`InfraSystem.occupancy`, `infra_system.gd:190`) ve aşım kapılarındadır. `units_for_occupancy` (`:198`) ve
  otomatik büyüme mevsimsiz taban yükü okur. Kabul vakası `season_load_does_not_grow_capacity`: Kara Cuma haftasındaki sürümden sonra `units()`
  değişmez (falsifikasyon: `units_for_occupancy` mevsimli yükü okursa FAIL).
- Bildirim katı `SupportSystem.reports_per_day` (`support_system.gd:155`) çarpımına girer (EKIP'in dosyası; yalnız çarpan).
- **Kara Cuma tek kanaldan gelir:** `world.season_prep` kartı (§5.3) üç hafta önce. Kapasite bloğundaki mevsim satırı ("Kara Cuma 3 hafta sonra ·
  beklenen doluluk %148"; saf `InfraSystem.projected_occupancy(kat)`) kart kapandıktan sonra, kart gelmediyse üç hafta kala görünür. Aşım
  uyarısı yalnız aşımda.
- **Kargo:** platform kargo taşımaz. Yazılım dokunuşları: kargo etiketi (Satıcı paneli K1), takip ve iade (Siparişlerim K2), kargo bağlantısı
  (paylaşılan entegrasyonlar). Geç teslimat şikâyeti EA kartıdır.
- Dönem: Kara Cuma 2012'de de vardır; I3 başlangıcı 2012'ye çekse de tablo geçerli.

### 3.8 Genel Bakış: pazaryeri blokları (PZ8; S5, S6, SG5, SG10, SG15)
**3.8.1 Düzen** (Faz 1 iskeletinin pazaryeri hâli; ayrı PAZARYERİ görünümü yok)
| Sütun | Bloklar |
|---|---|
| Sol, geniş | **Gelir raporu:** Komisyon, Üyelik, Premium satıcı, Öne çıkan ürünler; Toplam = MRR. Çizgi altı: Sezon geliri (bu ay tahsil edilen), Üyelik ayrıcalıkları gideri. Sütunlar: Bu ay (sürüyor), Geçen ay, Değişim, Pay. Her akım satırı kendi kolunu taşır (§3.5). 12 ay yığılmış sütun; Hafta/Ay anahtarı yalnız grafikte. |
| Orta | **Alıcılar:** toplam, üye, ücretsiz, üye oranı; 26 hafta. **Satıcılar:** aktif satıcı, Premium satıcı, bu ay katılan, bu ay ayrılan; satıcı çağrısı düğmesi. **Siparişler:** aylık sipariş, sepet ortalaması, aylık satış hacmi, satıcı başına aylık sipariş. |
| Sağ | **Kapasite** (Faz 1 ve mevsim satırı) · **Destek** |
- Uydurma ölçü yok: bulma oranı ve "etkin kesinti" gösterilmez; EN'de satış hacmi "Sales volume" (GMV kısaltması yok). Ortalama komisyon,
  kategori komisyonuyla birlikte EA'da anlam kazanır.
- Akım renkleri nötr mürekkep basamakları (`D_BAR_EMPH`, `D_BAR_FILL`, `D_INK_4`, `D_LINE_3`); hover satırı ve sütun parçasını birlikte yakar.
- `month_history` kapanış kaydına `streams` sözlüğü eklenir (`GameState.push_month_close`); eski kayıtta yoksa yok sayılır.
- B2B koltuk fiyatı gelir raporunda salt okunur görünür ve Satış'taki fiyat duruşuna bağlantı verir (SG15).

**3.8.2 Satış B2C özeti:** "{buyers} alıcı · {sellers} satıcı · MRR {mrr}" ve "Ürün'de aç".

**3.8.3 Satıcı çağrısı (SG5).** Satıcılar bloğunda "Satıcı çağrısı başlat / Start seller drive". Onay penceresi süreyi, burn payını, satıcı
girişi etkisini ve süren kampanyanın biteceğini söyler; çağrı `FinanceSystem.start_marketing_push(burn, growth, weeks, "sellers")`.
`GameState.marketing_push` `target` alanı kazanır (varsayılan "buyers": bugünkü kartlar değişmez); `marketing_growth_mult(target)`
(`finance_system.gd:180`) hedefe göre okur. Aynı anda tek itiş (bugünkü kural). Alıcı itişi kartlardan gelmeye devam eder.

**3.8.4 Kabul:** `--product-shot=live:overview_mkt|overview_mkt_listing|overview_mkt_bf` (normal, ilan dönemi, Kara Cuma haftası) TR/EN,
1920/1536; vaka `mkt_streams_sum_mrr` (`base` toplamı = `GameState.mrr`; falsifikasyon: bir akımı toplamdan çıkar → FAIL).

### 3.9 Rakipler ve Piyasa (PZ9; YM9)
- Piyasa devleri (Orinoco, Bidwell, Sindbad Holdings, Dealflock, Shopstead; `companies.json`, `noise: giant`) dev olarak kalır: Piyasa listesinde,
  Ürünleri'siz (Rakip Dünyası I2'nin ayrımı). Sindbad'ın halka arzı (105. hafta) Piyasa'nın mevcut akışından gelir.
- Pazaryerinin sektör rakipleri (`sector_slots.marketplace`, `RivalCatalog.NAMES.marketplace`, `rival_catalog.gd:41`) yeni ve taranmış parodi
  adlardır. Önerilen havuz Stitchery, Wishwell, Plushmark, Jetsam ve taranacak dört ad; Trendora çıkar (Türk devi parodisi yasak, Rakip Dünyası G
  kuralı). Soru 6.
- Rakip kademe tablosu 14 hat için, o gün yürürlükteki modelde yazılır: I2 indiyse `market_bar.json` ve takvim üreteci; inmediyse
  `rivals.json`'a pazaryeri bloğu, I2 onu ERP bloğuyla birlikte dönüştürür. Çıkışlar Kasım öncesinde Kampanya araçları ve Ödeme hatlarında yoğun.
- **Kabul:** `market_catalog_lint`; `--tab-shot=piyasa:sektor` pazaryeri sektör rakibiyle.

### 3.10 Eski türlerin silinmesi ve fikstür geçişi (PZ10; YM13)
- **UD8 mekanik:** `marketplace.json` ve alt tür kaydı eklenir; `run_probe.gd` B2C preset'leri ve `PRODUCT_NAMES` (`:61-76`), `_seed_b2c_world`,
  `_seed_b2c_neglect`; `main.gd` 7 yer (`live:b2c_mvp`, `live:b2c_live`, `--sales-shot=b2c_live` dahil); `sprint_probe.gd` 2 yer; §11.3'ün
  fikstür vakaları `marketplace`'e taşınır. Ekonomi hâlâ eski B2C'dir (kullanıcı × fiyat). Bütün vakalar yeşil.
- **UD9 silme ve şema kırılması:** `note_tool.json`, `video_clip.json`, `rivals.json` blokları, `NAMES` satırları, `sector_slots` satırları,
  `PROD_*_NOTE_TOOL_*` ve `PROD_*_VIDEO_CLIP_*` anahtarları (112 satır), `full_run_b2c_video`; §10'un kırılması; §11.3'ün emekli vakaları
  (onaylı liste).

## 4. Faz 3 · ERP derinliği

### 4.0 Atalet kuralı ve O22 sınırı (YM4, YM12)
- **Atalet:** kurulum hizmeti, Premium plan, modül eklentisi ve deneme ancak oyuncu ilgili kartı çıkarınca çalışır. Bot'un varsayılan politikası
  (`full_run*`) modül ve B2B gelir kartı planlamaz. Bu yüzden UD21-UD28 boyunca `--run-log=full_run:40:sim:<1..20>` `^PROBE` baytları O19 (ve
  indiyse O22) sonrası tabanla bire bir aynı kalır. Yeni preset `full_run_erp_deep` bu kartları kullanır ve protokole girer.
- UD29 (hat kolları ve B2B mevsimleri) ve UD30 (kartlar) atalet dışıdır: her ERP koşusunun dünyasını değiştirir, protokolle ölçülür (§11.2).
- **O22 sınırı:** Faz 3a O22'den bağımsızdır (modül alımı imzada, deneme adayı bugünkü faucet'ten). Faz 3b O22'nin yazılı arayüzünü ister: evre
  sayımı, `SalesFaucetSystem.spawn(star, source)` ile giriş evresi, temsilci kapanış kancası. O22'nin kodu ve PRD'si bu yazımda ağaçta yok.

### 4.1 Modüller (ER1; S9, SG7)
`erp.json` `groups[]`'a modül grubu girer. Demoda üç modül:
| Modül | K1 → K2 → K3 | K3 düğümü | İsteyen arketip | Açtığı sektör |
|---|---|---|---|---|
| `line_erp_purchasing` Purchasing / Satın Alma | Purchase requests / Satın alma talebi → Quote comparison / Teklif karşılaştırma → Reorder suggestions / Otomatik sipariş önerisi | analytics_engine | ops_cautious | yok |
| `line_erp_payroll` Payroll and staff / Bordro ve Personel | Staff records / Personel kartı → Payroll run / Bordro hesabı → Statutory filings / Resmî bildirim gönderimi | cicd | finance_brisk | health, textile |
| `line_erp_crm` Customer relations / Müşteri İlişkileri | Customer records / Müşteri kartı → Quotes and deals / Teklif ve fırsat takibi → Customer portal / Müşteri portalı | onboarding_flow | tech_exacting | media |
- Modüller kaliteye, MVP'ye ve değer okumasına (`product_value`) girmez; `usage_weight` ile altyapı yüküne girer (`InfraSystem.load_factor`).
  Destek akışı `usage_weight_total` okumaz (§3.2); modül desteğe dolaylı varır: yük çarpanı aşımı açar, aşım akışı
  `InfraSystem.report_inflow_multiplier` ile çarpar, yeni kodun girdisi `ProductLines.effort_of`'tur (`sprint_system.gd:971`). Doğrudan bir
  "kullanım payı toplamı okur" kancası yeni koddur ve bu PRD'de yoktur (genişliğin bedeli). Değerleri satışta doğar: eklenti geliri, arketip uyumu, genişleme, yeni sektör.
- `sprint.json`'a `modules` alanı (`markets: ["b2b"]`); `capabilities` hattı `kind` ile ayırır. B2B gelir kartlarına ayrı `revenue_b2b` alanı
  (görünen adı Gelir, durum cümleleri kendi anahtarlarıyla, §7).
- Arketiplere `wants_modules` ve `opens_sectors` (`sales_archetypes.gd:49,73,97`): modül canlı olunca arketipin sektör havuzu açtığı sektörleri de
  üretir. Bugün faucet 13 sektörün 10'unu üretiyor (`b2b_constants.gd:70-72`).
- Kademe adları dönem tarafsız; hiçbiri `ai` taşımaz. Raporlama gizli hattı demoda yok (EA, görünür kilitli).
- Hacim (hesap): 12 hat × 16 + 3 kart × 3 = 201 puan (bugün 144).

### 4.2 Gelir kalemleri (ER2-ER4)
`Customer` yeni `@export` alanları, varsayılan göç yerine geçer: `plan` ("standard"), `modules` ([]), `modules_offered` ([]), `from_trial`
(false), `impl_service` (false). `Customer.mrr` toplam kalır; `reflect_mrr` ve `add_mrr` reddi (`effects.gd:230-235`) değişmez. Kırılım
`SalesSystem.revenue_streams()`'in B2B kolundan türer: Abonelik, Modüller, Kurulum bedelleri (tek seferlik).
- **Modül eklentisi:** imzada (`SalesFinalizer._sign` → `SalesSystem.add_b2b_customer`, `sales_finalizer.gd:47`, `sales_system.gd:332`),
  Eklenti paketindeki her canlı modül için alım deterministik hash ile (temsilci koltuk hash'i kalıbı, `sales_rep_system.gd:208-232`): isteyen
  arketip 0,70, öbürü 0,15; hesabın MRR'ına `MODULE_ADDON_PER_SEAT × koltuk`. Bedeli modülün yükü ve destek payı.
- **Premium plan** (`cap_plan_premium`, `revenue_b2b`, efor 3): imzada alma 1★ 0,05 · 2★ 0,25 · 3★ 0,60 (ve paket katkısı); koltuk fiyatı ×1,35.
  Bedeli: Premium hesabın toleransı +6 ve destek kullanımı ×1,3 (daha çok bekler).
- **Kurulum hizmeti** (`cap_impl_service`, Traction'da açılır): yeni imzalarda kurulum bedeli = `IMPL_COVER × o hesabın beklenen onboarding servis
  gideri` (`ONBOARDING_MRR_MULT[faz] × MRR × onboarding süresi`, `infra_system.gd:92, 267-276`); canlıya geçişte `apply_one_time_income` ile. Gider
  karşılığıdır, kâr değildir: net onboarding gideri yarıya iner. Bootstrap'ta gider sıfır olduğu için kart orada kilitlidir. Bedeli toplantıda iğne
  −0,03 (bedel itiraz getirir). Denemeden gelen hesapta ×0,5.
- **Kabul:** vakalar `b2b_streams_sum_mrr`, `impl_fee_never_exceeds_cost` (falsifikasyon: üst sınırı kaldır → FAIL); yeni `Customer` alanlarının
  kayıt gidiş dönüşü.

### 4.3 Paketler: B2B (ER5; SG6)
- Satır = canlı modül; sütun = Standart pakette, Eklenti, Premium pakette (son sütun Premium plan çıkınca görünür). Yeni modül Eklenti başlar.
- Etkiler: Standart pakette → isteyen hesapta toplantı iğnesi +0,04 (en çok iki modül), gelir yok; Eklenti → gelir, isteyende +0,02; Premium
  pakette → Premium alma oranına modül başına +0,10 (tavan +0,30). İğne terimi `sales_meeting_system.gd:131-179` toplamına girer.
- Önizleme satırı: "Modül geliri ayda +$1.900 · 2★ toplantıda kazanma şansı +%4"; kaynak saf `SalesSystem.estimate_packaging(taslak)`. Not satırı:
  "Değişiklik yeni sözleşmelere işler".

### 4.4 Ücretsiz deneme (ER6; S8, SG6; soru 4)
- **Öneri:** demoda deneme, freemium EA. Erdem'e tek cümle: "B2B'de ücretsiz kullanıcı tek başına gelir getirmez; deneme firmalarının satış
  hattına adıyla akması gerçek ERP satışıdır; kalıcı ücretsiz kitle EA'da 'tek modül ücretsiz' olarak gelir."
- Açılış: `cap_trial` (`revenue_b2b`, efor 3); kilit Tablo İçe Aktarma (`line_erp_intake` K2) canlı: firma verisini kendisi yükler.
- **Adlı firmalar:** `GameState.erp_trials: Array[Dictionary]` `{name, star, archetype, until_day}`; ad faucet'in havuzundan,
  `ProspectRegistry.get_company_names` ile tekrarsız. Deneme bloğunda ve aday listesinde adlarıyla; aday kartında "Denemeden" etiketi.
- Haftalık giriş = `TRIAL_BASE × interest_now` (`support_system.gd:352`) × taban katı (üç eksen tabanı tutuyorsa 1,0, yoksa 0,5;
  `product_read.gd:111-131`) × mevsim. Yıldız karışımı 1★ 0,75 · 2★ 0,25.
- **Kol: süre 2 ya da 4 hafta** (Deneme bloğunda). 2 hafta → bitişte 0,25'i aday; 4 hafta → 0,35'i aday, yük ve destek iki kat süre.
- Bitişte aday aynı adla `SalesFaucetSystem.spawn(star, "trial")` (`sales_faucet_system.gd:199`); tik tavanı (`sales_constants.gd:19-38`) sayılır.
  Faz 3a'da aday ömrü 2 hafta (normal 1), iğne +0,06. Otomatik dönüşüm yok: imza kurucunun toplantısı ya da temsilci.
- Hesap olunca `from_trial`; Onboarding penceresi (O19) 1 hafta kısalır; kurulum bedeli ×0,5.
- Bedel: deneme başına 5 koltuk `served_count`'a, kullanım payı destek akışına, koltuk başına servis $8 (`infra_system.gd:88`).
- B2B'de ücretsiz ve ücretli ayrımı: Hesaplar bloğunda "Ücretli {paid} hesap · Denemede {trial} firma".
- **Kabul:** vaka `trial_to_prospect_named`; Deneme bloğu çekimi.

### 4.5 ERP hat kolları ve B2B mevsimleri (ER7; SG3, S3)
| Hat | Kol |
|---|---|
| ledger (Defter) | Yıl sonu destek yükü: Aralık'ın son 2 ve Ocak'ın ilk 2 haftası bildirim ×1,5; K2 canlıysa ×1,2 |
| invoicing (Fatura) | K2'nin adı "E-Invoicing / e-Fatura" olur (bugün "Toplu Fatura"); e-Fatura dönemine hazır olmak budur |
| stock (Stok) | ops_cautious toplantı uyumu |
| cashflow (Nakit Akışı) | finance_brisk toplantı uyumu |
| intake (Veri girişi) | tech_exacting toplantı uyumu; K2 denemeyi açar ve canlıya geçiş kayması şansını 0,20 indirir |
- Arketip uyumu sıfır toplamlıdır: ürün uyumu teriminin `FIT_LEVER_SHARE` kadarı istenen hattın kademesine göre dağıtılır, ortalaması bugünkü
  uyuma eşittir. Kabul: B2B kazanma oranı tabanın ±%10'unda.
- `seasons.json` B2B satırları: **e-Fatura son günü** (1. yılın sonu; invoicing K2 canlıysa Ocak'ta 4 hafta aday akışı ×1,5; değilse hesapların
  `trust_offset`'i −3 ve `pain_feature_id` invoicing K2); **aday mevsimi** (Ocak ×1,3, Aralık ×0,7; `lead_rate_per_week`,
  `sales_faucet_system.gd:120`); **yıl sonu destek** (yukarıda). Gerçek eşik ya da tutar yazılmaz; metin dönem tarafsızdır. Duyuru 36. haftada
  haber bandına tek satırdır (karar değil).
- Bunlar her ERP koşusunu değiştirir: protokolle ölçülür (§11.2).

### 4.6 Genel Bakış B2B ve genişleme (ER8, ER9; SG10)
- Orta sütun: **Hesaplar** (Faz 1 ve ücretli/denemede satırı) · **Deneme** (denemede, bu ay adaya dönen, bu ay denemeden imza, süre kolu) ·
  **Modüller** (modül başına "6/11 hesap · ayda $1.240").
- Sağ sütun: **Kayıplar** (bu ay kaybedilen MRR, son üç neden: Eksik işlev, Destek, Memnuniyet); kayıt `GameState.b2b_churn_log` (en çok 12;
  `_churn` yazar, `b2b_sales_system.gd:207`). Son kaybın tek cümlesi Source Serif 4 ile.
- Gelir raporu dip satırı: "Mevcut hesaplardan büyüme (3 ay) %104" = üç ay önce var olan hesapların bugünkü MRR'ı / o günkü MRR'ları;
  `GameState.b2b_mrr_snapshots` (3 ay, `month_ended`'da yazılır). NRR kısaltması ekranda yok.
- Hesap tablosu Satış portföyünde kalır; plan ve modül sütunları oraya girer.
- **Genişleme modül başına yeniden silahlanır:** tek `last_expansion_day` mandalı (`customer.gd:54`, `b2b_sales_system.gd:202`) yerine
  `modules_offered`. Eklenti paketli yeni modül canlıya çıkınca isteyen sağlıklı ve olgun hesaplar `customer.expansion_module` kartını alır
  (`customer_mrr_delta` fiili). Mevcut hesaplardan büyümenin %100'ü geçmesinin yolu budur.

### 4.7 Faz 3b · O22'den sonra
- Deneme adayı O22'nin Demo evresinden girer (Keşif atlanır); Faz 3a yedeği (ömür 2 hafta, iğne +0,06) kalkar.
- Modül alımı istenirse Teklif evresine taşınır; taşınmazsa imzada kalır. Karar O22 PRD'siyle.
- **Kabul:** O22'nin kendi kabul tablosu ve deneme adayının evre girişi vakası.

## 5. Olaylar

### 5.1 Kurallar
- Motor v3 main'de (`5933acc`): makullük bloğu ve `delay_weeks` zorunlu; `bash tools/plausibility_run.sh` `fails=0`; `--event-lint` temiz.
- Sahibin seçenek kuralları (2026-10-08): bedava çıkış yok; bedel olayın öznesine düşer; koşul hikâyeye uyar; tek kişilik olayda sprint saati
  yok. Memnuniyet tek başına kalıcı bedel değildir (`satisfaction_delta` bir tikte kayan hedefe çekilir); kalıcı iz `trust_offset`, kitle, satıcı,
  marka ya da nakittir.
- Metin kartın `text.en` ve `text.tr` bloklarındadır; gerçek kurum, tutar, sekme ya da düğüm adı yok; "TR/EN onay bekliyor". Frank satırı yalnız
  taslak.

### 5.2 Fiiller
| Fiil | Ne yapar | Yazdığı seam | Commit |
|---|---|---|---|
| `seller_delta {n, pct}` | satıcı sayısını değiştirir (n ya da pct) | `MarketplaceSystem.add_sellers` | UD17 |
| `commission_promo {points, weeks}` | geçici komisyon indirimi; satıcı girişi ve mevsim payı artar | `MarketplaceSystem.start_promo` | UD17 |
| `season_mod {orders_pct, load_pct}` | sıradaki mevsimin sipariş ve yük katı | `SeasonCalendar.set_mod` | UD17 |
| `trust_delta {amount}` | hesabın `trust_offset`'i | `CustomerRegistry.set_trust_offset` (`customer_registry.gd:219`) | UD20 |
- `convert_audience` ve `open_paid_tier` yürütücüsüz (`effects.gd:72`; çipleri `chips.gd:35,124`): UD6'da silinir (fiil listesi, çipler, lint
  listeleri, sözlük).
- Taslağın `capacity_add` fiili yazılmaz: kart seçenekleri düğmenin yapamadığını yapar.
- Yeni seam'ler (`scripts/events/seams/seams_market.gd`): `pazar.sellers`, `pazar.commission`, `pazar.weeks_to_season`, `pazar.orders_month`,
  `pazar.listing_period`.

### 5.3 Demo kartları
| Kart | Faz | İş |
|---|---|---|
| `world.season_prep` (yeni) | 2 | Kara Cuma'dan 3 hafta önce, yalnız pazaryeri. (a) Satıcılarla ortak indirim: `commission_promo` −3 puan, 3 hafta (gelir iner, satıcı ve sipariş artar). (b) Kampanyayı pazartesiye uzat: `season_mod` sipariş +%15, yük +%15. (c) Sipariş kotası: `season_mod` sipariş −%20, yük −%30. Kapasite almak seçenek değildir, düğme yapar. |
| `customer.counterfeit_listing` (yeni) | 2 | Satıcı ≥ 80; şans Satıcı başvurusu K2 ile yarıya iner. (a) Satıcıyı kapat: `seller_delta` −1, marka −1. (b) Belge doğrulamayı herkese zorunlu yap (K2 ister; yoksa kilit gerekçesi): `seller_delta` −%3, marka +1. (c) Ürünü kaldır, satıcıyı uyar: `audience_delta` −%2, marka −2. |
| `customer/b2c_refunds` (mekanik) | 2 | Alıcı ile satıcı anlaşmazlığı; şans Siparişlerim kolundan. (a) Platform öder: `add_cash` eksi. (b) Satıcıdan kes: `seller_delta` −%3. (c) Alıcıya bırak: `audience_delta` −%3 ve marka −1 (bedel bugün de kalıcıdır: `policy` seçeneği `satisfaction_delta` −5 ve `add_brand` −1 taşır, ACIK_KARARLAR 97 de "politika −5 ve marka −1" der; değişen `audience_delta` −%3'ün gelmesi, memnuniyet vuruşunun ona taşınması ve kartta bugün olmayan satıcı seçeneğinin (b) eklenmesidir). |
| `rival/shutdown_notice` (mekanik) | 2 | Küçük bir pazaryeri kapanıyor: `seller_delta` +%15 (bugünkü kitle artışının yerine). |
| `world/b2c_creator_feature`, `world/app_placement`, `world/newsletter_slot`, `funding/portfolio_vendor` ve `_trial`, `product/launch_leak`, `team/wiped_table` | 2 | Yalnız metin: alışveriş, alıcı ve satıcı dili. launch_leak: başkasının adresi ve siparişleri görünüyor; wiped_table: çift açılmış satıcı hesapları. |
| `product/paid_tier` | 2 | Metin Üyelik'e döner; Frank satırı taslak. |
| `outage` | 2 | Mevsim koşulu eklenir (Kara Cuma haftası ağırlığı). |
| `customer.einvoice_ask` (yeni) | 3a | 40. haftadan sonra, invoicing K2 canlı değilken, büyük bir hesap hazır olup olmadığını sorar. (a) Tarih ver: `promise_create` invoicing K2'ye, yıl sonuna kadar. (b) Bir entegratöre yönlendir: `add_cash` eksi, `trust_delta` +1. (c) Hazır değiliz de: `trust_delta` −4. |
| `customer.golive_slip` (yeni) | 3a | Onboarding'deki hesapta canlıya geçişe 1 hafta kala; şans 0,45, intake K2 ile −0,20, Destek masası boşsa +0,15. (a) İki kişi bir hafta kuruluma: `productivity_mod` ekip −%15, 1 hafta. (b) Ertele ve tarih ver: `promise_create` 2 hafta, `trust_delta` −2. (c) Dış danışman: `add_cash` eksi, yıldıza göre sabit tutar. |
| `customer.data_migration` (yeni) | 3a | 2★ ve üstü yeni imza. (a) Kendileri taşısın (intake K2 ister; yoksa kilit gerekçesi): `trust_delta` −1. (b) Biz taşırız: `productivity_mod` −%10, 2 hafta; `trust_delta` +2. (c) Yalnız açılış bakiyeleri: `trust_delta` −3. |
| `customer.expansion_module` (yeni) | 3a | §4.6; seçenek yapısı mevcut `customer.expansion` kartınınki, tutar modül eklentisi. |
- Faz 3 kartları atalet dışıdır (UD30) ve protokolle ölçülür.

## 6. Erken Erişim listesi (demo dışı)
- **Pazaryeri:** kategori başına komisyon ve ortalama komisyon ölçüsü; Ocak durgunluğu (negatif mevsim seam'i) ve küçük mevsimler; Shopstead'in
  satıcıları kendi mağazasına çekmesi; satıcı memnuniyeti kaydı; çapa satıcı adayları (Satış sekmesinin B2C hâli, mevcut aday ve toplantı
  motoruyla, komisyon pazarlığın konusu); kartlar `customer.commission_letter`, `customer.carrier_delay`, `rival.deal_site_sellers` (Dealflock'un
  2012 çöküşü), ödeme sahtekârlığı kartı (Ödeme K3). Platform lojistiği hiçbir kapsamda yok (S2).
- **ERP:** Üretim Planlama ile Servis ve Proje modülleri (Premium plana özel); Raporlama hattı (görünür kilitli); freemium ("tek modül ücretsiz");
  1★ için kendi kendine satın alma; destek sözleşmesi; yıllık sözleşme; iş ortağı kanalı; `customer.custom_module`; `customer.year_end_close`
  ((b) seçeneği "Kapanışı ocağa sarkıt": hesaba `trust_delta` −2, ekibin morali korunur); ayrıntılı kayıp nedenleri; çoklu şirket.
- **Genel:** Müşteri Başarısı sekmesi ve müşteri politikaları (demoda aynı kararlar kart ve özellik olarak var; ikinci anahtar saçma olurdu); sağlayıcı
  değiştirme.

## 7. Metinler
Hepsi yeni CSV anahtarıdır ya da değeri değişir; hepsi **TR/EN onay bekliyor**. Önce EN, sonra TR. Kart metinleri CSV'ye değil kartın kendi
bloklarına yazılır. Yeni terimler sözlüğe satır olarak girer (Pazaryeri, Satış hacmi, Sepet ortalaması, Komisyon, Üyelik, Hakediş, Premium satıcı,
Öne çıkan ürünler, Kara Cuma, Yılbaşı, Mevcut hesaplardan büyüme, e-Fatura). "Premium" soru 5'e bağlıdır; hayır denirse TR değerleri
"Profesyonel satıcı planı" ve "Kapsamlı plan" olur. "Onboarding" sözlüğe O19 ile girer. Mevcut `SYS_CANCEL`, `SALES_B2C_CONVERSION`,
`SALES_B2C_PLAN_HINT`, `PRODUCT_LOCKED_NODE` ve Finans gider anahtarları yeniden kullanılır.

**Faz 1**
| Anahtar | EN | TR |
|---|---|---|
| `PRODUCT_VIEW_OVERVIEW` | Overview | Genel Bakış |
| `PRODUCT_VIEW_OVERVIEW_LOCK` | Opens when v1.0 ships | v1.0 yayınlanınca açılır |
| `PRODUCT_OV_REVENUE` | Revenue report | Gelir raporu |
| `PRODUCT_OV_COL_THIS_MONTH` | This month (running) | Bu ay (sürüyor) |
| `PRODUCT_OV_COL_LAST_MONTH` | Last month | Geçen ay |
| `PRODUCT_OV_COL_CHANGE` | Change | Değişim |
| `PRODUCT_OV_COL_SHARE` | Share | Pay |
| `PRODUCT_OV_TOTAL` | Total | Toplam |
| `PRODUCT_OV_CHART_WEEK`, `_MONTH` | Week, Month | Hafta, Ay |
| `PRODUCT_STREAM_SUBSCRIPTION` | Subscriptions | Abonelik |
| `PRODUCT_OV_USERS` | Users | Kullanıcılar |
| `PRODUCT_OV_PAYING` | Paying | Ücretli |
| `PRODUCT_OV_FREE` | Free | Ücretsiz |
| `PRODUCT_OV_ACCOUNTS` | Accounts | Hesaplar |
| `PRODUCT_OV_PHASES` | Onboarding {onboarding} · Active {active} · At risk {risk} | Onboarding {onboarding} · Aktif {active} · Risk {risk} |
| `PRODUCT_OV_AVG_SATISFACTION` | Avg. satisfaction | Ort. memnuniyet |
| `PRODUCT_OV_PORTFOLIO` | Portfolio | Portföy |
| `PRODUCT_OV_LOSSES` | Losses | Kayıplar |
| `PRODUCT_OV_LOST_ACCOUNTS` | Accounts lost this month | Bu ay kaybedilen hesap |
| `PRODUCT_OV_CAPACITY` | Capacity | Kapasite |
| `PRODUCT_OV_LOAD` | Load | Doluluk |
| `PRODUCT_OV_UNITS` | {units} units · {provider} | {units} birim · {provider} |
| `PRODUCT_OV_BILL` | Server bill | Sunucu faturası |
| `PRODUCT_OV_SERVICE` | Service cost | Servis gideri |
| `PRODUCT_OV_UNIT_DELTA` | {amount} a month | ayda {amount} |
| `PRODUCT_OV_MODE_AUTO`, `_MANUAL` | Auto, Manual | Otomatik, Elle |
| `PRODUCT_OV_SUPPORT` | Support | Destek |
| `SALES_B2C_SUMMARY` | {users} users · {paying} paying · MRR {mrr} | {users} kullanıcı · {paying} ücretli · MRR {mrr} |
| `SALES_OPEN_IN_PRODUCT` | Open in Product | Ürün'de aç |

**Faz 2**
| Anahtar | EN | TR |
|---|---|---|
| `PROD_TYPE_MARKETPLACE_NAME` | Marketplace | Pazaryeri |
| `PROD_TYPE_MARKETPLACE_CATEGORY` | Online retail | Çevrimiçi perakende |
| `PROD_TYPE_MARKETPLACE_DESC` | Buyers · sellers · orders on one platform. | Alıcı · satıcı · sipariş tek platformda. |
| `PROD_TYPE_MARKETPLACE_TRADEOFF` | Buyers go where the sellers are and sellers go where the buyers are. You open with an empty shop window. | Alıcı satıcının olduğu yere, satıcı alıcının olduğu yere gider. Boş bir vitrinle açıyorsun. |
| `PROD_TYPE_MARKETPLACE_BET` | Small shops cannot reach buyers on their own. Give them one door and take a share of every sale. | Küçük mağaza alıcıya tek başına ulaşamıyor. Ona tek bir kapı aç, her satıştan pay al. |
| `PROD_TYPE_MARKETPLACE_PITCH` | The market where every small shop finds its buyer. | Her küçük mağazanın alıcısını bulduğu çarşı. |
| `PROD_LINE_MKT_*` (10), `PROD_STEP_MKT_*_K1..K3` (30) | §3.1 tabloları | §3.1 tabloları |
| `PROD_STEP_MKT_*_DESC` (30) | UD8'de, mevcut `_DESC` kaydıyla | aynı |
| Paylaşılan hat betimleri, pazaryeri (4) | ör. Accounting and carrier links | ör. Muhasebe ve kargo bağlantıları |
| `PRODUCT_AREA_BUYER`, `_SHORT` | Buyer side, Buyers | Alıcı tarafı, Alıcı |
| `PRODUCT_AREA_BUYER_NONE` | Buyers have nothing to shop with yet | Alıcının alışveriş edeceği bir şey henüz yok |
| `PRODUCT_AREA_BUYER_WEAK` | Buyers struggle to find and pay | Alıcı bulmakta ve ödemekte zorlanıyor |
| `PRODUCT_AREA_BUYER_ENOUGH` | Buyers find, pay and track without trouble | Alıcı sorunsuz buluyor, ödüyor ve izliyor |
| `PRODUCT_AREA_BUYER_STRONG` | Buyers tell their friends where they shop | Alıcı nereden aldığını çevresine anlatıyor |
| `PRODUCT_RESEARCH_VOICE_BUYER` | The shoppers we talked to want to know what happens after they pay | Görüştüğümüz alıcılar ödedikten sonra ne olacağını bilmek istiyor |
| `PRODUCT_AREA_SELLER`, `_SHORT` | Seller side, Sellers | Satıcı tarafı, Satıcı |
| `PRODUCT_AREA_SELLER_NONE` | Sellers have no tools yet | Satıcının aracı henüz yok |
| `PRODUCT_AREA_SELLER_WEAK` | Sellers struggle to list and get paid | Satıcı ürün yüklemekte ve parasını almakta zorlanıyor |
| `PRODUCT_AREA_SELLER_ENOUGH` | Sellers list, sell and get paid without trouble | Satıcı sorunsuz yüklüyor, satıyor ve parasını alıyor |
| `PRODUCT_AREA_SELLER_STRONG` | Sellers bring other sellers | Satıcı başka satıcıları getiriyor |
| `PRODUCT_RESEARCH_VOICE_SELLER` | The sellers we talked to want to know when the money arrives | Görüştüğümüz satıcılar paranın ne zaman geleceğini bilmek istiyor |
| `PRODUCT_CAP_PAID_PLAN` (değer değişir) | Membership | Üyelik |
| `PRODUCT_CAP_SELLER_PREMIUM` | Premium seller plan | Premium satıcı planı |
| `PRODUCT_CAP_FEATURED` | Featured listings | Öne çıkan ürünler |
| `PRODUCT_VIEW_PACKAGES` | Packages | Paketler |
| `PRODUCT_VIEW_PACKAGES_LOCK` | Opens with the first paid plan | İlk ücretli planla açılır |
| `PRODUCT_PACK_FREE`, `_PREMIUM` | Free, Premium | Ücretsiz, Premium |
| `PRODUCT_PACK_SELLERS` | Seller tools | Satıcı araçları |
| `PRODUCT_PACK_MEMBERSHIP` | Membership perks | Üyelik ayrıcalıkları |
| `PRODUCT_APPLY` | Apply | Uygula |
| `PRODUCT_PERK_DEALS` | Member deals | Üyeye özel fırsatlar |
| `PRODUCT_PERK_EARLY` | Early access to sales | Kampanyaya erken erişim |
| `PRODUCT_PERK_RETURNS` | Fast returns | Hızlı iade |
| `PRODUCT_PERK_COUPON` | Shipping coupon | Kargo kuponu |
| `PRODUCT_STREAM_COMMISSION` | Commission | Komisyon |
| `PRODUCT_STREAM_MEMBERSHIP` | Membership | Üyelik |
| `PRODUCT_STREAM_PREMIUM_SELLERS` | Premium sellers | Premium satıcılar |
| `PRODUCT_STREAM_FEATURED` | Featured listings | Öne çıkan ürünler |
| `PRODUCT_STREAM_SEASON`, `FIN_ONETIME_SEASON` | Seasonal sales | Sezon geliri |
| `PRODUCT_STREAM_PERKS`, `FIN_BURN_PERKS` | Member perks | Üyelik ayrıcalıkları |
| `PRODUCT_ADS_OFF`, `_LOW`, `_MID`, `_HIGH` | Off, Low, Medium, High | Kapalı, Az, Orta, Çok |
| `PRODUCT_OV_BUYERS` | Buyers | Alıcılar |
| `PRODUCT_OV_MEMBERS` | Members | Üye |
| `PRODUCT_OV_MEMBER_SHARE` | Member share | Üye oranı |
| `PRODUCT_OV_SELLERS` | Sellers | Satıcılar |
| `PRODUCT_OV_ACTIVE_SELLERS` | Active sellers | Aktif satıcı |
| `PRODUCT_OV_PREMIUM_SELLERS` | Premium sellers | Premium satıcı |
| `PRODUCT_OV_JOINED`, `_LEFT` | Joined this month, Left this month | Bu ay katılan, Bu ay ayrılan |
| `PRODUCT_OV_ORDERS` | Orders | Siparişler |
| `PRODUCT_OV_ORDERS_MONTH` | Orders a month | Aylık sipariş |
| `PRODUCT_OV_BASKET` | Avg. basket | Sepet ortalaması |
| `PRODUCT_OV_VOLUME` | Sales volume a month | Aylık satış hacmi |
| `PRODUCT_OV_ORDERS_PER_SELLER` | Orders per seller a month | Satıcı başına aylık sipariş |
| `PRODUCT_OV_OFF_PLATFORM` | Off platform | Platform dışı |
| `PRODUCT_OV_COMMISSION_LOCK` | Commission starts when Checkout and Payouts are live | Komisyon, Ödeme ve Hakediş canlı olunca başlar |
| `PRODUCT_OV_SEASON_AHEAD` | {season} in {weeks} weeks · expected load {pct}% | {season} {weeks} hafta sonra · beklenen doluluk %{pct} |
| `SEASON_BLACK_FRIDAY`, `SEASON_YEAR_END` | Black Friday, Year end | Kara Cuma, Yılbaşı |
| `PRODUCT_SELLER_DRIVE` | Start seller drive | Satıcı çağrısı başlat |
| `PRODUCT_SELLER_DRIVE_CONFIRM` | {weeks} weeks · burn +{pct}% · seller signups +{growth}%. A running campaign ends. | {weeks} hafta · burn +%{pct} · satıcı başvurusu +%{growth}. Süren kampanya biter. |
| `SALES_MKT_SUMMARY` | {buyers} buyers · {sellers} sellers · MRR {mrr} | {buyers} alıcı · {sellers} satıcı · MRR {mrr} |
| `PRODUCT_LEVER_MATCH` | Matches +{pct}% | Eşleşme +%{pct} |
| `PRODUCT_LEVER_ORDER_RATE` | Orders per buyer +{pct}% | Alıcı başına sipariş +%{pct} |
| `PRODUCT_LEVER_DISPUTES` | Return disputes {pct}% fewer | İade anlaşmazlığı %{pct} daha az |
| `PRODUCT_LEVER_BASKET` | Avg. basket +{pct}% | Sepet ortalaması +%{pct} |
| `PRODUCT_LEVER_ACTIVATION` | New sellers active in week one: {pct}% | İlk hafta aktifleşen yeni satıcı %{pct} |
| `PRODUCT_LEVER_SEASON` | Share of campaign weeks: {pct}% | Kampanya haftalarından alınan pay %{pct} |
| `PRODUCT_LEVER_SELLER_LOSS` | Sellers leaving {pct}% fewer | Ayrılan satıcı %{pct} daha az |
| `PRODUCT_LEVER_ORDER_CAP` | A seller handles {n} orders a month | Satıcı ayda {n} sipariş yetiştirir |
| `PRODUCT_LEVER_SIGNUPS` | Seller signups +{pct}% | Satıcı başvurusu +%{pct} |
| `PRODUCT_LEVER_COMMISSION_GATE` | Opens commission | Komisyonu açar |

**Faz 3**
| Anahtar | EN | TR |
|---|---|---|
| `PROD_LINE_ERP_PURCHASING`, `_PAYROLL`, `_CRM` ve kademeleri (9, `_DESC` ile) | §4.1 tablosu | §4.1 tablosu |
| `PROD_STEP_ERP_INVOICING_K2` (değer değişir) | E-Invoicing | e-Fatura |
| `PRODUCT_AREA_MODULES`, `_SHORT` | Modules | Modüller |
| `PRODUCT_AREA_MODULES_NONE` | No modules yet | Henüz modül yok |
| `PRODUCT_AREA_MODULES_WEAK` | A module is live, few accounts use it | Bir modül canlı, kullanan hesap az |
| `PRODUCT_AREA_MODULES_ENOUGH` | Accounts use the modules | Hesaplar modülleri kullanıyor |
| `PRODUCT_AREA_MODULES_STRONG` | Accounts ask for the next module | Hesaplar sıradaki modülü soruyor |
| `PRODUCT_RESEARCH_VOICE_MODULES` | The companies we talked to run payroll and purchasing in other tools | Görüştüğümüz firmalar bordroyu ve satın almayı başka araçlarda yürütüyor |
| `PRODUCT_AREA_REVENUE_B2B`, `_SHORT` | Revenue | Gelir |
| `PRODUCT_AREA_REVENUE_B2B_NONE` | One plan, one price | Tek plan, tek fiyat |
| `PRODUCT_AREA_REVENUE_B2B_WEAK` | Paid extras are open, few take them | Ücretli ekler açık, alan az |
| `PRODUCT_AREA_REVENUE_B2B_ENOUGH` | Plans and services are open | Planlar ve hizmetler açık |
| `PRODUCT_AREA_REVENUE_B2B_STRONG` | Accounts move up to Premium | Hesaplar Premium'a geçiyor |
| `PRODUCT_RESEARCH_VOICE_REVENUE_B2B` | The companies we talked to ask what a setup would cost | Görüştüğümüz firmalar kurulumun neye mal olacağını soruyor |
| `PRODUCT_CAP_PLAN_PREMIUM` | Premium plan | Premium plan |
| `PRODUCT_CAP_IMPL_SERVICE` | Setup service | Kurulum hizmeti |
| `PRODUCT_CAP_TRIAL` | Free trial | Ücretsiz deneme |
| `PRODUCT_LOCKED_PHASE` | Opens in {phase} | {phase} evresinde açılır |
| `PRODUCT_PACK_STANDARD`, `_ADDON`, `_IN_PREMIUM` | In Standard, Add-on, In Premium | Standart pakette, Eklenti, Premium pakette |
| `PRODUCT_PACK_NOTE` | Changes apply to new contracts | Değişiklik yeni sözleşmelere işler |
| `PRODUCT_STREAM_MODULES`, `_SETUP` | Modules, Setup fees | Modüller, Kurulum bedelleri |
| `PRODUCT_OV_TRIALS` | Trials | Deneme |
| `PRODUCT_OV_PAID_TRIAL` | {paid} paying accounts · {trial} on trial | Ücretli {paid} hesap · Denemede {trial} firma |
| `PRODUCT_OV_TRIAL_TO_LEAD` | Became leads this month | Bu ay adaya dönen |
| `PRODUCT_OV_TRIAL_SIGNED` | Signed from trial this month | Bu ay denemeden imza |
| `PRODUCT_OV_TRIAL_LENGTH` | {weeks} weeks | {weeks} hafta |
| `PRODUCT_OV_MODULES` | Modules | Modüller |
| `PRODUCT_OV_ADOPTION` | {n} of {total} accounts · {amount} a month | {n}/{total} hesap · ayda {amount} |
| `PRODUCT_OV_GROWTH_EXISTING` | Growth from existing accounts (3 mo) | Mevcut hesaplardan büyüme (3 ay) |
| `PRODUCT_OV_LOST_MRR` | MRR lost this month | Bu ay kaybedilen MRR |
| `CHURN_REASON_FEATURE`, `_SUPPORT`, `_SATISFACTION` | Missing feature, Support, Satisfaction | Eksik işlev, Destek, Memnuniyet |
| `SALES_LEAD_FROM_TRIAL` | From trial | Denemeden |
| `FIN_ONETIME_SETUP` | Setup fee | Kurulum bedeli |
| `SEASON_EINVOICE` | E-invoicing deadline | e-Fatura son günü |
| `NEWS_EINVOICE_ANNOUNCE` | Paper invoices end with the year; e-invoicing becomes mandatory | Kâğıt fatura yıl sonunda bitiyor; e-Fatura zorunlu oluyor |
| `PRODUCT_LEVER_FIT` | Better fit with {archetype} companies | {archetype} firmalarla uyum artar |
| `PRODUCT_LEVER_YEAR_END` | Year end support load {pct}% lower | Yıl sonu destek yükü %{pct} daha az |
| `PRODUCT_LEVER_EINVOICE` | Ready for e-invoicing | e-Faturaya hazır |
| `PRODUCT_LEVER_GOLIVE` | Customer launches slip less often | Müşteride canlıya geçiş daha az kayar |

## 8. Tasarım sabitleri (hepsi onay bekliyor)
Faz 2 ekonomisinin "sim" işaretli değerleri §3.0 simülasyonunun çıktısıdır; tablodaki başlangıç noktasıdır. Ayar penceresi ±%50.
| Sabit | Değer | Yer |
|---|---|---|
| `infra_auto` varsayılanı | true (Otomatik) | GameState bayrağı |
| SELLER_SEED | 10 | MarketplaceSystem |
| SELLER_HALF | 40 | find_rate yarı doygunluğu |
| LIQ_MIN, LIQ_MAX | 0,6, 1,5 | likidite çarpanı sınırları (MVP'de 1,0) |
| F (ücretsiz alıcının aylık siparişi) | 1,0 | taslağın haftalık 0,23'ü |
| MEMBER_ORDER_MULT | 1,5 | |
| AOV | 45 | |
| Komisyon | varsayılan %10, aralık %0-25, adım 1, C_REF %10, `c_katı` 0,4-1,8 | |
| S_BASE, S_DEMAND, BPS_CAP | sim (başlangıç S_BASE taslağın saatlik 0,015'i; BPS_CAP 300 alıcı/satıcı) | satıcı girişi |
| S_CHURN, S_CHURN_LOW, OPS_FLOOR | sim (OPS_FLOOR doğal noktanın dışında; taslağın 8'i doğal noktadaydı) | satıcı çıkışı |
| PAYWALL_DRAG_S, p_s0 | 0,4, 2/3 | |
| PREM_BASE, PREM_FEE_REF, Premium ücreti | sim; hedef varsayılan oyunda gelirin %10-20'si | |
| MEMBER_BASE, MEMBER_FEE_REF, Üyelik ücreti, aralık | 0,04, 9, 9, 1-30 | |
| Ayrıcalık ağırlıkları (fırsat, erken, iade, kupon) | 0,25, 0,15, 0,20, 0,50 | |
| Ayrıcalık bedelleri | `c_katı` ×0,97; ücretsizin mevsim siparişi ×0,95; RETURN_SHARE 0,08 × RETURN_COST $6; COUPON_COST $3 | |
| Erken erişim eki | üye payı +%20, mevsimden önceki 3 hafta | |
| ADS_RATE (Az, Orta, Çok) | satış hacminin %1, %2,5, %4 | |
| ADS_ORDER_DRAG, ADS_GROWTH_DRAG | %2, %5, %10; %1, %3, %6 | |
| Öne çıkan ürün kilidi | Kampanya araçları K2 ve 150 satıcı | |
| Hat kolları | §3.4 tablosu | |
| ORDER_CAP (Satıcı paneli K0-K3) | 20, 60, 150, 400 sipariş/ay | |
| SELLER_LOAD_EQ, SELLER_SUPPORT_DIV | 10, 150 | InfraSystem, SupportSystem |
| Mevsimler | §3.7 tablosu | `seasons.json` |
| Satıcı çağrısı | 4 hafta, burn %15, satıcı girişi +%40 | `marketing_terms` sınırları içinde |
| MARKET_TOTAL_GMV | 15.000.000 | `rival_catalog.gd` |
| mvp_min_per_side | 1 | `sprint.json` |
| QUALITY_AXES marketplace | inn 1,0, sta 1,3, exp 1,2 | `product_catalog.gd` |
| Bot stratejileri | §3.5.3 | `run_probe.gd` (harness) |
| MODULE_ADDON_PER_SEAT, MODULE_TAKE | $8; 0,70 isteyen, 0,15 öbürü | |
| MODULE_FIT (Standart, Eklenti; en çok 2 modül) | +0,04, +0,02 | |
| PREMIUM_PRICE_MULT, PREMIUM_TAKE (1★, 2★, 3★) | 1,35; 0,05, 0,25, 0,60 | |
| PACK_PREMIUM_TAKE | modül başına +0,10, tavan +0,30 | |
| PREMIUM_TOLERANCE_ADD, PREMIUM_SUPPORT_MULT | +6, ×1,3 | |
| IMPL_COVER, IMPL_NEEDLE, denemeden | 0,5, −0,03, ×0,5; Traction'da açılır | |
| TRIAL_BASE, TRIAL_TO_LEAD | haftada 3; 0,25 (2 hafta), 0,35 (4 hafta) | |
| TRIAL_STAR_MIX, TRIAL_SEATS, TRIAL_FIT, aday ömrü | 0,75/0,25, 5, +0,06, 2 hafta | |
| Denemeden gelen hesap | Onboarding penceresi −1 hafta, kurulum ×0,5 | |
| FIT_LEVER_SHARE | 0,25 (sıfır toplamlı) | |
| GOLIVE_SLIP (taban, intake K2, boş masa) | 0,45, −0,20, +0,15 | |
| SEASON_LEAD (Ocak, Aralık), YEAR_END_SUPPORT (taban, ledger K2) | ×1,3, ×0,7; ×1,5, ×1,2 | `seasons.json` |
| EINVOICE | aday akışı ×1,5, 4 hafta; `trust_offset` −3; duyuru 36. hafta | |
| Mevcut hesaplardan büyüme penceresi | 3 ay | |
| Kapı: akım payı tavanı | %65 (varsayılan, 90. hafta) | §11.2 |
| Kapı: stratejiler | 4 stratejinin en az 3'ü Seri A'ya 70-95. haftada, yayılım en çok 12 hafta | §11.2 |
| Kapı: ağaç | varsayılan oyunda 104. haftada açık ağaç en çok %60 | §11.2 |
| Kapı: B2B kazanma oranı | tabanın ±%10'u | §11.2 |

## 9. Commit sırası ve bağımlılıklar

### 9.1 Uçuştaki işler ve çakışan dosyalar (YM14)
| İş | Durum (HEAD `a4db89a`) | Bu PRD'yle ilişkisi |
|---|---|---|
| EKIP D1-D3 (`support_system.gd`, `build_bar*.gd`) | kirli ağaçta, commit'lenmedi | UD2'nin Destek bloğu okur → UD2 onlardan sonra |
| EKIP S2 (`product_tab.gd`) | yazılmadı | UD2 aynı dosyaya → S2'den sonra, ayrı hunk |
| EKIP S1, S3, V1 (`sprint_system.gd`, `sprint.json`, verim) | yazılmadı | Ağaç ölçümü ve UD10 kalibrasyonu sonrasına; `sprint.json` alan hunk'ları sıralı |
| EKIP `product_state.gd`, `hr_*` | kirli ağaçta | UD7 `product_state.gd`'ye dokunur → EKIP'ten sonra |
| O19 (B2B Onboarding tabanı) | ACIK 107(a) onaylı; yazıldı, indekste, commit'lenmedi (`b2b_constants.gd` `ONBOARDING_GRACE_WEEKS`/`MARGIN` ve `SIGNING_SAT_*`, `b2b_sales_system.gd`, `sales_system.gd` `add_b2b_customer`, `sales_tab.gd` `onboarding_ends_under_bar`, `run_probe.gd`) | Faz 3 tabanı O19 commit'inden sonra; deneme penceresi kısalması O19'un penceresidir |
| O22 (satış süreci) | kodu ve PRD'si ağaçta yok | Faz 3b'nin arayüzü (§4.0) |
| Ana menü AM5 (Devam kartı, kayıt) | main'de (`a4db89a`) | UD9'un şema kırılması AM5'ten sonradır ve sıra sağlandı; Devam kartı TOO_OLD yuvayı sunmaz |
| Rakip Dünyası I2 | başlamadı | UD16'nın veri biçimi; soru 7 |
| Rakip Dünyası I3 | başlamadı | Şema numarası (I3 önce inerse UD9 bir sonraki numarayı alır); dönem tarafsız adlar |
| Olay motoru v3 | main'de (`5933acc`) | kart kuralları |
| `strings.csv`, `endgame_smoke.gd`, `main.gd` | en az üç oturum yazıyor | bayt aralığı kuralı; anahtar ön ekleri `PRODUCT_OV_`, `PRODUCT_PACK_`, `PRODUCT_STREAM_`, `PRODUCT_LEVER_`, `PROD_*_MKT_`; yalnız kendi hunk'ların |

### 9.2 Commit tablosu
Her commit: `--event-lint` → `loc_residue` → `loc_csv_integrity` → dokunulan vakalar → (ekonomi commit'inde) protokol → (görünen değişiklikte)
görsel kabul → tek inceleme → commit. TR metni taşıyan mesaj "TR/EN onay bekliyor", sabit taşıyan "onay bekliyor" der.
| # | İçerik | Bağımlılık | Kapı |
|---|---|---|---|
| UD1 | Genel Bakış verisi: tek akımlı `revenue_streams()`, `overview_model.gd`, `infra_auto` ve `set_auto`, `product_view_requested` | EKIP D1-D3 main'de | bayt-eş; `infra_manual_stops_autogrow` |
| UD2 | Genel Bakış görünümü (GB1-GB3), `D_utilization_color`, CSV, `--product-shot=live:overview_*` | UD1; EKIP S2 | görsel kabul; tema kapıları |
| UD3 | Satış B2C özeti; çek adımları Genel Bakış'a | UD2 | `cheque_read_steps`; görsel |
| UD4 | Belgeler Faz 1: HARITA, CLAUDE §12 shot türleri | UD3 | loc kapıları |
| (kapı) | §3.0 simülasyonu ve tasarım notu onaylı; sorular 1-3, 5-7 cevaplı | | |
| UD5 | `tools/econ_protocol.sh`; `RunProbe` `STREAMS` ve `TREE` satırları; taban tablosu rapora | UD4 | harness, ayrı rapor |
| UD6 | `convert_audience`, `open_paid_tier` silinir | | `event_chip_coverage`, lint |
| UD7 | `groups[]` doğrulayıcısı; kalite seçeneği A; `lines_open`/`usage_weight_total` kapsamı | EKIP `product_state.gd` main'de | ERP bayt-eş; `two_sided_quality_mean` |
| UD8 | `marketplace.json`, alt tür kaydı, alanlar, MVP sayacı, hat ve kademe anahtarları; fikstür geçişi (eski ekonomi) | UD7 | bütün dokunulan vakalar yeşil |
| UD9 | not ve video silinir; şema kırılması; emekli vakalar (onaylı liste) | UD8; AM5; I3 sırası | §10, §11.3 |
| UD10 | `MarketplaceSystem` çekirdeği: satıcı, sipariş, satış hacmi, komisyon, ilan dönemi, mevsimsiz MRR, kayıt ilk komisyonda, likidite, aşımda sipariş kaybı, `product_history`, bot stratejileri, hacimle pazar payı | UD9; onaylı sabitler; EKIP S1, S3, V1 | protokol; `mkt_streams_sum_mrr`, `mkt_season_excluded_from_gates`, `mkt_commission_needs_checkout_payouts`, `mkt_save_roundtrip` |
| UD11 | Hat kolları ve kart açıklama satırları | UD10 | `mkt_line_levers_apply`; protokol |
| UD12 | Üyelik ayrıcalıkları, Premium satıcı, Öne çıkan ürünler, `plan_slots`, `estimate_tiers`, `perks` gider kalemi | UD11 | `mkt_estimate_tiers_pure`; protokol |
| UD13 | Mevsimler: `seasons.json`, `SeasonCalendar`, doluluk payı, destek çarpanı, sezon geliri kasaya | UD12; EKIP D1 | `season_load_does_not_grow_capacity`; protokol |
| UD14 | Genel Bakış pazaryeri blokları, akım satırı kolları, satıcı çağrısı (`marketing_push.target`) | UD13 | görsel kabul |
| UD15 | Paketler ekranı (B2C) | UD14 | görsel kabul |
| UD16 | Rakipler, adlar, sektör yuvaları, rakip kademe tablosu | UD10; I2 kararı; soru 6 | `market_catalog_lint`; Piyasa çekimi |
| UD17 | Fiiller `seller_delta`, `commission_promo`, `season_mod`; seam'ler | UD13 | `event_chip_coverage` |
| UD18 | Kartlar (§5.3, Faz 2) | UD17 | `plausibility_run` fails=0; kart çekimleri |
| UD19 | Belgeler Faz 2: HARITA, CLAUDE §6 B2C cümlesi ve §12, GUNCELLEMELER, ACIK maddesi (ACIK 97 yeniden açıldı, ölçüm) | UD18 | loc kapıları |
| UD20 | `trust_delta` fiili | | `event_chip_coverage` |
| UD21 | Modüller (grup, alan, arketip istekleri, sektör açılımı); bot modül planlamaz | O19 main'de; UD7 | ERP bayt-eş (20 tohum) |
| UD22 | `Customer` alanları, B2B akımları, modül eklentisi, `month_history.streams` | UD21 | bayt-eş; `b2b_streams_sum_mrr`; kayıt gidiş dönüşü |
| UD23 | Premium plan | UD22 | bayt-eş; `full_run_erp_deep` protokolü |
| UD24 | Kurulum hizmeti | UD23 | `impl_fee_never_exceeds_cost`; bayt-eş |
| UD25 | Paketler B2B, önizleme, iğne terimleri | UD24 | görsel; bayt-eş |
| UD26 | Genel Bakış B2B blokları (Modüller, Kayıplar ve nedenleri, mevcut hesaplardan büyüme), portföy sütunları | UD25 | görsel; bayt-eş |
| UD27 | Modül başına genişleme ve `customer.expansion_module` kartı (kart yalnız Eklenti modülü canlıyken) | UD26; UD20 | bayt-eş; plausibility |
| UD28 | Deneme (adlı firmalar, 2/4 hafta, blok, aday etiketi) | UD27 | `trial_to_prospect_named`; bayt-eş; görsel |
| UD29 | ERP hat kolları ve B2B mevsimleri | UD28 | protokol (§11.2 Faz 3) |
| UD30 | Kartlar `customer.einvoice_ask`, `customer.golive_slip`, `customer.data_migration` | UD29 | plausibility; protokol |
| UD31 | Belgeler Faz 3 ve ölçüm | UD30 | loc kapıları |
| UD32 | Faz 3b: deneme adayı O22 evresinden girer | O22 main'de, arayüz yazılı | O22 kabulü; evre girişi vakası |

### 9.3 Kesme listesi (YM11)
Faz başına "kesilirse demo bozulmaz", kesme sırasıyla:
- **Faz 1:** Destek bloğu (EKIP gecikirse sonra gelir).
- **Faz 2:** `customer.counterfeit_listing`; Yılbaşı (yalnız Kara Cuma); kargo kuponu (soru 1); Öne çıkan ürünler (strateji hedefi dörtten üçe
  iner, yeniden ölçülür); `world/` metin yenilemeleri (eski metin "uygulama" der ama bozmaz).
- **Faz 3:** Satın Alma modülü; `customer.data_migration`; `customer.einvoice_ask`; aday mevsimi; kurulum hizmeti.
- **Kesilmez:** Genel Bakış ve kapasite; `groups[]` ve seçenek A; ilan dönemi; mevsimsiz MRR; ölçüm protokolü; Paketler (S7); iki taraflı ağaç (S4);
  atalet kuralı.

## 10. Kayıt ve şema (YM5)
- **Faz 1:** şema artmaz. Yeni bayrak `infra_auto` (bool, varsayılan `true`); eski kayıtta Otomatik.
- **Faz 2:** tek kırılma UD9'da: `SCHEMA_VERSION` 15 → 16 (I3 önce indiyse bir sonraki numara), `MIN_LOADABLE_VERSION := SCHEMA_VERSION`
  (`save_manager.gd:16,23`). Gerekçe: silinen alt türün kaydı yüklenirse `line_ids()` boş döner; seçmeli düşürme `read_slot`'ta tür okuması ister ve
  ERP kayıtları için göç zincirini yaşatır; sürüm 0.1.0, yayınlanmış yapı yok. Aynı commit ölü göçleri siler (`_migrate_sales_rev6`, `_migrate_13`,
  `_migrate_14`, `_migrate_15`, `save_manager.gd` `read_slot` zinciri) ve §11.3'ün emekli vakalarını çıkarır. `SAVE_ERR_TOO_OLD` metni zaten "ürün
  verisi değişti" der; Devam kartı ve Yükle paneli TOO_OLD yuvayı açılabilir göstermez (AM5'in kuralı; `--menu-shot` ile doğrula). Emekli vakalar
  ve `engine_probe.gd:436` iğnesi (`== 10`) commit açıklamasında listelenir; CLAUDE §3 gereği onaydan sonra.
- UD9'dan sonraki bütün yeni durum anlamlı varsayılanla açılır, şema artmaz: `mkt_*` bayrakları, `plan_slots`, `product_history`,
  `month_history[].streams`, `marketing_push.target` ("buyers").
- **Faz 3:** şema artmaz. `Customer` `@export` alanları varsayılanlarıyla (`plan`, `modules`, `modules_offered`, `from_trial`, `impl_service`);
  GameState `erp_trials`, `b2b_mrr_snapshots`, `b2b_churn_log`; `initialize_run` (`game_state.gd:751`) hepsini sıfırlar. `MarketplaceSystem` ve
  `SeasonCalendar` statik durum tutmaz; tutarsa `SaveManager.reset_all_owners`'a girer.
- Her fazda kayıt gidiş dönüşü vakası (yeni bayrak ve alanlar).

## 11. Smoke, probe ve ölçüm

### 11.1 Ölçüm protokolü (YM3)
`tools/econ_protocol.sh` (UD5; harness, ayrı raporlanır), ACIK 97 biçiminde:
- Koşular: tohum 1-8, 120 hafta, `--lang=tr`, her koşu ayrı süreç ve `APPDATA`, en çok iki paralel. Preset'ler: `full_run`, `full_run_lean`,
  `full_run_vc_cautious`, `full_run_b2c` ve üç strateji preset'i, `full_run_b2c_vc_cautious`, `full_run_b2c_vc_walk`, `full_run_b2c_k1`; Faz 3'te
  `full_run_erp_deep`; 26 haftalık `b2c` ve `b2c_neglect` fikstürleri.
- Tablo (preset başına, önce/sonra): son id dağılımı; iflas sayısı; melek, seed ve Seri A günleri (en küçük, ortanca, en büyük); çekten önceki en
  düşük kasa; Traction'da sonlu runway payı; profitable_bootstrap oranı; akım payları (52. ve 90. hafta, yeni `STREAMS` satırı); ağacın %25, %50,
  %75 ve %100'ünün açıldığı haftalar (yeni `TREE` satırı, `SHIP` kayıtlarından); B2B kazanma oranı; Faz 3'te O19 M2 ve M3.
- `^PROBE` bayt karşılaştırması iki tarafta aynı harness'la yapılır (ebeveyn ağacı `git checkout-index` ile kurulur).

### 11.2 Faz kapıları
- **Faz 1:** `full_run` ve `full_run_b2c` tohum 1-8, 40 hafta bayt-eş; `run_gate` 3/3.
- **Faz 2:** UD7'de ERP bayt-eş. UD8'de bütün dokunulan vakalar yeşil, ekonomi eski. UD10-UD13 her birinde protokol ve sert kapılar: iflas ≤
  taban; her strateji preset'i Seri A'ya 70-95. haftada en az 6/8 tohumda; melek 8-25. haftada; varsayılan akım payı 90. haftada ≤ %65; ağaç
  104. haftada ≤ %60 (EKIP S1, S3, V1 sonrası; aşarsa hat eklenmez, K3 Ar-Ge kapısı ve efor bandı kullanılır). ERP `^PROBE` UD17'ye kadar bayt-eş;
  UD18'de fark yalnız `outage` koşulundan gelebilir, raporlanır. `plausibility_run` fails=0; `run_gate` 3/3.
- **Faz 3:** UD21-UD28 ERP `full_run` 20 tohum, 40 hafta bayt-eş (O19 sonrası taban). UD29-UD30: `full_run` ve `full_run_lean` Seri A ortanca günü
  tabandan erken değil, iflas ≤ taban, Traction sonlu runway payı ≥ taban (ACIK 107 M5'te 0,21), B2B kazanma oranı ±%10; `full_run_erp_deep` Seri A
  ortancası tabanın ±%50'sinde ve tabandan en çok 4 hafta erken, iflas ≤ taban; O19 M2 ve M3 raporu (kapı değil).
- Eşikler §8'de "onay bekliyor"; tutmayan değer commit'lenmez, rapora yazılır.

### 11.3 Vaka tablosu (YM13)
- **Taşınan (UD8, fikstür `note_tool`/`video_clip` → `marketplace`):** `product_read_catalogue`, `sprint_carry_keeps_progress`,
  `product_lines_catalog_loads`, `axis_reading_replaces_not_adds`, `infra_heavy_step_costs_capacity`, `above_gate_bonus_ladder`,
  `sprint_two_days_close`, `sprint_release_resets_live_bugs`, `sprint_never_stalls_in_plan`, `sprint_faulty_ticket_deterministic`,
  `sprint_beta_delays_release`, `sprint_beta_card_cannot_be_added`, `rnd_note_author_and_lines`, `research_occupies_person`,
  `research_and_build_pause_each_other`, `productivity_mod_paces_the_sprint`, `market_catalog_lint`, `line_ladder_rules`,
  `line_k3_locked_without_research`, `leave_does_not_pause_build`, `gate_scope_and_halves`, `card_math_matches_gdd_example`,
  `burn_tools_and_service`; yardımcılar `_seed_support_fixture`, `_seed_sprint`.
- **Ekonomisi değişen (UD10-UD12, yeni kurala göre güncellenir; emekliye ayrılan olursa onay):** `b2c_wom_needs_satisfaction`,
  `b2c_growth_multiplier_floor` (fiyat çarpanı → likidite), `b2c_satisfaction_drifts_to_experience`, `b2c_value_reads_live_lines` (taraf kapsamı),
  `sprint_paid_plan_opens_paid_tier` (Üyelik, Ödeme K1 kilidi), `sprint_lead_offers_paid_plan_b2c`, `gate1_b2c` (mevsimsiz MRR),
  `b2c_ending_reports_audience` (alıcı ve satıcı); Faz 1'de `cheque_read_steps`.
- **Emekli (UD9, onay bekliyor):** `save_v10_product_state`, `save_v13_day_stamps_migrate`, `save_v14_build_becomes_sprint_plan`,
  `save_v14_history_becomes_releases`, v12 öncülü vaka (`endgame_smoke.gd:2311`, kendi öncülünü emekli sayar). `SAVE_ERR_TOO_OLD` iddiaları iki yerdedir
  (`69f4786`): `_case_save_backup_fallback` içinde `:8910` (kalır; yeni sınırla güncellenir) ve `_case_save_v10_product_state` içinde
  `:14042-14047` (vaka emekli olur, bu iddia emekliden önce hayatta kalan bir vakaya taşınır ve yeni sınırla güncellenir); `engine_probe.gd:436` yeni
  değere.
- **Yeni (yalnız çekirdek mantık, hepsi falsifikasyon notlu):** `infra_manual_stops_autogrow` (UD1), `two_sided_quality_mean` (UD7),
  `mkt_streams_sum_mrr`, `mkt_season_excluded_from_gates`, `mkt_commission_needs_checkout_payouts`, `mkt_save_roundtrip` (UD10),
  `mkt_line_levers_apply` (UD11), `mkt_estimate_tiers_pure` (UD12), `season_load_does_not_grow_capacity` (UD13), `b2b_streams_sum_mrr` ve
  `b2b_save_roundtrip` (UD22), `impl_fee_never_exceeds_cost` (UD24), `trial_to_prospect_named` (UD28). Kartlar `event_chip_coverage` ve
  `plausibility_run` ile; arayüz smoke'la değil görsel kabulle.

### 11.4 Görsel kabul çekimleri
Yeni `--product-shot=live:` türleri (`main.gd`'nin `_seed_product_live(scenario)` işlevinde, gerçek bir koşuda `SprintSystem.choose_type` ile kurulur;
`product_fixtures.gd` yalnız `c1..c5`, `cards`, `flow` ve `edge:<ad>` çekimlerini besler): `overview_b2c`, `overview_b2b`, `overage`,
`manual` (Faz 1); `overview_mkt`, `overview_mkt_listing`, `overview_mkt_bf`, `packages_mkt` (Faz 2); `overview_erp`, `packages_erp`,
`overview_erp_trial` (Faz 3). Ayrıca `--sales-shot=b2c_live`, `--tab-shot=piyasa:sektor`, yeni kartlar için `--event-shot`. Her biri TR ve EN,
1920 ve 1536; `--theme-contrast-audit`; glif denetimi (`glyph_audit.gd`). Her karede: öğe yerinde mi, metin taşıyor ya da kesiliyor mu, doğru dilde
mi, satır burada doğru mu ve oyuncu anlıyor mu, logda hata var mı.

## 12. Sahip kararları

### 12.1 Sahibe yedi soru (öneriyle)
1. **Üyelik ayrıcalıkları ve kargo kuponu.** Üyelik temel alışverişi kilitlemez, dört ayrıcalık satar (§3.5.2). Kargo kuponu demoda olsun mu?
   A) Evet: platform kargo bedelini öder, kargoyu taşımaz; gider kalemi görünür. B) EA'ya, demoda üç ayrıcalık. **Öneri A:** kuponsuz Üyelik demoda
   zayıf kalır; gerçek üyeliklerin ana vaadi kargodur; taşıma yine satıcıda kaldığı için "kargo satıcının işi" eğilimiyle çelişmez.
2. **Gelir dengesinin hedefi.** A) Varsayılan oyunda 90. haftada tek akım ≤ %65; dört stratejinin en az üçü Seri A'ya 70-95. haftada; tek tarafa
   yatırım tıkanır. B) Daha sıkı: ≤ %50. C) Komisyon baskın, öbürleri yan gelir. **Öneri A:** gerçek pazaryerlerinde komisyon yarıdan fazladır ama
   reklam ve abonelik seçilebilir bir yoldur; %50 her oyunu aynı karışıma zorlar.
3. **Pazaryeri MVP'si.** A) İlan dönemi: herhangi 3 hat, her taraftan en az biri; komisyon Ödeme K1 ve Hakediş K1 canlı olunca başlar. B) Sabit
   iskelet: MVP = Ürün yükleme K1, Ödeme K1, Hakediş K1. **Öneri A:** sıra oyuncunun kararı kalır, ortak MVP sayacına dokunulmaz, "önce kitle sonra
   para" gerçek bir yoldur (ilan siteleri böyle başlar).
4. **ERP'de deneme mi, freemium mi?** "Kitle" dedin; tasarım bir aday borusu kurdu. A) Demoda 2 ya da 4 haftalık deneme (adlı firmalar, aday
   borusu), freemium EA. B) Demoda tek modül ücretsiz kalıcı plan. **Öneri A:** B2B'de ücretsiz kullanıcı tek başına gelir getirmez; deneme
   firmalarının satış hattına adıyla akması gerçek ERP satışıdır; kalıcı ücretsiz kitle EA'da "tek modül ücretsiz" olarak gelir.
5. **Adlar ve "premium".** A) "premium" izinli ödünç kelimelere girer: alıcıda Üyelik, satıcıda "Premium satıcı planı", ERP'de "Premium plan". B)
   Sözlük aynı kalır: "Profesyonel satıcı planı" ve "Kapsamlı plan". **Öneri A:** senin kullandığın kelime; Türk oyuncu "Premium üyelik"i tanır;
   oyunda iki ad yeter (Üyelik, Premium).
6. **Rakip adları.** Devler (Orinoco, Bidwell, Sindbad, Dealflock, Shopstead) Piyasa'da dev kalır; pazaryeri sektör rakipleri yeni parodi adlar
   (Stitchery, Wishwell, Plushmark, Jetsam ve taranacak dört ad; Trendora çıkar). A) Bu yol. B) Devler aynı zamanda sektör rakibi olur (Ürünleri'yle).
   **Öneri A:** Rakip Dünyası I2'nin dev ve sektör rakibi ayrımıyla uyumlu; küçük bir girişimin ilk yıl Orinoco'yla kademe yarışı saçma okunur.
7. **Faz sırası.** A) Faz 1 → Rakip Dünyası I2 → Faz 2 → Faz 3a (O19 sonrası) → O22 → Faz 3b. B) Faz 2 I2'yi beklemez; rakip tablosunu eski
   biçimde yazar, I2 iki bloğu birlikte dönüştürür (küçük çift iş, pazaryeri daha erken). **Öneri:** I2 Faz 1 bitene kadar başlıyorsa A, yoksa B.

### 12.2 Ekip kararları (varsayılanla kapatıldı; itiraz edilirse değişir)
- Bilgi sayfası Ürün penceresinde görünümdür; adlar Genel Bakış ve Paketler.
- Hat biçimi tek `groups[]`; kalite seçeneği A (iki tarafın ortalaması).
- Mevsimsiz MRR; mevsim fazlası kasaya; Ocak durgunluğu EA.
- Şema: tek kırılma UD9, `MIN_LOADABLE := SCHEMA`; başka fazda şema artmaz.
- Paketler taslak ve "Uygula" ile; kollar satırda adımlı ve "Uygula" ile; "önerilen" değer yok.
- Kapasite Otomatik/Elle; Destek bloğu salt okur; Hotfix BuildBar'da kalır.
- Müşteri politikaları EA'da ayrı Müşteri Başarısı sekmesinde.
- Tek `seasons.json`; demoda Kara Cuma ve Yılbaşı (B2C), e-Fatura, aday mevsimi ve yıl sonu desteği (B2B).
- Ekranda bulma oranı, "etkin kesinti", GMV ve NRR kısaltması yok.
- K3 adları dönem tarafsız; yeni kademe `ai` taşımaz. Demoda gizli hat yok.
- Kurulum bedeli gider karşılığıdır, kâr değildir.
- ACIK_KARARLAR'a yeni maddeler dosyanın son maddesinden sonra eklenir (bugün 107).

### 12.3 Onay bekleyenler (soru sayılmaz, raporda tek liste)
§8'in bütün sabitleri ve faz kapılarının eşikleri; §7'nin bütün metinleri (TR/EN); sözlük ekleri ("premium" soru 5'e bağlı); §11.3'ün emekli vakaları
ve `MIN_LOADABLE`; `product/paid_tier` için Frank satırı (taslak); ACIK 97'nin yeniden açılması.

## 13. Done
Erdem'e tek mesaj: madde başına ✅/⚠️/❌ (GB1-GB5, PZ0-PZ10, ER1-ER9, §5.3 kartları), commit kimlikleri, kapı çıktıları ve bayt-eş kanıtları;
simülasyon tablosu (dört strateji, iki yatırım profili); faz başına protokol tablosu (önce/sonra); ağaç yüzdesi tablosu; akım payları; TR/EN,
1920/1536 ekran görüntüleri; onay bekleyenler listesi (§12.3); açılan ACIK maddelerinin numaraları; kesilen kalemler (§9.3) ve nedeni.
