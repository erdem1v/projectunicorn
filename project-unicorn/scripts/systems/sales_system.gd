class_name SalesSystem
extends RefCounted

# Pure-logic system per TECH_SPEC §8.3 — no scene dependency, no instance.
#
# Economy Model v2 (PROJECT_SPEC §10 revision). After mvp_shipped:
#   - B2C: a live *audience* changes every in-game HOUR (hourly_tick), bidirectional —
#          quality/brand/reputation grow it; bugs / low reputation / negative events /
#          price hikes erode it. MRR is DERIVED automatically each hour:
#            paying = round(audience × conversion_rate(price)); MRR = paying × price.
#          Revenue flows between decisions, but only from player-managed levers (price,
#          quality, reputation, audience-moving events) — NOT tycoon spontaneous income.
#          Bidirectional → bad management shrinks the base → MRR falls → runway threat.
#   - B2B: pitch-driven, fixed MRR (seat × negotiated price). No auto-flow.
#   - Both: daily customer-satisfaction drift → health band.
# Canonical MRR bridge (aggregate active customers → GameState.mrr) is the sink.
#
# Driven by TimeManager: hourly_tick (B2C audience + derived MRR) + daily_tick slot 4
# (satisfaction + bridge backstop). The pricing ruler (apply_b2c_price) sets the price
# and applies the hike reaction; add_b2b_customer is the B2B close path.

# --- Tunables (PostShip working values; Erdem/playtest revise) ---
const B2C_PRICE_DEFAULT := 15            # $/user/month; the pricing ruler sets this
const B2C_USERBASE_ID := "co_b2c_userbase"

const SATISFACTION_QUALITY_GATE := 70    # quality ≥ → satisfaction drifts up
const SATISFACTION_BUG_GATE := 5         # bug_count > → satisfaction drifts down

const TRACTION_MRR_TARGET := 5000
const TRACTION_CUSTOMER_TARGET := 8

# --- Hourly audience flow (Economy Model v2 — bidirectional, MRR derives from it) ---
# Audience is the live B2C user base; it changes every in-game hour. quality/brand/
# (positive) reputation grow it; bugs / low reputation / price hikes erode it. Per-hour
# coefficients are ~1/24 of a daily rate. The delta is NOT clamped to ≥0 — it can be
# negative (erosion), so bad management (low quality + high bugs + falling reputation)
# shrinks the base, MRR falls, and runway stays a real threat. Working values; the
# priority is that the flow can go both ways (balance is the last pass).
const HOURLY_AUD_BASE := 0.08
const HOURLY_AUD_QUALITY_COEF := 0.006
const HOURLY_AUD_BRAND_COEF := 0.004
const HOURLY_AUD_REPUTATION_COEF := 0.01   # raw reputation (-10..100): 0 neutral, + grows, − erodes

# Rival-relative economy (Product Lifecycle Part 2A: turned ON). Audience quality
# term keys off the player's quality RELATIVE to the same-type STARTUP-league rivals
# (giants are aspiration, not the churn benchmark — see _rival_relative_quality).
const RIVAL_RELATIVE := true

# --- Erosion / churn (Product Lifecycle Part 2A) ---
# When the product falls below EROSION_THRESHOLD (bugs cut effective stability, or a
# rival passes → quality_term drops), churn overcomes the positive base → audience
# FALLS (not just slows). Kept as a separate additive term so the normalization
# contract is untouched and R1≡R6 stays automatic. BALANCE-TUNABLE (Erdem tunes feel).
# CHURN is PROPORTIONAL to the current audience (churn = losing existing users, so
# nothing to lose at audience 0 → a fresh product can grow from 0). CHURN_COEF is a
# per-audience-member rate: at the reference (audience 200, gap 18) → 0.0002·18·200 =
# 0.72, matching the originally-verified flat erosion at that point.
const CHURN_COEF := 0.0002
const EROSION_THRESHOLD := 42.0

# --- Dynamic pricing / value algorithm (working values; balance is the last pass) ---
# product_value() estimates the product's worth ($/user/mo) from quality + feature
# count/depth + low bug count + product-type tendency. It feeds the optimal mark,
# the rationale panel, conversion, the hike reaction, and the B2B range hint. Read-only.
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

# Price-hike audience reaction: fraction of the audience that leaves on a raise.
const CHURN_MAX := 0.45

# Audience growth price-sensitivity (multiplies the hourly flow). Cheaper → audience
# swells faster; premium price slows it.
const AUD_PRICE_MULT_MIN := 0.4
const AUD_PRICE_MULT_MAX := 1.8


