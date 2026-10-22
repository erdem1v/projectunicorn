extends RefCounted

# --sprint-probe=hours=<h>:cards=<1|2>:ticks=<t>[:start=<hour>][:seeds=1][:seed=424242][:events=0|1][:rate=<r>]
# [:lead=0|1][:gate=publish|more][:team=<n>][:fill=0|1][:market=b2c|b2b][:incident=<kind>@<tick>]
# [:promise=0|1][:tstar=<1-5>][:pmstar=<1-5>][:plus=<role>@<stars>][:founder=0|1][:fixture=iz1|iz1b|iz2][:build=demo|ea|full]
# [:planms=0|1]:
# does the Product screen's sprint plan come true? A founder builds note_tool (market=b2b: the erp product, four
# accounts signed the tick it goes live, two of a night-shift sector) for t ticks on each of the seeds seed,
# seed+1, …, the company working h hours from start (the game's default start hour unless given); team=N adds N-1
# mid-skilled employees in RunProbe.SMALL_CREW order (team=4: a developer, a designer and a tester);
# incident=outage@8 makes tick 8's die an emergency of that kind (outage, month_close,
# checkout, regression or storm; it needs a live product past its launch weeks, so a run that lasts that long: fill=1;
# events=1: the card stops the night and is answered with the rest of the desk, the line a kind hits is given the
# bug it needs the tick before). An emergency answered with its fix first re-reads the plan, and the close is checked
# against that. promise=1 (market=b2b, once the accounts are signed) gives the biggest account a promise, due that
# sprint, on the card the plan says will not finish but leaves nearest to done (the likeliest to reach testing): the
# card brings the promise event, whose answer (the cut test, the overtime) re-reads the plan too. Every sprint is planned and started here on the tick
# it opens, so the ledger measures the engine, not a player's delay: cards=N tops it up to N cards (the
# carried ones stay, the open Core K1 candidates follow by effort, each through SprintSystem.add),
# fill=1 adds every open card the way "+" takes them instead (SprintCatalog.open_cards, cards= is not read),
# lead=1 takes the lead's plan instead; a sprint with nothing to start ends the seed.
# The MVP gate is answered on the tick it opens: gate=publish (the default) ships v1.0 there, gate=more takes
# one more sprint and ships at the next close's gate.
# The larger companies: team=12|25|50 seat product managers, designers, developers and testers beside the founder
# (RunProbe.seed_crew, each person's stat drawn from the seed); tstar= and pmstar= pin every tester's and product
# manager's stars, plus=developer@3 hires one more person (a role id and its stars), founder=0 takes the founder off the
# sprint team, build=ea plays the EA build's cards and endings. fixture= seats a small company by hand:
#   iz1   three developers of 4, 3 and 3 stars (founder=1 keeps the founder) and the first sprint's three Core K1 cards in
#         plan order: the big one two people finish in two sprints (three cannot end it in one), then two small ones one
#         person finishes in a week each, sized in person-weeks of the game's person_points_week; iz1b: the big card last
#         (ticks=4 plays the example's two sprints)
#   iz2   the founder, a 3-star developer and a 2-star designer, and four Core K1 cards in plan order (cards= is not read)
# planms=1 plays no tick: it times what the Product screen asks of the engine while the sprint is planned, in the world the
# other options build (fill=1 for the fullest plan), the first call of each a warm-up, then PLANMS_REPS calls:
#   SPRINTPROBE PLANMS|team=<sprint team>|cards=<sprint cards + open candidates>|what=<w>|n=<calls>|median_ms=|max_ms=
# what: plan_outcome, can_add (one call per open candidate), mvp_eta, lead (the lead's suggestion) and screen (ProductModel.live,
# the page's whole model); the milliseconds are this machine's.
# The plan the screen draws (SprintSystem.plan_outcome) is read when its sprint starts and checked when it
# closes. events=0 runs only the sprint's daily step, with no decision paper; events=1 runs the whole clock
# in batches (each visible hour, then the night up to 08:00), answers the desk through RunProbe after every
# batch and draws each sprint's decision paper at sprint.json's `decision.sprint_chance` unless rate= gives
# another chance.
#
#   SPRINTPROBE SKIP|<seed>|<sprint>|<card>|full|ceiling   add() refused the card (no point left for it, or
#                                                         the load past the ceiling), the sprint stays short
#   SPRINTPROBE SKIP|<seed>|<sprint>|-|empty          the sprint has nothing to start, the seed ends
#   SPRINTPROBE PRED|<seed>|<sprint>|<card>|<split id:weeks+…>|<done>|<finishes 1|0>|<no_start 1|0>|<mvp_eta>
#   SPRINTPROBE REPRED|<seed>|<sprint>|<card>|<done>|<finishes 1|0>|<emergency card>   the plan read again after an
#                                                         emergency answered with its fix first; CLOSE compares it
#   SPRINTPROBE CLOSE|<seed>|<sprint>|<card>|<shipped 1|0>|<carried_done>|MATCH|MISMATCH[|cause=<event id>|cause=team]
#   SPRINTPROBE MVP|<seed>|<tick>
#   SPRINTPROBE PAPER|<seed>|<sprint>|<event id>|<speaker id, - for a paper no one speaks>   a decision paper asked
#   SPRINTPROBE PAPERSUM|weeks=<w>|sprints=<n>|papers=<k>|empty=<n-k>|empty_rate=<share of sprints with no paper>
#   SPRINTPROBE LOAD|<seed>|<sprint>|<planned>|<finished>|<idle>|<limit>   one closed sprint
#   SPRINTPROBE SUMMARY|match=<matched>/<closes>|mvp_days=<tick>x<seeds>,…   (- = no MVP within t ticks)
#   SPRINTPROBE LOADSUM|team=<n>|weeks=<w>|sprints=<n>|planned=<n>|finished=<n>|idle=<n>|limits=<limit>:<n>,…
# done and carried_done are the points the card gets in this sprint (carried_done - for a card that
# finished). mvp_eta is the screen's MVP forecast when the sprint starts (SprintSystem.mvp_eta),
# <sprint>/<week>: the sprint whose close ships v1.0 and the week before that close's tick (- = none).
# planned is the sprint's cards when it starts, finished those done when it closes, idle the person-weeks with
# no card (SprintSystem's worked list), limit why the plan stopped: ceiling or full (add refused a card), pool
# (fill=1: every open card is in), cards (cards=N reached) or lead.
#
# MATCH: the card finished in its sprint exactly when the plan said it finishes, and a carried card got
# the points the plan gave it. A mismatch is named when, inside its sprint, a decision paper was asked or an
# answered event changed the team's points or a card's effort, progress or place (cause=<event id>), or the
# week's tick changed the team (cause=team). The run passes when no mismatch is unnamed.

