class_name IncidentSystem
extends RefCounted

# THE NIGHT'S EMERGENCIES. Rare, sudden and real: the service goes down while the office sleeps and the player picks who
# pays for it. The system asks for the card by name (EventGate.request); the card owns the words and the option
# structure, this file the numbers a cost is made of, so a chip, the history row and what lands read one figure (plan).
#
# THE ROLL. p = min(BASE x load x (1 + min(open bugs, 12) / 8), P_MAX) x tier: the tier weighs the capped odds, so each
# server tier keeps its share at any load or bug count. Two emergencies are at least MIN_GAP ticks apart. The die is
# rolled once, in the 00:00 daily slice, and only decides: whether tonight has one and which minute of the night it
# began (`pending`). The card is asked for in the hourly slice of the first full hour after that minute, with the clock
# held (a night batch stops there, the card opens at once, and the answer lets the night carry on from where it
# stopped). A card the gate refuses is an emergency that never began: no stamp, no hold.
#
# Every number is in data/product/sprint.json `incident` and is [WORKING], except the server tiers'
# weights (`tier`), which the owner set.
#
# State is GameState.incident: {last_day, pending: {kind, minute}, open: {kind, start, opened, tried, back}, forced}.
# `open` stays after the answer: the card's words and the history rows read it.

## The card of each emergency, by kind and market.
const CARDS := {"outage": {"b2b": "product.incident_outage_b2b", "b2c": "product.incident_outage_b2c"}}
## The reason the clock is held while an emergency waits for its answer (TimeManager.HOLD_LABELS).
const HOLD := "incident"
## Debug switch: false skips the random die, for a harness that does not answer cards (an emergency holds the clock
## until its card is answered); an emergency forced with `force_on` still comes.
static var rolls := true

## The answers that leave the fix to the workday's start: the accounts pay for the hours they could not work.
const MORNING_ACTS := ["morning", "morning_credit", "morning_free_month"]


static func _cfg(path: String) -> Variant:
	return SprintCatalog.cfg("incident." + path)


# --- The roll --------------------------------------------------------------

## The server tier's weight on the odds: the cheaper the machines, the likelier the night.
static func tier_mult() -> float:
	return float((_cfg("tier") as Dictionary).get(InfraSystem.provider(), 1.0))


## How full the servers are is not part of the odds until the capacity rule is settled.
static func load_mult() -> float:
	return 1.0


## The week's chance of an emergency tonight.
static func hazard() -> float:
	var bugs: int = mini(ProductState.costed(ProductState.open_bugs()), int(_cfg("bug_cap")))
	var odds: float = float(_cfg("base")) * load_mult() * (1.0 + float(bugs) / float(_cfg("bug_div")))
	return minf(odds, float(_cfg("p_max"))) * tier_mult()


## Can the week have one: the product is live, MIN_GAP ticks have passed since the last, the launch weeks are over and
## someone is there to be hurt (an account, or an audience big enough to notice).
static func can_happen() -> bool:
	var inc: Dictionary = GameState.incident
	if not ProductState.is_live() or (inc.has("last_day") and GameState.day - int(inc.last_day) < int(_cfg("min_gap"))):
		return false
	if GameState.has_flag("mvp_launch_day") \
			and GameState.day - int(GameState.get_flag("mvp_launch_day")) < int(_cfg("launch_quiet")):
		return false
	match ProductState.market_type():
		"b2b":
			return not accounts().is_empty()
		"b2c":
			return SalesSystem.b2c_audience() >= float(_cfg("outage.min_audience"))
	return false


## 00:00: the die. It only decides whether tonight has an emergency and the minute of the night it began.
static func daily_tick() -> void:
	var inc: Dictionary = GameState.incident
	var forced: Dictionary = inc.get("forced", {})
	var asked: bool = int(forced.get("day", -1)) == GameState.day
	if asked:
		inc.erase("forced")
	if not can_happen():
		return
	if not asked and (not rolls or EvDice.unit("incident", GameState.day, "roll", "") >= hazard()):
		return
	var span: Array = _cfg("outage.start")
	var step: int = int(_cfg("outage.start_step"))
	var steps: int = (int(span[1]) - int(span[0])) / step + 1
	inc["pending"] = {"kind": String(forced.get("kind", "outage")),
		"minute": int(span[0]) + step * floori(EvDice.unit("incident", GameState.day, "start", "") * steps)}


## Every hour: the card of tonight's emergency is asked for at the first full hour after it began.
static func hourly_tick(hour: int) -> void:
	var pending: Dictionary = GameState.incident.get("pending", {})
	if pending.is_empty() or hour * 60 <= int(pending.minute):
		return
	GameState.incident.erase("pending")
	_ask(String(pending.kind), int(pending.minute))


## Debug (sprint_probe `incident=<kind>@<tick>`): that tick's die is a hit.
static func force_on(kind: String, day: int) -> void:
	GameState.incident["forced"] = {"kind": kind, "day": day}


