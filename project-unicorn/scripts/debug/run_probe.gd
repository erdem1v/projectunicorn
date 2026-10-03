class_name RunProbe
extends RefCounted

# Headless RUN LOG harness — event fire log, churn-chain autopsy and the played run.
# Debug builds only; main.gd runs it for --run-log=<preset>:<weeks>:<mode>.
#
# The probe is "the player". It mounts no shell and no modals: it drives the real tick
# dispatch and answers every decision through the seam the modal calls (EventGate.resolve),
# so the engine cannot tell it apart from a human except by the choice policy, which is
# deterministic and printed.
#
# Not a smoke case: it asserts nothing. It EMITS A LEDGER (every event fire with its source,
# every choice, daily economy state) that a human reads to find out what the game actually
# does over a run.
#
# Drive modes:
#   sim     — the game's clock without the wall clock: every visible hour is its own one-hour
#             TimeManager.advance_hours batch, answered before the next, and the night is one
#             skip_night batch (the rollover and the daily tick inside it). Deterministic, instant.
#   1|2|3|4 — the REAL clock at that speed index (TimeManager._advance_real, frame pacing and
#             all). The only mode that can catch a real-time-only defect.
# In both the founder sits the sales meetings when the week opens (the first 08:00, then every
# night_skipped) and takes the desk decisions at every visible hour, as a player at the keyboard.
#
# Output contract — one line per record, all prefixed PROBE so a grep separates them
# from the engine's own log lines:
#   PROBE BEGIN preset=<p> weeks=<n> mode=<m> seed=<s>
#   PROBE FIRE  day=<d> hour=<h> id=<id> src=<src>
#   PROBE PICK  day=<d> id=<id> choice=<i> label=<label>
#   PROBE STATE day=<d> cash=<n> mrr=<n> brand=<n> burn=<n> runway=<f> cust=<n> emp=<n> promises=<n>
#   PROBE B2C   day=<d> aud=<f> paying=<n> price=<n> conv=<f> sat=<n> sat_target=<n> live_bugs=<n>
#               confirmed=<n> q=<f> interest=<f> occ=<f> desk=<n> incoming=<n> inflow_day=<f>
#               validation_day=<f>          (every week a consumer product is live; desk = the
#                                           support desk's roster, inflow and validation per day)
#   PROBE CHURN day=<d> id=<cid> ...        (customer_churned — the autopsy's terminal)
#   PROBE PROMISE day=<d> id=<pid> status=<s> ...
#   PROBE TALLY <id> fires=<n> picks=<n>    (one per id, at the end)
#   PROBE END   day=<d> run_active=<b> ending=<id> finite_runway_p<1|2|3>=<finite weeks>/<weeks>
#               min_cash_pre_seed=<n> seed_day=<n|-1>   (the weeks are the weekly STATE readings,
#                                           by phase; seed_day is the day the seed was signed)
#   PROBE HR    hires=<n> emp=<n> payroll=<n> morale_avg=<f|-> below50=<n> min=<n|->
#   PROBE GATE  day=<d> emp=<n> roles=<role:total/j-m-s,...> payroll_monthly=<n> <burn id>=<n>... ...
#                                           (full_run*: once, the day the Series A door opens)
#   PROBE MONTH_BURN day=<d> n=<n> ticks=<n> <burn id>=<n>... one_time=<n>   (full_run*: beside each PROBE MONTH)
#               The burn ids are FinanceSystem.BURN_IDS, in its order.
#   PROBE SPRINT day=<d> n=<n> label=<v1.x|-> shipped=<card ids> carried=<n> velocity=<done>/<capacity>
#   PROBE SHIP  day=<d> version=<n> ...      (a public release: the MVP and every version after it)
#   PROBE VC_*  (the presets with a Series A policy): VC_CONFIG, VC_BOOK, VC_MEET,
#               VC_TABLE_OPEN, VC_PUSH, VC_TABLE_END, VC_REPLAY, VC_REPLAY_SUM

## Every preset. The fixture presets ({}) seed their world in _seed_world. The played runs
## (full_run*) seed nothing and carry what the founder picks and plays by:
##   subtype   — the product chosen in the Product tab on the first morning;
##   policy    — the event answers (default "sensible", below);
##   vc        — the Series A policy, sim only (none: the run never sits at a Series A table);
##   staff_cap — the headcount the B2B staffing ladder stops at (default: the whole ladder);
##   k1_only   — the founder never plans a K2 or K3 step.
const PRESETS := {
	"b2b_reps": {}, "b2b_solo": {}, "b2b_risk": {}, "b2b_slip": {}, "b2c": {}, "b2c_neglect": {},
	"full_run": {"subtype": "erp"},
	"full_run_naive": {"subtype": "erp", "policy": "naive"},
	"full_run_discount": {"subtype": "erp", "policy": "discount"},
	"full_run_vc_naive": {"subtype": "erp", "vc": "naive"},
	"full_run_vc_cautious": {"subtype": "erp", "vc": "cautious"},
	"full_run_lean": {"subtype": "erp", "vc": "walk", "staff_cap": 7},
	"full_run_b2c": {"subtype": "note_tool"},
	"full_run_b2c_video": {"subtype": "video_clip"},
	"full_run_b2c_vc_cautious": {"subtype": "note_tool", "vc": "cautious"},
	"full_run_b2c_vc_walk": {"subtype": "note_tool", "vc": "walk"},
	"full_run_b2c_k1": {"subtype": "note_tool", "k1_only": true},
}
const PRODUCT_NAMES := {"erp": "Sahra", "note_tool": "Notly", "video_clip": "Klipo"}
# The played run has three answer policies on one world, a controlled experiment on what
# the event cards do to the revenue curve:
#   full_run          — "sensible": a promise when one is open, then a stall, and a
#                       discount only when nothing else is left.
#   full_run_naive    — always the first unlocked row.
#   full_run_discount — the discount first, every time it is offered.
# The Series A policies sit on top of the sensible answers (sim only): only what happens once
# the door is open differs — see "The Series A hunt". An optional fifth spec part `replay=<K>`
# sets the naive table's per-fund replays (default 20; 0 turns them off).
#   full_run_lean     — B2B that stops hiring at seven people and walks the table: the bootstrap
#                       road, since profitable_bootstrap needs the Series A decision faced.
#   full_run_b2c*     — the consumer runs: the founder adds the paid plan card once it unlocks,
#                       never starts a sprint of research alone while a step is open, takes the
#                       support desk once anyone pays, and hires on B2C_LADDER beside the reps
#                       the desk needs.
#   full_run_b2c_k1   — the consumer run that stops at the K1 steps: how far K1 alone carries.
# Every played run takes the seed round the week its door opens — see "The seed round".
# The fixtures:
#   b2c           — a consumer product the sprint engine builds itself, the lead planning every
#                   sprint; its MVP release brings the launch audience and opens the paid tier.
#   b2c_neglect   — a stability-poor, bug-heavy B2C fixture nobody tends: satisfaction erodes.
#   The B2B fixtures and b2c_neglect seed a live product on a catalogue subtype without line
#   content, so they have no sprints.

