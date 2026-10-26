# Kod haritası · KALITE

Üretildi: git 74f8e04 · 2026-10-27 · `python -I tools/kod_haritasi/uret.py`
Kapsam: scripts/ altındaki 245 .gd (tools/ ve sandbox/ hariç). Kod temizliği ve kıdemli denetimde başlangıç listesi; kanıt değil, aday.

## En büyük 25 .gd

- scripts/debug/endgame_smoke.gd · 28948 satır · 656 func
- scripts/main/main.gd · 5482 satır · 196 func
- scripts/debug/run_probe.gd · 2390 satır · 92 func
- scripts/systems/sprint_system.gd · 1993 satır · 164 func
- scripts/theme/build_theme.gd · 1544 satır · 28 func
- scripts/systems/vc_pitch_system.gd · 1327 satır · 91 func
- scripts/autoload/save_manager.gd · 1297 satır · 61 func
- scripts/events/tools/lint.gd · 1269 satır · 45 func
- scripts/systems/hr_constants.gd · 1162 satır · 90 func
- scripts/ui/office/office_person.gd · 1128 satır · 51 func
- scripts/autoload/game_state.gd · 1050 satır · 55 func
- scripts/systems/sprint_catalog.gd · 1038 satır · 91 func
- scripts/tabs/product/product_model.gd · 999 satır · 53 func
- scripts/systems/term_sheet_table_system.gd · 987 satır · 57 func
- scripts/theme/ui_tokens.gd · 983 satır · 39 func
- scripts/events/core/effects.gd · 969 satır · 29 func
- scripts/tabs/events/mail_pane.gd · 889 satır · 46 func
- scripts/tabs/sales_tab.gd · 850 satır · 40 func
- scripts/systems/rnd_system.gd · 814 satır · 56 func
- scripts/ui/meeting/meeting_panel.gd · 805 satır · 38 func
- scripts/events/core/engine.gd · 804 satır · 36 func
- scripts/ui/office/office_people.gd · 763 satır · 48 func
- scripts/events/tools/engine_probe.gd · 700 satır · 17 func
- scripts/systems/b2b_sales_system.gd · 699 satır · 46 func
- scripts/tabs/piyasa_tab.gd · 689 satır · 34 func

## 80 satırdan uzun fonksiyonlar (99 tane, en uzun 40)

