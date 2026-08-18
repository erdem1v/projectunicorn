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
	# The order below is load-bearing; each step reads what the previous one settled.
	#  1. Break promises whose deadline passed, so today's trust ledger is current before any
	#     satisfaction target is computed.
	#  2. Stewardship reconcile, so today's dampen and today's routing see the settled roster.
	#  3. The per-customer lifecycle sweep (unchanged).
	#  4. The customer desk's request channel, AFTER the sweep, so a request reads today's
	#     settled satisfaction rather than yesterday's.
	#  5. The sales desk LAST: an autonomous close creates a Customer, and a same-day-signed
	#     account must not be lifecycle-ticked on its signing day — a founder-pitched account
	#     never is, because the pitch resolves mid-day after this slot.
	PromiseRegistry.tick_deadlines(GameState.day)  # §C: break promises whose deadline passed
	CustomerRepSystem.reconcile_assignments()
	# get_by_market returns a FRESH array, so removing a churned customer from the
	# registry mid-loop is safe (we iterate the copy, not the backing dict).
	for c in CustomerRegistry.get_by_market("b2b"):
		_tick_customer(c)
	CustomerRepSystem.daily_tick()
	SalesRepSystem.daily_tick()


static func _tick_customer(c: Customer) -> void:
	_tick_trust(c)
	_tick_satisfaction(c)
	# Escalation is a SIBLING of the lifecycle tick now, not a replacement for it (see
	# _tick_lifecycle), and it runs FIRST so that on a day when an account would both cross
	# into Risk and sink past the rep's threshold, the rep gets to speak and the generic
	# retention modal stands down — one situation, one decision moment.
	_tick_cs_escalation(c)
	_tick_lifecycle(c)


static func _tick_trust(c: Customer) -> void:
	# The trust ledger forgives on its own. Runs BEFORE the satisfaction drift so today's
	# target already reflects today's (slightly smaller) grudge — a broken promise makes an
	# account fragile for a month, not forever.
	if is_zero_approx(c.trust_offset):
		return
	CustomerRegistry.set_trust_offset(c.id,
		move_toward(c.trust_offset, 0.0, B2BConstants.TRUST_OFFSET_DECAY_PER_DAY))


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
		delta = int(float(delta) * B2BConstants.cs_dampen(_cs_expertise_of(c)))
	if delta != 0:
		CustomerRegistry.set_satisfaction(c.id, c.satisfaction + delta)


static func _cs_expertise_of(c: Customer) -> int:
	# The assigned rep's UZMANLIK, read straight off the axis — the conversion shim is gone.
	# An ON-LEAVE rep dampens nothing (design doc §8: capacity/CS contribution stops), so the
	# account erodes at full strength while they are away.
	if c.assigned_to == "":
		return 0
	var cs: Character = CharacterRegistry.get_character(c.assigned_to)
	if cs == null or cs.status != HRConstants.STATUS_ACTIVE:
		return 0
	return int(cs.role_stats.get(HRConstants.AXIS_EXPERTISE, 0))


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


# Kept promises lift the satisfaction target, broken ones depress it. This was a `return 0.0`
# stub whose own comment said Stage C would wire it — nothing ever did, and the consequence was
# that PROMISE_BROKEN_SAT's -20 was a one-shot the daily drift erased inside a week (only the
# tolerance move survived), while every B2B account shared one identical target: the global
# stability score. Task 2b wires it to the per-customer trust ledger, which makes the broken
# word DURABLE and gives the target its first genuine per-account differentiator.
static func _promise_offset(c: Customer) -> float:
	return c.trust_offset


# TODO (rival system): erode satisfaction when a same-sector rival passes the
# player. Gated OFF (B2BConstants.RIVAL_SATISFACTION_HOOK) — no fake behavior.
static func _rival_pressure(_c: Customer) -> float:
	return 0.0