## fixture=iz1: its developers' stars, and the big card's size in person-weeks per week of the sprint (two people for two
## sprints, a little short of full so that three people still cannot end it in the first).
const EXAMPLE_STARS := [4, 3, 3]
const EXAMPLE_BIG := 3.5
## planms=1: the calls timed after the warm-up.
const PLANMS_REPS := 9

static var _said: Dictionary = {}   # the running sprint: card id -> [plan finishes, plan's points, points before]
static var _seed: int = 0           # the seed being run
static var _cause: String = ""      # the first change that names the running sprint's mismatches
static var _seen: Array = []
static var _tally: Dictionary = {}  # the running sprint: {planned, idle, limit}
static var _sum: Dictionary = {}
static var _papered: Dictionary = {}  # "<seed>|<sprint>" -> true for a sprint that brought a decision paper


static func run(spec: String, payload: Dictionary) -> bool:
	var o: Dictionary = {"start": HRConstants.START_HOUR_DEFAULT, "seeds": 1, "seed": 424242, "events": 0,
		"lead": 0, "gate": "publish", "team": 1, "fill": 0, "market": "b2c", "incident": "", "promise": 0,
		"tstar": 0, "pmstar": 0, "plus": "", "founder": -1, "fixture": "", "build": "", "planms": 0}
	for part in spec.split(":"):
		var key: String = part.get_slice("=", 0)
		if key in ["gate", "market", "incident", "plus", "fixture", "build"]:
			o[key] = part.get_slice("=", 1)
		else:
			o[key] = part.get_slice("=", 1).to_float()
	if o.build != "":
		if o.build not in EndingsSystem.SHIPPED_SCOPES_BY_BUILD:
			print("SPRINTPROBE ERROR bad build '%s'" % o.build)
			return false
		EndingsSystem.build_scope_override = o.build
	if o.fixture == "iz2":
		o.cards = 4
	var events: bool = o.events == 1
	(SprintCatalog.cfg("decision") as Dictionary).sprint_chance = \
		float(o.get("rate", SprintCatalog.cfg("decision.sprint_chance"))) if events else 0.0
	EventBus.card_decision_requested.connect(func(_card: String) -> void: _paper_asked())
	EventBus.event_resolved.connect(func(id: String, _choice: int) -> void: _changed_by(id))
	EventBus.day_tick_completed.connect(func(_day: int) -> void: _changed_by("team"))
	var verdicts: Array = []
	var days: Dictionary = {}
	_sum = {"sprints": 0, "planned": 0, "finished": 0, "idle": 0, "limits": {}, "papers": 0}
	for i in int(o.seeds):
		var seed_value: int = int(o.seed) + i
		_seed = seed_value
		# initialize_run alone would keep the previous seed's registries and event pipeline.
		SaveManager.reset_all_owners()
		GameState.initialize_run(payload.merged({"seed": seed_value}))
		var subtype: String = "erp" if o.market == "b2b" else "note_tool"
		SprintSystem.choose_type(subtype, RunProbe.PRODUCT_NAMES[subtype])
		_seat(o)
		if o.incident != "":
			IncidentSystem.force_on(String(o.incident).get_slice("@", 0), int(String(o.incident).get_slice("@", 1)))
		WorkHoursSystem.set_company_start_hour(int(o.start))
		WorkHoursSystem.set_company_hours(int(o.hours))
		if String(o.fixture).begins_with("iz1"):
			_example_cards(o.fixture == "iz1")
		var going: bool = _plan(seed_value, o, verdicts)
		while going and GameState.day < int(o.ticks) and GameState.run_active:
			if events:
				var day: int = GameState.day
				if o.incident != "" and day == int(String(o.incident).get_slice("@", 1)) - 1:
					_stage_incident(String(o.incident).get_slice("@", 0), o.market == "b2b")
				while GameState.day == day and GameState.run_active:
					if TimeManager.is_night() or GameState.current_hour == TimeModel.HOURS_PER_DAY - 1:
						TimeManager.skip_night()
					else:
						TimeManager.advance_hours(1)
					RunProbe._drain_modals()
			else:
				GameState.advance_day()
				SprintSystem.daily_tick()
			_count_idle()
			if o.market == "b2b" and ProductState.is_live() and CustomerRegistry.get_by_market("b2b").is_empty():
				_sign_book()
			going = _plan(seed_value, o, verdicts)
		var mvp: int = GameState.get_flag("mvp_launch_day", -1)
		days[mvp] = days.get(mvp, 0) + 1
	if o.planms == 1:
		return true
	var order: Array = days.keys()
	order.sort()
	print("SPRINTPROBE SUMMARY|match=%d/%d|mvp_days=%s" % [verdicts.count("MATCH"), verdicts.size(),
		",".join(order.map(func(d: int) -> String: return "%sx%d" % ["-" if d < 0 else str(d), days[d]]))])
	print("SPRINTPROBE LOADSUM|team=%d|weeks=%d|sprints=%d|planned=%d|finished=%d|idle=%d|limits=%s" % [int(o.team),
		SprintSystem.sprint_weeks(), _sum.sprints, _sum.planned, _sum.finished, _sum.idle,
		",".join(_sum.limits.keys().map(func(k: String) -> String: return "%s:%d" % [k, _sum.limits[k]]))])
	print("SPRINTPROBE PAPERSUM|weeks=%d|sprints=%d|papers=%d|empty=%d|empty_rate=%.2f" % [SprintSystem.sprint_weeks(),
		_sum.sprints, _sum.papers, _sum.sprints - _sum.papers, 1.0 - float(_sum.papers) / maxf(1.0, _sum.sprints)])
	# A named mismatch carries its cause in the verdict; a bare one is unnamed.
	return not verdicts.has("MISMATCH")


