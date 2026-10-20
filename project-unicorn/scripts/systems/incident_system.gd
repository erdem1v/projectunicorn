class_name IncidentSystem
extends RefCounted

# THE EMERGENCIES. Rare, sudden and real: the service goes down while the office sleeps, a month cannot close, payments
# fail, a release breaks a line, a post about a bug goes round. The system asks for the card by name (EventGate.request);
# the card owns the words and the option structure, this file the numbers a cost is made of, so a chip, the history row
# and what lands read one figure (plan).
#
# THE ROLL. p = min(BASE x (1 + min(open bugs, 12) / 8), P_MAX) x tier: the tier weighs the capped odds, so each
# server tier keeps its share at any bug count. How full the servers are (`load_mult`) weighs only the outage, after the
# cap: its weight in the kind draw is multiplied and the week's odds grow by that much of it, so a full server makes
# outages likelier and no other emergency, and the cap cannot swallow it. Two emergencies are at least MIN_GAP ticks
# apart. The die is rolled once, in the 00:00 daily slice, and only decides: whether this week has one, which kind (by
# weight, among the kinds the world allows) and the minute its mail is stamped (`pending`; an outage also keeps the
# server load it was rolled at, which its card reads). A release that shipped a faulty card on a
# critical line brings its own emergency (regression) the morning after, with no die. A sprint that brought a decision
# paper has room for a service going down only (SERVICE_DOWN): any other kind is kept whole (`shifted`) and comes the
# first week of a sprint without one. The card is asked for in the hourly slice of the first full hour after the stamp, with the clock held (a
# night batch stops there, the card opens at once, and the answer lets the night carry on from where it stopped). A card
# the gate refuses is an emergency that never began: no stamp, no hold.
#
# THE KINDS and when their mail is stamped:
#   outage      the service went down between 00:30 and 04:30; the mail carries the minute the card opens.
#   month_close B2B, the last week of a calendar month, a line of the books with bugs; 22:10 to 22:55, card at 23:00.
#   checkout    B2C with a paid plan: payments broke the night before; 10 to 50 minutes into the workday.
#   regression  a release's faulty card broke a critical line; 10 to 50 minutes into the workday after it shipped.
#   storm       B2C, an audience and a shared line with many bugs; a post goes round between 11:00 and 16:00.
#
# Every number is in data/product/sprint.json `incident` and is [WORKING], except the server tiers'
# weights (`tier`), which the owner set.
#
# State is GameState.incident: {last_day, pending: {kind, minute, line, began, load}, shifted (a pending kept for the next
# sprint), open: {kind, start, opened, line, load, tried, version, act, back}, drains: [{line, pct}], forced}. `open` stays after the answer: the card's words and the history rows
# read it.

## The card of each emergency, by kind and market.
const CARDS := {
	"outage": {"b2b": "product.incident_outage_b2b", "b2c": "product.incident_outage_b2c"},
	"month_close": {"b2b": "customer.incident_month_close"},
	"checkout": {"b2c": "product.incident_checkout"},
	"regression": {"b2b": "product.incident_regression", "b2c": "product.incident_regression"},
	"storm": {"b2c": "product.incident_review_storm"},
}
## The kinds where the service goes down (the outage, the payments): the only emergency a sprint with a decision paper
## still takes.
const SERVICE_DOWN := ["outage", "checkout"]
## The reason the clock is held while an emergency waits for its answer (TimeManager.HOLD_LABELS).
const HOLD := "incident"
## Debug switch: false skips the random die and the release's own emergency, for a harness that does not answer cards
## (an emergency holds the clock until its card is answered); an emergency forced with `force_on` still comes.
static var rolls := true

## The answers that leave an outage's fix to the workday's start: the accounts pay for the hours they could not work.
const MORNING_ACTS := ["morning", "morning_credit", "morning_free_month"]
## The answers that give the people it hurt a free month.
const FREE_MONTH_ACTS := ["morning_free_month", "defer_free_month"]
## The answers that fix it at once: an account that lived through it thanks for it (SprintBridges.thank).
const QUICK_ACTS := ["now", "founder", "evening"]


