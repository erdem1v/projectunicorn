# Product Sistemi & Ekranı — Mevcut Durum Raporu (Audit)

**Tarih:** 2026-07-01
**Tür:** Salt-okunur denetim (kod değiştirilmedi)
**Kapsam:** `ProductTab` (tasarım/build/post-ship), `ProductCatalog`, `ProductSystem` build state-machine, `FeatureBuild`, `BuildHUDPanel`, build-fazı reactive event'leri.

**Denetlenen dosyalar**
- `scenes/tabs/ProductTab.tscn` · `scripts/tabs/product_tab.gd`
- `scripts/systems/product_catalog.gd`
- `scripts/systems/product_system.gd` · `scripts/data_models/feature_build.gd`
- `scenes/ui/components/BuildHUDPanel.tscn` · `scripts/ui/components/build_hud_panel.gd`
- `data/events/reactive/ev_mvp_*.json` (11 dosya)
- `scripts/autoload/event_manager.gd` (modifier dispatch + trigger eval), `scripts/autoload/time_manager.gd` (tick cadence), `scripts/autoload/game_state.gd` (skill/flag), `scenes/main/GameShell.tscn` (HUD montajı)

> Not: `project-unicorn-OLD-backup/` altındaki eşdeğer dosyalar **eski yedek**tir; bu rapor yalnızca aktif `project-unicorn/` ağacına bakar.

---

## 1. Product ekranı yapısı — view routing

Product tab tek bir `BuildStateRoot` (Control) içinde **4 view** barındırır; aynı anda yalnız biri görünür. Routing `product_tab.gd:_refresh_view()` içinde iki değişkene bakar: `ProductSystem.get_active_build()` (aktif build var mı) ve `GameState.flags["mvp_shipped"]`.

| View | Görünme koşulu | Ne gösteriyor |
|---|---|---|
| **DesignDocumentView** | `active_build == null` **ve** `mvp_shipped == false` | Ship-öncesi planlama: sol=ürün tipi, orta=özellik grid, sağ="TAHMİN" + mentor, alt="BUILD'İ BAŞLAT" commit bar |
| **BuildProgressView** | `active_build != null` **ve** faz ∈ {iteration, development, bugfix, polish} | Aktif build feed'i: header (tip/özellik/mühendis) + progress bar + kalite/bug/faz status bloğu + gün-gün feed. **Karar butonu yok** (butonlar HUD'da). |
| **PolishProgressView** | (hiç) — `_show_state()` ile kalıcı gizli | Deprecated. Spec #4'te bugfix ile birleşti; "bugfix" → BuildProgressView'a route edilir. Node hâlâ sahnede duruyor ama ölü. |
| **PostShipView** | `active_build == null` **ve** `mvp_shipped == true` | Ship-sonrası satış ekranı (bkz. §11) |

**Ship-öncesi → ship-sonrası akış:**
1. DesignDocumentView'da tip + 2–4 özellik seç → **BUILD'İ BAŞLAT** → `ProductSystem.start_build()` → `active_build` yaratılır, faz=`iteration`, oyun 1x'e alınır.
2. Router BuildProgressView'a geçer. Faz ilerlemesi (iteration ⇄ development → bugfix) **sağ-üstteki BuildHUDPanel** butonlarıyla yönetilir (§4, §7).
3. Bugfix'te **LAUNCH** → `ProductSystem.launch()` → `mvp_*` flag'leri yazılır → sentetik "ship moment" event'i (`ev_mvp_ship_moment`, Frank) enqueue edilir.
4. Event'in tek seçeneği (`ship_active_build` modifier) → `mvp_shipped=true`, `active_build=null`. Router **kalıcı olarak** PostShipView'a düşer.