Uzunluk = imza satırından gövdenin son kod satırına (boş/yorum satırları arada sayılır).
- scripts/theme/build_theme.gd:413 · _menajer · 806 satır
- scripts/debug/endgame_smoke.gd:51 · run_case · 572 satır
- scripts/events/core/effects.gd:230 · _apply · 519 satır
- scripts/events/tools/vocab_gen.gd:20 · run · 322 satır
- scripts/theme/build_theme.gd:39 · _initialize · 319 satır
- scripts/debug/endgame_smoke.gd:22740 · _case_sprint_timeline_matches_play_out · 266 satır
- scripts/main/main.gd:3341 · _run_hr_shot · 259 satır
- scripts/events/present/chips.gd:68 · describe · 232 satır
- scripts/debug/endgame_smoke.gd:8250 · _case_hr_constants_contract · 220 satır
- scripts/debug/endgame_smoke.gd:2209 · _case_save_v13_day_stamps_migrate · 209 satır
- scripts/autoload/game_state.gd:810 · initialize_run · 194 satır
- scripts/main/main.gd:1114 · _run_inbox_shot · 189 satır
- scripts/debug/endgame_smoke.gd:16190 · _case_fit_star_context · 179 satır
- scripts/events/seams/seams_ported.gd:8 · install · 175 satır
- scripts/onboarding/first_week_doc.gd:20 · lay_out · 161 satır
- scripts/events/seams/seams_sales.gd:26 · install · 160 satır
- scripts/debug/endgame_smoke.gd:2428 · _case_legacy_v12_save_opens_live_table · 157 satır
- scripts/main/main.gd:1789 · _run_office_shot · 147 satır
- scripts/debug/endgame_smoke.gd:7834 · _case_hr_leave_shift · 146 satır
- scripts/debug/endgame_smoke.gd:7087 · _case_hr_candidate_invariants · 145 satır
- scripts/debug/endgame_smoke.gd:15464 · _case_sales_offer_signing · 144 satır
- scripts/debug/endgame_smoke.gd:11377 · _case_job_assignment_and_idle · 140 satır
- scripts/debug/endgame_smoke.gd:17038 · _case_rnd_tree_loads_and_validates · 140 satır
- scripts/main/main.gd:1496 · _run_sales_shot · 140 satır
- scripts/debug/endgame_smoke.gd:13979 · _case_clock_resumes_only_by_player · 135 satır
- scripts/ui/office/office_map_card.gd:17 · _init · 134 satır
- scripts/debug/endgame_smoke.gd:11840 · _case_effective_skill_formula · 132 satır
- scripts/debug/endgame_smoke.gd:17664 · _case_rnd_note_author_and_lines · 129 satır
- scripts/debug/endgame_smoke.gd:21667 · _case_sprint_founder_share_frozen · 128 satır
- scripts/debug/endgame_smoke.gd:26670 · _case_save_v15_tickets_become_open_bugs · 128 satır
- scripts/debug/product_fixtures.gd:68 · _build · 127 satır
- scripts/debug/endgame_smoke.gd:1004 · _case_gate_decline_reminder · 125 satır
- scripts/debug/endgame_smoke.gd:19607 · _thesis_presenter_body · 124 satır
- scripts/debug/endgame_smoke.gd:19840 · _case_sales_meeting_time_skip_founder_share · 124 satır
- scripts/main/main.gd:3902 · _seed_product_live · 123 satır
- scripts/events/tools/why.gd:28 · report · 121 satır
- scripts/events/seams/seams_product.gd:15 · _install_product · 120 satır
- scripts/events/tools/engine_probe.gd:582 · _check_invalidation · 119 satır
- scripts/debug/run_probe.gd:351 · run · 117 satır
- scripts/debug/endgame_smoke.gd:1396 · _case_month_summary · 116 satır

## Ölü kod adayları (18)

Tanım satırı dışında scripts/, scenes/, data/ içinde adı hiç geçmeyen func (yorumlar sayılmaz, dizeler sayılır). Godot geri çağrıları hariç.
UYARI: call("a"+b) gibi kurulmuş adlar, sinyal adıyla bağlama, harness bayrakları ve tools/*.sh çağrıları yüzünden yanlış pozitif olabilir; silmeden önce grep ile doğrula.
- scripts/debug/office_crowd_probe.gd:48 · _log_error · debug
- scripts/main/game_shell.gd:167 · debug_force_vc_meeting · MCP seam (_dbg_*/debug_*, Godot MCP adla çağırır)
- scripts/main/main.gd:5423 · _dbg_close_request · MCP seam (_dbg_*/debug_*, Godot MCP adla çağırır)
- scripts/main/main.gd:5428 · _dbg_onb_random_x20 · MCP seam (_dbg_*/debug_*, Godot MCP adla çağırır)
- scripts/main/main.gd:5441 · _dbg_finish_run · MCP seam (_dbg_*/debug_*, Godot MCP adla çağırır)
- scripts/systems/line_gates.gd:126 · speed_bonus_for
- scripts/systems/product_catalog.gd:237 · type_sector_labels
- scripts/systems/rnd_system.gd:707 · family_root_done
- scripts/systems/sales_ledger.gd:34 · lead_star
- scripts/systems/sales_ledger.gd:39 · lead_weeks_left
- scripts/systems/sales_ledger.gd:244 · deal_count
- scripts/systems/sales_ledger.gd:252 · last_signed_star
- scripts/systems/sales_system.gd:501 · estimate_price_change
- scripts/theme/ui_factory.gd:41 · make_badge
- scripts/theme/ui_factory.gd:76 · make_stat
- scripts/theme/ui_tokens.gd:384 · format_money
- scripts/theme/ui_tokens.gd:954 · D_health_color
- scripts/theme/ui_tokens.gd:963 · D_relationship_palette

## Yarım sinyaller (18)

