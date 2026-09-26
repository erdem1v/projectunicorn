class_name SalesSystem
extends RefCounted

# Pure-logic system — no scene dependency, no instance.
#
# After mvp_shipped:
#   - B2C: a live *audience* changes every in-game HOUR (hourly_tick), bidirectional —
#          quality/brand/reputation grow it; bugs / low reputation / negative events /
#          price hikes erode it. MRR is DERIVED automatically each hour:
#            paying = round(audience × conversion_rate(price)); MRR = paying × price.
#          Revenue flows between decisions, but only from player-managed levers (price,
#          quality, reputation, audience-moving events) — NOT tycoon spontaneous income.
#          Bidirectional → bad management shrinks the base → MRR falls → runway threat.
#   - B2B: closed at the founder's table or by a rep (add_b2b_customer); fixed MRR
#          (seats × seat price), no hourly derivation.
#   - Both: daily customer-satisfaction drift → health band.
# Canonical MRR bridge (aggregate active customers → GameState.mrr) is the sink.
#
# Driven by TimeManager: hourly_tick (B2C audience + derived MRR) + daily_tick slot 4
# (B2C satisfaction, the B2B desk on a B2B product, bridge backstop). The pricing ruler
# (apply_b2c_price) sets the price and applies the hike reaction.

# --- Tunables (working values; playtest revises) ---
const B2C_PRICE_DEFAULT := 15            # $/user/month; the pricing ruler sets this
const B2C_USERBASE_ID := "co_b2c_userbase"

# B2C aggregate satisfaction drift (director ruling). The gate reads the EXPERIENCE axis — the
# axis the B2C record is SEEDED from (_ensure_b2c_record), and what a consumer feels day to
# day. Bugs erode through SATISFACTION_BUG_GATE.
const SATISFACTION_QUALITY_GATE := 40    # experience axis ≥ → satisfaction drifts up
const SATISFACTION_BUG_GATE := 5         # bug_count > → satisfaction drifts down

# THE SERIES A REVENUE BAR: the anchor of the director's [100,000-150,000] band. The Series A
# gate is MRR only; PhaseGateSystem (the gate leaf and series_a_bar) is its only reader.
# NEVER RENDERED AS A FIGURE (director ruling: the signal is shown, the number is not); the
# player reads PhaseGateSystem.series_a_signal().
const TRACTION_MRR_TARGET := 120_000

# WORKING: optimistic close-rate weight on the open pipeline — feeds only the Finance
# tab's "satış hedefi tutarsa" projection (FinanceSystem.get_optimistic_daily_net).
const PIPELINE_WEIGHT := 0.5

# --- Hourly audience flow (bidirectional, MRR derives from it) ---
# Per-hour coefficients are ~1/24 of a daily rate. The delta is NOT clamped to ≥ 0: erosion
# is real (see the header). Working values; the priority is that the flow can go both ways
# (balance is the last pass).
const HOURLY_AUD_BASE := 0.08
const HOURLY_AUD_QUALITY_COEF := 0.006
const HOURLY_AUD_BRAND_COEF := 0.004
const HOURLY_AUD_REPUTATION_COEF := 0.01   # raw reputation (-10..100): 0 neutral, + grows, − erodes

# --- Erosion / churn ---
# When the product falls below EROSION_THRESHOLD (bugs cut effective stability, or a
# rival passes → quality_term drops), churn overcomes the positive base → audience
# FALLS (not just slows). Kept as a separate additive term so the normalization
# contract is untouched. BALANCE-TUNABLE.
# CHURN is PROPORTIONAL to the current audience (churn = losing existing users, so
# nothing to lose at audience 0 → a fresh product can grow from 0). CHURN_COEF is a
# per-audience-member rate: at audience 200, gap 18 → 0.0002·18·200 = 0.72 users/hour.
const CHURN_COEF := 0.0002
# WORD OF MOUTH — the proportional growth term. Base growth is an ABSOLUTE per-hour trickle
# and churn is PROPORTIONAL to the audience; alone they settle at a fixed point
# (A_eq = grow / (CHURN_COEF·(42−q))) that never compounds and shrinks as rivals advance.
# Two terms on the aggregate's SATISFACTION (the B2C record, 0-100): a loved product compounds
# — grow += audience · WOM_COEF · max(0, sat − WOM_SAT_GATE)/100 — and a disliked one grows
# slower — grow *= clamp(sat / WOM_MULT_PIVOT, WOM_MULT_MIN, 1). WOM_COEF [ÖLÇ]: swept on
# --run-log=b2c_keep:180 (the maintained fixture) for the smallest value that keeps the 30-day
# MRR means non-decreasing to day 180 while b2c_neglect still declines.
const WOM_COEF := 0.005            # [ÖLÇ] per hour · per audience member · per satisfaction point/100 over the gate
const WOM_SAT_GATE := 60.0         # [WORKING] satisfaction above which word of mouth starts
const WOM_MULT_PIVOT := 50.0       # [WORKING] satisfaction at which base growth runs at full strength
const WOM_MULT_MIN := 0.3          # [WORKING] floor of the base-growth multiplier (satisfaction 0)
const EROSION_THRESHOLD := 42.0

