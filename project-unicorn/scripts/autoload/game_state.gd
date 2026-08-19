extends Node

# Core run state per TECH_SPEC §6.1.
# Defaults reflect PROJECT_SPEC §3.3 Phase 1 — Bootstrap start.
# All mutations go through setter methods so signal flow stays one-directional (§6.2).

const DAYS_PER_MONTH := 30  # Single home for the monthly → daily conversion; FinanceSystem reads it too

# Calendar anchor — Day 1 = Thu Jan 1, 2026 (game starts in 2026; year advances
# with playtime). Godot Time computes the real weekday from the date, so no
# offset hack. get_date_dict() is the seam; display formatting lives with whoever
# renders it (top_bar's Turkish weekday/month tables, product_ui_shared's short form).
const START_DATE := {"year": 2026, "month": 1, "day": 1}
# The two Turkish month tables that used to live here (UPPERCASE for headers, Title Case for
# prose) are RETIRED. Month words are Fmt.month_name / Fmt.month_upper now — one home, both
# languages, and the dotted-İ problem that forced two literal tables is handled there: the
# CSV holds each form outright rather than deriving one from the other with a case op that
# Godot does not localise.

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

# --- FLAG TYPING (save-schema constraint, not a style preference) ---
# `flags` is ~51 untyped keys carrying the entire product state, and its readers do NOT
# agree on typing: EventManager's conditions coerce through bool()/int(), while systems
# use plain GDScript truthiness. A String-typed flag satisfies one and fails the other, and
# a JSON round trip re-types every number to float (Godot's parser returns TYPE_FLOAT even
# for "5"). So the flag bag needs a declared type or a save cannot restore it faithfully.
#
# SaveCodec coerces every restored flag through flag_type_for(); set_flag push_warnings in
# debug builds when a live write disagrees with the declaration, so drift surfaces while it
# is still one line of code and not a save-shaped mystery.
#
# A key absent from BOTH tables is legal (content can invent flags) — it round-trips
# best-effort and set_flag stays silent about it.
const FLAG_TYPES := {
	# --- product lifecycle ---
	"mvp_shipped": TYPE_BOOL,
	"mvp_version": TYPE_INT,
	"mvp_version_history": TYPE_ARRAY,
	"mvp_components": TYPE_ARRAY,
	"mvp_product_name": TYPE_STRING,
	"mvp_sub_product_type_id": TYPE_STRING,
	"mvp_market_type": TYPE_STRING,
	"mvp_launch_day": TYPE_INT,
	"mvp_quality": TYPE_INT,
	"mvp_innovation": TYPE_FLOAT,
	"mvp_stability": TYPE_FLOAT,
	"mvp_experience": TYPE_FLOAT,
	"mvp_innovation_prev": TYPE_FLOAT,
	"mvp_stability_prev": TYPE_FLOAT,
	"mvp_experience_prev": TYPE_FLOAT,
	"mvp_bug_count_at_launch": TYPE_INT,
	"mvp_live_bug_count": TYPE_INT,
	"mvp_live_bug_progress": TYPE_FLOAT,
	"mvp_bug_history": TYPE_ARRAY,
	"mvp_bug_sprint_active": TYPE_BOOL,
	"mvp_sprint_days_total": TYPE_INT,
	"mvp_sprint_days_elapsed": TYPE_FLOAT,
	"mvp_sprint_fix_progress": TYPE_FLOAT,
	"bug_sprint_days": TYPE_ARRAY,
	"bug_sprint_just_done": TYPE_BOOL,
	"critical_bug_unfixed": TYPE_BOOL,
	"tech_debt_birikti": TYPE_BOOL,
	"cancelled_build_prefill": TYPE_DICTIONARY,
	"product_path_frank_seen": TYPE_BOOL,
	"needs_engineer": TYPE_BOOL,
	# --- B2C economy ---
	# b2c_audience is FLOAT and that is the fix for audit S3-43: sales_system's hourly tick
	# accumulated it as a float precisely so slow erosion survives instead of rounding to
	# zero each hour, while add_b2c_audience / apply_b2c_price wrote it back as an int and
	# threw the sub-unit accumulator away every time an event or a price change touched it.
	"b2c_audience": TYPE_FLOAT,
	"b2c_price": TYPE_INT,
	"b2c_paid_tier_open": TYPE_BOOL,
	# --- sales / customer desks ---
	"sales_lead_progress": TYPE_FLOAT,
	"cs_throughput_progress": TYPE_FLOAT,
	"next_find_prospects_day": TYPE_INT,
	"next_pitch_day": TYPE_INT,
	"b2b_high_scale_unlocked": TYPE_BOOL,
	# --- phase gate / endgame / VC ---
	"gate_prompt_day": TYPE_INT,
	"gate_declines": TYPE_INT,
	"pitch_prep_active": TYPE_BOOL,
	"pivot_offer_made": TYPE_BOOL,
	"acquisition_offer_made": TYPE_BOOL,
	"acquisition_offer_rejected": TYPE_BOOL,
	"vc_soft_cap_warned": TYPE_BOOL,   # was vc_d179_warned (Day-180 wall) — the warning now precedes the soft cap
	# --- angel round (Frank's seed) + the locked hard path ---
	# The one-shot latch lives HERE and not on the event object: AngelRoundSystem injects
	# through enqueue_front, which bypasses _is_eligible entirely, so GameEvent.one_shot is
	# dead code for every synthetic event (event_manager.gd:198-212).
	"angel_seed_offered": TYPE_BOOL,
	"angel_seed_accepted_day": TYPE_INT,
	"angel_nudge_shown": TYPE_BOOL,
	# RESERVED — NO WRITER EXISTS ANYWHERE. This is the guaranteed-false gate behind
	# "REDDET · ZOR MOD"; the Frank-less path ships after the demo. Declared so the day a
	# writer appears, the save schema already knows its type.
	"hard_mode_unlocked": TYPE_BOOL,
	# --- origin reserves + UI snooze ---
	"origin_press_sympathy": TYPE_BOOL,
	"origin_low_capital": TYPE_BOOL,
	"finance_runway_warn_snooze_until_day": TYPE_INT,
	# --- debug force flags (smoke harness) ---
	"debug_skill_force": TYPE_STRING,
	"debug_hr_force": TYPE_STRING,
}

