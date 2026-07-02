# Ship-Sonrası Yaşam Zemin Raporu (Audit)

**Tarih:** 2026-07-01 · **Tür:** Salt-okunur (kod değişmedi) · **Amaç:** Product Lifecycle **Part 2** (ship-sonrası yaşam: yıpranma, bug sprinti, versiyon update, üçlü tercih, HR köprüsü) spec zemini.
**Bağlam:** Part 1 (çok-boyutlu kalite + rakip + 3-eksenli feature + saatlik build + iki-kural event) yeni bitti. Bu audit onun bıraktığı kancaların üstüne kurulacak ship-sonrası tarafı netleştirir.

---

## BÖLGE 1 — Ship-sonrası ekran & durum (PostShipView tam hali)

**Routing** — `product_tab.gd:179 _refresh_view()`:
```
active == null && mvp_shipped  → PostShipView   (_paint_post_ship)
active != null (iter/dev/bugfix) → BuildProgressView
else                            → DesignDocumentView
```
Ship'ten sonra `active_build == null` + `mvp_shipped == true` → **hep PostShipView**. Tasarıma/yeni build'e dönüş yolu yok (Bölge 3).

**`_paint_post_ship()` (`product_tab.gd:879`) blokları:**

| Blok | Kaynak (dosya:satır) | Besleyen veri |
|---|---|---|
| Başlık `"<ad> · v1 · canlı"` | `:886` | `mvp_product_name` (fallback tip adı) — **"· v1" hardcoded** |
| DURUM (B2C funnel) `Deneyen→Ödeyen→MRR` + büyüme chip | `:889-894`, `_paint_status_funnel :928` | `b2c_audience`, `CustomerRegistry.get_total_users()`, `GameState.mrr`, `b2c_paid_tier_open`, `SalesSystem.growth_band()` |
| FİYATLANDIRMA paneli (B2C, kodla) | `_paint_pricing :982`, `_ensure_pricing_panel :1015` | `SalesSystem.product_value()` (optimal/floor), slider, canlı projeksiyon |
| DURUM (B2B) tek satır + "Sales'e git" butonu | `:895-907` | `CustomerRegistry.get_active()`, `ProspectRegistry.has_any()`, `GameState.mrr` |
| FRANK ship-tepkisi | `:909-910`, `_frank_ship_reaction` | `shipped_normalized()` (kalite), `mvp_bug_count_at_launch` |
| TRACTION bar + "Hazır — Frank'le konuş" chip | `:912-915`, `_paint_traction_chip :958` | `SalesSystem.traction_progress()`, `TRACTION_MRR_TARGET(5000)`, `ready_for_traction` flag |

**Ship-sonrası ürün state'i — DONMUŞ (teyit).** Launch anında yazılan flag'ler: `mvp_innovation/stability/usability`, `mvp_product_name`, `mvp_bug_count_at_launch`, `mvp_iteration_count`, `mvp_sub_product_type_id`, `mvp_market_type`, `mvp_quality` (türetilmiş köprü), `mvp_components` (`product_system.gd launch()` + `ship_active_build()`). **Ship'ten sonra bunları güncelleyen hiçbir kod yok.** Canlı ürün bug sayısı **yok** — `mvp_bug_count_at_launch` sabit; ship-sonrası bug biriktiren tick **yok** (Bölge 2/4).

> **Part 2 için nereye bağlanır:** "Ürün durumu" bloğu (canlı bug, effective stability, versiyon) = **kodla kurulacak yeni PanelContainer**, `_ensure_pricing_panel`'in aynısı: `post_ship_view.add_child(panel); post_ship_view.move_child(panel, 2)` pattern'i. Versiyon etiketi `:886`'daki `"· v1"` yerine `mvp_version` okuyacak (Bölge 3). Canlı bug/stability için önce Part 2'nin **canlı ürün state alanları** gerekli (donmuş flag yerine güncellenen değerler).

---

## BÖLGE 2 — Yıpranma kancaları (Part 1'in bıraktıkları)

