# C0p · Pazar 2 adım ekleri (HEAD cf452525)

2026-10-22 · PLAN_C_P2'nin 18 kod adımı için HEAD `cf452525` satırları (planın yazdığı kısa sha `cf45252`). Kaynak: `git archive HEAD`
anlık görüntüsü; çalışma ağacı (Q K20, Faz D farkı) okunmadı, Godot koşmadı. C0v/C0q satırları bu dosyada geçersizdir.
Çıktı repoya girmez. Plandan sapan her ad/yol/satır en sonda §S'de.

**Okuma notları.** Yol köküsüz `scripts/...` = `project-unicorn/scripts/...`. Kısaltmalar: `sm` = `scripts/debug/endgame_smoke.gd`
(25.698 satır; vaka `ad m<harita satırı>/f<işlev satırı>`), `rp` = `scripts/debug/run_probe.gd` (2.256), `mn` = `scripts/main/main.gd`
(5.172), `b2b` = `systems/b2b_sales_system.gd` (644), `b2bc` = `systems/b2b_constants.gd` (286), `pq` = `systems/product_quality.gd` (394),
`sc` = `systems/sprint_catalog.gd`, `sb` = `systems/sprint_bridges.gd`, `sconst` = `systems/sales_constants.gd`, `st` = `tabs/sales_tab.gd`,
`csv` = `localization/strings.csv` (FİZİKSEL satır; çok satırlı alan var, kayıt sırası değil). Tüm yollar `scripts/` altındadır
(`systems/`, `autoload/`, `events/`, `tabs/`, `ui/`, `data_models/`) aksi yazılmadıkça.

## 0. Her adımı ilgilendiren olgular

- **HEAD'de olmayan dosyalar:** `systems/b2b_satisfaction.gd`, `era_table.gd`, `sector_profiles.gd`, `market_standard.gd`,
  `market_report.gd`; `data/market/eras.json`, `sector_profiles.json` (bugün `data/market/` = `companies.json`, `people.json`).
  Kaynak veriler var: `pazar2/sim/eras.json` (`tavan` 2012:3 … 2034:14, `platform_tavan_farki` -1), `pazar2/sim/rivals.json`,
  `constants.json`, `pazar2/out/tur2/P_profiles.json`.
- **Planın "yeni" dediği smoke vakaları HEAD'de YOK** (`git grep HEAD`, `docs/tasks` dışı, sıfır sonuç): `sat_total_is_sum`,
  `sat_no_silent_drop`, `ledger_fade`, `chip_matches_ledger`, `era_ceiling_gates`, `save_v<N>_market_model`, `account_modules_from_profile`,
  `rival_same_rules`, `standard_median_second`, `wanted_level_fixed_at_signing`, `obsolete_row_named`, `close_chance_terms`,
  `loss_reason_order`, `star_bands_five`, `suggested_price_formula`, `market_pool_conserved`, `renewal_seats_follow_company`,
  `non_product_leave_named`, `no_midterm_churn`, `renewal_condition_timeline`, `requests_three_star_only`, `request_market_level_only`,
  `request_card_merges`, `module_add_price`, `yearly_report_november`, `renewal_outcome_named`. C0v'nin düşen `update_age_emphasis_only`,
  `renewal_paper_once_a_month` de yok.
- **Yeni `--*-shot` türleri HEAD'de yok:** `--sales-shot=sat_tip`, `accounts_330`, `<duruş>`, `<yeni türler>`; `--product-shot=live:overview_b2b`,
  `overview_b2c`, `overview_no3`, `live:<era türü>`; 4★ `--meeting-shot=probe`. Var olanlar: `live:b2b_requests` (mn:3838, `_seed_product_live`
  mn:3841), `live:b2b_mature`, `b2b_quarter`, `b2b_mvp`, `overview_pre` (mn:3822-3846 yorum, `_run_product_shot` mn:3702);
  `--meeting-shot=probe|lost` (`_run_meeting_shot` mn:4262); `--negotiation-shot=countered|last|insult|confirm` (`_run_negotiation_shot`
  mn:4358-4392; `open` için kol yok, düz çekim); `--inbox-shot=weekly_sales` (mn:1246), `rep_lost|weekly_lost|weekly_lost_only` (:1256),
  `clause_*` (:1254), `thanks` (:1234), `support_week|support_behind|support_go` (:1259) (`_run_inbox_shot` mn:1104);
  `--sales-shot` (`_run_sales_shot` mn:1471, tür listesi yorumu mn:1448-1470); `--tab-shot=piyasa:sektor` (`_run_tab_shot` mn:2335);
  `--tick-probe=…:accounts=<n>` (`_seed_accounts_state(count)` mn:518-536, ayrıştırma mn:557-562, `TICK WORLD` mn:536).
- **Bot (rp):** `PRESETS` rp:179-221 (`stance` anahtarı ve `full_run_idle` yok; `fix`, `desk`, `core_only`, `server`, `cash`, `vc`
  anahtarları var). PROBE satırları: `FIX` :495, `CHURN` :668, `SIGN` :684, `FIT` :692, `MLOSS` :710, `REPLOSS` :717, `LEAD` :725, `SIGNAL` :780,
  `CUST` :800, `SAT` :807, `UFLUX` :835, `BUGS` :876, `WEEK` :1149, `END` :1161, `DECISION` :1568, `FIXTURE` :2190, `MARKET` :550
  (Piyasa listesi). `PROBE STD/RENEW/POOL/REPORT/REQ` yok. `_pick_choice` rp:968, `RETAIN_PREFERENCE`/`DISCOUNT_PREFERENCE` rp:964-965.
- **Fikstür köprüsü (sm):** `_sign_fixture` sm:606 (36 çağrı), `_past_onboarding` sm:619, `_seed_b2b` sm:717; doğrudan
  `add_b2b_customer`: sm:611, 14822-14824, 14891, 15670, 15707, 19085, 19108, 19140, 21369, 22084, 22252; mn:533, 690, 1680, 3202, 3209,
  3627, 3947, 3964; rp:2206, 2231, 2236, 674. `add_b2b_customer` = `systems/sales_system.gd:343` (imza `(prospect, seats, seat_price, satisfaction,
  source := "founder_pitch", discount := 0.0)`).
- **Kapı betikleri var:** `tools/run_gate.sh`, `plausibility_run.sh`, `smoke_run.sh`; `scripts/theme/theme_check.gd`, `scripts/debug/glyph_audit.gd`.
- **`sprint.json`'da `bugs` bloğu ve `k` YOK** (Sessiz 33: ilk ihtiyaç duyan adım kurar). `SprintCatalog.cfg(path)` sc:29 okuyucudur.
- **Şema:** `SCHEMA_VERSION` 18 (`autoload/save_manager.gd:16`), `MIN_LOADABLE_VERSION` 10 (:23), zincir :200-205 (`< 15`, `< 16`, `< 18: _migrate_17`).

## C3a-1 · Defter (göçsüz)

**Dokunulacak (HEAD)**
- `b2b`: `daily_tick` :20, `_tick_customer` :48-71 (:54-55 iz sönümü, :56 `_tick_satisfaction`), `accept_promise` :376 (:383 `RETAIN_SAT_BUMP`),
  `apply_discount` :410 (:426 `_recover(c, RETAIN_SAT_BUMP)`), `_recover` :486-499, `on_promise_resolved` :501-552 (:522, :527, :532-533, :538, :543),
  `add_trust_drain` :200, `charge_trust_drains` :206-219 (:218), `account_bugs` :173-180 (`used_areas` × `capabilities`), `risk_voice` :620 (:625).