# --- Dynamic pricing / value algorithm (working values; balance is the last pass) ---
# product_value() estimates the product's worth ($/user/mo) from quality + feature
# count/depth + low bug count + product-type tendency. It feeds the pricing panel's optimal
# mark and rail, the publish flow's price rail, conversion, the hike reaction and audience
# price-sensitivity. Read-only.
const VALUE_BASE := 4.0
const VALUE_QUALITY_COEF := 0.12         # per quality point (0-100)
const VALUE_FEATURE_COEF := 1.2          # per shipped feature
const VALUE_COMPLEXITY_COEF := 0.6       # per total feature-complexity point
const VALUE_FLOOR_RATIO := 0.5           # lower-bound mark = optimal × this
const TENDENCY_MULT := {"premium": 1.35, "neutral": 1.0, "volume": 0.8}

# Standing conversion ratio: fraction of the WHOLE audience that pays at a given price.
# MRR derives from it each hour. Cheaper than optimal → higher; pricier → lower.
const CONVERSION_BASE := 0.35            # at optimal
const CONVERSION_MIN := 0.02
const CONVERSION_MAX := 0.60
# Bugs hit CONVERSION, not only satisfaction: without this a buggy product still converts
# browsers to payers at full rate. The standing conversion is scaled by
# (1 − live_bugs·BUG_CONV_COEF), floored — the raw live count, the same grammar as
# SATISFACTION_BUG_GATE ("10 bugs ≈ −20 %"). Applied AFTER the price clamp so a cheap price
# cannot hide bugs under CONVERSION_MAX, then re-clamped. The pricing ruler's live projection
# reads conversion_rate, so it moves too.
const BUG_CONV_COEF := 0.02              # [WORKING] per live bug; 10 bugs ≈ −20 %
const BUG_CONV_FLOOR := 0.4              # [WORKING] 30+ bugs cap the penalty at −60 %

# R&D §4.4 `onboarding_flow` — B2C conversion ×1.15. Multiplies CONVERSION_BASE
# INSIDE the price term, before the FIRST clamp, so the bonus is bounded exactly
# once and cannot stack past CONVERSION_MAX after the bug factor re-clamps.
const RND_CONVERSION_MULT := 1.15

# Price-hike audience reaction: fraction of the audience that leaves on a raise.
const CHURN_MAX := 0.45

# Audience growth price-sensitivity (multiplies the hourly flow). Cheaper → audience
# swells faster; premium price slows it.
const AUD_PRICE_MULT_MIN := 0.4
const AUD_PRICE_MULT_MAX := 1.8


static func daily_tick() -> void:
	# Daily: B2C satisfaction drift + a backstop MRR bridge (audience/MRR flow on hourly_tick).
	# THE MARKET GATE, symmetric with hourly_tick's (Satış §3.1): the B2B desk — lifecycle,
	# retention, expansion, faucet, the autonomous rep systems — runs only on a B2B product.
	if GameState.get_flag("mvp_shipped", false):
		_tick_satisfaction()
		if is_b2b_market():
			B2BSalesSystem.daily_tick()
	reflect_mrr()


# Is the SHIPPED product a B2B one? The one answer to "does the enterprise desk run",
# shared by the daily gate above and the HR role locks (a founder cannot hire a Satış
# Uzmanı into a market that has no enterprise desk to work).
static func is_b2b_market() -> bool:
	return String(GameState.get_flag("mvp_market_type", "b2c")) == "b2b"


