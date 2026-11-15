extends RefCounted

# Pazarlama's ledger: the channel rows the company runs, each row's weekly budget and runner, how loaded each runner is,
# and the Finance `marketing` line. State is GameState.marketing (saved with it); the catalogue and its [WORKING] numbers
# are data/marketing/channels.json.
#
# No class_name: readers preload it (a new class_name breaks other sessions' headless runs until they re-import).

const DATA_PATH := "res://data/marketing/channels.json"
static var _data: Dictionary = {}
## Where an ERP row's leads come from, on the lead (Prospect.source) and on the account it signs (Customer.lead_source).
const SOURCES := {"search_ads": "mkt_ads", "content_seo": "mkt_content", "referral": "mkt_referral", "target_sector": "mkt_target"}
## A source another system names that counts as a marketing source: the trade fair card's leads are the fair's.
const SOURCE_ALIASES := {"trade_fair": "mkt_event"}
## The tag a lead carries on Sales' lead row, by its source; a source with no tag shows none. Organik is Sales' own flow.
const SOURCE_TAGS := {"faucet": "SALES_SOURCE_ORGANIC", "mkt_content": "SALES_SOURCE_CONTENT", "mkt_ads": "SALES_SOURCE_ADS",
	"mkt_referral": "SALES_SOURCE_REFERRAL", "mkt_target": "SALES_SOURCE_TARGET", "mkt_event": "SALES_SOURCE_EVENT"}
const SALT_STAR := 457


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
## already runs, the runner cannot run it, the runner is the founder whose Marketing share is already full, the company
## sells to companies but its market is not open yet, or a Hedef sektör row targets a sector the product does not sell to.
static func add_row(kind: String, target: String, runner_id: String) -> Dictionary:
	if not kinds().has(kind) or not can_run(runner_id) \
			or (SalesSystem.is_b2b_market() and not SalesFaucetSystem.market_open()) \
			or (kind == "target_sector" and not ProductLines.buyer_sectors(String(GameState.get_flag("mvp_sub_product_type_id", ""))).has(target)) \
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


## An ERP row's cost per lead this week: its kind's lead_cost (İçerik ve SEO falls from start_cost over its first
## mature_weeks of spend), times the runner's load past 100%, times a card's boost on the kind (cost_mult).
static func lead_cost(r: Dictionary) -> float:
	var c: Dictionary = cfg("erp.%s" % r.kind)
	var cost: float = float(c.lead_cost)
	if c.has("start_cost"):
		cost = lerpf(float(c.start_cost), cost, minf(float(r.get("weeks", 0)) / float(c.mature_weeks), 1.0))
	return cost * maxf(load_pct(String(r.runner)) / 100.0, 1.0) * cost_mult(String(r.kind))


## Leads a week the ERP row brings: budget ÷ cost per lead × the product's strength; Referans has no budget and brings
## leads_per_account for each account whose satisfaction clears its bar.
static func leads_per_week(r: Dictionary) -> float:
	if r.kind == "referral":
		return float(cfg("erp.referral.leads_per_account")) * CustomerRegistry.get_active().filter(
			func(c: Customer) -> bool: return c.market_type == "b2b" and c.health == "healthy").size()
	return float(r.budget) / lead_cost(r) * SalesFaucetSystem.product_strength()


## The row's star mix: Arama reklamı brings mostly small companies, Hedef sektör one star up from the market's mix. Neither
## opens a band the market keeps shut: a shut band's share falls to the highest open band below it (the product's rule).
## Today no band is ever shut (the quality shifter keeps a floor); the fold acts once PRD_ERP package 6 A3 reads a shut band as 0.
static func _star_mix(kind: String) -> Array:
	var m: Array = SalesFaucetSystem.star_mix_now()
	var mix: Array = m.duplicate()
	match kind:
		"search_ads":
			mix = (cfg("erp.search_ads.mix") as Array).duplicate()
		"target_sector":
			mix = [0.0, float(m[0]), float(m[1]) + float(m[2])]
	for i in [2, 1]:
		if float(m[i]) <= 0.0:
			mix[i - 1] = float(mix[i - 1]) + float(mix[i])
			mix[i] = 0.0
	return mix


static func _roll_star(r: Dictionary, nth: int) -> int:
	var mix: Array = _star_mix(String(r.kind))
	var seed_value: int = GameState.run_seed + GameState.day * 7 + int(r.id) * 31 + nth
	var draw: float = float(SalesConstants.mix_seed(seed_value, SALT_STAR) % 10000) / 10000.0
	var acc: float = 0.0
	for i in 3:
		acc += float(mix[i])
		if draw < acc:
			return SalesConstants.STAR_MIN + i
	return SalesConstants.STAR_MAX


