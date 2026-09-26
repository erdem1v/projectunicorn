extends Node

# Core run state. Every `var` here is save schema (SaveCodec walks them) and its default is the
# migration for an older save. Mutations from outside go through the setters/seams below.

const DAYS_PER_MONTH := 30  # the monthly → daily economy conversion; FinanceSystem reads it too

# Day 1 = Thu Jan 1, 2026. get_date_dict() is the seam; Godot Time computes the weekday.
const START_DATE := {"year": 2026, "month": 1, "day": 1}

# --- Run identity ---
var company_name: String = "Unicorn Inc."
var origin: String = "self_made"      # "self_made" | "heir" | "corporate_refugee" (demo: self_made only)
var subgenre: String = "ai"           # "ai" | "saas" | "social" (demo: ai|saas only)
var logo_style: String = "minimalist" # "minimalist" | "tech" | "playful" | "serious"
var slogan: String = ""               # Optional free text — may be empty
var founder_name: String = ""         # Player's name; "" means the founder Character defaults to "Founder"
var founder_portrait: String = ""     # Portrait id (e.g. "founder_03"); art via FounderConstants.portrait_path()
# THE RNG SEED, 0 = unseeded. Not the funding round (run_seed_amount / run_seed_equity_pct).
var run_seed: int = 0

# --- Phase 1 — Bootstrap defaults ---
var cash: int = FounderConstants.STARTING_CASH
var mrr: int = 0
var daily_burn: int = FinanceSystem.starting_daily_burn()   # FinanceSystem owns the categorized breakdown
var brand: int = 50
var reputation: int = 0
var day: int = 1
var current_hour: int = 9        # 0-23. Day 1 starts at 09:00
var phase: int = 1               # 1=Bootstrap, 2=Traction, 3=Series A Hunt

# --- World-state flags (sparse, content-defined keys; no EventBus emission) ---
var flags: Dictionary = {}

# --- FLAG TYPING (save-schema constraint) ---
# Flag readers disagree on typing (bool()/int() coercion vs plain truthiness) and a JSON round
# trip re-types every number to float, so a flag needs a declared type for a save to restore it
# faithfully. SaveCodec coerces every restored flag through flag_type_for(); set_flag warns in
# debug builds when a live write disagrees. A key absent from both tables is legal and
# round-trips best-effort.
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
	"creation_draft": TYPE_DICTIONARY,   # draft guard: {step, market, type, features, name}
	"product_path_frank_seen": TYPE_BOOL,
	# --- Ürün rev 6.1 · HAT MODELİ ve DESTEK (§12, §8, §9, §10) ---
	# mvp_components (düz özellik listesi) Satış ve söz kaydı okuduğu için duruyor.
	"mvp_line_tiers": TYPE_DICTIONARY,          # {hat kimliği: 0|1|2|3} — §12.1
	# §11.2: çarpan KADEME başına saklanır, her kademe yayınlandığı sürümün cilasını taşır.
	# Kaybolursa her geçmiş sürüm bugünkü tur sayısıyla yeniden okunur.
	"mvp_step_realization": TYPE_DICTIONARY,    # {kademe kimliği: çarpan}
	"mvp_hidden_lines": TYPE_ARRAY,             # Ar-Ge'nin açtığı gizli hatlar — §12.1
	"mvp_design_turns": TYPE_INT,               # son sürümde tamamlanan TASARIM turu — §5
	# --- DESTEK: iki sayaç, mühürlü adlar (§8.1) ---
	"mvp_reports_incoming": TYPE_INT,           # GELEN BİLDİRİM
	"mvp_reports_progress": TYPE_FLOAT,         # kesirli birikim; tam sayıya taşınca sayaç artar
	"mvp_bugs_confirmed": TYPE_INT,             # DOĞRULANMIŞ HATA
	"mvp_validation_progress": TYPE_FLOAT,      # §8.2 doğrulama kesri
	"mvp_fix_run_active": TYPE_BOOL,            # §8.4 düzeltme koşusu
	"mvp_fix_run_fixed": TYPE_INT,              # koşuda şimdiye dek çözülen
	"mvp_fix_run_progress": TYPE_FLOAT,
	# --- §9 canlı akış ---
	# SÜRÜM yaşı (§17): mvp_launch_day ilk yayında bir kez damgalanır, bu her yayında yeniden.
	"mvp_version_launch_day": TYPE_INT,
	"mvp_interest": TYPE_FLOAT,                 # her yayında 100'e tazelenir, yarı ömür 30 gün
	"mvp_new_code_effort": TYPE_FLOAT,          # §9 yeni-kod terimi; τ=21 günde söner
	# --- §10 altyapı ---
	"mvp_infra_provider": TYPE_STRING,          # sağlayıcı kimliği
	"mvp_infra_units": TYPE_INT,                # satın alınan kapasite birimi
	# --- B2C economy ---
	# FLOAT so the hourly tick's slow erosion survives instead of rounding to zero each hour.
	"b2c_audience": TYPE_FLOAT,
	"b2c_price": TYPE_INT,
	"b2c_paid_tier_open": TYPE_BOOL,
	# --- sales / customer desks ---
	"cs_throughput_progress": TYPE_FLOAT,
	"sales_faucet_progress": TYPE_FLOAT,       # §3 — sub-lead inflow accumulator
	"sales_price_stance": TYPE_STRING,         # §7.5 — the SINGLE B2B price source
	"sales_meeting_used_day": TYPE_INT,        # §5.0 — the day the daily right was spent
	"sales_meeting_active": TYPE_BOOL,         # §5.0 — the founder is at a table (busy gate)
	"sales_inner_voice_used": TYPE_INT,        # §5.1.1 — the run's inner-voice budget
	"sales_open_pitch_promise": TYPE_STRING,   # §6 — the ONE open pitch promise, by account
	"sales_open_pitch_feature": TYPE_STRING,   # §6 — and the feature it named
	"sales_last_signed_star": TYPE_INT,        # §14 — sales.last_signed_star()
	"sales_weekly_anchor_day": TYPE_INT,       # §7.3 — the weekly summary's window start
	"sales_weekly_closes": TYPE_INT,           # §7.3 — closes inside that window
	# --- phase gate / endgame / VC ---
	# How many times the founder has said "not yet"; the gate card's escalating body reads it.
	"gate_declines": TYPE_INT,
	"pitch_prep_active": TYPE_BOOL,
	"pivot_offer_made": TYPE_BOOL,
	"acquisition_offer_made": TYPE_BOOL,
	"acquisition_offer_rejected": TYPE_BOOL,
	# --- angel round (Frank's seed) + the locked hard path ---
	"angel_seed_accepted_day": TYPE_INT,
	# RESERVED, no writer: the guaranteed-false gate behind "REDDET · ZOR MOD".
	"hard_mode_unlocked": TYPE_BOOL,
	# --- origin reserves + UI snooze ---
	"origin_press_sympathy": TYPE_BOOL,
	"origin_low_capital": TYPE_BOOL,
	"finance_runway_warn_snooze_until_day": TYPE_INT,
	# --- debug force flags (smoke harness) ---
	"debug_skill_force": TYPE_STRING,
	"debug_hr_force": TYPE_STRING,
}