# --- Hourly tick: bidirectional audience → derived MRR ---

static func hourly_tick(_hour: int) -> void:
	if GameState.get_flag("mvp_shipped", false) and not is_b2b_market():
		_tick_b2c_audience()
		_derive_b2c_mrr()      # MRR = paying(audience,price) × price
	reflect_mrr()


# The canonical MRR sink: aggregate active-customer MRR → GameState (set_mrr emits
# mrr_changed → TopBar live, runway recalc). WRITE-THROUGH LAW: cross-domain callers that
# change a customer's MRR reflect it through HERE, never a hand-rolled
# GameState.set_mrr(get_total_mrr()). One reconciliation rule, one place.
static func reflect_mrr() -> void:
	var total_mrr: int = CustomerRegistry.get_total_mrr()
	if GameState.mrr != total_mrr:
		GameState.set_mrr(total_mrr)


static func _tick_b2c_audience() -> void:
	# TASARIM KANONU: canlı ürünün ekonomisi ASLA donmaz — ne v-build ne sprint sırasında.
	# Sprint'in bedeli kapasite havuzudur (ProductSystem.capacity_speed_factor: build'le
	# paralelse ikisi de yavaşlar).
	# Accumulate as float so small per-hour deltas (especially slow erosion) survive
	# instead of rounding to zero each hour.
	var delta: float = _audience_delta_per_hour()
	GameState.set_flag("b2c_audience", maxf(0.0, b2c_audience() + delta))


# Shared audience-growth delta: _tick_b2c_audience and growth_band BOTH call this, so the
# "büyüyor / eriyor" verdict can never drift from the actual audience motion. Quality is the
# normalized, type-weighted, effective-stability composite (bugs already baked in via
# effective_stability, so there is NO separate bug subtractor — one clean channel).
static func _audience_delta_per_hour() -> float:
	var quality_term: float = _rival_relative_quality(QualityModel.shipped_normalized())
	var grow: float = (HOURLY_AUD_BASE \
		+ quality_term * HOURLY_AUD_QUALITY_COEF \
		+ GameState.brand * HOURLY_AUD_BRAND_COEF \
		+ GameState.reputation * HOURLY_AUD_REPUTATION_COEF) \
		* audience_growth_multiplier(int(GameState.get_flag("b2c_price", 0))) \
		* InfraSystem.acquisition_multiplier()   # Ürün §10: over capacity, B2C acquisition ×0,6
	var audience: float = b2c_audience()
	# Word of mouth, both directions (see WOM_* above), on the aggregate B2C record's
	# satisfaction. Before the record exists (no paid tier yet) it reads WOM_MULT_PIVOT, so the
	# pre-revenue trickle is untouched.
	var ub: Customer = CustomerRegistry.get_customer(B2C_USERBASE_ID)
	var sat: float = float(ub.satisfaction) if ub != null else WOM_MULT_PIVOT
	grow *= clampf(sat / WOM_MULT_PIVOT, WOM_MULT_MIN, 1.0)
	grow += audience * WOM_COEF * maxf(0.0, sat - WOM_SAT_GATE) / 100.0
	# A product below EROSION_THRESHOLD bleeds users (see CHURN_COEF). Price-independent, so
	# it sits outside the multiplier.
	return grow - CHURN_COEF * maxf(0.0, EROSION_THRESHOLD - quality_term) * audience


# Recenters the quality term around the same-type rival average. Benchmark = the STARTUP
# LEAGUE only (the player's real competition). Giants / established are aspiration, NOT the
# churn benchmark — averaging the full field (giants ≈ norm 85) would put a fresh player
# permanently below it → guaranteed death-spiral. Startup rivals advance daily, so the bar
# rises → "feed it or fall behind" pressure that stays recoverable.
static func _rival_relative_quality(player_nq: float) -> float:
	var sub: String = ProductState.subtype()
	var axes: Array = ProductCatalog.get_quality_axes(sub)
	var total: float = 0.0
	var n: int = 0
	for r in RivalRegistry.get_by_type(sub):
		if r.tier == "startup":
			total += QualityModel.normalized_quality_rival(r.composite(axes))   # rival scale bridge
			n += 1
	if n == 0:
		return player_nq
	return clampf(50.0 + (player_nq - total / float(n)), 0.0, 100.0)