## The emergency that began at `minute` of tonight, as the card will read it: when it began, when it opens and the
## people who tried the app since. Kept as `open`.
static func stage(kind: String, minute: int) -> void:
	var start: int = GameState.day * MailClock.DAY_MINUTES + minute
	var opened: int = MailClock.now()
	var open := {"kind": kind, "start": start, "opened": opened}
	if ProductState.market_type() == "b2c":
		open["tried"] = roundi(SalesSystem.b2c_audience() * float(_cfg("outage.try_share_hour"))
			* float(opened - start) / 60.0)
	GameState.incident["open"] = open


static func _ask(kind: String, minute: int) -> void:
	var before: Dictionary = GameState.incident.get("open", {})
	stage(kind, minute)
	var given: Dictionary = {}
	var sender: String = _builder()
	if sender != "":
		given["employee"] = sender
	if ProductState.market_type() == "b2b":
		var book: Array = night_accounts()
		given["customer"] = (book if not book.is_empty() else accounts())[0].id
	var card: String = CARDS[kind][ProductState.market_type()]
	if not EventGate.request(card, given):
		GameState.incident["open"] = before
		return
	GameState.incident["last_day"] = GameState.day
	SprintSystem.record_interrupt("incident")
	if EventGate.instances_of(card) > 0:
		_hold()


## The first developer on the Build job: the emergency's mail comes from them.
static func _builder() -> String:
	for member in SprintSystem.team():
		var person: Character = CharacterRegistry.get_character(member.id)
		if not member.founder and member.fits.has("dev") and HRConstants.JOB_BUILD in person.assigned_job_ids:
			return member.id
	return ""


# --- The hold --------------------------------------------------------------

static func _hold() -> void:
	TimeManager.hold_clock(HOLD)
	if not EventBus.event_resolved.is_connected(_on_resolved):
		EventBus.event_resolved.connect(_on_resolved)
		EventBus.clock_batch_ended.connect(_let_go)


static func _on_resolved(_event_id: String, _choice: int) -> void:
	_let_go()


## The hold goes with the card: answered, or dropped before it was shown (the batch that stopped for it has ended and
## the engine has pumped).
static func _let_go() -> void:
	for cards in CARDS.values():
		for card in cards.values():
			if EventGate.instances_of(card) > 0:
				return
	TimeManager.release_clock(HOLD)


# --- Who it hurts ----------------------------------------------------------

## The active B2B accounts, the largest first (seats, then MRR, then id).
static func accounts() -> Array:
	var book: Array = CustomerRegistry.get_by_market("b2b")
	book.sort_custom(SprintCatalog.larger_account)
	return book


## The accounts whose people work through the night.
static func night_accounts() -> Array:
	var sectors: Array = _cfg("outage.night_sectors")
	return accounts().filter(func(c: Customer) -> bool: return c.industry in sectors)


## What the card says of the night: when it began ("02:10"), how many people tried the app since, and whether the
## service is back (nothing out, or the answered fix is past).
static func start_clock() -> String:
	var open: Dictionary = GameState.incident.get("open", {})
	return MailClock.clock_text(int(open.start)) if open.has("start") else ""


static func tried() -> int:
	return int(GameState.incident.get("open", {}).get("tried", 0))


static func service_up() -> bool:
	var open: Dictionary = GameState.incident.get("open", {})
	return not open.has("start") or (open.has("back") and MailClock.now() >= int(open.back))


# --- The answer ------------------------------------------------------------

## What an act costs and does, worked out the way `resolve` applies it, in figures only: when the service is back
## (`back`, an absolute minute), and by market what the accounts keep (`trust` rows, `credit`) or what the audience
## is spared and loses (`audience`, `free`). A chip, a history row and the application read this one dict.
## The acts: `night` (the team fixes it now), `founder` (the founder does), `morning` (the team at the workday's
## start), `morning_credit` (and every account is credited) and `morning_free_month` (and the audience that tried the
## app gets a month free).
static func plan(act: String) -> Dictionary:
	var open: Dictionary = GameState.incident.get("open", {})
	var now: int = MailClock.now()
	var start: int = int(open.get("start", now))
	var back: int = _back(act, int(open.get("opened", now)), start)
	var hours: float = maxf(0.0, float(back - start) / 60.0)
	var out := {"act": act, "back": back, "market": ProductState.market_type()}
	if out.market == "b2b":
		if act in MORNING_ACTS:
			out["trust"] = _trust_rows(start, back, act == "morning_credit")
		if act == "morning_credit":
			out["credit"] = _credit(hours)
	else:
		out["audience"] = -_audience_loss(hours, act == "morning_free_month")
		if act == "morning_free_month":
			out["free"] = _free_month(int(open.get("tried", 0)))
	return out


