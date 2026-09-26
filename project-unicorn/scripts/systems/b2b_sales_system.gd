class_name B2BSalesSystem
extends RefCounted

# B2B customer lifecycle engine. Pure static logic, no scene dependency — mirrors SalesSystem.
# Dispatched DAILY from SalesSystem.daily_tick (slot 4, B2B market only), AFTER the B2C-only
# satisfaction tick. There is deliberately NO hourly B2B branch — B2B lifecycle is a daily cadence.
#
# Owns the two-layer satisfaction model (visible `satisfaction` computed from product health;
# hidden per-customer `tolerance` seeded at signing), the lifecycle phase machine (onboarding →
# active → risk → churning, plus the healthy → expansion promotion), and the WATCHED churn
# countdown — churn is never instant, it always runs down a visible counter that recovery resets.
#
# WRITE-THROUGH LAW: every customer field change routes through a CustomerRegistry seam; churn
# goes through remove(); aggregate MRR reflects through SalesSystem.reflect_mrr().


# --- Daily entry (called by SalesSystem.daily_tick for a shipped B2B product) ---
static func daily_tick() -> void:
	if not GameState.get_flag("mvp_shipped", false):
		return
	# The order below is load-bearing; each step reads what the previous one settled.
	#  1. Break promises whose deadline passed, so today's trust ledger is current before any
	#     satisfaction target is computed.
	#  2. Stewardship reconcile, so today's dampen and today's routing see the settled roster.
	#  3. The per-customer lifecycle sweep.
	#  4. The customer desk's request channel, AFTER the sweep, so a request reads today's
	#     settled satisfaction rather than yesterday's.
	#  5. The sales desk LAST: an autonomous close creates a Customer, and a same-day-signed
	#     account must not be lifecycle-ticked on its signing day — a founder-pitched account
	#     never is, because the pitch resolves mid-day after this slot.
	PromiseRegistry.tick_deadlines(GameState.day)
	CustomerRepSystem.reconcile_assignments()
	# get_by_market returns a FRESH array, so removing a churned customer from the
	# registry mid-loop is safe (we iterate the copy, not the backing dict).
	for c in CustomerRegistry.get_by_market("b2b"):
		_tick_customer(c)
	CustomerRepSystem.daily_tick()
	# SATIŞ rev 6 §3/§4 — the faucet and the pipeline clock run BEFORE the sales desk, so a
	# rep starting work today can pick up a lead that arrived today. It is NOT gated on
	# staffing: §3's base inbound continues with zero sales staff.
	SalesFaucetSystem.daily_tick()
	SalesRepSystem.daily_tick()


static func _tick_customer(c: Customer) -> void:
	# The trust ledger forgives on its own, BEFORE the satisfaction drift, so today's target
	# already reflects today's (slightly smaller) grudge — a broken promise makes an account
	# fragile for a month, not forever.
	if not is_zero_approx(c.trust_offset):
		CustomerRegistry.set_trust_offset(c.id,
			move_toward(c.trust_offset, 0.0, B2BConstants.TRUST_OFFSET_DECAY_PER_DAY))
	_tick_satisfaction(c)
	# A delegated account raises ONE escalation when it sinks past the level its rep can hold;
	# recovery above the threshold re-arms it. The flag IS the edge: `customer.cs_escalation`
	# reads it through `musteri.cs_escalated` (and the `escalated` scope selector), and the
	# gate decides. It is set BEFORE the lifecycle step, so any edge that step emits
	# (customer_health_changed) is evaluated against today's escalation state.
	c.cs_escalated = c.assigned_to != "" and c.satisfaction < B2BConstants.CS_ESCALATION_SAT
	# EVERY account runs the risk machinery, delegated or not: the player hears from the rep
	# AND still owns the churn decision. A rep slows the erosion (cs_dampen, see
	# _tick_satisfaction) and the request channel absorbs routine noise; a genuine churn risk
	# is ALWAYS the founder's call. Exempting delegated accounts would let one Müşteri
	# Temsilcisi immunise a whole roster against churn — a feature that lets the player
	# permanently solve money.
	if c.satisfaction < c.tolerance:
		_tick_at_risk(c)
	else:
		_tick_healthy(c)