# MRR derives from the live audience + price. Sets the aggregate B2C record absolutely
# (seats = paying users, mrr = paying × price). No-op until a price has been set.
static func _derive_b2c_mrr() -> void:
	if not GameState.get_flag("b2c_paid_tier_open", false):
		return  # no price yet → no paying users (audience still builds on the tick)
	var price: int = int(GameState.get_flag("b2c_price", B2C_PRICE_DEFAULT))
	var paying: int = int(round(int(b2c_audience()) * conversion_rate(price)))
	_ensure_b2c_record()
	CustomerRegistry.set_seats(B2C_USERBASE_ID, paying)
	CustomerRegistry.set_mrr(B2C_USERBASE_ID, paying * price)


# Create the single aggregate B2C userbase record if it doesn't exist yet.
static func _ensure_b2c_record() -> void:
	if CustomerRegistry.get_customer(B2C_USERBASE_ID) != null:
		return
	# Seed satisfaction from the EXPERIENCE axis (ease-of-use → happy new users).
	var seed_sat: int = int(round(QualityModel.axis_score(QualityModel.economy_dims_from_flags(), "experience")))
	var base := Customer.new()
	base.id = B2C_USERBASE_ID
	# NOT baked: the name is composed copy, so it is stored as a key + argument (company_name
	# stays "") and rendered by Customer.display_name(). Baking it would freeze one language
	# into the save.
	base.name_key = "SALES_B2C_USERBASE"
	base.name_arg = _product_name()
	base.industry = "consumer"
	base.company_size = "individual"
	base.market_type = "b2c"
	base.acquisition_source = "organic"
	base.acquired_on_day = GameState.day
	base.satisfaction = clampi(seed_sat, 0, 100)
	base.update_health_from_satisfaction()
	CustomerRegistry.add(base)


# Fixture entry (smoke, probe, main.gd's tempo probe — no game caller): opens the tier +
# stores the price, then derives MRR. The game's path is the pricing ruler (apply_b2c_price).
static func open_b2c_paid_tier(price: int) -> void:
	GameState.set_flag("b2c_paid_tier_open", true)
	GameState.set_flag("b2c_price", maxi(price, 1))
	_derive_b2c_mrr()
	reflect_mrr()


## THE read seam for the live B2C audience. Satış bu sayının sahibidir; Ürün §9'un kullanım
## çarpanı ve §10'un doluluk hesabı buradan okur. Sahibi olan modülde adlı bir okuma varken
## kimsenin bayrak adını bilmesi gerekmez; float döner, çünkü saatlik erozyon kesirde yaşıyor.
static func b2c_audience() -> float:
	return maxf(0.0, float(GameState.get_flag("b2c_audience", 0.0)))


## Paying users on a B2C run — seats on the single aggregate userbase record, which is where
## _derive_b2c_mrr writes them (seats = paying, mrr = paying x price). Ch. 13 §2: a consumer
## run reports audience and paying users; this is the second half of that pair, and naming it
## here keeps the aggregate-record id out of every caller. 0 before the paid tier opens:
## nobody is paying.
static func b2c_paying_users() -> int:
	var ub: Customer = CustomerRegistry.get_customer(B2C_USERBASE_ID)
	return int(ub.seats) if ub != null else 0


# Event audience lever (`audience_delta`, and `churn_customer` on the B2C aggregate): moves the
# live audience by n and re-derives MRR at once.
static func add_b2c_audience(n: int) -> void:
	# FLOAT, not int: the stored audience is _tick_b2c_audience's fractional accumulator, and
	# truncating it here would throw away the erosion it carries. The delta `n` stays an int
	# (callers count whole people). GameState.FLAG_TYPES pins the type.
	GameState.set_flag("b2c_audience", maxf(0.0, b2c_audience() + float(n)))
	_derive_b2c_mrr()
	reflect_mrr()


# --- Pipeline read seam (the Finance tab's optimistic projection) ---

static func pipeline_optimistic_mrr() -> int:
	# WORKING: Σ over open leads of (seat band midpoint × the stance's seat price) ×
	# PIPELINE_WEIGHT. Satış rev 6 §5.3/§7.5 — the projection reads the SAME two numbers a real
	# deal is made of, so the green curve moves when the player moves the price dial.
	# Meeting-odds weighting is deliberately NOT modelled — one flat optimism constant.
	var price: float = float(SalesLedger.seat_price_anchor())
	var total: float = 0.0
	for prospect in ProspectRegistry.get_all():
		var band: Dictionary = SalesConstants.seat_band(prospect.star)
		total += (float(band["low"]) + float(band["high"])) * 0.5 * price * PIPELINE_WEIGHT
	return int(round(total))