# The four DYNAMIC key families — one flag per entity id, so they cannot be listed above.
# Longest prefix wins (none of these four overlap, but the rule keeps it decidable).
const FLAG_TYPE_PREFIXES := {
	"b2b_broke_": TYPE_BOOL,                    # B2BSalesSystem credibility latch, per customer id
	"hr_manual_leave_": TYPE_BOOL,              # HRMoraleSystem manual-vacation marker, per character id
	"hr_valve_continued_": TYPE_BOOL,           # HROvertimeSystem "Devam et" memory, per character id
	"bug_count_at_bugfix_start_": TYPE_INT,     # ProductSystem beta-phase baseline, per build id
}

# GameState script variables the save deliberately does NOT carry. Empty today — every
# `var` on this node is run state. It exists so that excluding one later is a one-line,
# reviewable decision instead of an edit inside SaveCodec's walker.
const SAVE_EXCLUDE_FIELDS: Array[String] = []

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
var brand_low_since_day: int = -1      # brand-collapse 30-day window anchor (§4.4)
# (cash_went_negative and net_history_90 — the Day-180 fork's inputs — were retired with the
# fork on 2026-08-19, Calibration Round A §2. Profitability is a daily-evaluated CONDITION
# on the calendar-month ledger, §9: a month is "Artıda" only if its net is positive AND the
# treasury never sampled below zero inside it — the red-day test moved from a run-lifetime
# latch, which made the win permanently unreachable after one early Kepenk in a 24-month
# run, to a per-month count.)

