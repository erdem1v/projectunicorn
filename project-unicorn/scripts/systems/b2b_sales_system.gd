class_name B2BSalesSystem
extends RefCounted

# B2B customer lifecycle engine (PostShip B2B Sales System). Pure static logic,
# no scene dependency — mirrors SalesSystem. Dispatched DAILY from
# SalesSystem.daily_tick (slot 4), AFTER the B2C-only satisfaction tick, so the
# byte-identical B2C hourly/economy path in SalesSystem is never touched. There is
# deliberately NO hourly B2B branch — B2B lifecycle is a daily cadence.
#
# Stage A ownership: the two-layer satisfaction model (visible `satisfaction`
# computed from product health; hidden per-customer `tolerance` seeded at signing),
# the lifecycle phase machine (onboarding → active → risk → churning, plus the
# healthy → expansion promotion), and the WATCHED churn countdown — churn is never
# instant, it always runs down a visible counter that recovery resets.
#
# WRITE-THROUGH LAW: every customer field change routes through a CustomerRegistry
# seam; churn goes through remove(); aggregate MRR reflects through
# SalesSystem.reflect_mrr(). Later stages add event-family selection (B),
# promise reactions (C), CS dispatch (D), and expansion (E).


# --- Daily entry (called by SalesSystem.daily_tick when mvp_shipped) ---
static func daily_tick() -> void:
	if not GameState.get_flag("mvp_shipped", false):
		return
	PromiseRegistry.tick_deadlines(GameState.day)  # §C: break promises whose deadline passed
	# get_by_market returns a FRESH array, so removing a churned customer from the
	# registry mid-loop is safe (we iterate the copy, not the backing dict).
	for c in CustomerRegistry.get_by_market("b2b"):
		_tick_customer(c)


static func _tick_customer(c: Customer) -> void:
	_tick_satisfaction(c)
	_tick_lifecycle(c)


# --- Layer 1: visible satisfaction drifts toward a product-health target ---
static func _tick_satisfaction(c: Customer) -> void:
	var target: int = _satisfaction_target(c)
	var step: int = B2BConstants.SAT_DRIFT_STEP
	# Onboarding window (first ~ONBOARDING_DAYS after signing): first impressions
	# swing harder — a bug-heavy product at signing bites more, a solid one wins faster.
	if GameState.day < c.onboarding_until:
		step = int(ceil(float(step) * B2BConstants.ONBOARDING_AMP))
	var delta: int = clampi(target - c.satisfaction, -step, step)
	# CS delegation (Stage D): a good CS keeps hands-off customers happier — dampen the
	# EROSION (downward drift) by the rep's skill. Upward recovery stays full-strength.
	if delta < 0 and c.assigned_to != "":
		delta = int(float(delta) * B2BConstants.cs_dampen(_cs_skill_of(c)))
	if delta != 0:
		CustomerRegistry.set_satisfaction(c.id, c.satisfaction + delta)


static func _cs_skill_of(c: Customer) -> int:
	if c.assigned_to == "":
		return 0
	var cs: Character = CharacterRegistry.get_character(c.assigned_to)
	return int(cs.role_stats.get("cs_skill", 0)) if cs != null else 0


static func _satisfaction_target(c: Customer) -> int:
	# Product-health channel — the SAME effective-stability signal the rest of the
	# economy reads (bugs already folded into effective stability via economy dims,
	# so there is no separate bug subtractor). NO price link (B2B is not price-driven).
	# The promise-kept/broken term is blended in Stage C via _promise_offset.
	var health: float = QualityModel.axis_score(QualityModel.economy_dims_from_flags(), "stability")
	var target: float = health + _promise_offset(c)
	# Rival pressure (−) is a TODO hook, gated OFF until a rival system exists (A.2).
	if B2BConstants.RIVAL_SATISFACTION_HOOK:
		target -= _rival_pressure(c)
	return clampi(int(round(target)), 0, 100)


# Stage C hook: kept promises lift the satisfaction target, broken ones depress it.
# Stage A returns 0 (no promise system yet) — PromiseRegistry wires this in Stage C.
static func _promise_offset(_c: Customer) -> float:
	return 0.0


