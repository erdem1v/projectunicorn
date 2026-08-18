class_name RunProbe
extends RefCounted

# Headless RUN LOG harness — Playable Run Sprint Step 0a (event fire log), Step 0b
# (churn-chain autopsy) and Step 4 (the played run). Debug builds only; invoked by
# main.gd when the run args contain --run-log=<preset>:<days>:<mode>.
#
# WHAT IT IS: the probe is "the player". It mounts no shell and no modals — it drives
# the real tick dispatch and answers every decision through the same seam the modal
# calls (EventManager.resolve_choice), so the engine cannot tell it apart from a human
# except by the choice policy, which is deterministic and printed.
#
# WHY IT IS NOT A SMOKE CASE: the smoke suite asserts one proposition per process and
# says PASS/FAIL. This says nothing about right or wrong — it EMITS A LEDGER (every
# event fire with its source, every choice, daily economy state) that a human reads to
# find out what the game actually does over 60-90 days. Step 0's triage bins and Step 4's
# fire table are both scraped from this output.
#
# TWO DRIVE MODES, and the difference is the point:
#   sim   — drives TimeManager's dispatch directly (hour 1..23 → hour 0 → advance_day →
#           daily), no wall clock. Deterministic, instant, exact slot attribution. This
#           is what the fire tables are built from.
#   1|2|3|4 — the REAL clock at that speed index, exactly as a player experiences it
#           (TimeManager._drain_boundaries, frame pacing and all). Slower but honest;
#           this is the only mode that can catch a real-time-only defect such as the
#           ≤1-ambient-per-day throttle leaking across the hour-0 rollover
#           (event_manager.gd:98). Step 4's played run uses mode 4.
#
# Output contract — one line per record, all prefixed PROBE so a grep separates them
# from the engine's own [EventManager] chatter:
#   PROBE BEGIN preset=<p> days=<n> mode=<m> seed=<s>
#   PROBE FIRE  day=<d> hour=<h> id=<id> src=<src>
#   PROBE PICK  day=<d> id=<id> choice=<i> label=<label>
#   PROBE STATE day=<d> cash=<n> mrr=<n> brand=<n> burn=<n> runway=<f> cust=<n> emp=<n> promises=<n>
#   PROBE CHURN day=<d> id=<cid> ...        (customer_churned — the autopsy's terminal)
#   PROBE PROMISE day=<d> id=<pid> status=<s> ...
#   PROBE TALLY <id> fires=<n> picks=<n>    (one per id, at the end)
#   PROBE END   day=<d> ...
#
# DEDUPE-REJECTED fires are NOT visible here — enqueue() returns silently when
# _queue_has_id() rejects a duplicate. They are counted from the engine's own
# "[EventManager] Dedupe-rejected: <id>" debug line, which is why that print exists.

const PRESETS := ["b2b_reps", "b2b_solo", "b2b_risk", "b2b_risk_keep",
	"b2b_slip", "b2b_slip_keep", "b2c", "full_run"]

# Deterministic answer policy, per id prefix. Absent → choice 0. A locked choice is
# never picked (the probe re-runs the modal's own gate, see _pick_choice), so a policy
# index pointing at a locked row falls through to the first unlocked one.
#
# The retention row is 0 on purpose: "Söz ver" is choice 0 when the customer's pain
# feature is unshipped (b2b_event_factory.gd:41-47), and driving promises is the whole
# point of Step 0b. When it is absent the same index lands on the next row, which the
# PICK line records by label so the log never has to be guessed at.
const CHOICE_POLICY := {
	"ev_b2b_retain_": 0,
	"ev_b2b_request_": 0,
	"ev_b2b_escalation_": 0,
	"ev_b2b_expand_": 0,
	"ev_phase_gate_": 0,
	"ev_mvp_": 0,
}