# --- Sales desk activity log. The owning system holds the seam, GameState holds the array +
#     cap — the same split FinanceSystem.record_transaction uses. `kind` is an internal id
#     ("lead_expired" | "auto_close" | "founder_close" | "cs_absorb"); the Sales tab maps it
#     to a localized line, so nothing player-facing is stored here. ---

static func record_sales_event(kind: String, actor: String, company: String, mrr: int) -> void:
	GameState.sales_log.append({
		"day": GameState.day, "kind": kind, "actor": actor, "company": company, "mrr": mrr,
	})
	while GameState.sales_log.size() > GameState.SALES_LOG_CAP:
		GameState.sales_log.pop_front()


static func get_sales_log() -> Array:
	return GameState.sales_log.duplicate()  # readonly snapshot (get_burn_breakdown contract)


# --- B2B customer creation (SalesFinalizer on a signed negotiation, SalesRepSystem on an
#     autonomous routine close). The sole B2B signing path: the rep has no private way to
#     mint a customer. ---

static func add_b2b_customer(prospect: Prospect, seats: int, seat_price: int,
		satisfaction: int, source: String = "founder_pitch", discount: float = 0.0) -> Customer:
	# SATIŞ rev 6 §5.3/§5.4 — the deal is SEATS x SEAT PRICE, and both are stamped on the
	# record, so expansion charges what this account actually agreed to.
	var c := Customer.new()
	c.id = "co_" + prospect.id  # stable, derived from the lead id
	c.company_name = prospect.company_name
	c.industry = prospect.industry
	# §2 — the STAR is the account size. `b2b_expand` and the event modal's expansion preview
	# read the three-tier `company_size` (via B2BConstants.expansion_seats), so the field keeps
	# that vocabulary; the reverse map, for `add_prospect`, is SalesFaucetSystem.LEGACY_SIZE_TO_STAR.
	c.company_size = ["small", "mid", "enterprise"][clampi(prospect.star, 1, 3) - 1]
	c.market_type = "b2b"
	c.seats = maxi(seats, 0)
	c.seat_price = maxi(seat_price, 0)
	c.signing_discount = clampf(discount, 0.0, 1.0)
	c.mrr = c.seats * c.seat_price
	c.satisfaction = clampi(satisfaction, 0, 100)
	c.difficulty_stars = prospect.star
	c.acquisition_source = source
	c.acquired_on_day = GameState.day
	# B2B lifecycle seed: the star seeds the hidden tolerance (with the sector), drives the seat
	# band and is what every star row draws; larger/older/loyal accounts endure low satisfaction
	# longer. The model's defaults already read onboarding / no countdown / no risk streak.
	c.scale = prospect.star
	c.tolerance = B2BConstants.seed_tolerance(prospect.star, prospect.industry)
	c.onboarding_until = GameState.day + B2BConstants.ONBOARDING_DAYS
	# Request-channel phase, assigned ONCE here and never moved. A stride walk over a counter
	# coprime with the interval spreads the book by construction; an id.hash() would not —
	# consecutive customer ids differ only in their trailing character, so their hashes land
	# on consecutive phases.
	c.cs_request_phase = (GameState.run_customers_signed * B2BConstants.CS_PHASE_STRIDE) \
		% B2BConstants.CS_REQUEST_INTERVAL_DAYS
	# The feature this account wants (drives special requests + the retention promise).
	c.pain_feature_id = prospect.pain_feature_id
	if c.pain_feature_id == "":
		c.pain_feature_id = B2BSalesSystem.pick_pain_feature(ProductState.subtype(), c.scale)
	c.update_health_from_satisfaction()
	CustomerRegistry.add(c)
	# Working rule (direktör onayı) — the account arrives already owned when a rep has room.
	# Through the stewardship system's own seam: who holds an account is CS's rule, not
	# Sales', and Sales only says "one more exists now".
	CustomerRepSystem.auto_assign_new(c)
	GameState.run_customers_signed += 1  # run counter seam — sole B2B signing path
	# A signed company never returns to the faucet (Satış §4, "İmzalı müşteri dönmez"), churn
	# included: the entity is erased on churn, so this name is the durable memory.
	if not GameState.b2b_signed_company_names.has(c.company_name):
		GameState.b2b_signed_company_names.append(c.company_name)
	GameState.set_flag("sales_last_signed_star", c.scale)   # §14 sales.last_signed_star()
	EventBus.deal_signed.emit(c.id, c.seats, c.seat_price)
	# Deliberately NO transactions-log row here. That ledger sits under the cash curve and
	# every other row in it is paired with a real set_cash movement; a subscription's monthly
	# MRR is not collected cash, so a signed "+$1,100" beside a real "−$600" hire would read
	# as treasury income the player never received. The signing reaches them through the
	# headline/news channel instead, and the MRR itself lands via the bridge below.
	reflect_mrr()
	return c


