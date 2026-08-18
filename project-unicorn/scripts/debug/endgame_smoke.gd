class_name EndgameSmoke
extends RefCounted

# Headless smoke harness for the endgame engines (ENDGAME_DESIGN.md Spec 1+2).
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

const GATE1_ID := "ev_phase_gate_traction"
const GATE2_ID := "ev_phase_gate_series_a"

# Fixture axis defaults, each chosen to be the NEUTRAL point of the channel it feeds:
#   SEED_PACE 4       → 0.25 × 4 = 1.0 efor/day, exactly a pre-Coupling assist engineer
#   SEED_EXPERTISE 5  → ProductSystem.SEED_EXPERTISE_PIVOT, so the commit-seed multiplier is 1.0
#   SEED_RAPPORT 5    → mid-ruler coordination when a seeded employee is made SORUMLU
const SEED_PACE := 4
const SEED_EXPERTISE := 5
const SEED_RAPPORT := 5

static var _gate_signals: Array = []   # phase_gate_reached payloads
static var _endings: Array = []        # run_ended ending_ids


static func run_case(case_name: String, payload: Dictionary) -> void:
	GameState.initialize_run(payload)
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
		"bankruptcy":           fail = _case_bankruptcy()
		"shutter_recovery":     fail = _case_shutter_recovery()
		"brand_collapse":       fail = _case_brand_collapse()
		"cascade":              fail = _case_cascade()
		"pivot_accept":         fail = _case_pivot_accept()
		"pivot_decline":        fail = _case_pivot_decline()
		"fork_win":             fail = _case_fork_win()
		"fork_loss":            fail = _case_fork_loss()
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
		"walk_counts_rejection": fail = _case_walk_counts_rejection()
		"table_sign_closes_series_a": fail = _case_table_sign_closes_series_a()
		"table_walk_counts_rejection": fail = _case_table_walk_counts_rejection()
		"patience_zero_locks_pushes": fail = _case_patience_zero_locks_pushes()
		"push_decay_lowers_odds": fail = _case_push_decay_lowers_odds()
		"leverage_bonus_applies_and_shows": fail = _case_leverage_bonus_applies_and_shows()
		"no_leverage_no_box": fail = _case_no_leverage_no_box()
		"investment_figure_tracks_terms": fail = _case_investment_figure_tracks_terms()
		"table_board_push_sequence": fail = _case_table_board_push_sequence()
		"deal_prompt_defer_keeps_clock": fail = _case_deal_prompt_defer_keeps_clock()
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
		"b2b_rep_portrait_rotation": fail = _case_b2b_rep_portrait_rotation()
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
		"hr_search_cycle":          fail = _case_hr_search_cycle()
		"hr_search_cancel_dismiss": fail = _case_hr_search_cancel_dismiss()
		"hr_fire_path":             fail = _case_hr_fire_path()
		"hr_resignation_path":      fail = _case_hr_resignation_path()
		"hr_leave_cycle":           fail = _case_hr_leave_cycle()
		"hr_morale_no_drift":       fail = _case_hr_morale_no_drift()
		"hr_positive_recovery":     fail = _case_hr_positive_recovery()
		"hr_overtime_cost_tiers":   fail = _case_hr_overtime_cost_tiers()
		"hr_overtime_multipliers":  fail = _case_hr_overtime_multipliers()
		"hr_overtime_early_stop":   fail = _case_hr_overtime_early_stop()
		"hr_overtime_same_day_stop_bills": fail = _case_hr_overtime_same_day_stop_bills()
		"hr_overtime_safety_valve": fail = _case_hr_overtime_safety_valve()
		"hr_raise_and_vacation":    fail = _case_hr_raise_and_vacation()
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
		"sales_overtime_multiplier":         fail = _case_sales_overtime_multiplier()
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
		# --- Bug cleanup 2026-08-07 (AUDIT_2026-08-06): each of these FAILS against the
		#     pre-fix engine, which is what makes them regression guards rather than décor.
		"b2b_expansion_no_refire":            fail = _case_b2b_expansion_no_refire()
		"fumes_zero_revenue_ledger":          fail = _case_fumes_zero_revenue_ledger()
		"promise_orphan_no_brand_hit":        fail = _case_promise_orphan_no_brand_hit()
		"build_percent_single_source":        fail = _case_build_percent_single_source()
		"runway_days_and_negative_cash":      fail = _case_runway_days_and_negative_cash()
		"b2b_market_gate_b2c_run":            fail = _case_b2b_market_gate_b2c_run()
		"sales_autoclose_empty_pain":         fail = _case_sales_autoclose_empty_pain()
		"event_queue_dedupe_by_id":           fail = _case_event_queue_dedupe_by_id()
		# --- Playable Run Sprint 2026-08-17. Each one FAILS against the pre-fix engine;
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
static func _sim_day() -> void:
	GameState.advance_day()
	TimeManager._dispatch_daily_tick()


# TAM GÜN sürücü: motorun gerçek gün sınırını birebir yansıtır.
# TimeManager._drain_boundaries sırası: saat 1..23 → saat 0 → advance_day() → günlük
# slotlar. Günlük tik saat 0 ile saat 1'in ARASINDA durur; maliyeti günlük, faydayı
# saatlik işleyen her mekanizma tam olarak orada ayrışır (S1-3 ek mesai bedava hızı ve
# S2-37 bonus/ödeme asimetrisi bu boşlukta yaşıyordu, 135 case boyunca görünmeden).
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


static func _make_employee(id: String, display_name: String, role_id: String,
		pace: int = SEED_PACE, salary: int = 0, morale: int = 50,
		expertise: int = SEED_EXPERTISE, rapport: int = SEED_RAPPORT) -> Character:
	# ONE home for every employee seed. All three axes are parameters now (HR Coupling made
	# each of them load-bearing: pace → build speed, expertise → bug/wear average and the
	# commit seed, rapport → the coordination multiplier when this person is the SORUMLU).
	# Defaults are the NEUTRAL point of each channel, so a seed that does not care about an
	# axis cannot silently tilt an unrelated formula — see the SEED_* constants.
	var c := Character.new()
	c.id = id
	c.character_name = display_name
	c.role = role_id
	c.category = "employee"
	c.monthly_salary = salary
	c.morale = morale
	c.role_stats = {"expertise": expertise, "pace": pace, "rapport": rapport}
	c.traits = ["warms_up_fast"]
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
	p.industry = "Testing"
	p.archetype = "small"
	SalesSystem.add_b2b_customer(p, mrr, 70)


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
		if EventManager._active_event_id == event_id:
			return true
		if EventManager._active_event_id == "":
			return false
		EventManager.resolve_choice(EventManager._active_event_id, 0)
	return EventManager._active_event_id == event_id


# Occurrences of a gate scene across queue + active (must never exceed 1).
static func _instances_of(event_id: String) -> int:
	var n: int = 0
	for ev in EventManager._queue:
		if ev.id == event_id:
			n += 1
	if EventManager._active_event_id == event_id:
		n += 1
	return n


# Rev3: aktif build'i hedef faza gelene dek ProductSystem.hourly_tick ile sürer
# (sınırlı döngü; gün ilerletmez — saf build-motoru sürüşü).
# Player-gated iterasyon restore: tasarım kararı beklerken hedef İLERİ bir fazsa
# helper oyuncu koltuğuna oturup "Geliştirmeye geç" der — SIFIR ek tur, yani sıfır
# tur kazancı; determinizm case'leri (axes/ship damgaları) bire bir aynı kalır.
static func _run_build_to_phase(phase: String, max_hours: int = 24 * 120) -> bool:
	for i in max_hours:
		var b: FeatureBuild = ProductSystem.get_active_build()
		if b == null:
			return false
		if b.current_phase == phase:
			return true
		if b.current_phase == "iteration" and b.iteration_decision_pending and phase != "iteration":
			ProductSystem.enter_development()
			continue
		ProductSystem.hourly_tick(i % 24)
	var b_end: FeatureBuild = ProductSystem.get_active_build()
	return b_end != null and b_end.current_phase == phase


# İterasyon-döngüsü sürücüleri (player-gated restore): tasarım bandını karar anına
# sürer / bir "Bir tur daha" turunu baştan sona koşar (yeniden pending'e dönene dek).
static func _drive_to_iter_pending(max_hours: int = 24 * 60) -> bool:
	var b: FeatureBuild = ProductSystem.get_active_build()
	if b == null:
		return false
	for i in max_hours:
		if b.iteration_decision_pending:
			return true
		ProductSystem.hourly_tick(i % 24)
	return b.iteration_decision_pending


static func _run_iteration_round(max_hours: int = 24 * 30) -> bool:
	ProductSystem.advance_iteration()
	var b: FeatureBuild = ProductSystem.get_active_build()
	if b == null or b.iteration_round_days <= 0.0:
		return false
	for i in max_hours:
		if b.iteration_decision_pending:
			return true
		ProductSystem.hourly_tick(i % 24)
	return b.iteration_decision_pending


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


# --- Gate cases (Spec 1) ---

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
	EventManager.resolve_choice(GATE1_ID, 0)  # "Hazırız — geçelim"
	if GameState.phase != 2:
		return "advance_phase did not run (phase=%d)" % GameState.phase
	if GameState.phase_gate_ready or GameState.pending_next_phase != 0:
		return "gate latch not cleared after advance"
	return ""


static func _case_gate2() -> String:
	GameState.set_phase(2)  # debug backdoor — gate 1 already passed
	_seed_b2b(6000)         # MRR ≥ 5000; brand stays at neutral 50 ≥ 25
	_sim_day()
	if not GameState.phase_gate_ready or GameState.pending_next_phase != 3:
		return "gate 2 did not open (ready=%s pending=%d)" % [GameState.phase_gate_ready, GameState.pending_next_phase]
	if not _drain_to(GATE2_ID):
		return "gate 2 scene never became active"
	EventManager.resolve_choice(GATE2_ID, 0)
	if GameState.phase != 3:
		return "phase != 3 after confirm (%d)" % GameState.phase
	return ""


static func _case_gate_decline_reminder() -> String:
	_seed_b2b(500)
	_sim_day()
	if not _drain_to(GATE1_ID):
		return "gate scene never became active"
	EventManager.resolve_choice(GATE1_ID, 1)  # "Henüz değil"
	if GameState.phase != 1 or not GameState.phase_gate_ready:
		return "decline broke the latch (phase=%d ready=%s)" % [GameState.phase, GameState.phase_gate_ready]
	# No re-prompt before REMIND_INTERVAL_DAYS…
	for i in 4:
		_sim_day()
		if _instances_of(GATE1_ID) > 0:
			return "reminder re-enqueued early (day %d)" % GameState.day
	# …then exactly one re-prompt, with escalated copy.
	_sim_day()
	if _instances_of(GATE1_ID) != 1:
		return "reminder not re-enqueued at interval (instances=%d)" % _instances_of(GATE1_ID)
	var expected_body: String = String((PhaseGateSystem.GATES[0].bodies as Array)[1])
	if PhaseGateSystem._gate_event.body_text != expected_body:
		return "reminder copy did not escalate"
	# Never duplicates, even across further reminder windows.
	for i in 6:
		_sim_day()
		if _instances_of(GATE1_ID) > 1:
			return "gate scene duplicated (§7.10 violation)"
	return ""


# --- Ending cases (Spec 2) ---

static func _case_bankruptcy() -> String:
	GameState.set_cash(-1000)
	for i in 10:
		_sim_day()
		if not GameState.run_active:
			break
	if _endings != ["bankruptcy"]:
		return "endings: %s" % str(_endings)
	if GameState.run_active:
		return "run still active"
	if EventManager.get_queue_size() != 0:
		return "queue not flushed (%d left)" % EventManager.get_queue_size()
	return ""


static func _case_shutter_recovery() -> String:
	GameState.set_cash(-1000)
	for i in 3:
		_sim_day()
	if GameState.shutter_days_left != 5:
		return "counter wrong after 3 days (%d, want 5)" % GameState.shutter_days_left
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
	if not _drain_to("ev_pivot_offer"):
		return "pivot offer never became active"
	EventManager.resolve_choice("ev_pivot_offer", 0)  # "Pivot — devam ediyoruz"
	if not GameState.pivot_used:
		return "pivot_used not set"
	for i in 5:
		_sim_day()
	if not GameState.run_active:
		return "cascade re-fired after pivot (Erdem rule: VC path closed, run continues): %s" % str(_endings)
	return ""


static func _case_pivot_decline() -> String:
	_seed_b2b(3000)
	GameState.vc_rejections = 3
	_sim_day()
	if not _drain_to("ev_pivot_offer"):
		return "pivot offer never became active"
	EventManager.resolve_choice("ev_pivot_offer", 1)  # "Hayır. Bitti."
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
	if not ProductSystem.start_version_build(["ai_assistant_voice"], "founder"):
		return "v-build blocked during sprint (guard not removed)"
	var b: FeatureBuild = ProductSystem.get_active_build()
	if absf(ProductSystem.capacity_speed_factor() - 0.5) > 0.001:
		return "parallel factor not 0.5 (%.2f)" % ProductSystem.capacity_speed_factor()
	# Player-gated iterasyon: v-build'in minik tasarım bandı ölçüm penceresinin İÇİNE
	# düşmesin — karar anına sür, "Geliştirmeye geç" de; iki pencere de development'ta
	# ölçülür (mid-job developer kıyası da ancak orada anlamlı — design doc §5).
	for ih in 24 * 30:
		if b.iteration_decision_pending:
			break
		ProductSystem.hourly_tick(ih % 24)
	if not b.iteration_decision_pending:
		return "v-build design band never pended"
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
	# during the TASARIM fazı contributes nothing to speed yet (design doc §5 rol-faz eşlemesi),
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


static func _case_fork_win() -> String:
	_seed_b2b(6000)  # net +150/day, cash never dips, MRR ≥ threshold
	for i in 185:
		if not GameState.run_active:
			break
		_sim_day()
	if _endings != ["profitable_bootstrap"]:
		return "endings: %s (day %d, cash %d)" % [str(_endings), GameState.day, GameState.cash]
	if GameState.day != 180:
		return "fork fired on day %d, want 180" % GameState.day
	return ""


static func _case_fork_loss() -> String:
	GameState.cash_went_negative = true  # one fork condition failed → fumes
	for i in 185:
		if not GameState.run_active:
			break
		_sim_day()
	if _endings != ["running_on_fumes"]:
		return "endings: %s" % str(_endings)
	return ""


# --- Month-End Summary (Spec 3) ---

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
	if String(m.month_title) != "OCAK 2026":
		return "month_title: %s" % String(m.month_title)
	if String(m.day_range) != "Gün 1–31":
		return "day_range: %s" % String(m.day_range)
	if int(m.brand.from) != 50 or int(m.brand.to) != 60:
		return "brand delta: %s" % str(m.brand)
	if int(m.mrr.from) != 0 or int(m.mrr.to) != 0:
		return "mrr delta: %s" % str(m.mrr)
	# Hand-computed cash: 31 daily finance ticks × $50 burn, $0 revenue.
	if int(m.cash.from) != 10000 or int(m.cash.to) != 10000 - 31 * 50:
		return "cash delta: %s (want 10000 → %d)" % [str(m.cash), 10000 - 31 * 50]
	if int(m.team.from) != 1 or int(m.team.to) != 1:
		return "team delta: %s" % str(m.team)
	if String(m.highlight) != MonthSummarySystem.HIGHLIGHT_FALLBACK:
		return "quiet month should use fallback highlight, got: %s" % String(m.highlight)
	if String(m.frank_line) != "Bir ay daha. Ayakta olmak da bir metrik.":
		return "frank rule mismatch: %s" % String(m.frank_line)
	if int(GameState.month_ledger.get("start_day", 0)) != 32:
		return "ledger not re-snapshotted (start_day %s)" % str(GameState.month_ledger.get("start_day"))

	# Run counter seams (write-only; ledger deltas must not be affected).
	var p := Prospect.new()
	p.id = "lead_month_smoke"
	p.company_name = "Month Corp"
	p.industry = "Testing"
	p.archetype = "small"
	SalesSystem.add_b2b_customer(p, 500, 70)  # no mvp_shipped flag → gate 1 stays closed
	if GameState.run_customers_signed != 1:
		return "run_customers_signed = %d, want 1" % GameState.run_customers_signed
	EventManager._apply_modifiers([{"type": "churn_customer"}])
	if GameState.run_customers_lost != 1:
		return "run_customers_lost = %d, want 1" % GameState.run_customers_lost
	_make_employee("char_month_smoke_emp", "Smoke Hire", HRConstants.ROLE_DEVELOPER)
	if GameState.run_hires != 1:
		return "run_hires = %d, want 1" % GameState.run_hires
	if int(GameState.month_ledger.get("brand", -1)) != 60:
		return "counters disturbed the ledger snapshot"

	# Terminal suppression: Feb 2026 has 28 days → Feb closes at day 60 (Mar 1).
	# Force a Class-A ending on exactly that day: slot 9 ends the run before
	# slot 10 runs → the ending wins, no second summary (ledger 1/2 logic).
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
	for i in 10:
		_sim_day()
		if not GameState.run_active:
			break
	if _endings != ["bankruptcy"]:
		return "endings: %s" % str(_endings)
	if EventManager.get_queue_size() != 0:
		return "queue not flushed"
	# World stopped (§7.3): further ticks are no-ops, nothing re-enqueues.
	var cash_at_end: int = GameState.cash
	for i in 2:
		_sim_day()
	if GameState.cash != cash_at_end:
		return "cash changed after terminal (%d → %d)" % [cash_at_end, GameState.cash]
	if EventManager.get_queue_size() != 0:
		return "gate reminder re-enqueued after terminal"
	return ""


# --- VC Pitch cases (Spec 4) ---

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
	_seed_b2b(6000)
	_sim_day()  # aggregate MRR to 6000 (SalesSystem mrr bridge)
	if not VCPitchSystem.request_meeting("anchor"):
		return "request_meeting refused"
	for i in 5:
		_sim_day()
		if not GameState.run_active:
			return "run ended during wait: %s" % str(_endings)
		if EventManager._active_event_id == VCPitchSystem.MEETING_PROMPT_ID or _instances_of(VCPitchSystem.MEETING_PROMPT_ID) > 0:
			break
	if not _drain_to(VCPitchSystem.MEETING_PROMPT_ID):
		return "meeting prompt never enqueued"
	EventManager.resolve_choice(VCPitchSystem.MEETING_PROMPT_ID, 0)  # "Toplantıya gir"
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
	_seed_b2b(6000)
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
	GameState.set_flag("mvp_live_bug_count", 1)   # satisfy: bugs under target
	_sim_day()
	if not st.get("callback", {}).get("met", false):
		return "callback not met after condition satisfied"
	if not st.get("reentry_bonus", false):
		return "reentry_bonus not armed"
	var seed_with: int = int(VCPitchSystem.seed_conviction("meridian").value)
	st["reentry_bonus"] = false
	var seed_without: int = int(VCPitchSystem.seed_conviction("meridian").value)
	if seed_with - seed_without != PitchConstants.SEED_CALLBACK_BONUS:
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
	GameState.set_phase(3)
	GameState.active_sheets.append(VCPitchSystem._make_sheet("anchor", GameState.day))
	var warned := false
	for i in 20:
		_sim_day()
		if _instances_of(VCPitchSystem.SHEET_WARN_ID) > 0 or EventManager._active_event_id == VCPitchSystem.SHEET_WARN_ID:
			warned = true
		if GameState.active_sheets.is_empty():
			break
	if not warned:
		return "no expiry warning enqueued at day 3"
	if not GameState.active_sheets.is_empty():
		return "sheet did not expire"
	if GameState.vc_states.get("anchor", {}).get("status", "") != "expired":
		return "status not expired"
	if GameState.vc_rejections != 0:
		return "expiry counted as rejection (%d)" % GameState.vc_rejections
	return ""


static func _case_third_sheet_delayed() -> String:
	GameState.set_phase(3)
	_force("pass")
	_seed_b2b(6000)
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


static func _case_walk_counts_rejection() -> String:
	GameState.set_phase(3)
	GameState.active_sheets.append(VCPitchSystem._make_sheet("anchor", GameState.day))
	GameState.active_sheets.append(VCPitchSystem._make_sheet("nexus", GameState.day))
	VCPitchSystem.walk_table("anchor")
	if GameState.vc_rejections != 1:
		return "walk not counted (%d)" % GameState.vc_rejections
	if GameState.vc_states.get("anchor", {}).get("status", "") != "walked":
		return "status not walked"
	if VCPitchSystem.sheet_for("anchor") != null:
		return "walked sheet survived"
	if VCPitchSystem.sheet_for("nexus") == null:
		return "other sheet destroyed by walk"
	return ""


# ============================================================================
# Term Sheet Table cases (Spec 6) — drive TermSheetTableSystem engine-directly (no scene).
# ============================================================================