static func _cfg(path: String) -> Variant:
	return SprintCatalog.cfg("incident." + path)


# --- The roll --------------------------------------------------------------

## A server tier's weight on the odds (the one in use by default): the cheaper the machines, the likelier the night.
static func tier_mult(provider_id: String = InfraSystem.provider()) -> float:
	return float((_cfg("tier") as Dictionary).get(provider_id, 1.0))


## How full the servers are (`state`: the capacity state in force by default), as the odds of an outage weigh it: 1 up to
## the amber line, then the amber figure, then the over figure; a live product that bought no capacity reads over
## (sprint.json `incident.load`).
static func load_mult(state: String = InfraSystem.capacity_state()) -> float:
	if not ProductState.is_live() or state == InfraSystem.STATE_NORMAL:
		return 1.0
	return float(_cfg("load.amber" if state == InfraSystem.STATE_AMBER else "load.over"))


## The week's chance of an emergency tonight: the bugs' odds, capped, under the tier, and then the servers' load on the
## outage's share of it.
static func hazard() -> float:
	var bugs: int = mini(ProductState.costed(ProductState.open_bugs()), int(_cfg("bug_cap")))
	var odds: float = minf(float(_cfg("base")) * (1.0 + float(bugs) / float(_cfg("bug_div"))), float(_cfg("p_max")))
	return odds * tier_mult() * _total(_weights()) / _total(_weights(false))


## The weight of each kind this world allows, the outage's with the servers' load unless `loaded` is false.
static func _weights(loaded := true) -> Dictionary:
	var out: Dictionary = {}
	for kind in _cfg("weights"):
		if _allows(kind):
			out[kind] = float(_cfg("weights")[kind]) * (load_mult() if loaded and kind == "outage" else 1.0)
	return out


static func _total(weights: Dictionary) -> float:
	return weights.values().reduce(func(sum: float, weight: float) -> float: return sum + weight, 0.0)


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


## 00:00: the die. It only decides whether this week has an emergency, which kind and when its mail is stamped; the
## audience a deferred fix keeps losing pays its week first.
static func daily_tick() -> void:
	var inc: Dictionary = GameState.incident
	_drain_audience()
	var forced: Dictionary = inc.get("forced", {})
	var asked: bool = int(forced.get("day", -1)) == GameState.day
	if asked:
		inc.erase("forced")
	if inc.has("shifted"):
		if not SprintSystem.paper_sprint():
			inc["pending"] = inc["shifted"]
			inc.erase("shifted")
		return
	if not can_happen() or not (asked or rolls):
		return
	var kind: String = String(forced.get("kind", "")) if asked else _kind_this_week()
	if kind == "":
		return
	var pending: Dictionary = _schedule(kind, asked)
	if pending.is_empty():
		return
	inc["shifted" if kind not in SERVICE_DOWN and SprintSystem.paper_sprint() else "pending"] = pending


## Which emergency this week has, "" for none: a release that broke a critical line brings its own; else the die against
## the week's hazard, and then by weight among the kinds the world allows.
static func _kind_this_week() -> String:
	if _regression_line() != "":
		return "regression"
	if EvDice.unit("incident", GameState.day, "roll", "") >= hazard():
		return ""
	var allowed: Dictionary = _weights()
	var pick: float = EvDice.unit("incident", GameState.day, "kind", "") * _total(allowed)
	for kind in allowed:
		pick -= float(allowed[kind])
		if pick < 0.0:
			return kind
	return allowed.keys().back()


## May this kind happen this week in this world (its card's own conditions are asked again when it is requested).
static func _allows(kind: String) -> bool:
	var market: String = ProductState.market_type()
	match kind:
		"month_close":
			return market == "b2b" and _month_ends() and _line_of(kind) != ""
		"checkout":
			return market == "b2c" and SprintCatalog.tier(SprintCatalog.PAID_PLAN) > 0
		"storm":
			return market == "b2c" and SalesSystem.b2c_audience() >= float(_cfg("storm.min_audience")) \
				and _line_of(kind) != ""
	return true


