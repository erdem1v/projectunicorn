class_name EvBudgets
extends RefCounted

# RUN-SCARCE NARRATIVE RESOURCES (GDD §8.5). Some things are powerful only because they are rare
# — Frank's aphorisms, two per run: a third would be cheap, and a mentor whose verdicts are cheap
# is no longer a mentor. When a budget runs out the option carrying it LOCKS AND SHOWS ITS
# REASON rather than vanishing, so the player learns the resource existed by watching it run out.

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


## Spend one and report what is left. Refuses at zero rather than going negative — an option that
## got here with an empty budget slipped past its own `requires`, a content bug worth seeing.
static func spend(name: String) -> int:
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
	var saved: Dictionary = d.get("budgets", {})
	for name in saved:
		_left[name] = int(saved[name])
