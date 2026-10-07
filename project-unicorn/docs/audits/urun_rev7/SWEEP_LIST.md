# Ürün Rev 7 · SWEEP_LIST (Faz B süpürme listesi)

Faz A çıktısı, 2026-10-01. Commit edilmez. Faz B'nin 5. alt işi (PRD §6) bu listeyle çalışır.

## Kapsam, yöntem, karar kuralı

- **Silinecek set** (PRD §1 Faz B, §5.9): `scripts/tabs/product_tab.gd` (yerinde yeniden yazılır) ve
  `scripts/tabs/product/{capacity_block, creation_flow, detail_view, feature_lines_view, portfolio_view, pricing_panel,
  product_ui_shared, publish_flow, team_panel}.gd` ile `.uid` dosyaları.
- **Girdi:** Faz A bağımlılık taraması (iki ajan raporu). Her madde bugün yeniden ölçüldü; satır numaraları bugünkü
  ağaçtandır (F'nin `ui_tokens.gd` / `build_theme.gd` / `window_layer.gd` eklemeleri ve H'nin `main.gd` /
  `game_shell.gd` eklemeleri dahil).
- **GDD taraması:** `GDDs/*.docx` metni (`word/document.xml`, etiketler sökülerek) + `GDDs/GUNCELLEMELER.md` +
  `GDD — OLAY MOTORU (EVENT ENGINE) rev 2.md` + `GDD — ZAMAN MODELİ.md`. Hem fonksiyon/özellik adı hem Türkçe kavramı
  arandı. Kısaltmalar: **ch03** = `GDD v2 — 03 · Product Lifecycle` (rev 6.1), **GÜNC** = `GUNCELLEMELER.md`,
  **Ekip / ArGe / Satış** = modül GDD'leri, **Zaman** = `GDD — ZAMAN MODELİ.md`.
- **Çağıran arama:** `scripts/`, `scenes/`, `data/`, `tools/`, `project.godot`. Silinecek set, yorum satırları ve
  tanım satırının kendisi sayılmaz. Sınıflar: **üretim** · **rev7** (bayrak arkasındaki yeni kod) · **smoke**
  (`endgame_smoke.gd`) · **probe** (`run_probe.gd`, `office_crowd_probe.gd`, `loc_residue.gd`, `scripts/events/tools/`)
  · **harness** (`main.gd` debug bölümü) · **sandbox** (izlenmeyen `sandbox/ui_lab`; karara sayılmaz).
- **Karar kuralı** (PRD §1, §5.9; CLAUDE.md §2): çağıranı ya da GDD'de adı/kavramı olan **kalır** ve Faz B'de
  `docs/ACIK_ISLER/ISLER.md`'ye yeniden yuva listesi olarak yazılır. İkisi de yoksa **silinebilir (Faz B)**. Tek
  çağıranı bu listede silinebilir olan öğe onunla birlikte silinebilir (zincir, satırda yazılı).
- **Kesin kalır (sahip):** `RivalRegistry.get_player_rank_in_startup_league`, `ProductCatalog.suggest_product_name`,
  `bug_trend` zinciri.
- **Sahip kararı:** Frank külliyatı (CLAUDE.md §3) ve TR metin silme sahip onayı ister; bu satırlar öyle işaretli.

