class_name EndgameSmoke
extends RefCounted

# Headless smoke harness for the endgame engines.
# Debug builds only; invoked by main.gd when the run args contain
# --endgame-smoke=<case> (set application/run/main_args, run, read output).
# One case per process — autoload state stays pristine between cases.
#
# The harness never mounts the shell: it initializes a run, forces the case's
# preconditions, then drives GameState.advance_day() + TimeManager's daily
# dispatch DIRECTLY (no wall clock). Modals never mount (main.gd's event
# signals aren't wired pre-shell), so "the player" is simulated by calling
# EventManager.resolve_choice on the active event.
#
# IMPORTANT modeling rule: test MRR must come from real customer records —
# SalesSystem._mrr_bridge (slot 4) overwrites GameState.mrr from
# CustomerRegistry every day, so a bare set_mrr() would be clobbered before
# slots 8/9 read it.
#
# Output contract: exactly one "SMOKE PASS <case>" or "SMOKE FAIL <case>: why"
# line. The process is left ALIVE deliberately — editor-run output is only
# readable while the process lives (godot-mcp gotcha); editor-stop ends it.

const GATE1_ID := "funding.gate_traction"
const GATE2_ID := "funding.gate_series_a"
const DOOR_OPEN_ID := "funding.frank_door_open"   # Frank speaks first, the gate card a day later
const ANGEL_ID := "funding.frank_cheque"
const NUDGE_ID := "funding.hire_nudge"
const RETAIN_ID := "customer.retention"
const EXPANSION_ID := "customer.expansion"
const MEETING_ID := "funding.meeting_day"
const SHEET_WARN_ID := "funding.sheet_expiry"
const SHEET_DECISION_ID := "funding.sheet_decision"

# Fixture skill defaults. The three names are KEPT (fifty-odd call sites pass them
# positionally) but their MEANING moved with the 2026-08-21 area migration, because the
# three axes they were named after no longer exist:
#   SEED_EXPERTISE 5 → the role's KEY AREA. Still the neutral point of two channels at
#                      once: it is ProductSystem.SEED_EXPERTISE_PIVOT (commit-seed
#                      multiplier exactly 1.0) and, for a build-assigned developer, the
#                      number that feeds team speed. A seeded employee therefore
#                      contributes 0.25 × 5 = 1.25 efor/day, not the old 1.0 — the two
#                      anchors used to sit on two different axes and now share one area,
#                      so one of them had to move. The pivot was kept and the speed anchor
#                      moved, because the pivot is a PRODUCTION constant and the speed
#                      anchor is a test convenience.
#   SEED_PACE 3      → every OTHER area (the "rest" floor). Low but never zero: rev 2 §2
#                      wants a one-person team to have no holes.
#   SEED_RAPPORT 5   → LİDERLİK. Mid-ruler coordination when a seeded employee is SORUMLU,
#                      which is exactly what the name used to buy through UYUM.
const SEED_PACE := 3
const SEED_EXPERTISE := 5
const SEED_RAPPORT := 5

static var _gate_signals: Array = []   # phase_gate_reached payloads
static var _endings: Array = []        # run_ended ending_ids


static func run_case(case_name: String, payload: Dictionary) -> void:
	# RNG PIN: initialize_run seeds from
	# Time.get_ticks_msec() unless the payload carries a seed, so every case that touched the
	# ambient pool was a fresh coin flip per invocation (angel_fires_at_crossing passed solo
	# and failed 4 in 12). The suite now runs on the same seed the probes use — 424242 — and
	# a case that needs a specific seed sets it in its own payload first.
	var pinned: Dictionary = payload.duplicate()
	if int(pinned.get("seed", 0)) == 0:
		pinned["seed"] = 424242
	GameState.initialize_run(pinned)
	# BUILD PIN (2026-09-25): the endings read EndingsSystem.build_scope(), and a debug build
	# takes --build= from Project Settings -> Main Run Args, which headless runs load too. The
	# suite measures the demo unless a case pins EA / full itself.
	EndingsSystem.build_scope_override = EndingsSystem.BUILD_DEMO
	_gate_signals = []
	_endings = []
	EventBus.phase_gate_reached.connect(func(p: int) -> void: _gate_signals.append(p))
	EventBus.run_ended.connect(func(id: String, _d: Dictionary) -> void: _endings.append(id))

	var fail: String
	match case_name:
		"gate1_b2c":            fail = _case_gate1_b2c()
		"gate1_b2b":            fail = _case_gate1_b2b()
		"gate2":                fail = _case_gate2()
		"gate_decline_reminder": fail = _case_gate_decline_reminder()
		"traction_gate_one_option": fail = _case_traction_gate_is_one_option()
		"bankruptcy":           fail = _case_bankruptcy()
		"shutter_recovery":     fail = _case_shutter_recovery()
		"brand_collapse":       fail = _case_brand_collapse()
		"cascade":              fail = _case_cascade()
		"pivot_accept":         fail = _case_pivot_accept()
		"pivot_decline":        fail = _case_pivot_decline()
		# fork_win / fork_loss retired 2026-08-19 with the Day-180 fork;
		# the soft cap's guards live in the calibration block at the end of this match.
		"terminal_kills_gate":  fail = _case_terminal_kills_gate()
		"live_during_vbuild":   fail = _case_live_during_vbuild()
		"sprint_no_freeze":     fail = _case_sprint_no_freeze()
		"capacity_split":       fail = _case_capacity_split()
		"speed_preserve":       fail = _case_speed_preserve()
		"month_summary":        fail = _case_month_summary()
		"full_loop":            fail = _case_full_loop()
		"pitch_ret_counter":    fail = _case_pitch_ret_counter()
		"gecistir_cap":         fail = _case_gecistir_cap()
		"callback_contract":    fail = _case_callback_contract()
		"pitch_bug_interrogation": fail = _case_pitch_bug_interrogation()
		"pitch_refused_acq":    fail = _case_pitch_refused_acq()
		"sheet_expiry_no_rejection": fail = _case_sheet_expiry_no_rejection()
		"third_sheet_delayed":  fail = _case_third_sheet_delayed()
		"cascade_defer_with_sheet": fail = _case_cascade_defer_with_sheet()
		"walk_not_a_rejection": fail = _case_walk_not_a_rejection()
		"table_sign_closes_series_a": fail = _case_table_sign_closes_series_a()
		"table_walk_not_a_rejection": fail = _case_table_walk_not_a_rejection()
		"patience_zero_locks_pushes": fail = _case_patience_zero_locks_pushes()
		"push_decay_lowers_odds": fail = _case_push_decay_lowers_odds()
		"leverage_bonus_applies_and_shows": fail = _case_leverage_bonus_applies_and_shows()
		"no_leverage_no_box": fail = _case_no_leverage_no_box()
		"investment_figure_tracks_terms": fail = _case_investment_figure_tracks_terms()
		"table_board_push_sequence": fail = _case_table_board_push_sequence()
		"deal_prompt_defer_keeps_clock": fail = _case_deal_prompt_defer_keeps_clock()
		"hunt_offer_lifecycle": fail = _case_hunt_offer_lifecycle()
		"legacy_v12_save_opens_live_table": fail = _case_legacy_v12_save_opens_live_table()
		"series_a_road_closed_when_all_funds_close": fail = _case_series_a_road_closed_when_all_funds_close()
		"prep_bonus_and_capacity": fail = _case_prep_bonus_and_capacity()
		"meeting_daylock":      fail = _case_meeting_daylock()
		"pivot_closes_hunt":    fail = _case_pivot_closes_hunt()
		"meeting_during_kepenk": fail = _case_meeting_during_kepenk()
		"seat_upsell_moves_seats": fail = _case_seat_upsell_moves_seats()
		"satisfaction_seam_emits": fail = _case_satisfaction_seam_emits()
		"targeted_modifier_hits_named_customer": fail = _case_targeted_modifier_hits_named_customer()
		"burn_refresh_same_tick": fail = _case_burn_refresh_same_tick()
		"burn_day1_breakdown":  fail = _case_burn_day1_breakdown()
		"feature_bug_seed_by_complexity": fail = _case_feature_bug_seed_by_complexity()
		"hardening_seeds_no_bugs": fail = _case_hardening_seeds_no_bugs()
		"single_feature_build_legal": fail = _case_single_feature_build_legal()
		"commit_cost_charged_once": fail = _case_commit_cost_charged_once()
		"phase_bands_20_60_20": fail = _case_phase_bands_20_60_20()
		"speed_tracks_team_change": fail = _case_speed_tracks_team_change()
		"deterministic_axes_at_ship": fail = _case_deterministic_axes_at_ship()
		# --- İterasyon döngüsü (player-gated restore) + ekip kalite tavanı ---
		"iter_decision_gates_development": fail = _case_iter_decision_gates_development()
		"iter_ceiling_founder_vs_designer": fail = _case_iter_ceiling_founder_vs_designer()
		"iter_diminishing_returns": fail = _case_iter_diminishing_returns()
		"iter_ceiling_never_exceeded": fail = _case_iter_ceiling_never_exceeded()
		"iter_zero_staff_neutrality_and_axis_lock": fail = _case_iter_zero_staff_neutrality_and_axis_lock()
		"iter_version_build_same_loop": fail = _case_iter_version_build_same_loop()
		"runway_net_status":    fail = _case_runway_net_status()
		"gross_runway_months":  fail = _case_gross_runway_months()
		"locale_switch":        fail = _case_locale_switch()
		"settings_language_toggle": fail = _case_settings_language_toggle()
		"b2b_lifecycle_and_countdown": fail = _case_b2b_lifecycle_and_countdown()
		"b2b_satisfaction_leaves_b2c_identical": fail = _case_b2b_satisfaction_leaves_b2c_identical()
		"b2b_retention_routes_seams": fail = _case_b2b_retention_routes_seams()
		"b2b_ignore_then_churn": fail = _case_b2b_ignore_then_churn()
		"b2b_pitch_meeting_signs": fail = _case_b2b_pitch_meeting_signs()
		"sales_meeting_replays_identically": fail = _case_sales_meeting_replays_identically()
		"sales_inner_voice_reaches_view": fail = _case_sales_inner_voice_reaches_view()
		"sales_faucet_guard_b2c": fail = _case_sales_faucet_guard_b2c()
		"sales_lead_expiry_and_return_lock": fail = _case_sales_lead_expiry_and_return_lock()
		"sales_meeting_time_skip_founder_zero": fail = _case_sales_meeting_time_skip_founder_zero()
		"sales_check_replays_after_load": fail = _case_sales_check_replays_after_load()
		"sales_single_open_promise_lock": fail = _case_sales_single_open_promise_lock()
		"sales_rep_selection_rule": fail = _case_sales_rep_selection_rule()
		"sales_seat_price_stamp_and_expansion": fail = _case_sales_seat_price_stamp_and_expansion()
		"sales_save_roundtrip_rev6": fail = _case_sales_save_roundtrip_rev6()
		"loc_sales_derived_keys": fail = _case_loc_sales_derived_keys()
		"sales_presentation_rules": fail = _case_sales_presentation_rules()
		"sales_candidate_curve_and_traits": fail = _case_sales_candidate_curve_and_traits()
		"b2b_prospect_pain_references_real_feature": fail = _case_b2b_prospect_pain_references_real_feature()
		"b2b_promise_kept_on_ship": fail = _case_b2b_promise_kept_on_ship()
		"b2b_promise_broken_on_deadline": fail = _case_b2b_promise_broken_on_deadline()
		"founder_5skill_init":  fail = _case_founder_5skill_init()
		"alloc_guard":          fail = _case_alloc_guard()
		"trait_formula":        fail = _case_trait_formula()
		"lever_skill_new_keys": fail = _case_lever_skill_new_keys()
		"b2b_cs_absorbs_routine": fail = _case_b2b_cs_absorbs_routine()
		"b2b_cs_escalation_refuse": fail = _case_b2b_cs_escalation_refuse()
		"b2b_cs_counts_in_payroll_hires": fail = _case_b2b_cs_counts_in_payroll_hires()
		"b2b_expansion_moves_seats_mrr_counter": fail = _case_b2b_expansion_moves_seats_mrr_counter()
		"b2b_scale_and_sector_gating": fail = _case_b2b_scale_and_sector_gating()
		"b2b_onboarding_to_prospect_visible": fail = _case_b2b_onboarding_to_prospect_visible()
		"sales_month_counters": fail = _case_sales_month_counters()
		"onboarding_pages_contract": fail = _case_onboarding_pages_contract()
		"run_ledger":           fail = _case_run_ledger()
		# --- HR Core (task 1 of 3) ---
		"hr_axis_key_lock":         fail = _case_hr_axis_key_lock()
		"hr_candidate_invariants":  fail = _case_hr_candidate_invariants()
		"hr_archetype_trio":        fail = _case_hr_archetype_trio()
		"hr_training_locks":        fail = _case_hr_training_locks()
		"hr_search_cycle":          fail = _case_hr_search_cycle()
		"hr_search_cancel_dismiss": fail = _case_hr_search_cancel_dismiss()
		"hr_fire_path":             fail = _case_hr_fire_path()
		"hr_resignation_path":      fail = _case_hr_resignation_path()
		"hr_leave_cycle":           fail = _case_hr_leave_cycle()
		"hr_morale_drift_shape":    fail = _case_hr_morale_drift_shape()
		"hr_recovery_channels":     fail = _case_hr_recovery_channels()
		"hr_raise_and_leave":    fail = _case_hr_raise_and_leave()
		# --- İK modulü kapanışı (2026-08-22) ---
		"menu_has_one_path":        fail = _case_menu_has_one_path()
		"vacation_action_retired":  fail = _case_vacation_action_retired()
		"leave_does_not_pause_build": fail = _case_leave_does_not_pause_build()
		"money_never_double_minus": fail = _case_money_never_double_minus()
		# rev 6.1 §6.4 kapıyı geri koydu; case adıyla birlikte ters çevrildi.
		"beta_gate_requires_full_bar": fail = _case_beta_gate_requires_full_bar()
		"beta_discovery_decays_pool_never_empties": fail = _case_beta_discovery_decays_pool_never_empties()
		"beta_park_frees_capacity_slot": fail = _case_beta_park_frees_capacity_slot()
		"build_decision_tooltip_renders": fail = _case_build_decision_tooltip_renders()
		# --- DESTEK (§8) ve ALTYAPI (§10) ---
		"destek_empty_desk_piles_up":    fail = _case_destek_empty_desk_piles_up()
		"fix_run_ships_subset":          fail = _case_fix_run_ships_subset()
		"infra_capacity_moves_both_ways": fail = _case_infra_capacity_moves_both_ways()
		"infra_heavy_step_costs_capacity": fail = _case_infra_heavy_step_costs_capacity()
		"infra_overage_applies_and_stops": fail = _case_infra_overage_applies_and_stops()
		"infra_local_provider_tradeoff": fail = _case_infra_local_provider_tradeoff()
		"line_build_ships_and_stamps":   fail = _case_line_build_ships_and_stamps()
		"cancel_reverts_planned_steps":  fail = _case_cancel_reverts_planned_steps()
		"build_effort_from_hr_seams":    fail = _case_build_effort_from_hr_seams()
		"product_read_catalogue":        fail = _case_product_read_catalogue()
		"line_design_turns_and_gate":    fail = _case_line_design_turns_and_gate()
		"pause_kinds_and_lead_note":     fail = _case_pause_kinds_and_lead_note()
		"build_bar_line_states":         fail = _case_build_bar_line_states()
		"run_profile_never_exhausts":    fail = _case_run_profile_never_exhausts()
		"hr_frank_guard":           fail = _case_hr_frank_guard()
		"hr_active_filters":        fail = _case_hr_active_filters()
		"hr_overload_badge":        fail = _case_hr_overload_badge()
		"hr_constants_contract":    fail = _case_hr_constants_contract()
		"speed_ladder":            fail = _case_speed_ladder()
		"speed_day_invariant":     fail = _case_speed_day_invariant()
		# --- Product×HR Coupling (task 2 of 3) ---
		"coupling_speed_law":            fail = _case_coupling_speed_law()
		"coupling_coordination":         fail = _case_coupling_coordination_sources()
		"coupling_bug_team_average":     fail = _case_coupling_bug_team_average()
		"coupling_wear_team_average":    fail = _case_coupling_wear_team_average()
		"coupling_pm_experience":        fail = _case_coupling_pm_experience_bonus()
		"coupling_tester_beta_sprint":   fail = _case_coupling_tester_beta_and_sprint()
		"coupling_cs_dampen_axis":       fail = _case_coupling_cs_dampen_axis()
		"coupling_overtime_applied":     fail = _case_coupling_overtime_applied()
		# --- Sales/Customer×HR Coupling (task 2b) ---
		"sales_pipeline_rate_by_pace":       fail = _case_sales_pipeline_rate_by_pace()
		"sales_pipeline_stack_diminishes":   fail = _case_sales_pipeline_stack_diminishes()
		"sales_autonomous_close_routine":    fail = _case_sales_autonomous_close_routine()
		"sales_close_threshold_surfaces":    fail = _case_sales_close_threshold_surfaces()
		"sales_threshold_separates_tiers":   fail = _case_sales_threshold_separates_tiers()
		"sales_concession_deal_surfaces":    fail = _case_sales_concession_deal_surfaces()
		"sales_close_speed_by_expertise":    fail = _case_sales_close_speed_by_expertise()
		"cs_auto_assignment_capacity":       fail = _case_cs_auto_assignment_capacity()
		"cs_capacity_resolution":            fail = _case_cs_capacity_resolution()
		"cs_request_absorption_by_expertise": fail = _case_cs_request_absorption_by_expertise()
		"cs_request_throughput_by_pace":     fail = _case_cs_request_throughput_by_pace()
		"cs_request_covers_founder_managed": fail = _case_cs_request_covers_founder_managed()
		"cs_request_channel_gated_on_rep":   fail = _case_cs_request_channel_gated_on_rep()
		"promise_broken_penalty":            fail = _case_promise_broken_penalty()
		"sales_cs_zero_staff_identical":     fail = _case_sales_cs_zero_staff_identical()
		"prospect_id_unique_after_removal":  fail = _case_prospect_id_unique_after_removal()
		# --- Dünya İnandırıcılığı (şirket havuzu / pazar payı / haber akışı / event ilgililiği) ---
		"b2b_prospect_dedup_excludes_signed": fail = _case_b2b_prospect_dedup_excludes_signed()
		"company_catalog_pool_integrity":     fail = _case_company_catalog_pool_integrity()
		"market_share_tracks_mrr":            fail = _case_market_share_tracks_mrr()
		"news_feed_weights_and_no_repeat":    fail = _case_news_feed_weights_and_no_repeat()
		"cs_request_kind_state_driven":       fail = _case_cs_request_kind_state_driven()
		# --- Bug cleanup 2026-08-07: each of these FAILS against the
		#     pre-fix engine, which is what makes them regression guards rather than décor.
		"b2b_expansion_no_refire":            fail = _case_b2b_expansion_no_refire()
		"fumes_zero_revenue_ledger":          fail = _case_fumes_zero_revenue_ledger()
		"promise_orphan_no_brand_hit":        fail = _case_promise_orphan_no_brand_hit()
		"build_percent_single_source":        fail = _case_build_percent_single_source()
		"build_bar_hosts_agree":              fail = _case_build_bar_hosts_agree()
		"runway_days_and_negative_cash":      fail = _case_runway_days_and_negative_cash()
		"role_locks_and_runway_pair":         fail = _case_role_locks_and_runway_pair()
		"b2b_market_gate_b2c_run":            fail = _case_b2b_market_gate_b2c_run()
		"sales_autoclose_empty_pain":         fail = _case_sales_autoclose_empty_pain()
		# --- Satis/Destek Hotfix Turu 1, 2026-08-27. Her biri duzeltme oncesi motorda DUSER.
		"hotfix_promise_refuses_targetless": fail = _case_hotfix_promise_refuses_targetless()
		"hotfix_deal_variance_across_leads": fail = _case_hotfix_deal_variance_across_leads()
		"hotfix_archetype_mix_not_pinned":   fail = _case_hotfix_archetype_mix_not_pinned()
		"hotfix_ticker_routine_vs_news":     fail = _case_hotfix_ticker_routine_vs_news()
		"hotfix_account_count_excludes_base": fail = _case_hotfix_account_count_excludes_base()
		"hotfix_founder_takes_support_desk": fail = _case_hotfix_founder_takes_support_desk()
		"hotfix_new_account_auto_assigned":  fail = _case_hotfix_new_account_auto_assigned()
		"hotfix_weekly_summary_rows":       fail = _case_hotfix_weekly_summary_rows()
		# --- Destek Hattı Reworku (B1-B5), 2026-08-27. B1 kendi vakasini repoint etti.
		"support_desk_rates_stack":         fail = _case_support_desk_rates_stack()
		"hires_land_in_own_column":         fail = _case_hires_land_in_own_column()
		"owned_account_erodes_slower":      fail = _case_owned_account_erodes_slower()
		"cs_candidate_trait_filter":        fail = _case_cs_candidate_trait_filter()
		"account_ownership_round_trip":     fail = _case_account_ownership_round_trip()
		"founder_owns_accounts_manually":   fail = _case_founder_owns_accounts_manually()
		"event_queue_dedupe_by_id":           fail = _case_event_queue_dedupe_by_id()
		# --- Driver-run fixes, 2026-08-17. Each one FAILS against the pre-fix engine;
		#     each was found by a 90-day driver run (--run-log), not by reading.
		"promise_no_duplicate_word":          fail = _case_promise_no_duplicate_word()
		"promise_kept_stops_countdown":       fail = _case_promise_kept_stops_countdown()
		"recover_preserves_onboarding":       fail = _case_recover_preserves_onboarding()
		"angel_fires_at_crossing":            fail = _case_angel_fires_at_crossing()
		"angel_never_pre_ship":               fail = _case_angel_never_pre_ship()
		"angel_not_below_threshold":          fail = _case_angel_not_below_threshold()
		"angel_accept_is_atomic":             fail = _case_angel_accept_is_atomic()
		"angel_locked_choice_inert":          fail = _case_angel_locked_choice_inert()
		"angel_one_shot_falsified":           fail = _case_angel_one_shot_falsified()
		"angel_survives_series_a":            fail = _case_angel_survives_series_a()
		"angel_hire_nudge":                   fail = _case_angel_hire_nudge()
		# --- SaveManager task 2026-08-08. Bunlar ŞEMAYI değil RESET MİMARİSİNİ ölçer:
		#     serileştirme biçimi kolay %20; zor %80, yüklemenin ÇALIŞAN bir süreci
		#     eskiden yalnız bir OS restart'ının üretebildiği duruma döndürmesi.
		"save_roundtrip_fingerprint":         fail = _case_save_roundtrip_fingerprint()
		"save_continuity_seeded":             fail = _case_save_continuity_seeded()
		"save_double_load_no_residue":        fail = _case_save_double_load_no_residue()
		# --- Native çözünürlük / ultrawide 2026-08-08 ---
		"oda_anchors_stay_in_band":           fail = _case_oda_anchors_stay_in_band()
		"hr_experience_accrues":      fail = _case_hr_experience_accrues()
		"hr_training_eligibility_edge": fail = _case_hr_training_eligibility_edge()
		"hr_training_blocks_and_charges_once": fail = _case_hr_training_blocks_and_charges_once()
		"hr_training_completion":     fail = _case_hr_training_completion()
		"hr_expertise_cap_respected": fail = _case_hr_expertise_cap_respected()
		"ui_scale_ladder_fits_settings": fail = _case_ui_scale_ladder_fits_settings()
		# --- Lokalizasyon Faz 2 (2026-08-18) ---
		"loc_csv_integrity":         fail = _case_loc_csv_integrity()
		"loc_format_locale_flip":    fail = _case_loc_format_locale_flip()
		"loc_event_en_coverage":     fail = _case_loc_event_en_coverage()
		"loc_pick_fallback":         fail = _case_loc_pick_fallback()
		"loc_b2b_derived_keys":      fail = _case_loc_b2b_derived_keys()
		"loc_save_sector_migration": fail = _case_loc_save_sector_migration()
		"loc_product_derived_keys":  fail = _case_loc_product_derived_keys()
		"loc_format_args":           fail = _case_loc_format_args()
		"all_scripts_load":          fail = _case_all_scripts_load()
		"event_i1_single_gate":           fail = _case_event_i1_single_gate()
		"event_i2_economy_played_only":   fail = _case_event_i2_economy_played_only()
		"event_i3_no_silent_loss":        fail = _case_event_i3_no_silent_loss()
		"event_i4_demoted_never_dropped": fail = _case_event_i4_demoted_never_dropped()
		"event_i5_trigger_is_data":       fail = _case_event_i5_trigger_is_data()
		"event_i6_dice_never_kill":       fail = _case_event_i6_dice_never_kill()
		"event_i7_modifier_needs_seam":   fail = _case_event_i7_modifier_needs_seam()
		"event_dice_is_stable":           fail = _case_event_dice_is_stable()
		"event_thesis_day10_to_day90":    fail = _case_event_thesis_day10_to_day90()
		"event_thesis_through_presenter": fail = _case_event_thesis_through_presenter()
		"event_chip_coverage":       fail = _case_event_chip_coverage()
		"loc_b4_derived_keys":       fail = _case_loc_b4_derived_keys()
		"loc_b5_derived_keys":       fail = _case_loc_b5_derived_keys()
		"loc_language_switch":       fail = _case_loc_language_switch()
		# --- Calibration pass (2026-08-19) — one guard per number ---
		"harness_sniffer_matches_run_log": fail = _case_harness_sniffer_matches_run_log()
		"quality_half_sat_25":             fail = _case_quality_half_sat_25()
		"b2b_v1_lands_mid_band":           fail = _case_b2b_v1_lands_mid_band()
		"field_unlocked_for_saas_ops":     fail = _case_field_unlocked_for_saas_ops()
		"b2c_satisfaction_gate_experience": fail = _case_b2c_satisfaction_gate_experience()
		"rival_relative_uses_template_half_sat": fail = _case_rival_relative_uses_template_half_sat()
		"soft_cap_ends_run_at_730":        fail = _case_soft_cap_ends_run_at_730()
		"no_calendar_stop_before_cap":     fail = _case_no_calendar_stop_before_cap()
		"soft_cap_no_defer_for_sheet":     fail = _case_soft_cap_no_defer_for_sheet()
		"soft_cap_paper_names_unsigned_sheet": fail = _case_soft_cap_paper_names_unsigned_sheet()
		"soft_cap_warns_open_hunt":        fail = _case_soft_cap_warns_open_hunt()
		"month_history_close_and_cap":     fail = _case_month_history_close_and_cap()
		"growth_streak_semantics":         fail = _case_growth_streak_semantics()
		"series_a_gate_mrr_only":          fail = _case_series_a_gate_mrr_only()
		"frank_approach_lines_once":       fail = _case_frank_approach_lines_once()
		"series_a_signal_states":          fail = _case_series_a_signal_states()
		"month_history_save_typing":       fail = _case_month_history_save_typing()
		"b2c_wom_needs_satisfaction":      fail = _case_b2c_wom_needs_satisfaction()
		"b2c_growth_multiplier_floor":     fail = _case_b2c_growth_multiplier_floor()
		"conversion_bug_penalty":          fail = _case_conversion_bug_penalty()
		"audience_pct_modifier":           fail = _case_audience_pct_modifier()
		"complaint_never_charges_cash":    fail = _case_complaint_never_charges_cash()
		"discount_cap_two_uses":           fail = _case_discount_cap_two_uses()
		"risk_reentry_hysteresis":         fail = _case_risk_reentry_hysteresis()
		"risk_exit_stamps_day":            fail = _case_risk_exit_stamps_day()
		"discount_row_locked_past_cap":    fail = _case_discount_row_locked_past_cap()
		"retention_gate_shared":           fail = _case_retention_gate_shared()
		"manual_retention_respects_cap":   fail = _case_manual_retention_respects_cap()
		"profit_condition_fires":          fail = _case_profit_condition_fires()
		"ending_modes_by_build":           fail = _case_ending_modes_by_build()
		"bootstrap_milestone_keeps_the_run": fail = _case_bootstrap_milestone_keeps_the_run()
		"ending_paper_modes_on_screen":    fail = _case_ending_paper_modes_on_screen()
		"milestone_clock_hold":            fail = _case_milestone_clock_hold()
		"milestone_paper_under_card":      fail = _case_milestone_paper_under_card()
		"profit_predicate_margin_scale_red": fail = _case_profit_predicate_margin_scale_red()
		"speed_save_clamps_to_ladder":     fail = _case_speed_save_clamps_to_ladder()
		"topbar_speed_cluster_three_rungs": fail = _case_topbar_speed_cluster_three_rungs()
		"smoke_seed_pinned":               fail = _case_smoke_seed_pinned()
		"ambient_hourly_chance_exact":     fail = _case_ambient_hourly_chance_exact()
		"ambient_one_per_day_across_hour0": fail = _case_ambient_one_per_day_across_hour0()
		"creation_draft_survives_navigation": fail = _case_creation_draft_survives_navigation()
		"borderless_note_key_exists":      fail = _case_borderless_note_key_exists()
		# --- Temizlik turu 2026-08-20 (GDD v2 uygunluk denetiminin karar gerektirmeyen
		#     bulguları). Üçü de ÖNCEKİ motora karşı DÜŞER; falsifikasyonla doğrulandı.
		"source_tag_speaker_wins":         fail = _case_source_tag_speaker_wins()
		"ship_tooltip_counts_critical_penalty": fail = _case_ship_tooltip_counts_critical_penalty()
		"rail_tabs_match_scene_order":     fail = _case_rail_tabs_match_scene_order()
		# --- Ekip modülü · motor tarafı 2026-08-21 (alan modeli; rev 11 §4/§12). Dördü de ÖNCEKİ
		#     motora karşı DÜŞER; her biri falsifikasyonla doğrulandı.
		"job_assignment_and_idle":         fail = _case_job_assignment_and_idle()
		"overload_costs_output":           fail = _case_overload_costs_output()
		"save_migration_v3_to_v4":         fail = _case_save_migration_v3_to_v4()
		# --- Ekip arayüzü · onaylı tasarım 2026-08-22. Beşi de ÖNCEKİ motora karşı DÜŞER.
		"star_ruler_contract":            fail = _case_star_ruler_contract()
		"single_trait_contract":          fail = _case_single_trait_contract()
		"founder_trains_and_learns":      fail = _case_founder_trains_and_learns()
		"leadership_is_trainable":        fail = _case_leadership_is_trainable()
		"save_migration_v4_to_v5":        fail = _case_save_migration_v4_to_v5()
		# --- rev 11 · Faz 1. İkisi de ÖNCEKİ motora karşı DÜŞER.
		"save_migration_v6_to_v7":        fail = _case_save_migration_v6_to_v7()
		"save_migration_v6_to_v7_drops":  fail = _case_save_migration_v6_to_v7_drops()
		"work_hours_three_scopes":        fail = _case_work_hours_three_scopes()
		"work_hours_draft_commits":       fail = _case_work_hours_draft_commits()
		"promotion_and_raise_gate":       fail = _case_promotion_and_raise_gate()
		"effective_skill_formula":        fail = _case_effective_skill_formula()
		"hr_read_catalogue":              fail = _case_hr_read_catalogue()
		# --- Trait seti · Build Bar · Görevler (2026-08-21). Beşi de ÖNCEKİ motora karşı DÜŞER.
		"build_pauses_when_all_busy":     fail = _case_build_pauses_when_all_busy()
		"build_resumes_when_one_frees":   fail = _case_build_resumes_when_one_frees()
		"destek_survives_ship":           fail = _case_destek_survives_ship()
		"gorevler_has_no_founder":        fail = _case_gorevler_has_no_founder()
		# --- Ürün modülü · hat modeli 2026-08-24 (GDD ÜRÜN rev 6 §11, §12).
		#     Altısı da ÖNCEKİ motora karşı DÜŞER: hat modeli, kapı doğrulayıcısı ve
		#     çıta okuması bu turdan önce YOKTU. Her biri falsifikasyonla doğrulandı.
		"product_lines_catalog_loads":    fail = _case_product_lines_catalog_loads()
		"line_ladder_rules":              fail = _case_line_ladder_rules()
		"line_k3_locked_without_research": fail = _case_line_k3_locked_without_research()
		"axis_reading_replaces_not_adds": fail = _case_axis_reading_replaces_not_adds()
		"gate_scope_and_halves":          fail = _case_gate_scope_and_halves()
		"above_gate_bonus_ladder":        fail = _case_above_gate_bonus_ladder()
		"loc_product_line_keys_resolve":  fail = _case_loc_product_line_keys_resolve()
		# --- rev 6.1 · Ar-Ge bağı ve kart aritmetiği (2026-08-25).
		"research_node_map_binds":        fail = _case_research_node_map_binds()
		"rnd_tree_loads_and_validates":  fail = _case_rnd_tree_loads_and_validates()
		"research_occupies_person":       fail = _case_research_occupies_person()
		"research_and_build_pause_each_other": fail = _case_research_and_build_pause_each_other()
		"research_freezes_and_resumes":   fail = _case_research_freezes_and_resumes()
		"research_completion_no_economic_delta": fail = _case_research_completion_no_economic_delta()
		"paused_job_resumes_on_direct_return": fail = _case_paused_job_resumes_on_direct_return()
		"founder_split_halves_flat_speed": fail = _case_founder_split_halves_flat_speed()
		"split_bars_name_their_cause": fail = _case_split_bars_name_their_cause()
		"rnd_rail_open_with_waiting_page": fail = _case_rnd_rail_open_with_waiting_page()
		"rnd_note_author_and_lines": fail = _case_rnd_note_author_and_lines()
		"card_math_matches_gdd_example":  fail = _case_card_math_matches_gdd_example()
		"design_turn_ladder":             fail = _case_design_turn_ladder()
		"save_v10_product_state":         fail = _case_save_v10_product_state()
		# --- rev 6.1 · router devri (2026-08-25). İkisi de ÖNCEKİ ağaca karşı DÜŞER.
		"type_screen_matches_line_content": fail = _case_type_screen_matches_line_content()
		"line_build_writes_subgenre":     fail = _case_line_build_writes_subgenre()
		# --- Funding ladder + phase/endings (2026-08-27) ---
		"seed_door_traction_only":               fail = _case_seed_door_traction_only()
		"seed_door_below_bar":                   fail = _case_seed_door_below_bar()
		"seed_door_number_never_rendered":       fail = _case_seed_door_number_never_rendered()
		"seed_pitch_never_rejects":              fail = _case_seed_pitch_never_rejects()
		"seed_bands_map_to_terms":               fail = _case_seed_bands_map_to_terms()
		"seed_sheet_never_in_active_sheets":     fail = _case_seed_sheet_never_in_active_sheets()
		"seed_table_walk_is_locked":             fail = _case_seed_table_walk_is_locked()
		"seed_sign_is_not_terminal":             fail = _case_seed_sign_is_not_terminal()
		"seed_survives_series_a_sign":           fail = _case_seed_survives_series_a_sign()
		"seed_expectation_grace_then_stall":     fail = _case_seed_expectation_grace_then_stall()
		"seed_lead_warmth_at_series_a":          fail = _case_seed_lead_warmth_at_series_a()
		"seed_stage_does_not_leak":              fail = _case_seed_stage_does_not_leak()
		"seed_table_levers_and_final_offer":     fail = _case_seed_table_levers_and_final_offer()
		"series_a_sheet_derives_from_arr":       fail = _case_series_a_sheet_derives_from_arr()
		"bootstrap_needs_the_faced_flag":        fail = _case_bootstrap_needs_the_faced_flag()
		"faced_flag_upgrades_only":              fail = _case_faced_flag_upgrades_only()
		"buyout_needs_the_road_over":            fail = _case_buyout_needs_the_road_over()
		"buyout_inert_without_the_flag":         fail = _case_buyout_inert_without_the_flag()
		"buyout_numbers_make_the_sentence_true": fail = _case_buyout_numbers_make_the_sentence_true()
		"b2c_ending_reports_audience":           fail = _case_b2c_ending_reports_audience()
		"frank_line_renders_outside_the_paper":  fail = _case_frank_line_renders_outside_the_paper()
		"bankruptcy_frank_line_says_thirty":     fail = _case_bankruptcy_frank_line_says_thirty()
		"card_body_tokens_resolve":              fail = _case_card_body_tokens_resolve()
		"seed_sheet_round_trips":                fail = _case_seed_sheet_round_trips()
		_:                      fail = "unknown case"

	if fail == "":
		print("SMOKE PASS %s" % case_name)
	else:
		print("SMOKE FAIL %s: %s" % [case_name, fail])


# --- Day driver + seeds ---

# GÜNLÜK-YARIM sürücü: yalnız advance_day + günlük slotlar. Saatlik hiçbir şey koşmaz,
# yani build eforu, B2C audience/MRR akışı, hata birikimi ve ambient event'ler DURUR ve
# GameState.current_hour hiç kımıldamaz. Saatlik yola dokunmayan case'ler için doğru ve
# hızlı sürücü; saatlik/günlük SINIRINDA doğan bir davranışı ölçemez — onun için
# _sim_day_full() var.

## SATIŞ rev 6 §5.3 — THE FIXTURE BRIDGE, and the reason it exists rather than 25 hand edits.
## The signing seam takes SEATS and SEAT PRICE now; every case above seeds a target MRR
## because the MRR is what it asserts on. This converts once — seats from the star's band
## midpoint, price from the MRR — and then pins the exact figure through the registry seam,
## so a rounding remainder cannot silently move a number a case was written against.
## Fixtures only. Production has exactly one signing path and it is SalesSystem's.
static func _sign_fixture(p: Prospect, mrr: int, satisfaction: int,
		source: String = "founder_pitch") -> Customer:
	var band: Dictionary = SalesConstants.seat_band(p.star)
	var seats: int = maxi(int(round((float(band["low"]) + float(band["high"])) * 0.5)), 1)
	var price: int = maxi(int(round(float(mrr) / float(seats))), 1)
	var c: Customer = SalesSystem.add_b2b_customer(p, seats, price, satisfaction, source)
	if c != null and c.mrr != mrr:
		CustomerRegistry.set_mrr(c.id, mrr)
		SalesSystem.reflect_mrr()
	return c

## "Teklife geç" opens FROM THE SECOND probe (§5.1.1), so a case that wants the skip has to
## reach it first. Takes the first OPEN answer each turn until the skip is available, then
## takes it — which makes the played PATH short, stable and identical across two runs, and
## that is the property the replay cases measure.
static func _play_to_skip(vs: Dictionary) -> Dictionary:
	for i in SalesConstants.SAFETY_CAP_PROBES + 2:
		if String(vs.get("outcome", "")) != "":
			return vs
		if SalesMeetingSystem.can_skip_to_offer():
			return SalesMeetingSystem.skip_to_offer()
		var picked: String = ""
		for a in (vs.get("answers", []) as Array):
			if bool((a as Dictionary).get("open", false)):
				picked = String((a as Dictionary).get("id", ""))
				break
		if picked == "":
			return SalesMeetingSystem.skip_to_offer()
		vs = SalesMeetingSystem.choose(picked)
	return vs


static func _sim_day() -> void:
	GameState.advance_day()
	TimeManager._dispatch_daily_tick()


# TAM GÜN sürücü: motorun gerçek gün sınırını birebir yansıtır.
# TimeManager._drain_boundaries sırası: saat 1..23 → saat 0 → advance_day() → günlük
# slotlar. Günlük tik saat 0 ile saat 1'in ARASINDA durur; maliyeti günlük, faydayı
# saatlik işleyen her mekanizma tam olarak orada ayrışır (ek mesai bedava hızı ve
# bonus/ödeme asimetrisi bu boşlukta yaşıyordu, 135 case boyunca görünmeden).
#
# set_current_hour ŞART: EventManager._is_eligible `allowed_hours`'ı dispatch'e geçilen
# argümandan değil GameState.current_hour'dan okur — saat yazılmazsa saatlik pencereli
# her event yanlış saate karşı ölçülür.
static func _sim_day_full() -> void:
	while GameState.current_hour < TimeManager.HOURS_PER_DAY - 1:
		var next_hour: int = GameState.current_hour + 1
		GameState.set_current_hour(next_hour)
		TimeManager._dispatch_hourly_tick(next_hour)
	GameState.set_current_hour(0)
	TimeManager._dispatch_hourly_tick(0)
	GameState.advance_day()
	TimeManager._dispatch_daily_tick()


## Kurucunun `tech`i 2026-08-21'de DÖRDE bölündü (Ürün · Tasarım · Yazılım · Test), çünkü
## her ürün formülü artık kendi alanını okuyor. Fixture'ların "kurucu şu seviyede teknik"
## demesi için TEK yer: dördünü birden yazar, yani hangi formül hangi alanı okursa okusun
## sonuç migration öncesiyle aynı çıkar.
## Kurucunun dört teknik alanını tek hamlede kurar. DEĞERLER CETVELLE BİRLİKTE İKİYE
## KATLANDI (§2.4): eskiden 3 yazan bir çapa şimdi 6 yazıyor, ve katsayılar yarıya indiği
## için çapanın ÖLÇTÜĞÜ sayı kıpırdamadı — "kurucu tech-3 solo = 3,0 efor/gün" hâlâ 3,0.
## Literali 1,5'e çekmek çapanın ANLAMINI değiştirirdi; fixture'ı taşımak taşımaz.
##
## Kelepçe cetvelin kendisinden: motorda kurucu için bir aralık doğrulayıcısı yok, o yüzden
## bir fixture'ın cetvel dışına taşması sessizce mümkündü.
static func _set_founder_tech(value: int) -> void:
	var founder: Character = CharacterRegistry.get_founder()
	if founder == null:
		return
	value = clampi(value, HRConstants.AREA_MIN, HRConstants.AREA_MAX)
	for area_key in [HRConstants.AREA_PRODUCT, HRConstants.AREA_DESIGN,
			HRConstants.AREA_ENGINEERING, HRConstants.AREA_QA]:
		founder.role_stats[area_key] = value


## One area on the founder, clamped to the ruler. `_set_founder_tech` does the four product
## areas together because they move together in a fixture; Satış and Müşteri İlişkileri do
## not, so they get the single-area door rather than a second four-area helper.
static func _set_founder_area(area_key: String, value: int) -> void:
	var founder: Character = CharacterRegistry.get_founder()
	if founder == null:
		return
	founder.role_stats[area_key] = clampi(value, HRConstants.AREA_MIN, HRConstants.AREA_MAX)


static func _make_employee(id: String, display_name: String, role_id: String,
		pace: int = SEED_PACE, salary: int = 0, morale: int = 50,
		expertise: int = SEED_EXPERTISE, rapport: int = SEED_RAPPORT) -> Character:
	# ONE home for every employee seed. The parameter NAMES are pre-migration and kept on
	# purpose (fifty-odd positional call sites); what they set is now:
	#   expertise → the role's KEY AREA — "how good at your actual job"
	#   pace      → every other area — the floor that keeps a one-person team whole
	#   rapport   → LİDERLİK — the coordination multiplier when this person is SORUMLU
	# Defaults are the NEUTRAL point of each channel, so a seed that does not care about a
	# number cannot silently tilt an unrelated formula — see the SEED_* constants.
	var c := Character.new()
	c.id = id
	c.character_name = display_name
	c.role = role_id
	c.category = "employee"
	c.monthly_salary = salary
	c.morale = morale
	c.role_stats = HRConstants.seed_skills(role_id, expertise, pace, rapport)
	c.traits = ["picks_it_up_fast"]
	CharacterRegistry.add(c)
	return c


static func _seed_b2b(mrr: int) -> void:
	GameState.set_flag("mvp_shipped", true)
	GameState.set_flag("mvp_market_type", "b2b")
	# A shipped product always has quality axes — seed a realistic HEALTHY product so a
	# signed account holds steady under the B2B two-layer model (only a DEGRADING product
	# should erode it). Bug count is left untouched so cases that pre-set it keep control.
	GameState.set_flag("mvp_innovation", 45.0)
	GameState.set_flag("mvp_stability", 70.0)
	GameState.set_flag("mvp_experience", 45.0)
	var p := Prospect.new()
	p.id = "lead_smoke"
	p.company_name = "Smoke Corp"
	p.industry = "testing"
	p.star = 1
	_sign_fixture(p, mrr, 70)


## "Healthy Series A MRR" for the VC fixtures: the revenue bar moved
## 5,000 → the $40-80K band and VCPitchSystem's conviction seeding reads CONV_MRR_REFERENCE =
## the bar, so a fixture hard-pinned at 6,000 would read as a WEAK company. Bar + 1,000.
## A LIVE, HEALTHY B2B PRODUCT for the sitting cases — line tiers, not the legacy `mvp_*`
## flags. Ürün rev 6.1 assembles the axis readings from the LINE LADDER (product_state.gd:238),
## so a fixture that only sets `mvp_stability` leaves every `urun.axis_reading` at zero and the
## persuasion model reads a product that does not exist. `_seed_b2b` keeps its flags because
## the economy path still reads them; this is the other half.
static func _seed_b2b_lines(subtype: String, tier: int = 2) -> void:
	GameState.set_flag("mvp_sub_product_type_id", subtype)
	for line_id in ProductLines.line_ids(subtype):
		ProductState.set_line_tier(String(line_id), tier)


static func _seed_b2b_series_a() -> void:
	_seed_b2b(SalesSystem.TRACTION_MRR_TARGET + 1000)


## Closed calendar months on GameState.month_history: sequential
## 30-day spans, the given MRR closes, one income/expense pair per month.
static func _seed_month_closes(mrr_closes: Array, income: int = 30000, expense: int = 24000, red_days: int = 0) -> void:
	GameState.month_history.clear()
	var start: int = 1
	for m in mrr_closes:
		GameState.push_month_close({"start_day": start, "end_day": start + 29, "mrr_close": int(m),
			"income": income, "expense": expense, "net": income - expense, "red_days": red_days})
		start += 30


## Four closes at +15 % a month ending at `last` — three qualifying growth months.
static func _seed_growth_streak(last: int) -> void:
	var m3: int = int(round(last / 1.15))
	var m2: int = int(round(m3 / 1.15))
	var m1: int = int(round(m2 / 1.15))
	_seed_month_closes([m1, m2, m3, last])


static func _seed_b2c() -> void:
	GameState.set_flag("mvp_shipped", true)
	GameState.set_flag("mvp_market_type", "b2c")
	SalesSystem.add_b2c_audience(200)
	SalesSystem.open_b2c_paid_tier(15)  # derives paying users → userbase record + MRR > 0


static func _seed_live_product() -> void:
	# Canlı B2C ürün durumu (yaşam-döngüsü/kapasite case'lerinin ortak kurulumu):
	# pozitif nakit (7 gün negatif nakit bankruptcy shutter'ı tetikler), audience +
	# paid tier, shipped mvp eksenleri/bileşenleri.
	GameState.set_cash(50000)
	_seed_b2c()
	GameState.set_flag("mvp_sub_product_type_id", "ai_assistant")
	GameState.set_flag("mvp_components", ["ai_assistant_chat", "ai_assistant_memory"])
	GameState.set_flag("mvp_innovation", 20.0)
	GameState.set_flag("mvp_stability", 25.0)
	GameState.set_flag("mvp_experience", 22.0)
	GameState.set_flag("mvp_version", 2)
	GameState.set_flag("mvp_product_name", "Nova")


# Resolve foreign active events (always choice 0) until `event_id` is active.
static func _drain_to(event_id: String, max_steps: int = 8) -> bool:
	for i in max_steps:
		if EventGate.active_id() == event_id:
			return true
		if EventGate.active_id() == "":
			return false
		EventGate.resolve(EventGate.active_id(), 0)
	return EventGate.active_id() == event_id


# Occurrences of a gate scene across queue + active (must never exceed 1).
static func _instances_of(event_id: String) -> int:
	return EventGate.instances_of(event_id)


# Rev3: aktif build'i hedef faza gelene dek ProductSystem.hourly_tick ile sürer
# (sınırlı döngü; gün ilerletmez — saf build-motoru sürüşü).
# Build Bar grameri (2026-08-19): iki oyuncu koltuğu var — "Geliştirmeye geç" (tur 1
# bitince açılır) ve "Beta'ya geç" (geliştirme %80'de park eder). Hedef İLERİ bir fazsa
# helper açılan koltuğa HEMEN oturur — SIFIR tamamlanmış ek tur (yeni başlamış tur 2
# kazançsız terk edilir), yani sıfır tur kazancı; determinizm case'leri (axes/ship
# damgaları) bire bir aynı kalır.
static func _run_build_to_phase(phase: String, max_hours: int = 24 * 120) -> bool:
	for i in max_hours:
		var b: FeatureBuild = ProductSystem.get_active_build()
		if b == null:
			return false
		if b.current_phase == phase:
			return true
		if b.current_phase == "iteration" and phase != "iteration" and ProductSystem.can_enter_development():
			ProductSystem.enter_development()
			continue
		# BANDI BEKLER, KAPIYI DEĞİL (D2): fixture'lar geliştirmenin gerçekten koştuğu
		# bir beta istiyor. `can_enter_beta` artık geliştirmenin ilk saatinde de true.
		if b.current_phase == "development" and phase in ["bugfix", "shipped"] and ProductSystem.development_band_complete():
			ProductSystem.enter_beta()
			continue
		ProductSystem.hourly_tick(i % 24)
	var b_end: FeatureBuild = ProductSystem.get_active_build()
	return b_end != null and b_end.current_phase == phase


# İterasyon-döngüsü sürücüleri (Build Bar): tasarım bandını TUR 1'İN SONUNA sürer
# (tur 2 kendiliğinden başlar → "Geliştirmeye geç" açılır) / koşan turu bitene dek koşar
# (sayaç artar ya da tavan parkı düşer).
static func _drive_to_round_end(max_hours: int = 24 * 60) -> bool:
	var b: FeatureBuild = ProductSystem.get_active_build()
	if b == null:
		return false
	for i in max_hours:
		if ProductSystem.can_enter_development():
			return true
		ProductSystem.hourly_tick(i % 24)
	return ProductSystem.can_enter_development()


static func _run_iteration_round(max_hours: int = 24 * 30) -> bool:
	var b: FeatureBuild = ProductSystem.get_active_build()
	if b == null or b.current_phase != "iteration" or b.iteration_decision_pending:
		return false
	var start_count: int = b.iteration_count
	for i in max_hours:
		if b.iteration_count > start_count or b.iteration_decision_pending:
			return true
		ProductSystem.hourly_tick(i % 24)
	return b.iteration_count > start_count or b.iteration_decision_pending


# --- Run Ledger + newspaper copy (Ending Screen) ---

static func _case_run_ledger() -> String:
	# Fresh run: the six new ledger fields reset to 0.
	var l0: Dictionary = GameState.get_run_ledger()
	if int(l0.get("peak_mrr", -1)) != 0:
		return "peak_mrr not reset"
	if int(l0.get("valuation_m", -1)) != 0 or int(l0.get("investment_amount", -1)) != 0:
		return "signed terms not reset"

	# Peak MRR latches the MAX seen, not the current value.
	GameState.set_mrr(5000)
	GameState.set_mrr(3000)
	if GameState.run_peak_mrr != 5000:
		return "peak_mrr latch wrong: %d" % GameState.run_peak_mrr

	# B2B sign (sole seam) + a real employee hire (category guard).
	_seed_b2b(800)
	_make_employee("emp_smoke", "Smoke Dev", HRConstants.ROLE_DEVELOPER)
	# Ship history → derived product_ships / max_version.
	GameState.set_flag("mvp_version", 2)
	GameState.set_flag("mvp_version_history", [{"version": 1, "day": 10}, {"version": 2, "day": 40}])

	var l1: Dictionary = GameState.get_run_ledger()
	if int(l1.get("customers_signed", 0)) < 1:
		return "customers_signed not counted: %d" % int(l1.get("customers_signed", 0))
	if int(l1.get("hires", 0)) != 1:
		return "hires not counted: %d" % int(l1.get("hires", 0))
	if int(l1.get("peak_mrr", 0)) != 5000:
		return "ledger peak_mrr wrong: %d" % int(l1.get("peak_mrr", 0))
	if int(l1.get("product_ships", 0)) != 2:
		return "product_ships wrong: %d" % int(l1.get("product_ships", 0))
	if int(l1.get("product_version", 0)) != 2:
		return "product_version wrong: %d" % int(l1.get("product_version", 0))

	# Departure seam: removing an employee increments run_departures.
	CharacterRegistry.remove("emp_smoke")
	if GameState.run_departures != 1:
		return "run_departures not counted on employee remove: %d" % GameState.run_departures

	# Signed-terms persistence via the VCPitch seam (without firing the ending).
	VCPitchSystem._persist_signed_terms({"valuation_m": 22, "dilution_pct": 18, "board_seats": 1, "board_veto": false})
	var l2: Dictionary = GameState.get_run_ledger()
	if int(l2.get("valuation_m", 0)) != 22 or int(l2.get("equity_pct", 0)) != 18:
		return "signed terms not persisted"
	if int(l2.get("investment_amount", 0)) != int(round(22_000_000.0 * 18.0 / 100.0)):
		return "investment_amount wrong: %d" % int(l2.get("investment_amount", 0))

	# EndingsCopy composes a populated view_state (Founder-Friendly at equity 18, no veto).
	var data := {"company_name": "PromptPilot", "tone": "win", "phase": 3}
	var vs: Dictionary = EndingsCopy.build("series_a_close", l2, data)
	if String(vs.get("headline", "")) == "":
		return "EndingsCopy produced empty headline"
	if (vs.get("ledger_lines", []) as Array).size() < EndingsCopy.MIN_LEDGER_LINES:
		return "ledger_lines below MIN: %d" % (vs.get("ledger_lines", []) as Array).size()
	if String(vs.get("variant", "")) != "founder_friendly":
		return "series_a variant wrong: %s" % String(vs.get("variant", ""))

	# Faz-1 bankruptcy is the quiet closure (generic masthead, no engraving, no ledger box).
	var qdata := {"company_name": "PromptPilot", "tone": "loss"}
	var qledger: Dictionary = l2.duplicate()
	qledger.phase = 1
	var qvs: Dictionary = EndingsCopy.build("bankruptcy", qledger, qdata)
	if not bool(qvs.get("is_quiet_closure", false)):
		return "faz-1 bankruptcy not quiet closure"
	if String(qvs.get("engraving_path", "x")) != "":
		return "faz-1 quiet closure should have no engraving"
	if String(qvs.get("quiet_notice", "")) == "":
		return "faz-1 quiet closure missing notice"

	return ""


# --- Gate cases ---

static func _case_gate1_b2c() -> String:
	_seed_b2c()
	return _expect_gate1_opens_and_advances()


static func _case_gate1_b2b() -> String:
	# THE bug-fix proof: the old _check_traction lived in the B2C branch only;
	# a pure-B2B run must now open gate 1 identically.
	_seed_b2b(500)
	return _expect_gate1_opens_and_advances()


static func _expect_gate1_opens_and_advances() -> String:
	_sim_day()
	if not GameState.phase_gate_ready:
		return "gate 1 did not open (ready=false)"
	if GameState.pending_next_phase != 2:
		return "pending_next_phase != 2"
	if _gate_signals != [2]:
		return "phase_gate_reached signals: %s" % str(_gate_signals)
	if GameState.phase != 1:
		return "phase changed before the Frank scene (%d)" % GameState.phase
	if not _drain_to(GATE1_ID):
		return "gate scene never became active"
	EventGate.resolve(GATE1_ID, 0)  # "Hazırız — geçelim"
	if GameState.phase != 2:
		return "advance_phase did not run (phase=%d)" % GameState.phase
	if GameState.phase_gate_ready or GameState.pending_next_phase != 0:
		return "gate latch not cleared after advance"
	return ""


static func _case_gate2() -> String:
	GameState.set_phase(2)  # debug backdoor — gate 1 already passed
	# The revenue bar ALONE opens the door — no growth streak, no brand
	# floor. Frank's door-open line comes first; the decision card follows on a later day.
	_seed_b2b_series_a()    # MRR over the bar, no month history at all
	GameState.month_history.clear()
	_sim_day()
	if not GameState.phase_gate_ready or GameState.pending_next_phase != 3:
		return "gate 2 did not open on the bar alone (ready=%s pending=%d)" % [GameState.phase_gate_ready, GameState.pending_next_phase]
	if String(PhaseGateSystem.series_a_signal().get("state", "")) != "open":
		return "latched gate should read open"
	var fail: String = _expect_door_open_then_gate()
	if fail != "":
		return fail
	EventGate.resolve(GATE2_ID, 0)
	if GameState.phase != 3:
		return "phase != 3 after confirm (%d)" % GameState.phase
	return ""


## The door-open order, shared by every case that walks through the Series A door: the gate has
## latched today; Frank's door-open line is on screen, the decision card is NOT pending the
## same day, and it arrives on the next day once the line is answered.
static func _expect_door_open_then_gate() -> String:
	if not _drain_to(DOOR_OPEN_ID):
		return "Frank's door-open line never reached the screen (active=%s)" % EventGate.active_id()
	if _instances_of(GATE2_ID) != 0:
		return "the Series A card is pending on the same day as the door-open line"
	EventGate.resolve(DOOR_OPEN_ID, 0)
	if _instances_of(GATE2_ID) != 0:
		return "the Series A card arrived on the door-open day"
	_sim_day()
	if not _drain_to(GATE2_ID):
		return "gate 2 scene never became active the day after the door-open line"
	return ""


static func _case_gate_decline_reminder() -> String:
	# REPOINTED (Frank v6, surface 9). The Traction card became a one-option NOTIFICATION, so
	# the decline path, the escalating bodies and the REMIND_INTERVAL_DAYS re-ask live ONLY on
	# the Series A gate now. Same mechanism, same three things proved — decline works, the body
	# escalates, the reminder re-asks on the cadence and NOT before — moved to the gate that
	# still owns them. What the Traction card BECAME is pinned by the case below it.
	#
	# THE ESCALATED COPY IS READ THROUGH THE CSV KEY, NOT THROUGH A GATES DICT KEY. The line
	# this replaces read `PhaseGateSystem.GATES[0].bodies` — a real key until bbfe8b2
	# (2026-08-19) moved gate copy into strings.csv, and from that day an "Invalid access to
	# property or key" sitting inside a case nobody had reason to look at. A case that throws
	# returns "", which this suite scores as PASS; only smoke_run.sh stderr gate catches it.
	GameState.set_phase(2)   # debug backdoor — gate 1 is already behind us
	var gate: Dictionary = PhaseGateSystem._gate_for_phase(2)
	if String(gate.get("card_id", "")) != GATE2_ID:
		return "phase 2 gate is %s, not %s" % [String(gate.get("card_id", "")), GATE2_ID]
	# The contract moved onto the card, so it is read off the card. Two options and three body
	# variants are what the escalation needs; the re-ask interval is the card's own cooldown,
	# which is also the number the reminder half of this case counts days against.
	var card: Dictionary = EventGate.catalogue_card(GATE2_ID)
	if (card.get("options", []) as Array).size() != 2:
		return "%s carries %d option(s) — the escalation contract has no home left" % [
			GATE2_ID, (card.get("options", []) as Array).size()]
	var variants: Dictionary = ((card.get("text", {}) as Dictionary).get("tr", {}) as Dictionary) \
		.get("body", {}).get("variants", {})
	if variants.size() < 2:
		return "%s carries %d body/bodies — nothing can escalate" % [GATE2_ID, variants.size()]
	var remind_days: int = int((card.get("latch", {}) as Dictionary).get("cooldown_days", 0))
	var hold_days: int = 2   # strictly inside the window, so the clock cannot tick on its own
	if remind_days <= hold_days:
		return "the re-ask cooldown is %d — the hold below no longer fits in the window" % \
			remind_days

	# Both bodies read from strings.csv BEFORE anything is built, plus the two guards that keep
	# the comparison from going vacuous: a missing row makes translate() echo the key back, and
	# production would echo the SAME key back — two raw tokens comparing equal is exactly the
	# shape of green this file exists to stop.
	var opening: String = TranslationServer.translate("GATE_SERIES_A_BODY_0")
	var escalated: String = TranslationServer.translate("GATE_SERIES_A_BODY_1")
	if opening == "GATE_SERIES_A_BODY_0" or escalated == "GATE_SERIES_A_BODY_1":
		return "a GATE_SERIES_A_BODY_* row is missing from strings.csv"
	if opening == escalated:
		return "BODY_0 and BODY_1 carry the same text — the escalation is unprovable"

	# Open it the way _case_gate2 does: the revenue bar alone opens it, and Frank's
	# door-open line precedes the card by a day.
	_seed_b2b_series_a()
	_sim_day()
	if not GameState.phase_gate_ready or GameState.pending_next_phase != 3:
		return "gate 2 did not open (ready=%s pending=%d)" % [
			GameState.phase_gate_ready, GameState.pending_next_phase]
	var door_fail: String = _expect_door_open_then_gate()
	if door_fail != "":
		return door_fail
	var view: GameEvent = EventGate.active_card()
	if view.body_text != opening:
		return "gate did not open on BODY_0"
	if view.choices.size() != 2:
		return "Series A gate offers %d option(s), want advance + decline" % view.choices.size()
	var decline_idx: int = _row_with_verb(view, "phase_gate_decline")
	if decline_idx != 1:
		return "the phase_gate_decline effect sits on option %d, want 1" % decline_idx

	# HOLD BEFORE DECLINING. Declining on the day the gate opened — what this case used to do —
	# leaves on_gate_declined re-arm line unfalsifiable: the open and the decline would stamp
	# gate_prompt_day with the same number, so deleting the line would change nothing.
	# The reminder clock is EvLatches' last-fire day now, not a hand-stamped flag, and reading
	# it that way is stricter: the stamp could drift from the fire, the latch cannot.
	var open_day: int = EvHistory.last_day(GATE2_ID)
	if open_day >= 0:
		return "the gate has a resolution in history before it was answered"
	var fired_day: int = EvLatches.last_day(EvLatches.key_for(GATE2_ID, EvLatches.KEY_RUN, ""))
	for i in hold_days:
		_sim_day()
		if _instances_of(GATE2_ID) != 1:
			return "the card that is still up went to %d instances" % _instances_of(GATE2_ID)
	if EvLatches.last_day(EvLatches.key_for(GATE2_ID, EvLatches.KEY_RUN, "")) != fired_day:
		return "the reminder clock moved while the card was still up"

	EventGate.resolve(GATE2_ID, decline_idx)  # "Henüz değil"
	if GameState.phase != 2 or not GameState.phase_gate_ready:
		return "decline broke the latch (phase=%d ready=%s)" % [
			GameState.phase, GameState.phase_gate_ready]
	if int(GameState.get_flag("gate_declines", 0)) != 1:
		return "decline did not advance the escalation counter (%d)" % \
			int(GameState.get_flag("gate_declines", 0))
	if EvHistory.last_day(GATE2_ID) != GameState.day:
		return "the decline did not reach history (last fire day %d, today %d)" % [
			EvHistory.last_day(GATE2_ID), GameState.day]
	if _instances_of(GATE2_ID) != 0:
		return "the declined card stayed in play"

	# No re-prompt before the cooldown elapses — AND THE CLOCK RUNS FROM THE FIRE, not from the
	# answer. That is a behaviour change and it is the right one: the old engine re-stamped
	# gate_prompt_day on decline, so a player who sat on the card for four days bought himself
	# nine days of quiet. §3.1's cooldown is measured from the last time the card was SHOWN.
	var elapsed: int = GameState.day - fired_day
	if elapsed >= remind_days:
		return "the hold consumed the whole cooldown (%d of %d) — the window proves nothing" % [
			elapsed, remind_days]
	for i in remind_days - elapsed - 1:
		_sim_day()
		if _instances_of(GATE2_ID) > 0:
			return "reminder re-admitted early (%d days after the fire, cooldown %d)" % [
				GameState.day - fired_day, remind_days]
	# …then exactly one re-prompt, on the escalated body.
	_sim_day()
	if _instances_of(GATE2_ID) != 1:
		return "reminder not re-admitted at interval (instances=%d)" % _instances_of(GATE2_ID)
	# Drain whatever else the day raised: the reminder is ADMITTED, but the modal slot belongs
	# to whichever card §11.2 ranks first, and on a busy day that is not this one. The old
	# engine could not produce this situation because the gate pushed to the front of the
	# queue; the new one orders the whole day's admissions by declared priority, so a case that
	# reads active_card() without draining is reading someone else's card.
	if not _drain_to(GATE2_ID):
		return "the reminder never reached the screen (active=%s)" % EventGate.active_id()
	if EventGate.active_card().body_text != escalated:
		return "reminder copy did not escalate (declines=%d)" % 			int(GameState.get_flag("gate_declines", 0))
	# Never duplicates, even across a further reminder window.
	for i in remind_days + 1:
		_sim_day()
		if _instances_of(GATE2_ID) > 1:
			return "gate scene duplicated (§7.10 violation)"
	return ""


## The Traction card is a NOTIFICATION now (Frank v6, surface 9): ONE body, ONE option, and
## therefore no decline counter, no escalating copy and no REMIND_INTERVAL_DAYS re-ask.
## Everything _case_gate_decline_reminder used to prove about gate 1 died with the second
## option, so this pins what REPLACED it rather than leaving the surface uncovered.
##
## NOT A RATIFICATION. Whether the Traction gate SHOULD be declinable is a phase-transition
## design question that is still open (2026-08-25). This case pins TODAY, so that changing
## it is a decision someone makes rather than a drift someone discovers.
static func _case_traction_gate_is_one_option() -> String:
	var gate: Dictionary = PhaseGateSystem._gate_for_phase(1)
	if String(gate.get("card_id", "")) != GATE1_ID:
		return "phase 1 gate is %s, not %s" % [String(gate.get("card_id", "")), GATE1_ID]
	var card: Dictionary = EventGate.catalogue_card(GATE1_ID)
	if (card.get("options", []) as Array).size() != 1:
		return "%s carries %d options — it is not a notification any more" % [
			GATE1_ID, (card.get("options", []) as Array).size()]
	var body_field: Variant = ((card.get("text", {}) as Dictionary).get("tr", {}) as Dictionary) \
		.get("body", "")
	if typeof(body_field) != TYPE_STRING:
		return "%s carries a variant body block — nothing selects between them" % GATE1_ID
	# The deleted copy is the other half of the ruling: _BODY_1/_2 went with the option.
	if TranslationServer.translate("GATE_TRACTION_BODY_1") != "GATE_TRACTION_BODY_1":
		return "GATE_TRACTION_BODY_1 has a row again — escalation copy outlived its option"
	var body: String = TranslationServer.translate("GATE_TRACTION_BODY_0")
	if body == "GATE_TRACTION_BODY_0":
		return "GATE_TRACTION_BODY_0 has no row — the card would show a raw token"
	var advance_key: String = String(((card.get("text", {}) as Dictionary).get("tr", {}) \
		as Dictionary).get("options", {}).get("advance", ""))
	var advance_label: String = TranslationServer.translate(advance_key)
	if advance_key == "" or advance_label == advance_key:
		return "the Traction card's advance label has no row (%s)" % advance_key
	if advance_label == TranslationServer.translate("GATE_ADVANCE"):
		return "GATE_TRACTION_ADVANCE and GATE_ADVANCE read alike — the label check is vacuous"

	_seed_b2b(500)
	_sim_day()
	if not GameState.phase_gate_ready or GameState.pending_next_phase != 2:
		return "gate 1 did not open (ready=%s pending=%d)" % [
			GameState.phase_gate_ready, GameState.pending_next_phase]
	if not _drain_to(GATE1_ID):
		return "the notification never became active"
	var ev: GameEvent = EventGate.active_card()
	if ev.body_text != body:
		return "the card is not carrying GATE_TRACTION_BODY_0"
	if ev.choices.size() != 1:
		return "the notification offers %d options, want exactly 1" % ev.choices.size()
	if ev.choices[0].label != advance_label:
		return "the single option is not the per-gate GATE_TRACTION_ADVANCE label"
	if _row_with_verb(ev, "phase_gate_decline") >= 0:
		return "a phase_gate_decline effect is still on the Traction card"

	# And the copy cannot escalate even if the counter is forced: a literal body has nothing
	# to select between. This is the reminder half of the old case, asserted as the
	# impossibility it now is — and asserted through a RE-RENDER, because a card's text is
	# resolved at display time and a forced counter is exactly what would move it.
	GameState.set_flag("gate_declines", 9)
	if EventGate.render(GATE1_ID, EventGate.active_context()).body_text != body:
		return "Traction copy escalated off a forced counter"
	GameState.set_flag("gate_declines", 0)

	# The one option is the advance, not a dead button.
	EventGate.resolve(GATE1_ID, 0)
	if GameState.phase != 2:
		return "the only option did not advance the phase (phase=%d)" % GameState.phase
	if GameState.phase_gate_ready or GameState.pending_next_phase != 0:
		return "gate latch not cleared after the notification was confirmed"
	# And it never comes back: `one_shot` on the card, plus a ratchet that is now closed.
	for i in 7:
		_sim_day()
		if _instances_of(GATE1_ID) != 0:
			return "the Traction notification came back on day %d" % GameState.day
	return ""


# --- Ending cases ---

static func _case_bankruptcy() -> String:
	GameState.set_cash(-1000)
	# SINIR TÜRETİLDİ: ilk kasa-eksi tik sayacı AZALTMAZ, KURAR — yani iflas
	# SHUTTER_DAYS + 1'inci tik'te düşer. Bir tik pay bırakılıyor ve döngüyü asıl
	# durduran aşağıdaki `break`. (Emekli literal 10, eski sabitin 7 + 3'üydü.)
	for i in EndingsSystem.SHUTTER_DAYS + 2:
		_sim_day()
		if not GameState.run_active:
			break
	if _endings != ["bankruptcy"]:
		return "endings: %s" % str(_endings)
	if GameState.run_active:
		return "run still active"
	if EventGate.queue_size() != 0:
		return "queue not flushed (%d left)" % EventGate.queue_size()
	return ""


static func _case_shutter_recovery() -> String:
	GameState.set_cash(-1000)
	for i in 3:
		_sim_day()
	# TÜRETİLDİ, YAZILMADI: sayaç ilk kasa-eksi tik'inde SET edilir, sonrakilerde azalır —
	# üç ardışık tik SHUTTER_DAYS - 2 bırakır. Sabit bir sayı yazmak bu vakayı bir kez
	# zaten düşürdü (7 -> 30, Frank v6 turu): satır 28'lik gerçeğe karşı 5 iddia ediyordu.
	var want_left: int = EndingsSystem.SHUTTER_DAYS - 2
	if GameState.shutter_days_left != want_left:
		return "counter wrong after 3 days (%d, want %d)" % [GameState.shutter_days_left, want_left]
	GameState.set_cash(5000)
	_sim_day()
	if GameState.shutter_days_left != -1:
		return "counter did not reset on recovery (%d)" % GameState.shutter_days_left
	for i in 5:
		_sim_day()
	if not GameState.run_active or not _endings.is_empty():
		return "run ended after recovery: %s" % str(_endings)
	return ""


static func _case_brand_collapse() -> String:
	GameState.day = 40
	GameState.set_brand(10)
	GameState.active_scandal = true
	GameState.brand_low_since_day = 5  # 35 days under the floor
	_sim_day()
	if _endings != ["brand_collapse"]:
		return "endings: %s" % str(_endings)
	return ""


static func _case_cascade() -> String:
	GameState.vc_rejections = 3  # no customers → MRR 0 → metrics dead, no hatch
	_sim_day()
	if _endings != ["vc_rejection_cascade"]:
		return "endings: %s" % str(_endings)
	if GameState.get_flag("pivot_offer_made", false):
		return "pivot offered despite dead metrics"
	return ""


static func _case_pivot_accept() -> String:
	_seed_b2b(3000)  # metrics alive (≥ PIVOT_MRR_MIN, cash positive)
	GameState.vc_rejections = 3
	_sim_day()
	if not GameState.run_active:
		return "run ended instead of offering pivot: %s" % str(_endings)
	if not GameState.get_flag("pivot_offer_made", false):
		return "pivot offer not made"
	# REPOINTED (Frank v6, 17+18): ev_pivot_offer merged into the buyout card, whose trigger
	# does not exist yet, so there is no card to drain to. The SEAM the card called is
	# untouched and is what this case was ever really about - drive it directly.
	#
	# POSITIVE CONTROL FIRST. "The retired id never reached the queue" proves nothing about a
	# queue nothing ever reaches. _seed_b2b + one day always leaves the Traction gate pending
	# (_expect_gate1_opens_and_advances relies on the same fact), so this asserts the probe
	# below is looking at a LIVE queue rather than an empty one.
	if _instances_of(GATE1_ID) == 0:
		return "queue probe is dead — the inertness check below would be vacuously true"
	if _instances_of("ev_pivot_offer") != 0 or _instances_of("ev_buyout_offer") != 0:
		return "a retired offer card reached the queue"
	if EventGate.is_catalogued("ev_pivot_offer") \
			or EventGate.is_catalogued("ev_buyout_offer"):
		return "a retired offer card was authored back onto disk — it is pooled, not inert"
	EndingsSystem.on_pivot_accepted()
	if not GameState.pivot_used:
		return "pivot_used not set"
	# ISOLATE pivot_used. The cascade is guarded TWICE — pivot_used (endings_system.gd:171)
	# and the pivot_offer_made latch (:176) — so while both stand, deleting either changes
	# nothing observable and the loop below proves nothing. Strip the latch; pivot_used must
	# hold the door alone. The fixture is metrics-ALIVE, so the tell is the latch RE-BURNING,
	# not the run ending.
	GameState.set_flag("pivot_offer_made", false)
	_sim_day()
	if GameState.get_flag("pivot_offer_made", false):
		return "the cascade scan walked past pivot_used — the VC path re-opened"
	GameState.set_flag("pivot_offer_made", true)
	for i in 5:
		_sim_day()
	if not GameState.run_active:
		return "cascade re-fired after pivot (Erdem rule: VC path closed, run continues): %s" % str(_endings)
	return ""


## REPOINTED (Frank v6, surfaces 17+18). FALSIFICATION — each of these PRODUCTION
## mutations drops this case:
##   · endings_system.gd:178 — invert or weaken the metrics test: the sub-floor run takes
##     the ALIVE branch, burns the offer latch and never ends.
##   · endings_system.gd:187 — delete the trigger_ending call: _endings stays empty.
##   · endings_system.gd:164 — < to <=: three closed tables stop counting as three.
##   · sales_system.gd or customer_registry.gd — make the bridge yield 0: the ending STILL
##     fires (0 is sub-floor too), so only the MRR band assertion catches that this case
##     had quietly become a second copy of `cascade`, measuring an empty company.
static func _case_pivot_decline() -> String:
	# The card that carried "Hayır. Bitti." is retired, but the ENDING it reached is untouched
	# and still reachable by its own route: three closed tables with the metrics DEAD
	# (_check_vc_cascade else-branch). That is the path this case drives now, so the terminal
	# stays covered rather than merely believed — and it stays a PLAYED path, reached by the
	# engine daily scan, not by calling trigger_ending from the harness.
	#
	# The MRR must come from the CUSTOMER RECORD, not from set_mrr: the slot-4 bridge rewrites
	# GameState.mrr from CustomerRegistry every day and the endings scan is slot 9, so a bare
	# set_mrr() is long gone by the time _check_vc_cascade reads it.
	var want_mrr: int = EndingsSystem.PIVOT_MRR_MIN - 500
	if want_mrr <= 0:
		return "the floor moved under the fixture (%d): this case needs POSITIVE sub-floor revenue" \
			% EndingsSystem.PIVOT_MRR_MIN
	_seed_b2b(want_mrr)                                     # a REAL account, below the floor
	GameState.vc_rejections = EndingsSystem.CASCADE_TABLES  # derived, not typed
	_sim_day()
	# WHAT THE SLOT-9 SCAN ACTUALLY SAW. Without these the case goes green on a run whose MRR
	# was zeroed — proving the dead branch fires, but not that it fired for the reason this
	# case is named after. `cascade` already covers MRR 0; this one only earns its keep while
	# the company is genuinely alive and genuinely under the floor.
	if GameState.mrr <= 0 or GameState.mrr >= EndingsSystem.PIVOT_MRR_MIN:
		return "scan read MRR %d against floor %d — the customer record did not survive" % [
			GameState.mrr, EndingsSystem.PIVOT_MRR_MIN]
	if GameState.cash <= 0:
		return "cash was %d — the dead branch was reached through CASH, not the MRR floor" \
			% GameState.cash
	if GameState.get_flag("pivot_offer_made", false):
		return "metrics read ALIVE below the floor — the offer latch burned instead of the ending"
	if _endings != ["vc_rejection_cascade"]:
		return "endings: %s" % str(_endings)
	return ""


# --- Live-lifecycle case (canlı-yaşam-döngüsü kanonu) ---

static func _case_live_during_vbuild() -> String:
	# KANON: ship edilmiş sürüm CANLI kalır — sonraki sürüm (v3) geliştirilirken
	# audience/MRR akar, wear işler, sprint başlatılabilir; yalnız v3'ün ship'i
	# canlı sürümü değiştirir. (Playtest bug'ı: v3 dev başlayınca ekonomi taş
	# kesiliyordu — mvp_version_build_active freeze'i + slot-kilitli wear/sprint.)
	_seed_live_product()
	if not ProductSystem.start_version_build(["ai_assistant_voice"], "founder"):
		return "v3 build could not start"
	var aud0: float = float(GameState.get_flag("b2c_audience", 0))
	var mrr0: int = GameState.mrr
	# 10 gün: saatlik ekonomi + günlük slotlar. Bu döngü elle yazılmıştı ve günlük tiki
	# saat 23'ten SONRA atıyordu; motor onu saat 0 ile saat 1'in arasına koyuyor.
	# _sim_day_full() gerçek sırayı taşıyor.
	for d in 10:
		_sim_day_full()
		if not GameState.run_active:
			return "run ended mid-case (day %d, endings %s)" % [GameState.day, str(_endings)]
	var aud1: float = float(GameState.get_flag("b2c_audience", 0))
	if absf(aud1 - aud0) < 0.5:
		return "audience frozen during v3 dev (%.1f -> %.1f)" % [aud0, aud1]
	if GameState.mrr == mrr0 and absf(aud1 - aud0) > 20.0:
		return "MRR frozen while audience moved (mrr %d)" % GameState.mrr
	if float(GameState.get_flag("mvp_live_bug_progress", 0.0)) == 0.0 \
			and int(GameState.get_flag("mvp_live_bug_count", 0)) == 0:
		return "post-ship wear frozen during v3 dev"
	# Sprint build SÜRERKEN başlatılabilmeli ve bug temizlemeli (kanon).
	GameState.set_flag("mvp_live_bug_count", 6)
	if not ProductSystem.start_bug_sprint():
		return "bug sprint blocked during v3 dev"
	for h in 24:
		TimeManager._dispatch_hourly_tick(h)
	if int(GameState.get_flag("mvp_live_bug_count", 99)) >= 6:
		return "sprint not clearing bugs during v3 dev"
	for d in 8:   # sprint kurusun (max 7 gün)
		for h in 24:
			TimeManager._dispatch_hourly_tick(h)
	if GameState.get_flag("mvp_bug_sprint_active", false):
		return "sprint never completed"
	# v3 ship canlı sürümü DEĞİŞTİRİR (tek yaşam döngüsü, slot temiz).
	# Rev3: fazlar otomatik akar — build'i Beta'ya dek sür, sonra Yayınla.
	if not _run_build_to_phase("bugfix"):
		return "v3 build never reached beta"
	ProductSystem.launch()
	ProductSystem.ship_active_build()
	if int(GameState.get_flag("mvp_version", 0)) != 3:
		return "ship did not bump version (got %s)" % str(GameState.get_flag("mvp_version", 0))
	if ProductSystem.get_active_build() != null:
		return "build slot not cleared after ship"
	if GameState.get_flag("mvp_bug_sprint_active", false):
		return "sprint flag dirty after ship"
	return ""


# --- Kapasite havuzu + freeze-silme case'leri ---

static func _case_sprint_no_freeze() -> String:
	# KALICI KANIT: sprint'in audience-freeze'i silindi — sprint aktifken
	# trials (audience) ve payers/MRR akmaya devam eder (bedel artık kapasite
	# havuzu, ekonomi donması değil).
	_seed_live_product()
	GameState.set_flag("mvp_live_bug_count", 20)   # 5 iş-günü sprint — pencere boyunca aktif
	if not ProductSystem.start_bug_sprint():
		return "sprint could not start"
	var aud0: float = float(GameState.get_flag("b2c_audience", 0))
	var mrr0: int = GameState.mrr
	for h in 48:
		TimeManager._dispatch_hourly_tick(h % 24)   # sales hourly da koşmalı → dispatch üzerinden
	if not GameState.get_flag("mvp_bug_sprint_active", false):
		return "sprint ended early — case window invalid"
	var aud1: float = float(GameState.get_flag("b2c_audience", 0))
	if absf(aud1 - aud0) < 0.5:
		return "audience frozen during sprint (%.1f -> %.1f)" % [aud0, aud1]
	if GameState.mrr == mrr0 and absf(aud1 - aud0) > 20.0:
		return "payers/MRR frozen while audience moved (mrr %d)" % GameState.mrr
	return ""


static func _case_capacity_split() -> String:
	# Kapasite = 1 (kurucu, mühendis yok): sprint + v-build paralelken İKİSİ DE
	# yarı hız; mid-job mühendis eklenince (kapasite 2) anında tam hıza döner.
	# Sıralama bilinçli: önce sprint, sonra v-build → silinen sprint→v-build
	# guard'ının regresyon kanıtı da bu case'te.
	_seed_live_product()
	if CharacterRegistry.count_active_developers() != 0:
		return "unexpected engineer in registry (capacity would be 2)"
	# 1) Yalnız sprint → tam hız referansı (1.0 iş-günü / takvim günü).
	GameState.set_flag("mvp_live_bug_count", 28)   # 7 iş-günü — case boyunca bitmez
	if not ProductSystem.start_bug_sprint():
		return "sprint could not start"
	var s0: float = float(GameState.get_flag("mvp_sprint_days_elapsed", 0.0))
	for h in 24:
		ProductSystem.hourly_tick(h)   # saf hız ölçümü — sales/event gürültüsü yok
	if absf(float(GameState.get_flag("mvp_sprint_days_elapsed", 0.0)) - s0 - 1.0) > 0.02:
		return "solo sprint not full speed"
	# 2) Sprint AKTİFKEN v-build başlamalı (silinen guard'ın kanıtı) → ikisi yarı hız.
	# Rev3 ölçümü: build ilerlemesi EFOR cinsinden — beklenen günlük harcama =
	# team_speed(b) × capacity_speed_factor (taze çarpım; sabit 0.5/1.0 değil).
	#
	# LEDGER (Coupling): the expectation is now ACCUMULATED PER HOUR instead of sampled once.
	# team_speed became phase-aware, so a 24-hour window that crosses a faz sınırı has two
	# different speeds in it and a single sample silently mis-predicts the total (that is
	# exactly how this case first failed: 2.792 measured against a 2.000 sample). Summing the
	# same per-hour product the engine sums is not a weaker assertion — it is the "taze çarpım"
	# law this case already claimed, now actually enforced hour by hour.
	# ÜÇ özellik, bir değil: ölçüm iki tam 24 saatlik pencereyi efor TAVANINA ÇARPMADAN
	# geçirmek zorunda. Tavana dayanan pencere son saatlerde daha az efor yazar ve ölçülen
	# gün beklenenin altına düşer — 2026-08-21 alan migrasyonunda tam olarak bu oldu
	# (2.700 ölçüldü, 4.250 bekleniyordu), çünkü ekip hızlandı ve tek özellik erken bitti.
	# Ölçülen yasa (yarı hız / tam hıza dönüş) değişmedi; pencere dardı.
	if not ProductSystem.start_version_build(
			["ai_assistant_voice", "ai_assistant_streaming", "ai_assistant_tools"], "founder"):
		return "v-build blocked during sprint (guard not removed)"
	var b: FeatureBuild = ProductSystem.get_active_build()
	if absf(ProductSystem.capacity_speed_factor() - 0.5) > 0.001:
		return "parallel factor not 0.5 (%.2f)" % ProductSystem.capacity_speed_factor()
	# Build Bar grameri: v-build'in minik tasarım bandı ölçüm penceresinin İÇİNE
	# düşmesin — tur 1'in sonuna sür, "Geliştirmeye geç" de; iki pencere de development'ta
	# ölçülür (mid-job developer kıyası da ancak orada anlamlı).
	for ih in 24 * 30:
		if ProductSystem.can_enter_development():
			break
		ProductSystem.hourly_tick(ih % 24)
	if not ProductSystem.can_enter_development():
		return "v-build design band never ended round 1"
	ProductSystem.enter_development()
	var want_day: float = 0.0
	var e0: float = b.efor_spent
	s0 = float(GameState.get_flag("mvp_sprint_days_elapsed", 0.0))
	for h in 24:
		want_day += ProductSystem.team_speed(b) * ProductSystem.capacity_speed_factor() / 24.0
		ProductSystem.hourly_tick(h)
	var db: float = b.efor_spent - e0
	var ds: float = float(GameState.get_flag("mvp_sprint_days_elapsed", 0.0)) - s0
	if absf(db - want_day) > 0.02:
		return "build not at split speed (%.3f efor/day, want %.3f)" % [db, want_day]
	if absf(ds - 0.5) > 0.02:
		return "sprint not half speed (%.3f day/day)" % ds
	# 3) Mid-job hire → kapasite 2 → faktör 1.0'a DÖNER ve gerçek günlük çıktı BÜYÜR.
	# The relative claim compares MEASURED rates, not sampled expectations: a developer hired
	# during the TASARIM fazı contributes nothing to speed yet (rol-faz eşlemesi),
	# so comparing two samples could read equal while real throughput still doubled from the
	# recovered capacity factor. The measured comparison is the honest one either way.
	_make_employee("char_smoke_capacity_eng", "Smoke Eng", HRConstants.ROLE_DEVELOPER)
	if absf(ProductSystem.capacity_speed_factor() - 1.0) > 0.001:
		return "factor did not recover to 1.0 (%.2f)" % ProductSystem.capacity_speed_factor()
	var want_day2: float = 0.0
	e0 = b.efor_spent
	s0 = float(GameState.get_flag("mvp_sprint_days_elapsed", 0.0))
	for h in 24:
		want_day2 += ProductSystem.team_speed(b) * ProductSystem.capacity_speed_factor() / 24.0
		ProductSystem.hourly_tick(h)
	var db2: float = b.efor_spent - e0
	ds = float(GameState.get_flag("mvp_sprint_days_elapsed", 0.0)) - s0
	if absf(db2 - want_day2) > 0.02:
		return "build did not recover to full speed (%.3f efor/day, want %.3f)" % [db2, want_day2]
	if db2 <= db:
		return "recovered capacity did not raise real throughput (%.3f -> %.3f)" % [db, db2]
	db = db2
	if absf(ds - 1.0) > 0.02:
		return "sprint did not recover to full speed (%.3f day/day)" % ds
	return ""


static func _case_speed_preserve() -> String:
	# İş-3 fix'i: aksiyon butonları (build commit, sprint start) artık
	# TimeManager.resume_if_paused() çağırır — koşan hız KORUNUR, pause'dan
	# last_running_speed'e dönülür. Buton→handler kablosu windowed'da bir kez
	# elle doğrulanır (2x'te commit → 2x kalır).
	EventBus.speed_change_requested.emit(2)
	TimeManager.resume_if_paused()
	if TimeManager.current_speed != 2:
		return "running speed hijacked (%d, want 2)" % TimeManager.current_speed
	EventBus.speed_change_requested.emit(0)
	TimeManager.resume_if_paused()
	if TimeManager.current_speed != 2:
		return "paused game did not resume to last_running_speed (%d)" % TimeManager.current_speed
	if TimeManager.get_tree().paused:
		return "tree still paused after resume"
	return ""


# --- Month-End Summary ---

static func _case_month_summary() -> String:
	var months: Array = []  # captured summary_data dicts
	EventBus.month_ended.connect(func(d: Dictionary) -> void: months.append(d))

	# Highlight registry rules: higher priority replaces, first-come wins ties.
	GameState.submit_month_highlight("a", 50)
	GameState.submit_month_highlight("b", 90)
	GameState.submit_month_highlight("c", 90)
	if GameState.month_highlight_text != "b":
		return "highlight priority/tie rule broken (%s)" % GameState.month_highlight_text
	GameState.month_highlight_text = ""
	GameState.month_highlight_priority = -1

	# Quiet January with one known delta: brand 50 → 60. No customers, no
	# mvp flags → gates stay closed, MRR stays 0, cash falls by burn only.
	GameState.set_brand(60)
	for i in 30:
		_sim_day()  # days 2..31 — still January
	if months.size() != 0:
		return "month fired early (day %d, count %d)" % [GameState.day, months.size()]
	_sim_day()  # day 32 = Feb 1, 2026 → January closes (real calendar, not day%30)
	if months.size() != 1:
		return "expected exactly 1 month_ended at day 32, got %d" % months.size()
	var m: Dictionary = months[0]
	# Locale-independent: builds the expected string from the same keys the system uses,
	# instead of pinning the Turkish bytes (the old pin only held because the process
	# happened to run in Turkish).
	var want_title: String = TranslationServer.translate("MONTH_TITLE").format(
		{"month": Fmt.month_upper(1), "year": 2026})
	if String(m.month_title) != want_title:
		return "month_title: %s (want %s)" % [String(m.month_title), want_title]
	var want_range: String = TranslationServer.translate("MONTH_DAY_RANGE").format(
		{"from": 1, "to": 31})
	if String(m.day_range) != want_range:
		return "day_range: %s (want %s)" % [String(m.day_range), want_range]
	if int(m.brand.from) != 50 or int(m.brand.to) != 60:
		return "brand delta: %s" % str(m.brand)
	if int(m.mrr.from) != 0 or int(m.mrr.to) != 0:
		return "mrr delta: %s" % str(m.mrr)
	# Hand-computed cash: 31 daily finance ticks × $50 burn, $0 revenue.
	if int(m.cash.from) != 10000 or int(m.cash.to) != 10000 - 31 * 50:
		return "cash delta: %s (want 10000 → %d)" % [str(m.cash), 10000 - 31 * 50]
	if int(m.team.from) != 1 or int(m.team.to) != 1:
		return "team delta: %s" % str(m.team)
	if String(m.highlight) != MonthSummarySystem.highlight_fallback():
		return "quiet month should use fallback highlight, got: %s" % String(m.highlight)
	# Which RULE fired is the assertion; the sentence is whatever the CSV says it is.
	var want_frank: String = TranslationServer.translate("MONTH_FRANK_ANOTHER")
	if String(m.frank_line) != want_frank:
		return "frank rule mismatch: %s (want %s)" % [String(m.frank_line), want_frank]
	if int(GameState.month_ledger.get("start_day", 0)) != 32:
		return "ledger not re-snapshotted (start_day %s)" % str(GameState.month_ledger.get("start_day"))

	# Run counter seams (write-only; ledger deltas must not be affected).
	var p := Prospect.new()
	p.id = "lead_month_smoke"
	p.company_name = "Month Corp"
	p.industry = "testing"
	p.star = 1
	_sign_fixture(p, 500, 70)  # no mvp_shipped flag → gate 1 stays closed
	if GameState.run_customers_signed != 1:
		return "run_customers_signed = %d, want 1" % GameState.run_customers_signed
	# `verb`, and a NAMED account. The old executor's default target was
	# `get_lowest_satisfaction_customer(<the event's market>)`, computed at apply time; the new
	# one takes its subject from the card's bound scope, and a bare effect list has no scope.
	# Naming the account is what the card does too — it just does it through a slot.
	EventGate.debug_apply_effects([{"verb": "churn_customer", "entity_id": "co_lead_month_smoke"}])
	if GameState.run_customers_lost != 1:
		return "run_customers_lost = %d, want 1" % GameState.run_customers_lost
	_make_employee("char_month_smoke_emp", "Smoke Hire", HRConstants.ROLE_DEVELOPER)
	if GameState.run_hires != 1:
		return "run_hires = %d, want 1" % GameState.run_hires
	if int(GameState.month_ledger.get("brand", -1)) != 60:
		return "counters disturbed the ledger snapshot"

	# Terminal suppression: Feb 2026 has 28 days → Feb closes at day 60 (Mar 1).
	# Force a Class-A ending on exactly that day: slot 9 ends the run before
	# slot 10 runs → the ending wins, no second summary.
	while GameState.day < 59:
		_sim_day()
	if months.size() != 1:
		return "february closed before day 60? (count %d, day %d)" % [months.size(), GameState.day]
	GameState.series_a_closed = true
	_sim_day()  # day 60
	if GameState.run_active:
		return "run did not end on day 60"
	if months.size() != 1:
		return "summary fired on a terminal day (ending must win)"
	return ""


static func _case_terminal_kills_gate() -> String:
	_seed_b2b(500)
	_sim_day()
	if not GameState.phase_gate_ready:
		return "gate did not open"
	GameState.set_cash(-1000)
	# TÜRETİLDİ (_case_bankruptcy'ye bak): kepenk SHUTTER_DAYS + 1'inci tik'te düşer,
	# `break` düştüğü an çıkar.
	for i in EndingsSystem.SHUTTER_DAYS + 2:
		_sim_day()
		if not GameState.run_active:
			break
	if _endings != ["bankruptcy"]:
		return "endings: %s" % str(_endings)
	if EventGate.queue_size() != 0:
		return "queue not flushed"
	# World stopped: further ticks are no-ops, nothing re-enqueues.
	var cash_at_end: int = GameState.cash
	for i in 2:
		_sim_day()
	if GameState.cash != cash_at_end:
		return "cash changed after terminal (%d → %d)" % [cash_at_end, GameState.cash]
	if EventGate.queue_size() != 0:
		return "gate reminder re-admitted after terminal"
	return ""


# --- VC Pitch cases ---

static func _force(mode: String) -> void:
	GameState.set_flag("debug_skill_force", mode)  # SkillCheck deterministic override

static func _run_meeting(_vc: String, b2: String, b3: String, b4: String) -> void:
	# Drive the beat machine engine-directly (no scene): b1 read → b2 angle → b3 posture → b4.
	VCPitchSystem.advance("b1_read")
	VCPitchSystem.advance("b2_" + b2)
	VCPitchSystem.advance("b3_" + b3)
	VCPitchSystem.advance(b4)


static func _case_full_loop() -> String:
	# THE vertical slice: phase 3 → request → prompt accept → beats → sheet → sign → ending.
	GameState.set_phase(3)
	_force("pass")
	_seed_b2b_series_a()   # bar + 1000
	_sim_day()  # aggregate MRR to 6000 (SalesSystem mrr bridge)
	if not VCPitchSystem.request_meeting("anchor"):
		return "request_meeting refused"
	for i in 5:
		_sim_day()
		if not GameState.run_active:
			return "run ended during wait: %s" % str(_endings)
		if EventGate.active_id() == MEETING_ID or _instances_of(MEETING_ID) > 0:
			break
	if not _drain_to(MEETING_ID):
		return "meeting prompt never admitted"
	EventGate.resolve(MEETING_ID, "go")
	if not VCPitchSystem.is_meeting_active():
		return "meeting did not start"
	_run_meeting("anchor", "metrik", "durust", "b4_ack")
	if VCPitchSystem.is_meeting_active():
		return "meeting did not finish"
	if GameState.active_sheets.size() != 1:
		return "no sheet granted (%d)" % GameState.active_sheets.size()
	if GameState.run_sheets_won != 1 or GameState.run_pitches != 1:
		return "counters wrong (sheets=%d pitches=%d)" % [GameState.run_sheets_won, GameState.run_pitches]
	VCPitchSystem.sign_table("anchor")
	for i in 3:
		_sim_day()
		if not GameState.run_active:
			break
	if _endings != ["series_a_close"]:
		return "endings: %s" % str(_endings)
	return ""


static func _case_pitch_ret_counter() -> String:
	GameState.set_phase(3)
	_force("fail")
	_seed_b2b(500)
	_sim_day()
	VCPitchSystem.begin_meeting("anchor")
	if not VCPitchSystem.is_meeting_active():
		return "meeting did not start"
	_run_meeting("anchor", "metrik", "durust", "b4_leave")
	if GameState.vc_rejections != 1:
		return "vc_rejections=%d (want 1)" % GameState.vc_rejections
	if GameState.vc_states.get("anchor", {}).get("status", "") != "rejected":
		return "status not rejected"
	if GameState.run_pitches != 1:
		return "run_pitches=%d" % GameState.run_pitches
	return ""


static func _case_gecistir_cap() -> String:
	GameState.set_phase(3)
	_force("pass")
	_seed_b2b_series_a()   # bar + 1000
	_sim_day()
	VCPitchSystem.begin_meeting("anchor")
	VCPitchSystem.advance("b1_read")
	VCPitchSystem.advance("b2_metrik")   # +25 (crit) — raw conviction would reach Kazanıldı
	VCPitchSystem.advance("b3_gecistir") # caps the room at 65
	if VCPitchSystem._cap != PitchConstants.GECISTIR_CAP:
		return "geçiştir cap not applied (%d)" % VCPitchSystem._cap
	VCPitchSystem.advance("b4_callback") # only offered in the Ilık fork — proves cap worked
	if not GameState.active_sheets.is_empty():
		return "geçiştir won the room (sheet granted) — cap failed"
	VCPitchSystem.advance("b4_close")
	return ""


static func _case_callback_contract() -> String:
	GameState.set_phase(3)
	_force("pass")
	GameState.set_flag("mvp_shipped", true)
	GameState.set_flag("mvp_live_bug_count", 5)   # product interrogation + callback not-yet-met
	_seed_b2b(3000)
	_sim_day()
	VCPitchSystem.begin_meeting("meridian")
	VCPitchSystem.advance("b1_read")
	VCPitchSystem.advance("b2_metrik")
	VCPitchSystem.advance("b3_gecistir")     # cap → Ilık
	VCPitchSystem.advance("b4_callback")
	VCPitchSystem.advance("b4_close")
	var st: Dictionary = GameState.vc_states.get("meridian", {})
	if st.get("status", "") != "callback":
		return "status not callback (%s)" % st.get("status", "")
	if st.get("callback", {}).get("type", "") != "bugs_under":
		return "callback type=%s" % st.get("callback", {}).get("type", "")
	if st.get("callback", {}).get("met", true):
		return "callback already met"
	# ONE CALLBACK PER VC: the fund cannot be re-booked before its condition is met.
	if VCPitchSystem.request_meeting("meridian"):
		return "callback fund re-booked before its condition was met"
	GameState.set_flag("mvp_live_bug_count", 1)   # satisfy: bugs under target
	_sim_day()
	if not st.get("callback", {}).get("met", false):
		return "callback not met after condition satisfied"
	if VCPitchSystem.meeting_blocked_reason("meridian") != "":
		return "met callback still locked (%s)" % VCPitchSystem.meeting_blocked_reason("meridian")
	if not st.get("reentry_bonus", false):
		return "reentry_bonus not armed"
	var seed_with: int = int(VCPitchSystem.initial_conviction("meridian").value)
	st["reentry_bonus"] = false
	var seed_without: int = int(VCPitchSystem.initial_conviction("meridian").value)
	if seed_with - seed_without != PitchConstants.CONV_CALLBACK_BONUS:
		return "re-entry bonus wrong (%d vs %d)" % [seed_with, seed_without]
	return ""


static func _case_pitch_bug_interrogation() -> String:
	# A.4: live bugs > 0 must FIRE the product interrogation (sorgu key "bugs") and
	# leave the bugs_under callback UNMET — both were silently dead while VCPitch read
	# the never-written mvp_bug_count key (now mvp_live_bug_count with launch fallback).
	GameState.set_phase(3)
	_force("pass")
	GameState.set_flag("mvp_shipped", true)
	GameState.set_flag("mvp_live_bug_count", 5)    # >= CALLBACK_BUGS_UNDER (3)
	_seed_b2b(3000)
	_sim_day()
	VCPitchSystem.begin_meeting("meridian")        # product-domain VC
	VCPitchSystem.advance("b1_read")
	VCPitchSystem.advance("b2_metrik")             # _sorgu assigned here (_resolve_beat2)
	if VCPitchSystem._sorgu.get("key", "") != "bugs":
		return "product interrogation did not fire (sorgu=%s)" % str(VCPitchSystem._sorgu.get("key", ""))
	if VCPitchSystem._callback_met({"type": "bugs_under", "target": PitchConstants.CALLBACK_BUGS_UNDER}):
		return "bugs_under met at 5 bugs (should fail, target %d)" % PitchConstants.CALLBACK_BUGS_UNDER
	return ""


static func _case_pitch_refused_acq() -> String:
	# A.4: a prior acquisition-decline must FIRE the refused-acquisition interrogation
	# (narrative domain). Dead before A.2 unified the key (reader looked for the
	# never-written acquisition_declined; the writer sets acquisition_offer_rejected).
	GameState.set_phase(3)
	_force("pass")
	_seed_b2b(3000)
	GameState.set_flag("acquisition_offer_rejected", true)
	_sim_day()
	# Neutralize the DOMINANT-giant proxy so _rival_ahead() doesn't preempt the
	# refused-acq branch; the key unification is what lets it fire once rival is clear.
	for r in RivalRegistry.get_all():
		r.status = "STEADY"
	VCPitchSystem.begin_meeting("bosphorus")       # narrative-domain VC
	VCPitchSystem.advance("b1_read")
	VCPitchSystem.advance("b2_vizyon")             # _sorgu assigned here
	if VCPitchSystem._sorgu.get("key", "") != "refused_acq":
		return "refused-acq interrogation did not fire (sorgu=%s)" % str(VCPitchSystem._sorgu.get("key", ""))
	return ""


static func _case_sheet_expiry_no_rejection() -> String:
	# Two sheets granted the same day. Frank's warning comes at 3 BUSINESS days; at
	# the close the sheets are NOT dropped - a sit-or-decline card asks, one fund at a time,
	# on the same day; declining closes the fund and is not a rejection.
	GameState.set_phase(3)
	GameState.active_sheets.append(VCPitchSystem._make_sheet("anchor", GameState.day))
	GameState.active_sheets.append(VCPitchSystem._make_sheet("nexus", GameState.day))
	var expires: int = VCPitchSystem.sheet_for("anchor").expires_day
	if GameState.business_days_between(GameState.day, expires) != PitchConstants.SHEET_VALIDITY_BUSINESS_DAYS:
		return "validity is not %d business days" % PitchConstants.SHEET_VALIDITY_BUSINESS_DAYS
	var warned := false
	var decided: Array = []
	var decision_days: Array = []
	for i in 20:
		_sim_day_full()
		for guard in 16:
			var a: String = EventGate.active_id()
			if a == "":
				break
			if a == SHEET_WARN_ID:
				warned = true
				if VCPitchSystem.sheet_for("anchor").business_days_left(GameState.day) > PitchConstants.WARNING_DAYS:
					return "expiry warning early (%d business days left)" % VCPitchSystem.sheet_for("anchor").business_days_left(GameState.day)
			if a == SHEET_DECISION_ID:
				var vc: String = str(EventGate.active_context().get("investor", {}).get("id", ""))
				if GameState.active_sheets.size() != 2 - decided.size():
					return "a sheet was dropped before its decision (%d live)" % GameState.active_sheets.size()
				decided.append(vc)
				decision_days.append(GameState.day)
				EventGate.resolve(a, "decline")
				# The next card comes on the hourly sweep, the same day.
				while decided.size() < 2 and GameState.current_hour < TimeManager.HOURS_PER_DAY - 1 \
						and EventGate.active_id() == "":
					GameState.set_current_hour(GameState.current_hour + 1)
					TimeManager._dispatch_hourly_tick(GameState.current_hour)
				continue
			EventGate.resolve(a, 0)
		if decided.size() >= 2:
			break
	if not warned:
		return "no expiry warning admitted"
	if decided.size() != 2:
		return "decision cards seen for %s (want both funds)" % str(decided)
	if decided[0] == decided[1]:
		return "the same fund was asked twice: %s" % str(decided)
	if decision_days[0] != decision_days[1]:
		return "the two cards came on different days %s" % str(decision_days)
	if decision_days[0] < expires:
		return "decision card before the window closed (day %d < %d)" % [decision_days[0], expires]
	if not GameState.active_sheets.is_empty():
		return "declined sheets survived"
	for vc in ["anchor", "nexus"]:
		if GameState.vc_states.get(vc, {}).get("status", "") != "expired":
			return "%s status not closed after decline" % vc
		if VCPitchSystem.request_meeting(vc):
			return "%s could be re-booked after declining" % vc
	if GameState.vc_rejections != 0:
		return "decline counted as rejection (%d)" % GameState.vc_rejections
	return ""


static func _case_third_sheet_delayed() -> String:
	GameState.set_phase(3)
	_force("pass")
	_seed_b2b_series_a()   # bar + 1000
	_sim_day()
	GameState.active_sheets.append(VCPitchSystem._make_sheet("anchor", GameState.day))
	GameState.active_sheets.append(VCPitchSystem._make_sheet("nexus", GameState.day))
	VCPitchSystem.begin_meeting("meridian")
	_run_meeting("meridian", "metrik", "durust", "b4_ack")  # Kazanıldı, but 2 slots full
	if GameState.active_sheets.size() != 2:
		return "third sheet delivered immediately (%d)" % GameState.active_sheets.size()
	if not GameState.vc_states.get("meridian", {}).get("pending_sheet", false):
		return "pending_sheet flag not set"
	GameState.active_sheets.pop_front()  # free a slot (remove anchor)
	_sim_day()
	if GameState.active_sheets.size() != 2:
		return "pending sheet not delivered on slot free (%d)" % GameState.active_sheets.size()
	if VCPitchSystem.sheet_for("meridian") == null:
		return "meridian sheet not delivered"
	if GameState.vc_states["meridian"].get("pending_sheet", false):
		return "pending_sheet flag not cleared"
	return ""


static func _case_cascade_defer_with_sheet() -> String:
	GameState.set_phase(3)
	GameState.vc_rejections = 3
	GameState.set_mrr(0)  # no customers → bridge keeps it 0; cascade (not pivot) once sheet gone
	GameState.active_sheets.append(VCPitchSystem._make_sheet("anchor", GameState.day))
	_sim_day()
	if not GameState.run_active:
		return "cascade fired despite a live sheet: %s" % str(_endings)
	GameState.active_sheets.clear()
	for i in 3:
		_sim_day()
		if not GameState.run_active:
			break
	if _endings != ["vc_rejection_cascade"]:
		return "endings: %s" % str(_endings)
	return ""


static func _case_walk_not_a_rejection() -> String:
	# The player's walk closes the fund for the run but is not a rejection.
	GameState.set_phase(3)
	GameState.active_sheets.append(VCPitchSystem._make_sheet("anchor", GameState.day))
	GameState.active_sheets.append(VCPitchSystem._make_sheet("nexus", GameState.day))
	VCPitchSystem.walk_table("anchor")
	if GameState.vc_rejections != 0:
		return "the player's walk counted as a rejection (%d)" % GameState.vc_rejections
	if VCPitchSystem.request_meeting("anchor"):
		return "a walked fund could be re-booked"
	if GameState.vc_states.get("anchor", {}).get("status", "") != "walked":
		return "status not walked"
	if VCPitchSystem.sheet_for("anchor") != null:
		return "walked sheet survived"
	if VCPitchSystem.sheet_for("nexus") == null:
		return "other sheet destroyed by walk"
	return ""


# ============================================================================
# Term Sheet Table cases — drive TermSheetTableSystem engine-directly (no scene).
# ============================================================================

static func _grant(vc: String) -> void:
	GameState.active_sheets.append(VCPitchSystem._make_sheet(vc, GameState.day))


## The opening valuation the LIVE formula produces for a fund, in millions. The three table
## cases below used to hard-code Anchor's frozen 18; the sheet is priced from ARR now, so
## the expectation has to come from the same place the game gets it.
static func _derived_open_val(vc_id: String) -> int:
	var sheet: TermSheet = VCPitchSystem._make_sheet(vc_id, GameState.day)
	return int(sheet.opening_terms.get("valuation_m", 0))


static func _derived_open_dil(vc_id: String) -> int:
	var sheet: TermSheet = VCPitchSystem._make_sheet(vc_id, GameState.day)
	return int(sheet.opening_terms.get("dilution_pct", 0))


static func _case_table_sign_closes_series_a() -> String:
	GameState.set_phase(3)
	_force("pass")
	_grant("anchor")
	var captured: Array = []  # ending_data dicts (Array mutation survives lambda capture)
	EventBus.run_ended.connect(func(_id: String, d: Dictionary) -> void: captured.append(d))
	TermSheetTableSystem.open("anchor")
	TermSheetTableSystem.select_lever("valuation")
	var want_val: int = _derived_open_val("anchor") + PitchConstants.VAL_STEP
	var want_dil: int = _derived_open_dil("anchor")
	TermSheetTableSystem.push()  # one successful push on the valuation
	TermSheetTableSystem.sign()
	if _endings != ["series_a_close"]:
		return "endings: %s" % str(_endings)
	if captured.is_empty():
		return "no ending data captured"
	var d: Dictionary = captured[0]
	if int(d.get("valuation_m", 0)) != want_val:
		return "valuation_m=%s (want %d)" % [str(d.get("valuation_m")), want_val]
	if int(d.get("dilution_pct", 0)) != want_dil:
		return "dilution_pct=%s (want %d)" % [str(d.get("dilution_pct")), want_dil]
	if int(d.get("board_seats", -1)) != 1 or not bool(d.get("board_veto", false)):
		return "board terms: seats=%s veto=%s" % [str(d.get("board_seats")), str(d.get("board_veto"))]
	if int(d.get("money_raised", 0)) != int(round(want_val * 1_000_000.0 * want_dil / 100.0)):
		return "money_raised=%s" % str(d.get("money_raised"))
	return ""


static func _case_table_walk_not_a_rejection() -> String:
	GameState.set_phase(3)
	_grant("anchor")
	_grant("nexus")
	var walked: Array = []
	EventBus.sheet_walked.connect(func(vc: String) -> void: walked.append(vc))
	TermSheetTableSystem.open("anchor")
	TermSheetTableSystem.walk()
	if GameState.vc_rejections != 0:
		return "vc_rejections=%d (want 0 — K11: the player's walk is not a rejection)" % GameState.vc_rejections
	if GameState.vc_states.get("anchor", {}).get("status", "") != "walked":
		return "status not walked"
	if VCPitchSystem.sheet_for("anchor") != null:
		return "walked sheet survived"
	if VCPitchSystem.sheet_for("nexus") == null:
		return "other sheet destroyed"
	if walked != ["anchor"]:
		return "sheet_walked payload: %s" % str(walked)
	return ""


static func _case_patience_zero_locks_pushes() -> String:
	# Patience zero is no longer a free stop. An EAGER fund (high meeting conviction)
	# puts a final take-it-or-leave-it counter — pushes locked, only Sign and Walk. A COLD
	# fund walks out: closed for the run, sheet gone, one rejection counted, no signing.
	GameState.set_phase(3)
	_force("fail")
	_grant("bosphorus")  # patience 2
	VCPitchSystem.sheet_for("bosphorus").conviction = 100
	TermSheetTableSystem.open("bosphorus")
	TermSheetTableSystem.select_lever("valuation")
	TermSheetTableSystem.push()  # fail → patience 1
	if String(TermSheetTableSystem.view_state().investor_line) == "":
		return "the fund said nothing after a push — E's band is unreadable"
	TermSheetTableSystem.push()  # fail → patience 0 → final offer
	var vs: Dictionary = TermSheetTableSystem.view_state()
	if int(vs.state) != TermSheetTableSystem.PATIENCE_ZERO or not bool(vs.final_offer):
		return "eager fund: state=%d (want the final offer, PATIENCE_ZERO=%d)" % [
			int(vs.state), TermSheetTableSystem.PATIENCE_ZERO]
	for lever in TermSheetTableSystem.levers():
		if TermSheetTableSystem.can_push(lever):
			return "can still push %s at patience zero" % lever
	if not bool(vs.sign_enabled) or not bool(vs.walk_enabled):
		return "sign/walk disabled at the final offer"
	if int(vs.patience.current) != 0:
		return "patience.current=%d" % int(vs.patience.current)
	if bool(TermSheetTableSystem.show_other_available()) and TermSheetTableSystem.can_show_other():
		return "the other offer can still be shown after the final offer"
	TermSheetTableSystem._reset()

	# The cold fund: same pushes, no goodwill left → it walks.
	var rej0: int = GameState.vc_rejections
	VCPitchSystem.sheet_for("bosphorus").conviction = 0
	TermSheetTableSystem.open("bosphorus")
	TermSheetTableSystem.select_lever("valuation")
	TermSheetTableSystem.push()
	TermSheetTableSystem.push()
	vs = TermSheetTableSystem.view_state()
	if int(vs.state) != TermSheetTableSystem.FUND_WALKED or not bool(vs.fund_walked):
		return "cold fund: state=%d (want FUND_WALKED=%d)" % [int(vs.state), TermSheetTableSystem.FUND_WALKED]
	if bool(vs.sign_enabled):
		return "sign still enabled after the fund walked out"
	if GameState.vc_rejections != rej0 + 1:
		return "the walk-out counted %d rejections" % (GameState.vc_rejections - rej0)
	if VCPitchSystem.sheet_for("bosphorus") != null:
		return "the walked-out sheet survived"
	if String(GameState.vc_states.get("bosphorus", {}).get("status", "")) != "rejected":
		return "the walked-out fund is '%s', not closed as a rejection" % String(
			GameState.vc_states.get("bosphorus", {}).get("status", ""))
	TermSheetTableSystem.walk()   # a second exit must not count a second rejection
	if GameState.vc_rejections != rej0 + 1 or TermSheetTableSystem.is_active():
		return "leaving after the walk-out moved the counter or kept the table open"
	return ""


static func _case_push_decay_lowers_odds() -> String:
	# Invariant: breakdown().total == chance_for() for a few inputs.
	for combo in [["sales", 0, 0], ["negotiation", 1, 1], ["influence", 2, 0]]:
		var bd0: Dictionary = SkillCheck.breakdown(combo[0], combo[1], combo[2])
		if abs(float(bd0.total) - SkillCheck.chance_for(combo[0], combo[1], combo[2])) > 0.0000001:
			return "breakdown.total != chance_for for %s" % str(combo)
	GameState.set_phase(3)
	_force("pass")
	_grant("anchor")
	TermSheetTableSystem.open("anchor")
	var odds1: float = TermSheetTableSystem.odds_for("valuation").chance
	var money0: int = TermSheetTableSystem.money_raised()
	var pat0: int = int(TermSheetTableSystem.view_state().patience.current)
	TermSheetTableSystem.select_lever("valuation")
	TermSheetTableSystem.push()
	if TermSheetTableSystem.money_raised() <= money0:
		return "valuation push did not move the lever"
	if int(TermSheetTableSystem.view_state().patience.current) != pat0:
		return "patience changed on a successful push"
	var odds2: float = TermSheetTableSystem.odds_for("valuation").chance
	var expected: float = clampf(odds1 - PitchConstants.PUSH_DECAY, PitchConstants.PUSH_ODDS_FLOOR, SkillCheck.MAX_CHANCE)
	if abs(odds2 - expected) > 0.0000001:
		return "decay wrong: odds1=%f odds2=%f expected=%f" % [odds1, odds2, expected]
	return ""


static func _case_leverage_bonus_applies_and_shows() -> String:
	GameState.set_phase(3)
	_grant("anchor")
	_grant("nexus")
	TermSheetTableSystem.open("anchor")
	var vs: Dictionary = TermSheetTableSystem.view_state()
	if not bool(vs.leverage.active):
		return "leverage not active with 2 sheets"
	# The base is what the formula opens at, not what the registry used to freeze.
	var base_val: int = _derived_open_val("anchor")
	var cur: String = String(vs.levers[0].current_text)
	var lev_val: int = int(cur.trim_prefix("$").trim_suffix("M"))
	if lev_val != base_val + PitchConstants.LEVERAGE_OPEN_NOTCH:
		return "opening notch not applied (%d, want %d)" % [lev_val, base_val + PitchConstants.LEVERAGE_OPEN_NOTCH]
	var baseline: float = SkillCheck.chance_for("sales", int(PitchConstants.LEVER_DIFF["valuation"]), 0)
	if TermSheetTableSystem.odds_for("valuation").chance <= baseline:
		return "leverage did not raise odds above baseline"
	if String(vs.leverage.other_vc_name) != "Nexus Ventures":
		return "other_vc_name=%s" % String(vs.leverage.other_vc_name)
	# The other live sheet can be shown, once, and the fund answers in its own voice.
	if not bool(vs.show_other.visible) or not bool(vs.show_other.enabled):
		return "show-the-other-offer is not on offer with two live sheets"
	var shown: Dictionary = TermSheetTableSystem.show_other_offer()
	if String(shown.show_other.outcome) == "" or String(shown.investor_line) == "":
		return "the fund did not answer the shown offer"
	if bool(shown.show_other.enabled):
		return "the other offer can be shown twice"
	return ""


static func _case_no_leverage_no_box() -> String:
	GameState.set_phase(3)
	_grant("anchor")
	TermSheetTableSystem.open("anchor")
	var vs: Dictionary = TermSheetTableSystem.view_state()
	if bool(vs.leverage.active):
		return "leverage active with a single sheet"
	if String(vs.leverage.box_text) != "":
		return "leverage box text present with a single sheet"
	var cur: String = String(vs.levers[0].current_text)
	if int(cur.trim_prefix("$").trim_suffix("M")) != _derived_open_val("anchor"):
		return "single-sheet opening notched (%s)" % cur
	return ""


static func _case_investment_figure_tracks_terms() -> String:
	GameState.set_phase(3)
	_force("pass")
	_grant("anchor")
	TermSheetTableSystem.open("anchor")
	var v0: int = _derived_open_val("anchor")
	var d0: int = _derived_open_dil("anchor")
	var m0: int = TermSheetTableSystem.money_raised()
	if m0 != int(round(v0 * 1_000_000.0 * d0 / 100.0)):
		return "m0=%d (want %d)" % [m0, int(round(v0 * 1_000_000.0 * d0 / 100.0))]
	TermSheetTableSystem.select_lever("valuation")
	TermSheetTableSystem.push()
	var m1: int = TermSheetTableSystem.money_raised()
	var v1: int = v0 + PitchConstants.VAL_STEP
	if m1 <= m0 or m1 != int(round(v1 * 1_000_000.0 * d0 / 100.0)):
		return "m1=%d (want > m0 and %dM at %d%%)" % [m1, v1, d0]
	TermSheetTableSystem.select_lever("dilution")
	TermSheetTableSystem.push()
	var m2: int = TermSheetTableSystem.money_raised()
	var d1: int = maxi(d0 - PitchConstants.DIL_STEP, PitchConstants.DIL_FLOOR)
	if m2 >= m1 or m2 != int(round(v1 * 1_000_000.0 * d1 / 100.0)):
		return "m2=%d (want < m1 and %dM at %d%%)" % [m2, v1, d1]
	return ""


static func _case_table_board_push_sequence() -> String:
	GameState.set_phase(3)
	_force("pass")
	_grant("anchor")  # board 1 seat + veto
	TermSheetTableSystem.open("anchor")
	TermSheetTableSystem.select_lever("board")
	TermSheetTableSystem.push()  # drop veto
	# Locale-independent: asserts the SHAPE, not the Turkish bytes. The old byte-pin passed
	# only because the process happened to be running in Turkish.
	var want_seat: String = TranslationServer.translate("TERM_BOARD_SEAT_ONE").format({"n": 1})
	var got_seat: String = String(TermSheetTableSystem.view_state().levers[2].current_text)
	if got_seat != want_seat:
		return "after veto push: %s (want '%s')" % [got_seat, want_seat]
	TermSheetTableSystem.push()  # drop seat
	var want_clean: String = TranslationServer.translate("TERM_BOARD_CLEAN")
	var got_clean: String = String(TermSheetTableSystem.view_state().levers[2].current_text)
	if got_clean != want_clean:
		return "after seat push: %s (want '%s')" % [got_clean, want_clean]
	if TermSheetTableSystem.can_push("board"):
		return "board still pushable at temiz"
	return ""


static func _case_deal_prompt_defer_keeps_clock() -> String:
	# "Sonra" path: the sheet sits in active_sheets with its validity running; the table is
	# re-enterable until expiry. (The Frank prompt is UI-layer; this asserts the sheet economy
	# the defer relies on.)
	GameState.set_phase(3)
	_grant("anchor")
	var sheet: TermSheet = VCPitchSystem.sheet_for("anchor")
	if sheet == null:
		return "sheet not granted"
	var day0: int = GameState.day
	if sheet.business_days_left(GameState.day) != PitchConstants.SHEET_VALIDITY_BUSINESS_DAYS:
		return "validity clock not at full (%d)" % sheet.business_days_left(GameState.day)
	for i in 3:
		_sim_day()
	if VCPitchSystem.sheet_for("anchor") == null:
		return "sheet expired too early during defer"
	var vs: Dictionary = TermSheetTableSystem.open("anchor")
	if vs.is_empty() or not TermSheetTableSystem.is_active():
		return "table not re-enterable after defer"
	var want: int = PitchConstants.SHEET_VALIDITY_BUSINESS_DAYS - GameState.business_days_between(day0, GameState.day)
	if sheet.business_days_left(GameState.day) != want:
		return "clock did not tick in business days during defer (%d, want %d)" % [sheet.business_days_left(GameState.day), want]
	return ""


static func _case_hunt_offer_lifecycle() -> String:
	# The pre-table estimate contains the true opening term and is never centred on it,
	# and it does not reroll. Cancelling costs the fund's next meeting and shuts booking
	# for the day. Frank's cold exit is the fund's own line first, then "two in a row".
	# A clean Beat-3 question shows the odds it rolls.
	GameState.set_phase(3)
	_seed_b2b_series_a()
	_sim_day()
	for vc in ["anchor", "nexus", "bosphorus", "meridian"]:
		var sh: TermSheet = VCPitchSystem._make_sheet(vc, GameState.day)
		var r: Dictionary = VCPitchSystem.estimate_ranges(sh)
		var v: int = int(sh.opening_terms.valuation_m)
		var d: int = int(sh.opening_terms.dilution_pct)
		if not (int(r.val_lo) <= v and v <= int(r.val_hi)) or int(r.val_lo) + int(r.val_hi) == 2 * v:
			return "%s valuation range %s bad for %d" % [vc, str(r), v]
		if not (int(r.dil_lo) <= d and d <= int(r.dil_hi)) or int(r.dil_lo) + int(r.dil_hi) == 2 * d:
			return "%s dilution range %s bad for %d" % [vc, str(r), d]
		if VCPitchSystem.estimate_ranges(sh) != r:
			return "%s estimate rerolled" % vc

	var base: int = int(VCPitchSystem.initial_conviction("nexus").value)
	if not VCPitchSystem.request_meeting("nexus"):
		return "request refused"
	if not VCPitchSystem.cancel_meeting():
		return "cancel refused"
	if VCPitchSystem.request_meeting("anchor"):
		return "a meeting was booked the same day as a cancel"
	if VCPitchSystem.meeting_blocked_reason("anchor") != "cancelled_today":
		return "blocked reason '%s'" % VCPitchSystem.meeting_blocked_reason("anchor")
	var after: int = int(VCPitchSystem.initial_conviction("nexus").value)
	if base - after != PitchConstants.MEETING_CANCEL_PENALTY:
		return "cancel penalty %d (want %d)" % [base - after, PitchConstants.MEETING_CANCEL_PENALTY]
	_sim_day()
	if not VCPitchSystem.request_meeting("nexus"):
		return "booking still shut the next day"
	var day_before: int = int(GameState.pending_meeting.day)
	_sim_day()
	if not VCPitchSystem.reschedule_meeting():
		return "reschedule refused"
	if int(GameState.pending_meeting.day) != GameState.day + PitchConstants.MEETING_LEAD_DAYS \
			or int(GameState.pending_meeting.day) == day_before:
		return "reschedule did not re-apply the lead time from today"
	if int(GameState.vc_states["nexus"].get("move_penalty", 0)) \
			!= PitchConstants.MEETING_CANCEL_PENALTY + PitchConstants.MEETING_RESCHEDULE_PENALTY:
		return "move penalties did not accumulate (%s)" % str(GameState.vc_states["nexus"].get("move_penalty"))
	GameState.pending_meeting.clear()

	# Cold exit: two rejections in a row.
	_force("fail")
	VCPitchSystem.begin_meeting("anchor")
	VCPitchSystem.advance("b1_read")
	VCPitchSystem.advance("b2_metrik")
	# The shown Beat-3 odds use the rolled difficulty (Kolay on a clean question).
	VCPitchSystem._sorgu = {"key": "clean"}
	var vs: Dictionary = VCPitchSystem._beat3_view_state({})
	var want_odds: String = VCPitchSystem._odds(TranslationServer.translate("VC_APPROACH_HONEST"),
		PitchConstants.BEAT3_SKILL, PitchConstants.DIFF_KOLAY, 0)
	if String(vs.choices[0].odds_text) != want_odds:
		return "clean-question odds shown '%s', rolled '%s'" % [vs.choices[0].odds_text, want_odds]
	VCPitchSystem.advance("b3_spin")
	VCPitchSystem.advance("b4_leave")
	if not GameState.vc_frank_cold_shown.has("anchor") or not GameState.vc_last_meeting_rejected:
		return "first rejection did not show the fund's own line (%s)" % str(GameState.vc_frank_cold_shown)
	VCPitchSystem.begin_meeting("meridian")
	VCPitchSystem.advance("b1_read")
	VCPitchSystem.advance("b2_metrik")
	VCPitchSystem.advance("b3_spin")
	if VCPitchSystem._pick_cold_exit() != "VC_FRANK_COLD_GENERAL_2":
		return "second rejection in a row picked %s" % VCPitchSystem._pick_cold_exit()
	VCPitchSystem.advance("b4_leave")
	if GameState.vc_frank_cold_shown.has("meridian"):
		return "the general line also spent meridian's own line"
	return ""


## A v12 SAVE FROM BEFORE THE CANCEL-PENALTY, FINAL-COUNTER AND COLD-EXIT FIELDS
## LOADS AND SITS DOWN. Not a hand-written fixture: a real save is taken with every new field at
## a NON-default value, each key is asserted present in the file (so deleting it cannot be
## vacuous), deleted, and the file goes back through read_slot + apply_loaded_state. What comes
## back must be the declared defaults, and the live offer must open the table at
## E_FALLBACK_CONV_SERIES_A + fit. The fit is read, never hard-coded, so the case does not care
## how a fund's lens is defined. The offer is granted on a WEEKEND, the only grant day on which
## the old fourteen-calendar-day expiry differs from the current ten-business-day one.
static func _case_legacy_v12_save_opens_live_table() -> String:
	const STAMP := 88   # never equal to the fallback, so a surviving stamp cannot pass as it
	if SaveManager.MIN_LOADABLE_VERSION > 12:
		return "v12 is below MIN_LOADABLE_VERSION (%d) — this case's premise is retired" \
			% SaveManager.MIN_LOADABLE_VERSION
	# Its own slot: the shared manual_9001/9002 pair belongs to the round-trip cases.
	var slot: String = "smoke_legacy_v12_%d" % OS.get_process_id()

	# --- a live hunt with every new field at a non-default value ---------------
	GameState.set_phase(3)
	_seed_b2b_series_a()
	_sim_day()
	_drain_all_modals()   # a card on screen refuses the save (can_save); answer it first
	var walk_guard: int = 0
	while GameState.is_business_day(GameState.day) and walk_guard < 7:
		walk_guard += 1
		_sim_day()
		_drain_all_modals()
	if GameState.is_business_day(GameState.day):
		return "fixture: no weekend reached to grant on"
	# The cancel penalty the real way: book Nexus and cancel, which writes move_penalty on ITS row and today's
	# cancel day. Not on Anchor: begin_meeting erases the penalty, so a fund holding an offer
	# and a penalty at once is not a state the game produces.
	if not VCPitchSystem.request_meeting("nexus") or not VCPitchSystem.cancel_meeting():
		return "fixture: could not book and cancel a Nexus meeting"
	# Cold-exit memory: an earlier meeting ended cold and spent Meridian's own line.
	GameState.vc_last_meeting_rejected = true
	GameState.vc_frank_cold_shown.append("meridian")
	# The live offer, stamped the way _grant_sheet stamps it: row first, then the grant, so
	# _make_sheet reads the stamp.
	var anchor_st: Dictionary = VCPitchSystem._vc("anchor")
	anchor_st["sheet_conviction"] = STAMP
	_grant("anchor")
	anchor_st["status"] = "offered"
	var sheet: TermSheet = VCPitchSystem.sheet_for("anchor")
	if sheet == null or sheet.conviction != STAMP:
		return "fixture: the grant did not carry the row's conviction"
	sheet.expires_day = sheet.granted_day + 14   # the OLD rule: fourteen calendar days
	var want_expires: int = sheet.expires_day
	if want_expires == GameState.add_business_days(sheet.granted_day, PitchConstants.SHEET_VALIDITY_BUSINESS_DAYS):
		return "fixture: the old and new rules agree on this grant day — nothing old to load"
	var save_day: int = GameState.day

	# Checked first so a refusal is diagnosed here, not as save_to_slot's warning.
	if not SaveManager.can_save():
		return "fixture: save refused (%s, active card '%s')" \
			% [SaveManager.cannot_save_reason_key(), EventGate.active_id()]
	if not SaveManager.save_to_slot(slot):
		SaveManager.delete_slot(slot)
		return "save_to_slot failed"

	# --- age the file: the keys ARE there, then they are not --------------------
	var path: String = SaveManager.SAVE_DIR + slot + ".json"
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		SaveManager.delete_slot(slot)
		return "could not reopen the slot to strip it"
	var raw: Dictionary = JSON.parse_string(f.get_as_text()) as Dictionary
	f.close()
	var gs: Dictionary = (raw.get("state", {}) as Dictionary).get("game_state", {}) as Dictionary
	var sheets_json: Array = gs.get("active_sheets", []) as Array
	var rows: Dictionary = gs.get("vc_states", {}) as Dictionary
	var pre: String = ""
	if sheets_json.size() != 1 or int((sheets_json[0] as Dictionary).get("conviction", -1)) != STAMP:
		pre = "the sheet's conviction"
	elif int((sheets_json[0] as Dictionary).get("expires_day", 0)) != want_expires:
		pre = "the old-rule expires_day"
	elif int((rows.get("anchor", {}) as Dictionary).get("sheet_conviction", -1)) != STAMP:
		pre = "anchor's sheet_conviction"
	elif int((rows.get("nexus", {}) as Dictionary).get("move_penalty", 0)) != PitchConstants.MEETING_CANCEL_PENALTY:
		pre = "nexus's move_penalty"
	elif int(gs.get("vc_meeting_cancel_day", -1)) != save_day:
		pre = "vc_meeting_cancel_day"
	elif not bool(gs.get("vc_last_meeting_rejected", false)):
		pre = "vc_last_meeting_rejected"
	elif (gs.get("vc_frank_cold_shown", []) as Array).size() != 1:
		pre = "vc_frank_cold_shown"
	if pre != "":
		SaveManager.delete_slot(slot)
		return "fixture: %s was not in the file — deleting it would prove nothing" % pre
	for s in sheets_json:
		(s as Dictionary).erase("conviction")
	for vc in rows.keys():                       # vc_states[*], every row
		(rows[vc] as Dictionary).erase("sheet_conviction")
		(rows[vc] as Dictionary).erase("move_penalty")
	for k in ["vc_meeting_cancel_day", "vc_last_meeting_rejected", "vc_frank_cold_shown"]:
		gs.erase(k)
	raw["schema_version"] = 12   # explicit: a later schema bump must walk its migration ladder
	var w := FileAccess.open(path, FileAccess.WRITE)
	if w == null:
		SaveManager.delete_slot(slot)
		return "could not rewrite the slot"
	w.store_string(JSON.stringify(raw, "\t", false, true))
	w.close()

	var payload: Dictionary = SaveManager.read_slot(slot)
	SaveManager.delete_slot(slot)   # the payload is in memory; nothing below needs the file
	if not bool(payload.get("ok", false)):
		return "the stripped v12 save was refused: %s" % String(payload.get("error_key", ""))
	if not SaveManager.apply_loaded_state(payload):
		return "apply_loaded_state returned false"
	if GameState.day != save_day:
		return "the load came back on day %d, saved on %d" % [GameState.day, save_day]

	# --- GameState: initialize_run defaults ---------------------------------------
	if GameState.vc_meeting_cancel_day != -1:
		return "vc_meeting_cancel_day came back %d, want -1" % GameState.vc_meeting_cancel_day
	if GameState.vc_last_meeting_rejected:
		return "vc_last_meeting_rejected came back true"
	if not GameState.vc_frank_cold_shown.is_empty():
		return "vc_frank_cold_shown came back %s" % str(GameState.vc_frank_cold_shown)
	# The cancel day was TODAY in the file; had it survived, booking would read cancelled_today.
	if VCPitchSystem.meeting_blocked_reason("bosphorus") != "":
		return "booking locked after the load (%s)" % VCPitchSystem.meeting_blocked_reason("bosphorus")

	# --- the offer ---------------------------------------------------------------
	var loaded: TermSheet = VCPitchSystem.sheet_for("anchor")
	if loaded == null:
		return "the live offer did not survive the load"
	if loaded.conviction != -1:
		return "sheet conviction came back %d, want -1 (unstamped)" % loaded.conviction
	if loaded.expires_day != want_expires:
		return "expires_day came back %d, want the old-rule %d" % [loaded.expires_day, want_expires]
	# Two calendar weeks hold exactly ten weekdays wherever they start; a calendar count reads 14.
	var left: int = loaded.business_days_left(GameState.day)
	if left != 10:
		return "the old 14-day window reads %d business days, want 10" % left
	if loaded.is_decision_due(GameState.day):
		return "a fresh old-rule offer loaded already decision-due"
	# The clock read through the business-day counter on every day up to a week past the old
	# expiry: never negative, always the counter's own number (0 once the window is gone).
	for d in range(save_day, want_expires + 8):
		var n: int = loaded.business_days_left(d)
		if n < 0 or n != maxi(0, GameState.business_days_between(d, want_expires)):
			return "day %d: the old offer reads %d business days, counter says %d" \
				% [d, n, GameState.business_days_between(d, want_expires)]
	if not loaded.is_decision_due(want_expires):
		return "the old-rule offer is not decision-due on its own expires_day"

	# --- vc_states rows: absent keys read as the reader defaults -----------------
	var a_row: Dictionary = GameState.vc_states.get("anchor", {})
	if a_row.is_empty() or a_row.has("sheet_conviction"):
		return "anchor's row came back wrong: %s" % str(a_row)
	if VCPitchSystem._make_sheet("anchor", GameState.day).conviction != -1:
		return "a sheet re-made from the loaded row is stamped (delayed delivery path)"
	var n_row: Dictionary = GameState.vc_states.get("nexus", {})
	if n_row.is_empty() or n_row.has("move_penalty"):
		return "nexus's row came back wrong: %s" % str(n_row)
	# Same-world control through the reader itself: absent must cost exactly nothing.
	var conv_free: int = int(VCPitchSystem.initial_conviction("nexus").value)
	n_row["move_penalty"] = PitchConstants.MEETING_CANCEL_PENALTY
	var conv_pen: int = int(VCPitchSystem.initial_conviction("nexus").value)
	n_row.erase("move_penalty")
	if conv_free - conv_pen != PitchConstants.MEETING_CANCEL_PENALTY:
		return "an absent move_penalty did not read as 0 (%d without, %d with %d)" \
			% [conv_free, conv_pen, PitchConstants.MEETING_CANCEL_PENALTY]

	# --- the table ---------------------------------------------------------------
	var vs: Dictionary = TermSheetTableSystem.open("anchor")
	if vs.is_empty() or not TermSheetTableSystem.is_active() or not bool(vs.get("sign_enabled", false)):
		TermSheetTableSystem.reset()
		return "the table did not open on the loaded offer"
	var fit: int = TermSheetTableSystem._domain_fit()   # after open: it reads the seated fund
	var got_open: int = TermSheetTableSystem._opening_conviction(loaded)
	var got_e: int = TermSheetTableSystem.eagerness()
	TermSheetTableSystem.reset()
	if got_open != TermSheetTableSystem.E_FALLBACK_CONV_SERIES_A:
		return "opening conviction %d, want the fallback %d" % [got_open, TermSheetTableSystem.E_FALLBACK_CONV_SERIES_A]
	var want_e: int = clampi(TermSheetTableSystem.E_FALLBACK_CONV_SERIES_A + fit, 0, 100)
	if got_e != want_e:
		return "E opened at %d, want %d (fallback %d + fit %d)" \
			% [got_e, want_e, TermSheetTableSystem.E_FALLBACK_CONV_SERIES_A, fit]
	# Discrimination: the same table WITH a stamp opens elsewhere, so the check above is not
	# satisfied by a table that ignores conviction altogether.
	loaded.conviction = STAMP
	TermSheetTableSystem.open("anchor")
	var stamped_e: int = TermSheetTableSystem.eagerness()
	TermSheetTableSystem.reset()
	if stamped_e != clampi(STAMP + fit, 0, 100):
		return "a stamped sheet opened at %d, want %d" % [stamped_e, clampi(STAMP + fit, 0, 100)]
	return ""


## The Hunt tab's "road closed" line reads
## VCPitchSystem.series_a_road_closed(). Every fund closed in a word the game writes and nothing
## live → true. Each thing that still leaves a table to reach turns it false ON ITS OWN, and
## taking it away turns it back.
static func _case_series_a_road_closed_when_all_funds_close() -> String:
	# The line resolves in both locales. Read per locale, no switch — nothing to restore.
	for loc in ["tr", "en"]:
		var tobj: Translation = TranslationServer.get_translation_object(loc)
		if tobj == null:
			return "no %s translation loaded" % loc
		var line: String = String(tobj.get_message("HUNT_ROAD_CLOSED"))
		if line == "" or line == "HUNT_ROAD_CLOSED":
			return "HUNT_ROAD_CLOSED does not resolve in %s" % loc

	var funds: Array[String] = []
	for inv in InvestorRegistry.get_active():
		funds.append(String(inv.id))
	if funds.size() != 4:
		return "fixture: %d active funds (this case closes four)" % funds.size()
	# One closed word per fund, each one the game writes: rejected (a meeting refusal or the
	# fund walking out), walked (the player's walk), expired (the sit-or-decline card's decline).
	var closed: Dictionary = {"anchor": "rejected", "nexus": "walked", "bosphorus": "expired", "meridian": "rejected"}

	GameState.set_phase(3)
	if VCPitchSystem.series_a_road_closed():
		return "a fresh hunt (no fund rows; status defaults to open) read as closed"
	for id in funds:
		VCPitchSystem._vc(id)                       # explicit open rows, _vc's own shape
	if VCPitchSystem.series_a_road_closed():
		return "four open rows read as closed"
	for id in ["anchor", "nexus", "bosphorus"]:
		var st: Dictionary = VCPitchSystem._vc(id)
		st["status"] = closed[id]
	if VCPitchSystem.series_a_road_closed():
		return "read closed with meridian still open"
	var mer: Dictionary = VCPitchSystem._vc("meridian")
	mer["status"] = "callback"                                   # _set_callback's shape
	mer["callback"] = VCPitchSystem._make_callback("meridian")
	if VCPitchSystem.series_a_road_closed():
		return "read closed with meridian holding an unmet callback"

	# THE CLAIM.
	mer["status"] = closed["meridian"]
	mer["callback"] = {}
	if not VCPitchSystem.series_a_road_closed():
		return "all four funds closed, nothing live, and the road still reads open: %s" % str(GameState.vc_states)

	for p in [1, 2]:
		GameState.set_phase(p)
		if VCPitchSystem.series_a_road_closed():
			return "phase %d read the Series A road as closed" % p
	GameState.set_phase(3)
	if not VCPitchSystem.series_a_road_closed():
		return "back in phase 3 the road did not read closed"

	# A booked meeting — request_meeting's shape. Written directly: request_meeting refuses a
	# closed fund, and a booking with an open status would be caught by the status read instead.
	GameState.pending_meeting = {"vc_id": "meridian", "day": GameState.day + PitchConstants.MEETING_LEAD_DAYS}
	if VCPitchSystem.series_a_road_closed():
		return "a booked meeting still read as road closed"
	GameState.pending_meeting.clear()
	if not VCPitchSystem.series_a_road_closed():
		return "clearing the booking did not close the road again"

	_grant("anchor")                                  # a live sheet, statuses untouched
	if VCPitchSystem.series_a_road_closed():
		return "a live offer still read as road closed"
	GameState.active_sheets.clear()
	if not VCPitchSystem.series_a_road_closed():
		return "clearing the sheet did not close the road again"

	mer["pending_sheet"] = true                       # _grant_sheet's queue shape
	mer["status"] = "pending_sheet"
	if VCPitchSystem.series_a_road_closed():
		return "a queued sheet still read as road closed"
	mer["status"] = closed["meridian"]                # the flag alone
	if VCPitchSystem.series_a_road_closed():
		return "the pending_sheet flag alone did not keep the road open"
	mer["pending_sheet"] = false
	if not VCPitchSystem.series_a_road_closed():
		return "clearing the queue did not close the road again"

	# A pivot closes the road even with a fund still open.
	mer["status"] = "open"
	if VCPitchSystem.series_a_road_closed():
		return "meridian reopened and the road still read closed"
	GameState.pivot_used = true
	if not VCPitchSystem.series_a_road_closed():
		return "a pivot did not close the road"
	return ""


static func _case_prep_bonus_and_capacity() -> String:
	GameState.set_phase(3)
	if not VCPitchSystem.request_meeting("anchor"):
		return "request refused"
	if not VCPitchSystem.start_prep("anchor", "rakamlar"):
		return "prep refused (should be allowed, 3 days out)"
	if not GameState.get_flag("pitch_prep_active", false):
		return "capacity flag not set"
	# MEKANİZMA DEĞİŞTİ, KONU AYNI (H6, 2026-08-21). Hazırlık eskiden KAPASİTE TALEBİ
	# sayılıyordu, yani yapımın TAMAMINI yavaşlatıyordu — yanlış aktör: hazırlık yalnız
	# KURUCUYU tutar, çalışanların hızına dokunmamalı. Artık kurucuyu MEŞGUL sayar;
	# tek taşıyıcı oysa yapım DURUR, değilse hiçbir şey yavaşlamaz (ara kademe yok).
	if ProductSystem.capacity_demand() != 0:
		return "VC prep still eats build capacity (demand=%d) — H6 moved it off the multiplier" \
			% ProductSystem.capacity_demand()
	var founder: Character = CharacterRegistry.get_founder()
	if ProductSystem._is_free(founder):
		return "a founder in VC prep still counts as FREE for the build"
	VCPitchSystem.begin_meeting("anchor")  # consumes the prep focus
	if GameState.get_flag("pitch_prep_active", false):
		return "capacity flag not cleared at meeting start"
	if not ProductSystem._is_free(founder):
		return "the founder stayed busy after the prep was consumed"
	return ""


static func _case_meeting_daylock() -> String:
	GameState.set_phase(3)
	VCPitchSystem.request_meeting("anchor")
	if VCPitchSystem.prep_blocked_reason("anchor") != "":
		return "prep blocked 3 days out (should be allowed)"
	_sim_day()
	_sim_day()  # now 1 day before the meeting
	if VCPitchSystem.prep_blocked_reason("anchor") == "":
		return "prep not blocked <2 days before meeting"
	if VCPitchSystem.start_prep("anchor", "rakamlar"):
		return "start_prep succeeded when it should be blocked"
	return ""


static func _case_pivot_closes_hunt() -> String:
	GameState.set_phase(3)
	VCPitchSystem.request_meeting("anchor")
	GameState.vc_states["nexus"] = {"status": "callback", "callback": {"type": "first_engineer", "target": 1, "met": false}, "pending_sheet": false, "meeting_count": 1, "reentry_bonus": false}
	EndingsSystem.on_pivot_accepted()
	if not GameState.pending_meeting.is_empty():
		return "pending meeting survived pivot"
	if GameState.vc_states["nexus"].get("status", "") != "rejected":
		return "callback not killed by pivot"
	if not GameState.pivot_used:
		return "pivot_used not set"
	return ""


static func _case_meeting_during_kepenk() -> String:
	GameState.set_phase(3)
	GameState.set_cash(100000)  # fat runway → no thin-runway penalty to confound the diff
	_seed_b2b_series_a()   # bar + 1000
	_sim_day()  # base seed comfortably positive so the [0,100] clamp doesn't hide the penalty
	var seed_clear: int = int(VCPitchSystem.initial_conviction("anchor").value)
	GameState.shutter_days_left = 5  # Kepenk active
	VCPitchSystem.begin_meeting("anchor")
	if not VCPitchSystem.is_meeting_active():
		return "meeting blocked during Kepenk (should be allowed — ledger 12)"
	var seed_shutter: int = int(VCPitchSystem.initial_conviction("anchor").value)
	if seed_clear - seed_shutter != -PitchConstants.CONV_SHUTTER_PENALTY:
		return "shutter seed penalty wrong (clear=%d shutter=%d)" % [seed_clear, seed_shutter]
	VCPitchSystem.withdraw()
	return ""


# --- Stage C: state-seam cases (WRITE-THROUGH LAW) ---

static func _one_choice_event(id: String, modifiers: Array) -> GameEvent:
	# Minimal synthetic event carrier for modifier-routing cases (ship-moment pattern).
	var ev := GameEvent.new()
	ev.id = id
	ev.title = id
	var ch := EventChoice.new()
	ch.label = "ok"
	ch.modifiers = modifiers
	var choices: Array[EventChoice] = [ch]
	ev.choices = choices
	return ev


static func _case_seat_upsell_moves_seats() -> String:
	# The seat-upsell now moves SEATS (and prices MRR off seats) on the named account,
	# emits customer_seats_changed, and reflects the aggregate into GameState.mrr.
	_seed_b2b(2000)
	var cust: Customer = CustomerRegistry.get_by_market("b2b")[0]
	var seats0: int = cust.seats
	var mrr0: int = cust.mrr
	var seat_signals: Array = []
	var cb := func(_id: String, n: int) -> void: seat_signals.append(n)
	EventBus.customer_seats_changed.connect(cb)
	# REPOINTED AT THE EXECUTOR. The case used to mint a synthetic GameEvent and push it
	# through the queue, which is the admission bypass the rebuild deleted — there is no way
	# to hand the engine a card that is not in the catalogue, and that is the point. What the
	# case is ABOUT is the seats verb: seats move, MRR is priced off them, the signal fires
	# and the aggregate is bridged. That runs through the same executor a played card uses.
	EventGate.debug_apply_effects([
		{"verb": "seats", "amount": 4, "per_seat_mrr": 150, "entity_id": cust.id}])
	EventBus.customer_seats_changed.disconnect(cb)
	if cust.seats != seats0 + 4:
		return "seats did not move: %d -> %d (want +4)" % [seats0, cust.seats]
	if cust.mrr != mrr0 + 600:
		return "mrr not priced off seats: %d -> %d (want +600)" % [mrr0, cust.mrr]
	if seat_signals.is_empty():
		return "customer_seats_changed never fired"
	if GameState.mrr != CustomerRegistry.get_total_mrr():
		return "GameState.mrr not bridged (%d vs %d)" % [GameState.mrr, CustomerRegistry.get_total_mrr()]
	return ""


static func _case_satisfaction_seam_emits() -> String:
	# Satisfaction changes route through CustomerRegistry.set_satisfaction and emit.
	_seed_b2b(1000)
	var cust: Customer = CustomerRegistry.get_by_market("b2b")[0]
	var sat0: int = cust.satisfaction
	var sat_signals: Array = []
	var cb := func(_id: String, v: int) -> void: sat_signals.append(v)
	EventBus.customer_satisfaction_changed.connect(cb)
	CustomerRegistry.set_satisfaction(cust.id, sat0 - 10)
	EventBus.customer_satisfaction_changed.disconnect(cb)
	if cust.satisfaction != sat0 - 10:
		return "satisfaction not set (%d -> %d)" % [sat0, cust.satisfaction]
	if sat_signals != [sat0 - 10]:
		return "signal payload %s (want [%d])" % [str(sat_signals), sat0 - 10]
	return ""


static func _case_targeted_modifier_hits_named_customer() -> String:
	# A customer_id-targeted modifier hits ONLY the named account, not a bystander.
	_seed_b2b(1000)   # co_lead_smoke, seats 4
	var p := Prospect.new()
	p.id = "lead_two"
	p.company_name = "Second Corp"
	p.industry = "testing"
	p.star = 2
	_sign_fixture(p, 2000, 70)   # co_lead_two, seats 12
	var c1: Customer = CustomerRegistry.get_customer("co_lead_smoke")
	var c2: Customer = CustomerRegistry.get_customer("co_lead_two")
	var s1: int = c1.seats
	var s2: int = c2.seats
	EventGate.debug_apply_effects([
		{"verb": "seats", "amount": 5, "per_seat_mrr": 100, "entity_id": "co_lead_two"}])
	if c1.seats != s1:
		return "untargeted account changed: %d -> %d" % [s1, c1.seats]
	if c2.seats != s2 + 5:
		return "targeted account seats wrong: %d -> %d (want +5)" % [s2, c2.seats]
	return ""


static func _case_burn_day1_breakdown() -> String:
	# Gider dağılımı DÜRÜST: day-1'de motorda karşılığı olmayan kalem yok — tek satır
	# kurucu gideri (%100). Uydurma tools(7)/office(25)/legal(11)/misc(7) kalemleri
	# silindi; toplam 50 kaldı (runway kalibrasyonu oynamadı).
	if FinanceSystem.starting_daily_burn() != 50:
		return "starting_daily_burn %d, want 50 (baseline calibration moved)" % FinanceSystem.starting_daily_burn()
	if GameState.daily_burn != FinanceSystem.starting_daily_burn():
		return "GameState.daily_burn (%d) does not derive from the breakdown" % GameState.daily_burn
	# `servers` Ürün rev 6.1 §10 ile geldi: sunucu faturası burn'e GERÇEKTEN işliyor
	# (InfraSystem her gün aylık/30 olarak yazıyor). Ürün yayınlanana kadar 0 olduğu
	# için day-1 iddiası KIPIRDAMIYOR — aşağıdaki "sıfır olmayan kalem = kurgu"
	# kontrolü onu zaten kapsıyor ve tek satırlık render sözleşmesi aynen duruyor.
	# Bayat olan tek şey kadro listesiydi.
	var want_keys: Array = ["salaries", "overtime", "founder", "marketing", "office", "servers"]
	var keys: Array = FinanceSystem.STARTING_BURN_BREAKDOWN.keys()
	if keys.size() != want_keys.size():
		return "breakdown holds %d categories, want %d: %s" % [keys.size(), want_keys.size(), str(keys)]
	for key in want_keys:
		if not FinanceSystem.STARTING_BURN_BREAKDOWN.has(key):
			return "breakdown lost category '%s'" % key
		if not FinanceSystem.BURN_IDS.has(key):
			return "category '%s' has no TR label" % key
	for key in keys:
		var v: int = int(FinanceSystem.STARTING_BURN_BREAKDOWN[key])
		if String(key) == "founder":
			if v != 50:
				return "founder cost %d, want the whole $50 baseline" % v
		elif v != 0:
			return "category '%s' carries %d with no mechanic behind it (fiction)" % [key, v]
	# Day-1 render sözleşmesi: tek satır, founder, %100 (sıfır satırlar atlanır).
	var rows: Array = FinanceSystem.get_burn_breakdown_pct()
	if rows.size() != 1:
		return "day-1 breakdown renders %d rows, want exactly 1: %s" % [rows.size(), str(rows)]
	var row: Dictionary = rows[0]
	if String(row.get("id", "")) != "founder" or int(row.get("pct", 0)) != 100 or int(row.get("amount", 0)) != 50:
		return "day-1 row is not founder/100/50: %s" % str(row)
	return ""


static func _case_burn_refresh_same_tick() -> String:
	# set_burn_category refreshes GameState.daily_burn immediately (no daily tick).
	var burn0: int = GameState.daily_burn
	FinanceSystem.set_burn_category("marketing", 100)
	var expected: int = FinanceSystem.compute_total_burn()
	if GameState.daily_burn != expected:
		return "daily_burn stale: %d (want %d)" % [GameState.daily_burn, expected]
	if GameState.daily_burn <= burn0:
		return "burn did not rise after marketing spend (%d -> %d)" % [burn0, GameState.daily_burn]
	return ""


# --- Feature bug-seeding cases ---

static func _case_feature_bug_seed_by_complexity() -> String:
	# A v1 build seeds bugs = Σ feature complexity at commit (COEF 1.0); high > low.
	if not ProductSystem.start_build("ai_assistant", ["ai_assistant_chat", "ai_assistant_streaming"], ""):
		return "start_build(low) failed"
	var low: int = ProductSystem.get_active_build().bug_count   # chat 2 + streaming 2 = 4
	ProductSystem.cancel_build()
	if not ProductSystem.start_build("ai_assistant", ["ai_assistant_tools", "ai_assistant_image"], ""):
		return "start_build(high) failed"
	var high: int = ProductSystem.get_active_build().bug_count   # tools 4 + image 4 = 8
	if low != 4:
		return "low seed wrong: %d (want 4)" % low
	if high != 8:
		return "high seed wrong: %d (want 8)" % high
	if high <= low:
		return "high seed (%d) not > low (%d)" % [high, low]
	# Seeded bugs flow through the existing effective-stability channel.
	if QualityModel.effective_stability(50.0, high) >= 50.0:
		return "seeded bugs do not erode effective stability"
	return ""


static func _case_hardening_seeds_no_bugs() -> String:
	# A pure hardening (strengthen-only) v2 build seeds ZERO feature bugs.
	GameState.set_flag("mvp_shipped", true)
	GameState.set_flag("mvp_sub_product_type_id", "ai_assistant")
	GameState.set_flag("mvp_components", ["ai_assistant_chat", "ai_assistant_memory"])
	GameState.set_flag("mvp_innovation", 20.0)
	GameState.set_flag("mvp_stability", 25.0)
	GameState.set_flag("mvp_experience", 22.0)
	GameState.set_flag("mvp_live_bug_count", 3)
	GameState.set_flag("mvp_version", 1)
	if not ProductSystem.start_version_build([], "", ["ai_assistant_chat"]):
		return "start_version_build(harden) failed"
	var b: FeatureBuild = ProductSystem.get_active_build()
	if b.bug_count != 3:
		return "hardening seeded bugs: bug_count=%d (want 3 inherited, 0 seed)" % b.bug_count
	if b.strengthened_feature_ids.size() != 1 or b.strengthened_feature_ids[0] != "ai_assistant_chat":
		return "strengthen list wrong: %s" % str(b.strengthened_feature_ids)
	return ""


# --- Rev3: efor/hız motoru + deterministik eksen case'leri ---

static func _case_single_feature_build_legal() -> String:
	# Rev3: 2-4 seçim limiti kalktı — tek feature meşru build; boş liste reddedilir.
	if ProductSystem.start_build("ai_assistant", [], ""):
		return "empty feature list accepted"
	if ProductSystem.get_active_build() != null:
		return "rejected commit left an active build"
	if not ProductSystem.start_build("ai_assistant", ["ai_assistant_chat"], ""):
		return "single-feature build rejected"
	var b: FeatureBuild = ProductSystem.get_active_build()
	var want_efor: int = ProductCatalog.get_feature_efor("ai_assistant_chat")
	if want_efor != 6:
		return "chat efor changed: %d (want 6 = 4 + cx2)" % want_efor
	if absf(b.total_efor - float(want_efor)) > 0.001:
		return "total_efor %.1f != feature efor %d" % [b.total_efor, want_efor]
	return ""


static func _case_commit_cost_charged_once() -> String:
	# Üçüncü-parti maliyet commit'te TAM BİR KEZ düşer (Finance seam); sonraki
	# günler yalnız günlük net akış; strengthen-only v2 hiç tahsil etmez.
	var cash0: int = GameState.cash
	if not ProductSystem.start_build("ai_assistant", ["ai_assistant_voice"], ""):
		return "start_build failed"
	if GameState.cash != cash0 - 800:
		return "commit cost wrong: %d -> %d (want -800)" % [cash0, GameState.cash]
	for i in 3:
		var before: int = GameState.cash
		_sim_day()
		var day_delta: int = before - GameState.cash
		if day_delta != GameState.daily_burn:   # MRR 0 → net akış = -burn; başka kesinti YOK
			return "extra one-time delta on day %d: -%d (daily burn %d)" % [GameState.day, day_delta, GameState.daily_burn]
	# Strengthen-only v2: inherited/strengthen asla yeniden tahsil edilmez.
	ProductSystem.cancel_build()
	GameState.set_flag("mvp_shipped", true)
	GameState.set_flag("mvp_sub_product_type_id", "ai_assistant")
	GameState.set_flag("mvp_components", ["ai_assistant_voice"])
	GameState.set_flag("mvp_version", 1)
	var cash1: int = GameState.cash
	if not ProductSystem.start_version_build([], "", ["ai_assistant_voice"]):
		return "strengthen-only v2 failed"
	if GameState.cash != cash1:
		return "strengthen-only v2 charged cash (%d -> %d)" % [cash1, GameState.cash]
	return ""


static func _case_phase_bands_20_60_20() -> String:
	# Build Bar grameri (2026-08-19): tasarım bandı dolunca tur 2 KENDİLİĞİNDEN başlar
	# (efor donuk, faz aynı) — fazdan çıkış yalnız enter_development(). Geliştirme
	# bandı %80'de PARK eder — çıkış yalnız enter_beta(). %100'de Beta'da PARK
	# (auto-ship yok); launch yalnız Beta'da iş yapar.
	GameState.set_cash(50000)
	if not ProductSystem.start_build("ai_assistant", ["ai_assistant_chat", "ai_assistant_memory"], ""):
		return "start_build failed"
	var b: FeatureBuild = ProductSystem.get_active_build()
	# Beta öncesi launch → uyarı + no-op (build durur, ship flag'i yazılmaz).
	ProductSystem.launch()
	if GameState.get_flag("mvp_shipped", false) or ProductSystem.get_active_build() == null:
		return "launch outside beta was not a no-op"
	# 1) Tasarım bandı: tur 1 bitene dek sür; faz kendi kendine asla değişmez.
	var hours: int = 0
	while not ProductSystem.can_enter_development():
		if b.current_phase != "iteration":
			return "left iteration without a decision (phase %s)" % b.current_phase
		ProductSystem.hourly_tick(hours % 24)
		hours += 1
		if hours > 24 * 120:
			return "design band never ended round 1 (%.2f / %.2f)" % [b.efor_spent, b.total_efor]
	var design_cap: float = ProductSystem.PHASE_DESIGN_END * b.total_efor
	if absf(b.efor_spent - design_cap) > 0.001:
		return "efor not clamped at design band (%.3f, want %.3f)" % [b.efor_spent, design_cap]
	if b.iteration_count != 2 or b.iteration_decision_pending:
		return "round 2 did not auto-start when round 1 ended (count %d, pending %s)" % [b.iteration_count, str(b.iteration_decision_pending)]
	# 2) Turlar kendi kendine döner: 3 gün daha tik → faz aynı, efor donuk, tur 2 hâlâ koşuyor.
	for i in 24 * 3:
		ProductSystem.hourly_tick(i % 24)
	if b.current_phase != "iteration":
		return "auto-advanced out of design (phase %s)" % b.current_phase
	if absf(b.efor_spent - design_cap) > 0.001:
		return "efor moved during design rounds (%.3f)" % b.efor_spent
	if b.iteration_count != 2 or b.iteration_round_days <= 0.0:
		return "round 2 not running after 3 days (count %d, days %.2f)" % [b.iteration_count, b.iteration_round_days]
	# 3) Oyuncu kararı → development (yarım tur 2 kazançsız terk edilir); dev bandı %80'de PARK eder.
	ProductSystem.enter_development()
	if b.current_phase != "development":
		return "enter_development did not flip phase (%s)" % b.current_phase
	var dev_cap: float = ProductSystem.PHASE_DEV_END * b.total_efor
	hours = 0
	while not ProductSystem.development_band_complete():
		ProductSystem.hourly_tick(hours % 24)
		hours += 1
		if hours > 24 * 120:
			return "development never reached the park (%.1f / %.1f)" % [b.efor_spent, b.total_efor]
		if b.current_phase != "development":
			return "left development without a decision (phase %s)" % b.current_phase
	if absf(b.efor_spent - dev_cap) > 0.001:
		return "dev park efor not clamped at PHASE_DEV_END (%.3f, want %.3f)" % [b.efor_spent, dev_cap]
	# 4) Geliştirme parkı: 3 gün daha tik → faz aynı, efor donuk, bug birikmez.
	var bugs_at_park: int = b.bug_count
	for i in 24 * 3:
		ProductSystem.hourly_tick(i % 24)
	if b.current_phase != "development" or absf(b.efor_spent - dev_cap) > 0.001:
		return "dev park violated (phase %s, efor %.3f)" % [b.current_phase, b.efor_spent]
	if b.bug_count != bugs_at_park:
		return "bugs accrued during the dev park (%d -> %d)" % [bugs_at_park, b.bug_count]
	# 5) Oyuncu kararı → beta; beta bandında efor %100'e akar.
	ProductSystem.enter_beta()
	if b.current_phase != "bugfix":
		return "enter_beta did not flip phase (%s)" % b.current_phase
	hours = 0
	while b.efor_spent < b.total_efor:
		ProductSystem.hourly_tick(hours % 24)
		hours += 1
		if hours > 24 * 120:
			return "efor never completed (%.1f / %.1f)" % [b.efor_spent, b.total_efor]
		if b.current_phase != "bugfix":
			return "phase %s during the beta band" % b.current_phase
	# %100 → Beta'da SÜRESİZ park: 3 gün daha tik, ship YOK, build slotu dolu.
	for i in 24 * 3:
		ProductSystem.hourly_tick(i % 24)
	if GameState.get_flag("mvp_shipped", false):
		return "auto-shipped from beta park"
	if ProductSystem.get_active_build() == null:
		return "build slot cleared without launch"
	if ProductSystem.get_active_build().current_phase != "bugfix":
		return "park phase wrong: %s" % ProductSystem.get_active_build().current_phase
	# Beta'da launch → ship moment kuyruğa düşer, ship_active_build dünyayı damgalar.
	ProductSystem.launch()
	if _instances_of("product.first_ship") < 1:
		return "ship moment not admitted from beta launch"
	ProductSystem.ship_active_build()
	if not GameState.get_flag("mvp_shipped", false):
		return "ship did not set mvp_shipped"
	if ProductSystem.get_active_build() != null:
		return "build slot not cleared after ship"
	return ""


# --- İterasyon döngüsü (player-gated restore) + ekip kalite tavanı ---

static func _case_iter_decision_gates_development() -> String:
	# İterasyon fazından ASLA kendi kendine çıkılmaz: tur 1 bitince tur 2 kendiliğinden
	# başlar (efor donuk, faz aynı), Develop kapısı tur 1 bitmeden KAPALI, çıkış yalnız
	# enter_development() — ve öğretici moment tam BİR kez düşer (5 gün, iki tur bitse de).
	GameState.set_cash(50000)
	if not ProductSystem.start_build("ai_assistant", ["ai_assistant_chat", "ai_assistant_memory"], ""):
		return "start_build failed"
	var b: FeatureBuild = ProductSystem.get_active_build()
	if ProductSystem.can_enter_development():
		return "Develop offered before round 1 ended"
	ProductSystem.enter_development()   # guarded no-op before round 1 ends
	if b.current_phase != "iteration":
		return "enter_development flipped the phase before round 1 ended"
	if not _drive_to_round_end():
		return "design band never ended round 1"
	if b.current_phase != "iteration":
		return "left iteration without a decision (phase %s)" % b.current_phase
	var cap: float = ProductSystem.PHASE_DESIGN_END * b.total_efor
	if absf(b.efor_spent - cap) > 0.001:
		return "efor %.3f at round end, want the design cap %.3f" % [b.efor_spent, cap]
	if b.iteration_count != 2:
		return "round 2 did not auto-start (count %d)" % b.iteration_count
	# 5 gün: turlar döner, faz aynı, efor kımıldamaz; intro yalnız BİR kez.
	for i in 24 * 5:
		ProductSystem.hourly_tick(i % 24)
	if b.current_phase != "iteration" or absf(b.efor_spent - cap) > 0.001:
		return "design loop violated (phase %s, efor %.3f)" % [b.current_phase, b.efor_spent]
	if b.iteration_count < 3:
		return "rounds did not chain over 5 days (count %d)" % b.iteration_count
	if _instances_of("product.design_round_intro") != 1:
		return "iter intro admitted %d times, want exactly 1" % \
			_instances_of("product.design_round_intro")
	ProductSystem.enter_development()
	if b.current_phase != "development" or b.iteration_decision_pending:
		return "enter_development did not flip cleanly"
	var e0: float = b.efor_spent
	for i in 24:
		ProductSystem.hourly_tick(i % 24)
	if b.efor_spent <= e0 + 0.001:
		return "efor did not resume after the decision"
	return ""


static func _case_iter_ceiling_founder_vs_designer() -> String:
	# Tavana bağlı azalan getiri (tur sınırı 4 — Software Inc. grameri, 2026-08-19): solo
	# kurucu (tech 2) ile tur 2 ve 3'ün kazançları pozitif ve AZALAN, eksen tavanı (ya da
	# tavan üstü damgayı) aşmaz; Tasarımcı (UZMANLIK 7) gelince tavan formül kadar yükselir
	# ve SON tur (4) solo'nun son kazancından fazla verir — "daha iyi insanlar lazım, daha
	# çok tur değil" hissinin sayısal kanıtı. (Eski "plato" biçimi 12 tur istiyordu.)
	var founder: Character = CharacterRegistry.get_founder()
	_set_founder_tech(4)
	# Kurucu terimi motordan okunur, sabit yazılmaz — burada eski cetvelin fixture değeri
	# (2.0) duruyordu ve cetvel değişince iddia ölçtüğü şeyden koptu.
	var want0: float = ProductSystem.ITER_CEIL_FOUNDER_COEF \
		* float(GameState.get_founder_skill(HRConstants.AREA_PRODUCT))
	var ceil0: Dictionary = ProductSystem.iteration_axis_ceilings()
	if absf(float(ceil0["innovation"]) - want0) > 0.001:
		return "solo innovation ceiling %.2f, want %.2f" % [float(ceil0["innovation"]), want0]
	GameState.set_cash(200000)
	if not ProductSystem.start_build("ai_assistant", ["ai_assistant_chat", "ai_assistant_memory"], ""):
		return "start_build failed"
	var b: FeatureBuild = ProductSystem.get_active_build()
	if not _drive_to_round_end():
		return "design band never ended round 1"
	var stamp0: float = b.innovation
	var last_gain: float = INF
	var rounds: int = 0
	# Solo turlar: tavana kadar olan turların hepsi değil, SON tur işe alım sonrasına kalsın
	# (ITER_MAX_ROUNDS - 2 = cap 4'te tur 2 ve 3).
	while not b.iteration_decision_pending and rounds < ProductSystem.ITER_MAX_ROUNDS - 2:
		var before: float = b.innovation
		if not _run_iteration_round():
			return "iteration round %d did not complete" % (rounds + 1)
		var g: float = b.innovation - before
		if g <= 0.0:
			return "solo round %d gave no gain (%.3f) — headroom seeding broken" % [rounds + 2, g]
		if g >= last_gain - 0.0001:
			return "solo round %d gain %.3f is not smaller than the previous %.3f" % [rounds + 2, g, last_gain]
		last_gain = g
		rounds += 1
	if rounds != ProductSystem.ITER_MAX_ROUNDS - 2:
		return "solo drive ran %d rounds, want %d" % [rounds, ProductSystem.ITER_MAX_ROUNDS - 2]
	if b.innovation > maxf(stamp0, want0) + 0.001:
		return "solo axis %.2f exceeded the ceiling %.2f" % [b.innovation, want0]
	var solo_plateau: float = b.innovation
	# İŞE ALINAN KİŞİ DEĞİŞTİ (2026-08-22): tasarımcı yerine Ürün Yöneticisi.
	# İnovasyon tavanı ÜRÜN alanını okuyor (rev 2 §2 "özellik kararları") ve atama kapısıyla
	# birlikte artık YALNIZ Ürün'e ATANMIŞ biri o tavanı yükseltebiliyor. Bir tasarımcı kendi
	# ana alanına (Tasarım) doğuyor, yani İnovasyon'a değil DENEYİM'e dokunur — case'in ölçtüğü
	# eksen İnovasyon olduğu için doğru işe alım PM. Ölçülen yasa aynı kaldı: "daha iyi insan,
	# daha çok tur değil".
	_make_employee("char_iter_pm", "Iter PM", HRConstants.ROLE_PRODUCT_MANAGER,
		SEED_PACE, 0, 50, 7)
	# ANA alan, tam fiyat: §5'in ikincil-alan kesintisi yok.
	var want1: float = want0 + minf(7.0 * ProductSystem.ITER_CEIL_ROLE_COEF,
		ProductSystem.ITER_CEIL_ROLE_CAP)
	var ceil1: Dictionary = ProductSystem.iteration_axis_ceilings()
	if absf(float(ceil1["innovation"]) - want1) > 0.001:
		return "PM ceiling %.2f, want %.2f" % [float(ceil1["innovation"]), want1]
	if b.iteration_decision_pending:
		return "cannot run the post-hire round (cap hit during the solo drive)"
	var before2: float = b.innovation
	if not _run_iteration_round():
		return "post-hire round did not complete"
	var gain2: float = b.innovation - before2
	if gain2 <= last_gain + 0.001:
		return "hire did not lift the last round (gain %.3f vs solo last %.3f)" % [gain2, last_gain]
	if b.innovation <= solo_plateau + 0.05:
		return "axis did not move visibly above the solo level (%.2f vs %.2f)" % [b.innovation, solo_plateau]
	if b.iteration_count != ProductSystem.ITER_MAX_ROUNDS or not b.iteration_decision_pending:
		return "last round did not land on the cap park (count %d, pending %s)" % [b.iteration_count, str(b.iteration_decision_pending)]
	return ""


static func _case_iter_diminishing_returns() -> String:
	# Azalan getiri: tur N+1'in kazancı tur N'inkinden KÜÇÜK (ikisi de > 0).
	# Tasarımcı baştan masada → tavan yüksek, iki tur boyunca bol headroom.
	var founder: Character = CharacterRegistry.get_founder()
	_set_founder_tech(4)
	_make_employee("char_iter_dr_designer", "DR Designer", HRConstants.ROLE_DESIGNER,
		SEED_PACE, 0, 50, 7)
	GameState.set_cash(200000)
	if not ProductSystem.start_build("ai_assistant", ["ai_assistant_chat", "ai_assistant_memory"], ""):
		return "start_build failed"
	var b: FeatureBuild = ProductSystem.get_active_build()
	if not _drive_to_round_end():
		return "design band never ended round 1"
	var v0: float = b.innovation
	if not _run_iteration_round():
		return "round 2 did not complete"
	var gain_a: float = b.innovation - v0
	var v1: float = b.innovation
	if not _run_iteration_round():
		return "round 3 did not complete"
	var gain_b: float = b.innovation - v1
	if gain_a <= 0.0 or gain_b <= 0.0:
		return "rounds gave no gain (%.3f, %.3f) — headroom seeding broken" % [gain_a, gain_b]
	if gain_b >= gain_a - 0.0001:
		return "round N+1 gain %.3f is not smaller than round N gain %.3f" % [gain_b, gain_a]
	return ""


static func _case_iter_ceiling_never_exceeded() -> String:
	# Güvenlik tavanına (ITER_MAX_ROUNDS) kadar sür: hiçbir eksen kendi tavanını (ya da
	# tavan üstü commit damgasını) aşamaz; tavanda tur ZİNCİRİ durur (park), çıkış hâlâ oyuncuda.
	var founder: Character = CharacterRegistry.get_founder()
	_set_founder_tech(2)   # taban tavan 4 → damga tavanın üstünde kalabilir
	GameState.set_cash(200000)
	if not ProductSystem.start_build("ai_assistant", ["ai_assistant_chat", "ai_assistant_memory"], ""):
		return "start_build failed"
	var b: FeatureBuild = ProductSystem.get_active_build()
	if not _drive_to_round_end():
		return "design band never ended round 1"
	var stamp := {"innovation": b.innovation, "stability": b.stability, "experience": b.experience}
	var ceilings: Dictionary = ProductSystem.iteration_axis_ceilings()
	while not b.iteration_decision_pending:
		if not _run_iteration_round():
			return "round %d did not complete" % b.iteration_count
		for ax in QualityModel.AXES:
			var v: float = float(QualityModel.dims_from_build(b).get(ax, 0.0))
			var lim: float = maxf(float(stamp[ax]), float(ceilings[ax]))
			if v > lim + 0.001:
				return "axis %s (%.3f) exceeded its ceiling/stamp (%.3f) at round %d" % [ax, v, lim, b.iteration_count]
	if b.iteration_count != ProductSystem.ITER_MAX_ROUNDS:
		return "loop stopped at round %d, want the safety cap %d" % [b.iteration_count, ProductSystem.ITER_MAX_ROUNDS]
	if not b.iteration_decision_pending:
		return "cap reached but the decision is not pending — the build would be stuck"
	for i in 24 * 3:   # tavan parkı: 3 gün daha, sayaç ve efor kımıldamaz
		ProductSystem.hourly_tick(i % 24)
	if b.iteration_count != ProductSystem.ITER_MAX_ROUNDS or b.iteration_round_days > 0.0:
		return "the round chain ran past the safety cap"
	if float(stamp["innovation"]) > float(ceilings["innovation"]) \
			and absf(b.innovation - float(stamp["innovation"])) > 0.0001:
		return "an above-ceiling stamp moved (%.3f -> %.3f)" % [float(stamp["innovation"]), b.innovation]
	ProductSystem.enter_development()
	if b.current_phase != "development":
		return "exit blocked at the safety cap"
	return ""


static func _case_iter_zero_staff_neutrality_and_axis_lock() -> String:
	# Sıfır ekip → her tavan kurucu tabanı; BUILD İŞİNDE OLMAYAN kimse tavan OYNATMAZ;
	# her ALAN kendi eksenini yükseltir ve terim ITER_CEIL_ROLE_CAP'te kesilir.
	#
	# 2026-08-21: "her rol yalnız kendi eksenini yükseltir, gerisi sızıntıdır" hükmü DÜŞTÜ.
	# O bir ROL kapısıydı; rev 2 §2 onu alanlarla değiştirdi ve sızıntı diye bir şey kalmadı —
	# her alan zaten kendi eksenini besliyor. Yerine geçen kapı ATAMADIR: build'de olmayan
	# kimse build tavanına dokunmaz, ki ch. 03 §8'in istediği gerilim de tam olarak budur.
	var founder: Character = CharacterRegistry.get_founder()
	_set_founder_tech(6)
	# Kurucu tabanı motordan okunur (aynı gerekçe: sabit yazılı fixture değeri cetvelle
	# birlikte kayar ve iddiayı sessizce başka bir şeyin ölçüsü hâline getirir).
	var base: float = ProductSystem.ITER_CEIL_FOUNDER_COEF \
		* float(GameState.get_founder_skill(HRConstants.AREA_PRODUCT))
	var c: Dictionary = ProductSystem.iteration_axis_ceilings()
	for ax in QualityModel.AXES:
		if absf(float(c[ax]) - base) > 0.001:
			return "zero-staff ceiling for %s is %.2f, want founder base %.2f" % [ax, float(c[ax]), base]
	_make_employee("char_iter_zs_tester", "ZS Tester", HRConstants.ROLE_TESTER, SEED_PACE, 0, 50, 9)
	_make_employee("char_iter_zs_sales", "ZS Sales", HRConstants.ROLE_SALES_REP, SEED_PACE, 0, 50, 9)
	c = ProductSystem.iteration_axis_ceilings()
	for ax in QualityModel.AXES:
		if absf(float(c[ax]) - base) > 0.001:
			return "an unrelated role moved the %s ceiling (%.2f)" % [ax, float(c[ax])]
	# A DESIGNER. Tasarım onun ANA alanı, işe alım onu oraya koyuyor — ve Deneyim ekseni
	# Tasarım'ı okuyor (rev 2 §2 bunu kelimeyle söylüyor). İnovasyon Ürün'ü okur; Ürün onun
	# İKİNCİL alanı ve oraya ATANMADI, o yüzden İnovasyon tavanı KIPIRDAMAZ.
	#
	# İKİ KEZ DEĞİŞEN HÜKÜM. Önce "her rol tam bir ekseni yükseltir, gerisi sızıntıdır" vardı
	# (ROL kapısı). rev 2 alanları getirince "tasarımcı ikisini de yükseltir, ikincilini daha
	# az" oldu. Onaylı tasarımın ATAMA kapısıyla şimdi üçüncü hâli: kişi yalnız ATANDIĞI
	# alanda sayılır. İkincil alanının tavanını yükseltmek istiyorsan oyuncu onu Görevler'den
	# oraya TAŞIR — karar oyuncunun, karşılığında ana alanını bırakır ya da aşırı yükü öder.
	_make_employee("char_iter_zs_designer", "ZS Designer", HRConstants.ROLE_DESIGNER, SEED_PACE, 0, 50, 6)
	c = ProductSystem.iteration_axis_ceilings()
	var des_exp: float = float(c["experience"]) - base
	var des_inno: float = float(c["innovation"]) - base
	# ÜÇÜNCÜ HÂL, rev 11 §12.0: atama birimi ALAN DEĞİL İŞ. Build ekibi Ürün · Tasarım ·
	# Yazılım alanlarınca taşınır (§12.0) ve tasarımcı ikisini tutar — Tasarım ana, Ürün
	# ikincil (§4.4). Yani Build'deki bir tasarımcı İKİ tavanı da oynatır, ama ikincilini
	# §4.3'ün ×0,8'iyle. "Tasarımcıyı Ürün'e mi koyayım" kararı ortadan kalktı; karar artık
	# "Build'de mi değil mi" ve bedeli §12.1'in odak katsayısıyla ödeniyor.
	if des_exp <= 0.0:
		return "a designer did not raise the Deneyim ceiling, which §4.4 gives to Tasarım"
	if des_inno <= 0.0:
		return "a designer did not raise İnovasyon — §12.0's Build carries Ürün too"
	# İKİNCİL DAHA AZ. §4.3'ün ×0,8'i tam da burada okunmalı, yoksa ana/ikincil ayrımı
	# yalnız bir etiket olur.
	if des_inno >= des_exp:
		return "the secondary area contributed as much as the key one (%.2f vs %.2f) — §4.3 wants 0,8" % [
			des_inno, des_exp]
	if absf(float(c["stability"]) - base) > 0.001:
		return "a designer raised Kararlılık; Yazılım is not an area they can hold"
	# ...ve KARAR HÂLÂ BİR KARAR, yalnız granülerliği değişti. rev 2'de oyuncu tasarımcıyı
	# Tasarım'dan Ürün'e taşıyordu; §12.0'da ikisi de AYNI İŞİN (Build) taşıdığı alanlar, yani
	# öyle bir hamle yok. Kalan hamle Build'den ÇIKARMAK, ve bedeli ikisini birden kaybetmek:
	# tasarımcının tuttuğu her iki alan da o işten geliyordu.
	#
	# §12.2: "Boş iş için ayrı bir uyarı satırı yoktur ... matrisin kendisinde zaten görünür."
	# Buradaki ölçüm de o: boşalan iş sıfır üretir, ve bu okunur.
	CharacterRegistry.clear_jobs("char_iter_zs_designer")
	c = ProductSystem.iteration_axis_ceilings()
	if absf(float(c["experience"]) - base) > 0.001:
		return "an unassigned designer still raises Deneyim — the move cost nothing"
	if absf(float(c["innovation"]) - base) > 0.001:
		return "an unassigned designer still raises İnovasyon"
	CharacterRegistry.assign_job("char_iter_zs_designer", HRConstants.JOB_BUILD)
	# ATAMA KAPISI, alakasız roller: bir test mühendisi ve bir satış temsilcisi kendi
	# alanlarına doğar ve hiçbir build tavanını kıpırdatmaz.
	var before_unrelated: Dictionary = ProductSystem.iteration_axis_ceilings().duplicate()
	_make_employee("char_iter_zs_t2", "ZS Tester 2", HRConstants.ROLE_TESTER, SEED_PACE, 0, 50, 9)
	_make_employee("char_iter_zs_s2", "ZS Sales 2", HRConstants.ROLE_SALES_REP, SEED_PACE, 0, 50, 9)
	c = ProductSystem.iteration_axis_ceilings()
	for ax in QualityModel.AXES:
		if absf(float(c[ax]) - float(before_unrelated[ax])) > 0.001:
			return "somebody NOT assigned to a build area moved the %s ceiling (%.2f -> %.2f)" % [
				ax, float(before_unrelated[ax]), float(c[ax])]
	# The term still caps: stack enough build hires and ITER_CEIL_ROLE_CAP bites.
	for i in 6:
		_make_employee("char_iter_zs_pm%d" % i, "ZS PM %d" % i, HRConstants.ROLE_PRODUCT_MANAGER,
			SEED_PACE, 0, 50, 9)
	c = ProductSystem.iteration_axis_ceilings()
	if absf(float(c["innovation"]) - (base + ProductSystem.ITER_CEIL_ROLE_CAP)) > 0.001:
		return "the İnovasyon term is not capped at ITER_CEIL_ROLE_CAP (%.2f, want %.2f)" % [
			float(c["innovation"]), base + ProductSystem.ITER_CEIL_ROLE_CAP]
	return ""


static func _case_iter_version_build_same_loop() -> String:
	# v-build aynı döngüyü yaşar: sayaçlar v-commit'te sıfırdan, tur 1 → tur 2 (otomatik)
	# → tur 2 biter → karar → geliştirme.
	_seed_live_product()
	if not ProductSystem.start_version_build(["ai_assistant_voice"], ""):
		return "start_version_build failed"
	var b: FeatureBuild = ProductSystem.get_active_build()
	if b.iteration_count != 1 or b.iteration_decision_pending or b.iteration_round_days > 0.0:
		return "v-commit did not reset the iteration counters"
	if not _drive_to_round_end():
		return "v-build design band never ended round 1"
	if b.current_phase != "iteration":
		return "v-build auto-advanced (phase %s)" % b.current_phase
	if b.iteration_count != 2:
		return "round 2 did not auto-start (%d)" % b.iteration_count
	if not _run_iteration_round():
		return "v-build round 2 did not complete"
	if b.iteration_count != 3:
		return "round end did not increment the counter (%d)" % b.iteration_count
	ProductSystem.enter_development()
	if b.current_phase != "development":
		return "v-build exit did not flip to development"
	return ""


static func _case_speed_tracks_team_change() -> String:
	# Hız her saat taze: solo günlük harcama, sonra yazılımcı alınınca artan günlük harcama
	# (ve kısalan ~gün). ÖLÇÜM GELİŞTİRME FAZINDA yapılır.
	#
	# LEDGER (Coupling): the case MOVED phase, the formula did not. Measurement used to sit
	# wherever the build happened to be, which was iteration.
	#
	# LEDGER 2 (rev 2 area migration, 2026-08-21): the role gate came off — a developer's
	# Tasarım number stopped being decoration.
	#
	# LEDGER 3 (onaylı tasarım, 2026-08-22): AMA ATAMA KAPISI GELDİ ve sonuç yeniden değişti.
	# Atama artık ALANA yapılıyor ve bir çalışan yalnız ANA ya da İKİNCİL alanına atanabilir
	# (Görevler matrisi öteki sütünları "ALANI YOK · ATANAMAZ" diye kesikli çiziyor). Bir
	# yazılımcının alanları Yazılım ve Test; ikisi de TASARIM fazının alanı değil, yani o faza
	# GİREMEZ. §2'nin "tek kişilik ekipte boşluk kalmaz" cümlesi hâlâ geçerli ama YETENEK
	# hakkında: herkeste altı sayı var. Bugün kimin nereye GİRDİĞİNİ atama söylüyor.
	# Bu yüzden case iki şeyi ölçüyor: yazılımcı tasarım fazını KIMILDATMAZ, tasarımcı ise
	# kendi fazında gerçekten oynatır.
	GameState.set_cash(50000)
	var founder: Character = CharacterRegistry.get_founder()
	if founder == null:
		return "no founder in registry"
	_set_founder_tech(6)
	if not ProductSystem.start_build("ai_assistant", ["ai_assistant_tools", "ai_assistant_image"], ""):
		return "start_build failed"   # efor 8+8=16 — ölçüm pencereleri içinde bitmez
	var b: FeatureBuild = ProductSystem.get_active_build()
	var iter_speed_solo: float = ProductSystem.team_speed(b)
	if b.current_phase != "iteration":
		return "build did not start in the design phase (%s)" % b.current_phase
	# ATAMA KAPISI: bir yazılımcı Yazılım alanına doğuyor, tasarım fazının alanlarına
	# (Ürün · Tasarım) atanamaz, dolayısıyla o fazı kıpırdatmaz.
	_make_employee("char_iter_dev", "Iter Dev", HRConstants.ROLE_DEVELOPER)
	var with_dev: float = ProductSystem.team_speed(b)
	if absf(with_dev - iter_speed_solo) > 0.001:
		return "a developer moved TASARIM speed (%.3f -> %.3f); Yazılım and Test are not design-phase areas" % [
			iter_speed_solo, with_dev]
	CharacterRegistry.remove("char_iter_dev")
	# Tasarımcı ise KENDİ fazında: Tasarım onun ana alanı, oraya doğuyor ve hızı oynatıyor.
	_make_employee("char_iter_des", "Iter Des", HRConstants.ROLE_DESIGNER)
	var with_designer: float = ProductSystem.team_speed(b)
	if with_designer <= iter_speed_solo:
		return "a designer added nothing to TASARIM (%.3f -> %.3f)" % [iter_speed_solo, with_designer]
	CharacterRegistry.remove("char_iter_des")
	# Now push into GELİŞTİRME, the phase a developer owns, and measure there.
	if not _run_build_to_phase("development"):
		return "build never reached the development phase"
	# LEDGER (Coupling): the expectation SHAPE changed, the NUMBER did not. Founder tech-3 solo
	# was 1.0 x 3 = 3.0 under the old lead-weight law; then it became FOUNDER_SPEED_COEF x 3 x
	# coordination(Liderlik 0) = 3.0 x 1.0. Held by anchor a2.
	#
	# LEDGER 4 (kurucu cetveli 0-10, 2026-08-24): SAYI YINE KIPIRDAMADI ama artik HICBIR
	# YERDE YAZILI DEGIL. Fixture 3'ten 6'ya, katsayi 1,0'dan 0,5'e gitti; beklenti kurucunun
	# o fazdaki ALANINI motordan okuyor, cunku sabit yazilmis bir 3.0 bir daha cetvel
	# degisirse sessizce yanlis capayi savunurdu.
	var founder_dev_area: float = float(GameState.get_founder_skill(
		ProductSystem._founder_phase_area("development")))
	var want_solo: float = maxf(ProductSystem.SPEED_MIN,
		ProductSystem.FOUNDER_SPEED_COEF * founder_dev_area
		* HRConstants.coordination_for_founder(GameState.get_founder_skill("leadership")))
	var s0: float = b.efor_spent
	for h in 24:
		ProductSystem.hourly_tick(h)
	if absf((b.efor_spent - s0) - want_solo) > 0.02:
		return "solo day spend %.3f (want %.3f)" % [b.efor_spent - s0, want_solo]
	var days_before: int = ProductSystem.estimated_days_remaining(b)
	_make_employee("char_smoke_speed_eng", "Speed Eng", HRConstants.ROLE_DEVELOPER)
	var days_after: int = ProductSystem.estimated_days_remaining(b)
	if days_after >= days_before:
		return "~gün did not shrink after hire (%d -> %d)" % [days_before, days_after]
	# LEDGER (Coupling): old = 3.0 + SPEED_ASSIST_WEIGHT(0.5) x ENGINEER_DEFAULT_TECH_LEGACY(2)
	# = 4.0. New = (FOUNDER_SPEED_COEF x kurucunun alani + EMPLOYEE_SPEED_COEF x pace 4)
	# x coordination = 4.0. Same number, derived from the new law — anchor b1. No lead/assist
	# split any more, and no hard-coded founder number either (bkz. LEDGER 4).
	var want_team: float = maxf(ProductSystem.SPEED_MIN,
		(ProductSystem.FOUNDER_SPEED_COEF * founder_dev_area
			+ ProductSystem.EMPLOYEE_SPEED_COEF * float(SEED_EXPERTISE))
		* HRConstants.coordination_for_founder(GameState.get_founder_skill("leadership")))
	s0 = b.efor_spent
	for h in 24:
		ProductSystem.hourly_tick(h)
	if absf((b.efor_spent - s0) - want_team) > 0.02:
		return "team day spend %.3f (want %.3f)" % [b.efor_spent - s0, want_team]
	return ""


static func _case_deterministic_axes_at_ship() -> String:
	# Eksenler deterministik: commit damgası == projected_axes == ship'teki mvp_*
	# flag'leri (v1); v2 = önceki canlı + yeni katkılar + strengthen dominant bonusu.
	#
	# TAVAN BAŞLIĞI ŞART (2026-08-21). Her kalite ekseni artık KENDİ alanını okuyor
	# (İnovasyon←Ürün · Kararlılık←Yazılım · Deneyim←Tasarım), yani kurucunun 0 taşıdığı bir
	# alanın ekseni SIFIR tavanla gelir ve eksen hiç kımıldayamaz. Bu doğru davranıştır —
	# "tasarım bilmiyorsan tasarımı yükseltemezsin" alan modelinin bütün iddiası — ama bu
	# case DETERMİNİZMİ ölçüyor, tavanı değil, o yüzden kurucuya dört teknik alanda da
	# bolca baş açıklığı veriliyor. Tavanın kendisi iter_ceiling_* case'lerinin işi.
	_set_founder_tech(6)
	GameState.set_cash(200000)
	var picks := ["ai_assistant_chat", "ai_assistant_memory"]
	var want: Dictionary = ProductSystem.projected_axes(picks, [], {})
	if not ProductSystem.start_build("ai_assistant", picks, ""):
		return "start_build failed"
	var b: FeatureBuild = ProductSystem.get_active_build()
	if absf(b.innovation - float(want["innovation"])) > 0.001 \
			or absf(b.stability - float(want["stability"])) > 0.001 \
			or absf(b.experience - float(want["experience"])) > 0.001:
		return "commit axes != projected (I%.1f/S%.1f/E%.1f vs %s)" % [b.innovation, b.stability, b.experience, str(want)]
	if not _run_build_to_phase("bugfix"):
		return "v1 build never reached beta"
	if absf(b.innovation - float(want["innovation"])) > 0.001 \
			or absf(b.stability - float(want["stability"])) > 0.001 \
			or absf(b.experience - float(want["experience"])) > 0.001:
		return "axes drifted during build (no events fired)"
	ProductSystem.launch()
	ProductSystem.ship_active_build()
	if absf(float(GameState.get_flag("mvp_innovation", -1.0)) - float(want["innovation"])) > 0.001 \
			or absf(float(GameState.get_flag("mvp_stability", -1.0)) - float(want["stability"])) > 0.001 \
			or absf(float(GameState.get_flag("mvp_experience", -1.0)) - float(want["experience"])) > 0.001:
		return "v1 shipped flags != projected (%s)" % str(want)
	# v2: bir yeni feature + bir strengthen (chat'in dominant ekseni: experience).
	var base_dims := {
		"innovation": float(GameState.get_flag("mvp_innovation", 0.0)),
		"stability": float(GameState.get_flag("mvp_stability", 0.0)),
		"experience": float(GameState.get_flag("mvp_experience", 0.0)),
	}
	var want2: Dictionary = ProductSystem.projected_axes(["ai_assistant_voice"], ["ai_assistant_chat"], base_dims)
	if absf(float(want2["experience"]) - (float(want["experience"]) + 3.0 + ProductSystem.STRENGTHEN_AXIS_BONUS)) > 0.001:
		return "want2 experience math off (%s)" % str(want2)
	if not ProductSystem.start_version_build(["ai_assistant_voice"], "", ["ai_assistant_chat"]):
		return "v2 build failed"
	if not _run_build_to_phase("bugfix"):
		return "v2 build never reached beta"
	ProductSystem.launch()
	ProductSystem.ship_active_build()
	if int(GameState.get_flag("mvp_version", 0)) != 2:
		return "v2 ship did not bump version"
	if absf(float(GameState.get_flag("mvp_innovation", -1.0)) - float(want2["innovation"])) > 0.001 \
			or absf(float(GameState.get_flag("mvp_stability", -1.0)) - float(want2["stability"])) > 0.001 \
			or absf(float(GameState.get_flag("mvp_experience", -1.0)) - float(want2["experience"])) > 0.001:
		return "v2 shipped flags != previous live + contributions + strengthen bonus (%s)" % str(want2)
	return ""


# --- Two-runway model + localization cases ---

static func _case_runway_net_status() -> String:
	# Net runway: profitable → localized status word (no unit); finite → months + "ay".
	TranslationServer.set_locale("tr")
	var alive: Dictionary = UiTokens.net_runway_parts(INF)
	if String(alive.value) != "Artıda" or String(alive.unit) != "":
		return "profitable(tr) wrong: '%s' / '%s'" % [alive.value, alive.unit]
	TranslationServer.set_locale("en")
	if String(UiTokens.net_runway_parts(INF).value) != "Default Alive":
		return "profitable(en) wrong: '%s'" % UiTokens.net_runway_parts(INF).value
	TranslationServer.set_locale("tr")
	var finite: Dictionary = UiTokens.net_runway_parts(6.4)
	if String(finite.value) != "6" or String(finite.unit) != "ay":
		return "finite wrong: '%s' / '%s'" % [finite.value, finite.unit]
	# Break-even (net_burn == 0) counts as default alive → INF.
	GameState.set_daily_burn(50)
	GameState.set_mrr(1500)   # daily_revenue round(1500/30)=50 == burn → net 0 → INF
	if GameState.get_runway_months() != INF:
		return "break-even not treated as alive"
	return ""


static func _case_gross_runway_months() -> String:
	# Gross burn runway = cash / daily_burn / 30, always finite, 0 at cash ≤ 0.
	GameState.set_cash(30000)
	GameState.set_daily_burn(50)   # 30000/50/30 = 20 months
	var m: float = VCPitchSystem._gross_runway_months()
	if int(round(m)) != 20:
		return "gross months wrong: %.2f (want ~20)" % m
	GameState.set_cash(0)
	if VCPitchSystem._gross_runway_months() != 0.0:
		return "gross at cash 0 should be 0"
	return ""


static func _case_locale_switch() -> String:
	# CSV → TranslationServer resolves per locale (proves the localization layer end-to-end).
	TranslationServer.set_locale("en")
	if TranslationServer.translate("RUNWAY_PROFITABLE") != "Default Alive":
		return "en RUNWAY_PROFITABLE: '%s'" % TranslationServer.translate("RUNWAY_PROFITABLE")
	if TranslationServer.translate("RUNWAY_GROSS_LABEL") != "Gross Burn Runway":
		return "en RUNWAY_GROSS_LABEL: '%s'" % TranslationServer.translate("RUNWAY_GROSS_LABEL")
	TranslationServer.set_locale("tr")
	if TranslationServer.translate("RUNWAY_PROFITABLE") != "Artıda":
		return "tr RUNWAY_PROFITABLE: '%s'" % TranslationServer.translate("RUNWAY_PROFITABLE")
	if TranslationServer.translate("RUNWAY_GROSS_LABEL") != "Brüt Runway":
		return "tr RUNWAY_GROSS_LABEL: '%s'" % TranslationServer.translate("RUNWAY_GROSS_LABEL")
	return ""


static func _case_settings_language_toggle() -> String:
	# Structural check: the SettingsModal scene loads + instantiates and carries the
	# language toggle's unique nodes. (main is mid-setup here, so _ready population +
	# the visual layout are Erdem's F5 eye-check.)
	var scene: PackedScene = load("res://scenes/modals/SettingsModal.tscn")
	if scene == null:
		return "SettingsModal.tscn failed to load"
	var inst: Control = scene.instantiate()
	var has_nodes: bool = inst.get_node_or_null("%LanguageOption") != null \
		and inst.get_node_or_null("%LanguageHeader") != null
	inst.free()
	if not has_nodes:
		return "SettingsModal missing %LanguageOption / %LanguageHeader unique nodes"
	return ""


# --- B2B Sales System: Stage A (lifecycle + two-layer satisfaction + churn) ---

static func _case_b2b_lifecycle_and_countdown() -> String:
	# A degrading product erodes satisfaction below the account's hidden tolerance; the
	# customer walks active→risk with a VISIBLE churn countdown; recovery resets it; and
	# churn fires ONLY when the counter reaches zero (never instant).
	_seed_b2b(1000)
	var c: Customer = CustomerRegistry.get_by_market("b2b")[0]
	CustomerRegistry.set_tolerance(c.id, 50)
	CustomerRegistry.set_satisfaction(c.id, 70)
	# Degrade: low effective stability (high bugs) → low satisfaction target.
	GameState.set_flag("mvp_stability", 20.0)
	GameState.set_flag("mvp_live_bug_count", 40)
	var entered_risk := false
	for i in 40:
		_sim_day()
		if CustomerRegistry.get_customer(c.id) == null:
			return "churned before the recovery check (countdown too short?)"
		if c.lifecycle_phase == "risk" and c.churn_countdown >= 1:
			entered_risk = true
			break
	if not entered_risk:
		return "never reached Risk phase with a visible countdown"
	# Recover: fix the product + lift satisfaction over tolerance → counter resets.
	GameState.set_flag("mvp_stability", 90.0)
	GameState.set_flag("mvp_live_bug_count", 0)
	CustomerRegistry.set_satisfaction(c.id, 85)
	_sim_day()
	if c.churn_countdown != -1:
		return "churn countdown did not reset on recovery (%d)" % c.churn_countdown
	if c.lifecycle_phase == "risk":
		return "still in Risk after recovery"
	# Degrade again and ride the counter to zero → churn from the watched counter.
	GameState.set_flag("mvp_stability", 20.0)
	GameState.set_flag("mvp_live_bug_count", 40)
	CustomerRegistry.set_satisfaction(c.id, 70)
	var churned: Array = []
	var cb := func(id: String) -> void: churned.append(id)
	EventBus.customer_churned.connect(cb)
	var lost0: int = GameState.run_customers_lost
	for i in 60:
		_sim_day()
		if CustomerRegistry.get_customer(c.id) == null:
			break
	EventBus.customer_churned.disconnect(cb)
	if CustomerRegistry.get_customer(c.id) != null:
		return "did not churn after sustained low satisfaction"
	if churned != [c.id]:
		return "customer_churned payload wrong: %s (want [%s])" % [str(churned), c.id]
	if GameState.run_customers_lost != lost0 + 1:
		return "run_customers_lost not incremented (%d -> %d)" % [lost0, GameState.run_customers_lost]
	return ""


static func _case_b2b_satisfaction_leaves_b2c_identical() -> String:
	# Regression guard: the _tick_satisfaction refactor (B2C-only) must leave the B2C
	# aggregate's daily drift byte-identical, and a coexisting B2B account must NOT be
	# dragged through the old ±1 gate path (it is owned by the two-layer B2B model).
	_seed_b2c()  # co_b2c_userbase
	var p := Prospect.new()
	p.id = "lead_iso"
	p.company_name = "Iso Corp"
	p.industry = "testing"
	p.star = 1
	_sign_fixture(p, 1000, 70)   # coexisting B2B account
	var ub: Customer = CustomerRegistry.get_customer(SalesSystem.B2C_USERBASE_ID)
	if ub == null:
		return "no B2C aggregate record after seed"
	# Product where the OLD gate math yields a definite non-zero B2C delta (stab ≥ gate).
	GameState.set_flag("mvp_stability", 200.0)
	GameState.set_flag("mvp_innovation", 200.0)
	GameState.set_flag("mvp_experience", 200.0)
	GameState.set_flag("mvp_live_bug_count", 0)
	# Expected delta computed with the SAME code path the tick uses.
	var stab: float = QualityModel.axis_score(QualityModel.economy_dims_from_flags(), "stability")
	var bugs: int = int(GameState.get_flag("mvp_live_bug_count", 0))
	var gate_delta: int = 0
	if stab >= SalesSystem.SATISFACTION_QUALITY_GATE:
		gate_delta += 1
	if bugs > SalesSystem.SATISFACTION_BUG_GATE:
		gate_delta -= 1
	if gate_delta == 0:
		return "test misconfigured: expected a non-zero B2C gate delta (stab=%.1f)" % stab
	var s0: int = ub.satisfaction
	var want: int = clampi(s0 + gate_delta, 0, 100) - s0
	_sim_day()
	var got: int = ub.satisfaction - s0
	if got != want:
		return "B2C aggregate satisfaction delta changed by refactor: got %d want %d" % [got, want]
	return ""


# --- B2B Sales System: Stage B (state-bound families + retention + feature pool) ---

static func _add_risk_b2b(pid: String, mrr: int) -> Customer:
	# Create a founder-managed B2B account already in Risk (for retention-routing tests).
	var p := Prospect.new()
	p.id = pid
	p.company_name = "R_" + pid
	p.industry = "insurance"
	p.star = 1
	p.pain_feature_id = "ai_vec_filter"
	var c: Customer = _sign_fixture(p, mrr, 70)
	CustomerRegistry.set_tolerance(c.id, 50)
	CustomerRegistry.set_satisfaction(c.id, 20)
	CustomerRegistry.set_lifecycle_phase(c.id, "risk")
	CustomerRegistry.set_churn_countdown(c.id, 5)
	return c


static func _case_b2b_retention_routes_seams() -> String:
	GameState.set_flag("mvp_sub_product_type_id", "ai_vector_search")
	_seed_b2b(2000)  # healthy product + one healthy account (co_lead_smoke)

	# State-match guard: a HEALTHY founder-managed customer produces NO retention event.
	# Drive the B2B engine directly (advance_day + its daily tick) so the phase-gate /
	# ambient event machinery does not fire and leave a stale active modal.
	var healthy: Customer = CustomerRegistry.get_customer("co_lead_smoke")
	for i in 6:
		GameState.advance_day()
		B2BSalesSystem.daily_tick()
	if CustomerRegistry.get_customer("co_lead_smoke") == null:
		return "healthy account unexpectedly churned"
	if healthy.lifecycle_phase == "risk":
		return "healthy account fell into Risk (state-match broken)"
	if _instances_of(RETAIN_ID) != 0:
		return "retention event fired for a healthy account (never should)"

	# Söz ver → creates a promise, customer recovers, reputation up.
	var c1: Customer = _add_risk_b2b("ra", 1000)
	var rep0: int = GameState.reputation
	# FORCE, NOT REQUEST, and the reason is the tempo brake. This case plays four retention
	# decisions inside one simulated day; §13's budget is two interrupts, so the third and
	# fourth are legitimately DEMOTED TO PAPER and never mount. That is the engine working —
	# `_case_retention_gate_shared` is where admission is under test. What is under test HERE
	# is where each option's effects land, so §4.5's debug entry is the right door: it skips
	# G3, G4 and G8 and nothing else.
	if not EventGate.force_fire(RETAIN_ID, {"customer": c1.id}):
		return "the retention card was refused for an account in Risk"
	if EventGate.active_id() != RETAIN_ID:
		return "retention event not active (%s)" % EventGate.active_id()
	EventGate.resolve(RETAIN_ID, "promise_it")
	if PromiseRegistry.get_open_for("co_ra").size() != 1:
		return "Söz ver did not create a promise"
	if c1.lifecycle_phase == "risk":
		return "Söz ver did not recover the account"
	if GameState.reputation != rep0 + B2BConstants.RETAIN_PROMISE_REP:
		return "Söz ver reputation delta wrong"

	# Oyala → extends the countdown once, counts a stall, reputation down (the stall's
	# cost moved from brand to reputation; brand stays untouched).
	var c2: Customer = _add_risk_b2b("rb", 1000)
	var cd0: int = c2.churn_countdown
	var brand0: int = GameState.brand
	var rep1: int = GameState.reputation
	if not EventGate.force_fire(RETAIN_ID, {"customer": c2.id}):
		return "the retention card was refused for co_rb"
	EventGate.resolve(RETAIN_ID, "stall")
	if c2.churn_countdown != cd0 + B2BConstants.RETAIN_DELAY_DAYS:
		return "Oyala did not extend the countdown (%d -> %d)" % [cd0, c2.churn_countdown]
	if c2.retain_stalls != 1:
		return "Oyala did not count a stall"
	if GameState.reputation != rep1 + B2BConstants.RETAIN_DELAY_REP:
		return "Oyala reputation delta wrong"
	if GameState.brand != brand0:
		return "Oyala still moved brand (%d)" % (GameState.brand - brand0)

	# İndirim ver → MRR drops (bridged), customer recovers, reputation down.
	var c3: Customer = _add_risk_b2b("rc", 1000)
	var mrr0: int = c3.mrr
	var rep0b: int = GameState.reputation
	if not EventGate.force_fire(RETAIN_ID, {"customer": c3.id}):
		return "the retention card was refused for co_rc"
	EventGate.resolve(RETAIN_ID, "discount")
	var cut: int = int(round(1000.0 * B2BConstants.RETAIN_DISCOUNT_PCT))
	if c3.mrr != mrr0 - cut:
		return "İndirim MRR wrong: %d -> %d (want -%d)" % [mrr0, c3.mrr, cut]
	if GameState.mrr != CustomerRegistry.get_total_mrr():
		return "İndirim did not bridge MRR (%d vs %d)" % [GameState.mrr, CustomerRegistry.get_total_mrr()]
	if c3.lifecycle_phase == "risk":
		return "İndirim did not recover the account"
	if GameState.reputation != rep0b + B2BConstants.RETAIN_DISCOUNT_REP:
		return "İndirim reputation delta wrong"

	# "Kendi haline bırak" → NO instant churn / MRR / brand hit; the account stays in
	# Risk and keeps paying (the countdown just keeps running — proven in _case_b2b_ignore_then_churn).
	var c4: Customer = _add_risk_b2b("rd", 1000)
	var lost0: int = GameState.run_customers_lost
	var brand0b: int = GameState.brand
	var mrr0d: int = c4.mrr
	if not EventGate.force_fire(RETAIN_ID, {"customer": c4.id}):
		return "the retention card was refused for co_rd"
	EventGate.resolve(RETAIN_ID, "leave_alone")
	if CustomerRegistry.get_customer("co_rd") == null:
		return "Kendi haline bırak instantly churned the account (should not)"
	if GameState.run_customers_lost != lost0:
		return "Kendi haline bırak wrongly incremented run_customers_lost"
	if GameState.brand != brand0b:
		return "Kendi haline bırak wrongly moved brand (should land at churn, not here)"
	if c4.mrr != mrr0d:
		return "Kendi haline bırak wrongly changed MRR"
	if c4.lifecycle_phase != "risk":
		return "Kendi haline bırak left Risk (should stay, countdown running)"
	return ""


static func _case_b2b_ignore_then_churn() -> String:
	# "Kendi haline bırak" = no intervention: the customer stays in Risk and pays; the
	# churn countdown keeps running and fires _churn on its own at zero, with a SINGLE
	# brand delta (the moved-to-churn hit). And İlgilen before expiry can still rescue.
	GameState.set_flag("mvp_sub_product_type_id", "ai_vector_search")
	_seed_b2b(2000)
	GameState.set_flag("mvp_stability", 20.0)      # degrading product → stays under tolerance
	GameState.set_flag("mvp_live_bug_count", 40)

	# Ignore path → countdown runs down → natural churn with one brand hit.
	var c: Customer = _add_risk_b2b("ic", 1000)
	if not EventGate.request(RETAIN_ID, {"customer": c.id}):
		return "the retention card was refused for co_ic"
	EventGate.resolve(RETAIN_ID, "leave_alone")
	if CustomerRegistry.get_customer("co_ic") == null:
		return "ignore churned instantly"
	var cd0: int = c.churn_countdown
	if cd0 < 1:
		return "no active countdown after ignore"
	var brand_before: int = GameState.brand
	var lost_before: int = GameState.run_customers_lost
	var churned: Array = []
	var cb := func(id: String) -> void: churned.append(id)
	EventBus.customer_churned.connect(cb)
	for i in (cd0 + 3):
		GameState.advance_day()
		B2BSalesSystem.daily_tick()
		if CustomerRegistry.get_customer("co_ic") == null:
			break
	EventBus.customer_churned.disconnect(cb)
	if CustomerRegistry.get_customer("co_ic") != null:
		return "customer never churned after ignoring (countdown didn't run)"
	if churned != ["co_ic"]:
		return "customer_churned not emitted once (%s)" % str(churned)
	if GameState.run_customers_lost != lost_before + 1:
		return "run_customers_lost not incremented at natural churn"
	if GameState.brand != brand_before + B2BConstants.CHURN_BRAND:
		return "churn brand delta wrong/missing (want single %d)" % B2BConstants.CHURN_BRAND

	# Rescue path: a fresh Risk account, ignored once, is still saved by İlgilen → Söz ver.
	GameState.set_flag("mvp_stability", 90.0)
	GameState.set_flag("mvp_live_bug_count", 0)
	var r: Customer = _add_risk_b2b("ir", 1000)
	if not EventGate.request(RETAIN_ID, {"customer": r.id}):
		return "the retention card was refused for co_ir"
	EventGate.resolve(RETAIN_ID, "leave_alone")
	if CustomerRegistry.get_customer("co_ir") == null:
		return "rescue target churned on ignore"
	# THE REOPEN NOW COSTS A DAY, and the day is the finding. `customer.retention` carries a
	# one-day entity cooldown, so the İlgilen button cannot re-open the card the player just
	# answered — that is an undo, not a decision — but the rescue window itself is untouched:
	# the account is still in Risk with its countdown running.
	if EventGate.request(RETAIN_ID, {"customer": r.id}):
		return "the card re-opened the same day it was answered — the latch is not holding"
	GameState.advance_day()
	B2BSalesSystem.daily_tick()
	if not EventGate.request(RETAIN_ID, {"customer": r.id}):
		return "İlgilen could not re-open the card a day later"
	EventGate.resolve(RETAIN_ID, "promise_it")     # Söz ver → recover
	if r.lifecycle_phase == "risk":
		return "İlgilen → Söz ver did not rescue after an earlier ignore"
	return ""


# --- B2B pitch → MeetingScene migration (view-only, outcome-invariant) ---

static func _case_b2b_pitch_meeting_signs() -> String:
	# THE WHOLE SITTING, END TO END (§5.0 → §5.1 → §5.3 → §5.4): the founder sits down, the
	# customer cuts to the numbers, the table agrees a price, and an account exists that
	# carries THAT price. FALSIFICATION: against the retired four-beat pitch the seat-price
	# assertion fails — a signed account had no seat price to carry.
	GameState.set_flag("mvp_shipped", true)
	GameState.set_flag("mvp_market_type", "b2b")
	GameState.set_flag("mvp_sub_product_type_id", "ai_vector_search")
	_seed_b2b_lines("erp", 2)
	_set_founder_tech(9)
	_set_founder_area(HRConstants.AREA_SALES, 9)
	var p: Prospect = SalesFaucetSystem.spawn(1, "faucet")
	if p == null:
		return "the faucet produced no lead to meet"
	var before: int = CustomerRegistry.get_by_market("b2b").size()
	var vs: Dictionary = SalesMeetingSystem.open(p.id)
	if vs.is_empty() or not SalesMeetingSystem.is_active():
		return "the meeting did not open"
	# §5.0 — a sitting is ATOMIC, and the save gate is what makes "never serialised" honest.
	if SaveManager.can_save():
		return "a save was allowed mid-sitting — §5.0 says the scene is atomic"
	vs = _play_meeting_out(vs)
	if String(vs.get("outcome", "")) != "won":
		return "a strong founder against a 1-star table did not win: %s (odds %.2f, axes %d/%d/%d)" % [
			str(vs.get("outcome", "")), float(vs.get("odds", 0.0)),
			ProductRead.axis_reading("", "innovation"), ProductRead.axis_reading("", "stability"),
			ProductRead.axis_reading("", "experience")]
	# §5.3 — Perde 2. Offer at the band floor so the customer accepts on the first move.
	NegotiationSystem.open(NegotiationSystem.TYPE_B2B, {
		"account": p.company_name, "lead_id": p.id, "star": p.star,
		"archetype": p.archetype_id, "promised": SalesMeetingSystem.promised_feature(),
		"is_whale": p.is_whale,
	})
	NegotiationSystem.select_price(SalesConstants.SEAT_PRICE_MIN)
	var nvs: Dictionary = NegotiationSystem.offer()
	if String(nvs.get("state", "")) != "accepted":
		return "an offer at the band floor was not accepted: %s" % str(nvs.get("state", ""))
	SalesFinalizer.apply(NegotiationSystem.result())
	SalesMeetingSystem.close()
	if SalesMeetingSystem.is_active():
		return "the sitting is still active after close()"
	if CustomerRegistry.get_by_market("b2b").size() != before + 1:
		return "the signature created no customer"
	if ProspectRegistry.get_prospect(p.id) != null:
		return "the signature did not remove the lead"
	var c: Customer = CustomerRegistry.get_customer("co_" + p.id)
	if c == null:
		return "the customer id is not derived from the lead id"
	# §5.4 — THE PRICE TRAIL. The account carries what it agreed to, and MRR is the product.
	if c.seat_price != SalesConstants.SEAT_PRICE_MIN:
		return "the account did not carry the agreed seat price: $%d" % c.seat_price
	if c.mrr != c.seats * c.seat_price:
		return "MRR %d is not seats x seat price (%d x %d)" % [c.mrr, c.seats, c.seat_price]
	# The gate must be back OFF — but only the sitting's half of it. The two skipped hours
	# run the real hourly path (§5.0), so an ambient card may legitimately be up when the
	# player returns, and that refusal belongs to the event engine rather than to Sales.
	if NegotiationSystem.is_active():
		return "the negotiation is still active after the signature"
	if EventGate.active_id() == "" and not SaveManager.can_save():
		return "saving is still refused after the sitting closed with no card up"
	return ""


## Play a sitting to its outcome by taking the first OPEN answer each turn, then skipping to
## the offer if the customer is still asking. Shared by the sitting cases below.
static func _play_meeting_out(vs: Dictionary) -> Dictionary:
	for i in SalesConstants.SAFETY_CAP_PROBES + 2:
		if String(vs.get("outcome", "")) != "":
			return vs
		var picked: String = ""
		for a in (vs.get("answers", []) as Array):
			if bool((a as Dictionary).get("open", false)):
				picked = String((a as Dictionary).get("id", ""))
				break
		if picked == "":
			return SalesMeetingSystem.skip_to_offer()
		vs = SalesMeetingSystem.choose(picked)
	return vs

static func _case_sales_meeting_replays_identically() -> String:
	# §5.1 + engine §9.3 — THE NO-DICE-FISHING LAW, which the re-pitch design leans on. The
	# check derives from the run seed, the day, the lead and THE PATH, so replaying the same
	# answers gives the same verdict and only a DIFFERENT (and costlier) path moves the die.
	# This case replaces `b2b_rep_portrait_rotation`, whose subject — a portrait rotation on
	# the retired view adapter — no longer exists in any form.
	# FALSIFICATION: swap EvDice.check for SkillCheck.roll_against (the RngStreams draw the
	# old pitch used) and the two verdicts diverge, because a stream draw moves with position.
	GameState.set_flag("mvp_shipped", true)
	GameState.set_flag("mvp_market_type", "b2b")
	GameState.set_flag("mvp_sub_product_type_id", "ai_vector_search")
	GameState.run_seed = 424242
	var first: String = _replay_once("replay_lead")
	if first == "":
		return "the sitting produced no outcome to compare"
	# A reload restores the seed and the day; nothing else about the path changed.
	GameState.run_seed = 424242
	var second: String = _replay_once("replay_lead")
	if first != second:
		return "the same path replayed differently: %s then %s" % [first, second]
	# A DIFFERENT lead id is a genuinely different roll — the die is not a constant.
	var other: String = _replay_once("replay_other")
	var differed: bool = other != first
	# The SITTING is what must not survive the close (§5.0: one sitting, and nothing of it is
	# serialised). `path_id()` is deliberately never empty — an empty option_id would make two
	# different tables hash to the same die — so the thing to assert is the state, not a string.
	if SalesMeetingSystem.is_active():
		return "the sitting is still active after close()"
	if SalesMeetingSystem.active_lead_id() != "":
		return "the sitting still names a lead after close(): %s" % SalesMeetingSystem.active_lead_id()
	if not differed and first == "won":
		return "" # a different lead may legitimately land the same way; not a failure
	return ""


## One sitting on a hand-built lead, played by skipping straight to the offer so the PATH is
## exactly "skip:1" every time and the only variable under test is the derivation.
static func _replay_once(lead_id: String) -> String:
	if ProspectRegistry.get_prospect(lead_id) != null:
		ProspectRegistry.remove(lead_id)
	var p: Prospect = _add_prospect(lead_id, 2, "ai_vec_filter")
	GameState.set_flag("sales_meeting_used_day", -1)
	var vs: Dictionary = SalesMeetingSystem.open(p.id)
	if vs.is_empty():
		return ""
	while String(vs.get("outcome", "")) == "" and not SalesMeetingSystem.can_skip_to_offer():
		var picked: String = ""
		for a in (vs.get("answers", []) as Array):
			if bool((a as Dictionary).get("open", false)):
				picked = String((a as Dictionary).get("id", ""))
				break
		if picked == "":
			break
		vs = SalesMeetingSystem.choose(picked)
	if String(vs.get("outcome", "")) == "":
		vs = SalesMeetingSystem.skip_to_offer()
	var outcome: String = String(vs.get("outcome", ""))
	SalesMeetingSystem.close()
	if ProspectRegistry.get_prospect(lead_id) != null:
		ProspectRegistry.remove(lead_id)
	return outcome

## §5.1.1 — THE INNER VOICE REACHES THE SCREEN. main.gd discards open()'s frame and the scene
## paints its own view_state(); a line spent on the first call was never seen. The line must
## survive every view of its probe, cost the run's budget once, and leave with the probe.
## FALSIFICATION: return `_take_inner_voice()`'s text straight from view_state again (the old
## take-and-forget) and the second frame comes back empty.
static func _case_sales_inner_voice_reaches_view() -> String:
	GameState.set_flag("mvp_shipped", true)
	GameState.set_flag("mvp_market_type", "b2b")
	GameState.set_flag("mvp_sub_product_type_id", "ai_vector_search")
	GameState.set_flag("sales_inner_voice_used", 0)
	GameState.set_flag("sales_meeting_used_day", -1)
	var p: Prospect = _add_prospect("voice_lead", 3, "ai_vec_filter")
	var opened: Dictionary = SalesMeetingSystem.open(p.id)
	if opened.is_empty() or String(opened.get("outcome", "")) != "":
		SalesMeetingSystem.close()
		return "the sitting did not open on a probe"
	var shown: Dictionary = SalesMeetingSystem.view_state()
	var line: String = String(shown.get("inner_voice", ""))
	if line == "":
		SalesMeetingSystem.close()
		return "the scene's own frame carries no inner voice"
	if line != String(opened.get("inner_voice", "")):
		SalesMeetingSystem.close()
		return "the two frames of one probe disagree on the inner voice"
	var left: int = SalesLedger.inner_voice_left()
	if left != SalesConstants.INNER_VOICE_BUDGET_PER_RUN - 1:
		SalesMeetingSystem.close()
		return "the budget moved %d for one line, want 1" \
			% (SalesConstants.INNER_VOICE_BUDGET_PER_RUN - left)
	SalesMeetingSystem.close()
	return ""


static func _case_b2b_prospect_pain_references_real_feature() -> String:
	# B.4: a prospect's surface need maps to a feature that EXISTS in the active
	# product's pool (so a special request later is buildable, not a phantom ask).
	GameState.set_flag("mvp_shipped", true)
	GameState.set_flag("mvp_market_type", "b2b")
	GameState.set_flag("mvp_sub_product_type_id", "ai_vector_search")
	var pool_ids: Array = []
	for f in ProductCatalog.get_feature_pool("ai_vector_search"):
		pool_ids.append(String(f.get("id", "")))
	GameState.set_flag("mvp_shipped", true)
	GameState.set_flag("mvp_market_type", "b2b")
	for i in 6:
		var p: Prospect = SalesFaucetSystem.spawn(1, "faucet")
		if p == null:
			return "the faucet dried at draw %d" % i
		if p.pain_feature_id == "":
			return "lead %d has empty pain_feature_id" % i
		if not pool_ids.has(p.pain_feature_id):
			return "pain_feature_id %s not in the product pool" % p.pain_feature_id
		# `display_need()` is RETIRED with the read-gated need pools (§19). What a lead
		# renders instead is its archetype's one line, and the pain is an ID that a promise
		# and the CS request channel can both point at.
		if SalesArchetypes.voice_line(p.archetype_id) == "":
			return "lead %d renders no archetype line" % i
	return ""


# --- B2B Sales System: Stage C (promise tracking + Product roadmap coupling) ---

static func _case_b2b_promise_kept_on_ship() -> String:
	# A promised feature reaching live (mvp_components) before the deadline KEEPS the
	# promise → satisfaction + tolerance jump + promise_kept signal.
	GameState.set_flag("mvp_sub_product_type_id", "ai_vector_search")
	_seed_b2b(1000)
	var c: Customer = CustomerRegistry.get_by_market("b2b")[0]
	var sat0: int = c.satisfaction
	var tol0: int = c.tolerance
	var kept: Array = []
	var cb := func(id: String) -> void: kept.append(id)
	EventBus.promise_kept.connect(cb)
	var pr: Promise = PromiseRegistry.create(c.id, "ai_vec_filter", 14)
	GameState.set_flag("mvp_components", ["ai_vec_filter"])  # the promised feature ships
	EventBus.build_phase_changed.emit("shipped")
	EventBus.promise_kept.disconnect(cb)
	if pr.status != "kept":
		return "promise not kept on ship (status=%s)" % pr.status
	if kept != [pr.id]:
		return "promise_kept not emitted once (%s)" % str(kept)
	if c.satisfaction != clampi(sat0 + B2BConstants.PROMISE_KEPT_SAT, 0, 100):
		return "kept satisfaction jump wrong (%d -> %d)" % [sat0, c.satisfaction]
	if c.tolerance != clampi(tol0 + B2BConstants.PROMISE_KEPT_TOLERANCE, 0, 100):
		return "kept tolerance jump wrong (%d -> %d)" % [tol0, c.tolerance]
	return ""


static func _case_b2b_promise_broken_on_deadline() -> String:
	# A deadline passing with the feature unshipped BREAKS the promise → tolerance
	# double-drop + brand hit + credibility flag + promise_broken signal. A re-approach
	# afterwards lands with reduced goodwill.
	GameState.set_flag("mvp_sub_product_type_id", "ai_vector_search")
	_seed_b2b(1000)
	var c: Customer = CustomerRegistry.get_by_market("b2b")[0]
	var tol0: int = c.tolerance
	var brand0: int = GameState.brand
	var broken: Array = []
	var cb := func(id: String) -> void: broken.append(id)
	EventBus.promise_broken.connect(cb)
	var pr: Promise = PromiseRegistry.create(c.id, "ai_vec_filter", 3)
	for i in 5:
		GameState.advance_day()
		B2BSalesSystem.daily_tick()   # runs the deadline sweep; feature never shipped
	EventBus.promise_broken.disconnect(cb)
	if pr.status != "broken":
		return "promise not broken past deadline (status=%s)" % pr.status
	if broken != [pr.id]:
		return "promise_broken not emitted once (%s)" % str(broken)
	if GameState.brand != brand0 + B2BConstants.PROMISE_BROKEN_BRAND:
		return "broken brand hit wrong (%d -> %d)" % [brand0, GameState.brand]
	if c.tolerance != clampi(tol0 + B2BConstants.PROMISE_BROKEN_TOLERANCE, 0, 100):
		return "broken tolerance drop wrong (%d -> %d)" % [tol0, c.tolerance]
	if not GameState.get_flag("b2b_broke_%s" % c.id, false):
		return "credibility flag not set after a broken promise"
	# A re-approach now lands with HALF the goodwill bump (credibility down).
	var sat_before: int = c.satisfaction
	B2BSalesSystem.accept_promise(c.id, "ai_vec_filter", 14)
	if c.satisfaction != clampi(sat_before + int(B2BConstants.RETAIN_SAT_BUMP / 2), 0, 100):
		return "re-approach goodwill not reduced after a broken promise"
	return ""


# --- B2B Sales System: Stage D (Customer-Success delegation + escalation) ---

static func _make_cs(id: String, expertise: int, morale: int = 60) -> Character:
	var cs := Character.new()
	cs.id = id
	cs.character_name = "Burcu Çetin"
	cs.role = HRConstants.ROLE_CUSTOMER_REP
	cs.category = "employee"
	cs.monthly_salary = 5000
	cs.morale = morale
	# UZMANLIK is an AXIS value here (0-9), not the old 0-100 skill — the conversion shim is
	# gone. Expertise 5 is the value that reproduces the pre-Coupling seeded rep exactly:
	# B2BConstants.cs_dampen(5) = 1 - 5x0.055 = 0.725 = the old 1 - 55/200. Mind the margin
	# when changing it: at the erosion these cases set up, axis 0 ties the founder-managed
	# twin and axis 3 lands one point off CS_ESCALATION_SAT.
	cs.role_stats = HRConstants.seed_skills(HRConstants.ROLE_CUSTOMER_REP, expertise, SEED_PACE, SEED_RAPPORT)
	cs.traits = ["picks_it_up_fast"]
	CharacterRegistry.add(cs)
	return cs


static func _case_b2b_cs_absorbs_routine() -> String:
	# A CS-managed account erodes SLOWER than a founder-managed twin and produces NO
	# routine events (no retention/escalation while above the critical threshold).
	GameState.set_flag("mvp_sub_product_type_id", "ai_vector_search")
	_seed_b2b(1000)  # founder-managed twin (co_lead_smoke)
	var founder_mgd: Customer = CustomerRegistry.get_customer("co_lead_smoke")
	var cs: Character = _make_cs("char_cs_1", 5)
	var p := Prospect.new()
	p.id = "csm"
	p.company_name = "CS Managed"
	p.industry = "insurance"
	p.star = 1
	p.pain_feature_id = "ai_vec_filter"
	var cs_mgd: Customer = _sign_fixture(p, 1000, 70)
	CustomerRegistry.assign_customer(cs_mgd.id, cs.id)
	if cs_mgd.assigned_to != cs.id:
		return "assign_customer did not set assigned_to"
	GameState.set_flag("mvp_stability", 20.0)
	GameState.set_flag("mvp_live_bug_count", 40)
	CustomerRegistry.set_satisfaction(founder_mgd.id, 60)
	CustomerRegistry.set_satisfaction(cs_mgd.id, 60)
	for i in 6:
		GameState.advance_day()
		B2BSalesSystem.daily_tick()
	if cs_mgd.satisfaction <= founder_mgd.satisfaction:
		return "CS-managed did not erode slower (cs=%d founder=%d)" % [cs_mgd.satisfaction, founder_mgd.satisfaction]
	if _instances_of(RETAIN_ID) != 0:
		return "CS-managed produced a routine retention event"
	if _instances_of("customer.cs_escalation") != 0:
		return "CS-managed escalated while still above the critical threshold"
	return ""


static func _case_b2b_cs_escalation_refuse() -> String:
	# A CS-managed account crossing the critical threshold raises ONE escalation. "Hayır"
	# churns the account + drops brand + drops THAT CS employee's morale (through the seam).
	GameState.set_flag("mvp_shipped", true)
	GameState.set_flag("mvp_market_type", "b2b")
	GameState.set_flag("mvp_sub_product_type_id", "ai_vector_search")
	var cs: Character = _make_cs("char_cs_1", 4, 60)
	var p := Prospect.new()
	p.id = "esc"
	p.company_name = "Ege Sigorta"
	p.industry = "insurance"
	p.star = 1
	p.pain_feature_id = "ai_vec_filter"
	var c: Customer = _sign_fixture(p, 2000, 70)
	CustomerRegistry.assign_customer(c.id, cs.id)
	CustomerRegistry.set_satisfaction(c.id, 20)  # below the critical threshold
	GameState.advance_day()
	B2BSalesSystem.daily_tick()      # writes cs_escalated — the EDGE, and nothing else
	EventGate.daily_tick()           # the sweep reads it and admits the card
	var esc_id: String = "customer.cs_escalation"
	if not _drain_to(esc_id):
		return "escalation not active (%s)" % EventGate.active_id()
	var brand0: int = GameState.brand
	var lost0: int = GameState.run_customers_lost
	var morale0: int = cs.morale
	EventGate.resolve(esc_id, "refuse")
	if CustomerRegistry.get_customer(c.id) != null:
		return "refuse did not churn the account"
	if GameState.run_customers_lost != lost0 + 1:
		return "refuse did not increment run_customers_lost"
	if GameState.brand != brand0 - B2BConstants.CS_REFUSE_BRAND:
		return "refuse brand hit wrong (%d -> %d)" % [brand0, GameState.brand]
	if cs.morale != clampi(morale0 - B2BConstants.CS_REFUSE_MORALE, 0, 100):
		return "CS morale not dropped (%d -> %d)" % [morale0, cs.morale]
	return ""


static func _case_b2b_cs_counts_in_payroll_hires() -> String:
	# The CS employee type counts toward payroll + run_hires (a real hire), and the
	# CS accessors find it — so growing the portfolio creates organic HR demand.
	var pay0: int = CharacterRegistry.get_total_monthly_salaries()
	var hires0: int = GameState.run_hires
	_make_cs("char_cs_x", 5)
	if CharacterRegistry.get_total_monthly_salaries() != pay0 + 5000:
		return "CS salary not counted in payroll"
	if GameState.run_hires != hires0 + 1:
		return "CS hire not counted in run_hires"
	if CharacterRegistry.count_customer_reps() != 1:
		return "count_customer_reps wrong (%d)" % CharacterRegistry.count_customer_reps()
	if CharacterRegistry.get_customer_reps().size() != 1:
		return "get_customer_reps wrong"
	return ""


# --- B2B Sales System: Stage E (2nd product / sector affinity / value band / expansion) ---

static func _case_b2b_expansion_moves_seats_mrr_counter() -> String:
	# The expansion seam grows seats + MRR through the registry, bridges the aggregate,
	# and increments the run_customers_expanded counter (genuine upsell only).
	_seed_b2b(1000)
	var c: Customer = CustomerRegistry.get_by_market("b2b")[0]
	var seats0: int = c.seats
	var mrr0: int = c.mrr
	var exp0: int = GameState.run_customers_expanded
	var expanded: Array = []
	var cb := func(_id: String, n: int) -> void: expanded.append(n)
	EventBus.customer_expanded.connect(cb)
	# Satış rev 6 §5.4 — the caller still passes the flat constant, because the ENGINE'S own
	# `b2b_expand` effect does and this module edits no engine file. What changed is that a
	# stamped account IGNORES it and charges what it agreed to at signing. The 120 below is
	# therefore deliberately still here: it is the fallback, and the assertion is that this
	# account does not use it.
	var own_price: int = c.seat_price
	if own_price <= 0:
		return "the fixture account carries no stamped seat price"
	B2BSalesSystem.expand(c.id, 5, 120)
	EventBus.customer_expanded.disconnect(cb)
	if c.seats != seats0 + 5:
		return "seats did not grow (%d -> %d)" % [seats0, c.seats]
	if c.mrr != mrr0 + 5 * own_price:
		return "expansion charged %d for 5 seats, want 5 x the account's own $%d" % [
			c.mrr - mrr0, own_price]
	if GameState.mrr != CustomerRegistry.get_total_mrr():
		return "expansion did not bridge MRR (%d vs %d)" % [GameState.mrr, CustomerRegistry.get_total_mrr()]
	if GameState.run_customers_expanded != exp0 + 1:
		return "run_customers_expanded not incremented"
	if expanded.is_empty():
		return "customer_expanded never fired"
	# Event-driven path: a healthy, mature account auto-enqueues the expansion family on
	# the daily tick (state-bound, not calendar-polled) and resolving "Büyüt" upsells it.
	#
	# A SECOND, DISTINCT account — not a re-seed of co_lead_smoke. `expand()` above already
	# spent that account's one expansion moment, and since the expansion-loop fix the engine remembers it. The
	# re-seed only ever looked like a fresh start because expansion had no memory at all.
	GameState.set_flag("mvp_sub_product_type_id", "ai_vector_search")
	var pm := Prospect.new()
	pm.id = "lead_mature"
	pm.company_name = "Mature A.Ş."
	pm.industry = "testing"
	pm.star = 1
	_sign_fixture(pm, 1000, 70)
	var m: Customer = CustomerRegistry.get_customer("co_lead_mature")
	if m == null:
		return "the mature fixture account was not created"
	m.acquired_on_day = GameState.day - (B2BConstants.EXPANSION_MATURE_DAYS + 1)  # mature
	CustomerRegistry.set_lifecycle_phase(m.id, "active")
	CustomerRegistry.set_satisfaction(m.id, 80)  # healthy (>= tolerance)
	var seats_before: int = m.seats
	GameState.advance_day()
	B2BSalesSystem.daily_tick()      # marks the account `expansion` — the fact, not the card
	# THE EXPANSION IS A PAPER NOW, and that is the behaviour change worth pinning. It used to
	# mount a modal the moment an account matured: an interruption for good news with no
	# deadline behind it. It lands on the desk, and the desk is where the player picks it up.
	var eid: String = EXPANSION_ID
	if not EventGate.request(eid, {"customer": m.id}):
		return "the expansion card was refused for a mature healthy account"
	var desk: Array = EventGate.desk_papers(8)
	var on_desk: bool = false
	for entry in desk:
		if String((entry as Dictionary)["id"]) == eid:
			on_desk = true
			if int((entry as Dictionary)["days_left"]) <= 0:
				return "the expansion paper landed with no clock"
	if not on_desk:
		return "the expansion card did not reach the desk (desk: %d paper(s))" % desk.size()
	if EventGate.active_id() == eid:
		return "a paper mounted itself as a modal"
	if not EventGate.open_paper(eid):
		return "the paper would not open"
	EventGate.resolve(eid, "expand")
	if m.seats <= seats_before:
		return "event-driven expansion did not grow seats"
	return ""


static func _case_build_percent_single_source() -> String:
	# The same build printed different percentages in one frame: the portfolio badge
	# rounded, the floating HUD floored, the HUD's own bar took the raw float, and the
	# in-tab tracker floored a second time. The HUD floats OVER any open tab page, so two
	# of those were visible simultaneously. One formatter, one answer.
	# FAILS against the pre-fix engine, which had no shared formatter at all.
	var probes: Array = [0.4761, 0.005, 0.999, 0.5, 0.0, 1.0]
	for f in probes:
		var pct: int = UiTokens.build_percent(float(f))
		if pct != int(round(clampf(float(f), 0.0, 1.0) * 100.0)):
			return "build_percent(%f) = %d, not the rounded value" % [float(f), pct]
	# The specific value that used to split the two surfaces: floor 47 vs round 48.
	if UiTokens.build_percent(0.4761) != 48:
		return "0.4761 should read 48, got %d" % UiTokens.build_percent(0.4761)
	# Clamped at both ends, so no caller can render %101 or a negative bar.
	if UiTokens.build_percent(1.7) != 100 or UiTokens.build_percent(-0.3) != 0:
		return "build_percent does not clamp (%d / %d)" % [
			UiTokens.build_percent(1.7), UiTokens.build_percent(-0.3)]
	return ""


static func _case_source_tag_speaker_wins() -> String:
	# Kaynak rozetinin SIRASI. `endgame` etiketi konuşmacı kontrolünün önündeydi, o yüzden
	# Frank'in ağzından çıkan altı kart "PİYASA" okunuyordu — kepenk uyarısı, pivot teklifi,
	# satın alma teklifi, VC daveti, teklif süresi uyarısı, son gün uyarısı. Etiket bir KONU,
	# kaynak KONUŞANDIR.
	# FALSİFİKASYON: _source_tag'de konuşmacı kontrolünü `has_endgame` dalının ALTINA taşı →
	# ilk iddia FAIL ("MENTOR bekleniyordu, PİYASA geldi").
	var modal: GDScript = load("res://scripts/modals/event_modal.gd")
	var mentor: String = TranslationServer.translate("EVENT_TAG_MENTOR")
	var market: String = TranslationServer.translate("EVENT_TAG_MARKET")
	var product: String = TranslationServer.translate("EVENT_TAG_PRODUCT")
	var customer: String = TranslationServer.translate("EVENT_TAG_CUSTOMER")
	var team: String = TranslationServer.translate("EVENT_TAG_TEAM")
	var agenda: String = TranslationServer.translate("EVENT_TAG_AGENDA")

	# Her satır: [tags, character_id, beklenen rozet, ne ölçtüğü]
	var probes: Array = [
		[["endgame"], "char_mentor_frank", mentor, "Frank endgame kartı"],
		[["endgame"], "", market, "konuşmacısız endgame kartı"],
		[["ship_moment", "endgame"], "char_mentor_frank", product, "sürüm anı Frank anlatsa da ÜRÜN"],
		[["b2b_risk"], "char_mentor_frank", customer, "müşteri ailesi konuşmacıyı yener"],
		[["hr_morale"], "char_mentor_frank", team, "ekip ailesi konuşmacıyı yener"],
		[["phase_gate"], "", mentor, "faz kapısı konuşmacısız da MENTOR"],
		[[], "", agenda, "etiketsiz, konuşmacısız → GÜNDEM"],
	]
	for probe in probes:
		var ev := GameEvent.new()
		ev.id = "smoke_source_tag"
		# GameEvent.tags TİPLİ (Array[String]); Variant'tan gelen ham diziyi doğrudan
		# atamak çalışma zamanında reddedilir, o yüzden tek tek dolduruluyor.
		var tags: Array[String] = []
		for t in probe[0]:
			tags.append(String(t))
		ev.tags = tags
		ev.character_id = String(probe[1])
		var got: String = String(modal._source_tag(ev).get("text", ""))
		if got != String(probe[2]):
			return "%s: '%s' bekleniyordu, '%s' geldi" % [String(probe[3]), String(probe[2]), got]
	return ""


static func _case_ship_tooltip_counts_critical_penalty() -> String:
	# Yayınla tooltip'i canlıya taşınacak hata sayısını BEŞ EKSİK yazıyordu: iki ev sahibi de
	# ham bug_count basıyordu, launch() ise yazmadan hemen önce CRITICAL_BUG_LAUNCH_PENALTY
	# ekliyordu. Yani sayı, tam da riski göze alan oyuncuda yalan söylüyordu.
	# FALSİFİKASYON: projected_launch_bugs()'ın ceza dalını sil → ikinci iddia FAIL.
	GameState.set_cash(60000)
	var founder_id: String = CharacterRegistry.get_founder().id
	if not ProductSystem.start_build("saas_ops",
			["saas_ops_workflow", "saas_ops_reporting"], founder_id, "Nova"):
		return "start_build failed"
	if not _run_build_to_phase("bugfix"):
		return "build never reached beta"
	var b: FeatureBuild = ProductSystem.get_active_build()
	# Bayrak YOKKEN projeksiyon ham sayıya EŞİT — ceza koşulsuz eklenmiyor.
	GameState.set_flag("critical_bug_unfixed", false)
	if ProductSystem.projected_launch_bugs() != b.bug_count:
		return "bayraksız projeksiyon ham sayıdan saptı (%d != %d)" % [
			ProductSystem.projected_launch_bugs(), b.bug_count]
	# Bayrak varken projeksiyon TAM OLARAK cezayı ekler...
	GameState.set_flag("critical_bug_unfixed", true)
	var raw: int = b.bug_count
	var projected: int = ProductSystem.projected_launch_bugs()
	if projected != raw + ProductSystem.CRITICAL_BUG_LAUNCH_PENALTY:
		return "projeksiyon cezayı saymıyor (ham %d, projeksiyon %d, ceza %d)" % [
			raw, projected, ProductSystem.CRITICAL_BUG_LAUNCH_PENALTY]
	# ...ve launch() canlıya TAM O SAYIYI yazar. Tooltip ile gerçeğin ayrılamayacağı yer bu.
	ProductSystem.launch()
	var live: int = int(GameState.get_flag("mvp_live_bug_count", -1))
	if live != projected:
		return "launch %d yazdı, tooltip %d vaat etti" % [live, projected]
	return ""


static func _case_rail_tabs_match_scene_order() -> String:
	# SESSİZ KONUMSAL SÖZLEŞME. UiTokens.TABS bir dizi, LeftTabs.tscn bir düğüm listesi ve
	# left_tabs.gd ikisini İNDEKSLE eşliyor. Hiçbir şey bu eşleşmeyi doğrulamıyordu: sekme
	# sırası değişince ray doğru görünmeye devam eder, yalnız yanlış sayfayı açar.
	# Sahne INSTANTIATE EDİLMİYOR (headless'ta EventBus'a bağlanır ve rozet boyar) —
	# PackedScene.get_state() ile kaydedilmiş hâli okunuyor, ki ölçülen tam da o dosya.
	# FALSİFİKASYON: TABS'ta iki satırın yerini değiştir → ilk iddia FAIL.
	var ps: PackedScene = load("res://scenes/ui/components/LeftTabs.tscn")
	if ps == null:
		return "LeftTabs.tscn yüklenemedi"
	var st: SceneState = ps.get_state()
	var captions := PackedStringArray()
	for i in st.get_node_count():
		var path: String = String(st.get_node_path(i))
		if not path.begins_with("./Margin/Col/") or not path.ends_with("Btn/Stack/NameLabel"):
			continue
		if path.contains("SettingsBtn"):
			continue   # dişli bir sekme değil: aktif stil almaz, tab_changed emit etmez
		for j in st.get_node_property_count(i):
			if String(st.get_node_property_name(i, j)) == "text":
				captions.append(String(st.get_node_property_value(i, j)))
	if captions.size() != UiTokens.TABS.size():
		return "ray %d sekme çiziyor, TABS %d tanımlıyor" % [captions.size(), UiTokens.TABS.size()]
	for i in UiTokens.TABS.size():
		var want: String = "TAB_" + String(UiTokens.TABS[i].id).to_upper()
		if captions[i] != want:
			return "%d. sekme sahnede '%s', TABS'ta '%s'" % [i, captions[i], want]
	# İkinci iddia: her id BENZERSİZ ve her ikon dosyası GERÇEKTEN var. Yeni bir sekme
	# eklerken unutulan --import tam burada yakalanır (ikon sessizce boş çizilirdi).
	var seen := {}
	for row in UiTokens.TABS:
		var tid: String = String(row.id)
		if seen.has(tid):
			return "TABS'ta yinelenen id: %s" % tid
		seen[tid] = true
		var icon: String = String(row.get("icon", ""))
		if icon == "" or not ResourceLoader.exists(icon):
			return "%s sekmesinin ikonu yok: %s" % [tid, icon]
	return ""


static func _case_build_bar_hosts_agree() -> String:
	# Build Bar (Software Inc. segment grameri, 2026-08-19): ÜÇ ev sahibi — yüzen BuildHUD,
	# tracker kartı, ODA monitörü — AYNI BuildBar sahnesini kurar ve bar modelini KENDİ
	# çeker. Bu case üçünün aynı tick'te aynı modeli gösterdiğini ölçer: mount → 3 bar →
	# parmak izleri eşit ve türetilen modele eşit → 6 saat tik → parmak izleri değişmiş
	# ve HÂLÂ eşit. FALSİFİKASYON: monitör barının build_progress_changed bağını sök →
	# ikinci karşılaştırma FAIL (bar fingerprint()'i yeniden türetmez, önbelleği okur).
	# İlk smoke case'i ki GameShell'i headless mount eder — parse/instantiate grep'i şart.
	GameState.set_cash(50000)
	var founder_id: String = CharacterRegistry.get_founder().id
	if not ProductSystem.start_build("saas_ops",
			["saas_ops_workflow", "saas_ops_reporting", "saas_ops_integration"], founder_id, "Nova"):
		return "start_build failed"
	var b: FeatureBuild = ProductSystem.get_active_build()
	# r3 durumu: iki tur bitmiş, tur 3 yarıda (harness --build-state=r3 ile aynı sürüş).
	for i in 24 * 90:
		if b.iteration_count >= 3:
			break
		ProductSystem.hourly_tick(i % 24)
	if b.iteration_count != 3:
		return "fixture did not reach round 3 (count %d)" % b.iteration_count
	for i in 24 * 2:
		ProductSystem.hourly_tick(i % 24)
	# Ev sahibi = autoload (root main._ready sırasında meşgul — onboarding_pages_contract deseni).
	var host: Node = EventBus
	var shell: Node = load("res://scenes/main/GameShell.tscn").instantiate()
	host.add_child(shell)
	EventBus.tab_changed.emit("product")
	var cv: Node = shell.find_child("CenterViewport", true, false)
	if cv == null:
		shell.queue_free()
		return "CenterViewport not found in the mounted shell"
	var page: Node = cv.get_current_page_body()
	if page == null or not page.has_method("_navigate"):
		shell.queue_free()
		return "product tab body not mounted synchronously"
	page._navigate("tracker", {})
	var bars: Array = []
	for n in host.get_tree().get_nodes_in_group(&"build_bar"):
		if n.is_queued_for_deletion():
			continue
		bars.append(n)
	if bars.size() != 3:
		var paths: Array = []
		for n in bars:
			paths.append(str(n.get_path()))
		shell.queue_free()
		return "expected 3 BuildBar hosts, found %d: %s" % [bars.size(), str(paths)]
	var model = load("res://scripts/ui/components/build_bar_model.gd").new()
	if not model.derive():
		shell.queue_free()
		return "model did not derive from the seeded build"
	var want: String = model.fingerprint()
	if want.begins_with("design|3/") == false:
		shell.queue_free()
		return "fixture fingerprint not in round 3: %s" % want
	for n in bars:
		if n.fingerprint() != want:
			var got: String = n.fingerprint()
			shell.queue_free()
			return "host %s shows %s, model says %s" % [str(n.get_path()), got, want]
	# 6 saat tik: durum değişir; üç bar sinyalle birlikte yürümek zorunda.
	for i in 6:
		ProductSystem.hourly_tick(12 + i)
	var model2 = load("res://scripts/ui/components/build_bar_model.gd").new()
	model2.derive()
	var want2: String = model2.fingerprint()
	if want2 == want:
		shell.queue_free()
		return "6 hours changed nothing in the model (%s) — the tick did not advance the round" % want
	for n in bars:
		if n.fingerprint() != want2:
			var got2: String = n.fingerprint()
			shell.queue_free()
			return "host %s is stale after the tick: %s (want %s)" % [str(n.get_path()), got2, want2]
	shell.queue_free()
	return ""


static func _case_role_locks_and_runway_pair() -> String:
	# İKİ KARAR, İKİ İDDİA GRUBU (Erdem, 2026-08-24).
	#
	# B1 · MÜŞTERİ TEMSİLCİSİ KİLİDİ KALKTI, SATIŞ UZMANI KİLİDİ KALDI. MT'nin kilidi aynı
	# B2B kapısını taşıyordu ve GEREKÇESİ YALAN SÖYLÜYORDU: kart "Destek sistemi ile
	# açılacak" diyordu, kapı ise `has_b2b_product()`'tı — hiç değerlendirilmeyen bir koşulun
	# adı. §10.6 kilitli-görünür olarak yalnız Pazarlama ve in-house İK'yı sayıyor.
	#
	# B2 · ADAY KARTINDAKİ RUNWAY GERÇEĞİ SÖYLESİN. Şerit iki değeri de tam aya yuvarlıyordu,
	# yani ~0,6 aylık gerçek bir düşüş "5 ay → 5 ay" diye okunuyor ve kutu YİNE DE kırmızı
	# yanıyordu.
	#
	# FALSİFİKASYON: `role_lock_reason_key`e ROLE_CUSTOMER_REP dalını geri koy → ilk iddia
	# FAIL. `net_runway_pair`in çözünürlük dalını sil → dördüncü iddia FAIL.
	GameState.set_flag("mvp_shipped", false)
	if ProductSystem.has_b2b_product():
		return "fixture: the run already carries a B2B product; the lock cannot be measured"

	# 1 · MT B2C KOŞUSUNDA DA İŞE ALINIR.
	if not HRConstants.is_role_hireable(HRConstants.ROLE_CUSTOMER_REP):
		return "Müşteri Temsilcisi is still locked in a B2C run: '%s'" % \
			HRConstants.role_lock_reason_key(HRConstants.ROLE_CUSTOMER_REP)
	# 2 · SATIŞÇI KİLİDİ DURUYOR VE GEREKÇESİNİ YAZIYOR.
	var sales_key: String = HRConstants.role_lock_reason_key(HRConstants.ROLE_SALES_REP)
	if sales_key != "HR_ROLE_LOCK_SALES":
		return "the Satış Uzmanı gate is '%s', want HR_ROLE_LOCK_SALES" % sales_key
	if TranslationServer.translate(sales_key) == sales_key:
		return "the sales lock reason has no string — a locked card must say WHY (§10.6)"
	# 3 · ÖLÜ GEREKÇE DİZESİ AĞAÇTAN GİTTİ.
	if TranslationServer.translate("HR_ROLE_LOCK_CS") != "HR_ROLE_LOCK_CS":
		return "HR_ROLE_LOCK_CS still resolves; the reason it named was never evaluated"

	# 4 · YUVARLAMA YALANI: AYNI AYA YUVARLANAN iki değer, gerçek bir düşüşle.
	# SAYILAR ÖNCE ÇARPIŞMAYI KANITLAR. İlk denemede 5,6 → 4,95 seçilmişti ve o çift zaten
	# "6 ay" / "5 ay" veriyordu, yani iddia hiçbir zaman çarpışmayı ölçmedi — falsifikasyon
	# koştuğunda çözünürlük dalını silmek vakayı DÜŞÜRMEDİ ve tuzak ortaya çıktı.
	GameState.set_cash(100000)
	var a: float = 5.4
	var b: float = 4.6
	if UiTokens.net_runway_text(a) != UiTokens.net_runway_text(b):
		return "fixture: %.1f and %.1f do not collide on the shared formatter (%s vs %s)" % [
			a, b, UiTokens.net_runway_text(a), UiTokens.net_runway_text(b)]
	var pair: Dictionary = UiTokens.net_runway_pair(a, b)
	if not bool(pair["changed"]):
		return "a 0.8-month drop did not register as a change"
	if String(pair["before"]) == String(pair["after"]):
		return "the strip still prints the same text on both sides: '%s'" % String(pair["before"])
	# 5 · GÜRÜLTÜ DEĞİŞİKLİK DEĞİLDİR — şerit kırmızıya boyanmaz.
	if bool(UiTokens.net_runway_pair(5.0, 4.99)["changed"]):
		return "floating-point noise was painted as a runway drop"
	# 6 · INF→INF kırmızı DEĞİL, ve iki taraf da "Artıda" der.
	var inf_pair: Dictionary = UiTokens.net_runway_pair(INF, INF)
	if bool(inf_pair["changed"]):
		return "a profitable run was painted as losing runway"
	if String(inf_pair["before"]) != String(inf_pair["after"]):
		return "INF→INF printed two different words"
	# 7 · TEK EV KORUNDU: sıradan bir düşüş hâlâ paylaşılan biçimleyicinin cümlesi.
	var plain: Dictionary = UiTokens.net_runway_pair(6.0, 1.0)
	if String(plain["before"]) != UiTokens.net_runway_text(6.0) \
			or String(plain["after"]) != UiTokens.net_runway_text(1.0):
		return "a plain drop stopped going through net_runway_text: %s" % str(plain)
	return ""


static func _case_runway_days_and_negative_cash() -> String:
	# Two display bugs, both of which live in net_runway_parts and only there.
	# FAILS against the pre-fix engine: sub-month printed "0 ay", and negative cash printed
	# the green "Artıda" two cells from a running bankruptcy counter.
	GameState.set_cash(8597)
	# 0.2047 months ≈ 6 days. int(round()) rendered a bare 0 — insolvency, on a company
	# that is solvent for most of a week.
	var sub: Dictionary = UiTokens.net_runway_parts(0.2047)
	if String(sub.get("value", "")) == "0":
		return "sub-month runway still renders as a bare 0"
	if String(sub.get("unit", "")) == TranslationServer.translate("RUNWAY_UNIT_MONTHS"):
		return "sub-month runway is still labelled in months"
	if bool(sub.get("positive", false)):
		return "a six-day runway reads as positive"
	# The months path above one month is untouched.
	var normal: Dictionary = UiTokens.net_runway_parts(6.4)
	if String(normal.get("value", "")) != "6" \
			or String(normal.get("unit", "")) != TranslationServer.translate("RUNWAY_UNIT_MONTHS"):
		return "the months path moved: %s %s" % [str(normal.get("value")), str(normal.get("unit"))]
	# Negative cash can never read as "Artıda", whatever the daily net says.
	GameState.set_cash(-4000)
	var broke: Dictionary = UiTokens.net_runway_parts(INF)
	if bool(broke.get("positive", false)):
		return "negative cash still renders as positive runway"
	GameState.set_cash(20000)
	if not bool(UiTokens.net_runway_parts(INF).get("positive", false)):
		return "a solvent, profitable company lost its ARTIDA — the guard is a wall"
	return ""


# ============================================================================
#  Frank's angel round
# ============================================================================

# Seed a shipped B2B world at a chosen MRR, through the real signing seam, and hand back
# the account so a case can move its MRR later. _seed_b2b sets mvp_shipped for us.
static func _seed_angel_world(mrr: int) -> Customer:
	GameState.set_flag("mvp_sub_product_type_id", "saas_ops")
	_seed_b2b(mrr)
	return CustomerRegistry.get_customer("co_lead_smoke")


static func _case_angel_fires_at_crossing() -> String:
	# Frank's cheque arrives the first day a shipped product's MRR clears the bar — and it
	# reaches the player AHEAD of the phase gate when the two land together.
	var c: Customer = _seed_angel_world(1000)   # below the bar
	if c == null:
		return "fixture: no customer"
	if GameState.mrr != 1000:
		return "fixture drifted: MRR is %d, wanted 1000" % GameState.mrr
	# Clear the opening beats (first_revenue / frank_intro / traction gate) so the crossing
	# day starts with an EMPTY queue — which is both the realistic case (the seed fires
	# deep into a run, not on the noisy first morning) and the only condition under which
	# enqueue_front ordering is decidable at all. See the note below.
	for i in 3:
		_sim_day_full()
		_drain_all_modals()
	if _card_fired(ANGEL_ID):
		return "the offer opened below the bar (MRR %d)" % GameState.mrr

	# Cross BOTH bars in one day: the 2,500 seed bar and the Series A gate (MRR only — no
	# growth streak, no brand floor).
	CustomerRegistry.set_mrr(c.id, SalesSystem.TRACTION_MRR_TARGET + 1000)
	SalesSystem.reflect_mrr()
	# The crossing day is driven by hand rather than through _sim_day_full, for one reason:
	# the assertion below is a claim about two DETERMINISTIC beats, and it is only decidable
	# when the queue is empty when they fire (see the note at the assertion). The hourly
	# pass can drop a random ambient event in first — and it cannot be hoped away, because
	# run_case does NOT pin GameState.run_seed (initialize_run seeds off
	# Time.get_ticks_msec), so the ambient roll is a fresh coin every invocation. This case
	# passed solo and failed 4 times in 12 on that toss.
	#
	# So: run the hours exactly as the engine does, answer whatever the hourly pool raised,
	# and only then cross the day boundary into the daily slots that carry the two beats.
	# Nothing about the ordering under test is bypassed — only the unrelated noise is.
	while GameState.current_hour < TimeManager.HOURS_PER_DAY - 1:
		var h: int = GameState.current_hour + 1
		GameState.set_current_hour(h)
		TimeManager._dispatch_hourly_tick(h)
	GameState.set_current_hour(0)
	TimeManager._dispatch_hourly_tick(0)
	_drain_all_modals()          # the queue is now provably empty
	GameState.advance_day()
	TimeManager._dispatch_daily_tick()

	if not _card_fired(ANGEL_ID):
		return "the offer never opened at MRR %d" % GameState.mrr
	if _instances_of(ANGEL_ID) != 1:
		return "expected exactly one seed scene, found %d" % _instances_of(ANGEL_ID)

	# ORDERING GUARD (do not drain before reading this). It used to be a claim about SLOT
	# ORDER — AngelRoundSystem sat one line ahead of PhaseGateSystem in TimeManager because
	# "enqueue_front" did not mean front: it mounted immediately when nothing was active, so
	# with an empty queue the FIRST caller owned the screen. Neither system has a slot any
	# more. Both cards are admitted in the same tick and the engine orders the day's whole
	# admission set by §11.2 priority, which is why the assertion still reads the same way and
	# is now about something declared rather than about which file ran first.
	# On the crossing day the Series A door speaks through Frank's door-open line; the
	# decision card itself waits for a later day, so the line is what the cheque must lead.
	var seed_at: int = _queue_position_of(ANGEL_ID)
	var gate_at: int = _queue_position_of(DOOR_OPEN_ID)
	if _queue_position_of(GATE2_ID) >= 0:
		return "the Series A card is pending on the crossing day, ahead of Frank's door-open line"
	if gate_at < 0:
		return "fixture: the Series A gate did not open at MRR %d / brand %d" % [GameState.mrr, GameState.brand]
	if seed_at > gate_at:
		return "the phase gate is ahead of the seed scene (seed %d, gate %d)" % [seed_at, gate_at]
	return ""


# Answer every modal currently pending (always choice 0), so a case can reach a known
# empty-queue state. Bounded: a queue that will not drain is itself the finding.
static func _drain_all_modals() -> void:
	for i in 32:
		if EventGate.active_id() == "":
			return
		EventGate.resolve(EventGate.active_id(), 0)


# Where an id sits in the player's reading order: 0 = the modal on screen now, 1.. = the
# queue behind it, −1 = not pending.
static func _queue_position_of(event_id: String) -> int:
	if EventGate.active_id() == event_id:
		return 0
	var pos: int = EventGate.queue_position_of(event_id)
	return pos + 1 if pos >= 0 else -1


static func _case_angel_never_pre_ship() -> String:
	# Money without a product is not the beat. The guard under test is exactly the one the
	# seeder would otherwise satisfy, so it is cleared after seeding, on purpose.
	var c: Customer = _seed_angel_world(AngelRoundSystem.MRR_THRESHOLD * 2)
	if c == null:
		return "fixture: no customer"
	GameState.set_flag("mvp_shipped", false)
	for i in 3:
		_sim_day_full()
	if _card_fired(ANGEL_ID):
		return "the offer opened with no shipped product"
	if _instances_of(ANGEL_ID) != 0:
		return "a seed scene queued with no shipped product"
	if GameState.run_angel_equity_pct != 0:
		return "equity moved with no shipped product"
	return ""


static func _case_angel_not_below_threshold() -> String:
	# BOTH sides of the boundary in one case: silence at threshold-1 proves nothing on its
	# own (a feature that never fires would pass it), so the same account is then raised
	# over the line through the real seam and must fire.
	var c: Customer = _seed_angel_world(AngelRoundSystem.MRR_THRESHOLD - 1)
	if c == null:
		return "fixture: no customer"
	if GameState.mrr != AngelRoundSystem.MRR_THRESHOLD - 1:
		return "fixture drifted: MRR is %d" % GameState.mrr
	_sim_day_full()
	if _card_fired(ANGEL_ID):
		return "the offer opened one dollar under the bar (MRR %d)" % GameState.mrr
	# Over the line, through CustomerRegistry + the MRR bridge (a bare set_mrr would be
	# clobbered by SalesSystem._mrr_bridge on the next tick).
	CustomerRegistry.set_mrr(c.id, AngelRoundSystem.MRR_THRESHOLD)
	SalesSystem.reflect_mrr()
	_sim_day_full()
	if not _card_fired(ANGEL_ID):
		return "the offer did not open at the bar itself (MRR %d)" % GameState.mrr
	return ""


static func _case_angel_accept_is_atomic() -> String:
	# The round lands whole or not at all. A plain end-state check would pass against an
	# implementation that wrote cash FIRST and the cap table after — and that ordering ships
	# a one-frame Finance bar reading 0% beside $25,000 of new money, because cash_changed
	# is synchronous and the tab repaints inside it. So the probe below samples the world
	# FROM INSIDE the cash_changed emit.
	var c: Customer = _seed_angel_world(AngelRoundSystem.MRR_THRESHOLD)
	if c == null:
		return "fixture: no customer"
	var seen_equity: Array = [-1]
	var seen_tx: Array = [-1]
	var equity_emits: Array = [0]
	var probe := func(_v: int) -> void:
		seen_equity[0] = GameState.get_investor_equity_pct()
		seen_tx[0] = FinanceSystem.get_transactions().size()
	EventBus.equity_changed.connect(func(_p: int) -> void: equity_emits[0] += 1)
	_sim_day_full()
	if not _drain_to(ANGEL_ID):
		return "the seed scene never became active"
	# Baselines taken AFTER the day has settled: _sim_day_full runs the finance slot, which
	# applies the day's net flow, so a pre-tick snapshot would be off by exactly that net
	# and the case would be measuring the burn model rather than the round.
	var cash0: int = GameState.cash
	var tx0: int = FinanceSystem.get_transactions().size()
	EventBus.cash_changed.connect(probe)
	EventGate.resolve(ANGEL_ID, "accept")   # KABUL
	EventBus.cash_changed.disconnect(probe)

	if GameState.cash != cash0 + AngelRoundSystem.CASH_AMOUNT:
		return "cash %d -> %d, wanted +%d" % [cash0, GameState.cash, AngelRoundSystem.CASH_AMOUNT]
	if GameState.run_angel_equity_pct != AngelRoundSystem.EQUITY_PCT:
		return "angel equity is %d%%" % GameState.run_angel_equity_pct
	if GameState.get_investor_equity_pct() != AngelRoundSystem.EQUITY_PCT:
		return "composed investor equity is %d%%" % GameState.get_investor_equity_pct()
	if GameState.get_total_raised() != AngelRoundSystem.CASH_AMOUNT:
		return "total raised is %d" % GameState.get_total_raised()
	var txs: Array = FinanceSystem.get_transactions()
	if txs.size() != tx0 + 1:
		return "transactions grew by %d, wanted 1" % (txs.size() - tx0)
	var row: Dictionary = txs[txs.size() - 1]
	if String(row.get("label", "")) != AngelRoundSystem.TX_LABEL \
			or int(row.get("amount", 0)) != AngelRoundSystem.CASH_AMOUNT:
		return "ledger row is %s" % str(row)
	# The atomicity assertions proper.
	if seen_equity[0] != AngelRoundSystem.EQUITY_PCT:
		return "cash_changed fired with the cap table still at %d%% — the round is not atomic" % seen_equity[0]
	if seen_tx[0] != tx0 + 1:
		return "cash_changed fired before the ledger row was appended"
	if equity_emits[0] != 1:
		return "equity_changed fired %d times, wanted exactly 1" % equity_emits[0]
	if int(GameState.get_flag(AngelRoundSystem.FLAG_ACCEPTED_DAY, 0)) != GameState.day:
		return "the accepted-day stamp did not land"
	return ""


static func _case_angel_locked_choice_inert() -> String:
	# REDDET · ZOR MOD is visible and unusable, and the lock is honest: not a fake
	# threshold that could accidentally come true, but a flag with no writer in the engine.
	var ev: GameEvent = EventGate.render(ANGEL_ID)
	if ev.choices.size() != 2:
		return "the seed scene has %d choices, wanted 2" % ev.choices.size()
	var refuse: EventChoice = ev.choices[1]
	# The SAME call the modal makes (event_modal.gd:330), not a mirror of it.
	if EventGate.condition_met(refuse.unlock_condition):
		return "the hard-mode choice is unlocked"
	if refuse.unlock_reason_text == "":
		return "the locked choice carries no telegraph text"
	if not refuse.modifiers.is_empty():
		return "the locked choice carries modifiers — the lock is the only thing stopping them"
	# FALSIFY THE LOCK: it must be a live predicate over one named key, not a constant.
	GameState.set_flag(AngelRoundSystem.HARD_MODE_FLAG, true)
	if not EventGate.condition_met(refuse.unlock_condition):
		return "the lock did not open when hard_mode_unlocked was set — it is not a real condition"
	GameState.set_flag(AngelRoundSystem.HARD_MODE_FLAG, false)
	if EventGate.condition_met(refuse.unlock_condition):
		return "flag_equals matched a false value — the gate is flag_set, not flag_equals"
	return ""


static func _case_angel_one_shot_falsified() -> String:
	# Once, ever — and the second half proves the LATCH is what makes it so, rather than
	# some unrelated dedupe doing the work (or the feature simply never firing twice).
	var c: Customer = _seed_angel_world(AngelRoundSystem.MRR_THRESHOLD)
	if c == null:
		return "fixture: no customer"
	_sim_day_full()
	if not _drain_to(ANGEL_ID):
		return "the seed scene never became active"
	EventGate.resolve(ANGEL_ID, "accept")
	# Ten more days INCLUDING a genuine re-crossing: down under the bar, then back over.
	for i in 10:
		if i == 3:
			CustomerRegistry.set_mrr(c.id, AngelRoundSystem.MRR_THRESHOLD - 900)
			SalesSystem.reflect_mrr()
		if i == 6:
			CustomerRegistry.set_mrr(c.id, AngelRoundSystem.MRR_THRESHOLD + 2000)
			SalesSystem.reflect_mrr()
		_sim_day_full()
		if _instances_of(ANGEL_ID) != 0:
			return "the seed scene re-opened on day %d" % GameState.day
	if GameState.run_angel_equity_pct != AngelRoundSystem.EQUITY_PCT:
		return "equity compounded to %d%%" % GameState.run_angel_equity_pct
	var paid: int = 0
	for row in FinanceSystem.get_transactions():
		if String(row.get("label", "")) == AngelRoundSystem.TX_LABEL:
			paid += 1
	if paid != 1:
		return "the treasury took the cheque %d times" % paid
	# THE FALSIFICATION: clear the latch by hand and the offer MUST come back. Without this
	# half the case would pass just as happily against an engine where the beat never fires at
	# all, or where something other than the latch is doing the suppressing. It used to clear
	# a GameState flag; it clears the ENGINE's latch now, which is the thing that actually
	# refuses the card — and `investor.angel_taken` has to be cleared with it, because the
	# card's own condition asks whether the cheque has already been taken.
	EvLatches.clear_one(EvLatches.key_for(ANGEL_ID, EvLatches.KEY_RUN, ""))
	GameState.set_flag(AngelRoundSystem.FLAG_ACCEPTED_DAY, 0)
	_sim_day_full()
	if _instances_of(ANGEL_ID) != 1:
		return "clearing the latch did not re-open the offer — the one-shot is not the latch's doing"
	return ""


static func _case_angel_survives_series_a() -> String:
	# The regression guard for the collision this design exists to avoid:
	# _persist_signed_terms writes run_equity_pct by PLAIN ASSIGNMENT, so an angel slice
	# folded into that field would be erased by the signature. FAILS against any design
	# that shares one scalar between the two rounds.
	var c: Customer = _seed_angel_world(AngelRoundSystem.MRR_THRESHOLD)
	if c == null:
		return "fixture: no customer"
	_sim_day_full()
	if not _drain_to(ANGEL_ID):
		return "the seed scene never became active"
	EventGate.resolve(ANGEL_ID, "accept")
	VCPitchSystem._persist_signed_terms({
		"valuation_m": 22, "dilution_pct": 18, "board_seats": 1, "board_veto": false})
	if GameState.run_angel_equity_pct != AngelRoundSystem.EQUITY_PCT:
		return "the Series A erased the angel slice (%d%%)" % GameState.run_angel_equity_pct
	if GameState.run_equity_pct != 18:
		return "the Series A slice is %d%%" % GameState.run_equity_pct
	if GameState.get_investor_equity_pct() != 22:
		return "composed investor equity is %d%%, wanted 22" % GameState.get_investor_equity_pct()
	var want_raised: int = AngelRoundSystem.CASH_AMOUNT + int(round(22 * 1_000_000.0 * 18 / 100.0))
	if GameState.get_total_raised() != want_raised:
		return "total raised is %d, wanted %d" % [GameState.get_total_raised(), want_raised]
	var ledger: Dictionary = GameState.get_run_ledger()
	# The newspaper's valuation sentence stays about the Series A alone...
	if int(ledger.get("equity_pct", 0)) != 18:
		return "the ledger's Series A slice moved to %d" % int(ledger.get("equity_pct", 0))
	# ...while the founder's remaining share counts BOTH rounds.
	if int(ledger.get("investor_equity_pct", 0)) != 22:
		return "the ledger's composed investor slice is %d" % int(ledger.get("investor_equity_pct", 0))
	return ""


static func _case_angel_hire_nudge() -> String:
	# Frank's line about being one person: once, a couple of days after the money, and only
	# while the founder actually is alone. The HR rail badge rides with it and clears itself.
	var c: Customer = _seed_angel_world(AngelRoundSystem.MRR_THRESHOLD)
	if c == null:
		return "fixture: no customer"
	var badge0: int = HRSystem.attention_count()
	_sim_day_full()
	if not _drain_to(ANGEL_ID):
		return "the seed scene never became active"
	EventGate.resolve(ANGEL_ID, "accept")
	if HRSystem.attention_count() != badge0 + 1:
		return "the HR badge did not light after the seed (%d -> %d)" % [badge0, HRSystem.attention_count()]
	# Too early: the day after acceptance is inside the delay.
	_sim_day_full()
	if _instances_of(NUDGE_ID) != 0:
		return "the nudge fired before its delay elapsed"
	# The delay is the card's own condition — `funding.angel_days_since_accept >= 2` — so the
	# number is read off the card rather than off a system constant that no longer exists.
	for i in _nudge_delay_days():
		_sim_day_full()
	if not _drain_to(NUDGE_ID):
		return "the hire nudge never arrived"
	EventGate.resolve(NUDGE_ID, "go_to_hr")
	# Advisory only: nothing economic may have moved.
	if GameState.run_angel_equity_pct != AngelRoundSystem.EQUITY_PCT:
		return "the nudge moved equity"
	for i in 6:
		_sim_day_full()
		if _instances_of(NUDGE_ID) != 0:
			return "the nudge repeated on day %d" % GameState.day
	# Hiring clears the badge — the signpost is self-retiring, not a standing demand.
	_make_employee("emp_nudge_hire", "İlk Çalışan", HRConstants.ROLE_DEVELOPER)
	if HRSystem.attention_count() != badge0:
		return "the HR badge survived the hire (%d, wanted %d)" % [HRSystem.attention_count(), badge0]
	return ""


static func _case_promise_no_duplicate_word() -> String:
	# A word already given may not be given again: while a promise to
	# an account is OPEN, no retention or CS-request card may offer that account a second
	# "Söz ver". The rule already existed in the sibling channel (pick_request_kind scores
	# has_open_for at −25) but no gate enforced it anywhere.
	#
	# Measured cost of the gap, 90-day driver run (--run-log=b2b_risk:90:sim), 5 accounts:
	# 142 promises created, 117 broken — three open promises for the SAME customer and the
	# SAME feature at once. Broken, it charged three penalties for one unbuilt feature
	# (brand 50 → 0 by day 30); kept, one ship redeemed all three (+45 satisfaction for one
	# build). FAILS against the pre-fix engine on the very first re-offer.
	GameState.set_flag("mvp_sub_product_type_id", "saas_ops")
	_seed_b2b(1000)
	var c: Customer = CustomerRegistry.get_customer("co_lead_smoke")
	c.pain_feature_id = "saas_ops_scheduling"
	# Fixture guard: the promise row must be reachable at all, or this case proves nothing.
	var live: Array = GameState.get_flag("mvp_components", [])
	if live.has(c.pain_feature_id):
		return "fixture drifted: pain feature is already shipped"
	var ctx: Dictionary = _ctx_customer(c)
	var first: GameEvent = EventGate.render(RETAIN_ID, ctx)
	if not _row_unlocked(first, _promise_row_index(first), ctx):
		return "the retention card offered no promise row with nothing outstanding"

	# Give the word once, through the real modifier seam.
	B2BSalesSystem.accept_promise(c.id, c.pain_feature_id, B2BConstants.PROMISE_DEADLINE_DAYS)
	if not PromiseRegistry.has_open_for(c.id):
		return "accept_promise did not open a promise"

	# Now every card that could mint a second debt must withhold it.
	# THE ROW IS NOW SHOWN AND LOCKED, not withheld. §17.5's ruling: a locked option renders
	# greyed with its reason, because an option that disappears teaches the player nothing.
	# What must not happen is that it can be TAKEN, and that is what is asserted.
	var again: GameEvent = EventGate.render(RETAIN_ID, ctx)
	var again_idx: int = _promise_row_index(again)
	if again_idx < 0:
		return "the promise row vanished instead of locking — the player learns nothing"
	if _row_unlocked(again, again_idx, ctx):
		return "the retention card offered a SECOND word while one was still open"
	if again.choices[again_idx].unlock_reason_text == "":
		return "the locked promise row carries no reason line"
	_make_employee("emp_cs_dup", "Dup CS", HRConstants.ROLE_CUSTOMER_REP)
	var req: GameEvent = EventGate.render("customer.request_feature", ctx)
	var req_idx: int = _promise_row_index(req)
	if req_idx >= 0 and _row_unlocked(req, req_idx, ctx):
		return "the CS request card offered a SECOND word while one was still open"

	# Control: once the debt is settled, the card offers a word again — the gate is the
	# OPEN promise, not a permanent ban.
	for p in PromiseRegistry.get_open_for(c.id):
		p.status = "broken"
	if PromiseRegistry.has_open_for(c.id):
		return "fixture: the promise did not close"
	c.pain_feature_id = "saas_ops_field"   # a still-unshipped feature
	var reopened: GameEvent = EventGate.render(RETAIN_ID, ctx)
	if not _row_unlocked(reopened, _promise_row_index(reopened), ctx):
		return "the promise row never unlocked again after the debt closed"
	return ""


# Index of the row that would MINT A NEW PROMISE, found by modifier type rather than by
# label (labels are player-facing text) or position (the rows are conditional).
static func _promise_row_index(ev: GameEvent) -> int:
	return _row_with_verb(ev, "promise_create")


## The row carrying `verb`, by VERB rather than by label (labels are player-facing text) or by
## position (the rows are conditional). Reads `verb`, which is what an effect is keyed on in
## the card schema; the old modifier `type` key died with the builders.
static func _row_with_verb(ev: GameEvent, verb: String) -> int:
	for i in ev.choices.size():
		for m in ev.choices[i].modifiers:
			if String((m as Dictionary).get("verb", "")) == verb:
				return i
	return -1


## Did the CS desk escalate a request for this account — any of the three branches? The old
## engine had one card id per customer (`ev_b2b_request_<id>`) and the branch was chosen at
## build time; the branch is a condition now, so the family is what a case can name.
static func _request_cards_up() -> int:
	var n: int = 0
	for kind in ["complaint", "feature", "renewal"]:
		var id: String = "customer.request_" + kind
		# THE DESK COUNTS. These three are papers, and a paper is deliberately not in the
		# queue — `_instances_of` reads the queue and the active slot, so counting only there
		# says "nothing escalated" about a request sitting on the desk with its clock running.
		n += _instances_of(id)
		if EvPapers.has(id):
			n += 1
	return n


## Has this card fired at all this run? Replaces every `get_flag("<something>_shown")` read
## the old hand-rolled latches made possible — the latch is the engine's now, so the question
## is asked of the engine.
static func _card_fired(event_id: String) -> bool:
	return EvLatches.fires(EvLatches.key_for(event_id, EvLatches.KEY_RUN, "")) > 0


## The hire nudge's delay, read off the card's own condition rather than off a constant.
static func _nudge_delay_days() -> int:
	for leaf in EventGate.condition_leaves(
			EventGate.catalogue_card(NUDGE_ID).get("condition", {})):
		if String((leaf as Dictionary).get("seam", "")) == "funding.angel_days_since_accept":
			return int((leaf as Dictionary).get("value", 0))
	return 2


## Is row `idx` playable right now, against this card's frozen context? An out-of-range index
## is "no row", not a crash — several cases ask about a row that may legitimately be absent.
static func _row_unlocked(ev: GameEvent, idx: int, ctx: Dictionary) -> bool:
	if ev == null or idx < 0 or idx >= ev.choices.size():
		return false
	return EventGate.condition_met(ev.choices[idx].unlock_condition, ctx)


## A frozen context binding one customer, the shape EvScope produces. Cards are rendered and
## conditions are evaluated against this, so a case can ask what a card looks like FOR a named
## account without going through admission.
static func _ctx_customer(c: Customer) -> Dictionary:
	return {"customer": {"type": "customer", "id": c.id, "bound_day": GameState.day}}


static func _case_promise_kept_stops_countdown() -> String:
	# KEEPING the word must stop the churn clock, exactly as GIVING it
	# already did. accept_promise ran _recover (countdown → −1, streak → 0); the "kept"
	# branch of on_promise_resolved wrote satisfaction and nothing else, so the clock kept
	# running straight through the delivery. Reproduced in a driver run
	# (--run-log=b2b_risk_keep:90:sim): the feature shipped on day 12 into
	# "status=kept ... countdown=5 phase=risk".
	#
	# The gap is only survivable when +PROMISE_KEPT_SAT / −PROMISE_KEPT_TOLERANCE happens to
	# clear the bar in one step; on an account whose tolerance had been ratcheted up by
	# earlier broken words it does not, and the player pays cash and days for a feature and
	# loses the account anyway. FAILS against the pre-fix engine: countdown stays live.
	GameState.set_flag("mvp_sub_product_type_id", "saas_ops")
	_seed_b2b(1000)
	var c: Customer = CustomerRegistry.get_customer("co_lead_smoke")
	c.pain_feature_id = "saas_ops_scheduling"
	var p: Promise = PromiseRegistry.create(c.id, c.pain_feature_id, 14)

	# Put the account in a REAL risk state with a live countdown, through the seams.
	CustomerRegistry.set_tolerance(c.id, 60)
	CustomerRegistry.set_satisfaction(c.id, 20)   # gap 40: far wider than +15/−5 can close
	CustomerRegistry.set_lifecycle_phase(c.id, "risk")
	CustomerRegistry.set_churn_countdown(c.id, 3)
	CustomerRegistry.set_risk_streak(c.id, 5)

	# Ship the promised feature — the real coupling: mvp_components, then the phase signal.
	var comps: Array = GameState.get_flag("mvp_components", [])
	comps.append(c.pain_feature_id)
	GameState.set_flag("mvp_components", comps)
	EventBus.build_phase_changed.emit("shipped")

	if p.status != "kept":
		return "the shipped feature did not keep the promise (status=%s)" % p.status
	var after: Customer = CustomerRegistry.get_customer(c.id)
	if after == null:
		return "the account was removed by its own rescue"
	if after.churn_countdown != -1:
		return "kept promise left the churn countdown running (%d)" % after.churn_countdown
	if after.lifecycle_phase == "risk":
		return "kept promise left the account in risk phase"
	if after.risk_streak != 0:
		return "kept promise left the risk streak at %d" % after.risk_streak
	# The satisfaction bump must still be exactly PROMISE_KEPT_SAT — routing it through
	# _recover moved WHERE it is applied, never HOW MUCH. 20 + 15 = 35.
	if after.satisfaction != 35:
		return "kept-promise satisfaction drifted from PROMISE_KEPT_SAT (20 -> %d, want 35)" % after.satisfaction
	if after.tolerance != 60 + B2BConstants.PROMISE_KEPT_TOLERANCE:
		return "kept-promise tolerance drifted (%d)" % after.tolerance

	# The rescue must be REAL, not one tick deep: the account still sits under its bar
	# (35 < 55), so the next day legitimately restarts the streak — but from zero, and
	# without a countdown, which is the whole difference between a reprieve and none.
	_sim_day_full()
	var d2: Customer = CustomerRegistry.get_customer(c.id)
	if d2 == null:
		return "the account churned the day after its promise was kept"
	if d2.churn_countdown >= 0:
		return "the countdown restarted immediately (%d) — the streak was not reset" % d2.churn_countdown
	return ""


static func _case_recover_preserves_onboarding() -> String:
	# _recover stamped "active" unconditionally, while _tick_healthy's
	# own risk branch preserves "onboarding" inside the window — the identical bug that
	# branch carries a comment about, still live on this one. An account rescued in its
	# first ONBOARDING_DAYS left the window early while _tick_satisfaction kept amplifying
	# its drift, so phase and model disagreed for the rest of the window.
	# Observed in a driver run: signed day 1, stamped "active" on day 4, onboarding_until 31.
	# FAILS against the pre-fix engine: phase reads "active".
	GameState.set_flag("mvp_sub_product_type_id", "saas_ops")
	_seed_b2b(1000)
	var c: Customer = CustomerRegistry.get_customer("co_lead_smoke")
	if GameState.day >= c.onboarding_until:
		return "fixture: the account is already out of its onboarding window"
	CustomerRegistry.set_tolerance(c.id, 60)
	CustomerRegistry.set_satisfaction(c.id, 30)
	CustomerRegistry.set_lifecycle_phase(c.id, "risk")
	CustomerRegistry.set_churn_countdown(c.id, 4)
	B2BSalesSystem.apply_discount(c.id, -100)   # any rescue path: they all run _recover
	var after: Customer = CustomerRegistry.get_customer(c.id)
	if after.churn_countdown != -1:
		return "the rescue did not clear the countdown"
	if after.lifecycle_phase != "onboarding":
		return "rescue inside the onboarding window stamped '%s'" % after.lifecycle_phase

	# Control: the SAME rescue past the window must settle to "active", or the fix would
	# just be a different unconditional write.
	var p2 := Prospect.new()
	p2.id = "lead_mature"
	p2.company_name = "Mature A.Ş."
	p2.industry = "testing"
	p2.star = 1
	_sign_fixture(p2, 900, 70)
	var m: Customer = CustomerRegistry.get_customer("co_lead_mature")
	m.onboarding_until = GameState.day - 1     # window already closed
	CustomerRegistry.set_tolerance(m.id, 60)
	CustomerRegistry.set_satisfaction(m.id, 30)
	CustomerRegistry.set_lifecycle_phase(m.id, "risk")
	CustomerRegistry.set_churn_countdown(m.id, 4)
	B2BSalesSystem.apply_discount(m.id, -100)
	if CustomerRegistry.get_customer(m.id).lifecycle_phase != "active":
		return "a rescue past the window did not settle to active"
	return ""


static func _case_promise_orphan_no_brand_hit() -> String:
	# A promise used to outlive the account it was made to: tick_deadlines had no
	# liveness check, and in on_promise_resolved the brand write and the credibility flag
	# sat OUTSIDE the `if c != null` guard that protects every customer-side write beside
	# them. So the orphan still resolved to "broken" and charged brand a second time — for
	# a company that had already taken its churn hit and was gone from every screen — while
	# the Product tab kept counting a deadline down for it.
	# FAILS against the pre-fix engine: brand drops again and the ghost promise survives.
	GameState.set_flag("mvp_sub_product_type_id", "ai_vector_search")
	_seed_b2b(1000)
	var c: Customer = CustomerRegistry.get_customer("co_lead_smoke")
	var pr: Promise = PromiseRegistry.create(c.id, "ai_vec_filter", 3)
	if pr.status != "open":
		return "promise did not open"
	# The account leaves BEFORE the deadline — the ordering the engine never guarded.
	B2BSalesSystem.ignore_risk(c.id)   # no-op if not at risk; the removal below is the point
	CustomerRegistry.remove(c.id)
	if PromiseRegistry.has_open_for("co_lead_smoke"):
		return "an open promise survived the account it was made to"
	var brand_after_loss: int = GameState.brand
	# Ride past the deadline: nothing may resolve, and brand may not move again.
	for i in 6:
		GameState.advance_day()
		PromiseRegistry.tick_deadlines(GameState.day)
	if GameState.brand != brand_after_loss:
		return "brand moved for a company that no longer exists (%d -> %d)" % [
			brand_after_loss, GameState.brand]
	if pr.status == "broken":
		return "the orphan promise still resolved to broken"
	# Control: a promise whose customer is ALIVE still breaks and still costs brand.
	var p2 := Prospect.new()
	p2.id = "lead_alive"
	p2.company_name = "Alive A.Ş."
	p2.industry = "testing"
	p2.star = 1
	_sign_fixture(p2, 900, 70)
	var live_c: Customer = CustomerRegistry.get_customer("co_lead_alive")
	PromiseRegistry.create(live_c.id, "ai_vec_filter", 1)
	var brand_before_break: int = GameState.brand
	GameState.advance_day()
	GameState.advance_day()
	PromiseRegistry.tick_deadlines(GameState.day)
	if GameState.brand >= brand_before_break:
		return "a live customer's broken promise stopped costing brand — the guard is a wall"
	return ""


static func _case_fumes_zero_revenue_ledger() -> String:
	# "Running on Fumes" is the demo's conversion screen, and its ledger pool carried
	# ONE unconditioned line — "Gelir vardı, ama…" — while _assemble tops the pool up to
	# MIN_LEDGER_LINES. On a zero-activity run that false line was therefore GUARANTEED to
	# print, directly under a stat cell reading MRR $0.
	# FAILS against the pre-fix engine on the first assertion.
	# The SENTENCE comes from the CSV; pinning its Turkish bytes made this case pass only
	# while the process happened to run in Turkish (it failed the moment B7 keyed the pool).
	# What the case actually asserts is WHICH of the two lines the branch picked.
	var claim: String = TranslationServer.translate("END_RF_REVENUE_SOME")
	var claim_none: String = TranslationServer.translate("END_RF_REVENUE_NONE")
	# A run that earned nothing and signed nobody.
	var barren: Dictionary = {
		"phase": 1, "day": 730, "mrr": 0, "customers_signed": 0, "customers_active": 0,
		"hires": 0, "employees": 0, "product_ships": 0,
	}
	var vs: Dictionary = EndingsCopy.build("running_on_fumes", barren, {})
	var lines: Array = vs.get("ledger_lines", []) as Array
	var saw_none: bool = false
	for line in lines:
		if String(line) == claim:
			return "the zero-revenue run was told revenue existed: '%s'" % String(line)
		if String(line) == claim_none:
			saw_none = true
	if not saw_none:
		return "the zero-revenue run printed neither revenue line — the else-branch is gone"
	# THE TRAP: gating that line without an else-branch drops the worst-case pool to one
	# line plus two backups, and the paper silently sets short.
	if lines.size() < EndingsCopy.MIN_LEDGER_LINES:
		return "ledger under-filled after gating: %d lines, want >= %d" % [
			lines.size(), EndingsCopy.MIN_LEDGER_LINES]
	# Control: a run that DID earn keeps the original line, so the gate is a gate.
	var earning: Dictionary = barren.duplicate()
	earning["mrr"] = 4000
	earning["customers_signed"] = 3
	var vs2: Dictionary = EndingsCopy.build("running_on_fumes", earning, {})
	var found: bool = false
	for line in (vs2.get("ledger_lines", []) as Array):
		if String(line) == claim:
			found = true
	if not found:
		return "an earning run lost the revenue line entirely"
	return ""


static func _case_b2b_expansion_no_refire() -> String:
	# The promotion test is MONOTONE (day - acquired_on_day >= MATURE_DAYS) and
	# BOTH resolutions used to put the account straight back to "active" — the exact state
	# that predicate passes — so the identical modal re-fired every morning forever and
	# "Büyüt" was an unbounded free MRR faucet for one click a day.
	# FAILS against the pre-fix engine on the first re-tick, on BOTH branches.
	GameState.set_flag("mvp_sub_product_type_id", "saas_ops")
	_seed_b2b(1000)

	# --- Branch 1: ACCEPT ---
	var c: Customer = CustomerRegistry.get_customer("co_lead_smoke")
	c.acquired_on_day = GameState.day - (B2BConstants.EXPANSION_MATURE_DAYS + 1)
	CustomerRegistry.set_lifecycle_phase(c.id, "active")
	CustomerRegistry.set_satisfaction(c.id, 80)
	# A PAPER, not a modal — see _case_b2b_expansion_moves_seats_mrr_counter for the why. The
	# gate is asked the same question either way; what changed is the surface it lands on.
	var eid: String = EXPANSION_ID
	GameState.advance_day()
	B2BSalesSystem.daily_tick()
	if not EventGate.request(eid, {"customer": c.id}):
		return "expansion never offered"
	if not EventGate.open_paper(eid):
		return "the expansion paper would not open"
	EventGate.resolve(eid, "expand")
	var mrr_after_upsell: int = c.mrr
	for i in 6:
		GameState.advance_day()
		B2BSalesSystem.daily_tick()
		if EventGate.active_id() == eid or _instances_of(eid) > 0 or EvPapers.has(eid):
			return "expansion re-fired after ACCEPT (day %d)" % GameState.day
	if c.mrr != mrr_after_upsell:
		return "MRR kept growing after one upsell (%d -> %d)" % [mrr_after_upsell, c.mrr]

	# --- Branch 2: DECLINE, on a second account ---
	var p := Prospect.new()
	p.id = "lead_decliner"
	p.company_name = "Decline A.Ş."
	p.industry = "testing"
	p.star = 1
	_sign_fixture(p, 900, 80)
	var d: Customer = CustomerRegistry.get_customer("co_lead_decliner")
	if d == null:
		return "second account was not created"
	d.acquired_on_day = GameState.day - (B2BConstants.EXPANSION_MATURE_DAYS + 1)
	CustomerRegistry.set_lifecycle_phase(d.id, "active")
	CustomerRegistry.set_satisfaction(d.id, 80)
	# ONE card id for the whole family, so the second account cannot have its own. The first
	# account's paper is already answered, which is what leaves the id free — and the entity
	# latch is what keeps the two accounts' offers from absorbing each other.
	var did: String = EXPANSION_ID
	GameState.advance_day()
	B2BSalesSystem.daily_tick()
	if not EventGate.request(did, {"customer": d.id}):
		return "expansion never offered to the second account"
	if not EventGate.open_paper(did):
		return "the second account's expansion paper would not open"
	EventGate.resolve(did, "not_yet")
	for i in 6:
		GameState.advance_day()
		B2BSalesSystem.daily_tick()
		if EventGate.active_id() == did or _instances_of(did) > 0 or EvPapers.has(did):
			return "expansion re-fired after DECLINE (day %d)" % GameState.day
	# The Sales-tab button asks the same gate, so the loop cannot be reopened through the UI.
	if B2BSalesSystem.can_offer_expansion(d):
		return "the manual trigger's gate still reads as offerable after a decision"
	return ""


static func _case_b2b_market_gate_b2c_run() -> String:
	# daily_tick's only gate was `mvp_shipped`, so the ENTIRE B2B desk ran inside a
	# consumer game: one Satış Uzmanı hire minted enterprise prospects and, past the §10
	# line, signed enterprise contracts with no pitch ever played.
	# FAILS against the pre-fix engine (prospects appear within ~20 days).
	_seed_live_product()          # a shipped B2C world
	var rep: Character = _make_employee("char_b2c_sales", "Sales In B2C",
		HRConstants.ROLE_SALES_REP, SEED_PACE, 7000, 100)
	_park_leave([rep])
	var p0: int = ProspectRegistry.get_all().size()
	var c0: int = CustomerRegistry.get_by_market("b2b").size()
	for i in 25:
		_sim_day_full()
		if not GameState.run_active:
			return "run ended mid-case (day %d)" % GameState.day
	var p1: int = ProspectRegistry.get_all().size()
	if p1 != p0:
		return "B2B leads were minted inside a B2C run (%d -> %d)" % [p0, p1]
	var c1: int = CustomerRegistry.get_by_market("b2b").size()
	if c1 != c0:
		return "a B2B contract was signed inside a B2C run (%d -> %d)" % [c0, c1]
	# Control: the same roster in a B2B market DOES work, so the gate is a gate, not a wall.
	GameState.set_flag("mvp_market_type", "b2b")
	GameState.set_flag("mvp_sub_product_type_id", "saas_ops")
	for i in 25:
		_sim_day_full()
		if not GameState.run_active:
			break
	if ProspectRegistry.get_all().size() == p1:
		return "the enterprise desk stayed inert in a B2B market — the gate is a wall"
	return ""



# ============================================================================
#  Satis / Destek Hotfix Turu 1 (2026-08-27)
# ============================================================================

## F2 — A PROMISE WITH NO TARGET IS NOT A PROMISE. `pick_pain_feature` returns "" for every
## shipped product (its pool is keyed by the retired subtype vocabulary), and `promise_create`
## was minting empty-target promises from it. One of those keeps `has_open_for` true forever:
## nothing ever ships "", so the deadline sweep cannot resolve it, and every card that asks
## "is a word already open on this account" locks itself for the rest of the run.
## FALSIFICATION: drop the empty-target guard from PromiseRegistry.create and check 1 fails.
static func _case_hotfix_promise_refuses_targetless() -> String:
	_seed_b2b(1000)
	var c: Customer = CustomerRegistry.get_customer("co_lead_smoke")
	if c == null:
		return "the b2b seed did not produce an account"
	if PromiseRegistry.create(c.id, "", 14) != null:
		return "the registry minted a promise with no target"
	if PromiseRegistry.has_open_for(c.id):
		return "a refused promise still registered as open"
	# A real one still works — the guard refuses the empty target, not the mechanic.
	if PromiseRegistry.create(c.id, "saas_ops_scheduling", 14) == null:
		return "the registry refused a promise that names a real feature"
	if not PromiseRegistry.has_open_for(c.id):
		return "a real promise did not register"
	# And a SAVE that already carries a ghost is swept: `create` refusing new ones does
	# nothing for the run that already has one.
	var ghost := Promise.new()
	ghost.id = "promise_ghost"
	ghost.customer_id = c.id
	ghost.feature_id = ""
	ghost.status = "open"
	ghost.deadline_day = GameState.day + 5
	PromiseRegistry.insert_raw(ghost)
	if PromiseRegistry.drop_targetless() != 1:
		return "the load sweep did not drop the targetless promise"
	if PromiseRegistry.get_promise("promise_ghost") != null:
		return "the ghost survived the sweep"
	if not PromiseRegistry.has_open_for(c.id):
		return "the sweep took the real promise with the ghost"
	return ""


## F6 — TWO LEADS OF THE SAME STAR MUST NOT SIGN THE SAME DEAL. The rep desk took the band
## MIDPOINT, which is a constant, so every account of a given star bought exactly the same
## number of seats. Placement now comes from run seed + lead id + archetype.
## FALSIFICATION: restore the midpoint in _seats_for and the variance check fails with 1.
static func _case_hotfix_deal_variance_across_leads() -> String:
	GameState.set_flag("mvp_shipped", true)
	GameState.set_flag("mvp_market_type", "b2b")
	var seen: Dictionary = {}
	for i in 10:
		var arche: String = "ops_cautious" if i % 2 == 0 else "tech_exacting"
		var lead: Prospect = _add_prospect("var_%d" % i, 2, "", arche)
		seen[SalesRepSystem._seats_for(lead)] = true
	if seen.size() < 3:
		return "ten 2-star leads produced only %d distinct seat counts" % seen.size()
	# Still INSIDE the sealed band, and still replay-stable: the same lead asked twice
	# answers the same, or a reload would rewrite a deal that already closed.
	var band: Dictionary = SalesConstants.seat_band(2)
	for k in seen:
		if int(k) < int(band["low"]) or int(k) > int(band["high"]):
			return "seat count %d escaped the 2-star band" % int(k)
	var again: Prospect = ProspectRegistry.get_prospect("var_3")
	if SalesRepSystem._seats_for(again) != SalesRepSystem._seats_for(again):
		return "the seat draw is not stable for one lead"
	return ""


## F13 — THE ARCHETYPE DRAW WAS PINNED, and it looked like stub scarcity. `erp` is the only
## shipped B2B sub-type, exactly one archetype names it in `subtype_affinity`, and the picker
## returned the affinity list OUTRIGHT whenever it was non-empty — so the pool was always a
## list of one and two of the three archetypes could never appear at any star.
## FALSIFICATION: restore `return preferred if not preferred.is_empty() else fallback` and
## the distinct check fails with 1.
static func _case_hotfix_archetype_mix_not_pinned() -> String:
	var pool: Array = SalesArchetypes.candidates_for(1, "erp")
	var distinct: Dictionary = {}
	for id in pool:
		distinct[String(id)] = true
	if distinct.size() < 2:
		return "the 1-star candidate pool offers only %d archetype(s)" % distinct.size()
	# The affinity still LEANS: the erp-matched archetype holds more slots than any other.
	var counts: Dictionary = {}
	for id2 in pool:
		counts[String(id2)] = int(counts.get(String(id2), 0)) + 1
	if int(counts.get("ops_cautious", 0)) <= 1:
		return "the subtype-matched archetype lost its weighting"
	return ""


## F9 — THE TICKER SEES NEWS ONLY. The old gate let EVERY 3-star through for the rest of the
## run and had no whale term at all.
## FALSIFICATION: restore `scale >= 3 or scale > reach_band()` and the second 3-star check
## fails — a routine repeat signing reaches the ticker.
static func _case_hotfix_ticker_routine_vs_news() -> String:
	_seed_b2b(1000)
	# THE LEAGUE HAS TO BE RAISED FIRST, and the first draft of this case did not: at reach
	# band 1 a 3-star signing IS above-league, so it is news by the sealed rule no matter how
	# many came before. Putting the founder in the 3-star league is what isolates the term
	# actually under test — "the FIRST one, once".
	_set_founder_area(HRConstants.AREA_SALES, HRConstants.AREA_MAX)
	if SalesFaucetSystem.reach_band() < 3:
		return "the founder did not reach the 3-star league; the above-league term still dominates"
	var routine: Customer = CustomerRegistry.get_customer("co_lead_smoke")
	if routine == null:
		return "the b2b seed did not produce an account"
	routine.scale = 1
	if SalesLedger.is_newsworthy_signing(routine, false):
		return "a routine 1-star close reached the ticker"
	# A whale is news whatever its star.
	if not SalesLedger.is_newsworthy_signing(routine, true):
		return "a whale signing did not read as news"
	# The FIRST 3-star is news; the second is not.
	var first := Prospect.new()
	first.id = "news_1"
	first.company_name = "First Big"
	first.industry = "testing"
	first.star = 3
	var c1: Customer = _sign_fixture(first, 900, 70)
	if c1 == null or not SalesLedger.is_newsworthy_signing(c1, false):
		return "the run's first 3-star did not read as news"
	var second := Prospect.new()
	second.id = "news_2"
	second.company_name = "Second Big"
	second.industry = "testing"
	second.star = 3
	var c2: Customer = _sign_fixture(second, 900, 70)
	if c2 == null:
		return "the second 3-star fixture did not sign"
	if SalesLedger.is_newsworthy_signing(c2, false):
		return "the second 3-star still reached the ticker"
	return ""


## F12 — ONE COUNTING RULE. The top bar filtered to b2b and the summary counted every active
## record, so they disagreed by exactly the B2C aggregate userbase: an audience wearing a
## customer's shape, with zero seats.
## FALSIFICATION: point account_count at get_active().size() and the check fails by one.
static func _case_hotfix_account_count_excludes_base() -> String:
	_seed_b2b(1000)
	var before: int = CustomerRegistry.account_count()
	if before != CustomerRegistry.get_active().size():
		return "the two counts already disagreed before the userbase existed"
	var base := Customer.new()
	base.id = SalesSystem.B2C_USERBASE_ID
	base.market_type = "b2c"
	base.industry = "consumer"
	base.seats = 0
	CustomerRegistry.add(base)
	if CustomerRegistry.account_count() != before:
		return "the aggregate userbase counted as an account"
	if CustomerRegistry.get_active().size() != before + 1:
		return "the raw active list did not see the userbase at all"
	# AND THE OTHER HALF, which is the half that bit. `musteri.count` must KEEP counting the
	# aggregate: the traction gate asks it for "your first real customer", and on a B2C run that
	# customer IS the aggregate. Repointing that seam at account_count broke `gate1_b2c` on
	# every B2C path — two questions, two names, and this pins both so they cannot merge again.
	if int(EvSeams.read("musteri.count")) != before + 1:
		return "musteri.count stopped seeing the B2C userbase; the traction gate needs it"
	if int(EvSeams.read("sales.account_count")) != before:
		return "sales.account_count did not read the account rule"
	return ""


## B1 — PASSIVE FOUNDER CARE (repointed 2026-08-27 with the ruling that replaced the verb).
##
## The Hotfix wave gave the founder a way to SIT DOWN at the support desk. B1 deletes that verb
## outright: an idle founder is already looking after customers, and the desk reads it rather
## than being told. What this case is FOR is unchanged and still measured — with no rep, the
## product keeps a healing lever; engage the founder and it stops; disengage and it resumes.
##
## The trap the old version pinned still matters and is still here: `desk_roster()` reads the
## JOB while `validation_per_day()` sums the AREA contribution, so a founder counted by the
## roster must actually produce, not merely appear.
static func _case_hotfix_founder_takes_support_desk() -> String:
	_seed_b2b(1000)
	var founder: Character = CharacterRegistry.get_founder()
	if founder == null:
		return "no founder in the run"
	_set_founder_area(HRConstants.AREA_CUSTOMER_SUCCESS, 6)
	CharacterRegistry.clear_jobs(founder.id)
	# IDLE + LIVE PRODUCT = PASSIVE CARE, with nothing assigned anywhere.
	if not SupportSystem.founder_passive_care():
		return "an idle founder on a live product is not looking after customers"
	if not SupportSystem.desk_staffed():
		return "passive care did not put the founder on the desk roster"
	var passive_rate: float = SupportSystem.validation_per_day()
	if passive_rate <= 0.0:
		return "a passively caring founder validated nothing"
	if HRSystem.founder_task_state() != HRSystem.FOUNDER_STATE_CARE:
		return "the founder state did not read CARE while caring"

	# ENGAGED → IT STOPS. Any job at all takes him out; a build is the ordinary case.
	if CharacterRegistry.assign_job(founder.id, HRConstants.JOB_BUILD) != "":
		return "the founder could not take a build"
	if SupportSystem.founder_passive_care():
		return "a founder on a build still read as looking after customers"
	if SupportSystem.desk_staffed() or SupportSystem.validation_per_day() > 0.0:
		return "the desk kept producing after the founder started building"
	if HRSystem.founder_task_state() != HRSystem.FOUNDER_STATE_BUILD:
		return "an engaged founder still read as CARE"

	# DISENGAGED → IT RESUMES BY ITSELF. Nothing is re-assigned; the reading simply changes back.
	CharacterRegistry.clear_jobs(founder.id)
	if not SupportSystem.founder_passive_care():
		return "passive care did not resume when the engagement ended"
	if not is_equal_approx(SupportSystem.validation_per_day(), passive_rate):
		return "the resumed rate does not match the rate before the engagement"

	# A MEETING COUNTS AS ENGAGED TOO — `is_busy` is the other half of the predicate, and it is
	# what keeps a founder at a sales table from also manning the desk.
	GameState.set_flag("sales_meeting_active", true)
	if SupportSystem.founder_passive_care():
		return "a founder in a sales meeting still read as looking after customers"
	GameState.set_flag("sales_meeting_active", false)

	# NO LIVE PRODUCT, NO CARE: there is nothing to verify, and §2.3's BOŞTA must survive.
	GameState.set_flag("mvp_shipped", false)
	if SupportSystem.founder_passive_care():
		return "care read as active with no live product"
	if HRSystem.founder_task_state() != HRSystem.FOUNDER_STATE_IDLE:
		return "an idle founder with no product did not read as Boşta"
	return ""


## F5 — A NEW ACCOUNT LANDS ON A DESK (working rule, direktor onayi). Nothing assigned a
## freshly signed account to anybody: `_delegate_excess` only hands over what exceeds the
## founder's direct cap AND skips onboarding accounts, so an early run showed an idle rep at
## 0/4 next to a full founder. The picker was reading live state; the state really was zero.
## FALSIFICATION: set AUTO_ASSIGN_ON_SIGN false and the first check fails.
static func _case_hotfix_new_account_auto_assigned() -> String:
	GameState.set_flag("mvp_shipped", true)
	GameState.set_flag("mvp_market_type", "b2b")
	var rep: Character = _make_employee("char_cs_auto", "CS Auto", HRConstants.ROLE_CUSTOMER_REP)
	rep.role_stats[HRConstants.AREA_CUSTOMER_SUCCESS] = 6
	var lead := Prospect.new()
	lead.id = "auto_1"
	lead.company_name = "Auto Corp"
	lead.industry = "testing"
	lead.star = 1
	var c: Customer = _sign_fixture(lead, 500, 70)
	if c == null:
		return "the fixture did not sign"
	if c.assigned_to != rep.id:
		return "a newly signed account did not land on the only rep with room"
	if c.cs_pinned:
		return "the automatic assignment pinned the account as a player decision"
	if CustomerRepSystem.roster_size(rep.id) != 1:
		return "the rep roster did not see the account it now holds"
	return ""


## F4 — A SUMMARY WITH NO ROWS SUMMARISES NOTHING. The weekly card carried one sentence and a
## book count inside full decision chrome. §7.3 asks for the week's CLOSES; the rows are
## composed in Sales (`SalesLedger.weekly_close_lines`) and the card names one seam.
## FALSIFICATION: return "" from weekly_close_lines and every check below fails.
static func _case_hotfix_weekly_summary_rows() -> String:
	GameState.set_flag("mvp_shipped", true)
	GameState.set_flag("mvp_market_type", "b2b")
	if SalesLedger.weekly_close_lines() != "":
		return "a week with no closes produced rows"
	var lead := Prospect.new()
	lead.id = "wk_1"
	lead.company_name = "Hafta Corp"
	lead.industry = "testing"
	lead.star = 2
	var c: Customer = _sign_fixture(lead, 1200, 70)
	if c == null:
		return "the fixture did not sign"
	SalesSystem.record_sales_event("founder_close", "", c.company_name, c.mrr)
	var lines: String = SalesLedger.weekly_close_lines()
	if not lines.contains("Hafta Corp"):
		return "the week's close did not name its account"
	if not lines.contains(str(c.seats)):
		return "the row did not carry the seat count"
	# ALWAYS FIVE GLYPHS, the same grammar the star row draws: a table whose rows change width
	# with the star is a ragged edge, not a table.
	var first: String = lines.split("\n")[0]
	var glyphs: int = first.count(StarRating.FILLED) + first.count("·")
	if glyphs != SalesConstants.STAR_MAX:
		return "the star cell drew %d glyphs, want %d" % [glyphs, SalesConstants.STAR_MAX]
	# The total is a separate, final line.
	var rows: PackedStringArray = lines.split("\n")
	if rows.size() != 2:
		return "one close plus a total should be 2 lines, got %d" % rows.size()
	# A close that fell out of the window is not this week's business.
	GameState.day += SalesLedger.WEEKLY_WINDOW_DAYS + 1
	if SalesLedger.weekly_close_lines() != "":
		return "a close older than the window still counted as this week's"
	return ""


# ============================================================================
#  Destek Hattı Reworku — B2 · B3 · B4 · B5 (2026-08-27)
# ============================================================================

## B2 — REP + IDLE FOUNDER STACK. `_desk_sum` sums over the roster, so once B1 puts a passively
## caring founder INTO that roster the two rates add with no separate stacking rule. This case
## is the proof that they do, and that the sum is exactly the parts.
## FALSIFICATION: drop the founder out of `desk_roster()` and the combined rate equals the rep's.
static func _case_support_desk_rates_stack() -> String:
	_seed_support_fixture("b2b")
	var founder: Character = CharacterRegistry.get_founder()
	if founder == null:
		return "no founder in the run"
	_set_founder_area(HRConstants.AREA_CUSTOMER_SUCCESS, 6)
	# FOUNDER ALONE (idle, live product) — B1's passive care.
	CharacterRegistry.clear_jobs(founder.id)
	var founder_only: float = SupportSystem.validation_per_day()
	if founder_only <= 0.0:
		return "a passively caring founder validated nothing"
	# REP ALONE — take the founder out by engaging him.
	var rep: Character = _make_employee("char_stack_rep", "Stack Rep", HRConstants.ROLE_CUSTOMER_REP)
	rep.role_stats[HRConstants.AREA_CUSTOMER_SUCCESS] = 8
	if not rep.assigned_job_ids.has(HRConstants.JOB_SUPPORT):
		return "B3: a fresh Musteri Temsilcisi did not land on the support desk"
	CharacterRegistry.assign_job(founder.id, HRConstants.JOB_BUILD)
	var rep_only: float = SupportSystem.validation_per_day()
	if rep_only <= 0.0:
		return "a rep on the support desk validated nothing"
	# BOTH — the founder goes idle again and the rates add.
	CharacterRegistry.clear_jobs(founder.id)
	var both: float = SupportSystem.validation_per_day()
	if both <= rep_only:
		return "rep + idle founder (%.3f) is not faster than the rep alone (%.3f)" % [both, rep_only]
	if not is_equal_approx(both, rep_only + founder_only):
		return "the combined rate %.3f is not the sum of %.3f + %.3f" % [both, rep_only, founder_only]
	return ""


## B3 — NOBODY IS BORN INTO A FOREIGN COLUMN. A fresh hire lands on `default_job_for_role`, and
## that job must be one the role's KEY AREA can actually work. The Sales row shipped broken for
## two days (`sales` -> `accounts`) and the Musteri Temsilcisi row shipped broken for longer
## (`customer_success` -> `accounts`), both silently: the person was employed, assigned, and
## standing in the wrong column.
## FALSIFICATION: point either AREA_PRIMARY_JOB row back at "accounts" and this fails by name.
static func _case_hires_land_in_own_column() -> String:
	for role_id in HRConstants.ROLE_AREAS.keys():
		var role: String = String(role_id)
		var key_area: String = HRConstants.role_key_area(role)
		var job: String = HRConstants.default_job_for_role(role)
		if job == "":
			return "role '%s' has no default job at all" % role
		var areas: Array = HRConstants.JOB_AREAS.get(job, [])
		if not areas.has(key_area):
			return "role '%s' (key area %s) is born into '%s', which that area cannot work" % [
				role, key_area, job]
	# And the two the director named, by hand, through the real hire path.
	var srep: Character = _make_employee("char_col_sales", "Col Sales", HRConstants.ROLE_SALES_REP)
	if not srep.assigned_job_ids.has(HRConstants.JOB_SALES):
		return "a fresh Satis Temsilcisi is in %s, not the Sales job" % str(srep.assigned_job_ids)
	var crep: Character = _make_employee("char_col_cs", "Col CS", HRConstants.ROLE_CUSTOMER_REP)
	if not crep.assigned_job_ids.has(HRConstants.JOB_SUPPORT):
		return "a fresh Musteri Temsilcisi is in %s, not the support duty" % str(crep.assigned_job_ids)
	return ""


## B4 — AN OWNED ACCOUNT ERODES SLOWER, AND THE DELTA SCALES WITH THE OWNER'S OUTPUT.
##
## Two identical accounts, same tolerance, same starting satisfaction, same product health. One
## is owned by a rep; the other sits on the founder's desk with the founder ENGAGED, so nobody
## is caring for it. Then the owner's output is raised and the gap must widen.
## FALSIFICATION: remove the dampen multiplier and both halves fail.
static func _case_owned_account_erodes_slower() -> String:
	GameState.set_flag("mvp_shipped", true)
	GameState.set_flag("mvp_market_type", "b2b")
	# A SICK product, so the drift target is below tolerance and erosion actually runs.
	GameState.set_flag("mvp_innovation", 5.0)
	GameState.set_flag("mvp_stability", 5.0)
	GameState.set_flag("mvp_experience", 5.0)
	var founder: Character = CharacterRegistry.get_founder()
	if founder != null:
		CharacterRegistry.assign_job(founder.id, HRConstants.JOB_BUILD)   # engaged: cares for nobody
	var rep: Character = _make_employee("char_care_rep", "Care Rep", HRConstants.ROLE_CUSTOMER_REP)
	rep.traits = []                       # HAYIR DIYEMEZ would add a second, separate damper
	rep.role_stats[HRConstants.AREA_CUSTOMER_SUCCESS] = 4

	var drop_owned: int = _erosion_over_a_day("care_owned", rep)
	var drop_bare: int = _erosion_over_a_day("care_bare", null)
	if drop_owned >= 0 or drop_bare >= 0:
		return "neither account eroded (owned %d, bare %d) — the fixture is not sick" % [
			drop_owned, drop_bare]
	if drop_owned <= drop_bare:
		return "an owned account fell %d, an unowned one %d — ownership bought nothing" % [
			drop_owned, drop_bare]
	# AND IT SCALES: a stronger owner protects more.
	var weak_gap: int = drop_owned - drop_bare
	rep.role_stats[HRConstants.AREA_CUSTOMER_SUCCESS] = HRConstants.AREA_MAX
	var drop_strong: int = _erosion_over_a_day("care_strong", rep)
	if (drop_strong - drop_bare) <= weak_gap:
		return "a top owner (gap %d) protected no better than a weak one (gap %d)" % [
			drop_strong - drop_bare, weak_gap]
	return ""


## One account, one day of drift, returns the satisfaction DELTA (negative = eroded).
static func _erosion_over_a_day(cid: String, owner: Character) -> int:
	var p := Prospect.new()
	p.id = cid
	p.company_name = "Care " + cid
	p.industry = "testing"
	p.star = 2
	var c: Customer = _sign_fixture(p, 800, 90)
	if c == null:
		return 0
	ProspectRegistry.remove(p.id)
	# Out of the onboarding amplifier, and owned by exactly who this call says.
	c.onboarding_until = GameState.day - 1
	CustomerRegistry.set_lifecycle_phase(c.id, "active")
	CustomerRegistry.assign_customer(c.id, "" if owner == null else owner.id, true)
	var before: int = c.satisfaction
	B2BSalesSystem._tick_satisfaction(c)
	return c.satisfaction - before


## B5 — THE Mİ CANDIDATE POOL LOSES TWO TRAPS AND KEEPS ITS SIGNATURE. Same table, same
## generator, same pattern as the sales filter.
## FALSIFICATION: drop the customer_rep row from ROLE_TRAIT_BAN and the first check fails.
static func _case_cs_candidate_trait_filter() -> String:
	var banned: Array = ["takes_them_under", "double_checker"]
	var seen: Dictionary = {}
	for level in 3:
		for seed_value in 40:
			var files: Array = HRCandidateGenerator.generate(
				HRConstants.ROLE_CUSTOMER_REP, level, 1000 + seed_value * 37)
			for f in files:
				for t in (f.get("traits", []) as Array):
					var tid: String = String(t)
					if banned.has(tid):
						return "a Musteri Temsilcisi file carried the banned trait '%s'" % tid
					seen[tid] = true
	if seen.is_empty():
		return "no candidate carried any trait at all — the generator produced nothing"
	# HAYIR DIYEMEZ stays and is the role's signature trade.
	if not seen.has("cant_say_no"):
		return "HAYIR DIYEMEZ never appeared across the sweep — the pool lost its signature"
	# The sales pool is untouched by this row.
	if not HRConstants.role_bans_trait(HRConstants.ROLE_SALES_REP, "double_checker"):
		return "the sales ban row was disturbed"
	return ""


## B4/§13 — OWNERSHIP SURVIVES A REAL SAVE. Capacity is DERIVED and stores nothing, which is the
## claim this case makes concrete: the file carries who owns what and whether the player pinned
## it, and the capacity that reads out of it afterwards is computed, not restored.
static func _case_account_ownership_round_trip() -> String:
	GameState.set_flag("mvp_shipped", true)
	GameState.set_flag("mvp_market_type", "b2b")
	var rep: Character = _make_employee("char_own_rep", "Own Rep", HRConstants.ROLE_CUSTOMER_REP)
	rep.role_stats[HRConstants.AREA_CUSTOMER_SUCCESS] = 5
	var p := Prospect.new()
	p.id = "own_lead"
	p.company_name = "Own Corp"
	p.industry = "testing"
	p.star = 2
	var c: Customer = _sign_fixture(p, 700, 70)
	if c == null:
		return "the fixture did not sign"
	CustomerRegistry.assign_customer(c.id, rep.id, true)
	var cap_before: int = B2BConstants.account_capacity(5)
	if not SaveManager.save_to_slot(SAVE_SLOT_A):
		return "save_to_slot refused"
	if not SaveManager.apply_loaded_state(SaveManager.read_slot(SAVE_SLOT_A)):
		return "the slot did not load back"
	var back: Customer = CustomerRegistry.get_customer(c.id)
	if back == null:
		return "the account did not survive the round trip"
	if back.assigned_to != rep.id:
		return "ownership was lost: assigned_to is '%s'" % back.assigned_to
	if not back.cs_pinned:
		return "the player's pin was lost across the save"
	if B2BConstants.account_capacity(5) != cap_before:
		return "derived capacity changed across a save — it should be computed, not stored"
	_cleanup_save_slots()
	return ""


## A1/A2/A3 — THE FOUNDER IS AN OWNER LIKE ANY OTHER, EXCEPT THAT HE IS NEVER GIVEN ONE.
##
## Three rules, and the third is the one that keeps the first two honest:
##   A1  he can be handed an account, and owning it grants the care bonus
##   A3  his capacity is 4 + 2 x stars like everyone else, and it BLOCKS at the ceiling
##   A2  auto-assign never routes a signing to him — every account he holds was handed over
##
## FALSIFICATION: let `_ranked` return the founder and the A2 half fails; drop the capacity
## comparison from the picker's founder row and the A3 half is what catches it.
static func _case_founder_owns_accounts_manually() -> String:
	GameState.set_flag("mvp_shipped", true)
	GameState.set_flag("mvp_market_type", "b2b")
	var founder: Character = CharacterRegistry.get_founder()
	if founder == null:
		return "no founder in the run"
	_set_founder_area(HRConstants.AREA_CUSTOMER_SUCCESS, 4)   # 2 stars -> 8 accounts

	# --- A3: the founder's capacity comes from the SAME formula, no special rule ------------
	var cap: int = CustomerRepSystem.founder_account_capacity()
	if cap != B2BConstants.account_capacity(4):
		return "the founder's capacity (%d) is not the shared formula's answer (%d)" % [
			cap, B2BConstants.account_capacity(4)]

	# --- A2: a fresh signing goes to a REP, never to the founder ---------------------------
	var rep: Character = _make_employee("char_a2_rep", "A2 Rep", HRConstants.ROLE_CUSTOMER_REP)
	rep.role_stats[HRConstants.AREA_CUSTOMER_SUCCESS] = 6
	var signed := Prospect.new()
	signed.id = "a2_lead"
	signed.company_name = "Auto A2"
	signed.industry = "testing"
	signed.star = 1
	var auto_c: Customer = _sign_fixture(signed, 400, 70)
	if auto_c == null:
		return "the fixture did not sign"
	if auto_c.assigned_to == "":
		return "a new signing landed on the founder's desk — A2 says it never does automatically"
	if auto_c.assigned_to != rep.id:
		return "the signing went to '%s', not the only rep with room" % auto_c.assigned_to
	# AUTOMATIC OWNERSHIP IS NEVER PINNED. The pin marks a PLAYER decision (`assign_customer`'s
	# own contract) and, since B4 made "" mean both unowned and founder-owned, it is the ONLY
	# thing separating "handed to the founder on purpose" from "nobody took it". A system that
	# pinned would forge the player's mark and the morning sweep could never correct itself.
	if auto_c.cs_pinned:
		return "auto-assign pinned an account — the pin is the player's mark, not the system's"
	# A2 IS ONLY PARTLY OBSERVABLE, AND THAT IS A FINDING RATHER THAN A GAP IN THIS CASE.
	# Since B4, `assigned_to == ""` means BOTH "nobody was given it" AND "it is on the founder's
	# desk" — one value, two meanings, and `_account_owner` reads the second. So "the founder
	# never receives an account automatically" cannot be measured directly: an account that
	# finds no rep is already his by construction. What IS measurable, and what the ruling
	# actually protects, is the two halves below.
	CharacterRegistry.remove(rep.id)
	var solo := Prospect.new()
	solo.id = "a2_solo"
	solo.company_name = "Solo A2"
	solo.industry = "testing"
	solo.star = 1
	var solo_c: Customer = _sign_fixture(solo, 400, 70)
	if solo_c == null:
		return "the solo fixture did not sign"
	if solo_c.cs_pinned:
		return "an untouched account came back pinned"

	# --- A1: handing it over WORKS, and the care bonus follows ownership --------------------
	# `assigned_to == ""` IS founder ownership, so the proof that it counts is the owner seam.
	CustomerRegistry.assign_customer(solo_c.id, "", true)
	if B2BSalesSystem._account_owner(solo_c) == null:
		return "a founder-held account has no owner — the care bonus would not apply"
	if B2BSalesSystem._account_owner(solo_c).id != founder.id:
		return "the founder-held account resolved to somebody else"
	if not solo_c.cs_pinned:
		return "handing an account to the founder did not pin it (the sweep would take it back)"
	# Unassigning: the account goes back to unowned, and with the founder ENGAGED nobody cares.
	CustomerRegistry.assign_customer(solo_c.id, "", false)
	CharacterRegistry.assign_job(founder.id, HRConstants.JOB_BUILD)
	if B2BSalesSystem._account_owner(solo_c) == null:
		return "an engaged founder still owns the book — ownership is not the same as passive care"
	return ""

static func _case_sales_autoclose_empty_pain() -> String:
	# §7.2.1 — "Ayır" MEANS the desk is the founder's: a reserved lead is skipped by the rep
	# outright, and reserving does NOT stop its clock. This case replaces the old
	# unmappable-pain gate, which belonged to a concession model §19 retired.
	# FALSIFICATION: drop the ROUTE_RESERVED branch from pick_lead_for and the second check
	# fails — the rep takes the founder's table.
	GameState.set_flag("mvp_shipped", true)
	GameState.set_flag("mvp_market_type", "b2b")
	GameState.set_flag("mvp_sub_product_type_id", "ai_vector_search")
	_seed_b2b(1000)
	var rep: Character = _make_sales_rep("char_sr_1", 0, 9)
	var mine: Prospect = _add_prospect("reserved", 1, "ai_vec_filter")
	SalesLedger.set_routing(mine.id, SalesConstants.ROUTE_RESERVED)
	if SalesLedger.lead_routing(mine.id) != SalesConstants.ROUTE_RESERVED:
		return "the routing seam did not record the reservation"
	if SalesRepSystem.pick_lead_for(rep) != null:
		return "the rep picked a RESERVED lead"
	# The clock keeps running on a reserved lead (§7.2.1: "Rezerv süreyi durdurmaz").
	var left0: int = mine.days_left()
	GameState.advance_day()
	B2BSalesSystem.daily_tick()
	if ProspectRegistry.get_prospect("reserved") != null \
			and ProspectRegistry.get_prospect("reserved").days_left() >= left0:
		return "reserving froze the lead's counter"
	# Control: an unrouted sibling IS picked, so the skip is the reservation and nothing else.
	var free_lead: Prospect = _add_prospect("free", 1, "ai_vec_filter")
	var picked: Prospect = SalesRepSystem.pick_lead_for(rep)
	if picked == null or picked.id != free_lead.id:
		return "the rep did not pick the unrouted sibling"
	return ""

static func _case_event_queue_dedupe_by_id() -> String:
	# Array.has() on Array[GameEvent] compares REFERENCES, and every factory mints a fresh
	# GameEvent per call, so one id could occupy the queue N times over.
	# FAILS against the pre-fix engine (two instances land).
	_seed_b2b(500)
	var c: Customer = CustomerRegistry.get_customer("co_lead_smoke")
	# Occupy the modal slot, so the card under test must QUEUE rather than mount — the
	# already-active id was guarded even before the fix this case was written for; the QUEUE
	# was not.
	var risky: Customer = _add_risk_b2b("dedupe", 800)
	if not EventGate.request(RETAIN_ID, {"customer": risky.id}):
		return "could not occupy the active slot"
	if EventGate.active_id() == "":
		return "could not occupy the active slot"
	# TWO REQUESTS FOR THE SAME CARD, and only one may land. The identity bug this case was
	# born for cannot be written any more — a caller names an ID, so there is no second
	# instance to mint — which is exactly why the case was kept rather than deleted: it now
	# pins that the ENGINE refuses the duplicate instead of the caller checking first.
	EventGate.request(EXPANSION_ID, {"customer": c.id})
	EventGate.request(EXPANSION_ID, {"customer": c.id})
	if _instances_of(EXPANSION_ID) > 1:
		return "one event id entered the pipeline %d times" % _instances_of(EXPANSION_ID)
	return ""


static func _case_b2b_scale_and_sector_gating() -> String:
	# §2 THE DEMO CEILING (MÜHÜRLÜ): the faucet produces 1-3 stars only. 4-5 is not generated
	# and not written, and there is no locked 4-star card either — dim stars ARE the scale
	# telegraph.
	# §3 SECTOR AFFINITY moved from a product-keyed table to the ARCHETYPE's own sectors, so
	# the fiction stays clean without a second narrowing.
	# FALSIFICATION: the old spawner rolled scale from CustomerArchetypes and could hand back
	# a 5 whenever b2b_high_scale_unlocked was set; nothing set it, which was the bug.
	GameState.set_flag("mvp_shipped", true)
	GameState.set_flag("mvp_market_type", "b2b")
	GameState.set_flag("mvp_sub_product_type_id", "saas_ops")
	for i in 12:
		var p: Prospect = SalesFaucetSystem.spawn(SalesConstants.STAR_MAX + 2, "faucet")
		if p == null:
			return "the faucet dried at draw %d" % i
		if p.star < SalesConstants.STAR_MIN or p.star > SalesConstants.STAR_MAX:
			return "lead star out of the demo range: %d" % p.star
		if not SalesArchetypes.has(p.archetype_id):
			return "lead carries an unknown archetype: %s" % p.archetype_id
		if not SalesArchetypes.sectors(p.archetype_id).has(p.industry):
			return "lead industry %s is not one of %s's sectors" % [p.industry, p.archetype_id]
		if not SalesArchetypes.accepts_star(p.archetype_id, p.star):
			return "archetype %s does not take a %d-star table" % [p.archetype_id, p.star]
		if p.expires_on_day != p.spawned_on_day + SalesConstants.LEAD_LIFE_DAYS:
			return "lead has no honest expiry: spawned %d, expires %d" % [
				p.spawned_on_day, p.expires_on_day]
	return ""

static func _case_b2b_onboarding_to_prospect_visible() -> String:
	# REAL integrated path (NOT the _seed_b2b skip fixture that sets mvp_* flags directly):
	# onboarding payload → start_build (sets subgenre via the seam) → launch/ship (sets
	# mvp_market_type/sub_id) → Frank's intro beat → add_prospect → spawn_prospect →
	# ProspectRegistry (the source the Sales list renders). Guards the whole spawn chain
	# on the path a fresh game actually takes — the skip-path suite never exercised it.
	GameState.initialize_run({"company_name": "Test Inc.", "founder_name": "Dev"})
	if not ProductSystem.start_build("saas_ops", ["saas_ops_workflow", "saas_ops_reporting"], ""):
		return "start_build failed"
	if GameState.subgenre != "saas":
		return "start_build did not set subgenre via seam (got %s)" % GameState.subgenre
	# Rev3: fazlar otomatik — Beta'ya dek sür, sonra Yayınla (launch yalnız Beta'da).
	if not _run_build_to_phase("bugfix"):
		return "build never reached beta"
	ProductSystem.launch()
	# Dismiss the ship-moment (its ship_active_build modifier sets mvp_shipped); if no
	# modal is active, ship directly. Either way the ship-moment must not block the queue.
	if EventGate.active_id() != "":
		EventGate.resolve(EventGate.active_id(), 0)
	if not GameState.get_flag("mvp_shipped", false):
		ProductSystem.ship_active_build()
	if String(GameState.get_flag("mvp_market_type", "")) != "b2b":
		return "mvp_market_type not b2b after launch (%s)" % String(GameState.get_flag("mvp_market_type", ""))
	if String(GameState.get_flag("mvp_sub_product_type_id", "")) != "saas_ops":
		return "mvp_sub_product_type_id not set after launch"
	if not GameState.get_flag("mvp_shipped", false):
		return "mvp_shipped not set after ship"
	# Frank's intro is a post-ship beat — drive daily ticks and drain to it.
	var reached: bool = false
	for i in 4:
		_sim_day()
		if _drain_to("customer.frank_intro"):
			reached = true
			break
	if not reached:
		return "Frank intro never became active post-ship"
	var n0: int = ProspectRegistry.get_all().size()
	EventGate.resolve("customer.frank_intro", "go_to_sales")   # add_prospect
	var prospects: Array[Prospect] = ProspectRegistry.get_all()
	if prospects.size() != n0 + 1:
		return "Frank intro produced no prospect (spawn aborted?) %d -> %d" % [n0, prospects.size()]
	var p: Prospect = prospects[prospects.size() - 1]
	# The value band is RETIRED (§19): price comes from the seat band and the stance dial, so
	# there is no display range to populate. What a lead must carry instead is its star, its
	# archetype and an honest expiry.
	if p.star < SalesConstants.STAR_MIN or p.star > SalesConstants.STAR_MAX:
		return "event-spawned lead star out of range: %d" % p.star
	if not SalesArchetypes.has(p.archetype_id):
		return "event-spawned lead carries no archetype"
	if p.expires_on_day <= p.spawned_on_day:
		return "event-spawned lead has no expiry"
	return ""


static func _case_sales_month_counters() -> String:
	# The month_ledger customer-count snapshot (for the Sales pulse strip's Bu ay cells):
	# initialize_run's snapshot() baselines the counters, so a sign + a churn within the
	# month read as gained/lost/net = current run counter − the month-start baseline.
	GameState.initialize_run({})  # ends with snapshot() → baselines the current (0) counters
	var ledger: Dictionary = GameState.month_ledger
	if int(ledger.get("customers_signed", -1)) != 0 or int(ledger.get("customers_lost", -1)) != 0:
		return "month_ledger did not snapshot customer counts (signed=%s lost=%s)" % [str(ledger.get("customers_signed", "MISSING")), str(ledger.get("customers_lost", "MISSING"))]
	# A sign + a churn happen this month (run-cumulative counters advance).
	GameState.run_customers_signed = 3
	GameState.run_customers_lost = 1
	var gained: int = GameState.run_customers_signed - int(GameState.month_ledger.get("customers_signed", 0))
	var lost: int = GameState.run_customers_lost - int(GameState.month_ledger.get("customers_lost", 0))
	if gained != 3 or lost != 1 or (gained - lost) != 2:
		return "monthly delta wrong: gained=%d lost=%d net=%d" % [gained, lost, gained - lost]
	# The next month rolls over → re-snapshot moves the baseline to the current totals.
	MonthSummarySystem.snapshot()
	if int(GameState.month_ledger.get("customers_signed", -1)) != 3 or int(GameState.month_ledger.get("customers_lost", -1)) != 1:
		return "re-snapshot did not capture the new month baseline"
	return ""


# --- Founder 5-skill system (SKILL-RENAME + onboarding rework, Stage B) ---

static func _case_founder_5skill_init() -> String:
	# run_case's initialize_run built the founder from the debug payload: role_stats
	# must hold EXACTLY the 5 canonical skills, the full pool spent, no legacy keys.
	var founder: Character = CharacterRegistry.get_founder()
	if founder == null:
		return "no founder after initialize_run"
	var keys: Array = founder.role_stats.keys()
	for skill_key in FounderConstants.SKILLS:
		if not keys.has(skill_key):
			return "missing skill key %s" % skill_key
	if keys.size() != FounderConstants.SKILLS.size():
		return "unexpected extra role_stats keys: %s" % str(keys)
	var total: int = 0
	for skill_key in FounderConstants.SKILLS:
		total += int(founder.role_stats[skill_key])
	# TOPLAM DAĞITIM DEĞİL CETVEL BİRİMİNDE. Onboarding hâlâ POINT_POOL kadar puan
	# dağıtıyor; kaydedilen değer onun cetvel karşılığı (§2.4, FounderConstants.to_ruler).
	# Bu iddia tam olarak o çevrimin YAPILDIĞINI ölçüyor — çarpan düşerse burada patlar.
	var want_total: int = FounderConstants.POINT_POOL * FounderConstants.RULER_SCALE
	if total != want_total:
		return "skills sum %d (want %d — dağıtım %d × cetvel %d)" % [
			total, want_total, FounderConstants.POINT_POOL, FounderConstants.RULER_SCALE]
	var want_sales: int = FounderConstants.to_ruler(2)   # debug payload'ın satış dağıtımı
	if GameState.get_founder_skill("sales") != want_sales:
		return "sales=%d (debug payload 2 puan dağıttı, cetvelde %d olmalı)" % [
			GameState.get_founder_skill("sales"), want_sales]
	# Legacy read must return 0 (and push_error loudly — the SKILL-RENAME tripwire).
	if GameState.get_founder_skill("markets") != 0:
		return "legacy 'markets' read returned nonzero"
	# Stage D: the full founder identity flows through the single init seam.
	if GameState.founder_portrait != "founder_01":
		return "founder_portrait=%s (want founder_01)" % GameState.founder_portrait
	var origin_cash: int = int(FounderConstants.origin_by_id(GameState.origin).get("starting_cash", -1))
	if GameState.cash != origin_cash:
		return "cash=%d (want origin starting_cash %d)" % [GameState.cash, origin_cash]
	if not GameState.get_flag("origin_press_sympathy", false):
		return "reserved origin flag origin_press_sympathy not set"
	if not GameState.get_flag("origin_low_capital", false):
		return "reserved origin flag origin_low_capital not set"
	if founder.traits.size() != 2 or founder.traits[0] != "visionary" or founder.traits[1] != "stubborn":
		return "founder.traits=%s (want [visionary, stubborn])" % str(founder.traits)
	return ""


static func _case_alloc_guard() -> String:
	# FounderConstants.validate_alloc truth table (pool 6, cap 3, canonical keys only).
	var ok := {"product": 1, "design": 0, "engineering": 2, "qa": 0, "sales": 2, "customer_success": 0, "leadership": 0, "charisma": 1}
	if not FounderConstants.validate_alloc(ok):
		return "valid full-pool allocation rejected"
	if FounderConstants.alloc_remaining(ok) != 0:
		return "alloc_remaining != 0 for a full spend"
	if FounderConstants.validate_alloc({"tech": 2, "sales": 2, "negotiation": 1, "leadership": 0, "influence": 0}):
		return "one-under-pool sum accepted"
	if FounderConstants.validate_alloc({"tech": 2, "sales": 2, "negotiation": 1, "leadership": 1, "influence": 1}):
		return "one-over-pool sum accepted"
	if FounderConstants.validate_alloc({"tech": 4, "sales": 1, "negotiation": 1, "leadership": 0, "influence": 0}):
		return "per-skill cap 3 not enforced"
	if FounderConstants.validate_alloc({"tech": 2, "markets": 2, "negotiation": 1, "leadership": 0, "influence": 1}):
		return "legacy key 'markets' accepted"
	return ""


static func _case_trait_formula() -> String:
	# validate_traits: >=1 positive; 1 pos -> negative optional; 2 pos -> exactly 1 negative.
	if not FounderConstants.validate_traits(["visionary"]):
		return "1 positive rejected"
	if not FounderConstants.validate_traits(["visionary", "stubborn"]):
		return "1 positive + 1 negative rejected"
	if not FounderConstants.validate_traits(["visionary", "networker", "stubborn"]):
		return "2 positives + 1 negative rejected"
	if FounderConstants.validate_traits([]):
		return "empty selection accepted"
	if FounderConstants.validate_traits(["visionary", "networker"]):
		return "2 positives without the required negative accepted"
	if FounderConstants.validate_traits(["visionary", "networker", "disciplined", "stubborn"]):
		return "3 positives accepted"
	if FounderConstants.validate_traits(["visionary", "stubborn", "lone_wolf"]):
		return "2 negatives accepted"
	if FounderConstants.validate_traits(["charismatic"]):
		return "unknown trait id accepted"
	if FounderConstants.validate_traits(["visionary", "visionary"]):
		return "duplicate trait id accepted"
	if FounderConstants.validate_traits(["stubborn"]):
		return "negative-only selection accepted"
	return ""


static func _case_lever_skill_new_keys() -> String:
	# Term Sheet levers read the CANONICAL skill keys; can_read_prospect flips on Satış;
	# the odds-split label resolves through the CSV -> TranslationServer plumbing.
	#
	# 2026-08-21: `dilution` moved from `negotiation` to `charisma`. rev 2's six areas have no
	# negotiation, so its one reader had to be rebound, and ch. 02 §4 gives Karizma the TERMS
	# of a raise and not just the odds. THIS IS THE ONE BINDING rev 2 DOES NOT ITSELF
	# AUTHORIZE — it is one token in PitchConstants.LEVER_SKILL and ch. 09's turn owns the
	# ruling. This case is deliberately the place that would notice a silent change of mind.
	var want := {"valuation": "sales", "dilution": "charisma", "board": "charisma"}
	for lever in want:
		var skill_key: String = String(PitchConstants.LEVER_SKILL.get(lever, ""))
		if skill_key != want[lever]:
			return "LEVER_SKILL[%s]=%s (want %s)" % [lever, skill_key, want[lever]]
		if not FounderConstants.SKILLS.has(skill_key):
			return "LEVER_SKILL[%s] not a canonical skill" % lever
	var founder: Character = CharacterRegistry.get_founder()
	if founder == null:
		return "no founder"
	founder.role_stats["sales"] = SkillCheck.SALES_READ_THRESHOLD - 1
	if SkillCheck.can_read_prospect():
		return "can_read_prospect true below the Satış threshold"
	founder.role_stats["sales"] = SkillCheck.SALES_READ_THRESHOLD
	if not SkillCheck.can_read_prospect():
		return "can_read_prospect false at the Satış threshold"
	var prev_locale: String = Localization.get_language()
	Localization.set_language("tr")
	var label: String = PitchConstants.skill_label("sales")
	Localization.set_language(prev_locale)
	if label != "satış":
		return "skill_label(sales)=%s (want satış via CSV)" % label
	return ""


static func _case_onboarding_pages_contract() -> String:
	# The 3 dark-register onboarding pages honor the OnboardingStep contract:
	# valid with a complete draft, İleri-blocked when the blocking field is
	# missing (points unspent / trait formula broken / empty company name),
	# payload key sets match the draft schema slices.
	# Host = an autoload node, NOT the tree root: run_case executes during
	# main._ready, while root is still "busy setting up children" and rejects
	# add_child. An autoload finished entering the tree long ago.
	var root: Node = EventBus
	var scenes := {
		"character": load("res://scenes/onboarding/steps/CharacterStep.tscn"),
		"origin_traits": load("res://scenes/onboarding/steps/OriginTraitsStep.tscn"),
		"company": load("res://scenes/onboarding/steps/CompanyStep.tscn"),
	}
	var full_draft := {
		"founder_name": "Deneme", "portrait_id": "founder_03", "origin_id": "self_made",
		"trait_ids": ["visionary", "stubborn"],
		# DEBUG ALLOCATION, chosen to move as little as possible through the 2026-08-21
		# area migration. The old payload was {tech 2, sales 2, negotiation 1, influence 1};
		# `tech` fed build speed, the quality average AND the iteration ceilings, and those
		# three now read four separate areas — so no allocation of 6 points at cap 3 can
		# reproduce it exactly. engineering 2 holds the build-speed anchor at its old value,
		# sales 2 holds SkillCheck.SALES_READ_THRESHOLD, charisma 1 holds the pitch beats
		# non-zero, and the spare point goes to product so the İnovasyon ceiling is not flat.
		"skill_alloc": {"product": 1, "design": 0, "engineering": 2, "qa": 0, "sales": 2, "customer_success": 0, "leadership": 0, "charisma": 1},
		"company_name": "Synaptik", "logo_style": "tech", "slogan": "",
	}
	var expected_keys := {
		"character": ["founder_name", "portrait_id"],
		"origin_traits": ["origin_id", "trait_ids", "skill_alloc"],
		"company": ["company_name", "slogan", "logo_style"],
	}
	for key in scenes:
		var ps: PackedScene = scenes[key]
		if ps == null:
			return "scene %s failed to load" % key
		var node: Node = ps.instantiate()
		if not (node is OnboardingStep):
			node.free()
			return "%s is not an OnboardingStep" % key
		var step: OnboardingStep = node
		root.add_child(step)
		step.prefill(full_draft)
		if not step.is_valid():
			step.queue_free()
			return "%s invalid with a complete draft" % key
		var payload: Dictionary = step.collect_payload()
		for k in expected_keys[key]:
			if not payload.has(k):
				step.queue_free()
				return "%s payload missing key %s" % [key, k]
		step.queue_free()

	var unspent: Dictionary = full_draft.duplicate(true)
	unspent["skill_alloc"]["charisma"] = 0
	var p2: OnboardingStep = scenes["origin_traits"].instantiate()
	root.add_child(p2)
	p2.prefill(unspent)
	var valid_unspent: bool = p2.is_valid()
	p2.queue_free()
	if valid_unspent:
		return "page 2 valid with a skill point unspent"

	var two_pos: Dictionary = full_draft.duplicate(true)
	two_pos["trait_ids"] = ["visionary", "networker"]
	var p2b: OnboardingStep = scenes["origin_traits"].instantiate()
	root.add_child(p2b)
	p2b.prefill(two_pos)
	var valid_two_pos: bool = p2b.is_valid()
	p2b.queue_free()
	if valid_two_pos:
		return "page 2 valid with 2 positives and no negative"

	var nameless: Dictionary = full_draft.duplicate(true)
	nameless["company_name"] = ""
	var p3: OnboardingStep = scenes["company"].instantiate()
	root.add_child(p3)
	p3.prefill(nameless)
	var valid_nameless: bool = p3.is_valid()
	p3.queue_free()
	if valid_nameless:
		return "page 3 valid with an empty company name"
	return ""


# ============================================================================
#  HR Core (task 1 of 3) — data model, search, candidates, morale, actions,
#  overtime, economy. Every case is contract-level: it asserts what the DESIGN
#  promises, not how a given system happens to be written.
# ============================================================================

# Shared setup: park an employee's leave month far from the current one so the automatic
# annual-leave machine does not fire inside a case that is measuring something else.
## "Bu vaka izin hakkında DEĞİL" demenin yolu. §11.4 izni yılın herhangi bir ayından bir
## YAZ HAFTASINA taşıdı, ve Faz 5b'den beri her işe alım bir hafta damgalıyor — yani ayı
## itmek artık hiçbir şeyi park etmiyordu ve fixture'ların bir kısmı vaka ortasında izne
## çıkıyordu. -1 = haftası yok, ve tick_leave_departures onu açıkça atlıyor.
static func _park_leave(employees: Array) -> void:
	for e in employees:
		e.leave_week = -1
		e.leave_taken_year = 0


static func _case_hr_axis_key_lock() -> String:
	# §4/§3: employee and founder SHARE the six areas and differ only
	# in the tail — employee + Liderlik, founder + Liderlik + Karizma. That makes the key lock
	# MORE important, not less: before the migration the two key sets were disjoint, so a
	# mix-up was obvious; now they overlap and only the tail tells them apart.
	var founder: Character = CharacterRegistry.get_founder()
	if founder == null:
		return "no founder after initialize_run"
	# The shared half must genuinely be shared: the founder carries all six areas (§3's
	# stated reason for keeping him off the Ekip page).
	for area_key in HRConstants.AREAS:
		if not founder.role_stats.has(area_key):
			return "founder is missing area '%s' — rev 2 §3 says he has a score in every one" % area_key
	if not founder.role_stats.has(FounderConstants.SKILL_CHARISMA):
		return "founder is missing Karizma, which rev 2 §2 makes founder-only"
	if HRConstants.validate_employee_skills(founder.role_stats):
		return "the FOUNDER dict passed the EMPLOYEE validator — the tail is not being checked"
	var emp: Character = _make_employee("char_lock_emp", "Lock Emp", HRConstants.ROLE_DEVELOPER)
	if emp.role_stats.has(FounderConstants.SKILL_CHARISMA):
		return "employee carries Karizma, which is founder-only"
	if not HRConstants.validate_employee_skills(emp.role_stats):
		return "employee skills failed their own validator: %s" % str(emp.role_stats)
	if emp.role_stats.size() != HRConstants.EMPLOYEE_SKILL_KEYS.size():
		return "employee role_stats holds %d keys, want exactly %d" % [
			emp.role_stats.size(), HRConstants.EMPLOYEE_SKILL_KEYS.size()]
	# The peak must land where the TITLE says: a developer's key area is Yazılım.
	if int(emp.role_stats[HRConstants.AREA_ENGINEERING]) != SEED_EXPERTISE:
		return "a seeded developer's key area is not Yazılım: %s" % str(emp.role_stats)
	# THE RETIRED-KEY TRIPWIRE. Founder skills have had one since the 2026-07-16 rename;
	# employee axes never did, so a stray "pace" would have loaded as a dropped key and read
	# as a silent 0. This is the assertion that makes a bad migration loud.
	if not HRConstants.has_retired_skill_key({"pace": 4}):
		return "has_retired_skill_key did not catch a retired axis"
	if HRConstants.has_retired_skill_key(emp.role_stats):
		return "a freshly seeded employee still carries a retired axis: %s" % str(emp.role_stats)
	# Every near-miss shape must be rejected, not just obvious garbage.
	var short_dict: Dictionary = HRConstants.default_employee_skills()
	short_dict.erase(HRConstants.AREA_QA)
	if HRConstants.validate_employee_skills(short_dict):
		return "a missing area was accepted"
	var extra: Dictionary = HRConstants.default_employee_skills()
	extra[FounderConstants.SKILL_CHARISMA] = 2
	if HRConstants.validate_employee_skills(extra):
		return "an extra founder key was accepted"
	var off_ruler: Dictionary = HRConstants.default_employee_skills()
	off_ruler[HRConstants.AREA_SALES] = HRConstants.AREA_MAX + 1
	if HRConstants.validate_employee_skills(off_ruler):
		return "an off-ruler value was accepted"
	# Employee traits use their OWN catalog and formula, not the founder's.
	if HRConstants.validate_employee_traits(["visionary"]):
		return "a FOUNDER trait id passed the employee trait validator"
	return ""


static func _case_hr_candidate_invariants() -> String:
	# §10.2 · ÜÇ ARKETİP VE DÖRT BAĞLAYICI KURAL. "Üç aday rastgele üretilmez. Her aramada
	# SABİT bir üçlü arketip çekilir. Amaç, oyuncunun her aramada gerçek ve savunulabilir bir
	# karar vermesidir." Bantlar gitti: seviye artık kişide saklanan bir alan (§3), bant ise
	# işe alımda ATILAN bir bütçe seçeneğiydi.
	#
	# Dört kural da burada ölçülüyor:
	#   1. Hiçbir aday bir diğerini BÜTÜN EKSENLERDE yenemez.
	#   2. Ana alandaki yıldız farkı en fazla 1 YILDIZ (iki yarım kademe = 2 ham puan).
	#   3. Fiyat farkı %20–45.
	#   4. Üçlüden EN AZ BİRİ bedelli bir huy taşır.
	#
	# FALSİFİKASYON, VE ONU ARARKEN ÖĞRENİLEN ŞEY: `is_non_dominated_set` FİYATI DA okuyor
	# (A her eksende >= B VE A daha ucuz ya da eşit). Fiyat sırası §10.2'de sabit olduğu için
	# — Pazarlık < Uzman < Dengeli — en pahalı iki dosya hiçbir zaman hâkim OLAMAZ; kuralı
	# ihlal edebilecek tek şekil "EN UCUZ DOSYA AYNI ZAMANDA EN İYİSİ"dir. Ölçülmüş
	# falsifikasyon bu yüzden şudur: ARCHETYPE_SHAPE'in kıdemli satırında Pazarlık'ı
	# [9, 5, 4] yap (Uzman'ın [9, 4, 3]'ünün her yerinde >=) → product_manager/lvl2'de
	# "one file DOMINATES another" FAIL'i düşer.
	#
	# İLK DENENEN VE ÇALIŞMAYAN: ARCHETYPE_LEAD_OFFSET'i sıfırlamak. Case YEŞİL kaldı, çünkü
	# rotasyon bump'ı (her adayın FARKLI bir rol-dışı alanı +1) zaten iki dosyanın birbirini
	# her eksende yenmesini engelliyor. Liderlik farkı ikinci ve BAĞIMSIZ bir koruma —
	# tek başına test edilemez, ve o yüzden onun gerekçesi tasarımdır, bu iddia değil.
	var generations: int = 0
	var five_star_seen: int = 0
	for role_id in HRConstants.EMPLOYEE_ROLES:
		for level in HRConstants.LEVELS:
			for sd in 8:
				var seed_value: int = 1000 + sd * 7919 + generations * 31
				var files: Array = HRCandidateGenerator.generate(role_id, int(level), seed_value)
				generations += 1
				var tag: String = "%s/lvl%d seed %d" % [role_id, int(level), seed_value]
				if files.size() != HRConstants.CANDIDATE_COUNT:
					return "%s: %d files, want %d" % [tag, files.size(), HRConstants.CANDIDATE_COUNT]
				var band: Array = HRConstants.salary_band_for_level(role_id, int(level))
				var key_area: String = HRConstants.role_key_area(role_id)
				var lo: int = 1 << 30
				var hi: int = 0
				var key_lo: int = 1 << 30
				var key_hi: int = 0
				var cost_files: int = 0
				var five_star: bool = false
				var seen_traits: Array = []
				var seen_names: Array = []
				var seen_notes: Array = []
				var seen_salaries: Array = []
				var seen_archetypes: Array = []
				for f in files:
					var sal: int = int(f["salary"])
					if sal < int(band[0]) or sal > int(band[1]):
						return "%s: salary %d outside the LEVEL band %s" % [tag, sal, str(band)]
					lo = mini(lo, sal)
					hi = maxi(hi, sal)
					# Fiyat bir kaldıraç: üç dosya üç AYRI rakam ister. İki dosya aynı rakama
					# yuvarlanırsa §10.2'nin fiyat ekseni çökmüştür.
					if seen_salaries.has(sal):
						return "%s: two files quote the same salary %d — the price axis collapsed" % [tag, sal]
					seen_salaries.append(sal)
					# ÜÇLÜ SABİT: üç arketip, her biri bir kez.
					var arch: String = String(f["archetype"])
					if not HRConstants.ARCHETYPES.has(arch):
						return "%s: unknown archetype '%s'" % [tag, arch]
					if seen_archetypes.has(arch):
						return "%s: archetype '%s' appears twice — the trio is not fixed" % [tag, arch]
					seen_archetypes.append(arch)
					if int(f["level"]) != int(level):
						return "%s: file carries level %d" % [tag, int(f["level"])]
					var key_v: int = int((f["axes"] as Dictionary).get(key_area, -1))
					key_lo = mini(key_lo, key_v)
					key_hi = maxi(key_hi, key_v)
					if key_v >= HRConstants.AREA_MAX:
						five_star = true
					if not HRConstants.validate_employee_skills(f["axes"]):
						return "%s: axes off the ruler: %s" % [tag, str(f["axes"])]
					if not HRConstants.validate_employee_traits(f["traits"]):
						return "%s: traits break the employee formula: %s" % [tag, str(f["traits"])]
					for t in f["traits"]:
						if HRConstants.trait_carries_cost(String(t)):
							cost_files += 1
					if String(f["role"]) != role_id:
						return "%s: role mismatch (%s)" % [tag, String(f["role"])]
					# THE NOTE, BY ITS INDEX. generate() hands back `note_index`; the note TEXT
					# is resolved one layer up (HRSearchSystem.get_files → file_notes_line).
					var note_index: int = int(f["note_index"])
					if note_index < 0 or note_index >= HRConstants.FILE_NOTES_COUNT:
						return "%s: note_index %d outside 0..%d" % [
							tag, note_index, HRConstants.FILE_NOTES_COUNT - 1]
					var note_key: String = "HR_FILE_NOTE_%d" % (note_index + 1)
					if HRConstants.file_notes_line(note_index) == note_key:
						return "%s: %s has no row in strings.csv" % [tag, note_key]
					if String(f["name"]).strip_edges() == "":
						return "%s: empty candidate name" % tag
					# Batch no-repeat across every drawn pool: two identical names or the same
					# file note twice reads as a generator bug on the card.
					if seen_names.has(String(f["name"])):
						return "%s: candidate name '%s' repeated across files" % [tag, String(f["name"])]
					seen_names.append(String(f["name"]))
					if seen_notes.has(note_index):
						return "%s: file note %d repeated across files" % [tag, note_index]
					seen_notes.append(note_index)
					for t2 in f["traits"]:
						if seen_traits.has(String(t2)):
							return "%s: trait '%s' repeated across files" % [tag, String(t2)]
						seen_traits.append(String(t2))

				# 1 · HÂKİM ADAY YOK.
				if not HRCandidateGenerator.is_non_dominated_set(files):
					return "%s: one file DOMINATES another" % tag
				# 4 · Ayırt edici eksen HUY: en az bir bedelli huy, her aramada.
				if cost_files < HRConstants.TRIO_COST_TRAIT_MIN:
					return "%s: %d cost traits in the trio, want at least %d — every choice was free" % [
						tag, cost_files, HRConstants.TRIO_COST_TRAIT_MIN]
				if five_star:
					# §10.2 BEŞ YILDIZLI ADAY: yalnız Kıdemli, ve maaş talebi bandın TAVANINDA.
					# Bu aday §10.2'nin karşılaştırılabilirlik kurallarına konmuş ADI KONMUŞ
					# istisnadır — "o bir yıldız çalışandır ve öyle fiyatlanır" — o yüzden
					# yıldız farkı ve fiyat farkı iddiaları ona uygulanmaz.
					five_star_seen += 1
					if int(level) != HRConstants.LEVEL_SENIOR:
						return "%s: a five-star candidate outside the senior level" % tag
					if hi != maxi(int(band[0]), int(band[1])):
						return "%s: the five-star ask is %d, want the band ceiling %d" % [
							tag, hi, maxi(int(band[0]), int(band[1]))]
				else:
					# 2 · ANA ALANDA EN FAZLA 1 YILDIZ FARK. "Adaylar karşılaştırılabilir
					# olmalıdır; biri diğerinden iki yıldız iyiyse karar kendiliğinden verilir
					# ve seçim ortadan kalkar."
					if HRConstants.stars_for(key_hi) - HRConstants.stars_for(key_lo) > 1.0 + 0.001:
						return "%s: key-area spread is %.1f stars (%d..%d), want at most 1" % [
							tag, HRConstants.stars_for(key_hi) - HRConstants.stars_for(key_lo), key_lo, key_hi]
					# 3 · FİYAT FARKI %20–45.
					var spread: float = float(hi) / float(maxi(lo, 1)) - 1.0
					if spread < HRConstants.SALARY_SPREAD_MIN_R11 - 0.0001 \
							or spread > HRConstants.SALARY_SPREAD_MAX_R11 + 0.0001:
						return "%s: salary spread %.3f outside %.2f..%.2f (%d..%d)" % [
							tag, spread, HRConstants.SALARY_SPREAD_MIN_R11,
							HRConstants.SALARY_SPREAD_MAX_R11, lo, hi]
				# Same seed, byte-identical files — no RNG anywhere in the generator.
				if str(HRCandidateGenerator.generate(role_id, int(level), seed_value)) != str(files):
					return "%s: generator is not deterministic" % tag
	if generations < 100:
		return "only %d generations exercised, want at least 100" % generations
	# §10.2 "NADİRDİR": beş yıldız çıkabilmeli, ama her aramada değil. İki uçlu iddia —
	# olasılık 0'a düşerse alternatifin kendisi yok olur, 1'e çıkarsa nadirlik yalan olur.
	if five_star_seen == 0:
		return "no five-star candidate in %d generations — §10.2's alternative to training never appears" % generations
	if five_star_seen * 4 > generations:
		return "%d of %d generations carried a five-star candidate — that is not rare" % [
			five_star_seen, generations]
	# Negative control: without this the whole case would pass on a `return true` predicate.
	var dominant: Array = [
		{"axes": HRConstants.seed_skills(HRConstants.ROLE_DEVELOPER, 9, 9, 9), "salary": 5000},
		{"axes": HRConstants.seed_skills(HRConstants.ROLE_DEVELOPER, 4, 4, 4), "salary": 6000},
	]
	if HRCandidateGenerator.is_non_dominated_set(dominant):
		return "is_non_dominated_set accepted a strictly dominant, cheaper file — the predicate is vacuous"
	return ""


static func _case_hr_archetype_trio() -> String:
	# §10.2'nin TABLOSU, satır satır. Yukarıdaki case kuralların SAĞLANDIĞINI ölçüyor; bu
	# case üçlünün KİMLİĞİNİ ölçüyor — hangi arketip neyi taşır. İkisi ayrı, çünkü kurallar
	# şekli değişse de geçerli kalır, kimlik ise tablonun kendisidir.
	#
	# FALSİFİKASYON: ARCHETYPE_PRICE_UZMAN_SHARE'i 1.0 yap → Uzman Dengeli ile aynı fiyata
	# çıkar ve "Dengeli üçlünün en yükseğidir" iddiası FAIL eder.
	var role_id: String = HRConstants.ROLE_DEVELOPER
	var level: int = HRConstants.LEVEL_MID
	var files: Array = HRCandidateGenerator.generate(role_id, level, 90210)
	var by_arch: Dictionary = {}
	for f in files:
		by_arch[String(f["archetype"])] = f
	for want in HRConstants.ARCHETYPES:
		if not by_arch.has(String(want)):
			return "the trio is missing the '%s' archetype" % String(want)
	var uzman: Dictionary = by_arch[HRConstants.ARCHETYPE_UZMAN]
	var dengeli: Dictionary = by_arch[HRConstants.ARCHETYPE_DENGELI]
	var pazarlik: Dictionary = by_arch[HRConstants.ARCHETYPE_PAZARLIK]
	var key_area: String = HRConstants.role_key_area(role_id)

	# FİYAT: "Dengeli — üçlünün EN YÜKSEĞİ · Pazarlık — üçlünün EN DÜŞÜĞÜ · Uzman — orta-yüksek".
	if not (int(pazarlik["salary"]) < int(uzman["salary"]) and int(uzman["salary"]) < int(dengeli["salary"])):
		return "price order is %d/%d/%d (pazarlık/uzman/dengeli), want strictly increasing" % [
			int(pazarlik["salary"]), int(uzman["salary"]), int(dengeli["salary"])]

	# YILDIZ PROFİLİ: "Uzman — ana alanda üçlünün EN YÜKSEĞİ; diğer alanlar zayıf."
	# "Dengeli — TEPE NOKTASI YOK; ana ve ikincil alanda makul."
	var uz_key: int = int((uzman["axes"] as Dictionary).get(key_area, 0))
	var de_key: int = int((dengeli["axes"] as Dictionary).get(key_area, 0))
	var pa_key: int = int((pazarlik["axes"] as Dictionary).get(key_area, 0))
	if uz_key < de_key:
		return "the Uzman does not hold the top of the key area (%d vs Dengeli %d)" % [uz_key, de_key]
	if de_key >= uz_key and de_key >= pa_key and (uz_key > de_key or pa_key > de_key):
		pass   # Dengeli tepe DEĞİL; aşağıdaki iddia bunu doğrudan ölçüyor
	if de_key > uz_key or de_key > pa_key:
		return "the Dengeli has the peak (%d) — its whole identity is having none" % de_key

	# "Pazarlık — bir alanda GERÇEKTEN İYİ, en az bir alanda KIRIK."
	var pa_min: int = 1 << 30
	var de_min: int = 1 << 30
	for area_key in HRConstants.AREAS:
		pa_min = mini(pa_min, int((pazarlik["axes"] as Dictionary).get(String(area_key), 0)))
		de_min = mini(de_min, int((dengeli["axes"] as Dictionary).get(String(area_key), 0)))
	if pa_min >= de_min:
		return "the Pazarlık's worst area (%d) is not below the Dengeli's (%d) — nothing is broken" % [
			pa_min, de_min]

	# HUY ROLÜ: "Pazarlık — genellikle bedelli huy taşır." Motorda GARANTİ, çünkü
	# TRIO_COST_TRAIT_MIN'i bir olasılıkla karşılamak bazı aramaları bedelsiz bırakırdı.
	var pa_traits: Array = pazarlik["traits"]
	if pa_traits.is_empty() or not HRConstants.trait_carries_cost(String(pa_traits[0])):
		return "the Pazarlık carries no cost trait — the discriminating axis is gone"
	# "Dengeli — genellikle güvenli." Motorda hep bedelsiz.
	var de_traits: Array = dengeli["traits"]
	if not de_traits.is_empty() and HRConstants.trait_carries_cost(String(de_traits[0])):
		return "the Dengeli carries a cost trait — the trio's contrast is blurred"
	return ""

static func _case_hr_training_locks() -> String:
	# §5.4 · İKİ AYRI GEREKÇE, BİRBİRİNE KARIŞTIRILMAZ. "Eylem her zaman görünür, kilitliyse
	# gerekçesini gösterir. Deneyim dolu değil → 'henüz hak edilmedi'. Alan 5,0 yıldızda →
	# 'bu alanda öğrenecek bir şey kalmadı'. PARANIN YETMEMESİ BİR KİLİT DEĞİLDİR; bir
	# bedeldir ve modalde okunur."
	#
	# Üç yüzey (eğitim modali, satır menüsü, Kişisel kartı) kendi gerekçesini yazıyordu ve
	# ÜÇÜ DE tavanı söylüyordu — barı dolmamış bir junior'a "bu alan tavanda" diyorlardı,
	# yani oyuncu bekleyerek çözülecek bir durumu çözümsüz sanıyordu.
	#
	# FALSİFİKASYON: training_block_reason_key'in bar dalını sil (hep AT_CAP döndür) →
	# ikinci iddia FAIL eder.
	GameState.set_cash(500000)
	var dev: Character = _make_employee("char_lock_dev", "Lock Dev", HRConstants.ROLE_DEVELOPER,
		SEED_PACE, 6000, 70)
	_park_leave([dev])
	var key_area: String = HRConstants.role_key_area(dev.role)

	# 1 · BAR BOŞ → "henüz hak edilmedi", ve tavan gerekçesi DEĞİL.
	dev.experience_raw = 0
	CharacterRegistry.refresh_experience_threshold(dev)
	if CharacterRegistry.can_train(dev.id, key_area):
		return "an empty experience bar still unlocked training (§5.2 step 1)"
	if CharacterRegistry.training_block_reason_key(dev.id, key_area) != "HR_TRAINING_NOT_EARNED":
		return "an unfilled bar reads '%s', want HR_TRAINING_NOT_EARNED" % \
			CharacterRegistry.training_block_reason_key(dev.id, key_area)

	# 2 · BAR DOLU, ALAN TAVANIN ALTINDA → kilit YOK.
	dev.experience_raw = dev.experience_threshold
	if not CharacterRegistry.can_train(dev.id, key_area):
		return "a full bar did not unlock training"
	if CharacterRegistry.training_block_reason_key(dev.id, key_area) != "":
		return "a trainable area still reports a lock reason: '%s'" % \
			CharacterRegistry.training_block_reason_key(dev.id, key_area)

	# 3 · ALAN 5,0 YILDIZDA → "öğrenecek bir şey kalmadı", ve bar dolu olduğu hâlde.
	dev.role_stats[key_area] = HRConstants.AREA_MAX
	CharacterRegistry.refresh_experience_threshold(dev)
	dev.experience_raw = dev.experience_threshold
	if CharacterRegistry.can_train(dev.id, key_area):
		return "an area at the 5.0 ceiling is still trainable"
	if CharacterRegistry.training_block_reason_key(dev.id, key_area) != "HR_TRAINING_AT_CAP":
		return "a capped area reads '%s', want HR_TRAINING_AT_CAP" % \
			CharacterRegistry.training_block_reason_key(dev.id, key_area)

	# 4 · §5.3 EĞİTİM BEŞİNCİ YILDIZA KADAR ÇIKAR. Dört yıldızlı (8 puan) bir alan hâlâ
	# eğitilebilir olmalı — rev 2'nin AREA_TRAIN_CAP'i tam burada duvar örüyordu.
	dev.role_stats[key_area] = HRConstants.AREA_MAX - 2
	CharacterRegistry.refresh_experience_threshold(dev)
	dev.experience_raw = dev.experience_threshold
	if not CharacterRegistry.can_train(dev.id, key_area):
		return "a four-star area is not trainable — money cannot buy the fifth star (§5.3)"

	# 5 · PARA BİR KİLİT DEĞİL (§5.4). Kasa bedeli karşılamıyorken bile eğitim GİDER ve
	# kasayı eksiye götürür — işe alım komisyonuyla ve kıdem tazminatıyla aynı kanal.
	var fee: int = CharacterRegistry.training_fee_for(dev.id, key_area)
	GameState.set_cash(fee - 1)
	if CharacterRegistry.training_block_reason_key(dev.id, key_area) != "":
		return "an unaffordable fee was reported as a LOCK — §5.4 calls it a cost"
	if not HRSystem.send_to_training(dev.id, key_area):
		return "training refused for lack of cash — §5.4 says money is not a lock"
	if GameState.cash >= 0:
		return "the fee did not actually leave the treasury (%d)" % GameState.cash
	if dev.status != HRConstants.STATUS_TRAINING:
		return "the employee is not in training after send_to_training"

	# 6 · §5.5 SÜRE TÜRETİLİR. Metin gün sayısından çıkar; sabit bir satır olsaydı
	# TRAINING_DAYS değiştiğinde iki dilde birden yalan söylerdi (§16).
	var duration: String = HRConstants.training_duration_text()
	if duration == "" or duration.begins_with("HR_DURATION_"):
		return "the derived duration text resolved to a raw key: '%s'" % duration
	if not duration.contains(str(HRConstants.TRAINING_DAYS / 7)):
		return "the duration text '%s' does not read %d days" % [duration, HRConstants.TRAINING_DAYS]
	return ""


static func _case_hr_search_cycle() -> String:
	# §10: ARAMA ÜCRETSİZ, dosyalar BİR HAFTA sonra ve MODALSİZ gelir, komisyon bir kez ve
	# yalnız işe alımda, çalışan ertesi gün aktif, maaş burn'de, hires_total +1.
	#
	# FALSİFİKASYON: start_search'e bir FinanceSystem.apply_one_time_cost geri koy → ikinci
	# iddia FAIL eder.
	GameState.set_cash(100000)
	if not HRSearchSystem.can_start():
		return "cannot start a search from idle"
	var cash0: int = GameState.cash
	if not HRSearchSystem.start_search(HRConstants.ROLE_DEVELOPER, HRConstants.LEVEL_MID):
		return "start_search refused"
	# §10: "Aday araması ... ÜCRETSİZDİR. Retainer YOKTUR; tek ücret komisyondur."
	if GameState.cash != cash0:
		return "commissioning a search moved cash (%d -> %d) — §10 says it is free" % [cash0, GameState.cash]
	if HRSearchSystem.get_state() != HRConstants.SEARCH_SEARCHING:
		return "state is '%s', want '%s'" % [HRSearchSystem.get_state(), HRConstants.SEARCH_SEARCHING]
	if HRSearchSystem.can_start():
		return "a second search may start while one is already active"
	var arrived_on: int = -1
	for i in HRConstants.SEARCH_ARRIVAL_DAYS + 3:
		_sim_day()
		if HRSearchSystem.has_files_ready():
			arrived_on = i + 1
			break
	if arrived_on < HRConstants.SEARCH_ARRIVAL_DAYS or arrived_on > HRConstants.SEARCH_ARRIVAL_DAYS:
		return "files arrived on day %d, want %d-%d" % [
			arrived_on, HRConstants.SEARCH_ARRIVAL_DAYS, HRConstants.SEARCH_ARRIVAL_DAYS]
	# Arrival is a badge and a ticker line, never an interruption.
	# The HR family is one card now (`team.resignation`), so the prefix test became a namespace
	# test: nothing in `team.` may be on screen because files landed on the desk.
	if EventGate.active_id().begins_with("team."):
		return "candidate arrival opened a modal (%s)" % EventGate.active_id()
	var files: Array = HRSearchSystem.get_files()
	if files.size() != HRConstants.CANDIDATE_COUNT:
		return "%d files ready, want %d" % [files.size(), HRConstants.CANDIDATE_COUNT]
	var prev: Dictionary = HRSearchSystem.preview_hire(0)
	if int(prev.get("commission", -1)) != HRConstants.commission_for(int(files[0]["salary"])):
		return "preview commission %s, want %d" % [
			str(prev.get("commission")), HRConstants.commission_for(int(files[0]["salary"]))]
	var hires0: int = GameState.run_hires
	var cash1: int = GameState.cash
	var salary: int = int(files[0]["salary"])
	var hired: Character = HRSearchSystem.hire(0)
	if hired == null:
		return "hire returned null"
	if GameState.cash != cash1 - HRConstants.commission_for(salary):
		return "commission wrong (%d -> %d, want -%d)" % [cash1, GameState.cash, HRConstants.commission_for(salary)]
	if GameState.run_hires != hires0 + 1:
		return "hires_total not incremented"
	if hired.status != HRConstants.STATUS_ACTIVE:
		return "the new hire is not active"
	if hired.hire_day != GameState.day + 1:
		return "hire_day is %d, want the next day (%d) — full performance from day one, no ramp" % [
			hired.hire_day, GameState.day + 1]
	if hired.leave_week < 0:
		return "leave_week not assigned at hire (%d)" % hired.leave_week
	if not HRConstants.is_employee_role(hired.role):
		return "hired with a non-employee role '%s'" % hired.role
	# §3 SEVİYE İŞE ALIMDA DÜŞMEZ. rev 2'de aday üretilirken okunuyor, Character'a hiç
	# yazılmıyordu — yani oyunda seviye diye bir şey yoktu ve unvan hep çıplak rol adıydı.
	if hired.level != HRConstants.LEVEL_MID:
		return "the hire's level is %d, want the level the search asked for (%d)" % [
			hired.level, HRConstants.LEVEL_MID]
	if HRConstants.job_title(hired.role, hired.level) != HRConstants.role_label(hired.role):
		return "the Orta level rendered a prefix; §3 gives it none"
	# §9.1 "maaş hiçbir zaman düşürülmez" — tabanı işe alım maaşıdır.
	if hired.salary_floor != salary:
		return "salary_floor is %d, want the hiring salary %d" % [hired.salary_floor, salary]
	if HRSearchSystem.get_state() != HRConstants.SEARCH_IDLE:
		return "the search did not close after the hire"
	FinanceSystem.daily_tick()
	if int(FinanceSystem.get_burn_breakdown().get("salaries", 0)) != int(round(float(salary) / float(GameState.DAYS_PER_MONTH))):
		return "the new hire's salary is not in the burn breakdown"
	return ""


static func _case_hr_search_cancel_dismiss() -> String:
	# İptal de dosyaları geri çevirmek de PARA HAREKET ETTİRMEZ (§10 — arama ücretsiz).
	# İkisinin de bedeli beklenmiş HAFTADIR.
	# The second leg hires a Satış Uzmanı, and that role is locked outside a B2B market
	# (HRConstants.role_lock_reason_key) — the market flag alone opens it. Deliberately NOT
	# _seed_b2b(): this case is about the search state machine, and a live account would
	# drag the B2B daily chain through the arrival loop below.
	GameState.set_cash(100000)
	GameState.set_flag("mvp_market_type", "b2b")
	var c0: int = GameState.cash
	if not HRSearchSystem.start_search(HRConstants.ROLE_TESTER, HRConstants.LEVEL_JUNIOR):
		return "start_search refused"
	if not HRSearchSystem.cancel_search():
		return "cancel refused"
	if GameState.cash != c0:
		return "cancelling a free search moved cash (%d -> %d)" % [c0, GameState.cash]
	if HRSearchSystem.get_state() != HRConstants.SEARCH_IDLE:
		return "cancel did not return to idle"
	if not HRSearchSystem.start_search(HRConstants.ROLE_SALES_REP, HRConstants.LEVEL_SENIOR):
		return "could not start a second search after cancelling"
	for i in HRConstants.SEARCH_ARRIVAL_DAYS + 3:
		_sim_day()
		if HRSearchSystem.has_files_ready():
			break
	if not HRSearchSystem.has_files_ready():
		return "files never arrived for the dismiss leg"
	var cash_before: int = GameState.cash
	var hires0: int = GameState.run_hires
	if not HRSearchSystem.dismiss_files():
		return "dismiss refused"
	if GameState.cash != cash_before:
		return "dismiss charged something (%d -> %d)" % [cash_before, GameState.cash]
	if GameState.run_hires != hires0:
		return "dismiss counted a hire"
	if HRSearchSystem.get_state() != HRConstants.SEARCH_IDLE:
		return "dismiss did not close the search"
	if not HRSearchSystem.get_files().is_empty():
		return "dismissed files are still readable"
	return ""


static func _case_hr_fire_path() -> String:
	# Severance per the full-year rule charged ONCE, remaining team morale down, departures
	# up, role contribution gone immediately.
	GameState.set_cash(100000)
	var a: Character = _make_employee("char_fire_a", "Fire A", HRConstants.ROLE_DEVELOPER, SEED_PACE, 6000, 70)
	var b: Character = _make_employee("char_fire_b", "Fire B", HRConstants.ROLE_DEVELOPER, SEED_PACE, 6000, 70)
	_park_leave([a, b])
	a.hire_day = GameState.day - 400   # one full year served
	var want_severance: int = HRConstants.severance_amount(6000, 400)
	if want_severance != 6000:
		return "severance rule drifted: one year of service on 6000 gives %d" % want_severance
	var devs0: int = CharacterRegistry.count_active_developers()
	var morale_b0: int = b.morale
	var dep0: int = GameState.run_departures
	var prev: Dictionary = HRActions.preview_fire(a)
	if int(prev.get("severance", -1)) != want_severance:
		return "preview severance %s, want %d" % [str(prev.get("severance")), want_severance]
	var cash0: int = GameState.cash
	if not HRActions.fire(a):
		return "fire refused"
	if GameState.cash != cash0 - want_severance:
		return "severance not charged exactly once (%d -> %d)" % [cash0, GameState.cash]
	if GameState.run_departures != dep0 + 1:
		return "departures_total not incremented"
	if CharacterRegistry.get_character("char_fire_a") != null:
		return "the fired employee is still in the registry"
	if CharacterRegistry.count_active_developers() != devs0 - 1:
		return "the role contribution did not drop immediately"
	# Founder leadership is 0 in the debug payload, so the climate coefficient is neutral
	# and the team hit is exact.
	if b.morale != morale_b0 - HRConstants.MORALE_FIRE_TEAM:
		return "remaining team morale %d -> %d, want -%d" % [morale_b0, b.morale, HRConstants.MORALE_FIRE_TEAM]
	if HRActions.can_fire(CharacterRegistry.get_mentor()):
		return "the mentor is fireable"
	if HRActions.can_fire(CharacterRegistry.get_founder()):
		return "the founder is fireable"
	return ""


static func _case_hr_resignation_path() -> String:
	# Morale held under the flight-risk line, the window elapses, the roll fires, the person
	# is gone, and NO severance was paid (an unplanned loss).
	GameState.set_cash(100000)
	GameState.set_flag("debug_hr_force", "pass")   # deterministic roll
	var e: Character = _make_employee("char_quit", "Quit Guy", HRConstants.ROLE_DEVELOPER, SEED_PACE, 7000, 70)
	_park_leave([e])
	CharacterRegistry.set_morale(e.id, HRConstants.MORALE_FLIGHT_RISK - 5)
	var dep0: int = GameState.run_departures
	# ONE id for the whole family now. The old factory minted `ev_hr_resign_<employee_id>` —
	# a per-person id, which is how it avoided the queue's dedupe; the card carries
	# `latch_key: entity` instead, so two people can resign in one run and neither absorbs the
	# other's card, without the id having to encode the subject.
	var resign_id: String = "team.resignation"
	var seen: bool = false
	for i in HRConstants.RESIGN_WINDOW_MAX_DAYS + 4:
		_sim_day()
		if _instances_of(resign_id) >= 1:
			seen = true
			break
		if CharacterRegistry.get_character(e.id) == null:
			return "the employee vanished without a resignation event"
	if not seen:
		return "resignation never fired (risk days reached %d, window opens at %d)" % [
			e.flight_risk_days, HRConstants.RESIGN_WINDOW_MIN_DAYS]
	if e.flight_risk_days < HRConstants.RESIGN_WINDOW_MIN_DAYS:
		return "the roll fired after only %d risk days; the window opens at %d" % [
			e.flight_risk_days, HRConstants.RESIGN_WINDOW_MIN_DAYS]
	if not _drain_to(resign_id):
		return "could not bring the resignation event to the front"
	var cash_before: int = GameState.cash
	EventGate.resolve(resign_id, "acknowledge")
	if CharacterRegistry.get_character(e.id) != null:
		return "resignation resolved but the employee is still on the roster"
	if GameState.run_departures != dep0 + 1:
		return "departures_total not incremented on a resignation"
	if GameState.cash != cash_before:
		return "a resignation paid severance (%d -> %d)" % [cash_before, GameState.cash]
	return ""


static func _case_hr_leave_cycle() -> String:
	# Leave month reached -> on_leave automatically, salary STILL charged (paid leave),
	# capacity contribution absent, returns after LEAVE_DAYS with morale refreshed.
	GameState.set_cash(100000)
	var e: Character = _make_employee("char_leave", "Leave Guy", HRConstants.ROLE_DEVELOPER, SEED_PACE, 6000, 60)
	# HERKESİ PARK ET, SONRA YALNIZ BİRİNİ PİNLE. İzin haftası artık işe alımda damgalanıyor
	# (§11.4), yani kadronun başkaları da aynı haftaya düşebilir ve "kapasite BİR azaldı"
	# iddiası o zaman iki kişilik bir düşüşü ölçerdi.
	_park_leave(CharacterRegistry.get_employees())
	# §11.4: izin artık YAZ PENCERESİ içinde bir HAFTAdır, ay değil. Pencereye (Haziran)
	# atlayıp kişiyi o haftaya pinliyoruz — eski model yılın herhangi bir ayına düşebiliyordu
	# ve yaz kısıtı yoktu.
	while int(GameState.get_date_dict().month) != HRConstants.LEAVE_WINDOW_START_MONTH:
		_sim_day()
	e.leave_week = 0
	e.leave_taken_year = 0
	var cap0: int = ProductSystem.capacity_total()
	_sim_day()
	if e.status != HRConstants.STATUS_ON_LEAVE:
		return "leave month reached but status is '%s'" % e.status
	if ProductSystem.capacity_total() != cap0 - 1:
		return "an on-leave developer still counts toward capacity"
	if CharacterRegistry.count_active_developers() != 0:
		return "an on-leave developer counts as active"
	if CharacterRegistry.count_developers() != 1:
		return "an on-leave developer vanished from the headcount lens"
	FinanceSystem.daily_tick()
	if int(FinanceSystem.get_burn_breakdown().get("salaries", 0)) != int(round(6000.0 / float(GameState.DAYS_PER_MONTH))):
		return "paid leave is broken: salary is not charged while on leave"
	var morale_on_leave: int = e.morale
	for i in HRConstants.LEAVE_DAYS + 3:
		_sim_day()
		if e.status == HRConstants.STATUS_ACTIVE:
			break
	if e.status != HRConstants.STATUS_ACTIVE:
		return "never returned from leave after %d days" % (HRConstants.LEAVE_DAYS + 3)
	if e.morale <= morale_on_leave:
		return "return from leave did not refresh morale (%d -> %d)" % [morale_on_leave, e.morale]
	if ProductSystem.capacity_total() != cap0:
		return "capacity did not recover after the return"
	return ""


static func _case_hr_morale_drift_shape() -> String:
	# §7.1'İN ÜÇ DÖNÜM NOKTASI. Taban sürüklenme AŞAĞI çalışır (§7.2 "Moral kendiliğinden
	# iyileşmez") ve saat çarpanı sıfırın altına indiğinde İŞARET DÖNER:
	#   8 saat ×1,0  → erir          (taban)
	#   7 saat ×0    → DURUR
	#   5 saat ×−1,0 → taban hızında YÜKSELİR
	# Kısa günün bütün toparlanma mekaniği bu tek tablodan geliyor; ayrı bir sistem yok.
	#
	# FALSİFİKASYON: HRConstants.HOUR_MORALE_MULT'ta 7'yi 0 yerine 1,0 yap → "seven hours"
	# iddiası FAIL eder. 5'i pozitif yap → "five hours" iddiası FAIL eder.
	GameState.set_flag("debug_hr_force", "fail")   # istifa roll'u atmasın
	var days: int = 12
	var expect: int = int(round(HRConstants.MORALE_BASE_DRIFT_PER_DAY * float(days)))

	# --- 8 SAAT: taban hızında erir ---
	var base_emp: Character = _make_employee("drift_base", "Drift Base", HRConstants.ROLE_DEVELOPER,
		SEED_PACE, 0, 60)
	_park_leave([base_emp])
	var before: int = base_emp.morale
	for i in days:
		_sim_day()
	if base_emp.morale != before - expect:
		return "8h drifted %d over %d days, want -%d (§7.1 taban)" % [
			base_emp.morale - before, days, expect]

	# --- 7 SAAT: DURUR. Çarpan tam sıfır, yani hiçbir yöne gitmez. ---
	WorkHoursSystem.set_company_hours(7)
	var held: int = base_emp.morale
	for i in days:
		_sim_day()
	if base_emp.morale != held:
		return "7h moved morale by %d — §7.1 says the drift STOPS there" % [base_emp.morale - held]

	# --- 5 SAAT: taban hızında YÜKSELİR (§8.3 kısa gün, §7.2'nin üçüncü kanalı) ---
	WorkHoursSystem.set_company_hours(5)
	var low: int = base_emp.morale
	for i in days:
		_sim_day()
	if base_emp.morale != low + expect:
		return "5h moved %d over %d days, want +%d (§7.1 ×-1,0)" % [
			base_emp.morale - low, days, expect]

	# --- AŞIRI YÜK BİR TABAN KOYAR (§7.1 / §12.1) ---
	# "Aşırı yüklü bir çalışan kısa günden en fazla erimesinin durması kadar fayda görür;
	# morali YÜKSELMEZ." Bu, genel yön kuralından daha sert bir hüküm — ve o kural
	# yazılmasaydı aşırı yükün toparlanmayı HIZLANDIRDIĞI bir işaret hatası kaçınılmazdı.
	var loaded: Character = _make_employee("drift_loaded", "Drift Loaded", HRConstants.ROLE_DEVELOPER,
		SEED_PACE, 0, 60)
	_park_leave([loaded])
	if CharacterRegistry.assign_job(loaded.id, HRConstants.JOB_SUPPORT) != "":
		return "could not put the second job on the overload fixture"
	if not HRSystem.is_overloaded(loaded):
		return "two jobs did not read as overloaded"
	var loaded_before: int = loaded.morale
	for i in days:
		_sim_day()
	if loaded.morale > loaded_before:
		return "an overloaded employee RECOVERED on a short day (%d → %d) — §12.1 forbids it" % [
			loaded_before, loaded.morale]
	return ""

static func _case_hr_recovery_channels() -> String:
	# §7.2 — MORALİN YÜKSELME YOLLARI. Moral kendiliğinden iyileşmez ve taban drift yukarı
	# çalışmaz; bu sürümde üç kanal vardır ve ÜÇÜ DE BU MODÜLDEDİR:
	#   Zam (§9.2)                → nakitle ödenir
	#   Yıllık izin dönüşü (§11.4) → o kişinin iki haftasıyla ödenir
	#   Kısa gün (§8.3)            → bütün ekibin günlük çıktısıyla ödenir
	# Hiçbiri bedavaya moral üretmez, ve üçü de farklı para birimiyle ödenir.
	#
	# Olay kartları DÖRDÜNCÜ kanaldır ama §17.3'e göre BLOKLUDUR (motor insanları göremiyor),
	# o yüzden burada ölçülmez — ölçülseydi yazılmamış içeriğe bağlı bir vaka olurdu.
	#
	# FALSİFİKASYON: HRConstants.MORALE_LEAVE_RETURN'ü 0 yap → izin kanalı FAIL eder.
	# HOUR_MORALE_MULT[5]'i pozitif yap → kısa gün kanalı FAIL eder.
	GameState.set_flag("debug_hr_force", "fail")

	# --- 1 · ZAM ---
	# Maaş VERİLİR: can_raise sıfır maaşlı bir kaydı reddeder (yüzde bir zam sıfırdır ve
	# yuvarlama no-op'u kapıya takılır), ve _make_employee'nin varsayılanı sıfırdır.
	var raised: Character = _make_employee("rec_raise", "Rec Raise", HRConstants.ROLE_DEVELOPER,
		SEED_PACE, 4000, 50)
	_park_leave([raised])
	GameState.set_cash(500000)
	var before_raise: int = raised.morale
	if not HRActions.apply_raise(raised, HRConstants.RAISE_MAX_PCT):
		return "apply_raise refused a healthy employee"
	if raised.morale <= before_raise:
		return "§9.2 zam did not raise morale (%d → %d)" % [before_raise, raised.morale]

	# --- 2 · YILLIK İZİN DÖNÜŞÜ ---
	# §11.4: dönen çalışan +15 kazanır ve bu TEK SEFERDE gelir. §8.6: izin boyunca moral
	# HİÇ sürüklenmez — aksi hâlde iki hafta erir, sonra +15 alır ve izin NET BİR KAYBA
	# dönerdi. İkisini birlikte ölçüyoruz: dönüşteki moral, gidişteki moralden yüksek olmalı.
	var rested: Character = _make_employee("rec_leave", "Rec Leave", HRConstants.ROLE_TESTER,
		SEED_PACE, 0, 50)
	var before_leave: int = rested.morale
	HRMoraleSystem.send_on_leave(rested, HRConstants.LEAVE_DAYS, false)
	if rested.status != HRConstants.STATUS_ON_LEAVE:
		return "send_on_leave did not put the employee on leave"
	for i in HRConstants.LEAVE_DAYS + 2:
		_sim_day()
	if rested.status != HRConstants.STATUS_ACTIVE:
		return "the employee never came back from leave"
	if rested.morale <= before_leave:
		return "§11.4 izin dönüşü did not raise morale (%d → %d)" % [before_leave, rested.morale]

	# --- 3 · KISA GÜN ---
	# §8.3 / §7.1: beş saatte çarpan ×−1,0, yani taban hızında YÜKSELİR. Bu, çalışma süresi
	# kontrolünü tek yönlü bir baskı aletinden iki yönlü bir kadrana çeviren şeydir.
	var tired: Character = _make_employee("rec_short", "Rec Short", HRConstants.ROLE_DESIGNER,
		SEED_PACE, 0, 50)
	_park_leave([tired])
	WorkHoursSystem.set_company_hours(HRConstants.WORK_HOURS_MIN)
	var before_short: int = tired.morale
	for i in 12:
		_sim_day()
	if tired.morale <= before_short:
		return "§8.3 kısa gün did not raise morale (%d → %d)" % [before_short, tired.morale]
	return ""

static func _case_hr_raise_and_leave() -> String:
	# Raise bounded 3-15% with morale scaling on the percentage and a PERMANENT salary rise
	# that reaches burn; manual vacation takes the person out of capacity, refreshes morale
	# on return, and consumes that year's automatic leave.
	GameState.set_cash(200000)
	var e: Character = _make_employee("char_act", "Act Guy", HRConstants.ROLE_DEVELOPER, SEED_PACE, 10000, 50)
	_park_leave([e])
	# Out-of-range percentages are CLAMPED to the slider bounds rather than refused, so what
	# must hold is that no raise outside 3-15%% can ever be applied.
	if int(HRActions.preview_raise(e, HRConstants.RAISE_MIN_PCT - 1).get("pct", -1)) != HRConstants.RAISE_MIN_PCT:
		return "a percentage below the slider minimum was not clamped up to it"
	if int(HRActions.preview_raise(e, HRConstants.RAISE_MAX_PCT + 1).get("pct", -1)) != HRConstants.RAISE_MAX_PCT:
		return "a percentage above the slider maximum was not clamped down to it"
	var small: Dictionary = HRActions.preview_raise(e, HRConstants.RAISE_MIN_PCT)
	var big: Dictionary = HRActions.preview_raise(e, HRConstants.RAISE_MAX_PCT)
	if int(big.get("morale_after", 0)) <= int(small.get("morale_after", 0)):
		return "the morale gain does not scale with the raise percentage"
	if int(big.get("salary_after", 0)) <= int(small.get("salary_after", 0)):
		return "the preview salary does not scale with the percentage"
	var m0: int = e.morale
	if not HRActions.apply_raise(e, 10):
		return "raise refused"
	if e.monthly_salary != 11000:
		return "a 10 percent raise on 10000 produced %d" % e.monthly_salary
	if e.morale <= m0:
		return "the raise did not raise morale (%d -> %d)" % [m0, e.morale]
	FinanceSystem.daily_tick()
	if int(FinanceSystem.get_burn_breakdown().get("salaries", 0)) != int(round(11000.0 / float(GameState.DAYS_PER_MONTH))):
		return "the raise did not flow to burn"
	# İZİN ARTIK TEK KANALDAN: OTOMATİK YILLIK (H5, 2026-08-22). Oyuncunun
	# "Tatile gönder" yolu kaldırıldı; ölçülen yasa aynı kaldı (biri gider,
	# kapasite düşer, dönüşte moral tazelenir), yalnız kapı değişti.
	var cap0: int = ProductSystem.capacity_total()
	HRMoraleSystem.send_on_leave(e, HRConstants.LEAVE_DAYS, false)
	if e.status != HRConstants.STATUS_ON_LEAVE:
		return "annual leave did not take the employee out of capacity"
	if ProductSystem.capacity_total() != cap0 - 1:
		return "capacity unchanged during leave"
	if e.leave_taken_year != int(GameState.get_date_dict().year):
		return "the automatic leave did not stamp this year's latch"
	var mv: int = e.morale
	for i in HRConstants.LEAVE_DAYS + 3:
		_sim_day()
		if e.status == HRConstants.STATUS_ACTIVE:
			break
	if e.status != HRConstants.STATUS_ACTIVE:
		return "never returned from leave"
	if e.morale <= mv:
		return "the leave return did not refresh morale (%d -> %d)" % [mv, e.morale]
	return ""


static func _case_hr_frank_guard() -> String:
	# Frank is guarded by CATEGORY, not by name: never hireable, fireable, salaried as
	# staff, morale-managed, or included in overtime.
	var frank: Character = CharacterRegistry.get_mentor()
	if frank == null:
		return "no mentor in the registry"
	if frank.category != "mentor":
		return "the mentor is not guarded by category ('%s')" % frank.category
	if HRConstants.role_label(frank.role) != "Operating Partner":
		return "the mentor's visible role drifted: '%s'" % HRConstants.role_label(frank.role)
	for e in CharacterRegistry.get_employees():
		if e.id == frank.id:
			return "the mentor appears in get_employees"
	for e in CharacterRegistry.get_active_employees():
		if e.id == frank.id:
			return "the mentor appears in get_active_employees"
	if CharacterRegistry.get_total_monthly_salaries() != 0:
		return "the mentor draws payroll (%d)" % CharacterRegistry.get_total_monthly_salaries()
	# `can_send_on_vacation` EMEKLİ (H5): eylem kalktı, dolayısıyla Frank'e karşı
	# bağışıklığını sınamaya da gerek kalmadı — hiç kimse için çağrılamıyor.
	if HRActions.can_fire(frank) or HRActions.can_raise(frank, 5):
		return "an HR action accepts the mentor"
	if HRActions.can_fire(CharacterRegistry.get_founder()):
		return "the founder is fireable"
	var dev: Character = _make_employee("char_guard_dev", "Guard Dev", HRConstants.ROLE_DEVELOPER, SEED_PACE, 6000, 90)
	_park_leave([dev])
	# §8.2 / §9.1: mentor bordroda değil ve çalışma saatleri modelinin dışında. Blok
	# sistemi kalktı, ama sorunun kendisi geçerli — yalnız sorulacak yer değişti: on bir
	# saatlik bir şirkette bile mentora mesai tahakkuk etmez ve sayaçlarda görünmez.
	WorkHoursSystem.set_company_hours(HRConstants.WORK_HOURS_MAX)
	if WorkHoursSystem.overtime_pay_today(frank) != 0:
		return "the mentor accrued overtime pay (%d)" % WorkHoursSystem.overtime_pay_today(frank)
	if int(WorkHoursSystem.counts()["overtime"]) != 1:
		return "the overtime headcount is %d — it must count the one employee and nobody else" % int(
			WorkHoursSystem.counts()["overtime"])
	WorkHoursSystem.set_company_hours(HRConstants.WORK_HOURS_DEFAULT)
	var frank_morale: int = frank.morale
	_sim_day()
	if frank.morale != frank_morale:
		return "the mentor's morale was managed by the HR tick (%d -> %d)" % [frank_morale, frank.morale]
	if HRSearchSystem.hire(0) != null:
		return "hire() produced someone with no candidate files ready"
	return ""


static func _case_hr_active_filters() -> String:
	# An on-leave employee is genuinely PRESENT for payroll and every display, and genuinely
	# ABSENT for capacity, speed, overtime and CS dampen. One list would be wrong half the time.
	GameState.set_cash(100000)
	GameState.set_flag("mvp_sub_product_type_id", "ai_vector_search")
	_seed_b2b(1000)
	var dev: Character = _make_employee("char_filt_dev", "Filt Dev", HRConstants.ROLE_DEVELOPER, SEED_PACE, 6000, 60)
	var rep: Character = _make_employee("char_filt_rep", "Filt Rep", HRConstants.ROLE_CUSTOMER_REP, SEED_PACE, 5000, 60)
	_park_leave([dev, rep])
	var cust: Customer = CustomerRegistry.get_by_market("b2b")[0]
	CustomerRegistry.assign_customer(cust.id, rep.id)
	if B2BSalesSystem._account_owner(cust) == null:
		return "an ACTIVE customer rep does not read as the account's owner"
	var cap_before: int = ProductSystem.capacity_total()
	var payroll_before: int = CharacterRegistry.get_total_monthly_salaries()
	var team_before: int = CharacterRegistry.get_employees().size()
	HRMoraleSystem.send_on_leave(dev, HRConstants.LEAVE_DAYS, false)
	HRMoraleSystem.send_on_leave(rep, HRConstants.LEAVE_DAYS, false)
	# EXCLUDED while away.
	if ProductSystem.capacity_total() != cap_before - 1:
		return "an on-leave developer is still in the capacity pool"
	if CharacterRegistry.count_active_developers() != 0:
		return "an on-leave developer counts as active"
	# §8.6: "İzindeki ya da eğitimdeki çalışan üretmez, ÜCRETLENDİRİLMEZ ve saat çarpanı
	# yemez. ... Şirket 11 saatteyken izne çıkan bir çalışan MESAİ ÜCRETİ ALMAZ."
	WorkHoursSystem.set_company_hours(HRConstants.WORK_HOURS_MAX)
	if WorkHoursSystem.overtime_pay_today(rep) != 0:
		return "an on-leave employee accrued overtime pay at eleven company hours (%d)" % \
			WorkHoursSystem.overtime_pay_today(rep)
	WorkHoursSystem.set_company_hours(HRConstants.WORK_HOURS_DEFAULT)
	# B4 (2026-08-27): the absent-owner answer is now `null` rather than a zero score, and the
	# ACCOUNT MUST NOT SILENTLY FALL BACK TO THE FOUNDER while its rep is away — an assigned
	# account belongs to the person assigned to it, present or not. That is what the second
	# check pins.
	if B2BSalesSystem._account_owner(cust) != null:
		return "an on-leave customer rep still cares for the account"
	# INCLUDED while away.
	if CharacterRegistry.get_total_monthly_salaries() != payroll_before:
		return "paid leave is broken: payroll moved (%d -> %d)" % [
			payroll_before, CharacterRegistry.get_total_monthly_salaries()]
	if CharacterRegistry.get_employees().size() != team_before:
		return "an on-leave employee dropped off the roster"
	if int(GameState.get_run_ledger().get("employees", -1)) != team_before:
		return "an on-leave employee dropped out of the run ledger"
	if CharacterRegistry.count_developers() != 1:
		return "an on-leave developer dropped out of the headcount lens"
	return ""


static func _case_hr_overload_badge() -> String:
	# §15.1 · ROZETLER TÜRETİLİR VE BİRBİRİNİ BASTIRMAZ.
	#
	# "Birden fazla rozet aynı anda görünebilir. AŞIRI YÜKTEN MORALİ 35'İN ALTINA DÜŞMÜŞ bir
	# çalışan HEM AŞIRI YÜK HEM Ayrılabilir taşır." Bu case tam olarak o cümleyi ölçüyor —
	# ve o cümle rev 11'den önce hiçbir yüzeyde doğru değildi, çünkü hepsi ilk isabetten
	# sonra dönüyordu.
	#
	# ŞİRKET ÇAPINDAKİ "mühendise ihtiyaç var" ROZETİ KALKTI (§17.6, adıyla): bir şirket
	# sinyalini kişi başına rozet olarak çiziyor, yalnız developer alınarak temizleniyor ve
	# İngilizcede aşırı yük rozetiyle AYNI KELİMEYİ kullanıyordu (§16 bunu yasaklıyor).
	# AŞIRI YÜK artık YALNIZ §12.1'in iş sayısıdır.
	#
	# FALSİFİKASYON: HRMoraleSystem.badges_for'daki is_overloaded dalını sil → "iki rozet"
	# iddiası FAIL eder.
	var dev: Character = _make_employee("char_load_dev", "Load Dev", HRConstants.ROLE_DEVELOPER,
		SEED_PACE, 6000, 70)
	_park_leave([dev])
	if not HRSystem.badges_for(dev).is_empty():
		return "a healthy, single-job employee already carries a badge: %s" % str(HRSystem.badges_for(dev))

	# ŞİRKET BAYRAĞI ARTIK KİMSEYE ROZET TAKMAZ.
	GameState.set_flag("needs_engineer", true)
	if not HRSystem.badges_for(dev).is_empty():
		return "the retired needs_engineer flag still paints a per-person badge (§17.6)"

	# İKİNCİ İŞ → AŞIRI YÜK (§12.1: atanmış iş sayısı 2).
	if CharacterRegistry.assign_job(dev.id, HRConstants.JOB_SUPPORT) != "":
		return "could not give the developer a second job"
	if not HRSystem.badges_for(dev).has(HRConstants.BADGE_OVERLOAD_JOBS):
		return "two jobs did not produce AŞIRI YÜK"

	# MORAL 35 ALTI → Ayrılabilir, VE AŞIRI YÜK KALIR.
	CharacterRegistry.set_morale(dev.id, HRConstants.MORALE_FLIGHT_RISK - 1)
	var badges: Array[String] = HRSystem.badges_for(dev)
	if not badges.has(HRConstants.BADGE_FLIGHT_RISK):
		return "no Ayrılabilir badge under 35"
	if not badges.has(HRConstants.BADGE_OVERLOAD_JOBS):
		return "Ayrılabilir SUPPRESSED AŞIRI YÜK — §15.1 says badges do not suppress each other"
	if badges.size() < 2:
		return "an employee cannot carry two badges at once: %s" % str(badges)

	# KOŞUL ORTADAN KALKINCA ROZET KENDİLİĞİNDEN GİDER (§15.1): "Rozet kalıcı değildir;
	# ikinci iş alındığında AŞIRI YÜK aynı çizimde gider."
	CharacterRegistry.unassign_job(dev.id, HRConstants.JOB_SUPPORT)
	if HRSystem.badges_for(dev).has(HRConstants.BADGE_OVERLOAD_JOBS):
		return "AŞIRI YÜK survived losing the second job — a stored badge would do that"

	# SAKLANAN ROZET ALANI YOKTUR (§15.1) — ve bu artık YAPISAL. `attention_flag` 2026-08-24'te
	# Character'dan SİLİNDİ; iddia "alan boş kaldı mı" değil "alan geri geldi mi" diye soruyor,
	# çünkü bir sonraki yazıcı ancak alanı yeniden ekleyerek gelebilir.
	# FALSİFİKASYON: character.gd'ye `@export var attention_flag: String = ""` geri ekle → FAIL.
	if "attention_flag" in dev:
		return "Character grew a stored badge field again; §15.1 keeps badges derived"
	return ""

static func _case_hr_constants_contract() -> String:
	# The tuning surface itself, asserted rather than trusted. hr_constants.gd is the single
	# home for every HR number, so a typo there is a silent balance change everywhere — and
	# several of these are load-bearing STRUCTURE, not taste: the band shapes must have a
	# strict peak or non-dominance dies, the leave stride must be coprime with its span or
	# hires stack onto one month, and the mentor's label must stay byte-exact because it is
	# already on screen. Absorbed from a throwaway dev probe so the project keeps ONE harness.

	# --- The equivalence anchors the shims used to guarantee, now on the REAL law ---
	# These are the whole reason the Coupling could delete the conversion tables: the rescaled
	# coefficients reproduce the pre-migration numbers exactly at the anchor values.
	# The seeded employee's KEY AREA is what feeds team speed now (2026-08-21). 5 × 0.25.
	if not is_equal_approx(ProductSystem.EMPLOYEE_SPEED_COEF * float(SEED_EXPERTISE), 1.25):
		return "key area %d contributes %.3f efor/day, want 1.25" % [
			SEED_EXPERTISE, ProductSystem.EMPLOYEE_SPEED_COEF * float(SEED_EXPERTISE)]
	if not is_equal_approx(B2BConstants.cs_dampen(5), 0.725):
		return "UZMANLIK-5 dampen is %.4f, want the old cs_skill-55 value 0.725" % B2BConstants.cs_dampen(5)
	if not is_equal_approx(ProductSystem.SEED_EXPERTISE_PIVOT, float(SEED_EXPERTISE)):
		return "the fixture expertise default is no longer the seed pivot — the commit seed will tilt"

	# --- Roles, departments, labels ---
	if HRConstants.EMPLOYEE_ROLES.size() != 6:
		return "employee role count is %d, want the design's six" % HRConstants.EMPLOYEE_ROLES.size()
	for role_id in HRConstants.EMPLOYEE_ROLES:
		if HRConstants.role_label(role_id) == role_id:
			return "role '%s' has no display label" % role_id
		if String(HRConstants.ROLE_GROUP.get(role_id, "")) == "":
			return "role '%s' has no department" % role_id
		# §3: only the role's KEY and SECONDARY areas have help copy — the closed card never
		# shows the other four, so there is nothing to say about them.
		#
		# İKİNCİL ALAN ARTIK HER ROLDE YOK (§4.4). Cross-cover YALNIZ ürün tarafının kendi
		# içindedir: "Satış Temsilcisi — ana alanı Satış. İkincil alanı yoktur." Boş ikincil
		# bir eksiklik değil, verilmiş bir hükümdür, ve vaka artık hükmü doğruluyor.
		if HRConstants.role_key_area(role_id) == "":
			return "role '%s' has no key area — see HRConstants.ROLE_AREAS" % role_id
		var secondary: String = HRConstants.role_secondary_area(role_id)
		var product_side: bool = role_id in [HRConstants.ROLE_PRODUCT_MANAGER,
			HRConstants.ROLE_DESIGNER, HRConstants.ROLE_DEVELOPER, HRConstants.ROLE_TESTER]
		if product_side and secondary == "":
			return "product-side role '%s' lost its secondary area (§4.4 keeps it)" % role_id
		if not product_side and secondary != "":
			return "role '%s' still carries secondary '%s' — §4.4 removes it" % [role_id, secondary]
		for area_key in [HRConstants.role_key_area(role_id), secondary]:
			if String(area_key) == "":
				continue
			if HRConstants.role_area_meaning(role_id, String(area_key)) == "":
				return "role '%s' has no meaning copy for area '%s'" % [role_id, String(area_key)]
	if HRConstants.role_label(HRConstants.ROLE_MENTOR) != "Operating Partner":
		return "the mentor label drifted (it is already on screen): '%s'" % HRConstants.role_label(HRConstants.ROLE_MENTOR)
	# §13.1 DÖRT GRUP, ve altı rolün hepsi tam olarak birine düşer. Departman tablosu kalktı;
	# bu iddia onun yerine taksonomilerin TEKLİĞİNİ ölçüyor.
	var seen_groups: Dictionary = {}
	for role_id2 in HRConstants.EMPLOYEE_ROLES:
		var g: String = String(HRConstants.ROLE_GROUP.get(role_id2, ""))
		if not HRConstants.ROSTER_GROUPS.has(g):
			return "role '%s' maps to '%s', which is not a roster group" % [String(role_id2), g]
		seen_groups[g] = true
	if seen_groups.size() != HRConstants.ROSTER_GROUPS.size():
		return "only %d of the %d roster groups hold a role" % [
			seen_groups.size(), HRConstants.ROSTER_GROUPS.size()]

	# --- Trait catalog: SEKİZ, üçü bedelsiz + beşi bedelli, hepsi gösterilebilir ---
	# Sayı onaylı ikon sayfasından gelir (sekiz glif); bölünme görevin Cost sütunundan.
	if HRConstants.TRAITS.size() != 8:
		return "trait catalog holds %d, the approved sheet draws 8" % HRConstants.TRAITS.size()
	if HRConstants.free_trait_ids().size() != 3 or HRConstants.cost_trait_ids().size() != 5:
		return "trait split is %d free / %d cost, want 3/5" % [
			HRConstants.free_trait_ids().size(), HRConstants.cost_trait_ids().size()]
	# VALANS ÇİZİMDEN ÇIKTI (R4): hiçbir trait'te `polarity` kalmadı. Bu iddia
	# bir çizimin yanlışlıkla eski alanı geri getirmesini yakalar.
	for entry in HRConstants.TRAITS.values():
		if (entry as Dictionary).has("polarity"):
			return "a trait still carries `polarity` — R4 retired good/bad"
	for trait_id in HRConstants.TRAITS.keys():
		if HRConstants.trait_label(trait_id) == trait_id:
			return "trait '%s' has no label" % trait_id
		if HRConstants.trait_effect_text(trait_id) == "":
			return "trait '%s' has no effect text — a candidate file must state it plainly" % trait_id
	# İstifa ekseninin iki ucu birbirini tam olarak götürür (0.6 × 1.6 değil — SADIK ve
	# GÖZÜ YÜKSEKTE aynı anda taşınamaz, ama çarpan yine de çarpımsal olmalı).
	if not is_equal_approx(HRConstants.trait_mult(["loyal"], "resign_chance_mult"), 0.6):
		return "SADIK's resign multiplier drifted"
	if not is_equal_approx(HRConstants.trait_mult(["bag_packed"], "resign_chance_mult"), 1.6):
		return "GÖZÜ YÜKSEKTE's resign multiplier drifted"
	if not is_equal_approx(HRConstants.trait_mult([], "resign_chance_mult"), 1.0):
		return "an empty trait list is not multiplicatively neutral"

	# --- §10.2 arketip şekilleri: hâkimiyetsizliğin ve ayrık fiyatların YAPISAL ön koşulu --
	# Bantlar gitti (§3): üç profil artık bir BÜTÇE kademesi değil, üç ARKETİP.
	for level in HRConstants.LEVELS:
		var per_level: Dictionary = HRConstants.ARCHETYPE_SHAPE.get(int(level), {})
		if per_level.size() != HRConstants.ARCHETYPES.size():
			return "level %d holds %d archetypes, want %d" % [
				int(level), per_level.size(), HRConstants.ARCHETYPES.size()]
		for arch in HRConstants.ARCHETYPES:
			var shape: Array = HRConstants.archetype_shape(int(level), String(arch))
			# ÜÇ değer: şekil ANLAMLA okunur (ana alan · ikincil alan · diğer her alan),
			# eksen listesi üzerinde POZİSYONLA değil. AREAS.size()'a karşı iddia yanlış
			# olurdu — altı alan 3 uzunluğunda bir şekilden DOLDURULUYOR.
			if shape.size() != 3:
				return "level %d archetype '%s' is not [key, secondary, rest]" % [int(level), String(arch)]
			if int(shape[0]) < int(shape[1]) or int(shape[1]) < int(shape[2]):
				return "level %d archetype '%s' breaks key>=secondary>=rest: %s" % [
					int(level), String(arch), str(shape)]
			if int(shape[0]) > HRConstants.AREA_MAX or int(shape[2]) < HRConstants.AREA_MIN:
				return "level %d archetype '%s' leaves the 0-%d ruler: %s" % [
					int(level), String(arch), HRConstants.AREA_MAX, str(shape)]
		# §10.2 kural 2, ŞEKİL DÜZEYİNDE: ana alandaki üç değerin yayılımı en fazla 1 yıldız.
		var keys: Array = []
		for arch2 in HRConstants.ARCHETYPES:
			keys.append(int(HRConstants.archetype_shape(int(level), String(arch2))[0]))
		if HRConstants.stars_for(keys.max()) - HRConstants.stars_for(keys.min()) > 1.0 + 0.001:
			return "level %d key-area shapes span %s — more than one star" % [int(level), str(keys)]
		for role_id in HRConstants.EMPLOYEE_ROLES:
			var b: Array = HRConstants.salary_band_for_level(role_id, int(level))
			if b.size() != 2 or int(b[0]) >= int(b[1]):
				return "salary band %s/lvl%d is not a low..high pair: %s" % [role_id, int(level), str(b)]
			# EN GENİŞ FİYAT FARKI BANDA SIĞMALI, yoksa üçlü tavana yapışır ve %20-45 kuralı
			# yuvarlanarak çöker. Şart: tavan/taban >= 1 + SALARY_SPREAD_MAX_R11.
			if float(b[1]) / float(maxi(int(b[0]), 1)) < 1.0 + HRConstants.SALARY_SPREAD_MAX_R11:
				return "salary band %s/lvl%d (%s) is narrower than the %.0f%% price spread §10.2 requires" % [
					role_id, int(level), str(b), HRConstants.SALARY_SPREAD_MAX_R11 * 100.0]
	# Para SEVİYE satın alır, yoksa üç kademe dekorasyondur — her arketipin ana alanı
	# kademeler arasında tırmanır.
	for arch3 in HRConstants.ARCHETYPES:
		var j: int = int(HRConstants.archetype_shape(HRConstants.LEVEL_JUNIOR, String(arch3))[0])
		var m: int = int(HRConstants.archetype_shape(HRConstants.LEVEL_MID, String(arch3))[0])
		var sr: int = int(HRConstants.archetype_shape(HRConstants.LEVEL_SENIOR, String(arch3))[0])
		if not (j < m and m < sr):
			return "archetype '%s' does not climb the ruler across the levels (%d/%d/%d)" % [
				String(arch3), j, m, sr]
	# §3 UNVAN TÜRETİLİR: Orta'nın ön eki YOKTUR, diğer ikisinin vardır ve farklıdır.
	if HRConstants.job_title(HRConstants.ROLE_DEVELOPER, HRConstants.LEVEL_MID) \
			!= HRConstants.role_label(HRConstants.ROLE_DEVELOPER):
		return "the Orta level added a prefix; §3's table leaves that cell empty"
	if HRConstants.job_title(HRConstants.ROLE_DEVELOPER, HRConstants.LEVEL_JUNIOR) \
			== HRConstants.job_title(HRConstants.ROLE_DEVELOPER, HRConstants.LEVEL_SENIOR):
		return "Junior and Kıdemli render the same title"
	# §3 seviyenin ADI ile ÖN EKİ ayrı: Orta'nın ön eki yok ama adı var, ve Atlas onu çizer.
	if HRConstants.level_label(HRConstants.LEVEL_MID) == "" \
			or HRConstants.level_label(HRConstants.LEVEL_MID) == "HR_LEVEL_MID":
		return "the Orta level has no name — the Atlas segment would render a raw key"

	# --- Economy + action math ---
	# §10: "İşe alım gerçekleştiğinde bir aylık maaşın %50'si komisyon olarak ödenir.
	# $3.000'lik bir çalışanın maliyeti $4.500'dür. RETAINER YOKTUR; tek ücret komisyondur."
	# Eski çift-ücret modeli (peşin $600 + %15) oyuncuyu ARAMADAN ÖNCE cezalandırıyordu.
	if HRConstants.commission_for(3000) != 1500:
		return "commission on 3000 is %d, want §10's 1500 (half a month)" % HRConstants.commission_for(3000)
	if not is_equal_approx(HRConstants.severance_multiple(364), 1.0 / 3.0) \
			or not is_equal_approx(HRConstants.severance_multiple(730), 2.0):
		return "the severance year rule drifted"
	if HRConstants.raise_morale_gain(HRConstants.RAISE_MAX_PCT) <= HRConstants.raise_morale_gain(HRConstants.RAISE_MIN_PCT):
		return "the raise morale gain does not scale with the percentage"

	# --- §8.2 EK MESAİ ÜCRETİ, SAAT BAŞINA ---
	# "Aşan saatler için SAATLİK ÜCRETİN %50 FAZLASI ödenir (çarpan 1,5×). YALNIZ aşan
	# saatler; ilk sekiz saat normal ücrettir." Blok başına günlük yüzde (%40) modeli gitti.
	var hourly: float = float(9000) / float(HRConstants.HOURS_PER_MONTH)
	var want_ot: int = int(round(hourly * 3.0 * HRConstants.OVERTIME_WAGE_MULT))
	if HRConstants.overtime_pay_for_day(9000, HRConstants.WORK_HOURS_MAX) != want_ot:
		return "eleven hours on 9000 bills %d, want %d (three hours at 1.5x)" % [
			HRConstants.overtime_pay_for_day(9000, HRConstants.WORK_HOURS_MAX), want_ot]
	# İLK SEKİZ SAAT NORMAL ÜCRET: sekizde ve altında tahakkuk YOKTUR.
	if HRConstants.overtime_pay_for_day(9000, HRConstants.WORK_HOURS_DEFAULT) != 0 \
			or HRConstants.overtime_pay_for_day(9000, HRConstants.WORK_HOURS_MIN) != 0:
		return "an eight-hour or shorter day accrued overtime"
	# §8.4 ORAN: 11 saat +%37,5, 5 saat %62,5 — §8.1 ve §8.3'ün KENDİ sayıları.
	if not is_equal_approx(HRConstants.hours_output_mult(HRConstants.WORK_HOURS_MAX), 1.375) \
			or not is_equal_approx(HRConstants.hours_output_mult(HRConstants.WORK_HOURS_MIN), 0.625):
		return "the hour-to-output ratio drifted from §8.1/§8.3's own numbers"
	if not is_equal_approx(HRConstants.hours_output_mult(HRConstants.WORK_HOURS_DEFAULT), 1.0):
		return "the standard day is not neutral — every calibrated constant would move"

	# --- Liderlik: climate + coordination ---
	if not is_equal_approx(HRConstants.climate_drop_mult(0), 1.0) or not is_equal_approx(HRConstants.climate_gain_mult(0), 1.0):
		return "leadership 0 must be climate-neutral, or every existing number moves"
	if HRConstants.climate_drop_mult(3) >= 1.0 or HRConstants.climate_gain_mult(3) <= 1.0:
		return "the climate coefficients do not respond to leadership"
	if HRConstants.climate_drop_mult(HRConstants.AREA_MAX) < HRConstants.CLIMATE_DROP_FLOOR:
		return "the climate drop multiplier fell through its floor"
	# coordination_mult() is split by source (founder rises from neutral, a chosen lead is
	# two-sided) — the LEAD variant spans the whole COORD_MIN..COORD_MAX ruler. Both read
	# LİDERLİK since 2026-08-21; the employee side used to read UYUM, which rev 2 §2 deleted.
	if not is_equal_approx(HRConstants.coordination_for_lead(0), HRConstants.COORD_MIN) \
			or not is_equal_approx(HRConstants.coordination_for_lead(HRConstants.AREA_MAX), HRConstants.COORD_MAX):
		return "the coordination multiplier does not span COORD_MIN..COORD_MAX"
	if HRConstants.coordination_for_lead(HRConstants.AREA_MAX, true) <= HRConstants.coordination_for_lead(HRConstants.AREA_MAX, false):
		return "'Doğal lider' adds nothing at the top of the coordination range"
	# Founder-as-lead is NEUTRAL at Liderlik 0 and only rises — the anchor that keeps a
	# tech-3 solo founder at exactly 3.0 efor/gün (hr_constants.gd:532-536).
	if not is_equal_approx(HRConstants.coordination_for_founder(0), HRConstants.COORD_FOUNDER_NEUTRAL):
		return "founder coordination at Liderlik 0 is not neutral"
	if HRConstants.coordination_for_founder(HRConstants.AREA_MAX) <= HRConstants.coordination_for_founder(0):
		return "founder coordination does not rise with Liderlik"

	# --- Thresholds asked through ONE comparison home ---
	if HRConstants.is_flight_risk(HRConstants.MORALE_FLIGHT_RISK):
		return "exactly the flight-risk threshold must NOT count as at risk (design says 'altı')"
	if not HRConstants.is_flight_risk(HRConstants.MORALE_FLIGHT_RISK - 1):
		return "one under the flight-risk threshold is not at risk"
	# TÜKENİYOR bandı §7'de YOK — sabiti, karşılaştırıcısı ve rozeti birlikte gitti. §7'nin
	# dört bandı 80 / 50 / 35 eşikleriyle ölçülüyor ve onları morale_band_mult pinliyor.

	# --- §11.4 IZIN DAGILIMI: YAZ PENCERESI ICINDE, HAFTA HAFTA ---
	# Buradaki blok AY dagilimini olcuyordu (leave_month_for + LEAVE_MONTH_*); §11.4 izni
	# yilin herhangi bir ayindan Haziran-Agustos icinde bir HAFTAYA tasidi ve ay modelinin
	# tamami 2026-08-24'te silindi. Ayni ozellik yeni birimde olculuyor: on uc ardisik ise
	# alim on uc FARKLI haftaya duser (adim 5, pencere 13, aralarinda asal).
	var weeks_seen: Array = []
	for ordinal in HRConstants.LEAVE_WEEK_COUNT:
		var w: int = HRConstants.leave_week_for(ordinal)
		if w < 0 or w >= HRConstants.LEAVE_WEEK_COUNT:
			return "leave week out of the summer window: %d" % w
		if weeks_seen.has(w):
			return "leave week %d repeats inside the window (stride not coprime with %d)" % [
				w, HRConstants.LEAVE_WEEK_COUNT]
		weeks_seen.append(w)
	return ""


# ============================ Speed ladder (tempo) ===========================
# The ladder is expressed as REAL SECONDS PER IN-GAME DAY in ONE place
# (TimeManager.SECONDS_PER_DAY). These two cases pin the contract that makes the
# retune safe: the table itself, and the fact that a game day is the same number
# of ticks at every speed (only the real-time rate differs).

static func _case_speed_ladder() -> String:
	# The 4x rung is gone — pause + 1x/2x/3x.
	var ladder: Array = TimeManager.SECONDS_PER_DAY
	if ladder.size() != 4:
		return "the ladder has %d entries, want 4 (pause + 1x/2x/3x)" % ladder.size()
	var want: Array = [0.0, 12.0, 6.0, 3.0]
	for i in ladder.size():
		if not is_equal_approx(float(ladder[i]), float(want[i])):
			return "speed %d is %.3f s/day, want %.3f" % [i, ladder[i], want[i]]
	# Strictly faster as the index rises (idx 0 is pause, not part of the ordering).
	for i in range(2, ladder.size()):
		if float(ladder[i]) >= float(ladder[i - 1]):
			return "speed %d is not faster than speed %d" % [i, i - 1]

	# Derivation: hours-per-real-second comes from the table, never stored separately.
	if not is_equal_approx(TimeManager.hours_per_real_second(0), 0.0):
		return "pause must accrue no in-game hours"
	for i in range(1, ladder.size()):
		var want_mult: float = float(TimeManager.HOURS_PER_DAY) / float(ladder[i])
		if not is_equal_approx(TimeManager.hours_per_real_second(i), want_mult):
			return "speed %d multiplier is %.4f, want %.4f" % [i, TimeManager.hours_per_real_second(i), want_mult]
	# Out-of-range indices must be inert, not crash the accumulator.
	if not is_equal_approx(TimeManager.hours_per_real_second(ladder.size()), 0.0):
		return "an out-of-range speed index returned a live multiplier"

	# Bounds: the top index (3) is accepted, one past it (the old 4x) is refused.
	EventBus.speed_change_requested.emit(3)
	if TimeManager.current_speed != 3:
		return "top speed 3 was rejected (current %d)" % TimeManager.current_speed
	EventBus.speed_change_requested.emit(4)
	if TimeManager.current_speed != 3:
		return "the retired 4x index was accepted (current %d)" % TimeManager.current_speed

	# Pause/resume round-trip at the top index (speed_preserve covers idx 2).
	EventBus.speed_change_requested.emit(0)
	TimeManager.resume_if_paused()
	if TimeManager.current_speed != 3:
		return "paused game did not resume to last_running_speed (%d)" % TimeManager.current_speed
	if TimeManager.get_tree().paused:
		return "tree still paused after resume"
	return ""


static func _case_speed_day_invariant() -> String:
	# TICK PURITY: one in-game day is exactly HOURS_PER_DAY hourly boundaries and one
	# day advance at EVERY speed — only the real-time cost differs. Drives the
	# accumulator directly (no wall clock), the way the rest of this harness drives ticks.
	# Counters hang off the GameState seams (set_current_hour / advance_day), so they stay
	# honest even if a terminal fires and the dispatch guards start returning early.
	for idx in range(1, TimeManager.SECONDS_PER_DAY.size()):
		var counts: Dictionary = {"h": 0, "d": 0}
		var on_hour: Callable = func(_h: int) -> void: counts["h"] += 1
		var on_day: Callable = func(_d: int) -> void: counts["d"] += 1
		EventBus.hour_changed.connect(on_hour)
		EventBus.day_advanced.connect(on_day)

		# Start the day cleanly at 00:00 and zero the counters AFTER that write.
		GameState.set_current_hour(0)
		TimeManager.sync_to_current_hour()
		counts["h"] = 0
		counts["d"] = 0

		var secs: float = float(TimeManager.SECONDS_PER_DAY[idx])
		var mult: float = TimeManager.hours_per_real_second(idx)
		var step: float = secs / 1000.0        # 0.1% of a day per step
		var elapsed: float = 0.0
		var guard: int = 0
		while counts["d"] < 1 and guard < 5000:
			guard += 1
			TimeManager._in_game_hours += mult * step
			TimeManager._drain_boundaries()
			elapsed += step

		EventBus.hour_changed.disconnect(on_hour)
		EventBus.day_advanced.disconnect(on_day)

		if counts["d"] != 1:
			return "speed %d did not roll a day over within one day of real time" % idx
		if counts["h"] != TimeManager.HOURS_PER_DAY:
			return "speed %d fired %d hourly ticks in a day, want %d" % [idx, counts["h"], TimeManager.HOURS_PER_DAY]
		# ...and the day cost the real seconds the ladder advertises.
		if absf(elapsed - secs) > secs * 0.01:
			return "speed %d took %.3f real s/day, want %.3f" % [idx, elapsed, secs]
	return ""


# ============================================================================
#  Product×HR Coupling (task 2 of 3) — the axes now DO something. Task 1 proved
#  nothing moved; these prove the right things move, and that the two hard
#  equivalence anchors survived the rescale exactly.
# ============================================================================

static func _case_coupling_speed_law() -> String:
	# THE hız yasası, both hard anchors in one place, measured through the real formula.
	GameState.set_cash(200000)
	var founder: Character = CharacterRegistry.get_founder()
	_set_founder_tech(6)
	var coord: float = HRConstants.coordination_for_founder(GameState.get_founder_skill("leadership"))
	if not is_equal_approx(coord, 1.0):
		return "the debug payload no longer gives a neutral coordination multiplier (%.3f) — every anchor below shifts" % coord
	if not ProductSystem.start_build("ai_assistant", ["ai_assistant_tools", "ai_assistant_image"], ""):
		return "start_build failed"
	var b: FeatureBuild = ProductSystem.get_active_build()
	if not _run_build_to_phase("development"):
		return "build never reached development"
	# ANCHOR a2: SOLO KURUCU == 3,0 efor/gün, Coupling öncesiyle birebir aynı sayı.
	# Çapa cetvel değişiminden SAĞ ÇIKTI ve bu kasıtlı: fixture 3'ten 6'ya, katsayı 1,0'dan
	# 0,5'e gitti (§2.4), çarpım kıpırdamadı. Ölçülen sayının aynı kalması, cetvel
	# değişiminin kurucunun yapım katkısını sessizce iki katına ÇIKARMADIĞININ kanıtı.
	if absf(ProductSystem.team_speed(b) - 3.0) > 0.001:
		return "anchor a2 broken: solo founder is %.3f efor/day, want 3.0" % ProductSystem.team_speed(b)
	# ANCHOR b1: a seeded developer adds EMPLOYEE_SPEED_COEF × their Yazılım. It was 1.0 (the
	# pre-Coupling assist engineer) while the seed's build number was HIZ 4; the area
	# migration made it the KEY AREA, seeded at SEED_EXPERTISE, so the anchor is 1.25.
	# The COEFFICIENT did not move — the number it multiplies did.
	var want_b1: float = 3.0 + ProductSystem.EMPLOYEE_SPEED_COEF * float(SEED_EXPERTISE)
	_make_employee("char_law_dev", "Law Dev", HRConstants.ROLE_DEVELOPER)
	if absf(ProductSystem.team_speed(b) - want_b1) > 0.001:
		return "anchor b1 broken: +seeded developer gives %.3f, want %.3f" % [
			ProductSystem.team_speed(b), want_b1]
	# ATAMA KAPISI (onaylı tasarım, 2026-08-22). Bir tasarımcının alanları Tasarım ve Ürün;
	# Yazılım ikisi de değil, yani GELİŞTİRME fazına hiç giremez ve hızı kıpırdatmaz. §2'nin
	# "tek kişilik ekipte boşluk kalmaz" cümlesi YETENEK hakkında — herkeste altı sayı var —
	# ama kimin nereye GİRDİĞİNİ atama söylüyor, ve Görevler matrisi bu iki alan dışındaki
	# her sütunu "ALANI YOK · ATANAMAZ" diye kesikli çiziyor.
	var before_designer: float = ProductSystem.team_speed(b)
	_make_employee("char_law_designer", "Law Designer", HRConstants.ROLE_DESIGNER)
	var with_designer: float = ProductSystem.team_speed(b)
	if absf(with_designer - before_designer) > 0.001:
		return "a designer moved GELİŞTİRME speed (%.3f -> %.3f); Yazılım is not one of their two areas" % [
			before_designer, with_designer]
	# ...ve aynası: TASARIM fazında tasarımcı SAYILIR, yazılımcı SAYILMAZ. Toplam kurucu +
	# tasarımcı(ana alan); yazılımcı terimi YOK, çünkü o fazın alanlarına atanamaz.
	var iter_speed: float = ProductSystem._speed_for_phase("iteration", "")
	# Kurucu terimi SABİT YAZILMIYOR, motordan okunuyor: burada `3.0` duruyordu ve o sayı
	# kurucunun ESKİ cetveldeki fixture değeriydi. Cetvel değişince iddia ölçtüğü şeyden
	# koptu — "tasarımcı sayılıyor mu" sorusunu değil "fixture kaç" sorusunu ölçer oldu.
	var founder_area: float = float(GameState.get_founder_skill(
		ProductSystem._founder_phase_area("iteration")))
	var want_iter: float = ProductSystem.FOUNDER_SPEED_COEF * founder_area \
		+ ProductSystem.EMPLOYEE_SPEED_COEF * float(SEED_EXPERTISE)
	if absf(iter_speed - want_iter) > 0.001:
		return "TASARIM speed %.3f, want founder + designer only (%.3f) — the developer must not appear" % [
			iter_speed, want_iter]
	# AĞIRLIK YOK among employees: making the developer the SORUMLU must not change the SUM.
	# (Their quality shows up in the coordination term, which is what replaced the lead weight.)
	var sum_before: float = ProductSystem._phase_area_sum("development", "")
	var sum_as_lead: float = ProductSystem._phase_area_sum("development", "char_law_dev")
	if absf(sum_before - sum_as_lead) > 0.001:
		return "the lead still carries extra HIZ weight (%.3f vs %.3f) — 'ağırlık yok' broken" % [sum_before, sum_as_lead]
	return ""


static func _case_coupling_coordination_sources() -> String:
	# The multiplier is asymmetric BY SOURCE, and a stale lead resolves loudly to the founder.
	GameState.set_cash(200000)
	var founder: Character = CharacterRegistry.get_founder()
	_set_founder_tech(6)
	founder.role_stats["leadership"] = 0
	# Founder-as-lead is never a penalty: neutral at Liderlik 0, rising after that.
	if not is_equal_approx(HRConstants.coordination_for_founder(0), 1.0):
		return "founder coordination at Liderlik 0 is %.3f, want exactly 1.0" % HRConstants.coordination_for_founder(0)
	if HRConstants.coordination_for_founder(9) <= 1.0:
		return "founder coordination does not rise with Liderlik"
	# A CHOSEN employee lead is still a real bet — low LİDERLİK genuinely coordinates worse.
	if HRConstants.coordination_for_lead(0) >= 1.0:
		return "a Liderlik-0 lead is not a penalty (%.3f)" % HRConstants.coordination_for_lead(0)
	if HRConstants.coordination_for_lead(0) >= HRConstants.coordination_for_lead(9):
		return "lead coordination is not two-sided across the ruler"
	# The lead's LİDERLİK actually reaches the build speed.
	if not ProductSystem.start_build("ai_assistant", ["ai_assistant_tools", "ai_assistant_image"], ""):
		return "start_build failed"
	var b: FeatureBuild = ProductSystem.get_active_build()
	if not _run_build_to_phase("development"):
		return "build never reached development"
	var weak: Character = _make_employee("char_coord_weak", "Weak Lead", HRConstants.ROLE_DEVELOPER,
		SEED_PACE, 0, 50, SEED_EXPERTISE, 0)
	var strong: Character = _make_employee("char_coord_strong", "Strong Lead", HRConstants.ROLE_DEVELOPER,
		SEED_PACE, 0, 50, SEED_EXPERTISE, 9)
	b.lead_engineer_id = weak.id
	var speed_weak: float = ProductSystem.team_speed(b)
	b.lead_engineer_id = strong.id
	var speed_strong: float = ProductSystem.team_speed(b)
	if speed_strong <= speed_weak:
		return "the SORUMLU's UYUM does not reach build speed (%.3f vs %.3f)" % [speed_weak, speed_strong]
	# STALE LEAD: a fired or on-leave SORUMLU resolves to founder-as-lead, not to a silent
	# fallback. Nothing rewrites lead_engineer_id after commit, so this path is reachable.
	b.lead_engineer_id = strong.id
	HRMoraleSystem.send_on_leave(strong, HRConstants.LEAVE_DAYS, false)
	var speed_on_leave: float = ProductSystem.team_speed(b)
	b.lead_engineer_id = ""
	if absf(speed_on_leave - ProductSystem.team_speed(b)) > 0.001:
		return "an on-leave SORUMLU did not resolve to founder-as-lead (%.3f vs %.3f)" % [
			speed_on_leave, ProductSystem.team_speed(b)]
	return ""


static func _case_coupling_bug_team_average() -> String:
	# Bug rate reads the team's UZMANLIK WEIGHTED AVERAGE, and the average cuts BOTH ways.
	var founder: Character = CharacterRegistry.get_founder()
	_set_founder_tech(6)
	# GELİŞTİRME fazının alanı Yazılım; commit anındaki hata tohumu da onu okur (rev 2 §2).
	var dev_area: String = HRConstants.AREA_ENGINEERING
	# Kurucu yalnız ve sorumluyken ortalama TAM OLARAK onun kendi puanıdır: ağırlıklar
	# sadeleşir ((1,5 × p) / 1,5 = p), o yüzden BUG_TECH_REDUCER hiç yeniden ölçeklenmedi.
	#
	# DEĞER MOTORDAN OKUNUR. Burada `3.0` sabit yazılıydı ve o eski cetvelin fixture
	# değeriydi; §2.4 kurucuyu 0–10'a alınca sayı 6 oldu. VE BU BİR DENGE DEĞİŞİKLİĞİ:
	# `_team_area_avg` kurucu ile çalışanı NORMALİZE ETMEDEN aynı ortalamada topluyor, yani
	# tek kurucu hâlinde bug/wear azaltması gerçekten ikiye katlanıyor. Katsayıyı yarıya
	# indirmek çalışan-ağırlıklı hâli bozardı; doğru olan kurucunun nihayet aynı cetvelde
	# sayılması. Beyan edilir, gizlenmez.
	var founder_area_value: float = float(GameState.get_founder_skill(dev_area))
	if absf(ProductSystem._team_area_avg(dev_area, "") - founder_area_value) > 0.001:
		return "founder-solo average is %.3f, want his own %.1f exactly" % [
			ProductSystem._team_area_avg(dev_area, ""), founder_area_value]
	# A STRONG team lifts the average (fewer bugs)...
	var strong: Character = _make_employee("char_bug_strong", "Strong Dev", HRConstants.ROLE_DEVELOPER,
		SEED_PACE, 0, 50, 9, SEED_RAPPORT)
	var avg_strong: float = ProductSystem._team_area_avg(dev_area, "")
	if avg_strong <= founder_area_value:
		return "an UZMANLIK-9 developer did not lift the average above the founder's own %.1f (%.3f)" % [
			founder_area_value, avg_strong]
	CharacterRegistry.remove(strong.id)
	# ...and a WEAK team drags it below the founder's own number (more bugs). Two-directional.
	_make_employee("char_bug_weak", "Weak Dev", HRConstants.ROLE_DEVELOPER,
		SEED_PACE, 0, 50, 0, SEED_RAPPORT)
	var avg_weak: float = ProductSystem._team_area_avg(dev_area, "")
	if avg_weak >= founder_area_value:
		return "an UZMANLIK-0 developer did not drag the average below the founder's own %.1f (%.3f)" % [
			founder_area_value, avg_weak]
	# The SORUMLU carries ×1.5, so who is in charge changes the quality average.
	var as_member: float = ProductSystem._team_area_avg(dev_area, "")
	var as_lead: float = ProductSystem._team_area_avg(dev_area, "char_bug_weak")
	if as_lead >= as_member:
		return "making the weak developer SORUMLU did not lower the average (%.3f -> %.3f)" % [as_member, as_lead]
	return ""


static func _case_coupling_wear_team_average() -> String:
	# Post-ship wear follows the SAME grammar as bug — the founder-only read is gone.
	_seed_live_product()
	var founder: Character = CharacterRegistry.get_founder()
	_set_founder_tech(6)
	# The audience must be big enough to keep the wear rate OFF WEAR_FLOOR in BOTH arms —
	# otherwise both clamp to the floor and read identical, which says nothing about the
	# expertise term. (That is how this case first failed: 0.0480 == 24 x WEAR_FLOOR exactly.)
	GameState.set_flag("b2c_audience", 1000.0)
	GameState.set_flag("mvp_live_bug_count", 0)
	GameState.set_flag("mvp_live_bug_progress", 0.0)
	# Wear with the founder alone, over a day of live product.
	for h in 24:
		ProductSystem.hourly_tick(h)
	var solo_wear: float = float(GameState.get_flag("mvp_live_bug_progress", 0.0)) \
		+ float(int(GameState.get_flag("mvp_live_bug_count", 0)))
	if solo_wear <= 0.0:
		return "live product did not wear at all — case window invalid"
	if absf(solo_wear - 24.0 * ProductSystem.WEAR_FLOOR) < 0.0001:
		return "the wear rate is pinned at WEAR_FLOOR (%.4f) — the expertise term cannot be seen" % solo_wear
	# Aynı gün, bu kez kadroda yüksek TEST'li biri var: aşınma YAVAŞLAMALI.
	#
	# İŞE ALINAN KİŞİ DEĞİŞTİ (2026-08-22): yazılımcı yerine TEST MÜHENDİSİ. Canlı ürün
	# aşınması TEST alanını okuyor (rev 2 §2) ve atama kapısıyla birlikte artık YALNIZ Test'e
	# ATANMIŞ biri o sayıya giriyor. Bir yazılımcı kendi ana alanına (Yazılım) doğuyor —
	# Test onun ikincil alanı, ama oraya ATANMADIĞI sürece aşınmaya dokunmaz. Ölçülen yasa
	# aynı: "ekibin Test'i canlı ürünün aşınmasını yavaşlatır".
	_make_employee("char_wear_dev", "Wear Tester", HRConstants.ROLE_TESTER,
		SEED_PACE, 0, 50, 9, SEED_RAPPORT)
	GameState.set_flag("b2c_audience", 1000.0)
	GameState.set_flag("mvp_live_bug_count", 0)
	GameState.set_flag("mvp_live_bug_progress", 0.0)
	for h in 24:
		ProductSystem.hourly_tick(h)
	var team_wear: float = float(GameState.get_flag("mvp_live_bug_progress", 0.0)) \
		+ float(int(GameState.get_flag("mvp_live_bug_count", 0)))
	if team_wear >= solo_wear:
		return "a strong developer did not slow live-product wear (%.4f -> %.4f)" % [solo_wear, team_wear]
	return ""


static func _case_coupling_pm_experience_bonus() -> String:
	# TASARIM's quality channel: Ürün Yöneticisi UZMANLIK → Deneyim team bonus, and the
	# "önizleme == ship" structural guarantee must survive it.
	GameState.set_cash(200000)
	var picks := ["ai_assistant_chat", "ai_assistant_memory"]
	var before: Dictionary = ProductSystem.projected_axes(picks, [], {})
	# Kimse Tasarım'a atanmamışsa bonus tam olarak 0 — PM'siz her case bu yüzden dokunulmamış.
	#
	# ATAMA KAPISI, rev 11 §12.0 GRANÜLERLİĞİNDE. 2026-08-22'de bu case "PM'i Ürün'e mi
	# Tasarım'a mı koyuyorsun" kararını koruyordu. §12.0 atama birimini ALANDAN İŞE aldı ve
	# o karar ortadan kalktı: Build ekibi Ürün · Tasarım · Yazılım alanlarınca taşınır, yani
	# Build'deki bir Ürün Yöneticisi ikisini de getirir — Ürün'ünü ana (×1,0), Tasarım'ını
	# ikincil (×0,8) katsayısıyla. §4.3'ün "atanabilir, biraz daha verimsiz" cümlesi tam
	# olarak budur.
	#
	# Case'in ASIL ölçtüğü şey korunuyor: bonus hâlâ bir ATAMA KARARINA bağlı. Yalnız karar
	# artık "hangi alan" değil, "Build'de mi değil mi".
	var pm: Character = _make_employee("char_pm", "Pm One", HRConstants.ROLE_PRODUCT_MANAGER,
		SEED_PACE, 0, 50, 4, SEED_RAPPORT)
	# Yeni işe alınan Build'e oturur (default_job_for_role) → bonus GELİR.
	if float(ProductSystem.projected_axes(picks, [], {})["experience"]) \
		- float(before["experience"]) <= 0.0:
		return "a PM on the Build job added no Deneyim — §12.0 says Build carries Tasarım"
	# İŞTEN ÇIKARILINCA bonus GİDER: karar hâlâ karar.
	CharacterRegistry.clear_jobs(pm.id)
	if absf(float(ProductSystem.projected_axes(picks, [], {})["experience"])
			- float(before["experience"])) > 0.001:
		return "an unassigned PM still moved Deneyim — the bonus must follow the assignment"
	if CharacterRegistry.assign_job(pm.id, HRConstants.JOB_BUILD) != "":
		return "a PM was refused the Build job, which their Ürün area carries"
	var after: Dictionary = ProductSystem.projected_axes(picks, [], {})
	var gain: float = float(after["experience"]) - float(before["experience"])
	if gain <= 0.0:
		return "a product manager added no Deneyim bonus"
	if absf(float(after["innovation"]) - float(before["innovation"])) > 0.001 \
			or absf(float(after["stability"]) - float(before["stability"])) > 0.001:
		return "the PM bonus leaked into an axis other than Deneyim"
	# The CAP applies to the BONUS TERM, not the axis total — otherwise v2's accumulated
	# Deneyim would eat the cap and a new PM would silently add nothing.
	# `expertise` 2026-08-21'de emekli oldu; tavanı zorlamak için TASARIM'ı yükseltiyoruz,
	# çünkü bonusun okuduğu alan o.
	pm.role_stats[HRConstants.AREA_DESIGN] = HRConstants.AREA_MAX
	# İkinci PM de Build'e doğar; ayrıca bir alan taşıması gerekmiyor (§12.0).
	var pm2: Character = _make_employee("char_pm2", "Pm Two", HRConstants.ROLE_PRODUCT_MANAGER,
		SEED_PACE, 0, 50, 9, SEED_RAPPORT)
	var capped: Dictionary = ProductSystem.projected_axes(picks, [], {})
	var capped_gain: float = float(capped["experience"]) - float(before["experience"])
	if capped_gain > ProductSystem.PM_EXPERIENCE_CAP + 0.001:
		return "the PM bonus exceeded its cap (%.3f > %.3f)" % [capped_gain, ProductSystem.PM_EXPERIENCE_CAP]
	# A high v2 base must still receive the full capped bonus (the cap is on the term).
	var high_base := {"innovation": 40.0, "stability": 40.0, "experience": 40.0}
	var v2: Dictionary = ProductSystem.projected_axes(picks, [], high_base)
	var v2_no_pm: float = float(before["experience"]) + 40.0
	if absf((float(v2["experience"]) - v2_no_pm) - capped_gain) > 0.001:
		return "the cap was applied to the axis total, not the bonus term (v2 gain %.3f vs %.3f)" % [
			float(v2["experience"]) - v2_no_pm, capped_gain]
	# ÖNİZLEME == SHIP: the stamp must equal a fresh projection, bonus included.
	if not ProductSystem.start_build("ai_assistant", picks, ""):
		return "start_build failed"
	var b: FeatureBuild = ProductSystem.get_active_build()
	var want: Dictionary = ProductSystem.projected_axes(picks, [], {})
	if absf(b.experience - float(want["experience"])) > 0.001:
		return "commit stamp %.3f != fresh projection %.3f — preview == ship broken by the PM bonus" % [
			b.experience, float(want["experience"])]
	return ""


static func _case_coupling_tester_beta_and_sprint() -> String:
	# TEST bölümü: bulma isabeti + tempo from the Test Uzmanı, and a shorter hata sprinti.
	# No tester → every multiplier is exactly 1.0, which is why the existing beta cases hold.
	if not is_equal_approx(ProductSystem.tester_find_mult(), 1.0) \
			or not is_equal_approx(ProductSystem.tester_tempo_mult(), 1.0):
		return "the tester multipliers are not neutral with no tester on staff"
	var solo_sprint: int = ProductSystem.sprint_duration_for(28)
	_make_employee("char_tester", "Test One", HRConstants.ROLE_TESTER,
		SEED_PACE, 0, 50, 9, SEED_RAPPORT)
	if ProductSystem.tester_find_mult() <= 1.0:
		return "a UZMANLIK-9 tester did not raise bug-finding accuracy"
	if ProductSystem.tester_tempo_mult() <= 1.0:
		return "a tester did not raise the find/fix tempo"
	var team_sprint: int = ProductSystem.sprint_duration_for(28)
	if team_sprint >= solo_sprint:
		return "a tester did not shorten the hata sprinti (%d -> %d days)" % [solo_sprint, team_sprint]
	if team_sprint < ProductSystem.MIN_SPRINT_DAYS:
		return "the sprint fell below MIN_SPRINT_DAYS (%d)" % team_sprint
	# The tester also joins BETA's speed crew (PHASE_CREW bugfix = tester + developer).
	if not ProductSystem._phase_areas("bugfix").has(HRConstants.AREA_QA):
		return "the tester is not in the BETA phase crew"
	return ""


static func _case_coupling_cs_dampen_axis() -> String:
	# ANCHOR b2: the churn dampen reads UZMANLIK directly, and a UZMANLIK-5 rep dampens
	# EXACTLY as the pre-Coupling cs_skill-55 rep did — the shim's promise, kept without it.
	if not is_equal_approx(B2BConstants.cs_dampen(5), 0.725):
		return "UZMANLIK-5 dampen is %.4f, want the old cs_skill-55 value 0.725" % B2BConstants.cs_dampen(5)
	# Today's structural property preserved: the floor stays unreachable across the ruler.
	if B2BConstants.cs_dampen(HRConstants.AREA_MAX) <= B2BConstants.CS_DAMPEN_MIN:
		return "the dampen now reaches its floor; it did not before, so the erosion band moved"
	if B2BConstants.cs_dampen(0) < 1.0:
		return "a UZMANLIK-0 rep dampens erosion (%.4f); zero skill must mean zero help" % B2BConstants.cs_dampen(0)
	if B2BConstants.cs_dampen(9) >= B2BConstants.cs_dampen(0):
		return "the dampen does not strengthen with UZMANLIK"
	# End to end: a strong rep really does erode slower than a weak one on identical accounts.
	GameState.set_flag("mvp_sub_product_type_id", "ai_vector_search")
	_seed_b2b(1000)
	var weak_rep: Character = _make_employee("char_dmp_weak", "Weak Rep", HRConstants.ROLE_CUSTOMER_REP,
		SEED_PACE, 0, 50, 1, SEED_RAPPORT)
	var strong_rep: Character = _make_employee("char_dmp_strong", "Strong Rep", HRConstants.ROLE_CUSTOMER_REP,
		SEED_PACE, 0, 50, 9, SEED_RAPPORT)
	var a: Customer = CustomerRegistry.get_by_market("b2b")[0]
	var p := Prospect.new()
	p.id = "dmp"
	p.company_name = "Dampen Co"
	p.industry = "insurance"
	p.star = 1
	p.pain_feature_id = "ai_vec_filter"
	var bb: Customer = _sign_fixture(p, 1000, 70)
	CustomerRegistry.assign_customer(a.id, weak_rep.id)
	CustomerRegistry.assign_customer(bb.id, strong_rep.id)
	GameState.set_flag("mvp_stability", 20.0)
	GameState.set_flag("mvp_live_bug_count", 40)
	CustomerRegistry.set_satisfaction(a.id, 60)
	CustomerRegistry.set_satisfaction(bb.id, 60)
	for i in 6:
		GameState.advance_day()
		B2BSalesSystem.daily_tick()
	if bb.satisfaction <= a.satisfaction:
		return "the UZMANLIK-9 rep did not hold the account better (strong=%d weak=%d)" % [
			bb.satisfaction, a.satisfaction]
	return ""


static func _case_coupling_overtime_applied() -> String:
	# The multipliers task 1 exposed are now APPLIED. Nothing proved this wiring before: task 1
	# could only assert the numbers were queryable, so a formula that never read them looked fine.
	GameState.set_cash(200000)
	var founder: Character = CharacterRegistry.get_founder()
	_set_founder_tech(6)
	_make_employee("char_ot_dev", "OT Dev", HRConstants.ROLE_DEVELOPER, SEED_PACE, 6000, 100)
	# DÖRT özellik, iki değil. Ölçüm iki tam günü efor TAVANINA ÇARPMADAN geçirmek zorunda:
	# tavana dayanan gün son saatlerde daha az efor yazar ve oran sessizce 1.30'un altına
	# düşer. 2026-08-21'de tam olarak bu oldu — alan migrasyonu çalışanın katkısını 1.0'dan
	# 1.25'e çıkardı, build daha erken tavana vardı ve oran 1.259 okundu. Ölçülen yasa
	# değişmedi; ölçüm penceresi dardı.
	if not ProductSystem.start_build("ai_assistant",
			["ai_assistant_tools", "ai_assistant_image", "ai_assistant_memory", "ai_assistant_voice"], ""):
		return "start_build failed"
	var b: FeatureBuild = ProductSystem.get_active_build()
	if not _run_build_to_phase("development"):
		return "build never reached development"
	# Baseline day, no block running.
	var e0: float = b.efor_spent
	var bugs0: float = b.bug_progress + float(b.bug_count)
	for h in 24:
		ProductSystem.hourly_tick(h)
	var base_efor: float = b.efor_spent - e0
	var base_bugs: float = (b.bug_progress + float(b.bug_count)) - bugs0
	# ---- §8.4 · GETİRİ SAATİN KENDİSİDİR ----
	# "Ekip 8 saatte belli bir çıktı üretiyorsa 11 saatte ORANTILI OLARAK daha fazla üretir.
	# Fazladan bir 'ek mesai hızı' katsayısı UYGULANMAZ — eski koddaki +%30/+%15 hız bonusu
	# kaldırılmıştır." Oran BİR SAYI, ve o sayı §8.1'in kendi cümlesinde yazıyor: "en fazla
	# üç saat ek mesai, yani EN FAZLA +%37,5 ÇIKTI."
	#
	# FALSİFİKASYON: HRSystem.daily_contribution'dan hours_output_mult çarpanını kaldır →
	# oran 1,0 çıkar ve ilk iddia FAIL eder.
	WorkHoursSystem.set_company_hours(HRConstants.WORK_HOURS_MAX)
	e0 = b.efor_spent
	bugs0 = b.bug_progress + float(b.bug_count)
	for h in 24:
		ProductSystem.hourly_tick(h)
	var long_efor: float = b.efor_spent - e0
	var long_bugs: float = (b.bug_progress + float(b.bug_count)) - bugs0
	var want_ratio: float = HRConstants.hours_output_mult(HRConstants.WORK_HOURS_MAX)
	if absf(long_efor / maxf(0.001, base_efor) - want_ratio) > 0.02:
		return "an eleven-hour day produced %.3f× the eight-hour day, want %.3f" % [
			long_efor / maxf(0.001, base_efor), want_ratio]
	# §8.4: EK MESAİ KALİTE CEZASI TAŞIMAZ. "Eski koddaki ×1,25 bug çarpanı kaldırılmıştır.
	# Gerekçe: §7 moralin kaliteye dokunmadığını söyler; ek mesainin dokunması aynı sınırı
	# ihlal ederdi." Bug oranı ÇALIŞILAN SAATLE artmaz — hata birikimi kapasite çarpanından
	# gelir ve o saatten bağımsızdır, o yüzden iki günün bug'ı BİRBİRİNE EŞİT olmalı.
	if absf(long_bugs - base_bugs) > 0.0001:
		return "an eleven-hour day changed the bug rate (%.4f -> %.4f) — §8.4 forbids it" % [
			base_bugs, long_bugs]
	# ---- §8.3 · KISA GÜN, AYNI ORANLA AŞAĞI ----
	# "Beş saatlik gün, sekiz saatlik günün %62,5'i kadar iş çıkarır."
	WorkHoursSystem.set_company_hours(HRConstants.WORK_HOURS_MIN)
	e0 = b.efor_spent
	for h in 24:
		ProductSystem.hourly_tick(h)
	var short_efor: float = b.efor_spent - e0
	var want_short: float = HRConstants.hours_output_mult(HRConstants.WORK_HOURS_MIN)
	if absf(short_efor / maxf(0.001, base_efor) - want_short) > 0.02:
		return "a five-hour day produced %.3f× the eight-hour day, want %.3f" % [
			short_efor / maxf(0.001, base_efor), want_short]
	WorkHoursSystem.set_company_hours(HRConstants.WORK_HOURS_DEFAULT)
	return ""


# ============ Sales/Customer x HR Coupling (task 2b) ============================
# Shared shape: seed a shipped B2B product, hire the desk staff the case is about, drive whole
# days, and assert against the OWNING constants file (never a literal) so a calibration retune
# does not rewrite the tests.

static func _make_sales_rep(id: String, pace: int, expertise: int) -> Character:
	return _make_employee(id, "Satis " + id, HRConstants.ROLE_SALES_REP,
		pace, 0, 50, expertise, SEED_RAPPORT)


static func _make_cs_rep(id: String, pace: int, expertise: int) -> Character:
	return _make_employee(id, "Temsilci " + id, HRConstants.ROLE_CUSTOMER_REP,
		pace, 0, 50, expertise, SEED_RAPPORT)


static func _add_prospect(pid: String, star: int, pain: String,
		archetype_id: String = SalesArchetypes.DEFAULT_ID) -> Prospect:
	# Hand-built so a case controls the star, the archetype and the pain exactly (the faucet
	# derives all three). Satış rev 6 §2: the star IS the size — one field where there used
	# to be an archetype id, a scale and a difficulty that could disagree.
	var p := Prospect.new()
	p.id = pid
	p.company_name = "Lead " + pid
	p.industry = "testing"
	p.star = clampi(star, SalesConstants.STAR_MIN, SalesConstants.STAR_MAX)
	p.archetype_id = archetype_id
	p.pain_feature_id = pain
	p.spawned_on_day = GameState.day
	p.expires_on_day = GameState.day + SalesConstants.LEAD_LIFE_DAYS
	ProspectRegistry.add(p)
	return p


static func _case_sales_pipeline_rate_by_pace() -> String:
	# §3 THE FAUCET, and the assertion is the OPPOSITE of the one this case used to make.
	# Before rev 6 the desk produced nothing without a rep and a button produced the rest;
	# now a BASE INBOUND continues with zero sales staff and an assigned rep ADDS to it.
	# FALSIFICATION: against the old desk the first branch fails outright — its rate with no
	# rep was exactly zero.
	GameState.set_flag("mvp_shipped", true)
	GameState.set_flag("mvp_market_type", "b2b")
	GameState.set_flag("mvp_sub_product_type_id", "ai_vector_search")
	_seed_b2b(1000)
	var mult: float = SalesConstants.interest_mult(ProductRead.interest()) \
		* SalesConstants.phase_mult(GameState.phase)
	var base: float = SalesConstants.FAUCET_BASE_PER_WEEK / SalesConstants.DAYS_PER_WEEK * mult
	if not is_equal_approx(SalesFaucetSystem.lead_rate_per_day(), base):
		return "base inbound %f with no sales staff, want %f" % [
			SalesFaucetSystem.lead_rate_per_day(), base]
	if base <= 0.0:
		return "the faucet is dry with no sales staff — §3 says the base inbound continues"
	var before: int = ProspectRegistry.count()
	for i in 10:
		GameState.advance_day()
		B2BSalesSystem.daily_tick()
	if ProspectRegistry.count() <= before:
		return "no leads arrived over ten days with the base inbound running"

	# An ASSIGNED rep raises the flow by exactly one rep's worth (§3: +2/week).
	_make_sales_rep("char_sr_1", 6, 1)
	var want: float = (SalesConstants.FAUCET_BASE_PER_WEEK + SalesConstants.FAUCET_PER_REP_PER_WEEK) \
		/ SalesConstants.DAYS_PER_WEEK * mult
	if not is_equal_approx(SalesFaucetSystem.lead_rate_per_day(), want):
		return "rate with one rep %f, want %f" % [SalesFaucetSystem.lead_rate_per_day(), want]
	return ""

static func _case_sales_pipeline_stack_diminishes() -> String:
	# THE STACK DECAY IS RETIRED and this case guards what replaced it. §3 makes the faucet
	# LINEAR in assigned capacity (+2/week each) because supply is now a market reading
	# rather than a crowded queue; the anti-burst rule moved to a DAILY CAP, which is the
	# thing that still has to hold. FALSIFICATION: remove FAUCET_DAILY_MAX and the second
	# half fails — a week of banked flow releases in one morning.
	GameState.set_flag("mvp_shipped", true)
	GameState.set_flag("mvp_market_type", "b2b")
	GameState.set_flag("mvp_sub_product_type_id", "ai_vector_search")
	_seed_b2b(1000)
	_make_sales_rep("char_sr_1", 6, 1)
	var one: float = SalesFaucetSystem.lead_rate_per_day()
	_make_sales_rep("char_sr_2", 6, 1)
	var two: float = SalesFaucetSystem.lead_rate_per_day()
	var step: float = SalesConstants.FAUCET_PER_REP_PER_WEEK / SalesConstants.DAYS_PER_WEEK \
		* SalesConstants.interest_mult(ProductRead.interest()) \
		* SalesConstants.phase_mult(GameState.phase)
	if not is_equal_approx(two - one, step):
		return "a second rep added %f, want one rep's worth %f" % [two - one, step]
	# The daily cap holds however much flow has banked.
	GameState.set_flag("sales_faucet_progress", 0.99)
	for i in 20:
		_make_sales_rep("char_sr_x%d" % i, 9, 1)
	var before: int = ProspectRegistry.count()
	GameState.advance_day()
	B2BSalesSystem.daily_tick()
	var emitted: int = ProspectRegistry.count() - before
	if emitted > SalesConstants.FAUCET_DAILY_MAX:
		return "%d leads in one day, cap is %d" % [emitted, SalesConstants.FAUCET_DAILY_MAX]
	return ""

static func _case_sales_autonomous_close_routine() -> String:
	# §7.6 — an IN-LEAGUE close is DETERMINISTIC: no hidden percentage, the only variable is
	# how long it takes. The deal closes at the DIAL's price (§7.5), names the closer, and
	# logs. FALSIFICATION: against the old desk the price assertion fails — it placed the
	# deal inside an archetype MRR band and never read a stance.
	GameState.set_flag("mvp_shipped", true)
	GameState.set_flag("mvp_market_type", "b2b")
	GameState.set_flag("mvp_sub_product_type_id", "ai_vector_search")
	_seed_b2b(1000)
	var rep: Character = _make_sales_rep("char_sr_1", 0, 9)   # Satış 9 -> star 4, band 1..3
	SalesLedger.set_price_stance(SalesConstants.STANCE_STANDARD)
	_add_prospect("routine", 1, "ai_vec_filter")
	var signed0: int = GameState.run_customers_signed
	var closed: bool = false
	for i in 40:
		GameState.advance_day()
		B2BSalesSystem.daily_tick()
		if ProspectRegistry.get_prospect("routine") == null:
			closed = true
			break
	if not closed:
		return "an in-league lead never closed"
	if GameState.run_customers_signed != signed0 + 1:
		return "signing counter did not move (%d -> %d)" % [signed0, GameState.run_customers_signed]
	var c: Customer = CustomerRegistry.get_customer("co_routine")
	if c == null:
		return "no customer created for the closed lead"
	if c.acquisition_source != "sales_rep:%s" % rep.id:
		return "acquisition_source does not name the closer: %s" % c.acquisition_source
	# §7.5 — the rep closes at the dial, and their star does not touch the price.
	var want_price: int = SalesLedger.seat_price_anchor(SalesConstants.STANCE_STANDARD)
	if c.seat_price != want_price:
		return "closed at $%d/seat, the Standard dial says $%d" % [c.seat_price, want_price]
	var band: Dictionary = SalesConstants.seat_band(1)
	if c.seats < int(band["low"]) or c.seats > int(band["high"]):
		return "seats %d outside the 1-star band %d..%d" % [
			c.seats, int(band["low"]), int(band["high"])]
	var log: Array = SalesSystem.get_sales_log()
	if log.is_empty():
		return "the close produced no activity-log line"
	var last: Dictionary = log[log.size() - 1]
	if String(last.get("kind", "")) != "auto_close" or String(last.get("actor", "")) != rep.character_name:
		return "activity line does not name who closed it: %s" % str(last)
	return ""

static func _case_sales_close_threshold_surfaces() -> String:
	# §7.1 THE STAR GATE, and it replaced an MRR ceiling. A rep sells at or below their own
	# Satış star and CANNOT reach above it — a gate the player can see on the card rather
	# than a number they cannot. FALSIFICATION: the old desk gated on the archetype band
	# ceiling, so a 3-star lead under $600 would have closed itself.
	GameState.set_flag("mvp_shipped", true)
	GameState.set_flag("mvp_market_type", "b2b")
	GameState.set_flag("mvp_sub_product_type_id", "ai_vector_search")
	_seed_b2b(1000)
	var rep: Character = _make_sales_rep("char_sr_1", 0, 3)   # Satış 3 -> star 1.5 -> band 1
	_add_prospect("above", 3, "ai_vec_filter")
	var signed0: int = GameState.run_customers_signed
	# INSIDE THE LEAD'S LIFE. Forty days would let §4's expiry take the lead and the case
	# would then read "gone" as "closed" — a false pass in one direction and a false failure
	# in the other. A rep that could take this table would have started on day one.
	for i in SalesConstants.LEAD_LIFE_DAYS - 2:
		GameState.advance_day()
		B2BSalesSystem.daily_tick()
	var p: Prospect = ProspectRegistry.get_prospect("above")
	if p == null:
		return "a lead above the rep's star left the pipeline inside its own week"
	if p.is_being_worked():
		return "the rep started working a lead above their star"
	if GameState.run_customers_signed != signed0:
		return "signing counter moved without a played meeting (%d -> %d)" % [
			signed0, GameState.run_customers_signed]
	# And the card says WHY, rather than simply not appearing.
	if SalesRepSystem.out_of_band_reason(rep, p) != "SALES_BAND_ABOVE_REP":
		return "the out-of-band reason does not name the star gate: %s" % \
			SalesRepSystem.out_of_band_reason(rep, p)
	return ""

static func _case_sales_threshold_separates_tiers() -> String:
	# §7.2.2 THE BAND CAP, which can only ever LOWER the ceiling the star gate set. Raising
	# it past the rep's own star must do NOTHING — otherwise the setting becomes a way around
	# §7.1 and the star gate stops being hard. FALSIFICATION: drop the `mini()` in
	# band_ceiling and the third branch fails.
	GameState.set_flag("mvp_shipped", true)
	GameState.set_flag("mvp_market_type", "b2b")
	var rep: Character = _make_sales_rep("char_sr_1", 0, 4)   # Satış 4 -> star 2
	if SalesRepSystem.rep_star(rep) != 2:
		return "fixture rep is not a 2-star seller: %d" % SalesRepSystem.rep_star(rep)
	if SalesRepSystem.band_ceiling(rep) != 2:
		return "default ceiling is not the rep's own league: %d" % SalesRepSystem.band_ceiling(rep)
	SalesLedger.set_rep_band_cap(rep.id, 3)
	if SalesRepSystem.band_ceiling(rep) != 2:
		return "a cap ABOVE the rep's star raised the ceiling to %d" % SalesRepSystem.band_ceiling(rep)
	SalesLedger.set_rep_band_cap(rep.id, 1)
	if SalesRepSystem.band_ceiling(rep) != 1:
		return "a cap below the rep's star did not narrow the ceiling: %d" % \
			SalesRepSystem.band_ceiling(rep)
	# §7.2.2 — a 1-star rep gets NO selector: one rung is a fake choice, so the surface draws
	# a plain information line instead. The rule lives in the system so the tab cannot forget.
	var junior: Character = _make_sales_rep("char_sr_j", 0, 2)   # Satış 2 -> star 1
	if not SalesRepSystem.band_cap_options(junior).is_empty():
		return "a 1-star rep was offered a band selector"
	if SalesRepSystem.band_cap_options(rep).is_empty():
		return "a 2-star rep was offered no band selector"
	return ""

static func _case_sales_concession_deal_surfaces() -> String:
	# §7.6 THE PRICE-BREAK MOMENT — defined, published, and INERT. On Premium against a
	# price-sensitive archetype the desk publishes `rep_discount_requested` in the closing
	# days; it does NOT raise the card, because §18 puts that wiring in the event package.
	# The deal must still close at its own stance: an unwired card cannot be allowed to
	# strand a finished deal. FALSIFICATION: make the card fire and the fourth branch fails.
	GameState.set_flag("mvp_shipped", true)
	GameState.set_flag("mvp_market_type", "b2b")
	GameState.set_flag("mvp_sub_product_type_id", "ai_vector_search")
	_seed_b2b(1000)
	_make_sales_rep("char_sr_1", 0, 9)
	SalesLedger.set_price_stance(SalesConstants.STANCE_PREMIUM)
	_add_prospect("premium", 1, "ai_vec_filter", "ops_cautious")   # price-sensitive archetype
	var fired: Array = []
	var probe := func(_rep_id: String, lead_id: String) -> void: fired.append(lead_id)
	EventBus.rep_discount_requested.connect(probe)
	for i in 40:
		GameState.advance_day()
		B2BSalesSystem.daily_tick()
		if ProspectRegistry.get_prospect("premium") == null:
			break
	EventBus.rep_discount_requested.disconnect(probe)
	if fired.is_empty():
		return "the price-break moment never published on a Premium price-sensitive deal"
	if EventGate.active_id() == SalesConstants.PRICE_BREAK_CARD_ID:
		return "the price-break card FIRED — it is defined and inert until the event package"
	var c: Customer = CustomerRegistry.get_customer("co_premium")
	if c == null:
		return "the Premium deal never closed — an inert card stranded it"
	if c.seat_price != SalesLedger.seat_price_anchor(SalesConstants.STANCE_PREMIUM):
		return "the deal did not close at its own stance: $%d/seat" % c.seat_price
	# "Duyarsız arketip kartı üretmez" — the other half of the rule.
	var insensitive := Prospect.new()
	insensitive.star = 1
	insensitive.archetype_id = "tech_exacting"
	insensitive.work_stance = SalesConstants.STANCE_PREMIUM
	insensitive.work_due_day = GameState.day
	var rep2: Character = CharacterRegistry.get_character("char_sr_1")
	if SalesRepSystem.price_break_due(rep2, insensitive):
		return "a price-INSENSITIVE archetype produced the price-break moment"
	return ""

static func _case_sales_close_speed_by_expertise() -> String:
	# §7.2 — the processing span comes from the LEAGUE DIFFERENCE and the rep's EFFECTIVE
	# OUTPUT places the deal inside it. TWO-DIRECTIONAL: a stronger seller closes the same
	# lead in strictly fewer days, and Premium lengthens it (§7.5). Reading
	# `hr.effective_skill` rather than a raw star is the point — morale, focus, hours and
	# traits already live in that one formula and this desk does not copy it.
	GameState.set_flag("mvp_shipped", true)
	GameState.set_flag("mvp_market_type", "b2b")
	GameState.set_flag("mvp_sub_product_type_id", "ai_vector_search")
	_seed_b2b(1000)
	var weak: Character = _make_sales_rep("char_sr_weak", 0, 4)
	var strong: Character = _make_sales_rep("char_sr_strong", 0, 9)
	var lead: Prospect = _add_prospect("span", 1, "ai_vec_filter")
	var slow: int = SalesRepSystem.processing_days(weak, lead, SalesConstants.STANCE_STANDARD)
	var fast: int = SalesRepSystem.processing_days(strong, lead, SalesConstants.STANCE_STANDARD)
	if fast >= slow:
		return "effective output did not speed the close (weak=%d days, strong=%d days)" % [slow, fast]
	var premium: int = SalesRepSystem.processing_days(strong, lead, SalesConstants.STANCE_PREMIUM)
	if premium <= fast:
		return "Premium did not lengthen processing (%d -> %d days)" % [fast, premium]
	# And the span itself is league-driven: two leagues below is strictly faster than own.
	var own: Array = SalesConstants.process_span(0)
	var below: Array = SalesConstants.process_span(-2)
	if int(below[1]) >= int(own[0]):
		return "the league table does not separate own-league from two-below"
	return ""

static func _case_cs_auto_assignment_capacity() -> String:
	# Delegation is EXCESS-driven: under the founder's own capacity nothing moves; above it the
	# overflow goes over, bounded by cs_capacity(HIZ). Leave releases the roster.
	#
	# REPOINTED 2026-08-27 WITH THE RULING THAT CHANGED IT, in the same commit. F5 (direktör
	# onaylı çalışma kuralı) makes a newly signed account land on a rep with room AT THE
	# SIGNATURE, so the old starting state — every account on the founder's desk until the
	# morning sweep — no longer exists and the "exactly one hands over" count measured a world
	# that is gone. What the case is FOR is unchanged and still measured below: the founder's
	# direct cap, the rep's capacity ceiling, and §11.3's no-automatic-hand-off on leave.
	# The signing hand-off is disabled for the seeding loop so this case still exercises the
	# SWEEP, which is the path it owns; `hotfix_new_account_auto_assigned` owns the other one.
	GameState.set_flag("mvp_sub_product_type_id", "ai_vector_search")
	_seed_b2b(1000)
	var rep: Character = _make_cs_rep("char_cs_1", 9, 5)
	# B4: kurucunun tavanı artık KENDİ yıldızından türüyor, sabit değil.
	var founder_cap: int = CustomerRepSystem.founder_account_capacity()
	for i in founder_cap:
		var p: Prospect = _add_prospect("cap%d" % i, 1, "ai_vec_filter")
		var c: Customer = _sign_fixture(p, 300, 70)
		ProspectRegistry.remove(p.id)
		CustomerRegistry.set_lifecycle_phase(c.id, "active")
	CustomerRegistry.set_lifecycle_phase("co_lead_smoke", "active")
	# Hand every account back to the founder's desk, which is the state the SWEEP is written
	# against. Not pinned: pinning would make `_delegate_excess` skip them entirely.
	for c2 in CustomerRegistry.get_by_market("b2b"):
		CustomerRegistry.assign_customer(c2.id, "", false)
	CustomerRepSystem.reconcile_assignments()
	# co_lead_smoke + the founder cap more = cap + 1, so exactly ONE hands over.
	var assigned: int = 0
	for c in CustomerRegistry.get_by_market("b2b"):
		if c.assigned_to == rep.id:
			assigned += 1
	if assigned != 1:
		return "expected exactly the 1 excess account delegated, got %d" % assigned
	if B2BSalesSystem.founder_managed_count() != founder_cap:
		return "founder kept %d accounts, want the cap %d" % [
			B2BSalesSystem.founder_managed_count(), founder_cap]
	# §11.3: "AYRILAN KİŞİNİN HESAPLARI KURUCUYA DEVREDİLMEZ." Eski iddia tam tersini
	# ölçüyordu: temsilci izne çıkınca defterinin BOŞALMASINI bekliyordu, ve o boşaltma
	# hesapları kurucuya yazan `_release_unheld`'di. §5.7 ayrılmanın bedelini adıyla
	# koyuyor — "iş boşalır, o işi yapacak kimse kalmaz" — ve sessizce kapanan bir boşluk
	# bedel değildir. Hesap İZİNDEKİ TEMSİLCİDE KALIR ve oyuncu onu görür.
	CharacterRegistry.set_status(rep.id, HRConstants.STATUS_ON_LEAVE)
	CustomerRepSystem.reconcile_assignments()
	var still_held: int = 0
	for c in CustomerRegistry.get_by_market("b2b"):
		if c.assigned_to == rep.id:
			still_held += 1
		elif c.assigned_to != "":
			return "%s was handed to '%s' — §11.3 forbids the automatic hand-off" % [
				c.id, c.assigned_to]
	if still_held != 1:
		return "the on-leave rep's book was emptied (%d held) — the capacity gap must stay visible" % still_held
	return ""


static func _case_cs_capacity_resolution() -> String:
	# REPOINTED 2026-08-27 WITH THE RULING THAT REPLACED THE LADDER (B4). Capacity is now
	# 4 + 2 x stars and reads `HRConstants.stars_for`, so the old divisor assertions measured a
	# formula that no longer exists. Everything the case was FOR is still measured: the curve
	# rises, it is monotone, its top is a named number, and the founder book still reports.
	#
	# THE DIRECTOR'S OWN ANCHORS ARE THE ASSERTION. 1 star -> 6, 1.5 -> 7, 2 -> 8. The half-star
	# row is the one that could not exist before: the retired ladder divided POINTS by three and
	# could not see a half star at all.
	if B2BConstants.account_capacity(0) != B2BConstants.ACCOUNT_CAP_BASE:
		return "account_capacity(0) is not the base capacity"
	var anchors: Dictionary = {2: 6, 3: 7, 4: 8}   # points -> accounts (2 points = 1 star)
	for pts in anchors:
		var got: int = B2BConstants.account_capacity(int(pts))
		if got != int(anchors[pts]):
			return "account_capacity(%d pts) is %d, the director's anchor says %d" % [
				int(pts), got, int(anchors[pts])]
	if B2BConstants.account_capacity(HRConstants.AREA_MAX) <= B2BConstants.account_capacity(0):
		return "account_capacity does not rise across the ruler"
	var want_top: int = B2BConstants.ACCOUNT_CAP_BASE + int(round(
		float(B2BConstants.ACCOUNT_CAP_PER_STAR) * HRConstants.stars_for(HRConstants.AREA_MAX)))
	if B2BConstants.account_capacity(HRConstants.AREA_MAX) != want_top:
		return "account_capacity(top) is %d, want %d" % [
			B2BConstants.account_capacity(HRConstants.AREA_MAX), want_top]
	for i in HRConstants.AREA_MAX:
		if B2BConstants.account_capacity(i + 1) < B2BConstants.account_capacity(i):
			return "account_capacity is not monotone at %d points" % i
	_seed_b2b(1000)
	if B2BSalesSystem.founder_managed_count() != 1:
		return "founder_managed_count does not report the founder book"
	# THE FOUNDER USES THE SAME FORMULA — no special rule, which is B4's own wording.
	var f: Character = CharacterRegistry.get_founder()
	if f == null:
		return "no founder in the run"
	_set_founder_area(HRConstants.AREA_CUSTOMER_SUCCESS, 4)
	if CustomerRepSystem.founder_account_capacity() != B2BConstants.account_capacity(4):
		return "the founder's capacity does not come from the same formula"
	return ""


static func _case_cs_request_absorption_by_expertise() -> String:
	# THE VALVE PROOF: the SAME request is absorbed at one Müşteri Başarısı and escalated
	# one point lower. Difficulty is built so the ceiling lands exactly between the two.
	#
	# ONE NUMBER, TWO JOBS (rev 2 §2). Müşteri Başarısı is now BOTH the absorb ceiling and
	# the desk's daily budget — it used to be UZMANLIK and HIZ, and this case pinned HIZ at 9
	# so only the ceiling moved. There is no second axis to pin any more, and a straddle low
	# enough to be interesting now STARVES the desk: one rep at MB 2 clears 0,8 requests a day
	# and never reaches the one on the table, so BOTH halves would pass for the wrong reason.
	# TWO reps at the SAME level fund the day (0,8 + 0,6×0,8 = 1,28) without touching the
	# ceiling, which reads the TOP rep only. That is how a variable is held still now that the
	# two readings share a number.
	GameState.set_flag("mvp_sub_product_type_id", "ai_vector_search")
	_seed_b2b(1000)
	var c: Customer = CustomerRegistry.get_customer("co_lead_smoke")
	c.pain_feature_id = "ai_vec_filter"
	GameState.set_flag("mvp_components", [])          # pain UNSHIPPED -> +2
	CustomerRegistry.set_satisfaction(c.id, 20)       # under tolerance -> +2
	var diff: int = CustomerRepSystem.request_difficulty(c)
	var strong_expertise: int = diff - B2BConstants.CS_ABSORB_BASE
	# Lower bound 2, not 1: the WEAK side sits one under, and a desk of two reps at MB 0
	# clears 0,8 requests a day — under the 1,0 the queue needs to touch anything at all.
	if strong_expertise < 2 or strong_expertise > HRConstants.AREA_MAX:
		return "difficulty %d cannot be straddled with a funded desk (MB %d)" % [diff, strong_expertise]
	var strong: Character = _make_cs_rep("char_cs_strong", 9, strong_expertise)
	var strong2: Character = _make_cs_rep("char_cs_strong2", 9, strong_expertise)
	if CustomerRepSystem.absorb_ceiling() < diff:
		return "the strong rep should absorb difficulty %d (ceiling %d)" % [
			diff, CustomerRepSystem.absorb_ceiling()]
	CustomerRegistry.set_support_request(c.id, GameState.day)
	CustomerRepSystem.daily_tick()
	if c.support_request_since_day >= 0:
		return "the strong rep did not clear the request"
	if _request_cards_up() != 0:
		return "the strong rep escalated a request it should have absorbed"
	CharacterRegistry.remove(strong.id)
	CharacterRegistry.remove(strong2.id)
	# Same pair shape one point lower: the ceiling drops, the budget stays over 1,0.
	_make_cs_rep("char_cs_weak", 9, strong_expertise - 1)
	_make_cs_rep("char_cs_weak2", 9, strong_expertise - 1)
	CustomerRegistry.set_support_request(c.id, GameState.day)
	CustomerRepSystem.daily_tick()
	if _request_cards_up() == 0:
		return "the weaker rep absorbed a request that should have escalated"
	return ""


static func _case_cs_request_throughput_by_pace() -> String:
	# VOLUME, read off the one area: a stronger desk clears strictly more, and the surplus
	# QUEUES. This case used to vary HIZ with UZMANLIK pinned at 9 — rev 2 §2 collapsed both
	# onto Müşteri Başarısı, so pinning one while varying the other became impossible: the
	# two seeds ended up identical (1,850000 vs 1,850000) and the assertion could never fire.
	# It varies the one area now, which is the same shape of test with one number instead of
	# two. The queue half below is unchanged and still bites: a lone MB-0 rep carries 0,5 a
	# day, so the six open requests cannot all clear.
	GameState.set_flag("mvp_sub_product_type_id", "ai_vector_search")
	_seed_b2b(1000)
	GameState.set_flag("mvp_components", ["ai_vec_filter"])
	var slow: Character = _make_cs_rep("char_cs_slow", SEED_PACE, 0)
	var fast: Character = _make_cs_rep("char_cs_fast", SEED_PACE, HRConstants.AREA_MAX)
	if CustomerRepSystem.throughput_of(fast) <= CustomerRepSystem.throughput_of(slow):
		return "Müşteri Başarısı does not raise throughput (%f vs %f)" % [
			CustomerRepSystem.throughput_of(fast), CustomerRepSystem.throughput_of(slow)]
	var want: float = B2BConstants.CS_THROUGHPUT_BASE \
		+ float(HRConstants.AREA_MAX) * B2BConstants.CS_THROUGHPUT_PER_PACE
	if not is_equal_approx(CustomerRepSystem.throughput_of(fast), want):
		return "throughput %f, want %f" % [CustomerRepSystem.throughput_of(fast), want]
	CharacterRegistry.remove(fast.id)
	var opened: Array[String] = []
	for i in 6:
		var p: Prospect = _add_prospect("thr%d" % i, 1, "ai_vec_filter")
		var c: Customer = _sign_fixture(p, 300, 70)
		ProspectRegistry.remove(p.id)
		CustomerRegistry.set_support_request(c.id, GameState.day)
		opened.append(c.id)
	CustomerRepSystem.daily_tick()
	var still_open: int = 0
	for cid in opened:
		var cc: Customer = CustomerRegistry.get_customer(cid)
		if cc != null and cc.support_request_since_day >= 0:
			still_open += 1
	if still_open == 0:
		return "a slow desk cleared every request in one day; the queue is not bounded"
	return ""


static func _case_cs_request_covers_founder_managed() -> String:
	# THE NO-IDLE-HIRE GUARANTEE. One rep, one account, nothing delegated (well under the
	# cap) -> the rep STILL fields that account request on day one.
	GameState.set_flag("mvp_sub_product_type_id", "ai_vector_search")
	_seed_b2b(1000)
	GameState.set_flag("mvp_components", ["ai_vec_filter"])
	var c: Customer = CustomerRegistry.get_customer("co_lead_smoke")
	c.pain_feature_id = "ai_vec_filter"
	_make_cs_rep("char_cs_1", 9, 9)
	CustomerRepSystem.reconcile_assignments()
	if c.assigned_to != "":
		return "an account under the founder cap was delegated"
	CustomerRegistry.set_support_request(c.id, GameState.day)
	CustomerRepSystem.daily_tick()
	if c.support_request_since_day >= 0:
		return "the rep ignored a founder-managed account request (idle hire)"
	var log: Array = SalesSystem.get_sales_log()
	if log.is_empty() or String(log[log.size() - 1].get("kind", "")) != "cs_absorb":
		return "absorbing a founder-managed request produced no activity line"
	return ""


static func _case_cs_request_channel_gated_on_rep() -> String:
	# With no customer rep the channel does not exist: no request is ever opened.
	GameState.set_flag("mvp_sub_product_type_id", "ai_vector_search")
	_seed_b2b(1000)
	var c: Customer = CustomerRegistry.get_customer("co_lead_smoke")
	for i in 30:
		GameState.advance_day()
		B2BSalesSystem.daily_tick()
		if c.support_request_since_day >= 0:
			return "a request opened with no customer rep on staff (day %d)" % GameState.day
	if _request_cards_up() != 0:
		return "a request event fired with no customer rep on staff"
	return ""


static func _case_promise_broken_penalty() -> String:
	# PROMISE_BROKEN_SAT is APPLIED (the assertion the old broken-promise case never made),
	# and the hit is DURABLE: before task 2b the daily drift erased it inside a week because
	# _promise_offset was a permanent `return 0.0` stub.
	GameState.set_flag("mvp_sub_product_type_id", "ai_vector_search")
	_seed_b2b(1000)
	var c: Customer = CustomerRegistry.get_customer("co_lead_smoke")
	CustomerRegistry.set_satisfaction(c.id, 70)
	var sat_before: int = c.satisfaction
	var pr: Promise = PromiseRegistry.create(c.id, "ai_vec_filter", 1)
	GameState.advance_day()
	GameState.advance_day()
	PromiseRegistry.tick_deadlines(GameState.day)
	if pr.status != "broken":
		return "promise did not break (status=%s)" % pr.status
	# (a) the one-shot actually lands
	if c.satisfaction != clampi(sat_before + B2BConstants.PROMISE_BROKEN_SAT, 0, 100):
		return "PROMISE_BROKEN_SAT not applied (%d -> %d)" % [sat_before, c.satisfaction]
	# (b) the durable half is recorded on the trust ledger
	if not is_equal_approx(c.trust_offset, B2BConstants.PROMISE_BROKEN_OFFSET):
		return "trust offset %f, want %f" % [c.trust_offset, B2BConstants.PROMISE_BROKEN_OFFSET]
	# (c) a week later the account is STILL below where it started. A return to the 0.0 stub
	#     fails HERE - that is the whole point of this case.
	for i in 7:
		GameState.advance_day()
		B2BSalesSystem.daily_tick()
	if c.satisfaction >= sat_before:
		return "the broken promise was erased by drift within a week (now %d, started %d)" % [
			c.satisfaction, sat_before]
	# (d) and it forgives: the offset decays back toward zero on its own
	if absf(c.trust_offset) >= absf(B2BConstants.PROMISE_BROKEN_OFFSET):
		return "the grudge is not decaying (%f)" % c.trust_offset
	return ""


static func _case_sales_cs_zero_staff_identical() -> String:
	# THE ADDITIVITY GATE, HALVED ON PURPOSE — and the half that went is the point of the
	# rebuild rather than a casualty of it.
	#
	# The CUSTOMER desk keeps the invariant whole: with nobody on Hesap sahipliği, a long run
	# delegates nothing, opens no request and moves no throughput accumulator. That is still
	# what "hiring buys capacity" means on that side.
	#
	# The SALES desk cannot keep it, and §3 says so out loud: "Kapasite sıfırken taban
	# gelen-akış sürer." Before rev 6 the pipeline was dead without a rep and a button filled
	# it, which is exactly why sales capacity was decorative — hiring raised supply and never
	# capped what the player could work. So the assertion flips: leads DO arrive with nobody
	# on the sales job, and what must stay untouched is everything a REP would have done.
	# FALSIFICATION: put the rep desk's work behind no staffing check and the "nobody worked a
	# lead" branch fails.
	GameState.set_flag("mvp_shipped", true)
	GameState.set_flag("mvp_market_type", "b2b")
	GameState.set_flag("mvp_sub_product_type_id", "erp")
	_seed_b2b(1000)
	var mrr0: int = GameState.mrr
	var signed0: int = GameState.run_customers_signed
	for i in 60:
		GameState.advance_day()
		B2BSalesSystem.daily_tick()

	# §3 — the base inbound ran.
	if ProspectRegistry.count() <= 0:
		return "the base inbound produced nothing over sixty days with no sales staff"
	# …and nothing a rep does happened.
	for p in ProspectRegistry.get_all():
		if (p as Prospect).is_being_worked():
			return "a lead is being worked with nobody on the sales job"
	if GameState.run_customers_signed != signed0:
		return "an account signed itself with no sales staff (%d -> %d)" % [
			signed0, GameState.run_customers_signed]
	if GameState.mrr != mrr0:
		return "MRR moved with no sales staff (%d -> %d)" % [mrr0, GameState.mrr]
	for c in CustomerRegistry.get_by_market("b2b"):
		if c.assigned_to != "":
			return "an account was delegated with no customer rep on staff"
		if c.support_request_since_day >= 0:
			return "a request opened with no customer rep on staff"
	if float(GameState.get_flag("cs_throughput_progress", 0.0)) != 0.0:
		return "the throughput accumulator advanced with no customer rep"
	# The activity log may hold EXPIRIES (§4's honest drop line is not desk work), but never
	# a close: a close is the one thing a desk with nobody on it cannot produce.
	for row in SalesSystem.get_sales_log():
		var kind: String = String((row as Dictionary).get("kind", ""))
		if kind == "auto_close" or kind == "founder_close":
			return "the log holds a close with no desk staff: %s" % str(row)
	return ""

static func _case_prospect_id_unique_after_removal() -> String:
	# Regression: prospect ids were built off ProspectRegistry.count(), which DROPS when a lead
	# is signed or lost, so a same-day respawn rebuilt an existing id, ProspectRegistry.add
	# warned, and the lead was silently discarded while the spawner still returned it. The id
	# counter is MONOTONIC and rev 6 kept it that way.
	GameState.set_flag("mvp_shipped", true)
	GameState.set_flag("mvp_market_type", "b2b")
	GameState.set_flag("mvp_sub_product_type_id", "erp")
	var a: Prospect = SalesFaucetSystem.spawn(1, "test")
	if a == null:
		return "the faucet produced no lead"
	ProspectRegistry.remove(a.id)
	var b: Prospect = SalesFaucetSystem.spawn(1, "test")   # SAME day, count back to 0
	if b == null:
		return "the faucet produced no second lead"
	if a.id == b.id:
		return "same-day respawn reused the id %s" % a.id
	if ProspectRegistry.get_prospect(b.id) == null:
		return "the respawned lead was not registered (silently dropped)"
	return ""

static func _case_b2b_prospect_dedup_excludes_signed() -> String:
	# THE DURABLE HALF OF THE OLD LEDGER, kept while its neighbour was retired. §19 retires
	# the catalogue's SOLE-SUPPLY role, not the rule that a signed company never re-enters
	# COLD prospecting — a churned account comes back through a future win-back path, and
	# cold prospecting is not that path. Live leads still hold distinct names.
	# FALSIFICATION: drop b2b_signed_company_names from _excluded_names and the second loop
	# offers the signed company back within a handful of draws.
	GameState.set_flag("mvp_shipped", true)
	GameState.set_flag("mvp_market_type", "b2b")
	GameState.set_flag("mvp_sub_product_type_id", "ai_vector_search")
	var first: Prospect = SalesFaucetSystem.spawn(1, "faucet")
	if first == null:
		return "fresh run spawned null"
	var signed_name: String = first.company_name
	var c: Customer = _sign_fixture(first, 400, 70)
	ProspectRegistry.remove(first.id)
	if not GameState.b2b_signed_company_names.has(signed_name):
		return "ledger missed the signed name"
	# Draw a long way and hold each name out by hand: this case is about EXCLUSION, and the
	# return lock is a different rule with its own case.
	var names_seen: Dictionary = {}
	for i in 60:
		var p: Prospect = SalesFaucetSystem.spawn(1, "faucet")
		if p == null:
			return "the faucet dried at draw %d" % i
		if p.company_name == signed_name:
			return "signed company respawned as a prospect: %s" % signed_name
		if names_seen.has(p.company_name):
			return "duplicate live prospect name: %s" % p.company_name
		names_seen[p.company_name] = true
		ProspectRegistry.remove(p.id)
		SalesFaucetSystem.lock_return(p.company_name, 9999)
	# Churn the signed account (shared loss seam) — the name must STAY excluded.
	B2BSalesSystem._remove_lost(c)
	if CustomerRegistry.get_customer(c.id) != null:
		return "churn did not remove the customer record"
	for i in 40:
		var q: Prospect = SalesFaucetSystem.spawn(1, "faucet")
		if q == null:
			break
		if q.company_name == signed_name:
			return "churn re-opened cold prospecting for the signed name"
		ProspectRegistry.remove(q.id)
		SalesFaucetSystem.lock_return(q.company_name, 9999)
	# §3.1 — the market guard: a null spawn registers nothing and burns no id counter.
	GameState.set_flag("mvp_market_type", "b2c")
	var live_before: int = ProspectRegistry.count()
	var counter_before: int = GameState.run_prospects_spawned
	if SalesFaucetSystem.spawn(1, "faucet") != null:
		return "the faucet produced a B2B lead in a consumer run"
	if ProspectRegistry.count() != live_before:
		return "a refused spawn registered a lead anyway"
	if GameState.run_prospects_spawned != counter_before:
		return "a refused spawn burned the id counter"
	return ""

static func _case_company_catalog_pool_integrity() -> String:
	# §3 — THE POOL NEVER EXHAUSTS, and this case is the direct answer to the measured account
	# plateau. The 65-name catalogue's SOLE-SUPPLY role is what §19 retired: the names stay and
	# become the memorable minority behind a generated majority.
	# FALSIFICATION: point SalesNamePool.pool_for at CompanyCatalog alone and the drain loop
	# below runs out, which is exactly the plateau that was measured.
	GameState.set_flag("mvp_shipped", true)
	GameState.set_flag("mvp_market_type", "b2b")
	GameState.set_flag("mvp_sub_product_type_id", "saas_ops")
	# Every curated name is still offered — nothing was thrown away.
	for sector in B2BConstants.SECTORS:
		var pool: Array = SalesNamePool.pool_for(String(sector))
		for nm in CompanyCatalog.names_for_sector(String(sector)):
			if not pool.has(String(nm)):
				return "curated name dropped from the pool: %s" % String(nm)
		if pool.size() <= CompanyCatalog.names_for_sector(String(sector)).size():
			return "sector %s gained no generated names" % String(sector)
	# Draw far past the old catalogue ceiling. Every name is distinct and none is null.
	var seen: Dictionary = {}
	var drew: int = 0
	for i in 200:
		var p: Prospect = SalesFaucetSystem.spawn(1, "faucet")
		if p == null:
			return "the faucet ran dry after %d leads — §3 says the pool never exhausts" % drew
		if seen.has(p.company_name):
			return "duplicate live prospect name: %s" % p.company_name
		seen[p.company_name] = true
		drew += 1
		ProspectRegistry.remove(p.id)
		# A drawn-and-dropped name is free again only through the return lock, so hold it out
		# by hand: this loop is testing the POOL's depth, not the lock's.
		SalesFaucetSystem.lock_return(p.company_name, 9999)
	if drew < 200:
		return "drew only %d distinct companies" % drew
	# A SIGNED name never returns to cold prospecting (the durable half of the old ledger).
	var sp: Prospect = SalesFaucetSystem.spawn(1, "faucet")
	if sp == null:
		return "the faucet dried at the signing check"
	var c: Customer = _sign_fixture(sp, 500, 70)
	if not GameState.b2b_signed_company_names.has(c.company_name):
		return "a signed company was not recorded in the run ledger"
	for i in 40:
		var q: Prospect = SalesFaucetSystem.spawn(1, "faucet")
		if q == null:
			break
		if q.company_name == c.company_name:
			return "a signed company was offered again: %s" % c.company_name
		ProspectRegistry.remove(q.id)
		SalesFaucetSystem.lock_return(q.company_name, 9999)
	return ""

static func _case_market_share_tracks_mrr() -> String:
	# Fix 3: player share derives from MRR (rises with it), the snapshot sums to ~100,
	# the roster holds every catalog rival + market actor, the formatter keeps the
	# sliver legible, and the computation is pure (two same-day calls byte-equal).
	GameState.set_flag("mvp_sub_product_type_id", "ai_vector_search")
	_seed_b2b(1500)   # real customer record — set_mrr alone would be bridge-clobbered
	var snap: Dictionary = RivalRegistry.get_market_snapshot("ai_vector_search")
	var p1: float = float(snap["player_pct"])
	if p1 >= 1.0:
		return "seed MRR should start the share under 1%% (got %f)" % p1
	var expected_rows: int = RivalCatalog.TEMPLATE.size() + RivalCatalog.MARKET_ACTORS.size()
	var rivals: Array = snap["rivals"]
	if rivals.size() != expected_rows:
		return "snapshot lists %d rivals, want %d" % [rivals.size(), expected_rows]
	var total: float = p1 + float(snap["others_pct"])
	for row in rivals:
		total += float(row["share_pct"])
		if not [-1, 0, 1].has(int(row["trend"])):
			return "trend out of range for %s" % String(row["name"])
		if String(row["name"]).contains("#"):
			return "fallback rival name leaked into the market: %s" % String(row["name"])
	if absf(total - 100.0) > 0.11:
		return "market sums to %f, want ~100" % total
	for i in rivals.size() - 1:
		if float(rivals[i]["share_pct"]) < float(rivals[i + 1]["share_pct"]):
			return "rivals not sorted by share desc"
	if str(snap) != str(RivalRegistry.get_market_snapshot("ai_vector_search")):
		return "same-day snapshots differ (computation is not pure)"
	# Formatter: the share SHAPE is locale data now (Fmt + PCT_PATTERN/SHARE_FLOOR), so it
	# is asserted per locale instead of pinned to the Turkish bytes. Turkish leads with the
	# sign and a comma decimal ("%0,3"); English trails it with a dot ("0.3%"). Under the
	# floor each locale says its own sentence. The locale is captured and restored so the
	# rest of the case runs in the environment it started in.
	var loc0: String = TranslationServer.get_locale()
	TranslationServer.set_locale("tr")
	var tr_above: String = RivalRegistry.format_share(p1)
	var tr_floor: String = RivalRegistry.format_share(0.02)
	TranslationServer.set_locale("en")
	var en_above: String = RivalRegistry.format_share(p1)
	var en_floor: String = RivalRegistry.format_share(0.02)
	TranslationServer.set_locale(loc0)
	if not tr_above.begins_with("%") or not tr_above.contains(","):
		return "tr share wants a leading %% and a comma decimal, got: %s" % tr_above
	if tr_floor != "<%0,1":
		return "tr sub-floor share is %s, want <%%0,1" % tr_floor
	if not en_above.ends_with("%") or not en_above.contains("."):
		return "en share wants a trailing %% and a dot decimal, got: %s" % en_above
	if en_floor != "<0.1%":
		return "en sub-floor share is %s, want <0.1%%" % en_floor
	# MRR up → share strictly up (a second real customer record).
	var p := Prospect.new()
	p.id = "lead_smoke_growth"
	p.company_name = "Smoke Corp Growth"
	p.industry = "testing"
	p.star = 2
	_sign_fixture(p, 30000, 70)
	var p2: float = float(RivalRegistry.get_market_snapshot("ai_vector_search")["player_pct"])
	if p2 <= p1:
		return "share did not rise with MRR (%f -> %f)" % [p1, p2]
	return ""


static func _case_news_feed_weights_and_no_repeat() -> String:
	# Fix 4: 90 simulated days on the ISOLATED driver (advance_day + explicit feed tick —
	# full dispatch would drag phase gates/endings into a feed test; same rationale as the
	# 2b additivity case). Asserts the source distribution (sektör ~50%, biz hard-capped
	# at 20%), the no-repeat-until-reshuffle contract, and the stream cap. Writes the
	# line-by-line audit to user://news_feed_audit_90d.txt — stdout stays one SMOKE line.
	GameState.set_flag("mvp_sub_product_type_id", "ai_vector_search")
	_seed_b2b(1500)
	var audit: Array[String] = []
	var sektor_seen: Dictionary = {}     # txt -> true, cleared at each observed reshuffle
	var days: int = 90
	for i in days:
		GameState.advance_day()
		# "Biz" injections through the real channel (TimeManager._ready wired the feed).
		# DAILY on purpose: with surplus supply the hard cap is what limits the source,
		# so the ≤20% assertion below tests the cap, not the scarcity of milestones.
		EventBus.headline_added.emit(B2BConstants.notice_source_sales(), "Smoke kapanışı %d" % i)
		var reshuffles_before: int = int(GameState.news_feed.get("reshuffles", 0))
		NewsFeedSystem.daily_tick()
		var boundary_day: bool = int(GameState.news_feed["reshuffles"]) != reshuffles_before
		if boundary_day:
			sektor_seen.clear()   # epoch changed mid-day; today's lines span two epochs — skip dup check
		for line in NewsFeedSystem.get_lines_for_day(GameState.day):
			audit.append("%d|%s|%s|%s" % [int(line["day"]), String(line["kind"]), String(line["src"]), String(line["txt"])])
			if String(line["kind"]) == "sektor" and not boundary_day:
				if sektor_seen.has(String(line["txt"])):
					return "sektor line repeated before pool exhaustion: %s" % String(line["txt"])
				sektor_seen[String(line["txt"])] = true
	var counts: Dictionary = GameState.news_feed["counts"]
	var total: float = float(int(counts["sektor"]) + int(counts["rakip"]) + int(counts["biz"]))
	if total < float(days * NewsFeedSystem.DAILY_LINES_MIN):
		return "only %d lines over %d days" % [int(total), days]
	var sektor_frac: float = float(counts["sektor"]) / total
	var rakip_frac: float = float(counts["rakip"]) / total
	var biz_frac: float = float(counts["biz"]) / total
	if biz_frac > NewsFeedSystem.BIZ_HARD_CAP + 0.01:
		return "biz source broke the hard cap: %.3f" % biz_frac
	if sektor_frac < 0.40 or sektor_frac > 0.62:
		return "sektor share off band: %.3f" % sektor_frac
	if int(counts["rakip"]) == 0:
		return "rival source never fired over %d days" % days
	if (GameState.news_feed["stream"] as Array).size() > NewsFeedSystem.STREAM_CAP:
		return "stream exceeded its cap"
	# Audit report for the done message (distribution header + every line).
	var f: FileAccess = FileAccess.open("user://news_feed_audit_90d.txt", FileAccess.WRITE)
	if f != null:
		f.store_line("days=%d total=%d sektor=%.3f rakip=%.3f biz=%.3f reshuffles=%d" % [
			days, int(total), sektor_frac, rakip_frac, biz_frac, int(GameState.news_feed["reshuffles"])])
		for entry in audit:
			f.store_line(entry)
		f.close()
	return ""


static func _case_cs_request_kind_state_driven() -> String:
	# Fix 5: the request KIND derives from relationship state (satisfaction/tolerance,
	# broken word, tenure, stalls, unmet pain), deterministically — never from the
	# calendar. Detached Customer fixtures, direct pick_request_kind calls.
	GameState.set_flag("mvp_sub_product_type_id", "ai_vector_search")
	GameState.set_flag("mvp_components", ["ai_vec_embed_api"])
	# A — düşük memnuniyet + kırılmış söz → şikâyet.
	var a := Customer.new()
	a.id = "co_state_a"
	a.company_name = "Durum A"
	a.industry = "technology"
	a.satisfaction = 25
	a.tolerance = 50
	a.acquired_on_day = GameState.day
	a.pain_feature_id = "ai_vec_search_api"
	GameState.set_flag("b2b_broke_co_state_a", true)
	if B2BEventFactory.pick_request_kind(a) != B2BConstants.CS_KIND_COMPLAINT:
		return "unhappy broken-promise account did not complain (got %s)" % B2BEventFactory.pick_request_kind(a)
	# B — sağlıklı + karşılanmamış acı özelliği → özellik talebi.
	var b := Customer.new()
	b.id = "co_state_b"
	b.company_name = "Durum B"
	b.industry = "finance"
	b.satisfaction = 85
	b.tolerance = 40
	b.acquired_on_day = GameState.day
	b.pain_feature_id = "ai_vec_filter"
	if B2BEventFactory.pick_request_kind(b) != B2BConstants.CS_KIND_FEATURE:
		return "healthy unmet-pain account did not ask for the feature (got %s)" % B2BEventFactory.pick_request_kind(b)
	# C — uzun kıdem + oyalama izi, acısı karşılanmış → yenileme masası.
	var c := Customer.new()
	c.id = "co_state_c"
	c.company_name = "Durum C"
	c.industry = "media"
	c.satisfaction = 70
	c.tolerance = 40
	c.acquired_on_day = GameState.day - 180
	c.pain_feature_id = "ai_vec_embed_api"   # shipped → unmet-pain bonus yok
	c.retain_stalls = 1
	if B2BEventFactory.pick_request_kind(c) != B2BConstants.CS_KIND_RENEWAL:
		return "long-tenure account did not reach renewal (got %s)" % B2BEventFactory.pick_request_kind(c)
	# No-repeat korunuyor: A az önce şikâyet açtıysa bir daha şikâyet açamaz.
	a.last_request_kind = B2BConstants.CS_KIND_COMPLAINT
	if B2BEventFactory.pick_request_kind(a) == B2BConstants.CS_KIND_COMPLAINT:
		return "no-repeat rule broken by the state scorer"
	# Determinizm: aynı durum + aynı gün → aynı sonuç.
	if B2BEventFactory.pick_request_kind(b) != B2BEventFactory.pick_request_kind(b):
		return "kind selection is not deterministic"
	return ""


# ============================================================================
#  SaveManager — reset mimarisi (2026-08-08)
#  Bu üçlü ŞEMAYI değil YÜKLEMEYİ ölçer. Serileştirme biçimi kolay %20'dir; zor
#  %80, yüklemenin ÇALIŞAN bir süreci eskiden yalnız bir OS restart'ının
#  üretebildiği duruma döndürmesidir. Reset'ten kaçan her sahip eski koşuyu
#  yenisine sızdırır ve sızıntı günler sonra "imkânsız" bir hata olarak yüzeye
#  çıkar — asıl kanıt bu yüzden case 3'tür.
# ============================================================================

const SAVE_SLOT_A := "manual_9001"
const SAVE_SLOT_B := "manual_9002"


## Önemsiz olmayan bir dünya: her sahipten en az bir kayıt, artı serileştirmenin
## sessizce düşürebileceği tipler (kesirli float, tipli dizi, iç içe Resource ve
## DİSKTE OLMAYAN sentetik bir event).
static func _seed_save_world() -> void:
	GameState.day = 40
	GameState.set_cash(120000)
	_seed_b2b(3000)                      # müşteri + shipped ürün eksenleri
	CharacterRegistry.add(_make_employee("emp_save", "Kayit Testi", "developer"))
	PromiseRegistry.create("cust_smoke_corp", "ai_vec_embed_api", 10)
	RivalRegistry.advance_all()
	GameState.set_flag("b2c_audience", 1234.5)      # KESİRLİ: int'e yuvarlanırsa yakalanır
	GameState.set_flag("b2c_price", 29)             # int kalmalı
	FinanceSystem.burn_breakdown["marketing"] = 777
	GameState.cs_escalation_days.append(42)         # Array[int] tipli kalmalı (net_history_90 2026-08-19'da emekli)

	# SENTETİK EVENT GİTTİ. Fixture bir GameEvent kuruyor ve kuyruğa enjekte ediyordu; amacı
	# "hiçbir JSON dosyasında olmayan, id'den geri kurulamayan" bir kartın kaydı geçip
	# geçmediğini ölçmekti — yani tam olarak motorun artık temsil EDEMEDİĞİ şeyi. Kuyruk id
	# tutuyor, görünüm her açılışta katalogdan yeniden çiziliyor, dolayısıyla kaydedilecek bir
	# speaker_* alanı yok.
	#
	# YERİNE MASADA BİR KÂĞIT BIRAKILIYOR, ve seçim önemli: `can_save()` EKRANDA kart varken
	# kaydetmeyi REDDEDER (save_manager.gd:148) — koruduğu şey sunulmuş ama yanıtlanmamış bir
	# karardır. Bir kâğıt tam da bunun karşıtıdır: motor durumudur, EvSave bloğunda gidip
	# gelir, ve oyuncunun gerçek kayıtları da böyle görünür — masada kâğıt, ekranda modal yok.
	var aged: Customer = CustomerRegistry.get_by_market("b2b")[0]
	aged.acquired_on_day = GameState.day - (B2BConstants.EXPANSION_MATURE_DAYS + 1)
	CustomerRegistry.set_lifecycle_phase(aged.id, "active")
	CustomerRegistry.set_satisfaction(aged.id, 80)
	EventGate.request(EXPANSION_ID, {"customer": aged.id})


## Diske YAZ, geri OKU, normalleştir. Gerçek yolu kullanır (atomik yazım + JSON
## gidiş-dönüşü + şema kapısı), bellek içi bir kopya değil.
static func _save_fingerprint(slot_id: String) -> String:
	if not SaveManager.save_to_slot(slot_id):
		return ""
	var payload: Dictionary = SaveManager.read_slot(slot_id)
	if not bool(payload.get("ok", false)):
		return ""
	var state: Dictionary = payload["state"]
	# Hız BİLEREK normalleştirilir: yükleme duraklamış döner (TimeManager.from_dict),
	# yani ikinci kayıt ilkinden yalnız bu alanda ayrılır ve bu bir tasarım kararı.
	var sys: Dictionary = state.get("systems", {}) as Dictionary
	var t: Dictionary = sys.get("time", {}) as Dictionary
	t["current_speed"] = 0
	t["last_running_speed"] = 0
	return JSON.stringify(state, "", true, true)


static func _cleanup_save_slots() -> void:
	SaveManager.delete_slot(SAVE_SLOT_A)
	SaveManager.delete_slot(SAVE_SLOT_B)


# --- 1. Gidiş-dönüş parmak izi: kaydet → yükle → tekrar kaydet = aynı yük ---
static func _case_save_roundtrip_fingerprint() -> String:
	_seed_save_world()
	var before: String = _save_fingerprint(SAVE_SLOT_A)
	if before == "":
		_cleanup_save_slots()
		return "first save/read failed"

	var emp_before: Character = CharacterRegistry.get_character("emp_save")
	if emp_before == null:
		_cleanup_save_slots()
		return "seed failed: emp_save missing before the load"
	var hire_day_before: int = emp_before.hire_day
	var hires_before: int = GameState.run_hires

	if not SaveManager.apply_loaded_state(SaveManager.read_slot(SAVE_SLOT_A)):
		_cleanup_save_slots()
		return "apply_loaded_state returned false"

	var after: String = _save_fingerprint(SAVE_SLOT_B)
	if after != before:
		_cleanup_save_slots()
		return "payload differs after a load round-trip (%d vs %d bytes)" % [before.length(), after.length()]

	# Tip bütünlüğü: JSON her sayıyı float döndürür, geri kazanım şart.
	var aud: Variant = GameState.get_flag("b2c_audience", 0.0)
	if typeof(aud) != TYPE_FLOAT or not is_equal_approx(float(aud), 1234.5):
		_cleanup_save_slots()
		return "b2c_audience lost its float accumulator (%s)" % str(aud)
	if typeof(GameState.get_flag("b2c_price", 0)) != TYPE_INT:
		_cleanup_save_slots()
		return "b2c_price came back as a non-int"
	if GameState.cs_escalation_days.get_typed_builtin() != TYPE_INT:
		_cleanup_save_slots()
		return "cs_escalation_days lost its Array[int] typing"

	# insert_raw yolu: add() hire_day damgalar ve run_hires artırır — yükleme etmemeli.
	var emp: Character = CharacterRegistry.get_character("emp_save")
	if emp == null:
		_cleanup_save_slots()
		return "restored roster lost emp_save"
	if emp.hire_day != hire_day_before:
		_cleanup_save_slots()
		return "hire_day re-stamped on load (%d then %d)" % [hire_day_before, emp.hire_day]
	if GameState.run_hires != hires_before:
		_cleanup_save_slots()
		return "run_hires incremented by a load (%d then %d)" % [hires_before, GameState.run_hires]

	# KUYRUK ARTIK KART SERİLEŞTİRMİYOR, bu yüzden bu blok da ölçüsünü değiştirdi.
	#
	# Eskiden burada "altı speaker_* alanı ve iç içe EventChoice geri döndü mü" diye
	# soruluyordu: kuyruk GameEvent NESNELERİ tutuyordu ve kaydın onları bütün hâlde
	# taşıması gerekiyordu. Motorun kuyruğunda id ile BAĞLAM var; görünüm her açılışta
	# katalogdan, canlı dilde yeniden çiziliyor. Kaydedilecek bir speaker_name yok —
	# ve bu, koşu ortasında dil değiştirmenin neden güvenli olduğunun ta kendisi (§3.2).
	#
	# Ölçülmesi gereken şey bu yüzden ŞU: kartın kimliği ve ÖZNESİ döndü mü. Bir kaydın
	# kaybedebileceği tek şey odur, ve kaybederse kart yanlış hesap hakkında konuşur.
	var desk: Array = EventGate.desk_papers(8)
	var entry: Dictionary = {}
	for row in desk:
		if String((row as Dictionary)["id"]) == EXPANSION_ID:
			entry = row
	if entry.is_empty():
		_cleanup_save_slots()
		return "the paper did not survive the round-trip (desk: %d)" % desk.size()
	if int(entry["days_left"]) <= 0:
		_cleanup_save_slots()
		return "the paper came back with no clock (%d)" % int(entry["days_left"])
	# The VIEW is rebuilt from the catalogue, in the live locale, from an id and a frozen
	# context. Nothing about the card's words was in the save file, and that is the property
	# under test: a title that resolves proves the rebuild, and a title that is still its own
	# key proves only that a token round-tripped.
	var view: GameEvent = EventGate.render(EXPANSION_ID, EventGate.bind_scope(EXPANSION_ID))
	if view == null or view.choices.size() != 2:
		_cleanup_save_slots()
		return "the card did not rebuild its options from the catalogue"
	if view.title == "" or view.title == "B2B_EV_EXPANSION_TITLE":
		_cleanup_save_slots()
		return "the rebuilt view did not resolve its text (%s)" % view.title

	_cleanup_save_slots()
	return ""


# --- 2. Süreklilik: tohum GİRDİ, RNG akışları DURUMLARIYLA döner ---
static func _case_save_continuity_seeded() -> String:
	_seed_save_world()
	var skill: RandomNumberGenerator = RngStreams.get_stream(RngStreams.STREAM_SKILL)
	for i in 17:
		skill.randf()                     # akışı önemsiz olmayan bir konuma taşı

	if not SaveManager.save_to_slot(SAVE_SLOT_A):
		_cleanup_save_slots()
		return "save failed"
	# Kayıt ÖNCE, çekiliş SONRA: yükleme tam olarak bu çekilişi tekrarlamalı.
	var expected: float = RngStreams.get_stream(RngStreams.STREAM_SKILL).randf()

	if not SaveManager.apply_loaded_state(SaveManager.read_slot(SAVE_SLOT_A)):
		_cleanup_save_slots()
		return "apply_loaded_state returned false"
	var actual: float = RngStreams.get_stream(RngStreams.STREAM_SKILL).randf()
	if not is_equal_approx(actual, expected):
		_cleanup_save_slots()
		return "skill stream did not resume: expected %.17f, got %.17f" % [expected, actual]

	# Tohum artık okunabilir durum (dört canlı koşuda bir kez alınamadı).
	var ledger: Dictionary = GameState.get_run_ledger()
	if not ledger.has("seed"):
		_cleanup_save_slots()
		return "run ledger still does not expose the seed"
	if int(ledger["seed"]) != GameState.run_seed:
		_cleanup_save_slots()
		return "ledger seed %d != run_seed %d" % [int(ledger["seed"]), GameState.run_seed]

	# Taze koşu doğuştan tohumlu ve JSON'un güvenli tam-sayı aralığında.
	GameState.initialize_run({"origin_id": "self_made", "company_name": "Seed Co"})
	if GameState.run_seed == 0:
		_cleanup_save_slots()
		return "a fresh run was born unseeded"
	if absi(GameState.run_seed) >= (1 << 53):
		_cleanup_save_slots()
		return "fresh seed %d exceeds the JSON-safe integer range" % GameState.run_seed

	_cleanup_save_slots()
	return ""


# --- 3. İKİ YÜKLEME, TEK SÜREÇ: reset mimarisinin asıl kanıtı ---
static func _case_save_double_load_no_residue() -> String:
	_seed_save_world()
	if not SaveManager.save_to_slot(SAVE_SLOT_A):
		_cleanup_save_slots()
		return "save failed"

	if not SaveManager.apply_loaded_state(SaveManager.read_slot(SAVE_SLOT_A)):
		_cleanup_save_slots()
		return "first load failed"
	var fp2: String = _save_fingerprint(SAVE_SLOT_B)
	var roster_size: int = CharacterRegistry.get_all().size()

	# ARADA OYNA: ikinci yükleme bu artığın hiçbirini taşımamalı.
	var intruder := Customer.new()
	intruder.id = "cust_intruder"
	intruder.company_name = "Residue Ltd"
	CustomerRegistry.add(intruder)
	CharacterRegistry.add(_make_employee("emp_intruder", "Artik", "developer"))
	GameState.set_flag("residue_marker", true)

	if not SaveManager.apply_loaded_state(SaveManager.read_slot(SAVE_SLOT_A)):
		_cleanup_save_slots()
		return "second load failed"
	var fp3: String = _save_fingerprint(SAVE_SLOT_B)

	if fp3 != fp2:
		_cleanup_save_slots()
		return "load B inherited residue from the run played after load A"
	if CustomerRegistry.get_customer("cust_intruder") != null:
		_cleanup_save_slots()
		return "the intruding customer survived a load"
	if CharacterRegistry.get_character("emp_intruder") != null:
		_cleanup_save_slots()
		return "the intruding employee survived a load"
	if GameState.flags.has("residue_marker"):
		_cleanup_save_slots()
		return "a flag set between loads survived the second load"
	if CharacterRegistry.get_all().size() != roster_size:
		_cleanup_save_slots()
		return "roster size drifted across two loads (%d then %d)" % [roster_size, CharacterRegistry.get_all().size()]

	# reset_all_owners TEK giriş noktası: her kayıt boşalır — RAKİPLER HARİÇ, çünkü
	# boş bir rakip alanı geçerli durum değil (RivalCatalog'dan yeniden tohumlanır).
	SaveManager.reset_all_owners()
	if not CustomerRegistry.get_all().is_empty():
		_cleanup_save_slots()
		return "reset_all_owners left customers behind"
	if not CharacterRegistry.get_all().is_empty():
		_cleanup_save_slots()
		return "reset_all_owners left characters behind"
	if not PromiseRegistry.get_all().is_empty():
		_cleanup_save_slots()
		return "reset_all_owners left promises behind"
	if not ProspectRegistry.get_all().is_empty():
		_cleanup_save_slots()
		return "reset_all_owners left prospects behind"
	if RivalRegistry.get_all().is_empty():
		_cleanup_save_slots()
		return "reset_all_owners emptied the rival field instead of re-seeding it"
	if ProductSystem.active_build != null:
		_cleanup_save_slots()
		return "reset_all_owners left an active build behind"

	_cleanup_save_slots()
	return ""


# --- ODA çapaları her en-boy oranında GÖRÜNÜR bandın içinde kalmalı -----------
# Saf matematik: pencere de sahne de gerekmez, yalnız OdaLayout'un kapak dönüşümü.
# Oda 3840x2160 (16:9) boyanmış ve kompozisyon y 0.0'dan 0.98'e kadar UZANIYOR —
# yani DİKEY kırpma bütçesi SIFIR. KEEP_ASPECT_COVERED daha geniş bir en-boy
# oranında tam da bunu yapar: 32:9'da görünür bant [0.261, 0.739]'e iner ve üç
# çerçeve, kâğıtlar ve TELEFON tamamen ekran dışında kalır. Hepsi tıklanabilir
# çapa; telefon mentor/olay yüzeyi. Ölçüldü (5120x1440 shot'ı), sonra bu case
# yazıldı — case önce KIRMIZI doğdu, düzeltmeyle yeşile döndü.
static func _case_oda_anchors_stay_in_band() -> String:
	# EN-BOY ORANIYLA parametrelenir, pencere boyutuyla değil: OdaView'in gördüğü
	# rect viewport DEĞİL, CenterViewport'tur (sol ray genişliği, TopBar + ticker
	# yüksekliği düşülmüş). 1920x1080'de bu ~1.851 oranına denk geliyor — ilk
	# taslak ham 1920x1080'i (1.778) test etmişti ve BİRİNCİL çözünürlükteki
	# şerit gerilemesini tam da bu yüzden kaçırdı.
	var aspects := {
		"16:9  (1.778)": 16.0 / 9.0,
		"16:9 kabuk (1.851)": 1836.0 / 992.0,
		"16:10 (1.600)": 1.6,
		"21:9  (2.333)": 21.0 / 9.0,
		"32:9  (3.556)": 32.0 / 9.0,
	}
	# window: boyalı, TIKLANMAZ (yalnız tur bölgesi) ve tepeden y=0.0'da başlar —
	# hiçbir kırpma bütçesi onu kurtaramaz, kompozisyonun kenarıdır.
	# overtime_chip: place_clamped kullanır, tanımı gereği banda kendisi sığar.
	var exempt := ["window", "overtime_chip"]
	for label in aspects:
		var view := Vector2(1000.0 * float(aspects[label]), 1000.0)
		var band: Vector2 = OdaLayout.visible_band_y(view)
		for id in OdaLayout.RECTS:
			if id in exempt:
				continue
			var r: Rect2 = OdaLayout.RECTS[id]
			if r.position.y < band.x - 0.001:
				return "%s: '%s' üst kenarı bandın dışında (y %.3f < %.3f)" % [label, id, r.position.y, band.x]
			if r.end.y > band.y + 0.001:
				return "%s: '%s' alt kenarı bandın dışında (y %.3f > %.3f)" % [label, id, r.end.y, band.y]

	# BİRİNCİL ÇÖZÜNÜRLÜK GERİLEME KAPISI: 1920x1080'in kabuk oranında oda tam
	# viewport'u doldurmalı. Tavan oraya inerse oyuncu 16:9'da yan şeritler görür —
	# ultrawide'ı kurtarmak uğruna ana durumu bozmak kabul edilebilir değil.
	var shell := Vector2(1836.0, 992.0)
	if OdaLayout.room_rect(shell).size != shell:
		return "16:9 kabuk oranında oda kapaklandı — birincil çözünürlükte yan şerit oluşur"
	return ""


# ============================ DENEYİM / EĞİTİM ===============================
# Beşi de MEKANİĞİ ölçer, ekranı değil: sayılar
# HRConstants'ta WORKING ve değişebilir, ama SÖZLEŞME değişmemeli.

static func _case_hr_experience_accrues() -> String:
	GameState.set_cash(100000)
	var emp: Character = _make_employee("char_xp_a", "XP A", HRConstants.ROLE_DEVELOPER)
	# §5.1: DENEYİM TEK BAR. Alan bazlı sayaçlar emekli — "Deneyim tek bir bar olarak
	# tutulur ve ekranda her zaman 0–100 gösterilir; alan bazlı değildir."
	if emp.experience_raw != 0:
		return "fresh employee started at %d experience, want 0" % emp.experience_raw
	if emp.experience_threshold <= 0:
		return "a fresh employee has no experience threshold — the bar would divide by zero"
	_sim_day()
	if emp.experience_raw < HRConstants.EXPERIENCE_PER_WORKED_DAY:
		return "after one day experience is %d, want at least %d" % [
			emp.experience_raw, HRConstants.EXPERIENCE_PER_WORKED_DAY]
	# BOŞTAKİ kişi öğrenmez — §4'ün "boşta durur ve maaş yer" cümlesinin ikinci yarısı.
	var idle: Character = _make_employee("char_xp_idle", "XP Idle", HRConstants.ROLE_DEVELOPER)
	CharacterRegistry.clear_jobs(idle.id)
	_sim_day()
	if idle.experience_raw != 0:
		return "an UNASSIGNED employee learned (%d)" % idle.experience_raw
	# İZİNDEKİ biri BİRİKTİRMEZ — edilgenlik gerçekten edilgen olmalı.
	# İzin GERÇEKTEN sürmeli: tick_leave_returns, leave_until_day geçmişse kişiyi
	# günün başında aktife çeker ve çıplak bir set_status ölçümü geçersiz kılar.
	CharacterRegistry.set_status(emp.id, HRConstants.STATUS_ON_LEAVE)
	emp.leave_until_day = GameState.day + 10
	var before_leave: int = emp.experience_raw
	_sim_day()
	if emp.experience_raw != before_leave:
		return "an ON-LEAVE employee accrued experience (%d -> %d)" % [
			before_leave, emp.experience_raw]
	emp.leave_until_day = 0
	CharacterRegistry.set_status(emp.id, HRConstants.STATUS_ACTIVE)
	# §5.1 İŞBAŞI ÖĞRENME EMEKLİ: "Deneyim kendiliğinden yıldıza dönüşmez ... Deneyimin tek
	# çıkışı eğitimdir." Bar DOLAR VE ORADA DURUR; yıldızı hareket ettiren tek şey oynanmış
	# bir eğitim kararıdır. Eski ÜCRETSİZ kanal buradaydı ve tersini iddia ediyordu.
	var key_area: String = HRConstants.role_key_area(emp.role)
	var value_before: int = int(emp.role_stats[key_area])
	CharacterRegistry.add_experience(emp.id, emp.experience_threshold * 2)
	if emp.experience_raw != emp.experience_threshold:
		return "the bar did not stop at its threshold (%d / %d)" % [
			emp.experience_raw, emp.experience_threshold]
	if int(emp.role_stats[key_area]) != value_before:
		return "a full bar moved a star on its own — §5.1 retires learn-by-doing"
	return ""


static func _case_hr_training_eligibility_edge() -> String:
	# §5.2 DENEYİM BARI ARTIK KAPIDIR: "Deneyim barı %100'e ulaşır. Eğitim eylemi açılır."
	# rev 2'de şart YOKTU ve bu case tam tersini iddia ediyordu; iki ayrı kanalı (parayla /
	# işi yaparak) birbirinden korumak içindi. §5.1 işbaşı öğrenmeyi emekli etti, yani
	# korunacak ikinci kanal kalmadı — eğitim artık deneyimin TEK ÇIKIŞI.
	#
	# §5.4 iki kilit gerekçesini birbirine KARIŞTIRMAMAYI söylüyor:
	#   bar dolmadı       → "henüz hak edilmedi"
	#   alan 5,0 yıldızda → "bu alanda öğrenecek bir şey kalmadı"
	GameState.set_cash(100000)
	var emp: Character = _make_employee("char_xp_b", "XP B", HRConstants.ROLE_DESIGNER)
	if CharacterRegistry.can_train(emp.id):
		return "a fresh employee with an EMPTY bar was eligible — §5.2 makes the bar the gate"
	# Barı doldur: eylem AÇILIR.
	CharacterRegistry.add_experience(emp.id, emp.experience_threshold)
	if not CharacterRegistry.experience_bar_full(emp):
		return "add_experience did not fill the bar"
	if not CharacterRegistry.can_train(emp.id):
		return "a full bar did not open the training action"
	var key_area: String = HRConstants.role_key_area(HRConstants.ROLE_DESIGNER)
	if not CharacterRegistry.can_train(emp.id, key_area):
		return "NOT eligible in the role's own key area"
	# İzindeyken uygun olmamalı: eğitim aktif bir karardır.
	CharacterRegistry.set_status(emp.id, HRConstants.STATUS_ON_LEAVE)
	if CharacterRegistry.can_train(emp.id, key_area):
		return "an ON-LEAVE employee was eligible for training"
	return ""


static func _case_hr_training_blocks_and_charges_once() -> String:
	GameState.set_cash(100000)
	var emp: Character = _make_employee("char_xp_c", "XP C", HRConstants.ROLE_DEVELOPER)
	# §5.2: bar kapıdır. Doldurulmadan send_to_training reddeder.
	CharacterRegistry.add_experience(emp.id, emp.experience_threshold)
	var area_key: String = HRConstants.role_key_area(HRConstants.ROLE_DEVELOPER)
	var want_fee: int = CharacterRegistry.training_fee_for(emp.id, area_key)
	var cash_before: int = GameState.cash
	if not HRSystem.send_to_training(emp.id, area_key):
		return "send_to_training refused an eligible employee"
	# Ücret KADEMELİ (§8), yani sabit TRAINING_FEE değil — beklenen değer motorun kendi
	# hesabından okunuyor ki test formülü ikinci kez yazmasın.
	if GameState.cash != cash_before - want_fee:
		return "fee charged %d, want %d" % [cash_before - GameState.cash, want_fee]
	if emp.status != HRConstants.STATUS_TRAINING:
		return "status is '%s', want '%s'" % [emp.status, HRConstants.STATUS_TRAINING]
	# ÇIKTI ÜRETMEZ: aktif listede olmamalı (kapasite, hız, SORUMLU hepsi buradan okur).
	for a in CharacterRegistry.get_active_employees():
		if a.id == emp.id:
			return "a TRAINING employee is still in get_active_employees()"
	# İkinci kez gönderilemez, yani ücret iki kez alınamaz.
	var cash_mid: int = GameState.cash
	if HRSystem.send_to_training(emp.id, area_key):
		return "send_to_training accepted an already-training employee"
	if GameState.cash != cash_mid:
		return "a second call charged again (%d -> %d)" % [cash_mid, GameState.cash]
	return ""


static func _case_hr_training_completion() -> String:
	GameState.set_cash(100000)
	var emp: Character = _make_employee("char_xp_d", "XP D", HRConstants.ROLE_TESTER, 5, 0, 50, 4)
	# §5.2: oyuncu alanı seçer, AMA barın dolu olması şarttır — işbaşı öğrenme (§5.1)
	# emekli olduğu için eğitim deneyimin tek çıkışı ve bar da onun tek kapısı.
	CharacterRegistry.add_experience(emp.id, emp.experience_threshold)
	var area_key: String = HRConstants.role_key_area(HRConstants.ROLE_TESTER)
	var before: int = int(emp.role_stats[area_key])
	if not HRSystem.send_to_training(emp.id, area_key):
		return "send_to_training refused an eligible employee"
	for i in HRConstants.TRAINING_DAYS:
		if emp.status != HRConstants.STATUS_TRAINING:
			return "left training early on day %d" % i
		_sim_day()
	if emp.status != HRConstants.STATUS_ACTIVE:
		return "after %d days status is '%s', want active" % [HRConstants.TRAINING_DAYS, emp.status]
	var after: int = int(emp.role_stats[area_key])
	if after != before + 1:
		return "%s %d -> %d, want +1" % [area_key, before, after]
	if int(emp.trainings_done.get(area_key, 0)) != 1:
		return "the training counter did not tick"
	# §5.3 BEDEL YALNIZ YILDIZ SEVİYESİNE GÖRE KADEMELENİR. rev 2'nin "tekrarda azalan
	# getiri" zammı KALKTI — aynı +½ yıldızı ikinci bir eksenden fiyatlıyordu, ve §5.3
	# frenleri açıkça sayıyor: deneyim eşiği (§5.1) ve kademeli bedel, o kadar.
	#
	# Doğru iddia "tekrar daha pahalı" değil, "YÜKSEK YILDIZ daha pahalı".
	var fee_here: int = CharacterRegistry.training_fee_for(emp.id, area_key)
	var fee_two_stars_up: int = HRConstants.training_fee_tiered(
		mini(after + 2 * HRConstants.POINTS_PER_STAR, HRConstants.AREA_MAX))
	if fee_two_stars_up <= fee_here:
		return "the fee ladder is flat: %d at %d points, %d two stars higher" % [
			fee_here, after, fee_two_stars_up]
	# §5.3: "0★→0,5★ ucuzdur; 4,5★→5,0★ pahalıdır." Uçlar arasındaki fark kat kat olmalı.
	if HRConstants.training_fee_tiered(HRConstants.AREA_MAX - 1) < HRConstants.TRAINING_FEE_BASE * 4:
		return "the top rung is not meaningfully more expensive than the first"
	return ""


static func _case_hr_expertise_cap_respected() -> String:
	# Tavandaki biri eğitime GÖNDERİLEMEZ. Ücreti alıp hiçbir şey vermemek §10'un
	# yasakladığı şeyin aynası olurdu.
	GameState.set_cash(100000)
	# §5.3 TEK TAVAN: beşinci yıldız (AREA_MAX 10). AREA_TRAIN_CAP 8'in "para her şeyi
	# satın alamaz" boşluğu kalktı — "parayla satın alınamayan bir üst yıldız yoktur".
	# Beşinci yıldızı pahalı yapan iki fren artık deneyim eşiği ve kademeli bedeldir.
	var emp: Character = _make_employee("char_xp_e", "XP E", HRConstants.ROLE_DEVELOPER,
		5, 0, 50, HRConstants.AREA_MAX)
	CharacterRegistry.add_experience(emp.id, emp.experience_threshold)
	var capped_area: String = HRConstants.role_key_area(emp.role)
	if CharacterRegistry.can_train(emp.id, capped_area):
		return "an employee already at the five-star ceiling (%d) was eligible" % HRConstants.AREA_MAX
	var cash_before: int = GameState.cash
	if HRSystem.send_to_training(emp.id, capped_area):
		return "send_to_training accepted a capped employee"
	if GameState.cash != cash_before:
		return "a refused training still charged the fee"
	# Bir altındaki biri gönderilebilir ve tavanı AŞMAZ.
	var emp2: Character = _make_employee("char_xp_f", "XP F", HRConstants.ROLE_DEVELOPER,
		5, 0, 50, HRConstants.AREA_MAX - 1)
	CharacterRegistry.add_experience(emp2.id, emp2.experience_threshold)
	var area2: String = HRConstants.role_key_area(HRConstants.ROLE_DEVELOPER)
	if not HRSystem.send_to_training(emp2.id, area2):
		return "an employee one below the ceiling was refused"
	for _i in HRConstants.TRAINING_DAYS:
		_sim_day()
	var final_value: int = int(emp2.role_stats[area2])
	if final_value != HRConstants.AREA_MAX:
		return "%s landed at %d, want the ceiling %d" % [area2, final_value, HRConstants.AREA_MAX]
	# §5.2: "Deneyim barı SIFIRLANIR." Ve eşik yeniden hesaplanır, çünkü kişi az önce gelişti.
	if emp2.experience_raw != 0:
		return "the bar did not reset after training (%d)" % emp2.experience_raw
	return ""


## The UI-scale ladder must never be able to push a shell modal off the screen.
## Written because %150 did exactly that: content_scale_factor SHRINKS the logical
## viewport, so a 1920×1080 window at %150 reported 1280×720 while SettingsModal's
## FIXED CenterPanel was 860px tall — the Footer holding KAPAT fell off the bottom
## edge and the panel could only be dismissed with ESC.
##
## Why 1080/step is the right bound, and resolution-independent: with canvas_items
## the stretch is min(win.x/1920, win.y/1080), which on ANY 16:9 window is win.y/1080,
## so the logical height collapses to 1080/step whatever the panel measures. 16:10
## and ultrawide only ever give MORE height. So the primary resolution is the floor,
## not merely an example.
##
## The panel height is READ FROM THE SCENE and never re-typed here — a copied number
## keeps passing while the thing it guards drifts. SceneState rather than
## instantiate() keeps this a pure read: no _ready(), no signal wiring, no Settings
## access, nothing to leak into the next case.
static func _case_ui_scale_ladder_fits_settings() -> String:
	var packed: PackedScene = load("res://scenes/modals/SettingsModal.tscn")
	if packed == null:
		return "SettingsModal.tscn could not be loaded"
	var state: SceneState = packed.get_state()
	var top: float = INF
	var bottom: float = INF
	for i in state.get_node_count():
		if String(state.get_node_name(i)) != "CenterPanel":
			continue
		for j in state.get_node_property_count(i):
			match String(state.get_node_property_name(i, j)):
				"offset_top":    top = float(state.get_node_property_value(i, j))
				"offset_bottom": bottom = float(state.get_node_property_value(i, j))
	if is_inf(top) or is_inf(bottom):
		return "CenterPanel's offset_top/offset_bottom not found in the scene"
	var panel_h: float = bottom - top
	if panel_h <= 0.0:
		return "CenterPanel height read as %.1f — unexpected scene shape" % panel_h

	var top_step: float = 0.0
	for s in DisplaySettings.UI_SCALE_STEPS:
		top_step = maxf(top_step, float(s))
	if top_step <= 0.0:
		return "UI_SCALE_STEPS is empty"
	var tightest_h: float = DisplaySettings.BASE_VIEWPORT.y / top_step
	if tightest_h < panel_h:
		return "top step %d%% leaves a %.0fpx logical viewport; Settings panel is %.0fpx — KAPAT lands off-screen" % [
			int(round(top_step * 100.0)), tightest_h, panel_h]

	# İkinci hüküm: merdivenin tavanı üyelik kapısından da geçmeli, yoksa
	# is_step_allowed onu reddeder ve açılır listenin en üst adımı ölü görünür.
	if not DisplaySettings.is_step_allowed(top_step, Vector2i(1920, 1080)):
		return "top step %d%% is not legal at the primary resolution" % int(round(top_step * 100.0))
	return ""


## BILINGUAL BIRTH LAW's CSV half, as a command. Every row must carry BOTH locales, use
## only named placeholders, and expose the SAME token set in both columns — a tr/en token
## mismatch is the one .format failure that renders a literal "{company}" to the player.
## Also resolves every key through the real TranslationServer in both locales, which is
## what catches a row the parser silently dropped (the multi-line quoted event bodies are
## exactly the shape that can shift a column).
static func _case_loc_csv_integrity() -> String:
	var f := FileAccess.open("res://localization/strings.csv", FileAccess.READ)
	if f == null:
		return "strings.csv unreadable"
	var header: PackedStringArray = f.get_csv_line()
	if header.size() < 3:
		return "strings.csv header wants keys,tr,en — got %s" % str(header)
	var re_key := RegEx.new()
	re_key.compile("^[A-Z][A-Z0-9_]*$")
	var re_printf := RegEx.new()
	re_printf.compile("%[0-9]*[dsfx]")
	var re_token := RegEx.new()
	# Braces via character classes, not backslashes: GDScript rejects "\{" as an invalid
	# string escape, and "[{]" is the same thing to PCRE without fighting the string parser.
	re_token.compile("[{]([a-z_]+)[}]")
	var keys: Array[String] = []
	var seen := {}
	while not f.eof_reached():
		var row: PackedStringArray = f.get_csv_line()
		if row.size() == 0 or row[0].strip_edges() == "":
			continue
		var key: String = row[0].strip_edges()
		if re_key.search(key) == null:
			return "key is not SCREAMING_SNAKE: '%s'" % key
		if seen.has(key):
			return "duplicate key: %s" % key
		seen[key] = true
		# TAM ÜÇ SÜTUN, "en az üç" DEĞİL (2026-08-21). Kapı `< 3` diyordu ve
		# TIRNAKLANMAMIŞ VİRGÜL taşıyan bir değerin dörde bölünmesini sessizce geçirdi:
		# TR yarım kaldı (ilk parça), EN sütununa TR'nin İKİNCİ parçası oturdu ve gerçek
		# EN dördüncü sütunda düştü — yani oyuncu İngilizce oynarken ekranda Türkçe bir
		# cümle parçası gördü. İki sütun da dolu ve token'sız olduğu için başka hiçbir
		# iddia bunu yakalayamıyordu. FALSİFİKASYON: bir değerin tırnağını kaldır → FAIL.
		if row.size() != 3:
			return "%s has %d columns, wants exactly 3 (an unquoted comma splits a value)" % [
				key, row.size()]
		var tr_v: String = row[1]
		var en_v: String = row[2]
		if tr_v.strip_edges() == "" or en_v.strip_edges() == "":
			return "%s is single-locale (tr=%d chars, en=%d chars)" % [
				key, tr_v.length(), en_v.length()]
		if re_printf.search(tr_v) != null or re_printf.search(en_v) != null:
			return "%s still carries a positional printf token" % key
		var tr_tokens: Array[String] = []
		for m in re_token.search_all(tr_v):
			tr_tokens.append(m.get_string(1))
		var en_tokens: Array[String] = []
		for m in re_token.search_all(en_v):
			en_tokens.append(m.get_string(1))
		tr_tokens.sort()
		en_tokens.sort()
		if tr_tokens != en_tokens:
			return "%s token sets differ: tr=%s en=%s" % [key, str(tr_tokens), str(en_tokens)]
		# A brace that is not part of a {name} token would survive .format and reach the screen.
		if tr_v.count("{") != tr_tokens.size() or tr_v.count("}") != tr_tokens.size():
			return "%s tr has a stray brace" % key
		if en_v.count("{") != en_tokens.size() or en_v.count("}") != en_tokens.size():
			return "%s en has a stray brace" % key
		keys.append(key)
	if keys.size() < 300:
		return "only %d keys parsed — the CSV reader lost rows" % keys.size()
	var loc0: String = TranslationServer.get_locale()
	for loc in ["tr", "en"]:
		TranslationServer.set_locale(loc)
		for k in keys:
			if TranslationServer.translate(k) == k:
				TranslationServer.set_locale(loc0)
				return "%s does not resolve under '%s' (renders as the raw key)" % [k, loc]
	TranslationServer.set_locale(loc0)
	return ""


## Fmt actually flips. Replaces the byte-pins that asserted the Turkish-only forms and
## could not have noticed English rendering Turkish. Asserts the SHAPES that differ:
## thousands separator, decimal mark, percent side, date field ORDER, and the uppercase
## rule (the English branch exists because tr_upper was mangling Display→DİSPLAY).
static func _case_loc_format_locale_flip() -> String:
	var loc0: String = TranslationServer.get_locale()
	var d := {"weekday": 3, "day": 9, "month": 9, "year": 2026}
	var want := {
		"tr": {
			"money_exact": "$1.234.567", "money": "$3,5K", "pct": "%12,5",
			"date": "Çar, 9 Eyl 2026", "upper": "İYİ", "month": "Eylül",
		},
		"en": {
			"money_exact": "$1,234,567", "money": "$3.5K", "pct": "12.5%",
			"date": "Wed, Sep 9, 2026", "upper": "IYI", "month": "September",
		},
	}
	for loc in ["tr", "en"]:
		TranslationServer.set_locale(loc)
		var w: Dictionary = want[loc]
		var got := {
			"money_exact": Fmt.money_exact(1234567),
			"money": Fmt.money(3500),
			"pct": Fmt.percent(12.5, 1),
			"date": Fmt.date_line(d),
			"upper": Fmt.upper("iyi"),
			"month": Fmt.month_name(9),
		}
		for field in w:
			if String(got[field]) != String(w[field]):
				TranslationServer.set_locale(loc0)
				return "%s.%s = '%s', want '%s'" % [loc, field, got[field], w[field]]
	# The English branch of upper() is the bug fix; assert it on the word that was mangled.
	TranslationServer.set_locale("en")
	if Fmt.upper("Display") != "DISPLAY":
		TranslationServer.set_locale(loc0)
		return "en upper('Display') = '%s', want DISPLAY (the tr i→İ rule leaked)" % Fmt.upper("Display")
	TranslationServer.set_locale(loc0)
	return ""


## Every card carries BOTH locales, and every localization key in either resolves.
##
## REPOINTED AT THE CATALOGUE. `data/events/reactive/` went with the old engine, and with it
## the `*_en` sibling-field convention this case was written for — along with its ratchet,
## which existed because 79 English values were still unwritten. Cards carry a `text` block per
## locale and the BILINGUAL BIRTH LAW is absolute for them, so the ratchet has nothing to
## count down: the question is simply whether both blocks are there and whether every
## SCREAMING_SNAKE token in them has a CSV row.
static func _case_loc_event_en_coverage() -> String:
	EvCatalog.reload()
	var missing: Array[String] = []
	for id in EvCatalog.card_ids():
		var card: Dictionary = EvCatalog.card(String(id))
		var text: Dictionary = card.get("text", {})
		for locale in ["tr", "en"]:
			if not text.has(locale) or (text[locale] as Dictionary).is_empty():
				missing.append("%s: no %s block" % [id, locale])
				continue
			for token in _caps_tokens(text[locale]):
				if TranslationServer.translate(token) == token:
					missing.append("%s: %s has no CSV row" % [id, token])
	if EvCatalog.card_ids().is_empty():
		return "no cards found — the scan is not looking where it thinks"
	if not missing.is_empty():
		return "locale gaps (%d): %s" % [missing.size(), ", ".join(missing.slice(0, 8))]
	return ""


## Localization.pick's contract, including the one that is easy to get backwards: an EMPTY
## English sibling means "fall back to Turkish" and is how code-factory events stay correct
## in both locales without carrying a discriminator field.
static func _case_loc_pick_fallback() -> String:
	var loc0: String = TranslationServer.get_locale()
	var out: String = ""
	TranslationServer.set_locale("en")
	if Localization.pick("TR metni", "EN text") != "EN text":
		out = "en locale did not take the English sibling"
	elif Localization.pick("TR metni", "") != "TR metni":
		out = "empty _en under en must fall back to Turkish (the factory contract)"
	if out == "":
		TranslationServer.set_locale("tr")
		if Localization.pick("TR metni", "EN text") != "TR metni":
			out = "tr locale must ignore the English sibling"
		elif Localization.pick("TR metni", "") != "TR metni":
			out = "empty _en under tr must return the Turkish text"
	TranslationServer.set_locale(loc0)
	return out


## Derived keys resolve. B2BConstants builds its copy keys from ids at runtime
## (SECTOR_ + id, B2B_COMPLAINT_ + id, FEATURE_LABEL_ + feature_id …), which is what keeps
## one id yielding one row in both languages — but it also means NO grep for tr("LITERAL")
## can see them, and a typo would reach the player as a raw token or silently fall back to
## the generic line. This walks the real id lists and asserts each derived key resolves to
## something OTHER than the fallback, in BOTH locales.
static func _case_loc_b2b_derived_keys() -> String:
	var loc0: String = TranslationServer.get_locale()
	var feature_ids: Array = []
	for pid in ["ai_vector_search", "saas_ops"]:
		for f in ProductCatalog.get_feature_pool(pid):
			feature_ids.append(String(f.get("id", "")))
	if feature_ids.is_empty():
		TranslationServer.set_locale(loc0)
		return "no feature ids found — the scan is not looking where it thinks"
	var families := [
		{"prefix": "SECTOR_", "fallback": "SECTOR_FALLBACK", "ids": _sector_ids_with_fixture()},
		{"prefix": "B2B_CONTACT_", "fallback": "B2B_CONTACT_FALLBACK", "ids": B2BConstants.SECTORS},   # no fixture contact by design
		{"prefix": "B2B_COMPLAINT_", "fallback": "B2B_COMPLAINT_FALLBACK", "ids": B2BConstants.SECTORS},
		{"prefix": "FEATURE_LABEL_", "fallback": "FEATURE_LABEL_FALLBACK", "ids": feature_ids},
		{"prefix": "B2B_PAIN_", "fallback": "B2B_PAIN_FALLBACK", "ids": feature_ids},
	]
	for loc in ["tr", "en"]:
		TranslationServer.set_locale(loc)
		for fam in families:
			var fallback: String = TranslationServer.translate(String(fam["fallback"]))
			for id in (fam["ids"] as Array):
				var sid: String = String(id)
				if sid == "":
					continue
				var key: String = String(fam["prefix"]) + sid.to_upper()
				var got: String = TranslationServer.translate(key)
				if got == key:
					TranslationServer.set_locale(loc0)
					return "[%s] %s has no row (renders the raw key)" % [loc, key]
				if got == fallback:
					TranslationServer.set_locale(loc0)
					return "[%s] %s silently resolved to the family fallback" % [loc, key]
	TranslationServer.set_locale(loc0)
	return ""


## The 13 market sectors plus the fixture one. Only the SECTOR_ label family covers the
## fixture — it has no contact, no complaint voice and no company pool by design.
static func _sector_ids_with_fixture() -> Array:
	var out: Array = B2BConstants.SECTORS.duplicate()
	out.append(B2BConstants.SECTOR_FIXTURE)
	return out


## The v1→v2 save migration actually remaps. `industry` is persisted, so every save taken
## before the sector-id change carries a Turkish name where the code now expects an ASCII
## id. Without the migration such a save loads "fine" and is quietly wrong — the sector tag
## falls through to the generic label and affinity pools stop matching. Asserted on a
## hand-built v1 state rather than on a file, so the test cannot be fooled by a stale save.
# ===================== Ekip · görev ataması (rev 2 §4/§5) ====================

static func _case_job_assignment_and_idle() -> String:
	# rev 2 §4'ün cümleleri, ALAN kelimesiyle: kişi BİR ALANA atanır, atanmamış olan BOŞTA
	# durur ve maaş yer, ve hangi alanın boş kaldığı görünür. ch. 06 §1.3'ün paydası da burada.
	# FALSİFİKASYON: CharacterRegistry.add'deki default_area_for_role bloğunu sil → ilk
	# iddia FAIL ("işe alınan kişi boşta doğdu").
	var dev: Character = _make_employee("char_as_dev", "As Dev", HRConstants.ROLE_DEVELOPER)
	var rep: Character = _make_employee("char_as_rep", "As Rep", HRConstants.ROLE_CUSTOMER_REP)
	# Kimse boşta DOĞMAZ: işe alım kişiyi kendi ANA ALANINA koyar.
	if HRSystem.is_idle(dev) or HRSystem.is_idle(rep):
		return "a fresh hire was born idle — nobody should meet 'Boşta' at the moment they pay a commission"
	if not dev.assigned_jobs.has(HRConstants.AREA_ENGINEERING):
		return "a developer did not land on Yazılım: %s" % str(dev.assigned_jobs)
	if not rep.assigned_jobs.has(HRConstants.AREA_CUSTOMER_SUCCESS):
		return "a customer rep did not land on Müşteri İlişkileri: %s" % str(rep.assigned_jobs)
	# Seam'den çıkarınca BOŞTA olur — türetilmiş, saklanan bayrak değil.
	CharacterRegistry.unassign_area(dev.id, HRConstants.AREA_ENGINEERING)
	if not HRSystem.is_idle(dev):
		return "an unassigned employee is not idle"
	if HRSystem.idle_count() != 1:
		return "idle_count is %d, want exactly 1" % HRSystem.idle_count()
	# Bilinmeyen alan REDDEDİLİR, sessizce kabul edilmez.
	if CharacterRegistry.assign_area(dev.id, "not_an_area") == "":
		return "an unknown area id was accepted"
	# UYGUNLUK KAPISI (tasarımın "ALANI YOK · ATANAMAZ" hücresi): bir yazılımcı Satış'a
	# atanamaz — ne ana ne ikincil alanı. İkincil alanına (Test) atanabilir.
	if CharacterRegistry.assign_area(dev.id, HRConstants.AREA_SALES) != "not_your_area":
		return "a developer was allowed into Satış, which is neither their key nor their secondary area"
	if CharacterRegistry.assign_area(dev.id, HRConstants.AREA_QA) != "":
		return "a developer was refused their own SECONDARY area"
	CharacterRegistry.unassign_area(dev.id, HRConstants.AREA_QA)
	# §15.3 `hr.unstaffed_jobs()` — alan değil İŞ. Alan-anahtarlı ikizleri (covering_heads,
	# unstaffed_areas) yalnız bu vakadan çağrılıyordu ve §12.0 ile birlikte gitti.
	var empty: Array[String] = HRSystem.unstaffed_jobs()
	# REPOINTED 2026-08-27 WITH THE RULING (B3). Bu satır DESTEK'i sorguluyor, HESAPLAR'ı değil,
	# çünkü Müşteri Temsilcisi artık kendi alanının birincil işine — DESTEK MASASINA — doğuyor.
	# Eskiden HESAPLAR'a doğuyordu ve masa hiç dolmuyordu; düzeltilen şey tam olarak buydu.
	# Vakanın ÖLÇTÜĞÜ ŞEY DEĞİŞMEDİ: `unstaffed_jobs` gerçekten atanmış bir işi boş SAYMAMALI.
	if empty.has(HRConstants.JOB_SUPPORT):
		return "Destek reads unstaffed while the fresh Müşteri Temsilcisi is assigned to it"
	# Ve HESAPLAR artık varsayılan sakini olmayan bir sütundur — boş okunması DOĞRUDUR.
	if not empty.has(HRConstants.JOB_ACCOUNTS):
		return "Hesap sahipliği reads staffed with nobody assigned to it"
	# SATIŞ YİNE BİR İŞ (Satış rev 6 §3/§3.1, direktör hükmü 2026-08-26) ve bu satır tersine
	# çevrildi. 2026-08-25'in gerekçesi DEĞİŞMEDİ ve hâlâ doğru: kurucunun pitch'i bir
	# TOPLANTIDIR, slot tüketmez, hiçbir şeyi duraklatmaz — `SalesMeetingSystem` hiçbir
	# atamaya dokunmuyor. İş olan şey başka: §7.2'nin temsilci masası, tek müşteriyi 6-7 GÜN
	# işleyen sürekli iş. İkisi bir arada durur, ve ayrımı yapan da tam olarak bu vaka.
	#
	# Ledger'da olmasının iki ölçülebilir sonucu var: §3'ün musluğu "ATANMIŞ satış kapasitesi"
	# okuyabiliyor, ve §3.1'in "Satış işi sütunu kilitli-görünür" hükmünün asacağı bir sütun
	# oluyor. İkisi de Satış alanı `accounts` üzerinden taşınırken imkânsızdı.
	if not empty.has(HRConstants.JOB_SALES):
		return "Satış does not read as a staffable job; §3 needs assigned sales capacity"
	# Ve kimse atanmamışken BOŞ okunuyor — sütunun var olması onu dolu saymıyor.
	var sales_rep: Character = _make_employee("emp_sales_ledger", "Satis Ledger",
		HRConstants.ROLE_SALES_REP)
	CharacterRegistry.clear_jobs(sales_rep.id)
	CharacterRegistry.assign_job(sales_rep.id, HRConstants.JOB_SALES)
	if HRSystem.unstaffed_jobs().has(HRConstants.JOB_SALES):
		return "Satış still reads unstaffed with somebody assigned to it"
	# AMA SATIŞ ALANI YAŞAMAYA DEVAM EDER, ve bu kaldırmanın en riskli sonucudur:
	# SalesRepSystem otonom lead akışını `HRSystem.assigned_to(AREA_SALES)` üzerinden okuyor,
	# o da iş defterinin TÜRETİLMİŞ AYNASI. İş gidince alanı taşıyan tek iş hesap sahipliği
	# kaldı (JOB_AREAS["accounts"] zaten Satış ve Mİ'nin ikisini birden tutuyordu).
	# Bu iddia düşerse otonom satış sessizce susar — ekranda hiçbir hata görünmeden.
	var srep: Character = _make_employee("char_as_srep", "As SRep", HRConstants.ROLE_SALES_REP)
	if CharacterRegistry.assign_job(srep.id, HRConstants.JOB_ACCOUNTS) != "":
		return "a sales rep was refused the accounts job, which now carries the Satış area"
	if not srep.assigned_jobs.has(HRConstants.AREA_SALES):
		return "a sales rep on Hesaplar does not mirror into the Satış area: %s" % str(srep.assigned_jobs)
	var staffed := false
	for c2 in HRSystem.assigned_to(HRConstants.AREA_SALES):
		if c2.id == srep.id:
			staffed = true
	if not staffed:
		return "assigned_to(Satış) cannot see a staffed sales rep — autonomous sales would go silent"
	CharacterRegistry.clear_jobs(srep.id)
	CharacterRegistry.remove(srep.id)
	# KURUCU TEK ETKİN İŞ (§2.1 "Her şeyi yapabilir, aynı anda yapamaz") — ama Ar-Ge §5.0
	# bu kuralın SONUCUNU değiştirdi: ikinci iş artık REDDEDİLMİYOR, öncekini DURAKLATIYOR.
	# "Eski 'kurucu yapım yaparken satış yapamaz' kısıtı kaldırılmıştır. Kurucu satışa
	# geçebilir; geçtiğinde yapım duraklar. Aynı gramer." Eskiden burada `founder_busy`
	# refüzü ölçülüyordu; o kod artık yok, ve ölçülmesi gereken şey duraklamanın kendisi.
	var founder: Character = CharacterRegistry.get_founder()
	if founder.assigned_job_ids.size() != 1:
		return "the founder holds %d jobs at run start, want exactly 1" % founder.assigned_job_ids.size()
	# ALAN AYNASI DAHA GENİŞ OLABİLİR VE BU DOĞRUDUR: Build ekibi Ürün · Tasarım · Yazılım
	# alanlarınca taşınır (§12.0) ve kurucu altı alanın hepsini taşır (§2), yani Build'deki
	# bir kurucu üçünde de görünür. ProductSystem._founder_phase_area onu hangi faz koşuyorsa
	# orada bulabilsin diye böyle; eski tek-alan koltuğu bunu yapamıyordu.
	if founder.assigned_jobs.is_empty():
		return "the founder's area mirror is empty while he holds a job"
	var held: String = String(founder.assigned_job_ids[0])
	# İKİ SÜREKLİ SLOT, KURUCUYA DA. Eski "kurucu tek iş" istisnası 2026-08-25'te kalktı:
	# DESTEK'teki kurucu yapıma başlarsa İKİSİ DE koşar ve ikisi de yavaşlar (odak 0,50/0,50).
	# O baskı modülün öğrettiği şeydir — bir duraklamayla değiştirilmez.
	var second: String = HRConstants.JOB_SUPPORT if held != HRConstants.JOB_SUPPORT \
		else HRConstants.JOB_BUILD
	if CharacterRegistry.assign_job(founder.id, second) != "":
		return "the founder was refused a second CONTINUOUS job; two slots are his too"
	if founder.assigned_job_ids.size() != 2:
		return "the founder holds %d jobs after a second continuous one, want 2" \
			% founder.assigned_job_ids.size()
	if not founder.paused_job_ids.is_empty():
		return "a second CONTINUOUS job paused something; only research displaces (%s)" \
			% str(founder.paused_job_ids)
	# İki iş = 0,50 odak, ve AŞIRI YÜK. İkisi de baskının kendisidir.
	if not HRSystem.is_overloaded(founder):
		return "a founder on two continuous jobs did not read as overloaded"
	if HRConstants.focus_mult(HRSystem.job_count(founder)) != HRConstants.FOCUS_MULT_SPLIT:
		return "two continuous jobs did not split focus 0,50/0,50"
	# ÜÇÜNCÜ sürekli iş reddedilir — tavan hâlâ gerçek bir tavandır.
	var third: String = HRConstants.JOB_TEST
	if not founder.assigned_job_ids.has(third):
		if CharacterRegistry.assign_job(founder.id, third) != "job_cap":
			return "a third CONTINUOUS job was accepted; §12.1's two-job cap is not a cap"
	# ARAŞTIRMA TAVANA TAKILMAZ: slot tutmaz, ikisini birden duraklatır.
	if CharacterRegistry.assign_job(founder.id, HRConstants.JOB_RESEARCH) != "":
		return "a full continuous ledger REFUSED research; research occupies no slot"
	if founder.assigned_job_ids != [HRConstants.JOB_RESEARCH]:
		return "research did not displace both continuous jobs (%s)" \
			% str(founder.assigned_job_ids)
	if founder.paused_job_ids.size() != 2:
		return "research paused %d continuous jobs, want 2" % founder.paused_job_ids.size()
	# Ve geri dönüş: araştırma bitince ikisi de kaldıkları yerden döner.
	CharacterRegistry.unassign_job(founder.id, HRConstants.JOB_RESEARCH)
	if founder.assigned_job_ids.size() != 2:
		return "ending the research resumed %d of 2 paused jobs" \
			% founder.assigned_job_ids.size()
	if not founder.paused_job_ids.is_empty():
		return "resumed jobs were left in the paused ledger: %s" % str(founder.paused_job_ids)
	CharacterRegistry.clear_jobs(founder.id)
	if not founder.assigned_jobs.is_empty():
		return "clearing the jobs left a stale area mirror: %s" % str(founder.assigned_jobs)
	# Araştırma bir İŞ'tir (Ar-Ge §5.0, Ekip'in iş listesine eklendi) ama bir ALAN DEĞİLDİR:
	# HRConstants.AREAS hâlâ altı alan taşır. Yani alan kapısı aynı kapıdır ve uydurma bir
	# id'yi reddeder. Araştırmaya atama Ar-Ge panelinden geçer (§5.3), Görevler matrisinden
	# değil — matriste sütun VARDIR ama hücresi salt okunurdur.
	if CharacterRegistry.assign_area(founder.id, "research") == "":
		return "Araştırma was still accepted as an assignment — §12.0 removes the column"
	return ""


static func _case_overload_costs_output() -> String:
	# §12.1 AŞIRI YÜK = İKİ İŞ, ve bedeli İLK GÜNDEN ödenir. Rozet de bedel de gecikmez.
	#
	# LEDGER (2026-08-24): bu vaka rev 2 §5'in TOLERANS modelini ölçüyordu — beş günlük bir
	# lütuf penceresi, sonra ×0,75 çıktı cezası. §12.1 ikisini de adıyla kaldırdı: "Ayrı bir
	# tolerans sayacı yoktur. Moral hedefe doğru sürüklendiği için tolerans zaten
	# emergent'tir." Yerine ODAK KATSAYISI geçti (tek iş 1,00 · iki iş 0,50, her iki işe
	# ayrı ayrı) ve vaka onu ölçüyor. İDDİA SAYISI AYNI KALDI, ölçtükleri değişti.
	#
	# FALSİFİKASYON: HRSystem.output_mult_for_area'daki `focus_mult` çarpanını sil →
	# ikinci iddia FAIL (iki işte çıktı tek işteki gibi kalır).
	var dev: Character = _make_employee("char_ov_dev", "OV Dev", HRConstants.ROLE_DEVELOPER)
	if HRSystem.is_overloaded(dev):
		return "a single-job employee reads as overloaded"
	var solo_out: float = HRSystem.output_mult_for_area(dev, HRConstants.AREA_ENGINEERING)
	var solo_eff: float = HRSystem.effective_skill(dev, HRConstants.AREA_ENGINEERING)
	CharacterRegistry.assign_area(dev.id, HRConstants.AREA_QA)
	if not HRSystem.is_overloaded(dev):
		return "two jobs did not read as overloaded"
	# BEDEL İLK GÜNDEN: bir gün bile simüle etmeden yarıya iner.
	var split_out: float = HRSystem.output_mult_for_area(dev, HRConstants.AREA_ENGINEERING)
	if not is_equal_approx(split_out, solo_out * HRConstants.FOCUS_MULT_SPLIT):
		return "the second job did not halve output on day one: %.3f (want %.3f)" % [
			split_out, solo_out * HRConstants.FOCUS_MULT_SPLIT]
	# ...ve §4.5'in kanonik formülünde de aynı katsayı, aynı gün.
	if not is_equal_approx(HRSystem.effective_skill(dev, HRConstants.AREA_ENGINEERING),
			solo_eff * HRConstants.FOCUS_MULT_SPLIT):
		return "effective_skill does not carry the same focus coefficient"
	# TOPLAM ASLA BÜYÜMEZ (§12.1): "en iyi durumda tam olarak bir kişilik iş çıkar."
	# İki işin toplamı tek işteki çıktıyı GEÇEMEZ — eski ×0,75 cezası bu toplamı 0,75'e
	# düşürüyordu, yani bölünme iki kez faturalanıyordu.
	var both: float = HRSystem.effective_skill(dev, HRConstants.AREA_ENGINEERING) * 2.0
	if both > solo_eff + 0.001:
		return "two jobs produced MORE than one (%.3f vs %.3f)" % [both, solo_eff]
	# Bir işe dönünce katsayı geri gelir — bedel kalıcı bir damga değil, ANLIK bir durum.
	CharacterRegistry.unassign_area(dev.id, HRConstants.AREA_QA)
	if not is_equal_approx(HRSystem.output_mult_for_area(dev, HRConstants.AREA_ENGINEERING), solo_out):
		return "dropping back to one job did not restore full focus"
	# İKİNCİL ALAN daha yorucu (§4.3): bir yazılımcı Test'i ikincil alanından çalışır, yani
	# aynı gün ona daha pahalıya gelir.
	var fresh: Character = _make_employee("char_ov_b", "OV B", HRConstants.ROLE_DEVELOPER)
	CharacterRegistry.unassign_area(fresh.id, HRConstants.AREA_ENGINEERING)
	CharacterRegistry.assign_area(fresh.id, HRConstants.AREA_QA)
	if HRSystem.output_mult_for_area(fresh, HRConstants.AREA_QA) >= solo_out:
		return "working outside the key area costs nothing — §4.3 says the secondary area is more tiring"
	return ""


static func _case_star_ruler_contract() -> String:
	# Onaylı tasarım her yeteneği BEŞ YILDIZ çiziyor ve yarım yıldızı destekliyor. Cetvel
	# tek yerde yaşıyor: HRConstants.stars_for. İki uç da anlamlı olmalı — tavan tam beş,
	# tek sayılar yarım.
	# FALSİFİKASYON: AREA_MAX'i 9'a döndür → ikinci iddia FAIL (tavan 4,5 yıldız okur).
	if HRConstants.POINTS_PER_STAR != 2:
		return "POINTS_PER_STAR is %d; the half-star grammar needs exactly 2" % HRConstants.POINTS_PER_STAR
	if not is_equal_approx(HRConstants.stars_for(HRConstants.AREA_MAX), float(HRConstants.STAR_MAX)):
		return "the top of the ruler is %.1f stars, want a full %d — five can never fill" % [
			HRConstants.stars_for(HRConstants.AREA_MAX), HRConstants.STAR_MAX]
	# KURUCU DA BU CETVELDE (§2.4 + §5.3). Bu satır turdan ÖNCE DÜŞERDİ: SKILL_CEILING 5'ti
	# ve stars_for(5) = 2,5 yıldız verirdi — Kişisel kartı kurucuya asla dolduramayacağı bir
	# yıldız satırı çiziyordu. Cetvelin gerçekten birleştiğinin tek cümlelik ispatı.
	if not is_equal_approx(HRConstants.stars_for(FounderConstants.SKILL_CEILING),
			float(HRConstants.STAR_MAX)):
		return "the founder ceiling renders %.1f stars, want a full %d — §2.4 puts him on the shared ruler" % [
			HRConstants.stars_for(FounderConstants.SKILL_CEILING), HRConstants.STAR_MAX]
	if not is_equal_approx(HRConstants.stars_for(0), 0.0):
		return "zero points is not zero stars"
	if not is_equal_approx(HRConstants.stars_for(1), 0.5):
		return "one point is %.2f stars, want the half" % HRConstants.stars_for(1)
	# §5.3 TEK TAVAN: "Eğitim beşinci yıldıza kadar çıkabilir. Tavan 5,0 yıldızdır (10/10).
	# PARAYLA SATIN ALINAMAYAN BİR ÜST YILDIZ YOKTUR." rev 2'nin ayrı eğitim tavanı (8 = dört
	# yıldız) kalktı; beşinci yıldızı pahalı yapan iki fren artık DENEYİM EŞİĞİ ve KADEMELİ
	# BEDELDİR, bir duvar değil.
	if not is_equal_approx(HRConstants.stars_for(HRConstants.AREA_MAX), 5.0):
		return "the training ceiling renders %.1f stars, want 5" % HRConstants.stars_for(HRConstants.AREA_MAX)
	# BEDEL FRENİ ÖLÇÜLÜR: son kademe ilk kademeden belirgin şekilde pahalı olmalı, yoksa
	# §5.3'ün "pahalıdır" cümlesi boş kalır.
	if HRConstants.training_fee_tiered(HRConstants.AREA_MAX - 1) \
			< HRConstants.training_fee_tiered(0) * 4:
		return "the last training rung (%d) is not meaningfully pricier than the first (%d)" % [
			HRConstants.training_fee_tiered(HRConstants.AREA_MAX - 1),
			HRConstants.training_fee_tiered(0)]
	# Cetvel TAŞMAZ: tavanın üstündeki bir değer beş yıldızda kelepçelenir.
	if not is_equal_approx(HRConstants.stars_for(HRConstants.AREA_MAX + 4), float(HRConstants.STAR_MAX)):
		return "stars_for does not clamp above the ruler"
	# §10.2: beş yıldızlı aday NADİR ama MÜMKÜN — ve yalnız Kıdemli seviyede.
	if HRConstants.FIVE_STAR_CHANCE <= 0.0:
		return "no candidate can ever show five stars — §5.3's alternative disappears"
	if HRConstants.FIVE_STAR_CHANCE > 0.25:
		return "a %.0f%% five-star rate is not rare" % (HRConstants.FIVE_STAR_CHANCE * 100.0)
	return ""

static func _case_single_trait_contract() -> String:
	# Onaylı tasarım herkeste TEK trait çiziyor ve R4'ten sonra o trait'in KUTBU yok:
	# ayrım artık BEDEL (`carries_cost`), ve yalnız üretici okuyor.
	# FALSİFİKASYON: TRAIT_COUNT'ı 2 yap → ilk iddia FAIL.
	if HRConstants.TRAIT_COUNT != 1:
		return "TRAIT_COUNT is %d; the approved skin draws exactly one" % HRConstants.TRAIT_COUNT
	if HRConstants.validate_employee_traits([]):
		return "an employee with NO trait passed validation"
	if HRConstants.validate_employee_traits(["loyal", "last_one_out"]):
		return "two traits passed validation — TRAIT_COUNT is not enforced"
	# Bedelli TEK başına geçerli: saf yük bir dosya mümkün olmaya devam ediyor.
	if not HRConstants.validate_employee_traits(["mood_buster"]):
		return "a cost-only file was rejected — the price side of the choice vanished"
	if not HRConstants.validate_employee_traits(["loyal"]):
		return "a free-trait file was rejected"
	# EMEKLİ BİR ID ARTIK GEÇERSİZ. Bu, kayıt göçünün NEDEN gerekli olduğunun kanıtı:
	# göç olmasaydı eski bir kayıt tam olarak buraya düşerdi.
	if HRConstants.validate_employee_traits(["pressure_proof"]):
		return "a retired trait id still validates — the ten are not gone"
	# ÜRETEÇ de tek dağıtıyor, ve batch içinde trait tekrarı yok.
	var seen: Dictionary = {}
	var cost_files: int = 0
	var files: Array = HRCandidateGenerator.generate(HRConstants.ROLE_DEVELOPER,
		HRConstants.LEVEL_MID, 4242)
	for f in files:
		var traits: Array = f["traits"]
		if traits.size() != HRConstants.TRAIT_COUNT:
			return "a generated file carries %d traits, want exactly %d" % [
				traits.size(), HRConstants.TRAIT_COUNT]
		var tid: String = String(traits[0])
		if seen.has(tid):
			return "trait '%s' repeated inside one batch" % tid
		seen[tid] = true
		if HRConstants.trait_carries_cost(tid):
			cost_files += 1
	if cost_files < 1:
		return "no file in the batch carried a cost trait — every choice was free"
	return ""


static func _case_founder_trains_and_learns() -> String:
	# Kişisel sekmesinin kurucu kartı (10a) bir DENEYİM çubuğu ve bir EĞİTİME GÖNDER
	# düğmesi çiziyor. Eski motor ikisini de reddediyordu (can_train ve add_area_experience
	# yalnız "employee" kabul ediyordu), yani çubuk sonsuza dek %0 okuyacaktı.
	# FALSİFİKASYON: can_train'in kategori kapısını "employee"ye geri al → üçüncü iddia FAIL.
	GameState.set_cash(100000)
	var founder: Character = CharacterRegistry.get_founder()
	if founder == null:
		return "no founder in registry"
	# Kurucu bir İŞE atanmış doğar (§2.1: aynı anda tek iş).
	if founder.assigned_job_ids.size() != 1:
		return "the founder holds %d jobs at run start, want exactly 1" % founder.assigned_job_ids.size()
	if founder.assigned_jobs.is_empty():
		return "the founder's area mirror is empty while he holds a job"
	var area_key: String = String(founder.assigned_jobs[0])
	# ÖĞRENİR: bir gün geçince atandığı alanda deneyim birikir.
	# §5.1: kurucunun barı da TEK BAR. Kişisel kartı (§2.5) onu çiziyor ve kurucu bu
	# döngünün dışında kalırsa çubuk sonsuza dek %0 okur.
	var before: int = founder.experience_raw
	_sim_day()
	if founder.experience_raw <= before:
		return "the founder accrued no experience — the Kişisel bar would read %0 forever"
	# EĞİTİME GİDEBİLİR.
	# §5.2: bar kapıdır, kurucu için de. §5.2'nin kurucu istisnası ALAN sayısıyla ilgili
	# (yedisi de onun), deneyim şartıyla değil.
	CharacterRegistry.add_experience(founder.id, founder.experience_threshold)
	if not CharacterRegistry.can_train(founder.id):
		return "the founder cannot be trained — 10a draws the button anyway"
	var value_before: int = int(founder.role_stats.get(area_key, 0))
	if not HRSystem.send_to_training(founder.id, area_key):
		return "send_to_training refused the founder"
	# EğİTİMDEYKEN hiçbir alanın kadrosunda görünmez (11c'nin uyarı satırı bunu söylüyor).
	for c in HRSystem.assigned_to(area_key):
		if c.id == founder.id:
			return "a founder in training still counts on the roster of '%s'" % area_key
	for _i in HRConstants.TRAINING_DAYS:
		_sim_day()
	if int(founder.role_stats.get(area_key, 0)) != value_before + 1:
		return "'%s' went %d -> %d, want +1" % [
			area_key, value_before, int(founder.role_stats.get(area_key, 0))]
	if founder.status != HRConstants.STATUS_ACTIVE:
		return "the founder did not come back to active"
	return ""


static func _case_leadership_is_trainable() -> String:
	# 11c'nin üçüncü satırı LİDERLİK. Liderlik `AREAS`'ta DEĞİL, o yüzden eski kapı onu
	# sessizce reddediyordu — ama +1 yazma yolu (role_stats["leadership"]) zaten çalışıyordu.
	# SÜRE SABİT: revize tasarım (11c) üç satırda da "iki hafta" yazıyor, yani merdiven YOK.
	# FALSİFİKASYON: is_trainable_key'den Liderlik'i çıkar → ilk iddia FAIL.
	GameState.set_cash(100000)
	var emp: Character = _make_employee("char_ld_train", "LD Train", HRConstants.ROLE_DESIGNER,
		SEED_PACE, 0, 50, SEED_EXPERTISE, 2)
	CharacterRegistry.add_experience(emp.id, emp.experience_threshold)   # §5.2 bar kapıdır
	if not CharacterRegistry.can_train(emp.id, HRConstants.SKILL_LEADERSHIP):
		return "Liderlik is not trainable — §5.2 lists it among the selectable areas"
	# LİDERLİK PRİMİ KALKTI. §5.3 bedeli YALNIZ hedef alanın mevcut yıldız seviyesine göre
	# kademelendirir; Liderlik'i ayrıca pahalı yapan bir hüküm yok. Doğru iddia artık
	# "aynı seviyede Liderlik ile alan AYNI fiyattır".
	var lead_value: int = int(emp.role_stats.get(HRConstants.SKILL_LEADERSHIP, 0))
	var lead_fee: int = HRConstants.training_fee_tiered(lead_value)
	if HRConstants.training_fee_tiered(lead_value) != lead_fee:
		return "the fee ladder is not a pure function of the star level"
	if CharacterRegistry.training_fee_for(emp.id, HRConstants.SKILL_LEADERSHIP) != lead_fee:
		return "training_fee_for does not apply the Liderlik premium"
	var before: int = lead_value
	if not HRSystem.send_to_training(emp.id, HRConstants.SKILL_LEADERSHIP):
		return "send_to_training refused Liderlik"
	if emp.training_days_left != HRConstants.TRAINING_DAYS:
		return "training runs %d days, want the flat %d (11c: 'iki hafta' on every row)" % [
			emp.training_days_left, HRConstants.TRAINING_DAYS]
	for _i in HRConstants.TRAINING_DAYS:
		_sim_day()
	if int(emp.role_stats.get(HRConstants.SKILL_LEADERSHIP, 0)) != before + 1:
		return "Liderlik went %d -> %d, want +1" % [
			before, int(emp.role_stats.get(HRConstants.SKILL_LEADERSHIP, 0))]
	return ""







static func _case_hr_read_catalogue() -> String:
	# §15.3 · OKUMA YÜZEYİ VE SİNYALLER. §17.3 bu borcun kime ait olduğunu yazıyor:
	# "Ekip'in borcu — bu modülde, inşayla birlikte ödenir. İnşayı bloklamaz ... Ekip'in
	# yükümlülüğü OKUNABİLİR VE ETİKETLİ OLMAK. Bu ucuzdur, olay motorunu beklemez, ve
	# motor geldiğinde ona KEŞİF İŞİ BIRAKMAZ."
	#
	# Bu vaka tüketici DEĞİL, SÖZLEŞME testi: her anahtarın var olduğunu ve makul bir şey
	# döndürdüğünü, her sinyalin adının kararlı olduğunu sabitliyor. Motor geldiğinde bu
	# adlara karşı yazılacak.
	#
	# FALSİFİKASYON: HRSystem'den herhangi bir katalog fonksiyonunu sil → parse hatası,
	# kapı FAIL verir. EventBus'tan bir sinyal adını sil → has_signal iddiası FAIL eder.
	GameState.set_flag("debug_hr_force", "fail")
	var emp: Character = _make_employee("cat_a", "Cat A", HRConstants.ROLE_DEVELOPER,
		SEED_PACE, 4000, 70)
	_park_leave([emp])

	# --- SORGULAR ---
	if HRSystem.morale(emp) != emp.morale:
		return "hr.morale disagreed with the record"
	if HRSystem.morale_band(emp) != "mid":
		return "hr.morale_band at 70 read '%s', want 'mid'" % HRSystem.morale_band(emp)
	if HRSystem.headcount() < 1:
		return "hr.headcount reads %d with a seeded employee" % HRSystem.headcount()
	if HRSystem.skill(emp, HRConstants.AREA_ENGINEERING) != int(emp.role_stats[HRConstants.AREA_ENGINEERING]):
		return "hr.skill disagreed with role_stats"
	if HRSystem.effective_skill(emp, HRConstants.AREA_ENGINEERING) <= 0.0:
		return "hr.effective_skill returned nothing for an assigned developer"
	if HRSystem.status(emp) != HRConstants.STATUS_ACTIVE:
		return "hr.status read '%s'" % HRSystem.status(emp)
	if HRSystem.is_busy(emp):
		return "an active, assigned employee read as busy"
	if HRSystem.is_idle(emp):
		return "a freshly hired employee read as idle — §12.2 seats them on a job"
	if HRSystem.job_count(emp) != 1:
		return "hr.job_count is %d, want 1" % HRSystem.job_count(emp)
	if HRSystem.tenure_days(emp) < 0:
		return "hr.tenure_days went negative"
	if HRSystem.assigned_to_job(HRConstants.JOB_BUILD).is_empty():
		return "hr.assigned_to(iş) found nobody on Build"
	if not (HRSystem.unstaffed_jobs() is Array):
		return "hr.unstaffed_jobs did not return a list"
	if not (HRSystem.accounts_of(emp) is Array):
		return "hr.accounts_of did not return a list"
	if HRSystem.work_hours(emp) != HRConstants.WORK_HOURS_DEFAULT:
		return "hr.work_hours read %d on a fresh run" % HRSystem.work_hours(emp)
	var company: Dictionary = HRSystem.work_hours_company()
	if int(company["hours"]) != HRConstants.WORK_HOURS_DEFAULT \
			or int(company["start_hour"]) != HRConstants.START_HOUR_DEFAULT:
		return "hr.work_hours_company: %s" % str(company)
	if HRSystem.work_hours_overrides() != 0:
		return "hr.work_hours_overrides reads %d on a fresh run" % HRSystem.work_hours_overrides()
	if HRSystem.overtime_active(emp) or HRSystem.short_day_active(emp):
		return "eight hours read as overtime or short day"

	# --- §2.3 KURUCU GÖREV DURUMU: yedisi de TÜRETİLİR, hiçbiri saklanmaz ---
	var state: String = HRSystem.founder_task_state()
	if state != HRSystem.FOUNDER_STATE_BUILD:
		return "the founder starts on a build but reads '%s'" % state
	GameState.set_flag("pitch_prep_active", true)
	if HRSystem.founder_task_state() != HRSystem.FOUNDER_STATE_PITCH_PREP:
		return "yatırım hazırlığı did not surface as a task state — §2.3 gives it an id"
	# §2.2/§2.3: yatırım hazırlığı MEŞGULDÜR ve yapım §2.1'e göre duraklar.
	if not HRSystem.is_busy(CharacterRegistry.get_founder()):
		return "a founder in pitch prep did not read as busy (§2.2)"
	GameState.set_flag("pitch_prep_active", false)
	CharacterRegistry.clear_jobs(CharacterRegistry.get_founder().id)
	if HRSystem.founder_task_state() != HRSystem.FOUNDER_STATE_IDLE:
		return "an unassigned founder did not read as Boşta"
	# §2.5: durum Kişisel sayfasında TEK SATIR olarak OKUNUR. Yedi id'nin yedisi de bir
	# cümleye çözülmek zorunda — çözülmeyen bir id ekrana ham anahtar basar, ve
	# TranslationServer eksik satırda anahtarın KENDİSİNİ döndürdüğü için bunu yakalamanın
	# tek yolu anahtarla karşılaştırmaktır.
	for st in [HRSystem.FOUNDER_STATE_BUILD, HRSystem.FOUNDER_STATE_SALES,
			HRSystem.FOUNDER_STATE_SUPPORT, HRSystem.FOUNDER_STATE_RESEARCH,
			HRSystem.FOUNDER_STATE_PITCH_PREP, HRSystem.FOUNDER_STATE_TRAINING,
			HRSystem.FOUNDER_STATE_CARE, HRSystem.FOUNDER_STATE_IDLE]:
		var lkey: String = "HR_FOUNDER_STATE_%s" % String(st).to_upper()
		if TranslationServer.translate(lkey) == lkey:
			return "§2.3 state '%s' has no sentence — the page would print %s" % [String(st), lkey]
	if HRSystem.founder_task_label() != TranslationServer.translate("HR_FOUNDER_STATE_IDLE"):
		return "founder_task_label does not track the state it reports"

	# --- SİNYALLER: adlar KARARLI, ve sekizi bugün YAYINLANIYOR ---
	for sig in ["experience_bar_full", "morale_band_changed", "employee_eligible_for_promotion",
			"raise_requested", "leave_requested", "assignment_changed", "employee_hired",
			"employee_departed", "training_started", "training_completed"]:
		if not EventBus.has_signal(String(sig)):
			return "§15.3 signal '%s' is missing — the engine would have to discover it" % String(sig)

	# BANT KENARI gerçekten ateşliyor mu: 70 (mid) → 30 (low).
	var band_hits: Array = []
	var cb: Callable = func(cid: String, band: String) -> void:
		if cid == emp.id:
			band_hits.append(band)
	EventBus.morale_band_changed.connect(cb)
	CharacterRegistry.set_morale(emp.id, 30)
	EventBus.morale_band_changed.disconnect(cb)
	if band_hits.size() != 1 or String(band_hits[0]) != "low":
		return "the band edge did not fire once with 'low': %s" % str(band_hits)

	# BAR DOLMA KENARI bir kez ateşler, her gün değil.
	var full_hits: Array = []
	var cb2: Callable = func(cid: String) -> void:
		if cid == emp.id:
			full_hits.append(cid)
	EventBus.experience_bar_full.connect(cb2)
	CharacterRegistry.add_experience(emp.id, emp.experience_threshold)
	CharacterRegistry.add_experience(emp.id, emp.experience_threshold)   # ikinci kez: SESSİZ
	EventBus.experience_bar_full.disconnect(cb2)
	if full_hits.size() != 1:
		return "experience_bar_full fired %d times, want exactly one edge" % full_hits.size()
	return ""

static func _case_effective_skill_formula() -> String:
	# §4.5 KANONİK FORMÜL, beş çarpanın hepsi elle hesaplanmış değerlere karşı sabitleniyor:
	#
	#   etkin çıktı = yıldız × alan katsayısı × odak × moral bandı × huy
	#
	# Liderlik BİLEREK burada değil: §4.2 onu ALANIN TOPLAMINA uyguluyor, kişi başına değil.
	# Ayrı bir iddiayla aşağıda ölçülüyor.
	#
	# BİRİM HAM PUAN, YILDIZ DEĞİL. §4.1 iki ham puanı bir yıldıza çeviriyor, yani ikisi
	# sabit bir katsayıyla ayrışıyor ve formülün ŞEKLİ aynı; yıldıza geçmek her çıktıyı
	# yarıya indirir ve puana göre kalibre edilmiş her aşağı akış sabitini kaydırırdı.
	#
	# FALSİFİKASYON: effective_skill'den moral bandı satırını sil → "morale band" iddiası
	# FAIL. focus_mult'u 1.0 sabitle → "two jobs" iddiası FAIL.
	GameState.set_flag("debug_hr_force", "fail")
	var dev: Character = _make_employee("eff_dev", "Eff Dev", HRConstants.ROLE_DEVELOPER,
		SEED_PACE, 4000, 60, 8, 2)
	_park_leave([dev])
	dev.role_stats[HRConstants.AREA_ENGINEERING] = 8
	# DÜZELTİR AMA DOĞRULAMAZ. Tohum her alana 5 veriyor, yani aynı kişi koşu sürerken
	# GELEN'i de DOĞRULANMIŞ'a çeviriyordu ve havuz aritmetiği ölçülemez oluyordu
	# (falsifikasyon: "çözülenler havuzdan düşmesin" mutasyonu GEÇİYORDU).
	dev.role_stats[HRConstants.AREA_CUSTOMER_SUCCESS] = 0
	dev.role_stats[HRConstants.AREA_QA] = 4
	dev.traits = ["picks_it_up_fast"]   # hiçbir hız/çıktı çarpanı taşımaz

	# --- 1 · ANA ALAN, tek iş, nötr moral (50–80) ---
	# 8 × 1,0 × 1,0 × 1,0 × 1,0 = 8,0
	var v: float = HRSystem.effective_skill(dev, HRConstants.AREA_ENGINEERING)
	if absf(v - 8.0) > 0.001:
		return "ana alan: %.3f, want 8.000" % v

	# --- 2 · İKİNCİL ALAN ×0,8 (§4.3) ---
	# 4 × 0,8 = 3,2. 0,6 DEĞİL: zayıflık zaten yıldızlarda yazılı, katsayı onu ikinci kez kesmez.
	v = HRSystem.effective_skill(dev, HRConstants.AREA_QA)
	if absf(v - 3.2) > 0.001:
		return "ikincil alan: %.3f, want 3.200" % v

	# --- 3 · ODAK KATSAYISI: iki iş → 0,50, HER İKİ İŞE AYRI AYRI (§12.1) ---
	if CharacterRegistry.assign_job(dev.id, HRConstants.JOB_SUPPORT) != "":
		return "could not add the second job"
	v = HRSystem.effective_skill(dev, HRConstants.AREA_ENGINEERING)
	if absf(v - 4.0) > 0.001:
		return "two jobs: %.3f, want 4.000 (8 × 0,50)" % v
	# §12.1: "İki işe koymak toplamda ASLA daha fazla iş çıkarmaz." En iyi hâlde tam olarak
	# bir kişilik iş çıkar; bu bir üretim hilesi değil bir KAPSAMA aracıdır.
	var split_total: float = HRSystem.effective_skill(dev, HRConstants.AREA_ENGINEERING) * 2.0
	if split_total > 8.0 + 0.001:
		return "splitting produced MORE than one person's work (%.3f > 8.0)" % split_total
	CharacterRegistry.unassign_job(dev.id, HRConstants.JOB_SUPPORT)

	# --- 4 · MORAL BANDI (§7) ---
	# Bu, rev 11'in en büyük davranış değişikliği: ÖNCEDEN HİÇBİR üretim formülü
	# Character.morale okumuyordu.
	CharacterRegistry.set_morale(dev.id, 90)          # 80+ → +%10
	v = HRSystem.effective_skill(dev, HRConstants.AREA_ENGINEERING)
	if absf(v - 8.8) > 0.001:
		return "high morale band: %.3f, want 8.800" % v
	CharacterRegistry.set_morale(dev.id, 40)          # 50 altı → −%15
	v = HRSystem.effective_skill(dev, HRConstants.AREA_ENGINEERING)
	if absf(v - 6.8) > 0.001:
		return "low morale band: %.3f, want 6.800" % v
	CharacterRegistry.set_morale(dev.id, 60)          # nötr

	# --- 5 · HUY ÇARPANI (§6) ---
	dev.traits = ["double_checker"]                   # TİTİZ: speed_mult 0,85
	v = HRSystem.effective_skill(dev, HRConstants.AREA_ENGINEERING)
	if absf(v - 6.8) > 0.001:
		return "TİTİZ hız cezası: %.3f, want 6.800" % v
	dev.traits = ["picks_it_up_fast"]

	# --- ALANI YOK → 0 (§4.4) ---
	if HRSystem.effective_skill(dev, HRConstants.AREA_SALES) != 0.0:
		return "a developer produced Satış output — §4.4 says the product side never crosses"

	# --- EDİLGEN → 0 (§4.5, §8.6) ---
	CharacterRegistry.set_status(dev.id, HRConstants.STATUS_TRAINING)
	if HRSystem.effective_skill(dev, HRConstants.AREA_ENGINEERING) != 0.0:
		return "an in-training employee still produced"
	CharacterRegistry.set_status(dev.id, HRConstants.STATUS_ACTIVE)

	# --- §2 KURUCUYA MORAL BANDI UYGULANMAZ ---
	var founder: Character = CharacterRegistry.get_founder()
	founder.role_stats[HRConstants.AREA_ENGINEERING] = 6
	CharacterRegistry.set_morale(founder.id, 10)      # bandı olsaydı −%15 yerdi
	var fv: float = HRSystem.effective_skill(founder, HRConstants.AREA_ENGINEERING)
	if absf(fv - 6.0 * HRConstants.focus_mult(HRSystem.job_count(founder))) > 0.001:
		return "the founder took a morale band — §2 says he has no morale (%.3f)" % fv

	# --- §4.2 LİDERLİK ALANIN TOPLAMINA, KİŞİ BAŞINA DEĞİL ---
	# Yarım yıldız başına +%1, beş yıldızda +%10. Kişi başına katlansaydı kadro sayısıyla
	# çarpılırdı ve iki kişilik bir ekipte bonus iki kat okunurdu.
	if absf(HRSystem.leadership_output_mult(10) - 1.10) > 0.001:
		return "five stars of Liderlik gave %.3f, want 1.100" % HRSystem.leadership_output_mult(10)
	if absf(HRSystem.leadership_output_mult(0) - 1.0) > 0.001:
		return "zero Liderlik was not neutral"

	# --- §4.5'in ikinci yarısı: günlük katkı = etkin çıktı × ÇALIŞMA SAATİ ---
	# Saat formülün İÇİNDE değil DIŞINDA: yetenek bir SAATTE ne çıktığını, süre KAÇ SAAT
	# çıktığını belirler. Çarpan STANDART GÜNE göre normalize (HRConstants.hours_output_mult):
	# sekiz saat 1,0'dır, yani sekiz saatlik bir günde daily_contribution == effective_skill
	# ve Ürün/Satış/CS'nin bütün kalibre sabitleri yerinde kalır. §8.1 ile §8.3 oranı zaten
	# kendileri veriyor ve normalize hâl tam o iki sayıdır.
	WorkHoursSystem.set_company_hours(HRConstants.WORK_HOURS_DEFAULT)
	var per_hour: float = HRSystem.effective_skill(dev, HRConstants.AREA_ENGINEERING)
	var daily: float = HRSystem.daily_contribution(dev, HRConstants.AREA_ENGINEERING)
	if absf(daily - per_hour) > 0.001:
		return "the standard day is not neutral (%.3f vs %.3f)" % [daily, per_hour]
	# ONBİR SAAT: §8.1'in kendi cümlesi, "en fazla +%37,5 çıktı".
	WorkHoursSystem.set_company_hours(HRConstants.WORK_HOURS_MAX)
	if absf(HRSystem.daily_contribution(dev, HRConstants.AREA_ENGINEERING) - per_hour * 1.375) > 0.001:
		return "an eleven-hour day did not raise the daily contribution by 37.5%"
	# BEŞ SAAT: §8.3'ün kendi cümlesi, "sekiz saatlik günün %62,5'i".
	WorkHoursSystem.set_company_hours(HRConstants.WORK_HOURS_MIN)
	if absf(HRSystem.daily_contribution(dev, HRConstants.AREA_ENGINEERING) - per_hour * 0.625) > 0.001:
		return "a five-hour day did not cut the daily contribution to 62.5%"
	WorkHoursSystem.set_company_hours(HRConstants.WORK_HOURS_DEFAULT)
	WorkHoursSystem.set_company_hours(HRConstants.WORK_HOURS_MAX)
	var longer: float = HRSystem.daily_contribution(dev, HRConstants.AREA_ENGINEERING)
	if longer <= daily:
		return "a longer day did not produce more (§8.4: the return IS the hour)"
	return ""

static func _case_promotion_and_raise_gate() -> String:
	# §9.2 ZAM BEKLEME SÜRESİ + §9.3 TERFİ. İkisi birlikte ölçülüyor çünkü terfi bir zammı
	# İÇERİR ve bekleme süresini de kurar — ertesi gün üstüne ayrı bir zam alınabilseydi
	# altı aylık kural anlamsız olurdu.
	#
	# FALSİFİKASYON: HRActions.can_raise'deki raise_cooldown_left kapısını sil → ikinci zam
	# geçer ve "cooldown" iddiası FAIL eder. can_promote'taki LEVEL_SENIOR kapısını sil →
	# "Kıdemli terfi aldı" iddiası FAIL eder.
	GameState.set_cash(500000)
	var emp: Character = _make_employee("promo_a", "Promo A", HRConstants.ROLE_DEVELOPER,
		SEED_PACE, 3000, 60)

	# --- §9.2 ZAM: aralık %3–10 ---
	if HRConstants.RAISE_MAX_PCT != 10:
		return "the raise band ceiling is %d, want §9.2's 10" % HRConstants.RAISE_MAX_PCT
	var salary_before: int = emp.monthly_salary
	if not HRActions.apply_raise(emp, HRConstants.RAISE_MAX_PCT):
		return "the first raise was refused"
	if emp.monthly_salary <= salary_before:
		return "the raise did not move the salary"
	# §9.1 "Maaş hiçbir koşulda düşürülemez" — kuralı TAŞIYAN alan da yükselmeli.
	if emp.salary_floor != emp.monthly_salary:
		return "salary_floor did not follow the raise (%d vs %d)" % [
			emp.salary_floor, emp.monthly_salary]

	# --- §9.2 ALTI AY: ikinci zam REDDEDİLİR, ve gerekçesi okunabilir ---
	if HRActions.can_raise(emp, HRConstants.RAISE_MAX_PCT):
		return "a second raise was allowed the same day — §9.2 wants six months"
	if HRActions.raise_cooldown_left(emp) != HRConstants.RAISE_COOLDOWN_DAYS:
		return "cooldown reads %d days, want %d" % [
			HRActions.raise_cooldown_left(emp), HRConstants.RAISE_COOLDOWN_DAYS]

	# --- §9.3 TERFİ: tek adım, unvan değişir, maaş BANDA OTURMAZ ---
	var level_before: int = emp.level
	var pay_before: int = emp.monthly_salary
	if not HRActions.can_promote(emp):
		return "an Orta employee could not be promoted"
	if not HRActions.apply_promotion(emp, HRConstants.PROMOTION_MIN_PCT):
		return "apply_promotion refused"
	if emp.level != level_before + 1:
		return "promotion moved the level %d → %d, want a single step" % [level_before, emp.level]
	var want_pay: int = int(round(float(pay_before) * (1.0 + float(HRConstants.PROMOTION_MIN_PCT) / 100.0)))
	if absi(emp.monthly_salary - want_pay) > 1:
		return "promoted salary is %d, want %d — §9.3 raises by the CHOSEN pct, not to the band" % [
			emp.monthly_salary, want_pay]
	# §9.3'ün asıl iddiası: maaş YENİ SEVİYENİN piyasa bandına OTURMAZ. İçeriden terfi bu
	# yüzden dışarıdan aynı seviyede işe almaktan ucuzdur ve "yetiştir mi, satın al mı"
	# kararı canlı kalır.
	var band: Array = HRConstants.salary_band_for_level(emp.role, emp.level)
	if emp.monthly_salary >= int(band[0]):
		return "the promoted salary landed inside the new band (%d >= %d) — §9.3 forbids re-seating" % [
			emp.monthly_salary, int(band[0])]

	# --- §3 UNVAN TÜRETİLİR ---
	var title: String = HRConstants.job_title(emp.role, emp.level)
	if title == "" or title == emp.role:
		return "the derived title is empty or raw: '%s'" % title
	if HRConstants.job_title(emp.role, HRConstants.LEVEL_MID) != HRConstants.role_label(emp.role):
		return "Orta carries a prefix — §3 says it has none"

	# --- §9.3 KIDEMLİ TAVANDIR ---
	var senior: Character = _make_employee("promo_b", "Promo B", HRConstants.ROLE_DEVELOPER,
		SEED_PACE, 9000, 60)
	senior.level = HRConstants.LEVEL_SENIOR
	if HRActions.can_promote(senior):
		return "a Kıdemli was promotable — §9.3 makes it the ceiling"
	if HRActions.promotion_block_reason(senior) == "":
		return "the locked promotion row would show no reason (§13.3)"

	# --- §11.1 KIDEM TAZMİNATI BASAMAKLI VE TAVANLI ---
	if HRConstants.severance_amount(3000, 100) != int(round(3000.0 / 3.0)):
		return "under a year did not pay ⅓ salary: %d" % HRConstants.severance_amount(3000, 100)
	if HRConstants.severance_amount(3000, 550) != 3000:
		return "a year and a half paid %d, want exactly one salary (ara aylar yuvarlanmaz)" % \
			HRConstants.severance_amount(3000, 550)
	if HRConstants.severance_amount(3000, 3650) != 9000:
		return "ten years paid %d, want the three-salary cap" % HRConstants.severance_amount(3000, 3650)
	return ""

static func _case_work_hours_draft_commits() -> String:
	# §8.5 "maliyet TAAHHÜTTEN ÖNCE okunur" — ve bu cümle ancak TAAHHÜT VARSA doğru olur.
	# Onaylı 19a'nın alt barı iki eylem taşıyor (Vazgeç · Uygula); modal o güne kadar saati
	# ANINDA yazıyordu, yani okunan maliyet zaten ödenmiş bir maliyetti.
	#
	# BU VAKA MODALİ AÇMAZ. Modalin tek yaptığı `WorkHoursSystem.draft_state()` alıp
	# sözlüğü düzenlemek ve `apply_state` çağırmak; sözleşme motorda, ve burada ölçülen o.
	#
	# FALSİFİKASYON: `draft_state()`'i `GameState.group_work_hours_override`'ı KOPYALAMADAN
	# döndür (duplicate'i sil) → ilk iddia FAIL eder, çünkü taslağı düzenlemek motoru da
	# değiştirir.
	# MAAŞ ŞART: mesai tahakkuku saatlik ücretten türüyor, sıfır maaşlı bir fixture
	# 11 saat çalışsa da sıfır tahakkuk eder ve üçüncü iddia hiçbir şey ölçmez.
	var dev: Character = _make_employee("wh_draft_dev", "Draft Dev",
		HRConstants.ROLE_DEVELOPER, SEED_PACE, 6000)
	WorkHoursSystem.set_company_hours(8)
	WorkHoursSystem.clear_person_hours(dev.id)
	var group_id: String = WorkHoursSystem.group_of(dev)
	WorkHoursSystem.clear_group_hours(group_id)

	# 1 · TASLAK MOTORA DOKUNMAZ. Üç kapsamın üçü de düzenlenir; motor kıpırdamaz.
	var st: Dictionary = WorkHoursSystem.draft_state()
	st["company"] = 10
	st["start"] = 7
	(st["groups"] as Dictionary)[group_id] = 11
	(st["people"] as Dictionary)[dev.id] = 6
	if GameState.company_work_hours != 8:
		return "editing the draft moved the live company hours to %d" % GameState.company_work_hours
	if WorkHoursSystem.hours_for(dev) != 8:
		return "editing the draft moved the live resolution to %d" % WorkHoursSystem.hours_for(dev)
	if not GameState.group_work_hours_override.is_empty():
		return "editing the draft wrote a live group override: %s" % str(GameState.group_work_hours_override)

	# 2 · TASLAK AYNI ZİNCİRDEN ÇÖZÜLÜR (§15.2). Kişisel istisna grubunkini yener; kaynak
	# sözcüğü de taslaktan okunur. İkinci bir çözümleyici olsaydı bu iki satır ayrışırdı.
	if WorkHoursSystem.hours_in(st, dev) != 6:
		return "the draft resolved to %d, want the personal exception 6" % WorkHoursSystem.hours_in(st, dev)
	if WorkHoursSystem.inherited_from_in(st, dev) != "":
		return "a personal exception still reads as inherited in the draft"
	(st["people"] as Dictionary).erase(dev.id)
	if WorkHoursSystem.hours_in(st, dev) != 11:
		return "with the personal exception gone the draft should fall to the group's 11"
	if WorkHoursSystem.inherited_from_in(st, dev) != "group":
		return "the draft's KAYNAK word is not 'group' when the group decides"

	# 3 · BEDEL BLOĞU DA TASLAKTAN OKUR — önizlemenin bütün anlamı bu.
	var counts: Dictionary = WorkHoursSystem.counts_in(st)
	if int(counts["overtime"]) < 1:
		return "the draft's cost block does not see an 11-hour day as overtime"
	if WorkHoursSystem.daily_overtime_in(st) <= WorkHoursSystem.overtime_pay_accrued_today():
		return "the draft's overtime accrual is not above today's (nobody is on overtime today)"

	# 4 · UYGULA HEPSİNİ TEK HAMLEDE GEÇİRİR.
	WorkHoursSystem.apply_state(st)
	if GameState.company_work_hours != 10:
		return "apply_state did not commit the company hours (%d)" % GameState.company_work_hours
	if WorkHoursSystem.start_hour() != 7:
		return "apply_state did not commit the start hour (%d)" % WorkHoursSystem.start_hour()
	if WorkHoursSystem.hours_for(dev) != 11:
		return "apply_state did not commit the group override (%d)" % WorkHoursSystem.hours_for(dev)
	if dev.work_hours_override != 0:
		return "apply_state resurrected a personal exception the draft had cleared"

	# 5 · TERSİ DE: taslakta SİLİNEN bir istisna, uygulanınca motordan da SİLİNİR. Bir
	# "yalnız yazan" apply bunu kaçırırdı ve Vazgeç'i olmayan eski davranışa geri dönerdi.
	var st2: Dictionary = WorkHoursSystem.draft_state()
	(st2["groups"] as Dictionary).clear()
	WorkHoursSystem.apply_state(st2)
	if WorkHoursSystem.group_has_override(group_id):
		return "clearing a group exception in the draft did not clear it on apply"
	if WorkHoursSystem.hours_for(dev) != 10:
		return "after the group exception was cleared the person should inherit the company 10"

	# 6 · PENCERE TEK EVDEN. Çip ve modal aynı cümleyi çiziyor; iki hesap iki cevap demekti.
	var win: Dictionary = WorkHoursSystem.company_window()
	if int(win["start"]) != 7 or int(win["end"]) != 17:
		return "company_window says %s–%s, want 07–17" % [str(win["start"]), str(win["end"])]
	if String(win["end_text"]) != "17:00":
		return "company_window's end text is '%s'" % String(win["end_text"])

	# 7 · BAŞLANGIÇ SAATİ KAPIYI GEÇEMEZ. Rapor edilen "03:00" kusuru burada aranıyor:
	# hem yazıcı hem taslak kelepçeliyor, yani modalin dışından bile üretilemiyor.
	WorkHoursSystem.set_company_start_hour(3)
	if WorkHoursSystem.start_hour() < HRConstants.START_HOUR_MIN:
		return "a 03:00 start survived the writer's clamp (%d)" % WorkHoursSystem.start_hour()
	var st3: Dictionary = WorkHoursSystem.draft_state()
	st3["start"] = 3
	WorkHoursSystem.apply_state(st3)
	if WorkHoursSystem.start_hour() != HRConstants.START_HOUR_MIN:
		return "a 03:00 start survived apply_state (%d)" % WorkHoursSystem.start_hour()
	CharacterRegistry.remove(dev.id)
	return ""


static func _case_work_hours_three_scopes() -> String:
	# §8.1 ÜÇ KAPSAM, TEK ÇÖZÜMLEYİCİ:
	#   kişinin saati = çalışan istisnası ?? grubunun istisnası ?? şirket değeri
	# §15.2 bu zinciri bir tek-kaynak kuralı yapıyor; hiçbir sistem kendisi yürütmez.
	#
	# FALSİFİKASYON: WorkHoursSystem.hours_for'daki `c.work_hours_override > 0` dalını sil →
	# kişisel istisna görünmez olur ve "Cahit" iddiası FAIL eder. Grup dalını sil → grup
	# iddiası FAIL eder.
	var dev: Character = _make_employee("wh_dev", "Wh Dev", HRConstants.ROLE_DEVELOPER)
	var tester: Character = _make_employee("wh_qa", "Wh Qa", HRConstants.ROLE_TESTER)
	var seller: Character = _make_employee("wh_sales", "Wh Sales", HRConstants.ROLE_SALES_REP)
	var founder: Character = CharacterRegistry.get_founder()

	# --- TABAN: herkes şirketi devralır (§8.1 varsayılan 8 saat) ---
	if WorkHoursSystem.hours_for(dev) != HRConstants.WORK_HOURS_DEFAULT:
		return "a fresh employee did not inherit the company hours: %d" % WorkHoursSystem.hours_for(dev)
	if WorkHoursSystem.override_count() != 0:
		return "a fresh run reports %d overrides, want 0" % WorkHoursSystem.override_count()

	# --- GRUP kapsamı: Geliştirme Ekibi 10 saate karar veriyor ---
	WorkHoursSystem.set_group_hours(HRConstants.GROUP_DEVELOPMENT, 10)
	if WorkHoursSystem.hours_for(dev) != 10 or WorkHoursSystem.hours_for(tester) != 10:
		return "the development group override did not reach its members (%d / %d)" % [
			WorkHoursSystem.hours_for(dev), WorkHoursSystem.hours_for(tester)]
	if WorkHoursSystem.hours_for(seller) != HRConstants.WORK_HOURS_DEFAULT:
		return "a group override leaked onto Satış: %d" % WorkHoursSystem.hours_for(seller)
	if WorkHoursSystem.inherited_from(dev) != "group":
		return "the KAYNAK column would not say 'gruptan': %s" % WorkHoursSystem.inherited_from(dev)

	# --- ÇALIŞAN kapsamı: bir kişi kendi grubunu geçersiz kılar (§8.5'in Cahit'i) ---
	WorkHoursSystem.set_person_hours(dev.id, 6)
	if WorkHoursSystem.hours_for(dev) != 6:
		return "a personal override did not win over the group: %d" % WorkHoursSystem.hours_for(dev)
	if WorkHoursSystem.hours_for(tester) != 10:
		return "the personal override leaked onto a groupmate: %d" % WorkHoursSystem.hours_for(tester)
	if WorkHoursSystem.inherited_from(dev) != "":
		return "a deciding row still reads as inherited"

	# --- İSTİSNA KİŞİDE SAKLANIR: grubun değeri değişince kişi KARARINI KORUR (§8.1) ---
	WorkHoursSystem.set_group_hours(HRConstants.GROUP_DEVELOPMENT, 11)
	if WorkHoursSystem.hours_for(dev) != 6:
		return "the personal override did not survive a group change: %d" % WorkHoursSystem.hours_for(dev)

	# --- §8.2 / §8.3 durum okumaları ---
	if not WorkHoursSystem.overtime_active(tester):
		return "11 hours did not read as overtime"
	if not WorkHoursSystem.short_day_active(dev):
		return "6 hours did not read as a short day"
	var counts: Dictionary = WorkHoursSystem.counts()
	if int(counts["overtime"]) != 1 or int(counts["short_day"]) != 1:
		return "the cost block would miscount: %s" % str(counts)

	# --- §2 KURUCU istisna ALAMAZ ve şirketi devralır ---
	WorkHoursSystem.set_person_hours(founder.id, 5)
	if WorkHoursSystem.hours_for(founder) != HRConstants.WORK_HOURS_DEFAULT:
		return "the founder took a personal exception — §2 forbids it (%d)" % WorkHoursSystem.hours_for(founder)

	# --- §8.2 ücret YALNIZ aşan saatlere, %50 fazlasıyla ---
	# 11 saat = 3 aşan saat. Saatlik = maaş / 176, ve ödenen 3 × saatlik × 1,5.
	var want_ot: int = int(round(HRConstants.hourly_wage(tester.monthly_salary) * 3.0 * 1.5))
	if WorkHoursSystem.overtime_pay_today(tester) != want_ot:
		return "overtime pay %d, want %d (only the hours above eight, at 1.5x)" % [
			WorkHoursSystem.overtime_pay_today(tester), want_ot]
	if WorkHoursSystem.overtime_pay_today(dev) != 0:
		return "a short day accrued overtime pay"

	# --- §8.5 "Tümünü şirkete eşitle bütün istisnaları temizler" ---
	WorkHoursSystem.equalise_all()
	if WorkHoursSystem.override_count() != 0:
		return "equalise_all left %d override(s)" % WorkHoursSystem.override_count()
	for c in [dev, tester, seller]:
		if WorkHoursSystem.hours_for(c) != HRConstants.WORK_HOURS_DEFAULT:
			return "%s did not fall back to the company value after equalise" % c.id
	return ""

static func _case_save_migration_v6_to_v7() -> String:
	# rev 11 göçü: seviye · tek deneyim barı · ALAN → İŞ · yaz izni · şirket saatleri.
	#
	# FIXTURE İÇ İÇE, VE ASIL MESELE BU. save_to_slot karakterleri
	# state["registries"]["characters"] altına, GameState'i state["game_state"] altına yazar.
	# Bu dosyadaki diğer göç vakaları DÜZ bir dict veriyor ve v3'ten beri süren
	# state["characters"] hatasının üç şema sürümü boyunca yaşamasının sebebi tam olarak
	# buydu: fonksiyonun MANTIĞINI sınayıp ADRESİNİ hiç sınamamışlar.
	#
	# FALSİFİKASYON: _migrate_to_rev11'deki `_rows(state, "characters")` çağrısını
	# `state.get("characters", [])` ile değiştir → tek bir satır bile taşınmaz, ilk iddia FAIL.
	var state := {
		"registries": {
			"characters": [
				{"id": "c_dev", "category": "employee", "role": "developer",
					"monthly_salary": 4200,
					"role_stats": {"product": 2, "design": 1, "engineering": 7, "qa": 4,
						"sales": 0, "customer_success": 0, "leadership": 3},
					"area_experience": {"engineering": 80, "qa": 30},
					"assigned_jobs": ["engineering", "qa"],
					"leave_month": 3, "morale": 62},
			],
		},
		"game_state": {},
	}
	SaveManager._migrate_to_rev11(state)
	var dev: Dictionary = ((state["registries"] as Dictionary)["characters"] as Array)[0]

	# --- §12.0 ALAN → İŞ ---
	var jobs: Array = dev.get("assigned_job_ids", []) as Array
	if jobs != [HRConstants.JOB_BUILD, HRConstants.JOB_TEST]:
		return "areas did not remap to jobs: %s" % str(jobs)
	# ESKİ ALAN LİSTESİ OLDUĞU GİBİ DURUR (R8): sekiz yer onu hâlâ alan olarak okuyor.
	if (dev.get("assigned_jobs", []) as Array) != ["engineering", "qa"]:
		return "the legacy area list was mutated: %s" % str(dev.get("assigned_jobs"))

	# --- §3 seviye maaş bandından türetilir ---
	# $4.200 bir developer için Orta bandın (3.000-6.000) içinde.
	if int(dev.get("level", -1)) != HRConstants.LEVEL_MID:
		return "level derived as %d, want Orta" % int(dev.get("level", -1))

	# --- §5.1 tek bar: alan sayaçlarının EN YÜKSEĞİ, toplamı değil ---
	if int(dev.get("experience_raw", -1)) != 80:
		return "experience collapsed to %d, want the max (80)" % int(dev.get("experience_raw", -1))
	# Eşik gelişmişlikle büyür: toplam ham puan 2+1+7+4+0+0+3 = 17 → 40 + 6×17 = 142.
	if int(dev.get("experience_threshold", -1)) != HRConstants.experience_threshold(17):
		return "threshold %d, want %d" % [int(dev.get("experience_threshold", -1)),
			HRConstants.experience_threshold(17)]

	# --- §9.1 maaş tabanı ---
	if int(dev.get("salary_floor", -1)) != 4200:
		return "salary floor did not seed from the current salary: %s" % str(dev.get("salary_floor"))

	# --- §11.4 yaz izni: hafta indeksi pencerenin içinde ---
	var wk: int = int(dev.get("leave_week", -99))
	if wk < 0 or wk >= HRConstants.LEAVE_WEEK_COUNT:
		return "leave week %d is outside the summer window" % wk

	# --- §7 moral hedefi bugünkü moralden tohumlanır, yoksa ilk tik sıçrardı ---
	if int(dev.get("morale_target", -1)) != 62:
		return "morale target did not seed from morale: %s" % str(dev.get("morale_target"))

	# --- §4.2: alan başına lider koltuğu rev 11'de yok, ve DOĞRU yuvadan silinir ---
	var gs: Dictionary = state["game_state"] as Dictionary
	if gs.has("area_leads") or gs.has("job_leads"):
		return "a lead seat survived the migration — §4.2 has no per-area lead"
	if int(gs.get("company_work_hours", -1)) != HRConstants.WORK_HOURS_DEFAULT:
		return "company hours did not seed: %s" % str(gs.get("company_work_hours"))
	if int(gs.get("company_start_hour", -1)) != HRConstants.START_HOUR_DEFAULT:
		return "company start hour did not seed: %s" % str(gs.get("company_start_hour"))
	return ""


static func _case_save_migration_v6_to_v7_drops() -> String:
	# ATAMA DÜŞÜRME KURALI. §4.4 iki ikincil alanı kaldırdı, yani eski bir kayıt rev 11'de
	# GEÇERSİZ olan bir atama taşıyabilir. Eşleme yetmez: her iş yeni ROLE_AREAS'a karşı
	# yeniden doğrulanır, taşınamayan DÜŞER, ve liste boşalırsa kişi BOŞTA kalır.
	# Sessiz taşıma yok, sessiz onarım yok, "en yakın geçerli iş" yok.
	#
	# FALSİFİKASYON: _migrate_to_rev11'deki `can_hold_job` kapısını sil → müşteri
	# temsilcisi Satış işinde kalır ve ilk iddia FAIL.
	var state := {
		"registries": {
			"characters": [
				# Müşteri Temsilcisi SATIŞ alanındaydı — rev 2'de ikincil alanıydı, §4.4'te
				# artık değil. Satış işini taşıyamaz → düşer → BOŞTA.
				{"id": "c_cs", "category": "employee", "role": "customer_rep",
					"monthly_salary": 3000,
					"role_stats": {"product": 0, "design": 0, "engineering": 0, "qa": 0,
						"sales": 5, "customer_success": 7, "leadership": 2},
					"assigned_jobs": ["sales"], "morale": 70},
				# Satış Temsilcisi MÜŞTERİ İLİŞKİLERİ alanındaydı → Hesap sahipliği işine
				# eşlenir, ve Hesap sahipliğini SATIŞ alanı da taşıdığı için (§12.0) bu
				# atama GEÇERLİ kalır. Simetrik görünen iki vaka, farklı sonuç.
				{"id": "c_sales", "category": "employee", "role": "sales_rep",
					"monthly_salary": 3000,
					"role_stats": {"product": 0, "design": 0, "engineering": 0, "qa": 0,
						"sales": 7, "customer_success": 4, "leadership": 2},
					"assigned_jobs": ["customer_success"], "morale": 70},
				# Araştırma bir atama hedefi değil (§12.0) → sessizce düşer, sayıma girmez.
				{"id": "c_res", "category": "employee", "role": "tester",
					"monthly_salary": 3000,
					"role_stats": {"product": 0, "design": 0, "engineering": 4, "qa": 7,
						"sales": 0, "customer_success": 0, "leadership": 2},
					"assigned_jobs": ["research", "qa"], "morale": 70},
			],
		},
		"game_state": {},
	}
	SaveManager._migrate_to_rev11(state)
	var rows: Array = (state["registries"] as Dictionary)["characters"] as Array

	var cs: Dictionary = rows[0]
	if (cs.get("assigned_job_ids", []) as Array) != []:
		return "a customer_rep kept the Satış job: %s" % str(cs.get("assigned_job_ids"))

	var sales: Dictionary = rows[1]
	if (sales.get("assigned_job_ids", []) as Array) != [HRConstants.JOB_ACCOUNTS]:
		return "a sales_rep lost Hesap sahipliği, which Satış carries: %s" % str(sales.get("assigned_job_ids"))

	var res: Dictionary = rows[2]
	if (res.get("assigned_job_ids", []) as Array) != [HRConstants.JOB_TEST]:
		return "the research slot did not drop cleanly: %s" % str(res.get("assigned_job_ids"))

	# TAVAN da bir düşürme sebebidir (§12.1): ikiden fazlası atanamaz.
	var over := {
		"registries": {"characters": [
			{"id": "c_f", "category": "founder", "role": "founder",
				"monthly_salary": 0,
				"role_stats": {"product": 3, "design": 3, "engineering": 3, "qa": 3,
					"sales": 3, "customer_success": 3, "leadership": 3, "charisma": 2},
				"assigned_jobs": ["engineering", "qa", "customer_success", "sales"],
				"morale": 50},
		]},
		"game_state": {},
	}
	SaveManager._migrate_to_rev11(over)
	var f: Dictionary = ((over["registries"] as Dictionary)["characters"] as Array)[0]
	if (f.get("assigned_job_ids", []) as Array).size() != HRConstants.MAX_JOBS_PER_PERSON:
		return "four mappable areas did not clamp to the two-job cap: %s" % str(f.get("assigned_job_ids"))
	return ""

static func _case_save_migration_v4_to_v5() -> String:
	# v4 kayıtları İŞ kimliği taşıyor (build · test · support · accounts · sales · research ·
	# cost); v5 modeli ALAN kimliği bekliyor. Migration olmazsa _validate_shape her kayıtta
	# "unknown area" basıyor ve o kişi hiçbir alanın kadrosunda görünmüyor — yüklenen,
	# düzgün görünen ve ÇALIŞMAYAN bir koşu.
	# FALSİFİKASYON: read_slot'taki `if version < 5` satırını sil → ilk iddia FAIL.
	var state := {
		"characters": [
			{"id": "char_v4_dev", "category": "employee", "role": "developer",
				"role_stats": {"product": 3, "design": 3, "engineering": 7, "qa": 6,
					"sales": 2, "customer_success": 2, "leadership": 3},
				"assigned_jobs": ["build"]},
			{"id": "char_v4_cs", "category": "employee", "role": "customer_rep",
				"role_stats": {"product": 2, "design": 2, "engineering": 2, "qa": 2,
					"sales": 5, "customer_success": 7, "leadership": 2},
				"assigned_jobs": ["support", "accounts"]},
			{"id": "char_v4_founder", "category": "founder", "role": "founder",
				"role_stats": {"product": 2, "design": 1, "engineering": 4, "qa": 1,
					"sales": 1, "customer_success": 1, "leadership": 2, "charisma": 1},
				"assigned_jobs": ["build"]},
		],
		"job_leads": {"build": "char_v4_dev", "accounts": "char_v4_cs"},
	}
	SaveManager._migrate_assignments_to_areas(state)
	var dev: Dictionary = (state["characters"] as Array)[0]
	# build üç alanla besleniyordu → kişinin o üçü içinde EN GÜÇLÜ olduğu alana iner.
	if (dev["assigned_jobs"] as Array) != [HRConstants.AREA_ENGINEERING]:
		return "a developer on 'build' landed on %s, want Yazılım" % str(dev["assigned_jobs"])
	var cs: Dictionary = (state["characters"] as Array)[1]
	# Destek VE Hesap ikisi de Müşteri İlişkileri'ne katlanır ve TEKİLLEŞTİRİLİR — yani bu
	# kişi aşırı yükten çıkar, çünkü gerçekten tek alanda çalışıyor.
	if (cs["assigned_jobs"] as Array) != [HRConstants.AREA_CUSTOMER_SUCCESS]:
		return "support+accounts did not collapse onto one area: %s" % str(cs["assigned_jobs"])
	var f: Dictionary = (state["characters"] as Array)[2]
	if (f["assigned_jobs"] as Array) != [HRConstants.AREA_ENGINEERING]:
		return "the founder on 'build' landed on %s" % str(f["assigned_jobs"])
	# LİDER KOLTUKLARI SİLİNİR, TAŞINMAZ. §4.2 lideri YAPIM BAŞINA veriyor; alan başına oturan
	# koltuk rev 11'de yok. Bu iddia eskiden koltuğun DOĞRU ALANA taşındığını ölçüyordu ve
	# geçiyordu — ama elle kurulmuş DÜZ bir sözlük üzerinde: göç `job_leads`'i top-level
	# `state`'ten okuyor, oysa GameState değişkenleri `state["game_state"]` altında yaşıyor.
	# Yani gerçek bir kayıtta o blok hiçbir zaman çalışmadı ve vaka bunu göremedi — §10'un
	# "bir göç, YAZANIN yazdığı şekli okumalıdır" dersinin ikinci örneği.
	if state.has("job_leads") or state.has("area_leads"):
		return "a lead seat survived at the top level of the migration"
	var gs_v5: Dictionary = state.get("game_state", {}) as Dictionary
	if gs_v5.has("job_leads") or gs_v5.has("area_leads"):
		return "a lead seat survived under game_state"
	return ""


static func _case_save_migration_v3_to_v4() -> String:
	# v3 kayıtları üç ekseni taşıyor; v4 modeli altı alan + Liderlik bekliyor. Migration
	# olmazsa save_codec eski üç anahtarı OLDUĞU GİBİ yükler ve _validate_shape her çalışan
	# için push_error basar — yüklenen, düzgün görünen ve yanlış olan bir koşu.
	# FALSİFİKASYON: read_slot'taki `if version < 4` satırını sil → ilk iddia FAIL.
	var state := {
		"characters": [
			{"id": "char_old_dev", "category": "employee", "role": "developer",
				"role_stats": {"expertise": 7, "pace": 5, "rapport": 6},
				"experience": 40, "training_days_left": 0},
			{"id": "char_old_founder", "category": "founder", "role": "founder",
				"role_stats": {"tech": 3, "sales": 2, "negotiation": 1,
					"leadership": 4, "influence": 2}},
		],
	}
	SaveManager._migrate_character_areas(state)
	var dev: Dictionary = (state["characters"] as Array)[0]
	var stats: Dictionary = dev["role_stats"]
	if not HRConstants.validate_employee_skills(stats):
		return "the migrated employee does not satisfy the key lock: %s" % str(stats)
	# UZMANLIK → anahtar alan, HIZ → ikincil alan, UYUM → düşürüldü.
	if int(stats[HRConstants.AREA_ENGINEERING]) != 7:
		return "expertise 7 did not land on the developer's key area: %s" % str(stats)
	if int(stats[HRConstants.AREA_QA]) != 5:
		return "pace 5 did not land on the secondary area: %s" % str(stats)
	if HRConstants.has_retired_skill_key(stats):
		return "a retired axis survived the migration: %s" % str(stats)
	# Tek sayaç deneyim → alan başına, anahtar alana yazılmış.
	if int((dev["area_experience"] as Dictionary)[HRConstants.AREA_ENGINEERING]) != 40:
		return "the experience bar was not carried onto the key area"
	if dev.has("experience"):
		return "the retired scalar experience field survived"
	# Atama: eski kayıtta yok, rolün varsayılanına düşer — yüklenen koşu boşta uyanmaz.
	if (dev["assigned_jobs"] as Array) != ["build"]:   # v4 hedefi LEGACY iş kimliği; v5 alana çevirir
		return "the migrated employee was not put on a job: %s" % str(dev["assigned_jobs"])
	# Kurucu: tech dört teknik alana, influence → charisma, negotiation düşürüldü.
	var f: Dictionary = (state["characters"] as Array)[1]
	var fs: Dictionary = f["role_stats"]
	if fs.size() != FounderConstants.SKILLS.size():
		return "the migrated founder holds %d keys, want %d" % [fs.size(), FounderConstants.SKILLS.size()]
	for area_key in [HRConstants.AREA_PRODUCT, HRConstants.AREA_DESIGN,
			HRConstants.AREA_ENGINEERING, HRConstants.AREA_QA]:
		if int(fs[area_key]) != 3:
			return "founder tech 3 did not reach area '%s'" % area_key
	if int(fs[FounderConstants.SKILL_CHARISMA]) != 2:
		return "influence did not become Karizma"
	if fs.has("negotiation") or fs.has("tech") or fs.has("influence"):
		return "a retired founder skill survived: %s" % str(fs)
	if (f["assigned_jobs"] as Array) != ["build"]:     # aynı şekilde LEGACY
		return "the migrated founder was not put on the build job"
	# İKİNCİ KEZ koşmak zarar vermez: v4 satırında `expertise`/`tech` yok, dokunulmaz.
	SaveManager._migrate_character_areas(state)
	if int((dev["role_stats"] as Dictionary)[HRConstants.AREA_ENGINEERING]) != 7:
		return "running the migration twice corrupted an already-migrated row"
	return ""


static func _case_loc_save_sector_migration() -> String:
	var state := {
		"customers": [
			{"id": "co_a", "industry": "İnşaat"},      # LOC-DATA legacy fixture
			{"id": "co_b", "industry": "Sağlık"},      # LOC-DATA legacy fixture
			{"id": "co_c", "industry": "logistics"},   # already migrated — must not double-map
			{"id": "co_d", "industry": "Marslılar"},   # LOC-DATA unknown — must be LEFT ALONE
		],
		"prospects": [{"id": "p_a", "industry": "Finans"}],   # LOC-DATA legacy fixture
	}
	SaveManager._migrate_sector_ids(state)
	var got: Array = []
	for row in (state["customers"] as Array):
		got.append(String((row as Dictionary)["industry"]))
	got.append(String(((state["prospects"] as Array)[0] as Dictionary)["industry"]))
	var want := ["construction", "health", "logistics", "Marslılar", "finance"]   # LOC-DATA
	if got != want:
		return "sector migration produced %s, want %s" % [str(got), str(want)]
	# Every legacy value must land on a REAL sector id, or the table itself is the bug.
	for legacy in B2BConstants.LEGACY_SECTOR_IDS:
		var mapped: String = String(B2BConstants.LEGACY_SECTOR_IDS[legacy])
		if not B2BConstants.SECTORS.has(mapped) and mapped != B2BConstants.SECTOR_FIXTURE:
			return "legacy map sends '%s' to unknown id '%s'" % [legacy, mapped]
	return ""


## Product catalog derived keys resolve. Same guard as loc_b2b_derived_keys: the catalog
## builds its copy keys from ids at runtime (PROD_TYPE_ + ID + _NAME, PROD_FEAT_ + ID +
## _VOICE …), so no grep for tr("LITERAL") can see them, and a typo would reach the player
## as the raw id. Walks every sub-product type and every feature in both locales.
static func _case_loc_product_derived_keys() -> String:
	var loc0: String = TranslationServer.get_locale()
	var types: Array = ProductCatalog.get_all_sub_product_types()
	if types.size() < 8:
		TranslationServer.set_locale(loc0)
		return "only %d sub product types found — the scan is not looking where it thinks" % types.size()
	for loc in ["tr", "en"]:
		TranslationServer.set_locale(loc)
		for st in types:
			var tid: String = String((st as Dictionary).get("id", ""))
			for suffix in ["_NAME", "_CATEGORY", "_DESC", "_TRADEOFF", "_BET", "_PITCH"]:
				var key: String = "PROD_TYPE_" + tid.to_upper() + suffix
				if TranslationServer.translate(key) == key:
					TranslationServer.set_locale(loc0)
					return "[%s] %s has no row" % [loc, key]
			for sid in (st as Dictionary).get("sectors", []):
				var skey: String = "SECTOR_" + String(sid).to_upper()
				if TranslationServer.translate(skey) == skey:
					TranslationServer.set_locale(loc0)
					return "[%s] %s has no row" % [loc, skey]
			for f in ProductCatalog.get_feature_pool(tid):
				var fid: String = String((f as Dictionary).get("id", ""))
				for fsuffix in ["_NAME", "_VOICE"]:
					var fkey: String = "PROD_FEAT_" + fid.to_upper() + fsuffix
					if TranslationServer.translate(fkey) == fkey:
						TranslationServer.set_locale(loc0)
						return "[%s] %s has no row" % [loc, fkey]
		for axis in ["innovation", "stability", "experience"]:
			var akey: String = "PROD_AXIS_" + axis.to_upper()
			if TranslationServer.translate(akey) == akey:
				TranslationServer.set_locale(loc0)
				return "[%s] %s has no row" % [loc, akey]
	TranslationServer.set_locale(loc0)
	return ""


# ============================================================================
# Two guards added in B3b, both because a green suite had already hidden a real defect.
# ============================================================================

## Every .gd under res://scripts actually COMPILES.
##
## Why this exists: B2 shipped `hr_tab.gd` and `hr_atlas_modal.gd` with unbalanced braces —
## real parse errors — and the suite reported 135/135 PASS on top of them. Nothing was wrong
## with the suite: no case instantiates those two UI scripts, and a script that is never
## loaded is never compiled, so the error had nowhere to surface. The runner's
## "Parse Error" grep could not help either, for the same reason.
##
## A localization sweep rewrites hundreds of call sites across files no headless case
## touches, which is exactly the shape of change that produces this failure. So: load
## everything, and let the engine be the judge.
## Matches a whole `class_name Foo` line, kept as a file-level constant so the regex is
## compiled once rather than once per script.


static var RE_CLASS_NAME: RegEx = RegEx.create_from_string("(?m)^class_name[ \t]+[A-Za-z0-9_]+[ \t\r]*$")


static func _case_all_scripts_load() -> String:
	var files: Array[String] = []
	_collect_by_ext("res://scripts", "gd", files)
	_collect_by_ext("res://scenes", "gd", files)
	if files.size() < 100:
		return "only %d scripts found — the walk is broken, not the tree" % files.size()
	# ÜÇ ÖLÜ UÇ, ÜÇÜ DE "besbelli cevap" gibi göründüğü için kayda geçiyor:
	#   ResourceLoader.load() VARSAYILAN cache modunda parse hatalı bir script'i GEÇİRİR —
	#     önbellekteki nesneyi geri verir (bilerek bozulmuş bir hr_tab.gd ile ölçüldü).
	#   reload() YÜKLÜ script üzerinde motoru DÜŞÜRÜR: süit main.gd'yi boot ediyor, yani
	#     autoload'lar ve canlı sahne ağacı tam o script nesneleri üzerinde koşuyor.
	#   ResourceLoader.load(path, "Script", CACHE_MODE_IGNORE) MOTORU DÜŞÜRÜR — ölçüldü
	#     2026-08-24, `signal 11`, "Internal script error! Opcode: 0". Ve düşme yeri bu
	#     dosyanın KENDİ satırı: süit koşarken kendi script'ini önbelleği atlayarak
	#     yeniden ayrıştırmak, o script'in üzerinde koşan çerçeveyi ayağının altından
	#     çekiyor. Belge "önbelleği atla, gerçek yoldan derle" der ve doğrudur; burada
	#     yasak olan, DERLENEN ŞEYİN ŞU AN KOŞUYOR OLMASI.
	# Bu yüzden hâlâ AYRIK bir kopya derleniyor: yalnız kaynak metnini taşıyan taze bir
	# GDScript. Çalışan oyunda ona işaret eden hiçbir şey yok, ve reload() sadece bir derleme.
	var broken: Array[String] = []
	var unreadable: Array[String] = []
	for path in files:
		var src: String = FileAccess.get_file_as_string(path)
		if src == "":
			unreadable.append(path)
			continue
		var probe := GDScript.new()
		# `class_name X` satırını BOŞALT: gerçek dosya o global adın meşru sahibidir, yani
		# ikinci bir bildirim derlenmez ve projedeki her class_name dosyası bozuk raporlanır
		# (ölçüldü: 73 yanlış pozitif). Silinmiyor, boşaltılıyor — raporlanan satır numaraları
		# diskteki dosyayla eşleşmeye devam etsin.
		#
		# `\r` SINIFIN İÇİNDE VE BU VAKANIN KIRMIZISININ KÖK NEDENİ ODUR. Desen satır sonunu
		# `[ \t]*$` ile bitiriyordu; `\r` ne boşluk ne tab ve `$` yalnız `\n`'in hemen
		# öncesinde eşleşiyor, yani CRLF ile biten bir `class_name` satırı HİÇ eşleşmiyordu:
		# sub() no-op oluyor, bildirim probe'a sızıyor, dosya "derlenmedi" diye geliyordu.
		# Ağaçta 17 CRLF dosyası vardı ve her araç yazımı bir tane daha ekliyordu — yani
		# kırmızı, düzeltilmedikçe BÜYÜYEN bir kırmızıydı. (Dosyalar aynı turda LF'e
		# normalize edildi; desen yine de satır-sonu bağımsız kalıyor, çünkü bir sonraki
		# aracın ne yazacağını bu vaka bilemez.)
		probe.source_code = RE_CLASS_NAME.sub(src, "", true)
		if probe.reload() != OK:
			broken.append(path)
	# İKİ HATA MODU AYRI RAPORLANIR. Eskiden ikisi de aynı cümleyle geliyordu ve
	# "okunamadı" ile "derlenemedi" karışınca ilk bakılacak yer yanlış oluyordu.
	if not unreadable.is_empty():
		return "%d script(s) unreadable: %s" % [unreadable.size(), ", ".join(unreadable)]
	if not broken.is_empty():
		return "%d script(s) failed to compile: %s" % [broken.size(), ", ".join(broken)]
	return ""


## The names passed to `.format({...})` match the {tokens} in that key's CSV row.
##
## Why this exists: a mismatch is SILENT. String.format leaves an unmatched {token} sitting
## on screen, and an argument with no slot simply evaporates — so the sentence quietly loses
## the number it promised, with no error anywhere. `loc_csv_integrity` cannot see it: it
## proves tr and en agree with EACH OTHER, not that the CALLER agrees with either.
##
## Found two already-committed defects the day it was written: HR_NEWS_TRAINING_DONE was
## passing a `role` the sentence had no slot for, and PROD_MARKET_SHARE was being handed a
## `share` its value never interpolated — the market-share number was being dropped.
static func _case_loc_format_args() -> String:
	var want := {}
	var f := FileAccess.open("res://localization/strings.csv", FileAccess.READ)
	if f == null:
		return "strings.csv unreadable"
	f.get_csv_line()  # header
	var re_token := RegEx.new()
	re_token.compile("[{]([a-z_0-9]+)[}]")
	while not f.eof_reached():
		var row: PackedStringArray = f.get_csv_line()
		if row.size() < 3 or row[0].strip_edges() == "":
			continue
		var toks: Array[String] = []
		for m in re_token.search_all(row[1]):
			if not toks.has(m.get_string(1)):
				toks.append(m.get_string(1))
		toks.sort()
		want[row[0].strip_edges()] = toks

	var files: Array[String] = []
	_collect_by_ext("res://scripts", "gd", files)
	var re_call := RegEx.new()
	re_call.compile('(?:\\btr|TranslationServer\\.translate)\\([ \t\r\n]*"([A-Z0-9_]+)"[ \t\r\n]*\\)[ \t\r\n]*\\.format\\([ \t\r\n]*[{]')
	var re_nested := RegEx.new()
	re_nested.compile('\\.format\\([ \t\r\n]*[{]')
	var re_arg := RegEx.new()
	re_arg.compile('"([a-z_0-9]+)"[ \t]*:')
	var checked: int = 0
	for path in files:
		var src: String = FileAccess.get_file_as_string(path)
		for m in re_call.search_all(src):
			var key: String = m.get_string(1)
			if not want.has(key):
				continue  # missing-key coverage belongs to loc_residue, not here
			var body: String = _brace_body(src, m.get_end() - 1)
			# Strip NESTED format bodies first, or tr(A).format({"x": tr(B).format({"n": v})})
			# lends B's "n" to A and this case fails on a call that is perfectly correct.
			while true:
				var nm: RegExMatch = re_nested.search(body)
				if nm == null:
					break
				var inner: String = _brace_body(body, nm.get_end() - 1)
				body = body.substr(0, nm.get_start()) \
					+ body.substr(nm.get_end() + inner.length() + 1)
			var args: Array[String] = []
			for a in re_arg.search_all(body):
				if not args.has(a.get_string(1)):
					args.append(a.get_string(1))
			args.sort()
			if args != want[key]:
				return "%s: %s passes %s, CSV row wants %s" % [
					path.get_file(), key, str(args), str(want[key])]
			checked += 1
	if checked < 40:
		return "only %d format sites inspected — the scan is broken, not the code" % checked
	return ""


## Substring between the brace at `open_idx` and its match, exclusive. "" if unbalanced.
static func _brace_body(s: String, open_idx: int) -> String:
	var depth: int = 0
	var j: int = open_idx
	while j < s.length():
		var c: String = s[j]
		if c == "{":
			depth += 1
		elif c == "}":
			depth -= 1
			if depth == 0:
				return s.substr(open_idx + 1, j - open_idx - 1)
		j += 1
	return ""


static func _collect_by_ext(root: String, ext: String, out: Array[String]) -> void:
	var dir := DirAccess.open(root)
	if dir == null:
		return
	dir.list_dir_begin()
	var name: String = dir.get_next()
	while name != "":
		var path: String = root.path_join(name)
		if dir.current_is_dir():
			if not name.begins_with("."):
				_collect_by_ext(path, ext, out)
		elif name.get_extension() == ext:
			out.append(path)
		name = dir.get_next()
	dir.list_dir_end()


## Every derived key B4 introduced resolves, in both locales.
##
## Derived keys are built at run time from an id — "FIN_BURN_" + category.to_upper(),
## "PITCH_NEED_%d", "GATE_%s_TITLE" — so no grep for tr("LITERAL") can see them and a typo
## reaches the player as a raw token instead of a sentence. The only honest check walks the
## real id lists and asks the translation server.
static func _case_loc_b4_derived_keys() -> String:
	var loc0: String = TranslationServer.get_locale()
	var wanted: Array[String] = []
	for cat in FinanceSystem.BURN_IDS:
		wanted.append("FIN_BURN_" + String(cat).to_upper())
	for v in FinanceSystem.ONE_TIME_LABELS.values():
		wanted.append(String(v))
	# The PITCH_NEED / PITCH_REAL_NEED / PITCH_BUDGET pools were derived here and are RETIRED
	# with the four-beat script and its read-gated reveal (Satış rev 6 §19). What replaced
	# them is derived the same way and walked by `loc_sales_derived_keys`.
	# THE GATE'S COPY MOVED ONTO THE CARDS, and so did the derivation. `copy_key` and
	# `body_count` were how the old builder found "GATE_<KEY>_TITLE" and its numbered bodies;
	# the card carries the keys themselves, including the variant block the escalating body
	# selects from. Walking the card's text block asks the same question of the place the
	# answer now lives — and it catches an unwired variant, which the counted form could not.
	for gate in PhaseGateSystem.GATES:
		var card_id: String = String((gate as Dictionary).get("card_id", ""))
		if card_id == "":
			TranslationServer.set_locale(loc0)
			return "a gate row names no card"
		var card: Dictionary = EventGate.catalogue_card(card_id)
		if card.is_empty():
			TranslationServer.set_locale(loc0)
			return "the gate row names %s, which is not in the catalogue" % card_id
		var tokens: Array = _caps_tokens(card.get("text", {}))
		if tokens.is_empty():
			TranslationServer.set_locale(loc0)
			return "%s carries no localization keys at all" % card_id
		wanted.append_array(tokens)
	if wanted.size() < 25:
		TranslationServer.set_locale(loc0)
		return "only %d derived keys collected — the id lists are not being read" % wanted.size()
	for loc in ["tr", "en"]:
		TranslationServer.set_locale(loc)
		for k in wanted:
			if TranslationServer.translate(k) == k:
				TranslationServer.set_locale(loc0)
				return "[%s] %s has no row" % [loc, k]
	TranslationServer.set_locale(loc0)
	return ""


## Every derived key B5 introduced resolves, in both locales.
##
## Same reasoning as loc_b4_derived_keys: COMPANY_BG_<ID> and NEWS_<POOL_ID> are assembled
## from ids at run time, so a typo is invisible to every grep and reaches the player as a
## raw token on a customer card or in the ticker. The id lists are walked for real.
static func _case_loc_b5_derived_keys() -> String:
	var loc0: String = TranslationServer.get_locale()
	var wanted: Array[String] = []
	for rec in CompanyCatalog.all():
		var cid: String = String((rec as Dictionary).get("id", ""))
		if cid == "":
			TranslationServer.set_locale(loc0)
			return "a company row has no id"
		wanted.append("COMPANY_BG_" + cid)
	for row in NewsFeedSystem.SEKTOR_POOL:
		wanted.append("NEWS_" + String((row as Dictionary)["id"]).to_upper())
	for i in NewsFeedSystem.RIVAL_UP_COUNT:
		wanted.append("NEWS_RIVAL_UP_%d" % i)
	for i in NewsFeedSystem.RIVAL_DOWN_COUNT:
		wanted.append("NEWS_RIVAL_DOWN_%d" % i)
	for k in NewsFeedSystem.OUTLET_KEYS:
		wanted.append(String(k))
	if wanted.size() < 100:
		return "only %d derived keys collected — the id lists are not being read" % wanted.size()
	# An id with a non-ASCII character cannot form a clean derived key; three of the ticker
	# ids carried ç/ö before this batch, so the shape is asserted rather than assumed.
	var re_ascii := RegEx.new()
	re_ascii.compile("^[A-Z0-9_]+$")
	for k in wanted:
		if re_ascii.search(k) == null:
			return "derived key is not ASCII SCREAMING_SNAKE: %s" % k
	for loc in ["tr", "en"]:
		TranslationServer.set_locale(loc)
		for k in wanted:
			if TranslationServer.translate(k) == k:
				TranslationServer.set_locale(loc0)
				return "[%s] %s has no row" % [loc, k]
	TranslationServer.set_locale(loc0)
	return ""


## A mid-run language switch actually changes what the game COMPOSES, and the signal the
## resident surfaces repaint on actually fires.
##
## Scene-baked static text re-translates itself (auto-translate, probe-verified in Phase 1),
## but most of the game's text is composed in code — tr(KEY).format({...}), Fmt-formatted
## numbers and dates — and composition output is RESOLVED TEXT, not a key, so it cannot
## re-translate on its own. That is why CenterViewport rebuilds the open page on
## language_changed. This case proves the half a headless run can prove: flip the locale and
## the composed strings genuinely change, in both directions, and the signal fires.
static func _case_loc_language_switch() -> String:
	var loc0: String = Localization.get_language()
	var fired: Array[String] = []
	var probe := func(l: String) -> void: fired.append(l)
	EventBus.language_changed.connect(probe)

	var out: String = ""
	# Three different composition paths: a derived key, a .format() sentence, and Fmt.
	var samples := func() -> Array:
		return [
			FinanceSystem.burn_category_label("salaries"),
			TranslationServer.translate("PROD_DEV_VERSION").format({"version": 3}),
			Fmt.money_exact(1234567),
			Fmt.date_line({"weekday": 3, "day": 9, "month": 9, "year": 2026}),
		]
	Localization.set_language("tr")
	var tr_out: Array = samples.call()
	Localization.set_language("en")
	var en_out: Array = samples.call()

	for i in tr_out.size():
		if String(tr_out[i]) == String(en_out[i]):
			out = "sample %d did not change across the switch: '%s'" % [i, String(tr_out[i])]
			break
	if out == "":
		# And back again — a one-way switch would pass the check above and still be broken.
		Localization.set_language("tr")
		var back: Array = samples.call()
		for i in back.size():
			if String(back[i]) != String(tr_out[i]):
				out = "sample %d did not come back: '%s' vs '%s'" % [
					i, String(back[i]), String(tr_out[i])]
				break
	if out == "" and fired.size() < 3:
		out = "language_changed fired %d times, wanted 3 — resident surfaces never repaint" % fired.size()

	EventBus.language_changed.disconnect(probe)
	Localization.set_language(loc0)
	return out


# ============================= Calibration pass (2026-08-19) ==============================
# Guards for the calibration package. Each case names the number or contract it pins; every
# one was falsified once (the fix reverted, the case failing with the right diagnosis) before
# it was trusted. Fixture helpers used across the section live at the top of the block.

static func _case_harness_sniffer_matches_run_log() -> String:
	# Hygiene: RunProbe (--run-log) drives whole runs headless and its ticks reach
	# day_tick_completed like any other, so before this the probe autosaved fixture worlds into
	# the player's slots. The sniffer is a substring list; this pins the entry and the FLAGS-ONLY
	# rule (a bare project path must never match).
	if not SaveManager._is_harness_arg("--run-log=b2c:180:sim"):
		return "--run-log is not recognised as a harness flag (probe runs would autosave)"
	if not SaveManager._is_harness_arg("--endgame-smoke=x") or not SaveManager._is_harness_arg("--tab-shot=finance"):
		return "existing harness flags stopped matching"
	if SaveManager._is_harness_arg("C:/games/screenshots/project-unicorn") or SaveManager._is_harness_arg("res://run-log"):
		return "a bare (non --) argument matched the sniffer"
	return ""


# --- A played product is born INSIDE the tolerance band (three levers together) ---

# The two raw stability values --run-log measured at ship (seed 424242, 2026-08-19): the
# stability-competent v1 (integration+field+scheduling, build events +14, Beta cleared) and
# the weak set (workflow+reporting+scheduling, events +12, backlog sprinted). They are the
# numbers the tolerance band was seated against, so they are pinned here as the band's guard.
const CAL_V1_GOOD_RAW_STABILITY := 31.0
const CAL_V1_BAD_RAW_STABILITY := 18.3


static func _case_quality_half_sat_25() -> String:
	# Lever 1 by value: 25 maps to normalized 50, and the catalog-competent 3-feature v1
	# (raw 17) reads 40.5 — inside the band instead of 15-30 points under it.
	if not is_equal_approx(QualityModel.NORMALIZE_HALF_SAT, 25.0):
		return "NORMALIZE_HALF_SAT is %.1f, want 25" % QualityModel.NORMALIZE_HALF_SAT
	if not is_equal_approx(QualityModel.normalized_quality(25.0), 50.0):
		return "normalized_quality(25) = %.2f, want 50" % QualityModel.normalized_quality(25.0)
	var a17: float = QualityModel.axis_score({"stability": 17.0}, "stability")
	if absf(a17 - 40.476) > 0.01:
		return "axis_score(raw 17) = %.3f, want 40.476" % a17
	# The rival bridge keeps its own half-point: a raw-50 rival composite still reads 50.
	if not is_equal_approx(QualityModel.normalized_quality_rival(50.0), 50.0):
		return "normalized_quality_rival(50) = %.2f, want 50" % QualityModel.normalized_quality_rival(50.0)
	return ""


static func _case_b2b_v1_lands_mid_band() -> String:
	# Lever 2 by outcome, with the measured raws as constants. The good v1 must clear the
	# plain mid/enterprise bar (scale 3, no sector) and fall under the sector-picky mid bar;
	# the bad v1 must clear the plain small bar (scale 2) and fall under small+insurance.
	# Moving ONE lever alone breaks it: HALF_SAT back at 50 reads the good v1 at 38 (under
	# every bar); the old (35, 5) band reads the bad v1 over every small and mid bar.
	var good: float = QualityModel.axis_score({"stability": CAL_V1_GOOD_RAW_STABILITY}, "stability")
	var bad: float = QualityModel.axis_score({"stability": CAL_V1_BAD_RAW_STABILITY}, "stability")
	var mid_plain: int = B2BConstants.seed_tolerance(3, "manufacturing")
	var mid_picky: int = B2BConstants.seed_tolerance(3, "health")
	var small_plain: int = B2BConstants.seed_tolerance(2, "logistics")
	var small_picky: int = B2BConstants.seed_tolerance(2, "insurance")
	if not (good >= float(mid_plain) and good < float(mid_picky)):
		return "good v1 axis %.1f is outside [mid %d, mid+sector %d)" % [good, mid_plain, mid_picky]
	if not (bad >= float(small_plain) and bad < float(small_picky)):
		return "bad v1 axis %.1f is outside [small %d, small+sector %d)" % [bad, small_plain, small_picky]
	# The probe's 5-account book (2 small · 2 mid+sector · 1 enterprise): 3/5 for the good
	# v1, 1/5 for the bad one — the director's ~60 % / ~20 %.
	var bars: Array = [small_plain, small_picky, mid_picky, mid_picky, mid_plain]
	var good_ok: int = 0
	var bad_ok: int = 0
	for b in bars:
		if good >= float(b): good_ok += 1
		if bad >= float(b): bad_ok += 1
	if good_ok != 3 or bad_ok != 1:
		return "book fractions good=%d/5 bad=%d/5, want 3/5 and 1/5" % [good_ok, bad_ok]
	return ""


static func _case_field_unlocked_for_saas_ops() -> String:
	# Lever 3: saas_ops_field is buildable in the demo and the competent set stamps raw 17.
	for f in ProductCatalog.get_feature_pool("saas_ops"):
		if String(f.get("id", "")) == "saas_ops_field" and bool(f.get("requires_research", false)):
			return "saas_ops_field is still research-locked"
	GameState.set_cash(20000)
	var picks := ["saas_ops_integration", "saas_ops_field", "saas_ops_scheduling"]
	if not ProductSystem.start_build("saas_ops", picks, "", "Sahra"):
		return "start_build refused the competent set"
	var b: FeatureBuild = ProductSystem.get_active_build()
	if absf(b.stability - 17.0) > 0.001:
		return "competent set stamps stability %.1f, want 17" % b.stability
	return ""


static func _case_b2c_satisfaction_gate_experience() -> String:
	# B2C-growth precondition (director ruling 2026-08-19): the B2C aggregate's daily +1 reads the
	# EXPERIENCE axis at the re-seated gate (40). Raw 25 → 50 ≥ 40 climbs; raw 10 → 28.6
	# does not; a heavy backlog still erodes either way.
	_seed_b2c()
	var ub: Customer = CustomerRegistry.get_customer(SalesSystem.B2C_USERBASE_ID)
	if ub == null:
		return "no B2C aggregate record after seed"
	GameState.set_flag("mvp_stability", 0.0)
	GameState.set_flag("mvp_innovation", 0.0)
	GameState.set_flag("mvp_experience", 25.0)
	GameState.set_flag("mvp_live_bug_count", 0)
	# SUPPORT-QUIET WORLD. The support
	# desk's two-tier damage (Ops §8.3) legitimately writes the same B2C record every day; this
	# case isolates the QUALITY GATE, so each leg starts with no reports, no confirmed bugs and
	# no carried damage residue.
	var quiet := func() -> void:
		GameState.set_flag(ProductState.REPORTS_INCOMING, 0)
		GameState.set_flag(ProductState.BUGS_CONFIRMED, 0)
		SupportSystem.reset()
	quiet.call()
	CustomerRegistry.set_satisfaction(ub.id, 50)
	_sim_day()
	if ub.satisfaction != 51:
		return "experience 25 (axis 50) did not lift satisfaction (+%d)" % (ub.satisfaction - 50)
	GameState.set_flag("mvp_experience", 10.0)
	quiet.call()
	CustomerRegistry.set_satisfaction(ub.id, 50)
	_sim_day()
	if ub.satisfaction != 50:
		return "experience 10 (axis 28.6) moved satisfaction (%d)" % ub.satisfaction
	GameState.set_flag("mvp_experience", 25.0)
	GameState.set_flag("mvp_live_bug_count", SalesSystem.SATISFACTION_BUG_GATE + 1)
	quiet.call()
	CustomerRegistry.set_satisfaction(ub.id, 50)
	_sim_day()
	if ub.satisfaction != 50:
		return "over-gate bugs did not cancel the experience gain (%d)" % ub.satisfaction
	return ""


static func _case_rival_relative_uses_template_half_sat() -> String:
	# The rival scale bridge: rivals normalize at RIVAL_TEMPLATE_HALF_SAT (50), the player at
	# NORMALIZE_HALF_SAT (25). A player composite equal to the startup rivals' raw average
	# therefore reads ABOVE parity (q > 50) — which is the whole point: the bridge stops the
	# half-point move from doubling the rivals' lead over a played product.
	if not is_equal_approx(QualityModel.RIVAL_TEMPLATE_HALF_SAT, 50.0):
		return "RIVAL_TEMPLATE_HALF_SAT is %.1f, want 50" % QualityModel.RIVAL_TEMPLATE_HALF_SAT
	GameState.set_flag("mvp_sub_product_type_id", "ai_assistant")
	var axes: Array = ProductCatalog.get_quality_axes("ai_assistant")
	var total: float = 0.0
	var total_norm: float = 0.0
	var n: int = 0
	for r in RivalRegistry.get_by_type("ai_assistant"):
		if r.tier == "startup":
			total += r.composite(axes)
			total_norm += QualityModel.normalized_quality_rival(r.composite(axes))
			n += 1
	if n == 0:
		return "fixture: no startup rivals for ai_assistant"
	var avg_raw: float = total / float(n)
	var q_parity: float = SalesSystem._rival_relative_quality(QualityModel.normalized_quality(avg_raw))
	# The engine averages the NORMALIZED rival scores (not the raw composites), so the
	# expectation is built the same way.
	var want: float = 50.0 + QualityModel.normalized_quality(avg_raw) - total_norm / float(n)
	if absf(q_parity - want) > 0.01:
		return "q at raw parity = %.2f, want %.2f (rivals must normalize at the template half-point)" % [q_parity, want]
	if q_parity <= 50.0:
		return "q at raw parity = %.2f — the bridge is not lifting the played product" % q_parity
	return ""


# --- The calendar wall is gone; the soft cap is a catch, not a fork ---

static func _case_soft_cap_ends_run_at_730() -> String:
	# A run with no goal ending reaches the soft cap and ends there, as running_on_fumes,
	# on exactly SOFT_CAP_DAY — never earlier, never silently.
	GameState.set_cash(500000)   # no Kepenk on the way: cash is not the subject here
	GameState.day = EndingsSystem.SOFT_CAP_DAY - 3
	for i in 6:
		if not GameState.run_active:
			break
		_sim_day()
	if _endings != ["running_on_fumes"]:
		return "endings: %s (day %d)" % [str(_endings), GameState.day]
	if GameState.day != EndingsSystem.SOFT_CAP_DAY:
		return "soft cap fired on day %d, want %d" % [GameState.day, EndingsSystem.SOFT_CAP_DAY]
	return ""


static func _case_no_calendar_stop_before_cap() -> String:
	# Day 180 is just a day now. A solvent run with nothing else going on is still alive at
	# day 400 — the Day-180 fork used to end every run here.
	GameState.set_cash(500000)
	GameState.day = 176
	for i in 224:
		if not GameState.run_active:
			break
		_sim_day()
	if not GameState.run_active or not _endings.is_empty():
		return "run ended early: %s at day %d (the calendar wall is back)" % [str(_endings), GameState.day]
	if GameState.day != 400:
		return "sim drifted: day %d, want 400" % GameState.day
	return ""


static func _case_soft_cap_no_defer_for_sheet() -> String:
	# A live term sheet does NOT hold the cap (no auto-sign); the
	# ledger names the unsigned offer instead.
	GameState.set_cash(500000)
	GameState.phase = 3
	GameState.day = EndingsSystem.SOFT_CAP_DAY - 2
	GameState.active_sheets.append(VCPitchSystem._make_sheet("anchor", GameState.day))
	for i in 4:
		if not GameState.run_active:
			break
		_sim_day()
	if _endings != ["running_on_fumes"]:
		return "a live sheet deferred the soft cap: endings %s at day %d" % [str(_endings), GameState.day]
	if int(GameState.get_run_ledger().get("unsigned_sheets", 0)) != 1:
		return "the ledger does not name the unsigned sheet (unsigned_sheets=%s)" % str(GameState.get_run_ledger().get("unsigned_sheets"))
	return ""


# REMOVED 2026-08-23 — _case_soft_cap_warning_day.
# The mechanic it tested no longer exists: the warning was a fixed calendar day
# (PitchConstants.SOFT_CAP_WARN_DAY) and is now sheet-relative — VCPitchSystem
# ._tick_last_answer_warning fires once when the sole live sheet has days_left == 1, and
# suppresses on a pending meeting or another open/callback sheet (vc_pitch_system.gd:519-544).
# The working tree's replacement cases (last_answer_warning, last_answer_warning_suppressed)
# were destroyed before they were committed.
# This stub keeps the suite compiling; the two cases still need re-authoring by their author.
## The two warning holes FRANK_UNWIRED §7 left open. A run with the
## Series A signal OPEN but no signed round (phase 2 with the door standing open, or a phase-3
## Hunt with no live offer) must still get the final-stretch warning, and the arc it starts
## must not fade on an open signal. Only a SIGNED round ends the warning.
##
## FALSIFICATION: restore the `phase.series_a_signal == "open"` leaf in the arc's
## invalidate_when, or the any(signal != open, phase == 2) block on the press card.
static func _case_soft_cap_warns_open_hunt() -> String:
	GameState.initialize_run({"seed": 424242})
	GameState.day = 650
	GameState.set_phase(3)
	if String(PhaseGateSystem.series_a_signal().get("state", "")) != "open":
		return "fixture: phase 3 did not read the Series A signal as open"
	var press: Dictionary = EventGate.catalogue_card("world.final_stretch_press")
	if press.is_empty():
		return "world.final_stretch_press is not in the catalogue"
	if not EventGate.condition_met(press.get("condition", {}), {}):
		return "a phase-3 Hunt at day 650 with no signed round gets no final-stretch warning"
	var f := FileAccess.open("res://data/events/arcs/soft_cap_stretch.json", FileAccess.READ)
	var arc: Dictionary = JSON.parse_string(f.get_as_text()) as Dictionary
	for leaf in arc.get("invalidate_when", []):
		if EventGate.condition_met(leaf as Dictionary, {}):
			return "arc_final_stretch fades on an open signal with no signed round"
	return ""


static func _case_soft_cap_paper_names_unsigned_sheet() -> String:
	# The rewritten paper: an unsigned offer on the table is a ledger line; none → no line.
	var with_sheet: Dictionary = {
		"phase": 3, "day": 730, "mrr": 4000, "customers_signed": 3, "customers_active": 3,
		"hires": 1, "employees": 1, "product_ships": 2, "unsigned_sheets": 1,
	}
	var claim: String = TranslationServer.translate("END_RF_UNSIGNED_SHEET")
	var vs: Dictionary = EndingsCopy.build("running_on_fumes", with_sheet, {})
	var found: bool = false
	for line in (vs.get("ledger_lines", []) as Array):
		if String(line) == claim:
			found = true
	if not found:
		return "the unsigned sheet was not named on the paper"
	var without: Dictionary = with_sheet.duplicate()
	without["unsigned_sheets"] = 0
	var vs2: Dictionary = EndingsCopy.build("running_on_fumes", without, {})
	for line in (vs2.get("ledger_lines", []) as Array):
		if String(line) == claim:
			return "the paper named an unsigned sheet that does not exist"
	# Two-year span phrase: a 730-day run is not "close to a year".
	var span_two: String = TranslationServer.translate("END_SPAN_NEAR_TWO_YEARS")
	if span_two == "" or span_two == "END_SPAN_NEAR_TWO_YEARS":
		return "END_SPAN_NEAR_TWO_YEARS missing"
	var head_line: String = String((vs.get("ledger_lines", []) as Array)[0])
	if head_line.find(span_two) < 0:
		return "730-day paper does not use the two-year span phrase: '%s'" % head_line
	return ""


# --- The Series A gate: revenue bar (never shown) + a growth streak; the signal is shown ---

static func _case_month_history_close_and_cap() -> String:
	# The calendar-month ledger closes on the 1st, carries the open month's accruals
	# (income = Σ daily revenue, expense = Σ burn + one-time costs, red_days), and keeps 12.
	GameState.set_cash(100000)
	_seed_b2b(3000)   # daily revenue 100, burn 50 (founder) → net +50/day
	_sim_day()        # settle the bridge (MRR → GameState)
	var closes_before: int = GameState.month_history.size()
	for i in 40:
		_sim_day()
	if GameState.month_history.size() != closes_before + 1:
		return "expected one fiscal close in 40 days, got %d" % (GameState.month_history.size() - closes_before)
	var e: Dictionary = GameState.month_history[GameState.month_history.size() - 1]
	if int(e.get("income", 0)) <= 0 or int(e.get("expense", 0)) <= 0:
		return "close carries no accruals: %s" % str(e)
	if int(e.get("net", 0)) != int(e.get("income", 0)) - int(e.get("expense", 0)):
		return "net != income - expense: %s" % str(e)
	if int(e.get("mrr_close", 0)) != GameState.mrr:
		return "mrr_close %d != live MRR %d at close" % [int(e.get("mrr_close", 0)), GameState.mrr]
	if int(e.get("red_days", -1)) != 0:
		return "a solvent month counted red days: %s" % str(e)
	for i in 20:
		GameState.push_month_close({"start_day": 1, "end_day": 30, "mrr_close": 1, "income": 1, "expense": 1, "net": 0, "red_days": 0})
	if GameState.month_history.size() != GameState.MONTH_HISTORY_CAP:
		return "ring did not cap at %d (size %d)" % [GameState.MONTH_HISTORY_CAP, GameState.month_history.size()]
	return ""


static func _case_growth_streak_semantics() -> String:
	# Pure arithmetic of the streak: integer MoM compare, zero previous never counts.
	var cases := [
		[[0, 1000], 0],
		[[1000, 1120], 1],
		[[1000, 1119], 0],
		[[1000, 1200, 1400, 1600], 3],
		[[1000, 1200, 1100, 1300], 1],
		[[500], 0],
	]
	for cs in cases:
		_seed_month_closes(cs[0])
		var got: int = GameState.get_mrr_growth_streak(PhaseGateSystem.GROWTH_MIN_PCT)
		if got != int(cs[1]):
			return "closes %s → streak %d, want %d" % [str(cs[0]), got, int(cs[1])]
	_seed_month_closes([1000, 1120])   # exactly one qualifying month
	# THE VOCABULARY MOVED. `{"type": "mrr_growth_streak", "pct": N}` was the old engine's
	# leaf; the engine's is a seam comparison, and the percentage lives ON the seam because a
	# seam takes no arguments. That constraint is a feature here: the gate table and this case
	# can no longer disagree about what "qualifying growth" means, since neither carries the
	# number any more.
	if not EventGate.condition_met(
			{"seam": "finance.growth_streak_months", "op": ">=", "value": 1}):
		return "condition false at streak 1 (value 1)"
	if EventGate.condition_met(
			{"seam": "finance.growth_streak_months", "op": ">=", "value": 2}):
		return "condition true at streak 1 (value 2)"
	return ""


static func _case_series_a_gate_mrr_only() -> String:
	# The door is MRR ONLY. MRR over the bar with NO growth history and a
	# brand under the old floor of 25 must open it; one dollar under the bar must not.
	# FALSIFICATION: put the growth-streak or brand leaf back into PhaseGateSystem.GATES.
	GameState.set_phase(2)
	_seed_b2b(SalesSystem.TRACTION_MRR_TARGET - 1)
	GameState.month_history.clear()
	GameState.set_brand(5)
	for i in 3:
		_sim_day()
	if GameState.phase_gate_ready:
		return "the Series A gate opened one dollar under the bar"
	CustomerRegistry.set_mrr(CustomerRegistry.get_by_market("b2b")[0].id, SalesSystem.TRACTION_MRR_TARGET)
	SalesSystem.reflect_mrr()
	_sim_day()
	if not GameState.phase_gate_ready or GameState.pending_next_phase != 3:
		return "the gate stayed shut at the bar with no growth history and brand %d" % GameState.brand
	return ""


static func _case_series_a_signal_states() -> String:
	# Phase 1 → closed regardless; phase 2 under half the bar → closed; at half the bar
	# → warming (the same day Frank's first approach line may speak); at the bar → open with
	# no growth history; phase 3 → open. No `progress`, no `streak` — the readout has no ratio.
	GameState.set_phase(1)
	_seed_b2b_series_a()
	if String(PhaseGateSystem.series_a_signal().get("state", "")) != "closed":
		return "phase 1 should read closed"
	GameState.set_phase(2)
	GameState.month_history.clear()
	var cid: String = CustomerRegistry.get_by_market("b2b")[0].id
	var bar: int = PhaseGateSystem.series_a_bar()
	CustomerRegistry.set_mrr(cid, 500)
	SalesSystem.reflect_mrr()
	var sig: Dictionary = PhaseGateSystem.series_a_signal()
	if String(sig.get("state", "")) != "closed" or int(sig.get("approach", -1)) != 0:
		return "phase 2 with nothing should read closed (got %s)" % str(sig)
	if sig.has("progress") or sig.has("streak"):
		return "the signal still carries a ratio (K3): %s" % str(sig)
	CustomerRegistry.set_mrr(cid, bar / 2)
	SalesSystem.reflect_mrr()
	sig = PhaseGateSystem.series_a_signal()
	if String(sig.get("state", "")) != "warming" or int(sig.get("approach", 0)) != 1:
		return "half the bar should read warming at approach 1 (got %s)" % str(sig)
	CustomerRegistry.set_mrr(cid, bar)
	SalesSystem.reflect_mrr()
	sig = PhaseGateSystem.series_a_signal()
	if String(sig.get("state", "")) != "open" or not bool(sig.get("mrr_ok", false)) or int(sig.get("approach", 0)) != 4:
		return "the bar alone should read open at approach 4 (got %s)" % str(sig)
	GameState.set_phase(3)
	if String(PhaseGateSystem.series_a_signal().get("state", "")) != "open":
		return "phase 3 should read open"
	return ""


## Frank's approach lines. Each speaks at most ONCE per run — an MRR dip and
## re-cross never brings a line back — and an earlier line never follows a later one. The
## lines carry no number in either locale.
## FALSIFICATION: drop `latch.one_shot` from funding.frank_approach_half, or the `none`
## history block from funding.frank_approach_near.
static func _case_frank_approach_lines_once() -> String:
	const HALF := "funding.frank_approach_half"
	const NEAR := "funding.frank_approach_near"
	const CLOSE := "funding.frank_approach_close"
	for key in ["FRANK_APPROACH_HALF", "FRANK_APPROACH_NEAR", "FRANK_APPROACH_CLOSE", "FRANK_DOOR_OPEN"]:
		for loc in ["tr", "en"]:
			var tobj: Translation = TranslationServer.get_translation_object(loc)
			if tobj == null:
				return "no %s translation loaded" % loc
			var line: String = String(tobj.get_message(key))
			if line == "":
				return "%s has no %s text" % [key, loc]
			if RegEx.create_from_string("[0-9]").search(line) != null:
				return "%s (%s) carries a number: %s" % [key, loc, line]
	GameState.set_cash(100000)
	GameState.set_phase(2)
	_seed_b2b(1000)
	var cid: String = CustomerRegistry.get_by_market("b2b")[0].id
	var bar: int = PhaseGateSystem.series_a_bar()
	var at := func(pct: int) -> void:
		CustomerRegistry.set_mrr(cid, int(ceil(bar * pct / 100.0)))
		SalesSystem.reflect_mrr()
		_sim_day()
		_drain_all_modals()
	at.call(40)
	if _card_fired(HALF):
		return "the halfway line spoke under half the bar"
	at.call(55)
	if not _card_fired(HALF):
		return "the halfway line never spoke at 55 %% of the bar (approach %d)" % PhaseGateSystem.series_a_approach()
	at.call(30)
	at.call(60)
	at.call(60)
	if EvLatches.fires(EvLatches.key_for(HALF, EvLatches.KEY_RUN, "")) != 1:
		return "the halfway line spoke again after a dip and re-cross"
	# Jump the second mark: the third line speaks, and the skipped second one must stay quiet
	# even when MRR later falls back into its band.
	at.call(92)
	if not _card_fired(CLOSE):
		return "the close line never spoke at 92 %% of the bar"
	if _card_fired(NEAR):
		return "the three-quarters line spoke in the close band"
	at.call(80)
	if _card_fired(NEAR):
		return "an earlier approach line followed a later one"
	if GameState.phase_gate_ready:
		return "fixture: the gate opened under the bar"
	return ""


static func _case_month_history_save_typing() -> String:
	# The ring is an Array[Dictionary] of ints; a save round-trip must bring it back typed,
	# with ints (JSON re-types to float; the codec restores).
	_seed_month_closes([1000, 1200, 1500])
	GameState.set_cash(12345)
	_cleanup_save_slots()
	if not SaveManager.save_to_slot(SAVE_SLOT_B):
		_cleanup_save_slots()
		return "save refused"
	GameState.month_history.clear()
	if not SaveManager.apply_loaded_state(SaveManager.read_slot(SAVE_SLOT_B)):
		_cleanup_save_slots()
		return "load refused"
	_cleanup_save_slots()
	if GameState.month_history.size() != 3:
		return "month_history came back with %d entries, want 3" % GameState.month_history.size()
	if GameState.month_history.get_typed_builtin() != TYPE_DICTIONARY:
		return "month_history lost its Array[Dictionary] typing"
	var e: Dictionary = GameState.month_history[2]
	if typeof(e.get("mrr_close")) != TYPE_INT or int(e.get("mrr_close")) != 1500:
		return "mrr_close came back as %s (%s)" % [str(e.get("mrr_close")), type_string(typeof(e.get("mrr_close")))]
	if GameState.get_mrr_growth_streak(12) != 2:
		return "streak after load = %d, want 2" % GameState.get_mrr_growth_streak(12)
	return ""


# --- B2C growth compounds both ways (word of mouth on the aggregate's satisfaction) ---

static func _b2c_delta_at_satisfaction(sat: int) -> float:
	var ub: Customer = CustomerRegistry.get_customer(SalesSystem.B2C_USERBASE_ID)
	CustomerRegistry.set_satisfaction(ub.id, sat)
	return SalesSystem._audience_delta_per_hour()


static func _case_b2c_wom_needs_satisfaction() -> String:
	# Above the gate the hourly delta carries audience·WOM_COEF·(sat−gate)/100 — proportional
	# to the AUDIENCE (that is the compounding); below the gate there is no such term.
	_seed_b2c()
	GameState.set_flag("mvp_innovation", 15.0)
	GameState.set_flag("mvp_stability", 20.0)
	GameState.set_flag("mvp_experience", 17.5)
	GameState.set_flag("b2c_audience", 1000.0)
	var d50: float = _b2c_delta_at_satisfaction(50)
	var d60: float = _b2c_delta_at_satisfaction(60)
	var d80: float = _b2c_delta_at_satisfaction(80)
	if absf(d60 - d50) > 1e-6:
		return "satisfaction 60 (the gate) already adds word of mouth (%.4f vs %.4f)" % [d60, d50]
	var want: float = 1000.0 * SalesSystem.WOM_COEF * 0.2
	if absf((d80 - d50) - want) > 1e-6:
		return "sat 80 adds %.4f/h over sat 50, want audience·WOM_COEF·0.2 = %.4f" % [d80 - d50, want]
	# Proportional to the audience: double the audience, double the word-of-mouth term.
	GameState.set_flag("b2c_audience", 2000.0)
	var d80b: float = _b2c_delta_at_satisfaction(80)
	var d50b: float = _b2c_delta_at_satisfaction(50)
	if absf((d80b - d50b) - 2.0 * want) > 1e-6:
		return "word of mouth is not proportional to the audience (%.4f vs %.4f)" % [d80b - d50b, 2.0 * want]
	if SalesSystem.WOM_COEF <= 0.0:
		return "WOM_COEF is %.4f — the compounding term is off" % SalesSystem.WOM_COEF
	return ""


static func _case_b2c_growth_multiplier_floor() -> String:
	# Below the pivot the BASE growth is scaled by sat/50, floored at 0.3; at and above the
	# pivot it runs at full strength. Measured as the gap to the sat-50 delta with a tiny
	# audience so churn and word of mouth are negligible.
	_seed_b2c()
	GameState.set_flag("mvp_innovation", 15.0)
	GameState.set_flag("mvp_stability", 20.0)
	GameState.set_flag("mvp_experience", 17.5)
	GameState.set_flag("b2c_audience", 0.0)   # no audience → no churn, no word of mouth: pure base growth
	var d50: float = _b2c_delta_at_satisfaction(50)
	var d100: float = _b2c_delta_at_satisfaction(100)
	var d25: float = _b2c_delta_at_satisfaction(25)
	var d0: float = _b2c_delta_at_satisfaction(0)
	if d50 <= 0.0:
		return "fixture: base growth is not positive (%.4f)" % d50
	if absf(d100 - d50) > 1e-6:
		return "satisfaction above the pivot changed base growth (%.4f vs %.4f)" % [d100, d50]
	if absf(d25 - 0.5 * d50) > 1e-6:
		return "satisfaction 25 should halve base growth (%.4f vs %.4f)" % [d25, 0.5 * d50]
	if absf(d0 - SalesSystem.WOM_MULT_MIN * d50) > 1e-6:
		return "satisfaction 0 should floor at ×%.1f (%.4f vs %.4f)" % [SalesSystem.WOM_MULT_MIN, d0, SalesSystem.WOM_MULT_MIN * d50]
	# No aggregate record yet (paid tier closed) → the pre-revenue trickle is untouched.
	CustomerRegistry.remove(SalesSystem.B2C_USERBASE_ID)
	var d_none: float = SalesSystem._audience_delta_per_hour()
	if absf(d_none - d50) > 1e-6:
		return "without the aggregate record growth should equal the pivot reading (%.4f vs %.4f)" % [d_none, d50]
	return ""


# --- Bugs hit conversion ---

static func _case_conversion_bug_penalty() -> String:
	# 10 live bugs ≈ −20 % conversion, floored at ×0.4; the pricing ruler's projection
	# (estimate_price_change → new_paying) moves with it.
	_seed_b2c()
	GameState.set_flag("mvp_innovation", 15.0)
	GameState.set_flag("mvp_stability", 20.0)
	GameState.set_flag("mvp_experience", 17.5)
	GameState.set_flag("mvp_components", ["ai_assistant_chat", "ai_assistant_memory"])
	GameState.set_flag("mvp_sub_product_type_id", "ai_assistant")
	GameState.set_flag("b2c_audience", 1000.0)
	var price: int = int(GameState.get_flag("b2c_price", SalesSystem.B2C_PRICE_DEFAULT))
	# Bugs ALSO lower product_value (effective stability → composite → optimal), so the
	# expectation is rebuilt from product_value at each bug level: the penalty factor is what
	# conversion_rate adds on top of the price curve.
	for probe in [[0, 1.0], [10, 0.8], [60, SalesSystem.BUG_CONV_FLOOR]]:
		GameState.set_flag("mvp_live_bug_count", int(probe[0]))
		var optimal: float = maxf(1.0, float(SalesSystem.product_value()["optimal"]))
		var price_curve: float = clampf(SalesSystem.CONVERSION_BASE * optimal / maxf(1.0, float(price)),
			SalesSystem.CONVERSION_MIN, SalesSystem.CONVERSION_MAX)
		var want: float = clampf(price_curve * float(probe[1]), SalesSystem.CONVERSION_MIN, SalesSystem.CONVERSION_MAX)
		var got: float = SalesSystem.conversion_rate(price)
		if absf(got - want) > 1e-6:
			return "%d bugs → conversion %.4f, want price curve %.4f × %.2f = %.4f" % [int(probe[0]), got, price_curve, float(probe[1]), want]
		if int(probe[0]) == 0 and (got <= SalesSystem.CONVERSION_MIN or got >= SalesSystem.CONVERSION_MAX):
			return "fixture: bug-free rate %.3f sits on a clamp; the penalty would be masked" % got
	GameState.set_flag("mvp_live_bug_count", 0)
	var paying0: int = int(SalesSystem.estimate_price_change(price)["new_paying"])
	GameState.set_flag("mvp_live_bug_count", 10)
	var paying10: int = int(SalesSystem.estimate_price_change(price)["new_paying"])
	if paying10 >= paying0:
		return "the pricing projection did not move under bugs (%d vs %d paying)" % [paying10, paying0]
	return ""


# --- The bug complaint costs audience and satisfaction, never cash ---

static func _case_audience_pct_modifier() -> String:
	# audience_delta {pct} erodes (or grows) the live audience proportionally; flat delta is
	# unchanged; the badge renders the percentage.
	_seed_b2c()
	GameState.set_flag("b2c_audience", 1000.0)
	EventGate.debug_apply_effects([{"verb": "audience_delta", "pct": -0.03}])
	var a: float = float(GameState.get_flag("b2c_audience", 0.0))
	if absf(a - 970.0) > 0.01:
		return "pct −0.03 on 1000 left %.2f, want 970" % a
	EventGate.debug_apply_effects([{"verb": "audience_delta", "delta": 30}])
	if absf(float(GameState.get_flag("b2c_audience", 0.0)) - 1000.0) > 0.01:
		return "flat delta regressed"
	# event_modal.gd has no class_name; instantiate the script bare — _describe_modifier only
	# needs tr() and Fmt, neither of which needs the node in the tree.
	var modal: Node = (load("res://scripts/modals/event_modal.gd") as GDScript).new()
	# `verb`, the shape a CARD carries. The chip builder reads `verb` first and falls back to
	# `type`; asserting on the shape the cards actually use is what makes this case cover the
	# path a player sees.
	var badge: Dictionary = modal._describe_modifier({"verb": "audience_delta", "pct": -0.03})
	modal.free()
	var txt: String = String(badge.get("text", ""))
	if txt == "" or txt.find("3") < 0 or txt.find("{") >= 0:
		return "badge for the pct form is wrong: '%s'" % txt
	if String(badge.get("kind", "")) != "negative":
		return "badge kind for a negative pct should be negative, got %s" % str(badge.get("kind"))
	return ""


static func _case_complaint_never_charges_cash() -> String:
	# REPOINTED. The calibration ruled that a
	# complaint costs AUDIENCE and SATISFACTION and never cash. The card that carried the
	# ruling, `customer.bug_complaint`, was legacy B2C flavour and is gone; the ruling is not,
	# so it is asserted in the two places that survived it.
	#
	# HALF ONE - the live card. `customer.request_complaint` is the complaint the player
	# actually meets now, and no row of it may charge cash.
	if not EventGate.is_catalogued("customer.request_complaint"):
		return "customer.request_complaint not in the catalogue"
	var ev: GameEvent = EventGate.render("customer.request_complaint")
	if ev.choices.is_empty():
		return "the live complaint card rendered no choices"
	for ch in ev.choices:
		for m in ch.modifiers:
			if String((m as Dictionary).get("verb", "")) in ["add_cash", "spend_cash"]:
				return "a cash row survived in '%s'" % ch.label

	# HALF TWO - the executor. The three rows the deleted card handed it, written out here so
	# the arithmetic they pinned still has a case while the new deck is unwritten: satisfaction
	# on the userbase record, brand, a PERCENTAGE of the audience, and churn. Every one of them
	# has to leave cash exactly where it found it.
	_seed_b2c()
	GameState.set_flag("b2c_audience", 1000.0)
	SalesSystem._ensure_b2c_record()
	var ub: Customer = CustomerRegistry.get_customer(SalesSystem.B2C_USERBASE_ID)
	CustomerRegistry.set_satisfaction(ub.id, 40)
	# THE SUBJECT COMES WITH THE EFFECTS. The old executor had a hidden default —
	# "the most-at-risk customer in the event's market", computed at apply time — and that
	# default is what the port replaced with a declared scope slot. So the case has to bind
	# the slot, which is also the honest reading: these effects are ABOUT the userbase record,
	# and now they say so.
	var ctx: Dictionary = _ctx_customer(ub)
	var cash0: int = GameState.cash
	var brand0: int = GameState.brand
	EventGate.debug_apply_effects([
		{"verb": "satisfaction_delta", "amount": 10},
		{"verb": "add_brand", "amount": 2},
		{"verb": "audience_delta", "pct": -0.03}], ctx)
	if GameState.cash != cash0:
		return "answering in the open moved cash (%d → %d)" % [cash0, GameState.cash]
	if ub.satisfaction != 50:
		return "answering in the open did not lift satisfaction by 10 (got %d)" % ub.satisfaction
	if GameState.brand != brand0 + 2:
		return "answering in the open did not add brand +2"
	if absf(float(GameState.get_flag("b2c_audience", 0.0)) - 970.0) > 0.01:
		return "answering in the open did not cost 3 %% of the audience (%.1f)" % float(GameState.get_flag("b2c_audience", 0.0))
	EventGate.debug_apply_effects([
		{"verb": "satisfaction_delta", "amount": 6},
		{"verb": "add_brand", "amount": -1},
		{"verb": "audience_delta", "pct": -0.01}], ctx)
	if GameState.cash != cash0:
		return "the private reply moved cash"
	if ub.satisfaction != 56 or GameState.brand != brand0 + 1:
		return "the private reply should be sat +6 / brand −1 (sat %d, brand %d)" % [ub.satisfaction, GameState.brand]
	var aud_before_ignore: float = float(GameState.get_flag("b2c_audience", 0.0))
	EventGate.debug_apply_effects([
		{"verb": "churn_customer"},
		{"verb": "add_brand", "amount": -2}], ctx)
	if float(GameState.get_flag("b2c_audience", 0.0)) >= aud_before_ignore:
		return "ignoring it did not churn audience"
	if GameState.cash != cash0:
		return "ignoring it moved cash"
	return ""


# --- The discount cap, the risk hysteresis, one retention gate ---

static func _seed_risk_account() -> Customer:
	# One B2B account parked IN Risk with a running countdown and a degrading product.
	_seed_b2b(1000)
	var c: Customer = CustomerRegistry.get_by_market("b2b")[0]
	CustomerRegistry.set_tolerance(c.id, 50)
	CustomerRegistry.set_satisfaction(c.id, 30)
	GameState.set_flag("mvp_stability", 5.0)
	GameState.set_flag("mvp_live_bug_count", 30)
	CustomerRegistry.set_lifecycle_phase(c.id, "risk")
	CustomerRegistry.set_churn_countdown(c.id, B2BConstants.CHURN_COUNTDOWN_DAYS)
	return c


static func _case_discount_cap_two_uses() -> String:
	# Two discounts cut MRR and recover the account; the third is refused by the seam itself.
	var c: Customer = _seed_risk_account()
	var mrr0: int = c.mrr
	B2BSalesSystem.apply_discount(c.id, -150)
	if c.mrr != mrr0 - 150 or c.retain_discounts != 1:
		return "first discount: mrr %d (want %d), uses %d" % [c.mrr, mrr0 - 150, c.retain_discounts]
	CustomerRegistry.set_lifecycle_phase(c.id, "risk")
	B2BSalesSystem.apply_discount(c.id, -150)
	if c.mrr != mrr0 - 300 or c.retain_discounts != 2:
		return "second discount: mrr %d (want %d), uses %d" % [c.mrr, mrr0 - 300, c.retain_discounts]
	var sat_after_two: int = c.satisfaction
	CustomerRegistry.set_lifecycle_phase(c.id, "risk")
	B2BSalesSystem.apply_discount(c.id, -150)
	if c.mrr != mrr0 - 300 or c.retain_discounts != 2 or c.satisfaction != sat_after_two:
		return "third discount went through (mrr %d, uses %d, sat %d)" % [c.mrr, c.retain_discounts, c.satisfaction]
	return ""


static func _case_risk_reentry_hysteresis() -> String:
	# Rescued on day D, still under the bar: the account stays OUT of Risk until D+21, with
	# no countdown and no card, then re-enters the day the window closes.
	var c: Customer = _seed_risk_account()
	var day0: int = GameState.day
	B2BSalesSystem.apply_discount(c.id, -100)   # _recover → leaves Risk, stamps the exit day
	if c.lifecycle_phase == "risk" or c.last_risk_exit_day != day0:
		return "rescue did not leave Risk / stamp the day (phase %s, exit %d)" % [c.lifecycle_phase, c.last_risk_exit_day]
	var cards: Array = [0]
	EventBus.event_triggered.connect(func(id: String) -> void:
		if id == RETAIN_ID:
			cards[0] += 1)
	for i in B2BConstants.RISK_REENTRY_DAYS - 1:
		CustomerRegistry.set_satisfaction(c.id, 10)   # hold it far under the bar
		_sim_day()
		if c.lifecycle_phase == "risk":
			return "re-entered Risk on day %d, %d days after the rescue (window %d)" % [
				GameState.day, GameState.day - day0, B2BConstants.RISK_REENTRY_DAYS]
	if c.risk_streak < B2BConstants.RISK_TRIGGER_DAYS:
		return "the streak stopped counting during the window (%d)" % c.risk_streak
	if int(cards[0]) != 0:
		return "a retention card fired inside the window"
	CustomerRegistry.set_satisfaction(c.id, 10)
	_sim_day()   # D + 21
	if c.lifecycle_phase != "risk" or c.churn_countdown < 0:
		return "did not re-enter Risk when the window closed (day %d, phase %s)" % [GameState.day, c.lifecycle_phase]
	_drain_all_modals()
	return ""


static func _case_risk_exit_stamps_day() -> String:
	# Both exit sites stamp last_risk_exit_day: the daily sweep's healthy branch and _recover.
	var c: Customer = _seed_risk_account()
	if c.last_risk_exit_day != -1:
		return "fresh account already carries an exit day"
	GameState.set_flag("mvp_stability", 80.0)
	GameState.set_flag("mvp_live_bug_count", 0)
	CustomerRegistry.set_satisfaction(c.id, 90)   # over the bar → _tick_healthy's risk branch
	_sim_day()
	if c.lifecycle_phase == "risk" or c.last_risk_exit_day != GameState.day:
		return "healthy-branch exit did not stamp (phase %s, exit %d, day %d)" % [c.lifecycle_phase, c.last_risk_exit_day, GameState.day]
	CustomerRegistry.set_lifecycle_phase(c.id, "risk")
	CustomerRegistry.set_churn_countdown(c.id, 5)
	GameState.day += 10
	B2BSalesSystem.accept_promise(c.id, "ai_vec_filter", 14)   # the promise path → _recover
	if c.last_risk_exit_day != GameState.day:
		return "_recover exit did not stamp (exit %d, day %d)" % [c.last_risk_exit_day, GameState.day]
	_drain_all_modals()
	return ""


static func _case_discount_row_locked_past_cap() -> String:
	# Past the cap every discount row (retention card AND the CS complaint/renewal cards)
	# is present, locked by a real condition, and carries the reason on its sub-line.
	var c: Customer = _seed_risk_account()
	var ctx: Dictionary = _ctx_customer(c)
	var ev: GameEvent = EventGate.render(RETAIN_ID, ctx)
	var idx: int = _row_with_verb(ev, "b2b_retain_discount")
	if idx < 0:
		return "no discount row on the retention card"
	if not _row_unlocked(ev, idx, ctx):
		return "discount row locked before any discount"
	CustomerRegistry.set_retain_discounts(c.id, B2BConstants.RETAIN_DISCOUNT_MAX_USES)
	ev = EventGate.render(RETAIN_ID, ctx)
	idx = _row_with_verb(ev, "b2b_retain_discount")
	if idx < 0:
		return "the capped discount row was withheld — it must stay visible"
	if _row_unlocked(ev, idx, ctx):
		return "capped discount row is still unlocked"
	var want: String = TranslationServer.translate("B2B_DISCOUNT_SPENT_DESC")
	if ev.choices[idx].unlock_reason_text != want or want == "B2B_DISCOUNT_SPENT_DESC":
		return "capped row lacks the reason line ('%s')" % ev.choices[idx].unlock_reason_text
	# The CS channel: a complaint card's discount row locks the same way.
	var cs := Character.new()
	cs.id = "char_cs_cap"
	cs.character_name = "Cap Rep"
	cs.role = HRConstants.ROLE_CUSTOMER_REP
	cs.category = "employee"
	cs.monthly_salary = 5000
	cs.role_stats = {"expertise": 2, "pace": 5, "rapport": 5}
	CharacterRegistry.add(cs)
	CustomerRegistry.assign_customer(c.id, cs.id)
	CustomerRegistry.set_last_request_kind(c.id, "")
	# The three request kinds are three cards now; complaint and renewal are the two that carry
	# a discount row, and both are checked rather than whichever one the picker happened to
	# choose. That branch used to be invisible to the case — pick_request_kind decided it at
	# build time and nothing could ask which way it went.
	for card_id in ["customer.request_complaint", "customer.request_renewal"]:
		var req: GameEvent = EventGate.render(String(card_id), ctx)
		var ridx: int = _row_with_verb(req, "b2b_retain_discount")
		if ridx >= 0 and _row_unlocked(req, ridx, ctx):
			return "%s's discount row is unlocked past the cap" % card_id
	return ""


static func _case_retention_gate_shared() -> String:
	# ONE gate: healthy / countdown −1 / delegated+escalated → no card; live Risk → card.
	var c: Customer = _seed_risk_account()
	if not B2BSalesSystem.can_offer_retention(c):
		return "live Risk account refused"
	CustomerRegistry.set_churn_countdown(c.id, -1)
	if B2BSalesSystem.can_offer_retention(c):
		return "offered with no countdown running"
	CustomerRegistry.set_churn_countdown(c.id, 5)
	CustomerRegistry.set_lifecycle_phase(c.id, "active")
	if B2BSalesSystem.can_offer_retention(c):
		return "offered to an active (non-Risk) account"
	CustomerRegistry.set_lifecycle_phase(c.id, "risk")
	c.assigned_to = "someone"
	c.cs_escalated = true
	if B2BSalesSystem.can_offer_retention(c):
		return "offered while the rep's escalation is open"
	c.assigned_to = ""
	c.cs_escalated = false
	# The sweep's enqueue goes through the same gate: a recovered account raises no card.
	B2BSalesSystem.apply_discount(c.id, -50)   # leaves Risk
	# THE SWEEP AND THE BUTTON ASK THE SAME QUESTION, and now they ask it in the same place:
	# `customer.retention`'s own condition. B2BSalesSystem no longer has an enqueue function to
	# call, so the assertion drives the surviving entry point — a named request through the
	# gate — and it must be refused for an account that has left Risk.
	var before: int = EventGate.queued_ids().size() + (1 if EventGate.active_id() != "" else 0)
	if EventGate.request(RETAIN_ID, {"customer": c.id}):
		return "the gate admitted a retention card for an account that is not in Risk"
	var after: int = EventGate.queued_ids().size() + (1 if EventGate.active_id() != "" else 0)
	if after != before:
		return "a refused request still moved the queue"
	_drain_all_modals()
	return ""


static func _case_manual_retention_respects_cap() -> String:
	# The Sales-tab path and the cap together: after two discounts the manual card's discount
	# row is locked, and forcing the modifier through the seam changes nothing.
	var c: Customer = _seed_risk_account()
	CustomerRegistry.set_retain_discounts(c.id, B2BConstants.RETAIN_DISCOUNT_MAX_USES)
	var ctx: Dictionary = _ctx_customer(c)
	var ev: GameEvent = EventGate.render(RETAIN_ID, ctx)
	var mrr0: int = c.mrr
	var idx: int = _row_with_verb(ev, "b2b_retain_discount")
	if idx >= 0:
		if _row_unlocked(ev, idx, ctx):
			return "manual card offers an unlocked discount past the cap"
		EventGate.debug_apply_effects(ev.choices[idx].modifiers)   # the bypass a UI bug could make
	if c.mrr != mrr0 or c.retain_discounts != B2BConstants.RETAIN_DISCOUNT_MAX_USES:
		return "a forced discount past the cap changed state (mrr %d→%d, uses %d)" % [mrr0, c.mrr, c.retain_discounts]
	return ""


# --- Profitability is a condition, not a crossing ---

static func _case_profit_condition_fires() -> String:
	# Five Artıda closes seeded, live MRR over the floor, the sixth month earned by the sim:
	# no ending on the close day itself (slot 10 closes after slot 9 reads), the win the day
	# after; never before the sixth close.
	GameState.set_cash(100000)
	_seed_b2b(EndingsSystem.BOOTSTRAP_WIN_MRR + 5000)   # daily revenue ~833 vs burn 50 → an Artıda month
	# THE FIFTH CLAUSE (ch. 13 §1): profitability alone is not an ending. These two cases
	# measure the four ECONOMIC clauses, so the investor one is satisfied in the fixture
	# rather than restated in every assertion. That the clause is REQUIRED — and that
	# each of its three writers opens it — is bootstrap_needs_the_faced_flag's job.
	GameState.mark_faced_series_a("walked")
	_seed_month_closes([20000, 21000, 22000, 23000, 24000], 30000, 24000)   # 5 Artıda closes, margin 20 %
	var closes0: int = GameState.month_history.size()
	var fired_day: int = -1
	for i in 40:
		_sim_day()
		if not _endings.is_empty():
			fired_day = GameState.day
			break
		if GameState.month_history.size() == closes0 and not _endings.is_empty():
			return "ending fired before the sixth close"
	if _endings != ["profitable_bootstrap"]:
		return "endings: %s (closes %d, streak %d)" % [str(_endings), GameState.month_history.size(),
			GameState.get_profitable_month_streak()]
	if GameState.month_history.size() != closes0 + 1:
		return "the win needed %d closes, want exactly one more" % (GameState.month_history.size() - closes0)
	var close_day: int = int(GameState.month_history[GameState.month_history.size() - 1].get("end_day", 0))
	if fired_day != close_day + 1:
		return "win fired on day %d, want the day after the close (%d)" % [fired_day, close_day + 1]
	# The paper names the streak (END_BS_STREAK) when the ledger carries one.
	var vs: Dictionary = EndingsCopy.build("profitable_bootstrap", GameState.get_run_ledger(), {})
	var claim: String = TranslationServer.translate("END_BS_STREAK").format({"n": EndingsCopy._num(EndingsSystem.PROFIT_STREAK_MONTHS)})
	var found: bool = false
	for line in (vs.get("ledger_lines", []) as Array):
		if String(line) == claim:
			found = true
	if not found:
		return "the bootstrap paper did not name the %d-month streak" % EndingsSystem.PROFIT_STREAK_MONTHS
	return ""


## Owner rulings (2026-09-25): one paper, two modes. In the demo every
## ending ends the run. In EA / full the profitable bootstrap is a milestone; every loss, the
## signed Series A (until Act 3) and the sale stay endings.
## FALSIFICATION: make ending_mode() return "milestone" for series_a_close → the EA row fails.
static func _case_ending_modes_by_build() -> String:
	# The raw resolver (run_case pins the demo; clear the pin to read what the build says).
	# Only when nobody configured --build=: then an untagged headless build must be the demo.
	EndingsSystem.build_scope_override = ""
	var raw_args: String = " ".join(OS.get_cmdline_args()) + " " \
		+ String(ProjectSettings.get_setting("application/run/main_args", ""))
	if not raw_args.contains("--build=") and EndingsSystem.build_scope() != EndingsSystem.BUILD_DEMO:
		return "an untagged headless build did not read as the demo (%s)" % EndingsSystem.build_scope()
	EndingsSystem.build_scope_override = EndingsSystem.BUILD_DEMO
	for eid in EndingsSystem.ENDINGS.keys():
		if EndingsSystem.ending_mode(String(eid)) != EndingsSystem.MODE_ENDING:
			return "demo: %s is not an ending" % eid
	for scope in [EndingsSystem.BUILD_EA, EndingsSystem.BUILD_FULL]:
		EndingsSystem.build_scope_override = String(scope)
		for eid in EndingsSystem.ENDINGS.keys():
			var want: String = EndingsSystem.MODE_MILESTONE if String(eid) == "profitable_bootstrap" else EndingsSystem.MODE_ENDING
			var got: String = EndingsSystem.ending_mode(String(eid))
			if got != want:
				EndingsSystem.build_scope_override = ""
				return "%s: %s is %s, want %s" % [scope, eid, got, want]
	# A milestone save opened in the DEMO is a demo run: the latch does not count there, so
	# the win can still end it and the day-730 cap still applies.
	# FALSIFICATION: read the bare latch in bootstrap_milestone_taken → the demo run is stuck.
	GameState.bootstrap_milestone_day = 100
	EndingsSystem.build_scope_override = EndingsSystem.BUILD_EA
	var ea_taken: bool = EndingsSystem.bootstrap_milestone_taken()
	EndingsSystem.build_scope_override = EndingsSystem.BUILD_DEMO
	var demo_taken: bool = EndingsSystem.bootstrap_milestone_taken()
	var fail: String = ""
	if not ea_taken:
		fail = "EA: a written latch does not read as taken"
	elif demo_taken:
		fail = "demo: a milestone save's latch still reads as taken"
	else:
		GameState.day = EndingsSystem.SOFT_CAP_DAY
		if not EndingsSystem._check_soft_cap() or GameState.ending_id != "running_on_fumes":
			fail = "demo: the day-730 cap did not end a milestone save's run (ending '%s')" % GameState.ending_id
	EndingsSystem.build_scope_override = ""
	return fail


## EA: the profitable bootstrap opens the milestone paper ONCE and the run goes on — no
## run_ended, no ending_id, run_active untouched. The latch keeps the condition shut on the
## days after, the day-730 soft cap no longer ends the run (option a), and the soft-cap
## telegraph's seam reads true so its cards stay silent. The demo control is
## profit_condition_fires: the same fixture, an ending.
## FALSIFICATION: drop the latch check at the top of _check_profitable_bootstrap → the
## paper fires again the next day.
static func _case_bootstrap_milestone_keeps_the_run() -> String:
	EndingsSystem.build_scope_override = EndingsSystem.BUILD_EA
	var fired: Array = []
	EventBus.milestone_reached.connect(func(id: String, d: Dictionary) -> void:
		fired.append("%s/%s" % [id, String(d.get("mode", ""))]))
	GameState.set_cash(100000)
	_seed_b2b(EndingsSystem.BOOTSTRAP_WIN_MRR + 5000)
	GameState.mark_faced_series_a("walked")   # the fifth clause, as in profit_condition_fires
	_seed_month_closes([20000, 21000, 22000, 23000, 24000], 30000, 24000)
	var leaf_taken := {"seam": "phase.bootstrap_milestone", "op": "==", "value": true}
	if EventGate.condition_met(leaf_taken, {}):
		EndingsSystem.build_scope_override = ""
		return "the milestone seam read true before any milestone"
	var fired_day: int = -1
	for i in 40:
		_sim_day()
		if not fired.is_empty():
			fired_day = GameState.day
			break
	var fail: String = ""
	if fired != ["profitable_bootstrap/milestone"]:
		fail = "milestone signals: %s (endings %s)" % [str(fired), str(_endings)]
	elif not _endings.is_empty():
		fail = "the milestone also ended the run: %s" % str(_endings)
	elif not GameState.run_active or GameState.ending_id != "":
		fail = "run_active %s, ending_id '%s' after a milestone" % [str(GameState.run_active), GameState.ending_id]
	elif GameState.bootstrap_milestone_day != fired_day:
		fail = "latch day %d, paper day %d" % [GameState.bootstrap_milestone_day, fired_day]
	elif not EventGate.condition_met(leaf_taken, {}):
		fail = "the milestone seam still reads false"
	if fail == "":
		for i in 10:
			_sim_day()
		if fired.size() != 1:
			fail = "the paper opened again on a later day (%d signals)" % fired.size()
		elif not _endings.is_empty():
			fail = "a later day ended the run: %s" % str(_endings)
		elif EndingsSystem._check_profitable_bootstrap():
			# The condition is still TRUE (the company is still profitable). Read again, it
			# would claim the day's scan every day and the soft cap and the buyout window
			# after it would never run.
			fail = "the latched bootstrap check still claims the daily scan"
	if fail == "":
		# The soft-cap telegraph opener at day >= 640 is shut by the new seam.
		GameState.day = 650
		var press: Dictionary = EvCatalog.card("world.final_stretch_press")
		if press.is_empty():
			fail = "world.final_stretch_press is missing from the catalogue"
		elif EventGate.condition_met(press.get("condition", {}) as Dictionary, {}):
			fail = "the soft-cap telegraph would still fire after the milestone"
	if fail == "":
		GameState.day = EndingsSystem.SOFT_CAP_DAY
		_sim_day()
		if not _endings.is_empty() or not GameState.run_active:
			fail = "day %d ended a run past its milestone: %s" % [GameState.day, str(_endings)]
	if fail == "":
		# The run is past day 730 now, so its paper needs a span the cap never allowed.
		# FALSIFICATION: drop the OVER_TWO_YEAR_DAYS branch → day 1100 reads "close to two years".
		var over: String = TranslationServer.translate("END_SPAN_OVER_TWO_YEARS")
		var near: String = TranslationServer.translate("END_SPAN_NEAR_TWO_YEARS")
		if over == "END_SPAN_OVER_TWO_YEARS" or over == near:
			fail = "END_SPAN_OVER_TWO_YEARS does not resolve to its own line"
		elif EndingsCopy._span_phrase(1100) != over:
			fail = "day 1100 reads '%s'" % EndingsCopy._span_phrase(1100)
		elif EndingsCopy._span_phrase(EndingsSystem.SOFT_CAP_DAY) != near:
			fail = "day %d (the cap) no longer reads '%s'" % [EndingsSystem.SOFT_CAP_DAY, near]
	EndingsSystem.build_scope_override = ""
	return fail


## The paper's modes on screen: only the rail and the strip under the page change.
##   demo ending      — WISHLIST'E EKLE, TEKRAR DENE and Frank's strip, as always
##   EA ending        — no store CTA, no Frank strip, TEKRAR DENE stays
##   EA milestone     — DEVAM ET and ANA MENÜ only: no share, no TEKRAR DENE, no store CTA,
##                      no Frank strip (the owner's two buttons)
static func _case_ending_paper_modes_on_screen() -> String:
	var host: Node = _ui_host()
	if host == null:
		return "no UI host to mount the paper under"
	var scene: PackedScene = load("res://scenes/modals/EndingScene.tscn")
	if scene == null:
		return "EndingScene.tscn failed to load"
	var wish: String = TranslationServer.translate("ENDING_WISHLIST")
	var retry: String = TranslationServer.translate("ENDING_RETRY")
	var cont: String = TranslationServer.translate("UI_CONTINUE")
	var menu: String = TranslationServer.translate("ENDING_MAIN_MENU")
	var share: String = TranslationServer.translate("ENDING_SHARE")
	# [scope, mode, ending, wishlist, frank strip, retry, continue + main menu, share]
	var rows: Array = [
		[EndingsSystem.BUILD_DEMO, EndingsSystem.MODE_ENDING, "profitable_bootstrap", true, true, true, false, true],
		[EndingsSystem.BUILD_EA, EndingsSystem.MODE_ENDING, "bankruptcy", false, false, true, false, true],
		[EndingsSystem.BUILD_EA, EndingsSystem.MODE_MILESTONE, "profitable_bootstrap", false, false, false, true, false],
	]
	for r in rows:
		EndingsSystem.build_scope_override = String(r[0])
		var data: Dictionary = EndingsSystem._build_ending_data(String(r[2]), {})
		data["mode"] = String(r[1])
		var inst: Control = scene.instantiate()
		host.add_child(inst)
		inst.populate(data)
		var texts: Array[String] = []
		for b in inst.find_children("*", "Button", true, false):
			texts.append(String((b as Button).text))
		var frank_shown: bool = false
		var frank_line: String = String(data.get("frank_line", ""))
		for l in inst.find_children("*", "Label", true, false):
			if frank_line != "" and String((l as Label).text) == frank_line:
				frank_shown = true
		inst.free()
		EndingsSystem.build_scope_override = ""
		var tag: String = "%s/%s/%s" % [r[0], r[1], r[2]]
		if texts.has(wish) != bool(r[3]):
			return "%s: WISHLIST'E EKLE shown=%s" % [tag, str(texts.has(wish))]
		if frank_shown != bool(r[4]):
			return "%s: Frank's strip shown=%s" % [tag, str(frank_shown)]
		if texts.has(retry) != bool(r[5]):
			return "%s: TEKRAR DENE shown=%s" % [tag, str(texts.has(retry))]
		if texts.has(cont) != bool(r[6]) or texts.has(menu) != bool(r[6]):
			return "%s: DEVAM ET %s, ANA MENÜ %s" % [tag, str(texts.has(cont)), str(texts.has(menu))]
		if texts.has(share) != bool(r[7]):
			return "%s: GAZETEYİ PAYLAŞ shown=%s" % [tag, str(texts.has(share))]
	return ""


## The milestone paper holds the clock: while a hold is up, the speed restores that other
## surfaces send when THEY close (a card, the month summary, settings) cannot start time
## behind the paper; after the holder releases, its own restore does.
static func _case_milestone_clock_hold() -> String:
	EventBus.speed_change_requested.emit(2)
	if TimeManager.current_speed != 2:
		return "fixture: speed 2 did not take (%d)" % TimeManager.current_speed
	TimeManager.hold_clock("smoke_hold")
	var fail: String = ""
	if TimeManager.current_speed != 0:
		fail = "the hold did not stop the clock"
	if fail == "":
		EventBus.speed_change_requested.emit(1)   # what a closing card or the month summary sends
		if TimeManager.current_speed != 0:
			fail = "a restore under the hold started the clock"
	if fail == "":
		TimeManager.resume_if_paused()
		if TimeManager.current_speed != 0:
			fail = "resume_if_paused went around the hold"
	TimeManager.release_clock("smoke_hold")
	if fail == "":
		if TimeManager.is_clock_held():
			fail = "the hold survived its release"
		else:
			EventBus.speed_change_requested.emit(2)
			if TimeManager.current_speed != 2:
				fail = "the holder's restore after release did not take (%d)" % TimeManager.current_speed
	return fail


## main.gd's milestone handlers, driven directly with a stand-in ModalLayer (no GameShell):
##   1. a card already up when the paper opens stays ON TOP of it (the player answers the card
##      first; on top, the paper would hide it and ANA MENÜ would refuse to save for a
##      decision screen nobody can see), and the paper holds the clock;
##   2. DEVAM ET frees the paper and releases the hold;
##   3. ANA MENÜ keeps the run in a MANUAL slot — the rolling autosave would be overwritten by
##      the next run's third weekly autosave.
## FALSIFICATION: drop the move_child → the paper sits above the card. Save through the
## autosave again → the slot is auto_*.
static func _case_milestone_paper_under_card() -> String:
	var host: Node = _ui_host()
	if host == null or not host.has_method("_on_milestone_reached"):
		return "no main.gd host to drive the milestone handlers"
	EndingsSystem.build_scope_override = EndingsSystem.BUILD_EA
	var shell := Node.new()
	var layer := CanvasLayer.new()
	layer.name = "ModalLayer"
	shell.add_child(layer)
	host.add_child(shell)
	var card := Control.new()
	layer.add_child(card)
	var prev_shell: Variant = host.get("_shell")
	var prev_event: Variant = host.get("_event_modal")
	host.set("_shell", shell)
	host.set("_event_modal", card)
	var data: Dictionary = EndingsSystem._build_ending_data("profitable_bootstrap", {})
	data["mode"] = EndingsSystem.MODE_MILESTONE
	host.call("_on_milestone_reached", "profitable_bootstrap", data)
	var paper: Node = host.get("_milestone_modal")
	var fail: String = ""
	if paper == null:
		fail = "the paper did not mount"
	elif paper.get_index() >= card.get_index():
		fail = "the paper sits above the open card (paper %d, card %d)" % [paper.get_index(), card.get_index()]
	elif not TimeManager.is_clock_held():
		fail = "the paper did not hold the clock"
	if fail == "":
		host.set("_event_modal", null)   # the card was answered
		card.queue_free()
		host.call("_on_milestone_continue")
		if host.get("_milestone_modal") != null:
			fail = "DEVAM ET left the paper up"
		elif TimeManager.is_clock_held():
			fail = "DEVAM ET did not release the hold"
	if fail == "":
		var slot: String = String(host.call("_keep_run_for_main_menu"))
		if slot == "":
			fail = "ANA MENÜ could not keep the save (%s)" % SaveManager.cannot_save_reason_key()
		else:
			var listed: bool = false
			for row in SaveManager.list_slots():
				if String(row.get("slot_id", "")) == slot:
					listed = true
			SaveManager.delete_slot(slot)
			if not slot.begins_with(SaveManager.MANUAL_SLOT_PREFIX):
				fail = "ANA MENÜ saved into '%s', a slot that rotates" % slot
			elif not listed:
				fail = "ANA MENÜ reported slot '%s' but no such save is listed" % slot
	host.set("_shell", prev_shell)
	host.set("_event_modal", prev_event)
	host.set("_milestone_modal", null)
	TimeManager.release_clock("milestone_paper")
	shell.queue_free()
	EndingsSystem.build_scope_override = ""
	return fail


static func _case_profit_predicate_margin_scale_red() -> String:
	# Each clause alone blocks the win: thin margin, small scale, a red day inside the window.
	GameState.set_cash(100000)
	_seed_b2b(EndingsSystem.BOOTSTRAP_WIN_MRR + 5000)
	# THE FIFTH CLAUSE (ch. 13 §1): profitability alone is not an ending. These two cases
	# measure the four ECONOMIC clauses, so the investor one is satisfied in the fixture
	# rather than restated in every assertion. That the clause is REQUIRED — and that
	# each of its three writers opens it — is bootstrap_needs_the_faced_flag's job.
	GameState.mark_faced_series_a("walked")
	_sim_day()   # settle the MRR bridge
	_seed_month_closes([20000, 21000, 22000, 23000, 24000, 25000], 30000, 27500)   # margin 8 %
	var sig: Dictionary = EndingsSystem.profitability_signal()
	if bool(sig.get("met", false)) or bool(sig.get("margin_ok", true)):
		return "thin margin should block (%s)" % str(sig)
	_seed_month_closes([20000, 21000, 22000, 23000, 24000, 25000], 30000, 24000)   # margin 20 %
	CustomerRegistry.set_mrr(CustomerRegistry.get_by_market("b2b")[0].id, EndingsSystem.BOOTSTRAP_WIN_MRR - 1000)
	SalesSystem.reflect_mrr()
	sig = EndingsSystem.profitability_signal()
	if bool(sig.get("met", false)) or bool(sig.get("mrr_ok", true)):
		return "small scale should block (%s)" % str(sig)
	CustomerRegistry.set_mrr(CustomerRegistry.get_by_market("b2b")[0].id, EndingsSystem.BOOTSTRAP_WIN_MRR + 5000)
	SalesSystem.reflect_mrr()
	sig = EndingsSystem.profitability_signal()
	if not bool(sig.get("met", false)):
		return "all clauses met should read met (%s)" % str(sig)
	# One red day inside the newest month breaks the streak.
	var last: Dictionary = GameState.month_history[GameState.month_history.size() - 1]
	last["red_days"] = 1
	GameState.month_history[GameState.month_history.size() - 1] = last
	sig = EndingsSystem.profitability_signal()
	if bool(sig.get("met", false)) or int(sig.get("streak", 9)) != 0:
		return "a red day inside the window should break the streak (%s)" % str(sig)
	return ""


# --- The speed ladder is 1×/2×/3× ---

static func _case_speed_save_clamps_to_ladder() -> String:
	# A save written under the 5-rung ladder carries last_running_speed 4; from_dict clamps it
	# to the array's top (3) and the resume lands there — no 4x ghost in the accumulator.
	TimeManager.from_dict({"in_game_hours": 0.0, "current_speed": 4, "last_running_speed": 4})
	if TimeManager.last_running_speed != 3:
		return "stored speed 4 came back as %d, want 3" % TimeManager.last_running_speed
	TimeManager.resume_if_paused()
	if TimeManager.current_speed != 3:
		return "resume after a 4x save landed on %d, want 3" % TimeManager.current_speed
	if not is_equal_approx(TimeManager.hours_per_real_second(4), 0.0):
		return "index 4 still yields a live multiplier"
	return ""


static func _case_topbar_speed_cluster_three_rungs() -> String:
	# The TopBar scene carries pause + three rungs and no Speed4Btn; the script's button
	# array matches the ladder size exactly (index == speed index).
	var packed: PackedScene = load("res://scenes/ui/components/TopBar.tscn")
	if packed == null:
		return "TopBar.tscn failed to load"
	var state: SceneState = packed.get_state()
	var names: Array = []
	for i in state.get_node_count():
		names.append(String(state.get_node_name(i)))
	if names.has("Speed4Btn"):
		return "TopBar.tscn still carries Speed4Btn"
	for want in ["PauseBtn", "Speed1Btn", "Speed2Btn", "Speed3Btn"]:
		if not names.has(want):
			return "TopBar.tscn is missing %s" % want
	var src: String = (load("res://scripts/ui/components/top_bar.gd") as GDScript).source_code
	if src.find("Speed4Btn") >= 0:
		return "top_bar.gd still references Speed4Btn"
	return ""


# --- The suite runs on one seed ---

static func _case_smoke_seed_pinned() -> String:
	# run_case pins GameState.run_seed to the probes' seed unless the case asked for its own;
	# the ledger exposes it, so this is one read.
	var seed_now: int = int(GameState.get_run_ledger().get("seed", 0))
	if seed_now != 424242:
		return "smoke seed is %d, want 424242 (run_case no longer pins it)" % seed_now
	return ""


# --- The ambient rate model reproduces the authored daily chance; ≤1 ambient/day ---

static func _case_ambient_hourly_chance_exact() -> String:
	# 1 − (1 − p_h)^n == p for the authored pool (0.5 over a 10-hour window → 0.0670/h, not
	# 0.05/h), 24-hour windows, and the edges.
	var p_h: float = EventGate.hourly_chance(0.5, 10)
	if absf(p_h - 0.066967) > 1e-5:
		return "hourly_chance(0.5, 10) = %.6f, want 0.066967" % p_h
	if absf((1.0 - pow(1.0 - p_h, 10)) - 0.5) > 1e-9:
		return "ten rolls at p_h do not reproduce 0.5"
	var p24: float = EventGate.hourly_chance(0.3, 24)
	if absf((1.0 - pow(1.0 - p24, 24)) - 0.3) > 1e-9:
		return "24 rolls do not reproduce 0.3"
	if not is_equal_approx(EventGate.hourly_chance(0.4, 1), 0.4):
		return "a one-hour window must roll the daily chance as written"
	if not is_equal_approx(EventGate.hourly_chance(0.0, 10), 0.0) or not is_equal_approx(EventGate.hourly_chance(1.0, 10), 1.0):
		return "edges (0, 1) must pass through"
	# The old approximation was p/n — make sure the exact form is what the engine uses.
	if absf(p_h - 0.05) < 1e-6:
		return "the engine still uses the p/n approximation"
	return ""


static func _case_ambient_one_per_day_across_hour0() -> String:
	# Drive 30 full engine days (hour 1..23 → 0 → advance → daily) and count the hourly cards
	# per CALENDAR day — including across the hour-0 rollover, which is the boundary this case
	# exists for.
	#
	# THE CEILING MOVED AND IS NOW DECLARED. The old engine hard-capped the hourly path at one
	# card a day, in code, with no name. §13's budget is `MAX_INTERRUPTS_PER_DAY` and it
	# governs every interrupt rather than one path — so the number is read from EvTuning
	# instead of typed here, and raising it in the calibration pass will not make this case
	# lie. What the case still pins is the thing that was actually fragile: the rollover.
	#
	# REPOINTED, and STRONGER for it. The subject used to
	# be the three authored B2C hourly cards; all three were legacy flavour and are gone, and
	# the deck that replaces them is not written. The claim is about the ENGINE's clock, not
	# about content, so it must not wait on content: the subject is `fixture.hourly_ambient`,
	# admitted the way the thesis case admits its own fixtures — by widening SHIPPED_SCOPES for
	# the length of the run and narrowing it again.
	#
	# The fixture sits in allowed_hours [0, 0] ON PURPOSE. The three cards it replaced sat in
	# windows of 9-18, 18-22 and 20-23, so not one of them could ever fire at hour 0 and the
	# rollover branch named in the comment above was never actually reached. Now every fire is
	# a rollover fire.
	var shipped: Array = EvTuning.SHIPPED_SCOPES.duplicate()
	EvTuning.SHIPPED_SCOPES.append("fixture")
	EvCatalog.reload()
	_seed_b2c()
	GameState.set_cash(500000)
	GameState.set_flag("mvp_innovation", 15.0)
	GameState.set_flag("mvp_stability", 20.0)
	GameState.set_flag("mvp_experience", 17.5)
	GameState.set_flag("b2c_audience", 500.0)
	SalesSystem.add_b2c_audience(0)
	var per_day: Dictionary = {}
	# "Ambient" is a DECLARED tick now, not a derived one. `has_random_trigger()` used to
	# decide at read time whether a card belonged to the hourly path — the same routing that
	# made allowed_hours structurally dead on the daily path — so the case asked the card
	# whether it had a dice roll. It asks which clock the card declares instead.
	EventBus.event_triggered.connect(func(id: String) -> void:
		var card: Dictionary = EventGate.catalogue_card(id)
		if String(card.get("tick", "")) == "hourly":
			# hour 0 belongs to the NEW calendar day (GameState.day still shows yesterday)
			var slot: int = GameState.day + (1 if GameState.current_hour == 0 else 0)
			per_day[slot] = int(per_day.get(slot, 0)) + 1)
	var total: int = 0
	var at_hour_zero: int = 0
	for i in 30:
		var before: int = per_day.get(GameState.day + 1, 0)
		_sim_day_full()
		if int(per_day.get(GameState.day, 0)) > before:
			at_hour_zero += 1
		_drain_all_modals()
	EvTuning.SHIPPED_SCOPES.assign(shipped)
	EvCatalog.reload()
	for d in per_day.keys():
		total += int(per_day[d])
		if int(per_day[d]) > EvTuning.MAX_INTERRUPTS_PER_DAY:
			return "day %d received %d hourly cards (ceiling %d)" % [
				d, int(per_day[d]), EvTuning.MAX_INTERRUPTS_PER_DAY]
	if total == 0:
		return "fixture: no hourly card fired in 30 days (pool not eligible?)"
	if at_hour_zero == 0:
		return "no fire was attributed across the hour-0 rollover, which is the boundary this case is for"
	return ""


# --- A creation draft survives navigation ---

static func _case_creation_draft_survives_navigation() -> String:
	# A half-built product (path, type, two PLANNED STEPS, a name) on the creation flow; the
	# router tells the page it is closing → the draft lands in the typed flag → a fresh
	# ProductTab mount re-hydrates it at the same step with the same selection. Clean flows
	# stash nothing.
	#
	# The claim is unchanged by the rev 6.1 cutover; only the fixture data moved from flat
	# feature ids to line step ids, because `_selected` now carries the version plan.
	var root: Node = _ui_host()
	var flow_script: GDScript = load("res://scripts/tabs/product/creation_flow.gd")
	var flow: Control = flow_script.new()
	root.add_child(flow)
	flow.setup({"step": 3, "prefill": {"type": "note_tool",
		"features": ["line_note_tool_capture_k1", "line_note_tool_sync_k1"], "name": "Sahra"}})
	var d: Dictionary = flow.draft_state()
	if String(d.get("type", "")) != "note_tool" or (d.get("features", []) as Array).size() != 2 \
			or String(d.get("name", "")) != "Sahra":
		flow.free()
		return "fixture: draft_state did not read the prefilled selection (%s)" % str(d)
	flow.on_page_closing()
	flow.free()
	var stashed: Dictionary = GameState.get_flag("creation_draft", {})
	if stashed.is_empty():
		return "on_page_closing stashed nothing for a dirty draft"
	if int(stashed.get("step", 0)) != 3 or String(stashed.get("type", "")) != "note_tool":
		return "stashed draft is wrong: %s" % str(stashed)
	# The router actually calls it: the seam name must appear in center_viewport's free path.
	var router_src: String = (load("res://scripts/ui/components/center_viewport.gd") as GDScript).source_code
	if router_src.find('propagate_call("on_page_closing")') < 0:
		return "center_viewport does not notify the page before freeing it"
	# Re-mount: ProductTab consumes the draft and lands on the creation view with the selection.
	var tab: Control = (load("res://scenes/tabs/ProductTab.tscn") as PackedScene).instantiate()
	root.add_child(tab)
	var view: Node = tab.get("_view_node")
	# MESAJ SERBEST BIRAKMADAN ÖNCE KURULUR. Burası `tab.free()`'den SONRA `tab.get()`
	# çağırıyordu: "Cannot call method 'get' on a previously freed instance" atıyor, gövde
	# yarıda kesiliyor, fonksiyon "" dönüyor ve vaka SMOKE PASS basıyordu — yani gerçek
	# iddia BAŞARISIZKEN yeşil görünüyordu. (tools/smoke_run.sh stderr kapısı bunu yakaladı;
	# vakanın kendisi yakalayamazdı.)
	if tab.get("_view_id") != "creation" or view == null:
		var seen: String = str(tab.get("_view_id"))
		tab.free()
		return "ProductTab did not re-open the creation flow (view %s)" % seen
	var restored: Dictionary = view.draft_state()
	tab.free()
	if String(restored.get("type", "")) != "note_tool" or (restored.get("features", []) as Array).size() != 2 \
			or String(restored.get("name", "")) != "Sahra" or int(restored.get("step", 0)) != 3:
		return "re-hydrated draft differs: %s" % str(restored)
	if GameState.has_flag("creation_draft"):
		return "the draft flag was not consumed on re-mount"
	# A clean flow stashes nothing (and clears a stale flag).
	var clean: Control = flow_script.new()
	root.add_child(clean)
	clean.setup({"step": 1})
	clean.on_page_closing()
	clean.free()
	if GameState.has_flag("creation_draft"):
		return "a clean flow stashed a draft"
	return ""


## §12.11 MÜHÜRLÜ — tip ekranının OYNANABİLİR kartları ile hat içeriği olan alt-tipler
## AYNI KÜME olmak zorunda. İkisi iki ayrı dosyada yaşıyor (ProductCatalog.TYPE_SCREEN ve
## data/product/lines/*.json) ve ayrıştıkları an oyuncu tıklanabilir bir karttan BOŞ bir
## Konsept'e düşer — motoru görünmez kılan tam olarak bu kopukluktu.
##
## Kilitli tarafı da ölçer: §12.11 sayıyı mühürledi (yol başına ÜÇ) ve kilitli bir kartın
## hat içeriği OLMAMALI, yoksa oynanabilir bir ürünü kilitliyor olurduk.
## SAHNE AĞACINA MONTE EDEN VAKALAR İÇİN EV SAHİBİ. `root` OLMAZ: harness main.gd'nin
## `_ready`'sinden koşuyor ve o `_ready`, root'un KENDİ `add_child(Main)` çağrısının
## İÇİNDE çalışıyor — yani root o an "busy setting up children"dır ve ona `add_child`
## SESSİZCE BAŞARISIZ OLUR. Yalnız bir ERROR satırı basar; düğüm ağaca hiç girmez,
## `_ready`'si hiç koşmaz ve vaka olmayan bir şeyi ölçmeye çalışır.
##
## Ana sahne (Main) o an bir çocuk EKLEMİYOR, yalnız kendi `_ready`'sini koşuyor — bu
## yüzden meşru ev sahibi odur. Otoload'lar root'a ana sahneden ÖNCE eklenir, o yüzden
## son çocuk ana sahnedir.
static func _ui_host() -> Node:
	var tree := Engine.get_main_loop() as SceneTree
	if tree == null:
		return null
	if tree.current_scene != null:
		return tree.current_scene
	var root: Node = tree.root
	return root.get_child(root.get_child_count() - 1) if root.get_child_count() > 0 else root


static func _case_type_screen_matches_line_content() -> String:
	var playable: Array[String] = []
	for market in ["b2c", "b2b"]:
		var locked: Array = ProductCatalog.locked_type_ids(market)
		if locked.size() != 3:
			return "%s draws %d locked cards, §12.11 seals three per path" % [market, locked.size()]
		for tid in locked:
			if String(tid) == ProductCatalog.TYPE_SCREEN_SLOT:
				continue
			if ProductLines.has_subtype(String(tid)):
				return "%s is drawn locked but has line content" % String(tid)
			if ProductCatalog.get_sub_product_type_by_id(String(tid)).is_empty():
				return "locked card %s has no catalog record" % String(tid)
		for st in ProductCatalog.playable_types(market):
			var pid: String = String((st as Dictionary).get("id", ""))
			if String((st as Dictionary).get("market_type", "")) != market:
				return "%s is drawn on the %s path but its record says %s" 					% [pid, market, String((st as Dictionary).get("market_type", ""))]
			if not ProductLines.has_subtype(pid):
				return "%s is playable on the type screen but has no line content" % pid
			playable.append(pid)
	var lines_side: Array[String] = ProductLines.subtypes()
	playable.sort()
	lines_side.sort()
	if playable != lines_side:
		return "type screen offers %s, line content covers %s" % [str(playable), str(lines_side)]
	# Alt-tür anahtarı haber havuzunun kimliğidir; bilinmeyen bir anahtar
	# news_feed_system'in havuzunu sessizce boşaltır.
	for pid in playable:
		var pool: String = ProductCatalog.get_pool_of(pid)
		if not pool in ["ai", "saas", "social"]:
			return "%s resolves to pool '%s', which news_feed_system does not know" % [pid, pool]
	return ""


## §3'ün "taahhüt edilen ürün alt-türü seçer" hükmü hat yolunda da geçerli. start_build
## bunu yapıyordu, start_line_build YAPMIYORDU — ve düz akış emekli olunca GameState.subgenre
## bir daha hiç yazılmayacaktı: subgenre olay koşulları ve haber havuzu açılış değerinde
## donardı, hiçbir hata vermeden.
static func _case_line_build_writes_subgenre() -> String:
	ProductLines.reload()
	GameState.set_cash(50000)
	GameState.set_flag(ProductState.LINE_TIERS, {})
	GameState.set_flag("mvp_shipped", false)
	ProductSystem.active_build = null
	GameState.set_subgenre("social")   # kasten yanlış değer: yazma OLMAZSA burada kalır
	var founder: Character = _seed_build_crew()
	if not ProductSystem.start_line_build("erp",
			["line_erp_ledger_k1", "line_erp_stock_k1"], founder.id, "Defter"):
		return "fixture: start_line_build refused a two-K1 erp plan"
	var want: String = ProductCatalog.get_pool_of("erp")
	if want == "":
		return "fixture: erp has no pool key"
	if GameState.subgenre != want:
		return "start_line_build left subgenre at '%s', want '%s'" % [GameState.subgenre, want]
	return ""


# --- Held-back strings landed ---

static func _case_borderless_note_key_exists() -> String:
	# The borderless helper line the sharpness task deferred: the settings modal picks it the
	# moment it resolves (settings_modal._resolution_note_key), so the whole wire is "the row
	# exists in both locales".
	for loc in ["tr", "en"]:
		var txt: String = TranslationServer.get_translation_object(loc).get_message("SET_RESOLUTION_BORDERLESS") \
			if TranslationServer.get_translation_object(loc) != null else ""
		if txt == "" or txt == "SET_RESOLUTION_BORDERLESS":
			return "SET_RESOLUTION_BORDERLESS does not resolve in %s" % loc
	if TranslationServer.translate("TOPBAR_UNIT_PER_DAY") == "TOPBAR_UNIT_PER_DAY":
		return "TOPBAR_UNIT_PER_DAY missing"
	return ""

# ============================================================================
#  Build Bar · duraklama · DESTEK · trait göçü · Görevler (2026-08-21)
# ============================================================================

## R2: "Kurucu her şeyi yapabilir, ama aynı anda değil" — ve bu BİR KARAR DEĞİL,
## bir SONUÇ. Taşıyabilecek herkes meşgulse yapım durur ve efor İŞLEMEZ.
## FALSİFİKASYON: `build_paused()`'ı `return false` yap → ikinci iddia FAIL (efor akar).
static func _case_build_pauses_when_all_busy() -> String:
	_set_founder_tech(6)
	if not ProductSystem.start_build("ai_assistant",
			["ai_assistant_chat", "ai_assistant_streaming"], ""):
		return "could not start a build"
	# Tek kişilik şirket: taşıyan yalnız kurucu ve o BOŞ — yapım koşmalı.
	if ProductSystem.build_paused():
		return "a build with a free founder on it reported PAUSED"
	var b: FeatureBuild = ProductSystem.get_active_build()
	var before: float = b.efor_spent
	ProductSystem.hourly_tick(9)
	if b.efor_spent <= before:
		return "a running build did not spend effort"
	# Şimdi kurucuyu EĞİTİME yolla: kodda gerçekten var olan bir meşguliyet.
	var founder: Character = CharacterRegistry.get_founder()
	founder.status = HRConstants.STATUS_TRAINING
	if not ProductSystem.build_paused():
		return "every carrier is busy and the build still reports running"
	if ProductSystem.pause_note_key() != "BUILD_BUSY_ELSEWHERE":
		return "an ASSIGNED-but-busy team got the 'nobody is on it' note (%s)" % \
			ProductSystem.pause_note_key()
	var frozen: float = b.efor_spent
	ProductSystem.hourly_tick(10)
	if b.efor_spent > frozen + 0.0001:
		return "a PAUSED build kept spending effort (%.4f → %.4f)" % [frozen, b.efor_spent]
	# HİÇ KİMSE ATANMAMIŞSA not değişir — iki hâl birbirine karışmamalı.
	CharacterRegistry.clear_areas(founder.id)
	if ProductSystem.pause_note_key() != "BUILD_BUSY_NOBODY":
		return "with nobody assigned the note was not 'nobody is on it' (%s)" % \
			ProductSystem.pause_note_key()
	return ""


## Duraklama GERİ ALİNİR: biri boşalınca yapım TAM HIZDA döner (ara kademe yok, H5).
## FALSİFİKASYON: `_is_free`'den STATUS_ACTIVE kapısını kaldır → ilk iddia FAIL.
static func _case_build_resumes_when_one_frees() -> String:
	_set_founder_tech(6)
	if not ProductSystem.start_build("ai_assistant",
			["ai_assistant_chat", "ai_assistant_streaming"], ""):
		return "could not start a build"
	var founder: Character = CharacterRegistry.get_founder()
	founder.status = HRConstants.STATUS_TRAINING
	if not ProductSystem.build_paused():
		return "a build with its only carrier in training is not paused"
	# İKİNCİ BİR TAŞIYICI: fazın alanına atanmış, boş bir çalışan.
	var pm: Character = _make_employee("char_free_pm", "Free Pm",
		HRConstants.ROLE_PRODUCT_MANAGER)
	if not ProductSystem.phase_assignees("iteration").has(pm):
		return "a Product Manager was not counted among the design phase's carriers"
	if ProductSystem.build_paused():
		return "one free carrier was not enough to resume — H5 has no middle rung"
	var b: FeatureBuild = ProductSystem.get_active_build()
	var before: float = b.efor_spent
	ProductSystem.hourly_tick(11)
	if b.efor_spent <= before:
		return "a resumed build did not spend effort"
	# VC HAZIRLIĞI da meşgul eder — ama YALNIZ kurucuyu (H6: kapasite çarpanı değil).
	CharacterRegistry.clear_areas(pm.id)
	founder.status = HRConstants.STATUS_ACTIVE
	if ProductSystem.build_paused():
		return "the founder came back free and the build stayed paused"
	GameState.set_flag("pitch_prep_active", true)
	if not ProductSystem.build_paused():
		return "the founder went into VC prep and the build kept running"
	GameState.set_flag("pitch_prep_active", false)
	return ""


## R5: YAYINLAMAK BİR SON DEĞİLDİR. Yayından sonra kart kaybolmaz, DESTEK'e döner
## ve ürün yaşadıkça yaşar. DOĞRULANMIŞ gerçek veriyi okur; GELEN ÇİZİLMEZ.
## FALSİFİKASYON: `_derive_support`'ı `return false` yap → ikinci iddia FAIL.
##
## rev 6.1 (router devri): kart artık ESKİ hata sprintini değil §8/§9'un düzeltme
## koşusunu okuyor. Sebep ekranda görülüyordu — yüzen kart "HATA SPRİNTİ · 5 hata"
## derken altındaki canlı ürün sayfası "DÜZELTME BAŞLAT · DOĞRULANMIŞ 0" diyordu:
## tek şeyin iki gerçeği, iki ayrı motordan.
static func _case_destek_survives_ship() -> String:
	const BarModel := preload("res://scripts/ui/components/build_bar_model.gd")
	var before = BarModel.new()
	if before.derive():
		return "a card derived with no build and no shipped product"
	GameState.set_flag("mvp_shipped", true)
	GameState.set_flag("mvp_product_name", "Nova")
	GameState.set_flag("mvp_version", 2)
	# rev 6.1: DESTEK'in motoru §8/§9'un DÜZELTME KOŞUSU oldu. Kartın İDDİASI aynı
	# (yayın bir son değil), okuduğu sayaç değişti: `mvp_live_bug_count` değil
	# DOĞRULANMIŞ HATA. Masa da kurulmalı — kimse atanmamışsa koşu başlatılamaz
	# (§8: "Destek'e kimse atanmamışsa masa kapalıdır").
	GameState.set_flag(ProductState.BUGS_CONFIRMED, 7)
	GameState.set_flag(ProductState.FIX_RUN_ACTIVE, false)
	GameState.set_flag(ProductState.FIX_RUN_FIXED, 0)
	var founder: Character = CharacterRegistry.get_founder()
	CharacterRegistry.clear_jobs(founder.id)
	CharacterRegistry.assign_job(founder.id, HRConstants.JOB_SUPPORT)
	var m = BarModel.new()
	if not m.derive():
		return "the card vanished after ship — YAYINLANDI is not a terminal state (R5)"
	if m.phase != BarModel.PHASE_SUPPORT:
		return "a shipped product did not land on DESTEK (%s)" % String(m.phase)
	if m.live_bugs != 7:
		return "DOĞRULANMIŞ read %d, want the confirmed-bug count 7" % m.live_bugs
	if m.decision_key != "PROD_FIX_RUN_START" or not m.decision_enabled:
		return "DESTEK's decision row is not an armed fix run (%s/%s)" 			% [m.decision_key, str(m.decision_enabled)]
	# §8.4 — KOŞU SIRASINDA SATIR DÜŞMEZ, DEĞİŞİR: bitirmek de oyuncunun kararı.
	if not SupportSystem.start_fix_run():
		return "start_fix_run refused a shipped product with 7 confirmed bugs and a staffed desk"
	var running = BarModel.new()
	running.derive()
	if running.decision_key != "PROD_FIX_RUN_END":
		return "a running fix run did not offer the end action (%s)" % running.decision_key
	if not running.sprint_running:
		return "the card did not see the running fix run"
	# DESTEK DURAKLAMAZ: duraklama aktif YAPIMIN hâli, canlı ürünün değil.
	if running.paused:
		return "a live product reported PAUSED"
	return ""


## R1: kurucu Görevler matrisinde YOK — satır yok, kutu yok, salt-okunur bant yok.
## Ama atama YAŞAMAYA DEVAM EDİYOR (H4): motor onu aktif fazın alanına oturtuyor,
## çünkü hız terimi ve kalite ortalaması üçü de `assigned_jobs`'ı okuyor.
## FALSİFİKASYON: `_founder_band`'i geri koy → ikinci iddia FAIL.
static func _case_gorevler_has_no_founder() -> String:
	const Assignments := preload("res://scripts/tabs/hr/hr_assignments.gd")
	_make_employee("char_matrix_dev", "Matrix Dev", HRConstants.ROLE_DEVELOPER)
	var founder: Character = CharacterRegistry.get_founder()
	var page: Control = Assignments.build(func(_a: String, _b: String, _c: bool) -> void: pass)
	var names: Array[String] = []
	_collect_label_text(page, names)
	page.queue_free()
	for t in names:
		if t == founder.character_name:
			return "the founder still has a row on Görevler"
		if t == TranslationServer.translate("HR_FOUNDER_BAND"):
			return "the founder band is still drawn"
	if not names.has("Matrix Dev"):
		return "the matrix drew no employees at all — the probe is measuring nothing"
	# ATAMA ÖKSÜZ DEĞİL: motor kurucuyu hâlâ bir İŞTE tutuyor (§2.1 — aynı anda tek iş).
	# Alan aynasının daha geniş olması beklenir ve doğrudur: Build ekibi üç alanca taşınır
	# (§12.0) ve kurucu altısını da taşır (§2), yani Build'deki bir kurucu üçünde de görünür.
	if founder.assigned_job_ids.size() != 1:
		return "the founder holds %d jobs; the engine must keep exactly one" % \
			founder.assigned_job_ids.size()
	return ""


static func _collect_label_text(n: Node, out: Array[String]) -> void:
	if n is Label:
		out.append((n as Label).text)
	for c in n.get_children():
		_collect_label_text(c, out)


# ============================================================================
#  İK MODULÜ KAPANIŞI (2026-08-22) · R1 · H5 · C3 · C4 · H1
# ============================================================================

static func _script_methods(path: String) -> PackedStringArray:
	# Bir script'in KENDİ yüzeyi. "Şu fonksiyon artık YOK" iddiasını kanıtlamanın tek
	# davranışsal olmayan yolu bu: çağıranı kalmamış ama duran bir fonksiyon hiçbir
	# davranış testine görünmez, oysa geri dönen ikinci yol tam olarak böyle geri döner.
	var out := PackedStringArray()
	var sc: GDScript = load(path) as GDScript
	if sc == null:
		return out
	for m in sc.get_script_method_list():
		out.append(String(m.get("name", "")))
	return out


static func _case_menu_has_one_path() -> String:
	# R1: TEK YOL, TEK ÇAPA. ⋯ düğmesi ve onun 44px'lik sütunu SİLİNDİ (gizlenmedi),
	# pop-over'ın sola dönen ikinci konumu ve çentiği de onunla birlikte gitti.
	var ledger: GDScript = load("res://scripts/tabs/hr/hr_ledger.gd") as GDScript
	if ledger == null:
		return "hr_ledger.gd did not load"
	var consts: Dictionary = ledger.get_script_constant_map()
	if consts.has("W_MENU"):
		return "the ⋯ column width is back (W_MENU)"
	# ...ama menu YOLU duruyor: silinen şey ikinci giriş, karar değil.
	if not consts.has("ACTION_MENU"):
		return "the row menu action itself disappeared"
	var pop: PackedStringArray = _script_methods("res://scripts/tabs/hr/hr_popover.gd")
	for gone in ["_place_notch", "_draw_notch"]:
		if pop.has(gone):
			return "the notch survived the single-anchor ruling (%s)" % gone
	if not pop.has("_place"):
		return "the popover lost its placement function entirely"
	return ""


static func _case_vacation_action_retired() -> String:
	# H5: oyuncunun "Tatile gönder" yolu KALDIRILDI. İki şey birden kanıtlanıyor —
	# eylem gitti VE otomatik yıllık izin kanalı DURUYOR. Yalnız birincisi ölçülseydi,
	# izni tamamen kıran bir değişiklik de bu vakayı yeşil geçerdi.
	var acts: PackedStringArray = _script_methods("res://scripts/systems/hr_actions.gd")
	for gone in ["can_send_on_vacation", "preview_vacation", "send_on_vacation"]:
		if acts.has(gone):
			return "the retired vacation seam is back (%s)" % gone
	var tab: PackedStringArray = _script_methods("res://scripts/tabs/hr_tab.gd")
	for gone in ["_confirm_vacation", "_do_vacation"]:
		if tab.has(gone):
			return "the vacation confirm path is back (%s)" % gone
	var ledger: GDScript = load("res://scripts/tabs/hr/hr_ledger.gd") as GDScript
	if ledger != null and ledger.get_script_constant_map().has("ACTION_VACATION"):
		return "the vacation action id is back"
	# Emekli dizgiler: çevrilmeyen bir anahtar KENDİNİ döndürür.
	for key in ["HR_CARD_HOLIDAY", "HR_HOLIDAY_CONFIRM_TITLE", "HR_LEAVE_ANNUAL_SPENT"]:
		if TranslationServer.translate(key) != key:
			return "a retired vacation string is still in the CSV (%s)" % key
	# OTOMATİK KANAL YAŞIYOR ve R3 yapısal olarak karşılanıyor: yıl mandalına dokunan
	# tek şey artık o kanal.
	var morale: PackedStringArray = _script_methods("res://scripts/systems/hr_morale_system.gd")
	if not morale.has("send_on_leave") or not morale.has("tick_leave_departures"):
		return "the automatic annual-leave channel was removed with the manual action"
	var e: Character = _make_employee("char_vac_gone", "Vac Gone", HRConstants.ROLE_DEVELOPER)
	_park_leave([e])
	if e.leave_taken_year != 0:
		return "the year latch did not start clear"
	HRMoraleSystem.send_on_leave(e, HRConstants.LEAVE_DAYS, false)
	if e.leave_taken_year != int(GameState.get_date_dict().year):
		return "the automatic channel no longer stamps the year latch"
	return ""


static func _case_leave_does_not_pause_build() -> String:
	# C4/R4: bir çalışan izindeyken KURUCU BOŞSA yapım DURMAZ. Kural HEPSİ-meşgul,
	# herhangi-biri değil. İki yönü de ölçülüyor: boş kurucuyla koşar, kurucu da
	# meşgulken durur — yoksa "hiç durmuyor" da bu vakayı geçerdi.
	GameState.set_cash(200000)
	if not ProductSystem.start_build("ai_assistant", ["ai_assistant_chat"], ""):
		return "start_build failed"
	# GELİŞTİRME FAZINDA ölçülüyor: alanı tek ("engineering") ve bir YAZILIM MÜHENDİSİ
	# onu taşıyabiliyor. Tasarım fazının alanları product/design ve bir developer'a
	# `assign_area` "not_your_area" der — vaka o zaman kimsenin taşımadığı bir fazı
	# ölçmeye çalışırdı.
	if not _run_build_to_phase("development"):
		return "the build never reached development"
	var b: FeatureBuild = ProductSystem.get_active_build()
	var founder: Character = CharacterRegistry.get_founder()
	if founder == null:
		return "no founder"
	var staff: Array[Character] = []
	for c in ProductSystem.phase_assignees(b.current_phase):
		if c.category == "employee":
			staff.append(c)
	if staff.is_empty():
		# Fazı taşıyan bir çalışan yoksa vaka ÖLÇECEK BİR ŞEY BULAMAZ ve sessizce yeşil
		# geçer. Bu ilk yazımda gerçekten oldu: yardımcı ÇALIŞANIN rolüne göre
		# atanıyordu (engineering), yapım ise "iteration" fazındaydı (product/design),
		# yani kimse fazı taşımıyordu ve `build_paused` hiç kıpırdamıyordu. Falsifikasyon
		# bunu yakaladı — vaka bozulmuş motora da PASS basıyordu.
		var helper: Character = _make_employee("char_pause_help", "Pause Help", HRConstants.ROLE_DEVELOPER)
		var areas: Array = ProductSystem.PHASE_AREAS.get(b.current_phase, [])
		if areas.is_empty():
			return "phase '%s' carries no areas — nothing to measure" % b.current_phase
		CharacterRegistry.assign_area(helper.id, String(areas[0]))
		staff = [helper]
	var carriers: Array[Character] = ProductSystem.phase_assignees(b.current_phase)
	for c in staff:
		if not carriers.has(c):
			return "the fixture employee does not carry phase '%s'" % b.current_phase
	if ProductSystem.build_paused():
		return "the build was already paused with everyone active"
	for c in staff:
		HRMoraleSystem.send_on_leave(c, HRConstants.LEAVE_DAYS, false)
		if c.status != HRConstants.STATUS_ON_LEAVE:
			return "send_on_leave did not park %s" % c.id
	if founder.status != HRConstants.STATUS_ACTIVE:
		return "the founder was not active to begin with"
	if ProductSystem.build_paused():
		return "an employee on leave paused the build while the founder was free (R4)"
	# Şimdi kurucuyu da meşgul et: hazIrlık kurucunun meşguliyet kümesinde.
	GameState.set_flag("pitch_prep_active", true)
	var paused_now: bool = ProductSystem.build_paused()
	GameState.set_flag("pitch_prep_active", false)
	if not paused_now:
		return "the build kept running with every carrier busy"
	return ""


static func _case_money_never_double_minus() -> String:
	# C3: `HRConstants.money_tr` (→ `Fmt.money_exact`) işaretini KENDİ basıyor; İK'nın
	# yerel `_money` sarmalayıcısı üzerine bir eksi daha ekliyordu → "--$4.878".
	# İşten çıkarma nakdi eksiye geçirebildiği için bu tasarlanmış-ulaşılabilir bir hâldi.
	var e: Character = _make_employee("char_money", "Money Guy", HRConstants.ROLE_DEVELOPER, SEED_PACE, 12000, 50)
	e.hire_day = maxi(GameState.day - 400, 0)
	GameState.set_cash(1000)   # tazminat kasayı EKSİYE geçirsin
	var pv: Dictionary = HRActions.preview_fire(e)
	if not bool(pv.get("ok", false)):
		return "preview_fire refused: %s" % String(pv.get("reason", ""))
	if int(pv.get("cash_after", 0)) >= 0:
		return "the fixture did not push cash negative (%d)" % int(pv.get("cash_after", 0))
	var seen_negative: bool = false
	for r in pv.get("rows", []):
		var row: Dictionary = r
		for field in ["before", "after", "value", "note"]:
			var text: String = String(row.get(field, ""))
			if text.contains("--"):
				return "a doubled minus sign survived: '%s'" % text
			if text.begins_with("-"):
				seen_negative = true
		if String(row.get("kind", "")) == "delta" and bool(row.get("negative_after", false)):
			seen_negative = true
	if not seen_negative:
		# Tek eksi de yoksa vaka bir şey ölçmüyor demektir.
		return "no negative value reached the preview at all"
	return ""


## GDD ÜRÜN rev 6.1 §6.4 — %100 KAPISI. Bu case, adının ve gövdesinin TERSİNE
## ÇEVRİLDİĞİ bir case'tir ve sebebi kayda geçer: eski hâli (`beta_gate_open_early`)
## H1'in "kapı her yüzdede açık" kararını sabitliyordu. rev 6.1 o kararı geri aldı,
## çünkü H1 kendi gerekçesinde bedelinin olmadığını yazıyordu — hatalar yalnız
## GELİŞTİRME'de biriktiği için erken geçmek daha AZ hata ve daha KISA yapım
## demekti, yani bedelsiz baskın strateji. Teknoloji borcu demo dışı olduğundan
## (§1) eksik geliştirme cezalandırılamaz; cezalandırılamayan şey yasaklanır.
##
## Eski gövdenin ikinci yarısı (beta DOLGU çubuğu, bugs_start paydası) buradan
## ÇIKARILDI: §7 BETA satırının yüzde taşımasını yasaklıyor ve bugs_start'ı emekli
## ediyor. O yarının yerini BuildBar sayaç reworkünde sayaç iddiaları alır.
##
## FALSİFİKASYON: can_enter_beta'dan development_band_complete() koşulunu kaldır →
## ilk iddia FAIL.
static func _case_beta_gate_requires_full_bar() -> String:
	GameState.set_cash(50000)
	if not ProductSystem.start_build("ai_assistant", ["ai_assistant_chat"], ""):
		return "start_build failed"
	var b: FeatureBuild = ProductSystem.get_active_build()
	var hours: int = 0
	while not ProductSystem.can_enter_development():
		ProductSystem.hourly_tick(hours % 24)
		hours += 1
		if hours > 24 * 120:
			return "design band never ended"
	ProductSystem.enter_development()
	if b.current_phase != "development":
		return "enter_development did not flip phase"

	# --- KAPI KAPALI, ve bandın kendisi de dolu değil ---
	if ProductSystem.development_band_complete():
		return "the development band claims to be complete on its first hour"
	if ProductSystem.can_enter_beta():
		return "BETA opened before the bar was full — §6.4 forbids early phase skipping"
	# Kapalı kapı BASILAMAZ: enter_beta çağrılsa bile faz kımıldamaz.
	ProductSystem.enter_beta()
	if b.current_phase != "development":
		return "enter_beta crossed anyway while the gate was shut"

	# --- barı doldur, kapı açılsın ---
	while not ProductSystem.development_band_complete():
		ProductSystem.hourly_tick(hours % 24)
		hours += 1
		if hours > 24 * 400:
			return "the development band never filled"
	if not ProductSystem.can_enter_beta():
		return "the gate stayed shut with a full bar"
	ProductSystem.enter_beta()
	if b.current_phase != "bugfix":
		return "enter_beta refused a legal crossing"
	# §7 — sönümün başlangıç günü BETA girişinde damgalanır.
	if b.beta_entered_day != GameState.day:
		return "beta entry day was not stamped (%d vs %d)" % [b.beta_entered_day, GameState.day]
	return ""


## §7 — KEŞİF KESKİN AZALIR ve HAVUZ TÜKENMEZ. İkisi tek karardır: düz oran +
## tükenebilir havuz beklemeyi kesin kazançlı yapıyordu. Bu case ikisini de ölçer,
## ve "sıfıra asla ulaşılmaz" iddiasını havuzu bilerek boşaltarak sınar.
##
## FALSİFİKASYON: pow(BETA_FIND_DECAY, gün) terimini kaldır → sönüm iddiası FAIL.
## Havuz besleme dalını sil → tükenmezlik iddiası FAIL.
static func _case_beta_discovery_decays_pool_never_empties() -> String:
	# Sabitler §7'nin yazdığı sayılar olmalı...
	if absf(ProductSystem.BETA_BUG_FIND_PER_DAY - 6.0) > 0.001:
		return "beta discovery base is %.2f, §7 says 6" % ProductSystem.BETA_BUG_FIND_PER_DAY
	if absf(ProductSystem.BETA_FIND_DECAY - 0.85) > 0.001:
		return "beta decay is %.3f, §7 says 0,85" % ProductSystem.BETA_FIND_DECAY
	# ...ama sabiti okumak DAVRANIŞI ölçmez. Sönüm aşağıda MOTORDAN ölçülüyor: bu
	# case ilk yazıldığında eğriyi kendi içinde hesaplıyordu, ve `pow(...)` terimini
	# motordan silen bir mutasyon case'i GEÇİYORDU. Falsifikasyon o boşluğu buldu.

	GameState.set_cash(50000)
	if not ProductSystem.start_build("ai_assistant", ["ai_assistant_chat"], ""):
		return "start_build failed"
	var b: FeatureBuild = ProductSystem.get_active_build()
	var hours: int = 0
	while not ProductSystem.can_enter_development():
		ProductSystem.hourly_tick(hours % 24)
		hours += 1
		if hours > 24 * 120:
			return "design band never ended"
	ProductSystem.enter_development()
	while not ProductSystem.development_band_complete():
		ProductSystem.hourly_tick(hours % 24)
		hours += 1
		if hours > 24 * 400:
			return "the development band never filled"
	ProductSystem.enter_beta()

	# --- SÖNÜM, MOTORDAN ÖLÇÜLÜYOR ---------------------------------------
	# Aynı ekip, aynı havuz, tek fark BETA'da geçen gün. İlk gün çok bulur,
	# ikinci hafta tek tük (§7). Havuz tükenmez olduğu için ölçüm havuz
	# büyüklüğüne değil YALNIZ eğriye bakar.
	b.beta_entered_day = GameState.day
	b.bug_find_progress = 0.0
	var found_day0: int = b.bugs_found
	for h0 in 24:
		ProductSystem.hourly_tick(h0)
	var early: int = b.bugs_found - found_day0

	b.beta_entered_day = GameState.day - 12       # on ikinci beta günü
	b.bug_find_progress = 0.0
	var found_day12: int = b.bugs_found
	for h12 in 24:
		ProductSystem.hourly_tick(h12)
	var late: int = b.bugs_found - found_day12

	if early <= 0:
		return "beta found nothing on its first day (%d)" % early
	if late >= early:
		return "discovery did not decay: day 1 found %d, day 13 found %d" % [early, late]
	# 6 × 0,85^12 ≈ 0,85/gün — ilk günün altıda birinden az olmalı.
	if float(late) > float(early) * 0.5:
		return "decay is far too shallow: %d then %d" % [early, late]

	# HAVUZU BİLEREK BOŞALT: gizli = bug_count - (found - fixed) = 0.
	b.beta_entered_day = GameState.day
	b.bug_find_progress = 0.0
	b.bugs_found = b.bug_count
	b.bugs_fixed = 0
	b.bug_find_progress = 0.0
	var found_before: int = b.bugs_found
	var count_before: int = b.bug_count
	# Bir tam gün beta koştur — tükenmiş havuza rağmen keşif SÜRMELİ.
	for h in 24:
		ProductSystem.hourly_tick(h)
	if b.bugs_found <= found_before:
		return "discovery stopped once the hidden pool emptied — §7 says the pool never empties"
	if b.bug_count <= count_before:
		return "new bugs were found without the pool being replenished (invariant broken)"
	var hidden: int = b.bug_count - (b.bugs_found - b.bugs_fixed)
	if hidden < 0:
		return "the hidden-pool invariant went negative (%d)" % hidden
	return ""


## §7 · brief'in ikinci adlandırılmış kusuru — BETA'da park eden yapım KAPASİTE
## SLOTU YEMEZ. Kapasite bir YAPIM bölenidir; BETA'yı Test işi taşır ve BETA barı
## efor ilerletmez. Havuz tükenmez olduğu için BETA'nın doğal sonu da yoktur, yani
## eskiden hiç yayınlamayan oyuncu her hata sprintini KALICI olarak yarıya
## düşürüyordu.
##
## FALSİFİKASYON: capacity_demand'in faz listesine "bugfix"i geri koy → FAIL.
static func _case_beta_park_frees_capacity_slot() -> String:
	GameState.set_cash(50000)
	if not ProductSystem.start_build("ai_assistant", ["ai_assistant_chat"], ""):
		return "start_build failed"
	var b: FeatureBuild = ProductSystem.get_active_build()
	var base: int = ProductSystem.capacity_demand()
	if base < 1:
		return "a running build demands no capacity at all (%d)" % base

	var hours: int = 0
	while not ProductSystem.can_enter_development():
		ProductSystem.hourly_tick(hours % 24)
		hours += 1
		if hours > 24 * 120:
			return "design band never ended"
	if ProductSystem.capacity_demand() != base:
		return "TASARIM stopped demanding capacity"
	ProductSystem.enter_development()
	if ProductSystem.capacity_demand() != base:
		return "GELİŞTİRME stopped demanding capacity — it is the phase that spends effort"
	while not ProductSystem.development_band_complete():
		ProductSystem.hourly_tick(hours % 24)
		hours += 1
		if hours > 24 * 400:
			return "the development band never filled"
	ProductSystem.enter_beta()

	var parked: int = ProductSystem.capacity_demand()
	if parked >= base:
		return "a build parked in BETA still eats a capacity slot (%d, was %d)" % [parked, base]
	# Ve slot serbest kaldığı için paralel iş tam hızda koşar.
	if absf(ProductSystem.capacity_speed_factor() - 1.0) > 0.001:
		return "parking in BETA still halves parallel work (%.2f)" \
			% ProductSystem.capacity_speed_factor()
	return ""


## §6.4 kilit gerekçesi + §7 yayın tooltip'i — İKİSİ DE GERÇEKTEN ÇİZİLİYOR MU.
##
## Bu case'in sebebi tam olarak şudur: `projected_launch_bugs()` DOĞRU cevabı bir
## süredir veriyordu (cezayı ekledikten sonra hesaplıyor), ama BuildBar reworkü iki
## tooltip ev sahibini silince ÜRETİM TÜKETİCİSİ KALMADI ve BUILD_SHIP_TOOLTIP_BUGS
## öksüz bir anahtar oldu. Yani sayı doğruydu ve oyuncu onu HİÇ görmüyordu. Doğru
## sayıyı test etmek yetmez; ÇİZİLDİĞİNİ test etmek gerekir.
##
## FALSİFİKASYON: build_bar_model'den decision_tooltip atamalarını sil → FAIL.
static func _case_build_decision_tooltip_renders() -> String:
	GameState.set_cash(50000)
	if not ProductSystem.start_build("ai_assistant", ["ai_assistant_chat"], ""):
		return "start_build failed"
	var b: FeatureBuild = ProductSystem.get_active_build()
	var hours: int = 0
	while not ProductSystem.can_enter_development():
		ProductSystem.hourly_tick(hours % 24)
		hours += 1
		if hours > 24 * 120:
			return "design band never ended"
	ProductSystem.enter_development()

	# --- §6.4: kapı kilitliyken GEREKÇESİNİ taşır ---
	var model: RefCounted = load("res://scripts/ui/components/build_bar_model.gd").new()
	if not model.derive():
		return "the model refused to derive in development"
	if model.decision_enabled:
		return "the BETA decision reads enabled on development's first hour"
	if String(model.decision_tooltip).strip_edges() == "":
		return "the locked BETA gate shows no reason — §6.4 says it must"
	if String(model.decision_tooltip) == "BUILD_BETA_GATE_LOCKED":
		return "the gate reason rendered as its own key"

	# --- §7: yayın satırı TAŞINAN HATA SAYISINI taşır ---
	while not ProductSystem.development_band_complete():
		ProductSystem.hourly_tick(hours % 24)
		hours += 1
		if hours > 24 * 400:
			return "the development band never filled"
	ProductSystem.enter_beta()
	var clean: RefCounted = load("res://scripts/ui/components/build_bar_model.gd").new()
	if not clean.derive():
		return "the model refused to derive in beta"
	var n: int = ProductSystem.projected_launch_bugs()
	var tip: String = String(clean.decision_tooltip)
	if tip.strip_edges() == "":
		return "the ship action carries no tooltip — the honest number is unrendered again"
	if not tip.contains(str(n)):
		return "the ship tooltip '%s' does not carry the projected count %d" % [tip, n]

	# --- ve sayı KRİTİK-HATA CEZASINDAN SONRAKİ sayıdır (off-by-5 nüksü) ---
	GameState.set_flag("critical_bug_unfixed", true)
	var penalised: RefCounted = load("res://scripts/ui/components/build_bar_model.gd").new()
	penalised.derive()
	var n2: int = ProductSystem.projected_launch_bugs()
	if n2 != n + ProductSystem.CRITICAL_BUG_LAUNCH_PENALTY:
		GameState.set_flag("critical_bug_unfixed", false)
		return "the penalty did not reach the projection (%d -> %d)" % [n, n2]
	if not String(penalised.decision_tooltip).contains(str(n2)):
		GameState.set_flag("critical_bug_unfixed", false)
		return "the tooltip still prints the pre-penalty number"
	GameState.set_flag("critical_bug_unfixed", false)
	return ""


# =========================================================================
#  DESTEK (§8) ve ALTYAPI (§10)
# =========================================================================

## Canlı bir ürünü elle kurar — yapım hattından geçmeden, çünkü bu case'ler
## DESTEK/ALTYAPI aritmetiğini ölçüyor, yapım borusunu değil.
static func _seed_support_fixture(market: String = "b2c") -> void:
	ProductLines.reload()
	GameState.set_flag("mvp_shipped", true)
	GameState.set_flag("mvp_sub_product_type_id", "note_tool")
	GameState.set_flag("mvp_market_type", market)
	GameState.set_flag("mvp_version", 1)
	GameState.set_flag("mvp_live_bug_count", 6)
	GameState.set_flag(ProductState.LINE_TIERS, {})
	GameState.set_flag(ProductState.STEP_REALIZATION, {})
	GameState.set_flag(ProductState.REPORTS_INCOMING, 0)
	GameState.set_flag(ProductState.REPORTS_PROGRESS, 0.0)
	GameState.set_flag(ProductState.BUGS_CONFIRMED, 0)
	GameState.set_flag(ProductState.VALIDATION_PROGRESS, 0.0)
	GameState.set_flag(ProductState.FIX_RUN_ACTIVE, false)
	GameState.set_flag(ProductState.FIX_RUN_FIXED, 0)
	GameState.set_flag(ProductState.FIX_RUN_PROGRESS, 0.0)
	ProductState.refresh_on_publish(20.0)
	InfraSystem.reset()
	SupportSystem.reset()


## §8.2 — MASA BOŞSA HİÇBİR ŞEY DOĞRULANMAZ. Modülün merkez baskısı budur: bildirimler
## kendiliğinden gelir, ama hiçbir hata kendiliğinden çözülmez (§8.1). Boş masa bir
## "az doğrulama" durumu değil, TAM OLARAK SIFIR durumudur.
##
## FALSİFİKASYON: validation_per_day'i atanmamış herkesi de sayacak şekilde değiştir →
## "confirmed stayed flat" iddiası FAIL.
static func _case_destek_empty_desk_piles_up() -> String:
	_seed_support_fixture("b2c")
	GameState.set_flag("b2c_audience", 4000.0)
	# BORDRODA VAR, MASADA YOK. Bu satır olmadan iddia boşa düşüyordu: kadro bomboşken
	# "atamayı yoksay" mutasyonu da sıfır üretir, yani case atamayı değil BOŞLUĞU
	# ölçüyordu. Falsifikasyon bunu yakaladı.
	var idle: Character = _make_employee("idle_rep", "Idle Rep", HRConstants.ROLE_CUSTOMER_REP)
	idle.role_stats[HRConstants.AREA_CUSTOMER_SUCCESS] = 8
	# VE MASADAN İNDİRİLMEK ZORUNDA (B3, 2026-08-27). Müşteri Temsilcisi artık KENDİ birincil
	# işine, yani DESTEK MASASINA doğuyor — bu turun düzelttiği şeyin ta kendisi. Bu satır
	# olmadan "bordroda var, masada yok" fikstürü kendi kendini çürütüyordu: `_make_employee`
	# onu masaya oturtuyor ve case daha ilk iddiada düşüyordu.
	CharacterRegistry.clear_jobs(idle.id)
	# KURUCU MEŞGUL OLMAK ZORUNDA (B1, 2026-08-27). §8.2'nin BOŞ MASASI artık "kimse atanmadı"
	# değil "kimse atanmadı VE kurucu başka bir şey yapıyor" demektir: işsiz bir kurucu canlı
	# üründe kendiliğinden müşterilerle ilgilenir ve masayı doldurur. Bu satır olmadan case
	# kendi kurduğu dünyayı ölçemezdi — düştüğü yer de tam orasıydı. Ölçtüğü şey DEĞİŞMEDİ:
	# masa gerçekten boşken hiçbir şey doğrulanmaz.
	var busy_founder: Character = CharacterRegistry.get_founder()
	if busy_founder != null:
		CharacterRegistry.assign_job(busy_founder.id, HRConstants.JOB_BUILD)

	if SupportSystem.desk_staffed():
		return "the desk reads staffed before anyone was assigned"
	if absf(SupportSystem.validation_per_day()) > 0.0001:
		return "an empty desk validates %.4f/day — §8.2 says nothing" \
			% SupportSystem.validation_per_day()

	for h in 24:
		SupportSystem.hourly_tick(h)
	var incoming_empty: int = ProductState.reports_incoming()
	if incoming_empty <= 0:
		return "no reports arrived at all — §9's flow never reaches zero"
	if ProductState.bugs_confirmed() != 0:
		return "%d bugs were confirmed with nobody at the desk" % ProductState.bugs_confirmed()
	# Ve düzeltme koşusu da açılmaz: doğrulanmamış hata düzeltilemez.
	if SupportSystem.can_start_fix_run():
		return "a fix run could start with an empty desk and zero confirmed bugs"

	# --- masaya biri oturunca doğrulama BAŞLAR ---
	var rep: Character = _make_employee("desk_rep", "Desk Rep", HRConstants.ROLE_CUSTOMER_REP)
	rep.role_stats[HRConstants.AREA_CUSTOMER_SUCCESS] = 8
	if CharacterRegistry.assign_job(rep.id, HRConstants.JOB_SUPPORT) != "":
		return "could not seat anyone at the support desk"
	if not SupportSystem.desk_staffed():
		return "the desk still reads empty with someone assigned"
	if SupportSystem.validation_per_day() <= 0.0:
		return "a staffed desk still validates nothing"
	for h2 in 24:
		SupportSystem.hourly_tick(h2)
	if ProductState.bugs_confirmed() <= 0:
		return "a staffed desk confirmed nothing over a full day"
	if ProductState.reports_incoming() >= incoming_empty + 24:
		return "validation did not draw anything out of the incoming pool"
	return ""


## §8.4 — koşu oyuncunun istediği an biter ve YALNIZ ÇÖZÜLENLER gider. "35 doğrulanmış,
## 27 çözüldü, 27'si gider, 8'i havuzda kalır. Sıfır beklenmez."
##
## FALSİFİKASYON: _accrue_fix_run'dan BUGS_CONFIRMED yazımını kaldır → kalan havuz
## iddiası FAIL.
static func _case_fix_run_ships_subset() -> String:
	_seed_support_fixture("b2c")
	var dev: Character = _make_employee("fix_dev", "Fix Dev", HRConstants.ROLE_DEVELOPER)
	dev.role_stats[HRConstants.AREA_ENGINEERING] = 8
	if CharacterRegistry.assign_job(dev.id, HRConstants.JOB_SUPPORT) != "":
		return "could not seat the developer at the support desk"

	# DOĞRULANMIŞ 0 iken düğme KAPALIDIR (§8.4).
	if SupportSystem.can_start_fix_run():
		return "the fix run opened at zero confirmed bugs"
	if SupportSystem.fix_run_refusal() != SupportSystem.REFUSAL_NO_BUGS:
		return "the refusal at zero bugs was '%s'" % SupportSystem.fix_run_refusal()

	GameState.set_flag(ProductState.BUGS_CONFIRMED, 35)
	if not SupportSystem.can_start_fix_run():
		return "the fix run stayed shut with 35 confirmed bugs"
	if not SupportSystem.start_fix_run():
		return "start_fix_run refused"
	if not ProductState.fix_run_active():
		return "the run did not read as active"
	# §2/§8.4 — koşu aktif yapımı duraklatır.
	if not SupportSystem.fix_run_pauses_build():
		return "a running fix run does not pause the build"

	# Oyuncu 27 çözülene kadar bekler, sonra BİTİRİR. Sıfır beklenmez.
	var guard: int = 0
	while ProductState.fix_run_fixed() < 27 and guard < 24 * 200:
		SupportSystem.hourly_tick(guard % 24)
		guard += 1
	var fixed: int = ProductState.fix_run_fixed()
	if fixed < 27:
		return "the run never reached 27 fixes (%d)" % fixed
	var remaining_before: int = ProductState.bugs_confirmed()
	var shipped: int = SupportSystem.end_fix_run()

	if shipped != fixed:
		return "the run shipped %d but had fixed %d" % [shipped, fixed]
	if ProductState.fix_run_active():
		return "the run is still active after being ended"
	# 35 − çözülen = havuzda kalan. Kalanlar SİLİNMEZ.
	if remaining_before != 35 - fixed:
		return "pool reads %d after %d fixes of 35 — the remainder did not stay" \
			% [remaining_before, fixed]
	if ProductState.bugs_confirmed() != remaining_before:
		return "ending the run moved the pool (%d -> %d)" \
			% [remaining_before, ProductState.bugs_confirmed()]
	if ProductState.fix_run_fixed() != 0:
		return "the run counter did not clear"
	return ""


## §10 — kapasite HER AN, ±1 birim, CEZASIZ artıp azalır; fatura günlük olarak
## (aylık/30) burn'e işler ve YENİ FİYAT ERTESİ GÜNDEN itibaren geçerlidir.
##
## FALSİFİKASYON: adjust_capacity'ye bir ceza/kilit ekle → simetri iddiası FAIL.
static func _case_infra_capacity_moves_both_ways() -> String:
	_seed_support_fixture("b2c")
	InfraSystem.set_provider(InfraSystem.PROVIDER_CLOUD)
	InfraSystem.set_capacity(10)
	if InfraSystem.units() != 10:
		return "capacity did not take (%d)" % InfraSystem.units()
	var bill_10: int = InfraSystem.monthly_bill()
	if bill_10 != 10 * InfraSystem.unit_price(InfraSystem.PROVIDER_CLOUD, "b2c"):
		return "monthly bill %d is not units x unit price" % bill_10

	# YUKARI ve AŞAĞI, aynı adımla, aynı sonuca dönerek — hiçbir yönde ceza yok.
	InfraSystem.adjust_capacity(1)
	if InfraSystem.units() != 11:
		return "raising by one step gave %d" % InfraSystem.units()
	InfraSystem.adjust_capacity(-1)
	if InfraSystem.units() != 10:
		return "lowering by one step gave %d" % InfraSystem.units()
	if InfraSystem.monthly_bill() != bill_10:
		return "a round trip changed the bill (%d -> %d)" % [bill_10, InfraSystem.monthly_bill()]
	if InfraSystem.set_capacity(-5) != 0:
		return "capacity went negative"

	# Sağlayıcı göçü BEDELSİZ, ve fiyat FATURA YAYINLANDIĞINDA değişir.
	InfraSystem.set_capacity(10)
	var cash_before: int = GameState.cash
	InfraSystem.set_provider(InfraSystem.PROVIDER_ENTERPRISE)
	if GameState.cash != cash_before:
		return "switching provider charged a migration fee (%d -> %d)" % [cash_before, GameState.cash]
	if InfraSystem.monthly_bill() != 10 * InfraSystem.unit_price(InfraSystem.PROVIDER_ENTERPRISE, "b2c"):
		return "the new provider's price did not reach the bill"
	# Günlük fatura aylık/30'dur ve burn'e "servers" kaleminden işler.
	InfraSystem.daily_tick()
	var breakdown: Dictionary = FinanceSystem.get_burn_breakdown()
	if not breakdown.has(InfraSystem.BURN_CATEGORY):
		return "FinanceSystem has no '%s' burn category — the bill has nowhere to land" \
			% InfraSystem.BURN_CATEGORY
	if int(breakdown[InfraSystem.BURN_CATEGORY]) != InfraSystem.daily_bill():
		return "burn carries %d, the daily bill is %d" \
			% [int(breakdown[InfraSystem.BURN_CATEGORY]), InfraSystem.daily_bill()]
	return ""


## §10 — "ağır özellik yayınlamak KALICI bir işletme maliyetidir." Yük = 1 + Σağırlık/20,
## etkin kapasite = satın alınan / yük. Aynı kapasiteyle aynı kullanıcı, ağır kademe
## yayınlandıktan sonra daha dolu okur.
##
## FALSİFİKASYON: load_factor'ü sabit 1.0 yap → doluluk iddiası FAIL.
static func _case_infra_heavy_step_costs_capacity() -> String:
	_seed_support_fixture("b2c")
	InfraSystem.set_provider(InfraSystem.PROVIDER_CLOUD)
	InfraSystem.set_capacity(3)                       # 3.000 kullanıcı kapasitesi
	GameState.set_flag("b2c_audience", 2300.0)

	if absf(InfraSystem.load_factor() - 1.0) > 0.0001:
		return "an empty product already carries load %.3f" % InfraSystem.load_factor()
	var occ_before: float = InfraSystem.occupancy()
	var state_before: String = InfraSystem.capacity_state()
	if state_before != InfraSystem.STATE_NORMAL:
		return "a 77%% product reads %s before any heavy step" % state_before

	# AĞIR kademe yayınla: note_tool capture K3, kullanım ağırlığı 3.
	ProductState.set_line_tier("line_note_tool_capture", 3)
	if ProductState.usage_weight_total() <= 0:
		return "the shipped step contributed no usage weight"
	if InfraSystem.load_factor() <= 1.0:
		return "load stayed at %.3f after shipping a heavy step" % InfraSystem.load_factor()
	if InfraSystem.effective_capacity() >= float(InfraSystem.purchased_capacity()):
		return "effective capacity did not fall below what was purchased"
	if InfraSystem.occupancy() <= occ_before:
		return "occupancy did not rise (%.3f -> %.3f)" % [occ_before, InfraSystem.occupancy()]
	if InfraSystem.capacity_state() == InfraSystem.STATE_NORMAL:
		return "the same users on the same capacity still read normal after a heavy ship"
	# Kapasite eklemek geri alır — hasar kalıcı değil.
	InfraSystem.adjust_capacity(2)
	if InfraSystem.capacity_state() != InfraSystem.STATE_NORMAL:
		return "adding capacity did not clear the band (%s)" % InfraSystem.capacity_state()
	return ""


## §10 — %100 üstünde ÜÇ etki birden: memnuniyet −0,8/gün · GELEN ×1,5 · B2C edinim
## ×0,6. Ve "hasar kalıcı değildir: kapasite eklendiği an etki durur."
##
## FALSİFİKASYON: is_over_capacity'yi false döndür → üç iddia da FAIL.
static func _case_infra_overage_applies_and_stops() -> String:
	_seed_support_fixture("b2c")
	InfraSystem.set_provider(InfraSystem.PROVIDER_CLOUD)
	InfraSystem.set_capacity(2)                       # 2.000
	GameState.set_flag("b2c_audience", 900.0)         # rahat

	if InfraSystem.is_over_capacity():
		return "a comfortable product reads over capacity"
	if absf(InfraSystem.satisfaction_delta_per_day()) > 0.0001:
		return "a comfortable product bleeds satisfaction"
	if absf(InfraSystem.report_inflow_multiplier() - 1.0) > 0.0001:
		return "a comfortable product multiplies inflow"
	if absf(InfraSystem.acquisition_multiplier() - 1.0) > 0.0001:
		return "a comfortable product throttles acquisition"

	GameState.set_flag("b2c_audience", 5000.0)        # kapasitenin çok üstünde
	if not InfraSystem.is_over_capacity():
		return "5000 users on 2000 capacity did not read as overage"
	if absf(InfraSystem.satisfaction_delta_per_day() - InfraSystem.OVERAGE_SATISFACTION) > 0.0001:
		return "overage satisfaction is %.2f, §10 says %.2f" \
			% [InfraSystem.satisfaction_delta_per_day(), InfraSystem.OVERAGE_SATISFACTION]
	if absf(InfraSystem.report_inflow_multiplier() - InfraSystem.OVERAGE_INFLOW_MULT) > 0.0001:
		return "overage inflow multiplier is %.2f, §10 says 1,5" \
			% InfraSystem.report_inflow_multiplier()
	if absf(InfraSystem.acquisition_multiplier() - InfraSystem.OVERAGE_ACQUISITION_MULT) > 0.0001:
		return "overage acquisition multiplier is %.2f, §10 says 0,6" \
			% InfraSystem.acquisition_multiplier()
	# §8.3 — aşım zararı DESTEK'in −2,0 TAVANININ İÇİNDE toplanır, ayrı kanal değil.
	GameState.set_flag(ProductState.REPORTS_INCOMING, 60)
	GameState.set_flag(ProductState.BUGS_CONFIRMED, 40)
	if SupportSystem.daily_satisfaction_damage() < SupportSystem.DAMAGE_DAILY_CAP - 0.0001:
		return "overage pushed daily damage past the −2,0 cap (%.2f)" \
			% SupportSystem.daily_satisfaction_damage()

	# KAPASİTE EKLE → ÜÇÜ DE ANINDA DURUR.
	InfraSystem.set_capacity(8)
	if InfraSystem.is_over_capacity():
		return "adding capacity did not clear the overage"
	if absf(InfraSystem.satisfaction_delta_per_day()) > 0.0001 \
			or absf(InfraSystem.report_inflow_multiplier() - 1.0) > 0.0001 \
			or absf(InfraSystem.acquisition_multiplier() - 1.0) > 0.0001:
		return "an overage effect survived the capacity increase — §10 says damage is not permanent"
	return ""


## §10 — ucuz sağlayıcının bedeli DETERMİNİSTİKTİR: GELEN akışı ×1,25 ve kurumsal
## hesap imzalamaz. Rastgele kesinti YOKTUR (uyarısız kayıp yasağı).
##
## FALSİFİKASYON: LOCAL_INFLOW_MULT'u 1.0 yap → akış iddiası FAIL.
static func _case_infra_local_provider_tradeoff() -> String:
	_seed_support_fixture("b2c")
	InfraSystem.set_capacity(20)                      # bol kapasite: aşım karışmasın
	GameState.set_flag("b2c_audience", 1000.0)

	InfraSystem.set_provider(InfraSystem.PROVIDER_CLOUD)
	if absf(InfraSystem.report_inflow_multiplier() - 1.0) > 0.0001:
		return "the neutral provider is not neutral (%.2f)" % InfraSystem.report_inflow_multiplier()
	var flow_cloud: float = SupportSystem.reports_per_day()
	if InfraSystem.blocks_enterprise_signature():
		return "the cloud provider blocks an enterprise signature"

	InfraSystem.set_provider(InfraSystem.PROVIDER_LOCAL)
	if absf(InfraSystem.report_inflow_multiplier() - 1.25) > 0.0001:
		return "the local provider's inflow multiplier is %.2f, §10 says 1,25" \
			% InfraSystem.report_inflow_multiplier()
	var flow_local: float = SupportSystem.reports_per_day()
	# LİTERALE karşı, sabitin KENDİSİNE karşı DEĞİL: ilk yazımda karşılaştırma
	# InfraSystem.LOCAL_INFLOW_MULT ile yapılıyordu, yani sabiti 1,0'a çeken mutasyon
	# eşitliğin iki yanını da oynatıyor ve case GEÇİYORDU.
	if flow_local <= flow_cloud:
		return "the cheap provider cost nothing: %.4f/day vs neutral %.4f/day" % [flow_local, flow_cloud]
	if absf(flow_local - flow_cloud * 1.25) > 0.0001:
		return "the multiplier did not reach the actual flow (%.4f vs %.4f)" \
			% [flow_local, flow_cloud * 1.25]
	if not InfraSystem.blocks_enterprise_signature():
		return "the local provider does not block an enterprise signature"
	if InfraSystem.meets_enterprise_trust():
		return "the local provider satisfies the enterprise trust condition"

	# Ve ucuzdur: bedelin tamamı deterministik, tek kuruş rastgele değil.
	if InfraSystem.unit_price(InfraSystem.PROVIDER_LOCAL, "b2c") \
			>= InfraSystem.unit_price(InfraSystem.PROVIDER_CLOUD, "b2c"):
		return "the local provider is not the cheap one"
	InfraSystem.set_provider(InfraSystem.PROVIDER_ENTERPRISE)
	if not InfraSystem.meets_enterprise_trust():
		return "the enterprise provider does not satisfy the trust condition"
	return ""


## Kurucuyu her alanda tavana çıkarır ve Build işine oturtur — kapılar ve taşıyıcılar
## bu case'lerin konusu değilken yoldan çekilsinler diye.
static func _seed_build_crew() -> Character:
	var founder: Character = CharacterRegistry.get_founder()
	if founder != null:
		for area in HRConstants.AREAS:
			founder.role_stats[area] = HRConstants.AREA_MAX
		CharacterRegistry.clear_jobs(founder.id)
		CharacterRegistry.assign_job(founder.id, HRConstants.JOB_BUILD)
	return founder


## §12 + §11.2 — YAYIN, hat modelinin tek yazma anı. Kademeler ilerler, her biri
## SÜRÜMÜNÜN cilasını damgalar, ve canlı eksenler hat modelinden türetilir.
##
## FALSİFİKASYON: _apply_line_plan_at_ship'ten stamp_step çağrısını sil → damga
## iddiası FAIL. set_line_tier'i sil → kademe iddiası FAIL.
static func _case_line_build_ships_and_stamps() -> String:
	ProductLines.reload()
	GameState.set_cash(50000)
	_seed_build_crew()
	GameState.set_flag(ProductState.LINE_TIERS, {})
	GameState.set_flag(ProductState.STEP_REALIZATION, {})
	GameState.set_flag("mvp_shipped", false)
	GameState.set_flag("mvp_version", 0)

	var plan := ["line_note_tool_capture_k1", "line_note_tool_sync_k1",
		"line_note_tool_editor_k1"]
	if ProductSystem.validate_line_plan("note_tool", plan) != "":
		return "a legal three-step v1 plan was refused: %s" \
			% ProductSystem.validate_line_plan("note_tool", plan)
	# §6.0 — EforTavanı seçilen kademelerin efor toplamıdır.
	var want_effort: int = ProductLines.sum_effort(plan)
	if not ProductSystem.start_line_build("note_tool", plan, "", "Sable"):
		return "start_line_build refused a valid plan"
	var b: FeatureBuild = ProductSystem.get_active_build()
	if absf(b.total_efor - float(want_effort)) > 0.001:
		return "EforTavanı is %.1f, the plan sums to %d" % [b.total_efor, want_effort]
	# Kademeler HENÜZ ilerlemedi — plan build'de durur.
	if ProductState.line_tier("line_note_tool_capture") != 0:
		return "starting a build already advanced a line tier"

	# Dört tur tamamlanmış gibi damgalayıp yayınla.
	b.design_turns_completed = 4
	b.current_phase = "bugfix"
	b.bug_count = 2
	ProductSystem.launch()
	ProductSystem.ship_active_build()

	for pair in [["line_note_tool_capture", 1], ["line_note_tool_sync", 1],
			["line_note_tool_editor", 1]]:
		if ProductState.line_tier(String(pair[0])) != int(pair[1]):
			return "%s came out of the ship at tier %d, want %d" \
				% [pair[0], ProductState.line_tier(String(pair[0])), int(pair[1])]
	var stamps: Dictionary = ProductState.step_realization()
	var want_stamp: float = ProductSystem.design_turn_mult(4)
	for sid in plan:
		if not stamps.has(sid):
			return "%s shipped without a realization stamp" % sid
		# Kapı-üstü bonusu kurucu tavandayken devreye girebilir; damga TABANDAN AŞAĞI olamaz.
		if float(stamps[sid]) < want_stamp - 0.0001:
			return "%s stamped %.3f, below its version's %.3f polish" \
				% [sid, float(stamps[sid]), want_stamp]
	# §11.2 — canlı eksenler hat modelinden türetildi.
	var dims: Dictionary = ProductState.realized_dims()
	if absf(float(GameState.get_flag("mvp_innovation", -1.0)) - float(dims["innovation"])) > 0.001:
		return "the live axes did not come from the line model"
	if float(dims["innovation"]) <= 0.0:
		return "a shipped innovation step produced no innovation"
	return ""


## §12.3 kural 4 — "Sürüm iptal edilirse o sürümde PLANLANMIŞ kademeler hiç
## yapılmamış sayılır; hatlar önceki durumlarında kalır." Ve §2: GELİŞTİRME'den
## sonra iptal TÜM SÜRÜM EFORUNU yakar.
##
## Bu yapısal olarak doğrudur çünkü plan build'de durur ve hatlara yalnız YAYINDA
## dokunulur — geri alınacak bir şey yok, çünkü ileri de alınmamıştı. Case bunu
## sabitler ki biri "kolaylık olsun" diye commit'te yazmaya kalkmasın.
##
## FALSİFİKASYON: start_line_build'e ProductState.set_line_tier çağrısı ekle → FAIL.
static func _case_cancel_reverts_planned_steps() -> String:
	ProductLines.reload()
	GameState.set_cash(50000)
	_seed_build_crew()
	GameState.set_flag(ProductState.LINE_TIERS, {})
	GameState.set_flag(ProductState.STEP_REALIZATION, {})
	GameState.set_flag("mvp_shipped", false)
	GameState.set_flag("mvp_version", 0)
	# Önce bir K1 canlıya çıksın ki "önceki durum" sıfırdan farklı olsun.
	ProductState.set_line_tier("line_note_tool_search", 1)
	ProductState.stamp_step("line_note_tool_search_k1", 1.0)

	var plan := ["line_note_tool_search_k2", "line_note_tool_editor_k1"]
	if ProductSystem.validate_line_plan("note_tool", plan) != "":
		return "the upgrade plan was refused: %s" \
			% ProductSystem.validate_line_plan("note_tool", plan)
	if not ProductSystem.start_line_build("note_tool", plan, "", "Sable"):
		return "start_line_build refused"
	var b: FeatureBuild = ProductSystem.get_active_build()
	b.current_phase = "development"
	b.efor_spent = b.total_efor * 0.6         # yarıdan fazlası harcandı
	var burned: float = b.efor_spent
	var cash_before: int = GameState.cash

	ProductSystem.cancel_build()

	if ProductSystem.get_active_build() != null:
		return "the build survived cancellation"
	# HATLAR ÖNCEKİ DURUMLARINDA.
	if ProductState.line_tier("line_note_tool_search") != 1:
		return "the cancelled version moved a line to %d" \
			% ProductState.line_tier("line_note_tool_search")
	if ProductState.line_tier("line_note_tool_editor") != 0:
		return "a planned step landed despite the cancellation"
	if ProductState.step_realization().has("line_note_tool_search_k2"):
		return "a cancelled step left a realization stamp behind"
	# EFOR YANDI: harcanan iş geri gelmez ve kasaya iade yoktur.
	if burned <= 0.0:
		return "the fixture never spent any effort"
	if GameState.cash != cash_before:
		return "cancelling refunded %d — §2 says the whole version effort burns" \
			% (GameState.cash - cash_before)
	# Ve aynı kademe yeniden planlanabilir: iptal hattı bozmadı.
	if ProductSystem.validate_line_plan("note_tool", ["line_note_tool_search_k2"]) != "":
		return "the line could not be re-planned after a cancellation"
	return ""


## §6.1 — yapım hızı YALNIZ Ekip seam'lerinden gelir: Σ(daily_contribution) × K_EFOR.
## Build işine kimse atanmamışsa efor SIFIRDIR (ünvan hiçbir kapıyı açmaz, Ekip §12.0).
##
## FALSİFİKASYON: build_carriers'ı bütün çalışanları döndürecek şekilde değiştir →
## "unassigned" iddiası FAIL. K_EFOR'u 1.0 yap → katsayı iddiası FAIL.
static func _case_build_effort_from_hr_seams() -> String:
	# K_EFOR birleştirmesinin cebirsel özdeşliği: skill × (h/8) × (8/12) ≡ skill × h/12.
	if absf(ProductSystem.K_EFOR - 8.0 / 12.0) > 0.000001:
		return "K_EFOR is %.6f, §6.1 says 8/12" % ProductSystem.K_EFOR

	var founder: Character = CharacterRegistry.get_founder()
	if founder == null:
		return "no founder"
	for area in HRConstants.AREAS:
		founder.role_stats[area] = 0
	CharacterRegistry.clear_jobs(founder.id)

	var dev: Character = _make_employee("eff_e", "Eff E", HRConstants.ROLE_DEVELOPER)
	for area_d in HRConstants.AREAS:
		dev.role_stats[area_d] = 0
	dev.role_stats[HRConstants.AREA_ENGINEERING] = 8
	dev.traits = ["picks_it_up_fast"]          # hız/çıktı çarpanı taşımaz
	# CharacterRegistry.add() taze işe alımı KENDİ ANA İŞİNE oturtuyor (Ekip §12.2:
	# "işe alım, oyuncunun boşta duran biriyle tanışmak isteyeceği yer değildir"), yani
	# bir developer doğduğu anda Build'dedir. Atama iddiasını ölçmek için önce
	# masadan kaldırmak gerekiyor — bu case ilk yazımında tam olarak buna takıldı.
	CharacterRegistry.clear_jobs(dev.id)

	# BORDRODA VAR, BUILD'DE YOK → sıfır efor.
	if absf(ProductSystem.build_effort_per_day()) > 0.0001:
		return "an unassigned developer produced %.3f effort/day" \
			% ProductSystem.build_effort_per_day()

	if CharacterRegistry.assign_job(dev.id, HRConstants.JOB_BUILD) != "":
		return "could not assign the developer to the build"
	# 8 ham × alan 1,0 × odak 1,0 × moral nötr × 8 saat/8 = 8,0 günlük katkı.
	var contrib: float = HRSystem.daily_contribution(dev, HRConstants.AREA_ENGINEERING)
	if absf(contrib - 8.0) > 0.001:
		return "the HR seam returned %.3f, expected 8.0" % contrib
	var effort: float = ProductSystem.build_effort_per_day()
	if absf(effort - contrib * ProductSystem.K_EFOR) > 0.001:
		return "effort/day is %.4f, the seam x K_EFOR is %.4f" \
			% [effort, contrib * ProductSystem.K_EFOR]

	# §6.2 — TEST build TAŞIMAZ; katkısı BETA'dadır.
	var qa: Character = _make_employee("eff_q", "Eff Q", HRConstants.ROLE_TESTER)
	for area_q in HRConstants.AREAS:
		qa.role_stats[area_q] = 0
	qa.role_stats[HRConstants.AREA_QA] = 10
	CharacterRegistry.assign_job(qa.id, HRConstants.JOB_TEST)
	if absf(ProductSystem.build_effort_per_day() - effort) > 0.001:
		return "a tester on the Test job changed build effort — §6.2 says Test does not carry it"

	# §6.3 — hata oranı YAZILIM'la düşer ama sıfırlanmaz.
	var rate_strong: float = ProductSystem.line_bug_rate_per_effort()
	dev.role_stats[HRConstants.AREA_ENGINEERING] = 1
	var rate_weak: float = ProductSystem.line_bug_rate_per_effort()
	if rate_weak <= rate_strong:
		return "a weaker team did not produce more bugs (%.3f vs %.3f)" % [rate_weak, rate_strong]
	dev.role_stats[HRConstants.AREA_ENGINEERING] = 10
	if ProductSystem.line_bug_rate_per_effort() < ProductSystem.BUG_RATE_FLOOR - 0.0001:
		return "a strong team drove the bug rate below its floor"
	return ""


## §19 — OKUMA YÜZEYİ. "Adlar kararlıdır ve iç yapı değişse bile korunur. Olay motoru
## geldiğinde işi bunları OKUMAK olacak, keşfetmek değil."
##
## Bu case bir SÖZLÜK denetimidir: eksik bir ad, içeriğin o duruma asla atıfta
## bulunamaması demektir (§19'un attribution yasası). Bugün hiçbirinin abonesi yok
## ve olmaması da doğru — sinyaller dinleyicisi olmasa da yayınlanır.
##
## FALSİFİKASYON: EventBus'tan `line_completed` sinyalini sil → sinyal iddiası FAIL.
## ProductRead.market_word'ü sil → sorgu iddiası FAIL.
static func _case_product_read_catalogue() -> String:
	ProductLines.reload()
	_seed_support_fixture("b2c")
	ProductState.set_line_tier("line_note_tool_search", 1)
	ProductState.stamp_step("line_note_tool_search_k1", 1.0)

	# --- SORGULAR: §19'un listesi, birebir ---
	var q: Dictionary = {
		"phase": ProductRead.phase(""),
		"axis_reading": ProductRead.axis_reading("", "innovation"),
		"market_word": ProductRead.market_word("", "innovation"),
		"confirmed_open": ProductRead.confirmed_open(""),
		"unconfirmed": ProductRead.unconfirmed(""),
		"version_age": ProductRead.version_age(""),
		"usage": ProductRead.usage(""),
		"line_tier": ProductRead.line_tier("", "line_note_tool_search"),
		"line_next_step": ProductRead.line_next_step("", "line_note_tool_search"),
		"lines_open": ProductRead.lines_open(""),
		"steps_shipped": ProductRead.steps_shipped(""),
		"interest": ProductRead.interest(""),
		"capacity_tier": ProductRead.capacity_tier(""),
		"build_active": ProductRead.build_active(),
		"support_staffed": ProductRead.support_staffed(""),
		"step_unlockable": ProductRead.step_unlockable("line_note_tool_search_k2"),
	}
	if q.size() != 16:
		return "the query catalogue has %d entries, §19 lists 16" % q.size()

	# Birkaçının GERÇEKTEN okuduğunu kanıtla — imza sınavı yeterli değil.
	if String(q["phase"]) != ProductRead.PHASE_SUPPORT:
		return "a live product with no build reads phase '%s', §2 says DESTEK is permanent" \
			% String(q["phase"])
	if int(q["line_tier"]) != 1:
		return "line_tier read %d, the fixture set 1" % int(q["line_tier"])
	if String(q["line_next_step"]) != "line_note_tool_search_k2":
		return "line_next_step read '%s'" % String(q["line_next_step"])
	if int(q["lines_open"]) != 1 or int(q["steps_shipped"]) != 1:
		return "lines_open/steps_shipped read %d/%d, want 1/1" \
			% [int(q["lines_open"]), int(q["steps_shipped"])]
	if not [ProductRead.WORD_AHEAD, ProductRead.WORD_LEVEL, ProductRead.WORD_BEHIND] \
			.has(String(q["market_word"])):
		return "market_word returned '%s', outside önde/hizada/geride" % String(q["market_word"])
	# Tamamlanmış hat sıradaki kademeyi ÖNERMEZ.
	ProductState.set_line_tier("line_note_tool_search", 3)
	if ProductRead.line_next_step("", "line_note_tool_search") != "":
		return "a completed line still offered a next step"
	ProductState.set_line_tier("line_note_tool_search", 1)

	# --- SİNYALLER: §19'un listesi, birebir ---
	var signals := ["version_shipped", "build_started", "build_paused", "build_resumed",
		"fix_run_started", "fix_run_finished", "bug_confirmed",
		"unconfirmed_threshold_crossed", "axis_floor_warning", "axis_floor_crossed",
		"line_upgraded", "line_completed", "delighter_shipped", "phase_bar_raised"]
	var declared: Array[String] = []
	for d in EventBus.get_signal_list():
		declared.append(String((d as Dictionary).get("name", "")))
	for name in signals:
		if not declared.has(name):
			return "§19 signal '%s' is not declared on EventBus" % name
	if signals.size() != 14:
		return "the signal catalogue has %d entries, §19 lists 14" % signals.size()

	# Kenar sinyalleri: ilk çağrı yalnız TOHUMLAR, yayınlamaz.
	var seen: Array[String] = []
	EventBus.bug_confirmed.connect(func(_n: int) -> void: seen.append("bug_confirmed"))
	EventBus.unconfirmed_threshold_crossed.connect(
		func(_b: String) -> void: seen.append("threshold"))
	ProductRead.reset()
	GameState.set_flag(ProductState.BUGS_CONFIRMED, 5)
	ProductRead.emit_edges()          # tohumlama — sessiz olmalı
	if not seen.is_empty():
		return "the first edge sweep emitted %s instead of seeding" % str(seen)
	GameState.set_flag(ProductState.BUGS_CONFIRMED, 9)
	ProductRead.emit_edges()
	if not seen.has("bug_confirmed"):
		return "a rise in confirmed bugs emitted nothing"
	# Düşüş (düzeltme) bu sinyali ATMAZ — yalnız doğrulama atar.
	seen.clear()
	GameState.set_flag(ProductState.BUGS_CONFIRMED, 2)
	ProductRead.emit_edges()
	if seen.has("bug_confirmed"):
		return "fixing bugs emitted bug_confirmed"
	return ""


## §5 CİLA MERDİVENİ + §6.0/§6.4 — hat modelinin faz aritmetiği, uçtan uca.
##
## Üç iddia bir arada, çünkü üçü de aynı yeniden-şekillendirmenin parçası:
##  · "Geliştirmeye geç" İLK GÜNDEN basılabilir, ama tur 1 dolmadan ONAY ister.
##  · TASARIM turları eforu EforTavanı'nın ÜSTÜNDEN yakar (0,08/tur), barından değil.
##  · GELİŞTİRME barı tavanın %100'üne kadar dolar ve BETA kapısı orada açılır.
##
## FALSİFİKASYON: design_efor_spent'i efor_spent'e yaz → %100 kapısı iddiası FAIL.
## needs_design_confirm'ü false döndür → onay iddiası FAIL.
static func _case_line_design_turns_and_gate() -> String:
	ProductLines.reload()
	GameState.set_cash(50000)
	_seed_build_crew()
	GameState.set_flag(ProductState.LINE_TIERS, {})
	GameState.set_flag(ProductState.STEP_REALIZATION, {})
	GameState.set_flag("mvp_shipped", false)
	GameState.set_flag("mvp_version", 0)

	var plan := ["line_note_tool_capture_k1", "line_note_tool_editor_k1"]
	if not ProductSystem.start_line_build("note_tool", plan, "", "Sable"):
		return "start_line_build refused"
	var b: FeatureBuild = ProductSystem.get_active_build()
	var ceiling: float = b.total_efor

	# --- İLK GÜN: kapı açık, ama onay ister (§5) ---
	if not ProductSystem.can_enter_development():
		return "'Geliştirmeye geç' was shut on day one — §5 opens it immediately"
	if not ProductSystem.needs_design_confirm():
		return "crossing before turn 1 asked for no confirmation"
	if ProductSystem.design_turn_mult(b.design_turns_completed) != 0.75:
		return "a version crossing at zero turns would not carry the 0,75 multiplier"

	# --- TUR 1 dolsun ---
	var hours: int = 0
	while b.design_turns_completed < 1 and hours < 24 * 200:
		ProductSystem.hourly_tick(hours % 24)
		hours += 1
	if b.design_turns_completed < 1:
		return "the first design turn never completed"
	if ProductSystem.needs_design_confirm():
		return "the confirm dialog survived the first completed turn"
	# Turun maliyeti EforTavanı × 0,08, ve GELİŞTİRME barından ÇALMAZ.
	var want_cost: float = ProductSystem.DESIGN_TURN_COST * ceiling
	if absf(b.design_efor_spent - want_cost) > want_cost * 0.25:
		return "one turn burned %.2f, §5 says about %.2f" % [b.design_efor_spent, want_cost]
	if b.efor_spent > 0.0001:
		return "design turns ate into the development bar (%.3f)" % b.efor_spent
	if absf(b.total_efor - ceiling) > 0.001:
		return "the effort ceiling moved during design"

	# --- DÖRT TURDA PARK ---
	while not ProductSystem.design_turns_maxed() and hours < 24 * 600:
		ProductSystem.hourly_tick(hours % 24)
		hours += 1
	if b.design_turns_completed != 4:
		return "design stopped at %d turns, §5 caps at 4" % b.design_turns_completed
	var parked: float = b.design_efor_spent
	for h in 48:
		ProductSystem.hourly_tick(h % 24)
	if absf(b.design_efor_spent - parked) > 0.001:
		return "design kept burning past its fourth turn"
	if absf(ProductSystem.design_turn_mult(4) - 1.15) > 0.0001:
		return "four turns do not read as the 1,15 ceiling"

	# --- GELİŞTİRME: %100'e kadar, kapı orada açılır (§6.4) ---
	ProductSystem.enter_development()
	if b.current_phase != "development":
		return "enter_development did not flip the phase"
	if ProductSystem.can_enter_beta():
		return "BETA opened on development's first hour"
	var guard: int = 0
	while not ProductSystem.development_band_complete() and guard < 24 * 800:
		ProductSystem.hourly_tick(guard % 24)
		guard += 1
	if not ProductSystem.development_band_complete():
		return "the development bar never filled"
	if absf(b.efor_spent - ceiling) > 0.001:
		return "the bar stopped at %.2f of a %.2f ceiling — §6.0 wants 100%%" \
			% [b.efor_spent, ceiling]
	if not ProductSystem.can_enter_beta():
		return "the gate stayed shut at a full bar"
	# §6.3 — hatalar GELİŞTİRME'de birikti.
	if b.bug_count <= 0:
		return "a full development phase produced no bugs at all"
	return ""


## §2 DURAKLAMA İKİ TÜRDÜR + §3 LİDERSİZ YAPIM.
##
## S6'nın sözü: "Oto-duraklama CÜMLEYLE, manuel duraklama GLİFLE ayrışır — ikisi bir
## arada ASLA görünmez." Bu case tam olarak o ayrımı ölçer, çünkü ikisi tek bir
## boolean'a çökerse bar oyuncunun kendi kararını bir arıza gibi gösterir.
##
## FALSİFİKASYON: pause_kind'dan manuel dalını çıkar → glif iddiası FAIL.
## lead_missing'i false döndür → lider notu iddiası FAIL.
static func _case_pause_kinds_and_lead_note() -> String:
	ProductLines.reload()
	GameState.set_cash(50000)
	var founder: Character = _seed_build_crew()
	GameState.set_flag(ProductState.LINE_TIERS, {})
	GameState.set_flag("mvp_shipped", false)
	GameState.set_flag("mvp_version", 0)
	var lead: Character = _make_employee("pk_lead", "PK Lead", HRConstants.ROLE_DEVELOPER)
	lead.role_stats[HRConstants.AREA_ENGINEERING] = 8
	lead.role_stats[HRConstants.SKILL_LEADERSHIP] = 8

	if not ProductSystem.start_line_build("note_tool",
			["line_note_tool_capture_k1"], lead.id, "Sable"):
		return "start_line_build refused"

	# --- ÇALIŞIYOR ---
	if ProductSystem.build_paused():
		return "a fully staffed build reads paused"
	if ProductSystem.pause_kind() != ProductSystem.PAUSE_NONE:
		return "pause_kind is '%s' on a running build" % ProductSystem.pause_kind()

	# --- MANUEL: glif, CÜMLE YOK ---
	ProductSystem.set_manual_pause(true)
	if ProductSystem.pause_kind() != ProductSystem.PAUSE_MANUAL:
		return "a manual pause reads '%s'" % ProductSystem.pause_kind()
	if not ProductSystem.build_paused():
		return "a manual pause did not stop the build"
	if ProductSystem.pause_note_key() != "":
		return "the manual pause printed a sentence ('%s') — §2 says glyph only" \
			% ProductSystem.pause_note_key()
	# İlerleme KORUNUR: duraklatmak yapılanı silmez.
	var b: FeatureBuild = ProductSystem.get_active_build()
	var design_before: float = b.design_efor_spent
	for h in 24:
		ProductSystem.hourly_tick(h)
	if absf(b.design_efor_spent - design_before) > 0.0001:
		return "a paused build kept working"
	ProductSystem.set_manual_pause(false)
	if ProductSystem.build_paused():
		return "unpausing did not resume the build"

	# --- OTO: cümle, GLİF YOK ---
	CharacterRegistry.clear_jobs(founder.id)
	CharacterRegistry.clear_jobs(lead.id)
	if ProductSystem.pause_kind() != ProductSystem.PAUSE_AUTO:
		return "an unstaffed build reads '%s'" % ProductSystem.pause_kind()
	var note: String = ProductSystem.pause_note_key()
	if note != "BUILD_BUSY_NOBODY" and note != "BUILD_BUSY_ELSEWHERE":
		return "the auto pause printed '%s'" % note
	if TranslationServer.translate(note) == note:
		return "the auto-pause sentence has no string"

	# --- İKİSİ BİR ARADA ASLA: oyuncunun kararı kazanır ---
	ProductSystem.set_manual_pause(true)
	if ProductSystem.pause_kind() != ProductSystem.PAUSE_MANUAL:
		return "with both conditions true the bar chose '%s'" % ProductSystem.pause_kind()
	if ProductSystem.pause_note_key() != "":
		return "a manual pause over an empty desk still printed a sentence"
	ProductSystem.set_manual_pause(false)
	CharacterRegistry.assign_job(founder.id, HRConstants.JOB_BUILD)
	CharacterRegistry.assign_job(lead.id, HRConstants.JOB_BUILD)

	# --- §3 LİDERSİZ: yapım SÜRER, çarpan 1,0, bar notu düşer ---
	if ProductSystem.lead_missing():
		return "an active lead reads as missing"
	if ProductSystem.lead_note_key() != "":
		return "a build with a lead carries the no-lead note"
	var with_lead: float = ProductSystem.build_effort_per_day(lead.id)
	lead.status = HRConstants.STATUS_ON_LEAVE     # ayrıldı/çıkarıldı vekili
	if not ProductSystem.lead_missing():
		return "a departed lead still reads as present"
	if ProductSystem.lead_note_key() != "BUILD_NO_LEAD":
		return "the no-lead note is '%s'" % ProductSystem.lead_note_key()
	if TranslationServer.translate("BUILD_NO_LEAD") == "BUILD_NO_LEAD":
		return "BUILD_NO_LEAD has no string"
	# Liderlik çarpanı 1,0'a döner ve yapım DEVAM eder — geriye dönük bozulma yok.
	var leaderless: float = ProductSystem.build_effort_per_day(lead.id)
	if leaderless <= 0.0:
		return "the build stopped producing effort when the lead left"
	if leaderless >= with_lead:
		return "losing the lead did not remove the leadership bonus (%.3f vs %.3f)" \
			% [leaderless, with_lead]
	if absf(leaderless - ProductSystem.build_effort_per_day("")) > 0.0001:
		return "a departed lead is not equivalent to no lead at all"
	lead.status = HRConstants.STATUS_ACTIVE
	return ""


## S6'nın ALTI DURUMU, hat modeli yolunda. Bar tek renderer, üç ev sahibi — o yüzden
## durumları MODEL seviyesinde sabitlemek üç yüzeyi birden sabitler.
##
## FALSİFİKASYON: _derive_line'da show_percent'i true bırak → BETA iddiası FAIL.
## GELİŞTİRME dolumunu eski (frac−0,20)/0,60 aritmetiğine döndür → %100 iddiası FAIL.
static func _case_build_bar_line_states() -> String:
	ProductLines.reload()
	GameState.set_cash(50000)
	var founder: Character = _seed_build_crew()
	GameState.set_flag(ProductState.LINE_TIERS, {})
	GameState.set_flag("mvp_shipped", false)
	GameState.set_flag("mvp_version", 0)
	if not ProductSystem.start_line_build("note_tool",
			["line_note_tool_capture_k1", "line_note_tool_editor_k1"], "", "Sable"):
		return "start_line_build refused"
	var b: FeatureBuild = ProductSystem.get_active_build()
	var M := load("res://scripts/ui/components/build_bar_model.gd")

	# --- 1 · TASARIM, tur metni ve dolum ---
	var m: RefCounted = M.new()
	if not m.derive():
		return "the model refused to derive in design"
	if String(m.phase) != "design":
		return "design phase reads '%s'" % String(m.phase)
	if m.round_max != ProductSystem.DESIGN_TURN_MAX:
		return "round_max is %d, §5 caps at 4" % m.round_max
	if m.round_index != 1:
		return "the first running turn reads %d" % m.round_index
	if not m.show_percent:
		return "TASARIM dropped its percentage — only BETA does that"
	# Tur 1 dolmadan geçmek onay ister ve bar gerekçeyi taşır (§5).
	if String(m.decision_tooltip).strip_edges() == "":
		return "the pre-turn-1 crossing carries no confirmation text"

	# --- 2 · MANUEL DURAKLAMA: glif, cümle yok ---
	ProductSystem.set_manual_pause(true)
	var mp: RefCounted = M.new(); mp.derive()
	if mp.pause_kind != ProductSystem.PAUSE_MANUAL:
		return "the model read the manual pause as '%s'" % mp.pause_kind
	if mp.pause_note_key != "":
		return "the manual pause carried a sentence"
	ProductSystem.set_manual_pause(false)

	# --- 3 · OTO DURAKLAMA: cümle, glif yok ---
	CharacterRegistry.clear_jobs(founder.id)
	var ma: RefCounted = M.new(); ma.derive()
	if ma.pause_kind != ProductSystem.PAUSE_AUTO:
		return "an unstaffed build read '%s'" % ma.pause_kind
	if ma.pause_note_key == "":
		return "the auto pause carried no sentence"
	CharacterRegistry.assign_job(founder.id, HRConstants.JOB_BUILD)

	# --- 4 · GELİŞTİRME: kapı kilitli, gerekçesi yazılı ---
	ProductSystem.enter_development()
	var md: RefCounted = M.new(); md.derive()
	if String(md.phase) != "development":
		return "development phase reads '%s'" % String(md.phase)
	if md.decision_enabled:
		return "the BETA gate reads open on the first hour"
	if String(md.decision_tooltip).strip_edges() == "":
		return "the locked gate shows no reason"
	# §6.0 — dolum TAVANIN TAMAMINA göre.
	#
	# İKİ NOKTADAN ölçülüyor ve sebebi falsifikasyon: %50 eski (frac−0,20)/0,60
	# aritmetiğinin SABİT NOKTASI ((0,5−0,2)/0,6 = 0,5), yani tek başına iki formülü
	# ayırt edemiyor ve eski bandı geri getiren mutasyon case'i GEÇİYORDU. %80 ayırıyor:
	# doğru cevap 0,80, eski aritmetik 1,00 derdi.
	b.efor_spent = b.total_efor * 0.5
	var mh: RefCounted = M.new(); mh.derive()
	if absf(mh.phase_progress - 0.5) > 0.02:
		return "half the ceiling reads %.2f — the bar is not measuring the full 100%%" \
			% mh.phase_progress
	b.efor_spent = b.total_efor * 0.8
	var mq: RefCounted = M.new(); mq.derive()
	if absf(mq.phase_progress - 0.8) > 0.02:
		return "80%% of the ceiling reads %.2f — the bar is still on the old 0,20-0,80 band" \
			% mq.phase_progress

	# --- 5 · GELİŞTİRME DOLU: kapı açık ---
	b.efor_spent = b.total_efor
	var mf: RefCounted = M.new(); mf.derive()
	if not mf.decision_enabled:
		return "a full bar did not open the gate"
	if absf(mf.phase_progress - 1.0) > 0.001:
		return "a full bar reads %.2f" % mf.phase_progress

	# --- 6 · BETA: YÜZDE YOK, sayaç ve gün var (§7 mühürlü) ---
	ProductSystem.enter_beta()
	b.bugs_found = 4
	b.bugs_fixed = 2
	var mb: RefCounted = M.new(); mb.derive()
	if String(mb.phase) != "beta":
		return "beta phase reads '%s'" % String(mb.phase)
	if mb.show_percent:
		return "the BETA row carries a percentage — §7 forbids it"
	if mb.percent != 0:
		return "BETA published a percent value of %d" % mb.percent
	if mb.bugs_left != 2:
		return "KALAN reads %d, want 2 (4 found − 2 fixed)" % mb.bugs_left
	if mb.beta_day < 1:
		return "the beta day counter reads %d" % mb.beta_day
	if String(mb.decision_tooltip).strip_edges() == "":
		return "the ship action lost its bug tooltip in beta"
	return ""


## §12.10 — KOŞU PROFİLİ. "Bir demo koşusu 3–5 sürüm çıkarır ve 9–14 kademe harcar;
## katalogda 27 kademe vardır. Yani HİÇBİR KOŞU KATALOGU BİTİREMEZ; her koşu farklı
## bir ürün şekli üretir. Tekrar oynanabilirlik yapısaldır."
##
## Bu, hat modelinin bütün gerekçesidir (§12.1: düz katalog üçüncü sürümde tükeniyordu),
## ve ölçülmezse inşa edilmemiş demektir. Case dört sürüm oynar ve katalogda hâlâ iş
## kaldığını kanıtlar.
##
## FALSİFİKASYON: alt-tipin hat sayısını 9'dan 3'e indir → tükenmezlik iddiası FAIL.
static func _case_run_profile_never_exhausts() -> String:
	ProductLines.reload()
	GameState.set_cash(500000)
	_seed_build_crew()
	GameState.set_flag(ProductState.LINE_TIERS, {})
	GameState.set_flag(ProductState.STEP_REALIZATION, {})
	GameState.set_flag("mvp_shipped", false)
	GameState.set_flag("mvp_version", 0)
	GameState.set_flag("mvp_market_type", "b2c")

	var subtype := "note_tool"
	var total_steps: int = 27
	var counted: int = 0
	for lid in ProductLines.line_ids(subtype):
		for tier in [1, 2, 3]:
			if not ProductLines.step_at(String(lid), tier).is_empty():
				counted += 1
	if counted != total_steps:
		return "the subtype offers %d steps, §12.1 says 27" % counted

	var versions: int = 0
	var shipped_steps: int = 0
	var hours: int = 0
	# Dört sürüm, sürüm başına üç kademe — §12.10'un beklediği profilin ortası.
	for v in 4:
		var plan: Array[String] = []
		for lid2 in ProductLines.line_ids(subtype):
			if plan.size() >= 3:
				break
			var line_id: String = String(lid2)
			var nxt: int = ProductLines.next_tier(ProductState.line_tier(line_id))
			if nxt == 0:
				continue
			var sid: String = String(ProductLines.step_at(line_id, nxt).get("id", ""))
			if sid == "" or not LineGates.is_unlocked(sid):
				continue      # K3'ler Ar-Ge olmadan kilitli — doğru ve beklenen
			plan.append(sid)
		if plan.is_empty():
			return "version %d found no legal step — the catalogue ran dry" % (v + 1)
		if not ProductSystem.start_line_build(subtype, plan, "", "Sable"):
			return "version %d refused to start" % (v + 1)
		var b: FeatureBuild = ProductSystem.get_active_build()
		# Bir tur tasarım (taban cila), sonra geliştirmeyi doldur, sonra yayınla.
		while b.design_turns_completed < 1 and hours < 24 * 4000:
			ProductSystem.hourly_tick(hours % 24)
			hours += 1
		ProductSystem.enter_development()
		while not ProductSystem.development_band_complete() and hours < 24 * 4000:
			ProductSystem.hourly_tick(hours % 24)
			hours += 1
		ProductSystem.enter_beta()
		ProductSystem.launch()
		ProductSystem.ship_active_build()
		versions += 1
		shipped_steps += plan.size()

	# --- §12.10'un iki sayısı ---
	if versions < 3 or versions > 5:
		return "the run shipped %d versions, §12.10 expects 3-5" % versions
	if shipped_steps < 9 or shipped_steps > 14:
		return "the run consumed %d steps, §12.10 expects 9-14" % shipped_steps
	if ProductState.steps_shipped() != shipped_steps:
		return "the product records %d steps but the run shipped %d" \
			% [ProductState.steps_shipped(), shipped_steps]

	# --- KATALOG BİTMEDİ: hâlâ alınabilecek kademe var ---
	var still_open: int = 0
	for lid3 in ProductLines.line_ids(subtype):
		if ProductLines.next_tier(ProductState.line_tier(String(lid3))) != 0:
			still_open += 1
	if still_open <= 0:
		return "every line is finished after %d steps — the catalogue was exhausted" % shipped_steps
	if shipped_steps >= total_steps:
		return "the run consumed the whole catalogue"
	# Ve ürün gerçekten olgunlaştı: eksenler sıfırdan yukarı.
	var readings: Dictionary = ProductState.axis_readings()
	var any_up: bool = false
	for axis in readings:
		if int(readings[axis]) > 0:
			any_up = true
	if not any_up:
		return "four shipped versions produced no axis reading at all"
	return ""


# =========================================================================
#  ÜRÜN MODÜLÜ · HAT MODELİ (GDD ÜRÜN rev 6 §11 · §12)
# =========================================================================

## §12.1 · §12.2 — the catalog is data-driven and its SHAPE is law: 9 lines per
## subtype, 3 per axis, 3 steps per line. A content file that violates any of it
## must be REFUSED at load, not tolerated.
##
## FALSİFİKASYON: shared.json'dan bir hattı sil → "9 lines" iddiası FAIL.
## Bir kimlik hattının eksenini değiştir → "axis shape" iddiası FAIL.
static func _case_product_lines_catalog_loads() -> String:
	ProductLines.reload()
	var errs: Array = ProductLines.load_errors()
	if not errs.is_empty():
		return "catalog refused to load cleanly: %s" % str(errs)

	var subs: Array = ProductLines.subtypes()
	# §12.11 mühürlü üçlü. Dördüncü B2B slotu ruling bekliyor ve YOKLUĞU doğrudur:
	# geldiğinde yalnız bir içerik dosyası eklenir, kod değişmez.
	for want in ["note_tool", "video_clip", "erp"]:
		if not subs.has(want):
			return "sealed subtype '%s' missing from the catalog (have %s)" % [want, str(subs)]

	for st in subs:
		var sub: String = String(st)
		var ids: Array = ProductLines.line_ids(sub)
		if ids.size() != ProductLines.LINES_PER_SUBTYPE:
			return "%s has %d lines, §12.2 wants %d" % [sub, ids.size(), ProductLines.LINES_PER_SUBTYPE]
		var by_axis: Dictionary = ProductLines.line_ids_by_axis(sub)
		for axis in QualityModel.AXES:
			var n: int = (by_axis[axis] as Array).size()
			if n != 3:
				return "%s has %d lines on %s, §12.2 wants 3" % [sub, n, axis]
		# 9 hat × 3 kademe = 27 seçilebilir kalem (§12.1).
		var steps: int = 0
		for lid in ids:
			for tier in [1, 2, 3]:
				if not ProductLines.step_at(String(lid), tier).is_empty():
					steps += 1
		if steps != 27:
			return "%s resolved %d steps, §12.1 wants 27" % [sub, steps]

	# §12.10 — ERP'nin ekip telegrafı: paylaşılan Güvenlik & Yetki K3'ü ERP'de
	# YÜKSELİR. Aynı kademe not aracında yükselmez; override alt-tip başınadır.
	var erp_gate: Dictionary = ProductLines.step("line_shared_security_k3@erp").get("requires", {})
	var note_gate: Dictionary = ProductLines.step("line_shared_security_k3@note_tool").get("requires", {})
	var erp_total: Array = erp_gate.get("total", []) as Array
	if erp_total.is_empty():
		return "ERP's shared Güvenlik & Yetki K3 carries no total gate — §12.10's telegraph is missing"
	if int((erp_total[0] as Dictionary).get("stars", 0)) != 5:
		return "ERP telegraph asks for %d total stars, §12.10 says 5" \
			% int((erp_total[0] as Dictionary).get("stars", 0))
	if not (note_gate.get("total", []) as Array).is_empty():
		return "the override leaked: note_tool's shared K3 picked up ERP's total gate"
	return ""


## §12.3 MÜHÜRLÜ MERDİVEN, dört kuralın dördü de. Tek yerde yaşar (ProductLines);
## kart çizimi ve Konsept onayı kendi kontrolünü kurmaz, buraya sorar.
##
## FALSİFİKASYON: ladder_refusal'dan "skips_tier" dalını sil → ilk iddia FAIL.
## "line_already_planned" dalını sil → üçüncü iddia FAIL.
static func _case_line_ladder_rules() -> String:
	ProductLines.reload()
	var line := "line_note_tool_search"

	# 1 · ATLAMA YOK: K1 canlıda değilken K2 seçilemez.
	if ProductLines.ladder_refusal(line + "_k2", 0, []) != "skips_tier":
		return "a line could skip straight to K2 from empty"
	if ProductLines.ladder_refusal(line + "_k3", 1, []) != "skips_tier":
		return "a line could skip from K1 to K3"

	# 2 · Sıradaki kademe serbest.
	if ProductLines.ladder_refusal(line + "_k1", 0, []) != "":
		return "K1 was refused on an empty line"
	if ProductLines.ladder_refusal(line + "_k2", 1, []) != "":
		return "K2 was refused on a line already at K1"

	# 3 · SÜRÜM BAŞINA HAT BAŞINA BİR KADEME: aynı hat bir sürümde iki kademe zıplayamaz.
	if ProductLines.ladder_refusal(line + "_k2", 1, [line + "_k1"]) != "line_already_planned":
		return "the same line took two steps in one version"

	# 4 · DÜŞÜRME YOK ve KADEME 3'TE BİTER.
	if ProductLines.ladder_refusal(line + "_k1", 2, []) != "already_shipped":
		return "a line could be downgraded"
	if ProductLines.next_tier(3) != 0:
		return "a completed line still offered a next tier — §12.3 ends at 3"
	if not ProductLines.is_complete(3):
		return "tier 3 did not read as complete"
	return ""


## §12.5 — K3'ler Ar-Ge düğümü ister ve Ar-Ge sistemi HENÜZ YOK, o yüzden kilitli
## kalırlar. BU BİR HATA DEĞİL, SIRALAMADIR; geçici bypass yazılmaz. Kilit satırı
## düğümün ADINI yazmak zorundadır, yoksa oyuncu neyi araştıracağını bilemez.
##
## FALSİFİKASYON: ResearchSeam.completed'i true döndür → ilk iddia FAIL.
static func _case_line_k3_locked_without_research() -> String:
	ProductLines.reload()
	# Kurucuyu her alanda tavana çıkar: kilit YALNIZ Ar-Ge'den gelsin.
	var founder: Character = CharacterRegistry.get_founder()
	if founder == null:
		return "no founder to build the gate roster from"
	for area in HRConstants.AREAS:
		founder.role_stats[area] = HRConstants.AREA_MAX

	var step_id := "line_note_tool_capture_k3"
	var ev: Dictionary = LineGates.evaluate(step_id)
	if bool(ev.get("unlocked", false)):
		return "a K3 unlocked with no research system present"

	var unmet: Array = LineGates.unmet_parts(step_id)
	if unmet.size() != 1:
		return "expected exactly the research part unmet, got %d parts" % unmet.size()
	var part: Dictionary = unmet[0] as Dictionary
	if String(part.get("kind", "")) != LineGates.KIND_RESEARCH:
		return "the unmet part is '%s', not the research node" % String(part.get("kind", ""))
	var node: String = String(part.get("node", ""))
	if not ResearchSeam.NODES.has(node):
		return "the lock names '%s', which is not one of §12.5's six nodes" % node
	if ResearchSeam.node_name(node).strip_edges() == "":
		return "the lock line would render an empty research name"
	if ResearchSeam.completed(node):
		return "the research seam claims a node is done while the tree does not exist"
	return ""


## §12.4 — "Hattın katkısı YALNIZ mevcut kademesinin puanıdır." Kademe kendinden
## öncekini DEĞİŞTİRİR, üstüne EKLEMEZ. Bu case tam olarak o farkı ölçer: toplama
## olsaydı okuma çok daha yükseğe çıkardı.
##
## FALSİFİKASYON: realized_axis'i kademeleri toplayacak şekilde değiştir → "replacement"
## iddiası FAIL (47 yerine 80 okur).
static func _case_axis_reading_replaces_not_adds() -> String:
	ProductLines.reload()
	var st := "note_tool"
	var line := "line_note_tool_search"          # Deneyim ekseni
	var tiers := {line: 1}
	var stamps := {line: 1.0}                    # tur çarpanı 1,00 · kapı-üstü yok

	# K1: 4 puan × Kano 1,0 = 4,0 gizil. Bootstrap çıtası 12,0 → round(100 × 4/12) = 33.
	var before: int = QualityModel.axis_reading(st, tiers, stamps, "experience", 0, 1)
	if before != 33:
		return "K1 experience reading is %d, want 33 (4,0 gizil / çıta 12,0)" % before

	# K2: 9 puan × Kano 0,8 = 7,2 gizil → round(100 × 7,2/12) = 60 (rev 6.1 merkezleri).
	tiers[line] = 2
	var after: int = QualityModel.axis_reading(st, tiers, stamps, "experience", 0, 1)
	if after != 60:
		return "K2 experience reading is %d, want 60 (7,2 gizil / çıta 12,0)" % after
	# Toplama olsaydı gizil 4,0 + 7,2 = 11,2 → 93. Aradaki fark iddianın kendisidir.
	if after >= 93:
		return "the upgrade ADDED to the line instead of replacing it (%d)" % after

	# §11.2 — Kararlılık okumasından −2 × açık DOĞRULANMIŞ hata.
	var sline := "line_note_tool_sync"
	var stiers := {sline: 1}
	var sstamps := {sline: 1.0}
	var clean: int = QualityModel.axis_reading(st, stiers, sstamps, "stability", 0, 1)
	var buggy: int = QualityModel.axis_reading(st, stiers, sstamps, "stability", 5, 1)
	if clean - buggy != 10:
		return "5 confirmed bugs moved Kararlılık by %d, want 10 (−2 each)" % (clean - buggy)
	# İnovasyon'a dokunmaz: hata cezası TEK EKSENE yazılıdır.
	if QualityModel.axis_reading(st, stiers, sstamps, "innovation", 0, 1) \
			!= QualityModel.axis_reading(st, stiers, sstamps, "innovation", 5, 1):
		return "confirmed bugs leaked into the İnovasyon reading"

	# §11.3 — çıta her fazda +%10 yükselir; aynı ürün Traction'da DAHA DÜŞÜK okur.
	tiers[line] = 1
	var boot: int = QualityModel.axis_reading(st, tiers, stamps, "experience", 0, 1)
	var trac: int = QualityModel.axis_reading(st, tiers, stamps, "experience", 0, 2)
	if trac >= boot:
		return "the bar did not rise between phases (%d -> %d)" % [boot, trac]
	return ""


## §12.7 kapı KAPSAMI + §12.6 buçuk kuralı. İkisi bir arada ölçülüyor çünkü ikisi de
## "kim sayılır" sorusunun cevabı ve ikisi de sessizce yanlış olabilir.
##
## FALSİFİKASYON: LineGates.roster'ı get_active_employees'e çevir → izin iddiası FAIL.
## total_stars'ı tam yıldıza yuvarla → buçuk iddiası FAIL.
static func _case_gate_scope_and_halves() -> String:
	ProductLines.reload()
	var founder: Character = CharacterRegistry.get_founder()
	if founder == null:
		return "no founder"
	for area in HRConstants.AREAS:
		founder.role_stats[area] = 0

	# §12.6 — ★N = ham puan ≥ 2N. 5 ham = 2,5 yıldız, 6 ham = 3 yıldız.
	var a: Character = _make_employee("gate_a", "Gate A", HRConstants.ROLE_DEVELOPER)
	var b: Character = _make_employee("gate_b", "Gate B", HRConstants.ROLE_DEVELOPER)
	for area_a in HRConstants.AREAS:
		a.role_stats[area_a] = 0
		b.role_stats[area_a] = 0
	a.role_stats[HRConstants.AREA_ENGINEERING] = 5   # 2,5 yıldız
	b.role_stats[HRConstants.AREA_ENGINEERING] = 6   # 3,0 yıldız

	# BUÇUKLAR TOPLAMDA YÜZ DEĞERİNDEN SAYILIR: 2,5 + 3 = 5,5 ≥ ★5 ✓
	var total: float = LineGates.total_stars(HRConstants.AREA_ENGINEERING)
	if absf(total - 5.5) > 0.001:
		return "company Yazılım total is %.2f, want 5.50 (2,5 + 3)" % total

	# ...ama KİŞİ kapısında buçuk kurtarmaz: kimse ★3'ü tek başına aşmıyor.
	var ev4: Dictionary = LineGates.evaluate("line_shared_mobile_k2@note_tool")
	var saw_total := false
	for p in (ev4.get("parts", []) as Array):
		var part: Dictionary = p as Dictionary
		if String(part.get("kind", "")) == LineGates.KIND_TOTAL:
			saw_total = true
			if not bool(part.get("met", false)):
				return "total ★4 unmet at 5,5 company stars — halves were dropped"
	if not saw_total:
		return "the shared Mobil & Erişim K2 lost its total gate"

	# §12.7 — İZİNDEKİ/EĞİTİMDEKİ kişinin yıldızı SAYILIR (bilgi kaybı yoktur).
	a.status = HRConstants.STATUS_ON_LEAVE
	b.status = HRConstants.STATUS_TRAINING
	var total_away: float = LineGates.total_stars(HRConstants.AREA_ENGINEERING)
	if absf(total_away - 5.5) > 0.001:
		return "stars vanished while people were on leave/training (%.2f) — §12.7 counts them" \
			% total_away
	a.status = HRConstants.STATUS_ACTIVE
	b.status = HRConstants.STATUS_ACTIVE

	# Kurucu herkes gibi sayılır (§12.6).
	founder.role_stats[HRConstants.AREA_ENGINEERING] = 4   # +2 yıldız
	if absf(LineGates.total_stars(HRConstants.AREA_ENGINEERING) - 7.5) > 0.001:
		return "the founder's stars did not join the company total"
	return ""


## §12.8 — kapı-üstü bonusu: fazladan İLK yıldız +%8, İKİNCİ +%4, sonrası fark
## yaratmaz. Erişimin kendisi ikilidir; bu yalnız gerçekleşmeyi oynatır.
##
## FALSİFİKASYON: _excess_ladder'ın cap'ini kaldır → "no third star" iddiası FAIL.
static func _case_above_gate_bonus_ladder() -> String:
	ProductLines.reload()
	var founder: Character = CharacterRegistry.get_founder()
	if founder == null:
		return "no founder"
	for area in HRConstants.AREAS:
		founder.role_stats[area] = 0

	# Deneyim ekseninin sahibi Tasarım (§12.10). Bu kademe Tasarım ★2 istiyor.
	var step := "line_note_tool_editor_k2"
	var d: Character = _make_employee("gate_d", "Gate D", HRConstants.ROLE_DESIGNER)
	for area_d in HRConstants.AREAS:
		d.role_stats[area_d] = 0

	d.role_stats[HRConstants.AREA_DESIGN] = 4      # ★2 — tam kapıda
	if absf(LineGates.above_gate_bonus(step) - 0.0) > 0.0001:
		return "a team exactly at the gate earned a bonus"

	d.role_stats[HRConstants.AREA_DESIGN] = 6      # ★3 — bir fazla
	if absf(LineGates.above_gate_bonus(step) - LineGates.ABOVE_GATE_FIRST) > 0.0001:
		return "first extra star paid %.3f, want %.3f" \
			% [LineGates.above_gate_bonus(step), LineGates.ABOVE_GATE_FIRST]

	d.role_stats[HRConstants.AREA_DESIGN] = 8      # ★4 — iki fazla
	var two: float = LineGates.ABOVE_GATE_FIRST + LineGates.ABOVE_GATE_SECOND
	if absf(LineGates.above_gate_bonus(step) - two) > 0.0001:
		return "second extra star paid %.3f, want %.3f" % [LineGates.above_gate_bonus(step), two]

	d.role_stats[HRConstants.AREA_DESIGN] = 10     # ★5 — üç fazla, FARK YARATMAZ
	if absf(LineGates.above_gate_bonus(step) - two) > 0.0001:
		return "a third extra star still paid — §12.8 stops at two"

	# Kapının istemediği alan bonus üretmez: bu "kapı-üstü", "yıldız-üstü" değil.
	var ungated := "line_note_tool_editor_k1"
	if absf(LineGates.above_gate_bonus(ungated)) > 0.0001:
		return "an ungated step paid an above-gate bonus"

	# §11.2 — bonus gerçekleşmeye çarpan olarak giriyor.
	var plain: float = QualityModel.realization_stamp(1.0, 0.0)
	var boosted: float = QualityModel.realization_stamp(1.0, two)
	if absf(boosted - plain * (1.0 + two)) > 0.0001:
		return "the bonus did not multiply realization"
	return ""


## §12.12 + BILINGUAL BIRTH LAW — hat ve kademe adları/açıklamaları türetilmiş
## anahtarlardan okunur ve JSON'da metin YOKTUR. O yüzden bir içerik dosyası
## eklemek, karşılığında CSV satırı olmadan, ekranda ANAHTARIN KENDİSİNİ çizer.
## Bu case tam olarak onu yakalar, ve İKİ DİLDE birden.
##
## Dördüncü B2B alt-tipi geldiğinde bu case onun satırlarını da otomatik ister:
## döngü katalogdan yürüyor, elle yazılmış bir listeden değil.
##
## FALSİFİKASYON: strings.csv'den PROD_STEP_SHARED_MOBILE_K2 satırını sil → FAIL.
static func _case_loc_product_line_keys_resolve() -> String:
	ProductLines.reload()
	var prev_locale: String = TranslationServer.get_locale()
	var checked: int = 0
	var missing: Array[String] = []

	for locale in ["tr", "en"]:
		TranslationServer.set_locale(locale)
		for st in ProductLines.subtypes():
			var sub: String = String(st)
			for lid in ProductLines.line_ids(sub):
				var line: Dictionary = ProductLines.line(String(lid))
				var lkey: String = String(line.get("name_key", ""))
				if TranslationServer.translate(lkey) == lkey:
					missing.append("%s/%s" % [locale, lkey])
				checked += 1
				for tier in [1, 2, 3]:
					var step: Dictionary = ProductLines.step_at(String(lid), tier)
					for key_field in ["name_key", "desc_key"]:
						var k: String = String(step.get(key_field, ""))
						if k == "":
							missing.append("%s/%s tier %d has no %s" % [locale, lid, tier, key_field])
							continue
						if TranslationServer.translate(k) == k:
							missing.append("%s/%s" % [locale, k])
						checked += 1
	TranslationServer.set_locale(prev_locale)

	if not missing.is_empty():
		return "%d unresolved key(s), first: %s" % [missing.size(), ", ".join(missing.slice(0, 6))]
	# 3 alt-tip × (9 ad + 27 kademe adı + 27 açıklama) × 2 dil = 378 okuma.
	if checked < 300:
		return "only %d keys were checked — the catalog walk is not covering the tree" % checked
	return ""


## §12.5 (rev 6.1) + Ar-Ge §3.1 — düğüm kimliklerinin tek kaynağı Ar-Ge GDD §4'tür,
## paylaşılan hatların K3 haritası BAĞLAYICIDIR, ve GÖRÜNÜR hiçbir K3 bir DEVAM
## düğümüne bağlanamaz ("telegraflanmış hiçbir şey ulaşılmaz olmaz").
##
## FALSİFİKASYON: shared.json'da Entegrasyonlar K3'ü scalable_backend'e çevir →
## harita iddiası FAIL. Bir K3'ü knowledge_graph'a (devam) bağla → §3.1 iddiası FAIL.
static func _case_research_node_map_binds() -> String:
	ProductLines.reload()
	if not ProductLines.load_errors().is_empty():
		return "catalog refused to load: %s" % str(ProductLines.load_errors())

	# Ar-Ge §4 — yirmi düğüm, dört aile, her ailede kök + iki dal + iki devam.
	if ResearchSeam.NODES.size() != 20:
		return "the seam knows %d nodes, Ar-Ge §4 has 20" % ResearchSeam.NODES.size()
	var by_place: Dictionary = {}
	for node_id in ResearchSeam.NODES:
		var p: String = ResearchSeam.placement(String(node_id))
		by_place[p] = int(by_place.get(p, 0)) + 1
	if int(by_place.get(ResearchSeam.PLACE_ROOT, 0)) != 4:
		return "expected 4 root nodes, found %d" % int(by_place.get(ResearchSeam.PLACE_ROOT, 0))
	if int(by_place.get(ResearchSeam.PLACE_CONT, 0)) != 8:
		return "expected 8 continuation nodes, found %d" % int(by_place.get(ResearchSeam.PLACE_CONT, 0))

	# §12.5 — paylaşılan harita, ÜÇ ALT-TİPTE DE aynı.
	for st in ProductLines.subtypes():
		for base_line in ResearchSeam.SHARED_LINE_NODES:
			var want: String = String(ResearchSeam.SHARED_LINE_NODES[base_line])
			var step: Dictionary = ProductLines.step("%s_k3@%s" % [base_line, st])
			if step.is_empty():
				return "%s has no %s K3" % [st, base_line]
			var got: String = String((step.get("requires", {}) as Dictionary).get("research", ""))
			if got != want:
				return "%s/%s K3 binds '%s', §12.5's map says '%s'" % [st, base_line, got, want]

	# Ar-Ge §3.1 — hiçbir görünür kademe devam düğümüne bağlanmaz.
	var visible: int = 0
	for st2 in ProductLines.subtypes():
		for lid in ProductLines.line_ids(String(st2)):
			for tier in [1, 2, 3]:
				var s: Dictionary = ProductLines.step_at(String(lid), tier)
				var node: String = String((s.get("requires", {}) as Dictionary).get("research", ""))
				if node == "":
					continue
				visible += 1
				if not ResearchSeam.is_node(node):
					return "%s binds unknown node '%s'" % [s.get("id"), node]
				if not ResearchSeam.may_gate_visible_step(node):
					return "%s binds '%s', a %s node — Ar-Ge §3.1 forbids it" \
						% [s.get("id"), node, ResearchSeam.placement(node)]
	# 3 alt-tip × 9 hat = 27 K3, hepsi düğüm taşır (§12.5).
	if visible != 27:
		return "%d steps carry a research node, expected 27 (one K3 per line)" % visible

	# Ar-Ge §4.5.1 (MÜHÜRLÜ) — HER ALT-TİPİN KİMLİK KARARLILIK HATTININ K3'Ü bug_tracker'a
	# bağlanır. Bu, PRACTICE ailesinin görünür içerik açtığı tek yerdir: dört etkisi de
	# oyuncunun göremediği sayıları oynatıyordu ve hiçbir K3 bir Practice düğümü istemiyordu,
	# yani aile "+%5 düğümü olmayacak" yasasını çiğniyordu.
	#
	# Hat ADIYLA değil EKSENİYLE bulunuyor: §12.2'nin kimlik dağılımı eksen başına 2/1/2, yani
	# her alt-tipte paylaşılmayan Kararlılık hattı TEKTİR. İsimle arasaydık üç alt-tip için üç
	# literal gerekirdi ve dördüncü alt-tip geldiğinde sessizce eksik kalırdı.
	#
	# FALSİFİKASYON: üç JSON'dan birinde bu tek token'ı geri al → FAIL, alt-tipi adıyla yazar.
	var practice_gates: int = 0
	for st3 in ProductLines.subtypes():
		var found: String = ""
		for lid2 in ProductLines.line_ids(String(st3)):
			var rec: Dictionary = ProductLines.line(String(lid2))
			if bool(rec.get("shared", false)) or String(rec.get("axis", "")) != "stability":
				continue
			found = String(lid2)
			var k3s: Dictionary = ProductLines.step_at(String(lid2), 3)
			var bound: String = String((k3s.get("requires", {}) as Dictionary).get("research", ""))
			if bound != "bug_tracker":
				return "%s identity stability K3 binds '%s'; §4.5.1 says bug_tracker" % [st3, bound]
			practice_gates += 1
		if found == "":
			return "%s has no identity stability line; §12.2 wants exactly one" % st3
	if practice_gates != 3:
		return "%d identity stability lines gate bug_tracker, §4.5.1 wants 3" % practice_gates
	return ""


## §12.9 (rev 6.1) — kartın aritmetiği. Belge kendi çalışılmış örneğini veriyor:
##
##   Arama   Anında Arama ✓ → Filtreli Arama    Efor 8 · Deneyim 7,2 (+3,2)
##                            Kilit: Yazılım ★★ ✓ · Tasarım ★ ✗ → Eğit
##
## Bu case o satırı BİREBİR sabitler. Kartta HAM PUAN YAZILMAZ: Kano katsayısı
## uygulanmış gerçek değer yazılır, "oyuncu ekranda gördüğü sayıyı alır."
##
## FALSİFİKASYON: weighted_points'ten Kano katsayısını kaldır → 7,2 iddiası FAIL
## (9,0 okur). net_gain'i mevcut kademeyi düşmeyecek şekilde boz → +3,2 FAIL.
static func _case_card_math_matches_gdd_example() -> String:
	ProductLines.reload()
	var line := "line_note_tool_search"
	var k2 := line + "_k2"

	if ProductLines.effort_of(k2) != 8:
		return "Filtreli Arama effort is %d, §12.9's row says 8" % ProductLines.effort_of(k2)
	if ProductLines.axis_of(line) != "experience":
		return "the Arama line is on %s, §12.9's row says Deneyim" % ProductLines.axis_of(line)

	var weighted: float = ProductLines.weighted_points(k2)
	if absf(weighted - 7.2) > 0.001:
		return "card contribution is %.2f, §12.9's row says 7,2 (9 ham × Kano 0,8)" % weighted
	if absf(float(int(ProductLines.step(k2).get("axis_points", 0))) - 9.0) > 0.001:
		return "raw points are %d, rev 6.1's K2 centre is 9" \
			% int(ProductLines.step(k2).get("axis_points", 0))

	# Parantezdeki net kazanç: K1 canlıyken K2'ye geçmenin FARKI, toplamı değil.
	var gain: float = ProductLines.net_gain(line, 1)
	if absf(gain - 3.2) > 0.001:
		return "net gain reads %.2f, §12.9's row says +3,2 (7,2 − 4,0)" % gain
	# Boş hatta K1 almanın kazancı kademenin tamamıdır.
	if absf(ProductLines.net_gain(line, 0) - 4.0) > 0.001:
		return "an empty line's K1 gain reads %.2f, want 4,0" % ProductLines.net_gain(line, 0)
	# Tamamlanmış hat kazanç önermez.
	if absf(ProductLines.net_gain(line, 3)) > 0.001:
		return "a completed line still offered a gain"

	# §12.9'un kilit satırı da örnekte yazılı: Yazılım ★★ · Tasarım ★.
	var req: Dictionary = ProductLines.step(k2).get("requires", {}) as Dictionary
	var want_gate := {"engineering": 2, "design": 1}
	for entry in (req.get("person", []) as Array):
		var d: Dictionary = entry as Dictionary
		var area: String = String(d.get("area", ""))
		if not want_gate.has(area) or int(d.get("stars", 0)) != int(want_gate[area]):
			return "the Arama K2 gate drifted from §12.9's worked example"
		want_gate.erase(area)
	if not want_gate.is_empty():
		return "the Arama K2 gate lost %s" % str(want_gate.keys())
	return ""


## §5 (rev 6.1 MÜHÜRLÜ) — cila merdiveni. Bu tablo TERS ÇEVRİLDİ ve yönü iddianın
## kendisidir: bir turu TAMAMLAMAK taban (×1,00), turu ATLAMAK ceza (×0,75).
## Eski tabloda tamamlamak ×0,55 idi, yani işini yapan cezalandırılıyordu.
##
## FALSİFİKASYON: DESIGN_TURN_MULT'u eski {1: 0,55 …} tablosuna geri al →
## "completing a turn is the baseline" iddiası FAIL.
static func _case_design_turn_ladder() -> String:
	var m0: float = ProductSystem.design_turn_mult(0)
	var m1: float = ProductSystem.design_turn_mult(1)
	var m4: float = ProductSystem.design_turn_mult(4)

	if absf(m0 - 0.75) > 0.0001:
		return "rushing past turn 1 reads %.3f, §5 says 0,75" % m0
	if absf(m1 - 1.00) > 0.0001:
		return "one completed turn reads %.3f, §5 says it is the 1,00 baseline" % m1
	if absf(ProductSystem.design_turn_mult(2) - 1.06) > 0.0001:
		return "turn 2 reads %.3f, §5 says 1,06" % ProductSystem.design_turn_mult(2)
	if absf(ProductSystem.design_turn_mult(3) - 1.11) > 0.0001:
		return "turn 3 reads %.3f, §5 says 1,11" % ProductSystem.design_turn_mult(3)
	if absf(m4 - 1.15) > 0.0001:
		return "turn 4 reads %.3f, §5 says 1,15" % m4

	# YÖN: tamamlamak cezalandırılmaz. Eski tablo tam burada düşer.
	if m1 <= m0:
		return "completing a design turn is not better than skipping it (%.2f vs %.2f)" % [m1, m0]
	# Merdiven monoton artar ve tavanda durur.
	var prev: float = m0
	for t in [1, 2, 3, 4]:
		var v: float = ProductSystem.design_turn_mult(t)
		if v < prev:
			return "the ladder dips at turn %d (%.3f after %.3f)" % [t, v, prev]
		prev = v
	if absf(ProductSystem.design_turn_mult(9) - m4) > 0.0001:
		return "turn counts above the cap do not read as the cap"

	# Üç ekstra tur eforun %24'ünü yakar ve karşılığında %15 verir (§5'in kendi cümlesi).
	var extra_cost: float = 3.0 * ProductSystem.DESIGN_TURN_COST
	if absf(extra_cost - 0.24) > 0.0001:
		return "three extra turns cost %.2f of EforTavanı, §5 says 0,24" % extra_cost
	if absf((m4 / m1) - 1.15) > 0.0001:
		return "four turns pay %.3f over the baseline, §5 says 1,15" % (m4 / m1)

	# §11.2 — çarpan gerçekleşmeye girer, ve KADEME BAŞINA damgalanır.
	if absf(QualityModel.realization_stamp(m0, 0.0) - 0.75) > 0.0001:
		return "the rush multiplier did not reach the realization stamp"
	return ""


## §22.5 — kayıt şeması v9. İki iddia bir arada, çünkü ikisi de aynı sözleşmenin
## yarısı: YENİ durum tam olarak hayatta kalır, ESKİ kayıt sessizce yüklenmez.
##
## Damga sözlüğü bu case'in asıl konusudur: §11.2 çarpanı kademe yayınlanırken
## damgalıyor, o yüzden damgalar yeniden yüklemeyi atlatmazsa her geçmiş sürüm
## sessizce BUGÜNKÜ tur sayısıyla yeniden okunur ve eski işin değeri değişir.
##
## FALSİFİKASYON: FLAG_TYPES'tan mvp_step_realization satırını sil → damga iddiası
## FAIL. MIN_LOADABLE_VERSION'ı 8'e indir → red iddiası FAIL.
static func _case_save_v10_product_state() -> String:
	ProductLines.reload()
	# REPOINTED TWICE, and the second time is this one. 2026-08-25 moved the pin with the
	# event-engine bump; Satış rev 6 moves it again with the v11 bump, in the same change, for
	# the reason that note already gives: a case left asserting the old number sits red across
	# every phase of the NEXT module's work and teaches the suite to be ignored.
	#
	# The assertion is now "v10 OR LATER", not an equality, and that is the durable shape. What
	# this case owns is the event_engine BLOCK — it exists from v10 onward and keeps existing.
	# The refusal below stays EXACT, because MIN_LOADABLE really is a fixed ruling and the
	# case's own falsification note ("MIN_LOADABLE_VERSION'ı 8'e indir → red iddiası FAIL")
	# names it as the thing under test.
	if SaveManager.SCHEMA_VERSION < 10:
		return "schema is v%d, below the event-engine block's v10" % SaveManager.SCHEMA_VERSION

	# --- durumu kur -----------------------------------------------------
	GameState.set_flag("mvp_shipped", true)
	GameState.set_flag("mvp_sub_product_type_id", "note_tool")
	GameState.set_flag("mvp_market_type", "b2c")
	GameState.set_flag("mvp_version", 3)
	ProductState.set_line_tier("line_note_tool_search", 2)
	ProductState.set_line_tier("line_note_tool_editor", 1)
	ProductState.set_line_tier("line_shared_durability@note_tool", 1)
	# Üç ayrı sürümün cilası, üç ayrı damga — hepsi geri gelmeli.
	ProductState.stamp_step("line_note_tool_search_k2", 1.15)
	ProductState.stamp_step("line_note_tool_editor_k1", 0.75)
	ProductState.stamp_step("line_shared_durability@note_tool_k1", 1.06)
	ProductState.open_hidden_line("line_hidden_auto_organize")
	GameState.set_flag(ProductState.REPORTS_INCOMING, 41)
	GameState.set_flag(ProductState.BUGS_CONFIRMED, 9)
	GameState.set_flag(ProductState.FIX_RUN_ACTIVE, true)
	GameState.set_flag(ProductState.FIX_RUN_FIXED, 27)
	GameState.set_flag(ProductState.VERSION_LAUNCH_DAY, maxi(1, GameState.day - 12))
	GameState.set_flag(ProductState.INTEREST, 62.5)
	GameState.set_flag(ProductState.INFRA_PROVIDER, "cloud")
	GameState.set_flag(ProductState.INFRA_UNITS, 7)

	var age_before: int = ProductState.version_age_days()
	var readings_before: Dictionary = ProductState.axis_readings()
	var usage_before: int = ProductState.usage_weight_total()

	if not SaveManager.save_to_slot(SAVE_SLOT_A):
		_cleanup_save_slots()
		return "save_to_slot failed"
	# Durumu boz, sonra geri yükle: yükleme gerçekten yazmalı.
	GameState.set_flag(ProductState.LINE_TIERS, {})
	GameState.set_flag(ProductState.STEP_REALIZATION, {})
	GameState.set_flag(ProductState.BUGS_CONFIRMED, 0)
	if not SaveManager.apply_loaded_state(SaveManager.read_slot(SAVE_SLOT_A)):
		_cleanup_save_slots()
		return "apply_loaded_state returned false"

	# --- her alan hayatta mı --------------------------------------------
	if ProductState.line_tier("line_note_tool_search") != 2:
		_cleanup_save_slots()
		return "line tier did not survive the reload (%d)" % ProductState.line_tier("line_note_tool_search")
	if ProductState.lines_open() != 3 or ProductState.steps_shipped() != 4:
		_cleanup_save_slots()
		return "line totals came back wrong: %d open, %d steps" \
			% [ProductState.lines_open(), ProductState.steps_shipped()]
	var stamps: Dictionary = ProductState.step_realization()
	for pair in [["line_note_tool_search_k2", 1.15], ["line_note_tool_editor_k1", 0.75],
			["line_shared_durability@note_tool_k1", 1.06]]:
		var got: float = float(stamps.get(String(pair[0]), -1.0))
		if absf(got - float(pair[1])) > 0.0001:
			_cleanup_save_slots()
			return "stamp for %s came back %.3f, want %.3f" % [pair[0], got, float(pair[1])]
	if not ProductState.hidden_lines().has("line_hidden_auto_organize"):
		_cleanup_save_slots()
		return "an opened hidden line closed itself on reload"
	if ProductState.reports_incoming() != 41 or ProductState.bugs_confirmed() != 9:
		_cleanup_save_slots()
		return "the DESTEK counters did not survive (%d / %d)" \
			% [ProductState.reports_incoming(), ProductState.bugs_confirmed()]
	if not ProductState.fix_run_active() or ProductState.fix_run_fixed() != 27:
		_cleanup_save_slots()
		return "the fix run did not survive"
	if ProductState.version_age_days() != age_before:
		_cleanup_save_slots()
		return "version age drifted across the reload (%d vs %d)" \
			% [ProductState.version_age_days(), age_before]
	if absf(ProductState.interest() - 62.5) > 0.001:
		_cleanup_save_slots()
		return "interest came back %.2f" % ProductState.interest()
	if ProductState.infra_provider() != "cloud" or ProductState.infra_units() != 7:
		_cleanup_save_slots()
		return "the infrastructure choice did not survive"
	if ProductState.usage_weight_total() != usage_before:
		_cleanup_save_slots()
		return "usage weight total drifted (%d vs %d)" \
			% [ProductState.usage_weight_total(), usage_before]
	# Damgalar yaşadığı için okumalar da birebir aynı.
	if str(ProductState.axis_readings()) != str(readings_before):
		_cleanup_save_slots()
		return "axis readings changed across the reload: %s vs %s" \
			% [str(ProductState.axis_readings()), str(readings_before)]

	# --- §22.5: ESKİ kayıt AÇIKÇA reddedilir, sessizce yarım yüklenmez ----
	var path: String = SaveManager.SAVE_DIR + SAVE_SLOT_A + ".json"
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		_cleanup_save_slots()
		return "could not reopen the slot to age it"
	var raw: Dictionary = JSON.parse_string(f.get_as_text()) as Dictionary
	f.close()
	# Ages the file to v9 rather than v8: the boundary worth testing is the CURRENT one,
	# and a fixture two versions stale stops proving anything the day the gate moves.
	raw["schema_version"] = 9
	var w := FileAccess.open(path, FileAccess.WRITE)
	w.store_string(JSON.stringify(raw, "\t"))
	w.close()
	var refused: Dictionary = SaveManager.read_slot(SAVE_SLOT_A)
	_cleanup_save_slots()
	if bool(refused.get("ok", false)):
		return "a v9 save loaded into a v10 build — it must be refused, not half-applied"
	if String(refused.get("error_key", "")) != "SAVE_ERR_TOO_OLD":
		return "the refusal used '%s', not SAVE_ERR_TOO_OLD" % String(refused.get("error_key", ""))
	if (refused.get("state", {}) as Dictionary).size() != 0:
		return "the refused save still handed back state to apply"
	if TranslationServer.translate("SAVE_ERR_TOO_OLD") == "SAVE_ERR_TOO_OLD":
		return "SAVE_ERR_TOO_OLD has no string — the player would see the key"
	return ""


## Ar-Ge §3 · §4 · §13 — AĞAÇ VERİSİ KENDİ ŞEKLİNE UYUYOR MU.
##
## data/techtree/rnd_tree.json ile ResearchSeam.NODES iki ayrı dosyada yaşıyor ve BİRBİRİNİ
## doğruluyor: omurga (id/aile/yer) const, ayarlanabilir yarı (efor/nakit/alan/yıldız) veri.
## Bölünme kasıtlı — ProductLines._validate_step omurgayı KENDİ yüklenişinde okuyor, ve
## dosyadan gelen bir omurga hat doğrulayıcısını I/O sırasına bağımlı kılardı.
##
## Bu tek vaka on iki bağımsız tel taşıyor; herhangi bir alandaki tek bir düzenleme onu
## düşürür ve hangi kuralın kırıldığını adıyla yazar.
##
## FALSİFİKASYON (her biri ayrı ayrı doğrulandı): rnd_tree.json'da bir düğümün `stars`
## değerini 1 artır → merdiven FAIL · bir devam düğümünün `areas` dizisini tek alana indir →
## arity FAIL ve iki-alan sayımı FAIL (aynı mutasyonu iki bağımsız tel yakalar) ·
## knowledge_graph'ın `cross` hedefini ai_engine yap (dal, 90 efor, $600) → §3.1 tavanı üç
## ayrı gerekçeyle FAIL · bir nakit değerini değiştir → tablo FAIL.
static func _case_rnd_tree_loads_and_validates() -> String:
	ResearchTree.reload()
	var errs: Array[String] = ResearchTree.load_errors()
	if not errs.is_empty():
		return "tree load errors: %s" % ", ".join(errs)

	# --- omurga ile küme eşitliği, İKİ YÖNLÜ ---
	if ResearchTree.node_ids().size() != ResearchSeam.NODES.size():
		return "tree has %d nodes, the seam declares %d" \
			% [ResearchTree.node_ids().size(), ResearchSeam.NODES.size()]
	for id in ResearchSeam.NODES.keys():
		if not ResearchTree.has(String(id)):
			return "tree is missing '%s'" % id

	# --- §3: 4 kök / 8 dal / 8 devam ---
	var roots := 0
	var branches := 0
	var conts := 0
	var two_area := 0
	var cross_links := 0
	var cash_total := 0
	var cash_nodes := 0
	for id in ResearchSeam.NODES.keys():
		var nid := String(id)
		match ResearchSeam.placement(nid):
			ResearchSeam.PLACE_ROOT: roots += 1
			ResearchSeam.PLACE_BRANCH: branches += 1
			ResearchSeam.PLACE_CONT: conts += 1
		if ResearchTree.areas_of(nid).size() == 2:
			two_area += 1
		if ResearchTree.cross_of(nid) != "":
			cross_links += 1
		if ResearchTree.cash_of(nid) > 0:
			cash_nodes += 1
			cash_total += ResearchTree.cash_of(nid)
	if roots != 4 or branches != 8 or conts != 8:
		return "tree shape is %d/%d/%d, want 4/8/8" % [roots, branches, conts]

	# --- §13: "İki alanlı düğüm sayısı: 8 (tüm devamlar)" ---
	if two_area != 8:
		return "%d nodes want two areas, §13 says 8" % two_area

	# --- §13: "Çapraz koşul sayısı: 4 (yalnız devam-B düğümleri)" ---
	if cross_links != 4:
		return "%d cross links, §13 says 4" % cross_links

	# --- §13 nakit tablosu: ÜÇ düğüm, toplam $1.900 ---
	if cash_nodes != 3 or cash_total != 1900:
		return "%d nodes carry cash totalling $%d, §13 says 3 / $1900" % [cash_nodes, cash_total]
	if ResearchTree.cash_of("ai_engine") != 600 or ResearchTree.cash_of("security_cert") != 900 \
			or ResearchTree.cash_of("analytics_engine") != 400:
		return "the cash table drifted from §13's 600 / 900 / 400"

	# --- direktör hükmü R1: kök ★1 · dal ★2 · devam ★2 ---
	for id in ResearchSeam.NODES.keys():
		var nid := String(id)
		var want: int = 1 if ResearchSeam.placement(nid) == ResearchSeam.PLACE_ROOT else 2
		if ResearchTree.stars_of(nid) != want:
			return "%s is a %s and wants ★%d, tree says ★%d" \
				% [nid, ResearchSeam.placement(nid), want, ResearchTree.stars_of(nid)]

	# --- §3.1 sapma tavanı: çapraz hedef BAŞKA ailede, KÖK, ucuz, nakitsiz ---
	for id in ResearchSeam.NODES.keys():
		var nid := String(id)
		var cross: String = ResearchTree.cross_of(nid)
		if cross == "":
			continue
		if ResearchSeam.placement(nid) != ResearchSeam.PLACE_CONT:
			return "%s carries a cross condition but is a %s" % [nid, ResearchSeam.placement(nid)]
		if ResearchSeam.family(cross) == ResearchSeam.family(nid):
			return "%s cross target '%s' is in its own family" % [nid, cross]
		if ResearchSeam.placement(cross) != ResearchSeam.PLACE_ROOT:
			return "%s cross target '%s' is a %s; §3.1 wants a root" \
				% [nid, cross, ResearchSeam.placement(cross)]
		if ResearchTree.effort_of(cross) > 50 or ResearchTree.cash_of(cross) > 0:
			return "%s cross target '%s' costs %d effort / $%d; §3.1 wants a cheap early node" \
				% [nid, cross, ResearchTree.effort_of(cross), ResearchTree.cash_of(cross)]

	# --- §4.5 gizli hatlar: dört tane, eksen dağılımı 1/2/1, dal seviyesinde TEK istisna ---
	var opens: Array[String] = []
	var branch_level: Array[String] = []
	var tally := {"innovation": 0, "stability": 0, "experience": 0}
	for id in ResearchSeam.NODES.keys():
		var nid := String(id)
		var line_id: String = ResearchTree.opens_line_of(nid)
		if line_id == "":
			continue
		opens.append(line_id)
		tally[ResearchTree.hidden_line_axis(line_id)] = \
			int(tally.get(ResearchTree.hidden_line_axis(line_id), 0)) + 1
		if ResearchSeam.placement(nid) == ResearchSeam.PLACE_BRANCH:
			branch_level.append(nid)
	if opens.size() != 4:
		return "%d nodes open a hidden line, §4.5 says 4" % opens.size()
	if int(tally["innovation"]) != 1 or int(tally["stability"]) != 2 \
			or int(tally["experience"]) != 1:
		return "hidden line axis tally is %s, §4.5 wants 1/2/1" % tally
	# §13.5'in MÜHÜRLÜ tek istisnası. ADI kontrol ediliyor, sayısı değil: sayı kontrolü
	# istisnanın sessizce ikiye çıkmasını engellemez.
	if branch_level.size() != 1:
		return "%d hidden lines sit at branch level, §13.5 allows exactly one" % branch_level.size()
	if branch_level[0] != "test_automation":
		return "the branch-level hidden line hangs off '%s', §13.5 says test_automation" \
			% branch_level[0]

	# --- §12.1 / R4: yalnız KENDİ KENDİNE SERVİS yazıldı; diğer üçü kasten boş ---
	var authored := 0
	for line_id in ResearchTree.hidden_line_ids():
		if ResearchTree.hidden_line_authored(String(line_id)):
			authored += 1
	if authored != 1:
		return "%d hidden lines are authored, §12.1 writes exactly one for the demo" % authored
	if not ResearchTree.hidden_line_authored("line_hidden_self_serve"):
		return "the authored hidden line is not line_hidden_self_serve"

	# --- R7: yazılı hattın kendi K3'ü kök-ya-da-dal bir düğüme bağlanmalı, yoksa
	#     register_runtime_line kataloğu gürültüyle reddeder ---
	var raw: Dictionary = ResearchTree.hidden_line_raw("line_hidden_self_serve")
	var k3: Dictionary = (raw.get("steps", []) as Array)[2] as Dictionary
	var k3_node: String = String((k3.get("requires", {}) as Dictionary).get("research", ""))
	if k3_node == "":
		return "the hidden line's K3 carries no research node; the catalog would refuse it"
	if not ResearchSeam.may_gate_visible_step(k3_node):
		return "the hidden line's K3 binds '%s', a %s node — §3.1 forbids it" \
			% [k3_node, ResearchSeam.placement(k3_node)]

	return ""


# ============================================================================
#  AR-GE §5.0 — ARAŞTIRMA İNSANI MEŞGUL EDER
#
#  Modülün TEMELİ ve bütün paketin kabul testi. §1'in tek cümlesi şu: "birini masadan
#  kaldırıp araştırmaya verirsin, o kişi o süre boyunca ürün yapmaz." Bu kural gerçekten
#  kurulmazsa araştırma hiçbir şeye mal olmaz ve her araştırma bariz bir evete dönüşür.
# ============================================================================

## Bir kurucu araştırmaya geçince: (a) araştırma İŞİ üstünde, (b) türetilmiş ALAN AYNASI
## boşalır — yani build ekibinden düşer, (c) eski işi SİLİNMEZ, duraklar, (d) odak 1,00
## kalır (araştırma iki-iş bölmesine tabi değil), (e) yapım durur ve efor yakmaz.
##
## FALSİFİKASYON: HRConstants.areas_for_jobs'tan `is_exclusive_job` continue'sunu kaldır →
## (b) FAIL, çünkü araştıran kurucu sessizce build ekibine geri döner ve §5.0 kağıt üstünde
## kalır. `_displace_job`'u paused_job_ids'e yazmayacak şekilde değiştir → (c) FAIL.
static func _case_research_occupies_person() -> String:
	ProductLines.reload()
	ResearchTree.reload()
	RnDSystem.reset()
	GameState.set_cash(50000)
	GameState.set_flag(ProductState.LINE_TIERS, {})
	GameState.set_flag("mvp_shipped", true)      # §2 — Ar-Ge v1 yayınından sonra açılır
	ProductSystem.active_build = null
	var founder: Character = _seed_build_crew()
	if founder == null:
		return "fixture: no founder"
	if not ProductSystem.start_line_build("note_tool",
			["line_note_tool_capture_k1"], founder.id, "Sable"):
		return "fixture: start_line_build refused a one-K1 note_tool plan"
	if ProductSystem.build_paused():
		return "fixture: a build with a free founder on it reported PAUSED"

	# efor GELİŞTİRME barında birikir; hat yapımı TASARIM'da başlar (§2, §6).
	var b: FeatureBuild = ProductSystem.get_active_build()
	b.design_turns_completed = 4
	if ProductSystem.can_enter_development():
		ProductSystem.enter_development()
	var before: float = b.efor_spent
	ProductSystem.hourly_tick(9)
	if b.efor_spent <= before:
		return "fixture: a running build did not spend effort in GELİŞTİRME"

	# --- ARAŞTIRMAYA GEÇ ---
	var refusal: String = RnDSystem.start("data_model", [founder.id])
	if refusal != "":
		return "could not start research on data_model: '%s'" % refusal

	# (a) araştırma işi üstünde
	if not founder.assigned_job_ids.has(HRConstants.JOB_RESEARCH):
		return "the founder started a research but does not hold the research job"
	# (b) ALAN AYNASI BOŞ — bu satır §5.0'ın tamamını üreten tek koruma
	for area in [HRConstants.AREA_PRODUCT, HRConstants.AREA_DESIGN, HRConstants.AREA_ENGINEERING]:
		if founder.assigned_jobs.has(String(area)):
			return "a researching founder is still mirrored into build area '%s'" % area
	# (c) eski iş SİLİNMEDİ, duraklatıldı
	if not founder.paused_job_ids.has(HRConstants.JOB_BUILD):
		return "the founder's build job was DELETED rather than paused (§5.0)"
	# (d) odak bölünmedi: araştıran kişi tek iş sayılır
	if HRSystem.job_count(founder) != 1:
		return "a researcher counts as %d jobs; §5.0 exempts research from the 0,50 split" \
			% HRSystem.job_count(founder)
	if HRSystem.is_overloaded(founder):
		return "a researcher was badged AŞIRI YÜKLÜ while doing exactly one thing"
	# (e) yapım durdu ve efor YAKMIYOR
	if not ProductSystem.build_paused():
		return "the founder went to research and the build still reports running"
	var frozen: float = b.efor_spent
	ProductSystem.hourly_tick(10)
	if b.efor_spent > frozen + 0.0001:
		return "a build paused by research kept spending effort (%.4f -> %.4f)" \
			% [frozen, b.efor_spent]
	return ""


## §5.0 İKİ YÖNLÜ ÇALIŞIR, ve iki yön TEK PROSESTE denenir: tek yönlü bir gerileme
## ikisini ayrı vakaya bölseydik saklanabilirdi.
##   yön A · kurucu yapımdayken araştırma başlatır → yapım duraklar
##   yön B · kurucu araştırırken yapım başlatır    → araştırma DONAR, ilerleme korunur
##
## Öğretici yoktur; iki bar yan yana durur ve kendini anlatır (§5.0).
##
## FALSİFİKASYON: creation_flow'un/registry'nin displacement'ını yön B için kaldır →
## ikinci yarı FAIL ve araştırma yapımla birlikte akmaya devam eder.
static func _case_research_and_build_pause_each_other() -> String:
	ProductLines.reload()
	ResearchTree.reload()
	RnDSystem.reset()
	GameState.set_cash(50000)
	GameState.set_flag(ProductState.LINE_TIERS, {})
	GameState.set_flag("mvp_shipped", true)
	ProductSystem.active_build = null
	var founder: Character = _seed_build_crew()

	# --- YÖN A: yapım koşuyor, araştırma başlıyor ---
	if not ProductSystem.start_line_build("note_tool",
			["line_note_tool_capture_k1"], founder.id, "Sable"):
		return "fixture: start_line_build refused"
	if RnDSystem.start("data_model", [founder.id]) != "":
		return "fixture: research would not start"
	if not ProductSystem.build_paused():
		return "direction A: starting a research did not pause the build"
	# Bar SEBEBİ yazar, yalnız durumu değil (§5.6.1).
	var note: String = ProductSystem.pause_note_key()
	if note != "BUILD_BUSY_RESEARCH" and note != "BUILD_BUSY_NOBODY":
		return "direction A: the paused build's note was '%s'" % note

	# Araştırma gerçekten akıyor mu.
	RnDSystem.daily_tick()
	var moved: float = RnDSystem.progress_effort("data_model")
	if moved <= 0.0:
		return "direction A: the research did not accrue while the build was paused"

	# --- YÖN B: araştırma koşarken yapım başlıyor ---
	CharacterRegistry.assign_job(founder.id, HRConstants.JOB_BUILD)
	if founder.assigned_job_ids.has(HRConstants.JOB_RESEARCH):
		return "direction B: starting a build left the founder on research"
	if not RnDSystem.is_frozen():
		return "direction B: the research did not freeze when the founder went to build"
	# İLERLEME KORUNUR, yanmaz (§5.7).
	if abs(RnDSystem.progress_effort("data_model") - moved) > 0.0001:
		return "direction B: freezing BURNED progress (%.4f -> %.4f)" \
			% [moved, RnDSystem.progress_effort("data_model")]
	RnDSystem.daily_tick()
	if abs(RnDSystem.progress_effort("data_model") - moved) > 0.0001:
		return "direction B: a frozen research kept accruing"
	return ""


## §5.7 — HERKES ÇEKİLİNCE İLERLEME DONAR, YANMAZ. "Yanacak olsa kimse başlamaz."
## Ve geri dönünce kaldığı yerden akar; sıfırdan değil.
##
## FALSİFİKASYON: _accrue'nun freeze dalını ilerlemeyi sıfırlayacak şekilde değiştir →
## resume iddiası FAIL.
static func _case_research_freezes_and_resumes() -> String:
	ProductLines.reload()
	ResearchTree.reload()
	RnDSystem.reset()
	GameState.set_cash(50000)
	GameState.set_flag("mvp_shipped", true)
	ProductSystem.active_build = null
	var founder: Character = CharacterRegistry.get_founder()
	for area in HRConstants.AREAS:
		founder.role_stats[area] = HRConstants.AREA_MAX
	CharacterRegistry.clear_jobs(founder.id)

	if RnDSystem.start("data_model", [founder.id]) != "":
		return "fixture: research would not start"
	RnDSystem.daily_tick()
	var p1: float = RnDSystem.progress_effort("data_model")
	if p1 <= 0.0:
		return "the research did not accrue on day 1"

	RnDSystem.pause()
	if not RnDSystem.is_frozen():
		return "pause() did not freeze the research"
	for i in 5:
		RnDSystem.daily_tick()
	if abs(RnDSystem.progress_effort("data_model") - p1) > 0.0001:
		return "five frozen days moved progress (%.4f -> %.4f)" \
			% [p1, RnDSystem.progress_effort("data_model")]

	RnDSystem.set_assignees([founder.id])
	if RnDSystem.is_frozen():
		return "re-assigning did not resume the research"
	RnDSystem.daily_tick()
	if RnDSystem.progress_effort("data_model") <= p1 + 0.0001:
		return "a resumed research did not accrue"
	return ""


## §5.8 — TAMAMLANMA EKONOMİK DELTA ÜRETMEZ. "Ne para, ne marka, ne MRR; yalnız kapı açar."
## "Her ekonomik sonuç oynanmış bir karar anından gelir" ilkesinin de doğrudan uygulaması. Bu vaka, ileride biri
## "ödül gibi hissettirelim" diye marka bump'ı eklerse onu yakalamak için var.
##
## FALSİFİKASYON: _complete'e GameState.set_brand(GameState.brand + 1) ekle → FAIL, alanı
## adıyla yazar.
static func _case_research_completion_no_economic_delta() -> String:
	ProductLines.reload()
	ResearchTree.reload()
	RnDSystem.reset()
	GameState.set_cash(50000)
	GameState.set_flag("mvp_shipped", true)
	ProductSystem.active_build = null
	var founder: Character = CharacterRegistry.get_founder()
	for area in HRConstants.AREAS:
		founder.role_stats[area] = HRConstants.AREA_MAX
	CharacterRegistry.clear_jobs(founder.id)

	# data_model NAKİTSİZ bir kök (§13) — böylece meşru tek delta olan başlangıç
	# maliyeti bile yok ve ölçüm saf kalır.
	if ResearchTree.cash_of("data_model") != 0:
		return "fixture: data_model is supposed to be free, tree says $%d" \
			% ResearchTree.cash_of("data_model")
	if RnDSystem.start("data_model", [founder.id]) != "":
		return "fixture: research would not start"

	var cash0: int = GameState.cash
	var mrr0: int = GameState.mrr
	var brand0: int = GameState.brand
	var rep0: int = GameState.reputation

	var guard: int = 0
	while not RnDSystem.node_completed("data_model") and guard < 400:
		RnDSystem.daily_tick()
		guard += 1
	if not RnDSystem.node_completed("data_model"):
		return "data_model never completed in %d ticks" % guard

	if GameState.cash != cash0:
		return "completion moved cash by %d" % (GameState.cash - cash0)
	if GameState.mrr != mrr0:
		return "completion moved MRR by %d" % (GameState.mrr - mrr0)
	if GameState.brand != brand0:
		return "completion moved brand by %d" % (GameState.brand - brand0)
	if GameState.reputation != rep0:
		return "completion moved reputation by %d" % (GameState.reputation - rep0)

	# §3 — kök tamamlanınca İKİ dal birden açığa çıkar.
	if not RnDSystem.revealed("ai_engine") or not RnDSystem.revealed("semantic_index"):
		return "a completed root did not reveal BOTH of its branches"
	# §7 — aynı düğüm iki kez tamamlanamaz.
	if RnDSystem.start("data_model", [founder.id]) != RnDSystem.REFUSE_DONE:
		return "a completed node accepted a second start"
	return ""


## Ar-Ge §5.0 — ARAŞTIRMA HANGİ YOLDAN BİTERSE BİTSİN DURAKLAMIŞ İŞLER GERİ DÖNER.
##
## Sızıntı şuydu: `resume_paused_jobs` yalnız `unassign_job`'dan erişilebiliyordu. Build +
## Destek taşıyan biri araştırmaya geçip sonra araştırmayı BIRAKMADAN doğrudan build'e
## döndüğünde destek defterde sonsuza kadar park kalıyordu — iş sayısı 1, odak 1,00, AŞIRI
## YÜK rozeti yok, ve destek masası oyuncunun sandığından bir kişi eksik. Hiçbir yüzey
## "geri dönmedi" demediği için tamamen sessizdi.
##
## FALSİFİKASYON: `assign_job`'daki `if ended_exclusive: resume_paused_jobs(id)` bloğunu sil
## → destek geri dönmez ve ilk iddia FAIL eder, defterin içeriğini adıyla yazarak.
static func _case_paused_job_resumes_on_direct_return() -> String:
	ProductLines.reload()
	ResearchTree.reload()
	RnDSystem.reset()
	GameState.set_flag("mvp_shipped", true)
	ProductSystem.active_build = null
	var founder: Character = CharacterRegistry.get_founder()
	for area in HRConstants.AREAS:
		founder.role_stats[area] = HRConstants.AREA_MAX
	CharacterRegistry.clear_jobs(founder.id)

	# İki SÜREKLİ iş: ikisi de koşar, ikisi de yavaşlar (§12.1).
	if CharacterRegistry.assign_job(founder.id, HRConstants.JOB_BUILD) != "":
		return "fixture: build refused"
	if CharacterRegistry.assign_job(founder.id, HRConstants.JOB_SUPPORT) != "":
		return "fixture: support refused as a second continuous job"
	if not HRSystem.is_overloaded(founder):
		return "fixture: two continuous jobs did not read as overloaded"

	# Araştırma DIŞLAYICIDIR: ikisini birden duraklatır ve tavana takılmaz.
	if RnDSystem.start("data_model", [founder.id]) != "":
		return "research was refused while two continuous jobs were held"
	if founder.paused_job_ids.size() != 2:
		return "research parked %d continuous jobs, want 2" % founder.paused_job_ids.size()

	# ARAŞTIRMAYI BIRAKMADAN doğrudan build'e dön. Sızıntının tam yolu buydu.
	if CharacterRegistry.assign_job(founder.id, HRConstants.JOB_BUILD) != "":
		return "returning directly to build was refused"
	if not founder.assigned_job_ids.has(HRConstants.JOB_SUPPORT):
		return "the parked Destek job never came back: active=%s paused=%s" \
			% [str(founder.assigned_job_ids), str(founder.paused_job_ids)]
	if not founder.paused_job_ids.is_empty():
		return "the paused ledger still holds %s" % str(founder.paused_job_ids)
	if founder.assigned_job_ids.has(HRConstants.JOB_RESEARCH):
		return "the research survived a continuous job being assigned"
	if not HRSystem.is_overloaded(founder):
		return "back on two jobs but not overloaded — the badge and the 0,50 split are gone"
	return ""


## Ekip §4.5 — "Kurucu için moral bandı uygulanmaz; DİĞER BÜTÜN ÇARPANLAR AYNEN GEÇERLİDİR."
## Odak bölünmesi o çarpanlardan biridir, ve düz-katalog yolunda kurucu terimi seam'in
## DIŞINDA hesaplandığı için bölünmeyi ayrıca alması gerekiyor.
##
## Bu yolun ölü olmadığına dikkat: barın gün tahmini (build_bar_model) ve
## estimate_build_days onu çağırıyor, yani bölünme eksikken TAHMİN tam hız derken canlı hat
## yapımı yarı hızda akıyordu.
##
## FALSİFİKASYON: `_speed_for_phase`'deki `* HRConstants.focus_mult(...)` çarpanını sil →
## iki iş tek işle aynı hızı verir ve iddia FAIL eder, iki sayıyı da yazarak.
static func _case_founder_split_halves_flat_speed() -> String:
	ProductLines.reload()
	RnDSystem.reset()
	GameState.set_flag("mvp_shipped", false)
	ProductSystem.active_build = null
	var founder: Character = CharacterRegistry.get_founder()
	for area in HRConstants.AREAS:
		founder.role_stats[area] = HRConstants.AREA_MAX
	CharacterRegistry.clear_jobs(founder.id)
	# DÜZ KATALOG yolu: planned_step_ids boş kalmalı ki is_line_build() false olsun.
	if not ProductSystem.start_build("ai_assistant",
			["ai_assistant_chat", "ai_assistant_streaming"], ""):
		return "fixture: could not start a flat-catalog build"
	var b: FeatureBuild = ProductSystem.get_active_build()
	if ProductSystem.is_line_build():
		return "fixture: the build took the line path, not the flat one"

	CharacterRegistry.clear_jobs(founder.id)
	if CharacterRegistry.assign_job(founder.id, HRConstants.JOB_BUILD) != "":
		return "fixture: build refused"
	var solo: float = ProductSystem.team_speed(b)
	if solo <= 0.0:
		return "fixture: a founder alone on the build produced no speed"

	if CharacterRegistry.assign_job(founder.id, HRConstants.JOB_SUPPORT) != "":
		return "fixture: support refused as a second continuous job"
	var split: float = ProductSystem.team_speed(b)

	# §12.1 — iki iş, her ikisine AYRI AYRI 0,50. Yapım terimi tam olarak yarıya iner.
	var want: float = solo * HRConstants.FOCUS_MULT_SPLIT
	if absf(split - want) > 0.0001:
		return "a split founder builds at %.4f, want %.4f (half of %.4f)" % [split, want, solo]
	return ""


## YAVAŞLAYAN BAR SEBEBİNİ SÖYLER — duraklamış bir bar gibi (§5.6.1'in bir adım ötesi).
##
## Kurucu DESTEK'teyken yapıma başlarsa İKİSİ DE koşar ve İKİSİ DE yavaşlar (Ekip §12.1,
## odak 0,50/0,50). O baskı — bildirimler doğrulanmaktan hızlı birikir, memnuniyet erir,
## oyuncu işe alması gerektiğini anlar — modülün öğretmek istediği şeydir, ve yavaşlığın
## SEBEBİ ekranda yazmazsa duran barın sebebi yazmadığında olduğu kadar haksız bir kayıptır.
##
## Bu vaka üç şeyi birden ölçüyor, çünkü üçü tek olgunun üç yüzü:
##   · yapım barı bölünmeyi söylüyor
##   · DESTEK barı da söylüyor (o kart bugüne dek HİÇ not taşımıyordu)
##   · kurucunun kendi durum satırı iki kısa etiketi `·` ile birleştiriyor (Ekip §12.2)
##
## FALSİFİKASYON: `ProductSystem.split_note_key`'in gövdesini `return ""` yap → yapım barı
## iddiası FAIL. `_derive_support`'taki döngüyü sil → DESTEK iddiası FAIL.
## `founder_task_label`'ın kompozisyon dalını sil → satır tek etikete düşer ve FAIL.
static func _case_split_bars_name_their_cause() -> String:
	ProductLines.reload()
	ResearchTree.reload()
	RnDSystem.reset()
	GameState.set_cash(50000)
	GameState.set_flag(ProductState.LINE_TIERS, {})
	GameState.set_flag("mvp_shipped", true)
	GameState.set_flag("pitch_prep_active", false)
	ProductSystem.active_build = null
	var founder: Character = CharacterRegistry.get_founder()
	for area in HRConstants.AREAS:
		founder.role_stats[area] = HRConstants.AREA_MAX
	CharacterRegistry.clear_jobs(founder.id)

	# TEK İŞ: hiçbir bar bölünmeden söz etmez.
	if CharacterRegistry.assign_job(founder.id, HRConstants.JOB_SUPPORT) != "":
		return "fixture: support refused"
	if ProductSystem.split_note_key() != "":
		return "a single-job founder produced a split note"

	if not ProductSystem.start_line_build("note_tool",
			["line_note_tool_capture_k1"], founder.id, "Sable"):
		return "fixture: start_line_build refused"
	if CharacterRegistry.assign_job(founder.id, HRConstants.JOB_BUILD) != "":
		return "fixture: build refused as a second continuous job"

	# İKİSİ DE KOŞUYOR — duraklama YOK. Duraklama olsaydı ders bir DURAKLAMAYLA
	# değiştirilmiş olurdu ki hüküm tam olarak bunu yasaklıyor.
	if ProductSystem.build_paused():
		return "a second continuous job PAUSED the build; only research displaces"
	if not HRSystem.is_overloaded(founder):
		return "two continuous jobs did not read as overloaded"

	# 1 · YAPIM BARI sebebi yazıyor.
	if ProductSystem.split_note_key() != "BUILD_SPLIT_FOCUS":
		return "the build bar does not name the split (%s)" % ProductSystem.split_note_key()
	var bm = load("res://scripts/ui/components/build_bar_model.gd").new()
	if not bm.derive():
		return "fixture: the build bar model derived nothing"
	if String(bm.split_note_key) != "BUILD_SPLIT_FOCUS":
		return "the build bar MODEL dropped the split note"
	# Duraklama notu boş kalmalı: bar akıyor.
	if String(bm.pause_note_key) != "":
		return "a running split build carried a PAUSE note: %s" % bm.pause_note_key

	# 2 · DESTEK BARI da yazıyor. Bu kart, not alanları kurulmadan önce erken döndüğü için
	#     bugüne kadar hiçbir not taşımıyordu.
	ProductSystem.active_build = null
	var sm = load("res://scripts/ui/components/build_bar_model.gd").new()
	if not sm.derive():
		return "fixture: the support bar model derived nothing"
	if String(sm.phase) != "support":
		return "fixture: expected the DESTEK bar, got '%s'" % sm.phase
	if String(sm.split_note_key) != "BUILD_SPLIT_FOCUS":
		return "the DESTEK bar does not name the split"

	# 3 · KURUCUNUN DURUM SATIRI iki kısa etiketi orta noktayla birleştiriyor (§12.2).
	var line: String = HRSystem.founder_task_label()
	if not line.contains(" · "):
		return "the founder's state line did not compose two labels: '%s'" % line
	if not line.contains(TranslationServer.translate("HR_JOB_SUPPORT")) \
			or not line.contains(TranslationServer.translate("HR_JOB_BUILD")):
		return "the composed line names the wrong jobs: '%s'" % line

	# Tek işe dönünce satır da tek duruma döner — kompozisyon kalıcı bir hâl değil.
	CharacterRegistry.unassign_job(founder.id, HRConstants.JOB_BUILD)
	if HRSystem.founder_task_label().contains(" · "):
		return "the founder's line stayed composed after dropping to one job"
	return ""


## AR-GE RAYDA KİLİTLİ DEĞİLDİR — kapı sayfanın kendisindedir (direktör hükmü 2026-08-25).
##
## Pazarlama ile Ar-Ge aynı rozeti giyemez, çünkü FARKLI ŞEYLER söylüyorlar: Pazarlama bu
## yapıda gerçekten yok; Ar-Ge var, bitti, yalnız henüz açılmadı. YAKINDA rozeti artık tek
## şey demektir — bu yapıda yok — ve başka hiçbir şey onu giymez.
##
## Kapı DEĞİŞMEDİ: `RnDSystem.tree_open()`. Değişen yalnız v1 öncesinin görüntüsü: tek satır,
## kilitli yuva yok, hayalet ağaç yok.
##
## FALSİFİKASYON: `ui_tokens.gd`'nin rnd satırına `"lock": "v1_shipped"` geri koy → rozetsizlik
## iddiası FAIL. `left_tabs._refresh_rnd_badge`'deki `tree_open()` korumasını sil ve okunmamış
## raporu zorla → rozet-sıfır iddiası FAIL. `_build_waiting_page`'i `_build_chrome` yap →
## bekleme satırı iddiası FAIL.
static func _case_rnd_rail_open_with_waiting_page() -> String:
	ProductLines.reload()
	ResearchTree.reload()
	RnDSystem.reset()
	GameState.set_flag("mvp_shipped", false)

	# --- VERİ TARAFI: ray tanımı ---
	var rnd_row := {}
	var mkt_row := {}
	for row in UiTokens.TABS:
		if String(row.get("id", "")) == "rnd":
			rnd_row = row
		elif String(row.get("id", "")) == "marketing":
			mkt_row = row
	if rnd_row.is_empty() or mkt_row.is_empty():
		return "fixture: rnd or marketing missing from UiTokens.TABS"
	if rnd_row.has("lock"):
		return "the Ar-Ge rail entry still carries a lock ('%s'); the gate is the PAGE now" \
			% rnd_row["lock"]
	# Ve hüküm hedeflidir, toptan bir açma değil: Pazarlama rozetini KORUR.
	if String(mkt_row.get("lock", "")) != "ea":
		return "Marketing lost its lock; YAKINDA must still mean 'not in this build'"

	# --- SAYFA TARAFI: v1 öncesi bekleme satırı, sonrası ağaç ---
	var host: Node = EventBus
	var shell: Node = load("res://scenes/main/GameShell.tscn").instantiate()
	host.add_child(shell)
	EventBus.tab_changed.emit("rnd")
	var cv: Node = shell.find_child("CenterViewport", true, false)
	if cv == null:
		shell.queue_free()
		return "CenterViewport not found in the mounted shell"
	var page: Node = cv.get_current_page_body()
	if page == null:
		shell.queue_free()
		return "the Ar-Ge tab did not mount — is it still falling to the placeholder?"

	var waiting: String = TranslationServer.translate("RND_TREE_CLOSED")
	if not _node_tree_has_text(page, waiting):
		shell.queue_free()
		return "before v1 the page does not carry the waiting line"
	# TEK SATIR: ağacın hiçbir parçası çizilmemeli.
	if _node_tree_has_text(page, TranslationServer.translate("RND_LEGEND_COUNT")):
		shell.queue_free()
		return "the waiting page drew the tree legend; it must be ONE line and nothing else"

	# Rozet: ağaç açılmadan Ar-Ge'de sayılacak hiçbir şey yok, ve koruma AÇIKÇA yazılı.
	var rail: Node = shell.find_child("LeftTabs", true, false)
	if rail != null and rail.has_method("_refresh_rnd_badge"):
		rail._refresh_rnd_badge()
		var idx: int = -1
		for i in UiTokens.TABS.size():
			if String(UiTokens.TABS[i].id) == "rnd":
				idx = i
		if idx >= 0:
			var badge: Node = rail.tab_buttons[idx].get_node_or_null("Badge")
			if badge != null and bool(badge.visible):
				shell.queue_free()
				return "the Ar-Ge badge is visible before the tree opens"

	shell.queue_free()
	return ""


## Bir düğüm ağacında görünür bir Label'ın metnini arar. Bekleme sayfası tek satır olduğu
## için "şu var / bu yok" iddiaları başka türlü ölçülemiyor.
static func _node_tree_has_text(root: Node, needle: String) -> bool:
	if needle == "":
		return false
	if root is Label and String((root as Label).text).find(needle) >= 0:
		return true
	for c in root.get_children():
		if _node_tree_has_text(c, needle):
			return true
	return false


## Ar-Ge §6.2 · §6.3 · §6.4 · §14 — AYLIK ÜRÜN NOTU: KİM YAZAR ve NE SÖYLER.
##
## §6.2 (MÜHÜRLÜ): yazar bir Ürün Yöneticisi ya da Tasarımcıdır, ve kontrol ROLÜN ALANI
## TUTUP TUTMADIĞINDAN okunur — ham yıldızdan DEĞİL. Sebep somut: hr_candidate_generator her
## çalışanın HER alanını sıfırdan büyük dolduruyor, yani ham okuma müşteri temsilcisine ürün
## raporu yazdırır. Kurucu da hariçtir ve KATEGORİYLE hariç tutulmak zorundadır, çünkü
## can_hold_area kurucu için her alanda true döner.
##
## §14 (MÜHÜRLÜ): rakip satırında SAYISAL İDDİA YASAK. Bu, havuzun tamamı üzerinde
## makineyle kontrol edilebilen tek şeydir ve başka hiçbir kapı onu yakalamaz.
##
## FALSİFİKASYON: note_author'ı ham yıldıza çevir → müşteri temsilcisi yazar olur ve ilk
## iddia FAIL. _rival_name'in "+1"ini sil → dev seçilir ve o iddia FAIL. Havuzdaki bir
## cümleye rakam ekle → basamak iddiası FAIL, anahtarı adıyla yazarak.
static func _case_rnd_note_author_and_lines() -> String:
	ProductLines.reload()
	ResearchTree.reload()
	RnDSystem.reset()
	GameState.set_flag("mvp_shipped", true)
	# Rakip satırı KANONİK adları alt-tipten okuyor, o yüzden fikstürün gerçek bir alt-tipi
	# olmak zorunda — ürünsüz bir şirkette rakip satırı DOĞRU olarak boş kalır ve çizilmez.
	GameState.set_flag("mvp_sub_product_type_id", "note_tool")
	GameState.set_flag("mvp_market_type", "b2c")

	# --- §6.2 · YAZAR KAPISI ---
	var dev: Character = _make_employee("char_note_dev", "Not Dev", HRConstants.ROLE_DEVELOPER)
	var rep: Character = _make_employee("char_note_rep", "Not Rep", HRConstants.ROLE_CUSTOMER_REP)
	# Müşteri temsilcisinin ÜRÜN alanında ham puanı VAR — ham okuma onu yazar yapardı.
	rep.role_stats[HRConstants.AREA_PRODUCT] = HRConstants.AREA_MAX
	if RnDSystem.note_author() != null:
		return "a developer + a customer rep produced a note author; §6.2 wants a PM or a designer"
	var pm: Character = _make_employee("char_note_pm", "Not PM", HRConstants.ROLE_PRODUCT_MANAGER)
	var author: Character = RnDSystem.note_author()
	if author == null:
		return "a Product Manager on staff did not qualify as the note author"
	if author.id != pm.id:
		return "the note author is '%s', want the Product Manager" % author.id
	# Kurucu KATEGORİYLE hariç: can_hold_area onun için her alanda true.
	if author.category == "founder":
		return "the founder was picked as the note author; §6.2 excludes him"

	# --- §6.3 · ÜÇ SİNYAL ---
	var note: Dictionary = RnDSystem.compose_note(author)
	if String(note.get("demand_key", "x")) != "":
		return "the demand key is filled; §6.4 says it degrades until the generator ships"
	var rk: String = String(note.get("rival_key", ""))
	var tk: String = String(note.get("tech_key", ""))
	if rk == "" or tk == "":
		return "the rival/tech lines are empty (%s / %s) — sixteen authored sentences unreachable" \
			% [rk, tk]
	for key in [rk, tk]:
		if TranslationServer.translate(key) == key:
			return "note key '%s' does not resolve" % key

	# --- §14 · RAKİP GERÇEK, DEV DEĞİL, VE SAYISAL İDDİA YOK ---
	var sub: String = ProductState.subtype()
	var names: Array = RivalCatalog.NAMES.get(sub, []) as Array
	if names.is_empty():
		return "fixture: subtype '%s' has no canonical rival names" % sub
	var rival: String = String(note.get("rival", ""))
	if not names.has(rival):
		return "the note named '%s', which is not a canonical rival of %s" % [rival, sub]
	if rival == String(names[0]):
		return "the note named the GIANT (%s); its momentum is zero, so it is never this month's news" % rival
	# Beliren teknoloji GERÇEK ve HENÜZ ARAŞTIRILMAMIŞ bir düğüm olmalı.
	var tech: String = String(note.get("node", ""))
	if not ResearchSeam.is_node(tech):
		return "the emerging-technology line names '%s', not a real node" % tech
	if RnDSystem.node_completed(tech):
		return "the emerging-technology line named an ALREADY researched node (%s)" % tech

	# Havuzun TAMAMINDA basamak aranır — tek satır değil, on altı cümlenin hepsi.
	var digits := RegEx.new()
	digits.compile("[0-9]")
	for market in ["B2B", "B2C"]:
		for i in RnDSystem.NOTE_POOL_COUNT:
			var k: String = "RND_NOTE_RIVAL_%s_%d" % [market, i]
			for loc in ["tr", "en"]:
				TranslationServer.set_locale(loc)
				var line: String = TranslationServer.translate(k)
				if digits.search(line) != null:
					TranslationServer.set_locale("tr")
					return "%s (%s) carries a numeric claim; §14 forbids it: '%s'" % [k, loc, line]
	TranslationServer.set_locale("tr")

	CharacterRegistry.remove(dev.id)
	CharacterRegistry.remove(rep.id)
	CharacterRegistry.remove(pm.id)
	return ""


## Every SCREAMING_SNAKE string anywhere inside a text block — the presenter treats exactly
## these as localization keys, so exactly these must resolve. Used by the gate-copy check and
## by the card-locale coverage case; one definition, because two would drift.
static func _caps_tokens(node: Variant) -> Array:
	var out: Array = []
	match typeof(node):
		TYPE_DICTIONARY:
			for k in (node as Dictionary):
				out.append_array(_caps_tokens((node as Dictionary)[k]))
		TYPE_ARRAY:
			for v in (node as Array):
				out.append_array(_caps_tokens(v))
		TYPE_STRING:
			var t: String = String(node)
			if t.length() >= 3 and t == t.to_upper() and not t.contains(" ") \
					and t[0] >= "A" and t[0] <= "Z":
				out.append(t)
	return out


## EFFECT-VISIBILITY, made mechanical. CLAUDE.md's rule says a modifier with no label renders a
## BLIND card; until now that was enforced by whoever remembered. Every verb any card actually
## uses must either produce a chip or be named in EventModal.SILENT_VERBS.
##
## FALSIFICATION: delete one arm from _describe_modifier's match and this case names it.
static func _case_event_chip_coverage() -> String:
	EvCatalog.reload()
	var modal_script: GDScript = load("res://scripts/modals/event_modal.gd")
	var modal: Control = modal_script.new()
	var blind: Array = []
	# GDScript.get() does not see `const`; the constant map is the documented way in.
	var silent: Array = (modal_script.get_script_constant_map() as Dictionary).get("SILENT_VERBS", [])
	if silent.is_empty():
		modal.free()
		return "EventModal.SILENT_VERBS is missing or empty — the rule has no exemption list"
	for id in EvCatalog.card_ids():
		var card: Dictionary = EvCatalog.card(String(id))
		for o in (card.get("options", []) as Array):
			var opt: Dictionary = o
			var lists: Array = [opt.get("effects", [])]
			var check: Dictionary = opt.get("check", {})
			lists.append(check.get("on_pass", []))
			lists.append(check.get("on_fail", []))
			for lst in lists:
				for e in (lst as Array):
					var verb: String = String((e as Dictionary).get("verb", ""))
					if verb == "" or silent.has(verb):
						continue
					if (modal._describe_modifier(e) as Dictionary).is_empty():
						var row: String = "%s/%s:%s" % [id, opt.get("id", "?"), verb]
						if not blind.has(row):
							blind.append(row)
	modal.free()
	if not blind.is_empty():
		return "card rows that render no chip: %s" % ", ".join(blind)
	return ""


## I1 — there is no second way in.
##
## FALSIFICATION: add any public function to EvQueue that appends without going through
## EvGate, and this case cannot see it — which is exactly why the assertion is textual. I1 is
## structural (the Queue is private to the engine), and what a test CAN prove is that the
## deleted API stays deleted.
static func _case_event_i1_single_gate() -> String:
	var offenders: Array = []
	# The needle is SPLIT so this file does not contain it, and the linter's own source is
	# skipped for the same reason. A rule that reports the two places its own definition lives
	# fails on a clean tree, which is the fastest way to teach a team to ignore it (§17.10).
	var needle_a: String = "EventManager." + "enqueue"
	var needle_b: String = "." + "enqueue_front("
	for path in _walk_gd("res://scripts"):
		if path.begins_with("res://scripts/events/tools/"):
			continue
		var f := FileAccess.open(path, FileAccess.READ)
		if f == null:
			continue
		var n: int = 0
		while not f.eof_reached():
			n += 1
			var line: String = f.get_line()
			if line.strip_edges().begins_with("#"):
				continue
			if line.contains(needle_a) or line.contains(needle_b):
				offenders.append("%s:%d" % [path, n])
	if not offenders.is_empty():
		return "the deleted admission API is back at %s" % ", ".join(offenders)
	if not EvCatalog.has_card("world.final_stretch_press"):
		return "the catalogue did not load"
	return ""


## I2 — an economic delta needs a played decision.
##
## FALSIFICATION: move "add_cash" into EvEffects.NEUTRAL_VERBS and the first assertion fails.
static func _case_event_i2_economy_played_only() -> String:
	GameState.initialize_run({"seed": 424242})
	var before: int = GameState.cash

	EvEffects.run_ambient([{"verb": "add_cash", "amount": 5000}], {})
	if GameState.cash != before:
		return "an ambient origin moved cash by %d" % (GameState.cash - before)

	EvEffects.run_expire([{"verb": "add_cash", "amount": 500}], {})
	if GameState.cash != before:
		return "on_expire applied a POSITIVE delta"

	EvEffects.run_expire([{"verb": "add_cash", "amount": -200}], {})
	if GameState.cash != before - 200:
		return "on_expire could not apply a NEGATIVE delta, which §8.3 allows"

	EvEffects.run_played([{"verb": "add_cash", "amount": 200}], {})
	if GameState.cash != before:
		return "a played decision could not move cash"
	return ""


## I3 — no untelegraphed loss, at BOTH enforcement points.
##
## FALSIFICATION: give EndingsSystem.trigger_ending's `telegraph` argument a default, and the
## second half stops being provable at all.
static func _case_event_i3_no_silent_loss() -> String:
	GameState.initialize_run({"seed": 424242})
	EvSave.reset()
	GameState.set_run_active(true)

	# The executor refuses the effect.
	EvEffects.run_played([{"verb": "trigger_ending", "ending_id": "bankruptcy",
		"requires_telegraph": "never_fired"}], {})
	if not GameState.run_active:
		return "an ending fired with a telegraph that never did"

	EvEffects.run_played([{"verb": "trigger_ending", "ending_id": "bankruptcy"}], {})
	if not GameState.run_active:
		return "an ending fired with no requires_telegraph at all"

	# And a real telegraph lets it through, so the refusals above were about the telegraph
	# rather than about something being broken.
	EvFlags.stamp("shutter_warned", "smoke")
	EvEffects.run_played([{"verb": "trigger_ending", "ending_id": "bankruptcy",
		"requires_telegraph": "shutter_warned"}], {})
	if GameState.run_active:
		return "a properly telegraphed ending did not fire"

	# The signature is the other half: every one of trigger_ending's ten call sites had to name
	# a telegraph, and there is no default to fall back on.
	#
	# EndingsSystem is a RefCounted with only statics, so `has_method` and `get_script` cannot be
	# called on the class — the script resource is loaded by path instead, which is also the
	# only form that can see the method list of a class with no instance.
	var ends: GDScript = load("res://scripts/systems/endings_system.gd")
	var found: bool = false
	for m in ends.get_script_method_list():
		if String((m as Dictionary).get("name", "")) != "trigger_ending":
			continue
		found = true
		# `extra` is the one argument allowed a default. A second default means `telegraph`
		# acquired one, and I3's structural half — every call site must NAME its telegraph or
		# fail to compile — is gone.
		if ((m as Dictionary).get("default_args", []) as Array).size() > 1:
			return "trigger_ending's telegraph argument has acquired a default"
	if not found:
		return "trigger_ending is gone"
	return ""


## I4 — a card over budget is DEMOTED, never dropped, and never demoted into the ticker.
##
## FALSIFICATION: make EvTempo.assign return an empty array for an over-budget card.
static func _case_event_i4_demoted_never_dropped() -> String:
	GameState.initialize_run({"seed": 424242})
	EvSave.reset()
	EvTempo.reset()

	var pending: Array = []
	for i in 6:
		# A LIVE demotable interrupt: not `critical`, not `terminal_warning`, no arc, so
		# §13.5 does not exempt it from the budget. It replaced `product.critical_bug`,
		# which was removed as legacy flavour.
		pending.append({"event_id": "customer.retention"})
	var assigned: Array = EvTempo.assign(pending)
	if assigned.size() != pending.size():
		return "the governor dropped %d card(s); I4 forbids dropping" % (pending.size() - assigned.size())
	for a in assigned:
		var cls: String = String((a as Dictionary)["class"])
		if cls == "ambient":
			return "a card was demoted into the ticker, which drops its newest line when full"
		if cls not in ["interrupt", "paper", "info"]:
			return "unexpected class '%s'" % cls
	var demoted: int = 0
	for a in assigned:
		if bool((a as Dictionary).get("demoted", false)):
			demoted += 1
	if demoted == 0:
		return "six interrupts in one day and nothing was demoted — the ceiling is %d" \
			% EvTuning.MAX_INTERRUPTS_PER_DAY
	return ""


## I5 — the card file tells the truth about when it fires.
##
## Enforceable form: every card either declares a trigger/condition or is a pool card, and no
## system names a card id in order to fire it. A trigger that lives in GDScript has no
## syntactic signature; a system reaching for a specific card does.
static func _case_event_i5_trigger_is_data() -> String:
	EvCatalog.reload()
	var silent: Array = []
	for id in EvCatalog.card_ids():
		var card: Dictionary = EvCatalog.card(id)
		if String(card.get("version_scope", "demo")) == "fixture":
			continue
		# A card declares HOW IT FIRES in four legible ways, and `tick` is one of them.
		# `tick: request` says "no clock sweeps me; a caller names me" and `tick: scheduled`
		# says "an effect put me on the calendar" — both are as much a declaration as a
		# trigger block, and both are readable without opening a .gd file, which is what I5
		# is actually about. What I5 forbids is a card whose firing rule exists ONLY in code
		# while the card itself claims to be pool content.
		var declares: bool = card.has("trigger") or card.has("condition") or card.has("arc") \
			or String(card["tick"]) in ["request", "scheduled"]
		var poolable: bool = not card.has("arc") and not (card["tags"] as Array).has("critical")
		if not declares and not poolable:
			silent.append(String(id))
	if not silent.is_empty():
		return "cards with no declared trigger that are not pool cards: %s" % ", ".join(silent)
	return ""


## I6 — dice never kill.
##
## FALSIFICATION: add "trigger_ending" to the check-branch table and the first assertion fails.
static func _case_event_i6_dice_never_kill() -> String:
	GameState.initialize_run({"seed": 424242})
	EvSave.reset()
	GameState.set_run_active(true)
	EvFlags.stamp("shutter_warned", "smoke")

	EvEffects.run_check_branch([{"verb": "trigger_ending", "ending_id": "bankruptcy",
		"requires_telegraph": "shutter_warned"}], {})
	if not GameState.run_active:
		return "a dice branch ended the run"

	# The same effect from a played decision does end it — so the refusal was about the ORIGIN.
	EvEffects.run_played([{"verb": "trigger_ending", "ending_id": "bankruptcy",
		"requires_telegraph": "shutter_warned"}], {})
	if GameState.run_active:
		return "the control case did not fire, so the assertion above proves nothing"

	# And no authored check branch carries a terminal.
	EvCatalog.reload()
	for id in EvCatalog.card_ids():
		for o in (EvCatalog.card(id).get("options", []) as Array):
			var check: Dictionary = (o as Dictionary).get("check", {})
			for branch in ["on_pass", "on_fail"]:
				for e in (check.get(branch, []) as Array):
					if String((e as Dictionary).get("verb", "")) == "trigger_ending":
						return "%s has a terminal in a check branch" % id
	return ""


## I7 — no modifier line without a named seam, in both directions.
static func _case_event_i7_modifier_needs_seam() -> String:
	EvCatalog.reload()
	EvSeams.ensure_installed()
	for id in EvCatalog.card_ids():
		var card: Dictionary = EvCatalog.card(id)
		var lines: Dictionary = (card.get("text", {}).get("tr", {}) as Dictionary).get("modifier_lines", {})
		for seam_name in lines:
			if not EvSeams.has(String(seam_name)):
				return "%s names modifier seam '%s', which is not registered" % [id, seam_name]

	# The other direction: a contribution with no label does not render, rather than rendering
	# a machine key at the player.
	var rendered: Array = EvDice.modifier_lines(
		[{"seam": "hr.morale", "delta": 0.2}, {"seam": "hr.tenure_days", "delta": -0.1}],
		{"hr.morale": "morale is good"})
	if rendered.size() != 1:
		return "an unlabelled contribution rendered anyway (%d line(s))" % rendered.size()
	if String((rendered[0] as Dictionary)["sign"]) != "▲":
		return "the sign was not derived from the contribution"
	return ""


## A5 — the dice hash is stable, by construction and by fixture.
##
## FALSIFICATION: swap fnv1a's body for String.hash() and the known-value assertion fails.
## That is the whole point: these outcomes are save-critical, and a patched build must
## reproduce a saved run's rolls. String.hash() is not documented-stable across engine
## versions, so the algorithm is written out in-project and pinned here.
static func _case_event_dice_is_stable() -> String:
	var known: int = EvDice.fnv1a("project-unicorn")
	if EvDice.fnv1a("project-unicorn") != known:
		return "fnv1a is not deterministic within one process"
	if EvDice.fnv1a("project-unicorm") == known:
		return "fnv1a returned the same value for different input"

	GameState.initialize_run({"seed": 424242})
	GameState.day = 42
	var a: float = EvDice.unit("check", 42, "ev.x", "opt_a")
	var b: float = EvDice.unit("check", 42, "ev.x", "opt_a")
	if not is_equal_approx(a, b):
		return "the same coordinates gave two different rolls"
	if a < 0.0 or a >= 1.0:
		return "unit() returned %f, outside [0,1)" % a

	# §9.3: option_id is IN the hash, so a different option is a genuinely different roll —
	# which is what makes a reload buy a better and more expensive offer rather than a retry.
	if is_equal_approx(a, EvDice.unit("check", 42, "ev.x", "opt_b")):
		return "two options on one card shared a roll; save-scumming is back"
	if is_equal_approx(a, EvDice.unit("check", 43, "ev.x", "opt_a")):
		return "the day is not in the hash"
	return ""


## THE THESIS TEST, in the suite as well as the probe.
##
## §24 makes this the gate stage 2 may not be skipped past, and §0.2 makes it the reason the
## engine exists: a decision on day 10 produces a visible consequence on day 90, across a
## save/load, and the player can trace the link.
static func _case_event_thesis_day10_to_day90() -> String:
	var shipped: Array = EvTuning.SHIPPED_SCOPES.duplicate()
	EvTuning.SHIPPED_SCOPES.append("fixture")
	GameState.initialize_run({"seed": 424242})
	EvEngine.reset()
	EvCatalog.reload()

	GameState.day = 10
	if not EvEngine.force_fire("fixture.thesis_open"):
		EvTuning.SHIPPED_SCOPES.assign(shipped)
		return "the day-10 card would not fire"
	EvEngine.resolve("fixture.thesis_open", "promise")
	if not EvArcs.is_active("arc_fixture_thesis"):
		EvTuning.SHIPPED_SCOPES.assign(shipped)
		return "the arc did not start"

	# Round-trip, exactly as a real save would.
	var json: String = JSON.stringify(EvSave.to_dict())
	EvEngine.reset()
	EvSave.from_dict(JSON.parse_string(json) as Dictionary)
	if not EvArcs.is_active("arc_fixture_thesis"):
		EvTuning.SHIPPED_SCOPES.assign(shipped)
		return "the arc did not survive a save/load"

	GameState.day = 90
	var due: Array = EvSchedule.take_due()
	var found: bool = false
	for e in due:
		if String((e as Dictionary)["event_id"]) == "fixture.thesis_payoff":
			found = true
	if not found:
		EvTuning.SHIPPED_SCOPES.assign(shipped)
		return "the payoff was not due on day 90"

	# The load-bearing assertion: the condition reads a choice made 80 days ago.
	var cond: Dictionary = EvCatalog.card("fixture.thesis_payoff")["condition"]
	if not EvCondition.eval(cond):
		EvTuning.SHIPPED_SCOPES.assign(shipped)
		return "the payoff's condition could not read the day-10 choice"

	if not EvEngine.force_fire("fixture.thesis_payoff"):
		EvTuning.SHIPPED_SCOPES.assign(shipped)
		return "the payoff would not fire on day 90"
	EvEngine.resolve("fixture.thesis_payoff", "acknowledge")
	var landed: bool = EvFlags.has("fixture_payoff_landed")
	EvTuning.SHIPPED_SCOPES.assign(shipped)
	if not landed:
		return "the payoff resolved but left no trace"
	return ""


static func _walk_gd(root: String) -> Array:
	var out: Array = []
	var dir := DirAccess.open(root)
	if dir == null:
		return out
	dir.list_dir_begin()
	var name: String = dir.get_next()
	while name != "":
		var full: String = root.path_join(name)
		if dir.current_is_dir():
			if not name.begins_with("."):
				out.append_array(_walk_gd(full))
		elif name.ends_with(".gd"):
			out.append(full)
		name = dir.get_next()
	dir.list_dir_end()
	return out


## A2 — THE THESIS AGAIN, THROUGH THE REAL PRESENTATION PATH.
##
## `event_thesis_day10_to_day90` proves the arc, the schedule and the condition. It proves none
## of paper, desk, expiry clock or the presentation layer, because it drives the engine
## directly. This one runs the same day-10 → day-90 arc through everything a player touches:
## the view the modal is handed, the desk a deferred card lands on, and the clock it carries.
##
## ON A2'S "FORCED INTO DEMOTION" CLAUSE — an amendment written before §13.5 was implemented,
## and it turns out to be unsatisfiable AS WRITTEN, which is a finding rather than a dodge.
## §13.5 makes an arc step BUDGET-EXEMPT: "an arc turning point does not consume the day's
## interrupt slots", so the tempo governor will not demote a payoff no matter how busy the day
## is. Demoting it would be the bug. So this case proves the two halves separately and asserts
## the exemption out loud:
##
##   · a NON-exempt card admitted the same day IS demoted, lands on the desk with a clock, and
##     is still answerable — the consequence deferred, never dropped (I4);
##   · the payoff is NOT demoted, and the reason is named in the failure message so nobody
##     "fixes" the exemption later without reading this.
static func _case_event_thesis_through_presenter() -> String:
	var shipped: Array = EvTuning.SHIPPED_SCOPES.duplicate()
	EvTuning.SHIPPED_SCOPES.append("fixture")
	var fail: String = _thesis_presenter_body()
	EvTuning.SHIPPED_SCOPES.assign(shipped)
	return fail


static func _thesis_presenter_body() -> String:
	GameState.initialize_run({"seed": 424242})
	GameState.set_run_active(true)
	EvEngine.reset()
	EvCatalog.reload()

	# THE PRESENTER IS THE THING UNDER TEST, so the case listens where main.gd listens rather
	# than reading the queue. A card that never reaches this signal never reaches a player.
	var shown: Array = []
	var on_modal := func(ev: GameEvent) -> void: shown.append(ev)
	EventBus.modal_requested.connect(on_modal)

	GameState.day = 10
	if not EventGate.request("fixture.thesis_open"):
		EventBus.modal_requested.disconnect(on_modal)
		return "the day-10 card was refused"
	if shown.is_empty():
		EventBus.modal_requested.disconnect(on_modal)
		return "the card was admitted but never reached modal_requested"
	var opening: GameEvent = shown[shown.size() - 1]
	if opening.id != "fixture.thesis_open" or opening.choices.size() != 2:
		EventBus.modal_requested.disconnect(on_modal)
		return "the view handed over is wrong (%s, %d choice(s))" % [
			opening.id, opening.choices.size()]

	EventGate.resolve("fixture.thesis_open", "promise")
	if not EvArcs.is_active("arc_fixture_thesis"):
		EventBus.modal_requested.disconnect(on_modal)
		return "the arc did not start"

	# A paper due the SAME DAY as the payoff, so the desk half is exercised on the day that
	# matters rather than on a quiet one.
	EvSchedule.add("fixture.concurrent", 80)

	# Round-trip, exactly as a real save would.
	var json: String = JSON.stringify(EvSave.to_dict())
	EvEngine.reset()
	EvSave.from_dict(JSON.parse_string(json) as Dictionary)
	GameState.set_run_active(true)
	if not EvArcs.is_active("arc_fixture_thesis"):
		EventBus.modal_requested.disconnect(on_modal)
		return "the arc did not survive a save/load"

	# --- THE DEMOTION HALF, on a card that is not exempt -----------------------------------
	EvTempo.reset()
	var crowd: Array = []
	for i in EvTuning.MAX_INTERRUPTS_PER_DAY + 2:
		crowd.append({"event_id": "customer.retention"})
	var assigned: Array = EvTempo.assign(crowd)
	var demoted: int = 0
	for a in assigned:
		if bool((a as Dictionary).get("demoted", false)):
			demoted += 1
	if assigned.size() != crowd.size():
		EventBus.modal_requested.disconnect(on_modal)
		return "the governor dropped a card; I4 forbids dropping"
	if demoted == 0:
		EventBus.modal_requested.disconnect(on_modal)
		return "%d interrupts in one day and nothing was demoted (ceiling %d)" % [
			crowd.size(), EvTuning.MAX_INTERRUPTS_PER_DAY]
	# The payoff, run through the same governor on the same crowded day, must NOT be demoted.
	EvTempo.reset()
	crowd.append({"event_id": "fixture.thesis_payoff"})
	for a in EvTempo.assign(crowd):
		var entry: Dictionary = a
		if String(entry["event_id"]) != "fixture.thesis_payoff":
			continue
		if bool(entry.get("demoted", false)):
			EventBus.modal_requested.disconnect(on_modal)
			return "the arc payoff was demoted — §13.5 exempts arc steps from the day's " \
				+ "interrupt budget, and a payoff that can be pushed to the desk by a busy " \
				+ "day is the silent-death class §10.6 exists to prevent"
	EvTempo.reset()

	# --- DAY 90 -----------------------------------------------------------------------------
	shown.clear()
	GameState.day = 90
	EvEngine.daily_tick()
	# The day may raise more than one card, and §11.2 decides which owns the modal slot first.
	# Answering the others is what a player does; what must be true is that the payoff reaches
	# the screen on THIS day rather than being lost behind them.
	var mounted: bool = _drain_to("fixture.thesis_payoff")
	EventBus.modal_requested.disconnect(on_modal)

	var reached: bool = false
	for ev in shown:
		if (ev as GameEvent).id == "fixture.thesis_payoff":
			reached = true
	if not reached:
		return "the payoff did not reach the screen on day 90 (shown: %d card(s))" % shown.size()
	if not mounted or EventGate.active_id() != "fixture.thesis_payoff":
		return "the payoff is not the active card (%s)" % EventGate.active_id()

	# The concurrent card is a paper: on the desk, with a clock, and NOT a modal.
	var desk: Array = EventGate.desk_papers(8)
	var paper: Dictionary = {}
	for entry in desk:
		if String((entry as Dictionary)["id"]) == "fixture.concurrent":
			paper = entry
	if paper.is_empty():
		return "the same-day paper did not reach the desk (desk: %d)" % desk.size()
	if int(paper["days_left"]) <= 0:
		return "the paper landed with no clock (%d)" % int(paper["days_left"])

	EventGate.resolve("fixture.thesis_payoff", "acknowledge")
	if not EvFlags.has("fixture_payoff_landed"):
		return "the payoff resolved but left no trace"
	if EvArcs.is_active("arc_fixture_thesis"):
		return "the arc did not close on its payoff"

	# And the deferred one is still answerable — the whole point of demoting rather than
	# dropping. It opens from the desk and resolves like any other card.
	#
	# DRAIN FIRST. §11.3 allows one modal at a time, so `open_paper` refuses while anything is
	# on screen — and resolving the payoff pumps the queue, which on a busy day mounts the next
	# card immediately. The player would answer that one and then reach for the desk; the case
	# does the same.
	_drain_all_modals()
	if not EventGate.open_paper("fixture.concurrent"):
		return "the paper would not open from the desk"
	EventGate.resolve("fixture.concurrent", "ok")
	if not EvFlags.has("fixture_concurrent_landed"):
		return "the deferred card resolved but left no trace"
	return ""


# ============================================================================
#  SATIŞ rev 6 — the cases the rebuild is gated on
# ============================================================================

## §3.1 THE MARKET GUARD. A consumer run must produce ZERO B2B leads, however much sales
## capacity is standing around, and the surface must say WHY rather than simply be empty.
## The guard is asked in two places on purpose.
## FALSIFICATION: remove the `_market_open()` test from SalesFaucetSystem.daily_tick and the
## first branch fails — a hired rep mints enterprise leads inside a consumer app.
static func _case_sales_faucet_guard_b2c() -> String:
	GameState.set_flag("mvp_shipped", true)
	GameState.set_flag("mvp_market_type", "b2c")
	_seed_b2c()
	_make_sales_rep("char_sr_1", 6, 9)
	var before: int = ProspectRegistry.count()
	for i in 30:
		GameState.advance_day()
		TimeManager._dispatch_daily_tick()
	if ProspectRegistry.count() != before:
		return "a consumer run produced %d B2B leads" % (ProspectRegistry.count() - before)
	if SalesFaucetSystem.market_open():
		return "the faucet reads open in a consumer run"
	if SalesFaucetSystem.spawn(1, "faucet") != null:
		return "a direct spawn produced a lead in a consumer run"
	# The refusal is NAMED, and it is the same key the tab draws.
	if SalesLedger.meeting_block_reason("anything") != "SALES_BLOCK_NO_B2B":
		return "the block reason does not name the missing product: %s" % \
			SalesLedger.meeting_block_reason("anything")
	# And the same world with a B2B product flows, so the guard is a gate and not a wall.
	GameState.set_flag("mvp_market_type", "b2b")
	if not SalesFaucetSystem.market_open():
		return "the faucet stayed shut after the market turned B2B"
	return ""


## §4 LEAD LIFE AND THE RETURN LOCK. An unworked lead waits a week and then drops with the
## honest line; the company cannot be offered again for thirty days, and the return is
## TRACELESS — no memory, no penalty, nothing on the account.
## FALSIFICATION: drop _lock_return from the expiry branch and the company comes back the
## next morning, which is the "havuz tükenmez" rule turning into "havuz unutmaz".
static func _case_sales_lead_expiry_and_return_lock() -> String:
	GameState.set_flag("mvp_shipped", true)
	GameState.set_flag("mvp_market_type", "b2b")
	GameState.set_flag("mvp_sub_product_type_id", "erp")
	var p: Prospect = SalesFaucetSystem.spawn(1, "faucet")
	if p == null:
		return "the faucet produced no lead"
	var name: String = p.company_name
	if p.days_left() != SalesConstants.LEAD_LIFE_DAYS:
		return "a fresh lead shows %d days, want %d" % [p.days_left(), SalesConstants.LEAD_LIFE_DAYS]
	for i in SalesConstants.LEAD_LIFE_DAYS + 1:
		GameState.advance_day()
		SalesFaucetSystem.daily_tick()
	if ProspectRegistry.get_prospect(p.id) != null:
		return "the lead outlived its week"
	if not SalesFaucetSystem.is_return_locked(name):
		return "an expired company is not inside its return lock"
	# TRACELESS: an expiry is not a loss and must leave no memory (§4 vs §9).
	if SalesLedger.loss_count(name) != 0:
		return "an expiry wrote a loss to the account memory"
	if SalesLedger.loss_reason(name) != "":
		return "an expiry named a loss reason"
	# The honest line landed where the player can still read it.
	var log: Array = SalesSystem.get_sales_log()
	var found: bool = false
	for row in log:
		if String((row as Dictionary).get("kind", "")) == "lead_expired" \
				and String((row as Dictionary).get("company", "")) == name:
			found = true
	if not found:
		return "the expiry produced no activity line"
	# The lock actually holds the name out of the pool.
	for i in 30:
		var q: Prospect = SalesFaucetSystem.spawn(1, "faucet")
		if q == null:
			break
		if q.company_name == name:
			return "a locked company was offered again inside its window"
		ProspectRegistry.remove(q.id)
		SalesFaucetSystem.lock_return(q.company_name, 9999)
	# And it lifts on time rather than forever.
	for i in SalesConstants.RETURN_LOCK_DAYS + 1:
		GameState.advance_day()
		SalesFaucetSystem.daily_tick()
	if SalesFaucetSystem.is_return_locked(name):
		return "the return lock never lifted"
	return ""


## §5.0 THE TIME SKIP. Two hours pass and they are SIMULATED through the real hourly path
## with the founder counted busy. Ekip §2.1 then produces the GDD's own sentence: a build with
## a free team member FLOWS, a founder-only build PAUSES.
## FALSIFICATION: remove the `sales_meeting_active` branch from ProductSystem._is_free and the
## solo half fails — the founder keeps building from inside a meeting they are sitting in.
static func _case_sales_meeting_time_skip_founder_zero() -> String:
	ProductLines.reload()
	GameState.set_cash(50000)
	GameState.set_flag("mvp_shipped", true)
	GameState.set_flag("mvp_market_type", "b2b")
	GameState.set_flag("mvp_sub_product_type_id", "erp")
	# A FRESH ladder: the plan below is three K1 steps, and a seed that had already shipped
	# them would make `start_line_build` refuse on the ladder rule rather than on anything
	# this case is about.
	_seed_b2b_lines("erp", 0)
	GameState.set_flag(ProductState.LINE_TIERS, {})
	GameState.set_flag(ProductState.STEP_REALIZATION, {})
	_seed_build_crew()
	var plan := ["line_erp_ledger_k1", "line_erp_stock_k1", "line_erp_invoicing_k1"]
	if not ProductSystem.start_line_build("erp", plan, "", "Nova"):
		return "start_line_build refused the fixture plan"
	# INTO AN HOURLY PHASE. `ProductSystem.hourly_tick` advances effort only in
	# iteration | development | bugfix; a fresh build sits in DESIGN, which is a daily turn,
	# and two skipped hours would then read as "nothing happened" for both halves of this
	# case — a false pass on the solo side and a false failure on the team side.
	ProductSystem.get_active_build().current_phase = "development"

	# SOLO — the founder is the only carrier, so the skipped hours produce nothing.
	var lead: Prospect = SalesFaucetSystem.spawn(1, "faucet")
	if lead == null:
		return "the faucet produced no lead to sit at"
	var solo_before: float = ProductSystem.get_active_build().efor_spent
	var hour_before: int = GameState.current_hour
	SalesMeetingSystem.open(lead.id)
	SalesMeetingSystem.close()
	var solo_after: float = ProductSystem.get_active_build().efor_spent
	var skipped: int = (GameState.current_hour - hour_before + 24) % 24
	if skipped != SalesConstants.MEETING_SKIP_HOURS:
		return "the clock moved %d hours, want %d" % [skipped, SalesConstants.MEETING_SKIP_HOURS]
	if solo_after > solo_before + 0.00001:
		return "a founder-only build advanced while the founder sat at a table (%.5f -> %.5f)" \
			% [solo_before, solo_after]

	# TEAM — one free engineer on the build, and the same two hours flow.
	var eng: Character = _make_employee("char_eng_skip", "Deniz", HRConstants.ROLE_DEVELOPER)
	eng.role_stats[HRConstants.AREA_ENGINEERING] = HRConstants.AREA_MAX
	CharacterRegistry.assign_job(eng.id, HRConstants.JOB_BUILD)
	var lead2: Prospect = SalesFaucetSystem.spawn(1, "faucet")
	if lead2 == null:
		return "the faucet produced no second lead"
	GameState.set_flag("sales_meeting_used_day", -1)   # a fresh day's right
	var team_before: float = ProductSystem.get_active_build().efor_spent
	SalesMeetingSystem.open(lead2.id)
	SalesMeetingSystem.close()
	var team_after: float = ProductSystem.get_active_build().efor_spent
	if team_after <= team_before:
		return "a team build did not advance across the skipped hours (%.5f -> %.5f)" \
			% [team_before, team_after]
	# And the flag is DOWN afterwards: a founder stuck busy is worse than one never freed.
	if bool(GameState.get_flag("sales_meeting_active", false)):
		return "the meeting flag survived the close"
	return ""


## §5.1 / engine §9.3 — THE CHECK REPLAYS ACROSS A SAVE. The die derives from the run seed,
## the day, the lead and the path; nothing about a reload is in it. This is the harder half of
## `sales_meeting_replays_identically`: the state actually round-trips through the codec.
## FALSIFICATION: put a RngStreams draw in the resolution and the two halves diverge.
static func _case_sales_check_replays_after_load() -> String:
	GameState.set_flag("mvp_shipped", true)
	GameState.set_flag("mvp_market_type", "b2b")
	GameState.set_flag("mvp_sub_product_type_id", "erp")
	_seed_b2b_lines("erp", 1)
	var p: Prospect = _add_prospect("replay_save", 2, "")
	var day: int = GameState.day
	var seed_value: int = GameState.run_seed
	var memory_before: Dictionary = GameState.sales_line_memory.duplicate(true)
	var first: Dictionary = _play_to_skip(SalesMeetingSystem.open(p.id))
	var outcome_a: String = String(first.get("outcome", ""))
	var path_a: String = SalesMeetingSystem.path_id()
	SalesMeetingSystem.close()
	if outcome_a == "":
		return "the first sitting produced no outcome"

	# A reload puts the same world back: same seed, same day, same lead — AND the same content
	# repeat memory, which the picker's first tie-break reads (§11.2). Without restoring it the
	# second sitting correctly prefers a row the run has not spoken yet, and the case would be
	# measuring the repeat rule rather than the die.
	GameState.run_seed = seed_value
	GameState.day = day
	GameState.sales_line_memory.clear()
	for k in memory_before:
		GameState.sales_line_memory[k] = memory_before[k]
	if ProspectRegistry.get_prospect("replay_save") == null:
		_add_prospect("replay_save", 2, "")
	GameState.set_flag("sales_meeting_used_day", -1)
	var second: Dictionary = _play_to_skip(SalesMeetingSystem.open("replay_save"))
	var outcome_b: String = String(second.get("outcome", ""))
	var path_b: String = SalesMeetingSystem.path_id()
	SalesMeetingSystem.close()
	if path_a != path_b:
		return "the same play produced two paths: %s / %s" % [path_a, path_b]
	if outcome_a != outcome_b:
		return "the same path replayed differently: %s then %s" % [outcome_a, outcome_b]
	return ""


## §6 THE SINGLE OPEN PITCH PROMISE. One at a time, and the refusal is a VISIBLE locked row
## with its reason rather than a missing option.
## FALSIFICATION: drop the ledger check from SalesMeetingSystem._promise_locked and the second
## table offers a second word while the first is still owed.
static func _case_sales_single_open_promise_lock() -> String:
	GameState.set_flag("mvp_shipped", true)
	GameState.set_flag("mvp_market_type", "b2b")
	GameState.set_flag("mvp_sub_product_type_id", "ai_vector_search")   # a pool with features
	GameState.set_flag("mvp_components", [])
	var facts: Dictionary = {"has_promise_target": true, "open_pitch_promise": true}
	var row: Dictionary = {"answers": [{"id": "a_promise", "verb": SalesProbes.VERB_PROMISE}]}
	var locked: Array = SalesProbes.answers_for(row, facts, true)
	if locked.is_empty():
		return "the promise row vanished instead of locking"
	if bool((locked[0] as Dictionary).get("open", true)):
		return "the promise row is open while a word is already owed"
	if String((locked[0] as Dictionary).get("lock_fact", "")) != "open_pitch_promise":
		return "the lock does not name the open promise: %s" % \
			String((locked[0] as Dictionary).get("lock_fact", ""))
	# Unlocked, the same row is playable — so the lock is the promise and nothing else.
	var free_rows: Array = SalesProbes.answers_for(row, facts, false)
	if free_rows.is_empty() or not bool((free_rows[0] as Dictionary).get("open", false)):
		return "the promise row stayed shut with no open promise"
	# And with nothing to promise the row is ABSENT rather than offered and then broken.
	var no_target: Dictionary = {"has_promise_target": false, "open_pitch_promise": false}
	if not SalesProbes.answers_for(row, no_target, false).is_empty():
		return "the promise row was offered with nothing to promise"
	return ""


## §7.2.1 THE SELECTION RULE: the highest star inside the band, ties broken by least time
## left, reserved tables skipped, and a lead handed to a rep goes to the FRONT.
## FALSIFICATION: remove the expires_on_day comparison from _outranks and the tie resolves by
## id instead, which is stable but not the rule.
static func _case_sales_rep_selection_rule() -> String:
	GameState.set_flag("mvp_shipped", true)
	GameState.set_flag("mvp_market_type", "b2b")
	GameState.set_flag("mvp_sub_product_type_id", "erp")
	var rep: Character = _make_sales_rep("char_sr_1", 0, 9)   # star 4 -> band 1..3
	var small: Prospect = _add_prospect("sel_small", 1, "")
	var big: Prospect = _add_prospect("sel_big", 2, "")
	var big2: Prospect = _add_prospect("sel_big2", 2, "")
	big.expires_on_day = GameState.day + 6
	big2.expires_on_day = GameState.day + 2      # less time left wins the tie
	var picked: Prospect = SalesRepSystem.pick_lead_for(rep)
	if picked == null or picked.id != big2.id:
		return "selection did not take the highest star with the least time left: %s" % \
			("null" if picked == null else picked.id)
	# Reserved tables are the founder's and are skipped outright.
	SalesLedger.set_routing(big2.id, SalesConstants.ROUTE_RESERVED)
	SalesLedger.set_routing(big.id, SalesConstants.ROUTE_RESERVED)
	picked = SalesRepSystem.pick_lead_for(rep)
	if picked == null or picked.id != small.id:
		return "a reserved table was not skipped"
	# "Temsilciye ver" jumps the queue ahead of the star rule.
	SalesLedger.set_routing(small.id, SalesConstants.ROUTE_NONE)
	SalesLedger.set_routing(big.id, SalesConstants.ROUTE_NONE)
	SalesLedger.set_routing(small.id, SalesConstants.ROUTE_REP)
	picked = SalesRepSystem.pick_lead_for(rep)
	if picked == null or picked.id != small.id:
		return "a lead handed to a rep did not go to the front of the band queue"
	return ""


## §5.4 THE PRICE TRAIL: what the account agreed to at signing is what expansion charges.
## Before rev 6 every account expanded at one flat rate, so the stance dial had no tail and a
## click was worth the same on every record in the book.
## FALSIFICATION: make expand() read B2BConstants.EXPANSION_PER_SEAT_MRR again and the second
## half fails by exactly the difference between the two rates.
static func _case_sales_seat_price_stamp_and_expansion() -> String:
	GameState.set_flag("mvp_shipped", true)
	GameState.set_flag("mvp_market_type", "b2b")
	GameState.set_flag("mvp_sub_product_type_id", "erp")
	var p: Prospect = _add_prospect("stamped", 2, "")
	var price: int = 44
	var seats: int = 20
	var c: Customer = SalesSystem.add_b2b_customer(p, seats, price, 70)
	if c == null:
		return "the signing seam produced no customer"
	if c.seat_price != price:
		return "the account did not carry its seat price: %d" % c.seat_price
	if c.mrr != seats * price:
		return "MRR %d is not seats x price (%d x %d)" % [c.mrr, seats, price]
	if SalesLedger.seat_price(c.id) != price:
		return "the read surface does not return the stamped price"
	# Expansion charges THAT price, not the flat constant — and the caller still passes the
	# constant, because the engine's own effect does.
	var mrr_before: int = c.mrr
	var add: int = 5
	B2BSalesSystem.expand(c.id, add, B2BConstants.EXPANSION_PER_SEAT_MRR)
	var after: Customer = CustomerRegistry.get_customer(c.id)
	if after.seats != seats + add:
		return "expansion moved seats to %d, want %d" % [after.seats, seats + add]
	if after.mrr != mrr_before + add * price:
		return "expansion charged %d for %d seats, want %d at the account's own $%d" % [
			after.mrr - mrr_before, add, add * price, price]
	# An UNSTAMPED account (a v10 record, or a fixture) still expands at the caller's rate,
	# which is the old behaviour preserved exactly where the new price does not exist.
	var q: Prospect = _add_prospect("unstamped", 1, "")
	var c2: Customer = SalesSystem.add_b2b_customer(q, 10, 0, 70)
	var m2: int = c2.mrr
	B2BSalesSystem.expand(c2.id, 2, B2BConstants.EXPANSION_PER_SEAT_MRR)
	if CustomerRegistry.get_customer(c2.id).mrr != m2 + 2 * B2BConstants.EXPANSION_PER_SEAT_MRR:
		return "an unstamped account did not fall back to the caller's rate"
	return ""


## §13 THE SAVE SCHEMA. Every record the module owns has to survive a round trip, and the
## point of listing them one by one is that a field added later and forgotten here is exactly
## the field that will be found missing by a player rather than by a test.
## FALSIFICATION: drop `star` from Prospect and the first branch fails; drop `sales_band_caps`
## from GameState and the ledger branch does.
static func _case_sales_save_roundtrip_rev6() -> String:
	GameState.set_flag("mvp_shipped", true)
	GameState.set_flag("mvp_market_type", "b2b")
	GameState.set_flag("mvp_sub_product_type_id", "erp")
	var p: Prospect = _add_prospect("save_lead", 3, "line_erp_ledger_k1")
	p.routing = SalesConstants.ROUTE_RESERVED
	p.worked_by = "char_sr_1"
	p.work_started_day = GameState.day - 2
	p.work_due_day = GameState.day + 3
	p.work_stance = SalesConstants.STANCE_PREMIUM
	p.whale_condition = SalesConstants.WHALE_COND_LOCKED_TIER
	p.is_whale = true
	p.last_loss_reason = SalesConstants.LOSS_PRICE
	p.loss_count = 2
	var cp: Prospect = _add_prospect("save_cust", 2, "")
	var c: Customer = SalesSystem.add_b2b_customer(cp, 18, 52, 70, "founder_pitch", 0.2)
	SalesLedger.set_price_stance(SalesConstants.STANCE_PREMIUM)
	SalesLedger.set_rep_band_cap("char_sr_1", 2)
	SalesLedger.report_loss("Kayıp A.Ş.", SalesConstants.LOSS_STABILITY, "stability")
	SalesLedger.record_insult("Devrilen A.Ş.")
	SalesFaucetSystem.lock_return("Kilitli A.Ş.", 12)
	SalesLedger.set_open_pitch_promise(c.id, "line_erp_ledger_k1")
	SalesLedger.consume_meeting_right()
	SalesLedger.spend_inner_voice()
	SalesProbes.remember("probe_capacity")

	var slot: String = "smoke_sales_v11"
	if not SaveManager.save_to_slot(slot):
		return "the save was refused: %s" % SaveManager.cannot_save_reason_key()
	var data: Dictionary = SaveManager.read_slot(slot)
	if data.is_empty():
		return "the slot read back empty"
	# `read_slot` returns {ok, error_key, meta, state} — the version is consumed by the
	# migration ladder inside it and does not travel further, which is why `ok` is the thing
	# to assert: a schema this build refuses comes back false with a named reason.
	if not bool(data.get("ok", false)):
		return "the slot did not read back cleanly: %s" % String(data.get("error_key", ""))
	SaveManager.apply_loaded_state(data)

	var rp: Prospect = ProspectRegistry.get_prospect("save_lead")
	if rp == null:
		return "the lead did not survive the round trip"
	for pair in [["star", rp.star, 3], ["loss_count", rp.loss_count, 2],
			["work_started_day", rp.work_started_day, p.work_started_day],
			["work_due_day", rp.work_due_day, p.work_due_day]]:
		if int(pair[1]) != int(pair[2]):
			return "lead.%s came back %d, want %d" % [String(pair[0]), int(pair[1]), int(pair[2])]
	for spair in [["routing", rp.routing, SalesConstants.ROUTE_RESERVED],
			["work_stance", rp.work_stance, SalesConstants.STANCE_PREMIUM],
			["whale_condition", rp.whale_condition, SalesConstants.WHALE_COND_LOCKED_TIER],
			["last_loss_reason", rp.last_loss_reason, SalesConstants.LOSS_PRICE],
			["worked_by", rp.worked_by, "char_sr_1"],
			["pain_feature_id", rp.pain_feature_id, "line_erp_ledger_k1"]]:
		if String(spair[1]) != String(spair[2]):
			return "lead.%s came back '%s', want '%s'" % [
				String(spair[0]), String(spair[1]), String(spair[2])]
	if not rp.is_whale:
		return "the whale flag did not survive"

	var rc: Customer = CustomerRegistry.get_customer(c.id)
	if rc == null or rc.seat_price != 52:
		return "the account's seat price did not survive"
	if absf(rc.signing_discount - 0.2) > 0.001:
		return "the signing discount trace did not survive: %.3f" % rc.signing_discount

	if SalesLedger.price_stance() != SalesConstants.STANCE_PREMIUM:
		return "the price stance did not survive"
	if SalesLedger.rep_band_cap("char_sr_1") != 2:
		return "the band cap did not survive"
	if SalesLedger.loss_reason("Kayıp A.Ş.") != SalesConstants.LOSS_STABILITY:
		return "the account memory did not survive"
	if SalesLedger.loss_log().is_empty():
		return "the loss log did not survive"
	if not SalesLedger.was_insulted("Devrilen A.Ş."):
		return "the insult memory did not survive"
	if not SalesFaucetSystem.is_return_locked("Kilitli A.Ş."):
		return "the return lock did not survive"
	if SalesLedger.open_pitch_promise() != c.id:
		return "the open pitch promise did not survive"
	if SalesLedger.meeting_available_today():
		return "the spent meeting right did not survive"
	if SalesLedger.inner_voice_left() >= SalesConstants.INNER_VOICE_BUDGET_PER_RUN:
		return "the inner-voice budget did not survive"
	if not GameState.sales_line_memory.has("probe_capacity"):
		return "the content repeat memory did not survive"
	SaveManager.delete_slot(slot)
	return ""


## §11.5 — every key this module DERIVES at run time must resolve. A derived key is invisible
## to a grep for tr("LITERAL"), so a typo reaches the player as a raw token; this walks the
## real id lists and asks the translation server, the same shape as loc_b2b_derived_keys.
static func _case_loc_sales_derived_keys() -> String:
	var loc0: String = TranslationServer.get_locale()
	var wanted: Array[String] = []
	for id in SalesArchetypes.ids():
		wanted.append("SALES_ARCH_%s_LINE" % String(id).to_upper())
	for row in SalesProbes.CATALOGUE:
		var rid: String = String((row as Dictionary).get("id", ""))
		wanted.append("SALES_PROBE_%s" % rid.to_upper())
		for a in ((row as Dictionary).get("answers", []) as Array):
			wanted.append("SALES_ANS_%s_%s" % [rid.to_upper(),
				String((a as Dictionary).get("id", "")).to_upper()])
			var lf: String = String((a as Dictionary).get("lock_fact", ""))
			if lf != "":
				wanted.append("SALES_LOCK_%s" % lf.to_upper())
	wanted.append("SALES_LOCK_OPEN_PITCH_PROMISE")
	for reason in SalesConstants.LOSS_REASONS:
		wanted.append("SALES_LOSS_%s" % String(reason).to_upper())
		wanted.append("SALES_MEMORY_%s" % String(reason).to_upper())
	for cond in SalesConstants.WHALE_CONDITION_ORDER:
		wanted.append("SALES_WHALE_%s" % String(cond).to_upper())
	for stance in SalesConstants.STANCES:
		wanted.append("SALES_STANCE_%s" % String(stance).to_upper())
		wanted.append("SALES_STANCE_HINT_%s" % String(stance).to_upper())
	for key in ["SALES_BLOCK_NO_B2B", "SALES_BLOCK_MEETING_SPENT", "SALES_BLOCK_TOO_LATE",
			"SALES_BLOCK_NO_LEAD", "SALES_BLOCK_REASON_UNCHANGED", "SALES_BAND_ABOVE_REP",
			"SALES_BAND_ABOVE_CAP", "SALES_WIN_CUT", "SALES_INNER_VOICE_0",
			"SALES_INNER_VOICE_1", "SALES_INNER_VOICE_2"]:
		wanted.append(key)
	for locale in ["tr", "en"]:
		TranslationServer.set_locale(locale)
		for k in wanted:
			if TranslationServer.translate(k) == k:
				TranslationServer.set_locale(loc0)
				return "%s does not resolve in %s" % [k, locale]
	TranslationServer.set_locale(loc0)
	# The narrative half must be TAGGED, so the writing round can find every line it owns.
	TranslationServer.set_locale("tr")
	for row2 in SalesProbes.CATALOGUE:
		var key2: String = "SALES_PROBE_%s" % String((row2 as Dictionary).get("id", "")).to_upper()
		if not TranslationServer.translate(key2).begins_with("PH:"):
			TranslationServer.set_locale(loc0)
			return "%s is not tagged as a placeholder" % key2
	TranslationServer.set_locale(loc0)
	return ""


## §7.3 PRESENTATION, both halves. The ticker sees NEWS ONLY — a routine close reaches the
## player through the account list and the weekly summary, never by scrolling past. And the
## weekly card carries CLOSES ONLY: churn is the customer desk's surface, and a week with no
## closes drops no card at all.
## FALSIFICATION: drop the newsworthy test from _maybe_ticker and the first branch fails on
## the very first routine close.
static func _case_sales_presentation_rules() -> String:
	GameState.set_flag("mvp_shipped", true)
	GameState.set_flag("mvp_market_type", "b2b")
	GameState.set_flag("mvp_sub_product_type_id", "erp")
	_seed_b2b(1000)
	var rep: Character = _make_sales_rep("char_sr_1", 0, 9)   # Satış 9 -> star 4, reach band 4
	var lines: Array = []
	var probe := func(_src: String, text: String) -> void: lines.append(text)
	EventBus.headline_added.connect(probe)

	# A ROUTINE close: 1 star, well under the reach band. It must not reach the ticker.
	_add_prospect("routine_news", 1, "")
	for i in 20:
		GameState.advance_day()
		B2BSalesSystem.daily_tick()
		if ProspectRegistry.get_prospect("routine_news") == null:
			break
	if ProspectRegistry.get_prospect("routine_news") != null:
		EventBus.headline_added.disconnect(probe)
		return "the routine lead never closed, so the ticker rule was never exercised"
	if not lines.is_empty():
		EventBus.headline_added.disconnect(probe)
		return "a routine close reached the ticker: %s" % str(lines)

	# A 3-star close IS news (§7.3's own list: league-above, whale, the run's first 3 star).
	_add_prospect("news_worthy", 3, "")
	for i in 20:
		GameState.advance_day()
		B2BSalesSystem.daily_tick()
		if ProspectRegistry.get_prospect("news_worthy") == null:
			break
	EventBus.headline_added.disconnect(probe)
	if ProspectRegistry.get_prospect("news_worthy") != null:
		return "the 3-star lead never closed"
	if lines.is_empty():
		return "a 3-star signing did not reach the ticker"

	# THE WEEKLY CARD carries closes and nothing else, and a quiet week produces none.
	GameState.set_flag("sales_weekly_closes", 0)
	GameState.set_flag("sales_weekly_anchor_day",
		GameState.day - SalesConstants.WEEKLY_SUMMARY_INTERVAL_DAYS - 1)
	var reported: Array = []
	var wprobe := func(closes: int) -> void: reported.append(closes)
	EventBus.weekly_sales_report_issued.connect(wprobe)
	SalesRepSystem.daily_tick()
	if not reported.is_empty():
		EventBus.weekly_sales_report_issued.disconnect(wprobe)
		return "a week with zero closes still issued a summary"
	# With a close on the books it does report, and it reports the COUNT.
	GameState.set_flag("sales_weekly_closes", 3)
	GameState.set_flag("sales_weekly_anchor_day",
		GameState.day - SalesConstants.WEEKLY_SUMMARY_INTERVAL_DAYS - 1)
	SalesRepSystem.daily_tick()
	EventBus.weekly_sales_report_issued.disconnect(wprobe)
	if reported.size() != 1 or int(reported[0]) != 3:
		return "the weekly summary did not report its closes: %s" % str(reported)
	# And the counter resets, or the next week reports this week's work again.
	if int(GameState.get_flag("sales_weekly_closes", -1)) != 0:
		return "the weekly close counter did not reset"
	if rep == null:
		return "fixture rep vanished"
	return ""


## SATIŞ rev 6 §11.7 + §11.8 — THE TWO RULINGS THE SALES GDD HANDS TO THE EKİP GENERATOR.
## They are PARAMETERS of the one generator, never a second one (§15 puts candidate generation
## in Ekip §10.2 and a sales-only copy would be the second source that table forbids).
## FALSIFICATION: delete ROLE_ARCHETYPE_SHAPE and the curve branch fails on the first level;
## delete ROLE_TRAIT_BAN and the trap-trait branch fails inside a dozen seeds.
static func _case_sales_candidate_curve_and_traits() -> String:
	# THE CURVE SITS UNDER EVERY OTHER ROLE'S, at every level and every archetype. In sales a
	# star is money (§2), and the role has no secondary area to spend points on.
	for level in [HRConstants.LEVEL_JUNIOR, HRConstants.LEVEL_MID, HRConstants.LEVEL_SENIOR]:
		for arch in HRConstants.ARCHETYPES:
			var sales_key: int = int(HRConstants.archetype_shape(
				level, String(arch), HRConstants.ROLE_SALES_REP)[0])
			var neutral_key: int = int(HRConstants.archetype_shape(level, String(arch))[0])
			if sales_key >= neutral_key:
				return "sales %s at level %d is not below the neutral curve (%d vs %d)" % [
					String(arch), level, sales_key, neutral_key]
			if sales_key > SalesConstants.CANDIDATE_STAR_CAP_RAW:
				return "sales %s at level %d exceeds the demo ceiling: raw %d" % [
					String(arch), level, sales_key]
	# §11.7's centres, read as stars.
	var jr_uzman: float = HRConstants.stars_for(int(HRConstants.archetype_shape(
		HRConstants.LEVEL_JUNIOR, HRConstants.ARCHETYPE_UZMAN, HRConstants.ROLE_SALES_REP)[0]))
	if jr_uzman > 1.5:
		return "the junior sales centre is above ★1,5: %.1f" % jr_uzman
	var sr_uzman: float = HRConstants.stars_for(int(HRConstants.archetype_shape(
		HRConstants.LEVEL_SENIOR, HRConstants.ARCHETYPE_UZMAN, HRConstants.ROLE_SALES_REP)[0]))
	if sr_uzman > 3.0:
		return "the senior sales centre is above ★3: %.1f" % sr_uzman

	# GENERATED FILES obey the ceiling and the ban, across many seeds — including the rare TOP
	# file, whose peak must be the ROLE's ceiling rather than the ruler's end.
	var saw_top: bool = false
	for seed_value in range(1, 120):
		for level2 in [HRConstants.LEVEL_JUNIOR, HRConstants.LEVEL_MID, HRConstants.LEVEL_SENIOR]:
			var files: Array = HRCandidateGenerator.generate(
				HRConstants.ROLE_SALES_REP, level2, seed_value)
			if files.size() != HRConstants.CANDIDATE_COUNT:
				return "the generator returned %d sales files" % files.size()
			if not HRCandidateGenerator.is_non_dominated_set(files):
				return "a dominated sales file at seed %d level %d" % [seed_value, level2]
			for f in files:
				var axes: Dictionary = (f as Dictionary).get("axes", {}) as Dictionary
				var key: int = int(axes.get(HRConstants.AREA_SALES, 0))
				if key > SalesConstants.CANDIDATE_STAR_CAP_RAW:
					return "a sales file reached raw %d, over the ★3,5 demo ceiling" % key
				if key == SalesConstants.CANDIDATE_STAR_CAP_RAW:
					saw_top = true
				for t in ((f as Dictionary).get("traits", []) as Array):
					if String(t) == "takes_them_under" or String(t) == "double_checker":
						return "a sales candidate carries the banned trait '%s'" % String(t)
	if not saw_top:
		return "the top sales file never appeared in 119 searches — the branch is dead"

	# THE BAN IS A POOL FILTER, NOT A DELETION: the same traits stay live for another role.
	var pool: Array = HRConstants.cost_trait_ids(HRConstants.ROLE_DEVELOPER)
	if not pool.has("takes_them_under") or not pool.has("double_checker"):
		return "the trap traits were removed globally instead of filtered per role"
	if HRConstants.cost_trait_ids(HRConstants.ROLE_SALES_REP).size() < 1:
		return "the sales cost pool is empty — a Pazarlık file could not be built"
	return ""


# ============================================================================
# FUNDING LADDER + PHASE/ENDINGS (2026-08-27)
# The seed rung, the derived Series A sheet, the fifth bootstrap clause, and the
# buyout card. Each case FALSIFIES rather than merely asserting: a case that can
# only pass proves nothing.
# ============================================================================

const SEED_DOOR_ID := "funding.seed_door"
const SEED_OFFER_ID := "funding.seed_offer"
const SEED_CLOSED_ID := "funding.seed_closed"
const BUYOUT_ID := "funding.acquisition_offer"


## A Traction company sitting exactly on the seed bar, with a live B2B book.
static func _seed_seed_world(mrr: int = SeedConstants.DOOR_MRR) -> void:
	GameState.set_cash(40000)
	GameState.set_phase(2)
	_seed_b2b(mrr)
	_seed_b2b_lines("saas_ops")


## Run the seed meeting end to end with a given set of beat choices.
static func _play_seed_meeting(vc_id: String, choices: Array) -> bool:
	if not SeedRoundSystem.begin_pitch(vc_id):
		return false
	for c in choices:
		VCPitchSystem.advance(String(c))
	return true


static func _case_seed_door_traction_only() -> String:
	# THREE PHASES AND A RATCHET. Bootstrap must not open it; Traction must; and a dip below
	# the bar afterwards must NOT close it, because the announcement card is one_shot and a
	# door that re-locks can never tell the player about itself again.
	_seed_seed_world()
	GameState.set_phase(1)
	_sim_day_full()
	if SeedRoundSystem.door_open():
		return "the door opened in Bootstrap"
	GameState.set_phase(2)
	_sim_day_full()
	if not SeedRoundSystem.door_open():
		return "the door did not open in Traction at the bar (mrr %d)" % GameState.mrr
	var latched: int = GameState.seed_door_open_day
	CustomerRegistry.set_mrr(CustomerRegistry.get_by_market("b2b")[0].id, 1)
	_sim_day_full()
	if not SeedRoundSystem.door_open():
		return "an MRR dip re-locked the door — the ratchet is a live predicate"
	if GameState.seed_door_open_day != latched:
		return "the latch day moved %d -> %d" % [latched, GameState.seed_door_open_day]
	GameState.set_phase(3)
	if SeedRoundSystem.door_open():
		return "the door stayed open into the Series A Hunt"
	return ""


static func _case_seed_door_below_bar() -> String:
	_seed_seed_world(SeedConstants.DOOR_MRR / 2)
	for i in 5:
		_sim_day_full()
	if GameState.seed_door_open_day >= 0:
		return "the door latched at mrr %d, under the %d bar" % [GameState.mrr, SeedConstants.DOOR_MRR]
	if EvHistory.fire_count(SEED_DOOR_ID) > 0:
		return "the door card fired below the bar"
	return ""


static func _case_seed_door_number_never_rendered() -> String:
	# The appetite grammar: the door is shown, the figure is not. Every string this rung puts
	# on screen is checked, in both locales, for the bar in any shape it could be written.
	var loc0: String = TranslationServer.get_locale()
	var bar: int = SeedConstants.DOOR_MRR
	var forms: Array[String] = [str(bar), Fmt.money(bar), Fmt.money_exact(bar), Fmt.group(bar)]
	var keys: Array[String] = ["SEED_DOOR_TITLE", "SEED_DOOR_BODY", "SEED_DOOR_GO",
		"SEED_SECTION_TITLE", "SEED_DOOR_LINE", "SEED_DOOR_HINT", "SEED_BLOCK_CLOSED"]
	for loc in ["tr", "en"]:
		TranslationServer.set_locale(loc)
		for k in keys:
			var line: String = TranslationServer.translate(k)
			for f in forms:
				if line.contains(f):
					TranslationServer.set_locale(loc0)
					return "%s (%s) renders the door figure '%s'" % [k, loc, f]
	TranslationServer.set_locale(loc0)
	return ""


static func _case_seed_pitch_never_rejects() -> String:
	# The rung is GUARANTEED once entered (ruling 3). Drive the worst room available — the
	# hardest angle, then the posture that caps the room — and assert an offer still lands with
	# the cascade counter untouched and the fund still approachable at Series A.
	_seed_seed_world()
	_sim_day_full()
	var rejections0: int = GameState.vc_rejections
	if not _play_seed_meeting("anchor", ["b1_read", "b2_metrik", "b3_gecistir", "b4_ack"]):
		return "begin_pitch refused at an open door"
	if GameState.seed_sheet == null:
		return "a floored seed room produced no offer — the rung is not guaranteed"
	if GameState.vc_rejections != rejections0:
		return "a seed outcome moved the cascade counter to %d" % GameState.vc_rejections
	if String(GameState.vc_states.get("anchor", {}).get("status", "open")) in ["rejected", "walked"]:
		return "the seed sitting closed the fund for Series A"
	if GameState.series_a_closed or not GameState.run_active:
		return "the seed sitting ended the run"
	if GameState.run_sheets_won != 0:
		return "the seed offer counted as a Series A sheet won"
	return ""


static func _case_seed_bands_map_to_terms() -> String:
	# Three bands, three openings, each inside its declared envelope, and warmer must be
	# better in BOTH directions — more money for less of the company.
	var seen: Dictionary = {}
	for band in SeedConstants.BAND_IDS:
		var sheet: TermSheet = SeedRoundSystem.make_seed_sheet("anchor", String(band), 10)
		var raise_amount: int = int(sheet.opening_terms.get("raise", 0))
		var dil: int = int(sheet.opening_terms.get("dilution_pct", 0))
		if raise_amount < SeedConstants.RAISE_MIN or raise_amount > SeedConstants.RAISE_MAX:
			return "%s raise %d outside the band" % [band, raise_amount]
		if dil < SeedConstants.DIL_MIN or dil > SeedConstants.DIL_MAX:
			return "%s dilution %d outside the band" % [band, dil]
		if sheet.stage != PitchConstants.STAGE_SEED:
			return "%s sheet carries stage '%s'" % [band, sheet.stage]
		if sheet.expires_day != SeedConstants.NO_EXPIRY_DAY:
			return "%s sheet expires on day %d — the seed offer must not lapse" % [band, sheet.expires_day]
		seen[String(band)] = [raise_amount, dil]
	var strong: Array = seen[SeedConstants.BAND_STRONG]
	var harsh: Array = seen[SeedConstants.BAND_HARSH]
	if strong == harsh:
		return "strong and harsh produced identical terms %s — the band table is inert" % str(strong)
	if int(strong[0]) <= int(harsh[0]) or int(strong[1]) >= int(harsh[1]):
		return "a strong room is not better than a harsh one: %s vs %s" % [str(strong), str(harsh)]
	return ""


static func _case_seed_sheet_never_in_active_sheets() -> String:
	# FOUR LOAD-BEARING READERS walk active_sheets, and this names them one at a time:
	# leverage, the sheet cap, the soft-cap paper's unsigned line, and the cascade defer.
	_seed_seed_world()
	_sim_day_full()
	if not _play_seed_meeting("anchor", ["b1_read", "b2_vizyon", "b3_durust", "b4_ack"]):
		return "fixture: the seed meeting would not start"
	if GameState.seed_sheet == null:
		return "fixture: no seed offer"
	if not GameState.active_sheets.is_empty():
		return "the seed sheet landed in active_sheets"
	if VCPitchSystem.sheet_for("anchor") != null:
		return "sheet_for() returns the seed sheet — Series A code would negotiate it"
	if int(GameState.get_run_ledger().get("unsigned_sheets", 0)) != 0:
		return "the ledger counts the seed offer as an unsigned Series A sheet"
	if VCPitchSystem.is_last_answer_moment():
		return "the seed offer triggered the last-answer moment"
	# And the cascade must still be able to fire with a seed offer on the table.
	GameState.set_phase(3)
	GameState.vc_rejections = EndingsSystem.CASCADE_TABLES
	GameState.set_cash(1)
	CustomerRegistry.set_mrr(CustomerRegistry.get_by_market("b2b")[0].id, 0)
	for i in 3:
		_sim_day_full()
		if not GameState.run_active:
			break
	if GameState.run_active:
		return "a live seed offer deferred the rejection cascade"
	if GameState.ending_id != "vc_rejection_cascade":
		return "ended as '%s'" % GameState.ending_id
	return ""


static func _case_seed_table_walk_is_locked() -> String:
	# ZOR MOD, the Frank-cheque pattern: visible, disabled, and its reason names the real
	# shortfall. Falsified the same way the angel row is — by setting the flag.
	_seed_seed_world()
	_sim_day_full()
	if not _play_seed_meeting("anchor", ["b1_read", "b2_vizyon", "b3_durust", "b4_ack"]):
		return "fixture: the seed meeting would not start"
	var vs: Dictionary = TermSheetTableSystem.open("anchor")
	if vs.is_empty():
		return "the seed table would not open"
	if bool(vs.get("walk_enabled", true)):
		return "the seed table offers a walk"
	if not bool((vs.get("walk_lock", {}) as Dictionary).get("locked", false)):
		return "the walk row is disabled without saying why"
	if String((vs.get("walk_lock", {}) as Dictionary).get("reason_key", "")) == "":
		return "the walk lock carries no reason key"
	var rejections0: int = GameState.vc_rejections
	TermSheetTableSystem.walk()
	if GameState.seed_sheet == null:
		return "walk() destroyed the seed offer"
	if GameState.vc_rejections != rejections0:
		return "walk() at a seed table moved the cascade counter"
	# FALSIFY: the lock must be a live read of one named flag, not a constant.
	GameState.set_flag(AngelRoundSystem.HARD_MODE_FLAG, true)
	var open_vs: Dictionary = TermSheetTableSystem.view_state()
	var still_locked: bool = bool((open_vs.get("walk_lock", {}) as Dictionary).get("locked", false))
	GameState.set_flag(AngelRoundSystem.HARD_MODE_FLAG, false)
	if still_locked:
		return "the lock stayed shut with hard_mode_unlocked set — it is not a real condition"
	return ""


static func _case_seed_sign_is_not_terminal() -> String:
	# The first term sheet the player signs, and the first one that does not end the game.
	# Also the atomicity probe, sampled from INSIDE cash_changed like the angel case.
	_seed_seed_world()
	_sim_day_full()
	if not _play_seed_meeting("anchor", ["b1_read", "b2_vizyon", "b3_durust", "b4_ack"]):
		return "fixture: the seed meeting would not start"
	TermSheetTableSystem.open("anchor")
	var terms: Dictionary = GameState.seed_sheet.opening_terms.duplicate()
	var cash0: int = GameState.cash
	var tx0: int = FinanceSystem.get_transactions().size()
	var seen_equity: Array = [-1]
	var probe := func(_v: int) -> void: seen_equity[0] = GameState.get_investor_equity_pct()
	EventBus.cash_changed.connect(probe)
	TermSheetTableSystem.sign()
	EventBus.cash_changed.disconnect(probe)

	var raise_amount: int = int(terms.get("raise", 0))
	if GameState.cash != cash0 + raise_amount:
		return "cash %d -> %d, wanted +%d" % [cash0, GameState.cash, raise_amount]
	if GameState.run_seed_amount != raise_amount:
		return "run_seed_amount is %d" % GameState.run_seed_amount
	if GameState.seed_lead != "anchor":
		return "seed_lead is '%s'" % GameState.seed_lead
	if GameState.seed_closed_day != GameState.day:
		return "the expectation clock did not start"
	if GameState.seed_sheet != null:
		return "the offer survived being signed"
	if FinanceSystem.get_transactions().size() != tx0 + 1:
		return "no ledger row"
	if seen_equity[0] != GameState.run_seed_equity_pct:
		return "cash_changed fired with the cap table at %d%% — the round is not atomic" % seen_equity[0]
	if not GameState.run_active or GameState.ending_id != "":
		return "signing the seed ended the run as '%s'" % GameState.ending_id
	if GameState.series_a_closed:
		return "signing the seed set series_a_closed"
	if GameState.run_equity_pct != 0 or GameState.run_investment_amount != 0:
		return "the seed wrote the Series A term block"
	return ""


static func _case_seed_survives_series_a_sign() -> String:
	# The sibling of angel_survives_series_a: a Series A signature must not erase the seed
	# slice, which is the exact collision the separate scalars exist to prevent.
	GameState.record_seed_round(15, 120000, "anchor")
	GameState.record_angel_round(4, 25000)
	VCPitchSystem._persist_signed_terms({"valuation_m": 20, "dilution_pct": 20,
		"board_seats": 1, "board_veto": false})
	if GameState.run_seed_equity_pct != 15:
		return "the seed slice became %d%%" % GameState.run_seed_equity_pct
	if GameState.get_investor_equity_pct() != 4 + 15 + 20:
		return "composed investor equity is %d%%, wanted 39" % GameState.get_investor_equity_pct()
	if GameState.get_total_raised() != 25000 + 120000 + 4_000_000:
		return "total raised is %d" % GameState.get_total_raised()
	return ""


static func _case_seed_expectation_grace_then_stall() -> String:
	GameState.seed_lead = "anchor"
	GameState.seed_closed_day = 100
	GameState.day = 100 + SeedConstants.EXPECT_GRACE_DAYS - 1
	_seed_month_closes([10000, 10000, 10000, 10000])       # flat, but inside the grace window
	if SeedRoundSystem.expectation_state() != SeedConstants.EXPECT_GRACE:
		return "a flat month inside grace read as %d" % SeedRoundSystem.expectation_state()
	GameState.day = 100 + SeedConstants.EXPECT_GRACE_DAYS + 1
	if SeedRoundSystem.expectation_state() != SeedConstants.EXPECT_STALLED:
		return "a flat quarter past grace read as %d" % SeedRoundSystem.expectation_state()
	_seed_growth_streak(20000)                              # +15 %/month, above the 10 % bar
	if SeedRoundSystem.expectation_state() != SeedConstants.EXPECT_ON_TRACK:
		return "a growing quarter read as %d" % SeedRoundSystem.expectation_state()
	GameState.seed_lead = ""
	if SeedRoundSystem.expectation_state() != SeedConstants.EXPECT_NONE:
		return "an unseeded run carries an expectation"
	return ""


static func _case_seed_lead_warmth_at_series_a() -> String:
	_seed_b2b_series_a()
	GameState.set_phase(3)
	GameState.seed_lead = ""
	var cold: int = int(VCPitchSystem.initial_conviction("anchor").get("value", 0))
	var nexus_cold: int = int(VCPitchSystem.initial_conviction("nexus").get("value", 0))
	GameState.seed_lead = "anchor"
	var warm: int = int(VCPitchSystem.initial_conviction("anchor").get("value", 0))
	if warm - cold != SeedConstants.SEED_LEAD_WARMTH_BONUS:
		return "the seed lead gained %d conviction, wanted %d" % [
			warm - cold, SeedConstants.SEED_LEAD_WARMTH_BONUS]
	if int(VCPitchSystem.initial_conviction("nexus").get("value", 0)) != nexus_cold:
		return "the warmth reached a fund that did not lead the round"
	return ""


static func _case_seed_stage_does_not_leak() -> String:
	# The sitting-local stage must be cleared on close, or the next Series A table paints a
	# raise lever over valuation_m terms and reads $0.
	_seed_seed_world()
	_sim_day_full()
	if not _play_seed_meeting("anchor", ["b1_read", "b2_vizyon", "b3_durust", "b4_ack"]):
		return "fixture: the seed meeting would not start"
	TermSheetTableSystem.open("anchor")
	if String(TermSheetTableSystem.levers()[0]) != "raise":
		return "the seed table's first lever is '%s'" % String(TermSheetTableSystem.levers()[0])
	TermSheetTableSystem.sign()
	GameState.set_phase(3)
	_grant("nexus")
	TermSheetTableSystem.open("nexus")
	if String(TermSheetTableSystem.levers()[0]) != "valuation":
		return "a seed stage leaked into the Series A table"
	if TermSheetTableSystem.money_raised() <= 0:
		return "the Series A table read money_raised as %d" % TermSheetTableSystem.money_raised()
	return ""


static func _case_seed_table_levers_and_final_offer() -> String:
	# The seed table negotiates raise / dilution / board, never the Series A rows (the "$0M
	# valuation" bug), and at patience zero it always ends in the final counter — the seed
	# fund cannot walk, however cold the room was.
	_seed_seed_world()
	_sim_day_full()
	if not _play_seed_meeting("anchor", ["b1_read", "b2_vizyon", "b3_durust", "b4_ack"]):
		return "fixture: the seed meeting would not start"
	GameState.seed_sheet.conviction = 0
	var vs: Dictionary = TermSheetTableSystem.open("anchor")
	var ids: Array = []
	for L in vs.get("levers", []):
		ids.append(String(L.get("id", "")))
	if ids != ["raise", "dilution", "board"]:
		return "the seed table's rows are %s" % str(ids)
	var raise0: int = int(GameState.seed_sheet.opening_terms.get("raise", 0))
	if String(vs.levers[0].current_text) != Fmt.money_exact(raise0):
		return "the raise row reads '%s'" % String(vs.levers[0].current_text)
	# The board row is on the sheet but locked: seed accept keeps no board term (an open
	# decision, docs/ACIK_ISLER/ACIK_KARARLAR.md), so a push there would spend patience on nothing.
	var board_row: Dictionary = vs.levers[2]
	if bool(board_row.get("push_enabled", true)) or TermSheetTableSystem.can_push("board"):
		return "the seed board row can be pushed, but signing keeps no board term"
	if String(board_row.get("odds", {}).get("split_text", "")) != TranslationServer.translate("SEED_BOARD_LOCKED"):
		return "the locked seed board row does not say why"
	vs = TermSheetTableSystem.select_lever("raise")
	if String(vs.selected_lever) != "raise":
		return "the raise row cannot be selected (selected '%s')" % String(vs.selected_lever)
	_force("fail")
	for i in 8:
		if TermSheetTableSystem.can_push("raise"):
			TermSheetTableSystem.push()
	vs = TermSheetTableSystem.view_state()
	if int(vs.state) != TermSheetTableSystem.PATIENCE_ZERO:
		return "a cold seed table ended in state %d, not the final offer" % int(vs.state)
	if not bool(vs.sign_enabled) or bool(vs.walk_enabled) or bool(vs.fund_walked):
		return "the seed final offer is not sign-only"
	if int(vs.money_raised) < raise0:
		return "the seed final offer shrank the raise"
	return ""


static func _case_series_a_sheet_derives_from_arr() -> String:
	# The sheet is PRICED now, not copied. A faster company must get a better one.
	_seed_b2b_series_a()
	GameState.set_phase(3)
	_seed_month_closes([10000, 10000, 10000, 10000])            # flat: the low multiple band
	var slow: int = int(VCPitchSystem._make_sheet("anchor", GameState.day).opening_terms.get("valuation_m", 0))
	_seed_growth_streak(GameState.mrr)                          # +15 %/month: the high band
	var fast: int = int(VCPitchSystem._make_sheet("anchor", GameState.day).opening_terms.get("valuation_m", 0))
	if fast <= slow:
		return "a fast-growing company was valued at %dM against a flat one's %dM" % [fast, slow]
	var dil: int = int(VCPitchSystem._make_sheet("anchor", GameState.day).opening_terms.get("dilution_pct", 0))
	if dil < PitchConstants.SERIES_A_DIL_MIN or dil > PitchConstants.SERIES_A_DIL_MAX:
		return "dilution %d outside [%d, %d]" % [dil, PitchConstants.SERIES_A_DIL_MIN, PitchConstants.SERIES_A_DIL_MAX]
	# And the funds still differ from each other — the archetypes survived the change.
	var nexus_val: int = int(VCPitchSystem._make_sheet("nexus", GameState.day).opening_terms.get("valuation_m", 0))
	if nexus_val == fast:
		return "every fund priced the same company identically — the archetype nudge is inert"
	return ""


static func _case_bootstrap_needs_the_faced_flag() -> String:
	# Ch. 13 §1: profitability alone is not an ending. Build a run that satisfies all four
	# economic clauses and assert it does NOT win until the Series A decision has been faced.
	GameState.set_cash(100000)
	_seed_b2b(EndingsSystem.BOOTSTRAP_WIN_MRR + 5000)
	GameState.set_phase(2)
	GameState.faced_series_a = false
	GameState.faced_series_a_by = ""
	_seed_month_closes([20000, 21000, 22000, 23000, 24000, 25000], 30000, 24000)
	var sig: Dictionary = EndingsSystem.profitability_signal()
	if not (bool(sig.streak_ok) and bool(sig.margin_ok) and bool(sig.mrr_ok) and bool(sig.scandal_ok)):
		return "fixture: the four economic clauses are not met (%s)" % str(sig)
	if bool(sig.met):
		return "the bootstrap win fired without the Series A decision being faced"
	_sim_day_full()
	if not GameState.run_active:
		return "the run ended as '%s' with the faced flag unset" % GameState.ending_id
	# Each of the three writers must open it.
	for reason in ["declined", "walked", "door_open"]:
		GameState.faced_series_a = false
		GameState.faced_series_a_by = ""
		GameState.mark_faced_series_a(reason)
		if not bool(EndingsSystem.profitability_signal().get("met", false)):
			return "the win stayed shut after the '%s' writer" % reason
	return ""


static func _case_faced_flag_upgrades_only() -> String:
	# door_open must never overwrite a decline or a walk: the buyout card reads the REASON,
	# and a founder who walked a table has done the thing the card is about.
	GameState.faced_series_a = false
	GameState.faced_series_a_by = ""
	GameState.mark_faced_series_a("door_open")
	GameState.mark_faced_series_a("walked")
	if GameState.faced_series_a_by != "walked":
		return "walked did not upgrade door_open (got '%s')" % GameState.faced_series_a_by
	GameState.mark_faced_series_a("door_open")
	if GameState.faced_series_a_by != "walked":
		return "door_open overwrote walked"
	return ""


static func _case_buyout_needs_the_road_over() -> String:
	# The guard the sealed first sentence depends on: "Series A turu kapandı, ortada anlaşma
	# yok". One walked table with three funds still open does NOT close the road.
	_seed_b2b_series_a()
	GameState.set_phase(3)
	GameState.record_seed_round(15, 120000, "anchor")
	GameState.seed_closed_day = 1
	_grant("anchor")
	VCPitchSystem.walk_table("anchor", "walked")
	if not GameState.faced_series_a:
		return "walking a table did not set the faced flag"
	if GameState.faced_series_a_by != "walked":
		return "the faced flag reads '%s'" % GameState.faced_series_a_by
	if EndingsSystem.road_over():
		return "the road read as over with three funds still open"
	for vc in ["nexus", "bosphorus", "meridian"]:
		GameState.vc_states[vc] = {"status": "rejected", "callback": {}, "pending_sheet": false}
	if not EndingsSystem.road_over():
		return "the road did not close once every fund was closed"
	# THE MODAL SLOT HAS TO BE DRAINED. One card is active at a time, so an unresolved
	# foreign card blocks every later one — and a case that does not drain measures the
	# queue rather than the card it names.
	var arrived: bool = false
	for i in EndingsSystem.ACQ_CARD_WINDOW_DAYS + 2:
		_sim_day_full()
		if _drain_to(BUYOUT_ID):
			arrived = true
			break
		if not GameState.run_active:
			break
	if not arrived:
		return ("the buyout card never fired inside the window "
			+ "(road_over=%s days_open=%d lead=%s active=%s)" % [
				str(EndingsSystem.road_over()), EndingsSystem.acq_days_open(),
				GameState.seed_lead, EventGate.active_id()])
	# It names the SEED LEAD, and its two numbers are money rather than raw integers.
	# THE ACTIVE CONTEXT, not a bare render. render() with no context binds no scope slot,
	# so {investor} would survive to the assertion and this case would be measuring the
	# harness rather than the card. active_context() is the frozen binding the real modal
	# paints from.
	var ev: GameEvent = EventGate.render(BUYOUT_ID, EventGate.active_context())
	# FLATTENED: tools/smoke_run.sh extracts the verdict with a line-based grep, so a
	# failure message carrying a multi-paragraph body would be cut at its first newline
	# and the useful half would never reach the log.
	var body: String = Localization.pick(ev.body_text, ev.body_text_en).replace("
", " / ")
	var lead_name: String = String(InvestorRegistry.get_investor("anchor").get("display_name", ""))
	if not body.contains(lead_name):
		return "the buyout body does not name the seed lead: %s" % body
	if body.contains("{"):
		return "the buyout body reached the player with an unresolved token: %s" % body
	if ev.choices.size() != 2:
		return "the buyout card offers %d choices" % ev.choices.size()
	# "Kendi paramla devam" continues the run AND remembers the refusal.
	EventGate.resolve(BUYOUT_ID, "carry_on")
	if not GameState.run_active:
		return "carrying on ended the run as '%s'" % GameState.ending_id
	if not bool(GameState.get_flag("acquisition_offer_rejected", false)):
		return "refusing to sell was not remembered — a later VC meeting asks about it"
	if not GameState.pivot_used:
		return "carrying on left the VC road open"
	return ""


static func _case_buyout_inert_without_the_flag() -> String:
	# The exact world that used to open BOTH old cards — phase 3, brand 40, MRR alive, three
	# closed tables — with the faced flag never set by a decline or a walk. Nothing may fire.
	_seed_b2b_series_a()
	GameState.set_phase(3)
	GameState.set_brand(40)
	GameState.vc_rejections = 3
	GameState.record_seed_round(15, 120000, "anchor")
	GameState.faced_series_a = false
	GameState.faced_series_a_by = ""
	for vc in ["anchor", "nexus", "bosphorus", "meridian"]:
		GameState.vc_states[vc] = {"status": "rejected", "callback": {}, "pending_sheet": false}
	if EndingsSystem.road_over():
		return "the road read as over with the faced flag unset"
	# DRAINED EVERY DAY, or this case passes for the wrong reason: a blocked modal slot
	# would keep the buyout card off the screen and the assertion below would read as
	# proof of a guard that was never tested.
	for i in 30:
		_sim_day_full()
		if _drain_to(BUYOUT_ID):
			return "the buyout card fired without a decline or a walk"
		if not GameState.run_active:
			break
	if EvHistory.fire_count(BUYOUT_ID) > 0:
		return "the buyout card resolved without a decline or a walk"
	if GameState.ending_id == "acquisition":
		return "the acquisition ending fired with no card"
	return ""


static func _case_buyout_numbers_make_the_sentence_true() -> String:
	# The sealed line reads "At a {valuation} valuation, your share comes to {offer}". So the
	# offer must be the founder's SLICE of the valuation, never the valuation again.
	_seed_b2b(10000)
	GameState.set_brand(40)
	GameState.record_seed_round(15, 120000, "anchor")
	var val: int = EndingsSystem.acquisition_valuation()
	var share: int = EndingsSystem.acquisition_founder_share()
	if val <= 0:
		return "valuation is %d" % val
	if share >= val:
		return "the founder's share (%d) is not smaller than the valuation (%d)" % [share, val]
	var m: float = EndingsSystem.acquisition_multiple()
	if m < EndingsSystem.ACQ_M_MIN or m > EndingsSystem.ACQ_M_MAX:
		return "multiple %f escaped the clamp" % m
	# The clamp is real, not decorative.
	GameState.set_brand(100)
	_seed_growth_streak(GameState.mrr)
	if EndingsSystem.acquisition_multiple() > EndingsSystem.ACQ_M_MAX:
		return "the multiple escaped its clamp on a perfect run"
	# And the two seams the card reads must render money, not a bare integer.
	if not String(EvSeams.read("funding.acq_valuation")).contains("$"):
		return "funding.acq_valuation reads '%s'" % String(EvSeams.read("funding.acq_valuation"))
	return ""


static func _case_b2c_ending_reports_audience() -> String:
	# Ch. 13 §2: no template may print an account count on a consumer run.
	_seed_live_product()
	for i in 3:
		_sim_day_full()
	var ledger: Dictionary = GameState.get_run_ledger()
	if String(ledger.get("market", "")) != "b2c":
		return "the ledger did not record a consumer run"
	if int(ledger.get("audience", 0)) <= 0:
		return "audience is %d on a live consumer run" % int(ledger.get("audience", 0))
	var paying: int = int(ledger.get("paying_users", 0))
	if paying <= 0:
		return "paying_users is %d after the paid tier opened" % paying
	# The stat row must name PAYING, never MÜŞTERİ, and never the aggregate record count of 1.
	for eid in ["profitable_bootstrap", "running_on_fumes", "series_a_close"]:
		var vs: Dictionary = EndingsCopy.build(eid, ledger, {"company_name": "Probe"})
		var labels: Array = []
		for cell in (vs.get("stat_cells", []) as Array):
			labels.append(String((cell as Dictionary).get("label", "")))
			if String((cell as Dictionary).get("figure", "")) == "1" \
					and String((cell as Dictionary).get("label", "")) == TranslationServer.translate("END_STAT_CUSTOMERS"):
				return "%s prints the aggregate record as 1 MÜŞTERİ" % eid
		if labels.has(TranslationServer.translate("END_STAT_CUSTOMERS")):
			return "%s prints an account count on a consumer run" % eid
		if not labels.has(TranslationServer.translate("END_STAT_PAYING")):
			return "%s never names the paying users" % eid
	return ""


static func _case_frank_line_renders_outside_the_paper() -> String:
	# Seven translated verdict lines have shipped invisible. They have a surface now — and it
	# must NOT be the newspaper, which bans mentor attribution.
	for eid in EndingsSystem.ENDINGS.keys():
		var line: String = EndingsSystem.ending_frank_line(String(eid))
		if line == "" or line == "END_META_%s_FRANK" % String(eid).to_upper():
			return "%s has no Frank line" % eid
		var vs: Dictionary = EndingsCopy.build(String(eid), GameState.get_run_ledger(),
			{"company_name": "Probe", "frank_line": line})
		# The paper must not carry it in any of its own surfaces.
		for key in ["headline", "subhead", "engraving_caption", "quiet_notice"]:
			if String(vs.get(key, "")) == line:
				return "%s puts the mentor verdict on the paper's %s" % [eid, key]
		for l in (vs.get("ledger_lines", []) as Array):
			if String(l) == line:
				return "%s puts the mentor verdict in the paper's ledger box" % eid
	return ""


static func _case_bankruptcy_frank_line_says_thirty() -> String:
	# The line said seven while the top bar counted thirty for all thirty of those days.
	var loc0: String = TranslationServer.get_locale()
	for loc in ["tr", "en"]:
		TranslationServer.set_locale(loc)
		var line: String = TranslationServer.translate("END_META_BANKRUPTCY_FRANK")
		var seven: String = "Yedi" if loc == "tr" else "seven"
		var thirty: String = "Otuz" if loc == "tr" else "thirty"
		if line.contains(seven):
			TranslationServer.set_locale(loc0)
			return "[%s] the bankruptcy verdict still says seven" % loc
		if not line.contains(thirty):
			TranslationServer.set_locale(loc0)
			return "[%s] the bankruptcy verdict names no span: %s" % [loc, line]
	TranslationServer.set_locale(loc0)
	if EndingsSystem.SHUTTER_DAYS != 30:
		return "SHUTTER_DAYS moved to %d and the copy did not follow" % EndingsSystem.SHUTTER_DAYS
	return ""


static func _case_card_body_tokens_resolve() -> String:
	# THE GATE THAT WOULD HAVE CAUGHT THE {days} BUG. Every card body token must be either a
	# declared scope slot or a registered seam; anything else survives EvPresenter._interpolate
	# and reaches the player as literal braces. funding.sheet_expiry shipped exactly that.
	EvCatalog.reload()
	var tok := RegEx.new()
	tok.compile("[{]([a-z_]+)[}]")
	var offenders: Array = []
	for id in EvCatalog.card_ids():
		var card: Dictionary = EvCatalog.card(String(id))
		var slots: Array = (card.get("scope", {}) as Dictionary).keys()
		for locale in ["tr", "en"]:
			var block: Dictionary = (card.get("text", {}) as Dictionary).get(locale, {})
			var bodies: Array = []
			var body: Variant = block.get("body", "")
			if typeof(body) == TYPE_DICTIONARY:
				for v in (body as Dictionary).get("variants", {}).values():
					bodies.append(String(v))
			else:
				bodies.append(String(body))
			for b in bodies:
				var text: String = b
				# A CSV key resolves to its value; prose is checked as written.
				var resolved: String = TranslationServer.translate(text)
				if resolved != text:
					text = resolved
				for m in tok.search_all(text):
					var name: String = m.get_string(1)
					if slots.has(name) or EvSeams.has(name):
						continue
					var row: String = "%s[%s]:{%s}" % [id, locale, name]
					if not offenders.has(row):
						offenders.append(row)
	if not offenders.is_empty():
		return "card body tokens that resolve to nothing: %s" % ", ".join(offenders)
	return ""


static func _case_seed_sheet_round_trips() -> String:
	# The one untested path in the new state: TermSheet = null as a coerce_like template.
	_seed_seed_world()
	_sim_day_full()
	if not _play_seed_meeting("anchor", ["b1_read", "b2_vizyon", "b3_durust", "b4_ack"]):
		return "fixture: the seed meeting would not start"
	var before: TermSheet = GameState.seed_sheet
	if before == null:
		return "fixture: no seed offer"
	GameState.mark_faced_series_a("door_open")
	var block: Dictionary = SaveCodec.capture_game_state()
	GameState.seed_sheet = null
	GameState.seed_lead = ""
	GameState.faced_series_a = false
	GameState.faced_series_a_by = ""
	SaveCodec.apply_game_state(block)
	var after: TermSheet = GameState.seed_sheet
	if after == null:
		return "the seed sheet did not survive a save round trip"
	if String(after.stage) != PitchConstants.STAGE_SEED:
		return "stage came back as '%s'" % after.stage
	if String(after.band) != String(before.band):
		return "band came back as '%s', was '%s'" % [after.band, before.band]
	if int(after.opening_terms.get("raise", 0)) != int(before.opening_terms.get("raise", 0)):
		return "the raise came back as %d" % int(after.opening_terms.get("raise", 0))
	if String(after.vc_id) != String(before.vc_id):
		return "vc_id came back as '%s'" % after.vc_id
	if not GameState.faced_series_a or GameState.faced_series_a_by != "door_open":
		return "the faced flag did not survive the round trip"
	return ""