# Dynamic key families (one flag per entity id). None of the prefixes overlap.
const FLAG_TYPE_PREFIXES := {
	"b2b_broke_": TYPE_BOOL,                    # B2BSalesSystem credibility latch, per customer id
	"hr_manual_leave_": TYPE_BOOL,              # HRMoraleSystem manual-vacation marker, per character id
	"bug_count_at_bugfix_start_": TYPE_INT,     # ProductSystem beta-phase baseline, per build id
}

# --- Endgame state ---
var run_active: bool = true            # false = terminal reached; tick loop halts
var ending_id: String = ""             # one of EndingsSystem.ENDINGS keys once run ends
var phase_gate_ready: bool = false     # ratchet latch — cleared only by advance_phase()
var pending_next_phase: int = 0        # 0 = no open gate
var series_a_closed: bool = false
var shutter_days_left: int = -1        # -1 inactive; SHUTTER_DAYS..0 = Kepenk counter
var vc_rejections: int = 0             # closed pitch tables
var pivot_used: bool = false           # true → VC path permanently closed
var active_scandal: bool = false           # RESERVED — no scandal system yet; debug-settable
var unmanaged_major_scandal: bool = false  # RESERVED
var brand_low_since_day: int = -1      # brand-collapse 30-day window anchor

# --- Finance surface state ---
# Daily {day, cash} samples for the cash curve. Single writer: FinanceSystem.daily_tick via
# append_cash_sample. Intra-day one-time costs land in the next day's point and in `transactions`.
const CASH_HISTORY_CAP := 760          # soft cap 730 days + headroom; oldest dropped
var cash_history: Array = []           # [{day: int, cash: int}]
# Signed money-event log (negative = spend). Sole append point: FinanceSystem.record_transaction.
# Labels stored RAW; FinanceSystem.one_time_label_display maps registered ids for display.
const TRANSACTIONS_CAP := 50
var transactions: Array = []           # [{day: int, label: String, amount: int}]
# What the sales/customer desks did on their own, so the player can reconstruct a cause the
# ticker has scrolled past. Sole append point: SalesSystem.record_sales_event.
const SALES_LOG_CAP := 12
var sales_log: Array = []              # [{day, kind, actor, company, mrr}]