# id → the injector that built it. Everything not in _all_events is code-built, and
# one of these prefixes owns it. Kept here rather than in the engine because it is a
# READING aid, not a fact the game needs about itself.
const SOURCE_MAP := {
	"ev_b2b_retain_": "factory:b2b_sales_system:203 (retention)",
	"ev_b2b_expand_": "factory:b2b_sales_system:242 (expansion)",
	"ev_b2b_escalation_": "factory:b2b_sales_system:170 (cs_escalation)",
	"ev_b2b_request_": "factory:customer_rep_system:308 (cs_request)",
	"ev_hr_resign_": "factory:hr_morale_system:498 (resignation)",
	"ev_hr_valve_": "factory:hr_overtime_system:373 (overtime_valve)",
	"ev_hr_calm_stretch": "factory:hr_morale_system:526 (calm)",
	"ev_hr_big_signing": "factory:hr_morale_system:526 (big_signing)",
	"ev_hr_ship_glow": "factory:hr_morale_system:526 (ship_glow)",
	"ev_mvp_ship_moment": "factory:product_system:1266 (ship)",
	"ev_mvp_version_ship_moment": "factory:product_system:1266 (version_ship)",
	"ev_mvp_iter_decision_intro": "factory:product_system:615 (iter_intro)",
	"ev_phase_gate_": "factory:phase_gate_system:130 (gate)",
	"ev_angel_frank_seed": "factory:angel_round_system (seed offer)",
	"ev_angel_hire_nudge": "factory:angel_round_system (hire nudge)",
	"ev_shutter_warning": "factory:endings_system:118 (shutter)",
	"ev_pivot_offer": "factory:endings_system:169 (pivot)",
	"ev_acquisition_offer": "factory:endings_system:224 (acquisition)",
}

static var _fires: Dictionary = {}      # id -> fire count
static var _picks: Dictionary = {}      # id -> resolve count
static var _stop_day: int = 0
static var _preset: String = ""
static var _mode: String = ""
static var _wired: bool = false
static var _build_promises: bool = false   # presets ending "_keep": the founder builds what he promised
static var _full_run: bool = false         # "full_run": day 1, nothing seeded, the founder plays it
static var _hire_started: bool = false


# ============================================================================
#  Entry
# ============================================================================

static func run(spec: String, payload: Dictionary) -> void:
	# spec = "<preset>:<days>:<mode>", e.g. "b2b_solo:90:sim" or "b2c:60:4".
	var parts: PackedStringArray = spec.split(":", false)
	if parts.size() < 2:
		print("PROBE ERROR bad spec '%s' (want <preset>:<days>[:<mode>])" % spec)
		return
	_preset = String(parts[0])
	_stop_day = int(parts[1])
	_mode = String(parts[2]) if parts.size() > 2 else "sim"
	if not PRESETS.has(_preset):
		print("PROBE ERROR unknown preset '%s' (have %s)" % [_preset, ", ".join(PRESETS)])
		return

	_fires.clear()
	_picks.clear()
	_full_run = false
	_hire_started = false
	_build_promises = false
	GameState.initialize_run(payload)
	# Pin the seed so two probe runs of the same preset are comparable line for line —
	# the same reason --tempo-probe pins it (main.gd:327-331). initialize_run seeds from
	# Time.get_ticks_msec(), which would make every fire table a one-off.
	GameState.run_seed = 424242
	seed(GameState.run_seed)
	RngStreams.reseed(GameState.run_seed)   # the named streams, not just the global generator
	_wire_log()
	_seed_world(_preset)

	print("PROBE BEGIN preset=%s days=%d mode=%s seed=%d" % [_preset, _stop_day, _mode, GameState.run_seed])
	_log_state()

	if _mode == "sim":
		_run_sim()
	else:
		_run_realtime(int(_mode))


# ============================================================================
#  Logging seams
# ============================================================================

static func _wire_log() -> void:
	if _wired:
		return
	_wired = true
	# event_triggered fires on EVERY queue entry — the JSON pool's _enqueue_eligible AND
	# all 21 enqueue/enqueue_front injectors. That is why it, and not _history (which
	# only resolve_choice writes), is the fire log's source.
	EventBus.event_triggered.connect(_on_fire)
	EventBus.customer_churned.connect(_on_churn)
	EventBus.promise_created.connect(func(pid: String) -> void: _log_promise(pid, "created"))
	EventBus.promise_kept.connect(func(pid: String) -> void: _log_promise(pid, "resolved"))
	EventBus.promise_broken.connect(func(pid: String) -> void: _log_promise(pid, "resolved"))


static func _on_fire(event_id: String) -> void:
	_fires[event_id] = int(_fires.get(event_id, 0)) + 1
	print("PROBE FIRE day=%d hour=%d id=%s src=%s" % [
		GameState.day, GameState.current_hour, event_id, _source_of(event_id)])


