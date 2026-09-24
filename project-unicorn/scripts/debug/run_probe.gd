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
#   1|2|3 — the REAL clock at that speed index, exactly as a player experiences it
#           (TimeManager._drain_boundaries, frame pacing and all). Slower but honest;
#           this is the only mode that can catch a real-time-only defect such as the
#           ≤1-ambient-per-day throttle leaking across the hour-0 rollover
#           (event_manager.gd:98). Step 4's played run used mode 4 (the rung is gone; use 3).
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
#   PROBE HR    hires=<n> emp=<n> payroll=<n> morale_avg=<f|-> below50=<n> min=<n|->
#
# DEDUPE-REJECTED fires are NOT visible here — enqueue() returns silently when
# _queue_has_id() rejects a duplicate. They are counted from the engine's own
# "[EventManager] Dedupe-rejected: <id>" debug line, which is why that print exists.

const PRESETS := ["b2b_reps", "b2b_solo", "b2b_risk", "b2b_risk_keep",
	"b2b_slip", "b2b_slip_keep", "b2c", "b2c_keep", "b2c_neglect", "full_run", "full_run_weak",
	"full_run_naive", "full_run_discount"]
# Event revision 2026-09 added two policy variants of the played run. The WORLD is the
# same as full_run; only the answer policy differs, which makes the three a controlled
# experiment on what the event cards do to the revenue curve:
#   full_run          — "sensible": a promise when one is open, then a stall, and a
#                       discount only when nothing else is left.
#   full_run_naive    — always the first unlocked row, the probe's historical line.
#   full_run_discount — the discount first, every time it is offered.
# Calibration Round A (2026-08-19) added three presets:
#   full_run_weak — the played run with the ORIGINAL v1 set (workflow+reporting+scheduling,
#                   raw stability 6) and an immediate launch: the "bad v1" the tolerance
#                   band is measured against. full_run itself now builds the stability-
#                   competent set and waits in Beta (see _open_the_company / _keep_the_word).
#   b2c_keep      — the b2c fixture PLUS the sprint policy (_keep grammar): bugs are cleared,
#                   so the aggregate satisfaction can climb — the "maintained" B2C product.
#   b2c_neglect   — a stability-poor, bug-heavy B2C fixture nobody tends: satisfaction erodes.