# --- Month-End Summary state ---
# Month-start snapshot {start_day, mrr, cash, employees, brand} plus the OPEN month's accruals
# (income / expense / red_days). Written only by MonthSummarySystem.snapshot() and the accrue_*
# seams; "what changed this month?" comes from here, never from the run counters.
var month_ledger: Dictionary = {}
# Closed calendar months, oldest → newest. Sole writer: push_month_close (MonthSummarySystem,
# on the 1st, before the recap emit). Entry, ALL INT (SaveCodec restores ints; compute ratios
# at read time): {start_day, end_day, mrr_close, income, expense, net, red_days}.
# One-time INCOME (the angel cheque) is financing and is not accrued.
const MONTH_HISTORY_CAP := 12
var month_history: Array[Dictionary] = []
# "AYIN OLAYI": systems submit via submit_month_highlight(); cleared by snapshot().
var month_highlight_text: String = ""
var month_highlight_priority: int = -1

# --- Run-cumulative counters (the newspaper ending screen; read via get_run_ledger) ---
var run_customers_signed: int = 0      # SalesSystem.add_b2b_customer
var run_customers_lost: int = 0        # churn_customer modifier, B2B branch
var run_customers_expanded: int = 0    # B2BSalesSystem.expand
# MONOTONIC: makes prospect ids unique (the live pool size shrinks and would collide).
var run_prospects_spawned: int = 0     # PitchSystem.spawn_prospect
# Every company name ever SIGNED this run; survives churn so cold prospecting can never
# re-offer a former customer. Writer: SalesSystem.add_b2b_customer.
var b2b_signed_company_names: Array[String] = []
# Day stamps of CS escalations that reached the player, newest last: a rolling window for the
# company-wide weekly ceiling (_escalate_stale bypasses the per-account budgets).
var cs_escalation_days: Array[int] = []
var run_hires: int = 0                 # CharacterRegistry.add, category "employee"

# --- SATIŞ rev 6 §13 · the run records the module owns ------------------------
# Sole writer: SalesLedger.
# §5.2 — the loss log. DELIBERATELY UNPRUNED: a buffer for the demand generator; a trimmed
# buffer silently answers a question nobody asked. Rows are {day, account, reason, target}.
var sales_loss_log: Array = []
# §5.2 / §9 — per-company memory, keyed by COMPANY NAME so it survives the prospect being
# removed: {loss_reason, loss_target, loss_count, loss_day, insulted, insult_day, promise_broken}.
var sales_account_memory: Dictionary = {}
# §4 — companies held out of the faucet until a day: {company_name: unlock_day}.
var sales_return_locks: Dictionary = {}
# §7.2.2 — per-rep working band cap {character_id: star}; an absent key means "Kendi ligi".
var sales_band_caps: Dictionary = {}
# §11.2 — storylet repeat memory {row_id: times spoken}.
var sales_line_memory: Dictionary = {}

# B2B pitch customer-rep portrait rotation over the non-selected founder portraits.
var b2b_rep_portrait_rotation_index: int = 0
var b2b_last_rep_portrait: String = ""         # last face shown — no consecutive repeat
var run_departures: int = 0            # CharacterRegistry.remove, category "employee"
var run_scandals_total: int = 0        # RESERVED — no scandal system yet; debug-settable
var run_scandals_managed: int = 0      # RESERVED
var run_pushes_attempted: int = 0      # Term Sheet table push()
var run_pushes_won: int = 0            # successful pushes
var run_peak_mrr: int = 0              # latched in set_mrr
# Signed Series A terms, persisted at VCPitchSystem.sign_table. 0 unless a sheet was signed.
var run_investment_amount: int = 0     # money raised, dollars
var run_valuation_m: int = 0           # pre-money valuation, millions
var run_equity_pct: int = 0            # equity given == signed dilution_pct
var run_board_seats: int = 0
var run_board_veto: bool = false

# Frank's angel round, SEPARATE from the Series A terms above: those are written by plain
# assignment at signing and would erase the angel slice (and light ODA's "İlk Yatırım" diploma,
# which reads run_investment_amount). Readers compose totals via get_investor_equity_pct /
# get_total_raised, never by summing raw fields.
var run_angel_amount: int = 0
var run_angel_equity_pct: int = 0