static var _fires: Dictionary = {}      # id -> fire count
static var _picks: Dictionary = {}      # id -> resolve count
static var _stop_day: int = 0              # the tick (week) the run stops on
static var _stopped: bool = false
static var _preset: String = ""
static var _mode: String = ""
static var _wired: bool = false
static var _full_run: bool = false         # "full_run": day 1, nothing seeded, the founder plays it
static var _hire_started: bool = false
static var _last_appetite: String = ""     # PROBE SIGNAL on change
static var _discount_uses: Dictionary = {}  # customer id -> discounts taken
static var _policy: String = "sensible"     # full_run answer policy: sensible | naive | discount
static var _subtype: String = ""            # full_run*: the product chosen on the first morning
static var _staff_cap: int = 0              # full_run*: the headcount the B2B ladder stops at
static var _k1_only: bool = false           # full_run*: never plan a K2 or K3 step
static var _runway_weeks: Dictionary = {}   # phase -> Vector2i(weeks with a finite runway, weeks)
static var _min_cash_pre_seed: int = 0      # the lowest weekly cash before the seed round closed
static var _run_seed: int = 424242
static var _fix_on_at: float = 0.0         # clock day (TimeModel.days) the running fix pass started
static var _fix_off_at: float = -INF        # clock day the last fix pass ended
static var _fixer_id: String = ""           # the developer lent to the support desk for it
static var _fires_by_day: Dictionary = {}   # tick -> card fires that week, for PROBE WEEK
static var _gate_day: int = -1              # the day phase_gate_reached(3) fired (PROBE GATE)
static var _gate_logged: bool = false
static var _mb_acc: Dictionary = {}         # burn id -> realised sum over the open fiscal month
static var _mb_ticks: int = 0               # dispatched ticks folded into _mb_acc
static var _vc_policy: String = ""          # "" | "naive" | "cautious" | "walk"
static var _replay_k: int = -1              # naive only: table replays per fund; -1 = not given
static var _vc_done: bool = false           # the one table this run gets has been played
static var _vc_booked: String = ""          # the fund the current booking is with
static var _vc_meet_day: int = -1           # the day the last meeting was played
const TABLE_PUSH_CAP := 64                  # runaway backstop for a push loop, never reached in play


# ============================================================================
#  Entry
# ============================================================================

static func run(spec: String, payload: Dictionary) -> void:
	# spec = "<preset>:<weeks>:<mode>", e.g. "b2b_solo:13:sim" or "b2c:9:3".
	var parts: PackedStringArray = spec.split(":", false)
	if parts.size() < 2:
		print("PROBE ERROR bad spec '%s' (want <preset>:<weeks>[:<mode>])" % spec)
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
		print("PROBE ERROR unknown preset '%s' (have %s)" % [_preset, ", ".join(PRESETS.keys())])
		return

	_fires.clear()
	_picks.clear()
	_full_run = false
	_hire_started = false
	_gate_day = -1
	_gate_logged = false
	_stopped = false
	_mb_acc = {}
	_mb_ticks = 0
	_vc_policy = ""
	_vc_done = false
	_vc_booked = ""
	_vc_meet_day = -1
	_runway_weeks = {}
	# The presets measure the demo. A --build=ea in Main Run Args would otherwise turn the
	# bootstrap win into a non-terminal milestone and a real-clock run would sit on its paper.
	EndingsSystem.build_scope_override = EndingsSystem.BUILD_DEMO
	# The summary frequency is the player's setting; the probe logs the monthly cadence.
	SummarySystem.frequency_override = "monthly"
	GameState.initialize_run(payload)
	# Pin the seed so two probe runs of the same preset are comparable line for line, as
	# main.gd's _seed_run_reproducible does for the shots. initialize_run seeds from
	# Time.get_ticks_msec(), which would make every fire table a one-off.
	GameState.run_seed = _run_seed
	seed(GameState.run_seed)
	RngStreams.reseed(GameState.run_seed)   # the named streams, not just the global generator
	_wire_log()
	_seed_world(_preset)
	_min_cash_pre_seed = GameState.cash
	if _vc_policy == "naive":
		_replay_k = 20 if _replay_k < 0 else _replay_k
	else:
		_replay_k = 0
	if _vc_policy != "" and _mode != "sim":
		# The policies are defined and measured on sim only.
		print("PROBE ERROR %s is sim-only" % _preset)
		Engine.get_main_loop().quit()
		return

	print("PROBE BEGIN preset=%s weeks=%d mode=%s seed=%d" % [_preset, _stop_day, _mode, GameState.run_seed])
	if _vc_policy != "":
		print("PROBE VC_CONFIG policy=%s replay=%d" % [_vc_policy, _replay_k])
	_log_state()
	_play_the_week()                # the run opens at the first week's 08:00

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
	# event_triggered fires once for every card the engine puts up (EvEngine._announce),
	# resolved or not, so it and not the history is the fire log's source.
	EventBus.event_triggered.connect(_on_fire)
	EventBus.customer_churned.connect(_on_churn)
	EventBus.promise_created.connect(func(pid: String) -> void: _log_promise(pid, "created"))
	EventBus.promise_kept.connect(func(pid: String) -> void: _log_promise(pid, "resolved"))
	EventBus.promise_broken.connect(func(pid: String) -> void: _log_promise(pid, "resolved"))
	EventBus.build_phase_changed.connect(_on_build_phase)
	EventBus.sprint_closed.connect(_on_sprint_closed)
	EventBus.month_ended.connect(_on_month_ended)
	EventBus.phase_gate_reached.connect(_on_gate_reached)
	EventBus.day_tick_completed.connect(_on_day_tick_completed)
	EventBus.night_skipped.connect(_on_week_start)


static func _on_month_ended(_data: Dictionary) -> void:
	# The calendar-month ledger: the entry SummarySystem just pushed.
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
		int(e.get("net", 0)), int(e.get("red_weeks", 0)), growth,
		GameState.get_mrr_growth_streak(PhaseGateSystem.GROWTH_MIN_PCT), GameState.get_profitable_month_streak()])
	if _full_run:
		_log_month_burn(e, n)


static func _on_build_phase(new_phase: String) -> void:
	# A public release, with the raw axes the economy reads from now on: the sprint close pushed
	# them before it announced the release. bugs is the live wear count, tickets the confirmed ones.
	if new_phase != "shipped":
		return
	print("PROBE SHIP day=%d version=%d label=%s stability=%.1f innovation=%.1f experience=%.1f bugs=%d tickets=%d" % [
		GameState.day, ProductState.version(), SprintSystem.version_label(ProductState.version()),
		float(GameState.get_flag("mvp_stability", 0.0)), float(GameState.get_flag("mvp_innovation", 0.0)),
		float(GameState.get_flag("mvp_experience", 0.0)), ProductSystem.live_bug_count(), ProductState.bugs_confirmed()])


## Every sprint close, released or not: what shipped, how much carried and the velocity.
static func _on_sprint_closed(number: int) -> void:
	var r: Dictionary = GameState.product.release
	print("PROBE SPRINT day=%d n=%d label=%s shipped=%s carried=%d velocity=%d/%d" % [
		GameState.day, number, SprintSystem.version_label(int(r.number)) if int(r.number) > 0 else "-",
		",".join(r.shipped.map(func(c: Dictionary) -> String: return c.id)), r.carried.size(),
		int(r.velocity.done), int(r.velocity.total)])