# --- Layer 1: visible satisfaction drifts toward a product-health target ---
static func _tick_satisfaction(c: Customer) -> void:
	var target: int = _satisfaction_target(c)
	var step: int = B2BConstants.SAT_DRIFT_STEP
	# Onboarding window (first ~ONBOARDING_DAYS after signing): first impressions
	# swing harder — a bug-heavy product at signing bites more, a solid one wins faster.
	if GameState.day < c.onboarding_until:
		step = int(ceil(float(step) * B2BConstants.ONBOARDING_AMP))
	var delta: int = clampi(target - c.satisfaction, -step, step)
	# İLGİLENİLEN HESAP DAHA YAVAŞ AŞINIR, ve "ilgilenen" hesabın SAHİBİDİR (bkz.
	# _account_owner): kurucunun kendi masasındaki hesap da aynı formülle korunur, özel kural yok.
	# Bonus ETKİN ÇIKTIDAN okunur, ham eksenden değil: `HRSystem.effective_skill` alan
	# katsayısını, odağı (iki iş = 0,50), moral bandını ve huy çarpanlarını uyguluyor.
	# YALNIZ AŞAĞI YÖNDE: yukarı toparlanma tam güçte kalır.
	#
	# DESIGN-PARKED: the erosion MULTIPLIER is the working shape for the care bonus. The named
	# alternative is widening the account's tolerance instead — a different feel (the account
	# forgives more rather than souring slower) and a different interaction with §5.2's loss
	# reasons, so it is the director's call.
	if delta < 0:
		var owner: Character = _account_owner(c)
		if owner != null:
			var output: float = HRSystem.effective_skill(owner, HRConstants.AREA_CUSTOMER_SUCCESS)
			delta = int(float(delta) * B2BConstants.cs_dampen(int(round(output))))
			# HAYIR DİYEMEZ: kendi hesaplarında memnuniyet daha yüksek durur. Bir DELTA
			# ÜRETMİYOR — var olan aşınmayı daha da yumuşatıyor, yani "oynanmamış
			# ekonomik sonuç yok" kuralı duruyor: düşüşün sebebi hep ürün sağlığı.
			var bonus: float = HRConstants.trait_sum(owner.traits, "satisfaction_bonus")
			if bonus > 0.0:
				delta = int(float(delta) * maxf(0.0, 1.0 - bonus / 100.0))
	if delta != 0:
		CustomerRegistry.set_satisfaction(c.id, c.satisfaction + delta)


## WHO LOOKS AFTER THIS ACCOUNT. A named rep, or the founder when nobody is named:
## `assigned_to == ""` means "on the founder's own desk", never "nobody" (`assign_customer`'s
## own contract says so).
##
## AN ABSENT OWNER CARES FOR NOBODY: an on-leave or in-training rep dampens nothing, and the
## account erodes at full strength while they are away (Ekip §8.6). `null` is that answer.
static func _account_owner(c: Customer) -> Character:
	var owner: Character = CharacterRegistry.get_founder() if c.assigned_to == "" \
		else CharacterRegistry.get_character(c.assigned_to)
	if owner == null or owner.status != HRConstants.STATUS_ACTIVE:
		return null
	return owner


static func _satisfaction_target(c: Customer) -> int:
	# Product-health channel — the SAME effective-stability signal the rest of the
	# economy reads (bugs already folded into effective stability via economy dims,
	# so there is no separate bug subtractor). NO price link (B2B is not price-driven).
	# Kept promises lift the target and broken ones depress it through the per-customer trust
	# ledger: that is what makes a broken word DURABLE (the daily drift would otherwise walk
	# PROMISE_BROKEN_SAT back within a week) and gives each account its own target.
	var health: float = QualityModel.axis_score(QualityModel.economy_dims_from_flags(), "stability")
	return clampi(int(round(health + c.trust_offset)), 0, 100)


