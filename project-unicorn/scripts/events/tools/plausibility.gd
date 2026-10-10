extends RefCounted

# THE PLAUSIBILITY LEDGER (event engine v3, R13). It plays RunProbe's played runs and judges
# every card that reaches the screen against the rules the v3 schema is meant to make true, so
# "did this card fire somewhere a person could believe" stops being a thing a human reads a
# thousand log lines for.
#
#   godot --headless --path . -s res://scripts/events/tools/plausibility_main.gd \
#         -- --event-plausibility-probe=seeds=1-20:weeks=16
#
# No class_name: the SceneTree entry loads the file by path, so a run needs no --import.
#
# SPEC  seeds=<N|A-B>:weeks=<N>:variant=<plain|early|both>:preset=<RunProbe preset>
#       Defaults seeds=1-20, weeks=16, variant=both, preset by seed parity (odd plays B2B,
#       even the consumer run). ONE RUN PER PROCESS is the contract — tools/plausibility_run.sh
#       gives each run its own process and its own user directory; a seed range in one process
#       is the convenience form.
#
# THE EARLY-HIRE VARIANT exists because the plain played run staffs late: the tenure rules
# (a card that wants a colleague of some standing) are unreachable in sixteen weeks unless
# someone hires in week 2. It searches for a developer, a rep and a tester, three weeks apart,
# and takes the first file on the table.
#
# OUTPUT
#   PLAUS FIRE id= src= week= phase= hc= slots=<slot:tenure,...> req=<option:open|locked,...>
#   PLAUS FAIL <rule> <detail>                 one line per broken rule, per fire
#   PLAUS RATE phase= pool_weeks= nothing= empty=
#        pool_weeks  weeks a pool-drawn card fired
#        nothing     weeks no card fired at all
#        empty       ticks the floor was reached and found nothing (motor GDD 13.6)
#   PLAUS SUMMARY runs= fires= fails=          fails>0, or no run at all, returns false
#
# THE RULES, R13's numbering: 1 start_immunity, 2 plausibility, 3 known_absurd, 4 first_weeks,
# 5 family_gap, 6 critical_scope. Rule 7 (the error patterns in the log) belongs to the runner,
# which owns the log file. Rule 8 (a signal refused by a brake without a PLAUS DEFER line) has
# nothing to print: nothing defers until the brakes exist.

const DEFAULT_SEEDS := 20
const DEFAULT_WEEKS := 16
const VARIANTS := ["plain", "early"]
const EARLY_ROLES := ["developer", "customer_rep", "tester"]
## The origin a card's own tick field declares.
const SRC_BY_TICK := {"signal": "signal", "request": "request", "scheduled": "schedule"}

# The thresholds the rules judge against (R13, PRD section 8), each written under the name its
# owner will carry, so a rename lands as an edit here and not as a rule that quietly cannot fail.
const START_IMMUNITY_WEEKS := 3
const FAMILY_GAP_WEEKS_DEFAULT := 6
const FAMILY_GAP_WEEKS := {"employee_asks_money": 12, "world_offer_b2c": 8, "world_offer_b2b": 8,
	"founder_solitude": 3, "founder_network": 4, "customer_risk": 2, "product_floor": 4}
const ONBOARDING_VOICE_TENURE_WEEKS := 4
const RENEWAL_MIN_TENURE_WEEKS := 44
const CONFERENCE_TENURE_WEEKS := 28
const AUDIENCE_CREATOR := 3000
const AUDIENCE_PLACEMENT := 2000

# THE FOUNDER THIS LEDGER PLAYS, and its only home: tools/run_gate.sh measures the same full_run
# presets with main.gd's _debug_payload, so R13 has to judge that world and not a skill-less one.
# initialize_run reads the skill ruler, the traits and the opening cash off these keys; without
# them every skill is 0 and the growth the cards wait on never comes. The portrait, company name,
# logo and slogan a headless ledger never prints are left out.
const FOUNDER := {
	"origin_id": "self_made",
	"skill_alloc": {"product": 1, "design": 0, "engineering": 2, "qa": 0, "sales": 2,
		"customer_success": 0, "leadership": 0, "charisma": 1},
	"trait_ids": ["visionary", "stubborn"],
}

static var _runs: int = 0
static var _fires: int = 0
static var _fails: int = 0
## phase -> {pool, nothing, empty}, every run of this process folded in.
static var _rate: Dictionary = {}
## This run only: week -> {phase, fires, pool, empty}.
static var _weeks: Dictionary = {}
## family -> the week its last card fired.
static var _family_week: Dictionary = {}
static var _empty_base: int = 0
static var _variant: String = ""
static var _early_k: int = 0