# ============================================================================
#  Gate-day measurement: the gate-open day and the realised month (all full_run presets)
# ============================================================================
#
# Read-only lines. They draw no randomness and write no state, so every other PROBE line
# of a full_run is byte-identical with or without them.

static func _on_gate_reached(next_phase: int) -> void:
	# The Series A door is the gate whose next phase is 3. It fires in the phase-check slot of
	# the daily dispatch; the snapshot is printed with that day's PROBE STATE (_log_state), so
	# both lines describe the same moment — after the day's cards and the founder's moves.
	if next_phase == 3 and _gate_day < 0:
		_gate_day = GameState.day


static func _on_day_tick_completed(_day: int) -> void:
	if _full_run:
		_mb_add_tick()


## This tick's burn, by category. The breakdown holds daily rates written in the finance slot,
## which applies them for the tick's DAYS_PER_TICK days. The month closes in slot 0, before the
## finance slot, so a tick's burn always belongs to the month it is folded into here.
static func _mb_add_tick() -> void:
	var bd: Dictionary = FinanceSystem.get_burn_breakdown()
	for raw in FinanceSystem.BURN_IDS:
		var k: String = String(raw)
		_mb_acc[k] = int(_mb_acc.get(k, 0)) + TimeModel.DAYS_PER_TICK * int(bd.get(k, 0))
	_mb_ticks += 1


## PROBE MONTH_BURN — the closed month's expense split into the burn categories. one_time is
## what the categories do not explain: the one-off charges (hire commission, severance,
## training, the licences a sprint start pays, an event card's cash) that accrue straight into
## the month's expense.
static func _log_month_burn(e: Dictionary, n: int) -> void:
	var cat: int = 0
	for raw in FinanceSystem.BURN_IDS:
		cat += int(_mb_acc.get(String(raw), 0))
	var s0: int = int(e.get("start_day", 0))
	var e0: int = int(e.get("end_day", 0))
	var exp: int = int(e.get("expense", 0))
	print("PROBE MONTH_BURN day=%d n=%d start=%d end=%d ticks=%d ticks_expected=%d %s cat_sum=%d expense=%d one_time=%d income=%d" % [
		GameState.day, n, s0, e0, _mb_ticks, e0 - s0, _burn_fields(_mb_acc), cat, exp, exp - cat, int(e.get("income", 0))])
	_mb_acc = {}
	_mb_ticks = 0


## "<burn id>=<n>" for every burn category, 0 for one nothing has written yet.
static func _burn_fields(by_id: Dictionary) -> String:
	return " ".join(FinanceSystem.BURN_IDS.map(func(k: String) -> String: return "%s=%d" % [k, int(by_id.get(k, 0))]))


## PROBE GATE — the company on the day the Series A door opens: who is on the payroll, what
## a month costs at today's rate, what the last closed month actually cost, and the margins.
## Every burn category is printed as the finance system holds it; nothing is assumed.
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
	var runrate: int = GameState.daily_burn * TimeModel.DAYS_PER_MONTH
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
	print("PROBE GATE day=%d emp=%d on_leave=%d roles=%s payroll_monthly=%d %s bd_sum=%d daily_burn=%d expense_runrate=%d mrr=%d runrate_margin_pct=%s cust=%d accounts=%d cash=%d last_n=%d last_start=%d last_end=%d last_income=%d last_expense=%d last_net=%d last_margin_pct=%s win3_margin_pct=%d win6_margin_pct=%d profit_streak=%d growth_avg_pct=%d" % [
		GameState.day, staff.size(), on_leave, ",".join(parts), CharacterRegistry.get_total_monthly_salaries(),
		_burn_fields(bd), bd_sum, GameState.daily_burn, runrate, GameState.mrr, rr_margin,
		CustomerRegistry.get_all().size(), CustomerRegistry.account_count(), GameState.cash,
		last_n, int(last.get("start_day", -1)), int(last.get("end_day", -1)), last_income, last_expense, last_net, last_margin,
		GameState.get_window_margin_pct(3), GameState.get_window_margin_pct(6),
		GameState.get_profitable_month_streak(), GameState.get_mom_growth_avg_pct(PitchConstants.ARR_WINDOW_MONTHS)])


static func _on_fire(event_id: String) -> void:
	_fires[event_id] = int(_fires.get(event_id, 0)) + 1
	_fires_by_day[GameState.day] = int(_fires_by_day.get(GameState.day, 0)) + 1
	print("PROBE FIRE day=%d hour=%d id=%s src=%s" % [
		GameState.day, GameState.current_hour, event_id, _source_of(event_id)])


static func _source_of(event_id: String) -> String:
	return "pool" if EventGate.is_catalogued(event_id) else "factory:UNMAPPED"


static func _on_churn(customer_id: String) -> void:
	# The autopsy's terminal line. B2BSalesSystem emits the signal before
	# CustomerRegistry.remove(), so the record is still readable.
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
	_runway_weeks[GameState.phase] = _runway_weeks.get(GameState.phase, Vector2i.ZERO) + Vector2i(int(not is_inf(runway)), 1)
	if GameState.seed_closed_day < 0:
		_min_cash_pre_seed = mini(_min_cash_pre_seed, GameState.cash)
	# The B2C aggregate (audience, its satisfaction, live bugs) and the rival-relative
	# quality q that the audience formula actually reads — the four numbers the B2C growth
	# and bug-conversion verdicts are read from. q is -1 before a ship (nothing to compare).
	var ub: Customer = CustomerRegistry.get_customer(SalesSystem.B2C_USERBASE_ID)
	var q: float = -1.0
	if GameState.get_flag("mvp_shipped", false):
		q = SalesSystem._rival_relative_quality(QualityModel.shipped_normalized())
	var sig: Dictionary = PhaseGateSystem.series_a_signal()
	var appetite: String = String(sig.get("state", "closed"))
	# The Series A door is MRR only, so the gate reading is the signal state plus
	# Frank's approach step (0-4, phase.series_a_approach) — the growth streak is no
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
	# toward (B2BSalesSystem._satisfaction_target: the stability axis + trust_offset), and
	# it is printed beside satisfaction and tolerance because "why did nobody slide" and
	# "why did everybody slide" are the same question asked of these three numbers.
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
	# The fraction of the book at or above its bar — the number the
	# tolerance re-seat is judged by ("~60-70% of a 5-account book for a good v1, ~20% bad").
	if not book.is_empty():
		print("PROBE SAT day=%d satisfied=%d/%d target=%d" % [GameState.day, satisfied, book.size(),
			clampi(int(round(health)), 0, 100)])