# --- Layer 2 + phase machine: hidden tolerance vs satisfaction → churn countdown ---
static func _tick_at_risk(c: Customer) -> void:
	# Below this customer's tolerance: build the streak, then start (and run down)
	# the visible churn countdown. Churn ONLY at the counter's zero — never instant.
	CustomerRegistry.set_risk_streak(c.id, c.risk_streak + 1)
	if c.lifecycle_phase != "risk":
		if c.risk_streak < B2BConstants.RISK_TRIGGER_DAYS:
			return
		# HYSTERESIS: an account that left Risk inside RISK_REENTRY_DAYS does not re-enter
		# yet — the streak keeps counting, nothing else starts. The day the window closes it
		# re-enters immediately if it is still under its bar.
		if c.last_risk_exit_day >= 0 and GameState.day - c.last_risk_exit_day < B2BConstants.RISK_REENTRY_DAYS:
			return
		CustomerRegistry.set_lifecycle_phase(c.id, "risk")
		CustomerRegistry.set_churn_countdown(c.id, B2BConstants.CHURN_COUNTDOWN_DAYS)
		# Entering Risk IS the retention edge: set_lifecycle_phase emits
		# customer_health_changed, which `customer.retention` listens for. Nothing is pushed
		# from here; the engine decides.
		return
	var next_countdown: int = c.churn_countdown - 1
	CustomerRegistry.set_churn_countdown(c.id, next_countdown)
	if next_countdown <= 0:
		_churn(c)


# THE RETENTION PREDICATE: an active b2b account IN Risk with its countdown running, and no
# escalation open from its rep (that is the rep's voice, not the founder's). Read by the smoke
# suite; the shipped `customer.retention` card gates on `musteri.is_at_risk`.
static func can_offer_retention(c: Customer) -> bool:
	if c == null or c.market_type != "b2b" or c.status != "active":
		return false
	if c.lifecycle_phase != "risk" or c.churn_countdown < 0:
		return false
	if c.assigned_to != "" and c.cs_escalated:
		return false
	return true


static func _tick_healthy(c: Customer) -> void:
	# Satisfaction is at/above tolerance: recovery resets the risk machinery, and the phase
	# advances onboarding → active → (mature) expansion. ONE TRANSITION PER TICK:
	# set_lifecycle_phase writes through to this very instance, so the phase is matched ONCE —
	# otherwise a rescued account would go risk → active → expansion the same day.
	CustomerRegistry.set_risk_streak(c.id, 0)
	match c.lifecycle_phase:
		"risk":
			_recover(c, 0)
		"onboarding":
			if GameState.day >= c.onboarding_until:
				CustomerRegistry.set_lifecycle_phase(c.id, "active")
		"active":
			# Healthy + mature + never offered before → the positive family: a seat/MRR
			# upsell. The phase is a fact about the account that other readers use;
			# `customer.expansion` fires off `musteri.is_expansion_ready`.
			if can_offer_expansion(c):
				CustomerRegistry.set_lifecycle_phase(c.id, "expansion")
		# expansion / churning are not promotable states


# THE EXPANSION GATE, in one place so the daily sweep and the Sales-tab button cannot
# drift apart. The tab's manual trigger bypasses _tick_healthy entirely, so a latch that
# lived only in the sweep would leave the loop wide open through the UI.
static func can_offer_expansion(c: Customer) -> bool:
	if c.market_type != "b2b" or c.status != "active":
		return false
	if c.last_expansion_day >= 0:
		return false   # this account has already had its expansion moment
	return (GameState.day - c.acquired_on_day) >= B2BConstants.EXPANSION_MATURE_DAYS


static func _churn(c: Customer) -> void:
	# Loss from the watched counter (the passive path — countdown reached zero). The brand hit
	# lands HERE, at the actual churn moment. The escalation card's refusal churns through the
	# `churn_customer` verb with its own brand modifier and never reaches _churn, so there is
	# no double-apply.
	GameState.set_brand(GameState.brand + B2BConstants.CHURN_BRAND)
	_remove_lost(c)


static func _remove_lost(c: Customer) -> void:
	# Account loss: run counter + churn signal first (so a listener can still read the
	# record), then remove + reflect MRR.
	GameState.run_customers_lost += 1  # run counter seam, B2B loss path
	CustomerRegistry.set_lifecycle_phase(c.id, "churning")
	EventBus.customer_churned.emit(c.id)
	CustomerRegistry.remove(c.id)      # emits customer_removed
	SalesSystem.reflect_mrr()          # canonical MRR bridge after the account leaves


# --- Retention outcomes (called by the event effect verbs; WRITE-THROUGH LAW) ---