# TODO (rival system): erode satisfaction when a same-sector rival passes the
# player. Gated OFF (B2BConstants.RIVAL_SATISFACTION_HOOK) — no fake behavior.
static func _rival_pressure(_c: Customer) -> float:
	return 0.0


# --- Layer 2 + phase machine: hidden tolerance vs satisfaction → churn countdown ---
static func _tick_lifecycle(c: Customer) -> void:
	if c.assigned_to != "":
		_tick_cs_managed(c)  # delegated: no passive risk/countdown — escalate instead (Stage D)
		return
	if c.satisfaction < c.tolerance:
		_tick_at_risk(c)
	else:
		_tick_healthy(c)


static func _tick_cs_managed(c: Customer) -> void:
	# A CS-managed account runs NO passive risk/countdown and produces no routine events.
	# The exception: ONE escalation to the player when it crosses the critical threshold
	# the CS can no longer hold. Recovery above the threshold re-arms it.
	if c.satisfaction < B2BConstants.CS_ESCALATION_SAT:
		if not c.cs_escalated:
			c.cs_escalated = true
			_enqueue_cs_escalation(c)
	else:
		c.cs_escalated = false


static func _enqueue_cs_escalation(c: Customer) -> void:
	var cs: Character = CharacterRegistry.get_character(c.assigned_to)
	if cs == null:
		return
	EventManager.enqueue(B2BEventFactory.build_cs_escalation(c, cs))


static func _tick_at_risk(c: Customer) -> void:
	# Below this customer's tolerance: build the streak, then start (and run down)
	# the visible churn countdown. Churn ONLY at the counter's zero — never instant.
	CustomerRegistry.set_risk_streak(c.id, c.risk_streak + 1)
	if c.lifecycle_phase != "risk":
		if c.risk_streak >= B2BConstants.RISK_TRIGGER_DAYS:
			CustomerRegistry.set_lifecycle_phase(c.id, "risk")
			CustomerRegistry.set_churn_countdown(c.id, B2BConstants.CHURN_COUNTDOWN_DAYS)
			_maybe_enqueue_retention(c)  # founder-managed → present the decision (Stage B)
		return
	var next_countdown: int = c.churn_countdown - 1
	CustomerRegistry.set_churn_countdown(c.id, next_countdown)
	if next_countdown <= 0:
		_churn(c)


# Family selection is STATE-BOUND (never random): a founder-managed customer that
# has just crossed into Risk produces the retention decision. CS-managed customers
# escalate differently (Stage D), so they get no routine retention event here.
static func _maybe_enqueue_retention(c: Customer) -> void:
	if c.assigned_to != "":
		return
	EventManager.enqueue(B2BEventFactory.build_retention(c))


static func _tick_healthy(c: Customer) -> void:
	# Satisfaction is at/above tolerance: recovery resets the risk machinery, and
	# the phase advances onboarding → active → (mature) expansion.
	if c.risk_streak != 0:
		CustomerRegistry.set_risk_streak(c.id, 0)
	if c.lifecycle_phase == "risk":
		CustomerRegistry.set_churn_countdown(c.id, -1)
		CustomerRegistry.set_lifecycle_phase(c.id, "active")
	if c.lifecycle_phase == "onboarding" and GameState.day >= c.onboarding_until:
		CustomerRegistry.set_lifecycle_phase(c.id, "active")
	elif c.lifecycle_phase == "active" and (GameState.day - c.acquired_on_day) >= B2BConstants.EXPANSION_MATURE_DAYS:
		# Healthy + mature → the positive family: a seat/MRR upsell opportunity.
		CustomerRegistry.set_lifecycle_phase(c.id, "expansion")
		EventManager.enqueue(B2BEventFactory.build_expansion(c))


static func _churn(c: Customer) -> void:
	# Loss from the watched counter (the passive path).
	_remove_lost(c)


