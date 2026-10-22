# HARITA → kod haritası geçişi

`docs/HARITA.md` (406 satır, 23 bölüm; 27 satırı 2.000 karakteri aşar) ile `docs/kod_haritasi/` arasındaki karşılık. HARITA'ya bu belge dokunmaz.
Geçiş, kod yazan oturum bitince ayrı bir işle yapılır. Satır numaraları 2026-10-22 tarihli HARITA'dandır (git f3113fa4 + kirli ağaç).

## 1. Bölüm karşılıkları

| HARITA bölümü (satır) | Yeni yer | Not |
|---|---|---|
| Çekirdek (7) | `01_cekirdek.md` | Dağıtım sırası Giriş noktaları ve Dikkat'te; zaman sabitleri Durum ve veri'de |
| Kayıt (27) | `01_cekirdek.md` | Göç zinciri, yuva adları, `reset_all_owners`; göç vakaları Testler'de |
| Platform (45) | `01_cekirdek.md` | Settings, Localization, AudioManager, DisplaySettings, GraphicsSettings |
| Tema ve UI kiti (61) | `09_arayuz_bilesen.md` | UiTokens, UiFactory, build_theme, theme_check |
| Ana menü, açılış dizisi ve Jenerik (78) | `09_arayuz_bilesen.md` | `main.gd` açılış zinciri ayrıca `01_cekirdek.md` Dosyalar |
| Kabuk (95) | `09_arayuz_bilesen.md`, `01_cekirdek.md`, `08_sekmeler.md` | TopBar/ray/pencere 09; `main.gd`/`game_shell.gd` 01; sekme sözleşmesi 08 |
| Ofis (3B) (121) | `06_ofis.md` | Dışa aktarım hattı da 06'da |
| Ürün (139) | `02_urun_sprint.md`, `08_sekmeler.md` | Sistem 02; Ürün penceresi ve ProductModel 08 |
| Ar-Ge (166) | `02_urun_sprint.md`, `08_sekmeler.md` | Sistem 02; Ar-Ge penceresi 08; ARAŞTIRMA kartı 09 |
| Ekip (182) | `04_ekip.md`, `08_sekmeler.md`, `09_arayuz_bilesen.md` | Sistem 04; Ekip penceresi 08; Eğitim ve Mesai modalları 09 |
| Satış (201) | `03_satis_b2b.md`, `08_sekmeler.md` | Sistem 03; Satış penceresi 08 |
| Finans (227) | `05_fon_finans.md`, `08_sekmeler.md` | Sistem 05; Finans penceresi ve özet 08; nakit eğrisi 09 |
| Fonlama merdiveni (241) | `05_fon_finans.md`, `08_sekmeler.md`, `09_arayuz_bilesen.md` | Sistem 05; Yatırım sayfası 08; term sheet masası sahnesi 09 |
| Görüşme paneli (263) | `09_arayuz_bilesen.md`, `03_satis_b2b.md`, `05_fon_finans.md` | Panel ve adaptör 09; satış ve pazarlık kuralı 03; VC kuralı 05 |
| Dünya (rakip, haber) (276) | `05_fon_finans.md`, `08_sekmeler.md` | RivalRegistry, NewsFeedSystem, MarketCatalog, QualityModel 05; Piyasa penceresi 08 |
| Sonlar ve gazete (292) | `05_fon_finans.md`, `09_arayuz_bilesen.md` | EndingsSystem, EndingsCopy 05; EndingScene 09 |
| Olay motoru (307) | `07_olay_motoru.md` | |
| Gelen kutusu mesajları (329) | `05_fon_finans.md`, `09_arayuz_bilesen.md`, `08_sekmeler.md` | MessageSystem 05; Inbox modeli 09; Olaylar penceresi ve okuma bölmesi 08 |
| Teslim saati (MailClock) (340) | `05_fon_finans.md` | Teslim saati kuralı ayrıca CLAUDE.md §6 |
| Olay içeriği (data/events) (353) | `07_olay_motoru.md` | Kart sayıları, kapsam, katalog dışlamaları |
| Onboarding (365) | `09_arayuz_bilesen.md` | Kurucu kuralları 04 |
| Araçlar (380) | `10_test_harness.md`, `07_olay_motoru.md` | Smoke, probe, kapılar 10; olay araçları 07 |
| Üçüncü taraf ve altyapı (396) | kısmen `06_ofis.md`, `10_test_harness.md` | office3d hattı 06; githooks, `export_build.sh`, `tools/people` 10; kalanı aşağıda §2 |
| (HARITA'da yok) | `DIZIN.md`, `SEMBOLLER.tsv`, `KALITE.md` | Üretilmiş dizin, sembol tablosu ve kalite adayları |

## 2. Yeni haritada karşılığı olmayan HARITA içerikleri

Geçişte ya ilgili sistem sayfasına taşınmalı ya da bilerek bırakılmalı (CLAUDE.md'nin bunlardan bazılarına "HARITA'da" diye gösterdiği unutulmasın).
- Her bölümün GDD başvurusu (`· GDD ch01`, `· GDD Satış modülü` …): sistem sayfalarında GDD bölüm atıfları yok.
- Her bölümün "Sahip" satırı (autoload, sınıf, durumun tek yazarı) tek satırda: sistem sayfalarında Dosyalar ve Dikkat'e dağılmış, toplu özet yok.
- Probe kayıt türlerinin bölüm bölüm tam listesi: örnek `VC_REPLAY`/`VC_REPLAY_SUM` (Kayıt), `HR` (Ekip), `MARKET` ve `MARKET_LOG_WEEKS` (Dünya), `SPRINT`/`SHIP` (Ürün). Yeni sayfalarda kısmi.
- `--sprint-probe` ek anahtarlarının anlamları (`start`, `seeds`, `lead`, `gate`, `fill`, `tstar`, `pmstar`, `plus`, `founder`, `planms`): CLAUDE.md §12 "anlamları HARITA Ürün'de ve Araçlar'da" der; 02 ve 10'da yok.
- `--product-shot` `edge:<ad>` adları ve `live:<tür>` kurulumlarıyla ikinci/üçüncü kareleri (CLAUDE.md §12 HARITA Ürün'e gösterir): 02 ve 08 yalnız bayrağın biçimini verir.
- `--inbox-shot=<durum>` durum listesi (`offer`, `queue`, `customer`, `locked` …; HARITA Gelen kutusu, :338): CLAUDE.md §12 "durumlar HARITA'da" der; yeni haritada yok.
- Görsel tür listeleri: `--modal-shot` (save, load, settings türleri), `--hr-shot` türlerinin tamamı, `--finance-shot`, `--vc-shot=hunt*`, `--menu-shot` ayrıntısı; yeni sayfalarda kısmi.
- Paylaşılan kayıt yuvasına (`manual_9001`/`manual_9002`) yazan, paralel koşulamayan smoke vakalarının ADLI listesi (HARITA Araçlar :384): 10 yalnız yuvaları anar; CLAUDE.md §12 "liste HARITA'da" der.
- `GameState.messages` öğe şeması (`{id, kind, day, key, args …}`, HARITA :332): 05 alanı yalnız satırıyla anar.
- Ölçüm ayrıntıları: `--display-check` (gerçek pencere kipleri), `--render-probe=<sekme>:<kişi>:<hız>` alanları, `--backdrop-probe` satırları; 09 ve 10'da yalnız bayrak adı.
- Üçüncü taraf ve altyapı: `addons/` (`auto_reload`, `godot_mcp_editor`, `godot_mcp_runtime`), git kökündeki `.mcp.json`, Lucide ve Quaternius lisans dosyaları, `export_presets.cfg` paket dışı klasörleri, kök dosyalar listesi.
- Smoke vaka öneklerinin bölüm bölüm haritası (`hotfix_*` Satış yama turu, `coupling_*` Ürün+Ekip ortak, `faced_flag_*` …): 10 aile sayılarını verir, önek → sistem eşlemesini vermez.

## 3. Sistem sayfalarının "HARITA'da bayat" listelerinin birleşimi

Bayat (HARITA kodla çelişiyor; geçişte ya da önce düzeltilmeli):
- Kayıt (:39) ve CLAUDE.md: "göçler `read_slot` sırayla uygular". Zincir `SaveManager._read_file`'dadır (`save_manager.gd:170-209`); `read_slot` yalnız onu çağırır ve bozuk dosyada `.bak`'a düşer. (01)
- Platform (:52): "AudioManager … yalnız ayarlar modalı kullanır". `Settings.apply_all` (`settings.gd:125`) de çağırır; `sandbox/asset_lab/asset_lab.gd:64` `MusicPlayer`'ı durdurur. (01)
- Ofis (:127): `OfficeView.current_layout` diye üye yok; yerleşim `OfficeView.layout` alanındadır (`office_view.gd:31`). (06)
- Ofis (:129): gün tohumu `OfficeConstants.SALT_DAY` denir; sabit `SalesConstants.SALT_DAY`'dir (`sales_constants.gd:282`), `OfficePeople` oradan okur (`office_people.gd:548`). (06)
- Ürün (:158) DESTEK maddesi `MailPane._support_report` der; `mail_pane.gd` class_name taşımaz, fonksiyon `mail_pane.gd:688`'dedir. (08)
- Ekip (:193) Kişisel penceresi: huylar "YAKINDA etiketinin altında" denir; `personal_tab.gd:124-134` yalnız huy kutusunu ve adı çizer, YAKINDA etiketi ve CSV anahtarı yok. (04)
- Sonlar (:299): "Projede henüz export ön ayarı yok" denir; `export_presets.cfg` üç preset taşır (`custom_features` "", "ea", "full"); HARITA'nın kendi :405 satırı da öyle der. (05)
- Olay içeriği (:356): "`_` ya da `ev_debug_` ile başlayan dosyaları havuza almaz"; kod bu dosyaları hiç yüklemez, katalogda yoktur (`catalog.gd:19,61-63`). (07)
- Olay içeriği (:356): "`unwired` ve `drafts` adlı dizinlere girmez"; `drafts/` diskte yok, yalnız `EXCLUDED_DIRS` sabitinde (`catalog.gd:17`); gerçek dizin yalnız `unwired/` (3 kart). (07)
- Tema ve UI kiti (:73): "`DialoguePortraitCard`'ı onboarding'in karakter adımı kullanır"; `character_step.gd` kullanmaz (`:55` portreyi doku koyar), sınıfı yalnız kendi tscn'si referanslar. (09)
- Onboarding (:375): akış `Footer/Reason`'a yazar denir; düğüm `Paper/Col/Foot/Row/Reason`'dır (`OnboardingFlow.tscn:121`, kodda `%Reason`). (09)

Eksik (yanlış değil, geçişte tamamlanabilir):
- Çekirdek (:16) dağıtım satırı saatlik dilimde `InfraSystem.auto_adjust` (`time_manager.gd:445`) adımını saymaz; Ürün maddesi sayar. (02)
- Ürün ve Ar-Ge: okuyucusu olmayan `cicd`/`test_automation` etkileri, ölü `LineGates.speed_bonus_for`, `ProductCatalog.type_sector_labels`, `RnDSystem.family_root_done` ve dinleyicisiz sinyaller anılmaz. (02)
- Ürün (:141) "Yer" satırı `scripts/tabs/product/overview_view.gd`'yi saymaz (satır 155 GENEL BAKIŞ'ı anlatır). (08)
- Satış (:203) "Yer" satırı `counterpart_system`, `market_catalog`, `support_system`, `sales_probes`, `sales_name_pool`'u saymaz; ilk ikisi Fonlama (:254) ve Dünya (:284), Destek Ürün (:141-142) bölümünde. (03)
- Araçlar (:384-389): olay motoru fiil sözlüğü ile `EvEffects._apply` farkı anılmaz; yedi fiil kolsuz (`assign_to`, `start_training`, `add_customer`, `convert_audience`, `open_paid_tier`, `change_salary`, `fire_employee`). (07)
- Araçlar (:390) `tools/` satırı `plausibility_run.sh` ve `lint_v3_frozen.json`'u saymaz; `plausibility_run.sh` yalnız olay araçları satırında (:389). (10)
- Üçüncü taraf (:403) dışa aktarım çıktılarını `home, ishani, plaza, loft, city` sayar; `meet` yok, `export_office.js:31` altı yeri yazar. (06)

HARITA dışı ama aynı alan:
- `.githooks/pre-commit` yorumu "278-case smoke suite … takes hours" der; süit bugün 475 vakadır. (10)

## 4. Geçiş adımları (öneri, kod yazan oturum bitince)

- §3 "Bayat" maddelerini HARITA'da düzelt ya da HARITA'yı emekliye ayıracaksan doğrudan atla; CLAUDE.md'deki "HARITA Kayıt/Ürün/Araçlar'da" göstergelerini §2'deki içeriği taşıdığın sistem sayfasına çevir.
- §2'de "taşınmalı" denen her içeriği ilgili sistem sayfasının uygun bölümüne ekle (satır ≤240); taşınmayanları bilerek bırak ve burada işaretle.
- CLAUDE.md §4 "Bir şeyi bulmak için önce `docs/HARITA.md`" ve §13 belge listesini `docs/kod_haritasi/README.md`'ye çevir; ardından `python -I tools/kod_haritasi/uret.py` ile dizini yenile.