# --- Layer 2 + phase machine: hidden tolerance vs satisfaction → churn countdown ---
static func _tick_lifecycle(c: Customer) -> void:
	# EVERY account runs the risk machinery, delegated or not.
	#
	# This used to short-circuit on `assigned_to != ""` into a CS-managed branch that ran no
	# risk streak, no churn countdown and no _churn at all — a delegated account's ONLY loss
	# path was the player choosing to refuse a promise. That was harmless while nothing in the
	# game ever assigned an account, but Task 2b makes delegation automatic, and the branch
	# would then have meant: one Müşteri Temsilcisi permanently immunises up to cs_capacity
	# accounts against churn (even while that rep is on LEAVE, where the dampen drops to zero
	# but the immunity would not). That is Calibration Law 1's named failure — a feature that
	# lets the player permanently solve money.
	#
	# What a rep does instead is what the role actually promises: cs_dampen slows the erosion
	# (see _tick_satisfaction) and the request channel absorbs routine noise. A genuine churn
	# risk is ALWAYS the founder's call. That is also Tier-2 grammar — delegate, set policy,
	# intervene on exceptions — and it makes both halves of the customer_rep phase hint
	# ("Müşteri taleplerini karşılar, kaybı yavaşlatır") literally true.
	if c.satisfaction < c.tolerance:
		_tick_at_risk(c)
	else:
		_tick_healthy(c)


static func _tick_cs_escalation(c: Customer) -> void:
	# A delegated account still raises ONE escalation when it sinks past the level its rep can
	# hold; recovery above the threshold re-arms it. This is now a SIBLING of the lifecycle
	# tick rather than a replacement for it (see _tick_lifecycle), so the escalation and the
	# ordinary risk/retention machinery both run — the player hears from the rep AND still
	# owns the churn decision.
	if c.assigned_to == "":
		c.cs_escalated = false
		return
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


# Family selection is STATE-BOUND (never random): a customer that has just crossed into Risk
# produces the retention decision. The `assigned_to != ""` early-return that used to sit here
# is gone with the CS bypass — an account sliding toward churn is the founder's call whether
# or not a rep is stewarding it, and suppressing the decision was the other half of the
# immunity hole. The rep's own voice is the separate escalation in _tick_cs_escalation.
static func _maybe_enqueue_retention(c: Customer) -> void:
	# The ONE narrow case where a delegated account skips this: its rep has an escalation open
	# right now. That escalation is already a decision about this exact account and resolves it
	# either way (honour → promise + recovery, refuse → the account leaves), so raising the
	# generic retention modal on top would be two modals for one situation. This is NOT the old
	# blanket `assigned_to != ""` guard: the risk machinery keeps running underneath, the
	# countdown keeps ticking, and it still expires into _churn.
	if c.assigned_to != "" and c.cs_escalated:
		return
	EventManager.enqueue(B2BEventFactory.build_retention(c))


static func _tick_healthy(c: Customer) -> void:
	# Satisfaction is at/above tolerance: recovery resets the risk machinery, and
	# the phase advances onboarding → active → (mature) expansion.
	#
	# ONE TRANSITION PER TICK. set_lifecycle_phase writes through to this very instance,
	# so a chain that re-reads c.lifecycle_phase after writing it takes two steps in one
	# call: a rescued account went risk → active → expansion the same day, and the upsell
	# modal opened on the morning the customer was talked out of leaving. Read the phase
	# ONCE, at entry, and return after whichever transition fires.
	if c.risk_streak != 0:
		CustomerRegistry.set_risk_streak(c.id, 0)
	var phase_at_entry: String = c.lifecycle_phase

	if phase_at_entry == "risk":
		CustomerRegistry.set_churn_countdown(c.id, -1)
		# Recovering INSIDE the onboarding window returns to onboarding, not active: the
		# window is a fact about the calendar, not about how the account felt in between,
		# and the satisfaction model keeps amplifying until it closes. Sending it to
		# "active" here ended onboarding early and left phase and model disagreeing for
		# the rest of the window.
		CustomerRegistry.set_lifecycle_phase(c.id,
			"onboarding" if GameState.day < c.onboarding_until else "active")
		return

	if phase_at_entry == "onboarding":
		if GameState.day >= c.onboarding_until:
			CustomerRegistry.set_lifecycle_phase(c.id, "active")
		return

	if phase_at_entry != "active":
		return   # expansion / churning are not promotable states

	if not can_offer_expansion(c):
		return
	# Healthy + mature + never offered before → the positive family: a seat/MRR upsell.
	CustomerRegistry.set_lifecycle_phase(c.id, "expansion")
	EventManager.enqueue(B2BEventFactory.build_expansion(c))