# --- Entry -----------------------------------------------------------------

static func run(spec: String) -> bool:
	var opt: Dictionary = _parse(spec)
	if not bool(opt["ok"]):
		return false
	var variants: Array = VARIANTS if String(opt["variant"]) == "both" else [String(opt["variant"])]
	for run_seed in range(int(opt["from"]), int(opt["to"]) + 1):
		for variant in variants:
			_play(_preset_for(run_seed, String(opt["preset"])), run_seed, int(opt["weeks"]),
				String(variant))
	var phases: Array = _rate.keys()
	phases.sort()
	for phase in phases:
		var t: Dictionary = _rate[phase]
		print("PLAUS RATE phase=%d pool_weeks=%d nothing=%d empty=%d"
			% [phase, t["pool"], t["nothing"], t["empty"]])
	print("PLAUS SUMMARY runs=%d fires=%d fails=%d" % [_runs, _fires, _fails])
	return _fails == 0 and _runs > 0


static func _parse(spec: String) -> Dictionary:
	var out: Dictionary = {"from": 1, "to": DEFAULT_SEEDS, "weeks": DEFAULT_WEEKS,
		"variant": "both", "preset": "", "ok": true}
	for part in spec.split(":", false):
		var kv: PackedStringArray = String(part).split("=", true, 1)
		var value: String = String(kv[1]) if kv.size() == 2 else ""
		match String(kv[0]):
			"seeds":
				var ends: PackedStringArray = value.split("-")
				out["from"] = int(ends[0]) if ends.size() > 1 else 1
				out["to"] = int(ends[ends.size() - 1])
			"weeks":
				out["weeks"] = int(value)
			"variant":
				out["variant"] = value
			"preset":
				out["preset"] = value
			_:
				print("PLAUS ERROR bad spec part '%s' (want seeds|weeks|variant|preset=<value>)" % part)
				out["ok"] = false
	if String(out["variant"]) != "both" and not VARIANTS.has(String(out["variant"])):
		print("PLAUS ERROR bad variant '%s' (want both|%s)" % [out["variant"], "|".join(VARIANTS)])
		out["ok"] = false
	if String(out["preset"]) != "" and not RunProbe.PRESETS.has(String(out["preset"])):
		print("PLAUS ERROR bad preset '%s' (have %s)"
			% [out["preset"], ", ".join(RunProbe.PRESETS.keys())])
		out["ok"] = false
	return out


## R13's mix: odd seeds play the B2B run, even seeds the consumer one.
static func _preset_for(run_seed: int, override: String) -> String:
	if override != "":
		return override
	return "full_run" if run_seed % 2 == 1 else "full_run_b2c"


static func _play(preset: String, run_seed: int, weeks: int, variant: String) -> void:
	# Static system state outlives a run (initialize_run lays the world, not the owners), so a
	# second run in one process would start on the first one's latches and history.
	SaveManager.reset_all_owners()
	_variant = variant
	_early_k = 0
	_weeks.clear()
	_family_week.clear()
	_empty_base = EvEngine.empty_floor_ticks()
	# The ledger listens for exactly as long as the probe plays: the process outlives the probe by
	# a frame, the clock steps one more week inside it (RunProbe's own log carries that week too),
	# and a fire past the spec's last week is a fire the printed summary can no longer count.
	EventBus.event_triggered.connect(_on_fire)
	EventBus.day_tick_completed.connect(_on_day_end)
	EventBus.night_skipped.connect(_on_week_start)
	RunProbe.run("%s:%d:sim:%d" % [preset, weeks, run_seed], FOUNDER)
	EventBus.event_triggered.disconnect(_on_fire)
	EventBus.day_tick_completed.disconnect(_on_day_end)
	EventBus.night_skipped.disconnect(_on_week_start)
	_runs += 1
	for week in _weeks:
		var row: Dictionary = _weeks[week]
		var t: Dictionary = _rate.get_or_add(int(row["phase"]), {"pool": 0, "nothing": 0, "empty": 0})
		t["pool"] += 1 if int(row["pool"]) > 0 else 0
		t["nothing"] += 1 if int(row["fires"]) == 0 else 0
		t["empty"] += int(row["empty"])


# --- The run's own moves ---------------------------------------------------

static func _on_week_start() -> void:
	if _variant != "early":
		return
	if HRSearchSystem.has_files_ready():
		HRSearchSystem.hire(0)
	elif _early_k < EARLY_ROLES.size() and GameState.day >= 2 + 3 * _early_k \
			and HRSearchSystem.can_start() \
			and HRSearchSystem.start_search(String(EARLY_ROLES[_early_k]), 0):
		_early_k += 1


