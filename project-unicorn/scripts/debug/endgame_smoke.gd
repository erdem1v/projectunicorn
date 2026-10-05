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
const SHEET_WARN_ID := "funding.sheet_expiry"
const SHEET_DECISION_ID := "funding.sheet_decision"

# Fixture skill defaults. The names are kept because fifty-odd call sites pass them
# positionally; what they set are areas:
#   SEED_EXPERTISE 5 → the role's KEY AREA, inside the sprint's middle skill band: a seeded
#                      employee works the neutral 2 points a week.
#   SEED_PACE 3      → every OTHER area (the "rest" floor). Low but never zero: rev 2 §2
#                      wants a one-person team to have no holes.
#   SEED_RAPPORT 5   → LİDERLİK, the middle of the ruler.
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
	# The summary frequency is the player's setting; the suite reads the monthly cadence.
	SummarySystem.frequency_override = "monthly"
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
		"speed_preserve":       fail = _case_speed_preserve()
		"month_summary":        fail = _case_month_summary()
		"summary_frequency_ticks": fail = _case_summary_frequency_ticks()
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
		"burn_tools_and_service": fail = _case_burn_tools_and_service()
		"add_cash_writes_ledger": fail = _case_add_cash_writes_ledger()
		# --- İterasyon döngüsü (player-gated restore) + ekip kalite tavanı ---
		"runway_net_status":    fail = _case_runway_net_status()
		"gross_runway_months":  fail = _case_gross_runway_months()
		"locale_switch":        fail = _case_locale_switch()
		"b2b_lifecycle_and_countdown": fail = _case_b2b_lifecycle_and_countdown()
		"b2b_satisfaction_leaves_b2c_identical": fail = _case_b2b_satisfaction_leaves_b2c_identical()
		"b2b_retention_routes_seams": fail = _case_b2b_retention_routes_seams()
		"b2b_ignore_then_churn": fail = _case_b2b_ignore_then_churn()
		"b2b_pitch_meeting_signs": fail = _case_b2b_pitch_meeting_signs()
		"sales_meeting_replays_identically": fail = _case_sales_meeting_replays_identically()
		"sales_inner_voice_reaches_view": fail = _case_sales_inner_voice_reaches_view()
		"sales_faucet_guard_b2c": fail = _case_sales_faucet_guard_b2c()
		"sales_lead_expiry_and_return_lock": fail = _case_sales_lead_expiry_and_return_lock()
		"sales_meeting_time_skip_founder_share": fail = _case_sales_meeting_time_skip_founder_share()
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
		# --- DESTEK (§8) ve ALTYAPI (§10) ---
		"destek_empty_desk_piles_up":    fail = _case_destek_empty_desk_piles_up()
		"fix_run_ships_subset":          fail = _case_fix_run_ships_subset()
		"infra_capacity_moves_both_ways": fail = _case_infra_capacity_moves_both_ways()
		"infra_heavy_step_costs_capacity": fail = _case_infra_heavy_step_costs_capacity()
		"infra_overage_applies_and_stops": fail = _case_infra_overage_applies_and_stops()
		"infra_local_provider_tradeoff": fail = _case_infra_local_provider_tradeoff()
		"product_read_catalogue":        fail = _case_product_read_catalogue()
		"hr_frank_guard":           fail = _case_hr_frank_guard()
		"hr_active_filters":        fail = _case_hr_active_filters()
		"hr_overload_badge":        fail = _case_hr_overload_badge()
		"hr_constants_contract":    fail = _case_hr_constants_contract()
		"speed_ladder":            fail = _case_speed_ladder()
		"speed_day_invariant":     fail = _case_speed_day_invariant()
		# --- Product×HR Coupling (task 2 of 3) ---
		"coupling_wear_team_average":    fail = _case_coupling_wear_team_average()
		"coupling_cs_dampen_axis":       fail = _case_coupling_cs_dampen_axis()
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
		"event_instance_per_subject":         fail = _case_event_instance_per_subject()
		"scope_given_subject_gone_refused":   fail = _case_scope_given_subject_gone_refused()
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
		"save_v13_day_stamps_migrate":        fail = _case_save_v13_day_stamps_migrate()
		"look_registry_unique_and_saved":     fail = _case_look_registry_unique_and_saved()
		"meeting_cast_seeded_and_saved":      fail = _case_meeting_cast_seeded_and_saved()
		"vc_call_postpones_once":             fail = _case_vc_call_postpones_once()
		"hr_experience_accrues":      fail = _case_hr_experience_accrues()
		"hr_training_eligibility_edge": fail = _case_hr_training_eligibility_edge()
		"hr_training_blocks_and_charges_once": fail = _case_hr_training_blocks_and_charges_once()
		"hr_training_completion":     fail = _case_hr_training_completion()
		"hr_expertise_cap_respected": fail = _case_hr_expertise_cap_respected()
		# --- Native çözünürlük / ultrawide ---
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
		"event_set_aside_no_history":     fail = _case_event_set_aside_no_history()
		"event_no_double_resolution_after_load": fail = _case_event_no_double_resolution_after_load()
		"event_history_names_survive":    fail = _case_event_history_names_survive()
		"event_history_chip_matches_live": fail = _case_event_history_chip_matches_live()
		"messages_save_round_trip":       fail = _case_messages_save_round_trip()
		"sales_weekly_report_is_a_message": fail = _case_sales_weekly_report_is_a_message()
		"loc_b4_derived_keys":       fail = _case_loc_b4_derived_keys()
		"loc_b5_derived_keys":       fail = _case_loc_b5_derived_keys()
		"loc_language_switch":       fail = _case_loc_language_switch()
		# --- Calibration pass (2026-08-19) — one guard per number ---
		"harness_sniffer_matches_run_log": fail = _case_harness_sniffer_matches_run_log()
		"quality_half_sat_25":             fail = _case_quality_half_sat_25()
		"b2b_v1_lands_mid_band":           fail = _case_b2b_v1_lands_mid_band()
		"b2c_satisfaction_drifts_to_experience": fail = _case_b2c_satisfaction_drifts_to_experience()
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
		"b2c_value_reads_live_lines":      fail = _case_b2c_value_reads_live_lines()
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
		"milestone_paper_waits_for_card":  fail = _case_milestone_paper_waits_for_card()
		"event_gate_holds_clock":          fail = _case_event_gate_holds_clock()
		"profit_predicate_margin_scale_red": fail = _case_profit_predicate_margin_scale_red()
		"speed_save_clamps_to_ladder":     fail = _case_speed_save_clamps_to_ladder()
		"topbar_speed_cluster_four_rungs": fail = _case_topbar_speed_cluster_four_rungs()
		"smoke_seed_pinned":               fail = _case_smoke_seed_pinned()
		"ambient_hourly_chance_exact":     fail = _case_ambient_hourly_chance_exact()
		"ambient_hourly_never_at_night": fail = _case_ambient_hourly_never_at_night()
		"borderless_note_key_exists":      fail = _case_borderless_note_key_exists()
		# --- Temizlik turu 2026-08-20 (GDD v2 uygunluk denetiminin karar gerektirmeyen
		#     bulguları). Üçü de ÖNCEKİ motora karşı DÜŞER; falsifikasyonla doğrulandı.
		"source_tag_speaker_wins":         fail = _case_source_tag_speaker_wins()
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
		"split_bars_name_their_cause": fail = _case_split_bars_name_their_cause()
		"rnd_rail_open_with_waiting_page": fail = _case_rnd_rail_open_with_waiting_page()
		"rnd_note_author_and_lines": fail = _case_rnd_note_author_and_lines()
		"card_math_matches_gdd_example":  fail = _case_card_math_matches_gdd_example()
		"save_v10_product_state":         fail = _case_save_v10_product_state()
		# --- rev 6.1 · router devri (2026-08-25). İkisi de ÖNCEKİ ağaca karşı DÜŞER.
		"type_screen_matches_line_content": fail = _case_type_screen_matches_line_content()
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
		"card_body_tokens_resolve":              fail = _case_card_body_tokens_resolve()
		"seed_sheet_round_trips":                fail = _case_seed_sheet_round_trips()
		"office_move_gates_and_save":            fail = _case_office_move_gates_and_save()
		"sprint_two_days_close":                 fail = _case_sprint_two_days_close()
		"sprint_capacity_from_team":             fail = _case_sprint_capacity_from_team()
		"sprint_ceiling_125_blocks_add":         fail = _case_sprint_ceiling_125_blocks_add()
		"sprint_carry_keeps_progress":           fail = _case_sprint_carry_keeps_progress()
		"sprint_mvp_three_identity_k1":          fail = _case_sprint_mvp_three_identity_k1()
		"sprint_faulty_ticket_deterministic":    fail = _case_sprint_faulty_ticket_deterministic()
		"sprint_fix_card_closes_tickets":        fail = _case_sprint_fix_card_closes_tickets()
		"sprint_beta_delays_release":            fail = _case_sprint_beta_delays_release()
		"sprint_auto_start_after_a_day":         fail = _case_sprint_auto_start_after_a_day()
		"sprint_request_on_time_met":            fail = _case_sprint_request_on_time_met()
		"sprint_paid_plan_opens_paid_tier":      fail = _case_sprint_paid_plan_opens_paid_tier()
		"sprint_save_roundtrip":                 fail = _case_sprint_save_roundtrip()
		"sprint_decision_blocks_progress":       fail = _case_sprint_decision_blocks_progress()
		"sprint_beta_card_cannot_be_added":      fail = _case_sprint_beta_card_cannot_be_added()
		"sprint_release_resets_live_bugs":       fail = _case_sprint_release_resets_live_bugs()
		"sprint_departure_restaffs_card":        fail = _case_sprint_departure_restaffs_card()
		"sprint_never_stalls_in_plan":           fail = _case_sprint_never_stalls_in_plan()
		"sprint_lead_offers_paid_plan_b2c":      fail = _case_sprint_lead_offers_paid_plan_b2c()
		"sprint_solo_mvp_by_week_six":           fail = _case_sprint_solo_mvp_by_week_six()
		"promise_due_sprint_kept_when_shipped_next_sprint": fail = _case_promise_due_sprint_kept_when_shipped_next_sprint()
		"promise_due_sprint_breaks_after_close": fail = _case_promise_due_sprint_breaks_after_close()
		"promise_relock_after_break":            fail = _case_promise_relock_after_break()
		"quiet_cards_fill_empty_floor":          fail = _case_quiet_cards_fill_empty_floor()
		"sprint_decision_card_fires_shipped":    fail = _case_sprint_decision_card_fires_shipped()
		"promise_row_locked_after_break":        fail = _case_promise_row_locked_after_break()
		"promise_row_locked_when_no_room":       fail = _case_promise_row_locked_when_no_room()
		"sprint_late_only_when_behind":          fail = _case_sprint_late_only_when_behind()
		"save_v14_build_becomes_sprint_plan":    fail = _case_save_v14_build_becomes_sprint_plan()
		"save_v14_history_becomes_releases":     fail = _case_save_v14_history_becomes_releases()
		"product_paid_plan_locked_until_mvp":    fail = _case_product_paid_plan_locked_until_mvp()
		"product_pm_plan_opens_as_next_sprint":  fail = _case_product_pm_plan_opens_as_next_sprint()
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


# TAM GÜN sürücü: oyunun saat yolu (TimeManager.advance_hours) bu tikin kalan saatlerini ve 00:00
# devrini koşar, günlük tikten hemen sonra, gece atlamasına girmeden durur. Toplu adım kartları
# sonda bir kez gösterir, yani toplu adımda kabul edilen kart 00:00'da yeniden doğrulanır.
static func _sim_day_full() -> void:
	TimeManager.advance_hours(TimeModel.HOURS_PER_DAY - GameState.current_hour)


# Bir sonraki tikin 08:00'ine, oyunun oynadığı gibi: günün kalanı, devir ve günlük tik, sonra gece
# atlaması. Uyanık saate kapılı saatlik kartlar (toplantı ve masa oturumu) 08:00'de kabul edilir ve
# atlamanın sonundaki pump'ta gösterilir.
static func _sim_to_morning() -> void:
	_sim_day_full()
	TimeManager.skip_night()


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


## An established book at the bar, not a fresh signing: its onboarding window is closed, or the
## phase-3 onboarding service cost would drain the cash and the VC cases would run in the shutter.
static func _seed_b2b_series_a() -> void:
	_seed_b2b(SalesSystem.TRACTION_MRR_TARGET + 1000)
	CustomerRegistry.get_customer("co_lead_smoke").onboarding_until = GameState.day


## Closed calendar months on GameState.month_history: sequential spans of 30 ticks (only the
## closes and the money are read), the given MRR closes, one income/expense pair per month.
static func _seed_month_closes(mrr_closes: Array, income: int = 30000, expense: int = 24000, red_weeks: int = 0) -> void:
	GameState.month_history.clear()
	var start: int = 1
	for m in mrr_closes:
		GameState.push_month_close({"start_day": start, "end_day": start + 29, "mrr_close": int(m),
			"income": income, "expense": expense, "net": income - expense, "red_weeks": red_weeks})
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
	# the decline path, the escalating bodies and the cooldown re-ask live ONLY on
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
	# which is also the number the reminder half of this case counts ticks against.
	var card: Dictionary = EventGate.catalogue_card(GATE2_ID)
	if (card.get("options", []) as Array).size() != 2:
		return "%s carries %d option(s) — the escalation contract has no home left" % [
			GATE2_ID, (card.get("options", []) as Array).size()]
	var variants: Dictionary = ((card.get("text", {}) as Dictionary).get("tr", {}) as Dictionary) \
		.get("body", {}).get("variants", {})
	if variants.size() < 2:
		return "%s carries %d body/bodies — nothing can escalate" % [GATE2_ID, variants.size()]
	var remind_ticks: int = TimeModel.ticks(int((card.get("latch", {}) as Dictionary).get("cooldown_weeks", 0)))
	if remind_ticks < 1:
		return "%s has no re-ask cooldown" % GATE2_ID
	# Strictly inside the window, so the clock cannot tick on its own; a one-week cooldown
	# leaves no room and the hold is empty.
	var hold_ticks: int = remind_ticks - 1

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
	for i in hold_ticks:
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
	if elapsed >= remind_ticks:
		return "the hold consumed the whole cooldown (%d of %d) — the window proves nothing" % [
			elapsed, remind_ticks]
	for i in remind_ticks - elapsed - 1:
		_sim_day()
		if _instances_of(GATE2_ID) > 0:
			return "reminder re-admitted early (%d ticks after the fire, cooldown %d)" % [
				GameState.day - fired_day, remind_ticks]
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
	for i in remind_ticks + 1:
		_sim_day()
		if _instances_of(GATE2_ID) > 1:
			return "gate scene duplicated (§7.10 violation)"
	return ""


## The Traction card is a NOTIFICATION now (Frank v6, surface 9): ONE body, ONE option, and
## therefore no decline counter, no escalating copy and no cooldown re-ask.
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
	# SHUTTER_WEEKS + 1'inci tik'te düşer. Bir tik pay bırakılıyor ve döngüyü asıl
	# durduran aşağıdaki `break`.
	for i in TimeModel.ticks(EndingsSystem.SHUTTER_WEEKS) + 2:
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
	# üç ardışık tik SHUTTER_WEEKS - 2 bırakır.
	var want_left: int = TimeModel.ticks(EndingsSystem.SHUTTER_WEEKS) - 2
	if GameState.shutter_weeks_left != want_left:
		return "counter wrong after 3 ticks (%d, want %d)" % [GameState.shutter_weeks_left, want_left]
	GameState.set_cash(5000)
	_sim_day()
	if GameState.shutter_weeks_left != -1:
		return "counter did not reset on recovery (%d)" % GameState.shutter_weeks_left
	for i in 5:
		_sim_day()
	if not GameState.run_active or not _endings.is_empty():
		return "run ended after recovery: %s" % str(_endings)
	return ""


static func _case_brand_collapse() -> String:
	GameState.day = 40
	GameState.set_brand(10)
	GameState.active_scandal = true
	# Under the floor for exactly the window once the next tick lands.
	GameState.brand_low_since_day = GameState.day + 1 - TimeModel.ticks(EndingsSystem.BRAND_COLLAPSE_WINDOW)
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

# --- Kapasite havuzu + freeze-silme case'leri ---

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
	# The inbox opens on summary_ready; month_ended only carries the month_history entry.
	var summaries: Array = []
	var closes: Array = []
	var lines: Array = []
	EventBus.summary_ready.connect(func(d: Dictionary) -> void: summaries.append(d))
	EventBus.month_ended.connect(func(d: Dictionary) -> void: closes.append(d))
	EventBus.ticker_live_line.connect(func(_src: String, t: String) -> void: lines.append(t))

	# Highlight registry rules: higher priority replaces, first-come wins ties.
	GameState.submit_month_highlight("a", {}, 50)
	GameState.submit_month_highlight("b", {}, 90)
	GameState.submit_month_highlight("c", {}, 90)
	if String(GameState.month_highlight.get("key", "")) != "b":
		return "highlight priority/tie rule broken (%s)" % str(GameState.month_highlight)
	GameState.month_highlight.clear()
	GameState.month_highlight_priority = -1

	# Quiet January with one known delta: brand 50 → 60. No customers, no mvp flags → gates
	# stay closed, MRR stays 0, cash falls by burn only. Ticks 1-5 are the Thursdays of January.
	GameState.set_brand(60)
	for i in 4:
		_sim_day()  # ticks 2..5
	if not summaries.is_empty() or not closes.is_empty():
		return "month fired early (tick %d, count %d)" % [GameState.day, summaries.size()]
	_sim_day()  # tick 6 = 5 Feb 2026 → January closes in slot 0, before this week's flow
	if summaries.size() != 1 or closes.size() != 1:
		return "expected one summary and one close at tick 6, got %d / %d" % [summaries.size(), closes.size()]
	# The inbox keeps the same payload: numbers and keys, rendered when it is read.
	var posted: Array = GameState.messages.filter(func(msg: Dictionary) -> bool: return msg.kind == "summary")
	if posted.size() != 1 or posted[0].args != summaries[0] or posted[0].key != "MONTH_TITLE":
		return "the summary was not posted to the inbox as its payload: %s" % str(posted)
	var payload: Dictionary = summaries[0]
	var m: Dictionary = SummarySystem.display(payload)
	var want_title: String = TranslationServer.translate("MONTH_TITLE").format(
		{"month": Fmt.month_name(1), "year": 2026})
	if String(m.title) != want_title:
		return "title: %s (want %s)" % [String(m.title), want_title]
	var want_range: String = TranslationServer.translate(Fmt.count_key("SUMMARY_RANGE", 5)).format(
		{"from": 1, "to": 5})
	if String(m.range) != want_range:
		return "range: %s (want %s)" % [String(m.range), want_range]
	if int(payload.brand.from) != 50 or int(payload.brand.to) != 60:
		return "brand delta: %s" % str(payload.brand)
	if int(payload.mrr.from) != 0 or int(payload.mrr.to) != 0:
		return "mrr delta: %s" % str(payload.mrr)
	# Day 1 has no finance tick, so January carries ticks 2-5: four weeks, 28 days of $50 burn.
	var jan_flow: int = 4 * TimeModel.DAYS_PER_TICK * 50
	if int(payload.cash.from) != 10000 or int(payload.cash.to) != 10000 - jan_flow:
		return "cash delta: %s (want 10000 → %d)" % [str(payload.cash), 10000 - jan_flow]
	if int(closes[0].expense) != jan_flow or int(closes[0].end_day) != 6:
		return "January close: %s (want expense %d, end_day 6)" % [str(closes[0]), jan_flow]
	if int(payload.team.from) != 1 or int(payload.team.to) != 1:
		return "team delta: %s" % str(payload.team)
	var quiet: String = TranslationServer.translate(String(SummarySystem.PERIOD_KEYS["monthly"].quiet))
	if String(m.highlight) != quiet:
		return "quiet month should use fallback highlight, got: %s" % String(m.highlight)
	var lit: Dictionary = payload.duplicate(true)
	lit.highlight = {"key": "GATE_OPENED", "args": {"phase": "Traction"}}
	var want_lit: String = TranslationServer.translate("GATE_OPENED").format({"phase": "Traction"})
	if String(SummarySystem.display(lit).highlight) != want_lit:
		return "a submitted highlight did not render from its key and args"
	# Which RULE fired is the assertion; the sentence is whatever the CSV says it is.
	var want_frank: String = TranslationServer.translate("MONTH_FRANK_ANOTHER")
	if String(m.frank_line) != want_frank:
		return "frank rule mismatch: %s (want %s)" % [String(m.frank_line), want_frank]
	if int(GameState.month_ledger.get("start_day", 0)) != 6:
		return "ledger not re-snapshotted (start_day %s)" % str(GameState.month_ledger.get("start_day"))
	# The close itself is one live ticker line (runway is still above every alert band).
	var want_line: String = TranslationServer.translate("MONTH_CLOSED_TICKER").format({
		"month": Fmt.month_name(1), "mrr": Fmt.money(0), "delta": Fmt.money(-jan_flow)})
	if lines != [want_line]:
		return "month close ticker lines: %s (want [%s])" % [str(lines), want_line]

	# Run counter seams (write-only; the period snapshot must not be affected).
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
	if int(GameState.summary_ledger.get("brand", -1)) != 60:
		return "counters disturbed the period snapshot"

	# Terminal suppression: February is ticks 6-9, so it closes at tick 10 (5 Mar). A Class-A
	# ending on that tick: slot 9 ends the run before slot 10 sends → the ending wins, no second
	# summary. The month still closes in slot 0.
	while GameState.day < 9:
		_sim_day()
	if summaries.size() != 1:
		return "february closed before tick 10? (count %d, tick %d)" % [summaries.size(), GameState.day]
	GameState.series_a_closed = true
	_sim_day()  # tick 10
	if GameState.run_active:
		return "run did not end on tick 10"
	if summaries.size() != 1:
		return "summary fired on a terminal tick (ending must win)"
	if closes.size() != 2:
		return "February did not close in slot 0 (%d closes)" % closes.size()
	return ""


## The summary arrives at the right tick for each frequency, and a month close outside the
## summary's period is silent: one live ticker line, no summary. One calendar year of ticks
## 2..54 (tick N is the Thursday 1 Jan 2026 + 7(N − 1); 54 = 7 Jan 2027) through SummarySystem's
## two slots. A month turns on the first Thursday of the next month. The runway line rides the
## same slot: once when runway falls under a band, again only after it climbs back
## RUNWAY_ALERT_REARM_MONTHS above it and falls once more.
static func _case_summary_frequency_ticks() -> String:
	var fired: Array = []
	var lines: Array = []
	EventBus.summary_ready.connect(func(_d: Dictionary) -> void: fired.append(GameState.day))
	EventBus.ticker_live_line.connect(func(_src: String, _t: String) -> void: lines.append(GameState.day))
	var month_turns: Array = [6, 10, 14, 19, 23, 27, 32, 36, 40, 45, 49, 54]
	var want := {"weekly": range(2, 55), "monthly": month_turns, "quarterly": [14, 27, 40, 54],
		"yearly": [54]}
	for freq in SummarySystem.FREQUENCIES:
		SummarySystem.frequency_override = freq
		fired.clear()
		lines.clear()
		for t in range(2, 55):
			GameState.day = t
			SummarySystem.begin_day()
			SummarySystem.daily_tick()
		if fired != Array(want[freq]):
			return "%s summaries on ticks %s, want %s" % [freq, str(fired), str(want[freq])]
		# One month-close line per turn whatever the frequency; the runway never moves here.
		if lines != month_turns:
			return "%s month-close lines on ticks %s" % [freq, str(lines)]

	# THE RUNWAY LINE. No revenue, so runway is cash / (daily burn × DAYS_PER_MONTH) months.
	var month_cash: float = float(GameState.daily_burn * TimeModel.DAYS_PER_MONTH)
	var band: float = float(FinanceSystem.RUNWAY_ALERT_MONTHS[0])
	var rearm: float = FinanceSystem.RUNWAY_ALERT_REARM_MONTHS
	# above · crosses · stays under · back up inside the re-arm margin · under again ·
	# recovered past the margin · crosses again
	var walk: Array = [band + 1.0, band - 0.1, band - 0.2, band + rearm * 0.5, band - 0.1,
		band + rearm + 0.1, band - 0.1]
	var want_lines: Array = [0, 1, 1, 1, 1, 1, 2]
	lines.clear()
	for i in walk.size():
		GameState.set_cash(int(round(month_cash * float(walk[i]))))
		SummarySystem.daily_tick()
		if lines.size() != int(want_lines[i]):
			return "runway %.2f months: %d ticker line(s), want %d" % [
				GameState.get_runway_months(), lines.size(), int(want_lines[i])]
	return ""


static func _case_terminal_kills_gate() -> String:
	_seed_b2b(500)
	_sim_day()
	if not GameState.phase_gate_ready:
		return "gate did not open"
	GameState.set_cash(-1000)
	# TÜRETİLDİ (_case_bankruptcy'ye bak): kepenk SHUTTER_WEEKS + 1'inci tik'te düşer,
	# `break` düştüğü an çıkar.
	for i in TimeModel.ticks(EndingsSystem.SHUTTER_WEEKS) + 2:
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
	# Drive the beat machine engine-directly (no panel): b1 read → b2 angle → b3 posture → b4 →
	# close the result view.
	VCPitchSystem.advance("b1_read")
	VCPitchSystem.advance("b2_" + b2)
	VCPitchSystem.advance("b3_" + b3)
	VCPitchSystem.advance(b4)
	VCPitchSystem.advance("b4_close")


static func _case_full_loop() -> String:
	# THE vertical slice: phase 3 → request → prompt accept → beats → sheet → sign → ending.
	GameState.set_phase(3)
	_force("pass")
	_seed_b2b_series_a()   # bar + 1000
	_sim_day()  # aggregate MRR to 6000 (SalesSystem mrr bridge)
	if not VCPitchSystem.request_meeting("anchor"):
		return "request_meeting refused"
	for i in 5:
		_sim_to_morning()
		if not GameState.run_active:
			return "run ended during wait: %s" % str(_endings)
		if VCPitchSystem.call_waiting() != "":
			break
	if VCPitchSystem.call_waiting() != "anchor":
		return "the fund never called"
	VCPitchSystem.begin_meeting(VCPitchSystem.call_waiting())
	if not VCPitchSystem.is_active():
		return "meeting did not start"
	_run_meeting("anchor", "metrik", "durust", "b4_ack")
	if VCPitchSystem.is_active():
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
	if not VCPitchSystem.is_active():
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
	# the never-written mvp_bug_count key (now mvp_live_bug_count).
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
	# Two sheets granted the same tick. Frank's warning comes in the last WARNING_WEEKS; at
	# the close the sheets are NOT dropped - a sit-or-decline card asks, one fund at a time,
	# in the same week; declining closes the fund and is not a rejection.
	GameState.set_phase(3)
	GameState.active_sheets.append(VCPitchSystem._make_sheet("anchor", GameState.day))
	GameState.active_sheets.append(VCPitchSystem._make_sheet("nexus", GameState.day))
	var expires: int = VCPitchSystem.sheet_for("anchor").expires_day
	if expires - GameState.day != TimeModel.ticks(PitchConstants.SHEET_VALIDITY_WEEKS):
		return "validity is not %d weeks" % PitchConstants.SHEET_VALIDITY_WEEKS
	var warned := false
	var decided: Array = []
	var decision_days: Array = []
	for i in 20:
		_sim_to_morning()
		for guard in 16:
			var a: String = EventGate.active_id()
			if a == "":
				break
			if a == SHEET_WARN_ID:
				warned = true
				if VCPitchSystem.sheet_for("anchor").weeks_left(GameState.day) > PitchConstants.WARNING_WEEKS:
					return "expiry warning early (%d weeks left)" % VCPitchSystem.sheet_for("anchor").weeks_left(GameState.day)
			if a == SHEET_DECISION_ID:
				var vc: String = str(EventGate.active_context().get("investor", {}).get("id", ""))
				if GameState.active_sheets.size() != 2 - decided.size():
					return "a sheet was dropped before its decision (%d live)" % GameState.active_sheets.size()
				decided.append(vc)
				decision_days.append(GameState.day)
				EventGate.resolve(a, "decline")
				# The next card comes on the next hourly sweep, the same week.
				while decided.size() < 2 and GameState.current_hour < TimeModel.HOURS_PER_DAY - 1 \
						and EventGate.active_id() == "":
					TimeManager.advance_hours(1)
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
		return "the two cards came on different ticks %s" % str(decision_days)
	if decision_days[0] < expires:
		return "decision card before the window closed (tick %d < %d)" % [decision_days[0], expires]
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
	TermSheetTableSystem.open("anchor", PitchConstants.STAGE_SERIES_A)
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
	TermSheetTableSystem.open("anchor", PitchConstants.STAGE_SERIES_A)
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
	TermSheetTableSystem.open("bosphorus", PitchConstants.STAGE_SERIES_A)
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
	TermSheetTableSystem.reset()

	# The cold fund: same pushes, no goodwill left → it walks.
	var rej0: int = GameState.vc_rejections
	VCPitchSystem.sheet_for("bosphorus").conviction = 0
	TermSheetTableSystem.open("bosphorus", PitchConstants.STAGE_SERIES_A)
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
	TermSheetTableSystem.open("anchor", PitchConstants.STAGE_SERIES_A)
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
	TermSheetTableSystem.open("anchor", PitchConstants.STAGE_SERIES_A)
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
	TermSheetTableSystem.open("anchor", PitchConstants.STAGE_SERIES_A)
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
	TermSheetTableSystem.open("anchor", PitchConstants.STAGE_SERIES_A)
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
	TermSheetTableSystem.open("anchor", PitchConstants.STAGE_SERIES_A)
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
	var validity: int = TimeModel.ticks(PitchConstants.SHEET_VALIDITY_WEEKS)
	if sheet.weeks_left(GameState.day) != validity:
		return "validity clock not at full (%d)" % sheet.weeks_left(GameState.day)
	for i in validity - 1:   # deferred up to the offer's last week
		_sim_day()
	if VCPitchSystem.sheet_for("anchor") == null:
		return "sheet expired too early during defer"
	var vs: Dictionary = TermSheetTableSystem.open("anchor", PitchConstants.STAGE_SERIES_A)
	if vs.is_empty() or not TermSheetTableSystem.is_active():
		return "table not re-enterable after defer"
	var want: int = validity - (GameState.day - day0)
	if sheet.weeks_left(GameState.day) != want:
		return "clock did not tick in weeks during defer (%d, want %d)" % [sheet.weeks_left(GameState.day), want]
	return ""


static func _case_hunt_offer_lifecycle() -> String:
	# The pre-table estimate contains the true opening term and is never centred on it,
	# and it does not reroll. Cancelling costs the fund's next meeting and shuts booking
	# for the week. Frank's cold exit is the fund's own line first, then "two in a row".
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
		return "a meeting was booked the same week as a cancel"
	if VCPitchSystem.meeting_blocked_reason("anchor") != "cancelled_this_week":
		return "blocked reason '%s'" % VCPitchSystem.meeting_blocked_reason("anchor")
	var after: int = int(VCPitchSystem.initial_conviction("nexus").value)
	if base - after != PitchConstants.MEETING_CANCEL_PENALTY:
		return "cancel penalty %d (want %d)" % [base - after, PitchConstants.MEETING_CANCEL_PENALTY]
	_sim_day()
	if not VCPitchSystem.request_meeting("nexus"):
		return "booking still shut the next week"
	# A booking moves only before its week, counted from the booked week.
	var day_before: int = int(GameState.pending_meeting.day)
	if not VCPitchSystem.reschedule_meeting():
		return "reschedule refused"
	if int(GameState.pending_meeting.day) != day_before + TimeModel.ticks(PitchConstants.MEETING_LEAD_WEEKS):
		return "reschedule did not re-apply the lead time from the booked week"
	if int(GameState.vc_states["nexus"].get("move_penalty", 0)) \
			!= PitchConstants.MEETING_CANCEL_PENALTY + PitchConstants.MEETING_RESCHEDULE_PENALTY:
		return "move penalties did not accumulate (%s)" % str(GameState.vc_states["nexus"].get("move_penalty"))
	while GameState.day < int(GameState.pending_meeting.day):
		_sim_day()
	if VCPitchSystem.reschedule_meeting():
		return "the meeting moved in its own week"
	GameState.pending_meeting.clear()

	# Cold exit: two rejections in a row.
	_force("fail")
	VCPitchSystem.begin_meeting("anchor")
	VCPitchSystem.advance("b1_read")
	VCPitchSystem.advance("b2_metrik")
	# The shown Beat-3 odds use the rolled difficulty (Kolay on a clean question).
	VCPitchSystem._sorgu = {"key": "clean"}
	var vs: Dictionary = VCPitchSystem._beat3_view_state({})
	var want_chance: float = SkillCheck.chance_for(PitchConstants.BEAT3_SKILL, PitchConstants.DIFF_KOLAY, 0)
	if float(vs.choices[0].check.chance) != want_chance:
		return "clean-question odds shown %.3f, rolled %.3f" % [float(vs.choices[0].check.chance), want_chance]
	VCPitchSystem.advance("b3_spin")
	VCPitchSystem.advance("b4_leave")
	VCPitchSystem.advance("b4_close")
	if not GameState.vc_frank_cold_shown.has("anchor") or not GameState.vc_last_meeting_rejected:
		return "first rejection did not show the fund's own line (%s)" % str(GameState.vc_frank_cold_shown)
	VCPitchSystem.begin_meeting("meridian")
	VCPitchSystem.advance("b1_read")
	VCPitchSystem.advance("b2_metrik")
	VCPitchSystem.advance("b3_spin")
	if VCPitchSystem._pick_cold_exit() != "VC_FRANK_COLD_GENERAL_2":
		return "second rejection in a row picked %s" % VCPitchSystem._pick_cold_exit()
	VCPitchSystem.advance("b4_leave")
	VCPitchSystem.advance("b4_close")
	if GameState.vc_frank_cold_shown.has("meridian"):
		return "the general line also spent meridian's own line"
	return ""