- `b2bc`: `ONBOARDING_GRACE_WEEKS/MARGIN` :15-16, `SIGNING_SAT_OVER_TOL/MIN` :19-20, `SAT_DRIFT_STEP/ONBOARDING_AMP` :30-31, `COMPLAINT_BUG_GATE` :70,
  `B2B_BUG_SAT_PER/CAP` :72-73, `RETAIN_SAT_BUMP` :82, `PROMISE_KEPT/BROKEN/PARTIAL_SAT` :153/154/156, `PROMISE_*_OFFSET` :277-279,
  `TRUST_OFFSET_MIN/MAX/DECAY_PER_DAY` :280-282, `clamp_trust` :285, `cs_dampen` :201 (`CS_DAMPEN_PER_POINT` :198, `CS_DAMPEN_MIN` :177).
- `data_models/customer.gd`: `satisfaction` :30, `health` :29, `trust_offset` :61 (yorum :58-60), `update_health_from_satisfaction` :100.
  `autoload/customer_registry.gd`: `set_satisfaction` :158-175 (:170 `update_health…`), `set_trust_offset` :219-227.
- `systems/support_system.gd`: `DAMAGE_*` :62-69, `_damage_residue` :99, `daily_tick` :132 (çağrı :135), `reset/to_dict/from_dict` :142-157,
  `daily_satisfaction_damage` :244, `apply_daily_satisfaction_damage` :255-280. `systems/product_system.gd:22,26` (`support` bloğu).
- `events/core/effects.gd`: `satisfaction_delta` :419-426, `trust_delta` :429-439 (:436), `trust_plan` :683-709, `break_plan` :734-.
  `events/present/chips.gd`: :80, :88, :90, `_trust_parts` :291, `_trust_part` :312, `_break_parts` :320 (:325), :360.
  `systems/incident_system.gd`: `resolve` :510 (:516 iz, :519 `add_trust_drain`), `_trust_row` :599-606 (:603), `_trust_rows` :608-622.
- Diğer: `systems/customer_rep_system.gd:335` (`trust_offset < -4.0`); `ui/components/inbox.gd:214-218` (`risk_reason`; :216 hata kapısı, :218 `trust_offset`);
  `systems/hr_constants.gd:415` (`satisfaction_bonus` yorumu; tek okuyucusu `b2b:124`); `events/seams/seams_sales.gd:6-9`, :31-34 ("never name it");
  `systems/sales_system.gd` `add_b2b_customer` :343-413 (:371-372 taban), `signing_satisfaction_seed` :420-422.
- 13 `satisfaction_delta` kartı (`data/events/cards/`): customer/{b2c_refunds, chargeback, cs_escalation, named_in_leak, request_complaint,
  request_feature, request_renewal, security_review}, product/{b2c_floor_signal, repeat_reminders, support_overflow}, rival/{false_partner, price_cut}.