> **Tek yönlü akış:** Ship'ten sonra DesignDocumentView'a dönüş yok. `start_build()` zaten `active_build != null` iken çalışıyor ama ship sonrası hiçbir yol yeni build başlatmaya (design view'a) route etmiyor → oyunda ürün başına **yalnız bir build ömrü** var (bkz. §11).

---

## 2. Sub-product type'lar — ProductCatalog (10 tip)

`ProductCatalog.SUB_PRODUCT_TYPES`, subgenre'e göre gruplu. `ai` ve `saas` altında **5'er tip = 10 tip**; `social` boş. Ekranda oyuncunun subgenre'ine ait 5 tip listelenir (`get_sub_product_types(GameState.subgenre)`).

**Alanlar:** her tipte `id`, `name`, `pitch` (ekrandaki açıklama), `market_type` var; `price_tendency` **opsiyonel** (yoksa `"neutral"`).

### AI (subgenre = "ai")
| id | name | market | price_tendency | pitch (ekran metni) |
|---|---|---|---|---|
| `ai_assistant` | AI Assistant | b2c | (neutral) | "ChatGPT'nin yetmediği yerlerde devreye giren asistan." |
| `ai_photo_editor` | Photo Editor | b2c | volume | "Photoshop'un karmaşıklığını unutturan bir araç." |
| `ai_code_copilot` | Code Copilot | b2c | (neutral) | "Junior developer'lar için en iyi pair programmer." |
| `ai_multimodal_app` | Multi-Modal App | b2c | (neutral) | "Text + görsel + ses, hepsi bir arada." |
| `ai_vector_search` | Vector Search Service | b2b | premium | "Veri arama, ama anlama getir." |

### SaaS (subgenre = "saas")
| id | name | market | price_tendency | pitch (ekran metni) |
|---|---|---|---|---|
| `saas_project_mgmt` | Project Management | b2b | (neutral) | "Asana ölmedi, sadece arkanı dönmüş. Bunu yenilemek için bir fırsat." |
| `saas_crm` | CRM | b2b | (neutral) | "Sales takip platformu. Müşteri kaybeden satıcı yok." |
| `saas_analytics` | Analytics Dashboard | b2b | (neutral) | "Veriyi grafik haline getir. Yöneticiler bunun için para verir." |
| `saas_billing` | Billing Platform | b2b | (neutral) | "Para almayı kolaylaştır. İşin geri kalanı şirketin sorunu." |
| `saas_dev_tools` | Dev Tools | b2b | premium | "Diğer mühendislerin pain point'lerini sırtlanmak." |

**Kullanım:**
- `pitch` = sol kolonda tip satırının altındaki açıklama (`SubTypeRow_*/RowLayout/PitchLabel`).
- `market_type` → PostShip satış modelini seçer (`get_market_type`): b2c = audience/pricing funnel, b2b = prospect/pitch. Ship anında `mvp_market_type` flag'ine yazılır.
- `price_tendency` → `SalesSystem.product_value()` optimal fiyatını kaydırır (yalnız 3 tipte tanımlı: photo_editor=volume, vector_search=premium, dev_tools=premium).

> **Şikâyetle ilişki ("ChatGPT'nin yetmediği yer", "Multimodal ne demek"):** Tipin ekranda görünen tüm anlatımı **tek satırlık `pitch`**ten ibaret. Ayrı bir "bu ürün ne işe yarar / hedef kitle / neden farklı" açıklaması, örnek senaryo ya da uzun body yok. `ai_assistant` = "ChatGPT'nin yetmediği yerlerde…" ve `ai_multimodal_app` = "Text + görsel + ses, hepsi bir arada." metinleri aynen bu tek satırlar. Kod içi yorum da bunu doğruluyor: *"Voice strings are working drafts — Erdem revises in content pass."*

---

## 3. Feature (özellik) sistemi

`ProductCatalog.FEATURE_POOLS` — her sub-type'a bağlı **6–7 özellik** havuzu (yalnız `ai_code_copilot` 7, geri kalan 6). Ekranda `get_feature_pool(sub_type_id)` ile gelir; grid en fazla 7 kart gösterir (fazlası gizlenir).

**Bir feature'ın alanları — mevcut hâli:**
```
{ "id": ..., "name": ..., "voice": ..., "complexity": 1..5, "tags": [] }
```

- **`id`** — kimlik.
- **`name`** — kart başlığı (`NameLabel`).
- **`voice`** — kartın açıklama satırı (`VoiceLabel`). Karakter/atmosfer metni; mekanik bir alan **değil**.
- **`complexity`** — 1–5 arası int. Kartta dolu/boş noktalarla ("●") gösterilir (`_paint_complexity_dots`).
- **`tags`** — **her feature'da boş `[]`**. Tanımlı ama hiçbir yerde okunmuyor (forward-compat rezerv).

> **Şikâyetle ilişki ("sadece complexity ile if ediliyor, benefit yazmalı"):** Doğrulandı. Feature'ın **tek mekanik alanı `complexity`**. `benefit`, `tech`, `engagement`, "kaliteye katkısı", "hangi müşteriyi çeker" gibi hiçbir alan yok. `voice` sadece serbest metin. Mekanikte feature'ın etkisi tek yerden geçer:

**Feature seçimi neyi etkiliyor?** — Yalnızca **build süresini** (dolaylı olarak `complexity` toplamı üzerinden):
- `FeatureBuild.get_total_complexity()` = seçili feature'ların `complexity` toplamı.
- `start_build()`: `development_days_total = DEVELOPMENT_DAYS_BASE(6) + total_complexity`.
- `min_estimation_days = max(5, total_complexity + 2)` (hesaplanıyor ama **hiçbir yerde gösterilmiyor/kullanılmıyor**).
- **Kaliteye doğrudan etkisi YOK.** Kalite artışı yalnız `tech` skill + faz sabitlerinden gelir (§5); *hangi* feature'ı seçtiğin ya da *kaç* feature seçtiğin kaliteyi değiştirmiyor. Yani "az ama karmaşık" vs "çok ama basit" seçimi sadece süreyi oynatır; kalite/bug/satış sonucunu değiştirmez.
- Seçim kuralı: **min 2, max 4** feature (`_refresh_commit_bar`, `start_build` doğrulaması). Havuz ise 6–7 tane sunar.

---

## 4. Build faz state-machine

`ProductSystem` (RefCounted, static). Fazlar: `planning → iteration ⇄ iteration → development → bugfix → shipped` (+ `cancelled`). Günlük tick `TimeManager._tick_product()` → `ProductSystem.daily_tick()` (daily tick slot 1) ile sürülür — **gün sınırında, saatlik değil** (bkz. §5).

### Faz faz akış

| Faz | Süre / bitiş | Kalite (günlük) | Bug (günlük) | Oyuncu kararı |
|---|---|---|---|---|
| **planning** | — | — | — | Tip + feature seç, BUILD'İ BAŞLAT (bu faz aslında design view; build başlayınca direkt `iteration`) |
| **iteration** | `ITERATION_LENGTH_DAYS = 4` gün/tur; sayaç 0'a inince "karar bekliyor" | `+round(1.5 + tech)` | `+round( max(0, 1.2 − 0.4·tech) · mod )` | Sayaç bitince HUD'da: **[Bir iterasyon daha]** veya **[Development'a geç]** |
| **development** | `development_days_total = 6 + Σcomplexity` gün, otomatik sayar | `+round(1.5 + tech)` | `+round( max(0, 1.2 − 0.4·tech) )` | **Karar yok** — otomatik ilerler, bitince `bugfix`'e geçer |
| **bugfix** | **Açık uçlu** (otomatik ship yok) | `+1/gün` (`POLISH_QUALITY_BUMP_PER_DAY`) | `−4/gün` (`POLISH_BUG_FIX_PER_DAY`, min 0) | HUD'da **[LAUNCH]**'a basana kadar sürer |
| **shipped** | — | — | — | — (PostShipView) |

**iteration modifier (`mod`):** `mod = max(0.2, 1.0 − 0.1·(iteration_count−1))`. Yani ilk turda `mod=1.0`; her ek turda bug üretimi %10 azalır (min 0.2). Development'ta bu modifier **yok** (tam oran).

**Karar butonlarının etkisi (HUD):**
- `advance_iteration()` → `iteration_count++`, sayaç 4'e reset, **kalite anında +5** (`QUALITY_PER_ITERATION`).
- `enter_development()` → faz `development`, `development_days_elapsed=0`.
- `launch()` → yalnız `bugfix`'te geçerli; `critical_bug_unfixed` flag varsa `bug_count += 5` (`CRITICAL_BUG_LAUNCH_PENALTY`), sonra `mvp_*` flag + ship moment.

### Development'ta bug üretiliyor mu? — EVET (kod olarak), ama pratikte çoğu zaman 0

`_tick_development_phase()` **her gün** bug üretim satırını çalıştırır:
```gdscript
var bug_delta: float = max(0.0, BASE_BUG_RATE - (float(tech) * TECH_BUG_MOD))   # 1.2 - 0.4·tech
active_build.bug_count += int(round(bug_delta))
```
Ama sonuç `tech` skill'e bağlı ve **round() ile int'e yuvarlanıyor:**

| founder `tech` | ham bug_delta | `round()` → günlük bug |
|---|---|---|
| 0 | 1.2 | **1** |
| 1 | 0.8 | **1** |
| 2 | 0.4 | **0** |
| 3 | 0.0 | **0** |

> **Şikâyetle ilişki ("development'da hiç bug çıkmıyor"):** Kök neden bu. Founder skill havuzu **6 puan, eksen başına max 3** (`skill_step.gd`: `TOTAL_POOL=6`, `AXIS_CAP=3`). Oyuncu tech'e **2 veya 3** koyduysa `bug_delta` yuvarlanınca **0** olur → development boyunca hiç organik bug birikmez. tech 0–1 olsa günde 1 bug birikir. Aynı formül iteration'da da geçerli (üstüne `mod ≤ 1` ile daha da düşer), yani yüksek tech'te **hiçbir fazda** organik bug oluşmaz — bug'lar pratikte yalnız event'lerden (`critical_bug_unfixed` → +5) gelir. Development ayrıca hiçbir organik bug üretmese de kaliteyi `+round(1.5+tech)`/gün artırmaya devam eder, dolayısıyla "risk yok, sadece kalite artıyor" hissi doğar.

---

## 5. Kalite artış mekaniği — saatlik mi, günlük mü?

**Tamamen GÜNLÜK.** Kalite yalnız `ProductSystem.daily_tick()` içinde değişir; bu da `TimeManager._dispatch_daily_tick()`'ten (yalnız **gün sınırında**) çağrılır. Saatlik tick (`_dispatch_hourly_tick`) product'a **dokunmaz**. Kalitenin hiçbir ara-değeri/interpolasyonu yok.

**Kalite kaynakları (hepsi gün-granülaritesinde):**
- Başlangıç: `start_build()` → `quality = QUALITY_BASELINE = 50` (anında set).
- iteration/development günlük: `+round(1.5 + tech)` (tech 3 ise +5/gün; tech 0 ise +round(1.5)=**+2**/gün).
- `advance_iteration` (buton): **anında +5** (gün beklemeden).
- bugfix günlük: **+1/gün**.
- Hepsi `clampi(…, 0, 100)`.

> **Şikâyetle ilişki ("0'dan 54'e zıplıyor, saatlik smooth olsun"):** Kalite **sub-50'ye hiç inmez** — build başlar başlamaz `50` olur (baseline). Algılanan "0 → 54 sıçraması" şuna denk gelir: build öncesi hiçbir kalite gösterilmez (HUD gizli, design view'da kalite alanı yok) → build başlayınca anında 50 → ilk gün tick'i (+2…+5) ve/veya bir `advance_iteration` (+5) ile hızla ~54-60'a **basamak basamak** çıkar. Yani hem tabanı 50'den başlıyor (0'dan değil) hem de tüm hareket **günlük iri adımlarla** oluyor; saat-saat yumuşak artış yok. `advance_iteration`'ın anlık +5'i sıçramayı ayrıca büyütür.

