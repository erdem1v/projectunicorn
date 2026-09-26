extends Node

# Customer registry.
# Single source of truth for all customers (acquired accounts).
#
# Mutations route through registry methods. State changes emit on EventBus so
# scenes (Sales tab, ODA) update themselves without the registry knowing who is
# listening.
#
# SalesSystem's MRR bridge is the canonical path from get_total_mrr to GameState.mrr
# (TopBar listens to EventBus.mrr_changed); FinanceSystem reads GameState.mrr, not this
# registry.
#
# Naming caution: get_customer (not get) — `Object.get(prop)` is reserved
# and shadowing it produces subtle bugs (mirrors CharacterRegistry policy).

var _customers: Dictionary = {}  # id (String) -> Customer


# --- Read API ---

func get_customer(customer_id: String) -> Customer:
	return _customers.get(customer_id, null)


func get_all() -> Array[Customer]:
	var out: Array[Customer] = []
	out.assign(_customers.values())
	return out


func get_active() -> Array[Customer]:
	var out: Array[Customer] = []
	for c in _customers.values():
		if c.status == "active":
			out.append(c)
	return out


## HOW MANY ACCOUNTS THE BOOK HOLDS, and the reason it is not `get_active().size()`.
##
## The B2C user base lives in this registry as ONE aggregate `Customer` record — an audience
## wearing a customer's shape: its `seats` is the paying-user count and its name is composed
## copy. It belongs here (satisfaction, churn and MRR all run through the same machinery) but
## it is not an account. An ACCOUNT is an active customer that is not the aggregate: in a pure
## B2B run that is the b2b book; in a B2C run it is zero — a B2C company has an audience, not a
## client list.
func account_count() -> int:
	var n: int = 0
	for c in _customers.values():
		if c.status == "active" and c.id != SalesSystem.B2C_USERBASE_ID:
			n += 1
	return n


# --- Queries ---

func get_total_mrr() -> int:
	var total: int = 0
	for c in _customers.values():
		if c.status == "active":
			total += c.mrr
	return total


func get_by_market(market_type: String) -> Array[Customer]:
	# Active customers of one market model ("b2c" | "b2b").
	var out: Array[Customer] = []
	for c in _customers.values():
		if c.status == "active" and c.market_type == market_type:
			out.append(c)
	return out


func get_total_users() -> int:
	# B2C paying users — the B2C base is one aggregate record whose `seats` is the
	# paying-user count, so sum seats across active B2C records (not record count).
	var total: int = 0
	for c in _customers.values():
		if c.status == "active" and c.market_type == "b2c":
			total += c.seats
	return total


func get_total_seats() -> int:
	var total: int = 0
	for c in _customers.values():
		if c.status == "active" and c.market_type == "b2b":
			total += c.seats
	return total


func get_min_satisfaction(market: String = "") -> int:
	# Lowest satisfaction among active customers; 100 when there are none (nothing at risk).
	# `market` — "" scans the whole book; "b2c"/"b2b" scopes it, so a consumer-facing gate is
	# not armed by an unhappy enterprise account in a mixed portfolio.
	var lowest: int = 100
	for c in _customers.values():
		if c.status == "active" and (market == "" or c.market_type == market):
			lowest = mini(lowest, c.satisfaction)
	return lowest


# --- Write API ---

func add(customer: Customer) -> void:
	if customer == null or customer.id == "":
		push_warning("[CustomerRegistry] add() called with null or missing id")
		return
	if _customers.has(customer.id):
		push_warning("[CustomerRegistry] add() id collision: %s" % customer.id)
		return
	_customers[customer.id] = customer
	EventBus.customer_added.emit(customer.id)


func insert_raw(customer: Customer) -> void:
	# SAVE RESTORE ONLY — no customer_added emit. Mirrors CharacterRegistry.insert_raw.
	if customer == null or customer.id == "":
		push_warning("[CustomerRegistry] insert_raw() called with null or missing id")
		return
	_customers[customer.id] = customer