## v13 → v15. A real save taken on tick 40 gets known day values under the v13 names in every
## block, is aged to v13 and read back: today 40 is week 6, a past day d is week (d − 1) / 7 + 1,
## a due date is week 6 plus the weeks it had left (41 and 42 → 7, where the past-day rule says 6).
## The v15 step then drops the build and its sprint flags; the run has no product type, so it opens
## without a sprint. The migrated world then loads and runs a tick.
static func _case_save_v13_day_stamps_migrate() -> String:
	var slot: String = "smoke_v13_days_%d" % OS.get_process_id()
	var done := func(why: String) -> String:
		SaveManager.delete_slot(slot)
		return why
	_seed_save_world()
	var cust_id: String = CustomerRegistry.get_by_market("b2b")[0].id
	_add_prospect("lead_v13", 1, "")
	_drain_all_modals()
	if not SaveManager.save_to_slot(slot):
		return done.call("save_to_slot failed (%s)" % SaveManager.cannot_save_reason_key())
	var path: String = SaveManager.SAVE_DIR + slot + ".json"
	var raw: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(path)) as Dictionary
	var gs: Dictionary = raw["state"]["game_state"]
	var reg: Dictionary = raw["state"]["registries"]
	var sys: Dictionary = raw["state"]["systems"]
	var ev: Dictionary = sys[EvSave.BLOCK_KEY]
	var row_of := func(rows: Array, id: String) -> Dictionary:
		return rows.filter(func(r: Dictionary) -> bool: return r["id"] == id)[0]
	if int(gs["day"]) != 40 or (ev["papers"] as Dictionary).is_empty() \
			or (sys["product"] as Dictionary).has("active_build"):
		return done.call("fixture: want tick 40, a paper on the desk and no build (day %s, papers %s)"
			% [gs["day"], (ev["papers"] as Dictionary).keys()])

	# --- the file aged to v13 ----------------------------------------------------
	raw["schema_version"] = 13
	for k in ["shutter_weeks_left", "summary_ledger", "runway_warn_band", "founder_meeting_hours",
			"sales_meetings_week", "product"]:
		gs.erase(k)
	gs.merge({"shutter_days_left": 10, "brand_low_since_day": 15, "vc_meeting_cancel_day": 39,
		"bootstrap_milestone_day": -1, "company_start_hour": 7, "company_work_hours": 9,
		"cash": 60000, "mrr": 3000, "daily_burn": 1100,   # runway 2 months: band 3
		"cash_history": [{"day": 1, "cash": 100}, {"day": 7, "cash": 107}, {"day": 8, "cash": 108},
			{"day": 40, "cash": 140}],
		"transactions": [{"day": 15, "label": "a", "amount": -1}, {"day": 16, "label": "b", "amount": -2}],
		"cs_escalation_days": [15, 36],
		"sales_return_locks": {"V13 Co": 41},
		"hr_search": {"started_day": 30, "arrival_day": 42},
		"month_ledger": {"start_day": 32, "mrr": 2500, "cash": 111000, "employees": 2, "brand": 55,
			"customers_signed": 1, "customers_lost": 0, "income": 0, "expense": 0, "red_days": 8},
		"month_history": [{"start_day": 1, "end_day": 32, "mrr_close": 0, "income": 0, "expense": 0,
			"net": 0, "red_days": 3}],
	}, true)
	var flags: Dictionary = gs["flags"]
	flags.merge({"mvp_launch_day": 10, "mvp_version_launch_day": 36,
		"mvp_version_history": [{"version": 1, "day": 10}], "mvp_bug_history": [3, 4, 5],
		"mvp_sprint_days_total": 10, "mvp_sprint_days_elapsed": 3.5, "sales_weekly_anchor_day": 0,
		"angel_seed_accepted_day": 29, "finance_runway_warn_snooze_until_day": 42,
		"sales_meeting_active": true, "sales_meeting_used_day": 40, "sales_weekly_closes": 2}, true)
	var emp: Dictionary = row_of.call(reg["characters"], "emp_save")
	emp.erase("flight_risk_weeks")
	emp.erase("training_weeks_left")
	emp.merge({"hire_day": 22, "last_raise_day": 0, "flight_risk_days": 13, "training_days_left": 8,
		"employment_history": [{"day": 22, "kind": "raise", "old": 1, "new": 2}]}, true)
	(row_of.call(reg["customers"], cust_id) as Dictionary).merge({"acquired_on_day": 12,
		"onboarding_until": 41, "last_expansion_day": 20, "support_request_since_day": 33,
		"last_risk_exit_day": -1, "churn_countdown": -1, "risk_streak": 13, "cs_request_phase": 13}, true)
	(row_of.call(reg["prospects"], "lead_v13") as Dictionary).merge({"spawned_on_day": 30,
		"expires_on_day": 41, "work_started_day": -1, "work_due_day": 45}, true)
	reg["promises"][0]["deadline_day"] = 41
	# A build and an arc have nothing behind them here; the build rides through both migrations.
	sys["product"]["active_build"] = {SaveCodec.TYPE_TAG: "FeatureBuild", "start_day": 22,
		"beta_entered_day": 36, "iteration_round_days": 3.5}
	var scope := {"customer": {"type": "customer", "id": cust_id, "bound_day": 22}}
	ev["arcs"]["smoke_v13"] = {"id": "smoke_v13", "subject": {"type": "employee", "id": "emp_save",
		"bound_day": 22}, "started_day": 15, "awaiting_since": 29,
		"frozen_schedule": [{"event_id": EXPANSION_ID, "remaining_days": 10, "context": {}}]}
	ev["flags"]["smoke_v13"] = {"set_day": 22, "set_by": "smoke"}
	ev["timed_flags"]["smoke_v13"] = {"expires_on": SeedConstants.NO_EXPIRY_DAY, "set_day": 20,
		"set_by": "smoke"}
	ev["stamps"]["smoke_v13"] = {"day": 15, "set_by": "smoke"}
	ev["latches"]["smoke_v13"] = {"fires": 1, "last_day": 29}
	(ev["schedule"] as Array).append({"event_id": EXPANSION_ID, "fire_on_day": 55,
		"context": scope.duplicate(true), "arc_id": ""})
	(ev["rows"] as Array).append({"event_id": "smoke.v13", "day": 22, "resolution": "chosen",
		"option_id": "", "outcome_id": "", "entities": scope.duplicate(true), "deltas": [], "arc_id": ""})
	var paper_key: String = (ev["papers"] as Dictionary).keys()[0]
	(ev["papers"][paper_key] as Dictionary).merge({"expires_on": 41, "admitted_day": 38}, true)
	(ev["tempo_window"] as Array).append({"day": 40, "event_id": EXPANSION_ID, "category": "customer",
		"subject": cust_id, "class": "paper"})
	var w := FileAccess.open(path, FileAccess.WRITE)
	w.store_string(JSON.stringify(raw, "\t", false, true))
	w.close()

	# --- read_slot hands back week values ----------------------------------------
	var payload: Dictionary = SaveManager.read_slot(slot)
	if not bool(payload.get("ok", false)):
		return done.call("the v13 save was refused: %s" % payload.get("error_key", ""))
	var st: Dictionary = payload["state"]
	var mgs: Dictionary = st["game_state"]
	var mfl: Dictionary = mgs["flags"]
	var mreg: Dictionary = st["registries"]
	var mev: Dictionary = st["systems"][EvSave.BLOCK_KEY]
	var bad: Array[String] = []
	var expect := func(what: String, got: Variant, want: float) -> void:
		if not (got is int or got is float) or not is_equal_approx(float(got), want):
			bad.append("%s = %s, want %s" % [what, got, want])
	var gone := func(what: String, d: Dictionary, keys: Array) -> void:
		for k in keys:
			if d.has(k):
				bad.append("%s still carries '%s'" % [what, k])
	var days_of := func(rows: Array) -> Array:
		return rows.map(func(r: Dictionary) -> int: return int(r["day"]))

	expect.call("meta.day", payload["meta"].get("day"), 6)
	expect.call("day", mgs.get("day"), 6)
	expect.call("brand_low_since_day", mgs.get("brand_low_since_day"), 3)
	expect.call("vc_meeting_cancel_day (not today)", mgs.get("vc_meeting_cancel_day"), -1)
	expect.call("shutter_weeks_left", mgs.get("shutter_weeks_left"), 2)
	expect.call("bootstrap_milestone_day (sentinel)", mgs.get("bootstrap_milestone_day"), -1)
	expect.call("company_start_hour", mgs.get("company_start_hour"), 8)
	expect.call("company_work_hours", mgs.get("company_work_hours"), 9)
	expect.call("runway_warn_band", mgs.get("runway_warn_band"), 3)
	expect.call("sales_return_locks", mgs["sales_return_locks"].get("V13 Co"), 7)
	expect.call("hr_search.arrival_day", mgs["hr_search"].get("arrival_day"), 7)
	gone.call("game_state", mgs, ["shutter_days_left", "product"])
	gone.call("hr_search", mgs["hr_search"], ["started_day"])
	var cash: Array = (mgs["cash_history"] as Array).map(
		func(r: Dictionary) -> Array: return [int(r["day"]), int(r["cash"])])
	if cash != [[1, 107], [2, 108], [6, 140]]:
		bad.append("cash_history = %s, want each week's last sample" % str(cash))
	if days_of.call(mgs["transactions"]) != [3, 3]:
		bad.append("transactions days = %s, want [3, 3]" % str(days_of.call(mgs["transactions"])))
	var esc: Array = (mgs["cs_escalation_days"] as Array).map(func(d: Variant) -> int: return int(d))
	if esc != [3, 6]:
		bad.append("cs_escalation_days = %s, want [3, 6]" % str(esc))
	var month: Dictionary = mgs["month_ledger"]
	expect.call("month_ledger.start_day", month.get("start_day"), 5)
	expect.call("month_ledger.red_weeks", month.get("red_weeks"), 2)
	gone.call("month_ledger", month, ["red_days", "mrr", "employees", "brand"])
	var period: Dictionary = mgs.get("summary_ledger", {})
	for pair in [["start_day", 5], ["mrr", 2500], ["cash", 111000], ["employees", 2], ["brand", 55]]:
		expect.call("summary_ledger." + pair[0], period.get(pair[0]), pair[1])
	var closed: Dictionary = mgs["month_history"][0]
	expect.call("month_history.start_day", closed.get("start_day"), 1)
	expect.call("month_history.end_day", closed.get("end_day"), 5)
	expect.call("month_history.red_weeks", closed.get("red_weeks"), 1)
	gone.call("month_history", closed, ["red_days"])

	expect.call("mvp_launch_day", mfl.get("mvp_launch_day"), 2)
	expect.call("mvp_version_launch_day", mfl.get("mvp_version_launch_day"), 6)
	expect.call("mvp_version_history.day", mfl["mvp_version_history"][0].get("day"), 2)
	expect.call("sales_weekly_anchor_day (empty)", mfl.get("sales_weekly_anchor_day"), 0)
	expect.call("angel_seed_accepted_day", mfl.get("angel_seed_accepted_day"), 5)
	expect.call("finance_runway_warn_snooze_until_day", mfl.get("finance_runway_warn_snooze_until_day"), 7)
	if (mfl["mvp_bug_history"] as Array).map(func(n: Variant) -> int: return int(n)) != [5]:
		bad.append("mvp_bug_history = %s, want the newest sample" % str(mfl["mvp_bug_history"]))
	gone.call("flags", mfl, ["mvp_sprint_days_total", "mvp_sprint_days_elapsed", "mvp_sprint_weeks_total",
		"mvp_sprint_weeks_elapsed", "sales_meeting_active", "sales_meeting_used_day", "sales_weekly_closes"])

	var memp: Dictionary = row_of.call(mreg["characters"], "emp_save")
	expect.call("hire_day", memp.get("hire_day"), 4)
	expect.call("last_raise_day (sentinel)", memp.get("last_raise_day"), 0)
	expect.call("flight_risk_weeks", memp.get("flight_risk_weeks"), 1)
	expect.call("training_weeks_left", memp.get("training_weeks_left"), 2)
	expect.call("employment_history.day", memp["employment_history"][0].get("day"), 4)
	gone.call("character", memp, ["flight_risk_days", "training_days_left"])
	var mcust: Dictionary = row_of.call(mreg["customers"], cust_id)
	for pair in [["acquired_on_day", 2], ["onboarding_until", 7], ["last_expansion_day", 3],
			["support_request_since_day", 5], ["last_risk_exit_day", -1], ["churn_countdown", -1],
			["risk_streak", 1], ["cs_request_phase", 1]]:
		expect.call("customer." + pair[0], mcust.get(pair[0]), pair[1])
	var mlead: Dictionary = row_of.call(mreg["prospects"], "lead_v13")
	expect.call("prospect.spawned_on_day", mlead.get("spawned_on_day"), 5)
	expect.call("prospect.expires_on_day", mlead.get("expires_on_day"), 7)
	expect.call("prospect.work_started_day (sentinel)", mlead.get("work_started_day"), -1)
	gone.call("prospect", mlead, ["work_due_day"])
	expect.call("promise.deadline_day", mreg["promises"][0].get("deadline_day"), 7)

	gone.call("systems.product", st["systems"]["product"], ["active_build"])

	var arc: Dictionary = mev["arcs"]["smoke_v13"]
	expect.call("arc.started_day", arc.get("started_day"), 3)
	expect.call("arc.awaiting_since", arc.get("awaiting_since"), 5)
	expect.call("arc.subject.bound_day", arc["subject"].get("bound_day"), 4)
	expect.call("arc.frozen.remaining_weeks", arc["frozen_schedule"][0].get("remaining_weeks"), 2)
	gone.call("arc.frozen", arc["frozen_schedule"][0], ["remaining_days"])
	expect.call("ev.flag.set_day", mev["flags"]["smoke_v13"].get("set_day"), 4)
	expect.call("ev.timed.expires_on (NO_EXPIRY_DAY)", mev["timed_flags"]["smoke_v13"].get("expires_on"),
		SeedConstants.NO_EXPIRY_DAY)
	expect.call("ev.timed.set_day", mev["timed_flags"]["smoke_v13"].get("set_day"), 3)
	expect.call("ev.stamp.day", mev["stamps"]["smoke_v13"].get("day"), 3)
	expect.call("ev.latch.last_day", mev["latches"]["smoke_v13"].get("last_day"), 5)
	var sched: Dictionary = (mev["schedule"] as Array).back()
	expect.call("ev.schedule.fire_on_day", sched.get("fire_on_day"), 9)
	expect.call("ev.schedule.bound_day", sched["context"]["customer"].get("bound_day"), 4)
	var hist: Dictionary = (mev["rows"] as Array).back()
	expect.call("ev.row.day", hist.get("day"), 4)
	expect.call("ev.row.bound_day", hist["entities"]["customer"].get("bound_day"), 4)
	expect.call("ev.paper.expires_on", mev["papers"][paper_key].get("expires_on"), 7)
	expect.call("ev.paper.admitted_day", mev["papers"][paper_key].get("admitted_day"), 6)
	if not (mev["tempo_window"] as Array).is_empty():
		bad.append("tempo_window kept %d row(s)" % (mev["tempo_window"] as Array).size())
	if not bad.is_empty():
		return done.call("; ".join(bad))

	# --- the migrated world loads and runs a tick --------------------------------
	(mev["arcs"] as Dictionary).erase("smoke_v13")
	if not SaveManager.apply_loaded_state(payload):
		return done.call("apply_loaded_state returned false")
	if GameState.day != 6 or GameState.shutter_weeks_left != 2 \
			or CharacterRegistry.get_character("emp_save").training_weeks_left != 2:
		return done.call("the load did not seat the week values (tick %d, shutter %d)"
			% [GameState.day, GameState.shutter_weeks_left])
	if SprintSystem.is_typed():
		return done.call("a run without a product type opened with a sprint")
	_sim_day_full()
	if GameState.day != 7:
		return done.call("one day from the load reached tick %d, want 7" % GameState.day)
	return done.call("")


## A v12 SAVE FROM BEFORE THE CANCEL-PENALTY, FINAL-COUNTER AND COLD-EXIT FIELDS
## LOADS AND SITS DOWN. Not a hand-written fixture: a real save is taken with every new field at
## a NON-default value, each key is asserted present in the file (so deleting it cannot be
## vacuous), deleted, and the file goes back through read_slot + apply_loaded_state. What comes
## back must be the declared defaults, and the live offer must open the table at
## E_FALLBACK_CONV_SERIES_A + fit. The fit is read, never hard-coded, so the case does not care
## how a fund's lens is defined. The save is taken on tick 1, the one tick a day stamp and a
## week stamp agree on, so the file reads the same through the v14 migration.
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
	var want_expires: int = sheet.expires_day
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
		pre = "the sheet's expires_day"
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
	# The cancel day was THIS WEEK in the file; had it survived, booking would read cancelled_this_week.
	if VCPitchSystem.meeting_blocked_reason("bosphorus") != "":
		return "booking locked after the load (%s)" % VCPitchSystem.meeting_blocked_reason("bosphorus")

	# --- the offer ---------------------------------------------------------------
	var loaded: TermSheet = VCPitchSystem.sheet_for("anchor")
	if loaded == null:
		return "the live offer did not survive the load"
	if loaded.conviction != -1:
		return "sheet conviction came back %d, want -1 (unstamped)" % loaded.conviction
	# The stored window comes back live and falls due on its own expires_day.
	if loaded.weeks_left(GameState.day) <= 0 or loaded.is_decision_due(GameState.day):
		return "a fresh offer loaded already decision-due (expires tick %d)" % loaded.expires_day
	if not loaded.is_decision_due(loaded.expires_day):
		return "the loaded offer is not decision-due on its own expires_day"

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
	var vs: Dictionary = TermSheetTableSystem.open("anchor", PitchConstants.STAGE_SERIES_A)
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
	TermSheetTableSystem.open("anchor", PitchConstants.STAGE_SERIES_A)
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
	GameState.pending_meeting = {"vc_id": "meridian", "day": GameState.day + TimeModel.ticks(PitchConstants.MEETING_LEAD_WEEKS)}
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
	_park_leave([_make_employee("char_prep_dev", "Prep Dev", HRConstants.ROLE_DEVELOPER)])
	var capacity: int = SprintSystem.capacity()
	if not VCPitchSystem.request_meeting("anchor"):
		return "request refused"
	if not VCPitchSystem.start_prep("anchor", "rakamlar"):
		return "prep refused (should be allowed, 3 days out)"
	if not GameState.get_flag("pitch_prep_active", false):
		return "capacity flag not set"
	# Hazırlık yalnız kurucuyu tutar: canlı ürüne meşgul sayılır, sprintin haftalık puanına
	# dokunmaz (sprint ekibinden yalnız izin ve Ar-Ge düşürür).
	if SprintSystem.capacity() != capacity:
		return "VC prep moved the sprint capacity (%d -> %d)" % [capacity, SprintSystem.capacity()]
	var founder: Character = CharacterRegistry.get_founder()
	if ProductSystem._is_free(founder):
		return "a founder in VC prep still counts as FREE for the live product"
	VCPitchSystem.begin_meeting("anchor")  # consumes the prep focus; the founder is at the table
	if GameState.get_flag("pitch_prep_active", false):
		return "capacity flag not cleared at meeting start"
	if ProductSystem._is_free(founder):
		return "a founder seated at the pitch still counts as FREE for the live product"
	VCPitchSystem.withdraw()
	VCPitchSystem.end_sitting()
	if not ProductSystem._is_free(founder):
		return "the founder stayed busy after the sitting closed"
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
	GameState.shutter_weeks_left = 5  # Kepenk active
	VCPitchSystem.begin_meeting("anchor")
	if not VCPitchSystem.is_active():
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
	# Day 1 carries no category without a mechanic behind it: one row, the phase-1 tools base
	# with nobody on the payroll, 100 %, $50 (the runway calibration).
	if FinanceSystem.starting_daily_burn() != 50:
		return "starting_daily_burn %d, want 50 (baseline calibration moved)" % FinanceSystem.starting_daily_burn()
	if GameState.daily_burn != FinanceSystem.starting_daily_burn():
		return "GameState.daily_burn (%d) does not derive from the breakdown" % GameState.daily_burn
	# servers and service are written by InfraSystem and stay 0 until the product ships;
	# marketing and office are hooks at 0.
	var want_keys: Array = ["salaries", "overtime", "tools", "marketing", "office", "servers", "service"]
	var keys: Array = FinanceSystem.STARTING_BURN_BREAKDOWN.keys()
	if keys.size() != want_keys.size():
		return "breakdown holds %d categories, want %d: %s" % [keys.size(), want_keys.size(), str(keys)]
	for key in want_keys:
		if not FinanceSystem.STARTING_BURN_BREAKDOWN.has(key):
			return "breakdown lost category '%s'" % key
		if not FinanceSystem.BURN_IDS.has(key):
			return "category '%s' has no label" % key
	for key in keys:
		var v: int = int(FinanceSystem.STARTING_BURN_BREAKDOWN[key])
		if String(key) == "tools":
			if v != FinanceSystem.daily_rate(FinanceSystem.monthly_tools_for(0)):
				return "day-1 tools %d is not the phase-1 base with nobody on the payroll" % v
		elif v != 0:
			return "category '%s' carries %d with no mechanic behind it (fiction)" % [key, v]
	# Day-1 render contract: one row, tools, 100 % (zero rows are skipped).
	var rows: Array = FinanceSystem.get_burn_breakdown_pct()
	if rows.size() != 1:
		return "day-1 breakdown renders %d rows, want exactly 1: %s" % [rows.size(), str(rows)]
	var row: Dictionary = rows[0]
	if String(row.get("id", "")) != "tools" or int(row.get("pct", 0)) != 100 or int(row.get("amount", 0)) != 50:
		return "day-1 row is not tools/100/50: %s" % str(row)
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
	# One tick's cash delta is seven days of the daily rates, each rounded first:
	# 7 × (round(MRR / 30) − daily burn). MRR 1000 tells the order apart (7 × 33 ≠ 7000 / 30).
	_seed_b2b(1000)
	var cash0: int = GameState.cash
	_sim_day()
	var want: int = TimeModel.DAYS_PER_TICK * (int(round(GameState.mrr / float(TimeModel.DAYS_PER_MONTH)))
		- GameState.daily_burn)
	if GameState.mrr != 1000 or GameState.cash - cash0 != want:
		return "one tick moved cash by %d at MRR %d, burn %d (want %d)" % [
			GameState.cash - cash0, GameState.mrr, GameState.daily_burn, want]
	return ""


## The two burn lines that grow with the company. Tools: the phase base plus the phase rate per
## employee on the payroll, the founder out and people on leave in. Service: B2C per thousand
## users under the load; B2B per account plus seats under the load, plus the phase multiple of
## an account's MRR for its first four ticks; nothing while the product is not live.
##
## FALSIFICATION: count every character in FinanceSystem's tools pull, read `>=` for the
## onboarding window, drop the load factor from the seat term, or drop InfraSystem's is_live
## guard, and the matching assertion fails.
static func _case_burn_tools_and_service() -> String:
	FinanceSystem.daily_tick()
	var base_only: int = FinanceSystem.daily_rate(int(FinanceSystem.TOOLS_BASE_MONTHLY[1]))
	if int(FinanceSystem.get_burn_breakdown()["tools"]) != base_only:
		return "a founder-only company pays %d for tools, want the phase-1 base %d" % [
			int(FinanceSystem.get_burn_breakdown()["tools"]), base_only]
	_make_employee("char_tools_a", "Tools A", HRConstants.ROLE_DEVELOPER)
	var away: Character = _make_employee("char_tools_b", "Tools B", HRConstants.ROLE_DESIGNER)
	CharacterRegistry.set_status(away.id, HRConstants.STATUS_ON_LEAVE)
	for phase in [1, 2, 3]:
		GameState.set_phase(phase)
		FinanceSystem.daily_tick()
		var want_tools: int = FinanceSystem.daily_rate(int(FinanceSystem.TOOLS_BASE_MONTHLY[phase])
			+ 2 * int(FinanceSystem.TOOLS_PER_EMPLOYEE_MONTHLY[phase]))
		var got_tools: int = int(FinanceSystem.get_burn_breakdown()["tools"])
		if got_tools != want_tools:
			return "phase %d tools %d, want %d (two employees, one on leave, founder out)" % [
				phase, got_tools, want_tools]

	GameState.set_phase(2)
	if InfraSystem.monthly_service() != 0:
		return "a product that is not live costs %d in service" % InfraSystem.monthly_service()

	_seed_b2c()
	GameState.set_flag("b2c_audience", 4000.0)
	var want_b2c: int = int(round(4.0 * InfraSystem.SERVICE_PER_1K_USERS_B2C * InfraSystem.load_factor()))
	if InfraSystem.monthly_service() != want_b2c:
		return "4,000 users cost %d in service, want %d" % [InfraSystem.monthly_service(), want_b2c]

	GameState.set_flag("b2c_audience", 0.0)
	_seed_b2b(3000)
	ProductState.set_line_tier("line_note_tool_capture", 3)
	var lf: float = InfraSystem.load_factor()
	if lf <= InfraSystem.LOAD_BASE:
		return "fixture: the heavy step carries no load (%.3f)" % lf
	var c: Customer = CustomerRegistry.get_customer("co_lead_smoke")
	var settled: float = InfraSystem.SERVICE_PER_ACCOUNT_B2B + c.seats * InfraSystem.SERVICE_PER_SEAT_B2B * lf
	for phase in [1, 2, 3]:
		GameState.set_phase(phase)
		var want_b2b: int = int(round(settled + c.mrr * float(InfraSystem.ONBOARDING_MRR_MULT[phase])))
		if InfraSystem.monthly_service() != want_b2b:
			return "phase %d: an onboarding account costs %d in service, want %d" % [
				phase, InfraSystem.monthly_service(), want_b2b]

	# The multiple holds through the account's fourth tick and is gone on the fifth.
	GameState.day = c.onboarding_until - 1
	if InfraSystem.monthly_service() != int(round(settled + c.mrr * float(InfraSystem.ONBOARDING_MRR_MULT[3]))):
		return "the onboarding multiple ended before the account's fourth tick"
	GameState.day = c.onboarding_until
	if InfraSystem.monthly_service() != int(round(settled)):
		return "the onboarding multiple outlived its window (%d, want %d)" % [
			InfraSystem.monthly_service(), int(round(settled))]

	InfraSystem.daily_tick()
	var published: int = int(FinanceSystem.get_burn_breakdown()["service"])
	if published <= 0 or published != FinanceSystem.daily_rate(InfraSystem.monthly_service()):
		return "the service line carries %d, the daily rate is %d" % [
			published, FinanceSystem.daily_rate(InfraSystem.monthly_service())]
	GameState.set_flag("mvp_shipped", false)
	InfraSystem.daily_tick()
	if int(FinanceSystem.get_burn_breakdown()["service"]) != 0:
		return "service still burns %d with the product offline" % int(FinanceSystem.get_burn_breakdown()["service"])
	return ""


## A card's cash goes through Finance's one-time door: a cost lands in the open month's expense
## and the transactions list, income in the transactions list, and each moves the cash once. An
## expiry's cost takes the same door.
##
## FALSIFICATION: put `GameState.set_cash(GameState.cash + amount)` back in EvEffects' add_cash
## and the first assertion fails.
static func _case_add_cash_writes_ledger() -> String:
	GameState.set_cash(20000)
	var expense0: int = int(GameState.month_ledger.get("expense", 0))
	var rows0: int = GameState.transactions.size()
	EvEffects.run_played([{"verb": "add_cash", "amount": -6000, "label": "incident"}], {})
	if int(GameState.month_ledger.get("expense", 0)) != expense0 + 6000:
		return "a card's cost did not reach the month's expense (%d -> %d)" % [
			expense0, int(GameState.month_ledger.get("expense", 0))]
	EvEffects.run_played([{"verb": "add_cash", "amount": 3000, "label": "side_work"}], {})
	EvEffects.run_expire([{"verb": "add_cash", "amount": -500, "label": "refunds"}], {})
	if GameState.cash != 20000 - 6000 + 3000 - 500:
		return "cash is %d, want %d" % [GameState.cash, 20000 - 6000 + 3000 - 500]
	if int(GameState.month_ledger.get("expense", 0)) != expense0 + 6500:
		return "the month's expense is %d, want the two costs only (%d)" % [
			int(GameState.month_ledger.get("expense", 0)), expense0 + 6500]
	var rows: Array = GameState.transactions.slice(rows0)
	var want_rows: Array = [["incident", -6000], ["side_work", 3000], ["refunds", -500]]
	if rows.size() != want_rows.size():
		return "%d transactions rows, want %d: %s" % [rows.size(), want_rows.size(), str(rows)]
	for i in rows.size():
		var row: Dictionary = rows[i]
		if String(row.get("label", "")) != String(want_rows[i][0]) or int(row.get("amount", 0)) != int(want_rows[i][1]):
			return "transactions row %d is %s, want %s" % [i, str(row), str(want_rows[i])]
	return ""


# --- Feature bug-seeding cases ---

# --- Rev3: efor/hız motoru + deterministik eksen case'leri ---

# --- İterasyon döngüsü (player-gated restore) + ekip kalite tavanı ---

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
	var m: float = VCPitchSystem.gross_runway_months()
	if int(round(m)) != 20:
		return "gross months wrong: %.2f (want ~20)" % m
	GameState.set_cash(0)
	if VCPitchSystem.gross_runway_months() != 0.0:
		return "gross at cash 0 should be 0"
	return ""


static func _case_locale_switch() -> String:
	# CSV → TranslationServer resolves per locale (proves the localization layer end-to-end).
	TranslationServer.set_locale("en")
	if TranslationServer.translate("RUNWAY_PROFITABLE") != "Default Alive":
		return "en RUNWAY_PROFITABLE: '%s'" % TranslationServer.translate("RUNWAY_PROFITABLE")
	if TranslationServer.translate("SETTINGS_LANGUAGE") != "Language":
		return "en SETTINGS_LANGUAGE: '%s'" % TranslationServer.translate("SETTINGS_LANGUAGE")
	TranslationServer.set_locale("tr")
	if TranslationServer.translate("RUNWAY_PROFITABLE") != "Artıda":
		return "tr RUNWAY_PROFITABLE: '%s'" % TranslationServer.translate("RUNWAY_PROFITABLE")
	if TranslationServer.translate("SETTINGS_LANGUAGE") != "Dil":
		return "tr SETTINGS_LANGUAGE: '%s'" % TranslationServer.translate("SETTINGS_LANGUAGE")
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
	var edges: Array = []
	var edge_cb := func(_id: String, phase: String) -> void: edges.append(phase)
	EventBus.customer_health_changed.connect(edge_cb)
	var lost0: int = GameState.run_customers_lost
	for i in 60:
		_sim_day()
		if CustomerRegistry.get_customer(c.id) == null:
			break
	EventBus.customer_churned.disconnect(cb)
	EventBus.customer_health_changed.disconnect(edge_cb)
	if edges != ["risk", "churning"]:
		return "customer_health_changed fired off the phase edges: %s" % str(edges)
	if CustomerRegistry.get_customer(c.id) != null:
		return "did not churn after sustained low satisfaction"
	if churned != [c.id]:
		return "customer_churned payload wrong: %s (want [%s])" % [str(churned), c.id]
	if GameState.run_customers_lost != lost0 + 1:
		return "run_customers_lost not incremented (%d -> %d)" % [lost0, GameState.run_customers_lost]
	return ""


static func _case_b2b_satisfaction_leaves_b2c_identical() -> String:
	# Regression guard: with a B2B account beside it, the B2C aggregate still moves by its own
	# drift rule and nothing else, and the B2B account is not dragged through that rule (it is
	# owned by the two-layer B2B model).
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
	# Product whose experience score sits well above the seeded record: a definite drift.
	GameState.set_flag("mvp_stability", 200.0)
	GameState.set_flag("mvp_innovation", 200.0)
	GameState.set_flag("mvp_experience", 200.0)
	GameState.set_flag("mvp_live_bug_count", 0)
	# Expected delta: toward the experience score, capped at a week's step.
	var target: int = int(round(QualityModel.axis_score(QualityModel.economy_dims_from_flags(), "experience")))
	var step: int = int(TimeModel.per_tick(SalesSystem.SATISFACTION_DRIFT_PER_DAY))
	var s0: int = ub.satisfaction
	var want: int = clampi(target - s0, -step, step)
	if want == 0:
		return "test misconfigured: expected a non-zero B2C drift (target %d, satisfaction %d)" % [target, s0]
	_sim_day()
	var got: int = ub.satisfaction - s0
	if got != want:
		return "B2C aggregate satisfaction delta off its drift rule: got %d want %d" % [got, want]
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
	if c2.churn_countdown != cd0 + TimeModel.ticks(B2BConstants.RETAIN_DELAY_WEEKS):
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
	# The real countdown: the product also erodes the healthy twin, and a longer walk churns it.
	CustomerRegistry.set_churn_countdown(c.id, TimeModel.ticks(B2BConstants.CHURN_COUNTDOWN_WEEKS))
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
	# The product stays degraded: a fixed one lifts the account out of Risk on its own inside
	# the week the card's cooldown takes, and there is nothing left to rescue.
	var r: Customer = _add_risk_b2b("ir", 1000)
	if not EventGate.request(RETAIN_ID, {"customer": r.id}):
		return "the retention card was refused for co_ir"
	EventGate.resolve(RETAIN_ID, "leave_alone")
	if CustomerRegistry.get_customer("co_ir") == null:
		return "rescue target churned on ignore"
	# THE REOPEN NOW COSTS A WEEK, and the week is the finding. `customer.retention` carries a
	# one-week entity cooldown, so the İlgilen button cannot re-open the card the player just
	# answered — that is an undo, not a decision — but the rescue window itself is untouched:
	# the account is still in Risk with its countdown running.
	if EventGate.request(RETAIN_ID, {"customer": r.id}):
		return "the card re-opened the same week it was answered — the latch is not holding"
	GameState.advance_day()
	B2BSalesSystem.daily_tick()
	if not EventGate.request(RETAIN_ID, {"customer": r.id}):
		return "İlgilen could not re-open the card a week later"
	EventGate.resolve(RETAIN_ID, "promise_it")     # Söz ver → recover
	if r.lifecycle_phase == "risk":
		return "İlgilen → Söz ver did not rescue after an earlier ignore"
	return ""


# --- B2B pitch meeting (the sitting end to end, outcome-invariant) ---

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
	GameState.sales_meetings_week.clear()
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
	GameState.sales_meetings_week.clear()
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
	B2BSalesSystem.accept_promise(c.id, "ai_vec_filter", B2BConstants.PROMISE_DEADLINE_WEEKS)
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
	GameState.advance_day()   # one week of erosion; a longer walk floors both twins at 0
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
	m.acquired_on_day = GameState.day - (TimeModel.ticks(B2BConstants.EXPANSION_MATURE_WEEKS) + 1)  # mature
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
	var paper: String = EvLatches.key_of(eid, _ctx_customer(m))
	var desk: Array = EventGate.desk_papers(8)
	var on_desk: bool = false
	for entry in desk:
		if String((entry as Dictionary)["id"]) == paper:
			on_desk = true
			if int((entry as Dictionary)["weeks_left"]) <= 0:
				return "the expansion paper landed with no clock"
	if not on_desk:
		return "the expansion card did not reach the desk (desk: %d paper(s))" % desk.size()
	if EventGate.active_id() == eid:
		return "a paper mounted itself as a modal"
	if not EventGate.open_paper(paper):
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
	# FALSİFİKASYON: EvChips.source_tag'de konuşmacı kontrolünü `has_endgame` dalının ALTINA taşı →
	# ilk iddia FAIL ("MENTOR bekleniyordu, PİYASA geldi").
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
		var got: String = String(EvChips.source_tag(ev).get("text", ""))
		if got != String(probe[2]):
			return "%s: '%s' bekleniyordu, '%s' geldi" % [String(probe[3]), String(probe[2]), got]
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
	# İkinci iddia: her id BENZERSİZ.
	var seen := {}
	for row in UiTokens.TABS:
		var tid: String = String(row.id)
		if seen.has(tid):
			return "TABS'ta yinelenen id: %s" % tid
		seen[tid] = true
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
	# Half a month is two whole weeks. int(round()) of the months rendered "1 ay" or "0 ay";
	# under a month the value is weeks.
	var sub: Dictionary = UiTokens.net_runway_parts(0.5)
	if String(sub.get("value", "")) != "2" \
			or String(sub.get("unit", "")) != TranslationServer.translate("RUNWAY_UNIT_WEEKS"):
		return "half a month of runway renders as '%s %s', want 2 weeks" % [
			str(sub.get("value")), str(sub.get("unit"))]
	if bool(sub.get("positive", false)):
		return "a two-week runway reads as positive"
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
	# The crossing day is driven in two batches rather than one _sim_day_full, for one reason:
	# the assertion below is a claim about two DETERMINISTIC beats, and it is only decidable
	# when the queue is empty when they fire (see the note at the assertion). The hourly
	# pass can drop a random ambient event in first.
	#
	# So: run the hours up to 23:00 as the engine does, answer whatever the hourly pool raised,
	# and only then step into 00:00, whose rollover runs the daily slots that carry the two
	# beats. Nothing about the ordering under test is bypassed — only the unrelated noise is.
	TimeManager.advance_hours(TimeModel.HOURS_PER_DAY - 1 - GameState.current_hour)
	_drain_all_modals()          # the queue is now provably empty
	TimeManager.advance_hours(1)

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
	# The SAME call the modal makes (EventGate.condition_met), not a mirror of it.
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
	# Frank's line about being one person: once, the card's delay after the money, and only
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
	# The delay is the card's own condition — `funding.angel_weeks_since_accept >= n` — so the
	# number is read off the card rather than off a system constant. Nothing arrives before it.
	for i in TimeModel.ticks(_card_literal(NUDGE_ID, "funding.angel_weeks_since_accept")):
		if _instances_of(NUDGE_ID) != 0:
			return "the nudge fired before its delay elapsed (tick %d)" % GameState.day
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
			return "the nudge repeated on tick %d" % GameState.day
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
	B2BSalesSystem.accept_promise(c.id, c.pain_feature_id, B2BConstants.PROMISE_DEADLINE_WEEKS)
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
		n += _instances_of(id) + EvPapers.keys_of(id).size()
	return n


## Has this card fired at all this run? Replaces every `get_flag("<something>_shown")` read
## the old hand-rolled latches made possible — the latch is the engine's now, so the question
## is asked of the engine.
static func _card_fired(event_id: String) -> bool:
	return EvLatches.fires(EvLatches.key_for(event_id, EvLatches.KEY_RUN, "")) > 0


## The literal a card's condition compares a seam against. Card JSON cannot read a constant, so
## a case reads the number off the card and holds it to the constant it stands for. −1: absent.
static func _card_literal(card_id: String, seam: String) -> int:
	for leaf in EventGate.condition_leaves(
			EventGate.catalogue_card(card_id).get("condition", {})):
		if String((leaf as Dictionary).get("seam", "")) == seam:
			return int((leaf as Dictionary).get("value", 0))
	return -1


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
	# running straight through the delivery.
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
	# first ONBOARDING_WEEKS left the window early while _tick_satisfaction kept amplifying
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
	# The promotion test is MONOTONE (day - acquired_on_day >= MATURE_WEEKS) and
	# BOTH resolutions used to put the account straight back to "active" — the exact state
	# that predicate passes — so the identical modal re-fired every morning forever and
	# "Büyüt" was an unbounded free MRR faucet for one click a day.
	# FAILS against the pre-fix engine on the first re-tick, on BOTH branches.
	GameState.set_flag("mvp_sub_product_type_id", "saas_ops")
	_seed_b2b(1000)

	# --- Branch 1: ACCEPT ---
	var c: Customer = CustomerRegistry.get_customer("co_lead_smoke")
	c.acquired_on_day = GameState.day - (TimeModel.ticks(B2BConstants.EXPANSION_MATURE_WEEKS) + 1)
	CustomerRegistry.set_lifecycle_phase(c.id, "active")
	CustomerRegistry.set_satisfaction(c.id, 80)
	# A PAPER, not a modal — see _case_b2b_expansion_moves_seats_mrr_counter for the why. The
	# gate is asked the same question either way; what changed is the surface it lands on.
	var eid: String = EXPANSION_ID
	GameState.advance_day()
	B2BSalesSystem.daily_tick()
	if not EventGate.request(eid, {"customer": c.id}):
		return "expansion never offered"
	var paper: String = EvLatches.key_of(eid, _ctx_customer(c))
	if not EventGate.open_paper(paper):
		return "the expansion paper would not open"
	EventGate.resolve(eid, "expand")
	var mrr_after_upsell: int = c.mrr
	for i in 6:
		GameState.advance_day()
		B2BSalesSystem.daily_tick()
		if EventGate.active_id() == eid or _instances_of(eid) > 0 or EvPapers.has(paper):
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
	d.acquired_on_day = GameState.day - (TimeModel.ticks(B2BConstants.EXPANSION_MATURE_WEEKS) + 1)
	CustomerRegistry.set_lifecycle_phase(d.id, "active")
	CustomerRegistry.set_satisfaction(d.id, 80)
	# ONE card id for the whole family; the entity latch makes each account's offer its own
	# instance, with its own paper on the desk.
	var did: String = EXPANSION_ID
	GameState.advance_day()
	B2BSalesSystem.daily_tick()
	if not EventGate.request(did, {"customer": d.id}):
		return "expansion never offered to the second account"
	var d_paper: String = EvLatches.key_of(did, _ctx_customer(d))
	if not EventGate.open_paper(d_paper):
		return "the second account's expansion paper would not open"
	EventGate.resolve(did, "not_yet")
	for i in 6:
		GameState.advance_day()
		B2BSalesSystem.daily_tick()
		if EventGate.active_id() == did or _instances_of(did) > 0 or EvPapers.has(d_paper):
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
	HRSystem.founder_in_meeting = true
	if SupportSystem.founder_passive_care():
		return "a founder in a sales meeting still read as looking after customers"
	HRSystem.founder_in_meeting = false

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