---

## 6. Build event'leri — seçim ↔ modifier eşleşmesi

Build sırasında **yalnız** `build_phase` trigger'ı eşleşen (ya da `build_safe` etiketli) reactive event'ler fire edebilir (`event_manager.gd:_is_eligible`). İlgili modifier'lar `event_manager.gd:_apply_modifiers`'ta dispatch edilir:
- `quality_bonus {amount}` → `ProductSystem.apply_quality_bonus(amount)` → `quality += amount` (clamp 0-100).
- `speed_bonus {days}` → `ProductSystem.apply_speed_bonus(days)`.

### ⚠️ `speed_bonus` semantiği ters/opak (kritik bulgu)

`apply_speed_bonus(days)` — yorumu: *"days is negative to speed up; positive to slow down."*
```gdscript
"iteration":    iteration_days_in_current   = max(0, iteration_days_in_current + days)
"development":  development_days_total       = max(elapsed, development_days_total + days)
"bugfix":       # (no-op — açık uçlu faz)
```
Yani **`days` POZİTİF ise fazın sayacına gün EKLER → YAVAŞLATIR**; **NEGATİF ise HIZLANDIRIR**. İsim "bonus" ama pozitif değer ceza (yavaşlama). Bugfix'te tamamen no-op. Ayrıca iteration'da sayaç zaten 0'a inip "karar bekliyor" durumundaysa `+days` sayacı yeniden açıp ekstra gün ekleyebilir.