static func daily_tick() -> void:
	# Daily: satisfaction drift + a backstop MRR bridge. B2C audience/MRR now flow on
	# the HOURLY tick (hourly_tick); this is the slot-4 sink + B2B reflection.
	if GameState.get_flag("mvp_shipped", false):
		_tick_satisfaction()          # B2C aggregate only (B2B is routed away — see guard)
		B2BSalesSystem.daily_tick()   # B2B per-customer lifecycle (two-layer satisfaction / churn)
	_mrr_bridge()
	if OS.is_debug_build():
		print("[SalesSystem] Daily tick — MRR $%d" % GameState.mrr)


# --- Hourly tick (Economy Model v2): bidirectional audience → derived MRR ---

static func hourly_tick(_hour: int) -> void:
	if GameState.get_flag("mvp_shipped", false):
		var market: String = String(GameState.get_flag("mvp_market_type", "b2c"))
		if market == "b2c":
			_tick_b2c_audience()   # bidirectional interest flow
			_derive_b2c_mrr()      # MRR = paying(audience,price) × price
	_mrr_bridge()


# Canonical sink: reflect aggregate active-customer MRR into GameState (emits live).
static func _mrr_bridge() -> void:
	var total_mrr: int = CustomerRegistry.get_total_mrr()
	if GameState.mrr != total_mrr:
		GameState.set_mrr(total_mrr)  # emits mrr_changed → TopBar live; runway recalc


# Public bridge seam (WRITE-THROUGH LAW): cross-domain callers (event modifiers that
# change a customer's MRR) reflect the aggregate through HERE, never a hand-rolled
# GameState.set_mrr(get_total_mrr()). One reconciliation rule, one place.
static func reflect_mrr() -> void:
	_mrr_bridge()


# Bidirectional audience flow. Delta MAY be negative (erosion); audience clamps ≥ 0.
# Up: quality/brand/(positive)reputation. Down: bugs, low/negative reputation. The
# price multiplier accelerates a cheap price and slows a premium one.
static func _tick_b2c_audience() -> void:
	# TASARIM KANONU: canlı ürünün ekonomisi ASLA donmaz — ne v-build ne sprint
	# sırasında. Sprint'in bedeli artık kapasite havuzu (ProductSystem
	# capacity_speed_factor: build'le paralelse ikisi de yavaşlar), freeze değil.
	var delta: float = _audience_delta_per_hour()
	# Accumulate as float so small per-hour deltas (especially slow erosion) survive
	# instead of rounding to zero each hour; all readers int()-truncate for display.
	var audience: float = maxf(0.0, float(GameState.get_flag("b2c_audience", 0)) + delta)
	GameState.set_flag("b2c_audience", audience)


# Shared audience-growth delta (Product Lifecycle Part 1). R1 (_tick_b2c_audience)
# and R6 (growth_band) BOTH call this → the "büyüyor / eriyor" verdict can never
# drift from the actual audience motion. Quality is the normalized, type-weighted,
# effective-stability composite (bugs already baked in via effective_stability, so
# there is NO separate bug subtractor — one clean channel).
static func _audience_delta_per_hour() -> float:
	var nq: float = QualityModel.shipped_normalized()
	var quality_term: float = _rival_relative_quality(nq) if RIVAL_RELATIVE else nq
	var grow: float = (HOURLY_AUD_BASE \
		+ quality_term * HOURLY_AUD_QUALITY_COEF \
		+ GameState.brand * HOURLY_AUD_BRAND_COEF \
		+ GameState.reputation * HOURLY_AUD_REPUTATION_COEF) \
		* audience_growth_multiplier(int(GameState.get_flag("b2c_price", 0)))
	# Product Lifecycle Part 2A: a product below the bar bleeds users. quality_term
	# already folds in both erosion causes (bugs → effective stability; rival passing
	# → rival-relative drop), so this one term covers both. Churn is PROPORTIONAL to
	# the current audience (loss of existing users → 0 at audience 0, so a fresh
	# product still grows from nothing). Price-independent (outside the multiplier).
	var audience: float = float(GameState.get_flag("b2c_audience", 0))
	var churn: float = CHURN_COEF * maxf(0.0, EROSION_THRESHOLD - quality_term) * audience
	return grow - churn


