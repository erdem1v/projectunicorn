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
# ($10K cash, ~6.6 months runway). Solo founder, no hires, no marketing spend.

const DAYS_PER_MONTH := 30

# Bootstrap solo founder baseline burn (sums to $50/day = ~$1,500/month).
# Salaries are PULLED from CharacterRegistry at the top of daily_tick — one-way
# pull, HR ticks at slot 3 so the registry is quiescent by slot 5.
# Player marketing spend mechanic will mutate "marketing" via set_burn_category().
static var burn_breakdown := {
	"salaries": 0,        # Overwritten daily by pull from CharacterRegistry
	"tools": 7,           # SaaS subscriptions, hosting, dev tooling (~$210/mo)
	"office": 25,         # Coworking desk (~$750/mo)
	"marketing": 0,       # TODO when player marketing spend mechanic exists
	"legal": 11,          # Light retainer / freelance accountant (~$330/mo)
	"misc": 7,            # Software, supplies, fees (~$210/mo)
}


# --- Entry point (called by TimeManager._tick_finance) ---

static func daily_tick() -> void:
	# 0. Pull salaries from CharacterRegistry (HR ticked at slot 3; registry
	#    state is settled). Convert monthly payroll to a daily figure using
	#    DAYS_PER_MONTH — same conversion as MRR → daily revenue (line below).
	var monthly_salaries: int = CharacterRegistry.get_total_monthly_salaries()
	burn_breakdown["salaries"] = int(round(monthly_salaries / float(DAYS_PER_MONTH)))

	# 1. Recompute total burn from breakdown (may have shifted via salary pull / marketing)
	var total_burn: int = compute_total_burn()
	if GameState.daily_burn != total_burn:
		GameState.set_daily_burn(total_burn)  # emits burn_changed → TopBar

	# 2. Daily revenue from monthly recurring revenue
	var daily_revenue: int = int(round(GameState.mrr / float(DAYS_PER_MONTH)))

	# 3. Net flow applied once — single set_cash call → single signal pass
	var net: int = daily_revenue - total_burn
	GameState.set_cash(GameState.cash + net)
	# set_cash emits cash_changed + runway_recalculated → TopBar updates


# --- Burn breakdown API (consumed by future systems) ---

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
