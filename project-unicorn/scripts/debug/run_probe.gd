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
#   PROBE GATE  day=<d> emp=<n> roles=<role:total/j-m-s,...> payroll_monthly=<n> <burn categories> ...
#                                           (full_run*: once, the day the Series A door opens)
#   PROBE MONTH_BURN day=<d> n=<n> salaries=<n> ... one_time=<n>   (full_run*: beside each PROBE MONTH)
#   PROBE VC_*  (full_run_vc_naive / full_run_vc_cautious only): VC_CONFIG, VC_BOOK, VC_MEET,
#               VC_TABLE_OPEN, VC_PUSH, VC_TABLE_END, VC_REPLAY, VC_REPLAY_SUM
#
# DEDUPE-REJECTED fires are NOT visible here — enqueue() returns silently when
# _queue_has_id() rejects a duplicate. They are counted from the engine's own
# "[EventManager] Dedupe-rejected: <id>" debug line, which is why that print exists.

const PRESETS := ["b2b_reps", "b2b_solo", "b2b_risk", "b2b_risk_keep",
	"b2b_slip", "b2b_slip_keep", "b2c", "b2c_keep", "b2c_neglect", "full_run", "full_run_weak",
	"full_run_naive", "full_run_discount", "full_run_vc_naive", "full_run_vc_cautious"]
# HANDOFF_series_a.md §E (2026-09) added two Series A policies on top of full_run. The world
# and the answer policy are full_run's ("sensible"); only what happens once the door is open
# differs — see "The Series A hunt" below. Sim mode only. An optional fifth spec part
# `replay=<K>` sets the naive preset's per-fund table replays (default 20; 0 turns them off).
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
static var _gate_day: int = -1              # the day phase_gate_reached(3) fired (PROBE GATE)
static var _gate_logged: bool = false
static var _mb_acc: Dictionary = {}         # burn id -> realised sum over the open fiscal month
static var _mb_days: int = 0                # dispatch days folded into _mb_acc
static var _mb_folded_day: int = -1         # a close day whose burn month_ended already folded in
static var _vc_policy: String = ""          # "" | "naive" | "cautious" (full_run_vc_* presets)
static var _replay_k: int = -1              # naive only: table replays per fund; -1 = not given
static var _vc_done: bool = false           # the one table this run gets has been played
static var _vc_booked: String = ""          # the fund the current booking is with
static var _vc_meet_day: int = -1           # the day the last meeting was played
const TABLE_PUSH_CAP := 64                  # runaway backstop for a push loop, never reached in play


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
	# Optional 5th+ parts: named options. Today only replay=<K> (full_run_vc_naive).
	_replay_k = -1
	for idx in range(4, parts.size()):
		var extra: String = String(parts[idx])
		if extra.begins_with("replay="):
			_replay_k = maxi(0, int(extra.trim_prefix("replay=")))
	if not PRESETS.has(_preset):
		print("PROBE ERROR unknown preset '%s' (have %s)" % [_preset, ", ".join(PRESETS)])
		return

	_fires.clear()
	_picks.clear()
	_full_run = false
	_hire_started = false
	_build_promises = false
	_gate_day = -1
	_gate_logged = false
	_mb_acc = {}
	_mb_days = 0
	_mb_folded_day = -1
	_vc_policy = ""
	_vc_done = false
	_vc_booked = ""
	_vc_meet_day = -1
	GameState.initialize_run(payload)
	# Pin the seed so two probe runs of the same preset are comparable line for line —
	# the same reason --tempo-probe pins it (main.gd:327-331). initialize_run seeds from
	# Time.get_ticks_msec(), which would make every fire table a one-off.
	GameState.run_seed = _run_seed
	seed(GameState.run_seed)
	RngStreams.reseed(GameState.run_seed)   # the named streams, not just the global generator
	_wire_log()
	_seed_world(_preset)
	if _vc_policy == "naive":
		_replay_k = 20 if _replay_k < 0 else _replay_k
	else:
		_replay_k = 0
	if _vc_policy != "" and _mode != "sim":
		# The real clock plays the founder BEFORE the day's dispatch, so the meeting card and
		# the table would land a day apart from sim. The policies are defined on sim only.
		print("PROBE ERROR %s is sim-only" % _preset)
		Engine.get_main_loop().quit()
		return

	print("PROBE BEGIN preset=%s days=%d mode=%s seed=%d" % [_preset, _stop_day, _mode, GameState.run_seed])
	if _vc_policy != "":
		print("PROBE VC_CONFIG policy=%s replay=%d" % [_vc_policy, _replay_k])
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
	EventBus.phase_gate_reached.connect(_on_gate_reached)
	EventBus.day_tick_completed.connect(_on_day_tick_completed)


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
	if _full_run:
		_log_month_burn(e, n)


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


