# B2B Product Type & Sales Flow — Uçtan Uca Durum Tespiti (Audit)

**Tarih:** 2026-07-02 · **Tür:** Salt-okunur (kod değişmedi) · **Amaç:** B2B ürün tipinin ve satış akışının uçtan uca hangi parçalarının **CANLI / YARIM / PLACEHOLDER / YOK** olduğunu tahmin etmeden, koddan kanıtla ortaya koymak.
**Bağlam:** B2C akışı (build → ship → wear → sprint → versiyon → pricing → audience/churn/MRR) Part 1 + Part 2A/B ile kuruldu. B2B parça parça değinildi ama sistematik test edilmedi. Bu rapor karar (demo'ya girsin mi / spec'lensin mi / "Coming Soon" mu) için zemin.

**Durum lejantı:** CANLI = çalışır, ekonomiye/oyuncuya bağlı · YARIM = kısmen bağlı, boşluk var · PLACEHOLDER = kod var ama varsayılan kapalı/sahte · YOK = hiç kod yok.

**TL;DR:** B2B ürün tipi **onboarding→build→ship→pitch→deal→MRR** zinciri boyunca büyük ölçüde **CANLI**. Sales dialog / prospect flow gerçek ve uçtan uca çalışıyor (spekülasyon değil). B2C paritesindeki asıl boşluklar ekonominin **sürekli akış** tarafında: B2B MRR anlaşma-güdümlü ve statik (saatlik akış yok), pasif churn yok, traction bayrağı B2B'de hiç kalkmıyor.

---

## Bölüm 1 — B2B ürün onboarding'de seçilebiliyor mu?

### 1.1 B2B ayrı bir seçim ekseni DEĞİL — sub-type'ın bir özelliği · **CANLI (dolaylı)**
Onboarding subgenre adımı yalnız **AI** ve **SaaS**'ı seçtiriyor; Social "Coming Soon" (disabled):
- `scripts/onboarding/steps/subgenre_step.gd:8-9` `SUBGENRE_AI := "ai"` / `SUBGENRE_SAAS := "saas"`; `:21` `_apply_disabled_recipe(social_card)`; `:61-62` `is_valid()` yalnız ai/saas.

B2B/B2C ayrımı **subgenre'de değil**, her sub-type kaydındaki `market_type` alanında:
- `scripts/systems/product_catalog.gd:8-9` (yorum): *"market_type ("b2c" | "b2b") drives the PostShip sales model … B2C → audience/organic; B2B → prospect + pitch dialogue."*
- B2B sub-type'lar: `ai_vector_search` → `"market_type": "b2b"` (`:28`), ve **tüm 5 SaaS** b2b: `saas_project_mgmt` (`:33`), `saas_crm` (`:36`), `saas_analytics` (`:39`), `saas_billing` (`:42`), `saas_dev_tools` (`:45`).
- B2C sub-type'lar: `ai_assistant` (`:19`), `ai_photo_editor` (`:22`), `ai_code_copilot` (`:25`).

**Önemli sonuç:** Oyuncu onboarding'de "B2B" diye bir şey seçmiyor. Subgenre seçiyor (AI/SaaS), market_type ise **build sırasında seçilen sub-type ile** belirleniyor (sub-type seçimi onboarding'de değil, ProductTab DesignDocumentView'da — onboarding step listesi `Origin→Skill→Trait→Subgenre→Company→Confirm`, `onboarding_flow.gd:33-40,68` — arada sub-type step'i yok). Pratik pencere: **SaaS seçen kesin B2B** olur; **AI seçen 4 seçenekten 1'i (vector_search) B2B**, kalanı B2C. Yani B2B ürün "seçilebiliyor" ama üzerinde "B2B" yazan bir düğmeyle değil.

