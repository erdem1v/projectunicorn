extends RefCounted

# Pazarlama's ledger: the channel rows the company runs, each row's weekly budget and runner, how loaded each runner is,
# and the Finance `marketing` line. State is GameState.marketing (saved with it); the catalogue and its [WORKING] numbers
# are data/marketing/channels.json.
#
# No class_name: readers preload it (a new class_name breaks other sessions' headless runs until they re-import).

const DATA_PATH := "res://data/marketing/channels.json"
static var _data: Dictionary = {}


## channels.json by dot path: cfg("kinds.search_ads.load_pct").
static func cfg(path: String) -> Variant:
	if _data.is_empty():
		_data = JSON.parse_string(FileAccess.get_file_as_string(DATA_PATH))
	var v: Variant = _data
	for key in path.split("."):
		v = v[key]
	return v


## The channel kinds the company's market runs, in catalogue order.
static func kinds() -> Array:
	var market: String = "b2b" if SalesSystem.is_b2b_market() else "b2c"
	return (cfg("kinds") as Dictionary).keys().filter(func(k: String) -> bool: return market in cfg("kinds.%s.markets" % k))


static func rows() -> Array:
	return GameState.marketing.get("rows", [])


static func row(id: int) -> Dictionary:
	for r: Dictionary in rows():
		if int(r.id) == id:
			return r
	return {}


## A kind runs once per target (a category, a sector, or "" for none); a row starts at budget 0. Returns {} when that row
## already runs, the runner cannot run it, or the runner is the founder whose Marketing share is already full.
static func add_row(kind: String, target: String, runner_id: String) -> Dictionary:
	if not kinds().has(kind) or not can_run(runner_id) \
			or rows().any(func(r: Dictionary) -> bool: return r.kind == kind and r.target == target) \
			or (CharacterRegistry.get_character(runner_id).category == "founder" and load_pct(runner_id) >= 100):
		return {}
	var m: Dictionary = GameState.marketing
	var r := {"id": int(m.get("next_id", 1)), "kind": kind, "target": target, "budget": 0, "runner": runner_id}
	m["next_id"] = int(r.id) + 1
	if not m.has("rows"):
		m["rows"] = []
	m.rows.append(r)
	return r


static func remove_row(id: int) -> void:
	rows().erase(row(id))


## Budgetless kinds (Referans, E-posta) keep 0.
static func set_budget(id: int, amount: int) -> void:
	var r: Dictionary = row(id)
	if bool(cfg("kinds.%s.budgeted" % r.kind)):
		r.budget = clampi(amount, 0, int((cfg("budget_ladder") as Array).back()))


## The − / + buttons walk budget_ladder; a budget between two rungs moves to the next one.
static func step_budget(id: int, dir: int) -> void:
	var ladder: Array = cfg("budget_ladder")
	var b: int = int(row(id).budget)
	var i: int = ladder.bsearch(b, false) if dir > 0 else ladder.bsearch(b, true) - 1
	set_budget(id, int(ladder[clampi(i, 0, ladder.size() - 1)]))


## The founder, or anyone on the Marketing job (on leave too: the row stays theirs).
static func can_run(char_id: String) -> bool:
	var c: Character = CharacterRegistry.get_character(char_id)
	return c != null and (c.category == "founder" or c.assigned_job_ids.has(HRConstants.JOB_MARKETING))


## The runner's week, in percent: each row they run costs its kind's load_pct of a full week; the founder has only
## founder_share_pct of a week for Marketing, so one paid row is a full founder load.
static func load_pct(char_id: String) -> int:
	var sum: int = 0
	for r: Dictionary in rows():
		if r.runner == char_id:
			sum += int(cfg("kinds.%s.load_pct" % r.kind))
	var c: Character = CharacterRegistry.get_character(char_id)
	var share: int = int(cfg("founder_share_pct")) if c != null and c.category == "founder" else 100
	return roundi(sum * 100.0 / share)


## Weekly, before Finance: a row whose runner left passes to the founder (past the share, if need be), and the Finance
## line carries this week's spend as the daily rate it holds, zero included, so a closed row stops costing at once. Until
## a row has run the line belongs to the card's marketing push, so the ledger leaves it alone.
static func daily_tick() -> void:
	if not GameState.marketing.has("rows"):
		return
	var founder_id: String = CharacterRegistry.get_founder().id
	var spend: int = 0
	for r: Dictionary in rows():
		if not can_run(String(r.runner)):
			r.runner = founder_id
		spend += int(r.budget)
	FinanceSystem.set_burn_category("marketing", roundi(spend / float(TimeModel.DAYS_PER_TICK)))