static func _plan(seed_value: int, o: Dictionary, verdicts: Array) -> bool:
	var p: Dictionary = GameState.product
	if SprintSystem.mode() == "release":
		var finished: int = 0
		for id in _said:
			var carried: Array = p.release.carried.filter(func(c: Dictionary) -> bool: return c.id == id)
			var got: float = 0.0 if carried.is_empty() else float(carried[0].done) - _said[id][2]
			var verdict: String = "MATCH" if carried.is_empty() == _said[id][0] \
				and (carried.is_empty() or absf(got - _said[id][1]) <= SprintSystem.EPS) \
				else "MISMATCH" + ("" if _cause == "" else "|cause=" + _cause)
			verdicts.append(verdict)
			print("SPRINTPROBE CLOSE|%d|%d|%s|%d|%s|%s" % [seed_value, p.release.sprint, id, int(carried.is_empty()),
				"-" if carried.is_empty() else "%.2f" % got, verdict])
			finished += int(carried.is_empty())
		print("SPRINTPROBE LOAD|%d|%d|%d|%d|%d|%s" % [seed_value, p.release.sprint, _tally.planned, finished,
			_tally.idle, _tally.limit])
		_sum.sprints += 1
		_sum.papers += int(_papered.has("%d|%d" % [seed_value, p.release.sprint]))
		_sum.planned += _tally.planned
		_sum.finished += finished
		_sum.idle += _tally.idle
		_sum.limits[_tally.limit] = _sum.limits.get(_tally.limit, 0) + 1
		# gate=more answers the first gate with one more sprint (plan_next below) and publishes the next one:
		# the unpublished gate's record keeps its gate.
		if o.gate == "publish" or p.releases.filter(func(r: Dictionary) -> bool: return r.gate).size() > 1:
			SprintSystem.publish()
		if GameState.get_flag("mvp_launch_day", -1) == GameState.day:
			print("SPRINTPROBE MVP|%d|%d" % [seed_value, GameState.day])
		SprintSystem.plan_next()
	if SprintSystem.mode() != "plan":
		return true
	var limit: String = "lead"
	if o.lead == 1:
		SprintSystem.apply_lead()
	elif String(o.fixture).begins_with("iz1") and SprintSystem.sprint_number() == 1:
		limit = "fixture"
	else:
		limit = "pool"
		for c in (SprintCatalog.open_cards([]) if o.fill == 1 else SprintCatalog.mvp_candidates()):
			if o.fill != 1 and p.sprint.cards.size() >= int(o.cards):
				limit = "cards"
				break
			SprintSystem.add(c.id)
			if not p.sprint.cards.has(c.id):
				# add() refuses an open card when no point is left for it or the load would pass the ceiling.
				limit = "ceiling" if SprintSystem.plan_outcome().spare > SprintSystem.EPS else "full"
				print("SPRINTPROBE SKIP|%d|%d|%s|%s" % [seed_value, SprintSystem.sprint_number(), c.id, limit])
				break
	if o.promise == 1:
		_promise_late_card()
	if o.planms == 1:
		_plan_ms()
		return false
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
	var papered: bool = _papered.has("%d|%d" % [seed_value, SprintSystem.sprint_number()])
	_cause = GameState.product.decision.event_id if papered else ""
	_seen = _inputs()
	_tally = {"planned": p.sprint.cards.size(), "idle": 0, "limit": limit}
	return true