static func _source_of(event_id: String) -> String:
	if EventManager._all_events.has(event_id):
		return "pool"
	for prefix in SOURCE_MAP.keys():
		if event_id.begins_with(prefix):
			return String(SOURCE_MAP[prefix])
	return "factory:UNMAPPED"


static func _on_churn(customer_id: String) -> void:
	# The autopsy's terminal line. Read BEFORE CustomerRegistry.remove() runs (the signal
	# is emitted first — b2b_sales_system.gd:269-271), so the record is still readable.
	var c: Customer = CustomerRegistry.get_customer(customer_id)
	if c == null:
		print("PROBE CHURN day=%d id=%s (record already gone)" % [GameState.day, customer_id])
		return
	print("PROBE CHURN day=%d id=%s sat=%d tol=%d trust=%.1f phase=%s streak=%d countdown=%d mrr=%d" % [
		GameState.day, customer_id, c.satisfaction, c.tolerance, c.trust_offset,
		c.lifecycle_phase, c.risk_streak, c.churn_countdown, c.mrr])


static func _log_promise(promise_id: String, stage: String) -> void:
	var p: Promise = PromiseRegistry.get_promise(promise_id)
	if p == null:
		return
	var c: Customer = CustomerRegistry.get_customer(p.customer_id)
	var sat: int = c.satisfaction if c != null else -1
	var tol: int = c.tolerance if c != null else -1
	var cd: int = c.churn_countdown if c != null else -99
	var ph: String = c.lifecycle_phase if c != null else "(gone)"
	print("PROBE PROMISE day=%d stage=%s id=%s status=%s feature=%s deadline=%d cust=%s sat=%d tol=%d countdown=%d phase=%s" % [
		GameState.day, stage, promise_id, p.status, p.feature_id, p.deadline_day,
		p.customer_id, sat, tol, cd, ph])


static func _log_state() -> void:
	var runway: float = GameState.get_runway_months()
	print("PROBE STATE day=%d cash=%d mrr=%d brand=%d burn=%d runway=%s cust=%d emp=%d promises=%d phase=%d" % [
		GameState.day, GameState.cash, GameState.mrr, GameState.brand, GameState.daily_burn,
		("INF" if is_inf(runway) else "%.2f" % runway),
		CustomerRegistry.get_all().size(), CharacterRegistry.get_employees().size(),
		PromiseRegistry.get_all().size(), GameState.phase])


static func _log_customers() -> void:
	# The churn autopsy's raw material. TARGET is the number the whole B2B book drifts
	# toward — QualityModel.axis_score(economy_dims_from_flags(), "stability") + trust_offset
	# (b2b_sales_system.gd:96-106) — and it is printed beside satisfaction and tolerance
	# because "why did nobody slide" and "why did everybody slide" are the same question
	# asked of these three numbers.
	var health: float = QualityModel.axis_score(QualityModel.economy_dims_from_flags(), "stability")
	for c in CustomerRegistry.get_by_market("b2b"):
		print("PROBE CUST day=%d id=%s sat=%d tol=%d target=%d trust=%.1f phase=%s streak=%d cd=%d mrr=%d bugs=%d" % [
			GameState.day, c.id, c.satisfaction, c.tolerance,
			clampi(int(round(health + c.trust_offset)), 0, 100), c.trust_offset,
			c.lifecycle_phase, c.risk_streak, c.churn_countdown, c.mrr,
			int(GameState.get_flag("mvp_live_bug_count", 0))])


static func _log_tally() -> void:
	var ids: Array = _fires.keys()
	ids.sort()
	print("PROBE TALLY_BEGIN")
	for id in ids:
		print("PROBE TALLY %s fires=%d picks=%d src=%s" % [
			id, int(_fires[id]), int(_picks.get(id, 0)), _source_of(String(id))])
	print("PROBE TALLY_END")


# ============================================================================
#  The player: drain every modal the engine puts up
# ============================================================================

