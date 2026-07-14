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
		"sheet_expiry_no_rejection": fail = _case_sheet_expiry_no_rejection()
		"third_sheet_delayed":  fail = _case_third_sheet_delayed()
		"cascade_defer_with_sheet": fail = _case_cascade_defer_with_sheet()
		"walk_counts_rejection": fail = _case_walk_counts_rejection()
		"prep_bonus_and_capacity": fail = _case_prep_bonus_and_capacity()
		"meeting_daylock":      fail = _case_meeting_daylock()
		"pivot_closes_hunt":    fail = _case_pivot_closes_hunt()
		"meeting_during_kepenk": fail = _case_meeting_during_kepenk()
		_:                      fail = "unknown case"

	if fail == "":
		print("SMOKE PASS %s" % case_name)
	else:
		print("SMOKE FAIL %s: %s" % [case_name, fail])


# --- Day driver + seeds ---

static func _sim_day() -> void:
	GameState.advance_day()
	TimeManager._dispatch_daily_tick()


static func _seed_b2b(mrr: int) -> void:
	GameState.set_flag("mvp_shipped", true)
	GameState.set_flag("mvp_market_type", "b2b")
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
	GameState.set_flag("mvp_usability", 22.0)
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
	# 10 gün: saatlik ekonomi + günlük slotlar (_sim_day yalnız daily koşar —
	# audience/wear saatlik akar, o yüzden saat döngüsü şart).
	for d in 10:
		for h in 24:
			TimeManager._dispatch_hourly_tick(h)
		_sim_day()
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
	ProductSystem.enter_development()
	for i in 24 * 40:
		ProductSystem.hourly_tick(i % 24)   # dev tamamlanır + beta kurur
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
	if CharacterRegistry.count_engineers() != 0:
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
	if not ProductSystem.start_version_build(["ai_assistant_voice"], "founder"):
		return "v-build blocked during sprint (guard not removed)"
	ProductSystem.enter_development()
	var e0: float = ProductSystem.get_active_build().development_days_elapsed
	s0 = float(GameState.get_flag("mvp_sprint_days_elapsed", 0.0))
	for h in 24:
		ProductSystem.hourly_tick(h)
	var db: float = ProductSystem.get_active_build().development_days_elapsed - e0
	var ds: float = float(GameState.get_flag("mvp_sprint_days_elapsed", 0.0)) - s0
	if absf(db - 0.5) > 0.02:
		return "build not half speed (%.3f day/day)" % db
	if absf(ds - 0.5) > 0.02:
		return "sprint not half speed (%.3f day/day)" % ds
	# 3) Mid-job hire → kapasite 2 → her iki iş anında tam hıza döner.
	var eng := Character.new()
	eng.id = "char_smoke_capacity_eng"
	eng.character_name = "Smoke Eng"
	eng.role = "Engineer"
	eng.category = "employee"
	CharacterRegistry.add(eng)
	e0 = ProductSystem.get_active_build().development_days_elapsed
	s0 = float(GameState.get_flag("mvp_sprint_days_elapsed", 0.0))
	for h in 24:
		ProductSystem.hourly_tick(h)
	db = ProductSystem.get_active_build().development_days_elapsed - e0
	ds = float(GameState.get_flag("mvp_sprint_days_elapsed", 0.0)) - s0
	if absf(db - 1.0) > 0.02:
		return "build did not recover to full speed (%.3f day/day)" % db
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
	var emp := Character.new()
	emp.id = "char_month_smoke_emp"
	emp.character_name = "Smoke Hire"
	emp.role = "Engineer"
	emp.category = "employee"
	CharacterRegistry.add(emp)
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
	GameState.set_flag("mvp_bug_count", 5)   # product interrogation + callback not-yet-met
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
	GameState.set_flag("mvp_bug_count", 1)   # satisfy: bugs under target
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