# --- VC Pitch / Series A Hunt state. VCPitchSystem writes; EndingsSystem reads
# active_sheets/pending_meeting for the cascade defer. Meeting-LOCAL state lives in
# VCPitchSystem statics and is never saved. ---
var vc_states: Dictionary = {}         # vc_id -> {status, callback, pending_sheet, meeting_count, ...}
var active_sheets: Array = []          # live TermSheet resources (max PitchConstants.MAX_SHEETS)
var pending_meeting: Dictionary = {}   # {vc_id, day} — one at a time; empty = none
var prep: Dictionary = {}              # {vc_id, focus, done} — one prep per scheduled meeting
var run_pitches: int = 0               # completed meetings
var run_sheets_won: int = 0            # sheets granted
var vc_meeting_cancel_day: int = -1    # the day a booked meeting was cancelled; no new booking that day
var vc_last_meeting_rejected: bool = false  # did the last FINISHED Series A meeting end in a rejection?
var vc_frank_cold_shown: Array = []    # fund ids whose cold-exit Frank line has been shown

# --- Seed round (GDD v2 ch. 09 §3). Sole writer SeedRoundSystem.
# The offer is NOT in active_sheets on purpose: its readers would count it as a Series A sheet
# (leverage notch, MAX_SHEETS, unsigned_sheets, the never-expiring cascade defer).
var seed_door_open_day: int = -1       # ratchet, -1 = the door never opened this run
var seed_pitch_used: bool = false      # the run's ONE seed meeting has been spent
var seed_sheet: TermSheet = null       # the unsigned seed offer; no expiry
var seed_lead: String = ""             # vc_id that led the round; "" = no seed taken
var seed_closed_day: int = -1          # signing day — the growth expectation's clock origin
# Separate from the Series A terms for the same reason as the angel pair.
var run_seed_amount: int = 0
var run_seed_equity_pct: int = 0

# --- The Series A decision, and whether it was FACED (GDD v2 ch. 13 §1) ---
# EndingsSystem.profitability_signal reads the flag; the buyout card reads the REASON.
var faced_series_a: bool = false
var faced_series_a_by: String = ""     # "declined" | "walked" | "door_open" | "fund_walked"
var acq_road_over_day: int = -1        # day the Series A road closed; the buyout window's origin
# The day the bootstrap milestone paper opened, -1 before (EndingsSystem.ending_mode). Keeps the
# daily scan from re-opening it and lifts the day-730 soft cap.
var bootstrap_milestone_day: int = -1

# --- HR Core state (the owning system is the sole writer) ---
var hr_search: Dictionary = {}          # HRSearchSystem: {state, role, band, seed, started_day, arrival_day, files}

# --- §8.1 ÇALIŞMA SAATLERİ: şirket ve grup kapsamları ---
# Üçüncü kapsam Character.work_hours_override. Tek çözümleyici hr.work_hours(kişi) (§15.2).
# BAŞLANGIÇ SAATİ YALNIZ ŞİRKET KAPSAMINDA: ofis tek saatte açılır, grup ve çalışan yalnız SÜREYİ değiştirir.
var company_start_hour: int = 9         # §8.1 varsayılan 09:00, aralık 06:00-11:00
var company_work_hours: int = 8         # §8.1 şirket tabanı
# Yalnız İSTİSNASI OLAN grup (§15). Anahtar HRConstants.ROSTER_GROUPS üyesi, değer 5..11.
var group_work_hours_override: Dictionary = {}

# --- News feed state (sole writer NewsFeedSystem). JSON-primitive: {used_sektor, reshuffles,
# counts, biz_buffer, biz_dropped, recent_rivals, stream}. `biz_dropped` counts milestone lines
# the ≤20 % "biz" quota refused (calibration data). ---
var news_feed: Dictionary = {}

# --- Setters (the only way to mutate from outside) ---

func set_cash(value: int) -> void:
	cash = value
	EventBus.cash_changed.emit(cash)
	_emit_runway()

func set_mrr(value: int) -> void:
	mrr = value
	run_peak_mrr = maxi(run_peak_mrr, value)
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
	# Placeholder range; the bounds await a design decision.
	reputation = clampi(value, -10, 100)
	EventBus.reputation_changed.emit(reputation)

func advance_day() -> void:
	day += 1
	EventBus.day_advanced.emit(day)

func set_current_hour(value: int) -> void:
	current_hour = clampi(value, 0, 23)
	EventBus.hour_changed.emit(current_hour)

func set_subgenre(value: String) -> void:
	# Written by ProductSystem.start_build; readers read lazily, so no signal.
	subgenre = value

func set_phase(value: int) -> void:
	# Save-restore / debug only. Gameplay goes through advance_phase().
	phase = clampi(value, 1, 3)
	EventBus.phase_changed.emit(phase)