## F4 — A SUMMARY WITH NO ROWS SUMMARISES NOTHING. §7.3 asks for the week's CLOSES: the week's
## rows come out of Sales (`SalesLedger.close_week`), one per close, each with what the report's
## table reads, and the window resets.
## FALSIFICATION: drop the seats from record_close's row and the row check fails; skip the reset
## in close_week and the last check fails.
static func _case_hotfix_weekly_summary_rows() -> String:
	GameState.set_flag("mvp_shipped", true)
	GameState.set_flag("mvp_market_type", "b2b")
	if not SalesLedger.close_week().is_empty():
		return "a week with no closes produced rows"
	var lead := Prospect.new()
	lead.id = "wk_1"
	lead.company_name = "Hafta Corp"
	lead.industry = "testing"
	lead.star = 2
	var c: Customer = _sign_fixture(lead, 1200, 70)
	if c == null:
		return "the fixture did not sign"
	SalesLedger.record_close(c, "Burak Şahin")
	var week: Array = SalesLedger.close_week()
	if week.size() != 1:
		return "a week with one close returned %d rows" % week.size()
	var row: Dictionary = week[0]
	if String(row.company) != "Hafta Corp":
		return "the week's close did not name its account"
	if int(row.seats) != c.seats or int(row.star) != c.scale or int(row.mrr) != c.mrr \
			or int(row.price) != c.seat_price:
		return "the row did not carry the account's seats, star, price and MRR: %s" % str(row)
	# The window resets, or the next week reports this week's work again.
	if not SalesLedger.close_week().is_empty():
		return "an empty week reported closes"
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
	var left0: int = mine.weeks_left()
	GameState.advance_day()
	B2BSalesSystem.daily_tick()
	if ProspectRegistry.get_prospect("reserved") != null \
			and ProspectRegistry.get_prospect("reserved").weeks_left() >= left0:
		return "reserving froze the lead's counter"
	# Control: an unrouted sibling IS picked, so the skip is the reservation and nothing else.
	# The tick's faucet leads are set aside first: a higher star would outrank the sibling.
	for other in ProspectRegistry.get_all():
		if other.id != mine.id:
			ProspectRegistry.remove(other.id)
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


## Instances keyed by EvLatches.key_of. A's signal re-ask is not queued beside A's paper, and
## the Sales tab asking for A opens that paper; B's and C's cards neither absorb each other nor
## take A's paper off the desk; two papers of one card survive a save, including a save that
## keyed its desk by card id. FALSIFICATION: key EvQueue by event_id again, drop _admit's desk
## check, or take request()'s open-paper path out, and the case fails.
static func _case_event_instance_per_subject() -> String:
	_seed_b2b(500)
	var a: Customer = _add_risk_b2b("inst_a", 800)
	# A's card, demoted to the desk earlier; A's Risk edge is still buffered, so the drain re-asks A.
	EvPapers.place(RETAIN_ID, _ctx_customer(a), 1)
	var b: Customer = _add_risk_b2b("inst_b", 900)
	EventGate.hourly_tick(GameState.current_hour)
	if _instances_of(RETAIN_ID) != 1:
		return "the signal drain raised %d retention card(s), want B's alone" \
			% _instances_of(RETAIN_ID)
	var c: Customer = _add_risk_b2b("inst_c", 700)
	if not EventGate.request(RETAIN_ID, {"customer": c.id}) or _instances_of(RETAIN_ID) != 2:
		return "C's card was absorbed by B's (%d instance(s))" % _instances_of(RETAIN_ID)
	EventGate.resolve(RETAIN_ID, "leave_alone")
	EventGate.resolve(RETAIN_ID, "leave_alone")
	if EventGate.desk_papers(8).size() != 1:
		return "answering B's and C's cards took A's paper off the desk"
	if not EventGate.request(RETAIN_ID, {"customer": a.id}) or EventGate.active_id() != RETAIN_ID \
			or EventGate.queue_size() != 0:
		return "asking for A did not open A's paper"
	EventGate.resolve(RETAIN_ID, "leave_alone")
	if not EventGate.desk_papers(8).is_empty():
		return "answering A's paper left it on the desk"
	EvPapers.place(RETAIN_ID, _ctx_customer(b), 1)
	EvPapers.place(RETAIN_ID, _ctx_customer(c), 1)
	var block: Dictionary = JSON.parse_string(JSON.stringify(EvSave.to_dict()))
	EvSave.from_dict(block)
	if EventGate.desk_papers(8).size() != 2:
		return "a save kept %d of the two papers" % EventGate.desk_papers(8).size()
	var legacy: Dictionary = (block["papers"] as Dictionary).values()[0]
	legacy.erase("event_id")
	block["papers"] = {RETAIN_ID: legacy}
	EvSave.from_dict(block)
	if EventGate.desk_papers(8).size() != 1 \
			or not EventGate.open_paper(String(EventGate.desk_papers(8)[0]["id"])):
		return "a paper saved under its card id did not load onto the desk"
	return ""


## §11.4: an opened paper goes back on the desk unanswered. No history row; the paper keeps its
## clock; the signal names it. An interrupt is answered, never put aside.
## FALSIFICATION: record a row in EvEngine.set_aside, or drop its from-desk check, and this fails.
static func _case_event_set_aside_no_history() -> String:
	_seed_b2b(500)
	var a: Customer = _add_risk_b2b("aside_a", 800)
	EvPapers.place(RETAIN_ID, _ctx_customer(a), 2)
	var key: String = String(EventGate.desk_papers(8)[0]["id"])
	var left: int = EvPapers.weeks_left(key)
	var rows: int = EvHistory.rows().size()
	var heard: Array = []
	EventBus.event_set_aside.connect(func(id: String) -> void: heard.append(id))
	if not EventGate.open_paper(key) or not EventGate.set_aside():
		return "the opened paper could not be put aside"
	if EventGate.active_id() != "" or EvHistory.rows().size() != rows:
		return "putting the paper aside answered it (active '%s', %d new row(s))" \
			% [EventGate.active_id(), EvHistory.rows().size() - rows]
	if not EvPapers.has(key) or EvPapers.weeks_left(key) != left:
		return "the paper did not go back on the desk with its clock"
	if heard != [RETAIN_ID]:
		return "event_set_aside carried %s" % str(heard)
	var b: Customer = _add_risk_b2b("aside_b", 900)
	if not EventGate.request(RETAIN_ID, {"customer": b.id}) or EventGate.active_id() != RETAIN_ID:
		return "B's interrupt did not show"
	if EventGate.set_aside() or EventGate.active_id() != RETAIN_ID:
		return "an interrupt was put aside"
	return ""


## A night's save keeps a paper's last warning queued beside the paper, and nothing pumps after a
## load. Answered off the desk, the instance is answered once; put aside, its warning does not come
## straight back; shown by the pump main runs after a load, answering it clears the paper.
## FALSIFICATION: drop EvQueue.take from open_paper and the answered paper shows again.
static func _case_event_no_double_resolution_after_load() -> String:
	_seed_b2b(500)
	var a: Customer = _add_risk_b2b("twice", 800)
	var ctx: Dictionary = _ctx_customer(a)
	EvPapers.place(RETAIN_ID, ctx, 2)
	EvQueue.admit(RETAIN_ID, ctx, "interrupt")   # the warning EvEngine._step_last_warnings queues
	var block: Dictionary = JSON.parse_string(JSON.stringify(EvSave.to_dict()))
	EvSave.from_dict(block)
	var key: String = String(EventGate.desk_papers(8)[0]["id"])
	EventGate.open_paper(key)
	EventGate.resolve(RETAIN_ID, "leave_alone")
	if EventGate.active_id() != "" or EvHistory.chosen_count(RETAIN_ID) != 1:
		return "the paper was answered, then shown again (active '%s', %d answer(s))" \
			% [EventGate.active_id(), EvHistory.chosen_count(RETAIN_ID)]
	EvSave.from_dict(block)
	EventGate.open_paper(key)
	EventGate.set_aside()
	if EventGate.active_id() != "":
		return "the paper's warning came straight back over the set-aside paper"
	EvSave.from_dict(block)
	EventGate.pump()
	if EventGate.active_id() != RETAIN_ID:
		return "the pump after a load showed nothing"
	EventGate.resolve(RETAIN_ID, "leave_alone")
	if EventGate.active_id() != "" or EvHistory.chosen_count(RETAIN_ID) != 1 \
			or not EventGate.desk_papers(8).is_empty():
		return "answering the warning after a load left the paper or a second showing"
	return ""


## §7.1 `names`: a row keeps who it was about. The resignation removes the employee and the
## refusal loses the account, yet both rows read by name, the departure chip too; a desk paper
## keeps its subject's name; the B2C userbase is kept as its key and argument.
## FALSIFICATION: record without `names` in EvEngine.resolve and the first check fails.
static func _case_event_history_names_survive() -> String:
	var e: Character = _make_employee("char_nm", "Selin Kaya", HRConstants.ROLE_TESTER, SEED_PACE, 7000, 22)
	if not EventGate.request("team.resignation", {"employee": e.id}) or not _drain_to("team.resignation"):
		return "the resignation did not show"
	EventGate.resolve("team.resignation", "acknowledge")
	var row: Dictionary = EvHistory.rows()[-1]
	if CharacterRegistry.get_character(e.id) != null \
			or String((row.get("names", {}) as Dictionary).get("employee", "")) != "Selin Kaya":
		return "the resignation row lost the name: %s" % str(row.get("names"))
	var chip: String = EvChips.text(EvChips.describe(row["deltas"][0], row["entities"], row["names"], true)[0])
	if not chip.contains("Selin"):
		return "the departure chip does not name her: '%s'" % chip

	GameState.set_flag("mvp_shipped", true)
	GameState.set_flag("mvp_market_type", "b2b")
	GameState.set_flag("mvp_sub_product_type_id", "ai_vector_search")
	var cs: Character = _make_cs("char_cs_nm", 4, 60)
	var p := Prospect.new()
	p.id = "esc_nm"
	p.company_name = "Ege Sigorta"
	p.industry = "insurance"
	p.star = 1
	p.pain_feature_id = "ai_vec_filter"
	var c: Customer = _sign_fixture(p, 2000, 70)
	CustomerRegistry.assign_customer(c.id, cs.id)
	CustomerRegistry.set_satisfaction(c.id, 20)
	GameState.advance_day()
	B2BSalesSystem.daily_tick()
	EventGate.daily_tick()
	if not _drain_to("customer.cs_escalation"):
		return "the escalation did not show (%s)" % EventGate.active_id()
	EventGate.resolve("customer.cs_escalation", "refuse")
	row = EvHistory.rows()[-1]
	var lost_name: String = EvPresenter.resolve_text("{customer}", row["entities"], row.get("names", {}))
	if CustomerRegistry.get_customer(c.id) != null or lost_name != "Ege Sigorta":
		return "the lost account's row reads '%s'" % lost_name

	var gone: Customer = _add_risk_b2b("paper_nm", 800)
	EvPapers.place(RETAIN_ID, _ctx_customer(gone), 2)
	var key: String = EvLatches.key_of(RETAIN_ID, _ctx_customer(gone))
	CustomerRegistry.remove(gone.id)
	if EvPresenter.resolve_text("{customer}", EvPapers.context_of(key), EvPapers.names_of(key)) != gone.company_name:
		return "the desk paper lost its subject's name"

	_seed_b2c()
	var users: Customer = CustomerRegistry.get_by_market("b2c")[0]
	var kept: Variant = EvPresenter.freeze_names({"customer": {"type": "customer", "id": users.id}})["customer"]
	if not kept is Dictionary or String(kept["key"]) != users.name_key \
			or EvPresenter.name_text(kept) != users.display_name():
		return "the B2C userbase was kept as %s" % str(kept)
	return ""


## A history row's chip reads what the card's chip showed: each delta records the value that
## landed, worked out as the live chip works it out. Sprint hours clamped to the range, an effort
## cut held above the work done, the retention discount and the expansion at the seat price.
## FALSIFICATION: record the requested effort in EvEffects' sprint_card_effort arm, or drop
## `hours` from its sprint_hours delta, and this fails.
static func _case_event_history_chip_matches_live() -> String:
	_seed_sprint()
	SprintCatalog._data.decision.rate = 1.0
	for line_id in SprintCatalog.capabilities("core").slice(0, 2):
		SprintSystem.add("feat:%s_k1" % line_id)
	if not SprintSystem.start():
		return "fixture: the sprint did not start"
	_sim_day()
	SprintCatalog._data.decision.rate = 0.0
	if SprintSystem.mode() != "active" or SprintSystem.decision_card().is_empty():
		return "fixture: no decision waits in a running sprint (%s)" % SprintSystem.mode()
	_seed_b2b(500)
	var ctx: Dictionary = _ctx_customer(_add_risk_b2b("chips", 830))
	var effects: Array = [
		{"verb": "sprint_hours", "mult": 2.0},
		{"verb": "sprint_card_effort", "amount": -99},
		{"verb": "b2b_retain_discount", "scope": "customer"},
		{"verb": "b2b_expand", "scope": "customer"},
	]
	var live: Array = []
	for e in effects:
		live.append(EvChips.text(EvChips.describe(e, ctx, {}, false)[0]))
	var deltas: Array = EvEffects.run_played(effects, ctx)
	for i in effects.size():
		var shown: String = EvChips.text(EvChips.describe(deltas[i], ctx, {}, true)[0])
		if shown != live[i]:
			return "%s: the card showed '%s', its history row reads '%s'" % [effects[i].verb, live[i], shown]
	return ""


## The inbox's own messages survive a real save as keys and numbers: Frank's intro, a period
## summary's payload with its highlight args, and the weekly sales report, whose rows travel
## inside the message. After the load they render the same text. Past CAPACITY the oldest read
## message goes and no unread one does; ids count the kind's messages of the day; a new run
## starts with its own intro only.
## FALSIFICATION: skip `messages` in SaveCodec.capture_game_state and the round trip fails;
## trim without the read check and the unread count fails; drop `messages.clear()` from
## GameState.initialize_run and the second run carries the first run's messages.
static func _case_messages_save_round_trip() -> String:
	if GameState.messages.size() != 1 or GameState.messages[0].kind != "intro":
		return "a new run did not open with Frank's intro: %s" % str(GameState.messages)
	MessageSystem.mark_read(String(GameState.messages[0].id))
	_seed_b2b(500)
	GameState.advance_day()   # on day 1 the anchor below would be 0, which reads as unset
	SalesLedger.record_close(CustomerRegistry.get_by_market("b2b")[0], "Burak Şahin")
	GameState.set_flag("sales_weekly_anchor_day",
		GameState.day - TimeModel.ticks(SalesConstants.WEEKLY_SUMMARY_INTERVAL_WEEKS))
	SalesRepSystem._tick_weekly_summary()
	GameState.submit_month_highlight("GATE_OPENED", {"phase": "Traction"}, 70)
	MessageSystem.post("summary", "MONTH_TITLE", SummarySystem._build_summary_data("monthly", GameState.day))
	if GameState.messages.size() != 3 or String(GameState.messages[1].id) != "sales_week:%d:0" % GameState.day:
		return "fixture: want intro, report and summary, got %s" % str(GameState.messages)
	var before: String = str(GameState.messages)
	var summary: String = str(SummarySystem.display(GameState.messages[2].args))
	if not SaveManager.save_to_slot(SAVE_SLOT_A):
		return "save_to_slot refused"
	if not SaveManager.apply_loaded_state(SaveManager.read_slot(SAVE_SLOT_A)):
		_cleanup_save_slots()
		return "the slot did not load back"
	_cleanup_save_slots()
	if str(GameState.messages) != before:
		return "the messages changed across the save:\n%s\n%s" % [before, str(GameState.messages)]
	if str(SummarySystem.display(GameState.messages[2].args)) != summary:
		return "a loaded summary renders differently"

	for i in MessageSystem.CAPACITY:
		MessageSystem.post("probe", "MONTH_TITLE")
	if GameState.messages.size() != MessageSystem.CAPACITY + 2 or GameState.messages[0].kind != "sales_week":
		return "the trim did not drop only the read intro: %d kept, first %s" \
			% [GameState.messages.size(), GameState.messages[0].kind]
	if String(GameState.messages[-1].id) != "probe:%d:%d" % [GameState.day, MessageSystem.CAPACITY - 1]:
		return "ids do not count the day's messages: %s" % GameState.messages[-1].id

	SaveManager.reset_all_owners()
	GameState.initialize_run({"seed": 7})
	if GameState.messages.size() != 1 or GameState.messages[0].kind != "intro":
		return "a second run did not start with its own intro only: %d messages" % GameState.messages.size()
	return ""


## §7.3 — THE WEEKLY SALES REPORT IS A MESSAGE, NOT A CARD. It never becomes the active card and
## never waits in the queue, so it never blocks the pump: a card raised right after it shows at
## once. It carries the week's rows and the book as they stood; a founder-only week posts nothing.
## FALSIFICATION: raise an info card from _tick_weekly_summary through EventGate.request and the
## engine check fails.
static func _case_sales_weekly_report_is_a_message() -> String:
	_seed_b2b(500)
	GameState.advance_day()   # on day 1 the anchor below would be 0, which reads as unset
	var c: Customer = CustomerRegistry.get_by_market("b2b")[0]
	var interval: int = TimeModel.ticks(SalesConstants.WEEKLY_SUMMARY_INTERVAL_WEEKS)
	SalesLedger.record_close(c, "")
	GameState.set_flag("sales_weekly_anchor_day", GameState.day - interval)
	SalesRepSystem._tick_weekly_summary()
	if GameState.messages.any(func(m: Dictionary) -> bool: return m.kind == "sales_week"):
		return "a founder-only week posted a report"
	SalesLedger.record_close(c, "")
	SalesLedger.record_close(c, "Burak Şahin")
	GameState.set_flag("sales_weekly_anchor_day", GameState.day - interval)
	SalesRepSystem._tick_weekly_summary()
	if EventGate.active_id() != "" or EventGate.queue_size() != 0:
		return "the weekly report reached the event engine (active '%s', %d queued)" \
			% [EventGate.active_id(), EventGate.queue_size()]
	var week: Dictionary = GameState.messages[-1]
	if week.kind != "sales_week" or (week.args.rows as Array).size() != 2 \
			or int(week.args.accounts) != CustomerRegistry.account_count():
		return "the report did not carry the week's two closes and the book: %s" % str(week)
	var e: Character = _make_employee("char_wk_quit", "Selin Kaya", HRConstants.ROLE_TESTER, SEED_PACE, 7000, 22)
	if not EventGate.request("team.resignation", {"employee": e.id}) \
			or EventGate.active_id() != "team.resignation":
		return "a card raised after the report did not show (active '%s')" % EventGate.active_id()
	return ""


## §4.3: a subject the caller named binds or the card is refused. A lost account's churn edge
## drains after the account is removed; the `at_risk` selector must not hand its retention card
## to another account in Risk. FALSIFICATION: let a given slot fall back to its selector.
static func _case_scope_given_subject_gone_refused() -> String:
	_seed_b2b(500)
	var lost: Customer = _add_risk_b2b("lost", 800)
	_add_risk_b2b("other", 900)
	B2BSalesSystem._remove_lost(lost)
	# What the signal drain proposes for that edge.
	var v: EvGate.Verdict = EvGate.propose(RETAIN_ID, EvGate.Origin.SIGNAL, {"customer": lost.id})
	if v.admitted or v.step != "G5":
		return "the lost account's edge was not refused at G5 (step '%s', bound %s)" \
			% [v.step, str(v.context)]
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
		# A lead spawned after the week began gets one more week (SalesFaucetSystem.spawn).
		if p.expires_on_day <= p.spawned_on_day \
				or p.expires_on_day > p.spawned_on_day + TimeModel.ticks(SalesConstants.LEAD_LIFE_WEEKS) + 1:
			return "lead has no honest expiry: spawned %d, expires %d" % [
				p.spawned_on_day, p.expires_on_day]
	return ""


