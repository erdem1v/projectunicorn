extends Node

# Core run state per TECH_SPEC §6.1.
# Defaults reflect PROJECT_SPEC §3.3 Phase 1 — Bootstrap start.
# All mutations go through setter methods so signal flow stays one-directional (§6.2).

const DAYS_PER_MONTH := 30  # Single home for the monthly → daily conversion; FinanceSystem reads it too

# Calendar anchor — Day 1 = Thu Jan 1, 2026 (game starts in 2026; year advances
# with playtime). Godot Time computes the real weekday from the date, so no
# offset hack. get_display_date() does the conversion.
const START_DATE := {"year": 2026, "month": 1, "day": 1}
const MONTH_ABBR := ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
const DOW_ABBR := ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
# TR month display names (Month-End Summary header; localization pass externalizes later)
const MONTH_NAMES_TR := ["OCAK", "ŞUBAT", "MART", "NİSAN", "MAYIS", "HAZİRAN", "TEMMUZ", "AĞUSTOS", "EYLÜL", "EKİM", "KASIM", "ARALIK"]

# --- Run identity ---
var company_name: String = "Unicorn Inc."
var origin: String = "self_made"      # "self_made" | "heir" | "corporate_refugee" (demo: self_made only)
var subgenre: String = "ai"           # "ai" | "saas" | "social" (demo: ai|saas only)
var logo_style: String = "minimalist" # "minimalist" | "tech" | "playful" | "serious" (PROJECT_SPEC §3.1)
var slogan: String = ""               # Optional free text — may be empty
var founder_name: String = ""         # Player's name; "" means the founder Character defaults to "Founder"
var founder_portrait: String = ""     # Portrait id (e.g. "founder_03"); art via FounderConstants.portrait_path()
var run_seed: int = 0  # 0 = unseeded; TECH_SPEC §10.4 seeds this when run starts

# --- Phase 1 — Bootstrap defaults ---
var cash: int = FounderConstants.STARTING_CASH
var mrr: int = 0
var daily_burn: int = FinanceSystem.starting_daily_burn()        # ~$1,500/month — pressure-from-day-one baseline (~6.6mo runway at start); FinanceSystem owns categorized breakdown
var brand: int = 50              # Neutral baseline
var reputation: int = 0          # Self-Made Founder baseline (§4.5)
var day: int = 1
var current_hour: int = 9        # 0-23. Day 1 starts at 09:00 (business-day-start); see TECH_SPEC §20 (2026-05-15)
var phase: int = 1               # 1=Bootstrap, 2=Traction, 3=Series A Hunt

# --- World-state flags (sparse, content-defined keys) ---
# Read at next eligibility eval (no EventBus emission). Default-empty Dictionary
# means initialize_run does not need an explicit reset line.
var flags: Dictionary = {}

# --- Endgame state (ENDGAME_DESIGN.md §2/§3/§7 ledger item 7 — serialized set) ---
# Fields, not systems (§7.9): slot-9 evaluator reads these; later systems
# (VC pitch, scandal) write them with zero retrofit. SaveManager plugs in later.
var run_active: bool = true            # false = terminal reached; tick loop halts
var ending_id: String = ""             # one of EndingsSystem.ENDINGS keys once run ends
var phase_gate_ready: bool = false     # ratchet latch (§2.3) — cleared only by advance_phase()
var pending_next_phase: int = 0        # 0 = no open gate
var series_a_closed: bool = false      # future VC pitch system writes; debug-settable now (§7.8)
var shutter_days_left: int = -1        # -1 inactive; 7..0 = Kepenk counter (§4.3)
var vc_rejections: int = 0             # closed pitch tables; future VC pitch increments (§4.5)
var pivot_used: bool = false           # true → VC path permanently closed (Erdem 2026-07-13)
var active_scandal: bool = false           # RESERVED — no scandal system yet; debug-settable
var unmanaged_major_scandal: bool = false  # RESERVED — day-180 fork input (§4.6)
var cash_went_negative: bool = false   # latched in set_cash; day-180 fork input
var brand_low_since_day: int = -1      # brand-collapse 30-day window anchor (§4.4)
var net_history_90: Array[int] = []    # daily net ring buffer — fork wants CUMULATIVE 90-day sum > 0

