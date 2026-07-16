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


# --- Resolution (§C): ship-coupling keeps, deadline sweep breaks, late ship is partial ---

func _on_build_phase_changed(phase: String) -> void:
	# The promised feature reaching live (member of the persistent shipped set) keeps an
	# open promise (or partially redeems a broken one if it lands late).
	if phase != "shipped":
		return
	var live: Array = GameState.get_flag("mvp_components", [])
	for p in _promises.values():
		if not live.has(p.feature_id):
			continue
		if p.status == "open":
			_resolve(p, "kept" if GameState.day <= p.deadline_day else "partial")
		elif p.status == "broken":
			_resolve(p, "partial")  # late redemption of an already-broken promise


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
