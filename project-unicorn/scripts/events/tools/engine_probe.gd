class_name EvProbe
extends RefCounted

# Engine self-check. Runs headless, prints one line per assertion, and reports a verdict line
# the shell can grep:
#
#     godot --headless --path . --event-probe
#
# WHY THIS EXISTS SEPARATELY FROM THE SMOKE SUITE. endgame_smoke.gd is 12,500 lines and shared
# with several other sessions' work; adding to it mid-build is a merge hazard and a slow
# feedback loop (one Godot boot per case). This runs every core assertion in a single boot, so
# it is the loop used WHILE building. The permanent gates still go into the smoke suite — this
# does not replace them, it front-runs them.
#
# It grows into the "why didn't this fire" panel (§19.2): the gate already returns a Verdict
# carrying the step, the reason and the condition report, so the panel is a presentation of
# what this file already prints.

static var _pass: int = 0
static var _fail: int = 0


## Returns true when everything passed.
static func run() -> bool:
	_pass = 0
	_fail = 0
	print("=== EVENT ENGINE PROBE ===")
	_seed_world()
	_check_seams()
	_check_conditions()
	_check_flags()
	_check_history()
	_check_latches()
	_check_scope()
	_check_schedule()
	_check_queue()
	_check_effects()
	_check_save_block()
	_check_catalog()
	_check_thesis()
	_check_invalidation()
	print("PROBE %s  %d passed, %d failed" % ["PASS" if _fail == 0 else "FAIL", _pass, _fail])
	return _fail == 0


static func _ok(label: String, condition: bool, detail: String = "") -> void:
	if condition:
		_pass += 1
		print("  PASS  %s" % label)
	else:
		_fail += 1
		print("  FAIL  %s%s" % [label, ("  — " + detail) if detail != "" else ""])


static func _seed_world() -> void:
	GameState.initialize_run({"seed": 424242})
	EvFlags.reset()
	EvHistory.reset()
	EvLatches.reset()
	EvSchedule.reset()
	EvQueue.reset()
	EvArcs.reset()
	EvPapers.reset()


# --- Seams -----------------------------------------------------------------

static func _check_seams() -> void:
	print("- seams")
	EvSeams.ensure_installed()
	var names: Array = EvSeams.all_names()
	_ok("registry populated (%d seams)" % names.size(), names.size() > 60)
	_ok("hr.headcount is known", EvSeams.has("hr.headcount"))
	_ok("unknown name is not known", not EvSeams.has("hr.nonsense"))
	_ok("hr.headcount reads an int", typeof(EvSeams.read("hr.headcount")) == TYPE_INT)
	_ok("time.day matches GameState", int(EvSeams.read("time.day")) == GameState.day)

	# Type coercion: the JSON-float defect. A literal authored as 3 arrives as 3.0 and must
	# come back an int, or `in` against an int seam silently never matches.
	var coerced: Variant = EvSeams.coerce("hr.headcount", 3.0)
	_ok("int seam coerces a JSON float literal", typeof(coerced) == TYPE_INT and int(coerced) == 3,
		"got %s" % type_string(typeof(coerced)))
	var arr: Variant = EvSeams.coerce("hr.headcount", [1.0, 2.0, 3.0])
	_ok("coercion walks arrays",
		typeof(arr) == TYPE_ARRAY and typeof((arr as Array)[0]) == TYPE_INT)

	# Mockability (§6.1 clause 5).
	EvSeams.mock("hr.headcount", 99)
	_ok("a mocked seam overrides the binding", int(EvSeams.read("hr.headcount")) == 99)
	EvSeams.clear_mocks()
	_ok("clearing mocks restores the binding", int(EvSeams.read("hr.headcount")) != 99)


# --- Conditions ------------------------------------------------------------