# ============================================================================
#  B2 measurement: the gate-open day and the realised month (all full_run presets)
# ============================================================================
#
# Read-only lines, added for HANDOFF_series_a.md §C. They draw no randomness and write no
# state, so every other PROBE line of a full_run is byte-identical with or without them.

static func _on_gate_reached(next_phase: int) -> void:
	# The Series A door is the gate whose next phase is 3. It fires in the phase-check slot of
	# the daily dispatch; the snapshot is printed with that day's PROBE STATE (_log_state), so
	# both lines describe the same moment — after the day's cards and the founder's moves.
	if next_phase == 3 and _gate_day < 0:
		_gate_day = GameState.day


static func _on_day_tick_completed(day: int) -> void:
	if not _full_run:
		return
	if _mb_folded_day != day:      # a month-close day was already folded in inside month_ended
		_mb_add_today()


## Today's burn, by category. The breakdown is written in the finance slot and nothing but
## the next day's first slot rewrites it, so after the dispatch it is exactly what accrued.
static func _mb_add_today() -> void:
	var bd: Dictionary = FinanceSystem.get_burn_breakdown()
	for raw in FinanceSystem.BURN_IDS:
		var k: String = String(raw)
		_mb_acc[k] = int(_mb_acc.get(k, 0)) + int(bd.get(k, 0))
	_mb_days += 1


## PROBE MONTH_BURN — the closed month's expense split into the burn categories. one_time is
## what the categories do not explain: the one-off charges (hire commission, severance,
## training, build commits) that accrue straight into the month's expense.
static func _log_month_burn(e: Dictionary, n: int) -> void:
	_mb_add_today()                 # the 1st's own burn accrued BEFORE this close, so it is in it
	_mb_folded_day = GameState.day
	var cat: int = 0
	for raw in FinanceSystem.BURN_IDS:
		cat += int(_mb_acc.get(String(raw), 0))
	var s0: int = int(e.get("start_day", 0))
	var e0: int = int(e.get("end_day", 0))
	var exp: int = int(e.get("expense", 0))
	print("PROBE MONTH_BURN day=%d n=%d start=%d end=%d days=%d days_expected=%d salaries=%d overtime=%d founder=%d servers=%d marketing=%d office=%d cat_sum=%d expense=%d one_time=%d income=%d" % [
		GameState.day, n, s0, e0, _mb_days, e0 - s0,
		int(_mb_acc.get("salaries", 0)), int(_mb_acc.get("overtime", 0)), int(_mb_acc.get("founder", 0)),
		int(_mb_acc.get("servers", 0)), int(_mb_acc.get("marketing", 0)), int(_mb_acc.get("office", 0)),
		cat, exp, exp - cat, int(e.get("income", 0))])
	_mb_acc = {}
	_mb_days = 0