**Silinecekler ve BÜTÜN okuyucuları (HEAD)**
- `_tick_satisfaction` b2b:75: çağrı :56; yorum b2bc:203, hr_constants:415; sm: 4 geçiş.
- `satisfaction_next_tick` b2b:83: `effects.gd:688`, `incident_system.gd:603`; sm 2 geçiş. `satisfaction_after_break` b2b:90: `effects.gd:738`; sm 1.
- `_drift` b2b:98 (`_account_owner` :138 yalnız onun için; `cs_dampen` ve `satisfaction_bonus` tek okuyucusu :120/:124). `_target_on` :151,
  `_forgiven_trust` :167, `satisfaction_target` :146 (okuyucu: `rp:802`, `mn:724`, 32 sm geçişi; planda yalnız C3a-3'e yazılı).
- `onboarding_floor_until` b2b:184: `b2b:161`, `rp:2177`; sm 2. `onboarding_ends_under_bar` :191: tek okuyucu `st:553-554`; sm 2.
  csv `SALES_ONBOARDING_ENDS` 145 (tek okuyucu `st:554`).
- `ONBOARDING_GRACE_*`: `b2b:162`, `b2b:185`, `mn:1554`, `rp:2239`; sm 5 (`_past_onboarding` :620).
- `DAMAGE_*`/`daily_satisfaction_damage`/`apply_…`/`_damage_residue`: yalnız `support_system.gd` içinde; sm `infra_capacity_moves_both_ways`
  (m208/f14563, okuma :14595) `daily_satisfaction_damage` okur (planda adı yok).
- `set_trust_offset` customer_registry:219: yazarlar `effects.gd:436`, `incident_system.gd:516`, `b2b:55/218/522/533/543`, `mn:1561`; sm 5.
  `Customer.trust_offset` okuyucuları (C3a-2'ye kalır, deftere döner): b2b:54/93/147/193, effects:688, incident:603, customer_rep:335, inbox:218,
  rp:669/802, mn:1561; sm 46 satır.
- `signing_satisfaction_seed`: `sales_finalizer.gd:92`, `sales_rep_system.gd:268`; sm 3269, 3292-3299, 25148.
- `RETAIN_SAT_BUMP`: b2b:383, :426; sm 1. `B2B_BUG_SAT_PER/CAP`: yalnız b2b:158; sm 3. `COMPLAINT_BUG_GATE`: b2b:625, inbox:216, mn:1484; sm 5.
- csv: `SALES_ONBOARDING_ENDS` 145; değişecek `SALES_REASON_OUTAGE/STABILITY/SATISFACTION` 141-143 (`STABILITY` tek okuyucu inbox:218),
  `EFFECT_SATISFACTION` 1463, `EFFECT_TRUST_ACCOUNT/ACCOUNTS/PER_SPRINT/NIGHT_ACCOUNTS/OTHER_ACCOUNTS/UNTIL_SHIPS` 3162-3184.

**Güncellenecek mevcut smoke (sm)**
- Sil: `b2b_onboarding_grace_floor` m137/f3202. Yeniden: `b2b_promise_kept_on_ship` m169/f4073, `b2b_promise_broken_on_deadline` m170/f4099,
  `promise_kept_stops_countdown` m283/f5086, `promise_broken_penalty` m240/f9383, `promise_break_chain` m541/f22001, `promise_extend_once` m540/f21958,
  `incident_scale` m341/f17482, `bug_cost_b2b_account_lines` m555/f24835, `event_trust_delta_lasting` m337/f17156 (+ `_trust_standing_cost` f17191),
  `incident_defer_ends_with_line` m347/f18083, `paper_colors_two_arrivals` m525/f23180, `paper_trust_until_ships` m526/f23226, `owned_account_erodes_slower`
  m272/f5790 (+ `_erosion_over_a_day` f5821), `coupling_cs_dampen_axis` m224/f8308, `cs_request_kind_state_driven` m248/f9776 (:9803 `trust_offset` dalı),
  `b2b_account_reads_fit` m138/f3272.
- Planda adı yok ama bu adımın kaldırdığını okur: `infra_capacity_moves_both_ways` m208/f14563, `b2b_satisfaction_leaves_b2c_identical` m139/f3356 (:3373),
  `b2c_satisfaction_drifts_to_fit` m369/f12582 (B2C `satisfaction_target`; B2C ayrı `SalesSystem._tick_satisfaction` :432, silinmez).
- Hedefli koşu ailesi (geniş): `b2b_*`, `promise_*`, `cs_*`, `incident_*`, `paper_*`, `event_*`, `sales_*`, `release_thanks_*`, `risk_*`, `discount_*`, `recover_*`.
- PROBE/fikstür: `PROBE CHURN` rp:668 (`trust=`), `PROBE CUST` rp:800-803 (`target`, `trust`), `PROBE SAT` rp:807, `_check_b2b_fixture` rp:2169-2194,
  `_seed_b2b_world` rp:2196-2256 (`specs` :2219-2225 `sat` tohumları, :2236 çağrı, :2237-2239 `settled`); `sprint_probe.gd:240-243`;
  mn:533, 690, 724, 1554, 1557, 1561, 1680, 4418.

**C0v/C0q'dan düşenler:** ~~güncelleme yaşı: `last_touch_day`, 26 hafta/−1 per 4 hafta/−12, `_go_public` bağlantısı, `update_age_emphasis_only`~~ (§6 satır "Güncelleme
yaşı"); ~~şema 19 ve `_migrate_18` (C0v/C0q)~~ (C3a-1 göçsüz, plan §5); ~~durum terimleri zam −2 ve gönülsüz yenileme −6~~ (§6 satır "Durum terimleri"); ~~W1
`sat.term_raise`, `sat.term_reluctant`~~ (§6 W1 satırı); ~~`Customer.trust_offset` silinir (C0v)~~ (C3a-2'de). Sürer: W1 `sat.*` (term_discount, term_clause).

**D ortak:** D1/D3 (DPLAN2:77, :80): `effects.gd` 419-439, 683-739; `chips.gd` 80-90, 291-360; `support_system.gd` 62-157, 244-280; `incident_system.gd` 510-622.

## C10 · Dönem tavanı

- Dokunulacak: `systems/line_gates.gd` `evaluate` :65, `is_unlocked` :88, `unmet_parts` :95; `sc` `gate_reason` :290-311; yeni `era_table.gd` (`EraTable.ceiling`),
  `data/market/eras.json` (kaynak `pazar2/sim/eras.json`). Takvim: `GameState.get_date_dict` (başlangıç 1 Oca 2012).
- `gate_reason` okuyucuları (hepsi tavan kilidini görür): sc:234, 344, 579, 843; `sprint_system.gd:144, 588, 766, 1625`; `sb:47`;
  `tabs/product/product_model.gd:219, 569, 578-579`; `rp:1335`. `LineGates.is_unlocked`: `b2b:597`, `seams_ported.gd:45`, `product_read.gd:79`.
- Silinecek: yok. Smoke: `line_ladder_rules` m437/f15876, `line_k3_locked_without_research` m438/f15911, `gate_scope_and_halves` m439/f15946 güncellenir.
- Fikstür/kare: `--product-shot=live:<yeni tür>` için `_seed_product_live` mn:3841 yeni kol (HEAD'de yok).
- D ortak: D1 `sc` (`step_effort` :171-178 ve `gate_reason` bitişik).

## C3a-2 · 10 modül, profil, alanlar, TEK GÖÇ

**Dokunulacak (HEAD)**
- `systems/product_lines.gd`: `TIER_MAX` :20, `EFFORT_BANDS` :23 (kullanım :215), `IDENTITY_PROFILE_SHAPE` :39 (doğrulama :119-121),
  `IDENTITY_LINE_COUNT` :40 (:107-109), `LINES_PER_SUBTYPE` :41 (:133-134); üçü de TÜM alt-türlere (note_tool, video_clip 5/9 kalır) tek sabit: alt-tür
  başına değer gerekir. `steps_raw.size() != TIER_MAX` :155. `data/product/lines/erp.json` (169 satır): `line_erp_cashflow` :15 (dev), `intake` :45 (dev),
  `ledger` :76 (test), `stock` :106 (design), `invoicing` :136 (design); yorum :4 cashflow'a atıf.
- `data/product/sprint.json`: `month_close.lines` :63 (cashflow dahil), `incident.regression.b2b` :66-67 (cashflow dahil), `areas[core]` :131 (`identity: true`),
  `areas` :132-135. `data/product/rivals.json` `erp`: `tiers` :61-71 (`line_erp_cashflow` :62, `intake` :63, `ledger` :64), `launches` :72-83 (cashflow :76, intake :75, ledger :82).
- 5 kâğıt `data/events/cards/product/`: `sprint_design_color_blind` (cashflow :62), `sprint_dev_import_tool` (intake :77, ledger :78), `sprint_dev_multi_currency`
  (cashflow :69, ledger :68), `sprint_test_after_midnight` (cashflow :61, intake :62, ledger :60), `sprint_test_readonly_delete` (intake :71, ledger :70).
  Öteki iki ERP kâğıdı (`sprint_test_stock_transfer`, `sprint_design_gloves`) yalnız `stock` okur: göçten etkilenmez.
- Kayıt: `Customer.industry` customer.gd:19, `company_size` :20, `scale` :39, `market_ref` :79; `data_models/prospect.gd` `industry` :20, `star` :24, `last_loss_reason` :68,
  `pain_feature_id` :74. `autoload/save_manager.gd`: `_migrate_17` :969-990, `_retire_stability` :992-996, `_migrate_sector_ids` :1039; sıradaki kol :206.
  `GameState.sales_account_memory` game_state.gd:215, `sales_loss_log` :212; yazar `systems/sales_ledger.gd:179-190`.
- `systems/sales_faucet_system.gd`: `spawn` :191-250 (sektör çekimi `SalesArchetypes.sectors` + ikinci mixer turu :204-210; `sales_archetypes.gd` sektör listeleri :46, :64, :82),
  `sales_system.gd:343-413`, `b2b:173-180`, `sc:376-382` (`line_accounts`), `pq` `used_areas` :85, `uses_area` :91, `USE_AREA_MIN` :27.

**Silinecekler ve okuyucular**
- `line_erp_cashflow`: yukarıdaki veri satırları + sm 6 satır (18209-18213 `fix_first` vakası, 21200-21203, `CASHFLOW_STEP` 25267); `line_erp_intake` sm:17972. `line_erp_ledger` mn:77, 877, 977, 1484, 1628, 1709-1710, 1829, 4287; rp:316; sm 19.
- `Customer.trust_offset` (alan, 8 okuyucu: bkz. C3a-1) ve `TRUST_OFFSET_DECAY_PER_DAY` b2bc:282 (okuyucu b2b:168), `clamp_trust` b2bc:285 (okuyucular customer_registry:226, effects:688, incident:516/603, b2b:93).
- `ProductQuality.used_areas/uses_area/USE_AREA_MIN`: tek iki okuyucu `b2b:177` ve `sc:379` (plan doğru).
- `_migrate_17` içinden `_retire_stability` bloğu :970-977 + işlev :992-996 (yerine yeni göç temizler); `if version < 18` kolu C3a-3'te kalır.
- "9 hat × 3 = 27" mührü (planın adlarından FARKLI yerde, bkz. §S-1): `product_lines_catalog_loads` m436/f15075 (9 hat :15091, 3/3/3 :15098, 27 adım :15099-15105),
  `research_node_map_binds` m452/f16048 (:16091-16093 "3 alt-tip × 9 hat = 27 K3"), `product_line_profiles` m443/f15310 (profil şekli 2/1/2 ve 1/2/1 :15325),
  `loc_product_line_keys_resolve` m440/f16006 (yorum :16036 "378 okuma").
- **Güncellenecek smoke:** `product_lines_catalog_loads`, `loc_product_line_keys_resolve`, `bug_cost_b2b_account_lines` (m555/f24835, :24848 `uses_area`), `save_v10_product_state`
  m465/f16162, `account_uses_area_rule` m154/f9101 (planda adı yok; `uses_area` kuralını sabitler), `type_screen_matches_line_content` m467/f14038 (mühür DEĞİL, yalnız
  `locked.size() != 3`). Diğer hat-sözleşmesi okuyanlar: `line_ladder_rules`, `line_k3_locked_without_research`, `gate_scope_and_halves`, `product_fit_table`
  m441/f15128, `product_quality_sector_table` m442/f15209, `fit_star_context` m444/f15448, `fit_account_ref` m445/f15709, `fit_scale` m446/f15637, `save_v17_market_ref`
  m447/f15779, `product_area_row` m448/f15255, `rival_composite_table` m450/f25689, `research_node_map_binds`, `rnd_tree_loads_and_validates` m453/f16296, `card_math_matches_gdd_example` m464/f16134.
- PROBE/fikstür: `run_probe.gd` `FIXTURE_BUG_LINE` rp:316; `STAFF_LADDER` rp:1447; `mn:77` (`_ERP_SHIPPED_LINES`), `_seed_line_state` mn:3976.
- Belgeler: `GDDs/GUNCELLEMELER.md` (sayfada "9 hat × 3" ifadesi YOK; ilgili girişler :590 demo alt-tipleri, :165 hat verisi); `CLAUDE.md` §6 şema satırı; HARITA `:39`.
- Ar-Ge K3 kapısı eşlemesi (Sessiz 4): `systems/research_seam.gd` `completed` :64, düğüm bağları `research_node_map_binds` ile sınanır.

**C0v/C0q'dan düşenler:** ~~"şema 19 / `_migrate_18`" (C0q)~~ (numara iniş anında, plan §5); ~~`Customer.trust_offset` silinir C3a (C0v)~~ burada.
**D ortak:** D1 (`save_manager.gd` :16, :200-206; `sprint.json` :63-67, :131-135).

## C11a · Rakip şirketleri ve standart

**Dokunulacak (HEAD)**
- `data_models/rival.gd` (alanlar :17-31; `composite` :36-38), `systems/rival_catalog.gd` (`TEMPLATE` :20, `COMPOSITE_AXES` :33, `NAMES` :96, `SHARE_SEED` :125,
  `MARKET_ACTORS` :135, `MARKET_TOTAL_MRR` :144, `build_all` :148), `autoload/rival_registry.gd` (`TIER_ASYMPTOTE` :16, `advance_all` :71-87, `_status_for` :92-97,
  `get_market_snapshot` :127, `get_player_share_pct` :161), `autoload/time_manager.gd:406` (`advance_all` çağrısı, `SalesSystem.daily_tick`'ten sonra).
- `data/product/rivals.json` `erp`: `rivals` [3,5,6] :60, `tiers` :61-71, `launches` :72-83 (11 sabit çıkış). `sc`: `rival_table` :603, `rival_launch_in` :620, `_rival_tier` :713,
  `_closes_rival_gap` :722, `recent_hits` :731, `step_effort` :171-178 (rakip aynı kapıyı okur). `sb` `tick_rivals` :82-88 (yazar `rival_hits` :84-87).
  `ResearchSeam.completed(node)` research_seam.gd:64 (şirket başına olacak; çağıranlar: infra_system:237, line_gates:74, product_lines:345/355/395, sales_probes:77,
  sales_system:464, sc:176, support_system:163/227, rnd_system:435 yorum). `vc_pitch_system.gd`: `_rival_ahead` :1290-1295 (çağıran :1124, :1168).
  `news_feed_system.gd`: `BIZ_HARD_CAP` :39, `_pick_source` :267, `_rival_candidates` :326, `_emit_rakip` :346, rakip sürüm haberi `sb:82-91` (`ticker_live_line`).
- `docs/tasks/PRD_RAKIP_DUNYASI.md` F tablosu :26 ("I2 hafif rakipler + kalite çıtası → I3 dönem göçü").

**Silinecekler ve okuyucular**
- `rivals.json` `erp.launches`/`erp.tiers`: tek okuyucu `sc:603-735` (`rival_table`); `rival_hits` yazımı `sb:84-87`, okuyucu `sc:597/715/733`, `rp:888` yorum,
  `GameState`/`sprint_system.gd:81` ilk değer; sm 1 geçiş. `rivals.json`'ın `note_tool` (:2-30) ve `video_clip` (:31-58) blokları KALIR.
- `COMPOSITE_AXES`'in ERP satırı: HEAD'de YOK (§S-4). `QualityModel.grow`/`TIER_ASYMPTOTE` B2C için kalır.
- `_rival_ahead` "sabit true": sabit değil (§S-5); `rp`/sm: "Neutralize the DOMINANT-giant proxy" sm:1690.
- Smoke: `rival_composite_table` m450/f25689 (ERP beklenen kalite satırı :25674 sabitlenmiş), `market_share_tracks_mrr` m246/f9598 (planda adı yok; pay modelini okur, C11b'de de).
- PROBE: yeni `PROBE STD` (HEAD'de yok); `--tick-probe=3:accounts=330` (mn:557-562). Kare: haber şeridi için HEAD'de ayrı `--*-shot` türü doğrulanmadı (ticker: `news_feed_system.gd` `_emit_rakip` :346, `ticker_live_line`).

**D ortak:** D1 bağı (`step_effort`, `person_points_week` ×5) ve `sc` (rival_* :592-635, :713-736, D1/D2b/D7/D8a ile bitişik); `sb` D3.

## C3a-3 · İstenen seviye ve eskime

- Dokunulacak: `b2b_satisfaction.gd` (C3a-1'den), `b2b` `_target_on` yerine, `market_standard.gd`, `pq` `account_fit` :246-259, `market_ref_for` :206-209, `customer.gd:76-79`
  (`market_ref`), `customer_registry.gd` `set_market_ref` :229-237, `sb:35-36` (`set_market_ref` tetikleyicisi), `sales_system.gd:385` (imzada `set_market_ref`),
  `save_manager.gd` `_migrate_17` kalan `market_ref` bloğu :978-990 ve `:204-205` kolu, `inbox.gd:214-218` (`risk_reason`).
- Silinecekler ve okuyucuları: `account_fit`: `b2b:157`, `rp:695, 797, 827, 2176`; sm 17. `market_ref`/`market_ref_for`: `save_manager:988-989`, `sales_system:385`, `sb:36`, `pq:247-248`; sm 22.
  `satisfaction_target`: `rp:802`, `mn:724`, sm 32. Vakalar: `fit_account_ref` m445/f15709, `save_v17_market_ref` m447/f15779, `b2b_account_reads_fit` m138/f3272,
  `fit_star_context` m444/f15448 (hesap kolu; :15461-15467 + 35 geçiş).
- Gelen kutusu `risk_reason` en büyük olumsuz satır: `Inbox.risk_reason` HARITA:219'da tarif edilir, csv `SALES_REASON_*` 141-143.
- PROBE: `PROBE UFLUX` rp:811-845 (`renewal=` alanı `renewal` sayımı rp:821-835; `next_renewal_day` rp:831), `_account_u` rp:279. Kare `--sales-shot=sat_tip` (yok), TR/EN.
- `--tick-probe=3:accounts=330`; `plausibility_run.sh`; `run_gate.sh`.
- **C0v/C0q'dan düşenler:** ~~`market_ref` tetikleyicisinin yenileme açılışına (8 hafta) taşınması + `fit_account_ref`/`PROBE UFLUX` taşıma notu~~ (§6 satır "`market_ref` tetikleyicisi"; bu adım siler).
- **D ortak:** D1/D3: `save_manager.gd` :204-206, `sb` :35-36.

## C3b-1 · Kapanış zarı

**Dokunulacak (HEAD)**
- `pq`: `CLOSE_CURVE` :30, `close_chance` :233-241, `prospect_fit` :216, `prospect_ctx` :211, `fit` :261, `fit_from_levels` :268 (:296 `loss_area`), `market_fit` :222, `expectation` :118 (`rival_bump` :124-125).
- `systems/sales_rep_system.gd`: `lost_area` :239-241, `_close` :258-274 (:259, :265, :268), `_lose` :245-246, `_tick_weekly_summary` :301. `sales_meeting_system.gd`: `_ctx`/`_fit` :91-92, :142
  (`W_PRODUCT_FIT`), :161-162 (`MISMATCH_PENALTY`), :211, :213, :344-345, :360, :430, :436-438. `sales_probes.gd` :48-49, :62-64, `CATALOGUE` :141-170 (`probe_emphasis_*` :144-164).
  `sales_ledger.gd` `report_loss` :179, `repitch_blocked` :346, `_blocker_cleared` :354-363 (`LOSS_WEAK_AREA` :355-356). `sales_constants.gd` `MISMATCH_PENALTY` :87, `LOSS_WEAK_AREA` :205, `LOSS_REASONS` :210,
  `SALT_REP_CLOSE` :279. `sales_finalizer.gd` `lose` :47, imza :92. `sales_faucet_system.gd` `product_strength` :165-166 (okuyucu :150), `spawn` :191.
  `data/product/sprint.json:31-32` (`rival_bump`, `rival_bump_max`).
- Mail: `inbox.gd` `lost_body`/`lost_line` :311-320 ve `mail_pane.gd:148`; csv `SALES_REP_LOST_*`, `SALES_WEEKLY_LOST`, `SALES_LOSS_WEAK_AREA`, `SALES_MEMORY_WEAK_AREA`.

**Silinecekler ve okuyucular:** `CLOSE_CURVE`/`close_chance`: tek çağıran `srep:241` (+ `lost_area`); sm 7. `prospect_fit`: `srep:241`, `sales_system:421`, `rp:691, 716, 737`; sm 19. `prospect_ctx`: `sales_ledger:356`,
`sales_meeting_system:91`, `sales_probes:48`. `loss_area`/`lost_area`: sconst yok; `srep:239-259`, `sales_meeting_system:211/344/360/430/436`, `rp:694/712/727/737`, `mn:1665`; sm 26.
`rival_bump`: `pq:124-125` (adaya `rivals: true` bağlamı). `MISMATCH_PENALTY`: `sales_meeting_system:161-162` (kurucu "bir üste ×0,6" kuralı bunun yerine). `product_strength`: `sales_faucet_system:150, 165`;
sm 3 (`sales_star_mix_reads_fit` m152/f9003). `LOSS_WEAK_AREA`: `mn:1507/1509/4148/4150`, ledger/meeting/rep (yukarıda); sm 14.
`probe_emphasis_*` silinmez ("önemli modül" sorusu); sm `sales_emphasis_question` m147/f3920.

**Güncellenecek smoke:** `sales_rep_close_chance` m149/f8747, `sales_rep_close_die` m150/f8799, `sales_weak_area_loss` m148/f3981, `sales_meeting_reads_fit` m146/f3840, `product_fit_table` m441/f15128,
`product_quality_sector_table` m442/f15209, `fit_scale` m446/f15637, `sales_loss_reason_from_asked` m145/f3787, `bugs_leave_sales_and_vc_alone` m560/f25129 (:25135-25178 okuma listesi). Planda adı yok:
`sales_star_mix_reads_fit` m152/f9003, `sales_rep_loss_mail` m151/f8893, `b2b_pitch_meeting_signs` m142/f3569, `sales_save_roundtrip_rev6` m163/f19121.
**PROBE/Kare:** `PROBE SIGN` rp:684 (yeni alanlar `p= base= fit= seller= price=`), `PROBE FIT` rp:692, `REPLOSS` rp:717, `MLOSS` rp:710 (`reason= rival=`), `LEAD` rp:725; `--meeting-shot=probe|lost`.
**C0v/C0q'dan düşenler:** ~~`sign_gate_reason`, `sign_single_loss`, imza kapısı eşik+10, zar tabanı %60, `SIGNING_SAT_OVER_TOL` kapı payı~~ (§6 ilk iki satır); ~~`SalesRepSystem._close` "önce kapı sonra zar"~~;
~~`PROBE SIGN` kapı/zar ayrı kayıp alanı~~; ~~W1 `sign.mail_line`, `sign.mail_line_clean`, `sat.renewal_reading`, `sat.term_market_moved`~~ (§6 W1 satırı). `loss.bugs_*` düşenler listesinde YOK (plan sessiz).
**D ortak:** yok (∥D). Q dosyası `pq` yalnız C.

## C3b-2 · B2B ürün sayfası (alan beklentisi kalkar)

- Dokunulacak (HEAD): `sc` :125 (`area_level`), :328-333 (`card_effect` from/to_word), :672-695 (`_level_part`, `_standing`, `serves`), :804 (`_impact`), :818-829 (`_weakest`, `next_star/next_ratio`);
  `sb` :109 (`expectation`), :147-148 (`word_for`/`word`); `sprint_system.gd:1548`; `tabs/product/product_model.gd` :163 (`word`), :176, :456 (`next_ratio`); `vc_pitch_system.gd` :1128, :1178;
  `term_sheet_table_system.gd:548`; `pq` `expectation` :118, `word_for` :133, `word` :142, `is_enough` :147, `serves` :153, `next_star` :163, `next_ratio` :172, `weakest_area` :179, `area_row` :194, `_role` :322, `_value` :332, `_star_value` :341.
  `product_read.gd:101-104` B2C kalır (`weights("b2c", "")`, `expectation(area, {"audience": true})`).
- Silinecek ve okuyucular: `CORE_2/EMPHASIS_2/CORE_3/EMPHASIS_3` pq:37-40 B2C DE okur (§S-2: `_value` b2c dalı :326-331 → `_star_value`); yalnız `REST_3` :41, `W_B2B` :18, `weights` B2B dalı :72-75 ve `_role` "rest" :330 B2B'ye özgü.
  `area_row` pq:194: tek okuyucu yok (C0q: hiçbir ekran). `weakest_area` :179: `vc_pitch_system:1128/1178`, `term_sheet_table_system:548`; sm `vc_weakest_area` m561/f25200 (planda adı yok).
  `serves/next_star/next_ratio`: `sc:690, 824, 829`, `product_model.gd:456`.
- Smoke: `product_area_row` m448/f15255 (B2B kolu), `product_fit_table`, `product_quality_sector_table`, `fit_star_context` (35 geçiş), `vc_weakest_area`. Kapı `--sprint-probe` (`tools`/`scripts/debug/sprint_probe.gd`).
- Kare: `live:b2b_mature|plan|b2b_quarter` (mn:3822-3846). **D ortak:** D8a + `sprint_system.gd` (öneri/çeyrek şeridi `sc:818-829`, `product_model.gd:456`); `sc` :125/:328/:672-695 D1/D2b/D7/D8a ile aynı dosya.

## C3b-3 · 5 yıldız

- Dokunulacak (HEAD): `sconst` `STAR_MIX_BOOTSTRAP/TRACTION` :42-43, `STAR_MIN/MAX` :44-45, `PROBES_*` :103-105, `SEAT_BAND` :115-119, `TICKER_NEWSWORTHY_STAR` :175, `DEAL_BASE_WEEKS` :152 (zaten 5), `star_mix` :228, `seat_band` :234;
  `sales_faucet_system.gd` `SIZE_TO_STAR` :30, `star_mix_now` :148, `_roll_star` :169-177, `spawn` :194 (`clampi`), `spawn_prospect` :251-252; `counterpart_system.gd:20` (`PROSPECT_ROLES` 3 rol; :57 `slice(0, p.star)`);
  `sales_archetypes.gd` `star_range` :48, :66, :84 ([1,3],[1,3],[1,2]), :123; `negotiation_system.gd:98`; `sales_ledger.gd` `rep_band_cap` :98-109; `sales_rep_system.gd` :71, :87-89, :283; `sales_system.gd:317, 354`;
  `sales_meeting_system.gd` `_probes_for_star` :220-224 (çağrı :93); `b2bc` `EXPANSION_SEATS` :212, `expansion_seats` :215, tolerans `seed_tolerance` :62; `mn:1515` (`seat_band`).
- `musteri.scale` okuyan 5 kart (doğru): customer/{chargeback, named_in_leak, new_owner, security_review}, product/sprint_design_customer_colors; seam `seams_sales.gd:46`.
- Silinecekler: bkz. §S-3, `ProductQuality.STAR_MAX` (pq:21) sayfa-yıldızı merdivenidir, satış yıldızı değil. `company_size` okuyucuları: `sales_system.gd:354`, `effects.gd:648`, `chips.gd:226-227`, `b2bc:215`, `save_manager.gd:622, 633` (`_LEGACY_SIZE_TO_STAR`, KALIR).
- Smoke: `auto_capacity_grows_only` m211/f14731 (+650 koltuk), `star_ruler_contract` m418/f11227, `b2b_scale_and_sector_gating` m179/f6609, `sales_threshold_separates_tiers` m230/f8533,
  `hotfix_deal_variance_across_leads` m262/f5479, `sales_star_mix_reads_fit` m152/f9003, `sales_save_roundtrip_rev6` m163/f19121; PROBE `LEAD star=` rp:725; kare `--meeting-shot=probe` (4★ yeni).
- **D ortak:** ∥D.

## C3b-4a · Fiyat verisi ve duruşlar

- Dokunulacak: `sconst` `SEAT_PRICE_MIN/MAX` :120-121, `STANCES` :127, `STANCE_MULT` :128-132, `STANCE_DEFAULT` :133, `W_PRICE_SIGNAL` :80, `PROCESS_PREMIUM_PENALTY` :156, `stance_mult` :239;
  `sales_ledger.gd` `price_stance` :126, `set_price_stance` :131, `seat_price_anchor` :141-144; `sales_rep_system.gd:156` (`work_stance` damgası), :172, :265; `sales_system.gd` `pipeline_optimistic_mrr` :309-326;
  `sales_finalizer.gd`; `st` `_paint_stance` :219-230; `sales_meeting_system.gd:151-154`; `data/product/lines/erp.json` (fiyat sınıfı alanı HEAD'de yok).
- Silinecek ve okuyucular: `seat_price_anchor`: `negotiation_system.gd:111`, `sales_system.gd:314`, `sales_rep_system.gd:265`, `mn:1515`; `SEAT_PRICE_MIN/MAX`: `negotiation_system.gd:112-113`, `mn:4384/4387` (C3b-4b'de gider).
  "temsilcinin duruşsuz fiyatı" HEAD'de yok (§S-6). Smoke 72 geçiş (`stance`/`seat_price_anchor`): `b2b_pitch_meeting_signs` m142 (:3602/3619/3656), `sales_autonomous_close_routine` m228/f8447,
  `sales_concession_deal_surfaces` m231/f8561, `sales_desk_deal_runs_its_plan` m232/f8632, `sales_save_roundtrip_rev6` m163/f19121.
- Kare `--sales-shot=<duruş>` HEAD'de yok. Bot `stance` anahtarı yok (`PRESETS` rp:179). csv `SALES_STANCE_HINT_*` (üç metin). **D ortak:** ∥D.

## C3b-5 · Aday ve hesap kartı

- Dokunulacak: `st` `_lead_card` :323-375, `_account_card` :532-563, `_meta_line` :565-580, `_satisfaction_row` :608, `_name_row` :777, `_line` :786, `ATTENTION_RANK` :22, `PHASE_TAGS` :24-25;
  `scripts/theme/build_theme.gd` (damga `UiTokens.THEME_STAMP`, `main.gd:100-101` bayat uyarısı). Silinecek: `_meta_line`'ın modülsüz tek satırı :565. Kapılar `theme_check.gd`, `glyph_audit.gd`, `--theme-contrast-audit`.
- Kare `--sales-shot=<yeni türler>` yok. **D ortak:** ∥D.

## C11b · Pazar havuzu

- Dokunulacak: `rival_registry.gd` `get_market_snapshot` :127-158, `_share_row` :175, `_share_at` :193-210 (`SHARE_GROWTH_PER_DAY` :114, `SHARE_WOBBLE_AMP` :115), `get_player_share_pct` :161-162;
  `rival_catalog.gd` `SHARE_SEED` :125, `MARKET_ACTORS` :135-138, `MARKET_TOTAL_MRR` :144; `rivals.json`; `tabs/finance/finance_ozet_view.gd` :505-552 (snapshot okuyucu, sıra/pay satırları);
  `news_feed_system.gd:154, 326-340`; `sales_finalizer.gd`, `b2b` `_remove_lost` :303-310 (adlı rakibe geçiş).
- Silinecek: ERP için `MARKET_TOTAL_MRR` (okuyucu `rival_registry:162` — B2C ve öbür alt-türler de okur, tamamı silinemez), `SHARE_SEED`, momentum payı (`_share_at`). Okuyucular: `seams_sales.gd:121`, `seams_world.gd:77`, `news_feed_system.gd:154/223/331`.
- Smoke: `market_share_tracks_mrr` m246/f9598 (planda adı yok). PROBE `PROBE MARKET` rp:547-558 Piyasa listesinindir; yeni `PROBE POOL`. Kare `--tab-shot=piyasa:sektor`, Finans pazar payı. **D ortak:** ∥D.

## C5-1 · Yenileme

**Dokunulacak (HEAD)**
- `b2b`: `_tick_at_risk` :223-245, `can_offer_retention` :252, `_tick_healthy` :262-280, `can_offer_expansion` :286-291, `_churn` :294-300, `_remove_lost` :303-310, `hold` :396-408 (`retain_stalls` :402-404), `apply_discount` :410-427,
  `ignore_risk` :429, `expand` :437-455 (:452), `decline_expansion` :457-465, `_recover` :486-499. `b2bc` `RISK_TRIGGER_WEEKS` :21, `RISK_REENTRY_WEEKS` :27, `CHURN_COUNTDOWN_WEEKS` :28, `EXPANSION_MATURE_WEEKS` :29,
  `RETAIN_*` :74-88, `EXPANSION_PER_SEAT_MRR` :210, `EXPANSION_SEATS` :212, `expansion_seats` :215, `CS_KIND_*` :262-265, `RENEWAL_MIN_TENURE_WEEKS` :268.
- `customer_rep_system.gd` `pick_request_kind` :318-372 (:335-344 risk/oyala puanı, :365 `CS_KIND_RENEWAL`, :370-372). `sales_rep_system.gd` `_tick_weekly_summary` :301. `sb` `next_renewal_day` :62-66, `tick_requests` :22-55.
- `events/tools/plausibility.gd:57` (`RENEWAL_MIN_TENURE_WEEKS` kopyası), kural :366-369. `events/gate/scope.gd:297` (`can_offer_expansion`), `events/seams/seams_ported.gd:21` (`is_expansion_ready`), :51 (`retain_stalls`), :60 (açıklama "complaint | feature | renewal").
- Veri: `data/events/cards/customer/request_renewal.json` (id satırı 40, `b2b_retain_discount` :73), `expansion.json`, `retention.json` (`b2b_retain_delay` :129, `b2b_retain_discount` :150, `b2b_retain_ignore` :164, :209), `sprint_pm_renewal.json:62`. `data/product/sprint.json:38` (`request`).
- `save_manager.gd:735-738` eski göç satırları (`last_risk_exit_day`, `last_expansion_day`, `churn_countdown`, `risk_streak`) — plan doğru.

**Silinecekler ve okuyucular**
- `request_renewal.json`: id `customer.request_renewal` (kartı `plausibility.gd:366`, sm `discount_row_locked_past_cap` :13272 render eder), csv tek okuyucu: `B2B_EV_RENEWAL_TITLE` 748, `B2B_EV_RENEWAL_BODY` 729, `B2B_CHOICE_SIT_DOWN` 734, `B2B_CHOICE_RENEW_LOWER` 735, `B2B_CHOICE_LET_IT_WAIT` 736, `B2B_EV_REQ_RENEWAL_EXPIRED` 2113. KALIR: `B2B_DISCOUNT_SPENT_DESC` 1784 (retention, false_partner, price_cut, b2bc, sm).
- `CS_KIND_RENEWAL`/`CS_REQUEST_KINDS`: `customer_rep_system.gd:365, 371`; `RENEWAL_MIN_TENURE_WEEKS`: `customer_rep_system.gd:370`, `plausibility.gd:57/368-369`.
- `expansion.json` + `EXPANSION_SEATS`/`expansion_seats`: `effects.gd:648` (`b2b_expand`), `chips.gd:226-227`; `can_offer_expansion`: `b2b:278`, `scope.gd:297`, `seams_ported.gd:21`; `last_expansion_day`: customer.gd:54, customer_registry:296-304, save_manager:736, `b2b:289/452/464`; `Customer.company_size` tek okuyucusu `expansion_seats`. Fiiller `b2b_expand`/`b2b_expand_decline` effects.gd:62, 76; lint.gd:359-391.
- Risk/Oyala: `churn_countdown` (customer.gd:41, registry :189-199, `b2b:237-255/406/491`, `st:619-629` geri sayım UI, `rp:670/747/803`, `mn:733/1557`, `seams_sales.gd:42`, save_manager:737), `risk_streak` (customer.gd:42, registry:211, `b2b:226-267/489`, `rp:670/803`, save_manager:738),
  `retain_stalls` (customer.gd:46, `b2b:402-407`, `customer_rep_system.gd:344`, `seams_ported.gd:51`), `last_risk_exit_day` (customer.gd:48, registry:287, `b2b:233-234/492`, save_manager:735), verbler `b2b_retain_delay`/`b2b_retain_ignore` (effects.gd:617/637, chips.gd:40-41, `ignore_risk` b2b:429, `rp:964-965`).
- Smoke: `cs_renewal_floor` m583/f24646, `cs_request_kind_state_driven` m248/f9776, `discount_row_locked_past_cap` m390/f13243, `next_renewal_day_one_place` m523/f23093 (4 geçiş). Planda adı yok (Risk/Oyala/genişleme okur): `risk_reentry_hysteresis` m388/f13193, `risk_exit_stamps_day` m389/f13222, `b2b_lifecycle_and_countdown` m136/f3144,
  `b2b_retention_routes_seams` m140/f3406, `b2b_ignore_then_churn` m141/f3502, `b2b_expansion_moves_seats_mrr_counter` m178/f4254, `b2b_expansion_no_refire` m251/f5329, `recover_preserves_onboarding` m284/f5145, `promise_kept_stops_countdown` m283/f5086,
  `promise_orphan_no_brand_hit` m253/f5189, `retention_gate_shared` m391/f13280, `manual_retention_respects_cap` m392/f13315, `sales_seat_price_stamp_and_expansion` m162/f19078, `save_v13_day_stamps_migrate` m304/f2176, `event_history_chip_matches_live` m357/f6212; `paper_renewal_card_first` m524/f23125 (kart silinince konusuz).
- PROBE: `PROBE UFLUX renewal=` rp:821-835; yeni `PROBE RENEW`, `PROBE END retention=`. Kare `--inbox-shot=weekly_sales` (mn:1246) + yeni durumlar. Bot: `_pick_choice` rp:968.
- **C0v/C0q'dan düşenler:** ~~yenileme durumu alanları (dönem açık, sonuç, kâğıt, gönülsüz yenileme)~~ ve ~~tek zar/oranlar E1 K8~~ (§6 satırları "Yenileme kâğıdı", "tutum bantları", "Yıldız başına koltuk artış tabanları"); ~~satışçı raporu/kurucu kâğıdı/karşı teklif JSON'ları, W1 `renew.*`, `budget_mail.*`~~;
  ~~sektör eğilimi / `sector.trend_*`~~ (Sessiz 23); ~~kesinti tablosu `record_interrupt`/`_paper_blocked` (sm `sprint_system.gd:564, :1261`)~~ (Sessiz 21); ~~`market_ref` tetikleyicisinin taşınması~~ (C3a-3 siler); ~~bot kâğıt tercihi~~; ~~`renewal_paper_once_a_month`~~; ~~PROBE zam/indirim/bütçe/kâğıtlı ay~~; ~~bütçe kesintisinde koltuğu yarıya indirme~~.
- **D ortak:** D1/D3: `save_manager.gd:735-738`, `sb:22-70`.

## C5-2 · Yenileme şartı

- Dokunulacak: `customer.gd` şart alanları (madde alanları örneği `clause_due_day`/`notice_end_day` :94-95), `b2b` `_tick_clause` :349, `meet_clauses` :339, `_post_clause` :368, `write_clause` :326; `message_system.gd` (`post` :19, tür eşlemesi :56-58),
  `tabs/events/mail_pane.gd` (kind→etiket :137, gövde :146-150), `ui/components/inbox.gd` (:17-19 etiket, :296-320 satır önizlemesi), `st` `_account_card` :532; `b2bc` `CLAUSE_*` :49-52, `CLAUSE_MAILS` :54.
- Silinecek: yok. Smoke yeni `renewal_condition_timeline`; `PRESETS` `full_run_idle` yok (rp:179). Kare `--inbox-shot=<şart>` (yok; `clause_*` mn:1254 örnek). **D ortak:** ∥D.

## C6-1 · İstekler

- Dokunulacak: `sb` `tick_requests` :22-55 (`late` yazımı :30, alan :41 `ProductQuality.emphasis(c.industry)[0]`), `thank` :189, `thanks_of` :204, `on_release` :73-80 (`met`), :221-222 (istek teşekkürü); `sc` `candidates` :198-242 (`request` :201, :216), `open_requests` :764, `_request_of` :756,
  `paper_account` :430-452 (:434 `request`), `second_account` :453, `release_lead_sentence` :501; `b2b` `pick_pain_feature` :554, `_pick_line_pain` :583, `refresh_pains_after_ship` :639; `customer_rep_system.gd` `pick_request_kind` :318-372 (`feature` :366); `support_system.gd` `weekly_report` :318-340;
  `sprint_system.gd` `_speaker` :1249-1252; `tabs/product/product_model.gd:237, 414, 586`; `data/events/cards/customer/request_feature.json`; `sprint.json:38` (`request.deadline_weeks` 8).
- Silinecekler ve okuyucular: `request_feature.json` (csv tek okuyucu: `B2B_EV_REQ_FEATURE_EXPIRED` 2112, `B2B_CHOICE_NOT_NOW_SAY` 740, `B2B_EV_REQUEST_TITLE` 737, `B2B_CHOICE_GIVE_DATE` 738, `B2B_CHOICE_ON_THE_LIST` 739), `CS_KIND_FEATURE` b2bc:262 (`customer_rep_system.gd:366`),
  `late` durumu: tek yazar `sb:30`, okuyucu yok; `ProductQuality.TABLE/emphasis/_row`: son okuyucu `sb:41` (`sales_probes.gd:49` C3b-1'de gider). `support.sec_asked`, `support.new_request` HEAD'de YOK.
- Smoke: `sprint_request_on_time_met` m512/f21379 (+ `_seed_open_request` f21360), `release_thanks_each_kind` m349/f25323, `release_thanks_limits` m350/f25371, `release_thanks_incident_scope` m351/f25414 (+ `_met_request` f25291). Planda adı yok: `request_area_follows_emphasis` m155/f9141 (:9152),
  `sprint_late_for_requests` m546/f22608 (+ `_late_world` f22566), `paper_speaker_is_assignee` m516/f22683 (+ `_paper_pm_asked` f23402), `_request_cards_up` f5043.
- Kare `live:b2b_requests` var (mn:3838, :3943); `--inbox-shot=<istek>` yok. PROBE yeni `PROBE REQ`. **D ortak:** D3/D7/D8a: `support_system.gd`, `sc`, `sb`.
- **C0v'den düşenler:** ~~"Söz ver/Listeye al" şıkkı, decline −4, süre dolumu −5, istek kesintisi, 1★-2★ `late`~~ (§6 satır "İsteğin Söz ver / Listeye al"; Sessiz 20); ~~PROBE istek kesintisi sayısı~~; ~~csv "Değiştir" üç anahtar~~ (kart silinir).

## C6-2 · Genel Bakış

- Dokunulacak: `tabs/product/overview_view.gd` (`setup` :12, `_server_card` :28; sol sütun boş), `product_model.gd` `overview` :150 (`{server}`), `bug_row` :198, `bug_row_of` :204, `tabs/product_tab.gd` `open_area` :250 (çağrı `tabs/product/sprint_ui_shared.gd:335`), `_overview_view` :81-86,
  `ProductState.open_bugs_delta` product_state.gd:187, `SupportSystem.desk_roster` :186, `incident_system.gd` `GameState.incident["last_day"]` :271 (son 4 hafta kesinti sayacı yok), `build_theme.gd`.
- Silinecek: `open_area`'nın vurgusuz hâli (`product_tab.gd:250-257`, `product_fixtures.gd:180/190/598` `ui.open_area`). Kare `live:overview_b2b|overview_b2c|overview_no3` yok (`overview_pre` var). Kapılar `theme_check.gd`, `glyph_audit.gd`. **D ortak:** D1/D2a/D6 `product_model.gd`, D8b `product_tab.gd`.

## C8 · HESAPLAR

- Dokunulacak: `st` `_paint_portfolio` :514-530, `_account_card` :532-563, `_account_foot` :642 ("İlgilen"), `_open_steward_picker` :674, `ATTENTION_RANK` :22, `PHASE_TAGS` :24-25 (`SALES_CHIP_ONBOARDING` :25, `SALES_CHIP_HEALTHY` :538); `build_theme.gd`; fikstür `mn:518-536` (`_seed_accounts_state`, 330 hesap).
- Silinecek: csv `SALES_CHIP_HEALTHY` 133 (tek okuyucu `st:538`), `SALES_CHIP_ONBOARDING` 136 (tek okuyucu `st:25`); KALIR: `SALES_CHIP_RISK` 134, `SALES_CHIP_EXPANSION` 135, `SALES_EXPANSION_FICTION` 144 (`inbox.gd:122-124`, `kit_probe.gd:229`). `left_tabs.gd:116` rozeti değişmez.
- "Yenilemeyebilir" ve "Onboarding/Risk/Büyümeye açık yok" kuralı: HEAD'de `Yenilemeyebilir` adlı durum/anahtar yok (§S-7). Kare `--sales-shot=accounts_330` yok. Gate: `--tick-probe=3:accounts=330`. **D ortak:** ∥D.

## C12 · Rapor ve ödül

- Dokunulacak: yeni `market_report.gd`; `autoload/time_manager.gd:383-409` (`_dispatch_daily_tick`, `advance_all` :406), `systems/summary_system.gd` (`_close_month` :103, `month_ended` :126; `month_turned` :59/:70), `message_system.gd` (`post` :19), `mail_pane.gd` (:137, :146-150), `inbox.gd` (:17-19, :296-320),
  `sales_faucet_system.gd` `lead_rate_per_week` :120-129, `rival_registry.gd`, `autoload/game_state.gd` `FLAG_TYPES` :48, `time_manager.gd`.
- Silinecek: yok. Smoke yeni `yearly_report_november`; PROBE yeni `PROBE REPORT`; kare `--inbox-shot=<rapor>` yok. **D ortak:** ∥D.

## C3b-4b · Kurucu görüşmesi akışı (satış/pazarlık PRD'si sonrası)

- Dokunulacak: `systems/negotiation_system.gd` (durum :36-52, `open` :91, `select_price` :154, `offer` :168, `accept_counter` :195, `walk` :202, `patience_spent` :209, `view_state` :237), `ui/meeting/sales_meeting_adapter.gd` (:103, :198-232, :238-253), `ui/meeting/meeting_ruler.gd`, `sales_system.gd`, `sales_finalizer.gd` (:27-39).
- PRD'nin silmeye karar vereceği (şimdi silinmez): `SEAT_PRICE_MIN/MAX` sconst:120-121 (`negotiation_system.gd:112-113`, `mn:4384/4387`), `PATIENCE_MIN/MAX` :136-137 (`rp:1427`), `RESERVE_SENSITIVITY_*` :138-139, `INSULT_MARGIN` :140, `COUNTER_STEP_*` :141-142, `PROMISE_BAND_NARROW` :144;
  `OUTCOME_INSULTED` negotiation_system.gd:28 (`sales_finalizer.gd:39`, adapter :253), `STATE_COUNTERED` :31; `--negotiation-shot=countered|last|insult` mn:4370-4385; `rp:1422-1436` (`_meet` pazarlık döngüsü). Vaka: `star_ruler_contract` m418/f11227, `b2b_pitch_meeting_signs` m142/f3569, `sales_concession_deal_surfaces` m231/f8561 (8 `NegotiationSystem` geçişi).
  Seri A masası (`TermSheetTableSystem`) `PATIENCE_ZERO` kullanır, `NegotiationSystem` seri A tipini oynatmaz: dokunulmaz.
- Kare `--negotiation-shot=open|confirm`. **D ortak:** ∥D.

## §S · PLAN_C_P2 ile HEAD'in tutmadığı yerler (plan DÜZELTİLMEDİ)

1. C3a-2 "9 hat × 3 = 27 mührü (`product_line_profiles`, `type_screen_matches_line_content`)": mühür `product_lines_catalog_loads` (sm f15075) ve `research_node_map_binds` (f16048) içinde; `product_line_profiles` yalnız 2/1/2 profil şekli; `type_screen_matches_line_content` mühür taşımaz.
2. C3b-2 "yalnız B2B'nin okuduğu `CORE_2`, `EMPHASIS_2`, `CORE_3`, `EMPHASIS_3`": B2C de okur (`pq:326-331` → `_star_value`); yalnız `REST_3`, `W_B2B`, `weights` B2B dalı B2B'ye özgü.
3. C3b-3 "iki `STAR_MAX` kopyasından biri (`product_quality.gd:21`)": `ProductQuality.STAR_MAX` sayfa-yıldızı merdiveni (B2C `_value` :336, `_audience_fit` :302, `serves/next_star` :156-168, `sc:695`); `SalesConstants.STAR_MAX` sconst:45 satış yıldızıdır.
4. C11a "`COMPOSITE_AXES`'in ERP satırı": `rival_catalog.gd:33`'te ERP satırı yok (alt-tür kimlikleriyle anahtarlı, ERP boş eksen = eşit karışım, sm yorum :25685); vaka `rival_composite_table` yalnız ERP beklenen kalitesini sabitler (:25674).
5. C11a "`_rival_ahead`'in sabit `true`'su": `vc_pitch_system.gd:1290-1295` kayıtlı rakiplerde `status == "DOMINANT"` arar; giant tier her koşuda DOMINANT (`rival_registry.gd:92-95`, `rival_catalog.gd:21`) olduğundan fiilen hep true.
6. C3b-4a "temsilci Satış'taki duruşla satar / temsilcinin duruşsuz fiyatı": temsilci zaten duruşla satar (`sales_rep_system.gd:156` `work_stance`, :265 `seat_price_anchor(lead.work_stance)`).
7. C8 "'Yenilemeyebilir' durumu": HEAD'de böyle bir durum/anahtar yok; `PHASE_TAGS` yalnız `risk`, `expansion`, `onboarding` (st:24-25) + `SALES_CHIP_HEALTHY` varsayılanı (:538); `Yenilemeyecek/Fesih bildirimi/Ayrılabilir` etiketleri (C0v) kodda yok.
8. §5/Sessiz 32 "`sales_ledger.gd:347-354`": HEAD `repitch_blocked` :346-348, `_blocker_cleared` :354-363 (`LOSS_WEAK_AREA` kolu :355-356; bilinmeyen kimlik `true` döner, :362).
9. Planda yazılı olmayan HEAD gerçekleri (eksik): C3a-1 `_target_on/_forgiven_trust/_account_owner/cs_dampen/satisfaction_bonus` (okuyucusuz kalır), `SIGNING_SAT_MIN` (sales_system.gd:371; plan C3a-1'de silinecek listede yok), `Customer.health` (okuyucusuz; B2C çağırır); C5-1 dosya listesinde `effects.gd`, `chips.gd`, `st:619-629`,
   `sprint_system.gd:482-489`, `seams_product.gd:273-274`, `lint.gd:359-391`, `seams_sales.gd:42`, `rp`, `mn:733/736/1557` yok; vaka listeleri C3a-1, C5-1, C3b-1, C6-1, C11a, C3a-2 için yukarıdaki adlarla eksik.
