class_name FinanceSystem
extends RefCounted

# Pure-logic system driven by TimeManager._tick_finance (daily slot 5): daily revenue from MRR,
# daily burn as the sum of named categories, net flow applied to GameState.cash. Every mutation
# goes through a GameState setter, which emits; FinanceSystem never touches scenes or signals.

# Day-1 burn: $50/day (~$1,500/month; with $10K starting cash ≈ 6.6 months runway), all of it
# the founder's own cost. This const is its single home: burn_breakdown starts as a mutable copy
# and GameState's starting daily_burn derives from it (starting_daily_burn()). ALL WORKING.
# KATEGORİ VAR OLMA KURALI: bir kalem burada ya bir sistem YAZDIĞI için durur (salaries/overtime
# daily_tick pull'ları, servers InfraSystem'in set_burn_category'si) ya da 0-değerli TODO hook'tur
# (marketing, office) ve mekaniği gelene dek görünmez (get_burn_breakdown_pct sıfır satırı atlar).
# Uydurma sabit kalem YOK.
const STARTING_BURN_BREAKDOWN := {
	"salaries": 0,     # Overwritten daily by pull from CharacterRegistry
	"overtime": 0,     # Overwritten daily by pull from WorkHoursSystem; 0 when nobody is over 8h
	"founder": 50,     # WORKING: kurucunun kendi yaşam gideri — day-1 baseline'ın tamamı
	"marketing": 0,    # TODO hook: player marketing spend mechanic (set_burn_category ile yazar)
	"office": 0,       # TODO hook: ofis/kira mekaniği; 0 iken görünmez
	# Ürün rev 6.1 §10: sunucu faturası. InfraSystem her gün aylık/30 olarak yazar
	# (set_burn_category). Ürün yayınlanana kadar 0, yani görünmez.
	"servers": 0,
}
static var burn_breakdown := STARTING_BURN_BREAKDOWN.duplicate()

# Legal burn category ids; burn_category_label screams on any other. Display names are
# strings.csv FIN_BURN_<ID>.
const BURN_IDS := ["salaries", "overtime", "founder", "marketing", "office", "servers"]

# TODAY's one-time charges, label → summed amount: apply_one_time_cost adds, daily_tick clears
# it at its top, to_dict/from_dict carry it. Nothing reads it for display — the player-facing
# record of one-time money is GameState.transactions.
static var one_time_today := {}

# One-time charge id -> localization key. Callers pass ids and one_time_label_display translates
# at render time, so the transactions list follows the current language.
const ONE_TIME_LABELS := {
	"build_commit": "FIN_ONETIME_BUILD",
	"version_build_commit": "FIN_ONETIME_VERSION",
	"angel_seed": "ANGEL_TX_LABEL",
	"seed_round": "SEED_TX_LABEL",
	"hire": "HR_COST_HIRING",
	"severance": "HR_COST_SEVERANCE",
	"training": "HR_COST_TRAINING",
	"rnd": "TAB_RND",
}


# --- Run boundary + save (SaveManager) ---

static func reset() -> void:
	# A new run must not inherit the previous run's burn lines: the daily pulls rewrite only
	# salaries / overtime (and InfraSystem servers), so a leftover marketing or office figure
	# would keep charging the new company. duplicate() (not a reference to the const) so a
	# later set_burn_category cannot edit STARTING_BURN_BREAKDOWN itself.
	burn_breakdown = STARTING_BURN_BREAKDOWN.duplicate()
	one_time_today.clear()


static func to_dict() -> Dictionary:
	# The multi-day transactions log is not here: it lives on GameState.transactions and rides
	# in the GameState block.
	return {
		"burn_breakdown": burn_breakdown.duplicate(),
		"one_time_today": one_time_today.duplicate(),
	}


static func from_dict(d: Dictionary) -> void:
	if d.is_empty():
		return
	# Restored key-by-key ONTO the starting shape rather than replacing it wholesale: a save
	# written before a burn category existed must still end up with every category the
	# current build expects, or compute_total_burn silently stops counting one of them.
	var restored: Dictionary = STARTING_BURN_BREAKDOWN.duplicate()
	var saved: Dictionary = d.get("burn_breakdown", {}) as Dictionary
	for category in saved.keys():
		if restored.has(category):
			restored[String(category)] = int(saved[category])
	burn_breakdown = restored
	one_time_today = {}
	var saved_one_time: Dictionary = d.get("one_time_today", {}) as Dictionary
	for label in saved_one_time.keys():
		one_time_today[String(label)] = int(saved_one_time[label])


