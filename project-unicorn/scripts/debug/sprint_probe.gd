extends RefCounted

# --sprint-probe=hours=<h>:cards=<1|2>:ticks=<t>[:start=<hour>][:seeds=1][:seed=424242][:events=0|1][:rate=<r>]
# [:beta=0|1][:lead=0|1][:gate=publish|more]: does the Product screen's sprint plan come true? A solo founder builds
# note_tool for t ticks on each of the seeds seed, seed+1, …, the company working h hours from start
# (the game's default start hour unless given). Every sprint is planned and started here on the tick it
# opens, so the ledger measures the engine, not a player's delay: cards=N tops it up to N cards (the
# carried ones stay, the open Core K1 candidates follow by effort, each through SprintSystem.add),
# lead=1 takes the lead's plan instead, beta=1 opens Beta; a sprint with nothing to start ends the seed.
# The MVP gate is answered on the tick it opens: gate=publish (the default) ships v1.0 there, gate=more takes
# one more sprint and ships at the next close's gate.
# The plan the screen draws (SprintSystem.plan_outcome) is read when its sprint starts and checked when it
# closes. events=0 runs only the sprint's daily step, with no decision paper; events=1 runs the whole clock
# in batches (each visible hour, then the night up to 08:00), answers the desk through RunProbe after every
# batch and draws sprint decisions at sprint.json's rate unless rate= is given.
#
#   SPRINTPROBE SKIP|<seed>|<sprint>|<card>|full|ceiling   add() refused the card (no point left for it, or
#                                                         the load past the ceiling), the sprint stays short
#   SPRINTPROBE SKIP|<seed>|<sprint>|-|empty          the sprint has nothing to start, the seed ends
#   SPRINTPROBE PRED|<seed>|<sprint>|<card>|<split id:weeks+…>|<done>|<finishes 1|0>|<no_start 1|0>|<mvp_eta>
#   SPRINTPROBE CLOSE|<seed>|<sprint>|<card>|<shipped 1|0>|<carried_done>|MATCH|MISMATCH[|cause=<event id>|cause=team]
#   SPRINTPROBE MVP|<seed>|<tick>
#   SPRINTPROBE SUMMARY|match=<matched>/<closes>|mvp_days=<tick>x<seeds>,…   (- = no MVP within t ticks)
# done and carried_done are the points the card gets in this sprint (carried_done - for a card that
# finished). mvp_eta is the screen's MVP forecast when the sprint starts (SprintSystem.mvp_eta),
# <sprint>/<week>: the sprint whose close ships v1.0 and the week before that close's tick (- = none).
#
# MATCH: the card finished in its sprint exactly when the plan said it finishes, and a carried card got
# the points the plan gave it. A mismatch is named when, inside its sprint, an answered event changed the
# team's points or a card's effort, progress or place (cause=<event id>), or the week's tick changed the
# team (cause=team). The run passes when no mismatch is unnamed.

static var _said: Dictionary = {}   # the running sprint: card id -> [plan finishes, plan's points, points before]
static var _cause: String = ""      # the first change that names the running sprint's mismatches
static var _seen: Array = []


static func run(spec: String, payload: Dictionary) -> bool:
	var o: Dictionary = {"start": HRConstants.START_HOUR_DEFAULT, "seeds": 1, "seed": 424242, "events": 0,
		"beta": 0, "lead": 0, "gate": "publish"}
	for part in spec.split(":"):
		var key: String = part.get_slice("=", 0)
		if key == "gate":
			o.gate = part.get_slice("=", 1)
		else:
			o[key] = part.get_slice("=", 1).to_float()
	var events: bool = o.events == 1
	(SprintCatalog.cfg("decision") as Dictionary).rate = o.get("rate", SprintCatalog.cfg("decision.rate")) \
		if events else 0.0
	EventBus.event_resolved.connect(func(id: String, _choice: int) -> void: _changed_by(id))
	EventBus.day_tick_completed.connect(func(_day: int) -> void: _changed_by("team"))
	var verdicts: Array = []
	var days: Dictionary = {}
	for i in int(o.seeds):
		var seed_value: int = int(o.seed) + i
		# initialize_run alone would keep the previous seed's registries and event pipeline.
		SaveManager.reset_all_owners()
		GameState.initialize_run(payload.merged({"seed": seed_value}))
		SprintSystem.choose_type("note_tool", "Notly")
		WorkHoursSystem.set_company_start_hour(int(o.start))
		WorkHoursSystem.set_company_hours(int(o.hours))
		SprintSystem.set_beta(o.beta == 1)
		var going: bool = _plan(seed_value, o, verdicts)
		while going and GameState.day < int(o.ticks) and GameState.run_active:
			if events:
				var day: int = GameState.day
				while GameState.day == day and GameState.run_active:
					if TimeManager.is_night() or GameState.current_hour == TimeModel.HOURS_PER_DAY - 1:
						TimeManager.skip_night()
					else:
						TimeManager.advance_hours(1)
					RunProbe._drain_modals()
			else:
				GameState.advance_day()
				SprintSystem.daily_tick()
			going = _plan(seed_value, o, verdicts)
		var mvp: int = GameState.get_flag("mvp_launch_day", -1)
		days[mvp] = days.get(mvp, 0) + 1
	var order: Array = days.keys()
	order.sort()
	print("SPRINTPROBE SUMMARY|match=%d/%d|mvp_days=%s" % [verdicts.count("MATCH"), verdicts.size(),
		",".join(order.map(func(d: int) -> String: return "%sx%d" % ["-" if d < 0 else str(d), days[d]]))])
	# A named mismatch carries its cause in the verdict; a bare one is unnamed.
	return not verdicts.has("MISMATCH")