# --- Finance surface state (Finance Tab v1 — serialized set; SaveManager plugs in later) ---
# cash_history: daily {day, cash} samples for the cash curve. Single writer:
# FinanceSystem.daily_tick via append_cash_sample (slot 5, once per day). Intra-day
# one-time costs are deliberately NOT re-sampled — the single-writer rule holds;
# they land in the next day's point and, itemised, in `transactions`.
const CASH_HISTORY_CAP := 760          # soft cap 730 days + headroom; oldest dropped (was 200 for the 180-day wall)
var cash_history: Array = []           # [{day: int, cash: int}]
# transactions: persistent signed money-event log (negative = spend, positive = income).
# Sole append point: FinanceSystem.record_transaction. Labels stored RAW — display maps
# through FinanceSystem.one_time_label_display, so registered ids render TR and free-form
# labels (customer names) pass through unchanged.
const TRANSACTIONS_CAP := 50           # oldest dropped beyond this
var transactions: Array = []           # [{day: int, label: String, amount: int}]
# sales_log: what the sales/customer desks did on their own, so the player can reconstruct a
# cause the ticker has already scrolled past (Calibration Law 3 — the CAUSE must be readable).
# Same ring-buffer shape as `transactions` above. Sole append point:
# SalesSystem.record_sales_event.
const SALES_LOG_CAP := 12              # oldest dropped beyond this
var sales_log: Array = []              # [{day, kind, actor, company, mrr}]

# --- Month-End Summary state (Spec 3; serialized-set extension of §7.7) ---
# MonthLedger: month-start snapshot for the summary's deltas. Shape:
# {start_day, mrr, cash, employees, brand}. Written only by
# MonthSummarySystem.snapshot(); "what changed this month?" comes from here,
# never from the run counters below (two data shapes, two questions).
var month_ledger: Dictionary = {}
# THE CALENDAR-MONTH LEDGER (Calibration Round A §3/§9, 2026-08-19). Closed fiscal months,
# oldest → newest, cap MONTH_HISTORY_CAP. Sole writer: push_month_close (MonthSummarySystem,
# slot 10, on the 1st of each calendar month, BEFORE the recap emit). Entry — all INT (JSON
# re-types numbers to float on load and SaveCodec restores ints; never store a ratio here,
# compute margins at read time):
#   {start_day, end_day, mrr_close, income, expense, net, red_days}
# Readers: the Series A gate's growth-streak condition (PhaseGateSystem / EventManager
# mrr_growth_streak), the profitability condition (EndingsSystem §9) and the Finance tab's
# "Yatırımcı iştahı" + "Artıda · n/6 ay" lines. Accruals for the OPEN month live on
# month_ledger (income / expense / red_days; reset by snapshot()) through accrue_month_flow /
# accrue_month_expense — one-time INCOME (the angel cheque) is financing, not operating
# income, and is deliberately not accrued.
const MONTH_HISTORY_CAP := 12
var month_history: Array[Dictionary] = []
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
# MONOTONIC, never decremented — it exists to make prospect ids unique, not to be read as a
# statistic. PitchSystem.spawn_prospect used to build ids off ProspectRegistry.count(), which
# is the LIVE pool size: removing a lead lowers it, so a same-day respawn collided and
# ProspectRegistry.add silently dropped the new lead while spawn_prospect still returned it.
var run_prospects_spawned: int = 0     # PitchSystem.spawn_prospect (id uniqueness only)
# Every company name ever SIGNED this run (writer: SalesSystem.add_b2b_customer, the sole
# B2B signing path). Superset of "currently a customer": churn erases the Customer entity
# (all three removal flows), but the name stays here so cold prospecting can never re-offer
# a former customer (Fix 1). Win-back (future) derives churned = this minus live names.
var b2b_signed_company_names: Array[String] = []
# Day stamps of CS escalations that actually reached the player, newest last. Read as a
# rolling window (CS_ESCALATION_WINDOW_DAYS) to enforce the company-wide weekly ceiling —
# without it, per-account pacing alone cannot stop a bad week, because _escalate_stale
# deliberately bypasses both the throughput budget and the absorb ceiling.
var cs_escalation_days: Array[int] = []
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