# --- Month-End Summary state (Spec 3; serialized-set extension of §7.7) ---
# MonthLedger: month-start snapshot for the summary's deltas. Shape:
# {start_day, mrr, cash, employees, brand}. Written only by
# MonthSummarySystem.snapshot(); "what changed this month?" comes from here,
# never from the run counters below (two data shapes, two questions).
var month_ledger: Dictionary = {}
# Month highlight ("AYIN OLAYI") — systems submit via submit_month_highlight();
# cleared at each month rollover by MonthSummarySystem.snapshot().
var month_highlight_text: String = ""
var month_highlight_priority: int = -1

# --- Run-cumulative counters (Spec 3 §3 — WRITE-ONLY seam for the newspaper
# ending screen; the month modal never reads these). Increments live at the
# single existing seams only. B2C has no discrete sign/churn moment (aggregate
# userbase) → signed/lost count B2B events until the ending-screen spec decides
# B2C semantics. ---
var run_customers_signed: int = 0      # SalesSystem.add_b2b_customer
var run_customers_lost: int = 0        # churn_customer modifier, B2B branch
var run_customers_expanded: int = 0    # B2BSalesSystem.expand (genuine seat/MRR upsell)
var run_hires: int = 0                 # CharacterRegistry.add, category "employee"
# B2B pitch customer-rep portrait rotation (sequential over the non-selected founder
# portraits; read+written each meeting, so it's real run state, not a write-only counter).
var b2b_rep_portrait_rotation_index: int = 0   # sequential cursor into the rep-portrait pool
var b2b_last_rep_portrait: String = ""         # last face shown — new assignments skip it (no consecutive repeat)
var run_departures: int = 0            # RESERVED — no fire/quit seam exists yet
var run_scandals_total: int = 0        # RESERVED — no scandal system yet; debug-settable
var run_scandals_managed: int = 0      # RESERVED
var run_pushes_attempted: int = 0      # Term Sheet table push() writes (term_sheet_table_system.gd)
var run_pushes_won: int = 0            # Term Sheet table push() writes (successful pushes)
# Peak MRR reached this run — latched in set_mrr (newspaper "en yüksek gelir" line).
var run_peak_mrr: int = 0
# Signed Series A term sheet snapshot — persisted at VCPitchSystem.sign_table (the single
# sign seam). 0 unless a term sheet was actually signed (series_a_close). The ending screen
# reads these off get_run_ledger() rather than the transient run_ended payload extra.
var run_investment_amount: int = 0     # money raised, dollars
var run_valuation_m: int = 0           # pre-money valuation, millions
var run_equity_pct: int = 0            # equity given == signed dilution_pct
var run_board_seats: int = 0           # board seats granted to the investor
var run_board_veto: bool = false       # investor veto right granted

# --- VC Pitch / Series A Hunt state (Spec 4 / VC_PITCH_DESIGN.md §7 — serialized
# set, same "fields not systems" rule as the endgame block). VCPitchSystem writes;
# EndingsSystem reads active_sheets/pending_meeting for the cascade defer (ledger 17).
# All reset in initialize_run. Meeting-LOCAL state (conviction/beat/intel) is NOT here
# — it lives in VCPitchSystem static vars and is never serialized (ledger 13). ---
var vc_states: Dictionary = {}         # vc_id -> {status, callback, pending_sheet, meeting_count, ...}
var active_sheets: Array = []          # live TermSheet resources (max PitchConstants.MAX_SHEETS)
var pending_meeting: Dictionary = {}   # {vc_id, day} — one at a time (ledger 24); empty = none
var prep: Dictionary = {}              # {vc_id, focus, done} — one prep per scheduled meeting; empty = none
var run_pitches: int = 0               # run-cumulative: completed meetings (newspaper seam)
var run_sheets_won: int = 0            # run-cumulative: sheets granted (distinct from run_pushes_*)