# --- B2C satisfaction tick ---

static func _tick_satisfaction() -> void:
	# B2C satisfaction rises on strong EXPERIENCE (the axis the record was seeded from) and
	# falls when the open bug count is high (the direct churn driver). See the gate's note.
	var delta: int = 0
	if QualityModel.axis_score(QualityModel.economy_dims_from_flags(), "experience") >= SATISFACTION_QUALITY_GATE:
		delta += 1
	if ProductSystem.live_bug_count() > SATISFACTION_BUG_GATE:
		delta -= 1
	if delta == 0:
		return
	# B2B satisfaction is owned by B2BSalesSystem (two-layer model).
	for c in CustomerRegistry.get_by_market("b2c"):
		CustomerRegistry.set_satisfaction(c.id, c.satisfaction + delta)


# --- Value algorithm (product worth → optimal price + lower bound) ---

static func product_value() -> Dictionary:
	# Read-only worth estimate. Pricing power = the type-weighted, effective-stability
	# NORMALIZED composite, so the premium comes from whatever axis THIS market values
	# (quality_axes weights) and bugs dampen worth via effective stability, not a separate term.
	var components: Array = GameState.get_flag("mvp_components", [])
	var total_complexity: int = 0
	for fid in components:
		total_complexity += int(ProductCatalog.get_feature_by_id(String(fid)).get("complexity", 0))
	var mult: float = float(TENDENCY_MULT.get(ProductCatalog.get_price_tendency(ProductState.subtype()), 1.0))
	var raw: float = VALUE_BASE + QualityModel.shipped_normalized() * VALUE_QUALITY_COEF \
		+ components.size() * VALUE_FEATURE_COEF + total_complexity * VALUE_COMPLEXITY_COEF
	var optimal: int = int(round(maxf(1.0, raw) * mult))
	return {"optimal": optimal, "floor": maxi(1, int(round(optimal * VALUE_FLOOR_RATIO)))}


# --- Pricing relationships (conversion / churn / audience sensitivity) ---

## R&D §4.4 `onboarding_flow` — the live conversion multiplier: 1.15 once the node
## is done, 1.0 before it. Named so calibration reads two numbers, not one literal.
static func rnd_conversion_mult() -> float:
	return RND_CONVERSION_MULT if ResearchSeam.completed("onboarding_flow") else 1.0


static func conversion_rate(price: int) -> float:
	# Standing fraction of the WHOLE audience that pays at this price (MRR derives
	# from it each hour). Cheaper than optimal → higher; pricier → lower. Live bugs
	# suppress it (buyers generate the complaints that suppress buying).
	#
	# R&D §4.4 `onboarding_flow` multiplies the BASE inside the price term — before the first
	# clamp, never after the last (see RND_CONVERSION_MULT); after the last, CONVERSION_MAX would
	# eat it outright for anyone already at the ceiling. At optimal 0.35 → 0.4025, under
	# CONVERSION_MAX, so the node lands in full across the normal band; the ceiling clips it only
	# below optimal × 0.671 and swallows it only below optimal × 0.583, where an un-researched
	# player is already capped. pricing_panel.gd renders this rate, so the buff is visible.
	var optimal: float = maxf(1.0, float(product_value()["optimal"]))
	var rate: float = clampf(CONVERSION_BASE * rnd_conversion_mult() * (optimal / maxf(1.0, float(price))), CONVERSION_MIN, CONVERSION_MAX)
	var bug_factor: float = maxf(BUG_CONV_FLOOR, 1.0 - float(ProductSystem.live_bug_count()) * BUG_CONV_COEF)
	return clampf(rate * bug_factor, CONVERSION_MIN, CONVERSION_MAX)