## PROBE B2C — the consumer week: the audience and who pays it at what price, the userbase's
## satisfaction beside the experience score it drifts toward, live and confirmed bugs, the
## rival-relative q the audience formula reads, interest, server occupancy, and the support
## desk: who is on it, the reports waiting, and how many arrive and get validated a day.
static func _log_b2c() -> void:
	if not ProductState.is_live() or ProductState.market_type() != "b2c":
		return
	var ub: Customer = CustomerRegistry.get_customer(SalesSystem.B2C_USERBASE_ID)
	var price: int = int(GameState.get_flag("b2c_price", 0)) if GameState.get_flag("b2c_paid_tier_open", false) else 0
	print("PROBE B2C day=%d aud=%.1f paying=%d price=%d conv=%.3f sat=%d sat_target=%d live_bugs=%d confirmed=%d q=%.1f interest=%.1f occ=%.2f desk=%d incoming=%d inflow_day=%.2f validation_day=%.2f" % [
		GameState.day, SalesSystem.b2c_audience(), SalesSystem.b2c_paying_users(), price,
		SalesSystem.conversion_rate(price) if price > 0 else 0.0, ub.satisfaction if ub != null else -1,
		roundi(QualityModel.axis_score(QualityModel.economy_dims_from_flags(), "experience")),
		ProductSystem.live_bug_count(), ProductState.bugs_confirmed(),
		SalesSystem._rival_relative_quality(QualityModel.shipped_normalized()), ProductRead.interest(),
		InfraSystem.occupancy(), SupportSystem.desk_roster().size(), ProductState.reports_incoming(),
		SupportSystem.reports_per_day(), SupportSystem.validation_per_day()])


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
	# so this loop walks the whole queue. Then the desk's papers are opened, most urgent first,
	# and answered by the same policy: a paper left to lapse would pay an on_expire no policy
	# chose. The guard is a runaway backstop, not a cap: if it ever trips, that IS a finding
	# (an event re-queueing itself inside its own resolution) and it says so instead of
	# hanging the probe.
	var guard: int = 0
	while EventGate.active_id() != "" or not EventGate.desk_papers(1).is_empty():
		guard += 1
		if guard > 64:
			print("PROBE ERROR drain guard tripped at day %d on id=%s — an event is re-queueing inside its own resolution" % [
				GameState.day, EventGate.active_id()])
			return
		if EventGate.active_id() == "":
			# A paper the world has moved past is dropped off the desk instead of opening.
			EventGate.open_paper(String(EventGate.desk_papers(1)[0].id))
			continue
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
		# Count discounts BY MODIFIER TYPE (labels are player-facing text).
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
	# Runs the modal's OWN gate (EventGate.condition_met on unlock_condition), not a mirror of
	# it, so the probe can never pick a row a human is forbidden to click.
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
	var first_unlocked: int = -1
	for idx in ev.choices.size():
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
	# The game's clock, hour by hour: a visible hour is its own batch, so its cards are shown at
	# that hour and answered before the next, as a player answers them; an unanswered modal
	# would hold every later card behind it. The night is one batch that ends at 08:00, where
	# night_skipped opens the week (_on_week_start).
	while GameState.run_active and not _stopped:
		if TimeManager.is_clock_held():
			print("PROBE ERROR day=%d the clock is held" % GameState.day)
			break
		if TimeManager.is_night() or GameState.current_hour == TimeModel.HOURS_PER_DAY - 1:
			TimeManager.skip_night()
		else:
			TimeManager.advance_hours(1)
			_answer()
			_play_the_hour()
	_finish()


## 08:00, the week opens (night_skipped, both modes): the founder plays the week, the week's
## ledger lines print, and the run stops on its last week.
static func _on_week_start() -> void:
	_play_the_week()
	_log_state()
	_log_customers()
	_log_b2c()
	if GameState.day >= _stop_day or not GameState.run_active:
		_stopped = true
		if _mode != "sim":
			_finish()
			Engine.get_main_loop().quit()


## Answer every card on screen and the fund's call, then play the VC meeting that seated: in the
## game its panel holds the clock from the hour it opens.
static func _answer() -> void:
	_drain_modals()
	var caller: String = VCPitchSystem.call_waiting()
	if caller != "":
		VCPitchSystem.begin_meeting(caller)
	if VCPitchSystem.is_active():
		_play_the_hunt()


# ============================================================================
#  Drive mode: real clock
# ============================================================================

static func _run_realtime(speed_idx: int) -> void:
	if speed_idx <= 0 or speed_idx >= TimeModel.SECONDS_PER_HOUR.size():
		print("PROBE ERROR bad speed index %d" % speed_idx)
		Engine.get_main_loop().quit()
		return
	# Nothing pauses the clock in probe mode (main.gd's modal pause is shell wiring that
	# is not mounted), so the drain has to ride the hour boundary or a stuck active event
	# would silently block every later fire while the weeks kept rolling past it. The desk rides
	# it too, outside a batch: the night's and a meeting's hours are not the player's, and
	# night_skipped opens the week (_on_week_start).
	EventBus.hour_changed.connect(func(_h: int) -> void:
		_drain_modals()
		if not TimeManager.is_batching():
			_play_the_hour()
	)
	# A run that ends inside the night batch never reaches night_skipped: the ending closes it.
	EventBus.run_ended.connect(func(_id: String, _data: Dictionary) -> void:
		_finish()
		Engine.get_main_loop().quit(), CONNECT_ONE_SHOT)
	EventBus.speed_change_requested.emit(speed_idx)


static func _log_weekly_fires() -> void:
	# Verdict line: card fires per week, one tick each.
	for w in range(1, GameState.day + 1):
		print("PROBE WEEK w=%d fires=%d" % [w, int(_fires_by_day.get(w, 0))])


static func _finish() -> void:
	if _vc_policy != "" and not _vc_done:
		_vc_end("UNRESOLVED", "phase<3" if GameState.phase < 3 else "run_over")
	_log_weekly_fires()
	_log_tally()
	var runway: Array = [1, 2, 3].map(func(ph: int) -> String:
		var w: Vector2i = _runway_weeks.get(ph, Vector2i.ZERO)
		return "finite_runway_p%d=%d/%d" % [ph, w.x, w.y])
	print("PROBE END day=%d run_active=%s ending=%s %s min_cash_pre_seed=%d seed_day=%d" % [
		GameState.day, str(GameState.run_active), GameState.ending_id, " ".join(runway), _min_cash_pre_seed,
		GameState.seed_closed_day])
	_log_hr()


## PROBE HR — üç sayı: kaç işe alım, aylık maaş yükü, kaç kişi §7'nin 50 bandının altında.
## Sıfır işe alım bir hata değil bulgudur: probe'un işe alım yolu (`_hire_after_the_seed`)
## kapılıdır ve koşu İK'yı hiç egzersiz etmeyebilir.
static func _log_hr() -> void:
	var staff: Array[Character] = CharacterRegistry.get_employees()
	var payroll: int = CharacterRegistry.get_total_monthly_salaries()
	# `average_morale()` kimse yokken 0.0 döner ve "moral çöktü" diye okunurdu; kadro boşken
	# tire yazılır.
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
#  The founder's own moves (the played run; inert for the fire-log presets)
# ============================================================================