static func _drain_modals() -> void:
	# resolve_choice() ends in _pump_queue(), which mounts the next event synchronously —
	# so this loop walks the whole queue. The guard is a runaway backstop, not a cap: if
	# it ever trips, that IS a finding (an event re-queueing itself inside its own
	# resolution) and it says so instead of hanging the probe.
	var guard: int = 0
	while EventManager._active_event_id != "":
		guard += 1
		if guard > 64:
			print("PROBE ERROR drain guard tripped at day %d on id=%s — an event is re-queueing inside its own resolution" % [
				GameState.day, EventManager._active_event_id])
			return
		var id: String = EventManager._active_event_id
		var ev: GameEvent = EventManager._active_event
		if ev == null:
			print("PROBE ERROR active id=%s with null event object" % id)
			return
		var idx: int = _pick_choice(ev)
		if idx < 0:
			print("PROBE ERROR day=%d id=%s has NO unlocked choice — the player would be stuck" % [GameState.day, id])
			return
		var label: String = ev.choices[idx].label
		print("PROBE PICK day=%d id=%s choice=%d label=%s" % [GameState.day, id, idx, label])
		_picks[id] = int(_picks.get(id, 0)) + 1
		EventManager.resolve_choice(id, idx)


# Retention preference, BY MODIFIER TYPE rather than by row index or label. Index is wrong
# because the card's rows are conditional (the promise row vanishes once the pain feature
# ships, so "choice 0" silently becomes a different decision); label is wrong because labels
# are player-facing text. Order = strongest genuine rescue first: a promise and a discount
# both run _recover, a stall only postpones twice, and ignoring is a documented no-op.
#
# This is the probe PLAYING COMPETENTLY, and it matters for what the log proves: picking
# index 0 blindly had it answer "Oyala" on every post-delivery risk card, so the run
# measured a bad player rather than the engine.
const RETAIN_PREFERENCE := ["b2b_promise_create", "b2b_retain_discount", "b2b_retain_delay", "b2b_retain_ignore"]


static func _pick_choice(ev: GameEvent) -> int:
	# Runs the modal's OWN gate (EventManager.is_condition_met on unlock_condition —
	# event_modal.gd:330), not a mirror of it, so the probe can never pick a row a human
	# is forbidden to click.
	if ev.id.begins_with("ev_b2b_retain_"):
		for want_type in RETAIN_PREFERENCE:
			for idx in ev.choices.size():
				if not EventManager.is_condition_met(ev.choices[idx].unlock_condition):
					continue
				for m in ev.choices[idx].modifiers:
					if String(m.get("type", "")) == want_type:
						return idx
	# Policy index first, then the first unlocked row after it.
	var want: int = 0
	for prefix in CHOICE_POLICY.keys():
		if ev.id.begins_with(prefix):
			want = int(CHOICE_POLICY[prefix])
			break
	var first_unlocked: int = -1
	for offset in ev.choices.size():
		var idx: int = (want + offset) % ev.choices.size()
		if EventManager.is_condition_met(ev.choices[idx].unlock_condition):
			first_unlocked = idx
			break
	if first_unlocked < 0:
		return -1

	# AFFORDABILITY. The preferred row is taken only if the founder can plausibly pay for
	# it; otherwise the cheapest unlocked row wins. Without this the probe answers every
	# B2C card with its paid option and goes bankrupt on principle: the live pool's cash
	# choices are −$1,500 (bug refund), −$800 (launch push) and −$600 (power-user piece)
	# against an opening balance of $10,000, so three refunds and three launches are most
	# of the company. A founder watching that balance does not do this; neither should the
	# thing standing in for one.
	var budget: float = float(maxi(GameState.cash, 0)) * AFFORDABLE_FRACTION
	if float(-_cash_delta_of(ev.choices[first_unlocked])) <= budget:
		return first_unlocked
	var best: int = first_unlocked
	var best_cost: int = -_cash_delta_of(ev.choices[first_unlocked])
	for idx in ev.choices.size():
		if not EventManager.is_condition_met(ev.choices[idx].unlock_condition):
			continue
		var cost: int = -_cash_delta_of(ev.choices[idx])
		if cost < best_cost:
			best_cost = cost
			best = idx
	return best


# Fraction of the current balance the founder will spend on any single event choice.
const AFFORDABLE_FRACTION := 0.12

# Mirrors of sales_tab.gd's "Aday bul" button (that file is a scene script with no
# class_name, so its constants cannot be referenced — a drift here is a real risk and the
# reason both numbers are named rather than inlined at the call site).
const FIND_PROSPECTS_COOLDOWN_DAYS := 5
const FIND_PROSPECTS_COUNT := 2