# Frank's angel round — DELIBERATELY SEPARATE from the signed-terms block above.
# VCPitchSystem._persist_signed_terms writes run_equity_pct / run_investment_amount by
# PLAIN ASSIGNMENT (vc_pitch_system.gd:326,329). Folding the angel slice into those fields
# would let a Series A signature silently erase 4% of the cap table and $25,000 of raised
# capital, and would light ODA's "İlk Yatırım" diploma (which reads run_investment_amount
# raw) on a round it was never meant to describe. Two scalars cost two lines and make that
# collision unrepresentable. Cap-table and ledger readers compose them via the two derived
# seams below — never by summing the raw fields at the call site.
var run_angel_amount: int = 0          # dollars the angel put in
var run_angel_equity_pct: int = 0      # the angel's slice, percent

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

# --- HR Core state (same "fields not systems" rule as the VC block above; all reset in
# initialize_run). The owning system writes each one; nothing else touches them. ---
var hr_search: Dictionary = {}          # HRSearchSystem: {state, role, band, seed, started_day, arrival_day, files}
var hr_overtime: Dictionary = {}        # HROvertimeSystem: department id -> {block_days, day_index, ...}
var hr_last_overtime_day: int = 0       # HROvertimeSystem stamps; the "sakin dönem" trigger reads it
var hr_last_positive_event_day: int = 0 # HRMoraleSystem: positive-morale-event cooldown cursor

# --- News feed state (same "fields not systems" rule; owner: NewsFeedSystem, the sole
# writer). JSON-primitive throughout: {used_sektor, reshuffles, counts, biz_buffer,
# biz_dropped, recent_rivals, stream}. Reset in initialize_run.
# `biz_dropped` counts milestone lines the ≤20 % "biz" quota refused, so the quota's real
# cost is countable rather than silent — calibration data, not a bug counter. ---
var news_feed: Dictionary = {}

# --- Setters (the only way to mutate from outside) ---

func set_cash(value: int) -> void:
	cash = value
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
	submit_month_highlight(
		TranslationServer.translate("MONTH_HL_PHASE_ADVANCED").format(
			{"phase": phase_display_name(phase)}), 80)  # AYIN OLAYI (Spec 3 §4)
	EventBus.phase_changed.emit(phase)


# THE phase display-name seam. The same ["Bootstrap", "Traction", "Series A"] literal had
# grown a copy here and a copy in MonthSummarySystem._build_summary_data (PhaseGateSystem
# keeps a third as a private helper, now delegating). The save meta block needs a fourth
# reader, so the array moves to its owner instead of being copied again — GameState is
# where `phase` itself lives. Out-of-range phases clamp rather than crash: this renders a
# header, never a decision.
func phase_display_name(p: int) -> String:
	var names := ["Bootstrap", "Traction", "Series A"]
	return names[clampi(p - 1, 0, names.size() - 1)]


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
	if OS.is_debug_build():
		_warn_on_flag_type_drift(key, value)
	flags[key] = value


func flag_type_for(key: String) -> int:
	# Declared Variant type of a flag, or TYPE_NIL when the key is not registered.
	# SaveCodec's single oracle for the flag bag. Concrete keys first, then the four
	# dynamic prefix families.
	if FLAG_TYPES.has(key):
		return int(FLAG_TYPES[key])
	for prefix in FLAG_TYPE_PREFIXES:
		if key.begins_with(prefix):
			return int(FLAG_TYPE_PREFIXES[prefix])
	return TYPE_NIL


func _warn_on_flag_type_drift(key: String, value: Variant) -> void:
	# DEBUG-ONLY tripwire. A flag written with a type other than its declaration is a bug
	# that costs nothing today and costs a broken save later: the save records what the
	# writer put in, the load coerces to what FLAG_TYPES says, and the two silently differ.
	# Non-blocking (same grammar as CharacterRegistry._validate_shape) — the write lands,
	# the log carries the defect.
	var declared: int = flag_type_for(key)
	if declared == TYPE_NIL:
		return  # unregistered content flag — legal, no claim to contradict
	var actual: int = typeof(value)
	if actual == declared:
		return
	# int↔float is the ONE tolerated pair: GDScript promotes freely and every reader of a
	# numeric flag casts, so warning on it would be pure noise (`set_flag(k, 0)` into a
	# FLOAT slot is idiomatic here). Everything else is a genuine type change.
	if (actual == TYPE_INT or actual == TYPE_FLOAT) and (declared == TYPE_INT or declared == TYPE_FLOAT):
		return
	push_warning("[GameState] flag '%s' declared %s but written as %s — see FLAG_TYPES"
		% [key, type_string(declared), type_string(actual)])


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
	# Delegates to runway_months_for so the arithmetic has exactly one home.
	return runway_months_for(cash, get_net_daily_flow())