emit'i ya da connect'i bulunamayan sinyal (ada göre). Dizi içi bağ, await ve EvSignals.BINDINGS connect sayılır. Yanlış pozitif: bind(sig) ile değer olarak geçip değişkenden yayılan ya da yalnız smoke'ta adı geçen sinyal.
- scripts/autoload/event_bus.gd:73 · employee_eligible_for_promotion · emit yok
- scripts/autoload/event_bus.gd:76 · raise_requested · emit yok
- scripts/autoload/event_bus.gd:79 · leave_requested · connect yok
- scripts/autoload/event_bus.gd:84 · training_completed · connect yok
- scripts/autoload/event_bus.gd:99 · customer_mrr_changed · connect yok
- scripts/autoload/event_bus.gd:154 · line_upgraded · connect yok
- scripts/autoload/event_bus.gd:155 · line_completed · connect yok
- scripts/autoload/event_bus.gd:156 · delighter_shipped · connect yok
- scripts/autoload/event_bus.gd:162 · card_phase_changed · connect yok
- scripts/autoload/event_bus.gd:163 · card_done · connect yok
- scripts/autoload/event_bus.gd:164 · card_carried_over · connect yok
- scripts/autoload/event_bus.gd:167 · sprint_auto_started · connect yok
- scripts/autoload/event_bus.gd:214 · meeting_won · connect yok
- scripts/autoload/event_bus.gd:221 · pitch_promise_made · connect yok
- scripts/autoload/event_bus.gd:222 · pitch_promise_kept · connect yok
- scripts/autoload/event_bus.gd:223 · pitch_promise_broken · connect yok
- scripts/autoload/event_bus.gd:224 · whale_condition_met · connect yok
- scripts/modals/confirm_modal.gd:12 · alt_selected · emit yok

## Birden çok dosyada tanımlı const (95 ad)