static func accept_promise(customer_id: String, feature_id: String, deadline_days: int) -> void:
	# "Söz ver": create a promise (a debt) and the customer stays — recovered from Risk.
	var c: Customer = CustomerRegistry.get_customer(customer_id)
	if c == null:
		return
	PromiseRegistry.create(customer_id, feature_id, deadline_days)
	# A prior broken word makes a fresh promise land with less goodwill.
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
	# "İndirim ver": MRR drops by the pre-computed delta, the customer stays (recovers from
	# Risk). The `b2b_retain_discount` verb computes the delta (MRR × RETAIN_DISCOUNT_PCT);
	# this seam just applies it through the MRR seam + bridge.
	# CAP: RETAIN_DISCOUNT_MAX_USES per account across both channels (retention and renewal
	# request). The cards lock the row through `musteri.discounts_used`; this guard is the
	# seam's own defense.
	var c: Customer = CustomerRegistry.get_customer(customer_id)
	if c == null:
		return
	if c.retain_discounts >= B2BConstants.RETAIN_DISCOUNT_MAX_USES:
		return
	CustomerRegistry.set_retain_discounts(c.id, c.retain_discounts + 1)
	if mrr_delta != 0:
		CustomerRegistry.set_mrr(c.id, c.mrr + mrr_delta)
		SalesSystem.reflect_mrr()
	_recover(c, B2BConstants.RETAIN_SAT_BUMP)


static func ignore_risk(_customer_id: String) -> void:
	# "Kendi haline bırak": choose not to intervene. Deliberate NO-OP — the customer
	# stays in Risk and keeps paying; the churn countdown (already running) continues on
	# the daily tick and fires _churn on its own at zero. No instant state change here.
	pass


# --- Expansion (upsell): healthy mature accounts grow seats → MRR. ---
static func expand(customer_id: String, add_seats: int, per_seat_mrr: int) -> void:
	var c: Customer = CustomerRegistry.get_customer(customer_id)
	if c == null or add_seats <= 0:
		return
	# SATIŞ rev 6 §5.4 — THE ACCOUNT'S OWN PRICE, not the caller's. `per_seat_mrr` (the
	# `b2b_expand` verb passes B2BConstants.EXPANSION_PER_SEAT_MRR) is only the FALLBACK for a
	# record with no stamped price — a v10 save, or a fixture.
	var rate: int = c.seat_price if c.seat_price > 0 else per_seat_mrr
	CustomerRegistry.set_seats(c.id, c.seats + add_seats)
	CustomerRegistry.set_mrr(c.id, c.mrr + add_seats * rate)
	SalesSystem.reflect_mrr()
	GameState.run_customers_expanded += 1  # run counter seam — genuine upsell only
	EventBus.customer_expanded.emit(c.id, c.seats)
	# Back to a settled account after the upsell moment — and STAMP the latch, or the
	# account lands right back on the condition that promoted it and re-fires tomorrow.
	CustomerRegistry.set_last_expansion_day(c.id, GameState.day)
	if c.lifecycle_phase == "expansion":
		CustomerRegistry.set_lifecycle_phase(c.id, "active")


static func decline_expansion(customer_id: String) -> void:
	# "Şimdilik gerek yok": no growth, the account settles back to active (a real,
	# different state — the upsell simply does not happen; no counter, no MRR move).
	# The latch is stamped on BOTH branches: declining is an answer, not a postponement.
	var c: Customer = CustomerRegistry.get_customer(customer_id)
	if c == null:
		return
	CustomerRegistry.set_last_expansion_day(c.id, GameState.day)
	if c.lifecycle_phase == "expansion":
		CustomerRegistry.set_lifecycle_phase(c.id, "active")


static func founder_managed_count() -> int:
	# Founder-managed (unassigned) B2B accounts. Read against the founder's own
	# CustomerRepSystem.founder_account_capacity() by CustomerRepSystem, which delegates only
	# the EXCESS, and by the Sales tab's "doğrudan yönettiğin hesap" line and steward picker.
	return CustomerRegistry.get_by_market("b2b").filter(
		func(c: Customer) -> bool: return c.assigned_to == "").size()