static func _check_conditions() -> void:
	print("- conditions")
	EvSeams.mock("hr.headcount", 3)
	EvSeams.mock("finance.cash", 5000)

	_ok("empty condition is true", EvCondition.eval({}))
	_ok("seam >= holds", EvCondition.eval({"seam": "hr.headcount", "op": ">=", "value": 3}))
	_ok("seam >= fails", not EvCondition.eval({"seam": "hr.headcount", "op": ">=", "value": 4}))
	_ok("op in", EvCondition.eval({"seam": "hr.headcount", "op": "in", "value": [1, 3, 5]}))

	# The combinators the old vocabulary could not express at all.
	_ok("all", EvCondition.eval({"all": [
		{"seam": "hr.headcount", "op": ">=", "value": 3},
		{"seam": "finance.cash", "op": ">", "value": 100}]}))
	_ok("any takes the second branch", EvCondition.eval({"any": [
		{"seam": "hr.headcount", "op": ">=", "value": 99},
		{"seam": "finance.cash", "op": ">", "value": 100}]}))
	_ok("not", EvCondition.eval({"not": {"seam": "hr.headcount", "op": ">=", "value": 99}}))
	_ok("none", EvCondition.eval({"none": [{"seam": "hr.headcount", "op": ">=", "value": 99}]}))
	_ok("none fails when a child passes",
		not EvCondition.eval({"none": [{"seam": "hr.headcount", "op": ">=", "value": 1}]}))

	# §5.3's empty-collection rules, which are easy to get backwards.
	_ok("empty all is true", EvCondition.eval({"all": []}))
	_ok("empty any is FALSE", not EvCondition.eval({"any": []}))
	_ok("empty none is true", EvCondition.eval({"none": []}))

	# explain() must agree with eval() and must blame the right child.
	var tree: Dictionary = {"all": [
		{"seam": "hr.headcount", "op": ">=", "value": 3},
		{"seam": "finance.cash", "op": ">", "value": 999999, "reason": "not enough cash"}]}
	_ok("eval and explain agree",
		EvCondition.eval(tree) == bool(EvCondition.explain(tree)["passed"]))
	var report: Dictionary = EvCondition.explain(tree)
	_ok("explain blames exactly the failing child", (report["blame"] as Array).size() == 1)
	_ok("the authored reason survives to the top",
		EvCondition.reason_of(report) == "not enough cash",
		"got '%s'" % EvCondition.reason_of(report))

	# A failing `none` blames the child that PASSED — the case a single failed_leaf cannot say.
	var none_tree: Dictionary = {"none": [{"seam": "hr.headcount", "op": ">=", "value": 1}]}
	var none_report: Dictionary = EvCondition.explain(none_tree)
	_ok("a failing none blames the passing child",
		(none_report["blame"] as Array).size() == 1
		and bool(((none_report["blame"] as Array)[0] as Dictionary)["passed"]))

	# Leaf enumeration — what PhaseGateSystem's Series A readout needs to survive nesting.
	_ok("leaves are enumerable through nesting", EvCondition.leaves(tree).size() == 2)
	_ok("leaves are findable by seam name",
		EvCondition.leaves_named(tree, "seam", "finance.cash").size() == 1)
	_ok("seams_read reports both", EvCondition.seams_read(tree).size() == 2)

	EvSeams.clear_mocks()


# --- Flags -----------------------------------------------------------------

static func _check_flags() -> void:
	print("- flags")
	EvFlags.reset()
	_ok("an unset flag is false", not EvFlags.has("nope"))
	EvFlags.set_flag("frank_seed_taken", "probe")
	_ok("a set flag is true", EvFlags.has("frank_seed_taken"))
	_ok("provenance is recorded",
		String(EvFlags.provenance("frank_seed_taken").get("set_by", "")) == "probe")
	_ok("flag_unset is the complement",
		EvCondition.eval({"flag_unset": "nope"})
		and not EvCondition.eval({"flag_unset": "frank_seed_taken"}))

	# The absent-stamp rule: "N days after X" must be FALSE when X never happened, not day 0.
	_ok("days_since_flag on an unstamped name is false",
		not EvCondition.eval({"days_since_flag": "never", "op": ">=", "value": 0}))
	EvFlags.stamp("shipped", "probe")
	_ok("days_since_flag is 0 on the stamping day",
		EvCondition.eval({"days_since_flag": "shipped", "op": ">=", "value": 0}))
	_ok("and not yet 1", not EvCondition.eval({"days_since_flag": "shipped", "op": ">=", "value": 1}))

	EvFlags.set_timed("window", 3, "probe")
	_ok("a timed flag reads as set", EvFlags.has("window"))
	_ok("days_until_expiry counts", EvFlags.days_until_expiry("window") == 3)
	_ok("flag_expires_within sees it",
		EvCondition.eval({"flag_expires_within": "window", "days": 5}))


# --- History ---------------------------------------------------------------

