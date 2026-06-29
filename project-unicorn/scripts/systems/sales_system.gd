class_name SalesSystem
extends RefCounted

# Pure-logic system per TECH_SPEC §8.3 — no scene dependency, no instance.
# Driven by TimeManager.daily_tick slot 4 (before Finance, before Events).
#
# PostShip spec §C/§D. After mvp_shipped:
#   - B2C: grow an *audience* (interest, NOT revenue) from quality+brand-bugs.
#          Audience→paying conversion happens ONLY through played decisions:
#          the paid-tier pricing choice and growth-move events. There is NO
#          per-tick conversion — MRR plateaus between decisions, so growth
#          always traces to something the player did. (§10: no magical revenue,
#          CLAUDE.md Principle #2 — Faz 1 bug 1.8.)
#   - B2B: passive here — customers come from the pitch dialogue; expansion later.
#   - Both: daily customer-satisfaction drift → health band.
# The canonical MRR bridge (aggregate active customers → GameState.mrr) is kept.
#
# Public mutators (called by event/pitch modifiers, NOT auto-fired here):
#   open_b2c_paid_tier(), convert_b2c_audience(), add_b2b_customer().

# --- Tunables (PostShip working values; Erdem/playtest revise) ---
const AUDIENCE_GROWTH_BASE := 2.0
const AUDIENCE_QUALITY_COEF := 0.15
const AUDIENCE_BRAND_COEF := 0.10
const AUDIENCE_BUG_COEF := 0.30
const B2C_PRICE_DEFAULT := 15            # $/user/month; paid-tier decision may override
const B2C_USERBASE_ID := "co_b2c_userbase"

const SATISFACTION_QUALITY_GATE := 70    # quality ≥ → satisfaction drifts up
const SATISFACTION_BUG_GATE := 5         # bug_count > → satisfaction drifts down

const TRACTION_MRR_TARGET := 5000
const TRACTION_CUSTOMER_TARGET := 8


static func daily_tick() -> void:
	if GameState.get_flag("mvp_shipped", false):
		var market: String = String(GameState.get_flag("mvp_market_type", "b2c"))
		if market == "b2c":
			_tick_b2c()
		# B2B is intentionally passive: prospects + pitch dialogue drive growth.
		_tick_satisfaction()
		_check_traction()

	# Canonical MRR bridge (existing behavior) — aggregate active customers.
	var total_mrr: int = CustomerRegistry.get_total_mrr()
	if GameState.mrr != total_mrr:
		GameState.set_mrr(total_mrr)  # emits mrr_changed → TopBar; runway recalc

	if OS.is_debug_build():
		print("[SalesSystem] Daily tick — MRR $%d" % total_mrr)


# --- B2C audience + organic conversion ---

static func _tick_b2c() -> void:
	var quality: int = int(GameState.get_flag("mvp_quality", 50))
	var bugs: int = int(GameState.get_flag("mvp_bug_count_at_launch", 0))
	var marketing: float = 0.0  # forward-compat: Marketing system fills this later
	var growth: float = AUDIENCE_GROWTH_BASE \
		+ quality * AUDIENCE_QUALITY_COEF \
		+ GameState.brand * AUDIENCE_BRAND_COEF \
		- bugs * AUDIENCE_BUG_COEF \
		+ marketing
	growth = maxf(0.0, growth)
	var audience: int = int(GameState.get_flag("b2c_audience", 0)) + int(round(growth))
	GameState.set_flag("b2c_audience", audience)
	# No per-tick revenue. Audience is interest (a "pent-up demand" pool), NOT
	# revenue — it accrues passively, but it only becomes paying users through a
	# PLAYED decision: open_b2c_paid_tier() (the pricing event) and growth-move
	# events (Product Hunt, power-user) that call convert_b2c_audience(). This is
	# the §10 / CLAUDE.md Principle #2 fix (Faz 1 bug 1.8): MRR plateaus between
	# decisions instead of climbing every day on its own with nothing to click.


# Player opened the paid tier (a played pricing decision) — licenses B2C revenue
# and converts an initial chunk of the waiting audience into paying users.
# Called by the "open_paid_tier" event modifier. price/initial_pct from the choice.
static func open_b2c_paid_tier(price: int, initial_pct: float) -> void:
	if GameState.get_flag("b2c_paid_tier_open", false):
		return
	GameState.set_flag("b2c_paid_tier_open", true)
	GameState.set_flag("b2c_price", maxi(price, 1))
	var audience: int = int(GameState.get_flag("b2c_audience", 0))
	var initial: int = int(round(audience * clampf(initial_pct, 0.0, 1.0)))
	convert_b2c_audience(maxi(initial, 1), "decision")