## The ERP rows' leads: each row banks its leads_per_week and spawns the whole ones through the sales faucet (at most
## leads_cap_per_week, never more than one lead banked), sourced to the row; Hedef sektör asks the faucet for its sector. A
## draw the faucet cannot fill (no free name left) stops the row's week and only the leads made leave the bank.
## İçerik ve SEO matures a week per week of spend.
static func _spawn_leads() -> void:
	for r: Dictionary in rows():
		if r.kind == "content_seo" and int(r.budget) > 0:
			r["weeks"] = int(r.get("weeks", 0)) + 1
		var bank: float = float(r.get("bank", 0.0)) + leads_per_week(r)
		var n: int = mini(floori(bank), int(cfg("erp.leads_cap_per_week")))
		var sector: String = String(r.target) if r.kind == "target_sector" else ""
		var made: int = 0
		for i in n:
			if SalesFaucetSystem.spawn(_roll_star(r, i), SOURCES[r.kind], sector) == null:
				break
			made += 1
		r["bank"] = minf(bank - made, 1.0)


## A lead source as Pazarlama counts it: the trade fair card's "trade_fair" is the fair (mkt_event).
static func lead_source_id(source: String) -> String:
	return String(SOURCE_ALIASES.get(source, source))


## The strings.csv key of the tag a lead with this source shows on Sales' lead row, "" for none.
static func source_tag(source: String) -> String:
	return String(SOURCE_TAGS.get(lead_source_id(source), ""))


## The row's MRR contribution: today's MRR of the accounts its source signed in the last mrr_window_weeks (Hedef sektör:
## those in its sector). SQL to close averages 95 days, so a younger window would miss most of a channel's signings.
static func row_mrr(r: Dictionary) -> int:
	var source: String = String(SOURCES.get(r.kind, ""))
	var window: int = TimeModel.ticks(int(cfg("erp.mrr_window_weeks")))
	var sum: int = 0
	for c: Customer in CustomerRegistry.get_active():
		if c.market_type == "b2b" and lead_source_id(c.lead_source) == source and GameState.day - c.acquired_on_day < window \
				and (r.kind != "target_sector" or c.industry == String(r.target)):
			sum += c.mrr
	return sum


## What a card's marketing_boost lands at: {channel, pct, weeks}, the cut and the weeks inside channels.json's boost bounds.
static func boost_terms(kind: String, pct: int, weeks: int) -> Dictionary:
	return {"channel": kind, "pct": clampi(pct, 1, int(cfg("boost.pct_max"))), "weeks": clampi(weeks, 1, int(cfg("boost.weeks_max")))}


## A card's marketing_boost: for `weeks` the kind costs `pct` percent less (an ERP row's lead reads it, lead_cost).
## A second boost on the same kind replaces the first, cut and weeks both. Returns what landed, for the chip and the history.
static func boost(kind: String, pct: int, weeks: int) -> Dictionary:
	var t: Dictionary = boost_terms(kind, pct, weeks)
	GameState.marketing.get_or_add("boosts", {})[kind] = {"pct": t.pct, "until_day": GameState.day + TimeModel.ticks(t.weeks)}
	return t


## The cost multiplier a running boost puts on the kind; 1.0 without one. One boost per kind: the latest replaced any other.
static func cost_mult(kind: String) -> float:
	var b: Dictionary = (GameState.marketing.get("boosts", {}) as Dictionary).get(kind, {})
	if b.is_empty() or int(b.until_day) < GameState.day:
		return 1.0
	return 1.0 - float(b.pct) / 100.0


## Whether the company runs the kind: a row of it with a budget, or a budgetless row (Referans). The seam a boost card's
## option requires (`marketing.runs_channel.<kind>`).
static func runs_channel(kind: String) -> bool:
	return rows().any(func(r: Dictionary) -> bool:
		return r.kind == kind and (int(r.budget) > 0 or not bool(cfg("kinds.%s.budgeted" % kind))))


## The kind's weekly spend across its rows (`marketing.channel_weekly_spend.<kind>`).
static func channel_weekly_spend(kind: String) -> int:
	var sum: int = 0
	for r: Dictionary in rows():
		if r.kind == kind:
			sum += int(r.budget)
	return sum


## Weekly, before Finance: a row whose runner left passes to the founder (past the share, if need be), and the Finance
## line carries this week's spend as the daily rate it holds, zero included, so a closed row stops costing at once; the
## line is the ledger's alone. While the company's market is open the ERP rows bring their leads; a boost is dropped after
## the tick that spent its last week.
static func daily_tick() -> void:
	var spend: int = 0
	for r: Dictionary in rows():
		if not can_run(String(r.runner)):
			r.runner = CharacterRegistry.get_founder().id
		spend += int(r.budget)
	if SalesFaucetSystem.market_open():
		_spawn_leads()
	FinanceSystem.set_burn_category("marketing", roundi(spend / float(TimeModel.DAYS_PER_TICK)))
	var boosts: Dictionary = GameState.marketing.get("boosts", {})
	for kind: String in boosts.keys():
		if int(boosts[kind].until_day) <= GameState.day:
			boosts.erase(kind)