## PROBE GATE — the company on the day the Series A door opens: who is on the payroll, what
## a month costs at today's rate, what the last closed month actually cost, and the margins.
## "office" is printed as the finance system holds it (a TODO hook at 0); nothing is assumed.
static func _log_gate() -> void:
	var staff: Array[Character] = CharacterRegistry.get_employees()
	var by_role: Dictionary = {}          # role -> [total, junior, mid, senior]
	var on_leave: int = 0
	for c in staff:
		var r: String = String(c.role)
		var row: Array = by_role.get(r, [0, 0, 0, 0])
		row[0] = int(row[0]) + 1
		var lv: int = clampi(int(c.level), HRConstants.LEVEL_JUNIOR, HRConstants.LEVEL_SENIOR)
		row[1 + lv] = int(row[1 + lv]) + 1
		by_role[r] = row
		if String(c.status) == HRConstants.STATUS_ON_LEAVE:
			on_leave += 1
	var order: Array = HRConstants.EMPLOYEE_ROLES.duplicate()
	for r in by_role.keys():
		if not order.has(r):
			order.append(r)
	var parts: Array[String] = []
	for r in order:
		var row: Array = by_role.get(r, [0, 0, 0, 0])
		parts.append("%s:%d/%d-%d-%d" % [String(r), int(row[0]), int(row[1]), int(row[2]), int(row[3])])
	var bd: Dictionary = FinanceSystem.get_burn_breakdown()
	var bd_sum: int = 0
	for raw in FinanceSystem.BURN_IDS:
		bd_sum += int(bd.get(String(raw), 0))
	var runrate: int = GameState.daily_burn * 30
	var rr_margin: String = "n/a"
	if GameState.mrr > 0:
		rr_margin = str(int((GameState.mrr - runrate) * 100 / GameState.mrr))
	var last_n: int = GameState.month_history.size()
	var last: Dictionary = GameState.month_history[last_n - 1] if last_n > 0 else {}
	var last_income: int = int(last.get("income", 0))
	var last_expense: int = int(last.get("expense", 0))
	var last_net: int = int(last.get("net", 0))
	var last_margin: String = "n/a"
	if last_income > 0:
		last_margin = str(int(last_net * 100 / last_income))
	print("PROBE GATE day=%d emp=%d on_leave=%d roles=%s payroll_monthly=%d salaries=%d overtime=%d founder=%d servers=%d marketing=%d office=%d bd_sum=%d daily_burn=%d expense_runrate=%d mrr=%d runrate_margin_pct=%s cust=%d accounts=%d cash=%d last_n=%d last_start=%d last_end=%d last_income=%d last_expense=%d last_net=%d last_margin_pct=%s win3_margin_pct=%d win6_margin_pct=%d profit_streak=%d growth_avg_pct=%d" % [
		GameState.day, staff.size(), on_leave, ",".join(parts), CharacterRegistry.get_total_monthly_salaries(),
		int(bd.get("salaries", 0)), int(bd.get("overtime", 0)), int(bd.get("founder", 0)),
		int(bd.get("servers", 0)), int(bd.get("marketing", 0)), int(bd.get("office", 0)), bd_sum,
		GameState.daily_burn, runrate, GameState.mrr, rr_margin,
		CustomerRegistry.get_all().size(), CustomerRegistry.account_count(), GameState.cash,
		last_n, int(last.get("start_day", -1)), int(last.get("end_day", -1)), last_income, last_expense, last_net, last_margin,
		GameState.get_window_margin_pct(3), GameState.get_window_margin_pct(6),
		GameState.get_profitable_month_streak(), GameState.get_mom_growth_avg_pct(PitchConstants.ARR_WINDOW_MONTHS)])


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
	# K1–K3 (2026-09): the Series A door is MRR only, so the gate reading is the signal state
	# plus Frank's approach step (0-4, phase.series_a_approach) — the growth streak is no
	# longer a gate half. It is still logged on the PROBE MONTH line, where it feeds the
	# valuation band rather than the door.
	print("PROBE STATE day=%d cash=%d mrr=%d brand=%d burn=%d runway=%s cust=%d emp=%d promises=%d phase=%d aud=%d sat=%d bugs=%d q=%.1f appetite=%s approach=%d gate_ready=%s profit_streak=%d" % [
		GameState.day, GameState.cash, GameState.mrr, GameState.brand, GameState.daily_burn,
		("INF" if is_inf(runway) else "%.2f" % runway),
		CustomerRegistry.get_all().size(), CharacterRegistry.get_employees().size(),
		PromiseRegistry.get_all().size(), GameState.phase,
		int(GameState.get_flag("b2c_audience", 0)), (ub.satisfaction if ub != null else -1),
		int(GameState.get_flag("mvp_live_bug_count", 0)), q,
		appetite, int(sig.get("approach", 0)), str(GameState.phase_gate_ready), GameState.get_profitable_month_streak()])
	if appetite != _last_appetite:
		print("PROBE SIGNAL day=%d appetite=%s->%s mrr=%d approach=%d" % [
			GameState.day, _last_appetite, appetite, GameState.mrr, int(sig.get("approach", 0))])
		_last_appetite = appetite
	if _full_run and _gate_day == GameState.day and not _gate_logged:
		_gate_logged = true
		_log_gate()


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
	if _vc_policy != "" and not _vc_done:
		_vc_end("UNRESOLVED", "phase<3" if GameState.phase < 3 else "run_over")
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
		if _vc_policy != "":
			_play_the_hunt()
			if not GameState.run_active:
				return          # a signature ended the run; nothing else happens today
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
#  The Series A hunt (full_run_vc_naive / full_run_vc_cautious only)
# ============================================================================
#
# HANDOFF_series_a.md §E asks what share of term-sheet tables end in a signature, a final
# offer or the fund walking out when a naive founder plays them. The bot never met a VC, so
# these two policies are the working definitions the owner wrote:
#   naive    — once the door is open, book the first fund that will meet; at the table push
#              a random lever until patience runs out; sign a final offer.
#   cautious — the same meeting; sign the opening terms without a single push (the baseline).
# The meeting is played identically by both, so the two runs are the same run up to the
# table. The lever draw comes from a probe-local generator seeded per table with an EvDice
# hash of seed/day/ids — never a stream the game draws from — and nothing acts before
# phase 3: a VC preset is full_run until the door opens.

