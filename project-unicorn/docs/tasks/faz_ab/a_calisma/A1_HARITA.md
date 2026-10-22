# A1 · Bağlantı haritası (birleşik, A2 doğrulamalı)
HEAD `1faeb82`, 2026-10-16. Üç okuyucunun (A1a sistemler, A1b olay motoru/veri/kayıt/araçlar, A1c arayüz/belgeler)
haritası, A2'nin (Opus) kod doğrulaması ve tamlık süpürmesiyle birleştirildi. A2'nin değiştirdiği ya da eklediği her yer
**[A2]** ya da **[A2 düzeltme]** diye işaretlidir; ayrıntı ve gerekçe `A2_DOGRULAMA.md`'de. Satır numaraları HEAD'e
göredir; her dilim kendinden önceki dilimin kaydırdığı satırları yeniden bulur.

**Kodlayıcı yalnız kendi diliminin bölümünü okur**, sonra o bölümün gösterdiği katman satırlarına iner. Yürütücü notu
(`YURUTUCU_NOTU.md`) her dilimde geçerlidir.

## Dilim dizini

Kısaltmalar: C = `mvp_bugs_confirmed`, L = `mvp_live_bug_count`, O = yeni açık hata deposu, T = bilet defteri.
"Değişir" = vaka kod ya da beklenti değişikliği ister; "Yeni" = yazılacak vaka (falsifikasyonla); "Regresyon" = koşulur,
değişmesi beklenmez.

### K1 · Görevler matrisi sprinte bağlanır, kurucu (Karar 13)
**Kod dosyaları**
- `scripts/systems/sprint_system.gd`: `team()` 518-531 (iş süzgeci + pay; 527'deki `JOB_RESEARCH` denetimi süzgeçle
  gereksizleşir), `week_points` 507-512 (payı aynı yardımcıdan okur, bkz. yürütücü notu 14), `_points` 1290-1294,
  `capacity` 446-450, `_end_week` 720-746, `_restaff` 932-940, dinleyiciler 896-917. `_fits` 1272-1276 ve
  `founder_roles` **dokunulmaz** (zar ve D sınırı).
- `scripts/systems/hr_constants.gd`: `focus_mult` 184-185, `MAX_JOBS_PER_PERSON` 142 (salt okunur).
- `scripts/autoload/character_registry.gd`: `_validate_shape` kurucu kuralı 498-502 silinir; `assign_job` yorumu 220.
- `scripts/systems/hr_system.gd`: `founder_task_label` 221-237, `founder_task_state` 240-266 (260: Test tutan kurucu
  "Destekte" der).
- `scripts/tabs/product/product_model.gd`: ekip listesi ve pay 204, 268; boşta notu 251-254; "kimse yok" 260-263.
- `scripts/tabs/product/sprint_panel.gd`: `_nobody` 119-120, 172-189; ekip avatarları 93-102.
- `scripts/tabs/product/sprint_ui_shared.gd`: avatar ipucu 210-215 (payın görünür yeri).
- `scripts/tabs/hr/hr_assignments.gd`: başlık yorumu 7-8.
- `scripts/ui/office/office_people.gd`: 97 (`team()`), 454 (kurucu her açılışa yürür; değişmez, raporlanır), 666-672.
- `scripts/debug/run_probe.gd`: B2C kolu 1089-1098 (`clear_jobs` kalkar, Destek ikinci iş). Hotfix bloğu 1111-1117
  K2'ye kadar geliştiriciye ikinci iş verir.
- `scripts/debug/product_fixtures.gd`: `cap_zero` 106-110, `_team()` 554-562, yeni `edge:` fikstürleri;
  `scripts/main/main.gd` `edge:` yolu 3191; `docs/HARITA.md` Ürün görsel satırı (157) yeni adlar.
- `localization/strings.csv`: "sprintte kimse yok" metni (PRODUCT_TEAM_NOBODY 2835 yeniden ya da yeni anahtar) [TR/EN
  onay bekliyor].
- Otomatik izleyenler (kod değişikliği gerekmez, regresyonla doğrulanır): `plan_outcome` 566-580, `can_add`/`_takes`
  536-552, `mvp_eta` 590-629, `crunch_finishes` 648-660 (seam `urun.crunch_finishes`), `fits_plannable` 677-696,
  `role_of` 1260-1267, `pm_plans` (sprint_catalog.gd:483-506), `effects.gd:358-374` (`productivity_mod scope=team`),
  `support_system.gd` masa sayımı 194-238, `sprint_probe.gd` 186-201.

**Smoke**
- Yeni: `founder_not_double_counted` (§4.9; iki işli kurucunun kayıt ve yükleme turu dahil), matris vakası (§4.10).
- Değişir: `gorevler_has_no_founder` (13235; "tek iş" iddiası 13253-13255 gevşer, "satır yok" kalır),
  `job_assignment_and_idle` (10034), `hotfix_founder_takes_support_desk` (5183), `sprint_capacity_from_team` (17191),
  `productivity_mod_paces_the_sprint` (17235), `prep_bonus_and_capacity` (2566), `support_desk_rates_stack` (5303).
- Regresyon (A1b listesi): `hr_leave_cycle`, `hr_raise_and_leave`, `hr_active_filters`, `leave_does_not_pause_build`,
  `research_occupies_person`, `research_and_build_pause_each_other`, `research_freezes_and_resumes`,
  `sprint_ceiling_125_blocks_add`, `sprint_carry_keeps_progress`, `sprint_decision_blocks_progress`,
  `sprint_departure_restaffs_card`, `sprint_late_only_when_behind`, `promise_row_locked_when_no_room`,
  `product_pm_plan_opens_as_next_sprint`, `sprint_starts_only_with_consent`, `sprint_save_roundtrip`,
  `hotfix_account_count_excludes_base`, `owned_account_erodes_slower`, `founder_owns_accounts_manually`,
  `destek_survives_ship`, `destek_empty_desk_piles_up`, `split_bars_name_their_cause`,
  `paused_job_resumes_on_direct_return`, `sales_meeting_time_skip_founder_share`, `hr_read_catalogue`,
  `hires_land_in_own_column`, `overload_costs_output`, `effective_skill_formula`, `hr_overload_badge`,
  `founder_trains_and_learns`, `sprint_faulty_ticket_deterministic`.
- Regresyon **[A2 eklendi]** (sprint kuran ya da iş değiştiren, haritada yoktu): `sprint_solo_mvp_by_week_six` (18055),
  `sprint_lead_offers_paid_plan_b2c` (18044), `sprint_mvp_three_identity_k1`, `sprint_never_stalls_in_plan`,
  `sprint_paid_plan_opens_paid_tier`, `sprint_request_on_time_met`, `sprint_two_days_close`,
  `sprint_legacy_beta_cards_ship`, `sprint_decision_card_fires_shipped`, `product_paid_plan_locked_until_mvp`,
  `promise_due_sprint_kept_when_shipped_next_sprint`, `quiet_cards_fill_empty_floor`, `cheque_read_steps`,
  `event_history_chip_matches_live`, `b2b_onboarding_to_prospect_visible`, `save_double_load_no_residue`,
  `save_v14_build_becomes_sprint_plan`, `hotfix_weekly_summary_rows`, `research_abandon_keeps_progress`,
  `research_completion_no_economic_delta`, `hr_experience_accrues`, `hr_morale_drift_shape`,
  `sales_desk_deal_runs_its_plan`.

