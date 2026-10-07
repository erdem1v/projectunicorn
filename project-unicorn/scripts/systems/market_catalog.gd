class_name MarketCatalog
extends RefCounted

# The Piyasa catalogue and its pure value function. The catalogue is data (data/market) and is
# never saved; a company's value is a pure function of (run_seed, catalogue, GameState.market_shocks)
# at a week, so charts and year-end tables are recomputed and no price history is stored.
#
#   ln V(c, h) = ln anchor_c(year(h))                      year-end anchors, log-interp + smoothstep
#              + beta_c · sigma_market · N_market(h)       one shared market mood: the list moves together
#              + sigma_c · N_c(h)                           the company's own bounded noise
#              + shocks(c, h)                               ShockLog: a permanent part plus a decaying overshoot
#
# N draws a unit value per 4-week knot from a splitmix finalizer over (run_seed, id hash, knot)
# and runs Catmull-Rom between knots, so consecutive weekly deltas never repeat. Anchors are keyed
# by calendar year and read through GameState.get_date_dict; a week outside the anchor range
# clamps to the nearest anchor. Player actions never feed back into anchors (catalogue rule).

const COMPANIES_PATH := "res://data/market/companies.json"
const PEOPLE_PATH := "res://data/market/people.json"
const TILE_WEEKS := 13
# splitmix64 constants as signed 64-bit (0x9E3779B97F4A7C15, 0xBF58476D1CE4E5B9, 0x94D049BB133111EB).
const MIX_SEED := -7046029254386353131
const MIX_A := -4658895280553007687
const MIX_B := -7723592293110705685
const MARKET_HASH := 0x4D41524B   # the shared mood stream's id hash

static var _meta: Dictionary = {}
static var _companies: Array = []
static var _by_id: Dictionary = {}
static var _years: Dictionary = {}    # company id → its anchor years, sorted once for _ln_anchor
static var _people: Dictionary = {}


static func _load() -> void:
	var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(COMPANIES_PATH))
	_meta = data["meta"]
	_companies = data["companies"]
	for c in _companies:
		var years: Array = (c["anchors"] as Dictionary).keys().map(func(k): return int(k))
		years.sort()
		_years[c["id"]] = years
		_by_id[c["id"]] = c
	for p in JSON.parse_string(FileAccess.get_file_as_string(PEOPLE_PATH))["people"]:
		_people[p["id"]] = p


static func companies() -> Array:
	if _companies.is_empty():
		_load()
	return _companies


static func company(id: String) -> Dictionary:
	companies()
	return _by_id.get(id, {})


static func person(id: String) -> Dictionary:
	companies()
	return _people.get(id, {})


static func people() -> Array:
	companies()
	return _people.values()


static func meta() -> Dictionary:
	companies()
	return _meta


static func version() -> int:
	return int(meta()["version"])


## The player's sector on the list: the sub-type's slot 0..2 company ids (giant, league leader, incumbent).
static func sector_slots(subtype: String) -> Array:
	return meta()["sector_slots"].get(subtype, [])


# --- Value ------------------------------------------------------------------------------------

static func value(c: Dictionary, week: int) -> float:
	return exp(ln_value(c, week))


static func ln_value(c: Dictionary, week: int) -> float:
	var noise: Dictionary = meta()["noise"]
	var knot: int = int(meta()["knot_weeks"])
	return _ln_anchor(c, _year_frac(week)) \
		+ float(c["beta"]) * float(noise["sigma_market"]) * _noise(MARKET_HASH, week, knot) \
		+ float(noise["sigma_" + String(c["noise"])]) * _noise(String(c["id"]).hash(), week, knot) \
		+ _shocks(String(c["id"]), week)


## Share price: value / fixed shares outstanding. Derived, never stored.
static func price(c: Dictionary, week: int) -> float:
	return value(c, week) * 1_000_000.0 / float(c["shares_outstanding"])


static func series(c: Dictionary, from_week: int, to_week: int) -> Array[float]:
	var out: Array[float] = []
	for w in range(from_week, to_week + 1):
		out.append(value(c, w))
	return out


## Public rows on the list at `week`, most valuable first.
static func listed(week: int) -> Array:
	var rows: Array = companies().filter(
		func(c): return String(c["status"]) == "public" and int(c["listed_week"]) <= week)
	var v: Dictionary = {}
	for c in rows:
		v[c["id"]] = value(c, week)
	rows.sort_custom(func(a, b): return v[a["id"]] > v[b["id"]])
	return rows