# Recenters the quality term around the same-type rival average (Part 2A: ON).
# Benchmark = the STARTUP LEAGUE only (the player's real competition). Giants /
# established are aspiration, NOT the churn benchmark — averaging the full field
# (giants ≈ norm 85) would put a fresh player permanently below it → guaranteed
# death-spiral. Startup rivals advance daily, so the bar rises → "feed it or fall
# behind" pressure that stays recoverable.
static func _rival_relative_quality(player_nq: float) -> float:
	var sub: String = String(GameState.get_flag("mvp_sub_product_type_id", ""))
	var axes: Array = ProductCatalog.get_quality_axes(sub)
	var total: float = 0.0
	var n: int = 0
	for r in RivalRegistry.get_by_type(sub):
		if r.tier == "startup":
			total += QualityModel.normalized_quality(r.composite(axes))
			n += 1
	if n == 0:
		return player_nq
	var avg: float = total / float(n)
	return clampf(50.0 + (player_nq - avg), 0.0, 100.0)


# MRR derives from the live audience + price. Sets the aggregate B2C record absolutely
# (seats = paying users, mrr = paying × price). No-op until a price has been set.
static func _derive_b2c_mrr() -> void:
	if not GameState.get_flag("b2c_paid_tier_open", false):
		return  # no price yet → no paying users (audience still builds on the tick)
	var price: int = int(GameState.get_flag("b2c_price", B2C_PRICE_DEFAULT))
	var audience: int = int(GameState.get_flag("b2c_audience", 0))
	var paying: int = int(round(audience * conversion_rate(price)))
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
	base.company_name = _product_name() + " kullanıcıları"
	base.industry = "Consumer"
	base.company_size = "individual"
	base.market_type = "b2c"
	base.seats = 0
	base.mrr = 0
	base.acquisition_source = "organic"
	base.acquired_on_day = GameState.day
	base.satisfaction = clampi(seed_sat, 0, 100)
	base.update_health_from_satisfaction()
	CustomerRegistry.add(base)


# Licenses B2C revenue (opens the tier + stores the price), then derives MRR. The
# pricing ruler (apply_b2c_price) is the normal entry; kept for any event/flow that
# opens the tier directly. (No more "convert an initial chunk" — MRR derives.)
static func open_b2c_paid_tier(price: int, _initial_pct: float = 0.0) -> void:
	GameState.set_flag("b2c_paid_tier_open", true)
	GameState.set_flag("b2c_price", maxi(price, 1))
	_derive_b2c_mrr()
	_mrr_bridge()


# Event growth-spike lever (Product Hunt / power-user / referral): adds interest to the
# live audience. MRR follows automatically via the hourly derivation. Replaces the old
# "convert N audience → seats" chunk path.
static func add_b2c_audience(n: int) -> void:
	var audience: int = maxi(0, int(GameState.get_flag("b2c_audience", 0)) + n)
	GameState.set_flag("b2c_audience", audience)
	_derive_b2c_mrr()
	_mrr_bridge()


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
	# B2B lifecycle seed (Stage A): scale + hidden tolerance (scale + sector), fresh
	# onboarding window. Larger/older/loyal accounts endure low satisfaction longer.
	c.scale = prospect.scale
	c.tolerance = B2BConstants.seed_tolerance(prospect.scale, prospect.industry)
	c.lifecycle_phase = "onboarding"
	c.churn_countdown = -1
	c.risk_streak = 0
	c.support_load = B2BConstants.support_load_for(prospect.scale)
	c.onboarding_until = GameState.day + B2BConstants.ONBOARDING_DAYS
	# The feature this account wants (drives special requests + the retention promise).
	c.pain_feature_id = prospect.pain_feature_id
	if c.pain_feature_id == "":
		c.pain_feature_id = B2BSalesSystem.pick_pain_feature(
			String(GameState.get_flag("mvp_sub_product_type_id", "")), c.scale)
	c.update_health_from_satisfaction()
	CustomerRegistry.add(c)
	GameState.run_customers_signed += 1  # run counter seam (Spec 3 §3) — sole B2B signing path
	_mrr_bridge()  # reflect the signed deal immediately (canonical bridge)
	return c


static func _seats_for_archetype(archetype: String) -> int:
	return CustomerArchetypes.seats(archetype)


# --- Shared satisfaction tick ---

static func _tick_satisfaction() -> void:
	# Satisfaction rises on strong STABILITY (effective — bugs eat it) and falls
	# when the open bug count is high (the direct churn driver).
	var stab: float = QualityModel.axis_score(QualityModel.economy_dims_from_flags(), "stability")
	var bugs: int = int(GameState.get_flag("mvp_live_bug_count", GameState.get_flag("mvp_bug_count_at_launch", 0)))
	for c in CustomerRegistry.get_active():
		if c.market_type != "b2c":
			continue  # B2B satisfaction is owned by B2BSalesSystem (two-layer model); leave B2C byte-identical
		var delta: int = 0
		if stab >= SATISFACTION_QUALITY_GATE:
			delta += 1
		if bugs > SATISFACTION_BUG_GATE:
			delta -= 1
		if delta != 0:
			CustomerRegistry.set_satisfaction(c.id, c.satisfaction + delta)