func runway_months_for(cash_value: int, daily_net: int) -> float:
	# The same NET runway question asked about HYPOTHETICAL cash and flow, which is what a
	# preview needs: a hire moves cash and burn at once, so "runway after" cannot be answered
	# by get_runway_months() (that one only knows today). PURE arithmetic on purpose — it
	# carries no presentation guard, so get_runway_months() delegates to it byte-identically
	# and a caller that wants to floor a negative month count does so at its own edge.
	if daily_net >= 0:
		return INF
	return float(cash_value) / float(-daily_net) / float(DAYS_PER_MONTH)

func append_cash_sample(sample_cash: int) -> void:
	# Finance Tab v1 curve feed. Called EXACTLY once per day by FinanceSystem.daily_tick
	# (before its set_cash, so the synchronous cash_changed repaint reads a fresh buffer).
	cash_history.append({"day": day, "cash": sample_cash})
	while cash_history.size() > CASH_HISTORY_CAP:
		cash_history.pop_front()


# --- Calendar-month ledger seams (Calibration Round A §3/§9) ---

func accrue_month_flow(revenue: int, burn: int, closing_cash: int) -> void:
	# FinanceSystem.daily_tick, once per day, the SAME figures that moved the cash.
	month_ledger["income"] = int(month_ledger.get("income", 0)) + revenue
	month_ledger["expense"] = int(month_ledger.get("expense", 0)) + burn
	if closing_cash < 0:
		month_ledger["red_days"] = int(month_ledger.get("red_days", 0)) + 1


func accrue_month_expense(amount: int) -> void:
	# One-time COSTS (hire, severance, training, build commit) are outgoings of the month.
	month_ledger["expense"] = int(month_ledger.get("expense", 0)) + amount


func push_month_close(entry: Dictionary) -> void:
	month_history.append(entry)
	while month_history.size() > MONTH_HISTORY_CAP:
		month_history.pop_front()


## Consecutive closed months, newest backwards, whose close MRR grew ≥ min_pct over the
## previous close. Integer math (cur·100 ≥ prev·(100+pct)); a zero or negative previous close
## never counts. Needs streak+1 closes by construction (the first close has no predecessor).
func get_mrr_growth_streak(min_pct: int) -> int:
	var i: int = month_history.size() - 1
	var streak: int = 0
	while i >= 1:
		var prev: int = int(month_history[i - 1].get("mrr_close", 0))
		var cur: int = int(month_history[i].get("mrr_close", 0))
		if prev <= 0 or cur * 100 < prev * (100 + min_pct):
			break
		streak += 1
		i -= 1
	return streak


## Consecutive "Artıda" closes, newest backwards: net > 0 AND the treasury never sampled
## below zero inside the month (red_days == 0).
func get_profitable_month_streak() -> int:
	var streak: int = 0
	for i in range(month_history.size() - 1, -1, -1):
		var e: Dictionary = month_history[i]
		if int(e.get("net", 0)) <= 0 or int(e.get("red_days", 0)) > 0:
			break
		streak += 1
	return streak


## Σnet·100/Σincome over the last `months` closes; -1 when fewer closes exist or income is 0.
func get_window_margin_pct(months: int) -> int:
	if month_history.size() < months or months <= 0:
		return -1
	var inc: int = 0
	var net: int = 0
	for i in range(month_history.size() - months, month_history.size()):
		inc += int(month_history[i].get("income", 0))
		net += int(month_history[i].get("net", 0))
	if inc <= 0:
		return -1
	return int((net * 100) / inc)


