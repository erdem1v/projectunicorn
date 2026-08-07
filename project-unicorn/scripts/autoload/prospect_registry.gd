extends Node

# Prospect (sales lead) registry — PostShip spec §B.
# Single source of truth for B2B leads awaiting a pitch. Mirrors
# CustomerRegistry's pattern: mutations route through methods and emit on
# EventBus so the Sales tab repaints itself. On a successful pitch the caller
# converts the Prospect into a Customer (CustomerRegistry.add) and calls
# remove() here — prospects therefore never contribute to MRR.
#
# Naming caution: get_prospect (not get) — Object.get(prop) is reserved.

var _prospects: Dictionary = {}  # id (String) -> Prospect


# --- Read API ---

func get_prospect(prospect_id: String) -> Prospect:
	return _prospects.get(prospect_id, null)


func get_all() -> Array[Prospect]:
	var out: Array[Prospect] = []
	for p in _prospects.values():
		out.append(p)
	return out


func count() -> int:
	return _prospects.size()


func has_any() -> bool:
	return not _prospects.is_empty()


func get_company_names() -> Array:
	# Company names of every live lead — PitchSystem's spawn-dedup input (Fix 1).
	var out: Array = []
	for p in _prospects.values():
		out.append(p.company_name)
	return out


# --- Write API ---

func add(prospect: Prospect) -> void:
	if prospect == null or prospect.id == "":
		push_warning("[ProspectRegistry] add() called with null or missing id")
		return
	if _prospects.has(prospect.id):
		push_warning("[ProspectRegistry] add() id collision: %s" % prospect.id)
		return
	_prospects[prospect.id] = prospect
	EventBus.prospect_added.emit(prospect.id)


func insert_raw(prospect: Prospect) -> void:
	# SAVE RESTORE ONLY — no prospect_added emit (the shell is not in the tree during a
	# load). Mirrors CustomerRegistry.insert_raw / CharacterRegistry.insert_raw.
	if prospect == null or prospect.id == "":
		push_warning("[ProspectRegistry] insert_raw() called with null or missing id")
		return
	_prospects[prospect.id] = prospect


func reset() -> void:
	# Run-boundary reset (SaveManager.reset_all_owners). Without it an in-place restart
	# began with the previous company's open leads sitting in the pipeline — and worse,
	# PitchSystem's spawn dedup reads get_company_names(), so those ghosts also silently
	# excluded their own companies from the new run's prospect pool.
	# Direct clear, no prospect_removed emits — same doctrine as CustomerRegistry.reset().
	_prospects.clear()


func remove(prospect_id: String) -> void:
	if not _prospects.has(prospect_id):
		return
	_prospects.erase(prospect_id)
	EventBus.prospect_removed.emit(prospect_id)