static func _case_b2b_onboarding_to_prospect_visible() -> String:
	# REAL integrated path (NOT the _seed_b2b skip fixture that sets mvp_* flags directly):
	# onboarding payload → the type chosen in the Product tab (market, subtype and subgenre
	# through their seams) → sprints planned with the lead's suggestion until three identity
	# lines reach K1 → Frank's intro beat → add_prospect → spawn_prospect → ProspectRegistry
	# (the source the Sales list renders). Guards the whole spawn chain on the path a fresh
	# game actually takes; the skip-path suite never exercises it.
	GameState.initialize_run({"company_name": "Test Inc.", "founder_name": "Dev"})
	GameState.set_cash(200000)
	SprintSystem.choose_type("erp", "Sahra")
	if GameState.subgenre == "" or GameState.subgenre != ProductCatalog.get_pool_of("erp"):
		return "choose_type did not set subgenre via seam (got %s)" % GameState.subgenre
	if String(GameState.get_flag("mvp_market_type", "")) != "b2b":
		return "mvp_market_type not b2b after choosing the type (%s)" % String(GameState.get_flag("mvp_market_type", ""))
	if String(GameState.get_flag("mvp_sub_product_type_id", "")) != "erp":
		return "mvp_sub_product_type_id not set by the type"
	for i in 40:
		if ProductState.is_live():
			break
		if SprintSystem.mode() == "release":
			SprintSystem.plan_next()
		if SprintSystem.mode() == "plan":
			SprintSystem.apply_lead()
			SprintSystem.start()
		_sim_day()
	if not GameState.get_flag("mvp_shipped", false):
		return "the lead's sprints never shipped the MVP in 40 weeks"
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
	# Price comes from the seat band and the stance dial (§19). What a lead must carry is its
	# star, its archetype and an honest expiry.
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
	SummarySystem.snapshot()
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

	# 6 · §5.5 SÜRE TÜRETİLİR. Metin hafta sayısından çıkar; sabit bir satır olsaydı
	# TRAINING_WEEKS değiştiğinde iki dilde birden yalan söylerdi (§16).
	var duration: String = HRConstants.training_duration_text()
	if duration == "" or duration.begins_with("HR_DURATION_"):
		return "the derived duration text resolved to a raw key: '%s'" % duration
	if not duration.contains(str(HRConstants.TRAINING_WEEKS)):
		return "the duration text '%s' does not read %d weeks" % [duration, HRConstants.TRAINING_WEEKS]
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
	var arrival: int = TimeModel.ticks(HRConstants.SEARCH_ARRIVAL_WEEKS)
	for i in arrival + 3:
		_sim_day()
		if HRSearchSystem.has_files_ready():
			arrived_on = i + 1
			break
	if arrived_on != arrival:
		return "files arrived on tick %d, want %d" % [arrived_on, arrival]
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
		return "hire_day is %d, want the next tick (%d) — full performance from the first week, no ramp" % [
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
	if int(FinanceSystem.get_burn_breakdown().get("salaries", 0)) != int(round(float(salary) / float(TimeModel.DAYS_PER_MONTH))):
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
	for i in TimeModel.ticks(HRConstants.SEARCH_ARRIVAL_WEEKS) + 3:
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
	# One full year served. Tenure reads 0 for hire_day <= 0, so the run is moved past a year.
	GameState.day = TimeModel.ticks(TimeModel.WEEKS_PER_YEAR) + 1
	a.hire_day = GameState.day - TimeModel.ticks(TimeModel.WEEKS_PER_YEAR)
	var want_severance: int = HRConstants.severance_amount(6000, TimeModel.ticks(TimeModel.WEEKS_PER_YEAR))
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
	for i in TimeModel.ticks(HRConstants.RESIGN_WINDOW_MAX_WEEKS) + 4:
		_sim_day()
		if _instances_of(resign_id) >= 1:
			seen = true
			break
		if CharacterRegistry.get_character(e.id) == null:
			return "the employee vanished without a resignation event"
	if not seen:
		return "resignation never fired (risk weeks reached %d, window opens at %d)" % [
			e.flight_risk_weeks, HRConstants.RESIGN_WINDOW_MIN_WEEKS]
	if e.flight_risk_weeks < TimeModel.ticks(HRConstants.RESIGN_WINDOW_MIN_WEEKS):
		return "the roll fired after only %d risk weeks; the window opens at %d" % [
			e.flight_risk_weeks, HRConstants.RESIGN_WINDOW_MIN_WEEKS]
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
	# out of the sprint team, returns after LEAVE_WEEKS with morale refreshed.
	GameState.set_cash(100000)
	var e: Character = _make_employee("char_leave", "Leave Guy", HRConstants.ROLE_DEVELOPER, SEED_PACE, 6000, 60)
	# HERKESİ PARK ET, SONRA YALNIZ BİRİNİ PİNLE. İzin haftası işe alımda damgalanıyor (§11.4),
	# yani kadronun başkaları da aynı haftaya düşebilir ve kapasite düşüşü o zaman iki kişinin
	# düşüşünü ölçerdi.
	_park_leave(CharacterRegistry.get_employees())
	# §11.4: izin YAZ PENCERESİ içinde bir HAFTAdır. Pencerenin (Haziran) ilk tikinin arifesine
	# gidip kişiyi o tikin haftasına (0) pinliyoruz.
	while int(GameState.get_date_dict(GameState.day + 1).month) != HRConstants.LEAVE_WINDOW_START_MONTH:
		_sim_day()
	e.leave_week = 0
	e.leave_taken_year = 0
	var cap0: int = SprintSystem.capacity()
	_sim_day()
	if e.status != HRConstants.STATUS_ON_LEAVE:
		return "leave month reached but status is '%s'" % e.status
	if _sprint_points(e.id) > 0.0 or SprintSystem.capacity() >= cap0:
		return "an on-leave developer still counts toward capacity"
	if CharacterRegistry.count_active_developers() != 0:
		return "an on-leave developer counts as active"
	if CharacterRegistry.count_developers() != 1:
		return "an on-leave developer vanished from the headcount lens"
	FinanceSystem.daily_tick()
	if int(FinanceSystem.get_burn_breakdown().get("salaries", 0)) != int(round(6000.0 / float(TimeModel.DAYS_PER_MONTH))):
		return "paid leave is broken: salary is not charged while on leave"
	var morale_on_leave: int = e.morale
	for i in TimeModel.ticks(HRConstants.LEAVE_WEEKS) + 3:
		_sim_day()
		if e.status == HRConstants.STATUS_ACTIVE:
			break
	if e.status != HRConstants.STATUS_ACTIVE:
		return "never returned from leave after %d ticks" % (TimeModel.ticks(HRConstants.LEAVE_WEEKS) + 3)
	if e.morale <= morale_on_leave:
		return "return from leave did not refresh morale (%d -> %d)" % [morale_on_leave, e.morale]
	if _sprint_points(e.id) <= 0.0:
		return "the returning developer did not rejoin the sprint team"
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
	GameState.set_cash(500000)   # 36 haftalık burn kasayı eritmesin; nakit krizi morale dokunur
	var days: int = 12   # tik; her tik yedi günlük drift
	var expect: int = int(round(TimeModel.per_tick(HRConstants.MORALE_BASE_DRIFT_PER_DAY) * float(days)))

	# --- 8 SAAT: taban hızında erir ---
	var base_emp: Character = _make_employee("drift_base", "Drift Base", HRConstants.ROLE_DEVELOPER,
		SEED_PACE, 0, 60)
	_park_leave([base_emp])
	var before: int = base_emp.morale
	for i in days:
		_sim_day()
	if base_emp.morale != before - expect:
		return "8h drifted %d over %d ticks, want -%d (§7.1 taban)" % [
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
		return "5h moved %d over %d ticks, want +%d (§7.1 ×-1,0)" % [
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
	HRMoraleSystem.send_on_leave(rested, HRConstants.LEAVE_WEEKS, false)
	if rested.status != HRConstants.STATUS_ON_LEAVE:
		return "send_on_leave did not put the employee on leave"
	for i in TimeModel.ticks(HRConstants.LEAVE_WEEKS) + 2:
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
	# that reaches burn; leave takes the person out of the sprint team, refreshes morale
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
	if int(FinanceSystem.get_burn_breakdown().get("salaries", 0)) != int(round(11000.0 / float(TimeModel.DAYS_PER_MONTH))):
		return "the raise did not flow to burn"
	# İzin tek kanaldan gelir, otomatik yıllık izin: biri gider, kapasite düşer, dönüşte moral
	# tazelenir.
	var cap0: int = SprintSystem.capacity()
	HRMoraleSystem.send_on_leave(e, HRConstants.LEAVE_WEEKS, false)
	if e.status != HRConstants.STATUS_ON_LEAVE:
		return "annual leave did not take the employee out of capacity"
	if _sprint_points(e.id) > 0.0 or SprintSystem.capacity() >= cap0:
		return "capacity unchanged during leave"
	if e.leave_taken_year != int(GameState.get_date_dict().year):
		return "the automatic leave did not stamp this year's latch"
	var mv: int = e.morale
	for i in TimeModel.ticks(HRConstants.LEAVE_WEEKS) + 3:
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
	# ABSENT for the sprint team, overtime and CS dampen. One list would be wrong half the time.
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
	var payroll_before: int = CharacterRegistry.get_total_monthly_salaries()
	var team_before: int = CharacterRegistry.get_employees().size()
	HRMoraleSystem.send_on_leave(dev, HRConstants.LEAVE_WEEKS, false)
	HRMoraleSystem.send_on_leave(rep, HRConstants.LEAVE_WEEKS, false)
	# EXCLUDED while away.
	if _sprint_points(dev.id) > 0.0:
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
	# The absent owner reads as `null`, and the ACCOUNT MUST NOT SILENTLY FALL BACK TO THE
	# FOUNDER while its rep is away: an assigned account belongs to the person assigned to it,
	# present or not.
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
	if not is_equal_approx(B2BConstants.cs_dampen(5), 0.725):
		return "UZMANLIK-5 dampen is %.4f, want the old cs_skill-55 value 0.725" % B2BConstants.cs_dampen(5)

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
	var year: int = TimeModel.ticks(TimeModel.WEEKS_PER_YEAR)
	if not is_equal_approx(HRConstants.severance_multiple(year - 1), 1.0 / 3.0) \
			or not is_equal_approx(HRConstants.severance_multiple(2 * year), 2.0):
		return "the severance year rule drifted"
	if HRConstants.raise_morale_gain(HRConstants.RAISE_MAX_PCT) <= HRConstants.raise_morale_gain(HRConstants.RAISE_MIN_PCT):
		return "the raise morale gain does not scale with the percentage"

	# --- §8.2 EK MESAİ ÜCRETİ, SAAT BAŞINA ---
	# "Aşan saatler için SAATLİK ÜCRETİN %50 FAZLASI ödenir (çarpan 1,5×). YALNIZ aşan
	# saatler; ilk sekiz saat normal ücrettir." Blok başına günlük yüzde (%40) modeli gitti.
	var hourly: float = float(9000) / float(HRConstants.HOURS_PER_MONTH)
	var over: int = HRConstants.WORK_HOURS_MAX - HRConstants.WORK_HOURS_DEFAULT
	var want_ot: int = int(round(hourly * float(over) * HRConstants.OVERTIME_WAGE_MULT))
	if HRConstants.overtime_pay_for_day(9000, HRConstants.WORK_HOURS_MAX) != want_ot:
		return "the longest day on 9000 bills %d, want %d (%d hours at 1.5x)" % [
			HRConstants.overtime_pay_for_day(9000, HRConstants.WORK_HOURS_MAX), want_ot, over]
	# İLK SEKİZ SAAT NORMAL ÜCRET: sekizde ve altında tahakkuk YOKTUR.
	if HRConstants.overtime_pay_for_day(9000, HRConstants.WORK_HOURS_DEFAULT) != 0 \
			or HRConstants.overtime_pay_for_day(9000, HRConstants.WORK_HOURS_MIN) != 0:
		return "an eight-hour or shorter day accrued overtime"
	# §8.4 ORAN: sekizin üstündeki her saat yarım verim. 11 saat 1,1875, 16 saat 1,5, 5 saat 0,625.
	if not is_equal_approx(HRConstants.hours_output_mult(11), 1.1875) \
			or not is_equal_approx(HRConstants.hours_output_mult(HRConstants.WORK_HOURS_MAX), 1.5) \
			or not is_equal_approx(HRConstants.hours_output_mult(HRConstants.WORK_HOURS_MIN), 0.625):
		return "the hour-to-output ratio drifted from the diminishing-yield numbers"
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
# The ladder is REAL SECONDS PER IN-GAME HOUR in ONE place (TimeModel.SECONDS_PER_HOUR). These
# cases pin the table and the fact that a tick is the same 24 hourly ticks at every speed: only
# the visible hours cost real time, the night is skipped.

static func _case_speed_ladder() -> String:
	var ladder: Array = TimeModel.SECONDS_PER_HOUR
	var want: Array = [0.0, 10.0, 5.0, 10.0 / 3.0, 2.5]
	if ladder.size() != want.size():
		return "the ladder has %d entries, want %d (pause + 1x/2x/3x/4x)" % [ladder.size(), want.size()]
	for i in ladder.size():
		if not is_equal_approx(float(ladder[i]), float(want[i])):
			return "speed %d is %.3f s/hour, want %.3f" % [i, ladder[i], want[i]]
	# Strictly faster as the index rises (idx 0 is pause, not part of the ordering).
	for i in range(2, ladder.size()):
		if float(ladder[i]) >= float(ladder[i - 1]):
			return "speed %d is not faster than speed %d" % [i, i - 1]

	# Derivation: hours-per-real-second comes from the table, never stored separately.
	if not is_equal_approx(TimeManager.hours_per_real_second(0), 0.0):
		return "pause must accrue no in-game hours"
	for i in range(1, ladder.size()):
		if not is_equal_approx(TimeManager.hours_per_real_second(i), 1.0 / float(ladder[i])):
			return "speed %d multiplier is %.4f, want %.4f" % [i, TimeManager.hours_per_real_second(i), 1.0 / float(ladder[i])]
	# Out-of-range indices must be inert, not crash the accumulator.
	if not is_equal_approx(TimeManager.hours_per_real_second(ladder.size()), 0.0):
		return "an out-of-range speed index returned a live multiplier"

	# Bounds: the top index is accepted, one past it is refused.
	var top: int = ladder.size() - 1
	EventBus.speed_change_requested.emit(top)
	if TimeManager.current_speed != top:
		return "top speed %d was rejected (current %d)" % [top, TimeManager.current_speed]
	EventBus.speed_change_requested.emit(top + 1)
	if TimeManager.current_speed != top:
		return "index %d was accepted (current %d)" % [top + 1, TimeManager.current_speed]

	# Pause/resume round-trip at the top index (speed_preserve covers idx 2).
	EventBus.speed_change_requested.emit(0)
	TimeManager.resume_if_paused()
	if TimeManager.current_speed != top:
		return "paused game did not resume to last_running_speed (%d)" % TimeManager.current_speed
	if TimeManager.get_tree().paused:
		return "tree still paused after resume"
	return ""


## One tick through the real-time clock at speed idx, from the current hour to the next 08:00,
## in frames of 1/100 of an hour: TimeManager._advance_real, the night gate and the night skip.
## Returns the event log (hour values, "D" day_advanced, "T" day_tick_completed), the frame
## count, whether the clock agreed with itself inside the daily tick and whether 08:00 arrived.
## on_frame(out) runs before each frame.
static func _walk_day(idx: int, on_frame: Callable = Callable()) -> Dictionary:
	var out := {"log": [], "frames": 0, "synced": true, "arrived": false}
	var on_hour := func(h: int) -> void: (out["log"] as Array).append(h)
	var on_day := func(_d: int) -> void: (out["log"] as Array).append("D")
	var on_done := func(_d: int) -> void:
		(out["log"] as Array).append("T")
		if not is_equal_approx(TimeManager._in_game_hours, float(GameState.current_hour)):
			out["synced"] = false
	var on_skip := func() -> void: out["arrived"] = true
	EventBus.hour_changed.connect(on_hour)
	EventBus.day_advanced.connect(on_day)
	EventBus.day_tick_completed.connect(on_done)
	EventBus.night_skipped.connect(on_skip)
	EventBus.speed_change_requested.emit(idx)
	var step: float = float(TimeModel.SECONDS_PER_HOUR[idx]) / 100.0
	while not bool(out["arrived"]) and int(out["frames"]) < 5000:
		out["frames"] = int(out["frames"]) + 1
		if on_frame.is_valid():
			on_frame.call(out)
		TimeManager._advance_real(step)
	EventBus.hour_changed.disconnect(on_hour)
	EventBus.day_advanced.disconnect(on_day)
	EventBus.day_tick_completed.disconnect(on_done)
	EventBus.night_skipped.disconnect(on_skip)
	return out


## TICK PURITY at every speed: from 08:00 the hours run 9…23, the rollover at 00:00 carries
## day_advanced and the daily tick, then 1…8; the real time is the visible hours only, (workday
## end − 08:00) × s/hour, within one frame. Variants: a 24:00 workday end, a hold taken inside
## the night skip, and an office that is not empty yet.
static func _case_speed_day_invariant() -> String:
	var want_log: Array = range(9, 24) + [0, "D", "T"] + range(1, 9)
	var base_frames: Dictionary = {}
	for idx in range(1, TimeModel.SECONDS_PER_HOUR.size()):
		if GameState.current_hour != TimeModel.WEEK_START_HOUR:
			return "speed %d did not start at 08:00 (%d)" % [idx, GameState.current_hour]
		var s: float = float(TimeModel.SECONDS_PER_HOUR[idx])
		var want_secs: float = float(WorkHoursSystem.workday_end() - TimeModel.WEEK_START_HOUR) * s
		var w: Dictionary = _walk_day(idx)
		if not bool(w["arrived"]):
			return "speed %d never reached the next 08:00" % idx
		if w["log"] != want_log:
			return "speed %d clock order %s" % [idx, str(w["log"])]
		if not bool(w["synced"]):
			return "speed %d: the accumulator disagreed with the hour inside the daily tick" % idx
		var secs: float = float(w["frames"]) * s / 100.0
		if absf(secs - want_secs) > s / 100.0 + 0.0001:
			return "speed %d took %.3f real s/tick, want %.3f" % [idx, secs, want_secs]
		base_frames[idx] = int(w["frames"])

	# Gate: the office is not empty for K frames; the clock waits at the workday end.
	const K := 5
	var gate_hours: Array = []
	var gate := func() -> bool:
		gate_hours.append(GameState.current_hour)
		return gate_hours.size() > K
	TimeManager.register_night_gate(gate, 10.0)
	var end_hour: int = WorkHoursSystem.workday_end()
	var g: Dictionary = _walk_day(1)
	TimeManager.unregister_night_gate()
	if g["log"] != want_log or int(g["frames"]) != int(base_frames[1]) + K:
		return "gate: log %s, frames %d (want %d)" % [str(g["log"]), int(g["frames"]), int(base_frames[1]) + K]
	if gate_hours.size() != K + 1 or gate_hours.count(end_hour) != K + 1:
		return "gate: the clock moved while the office was not empty (%s)" % str(gate_hours)

	# Hold: a hold taken inside the skip stops it; released, the tick completes all 24 hours.
	var held := {"frames": 0, "hour": -1}
	var on_hour := func(h: int) -> void:
		if h == 3 and held["hour"] < 0:
			held["hour"] = h
			TimeManager.hold_clock("smoke_hold")
	var while_held := func(out: Dictionary) -> void:
		if not TimeManager.is_clock_held():
			return
		if GameState.current_hour != 3 or bool(out["arrived"]):
			held["hour"] = 99
		held["frames"] = int(held["frames"]) + 1
		if int(held["frames"]) == 5:
			TimeManager.release_clock("smoke_hold")
			EventBus.speed_change_requested.emit(1)
	EventBus.hour_changed.connect(on_hour)
	var hold_walk: Dictionary = _walk_day(1, while_held)
	EventBus.hour_changed.disconnect(on_hour)
	if int(held["hour"]) != 3 or int(held["frames"]) != 5:
		return "hold: the skip did not stop at the hold (%s)" % str(held)
	if hold_walk["log"] != want_log:
		return "hold: log after release %s" % str(hold_walk["log"])

	# A workday ending at 24:00: sixteen visible hours, the rollover inside the night skip.
	WorkHoursSystem.set_company_start_hour(TimeModel.WEEK_START_HOUR)
	WorkHoursSystem.set_company_hours(TimeModel.WORKDAY_LATEST_END - TimeModel.WEEK_START_HOUR)
	if WorkHoursSystem.workday_end() != TimeModel.WORKDAY_LATEST_END:
		return "fixture: workday end %d, want 24" % WorkHoursSystem.workday_end()
	var late: Dictionary = _walk_day(1)
	var late_secs: float = float(late["frames"]) * float(TimeModel.SECONDS_PER_HOUR[1]) / 100.0
	var late_want: float = float(TimeModel.WORKDAY_LATEST_END - TimeModel.WEEK_START_HOUR) \
		* float(TimeModel.SECONDS_PER_HOUR[1])
	if late["log"] != want_log or not bool(late["synced"]):
		return "24:00 end: clock order %s" % str(late["log"])
	if absf(late_secs - late_want) > float(TimeModel.SECONDS_PER_HOUR[1]) / 100.0 + 0.0001:
		return "24:00 end took %.3f real s, want %.3f" % [late_secs, late_want]
	return ""


# ============================================================================
#  Product×HR Coupling (task 2 of 3) — the axes now DO something. Task 1 proved
#  nothing moved; these prove the right things move, and that the two hard
#  equivalence anchors survived the rescale exactly.
# ============================================================================

static func _case_coupling_wear_team_average() -> String:
	# Post-ship wear follows the SAME grammar as bug — the founder-only read is gone.
	_seed_live_product()
	var founder: Character = CharacterRegistry.get_founder()
	_set_founder_tech(6)
	# The audience must be big enough to keep the wear rate OFF WEAR_FLOOR in BOTH arms —
	# otherwise both clamp to the floor and read identical, which says nothing about the
	# expertise term. It is sized from the coefficient: 0.04 an hour of user wear, more than
	# the founder's Test 6 takes off.
	var audience: float = 0.04 / ProductSystem.WEAR_AUD_COEF
	GameState.set_flag("b2c_audience", audience)
	GameState.set_flag("mvp_live_bug_count", 0)
	GameState.set_flag("mvp_live_bug_progress", 0.0)
	# Wear with the founder alone, over a day of live product.
	for h in 24:
		ProductSystem.hourly_tick(h)
	var solo_wear: float = float(GameState.get_flag("mvp_live_bug_progress", 0.0)) \
		+ float(int(GameState.get_flag("mvp_live_bug_count", 0)))
	if solo_wear <= 0.0:
		return "live product did not wear at all — case window invalid"
	if absf(solo_wear - TimeModel.per_tick(24.0 * ProductSystem.WEAR_FLOOR)) < 0.0001:
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
	GameState.set_flag("b2c_audience", audience)
	GameState.set_flag("mvp_live_bug_count", 0)
	GameState.set_flag("mvp_live_bug_progress", 0.0)
	for h in 24:
		ProductSystem.hourly_tick(h)
	var team_wear: float = float(GameState.get_flag("mvp_live_bug_progress", 0.0)) \
		+ float(int(GameState.get_flag("mvp_live_bug_count", 0)))
	if team_wear >= solo_wear:
		return "a strong developer did not slow live-product wear (%.4f -> %.4f)" % [solo_wear, team_wear]
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
	# One tick longer than a faucet lead: cases drive the desk across the next tick boundary and
	# read the lead after it, where a faucet lead would already have expired.
	p.expires_on_day = GameState.day + TimeModel.ticks(SalesConstants.LEAD_LIFE_WEEKS) + 1
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
	var base: float = SalesConstants.FAUCET_BASE_PER_WEEK * mult
	if not is_equal_approx(SalesFaucetSystem.lead_rate_per_week(), base):
		return "base inbound %f with no sales staff, want %f" % [
			SalesFaucetSystem.lead_rate_per_week(), base]
	if base <= 0.0:
		return "the faucet is dry with no sales staff — §3 says the base inbound continues"
	var before: int = ProspectRegistry.count()
	for i in 10:
		GameState.advance_day()
		B2BSalesSystem.daily_tick()
	if ProspectRegistry.count() <= before:
		return "no leads arrived over ten ticks with the base inbound running"

	# An ASSIGNED rep raises the flow by exactly one rep's worth (§3: +2/week).
	_make_sales_rep("char_sr_1", 6, 1)
	var want: float = (SalesConstants.FAUCET_BASE_PER_WEEK + SalesConstants.FAUCET_PER_REP_PER_WEEK) * mult
	if not is_equal_approx(SalesFaucetSystem.lead_rate_per_week(), want):
		return "rate with one rep %f, want %f" % [SalesFaucetSystem.lead_rate_per_week(), want]
	return ""

static func _case_sales_pipeline_stack_diminishes() -> String:
	# THE STACK DECAY IS RETIRED and this case guards what replaced it. §3 makes the faucet
	# LINEAR in assigned capacity (+2/week each) because supply is now a market reading
	# rather than a crowded queue; the anti-burst rule is a PER-TICK CAP, which is the
	# thing that still has to hold. FALSIFICATION: remove FAUCET_TICK_MAX and the second
	# half fails — twenty reps' flow releases in one week.
	GameState.set_flag("mvp_shipped", true)
	GameState.set_flag("mvp_market_type", "b2b")
	GameState.set_flag("mvp_sub_product_type_id", "ai_vector_search")
	_seed_b2b(1000)
	_make_sales_rep("char_sr_1", 6, 1)
	var one: float = SalesFaucetSystem.lead_rate_per_week()
	_make_sales_rep("char_sr_2", 6, 1)
	var two: float = SalesFaucetSystem.lead_rate_per_week()
	var step: float = SalesConstants.FAUCET_PER_REP_PER_WEEK \
		* SalesConstants.interest_mult(ProductRead.interest()) \
		* SalesConstants.phase_mult(GameState.phase)
	if not is_equal_approx(two - one, step):
		return "a second rep added %f, want one rep's worth %f" % [two - one, step]
	# The tick cap holds however much flow comes in.
	GameState.set_flag("sales_faucet_progress", 0.99)
	for i in 20:
		_make_sales_rep("char_sr_x%d" % i, 9, 1)
	var before: int = ProspectRegistry.count()
	GameState.advance_day()
	B2BSalesSystem.daily_tick()
	var emitted: int = ProspectRegistry.count() - before
	if emitted > SalesConstants.FAUCET_TICK_MAX:
		return "%d leads in one tick, cap is %d" % [emitted, SalesConstants.FAUCET_TICK_MAX]
	return ""

static func _case_sales_autonomous_close_routine() -> String:
	# §7.6 — a deal two leagues below the rep always closes on its first processing tick (the
	# tick after the rep picks it up). The deal closes at the DIAL's price (§7.5), names the
	# closer, and logs. FALSIFICATION: against the old desk the price assertion fails — it
	# placed the deal inside an archetype MRR band and never read a stance.
	GameState.set_flag("mvp_shipped", true)
	GameState.set_flag("mvp_market_type", "b2b")
	GameState.set_flag("mvp_sub_product_type_id", "ai_vector_search")
	_seed_b2b(1000)
	var rep: Character = _make_sales_rep("char_sr_1", 0, 9)   # Satış 9 -> star 4, band 1..3
	SalesLedger.set_price_stance(SalesConstants.STANCE_STANDARD)
	# Handed to the rep, so the faucet's own leads of the same tick do not outrank it.
	SalesLedger.set_routing(_add_prospect("routine", 1, "ai_vec_filter").id, SalesConstants.ROUTE_REP)
	var signed0: int = GameState.run_customers_signed
	var closed: bool = false
	var started: int = -1
	for i in 40:
		GameState.advance_day()
		B2BSalesSystem.daily_tick()
		var lead: Prospect = ProspectRegistry.get_prospect("routine")
		if lead == null:
			closed = true
			break
		if lead.is_being_worked():
			started = lead.work_started_day
	if not closed:
		return "an in-league lead never closed"
	if started < 0 or GameState.day != started + 1:
		return "a two-below deal took until tick %d, work started on %d" % [GameState.day, started]
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
	# The same tick's faucet expiries log after the desk, so the close is looked up, not taken
	# as the last line.
	for row in SalesSystem.get_sales_log():
		var r: Dictionary = row as Dictionary
		if String(r.get("kind", "")) == "auto_close" and String(r.get("company", "")) == c.company_name:
			if String(r.get("actor", "")) != rep.character_name:
				return "activity line does not name who closed it: %s" % str(r)
			return ""
	return "the close produced no activity-log line"

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
	# INSIDE THE LEAD'S LIFE. A longer walk would let §4's expiry take the lead and the case
	# would then read "gone" as "closed" — a false pass in one direction and a false failure
	# in the other. A rep that could take this table would have started on the first tick.
	for i in TimeModel.ticks(SalesConstants.LEAD_LIFE_WEEKS):
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
	# price-sensitive archetype the desk publishes `rep_discount_requested` before a processing
	# roll; it does NOT raise the card, because §18 puts that wiring in the event package.
	# The deal must still close at its own stance: an unwired card cannot be allowed to
	# strand a finished deal. FALSIFICATION: make the card fire and the fourth branch fails.
	GameState.set_flag("mvp_shipped", true)
	GameState.set_flag("mvp_market_type", "b2b")
	GameState.set_flag("mvp_sub_product_type_id", "ai_vector_search")
	_seed_b2b(1000)
	_make_sales_rep("char_sr_1", 0, 9)
	SalesLedger.set_price_stance(SalesConstants.STANCE_PREMIUM)
	# A price-sensitive archetype, handed to the rep so the faucet's leads do not outrank it.
	SalesLedger.set_routing(_add_prospect("premium", 1, "ai_vec_filter", "ops_cautious").id,
		SalesConstants.ROUTE_REP)
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
	if SalesRepSystem.price_break_due(insensitive):
		return "a price-INSENSITIVE archetype produced the price-break moment"
	return ""

static func _case_sales_close_speed_by_expertise() -> String:
	# §7.2 — a worked deal closes on each processing tick with a chance the LEAGUE DIFFERENCE
	# picks (SalesConstants.PROCESS_CLOSE_CHANCE), and Premium divides it (§7.5), so the
	# expected processing time grows by the same +30 %. A stronger seller sits more leagues
	# above the same lead and closes it sooner.
	GameState.set_flag("mvp_shipped", true)
	GameState.set_flag("mvp_market_type", "b2b")
	GameState.set_flag("mvp_sub_product_type_id", "ai_vector_search")
	_seed_b2b(1000)
	var weak: Character = _make_sales_rep("char_sr_weak", 0, 4)
	var strong: Character = _make_sales_rep("char_sr_strong", 0, 9)
	var own_star: int = SalesRepSystem.rep_star(weak)
	if SalesRepSystem.rep_star(strong) - own_star < 2:
		return "fixture: the strong rep is not two leagues above the weak one"
	var lead: Prospect = _add_prospect("span", own_star, "ai_vec_filter")
	lead.work_stance = SalesConstants.STANCE_STANDARD
	var own: float = SalesRepSystem.close_chance(weak, lead)
	var below: float = SalesRepSystem.close_chance(strong, lead)
	if not is_equal_approx(own, float(SalesConstants.PROCESS_CLOSE_CHANCE[0])) \
			or not is_equal_approx(below, float(SalesConstants.PROCESS_CLOSE_CHANCE[-2])):
		return "close chances own %.2f / two below %.2f do not read the league table" % [own, below]
	if below <= own:
		return "a stronger seller did not close the same lead sooner (%.2f -> %.2f)" % [own, below]
	lead.work_stance = SalesConstants.STANCE_PREMIUM
	if not is_equal_approx(SalesRepSystem.close_chance(strong, lead),
			below / (1.0 + SalesConstants.PROCESS_PREMIUM_PENALTY)):
		return "Premium did not divide the chance (%.3f)" % SalesRepSystem.close_chance(strong, lead)
	ProspectRegistry.remove(lead.id)

	# THE ROLL, through the desk's own sweep on the seeded stream: 1000 own-league deals close
	# after 1 / chance processing ticks on average (2 at 0.50).
	var n: int = 1000
	for i in n:
		var p: Prospect = _add_prospect("own_%d" % i, own_star, "ai_vec_filter")
		p.worked_by = weak.id
		p.work_started_day = GameState.day
		p.work_stance = SalesConstants.STANCE_STANDARD
	var open: int = ProspectRegistry.count()
	var tick_sum: int = 0
	for t in range(1, 60):
		GameState.day += 1
		SalesRepSystem._tick_processing()
		tick_sum += (open - ProspectRegistry.count()) * t
		open = ProspectRegistry.count()
		if open == 0:
			break
	var mean: float = float(tick_sum) / float(n)
	var want: float = 1.0 / float(SalesConstants.PROCESS_CLOSE_CHANCE[0])
	if open != 0 or absf(mean - want) > 0.15:
		return "own-league deals closed after %.3f ticks on average, want %.2f (%d still open)" % [
			mean, want, open]
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
	# Fix 4: 90 simulated ticks on the ISOLATED driver (advance_day + explicit feed tick —
	# full dispatch would drag phase gates/endings into a feed test; same rationale as the
	# 2b additivity case). Asserts the source distribution (sektör ~50%, biz hard-capped
	# at 20%), the no-repeat-until-reshuffle contract, and the stream cap. Writes the
	# line-by-line audit to user://news_feed_audit_90d.txt — stdout stays one SMOKE line.
	GameState.set_flag("mvp_sub_product_type_id", "ai_vector_search")
	_seed_b2b(1500)
	var audit: Array[String] = []
	var sektor_seen: Dictionary = {}     # txt -> true, cleared at each observed reshuffle
	var ticks: int = 90
	for i in ticks:
		GameState.advance_day()
		# "Biz" injections through the real channel (TimeManager._ready wired the feed).
		# EVERY TICK on purpose: with surplus supply the hard cap is what limits the source,
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
	if total < float(ticks * NewsFeedSystem.WEEKLY_LINES_MIN):
		return "only %d lines over %d ticks" % [int(total), ticks]
	var sektor_frac: float = float(counts["sektor"]) / total
	var rakip_frac: float = float(counts["rakip"]) / total
	var biz_frac: float = float(counts["biz"]) / total
	if biz_frac > NewsFeedSystem.BIZ_HARD_CAP + 0.01:
		return "biz source broke the hard cap: %.3f" % biz_frac
	if sektor_frac < 0.40 or sektor_frac > 0.62:
		return "sektor share off band: %.3f" % sektor_frac
	if int(counts["rakip"]) == 0:
		return "rival source never fired over %d ticks" % ticks
	if (GameState.news_feed["stream"] as Array).size() > NewsFeedSystem.STREAM_CAP:
		return "stream exceeded its cap"
	# Audit report for the done message (distribution header + every line).
	var f: FileAccess = FileAccess.open("user://news_feed_audit_90d.txt", FileAccess.WRITE)
	if f != null:
		f.store_line("ticks=%d total=%d sektor=%.3f rakip=%.3f biz=%.3f reshuffles=%d" % [
			ticks, int(total), sektor_frac, rakip_frac, biz_frac, int(GameState.news_feed["reshuffles"])])
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
	if CustomerRepSystem.pick_request_kind(a) != B2BConstants.CS_KIND_COMPLAINT:
		return "unhappy broken-promise account did not complain (got %s)" % CustomerRepSystem.pick_request_kind(a)
	# B — sağlıklı + karşılanmamış acı özelliği → özellik talebi.
	var b := Customer.new()
	b.id = "co_state_b"
	b.company_name = "Durum B"
	b.industry = "finance"
	b.satisfaction = 85
	b.tolerance = 40
	b.acquired_on_day = GameState.day
	b.pain_feature_id = "ai_vec_filter"
	if CustomerRepSystem.pick_request_kind(b) != B2BConstants.CS_KIND_FEATURE:
		return "healthy unmet-pain account did not ask for the feature (got %s)" % CustomerRepSystem.pick_request_kind(b)
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
	if CustomerRepSystem.pick_request_kind(c) != B2BConstants.CS_KIND_RENEWAL:
		return "long-tenure account did not reach renewal (got %s)" % CustomerRepSystem.pick_request_kind(c)
	# No-repeat korunuyor: A az önce şikâyet açtıysa bir daha şikâyet açamaz.
	a.last_request_kind = B2BConstants.CS_KIND_COMPLAINT
	if CustomerRepSystem.pick_request_kind(a) == B2BConstants.CS_KIND_COMPLAINT:
		return "no-repeat rule broken by the state scorer"
	# Determinizm: aynı durum + aynı gün → aynı sonuç.
	if CustomerRepSystem.pick_request_kind(b) != CustomerRepSystem.pick_request_kind(b):
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
	aged.acquired_on_day = GameState.day - (TimeModel.ticks(B2BConstants.EXPANSION_MATURE_WEEKS) + 1)
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
		if EvPapers.event_id_of(String((row as Dictionary)["id"])) == EXPANSION_ID:
			entry = row
	if entry.is_empty():
		_cleanup_save_slots()
		return "the paper did not survive the round-trip (desk: %d)" % desk.size()
	if int(entry["weeks_left"]) <= 0:
		_cleanup_save_slots()
		return "the paper came back with no clock (%d)" % int(entry["weeks_left"])
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
	SprintSystem.choose_type("erp", "Sahra")
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
	SprintSystem.apply_lead()
	if GameState.product.sprint.cards.is_empty():
		_cleanup_save_slots()
		return "fixture: the lead planned nothing to leave behind"

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
	if not GameState.product.sprint.cards.is_empty():
		_cleanup_save_slots()
		return "a sprint plan made between loads survived the second load"
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

	_cleanup_save_slots()
	return ""


# --- Looks: one per person, everyone apart, Frank's his alone, kept by a save, redrawn the same
# for an old one, drawn again on load where an old one wears Frank's ---
static func _case_look_registry_unique_and_saved() -> String:
	# A portrait past the first, so the founder cannot pass on the not-found fallback.
	var portrait: String = FounderConstants.PORTRAIT_IDS[2]
	CharacterRegistry.reset()
	GameState.initialize_run({"seed": 424242, "portrait_id": portrait})
	# Read afresh each time: a load builds new records.
	var people := func() -> Array:
		return [CharacterRegistry.get_founder()] + CharacterRegistry.get_employees()
	var looks := func() -> Dictionary:
		var out := {}
		for c in people.call():
			out[c.id] = LookSystem.signature(c.look)
		return out

	var founder_sig: String = LookSystem.signature(CharacterRegistry.get_founder().look)
	if founder_sig != LookSystem.signature(LookSystem.founder(portrait)):
		return "the founder does not wear the look of portrait %s" % portrait
	if not GameState.issued_looks.has(founder_sig):
		return "the founder's look was not registered as issued"

	var first: Array = HRConstants.FIRST_NAMES
	var last: Array = HRConstants.LAST_NAMES
	var roles: Array = HRConstants.EMPLOYEE_ROLES
	for i in 70:
		_make_employee("emp_look_%d" % i, "%s %s" % [first[i % first.size()], last[i % last.size()]], roles[i % roles.size()])
	var crowd: Array = people.call()
	if crowd.any(func(c: Character) -> bool: return c.look.is_empty()):
		return "an employee was added without a look"
	var sigs: Array = looks.call().values()
	# Apart in two slots also means no two share a signature.
	for i in crowd.size():
		for j in range(i + 1, crowd.size()):
			var gap: int = LookSystem.apart(crowd[i].look, crowd[j].look)
			if gap < LookSystem.MIN_APART:
				return "%s and %s differ in %d glance slots, want %d" % [crowd[i].id, crowd[j].id, gap, LookSystem.MIN_APART]
	if GameState.issued_looks.size() != sigs.size() \
			or sigs.any(func(s: String) -> bool: return GameState.issued_looks.count(s) != 1):
		return "issued_looks holds %d entries, want each of the %d looks once" % [GameState.issued_looks.size(), sigs.size()]

	# A draw that lands on Frank's hair on a bearded head is drawn again: the team, the candidates
	# and the funds' people all draw through LookSystem._unique.
	var landing := 0
	while not LookSystem.is_franks(LookSystem._make(landing, HRConstants.ROLE_SALES_REP, "m")):
		landing += 1
	if LookSystem.is_franks(LookSystem._unique(landing, HRConstants.ROLE_SALES_REP, "m", [])):
		return "a draw from seed %d kept Frank's look" % landing
	var funds: Array = GameState.investor_people.values().reduce(func(all: Array, side: Array) -> Array:
		return all + side, [])
	if crowd.any(func(c: Character) -> bool: return LookSystem.is_franks(c.look)) \
			or funds.any(func(q: Dictionary) -> bool: return LookSystem.is_franks(q.look)):
		return "someone in the office or across the table wears Frank's look"

	var saved: Dictionary = looks.call()
	var issued: Array[String] = GameState.issued_looks.duplicate()
	if not SaveManager.save_to_slot(SAVE_SLOT_A):
		_cleanup_save_slots()
		return "save failed (%s)" % SaveManager.cannot_save_reason_key()
	if not SaveManager.apply_loaded_state(SaveManager.read_slot(SAVE_SLOT_A)):
		_cleanup_save_slots()
		return "apply_loaded_state returned false"
	_cleanup_save_slots()
	if looks.call() != saved:
		return "a look changed across a save and load"
	if GameState.issued_looks != issued:
		return "issued_looks changed across a save and load"

	if not HRSearchSystem.start_search(HRConstants.ROLE_DEVELOPER, HRConstants.LEVEL_MID):
		return "start_search refused"
	for i in TimeModel.ticks(HRConstants.SEARCH_ARRIVAL_WEEKS) + 3:
		_sim_day()
		if HRSearchSystem.has_files_ready():
			break
	var files: Array = HRSearchSystem.get_files()
	if files.is_empty() or files.any(func(f: Dictionary) -> bool: return (f.get("look", {}) as Dictionary).is_empty()):
		return "the delivered files do not all carry a look"
	var file_sig: String = LookSystem.signature(files[0].look)
	var hired: Character = HRSearchSystem.hire(0)
	if hired == null or LookSystem.signature(hired.look) != file_sig:
		return "the hire does not wear the look on its file"

	# A save from before looks: nobody has one and nothing is issued.
	var blank := func() -> void:
		for c in CharacterRegistry.get_all():
			c.look = {}
		GameState.issued_looks.clear()
	blank.call()
	CharacterRegistry.fill_missing_looks()
	var filled: Dictionary = looks.call()
	if people.call().any(func(c: Character) -> bool: return c.look.is_empty()):
		return "fill_missing_looks left someone without a look"
	blank.call()
	CharacterRegistry.fill_missing_looks()
	if looks.call() != filled:
		return "fill_missing_looks drew different looks for the same save"

	# A save from before Frank's look was his alone: an employee and a fund's person wearing it.
	var worn: Character = CharacterRegistry.get_employees()[0]
	var analyst: Dictionary = GameState.investor_people.values()[0][2]
	var moustache := LookSystem.FRANK_LOOK.merged({"head": "m_worker"}, true)
	worn.look = moustache.duplicate()
	analyst.look = LookSystem.FRANK_LOOK.duplicate()
	CharacterRegistry.fill_missing_looks()
	CounterpartSystem.fill_investor_people()
	if worn.look == moustache or analyst.look == LookSystem.FRANK_LOOK:
		return "a load kept a look of Frank's"
	return ""


# --- The people across the table: each fund's three drawn once and kept, a prospect's drawn from
# its id each time, everyone named from the pool of the language the run began in ---
# --- A fund's call can be put off once: the meeting moves a lead time on and the fund remembers
# (as a reschedule), it calls again, and that call can only be answered ---
static func _case_vc_call_postpones_once() -> String:
	GameState.set_phase(3)
	_seed_b2b_series_a()
	if not VCPitchSystem.request_meeting("anchor"):
		return "request_meeting refused"
	var call := func() -> String:
		for i in 5:
			_sim_to_morning()
			if VCPitchSystem.call_waiting() != "":
				break
		return VCPitchSystem.call_waiting()
	if call.call() != "anchor":
		return "the fund never called"
	var before: int = int(GameState.vc_states.anchor.get("move_penalty", 0))
	if not VCPitchSystem.postpone_call():
		return "the first call could not be put off"
	if VCPitchSystem.call_waiting() != "":
		return "the fund still calls the week its meeting was put off"
	var after: int = int(GameState.vc_states.anchor.get("move_penalty", 0))
	if after != before + PitchConstants.MEETING_RESCHEDULE_PENALTY:
		return "putting the call off cost %d, want the reschedule's %d" % [after - before, PitchConstants.MEETING_RESCHEDULE_PENALTY]
	if call.call() != "anchor":
		return "the fund did not call again"
	if VCPitchSystem.postpone_call():
		return "the call was put off twice"
	VCPitchSystem.begin_meeting(VCPitchSystem.call_waiting())
	if not VCPitchSystem.is_active():
		return "the answered call did not start the meeting"
	return ""


static func _case_meeting_cast_seeded_and_saved() -> String:
	# A run takes its language from the locale: the case pins it Turkish and hands it back.
	var loc0: String = TranslationServer.get_locale()
	TranslationServer.set_locale("tr")
	var fail: String = _meeting_cast_checks()
	TranslationServer.set_locale(loc0)
	return fail


static func _meeting_cast_checks() -> String:
	CharacterRegistry.reset()
	GameState.initialize_run({"seed": 515151})
	var founder_look: Dictionary = CharacterRegistry.get_founder().look
	var drawn: Dictionary = GameState.investor_people.duplicate(true)
	var funds: Array = InvestorRegistry.get_active()
	if drawn.size() != funds.size():
		return "%d funds have people, want all %d" % [drawn.size(), funds.size()]
	var everyone: Array = []
	for inv: Dictionary in funds:
		var people: Array = CounterpartSystem.investor_people(inv.id)
		if people.map(func(p: Dictionary) -> String: return p.role) != CounterpartSystem.FUND_ROLES:
			return "%s: roles %s, want lead, partner, analyst" % [inv.id, people.map(func(p: Dictionary) -> String: return p.role)]
		var firsts: Array = people.map(func(p: Dictionary) -> String: return p.name.get_slice(" ", 0))
		var lasts: Array = people.map(func(p: Dictionary) -> String: return p.name.get_slice(" ", 1))
		for i in people.size():
			if firsts.count(firsts[i]) > 1 or lasts.count(lasts[i]) > 1:
				return "%s: two at the table share a name (%s)" % [inv.id, people.map(func(p: Dictionary) -> String: return p.name)]
			if not HRConstants.FIRST_NAMES.has(firsts[i]):
				return "%s: %s is not from the Turkish pool of a run begun in Turkish" % [inv.id, people[i].name]
		if inv.has("lead_sex") and people[0].look.sex != inv.lead_sex:
			return "%s: the lead is not of the sex the fund's copy gives them" % inv.id
		everyone.append_array(people)
	var looks: Array = [founder_look] + everyone.map(func(p: Dictionary) -> Dictionary: return p.look)
	for i in looks.size():
		for j in range(i + 1, looks.size()):
			if LookSystem.apart(looks[i], looks[j]) < LookSystem.MIN_APART:
				return "two of the funds' people (or one and the founder) look alike"
	if everyone.any(func(p: Dictionary) -> bool: return GameState.issued_looks.has(LookSystem.signature(p.look))):
		return "a fund's person was issued a look of the run's"

	GameState.name_lang = "en"
	if not SaveManager.save_to_slot(SAVE_SLOT_A):
		_cleanup_save_slots()
		return "save failed (%s)" % SaveManager.cannot_save_reason_key()
	var payload: Dictionary = SaveManager.read_slot(SAVE_SLOT_A)
	if not SaveManager.apply_loaded_state(payload):
		_cleanup_save_slots()
		return "apply_loaded_state returned false"
	if GameState.investor_people != drawn:
		_cleanup_save_slots()
		return "the funds' people changed across a save and load"
	if GameState.name_lang != "en":
		_cleanup_save_slots()
		return "name_lang came back as %s, want en" % GameState.name_lang
	# A save from before both: the run began in Turkish and its funds get the same people.
	var old: Dictionary = payload.duplicate(true)
	(old.state.game_state as Dictionary).erase("name_lang")
	(old.state.game_state as Dictionary).erase("investor_people")
	if not SaveManager.apply_loaded_state(old):
		_cleanup_save_slots()
		return "apply_loaded_state refused a save from before the funds had people"
	_cleanup_save_slots()
	if GameState.name_lang != "tr":
		return "a save from before name_lang came back as %s, want tr" % GameState.name_lang
	if GameState.investor_people != drawn:
		return "a save from before the funds had people drew different ones"

	# A run begun in English names from the English pools.
	GameState.name_lang = "en"
	GameState.investor_people.clear()
	CounterpartSystem.fill_investor_people()
	var lead: Dictionary = CounterpartSystem.lead(funds[0].id)
	if not HRConstants.FIRST_NAMES_EN.has(lead.name.get_slice(" ", 0)) \
			or not HRConstants.LAST_NAMES_EN.has(lead.name.get_slice(" ", 1)):
		return "%s is not from the English pools of a run begun in English" % lead.name
	var files: Array = HRCandidateGenerator.generate(HRConstants.ROLE_DEVELOPER, HRConstants.LEVEL_MID, 31337, "en")
	if files.any(func(f: Dictionary) -> bool: return not HRConstants.FIRST_NAMES_EN.has(f.name.get_slice(" ", 0))):
		return "a candidate of a run begun in English has a name from another pool"
	GameState.name_lang = "tr"

	# A prospect brings as many as its stars, the same ones every time.
	for star in [1, 2, 3]:
		var p := Prospect.new()
		p.id = "lead_cast_%d" % star
		p.star = star
		var side: Array = CounterpartSystem.prospect_people(p)
		if side.map(func(q: Dictionary) -> String: return q.role) != CounterpartSystem.PROSPECT_ROLES.slice(0, star):
			return "a %d-star prospect brought %s" % [star, side.map(func(q: Dictionary) -> String: return q.role)]
		if str(CounterpartSystem.prospect_people(p)) != str(side):
			return "a %d-star prospect brought different people the second time" % star
		if side.any(func(q: Dictionary) -> bool: return GameState.issued_looks.has(LookSystem.signature(q.look))):
			return "a prospect's person was issued a look of the run's"
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
	var week_gain: int = int(TimeModel.per_tick(HRConstants.EXPERIENCE_PER_WORKED_DAY))
	if emp.experience_raw < week_gain:
		return "after one tick experience is %d, want at least %d" % [emp.experience_raw, week_gain]
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
	for i in TimeModel.ticks(HRConstants.TRAINING_WEEKS):
		if emp.status != HRConstants.STATUS_TRAINING:
			return "left training early on tick %d" % i
		_sim_day()
	if emp.status != HRConstants.STATUS_ACTIVE:
		return "after %d ticks status is '%s', want active" % [TimeModel.ticks(HRConstants.TRAINING_WEEKS), emp.status]
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
	for _i in TimeModel.ticks(HRConstants.TRAINING_WEEKS):
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
## thousands separator, decimal mark, percent side, the date line's words, and the uppercase
## rule (the English branch exists because tr_upper was mangling Display→DİSPLAY).
static func _case_loc_format_locale_flip() -> String:
	var loc0: String = TranslationServer.get_locale()
	var d := {"week": 37, "month": 9, "year": 2026}
	var want := {
		"tr": {
			"money_exact": "$1.234.567", "money": "$3,5K", "pct": "%12,5",
			"date": "Hafta 37 · Eylül 2026", "upper": "İYİ", "month": "Eylül",
		},
		"en": {
			"money_exact": "$1,234,567", "money": "$3.5K", "pct": "12.5%",
			"date": "Week 37 · September 2026", "upper": "IYI", "month": "September",
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
	# bir kurucu üçünde de görünür.
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
	# Yıldız bir kural birimidir: hat kapıları, Ar-Ge gereksinimi, satış ligi ve müşteri temsilcisinin
	# kapasitesi yeteneği yıldıza çevirip okur, yarım yıldız dahil. Cetvel tek yerde yaşıyor:
	# HRConstants.stars_for. İki uç da anlamlı olmalı: tavan tam beş, tek sayılar yarım.
	# FALSİFİKASYON: AREA_MAX'i 9'a döndür → ikinci iddia FAIL (tavan 4,5 yıldız okur).
	if HRConstants.POINTS_PER_STAR != 2:
		return "POINTS_PER_STAR is %d; the half-star grammar needs exactly 2" % HRConstants.POINTS_PER_STAR
	if not is_equal_approx(HRConstants.stars_for(HRConstants.AREA_MAX), float(HRConstants.STAR_MAX)):
		return "the top of the ruler is %.1f stars, want a full %d — five can never fill" % [
			HRConstants.stars_for(HRConstants.AREA_MAX), HRConstants.STAR_MAX]
	# KURUCU DA BU CETVELDE (§2.4 + §5.3): tavanı tam beş yıldızdır.
	if not is_equal_approx(HRConstants.stars_for(FounderConstants.SKILL_CEILING),
			float(HRConstants.STAR_MAX)):
		return "the founder ceiling reads %.1f stars, want a full %d — §2.4 puts him on the shared ruler" % [
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
	for _i in TimeModel.ticks(HRConstants.TRAINING_WEEKS):
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
	if emp.training_weeks_left != TimeModel.ticks(HRConstants.TRAINING_WEEKS):
		return "training runs %d weeks, want the flat %d (11c: 'iki hafta' on every row)" % [
			emp.training_weeks_left, HRConstants.TRAINING_WEEKS]
	for _i in TimeModel.ticks(HRConstants.TRAINING_WEEKS):
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
	if HRSystem.tenure_weeks(emp) < 0:
		return "hr.tenure_weeks went negative"
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
	# EN UZUN GÜN: sekizin üstündeki saatler yarım verimle, on altı saat +%50 çıktı. On altı saat
	# ancak 08:00 başlangıcına sığar; gün en geç 00:00'da biter.
	WorkHoursSystem.set_company_start_hour(TimeModel.WEEK_START_HOUR)
	WorkHoursSystem.set_company_hours(HRConstants.WORK_HOURS_MAX)
	if absf(HRSystem.daily_contribution(dev, HRConstants.AREA_ENGINEERING) - per_hour * 1.5) > 0.001:
		return "the longest day did not raise the daily contribution by 50%"
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
	if HRActions.raise_cooldown_left(emp) != TimeModel.ticks(HRConstants.RAISE_COOLDOWN_WEEKS):
		return "cooldown reads %d weeks, want %d" % [
			HRActions.raise_cooldown_left(emp), HRConstants.RAISE_COOLDOWN_WEEKS]

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
	var year: int = TimeModel.ticks(TimeModel.WEEKS_PER_YEAR)
	if HRConstants.severance_amount(3000, year - 1) != int(round(3000.0 / 3.0)):
		return "under a year did not pay ⅓ salary: %d" % HRConstants.severance_amount(3000, year - 1)
	if HRConstants.severance_amount(3000, year + year / 2) != 3000:
		return "a year and a half paid %d, want exactly one salary (ara aylar yuvarlanmaz)" % \
			HRConstants.severance_amount(3000, year + year / 2)
	if HRConstants.severance_amount(3000, 10 * year) != 9000:
		return "ten years paid %d, want the three-salary cap" % HRConstants.severance_amount(3000, 10 * year)
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
	st["start"] = 10
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
	if WorkHoursSystem.start_hour() != 10:
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
	if int(win["start"]) != 10 or int(win["end"]) != 20:
		return "company_window says %s–%s, want 10–20" % [str(win["start"]), str(win["end"])]
	if String(win["end_text"]) != "20:00":
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


static var RE_CLASS_NAME: RegEx = RegEx.create_from_string("(?m)^class_name[ \t]+([A-Za-z0-9_]+)[ \t\r]*$")


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
		#
		# Boşaltılmış kopyada `self` artık X tipi değildir, yani `var a: X = self` yalnız kopyada
		# derlenmez. Sınıf adını kopyaya özel bir ada çeviren ikinci kopya onu derler, ama orada
		# da adın DEĞER olarak kullanımı (`X.new()`) çözülmez. Her kopya bir öz-göndermeyi
		# kaçırır; dosya ancak ikisi de derlenmezse bozuktur. Denemeler hata basmadan koşar
		# (runner basılan her hatayı FAIL sayar); gerçek kırık bir kez daha sesli derlenir ki
		# hatası logda dursun.
		var copies: Array[String] = [RE_CLASS_NAME.sub(src, "", true)]
		var own: RegExMatch = RE_CLASS_NAME.search(src)
		if own != null:
			copies.append(RegEx.create_from_string("\\b%s\\b" % own.get_string(1)).sub(
				src, own.get_string(1) + "__Probe", true))
		Engine.print_error_messages = false
		var compiles: bool = copies.any(func(copy: String) -> bool: return _compile(copy) == OK)
		Engine.print_error_messages = true
		if not compiles:
			_compile(copies[0])
			broken.append(path)
	# İKİ HATA MODU AYRI RAPORLANIR. Eskiden ikisi de aynı cümleyle geliyordu ve
	# "okunamadı" ile "derlenemedi" karışınca ilk bakılacak yer yanlış oluyordu.
	if not unreadable.is_empty():
		return "%d script(s) unreadable: %s" % [unreadable.size(), ", ".join(unreadable)]
	if not broken.is_empty():
		return "%d script(s) failed to compile: %s" % [broken.size(), ", ".join(broken)]
	return ""


## A detached compile: a fresh GDScript carrying only the source, which nothing in the running
## game points at.
static func _compile(source: String) -> Error:
	var probe := GDScript.new()
	probe.source_code = source
	return probe.reload()


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
			Fmt.date_line({"week": 37, "month": 9, "year": 2026}),
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


## B2C satisfaction has no gate: the userbase record drifts toward the experience score a day's
## step at a time (seven on a tick) from either side and stops there, and a live backlog over
## SATISFACTION_BUG_GATE pushes it down on top at its own daily rate, not the drift's.
## FALSIFICATION: put back the "+1 a day while experience ≥ 40" gate and the from-above leg
## climbs instead of falling; push the backlog at the drift's step and the backlog legs land low.
static func _case_b2c_satisfaction_drifts_to_experience() -> String:
	_seed_b2c()
	var ub: Customer = CustomerRegistry.get_customer(SalesSystem.B2C_USERBASE_ID)
	if ub == null:
		return "no B2C aggregate record after seed"
	GameState.set_flag("mvp_stability", 0.0)
	GameState.set_flag("mvp_innovation", 0.0)
	# SUPPORT-QUIET WORLD: the desk's two-tier damage and the server overage write the same
	# record every day, so each leg starts with no reports, no confirmed bugs, no carried
	# residue and room on the servers.
	InfraSystem.set_provider("cloud")
	InfraSystem.set_capacity(100)
	var step: int = int(TimeModel.per_tick(SalesSystem.SATISFACTION_DRIFT_PER_DAY))
	var push: int = int(TimeModel.per_tick(SalesSystem.SATISFACTION_BUG_PUSH_PER_DAY))
	var over: int = SalesSystem.SATISFACTION_BUG_GATE + 1
	var target: int = int(round(QualityModel.normalized_quality(25.0)))   # raw experience 25
	# [raw experience, live bugs, satisfaction before, satisfaction after one tick]
	for leg in [
			[25.0, 0, target - 3 * step, target - 2 * step],          # climbs a week's step
			[25.0, 0, target - 2, target],                            # and stops at the target
			[25.0, 0, 80, 80 - step],                                 # falls from above: nothing holds it up
			[10.0, 0, 10, 10 + step],                                 # a weak product (target 29) still climbs
			[25.0, over, target, target - push],                      # the backlog pushes under the target
			[25.0, over, target - 3 * step, target - 2 * step - push]]:   # and slows a climb
		GameState.set_flag("mvp_experience", float(leg[0]))
		GameState.set_flag("mvp_live_bug_count", int(leg[1]))
		GameState.set_flag(ProductState.REPORTS_INCOMING, 0)
		GameState.set_flag(ProductState.BUGS_CONFIRMED, 0)
		SupportSystem.reset()
		CustomerRegistry.set_satisfaction(ub.id, int(leg[2]))
		_sim_day()
		if ub.satisfaction != int(leg[3]):
			return "experience %.0f, %d live bugs: satisfaction %d -> %d, want %d" % [
				float(leg[0]), int(leg[1]), int(leg[2]), ub.satisfaction, int(leg[3])]
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
	# on exactly the SOFT_CAP_WEEK tick — never earlier, never silently.
	var cap: int = TimeModel.ticks(EndingsSystem.SOFT_CAP_WEEK)
	# The verdict card speaks the week before the cap; its JSON carries that week as a literal.
	if _card_literal("world.final_stretch_verdict", "time.week") != EndingsSystem.SOFT_CAP_WEEK - 1:
		return "final_stretch_verdict waits for week %d, the cap's eve is %d" % [
			_card_literal("world.final_stretch_verdict", "time.week"), EndingsSystem.SOFT_CAP_WEEK - 1]
	GameState.set_cash(500000)   # no Kepenk on the way: cash is not the subject here
	GameState.day = cap - 3
	for i in 6:
		if not GameState.run_active:
			break
		_sim_day()
	if _endings != ["running_on_fumes"]:
		return "endings: %s (tick %d)" % [str(_endings), GameState.day]
	if GameState.day != cap:
		return "soft cap fired on tick %d, want %d" % [GameState.day, cap]
	return ""


static func _case_no_calendar_stop_before_cap() -> String:
	# Week 26 (the old Day-180 fork) is just a week now. A solvent run with nothing else going
	# on is still alive the week before the cap.
	var last: int = TimeModel.ticks(EndingsSystem.SOFT_CAP_WEEK) - 1
	GameState.set_cash(500000)
	GameState.day = 25
	for i in last - 25:
		if not GameState.run_active:
			break
		_sim_day()
	if not GameState.run_active or not _endings.is_empty():
		return "run ended early: %s at tick %d (the calendar wall is back)" % [str(_endings), GameState.day]
	if GameState.day != last:
		return "sim drifted: tick %d, want %d" % [GameState.day, last]
	return ""


static func _case_soft_cap_no_defer_for_sheet() -> String:
	# A live term sheet does NOT hold the cap (no auto-sign); the
	# ledger names the unsigned offer instead.
	GameState.set_cash(500000)
	GameState.phase = 3
	GameState.day = TimeModel.ticks(EndingsSystem.SOFT_CAP_WEEK) - 2
	GameState.active_sheets.append(VCPitchSystem._make_sheet("anchor", GameState.day))
	for i in 4:
		if not GameState.run_active:
			break
		_sim_day()
	if _endings != ["running_on_fumes"]:
		return "a live sheet deferred the soft cap: endings %s at tick %d" % [str(_endings), GameState.day]
	if int(GameState.get_run_ledger().get("unsigned_sheets", 0)) != 1:
		return "the ledger does not name the unsigned sheet (unsigned_sheets=%s)" % str(GameState.get_run_ledger().get("unsigned_sheets"))
	return ""


# REMOVED 2026-08-23 — _case_soft_cap_warning_day.
# The mechanic it tested no longer exists: the warning was a fixed calendar day
# (PitchConstants.SOFT_CAP_WARN_DAY) and is now sheet-relative — VCPitchSystem
# ._tick_last_answer_warning fires once when the sole live sheet has weeks_left == 1, and
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
		"phase": 3, "day": TimeModel.ticks(EndingsSystem.SOFT_CAP_WEEK), "mrr": 4000, "customers_signed": 3, "customers_active": 3,
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
	# Two-year span phrase: a soft-cap run is not "close to a year".
	var span_two: String = TranslationServer.translate("END_SPAN_NEAR_TWO_YEARS")
	if span_two == "" or span_two == "END_SPAN_NEAR_TWO_YEARS":
		return "END_SPAN_NEAR_TWO_YEARS missing"
	var head_line: String = String((vs.get("ledger_lines", []) as Array)[0])
	if head_line.find(span_two) < 0:
		return "soft-cap paper does not use the two-year span phrase: '%s'" % head_line
	return ""


# --- The Series A gate: revenue bar (never shown) + a growth streak; the signal is shown ---

static func _case_month_history_close_and_cap() -> String:
	# The calendar-month ledger closes on the first tick of the next month, carries the open
	# month's accruals (income = Σ tick revenue, expense = Σ burn + one-time costs, red_weeks),
	# and keeps 12.
	GameState.set_cash(100000)
	_seed_b2b(3000)   # daily revenue 100, burn 50 tools + the account's service cost → net positive
	_sim_day()        # settle the bridge (MRR → GameState)
	var closes_before: int = GameState.month_history.size()
	for i in 4:
		_sim_day()    # ticks 3..6: January closes at tick 6 (5 Feb)
	if GameState.month_history.size() != closes_before + 1:
		return "expected one fiscal close by tick 6, got %d" % (GameState.month_history.size() - closes_before)
	var e: Dictionary = GameState.month_history[GameState.month_history.size() - 1]
	if int(e.get("income", 0)) <= 0 or int(e.get("expense", 0)) <= 0:
		return "close carries no accruals: %s" % str(e)
	if int(e.get("net", 0)) != int(e.get("income", 0)) - int(e.get("expense", 0)):
		return "net != income - expense: %s" % str(e)
	if int(e.get("mrr_close", 0)) != GameState.mrr:
		return "mrr_close %d != live MRR %d at close" % [int(e.get("mrr_close", 0)), GameState.mrr]
	if int(e.get("red_weeks", -1)) != 0:
		return "a solvent month counted red weeks: %s" % str(e)
	for i in 20:
		GameState.push_month_close({"start_day": 1, "end_day": 30, "mrr_close": 1, "income": 1, "expense": 1, "net": 0, "red_weeks": 0})
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
	# to the AUDIENCE (that is the compounding); below the gate there is no such term. Every
	# reading sits at or over WOM_MULT_PIVOT, so base growth is the same in all of them.
	_seed_b2c()
	GameState.set_flag("mvp_innovation", 15.0)
	GameState.set_flag("mvp_stability", 20.0)
	GameState.set_flag("mvp_experience", 17.5)
	GameState.set_flag("b2c_audience", 1000.0)
	var pivot: int = int(SalesSystem.WOM_MULT_PIVOT)
	var gate: int = int(SalesSystem.WOM_SAT_GATE)
	if gate <= pivot:
		return "fixture: the word-of-mouth gate (%d) must sit over the pivot (%d)" % [gate, pivot]
	var d_pivot: float = _b2c_delta_at_satisfaction(pivot)
	var d_gate: float = _b2c_delta_at_satisfaction(gate)
	var d_over: float = _b2c_delta_at_satisfaction(gate + 20)
	if absf(d_gate - d_pivot) > 1e-6:
		return "satisfaction %d (the gate) already adds word of mouth (%.4f vs %.4f)" % [gate, d_gate, d_pivot]
	var want: float = 1000.0 * SalesSystem.WOM_COEF * 0.2
	if absf((d_over - d_gate) - want) > 1e-6:
		return "sat %d adds %.4f/h over the gate, want audience·WOM_COEF·0.2 = %.4f" % [gate + 20, d_over - d_gate, want]
	# Proportional to the audience: double the audience, double the word-of-mouth term.
	GameState.set_flag("b2c_audience", 2000.0)
	var d_over_b: float = _b2c_delta_at_satisfaction(gate + 20)
	var d_gate_b: float = _b2c_delta_at_satisfaction(gate)
	if absf((d_over_b - d_gate_b) - 2.0 * want) > 1e-6:
		return "word of mouth is not proportional to the audience (%.4f vs %.4f)" % [d_over_b - d_gate_b, 2.0 * want]
	if SalesSystem.WOM_COEF <= 0.0:
		return "WOM_COEF is %.4f — the compounding term is off" % SalesSystem.WOM_COEF
	return ""


static func _case_b2c_growth_multiplier_floor() -> String:
	# Below the pivot the BASE growth is scaled by sat/WOM_MULT_PIVOT, floored at WOM_MULT_MIN;
	# at and above the pivot it runs at full strength. Measured as the gap to the pivot reading
	# with no audience, so churn and word of mouth are zero.
	_seed_b2c()
	GameState.set_flag("mvp_innovation", 15.0)
	GameState.set_flag("mvp_stability", 20.0)
	GameState.set_flag("mvp_experience", 17.5)
	GameState.set_flag("b2c_audience", 0.0)   # no audience → no churn, no word of mouth: pure base growth
	var pivot: int = int(SalesSystem.WOM_MULT_PIVOT)
	var half: int = int(SalesSystem.WOM_MULT_PIVOT * 0.5)
	var d_pivot: float = _b2c_delta_at_satisfaction(pivot)
	var d100: float = _b2c_delta_at_satisfaction(100)
	var d_half: float = _b2c_delta_at_satisfaction(half)
	var d0: float = _b2c_delta_at_satisfaction(0)
	if d_pivot <= 0.0:
		return "fixture: base growth is not positive (%.4f)" % d_pivot
	if absf(d100 - d_pivot) > 1e-6:
		return "satisfaction above the pivot changed base growth (%.4f vs %.4f)" % [d100, d_pivot]
	if absf(d_half - float(half) / float(pivot) * d_pivot) > 1e-6:
		return "satisfaction %d should scale base growth by %d/%d (%.4f vs %.4f)" % [
			half, half, pivot, d_half, float(half) / float(pivot) * d_pivot]
	if absf(d0 - SalesSystem.WOM_MULT_MIN * d_pivot) > 1e-6:
		return "satisfaction 0 should floor at ×%.1f (%.4f vs %.4f)" % [SalesSystem.WOM_MULT_MIN, d0, SalesSystem.WOM_MULT_MIN * d_pivot]
	# No aggregate record yet (paid tier closed) → the pre-revenue trickle is untouched.
	CustomerRegistry.remove(SalesSystem.B2C_USERBASE_ID)
	var d_none: float = SalesSystem._audience_delta_per_hour()
	if absf(d_none - d_pivot) > 1e-6:
		return "without the aggregate record growth should equal the pivot reading (%.4f vs %.4f)" % [d_none, d_pivot]
	return ""


# --- Bugs hit conversion ---

static func _case_conversion_bug_penalty() -> String:
	# 10 live bugs ≈ −20 % conversion, floored at ×0.4; the price-change projection
	# (SalesSystem.estimate_price_change → new_paying) moves with it.
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


## The B2C price anchor reads the live line ladder: open lines and their usage weight add
## worth, and the flat feature list (fixtures only) does not.
## FALSIFICATION: point product_value back at mvp_components and the feature-list leg moves.
static func _case_b2c_value_reads_live_lines() -> String:
	_seed_b2c()
	var sub: String = "note_tool"
	GameState.set_flag("mvp_sub_product_type_id", sub)
	GameState.set_flag("mvp_innovation", 15.0)
	GameState.set_flag("mvp_stability", 20.0)
	GameState.set_flag("mvp_experience", 17.5)
	var bare: int = int(SalesSystem.product_value()["optimal"])
	GameState.set_flag("mvp_components", ["ai_assistant_chat", "ai_assistant_memory"])
	if int(SalesSystem.product_value()["optimal"]) != bare:
		return "the flat feature list moved the value (%d -> %d)" % [
			bare, int(SalesSystem.product_value()["optimal"])]
	for line_id in ProductLines.line_ids(sub):
		ProductState.set_line_tier(String(line_id), 2)
	if ProductState.usage_weight_total() <= 0:
		return "fixture: tier 2 carries no usage weight, so the depth term cannot be seen"
	var mult: float = float(SalesSystem.TENDENCY_MULT.get(ProductCatalog.get_price_tendency(sub), 1.0))
	var want: int = int(round(maxf(1.0, SalesSystem.VALUE_BASE
		+ QualityModel.shipped_normalized() * SalesSystem.VALUE_QUALITY_COEF
		+ ProductState.lines_open() * SalesSystem.VALUE_FEATURE_COEF
		+ ProductState.usage_weight_total() * SalesSystem.VALUE_COMPLEXITY_COEF) * mult))
	var got: int = int(SalesSystem.product_value()["optimal"])
	if got != want or got <= bare:
		return "%d open lines, %d usage weight: optimal %d, want %d (bare %d)" % [
			ProductState.lines_open(), ProductState.usage_weight_total(), got, want, bare]
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
	# `verb`, the shape a CARD carries; asserting on the shape the cards actually use is what
	# makes this case cover the path a player sees.
	var parts: Array = EvChips.describe({"verb": "audience_delta", "pct": -0.03}, {}, {}, false)
	if parts.size() != 1:
		return "the pct form should be one part, got %d" % parts.size()
	var txt: String = EvChips.text(parts[0])
	if txt.find("3") < 0 or txt.find("{") >= 0 or String(parts[0]["value"]).find("3") < 0:
		return "part for the pct form is wrong: '%s'" % txt
	if String(parts[0]["polarity"]) != "cost":
		return "a negative pct should be a cost, got %s" % str(parts[0]["polarity"])
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
	CustomerRegistry.set_churn_countdown(c.id, TimeModel.ticks(B2BConstants.CHURN_COUNTDOWN_WEEKS))
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
	# Rescued on tick D, still under the bar: the account stays OUT of Risk until D + the
	# re-entry window, with no countdown and no card, then re-enters the tick the window closes.
	var c: Customer = _seed_risk_account()
	var day0: int = GameState.day
	B2BSalesSystem.apply_discount(c.id, -100)   # _recover → leaves Risk, stamps the exit day
	if c.lifecycle_phase == "risk" or c.last_risk_exit_day != day0:
		return "rescue did not leave Risk / stamp the day (phase %s, exit %d)" % [c.lifecycle_phase, c.last_risk_exit_day]
	var cards: Array = [0]
	EventBus.event_triggered.connect(func(id: String) -> void:
		if id == RETAIN_ID:
			cards[0] += 1)
	for i in TimeModel.ticks(B2BConstants.RISK_REENTRY_WEEKS) - 1:
		CustomerRegistry.set_satisfaction(c.id, 10)   # hold it far under the bar
		_sim_day()
		if c.lifecycle_phase == "risk":
			return "re-entered Risk on tick %d, %d ticks after the rescue (window %d)" % [
				GameState.day, GameState.day - day0, B2BConstants.RISK_REENTRY_WEEKS]
	if c.risk_streak < TimeModel.ticks(B2BConstants.RISK_TRIGGER_WEEKS):
		return "the streak stopped counting during the window (%d)" % c.risk_streak
	if int(cards[0]) != 0:
		return "a retention card fired inside the window"
	CustomerRegistry.set_satisfaction(c.id, 10)
	_sim_day()   # D + the window
	if c.lifecycle_phase != "risk" or c.churn_countdown < 0:
		return "did not re-enter Risk when the window closed (tick %d, phase %s)" % [GameState.day, c.lifecycle_phase]
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
	B2BSalesSystem.accept_promise(c.id, "ai_vec_filter", B2BConstants.PROMISE_DEADLINE_WEEKS)   # the promise path → _recover
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
	# the month closes in slot 0, so the endings scan (slot 9) of the same tick reads the sixth
	# close and the win lands on the close tick; never before the sixth close.
	GameState.set_cash(100000)
	_seed_b2b(EndingsSystem.BOOTSTRAP_WIN_MRR + 5000)   # daily revenue ~833 vs burn ~53 → an Artıda month
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
	if fired_day != close_day:
		return "win fired on tick %d, want the close tick (%d)" % [fired_day, close_day]
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
	# the win can still end it and the week-104 cap still applies.
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
		GameState.day = TimeModel.ticks(EndingsSystem.SOFT_CAP_WEEK)
		if not EndingsSystem._check_soft_cap() or GameState.ending_id != "running_on_fumes":
			fail = "demo: the week-104 cap did not end a milestone save's run (ending '%s')" % GameState.ending_id
	EndingsSystem.build_scope_override = ""
	return fail


## EA: the profitable bootstrap opens the milestone paper ONCE and the run goes on — no
## run_ended, no ending_id, run_active untouched. The latch keeps the condition shut on the
## ticks after, the week-104 soft cap no longer ends the run (option a), and the soft-cap
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
		# The soft-cap telegraph opener (its own time.week floor) is shut by the new seam.
		GameState.day = TimeModel.ticks(EndingsSystem.SOFT_CAP_WEEK) - 1
		var press: Dictionary = EvCatalog.card("world.final_stretch_press")
		if press.is_empty():
			fail = "world.final_stretch_press is missing from the catalogue"
		elif EventGate.condition_met(press.get("condition", {}) as Dictionary, {}):
			fail = "the soft-cap telegraph would still fire after the milestone"
	if fail == "":
		GameState.day = TimeModel.ticks(EndingsSystem.SOFT_CAP_WEEK)
		_sim_day()
		if not _endings.is_empty() or not GameState.run_active:
			fail = "tick %d ended a run past its milestone: %s" % [GameState.day, str(_endings)]
	if fail == "":
		# The run is past week 104 now, so its paper needs a span the cap never allowed.
		# FALSIFICATION: drop the OVER_TWO_YEAR_WEEKS branch → week 157 reads "close to two years".
		var over: String = TranslationServer.translate("END_SPAN_OVER_TWO_YEARS")
		var near: String = TranslationServer.translate("END_SPAN_NEAR_TWO_YEARS")
		if over == "END_SPAN_OVER_TWO_YEARS" or over == near:
			fail = "END_SPAN_OVER_TWO_YEARS does not resolve to its own line"
		elif EndingsCopy._span_phrase(157) != over:
			fail = "week 157 reads '%s'" % EndingsCopy._span_phrase(157)
		elif EndingsCopy._span_phrase(TimeModel.ticks(EndingsSystem.SOFT_CAP_WEEK)) != near:
			fail = "week %d (the cap) no longer reads '%s'" % [EndingsSystem.SOFT_CAP_WEEK, near]
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


## A stand-in GameShell for main.gd's handlers: the two layers they mount on and free from.
static func _stand_in_shell(host: Node) -> Node:
	var shell := Node.new()
	for layer_name in ["PanelLayer", "ModalLayer"]:
		var layer := CanvasLayer.new()
		layer.name = layer_name
		shell.add_child(layer)
	host.add_child(shell)
	return shell


## THE DECISION GATE HOLDS THE CLOCK FROM THE CARD TO ITS ANSWER, and it is main's handler that
## holds it: the engine only announces, so a harness with no shell never freezes. Between the two
## a speed key does nothing; the answer gives back the speed the card found.
## FALSIFICATION: drop TimeManager.hold_clock from main._on_event_modal_requested → the speed key
## goes through; drop release_clock from main._on_gate_closed → the clock stays held.
static func _case_event_gate_holds_clock() -> String:
	var host: Node = _ui_host()
	if host == null or not host.has_method("_on_event_modal_requested"):
		return "no main.gd host to drive the gate"
	var shell: Node = _stand_in_shell(host)
	var prev_shell: Variant = host.get("_shell")
	host.set("_shell", shell)
	EventBus.speed_change_requested.emit(2)
	var fail: String = ""
	if not EventGate.force_fire("fixture.thesis_close"):
		fail = "fixture: the card did not fire"
	elif TimeManager.is_clock_held():
		fail = "the engine held the clock by itself; a harness with no shell would freeze"
	if fail == "":
		host.call("_on_event_modal_requested", EventGate.active_card())
		EventBus.speed_change_requested.emit(3)
		if not TimeManager.is_clock_held() or TimeManager.current_speed != 0:
			fail = "the card on screen did not hold the clock (speed %d)" % TimeManager.current_speed
	if fail == "":
		EventGate.resolve("fixture.thesis_close", 0)
		host.call("_on_event_resolved", "fixture.thesis_close", 0)
		if TimeManager.is_clock_held():
			fail = "the answer did not release the clock"
		elif TimeManager.current_speed != 2:
			fail = "the answer did not give back the speed the card found (%d)" % TimeManager.current_speed
	host.set("_shell", prev_shell)
	TimeManager.release_clock("event")
	shell.queue_free()
	return fail


## main.gd's milestone handlers, driven directly with a stand-in shell, in the order a run brings
## them:
##   1. the paper mounts and holds the clock, which stops the night's batch; the card that batch
##      admitted pumps under it, and the paper steps aside for the decision (it would cover the inbox,
##      and ANA MENÜ would refuse to save for a decision the player cannot see) with its hold;
##   2. the answered decision brings the paper back, holding the clock;
##   3. DEVAM ET frees the paper, releases the hold and gives back the speed from before the paper;
##   4. ANA MENÜ keeps the run in a MANUAL slot — the rolling autosave would be overwritten by
##      the next run's third weekly autosave.
## FALSIFICATION: drop the step-aside from _on_event_modal_requested → the paper stays over the card;
## drop its release_clock → the hold stays; drop the mount from _open_after_gate → the paper never
## comes back. Save through the autosave again → the slot is auto_*.
static func _case_milestone_paper_waits_for_card() -> String:
	var host: Node = _ui_host()
	if host == null or not host.has_method("_on_milestone_reached"):
		return "no main.gd host to drive the milestone handlers"
	EndingsSystem.build_scope_override = EndingsSystem.BUILD_EA
	var shell: Node = _stand_in_shell(host)
	var prev_shell: Variant = host.get("_shell")
	host.set("_shell", shell)
	var data: Dictionary = EndingsSystem._build_ending_data("profitable_bootstrap", {})
	data["mode"] = EndingsSystem.MODE_MILESTONE
	EventBus.speed_change_requested.emit(2)
	host.call("_on_milestone_reached", "profitable_bootstrap", data)
	var fail: String = ""
	if host.get("_milestone_modal") == null or not TimeManager.is_clock_held():
		fail = "fixture: the paper did not mount and hold the clock"
	elif not EventGate.force_fire("fixture.thesis_close"):
		fail = "fixture: the card did not fire"
	if fail == "":
		host.call("_on_event_modal_requested", EventGate.active_card())
		if host.get("_milestone_modal") != null:
			fail = "the paper stayed over the decision that came under it"
		elif TimeManager._holds.has("milestone_paper"):
			fail = "the paper stepped aside but kept the clock held"
	if fail == "":
		EventGate.resolve("fixture.thesis_close", 0)
		host.call("_on_event_resolved", "fixture.thesis_close", 0)
		if host.get("_milestone_modal") == null:
			fail = "the answered decision did not bring the paper back"
		elif not TimeManager.is_clock_held():
			fail = "the paper came back without holding the clock"
	if fail == "":
		host.call("_on_milestone_continue")
		if host.get("_milestone_modal") != null:
			fail = "DEVAM ET left the paper up"
		elif TimeManager.is_clock_held():
			fail = "DEVAM ET did not release the hold"
		elif TimeManager.current_speed != 2:
			fail = "DEVAM ET did not give back the speed from before the paper (%d)" % TimeManager.current_speed
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
	host.set("_milestone_modal", null)
	host.set("_milestone_paper", [])
	TimeManager.release_clock("milestone_paper")
	TimeManager.release_clock("event")
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
	last["red_weeks"] = 1
	GameState.month_history[GameState.month_history.size() - 1] = last
	sig = EndingsSystem.profitability_signal()
	if bool(sig.get("met", false)) or int(sig.get("streak", 9)) != 0:
		return "a red day inside the window should break the streak (%s)" % str(sig)
	return ""


# --- The speed ladder is 1×/2×/3×/4× ---

static func _case_speed_save_clamps_to_ladder() -> String:
	# last_running_speed past the ladder's top clamps to it on load, and the resume lands there.
	var top: int = TimeModel.SECONDS_PER_HOUR.size() - 1
	TimeManager.from_dict({"in_game_hours": float(GameState.current_hour), "current_speed": top + 1,
		"last_running_speed": top + 1})
	if TimeManager.last_running_speed != top:
		return "stored speed %d came back as %d, want %d" % [top + 1, TimeManager.last_running_speed, top]
	TimeManager.resume_if_paused()
	if TimeManager.current_speed != top:
		return "resume after a speed-%d save landed on %d, want %d" % [top + 1, TimeManager.current_speed, top]
	if not is_equal_approx(TimeManager.hours_per_real_second(top + 1), 0.0):
		return "index %d yields a live multiplier" % (top + 1)
	if is_equal_approx(TimeManager.hours_per_real_second(top), 0.0):
		return "the top index %d yields no multiplier" % top
	return ""


static func _case_topbar_speed_cluster_four_rungs() -> String:
	# The TopBar scene carries pause + four rungs; the script's button array matches the ladder
	# (index == speed index) and the shell binds KEY_4 to the top rung.
	var packed: PackedScene = load("res://scenes/ui/components/TopBar.tscn")
	if packed == null:
		return "TopBar.tscn failed to load"
	var state: SceneState = packed.get_state()
	var names: Array = []
	for i in state.get_node_count():
		names.append(String(state.get_node_name(i)))
	for want in ["PauseBtn", "Speed1Btn", "Speed2Btn", "Speed3Btn", "Speed4Btn"]:
		if not names.has(want):
			return "TopBar.tscn is missing %s" % want
	if names.has("Speed5Btn"):
		return "TopBar.tscn carries a fifth rung"
	var src: String = (load("res://scripts/ui/components/top_bar.gd") as GDScript).source_code
	if src.find("Speed4Btn") < 0:
		return "top_bar.gd does not wire Speed4Btn"
	var shell: String = (load("res://scripts/main/game_shell.gd") as GDScript).source_code
	if not shell.contains("KEY_4, KEY_KP_4: speed_idx = 4"):
		return "game_shell.gd does not bind KEY_4 to speed 4"
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


## An hourly ambient card fires only in the visible hours and at most MAX_INTERRUPTS_PER_DAY a
## tick. The ENGINE's hourly clock is the subject, so the card is `fixture.hourly_ambient`
## (allowed_hours [10, 10], inside every workday), admitted by widening SHIPPED_SCOPES for the
## run. The ticks are driven hour by hour, each hour its own batch, so a card admitted in a
## visible hour shows at that hour as it does in play. The night's hours are skipped in one
## batch nobody watches: G4 refuses a non-critical hourly card there.
## FALSIFICATION: remove the is_night check in gate.gd _g4_window and the refusal fails.
static func _case_ambient_hourly_never_at_night() -> String:
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
	var per_tick: Dictionary = {}
	var at_night: Array = []
	EventBus.event_triggered.connect(func(id: String) -> void:
		if String(EventGate.catalogue_card(id).get("tick", "")) != "hourly":
			return
		per_tick[GameState.day] = int(per_tick.get(GameState.day, 0)) + 1
		if TimeManager.is_night():
			at_night.append(GameState.current_hour))
	for i in 30:
		for h in TimeModel.HOURS_PER_DAY:
			TimeManager.advance_hours(1)
			_drain_all_modals()
	GameState.set_current_hour(TimeModel.WEEK_START_HOUR - 5)
	var v: EvGate.Verdict = EvGate.propose("fixture.hourly_ambient", EvGate.Origin.TICK_HOURLY)
	EvTuning.SHIPPED_SCOPES.assign(shipped)
	EvCatalog.reload()
	var total: int = 0
	for t in per_tick.keys():
		total += int(per_tick[t])
		if int(per_tick[t]) > EvTuning.MAX_INTERRUPTS_PER_DAY:
			return "tick %d received %d hourly cards (ceiling %d)" % [
				t, int(per_tick[t]), EvTuning.MAX_INTERRUPTS_PER_DAY]
	if total == 0:
		return "fixture: no hourly card fired in 30 ticks (pool not eligible?)"
	if not at_night.is_empty():
		return "a non-critical hourly card was shown in the night at hours %s" % str(at_night)
	if v.admitted or v.step != "G4" or not v.reason.contains("is in the skipped night"):
		return "a night proposal was not refused at G4 (step '%s', reason '%s')" % [v.step, v.reason]
	return ""


# --- The type picker offers exactly the subtypes with line content ---

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


## §12.11 MÜHÜRLÜ — tip ekranının OYNANABİLİR kartları ile hat içeriği olan alt-tipler
## AYNI KÜME olmak zorunda. İkisi iki ayrı dosyada yaşıyor (ProductCatalog.TYPE_SCREEN ve
## data/product/lines/*.json) ve ayrıştıkları an oyuncu tıklanabilir bir karttan BOŞ bir
## ürüne düşer — motoru görünmez kılan tam olarak bu kopukluktu.
##
## Kilitli tarafı da ölçer: §12.11 sayıyı mühürledi (yol başına ÜÇ) ve kilitli bir kartın
## hat içeriği OLMAMALI, yoksa oynanabilir bir ürünü kilitliyor olurduk.
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
	if TranslationServer.translate("TOPBAR_UNIT_PER_MONTH") == "TOPBAR_UNIT_PER_MONTH":
		return "TOPBAR_UNIT_PER_MONTH missing"
	return ""

# ============================================================================
#  Build Bar · duraklama · DESTEK · trait göçü · Görevler (2026-08-21)
# ============================================================================

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
	if not running.fix_run_active:
		return "the card did not see the running fix run"
	return ""


## R1: kurucu Görevler matrisinde YOK — satır yok, kutu yok, salt-okunur bant yok.
## Ama atama YAŞAMAYA DEVAM EDİYOR (H4): motor onu aktif fazın alanına oturtuyor,
## çünkü hız terimi ve kalite ortalaması üçü de `assigned_jobs`'ı okuyor.
## FALSİFİKASYON: `_founder_band`'i geri koy → ikinci iddia FAIL.
static func _case_gorevler_has_no_founder() -> String:
	const Assignments := preload("res://scripts/tabs/hr/hr_assignments.gd")
	_make_employee("char_matrix_dev", "Matrix Dev", HRConstants.ROLE_DEVELOPER)
	var founder: Character = CharacterRegistry.get_founder()
	var page: Control = Assignments.build(func(_a: String, _b: String, _c: bool) -> void: pass, Callable(), false)
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
	HRMoraleSystem.send_on_leave(e, HRConstants.LEAVE_WEEKS, false)
	if e.leave_taken_year != int(GameState.get_date_dict().year):
		return "the automatic channel no longer stamps the year latch"
	return ""


## Bir çalışan izindeyken sprint DURMAZ: izindeki kişi ekipten düşer, kalan kurucu kartı yürütür.
## Herkes düşünce (çalışan izinde, kurucu Ar-Ge'de) kapasite sıfırdır ve kart o hafta ilerlemez.
## İki yön de ölçülür, yoksa "hiç durmuyor" da bu vakayı geçerdi.
static func _case_leave_does_not_pause_build() -> String:
	ResearchTree.reload()
	RnDSystem.reset()
	_seed_sprint()
	var dev: Character = _make_employee("char_leave_sprint", "Leave Dev", HRConstants.ROLE_DEVELOPER)
	_park_leave([dev])
	var card_id: String = "feat:line_note_tool_capture_k1"
	SprintSystem.add(card_id)
	if not SprintSystem.start():
		return "fixture: the sprint did not start"
	if not GameState.product.cards[card_id].assignees.has(dev.id):
		return "fixture: the developer was not on the card's first week"
	HRMoraleSystem.send_on_leave(dev, HRConstants.LEAVE_WEEKS, false)
	if dev.status != HRConstants.STATUS_ON_LEAVE:
		return "send_on_leave did not park %s" % dev.id
	var before: float = _card_worked(card_id)
	_sim_day()
	if _card_worked(card_id) <= before:
		return "an employee on leave stopped the sprint while the founder was free"
	if GameState.product.cards[card_id].assignees.has(dev.id):
		return "the week after the leave still staffs the card with the person on leave"
	# Şimdi kurucu da: araştırma kişinin tamamını alır. Ar-Ge yayından sonra açılır.
	GameState.set_flag("mvp_shipped", true)
	var founder: Character = CharacterRegistry.get_founder()
	for area in HRConstants.AREAS:
		founder.role_stats[area] = HRConstants.AREA_MAX
	if RnDSystem.start("data_model", [founder.id]) != "":
		return "fixture: the founder could not start research"
	if SprintSystem.capacity() != 0:
		return "with everyone away the sprint still reads %d points" % SprintSystem.capacity()
	var frozen: float = _card_worked(card_id)
	_sim_day()
	if absf(_card_worked(card_id) - frozen) > 0.0001:
		return "the card moved with nobody on the sprint (%.2f -> %.2f)" % [frozen, _card_worked(card_id)]
	return ""


static func _case_money_never_double_minus() -> String:
	# İşten çıkarma nakdi eksiye geçirebilir; Fmt.money_exact işaretini kendi basar, önizleme satırları çift eksi taşımamalı.
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


## §19 — OKUMA YÜZEYİ. "Adlar kararlıdır ve iç yapı değişse bile korunur. Olay motoru
## geldiğinde işi bunları OKUMAK olacak, keşfetmek değil."
##
## Bu case bir SÖZLÜK denetimidir: eksik bir ad, içeriğin o duruma asla atıfta
## bulunamaması demektir (§19'un attribution yasası). Sinyaller dinleyicisi olmasa da
## yayınlanır. Sprint seam'leri motoru okur: tür seçilmeden sprint yoktur.
##
## FALSİFİKASYON: EventBus'tan `line_completed` sinyalini sil → sinyal iddiası FAIL.
## ProductRead.market_word'ü sil → sorgu iddiası FAIL.
static func _case_product_read_catalogue() -> String:
	ProductLines.reload()
	_seed_support_fixture("b2c")
	ProductState.set_line_tier("line_note_tool_search", 1)
	ProductState.stamp_step("line_note_tool_search_k1", 1.0)

	# --- SORGULAR ---
	var q: Dictionary = {
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
		"support_staffed": ProductRead.support_staffed(""),
		"step_unlockable": ProductRead.step_unlockable("line_note_tool_search_k2"),
	}

	# Birkaçının GERÇEKTEN okuduğunu kanıtla — imza sınavı yeterli değil.
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

	# --- SİNYALLER ---
	var declared: Array[String] = []
	for d in EventBus.get_signal_list():
		declared.append(String((d as Dictionary).get("name", "")))
	for name in ["version_shipped", "fix_run_started", "fix_run_finished", "bug_confirmed",
			"unconfirmed_threshold_crossed", "axis_floor_warning", "axis_floor_crossed",
			"line_upgraded", "line_completed", "delighter_shipped", "phase_bar_raised"]:
		if not declared.has(name):
			return "§19 signal '%s' is not declared on EventBus" % name

	# --- SPRINT: seam'ler motoru okur ---
	if int(EvSeams.read("urun.sprint_number")) != 0 or bool(EvSeams.read("urun.sprint_running")):
		return "an untyped product reads a sprint (%s, running %s)" % [
			EvSeams.read("urun.sprint_number"), EvSeams.read("urun.sprint_running")]
	SprintSystem.choose_type("note_tool", "Fokus")
	SprintSystem.add("feat:line_note_tool_capture_k1")
	SprintSystem.start()
	if int(EvSeams.read("urun.sprint_number")) != 1 or not bool(EvSeams.read("urun.sprint_running")) \
			or int(EvSeams.read("urun.sprint_week")) != 1:
		return "a started sprint reads number %s, running %s, week %s" % [EvSeams.read("urun.sprint_number"),
			EvSeams.read("urun.sprint_running"), EvSeams.read("urun.sprint_week")]

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


## §12.3 MÜHÜRLÜ MERDİVEN, dört kuralın dördü de. Tek yerde yaşar (ProductLines); aday kartlar
## sıradaki kademeyi buradan okur.
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
	GameState.set_flag(ProductState.VERSION_LAUNCH_DAY, maxf(1.0, ProductSystem.clock_stamp() - 2.0))
	GameState.set_flag(ProductState.INTEREST, 62.5)
	GameState.set_flag(ProductState.INFRA_PROVIDER, "cloud")
	GameState.set_flag(ProductState.INFRA_UNITS, 7)

	var age_before: float = ProductState.version_age()
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
	if not is_equal_approx(ProductState.version_age(), age_before):
		_cleanup_save_slots()
		return "version age drifted across the reload (%.3f vs %.3f)" \
			% [ProductState.version_age(), age_before]
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


## Kurucuyu her alanda tavana çıkarır ve yapım işine oturtur: kapılar bu vakaların konusu değil.
static func _seed_build_crew() -> Character:
	var founder: Character = CharacterRegistry.get_founder()
	for area in HRConstants.AREAS:
		founder.role_stats[area] = HRConstants.AREA_MAX
	CharacterRegistry.clear_jobs(founder.id)
	CharacterRegistry.assign_job(founder.id, HRConstants.JOB_BUILD)
	return founder


## Bir kurucu araştırmaya geçince: (a) araştırma İŞİ üstünde, (b) türetilmiş ALAN AYNASI
## boşalır, (c) eski işi SİLİNMEZ, duraklar, (d) odak 1,00 kalır (araştırma iki-iş bölmesine
## tabi değil), (e) sprint ekibinden düşer ve kartına iş dökmez.
##
## FALSİFİKASYON: HRConstants.areas_for_jobs'tan `is_exclusive_job` continue'sunu kaldır →
## (b) FAIL. `_displace_job`'u paused_job_ids'e yazmayacak şekilde değiştir → (c) FAIL.
## SprintSystem.team'den JOB_RESEARCH süzgecini kaldır → (e) FAIL.
static func _case_research_occupies_person() -> String:
	ResearchTree.reload()
	RnDSystem.reset()
	_seed_sprint()
	GameState.set_flag("mvp_shipped", true)      # §2 — Ar-Ge v1 yayınından sonra açılır
	var founder: Character = _seed_build_crew()
	var card_id: String = "feat:line_note_tool_capture_k1"
	SprintSystem.add(card_id)
	if not SprintSystem.start():
		return "fixture: the sprint did not start"
	if _sprint_points(founder.id) <= 0.0:
		return "fixture: a free founder is not on the sprint team"

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
	# (e) sprint ekibinden düştü ve kartına iş DÖKMÜYOR
	if _sprint_points(founder.id) > 0.0:
		return "a researching founder still works the sprint"
	var frozen: float = _card_worked(card_id)
	_sim_day()
	if _card_worked(card_id) > frozen + 0.0001:
		return "a researching founder's card kept moving (%.4f -> %.4f)" % [frozen, _card_worked(card_id)]
	return ""


## §5.0 İKİ YÖNLÜ ÇALIŞIR, ve iki yön TEK PROSESTE denenir: tek yönlü bir gerileme
## ikisini ayrı vakaya bölseydik saklanabilirdi.
##   yön A · kurucu sprintteyken araştırma başlatır → sprint ekibinden düşer
##   yön B · kurucu araştırırken yapım işine döner  → araştırma DONAR, ilerleme korunur
##
## FALSİFİKASYON: registry'nin displacement'ını yön B için kaldır → ikinci yarı FAIL ve
## araştırma yapımla birlikte akmaya devam eder.
static func _case_research_and_build_pause_each_other() -> String:
	ResearchTree.reload()
	RnDSystem.reset()
	_seed_sprint()
	GameState.set_flag("mvp_shipped", true)
	var founder: Character = _seed_build_crew()

	# --- YÖN A: sprint koşuyor, araştırma başlıyor ---
	SprintSystem.add("feat:line_note_tool_capture_k1")
	if not SprintSystem.start():
		return "fixture: the sprint did not start"
	# One star in the root's area, its own requirement: a stronger founder finishes it in a week.
	founder.role_stats[HRConstants.AREA_PRODUCT] = 2
	if RnDSystem.start("data_model", [founder.id]) != "":
		return "fixture: research would not start"
	if RnDSystem.weeks_estimate("data_model", [founder.id]) <= 2.0:
		return "fixture: the research would finish within two ticks"
	if _sprint_points(founder.id) > 0.0:
		return "direction A: starting a research left the founder on the sprint team"

	# Araştırma gerçekten akıyor mu.
	RnDSystem.daily_tick()
	var moved: float = RnDSystem.progress_effort("data_model")
	if moved <= 0.0:
		return "direction A: the research did not accrue while the founder was off the sprint"

	# --- YÖN B: araştırma koşarken yapım işine dönüş ---
	CharacterRegistry.assign_job(founder.id, HRConstants.JOB_BUILD)
	if founder.assigned_job_ids.has(HRConstants.JOB_RESEARCH):
		return "direction B: going back to the build left the founder on research"
	if not RnDSystem.is_frozen():
		return "direction B: the research did not freeze when the founder went to build"
	if _sprint_points(founder.id) <= 0.0:
		return "direction B: the founder back from research is not on the sprint team"
	# İLERLEME KORUNUR, yanmaz (§5.7).
	if abs(RnDSystem.progress_effort("data_model") - moved) > 0.0001:
		return "direction B: freezing BURNED progress (%.4f -> %.4f)" \
			% [moved, RnDSystem.progress_effort("data_model")]
	RnDSystem.daily_tick()
	if abs(RnDSystem.progress_effort("data_model") - moved) > 0.0001:
		return "direction B: a frozen research kept accruing"
	return ""


# ============================================================================
#  AR-GE §5.0 — ARAŞTIRMA İNSANI MEŞGUL EDER
#
#  Modülün TEMELİ ve bütün paketin kabul testi. §1'in tek cümlesi şu: "birini masadan
#  kaldırıp araştırmaya verirsin, o kişi o süre boyunca ürün yapmaz." Bu kural gerçekten
#  kurulmazsa araştırma hiçbir şeye mal olmaz ve her araştırma bariz bir evete dönüşür.
# ============================================================================

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
	var founder: Character = CharacterRegistry.get_founder()
	for area in HRConstants.AREAS:
		founder.role_stats[area] = HRConstants.AREA_MAX
	# One star in the root's area, its own requirement: a stronger founder finishes it in a week.
	founder.role_stats[HRConstants.AREA_PRODUCT] = 2
	CharacterRegistry.clear_jobs(founder.id)

	if RnDSystem.start("data_model", [founder.id]) != "":
		return "fixture: research would not start"
	if RnDSystem.weeks_estimate("data_model", [founder.id]) <= 2.0:
		return "fixture: the research would finish within two ticks"
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


## BÖLÜNMÜŞ ODAK SEBEBİNİ SÖYLER. Kurucu DESTEK'teyken ikinci sürekli bir işe girerse ikisi de
## koşar ve ikisi de yavaşlar (Ekip §12.1, odak 0,50/0,50). Bildirimler doğrulanmaktan hızlı
## birikir ve oyuncu işe alması gerektiğini anlar; yavaşlığın SEBEBİ ekranda yazmazsa bu haksız
## bir kayıptır. İki yüzü ölçülür:
##   · DESTEK kartı bölünmeyi söylüyor
##   · kurucunun kendi durum satırı iki kısa etiketi `·` ile birleştiriyor (Ekip §12.2)
##
## FALSİFİKASYON: BuildBarModel.derive'daki masa döngüsünü sil → DESTEK iddiası FAIL.
## `founder_task_label`'ın kompozisyon dalını sil → satır tek etikete düşer ve FAIL.
static func _case_split_bars_name_their_cause() -> String:
	_seed_support_fixture("b2c")
	GameState.set_flag("pitch_prep_active", false)
	var founder: Character = CharacterRegistry.get_founder()
	for area in HRConstants.AREAS:
		founder.role_stats[area] = HRConstants.AREA_MAX
	CharacterRegistry.clear_jobs(founder.id)
	var bar_model: GDScript = load("res://scripts/ui/components/build_bar_model.gd")

	# TEK İŞ: kart bölünmeden söz etmez.
	if CharacterRegistry.assign_job(founder.id, HRConstants.JOB_SUPPORT) != "":
		return "fixture: support refused"
	var single = bar_model.new()
	if not single.derive():
		return "fixture: the DESTEK card derived nothing"
	if String(single.split_note_key) != "":
		return "a single-job founder produced a split note"

	if CharacterRegistry.assign_job(founder.id, HRConstants.JOB_BUILD) != "":
		return "fixture: build refused as a second continuous job"
	if not HRSystem.is_overloaded(founder):
		return "two continuous jobs did not read as overloaded"

	# 1 · DESTEK KARTI sebebi yazıyor.
	var split = bar_model.new()
	split.derive()
	if String(split.split_note_key) != "BUILD_SPLIT_FOCUS":
		return "the DESTEK card does not name the split"

	# 2 · KURUCUNUN DURUM SATIRI iki kısa etiketi orta noktayla birleştiriyor (§12.2).
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
## raporu zorla → rozet-sıfır iddiası FAIL. `_ready`'deki `add_child(_closed())` satırını `_build()` yap →
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
	if _node_tree_has_text(page, TranslationServer.translate("RND_LEGEND_INTRA")):
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
## cümleye rakam ekle → basamak iddiası FAIL, anahtarı adıyla yazarak. mark_note_read'ten
## MessageSystem.mark_read'i sil → kutudaki not okunmamış kalır ve son iddia FAIL.
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

	# The inbox keeps the note, and reading it in the Ar-Ge tab reads the message too.
	RnDSystem._note_last_day = 0
	GameState.day = TimeModel.ticks(ResearchTree.report_period_weeks())
	RnDSystem._tick_note()
	var posted: Array = GameState.messages.filter(func(m: Dictionary) -> bool: return m.kind == "rnd_note")
	if posted.size() != 1 or posted[0].read:
		return "the note did not reach the inbox unread: %s" % str(posted)
	RnDSystem.mark_note_read()
	if not posted[0].read:
		return "a note read in the Ar-Ge tab stayed unread in the inbox"

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
## uses must either produce a chip or be named in EvChips.SILENT_VERBS.
##
## FALSIFICATION: delete one arm from EvChips.describe's match and this case names it.
static func _case_event_chip_coverage() -> String:
	EvCatalog.reload()
	var blind: Array = []
	var silent: Array = EvChips.SILENT_VERBS
	if silent.is_empty():
		return "EvChips.SILENT_VERBS is empty — the rule has no exemption list"
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
					if EvChips.describe(e, {}, {}, false).is_empty():
						var row: String = "%s/%s:%s" % [id, opt.get("id", "?"), verb]
						if not blind.has(row):
							blind.append(row)
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
		pending.append({"event_id": "customer.retention", "context": {}})
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

	# THE DEMOTED CARD'S CLOCK (§12.4). A two-week paper reads its last week as `expiring` and
	# gets the last warning the tick before it expires; a one-week paper is in its last week
	# from the start ("this week"), never reads `expiring` and expires with no warning.
	var two_key: String = EvLatches.key_of("fixture.concurrent", {})
	var one_key: String = EvLatches.key_of("fixture.hourly_ambient", {})
	EvPapers.place("fixture.concurrent", {}, 2)
	EvPapers.place("fixture.hourly_ambient", {}, 1)
	for row in EventGate.desk_papers(8):
		var r: Dictionary = row
		var want_left: int = 2 if String(r["id"]) == two_key else 1
		if int(r["weeks_left"]) != want_left or bool(r["expiring"]):
			return "a fresh %d-week paper reads %d week(s), expiring %s" % [
				want_left, int(r["weeks_left"]), str(r["expiring"])]
	GameState.day += 1
	if not EvPapers.is_expiring(two_key) or not EvPapers.needing_last_warning().has(two_key):
		return "a two-week paper in its last week is not expiring"
	EvEngine._step_paper_expiry()
	if not EvQueue.holds(two_key):
		return "the two-week paper got no last warning"
	if EvPapers.has(one_key) or EvQueue.holds(one_key):
		return "the one-week paper outlived its week or drew a last warning"
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
		[{"seam": "hr.morale", "delta": 0.2}, {"seam": "hr.tenure_weeks", "delta": -0.1}],
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
## engine exists: a decision in week 2 produces a visible consequence in week 13, across a
## save/load, and the player can trace the link.
static func _case_event_thesis_day10_to_day90() -> String:
	var shipped: Array = EvTuning.SHIPPED_SCOPES.duplicate()
	EvTuning.SHIPPED_SCOPES.append("fixture")
	GameState.initialize_run({"seed": 424242})
	EvEngine.reset()
	EvCatalog.reload()

	GameState.day = 2
	if not EvEngine.force_fire("fixture.thesis_open"):
		EvTuning.SHIPPED_SCOPES.assign(shipped)
		return "the week-2 card would not fire"
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

	GameState.day = 13
	var due: Array = EvSchedule.take_due()
	var found: bool = false
	for e in due:
		if String((e as Dictionary)["event_id"]) == "fixture.thesis_payoff":
			found = true
	if not found:
		EvTuning.SHIPPED_SCOPES.assign(shipped)
		return "the payoff was not due in week 13"

	# The load-bearing assertion: the condition reads a choice made eleven weeks ago.
	var cond: Dictionary = EvCatalog.card("fixture.thesis_payoff")["condition"]
	if not EvCondition.eval(cond):
		EvTuning.SHIPPED_SCOPES.assign(shipped)
		return "the payoff's condition could not read the week-2 choice"

	if not EvEngine.force_fire("fixture.thesis_payoff"):
		EvTuning.SHIPPED_SCOPES.assign(shipped)
		return "the payoff would not fire in week 13"
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
## directly. This one runs the same week-2 → week-13 arc through everything a player touches:
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

	GameState.day = 2
	if not EventGate.request("fixture.thesis_open"):
		EventBus.modal_requested.disconnect(on_modal)
		return "the week-2 card was refused"
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

	# A paper due the SAME TICK as the payoff, so the desk half is exercised on the tick that
	# matters rather than on a quiet one.
	EvSchedule.add("fixture.concurrent", 11)

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
		crowd.append({"event_id": "customer.retention", "context": {}})
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
	crowd.append({"event_id": "fixture.thesis_payoff", "context": {}})
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

	# --- WEEK 13 ----------------------------------------------------------------------------
	shown.clear()
	GameState.day = 13
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
		return "the payoff did not reach the screen in week 13 (shown: %d card(s))" % shown.size()
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
	if int(paper["weeks_left"]) <= 0:
		return "the paper landed with no clock (%d)" % int(paper["weeks_left"])

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
## honest line; the company cannot be offered again for RETURN_LOCK_WEEKS, and the return is
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
	# A lead lives LEAD_LIFE_WEEKS; the expiry runs after the rep desk, so the next tick's desk
	# still sees it before it goes.
	var life: int = TimeModel.ticks(SalesConstants.LEAD_LIFE_WEEKS)
	if p.weeks_left() != life:
		return "a fresh lead shows %d weeks, want %d" % [p.weeks_left(), life]
	for i in life:
		GameState.advance_day()
		SalesFaucetSystem.daily_tick()
		SalesFaucetSystem.expire_leads()
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
	for i in TimeModel.ticks(SalesConstants.RETURN_LOCK_WEEKS) + 1:
		GameState.advance_day()
		SalesFaucetSystem.daily_tick()
	if SalesFaucetSystem.is_return_locked(name):
		return "the return lock never lifted"
	return ""


## §5.0 THE TIME SKIP AND THE ENTRY GATE. Closing a sitting costs MEETING_SKIP_HOURS and those
## hours are SIMULATED through the real hourly path. The founder is not zeroed: each skipped hour
## keeps 1 − HOURS_PER_DAY / WEEK_WORK_HOURS of the founder's output, so a meeting costs the week
## exactly hours / WEEK_WORK_HOURS (5 % for two hours). The output measured is the support desk's
## validation, the hourly work the founder's share reaches; the sprint works by the week. The busy
## flag lives only while the sitting is open and never reaches a save. Entry is shut at night and
## near the founder's end, four meetings fill the week whatever the workday's length, and a skip
## never crosses midnight.
## FALSIFICATION: drop founder_share from SupportSystem's hourly validation and the solo ratio
## reads 1.0; drop the midnight clamp in TimeManager.advance_hours and the late skip runs the
## daily tick.
static func _case_sales_meeting_time_skip_founder_share() -> String:
	_seed_support_fixture("b2b")
	GameState.set_flag("mvp_sub_product_type_id", "erp")
	GameState.set_cash(50000)
	# A pile the desk never empties, so every hour validates exactly its rate.
	GameState.set_flag(ProductState.REPORTS_INCOMING, 10000)
	var founder: Character = CharacterRegistry.get_founder()
	founder.role_stats[HRConstants.AREA_CUSTOMER_SUCCESS] = HRConstants.AREA_MAX
	CharacterRegistry.clear_jobs(founder.id)
	if CharacterRegistry.assign_job(founder.id, HRConstants.JOB_SUPPORT) != "":
		return "fixture: the founder could not take the support desk"
	var validated := func() -> float:
		return float(ProductState.bugs_confirmed()) + float(GameState.get_flag(ProductState.VALIDATION_PROGRESS, 0.0))
	var skip: int = SalesConstants.MEETING_SKIP_HOURS

	# SOLO — the founder is the desk: two ordinary hours, then a meeting's two hours.
	var lead: Prospect = SalesFaucetSystem.spawn(1, "faucet")
	if lead == null:
		return "the faucet produced no lead to sit at"
	var e0: float = validated.call()
	TimeManager.advance_hours(skip)
	var plain: float = validated.call() - e0
	if plain <= 0.0:
		return "a founder-only desk validated nothing in ordinary hours"
	var hour_before: int = GameState.current_hour
	SalesMeetingSystem.open(lead.id)
	if not HRSystem.founder_in_meeting:
		return "the open sitting did not seat the founder"
	var saved: String = JSON.stringify([SaveCodec.capture_game_state(),
		SaveCodec.capture_registries(), SaveManager._capture_systems()])
	if saved.contains("founder_in_meeting") or saved.contains("sales_meeting_active"):
		return "the sitting's busy flag reached the save state"
	var e1: float = validated.call()
	SalesMeetingSystem.close()
	var met: float = validated.call() - e1
	if GameState.current_hour - hour_before != skip:
		return "the clock moved %d hours, want %d" % [GameState.current_hour - hour_before, skip]
	var keep: float = 1.0 - float(TimeModel.HOURS_PER_DAY) / float(TimeModel.WEEK_WORK_HOURS)
	if absf(met - plain * keep) > 0.0001:
		return "the meeting's hours kept %.3f of the founder's output, want %.3f" % [met / plain, keep]
	# A tick is HOURS_PER_DAY such hours, so the week lost exactly skip / WEEK_WORK_HOURS.
	var week_loss: float = (plain - met) / (plain / float(skip) * float(TimeModel.HOURS_PER_DAY))
	var want_share: float = float(skip) / float(TimeModel.WEEK_WORK_HOURS)
	if absf(week_loss - want_share) > 0.0001 or not is_equal_approx(GameState.founder_meeting_share(), want_share):
		return "one meeting cost %.4f of the week (share %.4f), want %.4f" % [
			week_loss, GameState.founder_meeting_share(), want_share]

	# TEAM — a rep at the desk, and the same two hours flow at full rate for them.
	var rep: Character = _make_employee("char_rep_skip", "Deniz", HRConstants.ROLE_CUSTOMER_REP)
	rep.role_stats[HRConstants.AREA_CUSTOMER_SUCCESS] = HRConstants.AREA_MAX
	if not SupportSystem.desk_roster().has(rep):
		return "fixture: the rep was not seated at the desk"
	var lead2: Prospect = SalesFaucetSystem.spawn(1, "faucet")
	if lead2 == null:
		return "the faucet produced no second lead"
	var team_before: float = validated.call()
	SalesMeetingSystem.open(lead2.id)
	SalesMeetingSystem.close()
	if validated.call() - team_before <= met:
		return "a staffed desk did not outrun the founder alone across the skipped hours"
	# And the flag is DOWN afterwards: a founder stuck busy is worse than one never freed.
	if HRSystem.founder_in_meeting:
		return "the meeting flag survived the close"

	# THE WEEK'S CAP on a day that ends at midnight: four meetings, then the week is full with
	# hours still left. The next week starts at 08:00 through the real night skip.
	WorkHoursSystem.set_company_start_hour(TimeModel.WEEK_START_HOUR)
	WorkHoursSystem.set_company_hours(TimeModel.WORKDAY_LATEST_END - TimeModel.WEEK_START_HOUR)
	_sim_to_morning()
	if SalesLedger.meetings_this_week() != 0 or GameState.founder_meeting_share() != 0.0:
		return "a new week kept last week's meetings (%d, share %.2f)" % [
			SalesLedger.meetings_this_week(), GameState.founder_meeting_share()]
	for i in SalesConstants.MEETINGS_PER_WEEK:
		var table: Prospect = SalesFaucetSystem.spawn(1, "faucet")
		var why: String = SalesLedger.meeting_block_reason(table.id)
		if why != "":
			return "meeting %d of the week was refused at %02d:00: %s" % [i + 1, GameState.current_hour, why]
		SalesMeetingSystem.open(table.id)
		SalesMeetingSystem.close()
	var fifth: Prospect = SalesFaucetSystem.spawn(1, "faucet")
	if SalesLedger.meeting_block_reason(fifth.id) != "SALES_BLOCK_WEEK_FULL":
		return "the fifth meeting at %02d:00 reads '%s', want the week full" % [
			GameState.current_hour, SalesLedger.meeting_block_reason(fifth.id)]
	if not is_equal_approx(GameState.founder_meeting_share(),
			float(SalesConstants.MEETINGS_PER_WEEK * skip) / float(TimeModel.WEEK_WORK_HOURS)):
		return "four meetings cost %.3f of the week" % GameState.founder_meeting_share()

	# A DAY ENDING AT 24:00 counts as 23:00 for a sitting: the last entry runs its full hours and
	# lands at 23:00, so the rollover with its daily tick waits for the night skip.
	GameState.sales_meetings_week.clear()
	var last_entry: int = TimeModel.HOURS_PER_DAY - 1 - SalesConstants.MEETING_ENTRY_CUTOFF_HOURS
	GameState.set_current_hour(last_entry + 1)
	TimeManager.sync_to_current_hour()
	if SalesLedger.meeting_block_reason(fifth.id) != "SALES_BLOCK_TOO_LATE":
		return "an entry at %02d:00 would run past 23:00 on a day ending at midnight: '%s'" % [
			GameState.current_hour, SalesLedger.meeting_block_reason(fifth.id)]
	GameState.set_current_hour(last_entry)
	TimeManager.sync_to_current_hour()
	var day0: int = GameState.day
	if SalesLedger.meeting_block_reason(fifth.id) != "":
		return "entry at %02d:00 refused on a day that ends at midnight: %s" % [
			GameState.current_hour, SalesLedger.meeting_block_reason(fifth.id)]
	SalesMeetingSystem.open(fifth.id)
	SalesMeetingSystem.close()
	if GameState.day != day0 or GameState.current_hour != TimeModel.HOURS_PER_DAY - 1:
		return "the late meeting did not land at 23:00 on its own tick (tick %d, %02d:00)" % [
			GameState.day, GameState.current_hour]

	# THE NIGHT is shut whatever the week's count.
	GameState.sales_meetings_week.clear()
	GameState.set_current_hour(TimeModel.WEEK_START_HOUR - 1)
	TimeManager.sync_to_current_hour()
	if SalesLedger.meeting_block_reason(fifth.id) != "SALES_BLOCK_TOO_LATE":
		return "a night entry reads '%s', want too late" % SalesLedger.meeting_block_reason(fifth.id)
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
	GameState.sales_meetings_week.clear()
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
## FALSIFICATION: drop the ledger check from SalesMeetingSystem._promise_lock and the second
## table offers a second word while the first is still owed.
static func _case_sales_single_open_promise_lock() -> String:
	GameState.set_flag("mvp_shipped", true)
	GameState.set_flag("mvp_market_type", "b2b")
	GameState.set_flag("mvp_sub_product_type_id", "ai_vector_search")   # a pool with features
	GameState.set_flag("mvp_components", [])
	var facts: Dictionary = {"has_promise_target": true, "open_pitch_promise": true}
	var row: Dictionary = {"answers": [{"id": "a_promise", "verb": SalesProbes.VERB_PROMISE}]}
	var locked: Array = SalesProbes.answers_for(row, facts, "open_pitch_promise")
	if locked.is_empty():
		return "the promise row vanished instead of locking"
	if bool((locked[0] as Dictionary).get("open", true)):
		return "the promise row is open while a word is already owed"
	if String((locked[0] as Dictionary).get("lock_fact", "")) != "open_pitch_promise":
		return "the lock does not name the open promise: %s" % \
			String((locked[0] as Dictionary).get("lock_fact", ""))
	# Unlocked, the same row is playable — so the lock is the promise and nothing else.
	var free_rows: Array = SalesProbes.answers_for(row, facts, "")
	if free_rows.is_empty() or not bool((free_rows[0] as Dictionary).get("open", false)):
		return "the promise row stayed shut with no open promise"
	# And with nothing to promise the row is ABSENT rather than offered and then broken.
	var no_target: Dictionary = {"has_promise_target": false, "open_pitch_promise": false}
	if not SalesProbes.answers_for(row, no_target, "").is_empty():
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
	SalesLedger.set_open_pitch_promise(c.id)
	SalesLedger.count_meeting()
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
			["work_started_day", rp.work_started_day, p.work_started_day]]:
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
	if SalesLedger.meetings_this_week() != 1:
		return "the week's meeting count did not survive (%d)" % SalesLedger.meetings_this_week()
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
	wanted.append("SALES_LOCK_PROMISE_NO_ROOM")
	for reason in SalesConstants.LOSS_REASONS:
		wanted.append("SALES_LOSS_%s" % String(reason).to_upper())
		wanted.append("SALES_MEMORY_%s" % String(reason).to_upper())
	for cond in SalesConstants.WHALE_CONDITION_ORDER:
		wanted.append("SALES_WHALE_%s" % String(cond).to_upper())
	for stance in SalesConstants.STANCES:
		wanted.append("SALES_STANCE_%s" % String(stance).to_upper())
		wanted.append("SALES_STANCE_HINT_%s" % String(stance).to_upper())
	for key in ["SALES_BLOCK_NO_B2B", "SALES_BLOCK_WEEK_FULL", "SALES_BLOCK_TOO_LATE",
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
## weekly report carries CLOSES ONLY: churn is the customer desk's surface, and a week with no
## closes posts no report at all. A desk close carries its rep's name, the report's sender.
## FALSIFICATION: drop the newsworthy test from _maybe_ticker and the first branch fails on
## the very first routine close; pass "" from SalesRepSystem._close to record_close and the
## rep's name check fails.
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

	# The closes above belong to an earlier window; the desk's close carries its rep's name.
	var earlier: Array = SalesLedger.close_week()
	if earlier.is_empty() or String(earlier[-1].rep) != rep.character_name:
		return "the desk's close did not carry its rep's name: %s" % str(earlier)
	# THE WEEKLY REPORT carries closes and nothing else, and a quiet week produces none.
	var interval: int = TimeModel.ticks(SalesConstants.WEEKLY_SUMMARY_INTERVAL_WEEKS)
	GameState.set_flag("sales_weekly_anchor_day", GameState.day - interval)
	var reported: Array = []
	var wprobe := func(closes: int) -> void: reported.append(closes)
	EventBus.weekly_sales_report_issued.connect(wprobe)
	SalesRepSystem._tick_weekly_summary()
	if not reported.is_empty():
		EventBus.weekly_sales_report_issued.disconnect(wprobe)
		return "a week with zero closes still issued a summary"
	# With desk closes in the window it does report, and it reports the COUNT.
	var booked: Customer = CustomerRegistry.get_by_market("b2b")[0]
	for i in 3:
		SalesLedger.record_close(booked, rep.character_name)
	GameState.set_flag("sales_weekly_anchor_day", GameState.day - interval)
	SalesRepSystem._tick_weekly_summary()
	EventBus.weekly_sales_report_issued.disconnect(wprobe)
	if reported.size() != 1 or int(reported[0]) != 3:
		return "the weekly summary did not report its closes: %s" % str(reported)
	# And the window resets, or the next week reports this week's work again.
	if not (GameState.get_flag("sales_weekly_close_rows", []) as Array).is_empty():
		return "the weekly close window did not reset"
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
	var vs: Dictionary = TermSheetTableSystem.open("anchor", PitchConstants.STAGE_SEED)
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
	TermSheetTableSystem.open("anchor", PitchConstants.STAGE_SEED)
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
	GameState.day = 100 + TimeModel.ticks(SeedConstants.EXPECT_GRACE_WEEKS) - 1
	_seed_month_closes([10000, 10000, 10000, 10000])       # flat, but inside the grace window
	if SeedRoundSystem.expectation_state() != SeedConstants.EXPECT_GRACE:
		return "a flat month inside grace read as %d" % SeedRoundSystem.expectation_state()
	GameState.day = 100 + TimeModel.ticks(SeedConstants.EXPECT_GRACE_WEEKS) + 1
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
	TermSheetTableSystem.open("anchor", PitchConstants.STAGE_SEED)
	if String(TermSheetTableSystem.levers()[0]) != "raise":
		return "the seed table's first lever is '%s'" % String(TermSheetTableSystem.levers()[0])
	# The seed offer never expires, so the same fund can also hold a Series A sheet; that seat
	# must load the Series A sheet, not the older seed offer. Check the loaded TERMS, not the
	# levers: open() takes its stage from the caller, so levers() would pass either way.
	_grant("anchor")
	var series_a: TermSheet = VCPitchSystem.sheet_for("anchor")
	if series_a == null or VCPitchSystem.seed_sheet_for("anchor") == null:
		return "fixture: anchor does not hold both a seed offer and a Series A sheet"
	var want: int = VCPitchSystem.raised_for(int(series_a.opening_terms.get("valuation_m", 0)),
		int(series_a.opening_terms.get("dilution_pct", 0)))
	var seat: Dictionary = TermSheetTableSystem.open("anchor", PitchConstants.STAGE_SERIES_A)
	if seat.is_empty() or want <= 0 or TermSheetTableSystem.money_raised() != want:
		return "the Series A seat opened anchor's unsigned seed offer (raised %d, sheet %d)" % [
			TermSheetTableSystem.money_raised(), want]
	GameState.active_sheets.clear()
	TermSheetTableSystem.open("anchor", PitchConstants.STAGE_SEED)
	TermSheetTableSystem.sign()
	GameState.set_phase(3)
	_grant("nexus")
	TermSheetTableSystem.open("nexus", PitchConstants.STAGE_SERIES_A)
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
	var vs: Dictionary = TermSheetTableSystem.open("anchor", PitchConstants.STAGE_SEED)
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
	# The card's window is a literal in its JSON; it must be the constant's.
	if _card_literal(BUYOUT_ID, "funding.acq_weeks_open") != EndingsSystem.ACQ_CARD_WINDOW_WEEKS:
		return "acquisition_offer's window is %d weeks, ACQ_CARD_WINDOW_WEEKS is %d" % [
			_card_literal(BUYOUT_ID, "funding.acq_weeks_open"), EndingsSystem.ACQ_CARD_WINDOW_WEEKS]
	# THE MODAL SLOT HAS TO BE DRAINED. One card is active at a time, so an unresolved
	# foreign card blocks every later one — and a case that does not drain measures the
	# queue rather than the card it names.
	var arrived: bool = false
	for i in TimeModel.ticks(EndingsSystem.ACQ_CARD_WINDOW_WEEKS) + 2:
		_sim_day_full()
		if _drain_to(BUYOUT_ID):
			arrived = true
			break
		if not GameState.run_active:
			break
	if not arrived:
		return ("the buyout card never fired inside the window "
			+ "(road_over=%s weeks_open=%d lead=%s active=%s)" % [
				str(EndingsSystem.road_over()), EndingsSystem.acq_weeks_open(),
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
	var body: String = ev.body_text.replace("
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


## THE OFFICE LADDER: its gates, its week and its save. A fresh run sits in the flat; the
## business block opens on Frank's cheque and its cash bar, not a dollar short; the move lands
## MOVE_WEEKS ticks later and not a tick early; the flat is no way back; the office survives a real save
## file; and that file aged to v12 (no office fields) puts a run that took the cheque in the
## business block and leaves one that did not at home.
static func _case_office_move_gates_and_save() -> String:
	if OfficeSystem.current() != "home":
		return "a fresh run starts in '%s', want home" % OfficeSystem.current()
	if OfficeSystem.can_move_to("ishani"):
		return "the business block opened before Frank's cheque"
	GameState.record_angel_round(AngelRoundSystem.EQUITY_PCT, AngelRoundSystem.CASH_AMOUNT)
	var cash_bar: int = (OfficeConstants.CATALOG["ishani"].reqs as Array) \
		.filter(func(r: Dictionary) -> bool: return r.kind == "cash")[0].value
	GameState.set_cash(cash_bar - 1)
	if OfficeSystem.can_move_to("ishani"):
		return "the business block opened a dollar short of its cash bar"
	GameState.set_cash(cash_bar)
	if not OfficeSystem.can_move_to("ishani"):
		return "cheque and cash left the business block shut: %s" \
			% str(OfficeSystem.requirement_state("ishani"))
	if not OfficeSystem.move_to("ishani") or not OfficeSystem.is_moving():
		return "move_to did not start a move"
	if OfficeSystem.move_to("ishani"):
		return "a second move started while the first was on the road"
	for i in TimeModel.ticks(OfficeConstants.MOVE_WEEKS):
		if OfficeSystem.current() != "home":
			return "arrived after %d tick(s), want %d" % [i, OfficeConstants.MOVE_WEEKS]
		_sim_day()
	if OfficeSystem.current() != "ishani" or OfficeSystem.is_moving():
		return "after %d ticks the office is '%s' (moving: %s)" \
			% [OfficeConstants.MOVE_WEEKS, OfficeSystem.current(), OfficeSystem.is_moving()]
	if OfficeSystem.can_move_to("home"):
		return "the flat is offered as a way back"

	_drain_all_modals()   # a card on screen refuses the save (can_save)
	var slot: String = "smoke_office_%d" % OS.get_process_id()
	var done := func(why: String) -> String:
		SaveManager.delete_slot(slot)
		return why
	if not SaveManager.save_to_slot(slot):
		return done.call("save_to_slot failed (%s)" % SaveManager.cannot_save_reason_key())
	var path: String = SaveManager.SAVE_DIR + slot + ".json"
	var raw: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(path)) as Dictionary
	var gs: Dictionary = (raw.get("state", {}) as Dictionary).get("game_state", {}) as Dictionary
	if String(gs.get("office_id", "")) != "ishani":
		return done.call("the file holds office_id '%s'; stripping it would prove nothing"
			% gs.get("office_id", ""))
	if not SaveManager.apply_loaded_state(SaveManager.read_slot(slot)):
		return done.call("apply_loaded_state returned false")
	if OfficeSystem.current() != "ishani":
		return done.call("the save loaded back into '%s'" % OfficeSystem.current())

	# The same file aged to v12: the office fields gone, the schema explicit.
	for k in ["office_id", "office_move_to", "office_move_day", "mentor_line_key", "mentor_line_args"]:
		gs.erase(k)
	raw["schema_version"] = 12
	for angel in [AngelRoundSystem.CASH_AMOUNT, 0]:
		gs["run_angel_amount"] = angel
		var w := FileAccess.open(path, FileAccess.WRITE)
		w.store_string(JSON.stringify(raw, "\t", false, true))
		w.close()
		var state: Dictionary = SaveManager.read_slot(slot).get("state", {})
		var got: String = String(state.get("game_state", {}).get("office_id", ""))
		var want: String = "ishani" if angel > 0 else "home"
		if got != want:
			return done.call("a v12 save with angel %d migrated to '%s', want '%s'" % [angel, got, want])
	return done.call("")


# =========================================================================
#  ÜRÜN · SPRINT MOTORU
# =========================================================================

## Ürünü Ürün sekmesinin yolundan kurar: tür seçilir, Sprint 1 bugün planlamada açılır. Kasa
## kepenk sayacını başlatmayacak kadar derin; ekipte yalnız kurucu var. İstek oranı 0'dır (test
## sabiti): sprint karar kartları destededir, kararı ölçen vaka oranı kendisi açar.
static func _seed_sprint(subtype: String = "note_tool") -> void:
	ProductLines.reload()
	GameState.set_cash(500000)
	(SprintCatalog.cfg("decision") as Dictionary).rate = 0.0
	SprintSystem.choose_type(subtype, "Notly")


## Yayındaki ürün: Çekirdek'in ilk üç kimlik yeteneği K1'de, MVP sürümü çıkmış. Sprint kapanışı
## bunu MVP'den sonraki her sürüm gibi okur.
static func _seed_sprint_live(subtype: String) -> void:
	_seed_sprint(subtype)
	for line_id in SprintCatalog.capabilities("core").slice(0, int(SprintCatalog.cfg("mvp_lines"))):
		ProductState.set_line_tier(line_id, 1)
	GameState.set_flag("mvp_shipped", true)
	GameState.set_flag("mvp_version", 1)


## Orta becerili (ana alanı 5), orta moralli bir ekip üyesi; izin haftası park edilir.
static func _sprint_hire(id: String, role_id: String) -> Character:
	var c: Character = _make_employee(id, id, role_id, SEED_PACE, 0, 60)
	_park_leave([c])
	return c


## Kişinin bu sprintte haftalık puanı; ekipte değilse (izin, Ar-Ge) 0.
static func _sprint_points(id: String) -> float:
	for person in SprintSystem.team():
		if person.id == id:
			return person.points
	return 0.0


## Kartın üç fazına dökülmüş toplam puan; kart saklanmıyorsa (aday ya da çıkmış) 0.
static func _card_worked(card_id: String) -> float:
	var c: Dictionary = GameState.product.cards.get(card_id, {})
	return 0.0 if c.is_empty() else float(c.progress[0]) + float(c.progress[1]) + float(c.progress[2])


## Kartları bu sprinte koyar, başlatır ve iki haftasını oyunun günlük dağıtımıyla oynar; sürüm
## notundaysa önce sonraki sprintin planlamasına geçer. Sprint başlamazsa false.
static func _play_sprint(card_ids: Array) -> bool:
	if SprintSystem.mode() == "release":
		SprintSystem.plan_next()
	for id in card_ids:
		SprintSystem.add(id)
	if not SprintSystem.start():
		return false
	_sim_day()
	_sim_day()
	return true


## Sprint tam iki gün (iki hafta) sürer: başlatıldığı gün birinci hafta, ertesi gün ikinci, bir
## sonraki günün tikinde kapanır ve sürüm notu o gün yazılır.
static func _case_sprint_two_days_close() -> String:
	_seed_sprint()
	var closed: Array = []
	EventBus.sprint_closed.connect(func(n: int) -> void: closed.append(n))
	var start_day: int = GameState.day
	SprintSystem.add("feat:line_note_tool_capture_k1")
	if not SprintSystem.start():
		return "fixture: the sprint did not start"
	if SprintSystem.mode() != "active" or SprintSystem.week() != 1:
		return "a started sprint reads %s week %d, want active week 1" % [SprintSystem.mode(), SprintSystem.week()]
	_sim_day()
	if SprintSystem.mode() != "active" or SprintSystem.week() != 2 or not closed.is_empty():
		return "one day in: %s week %d, closes %s; want active week 2" % [SprintSystem.mode(), SprintSystem.week(), closed]
	_sim_day()
	if closed != [1] or SprintSystem.mode() != "release":
		return "two days in: closes %s, %s; want sprint 1 closed onto its release note" % [closed, SprintSystem.mode()]
	if int(GameState.product.release.day) != start_day + 2:
		return "the release note is dated %d, want start %d + 2" % [int(GameState.product.release.day), start_day]
	return ""


## Kapasite Ekip'ten okunur: kişi başına haftada iki puan × beceri bandı × moral bandı × çalışma
## saati, iki hafta; kurucunun bandı sabittir. Moral bandı kişinin puanını değiştirir, Ar-Ge'ye
## alınan ve izne çıkan kişi ekipten düşer; kimse kalmayınca "+" kapanır.
static func _case_sprint_capacity_from_team() -> String:
	ResearchTree.reload()
	RnDSystem.reset()
	_seed_sprint()
	var weeks: int = int(SprintCatalog.cfg("sprint_weeks"))
	var point: float = float(SprintCatalog.cfg("person_points_week"))
	var founder_pts: float = point * float(SprintCatalog.cfg("founder_mult"))
	var mid: float = point * float((SprintCatalog.cfg("skill.mult") as Array)[1])
	if SprintSystem.capacity() != roundi(founder_pts * weeks):
		return "a solo founder's sprint holds %d points, want %d" % [SprintSystem.capacity(), roundi(founder_pts * weeks)]
	var dev: Character = _sprint_hire("char_cap_dev", HRConstants.ROLE_DEVELOPER)
	if not is_equal_approx(_sprint_points(dev.id), mid) or SprintSystem.capacity() != roundi((founder_pts + mid) * weeks):
		return "a mid developer works %.2f a week for a capacity of %d, want %.2f and %d" % [
			_sprint_points(dev.id), SprintSystem.capacity(), mid, roundi((founder_pts + mid) * weeks)]
	dev.morale = HRConstants.MORALE_BAND_LOW - 1
	var low: float = mid * HRConstants.MORALE_BAND_LOW_MULT
	if not is_equal_approx(_sprint_points(dev.id), low) or SprintSystem.capacity() != roundi((founder_pts + low) * weeks):
		return "low morale left the developer at %.2f a week for a capacity of %d, want %.2f and %d" % [
			_sprint_points(dev.id), SprintSystem.capacity(), low, roundi((founder_pts + low) * weeks)]
	dev.morale = HRConstants.MORALE_BAND_LOW
	var founder: Character = CharacterRegistry.get_founder()
	for area in HRConstants.AREAS:
		founder.role_stats[area] = HRConstants.AREA_MAX
	GameState.set_flag("mvp_shipped", true)   # Ar-Ge yayından sonra açılır
	if RnDSystem.start("data_model", [founder.id]) != "":
		return "fixture: the founder could not start research"
	if _sprint_points(founder.id) > 0.0 or SprintSystem.capacity() != roundi(mid * weeks):
		return "a researching founder still counts: capacity %d, want the developer's %d" % [
			SprintSystem.capacity(), roundi(mid * weeks)]
	HRMoraleSystem.send_on_leave(dev, HRConstants.LEAVE_WEEKS, false)
	if SprintSystem.capacity() != 0 or SprintSystem.can_add():
		return "with the founder researching and the developer on leave the sprint holds %d points (+ open: %s)" % [
			SprintSystem.capacity(), SprintSystem.can_add()]
	return ""


## "+" yük tavanında (%125) kapanır: tavanın altındaki sprint kart alır, alınan kart kapasiteyi
## aşabilir ("devreder" uyarısı), tavanı geçmiş sprint yeni kart almaz.
static func _case_sprint_ceiling_125_blocks_add() -> String:
	_seed_sprint()
	_sprint_hire("char_ceil_dev", HRConstants.ROLE_DEVELOPER)
	var ceiling: float = SprintSystem.capacity() * float(SprintCatalog.cfg("cap_ceiling"))
	var refused: int = 0
	for c in SprintCatalog.candidates("core"):
		if c.kind != "feature" or SprintCatalog.gate_reason(c.step) != "":
			continue
		var open: bool = SprintSystem.can_add()
		if open != (SprintSystem.used() <= ceiling):
			return "+ reads %s at a load of %d against a ceiling of %.2f" % [open, SprintSystem.used(), ceiling]
		SprintSystem.add(c.id)
		if GameState.product.sprint.cards.has(c.id) != open:
			return "add() %s %s with + reading %s at a load of %d" % [
				"took" if not open else "refused", c.id, open, SprintSystem.used()]
		refused += int(not open)
	if refused == 0:
		return "fixture: the core cards never pushed the load over the ceiling (load %d, ceiling %.2f)" % [
			SprintSystem.used(), ceiling]
	return ""


## Devreden kart ilerlemesini korur: sürüm notu biten ve toplam puanı yazar, kart sonraki sprintte
## kaldığı yerden sürer ve planlamada yalnız kalan puanı yükler. Puan tamdır: notun bitenine ve
## planlamanın yüküne aynı kalan girer. Kurucu ilk haftada araştırmayı bitirir, kartı yalnız ikinci
## haftada işler.
static func _case_sprint_carry_keeps_progress() -> String:
	_seed_sprint()
	var id: String = "feat:line_note_tool_capture_k1"
	var total: int = SprintCatalog.step_effort("line_note_tool_capture_k1")
	if not _play_sprint(["res:core", id]):
		return "fixture: sprint 1 did not start"
	var worked: float = _card_worked(id)
	if worked <= 0.0 or worked >= total:
		return "a solo founder's K1 should carry out of sprint 1 part done, worked %.2f of %d" % [worked, total]
	var rows: Array = GameState.product.release.carried.filter(func(r: Dictionary) -> bool: return r.id == id)
	if rows.size() != 1 or not is_equal_approx(float(rows[0].done), worked) or int(rows[0].total) != total \
			or int(rows[0].to_sprint) != 2:
		return "the release note carries %s, want %s with %.2f of %d done, to sprint 2" % [rows, id, worked, total]
	SprintSystem.plan_next()
	if GameState.product.sprint.cards != [id] or not is_equal_approx(_card_worked(id), worked):
		return "sprint 2 opened with %s and the card at %.2f, want it alone at %.2f" % [
			GameState.product.sprint.cards, _card_worked(id), worked]
	if not is_equal_approx(SprintSystem.used(), total - worked):
		return "planning loads %.2f for the carried card, want the %.2f points it has left" % [
			SprintSystem.used(), total - worked]
	if not _play_sprint([]):
		return "fixture: sprint 2 did not start"
	if ProductState.line_tier("line_note_tool_capture") != 1:
		return "the carried card never shipped in sprint 2 (worked %.2f)" % _card_worked(id)
	return ""


## MVP: Çekirdek'in kimlik yeteneklerinden üçü K1'e varınca ürün CANLI v1.0 olur. Öncesindeki
## sprint sürüm çıkarmaz; MVP'nin sinyalleri (version_shipped ve "shipped") tam bir kez atılır ve
## MVP bayrakları o kapanışta yazılır. Sonraki sürüm v1.1'dir.
static func _case_sprint_mvp_three_identity_k1() -> String:
	_seed_sprint()
	for role_id in [HRConstants.ROLE_DESIGNER, HRConstants.ROLE_DEVELOPER, HRConstants.ROLE_TESTER]:
		_sprint_hire("char_mvp_" + role_id, role_id)
	var versions: Array = []
	var ships: Array = []
	EventBus.version_shipped.connect(func(n: int) -> void: versions.append(n))
	EventBus.build_phase_changed.connect(func(phase: String) -> void: ships.append(phase))
	var lines: Array = SprintCatalog.capabilities("core")
	if not _play_sprint(["feat:%s_k1" % lines[0]]) or ProductState.line_tier(lines[0]) != 1:
		return "fixture: sprint 1 did not ship %s" % lines[0]
	if ProductState.is_live() or int(GameState.product.release.number) != 0 or not versions.is_empty() \
			or not ships.is_empty():
		return "one identity line at K1 went public: live %s, release %d, versions %s, ship signals %s" % [
			ProductState.is_live(), int(GameState.product.release.number), versions, ships]
	if not _play_sprint(["feat:%s_k1" % lines[1], "feat:%s_k1" % lines[2]]):
		return "fixture: sprint 2 did not start"
	if not ProductState.is_live() or versions != [1] or ships != ["shipped"]:
		return "three identity lines at K1: live %s, versions %s, ship signals %s; want CANLI v1.0 once" % [
			ProductState.is_live(), versions, ships]
	var launch: int = GameState.day
	if int(GameState.product.release.number) != 1 \
			or int(GameState.get_flag("mvp_launch_day", -1)) != launch \
			or (GameState.get_flag("mvp_version_history", []) as Array).size() != 1:
		return "the MVP release reads %d, launch day %s, history %s" % [int(GameState.product.release.number),
			GameState.get_flag("mvp_launch_day", -1), GameState.get_flag("mvp_version_history", [])]
	if not _play_sprint(["feat:%s_k1" % lines[3]]):
		return "fixture: sprint 3 did not start"
	if versions != [1, 2] or ships.size() != 2 or int(GameState.get_flag("mvp_launch_day", -1)) != launch \
			or int(GameState.product.release.number) != 2:
		return "the release after MVP: versions %s, ship signals %d, launch day %s, release %d; want v1.1" % [
			versions, ships.size(), GameState.get_flag("mvp_launch_day", -1), int(GameState.product.release.number)]
	return ""


## Test rolü olmayan ekipte kartın Test fazı rolsüz, yarı hızla yapılır ve kart hatalı işaretlenir.
## Hatalı kart yayına giren sürümde zar atar: zar kartın kimliği ile sprint numarasının hash'i, eşik
## sprint.json'daki ihtimal. Vaka eşiği zarın hemen üstüne ve tam üstüne koyar (test sabiti):
## ilkinde kartın yeteneğine tek ticket düşer, ikincisinde düşmez. Kurucu Test rolüne de uyar; vaka
## onun rollerini Ürün ve Yazılım'a indirir (test sabiti).
static func _case_sprint_faulty_ticket_deterministic() -> String:
	_seed_sprint_live("note_tool")
	_sprint_hire("char_faulty_des", HRConstants.ROLE_DESIGNER)
	var saved: Array = [SprintCatalog.cfg("faulty_chance"), SprintCatalog.cfg("founder_roles")]
	SprintCatalog._data.founder_roles = ["product", "dev"]
	var run := func() -> String:
		if SprintSystem.team().any(func(p: Dictionary) -> bool: return "test" in p.fits):
			return "fixture: the team has someone in the Test role"
		var lines: Array = SprintCatalog.capabilities("core").slice(int(SprintCatalog.cfg("mvp_lines")))
		for i in 2:
			if SprintSystem.mode() == "release":
				SprintSystem.plan_next()
			var id: String = "feat:%s_k1" % lines[i]
			var roll: float = float(absi(hash(str([id, SprintSystem.sprint_number()]))) % 1000) / 1000.0
			var ticket: bool = i == 0
			SprintCatalog._data.faulty_chance = roll + 0.001 if ticket else roll
			var before: int = ProductState.bugs_confirmed()
			if not _play_sprint([id]):
				return "fixture: sprint %d did not start" % (i + 1)
			var shipped: Array = GameState.product.release.shipped.filter(func(c: Dictionary) -> bool: return c.id == id)
			if shipped.is_empty() or not shipped[0].faulty:
				return "fixture: %s did not ship marked faulty from a team with no Test role" % id
			if ProductState.bugs_confirmed() - before != int(ticket):
				return "a faulty card rolling %.3f against %.3f gave %d ticket(s), want %d" % [roll,
					float(SprintCatalog.cfg("faulty_chance")), ProductState.bugs_confirmed() - before, int(ticket)]
			if ticket and String(GameState.product.tickets.back().line) != lines[i]:
				return "the faulty ticket landed on %s, want %s" % [GameState.product.tickets.back().line, lines[i]]
		return ""
	var fail: String = run.call()
	SprintCatalog._data.faulty_chance = saved[0]
	SprintCatalog._data.founder_roles = saved[1]
	return fail


## Ticket'lar yeteneğe göre tek düzeltme kartında toplanır; acil eşiği kadar ticket kartı "! acil"
## yapar ve alanın uyarısını yakar. Kart çıkınca ticket'lar defterden ve doğrulanmış sayaçtan
## düşer, uyarı kalkar ve sürüm notu onu kalkanlar arasında yazar.
static func _case_sprint_fix_card_closes_tickets() -> String:
	_seed_sprint()
	_sprint_hire("char_fix_dev", HRConstants.ROLE_DEVELOPER)
	var line: String = SprintCatalog.capabilities("core")[0]
	var urgent: int = int(SprintCatalog.cfg("urgent_tickets"))
	ProductState.set_line_tier(line, 1)
	ProductState.adjust_confirmed(urgent)
	SprintBridges.sync_tickets()
	var fix: Array = SprintCatalog.candidates("core").filter(func(c: Dictionary) -> bool: return c.id == "fix:" + line)
	if fix.size() != 1 or fix[0].tickets.size() != urgent or not SprintCatalog.is_urgent(fix[0]) \
			or int(fix[0].effort) != int(SprintCatalog.cfg("effort.fix_urgent")):
		return "%d tickets on one capability read %s, want one urgent fix card carrying all of them" % [urgent, fix]
	if not SprintCatalog.area_alert("core"):
		return "an urgent capability did not raise Çekirdek's alert"
	if not _play_sprint([fix[0].id]):
		return "fixture: the sprint did not start"
	if ProductState.bugs_confirmed() != 0 or not (GameState.product.tickets as Array).is_empty():
		return "the fix card shipped and left %d confirmed, ledger %s" % [ProductState.bugs_confirmed(),
			GameState.product.tickets]
	if SprintCatalog.area_alert("core") or not GameState.product.release.alerts_cleared.has("core"):
		return "the alert reads %s after the fix, cleared %s" % [SprintCatalog.area_alert("core"),
			GameState.product.release.alerts_cleared]
	if SprintCatalog.candidates("core").any(func(c: Dictionary) -> bool: return c.kind == "fix"):
		return "a fix card outlived its tickets"
	return ""


## Beta açıkken biten kart sürüme girmez, bir sprint "beta" bekler: sürüm numarası artmaz, kademe
## yazılmaz. Sonraki kapanışta betadan çıkar ve sürüm olur; hatalı çıkış zarı orada betanın
## ihtimalini okur (test sabiti: normal ihtimal sıfır, beta ihtimali zarın hemen üstü). Kart hatalı
## olsun diye kurucunun rolleri Ürün ve Yazılım'a iner (test sabiti).
static func _case_sprint_beta_delays_release() -> String:
	_seed_sprint_live("note_tool")
	_sprint_hire("char_beta_des", HRConstants.ROLE_DESIGNER)
	var versions: Array = []
	EventBus.version_shipped.connect(func(n: int) -> void: versions.append(n))
	var saved: Array = [SprintCatalog.cfg("faulty_chance"), SprintCatalog.cfg("faulty_chance_beta"),
		SprintCatalog.cfg("founder_roles")]
	SprintCatalog._data.founder_roles = ["product", "dev"]
	var run := func() -> String:
		var line: String = SprintCatalog.capabilities("core")[3]
		var id: String = "feat:%s_k1" % line
		SprintSystem.set_beta(true)
		if not _play_sprint([id]):
			return "fixture: sprint 1 did not start"
		var r: Dictionary = GameState.product.release
		if int(r.number) != 0 or not r.beta or ProductState.line_tier(line) != 0 or not versions.is_empty() \
				or GameState.product.cards.get(id, {}).get("state", "") != "beta":
			return "a card done under beta: release %d (beta %s), tier %d, versions %s; want it waiting in beta" % [
				int(r.number), r.beta, ProductState.line_tier(line), versions]
		SprintSystem.plan_next()
		SprintSystem.set_beta(false)
		var roll: float = float(absi(hash(str([id, SprintSystem.sprint_number()]))) % 1000) / 1000.0
		SprintCatalog._data.faulty_chance = 0.0
		SprintCatalog._data.faulty_chance_beta = roll + 0.001
		var before: int = ProductState.bugs_confirmed()
		if not _play_sprint(["res:core"]):
			return "fixture: sprint 2 did not start"
		if versions != [2] or ProductState.line_tier(line) != 1:
			return "the sprint after beta: versions %s, tier %d; want the beta card released as v1.1" % [
				versions, ProductState.line_tier(line)]
		if ProductState.bugs_confirmed() - before != 1:
			return "the beta card rolled %.3f under the beta chance and gave %d ticket(s), want 1" % [
				roll, ProductState.bugs_confirmed() - before]
		return ""
	var fail: String = run.call()
	SprintCatalog._data.faulty_chance = saved[0]
	SprintCatalog._data.faulty_chance_beta = saved[1]
	SprintCatalog._data.founder_roles = saved[2]
	return fail


## Planlamada ya da sürüm notunda bir gün geçerse sprint liderin önerisiyle kendiliğinden başlar
## ve sprint_auto_started yayılır.
static func _case_sprint_auto_start_after_a_day() -> String:
	_seed_sprint()
	var auto: Array = []
	EventBus.sprint_auto_started.connect(func(n: int) -> void: auto.append(n))
	_sim_day()
	if SprintSystem.mode() != "active" or auto != [1] or int(GameState.product.auto_started) != 1:
		return "a day in planning: %s, auto starts %s; want sprint 1 running" % [SprintSystem.mode(), auto]
	if GameState.product.sprint.cards.is_empty():
		return "the auto-started sprint carries no cards; the lead's plan was not applied"
	_sim_day()
	_sim_day()
	if SprintSystem.mode() != "release":
		return "fixture: sprint 1 did not close (%s)" % SprintSystem.mode()
	_sim_day()
	if SprintSystem.mode() != "active" or SprintSystem.sprint_number() != 2 or auto != [1, 2]:
		return "a day on the release note: %s sprint %d, auto starts %s; want sprint 2 running" % [
			SprintSystem.mode(), SprintSystem.sprint_number(), auto]
	return ""


## B2B talebi: hesap imzadan bir sprint sonra sektörünün arketipine bağlı alandan bir kademe ister.
## Talep kartı adaylarda, liderin önerisinde ve öngörüde "zamanında" olarak görünür; son tarihten
## önce çıkan sürüm talebi karşılar ve aynı kademeye verilmiş sözü o sürümün "shipped"iyle tutar.
static func _case_sprint_request_on_time_met() -> String:
	_seed_sprint_live("erp")
	for role_id in [HRConstants.ROLE_DESIGNER, HRConstants.ROLE_DEVELOPER, HRConstants.ROLE_TESTER]:
		_sprint_hire("char_req_" + role_id, role_id)
	var lead := Prospect.new()
	lead.id = "lead_request"
	lead.company_name = "Request Co"
	lead.industry = String(SalesArchetypes.sectors("tech_exacting")[0])
	lead.star = 2
	var account: Customer = SalesSystem.add_b2b_customer(lead, 12, 50, 85)
	# A one-point sprint: the request's sprint starts with nothing carried in front of its card.
	if not _play_sprint(["res:core"]):
		return "fixture: sprint 1 did not start"
	var open: Array = GameState.product.requests.filter(func(r: Dictionary) -> bool: return r.status == "open")
	if open.size() != 1 or open[0].customer_id != account.id:
		return "a sprint after signing the account holds requests %s, want one from %s" % [open, account.id]
	var req: Dictionary = open[0]
	if SprintCatalog.area_of_line(req.line) != String(SprintCatalog.cfg("archetypes.tech_exacting")) \
			or int(req.due_sprint) != int(req.created_sprint) + int(SprintCatalog.cfg("request.deadline_sprints")) \
			or int(req.value) != account.mrr * 12:
		return "the request reads %s; want the archetype's area, the deadline sprint and a year of MRR" % req
	SprintSystem.plan_next()
	if not SprintCatalog.candidates(SprintCatalog.area_of_line(req.line)).any(
			func(c: Dictionary) -> bool: return c.id == req.card_id and c.kind == "request"):
		return "the request card %s is not among the candidates" % req.card_id
	if not SprintCatalog.lead_suggestion().has(req.card_id):
		return "the lead's plan skips the open request"
	if not SprintCatalog.forecast([req.card_id]).any(func(part: Dictionary) -> bool: return part.k == "request_on_time"):
		return "the forecast does not show the request on time"
	var promise: Promise = PromiseRegistry.create(account.id, req.step, 10)
	if not _play_sprint([req.card_id]):
		return "fixture: sprint 2 did not start"
	if req.status != "met":
		return "a request shipped in sprint %d, due %d, reads '%s'" % [SprintSystem.sprint_number(),
			int(req.due_sprint), req.status]
	if promise.status != "kept":
		return "the release met the request but not the word given for the same step ('%s')" % promise.status
	return ""


## Gelir'in "Ücretli plan" kartı çıkınca ücretli katman ürünün o anki değerinin önerdiği fiyatla
## açılır; tek kademeli yetenek tamamlanır ve aday olarak bir daha gelmez.
static func _case_sprint_paid_plan_opens_paid_tier() -> String:
	_seed_sprint_live("note_tool")
	_sprint_hire("char_paid_dev", HRConstants.ROLE_DEVELOPER)
	var id: String = "plan:" + SprintCatalog.PAID_PLAN
	var offered := func() -> bool:
		return SprintCatalog.candidates("revenue").any(func(c: Dictionary) -> bool: return c.id == id)
	if GameState.get_flag("b2c_paid_tier_open", false) or not offered.call():
		return "fixture: want a closed paid tier and the plan card in Gelir"
	SprintSystem.add(id)
	if not SprintSystem.start():
		return "fixture: the sprint did not start"
	_sim_day()
	# Kapanış katmanı, sürümün henüz itmediği eksenlerle açar: değer o günün başında okunur.
	var price: int = int(SalesSystem.product_value().optimal)
	_sim_day()
	if not GameState.get_flag("b2c_paid_tier_open", false) or int(GameState.get_flag("b2c_price", 0)) != price:
		return "the paid plan shipped: open %s at %s, want open at the optimal %d" % [
			GameState.get_flag("b2c_paid_tier_open", false), GameState.get_flag("b2c_price", 0), price]
	if SprintCatalog.tier(SprintCatalog.PAID_PLAN) != 1 or offered.call():
		return "the open paid tier reads tier %d and still offers the plan card" % SprintCatalog.tier(SprintCatalog.PAID_PLAN)
	return ""


## Ürün durumu kayıtla gidip gelir: sprintin ortasında alınan kayıt kartları, ilerlemeyi, sürüm
## geçmişini ve ticket defterini aynen ve aynı sırayla geri verir (betadaki kartlar saklandıkları
## sırayla çıkar) ve yüklenen dünya sprinti kapatır.
## FALSİFİKASYON: SaveManager.save_to_slot'taki JSON.stringify'a sort_keys=true geri koy → FAIL.
static func _case_sprint_save_roundtrip() -> String:
	var slot: String = "smoke_sprint_%d" % OS.get_process_id()
	var done := func(why: String) -> String:
		SaveManager.delete_slot(slot)
		return why
	_seed_sprint()
	_sprint_hire("char_save_des", HRConstants.ROLE_DESIGNER)
	var lines: Array = SprintCatalog.capabilities("core")
	if not _play_sprint(["feat:%s_k1" % lines[0]]):
		return "fixture: sprint 1 did not start"
	ProductState.adjust_confirmed(2)
	SprintBridges.sync_tickets()
	SprintSystem.plan_next()
	SprintSystem.add("feat:%s_k1" % lines[2])
	SprintSystem.add("feat:%s_k1" % lines[1])
	if not SprintSystem.start():
		return "fixture: sprint 2 did not start"
	_sim_day()
	_drain_all_modals()   # a card on screen refuses the save (can_save)
	if (GameState.product.tickets as Array).size() != 2 or (GameState.product.releases as Array).is_empty():
		return "fixture: want tickets and a release in the saved product"
	var plain := func() -> String:
		return JSON.stringify(SaveCodec.from_json(SaveCodec.to_json(GameState.product)), "", false)
	var reads := func() -> Array:
		return [SprintSystem.capacity(), SprintSystem.used(), SprintSystem.week(), SprintSystem.done_points()]
	var before: String = plain.call()
	var saved_reads: Array = reads.call()
	if not SaveManager.save_to_slot(slot):
		return done.call("save_to_slot failed (%s)" % SaveManager.cannot_save_reason_key())
	if not SaveManager.apply_loaded_state(SaveManager.read_slot(slot)):
		return done.call("apply_loaded_state returned false")
	if plain.call() != before:
		return done.call("the product came back different from the save, or in another order")
	if reads.call() != saved_reads:
		return done.call("the loaded sprint reads %s, the saved one %s" % [reads.call(), saved_reads])
	_sim_day()
	if SprintSystem.mode() != "release" or int(GameState.product.release.sprint) != 2:
		return done.call("the loaded sprint did not close (%s)" % SprintSystem.mode())
	return done.call("")


## Karar bekleyen kart ilerlemez: kâğıt masadayken haftanın işi ona dökülmez ve ona kimse atanmaz;
## sprint kapanınca ilerlemesiyle devreder, kâğıt kapanınca yeniden yürür. Kararlar ürünün gerçek
## sprint kartlarıdır; vaka istek oranını (test sabiti, her hafta) kendi süresince açar ve geri koyar.
## Tek kurucu ilk haftayı sıradaki ilk karta verir; geride kalan ikinci kart kararı alır.
static func _case_sprint_decision_blocks_progress() -> String:
	_seed_sprint()
	var rate: Variant = SprintCatalog.cfg("decision.rate")
	SprintCatalog._data.decision.rate = 1.0
	var run := func() -> String:
		var asked: Array = []
		EventBus.card_decision_requested.connect(func(id: String) -> void: asked.append(id))
		var lines: Array = SprintCatalog.capabilities("core")
		var free: String = "feat:%s_k1" % lines[0]
		var held: String = "feat:%s_k1" % lines[1]
		SprintSystem.add(free)
		SprintSystem.add(held)
		if not SprintSystem.start():
			return "fixture: the sprint did not start"
		_sim_day()
		if asked != [held] or not GameState.product.cards[held].decision \
				or not String(GameState.product.decision.get("event_id", "")).begins_with("product.sprint_"):
			return "a decision at rate 1 went to %s (pending %s), want a product sprint card on %s" % [
				asked, GameState.product.decision, held]
		if not (GameState.product.cards[held].assignees as Array).is_empty():
			return "a card waiting on its decision was staffed for the week"
		var at: float = _card_worked(held)
		_sim_day()
		if absf(_card_worked(held) - at) > 0.0001:
			return "a card waiting on its decision moved %.2f -> %.2f" % [at, _card_worked(held)]
		if not GameState.product.release.shipped.any(func(r: Dictionary) -> bool: return r.id == free):
			return "fixture: the founder freed by the decision did not finish the other card"
		if not GameState.product.release.carried.any(func(r: Dictionary) -> bool: return r.id == held):
			return "the waiting card did not carry over"
		SprintSystem.plan_next()
		if not SprintSystem.start():
			return "fixture: sprint 2 did not start"
		if GameState.product.cards[held].decision:
			return "the expired paper still holds the card"
		var resumed: float = _card_worked(held)
		_sim_day()
		if _card_worked(held) <= resumed:
			return "the released card did not move again"
		return ""
	var fail: String = run.call()
	SprintCatalog._data.decision.rate = rate
	return fail


## Betada bekleyen kart yerinden oynamaz: "+" (B2B müşteri satırı onu aday gibi sunar) onu bu
## sprinte almaz, kart betada kalır ve sonraki kapanışta betanın ihtimaliyle çıkar.
## FALSİFİKASYON: SprintSystem._movable'dan "beta"yı çıkar → FAIL.
static func _case_sprint_beta_card_cannot_be_added() -> String:
	_seed_sprint_live("note_tool")
	_sprint_hire("char_betaadd_des", HRConstants.ROLE_DESIGNER)
	var id: String = "feat:%s_k1" % SprintCatalog.capabilities("core")[3]
	SprintSystem.set_beta(true)
	if not _play_sprint([id]) or GameState.product.cards.get(id, {}).get("state", "") != "beta":
		return "fixture: %s is not waiting in beta" % id
	SprintSystem.plan_next()
	SprintSystem.add(id)
	if id in GameState.product.sprint.cards or GameState.product.cards[id].state != "beta":
		return "+ took the beta card into sprint 2 (sprint %s, state %s)" % [GameState.product.sprint.cards,
			GameState.product.cards[id].state]
	return ""


## Açık sürüm canlı hata havuzunu sıfırlar: sayaç ve aşınma ilerlemesi 0'dan başlar. Sürüm
## çıkarmayan kapanış (araştırma) havuza dokunmaz.
## FALSİFİKASYON: SprintSystem._close'taki mvp_live_bug_count sıfırlamasını sil → FAIL.
static func _case_sprint_release_resets_live_bugs() -> String:
	_seed_sprint_live("note_tool")
	_sprint_hire("char_bugs_dev", HRConstants.ROLE_DEVELOPER)
	GameState.set_flag("mvp_live_bug_count", 7)
	GameState.set_flag("mvp_live_bug_progress", 0.75)
	if not _play_sprint(["res:core"]):
		return "fixture: the research sprint did not start"
	if int(GameState.product.release.number) != 0 or ProductSystem.live_bug_count() != 7:
		return "a research-only close (release %d) moved the live pool to %d, want 7 untouched" % [
			int(GameState.product.release.number), ProductSystem.live_bug_count()]
	if not _play_sprint(["feat:%s_k1" % SprintCatalog.capabilities("core")[3]]):
		return "fixture: the release sprint did not start"
	if int(GameState.product.release.number) != 2:
		return "fixture: the second sprint did not release v1.1 (release %d)" % int(GameState.product.release.number)
	if ProductSystem.live_bug_count() != 0 or float(GameState.get_flag("mvp_live_bug_progress", -1.0)) != 0.0:
		return "the release left the live pool at %d bugs, progress %.2f; want 0 and 0.0" % [
			ProductSystem.live_bug_count(), float(GameState.get_flag("mvp_live_bug_progress", -1.0))]
	return ""


## Hafta ortasında ekipten ayrılan kişi kartından düşer ve boştaki kişi kimsesiz kalan karta
## haftanın kalanında atanır; Ekip'in gününde izne çıkan da karttan düşer.
## FALSİFİKASYON: SprintSystem._restaff'ın gövdesini boşalt → FAIL.
static func _case_sprint_departure_restaffs_card() -> String:
	_seed_sprint()
	var des: Character = _sprint_hire("char_left_des", HRConstants.ROLE_DESIGNER)
	var dev: Character = _sprint_hire("char_left_dev", HRConstants.ROLE_DEVELOPER)
	var founder: String = CharacterRegistry.get_founder().id
	SprintSystem.add("res:core")
	SprintSystem.add("res:onboarding")
	if not SprintSystem.start():
		return "fixture: the sprint did not start"
	# Founder and designer work equal points: which research card each takes is the tie order.
	var cards: Array = [GameState.product.cards["res:core"], GameState.product.cards["res:onboarding"]]
	var staffed: Array = cards.map(func(c: Dictionary) -> Array: return c.assignees)
	if not ([des.id] in staffed and [founder] in staffed):
		return "fixture: week one staffs %s, want the designer and the founder on one card each, the developer idle" \
			% [staffed]
	var orphan: Dictionary = cards[staffed.find([des.id])]
	var kept: Dictionary = cards[staffed.find([founder])]
	CharacterRegistry.remove(des.id)
	if orphan.assignees != [dev.id] or kept.assignees != [founder]:
		return "the designer left and the cards read %s and %s; want the idle developer on the orphaned card" % [
			orphan.assignees, kept.assignees]
	HRMoraleSystem.send_on_leave(dev, HRConstants.LEAVE_WEEKS, false)
	EventBus.hr_day_processed.emit()
	if not (orphan.assignees as Array).is_empty():
		return "the developer went on leave and still works %s" % orphan.id
	return ""


## Planlama donmaz: önerecek kart kalmayınca sprint boş başlar ve numara ilerler; araştırma bir
## kapanış sonra yeniden açılır ve lider onu alır.
## FALSİFİKASYON: SprintSystem._auto_start'ta _begin() yerine start() çağır → FAIL.
static func _case_sprint_never_stalls_in_plan() -> String:
	_seed_sprint_live("note_tool")
	_sprint_hire("char_stall_des1", HRConstants.ROLE_DESIGNER)
	_sprint_hire("char_stall_des2", HRConstants.ROLE_DESIGNER)
	_sprint_hire("char_stall_dev", HRConstants.ROLE_DEVELOPER)
	for line_id in ProductLines.line_ids(ProductState.subtype()):
		ProductState.set_line_tier(String(line_id), ProductLines.TIER_MAX)
	GameState.set_flag("b2c_paid_tier_open", true)
	var research: Array = SprintCatalog.area_ids().map(func(a: String) -> String: return "res:" + a)
	if not _play_sprint(research) or SprintSystem.mode() != "release" \
			or not (GameState.product.release.carried as Array).is_empty():
		return "fixture: the research sprint did not ship whole (%s)" % SprintSystem.mode()
	if SprintCatalog.area_ids().any(func(a: String) -> bool: return not SprintCatalog.candidates(a).is_empty()):
		return "fixture: a card is left to plan after the research sprint"
	_sim_day()
	if SprintSystem.mode() != "active" or SprintSystem.sprint_number() != 2:
		return "a day with nothing to plan left sprint %d in %s, want sprint 2 running empty" % [
			SprintSystem.sprint_number(), SprintSystem.mode()]
	for _d in 3:
		_sim_day()
	if SprintSystem.mode() != "active" or SprintSystem.sprint_number() != 3 \
			or (GameState.product.sprint.cards as Array).is_empty():
		return "after the empty sprint: sprint %d %s with %s; want sprint 3 running research again" % [
			SprintSystem.sprint_number(), SprintSystem.mode(), GameState.product.sprint.cards]
	return ""


## Söz sprint'e bağlıdır: koşan sprintte verilen söz bir sonraki sprintin sonuna kadardır, o sprintin
## planında liderin ilk kartıdır ve etiketini taşır; kart o sprintte çıkınca söz tutulur. İki
## haftalık gün sayısı arada geçse de söz kırılmaz.
## FALSİFİKASYON: PromiseRegistry.create'te due_sprint'i yazma → FAIL.
static func _case_promise_due_sprint_kept_when_shipped_next_sprint() -> String:
	var setup: Array = _seed_promise_sprint()
	if setup.is_empty():
		return "fixture: sprint 1 did not start"
	var account: Customer = setup[0]
	var step: String = setup[1]
	var promise: Promise = PromiseRegistry.create(account.id, step, B2BConstants.PROMISE_DEADLINE_WEEKS)
	if promise.due_sprint != 2:
		return "a word given while sprint 1 runs is due by sprint %d, want 2" % promise.due_sprint
	_sim_day()
	_sim_day()
	if promise.status != "open":
		return "the word broke at sprint 1's close (%s), before its own sprint" % promise.status
	SprintSystem.plan_next()
	var card: Dictionary = SprintCatalog.candidates(SprintCatalog.area_of_line(ProductLines.step(step).line_id)).filter(
		func(c: Dictionary) -> bool: return c.step == step)[0]
	var lead: Array = SprintCatalog.lead_suggestion()
	if lead.is_empty() or lead[0] != card.id:
		return "sprint 2's lead plan is %s, want the promised %s first" % [lead, card.id]
	if not SprintCatalog.card_effect(card).any(func(part: Dictionary) -> bool: return part.k == "promise"):
		return "the promised card's effect line does not name the promise"
	if not _play_sprint([card.id]):
		return "fixture: sprint 2 did not start"
	if promise.status != "kept":
		return "the promised step shipped at sprint 2's close and the word reads '%s'" % promise.status
	return ""


## Sözün sprinti kapanıp adım çıkmadıysa söz kırılır ve kırıldığı tik hesaba yazılır; o sprint
## sürerken gün sayısı geçmiş olsa da kırılmaz.
## FALSİFİKASYON: PromiseRegistry._overdue'yu yalnız gün kuralına indir → FAIL.
static func _case_promise_due_sprint_breaks_after_close() -> String:
	var setup: Array = _seed_promise_sprint()
	if setup.is_empty():
		return "fixture: sprint 1 did not start"
	var account: Customer = setup[0]
	var promise: Promise = PromiseRegistry.create(account.id, setup[1], B2BConstants.PROMISE_DEADLINE_WEEKS)
	_sim_day()
	_sim_day()
	SprintSystem.plan_next()
	SprintSystem.add("res:onboarding")
	if not SprintSystem.start():
		return "fixture: sprint 2 did not start"
	_sim_day()
	if promise.status != "open":
		return "the word broke in its own sprint's second week (%s)" % promise.status
	_sim_day()
	if promise.status != "broken" or account.promise_broken_day != GameState.day:
		return "sprint 2 closed without the step: the word reads '%s', broken on %d (today %d)" % [
			promise.status, account.promise_broken_day, GameState.day]
	return ""


## Kırık sözden sonra o hesaba PROMISE_RELOCK_WEEKS boyunca yeni söz verilmez; süre dolunca kilit
## kalkar.
## FALSİFİKASYON: B2BSalesSystem.on_promise_resolved'daki promise_broken_day yazımını sil → FAIL.
static func _case_promise_relock_after_break() -> String:
	GameState.set_flag("mvp_sub_product_type_id", "ai_vector_search")
	_seed_b2b(1000)
	var c: Customer = CustomerRegistry.get_by_market("b2b")[0]
	if B2BSalesSystem.promise_relocked(c):
		return "a fresh account is locked against promises"
	var promise: Promise = PromiseRegistry.create(c.id, "ai_vec_filter", 1)
	for _d in 3:
		GameState.advance_day()
		B2BSalesSystem.daily_tick()
	if promise.status != "broken" or not B2BSalesSystem.promise_relocked(c):
		return "the word reads '%s' and the account relocked %s" % [promise.status, B2BSalesSystem.promise_relocked(c)]
	var lock: int = TimeModel.ticks(B2BConstants.PROMISE_RELOCK_WEEKS)
	while GameState.day - c.promise_broken_day < lock - 1:
		GameState.advance_day()
	if not B2BSalesSystem.promise_relocked(c):
		return "the lock lifted %d ticks after the break, want %d" % [GameState.day - c.promise_broken_day, lock]
	GameState.advance_day()
	if B2BSalesSystem.promise_relocked(c):
		return "the lock still holds %d ticks after the break" % (GameState.day - c.promise_broken_day)
	return ""


## B2C'de yayından sonra ücretli plan liderin zorunlu kartıdır: gelirin kapısıdır, tek kurucunun dar
## sprintinde de önce o önerilir.
## FALSİFİKASYON: SprintCatalog._suggest'teki PAID_PLAN satırını sil → FAIL.
static func _case_sprint_lead_offers_paid_plan_b2c() -> String:
	_seed_sprint_live("note_tool")
	var lead: Array = SprintCatalog.lead_suggestion()
	if lead.is_empty() or lead[0] != "plan:" + SprintCatalog.PAID_PLAN:
		return "the solo founder's lead after MVP suggests %s, want the paid plan first" % str(lead)
	return ""


## Tek kurucu dört rolün hepsinde tam hızdadır: liderin önerisiyle her sprint bir K1 biter ve MVP
## üçüncü kapanışta, türün seçildiği günden en geç altı tik sonra çıkar.
## FALSİFİKASYON: sprint.json founder_roles'u ["product", "dev"] yap → FAIL.
static func _case_sprint_solo_mvp_by_week_six() -> String:
	_seed_sprint()
	var start: int = GameState.day
	while not ProductState.is_live() and GameState.day - start < 6:
		if SprintSystem.mode() == "release":
			SprintSystem.plan_next()
		SprintSystem.apply_lead()
		if not SprintSystem.start():
			return "sprint %d did not start from the lead's plan" % SprintSystem.sprint_number()
		_sim_day()
		_sim_day()
	var launch: int = int(GameState.get_flag("mvp_launch_day", -1))
	if not ProductState.is_live() or launch - start > 6:
		return "the solo founder's MVP: live %s, %d ticks after the type; want live within 6" % [
			ProductState.is_live(), launch - start]
	return ""


## Söz vakalarının ortak kurulumu: yayındaki ERP, üç kişilik ekip, Çekirdek'te talep eden bir hesap
## ve araştırmayla koşan Sprint 1. [hesap, söz verilecek kademe]; sprint başlamazsa [].
static func _seed_promise_sprint() -> Array:
	_seed_sprint_live("erp")
	for role_id in [HRConstants.ROLE_DESIGNER, HRConstants.ROLE_DEVELOPER, HRConstants.ROLE_TESTER]:
		_sprint_hire("char_word_" + role_id, role_id)
	var lead := Prospect.new()
	lead.id = "lead_word"
	lead.company_name = "Word Co"
	lead.industry = String(SalesArchetypes.sectors("tech_exacting")[0])
	lead.star = 2
	var account: Customer = SalesSystem.add_b2b_customer(lead, 12, 50, 85)
	SprintSystem.add("res:core")
	if not SprintSystem.start():
		return []
	return [account, "%s_k1" % SprintCatalog.capabilities("core")[3]]


## MVP öncesi koşuda taban boş kalmaz: quiet kartlar sıradan havuza girmez, yalnız boş haftayı
## doldurur ve tek kurucu MVP'ye yürürken taban art arda raporlanacak kadar boş bulunmaz (§13.6).
## Oyuncu her kartı ilk seçenekle cevaplar ki masa boşalsın ve taban tetiklenebilsin; kasa her
## hafta düşük bir bakiyede tutulur, runway birikim notunun eşiğinin altında kalır.
## FALSİFİKASYON: EvCatalog.pool_candidates'ten quiet dışlamasını sil → ilk kontrol düşer;
## founder.savings_note ve founder.unseen_build'i sil → hiçbir quiet kart ateşlenmez.
static func _case_quiet_cards_fill_empty_floor() -> String:
	for c in EvCatalog.pool_candidates("daily"):
		if ((c as Dictionary)["tags"] as Array).has("quiet"):
			return "the weighted pool offers the quiet card %s" % (c as Dictionary)["id"]
	# The rhythm includes the sprint decision papers: their real rate, not _seed_sprint's zero.
	var rate: Variant = SprintCatalog.cfg("decision.rate")
	_seed_sprint()
	SprintCatalog._data.decision.rate = rate
	var worst: int = 0
	var weeks: int = 0
	while weeks < 12:
		GameState.set_cash(5000)
		_sim_day_full()
		if ProductState.is_live():
			break
		weeks += 1
		worst = maxi(worst, EvEngine._floor_empty_streak)
		for i in 16:
			if EventGate.active_id() != "":
				EventGate.resolve(EventGate.active_id(), 0)
				continue
			var papers: Array = EventGate.desk_papers(8)
			if papers.is_empty():
				break
			EventGate.open_paper(String((papers[0] as Dictionary).id))
	if weeks < 5:
		return "fixture: the MVP shipped after %d week(s); the case needs a pre-MVP stretch" % weeks
	if worst >= EvTuning.FLOOR_EMPTY_REPORT_AFTER:
		return "the floor came up empty %d times running before the MVP" % worst
	if EvHistory.fire_count("founder.savings_note") + EvHistory.fire_count("founder.unseen_build") == 0:
		return "no quiet card filled an empty week in %d pre-MVP weeks" % weeks
	return ""


## Sprint karar kartları gerçek destededir: istek oranı 1 iken koşan sprintin ilk haftasından sonra
## geride kalan kart bir product.sprint_* kâğıdını masaya koyar ve gövdesi beklenen kartın adını
## okur. Vaka fikstür kapsamını açmaz; oranı (test sabiti) kendi süresince açar ve geri koyar.
## FALSİFİKASYON: kartlardan birinin version_scope'unu "fixture" yap ya da sprint.json
## decision.cards'ı fixture kimliklerine çevir → karar istenmez.
static func _case_sprint_decision_card_fires_shipped() -> String:
	if EvTuning.SHIPPED_SCOPES.has("fixture"):
		return "fixture: the shipped scopes already admit fixtures"
	_seed_sprint()
	var rate: Variant = SprintCatalog.cfg("decision.rate")
	SprintCatalog._data.decision.rate = 1.0
	for line_id in SprintCatalog.capabilities("core").slice(0, 2):
		SprintSystem.add("feat:%s_k1" % line_id)
	var started: bool = SprintSystem.start()
	if started:
		_sim_day()
	SprintCatalog._data.decision.rate = rate
	if not started:
		return "fixture: the sprint did not start"
	var event_id: String = String(GameState.product.decision.get("event_id", ""))
	if not event_id.begins_with("product.sprint_") or not event_id in (SprintCatalog.cfg("decision.cards") as Array):
		return "a decision at rate 1 asked for '%s', want one of %s" % [event_id, SprintCatalog.cfg("decision.cards")]
	if not EventGate.desk_papers(8).any(func(p: Dictionary) -> bool: return p.id == event_id):
		return "the %s paper is not on the desk" % event_id
	var name: String = SprintCatalog.card_name(SprintSystem.decision_card())
	var body: String = EventGate.render(event_id).body_text
	if name == "" or not body.contains(name) or body.contains("{"):
		return "the decision paper reads '%s', want it to name '%s'" % [body, name]
	return ""


## Kırık sözden sonra o hesaba yeni "Söz ver" açılmaz: dört söz satırı ve rakip fiyat kırma
## kartının söz satırı kilitlenir, gerekçe kırık sözün kendisidir; kilit pencere dolunca kalkar.
## Kırılmadan sonra hesaba yeni ve yapılmamış bir istek yazılır ki satırı yalnız kırık söz kilitlesin.
## FALSİFİKASYON: retention.json'un söz satırından musteri.broke_promise yaprağını sil → FAIL.
static func _case_promise_row_locked_after_break() -> String:
	GameState.set_flag("mvp_sub_product_type_id", "saas_ops")
	_seed_b2b(1000)
	var c: Customer = CustomerRegistry.get_customer("co_lead_smoke")
	c.pain_feature_id = "saas_ops_scheduling"
	B2BSalesSystem.accept_promise(c.id, c.pain_feature_id, B2BConstants.PROMISE_DEADLINE_WEEKS)
	PromiseRegistry.tick_deadlines(GameState.day + TimeModel.ticks(B2BConstants.PROMISE_DEADLINE_WEEKS) + 1)
	if PromiseRegistry.has_open_for(c.id) or c.promise_broken_day != GameState.day:
		return "fixture: the promise did not break this week (broken on %d)" % c.promise_broken_day
	c.pain_feature_id = "saas_ops_field"
	var ctx: Dictionary = _ctx_customer(c)
	var cards: Array = [RETAIN_ID, "customer.cs_escalation", "customer.request_feature",
		"customer.request_complaint", "rival.price_cut"]
	for id in cards:
		var ev: GameEvent = EventGate.render(id, ctx)
		var idx: int = _promise_row_index(ev)
		if idx < 0:
			return "%s lost its promise row" % id
		if _row_unlocked(ev, idx, ctx):
			return "%s offers a new word right after the last one broke" % id
		var why: String = EventGate.condition_reason(ev.choices[idx].unlock_condition, ctx)
		if why != "B2B_LOCK_PROMISE_BROKEN":
			return "%s locks its promise row with '%s', want B2B_LOCK_PROMISE_BROKEN" % [id, why]
	c.promise_broken_day = GameState.day - TimeModel.ticks(B2BConstants.PROMISE_RELOCK_WEEKS)
	for id in cards:
		var ev: GameEvent = EventGate.render(id, ctx)
		if not _row_unlocked(ev, _promise_row_index(ev), ctx):
			return "%s keeps its promise row locked after the relock window" % id
	return ""

## Söz satırı ancak kademe planlanabilir sprintin boş puanına sığıyorsa açıktır: dört söz satırı,
## rakip fiyat kırma kartının söz satırı ve satış görüşmesinin söz cevabı aynı kuralla kilitlenir,
## gerekçe "yer yok"tur ve görüşme aynı anahtarı gösterir. Plana girmemiş açık sözler vadesi olan
## sprintte yer tutar: iki hesaba verilen aynı kademe bir kez sayılır, yeri dolduran ikinci kademe
## satırı kilitler. Sprint koşarken boş puan sonraki sprintindir: koşan sprintin kartları da, o
## sprinte verilmiş sözler de yer tutmaz.
## FALSİFİKASYON: retention.json'un söz satırından musteri.promise_fits yaprağını sil,
## SalesMeetingSystem._promise_lock'tan sığma dalını sil, SprintSystem.fits_plannable'da açık
## sözleri sayma, aynı kademeyi her söz için say ya da vade süzgecini kaldır → FAIL.
static func _case_promise_row_locked_when_no_room() -> String:
	_seed_sprint_live("erp")
	_sprint_hire("char_room_dev", HRConstants.ROLE_DEVELOPER)
	var accounts: Array = []
	for id in ["lead_room", "lead_owed_a", "lead_owed_b"]:
		var lead := Prospect.new()
		lead.id = id
		lead.company_name = id
		lead.industry = String(SalesArchetypes.sectors("tech_exacting")[0])
		lead.star = 2
		accounts.append(SalesSystem.add_b2b_customer(lead, 12, 50, 85))
	var c: Customer = accounts[0]
	var pain: String = "%s_k1" % SprintCatalog.capabilities("core")[3]
	c.pain_feature_id = pain
	var pitch: String = SalesMeetingSystem._promise_step()
	var ctx: Dictionary = _ctx_customer(c)
	var check := func(open: bool, when: String) -> String:
		for id in [RETAIN_ID, "customer.cs_escalation", "customer.request_feature", "customer.request_complaint",
				"rival.price_cut"]:
			var ev: GameEvent = EventGate.render(id, ctx)
			var idx: int = _promise_row_index(ev)
			if idx < 0 or _row_unlocked(ev, idx, ctx) != open:
				return "%s: the promise row of %s is %s" % [when, id, "locked" if open else "open"]
			var why: String = EventGate.condition_reason(ev.choices[idx].unlock_condition, ctx)
			if not open and why != "SALES_LOCK_PROMISE_NO_ROOM":
				return "%s: %s locks its promise row with '%s'" % [when, id, why]
		var lock: String = SalesMeetingSystem._promise_lock()
		if lock != ("" if open else "promise_no_room"):
			return "%s: the meeting's promise answer reads the lock '%s'" % [when, lock]
		return ""
	var free := func(card: Dictionary) -> bool:
		return card.kind == "feature" and card.state == "candidate" and SprintCatalog.gate_reason(card.step) == "" \
			and card.step not in [pain, pitch]
	# Two steps given to the other accounts: each fits beside either word once, not twice, so the
	# first leaves room for the word and the two together do not.
	var cap: int = SprintSystem.capacity()
	var word: Array = [SprintCatalog.step_effort(pain), SprintCatalog.step_effort(pitch)]
	var owed: Array = []
	for area_id in SprintCatalog.area_ids():
		for card in SprintCatalog.candidates(area_id):
			if owed.size() < 2 and free.call(card) and cap - SprintCatalog.step_effort(card.step) >= word.max() \
					and cap - 2 * SprintCatalog.step_effort(card.step) < word.min():
				owed.append(card.step)
	if owed.size() < 2:
		return "fixture: no two steps that fit beside the word once but not twice (capacity %d)" % cap
	# Feature steps that are no word go to `place` until fewer than three points are free.
	var fill := func(place: Callable, load: Callable) -> float:
		for area_id in SprintCatalog.area_ids():
			for card in SprintCatalog.candidates(area_id):
				if load.call() < SprintSystem.capacity() - 2 and free.call(card) and card.step not in owed:
					place.call(card)
		return SprintSystem.capacity() - load.call()
	var fail: String = check.call(true, "an empty plan")
	if fail != "":
		return fail
	for account in accounts.slice(1):
		B2BSalesSystem.accept_promise(account.id, owed[0], B2BConstants.PROMISE_DEADLINE_WEEKS)
	fail = check.call(true, "one step promised to two accounts")
	if fail != "":
		return fail
	B2BSalesSystem.accept_promise(accounts[1].id, owed[1], B2BConstants.PROMISE_DEADLINE_WEEKS)
	fail = check.call(false, "open promises outside the plan")
	if fail != "":
		return fail
	var add := func(card: Dictionary) -> void: SprintSystem.add(card.id)
	if fill.call(add, func() -> float: return SprintSystem.used()) >= 3.0:
		return "fixture: the plan could not be filled"
	fail = check.call(false, "a full plan")
	if fail != "":
		return fail
	var row: Dictionary = {"answers": [{"id": "a_promise", "verb": SalesProbes.VERB_PROMISE}]}
	var answer: Dictionary = SalesProbes.answers_for(row, {"has_promise_target": true}, SalesMeetingSystem._promise_lock())[0]
	var key: String = SalesMeetingSystem._lock_key(String(answer.get("lock_fact", "")))
	if bool(answer.open) or key != "SALES_LOCK_PROMISE_NO_ROOM":
		return "the meeting shows its locked promise answer with '%s', not the card rows' reason" % key
	if not SprintSystem.start():
		return "fixture: the sprint did not start"
	fail = check.call(true, "a running sprint before an empty next sprint")
	if fail != "":
		return fail
	var send := func(card: Dictionary) -> void: SprintSystem.send_next(card.id)
	var next_load := func() -> float: return SprintSystem.points_left(GameState.product.next.cards)
	if fill.call(send, next_load) >= 3.0:
		return "fixture: the next sprint could not be filled"
	return check.call(false, "a full next sprint")


## product.sprint_late yalnız gerçekten geride kalan kartta açılır: sprintin kalan haftası bugünkü
## ekiple oynanır. Kurucuyla geliştirici ilk haftayı ilk karta verir; ikinci kart hiç ilerlememiştir
## ama ikinci hafta ikisi ona yetişir, kâğıt istenmez. Tek kurucunun ikinci kartı yetişmez: kâğıt
## gelir ve fazla mesai satırı ekipsiz de açıktır.
## FALSİFİKASYON: sprint_late.json'un koşulundan urun.decision_card_late yaprağını sil → ilk sprintte
## kâğıt istenir.
static func _case_sprint_late_only_when_behind() -> String:
	_seed_sprint()
	var rate: Variant = SprintCatalog.cfg("decision.rate")
	var events: Variant = SprintCatalog.cfg("decision.cards")
	SprintCatalog._data.decision.rate = 1.0
	SprintCatalog._data.decision.cards = ["product.sprint_late"]
	var run := func() -> String:
		var asked: Array = []
		EventBus.card_decision_requested.connect(func(id: String) -> void: asked.append(id))
		var dev: Character = _sprint_hire("char_late_dev", HRConstants.ROLE_DEVELOPER)
		var lines: Array = SprintCatalog.capabilities("core")
		for line_id in lines.slice(0, 2):
			SprintSystem.add("feat:%s_k1" % line_id)
		if not SprintSystem.start():
			return "fixture: sprint 1 did not start"
		_sim_day()
		if _card_worked("feat:%s_k1" % lines[1]) > 0.0:
			return "fixture: the second card got work in the first week"
		if not asked.is_empty():
			return "sprint_late asked about %s, which the founder and the developer finish this week" % asked
		_sim_day()
		SprintSystem.plan_next()
		CharacterRegistry.remove(dev.id)
		for line_id in lines.slice(2, 4):
			SprintSystem.add("feat:%s_k1" % line_id)
		if not SprintSystem.start():
			return "fixture: sprint 2 did not start"
		_sim_day()
		var behind: String = "feat:%s_k1" % lines[3]
		if asked != [behind] or GameState.product.decision.get("event_id", "") != "product.sprint_late":
			return "the solo founder's sprint asked about %s (%s), want sprint_late on %s" % [
				asked, GameState.product.decision, behind]
		var ev: GameEvent = EventGate.render("product.sprint_late")
		if not _row_unlocked(ev, _row_with_verb(ev, "sprint_hours"), {}):
			return "the overtime row is locked for a solo founder"
		return ""
	var fail: String = run.call()
	SprintCatalog._data.decision.rate = rate
	SprintCatalog._data.decision.cards = events
	return fail


## v14 → v15: sürmekte olan yapım Sprint 1'in planı olur. Planlanan her kademe bir özellik kartıdır:
## tasarımı dolu, geliştirmesi yapımın vardığı yerde, lisansı ödenmiş. Hattın şimdiki kademesinin
## damgası cilaya döner (tek tur üstü yarım, üç tur tam), yapımın bayrakları düşer. Taşınan dünya
## Sprint 1 planlamada açılır; başlatma lisansı yeniden kesmez ve kartlar kaldıkları yerden yürür.
static func _case_save_v14_build_becomes_sprint_plan() -> String:
	var slot: String = "smoke_v14_build_%d" % OS.get_process_id()
	var done := func(why: String) -> String:
		SaveManager.delete_slot(slot)
		return why
	ProductLines.reload()
	GameState.set_cash(200000)
	GameState.set_flag("mvp_sub_product_type_id", "note_tool")
	var lines: Array = ProductLines.line_ids("note_tool")
	ProductState.set_line_tier(lines[0], 1)
	ProductState.stamp_step("%s_k1" % lines[0], 1.11)
	ProductState.set_line_tier(lines[1], 1)
	ProductState.stamp_step("%s_k1" % lines[1], 1.05)
	_drain_all_modals()
	if not SaveManager.save_to_slot(slot):
		return done.call("save_to_slot failed (%s)" % SaveManager.cannot_save_reason_key())
	var path: String = SaveManager.SAVE_DIR + slot + ".json"
	var raw: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(path)) as Dictionary
	raw["schema_version"] = 14
	var gs: Dictionary = raw["state"]["game_state"]
	gs.erase("product")
	var dropped: Array = ["creation_draft", "cancelled_build_prefill", "product_path_frank_seen",
		"mvp_sprint_weeks_total", "mvp_bug_sprint_active", "bug_count_at_bugfix_start_b1"]
	for k in dropped:
		gs["flags"][k] = 1
	# A licensed K2 on a live line and a K1 that opens a new one, a quarter into development.
	var steps: Array = ["%s_k2" % lines[0], "%s_k1" % lines[2]]
	raw["state"]["systems"]["product"]["active_build"] = {SaveCodec.TYPE_TAG: "FeatureBuild",
		"product_name": "Notly", "planned_step_ids": steps, "total_efor": 8.0, "efor_spent": 2.0,
		"current_phase": "development"}
	var w := FileAccess.open(path, FileAccess.WRITE)
	w.store_string(JSON.stringify(raw, "\t", false, true))
	w.close()

	var payload: Dictionary = SaveManager.read_slot(slot)
	if not bool(payload.get("ok", false)):
		return done.call("the v14 save was refused: %s" % payload.get("error_key", ""))
	var st: Dictionary = payload["state"]
	var flags: Dictionary = st["game_state"]["flags"]
	var product: Dictionary = st["game_state"].get("product", {})
	if (st["systems"]["product"] as Dictionary).has("active_build"):
		return done.call("the build survived the migration")
	for k in dropped:
		if flags.has(k):
			return done.call("flag '%s' survived the migration" % k)
	if String(flags.get("mvp_product_name", "")) != "Notly" or String(flags.get("mvp_market_type", "")) != "b2c":
		return done.call("the type reads name '%s', market '%s'; want the build's name and the subtype's market" % [
			flags.get("mvp_product_name", ""), flags.get("mvp_market_type", "")])
	var ids: Array = steps.map(func(s: String) -> String: return "feat:" + s)
	if product.get("mode", "") != "plan" or int(product.sprint.number) != 1 or product.sprint.status != "planning" \
			or product.sprint.cards != ids:
		return done.call("the migrated product opens in %s, sprint %s %s with %s; want Sprint 1 planning with %s" % [
			product.get("mode", ""), product.get("sprint", {}).get("number"), product.get("sprint", {}).get("status"),
			product.get("sprint", {}).get("cards"), ids])
	var shares: Array = SprintCatalog.card_shares("feature")
	var left: float = 0.0
	for id in ids:
		var c: Dictionary = product.cards[id]
		var effort: float = float(c.effort)
		var want: Array = [effort * shares[0], effort * shares[1] * 0.25, 0.0]
		for i in 3:
			if not is_equal_approx(float(c.progress[i]), want[i]):
				return done.call("%s carries progress %s, want design done and development a quarter in %s" % [
					id, c.progress, want])
		if c.state != "planned" or not c.paid:
			return done.call("%s reads state %s, paid %s; want a planned card whose licence is paid" % [id, c.state, c.paid])
		left += effort - want[0] - want[1]
	var polish: Dictionary = product.polish
	if not is_equal_approx(float(polish.get(lines[0], 0.0)), float(SprintCatalog.cfg("polish_max"))) \
			or not is_equal_approx(float(polish.get(lines[1], 0.0)), float(SprintCatalog.cfg("polish_step"))):
		return done.call("polish reads %s, want the full stamp on %s and the half on %s" % [polish, lines[0], lines[1]])

	if not SaveManager.apply_loaded_state(payload):
		return done.call("apply_loaded_state returned false")
	if SprintSystem.mode() != "plan" or not is_equal_approx(SprintSystem.used(), left):
		return done.call("the loaded plan reads %s with a load of %.2f, want planning with %.2f left" % [
			SprintSystem.mode(), SprintSystem.used(), left])
	var cash: int = GameState.cash
	if not SprintSystem.start():
		return done.call("the migrated plan did not start")
	if GameState.cash != cash:
		return done.call("the sprint start charged the migrated cards' licences again (%d -> %d)" % [cash, GameState.cash])
	var worked: float = _card_worked(ids[0])
	_sim_day()
	if _card_worked(ids[0]) <= worked:
		return done.call("the migrated card did not move from where the build left it")
	return done.call("")


## v14 kaydının sürüm geçmişi Geçmiş'in sürüm listesine taşınır; sprintten önceki sürümün sprinti
## ve kart sayısı yoktur (-1, çizilmez).
## FALSİFİKASYON: _migrate_15'te "releases": releases yerine [] yaz → FAIL.
static func _case_save_v14_history_becomes_releases() -> String:
	var state := {"game_state": {"day": 30.0, "flags": {"mvp_sub_product_type_id": "note_tool",
		"mvp_market_type": "b2c", "mvp_shipped": true, "mvp_version": 2.0, "mvp_line_tiers": {},
		"mvp_version_history": [{"version": 1.0, "day": 10.0}, {"version": 2.0, "day": 20.0}]}},
		"systems": {"product": {}}}
	SaveManager._migrate_15(state)
	var releases: Array = state.game_state.product.releases
	if releases.map(func(r: Dictionary) -> int: return int(r.number)) != [1, 2]:
		return "releases came back %s, want versions 1 and 2" % str(releases)
	GameState.set_flag("mvp_sub_product_type_id", "note_tool")
	GameState.set_flag("mvp_market_type", "b2c")
	GameState.product = state.game_state.product
	var rows: Array = ProductModel.live().versions
	if rows.size() != 2 or int(rows[0].sprint) != -1 or int(rows[0].shipped_count) != -1:
		return "Geçmiş rows came back %s" % str(rows)
	return ""


## Ücretli plan yayındaki ürünün katmanıdır: MVP'den önce kilitli ve gerekçeli, "+" ve "→" onu
## almaz, lider önermez; MVP'den sonra açılır.
## FALSİFİKASYON: SprintCatalog.gate_reason'daki PAID_PLAN dalını sil → FAIL.
static func _case_product_paid_plan_locked_until_mvp() -> String:
	_seed_sprint()
	var id: String = "plan:" + SprintCatalog.PAID_PLAN
	if SprintCatalog.gate_reason(SprintCatalog.PAID_PLAN) == "":
		return "the paid plan is open before MVP"
	SprintSystem.add(id)
	SprintSystem.send_next(id)
	if id in GameState.product.sprint.cards or id in GameState.product.next.cards:
		return "the paid plan was placed before MVP"
	if id in SprintCatalog.lead_suggestion():
		return "the lead suggests the paid plan before MVP"
	GameState.set_flag("mvp_shipped", true)
	if SprintCatalog.gate_reason(SprintCatalog.PAID_PLAN) != "":
		return "the paid plan is still locked after MVP"
	SprintSystem.add(id)
	if id not in GameState.product.sprint.cards:
		return "the paid plan cannot be added after MVP"
	return ""


## PM'in onaylanan planı o sprint sonraki sütun olunca oraya, açılınca sprintin kartlarına geçer;
## arada lider ileriye ayrılmış kartlara dokunmaz. Onaysız plan saklanmaz; sonraki sprintin planı
## onaylanınca kartları hemen sonraki sütuna geçer.
## FALSİFİKASYON: SprintSystem.plan_next'teki onaylı plan döngüsünü sil → FAIL; lead_suggestion'dan
## _approved_ahead()'i çıkar → FAIL.
static func _case_product_pm_plan_opens_as_next_sprint() -> String:
	_seed_sprint()
	_make_employee("e_des", "Ece", HRConstants.ROLE_DESIGNER)
	_make_employee("e_dev", "Kaan", HRConstants.ROLE_DEVELOPER)
	if not SprintCatalog.pm_plans().is_empty():
		return "the PM plans without a PM"
	_make_employee("e_pm", "Deniz", HRConstants.ROLE_PRODUCT_MANAGER)
	var plans: Array = SprintCatalog.pm_plans()
	if plans.map(func(p: Dictionary) -> int: return int(p.number)) != [2, 3, 4] \
			or plans.any(func(p: Dictionary) -> bool: return p.approved or p.cards.is_empty()):
		return "proposals came back %s" % str(plans)
	if not GameState.product.quarter.plans.is_empty():
		return "an unapproved plan was stored"
	var approved: Array = plans[1].cards
	SprintSystem.approve(3)
	if not SprintCatalog.pm_plans()[1].approved or GameState.product.quarter.plans.size() != 1:
		return "approve(3) did not stick"
	var next_plan: Array = SprintCatalog.pm_plans()[0].cards
	var ahead: Array = approved + SprintCatalog.pm_plans()[2].cards
	SprintSystem.approve_all()
	if next_plan.any(func(id: String) -> bool: return id not in GameState.product.next.cards):
		return "sprint 2's approved plan is not in the next column"
	for n in [2, 3]:
		SprintSystem.apply_lead()
		if ahead.any(func(id: String) -> bool: return id in GameState.product.sprint.cards):
			return "the lead took cards approved for later sprints into sprint %d" % (n - 1)
		if not SprintSystem.start():
			return "sprint %d did not start" % (n - 1)
		for _d in 3:
			if SprintSystem.mode() != "release":
				_sim_day()
		SprintSystem.plan_next()
		var holder: Array = GameState.product.next.cards if n == 2 else GameState.product.sprint.cards
		var missing: Array = approved.filter(func(id: String) -> bool: return id not in holder)
		if not missing.is_empty():
			return "at sprint %d %s is missing %s" % [n, "next" if n == 2 else "open", str(missing)]
	return ""