# Deterministic answer policy, per id prefix. Absent → choice 0. A locked choice is
# never picked (the probe re-runs the modal's own gate, see _pick_choice), so a policy
# index pointing at a locked row falls through to the first unlocked one.
#
# The retention row is 0 on purpose: "Söz ver" is choice 0 when the customer's pain
# feature is unshipped (b2b_event_factory.gd:41-47), and driving promises is the whole
# point of Step 0b. When it is absent the same index lands on the next row, which the
# PICK line records by label so the log never has to be guessed at.
const CHOICE_POLICY := {
	"customer.": 0,
	"funding.": 0,
	"product.": 0,
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
	"ev_hr_calm_stretch": "factory:hr_morale_system:526 (calm)",
	"ev_hr_big_signing": "factory:hr_morale_system:526 (big_signing)",
	"ev_hr_ship_glow": "factory:hr_morale_system:526 (ship_glow)",
	"ev_mvp_ship_moment": "factory:product_system:1266 (ship)",
	"ev_mvp_version_ship_moment": "factory:product_system:1266 (version_ship)",
	"ev_mvp_iter_decision_intro": "factory:product_system:_end_round (iter_intro)",
	"ev_phase_gate_": "factory:phase_gate_system:130 (gate)",
	"funding.frank_cheque": "card:funding/frank_cheque.json",
	"funding.hire_nudge": "card:funding/hire_nudge.json",
	"funding.shutter_warning": "card:funding/shutter_warning.json",
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
static var _weak_v1: bool = false          # "full_run_weak": the original weak feature set + immediate launch
static var _beta_wait: bool = false        # full_run only: hold the ship in Beta until the backlog is small
static var _beta_since_day: int = -1       # first day the build was seen parked in Beta (bugfix phase)
static var _hire_started: bool = false
static var _last_appetite: String = ""     # PROBE SIGNAL on change (Calibration Round A §3)
static var _discount_uses: Dictionary = {}  # customer id -> discounts taken (Calibration Round A §8)
static var _policy: String = "sensible"     # full_run answer policy: sensible | naive | discount
static var _last_ship_day: int = 0          # the played run ships a version at a steady cadence
static var _run_seed: int = 424242
static var _fix_run_day: int = -1           # day the running fix pass started
static var _fixer_id: String = ""           # the developer lent to the support desk for it
static var _retain_days: Dictionary = {}    # customer id -> Array of fire days (retention cards)
static var _fires_by_day: Dictionary = {}   # day -> {family: count} for PROBE WEEK


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
	# Optional 4th part: the run seed, so one preset can be sampled across seeds.
	_run_seed = int(parts[3]) if parts.size() > 3 else 424242
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
	GameState.run_seed = _run_seed
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
	EventBus.build_phase_changed.connect(_on_build_phase)
	EventBus.month_ended.connect(_on_month_ended)


static func _on_month_ended(_data: Dictionary) -> void:
	# The calendar-month ledger (§3/§9): the entry MonthSummarySystem just pushed.
	if GameState.month_history.is_empty():
		return
	var e: Dictionary = GameState.month_history[GameState.month_history.size() - 1]
	var n: int = GameState.month_history.size()
	var growth: String = "n/a"
	if n >= 2:
		var prev: int = int(GameState.month_history[n - 2].get("mrr_close", 0))
		if prev > 0:
			growth = "%.1f" % ((float(int(e.get("mrr_close", 0))) / float(prev) - 1.0) * 100.0)
	print("PROBE MONTH day=%d n=%d mrr_close=%d income=%d expense=%d net=%d red=%d growth_pct=%s streak=%d profit_streak=%d" % [
		GameState.day, n, int(e.get("mrr_close", 0)), int(e.get("income", 0)), int(e.get("expense", 0)),
		int(e.get("net", 0)), int(e.get("red_days", 0)), growth,
		GameState.get_mrr_growth_streak(PhaseGateSystem.GROWTH_MIN_PCT), GameState.get_profitable_month_streak()])


static func _on_build_phase(new_phase: String) -> void:
	# The ship moment, with the raw axes the economy will read from now on. Bug count is the
	# LIVE count after launch (launch() copies the build's backlog into mvp_live_bug_count).
	if new_phase != "shipped":
		return
	print("PROBE SHIP day=%d version=%d stability=%.1f innovation=%.1f experience=%.1f bugs=%d components=%s" % [
		GameState.day, int(GameState.get_flag("mvp_version", 0)),
		float(GameState.get_flag("mvp_stability", 0.0)), float(GameState.get_flag("mvp_innovation", 0.0)),
		float(GameState.get_flag("mvp_experience", 0.0)), int(GameState.get_flag("mvp_live_bug_count", 0)),
		str(GameState.get_flag("mvp_components", []))])


static func _family_of(event_id: String) -> String:
	if event_id.begins_with("ev_b2b_retain_"): return "retain"
	if event_id.begins_with("ev_b2b_request_") or event_id.begins_with("ev_b2b_escalation_"): return "cs"
	if event_id.begins_with("ev_b2b_expand_"): return "expand"
	if event_id.begins_with("ev_mvp_"): return "build"
	if event_id.begins_with("ev_ps_"): return "post_ship"
	return "other"


static func _on_fire(event_id: String) -> void:
	_fires[event_id] = int(_fires.get(event_id, 0)) + 1
	var by: Dictionary = _fires_by_day.get(GameState.day, {})
	var fam: String = _family_of(event_id)
	by[fam] = int(by.get(fam, 0)) + 1
	_fires_by_day[GameState.day] = by
	if fam == "retain":
		var cid: String = event_id.trim_prefix("ev_b2b_retain_")
		var days: Array = _retain_days.get(cid, [])
		days.append(GameState.day)
		_retain_days[cid] = days
	print("PROBE FIRE day=%d hour=%d id=%s src=%s" % [
		GameState.day, GameState.current_hour, event_id, _source_of(event_id)])


static func _source_of(event_id: String) -> String:
	if EventGate.is_catalogued(event_id):
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
	# Calibration Round A: the B2C aggregate (audience, its satisfaction, live bugs) and the
	# rival-relative quality q that the audience formula actually reads — the four numbers
	# the §5/§6 verdicts are read from. q is -1 before a ship (nothing to compare).
	var ub: Customer = CustomerRegistry.get_customer(SalesSystem.B2C_USERBASE_ID)
	var q: float = -1.0
	if GameState.get_flag("mvp_shipped", false):
		q = SalesSystem._rival_relative_quality(QualityModel.shipped_normalized())
	var sig: Dictionary = PhaseGateSystem.series_a_signal()
	var appetite: String = String(sig.get("state", "closed"))
	print("PROBE STATE day=%d cash=%d mrr=%d brand=%d burn=%d runway=%s cust=%d emp=%d promises=%d phase=%d aud=%d sat=%d bugs=%d q=%.1f appetite=%s streak=%d/%d profit_streak=%d" % [
		GameState.day, GameState.cash, GameState.mrr, GameState.brand, GameState.daily_burn,
		("INF" if is_inf(runway) else "%.2f" % runway),
		CustomerRegistry.get_all().size(), CharacterRegistry.get_employees().size(),
		PromiseRegistry.get_all().size(), GameState.phase,
		int(GameState.get_flag("b2c_audience", 0)), (ub.satisfaction if ub != null else -1),
		int(GameState.get_flag("mvp_live_bug_count", 0)), q,
		appetite, int(sig.get("streak", 0)), int(sig.get("streak_need", 0)), GameState.get_profitable_month_streak()])
	if appetite != _last_appetite:
		print("PROBE SIGNAL day=%d appetite=%s->%s mrr=%d streak=%d" % [
			GameState.day, _last_appetite, appetite, GameState.mrr, int(sig.get("streak", 0))])
		_last_appetite = appetite


static func _log_customers() -> void:
	# The churn autopsy's raw material. TARGET is the number the whole B2B book drifts
	# toward — QualityModel.axis_score(economy_dims_from_flags(), "stability") + trust_offset
	# (b2b_sales_system.gd:96-106) — and it is printed beside satisfaction and tolerance
	# because "why did nobody slide" and "why did everybody slide" are the same question
	# asked of these three numbers.
	var health: float = QualityModel.axis_score(QualityModel.economy_dims_from_flags(), "stability")
	var book: Array = CustomerRegistry.get_by_market("b2b")
	var satisfied: int = 0
	for c in book:
		if c.satisfaction >= c.tolerance:
			satisfied += 1
		print("PROBE CUST day=%d id=%s sat=%d tol=%d target=%d trust=%.1f phase=%s streak=%d cd=%d mrr=%d bugs=%d" % [
			GameState.day, c.id, c.satisfaction, c.tolerance,
			clampi(int(round(health + c.trust_offset)), 0, 100), c.trust_offset,
			c.lifecycle_phase, c.risk_streak, c.churn_countdown, c.mrr,
			int(GameState.get_flag("mvp_live_bug_count", 0))])
	# Calibration Round A §1: the fraction of the book at or above its bar — the number the
	# tolerance re-seat is judged by ("~60-70% of a 5-account book for a good v1, ~20% bad").
	if not book.is_empty():
		print("PROBE SAT day=%d satisfied=%d/%d target=%d" % [GameState.day, satisfied, book.size(),
			clampi(int(round(health)), 0, 100)])


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
	while EventGate.active_id() != "":
		guard += 1
		if guard > 64:
			print("PROBE ERROR drain guard tripped at day %d on id=%s — an event is re-queueing inside its own resolution" % [
				GameState.day, EventGate.active_id()])
			return
		var id: String = EventGate.active_id()
		var ev: GameEvent = EventGate.active_card()
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
		# §8: count discounts BY MODIFIER TYPE (labels are player-facing text).
		for m in ev.choices[idx].modifiers:
			if String(m.get("verb", m.get("type", ""))) == "b2b_retain_discount":
				var cid: String = str(EventGate.active_context().get("customer", m.get("customer_id", "")))
				_discount_uses[cid] = int(_discount_uses.get(cid, 0)) + 1
				print("PROBE DISCOUNT day=%d cust=%s uses=%d" % [GameState.day, cid, int(_discount_uses[cid])])
		EventGate.resolve(id, idx)


# Retention preference, BY MODIFIER TYPE rather than by row index or label. Index is wrong
# because the card's rows are conditional (the promise row vanishes once the pain feature
# ships, so "choice 0" silently becomes a different decision); label is wrong because labels
# are player-facing text. Order = strongest genuine rescue first: a promise and a discount
# both run _recover, a stall only postpones twice, and ignoring is a documented no-op.
#
# This is the probe PLAYING COMPETENTLY, and it matters for what the log proves: picking
# index 0 blindly had it answer "Oyala" on every post-delivery risk card, so the run
# measured a bad player rather than the engine.
const RETAIN_PREFERENCE := ["promise_create", "b2b_retain_delay", "b2b_retain_discount", "b2b_retain_ignore"]
const DISCOUNT_PREFERENCE := ["b2b_retain_discount", "promise_create", "b2b_retain_delay", "b2b_retain_ignore"]


static func _pick_choice(ev: GameEvent) -> int:
	# b2c_neglect (Calibration Round A §5): the untended consumer product — every post-ship
	# card is answered with its LAST unlocked row (the "ignore it" grammar), never the paid
	# satisfaction boost. Without this the "neglect" arm still bought +20 satisfaction per
	# complaint and read as tended.
	if _preset == "b2c_neglect" and ev.id.begins_with("ev_ps_"):
		for idx in range(ev.choices.size() - 1, -1, -1):
			if EventGate.condition_met(ev.choices[idx].unlock_condition, EventGate.active_context()):
				return idx
	# Runs the modal's OWN gate (EventManager.is_condition_met on unlock_condition —
	# event_modal.gd:330), not a mirror of it, so the probe can never pick a row a human
	# is forbidden to click.
	# Account cards (retention, the three requests, the CS warning): the policy picks by
	# EFFECT VERB, never by row index or label — rows are conditional and labels are
	# player-facing text. `naive` skips this and takes the first unlocked row below.
	if _policy != "naive" and ev.id.begins_with("customer.") and ev.id != "customer.expansion":
		var order: Array = DISCOUNT_PREFERENCE if _policy == "discount" else RETAIN_PREFERENCE
		for want_verb in order:
			for idx in ev.choices.size():
				if not EventGate.condition_met(ev.choices[idx].unlock_condition, EventGate.active_context()):
					continue
				for m in ev.choices[idx].modifiers:
					if String(m.get("verb", m.get("type", ""))) == want_verb:
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
		if EventGate.condition_met(ev.choices[idx].unlock_condition, EventGate.active_context()):
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
		if not EventGate.condition_met(ev.choices[idx].unlock_condition, EventGate.active_context()):
			continue
		var cost: int = -_cash_delta_of(ev.choices[idx])
		if cost < best_cost:
			best_cost = cost
			best = idx
	return best


# Fraction of the current balance the founder will spend on any single event choice.
const AFFORDABLE_FRACTION := 0.12

# The two "Aday bul" mirrors were here and are RETIRED with the button (Satış rev 6 §19).
# The drift risk they were named against is gone with them: supply is SalesFaucetSystem's and
# the probe reads the same faucet the game does, so there is nothing left to mirror.


static func _cash_delta_of(choice: EventChoice) -> int:
	var total: int = 0
	for m in choice.modifiers:
		if String(m.get("verb", "")) == "add_cash":
			total += int(m.get("amount", 0))
		elif String(m.get("type", "")) == "cash":
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


static func _log_cadence() -> void:
	# §8/§13 verdict lines: per-account retention cadence (fires, the densest 30-day window,
	# discounts taken) and fires per week by family.
	var ids: Array = _retain_days.keys()
	ids.sort()
	for cid in ids:
		var days: Array = _retain_days[cid]
		var max30: int = 0
		for i in days.size():
			var n: int = 0
			for j in range(i, days.size()):
				if int(days[j]) - int(days[i]) < 30:
					n += 1
			max30 = maxi(max30, n)
		print("PROBE RETAIN %s fires=%d max30=%d discounts=%d" % [cid, days.size(), max30, int(_discount_uses.get(cid, 0))])
	var last_day: int = GameState.day
	var week: int = 1
	var d: int = 1
	while d <= last_day:
		var tot: Dictionary = {}
		for k in range(d, mini(d + 7, last_day + 1)):
			var by: Dictionary = _fires_by_day.get(k, {})
			for fam in by.keys():
				tot[fam] = int(tot.get(fam, 0)) + int(by[fam])
		var all: int = 0
		for fam in tot.keys():
			all += int(tot[fam])
		print("PROBE WEEK w=%d fires=%d retain=%d cs=%d expand=%d build=%d post_ship=%d other=%d" % [
			week, all, int(tot.get("retain", 0)), int(tot.get("cs", 0)), int(tot.get("expand", 0)),
			int(tot.get("build", 0)), int(tot.get("post_ship", 0)), int(tot.get("other", 0))])
		week += 1
		d += 7


static func _finish() -> void:
	_log_cadence()
	_log_tally()
	print("PROBE END day=%d run_active=%s ending=%s" % [
		GameState.day, str(GameState.run_active), GameState.ending_id])
	_log_hr()


## PROBE HR — üç sayı: kaç işe alım, aylık maaş yükü, kaç kişi §7'nin 50 bandının altında.
##
## Bu satır bugüne dek YOKTU. `PROBE STATE` yalnız `emp=<headcount>` taşıyordu; `run_hires`,
## `get_total_monthly_salaries()` ve `average_morale()` koşu boyunca HİÇ çağrılmıyordu, yani
## İK'nın koşuda ne yaptığı ölçülmüyordu.
##
## SIFIR İŞE ALIM BİR HATA DEĞİL BİR BULGUDUR ve öyle raporlanır: probe'un kendi işe alım
## yolu (`_hire_after_the_seed`) üç kapılı ve TEK ATIŞLIK, yani koşunun İK'yı hiç egzersiz
## etmemesi mümkün ve bu ölçümün söylemesi gereken ilk şey odur.
static func _log_hr() -> void:
	var staff: Array[Character] = CharacterRegistry.get_employees()
	var payroll: int = CharacterRegistry.get_total_monthly_salaries()
	# BOŞ KADRO TUZAĞI: `average_morale()` kimse yokken 0.0 döner ve bu satır o zaman
	# "moral çöktü" diye okunurdu — koşunun ilk kırk günü tam olarak öyle görünür.
	# Kadro boşken sayı YAZILMAZ, tire yazılır.
	var avg: String = "-"
	var below: int = 0
	var lowest: int = -1
	if not staff.is_empty():
		avg = "%.1f" % HRMoraleSystem.average_morale()
		lowest = HRConstants.MORALE_MAX
		for emp in staff:
			if emp.morale < HRConstants.MORALE_BAND_LOW:
				below += 1
			lowest = mini(lowest, emp.morale)
	print("PROBE HR hires=%d emp=%d payroll=%d morale_avg=%s below%d=%d min=%s" % [
		GameState.run_hires, staff.size(), payroll, avg,
		HRConstants.MORALE_BAND_LOW, below,
		"-" if lowest < 0 else str(lowest)])


# ============================================================================
#  The founder's own moves (Step 4; inert for the Step 0 fire-log presets)
# ============================================================================

static func _play_the_founder() -> void:
	# Runs once per day, after the daily dispatch. Every move goes through the seam the
	# corresponding tab button calls — the probe has no privileged path into the engine.
	if _full_run:
		_open_the_company()
		_hire_after_the_seed()
		if not _weak_v1:
			_run_the_company()
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
		# Calibration Round A §1: the COMPETENT v1 is the stability-heavy set — integration (7)
		# + field (7, unlocked from research this round) + scheduling (3): raw stability 17,
		# complexity 13, an $1,800 licence out of the $10,000 opening cash. The original set
		# (workflow+reporting+scheduling, raw stability 6, complexity 9) is what the played
		# run measured its retention hell with; it stays reachable as full_run_weak — the
		# "bad v1" the tolerance band is seated against.
		# Event revision 2026-09: the played run builds the LINE product a player can
		# actually pick (erp is the only playable B2B subtype). The old flat `saas_ops`
		# build has no line data, so the rebuilt sales meeting read its axes as 0 and the
		# founder lost ~96% of meetings — the $11.9K "ceiling" was that, not the economy.
		# full_run_weak keeps the retired flat product as the historical comparison.
		if _weak_v1:
			var features: Array = ["saas_ops_workflow", "saas_ops_reporting", "saas_ops_scheduling"]
			if ProductSystem.start_build("saas_ops", features, "", "Sahra"):
				print("PROBE PLAY day=%d start_build v1 Sahra (b2b) set=weak" % GameState.day)
			return
		var v1: Array = ["line_erp_ledger_k1", "line_erp_stock_k1", "line_erp_cashflow_k1"]
		if ProductSystem.start_line_build("erp", v1, CharacterRegistry.get_founder().id, "Sahra"):
			print("PROBE PLAY day=%d start_line_build v1 Sahra (erp) steps=%s" % [GameState.day, str(v1)])
		return
	_work_the_pipeline()


static func _work_the_pipeline() -> void:
	# The founder's sales day, Satış rev 6. Two things changed and both simplify this:
	# LEADS ARRIVE ON THEIR OWN (§3 — the button and its cooldown are retired, so the probe
	# no longer mirrors a UI constant it could not address), and the throttle is the DAILY
	# MEETING RIGHT rather than a two-day cooldown (§5.0). Both gates are asked through the
	# same seams the tab's own buttons ask, so the probe gets no faster a pipeline than a
	# player at the same keyboard.
	if SalesMeetingSystem.is_active() or NegotiationSystem.is_active():
		return
	# The first lead the founder is allowed to sit with, not only the head of the queue:
	# a blocked returning company at leads[0] used to idle the day's meeting for a week.
	for raw in ProspectRegistry.get_all():
		var lead: Prospect = raw as Prospect
		if lead != null and SalesMeetingSystem.block_reason(lead.id) == "":
			_meet(lead)
			return


static func _meet(p: Prospect) -> void:
	# One sitting, played straight: always the FIRST OPEN answer at every probe, then the
	# stance anchor at the table. That is a DELIBERATELY UNSKILLED line — it takes whatever
	# is on top rather than the highest-EV route — so the run's revenue curve is a floor on
	# what a player can do here, never a ceiling flattered by optimal play.
	var mrr_before: int = GameState.mrr
	var vs: Dictionary = SalesMeetingSystem.open(p.id)
	if vs.is_empty():
		return
	for i in SalesConstants.SAFETY_CAP_PROBES + 2:
		if String(vs.get("outcome", "")) != "":
			break
		var answers: Array = vs.get("answers", []) as Array
		var picked: String = ""
		for a in answers:
			if bool((a as Dictionary).get("open", false)):
				picked = String((a as Dictionary).get("id", ""))
				break
		if picked == "":
			vs = SalesMeetingSystem.skip_to_offer()
			break
		vs = SalesMeetingSystem.choose(picked)
	var outcome: String = String(vs.get("outcome", "lost"))
	if outcome == "won":
		# §5.3 — Perde 2, sessiz. The probe offers at the stance anchor and takes whatever
		# the customer counters with; a walk would be the skilled move and this line is not.
		NegotiationSystem.open(NegotiationSystem.TYPE_B2B, {
			"account": p.company_name, "lead_id": p.id, "star": p.star,
			"archetype": p.archetype_id, "promised": SalesMeetingSystem.promised_feature(),
			"is_whale": p.is_whale,
		})
		for j in SalesConstants.PATIENCE_MAX + 1:
			var nvs: Dictionary = NegotiationSystem.offer()
			if String(nvs.get("state", "")) == "accepted":
				break
			if String(nvs.get("state", "")) == "closed":
				break
			if int(nvs.get("counter", -1)) >= 0:
				NegotiationSystem.accept_counter()
				break
		SalesFinalizer.apply(NegotiationSystem.result())
	SalesMeetingSystem.close()
	print("PROBE PLAY day=%d meeting %s -> %s (mrr %d -> %d)" % [
		GameState.day, p.company_name, outcome, mrr_before, GameState.mrr])


## The played run's staffing ladder (Event revision 2026-09): a founder who is growing
## hires the desk the growth needs — a developer on Frank's money, a support rep once a
## few accounts are live, sales reps as MRR climbs. Each rung only when the payroll it
## adds leaves six months of runway. The weak run keeps the historical single hire.
const STAFF_LADDER := [
	{"role": "developer", "min_customers": 0, "min_mrr": 0},
	{"role": "customer_rep", "min_customers": 3, "min_mrr": 0},
	# QA early: the stability lines' K2/K3 gate on QA stars, and B2B satisfaction drifts
	# toward the stability reading. A run without a tester cannot hold its accounts.
	{"role": "tester", "min_customers": 0, "min_mrr": 3000},
	{"role": "sales_rep", "min_customers": 0, "min_mrr": 4000},
	{"role": "sales_rep", "min_customers": 0, "min_mrr": 12000},
	{"role": "developer", "min_customers": 0, "min_mrr": 15000},
	{"role": "customer_rep", "min_customers": 12, "min_mrr": 0},
	{"role": "sales_rep", "min_customers": 0, "min_mrr": 30000},
	{"role": "product_manager", "min_customers": 0, "min_mrr": 30000},
	{"role": "sales_rep", "min_customers": 0, "min_mrr": 50000},
	{"role": "developer", "min_customers": 0, "min_mrr": 60000},
	{"role": "customer_rep", "min_customers": 25, "min_mrr": 0},
	{"role": "sales_rep", "min_customers": 0, "min_mrr": 80000},
]


static func _hire_after_the_seed() -> void:
	# Frank's money buys the first employee — the beat Step 3 signposts. Driven through
	# HRSearchSystem exactly as the HR tab does it: start a search, wait for the files to
	# arrive, hire the cheapest one.
	if int(GameState.get_flag(AngelRoundSystem.FLAG_ACCEPTED_DAY, 0)) <= 0:
		return   # no seed money yet — hiring on the opening cash is a different run
	if HRSearchSystem.has_files_ready():
		var hired: Character = HRSearchSystem.hire(0)
		if hired != null:
			_hire_started = false
			print("PROBE PLAY day=%d hire %s salary=%d burn=%d" % [
				GameState.day, hired.role, hired.monthly_salary, GameState.daily_burn])
		return
	if _hire_started or not HRSearchSystem.can_start():
		return
	if not _weak_v1:
		var rung: int = CharacterRegistry.get_employees().size()
		if rung >= STAFF_LADDER.size():
			return
		var want: Dictionary = STAFF_LADDER[rung]
		if CustomerRegistry.account_count() < int(want["min_customers"]) or GameState.mrr < int(want["min_mrr"]):
			return
		var monthly_out: int = GameState.daily_burn * 30 + 6000 - GameState.mrr
		if monthly_out > 0 and GameState.cash < monthly_out * 6:
			return
		if HRSearchSystem.start_search(String(want["role"]), HRConstants.LEVEL_JUNIOR):
			_hire_started = true
			print("PROBE PLAY day=%d start_search %s/junior" % [GameState.day, want["role"]])
		return
	if not CharacterRegistry.get_employees().is_empty():
		return
	if HRSearchSystem.has_files_ready():
		var emp: Character = HRSearchSystem.hire(0)
		if emp != null:
			print("PROBE PLAY day=%d hire %s salary=%d burn=%d" % [
				GameState.day, emp.role, emp.monthly_salary, GameState.daily_burn])
		return
	if _hire_started or not HRSearchSystem.can_start():
		return
	if HRSearchSystem.start_search(HRConstants.ROLE_DEVELOPER, HRConstants.LEVEL_JUNIOR):
		_hire_started = true
		print("PROBE PLAY day=%d start_search developer/junior" % GameState.day)


## The played run's operations (Event revision 2026-09) — the things any player does and
## the old probe never did: buy server capacity so the product is not over capacity from
## the first seat, run a fix pass when confirmed bugs pile up, and ship a version on a
## steady cadence instead of only when a promise demands one.
static func _run_the_company() -> void:
	if not ProductState.is_live():
		return
	if InfraSystem.provider() == "":
		InfraSystem.set_provider("cloud")
		InfraSystem.set_capacity(InfraSystem.suggested_start_units())
		print("PROBE PLAY day=%d infra provider=cloud units=%d" % [GameState.day, InfraSystem.units()])
	if InfraSystem.occupancy() > 0.85:
		InfraSystem.adjust_capacity(1)
		print("PROBE PLAY day=%d infra +1 unit -> %d" % [GameState.day, InfraSystem.units()])
	# A fix pass pauses the build (§8.4), so a player closes it after a few days and ships
	# what was fixed; waiting for zero confirmed bugs never ends, because reports keep coming.
	if ProductState.fix_run_active():
		if ProductState.bugs_confirmed() <= 1 or GameState.day - _fix_run_day >= 4:
			print("PROBE PLAY day=%d fix_run end shipped=%d" % [GameState.day, SupportSystem.end_fix_run()])
			if _fixer_id != "":
				CharacterRegistry.unassign_job(_fixer_id, HRConstants.JOB_SUPPORT)
				_fixer_id = ""
	elif ProductState.bugs_confirmed() >= 6 and SupportSystem.can_start_fix_run():
		# §8.4: fixes are ENGINEERING on the support desk. The CS reps who staff it have no
		# engineering, so a player lends a developer to the desk for the pass.
		for dev in CharacterRegistry.get_employees():
			if dev.role == HRConstants.ROLE_DEVELOPER and not dev.assigned_job_ids.has(HRConstants.JOB_RESEARCH) \
					and CharacterRegistry.assign_job(dev.id, HRConstants.JOB_SUPPORT) == "":
				_fixer_id = dev.id
				break
		SupportSystem.start_fix_run()
		_fix_run_day = GameState.day
		print("PROBE PLAY day=%d fix_run start bugs=%d fixer=%s fix_per_day=%.2f" % [GameState.day,
			ProductState.bugs_confirmed(), _fixer_id, SupportSystem.fix_per_day()])
	_run_research()
	_keep_the_team()


## A player watching the roster does something before a person walks: a raise first, the
## year's holiday if a raise is not on the table. Nothing fancier; the probe's job is to
## stop measuring "nobody ever looked at morale" (27 of 30 hires resigned without it).
static func _keep_the_team() -> void:
	for emp in CharacterRegistry.get_employees():
		if emp.category != "employee" or emp.status != HRConstants.STATUS_ACTIVE:
			continue
		if emp.morale >= 40:
			continue
		if HRActions.can_raise(emp, 10) and HRActions.apply_raise(emp, 10):
			print("PROBE PLAY day=%d raise %s morale=%d" % [GameState.day, emp.role, emp.morale])
		elif emp.leave_taken_year != int(GameState.get_date_dict().year):
			HRMoraleSystem.send_on_leave(emp, 10, true)
			print("PROBE PLAY day=%d holiday %s morale=%d" % [GameState.day, emp.role, emp.morale])


## Research the next gated step needs (or any open node): a player who wants K2/K3 does
## Ar-Ge. Never the founder, whose seat is the build and the sales desk.
static func _run_research() -> void:
	if not RnDSystem.tree_open() or RnDSystem.active() != "":
		return
	var wanted: Array = []
	for tier in range(1, ProductLines.TIER_MAX + 1):
		for raw_line in ProductLines.line_ids("erp"):
			var line_id: String = String(raw_line)
			if ProductState.line_tier(line_id) + 1 != tier:
				continue
			var st: Dictionary = ProductLines.step_at(line_id, tier)
			var node: String = String((st.get("requires", {}) as Dictionary).get("research", ""))
			if node != "" and not RnDSystem.node_completed(node) and not wanted.has(node):
				wanted.append(node)
	for id in ResearchSeam.NODES.keys():
		if not wanted.has(String(id)):
			wanted.append(String(id))
	var founder_id: String = CharacterRegistry.get_founder().id
	# Research takes the whole person (Ar-Ge §5.0). Keep one developer on the build and
	# never take the one lent to the fix pass: a company with a single developer does
	# not research, it ships.
	var devs: int = 0
	for e in CharacterRegistry.get_employees():
		if e.role == HRConstants.ROLE_DEVELOPER:
			devs += 1
	for node in wanted:
		if not RnDSystem.available(String(node)):
			continue
		for c in RnDSystem.eligible_assignees(String(node)):
			if c.id == founder_id or c.id == _fixer_id:
				continue
			if c.role == HRConstants.ROLE_DEVELOPER and devs < 2:
				continue
			if RnDSystem.start(String(node), [c.id]) == "":
				print("PROBE PLAY day=%d research %s by %s" % [GameState.day, node, c.role])
				return


## Next steps a version could carry: the lowest open tier on each line, STABILITY first.
## B2B satisfaction drifts toward the product's stability reading (b2b_sales_system
## _satisfaction_target), so a player keeping accounts builds that axis before the others.
static func _next_open_steps(limit: int) -> Array:
	var out: Array = []
	var lines: Array = ProductLines.line_ids("erp")
	lines.sort_custom(func(a, b) -> bool:
		return int(ProductLines.axis_of(String(a)) == "stability") > int(ProductLines.axis_of(String(b)) == "stability"))
	for tier in range(1, ProductLines.TIER_MAX + 1):
		for raw_line in lines:
			var line_id: String = String(raw_line)
			if ProductState.line_tier(line_id) + 1 != tier:
				continue
			var st: Dictionary = ProductLines.step_at(line_id, tier)
			var sid: String = String(st.get("id", ""))
			if sid != "" and LineGates.is_unlocked(sid):
				out.append(sid)
				if out.size() >= limit:
					return out
	return out


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
		# Build Bar 2026-08-19: design rounds chain by themselves; the two human seats are
		# "Geliştirmeye geç" (opens when round 1 ends) and "Beta'ya geç" (development parks
		# at 80%). Taking each seat the moment it opens — ZERO completed extra rounds — is
		# the smoke harness's own convention (_run_build_to_phase): the build stays honest
		# without buying free quality (a just-started round 2 is abandoned, no gains).
		if ProductSystem.can_enter_development():
			ProductSystem.enter_development()
			print("PROBE PLAY day=%d enter_development" % GameState.day)
		# BANDI BEKLER (D2): kapı artık her yüzdede açık, ama erken çıkış bugün
		# bedelsiz ve baskın — temsilî koşunun onu alması kalibrasyonu bozardı.
		elif ProductSystem.development_band_complete():
			ProductSystem.enter_beta()
			print("PROBE PLAY day=%d enter_beta" % GameState.day)
		elif b.current_phase == "bugfix":
			# Beta is a PARK with no auto-ship: waiting is free apart from burn and clears the
			# backlog at POLISH_BUG_FIX_PER_DAY. The competent founder (full_run) waits until the
			# backlog is small or five Beta days have passed; every other preset (and the weak
			# v1) ships the day Beta opens, exactly as before.
			if _beta_wait:
				if _beta_since_day < 0:
					_beta_since_day = GameState.day
				var beta_days: int = GameState.day - _beta_since_day
				if b.bug_count > 3 and beta_days < 5:
					return
			_beta_since_day = -1
			print("PROBE PLAY day=%d launch build=%s bugs=%d" % [GameState.day, str(b.component_ids), b.bug_count])
			ProductSystem.launch()   # fires the ship-moment modal; the drain resolves it,
			_drain_modals()          # and ITS OWN modifier calls ship_active_build
		return

	# No build running: if a word is outstanding and the feature is not live, go build it.
	var line_product: bool = ProductLines.has_subtype(ProductState.subtype())
	for p in PromiseRegistry.get_all():
		if p.status != "open" or ProductState.is_feature_live(p.feature_id):
			continue
		var started: bool = false
		if line_product:
			if LineGates.is_unlocked(p.feature_id):
				started = ProductSystem.start_line_build(ProductState.subtype(), [p.feature_id],
					CharacterRegistry.get_founder().id)
		else:
			started = ProductSystem.start_version_build([p.feature_id], "founder")
		if started:
			print("PROBE PLAY day=%d start_version_build feature=%s (promise %s deadline=%d)" % [
				GameState.day, p.feature_id, p.id, p.deadline_day])
			return
	# Nothing promised: a growing product still ships. A version every three weeks, two steps.
	if line_product and _full_run and not _weak_v1 and GameState.day - _last_ship_day >= 21:
		var steps: Array = _next_open_steps(2)
		if not steps.is_empty() and ProductSystem.start_line_build(ProductState.subtype(), steps,
				CharacterRegistry.get_founder().id):
			_last_ship_day = GameState.day
			print("PROBE PLAY day=%d start_version_build steps=%s (cadence)" % [GameState.day, str(steps)])


# ============================================================================
#  World presets
# ============================================================================

static func _seed_world(preset: String) -> void:
	# "_keep" suffix = the founder honours his word (builds and ships the promised feature).
	# Split from the world seed on purpose: b2b_risk and b2b_risk_keep share an identical
	# world and differ ONLY in whether the promise is delivered, which makes the pair a
	# controlled experiment rather than two anecdotes.
	_build_promises = preset.ends_with("_keep")
	if preset.begins_with("full_run"):
		# THE PLAYED RUN. Nothing is seeded: no product, no customers, no money beyond the
		# origin's opening cash. Day 1 is day 1. Everything the log shows after this line
		# was earned by _play_the_founder through the same seams the tabs call.
		_full_run = true
		_build_promises = true
		_weak_v1 = preset == "full_run_weak"
		_beta_wait = not _weak_v1
		_policy = "naive" if preset == "full_run_naive" else ("discount" if preset == "full_run_discount" else "sensible")
		_last_ship_day = 0
		return
	GameState.set_cash(60000)   # deep enough that the Kepenk shutter never confounds a 90-day log
	match preset.trim_suffix("_keep"):
		"b2c":
			_seed_b2c_world(false)
		"b2c_neglect":
			_seed_b2c_world(true)
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
			# Calibration Round A §1: DERIVED, not authored. Unsalvageable = the zero-bug axis
			# sits 8 under the SMALL bar; the backlog (14) only makes it worse.
			_seed_stability_fixture("b2b_risk", _raw_for_axis(_bar_small() - 8.0), 14)
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
			# Calibration Round A §1: DERIVED. With the backlog live the axis sits 2 over the
			# MID bar (inside [T_mid, T_mid+5): small accounts safe, sector-picky mids and the
			# enterprise under); cleared, it must clear T_mid+7 — checked at seed time.
			_seed_stability_fixture("b2b_slip", _raw_for_axis(_bar_mid() + 2.0) + QualityModel.BUG_STABILITY_COEF * 9.0, 9)


static func _seed_b2c_world(neglect: bool) -> void:
	GameState.set_flag("mvp_shipped", true)
	# LAUNCH DAY, not just "shipped". These presets set the flag directly instead of going
	# through ship_active_build, which is the only writer of mvp_launch_day - so without
	# this line the fixture claims a live product with no launch date, and every
	# days_since_flag trigger reading it stays false forever (the paid-tier card, Frank v6
	# surface 7). A seeded world is "already live", so day 1 is the honest stamp.
	GameState.set_flag("mvp_launch_day", GameState.day)
	GameState.set_flag("mvp_market_type", "b2c")
	GameState.set_flag("mvp_sub_product_type_id", "ai_assistant")
	GameState.set_flag("mvp_components", ["ai_assistant_chat", "ai_assistant_memory"])
	GameState.set_flag("mvp_version", 1)
	GameState.set_flag("mvp_product_name", "Nova")
	if neglect:
		# Calibration Round A §5: the UNTENDED consumer product. Experience under the B2C
		# satisfaction gate (no daily +1), a live backlog over SATISFACTION_BUG_GATE (daily −1),
		# and nobody sprints — satisfaction erodes, the WOM term never opens, the multiplier
		# shrinks growth. The "declining" arm of the §5 measurement.
		GameState.set_flag("mvp_innovation", 10.0)
		GameState.set_flag("mvp_stability", 8.0)
		GameState.set_flag("mvp_experience", 8.0)
		GameState.set_flag("mvp_live_bug_count", 12)
	else:
		# A modest v1. Raw axes were 30/40/35 on the retired grown scale; halved 2026-08-19
		# with NORMALIZE_HALF_SAT (50 → 25) so the fixture's NORMALIZED meaning — and, with
		# the rival scale bridge, its rival-relative q ≈ 41 — is byte-for-byte what the
		# before/after table measured against.
		GameState.set_flag("mvp_innovation", 15.0)
		GameState.set_flag("mvp_stability", 20.0)
		GameState.set_flag("mvp_experience", 17.5)
	SalesSystem.add_b2c_audience(200)
	SalesSystem.open_b2c_paid_tier(15)


# --- Fixture arithmetic (Calibration Round A §1) ---
# axis(s) = 100·s/(s+H) (QualityModel.normalized_quality) and its inverse. Fixture
# stability is DERIVED from the tolerance bars at seed time so each preset's documented
# intent line survives a tolerance move; _seed_stability_fixture prints the derived value
# and a PROBE ERROR if the intent inequality it was derived for no longer holds.
static func _raw_for_axis(axis: float) -> float:
	var a: float = clampf(axis, 0.0, 99.0)
	return QualityModel.NORMALIZE_HALF_SAT * a / (100.0 - a)


static func _axis_of(raw_stability: float, bugs: int) -> float:
	return QualityModel.axis_score({"stability": QualityModel.effective_stability(raw_stability, bugs)}, "stability")


static func _bar_small() -> float:
	return float(B2BConstants.seed_tolerance(2, ""))   # demo small archetype: scale_base 2, no sector


static func _bar_mid() -> float:
	return float(B2BConstants.seed_tolerance(3, ""))   # demo mid/enterprise: scale 3 (SCALE_DEMO_MAX), no sector


static func _seed_stability_fixture(preset: String, raw_stability: float, bugs: int) -> void:
	GameState.set_flag("mvp_stability", raw_stability)
	GameState.set_flag("mvp_live_bug_count", bugs)
	var live_axis: float = _axis_of(raw_stability, bugs)
	var clear_axis: float = _axis_of(raw_stability, 0)
	var ok: bool = true
	match preset:
		"b2b_solo":
			ok = live_axis >= _bar_small() + 3.0 and live_axis < _bar_mid()
		"b2b_slip":
			ok = live_axis >= _bar_mid() and live_axis < _bar_mid() + 5.0 and clear_axis >= _bar_mid() + 7.0
		"b2b_risk":
			ok = clear_axis < _bar_small() - 5.0
	print("PROBE FIXTURE preset=%s stability=%.1f bugs=%d axis_live=%.1f axis_clear=%.1f bar_small=%d bar_mid=%d" % [
		preset, raw_stability, bugs, live_axis, clear_axis, int(_bar_small()), int(_bar_mid())])
	if not ok:
		print("PROBE ERROR fixture drifted: %s no longer satisfies its intent inequality (re-derive after a tolerance move)" % preset)


static func _seed_b2b_world(rep_count: int) -> void:
	GameState.set_flag("mvp_shipped", true)
	# LAUNCH DAY, not just "shipped". These presets set the flag directly instead of going
	# through ship_active_build, which is the only writer of mvp_launch_day - so without
	# this line the fixture claims a live product with no launch date, and every
	# days_since_flag trigger reading it stays false forever (the paid-tier card, Frank v6
	# surface 7). A seeded world is "already live", so day 1 is the honest stamp.
	GameState.set_flag("mvp_launch_day", GameState.day)
	GameState.set_flag("mvp_market_type", "b2b")
	GameState.set_flag("mvp_sub_product_type_id", "saas_ops")
	GameState.set_flag("mvp_components", ["saas_ops_workflow", "saas_ops_reporting"])
	GameState.set_flag("mvp_version", 1)
	GameState.set_flag("mvp_product_name", "Sahra")
	# A MID product on purpose: with its 4 live bugs the stability AXIS sits above a small
	# account's tolerance bar and below a scaled one's, so the book holds a mix of steady
	# and sliding accounts instead of being uniformly safe or uniformly doomed. The
	# satisfaction TARGET is this axis (b2b_sales_system.gd:96-106), so it is the single
	# most load-bearing fixture value in the whole log — which is why it is DERIVED from
	# the live bars (Calibration Round A §1) rather than authored as a raw number (it was
	# 55 on the retired grown scale; under NORMALIZE_HALF_SAT 25 that reads "excellent").
	GameState.set_flag("mvp_innovation", 20.0)
	GameState.set_flag("mvp_experience", 22.5)
	_seed_stability_fixture("b2b_solo",
		_raw_for_axis((_bar_small() + 3.0 + _bar_mid()) * 0.5) + QualityModel.BUG_STABILITY_COEF * 4.0, 4)

	# Five accounts through the real signing seam (SalesSystem.add_b2b_customer — the
	# sole B2B signing path), spread across archetypes so tolerance seeds differ and the
	# CS request cadence phases apart (cs_request_phase strides by 9 per signing).
	# Total MRR is deliberately ~2.7K: a young book that is PAST the traction gate
	# (mvp_shipped + 1 customer + mrr > 0) and well SHORT of Series A (MRR ≥ 5000 +
	# brand ≥ 25). Seeded higher, the run rockets to phase 3 in two days and the log
	# stops describing the early game it is supposed to describe.
	#
	# Satisfaction seeds straddle the tolerance seeds on purpose (re-seated bars 2026-08-19:
	# 42 small / 51 mid and enterprise, before sector bonuses of +3/+5): probe_c and
	# probe_e start close enough to their bar that ordinary product wear can push them
	# under, which is the only way the retention → promise → churn chain is reachable
	# without hand-forcing it.
	var specs := [
		{"id": "probe_a", "name": "Kuzey Lojistik", "industry": "logistics", "star": 1, "seats": 7, "price": 50, "sat": 72},
		{"id": "probe_b", "name": "Ege Sağlık", "industry": "health", "star": 2, "seats": 16, "price": 50, "sat": 64},
		{"id": "probe_c", "name": "Marmara İnşaat", "industry": "construction", "star": 2, "seats": 14, "price": 50, "sat": 52},
		{"id": "probe_d", "name": "Toros Sigorta", "industry": "insurance", "star": 1, "seats": 6, "price": 50, "sat": 68},
		{"id": "probe_e", "name": "Anadolu Üretim", "industry": "manufacturing", "star": 3, "seats": 11, "price": 50, "sat": 57},
	]
	for s in specs:
		var p := Prospect.new()
		p.id = String(s["id"])
		p.company_name = String(s["name"])
		p.industry = String(s["industry"])
		# Satış rev 6 §2 — the STAR is the size, and `add_b2b_customer` copies it into
		# `Customer.scale`, which is what seeds the hidden tolerance. The old note here
		# warned that setting an archetype without also rolling a scale signed every
		# account at the small-account floor; one field cannot fall out of step with the
		# other any more, because there is only one field.
		p.star = int(s["star"])
		# §5.3 — the deal is SEATS x SEAT PRICE. The seat counts are inside each star's band
		# and the price is the Standard anchor, so the preset's MRR figures are unchanged
		# (350 / 800 / 700 / 300 / 550) and every measurement taken against them still reads.
		SalesSystem.add_b2b_customer(p, int(s["seats"]), int(s["price"]), int(s["sat"]))

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
