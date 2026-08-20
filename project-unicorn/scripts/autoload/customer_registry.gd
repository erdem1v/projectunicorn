extends Node

# Customer registry per TECH_SPEC §6.1.
# Single source of truth for all customers (acquired accounts).
#
# Mutations route through registry methods. State changes emit on EventBus
# (TECH_SPEC §13) so scenes (Sales tab, ODA) update themselves without the registry
# knowing who is listening.
#
# Tick interaction (TECH_SPEC §8.2):
#   - SalesSystem.daily_tick (slot 4) reads get_total_mrr and pushes to
#     GameState.set_mrr — TopBar listens to EventBus.mrr_changed.
#   - FinanceSystem.daily_tick (slot 5) reads GameState.mrr (NOT this
#     registry directly — Sales is the canonical bridge to GameState).
#
# Naming caution: get_customer (not get) — `Object.get(prop)` is reserved
# and shadowing it produces subtle bugs (mirrors CharacterRegistry policy).

# Manual toggle for deliberate registry integration testing. Off in normal runs
# so a fresh game starts with zero customers and zero MRR. (B2C MRR then derives
# from the live audience + price each hour — Economy Model v2, PROJECT_SPEC §10
# revision.) Flip to true to restore the Nordica/Palmiye/Beykoz seed for verifying
# Sales/Finance pipeline behavior with real data.
const DEBUG_SEED := false

var _customers: Dictionary = {}  # id (String) -> Customer


func _ready() -> void:
	if DEBUG_SEED:
		_seed_debug_customers()


# --- Read API ---

func get_customer(customer_id: String) -> Customer:
	return _customers.get(customer_id, null)


func get_all() -> Array[Customer]:
	var out: Array[Customer] = []
	for c in _customers.values():
		out.append(c)
	return out


func get_active() -> Array[Customer]:
	var out: Array[Customer] = []
	for c in _customers.values():
		if c.status == "active":
			out.append(c)
	return out


# --- Queries (consumed by SalesSystem, the Sales tab and the ODA board) ---

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
	# B2B seat total across active B2B accounts.
	var total: int = 0
	for c in _customers.values():
		if c.status == "active" and c.market_type == "b2b":
			total += c.seats
	return total


func get_min_satisfaction(market: String = "") -> int:
	# Lowest satisfaction among active customers (drives churn-risk event gating).
	# Returns 100 when there are no customers (nothing at risk).
	# `market` — "" scans the whole book; "b2c"/"b2b" scopes it. A consumer-support event
	# must not be ARMED by an unhappy enterprise account, which is what the unscoped scan
	# allowed in any mixed portfolio.
	var lowest: int = 100
	var any: bool = false
	for c in _customers.values():
		if c.status == "active" and (market == "" or c.market_type == market):
			any = true
			lowest = mini(lowest, c.satisfaction)
	return lowest if any else 100


func get_lowest_satisfaction_customer(market: String = "") -> Customer:
	# The single most-at-risk active customer (churn target). Null if none.
	# Scoped by `market` for the same reason as get_min_satisfaction — and with an explicit
	# id TIEBREAK, because on equal satisfaction this used to return whichever record the
	# backing dictionary happened to iterate first. get_top_customers already tiebreaks on
	# id "for future seeded-RNG replay"; a churn victim deserves at least as much.
	var worst: Customer = null
	for c in _customers.values():
		if c.status != "active":
			continue
		if market != "" and c.market_type != market:
			continue
		if worst == null \
				or c.satisfaction < worst.satisfaction \
				or (c.satisfaction == worst.satisfaction and c.id < worst.id):
			worst = c
	return worst


func get_top_customers(limit: int = 5) -> Array[Customer]:
	# Sort by MRR desc; tiebreak by id (string) for deterministic order
	# (matters for future seeded-RNG replay per TECH_SPEC §10.4).
	var active: Array[Customer] = get_active()
	active.sort_custom(func(a, b):
		if a.mrr != b.mrr:
			return a.mrr > b.mrr
		return a.id < b.id)
	if active.size() > limit:
		active.resize(limit)
	return active