## The week's 08:00: the night's cards are answered, the desk looked at, the sprint planned,
## the seed round taken once its door opens, then the sales meetings sat back to back and the
## Series A hunt played. Every move goes through the seam the corresponding tab button calls —
## the probe has no privileged path into the engine.
static func _play_the_week() -> void:
	_answer()
	_play_the_hour()
	if not _full_run:
		return
	_plan_the_sprint()
	_take_the_seed()
	if GameState.get_flag("mvp_shipped", false):
		_work_the_pipeline()
	if _vc_policy != "":
		_play_the_hunt()


## Every visible hour: the desk decisions a player takes whenever a gate opens — a hire, a fix
## pass, research, the roster.
static func _play_the_hour() -> void:
	if not GameState.run_active or TimeManager.is_night():
		return
	if _full_run:
		_hire_after_the_seed()
		_run_the_company()


## The Product tab at the week's 08:00. Sprints close in the night's daily tick, so the morning
## finds either a running sprint or the release note: the note is read, the next sprint planned
## (the promised steps first, on B2C the paid plan, the lead's suggestion around them) and
## started. A decision paper waiting on a card was already answered off the desk (_drain_modals).
static func _plan_the_sprint() -> void:
	if not SprintSystem.is_typed():
		SprintSystem.choose_type(_subtype, PRODUCT_NAMES[_subtype])
		print("PROBE PLAY day=%d choose_type %s market=%s" % [GameState.day, _subtype, ProductState.market_type()])
	if SprintSystem.mode() == "release":
		SprintSystem.plan_next()
	if SprintSystem.mode() != "plan":
		return
	_plan_promises()
	var b2c: bool = ProductState.market_type() == "b2c"
	var paid: String = "plan:" + SprintCatalog.PAID_PLAN
	if b2c and not GameState.product.sprint.cards.has(paid):
		SprintSystem.add(paid)
		if GameState.product.sprint.cards.has(paid):
			print("PROBE PLAY day=%d paid plan card" % GameState.day)
	SprintSystem.apply_lead()
	if _k1_only:
		for id in GameState.product.sprint.cards.duplicate():
			if not _plannable(GameState.product.cards[id]):
				SprintSystem.remove(id)
	if b2c:
		_keep_building()
	# With no K1 step or fix left to plan, a research sprint: a plan left unstarted is auto-started
	# overnight on the lead's suggestion, K2 steps and all.
	if _k1_only and not SprintSystem.can_start():
		for area in SprintCatalog.areas_for(ProductState.subtype(), ProductState.market_type()):
			var research: Array = SprintCatalog.candidates(area.id).filter(func(c: Dictionary) -> bool: return c.kind == "research")
			if not research.is_empty():
				SprintSystem.add(research[0].id)
				break
	if SprintSystem.start():
		print("PROBE PLAY day=%d sprint %d start cards=%s used=%d capacity=%d" % [GameState.day,
			SprintSystem.sprint_number(), ",".join(GameState.product.sprint.cards), roundi(SprintSystem.used()),
			SprintSystem.capacity()])


## A sprint with research alone (or nothing) in it releases nothing, so while a step is open the
## founder plans the first one beside the research. With no open step the research sprint runs:
## there is nothing to build.
static func _keep_building() -> void:
	var p: Dictionary = GameState.product
	if p.sprint.cards.any(func(id: String) -> bool: return p.cards[id].kind != "research"):
		return
	for area in SprintCatalog.areas_for(ProductState.subtype(), ProductState.market_type()):
		for c in SprintCatalog.candidates(area.id):
			if c.kind != "research" and c.state == "candidate" and _plannable(c) and SprintCatalog.gate_reason(c.step) == "":
				SprintSystem.add(c.id)
				if p.sprint.cards.has(c.id):
					print("PROBE PLAY day=%d step beside research: %s" % [GameState.day, c.id])
				return


## The K1-only founder plans no step past K1: fixes, research and the paid plan stay open.
static func _plannable(c: Dictionary) -> bool:
	return not _k1_only or int(c.target_tier) <= 1


## Keeping the word: an open promise whose step is the line's next one goes into the sprint, as
## its feature card or, when the account asked for it, as the request card.
static func _plan_promises() -> void:
	for p in PromiseRegistry.get_all():
		if p.status != "open" or ProductState.is_feature_live(p.feature_id):
			continue
		for area in SprintCatalog.areas_for(ProductState.subtype(), ProductState.market_type()):
			for c in SprintCatalog.candidates(area.id):
				if c.step != p.feature_id or c.state != "candidate":
					continue
				SprintSystem.add(c.id)
				if GameState.product.sprint.cards.has(c.id):
					print("PROBE PLAY day=%d promise card=%s (promise %s deadline=%d)" % [
						GameState.day, c.id, p.id, p.deadline_day])


static func _work_the_pipeline() -> void:
	# The founder's sales week (Satış §3, §5.0): leads arrive on their own and the throttle is
	# the entry gate (the hour budget and the week's cap), asked through the same seam the tab
	# asks, so the probe gets no faster a pipeline than a player at the same keyboard. Each
	# sitting's close runs its hours, so the loop meets until the gate shuts, back at the desk
	# between sittings.
	if SalesMeetingSystem.is_active() or NegotiationSystem.is_active():
		return
	for i in SalesConstants.MEETINGS_PER_WEEK + 1:
		# The first lead the founder is allowed to sit with, not only the head of the queue: a
		# blocked returning company at leads[0] would idle the meeting.
		var table: Prospect = null
		for raw in ProspectRegistry.get_all():
			var lead: Prospect = raw as Prospect
			if lead != null and SalesLedger.meeting_block_reason(lead.id) == "":
				table = lead
				break
		if table == null or not GameState.run_active:
			return
		_meet(table)
		_answer()
		_play_the_hour()


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


## The B2B run's staffing ladder: a founder who is growing
## hires the desk the growth needs — a developer on Frank's money, a support rep once a
## few accounts are live, sales reps as MRR climbs. Each rung only when the payroll it
## adds leaves six months of runway.
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
## The consumer run's ladder: no sales desk to staff, so the rungs follow MRR alone, and beside
## them the support reps the desk needs.
const B2C_LADDER := [
	{"role": "developer", "min_mrr": 0},
	{"role": "designer", "min_mrr": 8000},
	{"role": "tester", "min_mrr": 15000},
	{"role": "developer", "min_mrr": 25000},
	{"role": "product_manager", "min_mrr": 40000},
]