static func _grant(vc: String) -> void:
	GameState.active_sheets.append(VCPitchSystem._make_sheet(vc, GameState.day))


static func _case_table_sign_closes_series_a() -> String:
	GameState.set_phase(3)
	_force("pass")
	_grant("anchor")
	var captured: Array = []  # ending_data dicts (Array mutation survives lambda capture)
	EventBus.run_ended.connect(func(_id: String, d: Dictionary) -> void: captured.append(d))
	TermSheetTableSystem.open("anchor")
	TermSheetTableSystem.select_lever("valuation")
	TermSheetTableSystem.push()  # valuation 18 → 22
	TermSheetTableSystem.sign()
	if _endings != ["series_a_close"]:
		return "endings: %s" % str(_endings)
	if captured.is_empty():
		return "no ending data captured"
	var d: Dictionary = captured[0]
	if int(d.get("valuation_m", 0)) != 22:
		return "valuation_m=%s (want 22)" % str(d.get("valuation_m"))
	if int(d.get("dilution_pct", 0)) != 22:
		return "dilution_pct=%s (want 22)" % str(d.get("dilution_pct"))
	if int(d.get("board_seats", -1)) != 1 or not bool(d.get("board_veto", false)):
		return "board terms: seats=%s veto=%s" % [str(d.get("board_seats")), str(d.get("board_veto"))]
	if int(d.get("money_raised", 0)) != int(round(22 * 1_000_000.0 * 22 / 100.0)):
		return "money_raised=%s" % str(d.get("money_raised"))
	return ""


static func _case_table_walk_counts_rejection() -> String:
	GameState.set_phase(3)
	_grant("anchor")
	_grant("nexus")
	var walked: Array = []
	EventBus.sheet_walked.connect(func(vc: String) -> void: walked.append(vc))
	TermSheetTableSystem.open("anchor")
	TermSheetTableSystem.walk()
	if GameState.vc_rejections != 1:
		return "vc_rejections=%d (want 1)" % GameState.vc_rejections
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
	GameState.set_phase(3)
	_force("fail")
	_grant("bosphorus")  # patience 2
	TermSheetTableSystem.open("bosphorus")
	TermSheetTableSystem.select_lever("valuation")
	TermSheetTableSystem.push()  # fail → patience 1
	TermSheetTableSystem.push()  # fail → patience 0 → PATIENCE_ZERO
	var vs: Dictionary = TermSheetTableSystem.view_state()
	if int(vs.state) != TermSheetTableSystem.PATIENCE_ZERO:
		return "state=%d (want PATIENCE_ZERO=%d)" % [int(vs.state), TermSheetTableSystem.PATIENCE_ZERO]
	for lever in TermSheetTableSystem.LEVERS:
		if TermSheetTableSystem.can_push(lever):
			return "can still push %s at patience zero" % lever
	if not bool(vs.sign_enabled) or not bool(vs.walk_enabled):
		return "sign/walk disabled at patience zero"
	if int(vs.patience.current) != 0:
		return "patience.current=%d" % int(vs.patience.current)
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
	var base_val: int = int(InvestorRegistry.get_investor("anchor").get("opening_terms", {}).get("valuation_m", 0))
	var cur: String = String(vs.levers[0].current_text)
	var lev_val: int = int(cur.trim_prefix("$").trim_suffix("M"))
	if lev_val != base_val + PitchConstants.LEVERAGE_OPEN_NOTCH:
		return "opening notch not applied (%d, want %d)" % [lev_val, base_val + PitchConstants.LEVERAGE_OPEN_NOTCH]
	var baseline: float = SkillCheck.chance_for("sales", int(PitchConstants.LEVER_DIFF["valuation"]), 0)
	if TermSheetTableSystem.odds_for("valuation").chance <= baseline:
		return "leverage did not raise odds above baseline"
	if String(vs.leverage.other_vc_name) != "Nexus Ventures":
		return "other_vc_name=%s" % String(vs.leverage.other_vc_name)
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
	if int(cur.trim_prefix("$").trim_suffix("M")) != 18:
		return "single-sheet opening notched (%s)" % cur
	return ""


static func _case_investment_figure_tracks_terms() -> String:
	GameState.set_phase(3)
	_force("pass")
	_grant("anchor")
	TermSheetTableSystem.open("anchor")
	var m0: int = TermSheetTableSystem.money_raised()
	if m0 != int(round(18 * 1_000_000.0 * 22 / 100.0)):
		return "m0=%d" % m0
	TermSheetTableSystem.select_lever("valuation")
	TermSheetTableSystem.push()  # val 22
	var m1: int = TermSheetTableSystem.money_raised()
	if m1 <= m0 or m1 != int(round(22 * 1_000_000.0 * 22 / 100.0)):
		return "m1=%d (want > m0 and 22×22%%)" % m1
	TermSheetTableSystem.select_lever("dilution")
	TermSheetTableSystem.push()  # dil 18
	var m2: int = TermSheetTableSystem.money_raised()
	if m2 >= m1 or m2 != int(round(22 * 1_000_000.0 * 18 / 100.0)):
		return "m2=%d (want < m1 and 22×18%%)" % m2
	return ""


static func _case_table_board_push_sequence() -> String:
	GameState.set_phase(3)
	_force("pass")
	_grant("anchor")  # board 1 seat + veto
	TermSheetTableSystem.open("anchor")
	TermSheetTableSystem.select_lever("board")
	TermSheetTableSystem.push()  # drop veto
	if String(TermSheetTableSystem.view_state().levers[2].current_text) != "1 koltuk":
		return "after veto push: %s (want '1 koltuk')" % String(TermSheetTableSystem.view_state().levers[2].current_text)
	TermSheetTableSystem.push()  # drop seat
	if String(TermSheetTableSystem.view_state().levers[2].current_text) != "temiz":
		return "after seat push: %s (want 'temiz')" % String(TermSheetTableSystem.view_state().levers[2].current_text)
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
	if sheet.days_left(GameState.day) != PitchConstants.SHEET_VALIDITY_DAYS:
		return "validity clock not at full (%d)" % sheet.days_left(GameState.day)
	for i in 3:
		_sim_day()
	if VCPitchSystem.sheet_for("anchor") == null:
		return "sheet expired too early during defer"
	var vs: Dictionary = TermSheetTableSystem.open("anchor")
	if vs.is_empty() or not TermSheetTableSystem.is_active():
		return "table not re-enterable after defer"
	if sheet.days_left(GameState.day) != PitchConstants.SHEET_VALIDITY_DAYS - 3:
		return "clock did not tick during defer (%d)" % sheet.days_left(GameState.day)
	return ""


static func _case_prep_bonus_and_capacity() -> String:
	GameState.set_phase(3)
	if not VCPitchSystem.request_meeting("anchor"):
		return "request refused"
	if not VCPitchSystem.start_prep("anchor", "rakamlar"):
		return "prep refused (should be allowed, 3 days out)"
	if not GameState.get_flag("pitch_prep_active", false):
		return "capacity flag not set"
	if ProductSystem.capacity_demand() < 1:
		return "prep did not occupy capacity (demand=%d)" % ProductSystem.capacity_demand()
	VCPitchSystem.begin_meeting("anchor")  # consumes the prep focus
	if GameState.get_flag("pitch_prep_active", false):
		return "capacity flag not cleared at meeting start"
	if ProductSystem.capacity_demand() != 0:
		return "capacity not released after prep consumed (%d)" % ProductSystem.capacity_demand()
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
	_seed_b2b(6000)
	_sim_day()  # base seed comfortably positive so the [0,100] clamp doesn't hide the penalty
	var seed_clear: int = int(VCPitchSystem.seed_conviction("anchor").value)
	GameState.shutter_days_left = 5  # Kepenk active
	VCPitchSystem.begin_meeting("anchor")
	if not VCPitchSystem.is_meeting_active():
		return "meeting blocked during Kepenk (should be allowed — ledger 12)"
	var seed_shutter: int = int(VCPitchSystem.seed_conviction("anchor").value)
	if seed_clear - seed_shutter != -PitchConstants.SEED_SHUTTER_PENALTY:
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
	# §F-1: the seat-upsell now moves SEATS (and prices MRR off seats) on the named account,
	# emits customer_seats_changed, and reflects the aggregate into GameState.mrr.
	_seed_b2b(2000)
	var cust: Customer = CustomerRegistry.get_by_market("b2b")[0]
	var seats0: int = cust.seats
	var mrr0: int = cust.mrr
	var seat_signals: Array = []
	var cb := func(_id: String, n: int) -> void: seat_signals.append(n)
	EventBus.customer_seats_changed.connect(cb)
	# Synthetic seats-modifier event (the state-bound expansion family replaced the old
	# random ev_ps_expansion_b2b JSON; the generic `seats` modifier stays for this path).
	EventManager.enqueue(_one_choice_event("smoke_seat_upsell",
		[{"type": "seats", "amount": 4, "per_seat_mrr": 150, "customer_id": cust.id}]))
	if EventManager._active_event_id != "smoke_seat_upsell":
		EventBus.customer_seats_changed.disconnect(cb)
		return "seat upsell event not active (%s)" % EventManager._active_event_id
	EventManager.resolve_choice("smoke_seat_upsell", 0)   # +4 koltuk @150
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
	# §F-8: satisfaction changes route through CustomerRegistry.set_satisfaction and emit.
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
	# §F-9: a customer_id-targeted modifier hits ONLY the named account, not a bystander.
	_seed_b2b(1000)   # co_lead_smoke, seats 4
	var p := Prospect.new()
	p.id = "lead_two"
	p.company_name = "Second Corp"
	p.industry = "Testing"
	p.archetype = "mid"
	SalesSystem.add_b2b_customer(p, 2000, 70)   # co_lead_two, seats 12
	var c1: Customer = CustomerRegistry.get_customer("co_lead_smoke")
	var c2: Customer = CustomerRegistry.get_customer("co_lead_two")
	var s1: int = c1.seats
	var s2: int = c2.seats
	EventManager.enqueue(_one_choice_event("smoke_seat_target", [{"type": "seats", "amount": 5, "per_seat_mrr": 100, "customer_id": "co_lead_two"}]))
	EventManager.resolve_choice("smoke_seat_target", 0)
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
	var want_keys: Array = ["salaries", "overtime", "founder", "marketing", "office"]
	var keys: Array = FinanceSystem.STARTING_BURN_BREAKDOWN.keys()
	if keys.size() != want_keys.size():
		return "breakdown holds %d categories, want %d: %s" % [keys.size(), want_keys.size(), str(keys)]
	for key in want_keys:
		if not FinanceSystem.STARTING_BURN_BREAKDOWN.has(key):
			return "breakdown lost category '%s'" % key
		if not FinanceSystem.BURN_LABELS.has(key):
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
	# §F-10/§E-D.2: set_burn_category refreshes GameState.daily_burn immediately (no daily tick).
	var burn0: int = GameState.daily_burn
	FinanceSystem.set_burn_category("marketing", 100)
	var expected: int = FinanceSystem.compute_total_burn()
	if GameState.daily_burn != expected:
		return "daily_burn stale: %d (want %d)" % [GameState.daily_burn, expected]
	if GameState.daily_burn <= burn0:
		return "burn did not rise after marketing spend (%d -> %d)" % [burn0, GameState.daily_burn]
	return ""


# --- Package 5: feature bug-seeding cases ---

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
	# Player-gated iterasyon (restore 2026-08): tasarım bandı dolunca build KARAR
	# bekleyerek park eder — auto-advance YOK, çıkış yalnız enter_development().
	# Sonrası eski kanun: [.20,.80) development, >=.80 bugfix OTOMATİK; %100'de
	# Beta'da PARK (auto-ship yok); launch yalnız Beta'da iş yapar.
	GameState.set_cash(50000)
	if not ProductSystem.start_build("ai_assistant", ["ai_assistant_chat", "ai_assistant_memory"], ""):
		return "start_build failed"
	var b: FeatureBuild = ProductSystem.get_active_build()
	# Beta öncesi launch → uyarı + no-op (build durur, ship flag'i yazılmaz).
	ProductSystem.launch()
	if GameState.get_flag("mvp_shipped", false) or ProductSystem.get_active_build() == null:
		return "launch outside beta was not a no-op"
	# 1) Tasarım bandı: karar yanana dek sür; faz kendi kendine asla değişmez.
	var hours: int = 0
	while not b.iteration_decision_pending:
		if b.current_phase != "iteration":
			return "left iteration without a decision (phase %s)" % b.current_phase
		ProductSystem.hourly_tick(hours % 24)
		hours += 1
		if hours > 24 * 120:
			return "design band never pended (%.2f / %.2f)" % [b.efor_spent, b.total_efor]
	var design_cap: float = ProductSystem.PHASE_DESIGN_END * b.total_efor
	if absf(b.efor_spent - design_cap) > 0.001:
		return "park efor not clamped at design band (%.3f, want %.3f)" % [b.efor_spent, design_cap]
	if b.iteration_count != 1:
		return "iteration_count at first pend: %d (want 1)" % b.iteration_count
	# 2) Tasarım parkı (beta parkının aynası): 3 gün daha tik → faz aynı, efor donuk.
	for i in 24 * 3:
		ProductSystem.hourly_tick(i % 24)
	if b.current_phase != "iteration":
		return "auto-advanced out of design park (phase %s)" % b.current_phase
	if absf(b.efor_spent - design_cap) > 0.001:
		return "efor moved during design park (%.3f)" % b.efor_spent
	# 3) Oyuncu kararı → development; dev→beta bandı OTOMATİK kalır.
	ProductSystem.enter_development()
	if b.current_phase != "development":
		return "enter_development did not flip phase (%s)" % b.current_phase
	hours = 0
	while b.efor_spent < b.total_efor:
		ProductSystem.hourly_tick(hours % 24)
		hours += 1
		if hours > 24 * 120:
			return "efor never completed (%.1f / %.1f)" % [b.efor_spent, b.total_efor]
		var frac: float = b.efor_spent / maxf(0.001, b.total_efor)
		var want: String = "development"
		if frac >= ProductSystem.PHASE_DEV_END:
			want = "bugfix"
		if b.current_phase != want:
			return "phase %s at frac %.3f (want %s)" % [b.current_phase, frac, want]
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
	if _instances_of("ev_mvp_ship_moment") < 1:
		return "ship moment not enqueued from beta launch"
	ProductSystem.ship_active_build()
	if not GameState.get_flag("mvp_shipped", false):
		return "ship did not set mvp_shipped"
	if ProductSystem.get_active_build() != null:
		return "build slot not cleared after ship"
	return ""


# --- İterasyon döngüsü (player-gated restore) + ekip kalite tavanı ---

static func _case_iter_decision_gates_development() -> String:
	# İterasyon ASLA kendi kendine ilerlemez: tasarım bandı dolunca park (efor donuk,
	# faz aynı), çıkış yalnız enter_development() — ve öğretici moment tam BİR kez düşer.
	GameState.set_cash(50000)
	if not ProductSystem.start_build("ai_assistant", ["ai_assistant_chat", "ai_assistant_memory"], ""):
		return "start_build failed"
	var b: FeatureBuild = ProductSystem.get_active_build()
	if not _drive_to_iter_pending():
		return "design band never pended"
	if b.current_phase != "iteration":
		return "left iteration without a decision (phase %s)" % b.current_phase
	var cap: float = ProductSystem.PHASE_DESIGN_END * b.total_efor
	if absf(b.efor_spent - cap) > 0.001:
		return "park efor %.3f, want the design cap %.3f" % [b.efor_spent, cap]
	# 5 gün park: auto-advance yok, efor kımıldamaz.
	for i in 24 * 5:
		ProductSystem.hourly_tick(i % 24)
	if b.current_phase != "iteration" or absf(b.efor_spent - cap) > 0.001:
		return "park violated (phase %s, efor %.3f)" % [b.current_phase, b.efor_spent]
	if _instances_of("ev_mvp_iter_decision_intro") != 1:
		return "iter intro event enqueued %d times, want exactly 1" % _instances_of("ev_mvp_iter_decision_intro")
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
	# Çift yönlü plato: solo kurucu (tech 2) tavana dayanır; Tasarımcı (UZMANLIK 7)
	# gelince tavan formül kadar yükselir ve bir sonraki tur, solo platonun son
	# kazancından fazla verir — "daha iyi insanlar lazım" hissinin sayısal kanıtı.
	var founder: Character = CharacterRegistry.get_founder()
	founder.role_stats["tech"] = 2
	var want0: float = ProductSystem.ITER_CEIL_FOUNDER_COEF * 2.0
	var ceil0: Dictionary = ProductSystem.iteration_axis_ceilings()
	if absf(float(ceil0["innovation"]) - want0) > 0.001:
		return "solo innovation ceiling %.2f, want %.2f" % [float(ceil0["innovation"]), want0]
	GameState.set_cash(200000)
	if not ProductSystem.start_build("ai_assistant", ["ai_assistant_chat", "ai_assistant_memory"], ""):
		return "start_build failed"
	var b: FeatureBuild = ProductSystem.get_active_build()
	if not _drive_to_iter_pending():
		return "design band never pended"
	var stamp0: float = b.innovation
	var last_gain: float = INF
	var rounds: int = 0
	while ProductSystem.can_advance_iteration() and rounds < ProductSystem.ITER_MAX_ROUNDS - 2:
		var before: float = b.innovation
		if not _run_iteration_round():
			return "iteration round %d did not complete" % (rounds + 1)
		last_gain = b.innovation - before
		rounds += 1
		if last_gain < 0.05:
			break
	if last_gain >= 0.05:
		return "solo build never plateaued (%d rounds, last gain %.3f)" % [rounds, last_gain]
	if b.innovation > maxf(stamp0, want0) + 0.001:
		return "solo plateau %.2f exceeded the ceiling %.2f" % [b.innovation, want0]
	var solo_plateau: float = b.innovation
	_make_employee("char_iter_designer", "Iter Designer", HRConstants.ROLE_DESIGNER,
		SEED_PACE, 0, 50, 7)
	var want1: float = want0 + minf(7.0 * ProductSystem.ITER_CEIL_ROLE_COEF, ProductSystem.ITER_CEIL_ROLE_CAP)
	var ceil1: Dictionary = ProductSystem.iteration_axis_ceilings()
	if absf(float(ceil1["innovation"]) - want1) > 0.001:
		return "designer ceiling %.2f, want %.2f" % [float(ceil1["innovation"]), want1]
	if not ProductSystem.can_advance_iteration():
		return "cannot run the post-hire round (safety cap hit during the solo drive)"
	var before2: float = b.innovation
	if not _run_iteration_round():
		return "post-hire round did not complete"
	var gain2: float = b.innovation - before2
	if gain2 <= last_gain + 0.001:
		return "hire did not lift the plateau (gain %.3f vs solo last %.3f)" % [gain2, last_gain]
	if b.innovation <= solo_plateau + 0.05:
		return "axis did not move visibly above the solo plateau (%.2f vs %.2f)" % [b.innovation, solo_plateau]
	return ""


static func _case_iter_diminishing_returns() -> String:
	# Azalan getiri: tur N+1'in kazancı tur N'inkinden KÜÇÜK (ikisi de > 0).
	# Tasarımcı baştan masada → tavan yüksek, iki tur boyunca bol headroom.
	var founder: Character = CharacterRegistry.get_founder()
	founder.role_stats["tech"] = 2
	_make_employee("char_iter_dr_designer", "DR Designer", HRConstants.ROLE_DESIGNER,
		SEED_PACE, 0, 50, 7)
	GameState.set_cash(200000)
	if not ProductSystem.start_build("ai_assistant", ["ai_assistant_chat", "ai_assistant_memory"], ""):
		return "start_build failed"
	var b: FeatureBuild = ProductSystem.get_active_build()
	if not _drive_to_iter_pending():
		return "design band never pended"
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
	# tavan üstü commit damgasını) aşamaz; tavanda advance reddeder, çıkış hâlâ oyuncuda.
	var founder: Character = CharacterRegistry.get_founder()
	founder.role_stats["tech"] = 1   # taban tavan 4 → damga tavanın üstünde kalabilir
	GameState.set_cash(200000)
	if not ProductSystem.start_build("ai_assistant", ["ai_assistant_chat", "ai_assistant_memory"], ""):
		return "start_build failed"
	var b: FeatureBuild = ProductSystem.get_active_build()
	if not _drive_to_iter_pending():
		return "design band never pended"
	var stamp := {"innovation": b.innovation, "stability": b.stability, "experience": b.experience}
	var ceilings: Dictionary = ProductSystem.iteration_axis_ceilings()
	while ProductSystem.can_advance_iteration():
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
	ProductSystem.advance_iteration()
	if b.iteration_count != ProductSystem.ITER_MAX_ROUNDS:
		return "advance_iteration ran past the safety cap"
	if float(stamp["innovation"]) > float(ceilings["innovation"]) \
			and absf(b.innovation - float(stamp["innovation"])) > 0.0001:
		return "an above-ceiling stamp moved (%.3f -> %.3f)" % [float(stamp["innovation"]), b.innovation]
	ProductSystem.enter_development()
	if b.current_phase != "development":
		return "exit blocked at the safety cap"
	return ""


