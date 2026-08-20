class_name FinanceSystem
extends RefCounted

# Pure-logic system per TECH_SPEC §8.3 — no scene dependency, no instance.
# Driven by TimeManager.daily_tick slot 5 (TECH_SPEC §8.2 ordered dispatch).
#
# Responsibilities (PROJECT_SPEC §5.3):
#   - Compute daily revenue from MRR (mrr / 30)
#   - Compute daily burn as the sum of named categories
#   - Apply net flow (revenue − burn) to GameState.cash
#   - Trigger runway recalculation (set_cash → runway_recalculated signal)
#
# Mutations flow only through GameState setters → EventBus signals →
# scenes update themselves. FinanceSystem never touches scenes or signals
# directly (one-way dataflow, TECH_SPEC §6.2).
#
# Burn breakdown defaults: $50/day baseline for the pressure-from-day-one start
# ($10K cash, ~6.6 months runway). The WHOLE baseline is the founder's own cost —
# ofis, araç, hukuk mekanikleri motorda yok, o yüzden hiçbir öyle satır rakam taşımaz.

# Bootstrap solo founder baseline burn (sums to $50/day = ~$1,500/month).
# KATEGORİ VAR OLMA KURALI: bir kalem burada ya bir sistem YAZDIĞI için durur
# (salaries/overtime pull'ları, marketing set_burn_category ile) ya da 0-değerli TODO
# hook'tur ve mekaniği gelene dek görünmez (get_burn_breakdown_pct sıfır satırı atlar).
# Uydurma sabit kalem YOK — eski tools(7)/office(25)/legal(11)/misc(7) literalleri
# motorda karşılıksız oldukları için SİLİNDİ (yeniden adlandırılmadı); day-1'in tamamı
# artık kurucunun kendi gideri olarak dürüst tek satır.
# Salaries AND overtime are PULLED at the top of daily_tick — one-way pull, HR ticks at
# slot 3 so the registry and the overtime stamp are both quiescent by slot 5. Both start
# at 0, so the day-1 baseline is unchanged at $50.
# Single home for the day-1 breakdown; burn_breakdown starts as a mutable copy,
# and GameState's starting daily_burn derives from it (starting_daily_burn()). ALL WORKING.
# NOT: static var reset'i süreç relaunch'una dayanır (TEKRAR DENE = OS restart); in-place reset seam'i ana menü / SaveManager task'ının işi.
const STARTING_BURN_BREAKDOWN := {
	"salaries": 0,     # Overwritten daily by pull from CharacterRegistry
	"overtime": 0,     # Overwritten daily by pull from HROvertimeSystem; 0 when no block runs
	"founder": 50,     # WORKING: kurucunun kendi yaşam gideri — day-1 baseline'ın tamamı
	"marketing": 0,    # TODO hook: player marketing spend mechanic (set_burn_category ile yazar)
	"office": 0,       # TODO hook: ofis/kira mekaniği curve session'ın işi; 0 iken görünmez
}
static var burn_breakdown := STARTING_BURN_BREAKDOWN.duplicate()

# The standing burn categories. The ids above are internal and English; rendering them raw
# would break the Content Law against internal codes on screen. The words now live in
# strings.csv as FIN_BURN_<ID>, derived by burn_category_label — so this list only has to say
# which ids are legal, and the "unknown id screams" guarantee is kept.
const BURN_IDS := ["salaries", "overtime", "founder", "marketing", "office"]

# TODAY's one-time charges, label → summed amount. apply_one_time_cost appends; daily_tick
# clears at its top, so a charge stays readable for the rest of the day it happened and is gone
# on the next day's tick ("bugünkü tek seferlik giderler").
# INVARIANT this relies on: no slot 1-5 system charges a one-time cost DURING the daily tick.
# Today nothing does — every caller is a player action (işe alım, işten çıkarma, build commit).
# If that ever changes, move the clear out of daily_tick.
# Reset position matches burn_breakdown's (see the note above it): process relaunch, no in-place
# seam until the main-menu / SaveManager task builds one.
static var one_time_today := {}

