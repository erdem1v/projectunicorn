extends Node

# Core run state per TECH_SPEC §6.1.
# Defaults reflect PROJECT_SPEC §3.3 Phase 1 — Bootstrap start.
# All mutations go through setter methods so signal flow stays one-directional (§6.2).

const DAYS_PER_MONTH := 30  # Matches FinanceSystem.DAYS_PER_MONTH; both convert monthly → daily

# Calendar anchor — Day 1 = Thu Jan 1, 2026 (game starts in 2026; year advances
# with playtime). Godot Time computes the real weekday from the date, so no
# offset hack. get_display_date() does the conversion.
const START_DATE := {"year": 2026, "month": 1, "day": 1}
const MONTH_ABBR := ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
const DOW_ABBR := ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]

# --- Run identity ---
var company_name: String = "Unicorn Inc."
var origin: String = "self_made"      # "self_made" | "heir" | "corporate_refugee" (demo: self_made only)
var subgenre: String = "ai"           # "ai" | "saas" | "social" (demo: ai|saas only)
var logo_style: String = "minimalist" # "minimalist" | "tech" | "playful" | "serious" (PROJECT_SPEC §3.1)
var slogan: String = ""               # Optional free text — may be empty
var founder_name: String = ""         # Player's name; "" means the founder Character defaults to "Founder"
var run_seed: int = 0  # 0 = unseeded; TECH_SPEC §10.4 seeds this when run starts

# --- Phase 1 — Bootstrap defaults ---
var cash: int = 10000
var mrr: int = 0
var daily_burn: int = 50        # ~$1,500/month — pressure-from-day-one baseline (~6.6mo runway at start); FinanceSystem owns categorized breakdown
var brand: int = 50              # Neutral baseline
var reputation: int = 0          # Self-Made Founder baseline (§4.5)
var day: int = 1
var current_hour: int = 9        # 0-23. Day 1 starts at 09:00 (business-day-start); see TECH_SPEC §20 (2026-05-15)
var phase: int = 1               # 1=Bootstrap, 2=Traction, 3=Series A Hunt

# --- World-state flags (sparse, content-defined keys) ---
# Read at next eligibility eval (no EventBus emission). Default-empty Dictionary
# means initialize_run does not need an explicit reset line.
var flags: Dictionary = {}

# --- Setters (the only way to mutate from outside) ---

func set_cash(value: int) -> void:
	cash = value
	EventBus.cash_changed.emit(cash)
	_emit_runway()

func set_mrr(value: int) -> void:
	mrr = value
	EventBus.mrr_changed.emit(mrr)
	_emit_runway()

func set_daily_burn(value: int) -> void:
	daily_burn = max(value, 0)
	EventBus.burn_changed.emit(daily_burn)
	_emit_runway()

func set_brand(value: int) -> void:
	brand = clampi(value, 0, 100)
	EventBus.brand_changed.emit(brand)

func set_reputation(value: int) -> void:
	# Placeholder clamp range — spec leaves bounds undefined.
	# See PROJECT_SPEC §9 Open Question #9 for designer decision.
	reputation = clampi(value, -10, 100)
	EventBus.reputation_changed.emit(reputation)

func advance_day() -> void:
	day += 1
	EventBus.day_advanced.emit(day)

func set_current_hour(value: int) -> void:
	current_hour = clampi(value, 0, 23)
	EventBus.hour_changed.emit(current_hour)

func set_phase(value: int) -> void:
	phase = clampi(value, 1, 3)
	EventBus.phase_changed.emit(phase)

# --- Flag accessors ---

func set_flag(key: String, value: Variant) -> void:
	# Flags are read-on-eligibility-eval, never pushed to UI. No EventBus emit.
	flags[key] = value


func get_flag(key: String, default_value: Variant = null) -> Variant:
	return flags.get(key, default_value)


func has_flag(key: String) -> bool:
	return flags.has(key)

# --- Derived getters ---

func get_daily_revenue() -> int:
	return int(round(mrr / float(DAYS_PER_MONTH)))

func get_net_daily_flow() -> int:
	return get_daily_revenue() - daily_burn

func get_runway_months() -> float:
	# Returns INF when positive net flow; otherwise months remaining.
	var daily_net: float = float(get_net_daily_flow())
	if daily_net >= 0.0:
		return INF
	return cash / (-daily_net) / float(DAYS_PER_MONTH)