# --- Setters (the only way to mutate from outside) ---

func set_cash(value: int) -> void:
	cash = value
	if cash < 0:
		cash_went_negative = true  # latch here (not in the finance tick) so intra-day event deltas count too
	EventBus.cash_changed.emit(cash)
	_emit_runway()

func set_mrr(value: int) -> void:
	mrr = value
	if value > run_peak_mrr:
		run_peak_mrr = value  # latch peak here (like set_cash's cash_went_negative) — write-only, no separate signal
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

func set_subgenre(value: String) -> void:
	# Write-through seam: called by ProductSystem.start_build when a product is
	# committed (onboarding no longer asks — the played product decision owns
	# this field). No signal: every reader (event conditions, VC seeding,
	# product pool fallbacks) reads lazily at evaluation time.
	subgenre = value

func set_phase(value: int) -> void:
	# Save-restore / debug backdoor ONLY. Gameplay phase changes go through
	# advance_phase() — the single write seam bound to a played Frank scene
	# (ENDGAME_DESIGN.md §2.1).
	phase = clampi(value, 1, 3)
	EventBus.phase_changed.emit(phase)


func advance_phase() -> void:
	# The SINGLE gameplay write seam for phase (ENDGAME_DESIGN.md §2.1).
	# Called from the Frank transition scene's "advance_phase" modifier after the
	# player confirms. Forward-only ratchet; produces no economic delta.
	if not phase_gate_ready or pending_next_phase <= phase:
		push_warning("[GameState] advance_phase without an open gate — ignored")
		return
	phase = clampi(pending_next_phase, 1, 3)
	phase_gate_ready = false
	pending_next_phase = 0
	var phase_names := ["Bootstrap", "Traction", "Series A"]
	submit_month_highlight(
		"Yeni faza geçildi: %s" % phase_names[clampi(phase - 1, 0, 2)], 80)  # AYIN OLAYI (Spec 3 §4)
	EventBus.phase_changed.emit(phase)


func set_run_active(value: bool) -> void:
	# No dedicated signal — run_ended carries the news with full ending context.
	run_active = value


func set_shutter_days_left(value: int) -> void:
	shutter_days_left = value
	EventBus.shutter_changed.emit(shutter_days_left)


func submit_month_highlight(text: String, priority: int) -> void:
	# AYIN OLAYI registry (Spec 3 §4): higher priority replaces lower;
	# first-come wins ties. Cleared each month rollover (MonthSummarySystem).
	if priority > month_highlight_priority:
		month_highlight_text = text
		month_highlight_priority = priority

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
	# NET runway (revenue-aware) — the player's canonical lens; VC surfaces deliberately
	# use GROSS (VCPitchSystem._gross_runway_months / term-sheet table days).
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
	# Reads from founder.role_stats. Populated by _build_founder from the
	# onboarding skill allocation. Returns 0 if founder or skill missing.
	# SKILL-RENAME tripwire: a read of a pre-rename key is a stale caller —
	# scream in every log instead of silently returning 0.
	if skill_name in FounderConstants.OLD_SKILLS:
		push_error("[GameState] read of renamed founder skill '%s' — see FounderConstants SKILL-RENAME ledger" % skill_name)
	var founder: Character = CharacterRegistry.get_founder()
	if founder == null:
		return 0
	return int(founder.role_stats.get(skill_name, 0))


func get_date_dict(for_day: int = -1) -> Dictionary:
	# Run day N → Godot Time datetime dict {year, month, day, weekday, …} via
	# the START_DATE anchor. THE single day→calendar conversion — month
	# boundaries come from here (real 28/30/31-day months), never from the
	# economy constant DAYS_PER_MONTH. Default: the current day.
	var d: int = day if for_day < 0 else for_day
	var anchor_unix: int = int(Time.get_unix_time_from_datetime_dict(START_DATE))
	return Time.get_datetime_dict_from_unix_time(anchor_unix + (d - 1) * 86400)