static func _cash_delta_of(choice: EventChoice) -> int:
	var total: int = 0
	for m in choice.modifiers:
		if String(m.get("type", "")) == "cash":
			total += int(m.get("delta", 0))
	return total


# ============================================================================
#  Drive mode: sim (deterministic)
# ============================================================================

static func _run_sim() -> void:
	# Mirrors EndgameSmoke._sim_day_full (endgame_smoke.gd:241) — the engine's real
	# boundary order — with the player's answer interleaved after EVERY dispatch, because
	# an unanswered modal blocks _pump_queue and the rest of the day's fires would queue
	# up invisibly behind it.
	while GameState.day < _stop_day and GameState.run_active:
		while GameState.current_hour < TimeManager.HOURS_PER_DAY - 1:
			var next_hour: int = GameState.current_hour + 1
			GameState.set_current_hour(next_hour)
			TimeManager._dispatch_hourly_tick(next_hour)
			_drain_modals()
		GameState.set_current_hour(0)
		TimeManager._dispatch_hourly_tick(0)
		_drain_modals()
		GameState.advance_day()
		TimeManager._dispatch_daily_tick()
		_drain_modals()
		_play_the_founder()
		_log_state()
		_log_customers()
	_finish()


# ============================================================================
#  Drive mode: real clock
# ============================================================================

static func _run_realtime(speed_idx: int) -> void:
	if speed_idx <= 0 or speed_idx >= TimeManager.SECONDS_PER_DAY.size():
		print("PROBE ERROR bad speed index %d" % speed_idx)
		Engine.get_main_loop().quit()
		return
	# Nothing pauses the clock in probe mode (main.gd's modal pause is shell wiring that
	# is not mounted), so the drain has to ride the hour boundary or a stuck active event
	# would silently block every later fire while days kept rolling past it.
	EventBus.hour_changed.connect(func(_h: int) -> void: _drain_modals())
	EventBus.day_advanced.connect(func(day: int) -> void:
		_drain_modals()
		_play_the_founder()
		_log_state()
		_log_customers()
		if day >= _stop_day or not GameState.run_active:
			_finish()
			Engine.get_main_loop().quit()
	)
	EventBus.speed_change_requested.emit(speed_idx)


static func _finish() -> void:
	_log_tally()
	print("PROBE END day=%d run_active=%s ending=%s" % [
		GameState.day, str(GameState.run_active), GameState.ending_id])


# ============================================================================
#  The founder's own moves (Step 4; inert for the Step 0 fire-log presets)
# ============================================================================

static func _play_the_founder() -> void:
	# Runs once per day, after the daily dispatch. Every move goes through the seam the
	# corresponding tab button calls — the probe has no privileged path into the engine.
	if _full_run:
		_open_the_company()
		_hire_after_the_seed()
	if not _build_promises:
		return
	_keep_the_word()


static func _open_the_company() -> void:
	# Day 1 of a real run: there is no product. Build one, ship it, then go selling.
	#
	# B2B, not B2C, and the choice is measured rather than stylistic: a B2C autopilot run
	# was played first and topped out at MRR 135 by day 173 (audience growth barely clears
	# the erosion term for a modest v1), so it can never reach the $2,500 seed bar — let
	# alone the $5,000 Series A gate — inside a run. That is a calibration finding in its
	# own right; it is also why the played run takes the B2B desk, where a signed account
	# is worth $200-$2,000 of MRR on the day it closes. It is additionally the market this
	# sprint's churn work lives in.
	if not GameState.get_flag("mvp_shipped", false):
		if ProductSystem.get_active_build() != null:
			return
		# Three features, complexity 9 — inside the documented 2-4 feature band, and short
		# enough that the first version ships inside a month.
		if ProductSystem.start_build("saas_ops",
				["saas_ops_workflow", "saas_ops_reporting", "saas_ops_scheduling"], "", "Sahra"):
			print("PROBE PLAY day=%d start_build v1 Sahra (b2b)" % GameState.day)
		return
	_work_the_pipeline()