# --- The ledger ------------------------------------------------------------

static func _on_fire(event_id: String) -> void:
	var card: Dictionary = EvCatalog.card(event_id)
	var context: Dictionary = EventGate.active_context()
	var src: String = _source_of(card)
	var week: int = GameState.day
	var row: Dictionary = _row(week)
	_fires += 1
	row["fires"] += 1
	if src == "pool":
		row["pool"] += 1
	print("PLAUS FIRE id=%s src=%s week=%d phase=%d hc=%d slots=%s req=%s" % [
		event_id, src, week, GameState.phase, int(EvSeams.read("hr.headcount")),
		_slots(context), _options(card, context)])
	_judge(card, context, src, week)


static func _on_day_end(day: int) -> void:
	var seen: int = EvEngine.empty_floor_ticks()
	var row: Dictionary = _row(day)
	row["phase"] = GameState.phase
	row["empty"] += seen - _empty_base
	_empty_base = seen


static func _row(week: int) -> Dictionary:
	return _weeks.get_or_add(week, {"phase": GameState.phase, "fires": 0, "pool": 0, "empty": 0})


## Which origin put the card up. The engine records none, so it is read off the card: the tick
## field is the origin's own declaration, and a card a system asks for by id declares
## tick: "request", so SRC_BY_TICK names it. An arc step comes from its arc, a quiet card only
## ever comes from the floor, and a critical card comes from the per-tick sweep
## (EvEngine._step_tick_proposals) rather than the pool draw, which excludes it
## (EvCatalog.pool_candidates) — so it reports the sweep's own origin name. A played run forces
## nothing, so R13's FORCE exemption has no origin to match.
static func _source_of(card: Dictionary) -> String:
	var tags: Array = card["tags"]
	if card.has("arc"):
		return "arc_step"
	if tags.has("quiet"):
		return "floor"
	if SRC_BY_TICK.has(card["tick"]):
		return String(SRC_BY_TICK[card["tick"]])
	return ("tick_%s" % card["tick"]) if tags.has("critical") else "pool"


## slot:tenure pairs — who the card landed on. A slot whose type has no standing reads -1.
static func _slots(context: Dictionary) -> String:
	var out: PackedStringArray = []
	for slot in context:
		out.append("%s:%d" % [slot, _tenure(context, String(slot))])
	return ",".join(out) if not out.is_empty() else "-"


static func _options(card: Dictionary, context: Dictionary) -> String:
	var out: PackedStringArray = []
	for opt in (card["options"] as Array):
		var option: Dictionary = opt
		out.append("%s:%s" % [String(option["id"]),
			"open" if EvCondition.eval(option.get("requires", {}), context) else "locked"])
	return ",".join(out)


static func _tenure(context: Dictionary, slot: String) -> int:
	var bound: Dictionary = context[slot]
	var seam: String = String(EvCatalog.TENURE_SEAMS.get(String(bound["type"]), ""))
	return -1 if seam == "" else int(EvSeams.read_for(seam, String(bound["id"])))


# --- The rules -------------------------------------------------------------

static func _judge(card: Dictionary, context: Dictionary, src: String, week: int) -> void:
	var id: String = String(card["id"])
	var tags: Array = card["tags"]
	var is_system: bool = bool(card.get("system", false))

	if week <= START_IMMUNITY_WEEKS and not is_system and not ["request", "floor"].has(src):
		_fail("start_immunity", "%s week=%d src=%s" % [id, week, src])

	for node in _plausibility_of(card):
		if not EvCondition.eval(node, context):
			_fail("plausibility", "%s node=%s" % [id, JSON.stringify(node)])

	var absurd: String = _known_absurd(card, context)
	if absurd != "":
		_fail("known_absurd", "%s %s" % [id, absurd])

	if id == "team.first_weeks":
		_fail("first_weeks", "%s fired in week %d" % [id, week])

	_judge_family(card, src, week)

	if tags.has("critical") and not is_system and not tags.has("terminal_warning"):
		_fail("critical_scope", "%s carries critical without system" % id)


## What the v3 compiler wrote, in the condition and in each slot's selector, as the NODES to
## judge rather than the leaves under them: a two-band `plausibility.phase_band` compiles to one
## `any`, and asking each band to hold on its own would fail the card for every band it is not in.
static func _plausibility_of(card: Dictionary) -> Array:
	var out: Array = []
	_plausibility_nodes(card.get("condition", {}), out)
	for spec in (card["scope"] as Dictionary).values():
		_plausibility_nodes((spec as Dictionary).get("where", {}), out)
	return out