static func _play_the_hunt() -> void:
	if _vc_done or not GameState.run_active or GameState.phase < 3 or TermSheetTableSystem.is_active():
		return
	# 1. The drain answered funding.meeting_day with "go", which seated the meeting. Play it.
	if VCPitchSystem.is_meeting_active():
		_play_the_meeting()
		_vc_meet_day = GameState.day
	# 2. A live Series A sheet: sit down the day it arrives (so the K10 card never comes).
	if not GameState.active_sheets.is_empty():
		var ts: TermSheet = GameState.active_sheets[0] as TermSheet
		_play_the_table(String(ts.vc_id))
		return
	# 3. Waiting on a booked meeting or a queued sheet.
	if not GameState.pending_meeting.is_empty() or EndingsSystem._any_pending_sheet():
		var pm_day: int = int(GameState.pending_meeting.get("day", -1))
		if not GameState.pending_meeting.is_empty() and pm_day >= 0 and pm_day < GameState.day - 5:
			print("PROBE ERROR day=%d booked meeting (day %d) never started" % [GameState.day, pm_day])
		return
	if _vc_meet_day == GameState.day:
		return                          # a refusal today: the next fund is booked tomorrow
	# 4. Book the first fund that will meet, in the registry's order.
	for raw in InvestorRegistry.get_active():
		var vc: String = String((raw as Dictionary).get("id", ""))
		var st: Dictionary = GameState.vc_states.get(vc, {}) as Dictionary
		if String(st.get("status", "open")) == "callback":
			continue
		if VCPitchSystem.meeting_blocked_reason(vc) != "":
			continue
		if VCPitchSystem.request_meeting(vc):
			_vc_booked = vc
			print("PROBE VC_BOOK day=%d fund=%s meet_day=%d meetings=%d rejections=%d mrr=%d brand=%d" % [
				GameState.day, vc, int(GameState.pending_meeting.get("day", 0)),
				int((GameState.vc_states.get(vc, {}) as Dictionary).get("meeting_count", 0)),
				GameState.vc_rejections, GameState.mrr, GameState.brand])
			return
	# Nothing left to book: no table this run. The replays still sample the four funds.
	if _vc_policy == "naive" and _replay_k > 0:
		_run_replays()
	_vc_end("NO_TABLE", "road_closed" if VCPitchSystem.series_a_road_closed() else "none_bookable")