# Display names for one-time charge labels. HR passes Turkish labels already
# (HRConstants.COST_LABEL_HIRE / _SEVERANCE) and they fall through unchanged; ProductSystem
# passes raw internal ids, which are mapped here so no product-side file has to change.
# WORKING TR.
# One-time charge id -> localization key. Every caller passes an ID now; HR used to pass
# already-translated text, which made the expense breakdown keep the language it was written
# in until the next daily tick.
const ONE_TIME_LABELS := {
	"build_commit": "FIN_ONETIME_BUILD",
	"version_build_commit": "FIN_ONETIME_VERSION",
	"angel_seed": "ANGEL_TX_LABEL",
	"hire": "HR_COST_HIRING",
	"severance": "HR_COST_SEVERANCE",
	"training": "HR_COST_TRAINING",
}


# --- Run boundary + save (SaveManager) ---
# The in-place seam both notes above promised ("static var reset'i süreç relaunch'una
# dayanır ... in-place reset seam'i ana menü / SaveManager task'ının işi"). Now it exists,
# so neither static depends on an OS restart any more.

static func reset() -> void:
	# burn_breakdown carries the previous run's payroll and marketing lines, and the salary
	# pull only overwrites the "salaries" key — so a leaked "marketing" figure would keep
	# charging a new company for a campaign the old one bought. duplicate() (not a reference
	# to the const) so a later set_burn_category cannot edit STARTING_BURN_BREAKDOWN itself.
	burn_breakdown = STARTING_BURN_BREAKDOWN.duplicate()
	one_time_today.clear()


static func to_dict() -> Dictionary:
	# one_time_today is a SINGLE DAY's ledger, and it is genuinely worth saving: a save
	# taken after the player paid a hire commission should reopen showing that charge in the
	# day's gider dökümü, exactly as it did a moment before. The multi-day transactions log
	# lives on GameState (GameState.transactions) and rides in the GameState block.
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
	# Day-1 baseline total ($50/day) — GameState defaults + initialize_run read it.
	var total: int = 0
	for category in STARTING_BURN_BREAKDOWN:
		total += STARTING_BURN_BREAKDOWN[category]
	return total


# --- Entry point (called by TimeManager._tick_finance) ---

static func daily_tick() -> void:
	# 0a. Yesterday's one-time charges stop being "today's". Cleared FIRST so nothing below
	#     can read a stale line, and so a charge made during the day just ended stays visible
	#     for that whole day (see the one_time_today invariant).
	one_time_today.clear()
	# 0. Pull salaries from CharacterRegistry (HR ticked at slot 3; registry
	#    state is settled). Convert monthly payroll to a daily figure using
	#    GameState.DAYS_PER_MONTH — same conversion as MRR → daily revenue (line below).
	var monthly_salaries: int = CharacterRegistry.get_total_monthly_salaries()
	burn_breakdown["salaries"] = daily_salary_for(monthly_salaries)
	# 0b. Same one-way PULL for today's overtime accrual. HR stamped it at slot 3, two
	#     slots ago. Pulling (rather than letting HR push via set_burn_category) is what
	#     keeps daily_burn from ever publishing fresh overtime against stale salaries,
	#     and avoids two extra burn_changed/runway signal passes every single day.
	burn_breakdown["overtime"] = HROvertimeSystem.pay_accrued_today()

	# 1. Recompute total burn from breakdown (may have shifted via salary pull / marketing)
	var total_burn: int = compute_total_burn()
	if GameState.daily_burn != total_burn:
		GameState.set_daily_burn(total_burn)  # emits burn_changed → TopBar

	# 2. Daily revenue from monthly recurring revenue
	var daily_revenue: int = int(round(GameState.mrr / float(GameState.DAYS_PER_MONTH)))

	# 3. Net flow applied once — single set_cash call → single signal pass
	var net: int = daily_revenue - total_burn
	var new_cash: int = GameState.cash + net
	# Calendar-month ledger accrual (Calibration Round A §3/§9): the same figures that move
	# the cash, once per day, before the sample so the close reads a settled month.
	GameState.accrue_month_flow(daily_revenue, total_burn, new_cash)
	# Curve sample BEFORE set_cash: signals are synchronous, so the cash_changed repaint
	# must read an already-fresh buffer. Slot-5 cash is tick-final (later slots' event
	# deltas land intra-day at modal resolve, not during dispatch), so this single
	# write site needs no ordering assumptions on slots 6-10.
	GameState.append_cash_sample(new_cash)
	GameState.set_cash(new_cash)
	# set_cash emits cash_changed + runway_recalculated → TopBar updates


