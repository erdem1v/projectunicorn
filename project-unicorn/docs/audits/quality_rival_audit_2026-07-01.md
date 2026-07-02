# Kalite & Rakip Sistemi Zemin Raporu (Audit)

**Tarih:** 2026-07-01 · **Tür:** Salt-okunur (kod değiştirilmedi) · **Amaç:** Product Redesign Part 1 spec zemini (kalite: tek int → çok-boyutlu + rakip-göreli).
**Kapsam:** 3 bölge — (1) `mvp_quality` tam izi, (2) rakip sistemi mevcut hâli, (3) sub-type + feature şeması ↔ kalite kesişimi.

---

## BÖLGE 1 — Kalite tam izi (yaz/oku)

### 1.0 KRİTİK: iki ayrı kalite yüzeyi var (+ bir ölü flag)

Redesign'da **her ikisini de** değiştirmek gerekir; sadece flag'e bakmak build-içi yüzeyi kaçırır.

| Yüzey | Nerede | Ömür | Kim yazıyor | Kim okuyor |
|---|---|---|---|---|
| **Canlı build kalitesi** `FeatureBuild.quality` (int) | resource alanı, `feature_build.gd:29` | Build süresince mutasyon | ProductSystem tick'leri + `advance_iteration` + `apply_quality_bonus` | BuildHUDPanel, BuildProgressView (yalnız ship-öncesi) |
| **Ship snapshot** `flags["mvp_quality"]` | GameState flag | `launch()`'ta dondurulur, PostShip'te sabit | `product_system.gd:165` (tek yazan) | SalesSystem (6), PitchSystem (1), ProductTab PostShip (2) |
| ~~`flags["product_quality"]`~~ | GameState flag | `ship_active_build()`'ta yazılır | `product_system.gd:276` | **HİÇ KİMSE** — ölü yazım (spec §5.1 "future read" diyor ama gerçek okuma `mvp_quality`) |

> Not: PROJECT_SPEC §5.1 canonical flag olarak `product_quality` diyor; **kod `mvp_quality`'yi kullanıyor.** Redesign spec'i bu ikiliğe dikkat etmeli.

### 1.1 YAZMA noktaları

Kalite yalnız **günlük tick**te (TimeManager daily slot 1) ve buton/event ile değişir — saatlik değil. `tech = GameState.get_founder_skill("tech")`.

| # | Yer (dosya:satır) | Ne zaman | Formül |
|---|---|---|---|
| W1 | `product_system.gd:215` `start_build` | Build başlarken | `quality = QUALITY_BASELINE = 50` ( v.tabanı; 0 değil) |
| W2 | `product_system.gd:80-81` `_tick_iteration_phase` | iteration günlük (karar-bekleme dışında) | `quality += round(1.5 + tech·1.0)` · clamp 0-100 |
| W3 | `product_system.gd:129` `advance_iteration` | "Bir iterasyon daha" butonu | `quality += QUALITY_PER_ITERATION = 5` (anlık, gün beklemez) |
| W4 | `product_system.gd:98-99` `_tick_development_phase` | development günlük | `quality += round(1.5 + tech·1.0)` · clamp |
| W5 | `product_system.gd:116` `_tick_bugfix_phase` | bugfix günlük | `quality += POLISH_QUALITY_BUMP_PER_DAY = 1` · clamp |
| W6 | `product_system.gd:261-264` `apply_quality_bonus` | Event modifier (`quality_bonus`) | `quality += amount` · clamp — build event seçeneklerinden |
| W7 | `product_system.gd:165` `launch` | LAUNCH anı | `set_flag mvp_quality = active_build.quality` (snapshot) |
| W8 | `product_system.gd:276` `ship_active_build` | Ship modal sonrası | `set_flag product_quality = quality` (**okunmuyor**) |