> ⚠️ **GDD ile PRD çelişkisi.** PRD §3.9 "Konsept ekranı yoktur" der, §5.9 eski Konsept/faz/cila kodunu siler. Oysa
> ch03 §3 (Konsept, tip ekranı), §10 (yayın akışı, kapasite bloğu, fiyat paneli), §16 (Frank şeridi), §17 (monitör,
> üçgen, portföy) ve GÜNC ch03 §2 (BuildBar'ın ikinci ev sahibi "Ürün sayfasındaki izleyici kartı") bu yüzeyleri adıyla
> anar; `GUNCELLEMELER.md`'de rev 7 maddesi yok. Bu yüzden bu yüzeylere bağlı her öğe aşağıda **kalır**; silinmeleri
> sahibin GUNCELLEMELER kaydına bağlı.

## 0. Silinecek set (bilgi; silme kararı PRD'nin)

| Dosya | Sınıf | GDD'deki yüzey | Setin dışından çağıran (şimdi) | Karar |
|---|---|---|---|---|
| `product_tab.gd` | (yok) | ch03 §2 Ürün sekmesi; GÜNC ch03 §2 izleyici kartı | üretim: `ProductTab.tscn:3` (script yolu) | yerinde yeniden yazılır; uid `uid://rmvnt0ew0cih` ve sahne yolu korunur |
| `capacity_block.gd` | `CapacityBlock` | ch03 §10 "Kapasite bloğu canlı ürün sayfasında yaşar" | yok | silinir (PRD) · yüzey GDD'de ⚠️ |
| `creation_flow.gd` | (yok) | ch03 §3 Konsept, tip ekranı; §16 Frank şeridi | smoke: `endgame_smoke.gd:12799` (`creation_draft_survives_navigation`) | silinir (PRD) · vaka da gider (§4) |
| `detail_view.gd` | (yok) | ch03 §17 Ürün Monitörü | yok | silinir (PRD) · yüzey GDD'de ⚠️ |
| `feature_lines_view.gd` | `FeatureLinesView` | ch03 §12.9 hat listesi | yok (yalnız yorum: `research_bar.gd:198`, `rnd_ui_shared.gd:196`) | silinir (PRD) |
| `portfolio_view.gd` | (yok) | ch03 §17 Portföy (MÜHÜRLÜ) | yok | silinir (PRD) · yüzey GDD'de ⚠️ |
| `pricing_panel.gd` | (yok) | ch03 §10 fiyat paneli | yok | silinir (PRD) · yüzey GDD'de ⚠️ |
| `product_ui_shared.gd` | `ProductUiShared` | yok (yardımcılar) | yok | silinir |
| `publish_flow.gd` | `PublishFlow` | ch03 §10 yayın akışı | üretim: `build_bar.gd:330`; harness: `main.gd:1642` | silinir (PRD) · önce bağ taşınır (§9) |
| `team_panel.gd` | `ProductTeamPanel` | ch03 §3 ekip seçimi ve lider, §12.9 ekip paneli | yok (yalnız yorum: `rnd_assign_panel.gd:8`) | silinir (PRD) |

## 1. Dosyalar (silmeyle yetim kalan)

| Öğe | Yer | GDD taraması | Çağıran (şimdi) | Karar |
|---|---|---|---|---|
| `TriangleRadar` | `scripts/ui/components/triangle_radar.gd` (+ `.uid`) | ch03 §17 "Eksen okumaları monitörün üçgeninde yaşar", "Üçgen kuralı (MÜHÜRLÜ)"; §11.3 üçgen geometrisi; ArGe §4.5 | yok (yalnız yorum: `cash_curve.gd:7`) | **kalır** (GDD) |
| `ProductTab.tscn` | `scenes/tabs/ProductTab.tscn` | ch03 §2 Ürün sekmesi | üretim: `window_layer.gd:12`; smoke: `endgame_smoke.gd:12821` | **kalır** (çağıran) |

Varlık (asset) ve veri dosyası yetim kalmıyor: `slider_grabber.svg` VolumeSlider'la ortak, `data/product/lines/*.json`
ProductLines'ın.

## 2. GameState bayrakları

| Öğe | Yer | GDD taraması | Çağıran (şimdi) | Karar |
|---|---|---|---|---|
| `creation_draft` | `game_state.gd:67` | yok ("taslak" yalnız Satış §11.5 ve Zaman §5/§9'da, ilgisiz) | smoke 3: `endgame_smoke.gd:12811, 12838, 12846` (yalnız `creation_draft_survives_navigation`) | **silinebilir (Faz B)** · vakayla zincir; eski kayıttan silme sahibin |
| `cancelled_build_prefill` | `game_state.gd:66` | ch03 §12.3 iptal kuralı (hatlar önceki durumda kalır) sistemdir; iptal edilen planı Konsept'e geri doldurmak GDD'de yok | yok | **silinebilir (Faz B)** |
| `product_path_frank_seen` | `game_state.gd:68` | ch03 §16 Frank şeridi (varsayılan satır, hover satırları) | yok | **kalır** (GDD) |
| `mvp_bug_history` | `game_state.gd:59` | ch03 §8.4 sayaç yön okları; Zaman §10 kayıt göçü | üretim 5: `save_manager.gd:565-566`, `product_system.gd:193, 197, 1389`; smoke 3: `endgame_smoke.gd:2284, 2388-2389`; harness 2: `main.gd:1574, 1612` | **kalır** (sahip: bug_trend zinciri) |

## 3. Harness

| Öğe | Yer | GDD taraması | Çağıran (şimdi) | Karar |
|---|---|---|---|---|
| `--product-shot=<portfoy\|ozellikler\|tracker\|beta\|detail_*\|publish>` | `main.gd:196` (dağıtım), `1552-1648` | yok | yalnız dağıtım satırı; belgede CLAUDE.md §12, `docs/HARITA.md:122` | **silinebilir (Faz B)** · yerine `--product7-shot` (Faz A) |
| `--build-state` + `_build_state_arg` + `_seed_build_state` | `main.gd:1471-1549` | yok | harness 4: yalnız `--product-shot` (`main.gd:1619, 1646`) ve kendi içi | **silinebilir (Faz B)** · `--product-shot` ile zincir; BuildHUD karesi isterse taşınır |
| `_seed_line_state` + `_ERP_SHIPPED_LINES` | `main.gd:70-74, 1675-1679` | yok | harness: `--product-shot` (`1568, 1603`) dışında `_seed_sales_world` (`1691`) ve meeting-shot (`1888`) | **kalır** (çağıran) |
| `BuildBar.debug_print` | `build_bar.gd:103` | yok | harness 1: `main.gd:1645` (`--product-shot`) | **silinebilir (Faz B)** · `--product-shot` ile zincir |
| `BuildBar.size_scale` + `_px` / `_fs` | `build_bar.gd:44, 110-117` | GÜNC ch03 §2 ve ch12 §3: BuildBar'ın iki ev sahibi, biri "Ürün sayfasındaki izleyici kartı" | yalnız `build_bar.gd` içi (`:111`); tek dış yazanı `creation_flow.gd:584` gidiyor | **kalır** (GÜNC) · yeni sayfa izleyici kartı taşımayacaksa sahip kaydı gerekir |
| `--tab-shot` / `--theme-audit` / `--render-probe` / `--office-shot=…:product` | `main.gd:189, 201, 204` (dağıtım), `317, 763, 970, 1052` (sekmeyi açan satırlar) | (genel araç) | harness | **kalır** (sekme kimliği alan genel araçlar; değişmez) |
| `--product7-shot` (yeni, Faz A) | `main.gd:197, 1651-1670`; röleler `game_shell.gd` | (araç) | harness | **kalır**; Faz B'de canlı kaynakla da çalışır hâle gelir |

`BuildBar.rebuild()` (`build_bar.gd:84`) bu silmeden önce de çağıransızdı; listenin konusu değil.

## 4. Smoke vakaları

| Vaka | Yer (tablo, gövde) | GDD taraması | Bağımlılık | Karar |
|---|---|---|---|---|
| `build_bar_hosts_agree` | `endgame_smoke.gd:266, 4490-4568` | GÜNC ch03 §2 ve ch12 §3 (iki ev sahibi); ch03 §2 | eski yönlendiricinin `_navigate("tracker")` (`:4526`) yolu | **kalır** (GDD) · Faz B'de yeni ev sahibine yeniden yazılır |
| `creation_draft_survives_navigation` | `endgame_smoke.gd:385, 12790-12850` | yok | `creation_flow.gd` ve `ProductTab.tscn` yükler, `creation_draft` kullanır | **silinebilir (Faz B)** |
| `type_screen_matches_line_content` | `endgame_smoke.gd:442, 12877-12908` | ch03 §3 tip ekranı telegrafı, §12.11 | `ProductCatalog.TYPE_SCREEN` | **kalır** (GDD) |
| `loc_product_derived_keys` | `endgame_smoke.gd:327, 11077-11134` | ch03 §12.11 "ad · kategori · açıklama · takas · bahis · pitch, iki dilde" | `PROD_TYPE_*_{CATEGORY,DESC,TRADEOFF}`, `SECTOR_*` | **kalır** (GDD) |
| `loc_b2b_derived_keys` | `endgame_smoke.gd:325, 9900-9937` | Satış §11.1 arketip alanı "sektör" | `SECTOR_` + dört canlı aile (`B2B_CONTACT_`, `B2B_COMPLAINT_`, `FEATURE_LABEL_`, `B2B_PAIN_`) | **kalır** |
| `loc_language_switch` | `endgame_smoke.gd:343, 11408-11453` | (genel dil değişimi) | örnek anahtar `PROD_DEV_VERSION` (`:11419`) | **kalır** · anahtar giderse örnek değiştirilir |
| `save_v13_day_stamps_migrate` | `endgame_smoke.gd:309, 2237-2465` | Zaman §10 kayıt göçü | `mvp_bug_history` (`:2284, 2388-2389`) | **kalır** (bug_trend zinciri) |
| Sistem mantığı vakaları (21): `conversion_bug_penalty`, `line_build_ships_and_stamps`, `cancel_reverts_planned_steps`, `commit_cost_charged_once`, `feature_bug_seed_by_complexity`, `phase_bands_20_60_20`, `live_during_vbuild`, `line_build_writes_subgenre`, `line_design_turns_and_gate`, `infra_capacity_moves_both_ways`, `b2c_satisfaction_gate_experience`, `line_ladder_rules`, `line_k3_locked_without_research`, `card_math_matches_gdd_example`, `run_profile_never_exhausts`, `save_v10_product_state`, `save_double_load_no_residue`, `lever_skill_new_keys`, `fix_run_ships_subset`, `product_read_catalogue`, `ship_tooltip_counts_critical_penalty` | Faz A raporundaki gövdeler | ch03 §2-§12 sistem kuralları | yetim seam'leri UI'sız sınar | **kalır** |

Paket eşikleri güvende: `all_scripts_load` 100 betik ister (silme sonrası ~206), `loc_format_args` 40 yer ister
(238'in 58'i silinen dosyalarda; 180 kalır).

## 5. Tema varyasyonları

| Öğe | Yer | GDD taraması | Çağıran (şimdi) | Karar |
|---|---|---|---|---|
| `ChromeButton` | `build_theme.gd:377-388` | ch03 §16 Frank şeridi; CLAUDE.md §7 Chrome kuralı "Ürün sayfasının Frank şeridi (ChromeButton)" | üretim yok (tek kullanıcı `creation_flow.gd:268` gidiyor); sandbox 33 (`ui_lab` temaları) | **kalır** (GDD + CLAUDE.md) |
| `PriceSlider` | `build_theme.gd:411-422` | ch03 §10 fiyat paneli; §3 "Fiyatın tek evi: v1 yayın anı + canlı fiyat paneli" | üretim yok (`pricing_panel.gd:92`, `publish_flow.gd:236` gidiyor); sandbox 24 | **kalır** (GDD) · grabber dokusu VolumeSlider'la ortak |

Silinen dosyaların kullandığı öbür 26 varyasyonun her birinin set dışında gerçek kullanıcısı var (Faz A raporu §2).

## 6. Token'lar (`UiTokens`)

| Öğe | Yer | GDD taraması | Çağıran (şimdi) | Karar |
|---|---|---|---|---|
| `VEIL_STRONG_CHROME` | `ui_tokens.gd:211` | ChromeButton üzerinden ch03 §16 | üretim 1: `build_theme.gd:381` (ChromeButton hover); sandbox 1 | **kalır** (ChromeButton'la) |
| `axis_experience()` + `AXIS_EXPERIENCE` / `AXIS_EXPERIENCE_CB` | `ui_tokens.gd:155-161, 419-421` | ch03 §17 üçgen, §11.1 Deneyim ekseni | yok (`seams_product.gd:44` ve `sales_probes.gd`'deki `"axis_experience"` ilgisiz bir id) | **kalır** (GDD, üçgenin eksen rengi) |
| `bug_severity()` | `ui_tokens.gd:472-475` | yok: ch03 §8.5 ısınma 20 / 40 eşiklidir, bu 0 / 2 eşikli hata rozeti; aynı kural değil | yok | **silinebilir (Faz B)** |

`NEUTRAL_BADGE_FG` `badge_palette` içinde yaşıyor. UiFactory, HRUiShared, Fmt üyelerinden yetim kalan yok.

## 7. CSV anahtar aileleri (`localization/strings.csv`)

Bugün 199 anahtar yalnız silinecek setten okunuyor (literal ya da `Fmt.count_key` tabanı + `_ONE` ikizi). Hiçbirinin set
dışında okuyucusu yok; karar GDD taramasından gelir. Anahtar listeleri tablonun altında.

| Aile | Sayı | GDD taraması | Karar |
|---|---|---|---|
| A. Konsept adımları: yol seçimi, adım başlıkları, geri bağlantıları | 19 | ch03 §3 "v1: Yol (B2C/B2B) → Tip (alt-tip) → Özellikler → ad · sorumlu ekip · onay"; §16 yol seçimi | **kalır** (GDD) ⚠️ PRD §3.9 |
| B. Tip ekranı | 7 | ch03 §3 tip ekranı telegrafı ("Erken Erişim" etiketi, "Daha büyük ekip ister."); §12.11 kilitli üçlü; GÜNC ch14 §2 | **kalır** (GDD) |
| C. Özellik hat listesi + kilit satırı | 20 | ch03 §12.9 satır anatomisi ve kilit satırı, "hat tamamlandı"; §5 Konsept altbilgisi "Fazla tasarım turu cilayı artırır."; §24 | **kalır** (GDD) |
| D. Konsept ekip paneli + lider | 15 | ch03 §3 ekip seçimi ve ekip lideri, §12.9 alan-gruplu ekip akordeonu; Ekip §4.2 | **kalır** (GDD) |
| E. Maliyet önizlemesi + ad + onay | 14 | ch03 §3 "Toplam efor · süre · bittiğinde kasada $X kalır"; §6.0; GÜNC ch03 §2 (süre "~N hafta") | **kalır** (GDD) |
| F. İptal diyaloğu | 5 | ch03 §2 İptal (MÜHÜRLÜ) "Geliştirme iptal edilsin mi? Tüm sürüm eforu yanar." | **kalır** (GDD) |
| G. Yayın akışı (v1 / v2+) | 14 | ch03 §10 YAYIN AKIŞI, §21; GÜNC ch03 §10, ch06 §2 | **kalır** (GDD) |
| H. Altyapı + kapasite bloğu | 19 | ch03 §10 sağlayıcı ve kapasite, "Kapasite bloğu", brüt marj; §17; ch08; GÜNC ch06 §1.1/§2/§4, ch08 §1/§4 | **kalır** (GDD) |
| I. Fiyat paneli | 19 | ch03 §10 fiyat paneli, §3 fiyatın tek evi | **kalır** (GDD) · §10'un [ÖNERİ, F5 bekler] maddesi "Alt sınır işareti kalkar; hiçbir taban/verdikt yoktur" onaylanırsa `PROD_FLOOR`, `PROD_OPTIMAL`, `PROD_OPTIMAL_UNKNOWN`, `PROD_PRICE_OPTIMAL`, `PROD_PRICE_CHEAP`, `PROD_PRICE_EXPENSIVE` silinebilir |
| J. Ürün Monitörü + portföy | 39 | ch03 §17 monitör alanları (fiyat, MRR, ücretsiz kullanıcı, churn, memnuniyet, ilgi, sürüm + sürüm yaşı, destek, kapasite, brüt marj), Portföy "KİLİTLİ · Series A sonrası" (MÜHÜRLÜ); §1 | **kalır** (GDD) · istisnalar aşağıda |
| K. DESTEK masası + hata sayaçları + trend/risk | 21 | ch03 §8.1 GELEN BİLDİRİM / DOĞRULANMIŞ HATA (mühürlü terimler), §8.2 masa, §8.4 yön okları, §9; GÜNC ch03 §8.2/§9 | **kalır** (GDD; trend/risk etiketleri bug_trend zincirinin) |
| L. Frank satırları | 5 | bkz. §9 | §9'daki satır kararları |
| M. `LOCK_BUILD_IN_PROGRESS` | 1 | ch03 §2 "Aynı anda tek yapım olur." | **kalır** (GDD) |
| N. `UI_OK` | 1 | yok | **silinebilir (Faz B)** |

**J ailesinin istisnaları:**
- `PROD_RIVAL_PASSED` ("{rival} seni geçti."): ch03 §11.3 ve §17 monitörde önde/hizada/geride okumasını reddeder.
  **silinebilir (Faz B) adayı · sahip kararı** (TR metin).
- `PROD_LIVE_VERSION_LC` ("CANLI v{version}"): SPEC §3 ve F raporu gereği rev7 sekmesinin başlık çipi okur; sekme
  (ajan E) bu tarama sırasında henüz ağaçta değildi. **kalır** (rev7).
- `PROD_MARKET_SHARE`: tek izi bir smoke docstring'i (`endgame_smoke.gd:11217`); "pazar payı merdiveni" ch03 §12.11,
  GÜNC ch12 §2. **kalır** (GDD).

**Okuyucu fonksiyonu yetim kalan türetilmiş aileler:**

| Aile | Sayı | Kurucu (şimdi çağıransız) | Çağıran (şimdi) | GDD taraması | Karar |
|---|---|---|---|---|---|
| `PROD_TYPE_<ID>_{CATEGORY,DESC,TRADEOFF}` | 39 | `ProductCatalog.type_category / type_desc / type_tradeoff` (`product_catalog.gd:331-341`) | smoke: `loc_product_derived_keys` (`:11088`) | ch03 §12.11 "ad · kategori · açıklama · takas · bahis · pitch, iki dilde" | **kalır** |
| `SECTOR_*` | 26 (23 + zaten yalnız smoke'ta olan `SECTOR_TESTING`, `SECTOR_TEXTILE`, `SECTOR_FALLBACK`) | `ProductCatalog.type_sector_labels` (`:344-348`) | smoke: `:9910`, `:11093` | Satış §11.1 arketipin "sektör" alanı | **kalır** |
| `PROD_INFRA_PROVIDER_{LOCAL,CLOUD,ENTERPRISE}`, `PROD_INFRA_QUALITY_{…}`, `PROD_INFRA_START_HINT` | 7 | `InfraSystem.provider_name_key`, `provider_quality_key` (`infra_system.gd:142-149`), `KEY_START_HINT` (`:81`) | yok | ch03 §10 sağlayıcı tablosu ("Kalite farkı"), öneri satırı "Tahmini ilk ay: ~1.000 kullanıcı" | **kalır** (GDD) |

**Okuyucusu canlı kalan aileler (bilgi):** `PROD_TYPE_<ID>_NAME` 13 (`ProductCatalog.type_name`: `product_system.gd:1267`,
`sales_system.gd:529`, rev7 `product_model.gd:83`) · `PROD_LINE_<X>` hat adları 20 (`product_lines.gd:324`,
`rnd_card_modal.gd:127`) · `PROD_STEP_*` 150 (`product_lines.gd:189`; `B2BConstants.feature_label`:
`seams_ported.gd:83`, `sales_tab.gd:494`, `sales_meeting_adapter.gd:238`). Hepsi **kalır**.

**Set dışında da okunan, kalan 11 anahtar:** `FIN_CAP_MRR` (TopBar.tscn:74, month_summary_modal.gd:52),
`HR_SEARCH_CANCEL_OK` (hr_tab.gd:251), `PRODUCT_FALLBACK_NAME` (sales_system.gd:528), `PROD_FIX_RUN_START` /
`PROD_FIX_RUN_END` (build_bar_model.gd:158), `PROD_LAUNCH_PLAIN` (build_bar_model.gd:127), `PROD_VERSION_SHORT`
(build_bar_model.gd:171, rev7 product_model.gd:75), `PROD_MENTOR_TAG` (MonthSummaryModal.tscn:146),
`PROD_TEAM_GROUP_COUNT` (rnd_assign_panel.gd:165), `UI_DISMISS` (confirm_modal.gd:37 ve diğerleri), `PROD_DEV_VERSION`
(yalnız smoke `loc_language_switch` örneği; ch03 §3 v2+ akışı "Geliştir · v{n}"). Hepsi **kalır**.

Kapsam dışı: silmeden önce de okuyucusu olmayan 15 `BUILD_*` / `PROD_*` anahtarı (Faz A raporu §1e).

### Anahtar listeleri

- **A (19):** PROD_BACK_PATH, PROD_BACK_PORTFOLIO, PROD_BACK_TYPE, PROD_PATH_B2B, PROD_PATH_B2B_CON1, PROD_PATH_B2B_CON2,
  PROD_PATH_B2B_DESC, PROD_PATH_B2B_PRO, PROD_PATH_B2C, PROD_PATH_B2C_CON, PROD_PATH_B2C_CON2, PROD_PATH_B2C_DESC,
  PROD_PATH_B2C_PRO, PROD_PATH_PICK, PROD_PATH_SUB, PROD_PATH_TITLE, PROD_STEP_FEATURES, PROD_STEP_PATH, PROD_STEP_TYPE
- **B (7):** PROD_TYPE_EA_TAG, PROD_TYPE_EXAMPLES, PROD_TYPE_LOCKED_REASON, PROD_TYPE_SLOT_NAME, PROD_TYPE_SLOT_REASON,
  PROD_TYPE_STEP_SUB, PROD_TYPE_STEP_TITLE
- **C (20):** PROD_ACTION_FEATURE_DESC, PROD_EFFORT_N, PROD_FEATURE_COUNT, PROD_LINES_EMPTY, PROD_LINES_HEADER,
  PROD_LINE_COMPLETE, PROD_LINE_CONTRIB, PROD_LOCK_ACTION_PERSON, PROD_LOCK_ACTION_RESEARCH, PROD_LOCK_ACTION_TOTAL,
  PROD_LOCK_PERSON, PROD_LOCK_PREFIX, PROD_LOCK_RESEARCH, PROD_LOCK_RESEARCH_SOON, PROD_LOCK_TOTAL, PROD_POLISH_NOTE,
  PROD_SELECTED, PROD_SELECTED_COUNT, PROD_UNPLANNED, PROD_UPPER_OPEN
- **D (15):** PROD_TEAM_FILTER_AREA_ALL, PROD_TEAM_FILTER_AVAILABLE, PROD_TEAM_FILTER_SEARCH, PROD_TEAM_GROUP_SELECTED,
  PROD_TEAM_HEADER, PROD_TEAM_HEADER_SUB, PROD_TEAM_LEAD, PROD_TEAM_LEAD_NONE, PROD_TEAM_LEAD_PICK,
  PROD_TEAM_PINNED_CAPTION, PROD_TEAM_PINNED_HINT, PROD_TEAM_REFUSE_INACTIVE, PROD_TEAM_REFUSE_JOB_CAP,
  PROD_TEAM_REFUSE_OTHER, PROD_TEAM_REFUSE_ROLE
- **E (14):** PROD_CASH_AFTER, PROD_CASH_DEDUCT, PROD_CONFIRM_START, PROD_DRAFT_CHIP, PROD_ETA_WEEKS, PROD_NAME_LABEL,
  PROD_NAME_SUGGEST, PROD_PROFILE, PROD_TOTALS, PROD_TOTALS_COST, PROD_TOTALS_COST_ONE, PROD_TOTALS_ONE, PROD_WEEKS,
  PROD_WEEKS_ONE
- **F (5):** PROD_CANCEL_BUILD, PROD_CANCEL_BUILD_BODY, PROD_CANCEL_BUILD_COST, PROD_CANCEL_BUILD_COST_ONE,
  PROD_CANCEL_BUILD_Q
- **G (14):** PROD_PUB_AXIS_SUMMARY, PROD_PUB_BUGS_CARRIED, PROD_PUB_CONFIRM_TITLE, PROD_PUB_INFRA_TITLE,
  PROD_PUB_PRICE_TITLE, PROD_PUB_ROW_FEATURES, PROD_PUB_ROW_INFRA, PROD_PUB_ROW_PRICE, PROD_PUB_ROW_VERSION,
  PROD_PUB_STEP_CAPTION, PROD_PUB_STEP_CONFIRM, PROD_PUB_STEP_INFRA, PROD_PUB_STEP_PRICE, PROD_PUB_V2_TITLE
- **H (19):** PROD_CAPACITY, PROD_CAPACITY_BILL, PROD_CAPACITY_LOAD, PROD_CAPACITY_LOAD_VALUE, PROD_CAPACITY_MARGIN,
  PROD_CAPACITY_OCCUPANCY, PROD_CAPACITY_OF, PROD_CAPACITY_OVER_BADGE, PROD_CAPACITY_UNSET, PROD_INFRA_CAPACITY_HEAD,
  PROD_INFRA_CAPACITY_ONLY, PROD_INFRA_CHANGE, PROD_INFRA_COMMIT, PROD_INFRA_HEADROOM_SEATS, PROD_INFRA_HEADROOM_USERS,
  PROD_INFRA_MONTHLY_BILL, PROD_INFRA_PROVIDER_HEAD, PROD_INFRA_UNITS_N, PROD_INFRA_UNIT_PRICE
- **I (19):** PROD_ACTION_PRICE, PROD_ACTION_PRICE_B2B, PROD_COST_PER_USER, PROD_FLOOR, PROD_GUT_PRICE, PROD_LIVE_PRICE,
  PROD_OPTIMAL, PROD_OPTIMAL_UNKNOWN, PROD_PER_MONTH, PROD_PER_USER, PROD_PER_USER_MONTH, PROD_PRICE_CHEAP,
  PROD_PRICE_COMMIT, PROD_PRICE_DRAFT, PROD_PRICE_EXPENSIVE, PROD_PRICE_N, PROD_PRICE_OPTIMAL, PROD_PRICE_RAISE,
  PROD_PRICING
- **J (39):** BUILD_LIVE_VERSION, PROD_AXIS_EXPERIENCE_N, PROD_AXIS_INNOVATION_N, PROD_AXIS_STABILITY_N,
  PROD_BUILD_STATUS_HEADER, PROD_CHURN_CAP, PROD_CONVERSION, PROD_CUSTOMERS_CAP, PROD_EFFECTIVE_STABILITY, PROD_FLAT,
  PROD_GO_TO_SALES, PROD_HEALTHY, PROD_INTEREST_CAP, PROD_IN_DEVELOPMENT, PROD_IN_DEV_PCT, PROD_LIVE_SUFFIX,
  PROD_LIVE_VERSION_LC, PROD_LIVE_WEEKS, PROD_LIVE_WEEKS_ONE, PROD_LOCKED_SERIES_A, PROD_MARKET_SHARE,
  PROD_MRR_CONTRIB_CAP, PROD_NEW_PRODUCT, PROD_PAYING, PROD_PORTFOLIO, PROD_PORTFOLIO_COUNT, PROD_PROMISED,
  PROD_RIVAL_PASSED, PROD_ROW_B2B, PROD_ROW_B2C, PROD_STATUS, PROD_SUPPORT, PROD_TRYING_CAP, PROD_UNKNOWN, PROD_VERSIONS,
  PROD_VERSION_LIVE, PROD_WITH_SALES, SALES_CUSTOMER, SALES_SATISFACTION
- **K (21):** PROD_BUGS_CONFIRMED, PROD_BUGS_TREND, PROD_BUG_RISK_CAP, PROD_DESK_ACCOUNTS_ONLY, PROD_DESK_EMPTY,
  PROD_DESK_FOUNDER_BUSY, PROD_DESK_FOUNDER_PASSIVE, PROD_DESK_STAFFED, PROD_FIX_REFUSAL_DESK_SHUT,
  PROD_FIX_REFUSAL_NOT_LIVE, PROD_FIX_REFUSAL_NO_BUGS, PROD_FIX_REFUSAL_RUNNING, PROD_FIX_RUN_FIXED_N, PROD_OPEN_BUGS,
  PROD_REPORTS_INCOMING, PROD_RISKY, PROD_RISK_HIGH, PROD_RISK_LOW, PROD_RISK_MID, PROD_TREND_FALLING, PROD_TREND_RISING
- **L (5):** PROD_MENTOR_LINE, PROD_READY_TALK_FRANK, PROD_TIP_BUGS, PROD_TIP_GOOD, PROD_TIP_WEAK
- **M, N (2):** LOCK_BUILD_IN_PROGRESS, UI_OK

## 8. GDD'de adı geçen seam'ler (sistem fonksiyonları)

**Silmeyle hiç çağıranı kalmayanlar:**

| Öğe | Yer | GDD taraması | Çağıran (şimdi) | Karar |
|---|---|---|---|---|
| `ProductSystem.set_build_lead` | `product_system.gd:349` | ch03 §3 "oyuncu ekip panelinden yeni lider atayabilir"; Ekip §4.2 | yok | **kalır** (GDD) |
| `ProductSystem.estimate_line_build_weeks` (+ tek çağıranı olduğu `projected_speed_factor_with_extra_job`) | `product_system.gd:1162, 234` | ch03 §3 maliyet önizlemesi "Toplam efor · süre"; §6.0; GÜNC ch03 §2 "~N hafta" | yok (`projected_speed_factor_with_extra_job` yalnız `:1167`'den) | **kalır** (GDD) |
| `ProductSystem.CANCEL_FREE_WEEKS` | `product_system.gd:116` | ch03 §2 İptal (MÜHÜRLÜ): TASARIM'da serbest iptal | yok | **kalır** (GDD) |
| `ProductSystem.phase_label_key` | `product_system.gd:322` | yok | yok (`BUILD_PHASE_*` anahtarları `build_bar.gd` üzerinden yaşıyor) | **silinebilir (Faz B)** |
| bug_trend zinciri: `bug_trend`, `health_state`, `product_bug_risk`, `_bug_trend_delta`; `TREND_DELTA`, `TREND_SPIKE`, `HEALTH_EFF_STAB_RATIO`, `BUG_RISK_ORTA`, `BUG_RISK_YUKSEK`, `BUG_HISTORY_WEEKS`; `daily_tick` penceresi | `product_system.gd:130-135, 189-197, 1387-1418` | ch03 §8.4 "Sayaçlar yön okları taşır (▲ baskı artıyor, ▼ iş eriyor)" | dış çağıran yok; zincir kendi içinde (`:1396, 1407`); bayrak §2'de | **kalır** (sahip kararı) |
| `InfraSystem.provider_name_key`, `provider_quality_key` | `infra_system.gd:142-149` | ch03 §10 sağlayıcı tablosu, "Kalite farkı"; §22 | yok | **kalır** (GDD) |
| `InfraSystem.occupancy_pct` | `infra_system.gd:193` | ch03 §10 "doluluk çubuğu (mevcut / etkin kapasite · %)" | yok | **kalır** (GDD) |
| `InfraSystem.suggested_start_headroom` + `KEY_START_HINT` | `infra_system.gd:248, 81` | ch03 §10 Altyapı adımının öneri satırı "Tahmini ilk ay: ~1.000 kullanıcı" | yok | **kalır** (GDD) |
| `InfraSystem.gross_margin_monthly` | `infra_system.gd:266` | ch03 §10 "Brüt marj = MRR − sunucu faturası; monitörde gösterilir, Finans tüketir", §17, §23; ch08; GÜNC ch06 / ch08 | yok | **kalır** (GDD) |
| `ProductCatalog.suggest_product_name` + `PRODUCT_NAME_POOL` | `product_catalog.gd:304-311` | ch03 §3 Konsept'in "ad" adımı | yok (havuz yalnız `:311`'de okunur) | **kalır** (sahip kararı) |
| `ProductCatalog.type_category`, `type_desc`, `type_tradeoff`, `type_sector_labels` | `product_catalog.gd:331-348` | ch03 §12.11 alt-tip kayıtları "ad · kategori · açıklama · takas · bahis · pitch"; §3 tip ekranı | yok | **kalır** (GDD) |
| `RivalRegistry.get_player_rank_in_startup_league` | `rival_registry.gd:75` | ch03 §12.11 "pazar payı merdiveni" (rakip adları) | yok | **kalır** (sahip kararı) |
| `CustomerRegistry.get_total_users` | `customer_registry.gd:75` | ch03 §17 "Ücretsiz kullanıcı ('deneyen' her yüzeyde yeniden adlandırılır)", §21 | yok | **kalır** (GDD) |
| `SalesSystem.apply_b2c_price` | `sales_system.gd:489` | ch03 §10 "fiyat konmadan v1 yayını tamamlanamaz", §3 canlı fiyat paneli | yok (B2C ücretli katmanı açan tek oyun yolu; `open_b2c_paid_tier` fikstürdür) | **kalır** (GDD) |

**UI'dan yetim kalanlar (yalnız smoke / probe / harness çağırıyor):**

| Öğe | Yer | GDD taraması | Çağıran (şimdi) | Karar |
|---|---|---|---|---|
| `ProductSystem.start_line_build` (+ `validate_line_plan`, `effort_ceiling`, `projected_line_dims`) | `product_system.gd:1187, 1130, 1156, 1172` | ch03 §2 Konsept → TASARIM; §12.7 "Kontrol Konsept onayında yapılır" | smoke 22 (`endgame_smoke.gd:12923…`); probe 4 (`run_probe.gd:696, 697, 1009, 1020`); harness 3 (`main.gd:1490, 1495, 1591`) | **kalır** (çağıran + GDD) |
| `ProductSystem.launch` | `product_system.gd:1014` | ch03 §10 yayın akışı, §19 `version_shipped` | smoke 9 (`:1274, 3037, 3108, 3528…`); probe 1 (`run_probe.gd:997`); kart notlarında ad geçer (`first_ship.json`, `version_ship.json`) | **kalır** |
| `ProductSystem.cancel_build` | `product_system.gd:1344` | ch03 §2 İptal (MÜHÜRLÜ) | smoke 3 (`:2943, 3014, 13945`) | **kalır** |
| `InfraSystem.set_provider`, `set_capacity`, `adjust_capacity`, `suggested_start_units` | `infra_system.gd:224-247` | ch03 §10 "Sağlayıcı canlıda her an değiştirilebilir", "Kapasite ±1 birim" | smoke 19; probe 3 (`run_probe.gd:844, 845, 849`) | **kalır** |
| `SalesSystem.estimate_price_change` | `sales_system.gd:473` | ch03 §10 fiyat paneli | smoke 2 (`:12025, 12027`) | **kalır** |
| `ProductCatalog.TYPE_SCREEN`, `TYPE_SCREEN_SLOT`, `playable_types`, `locked_type_ids` | `product_catalog.gd:51-80` | ch03 §3 tip ekranı (MÜHÜRLÜ), §12.11 "yol başına 3 kilitli kart" | smoke 3 (`:12880, 12884, 12890`) | **kalır** |
| `LineGates.unmet_parts` | `line_gates.gd:95` | ch03 §12.9 "Kilit satırı yalnız karşılanmayan parçaları yazar", §24 | smoke 1 (`:14626`) | **kalır** |
| `ProductLines.net_gain`, `axis_of`, `is_complete` | `product_lines.gd:414, 375, 484` | ch03 §12.9 "parantezde net kazanç", tamamlanmış hat | smoke 7; probe 1 (`run_probe.gd:942`) | **kalır** |
| `ProductState.axis_readings` | `product_state.gd:239` | ch03 §11.3 okuma, §19 `urun.axis_reading` | smoke 4 (`:14505, 15071, 15125, 15128`) | **kalır** |
| `PromiseRegistry.get_all` | `promise_registry.gd:30` | yok | smoke 1 (`:9260`); probe 2 (`run_probe.gd:380, 1003`) | **kalır** (çağıran) |
| `SkillCheck.can_read_prospect` | `skill_check.gd:103` | yok | smoke 4 (`:6301-6305`) | **kalır** (çağıran) |

## 9. Frank anahtarları

| Öğe | Yüzey (silinen) | GDD taraması | Çağıran (şimdi) | Karar |
|---|---|---|---|---|
| `PROD_MENTOR_LINE` | yol adımındaki Frank şeridi (`creation_flow.gd`) | ch03 §16 Frank şeridi; TR metni §16'nın emekli dediği kompozit satır ("kalabalığa satarsın / herkesi tanırsın"); `FRANK_VOICE_INVENTORY.md` satır 2 | yok | **kalır** (şerit §16'da) · metnin değişimi sahibin |
| `PROD_TIP_BUGS`, `PROD_TIP_GOOD`, `PROD_TIP_WEAK` | monitör şeridi (`detail_view.gd`) | ch03 §17 üçgen kuralı "Sayfada tavsiye/uyarı cümlesi … yoktur", §23 "italik tavsiye satırı kaldırıldı"; envanter satır 15 | yok | **sahip kararı** · GDD satırı kaldırır, Frank külliyatı onaysız silinmez |
| `PROD_READY_TALK_FRANK` | monitör rozeti "HAZIR · FRANK'LE KONUŞ" | yok; envanterde ses satırı değil, kimlik/eşlik anahtarı | yok | **silinebilir (Faz B)** · TR metin silme onayı |
| `PROD_MENTOR_TAG` | aylık özet | (kimlik) | üretim: `MonthSummaryModal.tscn:146` | **kalır** (çağıran) |

## 10. BuildHUD → PublishFlow bağı

| Öğe | Yer | GDD taraması | Çağıran (şimdi) | Karar |
|---|---|---|---|---|
| `Model.PHASE_BETA: PublishFlow.open()` | `build_bar.gd:330` | ch03 §10 yayın akışı (v1 fiyat · altyapı · onay; v2+ tek tık YAYINLA), §21; GÜNC ch03 §10 | üretim 1 (`build_bar.gd:330`, BETA kararı; `ProductSystem.launch`'a giden tek oyun yolu); harness 1 (`main.gd:1642`) | **kalır** (bağ) · Faz B'de yeni yayın girişine taşınır; taşınmazsa `build_bar.gd` derlenmez ve `all_scripts_load` düşer |

## 11. Sinyaller (silmeyle dinleyicisi azalan)

| Sinyal | GDD taraması | Yayıcı (şimdi) | Karar |
|---|---|---|---|
| `fix_run_started`, `fix_run_finished`, `bug_confirmed`, `unconfirmed_threshold_crossed` | ch03 §19 "Sinyaller (dinleyicisi olmasa da yayınlanır)" | `support_system.gd:315, 332`; `product_read.gd:200, 203`; smoke `:14093-14124` | **kalır** |
| `infra_changed` | ch03 §10 altyapı | `product_state.gd:223, 231` | **kalır** (yayıcı) |
| `customer_mrr_changed` | (ch03 dışı) | `customer_registry.gd:150` | **kalır** (yayıcı) |
| `promise_created`, `promise_kept` | Satış söz sistemi | `promise_registry.gd:72, 153`; probe `run_probe.gd:182-183` | **kalır** |

`docs/EVENT_SIGNAL_MANIFEST.md` silmeden sonra yeniden üretilir (elle düzenlenmez).

## 12. Güncellenecek belge ve yorumlar (silme değil)

| Yer | Ne |
|---|---|
| CLAUDE.md §7 (Chrome kuralı), §12 (shot ailesi) | Frank şeridi ve `--product-shot` adları; `--product7-shot` eklenir |
| `docs/HARITA.md:86, 87, 105, 111-112, 114, 122` | `_view_node` / `_view_id` / `_navigate`, iki smoke vakası, UI sınıfları, `launch` / `cancel_build` girişleri, product-shot türleri |
| `docs/ACIK_ISLER/ISLER.md:22-23, 41-42`; `ACIK_KARARLAR.md` #41, #43, #46, #48-#52, #54, #65, #80, #82 ve Chrome maddesi | sahip dokunur (CLAUDE.md §3) |
| `docs/writing/FRANK_VOICE_INVENTORY.md:53, 66, 101, 159`; `FRANK_ORPHANS.md:22`; `frank/STRUCTURAL_DEFECTS.md:146`; `Frank Diyalogları · v6.md:542` | Frank yüzeyleri sahibin |
| `GDDs/GUNCELLEMELER.md` (ch03 §2/§3/§10/§16/§17, ch12 §3/§5) | rev 7 kaydı sahibin |
| Kod yorumları: `window_layer.gd:71`, `left_tabs.gd:56`, `rnd_tab.gd:49, 236`, `rnd_ui_shared.gd:14, 196`, `rnd_assign_panel.gd:8`, `research_bar.gd:198`, `build_bar.gd:3-5, 19, 43`, `bar_kit.gd:8`, `build_hud_panel.gd:5`, `cash_curve.gd:7`, `game_shell.gd:61`, `sales_system.gd:21, 242-243, 445`, `support_system.gd:172`, `main.gd:2002-2003` (saati build commit'in açtığı yorumu), `endgame_smoke.gd:15382` | silinen sınıf ve dosya adları |
| `.godot/global_script_class_cache.cfg` | beş class_name düşer: `--headless --import` |

## Özet

| Kategori | kalır | silinebilir (Faz B) | sahip kararı |
|---|---|---|---|
| Dosyalar | 2 | 0 | 0 |
| Bayraklar | 2 | 2 | 0 |
| Harness | 4 | 3 | 0 |
| Smoke vakaları | 6 (+21 sistem vakası) | 1 | 0 |
| Varyasyonlar | 2 | 0 | 0 |
| Token'lar | 2 | 1 | 0 |
| CSV aileleri (199 anahtar) | 12 aile, 192 anahtar (L ailesi §9'da) | `UI_OK` | `PROD_RIVAL_PASSED`; §10 [ÖNERİ] onaylanırsa 6 fiyat anahtarı |
| Türetilmiş aileler | 3 aile, 72 anahtar | 0 | 0 |
| Seam'ler | 24 | 1 (`phase_label_key`) | 0 |
| Frank anahtarları | 2 | 1 (`PROD_READY_TALK_FRANK`) | `PROD_TIP_*` (3) |
| BuildHUD bağı | 1 | 0 | 0 |
| Sinyaller | 4 satır | 0 | 0 |