## The tick is the last of its calendar month: the next one's month differs (the month closes then).
static func _month_ends() -> bool:
	return int(GameState.get_date_dict().month) != int(GameState.get_date_dict(GameState.day + 1).month)


## The kind's night or day, as `pending`: {kind, minute (when its mail is stamped, a minute of the day), line, began
## (when it started, if that is not the stamp)}; {} when the kind has nothing to hit. `waive` is a forced emergency:
## the thresholds a line needs are waived, a line with a bug will do.
static func _schedule(kind: String, waive: bool) -> Dictionary:
	if not CARDS[kind].has(ProductState.market_type()):
		return {}
	var line: String = _line_of(kind, waive)
	if line == "" and kind != "outage":
		return {}
	var pending: Dictionary = {"kind": kind}
	if line != "":
		pending["line"] = line
	var window: Dictionary = WorkHoursSystem.company_window()
	match kind:
		"outage":
			var span: Array = _cfg("outage.start")
			var step: int = int(_cfg("outage.start_step"))
			pending["minute"] = int(span[0]) + step * floori(EvDice.unit("incident", GameState.day, "start", "")
				* ((int(span[1]) - int(span[0])) / step + 1))
			pending["load"] = InfraSystem.load_percent()
		"month_close":
			pending["minute"] = _draw(_cfg("month_close.stamp"), "start")
		"checkout":
			pending["began"] = _draw(_cfg("checkout.began"), "began")
			pending["minute"] = int(window.start) * 60 + _draw(_cfg("checkout.after_start"), "start")
		"regression":
			pending["minute"] = int(window.start) * 60 + _draw(_cfg("regression.after_start"), "start")
		"storm":
			var span: Array = _cfg("storm.stamp")
			pending["minute"] = _draw([maxi(int(span[0]), int(window.start) * 60),
				maxi(mini(int(span[1]), int(window["end"]) * 60 - 60), int(window.start) * 60)], "start")
	return pending


## A minute drawn from [low, high] under `salt`.
static func _draw(span: Array, salt: String) -> int:
	return int(span[0]) + floori(EvDice.unit("incident", GameState.day, salt, "") * float(int(span[1]) - int(span[0]) + 1))


## Every hour: the card of today's emergency is asked for at the first full hour after its mail is stamped.
static func hourly_tick(hour: int) -> void:
	var pending: Dictionary = GameState.incident.get("pending", {})
	if pending.is_empty() or hour * 60 <= int(pending.minute):
		return
	GameState.incident.erase("pending")
	_ask(pending)


## Debug (sprint_probe `incident=<kind>@<tick>`): that tick's die is a hit, of that kind.
static func force_on(kind: String, day: int) -> void:
	GameState.incident["forced"] = {"kind": kind, "day": day}


## The emergency that began at `began` (a minute of today) as the card will read it: when it began, when it opens, the
## line it hit, the server load it was rolled at (an outage's) and the people who tried the app since. Kept as `open`.
static func stage(kind: String, began: int, line := "", load_pct := 0) -> void:
	var start: int = GameState.day * MailClock.DAY_MINUTES + began
	var opened: int = MailClock.now()
	var hours: float = float(opened - start) / 60.0
	var open := {"kind": kind, "start": start, "opened": opened}
	if line != "":
		open["line"] = line
	if load_pct > 0:
		open["load"] = load_pct
	match kind:
		"outage":
			if ProductState.market_type() == "b2c":
				open["tried"] = roundi(SalesSystem.b2c_audience() * float(_cfg("outage.try_share_hour")) * hours)
		"checkout":
			open["tried"] = roundi(float(SalesSystem.b2c_paying_users()) * float(_cfg("checkout.try_share_hour")) * hours)
		"regression":
			open["version"] = SprintSystem.version_label(int((GameState.product.releases.back() as Dictionary).number))
	GameState.incident["open"] = open