func get_display_date(with_year: bool = false) -> String:
	# Day N → "Thu, Jan 1" (or "Thu, Jan 1, 2026" with_year) using the START_DATE
	# anchor. Godot Time built-ins; no external calendar lib.
	var d: Dictionary = get_date_dict()
	if with_year:
		return "%s, %s %d, %d" % [DOW_ABBR[d.weekday], MONTH_ABBR[d.month - 1], d.day, d.year]
	return "%s, %s %d" % [DOW_ABBR[d.weekday], MONTH_ABBR[d.month - 1], d.day]

func get_run_ledger() -> Dictionary:
	# The newspaper ending screen's single read seam. Recompute-on-demand (like
	# get_runway_months / get_founder_equity) — gathers the flat run_* counters +
	# derived live values into one dict EndingsCopy assembles into prose. READ-ONLY:
	# nothing here writes state. Signed-terms fields read 0 unless a term sheet was
	# signed; run_departures reads 0 until a fire/quit flow exists.
	var start: Dictionary = get_date_dict(1)   # founding calendar (day 1 = Jan 2026)
	return {
		# timeline
		"day": day,
		"phase": phase,
		"origin": origin,
		"start_month": int(start.month),
		"start_year": int(start.year),
		# economy
		"cash": cash,
		"mrr": mrr,
		"peak_mrr": run_peak_mrr,
		"brand": brand,
		"reputation": reputation,
		# customers (B2B discrete sign/churn; B2C is aggregate)
		"customers_active": CustomerRegistry.get_active().size(),
		"customers_signed": run_customers_signed,
		"customers_lost": run_customers_lost,
		"customers_expanded": run_customers_expanded,
		# team (founder + mentor excluded from get_employees)
		"employees": CharacterRegistry.get_employees().size(),
		"hires": run_hires,
		"departures": run_departures,
		# product (derived — no dedicated counter)
		"product_version": int(get_flag("mvp_version", 0)),
		"product_ships": (get_flag("mvp_version_history", []) as Array).size(),
		# fundraising
		"pitches": run_pitches,
		"sheets_won": run_sheets_won,
		"vc_rejections": vc_rejections,
		"pushes_attempted": run_pushes_attempted,
		"pushes_won": run_pushes_won,
		# signed term sheet (0 unless series_a_close)
		"investment_amount": run_investment_amount,
		"valuation_m": run_valuation_m,
		"equity_pct": run_equity_pct,
		"board_seats": run_board_seats,
		"board_veto": run_board_veto,
		# scandals (reserved — read 0 today)
		"scandals_total": run_scandals_total,
		"scandals_managed": run_scandals_managed,
	}


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
	# Onboarding no longer asks the subgenre — it defaults here and the committed
	# product write-throughs it later (set_subgenre via ProductSystem.start_build).
	subgenre = payload.get("subgenre_id", "ai")
	company_name = payload.get("company_name", "Unicorn Inc.")
	logo_style = payload.get("logo_style", "minimalist")
	slogan = payload.get("slogan", "")
	founder_name = payload.get("founder_name", "")
	founder_portrait = payload.get("portrait_id", "")

	# Start state: origin decides the opening cash (FounderConstants working
	# placeholder — Self-Made low capital; locked origins carry their own later).
	cash = int(FounderConstants.origin_by_id(origin).get("starting_cash", FounderConstants.STARTING_CASH))
	mrr = 0
	daily_burn = FinanceSystem.starting_daily_burn()
	brand = 50
	reputation = 0
	day = 1
	current_hour = 9   # TECH_SPEC §20 business-day-start
	phase = 1          # 1=Bootstrap

	# Endgame state reset (ENDGAME_DESIGN.md §7.7 serialized set)
	run_active = true
	ending_id = ""
	phase_gate_ready = false
	pending_next_phase = 0
	series_a_closed = false
	shutter_days_left = -1
	vc_rejections = 0
	pivot_used = false
	active_scandal = false
	unmanaged_major_scandal = false
	cash_went_negative = false
	brand_low_since_day = -1
	net_history_90 = []

	# Month-End Summary + run counters reset (Spec 3; month_ledger snapshot
	# happens at the END of this function — it needs the roster in place)
	month_highlight_text = ""
	month_highlight_priority = -1
	run_customers_signed = 0
	run_customers_lost = 0
	run_customers_expanded = 0
	b2b_rep_portrait_rotation_index = 0
	b2b_last_rep_portrait = ""
	run_hires = 0
	run_departures = 0
	run_scandals_total = 0
	run_scandals_managed = 0
	run_pushes_attempted = 0
	run_pushes_won = 0
	run_peak_mrr = 0
	run_investment_amount = 0
	run_valuation_m = 0
	run_equity_pct = 0
	run_board_seats = 0
	run_board_veto = false

	# VC Pitch / Series A Hunt reset (Spec 4). Dicts via .clear() in case a system
	# cached the reference; arrays reassigned.
	vc_states.clear()
	active_sheets = []
	pending_meeting.clear()
	prep.clear()
	run_pitches = 0
	run_sheets_won = 0

	# Flags survive nothing: fresh run = fresh world-state (hardening for any
	# future in-place restart; harmless in a fresh process).
	flags.clear()

	# Origin flags — set AFTER the clear or they would be wiped. RESERVED:
	# nothing consumes origin_press_sympathy / origin_low_capital yet; future
	# press/network systems read them (FounderConstants.ORIGINS reserved_flags).
	for origin_flag in FounderConstants.origin_by_id(origin).get("reserved_flags", []):
		set_flag(String(origin_flag), true)

	# Saat senkronu: current_hour'u doğrudan yazdık — TimeManager'ın accumulator'ı
	# da aynı saate kilitlenmeli, yoksa ilk gün saatlik tik atmaz ("ilk gün ölü").
	TimeManager.sync_to_current_hour()

	# Seeded RNG per TECH_SPEC §10.4
	run_seed = Time.get_ticks_msec()
	seed(run_seed)

	# Roster: ensure mentor exists, add founder
	CharacterRegistry.ensure_mentor()
	var founder := _build_founder(payload)
	CharacterRegistry.add(founder)

	# Month-1 ledger snapshot — AFTER the roster so the team count is real.
	# (The founder add above must not count as a "hire": category is "founder".)
	MonthSummarySystem.snapshot()
	run_hires = 0  # belt-and-braces: whatever roster seeding did, hires start at 0