func advance_phase() -> void:
	# THE gameplay write seam for phase: the Frank transition card's "advance_phase" modifier.
	if not phase_gate_ready or pending_next_phase <= phase:
		push_warning("[GameState] advance_phase without an open gate — ignored")
		return
	phase = clampi(pending_next_phase, 1, 3)
	phase_gate_ready = false
	pending_next_phase = 0
	submit_month_highlight(
		TranslationServer.translate("MONTH_HL_PHASE_ADVANCED").format(
			{"phase": phase_display_name(phase)}), 80)
	EventBus.phase_changed.emit(phase)


## Phase display name. Proper nouns, identical in both languages. Out-of-range clamps.
func phase_display_name(p: int) -> String:
	var names := ["Bootstrap", "Traction", "Series A Hunt"]
	return names[clampi(p - 1, 0, names.size() - 1)]


func set_run_active(value: bool) -> void:
	# No signal: run_ended carries the news with full context.
	run_active = value


func set_shutter_days_left(value: int) -> void:
	shutter_days_left = value
	EventBus.shutter_changed.emit(shutter_days_left)


func submit_month_highlight(text: String, priority: int) -> void:
	# Higher priority replaces lower; first-come wins ties.
	if priority > month_highlight_priority:
		month_highlight_text = text
		month_highlight_priority = priority

# --- Flag accessors ---

func set_flag(key: String, value: Variant) -> void:
	if OS.is_debug_build():
		_warn_on_flag_type_drift(key, value)
	flags[key] = value


## Declared Variant type of a flag, or TYPE_NIL when unregistered. SaveCodec's single oracle.
func flag_type_for(key: String) -> int:
	if FLAG_TYPES.has(key):
		return int(FLAG_TYPES[key])
	for prefix in FLAG_TYPE_PREFIXES:
		if key.begins_with(prefix):
			return int(FLAG_TYPE_PREFIXES[prefix])
	return TYPE_NIL


func _warn_on_flag_type_drift(key: String, value: Variant) -> void:
	# A write whose type differs from the declaration saves one type and loads another.
	# int↔float is tolerated: every numeric reader casts.
	var declared: int = flag_type_for(key)
	var actual: int = typeof(value)
	if declared == TYPE_NIL or actual == declared:
		return
	if actual in [TYPE_INT, TYPE_FLOAT] and declared in [TYPE_INT, TYPE_FLOAT]:
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

## NET runway (revenue-aware), the player's lens; VC surfaces use GROSS. INF when net flow ≥ 0.
func get_runway_months() -> float:
	return runway_months_for(cash, get_net_daily_flow())


## NET runway for HYPOTHETICAL cash and flow (a hire preview moves both). Pure arithmetic;
## a caller that wants to floor a negative month count does so itself.
func runway_months_for(cash_value: int, daily_net: int) -> float:
	if daily_net >= 0:
		return INF
	return float(cash_value) / float(-daily_net) / float(DAYS_PER_MONTH)

func append_cash_sample(sample_cash: int) -> void:
	# Once per day, before FinanceSystem's set_cash, so the cash_changed repaint reads a fresh buffer.
	cash_history.append({"day": day, "cash": sample_cash})
	while cash_history.size() > CASH_HISTORY_CAP:
		cash_history.pop_front()


# --- Calendar-month ledger seams ---

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
## never counts.
func get_mrr_growth_streak(min_pct: int) -> int:
	var streak: int = 0
	for i in range(month_history.size() - 1, 0, -1):
		var prev: int = int(month_history[i - 1].get("mrr_close", 0))
		var cur: int = int(month_history[i].get("mrr_close", 0))
		if prev <= 0 or cur * 100 < prev * (100 + min_pct):
			break
		streak += 1
	return streak


## Sentinel for get_mom_growth_avg_pct: fewer closed months than the window asks for. Sorts
## below every calibration cut, so a caller that forgets to test it lands on the pessimistic branch.
const GROWTH_AVG_UNKNOWN := -9999


## Mean month-over-month MRR growth, in percent, over the last `months` closes. An average, not
## a streak: one flat month is forgiven. Needs `months` + 1 closes; a zero or negative previous
## close contributes 0.
func get_mom_growth_avg_pct(months: int) -> int:
	if months <= 0 or month_history.size() < months + 1:
		return GROWTH_AVG_UNKNOWN
	var total: float = 0.0
	for i in range(month_history.size() - months, month_history.size()):
		var prev: int = int(month_history[i - 1].get("mrr_close", 0))
		var cur: int = int(month_history[i].get("mrr_close", 0))
		if prev > 0:
			total += float(cur - prev) * 100.0 / float(prev)
	return int(round(total / float(months)))


## Consecutive "Artıda" closes, newest backwards: net > 0 AND red_days == 0.
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
	return cash_history.duplicate()