# --- Write API (public — used by future close-deal / churn / renewal flows) ---

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
	# SAVE RESTORE ONLY — no customer_added emit. Mirrors CharacterRegistry.insert_raw and
	# the _seed_debug_customers precedent below ("writes directly to _customers; does NOT
	# call add() so no phantom customer_added signals fire").
	if customer == null or customer.id == "":
		push_warning("[CustomerRegistry] insert_raw() called with null or missing id")
		return
	_customers[customer.id] = customer


func reset() -> void:
	# Run-boundary reset (SaveManager.reset_all_owners). This registry had NO reset, so the
	# whole customer book survived an in-place restart: the new company opened its doors
	# already owning the previous run's accounts, with their MRR aggregating into a fresh
	# GameState the moment SalesSystem's bridge ran.
	#
	# DIRECT CLEAR, NOT remove()-in-a-loop, and that is load-bearing rather than an
	# optimisation: remove() emits customer_removed, which PromiseRegistry._on_customer_removed
	# turns into drop_open_for — so a reset that went through remove() would fire N promise
	# drops on the way out, and on a LOAD would race the restore that is about to seat those
	# same promises. Same "direct clear, no signals" doctrine as CharacterRegistry.reset().
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
		return  # No-op: don't emit a redundant signal
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
		return  # No-op: don't emit a redundant signal
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
		return  # No-op: don't emit a redundant signal
	c.satisfaction = clamped
	c.update_health_from_satisfaction()
	EventBus.customer_satisfaction_changed.emit(customer_id, clamped)


# --- B2B lifecycle seams (B2B Sales System). Each mutation routes through here so
#     the portfolio health / churn-countdown UI binds to a signal, never a raw poke. ---

func set_lifecycle_phase(customer_id: String, phase: String) -> void:
	# onboarding|active|risk|churning|expansion. Emits customer_health_changed.
	var c: Customer = _customers.get(customer_id, null)
	if c == null:
		push_warning("[CustomerRegistry] set_lifecycle_phase on unknown id: %s" % customer_id)
		return
	if c.lifecycle_phase == phase:
		return  # No-op: don't emit a redundant signal
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
		return  # No-op: don't emit a redundant signal
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
	# HIDDEN trust ledger (Task 2b) — no signal, same shape as set_tolerance above. Clamped by
	# the sales domain's constants because the sales domain owns what a promise is worth.
	var c: Customer = _customers.get(customer_id, null)
	if c == null:
		push_warning("[CustomerRegistry] set_trust_offset on unknown id: %s" % customer_id)
		return
	c.trust_offset = clampf(value, B2BConstants.TRUST_OFFSET_MIN, B2BConstants.TRUST_OFFSET_MAX)


func set_support_request(customer_id: String, since_day: int) -> void:
	# HIDDEN request-channel bookkeeping (Task 2b) — no signal. since_day == -1 means the
	# account has no open request; any other value is the day one opened (the escalation
	# clock AND the once-only latch, so the latch lives in state the system owns).
	# The old `progress` parameter is gone: it was written 1.0/0.0 and read by nothing.
	var c: Customer = _customers.get(customer_id, null)
	if c == null:
		return
	c.support_request_since_day = since_day


func set_request_phase(customer_id: String, phase: int) -> void:
	# HIDDEN — the account's day-offset inside CS_REQUEST_INTERVAL_DAYS. Written once at
	# signing (see SalesSystem.add_b2b_customer); nothing else may move it, or the whole
	# book drifts back toward filing on the same morning.
	var c: Customer = _customers.get(customer_id, null)
	if c == null:
		return
	c.cs_request_phase = phase