static func _choice_ids(vs: Dictionary) -> Array[String]:
	var out: Array[String] = []
	for c in (vs.get("choices", []) as Array):
		out.append(String((c as Dictionary).get("id", "")))
	return out


## The meeting rule, the same for both policies: read the room; take the angle with the best
## odds the room shows (then the easier one, then list order); answer the question honestly;
## at a lukewarm fork, press for the sheet.
static func _meeting_pick(ids: Array[String]) -> String:
	var best: String = ""
	var best_c: float = -1.0
	var best_d: int = 99
	for id in ids:
		if not id.begins_with("b2_"):
			continue
		var a: String = id.trim_prefix("b2_")
		var d: int = VCPitchSystem._angle_diff(a)
		var c: float = SkillCheck.chance_for(VCPitchSystem._angle_skill(a), d, VCPitchSystem._beat2_bonus(a))
		if c > best_c or (c == best_c and d < best_d):
			best = id
			best_c = c
			best_d = d
	if best != "":
		return best
	for want in ["b1_read", "b3_durust", "b4_zorla"]:
		if ids.has(want):
			return String(want)
	return ids[0]


static func _play_the_meeting() -> void:
	var fund: String = VCPitchSystem._vc_id
	if fund != _vc_booked:
		print("PROBE ERROR day=%d meeting fund %s is not the booked %s" % [GameState.day, fund, _vc_booked])
	var conv0: int = VCPitchSystem._conviction
	var trace: Array[String] = []
	var ids: Array[String] = ["b1_read"]   # Beat 1 has one row, and its resolver ignores the id
	var guard: int = 0
	while VCPitchSystem.is_meeting_active() and guard < 8:
		guard += 1
		var pick: String = _meeting_pick(ids)
		var before: int = VCPitchSystem._conviction
		var res: Dictionary = VCPitchSystem.advance(pick)
		if bool(res.get("done", false)):
			trace.append("%s:%d>end" % [pick, before])
			break
		trace.append("%s:%d>%d" % [pick, before, VCPitchSystem._conviction])
		ids = _choice_ids(res.get("view_state", {}) as Dictionary)
		if ids.is_empty():
			print("PROBE ERROR day=%d meeting view has no choices after %s" % [GameState.day, pick])
			break
	if VCPitchSystem.is_meeting_active():
		print("PROBE ERROR day=%d meeting did not finish" % GameState.day)
	var st: Dictionary = GameState.vc_states.get(fund, {}) as Dictionary
	print("PROBE VC_MEET day=%d fund=%s n=%d conv0=%d path=%s result=%s sheet_conv=%d rejections=%d brand=%d" % [
		GameState.day, fund, int(st.get("meeting_count", 0)), conv0, ",".join(trace),
		String(st.get("status", "?")), int(st.get("sheet_conviction", -1)), GameState.vc_rejections, GameState.brand])


static func _pushable_levers() -> Array[String]:
	var out: Array[String] = []
	for l in TermSheetTableSystem.levers():
		if TermSheetTableSystem.can_push(String(l)):
			out.append(String(l))
	return out