static func _check_history() -> void:
	print("- history")
	EvHistory.reset()
	_ok("nothing has fired", EvHistory.fire_count("ev.x") == 0)
	_ok("days_since is -1, not a big number", EvHistory.days_since("ev.x") == -1)

	EvHistory.record("hr.raise_request", EvHistory.RESOLUTION_CHOSEN, "accept", "gave_raise",
		{"employee": {"type": "employee", "id": "emp_1"}}, [])
	_ok("fire_count counts", EvHistory.fire_count("hr.raise_request") == 1)
	_ok("chose finds the option", EvHistory.chose("hr.raise_request", "accept"))
	_ok("chose rejects another option", not EvHistory.chose("hr.raise_request", "refuse"))
	_ok("last_outcome is recorded", EvHistory.last_outcome("hr.raise_request") == "gave_raise")
	_ok("chose_about finds the subject",
		EvHistory.chose_about("hr.raise_request", "employee", "emp_1"))
	_ok("chose_about rejects another subject",
		not EvHistory.chose_about("hr.raise_request", "employee", "emp_2"))

	# THE THESIS PRIMITIVE: a condition reading a choice made earlier.
	_ok("a CONDITION can read a past choice",
		EvCondition.eval({"history": "chose", "event": "hr.raise_request", "option": "accept"}),
		"this is the query the old engine had no way to ask")
	_ok("and can read that another was not taken",
		not EvCondition.eval({"history": "chose", "event": "hr.raise_request", "option": "refuse"}))

	# An expiry is a fact too, and a later card may need it.
	EvHistory.record("sales.offer", EvHistory.RESOLUTION_EXPIRED, "", "lapsed", {}, [])
	_ok("resolution is queryable",
		EvCondition.eval({"history": "resolution", "event": "sales.offer", "value": "expired"}))
	_ok("an expiry counts as a fire but not as a choice",
		EvHistory.fire_count("sales.offer") == 1 and EvHistory.chosen_count("sales.offer") == 0)

	# I3's runtime half.
	EvFlags.set_flag("shutter_warned", "probe")
	_ok("a telegraph is found via a flag", EvHistory.telegraph_fired("shutter_warned"))
	_ok("a telegraph is found via a resolved card", EvHistory.telegraph_fired("sales.offer"))
	_ok("an unfired telegraph is not found", not EvHistory.telegraph_fired("never_happened"))


# --- Latches ---------------------------------------------------------------

static func _check_latches() -> void:
	print("- latches")
	EvLatches.reset()
	var one_shot: Dictionary = {EvLatches.ONE_SHOT: true}
	var key: String = EvLatches.key_for("ev.once", EvLatches.KEY_RUN, "")
	_ok("a fresh one_shot passes", EvLatches.blocked_reason(one_shot, key) == "")
	EvLatches.spend(key)
	_ok("a spent one_shot blocks", EvLatches.blocked_reason(one_shot, key) != "")

	var cooldown: Dictionary = {EvLatches.COOLDOWN: 30}
	var ck: String = EvLatches.key_for("ev.cool", EvLatches.KEY_RUN, "")
	_ok("a fresh cooldown passes", EvLatches.blocked_reason(cooldown, ck) == "")
	EvLatches.spend(ck)
	_ok("a spent cooldown blocks today", EvLatches.blocked_reason(cooldown, ck) != "")
	_ok("and reports how long is left", EvLatches.cooldown_left(cooldown, ck) == 30)

	# The per-entity key: two people may each raise the same card on the same day (§20 A6).
	var k1: String = EvLatches.key_for("hr.raise", EvLatches.KEY_ENTITY, "emp_1")
	var k2: String = EvLatches.key_for("hr.raise", EvLatches.KEY_ENTITY, "emp_2")
	_ok("entity keys differ per subject", k1 != k2)
	EvLatches.spend(k1)
	_ok("one subject's latch does not block another",
		EvLatches.blocked_reason(one_shot, k1) != "" and EvLatches.blocked_reason(one_shot, k2) == "")

	var capped: Dictionary = {EvLatches.MAX_FIRES: 2}
	var mk: String = EvLatches.key_for("ev.twice", EvLatches.KEY_RUN, "")
	EvLatches.spend(mk)
	_ok("max_fires allows the second", EvLatches.blocked_reason(capped, mk) == "")
	EvLatches.spend(mk)
	_ok("max_fires blocks the third", EvLatches.blocked_reason(capped, mk) != "")


# --- Scope -----------------------------------------------------------------

static func _check_scope() -> void:
	print("- scope")
	var employees: Array = CharacterRegistry.get_employees()
	var founder: Character = CharacterRegistry.get_founder()
	_ok("the founder exists and is not an employee",
		founder != null and founder.category == "founder")
	_ok("get_employees never returns the founder",
		not employees.any(func(c): return (c as Character).category == "founder"))

	var res: Dictionary = EvScope.resolve({"employee": {"type": "employee", "required": true}})
	if employees.is_empty():
		_ok("a required slot with no candidate REFUSES", not bool(res["ok"]))
		_ok("and names the slot it could not fill", String(res["unresolved"]) == "employee")
	else:
		_ok("a required slot binds", bool(res["ok"]))

	var opt: Dictionary = EvScope.resolve({"employee": {"type": "employee", "required": false}})
	_ok("an optional slot never blocks", bool(opt["ok"]))

	var f: Dictionary = EvScope.resolve({"founder": {"type": "founder", "required": true}})
	_ok("the founder slot binds", bool(f["ok"]))
	_ok("the bound context holds scalars only, never an object",
		typeof((f["context"] as Dictionary)["founder"]) == TYPE_DICTIONARY
		and typeof(((f["context"] as Dictionary)["founder"] as Dictionary)["id"]) == TYPE_STRING)
	_ok("entity_exists sees a bound slot",
		EvCondition.eval({"entity_exists": "founder"}, f["context"]))
	_ok("entity_exists is false for an unbound slot",
		not EvCondition.eval({"entity_exists": "nobody"}, f["context"]))
	_ok("entity_count reads the roster",
		EvCondition.eval({"entity_count": "founder", "op": ">=", "value": 1}))