**Probe ve görsel**: `--sprint-probe=hours=40:cards=2:ticks=60:team=3:fill=1:events=1` (taban A1d: 245/251, 6 adlı, adsız
0); `run_gate.sh`; `full_run` **ve** `full_run_b2c` 104 hafta A1d tabanına karşı (iki koşu, bkz. yürütücü notu 15);
`--product-shot=live:plan`, `live:active`, `edge:cap_zero` + yeni `edge:` (Destek'te kişili ekip, boş sprint);
`--hr-shot=saatler-sprint`; `--office-shot=<ofis>:<saat>:desk_shut` boş masa karesi (§4.9).

### K2 · Hotfix, düzeltme koşusu, "Kaçırıldı", "Hata yığını" kalkar
**Kod ve veri**
- `scripts/systems/support_system.gd`: `FIX_COEF` 75, `REFUSAL_*` 94-97, `REPORTS_WEEK_NET` yazımı 128-129 ve 140,
  koşu boşaltması 130-133, `fix_per_day` 241-246, `fix_run_refusal`/`can_start_fix_run`/`start_fix_run`/`end_fix_run`
  308-348.
- `scripts/systems/product_state.gd`: 18-22 (`FIX_RUN_*`, `REPORTS_WEEK_NET`), `reports_missed` 168-169,
  `fix_run_active/fixed` 180-185.
- `scripts/events/core/effects.gd` 43, 439-442; `scripts/events/present/chips.gd` 44; `scripts/events/tools/lint.gd`
  323, 341; `scripts/events/seams/seams_sales.gd` 119-123; `scripts/autoload/event_bus.gd` 147-148.
- `data/events/cards/product/bug_pile.json` silinir; `tools/lint_v3_frozen.json:28`.
- `scripts/ui/components/build_bar_model.gd` 14-19, 32-34, 52-63, 72-73; `build_bar.gd` 21-22, 104-120, 151, 155,
  171-178; `scripts/tabs/product/product_model.gd:254` (`PRODUCT_IDLE_FIX`).
- `scripts/debug/run_probe.gd` 129-131, 1099-1122, 1173 (`_fixer_id`), başlık yorumu 1083-1085.
- `scripts/main/main.gd` 1220-1223 (başlık), `desk_shut` 1289-1294 yeniden kurulur (`REPORTS_WEEK_NET` satırı gider),
  `fix_run` 1295-1306 silinir. `scripts/systems/rnd_system.gd:136` yorum.
- `localization/strings.csv` 592-593, 1262-1263, 2840, 3054, 3094-3098.
- Üretilenler aynı commit'te: `docs/content/events_draft/_vocabulary.md` (`--event-vocab`),
  `docs/EVENT_SIGNAL_MANIFEST.md` (`python tools/gen_signal_manifest.py`).
- Kayıt: silinen kartın kuyruk/aktif/kâğıt satırları (queue.gd:217, 224; papers.gd:193) ve `FIX_RUN_*` bayrakları
  `_migrate_16`'da (K3) temizlenir; K2 yalnız kodu siler.

**Smoke**: Silinir `fix_run_ships_subset` (13466). Değişir `destek_survives_ship` (13194), `destek_empty_desk_piles_up`
(13411; falsifikasyon yorumu 13398-13410 dahil), `product_read_catalogue` (13699; §19 sinyal listesi 13744),
`save_v10_product_state` (14249), `event_beat_freezes_seams` (5854), `event_chip_coverage` (15158),
`_seed_support_fixture` (13377). Regresyon `paused_job_resumes_on_direct_return`. `hotfix_*` öneklerine dokunulmaz.

**Kapılar**: `--event-lint`, `loc_residue`, `loc_csv_integrity`, plausibility, `--run-log` B2B ve B2C 30 hafta,
`--office-shot=home:12:desk_shut`.

### K3 · Tek hata deposu, rastgele dağılım, şema 16 göçünün 1. kısmı
**Kod ve veri**
- `scripts/systems/product_state.gd`: yeni okuma/yazma (`open_bugs`, `open_bugs_by_line`, `line_bugs`, `add_bugs`,
  `clear_line_bugs`, `line_blocked`); C silinir (16, 163-164, 176-177); `axis_readings`/`axis_reading` 254-261 C yerine
  O (K5'te parametre kalkar).
- `scripts/systems/support_system.gd`: doğrulama 125-127 → her hata için tohumlu eşit hat seçimi + `add_bugs`; zarar
  273 C → O.
- `scripts/systems/sprint_bridges.gd`: `sync_tickets` 19-42, `close_tickets` 47-54, `add_faulty_ticket` 58-61,
  `_next_ticket_id` 239-241 silinir; başlık 4-9.
- `scripts/systems/sprint_system.gd`: `new_state` 82-85, `daily_tick` 31, `publish` 222-227, `_close` 1009-1012,
  1027-1042 (`releases` yüklemi 1032-1033, canlıdaki sessiz düşüş), `_go_public` 1102-1104.
- `scripts/systems/sprint_catalog.gd`: `tickets_by_line` 625-630 → `open_bugs_by_line`; okuyucular 146, 160, 261;
  `ticket_title` 201-203; `data/product/sprint.json:43` `ticket_titles`; CSV 2974-2976.
- `scripts/systems/rnd_system.gd` 595-606; `scripts/systems/product_read.gd` 37-38, 140-164;
  `scripts/events/seams/seams_product.gd` 90-91 (`urun.open_bugs`); `data/events/cards/customer/b2c_refunds.json:39`.
- Ara okuyucular C → O: `b2b_sales_system.gd:504`, `build_bar_model.gd:50`, `sales_ledger.gd:338`,
  `sales_meeting_system.gd:340`, `sales_probes.gd:62` (son üçü K5'te silinir), `quality_model.gd:228-245` (parametre).
- `scripts/autoload/event_bus.gd`: `line_bugs_cleared`; `bug_confirmed` 149 toplam O'yu izler.
- Tohum: `scripts/systems/rng_streams.gd` 18-20 (yeni akış) ya da `run_seed`'li hash (yürütücü notu 19).
- Kayıt: `scripts/autoload/save_manager.gd` 16 (`SCHEMA_VERSION` 16), 194-201 (zincir), yeni `_migrate_16` 1. kısım
  (T ve C → O, `gate_faulty` → `pending_faulty`, `FIX_RUN_*` ve `bug_pile` motor satırları); `_migrate_15` yorumu
  805-810; `scripts/autoload/game_state.gd` FLAG_TYPES 75, 77-79 + yeni anahtarlar, yorum 300-301.
- `scripts/main/main.gd:768` (`rnd_note_demand` fikstürü); `scripts/debug/run_probe.gd` 283-286, 532-539 (C).
- Üretilenler: `_vocabulary.md`, `EVENT_SIGNAL_MANIFEST.md`.

**Smoke**: Yeni `save_v15_tickets_become_open_bugs`, hat temizleme (§4.2), dağılım (§4.3, çok tohumlu). Değişir:
`sprint_fix_card_closes_tickets` (17484 → `sprint_fix_card_clears_its_line`), `sprint_faulty_ticket_deterministic` (17447
→ `sprint_faulty_bug_on_card_line`), `sprint_save_roundtrip` (17727), `rnd_note_author_and_lines` (15002),
`save_v10_product_state` (14249), `product_read_catalogue` (13764-13782), `infra_overage_applies_and_stops` (13601),
`sales_meeting_time_skip_founder_share` (15794), `b2c_satisfaction_drifts_to_experience` (11633),
`destek_survives_ship`, `destek_empty_desk_piles_up`, `event_beat_freezes_seams`. **[A2]** `_seed_support_fixture`
(13384 `LINE_TIERS {}`) ve `_seed_live_product` (697) hatsız canlı ürün kurar: hat kademesi eklenmeli.

**Kapılar**: lint, loc, `--sprint-probe`, `--event-vocab` + manifest.

### K4 · Düzeltme kartı: efor, etkilenenler, en büyük hesap, sürüm notu
**Kod ve veri**
- `scripts/systems/sprint_catalog.gd`: `area_alert` 143-150, `candidates` 261-269, `is_urgent` 284-285, `card_name`
  309-312, `card_effect` 347-354, `forecast` 378-403, `_clears_alert` 633-634, `_impact` 715-719; yeni `line_impact`
  `{accounts, seats, top_id, top_seats}`, hattı kullanan hesap listesi.
- `scripts/systems/sales_archetypes.gd`: yeni `uses_axis`, `USE_AXIS_MIN` (0,25, onay bekliyor); `axis_weights` 157.
- `scripts/systems/sprint_bridges.gd` 91-94 (arketip döngüsü ortak yüklemi kullanır), `actual_sentence` 195-210.
- `scripts/systems/sprint_system.gd`: kapanış 1009-1012, sürüm kaydı 1057-1064 (`bugs_before/after`, `faulty`),
  `_expected` 1108-1114, `_refresh_fix_cards` 1192-1201 (başlamamış kartın eforu yenilenir, koşanınki kilitli).
- `scripts/systems/sales_system.gd` 273-290 (B2C kullanıcı); `data/product/sprint.json` 6, 36, 42.
- `scripts/tabs/product/product_model.gd` 297-321, 411-419; `sprint_ui_shared.gd` 26-29, 287-327; `sprint_card.gd`
  80-94, 126-127, 191-192; `sprint_panel.gd` 128-130, 238-246; `product_fixtures.gd` 473-477 + yeni `edge:`.
- CSV 2847, 2854-2857, 2971, 2992-2995; yeni anahtarlar [TR/EN onay bekliyor]. B'nin girişi: hattın kartını sprinte
  koyan/başa taşıyan fonksiyon.

**Smoke**: Yeni `sprint_fix_preview_matches_close` (§4.6b). Değişir `sprint_fix_card_clears_its_line`,
`sprint_ceiling_125_blocks_add` (17304). Regresyon `promise_due_sprint_kept_when_shipped_next_sprint`,
`sprint_request_on_time_met`. **Probe/görsel**: `--sprint-probe`, `glyph_audit`, `edge:` (uzun hesap adlı kart, sürüm notu).

### K5 · Etki zinciri, aşınma ve L silinir, satış/VC kesimleri, itibar, bot kolları, göç 2
**Kod**
- Aşınma ve L: `product_system.gd` 15-28, 50-58, 65-101, 125-153 (+ ölü zincir 158-189, K8); `time_manager.gd` 381 (L
  örneği), 427; `sprint_system.gd` 1092-1094; `event_bus.gd:137` yorum; `product_catalog.gd` 81-164 `complexity` ve 255
  `get_feature_by_id` (K8'e kalabilir).
- Akış: `support_system.gd` 38, 164-176 (L terimi), 181-184 (`USAGE_DIV_B2B`, değer E1).
- Kalite okuması: `quality_model.gd` 40, 87-124, 160, 228-245; `product_state.gd` 254-261.
- Satış: `sales_system.gd` 27-33, 100-107, 180-204 (B2C hata terimi erozyonun yanına), 239-262, 405-468;
  `sales_meeting_system.gd` 128-142, 338-341, 409, 426; `sales_probes.gd` 62, 135, 143-152; `sales_ledger.gd`
  335-338; `sales_faucet_system.gd` 147-173.
- B2B: `b2b_sales_system.gd` 124-141 (hedef, yorum 130-132), 499-512 (`risk_voice`); `b2b_constants.gd:56`;
  `scripts/ui/components/inbox.gd` 208-213; `sales_tab.gd` 529-551.
- VC: `vc_pitch_system.gd` 489-505, 716-719, 731-744, 890-904, 1140-1152, 1190-1206, 1288-1308;
  `pitch_constants.gd:116`; `term_sheet_table_system.gd` 62, 546-552; `hunt_tab.gd:337`, `vc_meeting_adapter.gd:195`.
- İtibar: yeni haftalık yazar (`SupportSystem.daily_tick` önerisi), `game_state.gd:346-349` yorum; `top_bar.gd` 104,
  220 (negatif değer görseli).
- Kayıt: `_migrate_16` 2. kısım (L anahtarları, `mvp_bug_history`, `bugs_under`); `save_manager.gd` 723-725
  (`_migrate_14` kırpması), `game_state.gd` 61-63.
- Bot: `run_probe.gd` 72-85 (`fix` anahtarı), 153-197 (spec + sıfırlama), 283-286, 483-539 (505 **[A2]**), 837-872,
  1563-1570, 1585-1711 (fikstürler, 1711 yorum **[A2]**), `_founder_on_build`/`_is_free`/`_team_area_avg` ailesi;
  `save_manager.gd:320-353` ya da `ProductSystem.reset` zinciri (`fix_off`); `plausibility.gd` 140-161.
- Metin: CSV 144-146, 470, 482, 834, 1325-1326, 2489, 2516, 2519-2521 + yeni anahtarlar [TR/EN onay bekliyor];
  `founder_constants.gd:113`; `main.gd` 1044, 1113-1116, 1177 (satış fikstürleri).

**Smoke**: Yeni `neglect_reputation_below_zero`, `bugs_leave_sales_and_vc_alone`, `save_v15_callback_bugs_under`.
Silinir `conversion_bug_penalty` (12093), `coupling_wear_team_average` (7718), `sprint_release_resets_live_bugs` (17872).
Değişir `callback_contract` (1541), `pitch_bug_interrogation` (1580), `b2b_lifecycle_and_countdown` (3019),
`b2b_onboarding_grace_floor` (3077), `b2b_satisfaction_leaves_b2c_identical` (3141), `b2b_ignore_then_churn` (3289),
`b2b_cs_absorbs_routine` (3740), `coupling_cs_dampen_axis` (7761), `b2c_satisfaction_drifts_to_experience` (11633),
`risk_exit_stamps_day` (12314), `axis_reading_replaces_not_adds` (13918), `b2b_pitch_meeting_signs` (3357),
`sales_loss_reason_from_asked` (3576), `infra_local_provider_tradeoff` (13650), `prep_bonus_and_capacity` (2581-2590),
`save_v13_day_stamps_migrate` (2095; 2240-2241), `sprint_decision_blocks_progress` (falsifikasyon yorumu 17871),
`_seed_risk_account` (12253), `_seed_support_fixture`. **[A2 eklendi]**: `cs_renewal_floor` (19423; `risk_voice`),
`series_a_road_closed_when_all_funds_close` (2510-2517; Meridian'ın ürün geri dönüşü), `b2c_value_reads_live_lines`
(12148; `shipped_normalized`).

**Kapılar**: plausibility, `--sprint-probe`, `--event-lint`, 16 koşuluk matris (dört kol × iki pazar × tohum 7, 11).

### K6 · Hat paneli ve Destek kartı
- `scripts/tabs/product/area_panel.gd` 4-7, 10-27, 95-96, 116-130, 163-198, 226-236, 273-278;
  `product_model.gd` 23, 29-36, 132, 144-161, 183-194; `product_tab.gd` 7-8, 95-97, 212-216, 229-256;
  `quarter_view.gd` 43-60; `sprint_catalog.gd` 154-198 (`area_sentence`, `voices`); `sprint_system.gd` 376-378;
  `data/product/sprint.json:33` (`voices_new_weeks`).
- Destek kartı: `build_bar_model.gd` 24-31, 41-73; `build_bar.gd` 44-51, 87-102, 122-127, 147-166;
  `build_hud_panel.gd` 70-99 (tık/sürükle ayrımı); `window_layer.gd:140`.
- `main.gd` 1289-1294 (`desk_shut` son hâli), 3125-3129 ve 3192-3198 (`edge:voices_open`); `product_fixtures.gd`
  165-166, 202-206, 289, 359, 500, 519-534, 573, 599 + yeni `edge:`.
- `assets/icons/product/voices.svg`, `sprint_ui_shared.gd:12`; `build_theme.gd` 997-998 (`CountChip`).
- CSV 590-591, 2809-2813, 2826-2827, 2858-2859, 2929-2930, 2944-2945, 2960-2961, 2966-2967, 2977-2983.
- Smoke yok (görsel kabul); `fix_run_ships_subset` K2'de gitti. Kareler: B2B/B2C hat paneli, uzun liste, `desk_shut`.

### K7 · Sönük kart düğmeleri
- `scripts/tabs/product/sprint_card.gd` 17-19, 108-113, 142-144, 219-232, 315-320; `sprint_ui_shared.gd` 31-32,
  234-247; `scripts/theme/build_theme.gd` 974, 995-996, 1017-1020; `ui_tokens.gd:44` (`THEME_STAMP`); üretilen iki tema.
- Önce `git diff -- themes/` ve iki `.tres` yedeği `a_calisma/k7_tema_yedek/`'e. `project.godot`'a dokunulmaz.
- Kapılar: `theme_check.gd`, `--theme-contrast-audit`, `--product-shot=live:active`, `live:plan`.

### K8 · Ölü kod, belgeler, §4.1 grep kapısı, son kapılar
- Ölü kod: `product_system.gd` 23-28, 149-189 (`bug_trend`, `health_state`, `product_bug_risk`,
  `_shipped_total_complexity`); `game_state.gd:127` öneki; `product_catalog.gd` `complexity` + `get_feature_by_id`
  **[A2]**; CSV 1179-1181, 1194-1196, 1238, 1264 (`PROD_RISK_*`, `PROD_HEALTHY`, `PROD_RISKY`, `PROD_FLAT`,
  `PROD_TREND_*`) **[A2]**; 1239 `PROD_TIP_BUGS`.
- Belgeler (A1c §12 + **[A2]** ekleri): HARITA (39, 137, 142-158, 168 **[A2]**, 176-194, 210-213, 308, 359), CLAUDE.md
  (53, 95-96, 107, 145, 220-226), GUNCELLEMELER, motor md §27, ZAMAN MODELİ, glossary, FRANK_VOICE_INVENTORY,
  `hr_constants.gd` 14-17, ACIK_KARARLAR 38, 39, 43, 44, 45 ve **[A2]** 96 (alt maddeler), 97, 99, 59 (E1 sonucu),
  1569-1573; ISLER C-07, INT-9, **[A2]** 56-58 (hata trendi zinciri), 118; yeni VC notu (Karar 10).
- §4.1 grep: `scripts/ data/ tools/ localization/`; istisnalar `_migrate_16`, şema 15 vakaları ve `_migrate_15`'in
  `_BUILD_FLAG_PREFIXES` (save_manager.gd:813-814) satırı (gerekçeyle).
- Son kapılar: tam `run_gate.sh`, plausibility, lint, loc, glyph.

---

## Katman A · Sistemler (A1a)
HEAD 1faeb82, salt okuma, 2026-10-16. Kapsam: PRD §6 "Sistemler" (Destek, Sprint, Ekip, Ürün kalitesi, Sürüm notu ve köprü, Satış, B2B yaşam döngüsü, VC, İtibar, Kalite okuması, Ar-Ge, Zaman yöneticisi). Olay motoru, veri, kayıt, araçlar (A1b) ve arayüz, belgeler (A1c) kendi haritalarındadır; burada yalnız sistemin okuduğu ya da yazdığı yerle kesiştiklerinde "Not" sütununda anılır.

**Kısaltmalar.** L = `mvp_live_bug_count` (gizli canlı hata). C = `mvp_bugs_confirmed` (doğrulanmış hata). T = bilet defteri (`product.tickets`, `ticket_seq`, `voices_seen`). W = aşınma (`_post_ship_wear_hourly`). F = düzeltme koşusu (Hotfix). O = yeni tek hata deposu (hat başına açık hata; PRD Karar 1). Hat = `ProductLines` hat kimliği. "Yok" = PRD'nin andığı ama kodda bulunmayan kalem.

**Dilim sütunu.** PRD §8 ve K0 (Opus) nihai tablosuna göre: K1 Görevler matrisi + kurucu; K2 Hotfix/koşu/Kaçırıldı/Hata yığını; K3 tek depo, rastgele dağılım, şema 16 1. kısım; K4 düzeltme kartı; K5 etki zinciri, W ve L silinir, satış/VC kesimleri, itibar, bot, göç 2. kısım; K6 hat paneli + Destek kartı; K7 sönük düğmeler; K8 ölü kod + belgeler. PRD'nin sustuğu yerde dilim benim önerimdir ve "Not"ta belirtilir.

### 0. K0 keşfine göre kodda düzeltilen / eklenen bulgular
1. `_validate_shape` kurucu kuralı `character_registry.gd:498-502`'dedir (K0: 507-510). `add()` (438) ve `insert_raw()` (511) çağırır; yalnız `push_error`, engellemez.
2. Kurucunun başlangıç işi her zaman Yapım'dır: `_founder_start_area` yalnız product/design/engineering'e bakar (`game_state.gd:576-584`), `qa` aday bile değildir. Opus incelemesi madde 2(c) ("QA en yüksekse Test") kodda oluşamaz.
3. `ProductSystem._founder_on_build` Destek işindeki kurucuyu da "yapımda" sayar: alan aynası Destek için `engineering` ekler (`hr_constants.gd:121-131`, `areas_for_jobs` 211-232), `_founder_on_build` `engineering`'i arar (`product_system.gd:75-77`). Yalnız W'nin kullandığı K5'te silinecek bir kusurdur.
4. Hat seçen ayrı bir sahip kod yok: bugünkü "hat seçimi" `SprintBridges.sync_tickets` içindeki `hash("%d|ticket")` payıdır (`sprint_bridges.gd:32-41`). `SprintCatalog.bug_line()` (A_PLAN) kodda yoktur.
5. `damage_product` fiili yalnız bir liste dizgesidir (`effects.gd:43`); yürütücüsü yok. `critical_bug_unfixed` bayrağının (`game_state.gd:64`, `effects.gd:66`) okuyanı da yazanı da yok. `FLAG_TYPE_PREFIXES["bug_count_at_bugfix_start_"]` (`game_state.gd:127`) öksüzdür; `_migrate_15` onu zaten siler (`save_manager.gd:814`). Üçü A1b'nin konusu, burada not.
6. `validation_per_day` okur döngüsünde (`support_system.gd:235-237`) `role_of` etkin kip dışında hep "" döner (`sprint_system.gd:1261-1262`): plan ve sürüm notu kipinde bütün aktif çalışanlar "mail okur" sayılır.
7. `CustomerRegistry.get_by_market` yalnız `status == "active"` döner (`customer_registry.gd:66-73`); `"trial"` değeri kodda hiçbir yerde atanmıyor (`customer.gd:28` yalnız yorum). PRD Karar 6'nın "aktif ya da deneme" koşulu pratikte "aktif"tir.
8. `GameState.set_reputation` yorumu "sınırlar tasarım kararı bekliyor" der (`game_state.gd:347`); PRD Karar 10 −10'u geçerli sayar. Yorum K5/K8'de güncellenir.

---

### 1. Destek (`support_system.gd`, Destek bayrakları `product_state.gd`, `product_read.gd`)

| Kalem | Dosya:satır | Bugün (okur/yazar, ne yapar) | Yeni karşılığı (PRD kararı) | Dilim | Not |
|---|---|---|---|---|---|
| Akış formülü `reports_per_day` | support_system.gd:164-176 | Canlı değilse 0. (taban 0,2 / `self_service` ile 0,14 [167]) + 0,05 × L [172] + 0,03 × yeni kod × e^(−sürüm yaşı/3) [168-169, 173], × kullanım [176] × altyapı [176]. Okur: L, `NEW_CODE_EFFORT`, sürüm yaşı | Karar 2: akış bugünkü akışla kalır; L'li taşınan terim kalkar. Taban, yeni kod, kullanım, altyapı kalır; değerler A0/E1'den, onay bekliyor. Karar 11: hedefler iki ölçü | K5 | Yorum 170-171 ve başlık 8-26 bayatlar (K8). Yeni kod terimi düzeltme-only sürümde 0'lanır, bkz. Risk 4 |
| Taşınan hata katsayısı | support_system.gd:38 (`INFLOW_CARRIED_COEF`) | Yalnız satır 172'de kullanılır | Silinir (Karar 2: aşınma ve taşınan terim yok) | K5 | |
| Kullanım çarpanı | support_system.gd:181-184, 45-46 (`USAGE_DIV_B2C` 2000, `USAGE_DIV_B2B` 10) | B2B: 1 + aktif hesap/10 (`get_by_market("b2b")`); B2C: 1 + kitle/2000 (`SalesSystem.b2c_audience`) | Karar 11: B2B'de akış hesap sayısıyla daha yavaş büyür; bölen değeri onay bekliyor (A_PLAN önerisi 10 → 25, PRD sabitlemiyor) | K5 | Okuyucu `ProductRead.usage` (product_read.gd:52-53) → seam `urun.usage` (seams_product.gd:97-98); B2C bölenini A_PLAN E'ye bırakıyor |
| Saatlik akış → GELEN | support_system.gd:111-123 | Canlıyken `REPORTS_PROGRESS` birikir, tam sayı `REPORTS_INCOMING`'e eklenir (masa kapalı da olsa) | Karar 1/2: bildirim akışı hata kaynağının sayısını belirler; "Gelen" oyuncudan gizli (PRD §3 Destek kartı: "Doğrulanmış/Gelen yazısı yoktur"). Karar 9: mevcut destek zararı kalır, yani Gelen sayacı iç mekanik olarak kalır | K2 (kart metni), K6 | PRD Gelen'in kaderini açıkça yazmıyor; bkz. Risk 7 |
| Doğrulama GELEN → C | support_system.gd:125-127, `_drain` 381-394 | Doğrulanan her bildirim C'yi artırır; kesir `VALIDATION_PROGRESS`'te | Karar 1/3: doğrulanan her hata O'ya, uniform ve tohumlu rastgele canlı hatta yazılır (n hata = n bağımsız seçim); yazma `add_bugs(hat, n)` kapısından | K3 | `_drain` genel (sayaçtan sayaca); hat seçimi için ayrı yol gerekir. `VALIDATION_BANK_MAX` (support_system.gd:60, değer 1,0) değişmez **[A2 düzeltme: "60" satır numarasıydı]**. `add_bugs` bugün yok. **[A2]** `_seed_support_fixture` (endgame_smoke.gd:13384 `LINE_TIERS {}`) ve `_seed_live_product` (697) canlı ama hatsız ürün kurar: K3'te bu fikstürlerde düşecek hat yok |
| Doğrulama hızı `validation_per_day` | support_system.gd:230-238 (katsayı 233, `bug_tracker` 1,0 / 0,8; `SUPPORT_BASE_POINTS` 56) | `desk_roster` ∪ (aktif çalışan ve `SprintSystem.role_of == ""`) üzerinden `_area_sum`, müşteri başarısı alanı, taban 2,0 | Karar 13: "masa sayımı sprintle aynı payı okur; kimse iki yerde tam sayılmaz" | K1 | Sprint rolü olmayan okur dalı 235-237: `role_of` plan/sürüm kipinde hep "" (sprint_system.gd:1261-1262), yani o kiplerde Yapım/Test tutan herkes de okur. PRD bu dalı anmıyor; Risk 2. **[A2]** Plan/sürüm kipinde saat oyuncu planlayana dek çoğunlukla `HOLD_PLAN` ile tutulu (sprint_system.gd:1161-1164), dalın etkisi kısa pencerelidir |
| `_area_sum` tabanı | support_system.gd:253-259 (257: `maxf(points, floor_points)`) | Her okur en az `floor_points` (doğrulamada 2,0) sayılır; odak payı taban altında görünmez | Karar 13 / Kabul 4.9: "Yapım+Destek tutan kurucu iki yerde 0,5 sayılır" | K1 | Yazılımcı/tasarımcı müşteri başarısı alanını taşımaz (`can_hold_area`, hr_system.gd:388) → `effective_skill` 0 → taban 2,0 tam sayılır; kurucuda `CS puanı × 0,5` 2,0'ın altındaysa yine taban. Ölçütün neye bağlanacağı Risk 2 |
| Masa kadrosu `desk_roster` | support_system.gd:194-200 | `HRSystem.assigned_to_job(JOB_SUPPORT)` + pasif ilgideki kurucu | Karar 13: Yapım'daki kurucu masada sayılmaz (zaten sayılmıyor: kurucu yalnız Destek işi ya da pasif ilgiyle girer); Yapım+Destek kurucu 0,5 | K1 | Davranış bugün zaten Karar 13'ün masa yarısına uyar; K1'in masa kısmı çoğunlukla karakterizasyon testi (K0 k1-matrix, madde 2) |
| Pasif ilgi `founder_passive_care` | support_system.gd:212-218 | Canlı ürün + aktif kurucu + meşgul değil + `assigned_job_ids` boş | Karar 13: işi olmayan kurucu sprintte değildir, masada pasif ilgiyle sayılır | K1 | Okuyucular: desk_roster:196, hr_system.gd:264 (`founder_task_state` CARE), office_people.gd:671 (telefon animasyonu). Kural değişmez. **[A2]** Oyuncu yolunda işsiz kurucu doğmaz (kurucunun işi yalnız Yapım ↔ Ar-Ge değişir): bu dal bot, debug ve eski kayıtta yaşar |
| Masa dolu mu `desk_staffed` | support_system.gd:223-224 | `not desk_roster().is_empty()` | Karar 13 / Kabul 4.9: `destek.desk_staffed` Yapım'daki kurucu için false | K1 | Okuyucular: seams_sales.gd:117-118 (`destek.desk_staffed`), product_read.gd:90-91, build_bar_model.gd:63 |
| Düzeltme hızı `fix_per_day` | support_system.gd:243-246, `FIX_COEF` 75 | Koşu açıkken 1,2 × masadaki mühendislik | Karar 12: düzeltme koşusu ve kodu kalkar | K2 | `_area_sum` tabansız çağrısı (floor 0) yalnız bu fonksiyonda; onunla birlikte tek kullanım biter |
| Koşuyu başlat/bitir/ret | support_system.gd:308-348 (`fix_run_refusal` 308, `can_start_fix_run` 320, `start_fix_run` 325, `end_fix_run` 340), `REFUSAL_*` 94-97 | Koşu bayraklarını yazar; `EventBus.fix_run_started/finished` yayar (330, 347) | Karar 12: kalkar | K2 | Okuyucular: effects.gd:440-441 (`fix_run_start` fiili), seams_sales.gd:119-123, build_bar.gd:174-177, build_bar_model.gd:17-18,60-62, run_probe.gd:1104-1122, product_model.gd:254 |
| Koşu boşaltması | support_system.gd:131-133 | `_drain(FIX_RUN_PROGRESS …, C → FIX_RUN_FIXED)` her saat | Karar 12: kalkar | K2 | |
| Kaçırılan bildirim | support_system.gd:128-129 (saatlik yazım), 140 (günlük sıfırlama); product_state.gd:22 (`REPORTS_WEEK_NET`), 168-169 (`reports_missed`) | Haftalık net = gelen − doğrulanan | Karar 12: "Kaçırıldı" kalkar | K2 | Okuyucu build_bar_model.gd:52; main.gd:1289-1306 çekimleri yazar (`desk_shut` 1289-1294, `fix_run` 1295-1306) **[A2 düzeltme]** (`desk_shut` K2'de yeniden kurulur, `fix_run` çekimi silinir) |
| Günlük memnuniyet zararı | support_system.gd:269-274 (C: 273), sabitler 64-71 | GELEN × −0,6/10 + C × −0,3/10 + altyapı, tavan −2,0/gün | Karar 9: "var olan destek memnuniyet zararı kalır". C yerine O toplamı | K3 (C → O), değer K5 | Altyapı zararı (`InfraSystem.satisfaction_delta_per_day`, 274) tavanın içinde kalır, dokunulmaz |
| Zararın dağıtımı | support_system.gd:280-298 | B2B: aktif hesaplara eşit bölünür (285-286); B2C: kitle kaydına (287-290); kalıntı `_damage_residue` (104) | Değişmez. Karar 9'un asıl B2B kanalı hesap hedefidir (bkz. §7) | — | `_damage_residue` kayda girer (to_dict 150-151) |
| Isınma bandı `warmth_band` | support_system.gd:356-362, sabitler 79-83 | GELEN < 20 sakin, ≤ 40 ılık, üstü sıcak | PRD §6 `warmth_band` seam'ini listeler; Karar 12 anmıyor → varsayım: kalır | — | Okuyucular: seams_sales.gd:124-126, product_read.gd:155 (kenar sinyali), kartlar b2c_refunds, support_overflow, wiped_table. Risk 7 |
| İlgi `interest_now` | support_system.gd:368-371, daily_tick 143 | Yarı ömür 30 gün | Değişmez | — | `refresh_on_publish` (product_state.gd:215-218) her yayında 100'e tazeler; bkz. Risk 4 |
| Günlük tik | support_system.gd:136-143 | Zarar + ilgi; `REPORTS_WEEK_NET` sıfırlar | K2'de `REPORTS_WEEK_NET` satırı gider; haftalık itibar yazarı (Karar 10) A_PLAN'a göre buraya girer | K2, K5 | Yeni itibar yazarı bugün yok (bkz. §9) |
| Kayıt yönlendirme | support_system.gd:146-155; product_system.gd:41-47; save_manager.gd:341,373,389 | Yalnız `_damage_residue` kayda girer | Değişmez | — | `reset_all_owners` (save_manager.gd:320) `ProductSystem.reset` üzerinden `SupportSystem.reset` çağırır (341) |
| Saf bayrak: C | product_state.gd:16, 163-164 (`bugs_confirmed`), 176-177 (`adjust_confirmed`); game_state.gd:75 | C'nin tek evi | Karar 1: silinir; yerine O (`open_bugs`, `open_bugs_by_line`, `line_bugs`) | K3 | Yeni okuma/yazma yüzeyi (`open_bugs`, `add_bugs`, `clear_line_bugs`, `line_blocked`, `line_bugs_cleared` sinyali) kodda yok |
| Saf bayrak: F | product_state.gd:18-20, 180-185; game_state.gd:77-79 | `FIX_RUN_ACTIVE/FIXED/PROGRESS` | Karar 12 | K2 (kod), K3 (göç) | `FLAG_TYPES` kayıt temizliği A1b'de |
| Okuma yüzeyi C | product_read.gd:37-38 (`confirmed_open`), 140-164 (`_prev_confirmed`, `bug_confirmed` kenar sinyali) | C'yi okur; C artınca `EventBus.bug_confirmed` atar | Karar 1: O toplamı; seam `urun.bugs_confirmed` → `urun.open_bugs` (seams_product.gd:90-91) | K3 | `bug_confirmed` sinyalinin dinleyicisi yok (grep); §19 sözleşmesi. Adı ve manifest A1b'de |

### 2. Sprint (`sprint_system.gd`, `sprint_catalog.gd`, `data/product/sprint.json`)

| Kalem | Dosya:satır | Bugün (okur/yazar, ne yapar) | Yeni karşılığı (PRD kararı) | Dilim | Not |
|---|---|---|---|---|---|
| Sprint durumu `new_state` | sprint_system.gd:76-86 (tickets, ticket_seq 82; voices_seen 83; gate_faulty 85) | T alanlarını ve `gate_faulty`'yi taşır; `choose_type` (63) ve `_migrate_15` (save_manager.gd:882) çağırır | Karar 1: T silinir; `gate_faulty` → `pending_faulty` (A_PLAN) | K3, K6 (`voices_seen`) | `_migrate_16` v14'ten gelen `_migrate_15` çıktısında bilet bulunmayacağını hesaba katmalı (`get("tickets", [])`). `SprintSystem.reset` yok: durum `GameState.product`'ta (game_state.gd:876 `product.clear()`) |
| Günlük tik | sprint_system.gd:28-46 (31: `sync_tickets`; 33: `_refresh_fix_cards`) | Her tik defteri C'ye eşitler ve düzeltme kartlarını yeniler | `sync_tickets` silinir; kart yenileme O'dan, kural Karar 5/6 | K3, K4 | |
| **Sprint ekibi `team()`** | sprint_system.gd:518-531 (527: `fits.is_empty() or JOB_RESEARCH`; 529-530: puan, fits, ahead) | Aktif çalışan + aktif kurucu; yalnız Ar-Ge'dekini atar; işlere hiç bakmaz; puan `_points` (focus_mult yok) | Karar 13: yalnız Build/Test işi tutanlar. Pay: tek iş 1,0; iki sürekli işte 0,5 × (sprint işi sayısı) (Build+Test = 1,0; Build+Destek = 0,5; Destek tek = 0); Ar-Ge 0. Kurucu da aynı kural | K1 | Mevcut `HRSystem.assigned_to_job(JOB_BUILD/JOB_TEST)` aynı süzgeci (ACTIVE) taşır, kopya yazılmamalı (CLAUDE §8). Ar-Ge dışlayıcı iş diğer işleri duraklatır (character_registry.gd:221-232) → 527'deki JOB_RESEARCH denetimi gereksizleşir |
| Haftalık puan `_points`, `points_for` | sprint_system.gd:1290-1294, 1281-1286 | 2 × beceri bandı × verim × saat; kurucu sabit (`founder_mult`) | Pay çarpanı buraya ya da ortak yardımcıya girer (Karar 13) | K1 | `points_for` kişisiz puanı hr_atlas_modal.gd:343 da okur (iş yok varsayımı) |
| Kapasite `capacity()` | sprint_system.gd:446-450 | Σ team().points × sprint haftası | Matris payıyla; sprintte kimse yoksa 0 → plan bunu söyler, saat akar (Karar 13, 15) | K1 | Okuyucular: sprint_system.gd:152, 400, 537, 557, 591, 695, 970; sprint_catalog.gd:411, 440, 493; product_model.gd:203, 371; run_probe.gd:872; sprint_probe (A1b) |
| Kapasite anlık görüntüsü | sprint_system.gd:152 (`sprint.capacity`), 990 (`velocity.total`) | Başlangıçta dondurulur | Pay sonrası değişen kapasiteyi taşır; "düzeltme payı" ölçümü (Kabul 4.4) `capacity()` plan kipinde | K1 | |
| Mesai modalı `week_points` | sprint_system.gd:507-512; work_hours_modal.gd:217-218 | `team()` üyelerini gezer ama puanı `_points(c, taslak saat)` ile yeniden hesaplar | Karar 13: aynı pay | K1 | Pay yalnız `team()` çıktısına konursa bu fonksiyon onu atlar (Risk 5) |
| Aşama uyumu `_fits`, `ahead` | sprint_system.gd:1272-1276, 530; sprint.json:19, 23 | Kurucu: `founder_roles` (4 rol); çalışan: ana/ikincil alanın rolleri; `ahead` = ne dev ne test | PRD Karar 13 sınırı: "aşama uyumu bugünkü kuralla kalır", D'nindir | — (D) | Dokunulmamalı: iş tabanlı olursa %40 zarı çalışmaya başlar (§13) |
| `role_of` | sprint_system.gd:1260-1267 | Etkin kipte kişinin bu haftaki faz rolü, değilse "" | Semantik aynı; team() daraldığı için Destek-only kişi hep "" | K1 | Okuyucular: hr_system.gd:235, support_system.gd:236, product_model.gd:251, office_people.gd:667 |
| `assignees` yazımı | sprint_system.gd:754-781 (`_assign`), 932-940 (`_restaff`), 119 (`remove`), 317 (`decision_carry`), 1045 (`_close`) | Atama `team()` kişilerinden | team() daralınca kendiliğinden izler; ayrı değişiklik gerekmez | K1 | Okuyucular: sprint_system.gd:654-655, 730; sprint_card.gd:256; product_model.gd:229, 234 |
| Plan tahmini `plan_outcome`, `_play_out` | sprint_system.gd:566-580, 805-827 | `team()` ile kopyalarda oynatır; `_assign` ile aynı sıra | Karar 13 + Kabul 4.6: üç durumda (Destek-only, Yapım+Destek, geri alma) tahmin = kapanış | K1, K4 | `--sprint-probe` bu eşliği sınar (A1b). `plan_outcome` kartın hata sayısını ya da `faulty` zarını modellemez |
| "+" yüklemi `can_add`, `_takes` | sprint_system.gd:536-552 | Kapasite × `cap_ceiling` (sprint.json:25) ve `_play_out` boş puan | Matris payıyla otomatik | K1 | |
| MVP tahmini | sprint_system.gd:590-629 | `team()` ve `capacity()` okur | Otomatik | K1 | |
| Karar kartı geç/mesai | sprint_system.gd:634-660 | `team()` ile oynar; mesai ölçeği `t.points × scale` | Otomatik | K1 | `scope=team` `productivity_mod` ekibe aynı `team()`'i sorar (effects.gd:365-372) |
| Söz kilidi `fits_plannable` | sprint_system.gd:677-696 | `capacity()` − `used()` | Otomatik | K1 | |
| Plan bekleme / otomatik başlangıç | sprint_system.gd:394-401 (`awaits_plan`), 556-558 (`can_start`), 962-978 (`_auto_start`) | `capacity() == 0` iken tutuş yok, otomatik başlamaz | Karar 13/15: kimse yoksa plan söyler, Ekip'e bağlar, saat akar | K1 | `plan_next` yine koşar (966-969); sprint numarası ilerler. Metin ve Ekip bağı arayüzde (A1c) |
| Başlatma | sprint_system.gd:142-170 (152: kapasite, 168: `_assign`) | Atama team() ile | Otomatik | K1 | |
| Hafta sonu işi `_end_week` | sprint_system.gd:720-746 (722-724: `people` = team(); 731: yalnız team'de olan çalışır) | Hafta ortası Build'den çıkan o hafta işe yaramaz | Karar 13 + Opus 2(b): hafta ortası iş değişikliği Ekip'in gününde | K1 | Risk 5 |
| Ekip değişimi dinleyicileri | sprint_system.gd:896-917 | Etkin sprintte `assignment_changed` yalnız `_changed()` (915-917); `_restaff` yalnız `hr_day_processed` ve `character_removed` (897-899, 905-910); **[A2]** `employee_hired` ve `training_started` de yalnız `_on_assignment_changed`'e bağlı (901-902) | Aynı kural kapasiteye de uygulanmalı ya da `--sprint-probe` adsız uyuşmazlık verir (Kabul 4.6a) | K1 | `team()` canlı okunur, `assignees` ise Ekip gününde yenilenir |
| Atamada rol yavaşlığı ve hatalı kart | sprint_system.gd:787-798 (795-796: `faulty = true`), 1027-1028 (zar), sprint_catalog.gd:293 (`faulty`), sprint.json:28 (`faulty_chance` 0,4) | Test fazı Test rolü olmayanla yarı hızda yapılırsa kart işaretlenir; kapanışta 0,4 zar | Karar 3'ün tek istisnası: hatalı kapanışın hatası kartın hattına; yayın öncesi saklanır. Zar olasılığı D'nin | K3 (hat), D | §13: K1 zarı çalıştırmaz |
| Hatalı hatlar kuyruğu | sprint_system.gd:1006, 1028 (faulty listesi), 1036-1042 (`gate`, `gate_faulty`), 222-227 (`publish`), 1084-1104 (`_go_public`: 1103-1104 `add_faulty_ticket`) | Yayınlanan sürümde bilet doğurur; MVP kapısında kuyruğa gider; ürün canlı değilse ve kapanış MVP kapısı da değilse (`public` ve `gate` ikisi de false) `faulty` listesi hiçbir yere yazılmadan düşer. **[A2 düzeltme]** Aynı düşüş canlı üründe de olur: kapanış yalnız araştırma ya da bileti boşalmış düzeltme kartı çıkarıyorsa `public` false'tur (1032-1037) | Karar 3: hata kartın hattına `add_bugs(hat, 1)`; yayın öncesi `pending_faulty`'de saklanır, v1.0'da düşer (sessiz yok oluş kalkar) | K3 | Sessiz yok oluş dalı Karar 3 ile kalkar |
| Kapanış: düzeltme kartı | sprint_system.gd:1009-1012 (`SprintBridges.close_tickets(c.tickets)`, `closed += size`), 1032-1033 (`releases`: bileti boş düzeltme sürüm yapmaz), 1047 (`_refresh_fix_cards`), 1063 (`release.expected`) | Kart kapanırken kendi bilet listesini düşürür | Karar 5: kapanışta hattın o anki bütün açık hatası `clear_line_bugs(hat)` ile düşer; sürüm kaydına önce/sonra sayı (Karar 6 sürüm notu "6 → 0") | K4 | Sürüm kaydı kartın snapshot'ını saklar (1057, 1059): `bugs_before/after` alanı buraya girer. Kayıtlı eski `releases[].shipped[].tickets` dizileri okunabilir kalmalı |
| Sürüm yazımı `_go_public` | sprint_system.gd:1084-1104 (1093-1094: L sıfırlama; 1097: `refresh_on_publish`) | L her sürümle sıfırlanır | L silinir (Karar 2) | K5 | Düzeltme-only sürüm de `refresh_on_publish(0)` çağırır (ilgi 100, yeni kod 0); Risk 4 |
| `_refresh_fix_cards` | sprint_system.gd:1192-1201 | Başlamamış düzeltme kartının biletlerini defterden yeniler, boşsa siler | Karar 5/6: sayı her zaman canlı; koşan kartın eforu kilitli (Kabul 4.6c); 0 hataya düşen kart silinir | K4 | `start()` (129-135) ve `daily_tick` çağırır |
| `_expected` | sprint_system.gd:1108-1114 | Kapanan bilet sayısı cümlesi (`PRODUCT_RESULT_TICKETS_EXPECTED`) | "N hata kapanır / kapandı" (Karar 6, §3 Sürüm notu) | K4 | CSV anahtarları A1b/A1c |
| Düzeltme kartı oluşumu | sprint_catalog.gd:260-269 (`candidates`), 288-294 (`new_card`, `tickets: []` 292) | Bileti olan her yetenek için `fix:<hat>` kartı; efor 1 ya da acilse 2 (`effort.fix`, `fix_urgent`, sprint.json:6) | Karar 7: 1-2 hata 1 puan, 3-5 hata 2 puan, 6+ 3 puan; basamaklar ve acil eşiği `sprint.json`'da tek ayar | K4 | `fix_urgent` ayrı efor anahtarı basamaklara eriyecek (A_PLAN: silinir). D'de rol puanı ölçeği |
| Acil eşiği | sprint.json:36 (`urgent_tickets` 3); sprint_catalog.gd:148 (`area_alert`), 265-266 (efor), 275 (sıralama), 284-285 (`is_urgent`), 809 (zorunlu liste) | 3+ bilet = "Acil", alanda "!" | Karar 4: rastgele dağılımda çok acil kart doğmasın diye eşik ve zorunluluk yeniden ele alınır; "Acil" etiketi B'nin acil durumuyla karışmaz [TR/EN onay bekliyor] | K4 (tek ayar), K5 (kalibrasyon) | Okuyucu arayüz: product_model.gd:417 (`urgent`), sprint_card.gd:191, area_panel.gd:95 |
| Bot planlayıcının zorunlu listesi | sprint_catalog.gd:800-818 (`_suggest`: söz 800-805, istek 806, ücretli plan 807, en zayıf alanın en iyisi 808 [bu bir düzeltme kartı olabilir], acil düzeltmeler 809; tavan döngüsü 811-818) | Zorunlular `used + load ≤ capacity × 1,25` ya da boş sprintte ilk kart; sonra etki/efor | Karar 4: acil zorunluluğu yeniden ele alınır; Kabul 4.4: kollar düzeltme kartlarını önce ekler, kalan kapasiteyi lider doldurur | K4/K5 | Çağıranlar: `lead_suggestion` 410-411 (`apply_lead`, `_auto_start`), `pm_plans` 501. `SprintSystem.add` kartı `_takes` yüzünden reddedince bot sınırı bot tarafında aşmalı (PRD Kabul 4.4) |
| `pm_plans` | sprint_catalog.gd:483-506 (493: `capacity()`, 501: `_suggest`) | `team()`'i doğrudan okumaz; bağ yalnız `capacity()` ve `_suggest` | Otomatik (kapasite payı + yeni zorunlu liste) | K1, K5 | Çağıranlar: sprint_system.gd:348, 355, 364; product_model.gd:374 |
| Uyarı "!" `area_alert`, `_clears_alert` | sprint_catalog.gd:143-150, 633-634 | Bilet sayısı ≥ eşik ya da sunucu aşımı; `closed` kapanmış bilet kimlikleri | Eşik hat başına açık hata; `closed` parametresi hat temizleme semantiğine uyarlanır | K4 | `_close` (sprint_system.gd:1003, 1055) öncesi/sonrası karşılaştırır |
| Önizleme `forecast`, `card_effect`, `card_name` | sprint_catalog.gd:378-403 (383-384, 401-402), 347-354, 309-312 | Bilet sayısı ve kalkan "!" | "6 hata kapanır"; kartta hat, hata sayısı, hesap, kullanıcı, en büyük hesap adı ve koltuğu (Karar 6; `top_star` yok) | K4 | `line_impact` `{accounts, seats, top_id, top_seats}` yok |
| Etki puanı `_impact` | sprint_catalog.gd:715-729 (718-719); sprint.json:42 (`impact.ticket` 0,5) | Düzeltmede `ticket × n + alert` | `bug × n + alert` (aynı ağırlıklar) | K4 | |
| Bilet okuma `tickets_by_line` | sprint_catalog.gd:625-630 | Defter satırlarını hatta göre gruplar | Silinir; `ProductState.open_bugs_by_line()` | K3 | Okuyucular: sprint_catalog.gd:146, 160, 261, 634; sprint_system.gd:1194; rnd_system.gd:601 |
| Sesler ve alan cümlesi | sprint_catalog.gd:154-171 (`area_sentence`), 177-198 (`voices`), 201-203 (`ticket_title`); sprint_system.gd:376-378 (`voices_seen`); sprint.json:43 (`ticket_titles`) | Bilet başına "ses" başlığı; "N açık ticket" | Karar 12: Sesler ve "N ticket" kalkar; alan satırı "N açık hata" | K3 (veri), K6 (görünüm) | Alan cümlesi hatayla çelişmemeli (`PRODUCT_AREA_*_ENOUGH`) |
| Sprint süresi, çeyrek, rakip | sprint_system.gd:425-438 | Hata okumaz | — | — | |
| Doğrulama izleme | sprint_system.gd:710-711 (`worked`) → hr_system.gd:84 | Yapım deneyim bonusu | Karar 13 etkilenmez | — | |

### 3. Ekip (Görevler matrisi, iş/alan adaptörü, odak, kurucu, kayıt şekli)

| Kalem | Dosya:satır | Bugün (okur/yazar, ne yapar) | Yeni karşılığı (PRD kararı) | Dilim | Not |
|---|---|---|---|---|---|
| Tek yazıcı `assign_job` | character_registry.gd:193-245 (tavan 210-216; dışlayıcı yer değiştirme 221-232; yorum 220: "kurucu istisnası yoktur") | İş ekler; sürekli iş tavanı `MAX_JOBS_PER_PERSON`; araştırma diğer işleri duraklatır | Değişmez; kurucu iki işi tutabilir (Karar 13: Yapım+Destek) | — | Çağıranlar: hr_tab.gd:468, hr_assignments.gd:106-127 (UI kilidi 121), rnd_system.gd:304, run_probe.gd:1097,1116 |
| `unassign_job`, `clear_jobs`, `resume_paused_jobs` | character_registry.gd:288-298, 303-311, 261-285 | İş çıkarır; `assignment_changed` yayar | Değişmez | — | `assignment_changed` sprint için yalnız plan kipinde `_changed()` (sprint_system.gd:915-917) |
| Alan aynası `_sync_area_mirror` | character_registry.gd:315-318; hr_constants.gd:211-232 (`areas_for_jobs`), 121-131 (`JOB_AREAS`) | `assigned_jobs` işlerden türetilir. Destek işi `engineering` ve `customer_success` alanlarını yansıtır | Değişmez | — | Mirror okuyucuları: `HRSystem.assigned_to(area)` (hr_system.gd:275): ürün kalitesi `_team_area_avg`, Satış/CS (sales_faucet_system.gd:124, sales_rep_system.gd:41,136, sales_ledger.gd:71,346, customer_rep_system.gd:47) |
| İş/alan adaptörü `assign_area` | character_registry.gd:323-333; `unassign_area` 336-339; hr_constants.gd:190-206 (`AREA_PRIMARY_JOB`, `primary_job_for_area`, `default_job_for_role`) | Alanı birincil işe çevirir; tek çalışma zamanı çağıran debug fikstürü (main.gd:2801) | Değişmez. Yapım alanları → Build, qa → Test, customer_success → Destek, sales → Satış | — | `game_state.gd:981` kurucunun başlangıç işini de bu tablodan türetir; `add()` yeni işe alınanı `default_job_for_role` ile oturtur (character_registry.gd:445-448): her yeni geliştirici otomatik Build'dedir |
| `focus_mult`, sabitler | hr_constants.gd:142 (`MAX_JOBS_PER_PERSON`), 145-146, 184-185 | Tek iş 1,0; iki iş 0,5; yalnız `effective_skill` ve `output_mult_for_area` uygular (hr_system.gd:371, 393) | Karar 13: `team()` aynı payı okur | K1 | `MAX_JOBS_PER_PERSON` okuyucuları: character_registry.gd:215, 275; hr_assignments.gd:121; save_manager.gd:1095 (eski göç) |
| Kurucunun iki işi `_validate_shape` | character_registry.gd:468-502 (498-502: kurucu kuralı); `add` 438; `insert_raw` 511 | Yalnız `add()` ve `insert_raw()` (kayıt yükleme) koşturur; iki işli kurucuda `push_error` basar (`^ERROR:` kapılarda başarısızlık sayılır). Çalışma anında `assign_job` kurucuya ikinci işi verir, kural ancak yüklemede patlar **[A2 düzeltme: "ve kayıtta" değil]** | Karar 13: kural kalkar; Yapım+Destek tutan kurucu meşru | K1 | Yanındaki yorum (498-499 **[A2 düzeltme]**) ve `assign_job` yorumu (220) çelişiyor; kural gidince yorum da gider |
| Kurucunun başlangıç işi | game_state.gd:576-584 (`_founder_start_area`), 981-985 | Her zaman Build | Karar 13: "oyun başında kurucu Yapım'dadır; ilk sprint boş kalmaz" ile uyumlu | — | Opus 2(c) kodda yok (bkz. §0 madde 2) |
| Kurucu etiketi `founder_task_label` | hr_system.gd:221-237 (228-232: ≥ 2 iş "A · B"; 235-236: Build ama kart yoksa "Planlama yapıyor") | Etiket işlerden ya da `founder_task_state`'ten | Karar 13: sprintte kartı olan kurucu "Boşta" görünmez; işi olmayan kurucu masada pasif ilgi (CARE) | K1 | Okuyucular: hr_dossier.gd:143, personal_tab.gd:92, rnd_assign_panel.gd:182 |
| Kurucu durumu `founder_task_state` | hr_system.gd:240-266 (260: Destek ya da Test → SUPPORT; 264: CARE) | Sıra: eğitim, yatırım, Ar-Ge, Build, Satış/Hesap, Destek/Test, CARE, Boşta | Karar 13: Test tutan kurucu artık sprinte girer, ama etiket "Destekte" der | K1 | Seam `founder.task_state` (seams_hr.gd:181) aynı değeri okur; CSV `HR_FOUNDER_STATE_*` (strings.csv:445-451, 2552). Risk 6 |
| Bekleyen iş `job_waiting_key` | hr_system.gd:303-311 | Build/Test: tür seçilmediyse bekler; Destek/Hesap: canlı değilse | Değişmez | — | |
| `assigned_to_job`, `_on_duty` | hr_system.gd:280-293 | Aktif kişileri (kurucu dahil) işe göre döner | `team()` için yeniden kullanılacak okuma | K1 | |
| `job_count`, `is_overloaded`, `idle_count` | hr_system.gd:326-343, 298 | İş sayısı; 2 iş = aşırı yük (moral cezası hr_morale_system.gd:149, 220) | Değişmez | — | Kurucunun morali yok; Build+Destek çalışan morali etkilenir (PRD sustu, mevcut kural) |
| `effective_skill`, `daily_contribution` | hr_system.gd:381-397 (393 odak), 496-497 | Müşteri başarısı/satış/Ar-Ge masa sayımı | Karar 13: masa sayımı sprintle aynı payı okur | K1 | Okuyucular: support_system.gd:257, b2b_sales_system.gd:95, rnd_system research_per_day, sales_* |
| Kurucu hesap sahipliği | b2b_sales_system.gd:93-95, 116-121 (`_account_owner`) | `assigned_to == ""` hesapları kurucunun masasında; dampener `effective_skill(kurucu, CS)` tam odakla (iş yoksa `focus_mult(0)` = 1,0) | PRD sessiz | — | Risk 6 |
| İş anlamı satırı ve beceri metni | strings.csv:470 (`HR_AREA_MEANING_TESTER_QA`), 482 (`ONB_SKILL_QA_DESC`); founder_constants.gd:113; hr_constants.gd:15 (yorum) | "canlı hata aşınması" vaadi | Karar 12: vaat kalkar; Test'in canlı etkisi D'de döner [TR/EN onay bekliyor] | K5 | Yorum satırı 15 "beta keşif hızı" da eski (beta kanalı oyundan çıktı) |
| Karakter alanları | character.gd:59-64 | `assigned_job_ids`, `assigned_jobs`, `paused_job_ids` | Değişmez | — | |
| B2C bot kolunun varsayımı | run_probe.gd:1089-1098 | Kurucuyu `clear_jobs` + Destek yapar, "sprint puanı işini okumaz" varsayımıyla | Karar 13: varsayım çürür; kol yeniden kurulur | K1 (A1b) | `full_run_b2c` ve `run_gate.sh` etkilenir; ekonomi kayması K1 raporuna. **[A2]** Hotfix bloğu (run_probe.gd:1111-1117) B2B'de de bir geliştiriciye Destek'i ikinci iş verir: K2 gelene dek `full_run` da kayar |

### 4. Ürün kalitesi ve ürün durumu (`product_system.gd`, `product_state.gd`, `product_read.gd`)

| Kalem | Dosya:satır | Bugün (okur/yazar, ne yapar) | Yeni karşılığı (PRD kararı) | Dilim | Not |
|---|---|---|---|---|---|
| `_founder_on_build` | product_system.gd:71-78 (okuyan 86) | Kurucu serbest ve alan aynasında product/design/engineering var | Karar 2: aşınma kalkar → bu aile ölü. Karar 13 bağı sprint'te `team()` ile kurulur, burada değil | K5 (siler); K1 bağımlılık kurmaz | Tek çağıran `_team_area_avg` (86); onun tek çağıranı W (136). Destek-only kurucuyu "yapımda" sayan kusur (§0 madde 3) W ile gider. Smoke `endgame_smoke.gd:2581-2590` `_is_free`'yi doğrudan çağırır |
| `_is_free`, `_team_area_avg` | product_system.gd:65-66, 83-94 | Serbestlik ve alan uzmanlık ortalaması | Silinir (W ile) | K5 | hr_system.gd:149 yorumu "ProductSystem._is_free üzerinden" bayatlar (K8) |
| Aşınma `_post_ship_wear_hourly` | product_system.gd:125-146, sabitler 15-21 | Her saat L'yi artırır (kitle, karmaşıklık, Test uzmanlığı); `build_progress_changed` yayar (146) | Karar 2: kalkar | K5 | Tek saatlik emitter: Destek kartı ve HUD sinyali buna bağlı (build_bar.gd:49, build_hud_panel.gd:52); emitter `add_bugs/clear_line_bugs` olur (A_PLAN 4.6) |
| `hourly_tick` | product_system.gd:125-128; time_manager.gd:427 | Yalnız W'yi çağırır | W giderse fonksiyon ve TimeManager çağrısı gider | K5 | |
| Haftalık hata örneği | product_system.gd:50-58 (`daily_tick`: L → `mvp_bug_history`), time_manager.gd:381 | `bug_trend` / `health_state` için pencere | L ile gider | K5 | Eski göç satırı: save_manager.gd:723-725 (`_migrate_14`) |
| `live_bug_count` | product_system.gd:100-101 | L'nin tek okuma kapısı (19 okur satır, bkz. §6, §8, §10) | Silinir; okuyucular kesilir ya da O'ya gider | K5 | Okuyucu listesi: quality_model.gd:111; sales_system.gd:424, 467; support_system.gd:172; term_sheet_table_system.gd:549; vc_pitch_system.gd:1149, 1199, 1291; inbox.gd:211; product_system.gd:177, 184 |
| `bug_trend`, `health_state`, `product_bug_risk`, `_shipped_total_complexity` | product_system.gd:158-189, 149-153 | Oyunda hiçbir çağıran yok (grep); yalnız smoke | Karmaşıklık hesabı ve ölü kod silinir (Karar 2) | K5 (karmaşıklık, W ile), K8 (diğerleri) | `ProductState.is_feature_live`'in `mvp_components` okuması dokunulmaz (A_PLAN 5.6 K8) |
| Yayın sırasında tazeleme | product_state.gd:215-218 (`refresh_on_publish`) | Sürüm yaşı, ilgi, yeni kod terimi birlikte sıfırlanır | Karar 2 "yeni kod = son sürümle gelen değişiklik": düzeltme-only sürümde tanım belirsiz | K5 | Risk 4 |
| Eksen okumaları | product_state.gd:254-261 (C'yi QualityModel'e geçirir) | `axis_reading(…, bugs_confirmed())` | Karar 8/1: ham eksen; C parametresi kalkar | K3 (ara: O), K5 | bkz. §10 |
| `ProductRead` kenar sinyalleri | product_read.gd:153-185 | C, ısınma bandı, taban merdiveni, faz çıtası kenarları | C → O toplamı; `bug_confirmed` yeniden tanımlanır | K3 | Taban merdiveni (`axis_floor_state` 122-131) eksen okumasını kullanır: hata okumasından arınınca `b2c_floor_*` ve `launch_leak` kartlarının duyarlılığı değişir (A_PLAN 5.1 satır 6) |
| `market_word`, `axis_reading` seam'leri | product_read.gd:14-33; seams_product.gd:72-77 | Eksen okuması (Kararlılık −2 × C dahil) | Kararlılık okuması hata çıkarmaz | K5 | `urun.axis_stability` okuyan kartlar: b2c_floor_*, launch_leak, password_rule, shutdown_notice, b2c_creator_feature (A1b) |
| Destek masası boş mu (olay yüzeyi) | product_read.gd:90-91 | `SupportSystem.desk_staffed` | Karar 13 etkisi `desk_staffed` içinde | K1 | |

### 5. Sürüm notu ve köprü (`sprint_bridges.gd`, sürüm kaydı `sprint_system.gd`)

| Kalem | Dosya:satır | Bugün (okur/yazar, ne yapar) | Yeni karşılığı (PRD kararı) | Dilim | Not |
|---|---|---|---|---|---|
| `sync_tickets` | sprint_bridges.gd:19-42 | Defteri C'ye eşitler; yeni doğrulananlar hat ağırlığı (1 + kullanım ağırlığı) ve `hash("%d|ticket")` ile dağılır; koşunun erittikleri en eskiden düşer | Silinir. Dağılım: her hata bağımsız, eşit olasılıklı, tohumlu canlı hat (Karar 3) | K3 | Canlı hat = `line_tier(hat) > 0` (sync_tickets 27-31 ile aynı kapsam). Tohum: bkz. §12 ve Risk 8. Defter C'nin gerisinde kalabilir (Yürütücü notu 11): `_migrate_16` fazlayı canlı hatlara dağıtır |
| `close_tickets` | sprint_bridges.gd:47-54 | Kartın biletlerini defterden ve C'den düşer | `clear_line_bugs(hat)` (Karar 5) | K3/K4 | |
| `add_faulty_ticket` | sprint_bridges.gd:58-61; main.gd:768 (debug fikstürü) | Hatalı çıkış: kartın hattına bilet + C+1 | `add_bugs(kart_hattı, 1)`; yayın öncesi `pending_faulty` | K3 | |
| `_next_ticket_id`, başlık yorumu | sprint_bridges.gd:239-241, 4-9 | `ticket_seq` | Silinir; başlık "yalnız tickets, ticket_seq…" cümlesi güncellenir | K3, K8 | CLAUDE.md §6 WRITE-THROUGH satırı da aynı cümleyi taşır (A1c) |
| Talep arketip döngüsü | sprint_bridges.gd:72-109 (91-94) | Hesabın sektöründen arketip → alan → hat | Ortak `uses_axis` yüklemiyle aynı arketip tablosunu kullanır (A_PLAN 5.2); kopya kod yok | K4 | `SalesArchetypes.uses_axis`, `USE_AXIS_MIN` kodda yok |
| `on_release` | sprint_bridges.gd:115-119 | Karşılanan talep, sunucu kapasitesi | Hata okumaz | — | |
| Sonuç cümlesi `actual_sentence` | sprint_bridges.gd:195-210 (204-209: kapanan bilet) | v1.0: B2C kullanıcı; değişen alan; yoksa kapanan bilet; yoksa değişiklik yok | "N hata kapandı"; sürüm notunda gerçek sayı (Karar 6/§3) | K4 | Çağıran: sprint_system.gd:1124 (`_fill_actual`) |
| Basın satırı, eksen köprüsü | sprint_bridges.gd:141-163, 170-174 | Hata okumaz | — | — | `push_axes` ham eksenleri yazar |
| Sürüm kaydı `release` | sprint_system.gd:1057-1071 | `shipped` snapshot'ı, `carried`, `velocity`, `expected`, `alerts_cleared` | "Fatura düzeltmesi · 6 → 0 açık hata" için `bugs_before/after`; gerçek sayı, "9 → 0" (Karar 6, Kabul 4.6b) | K4 | Hatalı hatlar (sürüm kaydındaki `faulty`) B'nin adlı okuması (PRD §9 madde 4): bugün kayda yazılmıyor |
| Hat temizlendi sinyali | (yok) | `EventBus.line_bugs_cleared` yok | B'nin sözleşmesi (PRD §9 madde 5) | K3 | Yazma noktaları: `add_bugs`, `line_blocked`, düzeltme kartını sprinte koyan/başa taşıyan giriş (K4): hepsi yok |

### 6. Satış (B2B ve B2C) (`sales_system.gd` ve satış aileleri)

| Kalem | Dosya:satır | Bugün (okur/yazar, ne yapar) | Yeni karşılığı (PRD kararı) | Dilim | Not |
|---|---|---|---|---|---|
| B2C dönüşüm hata çarpanı | sales_system.gd:106-107 (`BUG_CONV_COEF/FLOOR`), 467-468 | Standing dönüşümü (1 − L × 0,02) ile çarpar (alt sınır 0,4) | Karar 8: satış hatayı okumaz → kalkar | K5 | |
| B2C memnuniyet itişi | sales_system.gd:32-33, 421-428 | L > 5 ise günlük −1 ek itiş; hedef deneyim ekseni | Karar 8/9: kalkar (uçurum), hata bedeli churn kanalıyla | K5 | `economy_dims_from_flags` hedefi deneyim eksenini okur ve L stabilite eksenini aşındırdığı için hedefe etkisi yok; çağrı `dims_from_flags()`'e döner |
| B2C kitle büyümesi | sales_system.gd:183-204 (`_audience_delta_per_hour`); 184: `shipped_normalized` (L'li), 188: itibar × 0,01, 204: erozyon terimi | Büyüme − `CHURN_COEF × max(0, 25 − kalite) × kitle` | Yeni hata terimi erozyon teriminin YANINA eklenir (Yürütücü notu 10): −`B2C_BUG_CHURN_COEF × min(max(0, O − 3), 40) × kitle` (A_PLAN 5.3; katsayı Karar 4'e uyar, onay bekliyor); `shipped_normalized` ham eksene döner | K5 | `growth_band` (528-538) aynı delta'yı okur: bant hata terimini de yansıtır |
| B2C kayıt tohumu | sales_system.gd:239-262 (`_ensure_b2c_record`, 243) | Deneyim eksenine göre tohum memnuniyet | L'siz | K5 | L deneyim eksenini aşındırmaz; yalnız çağrı adı değişir |
| İmzada açılış memnuniyeti | sales_system.gd:409-413 (`signing_satisfaction_seed`); çağıranlar sales_finalizer.gd:84, sales_rep_system.gd:238 | (kararlılık + deneyim)/2, stabilite L'li | Ham eksen (Karar 8) | K5 | |
| Ürün değeri / fiyat | sales_system.gd:433-441 (`product_value`, 439) | `shipped_normalized` (L'li) | Ham eksen (A_PLAN 5.1 satır 5) | K5 | `conversion_rate`, `apply_b2c_price`, `audience_growth_multiplier` dolaylı |
| Rakip kıyası | sales_system.gd:212-229 (`_rival_relative_quality`) | `shipped_normalized` girer | Ham eksen | K5 | run_probe.gd:476,537 de aynı çağrıyı basar |
| B2C kayıt zararı hedefi | support_system.gd:287-290; sales_system.gd:24 (`B2C_USERBASE_ID`) | Destek zararı kitle kaydına yazılır | Değişmez | — | `B2C kullanıcı tabanını tutan Customer aday değildir` (Karar 6): `market_type == "b2c"` süzer |
| Kullanıcı sayısı için B2C kaynak | sales_system.gd:273-290 (`b2c_audience`, `b2c_paying_users`) | Kitle ve ödeyen | Karar 6: kullanıcı = kitle × hattın payı | K4 | `line_share(hat)` kodda yok |
| Toplantı: ürün uyumu | sales_meeting_system.gd:128-142 (141) | Eksen okumasıyla uyum; Kararlılık okuması −2 × C içerir | Karar 8: hata okunmaz | K5 (QualityModel kesimi) | Kod değişmez; kaynak okuma değişir |
| Toplantı: kayıp nedeni | sales_meeting_system.gd:338-341 (340: `confirmed_bugs >= 3`) | "stability" nedeni hata sayısından da gelir | Karar 8: kayıp nedeni yalnız eksen | K5 | |
| Soru kataloğu | sales_probes.gd:62 (`confirmed_bugs`), 135 (kapı `confirmed_bugs max 2`), 143-146 (`probe_stability_bugs`) | "Açık hatalarınız var" sorusu | Karar 8: silinir | K5 | CSV `SALES_PROBE_PROBE_STABILITY_BUGS`, `SALES_ANS_*` A1c |
| Yeniden sunum kapısı | sales_ledger.gd:335-338 (`_blocker_cleared` STABILITY) | `axis_reading ≥ 55 and confirmed_open ≤ 2` | Hata terimi kalkar; yalnız eksen | K5 | |
| Ana kapı yıldız karışımı | sales_faucet_system.gd:147-161 (`star_mix_now`), 165-173 (`product_strength`) | Eksen okumasıyla yıldız payı kayar | Karar 8: ham eksen | K5 | Kod değişmez |

### 7. B2B hesap yaşam döngüsü ve şikâyet ailesi (`b2b_sales_system.gd`, `b2b_constants.gd`, `customer_rep_system.gd`, `inbox.gd`)

| Kalem | Dosya:satır | Bugün (okur/yazar, ne yapar) | Yeni karşılığı (PRD kararı) | Dilim | Not |
|---|---|---|---|---|---|
| Hesap memnuniyet hedefi | b2b_sales_system.gd:124-141 (`satisfaction_target`, `_target_on`; 136: `economy_dims_from_flags` → stabilite) | Hedef = ham stabilite skoru (L'li) + güven defteri; onboarding tabanı | Karar 9: hedef = ham stabilite + güven − `min(0,5 × b, 20)`; b = hesabın kullandığı hatlardaki açık hata; onboarding tabanı cezadan sonra (A_PLAN 5.3.7; sayılar onay bekliyor, Karar 4'e uyar) | K5 | `uses_axis` ve `account_bugs(hesap)` yok; kullanılan hat listesi B'ye de açık olmalı (PRD Karar 6 son madde) |
| Memnuniyet sürüklenmesi | b2b_sales_system.gd:73-107 | Hedefe sürüklenir, onboarding'de genlik büyük, sahip dampener | Değişmez | — | Kurucu sahipliği Risk 6 |
| Risk → sayaç → ayrılma | b2b_sales_system.gd:162-185 (`_tick_at_risk`), 202-220 (`_tick_healthy`), 234-250 (`_churn`, `_remove_lost`) | Var olan makine | Karar 9: hatanın B2B bedeli bu makineden geçer; makine değişmez | — | |
| Risk sebebi | b2b_sales_system.gd:499-512 (504: `bugs_confirmed() > COMPLAINT_BUG_GATE` veya sunucu aşımı); inbox.gd:210-213 (211: `live_bug_count() > COMPLAINT_BUG_GATE`) | İki ayrı kural (C ve L) ayrı yüzeylerde | Tek kural: hesabın kendi hatları eşiğin üstünde (A_PLAN 5.1 satır 9) | K3 (C → O), K5 | `COMPLAINT_BUG_GATE` 6 (b2b_constants.gd:56) hesap başına anlam kazanır. seams `musteri.risk_voice` (seams_ported.gd:74-76) ve `musteri.complaint_voice` (69-73) aynı fonksiyonları sarar |
| Şikâyet türü seçimi | customer_rep_system.gd:318-364 (`pick_request_kind`; şikâyet skoru 332-340) | Memnuniyet−tolerans farkı, kırık söz, güven, risk izi; hata sayısını okumaz | Değişmez; hata dolaylı olarak memnuniyetten girer | — | Şikâyet sesi sektöre göre `complaint_voice` (b2b_constants.gd:110-111) |
| Retention itibar deltaları | b2b_constants.gd:66-71 (`RETAIN_*_REP`) | Retention kartları `add_reputation ±1` taşır | Değişmez | — | itibar yazarları için §9 |

### 8. VC ve term sheet (`vc_pitch_system.gd`, `term_sheet_table_system.gd`, `pitch_constants.gd`)

| Kalem | Dosya:satır | Bugün (okur/yazar, ne yapar) | Yeni karşılığı (PRD kararı) | Dilim | Not |
|---|---|---|---|---|---|
| Tohum "ürün" sorgusu | vc_pitch_system.gd:1148-1151 (1149) | En zayıf eksen zayıf ya da `live_bug_count() > 0` → `how_big` | Karar 8: hata kalkar, yalnız en zayıf eksen | K5 | |
| Series A ürün sorgusu | vc_pitch_system.gd:1198-1206 (1199-1200: `bugs`) | L > 0 → "ürün hata kaynıyor" | Karar 8: silinir ("Nereden bilecek?") | K5 | Etki: `_beat3_diff` (1258) sorgu "clean" değilse zorlaşır; hata artık zorlaştırmaz. CSV `VC_Q_BUGS`, `VC_Q_BUGS_MONO` A1c |
| Geri dönüş yaratma | vc_pitch_system.gd:489-495 (493: `product` alanı → `bugs_under`); pitch_constants.gd:116 (`CALLBACK_BUGS_UNDER` 3) | Ürün fonu için "açık hata < 3" koşulu | Karar 8/Kabul 4.7: "En zayıf eksen > 40" | K5 | `_weakest_dimension` (1300-1308) "< 40" zayıf sayar; yani `>= 40` sağlanır, PRD "> 40" (eşitlik: Risk 9). **[A2]** Ölçek sorunu daha büyüktür: ham eksen 40'a varmaz (Risk 9, ACIK_KARARLAR 59) |
| Geri dönüş metni | vc_pitch_system.gd:499-505 (503: `HUNT_CB_BUGS`) | | Yeni koşul metni [TR/EN onay bekliyor] | K5 | Okuyucular: hunt_tab.gd:337, vc_meeting_adapter.gd:195 |
| Geri dönüş sınaması | vc_pitch_system.gd:890-902 (`_tick_callbacks`), 1288-1294 (`_callback_met`, 1291: `bugs_under`) | Günlük tik; `callback_ready` yayar | Yeni koşul türü | K5 | |
| Bekleyen geri dönüşün kaydı | game_state.gd:244 (`vc_states` → `callback`) | Kayıtta `{type: "bugs_under", target: 3}` taşınır | Göç 2. kısım: `bugs_under` → yeni koşul; kayıtta `bugs_under` kalmaz (Kabul 4.7) | K5 | `VCPitchSystem.reset` oturum durumudur (save_manager.gd:349); `vc_states` kayıtta |
| Itibar sorusu | vc_pitch_system.gd:1145 (tohum "insight"), 1193-1194 (Series A `reputation`) | `GameState.reputation < 0` | Karar 10: kalır; itibar artık negatife inebilir | K5 | Bugün itibar yalnız olay kartlarıyla oynadığı için nadiren negatiftir (§9) |
| Term sheet uyumu Meridian | term_sheet_table_system.gd:62 (`E_FIT_PRODUCT_BUGS` 6), 546-552 (549) | Canlı hata > 0 → −6, yoksa +6 | Karar 8: silinir | K5 | Diğer üç terim (yayında, eksen tabanı) kalır |
| Takip sorusu / anlaşmanın düşmesi | (yok) | | PRD §2.10: şimdi yapılmaz, `ISLER.md`'ye not | K8 | |
| VC'nin ekip okuması | vc_pitch_system.gd:1140-1141, 1178-1183; term_sheet_table_system.gd:540-542 | `count_developers`, `get_employees` (matristen bağımsız) | Değişmez | — | Matristen etkilenmez; başlık sayımıdır |

### 9. İtibar (`GameState.reputation` okuyucu ve yazarlarının tamamı)

| Kalem | Dosya:satır | Bugün (okur/yazar, ne yapar) | Yeni karşılığı (PRD kararı) | Dilim | Not |
|---|---|---|---|---|---|
| Alan ve sıfırlama | game_state.gd:34 (`reputation`), 786 (`initialize_run` → 0); SaveCodec GameState değişkenlerini kendisi bulur | int, 0 başlar | Değişmez | — | |
| Tek yazma kapısı | game_state.gd:346-349 (`set_reputation`: −10..100, `reputation_changed`) | Yazar: yalnız olay fiili | Karar 10: −10 geçerli (taban 0 yok) | K5 | Yorum "sınırlar tasarım kararı bekliyor" (347) güncellenir |
| Yazar: olay fiili | effects.gd:71, 240-241 (`add_reputation`), chips.gd:69, lint.gd:320 | 24 kart dosyası yazar: customer/{chargeback, leak_questions, named_in_leak, retention}, founder/friends_test, funding/{portfolio_vendor, portfolio_vendor_trial}, product/{b2c_floor_churn, bug_pile, launch_leak, outage, repeat_reminders, sprint_rewrite_bugs, sprint_rewrite_reader, sprint_unasked_rewrite, support_overflow}, rival/{copycat, copycat_reply, false_partner, funding_round, price_cut}, team/{outside_offer, password_rule}, world/final_stretch_comment | Değişmez; `bug_pile` K2'de silinir | K2 | |
| Yazar: hata kaynaklı | (yok) | Hiçbir sistem itibarı hatadan yazmaz (grep: yalnız `add_reputation`) | Karar 10: ihmal itibarı düşürür; sebep bir yüzeyde görünür (sürüm notu / haftalık özet / Destek kartı ipucu: ajan önerir) | K5 | Önerilen yer `SupportSystem.daily_tick` (haftalık, A_PLAN 5.3.9); kural ve eşik "onay bekliyor". Smoke `neglect_reputation_below_zero` |
| Okuyucu: B2C büyüme | sales_system.gd:52 (`HOURLY_AUD_REPUTATION_COEF` 0,01), 188 | Her itibar puanı saatlik büyümeyi artırır/azaltır | Kalır (Karar 10) | — | Negatif itibar kitleyi yavaşlatır |
| Okuyucu: VC | vc_pitch_system.gd:1145, 1193 | Bkz. §8 | Kalır | — | |
| Okuyucu: üst bar | top_bar.gd:104, 220 | `reputation_changed` ile yenilenir | Değişmez | — | |
| Okuyucu: olay seam'i | seams_finance.gd:23-24 (`finance.reputation`) | Okuyan kart yok (grep) | Değişmez | — | |
| Okuyucu: gazete | game_state.gd:676 (`get_run_ledger`), ending_scene.gd | Defter anahtarı yazılır | Değişmez | — | `reputation` anahtarını okuyan satır bulunamadı |
| Debug günlüğü | main.gd:485 | `TEMPO STATE rep=` | — | — | |

### 10. Kalite okuması (Kararlılık, `quality_model.gd`)

| Kalem | Dosya:satır | Bugün (okur/yazar, ne yapar) | Yeni karşılığı (PRD kararı) | Dilim | Not |
|---|---|---|---|---|---|
| Kararlılık aşınması `effective_stability` | quality_model.gd:40 (`BUG_STABILITY_COEF` 0,8), 92-93 | stabilite − 0,8 × L | Karar 8: ekonomi hata okumaz; silinir | K5 | Çağıranlar: quality_model.gd:111; product_system.gd:177; run_probe.gd:1655 |
| Ekonomi eksenleri `economy_dims_from_flags` | quality_model.gd:109-112 | Ham eksenler, stabilite L'li | `dims_from_flags` ile birleşir | K5 | Okuyucular: b2b_sales_system.gd:136; sales_system.gd:184 (dolaylı), 243, 410, 421, 439; quality_model.gd:124 |
| Birleşik kalite | quality_model.gd:117-124 (`shipped_normalized`, `shipped_composite`) | Kitle büyümesi, ürün değeri, rakip kıyası | Ham eksen | K5 | run_probe.gd:476,537 |
| Okuma bedeli `CONFIRMED_BUG_READING_COST` | quality_model.gd:160, 228-235 (234) | Kararlılık okuması −2 × C | Karar 8: kalkar | K5 | Okuyucular: toplantı ihtimali, ana kapı, `urun.axis_stability` kartları, taban merdiveni (bkz. §4, §6) |
| Okuma kapısı C parametresi | product_state.gd:254-261 | | | K3 (O'ya), K5 (kalkar) | |
| `realized_dims`, `axis_bar` | quality_model.gd:180-191, 251-256 | Hata okumaz | — | — | |

### 11. Ar-Ge (`rnd_system.gd`, `research_seam.gd`, `research_tree.gd`)

| Kalem | Dosya:satır | Bugün (okur/yazar, ne yapar) | Yeni karşılığı (PRD kararı) | Dilim | Not |
|---|---|---|---|---|---|
| Talep hattı oyu | rnd_system.gd:595-607 (`_demand_line`; 601-603: `tickets_by_line`) | Açık talep + açık bilet hat başına bir oy | `open_bugs_by_line()` (A_PLAN 5.1 satır 18) | K3 | Not metni kartı: rnd_note_demand (main.gd:739 yorum) |
| Araştırmacı dışlama | rnd_system.gd:13, character_registry.gd:221-232 | Sprint ekibi araştırmacıyı dışarıda bırakır; araştırma diğer işleri duraklatır | K1 sonrası `team()` Build/Test filtresi bunu kendiliğinden verir | K1 | `JOB_RESEARCH` kontrolü (sprint_system.gd:527) gereksizleşir |
| Freeze nedeni | rnd_system.gd:135-141 (yorum "a fix run stealing the person"), 344-355 (`freeze_note`) | `RND_PAUSED_BUILD` Build'e geçişte | Yorum K2'de bayatlar; davranış değişmez | K2, K8 | |
| Pratik düğümleri | support_system.gd:167 (`self_service`), 233 (`bug_tracker`); research_seam.gd:39-43 | Akış tabanı ve doğrulama hızı | Karar 2 akışı korur; ikisi kalır | — | `cicd` (`bug_rate_ceil`) ve `test_automation` (`beta_decay`) etkilerinin kodda okuyucusu yok (grep); A_PLAN 4.6 |
| Rnd başlık yorumu | rnd_system.gd:13-22 | "bug/effort in ProductSystem" der | Bayat (ProductSystem'de Ar-Ge katsayısı yok) | K8 | |

### 12. Zaman yöneticisi ve tohumlar (`time_manager.gd`, `rng_streams.gd`)

| Kalem | Dosya:satır | Bugün (okur/yazar, ne yapar) | Yeni karşılığı (PRD kararı) | Dilim | Not |
|---|---|---|---|---|---|
| Günlük dağıtım sırası | time_manager.gd:373-415 (381 `ProductSystem.daily_tick`, 384 `SprintSystem.daily_tick`, 385 `SupportSystem.daily_tick`, 387 `ProductRead.emit_edges`, 392 `HRSystem.daily_tick`, 393 `SalesSystem.daily_tick`, 411 `VCPitchSystem.daily_tick`) | Sprint hafta/kapanış → Destek zararı → kenar sinyalleri → HR → Satış (B2B hedef/B2C) → VC | Haftalık itibar yazarı (Karar 10) Destek tikinde, B2B hedefi ve B2C erimesi Satış tikinde; sıra korunur | K5 | Tik başına bir hafta; B2B hedefi hata sayısını sprint kapanışından sonra okur |
| Saatlik dağıtım | time_manager.gd:422-432 (427 `ProductSystem.hourly_tick`, 428 `SupportSystem.hourly_tick`, 430 `SalesSystem.hourly_tick`) | W, akış, B2C kitle | W gider (K5); akış ve B2C kalır | K5 | Toplu adım (gece, toplantı) saatleri yine tek tek koşar (`_run_batch` 189-200, `_step_hour` 142-158) |
| Kurucu toplantı payı | time_manager.gd:216-219 (`founder_output_factor`), support_system.gd:116 | Toplantı saatinde kurucunun masa payı | Değişmez | — | |
| Tohumlu akışlar | rng_streams.gd:18-20 (`skill`, `hr_morale`), 28-31 (`get_stream`: boyut denetimi), 69-77 (`from_dict`) | Hata dağılımı akış kullanmıyor; sprint içi zarlar `hash(str([...]))` (sprint_system.gd:842, 1027) | Karar 3: "tohumlu rastgelelik", hata başına bağımsız | K3 | Seçenekler: (a) yeni `RngStreams` akışı (`STREAM_IDS` genişler, eski kayıtta akış yok → `run_seed`'den başlar, kayıtta saklanır); (b) `run_seed` + kalıcı hata sıra sayısı hash'i (akışsız). Karar bekliyor (Risk 8) |
| Hat seçimi kapsamı | sprint_bridges.gd:27-31 | `ProductLines.line_ids(subtype)` ve `tier > 0` | Karar 3: "canlı özelliği olan hat", eşit olasılık | K3 | Gizli (Ar-Ge) hatlar `line_ids` içinde ama açılana dek kademe 0. **[A2]** `cap_paid_plan` `line_ids`'te yok, hata almaz; kademesi > 0 olan her hattın bir alanı var (sprint.json `areas`, `SprintCatalog.capabilities` 62-71), yani her hatanın düzeltme kartı doğabilir |
| Koşu sıfırlama | save_manager.gd:320-355 | `RngStreams.reset()` son sıra (353); `SprintSystem` girişi yok | Yeni statik durum (ör. `fix_off` debug anahtarı) buraya ya da `run()` sıfırlamasına girmeli | K5 (A1b) | PRD §6 "reset_all_owners" satırında SprintSystem/ProductState için literal giriş yok |

---

### 13. Bilinen gerçek: %40 hatalı kapanış zarı K1'den sonra atılmaya başlar mı?

**Cevap: HAYIR.** (A2 kodda yeniden doğruladı: `A2_DOGRULAMA.md` §3.) K1 (sprint ekibi = yalnız Build/Test işi tutanlar, pay `focus_mult`, kurucu sprint işi tutmayabilir) zarı çalıştırmaz. Zar bugün de atılmıyor, ama PRD'nin gerekçesi ("kurucu her rolü tutuyor") bağlayıcı olan mekanizma değil.

Kod yolu (sırayla):
1. Hatalı işaret: `SprintSystem._work` (sprint_system.gd:787-798). `speed = 1.0 if _role(c, at) in person.fits else no_role_speed` (791); `if at == TEST_PHASE and speed < 1.0: c.faulty = true` (795-796).
2. Zar: `_close` (sprint_system.gd:1027-1028): `c.faulty and hash(str([c.id, number])) % 1000 / 1000 < faulty_chance` (sprint.json:28 = 0,4); isabet `faulty` listesine, oradan `_go_public` (1103-1104) ya da `gate_faulty` (1041-1042).
3. Test fazını kim yürütür: `_assign` (754-781): `able` = serbest kişiler, süzgeç `(at == 0 or not p.ahead) and (p.ahead or i < cards.size())` (765-766). `ahead = not (fits.has("dev") or fits.has("test"))` (530). Yani 1. ve 2. fazları (geliştirme, test) yalnız dev ya da test rolüne uyanlar yürütebilir; tasarımcı ve ürün yöneticisi (`ahead`) yalnız 0. fazı yürütür.
4. `fits` nereden gelir: `_fits` (1272-1276). Kurucu: `sprint.json:23` `founder_roles = [product, design, dev, test]`, işlere hiç bakmaz. Çalışan: `can_hold_area(rol, alan)` ile rolün ana ya da ikincil alanı (hr_constants.gd:253-260; `ROLE_AREAS` 86-95): geliştirici {engineering, qa} → dev + test; test uzmanı {qa, engineering} → test + dev; tasarımcı {design, product} ve ürün yöneticisi {product, design} → `ahead`; satış ve müşteri temsilcisi → `fits` boş, `team()` dışı (527).
5. Sonuç: Test fazında çalışabilen herkes (geliştirici, test uzmanı, kurucu) `test` rolüne zaten uyar → `speed == 1` → `faulty` hiç true olmaz. Kurucu olmadan da bu doğrudur (geliştirici ikincil alanı qa).
6. K1 `team()`'i yalnız süzer ve pay uygular; `_fits` ve `founder_roles` değişmez (PRD Karar 13 sınırı) → yukarıdaki zincir aynen sürer. Kurucu sprinte hiç girmezse de ekipte yalnız çalışan kalır ve yine hepsi `test`'e uyar.
7. Kanıt ters yönden: smoke `_case_sprint_faulty_ticket_deterministic` (endgame_smoke.gd:17447-17478) zarı çalıştırmak için `founder_roles`'u `["product","dev"]`'e düşürür (17451) ve tasarımcı işe alır (17449); "ekipte Test rolü olan biri var" ise fikstürü reddeder (17453). Yani zar yalnız test sabiti değiştirilince çalışır.

Uyarılar (K1 raporu için):
- K1 `_fits`'i iş tabanlı yaparsa (ör. "Test rolüne yalnız Test işi tutan uyar") her Build-only çalışan ve kurucu için Test fazı yarı hızda koşar ve kartların %40'ı hatalı kapanır: büyük ekonomi kayması; D'nin işidir. K1'de smoke'ta "`_fits` job'tan bağımsız" iddiasını sabitlemek ucuz bir korumadır.
- Yalnız tasarımcı/ürün yöneticisinden oluşan bir sprint ekibi (kurucu Build'den çıkmışsa) `capacity() > 0` verir ama geliştirme fazını yürütecek kimse olmadığından kartlar sprint boyunca ilerleyemez; zar değil, tıkanma. Risk 3.

---

### 14. Kodda olmayan kalemler (PRD listesinde anılan ya da planın dayandığı)
1. `SalesArchetypes.uses_axis`, `USE_AXIS_MIN`: yok (sales_archetypes.gd'de `sectors`, `axis_weights`, `ids` var; yüklem yok).
2. `ProductState.add_bugs / clear_line_bugs / open_bugs / open_bugs_by_line / line_bugs / line_blocked / snapshot_open_bugs`: yok.
3. `EventBus.line_bugs_cleared`: yok. `SprintCatalog.bug_line / line_impact / line_accounts / line_share`: yok. `B2BSalesSystem.account_bugs`: yok.
4. Hat seçimi için tohumlu akış: yok (`RngStreams` yalnız `skill`, `hr_morale`).
5. Hata kaynaklı itibar yazarı: yok (§9).
6. `damage_product` fiilinin yürütücüsü: yok. `critical_bug_unfixed` yazarı ve okuyanı: yok.
7. `SprintSystem.reset` / `reset_all_owners` içinde SprintSystem girişi: yok (durum `GameState.product`'ta).
8. `_migrate_16`: yok (zincir `<11`, `<13`, `<14`, `<15`: save_manager.gd:194-201); `SCHEMA_VERSION` 15 (save_manager.gd:16).
9. `product.pending_faulty`: yok (bugünkü ad `gate_faulty`).
10. Bot kolları (`fix`, `PROBE FIX`, `fix_off` anahtarı): yok (A1b).

### 15. Açık sorular / riskler (en çok 10)
1. **Zar ve `_fits` (kritik).** K1 `_fits`'e dokunmamalı; aksi halde %40 zar sessizce çalışmaya başlar (§13). Karakterizasyon testi önerilir.
2. **Masa sayımı ölçütü.** Taban (support_system.gd:257, 2,0) ve sprint rolü olmayan okur dalı (235-237) yüzünden "iki yerde 0,5" yalnız roster üyeliği ve `desk_staffed` ile anlamlı ölçülür, puanla değil; ayrıca plan ve sürüm kiplerinde (`role_of` hep "") Yapım tutan her çalışan masada "mail okur" sayılır. PRD "kimse iki yerde tam sayılmaz" diyor, bu dalı anmıyor: bırakılacak mı, `team()` payına mı bağlanacak?
3. **Yalnız `ahead` ekip.** Kurucu Build'den çıkınca ekip yalnız tasarımcı/PM'den oluşabilir: kapasite > 0, geliştirme fazını kimse yürütemez (sprint_system.gd:765-766). `can_start`/`awaits_plan` bunu yakalamıyor; "sprintte kimse yok" metninin kapsamına girer mi?
4. **Düzeltme-only sürümün yan etkisi.** `_go_public(n, 0, …)` düzeltme sürümünde `NEW_CODE_EFFORT`'u 0'lar (önceki özelliğin sönen akış terimini siler) ve ilgiyi 100'e tazeler (product_state.gd:215-218, sprint_system.gd:1097). Karar 2'nin "yeni kod = son sürümle gelen değişiklik" tanımı ve hata sprintinin maliyeti K5 kalibrasyonunda bunu hesaba katmalı.
5. **Pay yalnız `team()`'de olmamalı.** `week_points` (sprint_system.gd:509-511) ve `points_for` (hr_atlas_modal.gd:343) puanı `team()` dışından yeniden hesaplar; ortak yardımcı yoksa mesai modalı ve işe alım dosyası eski değeri gösterir. Hafta ortası iş değişikliğinde `team()` canlı, `assignees` Ekip gününde yenilenir (sprint_system.gd:896-917): adsız `--sprint-probe` uyuşmazlığı riski.
6. **Etiket ve sahiplik tutarsızlıkları.** Test-only kurucu "Destekte" etiketi alır (hr_system.gd:260); `_founder_on_build` Destek-only kurucuyu "yapımda" sayar (K5'te gider, K1 ona bağımlılık kurmamalı); kurucunun sahibi olduğu B2B hesaplarında dampener iş sayısına bakmadan tam odakla uygulanır (b2b_sales_system.gd:95).
7. **Gelen / ısınma / `destek.*` seam'leri.** Karar 12 yalnız koşu, Kaçırıldı ve kart metinlerini siliyor; PRD §6 `warmth_band` ve `desk_staffed`'i listeliyor ama kaderini yazmıyor. `unconfirmed_threshold_crossed` sinyali, `support_overflow`, `wiped_table`, `b2c_refunds` kartları bu mekanikte yaşıyor. Gelen sayacı "gizli iç mekanik" olarak kalıyor varsayıldı.
8. **Hat dağılımı için tohum yöntemi.** Yeni `RngStreams` akışı (kayda girer, `STREAM_IDS` boyutu `get_stream`'in yeniden tohumlama denetimini etkiler: rng_streams.gd:29) ya da `run_seed` + kalıcı hata sıra sayısı hash'i. Eski kayıtların ve `--run-log` bayt-determinizminin korunması için karar gerekir. **[A2 düzeltme]** (a) kayıt uyumludur: `RngStreams.from_dict` kayıtta olmayan akışı `run_seed`'den kurar (rng_streams.gd:67-70), `get_stream`'in boyut denetimi (29) ondan sonra tutar. Bugünkü hatalı kart zarı (sprint_system.gd:1027) `run_seed` okumaz, tohumlar arasında çeşitlenmez. Ayrıca aday hesap listesi için `get_by_market` yeterli (yalnız "active"; "trial" kodda yok).
9. **VC geri dönüş eşiği.** `_weakest_dimension` "< 40" zayıf sayar (vc_pitch_system.gd:1308), PRD "En zayıf eksen > 40" yazıyor: tam 40'ta fark var. Bekleyen `bugs_under` kaydı `GameState.vc_states` içinde (game_state.gd:244), göç 2. kısmı onu dönüştürmeli. **[A2, PLAN ETKİSİ]** Asıl sorun ölçek: `_weakest_dimension` HAM eksenleri (`dims_from_flags`) okur ve ACIK_KARARLAR 59'a göre ham eksen hat modelinde 40'a neredeyse hiç varmaz (760 haftalık probe'da en yüksek 33,3). Koşul bu ölçekle kurulursa Meridian'ın (ürün alanlı tek fon, investor_registry.gd:61-65) geri dönüşü hiç karşılanmaz, `callback_unmet` kilidi kalkmaz ve `series_a_road_closed` (vc_pitch_system.gd:742) yolu hiç kapanmış saymaz. Ölçek E1'de Erdem'e sorulur.
10. **Acil kural ve bot zorunlu listesi.** `_suggest`'in zorunlu listesi acil düzeltmelerin hepsini kapasite × 1,25'e kadar alıyor (sprint_catalog.gd:809, 811-818). Rastgele dağılımla 3+ hatalı çok hat doğunca bu liste sprinti düzeltmeyle doldurur (Karar 4'ün hedefi tersi); eşik ve zorunluluk birlikte E1'e girmeli. `fix_urgent` ayrı efor anahtarı basamaklara (Karar 7) eridiğinde `is_urgent` yalnız etiket ve zorunluluğu taşır.

### A2 · Bu katmana eklenen satırlar (tamlık süpürmesi)

| Kalem | Dosya:satır | Bugün (okur/yazar, ne yapar) | Yeni karşılığı (PRD kararı) | Dilim | Not |
|---|---|---|---|---|---|
| Ürün kataloğunun `complexity` alanı | product_catalog.gd:81-82 (yorum), 83-164 (`complexity` değerleri), 255 (`get_feature_by_id`) | Tek okuyucu `_shipped_total_complexity` (product_system.gd:149-153). Yorumdaki "ürün değerine (fiyat) girer" yanlış: `product_value` (sales_system.gd:433-443) okumaz | Karar 2: karmaşıklık hesabı silinir → `complexity` anahtarları ve `get_feature_by_id` ölür | K5 (W ile) / K8 | `FEATURE_POOLS` kimlikleri Satış'ta yaşar; yalnız `complexity` anahtarı ve tek okuyucusu gider |
| `build_progress_changed` yorumu | event_bus.gd:137 | "ProductSystem's hourly wear moved the live bug counters" | Yayan `add_bugs`/`clear_line_bugs` olunca yorum değişir | K5 | Manifestin bölüm başlığı değil, sinyal yorumu |
| `GameState.product` yorumu | game_state.gd:300-301 | "SprintBridges writes only tickets, ticket_seq, requests and rival_hits" | Köprü bilet yazmaz | K3 | CLAUDE.md §6 (95-96) aynı cümleyi taşır (K8) |
| Satış hata yorumları | sales_system.gd:27-30, 100-105, 180, 434-436, 455-457 | Hata kanallarını anlatır (L itişi, dönüşüm, `effective_stability`) | Kanallarla birlikte güncellenir | K5 | Yorum kuralı: yalnız bugünkü neden |
| B2B hedef yorumu | b2b_sales_system.gd:130-132 | "bugs already folded into effective stability ... no separate bug subtractor" | Hesap başına hata terimi gelince yanlış olur | K5 | |
| Meridian'ın ürün geri dönüşü | investor_registry.gd:61-65 (`meridian`, `domain: product`); vc_pitch_system.gd:731-744 (`series_a_road_closed`), 716-719 | Ürün alanlı tek fon Meridian'dır; "callback" statüsü yolu açık sayar | Koşul karşılanamazsa yol hiç kapanmaz | K5 | **PLAN ETKİSİ** (ACIK_KARARLAR 59, A2_DOGRULAMA §5.1) |
| Ar-Ge vaat metni | strings.csv:2248 (`PROD_RND_NODE_CICD_UNLOCK`), 2273 (`_DISCOVERY`); rnd_tree.json:24 (`bug_rate_ceil`) | "geliştirmeden daha az hata çıkıyor" der; etkinin okuyucusu yok | Karar 12'nin saydıkları arasında değil; A dokunmaz | — (R notu) | Test vaadine benzer karşılıksız oyuncu metni; Karar 2 yeni kod terimiyle bağlanabilir, sahip kararı |
| Hata trendi zincirinin CSV'si | strings.csv:1179-1181, 1194-1196, 1238, 1264 | `PROD_RISK_*`, `PROD_HEALTHY`, `PROD_RISKY`, `PROD_FLAT`, `PROD_TREND_*` okuyucusuz; fonksiyonlar id döner | Girdileri (L, `mvp_bug_history`, `effective_stability`, karmaşıklık) K5'te silinir; zincir çalışamaz | K8 | ISLER.md:56-58 sahibin tuttuğu "yeniden yuva" listesinde; silme gerekçesi R'de |
| Kurucunun iş değiştirme yolu | rnd_system.gd:292, 304, 360; character_registry.gd:261-285 (`resume_paused_jobs`); hr_tab.gd:466-468 yalnız çalışan satırı | Oyuncu kurucunun işini yalnız Ar-Ge ile değiştirir; araştırma bitince Yapım geri gelir | Karar 13'ün işsiz ve Yapım+Destek kurucusu oyuncuda doğmaz (bot, debug, eski kayıt) | K1 (bilgi) | E1'e soru (A2_DOGRULAMA §5.3) |
| Hatsız canlı ürün fikstürleri | endgame_smoke.gd:697-709 (`_seed_live_product`, ai_assistant), 13377-13395 (`_seed_support_fixture`, `LINE_TIERS {}`); run_probe.gd:108-109 | Canlı ürün, hiç canlı hat yok | Karar 3'ün "yayında hat yokken" dalı yalnız burada oluşur; oyunda canlı ürün en az üç kimlik hattıyla çıkar | K3 (smoke), K5 (probe fikstürleri) | Yürütücü notu 20 |
| Sprint kapanışında canlı üründe sessiz düşüş | sprint_system.gd:1032-1042 | Kapanış yalnız araştırma ya da bileti boşalmış düzeltme kartı çıkarıyorsa `public` false: hatalı kartın hatası düşer | Karar 3: hatalı kapanışın hatası kartın hattına | K3 | `releases` yüklemi bilet kalkınca yeniden yazılır |

---

## Katman B · Olay motoru, veri, kayıt, araçlar (A1b)
HEAD `1faeb82`. `scripts/`, `data/`, `tools/`, `localization/` HEAD ile aynı (ağaçtaki fark yalnız `project.godot`, iki tema, izlenmeyen belgeler). Salt okuma.
Kaynaklar: PRD §6, YURUTUCU_NOTU, K0_KESIF (satırlar yeniden açılarak doğrulandı; sapmalar "Not" sütununda), A_PLAN §5, A1d taban kaydı.

**Kısaltmalar.** C = `mvp_bugs_confirmed` (`ProductState.bugs_confirmed()`). L = `mvp_live_bug_count` (`ProductSystem.live_bug_count()`). O = yeni açık hata deposu. "Karar N" = PRD §2 madde N. Dilim = PRD §8 / PLAN_A (K1 matris + kurucu · K2 Hotfix/koşu/Kaçırıldı/Hata yığını · K3 tek depo, dağılım, göç 1 · K4 düzeltme kartı · K5 etki zinciri, aşınma ve L, kesimler, itibar, bot kolları, göç 2 · K6 hat paneli + Destek kartı · K7 sönük düğmeler · K8 ölü kod + belgeler).
**Yeni API adları** (`ProductState.open_bugs`, `open_bugs_by_line`, `line_bugs`, `add_bugs`, `clear_line_bugs`, `line_blocked`, `open_bugs_delta`, `snapshot_open_bugs`, `EventBus.line_bugs_cleared`, `SprintCatalog.line_impact / line_accounts / line_share / bug_line`, `SalesArchetypes.uses_axis`, `USE_AXIS_MIN`, `_migrate_16`) A_PLAN §5.2 ve PRD'den alınmıştır; bugün kodda YOKTUR (bkz. §9). PRD ile çelişen A_PLAN parçaları (haftanın hattı, `top_star`, itibar tabanı 0, `fix_all`) kullanılmadı.

### 0. Doğrulama notları (K0 ve PRD'ye düzeltmeler)
1. **`urun.axis_stability` okuyan kartlar PRD §6'dan dardır.** Yalnız `launch_leak` (`launch_leak.json:39`) ve `password_rule` (`password_rule.json:82`) `urun.axis_stability` okur. `b2c_floor_churn` (`:40`), `b2c_floor_signal` (`:51`), `shutdown_notice` (`:63`), `b2c_creator_feature` (`:48`) `urun.floor_stability` okur; o da aynı `axis_reading`'den türer (`product_read.gd:122-133`). Etki aynı, seam adı farklı.
2. K0'ın `_validate_shape` satırı yanlış: kural `character_registry.gd:500-502` (K0: 507-510).
3. `mvp_reports_week_net` `GameState.FLAG_TYPES`'ta yok (`game_state.gd:48-122` taranır); silmek için yalnız `ProductState.REPORTS_WEEK_NET` (`product_state.gd:22`) gider.
4. `damage_product` fiili `effects.gd:43` listesinde ama `_apply`'da kolu yok; `critical_bug_unfixed` bayrağının (`effects.gd:66`, `game_state.gd:64`) okuyanı/yazanı yok. İkisi de "hata" kelimesiyle grep'e takılır, A'nın konusu değil (bkz. §2).
5. `ProductSystem.bug_trend / health_state / product_bug_risk` ve `_shipped_total_complexity` için smoke'ta bile çağrı yok (`endgame_smoke.gd` grep: yalnız `_is_free` 2581-2590). A_PLAN §4.6'daki "yalnız smoke" ifadesi bayat.
6. `USAGE_DIV_B2B` bugün 10 (`support_system.gd:46`); YURUTUCU_NOTU 5 uyarınca 25 sabit değildir.
7. `musteri.risk_voice` seam'i de hatayı okur (`seams_ported.gd:74-76` → `b2b_sales_system.gd:504`); PRD §6 listesinde yok, §1'e eklendi.

---

### 1. Olay motoru · seam'ler
| Kalem | Dosya:satır | Bugün (okur/yazar, ne yapar) | Yeni karşılığı (PRD kararı) | Dilim | Not |
|---|---|---|---|---|---|
| `urun.bugs_confirmed` | `seams_product.gd:90-91` | Okur: `ProductRead.confirmed_open()` (`product_read.gd:37-38`) → `ProductState.bugs_confirmed()` (`product_state.gd:163-164`) = C. Okuyan kartlar: `bug_pile.json:27` (≥12, gövde jetonu `:73,:85`), `b2c_refunds.json:39` (≥8). Smoke taklidi: `endgame_smoke.gd:5856,5862` | `urun.open_bugs` = `ProductRead.open_bugs()` = `ProductState.open_bugs()` toplamı (Karar 1; A_PLAN 5.2) | K3 | Ad değişir: `--event-lint` (bilinmeyen seam hatası) + `--event-vocab` + manifest aynı commit'te. Eşik 8 aynı kalır (A_PLAN 5.1 s.19). `bug_pile` K2'de silinir, yani K3'te tek kart etkilenir |
| `urun.worst_line_bugs` (YOK) | — | Kodda yok | Yeni: en çok hatalı hattın sayısı (A_PLAN 5.2; PRD §9 madde 4 "hat dökümü") | K3 | B'nin girdisi; PRD R raporunda adlı okuma noktası olarak listelenecek |
| `urun.bugs_unconfirmed` | `seams_product.gd:92-93` | `ProductRead.unconfirmed()` → `ProductState.reports_incoming()` (`product_state.gd:159-160`). Okuyan: `repeat_reminders.json:70` (≥6), `support_overflow.json:123,:133` (gövde jetonu) | Değişmez (A_PLAN 5.1 sonu: hata sayısına bağlanmayan). Gelen bildirim sayacı doğrulama hattı olarak kalır; yalnız Destek kartında gösterilmez (PRD §3) | — (K3 doğrulama borusunu O'ya bağlar, seam sabit) | `USAGE_DIV_B2B` değişimi (K5) `repeat_reminders` penceresini (`version_age == 1`, B2B) kaydırır |
| `urun.axis_stability` | `seams_product.gd:74-75` | `ProductRead.axis_reading("", "stability")` → `ProductState.axis_reading` (`product_state.gd:259-261`) → `QualityModel.axis_reading(..., bugs_confirmed())` (`quality_model.gd:228-236`): Kararlılık okumasından her C için 2 puan düşer (`CONFIRMED_BUG_READING_COST`, `:160`). Okuyan: `launch_leak.json:39` (<10), `password_rule.json:82` (<10) | K3: C yerine `open_bugs()` (A_PLAN 5.6 K3). K5: −2/hata terimi silinir (A_PLAN 5.1 s.6; Karar 8 ile uyumlu), okuma ham eksen olur | K3 → K5 | İki kart hata duyarlılığını kaybeder; PRD Karar 8 bu iki kartı adıyla saymıyor (bkz. §10 madde 7). `plausibility_run.sh` K5'te koşar |
| `urun.floor_stability` | `seams_product.gd:83-85` | `ProductRead.axis_floor_state("stability")` (`product_read.gd:122-133`) aynı `axis_reading`'den; taban B2B 40 / B2C 20 (`product_read.gd:111-114`). Okuyan: `b2c_floor_churn.json:40` (==crossed), `b2c_floor_signal.json:51` (!=""), `shutdown_notice.json:63`, `b2c_creator_feature.json:48` (ikisi de !=crossed koruması) | Aynı K3/K5 yolu. K5'ten sonra tabanın altına hata yüzünden inilmez | K3 → K5 | Sinyaller de buradan: `axis_floor_warning/crossed` (`product_read.gd:170-176`, `signals.gd:37-38`); kart tetikleri `b2c_floor_signal.json:34`, `b2c_floor_churn.json:28`. B2C'de Kararlılık tabanı (20) hata terimi olmadan nadiren aşılır: iki kartın Kararlılık dalı kuruyabilir |
| `urun.support_staffed` | `seams_product.gd:107-109` | `ProductRead.support_staffed()` (`product_read.gd:90-91`) → `SupportSystem.desk_staffed()` | Aynı seam; anlam Karar 13'le `desk_roster` üzerinden (Yapım'daki kurucu masada değil, Yapım+Destek 0,5) | K1 | Okuyan kart yok (`data/events` grep: 0) |
| `urun.usage` | `seams_product.gd:97-98` | `SupportSystem.usage_multiplier()` (`support_system.gd:181-184`, B2B bölen `:46`) | `USAGE_DIV_B2B` akış ayarı (E1/A0'dan, onay bekliyor; YURUTUCU_NOTU 5) | K5 | Okuyan kart yok. Karar 11'in "B2B'de akış hesap sayısıyla daha yavaş büyür" mekanizması |
| `urun.crunch_finishes` | `seams_product.gd:60-62` | `SprintSystem.crunch_finishes()` (`sprint_system.gd:648-660`) `team()` okur (`:658`) | Karar 13: `team()` yalnız Yapım+Test, pay `focus_mult` | K1 | Karar kartı `product.sprint_late`'in fazla mesai seçeneğini besler; `sprint_late_only_when_behind` (`endgame_smoke.gd:18320`) |
| `urun.sprint_*`, `urun.decision_card*` | `seams_product.gd:34-58` | `SprintSystem.sprint_number/week/mode/decision_*`; `team()`/`capacity()` doğrudan okumaz | Değişmez | — | `crunch_finishes` hariç hiçbir seam kimin sprintte olduğunu açmıyor: B'nin "kâğıdı kim konuşur" kuralı için yeni seam ya da `SprintSystem.team()` çağrısı gerekir (B'nin işi) |
| `destek.desk_staffed` | `seams_sales.gd:117-118` | `SupportSystem.desk_staffed()` (`support_system.gd:223-225`) = `desk_roster()` boş değil (`:194-203`); kurucu `founder_passive_care()` (`:212-220`) yalnız işi yoksa girer. Okuyan: `bug_pile.json:32`, `support_overflow.json:46` (==false), smoke `endgame_smoke.gd:5857,5866,5868` | Aynı seam. Karar 13: Yapım'daki kurucu masada değil (bugün zaten böyle), Yapım+Destek kurucu `effective_skill` ile 0,5, işsiz kurucu pasif ilgiyle. Masa tarafı bugün Karar 13'e uyuyor (K0 §2) | K1 | Yalnız karakterizasyon testi ve `_validate_shape` düzeltmesi gerekir |
| `destek.warmth_band` | `seams_sales.gd:124-126` | `SupportSystem.warmth_band()` (`support_system.gd:356-364`), `reports_incoming` 20/40 eşikleri (`:79-80`). Okuyan: `b2c_refunds.json:44`, `support_overflow.json:41`, `wiped_table.json:71` (!= calm) | Değişmez (gelen sayacı kalır) | — (K5 akış etkisi) | `USAGE_DIV_B2B`/aşınma silinmesi (K5) akışı, yani üç kartın ateşleme oranını kaydırır; plausibility K5 |
| `destek.can_start_fix_run` | `seams_sales.gd:119-121` | `SupportSystem.can_start_fix_run()` (`support_system.gd:320-322`). Okuyan: `bug_pile.json:48` (`requires`) | Silinir (Karar 12) | K2 | `_vocabulary.md:147` satırı gider |
| `destek.fix_run_active` | `seams_sales.gd:122-123` | `ProductState.fix_run_active()` (`product_state.gd:180-181`). Okuyan: `bug_pile.json:37` | Silinir (Karar 12) | K2 | `_vocabulary.md:149` |
| `musteri.risk_voice` | `seams_ported.gd:74-76` | `B2BSalesSystem.risk_voice` (`b2b_sales_system.gd:499-510`): `bugs_confirmed() > COMPLAINT_BUG_GATE (6, b2b_constants.gd:56)` ise şikâyet sesi. Okuyan: `retention.json:173,:189` (gövde jetonu); `plausibility.gd:374` `_is_generic_voice` | A_PLAN 5.1 s.9: hesabın kendi hatları > 6 (tek kural) | K5 | Seam adı değişmez, değeri hesaba göre değişir. `inbox.gd:211` `risk_reason` aynı kurala geçer (arayüz katmanı) |
| `hr.job` | `seams_hr.gd:83-87` | `assigned_job_ids[0]` (yalnız İLK iş). Okuyan: `sprint_rewrite_bugs/owner/reader.json:47/47/51`, `sprint_unasked_rewrite.json:33`, `named_in_leak.json:38` (`== "build"`) | Karar 13 iki işli kişiyi sprintte 0,5 sayar; seam ilk işe bakmaya devam eder | K1 | Kopukluk: Destek+Yapım tutan geliştirici sprintte sayılır ama ilk işi Destek ise bu kartların "build" seçicisini geçmez (bkz. §10 madde 3) |
| `hr.is_idle`, `hr.idle_count`, `founder.task_state` | `seams_hr.gd:60-62, 135-137, 180-182` | `HRSystem.is_idle` (`hr_system.gd:298`), `idle_count` (`:338`), `founder_task_state` (`:240`); etiket `founder_task_label` `SprintSystem.role_of` okur (`hr_system.gd:235`). Okuyan: `support_overflow.json:56`, `closing_docs*.json:47-52/59-64` | Karar 13: sprintte kartı olan kurucu "Boşta" görünmez; state sırası (eğitim, hazırlık, Ar-Ge, yapım, satış/hesap, destek/test, CARE, idle) kurucunun sprint payıyla tutarlı | K1 | Kart etkisi yok; `founder.task_state == build` (support_overflow) Yapım'daki kurucuda geçer |
| `finance.reputation` | `seams_finance.gd:23-24` | `GameState.reputation` (kenetli −10..100). Okuyan kart yok | Değişmez; itibarın yeni yazarı sistem tarafında (Karar 10) | K5 | İtibarın tek yazarı bugün `add_reputation` fiili (`effects.gd:240-241`) |

### 2. Olay motoru · fiiller, çipler, lint
| Kalem | Dosya:satır | Bugün | Yeni karşılığı | Dilim | Not |
|---|---|---|---|---|---|
| `fix_run_start` fiili (liste) | `effects.gd:43` | `NEUTRAL_VERBS` içinde | Silinir (Karar 12) | K2 | |
| `fix_run_start` fiili (kol) | `effects.gd:439-442` | `SupportSystem.start_fix_run()` yoksa `{refused: fix_run_refusal()}` | Silinir | K2 | Tek kullanıcı kart `bug_pile.json:55` |
| `fix_run_start` çipi | `chips.gd:44` | `["EFFECT_FIX_RUN_STARTS", "neutral"]`; CSV `strings.csv:3054` | Silinir (satır + CSV anahtarı) | K2 | `event_chip_coverage` (`endgame_smoke.gd:15158`) |
| `fix_run_start` lint | `lint.gd:323` (WRITER_VERBS), `:341` (CONSEQUENCE_VERBS) | Yazar fiili ve "bedeli sonucu olan" fiil | İkisinden de çıkar | K2 | `vocab_gen.gd:250-252` sayıyı yazar: "Writer verbs (32)" → 31 (`_vocabulary.md:551`) |
| `productivity_mod` `scope=team` | `effects.gd:358-374` | `SprintSystem.team()` üyelerine `HRSystem.add_productivity_mod`; `mode() != "active"` ya da ekip boşsa `_no_target(verb, "team")` | Karar 13: `team()` yalnız Yapım+Test (pay `focus_mult`); Destek'teki geliştirici kapsam dışı, Yapım+Destek geliştirici kapsamda (yüzde tam, sprint payı 0,5 çarpar) | K1 | Etkilenen kartlar: `leak_questions.json:79-83` (−15/3 hf), `sprint_rewrite_bugs.json:115-119` (−20/2), `sprint_rewrite_owner.json:105-109` (+5/6), `sprint_rewrite_reader.json:105-109` (−10/3), `password_rule.json:160-164` (−15/2). Smoke `productivity_mod_paces_the_sprint` (`:17235`) |
| `productivity_mod` çipi | `chips.gd:84-100` | `EFFECT_PACE_TEAM / _FOUNDER / _PACE` | Değişmez | — | Kapsam değişse de çip metni aynı |
| `productivity_mod` lint | `lint.gd:287-288, :742-743` | `pct == 0` ve `on_invalidate` kuralları | Değişmez | — | |
| `productivity_mod` `scope=founder/employee` | `support_overflow.json:68` (`yourself`, −20 kurucu), `wiped_table.json:83` (−50 çalışan) | Kişiye bağlanır; sprint puanına `_points` içindeki `HRSystem.productivity(c)` ile girer (`sprint_system.gd:1290-1293`) | Karar 13: kişi `team()` dışındaysa sprint puanına yansımaz | K1 | `support_overflow` yalnız `founder.task_state == build` iken geçer, yani kurucu `team()` içinde |
| `damage_product` | `effects.gd:43` | Listede, `_apply` kolu yok; `_vocabulary.md:53,:626` | Bu fazın konusu değil | K8 (not) | "Hata" kelimesi grep'e girer; kaldırılıp kaldırılmayacağı sahibe sorulur |
| `critical_bug_unfixed` | `effects.gd:66`, `game_state.gd:64` | `set_game_flag` beyaz listesi + FLAG_TYPES; okuyan/yazan yok | Bu fazın konusu değil | K8 (not) | `GAME_FLAG_WHITELIST` "satır eklemek tasarım kararıdır" (`effects.gd:64-66`) |
| `add_reputation` | `effects.gd:240-241` | Bugün itibarın tek yazarı (`GameState.set_reputation`, `game_state.gd:346-349`, kenet −10..100) | Karar 10: haftalık sistem yazarı ayrıca eklenir (A_PLAN 5.3.9; tabanı yok) | K5 | `bug_pile`'ın `later` seçeneği ve süre cezası −1 (`bug_pile.json:64, :100`) kartla birlikte gider |

### 3. Olay motoru · kartlar (seam değişince ne olur)
| Kart | Dosya:satır | Okuduğu seam / fiil | Seam değişince | Dilim | Not |
|---|---|---|---|---|---|
| `product.bug_pile` | `bug_pile.json:27,32,37,48,55`; gövde `:73,:85`; frozen `lint_v3_frozen.json:28`; CSV `strings.csv:3094-3098` | `urun.bugs_confirmed ≥ 12` ∧ `desk_staffed` ∧ `!fix_run_active`; seçenek `fix_now` = `requires can_start_fix_run` + `fix_run_start`; `later` = `add_reputation −1`; süre cezası −1 | Silinir (Karar 12 "Hata yığını" kartı) | K2 | Beş `EV_PRODUCT_BUG_PILE_*` anahtarı, frozen satırı, `event_beat_freezes_seams` (`endgame_smoke.gd:5854`) yeniden yazılır (gövde jetonu için `support_overflow` kullanılabilir). Kartın işini sistem tarafında üstlenen yok (B'nin acil olayı ayrı) |
| `customer.b2c_refunds` | `b2c_refunds.json:39,44,50` | `urun.bugs_confirmed ≥ 8` ∨ `warmth_band == hot`, `sales.b2c_audience ≥ 1000`; efekt: `add_cash −3000`, `satisfaction_delta` | `urun.open_bugs ≥ 8` (K3); eşik aynı | K3 | Gövde (`EV_CUSTOMER_B2C_REFUNDS_BODY`, `strings.csv:3128`) hata sayısı anmıyor. Karar 4 hedefi (medyan <5) tutarsa kart nadirleşir; hiç düzeltmeyen oyuncuda sıklaşır |
| `product.support_overflow` | `support_overflow.json:41,46,56`; gövde `:123,:133` | `warmth_band == hot` ∧ `desk_staffed == false` ∧ `hr.headcount == 0` ∧ `founder.task_state == build`; jeton `urun.bugs_unconfirmed` | Seam'ler değişmez; `desk_staffed` anlamı K1'de (Yapım'daki kurucu masada değil → koşul sürer) | K1 | Kalır. Akış sabiti (K5) ateşleme oranını kaydırır |
| `team.wiped_table` | `wiped_table.json:71` | `warmth_band != calm`, `newest_hire`, `productivity_mod employee −50` | Değişmez | — | Baseline `lint_baseline.json:15` (T3) |
| `product.repeat_reminders` | `repeat_reminders.json:70` | `urun.bugs_unconfirmed ≥ 6` ∧ `version_age == 1` ∧ B2B | Değişmez | — (K5 akış etkisi) | Tek haftalık pencere; akış ayarı (K5) penceredeki sayıyı değiştirir |
| `product.launch_leak` | `launch_leak.json:39` | `urun.axis_stability < 10` ∧ `enterprise_trust == false` ∧ `b2c_audience ≥ 30`, sürümden 2-6 hf | K5: hata terimi gidince yalnız ham Kararlılık | K5 | |
| `team.password_rule` | `password_rule.json:82` | `urun.axis_stability < 10` ∧ `sprint_running` ∧ `sprint_week == 2`; seçenek `productivity_mod team −15/2hf` (`:160-164`) | K5 (okuma) ve K1 (`scope=team` kapsamı) | K1, K5 | İki dilimde etkilenen tek kart |
| `product.b2c_floor_churn` / `b2c_floor_signal` | `b2c_floor_churn.json:28,40`; `b2c_floor_signal.json:34,51` | `axis_floor_crossed/warning` sinyali + `urun.floor_*` | K5 (okuma) | K5 | Kararlılık dalı B2C tabanı 20'de |
| `rival.shutdown_notice` | `shutdown_notice.json:63` | `urun.floor_stability != crossed` | K5 (okuma) | K5 | Baseline `lint_baseline.json:14` (O5) |
| `world.b2c_creator_feature` | `b2c_creator_feature.json:48` | `urun.floor_stability != crossed` | K5 (okuma) | K5 | `plausibility.gd:352-355` kitle koruması hata okumuyor |
| `customer.retention` | `retention.json:173,:189` | `musteri.risk_voice` jetonu | Bkz. §1 `musteri.risk_voice` | K5 | |
| `sprint_rewrite_*`, `sprint_unasked_rewrite`, `leak_questions` | bkz. §2 | `productivity_mod scope=team` + `hr.job == build` | K1 | K1 | `sprint_rewrite_bugs` adı "hata" içerir ama hata deposu okumaz |

### 4. Üretilen ve sabit dosyalar
| Kalem | Dosya:satır | Bugün | Yeni karşılığı | Dilim | Not |
|---|---|---|---|---|---|
| `_vocabulary.md` | `docs/content/events_draft/_vocabulary.md:53-54` (nötr fiiller), `:142-150` (`destek.`), `:350-381` (`urun.`), `:551` ("Writer verbs (32)"), `:572`, `:626` | `--event-vocab` üretir (`vocab_gen.gd`); KEEP bloğu `:638` korunur | K2: iki `destek.*` satırı + `fix_run_start` çıkar, sayı 31. K3: `urun.bugs_confirmed` → `urun.open_bugs`, `urun.worst_line_bugs` eklenir | K2, K3, K8 son | Her commit'te yeniden üret ve ekle |
| `EVENT_SIGNAL_MANIFEST.md` | `docs/EVENT_SIGNAL_MANIFEST.md:153` (`build_progress_changed`: main · product_system), `:161-162` (`fix_run_*`), `:163` (`bug_confirmed`), `:164`, `:57` | `tools/gen_signal_manifest.py` üretir (`BUS`, `scripts/` taraması) | K2: `fix_run_started/finished` (`event_bus.gd:147-148`) çıkar. K3: `line_bugs_cleared` eklenir; `bug_confirmed` (`event_bus.gd:149`, yayan `product_read.gd:164`, dinleyen 0) C yerine toplam O'yu izler. K5: `build_progress_changed` yayanı aşınma yerine `add_bugs/clear_line_bugs` olur (`product_system.gd:146` kalkar; A_PLAN 4.6) | K2, K3, K5 | Başlık sayıları (146 sinyal, 2 yayansız, 69 dinleyicisiz) değişir |
| `lint_v3_frozen.json` | `tools/lint_v3_frozen.json:28` (`product.bug_pile`) | "Liste büyümez, yeniden yazılan kart çıkar" (`:2`) | Satır silinir | K2 | `customer.b2c_refunds` (`:4`) ve öteki beş kart kalır |
| `lint_baseline.json` | `tools/lint_baseline.json:11` (`sprint_rewrite_bugs` O4), `:14` (`shutdown_notice` O5), `:15` (`wiped_table` T3), `:18` | Parmak izi kart metnine bağlı | Kart içeriği değişmediği sürece dokunulmaz | — | K1-K5 bu üç kartın JSON'unu değiştirmiyor. Değişirse `--event-lint=baseline` ayrı karar |

### 5. Kayıt
| Kalem | Dosya:satır | Bugün | Yeni karşılığı | Dilim | Not |
|---|---|---|---|---|---|
| `SCHEMA_VERSION` / `MIN_LOADABLE_VERSION` | `save_manager.gd:16, :23` | 15 / 10 | 16 / 10 (A 16, B 17; Karar şema numarası, YURUTUCU_NOTU 7) | K3 | `meta` ve `schema_version` yazımı `:227, :271` sabiti okur |
| `read_slot` göç zinciri | `save_manager.gd:187-201` | `<11 _migrate_sales_rev6`, `<13`, `<14`, `<15` | `if version < 16: _migrate_16(state)` eklenir | K3 | `list_slots` her yuvayı buradan okur: göç saf ve ucuz olmalı |
| `_migrate_16` (YOK) | — | Kodda yok (`_migrate_15` `:817`) | **1. kısım (K3):** `product.tickets` satırlarını `line`'a göre say → `mvp_open_bugs`; C satır sayısından fazlaysa fazlayı canlı hatlara hat sırasıyla dağıt (bilet defteri C'nin gerisinde kalabilir: `sync_tickets` defteri C'den her gün yeniden kurar, `sprint_bridges.gd:19-42`; YURUTUCU_NOTU 11). `mvp_open_bugs_prev` aynı sözlük. `product.tickets/ticket_seq/voices_seen` sil; `gate_faulty` → `pending_faulty`. Flag sil: `mvp_bugs_confirmed`, `mvp_fix_run_active/fixed/progress`, `mvp_reports_week_net`. **2. kısım (K5):** `mvp_live_bug_count`, `mvp_live_bug_progress`, `mvp_bug_history` sil (L taşınmaz); bekleyen VC `bugs_under` → yeni eksen koşulu | K3 + K5 | `mvp_reports_incoming/_progress`, `mvp_validation_progress`, `mvp_new_code_effort` kalır |
| `_migrate_16` · ürün durumu koruması | `save_manager.gd:827-828` | `_migrate_15` tür seçilmemişse (`subtype == ""`) `game_state.product` kurmadan döner | `_migrate_16` `game_state.product` yokluğunu ve `_migrate_15`'in `SprintSystem.new_state` ile kurduğu (bilet alanı olmayan) durumu tolere eder | K3 | `_migrate_15` `SprintSystem.new_state(today)` çağırır (`:882`): K3'ten sonra v15 zinciri v16 biçimli ürün üretir; `erase` ile idempotent olmalı. **[A2]** `_migrate_15`'in açıklaması (`:805-810`) "ilk günlük eşitleme biletleri dağıtır" der; K3'te bayatlar |
| `_migrate_16` · kart içindeki bilet kimlikleri | `sprint_catalog.gd:292` (`new_card` `"tickets": []`), `:268`; `sprint_system.gd:1011-1012` (kapanış), `:1194-1199` (yenileme) | Düzeltme kartı `tickets` kimlik dizisi taşır; koşan kartın eforu kilitli. Sürüm kayıtları `releases[].shipped[]` kart sözlüğü taşır, `actual_sentence` `c.tickets.size()` okur (`sprint_bridges.gd:204-207`) | Düzeltme kartı sayıyı O'dan okur (Karar 5, `line_bugs`). Göç: koşan/bekleyen düzeltme kartlarının `tickets` alanı hat sayısına çevrilir ya da silinip kart yeniden kurulur; eski sürüm kayıtlarında `bugs_before/after` yok (sürüm notu geri dönüşü K4) | K3, K4 | Koşan düzeltme kartı (state `running`) göçte eforunu korumalı (Karar 6/§4.6c "Koşan kartın eforu kilitlidir") |
| `_migrate_16` · VC geri dönüşü | `game_state.gd:244` (`vc_states`), `vc_pitch_system.gd:489-495` (`_make_callback`), `:1288-1295` (`_callback_met`), `:890-904` (`_tick_callbacks`), `:716-719` | `vc_states.<id>.callback = {type:"bugs_under", target:3, met}` kayıtla taşınır; koşul `live_bug_count() < 3` | Karar 8 ve §4.7: "En zayıf eksen > 40" (`PitchConstants.CALLBACK_AXIS_MIN`, `HUNT_CB_AXIS`) tipi; `met` bayrağı korunur; göç sonrası kayıtta `bugs_under` kalmaz | K5 | Çevrilmezse `_callback_met` varsayılanı `false` döner (`:1294`) ve kapı `callback_unmet` ile (`:718-719`) sonsuza dek kilitli kalır. **[A2, PLAN ETKİSİ]** Yeni koşul `_weakest_dimension`'ın ham eksen ölçeğiyle kurulursa da hiç karşılanmaz (ACIK_KARARLAR 59); ölçek E1'de |
| `_migrate_16` · olay motoru bloğu | `queue.gd:213-225`, `papers.gd:187-194`, `save_manager.gd:661` (`_migrate_14` `sys[EvSave.BLOCK_KEY]`'ı zaten geziyor) | Silinen kartın kuyruk/aktif/kâğıt satırı yüklemede `push_error("... no such card")` basıp düşer; `gate_common.sh:9` `^ERROR:` satırını başarısızlık sayar | `bug_pile` satırlarının göçte temizlenmesi önerilir (öncül 33c5323 temizlememişti) | K2/K3 | Bkz. §10 madde 1 |
| `_migrate_14` · `mvp_bug_history` | `save_manager.gd:724-725` | v13 kaydında örneği son tek örneğe kırpar | `_migrate_16` bayrağı silecek; bu iki satır ölü olur ve §4.1 istisnası yalnız `_migrate_16`'yı sayar | K5 | `save_v13_day_stamps_migrate` (`endgame_smoke.gd:2095`) `:2240-2241`'de `[5]` bekler; göç sonrası "yok" beklemeye çevrilir |
| `_migrate_15` · eski yapım anahtarları | `save_manager.gd:813-814` (`_BUILD_FLAG_PREFIXES`: `mvp_bug_sprint_`, `bug_count_at_bugfix_start_`, `mvp_bug_count_at_launch`), `:807-810` açıklama | Eski yapım bayraklarını süpürür | Dokunulmaz (v14→15 göçü) | — | §4.1 grep'ine "bug" ile takılır; R'de gerekçesiyle listelenecek |
| `GameState.FLAG_TYPES` | `game_state.gd:61-63` (`mvp_live_bug_count/progress`, `mvp_bug_history`), `:75` (`mvp_bugs_confirmed`), `:77-79` (`mvp_fix_run_*`) | Tip kaydı; `SaveCodec._decode_flags` (`save_codec.gd:217-236`) bu tabloya göre çevirir | Silinen anahtarlar çıkar; `mvp_open_bugs`, `mvp_open_bugs_prev` `TYPE_DICTIONARY` eklenir (JSON sayıları float döner: okuma `int()`) | K3 (C, fix_run), K5 (L) | `:73-74` (`mvp_reports_incoming/_progress`) ve `:76` (`mvp_validation_progress`) kalır |
| `FLAG_TYPE_PREFIXES` | `game_state.gd:127` (`bug_count_at_bugfix_start_`) | Eski yapım taban öneki; yazanı yok | Ölü önek | K8 | |
| `reset_all_owners` | `save_manager.gd:320-358` (`ProductSystem.reset()` `:341`) | SprintSystem/ProductState adlı satır YOK; sprint durumu `GameState.product` içinde (`game_state.gd:876` `product.clear()`). `ProductSystem.reset` → `SupportSystem.reset` + `ProductRead.reset` (`product_system.gd:32-38`) | Yeni statik `fix_off` debug anahtarı (K5) `ProductSystem.reset` zincirine ya da `reset_all_owners`'a girer; `RunProbe.run` sıfırlama bloğu da (`run_probe.gd:175-197`) | K5 | PRD §6 "reset_all_owners: SprintSystem/ProductState" satırının birebir karşılığı yok. Precedent: `EndingsSystem.build_scope_override` (`endings_system.gd:374`), `SummarySystem.frequency_override` |
| `SprintSystem.new_state` | `sprint_system.gd:76-86` | `tickets: []`, `ticket_seq: 0` (`:82`), `voices_seen: {}` (`:83`), `gate_faulty: []` (`:85`) | `tickets/ticket_seq/voices_seen` kalkar; `gate_faulty` → `pending_faulty` (anlamı genişler: yayın öncesi hatalı kapanış + yayında hat yokken doğan hata, v1.0'da düşer) | K3 | Okuyanlar: `sprint_system.gd:226-227` (`publish`), `:1042` (kapanış), `:1103-1104` (`_go_public`) |
| `SprintSystem.voices_seen()` | `sprint_system.gd:376-377` | Alan başına son görülme günü | Silinir (Sesler bölümü kalkar, Karar 12) | K6 | `product_tab.gd:8,:248`, `area_panel.gd:166,:193`, `product_fixtures.gd:202-206` (arayüz katmanı) |
| `_go_public` L sıfırlama | `sprint_system.gd:1093-1094` | Her sürümde `mvp_live_bug_count/progress` = 0 | Satırlar silinir | K5 | Smoke `sprint_release_resets_live_bugs` (`endgame_smoke.gd:17872`) silinir |
| Hatalı kapanış zarı | `sprint_system.gd:796` (`c.faulty = true` Test fazı rolsüz), `:1027-1028` (zar, `faulty_chance`), `:1040-1042` | Hatalı kart `_go_public`'te `add_faulty_ticket(hat)` ya da kapıda `gate_faulty` | `_go_public` `add_bugs(kart.hattı, 1)`, yayın öncesi `pending_faulty` (Karar 3 istisnası) | K3 | Bkz. §10 madde 4 (`founder_roles` ve %40 zarı) |
| Bilet defteri yazma noktaları | `sprint_bridges.gd:19-42` (`sync_tickets`), `:47-54` (`close_tickets`), `:58-61` (`add_faulty_ticket`), `:239-241` (`_next_ticket_id`); `sprint_system.gd:31` (günlük `sync_tickets`) | C ile defteri senkron tutar; kart kapanışı `adjust_confirmed(-n)` (`product_state.gd:176-177`) | Silinir; yerine `clear_line_bugs(hat)` + `line_bugs_cleared` sinyali (B'nin yazma noktası) | K3 | `SprintBridges` başlık yorumu `:7` ("dört anahtar") güncellenir |
| Kaydı taşıyan bütün bayraklar (düzeltme koşusu) | `product_state.gd:18-22, :180-185` | `FIX_RUN_*`, `REPORTS_WEEK_NET`, `reports_missed` | Silinir | K2 | `save_v10_product_state` (`endgame_smoke.gd:14279-14280, :14323`) güncellenir |

#### 5.1 Kayıt/göç smoke vakaları ve bu anahtarları kuran fikstürler
| Vaka / fikstür | Dosya:satır | Kurduğu / doğruladığı anahtar | Dilim | Not |
|---|---|---|---|---|
| `save_v10_product_state` | `endgame_smoke.gd:14249` (dispatch `:421`) | `REPORTS_INCOMING 41`, `BUGS_CONFIRMED 9` (`:14278`), `FIX_RUN_ACTIVE/FIXED` (`:14279-14280`), denetim `:14296, :14319, :14322-14323` | K2 (fix_run), K3 (C → `mvp_open_bugs`) | Mevcut şemada kaydet-yükle turu; göç değil |
| `save_v13_day_stamps_migrate` | `endgame_smoke.gd:2095` (dispatch `:285`) | `mvp_bug_history [3,4,5]` (`:2140`), denetim `:2240-2241` (`[5]`) | K5 | Zincir 16'ya kadar işler: `mvp_bug_history` yok beklenmeli |
| `save_v14_build_becomes_sprint_plan` | `endgame_smoke.gd:18371` | Düşen eski bayraklar `mvp_bug_sprint_active`, `bug_count_at_bugfix_start_b1` (`:18392-18393`) | — | `_migrate_15` fikstürü; zincir 16'yla da geçmeli |
| `save_v14_history_becomes_releases` | `endgame_smoke.gd:18463` | `_migrate_15`'i doğrudan çağırır (`:18468`) | — | Şema 15 göç vakası: §4.1 istisnası |
| `sprint_save_roundtrip` | `endgame_smoke.gd:17727` (dispatch `:460`) | `adjust_confirmed(2)` + `sync_tickets` (`:17737-17738`), `product.tickets.size()==2` (`:17746-17747`) | K3 | Tek şemalı turda `mvp_open_bugs` ile yeniden kurulur |
| `save_v15_tickets_become_open_bugs` (YOK) | — | PRD §4.7 / A_PLAN 7 K3 | K3 | Şablon `save_v14_build_becomes_sprint_plan`: `save_to_slot` → `schema_version` 15 yap → `read_slot` |
| `save_v15_callback_bugs_under` (YOK) | — | PRD §4.7 | K5 | `vc_states.<id>.callback` fikstürü |
| `_seed_support_fixture` | `endgame_smoke.gd:13377` | `mvp_live_bug_count 6` (`:13383`), `BUGS_CONFIRMED 0` (`:13388`), `FIX_RUN_*` (`:13405-13409`) | K2/K3/K5 | `destek_*` ve `product_read_catalogue` ortak fikstürü |
| `_seed_risk_account` | `endgame_smoke.gd:12253` (`:12260` L) | L ile Risk sebebi | K5 | `risk_exit_stamps_day` (`:12314`) |
| `product_read_catalogue` bug_confirmed kenarı | `endgame_smoke.gd:13764-13782` | `BUGS_CONFIRMED 5→9→2` ve §19 sinyal listesi `:13744` (`fix_run_*`) | K2/K3 | Düşüş sinyali atmaz kuralı O toplamına taşınır |

### 6. Veri
| Kalem | Dosya:satır | Bugün (okuyan) | Yeni karşılığı | Dilim | Not |
|---|---|---|---|---|---|
| `urgent_tickets` | `sprint.json:36` (3) | `sprint_catalog.gd:148` (alan uyarısı), `:265` (acil kart), `:285` (`is_urgent`) | `urgent_bugs`; Karar 4 acil eşiği yeniden ele alınır (tek ayar, Karar 7), bugünkü değer 3 K4'e kadar | K4 (ad/yer), K5 (değer) | Bot `_suggest` zorunlu listesi `sprint_catalog.gd:809` (`must.append_array(pool.filter(is_urgent))`) bu eşiği zorunlu kart yapar; rastgele dağılımda çok acil kart doğurabilir |
| `effort.fix`, `effort.fix_urgent` | `sprint.json:6` | `sprint_catalog.gd:266`; göç `save_manager.gd:863` yalnız `effort.k%d` okur | Basamaklı `fix_effort` (1-2 hata → 1, 3-5 → 2, ≥6 → 3; `{"steps":[3,6],"points":[1,2,3]}`, Karar 7, onay bekliyor); iki eski anahtar silinir | K4 | Smoke `sprint_fix_card_closes_tickets` `cfg("urgent_tickets")` (`endgame_smoke.gd:17488`) ve `cfg("effort.fix_urgent")` (`:17494`) okur |
| `impact.ticket` | `sprint.json:42` (0,5) | `sprint_catalog.gd:719` (`w.ticket × card.tickets.size()`) | `impact.bug` (A_PLAN 5.3.6) | K4 | |
| `content.ticket_titles` | `sprint.json:43` (3) | `sprint_catalog.gd:202` (`ticket_title`) | Silinir ("ticket" oyuncu metninden çıkar) | K6 | `PRODUCT_TICKET_0..2` `strings.csv:2974-2976` |
| `voices_new_weeks` | `sprint.json:33` (2) | `sprint_catalog.gd:180` (`voices()`) | Sesler kalkınca okuyan kalmaz; araştırma cümlesi "iki hafta" için yeniden kullanılabilir (A_PLAN 6) | K6 | Silmeden önce okuyanı kontrol et |
| `founder_roles` | `sprint.json:23` | `sprint_system.gd:1272` (`_fits`: kurucu her role uyar) | Karar 13: kimin sprintte olduğu işe bakar; roller aynı kalır (rol puanı D'nin) | K1 | **[A2 düzeltme]** Zarın atılmamasının sebebi yalnız kurucu değildir: Test fazını yalnız `dev`/`test` rolüne uyanlar yürütür (`sprint_system.gd:765-766, 790`) ve geliştirici ile test uzmanı da `test`'e uyar (`hr_constants.gd:89-90`). `sprint_faulty_ticket_deterministic` (`endgame_smoke.gd:17447`) zarı ancak kurucu rollerini `["product","dev"]` yapıp tasarımcı alarak çalıştırır (`:17449-17453`) |
| `founder_mult` | `sprint.json:22` | `sprint_system.gd:1290-1293` (`_points`) | Aynı; pay (`focus_mult`) ayrıca çarpar | K1 | |
| `cap_ceiling` | `sprint.json:25` (1,25) | `sprint_catalog.gd:811`, `sprint_system.gd:545-551` (`_takes`), smoke `:17304` | Aynı; bot kolu bunu aşmak zorunda kalabilir (PRD §4.4 kurulum) | K5 | `SprintSystem.add` reddederse bot tarafı `_place` kullanabilir (private) |
| `faulty_chance` | `sprint.json:28` (0,4) | `sprint_system.gd:1027` | Değişmez (D testçiye bağlar) | — | |
| `shares.fix`, `roles.fix` | `sprint.json:10, :16` | `sprint_catalog.gd` kart kurulumu | Değişmez | — | |
| Kart JSON'ları (hata seam'i) | `b2c_refunds.json:39`, `bug_pile.json:*` | bkz. §3 | bkz. §3 | K2, K3 | Başka `data/` dosyasında hata/ticket anahtarı yok (grep; `lines/*.json` ve `rnd_tree.json`'daki `bug_tracker` Ar-Ge düğümü, hata deposuyla ilgisiz) |
| CSV (olay yüzü) | `strings.csv:3054` (`EFFECT_FIX_RUN_STARTS`), `:3094-3098` (`EV_PRODUCT_BUG_PILE_*`) | `chips.gd:44`, `bug_pile.json` | Silinir | K2 | |
| CSV (öteki "silinen" aileler) | `strings.csv:590-593` (`BUILD_SUPPORT_*`, `FIX_RUN_REFUSED_NO_BUGS`), `:1239`, `:1262-1263`, `:2840`, `:2809-2813`, `:2826-2827`, `:2854-2859`, `:2929-2930`, `:2966-2967`, `:2974-2976`, `:2983`, `:2992-2995`, `:834` (`HUNT_CB_BUGS`), `:1325-1326` (`VC_Q_BUGS*`), `:2489, :2519-2521` (`SALES_*STABILITY_BUGS*`), `:470` (`HR_AREA_MEANING_TESTER_QA`), `:482` (`ONB_SKILL_QA_DESC`) | Arayüz/satış/VC metinleri | A_PLAN 6 silme/yeniden yazma listesi | K2, K5, K6 | Bu katmanın değil (arayüz katmanı); burada yalnız tam satır numaraları için listelendi |

### 7. Araçlar
#### 7.1 `run_probe.gd`
| Kalem | Dosya:satır | Bugün | Yeni karşılığı | Dilim | Not |
|---|---|---|---|---|---|
| Hotfix bloğu | `run_probe.gd:1099-1122` | C ≥ 6 ve `can_start_fix_run()` ise koşu başlatır (4 gün aç/1 gün kapa), geliştirici ödünç verir, `PROBE PLAY ... fix_run start/end` basar (`:1106, :1121`) | Silinir (Karar 12; PRD §6 "run_probe artık Hotfix değil düzeltme kartı kullanır") | K2 | Bot bunun yerine düzeltme kartını sprint planıyla alır (aşağıda) |
| Hotfix durumu | `run_probe.gd:129-131` (`_fix_on_at`, `_fix_off_at`, `_fixer_id`), `:1173` (`_run_research` `_fixer_id`'i atlar) | `RunProbe.run` sıfırlama bloğu (`:175-197`) bu üçünü sıfırlamıyor (aynı süreçte çok koşuda sızar: `plausibility_run.sh`) | Silinir | K2 | |
| B2C kurucu→Destek kolu | `run_probe.gd:1089-1098` | Pazar b2c ∧ `b2c_paying_users() > 0` ise `clear_jobs(founder)` + `assign_job(JOB_SUPPORT)`; yorum "sprint puanı işine bakmaz (SprintSystem.team)" (`:1089-1093`) | Karar 13: kurucu Yapım'da kalır, Destek ikinci iş olur (0,5/0,5); `clear_jobs` kalkar. Yorum yeniden yazılır | K1 | `full_run_b2c` ekonomi kayması K1 raporunda (A1d tabanı `full_run_b2c_7.log`). **[A2 düzeltme]** B2B presetlerinde kurucu iş değiştirmez, ama Hotfix bloğu (`:1111-1117`) iki pazarda da bir geliştiriciye Destek'i ikinci iş verir; K1 sonrası o geliştirici sprintte 0,5 sayılır ve `full_run` da kayar (K2 bloğu silene dek). Oyuncunun bu hâle ulaşma yolu yok (bkz. §10 madde 5) |
| Hire tetikleyici | `run_probe.gd:1042-1043` | B2C'de ödeyen var ∧ `reports_incoming > 0` ∧ `validation_per_day() < reports_per_day()` ise destek elemanı işe alır | Değişmez | — (K5 akış) | Akış sabiti (K5) işe alma zamanını kaydırır |
| PROBE SHIP | `run_probe.gd:283-286` | `bugs=<L> tickets=<C>` | `open_bugs=<O>`; `bugs=` kalkar (A_PLAN 5.8) | K3 (C), K5 (L) | A1d tabanı: `bugs=0 tickets=0` |
| PROBE STATE | `run_probe.gd:483-489` | `bugs=<L>` | `open_bugs=<O>` | K5 | Başlık yorum bloğu `:27-34` |
| PROBE CUST | `run_probe.gd:511-515` | Her satır global L'yi `bugs=` diye basar (hesap başına değil) | Hesabın kendi hatları (`account_bugs`) | K5 | `target=` (`:512`) `B2BSalesSystem.satisfaction_target` |
| PROBE B2C | `run_probe.gd:532-539`, başlık `:31-34` | `live_bugs=<L> confirmed=<C>`; `economy_dims_from_flags()` (`:535`) L-eroded | `live_bugs/confirmed` yerine `open_bugs=<O>` | K3 (C), K5 (L, dims) | A1d: `PROBE B2C` 97 satır/koşu (b2c) |
| `PROBE PLAY` sprint başlangıcı | `run_probe.gd:869-872` | `sprint N start cards= used= capacity=` | `PROBE FIX` satırı buraya (başladığı andaki düzeltme `remaining` toplamı / `capacity()`, PRD §4.4) | K5 | Sprint başlayınca kartlar `GameState.product.sprint.cards`'ta |
| `PROBE FIX` (YOK) | — | Kodda yok | Yeni | K5 | Haftalık yeni/açık hata serisi için de satır yok (A1d tablosu bugün yalnız L/C'yi görüyor) |
| `PRESETS` şekli | `run_probe.gd:72-85`, belge `:66-71` | 17 anahtar; alanlar `subtype, policy, vc, staff_cap, k1_only` | `fix` anahtarı: `fix_none / fix_worst / fix_due / fix_off` (PRD §4.4; `policy` olay cevabı olarak kalır) | K5 | Sekiz preset ya da `replay=` gibi adlı 5. spec parçası; seçim A1 dışı |
| `fix` kolunun okunacağı yer | `run_probe.gd:1563-1570` (`_seed_world` `full_run*` dalı) | Yalnız adı `full_run` ile başlayan presetler spec okur | Bir `spec.get("fix", ...)` satırı eklenir | K5 | Spec ayrıştırma `:153-173` (`parts[3]` tohum, `:164-170` `replay=`) |
| `run()` statik sıfırlama | `run_probe.gd:175-197` | Koşu başında statikleri temizler | `fix_off` ve kol durumu eklenir | K5 | `plausibility.gd:149-161` aynı süreçte çok koşu sürer |
| `_plan_the_sprint` / `apply_lead` | `run_probe.gd:837-872`; `sprint_system.gd:259-266`; `sprint_catalog.gd:790-830` | `apply_lead()` `lead_suggestion()` kartlarını `_place` ile koyar (`add`/`can_add` kapısından geçmez); `_suggest` zorunlu liste: söz, istek, ücretli plan, en zayıf alanın en iyi kartı (düzeltme olabilir), tüm acil düzeltmeler (`:809`); ilk kart boş sprintte her zaman alınır | PRD §4.4 sırası: lider planı → tüm düzeltme kartları `remove` → kolun kartları önce `add` → kalanı lider kuralıyla doldur. `_k1_only` aynı kalıbı kullanıyor (`:856-860`) | K5 | `add` kartı `_takes` yüzünden reddederse (`sprint_system.gd:545-552`) bot sınırı aşabilir; ikinci `apply_lead` acil kartları geri koyar, `_suggest` filtresi gerekir |
| Fixture preset'ler (L'ye bağlı) | `run_probe.gd:1639` (`b2c_neglect`), `:1666-1685` (`_seed_stability_fixture`), `:1654-1656` (`_axis_of` → `effective_stability`), `:1603`, `:1698` (`BUG_STABILITY_COEF`) | `b2b_solo/b2b_slip/b2b_risk/b2c_neglect` hata birikimini L olarak kurar ve eşitsizlik denetimini `PROBE ERROR fixture drifted` ile yapar | K5'te L silinince yeniden kurulmalı (hat başına O, ham Kararlılık) | K5 | Başlık yorumları `:107-108`, `:1585-1597`; ACIK_KARARLAR 1261, 1307, 1899-1902 bu presetlere atıf yapıyor (belge katmanı) |

#### 7.2 `sprint_probe.gd`
| Kalem | Dosya:satır | Bugün | Yeni karşılığı | Dilim | Not |
|---|---|---|---|---|---|
| Ekip fikstürü | `sprint_probe.gd:40-41` (`HIRES`), `:52` (varsayılan `team: 1`), `:73-74`, `:172-182` (`_hire`) | `team=N` N−1 orta beceri çalışan işe alır; `CharacterRegistry.add` her birine rolün varsayılan işini verir (geliştirici/tasarımcı → Yapım, test mühendisi → Test) | Karar 13 altında geçerli kalır: `team=3` (kurucu + geliştirici + tasarımcı) hepsi Yapım. İki işli ya da yalnız-Destek kişi için yeni anahtar gerekmez (fikstür dışı smoke/edge'de) | K1 | |
| Uyuşmazlık nedenleri | `sprint_probe.gd:63` (`event_resolved` → `_changed_by(id)`), `:64` (`day_tick_completed` → `"team"`), `:204-211` | `cause=<olay kimliği>` ya da `cause=team` | Karar 13 yeni bir ad getirebilir (iş değişikliği Ekip'in gününde işler, `sprint_system.gd:915-917`); PRD §4.6(a) gerekçesiyle yazılır | K1 | A1d tabanı (HEAD 1faeb82): `match=245/251`; 6 adlı uyuşmazlık = 3 × `product.sprint_late` + 3 × `team`; adsız 0; `LOADSUM idle=25` |
| Boşta sayacı | `sprint_probe.gd:186-195` (`_count_idle`) | `team().size() − worked.ids` | Aynı | K1 | `team()` küçülürse `idle` ve `LOADSUM` kayar (taban karşılaştırması) |
| Girdi anlık görüntüsü | `sprint_probe.gd:197-201` (`_inputs`) | `team()` + kartların `remaining`'i | Aynı | K1 | Düzeltme kartı eforu hat sayısına bağlanınca (K4) `remaining` kayar, tahmin eşliği `sprint_fix_preview_matches_close` ile ayrıca kanıtlanır |
| Kapı komutu | CLAUDE.md §12; PRD §4.6(a) | `--sprint-probe=hours=40:cards=2:ticks=60:team=3:fill=1:events=1` | Her dilimden sonra adsız uyuşmazlık 0 | K1, K3, K4, K5 | Bu komut yalnız Yapım ekipli fikstür; Destek'te kişili plan için yeni `edge:` fikstürü şart |

#### 7.3 Debug fikstürleri ve çekimler
| Kalem | Dosya:satır | Bugün | Yeni karşılığı | Dilim | Not |
|---|---|---|---|---|---|
| `--office-shot ... desk_shut` | `main.gd:1289-1294` (başlık `:1220-1225`) | B2C `note_tool`, `REPORTS_INCOMING 12`, `REPORTS_WEEK_NET 12` yazar (silinecek bayrak), `build_progress_changed` yayar | Yeniden kurulur, silinmez (PRD §4.12): masa boş, açık hata tohumlu (`add_bugs`), Destek kartı yeni görünümde | K2 (bayrağı bırak), K6 (son hâl) | CLAUDE.md §12 "12 gelen bildirim" cümlesi güncellenir (belge katmanı). K1: boş masa ofis karesi |
| `--office-shot ... fix_run` | `main.gd:1295-1306` | `BUGS_CONFIRMED 9`, `FIX_RUN_*`, `REPORTS_WEEK_NET` | Silinir | K2 | CLAUDE.md §12 `fix_run` anılmıyor, yalnız `desk_shut` |
| L tohumları | `main.gd:1044` (`risk reason → "sık kesinti şikayeti"`), `:1114` (`COMPLAINT_BUG_GATE`), `:1177` | `mvp_live_bug_count` yazar; `risk_reason` (`inbox.gd:211`) L'yi okur | Hesabın kendi hatları (`add_bugs` ile hat tohumu) | K5 | Sales çekimleri (`--sales-shot`) |
| `--product-shot=live:*` | `main.gd:3139-3190` (`_run_product_shot`), `:3245-3330` (`_seed_product_live`) | `SprintSystem.choose_type` + `_seed_hr_roster` (`:2991`: PM, tasarımcı, geliştirici izinde, test mühendisi, satış temsilcisi); `live:plan` `:3276`, `live:active` `:3283` | Karar 13: `team()` Yapım+Test; satış temsilcisi ekipten çıkar, kapasite çubuğu değişir (kareler yeniden çekilir) | K1 (kapasite), K7 (düğmeler) | `live:solo15/solo12_active` kurucu tek başına: `focus_mult` 1,0 |
| `edge:<ad>` fikstür yolu | `main.gd:3191` → `game_shell.gd:172` → `product_fixtures.gd` | Görünüm modeli sözlüğü (motor durumu değil) | Yeni: hat paneli B2B/B2C, 1-2 hatalı uzun liste, uzun hesap adlı düzeltme kartı, sürüm notu, Destek'te kişili ekip + boş sprint (PRD §4.12) | K1, K4, K6 | Adlar HARITA'ya eklenecek |
| `product_fixtures.gd` bilet/ses | `product_fixtures.gd:165-166` (`voices_open`), `:202-206` (`voices_seen` eylemi), `:289`, `:473-477` (`{"k":"tickets"}` etki çipi), `:500` (`voices`), `:519-534` (`voices`, `_heard`), `:359, :573` (müşteri satırı `tickets`), `:599` (`voices_open` ui) | Sesler ve bilet çipleri | K4/K6'da kart etki satırı ve Sesler kalkınca fikstür de güncellenir | K4, K6 | `main.gd:3192-3198` `edge:voices_open` özel dalı da gider |
| `cap_zero` fikstürü | `product_fixtures.gd:106-110` | `team = []`, `staffed = false`, `warning_text = ""`: "sprintte kimse yok" zaten var | Karar 13: plan bunu söyler ve Ekip'e bağlar (yeni metin + bağ) | K1 | PRD §4.12 "sprintte kimsenin olmadığı hâl" için bu fikstür uyarlanır |
| `_team()` fikstürü | `product_fixtures.gd:554-562` | Görünüm modeli ekibi (Kurucu, Deniz, Ece, Kaan) | Destek'teki kişi listede görünmez, Yapım+Destek yarım payla | K1 | Yeni `edge:` |
| `tools/run_gate.sh` | `run_gate.sh:19` (`full_run full_run_b2c full_run_vc_cautious`), `:25`, `:29-31` | Her koşu tek `PROBE END`, bir son, sıfır `ERROR` ister | Değişmez; ekonomi kayması kapıda değil K1 raporunda | K1, K8 | `ERR_TOKENS = ^ERROR:|SCRIPT ERROR|Parse Error|Compile Error` (`gate_common.sh:9`): `_validate_shape` push_error'ı iki işli kurucuda kapıyı düşürür |
| `plausibility` | `plausibility.gd:140-143, :149-161`; `tools/plausibility_run.sh` | Tek süreçte çok koşu, `reset_all_owners` + `RunProbe.run` | Yeni `fix` anahtarının varsayılan kolu tanımlı olmalı | K2, K5, K8 | Bkz. §10 madde 6 |

### 8. Smoke vakaları dilime göre
Adlar `endgame_smoke.gd` match tablosu (`:51-730`) adıdır; fonksiyon `_case_<ad>`. Satır = fonksiyon tanımı.

| Dilim | Vaka (satır) | Dokunduğu şey | Ne olur |
|---|---|---|---|
| K1 | `sprint_capacity_from_team` (17191), `productivity_mod_paces_the_sprint` (17235), `prep_bonus_and_capacity` (2566), `hr_leave_cycle` (6907), `hr_raise_and_leave` (7076), `hr_active_filters` (7213), `leave_does_not_pause_build` (13307), `research_occupies_person` (14536), `research_and_build_pause_each_other` (14597), `research_freezes_and_resumes` (14654), `sprint_ceiling_125_blocks_add` (17304), `sprint_carry_keeps_progress` (17334), `sprint_decision_blocks_progress` (17779), `sprint_departure_restaffs_card` (17895), `sprint_late_only_when_behind` (18320), `promise_row_locked_when_no_room` (18226), `product_pm_plan_opens_as_next_sprint` (18509), `sprint_starts_only_with_consent` (17520), `sprint_save_roundtrip` (17727) | `team()`, `capacity()`, `role_of`, `week_points`, `pm_plans` | Kurucuyu/çalışanı işsiz bırakan ya da Destek'e alan vakalar kapasiteyi değiştirir; ~16-25 vaka ayar ister (K0) |
| K1 | `hotfix_founder_takes_support_desk` (5183), `support_desk_rates_stack` (5303), `hotfix_account_count_excludes_base` (5147), `owned_account_erodes_slower` (5366), `founder_owns_accounts_manually` (5489), `destek_survives_ship` (13194), `destek_empty_desk_piles_up` (13411), `split_bars_name_their_cause` (14847), `paused_job_resumes_on_direct_return` (14799), `sales_meeting_time_skip_founder_share` (15794), `hr_read_catalogue` (10390), `job_assignment_and_idle` (10034, 26 iş okuması), `gorevler_has_no_founder` (13235), `hires_land_in_own_column` (5339), `overload_costs_output` (10176), `effective_skill_formula` (10504), `hr_overload_badge` (7260), `founder_trains_and_learns` (10306) | Masa sayımı, iş sayısı, `_validate_shape` | `job_assignment_and_idle` kurucuya ikinci sürekli işi verip üçüncüyü reddeder (K0 `:10131-10147`); "koşu başında tam bir iş" denetimleri (`:10118-10119, :10316-10317, :13253-13254`) başlangıç işi için hâlâ doğru, Karar 13'le uyumlu mu diye gözden geçirilir; `gorevler_has_no_founder` (13235) kurucu satırı beklentisi Karar 13'e göre yeniden okunur |
| K1 | `sprint_faulty_ticket_deterministic` (17447) | `founder_roles` override (`:17453`) | **[A2 düzeltme]** Karar 13'ten sonra da zar atılmaz (A2_DOGRULAMA §3). Vaka K3'te `sprint_faulty_bug_on_card_line` olur; K1'de yalnız regresyon |
| K1 (yeni) | `founder_not_double_counted` (§4.9), matris vakası (§4.10), `sprint_*` yeni fikstürler | | Falsification ile; `hotfix_founder_takes_support_desk` zaten üç masa hâlini kanıtlıyor (karakterizasyon) |
| K2 | `fix_run_ships_subset` (13466; 13 `fix_run` okuması, `BuildBarModel.derive`) | Hotfix | Silinir |
| K2 | `destek_survives_ship` (13194), `destek_empty_desk_piles_up` (13411), `product_read_catalogue` (13699), `save_v10_product_state` (14249), `event_beat_freezes_seams` (5854), `event_chip_coverage` (15158), `_seed_support_fixture` (13377) | `fix_run_*`, `REPORTS_WEEK_NET`, `reports_missed`, `bug_pile` | `fix_run` parçaları ayıklanır; `event_beat_freezes_seams` başka kartla yeniden yazılır |
| K3 | `sprint_fix_card_closes_tickets` (17484) → `sprint_fix_card_clears_its_line`; `sprint_faulty_ticket_deterministic` (17447) → `sprint_faulty_bug_on_card_line`; `sprint_save_roundtrip` (17727); `rnd_note_author_and_lines` (15002, 12 okuma); `save_v10_product_state`; `product_read_catalogue` (bug_confirmed kenarı `:13764-13782`); `infra_overage_applies_and_stops` (13601, C `:13630`); `sales_meeting_time_skip_founder_share` (C `:15806`); `b2c_satisfaction_drifts_to_experience` (11633, C `:11660`) | C, bilet defteri, `gate_faulty` | Yeni: `save_v15_tickets_become_open_bugs`, hat temizleme (§4.2), dağılım (§4.3, çok tohumlu sayım, falsification) |
| K4 | `sprint_fix_card_closes_tickets`, `sprint_ceiling_125_blocks_add` (17304); yeni `sprint_fix_preview_matches_close` (§4.6b) | Efor/acil/önizleme | `urgent_bugs` ve `fix_effort` ile |
| K5 | `callback_contract` (1541), `pitch_bug_interrogation` (1580), `b2b_lifecycle_and_countdown` (3019), `b2b_onboarding_grace_floor` (3077), `b2b_satisfaction_leaves_b2c_identical` (3141), `b2b_ignore_then_churn` (3289), `b2b_cs_absorbs_routine` (3740), `coupling_wear_team_average` (7718, 12 okuma), `coupling_cs_dampen_axis` (7761), `b2c_satisfaction_drifts_to_experience` (11633), `conversion_bug_penalty` (12093), `risk_exit_stamps_day` (12314), `sprint_release_resets_live_bugs` (17872), `axis_reading_replaces_not_adds` (13918), `b2b_pitch_meeting_signs` (3357), `sales_loss_reason_from_asked` (3576), `infra_local_provider_tradeoff` (13650), `prep_bonus_and_capacity` (`_is_free` `:2581-2590`), `save_v13_day_stamps_migrate` (2095) | L, aşınma, C okuyan satış/VC/kalite, `_is_free` ailesi | Bazıları silinir (`conversion_bug_penalty`, `coupling_wear_team_average`, `sprint_release_resets_live_bugs`), bazıları yeniden yazılır; yeni `neglect_reputation_below_zero`, `bugs_leave_sales_and_vc_alone`, `save_v15_callback_bugs_under` |
| K6 | `fix_run_ships_subset` (BuildBarModel), `product_read_catalogue` | Destek kartı modeli | Arayüz doğrulaması smoke ile değil görsel kabulle (CLAUDE.md §10) |
| K8 | Smoke'ta `bug_trend`, `health_state`, `product_bug_risk` çağrısı yok | Ölü kod | Vaka silmeye gerek yok |

**Ortak smoke yardımcıları** (K1'de ekip kuran, K3-K5'te hata kuran): `_seed_sprint` (17113), `_seed_sprint_live` (17122), `_sprint_hire` (17131), `_sprint_points` (17138), `_play_sprint` (17153), `_seed_build_crew` (14518), `_make_employee` (610), `_seed_live_product` (697), `_seed_support_fixture` (13377), `_seed_risk_account` (12253).

### 9. PRD listesinde olup kodda bulunmayanlar
- `ProductState.open_bugs / open_bugs_by_line / line_bugs / add_bugs / clear_line_bugs / line_blocked / open_bugs_delta / snapshot_open_bugs / worst_bug_line`: yok (`product_state.gd` grep).
- `EventBus.line_bugs_cleared`: yok (`event_bus.gd`).
- `SalesArchetypes.uses_axis`, `USE_AXIS_MIN`: yok (`sales_archetypes.gd` grep); `axis_weights` (`:157`) var.
- `SprintCatalog.line_impact / line_accounts / line_share / bug_line`: yok.
- `_migrate_16`, `save_v15_*` vakaları: yok. Mevcut vaka adları `save_v10_*`, `save_v13_*`, `save_v14_*`.
- Haftalık itibar yazarı: yok (`set_reputation` yalnız `effects.gd:240-241`'den).
- `RunProbe` `fix` anahtarı, `PROBE FIX`, dört kol, `fix_off` anahtarı: yok.
- `reset_all_owners` içinde SprintSystem/ProductState girdisi: yok (bkz. §5).
- `PRODUCT_BUGS_TIP*`, `HUNT_CB_AXIS`: CSV'de yok (yeni anahtar).
- Yeni smoke vakaları (`sprint_fix_preview_matches_close`, `neglect_reputation_below_zero`, `founder_not_double_counted`, `bugs_leave_sales_and_vc_alone`, matris vakası): yok.
- PRD §6 "B2C kolu kurucuyu Destek'e taşır": `run_probe.gd:1089-1098` mevcut; yeniden kurulacak.
- PRD §6 `axis_stability` kartları: `b2c_floor_*`, `shutdown_notice`, `b2c_creator_feature` aslında `urun.floor_stability` (bkz. §0).

### 10. Açık sorular / riskler
1. **Silinen kartın kayıtta kalan satırları.** `systems.event_engine` bloğunda `product.bug_pile` kuyruk/aktif/kâğıt satırı varsa yükleme `push_error` basar (`queue.gd:217, :224`, `papers.gd:193`), ve `gate_common.sh:9` bunu `^ERROR:` sayar. 33c5323 (16 kart silme) göçte temizlememişti. `_migrate_16` bu üç listeyi temizlesin mi?
2. **§4.1 grep istisnası dar.** İstisna yalnız `_migrate_16` ve şema 15 fikstürleri; `_migrate_14` içindeki `mvp_bug_history` kırpması (`save_manager.gd:724-725`) ve `save_v13_day_stamps_migrate`'in `[5]` beklentisi (`endgame_smoke.gd:2240`) dışarıda kalıyor. Satırlar silinmeli (göç zaten bayrağı atıyor) ya da istisna genişletilmeli.
3. **Karar 13 ile `hr.job`.** `hr.job` yalnız İLK işi döndürür (`seams_hr.gd:83-87`); beş kart `== "build"` ister (`sprint_rewrite_*`, `sprint_unasked_rewrite`, `named_in_leak`). Destek+Yapım tutan geliştirici sprintte 0,5 sayılır ama ilk işi Destek ise bu kartların seçicisine girmez. Seçici `SprintSystem.team()` ile mi hizalansın, yoksa B'ye bırakılsın mı?
4. **%40 zarı ve `founder_roles`.** Kurucu `sprint.json:23` yüzünden her role uyar, yani Yapım'daki kurucu Test fazını rolsüz bırakmaz (`sprint_system.gd:796`) ve zar atılmaz. **[A2 düzeltme: yanlış]** Kurucu sprintten çıksa da zar atılmaz: geriye kalan her geliştirme/test kişisi (geliştirici, test uzmanı) `test`'e uyar, tasarımcı ve PM Test fazına giremez (`ahead`, `sprint_system.gd:530, 765-766`). K1 raporu zarı ekonomi kayması sebebi saymaz (A2_DOGRULAMA §3).
5. **İki işli kurucuya oyuncu yolu yok.** Görevler matrisi yalnız çalışanları listeler (`hr_assignments.gd:42` `get_employees()`; `gorevler_has_no_founder`, `endgame_smoke.gd:13235`), tek UI yazıcısı `hr_tab.gd:468`. Kurucunun işini bugün yalnız başlangıç işi, Ar-Ge oturması (`rnd_system.gd:304`), bot (`run_probe.gd:1089-1098`) ve debug değiştirir. Karar 13'ün "Yapım+Destek tutan kurucu 0,5" hâli oyuncu için erişilemez, yalnız botta ve fikstürde var: gerçek oyunda kurucu Destek'e atanabilsin mi (A'nın kapsamı mı)? Bot tarafında çalışansız B2C koşusunda kurucu Yapım+Destek tutarsa sprint puanı 0,5'e iner; `full_run_b2c` ve dört kolun tabanı kayar, K1 sonrası yeniden ölçülmeli.
6. **`fix` anahtarının varsayılanı.** `run_gate.sh:19` ve `plausibility.gd:140-143` `fix` anahtarı olmayan presetleri koşar. Varsayılan kol hangisi (`fix_worst`?) ve `run_gate` presetleri K2'den sonra hangi düzeltme davranışıyla koşacak? Bugün bot Hotfix kullanıyor; K2'de blok gidince K5'e kadar düzeltme yapan kol yok (lider zaten acil kartları alıyor).
7. **Hata duyarlılığı kaybı onayı.** A_PLAN 5.1 s.6 `axis_reading`'in −2/hata terimini K5'te siler; `launch_leak`, `password_rule` ve dört `floor_stability` kartı hataya tepki vermez olur. PRD Karar 8 bu sonucu adıyla saymıyor (dönüşüm, toplantı, yıldız, VC, term sheet sayıyor). Kesim yalnız satış/VC'ye mi uygulansın, olay kartları hata duyarlı mı kalsın?
8. **VC koşulu sınırı.** Yeni geri dönüş "En zayıf eksen > 40"; `_weakest_dimension` `worst_v < 40.0` ise zayıf sayar (`vc_pitch_system.gd:1308`), yani 40 tam sınırda zayıf değil. "> 40" ile "≥ 40" farkı ve `dims_from_flags` ham eksen (hata terimsiz) olması netleşmeli; `HUNT_CB_AXIS` metni "> {n}" diyor. **[A2]** Ham eksen 40'a varmaz (ACIK_KARARLAR 59): eşitlik değil ölçek sorunudur, E1'e.
9. **Eski sürüm kayıtlarında "6 → 0".** `releases[].shipped[]` kartları `tickets` dizisi taşır (`sprint_bridges.gd:204-207`); `bugs_before/after` yok. Sürüm notu geri dönüşü (yalnız kapanan sayı mı, satır mı gizli) K4'te kararlaştırılmalı; koşan düzeltme kartının eforu göçte korunmalı.
10. **Rastgele dağılım ve sabit eşikler.** `b2c_refunds` (≥8 toplam), `bug_pile` yok, `COMPLAINT_BUG_GATE` 6 (hesap başına), acil eşik 3 hat başına: dağılım hatları seyreltince hat başına sayı düşer, toplam aynı kalır. Bu üç eşiğin hangisi toplama hangisi hatta bağlı tutulsun (A_PLAN 5.4 "var olan değer" der)? Değerler "onay bekliyor" ve K5 ölçümüne göre.

### A2 · Bu katmana eklenen satırlar (tamlık süpürmesi)

| Kalem | Dosya:satır | Bugün (okur/yazar, ne yapar) | Yeni karşılığı (PRD kararı) | Dilim | Not |
|---|---|---|---|---|---|
| `axis_readings` hata parametresi | product_state.gd:254-256; quality_model.gd:239-245 | Üç okumayı birlikte C ile kurar; tek okuyucusu smoke `save_v10_product_state` (14287, 14341-14344) | K3'te O, K5'te parametre kalkar | K3, K5 | Haritada yalnız tekil `axis_reading` vardı |
| PROBE CUST sağlık değeri | run_probe.gd:505 | `axis_score(economy_dims_from_flags(), "stability")` | Ham eksen (K5) | K5 | `^PROBE` biçimi değişirse tablo betiği de |
| Kararlılık fikstürü yorumu | run_probe.gd:1711 | "ordinary product wear can push them under" | Aşınma yok; fikstür O ile kurulur | K5 | |
| Hotfix bloğunun pazarı | run_probe.gd:1111-1117 | `bugs_confirmed() >= 6` ise iki pazarda da bir geliştiriciye Destek'i ikinci iş verir | K1 sonrası o geliştirici koşu boyunca sprintte 0,5 sayılır; K2 bloğu siler | K1 (kayma), K2 (silme) | `full_run` da kayar, yalnız `full_run_b2c` değil |
| Smoke `sprint_solo_mvp_by_week_six` | endgame_smoke.gd:18052-18071 | Tek kurucu dört rolde tam hız, MVP altıncı tikte | Kurucu Yapım'da kalır; K1 sonrası da geçmeli | K1 (regresyon) | Falsifikasyonu `founder_roles` üzerinden (18054) |
| Smoke `cs_renewal_floor` | endgame_smoke.gd:19423-19458 (19445-19453) | `B2BSalesSystem.risk_voice` onboarding kolunu sınar | `risk_voice`'un hata kuralı hesap başına olur; vaka hatasız kurulduğu için kalmalı | K5 (regresyon) | |
| Smoke `series_a_road_closed_when_all_funds_close` | endgame_smoke.gd:2509-2519 | `_make_callback("meridian")` = ürün geri dönüşü (`bugs_under`) | Yeni koşul türüyle yeniden okunur | K5 | **PLAN ETKİSİ** ile bağlı |
| Smoke `b2c_value_reads_live_lines` | endgame_smoke.gd:12130-12155 (12148) | `shipped_normalized` okur | Ham eksene döner | K5 | |
| Smoke falsifikasyon yorumu | endgame_smoke.gd:13398-13410 | "kaçırılan", `fix_run_refusal` anlatır | K2'de vaka ile birlikte | K2 | |
| K1 regresyon vakaları (haritada yoktu) | `sprint_mvp_three_identity_k1`, `sprint_never_stalls_in_plan`, `sprint_paid_plan_opens_paid_tier`, `sprint_request_on_time_met`, `sprint_two_days_close`, `sprint_legacy_beta_cards_ship`, `sprint_decision_card_fires_shipped`, `sprint_lead_offers_paid_plan_b2c` (18044), `product_paid_plan_locked_until_mvp`, `promise_due_sprint_kept_when_shipped_next_sprint`, `quiet_cards_fill_empty_floor`, `cheque_read_steps`, `event_history_chip_matches_live`, `b2b_onboarding_to_prospect_visible`, `save_double_load_no_residue`, `save_v14_build_becomes_sprint_plan`, `hotfix_weekly_summary_rows`, `research_abandon_keeps_progress`, `research_completion_no_economic_delta`, `hr_experience_accrues`, `hr_morale_drift_shape`, `sales_desk_deal_runs_its_plan` | Sprint kurar, kart oynar ya da kurucunun/çalışanın işini değiştirir | Kurucu Yapım'da kaldıkça değişmez | K1 (regresyon) | K0'ın "≈27 vaka sprint başlatır" sayısının adları |
| `_migrate_15` açıklaması | save_manager.gd:805-810 | "the first daily sync attributes them to capabilities, so the ticket ledger starts empty" | K3 sonrası `_migrate_16` C'yi hatlara dağıtır; yorum bayatlar | K3 | INT-9'un sebebi bu cümlede |

---

## Katman C · Arayüz ve belgeler (A1c)
HEAD 1faeb82, 2026-10-16. Kapsam: PRD §6 "Arayüz" ve "Belgeler". Salt okuma; her satır açılmış bir dosyaya dayanır.
Karar n = PRD §2 kararı. Dilim = PRD §8 K1..K8 (K1 Görevler matrisi + kurucu · K2 Hotfix/koşu/Kaçırıldı/Hata yığını silinir · K3 tek depo + rastgele dağılım + şema 16 (1) · K4 düzeltme kartı + sürüm notu · K5 etki zinciri, aşınma ve L silinir, itibar, kollar, göç (2) · K6 hat paneli + Destek kartı · K7 sönük düğmeler · K8 ölü kod + belgeler).
"(a)" ve "(b)" öteki iki okuyucunun katmanıdır (sistemler; olay motoru, veri, kayıt, araçlar). Burada yalnız arayüzün okuduğu yerde, o satırın arayüze etkisi için anılırlar.

### 0. Öne çıkan bulgular (ayrıntı aşağıda, risk özeti §15'te)
1. **Görevler matrisinde kurucu satırı yoktur.** `hr_assignments.gd:42` yalnız `get_employees()` çizer (`character_registry.gd:41-46`, kategori "employee"). Oyuncunun kurucuya iş atayabildiği hiçbir arayüz yolu yoktur (`assign_job` çağıranları: `hr_tab.gd:468` yalnız çalışan satırları, `rnd_system.gd:304`, `main.gd` debug, `run_probe.gd`). Karar 13'ün "Yapım ve Destek tutan kurucu" durumu bugün yalnız bot ve debug ile doğar. Ekip GDD §12 de "Kurucu bu matriste bulunmaz" der (docx paragraf 779). Smoke `_case_gorevler_has_no_founder` (`endgame_smoke.gd:13235`) bunu kilitler. **[A2]** Oyuncunun kurucu için tek yolu Ar-Ge'dir (rnd_system.gd:292, 304, 360; araştırma bitince Yapım `resume_paused_jobs` ile döner): işsiz kurucu (pasif ilgi) de normal oyunda doğmaz.
2. **Ofiste kurucu sprint açılışına her zaman yürür.** `office_people.gd:454` `a.founder or team.has(...)`. K0'ın "kurucu `team()`'den çıkınca açılıştan çıkar" notu kodla örtüşmez.
3. **`HR_AREA_MEANING_*` oyuncuya hiç çizilmez.** Tek okuyucu `HRConstants.role_area_meaning` (`hr_constants.gd:1180`); onu yalnız smoke çağırır (`endgame_smoke.gd:7356`). Test işinin "canlı hata aşınması" vaadinin gerçekten çizilen tek yeri `ONB_SKILL_QA_DESC` (onboarding adım 2, `origin_traits_step.gd:259`).
4. **Canlı modelde `customer.tickets` hep 0'dır** (`product_model.gd:190`); `area_panel.gd:234-236` "N ticket" dalı canlıda erişilemez, yalnız fikstürde (`product_fixtures.gd:359`) çizilir.
5. **Ekip GDD'de "canlı aşınma Test alanının işi" cümlesi birebir yok.** `GDD — EKİP MODÜLÜ vson.docx` paragraf taraması "aşınma" bulmadı. En yakın metinler: `GUNCELLEMELER.md:611` ("Test beta keşif hızını ve Kararlılık tabanını oynatır") ve docx §12.0 tablosu (paragraf 787-789 "Test / beta keşif hızı"), paragraf 1039 ("hata oranı · beta keşif hızı").
6. **Çeyrek görünümünün dar sütunu da `AreaPanel`'i kullanır** (`quarter_view.gd:55-60`, `compact=true`); ses çipi (`area_panel.gd:116-124`) ve alan cümlesi orada da çizilir.
7. **Destek kartı sürükleme tutamağıdır.** `build_hud_panel.gd:82-99` kartın her yerindeki basışı sürükleme sayar; "tıklayınca Ürün aç" (PRD §3) tık/sürükle ayrımı ister.
8. **Alan başına acil/uyarı üçgeni** (`area_panel.gd:95-96`) `urgent_tickets` eşiğine bağlı (`sprint_catalog.gd:143-150`); PRD üçgeni anmıyor, Karar 4 eşiği değişince anlamı da değişir.
9. **`hotfix_*` smoke önekleri 2026-08 yama turunun adıdır** (`endgame_smoke.gd:241-248`, HARITA:213); K2 "Hotfix siler" derken bu vakalara dokunmamalı. "hotfix" izinli ödünç kelime olarak CLAUDE.md:53 ve glossary:10'da durur.

### 1. Hat paneli (AreaPanel ve alan modeli)
| Kalem | Dosya:satır | Bugün (okur/yazar, ne yapar) | Yeni karşılığı (PRD kararı no.) | Dilim | Not |
|---|---|---|---|---|---|
| Ses katlaması durumu | area_panel.gd:10, 18, 27 | `ui_changed(open_area, voices_open)` sinyali; `_voices_open` modelden tohumlanır | Kalkar (§3 "Sesler bölümü yoktur"; Karar 12). Sinyal yalnız `open_area` taşır | K6 | `product_tab.gd:212-216` `_on_ui_changed` imzası da değişir |
| Alan satırı ses çipi | area_panel.gd:116-124, 187-198 | `area.voices.n > 0` ise `CountChip` içinde ses simgesi + sayı + "k yeni" | Kalkar. Yerine kapalı satırda "N açık hata" (Karar 1; §3) | K6 | Dar çeyrek sütununda da çizilir (quarter_view.gd:55-60); `CountChip` yalnız burada kullanılır (build_theme.gd:998) |
| Alan uyarı üçgeni | area_panel.gd:95-96 | `area.alert` doğruysa warn glifi | Anlamı Karar 4 acil eşiğine bağlı; PRD üçgeni anmıyor | K5/K6 | Veri: product_model.gd:153 → sprint_catalog.gd:143-150 (`urgent_tickets` ya da sunucu aşımı). Soru §15-7 |
| Alan cümlesi | area_panel.gd:128-130 | `area.sentence` Caption olarak yazılır | "9 açık hata" yanında "sorunsuz yürüyor" yazmaz (§3) | K6 | Cümle kaynağı sprint_catalog.gd:154-171 (alan × durum şablonu + "N açık ticket" + rakip) |
| Açık gövde: YAPILANLAR/YAPILABİLECEKLER | area_panel.gd:136-161 | Kademe kareleri; aday kartlar `SprintCard.Look.LOW` | Aday kartlar arasında düzeltme kartı kalır (Karar 5) | K4 | Hat satırı ile düzeltme kartı aynı bilgiyi iki kez verebilir (§15-4) |
| SESLER bölümü | area_panel.gd:163-183 | Başlık, katlama satırı, açılınca ses cümleleri ("Yeni" damgası) | Kalkar; yerine "yalnız hatası olan hatlar" tek satır `bug_row` (Karar 6; §3) | K6 | B2B: "Fatura · 6 açık hata · 3 hesap · 140 kullanıcı ↑"; B2C: "Eşitleme · 5 açık hata · 300 kullanıcı ↓". Ok anlamı PRD'de yazılı değil |
| Ses sayacı çizici | area_panel.gd:186-198 | `_add_voice_counts` (`SprintUiShared.VOICES` glifi) | Silinir | K6 | `voices.svg` yalnız burada kullanılır (sprint_ui_shared.gd:12) |
| Ses katlama tıkı | area_panel.gd:273-278 | `action.emit("voices_seen", {area})` + `ui_changed` | Silinir | K6 | `product_tab.gd:248` `voices_seen` kolu, `SprintSystem.voices_seen` (sprint_system.gd:376-378, (a)) ve `GameState.product.voices_seen` (sprint_system.gd:83, (a)/(b)) birlikte gider |
| Müşteriler satırı "N ticket" dalı | area_panel.gd:234-236 | `c.request == ""` ise `PRODUCT_CUSTOMER_TICKETS` | Silinir (Karar 1, 12 "N ticket metinleri") | K6 (K8 doğrular) | Canlıda erişilemez: product_model.gd:190 `"tickets": 0` ve yalnız açık talepli müşteri listelenir (:183-194) |
| Başlık yorumu | area_panel.gd:4-7 | "…aday kartları ve sesleri" | Yorum güncellenir | K6 | CLAUDE.md §8 yorum kuralı |
| Model sözleşmesi: alan | product_model.gd:29-33 | `voices: {n,new}`, `voices_list`, `alert` | `voices*` kalkar; hat dökümü eklenir (örn. `bug_lines`) | K6 | Fikstür aynı sözleşmeyi taşır (product_fixtures.gd:519-520, 530-534) |
| Model sözleşmesi: müşteri | product_model.gd:34-36 | `tickets` alanı | Kalkar | K6 | |
| Model: `ui` | product_model.gd:23, 132 | `voices_open` | Kalkar | K6 | product_fixtures.gd:599 aynı |
| Model: alan kurucu | product_model.gd:144-161 | `voices := SprintCatalog.voices(id)` (:146), `voices` sözlüğü (:152), `voices_list` (:155), `sentence` (:151), `alert` (:153) | Hat dökümü (hat, açık hata, hesap, kullanıcı, en büyük hesap) `line_impact` / depodan okunur | K6 (veri K3, K4) | `line_impact` `{accounts, seats, top_id, top_seats}` bugün kodda yok (PRD §2 Karar 6, §14) |
| Katalog: SESLER | sprint_catalog.gd:174-198 | Açık ticket başlıkları + araştırma cümlesi + rakip çıkışı, "yeni" ayrımı (`voices_seen`, `voices_new_weeks`) | `voices()` silinir | K6 | sprint.json:33 `voices_new_weeks` da ölür |
| Katalog: ticket başlığı | sprint_catalog.gd:201-203 | `PRODUCT_TICKET_%d` dinamik anahtar, `content.ticket_titles` (sprint.json:43) | Silinir (Karar 1, 12) | K3 | Dinamik anahtar: grep `PRODUCT_TICKET_0` bulur ama okuyucuyu bulmaz (§11-B) |
| Katalog: hata/ticket dökümü | sprint_catalog.gd:624-630 | `tickets_by_line` (okuyucular: :146, :160, :261, rnd_system.gd:601, sprint_system.gd:1194) | Tek hata deposundan hat dökümü (Karar 1, 3) | K3 | rnd_system.gd:595-603 R&D "talep baskısı" notunu bu oylarla besler; GUNCELLEMELER.md:668 ona dayanır |

### 2. Düzeltme kartı (kart, etki parçaları, öngörü)
| Kalem | Dosya:satır | Bugün | Yeni karşılığı | Dilim | Not |
|---|---|---|---|---|---|
| Aday düzeltme kartı üretimi | sprint_catalog.gd:261-269 | Hat başına açık ticket varsa `fix:<hat>` kartı; `urgent_tickets` ≥ eşikse efor `fix_urgent`; `card.tickets = ids` | Hat başına açık hata varsa kart; efor 1-2 hata 1, 3-5 hata 2, 6+ hata 3 (Karar 7); kademeler `sprint.json`'da tek ayar | K3/K4 | sprint.json:6 `effort.fix`, `fix_urgent`; :36 `urgent_tickets`; :42 `impact.ticket` |
| Acil yüklemi | sprint_catalog.gd:284-285 | `fix` ve `tickets.size() ≥ urgent_tickets` | Eşik ve zorunluluk Karar 4'e göre yeniden ele alınır | K4/K5 | `is_urgent` okuyucuları: sprint_catalog.gd:148 (alan uyarısı), :275 (sıralama), :809 (bot `must`); product_model.gd:417; sprint_card.gd:191 |
| Kart adı | sprint_catalog.gd:312 | `PRODUCT_FIX_CARD` "{capability} düzeltmesi" | "Fatura düzeltmesi" + kartta: hata sayısı, hesap, kullanıcı, B2B'de en büyük hesap adı ve koltuğu (Karar 6) | K4 | `top_star` / `{stars}★` yok sayılır (PRD §0 madde 1) |
| Etki satırı (fix) | sprint_catalog.gd:347-354 | `{k:"tickets", n}` + `alert_clear` | Yeni parça (hat, hata, hesap, kullanıcı, en büyük hesap) | K4 | Sözleşme: product_model.gd:74 |
| Etki parçası çizici | sprint_ui_shared.gd:287-327 (özellikle :309-311) | `"tickets","voices"` kolu `COUNT_KEYS` ile "{n} ticket kapatır/kapanır" | `tickets` kolu yeni `bugs` parçasına çevrilir; `voices` kolu silinir | K4 (voices K6) | `COUNT_KEYS` tablosu sprint_ui_shared.gd:26-29; yalnız fikstür `voices` parçası üretiyor (product_fixtures.gd:500) |
| "Acil" etiketi | sprint_card.gd:191-192 | `PRODUCT_URGENT` "Acil" uyarı üçgenli etiket | B'nin "acil durum" olayıyla karışmayacak ad (Karar 4) [TR/EN onay bekliyor] | K4 | Etiket stilleri HARITA:150 `TagWarnBox`/`TagWarnInk` |
| Kart efor/urgent alanı | product_model.gd:411-419 | `effort = roundi(SprintSystem.total(c))`, `urgent = SprintCatalog.is_urgent(c)` | Planlanmamış kartın efor ve sayıları her çizimde yenilenir; koşan kartın eforu kilitli (§4.6c) | K4 | Aday kart `stored.get(c.id, c)` anlık görüntüsü (sprint_catalog.gd:274) günlük tikle yenilenir (sprint_system.gd:1194-1199, (a)) |
| Düzeltme kartı satırı genişliği | sprint_card.gd:80-94, 126-127 | WIDE'da ad `OVERRUN_TRIM_ELLIPSIS`; öbür görünüşte 2 satır sarar; etki satırı `HFlowContainer` | Uzun hesap adı taşmamalı (§4.12 "uzun hesap adıyla") | K4 | Yeni `--product-shot=edge:<ad>` fikstürü gerekir |
| Öngörü (SPRINT SONUNDA) | sprint_catalog.gd:378-403; sprint_panel.gd:128-130 | Fix kartlarının ticket kimlikleri toplanır, `{k:"tickets", n}`; "!" kalkışı | "6 hata kapanır" (§3); önizleme N = kapanışta silinen (§4.6b) | K4 | Kapanışta gerçek sayı: sprint_system.gd:1011-1012 (`close_tickets`, (a)) |
| Karar 7 eforu | sprint.json:6 | `fix:1, fix_urgent:2` | Tek ayar, kademeli | K4 | E1 cevabı yalnız bu değerleri değiştirir |
| Fiyat/etki puanı | sprint_catalog.gd:715-719 | `w.ticket * tickets.size() + alert` | Hata sayısına göre | K3/K4 | (a) kapsar |
| Düzeltme kartı düğmeleri | product_model.gd:82-89 | `BUTTONS` tablosu | Değişmez | - | K7 yalnız görünümü değiştirir |
| Müşteri kartı "+"/"→" | area_panel.gd:244-247 | `SprintUiShared.key_button` | Karar 14 sönük/parlar | K7 | |

### 3. Sprint planı: ekip listesi, kapasite çubuğu, atananlar, Görevler
| Kalem | Dosya:satır | Bugün | Yeni karşılığı | Dilim | Not |
|---|---|---|---|---|---|
| Ekip listesi (avatarlar) | product_model.gd:204, 268; sprint_panel.gd:93-102 | `SprintSystem.team()` (Ar-Ge hariç herkes, kurucu daima) → `_person(...)`: ad, rol metni, yüz | Yalnız Yapım ekibi + Test işini tutan; Destek'teki dışarıda; Yapım+Destek yarım payla (Karar 13; §3) | K1 | Model kişisine pay (0,5) eklenmeli; avatar ipucu sprint_ui_shared.gd:210-215 pay göstermiyor (görünür yeri K1 kararı) |
| Kapasite toplamı | product_model.gd:203, 371; sprint_ui_shared.gd:116-121 | `SprintSystem.capacity()` (= Σ `team().points` × hafta, sprint_system.gd:446-450, (a)) | Aynı çağrı; `team()` payı uygular (Karar 13) | K1 | Çubuk kodu değişmez (`CapacityBar` sprint_ui_shared.gd:55-85); veri değişir. Çeyrek sütunları aynı toplamı kullanır (product_model.gd:371, quarter_view.gd) |
| Boş kadro / kimse çalışamıyor | sprint_panel.gd:119-120, 172-189; product_model.gd:260-263 | Ekip ve kart yoksa `_nobody` (Ar-Ge'ye git / işe al / `PRODUCT_GO_TEAM` Ekip'e git); kart varsa yalnız `start_reason` metni | "Sprintte kimse yoksa plan bunu söyler ve Ekip'e bağlar" (Karar 13; §3) | K1 | Boşluk: ekip boş ama kart doluysa bağ yok (yalnız metin, product_model.gd:263). `PRODUCT_TEAM_NOBODY` metni TR/EN onay bekliyor. Ek yol zaten var: product_tab.gd:249 `"team"` kolu |
| Rol uyarısı | product_model.gd:248-249 | `team` içinde `"test" in t.fits` yoksa `PRODUCT_ROLE_MISSING` | Aşama uyumu bugünkü kuralla kalır (Karar 13 sınır, D) | - | `fits` alanı `SprintSystem._fits` (sprint_system.gd:1272-1276) |
| Boştaki kişi notu | product_model.gd:251-254 | `team` içinde `role_of(id) == ""` sayılır; öneri `PRODUCT_IDLE_FIX` (koşu açılabiliyorsa) ya da `PRODUCT_IDLE_PLAN` | "Boşta" yalnız gerçekten sprintte olan ve kartsız kişiyi sayar; kartı olan kurucu "Boşta" görünmez (Karar 13) | K1; `PRODUCT_IDLE_FIX` K2 | `can_start_fix_run` K2'de gider → öneri hep `PRODUCT_IDLE_PLAN` |
| Kart atananları | product_model.gd:229, 234, 238, 484-488; sprint_card.gd:256-257 | `_people(c.assignees, team)`: atananı `team` kimlikleriyle süzer | `team()` daralınca Destek'e geçen kişi koşan kartın avatarından düşer | K1 | `assignees` yazımı (a) (`_assign`) |
| Araştıran kurucu | product_model.gd:256-259, 263 | Kurucu Ar-Ge işini tutuyorsa `rnd` metni | Değişmez | - | Matris kuralıyla çelişmez (Ar-Ge tek başına tutulur) |
| Kadroda çalışan var mı | product_model.gd:269 | `get_employees().is_empty()` → `_nobody` yolu | Aynı | - | |
| Mesai modalı sprint puanı | work_hours_modal.gd:211-228 (217-218) | `SprintSystem.week_points()` ve taslak | `team()` değişince değerler değişir | K1 | Kurucu tek başınayken de gösterilir (yorum :211) |
| İşe alım dosyası puanı | hr_atlas_modal.gd:343 | `SprintSystem.points_for(role, axes, hours)` (adayın puanı) | Değişmez (aday atanmamış, pay yok) | - | Not: pay gösterilmez, tutarlılık sorusu |
| Görevler matrisi: satırlar | hr_assignments.gd:7-8, 42-48 | Yalnız çalışanlar; başlıkta "KURUCU BURADA YOK… sprint ekibine kendiliğinden girer" | Başlık yorumu doğru olmaktan çıkar (Karar 13); kurucu satırı kararı bekliyor (§15-1) | K1 | Smoke `_case_gorevler_has_no_founder` endgame_smoke.gd:13235-13258 "exactly one job" iddiası; Ekip GDD §12 paragraf 779 |
| Görevler matrisi: kutu | hr_assignments.gd:106-128; hr_tab.gd:464-473 | İş tavanı `MAX_JOBS_PER_PERSON` (kilitli kutu "HR_ASSIGN_JOB_CAP"); tık → `CharacterRegistry.assign_job` | Aynı yazma kapısı; sprint payı bu kutulardan türetilir | K1 | `HRConstants.focus_mult` (hr_constants.gd:184, (a)) |
| Görevler etiketleri | hr_tab.gd:450-459 | `HRSystem.idle_count() + waiting_count()` ve aşırı yük etiketi | "Boşta" tanımı Karar 13 ile uyumlu kalmalı | K1 | `idle_count` sahibi (a) |
| Kurucu görev satırı | hr_system.gd:221-237; tüketiciler personal_tab.gd:92, hr_dossier.gd:143, rnd_assign_panel.gd:182 | Kurucu 2+ işteyse "Yapım · Destek"; Yapım durumunda kart yoksa `OFFICE_ACT_PLAN` (`role_of == ""`, :235) | "Sprintte kartı olan kurucu Boşta görünmez" (Karar 13) | K1 | `founder_task_state` hr_system.gd:240-262 (a) |
| Karar 13 smoke | endgame_smoke.gd (vaka adı `_case_*`) | `_case_gorevler_has_no_founder` :13235; `_case_hotfix_founder_takes_support_desk` (K0:109) | `founder_not_double_counted`, Görevler matrisi vakası | K1 | Falsification şart (CLAUDE.md memory: SMOKE kuralı) |

### 4. Sürüm notu (sprint kapanış görünümü ve modeli)
| Kalem | Dosya:satır | Bugün | Yeni karşılığı | Dilim | Not |
|---|---|---|---|---|---|
| Çıkan kartlar listesi | product_model.gd:297-313 (304); sprint_panel.gd:238-246 | `shipped` = `_card(c, BITTI)`: tür simgesi, ad, efor kutusu | Düzeltme kartı satırı kapanıştaki gerçek sayıyı yazar: "Fatura düzeltmesi · 6 → 0 açık hata" (§3) | K4 | Kapanıştan sonra kartın hata listesi (sprint_system.gd:1011 `c.tickets = close_tickets(...)`, (a)) önceki sayıyı kaybeder; "6 →" için kapanış öncesi sayı saklanmalı. Sprintte yeni hata düştüyse "9 → 0" |
| Sonuç satırı (gerçekleşen) | sprint_bridges.gd:192-210 (209); product_model.gd:316-321; sprint_panel.gd:264-265 | `PRODUCT_RESULT_TICKETS_ACTUAL` "N ticket kapandı" | "6 hata kapandı" (§3) | K4 | (a) üretir, arayüz yalnız `SprintBridges.resolve` ile okur; CSV 2994-2995 |
| Sonuç satırı (beklenen) | sprint_system.gd:1107-1114 (1113) | `PRODUCT_RESULT_TICKETS_EXPECTED` | "N hata kapanmalı" | K4 | CSV 2992-2993 |
| Basın/hız/lider | sprint_panel.gd:257-286 | Değişmez | - | - | |
| Kapanışın itibar sebebi | (yok) | - | Karar 10: sebep bir yüzeyde görünür (sürüm notu / haftalık özet / Destek kartı ipucu); ajan önerir | K5 | Aday yüzey burası (§7 ile birlikte). Yeni anahtar gerekir |
| Sürüm notu fikstürü | product_fixtures.gd:131-139 (`gate`), 120-130 (`no_release`), 179-187 (`publish`) | c3 tabanlı sürüm notları var | Düzeltme kartı satırlı sürüm notu için yeni `edge:` (§4.12) | K4 | HARITA:157 ada eklenir |

### 5. Destek kartı (BuildBar, BuildBarModel, BuildHUDPanel)
| Kalem | Dosya:satır | Bugün | Yeni karşılığı | Dilim | Not |
|---|---|---|---|---|---|
| Model: doğrulanmış hata | build_bar_model.gd:30, 50 | `ProductState.bugs_confirmed()` | Tek açık hata sayısı (Karar 1) | K3 (okuma), K6 (yüzey) | 11 okuyucudan biri (K0) |
| Model: gelen bildirim | build_bar_model.gd:31, 51 | `ProductState.reports_incoming()` | Kart "Gelen" göstermez (§3) | K6 | Sayaç hayatta kalıp kalmayacağı (a) kararı (sistem: `support_system.gd:123, 357`) |
| Model: kaçırılan | build_bar_model.gd:32, 52; build_bar.gd:151 | `ProductState.reports_missed()` → `BUILD_SUPPORT_MISSED` | "Kaçırıldı" kalkar (Karar 12) | K2 | CSV 592 |
| Model: düzeltme koşusu | build_bar_model.gd:14-19, 33-34, 53-63, 72-73 | `fix_run_active`, `fixed`, `fill`, `percent`, `decision_key`, `decision_enabled`, `refusal_key`, `REFUSAL_KEYS` | Hepsi kalkar (Karar 12) | K2 | `fingerprint()` (:71-73) yeni alanlarla yeniden kurulur; `smoke` `destek_survives_ship` (:13195-13222), `fix_run_ships_subset` bu modeli çağırır |
| Model: bölünmüş odak notu | build_bar_model.gd:24-26, 63-66; build_bar.gd:147-148 | Masadaki biri aşırı yüklüyse `BUILD_SPLIT_FOCUS` | Muhtemelen kalır (Karar 13 yarım pay) | K6 | PRD §3 "tek satır" ile ilişkisi yazılı değil (§15-6); smoke `split_bars_name_their_cause` :14845-14871 |
| Kart: DESTEK satırı | build_bar.gd:87-102, 149-153 | "DESTEK", Doğrulanmış {n}, Gelen {n} ya da kaçırıldı; yüzde ve ilerleme çubuğu (koşu sürerken) | Tek satır "7 açık hata ›"; düğme, yüzde, Doğrulanmış/Gelen yok (§3) | K6 | `_percent_label`, `_progress`, `PROD_PERCENT` okuyucusu burada düşer (CSV 594 öbür okuyucular: rnd_ui_shared.gd:113, research_bar.gd:150) |
| Kart: eylem düğmesi | build_bar.gd:104-120, 171-178 | `FloatAction` düğmesi `start_fix_run`/`end_fix_run`; gerekçe `_refusal_label` | Kalkar (Karar 12) | K2 | `PLAY_ICON`/`END_ICON` sabitleri build_bar.gd:21-22 |
| Kart: tıklama | build_hud_panel.gd:82-99 | Kartın her yeri sürükleme tutamağı | Tık → Ürün penceresi, en çok hatası olan hattın alanı açık (§3) | K6 | Mekanizma önerisi: `EventBus.tab_changed.emit("product")` + `window_layer.gd:140 get_current_page_body()._set_ui(area_id, "open_area")` (product_tab.gd:207-210); fikstürde aynı kalıp var (main.gd:3187). Tık-sürükle eşiği gerekir; eşitlikte hat seçimi belirsiz |
| Kart: otomatik başlama notu | build_bar.gd:122-127, 164-166 | `PRODUCT_AUTO_STARTED` | PRD sessiz | K6 | Soru §15-6 |
| Kart görünürlüğü | build_bar_model.gd:41-43; build_hud_panel.gd:70-73 | `mvp_shipped` yoksa kart yok | Aynı | - | |
| Kart sinyalleri | build_bar.gd:44-51 | `build_phase_changed`, `day_advanced`, `language_changed`, `assignment_changed`, `build_progress_changed`, `employee_training_changed`, `product_state_changed` | `fix_run_started/finished` EventBus sinyalleri (event_bus.gd:147-148) kartı beslemiyor; K2 siler | K2 | (b) |
| BuildBar sahnesi | scenes/ui/components/BuildBar.tscn; BuildHUDPanel.tscn:32 | Sahne yalnız betik bağlar | Değişmez | - | |
| desk_shut çekimi | main.gd:1289-1294 | Canlı B2C, bildirim bayrakları (`REPORTS_INCOMING`/`REPORTS_WEEK_NET`) 12 | Yeniden kurulur, silinmez (PRD §4.12; YURUTUCU_NOTU 1) | K2 (yeniden kur), K6 (son hâl) | Artık tek açık hata deposuna hata yazmalı (`ProductState.add_bugs`, K3) |
| fix_run çekimi | main.gd:1295-1306 | `BUGS_CONFIRMED`, `FIX_RUN_*` bayrakları | Silinir | K2 | CLAUDE.md §12 yalnız `desk_shut`'ı anar |

### 6. Gelen kutusu şikâyet maili ve Satış'taki Risk rozeti
| Kalem | Dosya:satır | Bugün | Yeni karşılığı | Dilim | Not |
|---|---|---|---|---|---|
| Risk sebebi | inbox.gd:208-213 | `ProductSystem.live_bug_count() > B2BConstants.COMPLAINT_BUG_GATE` ise `SALES_REASON_OUTAGE`; yoksa `trust_offset ≥ 0` → `SALES_REASON_STABILITY`, aksi `SALES_REASON_SATISFACTION` | Hesabın kullandığı hatlardaki açık hata memnuniyet hedefini düşürür (Karar 9); sebep bu hata sayısına bakar (L ve `COMPLAINT_BUG_GATE` kalkar) | K5 | ACIK_KARARLAR 39 bu satırın çelişkisidir; `B2BSalesSystem.risk_voice` ayrı sayaç okur (b2b_sales_system.gd:504, (a)). `SalesArchetypes.uses_axis` gerekir (kodda yok) |
| Gelen kutusu Risk hatırlatması | inbox.gd:108-121 (118) | Risk'teki B2B hesap için `INBOX_SUBJ_RISK`, "Sebep: {reason}" | Aynı sebep satırı yeni kuralla | K5 | `Inbox.desk()`; konu CSV 3212 |
| Satış hesap kartı Risk rozeti | sales_tab.gd:22-24, 529-551 (542) | `PHASE_TAGS` `SALES_CHIP_RISK`; Risk'te `INBOX.risk_reason(c)` satırı | Sebep satırı yeni kuralla | K5 | Rozet kodu değişmez |
| Sektör şikâyet metni | b2b_constants.gd:56, 78, 111 | `COMPLAINT_BUG_GATE` 6; `B2B_COMPLAINT_<SEKTÖR>` türetilmiş | Kapı kalkar | K5 | (a) kapsar; CSV 702-723 |
| Risk fikstürleri | main.gd:1044, 1113-1116, 1177 | `mvp_live_bug_count` bayrağı 12 / `COMPLAINT_BUG_GATE` | Yeni hata deposu fikstürü | K5 | `--sales-shot` kareleri (`edge`, `risk_stability`, `deals`) |
| Satış toplantısı sorusu | sales_probes.gd:62, 135, 143-152; sales_meeting_system.gd:409, 426 | `confirmed_bugs` olgusu; "probe_stability_bugs" ve a_strength kapısı `confirmed_bugs ≤ 2` | Soru ve cevapları silinir; kapı kalkar (Karar 8) | K5 | (a)/(b) kapsar; CSV 2489, 2519-2521 ve 2516 aşağıda §11 |

### 7. TopBar itibar değeri
| Kalem | Dosya:satır | Bugün | Yeni karşılığı | Dilim | Not |
|---|---|---|---|---|---|
| Değer etiketi | top_bar.gd:220; TopBar.tscn:113-121 | `$RepValue.text = str(GameState.reputation)`; anahtar `FIN_CAP_REPUTATION` (CSV 562); ipucu yok | İtibar sıfırın altına inebilir, taban −10 (Karar 10) | K5 | Negatif ("-10") yerleşimi ve TR/EN, 1,25 ölçek denenmemiş; runway'in ipucu kalıbı mevcut (top_bar.gd:215-216) |
| Güncelleme | top_bar.gd:104 | `reputation_changed` → yenile | Aynı | - | |
| Alt sınır | game_state.gd:346-349 | `clampi(value, -10, 100)` | Zaten −10 (YURUTUCU_NOTU 2) | - | `max(0, …)` taban yazılmaz |
| Sebep yüzeyi | (yok) | Hata yüzünden itibar düşünce sebep görünmez | Sebep bir yerde görünür (Karar 10) | K5 | Adaylar: TopBar ipucu, sürüm notu (§4), Destek kartı ipucu |
| Okuyan yüzeyler (arayüz dışı) | vc_pitch_system.gd:1193; sales_system.gd:188 | VC itibar sorusu (`VC_Q_REPUTATION`, CSV 1323-1324) ve B2C kitle | Kalır | - | (a)/(b); anlatı fonu toplantı ihtimali de kalır (Karar 10) |

### 8. Ekip iş anlamı, onboarding becerisi (aşınma vaadi), Test alanı
| Kalem | Dosya:satır | Bugün | Yeni karşılığı | Dilim | Not |
|---|---|---|---|---|---|
| İş anlamı satırı | hr_constants.gd:1178-1183 (`role_area_meaning`), :349-354 (`_derived`); CSV 470 | Okuyucu yok (yalnız smoke endgame_smoke.gd:7356); "Beta keşif hızı ve canlı hata aşınması" | Vaat kalkar (Karar 12): "Beta keşif hızı" | K5 | Dinamik anahtar `HR_AREA_MEANING_<ROL>_<ALAN>`. Satırı silmek smoke :7356'yı düşürür |
| Onboarding beceri açıklaması | founder_constants.gd:111-116 (113); origin_traits_step.gd:259; CSV 482 | `ONB_SKILL_QA_DESC` "…canlı ürünün aşınma hızı." onboarding adım 2'de çizilir | Vaat kalkar (Karar 12) | K5 | TR/EN onay bekliyor. Görsel: `--onboard-shot=2:random` |
| AREA_QA yorumu | hr_constants.gd:15 | "Test - beta keşif hızı, canlı bug aşınması" | Yorum güncellenir (PRD §6) | K8 (K5 ile aynı commit olabilir) | hr_constants.gd:14 ("bug oranı") ve :17 ("bilet") ayrıca bakılır |
| Yazılım/Test "hata oranı" metinleri | CSV 468, 471 | `HR_AREA_MEANING_DEVELOPER_ENGINEERING`, `..._TESTER_ENGINEERING`: "Geliştirme hızı ve hata oranı" | A'da dokunulmaz (Test'in etkisi D'dedir) | - | Soru §15-9 |
| "Bilet çözümü" | CSV 473 (`HR_AREA_MEANING_CUSTOMER_REP_CUSTOMER_SUCCESS`); hr_constants.gd:17 | "Bilet çözümü ve churn" | Karar 12 "N ticket metinleri" kapsamında mı? | K5/K8 | Soru §15-9 |
| Titiz huyu | CSV 866 (`HR_TRAIT_DOUBLE_CHECKER_EFFECT`) | "Geliştirmede çok daha az hata çıkarır" | D'nin konusu | - | Dokunma |

### 9. Ofis (3B kişiler)
| Kalem | Dosya:satır | Bugün | Yeni karşılığı | Dilim | Not |
|---|---|---|---|---|---|
| Sprint açılışına kim yürür | office_people.gd:93-98, 177, 451-454 | `sprint_started` → `_kickoff = team().map(id)`; toplantı odasına `a.founder or team.has(id)` | `team()` Karar 13'e göre daralır; kurucu hâlâ `a.founder or` ile her zaman katılır | K1 | Karar gerekir (§15-2). Oda yoksa `_kickoff` boş. **[A2 öneri]** `a.founder or` kalsın: kurucu açılışı sunar (`spots.present`, 440-446), sprint üyeliğinden bağımsızdır; K1 raporunda yazılır |
| Atama değişiminde yenileme | office_people.gd:85, 93-95 | `assignment_changed` ve sprint başında `_on_assignment_changed` | Aynı | - | |
| Rol animasyonu | office_people.gd:30-41, 666-672 | `_work_of`: `role_of` doluysa `SPRINT_WORK`; kurucu `founder_passive_care` → "phone" yoksa "plan"; çalışan `JOB_WORK[assigned_job_ids[0]]` | `role_of` (a) takımla uyumlu; masa payı değişince kurucu "phone" kuralı K1'de yeniden doğrulanır | K1 | `JOB_WORK` Test → "coffee" (kartsız tester); Destek → "phone" |
| Destek kartı ofiste | (BuildHUDPanel, sağ üst) | §5 | §5 | K6 | Ofis karesi `--office-shot=<ofis>:<saat>:desk_shut` |

### 10. Ürün sekmesi kabuğu, varlıklar ve tema
| Kalem | Dosya:satır | Bugün | Yeni karşılığı | Dilim | Not |
|---|---|---|---|---|---|
| Sekme yerel durumu | product_tab.gd:7-8, 212-216 | "ses katlaması" sekmenin yerel durumu; `_on_ui_changed(open_area, voices_open)` | `voices_open` kalkar | K6 | Üst yorum satırı 7-8 da güncellenir |
| Sekme eylem tablosu | product_tab.gd:231-256 (248, 249) | `"voices_seen"` → `SprintSystem.voices_seen`; `"team"` → Ekip | `voices_seen` kolu silinir; `"team"` K1'in boş-ekip bağı için kalır | K6, K1 | |
| Kaynak yokken eylemler | product_tab.gd:229-231 | Fikstür tablosuyla "aynı türler" | Fikstür de güncellenir | K6 | product_fixtures.gd:202-206 `voices_seen` kolu |
| Yeniden kurma sinyalleri | product_tab.gd:95-97 | `product_state_changed`, `day_advanced`, `desk_changed` | Hata düşünce de `product_state_changed` yayınlanmalı (hat paneli bayat kalmasın) | K3 | (a) yayın noktası |
| ses simgesi | assets/icons/product/voices.svg (+ .import); sprint_ui_shared.gd:12 | Yalnız `SprintUiShared.VOICES` kullanır | Silinir | K6/K8 | |
| `bug.svg` | sprint_ui_shared.gd:13; sprint_panel.gd:99 | Rol uyarısı notunda | Kalır; hat satırı simgesi olabilir | - | |
| `CountChip` tema varyasyonu | build_theme.gd:997-998; HARITA:150 | Yalnız area_panel.gd:118 | Hat satırı yeniden kullanmazsa ölü | K6/K8 | Tema yeniden üretimi ve `THEME_STAMP` (ui_tokens.gd:44) yalnız stil değişirse |
| Kart düğmeleri: sönük/parlak | sprint_card.gd:17-19, 108-113, 142-144, 219-232, 315-320; build_theme.gd:974, 995-996, 1017-1020 | `BUTTONS_ALWAYS` = ADAY, KİLİTLİ; `BUTTONS_ON_HOVER` = SPRINT_PLAN, SPRINT_AKTIF, PLANLANAN, DEVREDEN (hover'da `_hover_bar.visible`); düğme varyasyonları `IconKey`, `CardKeyText`, `CardKeys(+Planned)` | Hepsi her zaman görünür ve sönük, kart üstüne gelince parlar (Karar 14) | K7 | Tema üretimi iki `.tres` yeniden yazar: önce `git diff -- themes/` ve kopya scratchpad'e (PRD §8); `project.godot`'a dokunulmaz |
| Kart anahtar düğmesi | sprint_ui_shared.gd:31-32, 234-247 | `key_button`: glif düğme / "çıkar" metni | Sönük görünüm tema üzerinden | K7 | |
| Çeyrek görünümü | quarter_view.gd:43-60, 172 | `AreaPanel(compact)` + MINI kartlar | MINI kartta düğme yok | K6 doğrular | §0 madde 6 |

### 11. localization/strings.csv: silinecek / yeniden yazılacak anahtarlar
CSV satır numaraları fiziksel satırdır (`grep -n`). Okuyucu sütunu: kod dosyası:satır. "Dinamik" = anahtar kod içinde birleştirilerek kurulur (düz arama kaçırır, ayrıca §11-B).

#### 11-A. Anahtar tablosu
| Kalem | Dosya:satır | Bugün (okuyucu) | Yeni karşılığı | Dilim | Not |
|---|---|---|---|---|---|
| PRODUCT_VOICES, _COUNT, _COUNT_ONE | CSV 2809-2811; area_panel.gd:166, 193 | SESLER başlığı, "n ses" | Sil (§3) | K6 | `_COUNT*` `Fmt.count_key` ile (dinamik sonek) |
| PRODUCT_NEW_COUNT, PRODUCT_NEW_STAMP | CSV 2812-2813; area_panel.gd:181, 197 | "k yeni", "Yeni" | Sil | K6 | |
| PRODUCT_RESEARCH_VOICE_CORE/ONBOARDING/GROWTH/INTEGRATIONS/TRUST/REVENUE | CSV 2977-2982; sprint_catalog.gd:192 | Dinamik `"…VOICE_" + area.to_upper()` | Sil (`voices()` ölür) | K6 | Araştırma bilgisi başka yüzeyde yok; `research_done` kartlar için kalır |
| PRODUCT_RIVAL_VOICE | CSV 2983; sprint_catalog.gd:196 | Rakip çıkışı sesi | Sil | K6 | Rakip bilgisi `PRODUCT_AREA_RIVAL` (CSV 2968) ve alan bayrağında kalır |
| PRODUCT_CUSTOMER_TICKETS, _ONE | CSV 2826-2827; area_panel.gd:236 | Canlıda erişilemez dal | Sil | K6/K8 | Dinamik sonek `count_key` |
| PRODUCT_AREA_TICKETS, _ONE | CSV 2966-2967; sprint_catalog.gd:165 | "{n} açık ticket" alan cümlesinde | "N açık hata" (§3 alan satırı) | K6 | Metin TR/EN onay bekliyor |
| PRODUCT_TICKET_0..2 | CSV 2974-2976; sprint_catalog.gd:203 | Dinamik `"PRODUCT_TICKET_%d"` | Sil (Karar 1) | K3 | + sprint.json:43 `ticket_titles` |
| PRODUCT_FX_TICKETS_CLOSE, _CLOSE_ONE, _CLOSED, _CLOSED_ONE | CSV 2854-2857; sprint_ui_shared.gd:27, 311 | Kart/öngörü etki parçası | "{n} hata kapatır/kapanır" | K4 | `COUNT_KEYS` tablosu |
| PRODUCT_FX_VOICES_CLOSE(+_ONE), _CLOSED(+_ONE) | CSV 2858-2859, 2929-2930; sprint_ui_shared.gd:28, 311 | Yalnız fikstür parçası üretir | Sil | K6 | product_fixtures.gd:500 |
| PRODUCT_RESULT_TICKETS_EXPECTED(+_ONE), _ACTUAL(+_ONE) | CSV 2992-2995; sprint_system.gd:1113; sprint_bridges.gd:209 | Sürüm sonucu cümleleri | "N hata kapanmalı / kapandı" | K4 | Dinamik sonek `count_key` |
| PRODUCT_IDLE_FIX | CSV 2840; product_model.gd:254 | Boşta notunun önerisi, koşu açılabiliyorsa | Sil | K2 | `PRODUCT_IDLE`, `_ONE`, `PRODUCT_IDLE_PLAN` kalır |
| PRODUCT_URGENT | CSV 2847; sprint_card.gd:192 | "Acil" | Yeni ad (B ile karışmaz) | K4 | TR/EN onay bekliyor |
| PRODUCT_FIX_CARD | CSV 2971; sprint_catalog.gd:312 | "{capability} düzeltmesi" | Hat, hata, hesap, kullanıcı, en büyük hesap | K4 | |
| PRODUCT_AREA_CORE_ENOUGH, _STRONG; PRODUCT_AREA_TRUST_ENOUGH, _STRONG | CSV 2944-2945, 2960-2961; sprint_catalog.gd:159 | Dinamik `"PRODUCT_AREA_%s_%s"`; "Temel iş sorunsuz yürüyor", "Ürün güvenilir çalışıyor" | Açık hata varken çelişmez (§3) | K6 | PRD adıyla anar CORE_ENOUGH ve TRUST_ENOUGH; STRONG da hata varken çelişebilir |
| PROD_FIX_RUN_START, PROD_FIX_RUN_END | CSV 1262-1263; build_bar_model.gd:59 | Düğme metinleri ("Hotfix yayınla · {n} düzeltildi") | Sil | K2 | |
| FIX_RUN_REFUSED_NO_BUGS | CSV 593; build_bar_model.gd:17 | Düğme gerekçesi | Sil | K2 | |
| BUILD_SUPPORT_MISSED | CSV 592; build_bar.gd:151 | "Gelen n · bu hafta m kaçırıldı" | Sil | K2 | |
| BUILD_SUPPORT_CONFIRMED, BUILD_SUPPORT_INCOMING | CSV 590-591; build_bar.gd:150-151 | "Doğrulanmış n", "Gelen n" | Sil; yerine "N açık hata ›" anahtarı | K6 | K0: K2'de kartta kalır |
| BUILD_BUSY_NOBODY | CSV 565; build_bar_model.gd:18; rnd_system.gd:352 | Düğme gerekçesi + Ar-Ge okuyucusu | Anahtar kalır (rnd_system) | K2 | Yalnız build_bar_model okuyucusu düşer |
| BUILD_SPLIT_FOCUS, BUILD_PHASE_SUPPORT | CSV 566, 589; build_bar_model.gd:65; build_bar.gd:149 | Bölünmüş odak notu, "DESTEK" | Kalır | - | §15-6 |
| PROD_PERCENT | CSV 594 | Okuyucular: rnd_ui_shared.gd:113, research_bar.gd:150, build_bar.gd:155 | Kalır | - | build_bar okuyucusu K2/K6'da düşer |
| EFFECT_FIX_RUN_STARTS | CSV 3054; chips.gd:44 | Çip | Sil | K2 | (b); lint.gd:323, 341 `fix_run_start` fiili de gider |
| EV_PRODUCT_BUG_PILE_TITLE/FIX/LATER/LOCK_FIX/EXPIRED | CSV 3094-3098; bug_pile.json | Hata yığını kartı | Sil | K2 | (b) |
| PROD_TIP_BUGS | CSV 1239; okuyucu yok | Ölü anahtar (detail_view.gd yok) | Sil | K8 | FRANK_VOICE_INVENTORY.md:66 satırı ve ALL_SCENES_DRAFT.md:463 |
| VC_Q_BUGS, VC_Q_BUGS_MONO | CSV 1325-1326; vc_pitch_system.gd:1200 | "Ürünün hata kaynıyor" sorgusu | Sil (Karar 8) | K5 | VC itibar sorusu (CSV 1323-1324) kalır |
| HUNT_CB_BUGS | CSV 834; vc_pitch_system.gd:503, 1291 | `bugs_under` geri dönüş koşulu "Aktif hata < n" | Yeni koşul "En zayıf eksen > 40"; göçle `bugs_under` kalmaz (§4.7) | K5 | Yeni anahtar gerekir |
| SALES_PROBE_PROBE_STABILITY_BUGS | CSV 2489; sales_meeting_system.gd:409 | Dinamik `"SALES_PROBE_%s"` | Sil (Karar 8) | K5 | |
| SALES_ANS_PROBE_STABILITY_BUGS_A_ADMIT / _A_PROMISE / _A_REFERENCE | CSV 2519-2521; sales_meeting_system.gd:426 | Dinamik `"SALES_ANS_%s_%s"` | Sil | K5 | |
| SALES_ANS_PROBE_STABILITY_RECORD_A_STRENGTH | CSV 2516 | "…açık hata listesi kısa." | Hatayı anmaz; kapı `confirmed_bugs ≤ 2` (sales_probes.gd:135) kalkar | K5 | |
| SALES_REASON_OUTAGE | CSV 144; inbox.gd:212 | "sık kesinti şikayeti" | Hesabın kullandığı hatlardaki açık hata sebebi | K5 | TR/EN onay bekliyor |
| SALES_REASON_STABILITY, SALES_REASON_SATISFACTION | CSV 145-146; inbox.gd:213 | Risk sebepleri | Kural gözden geçirilir (ACIK_KARARLAR 39) | K5 | |
| HR_AREA_MEANING_TESTER_QA | CSV 470 | §8 | "Beta keşif hızı" | K5 | |
| ONB_SKILL_QA_DESC | CSV 482 | §8 | Vaat kalkar | K5 | |
| HR_AREA_MEANING_CUSTOMER_REP_CUSTOMER_SUCCESS | CSV 473 | "Bilet çözümü ve churn" | Belirsiz (§15-9) | K5/K8 | |
| EV_PRODUCT_SUPPORT_OVERFLOW_KNOWN_BUGS | CSV 3471 | `support_overflow` seçeneği "Bilinen hataların listesini yayınla" | (b) kart incelemesi | K2/K5 | Kart `urun.bugs_unconfirmed` okur (support_overflow.json:123) |
| Yeni anahtarlar | (CSV'de yok) | `PRODUCT_BUGS_TIP*` 0 satır | Hat satırı, kart satırı, en büyük hesap, "N açık hata ›", itibar sebebi, boş ekip bağı, yeni "Acil" adı | K1, K4, K5, K6 | Önce İngilizce doğar; tire yok; TR/EN onay bekliyor (CLAUDE.md §5) |

#### 11-B. Dinamik anahtar kurucuları (düz grep kaçırır)
| Kalem | Dosya:satır | Bugün | Etkilenen anahtarlar | Dilim | Not |
|---|---|---|---|---|---|
| Alan × durum cümlesi | sprint_catalog.gd:159 | `"PRODUCT_AREA_%s_%s" % [area.to_upper(), word.to_upper()]` | PRODUCT_AREA_*_NONE/WEAK/ENOUGH/STRONG (CSV 2943-2961 bandı) | K6 | CORE_ENOUGH ve TRUST_ENOUGH'u düz grep hiç bulmaz |
| Ticket başlığı | sprint_catalog.gd:203 | `"PRODUCT_TICKET_%d" % variant` | PRODUCT_TICKET_0..2 | K3 | |
| Araştırma sesi | sprint_catalog.gd:192 | `"PRODUCT_RESEARCH_VOICE_" + area.to_upper()` | PRODUCT_RESEARCH_VOICE_* | K6 | |
| Çoğul sonek | util/fmt.gd:51-52 (`count_key`) | `key + "_ONE"` | PRODUCT_VOICES_COUNT, PRODUCT_CUSTOMER_TICKETS, PRODUCT_IDLE, PRODUCT_AREA_TICKETS, PRODUCT_FX_*, PRODUCT_RESULT_TICKETS_* | K2-K6 | `_ONE` ikizleri düz grep'te okuyucusuz görünür |
| Etki parçası tablosu | sprint_ui_shared.gd:26-29, 311 | `COUNT_KEYS[part.k][int(forecast)]` | PRODUCT_FX_TICKETS_*, PRODUCT_FX_VOICES_* | K4/K6 | |
| Sonuç cümlesi saklanır | sprint_bridges.gd:209; sprint_system.gd:1113; product_model.gd:318-321 | `{key, args}` olarak kayda yazılır, `resolve` okur | PRODUCT_RESULT_TICKETS_* | K4 | Kayıtta eski anahtar adı kalabilir: eski sürüm kaydı yüklenince `resolve` bilinmeyen anahtar okur; (a)/(b) göç sorusu |
| İş anlamı | hr_constants.gd:1183, 349-354 | `_derived("HR_AREA_MEANING_", role + "_" + area)` | HR_AREA_MEANING_* | K5 | Eksikse kimliği döner (`out if out != key else id`) |
| Beceri açıklaması | founder_constants.gd:111-116 | Sabit tablo (düz grep bulur) | ONB_SKILL_*_DESC | K5 | |
| Satış sorusu/cevabı | sales_meeting_system.gd:409, 426, 438 | `"SALES_PROBE_%s"`, `"SALES_ANS_%s_%s"`, `"SALES_LOCK_%s"` | SALES_PROBE_PROBE_STABILITY_BUGS, SALES_ANS_PROBE_STABILITY_*, SALES_LOCK_* | K5 | |
| Hedef cümlesi | product_model.gd:406 | `"PRODUCT_GOAL_" + area.to_upper()` | PRODUCT_GOAL_* | - | Dokunulmaz; örnek olarak listelendi |

### 12. Belgeler (K8 ve ilgili dilimler)
| Kalem | Dosya:satır | Bugün | Yeni karşılığı | Dilim | Not |
|---|---|---|---|---|---|
| HARITA.md Kayıt | docs/HARITA.md:39 | `SCHEMA_VERSION (15)`; `_migrate_15` anlatılır | 16, `_migrate_16` cümlesi | K3, K5, K8 | Bölüm "Kayıt" (27-44); `_migrate_16` iki dilimde yazılır |
| HARITA.md Ofis | docs/HARITA.md:137 | `desk_shut` ve `--office-shot` ek listesi | `desk_shut` yeni karta göre; `fix_run` ekli değil | K6, K8 | |
| HARITA.md Ürün (yer/sahip) | docs/HARITA.md:142, 144, 145, 147, 148 | `SprintBridges` "tickets, ticket_seq"; `gate_faulty`; "ticket eşitleme"; `sync_tickets`/`close_tickets`/`add_faulty_ticket`; `bugs_confirmed`, aşınma, `live_bug_count`, `product_bug_risk` | Tek hata deposu, hat temizleme, `add_bugs` vb. yazma noktaları | K3, K5, K8 | |
| HARITA.md Ürün (arayüz) | docs/HARITA.md:150, 151, 152 | CountChip, glifli ACİL etiketi, `idle_text` "hata düzeltmeyi başlat", DESTEK kartı (Doğrulanmış, Gelen, kaçırılan, Hotfix düğmesi, `REFUSAL_KEYS`) | Yeni kart, yeni etiket, tek satırlı Destek kartı | K2, K4, K6, K8 | |
| HARITA.md Ürün (smoke/probe/görsel) | docs/HARITA.md:155, 156, 157, 158 | `fix_run_ships_subset`, `support_desk_rates_stack`; `SHIP` hata/ticket; `_run_the_company` düzeltme koşusu; `edge:voices_open`; sprint-probe | Yeni vaka adları, `PROBE FIX`, yeni `edge:` adları (§4.12) | K1-K6, K8 | |
| HARITA.md Satış | docs/HARITA.md:210, 211, 213 | `Inbox.risk_reason` canlı hata sayısı kuralı; `destek.can_start_fix_run`/`fix_run_active`; `hotfix_*`, `conversion_bug_penalty` önekleri | Yeni Risk sebebi; seam'ler silinir; `hotfix_*` 2026-08 turu adı olarak kalır | K2, K5, K8 | |
| HARITA.md Olay motoru | docs/HARITA.md:308 | `fix_run_start` fiili ve çipi | Silinir | K2 | Bölüm "Olay motoru" (295-314) |
| HARITA.md Araçlar | docs/HARITA.md:359 | Probe preset aileleri | `fix_*` kolları, `PROBE FIX` | K5 | |
| HARITA.md Ekip | docs/HARITA.md:176-194 (özellikle 185, 192) | Görevler matrisi (kurucu satırı anılmaz), `--hr-shot` türleri | Kurucu sprint payı; yeni hr-shot türü | K1 | Matrise kurucu satırı kararına bağlı |
| CLAUDE.md §6 | CLAUDE.md:95-96 | WRITE-THROUGH: köprü "yalnız `tickets`, `ticket_seq`, `requests`, `rival_hits`'i yazar" | Yeni yazma noktaları | K3, K8 | |
| CLAUDE.md §6 | CLAUDE.md:107 | `SCHEMA_VERSION` 15 | 16 | K3, K8 | |
| CLAUDE.md §8 | CLAUDE.md:145 | "var olan evi ara (… `ProductSystem.live_bug_count` …)" | `live_bug_count` kalkar; örnek değişir | K5, K8 | |
| CLAUDE.md §12 | CLAUDE.md:220, 226 | `desk_shut` "canlı B2C, DESTEK masası boş, 12 gelen bildirim" | Yeni karta göre yeniden anlatılır | K6, K8 | PRD §6 CLAUDE.md §6, §8, §12 |
| CLAUDE.md §5 | CLAUDE.md:53 | İzinli ödünç kelimelerde "hotfix" | Kullanım kalmazsa liste kararı | K8 | glossary:10 ile birlikte (§15-8) |
| GUNCELLEMELER.md (eski girişler) | GDDs/GUNCELLEMELER.md:128, 133, 138-141, 143 | Ürün rev 6.1 §8.2-§8.4 ve §9 satırları (doğrulama oranı, DESTEK kartı gelen satırı, Hotfix düğmesi, akış formülü) | Yeni giriş "Hatalar ve hata gösterimi (Faz A)" ve eski girişlere "yerine" notu (eski girişler arama dışı, PRD §4.1) | K8 | |
| GUNCELLEMELER.md | GDDs/GUNCELLEMELER.md:204-207, 219-222 | Sprint motoru, ticket defteri kayıtta | Tek hata deposu, şema 16 | K8 | |
| GUNCELLEMELER.md | GDDs/GUNCELLEMELER.md:283-286 | Ekip §1.2 Destek yükü: "iki sayaçla çalışır" | Güncellenir | K8 | |
| GUNCELLEMELER.md | GDDs/GUNCELLEMELER.md:611 | "…Test beta keşif hızını ve Kararlılık tabanını oynatır" | Ekip GDD "canlı aşınma Test alanının işi" cümlesinin dayanağı (PRD §6); birebir cümle bulunamadı | K8 | Bölüm "EKİP MODÜLÜ (rev 11)" (492-628); docx §12.0 satırı da bakılacak |
| GUNCELLEMELER.md | GDDs/GUNCELLEMELER.md:668 | Ar-Ge §6.3 "açık ticket'lar" oyu | Hata deposu oyu | K3, K8 | rnd_system.gd:595-603 |
| GUNCELLEMELER.md | GDDs/GUNCELLEMELER.md:748-751 | Risk sebebi, `COMPLAINT_BUG_GATE` | Yeni kural | K5, K8 | |
| Ekip GDD (docx) | GDD — EKİP MODÜLÜ vson.docx paragraf 779, 787-792, 257, 1039 | "Kurucu bu matriste bulunmaz"; Destek işi "bilet çözümü, yanıt süresi"; "bilet → hata düzeltme hattı" | Kurucu kararına göre; "bilet" sözcüğü | K1, K8 | docx'te satır yok; paragraf indeksi verildi |
| Motor md §27 | GDDs/GDD — OLAY MOTORU (EVENT ENGINE) rev 2.md:2004-2016 (§27.11), 2196-2204 (§27.15 `team`), 2486-2506 (§27.25) | `destek.can_start_fix_run`; `fix_run_start` fiili; `destek.fix_run_active`; "koşu sürerken susan hata yığını"; `productivity_mod` `team` kapsamı | Kaldırma/değişiklik notları: silinen seam/fiil/kart; yeni §27.n "Faz A" | K2, K8 | Kod md'den ayrılırsa ayrılık §27'ye yazılır (CLAUDE.md §2) |
| ZAMAN MODELİ | GDDs/GDD — ZAMAN MODELİ.md:163, 209, 212, 268, 366 | `INFLOW_TAU` §3.5; `BUG_HISTORY_*` satırı; B2C memnuniyet "canlı hata 5'i aşınca"; `product.bug_pile` bekleme satırı | `bug_pile` satırı silinir; öbürleri L ve aşınma kalkınca | K2, K5, K8 | PRD: "bug_pile satırı"; :268 ve :209 K5 |
| Glossary | docs/design/localization_glossary.md:10, 68, 72, 78, 79, 80 | hotfix izinli kelime; ticket; ses (kullanıcı); düzeltme koşusu; hata düzeltme/hotfix; kaçırılan bildirim | Satırlar silinir/yeniden yazılır; yeni terim satırları (açık hata, hat) | K8 | |
| ACIK_KARARLAR 39 | docs/ACIK_ISLER/ACIK_KARARLAR.md:466-484 | Risk sebebi ile elde tutma sesi farklı sayaç okur | Karar 9 ile çözülür | K5, K8 | |
| ACIK_KARARLAR 45 | docs/ACIK_ISLER/ACIK_KARARLAR.md:567-586 | Canlı aşınma ve devir sayacı | Karar 2 ile kapanır | K5, K8 | 43 (karmaşıklık ve aşınma, :531-547) de aynı yolda; 38 (:447) "bilet çözümü" ve Destek işini anar |
| ISLER C-07 | docs/ACIK_ISLER/ISLER.md:98 | Planlanmış düzeltme kartı eforu eşik geçince güncellenmiyor | Karar 7 / §4.6c ile kapanır | K4, K8 | |
| ISLER INT-9 | docs/ACIK_ISLER/ISLER.md:107 | Göç sonrası bilet defteri boş | Defter kalkar | K3, K8 | |
| ISLER (yeni not) | docs/ACIK_ISLER/ISLER.md | - | VC takip sorusu ve anlaşma düşmesi (Karar 10) | K8 | PRD §2 Karar 10 |
| FRANK_VOICE_INVENTORY | docs/writing/FRANK_VOICE_INVENTORY.md:66, 114 | Satır 15 `PROD_TIP_BUGS`; `[COND?]` "live bug count at ship" | Satır 15 `PROD_TIP_BUGS` çıkar; 114 güncellenir | K8 | |
| Üretilen belgeler | docs/content/events_draft/_vocabulary.md:54, 147, 149, 357, 572; docs/EVENT_SIGNAL_MANIFEST.md:161-162 | `fix_run_start`, `destek.can_start_fix_run`, `destek.fix_run_active`, `urun.bugs_confirmed`; `fix_run_started/finished` | Elle düzenlenmez: `--event-vocab` ve `python tools/gen_signal_manifest.py` | K2, K3 | (b) kapsar |
| hr_constants AREA_QA yorumu | scripts/systems/hr_constants.gd:15 | "…canlı bug aşınması" | Güncellenir | K8 | §8 |

### 13. Görsel kabul için mevcut shot türleri (K-adım kabulünde yeniden kullanılabilir)
| Kalem | Dosya:satır | Bugün | Yeni karşılığı | Dilim | Not |
|---|---|---|---|---|---|
| `--product-shot=c1..c5`, `cards`, `flow` | main.gd:3139-3191; product_fixtures.gd:12, 70-167 | Fikstür kaynağıyla sprint ekranı; `cards` tüm kart durumları (:87-101), `flow` başlat/ilerlet/plan | Hat paneli (alan satırı), düzeltme kartı (`kesinti` :473), sürüm notu (c3) için temel | K4, K6 | `c2` aktif sprint, `c3` sürüm notu |
| `--product-shot=edge:cap_zero` | product_fixtures.gd:106-112 | Ekip ve kart yok, kapasite 0 (`_nobody` yolu) | "Sprintte kimse yok" karesinin temeli | K1 | Kart dolu + ekip boş hâli yok; yeni fikstür |
| `--product-shot=edge:over_100`, `over_125`, `empty_start`, `no_release`, `gate`, `history`, `history_empty`, `mvp`, `locked_k3`, `replan`, `pm_started`, `quarter_no_pm`, `goal_menu`, `approved`, `no_candidates`, `b2b_no_requests` | product_fixtures.gd:78-166; HARITA:157 | Uç durumlar | Kapasite çubuğu aşımı, sürüm notu, çeyrek | K1, K4 | |
| `--product-shot=edge:voices_open` | product_fixtures.gd:165-166; main.gd:3192-3198 | Açık alan + ses katlaması | Silinir; yerine hat paneli fikstürleri | K6 | HARITA:157 listesinden de çıkar |
| Yeni `edge:` fikstürleri | - | Yok | Hat paneli B2B, hat paneli B2C, 1-2 hatalı çok hatlı uzun liste, uzun hesap adlı düzeltme kartı, sürüm notu, Destek'teki kişili ekip + kapasite çubuğu, boş ekip | K1, K4, K6 | Adları HARITA:157'ye eklenir (PRD §4.12) |
| `--product-shot=live:plan` | main.gd:3174, 3274-3277 | Plan, `_skip`, `_start` kareleri | Sönük düğmeler kabulü (§4.12) | K7 | |
| `--product-shot=live:active` | main.gd:3278-3284 | Aktif sprint, ikinci hafta | Sönük düğmeler + ekip listesi | K7, K1 | |
| `--product-shot=live:week1`, `gate`, `b2c_mvp`, `b2c_live`, `b2b_requests`, `delegate`, `rnd` | main.gd:3229-3318 | Sprint motoruyla gerçek koşular; `week1` sürüm notuna kapanır (`_close`) | Gerçek sürüm notu, B2B talep kartları, kurucu Ar-Ge (ekip dışı) | K4, K1 | `b2c_live` Geçmiş açık (:3185-3187) |
| `--product-shot=live:solo15`, `solo15_tip`, `solo12_active` | main.gd:3250-3256 | Kurucu tek başına, mesai 15/12 saat | Kurucu tek ekip üyesi (Yapım) hâli | K1 | |
| `--hr-shot=gorevler`, `gorevler-bos`, `gorevler-arge`, `urunsuz`, `urunsuz_tur`, `saatler-sprint`, `dosya-kurucu`, `verim`, `kalabalik` | main.gd:2718-2740 | Görevler matrisi, boş kadro, kurucu dosyası, mesai paneli sprint puanı | Matris/sprint bağı; `saatler-sprint` kapasite etkisi | K1 | |
| `--office-shot=<ofis>:<saat>:desk_shut` | main.gd:1220-1223, 1289-1294 | Destek kartı, 12 gelen bildirim | Yeniden kurulur, "N açık hata ›" karesi, boş masa karesi | K2, K6 | PRD §4.9: boş masa ofis karesi rapora konur |
| `--office-shot=<ofis>:<saat>:fix_run` | main.gd:1295-1306 | Düzeltme koşusu karesi | Silinir | K2 | |
| `--office-shot=<ofis>:<saat>:full`, `crowd40`, `<sekme>`, `hr_dossier`, `cheque`, `v1` | main.gd:1203-1223 | Ofis ve pencereler | Sprint açılışına yürüme ve rol animasyonu için ofis; `<sekme>` ekip/ürün penceresi | K1 | Açılış yürüyüşünü doğrudan çeken tür yok; `--day-shot=<ofis>:<hız>` bir haftayı oynar (denenmedi) |
| `--clock-shot=<durum>` ve TopBar'ı kapsayan her kare | main.gd:1649-1653 | TopBar'ın saat durumları (itibar değeri görünür) | Negatif itibar karesi için yeni fikstür gerekir | K5 | `--tab-shot`, `--office-shot` kareleri TopBar taşır |
| `--onboard-shot=2:random` | main.gd:2308-2315 | Onboarding adım 2 (beceri sütunları ve açıklamaları) | `ONB_SKILL_QA_DESC` yeni metin karesi | K5 | `origin_traits_step.gd:259` |
| `--sales-shot=edge`, `risk_stability`, `deals` | main.gd:1015-1022, 1044, 1113-1116, 1177 | Risk'teki hesap ve sebep satırı | Yeni Risk sebebi | K5 | Fikstür `mvp_live_bug_count` yazıyor; hata deposuna çevrilmeli |
| `--inbox-shot=attention`, `rnd_note_demand` | main.gd:735-744, 858, 764-768 | Gelen kutusunda Risk hatırlatması; ticket açılmış R&D notu | Risk hatırlatması yeni sebep; `rnd_note_demand` `add_faulty_ticket` (main.gd:768) çağırır | K3, K5 | Fikstür çağrısı K3'te değişmeli |
| `--tab-shot=product` | main.gd:1785 | Ürün penceresi (canlı model) | Genel kabul | K4, K6 | |

### 14. PRD listesinde olup kodda bulunmayanlar / farklı bulunanlar
| Kalem | Dosya:satır | Bugün | Yeni karşılığı | Dilim | Not |
|---|---|---|---|---|---|
| `SalesArchetypes.uses_axis`, `USE_AXIS_MIN` | scripts/systems/sales_archetypes.gd (grep: yok) | Bu yüklem yok | Karar 6, eşik 0,25 [onay bekliyor] | K4 | Kullanım: hat satırındaki hesap sayısı ve Risk sebebi |
| `ProductState.add_bugs`, `open_bugs`, `line_impact`, `line_blocked`, `line_bugs_cleared`, `_migrate_16` | scripts, data, tools (grep: yok) | Yok | PRD §9 adlı yazma/okuma noktaları | K3, K4, K5 | Arayüz `line_impact` alanlarını okuyacak |
| `PRODUCT_BUGS_TIP*` | localization/strings.csv (grep: 0 satır) | Yok | Yeni anahtar | K4 | PRD §0 madde 1 |
| `HR_AREA_MEANING_*` arayüz okuyucusu | grep: yalnız smoke | Çizilmez | Karar 12 yine de metni düzeltir | K5 | §0 madde 3 |
| Ekip GDD "canlı aşınma Test alanının işi" cümlesi | docx paragraf taraması | Birebir yok | GUNCELLEMELER.md:611 ve docx §12.0 satırları | K8 | §0 madde 5 |
| `PRODUCT_AREA_CORE_ENOUGH` / `TRUST_ENOUGH` literal okuyucusu | grep: yok | Dinamik (sprint_catalog.gd:159) | Metin çelişkisi | K6 | §11-B |
| `reset_all_owners` içinde SprintSystem/ProductState girişi | (a)/(b) | Yok (K0) | PRD §6 satırı | K3 | Arayüz değil |

### 15. Açık sorular / riskler (en çok 10)
1. **Görevler matrisinde kurucu yok.** Kurucuya iş atamanın oyuncu yolu bulunmuyor (§0-1); Ekip GDD §12 ve `_case_gorevler_has_no_founder` bunu bilerek kilitler. Karar 13'ün "Yapım ve Destek tutan kurucu" durumu oyuncuda doğmaz. A'da yalnız motor bağı mı kurulacak, matrise kurucu satırı eklenecek mi? İkincisi GDD'yi değiştirir (ACIK_KARARLAR yolu).
2. **Ofiste kurucu açılışa her zaman yürür** (`office_people.gd:454`). `team()` kurucuyu dışarıda bırakınca da yürür; PRD "kimin yürüdüğü" arayüz bağını sayıyor. Hangisi istenir?
3. **`HR_AREA_MEANING_TESTER_QA` çizilmiyor, `ONB_SKILL_QA_DESC` çiziliyor.** Anahtarı silmek smoke :7356'yı düşürür; yeniden yazmak yeter. Hangisi?
4. **Hat satırı ile düzeltme kartı çifte bilgi** (§3: satır "Fatura · 6 açık hata · 3 hesap · 140 kullanıcı ↑" ve kart "Fatura düzeltmesi · 6 hata · 3 hesap · 140 kullanıcı · en büyüğü ..."). Aynı alanın açık gövdesinde ikisi alt alta gelir. Oklar (↑ ↓) PRD'de tanımlı değil.
5. **Çeyrek görünümünde `AreaPanel(compact)`** hat paneli nasıl davranacak? Bugün ses çipi ve cümle orada da çiziliyor (`quarter_view.gd:55-60`).
6. **Destek kartı:** `BUILD_SPLIT_FOCUS` ve `PRODUCT_AUTO_STARTED` satırları "tek satır" ile nasıl bir arada? Gerekçe satırı kalkınca boş masa (`BUILD_BUSY_NOBODY`) bilgisi kartta görünmez. Tık/sürükle ayrımı ve eşit hatlarda "en çok hatalı" seçimi tanımsız.
7. **Alan uyarı üçgeni ve "alert_clear"** `urgent_tickets` eşiğine bağlı (`sprint_catalog.gd:143-150, 378-403`); Karar 4 eşiği ve acil zorunluluğu değişince bu uyarının anlamı ve öngörü çipi ne olacak?
8. **"hotfix" izinli ödünç kelime listesinde** (CLAUDE.md:53, glossary:10); kullanım kalmayınca listeden çıkar mı? Ayrıca K2 `hotfix_*` smoke önekine (2026-08 yama turu) dokunmamalı.
9. **"Bilet / ticket" kapsamı:** `HR_AREA_MEANING_CUSTOMER_REP_CUSTOMER_SUCCESS` ("Bilet çözümü"), `hr_constants.gd:17`, Ekip GDD §12.0 ve paragraf 257 Karar 12 "N ticket metinleri" kapsamında mı? Aynı soru "hata oranı" metinleri (CSV 468, 471) ve `HR_TRAIT_DOUBLE_CHECKER_EFFECT` (D'nin).
10. **Kayıtta saklanan sonuç cümleleri:** `release.expected/actual` `{key, args}` olarak yazılıyor (`sprint_bridges.gd:209`, `sprint_system.gd:1113`); eski anahtar `PRODUCT_RESULT_TICKETS_*` silinirse eski kayıttaki sürüm notu bilinmeyen anahtar gösterir. Göç (a)/(b) bunu bilmeli; ayrıca negatif itibarın TopBar'daki yerleşimi ve itibar sebebi yüzeyi (Karar 10) henüz seçilmedi.

### A2 · Bu katmana eklenen satırlar (tamlık süpürmesi)

| Kalem | Dosya:satır | Bugün (okur/yazar, ne yapar) | Yeni karşılığı (PRD kararı) | Dilim | Not |
|---|---|---|---|---|---|
| ACIK_KARARLAR 96 alt maddeleri | docs/ACIK_ISLER/ACIK_KARARLAR.md:1186-1188 (4), 1188-1194 (5), 1200-1201 (9), 1212-1220 (16), 1227-1228 (21), 1239-1240 (29), 1264-1266 (45 bağı), 1277-1278 (49), 1279-1282 (50), 1284-1286 (52) | Rol uyumu, "odak payı sprint puanına girmez", "!" 3+ ticket, liderin acil zorunluluğu, hatalı kartın yalnız sürümde bilet açması, bilet ağırlığı, "ticket" ödünç listesi, L sıfırlaması, kart biletlerinin yenilenmesi | Faz A bunların çoğunu değiştirir (Karar 1, 3, 4, 5, 13) | K8 | Açık madde: yalnız "Faz A Kn ile değişti" notu; karar Erdem'in |
| ACIK_KARARLAR 97 | :1310 (`founder_roles`), :1319 (`WEAR_AUD_COEF`), :1374-1375 (`product.bug_pile`), :1423 (`EFFECT_FIX_RUN_STARTS` metni) | Onay bekleyen değerler ve metinler | `bug_pile` ve aşınma silinir: madde kısmen konusuz kalır | K8 | |
| ACIK_KARARLAR 99 | :1450-1464 | Geç B2C'de doğrulanmış hata birikimi; seçenek C "sprint puanı işi ve odağı okur (96 (5))" | Faz A Karar 13 C'yi uygular; ölçümü K5 | K1 (bilgi), K8 (not) | |
| ACIK_KARARLAR 44 | :548-566 (554) | "`ProductSystem` hata tohumu ve aşınma" | Aşınma kalkar | K8 | 43 ve 45 A1c'de vardı |
| ACIK_KARARLAR 59 | :738-760 | VC zayıf boyut tabanı ham eksenle karşılaştırılıyor; ham eksen 40'a varmıyor | Yeni geri dönüş koşulunun ölçeği buna bağlı | E1, K5 | **PLAN ETKİSİ** |
| ACIK_KARARLAR olay içeriği | :1569-1573 | Kalibrasyon turunun 27 kartı arasında `product.bug_pile` (Y7) | Kart silinir | K8 | |
| ISLER hata trendi zinciri | docs/ACIK_ISLER/ISLER.md:56-58 | `bug_trend`, `health_state`, `product_bug_risk`, `mvp_bug_history` ve sekiz etiket "sahip" tutuyor | Girdileri K5'te silinir; madde kapanış notuyla güncellenir | K8 | Silme sahibin "yeniden yuva" listesine dokunur: R'de gerekçe |
| ISLER harness notu | ISLER.md:118-119 | "Probe kurucusunun Müşteri İlişkileri'si 0: masadaki kurucu doğrulamaz, yalnız düzeltir" | K2 sonrası "yalnız düzeltir" yarısı geçersiz | K1, K8 | B2C kolunun yeniden kurulumu bunu bilir |
| HARITA Ar-Ge notu | docs/HARITA.md:168 | Ar-Ge notunun talep satırı açık ticket oylarını sayar | Açık hata oyu | K3, K8 | rnd_system.gd:595-606 |
| `edge:voices_open` başlık yorumu | main.gd:3125-3129 | Fikstür türlerini anlatan yorum | Sesler kalkınca güncellenir | K6 | |
| Ofiste kurucunun masa animasyonu | office_people.gd:666-672 | Kartı olmayan kurucu: pasif ilgide "phone", aksi hâlde hep "plan" (Destek tutsa da) | İki işli kurucu için Karar 13 anlamı; K1 raporunda | K1 | Çalışan `JOB_WORK[ilk iş]` ile çizilir (30-37) |
| Tarihçe denetim belgeleri | docs/audits/urun_rev7/*.md | Eski isimler (`PROD_FIX_RUN_*`, `mvp_bug_history`, ses) | Arama dışı tarihçe | — | §4.1 aramasına girmez (yalnız `scripts/ data/ tools/ localization/`) |