### 1.2 MVP build hiyerarşisi B2B için tanımlı · **CANLI**
L1 subgenre → L2 sub-type → L3 feature yapısı B2B'de B2C ile **aynı ve dolu**:
- B2B feature havuzları var: `ai_vector_search` (`product_catalog.gd:85-92`, 6 feature), `saas_project_mgmt` (`:93-100`), `saas_crm` (`:101-108`), `saas_analytics` (`:109-116`), `saas_billing` (`:117-124`), `saas_dev_tools` (`:125-132`). Her feature `complexity/pull/stakes/dimension_contribution` taşıyor — B2C feature'larıyla birebir aynı şema.
- Seçim yolu ortak: `ProductCatalog.get_feature_pool(sub_type_id)` (`:198-199`) B2B/B2C ayırt etmiyor.

### 1.3 B2B tip-özel quality axes gerçekten BAĞLI (tanımlı-ama-kullanılmıyor değil) · **CANLI**
Rapor sorusu: "B2B'de Kararlılık → 'Veri Güvenliği & Ölçek' display_label vardı — bağlı mı yoksa ölü mü?" → **Bağlı.**
- Tanım: `product_catalog.gd:160-163` `ai_vector_search` → `stability` weight **1.6**, `display_label` **"Veri Güvenliği & Ölçek"**; ayrıca `saas_billing` stability→"Doğruluk & Güvenlik" (`:183`), `saas_dev_tools`/`ai_vector_search` usability→"Entegrasyon Kolaylığı" (`:163,189`).
- **Kullanım (kanıt):** `QualityModel.shipped_normalized()` (`quality_model.gd:143-145`) ve `shipped_composite()` (`:149-151`) sub-type'ın axes'ini `ProductCatalog.get_quality_axes(sub)` ile alıp `composite_quality`'ye besliyor. Bu ekonominin okuduğu kalite sayısı (audience deltası, product_value, satisfaction hepsi buradan). `SalesSystem.product_value()` (`sales_system.gd:308-318`) ve `_value_lines()` (`:329-353`) de aynı axes'i okuyor — rationale satırları B2B'de gerçekten "Veri Güvenliği & Ölçek 63 → orta" yazıyor (`:337-343`).
- `weight` farklılıkları (B2B'de stability ağırlıklı) `composite_quality`'nin ağırlıklı ortalamasına giriyor (`quality_model.gd:68-76`) → **pazar tipine göre hangi eksenin fiyat/kalite gücü verdiği gerçekten değişiyor.**

**Bölüm 1 sonucu:** B2B ürün seçilip kurulabiliyor; hiyerarşi + tip-özel quality axes canlı. Tek "belirsizlik" tasarımsal: oyuncuya "B2B mi B2C mi" diye açık bir seçim sunulmuyor, market_type sub-type'tan türüyor.

---

## Bölüm 2 — B2B ürün build + ship edilebiliyor mu?

### 2.1 Build akışı market'ten BAĞIMSIZ (tek ortak yol) · **CANLI**
B2B ürün B2C ile **birebir aynı** build akışından geçiyor — ayrı yol yok:
- `ProductSystem.start_build()` (`product_system.gd:451-489`): yalnız sub-type geçerliliği + feature sayısı (2-4) + havuz üyeliği doğruluyor. **Hiçbir `market_type` / `is_b2b` dalı yok.**
- Saatlik büyüme fazları `iteration/development/bugfix/bug_sprint` (`hourly_tick`, `:152-182`) market'e bakmıyor — quality eksenleri, bug accrual, sprint mantığı ortak.

### 2.2 Ship / launch B2B'yi ayrı ele ALMIYOR — sadece market_type damgalıyor · **CANLI**
- `launch()` (`product_system.gd:390-442`) tek yol. B2B'ye özgü tek satır: `:441` `GameState.set_flag("mvp_market_type", ProductCatalog.get_market_type(active_build.sub_product_type_id))`. Bunun dışında snapshot (innovation/stability/usability, bug, versiyon, quality köprüsü) market'ten bağımsız yazılıyor (`:413-437`).
- `ship_active_build()` (`:659`) ortak; B2B için özel dal yok.
- `mvp_market_type` bayrağı ship-sonrası tüm dalların anahtarı (`SalesSystem.hourly_tick`, `PostShipView`, event trigger'ları hep bunu okuyor).

**Bölüm 2 sonucu:** B2B ürün B2C'yle aynı build/ship omurgasından geçiyor; fark yalnızca ship anında yazılan `mvp_market_type` bayrağı. Ayrım ship-sonrası başlıyor (Bölüm 3).

---

## Bölüm 3 — B2B ship sonrası ekonomi akıyor mu? (EN KRİTİK)

### 3.1 B2B'nin saatlik ekonomi tick'i YOK — B2C-only · **YARIM (bilinçli tasarım + boşluk)**
`SalesSystem.hourly_tick()` yalnız B2C dalını işletiyor:
```
sales_system.gd:101-108
static func hourly_tick(_hour: int) -> void:
    if GameState.get_flag("mvp_shipped", false):
        var market := String(GameState.get_flag("mvp_market_type", "b2c"))
        if market == "b2c":
            _tick_b2c_audience()   # audience akışı
            _derive_b2c_mrr()      # MRR = paying × price
            _check_traction()
    _mrr_bridge()
```
- **`else` (b2b) dalı yok.** B2B için saatlik audience/MRR türetimi çalışmıyor. B2B'de `_mrr_bridge()` yine çağrılıyor (`:108`) ama o sadece `CustomerRegistry.get_total_mrr()`'ı GameState'e yansıtan **pasif toplam** — yeni gelir üretmez.
- Tasarım niyeti kod yorumunda net: `sales_system.gd:14` *"B2B: pitch-driven, fixed MRR (seat × negotiated price). No auto-flow."* Yani B2C'deki "saatlik bidirectional audience" karşılığı B2B'de **bilinçli olarak yok**; B2B geliri anlaşma-güdümlü.

### 3.2 B2B MRR nereden geliyor: imzalanan anlaşma (pitch) + expansion event'i · **CANLI**
B2B MRR **hardcoded/placeholder değil** — oynanmış pitch'ten türüyor:
- `PitchSystem._resolve_outcome()` (`pitch_system.gd:269-276`): SIGNED'da `target = lerp(MRR_BANDS[archetype].low..high, price_mult)`; `mrr = round(target × mrr_mult)`. Bantlar `pitch_system.gd:22-26` (small 200-500 / mid 800-2000 / enterprise 3000-8000).
- Bu MRR `SalesSystem.add_b2b_customer(prospect, mrr, satisfaction)` (`sales_system.gd:235-252`) ile bir `Customer` kaydına yazılıyor; `:251` imzalandığı an `GameState.set_mrr(CustomerRegistry.get_total_mrr())` ile ekonomiye yansıyor.
- **Nüans (seat vs MRR):** `add_b2b_customer` seat'i `_seats_for_archetype` (`:255-259`, enterprise 40 / mid 12 / small 4) ile ayrıca saklıyor **ama MRR seat×fiyat olarak hesaplanmıyor** — MRR bant-lerp'ten geliyor. Pitch'in fiyat ipucu ekranı (`_pitch_value_hint`, `pitch_system.gd:98-111`) seat başına fiyatı ürün değerinden gösteriyor, ama imzalanan rakam banttan türüyor. Yani "seat sayısı × fiyat" görünür bir çerçeve; motor değeri **bant × pazarlık seçimi**. Placeholder değil, ama seat rakamı ekonomik olarak MRR'ı sürmüyor.
- **Expansion (gerçek B2B büyüme):** `ev_ps_expansion_b2b.json` → `customer_mrr_delta` modifier'ı mevcut B2B hesabının MRR'ını artırıyor (`event_manager.gd:373-379`, `+600`/`+1000` seçime göre). Oynanmış karar → MRR artışı. CANLI.

### 3.3 Part 2A wear/erosion/churn B2B'de: kısmen çalışıyor · **YARIM**
- **Wear (canlı bug birikimi): B2B'de çalışıyor ama audience-kör.** `_post_ship_wear_hourly()` (`product_system.gd:204-219`) yalnız `mvp_shipped`'e bakıyor, market'e değil (`product_system.gd:152-156`), yani B2B ürün de yıpranıyor. AMA wear oranı `audience × WEAR_AUD_COEF + complexity×… − tech×…` (`:211`) ve B2B'de `b2c_audience = 0` → wear yalnız **complexity + WEAR_FLOOR**'dan geliyor (B2C'ye göre zayıf, ama sıfır değil). Sonuç: canlı bug artar → effective stability düşer.
- **Satisfaction drift: B2B müşterilere UYGULANIYOR.** `_tick_satisfaction()` (`sales_system.gd:264-277`) `CustomerRegistry.get_active()` üzerindeki **tüm** müşterilere (B2B dahil) `mvp` stability + `mvp_live_bug_count` okuyarak günlük drift uyguluyor. Yani wear → B2B müşteri memnuniyeti düşüşü zinciri bağlı.
- **Pasif churn (audience erosion): B2B'de YOK.** `_tick_b2c_audience`'ın churn terimi (`sales_system.gd:154`) audience'a proporsiyonel ve **B2C-only**. B2B'nin audience'ı olmadığı için pasif erozyon yok.
- **B2B churn yalnız event-aracılı VAR.** `churn_customer` modifier'ı (`event_manager.gd:361-372`) B2B için en düşük memnuniyetli hesabı siliyor (`:371 CustomerRegistry.remove`). Tetikleyici canlı: `ev_ps_bug_complaint.json` **market-gate'siz** (`trigger_conditions`: `customer_count_min≥1` + `customer_satisfaction_below 60` + `random 0.5`); "Görmezden gel" seçeneği `churn_customer` fırlatıyor (`ev_ps_bug_complaint.json:37-40`). Yani wear→bug→memnuniyet<60→şikayet event'i→(oyuncu ihmal ederse) B2B hesap kaybı zinciri **uçtan uca kapalı**, ama pasif değil (oynanmış seçime bağlı — Principle #2 ile tutarlı).

### 3.4 Traction bayrağı B2B'de hiç kalkmıyor · **YARIM (gerçek boşluk)**
- `_check_traction()` (`sales_system.gd:288-294`) `ready_for_traction` bayrağını set eden **tek** yer, ve yalnız `hourly_tick`'in **B2C dalında** çağrılıyor (`:107`). `daily_tick`'te veya B2B dalında çağrı yok (grep doğrulandı: tek çağrı `sales_system.gd:107`).
- Sonuç: B2B ürün $5000 MRR / 8 müşteri hedefine ulaşsa bile `ready_for_traction` **hiç true olmuyor** → "Traction'a hazır" beat'i (EventManager eligibility'si bu bayrağı bekliyor) B2B'de tetiklenmiyor.
- PostShip'teki **traction bar'ı yine doluyor** çünkü `product_tab.gd:1195` `SalesSystem.traction_progress()`'i canlı okuyor (`:282-285`, B2B'de `customers/8` üzerinden ilerler). Yani görsel ilerleme var, ama **faz-geçiş kapısı B2B'de açılmıyor.** (Not: faz-geçişi zaten proje genelinde stub — bkz. memory; ama B2B özelinde bayrak hiç yazılmıyor.)