# --- Schedule --------------------------------------------------------------

static func _check_schedule() -> void:
	print("- schedule")
	EvSchedule.reset()
	EvSchedule.add("ev.payoff", 80, {"employee": {"type": "employee", "id": "emp_1"}}, "arc_x")
	_ok("an entry is pending", EvSchedule.size() == 1)
	_ok("nothing is due yet", EvSchedule.take_due().is_empty())

	# The whole point of §16.2, asserted rather than assumed.
	var payload: Dictionary = EvSchedule.to_dict()
	var as_json: String = JSON.stringify(payload)
	_ok("the schedule serialises to pure JSON", as_json != "" and as_json != "null")
	_ok("and contains no Resource tag", not as_json.contains("__res"),
		"a serialised Resource in the schedule is a resurrected entity waiting to happen")

	EvSchedule.reset()
	EvSchedule.add("ev.overdue", 0, {}, "arc_y")
	_ok("a due entry is taken", EvSchedule.take_due().size() == 1)

	# Freeze / thaw: relative days on the arc, absolute in the schedule.
	EvSchedule.reset()
	EvSchedule.add("ev.step", 10, {}, "arc_z")
	var frozen: Array = EvSchedule.freeze_arc("arc_z")
	_ok("freezing removes it from the schedule", EvSchedule.size() == 0 and frozen.size() == 1)
	_ok("and keeps the delay as RELATIVE days",
		int((frozen[0] as Dictionary)["remaining_days"]) == 10)
	EvSchedule.thaw_arc("arc_z", frozen)
	_ok("thawing restores one entry", EvSchedule.size() == 1)
	_ok("still due in 10 days, not overdue", EvSchedule.take_due().is_empty())

	EvSchedule.reset()
	EvSchedule.add("ev.a", 5, {}, "arc_a")
	EvSchedule.add("ev.b", 5, {}, "arc_b")
	_ok("drop_arc removes only its own", EvSchedule.drop_arc("arc_a") == 1 and EvSchedule.size() == 1)


# --- Queue -----------------------------------------------------------------

static func _check_queue() -> void:
	print("- queue")
	EvQueue.reset()
	_ok("admits once", EvQueue.admit("ev.one", {}, "interrupt"))
	_ok("refuses the same id twice", not EvQueue.admit("ev.one", {}, "interrupt"))
	_ok("and COUNTS the absorbed attempt", EvQueue.absorbed_count("ev.one") == 1,
		"a silently swallowed duplicate is how a runaway hides")
	_ok("size is one", EvQueue.size() == 1)
	EvQueue.admit("ev.two", {}, "paper", "arc_q")
	_ok("drop_arc removes only its own", EvQueue.drop_arc("arc_q") == 1 and EvQueue.size() == 1)
	EvQueue.flush()
	_ok("flush empties the queue", EvQueue.size() == 0)


# --- Effects: the invariants that are now structural ------------------------