static func _work_the_pipeline() -> void:
	# The founder's sales day: keep leads coming, and pitch whoever is waiting. Both moves
	# go through the seams the Sales tab's own buttons call, cooldown flags included — the
	# probe gets no faster pipeline than a player at the same keyboard.
	if PitchSystem.is_active():
		return
	var leads: Array = ProspectRegistry.get_all()
	if leads.is_empty():
		if GameState.day >= int(GameState.get_flag("next_find_prospects_day", 0)):
			# Mirrors sales_tab.gd's "Aday bul" button exactly — cooldown, count and
			# archetype mix. Copied rather than referenced because sales_tab.gd carries no
			# class_name (it is a scene script), so its consts are not addressable from here.
			GameState.set_flag("next_find_prospects_day", GameState.day + FIND_PROSPECTS_COOLDOWN_DAYS)
			for i in FIND_PROSPECTS_COUNT:
				PitchSystem.spawn_prospect("mid" if (GameState.day + i) % 3 == 0 else "small", "founder_search")
			print("PROBE PLAY day=%d find_prospects (+%d)" % [GameState.day, FIND_PROSPECTS_COUNT])
		return
	if not PitchSystem.can_pitch():
		return
	_pitch(leads[0])


static func _pitch(p: Prospect) -> void:
	# One sitting, played straight: always the first option at every stage. That is a
	# DELIBERATELY UNSKILLED line — it takes the honest-answer route rather than the
	# highest-EV one — so the run's revenue curve is a floor on what a player can do here,
	# never a ceiling flattered by optimal play.
	if not PitchSystem.begin(p.id):
		return
	var mrr_before: int = GameState.mrr
	for i in 8:
		if not PitchSystem.is_active():
			break
		var out: Dictionary = PitchSystem.choose(0)
		if bool(out.get("done", false)):
			var res: Dictionary = out.get("result", {})
			print("PROBE PLAY day=%d pitch %s -> %s (mrr %d -> %d)" % [
				GameState.day, p.company_name, String(res.get("outcome", "?")),
				mrr_before, GameState.mrr])
			return
	if PitchSystem.is_active():
		print("PROBE ERROR day=%d pitch never resolved for %s" % [GameState.day, p.company_name])
		PitchSystem.reset()


static func _hire_after_the_seed() -> void:
	# Frank's money buys the first employee — the beat Step 3 signposts. Driven through
	# HRSearchSystem exactly as the HR tab does it: start a search, wait for the files to
	# arrive, hire the cheapest one.
	if not CharacterRegistry.get_employees().is_empty():
		return
	if int(GameState.get_flag(AngelRoundSystem.FLAG_ACCEPTED_DAY, 0)) <= 0:
		return   # no seed money yet — hiring on the opening cash is a different run
	if HRSearchSystem.has_files_ready():
		var emp: Character = HRSearchSystem.hire(0)
		if emp != null:
			print("PROBE PLAY day=%d hire %s salary=%d burn=%d" % [
				GameState.day, emp.role, emp.monthly_salary, GameState.daily_burn])
		return
	if _hire_started or not HRSearchSystem.can_start():
		return
	if HRSearchSystem.start_search(HRConstants.ROLE_DEVELOPER, HRConstants.BAND_JUNIOR):
		_hire_started = true
		print("PROBE PLAY day=%d start_search developer/junior" % GameState.day)


static func _keep_the_word() -> void:
	# THE DIRECTOR'S SCENARIO, played: a customer demands a feature, the founder actually
	# builds it, and we watch what the account does when it lands. Without this the probe
	# can only ever observe promises BREAKING, which answers half the question.
	# Bugs first: a founder watching accounts slide clears the backlog, and on the B2B side
	# it is the ONLY lever that moves the satisfaction TARGET (which is the product's
	# effective stability — b2b_sales_system.gd:96-106). Shipping features alone cannot
	# lift an account over its tolerance bar; fixing bugs can.
	if int(GameState.get_flag("mvp_live_bug_count", 0)) >= 6 \
			and not GameState.get_flag("mvp_bug_sprint_active", false) \
			and ProductSystem.start_bug_sprint():
		print("PROBE PLAY day=%d bug_sprint bugs=%d" % [
			GameState.day, int(GameState.get_flag("mvp_live_bug_count", 0))])
		return

	var b: FeatureBuild = ProductSystem.get_active_build()
	if b != null:
		# Player-gated iteration: the design band parks on a decision and waits for a human.
		# Taking the seat with ZERO extra rounds is the smoke harness's own convention
		# (_run_build_to_phase) — it keeps the build honest without buying free quality.
		if b.current_phase == "iteration" and b.iteration_decision_pending:
			ProductSystem.enter_development()
			print("PROBE PLAY day=%d enter_development" % GameState.day)
		elif b.current_phase == "bugfix":
			print("PROBE PLAY day=%d launch build=%s" % [GameState.day, str(b.component_ids)])
			ProductSystem.launch()   # fires the ship-moment modal; the drain resolves it,
			_drain_modals()          # and ITS OWN modifier calls ship_active_build
		return

	# No build running: if a word is outstanding and the feature is not live, go build it.
	var live: Array = GameState.get_flag("mvp_components", [])
	for p in PromiseRegistry.get_all():
		if p.status != "open" or live.has(p.feature_id):
			continue
		if ProductSystem.start_version_build([p.feature_id], "founder"):
			print("PROBE PLAY day=%d start_version_build feature=%s (promise %s deadline=%d)" % [
				GameState.day, p.feature_id, p.id, p.deadline_day])
		return