func _build_founder(payload: Dictionary) -> Character:
	var skill_alloc: Dictionary = payload.get("skill_alloc", {})
	# Trait ids as one array (polarity derives from the FounderConstants catalog).
	# RESERVED: no system consumes trait effects yet — stored for the wiring task.
	var traits_arr: Array[String] = []
	for trait_id in payload.get("trait_ids", []):
		traits_arr.append(String(trait_id))
	if not FounderConstants.validate_traits(traits_arr):
		push_error("[GameState] trait_ids failed the trait formula: %s" % str(traits_arr))

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
	# SKILL-RENAME: canonical key list lives in FounderConstants.SKILLS — the single
	# mapping. Stale payload keys (pre-rename UI) are flagged loudly, never copied.
	var stats: Dictionary = {}
	for skill_key in FounderConstants.SKILLS:
		stats[skill_key] = int(skill_alloc.get(skill_key, 0))
	for k in skill_alloc.keys():
		if not FounderConstants.SKILLS.has(k):
			push_error("[GameState] stale skill key in onboarding payload: '%s' (SKILL-RENAME)" % k)
	if not FounderConstants.validate_alloc(skill_alloc):
		push_error("[GameState] skill_alloc failed validation (pool %d, cap %d): %s"
			% [FounderConstants.POINT_POOL, FounderConstants.ONBOARDING_CAP, str(skill_alloc)])
	f.role_stats = stats
	f.traits = traits_arr
	# loyalty / relationship / trust_score / attention_flag stay at Resource
	# defaults — forward-compatible per scripts/data_models/character.gd.
	return f