static func _ask(pending: Dictionary) -> void:
	var kind: String = pending.kind
	var line: String = String(pending.get("line", ""))
	var before: Dictionary = GameState.incident.get("open", {})
	stage(kind, int(pending.get("began", pending.minute)), line, int(pending.get("load", 0)))
	var market: String = ProductState.market_type()
	var given: Dictionary = {}
	var writer: String = _writer(kind)
	if writer != "":
		given["employee"] = writer
	if market == "b2b":
		given["customer"] = _largest_night_account() if kind == "outage" else String(SprintCatalog.line_impact(line).top_id)
	var stamp: int = -1 if kind == "outage" else GameState.day * MailClock.DAY_MINUTES + int(pending.minute)
	var card: String = CARDS[kind][market]
	if (market == "b2b" and given.customer == "") or not EventGate.request(card, given, false, stamp):
		GameState.incident["open"] = before
		return
	GameState.incident["last_day"] = GameState.day
	SprintSystem.record_interrupt("incident")
	if EventGate.instances_of(card) > 0:
		_hold()


## Who writes the emergency's mail, "" when the card names no one (an account writes it, or the server's own alert):
## the first developer on the Build job; for a broken release the tester first, for a post going round the customer
## rep. The card falls back to the founder's own note when no one is found.
static func _writer(kind: String) -> String:
	match kind:
		"month_close":
			return ""
		"regression":
			var tester: String = _first_with_role(HRConstants.ROLE_TESTER)
			return tester if tester != "" else _builder()
		"storm":
			return _first_with_role(HRConstants.ROLE_CUSTOMER_REP)
	return _builder()


static func _first_with_role(role: String) -> String:
	for person in CharacterRegistry.get_active_employees():
		if person.role == role:
			return person.id
	return ""


## The first developer on the Build job.
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


# --- What it hit -----------------------------------------------------------

## The line an emergency of this kind hit, "" when none: the books' lines with enough bugs for a month that cannot
## close, a shared line for a post going round, a critical line the release broke, the paid plan for failing
## payments (it has no line of its own). `waive` drops the bug thresholds.
static func _line_of(kind: String, waive := false) -> String:
	match kind:
		"checkout":
			return SprintCatalog.PAID_PLAN
		"month_close":
			return _worst(_cfg("month_close.lines"), int(_cfg("month_close.line_bugs")), waive)
		"storm":
			return _worst(_cfg("storm.lines"), int(_cfg("storm.line_bugs")), waive)
		"regression":
			return _regression_line(waive)
	return ""


## The line of these (by its id before the "@") with the most open bugs, at least `floor_bugs` (one when waived); a
## B2B line must have an account that uses it. Ties go to the line more people use, then to the smaller id.
static func _worst(bases: Array, floor_bugs: int, waive: bool) -> String:
	var bugs: Dictionary = ProductState.open_bugs_by_line()
	var ids: Array = bugs.keys()
	ids.sort()
	var worst: String = ""
	for line in ids:
		if line.get_slice("@", 0) not in bases or ProductState.costed(int(bugs[line])) < (1 if waive else floor_bugs):
			continue
		if ProductState.market_type() == "b2b" and SprintCatalog.line_accounts(line).is_empty():
			continue
		if worst == "" or int(bugs[line]) > int(bugs[worst]) or (int(bugs[line]) == int(bugs[worst])
				and SprintCatalog.line_users(line) > SprintCatalog.line_users(worst)):
			worst = line
	return worst


## The critical line the release that closed today shipped a faulty card on (the one more people use), "" when there is
## none. `waive`: with none, the critical line with the most bugs.
static func _regression_line(waive := false) -> String:
	var critical: Array = _cfg("regression." + ProductState.market_type())
	var releases: Array = GameState.product.get("releases", [])
	var line: String = ""
	if not releases.is_empty() and int(releases.back().day) == GameState.day:
		for hit in releases.back().faulty:
			if String(hit).get_slice("@", 0) in critical and (line == "" or SprintCatalog.line_users(hit)
					> SprintCatalog.line_users(line)):
				line = hit
	return _worst(critical, 1, true) if line == "" and waive else line


