extends Node

# Promise registry. Single source of truth for open/closed promises, mirroring
# CustomerRegistry / ProspectRegistry (mutations route through methods; state changes
# emit on EventBus so UI binds without polling).
#
# Resolution: ship-coupling (build_phase_changed → kept, or partial when late) and the daily
# deadline sweep (→ broken). "Shipped" is ProductState.is_feature_live.

var _promises: Dictionary = {}  # id (String) -> Promise


func _ready() -> void:
	# Ship-coupling: a Product feature reaching live keeps a matching open promise.
	EventBus.build_phase_changed.connect(_on_build_phase_changed)
	# A promise cannot outlive the company it was made to. Bound to the REMOVAL SIGNAL
	# rather than to B2BSalesSystem's churn seam on purpose: accounts also leave through
	# the `churn_customer` event modifier, which deletes the record directly, and a promise
	# left behind by that path breaks days later — charging brand a second time for a
	# company that already took its churn hit and is gone from every screen.
	EventBus.customer_removed.connect(drop_open_for)


# --- Read API ---

func get_promise(promise_id: String) -> Promise:
	return _promises.get(promise_id, null)


func get_all() -> Array[Promise]:
	var out: Array[Promise] = []
	out.assign(_promises.values())
	return out


func get_open_for(customer_id: String) -> Array[Promise]:
	var out: Array[Promise] = []
	for p in _promises.values():
		if p.status == "open" and p.customer_id == customer_id:
			out.append(p)
	return out


func has_open_for(customer_id: String) -> bool:
	return not get_open_for(customer_id).is_empty()


# --- Write API ---

func create(customer_id: String, feature_id: String, deadline_days: int) -> Promise:
	# The single creation seam. Emits promise_created. Deadline is relative to today.
	#
	# A PROMISE WITH NO TARGET IS REFUSED. Nothing ever ships "", so it could never be kept,
	# and while it stays open `has_open_for` reports true and every card that asks "is a word
	# already open on this account" locks. Refused HERE because every creation path ends in
	# this seam (a restored save is cleaned by drop_targetless instead). Returning null is the
	# shape callers already handle (they check the registry, not the return); the warning
	# names the customer so a regression is not silent.
	if feature_id.strip_edges() == "":
		push_warning("[PromiseRegistry] refused a promise with no target for '%s'" % customer_id)
		return null
	var p := Promise.new()
	p.id = "promise_%s_%s_%d" % [customer_id, feature_id, GameState.day]
	p.customer_id = customer_id
	p.feature_id = feature_id
	p.created_on_day = GameState.day
	p.deadline_day = GameState.day + maxi(deadline_days, 1)
	p.status = "open"
	# Guard against a duplicate id in the same-day/same-feature edge (append a suffix).
	if _promises.has(p.id):
		p.id += "_%d" % _promises.size()
	_promises[p.id] = p
	EventBus.promise_created.emit(p.id)
	return p


func reset() -> void:
	_promises.clear()


## Drops every OPEN promise that names no feature. Called once on load, because `create()`
## refusing them does nothing for a save that already carries one — and a save that carries
## one carries a lever that is off for the rest of that run.
##
## Closed ones are left alone on purpose: kept/partial/broken are history, and rewriting history
## to tidy a bug is how a save stops matching what the player remembers doing. Returns the count.
func drop_targetless() -> int:
	var doomed: Array = []
	for pid in _promises:
		var p: Promise = _promises[pid]
		if p.status == "open" and p.feature_id.strip_edges() == "":
			doomed.append(pid)
	for pid in doomed:
		_promises.erase(pid)
	return doomed.size()


func insert_raw(promise: Promise) -> void:
	# SAVE RESTORE ONLY — no promise_created emit (create() is the seam for a promise that
	# is actually being MADE; restoring one is not a new commitment).
	# SaveCodec deliberately restores promises LAST, after every customer is seated: this
	# registry binds customer_removed → drop_open_for at _ready, so any customer churn that
	# happened between the two would silently delete restored promises.
	if promise == null or promise.id == "":
		push_warning("[PromiseRegistry] insert_raw() called with null or missing id")
		return
	_promises[promise.id] = promise


func drop_open_for(customer_id: String) -> void:
	# DROPPED, not resolved. "broken" would emit promise_broken and run the whole penalty
	# chain — a second brand hit, with no event and no attributable cause the player can
	# read — for an account that no longer exists; left open, it would keep counting down on
	# the Product tab under a null customer name.
	# CLOSED promises stay: kept/partial/broken are history, and history outlives the
	# customer.
	for pid in _promises.keys():
		var p: Promise = _promises[pid]
		if p.customer_id == customer_id and p.status == "open":
			_promises.erase(pid)


# --- Resolution: ship-coupling keeps, deadline sweep breaks, late ship is partial ---

func _on_build_phase_changed(phase: String) -> void:
	# The promised feature reaching live keeps an open promise (or partially redeems a
	# broken one if it lands late).
	if phase != "shipped":
		return
	for p in _promises.values():
		if not ProductState.is_feature_live(p.feature_id):
			continue
		if p.status == "open":
			_resolve(p, "kept" if GameState.day <= p.deadline_day else "partial")
		elif p.status == "broken":
			_resolve(p, "partial")  # late redemption of an already-broken promise
	B2BSalesSystem.refresh_pains_after_ship()


func tick_deadlines(day: int) -> void:
	# Called daily by B2BSalesSystem. An open promise past its deadline breaks.
	for p in _promises.values():
		if p.status == "open" and day > p.deadline_day:
			_resolve(p, "broken")


func _resolve(p: Promise, status: String) -> void:
	if p.status == status:
		return
	p.status = status
	if status == "broken":
		EventBus.promise_broken.emit(p.id)
	else:
		EventBus.promise_kept.emit(p.id)  # kept + partial both resolve the promise
	# The customer-facing reaction lives in the sales domain (routes through seams).
	B2BSalesSystem.on_promise_resolved(p)