# THE EXPANSION GATE, in one place so the daily sweep and the Sales-tab button cannot
# drift apart. The tab's manual trigger bypasses _tick_healthy entirely, so a latch that
# lived only in the sweep would leave the loop wide open through the UI.
static func can_offer_expansion(c: Customer) -> bool:
	if c == null or c.market_type != "b2b" or c.status != "active":
		return false
	if c.last_expansion_day >= 0:
		return false   # this account has already had its expansion moment
	return (GameState.day - c.acquired_on_day) >= B2BConstants.EXPANSION_MATURE_DAYS


static func _churn(c: Customer) -> void:
	# Loss from the watched counter (the passive path — countdown reached zero). The
	# brand hit lands HERE, at the actual churn moment (moved off the retention "Kendi
	# haline bırak" option). CS-refuse churn keeps its own brand modifier and does NOT
	# route through _churn, so there is no double-apply.
	GameState.set_brand(GameState.brand + B2BConstants.CHURN_BRAND)
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


static func ignore_risk(_customer_id: String) -> void:
	# "Kendi haline bırak": choose not to intervene. Deliberate NO-OP — the customer
	# stays in Risk and keeps paying; the churn countdown (already running) continues on
	# the daily tick and fires _churn on its own at zero. No instant state change here.
	pass


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
	# (The old `c.support_load += 1` here is gone with the field — see customer.gd. The
	# "bigger account is heavier to support" pressure is real and survives: the request channel
	# reads `scale`, and an expanded account keeps its scale.)
	GameState.run_customers_expanded += 1  # run counter seam (Spec 3 §3) — genuine upsell only
	EventBus.customer_expanded.emit(c.id, c.seats)
	# Back to a settled account after the upsell moment — and STAMP the latch, or the
	# account lands right back on the condition that promoted it and re-fires tomorrow.
	CustomerRegistry.set_last_expansion_day(c.id, GameState.day)
	if c.lifecycle_phase == "expansion":
		CustomerRegistry.set_lifecycle_phase(c.id, "active")


static func decline_expansion(customer_id: String) -> void:
	# "Şimdilik gerek yok": no growth, the account settles back to active (a real,
	# different state — the upsell simply does not happen; no counter, no MRR move).
	# The latch is stamped on BOTH branches: declining is an answer, not a postponement,
	# and leaving it unstamped is what made "no" mean "ask me again tomorrow, forever".
	var c: Customer = CustomerRegistry.get_customer(customer_id)
	if c == null:
		return
	CustomerRegistry.set_last_expansion_day(c.id, GameState.day)
	if c.lifecycle_phase == "expansion":
		CustomerRegistry.set_lifecycle_phase(c.id, "active")


static func founder_managed_count() -> int:
	# Founder-managed (unassigned) B2B accounts. Read against B2BConstants.FOUNDER_DIRECT_CAP
	# by CustomerRepSystem, which delegates only the EXCESS above that cap, and by the Sales
	# tab's "doğrudan yönettiğin hesap" line. (Until Task 2b this had zero callers and its
	# docstring claimed the Sales UI already read it, which was not true.)
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
		# Same onboarding-window rule _tick_healthy already follows (see the note at its
		# "risk" branch): the window is a fact about the CALENDAR, not about how the
		# account felt in between, and _tick_satisfaction keeps amplifying until it
		# closes. Writing "active" unconditionally ended onboarding early for any account
		# rescued inside its first 30 days and left the phase and the drift model
		# disagreeing for the rest of the window — the identical bug that branch was
		# fixed for, still live on this one. Observed in a driver run: an account signed
		# on day 1 was stamped "active" on day 4 with onboarding_until = 31.
		CustomerRegistry.set_lifecycle_phase(c.id,
			"onboarding" if GameState.day < c.onboarding_until else "active")