## A decision paper was asked: the speaker is the person the engine bound it to (the decision record keeps them).
static func _paper_asked() -> void:
	var decision: Dictionary = GameState.product.decision
	_papered["%d|%d" % [_seed, SprintSystem.sprint_number()]] = true
	# The staff moves off the card until the answer, so a paper still waiting at the week's end costs the card that
	# week: it names the sprint.
	if _cause == "":
		_cause = decision.event_id
	print("SPRINTPROBE PAPER|%d|%d|%s|%s" % [_seed, SprintSystem.sprint_number(), decision.event_id,
		"-" if decision.speaker == "" else decision.speaker])


## The sprint team: team= people (the fixture's own few instead), plus= one more, the founder off it with founder=0 (a fixture
## named iz1 takes him off unless founder=1).
static func _seat(o: Dictionary) -> void:
	match o.fixture:
		"iz1", "iz1b":
			for i in EXAMPLE_STARS.size():
				RunProbe.seed_hire("char_probe_%d" % i, HRConstants.ROLE_DEVELOPER, HRConstants.POINTS_PER_STAR * EXAMPLE_STARS[i])
		"iz2":
			RunProbe.seed_hire("char_probe_0", HRConstants.ROLE_DEVELOPER, HRConstants.POINTS_PER_STAR * 3)
			RunProbe.seed_hire("char_probe_1", HRConstants.ROLE_DESIGNER, HRConstants.POINTS_PER_STAR * 2)
		_:
			RunProbe.seed_crew(int(o.team), _seed, int(o.tstar), int(o.pmstar))
	if o.plus != "":
		RunProbe.seed_hire("char_probe_plus", String(o.plus).get_slice("@", 0),
			HRConstants.POINTS_PER_STAR * int(String(o.plus).get_slice("@", 1)))
	if o.founder == 0 or (o.founder < 0 and String(o.fixture).begins_with("iz1")):
		CharacterRegistry.clear_jobs(CharacterRegistry.get_founder().id)