func reset() -> void:
	# Run-boundary reset (SaveManager.reset_all_owners).
	#
	# DIRECT CLEAR, NOT remove()-in-a-loop, and that is load-bearing rather than an
	# optimisation: remove() emits customer_removed, which PromiseRegistry binds to
	# drop_open_for — so a reset that went through remove() would fire N promise drops on the
	# way out, and on a LOAD would race the restore that is about to seat those same promises.
	# Same "direct clear, no signals" doctrine as CharacterRegistry.reset().
	_customers.clear()


func remove(customer_id: String) -> void:
	if not _customers.has(customer_id):
		return
	_customers.erase(customer_id)
	EventBus.customer_removed.emit(customer_id)


func set_mrr(customer_id: String, value: int) -> void:
	var c: Customer = _customers.get(customer_id, null)
	if c == null:
		push_warning("[CustomerRegistry] set_mrr on unknown id: %s" % customer_id)
		return
	var clamped: int = maxi(value, 0)
	if c.mrr == clamped:
		return
	c.mrr = clamped
	EventBus.customer_mrr_changed.emit(customer_id, clamped)


func set_seats(customer_id: String, value: int) -> void:
	# Seat-level write — B2C dynamic pricing (seat-granular churn) and B2B seat upsell.
	# WRITE-THROUGH LAW: the ONLY seam for `seats`. Emits customer_seats_changed so every
	# seat display repaints live (no raw Customer.seats pokes elsewhere).
	var c: Customer = _customers.get(customer_id, null)
	if c == null:
		push_warning("[CustomerRegistry] set_seats on unknown id: %s" % customer_id)
		return
	var clamped: int = maxi(value, 0)
	if c.seats == clamped:
		return
	c.seats = clamped
	EventBus.customer_seats_changed.emit(customer_id, clamped)


func set_satisfaction(customer_id: String, value: int) -> void:
	# Satisfaction seam (WRITE-THROUGH LAW): the ONLY place events/systems change a
	# customer's satisfaction. Clamps 0-100, keeps the derived health band in sync,
	# and emits so health-band UI can bind without polling.
	var c: Customer = _customers.get(customer_id, null)
	if c == null:
		push_warning("[CustomerRegistry] set_satisfaction on unknown id: %s" % customer_id)
		return
	var clamped: int = clampi(value, 0, 100)
	if c.satisfaction == clamped:
		return
	c.satisfaction = clamped
	c.update_health_from_satisfaction()
	EventBus.customer_satisfaction_changed.emit(customer_id, clamped)


# --- B2B lifecycle seams. Each mutation routes through here so the portfolio health /
#     churn-countdown UI binds to a signal, never a raw poke. ---

func set_lifecycle_phase(customer_id: String, phase: String) -> void:
	# onboarding|active|risk|churning|expansion. Emits customer_health_changed.
	var c: Customer = _customers.get(customer_id, null)
	if c == null:
		push_warning("[CustomerRegistry] set_lifecycle_phase on unknown id: %s" % customer_id)
		return
	if c.lifecycle_phase == phase:
		return
	c.lifecycle_phase = phase
	EventBus.customer_health_changed.emit(customer_id, phase)


func set_churn_countdown(customer_id: String, value: int) -> void:
	# -1 = inactive; N..0 drives the visible "Churn'e ~N gün" readout. Emits
	# customer_health_changed (same channel as the phase) so the counter repaints.
	var c: Customer = _customers.get(customer_id, null)
	if c == null:
		push_warning("[CustomerRegistry] set_churn_countdown on unknown id: %s" % customer_id)
		return
	var clamped: int = maxi(value, -1)
	if c.churn_countdown == clamped:
		return
	c.churn_countdown = clamped
	EventBus.customer_health_changed.emit(customer_id, c.lifecycle_phase)


func set_tolerance(customer_id: String, value: int) -> void:
	# HIDDEN per-customer field — no signal (the UI never shows raw tolerance).
	var c: Customer = _customers.get(customer_id, null)
	if c == null:
		push_warning("[CustomerRegistry] set_tolerance on unknown id: %s" % customer_id)
		return
	c.tolerance = clampi(value, 0, 100)