# ============================================================================
#  World presets
# ============================================================================

static func _seed_world(preset: String) -> void:
	# "_keep" suffix = the founder honours his word (builds and ships the promised feature).
	# Split from the world seed on purpose: b2b_risk and b2b_risk_keep share an identical
	# world and differ ONLY in whether the promise is delivered, which makes the pair a
	# controlled experiment rather than two anecdotes.
	_build_promises = preset.ends_with("_keep")
	if preset == "full_run":
		# THE PLAYED RUN. Nothing is seeded: no product, no customers, no money beyond the
		# origin's opening cash. Day 1 is day 1. Everything the log shows after this line
		# was earned by _play_the_founder through the same seams the tabs call.
		_full_run = true
		_build_promises = true
		return
	GameState.set_cash(60000)   # deep enough that the Kepenk shutter never confounds a 90-day log
	match preset.trim_suffix("_keep"):
		"b2c":
			_seed_b2c_world()
		"b2b_solo":
			_seed_b2b_world(0)
		"b2b_reps":
			_seed_b2b_world(2)
		"b2b_risk":
			# Same book, a product under real strain — the ONLY configuration in which the
			# retention → promise → build → churn chain is reachable, because the B2B
			# satisfaction target IS the product's stability score. Stated plainly as a
			# CONSTRUCTED pressure state: the healthy fixture (b2b_solo) parks the whole
			# book at target 49-51 against tolerances of 35-50 and nothing ever slides,
			# which is itself one of Step 0's findings.
			_seed_b2b_world(0)
			GameState.set_flag("mvp_stability", 34.0)
			GameState.set_flag("mvp_live_bug_count", 14)
		"b2b_slip":
			# RECOVERABLE pressure, and the distinction from b2b_risk is the whole point.
			# b2b_risk is UNSALVAGEABLE by construction: raw stability 34 puts the
			# satisfaction target below every tolerance in the book even at zero bugs, so
			# the only possible ending is that everyone leaves. This preset instead sits
			# the target just UNDER the mid/enterprise bar while the bug backlog is live
			# and just OVER it once the backlog is cleared — so a founder who answers the
			# demand AND cleans up actually keeps the account, and one who ignores it does
			# not. That is the Frostpunk clause in the design principles (recoverable
			# pressure) and it is the only world in which "retained" is a real outcome
			# rather than a fixture gift.
			_seed_b2b_world(0)
			GameState.set_flag("mvp_stability", 52.0)
			GameState.set_flag("mvp_live_bug_count", 12)


static func _seed_b2c_world() -> void:
	GameState.set_flag("mvp_shipped", true)
	GameState.set_flag("mvp_market_type", "b2c")
	GameState.set_flag("mvp_sub_product_type_id", "ai_assistant")
	GameState.set_flag("mvp_components", ["ai_assistant_chat", "ai_assistant_memory"])
	GameState.set_flag("mvp_version", 1)
	GameState.set_flag("mvp_product_name", "Nova")
	GameState.set_flag("mvp_innovation", 30.0)
	GameState.set_flag("mvp_stability", 40.0)
	GameState.set_flag("mvp_experience", 35.0)
	SalesSystem.add_b2c_audience(200)
	SalesSystem.open_b2c_paid_tier(15)