Enum üyeleri hariç. Aynı değer mi, kopya mı, yalnız ad çakışması mı: elle bakılmalı.
- INBOX · 17 dosya · scripts/main/game_shell.gd:7, scripts/main/main.gd:20, scripts/modals/save_load_modal.gd:19, scripts/modals/system_menu_modal.gd:22, scripts/tabs/events/mail_pane.gd:19, scripts/tabs/events_tab.gd:8 +11
- WIDTH · 6 dosya · scripts/modals/hr_action_modal.gd:18, scripts/modals/training_modal.gd:19, scripts/modals/work_hours_modal.gd:22, scripts/ui/components/left_tabs.gd:28, scripts/ui/office/office_map_card.gd:11 +1
- CLOCK · 5 dosya · scripts/tabs/events/mail_pane.gd:24, scripts/tabs/hunt_tab.gd:11, scripts/tabs/product/sprint_ui_shared.gd:16, scripts/tabs/rnd/rnd_detail_panel.gd:20, scripts/tabs/sales_tab.gd:30
- ChequeRead · 5 dosya · scripts/tabs/finance/finance_ozet_view.gd:34, scripts/tabs/personal_tab.gd:13, scripts/ui/components/top_bar.gd:19, scripts/ui/office/office_notice_stack.gd:12, scripts/debug/endgame_smoke.gd:34
- GraphicsSettingsLib · 4 dosya · scripts/autoload/settings.gd:17, scripts/modals/settings_modal.gd:19, scripts/ui/menu_backdrop.gd:12, scripts/ui/office/office_view.gd:13
- ModuleLocks · 4 dosya · scripts/events/core/delays.gd:22, scripts/events/seams/seams_world.gd:6, scripts/events/tools/vocab_gen.gd:13, scripts/ui/components/left_tabs.gd:26
- STAR · 4 dosya · scripts/systems/sprint_catalog.gd:21, scripts/tabs/events/mail_pane.gd:25, scripts/tabs/rnd/rnd_ui_shared.gd:52, scripts/tabs/sales_tab.gd:35
- ARROW · 3 dosya · scripts/modals/hr_action_modal.gd:19, scripts/tabs/product/sprint_ui_shared.gd:13, scripts/tabs/sales_tab.gd:33
- CHECK · 3 dosya · scripts/tabs/product/sprint_ui_shared.gd:15, scripts/tabs/rnd/rnd_tree_view.gd:47, scripts/ui/office/office_notice_stack.gd:13
- CHEVRON · 3 dosya · scripts/tabs/product/quarter_view.gd:13, scripts/tabs/rnd/rnd_assign_panel.gd:22, scripts/tabs/rnd/rnd_tree_view.gd:46
- COLUMNS · 3 dosya · scripts/onboarding/steps/company_step.gd:8, scripts/onboarding/steps/origin_traits_step.gd:12, scripts/tabs/hr/hr_ledger.gd:10
- DATA_PATH · 3 dosya · scripts/menu/credits.gd:9, scripts/systems/graphics_settings.gd:18, scripts/systems/sprint_catalog.gd:11
- DisplaySettingsLib · 3 dosya · scripts/autoload/settings.gd:16, scripts/modals/settings_modal.gd:18, scripts/systems/graphics_settings.gd:15
- EMBLEM · 3 dosya · scripts/menu/continue_card.gd:6, scripts/onboarding/first_week_doc.gd:9, scripts/onboarding/steps/company_step.gd:10
- GROUP · 3 dosya · scripts/ui/components/inbox.gd:14, scripts/ui/components/toast.gd:10, scripts/ui/components/window_layer.gd:45
- INFO · 3 dosya · scripts/tabs/rnd/rnd_detail_panel.gd:18, scripts/tabs/sales_tab.gd:32, scripts/ui/meeting/meeting_panel.gd:23
- LOCK_ICON · 3 dosya · scripts/modals/ending_scene.gd:36, scripts/theme/ui_factory.gd:10, scripts/ui/components/left_tabs.gd:41
- RISE · 3 dosya · scripts/tabs/piyasa_tab.gd:21, scripts/ui/components/toast.gd:14, scripts/ui/office/person_bust.gd:16
- STAR_MAX · 3 dosya · scripts/systems/hr_constants.gd:31, scripts/systems/product_quality.gd:21, scripts/systems/sales_constants.gd:45
- W · 3 dosya · scripts/modals/training_modal.gd:21, scripts/tabs/hr/hr_assignments.gd:16, scripts/debug/kit_probe.gd:11
- AREAS · 2 dosya · scripts/systems/hr_constants.gd:18, scripts/debug/product_fixtures.gd:16
- BAND_H · 2 dosya · scripts/modals/work_hours_modal.gd:34, scripts/tabs/events_tab.gd:15
- BAR_W · 2 dosya · scripts/onboarding/first_week_doc.gd:12, scripts/onboarding/steps/origin_traits_step.gd:15
- BarKit · 2 dosya · scripts/ui/components/build_bar.gd:14, scripts/ui/components/research_bar.gd:26
- CALENDAR · 2 dosya · scripts/tabs/hunt_tab.gd:12, scripts/tabs/sales_tab.gd:31
- CONFIRM_MODAL · 2 dosya · scripts/main/main.gd:23, scripts/onboarding/onboarding_flow.gd:21
- CONV_BASE · 2 dosya · scripts/systems/pitch_constants.gd:18, scripts/systems/seed_constants.gd:83
- CONV_BRAND_FLOOR · 2 dosya · scripts/systems/pitch_constants.gd:24, scripts/systems/seed_constants.gd:87
- CONV_BRAND_MAX · 2 dosya · scripts/systems/pitch_constants.gd:25, scripts/systems/seed_constants.gd:88
- CONV_MRR_MAX_BONUS · 2 dosya · scripts/systems/pitch_constants.gd:23, scripts/systems/seed_constants.gd:86
- CONV_MRR_REFERENCE · 2 dosya · scripts/systems/pitch_constants.gd:22, scripts/systems/seed_constants.gd:84
- CONV_SCANDAL_PENALTY · 2 dosya · scripts/systems/pitch_constants.gd:28, scripts/systems/seed_constants.gd:96
- CONV_SHUTTER_PENALTY · 2 dosya · scripts/systems/pitch_constants.gd:26, scripts/systems/seed_constants.gd:94
- CONV_THIN_RUNWAY_PENALTY · 2 dosya · scripts/systems/pitch_constants.gd:27, scripts/systems/seed_constants.gd:95
- CONV_WARM_INTRO_BONUS · 2 dosya · scripts/systems/pitch_constants.gd:30, scripts/systems/seed_constants.gd:93
- DIL_STEP · 2 dosya · scripts/systems/pitch_constants.gd:124, scripts/systems/seed_constants.gd:47
- EDGE · 2 dosya · scripts/tabs/events_tab.gd:16, scripts/ui/components/window_layer.gd:43
- EFFORT_BANDS · 2 dosya · scripts/systems/product_lines.gd:23, scripts/systems/research_tree.gd:37
- FADE_S · 2 dosya · scripts/ui/meeting/meeting_panel.gd:43, scripts/ui/office/office_travel.gd:15
- FAMILY_GAP_WEEKS · 2 dosya · scripts/events/core/tuning.gd:33, scripts/events/tools/plausibility.gd:54
- FAMILY_GAP_WEEKS_DEFAULT · 2 dosya · scripts/events/core/tuning.gd:31, scripts/events/tools/plausibility.gd:53
- FERRY_ENDS · 2 dosya · scripts/ui/office/office_city.gd:40, scripts/ui/office/office_lighting.gd:59
- FERRY_SPEED · 2 dosya · scripts/ui/office/office_city.gd:41, scripts/ui/office/office_lighting.gd:61
- FERRY_TURN · 2 dosya · scripts/ui/office/office_city.gd:42, scripts/ui/office/office_lighting.gd:60
- FILTERS · 2 dosya · scripts/tabs/events_tab.gd:10, scripts/tabs/piyasa_tab.gd:9
- FOCUS_ZOOM · 2 dosya · scripts/ui/office/meeting_invite.gd:23, scripts/ui/office/office_city.gd:25
- FRAME · 2 dosya · scripts/ui/components/window_layer.gd:28, scripts/ui/office/person_bust.gd:14
- GATE_STRIP · 2 dosya · scripts/modals/save_load_modal.gd:18, scripts/ui/components/window_frame.gd:12
- GLASSES · 2 dosya · scripts/systems/look_system.gd:12, scripts/systems/people_parts.gd:155
- GLYPHS · 2 dosya · scripts/events/present/chips.gd:57, scripts/tabs/events/mail_pane.gd:22
- INBOX_GLYPH · 2 dosya · scripts/tabs/product/sprint_card.gd:22, scripts/tabs/product/sprint_panel.gd:13
- KEYBOARD · 2 dosya · scripts/ui/office/office_notice_stack.gd:14, scripts/ui/office/office_travel.gd:25
- KEY_W · 2 dosya · scripts/onboarding/first_week_doc.gd:11, scripts/tabs/hr/hr_dossier.gd:14
- KINDS · 2 dosya · scripts/systems/people_parts.gd:11, scripts/tabs/rnd/rnd_history.gd:11
- LEAD · 2 dosya · scripts/ui/meeting/sales_meeting_adapter.gd:19, scripts/ui/meeting/vc_meeting_adapter.gd:16
- LICENSES · 2 dosya · scripts/menu/credits.gd:8, scripts/modals/settings_modal.gd:20
- LOCKUP_S · 2 dosya · scripts/menu/main_menu.gd:23, scripts/onboarding/onboarding_flow.gd:31
- LUCIDE · 2 dosya · scripts/menu/licenses.gd:13, scripts/debug/write_licenses.gd:11
- MAIL_PANE · 2 dosya · scripts/main/main.gd:21, scripts/tabs/product/sprint_card.gd:23
- MAIN_MENU_SCRIPT · 2 dosya · scripts/main/main.gd:17, scripts/onboarding/onboarding_flow.gd:14
- MARKET_B2B · 2 dosya · scripts/systems/infra_system.gd:33, scripts/systems/support_system.gd:87
- MIX_INCREMENT · 2 dosya · scripts/systems/hr_candidate_generator.gd:32, scripts/systems/sales_constants.gd:274
- MIX_MODULUS · 2 dosya · scripts/systems/hr_candidate_generator.gd:30, scripts/systems/sales_constants.gd:272
- MIX_MULTIPLIER · 2 dosya · scripts/systems/hr_candidate_generator.gd:31, scripts/systems/sales_constants.gd:273
- MIX_SALT_STRIDE · 2 dosya · scripts/systems/hr_candidate_generator.gd:33, scripts/systems/sales_constants.gd:275
- Model · 2 dosya · scripts/ui/components/build_bar.gd:13, scripts/ui/components/research_bar.gd:25
- NAME_W · 2 dosya · scripts/onboarding/steps/character_step.gd:10, scripts/onboarding/steps/company_step.gd:7
- ONBOARDING_VOICE_TENURE_WEEKS · 2 dosya · scripts/events/tools/plausibility.gd:56, scripts/systems/b2b_constants.gd:275
- OUT_PATH · 2 dosya · scripts/events/tools/vocab_gen.gd:15, scripts/theme/build_theme.gd:34
- PANE · 2 dosya · scripts/tabs/events_tab.gd:9, scripts/tabs/rnd/rnd_history.gd:10
- PAUSE · 2 dosya · scripts/tabs/product/sprint_panel.gd:12, scripts/tabs/rnd/rnd_ui_shared.gd:53
- PHASE_KEYS · 2 dosya · scripts/autoload/game_state.gd:410, scripts/tabs/product/sprint_card.gd:21
- PROPS · 2 dosya · scripts/ui/office/office_person.gd:77, scripts/debug/office_pan_probe.gd:22
- PULSE_ALPHA · 2 dosya · scripts/ui/components/top_bar.gd:45, scripts/ui/office/office_hud.gd:14
- PULSE_SCALE · 2 dosya · scripts/ui/components/top_bar.gd:44, scripts/ui/office/office_hud.gd:13
- RENEWAL_MIN_TENURE_WEEKS · 2 dosya · scripts/events/tools/plausibility.gd:57, scripts/systems/b2b_constants.gd:273
- ROWS · 2 dosya · scripts/tabs/rnd/rnd_tree_view.gd:44, scripts/debug/kit_probe.gd:12
- ROW_H · 2 dosya · scripts/modals/settings_modal.gd:65, scripts/tabs/events_tab.gd:13
- SAVED_GLYPH · 2 dosya · scripts/main/main.gd:31, scripts/modals/ending_scene.gd:38
- SCHEMA_VERSION · 2 dosya · scripts/autoload/save_manager.gd:16, scripts/autoload/settings.gd:11
- SEP · 2 dosya · scripts/systems/sprint_catalog.gd:20, scripts/tabs/product/sprint_ui_shared.gd:8
- SEPARATOR · 2 dosya · scripts/theme/ui_tokens.gd:131, scripts/ui/components/news_ticker.gd:36
- STAGES · 2 dosya · scripts/systems/sprint_system.gd:18, scripts/debug/product_fixtures.gd:10
- STALL_S · 2 dosya · scripts/ui/office/office_person.gd:131, scripts/debug/office_crowd_probe.gd:13
- START_IMMUNITY_WEEKS · 2 dosya · scripts/events/core/tuning.gd:124, scripts/events/tools/plausibility.gd:52
- STATE_ACTIVE · 2 dosya · scripts/events/core/arcs.gd:16, scripts/systems/rnd_system.gd:31
- STRINGS_CSV · 2 dosya · scripts/autoload/localization.gd:12, scripts/debug/loc_residue.gd:26
- STYLES · 2 dosya · scripts/systems/people_parts.gd:99, scripts/ui/components/logo_emblem.gd:9
- TABLE · 2 dosya · scripts/systems/product_quality.gd:48, scripts/systems/sales_archetypes.gd:41
- TOAST · 2 dosya · scripts/modals/ending_scene.gd:37, scripts/debug/kit_probe.gd:7
- TOON · 2 dosya · scripts/ui/office/office_body.gd:12, scripts/ui/office/office_materials.gd:9
- TRAINING_MODAL · 2 dosya · scripts/tabs/hr/hr_ledger.gd:31, scripts/tabs/personal_tab.gd:8
- TRAITS · 2 dosya · scripts/systems/founder_constants.gd:44, scripts/systems/hr_constants.gd:419
- TX_LABEL · 2 dosya · scripts/systems/angel_round_system.gd:30, scripts/systems/seed_constants.gd:122
- WARN · 2 dosya · scripts/tabs/product/sprint_ui_shared.gd:14, scripts/tabs/rnd/rnd_detail_panel.gd:19

## TODO/FIXME/HACK (yorumlarda, 0 dosya, toplam 0)

- (yok)
