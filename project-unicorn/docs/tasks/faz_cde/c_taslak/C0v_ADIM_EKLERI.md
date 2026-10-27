# Faz C · C0v Adım ekleri

> **C0q tazelemesi (2026-10-20, taban `910ad1f`).** Ayrıntı: `C0q_TAZELEME.md`. 109 satır yerinde düzeltildi, 52 satır eklendi (125 "(C0q)" işareti). Satır numaraları Q'nun değiştirdiği dosyalarda 910ad1f'ya göredir; her adımın "Q'dan beklenen" bölümüne cevap eklendi. E1'e 9 yeni soru (23-31) girdi; 22 sorudan 5'ine Q notu eklendi.

Taban `main` @ `fc6b392` (`git archive` kopyası; çalışma ağacı okunmadı). (C0q) 2026-10-20'de `910ad1f`'a tazelendi: satır numaraları Q'nun değiştirdiği dosyalarda 910ad1f'ya göredir ("(C0q)" işaretli), Q'nun dokunmadığı dosyalarda iki taban aynıdır. Girdiler:
`PRD_FAZ_C_URUN_HESAP.md` (PRD), `ERDEM_QCD_CEVAP.md` §1 ve §2.2, `c_taslak/PLAN_C.md`, `c_taslak/C0_HARITA.md` (C0v
düzeltmeleriyle), `c_taslak/W1_METINLER.json` (242 metin). Bu ekler bağlayıcıdır: uygulayıcı her adımda buradaki listeyle
başlar; "öneri" yazan yer E1'de ya da adımın Opus incelemesinde kesinleşir.

Q'nun yeniden yazacağı dosyalar (`sales_system`, `sales_finalizer`, `sales_rep_system`, `sales_meeting_system`,
`sales_ledger`, `b2b_sales_system`, `b2b_constants`, `customer.gd`, `sprint_bridges`) yalnız fonksiyon adıyla anılırdı;
(C0q) Q bitti, satırları aşağıda ve `C0q_TAZELEME.md` §3'te (`b2b_constants.gd` Q'da değişmedi).

## 0. Her adımda ortak

- **Kapı sırası** (PLAN_C "Her commit'in akışı" 2; CLAUDE.md §12): `--event-lint` → `loc_residue` → `bash tools/smoke_run.sh
  loc_csv_integrity` → hedefli smoke → adımın kapıları → `bash tools/run_gate.sh` (PLAN_C farkı 4). `class_name` eklenir ya da
  silinirse önce `--headless --import` (CLAUDE.md §12 Tuzaklar).
- **Üretilmiş belgeler:** seam ya da fiil değişen commit `--event-vocab` koşar (`docs/content/events_draft/_vocabulary.md`);
  sinyal değişen commit `python tools/gen_signal_manifest.py` koşar (CLAUDE.md §12, §13).
- **Metin:** oyuncu metni W1'den gelir (`W1_METINLER.json`, alan `step`). Arayüz ve mail metni CSV anahtarıdır; kart
  metni kartın JSON'unda `text.tr`/`text.en` içinde durur (`incident_outage_b2b.json` satır içi gövde, `request_feature.json`
  CSV anahtarı; ikisi de bugün var). **Anahtar adı önerisi:** W1 id'sinin büyük harfli hâli, nokta yerine alt çizgi, önüne
  ailenin öneki: `ov.*` ve `server.*` → `PRODUCT_OV_*`, `PRODUCT_SERVER_*` (aile `PRODUCT_*`, csv `:2790-2926` (C0q));
  `fin.*` → `FIN_*` (`FIN_BURN_*` `:1441-1445` (C0q)); `clause.*`, `renew.*`, `budget_mail.*` → `B2B_CLAUSE_*`, `B2B_RENEW_*`,
  `B2B_BUDGET_*` (aile `B2B_*`, `:732-786`); `sat.*`, `accounts.*`, `sign.*`, `loss.*`, `sector.*` → `SALES_SAT_*`,
  `SALES_ACCOUNTS_*`, `SALES_SIGN_*`, `SALES_LOSS_BUGS_*`, `SALES_SECTOR_*` (aile `SALES_*`, `:117-150`, `:2471-2475` (C0q));
  `support.*` → `MAIL_SUPPORT_*` (kalıp `MAIL_RPT_*` `:3198-3203` (C0q)); `atlas.*` → `HR_ATLAS_DESK_*`; `office.*` → `OFFICE_*`
  (`:2719-2767` (C0q)). Yeni anahtar ailesinin yanına eklenir. Silinen anahtar okuyucusuyla aynı commit'te gider (CLAUDE.md §8).
- **Göç** yalnız C3a'dadır (PLAN_C "Kayıt"). Öbür adımlar yeni alanı anlamlı varsayılanla ekler: `Customer` ve öbür
  modellerde `@export` varsayılanı (`save_codec.gd:9-11`, `:66-82` (C0q)), `GameState` değişkeninde `initialize_run` değeri
  (`save_codec.gd:201-219` (C0q)), bayrakta `GameState.FLAG_TYPES` girdisi (`game_state.gd:48`; tipsiz bayrak JSON'dan float döner,
  `save_codec.gd:14-17`, `:222-242` (C0q)). JSON'dan dönen iç içe sözlük ve dizi sayıları float'tır; okuyucu `int()` yapar
  (`save_codec.gd:14-17`).
- **Görsel kabul:** TR, EN, `--palette=cb`, `--shot-scale=1.25` (PRD §4.6; CLAUDE.md §11, §12). Fikstür adları HARITA'ya.
  Aşağıdaki yeni tür adları önerilir; bayrak ailesi bugün vardır (CLAUDE.md §12).

---

## C1 · Sunucu, Genel Bakış iskeleti, kademe fiyatı, bot kapasite politikası