static func _seed_b2b_world(rep_count: int) -> void:
	GameState.set_flag("mvp_shipped", true)
	GameState.set_flag("mvp_market_type", "b2b")
	GameState.set_flag("mvp_sub_product_type_id", "saas_ops")
	GameState.set_flag("mvp_components", ["saas_ops_workflow", "saas_ops_reporting"])
	GameState.set_flag("mvp_version", 1)
	GameState.set_flag("mvp_product_name", "Sahra")
	# A MID product on purpose: stability 55 sits above a small account's tolerance seed
	# (35) and below a scaled one's, so the book holds a mix of steady and sliding
	# accounts instead of being uniformly safe or uniformly doomed. The satisfaction
	# TARGET is this stability number (b2b_sales_system.gd:96-106), so it is the single
	# most load-bearing fixture value in the whole log.
	GameState.set_flag("mvp_innovation", 40.0)
	GameState.set_flag("mvp_stability", 55.0)
	GameState.set_flag("mvp_experience", 45.0)
	GameState.set_flag("mvp_live_bug_count", 4)

	# Five accounts through the real signing seam (SalesSystem.add_b2b_customer — the
	# sole B2B signing path), spread across archetypes so tolerance seeds differ and the
	# CS request cadence phases apart (cs_request_phase strides by 9 per signing).
	# Total MRR is deliberately ~2.7K: a young book that is PAST the traction gate
	# (mvp_shipped + 1 customer + mrr > 0) and well SHORT of Series A (MRR ≥ 5000 +
	# brand ≥ 25). Seeded higher, the run rockets to phase 3 in two days and the log
	# stops describing the early game it is supposed to describe.
	#
	# Satisfaction seeds straddle the tolerance seeds on purpose (35 small / 45 mid /
	# 55 enterprise, before sector bonuses): probe_c and probe_e start close enough to
	# their bar that ordinary product wear can push them under, which is the only way
	# the retention → promise → churn chain is reachable without hand-forcing it.
	var specs := [
		{"id": "probe_a", "name": "Kuzey Lojistik", "industry": "logistics", "arch": "small", "mrr": 350, "sat": 72},
		{"id": "probe_b", "name": "Ege Sağlık", "industry": "health", "arch": "mid", "mrr": 800, "sat": 64},
		{"id": "probe_c", "name": "Marmara İnşaat", "industry": "construction", "arch": "mid", "mrr": 700, "sat": 52},
		{"id": "probe_d", "name": "Toros Sigorta", "industry": "insurance", "arch": "small", "mrr": 300, "sat": 68},
		{"id": "probe_e", "name": "Anadolu Üretim", "industry": "manufacturing", "arch": "enterprise", "mrr": 550, "sat": 57},
	]
	for s in specs:
		var p := Prospect.new()
		p.id = String(s["id"])
		p.company_name = String(s["name"])
		p.industry = String(s["industry"])
		p.archetype = String(s["arch"])
		# LOAD-BEARING: add_b2b_customer copies prospect.scale straight through
		# (sales_system.gd:316) and seeds the hidden tolerance from it. Prospect.scale
		# defaults to 1, so an archetype set without a scale roll signs every account —
		# enterprise included — at the small-account tolerance floor of 35, and the whole
		# book becomes unsinkable for reasons that have nothing to do with the engine.
		p.scale = B2BConstants.roll_scale(p.archetype)
		SalesSystem.add_b2b_customer(p, int(s["mrr"]), int(s["sat"]))

	for i in rep_count:
		var c := Character.new()
		c.id = "probe_cs_%d" % i
		c.character_name = "Temsilci %d" % (i + 1)
		c.role = HRConstants.ROLE_CUSTOMER_REP
		c.category = "employee"
		c.monthly_salary = 6000
		c.morale = 60
		# UZMANLIK 2, not 5, and the difference decides whether this preset observes
		# anything at all: the desk absorbs every request whose difficulty is under
		# CS_ABSORB_BASE (3) + the top rep's UZMANLIK (customer_rep_system.gd:230-234).
		# An expertise-5 rep gives a ceiling of 8, which swallows the whole request
		# channel — the run then proves only that a great rep is great. A junior hire
		# (ceiling 5) is both the realistic first CS hire and the configuration in which
		# the escalation path is reachable.
		c.role_stats = {"expertise": 2, "pace": 5, "rapport": 5}
		CharacterRegistry.add(c)