static func _check_effects() -> void:
	print("- effects (I2 / I3 / I6)")

	# I2. The point is not that ambient callers are *told off* for spending money — it is that
	# the verb is not a key in their table, so they cannot reach it at all.
	var cash_before: int = GameState.cash
	EvEffects.run_ambient([{"verb": "add_cash", "amount": 5000}], {})
	_ok("I2: an ambient origin CANNOT move cash", GameState.cash == cash_before,
		"cash moved by %d" % (GameState.cash - cash_before))

	EvEffects.run_played([{"verb": "add_cash", "amount": 500}], {})
	_ok("I2: a played decision can", GameState.cash == cash_before + 500)

	# §8.3's one exception is a SIGN rule, and a sign rule can only be checked at dispatch.
	var before_expire: int = GameState.cash
	EvEffects.run_expire([{"verb": "add_cash", "amount": 300}], {})
	_ok("I2: on_expire CANNOT apply a positive delta", GameState.cash == before_expire)
	EvEffects.run_expire([{"verb": "add_cash", "amount": -200}], {})
	_ok("I2: on_expire CAN apply a negative one", GameState.cash == before_expire - 200)

	# Neutral verbs are available everywhere — the split restricts economy, not bookkeeping.
	EvFlags.reset()
	EvEffects.run_ambient([{"verb": "set_flag", "name": "ambient_wrote_this"}], {})
	_ok("neutral verbs work from every origin", EvFlags.has("ambient_wrote_this"))

	# I3. An untelegraphed loss does not happen.
	GameState.set_run_active(true)
	GameState.ending_id = ""
	EvEffects.run_played([{"verb": "trigger_ending", "ending_id": "bankruptcy",
		"requires_telegraph": "never_fired"}], {})
	_ok("I3: an ending whose telegraph never fired is REFUSED", GameState.run_active,
		"the run ended anyway")

	EvEffects.run_played([{"verb": "trigger_ending", "ending_id": "bankruptcy"}], {})
	_ok("I3: an ending declaring no telegraph at all is refused", GameState.run_active)

	# I6. A dice branch may not be terminal, and it is the TABLE that says so.
	EvFlags.set_flag("shutter_warned", "probe")
	EvEffects.run_check_branch([{"verb": "trigger_ending", "ending_id": "bankruptcy",
		"requires_telegraph": "shutter_warned"}], {})
	_ok("I6: a dice branch cannot end the run even WITH a telegraph", GameState.run_active,
		"zar oldurdu")

	# And the same effect, from a played decision, does end it — proving the refusals above
	# were about the ORIGIN and not about something being broken.
	EvEffects.run_played([{"verb": "trigger_ending", "ending_id": "bankruptcy",
		"requires_telegraph": "shutter_warned"}], {})
	_ok("a telegraphed ending from a played decision DOES end the run", not GameState.run_active)
	GameState.set_run_active(true)

	# add_mrr has no write seam and says so rather than faking it. The old engine shipped a
	# chip for it with no dispatcher arm — a card promising the player a number nothing applied.
	var mrr_before: int = GameState.mrr
	var log: Array = EvEffects.run_played([{"verb": "add_mrr", "amount": 900}], {})
	_ok("add_mrr is refused with a reason, not silently applied",
		GameState.mrr == mrr_before
		and String((log[0] as Dictionary).get("refused", "")) != "")

	# Unknown verbs are refused and logged; the run continues.
	var log2: Array = EvEffects.run_played([{"verb": "make_money_appear"}], {})
	_ok("an unknown verb is refused and logged",
		String((log2[0] as Dictionary).get("refused", "")) == "unknown verb")


# --- The save block ---------------------------------------------------------

static func _check_save_block() -> void:
	print("- save block")
	EvFlags.set_flag("probe_flag", "probe")
	EvHistory.record("ev.probe", EvHistory.RESOLUTION_CHOSEN, "opt", "out",
		{"employee": {"type": "employee", "id": "emp_probe"}}, [])
	EvSchedule.add("ev.probe", 30, {"employee": {"type": "employee", "id": "emp_probe"}}, "arc_p")

	var block: Dictionary = EvSave.to_dict()
	_ok("the block declares its version", int(block.get("version", 0)) == EvSave.BLOCK_VERSION)

	# THE assertion. A Resource in here is a dead entity waiting to be handed back on load.
	var offender: String = EvSave.verify_no_resources(block)
	_ok("no Resource anywhere in the engine block", offender == "", "found at %s" % offender)

	var json: String = JSON.stringify(block)
	_ok("the whole block is JSON-serialisable", json != "" and json != "null")
	_ok("and carries no __res tag", not json.contains(SaveCodec.TYPE_TAG))

	# Round trip.
	EvSave.from_dict(block)
	_ok("flags survive a round trip", EvFlags.has("probe_flag"))
	_ok("history survives", EvHistory.chose("ev.probe", "opt"))
	_ok("the bound entity survives as an ID, not an object",
		typeof(((EvHistory.rows()[0] as Dictionary)["entities"] as Dictionary)["employee"]) == TYPE_DICTIONARY)

	# A6: no narrative flag changed storage location. The two flags content writes today are
	# read by ProductSystem from GameState, and they stay there — a flag that moved house would
	# be looked for in the wrong place by every save written before the move, and the condition
	# would silently read false.
	GameState.set_flag("tech_debt_birikti", true)
	_ok("tech_debt_birikti still lives in GameState, not the engine store",
		bool(GameState.get_flag("tech_debt_birikti", false)) and not EvFlags.has("tech_debt_birikti"))
	GameState.set_flag("tech_debt_birikti", false)

	# The schema moved with the block.
	_ok("schema is v10", SaveManager.SCHEMA_VERSION == 10)
	_ok("and v9 saves are refused, not half-loaded", SaveManager.MIN_LOADABLE_VERSION == 10)


# --- Catalogue --------------------------------------------------------------