İlgili yan-snapshotlar (kalite değil ama redesign'da beraber taşınır): `mvp_bug_count_at_launch` (`:166`), `mvp_iteration_count` (`:167`), `mvp_sub_product_type_id` (`:169`), `mvp_market_type` (`:170`), `mvp_components` (`:277`), `bug_count_at_bugfix_start_<id>` (`:107`, okunmuyor). LAUNCH'ta `critical_bug_unfixed` flag'i varsa `bug_count += 5` (`:163`).

**Event `quality_bonus` modifier'ları** (W6 üstünden dokunan): `iter_001`+4/−2, `dev_001`+3, `dev_002`+3, `dev_003`−2, `bugfix_001`+4, `bugfix_002`+2, `bugfix_003`+3. Hepsi canlı `FeatureBuild.quality`'ye eklenir (snapshot'tan önce).

### 1.2 OKUMA noktaları — her biri: **nasıl** kullanıyor + **yeni model notu**

Kullanım tipi: **ÇARPAN** = lineer katsayı/toplam terimi · **EŞİK** = gate/band · **SEED** = başlangıç değeri · **GÖSTERİM** = sadece UI.

| # | Yer (dosya:satır / fonksiyon) | Okur | Nasıl kullanıyor | Tip | Yeni model notu (boyut mu / bileşik mi) |
|---|---|---|---|---|---|
| R1 | `sales_system.gd:105-108` `_tick_b2c_audience` | mvp_quality, bugs | Saatlik audience delta: `+ quality·0.006`, `− bugs·0.03` | **ÇARPAN** (saatlik büyüme) | En etkili tüketici. Muhtemelen **bileşik skor** ya da **Innovation+Usability** karışımı beslemeli |
| R2 | `sales_system.gd:136-147` `_ensure_b2c_record` | mvp_quality | B2C userbase başlangıç `satisfaction = quality` | **SEED** | **Usability/Stability** boyutu daha uygun |
| R3 | `sales_system.gd:204-211` `_tick_satisfaction` | mvp_quality, bugs | `quality ≥ 70 → sat +1/gün`; `bugs > 5 → sat −1/gün` | **EŞİK** (70 / 5) | Memnuniyet = **Stability/Usability** eksenine bağlanmalı |
| R4 | `sales_system.gd:238-253` `product_value` | mvp_quality, bugs, mvp_components | Optimal fiyat: `raw = 4 + quality·0.12 + feat·1.2 + complexity·0.6 − bugs·0.5`, `×tendency` | **ÇARPAN** (fiyat) | Fiyat gücü = **Innovation** (premium) ağırlıklı olabilir |
| R5 | `sales_system.gd:266-281` `_value_lines` | mvp_quality, bugs | Fiyat gerekçe metni: quality bandları **75 / 50**; bug bandları 0/≤4/>4 | **EŞİK+GÖSTERİM** | Boyut-başına ayrı satır gösterme fırsatı |
| R6 | `sales_system.gd:379-384` `growth_band` | mvp_quality, bugs | R1 ile aynı delta → sözel band ("büyüyor/eriyor") | **ÇARPAN→EŞİK** | R1 ile senkron kalmalı (aynı bileşimi okumalı) |
| R7 | `sales_system.gd:292-297` `conversion_rate` (dolaylı) | product_value optimal | `rate = 0.35·(optimal/price)` — optimal kalite-türevli | **ÇARPAN (dolaylı)** | R4 üzerinden otomatik gelir |
| R8 | `sales_system.gd:300-316` `churn_fraction`, `audience_growth_multiplier` (dolaylı) | product_value optimal | Zam tepkisi + fiyat çarpanı — optimal üstünden | **ÇARPAN (dolaylı)** | R4 üzerinden otomatik |
| R9 | `pitch_system.gd:248,269` `_resolve_outcome` | mvp_quality | İmzalanan **B2B** müşterinin başlangıç `satisfaction = quality (+5 crit)`. **Sonucu (band) etkilemez** — sadece seed | **SEED** (B2B) | B2B tarafı: **Stability/Usability** seed; ayrıca pitch başarısına kaliteyi bağlama fırsatı (şu an bağlı değil) |
| R10 | `product_tab.gd:607,632` `_paint_post_ship` / `_frank_ship_reaction` | mvp_quality, bugs | PostShip Frank repliği: `quality ≥ 80` / `bugs > 8` bandları | **EŞİK+GÖSTERİM** (80 / 8) | Boyut-farkındalıklı repliklere çevrilebilir |
| R11 | `build_hud_panel.gd:90` | `active_build.quality` (canlı) | HUD `"Kalite %d"` | **GÖSTERİM** (ship-öncesi) | Çok-boyut → çoklu mini-gösterge gerekir |
| R12 | `product_tab.gd:443` BuildProgressView | `active_build.quality` (canlı) | Status `"%d / 100"` | **GÖSTERİM** (ship-öncesi) | 0-100 tek-int varsayımı; açık-uçlu modelde kaldırılır |

**Kalite göstermeyen ama beklenebilecek yerler (teyit):** DesignDocumentView "TAHMİN" paneli → `Row_QualityCeiling` **koda gizli** (hiç dolmuyor). RightPanel → kaliteyi hiç okumuyor. Projeksiyon → yok.

---

## BÖLGE 2 — Rakip sistemi mevcut hâli

### 2.1 RivalRegistry / RivalModel / Rival data — **hiçbiri yok**

- `scripts/autoload/` içinde **rival yok** (yalnız Character/Customer/Prospect + GameState/EventManager/TimeManager/SaveManager/Settings/EventBus). `project.godot [autoload]`'da rival kaydı yok (`CustomerRegistry`=24, `ProspectRegistry`=25 var).
- `data_models/` içinde **RivalModel/Rival yok**. `data/` içinde rakip JSON'u yok.
- **EventBus'ta rakip sinyali yok.** `right_panel.gd:21` bir *TODO* olarak `EventBus.rival_status_changed` ve `RivalAI.get_active_rivals()` adlarını anıyor — ikisi de mevcut değil (isim de "RivalAI", "RivalRegistry" değil; spec adlandırmayı netleştirmeli).

### 2.2 Sağ paneldeki "ACTIVE RIVALS" — tamamen placeholder

- Sahne (`RightPanel.tscn:265-353`): `RivalsSection` içinde **hardcoded 3 örnek satır**, hepsi `visible=false`:
  - `Rival1`: "Kerem @ Volthane" / `HIRING`
  - `Rival2`: "Despina @ Mavi-Loop" / `QUIET`
  - `Rival3`: "Ortega @ Bytecraft" / `PIVOTING`
  - `EmptyStateLabel` (`:349`): **"Rakip izlenmiyor"** (`visible=false`, kod açar).
- Kod (`right_panel.gd:144-152` `_refresh_rivals`): registry yok; **her zaman** 3 satırı gizler, `CountLabel="0"`, `EmptyStateLabel.visible=true`. Yani ekranda daima **"Rakip izlenmiyor" + 0**. Veri kaynağı **boş/yok** — hardcoded örnekler sadece tasarım placeholder'ı, canlı veri değil.

### 2.3 Referans pattern — registry + model (RivalRegistry'yi aynen böyle kur)

En temiz örnek **CustomerRegistry + Customer**:

- **Model** (`data_models/customer.gd`): `class_name Customer extends Resource`; `@export` alanlar (id, company_name, market_type, mrr, satisfaction…) + **forward-compat rezerv alanlar** default'la tanımlı (retrofit'siz genişleme). "Naming caution: `name` değil `company_name`" konvansiyonu.
- **Registry** (`autoload/customer_registry.gd`): `extends Node` (autoload); depolama `var _customers: Dictionary = {}  # id → Customer`; Read API `get_customer(id)/get_all()/get_active()/get_total_mrr()`; **mutasyonlar registry metodundan geçer ve `EventBus`'a sinyal emit eder** (registry kimin dinlediğini bilmez — RightPanel/SalesTab kendini günceller).
- **Kayıt** (`project.godot [autoload]`): `RivalRegistry="*res://scripts/autoload/rival_registry.gd"` satırı eklenir (`*` = enabled).
- **Sinyal**: `event_bus.gd`'a `rival_added/rival_status_changed` vb. eklenir; `right_panel.gd:_refresh_rivals` `_refresh_customers` ile birebir aynı pattern'e çevrilir (satırları `RivalRegistry.get_active_rivals()`'tan doldur, boşsa empty state).

> Prospect/Character registry'leri de aynı iskelet (autoload Node + `Dictionary` + EventBus emit). Herhangi biri şablon olarak yeterli.

---

## BÖLGE 3 — Sub-type + Feature şeması (kalite kesişimi)

**Konum & format:** Hepsi `scripts/systems/product_catalog.gd` içinde **GDScript `const` dict** (hardcoded, JSON değil). Yorum: *"Hardcoded for demo; JSON externalization to data/products/ is content-phase work."* → yeni alanlar şimdilik bu dict'lere eklenir; ileride `data/products/*.json`'a taşınabilir.

### 3.1 Sub-product type kaydı — tam alanlar
`SUB_PRODUCT_TYPES[subgenre][]` → her kayıt:
```
{ id, name, pitch, market_type, price_tendency? }
```
| Alan | Var mı | Not |
|---|---|---|
| id, name | ✓ | kimlik + görünen ad |
| pitch | ✓ | tek satır açıklama (ekranda tek anlatım) |
| market_type | ✓ | "b2c"/"b2b" → PostShip satış modeli |
| price_tendency | ops. | "premium/neutral/volume" (yalnız 3 tipte); `product_value` çarpanı |
| **description / hedef-kitle** | ✗ | yok |
| **kalite / boyut / kalite-ekseni alanı** | ✗ | **YOK (teyit)** |

**Yeni model bağlantısı:** tip-özel kalite eksenleri (ör. bu tip için Innovation tavanı yüksek, Stability zor) → buraya `quality_axes` / `dimension_ceilings` gibi alan eklenir; `get_sub_product_type_by_id()` zaten tüm kaydı döndürüyor, tüketiciler oradan okur.

### 3.2 Feature kaydı — tam alanlar
`FEATURE_POOLS[sub_type_id][]` → her kayıt:
```
{ id, name, voice, complexity (1-5), tags: [] }
```
- **Feature'lar globe değil, sub-type'a bağlı** havuzlar (`FEATURE_POOLS` anahtarı = sub_type_id; `get_feature_pool(sub_type_id)`). Global lookup için `get_feature_by_id()` tüm havuzları tarar.
- `tags` her feature'da **boş `[]`** (okunmuyor, forward-compat).
- **Kalite/boyut/benefit alanı YOK.** Tek mekanik alan `complexity`.

**Feature → etki tam kod yolu (tek satır teyit):** `feature_build.gd:86-91 get_total_complexity()` (Σ complexity) → `product_system.gd:222 development_days_total = 6 + Σcomplexity` → **yalnız build SÜRESİ**. Feature seçimi kaliteyi/bug'u **doğrudan etkilemez**; post-ship'te `feature_count` + `total_complexity` yalnız `product_value()` fiyatına girer (R4). "Hangi feature = hangi kalite boyutu" eşlemesi **yok**.

**Yeni model bağlantısı:** feature'ın hangi boyutu beslediği için kayda `dimension` / `quality_contribution: {innovation, stability, usability}` alanı eklenir; tüketici tarafında yeni bir toplama fonksiyonu (`get_total_complexity` yanında `get_dimension_contributions()`) gerekir ve build tick'i bunu kaliteye çevirir.

### 3.3 Spec'in kendi hedefi (referans)
`PROJECT_SPEC.md:673-681 §5.1` zaten çok-boyutu öngörüyor: **Innovation** (distinctiveness/press/acquisition), **Stability** (bug-freeness/churn/support), **Usability** (ease/onboarding/satisfaction). "Şimdilik single field; Spec #3'te multi-dimensional expansion." Redesign bu üçlüyü canonlaştırabilir.

---

## EN RİSKLİ NOKTA (spec yazarken en çok dikkat)

**En riskli/en çok dokunulacak yer `SalesSystem` — özellikle `_tick_b2c_audience` (R1) + `product_value` (R4) ekseni.** Sebep: (a) kalite tek bir int olarak **6 ayrı SalesSystem noktasında** hem çarpan hem eşik olarak, üstelik `optimal` üzerinden **dolaylı** olarak conversion/churn/growth-multiplier'a da yayılıyor — tek int'i çok-boyuta çevirince bu noktaların her biri "hangi boyutu ya da bileşik skoru okuyacak?" kararını ayrı ayrı vermek zorunda ve **R1 ile R6 (growth_band) aynı formülü kopyaladığı için senkron kalmazsa** oyuncuya "büyüyor" derken erimesi gibi tutarsızlık çıkar. (b) Kalitenin **iki yüzeyi** (`FeatureBuild.quality` canlı + `mvp_quality` snapshot) ve **bir ölü flag** (`product_quality`) var; redesign yalnız flag'i çok-boyuta çevirir de canlı build alanını unutursa BuildHUD/BuildProgress kırılır, ya da tersine. (c) `mvp_quality` **açık-uçlu değil, 0-100 clamp'li** ve `conversion_rate`'te `optimal/price` oranına giriyor — açık-uçlu (100+) modele geçince fiyat/conversion ölçeği patlayabilir, bu yüzden çok-boyutlu skoru bu formüllere sokmadan önce **normalizasyon/ölçek katmanı** tanımlanmalı. Kısacası spec: (1) canlı+snapshot iki yüzeyi birlikte ele al, (2) her SalesSystem tüketicisi için "boyut mu / bileşik mi" eşlemesini tek tabloda sabitle, (3) açık-uçlu skoru mevcut oransal formüllere sokmadan bir ölçekleme sözleşmesi koy.

---
*Rapor sonu — salt-okunur denetim, kod değiştirilmedi.*