func set_last_request_kind(customer_id: String, kind: String) -> void:
	# HIDDEN — blocks the same request kind arriving twice running from one account.
	var c: Customer = _customers.get(customer_id, null)
	if c == null:
		return
	c.last_request_kind = kind


func set_retain_discounts(customer_id: String, n: int) -> void:
	# HIDDEN discount counter (Calibration Round A §8) — no signal; the locked row the
	# factory renders past the cap is what the player sees. Counts BOTH discount channels
	# (the retention card and the CS complaint/renewal cards), because both resolve through
	# B2BSalesSystem.apply_discount.
	var c: Customer = _customers.get(customer_id, null)
	if c == null:
		return
	c.retain_discounts = maxi(n, 0)


func set_last_risk_exit_day(customer_id: String, day: int) -> void:
	# HIDDEN hysteresis latch (Calibration Round A §8) — no signal; stamped by both risk-exit
	# sites (B2BSalesSystem._recover and _tick_healthy's risk branch). -1 = never left Risk.
	var c: Customer = _customers.get(customer_id, null)
	if c == null:
		return
	c.last_risk_exit_day = day


func set_last_expansion_day(customer_id: String, day: int) -> void:
	# HIDDEN expansion latch (K2) — no signal; the phase change that accompanies it is
	# what the UI repaints on. -1 means the moment has not happened. Like the support
	# request latch, this lives in state the SYSTEM owns rather than in a property of the
	# event, because EventManager.enqueue bypasses one_shot and cooldown entirely.
	var c: Customer = _customers.get(customer_id, null)
	if c == null:
		return
	c.last_expansion_day = day


func assign_customer(customer_id: String, employee_id: String, pinned: bool = false) -> void:
	# Delegation seam (Stage D): "" = founder-managed, else a Customer Success employee id.
	# `pinned` marks the assignment as a PLAYER decision. reconcile_assignments() runs every
	# morning and would otherwise silently undo a manual choice — automatic callers leave the
	# default false, the Sales-tab picker passes true. Note "" + pinned is meaningful: it is
	# the player deliberately keeping an account on the founder's desk.
	var c: Customer = _customers.get(customer_id, null)
	if c == null:
		push_warning("[CustomerRegistry] assign_customer on unknown id: %s" % customer_id)
		return
	if c.assigned_to == employee_id and c.cs_pinned == pinned:
		return  # No-op: don't emit a redundant signal
	c.assigned_to = employee_id
	c.cs_pinned = pinned
	EventBus.customer_assigned.emit(customer_id, employee_id)


func set_cs_pinned(customer_id: String, pinned: bool) -> void:
	# Clears (or sets) player intent without touching the assignment itself — used when a
	# pinned rep leaves and reconcile has to release the account.
	var c: Customer = _customers.get(customer_id, null)
	if c == null:
		return
	c.cs_pinned = pinned


# --- Debug seed (writes directly to _customers; does NOT call add() so no
#     phantom customer_added signals fire on startup) ---

func _seed_debug_customers() -> void:
	# DEBUG SEED — names from RightPanel placeholder turn; not in PROJECT_SPEC.
	# Remove when prospect/close-deal flow + data/companies/customers.json exist.
	var nordica := Customer.new()
	nordica.id = "co_debug_nordica"
	nordica.company_name = "Nordica Logistics"
	nordica.industry = "logistics"
	nordica.mrr = 3200
	nordica.seats = 12
	_customers[nordica.id] = nordica

	var palmiye := Customer.new()
	palmiye.id = "co_debug_palmiye"
	palmiye.company_name = "Palmiye Holding"
	palmiye.industry = "real_estate"
	palmiye.mrr = 1800
	palmiye.seats = 8
	_customers[palmiye.id] = palmiye

	var beykoz := Customer.new()
	beykoz.id = "co_debug_beykoz"
	beykoz.company_name = "Beykoz Tekstil"
	beykoz.industry = "textile"
	beykoz.mrr = 900
	beykoz.seats = 4
	_customers[beykoz.id] = beykoz