## The role the ladder hires next, or "" while it waits. B2B climbs STAFF_LADDER by headcount up
## to the preset's cap. B2C first hires a support rep whenever someone pays, reports are waiting
## and the desk validates fewer a day than arrive: the release-to-release swing in the inflow
## alone does not hire while the desk keeps the queue empty, and a rep away on leave or in
## training is waited for, not replaced. Then the first B2C_LADDER rung whose role the staff is
## short of.
static func _next_role() -> String:
	var staff: Array[Character] = CharacterRegistry.get_employees()
	if SalesSystem.is_b2b_market():
		if staff.size() >= _staff_cap:
			return ""
		var want: Dictionary = STAFF_LADDER[staff.size()]
		if CustomerRegistry.account_count() < int(want.min_customers) or GameState.mrr < int(want.min_mrr):
			return ""
		return String(want.role)
	var reps: Array = staff.filter(func(c: Character) -> bool: return c.role == HRConstants.ROLE_CUSTOMER_REP)
	if SalesSystem.b2c_paying_users() > 0 and ProductState.reports_incoming() > 0 \
			and reps.all(func(c: Character) -> bool: return c.status == HRConstants.STATUS_ACTIVE) \
			and SupportSystem.validation_per_day() < SupportSystem.reports_per_day():
		return HRConstants.ROLE_CUSTOMER_REP
	# The first rung whose role is short of what the ladder wants up to it: a departure is refilled
	# with the role that left, not with whatever rung the smaller headcount points at.
	var spare: Dictionary = {}
	for c in staff:
		spare[c.role] = int(spare.get(c.role, 0)) + 1
	for want in B2C_LADDER:
		spare[want.role] = int(spare.get(want.role, 0)) - 1
		if int(spare[want.role]) < 0:
			return String(want.role) if GameState.mrr >= int(want.min_mrr) else ""
	return ""


static func _hire_after_the_seed() -> void:
	# Frank's money buys the first employee. Driven through
	# HRSearchSystem exactly as the HR tab does it: start a search, wait for the files to
	# arrive, hire the cheapest one.
	if int(GameState.get_flag(AngelRoundSystem.FLAG_ACCEPTED_DAY, 0)) <= 0:
		return   # no cheque from Frank yet — hiring on the opening cash is a different run
	if HRSearchSystem.has_files_ready():
		var hired: Character = HRSearchSystem.hire(0)
		if hired != null:
			_hire_started = false
			print("PROBE PLAY day=%d hire %s salary=%d burn=%d" % [
				GameState.day, hired.role, hired.monthly_salary, GameState.daily_burn])
		return
	if _hire_started or not HRSearchSystem.can_start():
		return
	var role: String = _next_role()
	if role == "":
		return
	var monthly_out: int = GameState.daily_burn * 30 + 6000 - GameState.mrr
	if monthly_out > 0 and GameState.cash < monthly_out * 6:
		return
	if HRSearchSystem.start_search(role, HRConstants.LEVEL_JUNIOR):
		_hire_started = true
		print("PROBE PLAY day=%d start_search %s/junior" % [GameState.day, role])


## The played run's operations — the things any player does once the product is live: run a
## fix pass when confirmed bugs pile up, research, look after the roster. Servers and the price
## follow the releases on their own.
static func _run_the_company() -> void:
	if not ProductState.is_live():
		return
	# Once anyone pays for the consumer product the founder swaps his build job for the support
	# desk (§8.2). Sprint points do not read his job (SprintSystem.team), so the sprint loses
	# nothing; the desk gains his engineering for fix passes, and his customer_success for
	# validation (0 in the debug payload, so the first rep is still needed).
	var founder: Character = CharacterRegistry.get_founder()
	if ProductState.market_type() == "b2c" and SalesSystem.b2c_paying_users() > 0 \
			and not founder.assigned_job_ids.has(HRConstants.JOB_SUPPORT):
		CharacterRegistry.clear_jobs(founder.id)
		if CharacterRegistry.assign_job(founder.id, HRConstants.JOB_SUPPORT) == "":
			print("PROBE PLAY day=%d founder takes the support desk" % GameState.day)
	# A player closes a fix pass every few days and ships what was fixed; waiting for zero confirmed
	# bugs never ends, because reports keep coming. Four calendar days on, one off, counted on the
	# clock: the night cannot be acted in, so while the
	# backlog stays high a week settles at twenty hours on (12:00 to 08:00) and four off.
	var now: float = TimeModel.days(GameState.day + GameState.current_hour / float(TimeModel.HOURS_PER_DAY))
	if ProductState.fix_run_active():
		if ProductState.bugs_confirmed() <= 1 or now - _fix_on_at >= 4.0:
			print("PROBE PLAY day=%d fix_run end shipped=%d" % [GameState.day, SupportSystem.end_fix_run()])
			_fix_off_at = now
			if _fixer_id != "":
				CharacterRegistry.unassign_job(_fixer_id, HRConstants.JOB_SUPPORT)
				_fixer_id = ""
	elif ProductState.bugs_confirmed() >= 6 and SupportSystem.can_start_fix_run() and now - _fix_off_at >= 1.0:
		# §8.4: fixes are ENGINEERING on the support desk. The CS reps who staff it have no
		# engineering, so a player lends a developer to the desk for the pass.
		for dev in CharacterRegistry.get_employees():
			if dev.role == HRConstants.ROLE_DEVELOPER and not dev.assigned_job_ids.has(HRConstants.JOB_RESEARCH) \
					and CharacterRegistry.assign_job(dev.id, HRConstants.JOB_SUPPORT) == "":
				_fixer_id = dev.id
				break
		SupportSystem.start_fix_run()
		_fix_on_at = now
		print("PROBE PLAY day=%d fix_run start bugs=%d fixer=%s fix_per_day=%.2f" % [GameState.day,
			ProductState.bugs_confirmed(), _fixer_id, SupportSystem.fix_per_day()])
	_run_research()
	_keep_the_team()


## A player watching the roster does something before a person walks: a raise first, the
## year's holiday if a raise is not on the table. Nothing fancier: without it the run
## measures a founder who never looks at morale.
static func _keep_the_team() -> void:
	for emp in CharacterRegistry.get_employees():
		if emp.category != "employee" or emp.status != HRConstants.STATUS_ACTIVE:
			continue
		if emp.morale >= 40:
			continue
		if HRActions.can_raise(emp, 10) and HRActions.apply_raise(emp, 10):
			print("PROBE PLAY day=%d raise %s morale=%d" % [GameState.day, emp.role, emp.morale])
		elif emp.leave_taken_year != int(GameState.get_date_dict().year):
			HRMoraleSystem.send_on_leave(emp, HRConstants.LEAVE_WEEKS, true)
			print("PROBE PLAY day=%d holiday %s morale=%d" % [GameState.day, emp.role, emp.morale])


## Research the next gated step needs (or any open node): a player who wants K2/K3 does
## Ar-Ge. Never the founder, whose seat is the build and the sales desk.
static func _run_research() -> void:
	if not RnDSystem.tree_open() or RnDSystem.active() != "":
		return
	var wanted: Array = []
	for tier in range(1, ProductLines.TIER_MAX + 1):
		for raw_line in ProductLines.line_ids(ProductState.subtype()):
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
	# Research takes the whole person (Ar-Ge §5.0). Keep one developer on the sprint and
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


# ============================================================================
#  The seed round (every played run)
# ============================================================================
#
# The seed door opens in Traction at its MRR bar and closes on entering phase 3; the run gets
# one pitch, and the seed room cannot say no (ch. 09 §3). Every played run takes it the week the
# door opens: the first fund in the registry's order that takes the pitch, the meeting played by
# the Series A rule (_meeting_pick), then the offer signed at the table by the preset's Series A
# table policy. naive pushes random levers until the final counter; cautious, and the runs with
# no Series A policy, sign the opening terms; walk signs them too, because the seed table has no
# walk (TermSheetTableSystem.walk refuses it at seed).