func get_founder_equity() -> float:
	# Derived from CharacterRegistry employee equity_pct values. Matches the
	# get_runway_months pattern — single source of truth, recompute on demand.
	var employee_total: float = 0.0
	for emp in CharacterRegistry.get_employees():
		employee_total += emp.equity_pct
	return clamp(1.0 - employee_total, 0.0, 1.0)


func get_founder_skill(skill_name: String) -> int:
	# Reads from founder.role_stats. Populated by _build_founder from
	# onboarding SkillStep payload. Returns 0 if founder or skill missing.
	var founder: Character = CharacterRegistry.get_founder()
	if founder == null:
		return 0
	return int(founder.role_stats.get(skill_name, 0))


func get_display_date(with_year: bool = false) -> String:
	# Day N → "Thu, Jan 1" (or "Thu, Jan 1, 2026" with_year) using the START_DATE
	# anchor. Godot Time built-ins; no external calendar lib.
	var anchor_unix: int = int(Time.get_unix_time_from_datetime_dict(START_DATE))
	var current_unix: int = anchor_unix + (day - 1) * 86400
	var d: Dictionary = Time.get_datetime_dict_from_unix_time(current_unix)
	if with_year:
		return "%s, %s %d, %d" % [DOW_ABBR[d.weekday], MONTH_ABBR[d.month - 1], d.day, d.year]
	return "%s, %s %d" % [DOW_ABBR[d.weekday], MONTH_ABBR[d.month - 1], d.day]

func _emit_runway() -> void:
	EventBus.runway_recalculated.emit(get_runway_months())


# --- Run initialization (single seam: onboarding Confirm + F12 debug skip) ---

func initialize_run(payload: Dictionary) -> void:
	# Called once when the onboarding flow confirms (or F12 skip fires).
	# Direct field assignment — GameShell has not been instanced yet, so no
	# listeners exist on EventBus and signals would land in the void. Setters
	# (which emit) are reserved for in-game mutation when listeners are wired.

	# Identity
	origin = payload.get("origin_id", "self_made")
	subgenre = payload.get("subgenre_id", "ai")
	company_name = payload.get("company_name", "Unicorn Inc.")
	logo_style = payload.get("logo_style", "minimalist")
	slogan = payload.get("slogan", "")
	founder_name = payload.get("founder_name", "")

	# Start state per PROJECT_SPEC §4.5 (Self-Made values — only playable demo origin)
	cash = 10000
	mrr = 0
	daily_burn = 50
	brand = 50
	reputation = 0
	day = 1
	current_hour = 9   # TECH_SPEC §20 business-day-start
	phase = 1          # 1=Bootstrap

	# Seeded RNG per TECH_SPEC §10.4
	run_seed = Time.get_ticks_msec()
	seed(run_seed)

	# Roster: ensure mentor exists, add founder
	CharacterRegistry.ensure_mentor()
	var founder := _build_founder(payload)
	CharacterRegistry.add(founder)


func _build_founder(payload: Dictionary) -> Character:
	var skill_alloc: Dictionary = payload.get("skill_alloc", {})
	var traits_arr: Array[String] = []
	var positive_id: String = payload.get("trait_positive_id", "")
	var negative_id: String = payload.get("trait_negative_id", "")
	if positive_id != "":
		traits_arr.append(positive_id)
	if negative_id != "":
		traits_arr.append(negative_id)

	var raw_name: String = payload.get("founder_name", "")
	var display_name: String = raw_name.strip_edges() if raw_name != "" else ""
	if display_name == "":
		display_name = "Founder"

	var f := Character.new()
	f.id = "char_founder"
	f.character_name = display_name
	f.role = "Founder"
	f.category = "founder"
	f.monthly_salary = 0
	f.equity_pct = 100.0
	f.morale = 50
	f.role_stats = {
		"tech": int(skill_alloc.get("tech", 0)),
		"markets": int(skill_alloc.get("markets", 0)),
		"charisma": int(skill_alloc.get("charisma", 0)),
		"politics": int(skill_alloc.get("politics", 0)),
	}
	f.traits = traits_arr
	# loyalty / relationship / trust_score / attention_flag stay at Resource
	# defaults — forward-compatible per scripts/data_models/character.gd.
	return f