### effective_stability — kanca var, YARIM bağlı
- `QualityModel.effective_stability(stability, bug_count) = max(0, stability − 1.5·bug_count)` (`quality_model.gd`). `economy_dims_from_flags()` stability yerine bunu koyar; `mvp_bug_count_at_launch`'ı okur.
- `shipped_normalized()` → `economy_dims_from_flags()` → **audience/MRR bunu okuyor** (`SalesSystem._audience_delta_per_hour` → `shipped_normalized()`). Yani teorik olarak **bug artarsa audience düşer**.
- **AMA:** `mvp_bug_count_at_launch` ship-sonrası **hiç artmıyor** → effective_stability sabit → kanca ateşlenmiyor. **Eksik parça:** ship-sonrası bug biriktiren bir tick + canlı bug alanı (donmuş flag yerine). Bunu bağlayınca "kullanım→bug→stability düşer→audience erir" zinciri otomatik çalışır (audience zaten effective_stability okuyor).

### Çift-yönlü audience — matematiksel olarak neredeyse tek-yönlü
`SalesSystem._audience_delta_per_hour()` (Part 1):
```
delta = (HOURLY_AUD_BASE 0.08 + nq·0.006 + brand·0.004 + reputation·0.01) · audience_growth_multiplier(price)
```
- Part 1'de **`− bugs·coef` çıkarıldı** (bug'lar artık effective_stability üzerinden `nq`'ya giriyor).
- `nq` (normalized) **0'da tabanlanıyor** → bug'lar `nq`'yu en fazla 0'a çeker, negatife değil. Üstelik **base 0.08 + brand·0.004** (brand 50 → +0.2) pozitif taban yaratıyor.
- Sonuç: **erozyon (delta<0) pratikte imkânsız** — ancak reputation çok negatif + brand düşük + nq 0 birleşirse. Part 1 done'daki "yavaşlar ama erimez"in kod sebebi budur.
- **Erozyon için ne değişmeli (Part 2):** (a) ship-sonrası **canlı bug artışı** (yukarıda), **VE** (b) pozitif tabanı koşullu yap **ya da** düşük-effective-stability/yüksek-bug'da bir **negatif churn terimi** ekle (`− k·max(0, threshold − effective_stability)` gibi). Sadece bug biriktirmek yetmez; taban 0.08 pozitif kaldıkça audience yine de yavaş büyür.
- `growth_band()` de aynı `_audience_delta_per_hour()`'ı okuyor (R1≡R6 senkron) — "eriyor" bandı zaten var (`delta ≤ −0.1`) ama yukarıdaki sebeple nadiren tetiklenir.

### RIVAL_RELATIVE kancası — hazır, kapalı; açmak gerekli-ama-yetersiz
- `SalesSystem.RIVAL_RELATIVE := false` + `_rival_relative_quality(player_nq)`: `clampf(50 + (player_nq − same_type_rival_avg_nq), 0, 100)`. Flag açılınca audience'ın kalite terimi mutlak yerine **rakip-göreli** olur.
- `RivalRegistry.get_by_type(sub)` erişilebilir; rakipler **günlük ilerliyor** (`advance_all`, `_tick_rivals`). Yani oyuncu dururken rakip ortalaması yükselir → `player_nq − avg` düşer → kalite terimi düşer → audience yavaşlar. **"Rakip seni geçince audience yavaşlar" bu flag'i açmakla otomatik gelir.**
- **AMA yetersiz:** kalite terimi `clampf(…, 0, 100)` yine pozitif tabanlı formüle giriyor → base 0.08 yüzünden **audience kaçmaz, sadece yavaşlar**. Gerçek "audience KAÇAR" için Bölge 2'deki taban/churn düzeltmesi şart. Yani RIVAL_RELATIVE flip = gerekli ama tek başına yetersiz.

### Ship-sonrası product tick — YOK
`ProductSystem.hourly_tick()` ilk satır `if active_build == null: return`. Build bitince (`active_build = null`) **ürüne dokunan hiçbir tick kalmıyor**. Audience saatlik akar (`SalesSystem.hourly_tick`) ama **ürünün kendi yıpranması için yeni bir ship-sonrası tick gerekli.**