static func churn_fraction(old_price: int, new_price: int) -> float:
	# Fraction of the AUDIENCE that leaves on a price raise (the hike reaction).
	# Bigger hike + further past optimal → more leave.
	if new_price <= old_price or old_price <= 0:
		return 0.0
	var optimal: float = maxf(1.0, float(product_value()["optimal"]))
	var raise_ratio: float = float(new_price - old_price) / maxf(1.0, float(old_price))
	var above_optimal: float = maxf(0.0, (float(new_price) - optimal) / optimal)
	return clampf(raise_ratio * 0.6 + above_optimal * 0.5, 0.0, CHURN_MAX)


static func audience_growth_multiplier(price: int) -> float:
	# Multiplies the hourly audience flow. Neutral (1.0) until a price is set.
	if not GameState.get_flag("b2c_paid_tier_open", false) or price <= 0:
		return 1.0
	var optimal: float = maxf(1.0, float(product_value()["optimal"]))
	return clampf(optimal / maxf(1.0, float(price)), AUD_PRICE_MULT_MIN, AUD_PRICE_MULT_MAX)


# --- The free-price lever (a played decision) ---

static func estimate_price_change(new_price: int) -> Dictionary:
	# Pure preview for the UI (no mutation): the audience reaction to a hike + the
	# resulting DERIVED paying users / MRR at the proposed price. churn_fraction is already
	# 0 for anything that is not a raise.
	new_price = maxi(new_price, 1)
	var was_open: bool = GameState.get_flag("b2c_paid_tier_open", false)
	var old_price: int = int(GameState.get_flag("b2c_price", 0)) if was_open else 0
	var drop: float = churn_fraction(old_price, new_price)
	var audience_after: int = int(round(int(b2c_audience()) * (1.0 - drop)))
	var new_paying: int = int(round(audience_after * conversion_rate(new_price)))
	return {
		"is_raise": was_open and new_price > old_price, "audience_drop_pct": drop,
		"new_paying": new_paying, "new_mrr": new_paying * new_price, "old_mrr": GameState.mrr,
	}


static func apply_b2c_price(new_price: int) -> void:
	# The player set a price on the ruler. Opens the tier + stores the price; a RAISE
	# triggers an audience drop (the hike reaction). MRR is DERIVED immediately so the
	# change is felt now, and re-derives every hour via hourly_tick.
	new_price = maxi(new_price, 1)
	var was_open: bool = GameState.get_flag("b2c_paid_tier_open", false)
	var old_price: int = int(GameState.get_flag("b2c_price", 0)) if was_open else 0
	GameState.set_flag("b2c_paid_tier_open", true)
	GameState.set_flag("b2c_price", new_price)
	if was_open and new_price > old_price:
		# Stored as a float — same reasoning as add_b2c_audience: rounding the hike reaction to
		# a whole person would discard _tick_b2c_audience's fractional accumulator.
		var drop: float = churn_fraction(old_price, new_price)
		GameState.set_flag("b2c_audience", b2c_audience() * (1.0 - drop))
	_derive_b2c_mrr()
	reflect_mrr()


# --- UI helpers ---

static func growth_band() -> String:
	# Verbal band for the audience flow DIRECTION. Uses the SAME shared delta as
	# _tick_b2c_audience so "büyüyor/eriyor" can never contradict the motion.
	var delta: float = _audience_delta_per_hour()
	if delta <= -0.1:
		return TranslationServer.translate("GROWTH_MELTING")
	if delta < 0.15:
		return TranslationServer.translate("GROWTH_FLAT")
	if delta >= 0.6:
		return TranslationServer.translate("GROWTH_FAST")
	return TranslationServer.translate("GROWTH_STEADY")


static func _product_name() -> String:
	var n: String = ProductState.product_name()
	if n != "":
		return n
	var sub_id: String = ProductState.subtype()
	if sub_id == "":
		return TranslationServer.translate("PRODUCT_FALLBACK_NAME")
	return ProductCatalog.type_name(sub_id)