## Kurucunun başlangıç alanı: Ürün · Tasarım · Yazılım içinde EN YÜKSEK olanı. Beraberlikte
## liste sırası; deterministik olmalı, smoke pinli seed'le kadro karşılaştırıyor.
func _founder_start_area(stats: Dictionary) -> String:
	var best: String = HRConstants.AREA_ENGINEERING
	var best_v: int = -1
	for area_key in [HRConstants.AREA_PRODUCT, HRConstants.AREA_DESIGN, HRConstants.AREA_ENGINEERING]:
		var v: int = int(stats.get(String(area_key), 0))
		if v > best_v:
			best_v = v
			best = String(area_key)
	return best


## THE cap-table total: angel + seed + signed Series A. A future round is one summand here.
func get_investor_equity_pct() -> int:
	return run_angel_equity_pct + run_seed_equity_pct + run_equity_pct


## Every dollar raised this run, across rounds.
func get_total_raised() -> int:
	return run_angel_amount + run_seed_amount + run_investment_amount


## The single write seam for the angel slice.
func record_angel_round(equity_pct: int, amount: int) -> void:
	run_angel_equity_pct = equity_pct
	run_angel_amount = amount
	EventBus.equity_changed.emit(get_investor_equity_pct())


## The single write seam for the seed slice. The lead is recorded here, with the money: it
## outlives the sheet (cleared on signing) and vc_states (reachability, not history), and the
## Series A warmth bonus and the buyout card read it.
func record_seed_round(equity_pct: int, amount: int, vc_id: String) -> void:
	run_seed_equity_pct = equity_pct
	run_seed_amount = amount
	seed_lead = vc_id
	EventBus.equity_changed.emit(get_investor_equity_pct())


## Record that the Series A decision was FACED, and by which route (ch. 13 §1). UPGRADE-ONLY:
## a door left open and a table walked later must read as walked, because the buyout card
## decides from this whether a buyer has a reason to call.
func mark_faced_series_a(reason: String) -> void:
	const RANK := {"": 0, "door_open": 1, "declined": 2, "walked": 2}
	if int(RANK.get(reason, 0)) <= int(RANK.get(faced_series_a_by, 0)) and faced_series_a:
		return
	faced_series_a = true
	faced_series_a_by = reason


## founder.role_stats[skill_name], 0 when missing. A pre-rename key is a stale caller and errors.
func get_founder_skill(skill_name: String) -> int:
	if skill_name in FounderConstants.OLD_SKILLS:
		push_error("[GameState] read of renamed founder skill '%s' — see FounderConstants SKILL-RENAME ledger" % skill_name)
	var founder: Character = CharacterRegistry.get_founder()
	if founder == null:
		return 0
	return int(founder.role_stats.get(skill_name, 0))


## Run day N → Godot Time datetime dict {year, month, day, weekday, …}. THE day→calendar
## conversion: month boundaries come from here (real 28/30/31-day months), never from the
## economy constant DAYS_PER_MONTH. Default: the current day.
func get_date_dict(for_day: int = -1) -> Dictionary:
	var d: int = day if for_day < 0 else for_day
	var anchor_unix: int = int(Time.get_unix_time_from_datetime_dict(START_DATE))
	return Time.get_datetime_dict_from_unix_time(anchor_unix + (d - 1) * 86400)


## Is run day N a weekday? (Godot weekday: 0 = Sunday … 6 = Saturday.)
func is_business_day(for_day: int) -> bool:
	var wd: int = int(get_date_dict(for_day).weekday)
	return wd != 0 and wd != 6


## Weekdays in the half-open run-day interval (from_day, to_day]; negative when to_day is
## earlier. Whole weeks are counted arithmetically.
func business_days_between(from_day: int, to_day: int) -> int:
	if to_day < from_day:
		return -business_days_between(to_day, from_day)
	var weeks: int = int(float(to_day - from_day) / 7.0)
	var count: int = weeks * 5
	for d in range(from_day + weeks * 7 + 1, to_day + 1):
		if is_business_day(d):
			count += 1
	return count


## The run day on which the n-th weekday after from_day falls (n >= 1).
func add_business_days(from_day: int, n: int) -> int:
	var d: int = from_day
	var left: int = maxi(n, 0)
	while left > 0:
		d += 1
		if is_business_day(d):
			left -= 1
	return d