func get_cash_history() -> Array:
	return cash_history.duplicate()  # readonly snapshot (get_burn_breakdown contract)


func get_founder_equity() -> float:
	# Derived from CharacterRegistry employee equity_pct values. Matches the
	# get_runway_months pattern — single source of truth, recompute on demand.
	var employee_total: float = 0.0
	for emp in CharacterRegistry.get_employees():
		employee_total += emp.equity_pct
	return clamp(1.0 - employee_total, 0.0, 1.0)


func get_investor_equity_pct() -> int:
	# THE cap-table denominator: angel + signed Series A. Recompute-on-demand (the
	# get_runway_months / get_founder_equity pattern) so a future round is one summand
	# here and zero edits at the read sites.
	return run_angel_equity_pct + run_equity_pct


func get_total_raised() -> int:
	# Every dollar raised this run, across rounds. Same reasoning as above.
	return run_angel_amount + run_investment_amount


func record_angel_round(equity_pct: int, amount: int) -> void:
	# The single write seam for the angel slice (WRITE-THROUGH LAW). Emits, because the
	# Finance cap-table bar otherwise repaints only as a SIDE EFFECT of the cash movement
	# that happens to accompany a round — true for the angel seam by construction, false
	# for the first equity change that moves no cash.
	run_angel_equity_pct = equity_pct
	run_angel_amount = amount
	EventBus.equity_changed.emit(get_investor_equity_pct())


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


## Day N → the month word in the CURRENT locale ("Ocak" / "January"). Kept as a seam because
## callers pass a day, not a month; the words themselves come from Fmt.
func month_name_for_day(for_day: int = -1) -> String:
	return Fmt.month_name(int(get_date_dict(for_day).month))


func months_elapsed_since(start_day: int) -> int:
	# Whole CALENDAR months between start_day and today (0 on the same month), using
	# get_date_dict — NOT the economy constant DAYS_PER_MONTH. The two disagree by design
	# (real 28/30/31-day months vs a flat 30), so a tenure line that prints a month NAME
	# must count with the same calendar that produced the name or the two contradict.
	# Negative when start_day is in a later month (a hire whose first day has not arrived).
	var a: Dictionary = get_date_dict(start_day)
	var b: Dictionary = get_date_dict()
	return (int(b.year) * 12 + int(b.month)) - (int(a.year) * 12 + int(a.month))

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
		# The run's RNG seed. Absent from this ledger until now, which is audit S2-40: the
		# seed existed but was unobtainable, so a reproducible-looking bug across four live
		# runs could not actually be reproduced. Read-only here, like every other key.
		"seed": run_seed,
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
		# live term sheets at the moment of reading — the soft-cap paper names an unsigned
		# offer left on the table (Calibration Round A §2; VC_PITCH_DESIGN ledger 16)
		"unsigned_sheets": active_sheets.size(),
		# calendar-month ledger digest (Calibration Round A §3/§9)
		"months_closed": month_history.size(),
		"profit_streak": get_profitable_month_streak(),
		"pushes_attempted": run_pushes_attempted,
		"pushes_won": run_pushes_won,
		# signed term sheet (0 unless series_a_close). These three stay SERIES-A-ONLY on
		# purpose: the ending newspaper composes them into one sentence ("at valuation X,
		# raised Y, gave Z%"), and folding the angel round into them would make that
		# sentence false — the angel money was not raised at that valuation.
		"investment_amount": run_investment_amount,
		"valuation_m": run_valuation_m,
		"equity_pct": run_equity_pct,
		"board_seats": run_board_seats,
		"board_veto": run_board_veto,
		# the angel round, and the run-wide totals the cap table actually owes
		"angel_amount": run_angel_amount,
		"angel_equity_pct": run_angel_equity_pct,
		"investor_equity_pct": get_investor_equity_pct(),
		"total_raised": get_total_raised(),
		# scandals (reserved — read 0 today)
		"scandals_total": run_scandals_total,
		"scandals_managed": run_scandals_managed,
	}


func _emit_runway() -> void:
	EventBus.runway_recalculated.emit(get_runway_months())