func set_risk_streak(customer_id: String, value: int) -> void:
	# HIDDEN bookkeeping counter (consecutive days under tolerance) — no signal.
	var c: Customer = _customers.get(customer_id, null)
	if c == null:
		return
	c.risk_streak = maxi(value, 0)


func set_trust_offset(customer_id: String, value: float) -> void:
	# HIDDEN trust ledger — no signal, same shape as set_tolerance above. Clamped by the
	# sales domain's constants because the sales domain owns what a promise is worth.
	var c: Customer = _customers.get(customer_id, null)
	if c == null:
		push_warning("[CustomerRegistry] set_trust_offset on unknown id: %s" % customer_id)
		return
	c.trust_offset = clampf(value, B2BConstants.TRUST_OFFSET_MIN, B2BConstants.TRUST_OFFSET_MAX)


func set_support_request(customer_id: String, since_day: int) -> void:
	# HIDDEN request-channel bookkeeping — no signal. since_day == -1 means the account has
	# no open request; any other value is the day one opened (the escalation clock AND the
	# once-only latch, so the latch lives in state the system owns).
	var c: Customer = _customers.get(customer_id, null)
	if c == null:
		return
	c.support_request_since_day = since_day


func set_last_request_kind(customer_id: String, kind: String) -> void:
	# HIDDEN — blocks the same request kind arriving twice running from one account.
	var c: Customer = _customers.get(customer_id, null)
	if c == null:
		return
	c.last_request_kind = kind


func set_pain_feature(customer_id: String, feature_id: String) -> void:
	# The thing this account wants next (a line step or a flat feature id). No signal: the
	# promise rows and the request channel read it through seams at the moment they render.
	var c: Customer = _customers.get(customer_id, null)
	if c == null:
		return
	c.pain_feature_id = feature_id


func set_retain_discounts(customer_id: String, n: int) -> void:
	# HIDDEN discount counter — no signal; the locked card row past the cap is what the player
	# sees. Counts BOTH discount channels (the retention card and the CS renewal card), because
	# both resolve through B2BSalesSystem.apply_discount.
	var c: Customer = _customers.get(customer_id, null)
	if c == null:
		return
	c.retain_discounts = maxi(n, 0)


func set_last_risk_exit_day(customer_id: String, day: int) -> void:
	# HIDDEN hysteresis latch — no signal; stamped by B2BSalesSystem._recover, which every exit
	# from Risk goes through. -1 = never left Risk.
	var c: Customer = _customers.get(customer_id, null)
	if c == null:
		return
	c.last_risk_exit_day = day


func set_last_expansion_day(customer_id: String, day: int) -> void:
	# HIDDEN expansion latch — no signal; the phase change that accompanies it is what the UI
	# repaints on. -1 means the moment has not happened. The card's own one_shot latch brakes
	# the card; this field stays because it is a fact about the account (can_offer_expansion
	# reads it).
	var c: Customer = _customers.get(customer_id, null)
	if c == null:
		return
	c.last_expansion_day = day


func assign_customer(customer_id: String, employee_id: String, pinned: bool = false) -> void:
	# Delegation seam: "" = founder-managed, else a Customer Success employee id.
	# `pinned` marks the assignment as a PLAYER decision. reconcile_assignments() runs every
	# morning and would otherwise silently undo a manual choice — automatic callers leave the
	# default false, the Sales-tab picker passes true. Note "" + pinned is meaningful: it is
	# the player deliberately keeping an account on the founder's desk.
	var c: Customer = _customers.get(customer_id, null)
	if c == null:
		push_warning("[CustomerRegistry] assign_customer on unknown id: %s" % customer_id)
		return
	if c.assigned_to == employee_id and c.cs_pinned == pinned:
		return
	c.assigned_to = employee_id
	c.cs_pinned = pinned
	EventBus.customer_assigned.emit(customer_id, employee_id)