## Applies an act: the trust, the credit or the free month, the audience, and the time the service is back.
static func resolve(act: String) -> Dictionary:
	var done: Dictionary = plan(act)
	for row in done.get("trust", []):
		for id in row.ids:
			var account: Customer = CustomerRegistry.get_customer(id)
			CustomerRegistry.set_trust_offset(id, B2BConstants.clamp_trust(account.trust_offset + float(row.delta)))
	if done.has("credit"):
		FinanceSystem.apply_one_time_cost(int(done.credit.amount), "outage_credit")
	if done.has("free"):
		FinanceSystem.apply_one_time_cost(int(done.free.amount), "refunds")
	if int(done.get("audience", 0)) != 0:
		SalesSystem.add_b2c_audience(int(done.audience))
	GameState.incident["open"]["back"] = done.back
	return done.merged({"verb": "incident"})


## When the service is back, an absolute minute: from the opening for a fix now, from the workday's start for the
## morning's.
static func _back(act: String, opened: int, start: int) -> int:
	match act:
		"night":
			return opened + _fix_minutes(false)
		"founder":
			return opened + _fix_minutes(true)
	return start / MailClock.DAY_MINUTES * MailClock.DAY_MINUTES + int(WorkHoursSystem.company_window().start) * 60 \
		+ _fix_minutes(false)


## The base hours over the best engineer's pace, slower when the founder does it alone (or is alone), to a clock step.
static func _fix_minutes(by_founder: bool) -> int:
	var crew: Array = SprintSystem.team().filter(func(t: Dictionary) -> bool: return not t.founder)
	var alone: bool = by_founder or crew.is_empty()
	var stars: float = 0.0
	if alone:
		stars = _stars(CharacterRegistry.get_founder().id)
	else:
		for member in crew:
			stars = maxf(stars, _stars(member.id))
	var hours: float = float(_cfg("outage.fix_hours")) \
		/ (float(_cfg("outage.crew_base")) + float(_cfg("outage.crew_per_star")) * stars)
	if alone:
		hours *= float(_cfg("outage.founder_slower"))
	var step: int = int(_cfg("outage.fix_step"))
	return roundi(hours * 60.0 / step) * step


static func _stars(person_id: String) -> float:
	var skills: Dictionary = CharacterRegistry.get_character(person_id).role_stats
	return HRConstants.stars_for(int(skills.get(HRConstants.AREA_ENGINEERING, 0)))


## The accounts' share of a morning fix: each pays the hours it could not work, the night shift from the moment the
## service went down, the rest from their day's start; a credit forgives most of it. One row per group that pays.
static func _trust_rows(start: int, back: int, credited: bool) -> Array:
	var keep: float = 1.0 - float(_cfg("outage.credit_forgives")) if credited else 1.0
	var morning: int = start / MailClock.DAY_MINUTES * MailClock.DAY_MINUTES + int(_cfg("outage.day_start"))
	var night: Array = night_accounts()
	var groups: Array = [["all", accounts(), morning]]
	if not night.is_empty():
		groups = [["night", night, start], ["other", accounts().filter(func(c: Customer) -> bool: return not night.has(c)),
			morning]]
	var rows: Array = []
	for group in groups:
		var book: Array = group[1]
		var hours: float = maxf(0.0, float(back - int(group[2])) / 60.0)
		var delta: int = -roundi(minf(float(_cfg("outage.trust_cap")), float(_cfg("outage.trust_per_hour")) * hours) * keep)
		if delta == 0 or book.is_empty():
			continue
		var top: Customer = book[0]
		rows.append({"group": group[0], "n": book.size(), "delta": delta,
			"ids": book.map(func(c: Customer) -> String: return c.id), "name": top.display_name(), "from": top.satisfaction,
			"to": B2BSalesSystem.satisfaction_next_tick(top, B2BConstants.clamp_trust(top.trust_offset + delta))})
	return rows


## The credit of the book: the tier of the hours the service was down, over the accounts' monthly fees as they stand.
static func _credit(hours: float) -> Dictionary:
	var pct: int = 0
	for tier in _cfg("outage.credit"):
		if hours >= float(tier[0]):
			pct = int(tier[1])
	var book: Array = accounts()
	var fees: int = 0
	for account in book:
		fees += account.mrr
	return {"n": book.size(), "pct": pct, "amount": roundi(float(fees) * pct / 100.0)}


## The audience that leaves, whole people: a share of it by the hours down, capped; a free month leaves part of it.
static func _audience_loss(hours: float, free_month: bool) -> int:
	var share: float = minf(float(_cfg("outage.loss_cap")), float(_cfg("outage.loss_per_hour")) * hours)
	return roundi(SalesSystem.b2c_audience() * share * (float(_cfg("outage.free_month_loss")) if free_month else 1.0))


## A free month for the people who tried the app: only those among them who pay cost anything.
static func _free_month(people: int) -> Dictionary:
	var paying: int = roundi(float(people) * SalesSystem.b2c_paying_users() / maxf(SalesSystem.b2c_audience(), 1.0))
	var price: int = int(GameState.get_flag("b2c_price", SalesSystem.B2C_PRICE_DEFAULT))
	return {"n": people, "paying": paying, "amount": paying * price}