# --- Run initialization (single seam: onboarding Confirm + F12 debug skip) ---

func initialize_run(payload: Dictionary) -> void:
	# Called once when the onboarding flow confirms (or F12 skip fires) — AND on every
	# load, which is why there is no second init path.
	#
	# Direct field assignment — GameShell has not been instanced yet, so no
	# listeners exist on EventBus and signals would land in the void. Setters
	# (which emit) are reserved for in-game mutation when listeners are wired.
	#
	# THAT ASSUMPTION HOLDS ON THE LOAD PATH TOO, and deliberately: main.gd tears the shell
	# down BEFORE calling SaveManager.apply_loaded_state, so the restore below runs into the
	# same empty-listener world onboarding does. Do not "upgrade" the restore to setters —
	# it would be a 70-signal broadcast storm into nothing, and the one thing it could
	# achieve (repainting the UI) is what remounting the shell already does.
	#
	# TWO OPTIONAL PAYLOAD KEYS:
	#   "seed"    : int        — the run's RNG seed. A FRESH run generates and records one
	#                            here (see _generate_seed); a LOAD passes the saved value.
	#   "restore" : Dictionary — a save's state block, applied OVER the defaults set below.
	#                            Present ⇒ this is a load: the roster and the month-1 ledger
	#                            come from the save, so the seeding tail is skipped.
	var restore_block: Dictionary = _game_state_block(payload.get("restore", {}))
	var is_restore: bool = not restore_block.is_empty()

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
	brand_low_since_day = -1
	month_history.clear()   # the calendar-month ledger (accruals reset by MonthSummarySystem.snapshot below)

	# Finance surface state (Finance Tab v1). Day-1 point seeded here so the curve
	# renders a valid single sample before the first daily tick.
	cash_history = [{"day": 1, "cash": cash}]
	transactions = []
	sales_log = []

	# Month-End Summary + run counters reset (Spec 3; month_ledger snapshot
	# happens at the END of this function — it needs the roster in place)
	month_highlight_text = ""
	month_highlight_priority = -1
	run_customers_signed = 0
	run_customers_lost = 0
	run_customers_expanded = 0
	run_prospects_spawned = 0
	b2b_signed_company_names = []
	cs_escalation_days.clear()
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
	run_angel_amount = 0
	run_angel_equity_pct = 0
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

	# HR Core state. Dicts via .clear() in case a system cached the reference (same
	# reasoning as the VC block). NOTE: HRSystem.reset() deliberately does NOT run here —
	# it seeds the HR RNG from run_seed and may set flags, and both of those happen further
	# down. It is called after the seed block instead.
	hr_search.clear()
	hr_overtime.clear()
	hr_last_overtime_day = 0
	hr_last_positive_event_day = 0
	news_feed.clear()

	# Flags survive nothing: fresh run = fresh world-state (hardening for any
	# future in-place restart; harmless in a fresh process).
	flags.clear()

	# Origin flags — set AFTER the clear or they would be wiped. RESERVED:
	# nothing consumes origin_press_sympathy / origin_low_capital yet; future
	# press/network systems read them (FounderConstants.ORIGINS reserved_flags).
	for origin_flag in FounderConstants.origin_by_id(origin).get("reserved_flags", []):
		set_flag(String(origin_flag), true)

	# --- RESTORE POINT. Everything above is the fresh-run baseline; a load now writes the
	# saved values over it, field by field, and anything the save does not carry keeps the
	# baseline (that is the whole forward-compat story — no migration code, just defaults).
	# run_seed is part of the block, so the line below reads the SAVED seed on a load and
	# the payload/generated one on a fresh run.
	if is_restore:
		SaveCodec.apply_game_state(restore_block)

	# Seeded RNG per TECH_SPEC §10.4. A fresh run GENERATES and RECORDS its seed from birth
	# (it used to be Time.get_ticks_msec() assigned here and never surfaced anywhere — audit
	# S2-40: four live runs produced a "reproducible" bug that could not be reproduced,
	# because the seed was unobtainable). It now rides in get_run_ledger() and in every save.
	# 0 is treated as ABSENT, not as a seed. run_seed's own declaration documents "0 =
	# unseeded", and a caller that passes the key but reads it out of a save block missing
	# the field would otherwise hand over a literal 0 and pin every run to one sequence.
	var seed_in: int = int(payload.get("seed", 0))
	if seed_in == 0:
		seed_in = int(restore_block.get("run_seed", 0))
	if seed_in == 0:
		seed_in = _generate_seed()
	run_seed = seed_in
	# The GLOBAL generator is now a BACKSTOP, not the game's RNG: the four real draw sites
	# moved to RngStreams (events / skill / hr_morale), which is what makes a save resumable
	# — Godot exposes no way to read the global generator's position. Kept seeded so any
	# future bare randf() is at least deterministic for the run rather than wild.
	seed(run_seed)
	RngStreams.reseed(run_seed)

	# Saat senkronu: current_hour'u doğrudan yazdık — TimeManager'ın accumulator'ı
	# da aynı saate kilitlenmeli, yoksa ilk gün saatlik tik atmaz ("ilk gün ölü").
	# On a load current_hour came from the save, so the same rule applies for the same reason.
	TimeManager.sync_to_current_hour()

	# HR sub-system static state (the HR RNG included) — MUST come after run_seed is
	# assigned and after flags.clear(), or the HR stream would be seeded from the previous
	# run's value and anything it flags would be wiped a moment later. A fresh process
	# would not need this, but the debug onboarding re-trigger reuses the process.
	HRSystem.reset()

	if is_restore:
		# The roster, the month-1 ledger and run_hires all come from the save. Seeding a
		# mentor + a fresh founder here would collide with the restored records (add() would
		# drop char_founder on an id collision and leave the SAVED founder in place while
		# still counting a hire), and MonthSummarySystem.snapshot() would overwrite the
		# restored month_ledger with a day-N baseline — the month modal would then report
		# deltas against the moment of loading instead of against the start of the month.
		return

	# Roster: ensure mentor exists, add founder
	CharacterRegistry.ensure_mentor()
	var founder := _build_founder(payload)
	CharacterRegistry.add(founder)

	# Month-1 ledger snapshot — AFTER the roster so the team count is real.
	# (The founder add above must not count as a "hire": category is "founder".)
	MonthSummarySystem.snapshot()
	run_hires = 0  # belt-and-braces: whatever roster seeding did, hires start at 0