static func _take_the_seed() -> void:
	if GameState.seed_sheet == null and SeedRoundSystem.door_open() \
			and WorkHoursSystem.sitting_open(PitchConstants.MEETING_HOURS):
		for raw in InvestorRegistry.get_active():
			var fund: String = String((raw as Dictionary).get("id", ""))
			if SeedRoundSystem.begin_pitch(fund):
				var path: String = _sit_the_meeting()
				print("PROBE PLAY day=%d seed meeting fund=%s path=%s" % [GameState.day, fund, path])
				break
	var sheet: TermSheet = GameState.seed_sheet
	if sheet == null or not WorkHoursSystem.sitting_open(PitchConstants.TERM_TABLE_HOURS):
		return
	TermSheetTableSystem.open(sheet.vc_id, PitchConstants.STAGE_SEED)
	var pushes: int = 0
	if _vc_policy == "naive":
		pushes = int(_push_until_done("probe_seed_lever", sheet.vc_id, sheet.vc_id, false).pushes)
	TermSheetTableSystem.sign()           # → SeedRoundSystem.accept: the money in, the run goes on
	TermSheetTableSystem.end_sitting()
	print("PROBE PLAY day=%d seed signed fund=%s band=%s pushes=%d raise=%d equity=%d cash=%d" % [
		GameState.day, sheet.vc_id, sheet.band, pushes, GameState.run_seed_amount,
		GameState.run_seed_equity_pct, GameState.cash])


# ============================================================================
#  The Series A hunt (the presets with a Series A policy)
# ============================================================================
#
# What share of term-sheet tables end in a signature, a final offer or the fund walking
# out when a naive founder plays them? The bot never met a VC, so
# these policies are the working definitions the owner wrote:
#   naive    — once the door is open, book the first fund that will meet; at the table push
#              a random lever until patience runs out; sign a final offer.
#   cautious — the same meeting; sign the opening terms without a single push (the baseline).
#   walk     — the same meeting; walk the first table through its own walk (VCPitchSystem.
#              walk_table): the Series A decision faced and refused, the bootstrap road.
# The meeting is played identically by all, so the runs are the same run up to the
# table. The lever draw comes from a probe-local generator seeded per table with an EvDice
# hash of seed/day/ids — never a stream the game draws from — and nothing acts before
# phase 3: until the door opens a VC preset is the same run without the policy, except naive,
# whose seed table is pushed (see "The seed round").

static func _play_the_hunt() -> void:
	if _vc_done or not GameState.run_active or GameState.phase < 3 or TermSheetTableSystem.is_active():
		return
	# 1. The founder answered the fund's call, which seated the meeting. Play it.
	if VCPitchSystem.is_active():
		_play_the_meeting()
		_vc_meet_day = GameState.day
	# 2. A live Series A sheet: sit down the week it arrives (so the decision card never comes).
	if not GameState.active_sheets.is_empty():
		var ts: TermSheet = GameState.active_sheets[0] as TermSheet
		_play_the_table(String(ts.vc_id))
		return
	# 3. Waiting on a booked meeting or a queued sheet.
	if not GameState.pending_meeting.is_empty() or EndingsSystem._any_pending_sheet():
		var pm_day: int = int(GameState.pending_meeting.get("day", -1))
		if not GameState.pending_meeting.is_empty() and pm_day >= 0 and pm_day < GameState.day - 1:
			print("PROBE ERROR day=%d booked meeting (day %d) never started" % [GameState.day, pm_day])
		return
	if _vc_meet_day == GameState.day:
		return                          # a refusal this week: the next fund is booked next week
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
	var path: String = _sit_the_meeting()
	var st: Dictionary = GameState.vc_states.get(fund, {}) as Dictionary
	print("PROBE VC_MEET day=%d fund=%s n=%d conv0=%d path=%s result=%s sheet_conv=%d rejections=%d brand=%d" % [
		GameState.day, fund, int(st.get("meeting_count", 0)), conv0, path,
		String(st.get("status", "?")), int(st.get("sheet_conviction", -1)), GameState.vc_rejections, GameState.brand])


## The seated meeting, Series A or seed, played to its end by _meeting_pick and its hours run.
## Returns the path: "<pick>:<conviction before>><after>" per beat.
static func _sit_the_meeting() -> String:
	var trace: Array[String] = []
	var ids: Array[String] = ["b1_read"]   # Beat 1 has one row, and its resolver ignores the id
	var guard: int = 0
	while VCPitchSystem.is_active() and guard < 8:
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
	if VCPitchSystem.is_active():
		print("PROBE ERROR day=%d meeting did not finish" % GameState.day)
	VCPitchSystem.end_sitting()     # the sitting's hours run once the panel is gone
	return ",".join(trace)


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
	var sheet: TermSheet = VCPitchSystem.sheet_for(vc)
	if sheet == null:
		_vc_end("NO_TABLE", "no_sheet")
		return
	if _vc_policy == "naive" and _replay_k > 0:
		_run_replays()                  # the table is still closed: same company, same day
	var ov: Dictionary = TermSheetTableSystem.open(vc, PitchConstants.STAGE_SERIES_A)
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
	elif _vc_policy == "walk":
		outcome = "FOUNDER_WALKED"
	elif int(ev.get("state", 0)) == TermSheetTableSystem.PATIENCE_ZERO:
		outcome = "SIGNED_FINAL"
	var t1: Dictionary = TermSheetTableSystem._terms.duplicate()
	# A walked table raised nothing: its working terms are printed, its money is not.
	var money: String = "-" if walked or _vc_policy == "walk" else str(TermSheetTableSystem.money_raised())
	print("PROBE VC_TABLE_END day=%d fund=%s policy=%s outcome=%s e0=%d e_end=%d thr=%d pushes=%d wins=%d levers=%s patience_left=%d val_m=%d dil=%d board=%d veto=%s money=%s rejections=%d" % [
		GameState.day, vc, _vc_policy, outcome, e0, TermSheetTableSystem.eagerness(), thr, int(r.pushes), int(r.wins),
		String(r.get("levers", "")), int((ev.get("patience", {}) as Dictionary).get("current", 0)), int(t1.get("valuation_m", 0)),
		int(t1.get("dilution_pct", 0)), int(t1.get("board_seats", 0)), str(bool(t1.get("board_veto", false))),
		money, GameState.vc_rejections])
	_vc_done = true
	if walked:
		TermSheetTableSystem.leave()    # the closure is already written by the fund's walk-out
	elif _vc_policy == "walk":
		TermSheetTableSystem.walk()     # → VCPitchSystem.walk_table: the decision faced, the run goes on
	else:
		TermSheetTableSystem.sign()     # → EndingsSystem.trigger_ending("series_a_close")
	TermSheetTableSystem.end_sitting()  # a run-ending signature owes no hours


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
	if TermSheetTableSystem.is_active() or VCPitchSystem.is_active() or not GameState.run_active:
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
			TermSheetTableSystem.open(fund, PitchConstants.STAGE_SERIES_A)
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
	if preset.begins_with("full_run"):
		# THE PLAYED RUN. Nothing is seeded: no product, no customers, no money beyond the
		# origin's opening cash. Everything the log shows was earned by the founder's moves
		# through the same seams the tabs call.
		_full_run = true
		var spec: Dictionary = PRESETS[preset]
		_subtype = String(spec.subtype)
		_policy = String(spec.get("policy", "sensible"))
		_vc_policy = String(spec.get("vc", ""))
		_staff_cap = int(spec.get("staff_cap", STAFF_LADDER.size()))
		_k1_only = bool(spec.get("k1_only", false))
		return
	GameState.set_cash(60000)   # deep enough that the Kepenk shutter never confounds a 90-day log
	match preset:
		"b2c":
			_seed_b2c_world()
		"b2c_neglect":
			_seed_b2c_neglect()
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
			# which is itself one of the probe's own findings.
			_seed_b2b_world(0)
			# DERIVED, not authored. Unsalvageable = the zero-bug axis
			# sits 8 under the SMALL bar; the backlog (14) only makes it worse.
			_seed_stability_fixture("b2b_risk", _raw_for_axis(_bar_small() - 8.0), 14)
		"b2b_slip":
			# RECOVERABLE pressure, and the distinction from b2b_risk is the whole point.
			# b2b_risk is UNSALVAGEABLE by construction: the satisfaction target sits below
			# every tolerance in the book even at zero bugs. This preset sits the target near
			# the mid/enterprise bar while the bug backlog is live and clearly over it once the
			# backlog is cleared — so a founder who answers the demand AND cleans up keeps the
			# account, and one who ignores it does not.
			_seed_b2b_world(0)
			# DERIVED. With the backlog live the axis sits 2 over the
			# MID bar (inside [T_mid, T_mid+5): small accounts safe, sector-picky mids and the
			# enterprise under); cleared, it must clear T_mid+7 — checked at seed time.
			_seed_stability_fixture("b2b_slip", _raw_for_axis(_bar_mid() + 2.0) + QualityModel.BUG_STABILITY_COEF * 9.0, 9)


