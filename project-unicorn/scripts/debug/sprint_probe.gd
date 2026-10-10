extends RefCounted

# --sprint-probe=hours=<h>:cards=<1|2>:ticks=<t>[:start=<hour>][:seeds=1][:seed=424242][:events=0|1][:rate=<r>]
# [:beta=0|1][:lead=0|1]: does the Product screen's sprint plan come true? A solo founder builds
# note_tool for t ticks on each of the seeds seed, seed+1, …, the company working h hours from start
# (the game's default start hour unless given). Every sprint is planned and started here on the tick it
# opens, so the ledger measures the engine, not a player's delay: cards=N tops it up to N cards (the
# carried ones stay, the open Core K1 candidates follow by effort, each through SprintSystem.add),
# lead=1 takes the lead's plan instead, beta=1 opens Beta; a sprint with nothing to start ends the seed.
# What the screen says of each card is read when its sprint starts and checked when it closes. events=0
# runs only the sprint's daily step, with no decision paper; events=1 runs the whole clock in batches
# (each visible hour, then the night up to 08:00), answers the desk through RunProbe after every batch
# and draws sprint decisions at sprint.json's rate unless rate= is given.
#
#   SPRINTPROBE SKIP|<seed>|<sprint>|<card>|ceiling   add() refused the card, the sprint stays short
#   SPRINTPROBE SKIP|<seed>|<sprint>|-|empty          the sprint has nothing to start, the seed ends
#   SPRINTPROBE CLOSE|<seed>|<sprint>|<card>|<shipped 1|0>|<carried_done>|MATCH|MISMATCH[|cause=<event id>|cause=team]
#   SPRINTPROBE MVP|<seed>|<tick>
#   SPRINTPROBE SUMMARY|match=<matched>/<closes>|mvp_days=<tick>x<seeds>,…   (- = no MVP within t ticks)
# carried_done is the points a carried card got in this sprint, - for a card that finished.
#
# MATCH: the card finished in its sprint exactly when the screen did not tag it as carrying over. A
# mismatch is named when, inside its sprint, an answered event changed the team's points or a card's
# effort, progress or place (cause=<event id>), or the week's tick changed the team (cause=team). The
# run passes when no mismatch is unnamed.

static var _said: Dictionary = {}   # the running sprint: card id -> [the screen says it finishes, points done]
static var _cause: String = ""      # the first change that names the running sprint's mismatches
static var _seen: Array = []


static func run(spec: String, payload: Dictionary) -> bool:
	var o: Dictionary = {"start": HRConstants.START_HOUR_DEFAULT, "seeds": 1, "seed": 424242, "events": 0,
		"beta": 0, "lead": 0}
	for part in spec.split(":"):
		o[part.get_slice("=", 0)] = part.get_slice("=", 1).to_float()
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
			var verdict: String = "MATCH" if carried.is_empty() == _said[id][0] \
				else "MISMATCH" + ("" if _cause == "" else "|cause=" + _cause)
			verdicts.append(verdict)
			print("SPRINTPROBE CLOSE|%d|%d|%s|%d|%s|%s" % [seed_value, p.release.sprint, id, int(carried.is_empty()),
				"-" if carried.is_empty() else "%.2f" % (float(carried[0].done) - _said[id][1]), verdict])
		if GameState.get_flag("mvp_launch_day", -1) == GameState.day:
			print("SPRINTPROBE MVP|%d|%d" % [seed_value, GameState.day])
		SprintSystem.plan_next()
	if SprintSystem.mode() != "plan":
		return true
	if o.lead == 1:
		SprintSystem.apply_lead()
	else:
		var open: Array = SprintCatalog.candidates("core").filter(func(c: Dictionary) -> bool:
			return c.kind == "feature" and int(c.target_tier) == 1 and c.state == "candidate")
		open.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
			return a.effort < b.effort if a.effort != b.effort else a.id < b.id)
		for c in open:
			if p.sprint.cards.size() >= int(o.cards):
				break
			SprintSystem.add(c.id)
			if not p.sprint.cards.has(c.id):
				# add() refuses an open card only when the load is past the ceiling.
				print("SPRINTPROBE SKIP|%d|%d|%s|ceiling" % [seed_value, SprintSystem.sprint_number(), c.id])
				break
	_said = {}
	for card in ProductModel.live().center.cards:
		if card.id in p.sprint.cards:
			var c: Dictionary = p.cards[card.id]
			_said[card.id] = [not card.spills, SprintSystem.total(c) - SprintSystem.remaining(c)]
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