### Tüm build event'leri — faz, seçenek, modifier

**ITERATION fazı**

| Event | Seçenek | Modifier'lar | Net etki |
|---|---|---|---|
| `ev_mvp_iter_001_scope_creep`<br>*(chance 0.35)* | "Düzgün yap — birkaç gün daha gerek" | `quality_bonus +4`, `speed_bonus days:2` | kalite +4, **+2 gün yavaş** |
| | "Kırp, yüzeyi koru, devam et" | `quality_bonus −2`, `set_flag scope_creep_kirpildi` | kalite −2 |
| `ev_mvp_iter_002_competitor_signal`<br>*(chance 0.25)* | "Tasarımı onların eksik yerine eğ" | `set_flag pivot_versus_rakip`, `speed_bonus days:1` | **+1 gün yavaş**, başka mekanik ödül yok |
| | "Kendi yolundan sapma" | `brand +1` | brand +1 |
| `ev_mvp_iter_003_early_user_feedback`<br>*(chance 0.25)* | **"Önerilerini ciddiye al, tasarımı tekrar düşün"** | `set_flag early_feedback_dinlendi`, **`speed_bonus days:1`** | **+1 gün yavaş**, kalite ödülü YOK |
| | "Vizyonuna sadık kal, yola devam" | `brand +1` | brand +1 |
| `ev_mvp_cofounder_offer_iter`<br>*(day≥10, chance 0.15)* | "Kabul et" / "Reddet" | yalnız `set_flag` | (yalnız flag, üretim etkisi yok) |