# --- One-time spend seam (Rev3 build commit: API/lisans maliyeti) ---
# Write-Through: Finance owns cash. Charged EXACTLY once by the commit seam
# (ProductSystem.start_build / start_version_build) after validation. Aylık
# yinelenen API-maliyeti modeli (gelecekte mekaniğiyle birlikte doğacak bir "tools"
# kalemi) BİLİNÇLİ ERTELENDİ — economy-curve redesign'da ele alınacak. Affordability gate yok
# (nakit eksiye düşebilir — mevcut iflas baskısıyla aynı kanal); iptal + yeniden
# commit YENİDEN tahsil eder (yanan yanmıştır — working call). `label` ARTIK gerçekten
# kaydediliyor: one_time_today ledger'ına yazılır ve gider dökümünde satır olur
# (Calibration Law 3 — oyuncu parasının nereye gittiğini okuyabilmeli).

static func apply_one_time_cost(amount: int, label: String) -> void:
	if amount <= 0:
		return
	# Ledger: SUMMED per label rather than appended as rows, so two hires on one day read as a
	# single "İşe alım $2.000" line. The retainer and the commission deliberately share
	# COST_LABEL_HIRE, which collapses one whole search into one line.
	one_time_today[label] = int(one_time_today.get(label, 0)) + amount
	record_transaction(label, -amount)
	GameState.accrue_month_expense(amount)   # an outgoing of the open month (Calibration Round A §9)
	# set_cash LAST: its cash_changed emit is synchronous, and repaints triggered by it
	# must read both ledgers already-appended (the old emit-first order served the finance
	# tab a pre-append one_time_today for one frame).
	GameState.set_cash(GameState.cash - amount)   # emits cash_changed + runway_recalculated
	if OS.is_debug_build():
		print("[FinanceSystem] one-time cost $%d (%s)" % [amount, label])


static func apply_one_time_income(amount: int, label: String) -> void:
	# The income sibling of apply_one_time_cost, and it exists so no caller has to
	# open-code the ordering. Deliberately NOT folded into one signed function: a cost also
	# writes one_time_today (today's "gider dökümü" is a spend list, and an investment is
	# not a spend), while income only needs the multi-day transactions log.
	#
	# SAME LOAD-BEARING ORDER: ledger row FIRST, set_cash LAST. cash_changed is synchronous
	# and the Finance tab repaints inside it; it must read an already-appended log.
	if amount <= 0:
		return
	record_transaction(label, amount)
	GameState.set_cash(GameState.cash + amount)   # emits cash_changed + runway_recalculated
	if OS.is_debug_build():
		print("[FinanceSystem] one-time income $%d (%s)" % [amount, label])


# --- Burn breakdown API (consumed by future systems) ---

static func daily_salary_for(monthly_total: int) -> int:
	# Monthly payroll → the daily figure that lands in burn_breakdown["salaries"]. Same
	# conversion as MRR → daily revenue (GameState.DAYS_PER_MONTH), rounded ONCE. Exposed so a
	# preview (HRSearchSystem.preview_hire) can promise the exact number this tick will publish
	# instead of mirroring the arithmetic and drifting from it.
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
	burn_breakdown[category] = max(value, 0)
	# Stale-mirror fix (§E-D.2): refresh the cached GameState.daily_burn NOW so runway /
	# TopBar / VCPitch reflect a marketing-spend change this tick, not only next daily tick.
	GameState.set_daily_burn(compute_total_burn())


static func get_burn_breakdown() -> Dictionary:
	# Readonly snapshot — callers must not mutate the returned dict.
	return burn_breakdown.duplicate()


