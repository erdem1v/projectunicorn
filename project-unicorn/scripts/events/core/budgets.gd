class_name EvBudgets
extends RefCounted

# RUN-SCARCE NARRATIVE RESOURCES (GDD §8.5).
#
# Some things are only powerful because they are rare. Frank's aphorisms are the shipped
# example: two per run (§8.5, and FRANK_VOICE_INVENTORY.md keeps the same ledger from the
# writing side). The third one would not be wrong, it would be cheap — and a mentor whose
# verdicts are cheap is no longer a mentor.
#
# §8.5's second half is the part that makes this a mechanic rather than a counter: when a
# budget runs out, the option carrying it LOCKS AND SHOWS ITS REASON. It does not vanish. The
# player learns the resource existed by watching it run out, which is the only way a scarce
# thing can teach anything.

## name -> remaining
static var _left: Dictionary = {}
static var _seeded: bool = false


static func _ensure() -> void:
	if _seeded:
		return
	_seeded = true
	for name in EvTuning.BUDGETS:
		_left[name] = int(EvTuning.BUDGETS[name])


static func remaining(name: String) -> int:
	_ensure()
	return int(_left.get(name, 0))


static func can_spend(name: String) -> bool:
	return remaining(name) > 0


## Spend one and report what is left. Refuses at zero rather than going negative — an option
## that reached here with an empty budget got past its own `requires`, which is a content bug
## worth seeing rather than absorbing.
static func spend(name: String) -> int:
	_ensure()
	var left: int = remaining(name)
	if left <= 0:
		push_error("[EvBudgets] '%s' is exhausted; the option should have been locked" % name)
		return 0
	_left[name] = left - 1
	return left - 1


static func reset() -> void:
	_left.clear()
	_seeded = false


static func to_dict() -> Dictionary:
	_ensure()
	return {"budgets": _left.duplicate(true)}


static func from_dict(d: Dictionary) -> void:
	reset()
	_ensure()
	for name in (d.get("budgets", {}) as Dictionary):
		_left[name] = int((d["budgets"] as Dictionary)[name])