static func _case_iter_zero_staff_neutrality_and_axis_lock() -> String:
	# Sıfır ekip → her tavan kurucu tabanı; alakasız roller tavan OYNATMAZ; her rol
	# YALNIZ kendi eksenini yükseltir (sızıntı kontrolü — coupling_pm_experience aynası);
	# rol terimi ITER_CEIL_ROLE_CAP'te kesilir (çoklu işe alım istifi).
	var founder: Character = CharacterRegistry.get_founder()
	founder.role_stats["tech"] = 3
	var base: float = ProductSystem.ITER_CEIL_FOUNDER_COEF * 3.0
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
	_make_employee("char_iter_zs_designer", "ZS Designer", HRConstants.ROLE_DESIGNER, SEED_PACE, 0, 50, 6)
	c = ProductSystem.iteration_axis_ceilings()
	if absf(float(c["innovation"]) - (base + 6.0 * ProductSystem.ITER_CEIL_ROLE_COEF)) > 0.001:
		return "designer term wrong (%.2f)" % float(c["innovation"])
	if absf(float(c["stability"]) - base) > 0.001 or absf(float(c["experience"]) - base) > 0.001:
		return "designer leaked into stability/experience"
	_make_employee("char_iter_zs_dev", "ZS Dev", HRConstants.ROLE_DEVELOPER, SEED_PACE, 0, 50, 4)
	c = ProductSystem.iteration_axis_ceilings()
	if absf(float(c["stability"]) - (base + 4.0 * ProductSystem.ITER_CEIL_ROLE_COEF)) > 0.001:
		return "developer term wrong (%.2f)" % float(c["stability"])
	if absf(float(c["experience"]) - base) > 0.001:
		return "developer leaked into experience"
	_make_employee("char_iter_zs_pm", "ZS PM", HRConstants.ROLE_PRODUCT_MANAGER, SEED_PACE, 0, 50, 9)
	_make_employee("char_iter_zs_pm2", "ZS PM 2", HRConstants.ROLE_PRODUCT_MANAGER, SEED_PACE, 0, 50, 9)
	c = ProductSystem.iteration_axis_ceilings()
	var want_pm: float = base + minf(18.0 * ProductSystem.ITER_CEIL_ROLE_COEF, ProductSystem.ITER_CEIL_ROLE_CAP)
	if absf(float(c["experience"]) - want_pm) > 0.001:
		return "PM term not capped at ITER_CEIL_ROLE_CAP (%.2f, want %.2f)" % [float(c["experience"]), want_pm]
	return ""


static func _case_iter_version_build_same_loop() -> String:
	# v-build aynı oyuncu-kapılı döngüyü yaşar: sayaçlar v-commit'te sıfırdan, park →
	# tur → karar → geliştirme.
	_seed_live_product()
	if not ProductSystem.start_version_build(["ai_assistant_voice"], ""):
		return "start_version_build failed"
	var b: FeatureBuild = ProductSystem.get_active_build()
	if b.iteration_count != 1 or b.iteration_decision_pending or b.iteration_round_days > 0.0:
		return "v-commit did not reset the iteration counters"
	if not _drive_to_iter_pending():
		return "v-build design band never pended"
	if b.current_phase != "iteration":
		return "v-build auto-advanced (phase %s)" % b.current_phase
	if not _run_iteration_round():
		return "v-build round did not complete"
	if b.iteration_count != 2:
		return "round did not increment the counter (%d)" % b.iteration_count
	ProductSystem.enter_development()
	if b.current_phase != "development":
		return "v-build exit did not flip to development"
	return ""