**Bölüm 3 sonucu (kritik cevap):** B2B ürün **para kazanabiliyor** — pitch imzası + expansion event'i ile gerçek MRR üretiyor ve GameState'e yansıyor. Ekonomi "placeholder" veya "B2C'ye düşme" değil. Ama B2C'nin sürekli/otomatik akış tarafı B2B'de yok: MRR anlaşmalar arası **statik**, pasif churn yok, traction bayrağı hiç kalkmıyor.

---

## Bölüm 4 — Sales dialog / prospect flow var mı?

### 4.1 Sales tab: gerçek ekran, placeholder değil · **CANLI**
- Ekran: `scenes/tabs/SalesTab.tscn` + `scripts/tabs/sales_tab.gd` — iki kolon (Prospects: Pitch/Find butonları · Customers) + metrik satırı. Boş-state değil, canlı veriden satır kuruyor (`sales_tab.gd:67-114`).
- Erişilebilir: `center_viewport.gd:10` `"sales": preload(".../SalesTab.tscn")`; `left_tabs.gd:18` `$Margin/Col/SalesBtn`; `ui_tokens.gd:111` TABS içinde `{"id": "sales", "label": "Sales", …}`. Sol tab'dan tıklanabilir.
- Metrik satırı market-farkında (`sales_tab.gd:61-64`): B2C → "N ödeyen kullanıcı", B2B → "N müşteri".