## The newspaper ending screen's single read seam: the run_* counters plus derived live values.
func get_run_ledger() -> Dictionary:
	var start: Dictionary = get_date_dict(1)
	return {
		# timeline
		"day": day,
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
		# Population figures mean different things per market: a consumer run reports AUDIENCE
		# and PAYING USERS, never an account count (ch. 13 §2).
		"market": String(get_flag("mvp_market_type", "b2c")),
		"audience": int(round(SalesSystem.b2c_audience())),
		"paying_users": SalesSystem.b2c_paying_users(),
		# customers (B2B discrete sign/churn; B2C is one aggregate record)
		"customers_active": CustomerRegistry.get_active().size(),
		"customers_signed": run_customers_signed,
		"customers_lost": run_customers_lost,
		"customers_expanded": run_customers_expanded,
		# team (founder + mentor excluded from get_employees)
		"employees": CharacterRegistry.get_employees().size(),
		"hires": run_hires,
		"departures": run_departures,
		# product
		"product_version": int(get_flag("mvp_version", 0)),
		"product_ships": (get_flag("mvp_version_history", []) as Array).size(),
		# fundraising
		"pitches": run_pitches,
		"sheets_won": run_sheets_won,
		"vc_rejections": vc_rejections,
		# live term sheets now: the soft-cap paper names an unsigned offer left on the table
		"unsigned_sheets": active_sheets.size(),
		# calendar-month ledger digest
		"months_closed": month_history.size(),
		"profit_streak": get_profitable_month_streak(),
		"pushes_attempted": run_pushes_attempted,
		"pushes_won": run_pushes_won,
		# Signed Series A terms ONLY: the paper composes them into one sentence ("at valuation X,
		# raised Y, gave Z%") that the angel and seed money were not raised at.
		"investment_amount": run_investment_amount,
		"valuation_m": run_valuation_m,
		"equity_pct": run_equity_pct,
		"board_seats": run_board_seats,
		"board_veto": run_board_veto,
		"angel_amount": run_angel_amount,
		"angel_equity_pct": run_angel_equity_pct,
		"seed_lead": seed_lead,
		"seed_amount": run_seed_amount,
		"seed_equity_pct": run_seed_equity_pct,
		"seed_expectation": SeedRoundSystem.expectation_state(),
		"faced_series_a": faced_series_a,
		"faced_series_a_by": faced_series_a_by,
		"investor_equity_pct": get_investor_equity_pct(),
		"total_raised": get_total_raised(),
		# scandals (reserved — read 0 today)
		"scandals_total": run_scandals_total,
		"scandals_managed": run_scandals_managed,
	}


func _emit_runway() -> void:
	EventBus.runway_recalculated.emit(get_runway_months())


# --- Run initialization (onboarding Confirm, debug skip, and every load) ---

func initialize_run(payload: Dictionary) -> void:
	# Direct field assignment, not setters: no shell is mounted (on a load main.gd tears it down
	# first), so signals would land in the void; remounting the shell repaints.
	#
	# Optional payload keys:
	#   "seed"    : int        — the RNG seed; a fresh run generates one.
	#   "restore" : Dictionary — a save's state block ({game_state, registries, systems}),
	#                            applied OVER the defaults below. Present ⇒ this is a load: the
	#                            roster and the month-1 ledger come from the save.
	var restore_block: Dictionary = (payload.get("restore", {}) as Dictionary).get("game_state", {})
	var is_restore: bool = not restore_block.is_empty()

	# Identity
	origin = payload.get("origin_id", "self_made")
	subgenre = payload.get("subgenre_id", "ai")   # the committed product overwrites it later
	company_name = payload.get("company_name", "Unicorn Inc.")
	logo_style = payload.get("logo_style", "minimalist")
	slogan = payload.get("slogan", "")
	founder_name = payload.get("founder_name", "")
	founder_portrait = payload.get("portrait_id", "")

	cash = int(FounderConstants.origin_by_id(origin).get("starting_cash", FounderConstants.STARTING_CASH))
	mrr = 0
	daily_burn = FinanceSystem.starting_daily_burn()
	brand = 50
	reputation = 0
	day = 1
	current_hour = 9
	phase = 1

	# Endgame state
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
	month_history.clear()

	# Day-1 point so the curve renders before the first daily tick.
	cash_history = [{"day": 1, "cash": cash}]
	transactions = []
	sales_log = []

	# Month-End Summary + run counters (month_ledger is snapshotted at the END: it needs the roster)
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

	# VC Pitch / Series A Hunt. Dicts via .clear() in case a system cached the reference.
	vc_states.clear()
	active_sheets = []
	pending_meeting.clear()
	prep.clear()
	run_pitches = 0
	run_sheets_won = 0
	vc_meeting_cancel_day = -1
	vc_last_meeting_rejected = false
	vc_frank_cold_shown = []

	# Seed round + the faced-Series-A memory
	seed_door_open_day = -1
	seed_pitch_used = false
	seed_sheet = null
	seed_lead = ""
	seed_closed_day = -1
	run_seed_amount = 0
	run_seed_equity_pct = 0
	faced_series_a = false
	faced_series_a_by = ""
	acq_road_over_day = -1
	bootstrap_milestone_day = -1

	# HR Core state. HRSystem.reset() runs further down: it needs run_seed and may set flags.
	hr_search.clear()
	company_start_hour = HRConstants.START_HOUR_DEFAULT
	company_work_hours = HRConstants.WORK_HOURS_DEFAULT
	group_work_hours_override.clear()
	news_feed.clear()

	flags.clear()
	# Origin flags, after the clear. RESERVED: nothing consumes them yet
	# (FounderConstants.ORIGINS reserved_flags).
	for origin_flag in FounderConstants.origin_by_id(origin).get("reserved_flags", []):
		set_flag(String(origin_flag), true)

	# RESTORE POINT: a load writes the saved values over the baseline; anything the save does
	# not carry keeps it (the whole forward-compat story).
	if is_restore:
		SaveCodec.apply_game_state(restore_block)

	# 0 is ABSENT, not a seed: a literal 0 would pin every run to one sequence.
	var seed_in: int = int(payload.get("seed", 0))
	if seed_in == 0:
		seed_in = int(restore_block.get("run_seed", 0))
	if seed_in == 0:
		# Bounded under 2^52 so the seed survives JSON (doubles) exactly. The one draw the game
		# still takes from the engine's startup-randomised global stream.
		seed_in = absi((randi() << 21) ^ (randi() << 3) ^ int(Time.get_ticks_usec())) % (1 << 52)
	run_seed = seed_in
	# The global generator is a backstop only (the draw sites use RngStreams); seeded so any
	# stray randf() is at least deterministic for the run.
	seed(run_seed)
	RngStreams.reseed(run_seed)

	# current_hour was written directly: the clock's accumulator must follow (see TimeManager).
	TimeManager.sync_to_current_hour()

	# After run_seed and flags.clear(): the HR stream must not seed from the previous run, and
	# anything it flags must not be wiped.
	HRSystem.reset()

	if is_restore:
		# Roster, month-1 ledger and run_hires come from the save; seeding a founder or
		# snapshotting here would collide with the restored records.
		return

	CharacterRegistry.ensure_mentor()
	CharacterRegistry.add(_build_founder(payload))

	# Month-1 ledger after the roster so the team count is real. The founder is category
	# "founder", not a hire.
	MonthSummarySystem.snapshot()
	run_hires = 0