## A product already live on day 1. mvp_launch_day is stamped here because the fixture skips
## the sprint close, its only writer, and every weeks_since_flag trigger reading it would
## otherwise stay false forever.
static func _seed_live_product(market: String, subtype: String, components: Array, product_name: String) -> void:
	GameState.set_flag("mvp_shipped", true)
	GameState.set_flag("mvp_launch_day", GameState.day)
	GameState.set_flag("mvp_market_type", market)
	GameState.set_flag("mvp_sub_product_type_id", subtype)
	GameState.set_flag("mvp_components", components)
	GameState.set_flag("mvp_version", 1)
	GameState.set_flag("mvp_product_name", product_name)


## The tended consumer product, built by the sprint engine itself: the note app and the founder
## alone, Sprint 1 started on the lead's plan and every later sprint auto-started on it. The MVP
## release brings the launch audience and opens the paid tier.
static func _seed_b2c_world() -> void:
	SprintSystem.choose_type("note_tool", PRODUCT_NAMES["note_tool"])
	SprintSystem.apply_lead()
	SprintSystem.start()
	EventBus.version_shipped.connect(func(_n: int) -> void:
		SalesSystem.add_b2c_audience(200)
		SalesSystem.open_b2c_paid_tier(15), CONNECT_ONE_SHOT)


## The UNTENDED consumer product: experience low enough that satisfaction drifts down toward its
## score, a live backlog over SATISFACTION_BUG_GATE pushing it lower, and nobody sprints. The
## "declining" arm of the B2C growth measurement.
static func _seed_b2c_neglect() -> void:
	_seed_live_product("b2c", "ai_assistant", ["ai_assistant_chat", "ai_assistant_memory"], "Nova")
	GameState.set_flag("mvp_innovation", 10.0)
	GameState.set_flag("mvp_stability", 8.0)
	GameState.set_flag("mvp_experience", 8.0)
	GameState.set_flag("mvp_live_bug_count", 12)
	SalesSystem.add_b2c_audience(200)
	SalesSystem.open_b2c_paid_tier(15)


# --- Fixture arithmetic ---
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
	return float(B2BConstants.seed_tolerance(2, ""))   # a small account: scale 2, no sector


static func _bar_mid() -> float:
	return float(B2BConstants.seed_tolerance(3, ""))   # a mid/enterprise account: scale 3, no sector


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
	_seed_live_product("b2b", "saas_ops", ["saas_ops_workflow", "saas_ops_reporting"], "Sahra")
	# A MID product on purpose: with its 4 live bugs the stability AXIS sits above a small
	# account's tolerance bar and below a scaled one's, so the book holds a mix of steady
	# and sliding accounts. The satisfaction TARGET is this axis, so it is the most
	# load-bearing fixture value in the log — which is why it is DERIVED from the live bars
	# rather than authored as a raw number.
	GameState.set_flag("mvp_innovation", 20.0)
	GameState.set_flag("mvp_experience", 22.5)
	_seed_stability_fixture("b2b_solo",
		_raw_for_axis((_bar_small() + 3.0 + _bar_mid()) * 0.5) + QualityModel.BUG_STABILITY_COEF * 4.0, 4)

	# Five accounts through the real signing seam (SalesSystem.add_b2b_customer — the
	# sole B2B signing path), spread across archetypes so tolerance seeds differ and the
	# CS request cadence phases apart (cs_request_phase strides by 9 per signing).
	# Total MRR is deliberately ~2.7K: a young book that is PAST the traction gate
	# (mvp_shipped + 1 customer + mrr > 0) and well SHORT of Series A (MRR at the
	# SalesSystem.TRACTION_MRR_TARGET bar — MRR only). Seeded higher, the run rockets to
	# phase 3 in two days and the log stops describing the early game it is supposed to
	# describe.
	#
	# Satisfaction seeds straddle the tolerance seeds on purpose: probe_c and probe_e start
	# close enough to their bar that ordinary product wear can push them under, which is the
	# only way the retention → promise → churn chain is reachable without hand-forcing it.
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
		# Satış §2 — the STAR is the size; `add_b2b_customer` copies it into `Customer.scale`,
		# which seeds the hidden tolerance.
		p.star = int(s["star"])
		# §5.3 — the deal is SEATS x SEAT PRICE: seat counts inside each star's band at the
		# Standard price anchor (MRR 350 / 800 / 700 / 300 / 550).
		SalesSystem.add_b2b_customer(p, int(s["seats"]), int(s["price"]), int(s["sat"]))

	for i in rep_count:
		var c := Character.new()
		c.id = "probe_cs_%d" % i
		c.character_name = "Temsilci %d" % (i + 1)
		c.role = HRConstants.ROLE_CUSTOMER_REP
		c.category = "employee"
		c.monthly_salary = 6000
		c.morale = 60
		# A junior rep, MÜŞTERİ İLİŞKİLERİ 2: the desk absorbs every request up to
		# CustomerRepSystem.absorb_ceiling(), so a strong rep would swallow the whole request
		# channel and the escalation path would never be observed. The trait touches only
		# overtime morale, so it does not move the rep's output or growth.
		c.role_stats = HRConstants.seed_skills(c.role, 2, 2)
		c.traits = ["last_one_out"]
		CharacterRegistry.add(c)