func _game_state_block(restore: Variant) -> Dictionary:
	# Accepts either the whole save state block ({game_state, registries, systems}) or a
	# bare GameState field dict, so a caller cannot get it subtly wrong in a way that loads
	# a run with every field silently at its default.
	if typeof(restore) != TYPE_DICTIONARY:
		return {}
	var d: Dictionary = restore as Dictionary
	if d.has("game_state") and typeof(d["game_state"]) == TYPE_DICTIONARY:
		return d["game_state"] as Dictionary
	return d


func _generate_seed() -> int:
	# Wide entropy, bounded to stay EXACT through JSON. Save files are JSON (TECH_SPEC
	# §10.1) and JSON numbers are IEEE doubles, so anything past 2^53 would come back
	# rounded — a save that reproduces a DIFFERENT run than the one it recorded. 2^52 keeps
	# a comfortable margin and still leaves 4.5 quadrillion distinct runs.
	# randi() reads the engine's own startup-randomised global stream; this is the one place
	# the game still draws from it, and it happens exactly once per run.
	const SEED_CEILING := 1 << 52
	return absi((randi() << 21) ^ (randi() << 3) ^ int(Time.get_ticks_usec())) % SEED_CEILING


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
		# S2-42: the default founder name is COPY, not data — it must not be baked into
		# a persisted field in one language. Rendered from the glossary term instead.
		display_name = TranslationServer.translate("HR_ROLE_FOUNDER")

	var f := Character.new()
	f.id = "char_founder"
	f.character_name = display_name
	f.role = HRConstants.ROLE_FOUNDER   # typed id; label "Kurucu" via HRConstants.role_label
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
