extends Node

# Promise registry (B2B Sales System §C). Single source of truth for open/closed
# promises, mirroring CustomerRegistry / ProspectRegistry (mutations route through
# methods; state changes emit on EventBus so UI binds without polling).
#
# Stage B builds creation (the retention "Söz ver" + CS escalation "sözü tut" need
# it). Stage C adds ship-coupling (build_phase_changed → kept), the daily deadline
# sweep (→ broken), and late-ship (→ partial). Kept: reads the persistent shipped
# feature set GameState.get_flag("mvp_components").

var _promises: Dictionary = {}  # id (String) -> Promise


func _ready() -> void:
	# Ship-coupling (§C): a Product feature reaching live keeps a matching open promise.
	EventBus.build_phase_changed.connect(_on_build_phase_changed)
	# A promise cannot outlive the company it was made to. Bound to the REMOVAL SIGNAL
	# rather than to B2BSalesSystem's churn seam on purpose: accounts also leave through
	# the `churn_customer` event modifier, which deletes the record directly, and a promise
	# left behind by that path breaks days later — charging brand a second time for a
	# company that already took its churn hit and is gone from every screen.
	EventBus.customer_removed.connect(_on_customer_removed)


# --- Read API ---

func get_promise(promise_id: String) -> Promise:
	return _promises.get(promise_id, null)


func get_all() -> Array[Promise]:
	var out: Array[Promise] = []
	for p in _promises.values():
		out.append(p)
	return out


func get_open_for(customer_id: String) -> Array[Promise]:
	var out: Array[Promise] = []
	for p in _promises.values():
		if p.status == "open" and p.customer_id == customer_id:
			out.append(p)
	return out


func has_open_for(customer_id: String) -> bool:
	for p in _promises.values():
		if p.status == "open" and p.customer_id == customer_id:
			return true
	return false


# --- Write API ---

func create(customer_id: String, feature_id: String, deadline_days: int) -> Promise:
	# The single creation seam. Emits promise_created. Deadline is relative to today.
	#
	# A PROMISE WITH NO TARGET IS REFUSED, and this is the fix for the ghost lock the F5 pass
	# found. `B2BSalesSystem.pick_pain_feature` returns "" for every shipped product — its pool
	# is keyed by the RETIRED subtype vocabulary — so `promise_create` was minting promises
	# whose feature_id was the empty string. They can never be kept (nothing ever ships ""), the
	# deadline sweep never reaches them because `has_open_for` keeps reporting true, and every
	# card that asks "is a word already open on this account" locked itself forever. One account
	# answering one retention card closed the promise lever for the rest of the run.
	#
	# Refusing at the seam is the only place that holds: three call sites create promises and a
	# fourth is a save restore. Returning null is already the shape callers handle (they check
	# the registry, not the return), and the warning names the caller so a real regression is
	# not silent.
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
## refusing them from today on does nothing for a save that already carries one — and a save
## that carries one carries a lever that is off for the rest of that run.
##
## Closed ones are left alone on purpose: kept/partial/broken are history, and rewriting history
## to tidy a bug is how a save stops matching what the player remembers doing. Returns the count.
func drop_targetless() -> int:
	var doomed: Array = []
	for pid in _promises:
		var p: Promise = _promises[pid]
		if p.status == "open" and String(p.feature_id).strip_edges() == "":
			doomed.append(pid)
	for pid in doomed:
		_promises.erase(pid)
	if not doomed.is_empty():
		print("[PromiseRegistry] dropped %d targetless promise(s) on load" % doomed.size())
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


func _on_customer_removed(customer_id: String) -> void:
	drop_open_for(customer_id)


func drop_open_for(customer_id: String) -> int:
	# DROPPED, not resolved. "broken" would emit promise_broken and run the whole penalty
	# chain — a second brand hit, with no event and no attributable cause the player can
	# read — for an account that no longer exists. Meanwhile the Product tab kept rendering
	# "SÖZ VERİLDİ · Müşteri · <özellik> · N gün" (that literal "Müşteri" IS the null
	# lookup) and counting down for a company that left days ago.
	# CLOSED promises stay: kept/partial/broken are history, and history outlives the
	# customer. Returns how many open ones were dropped.
	var dropped: int = 0
	for pid in _promises.keys():
		var p: Promise = _promises[pid]
		if p.customer_id == customer_id and p.status == "open":
			_promises.erase(pid)
			dropped += 1
	return dropped


# --- Resolution (§C): ship-coupling keeps, deadline sweep breaks, late ship is partial ---

func _on_build_phase_changed(phase: String) -> void:
	# The promised feature reaching live (member of the persistent shipped set) keeps an
	# open promise (or partially redeems a broken one if it lands late).
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