static func _remove_lost(c: Customer) -> void:
	# Shared account-loss seam (passive churn + deliberate "Bırak"). Run counter + churn
	# signal first (so a listener can still read the record), then remove + reflect MRR.
	GameState.run_customers_lost += 1  # run counter seam (Spec 3 §3), B2B loss path
	CustomerRegistry.set_lifecycle_phase(c.id, "churning")
	EventBus.customer_churned.emit(c.id)
	CustomerRegistry.remove(c.id)      # emits customer_removed
	SalesSystem.reflect_mrr()          # canonical MRR bridge after the account leaves


# --- Stage B: retention outcomes (called by event modifiers; WRITE-THROUGH LAW) ---

static func accept_promise(customer_id: String, feature_id: String, deadline_days: int) -> void:
	# "Söz ver": create a promise (a debt) and the customer stays — recovered from Risk.
	var c: Customer = CustomerRegistry.get_customer(customer_id)
	if c == null:
		return
	PromiseRegistry.create(customer_id, feature_id, deadline_days)
	# A prior broken word makes a fresh promise land with less goodwill (§C credibility).
	var bump: int = B2BConstants.RETAIN_SAT_BUMP
	if GameState.get_flag("b2b_broke_%s" % customer_id, false):
		bump = int(bump / 2)
	_recover(c, bump)


static func hold(customer_id: String) -> void:
	# "Oyala": buy time by pushing the churn countdown out. Works RETAIN_DELAY_MAX_USES
	# times, then the customer catches on (no more extension; erosion keeps going).
	var c: Customer = CustomerRegistry.get_customer(customer_id)
	if c == null:
		return
	if c.retain_stalls >= B2BConstants.RETAIN_DELAY_MAX_USES:
		return  # caught on — stalling no longer works
	c.retain_stalls += 1
	if c.lifecycle_phase == "risk" and c.churn_countdown >= 0:
		CustomerRegistry.set_churn_countdown(c.id, c.churn_countdown + B2BConstants.RETAIN_DELAY_DAYS)


static func apply_discount(customer_id: String, mrr_delta: int) -> void:
	# "İndirim ver": MRR drops by the pre-computed delta, the customer stays (recovers
	# from Risk). The delta is computed in B2BEventFactory so the modal can show the
	# figure; the seam just applies it through the MRR seam + bridge.
	var c: Customer = CustomerRegistry.get_customer(customer_id)
	if c == null:
		return
	if mrr_delta != 0:
		CustomerRegistry.set_mrr(c.id, c.mrr + mrr_delta)
		SalesSystem.reflect_mrr()
	_recover(c, B2BConstants.RETAIN_SAT_BUMP)


static func release(customer_id: String) -> void:
	# "Bırak": deliberately lose the account (brand hit rides as a separate modifier).
	var c: Customer = CustomerRegistry.get_customer(customer_id)
	if c == null:
		return
	_remove_lost(c)


# --- Stage D: CS escalation outcomes (called by event modifiers) ---

static func honor_cs_promise(customer_id: String, feature_id: String, deadline_days: int) -> void:
	# "Tamam, sözü tut": honor the word the CS gave — create the promise (routes into §C)
	# and keep the account. The CS's committed word is honored.
	accept_promise(customer_id, feature_id, deadline_days)
	var c: Customer = CustomerRegistry.get_customer(customer_id)
	if c != null:
		c.cs_escalated = false


static func refuse_cs_promise(customer_id: String) -> void:
	# "Hayır, yapmıyoruz": the CS's promise is refused → the account churns. Brand down and
	# the CS's morale drop ride as separate modifiers on the choice (see B2BEventFactory).
	var c: Customer = CustomerRegistry.get_customer(customer_id)
	if c != null:
		_remove_lost(c)


