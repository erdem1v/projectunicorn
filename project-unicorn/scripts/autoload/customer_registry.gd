extends Node

# Customer registry per TECH_SPEC §6.1.
# Single source of truth for all customers (acquired accounts).
#
# Mutations route through registry methods. State changes emit on EventBus
# (TECH_SPEC §13) so scenes (RightPanel, future Sales Tab) update themselves
# without the registry knowing who is listening.
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
# so a fresh game starts with zero customers and zero MRR (Economic Outcome
# Principle, PROJECT_SPEC §10). Flip to true to restore the Nordica/Palmiye/
# Beykoz seed for verifying Sales/Finance pipeline behavior with real data.
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


# --- Queries (consumed by SalesSystem and RightPanel) ---

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


func get_min_satisfaction() -> int:
	# Lowest satisfaction among active customers (drives churn-risk event gating).
	# Returns 100 when there are no customers (nothing at risk).
	var lowest: int = 100
	var any: bool = false
	for c in _customers.values():
		if c.status == "active":
			any = true
			lowest = mini(lowest, c.satisfaction)
	return lowest if any else 100


func get_lowest_satisfaction_customer() -> Customer:
	# The single most-at-risk active customer (churn target). Null if none.
	var worst: Customer = null
	for c in _customers.values():
		if c.status == "active" and (worst == null or c.satisfaction < worst.satisfaction):
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


# --- Debug seed (writes directly to _customers; does NOT call add() so no
#     phantom customer_added signals fire on startup) ---

func _seed_debug_customers() -> void:
	# DEBUG SEED — names from RightPanel placeholder turn; not in PROJECT_SPEC.
	# Remove when prospect/close-deal flow + data/companies/customers.json exist.
	var nordica := Customer.new()
	nordica.id = "co_debug_nordica"
	nordica.company_name = "Nordica Logistics"
	nordica.industry = "Logistics"
	nordica.mrr = 3200
	nordica.seats = 12
	_customers[nordica.id] = nordica

	var palmiye := Customer.new()
	palmiye.id = "co_debug_palmiye"
	palmiye.company_name = "Palmiye Holding"
	palmiye.industry = "Real Estate"
	palmiye.mrr = 1800
	palmiye.seats = 8
	_customers[palmiye.id] = palmiye

	var beykoz := Customer.new()
	beykoz.id = "co_debug_beykoz"
	beykoz.company_name = "Beykoz Tekstil"
	beykoz.industry = "Textile"
	beykoz.mrr = 900
	beykoz.seats = 4
	_customers[beykoz.id] = beykoz