static func _plan(seed_value: int, o: Dictionary, verdicts: Array) -> bool:
	var p: Dictionary = GameState.product
	if SprintSystem.mode() == "release":
		for id in _said:
			var carried: Array = p.release.carried.filter(func(c: Dictionary) -> bool: return c.id == id)
			var got: float = 0.0 if carried.is_empty() else float(carried[0].done) - _said[id][2]
			var verdict: String = "MATCH" if carried.is_empty() == _said[id][0] \
				and (carried.is_empty() or absf(got - _said[id][1]) <= SprintSystem.EPS) \
				else "MISMATCH" + ("" if _cause == "" else "|cause=" + _cause)
			verdicts.append(verdict)
			print("SPRINTPROBE CLOSE|%d|%d|%s|%d|%s|%s" % [seed_value, p.release.sprint, id, int(carried.is_empty()),
				"-" if carried.is_empty() else "%.2f" % got, verdict])
		# gate=more answers the first gate with one more sprint (plan_next below) and publishes the next one:
		# the unpublished gate's record keeps its gate.
		if o.gate == "publish" or p.releases.filter(func(r: Dictionary) -> bool: return r.gate).size() > 1:
			SprintSystem.publish()
		if GameState.get_flag("mvp_launch_day", -1) == GameState.day:
			print("SPRINTPROBE MVP|%d|%d" % [seed_value, GameState.day])
		SprintSystem.plan_next()
	if SprintSystem.mode() != "plan":
		return true
	if o.lead == 1:
		SprintSystem.apply_lead()
	else:
		for c in SprintCatalog.mvp_candidates():
			if p.sprint.cards.size() >= int(o.cards):
				break
			SprintSystem.add(c.id)
			if not p.sprint.cards.has(c.id):
				# add() refuses an open card when no point is left for it or the load would pass the ceiling.
				print("SPRINTPROBE SKIP|%d|%d|%s|%s" % [seed_value, SprintSystem.sprint_number(), c.id,
					"ceiling" if SprintSystem.plan_outcome().spare > SprintSystem.EPS else "full"])
				break
	var plan: Dictionary = SprintSystem.plan_outcome().cards
	var eta: Dictionary = SprintSystem.mvp_eta()
	_said = {}
	for id in p.sprint.cards:
		var card: Dictionary = plan[id]
		_said[id] = [card.finishes, card.done, SprintSystem.total(p.cards[id]) - SprintSystem.remaining(p.cards[id])]
		print("SPRINTPROBE PRED|%d|%d|%s|%s|%.2f|%d|%d|%s" % [seed_value, SprintSystem.sprint_number(), id,
			"+".join(card.split.map(func(w: Dictionary) -> String: return "%s:%d" % [w.id, w.weeks])), card.done,
			int(card.finishes), int(card.done <= SprintSystem.EPS),
			"-" if eta.is_empty() else "%d/%d" % [eta.sprint, eta.week]])
	if not SprintSystem.start():
		print("SPRINTPROBE SKIP|%d|%d|-|empty" % [seed_value, SprintSystem.sprint_number()])
		return false
	_cause = ""
	_seen = _inputs()
	return true


## What the running sprint works with: the team at its weekly points and each card's remaining effort.
static func _inputs() -> Array:
	var p: Dictionary = GameState.product
	return [SprintSystem.team(), p.sprint.cards.map(func(id: String) -> Array:
		return [id, SprintSystem.remaining(p.cards[id])])]


## At a tick's end the week's work is already in the cards, so the tick compares only the team.
static func _changed_by(who: String) -> void:
	if SprintSystem.mode() != "active":
		return
	var now: Array = _inputs()
	if _cause == "" and (now[0] != _seen[0] or (who != "team" and now[1] != _seen[1])):
		_cause = who
	_seen = now