# --- Traction north-star ---
# Display-only progress for the PostShip bar. The GATE itself lives in
# PhaseGateSystem (slot 8) — subgenre-agnostic, reads GameState/registry state
# daily. The old _check_traction/ready_for_traction mechanism (B2C-branch-only,
# never fired for B2B) was removed with the endgame engine (ENDGAME_DESIGN.md §2.2).

static func traction_progress() -> float:
	var mrr_ratio: float = float(GameState.mrr) / float(TRACTION_MRR_TARGET)
	var cust_ratio: float = float(CustomerRegistry.get_active().size()) / float(TRACTION_CUSTOMER_TARGET)
	return clampf(maxf(mrr_ratio, cust_ratio), 0.0, 1.0)


# --- Value algorithm (product worth → optimal price + lower bound + rationale) ---

static func product_value() -> Dictionary:
	# Read-only worth estimate from the launch snapshot. No economic delta.
	var sub: String = String(GameState.get_flag("mvp_sub_product_type_id", ""))
	var components: Array = GameState.get_flag("mvp_components", [])
	var feature_count: int = components.size()
	var total_complexity: int = 0
	for fid in components:
		var f: Dictionary = ProductCatalog.get_feature_by_id(String(fid))
		total_complexity += int(f.get("complexity", 0))
	var tendency: String = ProductCatalog.get_price_tendency(sub)
	var mult: float = float(TENDENCY_MULT.get(tendency, 1.0))
	# Pricing power = the type-weighted, effective-stability NORMALIZED composite.
	# Premium therefore comes from whatever axis THIS market values (Innovation for
	# consumer types, Stability/reliability for B2B infra — encoded in quality_axes
	# weights), and bugs dampen worth via effective stability, not a separate term.
	# (Refines the plan's "Innovation drives price" to be type-correct.)
	var nq: float = QualityModel.shipped_normalized()
	var raw: float = VALUE_BASE + nq * VALUE_QUALITY_COEF \
		+ feature_count * VALUE_FEATURE_COEF + total_complexity * VALUE_COMPLEXITY_COEF
	raw = maxf(1.0, raw) * mult
	var optimal: int = int(round(raw))
	var floor_price: int = maxi(1, int(round(optimal * VALUE_FLOOR_RATIO)))
	return {
		"optimal": optimal,
		"floor": floor_price,
		"lines": _value_lines(sub, feature_count, tendency),
		"tendency": tendency,
	}


static func _value_lines(sub: String, feature_count: int, tendency: String) -> Array:
	# One rationale line PER axis, using the type's display_label (so B2B reads
	# "Veri Güvenliği & Ölçek 63 → orta"). Working TR (Erdem voice-revises).
	var lines: Array = []
	var dims: Dictionary = QualityModel.economy_dims_from_flags()
	var axes: Array = ProductCatalog.get_quality_axes(sub)
	if axes.is_empty():
		axes = QualityModel.DEFAULT_AXES
	for a in axes:
		var axis: String = String(a.get("axis", ""))
		var label: String = String(a.get("display_label", axis))
		# A1 single-source-of-truth: show the RAW axis value (stability = effective,
		# since dims come from economy_dims_from_flags) so this badge matches the
		# left "Ürün Durumu" card byte-for-byte. The price formula is unaffected — it
		# reads QualityModel.shipped_normalized() (composite), never these badges.
		var s: int = int(round(float(dims.get(axis, 0.0))))
		# Bands re-tuned for the raw scale (axes born 0, asymptote ~110): a shipped
		# axis ≥70 reads strong, ≥45 mid. Cosmetic only (chip color/label).
		var axis_sign: int = 1 if s >= 70 else (0 if s >= 45 else -1)
		var tail: String = "güçlü" if axis_sign > 0 else ("orta" if axis_sign == 0 else "zayıf")
		lines.append({"text": "%s %d → %s" % [label, s, tail], "sign": axis_sign})
	if feature_count >= 3:
		lines.append({"text": "%d feature → dolu bir ürün" % feature_count, "sign": 1})
	else:
		lines.append({"text": "%d feature → ince bir ürün" % feature_count, "sign": 0})
	match tendency:
		"premium":
			lines.append({"text": "Bu kategori premium fiyatı kaldırır", "sign": 1})
		"volume":
			lines.append({"text": "Bu kategori hacim oyunu — düşük fiyat mantıklı", "sign": -1})
	return lines