## Push random levers until patience is gone (final offer or walk-out) or nothing can move.
## A fresh lever is drawn on EVERY push from a probe-local generator seeded once per table
## (run seed, kind, day, key) — never a stream the game draws from. Not EvDice per push: its
## hash keeps the low bits, so keys that differ only in a trailing push index land on nearly
## the same number and every push would pick the same lever.
static func _push_until_done(kind: String, key: String, fund: String, log_each: bool) -> Dictionary:
	var pushes: int = 0
	var wins: int = 0
	var state: int = TermSheetTableSystem.IDLE
	var seq: Array[String] = []
	var pick := RandomNumberGenerator.new()
	pick.seed = EvDice.fnv1a("%d|%s|%d|%s" % [GameState.run_seed, kind, GameState.day, key])
	while pushes < TABLE_PUSH_CAP:
		var pl: Array[String] = _pushable_levers()
		if pl.is_empty():
			break
		var lever: String = pl[pick.randi_range(0, pl.size() - 1)]
		seq.append(lever.substr(0, 1))
		TermSheetTableSystem.select_lever(lever)
		var pv: Dictionary = TermSheetTableSystem.push()
		pushes += 1
		state = int(pv.get("state", 0))
		var ok: bool = state == TermSheetTableSystem.PUSH_SUCCESS
		if ok:
			wins += 1
		if log_each:
			print("PROBE VC_PUSH day=%d fund=%s n=%d lever=%s success=%s e=%d patience=%d band=%s state=%d" % [
				GameState.day, fund, pushes, lever, str(ok), TermSheetTableSystem.eagerness(),
				int((pv.get("patience", {}) as Dictionary).get("current", -1)), String(pv.get("eagerness_band", "")), state])
		if state == TermSheetTableSystem.PATIENCE_ZERO or state == TermSheetTableSystem.FUND_WALKED:
			break
	if pushes >= TABLE_PUSH_CAP:
		print("PROBE ERROR day=%d fund=%s push cap reached" % [GameState.day, fund])
	return {"pushes": pushes, "wins": wins, "state": state, "levers": "".join(seq)}


static func _play_the_table(vc: String) -> void:
	if GameState.seed_sheet != null:
		print("PROBE ERROR day=%d a seed sheet is present — open() would seat the seed table" % GameState.day)
	var sheet: TermSheet = VCPitchSystem.sheet_for(vc)
	if sheet == null:
		_vc_end("NO_TABLE", "no_sheet")
		return
	if _vc_policy == "naive" and _replay_k > 0:
		_run_replays()                  # the table is still closed: same company, same day
	var ov: Dictionary = TermSheetTableSystem.open(vc)
	if ov.is_empty():
		_vc_end("NO_TABLE", "open_failed")
		return
	var e0: int = TermSheetTableSystem.eagerness()
	var fit: int = TermSheetTableSystem._domain_fit()
	var thr: int = TermSheetTableSystem.walk_threshold()
	var t0: Dictionary = TermSheetTableSystem._terms.duplicate()
	print("PROBE VC_TABLE_OPEN day=%d fund=%s conv=%d fit=%d e0=%d patience=%d thr=%d band=%s val_m=%d dil=%d board=%d veto=%s" % [
		GameState.day, vc, sheet.conviction, fit, e0, int((ov.get("patience", {}) as Dictionary).get("max", 0)), thr,
		String(ov.get("eagerness_band", "")), int(t0.get("valuation_m", 0)), int(t0.get("dilution_pct", 0)),
		int(t0.get("board_seats", 0)), str(bool(t0.get("board_veto", false)))])
	var r: Dictionary = {"pushes": 0, "wins": 0, "levers": ""}
	if _vc_policy == "naive":
		r = _push_until_done("probe_vc_lever", vc, vc, true)
	# Read BEFORE sign(): signing resets the table's state.
	var ev: Dictionary = TermSheetTableSystem.view_state()
	var walked: bool = bool(ev.get("fund_walked", false))
	var outcome: String = "SIGNED_NO_FINAL"
	if walked:
		outcome = "FUND_WALKED"
	elif int(ev.get("state", 0)) == TermSheetTableSystem.PATIENCE_ZERO:
		outcome = "SIGNED_FINAL"
	var t1: Dictionary = TermSheetTableSystem._terms.duplicate()
	# A walked table raised nothing: its working terms are printed, its money is not.
	var money: String = "-" if walked else str(TermSheetTableSystem.money_raised())
	print("PROBE VC_TABLE_END day=%d fund=%s policy=%s outcome=%s e0=%d e_end=%d thr=%d pushes=%d wins=%d levers=%s patience_left=%d val_m=%d dil=%d board=%d veto=%s money=%s rejections=%d" % [
		GameState.day, vc, _vc_policy, outcome, e0, TermSheetTableSystem.eagerness(), thr, int(r.pushes), int(r.wins),
		String(r.get("levers", "")), int((ev.get("patience", {}) as Dictionary).get("current", 0)), int(t1.get("valuation_m", 0)),
		int(t1.get("dilution_pct", 0)), int(t1.get("board_seats", 0)), str(bool(t1.get("board_veto", false))),
		money, GameState.vc_rejections])
	_vc_done = true
	if walked:
		TermSheetTableSystem.leave()    # the closure is already written by the fund's walk-out
	else:
		TermSheetTableSystem.sign()     # → EndingsSystem.trigger_ending("series_a_close")