### 4.2 Find Prospects + prospect üretimi · **CANLI**
- `find_button` yalnız B2B'de görünür (`sales_tab.gd:73` `find_button.visible = is_b2b`), 5 gün cooldown-gate'li (`:9,74-76,126`).
- Basınca 2 prospect üretiyor: `sales_tab.gd:119-127` → `PitchSystem.spawn_prospect(archetype, "find")`.
- `PitchSystem.spawn_prospect()` (`pitch_system.gd:52-66`) gerçek Prospect kaydı üretiyor (şirket adı/sektör/need/difficulty/budget_band havuzlardan, `:29-38`) → `ProspectRegistry.add` → `EventBus.prospect_added` → Sales tab repaint.

### 4.3 Pitch dialogue: 4-sahneli tam akış · **CANLI**
- Motor: `PitchSystem` (`pitch_system.gd`) — `intro → value → pricing → close` (`:139-200`). SkillCheck rolleri: value'da markets/charisma (`:220`), close'da charisma (`:236-237`). Markets eşiği prospect'in gizli budget_band/real_need'ini açıyor (`:145-147`, `SkillCheck.can_read_prospect`).
- Renderer: `pitch_dialogue_modal.gd` (`begin/get_stage/choose` çağırıyor, `:28-71`); sonuç paneli SIGNED/CALLBACK/LOST metni (`:103-118`).
- Mount: `main.gd:156-168` `_on_pitch_requested` → PitchDialogueModal'ı ModalLayer'a ekliyor + oyunu duraklatıyor (`:161`). Kapanışta `pitch_finished` → hız restore (`:171-178`).
- Deal kapatma → müşteri: `pitch_system.gd:274` SIGNED'da `SalesSystem.add_b2b_customer(...)` + `ProspectRegistry.remove` (`:275`). CALLBACK'te prospect havuzda kalıyor (`:280`), LOST'ta siliniyor (`:279`). Cooldown `next_pitch_day` (`:254`, 2 gün).