static func _case_speed_tracks_team_change() -> String:
	# Hız her saat taze: solo günlük harcama, sonra yazılımcı alınınca artan günlük harcama
	# (ve kısalan ~gün). ÖLÇÜM GELİŞTİRME FAZINDA yapılır.
	#
	# LEDGER (Coupling): the case MOVED phase, the formula did not. Measurement used to sit
	# wherever the build happened to be, which was iteration; a developer contributes NOTHING
	# there, because Tasarım fazı tasarımcı + Ürün Yöneticisi'nin işidir (design doc §5 rol-faz
	# eşlemesi). That is the correct world, not a bug: kod yazılmayan fazda kod eli çalışmaz.
	# So the case now measures in the phase the developer OWNS, and asserts the iteration
	# behaviour explicitly below so the surprise becomes a documented law.
	GameState.set_cash(50000)
	var founder: Character = CharacterRegistry.get_founder()
	if founder == null:
		return "no founder in registry"
	founder.role_stats["tech"] = 3
	if not ProductSystem.start_build("ai_assistant", ["ai_assistant_tools", "ai_assistant_image"], ""):
		return "start_build failed"   # efor 8+8=16 — ölçüm pencereleri içinde bitmez
	var b: FeatureBuild = ProductSystem.get_active_build()
	# A developer must NOT speed up the design phase — the rol-faz mapping, asserted.
	var iter_speed_solo: float = ProductSystem.team_speed(b)
	if b.current_phase != "iteration":
		return "build did not start in the design phase (%s)" % b.current_phase
	_make_employee("char_iter_dev", "Iter Dev", HRConstants.ROLE_DEVELOPER)
	if absf(ProductSystem.team_speed(b) - iter_speed_solo) > 0.001:
		return "a developer changed TASARIM-phase speed (%.3f -> %.3f); that phase belongs to the designer" % [
			iter_speed_solo, ProductSystem.team_speed(b)]
	CharacterRegistry.remove("char_iter_dev")
	# Now push into GELİŞTİRME, the phase a developer owns, and measure there.
	if not _run_build_to_phase("development"):
		return "build never reached the development phase"
	# LEDGER (Coupling): the expectation SHAPE changed, the NUMBER did not. Founder tech-3 solo
	# was 1.0 x 3 = 3.0 under the old lead-weight law; now it is FOUNDER_SPEED_COEF x 3 x
	# coordination(Liderlik 0) = 3.0 x 1.0. Held by anchor a2.
	var want_solo: float = maxf(ProductSystem.SPEED_MIN,
		ProductSystem.FOUNDER_SPEED_COEF * 3.0
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
	# = 4.0. New = (FOUNDER_SPEED_COEF x 3 + EMPLOYEE_SPEED_COEF x pace 4) x coordination = 4.0.
	# Same number, derived from the new law — anchor b1. No lead/assist split any more.
	var want_team: float = maxf(ProductSystem.SPEED_MIN,
		(ProductSystem.FOUNDER_SPEED_COEF * 3.0
			+ ProductSystem.EMPLOYEE_SPEED_COEF * float(SEED_PACE))
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


# --- Package 5: two-runway model + localization cases ---

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
	p.industry = "Testing"
	p.archetype = "small"
	SalesSystem.add_b2b_customer(p, 1000, 70)   # coexisting B2B account
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
	p.industry = "Sigorta"
	p.archetype = "small"
	p.pain_feature_id = "ai_vec_filter"
	var c: Customer = SalesSystem.add_b2b_customer(p, mrr, 70)
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
	if _instances_of("ev_b2b_retain_co_lead_smoke") != 0:
		return "retention event fired for a healthy account (never should)"

	# Söz ver → creates a promise, customer recovers, reputation up.
	var c1: Customer = _add_risk_b2b("ra", 1000)
	var rep0: int = GameState.reputation
	EventManager.enqueue(B2BEventFactory.build_retention(c1))
	if EventManager._active_event_id != "ev_b2b_retain_co_ra":
		return "retention event not active (%s)" % EventManager._active_event_id
	EventManager.resolve_choice("ev_b2b_retain_co_ra", 0)
	if PromiseRegistry.get_open_for("co_ra").size() != 1:
		return "Söz ver did not create a promise"
	if c1.lifecycle_phase == "risk":
		return "Söz ver did not recover the account"
	if GameState.reputation != rep0 + B2BConstants.RETAIN_PROMISE_REP:
		return "Söz ver reputation delta wrong"

	# Oyala → extends the countdown once, counts a stall, brand down.
	var c2: Customer = _add_risk_b2b("rb", 1000)
	var cd0: int = c2.churn_countdown
	var brand0: int = GameState.brand
	EventManager.enqueue(B2BEventFactory.build_retention(c2))
	EventManager.resolve_choice("ev_b2b_retain_co_rb", 1)
	if c2.churn_countdown != cd0 + B2BConstants.RETAIN_DELAY_DAYS:
		return "Oyala did not extend the countdown (%d -> %d)" % [cd0, c2.churn_countdown]
	if c2.retain_stalls != 1:
		return "Oyala did not count a stall"
	if GameState.brand != brand0 + B2BConstants.RETAIN_DELAY_BRAND:
		return "Oyala brand delta wrong"

	# İndirim ver → MRR drops (bridged), customer recovers, reputation down.
	var c3: Customer = _add_risk_b2b("rc", 1000)
	var mrr0: int = c3.mrr
	var rep0b: int = GameState.reputation
	EventManager.enqueue(B2BEventFactory.build_retention(c3))
	EventManager.resolve_choice("ev_b2b_retain_co_rc", 2)
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
	EventManager.enqueue(B2BEventFactory.build_retention(c4))
	EventManager.resolve_choice("ev_b2b_retain_co_rd", 3)
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
	EventManager.enqueue(B2BEventFactory.build_retention(c))
	EventManager.resolve_choice("ev_b2b_retain_co_ic", 3)  # "Kendi haline bırak"
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
	EventManager.enqueue(B2BEventFactory.build_retention(r))
	EventManager.resolve_choice("ev_b2b_retain_co_ir", 3)  # ignore
	if CustomerRegistry.get_customer("co_ir") == null:
		return "rescue target churned on ignore"
	EventManager.enqueue(B2BEventFactory.build_retention(r))  # reopen İlgilen
	EventManager.resolve_choice("ev_b2b_retain_co_ir", 0)     # Söz ver → recover
	if r.lifecycle_phase == "risk":
		return "İlgilen → Söz ver did not rescue after an earlier ignore"
	return ""


# --- B2B pitch → MeetingScene migration (view-only, outcome-invariant) ---

static func _case_b2b_pitch_meeting_signs() -> String:
	# The B2BPitchMeeting view-adapter drives the UNCHANGED PitchSystem to the same SIGNED
	# outcome the retired modal produced — round-trip parity through advance().
	GameState.set_flag("mvp_shipped", true)
	GameState.set_flag("mvp_market_type", "b2b")
	GameState.set_flag("mvp_sub_product_type_id", "ai_vector_search")
	_force("pass")  # deterministic skill checks → SIGNED
	var p: Prospect = PitchSystem.spawn_prospect("small", "find")
	var before: int = CustomerRegistry.get_by_market("b2b").size()
	B2BPitchMeeting.begin_meeting(p.id)
	if not B2BPitchMeeting.is_active():
		return "adapter not active after begin_meeting"
	B2BPitchMeeting.advance("c0")  # intro
	B2BPitchMeeting.advance("c0")  # value (skill check)
	B2BPitchMeeting.advance("c1")  # pricing (fair)
	var rc: Dictionary = B2BPitchMeeting.advance("c0")  # close → result screen
	if rc.get("done", true):
		return "close should show a result screen, not close immediately"
	if String(rc.get("view_state", {}).get("beat_label", "")) != "İMZA":
		return "expected SIGNED (İMZA), got %s" % String(rc.get("view_state", {}).get("beat_label", ""))
	var rd: Dictionary = B2BPitchMeeting.advance("done")  # Devam → close
	if not rd.get("done", false):
		return "Devam did not close the meeting"
	if B2BPitchMeeting.is_active():
		return "adapter still active after close"
	if CustomerRegistry.get_by_market("b2b").size() != before + 1:
		return "SIGNED did not create a customer"
	if ProspectRegistry.get_prospect(p.id) != null:
		return "SIGNED did not remove the prospect"
	return ""


static func _case_b2b_rep_portrait_rotation() -> String:
	# Rep portrait: sequential over the NON-selected founder pool, no consecutive repeat,
	# player's own excluded, persisted per-prospect (survives a re-meeting).
	GameState.initialize_run({})
	GameState.founder_portrait = "founder_03"  # the player's — must be excluded
	GameState.set_flag("mvp_market_type", "b2b")
	GameState.set_flag("mvp_sub_product_type_id", "ai_vector_search")
	var assigned: Array = []
	var prospects: Array = []
	for i in 6:
		var p: Prospect = PitchSystem.spawn_prospect("small", "find")
		prospects.append(p)
		var rep: String = B2BPitchMeeting._assign_rep(p)
		if rep == "founder_03":
			return "assigned the player's own portrait"
		if not assigned.is_empty() and String(assigned[assigned.size() - 1]) == rep:
			return "consecutive repeat: %s" % rep
		if p.rep_portrait_id != rep:
			return "rep not persisted on the prospect"
		assigned.append(rep)
	# Re-meeting the SAME prospect returns the SAME face.
	var again: String = B2BPitchMeeting._assign_rep(prospects[0])
	if again != String(assigned[0]):
		return "re-meeting did not reuse the persisted portrait (%s vs %s)" % [again, str(assigned[0])]
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
	for i in 6:
		var p: Prospect = PitchSystem.spawn_prospect("small", "find")
		if p.pain_feature_id == "":
			return "prospect %d has empty pain_feature_id" % i
		if not pool_ids.has(p.pain_feature_id):
			return "pain_feature_id %s not in the product pool" % p.pain_feature_id
		if p.need_summary == "":
			return "prospect %d need_summary empty" % i
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
	cs.role_stats = {"expertise": expertise, "pace": SEED_PACE, "rapport": SEED_RAPPORT}
	cs.traits = ["warms_up_fast"]
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
	p.industry = "Sigorta"
	p.archetype = "small"
	p.pain_feature_id = "ai_vec_filter"
	var cs_mgd: Customer = SalesSystem.add_b2b_customer(p, 1000, 70)
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
	if _instances_of("ev_b2b_retain_%s" % cs_mgd.id) != 0:
		return "CS-managed produced a routine retention event"
	if _instances_of("ev_b2b_escalation_%s" % cs_mgd.id) != 0:
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
	p.industry = "Sigorta"
	p.archetype = "small"
	p.pain_feature_id = "ai_vec_filter"
	var c: Customer = SalesSystem.add_b2b_customer(p, 2000, 70)
	CustomerRegistry.assign_customer(c.id, cs.id)
	CustomerRegistry.set_satisfaction(c.id, 20)  # below the critical threshold
	GameState.advance_day()
	B2BSalesSystem.daily_tick()  # escalation fires
	var esc_id: String = "ev_b2b_escalation_%s" % c.id
	if EventManager._active_event_id != esc_id:
		return "escalation not active (%s)" % EventManager._active_event_id
	var brand0: int = GameState.brand
	var lost0: int = GameState.run_customers_lost
	var morale0: int = cs.morale
	EventManager.resolve_choice(esc_id, 1)  # "Hayır, yapmıyoruz"
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
	B2BSalesSystem.expand(c.id, 5, 120)
	EventBus.customer_expanded.disconnect(cb)
	if c.seats != seats0 + 5:
		return "seats did not grow (%d -> %d)" % [seats0, c.seats]
	if c.mrr != mrr0 + 5 * 120:
		return "mrr not priced off added seats (%d -> %d)" % [mrr0, c.mrr]
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
	# spent that account's one expansion moment, and since K2 the engine remembers it. The
	# re-seed only ever looked like a fresh start because expansion had no memory at all.
	GameState.set_flag("mvp_sub_product_type_id", "ai_vector_search")
	var pm := Prospect.new()
	pm.id = "lead_mature"
	pm.company_name = "Mature A.Ş."
	pm.industry = "Testing"
	pm.archetype = "small"
	SalesSystem.add_b2b_customer(pm, 1000, 70)
	var m: Customer = CustomerRegistry.get_customer("co_lead_mature")
	if m == null:
		return "the mature fixture account was not created"
	m.acquired_on_day = GameState.day - (B2BConstants.EXPANSION_MATURE_DAYS + 1)  # mature
	CustomerRegistry.set_lifecycle_phase(m.id, "active")
	CustomerRegistry.set_satisfaction(m.id, 80)  # healthy (>= tolerance)
	var seats_before: int = m.seats
	GameState.advance_day()
	B2BSalesSystem.daily_tick()
	var eid: String = "ev_b2b_expand_%s" % m.id
	if EventManager._active_event_id != eid:
		return "expansion event not auto-enqueued for mature account (%s)" % EventManager._active_event_id
	EventManager.resolve_choice(eid, 0)  # "Büyüt"
	if m.seats <= seats_before:
		return "event-driven expansion did not grow seats"
	return ""


static func _case_build_percent_single_source() -> String:
	# S2-8. The same build printed different percentages in one frame: the portfolio badge
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


static func _case_runway_days_and_negative_cash() -> String:
	# S2-9 + S2-10, both of which live in net_runway_parts and only there.
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
#  Frank's angel round (Playable Run Sprint 2026-08-17)
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
	if GameState.get_flag(AngelRoundSystem.FLAG_OFFERED, false):
		return "the offer opened below the bar (MRR %d)" % GameState.mrr

	# Cross BOTH bars in one day: the 2,500 seed bar and the 5,000 Series A gate. Brand
	# starts at 50, so gate 2's brand condition is already satisfied.
	CustomerRegistry.set_mrr(c.id, 6000)
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

	if not GameState.get_flag(AngelRoundSystem.FLAG_OFFERED, false):
		return "the offer never opened at MRR %d" % GameState.mrr
	if _instances_of(AngelRoundSystem.EVENT_ID) != 1:
		return "expected exactly one seed scene, found %d" % _instances_of(AngelRoundSystem.EVENT_ID)

	# ORDERING GUARD (do not drain before reading this). enqueue_front does NOT simply mean
	# "front": it ends in _pump_queue, which mounts immediately when nothing is active. So
	# with an EMPTY queue the FIRST caller owns the screen and later ones stack behind it,
	# while with a modal already up the LAST caller pushes to the head of the queue. Slot
	# order therefore only decides the reading order in the empty-queue case — which is the
	# case this asserts, and the reason AngelRoundSystem sits at slot 8a, one line ahead of
	# PhaseGateSystem: the money should land before "you're ready for Series A".
	var seed_at: int = _queue_position_of(AngelRoundSystem.EVENT_ID)
	var gate_at: int = _queue_position_of(GATE2_ID)
	if gate_at < 0:
		return "fixture: the Series A gate did not open at MRR %d / brand %d" % [GameState.mrr, GameState.brand]
	if seed_at > gate_at:
		return "the phase gate is ahead of the seed scene (seed %d, gate %d)" % [seed_at, gate_at]
	return ""


# Answer every modal currently pending (always choice 0), so a case can reach a known
# empty-queue state. Bounded: a queue that will not drain is itself the finding.
static func _drain_all_modals() -> void:
	for i in 32:
		if EventManager._active_event_id == "":
			return
		EventManager.resolve_choice(EventManager._active_event_id, 0)


# Where an id sits in the player's reading order: 0 = the modal on screen now, 1.. = the
# queue behind it, −1 = not pending.
static func _queue_position_of(event_id: String) -> int:
	if EventManager._active_event_id == event_id:
		return 0
	for i in EventManager._queue.size():
		if EventManager._queue[i].id == event_id:
			return i + 1
	return -1


static func _case_angel_never_pre_ship() -> String:
	# Money without a product is not the beat. The guard under test is exactly the one the
	# seeder would otherwise satisfy, so it is cleared after seeding, on purpose.
	var c: Customer = _seed_angel_world(AngelRoundSystem.MRR_THRESHOLD * 2)
	if c == null:
		return "fixture: no customer"
	GameState.set_flag("mvp_shipped", false)
	for i in 3:
		_sim_day_full()
	if GameState.get_flag(AngelRoundSystem.FLAG_OFFERED, false):
		return "the offer opened with no shipped product"
	if _instances_of(AngelRoundSystem.EVENT_ID) != 0:
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
	if GameState.get_flag(AngelRoundSystem.FLAG_OFFERED, false):
		return "the offer opened one dollar under the bar (MRR %d)" % GameState.mrr
	# Over the line, through CustomerRegistry + the MRR bridge (a bare set_mrr would be
	# clobbered by SalesSystem._mrr_bridge on the next tick).
	CustomerRegistry.set_mrr(c.id, AngelRoundSystem.MRR_THRESHOLD)
	SalesSystem.reflect_mrr()
	_sim_day_full()
	if not GameState.get_flag(AngelRoundSystem.FLAG_OFFERED, false):
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
	if not _drain_to(AngelRoundSystem.EVENT_ID):
		return "the seed scene never became active"
	# Baselines taken AFTER the day has settled: _sim_day_full runs the finance slot, which
	# applies the day's net flow, so a pre-tick snapshot would be off by exactly that net
	# and the case would be measuring the burn model rather than the round.
	var cash0: int = GameState.cash
	var tx0: int = FinanceSystem.get_transactions().size()
	EventBus.cash_changed.connect(probe)
	EventManager.resolve_choice(AngelRoundSystem.EVENT_ID, 0)   # KABUL
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
	var ev: GameEvent = AngelRoundSystem.build_offer_event()
	if ev.choices.size() != 2:
		return "the seed scene has %d choices, wanted 2" % ev.choices.size()
	var refuse: EventChoice = ev.choices[1]
	# The SAME call the modal makes (event_modal.gd:330), not a mirror of it.
	if EventManager.is_condition_met(refuse.unlock_condition):
		return "the hard-mode choice is unlocked"
	if refuse.unlock_reason_text == "":
		return "the locked choice carries no telegraph text"
	if not refuse.modifiers.is_empty():
		return "the locked choice carries modifiers — the lock is the only thing stopping them"
	# FALSIFY THE LOCK: it must be a live predicate over one named key, not a constant.
	GameState.set_flag(AngelRoundSystem.HARD_MODE_FLAG, true)
	if not EventManager.is_condition_met(refuse.unlock_condition):
		return "the lock did not open when hard_mode_unlocked was set — it is not a real condition"
	GameState.set_flag(AngelRoundSystem.HARD_MODE_FLAG, false)
	if EventManager.is_condition_met(refuse.unlock_condition):
		return "flag_equals matched a false value — the gate is flag_set, not flag_equals"
	return ""


static func _case_angel_one_shot_falsified() -> String:
	# Once, ever — and the second half proves the LATCH is what makes it so, rather than
	# some unrelated dedupe doing the work (or the feature simply never firing twice).
	var c: Customer = _seed_angel_world(AngelRoundSystem.MRR_THRESHOLD)
	if c == null:
		return "fixture: no customer"
	_sim_day_full()
	if not _drain_to(AngelRoundSystem.EVENT_ID):
		return "the seed scene never became active"
	EventManager.resolve_choice(AngelRoundSystem.EVENT_ID, 0)
	# Ten more days INCLUDING a genuine re-crossing: down under the bar, then back over.
	for i in 10:
		if i == 3:
			CustomerRegistry.set_mrr(c.id, AngelRoundSystem.MRR_THRESHOLD - 900)
			SalesSystem.reflect_mrr()
		if i == 6:
			CustomerRegistry.set_mrr(c.id, AngelRoundSystem.MRR_THRESHOLD + 2000)
			SalesSystem.reflect_mrr()
		_sim_day_full()
		if _instances_of(AngelRoundSystem.EVENT_ID) != 0:
			return "the seed scene re-opened on day %d" % GameState.day
	if GameState.run_angel_equity_pct != AngelRoundSystem.EQUITY_PCT:
		return "equity compounded to %d%%" % GameState.run_angel_equity_pct
	var paid: int = 0
	for row in FinanceSystem.get_transactions():
		if String(row.get("label", "")) == AngelRoundSystem.TX_LABEL:
			paid += 1
	if paid != 1:
		return "the treasury took the cheque %d times" % paid
	# THE FALSIFICATION: clear the latch by hand and the offer MUST come back. Without
	# this half the case would pass just as happily against an engine where the beat never
	# fires at all, or where something other than the flag is doing the suppressing.
	GameState.set_flag(AngelRoundSystem.FLAG_OFFERED, false)
	_sim_day_full()
	if _instances_of(AngelRoundSystem.EVENT_ID) != 1:
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
	if not _drain_to(AngelRoundSystem.EVENT_ID):
		return "the seed scene never became active"
	EventManager.resolve_choice(AngelRoundSystem.EVENT_ID, 0)
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
	if not _drain_to(AngelRoundSystem.EVENT_ID):
		return "the seed scene never became active"
	EventManager.resolve_choice(AngelRoundSystem.EVENT_ID, 0)
	if HRSystem.attention_count() != badge0 + 1:
		return "the HR badge did not light after the seed (%d -> %d)" % [badge0, HRSystem.attention_count()]
	# Too early: the day after acceptance is inside the delay.
	_sim_day_full()
	if _instances_of(AngelRoundSystem.NUDGE_EVENT_ID) != 0:
		return "the nudge fired before its delay elapsed"
	for i in AngelRoundSystem.NUDGE_DELAY_DAYS:
		_sim_day_full()
	if not _drain_to(AngelRoundSystem.NUDGE_EVENT_ID):
		return "the hire nudge never arrived"
	EventManager.resolve_choice(AngelRoundSystem.NUDGE_EVENT_ID, 0)
	# Advisory only: nothing economic may have moved.
	if GameState.run_angel_equity_pct != AngelRoundSystem.EQUITY_PCT:
		return "the nudge moved equity"
	for i in 6:
		_sim_day_full()
		if _instances_of(AngelRoundSystem.NUDGE_EVENT_ID) != 0:
			return "the nudge repeated on day %d" % GameState.day
	# Hiring clears the badge — the signpost is self-retiring, not a standing demand.
	_make_employee("emp_nudge_hire", "İlk Çalışan", HRConstants.ROLE_DEVELOPER)
	if HRSystem.attention_count() != badge0:
		return "the HR badge survived the hire (%d, wanted %d)" % [HRSystem.attention_count(), badge0]
	return ""


static func _case_promise_no_duplicate_word() -> String:
	# Playable Run Sprint. A word already given may not be given again: while a promise to
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
	var first: GameEvent = B2BEventFactory.build_retention(c)
	if _promise_row_index(first) < 0:
		return "the retention card offered no promise row with nothing outstanding"

	# Give the word once, through the real modifier seam.
	B2BSalesSystem.accept_promise(c.id, c.pain_feature_id, B2BConstants.PROMISE_DEADLINE_DAYS)
	if not PromiseRegistry.has_open_for(c.id):
		return "accept_promise did not open a promise"

	# Now every card that could mint a second debt must withhold it.
	var again: GameEvent = B2BEventFactory.build_retention(c)
	if _promise_row_index(again) >= 0:
		return "the retention card offered a SECOND word while one was still open"
	if again.choices.is_empty():
		return "withholding the promise row emptied the card — the player would be stuck"
	var req: GameEvent = B2BEventFactory.build_cs_request(c, _make_employee(
		"emp_cs_dup", "Dup CS", HRConstants.ROLE_CUSTOMER_REP))
	if _promise_row_index(req) >= 0:
		return "the CS request card offered a SECOND word while one was still open"

	# Control: once the debt is settled, the card offers a word again — the gate is the
	# OPEN promise, not a permanent ban.
	for p in PromiseRegistry.get_open_for(c.id):
		p.status = "broken"
	if PromiseRegistry.has_open_for(c.id):
		return "fixture: the promise did not close"
	c.pain_feature_id = "saas_ops_field"   # a still-unshipped feature
	if _promise_row_index(B2BEventFactory.build_retention(c)) < 0:
		return "the promise row never came back after the debt closed"
	return ""


# Index of the row that would MINT A NEW PROMISE, found by modifier type rather than by
# label (labels are player-facing text) or position (the rows are conditional).
static func _promise_row_index(ev: GameEvent) -> int:
	for i in ev.choices.size():
		for m in ev.choices[i].modifiers:
			if String(m.get("type", "")) == "b2b_promise_create":
				return i
	return -1


static func _case_promise_kept_stops_countdown() -> String:
	# Playable Run Sprint. KEEPING the word must stop the churn clock, exactly as GIVING it
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
	# Playable Run Sprint. _recover stamped "active" unconditionally, while _tick_healthy's
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
	p2.industry = "Testing"
	p2.archetype = "small"
	SalesSystem.add_b2b_customer(p2, 900, 70)
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
	# S1-6. A promise used to outlive the account it was made to: tick_deadlines had no
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
	p2.industry = "Testing"
	p2.archetype = "small"
	SalesSystem.add_b2b_customer(p2, 900, 70)
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
	# S2-6. "Running on Fumes" is the demo's conversion screen, and its ledger pool carried
	# ONE unconditioned line — "Gelir vardı, ama…" — while _assemble tops the pool up to
	# MIN_LEDGER_LINES. On a zero-activity run that false line was therefore GUARANTEED to
	# print, directly under a stat cell reading MRR $0.
	# FAILS against the pre-fix engine on the first assertion.
	var claim: String = "Gelir vardı"
	# A run that earned nothing and signed nobody.
	var barren: Dictionary = {
		"phase": 1, "day": 180, "mrr": 0, "customers_signed": 0, "customers_active": 0,
		"hires": 0, "employees": 0, "product_ships": 0,
	}
	var vs: Dictionary = EndingsCopy.build("running_on_fumes", barren, {})
	var lines: Array = vs.get("ledger_lines", []) as Array
	for line in lines:
		if String(line).begins_with(claim):
			return "the zero-revenue run was told revenue existed: '%s'" % String(line)
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
		if String(line).begins_with(claim):
			found = true
	if not found:
		return "an earning run lost the revenue line entirely"
	return ""


static func _case_b2b_expansion_no_refire() -> String:
	# K2 / S1-1. The promotion test is MONOTONE (day - acquired_on_day >= MATURE_DAYS) and
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
	var eid: String = "ev_b2b_expand_%s" % c.id
	GameState.advance_day()
	B2BSalesSystem.daily_tick()
	if EventManager._active_event_id != eid:
		return "expansion never offered (%s)" % EventManager._active_event_id
	EventManager.resolve_choice(eid, 0)   # "Büyüt"
	var mrr_after_upsell: int = c.mrr
	for i in 6:
		GameState.advance_day()
		B2BSalesSystem.daily_tick()
		if EventManager._active_event_id == eid or _instances_of(eid) > 0:
			return "expansion re-fired after ACCEPT (day %d)" % GameState.day
	if c.mrr != mrr_after_upsell:
		return "MRR kept growing after one upsell (%d -> %d)" % [mrr_after_upsell, c.mrr]

	# --- Branch 2: DECLINE, on a second account ---
	var p := Prospect.new()
	p.id = "lead_decliner"
	p.company_name = "Decline A.Ş."
	p.industry = "Testing"
	p.archetype = "small"
	SalesSystem.add_b2b_customer(p, 900, 80)
	var d: Customer = CustomerRegistry.get_customer("co_lead_decliner")
	if d == null:
		return "second account was not created"
	d.acquired_on_day = GameState.day - (B2BConstants.EXPANSION_MATURE_DAYS + 1)
	CustomerRegistry.set_lifecycle_phase(d.id, "active")
	CustomerRegistry.set_satisfaction(d.id, 80)
	var did: String = "ev_b2b_expand_%s" % d.id
	GameState.advance_day()
	B2BSalesSystem.daily_tick()
	if not _drain_to(did):
		return "expansion never offered to the second account"
	EventManager.resolve_choice(did, 1)   # "Şimdilik gerek yok"
	for i in 6:
		GameState.advance_day()
		B2BSalesSystem.daily_tick()
		if EventManager._active_event_id == did or _instances_of(did) > 0:
			return "expansion re-fired after DECLINE (day %d)" % GameState.day
	# The Sales-tab button asks the same gate, so the loop cannot be reopened through the UI.
	if B2BSalesSystem.can_offer_expansion(d):
		return "the manual trigger's gate still reads as offerable after a decision"
	return ""


static func _case_b2b_market_gate_b2c_run() -> String:
	# S1-2. daily_tick's only gate was `mvp_shipped`, so the ENTIRE B2B desk ran inside a
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


static func _case_sales_autoclose_empty_pain() -> String:
	# S1-7. An UNMAPPABLE pain is the conservative case, not the permissive one. This
	# branch returned true, so the §10 concession gate opened widest exactly where the
	# engine knew least — and mvp_components was never consulted at all.
	GameState.set_flag("mvp_sub_product_type_id", "ai_vector_search")
	_seed_b2b(1000)
	GameState.set_flag("mvp_components", ["ai_vec_search_api"])
	var blank: Prospect = _add_prospect("nopain", "small", "")
	if SalesRepSystem.is_auto_closable(blank):
		return "a lead with no mapped pain still reads as auto-closable"
	# Control: a lead whose pain IS shipped stays routine, so the gate did not just close.
	var known: Prospect = _add_prospect("known", "small", "ai_vec_search_api")
	if not SalesRepSystem.is_auto_closable(known):
		return "a lead whose pain is already shipped should still be auto-closable"
	return ""


static func _case_event_queue_dedupe_by_id() -> String:
	# Array.has() on Array[GameEvent] compares REFERENCES, and every factory mints a fresh
	# GameEvent per call, so one id could occupy the queue N times over.
	# FAILS against the pre-fix engine (two instances land).
	_seed_b2b(500)
	var c: Customer = CustomerRegistry.get_customer("co_lead_smoke")
	# Occupy the modal slot, so the two events under test must QUEUE rather than mount —
	# the already-active id was guarded even before this fix; the QUEUE was not.
	EventManager.enqueue(B2BEventFactory.build_retention(c))
	if EventManager._active_event_id == "":
		return "could not occupy the active slot"
	var a: GameEvent = B2BEventFactory.build_expansion(c)
	var b: GameEvent = B2BEventFactory.build_expansion(c)
	if a == b:
		return "the factory returned one instance twice — the case would prove nothing"
	EventManager.enqueue(a)
	EventManager.enqueue(b)
	if _instances_of(a.id) != 1:
		return "one event id entered the pipeline %d times" % _instances_of(a.id)
	return ""


static func _case_b2b_scale_and_sector_gating() -> String:
	# Demo scale gating (1..3 only, 4-5 Tier 2 gated) AND sector affinity: the chosen
	# product yields only sector-appropriate prospects, each with a value RANGE band.
	GameState.set_flag("mvp_shipped", true)
	GameState.set_flag("mvp_market_type", "b2b")
	GameState.set_flag("mvp_sub_product_type_id", "saas_ops")
	var ops_sectors: Array = B2BConstants.sector_pool("saas_ops")
	for i in 8:
		var p: Prospect = PitchSystem.spawn_prospect("small", "find")
		if p.scale < 1 or p.scale > B2BConstants.SCALE_DEMO_MAX:
			return "prospect scale out of demo range: %d" % p.scale
		if not ops_sectors.has(p.industry):
			return "ops prospect industry %s not in sector affinity" % p.industry
		if p.value_band_min <= 0 or p.value_band_max <= p.value_band_min:
			return "prospect value band invalid (%d-%d)" % [p.value_band_min, p.value_band_max]
	# Switching the product switches the sector pool (vector-search → no construction).
	GameState.set_flag("mvp_sub_product_type_id", "ai_vector_search")
	var vec_sectors: Array = B2BConstants.sector_pool("ai_vector_search")
	for i in 5:
		var p2: Prospect = PitchSystem.spawn_prospect("small", "find")
		if not vec_sectors.has(p2.industry):
			return "vector-search prospect industry %s off-affinity" % p2.industry
		if ops_sectors.has(p2.industry) and not vec_sectors.has(p2.industry):
			return "vector-search yielded an ops-only sector: %s" % p2.industry
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
	if EventManager._active_event_id != "":
		EventManager.resolve_choice(EventManager._active_event_id, 0)
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
		if _drain_to("ev_ps_frank_intro_b2b"):
			reached = true
			break
	if not reached:
		return "Frank intro never became active post-ship"
	var n0: int = ProspectRegistry.get_all().size()
	EventManager.resolve_choice("ev_ps_frank_intro_b2b", 0)   # add_prospect (source frank_intro)
	var prospects: Array[Prospect] = ProspectRegistry.get_all()
	if prospects.size() != n0 + 1:
		return "Frank intro produced no prospect (spawn aborted?) %d -> %d" % [n0, prospects.size()]
	var p: Prospect = prospects[prospects.size() - 1]
	if p.value_band_min <= 0 or p.value_band_max <= p.value_band_min:
		return "prospect value band not populated (%d-%d)" % [p.value_band_min, p.value_band_max]
	if not B2BConstants.sector_pool("saas_ops").has(p.industry):
		return "prospect industry %s off saas_ops affinity" % p.industry
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
	if total != FounderConstants.POINT_POOL:
		return "skills sum %d (want %d)" % [total, FounderConstants.POINT_POOL]
	if GameState.get_founder_skill("sales") != 2:
		return "sales=%d (debug payload wants 2)" % GameState.get_founder_skill("sales")
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
	var ok := {"tech": 2, "sales": 2, "negotiation": 1, "leadership": 0, "influence": 1}
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
	# Term Sheet levers read the NEW skill keys; can_read_prospect flips on Satış;
	# the odds-split label resolves through the CSV -> TranslationServer plumbing.
	var want := {"valuation": "sales", "dilution": "negotiation", "board": "influence"}
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
		"skill_alloc": {"tech": 2, "sales": 2, "negotiation": 1, "leadership": 0, "influence": 1},
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
	unspent["skill_alloc"]["influence"] = 0
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
static func _park_leave(employees: Array) -> void:
	var this_month: int = int(GameState.get_date_dict().month)
	for e in employees:
		e.leave_month = ((this_month + 5) % 12) + 1
		e.leave_taken_year = 0


static func _case_hr_axis_key_lock() -> String:
	# Founder and employee key sets must NEVER mix. get_founder_skill returns 0 for an
	# unknown key without complaining, so cross-contamination would otherwise be silent.
	var founder: Character = CharacterRegistry.get_founder()
	if founder == null:
		return "no founder after initialize_run"
	for axis_key in HRConstants.AXES:
		if founder.role_stats.has(axis_key):
			return "founder carries employee axis '%s'" % axis_key
	if HRConstants.validate_employee_axes(founder.role_stats):
		return "the FOUNDER dict passed the EMPLOYEE axis validator"
	var emp: Character = _make_employee("char_lock_emp", "Lock Emp", HRConstants.ROLE_DEVELOPER)
	for skill_key in FounderConstants.SKILLS:
		if emp.role_stats.has(skill_key):
			return "employee carries founder skill '%s'" % skill_key
	if not HRConstants.validate_employee_axes(emp.role_stats):
		return "employee axes failed their own validator: %s" % str(emp.role_stats)
	if emp.role_stats.size() != HRConstants.AXES.size():
		return "employee role_stats holds %d keys, want exactly %d" % [emp.role_stats.size(), HRConstants.AXES.size()]
	# Every near-miss shape must be rejected, not just obvious garbage.
	if HRConstants.validate_employee_axes({"expertise": 5, "pace": 5}):
		return "a missing axis was accepted"
	if HRConstants.validate_employee_axes({"expertise": 5, "pace": 5, "rapport": 5, "tech": 2}):
		return "an extra founder key was accepted"
	if HRConstants.validate_employee_axes({"expertise": 5, "pace": HRConstants.AXIS_MAX + 1, "rapport": 5}):
		return "an off-ruler value was accepted"
	# Employee traits use their OWN catalog and formula, not the founder's.
	if HRConstants.validate_employee_traits(["visionary"]):
		return "a FOUNDER trait id passed the employee trait validator"
	return ""


static func _case_hr_candidate_invariants() -> String:
	# THE heart of the mechanic: the moment one dominant file can appear, "which do I need"
	# collapses into "just buy the best one". Asserted over 100+ generations across every
	# role and band (quotes are seed-independent — salary is a pure function of role/band/
	# profile — so all 18 role×band windows are covered exhaustively). Shape-agnostic on
	# the NUMBERS, but two design invariants are pinned: pairwise non-dominance (price
	# included) and pairwise-DISTINCT salary quotes — the mixed BAND_SHAPE profiles exist
	# precisely so price is a live lever.
	var generations: int = 0
	for role_id in HRConstants.EMPLOYEE_ROLES:
		for band_id in HRConstants.BANDS:
			for s in 6:
				var seed_value: int = 1000 + s * 7919 + generations * 31
				var files: Array = HRCandidateGenerator.generate(role_id, band_id, seed_value)
				generations += 1
				var tag: String = "%s/%s seed %d" % [role_id, band_id, seed_value]
				if files.size() != HRConstants.CANDIDATE_COUNT:
					return "%s: %d files, want %d" % [tag, files.size(), HRConstants.CANDIDATE_COUNT]
				var band: Array = HRConstants.salary_band(role_id, band_id)
				var lo: int = 1 << 30
				var hi: int = 0
				var seen_traits: Array = []
				var seen_names: Array = []
				var seen_notes: Array = []
				var seen_salaries: Array = []
				for f in files:
					var sal: int = int(f["salary"])
					if sal < int(band[0]) or sal > int(band[1]):
						return "%s: salary %d outside band %s" % [tag, sal, str(band)]
					lo = mini(lo, sal)
					hi = maxi(hi, sal)
					# Fiyat bir kaldıraç: üç dosya üç AYRI rakam ister (BAND_SHAPE karma
					# profilleri — kesin artan toplamlar). İki dosya aynı rakama yuvarlanırsa
					# gap kuralı delinmiştir (_shape_premium'daki aritmetik notu).
					if seen_salaries.has(sal):
						return "%s: two files quote the same salary %d — the price axis collapsed" % [tag, sal]
					seen_salaries.append(sal)
					if not HRConstants.validate_employee_axes(f["axes"]):
						return "%s: axes off the ruler: %s" % [tag, str(f["axes"])]
					if not HRConstants.validate_employee_traits(f["traits"]):
						return "%s: traits break the employee formula: %s" % [tag, str(f["traits"])]
					if String(f["role"]) != role_id:
						return "%s: role mismatch (%s)" % [tag, String(f["role"])]
					if String(f["name"]).strip_edges() == "" or String(f["note"]).strip_edges() == "":
						return "%s: empty name or file note" % tag
					# Batch no-repeat across every drawn pool, not just traits: two identical
					# names or the same file note twice reads as a generator bug on the card.
					if seen_names.has(String(f["name"])):
						return "%s: candidate name '%s' repeated across files" % [tag, String(f["name"])]
					seen_names.append(String(f["name"]))
					if seen_notes.has(String(f["note"])):
						return "%s: file note repeated across files" % tag
					seen_notes.append(String(f["note"]))
					# Cross-distribution: no trait id repeats across the three files.
					for t in f["traits"]:
						if seen_traits.has(String(t)):
							return "%s: trait '%s' repeated across files" % [tag, String(t)]
						seen_traits.append(String(t))
				if float(hi) / float(maxi(lo, 1)) - 1.0 > HRConstants.SALARY_SPREAD_MAX + 0.0001:
					return "%s: salary spread %.3f exceeds %.2f (%d..%d)" % [
						tag, float(hi) / float(maxi(lo, 1)) - 1.0, HRConstants.SALARY_SPREAD_MAX, lo, hi]
				# Salaries sit in a CONTIGUOUS window, not merely somewhere inside the band:
				# the design wants three quotes that read as the same tier ("maaşlar birbirine
				# yakındır"), which band containment alone does not promise.
				var window_mid: float = float(lo + hi) / 2.0
				var band_mid: float = float(int(band[0]) + int(band[1])) / 2.0
				var band_span: float = float(int(band[1]) - int(band[0]))
				if band_span > 0.0 and absf(window_mid - band_mid) > band_span / 2.0:
					return "%s: the quote window (%d..%d) is not inside the band %s" % [tag, lo, hi, str(band)]
				if not HRCandidateGenerator.is_non_dominated_set(files):
					return "%s: one file DOMINATES another" % tag
				# Same seed, byte-identical files — no RNG anywhere in the generator.
				if str(HRCandidateGenerator.generate(role_id, band_id, seed_value)) != str(files):
					return "%s: generator is not deterministic" % tag
	if generations < 100:
		return "only %d generations exercised, want at least 100" % generations
	# Negative control: without this the whole case would pass on a `return true` predicate.
	var dominant: Array = [
		{"axes": {"expertise": 9, "pace": 9, "rapport": 9}, "salary": 5000},
		{"axes": {"expertise": 4, "pace": 4, "rapport": 4}, "salary": 6000},
	]
	if HRCandidateGenerator.is_non_dominated_set(dominant):
		return "is_non_dominated_set accepted a strictly dominant, cheaper file — the predicate is vacuous"
	return ""


static func _case_hr_search_cycle() -> String:
	# Retainer once, files in 2-4 days with NO modal, commission once, employee active the
	# next day, salary in burn, hires_total +1.
	GameState.set_cash(100000)
	if not HRSearchSystem.can_start():
		return "cannot start a search from idle"
	var cash0: int = GameState.cash
	if not HRSearchSystem.start_search(HRConstants.ROLE_DEVELOPER, HRConstants.BAND_MID):
		return "start_search refused"
	if GameState.cash != cash0 - HRConstants.SEARCH_RETAINER:
		return "retainer not charged exactly once (%d -> %d)" % [cash0, GameState.cash]
	if HRSearchSystem.get_state() != HRConstants.SEARCH_SEARCHING:
		return "state is '%s', want '%s'" % [HRSearchSystem.get_state(), HRConstants.SEARCH_SEARCHING]
	if HRSearchSystem.can_start():
		return "a second search may start while one is already active"
	var arrived_on: int = -1
	for i in HRConstants.SEARCH_ARRIVAL_MAX_DAYS + 3:
		_sim_day()
		if HRSearchSystem.has_files_ready():
			arrived_on = i + 1
			break
	if arrived_on < HRConstants.SEARCH_ARRIVAL_MIN_DAYS or arrived_on > HRConstants.SEARCH_ARRIVAL_MAX_DAYS:
		return "files arrived on day %d, want %d-%d" % [
			arrived_on, HRConstants.SEARCH_ARRIVAL_MIN_DAYS, HRConstants.SEARCH_ARRIVAL_MAX_DAYS]
	# Arrival is a badge and a ticker line, never an interruption.
	if EventManager._active_event_id.begins_with("ev_hr_"):
		return "candidate arrival opened a modal (%s)" % EventManager._active_event_id
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
	if hired.leave_month < 1 or hired.leave_month > 12:
		return "leave_month not assigned at hire (%d)" % hired.leave_month
	if not HRConstants.is_employee_role(hired.role):
		return "hired with a non-employee role '%s'" % hired.role
	if HRSearchSystem.get_state() != HRConstants.SEARCH_IDLE:
		return "the search did not close after the hire"
	FinanceSystem.daily_tick()
	if int(FinanceSystem.get_burn_breakdown().get("salaries", 0)) != int(round(float(salary) / float(GameState.DAYS_PER_MONTH))):
		return "the new hire's salary is not in the burn breakdown"
	return ""


static func _case_hr_search_cancel_dismiss() -> String:
	# Cancelling burns the retainer; dismissing all files closes the search for free.
	# The second leg hires a Satış Uzmanı, and that role is locked outside a B2B market
	# (HRConstants.role_lock_reason_key) — the market flag alone opens it. Deliberately NOT
	# _seed_b2b(): this case is about the search state machine, and a live account would
	# drag the B2B daily chain through the arrival loop below.
	GameState.set_cash(100000)
	GameState.set_flag("mvp_market_type", "b2b")
	var c0: int = GameState.cash
	if not HRSearchSystem.start_search(HRConstants.ROLE_TESTER, HRConstants.BAND_JUNIOR):
		return "start_search refused"
	if not HRSearchSystem.cancel_search():
		return "cancel refused"
	if GameState.cash != c0 - HRConstants.SEARCH_RETAINER:
		return "cancel refunded the retainer (%d -> %d)" % [c0, GameState.cash]
	if HRSearchSystem.get_state() != HRConstants.SEARCH_IDLE:
		return "cancel did not return to idle"
	if not HRSearchSystem.start_search(HRConstants.ROLE_SALES_REP, HRConstants.BAND_SENIOR):
		return "could not start a second search after cancelling"
	for i in HRConstants.SEARCH_ARRIVAL_MAX_DAYS + 3:
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
	# is gone, and NO severance was paid (an unplanned loss, design doc §6).
	GameState.set_cash(100000)
	GameState.set_flag("debug_hr_force", "pass")   # deterministic roll
	var e: Character = _make_employee("char_quit", "Quit Guy", HRConstants.ROLE_DEVELOPER, SEED_PACE, 7000, 70)
	_park_leave([e])
	CharacterRegistry.set_morale(e.id, HRConstants.MORALE_FLIGHT_RISK - 5)
	var dep0: int = GameState.run_departures
	var resign_id: String = "ev_hr_resign_%s" % e.id
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
	EventManager.resolve_choice(resign_id, 0)
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
	e.leave_month = int(GameState.get_date_dict().month)   # force: this month
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


static func _case_hr_morale_no_drift() -> String:
	# The autonomous drift is DELETED, not tuned to zero. A day with no event, no overtime,
	# no overload and no action must not move morale by a single point — in either direction,
	# and at any starting value.
	GameState.set_flag("debug_hr_force", "fail")   # no resignation roll may fire
	var a: Character = _make_employee("char_drift_a", "Drift A", HRConstants.ROLE_DEVELOPER, SEED_PACE, 0, 20)
	var b: Character = _make_employee("char_drift_b", "Drift B", HRConstants.ROLE_TESTER, SEED_PACE, 0, 90)
	var c: Character = _make_employee("char_drift_c", "Drift C", HRConstants.ROLE_DESIGNER, SEED_PACE, 0, 50)
	_park_leave([a, b, c])
	var before: Array = [a.morale, b.morale, c.morale]
	for i in 12:
		_sim_day()
	var after: Array = [a.morale, b.morale, c.morale]
	if after != before:
		return "morale moved with no played cause: %s -> %s" % [str(before), str(after)]
	# If a positive event had fired it would explain the (absent) movement — make that a
	# distinct failure rather than a confusing pass.
	if _instances_of("ev_hr_calm_stretch") + _instances_of("ev_hr_ship_glow") + _instances_of("ev_hr_big_signing") > 0:
		return "a positive morale event fired inside the no-drift window"
	return ""


static func _case_hr_positive_recovery() -> String:
	# Morale never self-heals, so the loop must be BIDIRECTIONAL or the demo is broken:
	# at least one placeholder positive event has to raise team morale.
	var a: Character = _make_employee("char_pos_a", "Pos A", HRConstants.ROLE_DEVELOPER, SEED_PACE, 0, 45)
	var b: Character = _make_employee("char_pos_b", "Pos B", HRConstants.ROLE_TESTER, SEED_PACE, 0, 45)
	_park_leave([a, b])
	# A long stretch with no overtime is one of the design's named recovery triggers. No stamp is
	# forced: a team that has never worked a late night genuinely HAS had a quiet stretch, and it
	# must be able to reach the only recovery channel that needs no player action at all.
	if HRMoraleSystem.average_morale() > float(HRConstants.CALM_STRETCH_MAX_MORALE):
		return "test setup wrong: the team is already too happy to trigger recovery"
	var m0: int = a.morale
	var fired: String = ""
	for i in HRConstants.CALM_STRETCH_DAYS + 4:
		_sim_day()
		if _instances_of("ev_hr_calm_stretch") >= 1:
			fired = "ev_hr_calm_stretch"
			break
	if HRMoraleSystem.days_since_last_overtime() < HRConstants.CALM_STRETCH_DAYS:
		return "days_since_last_overtime reads %d after %d quiet days" % [
			HRMoraleSystem.days_since_last_overtime(), HRConstants.CALM_STRETCH_DAYS]
	if fired == "":
		return "no positive morale event fired on a %d-day calm stretch" % HRConstants.CALM_STRETCH_DAYS
	if not _drain_to(fired):
		return "could not bring the positive event to the front"
	EventManager.resolve_choice(fired, 0)
	if a.morale <= m0 or b.morale <= m0:
		return "the positive event did not raise team morale (%d -> %d / %d)" % [m0, a.morale, b.morale]
	return ""


static func _case_hr_overtime_cost_tiers() -> String:
	# Pay accrues per PARTICIPATING employee per day with the founder free, and the morale
	# cost follows the 1-3 / 4-7 / 8+ tiers exactly.
	GameState.set_cash(200000)
	var a: Character = _make_employee("char_ot_a", "OT A", HRConstants.ROLE_DEVELOPER, SEED_PACE, 9000, 100)
	var b: Character = _make_employee("char_ot_b", "OT B", HRConstants.ROLE_TESTER, SEED_PACE, 6000, 100)
	var away: Character = _make_employee("char_ot_sales", "OT Sales", HRConstants.ROLE_SALES_REP, SEED_PACE, 7000, 100)
	_park_leave([a, b, away])
	if not HROvertimeSystem.start(HRConstants.DEPT_PRODUCT_DEV, 14):
		return "overtime block refused"
	var ids: Array = []
	for p in HROvertimeSystem.participants(HRConstants.DEPT_PRODUCT_DEV):
		ids.append(p.id)
	if ids.has(away.id):
		return "a sales rep participated in a product_dev block"
	if not (ids.has(a.id) and ids.has(b.id)):
		return "product_dev members missing from participants: %s" % str(ids)
	if ids.has("char_mentor_frank"):
		return "the mentor was included in overtime"
	var want_daily: int = HRConstants.overtime_daily_pay(9000) + HRConstants.overtime_daily_pay(6000)
	# TAM gün sürücü: ek mesainin FAYDASI saatlik yolda tüketiliyor (product_system.gd),
	# BEDELİ günlük slot 3'te tahakkuk ediyor. Yalnız günlük yarısını koşan bir sürücü bu
	# ikisinin ayrıştığı yeri hiç göremez — S1-3 tam orada saklanmıştı.
	for d in range(1, 9):
		var m_before: int = a.morale
		_sim_day_full()
		if HROvertimeSystem.day_index(HRConstants.DEPT_PRODUCT_DEV) != d:
			return "day index is %d on overtime day %d" % [HROvertimeSystem.day_index(HRConstants.DEPT_PRODUCT_DEV), d]
		if HROvertimeSystem.pay_accrued_today() != want_daily:
			return "day %d pay %d, want %d (the founder must cost nothing extra)" % [
				d, HROvertimeSystem.pay_accrued_today(), want_daily]
		var drop: int = m_before - a.morale
		if drop != HRConstants.overtime_morale_drop(d):
			return "day %d morale drop %d, want %d" % [d, drop, HRConstants.overtime_morale_drop(d)]
	# The pay reaches burn through Finance's PULL, not an HR push. Slot 5 of the last
	# _sim_day_full() already ran that pull, so calling daily_tick() again here would
	# re-pull AND re-apply a second day of net cash for one calendar day.
	if int(FinanceSystem.get_burn_breakdown().get("overtime", -1)) != want_daily:
		return "overtime pay is not in the burn breakdown (%s)" % str(FinanceSystem.get_burn_breakdown().get("overtime"))
	return ""


static func _case_hr_overtime_multipliers() -> String:
	# STATE, not application: the multipliers must be exact and queryable (task 2 applies
	# them), bug_multiplier is product_dev-ONLY, and a block auto-ends on its final day.
	if not is_equal_approx(HROvertimeSystem.speed_multiplier(HRConstants.DEPT_PRODUCT_DEV), 1.0):
		return "an inactive department does not report 1.0"
	if not is_equal_approx(HROvertimeSystem.bug_multiplier(), 1.0):
		return "the inactive bug multiplier is not 1.0"
	var dev: Character = _make_employee("char_mult_dev", "Mult Dev", HRConstants.ROLE_DEVELOPER, SEED_PACE, 6000, 100)
	_park_leave([dev])
	GameState.set_flag("debug_hr_force", "fail")
	if not HROvertimeSystem.start(HRConstants.DEPT_PRODUCT_DEV, 14):
		return "start refused"
	for d in range(1, 15):
		_sim_day_full()
		if d >= 14:
			break
		var bonus: float = HRConstants.OVERTIME_SPEED_BONUS_LATE if d >= HRConstants.OVERTIME_DIMINISH_DAY else HRConstants.OVERTIME_SPEED_BONUS_EARLY
		if not is_equal_approx(HROvertimeSystem.speed_multiplier(HRConstants.DEPT_PRODUCT_DEV), 1.0 + bonus):
			return "day %d speed multiplier %.4f, want %.4f" % [
				d, HROvertimeSystem.speed_multiplier(HRConstants.DEPT_PRODUCT_DEV), 1.0 + bonus]
		if not is_equal_approx(HROvertimeSystem.bug_multiplier(), HRConstants.OVERTIME_BUG_MULT):
			return "product_dev overtime did not raise the bug multiplier on day %d" % d
	if HROvertimeSystem.is_active(HRConstants.DEPT_PRODUCT_DEV):
		return "the 14-day block did not auto-end on its final day"
	if not is_equal_approx(HROvertimeSystem.bug_multiplier(), 1.0):
		return "the bug multiplier stayed raised after the block ended"
	# A non-product department must not touch the bug channel at all.
	var rep: Character = _make_employee("char_mult_cs", "Mult CS", HRConstants.ROLE_CUSTOMER_REP, SEED_PACE, 5000, 100)
	_park_leave([rep])
	if not HROvertimeSystem.start(HRConstants.DEPT_CUSTOMER, 3):
		return "customer block refused"
	_sim_day()
	if not is_equal_approx(HROvertimeSystem.bug_multiplier(), 1.0):
		return "a customer-department block raised the bug multiplier"
	if is_equal_approx(HROvertimeSystem.speed_multiplier(HRConstants.DEPT_CUSTOMER), 1.0):
		return "the customer block produced no speed multiplier"
	return ""


static func _case_hr_overtime_early_stop() -> String:
	# Stopping on day 4 of a 7-day block accrues EXACTLY four days of pay; nothing is
	# refunded and nothing further accrues.
	GameState.set_cash(200000)
	var e: Character = _make_employee("char_stop", "Stop Guy", HRConstants.ROLE_DEVELOPER, SEED_PACE, 9000, 100)
	_park_leave([e])
	if not HROvertimeSystem.start(HRConstants.DEPT_PRODUCT_DEV, 7):
		return "start refused"
	var daily: int = HRConstants.overtime_daily_pay(9000)
	var paid: int = 0
	for d in 4:
		_sim_day_full()
		paid += HROvertimeSystem.pay_accrued_today()
	if paid != daily * 4:
		return "four worked days accrued %d, want %d" % [paid, daily * 4]
	# Day 4's daily tick already ran, so stop() lands on an ALREADY-CHARGED day and must
	# not bill it twice — the same-day billing rule only fires when the day is unbilled.
	var morale_at_stop: int = e.morale
	if not HROvertimeSystem.stop(HRConstants.DEPT_PRODUCT_DEV):
		return "early stop refused"
	if HROvertimeSystem.is_active(HRConstants.DEPT_PRODUCT_DEV):
		return "the block is still active after stop()"
	if HROvertimeSystem.pay_accrued_today() != daily:
		return "stop() on an already-charged day re-billed it (%d, want %d)" % [
			HROvertimeSystem.pay_accrued_today(), daily]
	for d in 3:
		_sim_day_full()
		if HROvertimeSystem.pay_accrued_today() != 0:
			return "pay kept accruing after the early stop (%d)" % HROvertimeSystem.pay_accrued_today()
	if e.morale != morale_at_stop:
		return "morale kept dropping after the early stop (%d -> %d)" % [morale_at_stop, e.morale]
	if e.overtime_days != 0:
		return "overtime_days not reset on stop (%d)" % e.overtime_days
	return ""


static func _case_hr_overtime_same_day_stop_bills() -> String:
	# S1-3: a block that starts AND stops between two daily ticks must still bill that day.
	# The speed bonus is consumed on the HOURLY tick; the cost used to be charged only on
	# the daily one, so start-at-10:00 / "Bitir"-at-22:00 bought up to 23 hours of +%30
	# build speed for $0 and zero morale, repeatable every single day.
	#
	# This case FAILS against the pre-fix engine: pay stays 0 and morale never moves.
	GameState.set_cash(200000)
	var e: Character = _make_employee("char_sameday", "Same Day", HRConstants.ROLE_DEVELOPER,
		SEED_PACE, 9000, 100)
	_park_leave([e])
	# Land on a clean day boundary first, so the pay stamp belongs to "today".
	_sim_day_full()
	var morale_before: int = e.morale
	if not HROvertimeSystem.start(HRConstants.DEPT_PRODUCT_DEV, 7):
		return "start refused"
	# Mid-day: the hours where the bonus is actually collected.
	for h in range(10, 22):
		TimeManager._dispatch_hourly_tick(h)
	if is_equal_approx(HROvertimeSystem.speed_multiplier(HRConstants.DEPT_PRODUCT_DEV), 1.0):
		return "no speed bonus was on offer during the block — case proves nothing"
	if not HROvertimeSystem.stop(HRConstants.DEPT_PRODUCT_DEV):
		return "early stop refused"
	if e.morale >= morale_before:
		return "same-day stop cost no morale (%d -> %d)" % [morale_before, e.morale]
	# The money rides the carry into the next day's total, because Finance already pulled
	# for today by the time any in-day stop can happen.
	var daily: int = HRConstants.overtime_daily_pay(9000)
	_sim_day_full()
	if HROvertimeSystem.pay_accrued_today() != daily:
		return "same-day stop billed %d, want %d" % [HROvertimeSystem.pay_accrued_today(), daily]
	if int(FinanceSystem.get_burn_breakdown().get("overtime", -1)) != daily:
		return "the billed day never reached burn (%s)" % str(
			FinanceSystem.get_burn_breakdown().get("overtime"))
	# …and it is billed ONCE: the day after, nothing lingers.
	_sim_day_full()
	if HROvertimeSystem.pay_accrued_today() != 0:
		return "the stopped block kept billing (%d)" % HROvertimeSystem.pay_accrued_today()
	return ""


static func _case_hr_overtime_safety_valve() -> String:
	# The valve is an EVENT, never a silent exclusion: a participant crossing into KAÇMA
	# RİSKİ mid-block asks the player, "Devam et" raises THAT person's odds, and nobody is
	# removed from the block behind the player's back.
	GameState.set_cash(200000)
	GameState.set_flag("debug_hr_force", "fail")   # isolate the valve from the resignation roll
	var e: Character = _make_employee("char_valve", "Valve Guy", HRConstants.ROLE_DEVELOPER,
		SEED_PACE, 9000, HRConstants.MORALE_FLIGHT_RISK + 2)
	_park_leave([e])
	if not HROvertimeSystem.start(HRConstants.DEPT_PRODUCT_DEV, 14):
		return "start refused"
	var valve_id: String = "ev_hr_valve_%s" % e.id
	var seen: bool = false
	for d in 5:
		_sim_day()
		if _instances_of(valve_id) >= 1:
			seen = true
			break
	if not seen:
		return "no safety-valve event when a participant crossed the flight-risk line (morale %d)" % e.morale
	var still_in: bool = false
	for p in HROvertimeSystem.participants(HRConstants.DEPT_PRODUCT_DEV):
		if p.id == e.id:
			still_in = true
	if not still_in:
		return "the at-risk employee was silently removed from overtime"
	if not HROvertimeSystem.is_active(HRConstants.DEPT_PRODUCT_DEV):
		return "the block stopped on its own"
	if not _drain_to(valve_id):
		return "could not bring the valve event to the front"
	var odds_before: float = HRConstants.resign_chance(e.traits, false)
	EventManager.resolve_choice(valve_id, 1)   # "Devam et"
	if not HROvertimeSystem.valve_continued_for(e.id):
		return "'Devam et' did not record the continued risk"
	if HRConstants.resign_chance(e.traits, true) <= odds_before:
		return "continuing did not raise the resignation odds (%.3f vs %.3f)" % [
			HRConstants.resign_chance(e.traits, true), odds_before]
	if not HROvertimeSystem.is_active(HRConstants.DEPT_PRODUCT_DEV):
		return "'Devam et' stopped the block"
	return ""


static func _case_hr_raise_and_vacation() -> String:
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
	var cap0: int = ProductSystem.capacity_total()
	var vprev: Dictionary = HRActions.preview_vacation(e)
	if not bool(vprev.get("consumes_annual_leave", false)):
		return "the vacation preview does not say it consumes that year's automatic leave"
	if not HRActions.send_on_vacation(e):
		return "vacation refused"
	if e.status != HRConstants.STATUS_ON_LEAVE:
		return "vacation did not take the employee out of capacity"
	if ProductSystem.capacity_total() != cap0 - 1:
		return "capacity unchanged during a vacation"
	if e.leave_taken_year != int(GameState.get_date_dict().year):
		return "the manual vacation did not consume this year's automatic leave"
	var mv: int = e.morale
	for i in HRConstants.VACATION_DAYS + 3:
		_sim_day()
		if e.status == HRConstants.STATUS_ACTIVE:
			break
	if e.status != HRConstants.STATUS_ACTIVE:
		return "never returned from the manual vacation"
	if e.morale <= mv:
		return "the vacation return did not refresh morale (%d -> %d)" % [mv, e.morale]
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
	if HRActions.can_fire(frank) or HRActions.can_raise(frank, 5) or HRActions.can_send_on_vacation(frank):
		return "an HR action accepts the mentor"
	if HRActions.can_fire(CharacterRegistry.get_founder()):
		return "the founder is fireable"
	var dev: Character = _make_employee("char_guard_dev", "Guard Dev", HRConstants.ROLE_DEVELOPER, SEED_PACE, 6000, 90)
	_park_leave([dev])
	if not HROvertimeSystem.start(HRConstants.DEPT_PRODUCT_DEV, 3):
		return "overtime block refused"
	for p in HROvertimeSystem.participants(HRConstants.DEPT_PRODUCT_DEV):
		if p.id == frank.id:
			return "the mentor was included in overtime"
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
	if B2BSalesSystem._cs_expertise_of(cust) <= 0:
		return "an ACTIVE customer rep gives no churn dampen"
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
	if not HROvertimeSystem.participants(HRConstants.DEPT_PRODUCT_DEV).is_empty():
		return "an on-leave employee can be put on overtime"
	if B2BSalesSystem._cs_expertise_of(cust) != 0:
		return "an on-leave customer rep still dampens churn (%d)" % B2BSalesSystem._cs_expertise_of(cust)
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
	# needs_engineer finally has a READER: the AŞIRI YÜKLÜ badge. It was write-only before
	# this task. And badges are DERIVED, which is what lets one person carry two at once.
	var dev: Character = _make_employee("char_load_dev", "Load Dev", HRConstants.ROLE_DEVELOPER, SEED_PACE, 6000, 70)
	var rep: Character = _make_employee("char_load_rep", "Load Rep", HRConstants.ROLE_CUSTOMER_REP, SEED_PACE, 5000, 70)
	_park_leave([dev, rep])
	if HRMoraleSystem.is_capacity_overloaded():
		return "reported overloaded with no capacity pressure"
	if HRSystem.badges_for(dev).has(HRConstants.BADGE_OVERLOADED):
		return "AŞIRI YÜKLÜ badge before any capacity pressure"
	GameState.set_flag("needs_engineer", true)
	if not HRMoraleSystem.is_capacity_overloaded():
		return "needs_engineer still has no reader — the flag is write-only"
	if not HRSystem.badges_for(dev).has(HRConstants.BADGE_OVERLOADED):
		return "a product_dev member shows no AŞIRI YÜKLÜ under capacity pressure"
	if HRSystem.badges_for(rep).has(HRConstants.BADGE_OVERLOADED):
		return "a customer-department member shows a product capacity badge"
	CharacterRegistry.set_morale(dev.id, HRConstants.MORALE_BURNOUT - 1)
	if not HRSystem.badges_for(dev).has(HRConstants.BADGE_BURNING_OUT):
		return "no TÜKENİYOR badge under the burnout threshold"
	CharacterRegistry.set_morale(dev.id, HRConstants.MORALE_FLIGHT_RISK - 1)
	if not HRSystem.badges_for(dev).has(HRConstants.BADGE_FLIGHT_RISK):
		return "no KAÇMA RİSKİ badge under the flight-risk threshold"
	# Two at once is exactly why badges are derived rather than a single String field.
	if HRSystem.badges_for(dev).size() < 2:
		return "an employee cannot carry two badges at once: %s" % str(HRSystem.badges_for(dev))
	if dev.attention_flag != "":
		return "attention_flag was written; badges must stay derived"
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
	if not is_equal_approx(ProductSystem.EMPLOYEE_SPEED_COEF * float(SEED_PACE), 1.0):
		return "pace %d contributes %.3f efor/day, want the old assist engineer's 1.0" % [
			SEED_PACE, ProductSystem.EMPLOYEE_SPEED_COEF * float(SEED_PACE)]
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
		if HRConstants.department_of(role_id) == "":
			return "role '%s' has no department" % role_id
		if not HRConstants.ROLE_AXIS_MEANING.has(role_id):
			return "role '%s' has no per-axis meaning copy" % role_id
	if HRConstants.role_label(HRConstants.ROLE_MENTOR) != "Operating Partner":
		return "the mentor label drifted (it is already on screen): '%s'" % HRConstants.role_label(HRConstants.ROLE_MENTOR)
	if HRConstants.roles_in_department(HRConstants.DEPT_PRODUCT_DEV).size() != 4:
		return "product_dev should hold four roles, holds %d" % HRConstants.roles_in_department(HRConstants.DEPT_PRODUCT_DEV).size()

	# --- Trait catalog: 5 + 5, every entry displayable with its effect ---
	if HRConstants.positive_trait_ids().size() != 5 or HRConstants.negative_trait_ids().size() != 5:
		return "trait catalog is %d+/%d-, want 5+/5-" % [
			HRConstants.positive_trait_ids().size(), HRConstants.negative_trait_ids().size()]
	for trait_id in HRConstants.TRAITS.keys():
		if HRConstants.trait_label(trait_id) == trait_id:
			return "trait '%s' has no label" % trait_id
		if HRConstants.trait_effect_text(trait_id) == "":
			return "trait '%s' has no effect text — a candidate file must state it plainly" % trait_id
	# The two morale traits are exact inverses, so a mixed file cancels out.
	if not is_equal_approx(HRConstants.trait_mult(["pressure_proof", "glass_heart"], "morale_drop_mult"), 1.0):
		return "the opposing morale traits do not cancel"
	if not is_equal_approx(HRConstants.trait_mult([], "morale_drop_mult"), 1.0):
		return "an empty trait list is not multiplicatively neutral"

	# --- Band shapes: the STRUCTURAL invariants behind non-dominance + distinct prices ---
	# Karma profiller (B1): bant başına CANDIDATE_COUNT profil, ucuzdan pahalıya;
	# aday k = profil k rotasyon k. Toplamlar kesin artar — non-dominance'ın ve ayrık
	# fiyatların yapısal ön koşulu (A her eksende >= B ⇒ total(A) >= total(B)).
	for band_id in HRConstants.BANDS:
		var profiles: Array = HRConstants.BAND_SHAPE.get(band_id, [])
		if profiles.size() != HRConstants.CANDIDATE_COUNT:
			return "band '%s' holds %d profiles, want CANDIDATE_COUNT (%d)" % [
				band_id, profiles.size(), HRConstants.CANDIDATE_COUNT]
		var prev_total: int = -1
		for k in profiles.size():
			var shape: Array = HRConstants.band_shape(band_id, k)
			if shape.size() != HRConstants.AXES.size():
				return "band '%s' profile %d is not one value per axis" % [band_id, k]
			if not (int(shape[0]) > int(shape[1]) and int(shape[1]) >= int(shape[2])):
				return "band '%s' profile %d breaks peak>mid>=low, so a rotation has no strict max: %s" % [band_id, k, str(shape)]
			if int(shape[0]) > HRConstants.AXIS_MAX or int(shape[2]) < HRConstants.AXIS_MIN:
				return "band '%s' profile %d leaves the 0-%d ruler: %s" % [band_id, k, HRConstants.AXIS_MAX, str(shape)]
			var total: int = 0
			for v in shape:
				total += int(v)
			if total <= prev_total:
				return "band '%s' profile totals do not strictly increase (%d after %d): %s" % [
					band_id, total, prev_total, str(profiles)]
			prev_total = total
		for role_id in HRConstants.EMPLOYEE_ROLES:
			var b: Array = HRConstants.salary_band(role_id, band_id)
			if b.size() != 2 or int(b[0]) >= int(b[1]):
				return "salary band %s/%s is not a low..high pair: %s" % [role_id, band_id, str(b)]
	# Money must buy level, or the three tiers are decoration — the cheapest AND the
	# priciest profile peaks both climb across the tiers.
	var top: int = HRConstants.CANDIDATE_COUNT - 1
	if not (int(HRConstants.band_shape(HRConstants.BAND_JUNIOR, 0)[0]) < int(HRConstants.band_shape(HRConstants.BAND_MID, 0)[0]) \
			and int(HRConstants.band_shape(HRConstants.BAND_MID, 0)[0]) < int(HRConstants.band_shape(HRConstants.BAND_SENIOR, 0)[0])):
		return "the band tiers do not climb the ruler (cheapest profiles)"
	if not (int(HRConstants.band_shape(HRConstants.BAND_JUNIOR, top)[0]) < int(HRConstants.band_shape(HRConstants.BAND_MID, top)[0]) \
			and int(HRConstants.band_shape(HRConstants.BAND_MID, top)[0]) < int(HRConstants.band_shape(HRConstants.BAND_SENIOR, top)[0])):
		return "the band tiers do not climb the ruler (top profiles)"

	# --- Economy + action math ---
	if HRConstants.commission_for(9200) != 1380:
		return "commission on 9200 is %d, want the mockup's 1380" % HRConstants.commission_for(9200)
	if HRConstants.severance_months(364) != 1 or HRConstants.severance_months(730) != 2:
		return "the severance year rule drifted"
	if HRConstants.raise_morale_gain(HRConstants.RAISE_MAX_PCT) <= HRConstants.raise_morale_gain(HRConstants.RAISE_MIN_PCT):
		return "the raise morale gain does not scale with the percentage"
	if HRConstants.overtime_daily_pay(9000) != 120:
		return "overtime daily pay on 9000 is %d, want 120 (40%% of a daily 300)" % HRConstants.overtime_daily_pay(9000)

	# --- Overtime ladder ---
	if HRConstants.overtime_morale_drop(3) == HRConstants.overtime_morale_drop(4) \
			or HRConstants.overtime_morale_drop(7) == HRConstants.overtime_morale_drop(8):
		return "the overtime morale tiers do not step at day 4 and day 8"
	if not is_equal_approx(HRConstants.overtime_speed_bonus(HRConstants.OVERTIME_DIMINISH_DAY - 1), HRConstants.OVERTIME_SPEED_BONUS_EARLY):
		return "the day before the diminish point is not the opening rate"
	if not is_equal_approx(HRConstants.overtime_speed_bonus(HRConstants.OVERTIME_DIMINISH_DAY), HRConstants.OVERTIME_SPEED_BONUS_LATE):
		return "the diminish point does not drop the rate"

	# --- Liderlik: climate + coordination ---
	if not is_equal_approx(HRConstants.climate_drop_mult(0), 1.0) or not is_equal_approx(HRConstants.climate_gain_mult(0), 1.0):
		return "leadership 0 must be climate-neutral, or every existing number moves"
	if HRConstants.climate_drop_mult(3) >= 1.0 or HRConstants.climate_gain_mult(3) <= 1.0:
		return "the climate coefficients do not respond to leadership"
	if HRConstants.climate_drop_mult(HRConstants.AXIS_MAX) < HRConstants.CLIMATE_DROP_FLOOR:
		return "the climate drop multiplier fell through its floor"
	# coordination_mult() was split by source (founder rises from neutral, employee is
	# two-sided) — the employee variant is the one that spans the whole COORD_MIN..COORD_MAX ruler.
	if not is_equal_approx(HRConstants.coordination_for_employee(0), HRConstants.COORD_MIN) \
			or not is_equal_approx(HRConstants.coordination_for_employee(HRConstants.AXIS_MAX), HRConstants.COORD_MAX):
		return "the coordination multiplier does not span COORD_MIN..COORD_MAX"
	if HRConstants.coordination_for_employee(HRConstants.AXIS_MAX, true) <= HRConstants.coordination_for_employee(HRConstants.AXIS_MAX, false):
		return "'Doğal lider' adds nothing at the top of the coordination range"
	# Founder-as-lead is NEUTRAL at Liderlik 0 and only rises — the anchor that keeps a
	# tech-3 solo founder at exactly 3.0 efor/gün (hr_constants.gd:532-536).
	if not is_equal_approx(HRConstants.coordination_for_founder(0), HRConstants.COORD_FOUNDER_NEUTRAL):
		return "founder coordination at Liderlik 0 is not neutral"
	if HRConstants.coordination_for_founder(HRConstants.AXIS_MAX) <= HRConstants.coordination_for_founder(0):
		return "founder coordination does not rise with Liderlik"

	# --- Thresholds asked through ONE comparison home ---
	if HRConstants.is_flight_risk(HRConstants.MORALE_FLIGHT_RISK):
		return "exactly the flight-risk threshold must NOT count as at risk (design says 'altı')"
	if not HRConstants.is_flight_risk(HRConstants.MORALE_FLIGHT_RISK - 1):
		return "one under the flight-risk threshold is not at risk"
	if HRConstants.is_burning_out(HRConstants.MORALE_BURNOUT):
		return "exactly the burnout threshold must NOT count as burning out"

	# --- Leave distribution: spread across months, and NEVER the hire month ---
	for hire_month in range(1, 13):
		var seen: Array = []
		for ordinal in 12 - HRConstants.LEAVE_MONTH_MIN_GAP:
			var m: int = HRConstants.leave_month_for(hire_month, ordinal)
			if m < 1 or m > 12:
				return "leave month out of range: %d" % m
			if m == hire_month:
				return "a hire in month %d was given leave in that same month (ordinal %d)" % [hire_month, ordinal]
			if seen.has(m):
				return "leave month %d repeats within the allowed span (stride not coprime)" % m
			seen.append(m)
	return ""


# ============================ Speed ladder (tempo) ===========================
# The ladder is expressed as REAL SECONDS PER IN-GAME DAY in ONE place
# (TimeManager.SECONDS_PER_DAY). These two cases pin the contract that makes the
# retune safe: the table itself, and the fact that a game day is the same number
# of ticks at every speed (only the real-time rate differs).

static func _case_speed_ladder() -> String:
	var ladder: Array = TimeManager.SECONDS_PER_DAY
	if ladder.size() != 5:
		return "the ladder has %d entries, want 5 (pause + 1x/2x/3x/4x)" % ladder.size()
	var want: Array = [0.0, 12.0, 6.0, 3.0, 1.5]
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

	# Bounds: the NEW top index is accepted, one past it is refused.
	EventBus.speed_change_requested.emit(4)
	if TimeManager.current_speed != 4:
		return "top speed 4 was rejected (current %d)" % TimeManager.current_speed
	EventBus.speed_change_requested.emit(ladder.size())
	if TimeManager.current_speed != 4:
		return "an out-of-range speed was accepted (current %d)" % TimeManager.current_speed

	# Pause/resume round-trip at the new top index (speed_preserve covers idx 2).
	EventBus.speed_change_requested.emit(0)
	TimeManager.resume_if_paused()
	if TimeManager.current_speed != 4:
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
	founder.role_stats["tech"] = 3
	var coord: float = HRConstants.coordination_for_founder(GameState.get_founder_skill("leadership"))
	if not is_equal_approx(coord, 1.0):
		return "the debug payload no longer gives a neutral coordination multiplier (%.3f) — every anchor below shifts" % coord
	if not ProductSystem.start_build("ai_assistant", ["ai_assistant_tools", "ai_assistant_image"], ""):
		return "start_build failed"
	var b: FeatureBuild = ProductSystem.get_active_build()
	if not _run_build_to_phase("development"):
		return "build never reached development"
	# ANCHOR a2: founder tech-3 solo == 3.0 efor/gün, exactly the pre-Coupling number.
	if absf(ProductSystem.team_speed(b) - 3.0) > 0.001:
		return "anchor a2 broken: founder tech-3 solo is %.3f efor/day, want 3.0" % ProductSystem.team_speed(b)
	# ANCHOR b1: a pace-4 developer adds exactly 1.0, what a pre-Coupling assist engineer added.
	_make_employee("char_law_dev", "Law Dev", HRConstants.ROLE_DEVELOPER)
	if absf(ProductSystem.team_speed(b) - 4.0) > 0.001:
		return "anchor b1 broken: +pace-4 developer gives %.3f, want 4.0" % ProductSystem.team_speed(b)
	# ROL-FAZ EŞLEMESİ (design doc §5): a designer does not write code, a developer does not
	# draw screens. Each role moves the phase it owns and no other.
	_make_employee("char_law_designer", "Law Designer", HRConstants.ROLE_DESIGNER)
	if absf(ProductSystem.team_speed(b) - 4.0) > 0.001:
		return "a designer changed GELİŞTİRME speed (%.3f); that phase belongs to the developer" % ProductSystem.team_speed(b)
	# ...and the mirror: in TASARIM the designer counts and the developer does not.
	var iter_speed: float = ProductSystem._speed_for_phase("iteration", "")
	var want_iter: float = ProductSystem.FOUNDER_SPEED_COEF * 3.0 \
		+ ProductSystem.EMPLOYEE_SPEED_COEF * float(SEED_PACE)
	if absf(iter_speed - want_iter) > 0.001:
		return "TASARIM speed %.3f, want founder + designer only (%.3f)" % [iter_speed, want_iter]
	# AĞIRLIK YOK among employees: making the developer the SORUMLU must not change the SUM.
	# (Their quality shows up in the coordination term, which is what replaced the lead weight.)
	var sum_before: float = ProductSystem._phase_pace_sum("development", "")
	var sum_as_lead: float = ProductSystem._phase_pace_sum("development", "char_law_dev")
	if absf(sum_before - sum_as_lead) > 0.001:
		return "the lead still carries extra HIZ weight (%.3f vs %.3f) — 'ağırlık yok' broken" % [sum_before, sum_as_lead]
	return ""


static func _case_coupling_coordination_sources() -> String:
	# The multiplier is asymmetric BY SOURCE, and a stale lead resolves loudly to the founder.
	GameState.set_cash(200000)
	var founder: Character = CharacterRegistry.get_founder()
	founder.role_stats["tech"] = 3
	founder.role_stats["leadership"] = 0
	# Founder-as-lead is never a penalty: neutral at Liderlik 0, rising after that.
	if not is_equal_approx(HRConstants.coordination_for_founder(0), 1.0):
		return "founder coordination at Liderlik 0 is %.3f, want exactly 1.0" % HRConstants.coordination_for_founder(0)
	if HRConstants.coordination_for_founder(9) <= 1.0:
		return "founder coordination does not rise with Liderlik"
	# A CHOSEN employee lead is a real bet — low UYUM genuinely coordinates worse.
	if HRConstants.coordination_for_employee(0) >= 1.0:
		return "a UYUM-0 employee lead is not a penalty (%.3f)" % HRConstants.coordination_for_employee(0)
	if HRConstants.coordination_for_employee(0) >= HRConstants.coordination_for_employee(9):
		return "employee coordination is not two-sided across the ruler"
	# The lead's UYUM actually reaches the build speed.
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
	founder.role_stats["tech"] = 3
	var dev_roles: Array = ProductSystem._phase_crew_roles("development")
	# Founder alone and in charge: the average IS his Teknoloji — byte-equal to the
	# pre-Coupling founder-only read, which is why the reducer was not rescaled.
	if absf(ProductSystem._team_expertise_avg(dev_roles, "") - 3.0) > 0.001:
		return "founder-solo average is %.3f, want his Teknoloji 3.0 exactly" % ProductSystem._team_expertise_avg(dev_roles, "")
	# A STRONG team lifts the average (fewer bugs)...
	var strong: Character = _make_employee("char_bug_strong", "Strong Dev", HRConstants.ROLE_DEVELOPER,
		SEED_PACE, 0, 50, 9, SEED_RAPPORT)
	var avg_strong: float = ProductSystem._team_expertise_avg(dev_roles, "")
	if avg_strong <= 3.0:
		return "an UZMANLIK-9 developer did not lift the average (%.3f)" % avg_strong
	CharacterRegistry.remove(strong.id)
	# ...and a WEAK team drags it below the founder's own number (more bugs). Two-directional.
	_make_employee("char_bug_weak", "Weak Dev", HRConstants.ROLE_DEVELOPER,
		SEED_PACE, 0, 50, 0, SEED_RAPPORT)
	var avg_weak: float = ProductSystem._team_expertise_avg(dev_roles, "")
	if avg_weak >= 3.0:
		return "an UZMANLIK-0 developer did not drag the average down (%.3f)" % avg_weak
	# The SORUMLU carries ×1.5, so who is in charge changes the quality average.
	var as_member: float = ProductSystem._team_expertise_avg(dev_roles, "")
	var as_lead: float = ProductSystem._team_expertise_avg(dev_roles, "char_bug_weak")
	if as_lead >= as_member:
		return "making the weak developer SORUMLU did not lower the average (%.3f -> %.3f)" % [as_member, as_lead]
	return ""


static func _case_coupling_wear_team_average() -> String:
	# Post-ship wear follows the SAME grammar as bug — the founder-only read is gone.
	_seed_live_product()
	var founder: Character = CharacterRegistry.get_founder()
	founder.role_stats["tech"] = 3
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
	# Same day again, but with a high-UZMANLIK developer on staff: wear must be SLOWER.
	_make_employee("char_wear_dev", "Wear Dev", HRConstants.ROLE_DEVELOPER,
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
	# No product manager → the bonus is exactly 0, which is why every PM-less case is untouched.
	var pm: Character = _make_employee("char_pm", "Pm One", HRConstants.ROLE_PRODUCT_MANAGER,
		SEED_PACE, 0, 50, 4, SEED_RAPPORT)
	var after: Dictionary = ProductSystem.projected_axes(picks, [], {})
	var gain: float = float(after["experience"]) - float(before["experience"])
	if gain <= 0.0:
		return "a product manager added no Deneyim bonus"
	if absf(float(after["innovation"]) - float(before["innovation"])) > 0.001 \
			or absf(float(after["stability"]) - float(before["stability"])) > 0.001:
		return "the PM bonus leaked into an axis other than Deneyim"
	# The CAP applies to the BONUS TERM, not the axis total — otherwise v2's accumulated
	# Deneyim would eat the cap and a new PM would silently add nothing.
	pm.role_stats["expertise"] = 9
	_make_employee("char_pm2", "Pm Two", HRConstants.ROLE_PRODUCT_MANAGER,
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
	if not ProductSystem._phase_crew_roles("bugfix").has(HRConstants.ROLE_TESTER):
		return "the tester is not in the BETA phase crew"
	return ""


static func _case_coupling_cs_dampen_axis() -> String:
	# ANCHOR b2: the churn dampen reads UZMANLIK directly, and a UZMANLIK-5 rep dampens
	# EXACTLY as the pre-Coupling cs_skill-55 rep did — the shim's promise, kept without it.
	if not is_equal_approx(B2BConstants.cs_dampen(5), 0.725):
		return "UZMANLIK-5 dampen is %.4f, want the old cs_skill-55 value 0.725" % B2BConstants.cs_dampen(5)
	# Today's structural property preserved: the floor stays unreachable across the ruler.
	if B2BConstants.cs_dampen(HRConstants.AXIS_MAX) <= B2BConstants.CS_DAMPEN_MIN:
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
	p.industry = "Sigorta"
	p.archetype = "small"
	p.pain_feature_id = "ai_vec_filter"
	var bb: Customer = SalesSystem.add_b2b_customer(p, 1000, 70)
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
	founder.role_stats["tech"] = 3
	_make_employee("char_ot_dev", "OT Dev", HRConstants.ROLE_DEVELOPER, SEED_PACE, 6000, 100)
	if not ProductSystem.start_build("ai_assistant", ["ai_assistant_tools", "ai_assistant_image"], ""):
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
	# Same day with a product_dev block running: FASTER, and buggier.
	if not HROvertimeSystem.start(HRConstants.DEPT_PRODUCT_DEV, 7):
		return "overtime block refused"
	e0 = b.efor_spent
	bugs0 = b.bug_progress + float(b.bug_count)
	for h in 24:
		ProductSystem.hourly_tick(h)
	var ot_efor: float = b.efor_spent - e0
	var ot_bugs: float = (b.bug_progress + float(b.bug_count)) - bugs0
	if ot_efor <= base_efor:
		return "ek mesai did not speed the build up (%.3f -> %.3f efor/day)" % [base_efor, ot_efor]
	var want_ratio: float = 1.0 + HRConstants.OVERTIME_SPEED_BONUS_EARLY
	if absf(ot_efor / maxf(0.001, base_efor) - want_ratio) > 0.02:
		return "ek mesai speed ratio %.3f, want %.3f" % [ot_efor / maxf(0.001, base_efor), want_ratio]
	if ot_bugs <= base_bugs:
		return "ek mesai did not raise the bug rate (%.4f -> %.4f)" % [base_bugs, ot_bugs]
	if absf(ot_bugs / maxf(0.0001, base_bugs) - HRConstants.OVERTIME_BUG_MULT) > 0.05:
		return "ek mesai bug ratio %.3f, want %.3f" % [
			ot_bugs / maxf(0.0001, base_bugs), HRConstants.OVERTIME_BUG_MULT]
	# Stopping the block returns both channels to baseline — the multipliers are not sticky.
	HROvertimeSystem.stop(HRConstants.DEPT_PRODUCT_DEV)
	if not is_equal_approx(HROvertimeSystem.speed_multiplier(HRConstants.DEPT_PRODUCT_DEV), 1.0) \
			or not is_equal_approx(HROvertimeSystem.bug_multiplier(), 1.0):
		return "the multipliers stayed raised after the block stopped"
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


static func _add_prospect(pid: String, archetype: String, pain: String) -> Prospect:
	# Hand-built so a case controls archetype and pain exactly (spawn_prospect derives both).
	var p := Prospect.new()
	p.id = pid
	p.company_name = "Lead " + pid
	p.industry = "Testing"
	p.archetype = archetype
	p.scale = CustomerArchetypes.scale_base(archetype)
	p.difficulty_stars = CustomerArchetypes.difficulty_stars(archetype)
	p.pain_feature_id = pain
	ProspectRegistry.add(p)
	return p


static func _case_sales_pipeline_rate_by_pace() -> String:
	# HIZ drives the autonomous lead cadence, and ZERO sales staff produces zero leads.
	GameState.set_flag("mvp_sub_product_type_id", "ai_vector_search")
	_seed_b2b(1000)
	var before: int = ProspectRegistry.count()
	for i in 10:
		GameState.advance_day()
		B2BSalesSystem.daily_tick()
	if ProspectRegistry.count() != before:
		return "leads appeared with NO sales rep (%d -> %d)" % [before, ProspectRegistry.count()]
	if not is_equal_approx(SalesRepSystem.lead_rate_per_day(), 0.0):
		return "lead rate non-zero with no rep: %f" % SalesRepSystem.lead_rate_per_day()
	var rep: Character = _make_sales_rep("char_sr_1", 6, 1)
	var pace: float = float(int(rep.role_stats.get(HRConstants.AXIS_PACE, 0)))
	var want: float = B2BConstants.LEAD_PER_PACE_POINT * pace
	if not is_equal_approx(SalesRepSystem.lead_rate_per_day(), want):
		return "lead rate %f, want %f" % [SalesRepSystem.lead_rate_per_day(), want]
	# Over N days the accumulator emits floor(N x rate) leads (soft cap not reached).
	var base: int = ProspectRegistry.count()
	var days: int = 10
	for i in days:
		GameState.advance_day()
		B2BSalesSystem.daily_tick()
	var expected: int = int(floor(float(days) * want + 0.0000001))
	if ProspectRegistry.count() - base != expected:
		return "emitted %d leads over %d days, want %d" % [
			ProspectRegistry.count() - base, days, expected]
	return ""


static func _case_sales_pipeline_stack_diminishes() -> String:
	# A second rep adds STRICTLY MORE than zero and STRICTLY LESS than a second full rep.
	GameState.set_flag("mvp_sub_product_type_id", "ai_vector_search")
	_seed_b2b(1000)
	_make_sales_rep("char_sr_1", 6, 1)
	var one: float = SalesRepSystem.lead_rate_per_day()
	_make_sales_rep("char_sr_2", 6, 1)
	var two: float = SalesRepSystem.lead_rate_per_day()
	if two <= one:
		return "second rep added nothing (%f -> %f)" % [one, two]
	if two >= one * 2.0:
		return "second rep stacked linearly (%f -> %f); diminishing returns missing" % [one, two]
	var want: float = one * (1.0 + B2BConstants.REP_STACK_DECAY)
	if not is_equal_approx(two, want):
		return "stacked rate %f, want %f (decay %f)" % [two, want, B2BConstants.REP_STACK_DECAY]
	return ""


static func _case_sales_autonomous_close_routine() -> String:
	# A ROUTINE lead closes itself, lands in the small band, names the closer, and logs.
	GameState.set_flag("mvp_sub_product_type_id", "ai_vector_search")
	_seed_b2b(1000)
	GameState.set_flag("mvp_components", ["ai_vec_filter"])  # pain SHIPPED -> no concession
	var rep: Character = _make_sales_rep("char_sr_1", 0, 9)
	_add_prospect("routine", "small", "ai_vec_filter")
	var signed0: int = GameState.run_customers_signed
	var closed: bool = false
	for i in 40:
		GameState.advance_day()
		B2BSalesSystem.daily_tick()
		if ProspectRegistry.get_prospect("routine") == null:
			closed = true
			break
	if not closed:
		return "a routine lead never closed autonomously"
	if GameState.run_customers_signed != signed0 + 1:
		return "signing counter did not move (%d -> %d)" % [signed0, GameState.run_customers_signed]
	var c: Customer = CustomerRegistry.get_customer("co_routine")
	if c == null:
		return "no customer created for the auto-closed lead"
	if c.acquisition_source != "sales_rep:%s" % rep.id:
		return "acquisition_source does not name the closer: %s" % c.acquisition_source
	var band: Dictionary = CustomerArchetypes.mrr_band("small")
	if c.mrr < int(band["low"]) or c.mrr > int(band["high"]):
		return "auto-closed MRR %d outside the small band" % c.mrr
	if c.mrr > B2BConstants.AUTONOMOUS_CLOSE_MRR_MAX:
		return "auto-closed MRR %d crossed the threshold" % c.mrr
	var log: Array = SalesSystem.get_sales_log()
	if log.is_empty():
		return "the autonomous close produced no activity-log line"
	var last: Dictionary = log[log.size() - 1]
	if String(last.get("kind", "")) != "auto_close" or String(last.get("actor", "")) != rep.character_name:
		return "activity line does not name who closed it: %s" % str(last)
	return ""


static func _case_sales_close_threshold_surfaces() -> String:
	# THE BOUNDARY PROOF: a lead above the threshold warms but NEVER closes itself.
	GameState.set_flag("mvp_sub_product_type_id", "ai_vector_search")
	_seed_b2b(1000)
	GameState.set_flag("mvp_components", ["ai_vec_filter"])
	_make_sales_rep("char_sr_1", 0, 9)
	_add_prospect("big", "mid", "ai_vec_filter")
	var signed0: int = GameState.run_customers_signed
	for i in 40:
		GameState.advance_day()
		B2BSalesSystem.daily_tick()
	var p: Prospect = ProspectRegistry.get_prospect("big")
	if p == null:
		return "an above-threshold lead was closed autonomously"
	if GameState.run_customers_signed != signed0:
		return "signing counter moved without a played pitch (%d -> %d)" % [
			signed0, GameState.run_customers_signed]
	if p.warm_progress < B2BConstants.AUTO_CLOSE_PROGRESS:
		return "the rep never worked the big lead (warm=%f)" % p.warm_progress
	if SalesRepSystem.warm_bonus_for(p) != B2BConstants.WARM_BONUS_MAX:
		return "warm bonus %d, want the cap %d" % [
			SalesRepSystem.warm_bonus_for(p), B2BConstants.WARM_BONUS_MAX]
	return ""


static func _case_sales_threshold_separates_tiers() -> String:
	# The threshold must sit in the GAP between the small and mid bands. If a balance pass
	# moves a band, this trips before an above-threshold deal can start auto-closing.
	var small_high: int = int(CustomerArchetypes.mrr_band("small")["high"])
	var mid_low: int = int(CustomerArchetypes.mrr_band("mid")["low"])
	if small_high >= B2BConstants.AUTONOMOUS_CLOSE_MRR_MAX \
			or B2BConstants.AUTONOMOUS_CLOSE_MRR_MAX >= mid_low:
		return "threshold %d is not inside the band gap (%d..%d)" % [
			B2BConstants.AUTONOMOUS_CLOSE_MRR_MAX, small_high, mid_low]
	# SIZE is the only variable here, so the concession gate must be held OPEN: every lead
	# voices a pain the product has ALREADY shipped. A bare Prospect leaves pain_feature_id
	# empty, and an unmappable pain is (correctly) the conservative case — it would fail
	# these three on the wrong axis and hide a real band regression.
	GameState.set_flag("mvp_components", ["ai_vec_search_api"])
	var s := Prospect.new()
	s.archetype = "small"
	s.pain_feature_id = "ai_vec_search_api"
	var m := Prospect.new()
	m.archetype = "mid"
	m.pain_feature_id = "ai_vec_search_api"
	var e := Prospect.new()
	e.archetype = "enterprise"
	e.pain_feature_id = "ai_vec_search_api"
	if not SalesRepSystem.is_auto_closable(s):
		return "a small lead is not auto-closable"
	if SalesRepSystem.is_auto_closable(m) or SalesRepSystem.is_auto_closable(e):
		return "a mid/enterprise lead is auto-closable"
	return ""


static func _case_sales_concession_deal_surfaces() -> String:
	# A lead whose pain maps to an UNSHIPPED feature needs the founder's word -> never auto.
	GameState.set_flag("mvp_sub_product_type_id", "ai_vector_search")
	_seed_b2b(1000)
	GameState.set_flag("mvp_components", ["ai_vec_search_api"])  # NOT the pain below
	_make_sales_rep("char_sr_1", 0, 9)
	var p: Prospect = _add_prospect("concession", "small", "ai_vec_filter")
	if SalesRepSystem.is_auto_closable(p):
		return "a concession lead reads as auto-closable"
	for i in 40:
		GameState.advance_day()
		B2BSalesSystem.daily_tick()
	if ProspectRegistry.get_prospect("concession") == null:
		return "a concession lead closed without the founder"
	# Ship the feature and the SAME lead becomes routine - proves the gate IS the concession.
	GameState.set_flag("mvp_components", ["ai_vec_search_api", "ai_vec_filter"])
	if not SalesRepSystem.is_auto_closable(ProspectRegistry.get_prospect("concession")):
		return "shipping the promised feature did not make the lead routine"
	return ""


static func _case_sales_close_speed_by_expertise() -> String:
	# TWO-DIRECTIONAL: higher UZMANLIK closes a routine lead in strictly fewer days.
	GameState.set_flag("mvp_sub_product_type_id", "ai_vector_search")
	_seed_b2b(1000)
	GameState.set_flag("mvp_components", ["ai_vec_filter"])
	var weak: Character = _make_sales_rep("char_sr_weak", 0, 2)
	_add_prospect("slow", "small", "ai_vec_filter")
	var slow_days: int = 0
	for i in 200:
		GameState.advance_day()
		B2BSalesSystem.daily_tick()
		slow_days += 1
		if ProspectRegistry.get_prospect("slow") == null:
			break
	if ProspectRegistry.get_prospect("slow") != null:
		return "the weak rep never closed a routine lead"
	CharacterRegistry.remove(weak.id)
	_make_sales_rep("char_sr_strong", 0, 9)
	_add_prospect("fast", "small", "ai_vec_filter")
	var fast_days: int = 0
	for i in 200:
		GameState.advance_day()
		B2BSalesSystem.daily_tick()
		fast_days += 1
		if ProspectRegistry.get_prospect("fast") == null:
			break
	if ProspectRegistry.get_prospect("fast") != null:
		return "the strong rep never closed a routine lead"
	if fast_days >= slow_days:
		return "UZMANLIK did not speed the close (weak=%d days, strong=%d days)" % [slow_days, fast_days]
	return ""


static func _case_sales_overtime_multiplier() -> String:
	# Sales overtime finally BUYS something. Before task 2b a Satis block cost cash and morale
	# and raised nothing: speed_multiplier was only ever read with DEPT_PRODUCT_DEV.
	GameState.set_flag("mvp_sub_product_type_id", "ai_vector_search")
	_seed_b2b(1000)
	_make_sales_rep("char_sr_1", 6, 5)
	var base_rate: float = SalesRepSystem.lead_rate_per_day()
	HROvertimeSystem.start(HRConstants.DEPT_SALES, HRConstants.OVERTIME_BLOCKS[0])
	var mult: float = HROvertimeSystem.speed_multiplier(HRConstants.DEPT_SALES)
	if is_equal_approx(mult, 1.0):
		return "starting a sales overtime block produced no multiplier"
	if not is_equal_approx(SalesRepSystem.lead_rate_per_day(), base_rate * mult):
		return "lead rate %f, want base %f x overtime %f" % [
			SalesRepSystem.lead_rate_per_day(), base_rate, mult]
	HROvertimeSystem.stop(HRConstants.DEPT_SALES)
	if not is_equal_approx(SalesRepSystem.lead_rate_per_day(), base_rate):
		return "the lead rate stayed raised after the block stopped"
	return ""


static func _case_cs_auto_assignment_capacity() -> String:
	# Delegation is EXCESS-driven: under FOUNDER_DIRECT_CAP nothing moves; above it the
	# overflow goes over, bounded by cs_capacity(HIZ). Leave releases the roster.
	GameState.set_flag("mvp_sub_product_type_id", "ai_vector_search")
	_seed_b2b(1000)
	var rep: Character = _make_cs_rep("char_cs_1", 9, 5)
	for i in B2BConstants.FOUNDER_DIRECT_CAP:
		var p: Prospect = _add_prospect("cap%d" % i, "small", "ai_vec_filter")
		var c: Customer = SalesSystem.add_b2b_customer(p, 300, 70)
		ProspectRegistry.remove(p.id)
		CustomerRegistry.set_lifecycle_phase(c.id, "active")
	CustomerRegistry.set_lifecycle_phase("co_lead_smoke", "active")
	CustomerRepSystem.reconcile_assignments()
	# co_lead_smoke + FOUNDER_DIRECT_CAP more = cap + 1, so exactly ONE hands over.
	var assigned: int = 0
	for c in CustomerRegistry.get_by_market("b2b"):
		if c.assigned_to == rep.id:
			assigned += 1
	if assigned != 1:
		return "expected exactly the 1 excess account delegated, got %d" % assigned
	if B2BSalesSystem.founder_managed_count() != B2BConstants.FOUNDER_DIRECT_CAP:
		return "founder kept %d accounts, want the cap %d" % [
			B2BSalesSystem.founder_managed_count(), B2BConstants.FOUNDER_DIRECT_CAP]
	CharacterRegistry.set_status(rep.id, HRConstants.STATUS_ON_LEAVE)
	CustomerRepSystem.reconcile_assignments()
	for c in CustomerRegistry.get_by_market("b2b"):
		if c.assigned_to != "":
			return "an on-leave rep still holds %s" % c.id
	return ""


static func _case_cs_capacity_resolution() -> String:
	# The dead-symbol sweep, asserted. cs_capacity now reads HIZ and actually spreads; the
	# retired 0-100-scale divisor is gone; FOUNDER_DIRECT_CAP has a live reader.
	if B2BConstants.cs_capacity(0) != B2BConstants.CS_BASE_CAPACITY:
		return "cs_capacity(0) is not the base capacity"
	if B2BConstants.cs_capacity(HRConstants.AXIS_MAX) <= B2BConstants.cs_capacity(0):
		return "cs_capacity does not rise across the ruler (the old /25 bug)"
	var want_top: int = B2BConstants.CS_BASE_CAPACITY + int(
		float(HRConstants.AXIS_MAX) / float(B2BConstants.CS_PACE_PER_SLOT))
	if B2BConstants.cs_capacity(HRConstants.AXIS_MAX) != want_top:
		return "cs_capacity(9) is %d, want %d" % [B2BConstants.cs_capacity(HRConstants.AXIS_MAX), want_top]
	for i in HRConstants.AXIS_MAX:
		if B2BConstants.cs_capacity(i + 1) < B2BConstants.cs_capacity(i):
			return "cs_capacity is not monotone at HIZ %d" % i
	_seed_b2b(1000)
	if B2BSalesSystem.founder_managed_count() != 1:
		return "founder_managed_count does not report the founder book"
	return ""


static func _case_cs_request_absorption_by_expertise() -> String:
	# THE AXIS-SPLIT PROOF: the SAME request is absorbed at one UZMANLIK and escalated one
	# point lower. Difficulty is built so the ceiling lands exactly between the two.
	GameState.set_flag("mvp_sub_product_type_id", "ai_vector_search")
	_seed_b2b(1000)
	var c: Customer = CustomerRegistry.get_customer("co_lead_smoke")
	c.pain_feature_id = "ai_vec_filter"
	GameState.set_flag("mvp_components", [])          # pain UNSHIPPED -> +2
	CustomerRegistry.set_satisfaction(c.id, 20)       # under tolerance -> +2
	var diff: int = CustomerRepSystem.request_difficulty(c)
	var strong_expertise: int = diff - B2BConstants.CS_ABSORB_BASE
	if strong_expertise < 1 or strong_expertise > HRConstants.AXIS_MAX:
		return "difficulty %d cannot be straddled on the 0-9 ruler" % diff
	var strong: Character = _make_cs_rep("char_cs_strong", 9, strong_expertise)
	if CustomerRepSystem.absorb_ceiling() < diff:
		return "the strong rep should absorb difficulty %d (ceiling %d)" % [
			diff, CustomerRepSystem.absorb_ceiling()]
	CustomerRegistry.set_support_request(c.id, GameState.day)
	CustomerRepSystem.daily_tick()
	if c.support_request_since_day >= 0:
		return "the strong rep did not clear the request"
	if _instances_of("ev_b2b_request_%s" % c.id) != 0:
		return "the strong rep escalated a request it should have absorbed"
	CharacterRegistry.remove(strong.id)
	_make_cs_rep("char_cs_weak", 9, strong_expertise - 1)
	CustomerRegistry.set_support_request(c.id, GameState.day)
	CustomerRepSystem.daily_tick()
	if _instances_of("ev_b2b_request_%s" % c.id) == 0:
		return "the weaker rep absorbed a request that should have escalated"
	return ""


static func _case_cs_request_throughput_by_pace() -> String:
	# HIZ is volume: a faster desk clears strictly more, and the surplus QUEUES.
	GameState.set_flag("mvp_sub_product_type_id", "ai_vector_search")
	_seed_b2b(1000)
	GameState.set_flag("mvp_components", ["ai_vec_filter"])
	var slow: Character = _make_cs_rep("char_cs_slow", 0, 9)
	var fast: Character = _make_cs_rep("char_cs_fast", 9, 9)
	if CustomerRepSystem.throughput_of(fast) <= CustomerRepSystem.throughput_of(slow):
		return "HIZ does not raise throughput (%f vs %f)" % [
			CustomerRepSystem.throughput_of(fast), CustomerRepSystem.throughput_of(slow)]
	var want: float = B2BConstants.CS_THROUGHPUT_BASE \
		+ float(HRConstants.AXIS_MAX) * B2BConstants.CS_THROUGHPUT_PER_PACE
	if not is_equal_approx(CustomerRepSystem.throughput_of(fast), want):
		return "throughput %f, want %f" % [CustomerRepSystem.throughput_of(fast), want]
	CharacterRegistry.remove(fast.id)
	var opened: Array[String] = []
	for i in 6:
		var p: Prospect = _add_prospect("thr%d" % i, "small", "ai_vec_filter")
		var c: Customer = SalesSystem.add_b2b_customer(p, 300, 70)
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
	if _instances_of("ev_b2b_request_%s" % c.id) != 0:
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
	# THE ADDITIVITY GATE. With no sales rep and no customer rep, a long run touches none of
	# the new state: no leads, no assignments, no requests, no activity log, no flags.
	GameState.set_flag("mvp_sub_product_type_id", "ai_vector_search")
	_seed_b2b(1000)
	var prospects0: int = ProspectRegistry.count()
	var mrr0: int = GameState.mrr
	for i in 60:
		GameState.advance_day()
		B2BSalesSystem.daily_tick()
	if ProspectRegistry.count() != prospects0:
		return "prospects changed with no sales staff (%d -> %d)" % [prospects0, ProspectRegistry.count()]
	if GameState.mrr != mrr0:
		return "MRR moved with no sales staff (%d -> %d)" % [mrr0, GameState.mrr]
	for c in CustomerRegistry.get_by_market("b2b"):
		if c.assigned_to != "":
			return "an account was delegated with no customer rep on staff"
		if c.support_request_since_day >= 0:
			return "a request opened with no customer rep on staff"
	if not GameState.sales_log.is_empty():
		return "the activity log grew with no desk staff"
	if float(GameState.get_flag("sales_lead_progress", 0.0)) != 0.0:
		return "the lead accumulator advanced with no sales staff"
	if float(GameState.get_flag("cs_throughput_progress", 0.0)) != 0.0:
		return "the throughput accumulator advanced with no customer rep"
	return ""


static func _case_prospect_id_unique_after_removal() -> String:
	# Regression: prospect ids were built off ProspectRegistry.count(), which DROPS when a lead
	# is signed or lost, so a same-day respawn rebuilt an existing id, ProspectRegistry.add
	# warned, and the lead was silently discarded while spawn_prospect still returned it.
	GameState.set_flag("mvp_shipped", true)
	GameState.set_flag("mvp_market_type", "b2b")
	GameState.set_flag("mvp_sub_product_type_id", "ai_vector_search")
	var a: Prospect = PitchSystem.spawn_prospect("small", "test")
	ProspectRegistry.remove(a.id)
	var b: Prospect = PitchSystem.spawn_prospect("small", "test")   # SAME day, count back to 0
	if a.id == b.id:
		return "same-day respawn reused the id %s" % a.id
	if ProspectRegistry.get_prospect(b.id) == null:
		return "the respawned lead was not registered (silently dropped)"
	if ProspectRegistry.count() != 1:
		return "registry holds %d prospects, want 1" % ProspectRegistry.count()
	return ""


# ============ Dünya İnandırıcılığı (şirket havuzu + dedup) ======================

static func _case_b2b_prospect_dedup_excludes_signed() -> String:
	# Fix 1: a SIGNED company never re-enters cold prospecting (churn included), live
	# leads hold distinct names, and an exhausted catalog returns null without burning
	# the id counter or registering anything.
	GameState.set_flag("mvp_sub_product_type_id", "ai_vector_search")
	# Sign the first spawned company through the real path (the pitch SIGNED sequence).
	var first: Prospect = PitchSystem.spawn_prospect("small", "find")
	if first == null:
		return "fresh run spawned null"
	var signed_name: String = first.company_name
	var c: Customer = SalesSystem.add_b2b_customer(first, 400, 70)
	ProspectRegistry.remove(first.id)
	if not GameState.b2b_signed_company_names.has(signed_name):
		return "ledger missed the signed name"
	# Drain the whole affinity pool. Expected supply derives from the catalog (owning
	# source, never a literal): every company in the pool's sectors minus the signed one.
	var expected: int = 0
	for s in B2BConstants.sector_pool("ai_vector_search"):
		expected += CompanyCatalog.names_for_sector(String(s)).size()
	expected -= 1
	var names_seen: Dictionary = {}
	for i in expected + 10:
		var p: Prospect = PitchSystem.spawn_prospect("small", "find")
		if p == null:
			break
		if p.company_name == signed_name:
			return "signed company respawned as a prospect: %s" % signed_name
		if names_seen.has(p.company_name):
			return "duplicate live prospect name: %s" % p.company_name
		names_seen[p.company_name] = true
	if names_seen.size() != expected:
		return "drained %d distinct names, want %d" % [names_seen.size(), expected]
	if PitchSystem.eligible_company_count() != 0:
		return "pool drained but eligible_company_count()=%d" % PitchSystem.eligible_company_count()
	var live_before: int = ProspectRegistry.count()
	var counter_before: int = GameState.run_prospects_spawned
	if PitchSystem.spawn_prospect("small", "find") != null:
		return "spawn returned a lead from an exhausted pool"
	if ProspectRegistry.count() != live_before:
		return "null spawn registered a lead anyway"
	if GameState.run_prospects_spawned != counter_before:
		return "null spawn burned the id counter"
	# Churn the signed account (shared loss seam) — the name must STAY excluded: churned
	# companies return through a future win-back path, never through cold prospecting.
	B2BSalesSystem._remove_lost(c)
	if CustomerRegistry.get_customer(c.id) != null:
		return "churn did not remove the customer record"
	if PitchSystem.eligible_company_count() != 0:
		return "churn re-opened cold prospecting for the signed name"
	if PitchSystem.spawn_prospect("small", "find") != null:
		return "churned company respawned as a prospect"
	return ""


static func _case_company_catalog_pool_integrity() -> String:
	# Fix 2: >= 60 companies, every canonical sector populated, globally unique names,
	# a non-empty background line per record, and every sector any affinity pool can
	# request resolves to at least one company (the old 4-sector fallback hole).
	var all_companies: Array = CompanyCatalog.all()
	if all_companies.size() < 60:
		return "catalog holds %d companies, want >= 60" % all_companies.size()
	var seen: Dictionary = {}
	for rec in all_companies:
		var nm: String = String(rec["name"])
		if seen.has(nm):
			return "duplicate company name: %s" % nm
		seen[nm] = true
		if String(rec["background"]).strip_edges() == "":
			return "empty background line: %s" % nm
		if CompanyCatalog.background_for(nm) == "":
			return "background_for() returned empty for %s" % nm
	var counts: Dictionary = CompanyCatalog.count_by_sector()
	for sector in B2BConstants.SECTOR_CONTACT:   # the 13-sector canon
		if int(counts.get(sector, 0)) < 4:
			return "sector %s holds %d companies, want >= 4" % [sector, int(counts.get(sector, 0))]
	var pools: Array = []
	for sub_id in B2BConstants.SECTOR_AFFINITY:
		pools.append(B2BConstants.sector_pool(String(sub_id)))
	pools.append(B2BConstants.SECTOR_AFFINITY_FALLBACK)
	for pool in pools:
		for s in pool:
			if CompanyCatalog.names_for_sector(String(s)).is_empty():
				return "affinity sector %s resolves to zero companies" % s
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
	p.industry = "Testing"
	p.archetype = "mid"
	SalesSystem.add_b2b_customer(p, 30000, 70)
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
		EventBus.headline_added.emit(B2BConstants.NOTICE_SOURCE_SALES, "Smoke kapanışı %d" % i)
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
	a.industry = "Teknoloji"
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
	b.industry = "Finans"
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
	c.industry = "Medya"
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
	GameState.net_history_90.append(42)             # Array[int] tipli kalmalı

	# Sentetik event: hiçbir JSON dosyasında yok, id'den geri kurulamaz. Altı
	# speaker_* alanı bilerek dolu — _build_event_from_dict bunları hiç okumuyordu.
	var ev := GameEvent.new()
	ev.id = "ev_smoke_synthetic"
	ev.title = "Sentetik"
	ev.speaker_name = "Smoke Corp"
	ev.speaker_role = "Satin alma"
	ev.speaker_status = "RISK ALTINDA"
	ev.speaker_status_kind = "negative"
	ev.speaker_initial = "SC"
	ev.speaker_chips = [{"text": "cip", "kind": "neutral"}]
	var ch := EventChoice.new()
	ch.label = "Secenek"
	ev.choices.append(ch)
	EventManager._queue.append(ev)


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
	if GameState.net_history_90.get_typed_builtin() != TYPE_INT:
		_cleanup_save_slots()
		return "net_history_90 lost its Array[int] typing"

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

	# Sentetik event, altı speaker_* alanı ve iç içe EventChoice ile döndü mü?
	var found: GameEvent = null
	for e in EventManager._queue:
		if e.id == "ev_smoke_synthetic":
			found = e
	if found == null:
		_cleanup_save_slots()
		return "synthetic queued event did not survive the round-trip"
	if found.speaker_name != "Smoke Corp" or found.speaker_status_kind != "negative" \
			or found.speaker_chips.size() != 1:
		_cleanup_save_slots()
		return "synthetic event lost its speaker_* fields"
	if found.choices.size() != 1 or not (found.choices[0] is EventChoice):
		_cleanup_save_slots()
		return "synthetic event lost its nested EventChoice"

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

	# Tohum artık okunabilir durum (audit S2-40: dört canlı koşuda bir kez alınamadı).
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
# Terminal UI görevi §4. Beşi de MEKANİĞİ ölçer, ekranı değil: sayılar
# HRConstants'ta WORKING ve değişebilir, ama SÖZLEŞME değişmemeli.

static func _case_hr_experience_accrues() -> String:
	GameState.set_cash(100000)
	var emp: Character = _make_employee("char_xp_a", "XP A", HRConstants.ROLE_DEVELOPER)
	if emp.experience != 0:
		return "fresh employee started at experience %d, want 0" % emp.experience
	_sim_day()
	var after_one: int = emp.experience
	if after_one != HRConstants.EXPERIENCE_PER_DAY:
		return "after one idle day experience is %d, want %d" % [after_one, HRConstants.EXPERIENCE_PER_DAY]
	# İZİNDEKİ biri BİRİKTİRMEZ — edilgenlik gerçekten edilgen olmalı.
	# İzin GERÇEKTEN sürmeli: tick_leave_returns, leave_until_day geçmişse kişiyi
	# günün başında aktife çeker ve çıplak bir set_status ölçümü geçersiz kılar.
	CharacterRegistry.set_status(emp.id, HRConstants.STATUS_ON_LEAVE)
	emp.leave_until_day = GameState.day + 10
	_sim_day()
	if emp.experience != after_one:
		return "an ON-LEAVE employee accrued experience (%d -> %d)" % [after_one, emp.experience]
	emp.leave_until_day = 0
	CharacterRegistry.set_status(emp.id, HRConstants.STATUS_ACTIVE)
	# Tavanı aşmaz.
	CharacterRegistry.add_experience(emp.id, HRConstants.EXPERIENCE_MAX * 2)
	if emp.experience != HRConstants.EXPERIENCE_MAX:
		return "experience clamped to %d, want %d" % [emp.experience, HRConstants.EXPERIENCE_MAX]
	return ""


static func _case_hr_training_eligibility_edge() -> String:
	# TAM 100'de uygun, 99'da DEĞİL. Eşiğin kendisi sözleşmenin parçası.
	GameState.set_cash(100000)
	var emp: Character = _make_employee("char_xp_b", "XP B", HRConstants.ROLE_DESIGNER)
	CharacterRegistry.add_experience(emp.id, HRConstants.EXPERIENCE_MAX - 1)
	if CharacterRegistry.can_train(emp.id):
		return "eligible at %d, one short of the threshold" % emp.experience
	CharacterRegistry.add_experience(emp.id, 1)
	if not CharacterRegistry.can_train(emp.id):
		return "NOT eligible at exactly %d" % HRConstants.EXPERIENCE_MAX
	# İzindeyken uygun olmamalı: eğitim aktif bir karardır.
	CharacterRegistry.set_status(emp.id, HRConstants.STATUS_ON_LEAVE)
	if CharacterRegistry.can_train(emp.id):
		return "an ON-LEAVE employee was eligible for training"
	return ""


static func _case_hr_training_blocks_and_charges_once() -> String:
	GameState.set_cash(100000)
	var emp: Character = _make_employee("char_xp_c", "XP C", HRConstants.ROLE_DEVELOPER)
	CharacterRegistry.add_experience(emp.id, HRConstants.EXPERIENCE_MAX)
	var cash_before: int = GameState.cash
	if not HRSystem.send_to_training(emp.id):
		return "send_to_training refused an eligible employee"
	if GameState.cash != cash_before - HRConstants.TRAINING_FEE:
		return "fee charged %d, want %d" % [cash_before - GameState.cash, HRConstants.TRAINING_FEE]
	if emp.status != HRConstants.STATUS_TRAINING:
		return "status is '%s', want '%s'" % [emp.status, HRConstants.STATUS_TRAINING]
	# ÇIKTI ÜRETMEZ: aktif listede olmamalı (kapasite, hız, SORUMLU hepsi buradan okur).
	for a in CharacterRegistry.get_active_employees():
		if a.id == emp.id:
			return "a TRAINING employee is still in get_active_employees()"
	# İkinci kez gönderilemez, yani ücret iki kez alınamaz.
	var cash_mid: int = GameState.cash
	if HRSystem.send_to_training(emp.id):
		return "send_to_training accepted an already-training employee"
	if GameState.cash != cash_mid:
		return "a second call charged again (%d -> %d)" % [cash_mid, GameState.cash]
	return ""


static func _case_hr_training_completion() -> String:
	GameState.set_cash(100000)
	var emp: Character = _make_employee("char_xp_d", "XP D", HRConstants.ROLE_TESTER, 5, 0, 50, 4)
	CharacterRegistry.add_experience(emp.id, HRConstants.EXPERIENCE_MAX)
	var expertise_before: int = int(emp.role_stats[HRConstants.AXIS_EXPERTISE])
	if not HRSystem.send_to_training(emp.id):
		return "send_to_training refused an eligible employee"
	for i in HRConstants.TRAINING_DAYS:
		if emp.status != HRConstants.STATUS_TRAINING:
			return "left training early on day %d" % i
		_sim_day()
	if emp.status != HRConstants.STATUS_ACTIVE:
		return "after %d days status is '%s', want active" % [HRConstants.TRAINING_DAYS, emp.status]
	var expertise_after: int = int(emp.role_stats[HRConstants.AXIS_EXPERTISE])
	if expertise_after != expertise_before + 1:
		return "expertise %d -> %d, want +1" % [expertise_before, expertise_after]
	if emp.experience != 0:
		return "experience did not reset (%d)" % emp.experience
	return ""


static func _case_hr_expertise_cap_respected() -> String:
	# Tavandaki biri eğitime GÖNDERİLEMEZ. Ücreti alıp hiçbir şey vermemek §10'un
	# yasakladığı şeyin aynası olurdu.
	GameState.set_cash(100000)
	var emp: Character = _make_employee("char_xp_e", "XP E", HRConstants.ROLE_DEVELOPER,
		5, 0, 50, HRConstants.EXPERTISE_CAP)
	CharacterRegistry.add_experience(emp.id, HRConstants.EXPERIENCE_MAX)
	if CharacterRegistry.can_train(emp.id):
		return "an employee already at the expertise cap (%d) was eligible" % HRConstants.EXPERTISE_CAP
	var cash_before: int = GameState.cash
	if HRSystem.send_to_training(emp.id):
		return "send_to_training accepted a capped employee"
	if GameState.cash != cash_before:
		return "a refused training still charged the fee"
	# Bir altındaki biri gönderilebilir ve tavanı AŞMAZ.
	var emp2: Character = _make_employee("char_xp_f", "XP F", HRConstants.ROLE_DEVELOPER,
		5, 0, 50, HRConstants.EXPERTISE_CAP - 1)
	CharacterRegistry.add_experience(emp2.id, HRConstants.EXPERIENCE_MAX)
	if not HRSystem.send_to_training(emp2.id):
		return "an employee one below the cap was refused"
	for _i in HRConstants.TRAINING_DAYS:
		_sim_day()
	var final_expertise: int = int(emp2.role_stats[HRConstants.AXIS_EXPERTISE])
	if final_expertise != HRConstants.EXPERTISE_CAP:
		return "expertise landed at %d, want the cap %d" % [final_expertise, HRConstants.EXPERTISE_CAP]
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
		if row.size() < 3:
			return "%s has %d columns, wants 3" % [key, row.size()]
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