**Dokunulacak**
- `infra_system.gd`:
  - `CAPACITY_STEP` (`:50`) ve `adjust_capacity` (`:245-246`): adım `max(1, round(units × 0,10))` (K1).
  - `UNIT_PRICE_B2C`/`_B2B` (`:26`, `:28`): 125/250/500 ve 60/120/240 (K2).
  - `OCCUPANCY_AMBER` (`:60`) 0,80 → 0,90 ve `capacity_state` (`:212-221`) sarı %90, kırmızı %100 (PRD Karar 1).
  - Yeni `outage_load_mult()`: yük ≤ 0,90 → 1,0; ≤ 1,00 → 1,5; üstü ya da kapasitesiz canlı ürün → 2,5.
  - Yeni otomatik ayar okuması (eşik %80, adım yükü ~%65'e indirir, küçültmez; E1). Adım hesabı için `units_for_occupancy`
    (`:198-199`) kalır, tek okuyucusu bu olur.
- `report_inflow_multiplier` (`:297-305`): aşım ×1,5 dalı silinir, ×1,25 kalır.
- `support_system.gd:163-165`: yorum yerel çarpanı anlatır.
- `incident_system.gd:69-71` `load_mult()` gövdesi `InfraSystem.outage_load_mult()`'u okur; nasıl uygulanacağı E1 sorusu 1 ve 2.
  Yük cümlesi için zar anındaki yük `GameState.incident.pending`'e yazılır (`:117-120`) ve `olay.*` seam'i ondan okur
  (`seams_incident.gd`, yeni seam; kart `incident_outage_b2b/b2c.json` gövdesine `by_seam` varyantı; W1 `incident.load_line`).
- `product_state.gd:26-27`, `:274-297` (C0q): anahtar ve son otomatik büyüme yeni bayraklar; yazarı `ProductState`, karar `InfraSystem`
  (aşağıda "Özel doğrulama 1").
- Otomatik ayarın çağrısı: `time_manager.gd:436-442` `_dispatch_hourly_tick` içinde `SalesSystem.hourly_tick`'ten sonra tek
  çağrı. Gerekçe: imza, koltuk değişimi ve saatlik B2C kitlesi aynı saatte görülür; gece toplu adımı da saat saat geçer
  (`:183-200`) ve 00:00'ın saatlik dilimi günlük zardan önce koşar (`:153-157`). PRD "büyüme anında okunur" der; saatlik
  okuma bunu en çok bir saat gecikmeyle karşılar (A6'nın cevabı önerisi).
- Büyüme satırı "son 4 haftanın büyümesi" ister: hizmet edilen sayının geçmişi bugün saklanmıyor. 4 haftalık liste bayrak olarak
  tutulur (`TYPE_ARRAY`).
- Sürüm satırı ("v1.7 ile kapasite … indi"): yük çarpanı sürümde değişir (`ProductState.refresh_on_publish`,
  `sprint_system.gd:1529`). Önceki ve sonraki etkin kapasite sürüm kaydına yazılır. Sürüm kaydının yazarı `SprintSystem`'dir;
  köprü `SprintBridges` yalnız `requests`, `rival_hits` ve `thanks`'i yazar (CLAUDE.md §6). Alanı `SprintSystem._go_public`
  (`:1517-1532` (C0q)) ya da kapanış yazar.
- `SprintBridges.on_release`: kapasite satırı silinir; `requests`'i `met` yapan kısım kalır. `on_mvp` korunur.
  `sprint_system.gd:1532` (C0q) çağrısı kalır (istek kısmı için).
- `product_tab.gd`:
  - `VIEW_KEYS` (`:16`) üç kâğıt olur; `_build_ctl` (`:192-207`) v1.0 öncesi GENEL BAKIŞ kilidi (`D_locked_tab` kalıbı,
    `:199`).
  - Son açık kâğıt `_ui`'de hatırlanır, kayda yazılmaz (PRD Karar 10).
  - `product_model.gd` yeni `overview` modeli: C1'de yalnız Sunucu bloğu ve iskelet.
  - Yeni görünüm dosyası `scripts/tabs/product/` altında (`class_name` eklenirse `--import`).
  - Sunucu bloğu `EventBus.infra_changed`'i (`event_bus.gd:144`; bugün dinleyicisi yok) dinler.
- `run_probe.gd`:
  - `PRESETS` (`:154-186`) `server_lean`, `server_wide`, `server_auto`; `_seed_world` spec anahtarı `server` (`:1912-1922` (C0q)).
  - `_run_the_company` (`:1438-1451`) kapasite politikası; başlık yorumu (`:1436-1437` (C0q) "Servers … follow the releases on their
    own") düzelir.
  - Varsayılan politika önerisi: yük %90'ı geçince bir adım (elle oynayan oyuncu). `server_lean` payı %5'te,
    `server_wide` %40'ta tutar; `server_auto` anahtarı açar.
- `main.gd:3013-3014`, `:3742-3743`, `:4030` (C0q) fikstürleri yeni API'ye uyar.

**Silinecek kod**
- `infra_system.gd`:
  - `OVERAGE_*` (`:66-69`), `overage_satisfaction`, `satisfaction_delta_per_day` (`:286-292`), `acquisition_multiplier`
    (`:309-312`).
  - Uyarı mandalı ve kartı: `_warning_consumed_version`, `reset/to_dict/from_dict`, `due_capacity_warning`,
    `mark_capacity_warning_shown` (`:98-115`, `:327-340`).
- `support_system.gd:248` aşım payı. Destek zararının kendisi C3a'da gider.
- `SalesSystem._audience_delta_per_hour` içindeki `InfraSystem.acquisition_multiplier()` çarpanı (`sales_system.gd:195` (C0q); Q dosyası).
- `endgame_smoke.gd:14320` (C0q) `InfraSystem.reset()` satırı (`_seed_support_fixture`).
- Ar-Ge `incident_playbook` düğümünün etkisi (`rnd_tree.json:26`, `research_tree.gd:49-52`, `:308-310` (C0q)): E1 sorusu 4 karara
  bağlanmadan silinmez. Doğrulama `_validate_effects` her katsayının bir düğümde olmasını ister; etki silinirse liste, düğüm
  ve smoke `rnd_tree_loads_and_validates` (`:16073` (C0q)) aynı commit'te değişir.

**Smoke**
- Yeni (PRD §4.4 m.4): `capacity_step_immediate`, `load_mult_steps`, `no_hidden_overage`, `auto_capacity_grows_only`.
- Yeniden yaz:
  - `infra_capacity_moves_both_ways` (13803): %10 adım ve yeni fiyat.
  - `infra_heavy_step_costs_capacity` (13850): sarı eşik %90.
  - `infra_local_provider_tradeoff` (13935): ×1,5 satırları çıkar.
  - `incident_gap_and_spread` (15771): `_incident_world` (`:17150` (C0q)) kapasite alır. Almazsa 0,3 okur, beklenen 0,25'tir
    (C0_HARITA §4, C0v).
- Sil: `infra_overage_applies_and_stops` (13886).
- Fikstür değişince koşar: `incident_*`, `release_thanks_*`, `release_reviews_pick`, `paper_interrupt_order`,
  `inbox_no_night_stamp`, `rnd_tree_loads_and_validates`, `save_v10_product_state` (14520; `:16023` (C0q) bulut ve 7 birim).

**CSV**
- Silinecek: yok. Uyarı kartının anahtarı hiç yoktu (C0_HARITA §15).
- Değişecek: `PROD_RND_NODE_INCIDENT_PLAYBOOK_UNLOCK`/`_DESC` (`:2220-2221` (C0q)), E1 sorusu 4'e bağlı.
- Yeni: W1 `ov.tab_overview`, `ov.locked`, `server.*` (35 metin), `incident.load_line` (kart JSON'u).

**PROBE** (PLAN_C C1)
- Haftalık sunucu satırı önerisi: `PROBE SERVER day= units= provider= load= cap= bill= auto=`.
- `PROBE END`'e sunucu tıkı, otomatik büyüme sayısı ve kademe başına kesinti.
- Biçim başlık yorumuna (`run_probe.gd:27-133` (C0q)) yazılır.

**Görsel**
- `--product-shot=live:<tür>` (CLAUDE.md §12) yeni türler: `overview_pre` (v1.0 öncesi kilit), `server_80`, `server_94`,
  `server_104`, `server_growth`, `server_auto`.
- Kesinti kartı yük %90 üstünde `--event-shot`.

**Belge payı**
- CLAUDE.md §6 "Acil durum" paragrafı (yük çarpanı), §12 probe cümlesi (yeni kollar).
- HARITA `:34` (mandal cümlesi silinir), `:151` (`on_release` "altyapı payını da büyütür" silinir), `:154`, `:155`, `:160`,
  `:161`.
- GUNCELLEMELER `:152-154` (aşım), `:340-343` (C0q) (kesinti).
- `_vocabulary.md` (yeni `olay.*`, `urun.capacity_state`), sinyal manifesti (`infra_changed` dinleyicisi).

**Q'dan beklenen** (RAPOR_Q, C0q): `SprintBridges` içinde `push_axes` silindikten sonra `on_release`/`on_mvp`'nin adı ve yeri;
`SalesSystem._audience_delta_per_hour`'ın Q sonrası adı.
(C0q) Cevap: `push_axes` silindi; `_go_public` `sprint_system.gd:1519-1532` (`refresh_on_publish` `:1529`, `on_mvp` `:1531`, `on_release` `:1532`); `on_release` `sprint_bridges.gd:71-76` (gövde aynı, kapasite satırı `:75`), `on_mvp` `:125`. `_audience_delta_per_hour(quality := b2c_quality())` `sales_system.gd:188`, `acquisition_multiplier` çarpanı `:195`; kalite `hourly_tick`'te (`:151-163`) saatte bir okunur.

**D'ye devredilen**
- Genel Bakış iskeleti ve `_build_ctl`. D'nin ÇEYREK kilidi aynı işlevdedir (PRD Karar 10).
- PROBE sunucu alanlarının adları.

**Risk**
- Bot kapasite politikası yoksa her koşu 1 birimde kalır, yük %100'ü aşar ve kesinti ×2,5 işler (PLAN_C farkı 2).
- Kapasitesiz fikstürler bütün `incident_*` ailesini kaydırır.
- Yük çarpanının uygulanışı (E1 sorusu 1 ve 2) M7 kapısını belirler.

**Kapılar:** §4.4 m.4; hedefli smoke yukarıda; `run_gate`; görsel (Sunucu bloğu üç yük, büyüme satırı, anahtar açık, v1.0
öncesi kilit).

---

## C2 · Giderler

**Dokunulacak**
- `finance_system.gd`:
  - `STARTING_BURN_BREAKDOWN` (`:23-33`) ve `BURN_IDS` (`:38`): `tools` ve `service` çıkar. Kalan `salaries, overtime,
    marketing, office, servers`; gün 1 gideri 0.
  - `daily_tick` (`:135-137`): `tools` satırı çıkar.
  - `from_dict` (`:104-115`) sonunda `GameState.set_daily_burn(compute_total_burn())` (Özel doğrulama 2).
  - Yorumlar `:10-12`, `:16-22`, `:26-32`, `:91-93`, `:129-132` güncellenir.
- `infra_system.gd`:
  - `SERVICE_*` ve `ONBOARDING_MRR_MULT` (`:82-93`), `monthly_service` (`:266-276`) silinir.
  - `daily_tick` (`:347-349`): servis satırı çıkar.
  - `gross_margin_monthly` (`:279-281`): okuyucusu yok (C0_HARITA §5), silinir. PRD "yalnız sunucuyu düşer" der ama okuyan
    yok (CLAUDE.md §8).
- `hr_search_system.gd:252-256` `preview_hire`: `tools_after` terimi çıkar.
- `hr_actions.gd:247-248`: `HR_ROW_TOOLS` satırı çıkar.
- `finance_ozet_view.gd:383-400` `_refresh_burn`: boş liste için W1 `fin.empty`. Ofis ipucu W1 `fin.office_tip`; kira C9'da
  gelir, ipucu C9'la birlikte görünür.
- `first_week_doc.gd:225-229`: gün 1 gideri 0 ve `runway_months_for` INF döner (`game_state.gd:485-488` (C0q)); hücre
  `roundi(INF)` ile biçimlenir. E1 sorusu 8.
- `run_probe.gd`:
  - `MONTH_BURN` ve `GATE`: alanlar `BURN_IDS`'ten kendiliğinden düşer (`:516-517`); başlık yorumu `:103-106` (C0q).
  - Evre 1 runway'i sonsuz yazılır (PRD Risk 2).

**Silinecek:** yukarıdaki sabitler ve işlevler; `TOOLS_BASE_MONTHLY`, `TOOLS_PER_EMPLOYEE_MONTHLY`, `monthly_tools_for`
(`:13-14`, `:219-222`).

**Smoke**
- Yeni (§4.4 m.5): `burn_lines_visible`.
- Yeniden yaz: `burn_day1_breakdown` (2766).
- Sil: `burn_tools_and_service` (2831).
- Sayı için gözden geçir: `marketing_push_burns_and_ends` (2933), `runway_net_status` (3011), `gross_runway_months` (3032),
  `hire_preview_counts_inherited_overtime` (6986), `hr_search_cycle` (6909), `summary_frequency_ticks` (1456, `:1504` (C0q)),
  `save_v13_day_stamps_migrate` (2144), `loc_b4_derived_keys` (11607).

**CSV**
- Sil: `FIN_BURN_TOOLS` (`:3026`), `FIN_BURN_SERVICE` (`:3027`), `HR_ROW_TOOLS` (`:3037` (C0q)); üçünün de tek okuyucusu bu
  adımda gider (C0v taraması).
- Değiştir: `ONB_DOC_BURN` (`:101` "Geçim ve araçlar").
- Yeni: W1 `fin.empty`, `fin.office_tip`. W1'in beş `fin.row_*` metni mevcut anahtarlardır (`FIN_BURN_SALARIES` …
  `FIN_BURN_SERVERS`, csv `:1441-1445` (C0q); W1 notu "Yeni metin yok"), dokunulmaz.

**PROBE:** `MONTH_BURN`/`GATE`'ten `tools=`, `service=` düşer (PLAN_C C2).

**Görsel:** `--finance-shot=gider` (dolu, var) ve yeni `gider_empty`.

**Belge payı**
- HARITA `:230`, `:235-237` (C0q).
- GUNCELLEMELER `:284-286`, `:372-374`, `:383-385`, `:400-402`, `:410-412` (C0q).
- Glossary `:48-50` ("Geçim ve araçlar", "Servis maliyeti", "Brüt marj").

**Q'dan beklenen:** yok (dosyaların hiçbiri Q'nun değil).

**D'ye devredilen:** yok.

**Risk:** Başlangıç gideri 50 varsayan vakalar dağınık (C0_HARITA §5). Yükleme sonrası `daily_burn` tazelenmezse ilk tike
kadar eski gider görünür.

**Kapılar:** §4.4 m.5 (`burn_lines_visible`); `loc_residue`; `run_gate`; görsel (Finans boş ve dolu).

---

## C3a · Memnuniyet defteri, güncelleme yaşı, şema 19 ve tek göç

**Dokunulacak**
- **Yeni `B2BSatisfaction`** (PRD §9-R adları; D okur): `terms(c)`, `total(c)`, `preview(c, delta)`.
- **`customer_registry.gd`**:
  - Yeni `add_ledger_entry`.
  - `set_trust_offset` (`:219-226`) silinir.
  - `set_satisfaction` (`:158-176`) kalır; toplam her tik buradan yazılır.
- **`customer.gd`** (Q dosyası):
  - `trust_offset` silinir.
  - Yeni `ledger: Array` (varsayılan `[]`) ve `last_touch_day: int`. Varsayılan önerisi `-1`; okuyucu `-1`'de imza gününü
    okur.
  - `health` ve `update_health_from_satisfaction` okuyucusuzdur (A20); silinir.
- **`b2b_sales_system.gd`**:
  - Silinir: `_tick_satisfaction`, `_drift`, `_account_owner` (yalnız `_drift` için ise), `_target_on`, `satisfaction_target`,
    `_forgiven_trust`, `satisfaction_next_tick`, `satisfaction_after_break`, `onboarding_floor_until`,
    `onboarding_ends_under_bar`.
  - Değişir: `_tick_customer` (toplamı yazar, Risk dalı kalır), `_recover` (anlık bump kalkar), `accept_promise`,
    `apply_discount` (+8 durum terimi), `on_promise_resolved` (+6 / −3 / −12 satırları; tolerans, marka, bayrak kalır),
    `charge_trust_drains` (deftere satır; E1 sorusu 15).
- **`b2b_constants.gd`**:
  - Silinir: `SAT_DRIFT_STEP`, `ONBOARDING_AMP`, `ONBOARDING_GRACE_*`, `B2B_BUG_SAT_*`, `PROMISE_*_SAT`, `SIGNING_SAT_MIN`
    (C3b ile), `TRUST_OFFSET_DECAY_PER_DAY`, `clamp_trust` (son okuyucusu gidince).
  - Yeni defter sabitleri (K5).
  - `cs_dampen` sönme süresine döner.
- **`support_system.gd`**:
  - Silinir: `DAMAGE_*` (`:60-69`), `_damage_residue` (`:95-99`), `reset/to_dict/from_dict` (`:138-147`),
    `daily_satisfaction_damage`, `apply_daily_satisfaction_damage` (`:240-272`), `daily_tick`'teki çağrı (`:132`).
  - `ProductSystem.to_dict/from_dict` (`product_system.gd:22,26`) `support` bloğunu bırakır.
  - B2C kaydı E1 sorusu 13.
- **`effects.gd`**:
  - `satisfaction_delta` (`:420-426`) 8 haftalık satır yazar.
  - `trust_delta` (`:429-439`) deftere yazar; `per_sprint` yolu korunur.
  - `trust_plan` (`:683-690`) ve `break_plan` (`:734-739`) `B2BSatisfaction.preview` okur.
- **`chips.gd`**: `:88`, `:90`, `_trust_parts`/`_trust_part`/`_break_parts` (`:291-330`, `:360-363`) aynı sayıyı okur.
- **`incident_system.gd`**: `resolve` `:493` deftere 13 haftalık satır; `:496` `add_trust_drain` kalır; `_trust_row` `:580`
  `preview` okur.
- **Diğer okuyucular**:
  - `customer_rep_system.gd:335` `trust_offset < -4.0` → defter okuması.
  - `inbox.gd:218` (C0q) `risk_reason`: en büyük olumsuz satır (PRD Karar 5).
  - `hr_constants.gd:420` yorumu.
- **Güncelleme yaşı** (PLAN_C farkı 3):
  - Sürüm kapanışında, yayına giren kartın alanı hesabın `emphasis(sector)` alanlarındansa `last_touch_day` yazılır.
  - Bağlantı yeri (C0q): `SprintSystem._go_public` (`sprint_system.gd:1519-1532`) çağrılmadan önce `_close` sürüm kaydını yazar; kayıtta `release.shipped` kartları `area` taşır (`sprint_bridges.gd:103-106` okur). Q yeni alan eklemedi, `last_touch_day` yazıcısı C3a'nın.
  - Terim 26 haftaya kadar 0, sonra her 4 haftada −1, en çok −12 (K7).
- **Kayıt**: `save_manager.gd:16` → 19; yeni `if version < 19:` kolu `:194-203` zincirinin sonuna ((C0q) zincir `if version < 18: _migrate_17(state)` ile `:204-205`'te bitiyor; yeni kol `:206`'dan, işlev `_migrate_18`); `:22` (C0q) yorumu.
  Göç içeriği Özel doğrulama 3'te.
- **Araç ve fikstür**:
  - `run_probe.gd`: `_on_churn` `:587-588`, `_log_customers` `:707-724` (C0q) (`target`/`trust` terim dökümüne), ~~`_bug_penalty`
    `:1788-1789`, `_seed_stability_fixture` `:1823`, `_seed_b2b_world` `:1868` (tohum `sat` kalkar)~~ (C0q) Q üçünü yeniden yazdı: `B2B_PRODUCTS` `:1982`, `_check_b2b_fixture` `:1995-2019` (`B2BSalesSystem._target_on` ve `onboarding_floor_until` okur: C3a yeniden yazar), `_seed_b2b_world(preset)` `:2022-2082` (`sat` tohumları `specs`'te, `add_b2b_customer` çağrısı `:2062`, `settled` presetlerde `ONBOARDING_GRACE_WEEKS` `:2065`).
  - `sprint_probe.gd:240`; `main.gd:706`, `:714`, `:725`, `:1447-1454`, `:4141-4156` (C0q).
- **Seam açıklamaları**: `seams_sales.gd:6-9`, `:33-34` ("never name it") PRD'nin ipucuyla çelişir (A15); açıklama güncellenir.

**Smoke**
- Yeni (§4.4 m.1, m.3, m.7'nin yaş yarısı): `sat_total_is_sum`, `sat_no_silent_drop`, `ledger_fade`, `chip_matches_ledger`,
  `update_age_emphasis_only`.
- Yeni göç vakaları (§4.5): `save_v18_*` (Q 18'i aldıysa) ya da `save_v17_*`. `trust_offset` → satır, `last_touch_day`,
  `market_ref` korunur, yükleme sonrası nedensiz düşüş 0.
- Sil: `b2b_onboarding_grace_floor` (3120).
- Yeniden yaz:
  - Söz ailesi: `b2b_promise_kept_on_ship` (3684), `b2b_promise_broken_on_deadline` (3710), `promise_kept_stops_countdown`
    (4703), `promise_broken_penalty` (8578), `promise_break_chain` (20166), `promise_extend_once` (20123).
  - `incident_scale` (15820), `bug_cost_b2b_account_lines` (22977), `event_trust_delta_lasting` (15508) ve yardımcısı
    `_trust_standing_cost` (15543).
  - `incident_defer_ends_with_line` (16420), `paper_colors_two_arrivals` (21340), `paper_trust_until_ships` (21386).
  - `cs_dampen` ailesi: `owned_account_erodes_slower` (5407) ve `_erosion_over_a_day` (5440), `coupling_cs_dampen_axis`
    (7947).
  - `cs_request_kind_state_driven` (8970, `trust_offset` dalı).
- Yardımcılar: `_past_onboarding` (594) silinir ya da anlamı değişir; `_sign_fixture` (581) memnuniyet tohumu ilk tikte
  ezilir.
- Hedefli koşu (memnuniyeti tohumlayıp tik ilerleten vaka sayısı geniş, C0_HARITA §7 C0v satırı): `b2b_*`, `promise_*`,
  `cs_*`, `incident_*`, `paper_*`, `event_*`, `sales_*`, `release_thanks_*`, `risk_*`, `discount_*`, `recover_*`.

**CSV**
- Sil: `SALES_ONBOARDING_ENDS` (`:148`) ve `SALES_CHIP_ONBOARDING` (`:139`), ikisinin tek okuyucusu `sales_tab.gd` (`:25` `PHASE_TAGS`, `:547` (C0q)).
  PRD Karar 14 bunları C8'e verir; C3a `onboarding_ends_under_bar`'ı silerse `:546-547` (C0q) aynı commit'te gider.
- Değiştir: `SALES_REASON_*` (`:144-146`), `EFFECT_SATISFACTION` (`:1659`), `EFFECT_TRUST_*` (`:3353-3375` (C0q)).
- Yeni: W1 `sat.*` (C3a'nın 15 metni; `sat.term_clause`, `sat.term_discount/raise/reluctant` kendi adımlarında).

**PROBE:** `PROBE CUST` terim dökümü, `PROBE CHURN`'ün `trust=` alanı terimlere döner (PLAN_C farkı 9).

**Görsel:** memnuniyet ipucu bugünkü hesap kartında (`sales_tab.gd:601-630` (C0q) `_satisfaction_row`) ve yeni `--sales-shot=sat_tip`.
Tablo hücresine C8 taşır.

**Belge payı**
- CLAUDE.md §6: şema 19, WRITE-THROUGH LAW seam listesi (`set_trust_offset` → `add_ledger_entry`).
- HARITA `:39`, `:206-209`, `:217` (C0q).
- GUNCELLEMELER `:266-270`, `:316-318` (A'nın Karar 9'undan sapma), `:847-852` (C0q).
- `_vocabulary.md`, `tools/lint_v3_frozen.json` (yeniden yazılan kart çıkar).

**Q'dan beklenen** (RAPOR_Q §4)
- `account_fit(c).value`, `uses_area(sector, area)`, `weights(market, sector)`, `emphasis(sector)`.
- `Customer.market_ref` ve şema 18'in göç işlevinin adı.
- `risk_voice`'un Q sonrası şikâyet kapısı.
- `b2b_sales_system`'de Q'nun kaldırdığı ara bağ (Q PRD "C'ye devredilenler").
(C0q) Cevaplar: `account_fit` `product_quality.gd:246`, `used_areas` `:85`, `uses_area` `:91`, `weights` `:66`, `emphasis` `:79`; `Customer.market_ref` `customer.gd:74-80`, göç `_migrate_17` `save_manager.gd:969` (kol `:204-205`); `risk_voice` kapısı değişmedi: `account_bugs(c) > COMPLAINT_BUG_GATE or InfraSystem.is_over_capacity()` (`b2b_sales_system.gd:562`); ara bağ Q'da KALDIRILMADI, tersine kuruldu: `_target_on` `account_fit(c).value`'yu okur (`:155-156`), imza tohumu `signing_satisfaction_seed(prospect)` = `prospect_fit(prospect).value`; ikisi de C3a/C3b'de silinir ya da toplamın ürün terimine döner.

**D'ye devredilen:** `B2BSatisfaction.terms/total/preview`, `CustomerRegistry.add_ledger_entry`, şema 19; D'nin hata terimi
notu (D PRD satır 48, 581).

**Risk:** en büyük dilim; kayıt göçü ve fikstür köprüsü.

**Kapılar**
- §4.4 m.1, m.3, `update_age_emphasis_only`; göç vakaları; `--event-lint`.
- `bash tools/plausibility_run.sh` (`fails=0`); `run_gate`.
- A'nın churn kapıları B2B'de yeniden: `full_run_fix_{none,worst,due,off}`, tohum 7 ve 11, 104 hafta. Kural:
  `fix_worst` ≤ `fix_off` + 10 puan ve `fix_none` ≥ 2 × `fix_off` (RAPOR_A §4; PLAN_C C3a).

---

## C3b · İmza değeri ve kapısı

**Dokunulacak** (hepsi Q dosyası; (C0q) satırlar 910ad1f)
- `SalesSystem.add_b2b_customer` ((C0q) `sales_system.gd:344`; `satisfaction` parametresi `:345`, taban `:371-372`, imzada `set_market_ref` `:386`): `satisfaction` parametresi ve `max(tolerans + 10, 50)` tabanı kalkar. Değer
  `B2BSatisfaction.total` ile açılır (defter boş, yaş 0).
- `SalesSystem.signing_satisfaction_seed` silinir; okuyucuları `sales_finalizer.gd:92` ve `sales_rep_system.gd:268` (C0q).
- `SalesRepSystem._close`: önce C'nin kapısı, sonra Q'nun zarı (`close_chance(p)`); kapı reddi zarsız kayıptır. (C0q) `_close` `sales_rep_system.gd:258`; zar `var lost: String = lost_area(lead)` `:259`, kayıp `_lose(rep, lead, lost)` `:245`; kapı `:259`'un önüne girer, kayıp aynı `_lose` yolundan (`SalesFinalizer.lose` + haftada tek mail) gider; mailin `area` alanı bugün yalnız eksik alan kimliği taşır, açık hata varyantı için neden alanı gerekir (`inbox.gd:335-346` `lost_body`/`lost_line`).
- `SalesMeetingSystem`: kurucu yolunda kapı görüşme sonucunda okunur. `loss_area` boşsa neden hesabın kullandığı alanlardan en
  çok açık hatalı olanıdır (PRD Karar 6).
- `SalesLedger.report_loss`, `record_sales_event` türleri; `sales_tab.gd:323-376` aday kartında U sözcüğü, sektör cümlesi,
  en zayıf yer.
- Debug çağıranlar: `main.gd:690`, `:3025`, `:3032`, `:3437`, `:3717` ve (C0q) yeni `main.gd:533` (`_seed_accounts_state`, `--tick-probe=…:accounts=<n>`; `add_b2b_customer(lead, 1, 10, 85).tolerance = 0`); `run_probe.gd:2062` (C0q).
- Smoke köprüsü `endgame_smoke.gd:599-608` `_sign_fixture` ve doğrudan çağıranlar: `:20938`, `:21653`, `:21807`, `:18854` (C0q),
  `:18811` (C0q); (C0q) ayrıca `:15458`, `:18818`, `:18841`, `:18873`.

**Silinecek:** `SIGNING_SAT_MIN`. `SIGNING_SAT_OVER_TOL` kapının payı olarak kalır (C0_HARITA §7).

**Smoke**
- Yeni (§4.4 m.2): `sign_gate_reason`, `sign_single_loss`.
- Yeniden yaz: ~~`b2b_v1_lands_mid_band` (11786)~~ (C0q) Q K4b'de sildi, yazılacak yok; `b2b_account_reads_fit` (`:3215`, tohum ve taban iddiaları); `bugs_leave_sales_and_vc_alone` (`:24641`, Q'da yeniden yazıldı, E1 sorusu 16); `sales_*` ailesi Q'yla ((C0q) Q'nun yeni vakaları: `sales_rep_close_chance`, `sales_rep_close_die` `:8766`, `sales_rep_loss_mail`, `sales_weak_area_loss`, `sales_meeting_reads_fit`).

**CSV:** Yeni: W1'in C3b'ye verdiği 7 metin: `sign.mail_line`, `sign.mail_line_clean`, `loss.bugs_rep`, `loss.bugs_meeting`,
`loss.bugs_summary_row`, `sat.renewal_reading`, `sat.term_market_moved`. Son ikisi `market_ref` satırıdır (PLAN_C farkı 3:
C3b satırı yazar, C5 tetikleyiciyi taşır). ~~Aday kartı sözcükleri Q'nun anahtarıdır.~~ (C0q) Q aday kartına anahtar yazmadı: yeni soru 31. Silinecek yok.

**PROBE:** `PROBE SIGN` yanında kapı kaybı ve zar kaybı ayrı alanlar; Q'nun `PROBE FIT`'iyle aynı satırda değil (PLAN_C C3b).

**Görsel:** `--sales-shot=<yeni tür>` aday kartı (U sözcüğü), görüşmenin kapı kaybı `--meeting-shot=lost`.

**Belge payı:** HARITA `:206`; GUNCELLEMELER `:316-318` ("Satış ve yatırımcı hatayı okumaz"), `:847-852` (C0q); (C0q) Q'nun `GUNCELLEMELER.md:316-318`'e bir sonraki girişi (B2B hata terimi) zaten yazdı, çelişki notu C3b'nin.

**Q'dan beklenen** (RAPOR_Q §4)
- `prospect_fit(p)`'nin alanları (`value`, `loss_area`, `capped`, `label_key`, `note`).
- `close_chance(p)` ve `_close`'taki çağrı yeri; `LOSS_WEAK_AREA`; kayıp mailinin anahtarı; aday kartı sözcüğünün anahtarı.
(C0q) Cevaplar: `prospect_fit(p)` = {value, match, capped, weakest_emphasis, loss_area, note [{area, word}], label_key} (`product_quality.gd:216`, `fit` `:261`); `close_chance(p)` `:233`, `_close`'ta `lost_area(lead)` `:259`; `SalesConstants.LOSS_WEAK_AREA`; anahtarlar `SALES_REP_LOST_TITLE`, `SALES_REP_LOST_BODY`, `SALES_WEEKLY_LOST`, `SALES_LOSS_WEAK_AREA`, `SALES_MEMORY_WEAK_AREA`; aday kartı sözcüğünün anahtarı YOK: Q yalnız `label_key` (`SALES_MOD_PRODUCT_FIT`) ve `note`'u verir, sözcükler `PRODUCT_LEVEL_{NONE,WEAK,ENOUGH,STRONG}` (`strings.csv:2786-2789`); `sales_tab.gd:323-376` aday kartı Q'da değişmedi, çizim C3b'nin.

**D'ye devredilen:** yok.

**Risk:** Q'nun sözleşmesine dayanır. Fikstür köprüsü tek yerde değişir, imza değeri gerçek olunca imza sonrası sayı
varsayan vakalar kayar.

**Kapılar:** §4.4 m.2; `run_gate`; görsel `--sales-shot`.

---

## C4 · Kurumsal sunucu maddesi

**Dokunulacak**
- İmzada madde yazımı: `SalesSystem.add_b2b_customer`, Q dosyası; 3★ ve sağlayıcı Kurumsal değil.
- Yeni `Customer` alanları: maddenin bitiş günü, fesih bildirimi günü. Varsayılan "madde yok"; göç yazmaz (PLAN_C "Kayıt").
- Ay başı işleyişi `EventBus.month_ended` (A18; ay kapanışı günlük dağıtımın 0. yuvası, `time_manager.gd:388`). Hangi tik
  E1 sorusu 17.
- −10 durum terimi `B2BSatisfaction.terms`'te.
- Mailler `MessageSystem.post` ile (teslim `MailClock`).
- Sunucu bloğunda "Kurumsal sunucu bekleyen N hesap" (C1'in bloğu).
- `InfraSystem.set_provider` inişte süreyi yeniden başlatır.
- `meets_enterprise_trust` (`infra_system.gd:318-319`) kartlar için kalır; madde ayrı okumadır. Güvenlik sertifikası maddeyi
  karşılamaz (PRD Karar 4).

**Silinecek:** yok.

**Smoke:** yeni `enterprise_clause_timeline` (§4.4 m.6).

**CSV:** yeni W1 `clause.*` (18 metin) ve `sat.term_clause`.

**PROBE:** yok (PLAN_C dağılımında yok).

**Görsel:** `--inbox-shot=<yeni durum>` madde maili; Sunucu bloğu satırı (C1 fikstürüne 3★ hesap).

**Belge payı:** HARITA Satış.

**Q'dan beklenen:** `add_b2b_customer`'ın Q sonrası adı ve imzası; balina koşulu E1 sorusu 18. (C0q) Cevap: `add_b2b_customer(prospect, seats, seat_price, satisfaction, source := "founder_pitch", discount := 0.0)` `sales_system.gd:344`, imza aynı; balina koşulu `sales_faucet_system.gd:269-275` ve öbür sağlayıcı okuyucuları değişmedi.

**D'ye devredilen:** yok.

**Risk:** takvim (tik hafta, etiket takvim tarihi).

**Kapılar:** §4.4 m.6 (`enterprise_clause_timeline`); `run_gate`.

---

## C5 · Yenileme

**Dokunulacak**
- **Sözleşme kaydı ve tarih.** Bitiş `acquired_on_day`'den türer (alan yok). Yenileme durumu yeni `Customer` alanlarıdır:
  dönem açık, sonuç, kâğıt, gönülsüz yenileme. Varsayılanları göçsüz.
- `SprintBridges.next_renewal_day` tarih kaynağı kalır ya da yeni kayda döner. Okuyucuları: `tick_requests`,
  `SprintSystem.decision_renewal_saved` (`sprint_system.gd:482-489`), `urun.decision_renewal_saved` seam'i
  (`seams_product.gd:290-292` (C0q)), `sprint_pm_renewal.json`. 8 ve 12 haftalık iki pencere E1 sorusu 10.
- **Tek zar.** Hesap başına, bütçe kesintisiyle aynı RNG akışı (`RngStreams`, kayıt bloğu `rng`). Oranlar E1'den (K8).
- **Sonuç yazımı.** Koltuk ve MRR `CustomerRegistry.set_seats` (`:143-155`) ve `set_mrr` (`:131-141`); `SalesSystem.reflect_mrr`.
- **Kayıp.** Başka ürüne geçiş ve memnun olmayanın bütçe kesintisi sözleşme sonunda `B2BSalesSystem._remove_lost` yolundan
  geçer (`customer_churned`, `run_customers_lost`; A19, E1 sorusu 12).
- **Kâğıt ve mail.**
  - Satışçı raporu, kurucu kâğıdı ve karşı teklif kartları `data/events/cards/customer/` altında yeni JSON'lar; metin W1
    `renew.*`.
  - Cevaplar ve sonuç mailleri `MessageSystem.post`.
  - Bütçe maili W1 `budget_mail.*`.
- **Sektör eğilimi.** C'nin verisinde sektör kimliğiyle (PRD Karar 8); 13 sektörün kimliği Q'nun tablosundan.
- **Kesinti tablosu.** `record_interrupt` ve `_paper_blocked` (Özel doğrulama 4).
- **`market_ref` tetikleyicisi.** Q'nun seam'i, bugün ~~`next_renewal_day` açılışında~~ (C0q) `SprintBridges.tick_requests`'in içinde, `GameState.day == next_renewal_day(c) - before_renewal_weeks` (12 hafta) gününde (`sprint_bridges.gd:35-36`) ve imzada (`sales_system.gd:386`); yeni kaydın
  açılışına (8 hafta) taşınır. Değer değişirse defterde adlı satır. Taşıma üç şeyi birlikte değiştirir: smoke `fit_account_ref` (`:15497`, bir gün önce dokunmaz / o gün yeniler iddiası), `PROBE UFLUX` (`run_probe.gd:750`, `renewal=` sayımı) ve C6'nın `scale >= 3` süzgeci `:35-36`'yı kapsamamalı (tüm hesaplar).
- **Bot.** `run_probe.gd:879-931` (C0q) `_pick_choice` yeni kâğıtları fiil tercihiyle cevaplar (`RETAIN_PREFERENCE`/
  `DISCOUNT_PREFERENCE` `:875-876` (C0q)).

**Silinecek**
- `customer/request_renewal.json`.
- `CS_KIND_RENEWAL`, `CS_REQUEST_KINDS`'teki üyesi, `RENEWAL_MIN_TENURE_WEEKS` (`b2b_constants.gd:248-254`).
- `pick_request_kind`'in yenileme puanı (`customer_rep_system.gd:339-345`, `:365`, `:370-372`).
- `plausibility.gd:57` `RENEWAL_MIN_TENURE_WEEKS` ve `:364-367` kural.
- `seams_ported.gd:60` açıklamasındaki `renewal`.

**Smoke**
- Yeni (§4.4 m.6): `renewal_paper_once_a_month`, `renewal_outcome_named`.
- Yeniden yaz:
  - `next_renewal_day_one_place` (21254).
  - `cs_renewal_floor` (22789): yenileme yarısı silinir, onboarding sesi kalır.
  - `cs_request_kind_state_driven` (8970): iki tür.
  - `discount_row_locked_past_cap` (12480): `:13223` (C0q) `request_renewal`'ı render eder.
- Koru: `paper_renewal_card_first` (21285); yeni tarih kaynağıyla koşar.

**CSV**
- Sil: `B2B_EV_RENEWAL_TITLE` (`:786`), `B2B_EV_RENEWAL_BODY` (`:767`), `B2B_CHOICE_SIT_DOWN` (`:772`),
  `B2B_CHOICE_RENEW_LOWER` (`:773`), `B2B_CHOICE_LET_IT_WAIT` (`:774`), `B2B_EV_REQ_RENEWAL_EXPIRED` (`:2358` (C0q)). Altısının
  tek okuyucusu `request_renewal.json` (C0v taraması).
- Kalır: `B2B_DISCOUNT_SPENT_DESC` (`:2025` (C0q)).
- Yeni: W1 `renew.*`, `budget_mail.*`, `sector.trend_*`, `sat.term_discount/raise/reluctant` (C5'in 77 metni).

**PROBE**
- Yenileme sonuçları (zam, aynı, indirim, koltuk artışı, azalış, geçiş, bütçe) ve kâğıtlı ay sayısı (PLAN_C C5).
- Saat durması ve satışçı masasının payı da buraya önerilir (A29, E1 sorusu 20).

**Görsel:** `--inbox-shot=<yeni durumlar>`: satışçı raporu (koltuk satırlarıyla), kurucu kâğıdı, sonuç maili.

**Belge payı**
- CLAUDE.md §6 "Gelir" ve "Karar kâğıdı" (kesinti sırası).
- HARITA Satış ve Ürün (`:151` `tick_requests`, `:160` `next_renewal_day` smoke öneki).
- `tools/lint_v3_frozen.json`.

**Q'dan beklenen**
- `market_ref_for(star, sector)` ve yazan seam'in adı.
- En zayıf vurgu alanının sözcüğü (`word` ya da `weakest_area`), "Zayıf ×2, Güçlü ×0,5" için.
- 13 sektör kimliği.
(C0q) Cevaplar: `ProductQuality.market_ref_for(star, sector, subtype := ProductState.subtype())` `product_quality.gd:206`; yazan `CustomerRegistry.set_market_ref(id, ref)` `customer_registry.gd:229`; en zayıf vurgu alanı `account_fit(c).weakest_emphasis` (alan kimliği) ve `note` (`{area, word}`); 13 sektör `ProductQuality.TABLE` anahtarları `:48-62` (health, finance, insurance, legal, logistics, construction, ecommerce, retail, technology, manufacturing, real_estate, textile, media; `textile` ve `media` satırları onay bekliyor).

**D'ye devredilen**
- Kesinti tablosunun adı, alanları ve sırası; gönder sorusunun ekleneceği yer (sprint kâğıdı ile istek kartı arasında,
  PRD Karar 8).

**Risk:** akış ve kâğıt motoru. Kesinti kaydı ezilmesi (A27). 330 hesapta ayda yaklaşık 27 yenileme (PRD Karar 8).

**Kapılar:** §4.4 m.6; `plausibility_run.sh`; `run_gate`.

---

## C6 · Genel Bakış'ın kalan blokları ve istekler

**Dokunulacak**
- **`product_model.gd` `overview` ve görünüm.**
  - Sürüm bloğu Q'nun `area_row`'unu okur.
  - Kararlılık bloğu: ▲ için `ProductState.open_bugs_delta()` (`product_state.gd:170-175` (C0q)) var. "Son 4 haftada N kesinti"
    için kayıt yok: `GameState.incident` yalnız `last_day` tutar (`incident_system.gd:29-30`, `:253`). C6 ya olay geçmişinden
    sayar ya da gün listesi ekler.
  - En kötü iki hat `ProductModel.bug_row` (`:185-187`); temsilci `SupportSystem.desk_roster()` (`support_system.gd:183-190`).
  - İstekler ve İş blokları.
- **Düzeltme kartına giden yol.** Hat kartını SPRINT'te bir kez vurgulayan tek işlev. Bugünkü `open_area` (`product_tab.gd:228`)
  alanı açar, kartı vurgulamaz (C0_HARITA §11). C7 ve D aynı işlevi okur.
- **3★ süzgeci.**
  - `SprintBridges.tick_requests` (Q dosyası): yalnız `scale >= 3`; 1★ ve 2★'ın açık istekleri cezasız düşer. Düşen istek
    `late` olmaz; `late` bugün süresi geçen isteğin durumudur.
  - `customer_rep_system.gd:318-372` `pick_request_kind`: `feature` yalnız 3★.
- **İstek kartı.** `customer/request_feature.json` iki şık: `promise_it` ve "Listeye al". `decline` (−4) ve süre dolumu (−5)
  kalkar. Kartın hangi yoldan isteneceği E1 sorusu 11 (A23, A31).
- **Kesinti tablosu.** İstek en alttadır (Özel doğrulama 4).
- **PM kâğıdı ve teşekkür.** PM kâğıdının istek konusu `SprintCatalog.paper_account("request")` (`sprint_catalog.gd:423-431` (C0q))
  ve `SprintSystem._speaker` (`:1249`); teşekkürün istek tetikleyicisi `SprintBridges.thank` 3★.

**Silinecek:** `request_feature.json`'un `decline` şıkkı ve `on_expire` cezası.

**Smoke**
- Yeni (§4.4 m.7): `requests_three_star_only`.
- Yeniden yaz:
  - 3★ fikstür: `sprint_request_on_time_met` (19544) ve `_seed_open_request` (19525), `sprint_late_for_requests` (20769)
    ve `_late_world` (20727), `paper_speaker_is_assignee` (20844) ve `_paper_pm_asked` (21553), `_request_cards_up` (4660).
  - `release_thanks_each_kind` (23330), `release_thanks_limits` (23378), `release_thanks_incident_scope` (23421) ve
    `_met_request` (23298).
  - `cs_request_kind_state_driven` (8970).

**CSV**
- Sil: `B2B_CHOICE_NOT_NOW_SAY` (`:778`), `B2B_EV_REQ_FEATURE_EXPIRED` (`:2357` (C0q)); tek okuyucuları `request_feature.json`.
- Değiştir: `B2B_EV_REQUEST_TITLE` (`:775`), `B2B_CHOICE_GIVE_DATE` (`:776`), `B2B_CHOICE_ON_THE_LIST` (`:777`).
- Yeni: W1 `ov.*` (C6), `req.*`.

**PROBE:** istek kesintisi sayısı, ilk 3★ isteğinin haftası (PLAN_C C6).

**Görsel:** `--product-shot=live:overview_b2b`, `overview_b2c`, `overview_no3` (PRD §4.6).

**Belge payı:** CLAUDE.md §6 "Karar kâğıdı" ve "Sürüm anı" (istek 3★); HARITA Ürün `:151`, `:155`.

**Q'dan beklenen:** `area_row(area)`; istek alanı = vurgu 1 (Q PRD satır 130); `tick_requests` ve `thank`'in Q sonrası adları.
(C0q) Cevaplar: `ProductQuality.area_row(area)` `product_quality.gd:194` = {area, word, tone (`pos`/`neutral`/`warn`), sentence, squares 0-10, faint_from 8}; hiçbir ekran okumuyor; beklentisi 0 olan alanda (B2B'de Gelir) `squares` 0 ama `word` "strong" der, çizim C6'nın. İstek alanı vurgu 1: `sprint_bridges.gd:41`. Adlar aynı: `tick_requests` `:22`, `thank` `:190`, `thanks_of` `:205`, `next_renewal_day` `:62`.

**D'ye devredilen:** istek listesi verisi (yalnız 3★), düzeltme kartına giden yol; sprint ekranının "Müşteriler" şeridi
(A25; E1 sorusu 19).

**Risk:** UI kanunu; iki istek yolu (A23).

**Kapılar:** §4.4 m.7; `plausibility_run.sh`; `run_gate`; görsel.

---

## C7 · Haftalık destek raporu

**Dokunulacak**
- Kalıp `SalesRepSystem._tick_weekly_summary` (`MessageSystem.post`; Q dosyası).
- Yeni mesaj türü üç yerde: `mail_pane.gd:146` kolu, `inbox.gd:18-19` etiket, `inbox.gd:296` (C0q).
- Gönderen E1 sorusu 14 (A24).
- "Yeni mi" için önceki raporun durumu bayrakta saklanır (`FLAG_TYPES`; kalıp `sales_weekly_anchor_day`/
  `sales_weekly_close_rows`, `game_state.gd:95-96` (C0q)).
- "Yetişemedim" haftanın gelen sayısını ister; bugün yok. `ProductState.REPORTS_INCOMING` birikimdir, gelen saatlik eklenir
  (`support_system.gd:113-117`). Haftalık sayaç eklenir.
- Düğme C6'nın "düzeltme kartına giden yol"unu çağırır.

**Silinecek:** yok.

**Smoke:** yeni `support_report_quiet_week` (§4.4 m.7).

**CSV:** yeni W1 `support.*` (12 metin).

**PROBE:** yok.

**Görsel:** `--inbox-shot=<yeni durum>`.

**Belge payı:** HARITA Ürün (Destek).

**Q'dan beklenen:** `_tick_weekly_summary`'nin Q sonrası adı. (C0q) Cevap: aynı ad, `sales_rep_system.gd:301`; Q mesaj türü `sales_loss`'u ekledi (kalıp örneği: `inbox.gd:18-19,311-316`, `mail_pane.gd:137,148-149`).

**D'ye devredilen:** düzeltme kartı yolu (C6 ile aynı).

**Risk:** küçük.

**Kapılar:** §4.4 m.7; `run_gate`.

---

## C8 · HESAPLAR tablosu

**Dokunulacak**
- `sales_tab.gd`:
  - ADAYLAR | HESAPLAR.
  - `_paint_portfolio` (`:512-526`) ve `_account_card` (`:530-552` (C0q)) tabloya döner; `PHASE_TAGS`/`ATTENTION_RANK` (`:22-25`).
  - "İlgilen" yalnız Ayrılabilir ve Yenilemeyebilir'de (`:635-660`); steward seçici (`:667-` (C0q)) korunur.
  - Sıra ve görünüm pencere ömrü boyunca hatırlanır, kayda yazılmaz.
- Durum etiketinin hesaplandığı tek işlev (en ağırı yazar): Yenilemeyecek, Fesih bildirimi, Ayrılabilir, Yenilemeyebilir,
  Sunucu maddesi.
- Memnuniyet hücresi "41 · Kesinti" (C3a'nın `terms`'i).
- `left_tabs.gd:116` rozeti değişmez (C0_HARITA §12).
- Gelen kutusu hatırlatıcısı (`inbox.gd:114-126` (C0q)) E1 sorusu 9.

**Silinecek:** `SALES_CHIP_HEALTHY` kolu ve onboarding satırı (C3a almadıysa).

**Smoke:** yok; arayüz görsel kabulle (CLAUDE.md §10).

**CSV**
- Sil: `SALES_CHIP_HEALTHY` (`:136`; tek okuyucu `sales_tab.gd:536` (C0q)), C3a'da gitmediyse `SALES_CHIP_ONBOARDING` ve
  `SALES_ONBOARDING_ENDS`.
- Silinmez: `SALES_CHIP_RISK`, `SALES_CHIP_EXPANSION`, `SALES_EXPANSION_FICTION`; `inbox.gd:122-124` (C0q) ve `kit_probe.gd:229`
  okur (C0v düzeltmesi).
- Yeni: W1 `accounts.*` (31 metin).

**PROBE:** yok.

**Görsel:** 330 satır. Dünya `--tick-probe … accounts=<n>`'in ERP dünyasıyla kurulur (CLAUDE.md §12); yeni
`--sales-shot=accounts_330`.

**Belge payı:** HARITA `:215` (C0q).

**Q'dan beklenen:** yok.

**D'ye devredilen:** yok.

**Risk:** 330 satırın kurulma maliyeti. Ölçüm `--tick-probe=<hız>:accounts=330`.

**Kapılar:** `run_gate`; görsel (330 satır, TR, EN, cb, 1,25).

---

## C9 · Maaş, masa tavanı, Plaza şartı, taşınma, bot

**Dokunulacak**
- `hr_constants.gd:591-598` bantlar ×1,5. Komisyon da büyür (`:717`, `:837-838`; A12).
- Masa tavanı (Özel doğrulama 5):
  - `hr_search_system.gd:61-63` `can_start` ya da `:96-123` `start_search` (arka kapı).
  - Atlas: `hr_atlas_modal.gd` `_build_search_step` (`:52-123`), `_on_start_pressed` (`:386-391`); kilit kalıbı
    `role_lock_reason_key` (`hr_constants.gd:377-388`).
- `office_constants.gd`:
  - `CATALOG`'a `rent` (ev yok, 4.000 / 8.000 / 18.000).
  - Plaza `team` şartı (`:45`) ve Loft (`:59`) sayımla birlikte (Özel doğrulama 6).
  - İş hanı `angel` (`:32`) E1'in cevabıyla; `office_hud.gd:98` nefesi ve `funding/frank_office_move.json` buna bağlı (A11).
- `office_system.gd:23-35` sayım; `:46-47` yorumu.
- Kira yazımı: `office` kalemi (`finance_system.gd:28`). Sıra önerisi: `OfficeSystem.daily_tick`'i `FinanceSystem.daily_tick`'ten
  önceye almak (`time_manager.gd:407-409`). Gerekçe: yorum yalnız olay yuvasından önce olmasını ister (`:408`); böylece varış
  tikinde kira o haftanın akışına girer (A10, PRD "taşındığın hafta başlar").
- Ofis kartı ve Atlas metinleri: `office_map_card.gd:63`, `:121-139`; `office_city.gd:169-170`.
- İşe alım önizlemesi `preview_hire` ilk işe alımda kira dahil runway.
- `run_probe.gd`:
  - `_hire_after_the_seed` (`:1410-1433` (C0q)): `+ 6000` tahmini gerçek maaş bandı ve kirayla değişir (harness değişikliği, CLAUDE.md
    §3); taşınma politikası (boş masa yoksa `can_move_to` tutan sonraki ofis).
  - `cash_spend` ve `cash_hoard` kolları ve spec anahtarı `cash`.
  - `PROBE DECISION` satırı (hafta, yüzey, hesap ya da kart).
- Debug: `main.gd:3029`, `:3148`, `:3156`, `:3175` arama çağrıları evdeyse tavana takılır; `:3165` (C0q) komisyon.

**Silinecek:** `office_system.gd:46-47` "No money moves" yorumu; `finance_system.gd:28` TODO yorumu.

**Smoke**
- Yeni (§4.4 m.5): `desk_cap_blocks_hire`.
- Yeniden yaz:
  - `office_move_gates_and_save` (18418).
  - Evde arama ya da işe alım yapan vakalar İş hanı kurulumuyla: `hr_search_cycle` (6909), `hr_search_cancel_dismiss` (7013),
    `hire_preview_counts_inherited_overtime` (6986), `hr_frank_guard` (7397), `look_registry_unique_and_saved` (9493).
  - Bant ve komisyon: `hr_candidate_invariants` (6614, `:6977`), `hr_constants_contract` (7545, `:7982`, `:8015-8016` (C0q)),
    `promotion_and_raise_gate` (10824, `:11657` (C0q)).
- Gözden geçir: `hr_leave_cycle` (7136), `hr_raise_and_leave` (7305).

**CSV**
- Değiştir: `OFFICE_CARD_DESKS` (`:2733`), `OFFICE_HOVER_LINE` (`:2745`), `OFFICE_REQ_TEAM` (`:2720` (C0q); bugün "Ekip en az {n}
  kişi"), `OFFICE_MAP_SUB` (`:2730` (C0q)).
- Yeni: W1 `atlas.*`, `office.*` (10 metin).

**PROBE**
- `PROBE DECISION`.
- İlk işe alım ve taşınma haftaları ile o haftanın runway'i; en derin açık, 52. hafta ve evre 3 net (PLAN_C C9).

**Görsel**
- Atlas evde ve dolu: `--hr-shot=<yeni tür>`.
- Ofis kartı: `--office-shot=city:<saat>:card_ishani`, `card_home` (var; CLAUDE.md §12).
- Finans ofis ipucu.

**Belge payı**
- HARITA `:126` (Ofis "kasa hareketi yok"), `:188` (`preview_hire` "maaş ve araç farkıyla").
- Glossary `:174-189` (C0q) (Kira, Boş masa).
- CLAUDE.md §12 probe (yeni kollar).

**Q'dan beklenen:** yok.

**D'ye devredilen:** `PROBE DECISION` komutu (PRD §4.3; D okur).

**Risk:** tavan botun taşınmasıyla aynı commit'te girer, yoksa koşu işe alamaz (PLAN_C C9). İş hanı'nın Frank şartı
kalırsa B2C botu ilk işe alımı 22. haftaya kadar yapamaz (PRD §10).

**Kapılar:** §4.4 m.5; `run_gate`; görsel.

---

## Özel doğrulamalar

**1. `InfraSystem` kayda girmiyor; anahtar ve son otomatik büyüme nerede saklanır.**
- **Kanıt.**
  - `save_manager.gd:375-384` `_capture_systems` ve `:387-402` (C0q) `_restore_systems` `InfraSystem`'i anmaz.
  - `reset_all_owners` (`:324-357`) de anmaz; `InfraSystem.reset()`'i yalnız smoke çağırır (`endgame_smoke.gd:14320` (C0q)).
  - Kapasite ve sağlayıcı bayraktır: `ProductState.INFRA_PROVIDER`/`INFRA_UNITS` (`product_state.gd:26-27` (C0q)),
    `FLAG_TYPES` (`game_state.gd:77-78`). Yazarı `ProductState.set_infra_*` (`:285-297` (C0q)) ve `infra_changed` yayar.
  - Bayraklar `initialize_run`'da temizlenir (`game_state.gd:896` (C0q)).
- **Öneri.**
  - Anahtar `mvp_infra_auto` (`TYPE_BOOL`), son büyüme `mvp_infra_auto_last` (`TYPE_DICTIONARY`: gün, önce, sonra),
    büyüme geçmişi `mvp_infra_served_weeks` (`TYPE_ARRAY`).
  - Üçü `FLAG_TYPES`'a girer; yazarı `ProductState` (aynı seam ailesi), kararı `InfraSystem` verir.
  - Eski kayıtta bayrak yoktur, `get_flag` varsayılanı kapalı okur; göç gerekmez (PLAN_C "Kayıt").
  - `GameState` değişkeni seçilirse `initialize_run`'da sıfırlanmalı (`save_codec.gd:201-219` (C0q)); bayrak yolu bunu
    `flags.clear()` ile zaten yapar.

**2. `burn_breakdown` yükleme ve `daily_burn`'ün bayatlığı.**
- **Kanıt.**
  - `FinanceSystem.from_dict` (`finance_system.gd:104-115`) kalemleri başlangıç şeklinin üstüne koyar; şekilde olmayan
    kalem düşer.
  - `apply_loaded_state` önce `GameState.initialize_run(restore)` ile kayıttaki `daily_burn`'ü yazar (`save_manager.gd:301` (C0q)),
    sonra `_restore_systems` (`:305`) `FinanceSystem.from_dict`'i çağırır (`:397` (C0q)).
  - `daily_burn` ilk kez `FinanceSystem.daily_tick`'te tazelenir (`:139-141`).
  - C2'den sonra eski kayıt `tools` kalemsiz ama `tools`'lu `daily_burn` ile açılır; TopBar ve runway ilk tike kadar eskiyi
    okur.
- **Öneri.** `from_dict`'in son satırı `GameState.set_daily_burn(compute_total_burn())`. Yükleme anında kabuk yoktur,
  `burn_changed`'in dinleyicisi yoktur, zararsızdır. Alternatif doğrudan atama `SaveCodec`'in tercihidir
  (`save_codec.gd:202-203` (C0q)); WRITE-THROUGH LAW `set_*`'ı ister (CLAUDE.md §6).

**3. 18 → 19 göçü ve `SaveCodec`'in yeni alan varsayılanı.**
- **Kanıt.**
  - Göç zinciri ham sözlükte koşar (`save_manager.gd:194-203`), `restore_registries`'ten önce (`:304` (C0q)).
  - `res_from_dict` bugünkü sınıfta olmayan anahtarı düşürür (`save_codec.gd:9-11`, `:78-81` (C0q)). `trust_offset` alanı
    silindikten sonra değer ancak göçte, ham sözlükten okunabilir.
  - Hesaplar `state.registries.customers`'tadır (`save_codec.gd:251-258` (C0q)).
- **Göçün içeriği** (PLAN_C "Kayıt", PRD §4.5):
  - Her B2B hesap için `trust_offset ≠ 0` ise defterde 4 haftalık tek satır (tutar yuvarlanmış iz, gün = göç günü =
    `state.game_state.day`).
  - `trust_offset` anahtarı silinir; `last_touch_day` = göç günü.
  - `market_ref` Q'nun 18 göçünden gelir, dokunulmaz.
  - `GameState.trust_drains` (`game_state.gd:318` (C0q)) olduğu gibi kalır: şekli `{accounts, amount, until}`
    (`b2b_sales_system.gd:198-199` (C0q)) ve C3a yalnız yazdığı yeri değiştirir (E1 sorusu 15).
  - `systems.product.support.damage_residue` göçe girmez; `ProductSystem.from_dict` onu okumayı bırakınca düşer.
- **Göç yazmaz:** sözleşme bitişi (imza gününden türer), açık Kurumsal madde, otomatik ayar, masa aşımı, 1★ ve 2★
  istekleri (C6'nın tik kuralı düşürür), `burn_breakdown` kalemleri.
- **Varsayılanlar.**
  - `ledger: Array = []`.
  - `last_touch_day: int = -1`; okuyucu `-1`'de `acquired_on_day`'i okur. Yeni imza bu yüzden göçsüz doğru başlar; eski kayıt
    göçle göç gününden başlar. Göç yazmasaydı eski hesap ilk tikte yaş terimi alırdı, bu nedensiz düşüş olurdu (M1).
  - JSON'dan dönen satır sayıları float'tır, okuyucu `int()` yapar (`save_codec.gd:14-17`).
- **Sürüm.** `SCHEMA_VERSION` 19; `version > SCHEMA_VERSION` yeni kaydı reddeder (`:187-188`). Q 18'i almadıysa 17 → 19
  atlanır ve raporda yazılır (PLAN_C). (C0q) Q 18'i aldı (`save_manager.gd:16`); C3a 18 → 19. Kayıttan dönen `market_ref` değerleri JSON sayısıdır (tam sayı float açılabilir): `account_fit` karşılaştırmaları sayısal olmalı (`R_DEFTER` K2).

**4. Kesinti tablosu ve haftalık bütçe.**
- **Kanıt.**
  - Bugünkü yuva `GameState.product.interrupt = {sprint, kind}` (`sprint_system.gd:564-566`), sprint başına tek kayıt, son
    yazan kalır.
  - Okuyucular `_paper_blocked` (`:1261-1265`), `paper_sprint` (`:1269-1270`), `_interrupted_by` (`:1274-1276`),
    `IncidentSystem.daily_tick` (`incident_system.gd:108`, `:120`).
  - Yazanlar `incident_system.gd:254`, `sprint_system.gd:991`, `:1237`.
  - CS kanalının ayrı tavanı `GameState.cs_escalation_days` (`customer_rep_system.gd:291-309`; `CS_ESCALATION_WEEKLY_CAP 2`,
    pencere 1 hafta, `b2b_constants.gd:234-235`).
- **Gereken.** "Haftada en çok 1" için kaydın günü (tik); "sprintte en çok 1 durma" için sprintteki türlerin hepsi. Tek
  `kind` ikincinin üstüne yazar (A27).
- **Öneri.**
  - `interrupt = {sprint, day, kinds: Array}`. `_interrupted_by` kesişime bakar; haftalık bütçe `day == GameState.day`.
  - Servisin çöktüğü acil durum her zaman gelir ve kaydı eklenir, silmez.
  - Okuyucu eski kaydın `kind` anahtarını `[kind]` diye okur; göç gerekmez (C5 göç yazamaz).
  - CS tavanı istek kartının yolu değişirse (E1 sorusu 11) kalkar ya da yalnız şikâyete kalır.
  - Sıra PRD Karar 8: acil durum > söz > yenileme kâğıdı > sprint kâğıdı > (D: gönder sorusu) > istek.

**5. Masa sayısı ve kurucunun masası.**
- **Kanıt.**
  - `OfficeConstants.CATALOG.desks` ev 1, İş hanı 10, Plaza 36, Loft 64 (`office_constants.gd:19`, `:28`, `:40`, `:54`);
    masa bugün yalnız gösterilir (`office_map_card.gd:63`).
  - Çalışan sayısı `get_employees()`: izindeki ve eğitimdeki dahil (`character_registry.gd:41-46`), ayrılan kayıttan silinir
    (`:553-559`).
  - 3B ofis kurucu masasından ayrı 10 / 37 / 69 çalışan oturtur (`art/office3d/*.json` `maxN`, `desk` noktaları
    1 / 11 / 38 / 70; `office_layout.gd:43`; `office_people.gd:613`).
- **Kural** (PRD Karar 3): boş masa = `desks − 1 − get_employees().size()`. Taşınma kararı verilince `desks` gidilen ofisin
  sayısıdır (`GameState.office_move_to`, `game_state.gd:299` (C0q)). Evde 1 − 1 − 0 = 0, arama açılmaz.
- **Taşınma süresi.** Aday taşınma bitmeden işe başlamaz: arama ve taşınma birer hafta (`hr_constants.gd:719`,
  `office_constants.gd:9`). Dosyalar HR yuvasında (`time_manager.gd:402`), taşınma ofis yuvasında (`:409`) aynı tikte iner;
  işe alım dağıtımdan sonradır. Kural bugünkü sürelerle kendiliğinden tutar, kod gerekmez. Süreler ayrışırsa `hire()`
  korunur (E1 sorusu 6).
- 3B ile katalog farkı E1 sorusu 5.

**6. Plaza şartının sayımı.**
- **Kanıt.**
  - `requirement_state` `team`'i `HRSystem.headcount()` = `count_employees()` ile okur (`office_system.gd:26`,
    `hr_system.gd:133-134`); kurucu sayılmaz.
  - Satırın sağı `şu an {value}` aynı sayıyı yazar (`office_map_card.gd:127`, csv `:2723` (C0q)).
  - `hr.headcount` seam'i kurucuyu saymaz (`seams_hr.gd:129-131`).
  - Loft şartı 35 çalışandır (`office_constants.gd:59`): Plaza'nın 36 masası kurucuyla dolu.
- **Öneri.**
  - `requirement_state`'in `team` okuması `headcount() + 1` (ofisteki kişi). Plaza değeri 10 (PRD), Loft 35 → 36: aynı kapı,
    yeni sayım.
  - `OFFICE_REQ_TEAM` W1 `office.req_team` ("En az {n} kişi (sen dahil)").
  - `hr.headcount` seam'i değişmez, kartlar etkilenmez.
  - Alternatif "değer 9, metin +1" `şu an` okumasını da +1 yazdırmayı gerektirir, iki yerde hesap olur.

---

## E1 soruları

Her soru kodun ortaya çıkardığı bir noktadır; kanıt C0_HARITA §18'in maddesi ve satırıdır. Öneri tek cümledir.

1. **Yük çarpanı yalnız kesintiyi mi artırır?** (A30)
   - `hazard()` haftanın bütün acil durum türleri için tek ihtimaldir (`incident_system.gd:75-78`); tür ondan sonra ağırlıkla
     seçilir (`:125-142`, `sprint.json:52` (C0q)).
   - PRD Karar 1 ve W1 `server.warn_*` "kesinti ihtimali" der.
   - Öneri: yük yalnız kesintinin payını büyütür. Haftalık ihtimal `p × (1 + s × (L − 1))`, `s` kesintinin izinli türler
     içindeki ağırlık payı; tür seçiminde kesintinin ağırlığı × L. Kesinti ihtimali L katına çıkar, öbür türler değişmez.

2. **Tavan (0,3) çarpanı yutuyor.** (A2)
   - Kırpma çarpandan sonra gelir (`incident_system.gd:77-78`): ×2,5 yalnız açık hata ≤ 1, ×1,5 yalnız ≤ 8 iken tam işler.
   - Öneri: tavan yalnız taban × hata kısmını kırpar, yük çarpanı (1. sorunun biçimiyle) kırpmadan sonra uygulanır.
   - Bedeli: Yerel'de 12 hata ve %104 yükte haftalık kesinti ihtimali 0,3 × 2,5 = 0,75 olur (B2B'de ay sonu dışında `s` = 1),
     Bulut'ta 0,375.
   - M7 kapısı C0s'te bu biçimle ölçülür.

3. **Sunucu bloğunun "Kapasite" sayısı satın alınan mı, etkin mi?** (A4)
   - `purchased_capacity` ile `effective_capacity` ağır kademede ayrılır (`infra_system.gd:168-175`).
   - PRD örneği (6.500 · %80 · boş 1.300) yalnız etkin okunursa tutar.
   - Kademe ipucu "50 koltuk başına" satın alınan birimdir.
   - Öneri: blok ve ipucu etkin kapasiteyi yazar; fiyat satırı "birim" der, koltuk saymaz (W1 `server.tier_tip_price_*`
     değişir).

4. **Ar-Ge `incident_playbook` düğümünün tek etkisi silinen aşım zararıdır.** (A7)
   - `rnd_tree.json:26`, `research_tree.gd:49-52`, `:308-310`; metin `:2221` (C0q) "taşan kapasite müşteride eskisi kadar iz
     bırakmıyor".
   - Öneri: düğümün etkisi yük %100 üstündeki kesinti çarpanını 2,5'ten 2,0'a indirir. Konusu aynı kalır, katsayı listesi
     değişmez; metin W1'e eklenir.
   - (C0q) Q `COEFFICIENT_EFFECTS`'te yalnız `experience_effort`'u `design_effort` yaptı (`research_tree.gd:52`); `overage_satisfaction` (`:51`), `rnd_tree.json:26` ve metin aynı: soru olduğu gibi duruyor.

5. **Masa sayısı katalogda ve 3B'de farklı.** (A3)
   - Katalog 10 / 36 / 64 (kurucu dahil), 3B 11 / 38 / 70 masa noktası.
   - Öneri: katalog esastır (Erdem'in sayıları). 3B'de fazla masalar boş kalır, kod değişmez.

6. **"Aday taşınma bitmeden işe başlamaz" (K3) kod istemiyor.**
   - Arama ve taşınma birer hafta, aynı tikte iner (Özel doğrulama 5).
   - Öneri: madde onaydan düşer. Süreler ayrışırsa `hire()` koruması aynı commit'te gelir.

7. **Plaza ve Loft şartı nasıl sayılır?**
   - Sayım bugün kurucusuz (`office_system.gd:26`); Loft 35 çalışan = Plaza dolu (`office_constants.gd:59`).
   - Öneri: şart ofisteki kişiyi sayar (kurucu dahil). Plaza 10, Loft 36 (aynı kapı).

8. **Onboarding belgesinde gider 0 ve runway sonsuz.** (A9)
   - `first_week_doc.gd:225-229` `roundi(INF)` biçimler; PRD ekranı anmaz.
   - Öneri: gider hücresi "$0", runway hücresi sayı yerine sözcük ("sınırsız"). W1'e iki metin eklenir;
     `ONB_DOC_BURN` "Aylık gider" olur.

9. **Gelen kutusundaki Risk ve genişleme hatırlatıcısı kalsın mı?** (A32)
   - `inbox.gd:114-126` (C0q) `SALES_CHIP_RISK`/`_EXPANSION` ve `SALES_EXPANSION_FICTION`'ı okur.
   - PRD Karar 13 bu etiketleri yalnız tablodan kaldırır.
   - Öneri: hatırlatıcı tablonun Durum'una bağlanır (Ayrılabilir ve Yenilemeyebilir hesaplar için not). Genişleme notu
     10. sorunun cevabıyla gider. Üç anahtar o commit'te silinir.
   - (C0q) `inbox.gd:114-126` Q'da değişmedi. `risk_reason` (`:215-218`) metni Q'da değişti (`SALES_REASON_STABILITY` = "ürün yeterince güvenilir değil (Güven & Ölçek)") ama hâlâ her koşulda Güven & Ölçek der; hesabın düşük uyumu başka alandan olabilir (RAPOR_Q §7.4): yeni soru 28.

10. **İki pencere ve iki koltuk yolu.** (A22, A26)
    - Yenileme dönemi bitişe 8 hafta kala açılır (Karar 8); istek penceresi 12 haftadır (`sprint.json:38` (C0q)
      `before_renewal_weeks`).
    - `customer.expansion` kâğıdı olgun hesaba tek sefer koltuk satar (`EXPANSION_SEATS` 3/6/12, `b2b_constants.gd:198`;
      `sales_tab.gd:648-650` (C0q)).
    - Öneri: 3★ istek penceresi 12 hafta kalır (isteğin yenilemeden önce yayına girebilmesi için), yenileme 8 hafta.
      Genişleme kâğıdı ve "Değerlendir" kalkar; koltuk artışı yalnız yenilemenin sonucudur (Karar 8 ve 13 tek yol).
    - (C0q) Q'nun `market_ref` yenilemesi de 12 haftalık pencerede (`sprint_bridges.gd:35-36`). Öneri uygulanırsa tetikleyici 8 haftalık yenileme kaydına taşınır; smoke `fit_account_ref` (`:15497`) ve `PROBE UFLUX` (`run_probe.gd:750`) birlikte değişir (A22).

11. **İstek kartı hangi yoldan gelir?** (A23, A31)
    - `customer.request_feature` yalnız CS kanalından ve yalnız Müşteri İlişkileri'nde biri varken gelir
      (`customer_rep_system.gd:193-194`, `:303-304`).
    - Sprint isteği temsilcisiz doğar (`sprint_system.gd:33`). Karar 11: "temsilci şartı kalkar".
    - Öneri: istek kartı sprint isteği doğduğunda istenir. CS kanalının `feature` türü kalkar, kanal şikâyete iner,
      haftalık tavanı 2 olarak kalır.

12. **Ürün dışı kayıplar VC'nin churn sayacına girer mi?** (A19)
    - `run_customers_lost`'u VC sorgusu ve term sheet okur (`vc_pitch_system.gd:522`, `:1136`;
      `term_sheet_table_system.gd:535` (C0q)).
    - `churn_customer` fiili `customer_churned` yaymaz (`effects.gd:270-283`).
    - Öneri: başka ürüne geçiş ve memnun olmayanın bütçe kesintisi `_remove_lost` yolundan geçer ve sayılır.
      `churn_customer` fiili de bu yola bağlanır.

13. **B2C kitle kaydı ve adsız destek zararı.** (A13)
    - Zarar B2C'de tek kitle kaydına yazar (`support_system.gd:259-264`).
    - İki `satisfaction_delta` kartı B2C'dir (`customer.b2c_refunds`, `product.b2c_floor_signal`).
    - Öneri: zarar B2C'de de kalkar (Erdem "gizli gider yok"un memnuniyet karşılığı); iki kartın tutarı B2C kaydında anlık
      kalır (B2C defteri yok, Q'nun B2C memnuniyeti hedefe yürür).
    - (C0q) Q B2C memnuniyetini `b2c_satisfaction_target()`'a bağladı ve ağızdan ağıza kapısını memnuniyete koydu (`WOM_SAT_GATE` 65, `sales_system.gd:83-85`). Q'nun K9 ölçümü adsız zararın açık olduğu dünyada koştu (`support_system.gd` değişmedi). Zararı B2C'den silmek B2C büyümesini kaydırır (RAPOR_Q §1 madde 3, ❌ 18/24): yeni soru 26.

14. **Destek raporunu kim gönderir?** (A24)
    - PRD "Destek işi" der (`SupportSystem.desk_roster`, `support_system.gd:183-190`).
    - PRD'nin atfı Müşteri İlişkileri alanının sırasıdır (`customer_rep_system.gd:41-58`).
    - Öneri: Destek işindeki en yüksek destek puanlı çalışan gönderir. Kurucu göndermez, tek kurucuda rapor yok (Karar 12
      "1 kişi: rapor yok").

15. **"Düzelene kadar her sprint −3" satırının süresi.** (A17)
    - `trust_drains` her sprint kapanışında yazar (`b2b_sales_system.gd:204-217` (C0q)).
    - Acil durumun ertelemesi PRD'nin "ertelenen hata"sıdır (8 hafta); iki PM kâğıdının (`sprint_pm_phone_too`,
      `sprint_pm_renewal`) `per_sprint`'i için süre yok.
    - Öneri: her sprint kapanışı 8 haftalık −3 satırı yazar, koşul kalkınca yenisi yazılmaz. Kayıt şekli ve göç değişmez.

16. **Satış artık hatayı okur.** (A21)
    - `bugs_leave_sales_and_vc_alone` (`endgame_smoke.gd:24641`) ve GUNCELLEMELER `:316-317` (C0q) "Satış ve yatırımcı hatayı
      okumaz" der; C3b'nin kapısı açık hatayla reddeder.
    - Öneri: vaka VC yarısıyla kalır. Satış yarısı `sign_gate_reason`'a geçer; GUNCELLEMELER satırı ikinci sapma olarak
      yazılır.
    - (C0q) Q vakayı yeniden yazdı (`:24641`): hatasız ve Trust'sız iki ERP'de 50 açık hatanın dönüşüm, `signing_satisfaction_seed(lead)`, görüşme katkıları, `_fit_line`, yıldız karışımı, `facts_for`, `_derive_loss_reason`, `repitch_blocked`, VC sorgusu ve term sheet uyumunu değiştirmediğini sınar. Kapı `_derive_loss_reason`'ı ya da tohumu hata ile değiştirirse vaka düşer: açık hata reddi `_close` ve `sign_deal` içinde ayrı okumada (`sign_gate_reason`) kalmalı.

17. **Kurumsal madde ayın hangi tikinde işler?** (A18)
    - Ay kapanışı günlük dağıtımın 0. yuvasında `month_ended` yayar (`time_manager.gd:388`).
    - Öneri: kural `month_ended` tikinde işler; etiket takvim tarihi yazar.

18. **Balina adayının "Altyapı güvencesi istiyor" koşulu.** (A8)
    - Koşul ve kayıp nedeni sağlayıcıya bakar (`sales_faucet_system.gd:269-275`, `SALES_WHALE_PROVIDER_OR_CERT` `:2434` (C0q)).
    - Karar 4 Standart'ta 3★'ı maddeyle imzalatır.
    - Öneri: koşul yalnız Yerel'de kalır. Standart'ta aday maddeyle imzalar; metin "Kurumsal sunucu şartı sözleşmeye
      yazılır" olur (Q dosyası; C0q yerini verir).

19. **Sprint ekranındaki "Müşteriler · N talep" şeridi.** (A25)
    - `area_panel.gd:190-210`, `product_model.gd:214-231`.
    - Öneri: C6 dokunmaz; D plan ekranındaki istek listesiyle değiştirir (PRD §7 "plan ekranının istek listesi D'nin").

20. **Atanmamış iki PROBE alanı.** (A29)
    - PRD §4.2 saat durmasını ve satışçı masasının payını ölçülenler arasında sayar.
    - Öneri: ikisi C5'e girer (kâğıtlar ve yenileme masası orada doğar).
    - (C0q) `PROBE SIGN by=founder|rep` ve Q'nun `desk` kolları satışçı masasının payını bugün ölçülebilir yapıyor; saat durması hâlâ atanmamış.

21. **"HAYIR DİYEMEZ" huyunun memnuniyet etkisi.** (A16)
    - Tek okuyucusu silinen `_drift` (`b2b_sales_system.gd:122`, `hr_constants.gd:452` +5).
    - Öneri: hesabın sahibi bu huyu taşırken +5 durum terimi, adı temsilcinin adı. Görünür, adlı, kaymasız.

22. **"Söz ver"in anlık +8'i.** (A14)
    - `accept_promise` `_recover(c, RETAIN_SAT_BUMP)` ile memnuniyeti hemen artırır.
    - Öneri: anlık artış silinir (Karar 5 "anlık sıçramalar silinir"); söz tutulunca +6 kalıcı satır yazar.

### (C0q) Q'dan sonra doğan sorular

Her soru Q'nun koduyla ya da RAPOR_Q ile ortaya çıkar; kanıt `C0q_TAZELEME.md` §7'dedir.

23. **İmza kapısı hangi U'yu okur?** (C3b)
    - `prospect_fit` aday bağlamıdır ve rakip penceresi dahildir (`product_quality.gd:359-360`); imzadan sonra hesap rakipsiz `market_ref` ile okunur (`account_fit` `:246`). Rakip çıkışı penceresinde ikisi farklı sayı verir (smoke `fit_account_ref`).
    - Q'nun kapı payı ölçümü (RAPOR_Q §7.4) `PROBE FIT u=`'dur, yani `prospect_fit.value` (`run_probe.gd:610-613`).
    - Öneri: kapı `prospect_fit`'i okur ve ret nedeni onun `loss_area`'sıdır; imza değeri `account_fit` ile yazılır.

24. **Ar-Ge gizli hat açılışında hesabın U'sunun düşüşü adsız.** (C3a/C6, A33)
    - Gizli hat alanın hat sayısını artırır, boş hat seviyeyi düşürür; hesabın `market_ref`'i donuktur (RAPOR_Q §4.2 kural 8, §7.4). `PROBE UFLUX` bu düşüşü `unexplained` sayar (sürüm ve yenileme dışı).
    - Öneri: Ar-Ge düğümünün tamamlanması açıklayıcı olay sayılır (ipucunda "Ürün uyumu" satırı `note` ile alanın yeni hâlini söyler); `PROBE UFLUX`'a `research=` bayrağı eklenir.

25. **C3a ile C3b arasında zayıf ürünle imzalanan hesap.** (sıra)
    - C3a kayma ve tabanı siler; `add_b2b_customer` tabanı (`sales_system.gd:371-372`) yalnız ilk tiki korur. Q ölçümü: zayıf ürünle imzalanan 2★/3★ hesap 4 hafta sonra Risk'e girer (`R_DEFTER` K4b, gün 27, sat 43 / tol 51).
    - Öneri: C3a'nın A kapıları `desk` kollarıyla da koşar; aralıktaki sapma C3b ile kapanır, commit sırası değişmez.

26. **B2C: adsız destek zararı silinince Q'nun C10 kalibrasyonu.** (C3a)
    - Q'nun B2C ölçümü zararlı dünyada koştu; `WOM_SAT_GATE` 65 memnuniyete bağlı.
    - Öneri: zarar B2C'de de kalkar; `full_run_b2c_fix_{none,worst,due,off}` tohum 7 ve 11, 26/52/104. hafta kitle sapması C3a'dan sonra ölçülür, bant dışı çıkarsa `WOM_*` Erdem'e döner.

27. **Zar tabanı %60 ve `CLOSE_CURVE`.** (C3b, K6)
    - Kapıyı geçen adayın U'su ≥ tol + 10 (1★ 43-48, 2★ 52-57, 3★ 61-66): eğri bu aralıkta 1★ için %36-46, 2★ için %54-63, 3★ için %70-78 verir.
    - Öneri: `max(close_chance, 0,60)` yalnız kapıyı geçen adayda uygulanır; `CLOSE_CURVE` Q'nun onay bekleyen sabiti olarak dokunulmaz.

28. **`Inbox.risk_reason` hangi alanı söyler?** (C3a/C8)
    - Bugün `trust_offset >= 0` iken hep Güven & Ölçek der (`inbox.gd:218`); Q yalnız metni değiştirdi.
    - Öneri: neden defterin en büyük olumsuz satırıdır; satır "Ürün uyumu" ise `account_fit(c).loss_area`'nın kısa adıyla yazılır; `SALES_REASON_STABILITY` silinir.

29. **`area_row` çizim kararları.** (C6)
    - Beklentisi 0 olan alanda `squares` 0 ama `word` "strong" der (RAPOR_Q §4.2 kural 7).
    - Öneri: Sürüm bloğu beklentisi 0 olan alanı gri "—" çizer ve kare göstermez.

30. **Görsel kabul aracı.** (C1, C6)
    - `--tab-shot=product` Q'dan önce de kırık (RAPOR_Q §9 soru 13).
    - Öneri: Genel Bakış kareleri `--product-shot=live:<tür>` ile alınır; yeni türler C0v'nin C1/C6 görsel listesindedir.

31. **Aday kartı U sözcüğünün kaynağı.** (C3b)
    - Q aday kartı için CSV anahtarı yazmadı; elde `label_key` (`SALES_MOD_PRODUCT_FIT`), `note` ({area, word}) ve `PRODUCT_LEVEL_{NONE,WEAK,ENOUGH,STRONG}` var. Görüşme çipinin cümlesini kuran `SalesMeetingSystem._fit_line` (`sales_meeting_system.gd:210`) özel işlevdir ve oturum durumuna (`_fit`, `_ctx`) bağlıdır.
    - Öneri: `_fit_line`'ın cümle kurma kısmı adayı parametre alan bir işleve çıkarılır (CLAUDE.md §8: ikinci kopya yok); aday kartı aynı cümleyi okur, yeni anahtar yazılmaz.