static func _check_catalog() -> void:
	print("- catalogue")
	EvCatalog.reload()
	_ok("no load errors", EvCatalog.load_errors().is_empty(),
		str(EvCatalog.load_errors()))
	_ok("fixture cards loaded", EvCatalog.has_card("fixture.thesis_open"))
	_ok("fixture arcs loaded", EvCatalog.has_arc("arc_fixture_thesis"))

	# G2 refuses them in a normal build — the same mechanism that keeps Early Access content
	# out of a demo pool, rather than a second "is this a test" flag to forget.
	var blocked: EvGate.Verdict = EvGate.propose("fixture.thesis_open", EvGate.Origin.TICK_DAILY)
	_ok("a fixture card is REFUSED at G2 in a normal build",
		not blocked.admitted and blocked.step == "G2", "step was %s" % blocked.step)

	# An arc step is never a pool candidate (§10.10) — a step drawn from the pool would burn
	# its own one_shot out of order and lock the arc there for the rest of the run.
	var pool_ids: Array = []
	for c in EvCatalog.pool_candidates("scheduled"):
		pool_ids.append(String((c as Dictionary)["id"]))
	_ok("§10.10: an arc step is never in the pool", not pool_ids.has("fixture.thesis_payoff"))

	# unwired/ must stay unreachable. Its cards have empty conditions, and an empty condition
	# is TRUE — so a recursive loader that saw that directory would fire ev_seed_closed on
	# day 1. Today it is inert only because the OLD loader is non-recursive; here it is a rule.
	_ok("unwired/ is excluded from the catalogue", not EvCatalog.has_card("ev_seed_closed"))


static func _due_day_of(event_id: String) -> int:
	for e in EvSchedule.pending():
		if String((e as Dictionary)["event_id"]) == event_id:
			return int((e as Dictionary)["fire_on_day"])
	return -1


# --- THE THESIS TEST --------------------------------------------------------
#
# GDD §0.2, and §24 makes it the gate stage 2 may not be skipped past: a card played on day 10
# produces a visible consequence on day 90, across a save/load, a speed change and an unrelated
# concurrent arc, with its subject and context intact.

static func _check_thesis() -> void:
	print("- THE THESIS TEST (day 10 -> day 90)")
	var shipped: Array = EvTuning.SHIPPED_SCOPES.duplicate()
	EvTuning.SHIPPED_SCOPES.append("fixture")

	GameState.initialize_run({"seed": 424242})
	EvEngine.reset()
	EvCatalog.reload()

	# --- day 10: the decision --------------------------------------------
	GameState.day = 10
	var opened: EvGate.Verdict = EvGate.propose("fixture.thesis_open", EvGate.Origin.TICK_DAILY)
	_ok("day 10: the opening card is admitted", opened.admitted,
		"%s: %s" % [opened.step, opened.reason])
	EvQueue.admit("fixture.thesis_open", opened.context, "interrupt")
	EvEngine.pump()
	_ok("day 10: it is on screen", EvQueue.active_id() == "fixture.thesis_open")
	EvEngine.resolve("fixture.thesis_open", "promise")
	_ok("day 10: the arc started", EvArcs.is_active("arc_fixture_thesis"))
	_ok("day 10: the payoff is scheduled", EvSchedule.has("fixture.thesis_payoff"))

	# --- an unrelated arc runs alongside ---------------------------------
	EvSchedule.add("fixture.concurrent", 40, {}, "")
	_ok("an unrelated card shares the schedule", EvSchedule.size() == 2)

	# --- the save/load cycle ---------------------------------------------
	var block: Dictionary = EvSave.to_dict()
	var json: String = JSON.stringify(block)
	_ok("the engine block survives JSON", json != "" and json != "null")
	_ok("and holds no Resource", EvSave.verify_no_resources(block) == "")
	EvEngine.reset()
	_ok("after a reset the arc is gone", not EvArcs.is_active("arc_fixture_thesis"))
	EvSave.from_dict(JSON.parse_string(json) as Dictionary)
	_ok("after the load the arc is back", EvArcs.is_active("arc_fixture_thesis"))
	_ok("and the schedule came with it", EvSchedule.has("fixture.thesis_payoff"))
	_ok("and history remembers the choice",
		EvCondition.eval({"history": "chose", "event": "fixture.thesis_open", "option": "promise"}))

	# --- a speed change ---------------------------------------------------
	# Every day field is absolute (§16.3), so a speed change cannot distort the arithmetic —
	# there is no arithmetic to distort. Asserted rather than assumed.
	TimeManager.current_speed = 3
	_ok("a speed change moves no due date", _due_day_of("fixture.thesis_payoff") == 90,
		"due on day %d" % _due_day_of("fixture.thesis_payoff"))
	TimeManager.current_speed = 1

	# --- days 11..89: nothing lands early, and the unrelated card runs alongside ----
	var early: int = 0
	var concurrent_landed_on: int = -1
	for d in range(11, 90):
		GameState.day = d
		for due in EvSchedule.take_due():
			var due_id: String = String((due as Dictionary)["event_id"])
			if due_id == "fixture.thesis_payoff":
				early += 1
			elif due_id == "fixture.concurrent":
				concurrent_landed_on = d
				var v: EvGate.Verdict = EvGate.propose(due_id, EvGate.Origin.SCHEDULE)
				if v.admitted:
					EvQueue.admit(due_id, v.context, "paper")
					EvPapers.place(due_id, v.context, 200)
	_ok("nothing fires early", early == 0)
	_ok("the unrelated card landed on its own day, mid-arc", concurrent_landed_on == 50,
		"landed on day %d" % concurrent_landed_on)
	_ok("and it is sitting on the desk while the arc runs", EvPapers.has("fixture.concurrent"))

	# --- day 90: the payoff -----------------------------------------------
	GameState.day = 90
	var due_now: Array = EvSchedule.take_due()
	var found: bool = false
	for due in due_now:
		if String((due as Dictionary)["event_id"]) == "fixture.thesis_payoff":
			found = true
	_ok("day 90: the payoff comes due", found)

	var payoff: EvGate.Verdict = EvGate.propose("fixture.thesis_payoff", EvGate.Origin.SCHEDULE)
	_ok("day 90: it passes the gate", payoff.admitted, "%s: %s" % [payoff.step, payoff.reason])
	_ok("its condition read a choice made 80 days earlier",
		EvCondition.eval((EvCatalog.card("fixture.thesis_payoff") as Dictionary)["condition"]),
		"this is the query the old engine had no way to ask")

	EvQueue.admit("fixture.thesis_payoff", payoff.context, "interrupt", "arc_fixture_thesis")
	EvEngine.pump()
	_ok("day 90: the payoff is on screen", EvQueue.active_id() == "fixture.thesis_payoff")
	EvEngine.resolve("fixture.thesis_payoff", "acknowledge")
	_ok("day 90: THE PAYOFF LANDED", EvFlags.has("fixture_payoff_landed"))
	_ok("and the arc closed with its outcome",
		EvArcs.state_of("arc_fixture_thesis") == EvArcs.STATE_ENDED
		and EvArcs.outcome_of("arc_fixture_thesis") == "kept")
	_ok("the unrelated card is STILL on the desk, untouched by the arc closing",
		EvPapers.has("fixture.concurrent"),
		"an arc ending must not sweep work that was never its own")

	EvTuning.SHIPPED_SCOPES.clear()
	EvTuning.SHIPPED_SCOPES.append_array(shipped)