## The line the open emergency hit, "" for one that hit none (an outage).
static func hit_line() -> String:
	return String(GameState.incident.get("open", {}).get("line", ""))


## The version the open regression broke, "v1.4".
static func version() -> String:
	return String(GameState.incident.get("open", {}).get("version", ""))


## The server load, in percent, the open outage was rolled at; 0 for another kind of emergency.
static func outage_load() -> int:
	return int(GameState.incident.get("open", {}).get("load", 0))


## Which of a card's bodies the open emergency reads (the card's `by_seam` variants): a month that cannot close and a
## post going round have one for each of their lines; a broken release has two for each critical B2B line (many
## accounts use it, one does) and then one for each B2C line.
static func variant() -> int:
	var base: String = hit_line().get_slice("@", 0)
	match String(GameState.incident.get("open", {}).get("kind", "")):
		"month_close":
			return (_cfg("month_close.lines") as Array).find(base)
		"storm":
			return (_cfg("storm.lines") as Array).find(base)
		"regression":
			var b2b: Array = _cfg("regression.b2b")
			if ProductState.market_type() == "b2b":
				return b2b.find(base) * 2 + int(SprintCatalog.line_accounts(hit_line()).size() == 1)
			return b2b.size() * 2 + (_cfg("regression.b2c") as Array).find(base)
	return 0


## The active B2B accounts, the largest first (seats, then MRR, then id).
static func accounts() -> Array:
	var book: Array = CustomerRegistry.get_by_market("b2b")
	book.sort_custom(SprintCatalog.larger_account)
	return book


## The accounts whose people work through the night.
static func night_accounts() -> Array:
	var sectors: Array = _cfg("outage.night_sectors")
	return accounts().filter(func(c: Customer) -> bool: return c.industry in sectors)


static func _largest_night_account() -> String:
	var book: Array = night_accounts()
	return (book if not book.is_empty() else accounts())[0].id


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


## The account that lived through the open emergency and can thank for a fix that came at once, and whether the fix
## landed before the accounts' morning (`night`): {} when the answer was not a quick one or nobody was there to see
## the service down (an outage the night shift never felt, mended before the accounts' day began).
static func quick_fix() -> Dictionary:
	var open: Dictionary = GameState.incident.get("open", {})
	if ProductState.market_type() != "b2b" or String(open.get("act", "")) not in QUICK_ACTS:
		return {}
	var night: bool = int(open.back) % MailClock.DAY_MINUTES < int(_cfg("outage.day_start"))
	var felt: Array = night_accounts() if open.kind == "outage" else SprintCatalog.line_accounts(String(open.line))
	if open.kind == "outage" and felt.is_empty() and not night:
		felt = accounts()
	felt.sort_custom(SprintCatalog.larger_account)
	return {} if felt.is_empty() else {"customer": felt[0].id, "night": night}


# --- The answer ------------------------------------------------------------