### 4.4 PostShipView "Sales'e git" butonu: gerçek bağlantı, dead-end değil · **CANLI**
- Buton yalnız B2B dalında görünür: `product_tab.gd:1183` `post_ship_sales_button.visible = true` (B2C dalında `:1168` gizli).
- Basınca: `product_tab.gd:1340-1341` `_on_post_ship_sales_pressed()` → `EventBus.tab_changed.emit("sales")` → dolu Sales tab'a gidiyor (boş sekmeye değil).
- B2B durum metni de canlı: müşteri yoksa prospect varsa "İlk pitch'in Sales sekmesinde seni bekliyor", yoksa "Frank seni biriyle tanıştıracak"; varsa "N müşteri · MRR $X" (`product_tab.gd:1177-1182`).

### 4.5 B2B sales akışına GİRİŞ otomatik seed'li · **CANLI**
- İlk prospect elle "Find" gerektirmiyor: `ev_ps_frank_intro_b2b.json` (`one_shot`, trigger `mvp_shipped` + `market_type b2b`, `cooldown 0`) → seçince `add_prospect(archetype=mid, source=frank_intro)` (`:20`). `market_type` trigger'ı EventManager'da işleniyor (`event_manager.gd:218-219`). Yani B2B ürün ship edilince ilk lead kendiliğinden geliyor.
- Ek seed: `ev_ps_referral_b2b.json` → `add_prospect` (mid/small, `:20-30`), market-gate'li (`:10`).