# --- Pricing relationships (conversion / churn / audience sensitivity) ---

static func conversion_rate(price: int) -> float:
	# Standing fraction of the WHOLE audience that pays at this price (MRR derives
	# from it each hour). Cheaper than optimal → higher; pricier → lower.
	var optimal: float = maxf(1.0, float(product_value()["optimal"]))
	var rate: float = CONVERSION_BASE * (optimal / maxf(1.0, float(price)))
	return clampf(rate, CONVERSION_MIN, CONVERSION_MAX)


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


# --- The free-price lever (a played decision; the ONLY B2C revenue mover) ---

static func estimate_price_change(new_price: int) -> Dictionary:
	# Pure preview for the UI (no mutation): the audience reaction to a hike + the
	# resulting DERIVED paying users / MRR at the proposed price.
	new_price = maxi(new_price, 1)
	var was_open: bool = GameState.get_flag("b2c_paid_tier_open", false)
	var old_price: int = int(GameState.get_flag("b2c_price", 0)) if was_open else 0
	var is_raise: bool = was_open and new_price > old_price
	var audience: int = int(GameState.get_flag("b2c_audience", 0))
	var drop: float = churn_fraction(old_price, new_price) if is_raise else 0.0
	var audience_after: int = int(round(audience * (1.0 - drop)))
	var new_paying: int = int(round(audience_after * conversion_rate(new_price)))
	return {
		"old_price": old_price, "new_price": new_price, "is_raise": is_raise,
		"audience_drop_pct": drop, "audience_after": audience_after,
		"new_paying": new_paying, "new_mrr": new_paying * new_price, "old_mrr": GameState.mrr,
	}


static func apply_b2c_price(new_price: int) -> Dictionary:
	# The player set a price on the ruler. Opens the tier + stores the price; a RAISE
	# triggers an audience drop (the hike reaction). MRR is DERIVED immediately so the
	# change is felt now, and re-derives every hour via hourly_tick. This is a played
	# lever; the auto-flow it shapes is Economy Model v2 (PROJECT_SPEC §10).
	new_price = maxi(new_price, 1)
	var was_open: bool = GameState.get_flag("b2c_paid_tier_open", false)
	var old_price: int = int(GameState.get_flag("b2c_price", 0)) if was_open else 0
	var old_mrr: int = GameState.mrr
	var audience_before: int = int(GameState.get_flag("b2c_audience", 0))

	GameState.set_flag("b2c_paid_tier_open", true)
	GameState.set_flag("b2c_price", new_price)

	var drop_pct: float = 0.0
	if was_open and new_price > old_price:
		drop_pct = churn_fraction(old_price, new_price)
		GameState.set_flag("b2c_audience", maxi(0, int(round(audience_before * (1.0 - drop_pct)))))

	_derive_b2c_mrr()
	_mrr_bridge()

	var audience_after: int = int(GameState.get_flag("b2c_audience", 0))
	if OS.is_debug_build():
		print("[SalesSystem] apply_b2c_price $%d→$%d audience %d→%d (drop %d%%) MRR $%d→$%d" \
			% [old_price, new_price, audience_before, audience_after,
			int(round(drop_pct * 100.0)), old_mrr, GameState.mrr])
	return {
		"old_price": old_price, "new_price": new_price,
		"is_raise": was_open and new_price > old_price, "audience_drop_pct": drop_pct,
		"audience_before": audience_before, "audience_after": audience_after,
		"old_mrr": old_mrr, "new_mrr": GameState.mrr,
	}


# --- UI helpers ---

static func growth_band() -> String:
	# Verbal band for the audience flow DIRECTION. Uses the SAME shared delta as
	# _tick_b2c_audience (R1) so "büyüyor/eriyor" can never contradict the motion.
	var delta: float = _audience_delta_per_hour()
	if delta <= -0.1:
		return "eriyor"
	if delta < 0.15:
		return "duruyor"
	if delta >= 0.6:
		return "hızlı büyüyor"
	return "büyüyor"


static func _product_name() -> String:
	var n: String = String(GameState.get_flag("mvp_product_name", ""))
	if n != "":
		return n
	var st: Dictionary = ProductCatalog.get_sub_product_type_by_id(
		String(GameState.get_flag("mvp_sub_product_type_id", "")))
	return String(st.get("name_human", st.get("name", "Ürün")))