**DEVELOPMENT fazı**

| Event | Seçenek | Modifier'lar | Net etki |
|---|---|---|---|
| `ev_mvp_dev_001_integration_broken`<br>*(chance 0.30)* | "Gece boyu uğraş, doğru yap" | `quality_bonus +3`, `set_flag founder_fatigue` | kalite +3 |
| | **"Geçici çözüm — TODO listesine ekle"** | `set_flag tech_debt_birikti`, **`speed_bonus days:−1`** | **−1 gün HIZLI**, ceza yok* |
| `ev_mvp_dev_002_tech_debt_callout`<br>*(flag tech_debt_birikti, chance 0.25)* | "Dur, düzelt, sonra devam" | `speed_bonus days:2`, `quality_bonus +3` | kalite +3, **+2 gün yavaş** |
| | "Üstüne build etmeye devam" | `set_flag tech_debt_birikti`, `speed_bonus days:−1` | **−1 gün hızlı** |
| `ev_mvp_dev_003_solo_dev_fatigue`<br>*(chance 0.20)* | "Bugün kendine ver, yarın taze başla" | `speed_bonus days:1`, `set_flag founder_recovery` | **+1 gün yavaş** (dinlenme = gün kaybı) |
| | "Zorla, kahve yap, masaya otur" | `quality_bonus −2`, `set_flag founder_fatigue` | kalite −2 |
| `ev_mvp_cofounder_offer_dev`<br>*(day≥10, chance 0.15)* | "Kabul et" / "Reddet" | yalnız `set_flag` | (yalnız flag) |