# Convert n waiting audience members into paying B2C users (one aggregate record).
static func convert_b2c_audience(n: int, source: String) -> void:
	var audience: int = int(GameState.get_flag("b2c_audience", 0))
	n = clampi(n, 0, audience)
	if n <= 0:
		return
	GameState.set_flag("b2c_audience", audience - n)
	_add_b2c_users(n, source)


static func _add_b2c_users(n: int, source: String) -> void:
	var price: int = int(GameState.get_flag("b2c_price", B2C_PRICE_DEFAULT))
	var quality: int = int(GameState.get_flag("mvp_quality", 50))
	var base: Customer = CustomerRegistry.get_customer(B2C_USERBASE_ID)
	if base == null:
		base = Customer.new()
		base.id = B2C_USERBASE_ID
		base.company_name = _product_name() + " kullanıcıları"
		base.industry = "Consumer"
		base.company_size = "individual"
		base.market_type = "b2c"
		base.seats = 0
		base.acquisition_source = source
		base.acquired_on_day = GameState.day
		base.satisfaction = clampi(quality, 0, 100)
		base.update_health_from_satisfaction()
		base.seats = n
		base.mrr = base.seats * price
		CustomerRegistry.add(base)
		GameState.set_mrr(CustomerRegistry.get_total_mrr())  # reflect now (first-revenue beat same day)
		return
	base.seats += n
	CustomerRegistry.set_mrr(base.id, base.seats * price)
	GameState.set_mrr(CustomerRegistry.get_total_mrr())


# --- B2B customer creation (called by PitchSystem on SIGNED) ---

static func add_b2b_customer(prospect: Prospect, mrr: int, satisfaction: int) -> Customer:
	var c := Customer.new()
	c.id = "co_" + prospect.id  # stable, derived from the lead id
	c.company_name = prospect.company_name
	c.industry = prospect.industry
	c.company_size = prospect.archetype
	c.market_type = "b2b"
	c.seats = _seats_for_archetype(prospect.archetype)
	c.mrr = maxi(mrr, 0)
	c.satisfaction = clampi(satisfaction, 0, 100)
	c.difficulty_stars = prospect.difficulty_stars
	c.warning_flags = prospect.warning_flags.duplicate()
	c.acquisition_source = "founder_pitch"
	c.acquired_on_day = GameState.day
	c.update_health_from_satisfaction()
	CustomerRegistry.add(c)
	GameState.set_mrr(CustomerRegistry.get_total_mrr())  # reflect the signed deal immediately
	return c


static func _seats_for_archetype(archetype: String) -> int:
	match archetype:
		"enterprise": return 40
		"mid": return 12
		_: return 4


# --- Shared satisfaction tick ---

static func _tick_satisfaction() -> void:
	var quality: int = int(GameState.get_flag("mvp_quality", 50))
	var bugs: int = int(GameState.get_flag("mvp_bug_count_at_launch", 0))
	for c in CustomerRegistry.get_active():
		var delta: int = 0
		if quality >= SATISFACTION_QUALITY_GATE:
			delta += 1
		if bugs > SATISFACTION_BUG_GATE:
			delta -= 1
		if delta != 0:
			c.satisfaction = clampi(c.satisfaction + delta, 0, 100)
			c.update_health_from_satisfaction()


# --- Traction north-star ---

static func traction_progress() -> float:
	var mrr_ratio: float = float(GameState.mrr) / float(TRACTION_MRR_TARGET)
	var cust_ratio: float = float(CustomerRegistry.get_active().size()) / float(TRACTION_CUSTOMER_TARGET)
	return clampf(maxf(mrr_ratio, cust_ratio), 0.0, 1.0)


static func _check_traction() -> void:
	if GameState.get_flag("ready_for_traction", false):
		return
	if traction_progress() >= 1.0:
		GameState.set_flag("ready_for_traction", true)
		# The one-shot "Traction'a hazır" beat fires via its eligibility event
		# (flag_set ready_for_traction + !traction_beat_seen) in EventManager.


# --- UI helpers ---

static func growth_band() -> String:
	# Soft verbal band for PostShipView (no raw rate). Based on audience growth/day.
	var quality: int = int(GameState.get_flag("mvp_quality", 50))
	var bugs: int = int(GameState.get_flag("mvp_bug_count_at_launch", 0))
	var growth: float = AUDIENCE_GROWTH_BASE + quality * AUDIENCE_QUALITY_COEF \
		+ GameState.brand * AUDIENCE_BRAND_COEF - bugs * AUDIENCE_BUG_COEF
	if growth >= 14.0:
		return "hızlı"
	if growth >= 8.0:
		return "tutarlı"
	return "yavaş"


static func _product_name() -> String:
	var st: Dictionary = ProductCatalog.get_sub_product_type_by_id(
		String(GameState.get_flag("mvp_sub_product_type_id", "")))
	return String(st.get("name", "Ürün"))