static func _vc_end(outcome: String, reason: String) -> void:
	print("PROBE VC_TABLE_END day=%d fund=- policy=%s outcome=%s reason=%s pushes=0 rejections=%d" % [
		GameState.day, _vc_policy, outcome, reason, GameState.vc_rejections])
	_vc_done = true


# --- Replays (naive only) ------------------------------------------------------
#
# One run gives at most one table: signing ends the run, and a fund walking out marks the
# Series A decision faced, which a profitable company at the door turns into the bootstrap
# ending the next day. So each naive run also replays the table, from the SAME company on
# the SAME day, K times per fund: a fresh sheet stamped at the win line (70), the fund's real
# fit, a reseeded skill stream. Nothing is signed. Afterwards every touched field and the
# skill stream go back exactly, and a fingerprint of everything a save carries (GameState, the
# registries, every system block incl. the event engine and the RNG streams) plus the event
# engine's pending signal buffer proves it.

static func _vc_capture() -> Dictionary:
	return {
		"sheets": GameState.active_sheets.duplicate(),          # the same TermSheet objects
		"vc_states": GameState.vc_states.duplicate(true),
		"rej": GameState.vc_rejections,
		"faced": GameState.faced_series_a,
		"faced_by": GameState.faced_series_a_by,
		"pa": GameState.run_pushes_attempted,
		"pw": GameState.run_pushes_won,
	}


static func _vc_restore(s: Dictionary) -> void:
	GameState.active_sheets.clear()
	GameState.active_sheets.append_array(s["sheets"] as Array)
	GameState.vc_states.clear()
	GameState.vc_states.merge((s["vc_states"] as Dictionary).duplicate(true))
	GameState.vc_rejections = int(s["rej"])
	GameState.faced_series_a = bool(s["faced"])
	GameState.faced_series_a_by = String(s["faced_by"])
	GameState.run_pushes_attempted = int(s["pa"])
	GameState.run_pushes_won = int(s["pw"])


static func _state_fingerprint() -> Dictionary:
	return {"gs": SaveCodec.capture_game_state(), "reg": SaveCodec.capture_registries(),
		"sys": SaveManager._capture_systems(), "ev_buf": EvEngine._signal_buffer.size()}