static func attention_count() -> int:
	# What the left-rail Satış badge counts: live accounts sitting in the RİSK phase — the
	# ones whose churn countdown is running and who will leave if nothing is done. Kept
	# here beside the phase machine that writes "risk" so the UI reads one number from one
	# place, exactly like HRSystem.attention_count() does for the Ekip badge.
	return CustomerRegistry.get_by_market("b2b").filter(
		func(c: Customer) -> bool: return c.lifecycle_phase == "risk").size()


static func _recover(c: Customer, sat_bump: int) -> void:
	# The customer stays: relieve satisfaction and clear the risk machinery.
	CustomerRegistry.set_satisfaction(c.id, c.satisfaction + sat_bump)
	CustomerRegistry.set_risk_streak(c.id, 0)
	if c.lifecycle_phase == "risk":
		CustomerRegistry.set_churn_countdown(c.id, -1)
		CustomerRegistry.set_last_risk_exit_day(c.id, GameState.day)   # hysteresis stamp
		# A rescue INSIDE the onboarding window returns to onboarding, not active: the window
		# is a fact about the CALENDAR, and _tick_satisfaction keeps amplifying until it closes.
		CustomerRegistry.set_lifecycle_phase(c.id,
			"onboarding" if GameState.day < c.onboarding_until else "active")


# --- The sales-domain reaction to a promise resolving (called by PromiseRegistry;
#     routes every customer/brand write through owning seams). ---
static func on_promise_resolved(p: Promise) -> void:
	var c: Customer = CustomerRegistry.get_customer(p.customer_id)
	# SATIŞ rev 6 §6 — the PITCH promise has its own counter in the same Registry. If the
	# promise that just resolved is the one open pitch promise, the single-open lock lifts
	# and the module's own vocabulary speaks. A BROKEN one also locks the row on that account
	# for the rest of the run (§6), which is what the account memory records.
	if SalesLedger.open_pitch_promise() == p.customer_id:
		var account_key: String = c.company_name if c != null else p.customer_id
		SalesLedger.clear_open_pitch_promise()
		if p.status == "broken":
			SalesLedger.record_broken_promise(account_key)
			EventBus.pitch_promise_broken.emit(account_key)
		elif p.status == "kept":
			EventBus.pitch_promise_kept.emit(account_key)
	match p.status:
		"kept":
			# Word kept on time: satisfaction + tolerance jump, loyalty up, credibility
			# restored (a future promise lands full-strength again).
			if c != null:
				CustomerRegistry.set_tolerance(c.id, c.tolerance + B2BConstants.PROMISE_KEPT_TOLERANCE)
				# Lift the TARGET too, so the goodwill outlives the day it was earned.
				CustomerRegistry.set_trust_offset(c.id, c.trust_offset + B2BConstants.PROMISE_KEPT_OFFSET)
				# THE SATISFACTION BUMP GOES THROUGH _recover, NOT a bare set_satisfaction:
				# like accept_promise, keeping the word clears the churn countdown and the
				# risk streak on the spot, so delivering rescues the account the same day
				# even when the bump alone would not clear its tolerance bar.
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
				CustomerRegistry.set_tolerance(c.id, mini(c.tolerance + B2BConstants.PROMISE_BROKEN_TOLERANCE,
					B2BConstants.seed_tolerance(c.scale, c.industry) + B2BConstants.PROMISE_TOLERANCE_CEILING))
				# THE DURABLE HALF. Without this the -20 above is walked back by SAT_DRIFT_STEP
				# within a week and a broken word leaves no trace at all.
				CustomerRegistry.set_trust_offset(c.id, c.trust_offset + B2BConstants.PROMISE_BROKEN_OFFSET)
				# INSIDE the null guard: a promise that outlived its account must not charge
				# brand or stamp a credibility flag for a company that no longer exists
				# (PromiseRegistry also drops open promises when the account leaves).
				GameState.set_brand(GameState.brand + B2BConstants.PROMISE_BROKEN_BRAND)
				GameState.set_flag("b2b_broke_%s" % p.customer_id, true)