# --- Stage E: expansion (upsell). Healthy mature accounts grow seats → MRR, which
#     also raises support load (feeding the need for a CS rep). ---
static func expand(customer_id: String, add_seats: int, per_seat_mrr: int) -> void:
	var c: Customer = CustomerRegistry.get_customer(customer_id)
	if c == null or add_seats <= 0:
		return
	CustomerRegistry.set_seats(c.id, c.seats + add_seats)
	CustomerRegistry.set_mrr(c.id, c.mrr + add_seats * per_seat_mrr)
	SalesSystem.reflect_mrr()
	c.support_load += 1  # a bigger account is heavier to support (feeds CS demand)
	GameState.run_customers_expanded += 1  # run counter seam (Spec 3 §3) — genuine upsell only
	EventBus.customer_expanded.emit(c.id, c.seats)
	# Back to a settled account after the upsell moment.
	if c.lifecycle_phase == "expansion":
		CustomerRegistry.set_lifecycle_phase(c.id, "active")


static func decline_expansion(customer_id: String) -> void:
	# "Şimdilik gerek yok": no growth, the account settles back to active (a real,
	# different state — the upsell simply does not happen; no counter, no MRR move).
	var c: Customer = CustomerRegistry.get_customer(customer_id)
	if c != null and c.lifecycle_phase == "expansion":
		CustomerRegistry.set_lifecycle_phase(c.id, "active")


static func founder_managed_count() -> int:
	# Founder-managed (unassigned) B2B accounts — the ~constant decision surface. The Sales
	# UI reads this against B2BConstants.FOUNDER_DIRECT_CAP to prompt delegation (hire CS).
	var n: int = 0
	for c in CustomerRegistry.get_by_market("b2b"):
		if c.assigned_to == "":
			n += 1
	return n


static func _recover(c: Customer, sat_bump: int) -> void:
	# The customer stays: relieve satisfaction and clear the risk machinery.
	CustomerRegistry.set_satisfaction(c.id, c.satisfaction + sat_bump)
	CustomerRegistry.set_risk_streak(c.id, 0)
	if c.lifecycle_phase == "risk":
		CustomerRegistry.set_churn_countdown(c.id, -1)
		CustomerRegistry.set_lifecycle_phase(c.id, "active")


# --- Stage C: the sales-domain reaction to a promise resolving (called by
#     PromiseRegistry; routes every customer/brand write through owning seams). ---
static func on_promise_resolved(p: Promise) -> void:
	var c: Customer = CustomerRegistry.get_customer(p.customer_id)
	match p.status:
		"kept":
			# Word kept on time: satisfaction + tolerance jump, loyalty up, credibility
			# restored (a future promise lands full-strength again).
			if c != null:
				CustomerRegistry.set_satisfaction(c.id, c.satisfaction + B2BConstants.PROMISE_KEPT_SAT)
				CustomerRegistry.set_tolerance(c.id, c.tolerance + B2BConstants.PROMISE_KEPT_TOLERANCE)
			GameState.set_flag("b2b_broke_%s" % p.customer_id, false)
		"partial":
			# Shipped late: a soft satisfaction penalty (better than an outright break).
			if c != null:
				CustomerRegistry.set_satisfaction(c.id, c.satisfaction + B2BConstants.PROMISE_PARTIAL_SAT)
		"broken":
			# Deadline passed unshipped: the customer returns angrier (double drop),
			# brand takes a hit, and a future "Söz ver" is less credible with them.
			if c != null:
				CustomerRegistry.set_satisfaction(c.id, c.satisfaction + B2BConstants.PROMISE_BROKEN_SAT)
				CustomerRegistry.set_tolerance(c.id, c.tolerance + B2BConstants.PROMISE_BROKEN_TOLERANCE)
			GameState.set_brand(GameState.brand + B2BConstants.PROMISE_BROKEN_BRAND)
			GameState.set_flag("b2b_broke_%s" % p.customer_id, true)


# --- Feature-pool binding (B.4): the pain a prospect/customer voices maps to a
#     feature that EXISTS in the active product's pool (so a promise is buildable). ---
static func pick_pain_feature(sub_id: String, index: int) -> String:
	if sub_id == "":
		return ""
	var pool: Array = ProductCatalog.get_feature_pool(sub_id)
	if pool.is_empty():
		return ""
	var f: Dictionary = pool[index % pool.size()]
	return String(f.get("id", ""))