static func leader(week: int) -> Dictionary:
	var rows: Array = listed(week)
	return rows[0] if not rows.is_empty() else {}


static func list_total(week: int) -> float:
	var total: float = 0.0
	for c in listed(week):
		total += value(c, week)
	return total


static func share_of_list(c: Dictionary, week: int) -> float:
	return value(c, week) / list_total(week)


## The KPI tile's bars: the list total over the last TILE_WEEKS weeks ending at `week`.
static func list_series(week: int) -> Array[float]:
	var out: Array[float] = []
	for w in range(week - TILE_WEEKS + 1, week + 1):
		out.append(list_total(w))
	return out


## The week whose tick falls last in `year` (negative before the run began).
static func week_at_year_end(year: int) -> int:
	var start: int = int(Time.get_unix_time_from_datetime_dict(GameState.get_date_dict(1)))
	var year_end: int = int(Time.get_unix_time_from_datetime_dict({"year": year, "month": 12, "day": 31}))
	return 1 + floori(float(year_end - start) / (7.0 * 86400.0))


## The report card's year-end rows, {year: value} for the `count` years ending at `until_year`;
## years before the company listed are left out.
static func year_end_values(c: Dictionary, until_year: int, count: int = 5) -> Dictionary:
	var out: Dictionary = {}
	for year in range(until_year - count + 1, until_year + 1):
		if year >= int(c["ipo_year"]):
			out[year] = value(c, week_at_year_end(year))
	return out


# --- Terms --------------------------------------------------------------------------------------

static func _year_frac(week: int) -> float:
	var d: Dictionary = GameState.get_date_dict(week)
	return float(d.year) + (float(d.week) - 0.5) / (365.25 / 7.0)


## Anchor `year` sits at year end, position year + 1; between two anchors the log value runs a
## smoothstep, outside the range it clamps.
static func _ln_anchor(c: Dictionary, x: float) -> float:
	var anchors: Dictionary = c["anchors"]
	var years: Array = _years[c["id"]]
	if x <= float(years[0] + 1):
		return log(float(anchors[str(years[0])]))
	for i in range(1, years.size()):
		if x <= float(years[i] + 1):
			var f: float = (x - float(years[i - 1] + 1)) / float(years[i] - years[i - 1])
			f = f * f * (3.0 - 2.0 * f)
			return lerpf(log(float(anchors[str(years[i - 1])])), log(float(anchors[str(years[i])])), f)
	return log(float(anchors[str(years.back())]))


## Catmull-Rom through unit knots every `knot_weeks`; bounded by the knots up to the spline's
## small overshoot.
static func _noise(id_hash: int, week: int, knot_weeks: int) -> float:
	var k: int = floori(float(week) / float(knot_weeks))
	var f: float = float(week - k * knot_weeks) / float(knot_weeks)
	var a: float = _unit(id_hash, k - 1)
	var b: float = _unit(id_hash, k)
	var c: float = _unit(id_hash, k + 1)
	var d: float = _unit(id_hash, k + 2)
	return 0.5 * (2.0 * b + (c - a) * f + (2.0 * a - 5.0 * b + 4.0 * c - d) * f * f
		+ (3.0 * b - a - 3.0 * c + d) * f * f * f)


## splitmix64 finalizer over (run_seed, id hash, knot) → [-1, 1). Integer arithmetic wraps.
static func _unit(id_hash: int, knot: int) -> float:
	var z: int = GameState.run_seed * MIX_SEED + id_hash * MIX_A + knot * MIX_B
	z = (z ^ _ushr(z, 30)) * MIX_A
	z = (z ^ _ushr(z, 27)) * MIX_B
	z = z ^ _ushr(z, 31)
	return float(z & 0xFFFFFFFFFFFFF) / 4503599627370496.0 * 2.0 - 1.0


static func _ushr(z: int, n: int) -> int:
	return (z >> n) & ((1 << (64 - n)) - 1)


## ShockLog rows for the company that have landed by `week`: J·(rho + (1 − rho)·e^(−age/tau)).
static func _shocks(id: String, week: int) -> float:
	var total: float = 0.0
	for s in GameState.market_shocks:
		if String(s["company_id"]) != id or int(s["week"]) > week:
			continue
		var rho: float = float(s["rho"])
		total += float(s["J"]) * (rho + (1.0 - rho) * exp(-float(week - int(s["week"])) / float(s["tau"])))
	return total