## fixture=iz1: the first sprint's three Core K1 cards, the big one first (last with iz1b). They go in at their catalog
## size and are resized after, as the product shots do, because the plan takes no small card behind a big full one. The big
## card is EXAMPLE_BIG person-weeks per week of the sprint, each small one a person-week, a person-week being what a 3-star
## developer of this company makes in one (person_points_week through the skill band, the hours and the pace).
static func _example_cards(big_first: bool) -> void:
	var week: float = SprintSystem.team().filter(func(t: Dictionary) -> bool: return t.id == "char_probe_1")[0].points
	var big: int = roundi(EXAMPLE_BIG * SprintSystem.sprint_weeks() * week)
	var ids: Array = SprintCatalog.mvp_candidates().slice(0, 3).map(func(c: Dictionary) -> String: return c.id)
	for id in ids:
		SprintSystem.add(id)
	var sizes: Array = [big, roundi(week), roundi(week)] if big_first else [roundi(week), roundi(week), big]
	for i in ids.size():
		var card: Dictionary = GameState.product.cards[ids[i]]
		card.need = SprintCatalog.card_need(card.kind, card.line, card.target_tier, sizes[i])


## planms=1: what the Product screen asks of the engine in this plan, timed on this machine (PLANMS rows). The first call of
## each is a warm-up and is not counted; the sprint is never started.
static func _plan_ms() -> void:
	var open: Array = SprintCatalog.open_cards([])
	var team: int = SprintSystem.team().size()
	var cards: int = GameState.product.sprint.cards.size() + open.size()
	_plan_row(team, cards, "plan_outcome", _timed(func() -> void: SprintSystem.plan_outcome()))
	var adds: Array = []
	for c in open:
		adds.append_array(_timed(func() -> void: SprintSystem.can_add(c.id)))
	_plan_row(team, cards, "can_add", adds)
	_plan_row(team, cards, "mvp_eta", _timed(func() -> void: SprintSystem.mvp_eta()))
	_plan_row(team, cards, "lead", _timed(func() -> void: SprintCatalog.lead_suggestion()))
	_plan_row(team, cards, "screen", _timed(func() -> void: ProductModel.live()))


## PLANMS_REPS timings (milliseconds) of `work`, after one call that is not counted.
static func _timed(work: Callable) -> Array:
	work.call()
	var ms: Array = []
	for _i in PLANMS_REPS:
		var started: int = Time.get_ticks_usec()
		work.call()
		ms.append((Time.get_ticks_usec() - started) / 1000.0)
	return ms


static func _plan_row(team: int, cards: int, what: String, ms: Array) -> void:
	if ms.is_empty():
		return
	ms.sort()
	print("SPRINTPROBE PLANMS|team=%d|cards=%d|what=%s|n=%d|median_ms=%.3f|max_ms=%.3f" % [team, cards, what, ms.size(),
		ms[int(ms.size() * 0.5)], ms[-1]])


## Four signed accounts, the biggest two of a night-shift sector: the book an emergency lands on (market=b2b).
static func _sign_book() -> void:
	for row in [["logistics", 60, 3200], ["manufacturing", 40, 2400], ["retail", 30, 1800], ["insurance", 20, 1400]]:
		var c := Customer.new()
		c.id = "co_probe_" + row[0]
		c.company_name = c.id
		c.industry = row[0]
		c.market_type = "b2b"
		c.seats = row[1]
		c.mrr = row[2]
		c.satisfaction = 72
		c.tolerance = 40
		c.acquired_on_day = GameState.day
		c.update_health_from_satisfaction()
		CustomerRegistry.add(c)


## A promise from the biggest signed account for the step of the card the plan says will not finish but leaves nearest
## to done, due this sprint (promise=); none before the book is signed or when every card with a step finishes.
static func _promise_late_card() -> void:
	var p: Dictionary = GameState.product
	var plan: Dictionary = SprintSystem.plan_outcome().cards
	var left := func(id: String) -> float: return SprintSystem.remaining(p.cards[id]) - plan[id].done
	var late: Array = p.sprint.cards.filter(func(id: String) -> bool: return not plan[id].finishes and p.cards[id].step != "")
	var book: Array = CustomerRegistry.get_by_market("b2b")
	if book.is_empty() or late.is_empty():
		return
	late.sort_custom(func(a: String, b: String) -> bool: return left.call(a) < left.call(b))
	book.sort_custom(SprintCatalog.larger_account)
	PromiseRegistry.create(book[0].id, p.cards[late[0]].step, 1).due_sprint = SprintSystem.sprint_number()