static func _run_replays() -> void:
	if TermSheetTableSystem.is_active() or VCPitchSystem.is_meeting_active() or not GameState.run_active:
		print("PROBE ERROR day=%d replays need a closed table and a live run" % GameState.day)
		return
	var fp0: Dictionary = _state_fingerprint()
	var snap: Dictionary = _vc_capture()
	var rng: RandomNumberGenerator = RngStreams.get_stream(RngStreams.STREAM_SKILL)
	var seed0: int = rng.seed
	var state0: int = rng.state
	for raw in InvestorRegistry.get_active():
		var fund: String = String((raw as Dictionary).get("id", ""))
		var nf: int = 0
		var nw: int = 0
		var nx: int = 0
		var e0_f: int = -1
		var fit_f: int = 0
		var thr_f: int = -1
		for i in _replay_k:
			rng.seed = EvDice.fnv1a("%d|probe_vc_replay_rng|%s|%d" % [GameState.run_seed, fund, i])
			GameState.active_sheets.clear()               # ONE sheet: no leverage from another
			var sh: TermSheet = VCPitchSystem._make_sheet(fund, GameState.day)
			sh.conviction = TermSheetTableSystem.E_FALLBACK_CONV_SERIES_A
			GameState.active_sheets.append(sh)
			TermSheetTableSystem.open(fund)
			var e0: int = TermSheetTableSystem.eagerness()
			var fit: int = TermSheetTableSystem._domain_fit()
			var thr: int = TermSheetTableSystem.walk_threshold()
			var r: Dictionary = _push_until_done("probe_vc_replay_lever", "%s#%d" % [fund, i], fund, false)
			var st: int = int(r.state)
			var outcome: String = "EXHAUSTED"
			if st == TermSheetTableSystem.PATIENCE_ZERO:
				outcome = "FINAL_OFFER"
				nf += 1
			elif st == TermSheetTableSystem.FUND_WALKED:
				outcome = "FUND_WALKED"
				nw += 1
			else:
				nx += 1
			print("PROBE VC_REPLAY day=%d fund=%s i=%d outcome=%s e0=%d fit=%d thr=%d pushes=%d wins=%d levers=%s e_end=%d" % [
				GameState.day, fund, i, outcome, e0, fit, thr, int(r.pushes), int(r.wins), String(r.levers), TermSheetTableSystem.eagerness()])
			e0_f = e0
			fit_f = fit
			thr_f = thr
			TermSheetTableSystem.reset()      # not leave(): leave() only closes a walked-out table
			_vc_restore(snap)
		print("PROBE VC_REPLAY_SUM day=%d fund=%s n=%d final=%d walked=%d exhausted=%d walk_pct=%.1f e0=%d fit=%d thr=%d" % [
			GameState.day, fund, _replay_k, nf, nw, nx, 100.0 * float(nw) / float(maxi(_replay_k, 1)), e0_f, fit_f, thr_f])
	rng.seed = seed0          # seed first: setting it resets state
	rng.state = state0
	var fp1: Dictionary = _state_fingerprint()
	if fp1 != fp0:
		var bad: Array[String] = []
		var g0: Dictionary = fp0["gs"] as Dictionary
		var g1: Dictionary = fp1["gs"] as Dictionary
		for k in g0.keys():
			if g0[k] != g1.get(k):
				bad.append(String(k))
		if fp0["reg"] != fp1["reg"]:
			bad.append("registries")
		var s0: Dictionary = fp0["sys"] as Dictionary
		var s1: Dictionary = fp1["sys"] as Dictionary
		for k in s0.keys():
			if s0[k] != s1.get(k):
				bad.append("sys." + String(k))
		if int(fp0["ev_buf"]) != int(fp1["ev_buf"]):
			bad.append("ev_signal_buffer")
		print("PROBE ERROR day=%d replay left a trace: %s" % [GameState.day, ",".join(bad)])


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
		_vc_policy = "naive" if preset == "full_run_vc_naive" else ("cautious" if preset == "full_run_vc_cautious" else "")
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
	# (mvp_shipped + 1 customer + mrr > 0) and well SHORT of Series A (MRR at the
	# SalesSystem.TRACTION_MRR_TARGET bar — MRR only since K1 + K2). Seeded higher, the run rockets to phase 3 in two days and the log
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