static func starting_daily_burn() -> int:
	# Day-1 baseline total — GameState defaults + initialize_run read it.
	var total: int = 0
	for category in STARTING_BURN_BREAKDOWN:
		total += STARTING_BURN_BREAKDOWN[category]
	return total


# --- Entry point (called by TimeManager._tick_finance) ---

static func daily_tick() -> void:
	one_time_today.clear()   # yesterday's one-time charges stop being "today's"
	# Salaries and overtime are PULLED: HR ticked at slot 3, so the registry and today's
	# overtime stamp are settled. Pulling (rather than letting HR push via set_burn_category)
	# keeps daily_burn from ever publishing fresh overtime against stale salaries, and avoids
	# two extra burn_changed/runway signal passes every day.
	# Ekip §8.2: ek mesai ayrı bir mekanik değil, çalışma aralığının sonucudur; "KİŞİ BAŞINA
	# hesaplanır, şirket ayarına göre değil. Ölçüt kişinin §8.1'e göre devraldığı saattir."
	burn_breakdown["salaries"] = daily_salary_for(CharacterRegistry.get_total_monthly_salaries())
	burn_breakdown["overtime"] = WorkHoursSystem.overtime_pay_accrued_today()

	var total_burn: int = compute_total_burn()
	if GameState.daily_burn != total_burn:
		GameState.set_daily_burn(total_burn)  # emits burn_changed → TopBar
	var daily_revenue: int = GameState.get_daily_revenue()
	var new_cash: int = GameState.cash + daily_revenue - total_burn
	# Calendar-month ledger accrual: the same figures that move the cash, once per day, before
	# the sample so the close reads a settled month.
	GameState.accrue_month_flow(daily_revenue, total_burn, new_cash)
	# Curve sample BEFORE set_cash: signals are synchronous, so the cash_changed repaint
	# must read an already-fresh buffer. Slot-5 cash is tick-final (later slots' event
	# deltas land intra-day at modal resolve, not during dispatch), so this single
	# write site needs no ordering assumptions on slots 6-10.
	GameState.append_cash_sample(new_cash)
	GameState.set_cash(new_cash)


# --- One-time cash movements (Write-Through: Finance owns cash) ---
# Affordability gate yok (nakit eksiye düşebilir — mevcut iflas baskısıyla aynı kanal); iptal +
# yeniden commit YENİDEN tahsil eder (yanan yanmıştır — working call). Aylık yinelenen
# API-maliyeti modeli (mekaniğiyle birlikte doğacak bir "tools" kalemi) BİLİNÇLİ ERTELENDİ.

static func apply_one_time_cost(amount: int, label: String) -> void:
	if amount <= 0:
		return
	one_time_today[label] = int(one_time_today.get(label, 0)) + amount
	record_transaction(label, -amount)
	GameState.accrue_month_expense(amount)   # an outgoing of the open month
	# set_cash LAST: its cash_changed emit is synchronous, and repaints triggered by it must
	# read the transactions row already appended.
	GameState.set_cash(GameState.cash - amount)   # emits cash_changed + runway_recalculated


static func apply_one_time_income(amount: int, label: String) -> void:
	# The income sibling of apply_one_time_cost, so no caller has to open-code the ordering.
	# Deliberately NOT folded into one signed function: a cost also writes one_time_today and
	# the month's expense accrual, while income only writes the transactions log.
	# SAME LOAD-BEARING ORDER: ledger row FIRST, set_cash LAST.
	if amount <= 0:
		return
	record_transaction(label, amount)
	GameState.set_cash(GameState.cash + amount)   # emits cash_changed + runway_recalculated


# --- Burn breakdown API ---

static func daily_salary_for(monthly_total: int) -> int:
	# Monthly payroll → the daily figure that lands in burn_breakdown["salaries"], rounded ONCE.
	# Exposed so a preview (HRSearchSystem.preview_hire) can promise the exact number this tick
	# will publish instead of mirroring the arithmetic and drifting from it.
	return int(round(float(monthly_total) / float(GameState.DAYS_PER_MONTH)))


static func compute_total_burn() -> int:
	var total: int = 0
	for category in burn_breakdown:
		total += burn_breakdown[category]
	return total