> **Part 2 için nereye takılır:** yeni bir `ProductSystem` ship-sonrası fonksiyonu (canlı bug accrual + effective-stability güncelleme), `TimeManager._tick_product_hourly`'ye `active_build==null && mvp_shipped` dalı olarak eklenir (mevcut slot, `time_manager.gd:196`). Ya da SalesSystem hourly'ye bir ürün-yıpranma adımı.

---

## BÖLGE 3 — Versiyon update için yeniden-build yolu

### Tek-yönlülük: engel **routing**, `start_build` değil
- `_refresh_view` shipped → PostShipView'a sabitliyor; tasarıma dönüş edge'i yok.
- **`ProductSystem.start_build(sub, features, engineer, product_name)`** guard'ı: `if active_build != null: return false`. Ship-sonrası `active_build == null` → **start_build TEKRAR ÇAĞRILABİLİR.** Tıkalı olan tek şey ekran routing'i.
- Yani: yeni bir `active_build` set edilirse `_refresh_view` **zaten** BuildProgressView'a route eder (`active != null` dalı). Versiyon build'i mevcut build UI'ından "bedava" akar.

### Mevcut ürün state'ini v2'ye taşıma — seed gerekli
- `start_build` şu an eksenleri **sıfırlıyor** (`b.innovation = b.stability = b.usability = 0`, `product_system.gd`). v2 sıfırdan değil, v1'in üstüne kurulmalı.
- **v2 dims seed'i:** `mvp_innovation/stability/usability` flag'lerinden okunup FeatureBuild'e set edilmeli. `mvp_components` (v1 feature'ları) + yeni eklenen feature'lar → yeni `feature_ids`; `bug_count` = `mvp_bug_count_at_launch` (taşınır veya kısmen).
- **En temiz yol:** `start_build`'i bozmadan **yeni `start_version_build(new_features, product_name)`** — v1 flag'lerinden dims/bug/components seed eder, `active_build` set eder, `EventBus.build_phase_changed.emit("iteration")`. Mevcut build state-machine + HUD + event'ler değişmeden çalışır. (Alternatif: `start_build`'e `seed_dims` opsiyonel parametresi.)

### `mvp_version` — YOK
- Versiyon sayacı flag'i yok; `"· v1"` `product_tab.gd:886`'da **hardcoded**.
- **Part 2:** `mvp_version` flag'i (launch'ta 1, her versiyon ship'inde +1) + `:886`'yı `"· v%d · canlı" % version`'a çevir. Ship-sonrası merge: v2 bitince dims'i tekrar `mvp_*`'a yaz + `mvp_version += 1`.

---

## BÖLGE 4 — Bug sprinti + üçlü tercih + HR köprüsü için zemin

### Founder aksiyon / karar UI'ı — tek CTA var (fiyat)
- PostShipView'da oyuncunun aksiyon seçtiği tek yer: **`_pricing_apply`** (`product_tab.gd:1091`, `CommitButton` amber). Pattern: kodla kurulan PanelContainer + CommitButton (`_ensure_pricing_panel`).
- **Part 2:** "Bug Sprinti başlat" / "v2 geliştir" / "Fiyat" gibi aksiyonlar → aynı pattern'de **kodla kurulan bir "Aksiyonlar" kartı** (PanelContainer, PostShipView'a `move_child(panel, 2)` ile mount). Fiyat CTA'sı birebir örnek.

### Faz / meşguliyet state — ship-sonrası YOK; `active_build` yeniden kullanılabilir
- Ship-sonrası "founder meşgul / aksiyon sürüyor" state'i **yok**.
- **`active_build` kavramı bug-sprinti için yeniden kullanılabilir:** build state-machine (faz sayaçları + saatlik tick + "meşgul" hissi) zaten var. Bir bug-sprinti "hafif bir active_build" (ör. `current_phase = "bugfix"` benzeri, kısa) olarak modellenebilir → BuildProgressView + HUD onu gösterir, bu sürede yeni build engellenir (guard zaten `active_build != null`). Alternatif: yeni bir `founder_busy_until` flag + tick. **En az yeni-kavram:** active_build'i reuse et.