### 4.6 CustomerRegistry B2B debug müşterileri (Nordica/Palmiye/Beykoz) · **PLACEHOLDER (varsayılan kapalı)**
- `customer_registry.gd:24` `const DEBUG_SEED := false` → normal oyunda seed **çalışmıyor**; oyun 0 müşteriyle başlıyor.
- Seed edilirse bile ekonomiye "yarı bağlı": `_seed_debug_customers()` (`:175-200`) doğrudan `_customers[...]` yazıyor, `add()` çağırmıyor → `customer_added` sinyali fırlamıyor (yorum `:172-174`). MRR toplamı yine `get_total_mrr()`'a girer ama sinyalsiz.
- **Gerçek B2B müşterileri sağ panel placeholder'ı DEĞİL:** canlı runda B2B müşteri yalnız imzalanan pitch'ten doğuyor (`add_b2b_customer` → `CustomerRegistry.add` → `customer_added` → hem Sales tab hem `_mrr_bridge` → GameState.mrr). Bunlar tam ekonomiye bağlı. Yani debug isimler placeholder; canlı B2B müşteriler gerçek.

**Bölüm 4 sonucu (kritik cevap):** Sales dialog / prospect flow **var ve uçtan uca çalışıyor** — bekleyen "horizon" değil. Prospect üretimi (Frank intro + Find + referral), 4-sahneli pitch (SkillCheck'li), deal kapatma (→ gerçek müşteri + MRR) hepsi canlı. Debug müşteriler kapalı placeholder; canlı müşteriler ekonomiye bağlı.

---

## Bölüm 5 — B2B vs B2C: parite haritası

### 5.1 Özet tablo

| Ana özellik | B2C | B2B | Kanıt (dosya:satır) |
|---|---|---|---|
| Onboarding / tip seçimi | CANLI | **CANLI** (dolaylı — sub-type market_type'ından) | `subgenre_step.gd:61`, `product_catalog.gd:28,33-45,223-225` |
| Build (iteration/dev/polish/bug) | CANLI | **CANLI** (ortak, market-agnostik) | `product_system.gd:451-489,152-182` |
| Ship / launch | CANLI | **CANLI** (ortak; sadece market_type damgalanır) | `product_system.gd:390-442,659` |
| Tip-özel quality axes | CANLI | **CANLI** (B2B label'ları bağlı + okunuyor) | `product_catalog.gd:160-190`, `quality_model.gd:143-151` |
| Pricing kaldıracı | CANLI (slider → `apply_b2c_price`) | **YOK** (post-ship fiyat kolu B2B'de yok; fiyat pitch anında per-deal seçilir) | `product_tab.gd:1615` (price satırı `is_b2c`), `pitch_system.gd:181-186` |
| Ship-sonrası MRR akışı | CANLI (saatlik audience→MRR, çift yönlü) | **YARIM** (anlaşma-güdümlü, statik; saatlik akış yok) | `sales_system.gd:101-108,235-252` |
| Wear (canlı bug birikimi) | CANLI (audience-güdümlü) | **YARIM** (çalışır ama audience-kör, sadece complexity/floor) | `product_system.gd:204-219,211` |
| Erosion / pasif churn | CANLI (audience erozyonu) | **YOK** (pasif churn yok; yalnız event-aracılı churn) | `sales_system.gd:154`, `event_manager.gd:361-372` |
| Satisfaction drift → health | CANLI | **CANLI** (tüm aktif müşterilere, B2B dahil) | `sales_system.gd:264-277` |
| Bug sprinti | CANLI | **CANLI** (ortak build; aksiyon kartı B2B'de de görünür) | `product_tab.gd:1611-1670` (yalnız price satırı gate'li) |
| Versiyon (v2) build | CANLI | **CANLI** (ortak build yolu) | `product_system.gd:585,601`, `product_tab.gd:1660-1665` |
| Traction kapısı (`ready_for_traction`) | CANLI | **YARIM** (bar dolar, bayrak hiç kalkmaz) | `sales_system.gd:107,288-294` |
| Sales flow (prospect→pitch→deal) | YOK (B2C'de pitch yok — tasarımca) | **CANLI** (B2B'nin çekirdek gelir yolu) | `pitch_system.gd`, `sales_tab.gd`, `pitch_dialogue_modal.gd`, `main.gd:156-168` |
| Expansion / hesap büyütme | (audience spike event'leri) | **CANLI** (`customer_mrr_delta` event'i) | `event_manager.gd:373-379`, `ev_ps_expansion_b2b.json` |
| Sözleşme / renewal döngüsü | YOK | **YOK** (`Customer.renewal_day` tanımlı ama kullanılmıyor) | `customer.gd:43` |

### 5.2 B2B'yi B2C paritesine getirmek için eksik ana parçalar (kaba tespit — spec değil)
1. **Sürekli B2B ekonomi tick'i yok.** MRR imzalar arası statik; seat büyümesi, düzenli renewal/expansion kadansı yok (yalnız rastgele event'ler). `hourly_tick`'te b2b dalı yok (`sales_system.gd:101-108`).
2. **Pasif B2B churn yok.** Düşük memnuniyet kendi başına MRR/hesap kaybettirmiyor; churn yalnız oyuncunun ihmal ettiği `ev_ps_bug_complaint` seçeneğiyle (`churn_customer`). Memnuniyet health band'ini değiştiriyor (`customer.gd:52-58`) ama bunu okuyup churn eden pasif mekanik yok.
3. **`ready_for_traction` B2B'de hiç kalkmıyor** (`_check_traction` yalnız B2C dalında, `sales_system.gd:107`) → traction beat'i / faz kapısı B2B'de tetiklenmez.
4. **B2B fiyatlama post-ship kolsuz.** B2C'nin slider'ı gibi devam eden bir fiyat kaldıracı yok; fiyat yalnız pitch anında (`pitch_system.gd:181-186`). İmzadan sonra fiyat/anlaşma yeniden ayarlanamıyor (renewal/upsell sistemi yok).
5. **Wear B2B'de audience-kör** (`product_system.gd:211` audience terimi 0) → B2B ürün yıpranması zayıf/complexity-only; B2B'ye özel yıpranma sürücüsü (seat kullanımı, SLA vb.) yok.
6. **Sözleşme/renewal modeli yok** (`Customer.renewal_day` rezerve, `customer.gd:43`) — B2B için doğal olan dönemsel yenileme/kayıp döngüsü kurulmamış.

### 5.3 Sales flow B2B'nin çekirdeği mi? — **Evet.**
B2B geliri neredeyse tamamen **pitch + event güdümlü**: yeni B2B müşteri yaratan **tek** kod yolu `SalesSystem.add_b2b_customer`, o da yalnız `PitchSystem` SIGNED'dan çağrılıyor (`pitch_system.gd:274`). B2C'nin pasif audience→MRR akışının B2B'deki karşılığı **prospect→pitch→deal** zinciri. Yani B2B ekonomisi "başka türlü" kurulmuş değil — sales flow onun omurgası, ve o omurga canlı. Eksik olan, imza **sonrası** yaşam döngüsü (renewal, pasif churn, sürekli akış, traction kapısı).

---

## Belirsiz kalan noktalar (uydurma yok)
- **Seat rakamının rolü belirsiz:** `_seats_for_archetype` seat saklıyor (`sales_system.gd:255-259`) ve pitch UI seat başına fiyat gösteriyor (`pitch_system.gd:107-111`), ama imzalanan MRR bant-lerp'ten geliyor (`pitch_system.gd:270-272`) — seat, MRR'ı ekonomik olarak sürmüyor. Bu bilinçli bir sadeleştirme mi yoksa yarım kalmış "seat×fiyat" niyeti mi, koddan kesin çıkmıyor.
- **Faz geçişi B2B özelinde test edilmedi:** faz-transition zaten proje genelinde stub (memory: slot 8), o yüzden `ready_for_traction`'ın B2B'de kalkmaması pratikte tek başına faz'ı durduran şey değil; ama B2B'ye özgü ek bir boşluk olduğu kesin.
- **Debug müşteri seed'i açılırsa** (`DEBUG_SEED=true`) sinyalsiz eklendikleri için Sales tab / RightPanel'de anlık görünmeyebilirler (`customer_registry.gd:172-174`) — bu davranış yalnız debug modunda geçerli, canlı akışı etkilemiyor.

---

*Salt-okunur audit. Bu raporda hiçbir kod/dosya değiştirilmedi (yalnız bu rapor yazıldı). Karar + spec sonraki adım.*