## What an act costs and does, worked out the way `resolve` applies it, in figures only: when the fix lands (`back`, an
## absolute minute, and `tomorrow` if it waits for another day's workday: a fix past midnight is still tonight's), and
## by market what the accounts keep (`trust` rows, `per_sprint`, `credit`) or what the audience is spared and loses
## (`audience`, `drain`, `free`). A chip, a history row and the application read this one dict.
## The acts: `now` (the team fixes it at once), `founder` (the founder does, slower), `evening` (the team, after the
## workday), `morning` (the team at the workday's start), `morning_credit` and `morning_free_month` (an outage's
## morning, with every account credited or the audience that tried the app given a month), `defer` (the fix waits for
## the next sprint and the hurt goes on) and `defer_free_month` (the same, the people it hurt given a month).
static func plan(act: String) -> Dictionary:
	var open: Dictionary = GameState.incident.get("open", {})
	var now: int = MailClock.now()
	var kind: String = String(open.get("kind", "outage"))
	var opened: int = int(open.get("opened", now))
	var start: int = int(open.get("start", now))
	var back: int = _back(act, kind, opened)
	var out := {"act": act, "kind": kind, "market": ProductState.market_type()}
	if back > 0:
		out["back"] = back
		out["tomorrow"] = back / MailClock.DAY_MINUTES > opened / MailClock.DAY_MINUTES \
			and back % MailClock.DAY_MINUTES >= int(WorkHoursSystem.company_window().start) * 60
	var hours: float = maxf(0.0, float(back - start) / 60.0)
	if out.market == "b2b":
		if kind == "outage" and act in MORNING_ACTS:
			out["trust"] = _trust_rows(start, back, act == "morning_credit")
		if act == "morning_credit":
			out["credit"] = _credit(hours)
		if act == "defer":
			var book: Array = _hit_accounts()
			if not book.is_empty():
				out["trust"] = [_trust_row("all", book, int(_cfg("defer.trust")))]
				out["per_sprint"] = int(_cfg("defer.per_sprint"))
	else:
		match kind:
			"outage":
				out["audience"] = -_audience_loss(hours, act == "morning_free_month")
			"checkout":
				out["audience"] = -_give_up(hours)
		if act in FREE_MONTH_ACTS:
			out["free"] = _free_month(_affected())
		if act.begins_with("defer"):
			out["drain"] = float(_cfg("defer.free_month_audience" if act == "defer_free_month" else "defer.audience"))
	return out


## Applies an act: the trust, the credit or the free month, the audience, the standing costs and the time the fix lands.
static func resolve(act: String) -> Dictionary:
	var plan_done: Dictionary = plan(act)
	var hit: Array = []
	for row in plan_done.get("trust", []):
		for id in row.ids:
			var account: Customer = CustomerRegistry.get_customer(id)
			CustomerRegistry.set_trust_offset(id, B2BConstants.clamp_trust(account.trust_offset + float(row.delta)))
			hit.append(id)
	if plan_done.has("per_sprint"):
		B2BSalesSystem.add_trust_drain(hit, int(plan_done.per_sprint), {"line_cleared": hit_line()})
	if plan_done.has("credit"):
		FinanceSystem.apply_one_time_cost(int(plan_done.credit.amount), "outage_credit")
	if plan_done.has("free"):
		FinanceSystem.apply_one_time_cost(int(plan_done.free.amount), "refunds")
	if int(plan_done.get("audience", 0)) != 0:
		SalesSystem.add_b2c_audience(int(plan_done.audience))
	if plan_done.has("drain"):
		GameState.incident.get_or_add("drains", []).append({"line": hit_line(), "pct": plan_done.drain})
	GameState.incident["open"]["act"] = act
	if plan_done.has("back"):
		GameState.incident["open"]["back"] = plan_done.back
	return plan_done.merged({"verb": "incident"})


## A week of the audience a deferred fix keeps losing: each standing loss takes its share until its line has no bug
## left (the sprint that fixes the line is not charged).
static func _drain_audience() -> void:
	var standing: Array = GameState.incident.get("drains", []).filter(
		func(d: Dictionary) -> bool: return ProductState.line_bugs(String(d.line)) > 0)
	for d in standing:
		SalesSystem.add_b2c_audience(-roundi(SalesSystem.b2c_audience() * float(d.pct)))
	if GameState.incident.has("drains"):
		GameState.incident["drains"] = standing