# --- Feature-pool binding: the pain a prospect/customer voices maps to a
#     feature that EXISTS in the active product's pool (so a promise is buildable). ---
static func pick_pain_feature(sub_id: String, index: int) -> String:
	if sub_id == "":
		return ""
	# LINE MODEL (Ürün rev 6.1 §12): a line subtype (the playable erp among them) has no flat
	# pool; its accounts want the next line step instead.
	if ProductLines.has_subtype(sub_id):
		return _pick_line_pain(sub_id, index)
	var pool: Array = ProductCatalog.get_feature_pool(sub_id)
	if pool.is_empty():
		return ""
	# An UNSHIPPED feature, walking the pool from the caller's index so the choice stays
	# deterministic and evenly spread: a feature the product already has is not a pain, and a
	# promise about it would be either a free win or an unfair loss.
	var live: Array = GameState.get_flag("mvp_components", [])
	for step in pool.size():
		var cand: Dictionary = pool[(index + step) % pool.size()]
		var cand_id: String = String(cand.get("id", ""))
		if cand_id != "" and not live.has(cand_id):
			return cand_id
	# Every feature in the pool is already live: this account has nothing left to want.
	# "" is the honest answer and the existing no-pain contract everywhere downstream.
	return ""


## An account on a line product wants THE NEXT STEP of one of the product's lines: the
## thing a real customer asks for is "the bit after what you have". Steps the company can
## already build (LineGates open) are preferred, so a promise is a schedule question and
## not a trap; a gated step is only chosen when nothing open is left. Deterministic by
## `index`, like the flat picker, so two accounts signed the same day differ.
static func _pick_line_pain(sub_id: String, index: int) -> String:
	# Wants CLUSTER, the way real requests do: first the next step on a line the product
	# already has, lowest tier first; only then the opening step of a line it lacks. One
	# version that ships the common ask therefore keeps several accounts' words at once.
	var best_rank: int = 999
	var open_steps: Array[String] = []
	var gated_steps: Array[String] = []
	for raw_line in ProductLines.line_ids(sub_id):
		var line_id: String = String(raw_line)
		var have: int = ProductState.line_tier(line_id)
		var nxt: Dictionary = ProductLines.step_at(line_id, have + 1)
		if nxt.is_empty():
			continue
		var sid: String = String(nxt.get("id", ""))
		if not LineGates.is_unlocked(sid):
			gated_steps.append(sid)
			continue
		# rank: existing lines by the tier they would reach, unopened lines after them all
		var rank: int = int(nxt.get("tier", 1)) if have > 0 else 10
		if rank < best_rank:
			best_rank = rank
			open_steps.clear()
		if rank == best_rank:
			open_steps.append(sid)
	var pick_from: Array[String] = open_steps if not open_steps.is_empty() else gated_steps
	if pick_from.is_empty():
		return ""
	return pick_from[absi(index) % pick_from.size()]


const RISK_VOICE_SHORT_KEYS := ["B2B_RISK_VOICE_SHORT_1", "B2B_RISK_VOICE_SHORT_2", "B2B_RISK_VOICE_SHORT_3"]

## What an account in Risk actually says, chosen by WHY it is in Risk, in the order a customer
## would lead with them: a word you broke, a product that is visibly failing, a product that
## has stopped being enough.
static func risk_voice(c: Customer) -> String:
	if c == null:
		return ""
	if GameState.get_flag("b2b_broke_%s" % c.id, false):
		return TranslationServer.translate("B2B_RISK_VOICE_BROKEN")
	if ProductState.bugs_confirmed() > B2BConstants.COMPLAINT_BUG_GATE or InfraSystem.is_over_capacity():
		return B2BConstants.complaint_voice(c.industry)
	return TranslationServer.translate(RISK_VOICE_SHORT_KEYS[absi(c.id.hash()) % RISK_VOICE_SHORT_KEYS.size()])


## After a ship, an account whose wish just went live wants the next thing. Called by
## PromiseRegistry AFTER it has resolved the promises the ship kept, so the kept promise
## is credited against the old wish before the account forms a new one.
static func refresh_pains_after_ship() -> void:
	var sub_id: String = ProductState.subtype()
	for c in CustomerRegistry.get_all():
		if c.pain_feature_id == "" or not ProductState.is_feature_live(c.pain_feature_id):
			continue
		CustomerRegistry.set_pain_feature(c.id, pick_pain_feature(sub_id, c.scale + GameState.day))