static func get_one_time_today() -> Dictionary:
	# Readonly snapshot of today's one-time charges, label → amount. Same contract as
	# get_burn_breakdown above. Empty on a day nobody spent anything one-off.
	return one_time_today.duplicate()


static func burn_category_label(category: String) -> String:
	# Internal burn id → display name. Unknown ids fall back to themselves only after
	# screaming, so a typo shows up in the log rather than as an English word on screen.
	if not BURN_IDS.has(category):
		push_error("[FinanceSystem] burn_category_label on unknown category: '%s'" % category)
		return category
	return TranslationServer.translate("FIN_BURN_" + category.to_upper())


static func one_time_label_display(label: String) -> String:
	# One-time charge label → display name. HR already passes Turkish (COST_LABEL_HIRE /
	# _SEVERANCE) and falls through unchanged; ProductSystem's raw ids are mapped.
	# NOTE for future callers: pass a Turkish label, or register the id in ONE_TIME_LABELS —
	# an unregistered English id will render as-is and break the no-internal-codes law.
	# The mapped value may itself be a LOCALIZATION KEY (the Bilingual Birth direction of
	# travel): TranslationServer.translate returns a non-key unchanged, so the two existing
	# literal values and HR's free-form Turkish labels pass through exactly as before. This
	# is a static, so tr() is unavailable — translate() is the documented statics path.
	return TranslationServer.translate(String(ONE_TIME_LABELS.get(label, label)))


# --- Transactions log (Finance Tab v1 "Son işlemler") ---
# Persistent multi-day extension of the one_time_today seam — NOT a parallel ledger:
# apply_one_time_cost appends here in the same breath. Storage lives on GameState (reset
# by initialize_run, SaveManager serializes later); this is the sole append point.
#
# THE INVARIANT: every row is a real cash movement that actually happened, paired with a
# set_cash. Signings used to be appended here too, carrying the account's MONTHLY MRR as
# though that money had entered the treasury — so "İşe alım −$600" (cash genuinely gone)
# and "Ferrum Endüstri +$1,100" (a subscription not yet collected even once) rendered
# identically, signed and coloured, in a card sitting directly under the cash curve. The
# signing reaches the player through the news/headline channel instead. Do not re-add a
# row for anything the treasury did not actually move.

static func record_transaction(label: String, amount: int) -> void:
	# Signed: negative = spend, positive = income. Labels stored RAW; display goes
	# through one_time_label_display at render time.
	GameState.transactions.append({"day": GameState.day, "label": label, "amount": amount})
	while GameState.transactions.size() > GameState.TRANSACTIONS_CAP:
		GameState.transactions.pop_front()


static func get_transactions() -> Array:
	# Readonly snapshot, oldest → newest (same contract as get_burn_breakdown).
	return GameState.transactions.duplicate()


# --- Finance Tab v1 read seams (humble-UI law: the tab renders these verbatim) ---

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
	# Largest-remainder: floor everyone, hand the leftover points to the biggest remainders.
	var assigned: int = 0
	for row in rows:
		var exact: float = float(row.amount) * 100.0 / float(total)
		row["pct"] = int(floor(exact))
		row["_rem"] = exact - floor(exact)
		assigned += int(row.pct)
	var leftover: int = 100 - assigned
	var by_rem: Array = rows.duplicate()
	by_rem.sort_custom(func(a, b): return float(a._rem) > float(b._rem))
	for i in range(leftover):
		by_rem[i % by_rem.size()]["pct"] = int(by_rem[i % by_rem.size()].pct) + 1
	for row in rows:
		row.erase("_rem")
	return rows


static func get_optimistic_daily_net() -> int:
	# WORKING: "satış hedefi tutarsa" projection slope — today's MRR plus the
	# pipeline-weighted open pipeline, minus today's burn. Revisit at the curve session.
	var optimistic_mrr: int = GameState.mrr + SalesSystem.pipeline_optimistic_mrr()
	return int(round(optimistic_mrr / float(GameState.DAYS_PER_MONTH))) - GameState.daily_burn