**BUGFIX fazı** *(dikkat: bugfix'te `speed_bonus` NO-OP — açık uçlu faz)*

| Event | Seçenek | Modifier'lar | Net etki |
|---|---|---|---|
| `ev_mvp_bugfix_001_critical_bug`<br>*(chance 0.40, pri 1)* | "Launch'u ertele, çöz" | `speed_bonus days:3`, `quality_bonus +4` | kalite +4 (+3 gün no-op) |
| | "Bırak, gönder — fark eden olmaz" | `set_flag critical_bug_unfixed`, `brand −2` | brand −2, launch'ta **+5 bug** |
| `ev_mvp_bugfix_002_early_launch_pressure`<br>*(chance 0.30)* | "Bir tur daha temizlik" | `quality_bonus +2`, `set_flag polish_one_more_pass` | kalite +2 |
| | "Hazır olmasa da çık" | `set_flag launch_pressure_kabul` | (yalnız flag) |
| `ev_mvp_bugfix_003_final_polish`<br>*(chance 0.25)* | "Vakit harca, cila çek" | `quality_bonus +3`, `speed_bonus days:1` | kalite +3 (+1 gün no-op) |
| | "Yeterince iyi — devam" | (boş) | etki yok |

> **Şikâyetlerle ilişki:**
> - **"tasarımı tekrar düşün → hız buff'ı alıyorum, saçmalık"** → `ev_mvp_iter_003`. "Önerileri ciddiye al, tasarımı tekrar düşün" seçeneğinin **tek mekanik etkisi `speed_bonus days:1`** (bir flag + 1 gün). `days:1` pozitif olduğu için aslında **yavaşlatma**dır (buff değil), ama isim "speed_bonus" olduğu ve kalite ödülü hiç olmadığı için hem yanıltıcı hem tuhaf: kullanıcı geri bildirimini ciddiye almak → yalnızca gecikme, hiçbir kalite kazancı yok. Alternatif "vizyona sadık kal" ise `brand +1` alır. Yani "kullanıcıyı dinle" yolu mekanik olarak cezalı, "dinleme" yolu ödüllü.
> - **"geçici çözüm → hız bonusu, tuhaf"** → `ev_mvp_dev_001`. "Geçici çözüm — TODO listesine ekle" → `speed_bonus days:−1` (development'ı 1 gün kısaltır) + `tech_debt_birikti` flag. Semantik olarak "hack = daha hızlı" doğru yönde ama *tuhaf* çünkü **görünür bir bedeli yok**: development'ta organik bug üretimi yüksek tech'te zaten 0 (§4), ve `tech_debt_birikti` flag'i yalnız `ev_mvp_dev_002`'yi tetikleme koşulu — o da yine hızlanma sunuyor. Yani hack net bir kazanç gibi görünür.
> - **Genel:** `speed_bonus`'un pozitif=yavaş / negatif=hızlı semantiği modelin her yerinde opak. Bugfix event'lerindeki `speed_bonus`'lar (`iter_001`? hayır — `bugfix_001` days:3, `bugfix_003` days:1) **hiçbir işe yaramıyor** (no-op), çünkü bugfix açık uçlu.

---

## 7. BuildHUDPanel — sağ-üst desk paneli

**Konum/montaj:** `GameShell.tscn` → `MidRow/CenterViewport/BuildHUD` (desk alanının içinde, `clip_contents=true` panelle kırpılır). Root Control sağ-üste sabitli (`offset_left=-300, offset_top=60, offset_right=-20, offset_bottom=220`) → ~280×160 px yüzen kart. `process_mode = ALWAYS` (modal açıkken/oyun duraklıyken de tıklanabilir). `mouse_filter=IGNORE` kök → desk tıklamaları geçer, yalnız iç panel/butonlar yakalar.

**Görünürlük:** yalnız `active_build != null` iken (`_refresh` → `visible`).

**Gösterdikleri (faz-duyarlı):**
- Header: ürün tipi adı + faz etiketi (iteration'da "Designing — Iteration N" / karar beklerken "İterasyon N bitti — karar ver" ve etiket ACCENT renk).
- Stats: `"Kalite N"` (her zaman) + bug satırı:
  - iteration → `"Bug riski: Düşük/Orta/Yüksek (N)"` (≤2 Düşük, ≤6 Orta, >6 Yüksek)
  - development → `"Bug: N"`
  - bugfix → `"Bug: N (azalıyor)"`
- Progress bar: iteration (4 günlük tur ilerlemesi) / development (elapsed/total); bugfix'te **gizli** (açık uçlu, bitiş yalanı vermesin diye).
- Butonlar: iteration → [Bir iterasyon daha] + [Development'a geç] (yalnız `iteration_decision_pending` iken aktif + ACCENT tint; değilse görünür-ama-disabled); development → buton yok; bugfix → [LAUNCH].

**Refresh cadence:** signal-driven — `build_phase_changed`, `build_iteration_decision_pending`, `day_advanced`, `build_progress_changed`. Son ikisi **gün sınırında** fire eder → HUD **günlük** güncellenir, saatlik değil (kalite/bug gün-gün zıplar, §5 ile tutarlı). `_process` poll yok.

---

## 8. "Build'i başlat" butonu + commit bar

DesignDocumentView'ın en altında, `ColumnsRow`'un (3 kolon, dikeyde expand) hemen ardında:
```
[node CommitBar type="Button"]  custom_minimum_size=(0,44)  disabled=true  text="BUILD'İ BAŞLAT"
[node ReasonLabel type="Label"] text="Ürün tipi ve en az 2 özellik seç."  (ortalı)
```
- **Tema:** `CommitBar`'da **`theme_type_variation` YOK** → varsayılan `Button` teması (nötr/gri). Karşılaştırma: PostShip'teki fiyat "Uygula" ve "Sales'e git" butonları `theme_type_variation=&"CommitButton"` (amber vurgu) kullanıyor — commit bar kullanmıyor.
- **Geometri:** tam-genişlik, 44 px yükseklik, altında ortalı gri açıklama satırı. `ColumnsRow` dikeyde büyüdüğü için buton panellerin **altındaki geniş boşlukta** yatay bir şerit olarak oturur.
- **Durum:** `_refresh_commit_bar()` → geçerli değilse (tip yok veya <2 / >4 feature) `disabled=true` + `ReasonLabel` görünür; geçerliyse aktif.

> **Şikâyetle ilişki ("kocaman gri alan üstünde, rezil"):** Doğrulandı — tam genişlik, varsayılan-gri temalı, vurgusuz büyük bir buton; hem amber "CommitButton" varyasyonunu kullanmıyor hem de üstündeki kolonların altındaki boşlukta iri gri bir slab gibi duruyor.

---

## 9. Ürün ismi

**Ürünün adı YOK.** Oyuncu build sırasında ya da öncesinde **isim girmiyor.**
- `start_build()` build id'yi sabit `"mvp_build_001"` verir; hiçbir yerde serbest ürün adı alanı yok.
- Hem BuildHUDPanel hem BuildProgressView hem PostShipView, ürünü **sub-product type adıyla** gösterir (`_sub_type_display` / `_sub_product_type_name` → `ProductCatalog…name`), ör. "AI Assistant".
- PostShipTitle = `"<tip adı> · canlı"` (ör. "AI Assistant · canlı").
- **Şirket adı** ayrı olarak var (`GameState.company_name`, onboarding CompanyStep'te girilir, default "Unicorn Inc.") ama **Product ekranında hiç kullanılmıyor** — yalnız başka yerlerde (TopBar vb.). Yani ürün = tip adı; ürüne özel bir isim kavramı yok.

---

## 10. Ship-sonrası Product ekranı (PostShipView)

Ship'ten sonra Product tab kalıcı olarak PostShipView gösterir (`_paint_post_ship`). İçerik `mvp_market_type`'a göre dallanır:

**Ortak bloklar:**
- **PostShipTitle:** "<tip> · canlı".
- **FRANK** paneli: ship-anı tepkisi, kalite/bug'a göre 3 varyant (`_frank_ship_reaction`): bug>8 → "o bug'lar…", kalite≥80 → "temiz çıktı", diğer → "birinin buna para vermesini sağlamak".
- **TRACTION'A DOĞRU:** bar = `SalesSystem.traction_progress()`, etiket = `"MRR $X / $HEDEF"`; hazırsa "Hazır — Frank'le konuş" chip'i.

**B2C ise (`market_type=="b2c"`):**
- **DURUM funnel'ı** (kodla kurulur): Deneyen → Ödeyen → MRR + büyüme bandı chip'i ("hızlı büyüyor/büyüyor/eriyor").
- **FİYATLANDIRMA paneli** (tamamen kodla, `_ensure_pricing_panel`): ürün değeri (`SalesSystem.product_value`, Markets skill'i eşiği altındaysa "belirsiz"), rationale chip'leri, renkli fiyat spektrumu + floor/optimal notch'ları, HSlider, canlı projeksiyon (Seçilen/Ödeyen/MRR/Dönüşüm before→after), ve amber **"Fiyatı koy / uygula"** CTA. Bu, B2C'nin **tek gerçek gelir kaldıracı** (`SalesSystem.apply_b2c_price`).

**B2B ise:**
- Funnel/pricing gizli. Tek satır `StatusBody`: müşteri yoksa "İlk pitch'in Sales sekmesinde…" / "Frank seni biriyle tanıştıracak", varsa "N müşteri · MRR $X".
- **"Sales sekmesine git →"** butonu görünür (pitch akışı Sales tab'da).

### Versiyon / update mekaniği?

**YOK — teyit edildi.** Ship-sonrası:
- Yeni build başlatma / v2 / feature ekleme / güncelleme yolu yok. Router `active_build==null && mvp_shipped` → hep PostShipView; DesignDocumentView'a dönüş edge'i yok.
- Kalite ship anında dondurulur (`mvp_quality` flag) ve PostShip'te değişmez; ürünü iyileştirme/yeni sürüm mekaniği bulunmuyor.
- Ship-sonrası ekran esasen **fiyatlandırma + satış funnel'ı + traction takibi**ne indirgenmiş durumda; "ürün" tarafı artık statik.

---

## Özet — kullanıcı gözlemlerinin kod karşılıkları

| Gözlem | Kök neden (mevcut kod) |
|---|---|
| "ChatGPT'nin yetmediği yer / Multimodal ne demek" | Tip'in ekran metni tek satırlık `pitch`; ayrı açıklama/hedef-kitle/örnek yok (§2). Yorum: "working drafts". |
| "Feature sadece complexity ile if ediliyor, benefit yazmalı" | Feature'ın tek mekanik alanı `complexity`; `tags` boş; benefit/tech/engagement alanı yok. Feature seçimi yalnız **build süresini** etkiliyor, kaliteyi/bug'u/satışı değil (§3). |
| "Development'da hiç bug çıkmıyor" | Bug üretim kodu **var** ama `round(1.2 − 0.4·tech)`; tech ≥ 2'de 0'a yuvarlanır. 6 puanlık havuzda tech 2-3 tipik → organik bug hiç oluşmaz (§4). |
| "Kalite 0'dan 54'e zıplıyor, saatlik olsun" | Kalite **günlük** tick'te değişir (saatlik değil); baseline **50**'den başlar (0 değil); `advance_iteration` anlık +5 sıçratır → gün-granüllü iri adımlar (§5). |
| "Tasarımı tekrar düşün → hız buff'ı, saçmalık" | `ev_mvp_iter_003` "geri bildirimi ciddiye al" seçeneği yalnız `speed_bonus days:1` (aslında +1 gün yavaşlatma) + flag; kalite ödülü yok. Alternatif "vizyona sadık kal" `brand+1` alır (§6). |
| "Geçici çözüm → hız bonusu, tuhaf" | `ev_mvp_dev_001` hack seçeneği `speed_bonus days:−1` (−1 gün) + `tech_debt_birikti`; görünür bedeli yok, dev'de bug zaten oluşmuyor (§6). |
| "Build'i başlat kocaman gri alan üstünde, rezil" | `CommitBar` varsayılan-gri Button teması (amber `CommitButton` varyasyonu kullanılmıyor), tam-genişlik 44px, kolonların altındaki boşlukta (§8). |
| "Ürün ismi yok mu?" | Yok; oyuncu isim girmiyor, ürün = sub-type adı; şirket adı ayrı ama Product ekranında kullanılmıyor (§9). |
| "Ship sonrası sadece fiyatlandırma mı?" | Evet — PostShipView = funnel + pricing + Frank + traction; versiyon/update mekaniği yok, yeni build yolu yok (§10). |

---

*Rapor sonu — salt-okunur denetim, kod değiştirilmedi.*