## When the fix lands, an absolute minute, 0 for a fix that waits for the next sprint: from the opening for a fix now,
## from the end of the workday for the evening's, from the next workday's start for the morning's.
static func _back(act: String, kind: String, opened: int) -> int:
	if act.begins_with("defer"):
		return 0
	var window: Dictionary = WorkHoursSystem.company_window()
	var day_start: int = opened / MailClock.DAY_MINUTES * MailClock.DAY_MINUTES
	match act:
		"now":
			return opened + _fix_minutes(false, kind)
		"founder":
			return opened + _fix_minutes(true, kind)
		"evening":
			return maxi(opened, day_start + int(window["end"]) * 60) + _fix_minutes(false, kind)
	var morning: int = day_start + int(window.start) * 60
	if morning <= opened:
		morning += MailClock.DAY_MINUTES
	return morning + _fix_minutes(false, kind)


## The base hours over the best engineer's pace, slower when the founder does it alone (or is alone), to a clock step.
static func _fix_minutes(by_founder: bool, kind: String) -> int:
	var crew: Array = SprintSystem.team().filter(func(t: Dictionary) -> bool: return not t.founder)
	var alone: bool = by_founder or crew.is_empty()
	var stars: float = 0.0
	if alone:
		stars = _stars(CharacterRegistry.get_founder().id)
	else:
		for member in crew:
			stars = maxf(stars, _stars(member.id))
	var hours: float = float(_cfg("fix.hours")[kind]) / (float(_cfg("fix.crew_base")) + float(_cfg("fix.crew_per_star")) * stars)
	if alone:
		hours *= float(_cfg("fix.founder_slower"))
	var step: int = int(_cfg("fix.step"))
	return roundi(hours * 60.0 / step) * step


static func _stars(person_id: String) -> float:
	var skills: Dictionary = CharacterRegistry.get_character(person_id).role_stats
	return HRConstants.stars_for(int(skills.get(HRConstants.AREA_ENGINEERING, 0)))


## The accounts the emergency hit: the largest user of the books' line for a month that cannot close, every user of
## the line for a broken release; the largest first.
static func _hit_accounts() -> Array:
	var users: Array = SprintCatalog.line_accounts(hit_line())
	users.sort_custom(SprintCatalog.larger_account)
	if String(GameState.incident.get("open", {}).get("kind", "")) == "month_close":
		return users.slice(0, 1)
	return users


## One group of accounts that took `delta` on their ledgers: its largest account's name and satisfaction now and a
## tick on.
static func _trust_row(group: String, book: Array, delta: int) -> Dictionary:
	var top: Customer = book[0]
	return {"group": group, "n": book.size(), "delta": delta, "ids": book.map(func(c: Customer) -> String: return c.id),
		"name": top.display_name(), "from": top.satisfaction,
		"to": B2BSalesSystem.satisfaction_next_tick(top, B2BConstants.clamp_trust(top.trust_offset + delta))}


## The accounts' share of an outage's morning fix: each pays the hours it could not work, the night shift from the moment
## the service went down, the rest from their day's start; a credit forgives most of it. One row per group that pays.
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
		if delta != 0 and not book.is_empty():
			rows.append(_trust_row(group[0], book, delta))
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


## The audience lost to payments that fail for `hours`: a share of the paying users try to pay each hour, a share of
## those give up for good, and the people who pay are a share of the audience.
static func _give_up(hours: float) -> int:
	var paying: float = maxf(float(SalesSystem.b2c_paying_users()), 1.0)
	var lost: float = paying * float(_cfg("checkout.try_share_hour")) * hours * float(_cfg("checkout.give_up"))
	return roundi(lost * SalesSystem.b2c_audience() / paying)


## The people the emergency hurt: those who tried the app or the checkout, or the users of the line it hit.
static func _affected() -> int:
	if String(GameState.incident.get("open", {}).get("kind", "")) in ["outage", "checkout"]:
		return tried()
	return SprintCatalog.line_users(hit_line())


## A free month for these people: only those among them who pay cost anything.
static func _free_month(people: int) -> Dictionary:
	var paying: int = roundi(float(people) * SalesSystem.b2c_paying_users() / maxf(SalesSystem.b2c_audience(), 1.0))
	var price: int = int(GameState.get_flag("b2c_price", SalesSystem.B2C_PRICE_DEFAULT))
	return {"n": people, "paying": paying, "amount": paying * price}