func _build_founder(payload: Dictionary) -> Character:
	var skill_alloc: Dictionary = payload.get("skill_alloc", {})
	# RESERVED: no system consumes trait effects yet.
	var traits_arr: Array[String] = []
	for trait_id in payload.get("trait_ids", []):
		traits_arr.append(String(trait_id))
	if not FounderConstants.validate_traits(traits_arr):
		push_error("[GameState] trait_ids failed the trait formula: %s" % str(traits_arr))

	var display_name: String = String(payload.get("founder_name", "")).strip_edges()
	if display_name == "":
		# The default name is copy, not data: it must not be persisted in one language.
		display_name = TranslationServer.translate("HR_ROLE_FOUNDER")

	var f := Character.new()
	f.id = "char_founder"
	f.character_name = display_name
	f.role = HRConstants.ROLE_FOUNDER
	f.category = "founder"
	f.monthly_salary = 0
	f.morale = 50
	# Onboarding allocates in distribution units; the stored value is the RULER equivalent
	# (§2.4). Validation still checks the RAW allocation. Stale pre-rename keys are flagged,
	# never copied.
	var stats: Dictionary = {}
	for skill_key in FounderConstants.SKILLS:
		stats[skill_key] = FounderConstants.to_ruler(int(skill_alloc.get(skill_key, 0)))
	for k in skill_alloc.keys():
		if not FounderConstants.SKILLS.has(k):
			push_error("[GameState] stale skill key in onboarding payload: '%s' (SKILL-RENAME)" % k)
	if not FounderConstants.validate_alloc(skill_alloc):
		push_error("[GameState] skill_alloc failed validation (pool %d, cap %d): %s"
			% [FounderConstants.POINT_POOL, FounderConstants.ONBOARDING_CAP, str(skill_alloc)])
	f.role_stats = stats
	# The founder sits in ONE JOB (§12.0), the primary job of the build area he allocated most
	# into. The area list is a mirror derived from the jobs; written by hand it would be
	# overwritten on the next assignment and §2.1's "cannot do both" lock would never engage.
	var start_job: String = HRConstants.primary_job_for_area(_founder_start_area(stats))
	if start_job != "":
		f.assigned_job_ids.append(start_job)
	for area_id in HRConstants.areas_for_jobs(f.role, f.category, f.assigned_job_ids):
		f.assigned_jobs.append(String(area_id))
	f.traits = traits_arr
	return f