static func set_burn_category(category: String, value: int) -> void:
	if not burn_breakdown.has(category):
		push_warning("[FinanceSystem] Unknown burn category: %s" % category)
		return
	burn_breakdown[category] = maxi(value, 0)
	# Refresh the cached GameState.daily_burn NOW so runway / TopBar / VCPitch see the change
	# this tick, not only at the next daily tick.
	GameState.set_daily_burn(compute_total_burn())


static func get_burn_breakdown() -> Dictionary:
	# Readonly snapshot — callers must not mutate the returned dict.
	return burn_breakdown.duplicate()


static func burn_category_label(category: String) -> String:
	# Internal burn id → display name. Unknown ids fall back to themselves only after
	# screaming, so a typo shows up in the log rather than as an English word on screen.
	if not BURN_IDS.has(category):
		push_error("[FinanceSystem] burn_category_label on unknown category: '%s'" % category)
		return category
	return TranslationServer.translate("FIN_BURN_" + category.to_upper())


static func one_time_label_display(label: String) -> String:
	# One-time charge id → display name via ONE_TIME_LABELS (values are localization keys). An
	# id missing from the table renders as-is — an internal code on screen — so register every
	# new id there. Static, so TranslationServer.translate instead of tr().
	return TranslationServer.translate(String(ONE_TIME_LABELS.get(label, label)))


# --- Transactions log (Finance tab "Son işlemler") ---
# The persistent multi-day money log. apply_one_time_cost / apply_one_time_income append through
# record_transaction, the sole append point; storage lives on GameState (reset by initialize_run,
# saved in the GameState block).
#
# THE INVARIANT: every row is a real cash movement that actually happened, paired with a
# set_cash. A signing is not one (its MRR has not been collected yet); it reaches the player
# through the news/headline channel. Do not add a row for anything the treasury did not move.

static func record_transaction(label: String, amount: int) -> void:
	# Signed: negative = spend, positive = income. Labels stored RAW; display goes
	# through one_time_label_display at render time.
	GameState.transactions.append({"day": GameState.day, "label": label, "amount": amount})
	while GameState.transactions.size() > GameState.TRANSACTIONS_CAP:
		GameState.transactions.pop_front()


static func get_transactions() -> Array:
	# Readonly snapshot, oldest → newest (same contract as get_burn_breakdown).
	return GameState.transactions.duplicate()


# --- Finance tab read seams (humble-UI law: the tab renders these verbatim) ---

static func get_monthly_flow() -> Dictionary:
	# Run-rate month from live state — same sources as the TopBar, so the tab and the
	# bar can never disagree: income = MRR as-is, expense/net = daily × DAYS_PER_MONTH.
	return {
		"income": GameState.mrr,
		"expense": GameState.daily_burn * GameState.DAYS_PER_MONTH,
		"net": GameState.get_net_daily_flow() * GameState.DAYS_PER_MONTH,
	}


static func get_burn_breakdown_pct() -> Array:
	# [{id, label, amount, pct}] — zero categories skipped, sorted desc by amount,
	# largest-remainder rounding so the pct column sums to exactly 100.
	var rows: Array = []
	var total: int = 0
	for category in burn_breakdown:
		var amount: int = int(burn_breakdown[category])
		if amount <= 0:
			continue
		total += amount
		rows.append({"id": category, "label": burn_category_label(category), "amount": amount})
	if total <= 0:
		return []
	rows.sort_custom(func(a, b): return int(a.amount) > int(b.amount))
	# Largest-remainder: floor everyone, hand the leftover points to the biggest remainders
	# (leftover < rows.size(), since every remainder is < 1).
	var assigned: int = 0
	for row in rows:
		var exact: float = float(row.amount) * 100.0 / float(total)
		row["pct"] = int(floor(exact))
		row["_rem"] = exact - floor(exact)
		assigned += int(row.pct)
	var by_rem: Array = rows.duplicate()
	by_rem.sort_custom(func(a, b): return float(a._rem) > float(b._rem))
	for i in range(100 - assigned):
		by_rem[i]["pct"] += 1
	for row in rows:
		row.erase("_rem")
	return rows


static func get_optimistic_daily_net() -> int:
	# WORKING: "satış hedefi tutarsa" projection slope — today's MRR plus the
	# pipeline-weighted open pipeline, minus today's burn.
	var optimistic_mrr: int = GameState.mrr + SalesSystem.pipeline_optimistic_mrr()
	return int(round(optimistic_mrr / float(GameState.DAYS_PER_MONTH))) - GameState.daily_burn