# --- Stage C: the sales-domain reaction to a promise resolving (called by
#     PromiseRegistry; routes every customer/brand write through owning seams). ---
static func on_promise_resolved(p: Promise) -> void:
	var c: Customer = CustomerRegistry.get_customer(p.customer_id)
	match p.status:
		"kept":
			# Word kept on time: satisfaction + tolerance jump, loyalty up, credibility
			# restored (a future promise lands full-strength again).
			if c != null:
				CustomerRegistry.set_tolerance(c.id, c.tolerance + B2BConstants.PROMISE_KEPT_TOLERANCE)
				# Lift the TARGET too, so the goodwill outlives the day it was earned.
				CustomerRegistry.set_trust_offset(c.id, c.trust_offset + B2BConstants.PROMISE_KEPT_OFFSET)
				# THE SATISFACTION BUMP GOES THROUGH _recover, NOT through a bare
				# set_satisfaction, and the difference is the churn countdown.
				#
				# accept_promise — merely GIVING the word — already calls _recover, which
				# clears the countdown and the risk streak on the spot. KEEPING the word
				# used to write satisfaction and nothing else, so the clock kept running
				# through the delivery: the rescue had to wait for the next daily tick and
				# only arrived if the +15/−5 happened to clear the tolerance bar in one
				# step. When the gap was wider than that (an account whose tolerance had
				# been ratcheted up by earlier broken promises), the player paid cash and
				# days for a feature and watched the account leave anyway.
				# Promising saved the customer; delivering did not. Same seam now, both.
				_recover(c, B2BConstants.PROMISE_KEPT_SAT)
			GameState.set_flag("b2b_broke_%s" % p.customer_id, false)
		"partial":
			# Shipped late: a soft satisfaction penalty (better than an outright break).
			if c != null:
				CustomerRegistry.set_satisfaction(c.id, c.satisfaction + B2BConstants.PROMISE_PARTIAL_SAT)
				CustomerRegistry.set_trust_offset(c.id, c.trust_offset + B2BConstants.PROMISE_PARTIAL_OFFSET)
		"broken":
			# Deadline passed unshipped: the customer returns angrier (double drop),
			# brand takes a hit, and a future "Söz ver" is less credible with them.
			if c != null:
				CustomerRegistry.set_satisfaction(c.id, c.satisfaction + B2BConstants.PROMISE_BROKEN_SAT)
				CustomerRegistry.set_tolerance(c.id, c.tolerance + B2BConstants.PROMISE_BROKEN_TOLERANCE)
				# THE DURABLE HALF. Without this the -20 above is walked back by SAT_DRIFT_STEP
				# within a week and a broken word leaves no trace at all.
				CustomerRegistry.set_trust_offset(c.id, c.trust_offset + B2BConstants.PROMISE_BROKEN_OFFSET)
				# INSIDE the null guard, like every customer-side write above it. These two
				# sat outside it, so a promise that outlived its account still charged brand
				# — a drop with no event, no modal and no cause the player could attribute —
				# and stamped a credibility flag for a company that no longer exists.
				# PromiseRegistry now drops open promises when the account leaves, so this
				# is the second lock on the same door rather than the only one.
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
	# An UNSHIPPED feature, walking the pool from the caller's index so the choice stays
	# deterministic and evenly spread. Drawing from the whole pool meant an account could
	# be born wanting something the product already had — which is not a pain, and which
	# turned any promise made about it into either a free win or an unfair loss.
	var live: Array = GameState.get_flag("mvp_components", [])
	for step in pool.size():
		var cand: Dictionary = pool[(index + step) % pool.size()]
		var cand_id: String = String(cand.get("id", ""))
		if cand_id != "" and not live.has(cand_id):
			return cand_id
	# Every feature in the pool is already live: this account has nothing left to want.
	# "" is the honest answer and the existing no-pain contract everywhere downstream.
	return ""