## What a forced emergency of this kind finds in the world the tick before it comes (incident=): the bugs on a line it
## hits (one the running sprint holds no fix card for, or that sprint's close would clear them), a paid plan for payments
## to fail, an audience (one big enough for anyone to be hurt, a crowd for a post to go round).
static func _stage_incident(kind: String, b2b: bool) -> void:
	if not b2b:
		SalesSystem.add_b2c_audience(maxi(0, int(SprintCatalog.cfg("incident.outage.min_audience")) - roundi(SalesSystem.b2c_audience())))
	match kind:
		"month_close":
			ProductState.add_bugs(_free_line("incident.month_close.lines"), int(SprintCatalog.cfg("incident.month_close.line_bugs")))
		"regression":
			ProductState.add_bugs(_free_line("incident.regression." + ("b2b" if b2b else "b2c")), 1)
		"storm":
			ProductState.add_bugs(_free_line("incident.storm.lines"), 1)
			SalesSystem.add_b2c_audience(maxi(0, int(SprintCatalog.cfg("incident.storm.min_audience")) - roundi(SalesSystem.b2c_audience())))
		"checkout":
			SalesSystem.open_b2c_paid_tier(SalesSystem.B2C_PRICE_DEFAULT)


## The first of these lines (a config list of line ids, shared ones without their product) the running sprint has no
## fix card for.
static func _free_line(path: String) -> String:
	var sprinted: Array = GameState.product.sprint.cards
	var lines: Array = (SprintCatalog.cfg(path) as Array).map(func(id: String) -> String:
		return id + "@" + ProductState.subtype() if id.begins_with("line_shared_") else id)
	for line in lines:
		if not sprinted.has("fix:" + line):
			return line
	return lines[0]


## The week the tick closed: team members on no card, by the engine's worked list.
static func _count_idle() -> void:
	var worked: Dictionary = GameState.product.worked
	if int(worked.day) != GameState.day:
		return
	var ids: Dictionary = {}
	for id in worked.ids:
		ids[id] = true
	_tally.idle += SprintSystem.team().size() - ids.size()


## What the running sprint works with: the team at its weekly points and each card's remaining effort.
static func _inputs() -> Array:
	var p: Dictionary = GameState.product
	return [SprintSystem.team(), p.sprint.cards.map(func(id: String) -> Array:
		return [id, SprintSystem.remaining(p.cards[id])])]


## At a tick's end the week's work is already in the cards, so the tick compares only the team. An emergency answered
## with its line's fix first moved the cards about: the plan is read again, and the close is checked against it.
static func _changed_by(who: String) -> void:
	if SprintSystem.mode() != "active":
		return
	var now: Array = _inputs()
	if _cause == "" and (now[0] != _seen[0] or (who != "team" and now[1] != _seen[1])):
		_cause = who
	var promise: bool = who == "product.promise_due"
	var moved: bool = now[1] != _seen[1] or (promise and now[0] != _seen[0])
	if who != "team" and moved and (promise or EvCatalog.card(who).get("tags", []).has("incident")):
		_reread(who)
	_seen = now


## The sprint's plan from here on, with the points each card has made since the sprint (or the card) began. After an
## emergency's answer a close that differs from it is named by what changed after that point, not by the answer.
static func _reread(who: String) -> void:
	if who != "product.promise_due":
		_cause = ""
	var p: Dictionary = GameState.product
	var plan: Dictionary = SprintSystem.plan_outcome().cards
	for id in p.sprint.cards:
		var card: Dictionary = p.cards[id]
		var made: float = SprintSystem.total(card) - SprintSystem.remaining(card)
		var before: float = _said[id][2] if _said.has(id) else made
		_said[id] = [plan[id].finishes, plan[id].done + made - before, before]
		print("SPRINTPROBE REPRED|%d|%d|%s|%.2f|%d|%s" % [_seed, SprintSystem.sprint_number(), id, _said[id][1],
			int(plan[id].finishes), who])