### HR köprüsü — HR neredeyse yok; köprü hafif olmalı
- `HRSystem` (`hr_system.gd`) **sadece morale drift** yapıyor (`daily_tick` → `_baseline_morale_tick`). **Hire flow YOK.**
- `CharacterRegistry`: founder + mentor (`ensure_mentor`) var; **`DEBUG_SEED = false` → 0 çalışan**. Employee'ler yok.
- **Yani HR modülü (hire flow, candidate spawn, roster) hazır DEĞİL** — ayrı task. Part 2'nin "HR köprüsü" = **hafif bir kanca**: bug-sprinti baskısı → "mühendis lazım" flag/sinyali (ör. `set_flag needs_engineer` + Frank advisory + bir event), gerçek işe alım **ayrı HR task'ında**. Köprü = flag + işaret, modül değil.

### Traction / phase geçişi — PLACEHOLDER
- `ready_for_traction` flag'i `SalesSystem._check_traction` (`sales_system.gd:258`) ile set edilir: `traction_progress() ≥ 1.0`. `traction_progress = clampf(max(mrr/5000, customers/8), 0, 1)` (`:252`).
- "Hazır — Frank'le konuş" chip'i bir **badge** (buton değil, aksiyon yok). `ev_ps_traction_ready` = tek-seçenekli **anlatı beat**'i (flag + advisory, phase değiştirmez).
- `GameState.phase` (1-3) + `set_phase` (`game_state.gd:33,75`) var **ama** `TimeManager._tick_phase_check` (`time_manager.gd:188`) = **`pass` TODO**. **Faz geçişi (Bootstrap→Traction) implement edilmemiş.**
- **Versiyon/büyüme kesişimi:** şu an yok. Part 2 versiyon/traction'ı bağlarsa (ör. v2 ship → MRR sıçraması → traction), `_tick_phase_check`'in doldurulması ayrı bir bağımlılık (bu audit'in dışı ama Part 2 spec'i farkında olmalı).

---

## EN RİSKLİ NOKTA (spec yazarken en çok dikkat)

**En riskli/en çok dokunulacak yer YIPRANMA (erozyon) tick'i — çünkü ekonomiye dokunuyor ve tek değişiklik yetmiyor, üç şeyi eşgüdümlü değiştirmek gerekiyor:** (1) ship-sonrası **canlı bug accrual** tick'i (donmuş `mvp_bug_count_at_launch` yerine güncellenen bir alan) + (2) audience formülünün **pozitif tabanını koşullu yapmak ya da bir negatif churn terimi** eklemek (yoksa bug biriket de audience erimez, sadece yavaşlar) + (opsiyonel 3) `RIVAL_RELATIVE`'i açmak. Bu üçü Part 1'in en kırılgan yüzeyine (SalesSystem `_audience_delta_per_hour`, R1≡R6 senkronu, normalize sözleşmesi) dokunuyor; yanlış ayar audience'ı ya patlatır ya çökertir — **normalizasyon/taban sözleşmesini bozmadan** yapılmalı. Buna kıyasla **versiyon yeniden-build yapısal olarak KOLAY** (start_build zaten çağrılabilir; sadece routing + dims-seed + merge + `mvp_version` gerekiyor) ve **üçlü-tercih state'i orta** (active_build reuse edilirse yeni state-machine gerekmez).

**Ship-sonrası akışı tek-yönlülükten çıkarmanın en temiz yolu:** `start_build`'in guard'ına **dokunma** (o zaten `active_build==null` iken çalışır). Bunun yerine PostShipView'a **kodla bir "Aksiyonlar" kartı** ekle; "v2 geliştir" butonu yeni bir **`start_version_build()`** çağırsın — bu, `mvp_*` flag'lerinden dims/bug/components seed eder ve `active_build`'i set eder. `_refresh_view` **zaten** non-null `active_build`'i BuildProgressView'a route ettiği için versiyon build'i mevcut build UI'ından hatasız akar; ship anında dims'i `mvp_*`'a geri yaz + `mvp_version += 1`. Böylece tek-yönlülük, ekranı yeniden yazmadan, tek bir aksiyon-entry + seed/merge ile kırılır.

---
*Rapor sonu — salt-okunur denetim, kod değiştirilmedi.*