# --- THE SECOND VARIANT: the subject leaves ---------------------------------
#
# §7.1's other half. An arc whose subject is removed mid-run must apply one of §10.5's three
# policies, and — the clause that matters most — `reassign` must PAUSE rather than kill, and a
# promise arc must never die quietly.

static func _check_invalidation() -> void:
	print("- arc invalidation (the three policies)")
	var shipped: Array = EvTuning.SHIPPED_SCOPES.duplicate()
	EvTuning.SHIPPED_SCOPES.append("fixture")
	GameState.initialize_run({"seed": 424242})
	EvEngine.reset()
	EvCatalog.reload()

	# A subject to lose.
	var emp := Character.new()
	emp.id = "emp_probe_subject"
	emp.character_name = "Probe"
	emp.category = "employee"
	emp.role = HRConstants.ROLE_DEVELOPER
	emp.monthly_salary = 3000
	emp.morale = 60
	emp.traits = ["picks_it_up_fast"]
	emp.role_stats = HRConstants.default_employee_skills()
	CharacterRegistry.add(emp)
	_ok("the subject exists", CharacterRegistry.get_character("emp_probe_subject") != null)

	# --- reassign: pause, do not kill -------------------------------------
	GameState.day = 40
	EvArcs.start("arc_fixture_subject", {"type": "employee", "id": "emp_probe_subject",
		"slot": "employee"})
	EvSchedule.add("fixture.subject_open", 20, {}, "arc_fixture_subject")
	_ok("the arc is running with a subject", EvArcs.is_active("arc_fixture_subject"))
	_ok("and has a scheduled step", EvSchedule.has("fixture.subject_open"))

	GameState.day = 60
	CharacterRegistry.remove("emp_probe_subject")
	_ok("day 60: the subject is gone",
		CharacterRegistry.get_character("emp_probe_subject") == null)

	EvEngine.daily_tick()
	_ok("reassign PAUSES rather than kills",
		EvArcs.state_of("arc_fixture_subject") == EvArcs.STATE_AWAITING,
		"state is %s" % EvArcs.state_of("arc_fixture_subject"))
	_ok("the arc is NOT ended", EvArcs.state_of("arc_fixture_subject") != EvArcs.STATE_ENDED)
	_ok("its schedule was frozen, not dropped", not EvSchedule.has("fixture.subject_open"),
		"the step must leave the global schedule while the arc waits")
	_ok("and the step is remembered as a RELATIVE delay",
		(EvArcs.snapshot("arc_fixture_subject").get("frozen_schedule", []) as Array).size() == 1)

	# --- resuming: relative days re-materialise, nothing dumps at once -----
	var replacement := Character.new()
	replacement.id = "emp_probe_replacement"
	replacement.character_name = "Replacement"
	replacement.category = "employee"
	replacement.role = HRConstants.ROLE_DEVELOPER
	replacement.monthly_salary = 3000
	replacement.morale = 60
	replacement.traits = ["picks_it_up_fast"]
	replacement.role_stats = HRConstants.default_employee_skills()
	CharacterRegistry.add(replacement)

	GameState.day = 69
	EvArcs.reassign_subject("arc_fixture_subject",
		{"type": "employee", "id": "emp_probe_replacement", "slot": "employee"})
	_ok("a new subject resumes the arc", EvArcs.is_active("arc_fixture_subject"))
	_ok("the frozen step came back", EvSchedule.has("fixture.subject_open"))
	_ok("and it is NOT overdue after a 9-day pause",
		_due_day_of("fixture.subject_open") == 69,
		"due on day %d — a frozen arc must not dump every step at once on resume"
			% _due_day_of("fixture.subject_open"))

	# --- the 14-day timeout falls to close --------------------------------
	EvEngine.reset()
	EvCatalog.reload()
	GameState.day = 100
	EvArcs.start("arc_fixture_subject", {"type": "employee", "id": "emp_probe_replacement",
		"slot": "employee"})
	CharacterRegistry.remove("emp_probe_replacement")
	EvEngine.daily_tick()
	_ok("awaiting again", EvArcs.state_of("arc_fixture_subject") == EvArcs.STATE_AWAITING)
	_ok("not yet timed out", not EvArcs.awaiting_timed_out("arc_fixture_subject"))
	GameState.day = 100 + EvTuning.ARC_AWAITING_SUBJECT_TIMEOUT_DAYS
	_ok("timed out on day %d" % GameState.day,
		EvArcs.awaiting_timed_out("arc_fixture_subject"))
	EvEngine.daily_tick()
	_ok("and the timeout CLOSED it rather than leaving it hanging",
		EvArcs.state_of("arc_fixture_subject") == EvArcs.STATE_ENDED,
		"an arc may not wait for a subject for the rest of the run")

	# --- a promise arc may never fade (§10.6) -----------------------------
	var promise_def: Dictionary = EvCatalog.arc("arc_fixture_thesis")
	_ok("the fixture promise arc is typed as one",
		String(promise_def.get("type", "")) == EvArcs.TYPE_PROMISE)
	_ok("§10.6: its policy is not fade",
		String((promise_def.get("on_invalidate", {}) as Dictionary).get("policy", "")) != EvArcs.POLICY_FADE)
	_ok("§10.6: and its penalties are not empty",
		not ((promise_def.get("on_invalidate", {}) as Dictionary).get("penalties", []) as Array).is_empty(),
		"a promise that evaporates silently reads as a bug and the thesis dies with the trust")

	# --- a dead arc leaves nothing behind on any surface -------------------
	EvEngine.reset()
	EvCatalog.reload()
	GameState.day = 200
	EvArcs.start("arc_fixture_thesis")
	EvSchedule.add("fixture.thesis_payoff", 5, {}, "arc_fixture_thesis")
	EvQueue.admit("fixture.thesis_close", {}, "interrupt", "arc_fixture_thesis")
	EvPapers.place("fixture.concurrent", {}, 30, "arc_fixture_thesis")
	EvArcs.abort("arc_fixture_thesis", "probe")
	_ok("aborting sweeps the schedule", not EvSchedule.has("fixture.thesis_payoff"))
	_ok("and the queue", not EvQueue.has("fixture.thesis_close"))
	_ok("and the desk", not EvPapers.has("fixture.concurrent"),
		"§16.1 lists four separate arrays and §20 G3 only mentions one of them")

	# --- an unknown arc_id on load aborts, and does not crash --------------
	EvArcs.reset()
	EvArcs.from_dict({"arcs": {"arc_that_no_longer_exists": {
		"id": "arc_that_no_longer_exists", "state": "active", "step": 0, "vars": {},
		"subject": {}, "started_day": 1, "outcome": "", "awaiting_since": -1,
		"frozen_schedule": []}}})
	_ok("a save naming a vanished arc definition is dropped, not crashed",
		EvArcs.state_of("arc_that_no_longer_exists") == "")

	EvTuning.SHIPPED_SCOPES.clear()
	EvTuning.SHIPPED_SCOPES.append_array(shipped)