## Descent stops at the first node the compiler stamped, and goes no deeper than an `all`: inside
## `any`, `none` or `not` a single child's verdict is not the node's.
static func _plausibility_nodes(node: Dictionary, out: Array) -> void:
	if String(node.get("_from", "")) == "plausibility":
		out.append(node)
	elif node.has(EvCondition.ALL):
		for child in (node[EvCondition.ALL] as Array):
			_plausibility_nodes(child as Dictionary, out)
	elif not EvCondition.leaves_named(node, "_from", "plausibility").is_empty():
		out.append(node)


## R5's brake: two cards of one family may not land closer than the family's gap. A chain step
## and a system request are exempt.
static func _judge_family(card: Dictionary, src: String, week: int) -> void:
	var family: String = String(card.get("family", ""))
	if family == "":
		return
	var gap: int = int(FAMILY_GAP_WEEKS.get(family, FAMILY_GAP_WEEKS_DEFAULT))
	var last: int = int(_family_week.get(family, -gap))
	if week - last < gap and String(card.get("follows", "")) == "" \
			and src != "request":
		_fail("family_gap", "%s family=%s week=%d last=%d gap=%d"
			% [String(card["id"]), family, week, last, gap])
	_family_week[family] = week


## R13 rule 3: the nine fires the research confirmed absurd, each returning why it is absurd;
## the caller prints the card id.
static func _known_absurd(card: Dictionary, context: Dictionary) -> String:
	var id: String = String(card["id"])
	match id:
		"customer.cs_escalation":
			var customer: int = _tenure(context, "customer")
			var rep: int = _tenure(context, "rep")
			if mini(customer, rep) < ONBOARDING_VOICE_TENURE_WEEKS:
				return "customer=%dw rep=%dw want>=%dw" \
					% [customer, rep, ONBOARDING_VOICE_TENURE_WEEKS]
		"customer.retention":
			var weeks: int = _tenure(context, "customer")
			if weeks < ONBOARDING_VOICE_TENURE_WEEKS \
					and _is_generic_voice(String((context["customer"] as Dictionary)["id"])):
				return "customer=%dw speaks the generic risk voice, not an onboarding one" % weeks
		"team.conference_trip":
			var weeks: int = _tenure(context, "employee")
			if weeks < CONFERENCE_TENURE_WEEKS:
				return "employee=%dw want>=%dw" % [weeks, CONFERENCE_TENURE_WEEKS]
		"rival.shutdown_notice", "funding.portfolio_vendor":
			var option: String = _open_marketing(card, context)
			if option != "":
				return "marketing option '%s' is open" % option
		"world.b2c_creator_feature":
			var audience: int = int(EvSeams.read("sales.b2c_audience"))
			if audience < AUDIENCE_CREATOR:
				return "audience=%d want>=%d" % [audience, AUDIENCE_CREATOR]
		"world.app_placement":
			var audience: int = int(EvSeams.read("sales.b2c_audience"))
			if audience < AUDIENCE_PLACEMENT:
				return "audience=%d want>=%d" % [audience, AUDIENCE_PLACEMENT]
		"rival.price_cut":
			var weeks: int = _tenure(context, "customer")
			if weeks < ONBOARDING_VOICE_TENURE_WEEKS:
				return "customer=%dw want>=%dw" % [weeks, ONBOARDING_VOICE_TENURE_WEEKS]
		"customer.request_renewal":
			var weeks: int = _tenure(context, "customer")
			if weeks < RENEWAL_MIN_TENURE_WEEKS:
				return "customer=%dw want>=%dw" % [weeks, RENEWAL_MIN_TENURE_WEEKS]
	return ""


## The line B2BSalesSystem gives an account with nothing louder to say. A fresh account speaking
## it is the defect: it has no history to be disappointed by yet.
static func _is_generic_voice(customer_id: String) -> bool:
	var voice: String = String(EvSeams.read_for("musteri.risk_voice", customer_id))
	for key in B2BSalesSystem.RISK_VOICE_SHORT_KEYS:
		if TranslationServer.translate(String(key)) == voice:
			return true
	return false


## The option that answers with a marketing spend, when nothing locks it.
static func _open_marketing(card: Dictionary, context: Dictionary) -> String:
	for opt in (card["options"] as Array):
		var option: Dictionary = opt
		for effect in (option.get("effects", []) as Array):
			if String((effect as Dictionary).get("verb", "")) == "marketing_push" \
					and EvCondition.eval(option.get("requires", {}), context):
				return String(option["id"])
	return ""


static func _fail(rule: String, detail: String) -> void:
	_fails += 1
	print("PLAUS FAIL %s %s" % [rule, detail])
