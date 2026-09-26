class_name EvSchedule
extends RefCounted

# DEFERRED CONSEQUENCES, AS PURE DATA (GDD §16.2). One entry:
#
#     {event_id, fire_on_day, context, arc_id}
#
# A FUNCTION POINTER IS NEVER STORED HERE (§16.2). A serialised Callable may name an object or
# method that no longer exists after a load or a patch, and fails as a consequence that silently
# never arrives; a save that names a method can also ask the game to call something. Behaviour
# re-resolved from an id also picks up content edits.
#
# ABSOLUTE DAYS ONLY (§16.3), never "ticks remaining", so save/load and speed changes cannot
# distort the arithmetic. §20 B1: a due day that has PASSED fires immediately, never skipped.
# The one exception is a frozen arc, which stores RELATIVE days on the arc itself (see
# EvArcs.pause_for_subject) so the global schedule stays purely absolute.

## Array of entries, kept sorted by fire_on_day so due() is a prefix scan.
static var _entries: Array = []


# --- Writing ---------------------------------------------------------------

static func add(event_id: String, delay_days: int, context: Dictionary = {},
		arc_id: String = "") -> void:
	_entries.append({
		"event_id": event_id,
		"fire_on_day": GameState.day + maxi(0, delay_days),
		# Scalars only: EvScope stores {type, id, bound_day}, never an object. A Resource here
		# would come back on load as a private copy of a dead entity.
		"context": context.duplicate(true),
		"arc_id": arc_id,
	})
	_sort()


static func cancel(event_id: String) -> int:
	return _drop_where("event_id", event_id)


## Everything an arc has pending. Called when the arc ends or aborts (§20 G3).
static func drop_arc(arc_id: String) -> int:
	return 0 if arc_id == "" else _drop_where("arc_id", arc_id)


static func _drop_where(field: String, value: String) -> int:
	var before: int = _entries.size()
	_entries = _entries.filter(func(e): return String(e[field]) != value)
	return before - _entries.size()


# --- Freezing (the reassign policy) ----------------------------------------

## Take an arc's entries OUT of the schedule and hand them back as relative delays. The arc
## holds them until it has a subject again.
static func freeze_arc(arc_id: String) -> Array:
	var frozen: Array = []
	var kept: Array = []
	for e in _entries:
		var entry: Dictionary = e
		if String(entry["arc_id"]) == arc_id:
			frozen.append({
				"event_id": entry["event_id"],
				"remaining_days": maxi(0, int(entry["fire_on_day"]) - GameState.day),
				"context": entry["context"],
			})
		else:
			kept.append(entry)
	_entries = kept
	return frozen


## Put them back, re-materialising absolute days from today. An arc that waited nine days
## resumes with nine days still to go on each step — not nine steps due at once.
static func thaw_arc(arc_id: String, frozen: Array) -> void:
	for f in frozen:
		var entry: Dictionary = f
		add(String(entry["event_id"]), int(entry["remaining_days"]),
			entry.get("context", {}), arc_id)


# --- Reading ---------------------------------------------------------------

## Entries due today or overdue, removed from the schedule as they are handed over.
## Overdue is not an error and is not skipped — see the header.
static func take_due() -> Array:
	var due: Array = []
	var kept: Array = []
	for e in _entries:
		if int((e as Dictionary)["fire_on_day"]) <= GameState.day:
			due.append(e)
		else:
			kept.append(e)
	_entries = kept
	return due


static func pending() -> Array:
	return _entries.duplicate(true)


static func has(event_id: String) -> bool:
	for e in _entries:
		if String((e as Dictionary)["event_id"]) == event_id:
			return true
	return false


static func size() -> int:
	return _entries.size()


static func _sort() -> void:
	_entries.sort_custom(func(a, b):
		if int(a["fire_on_day"]) == int(b["fire_on_day"]):
			return String(a["event_id"]) < String(b["event_id"])   # total order, no RNG
		return int(a["fire_on_day"]) < int(b["fire_on_day"]))


# --- Lifecycle -------------------------------------------------------------

static func reset() -> void:
	_entries.clear()


static func to_dict() -> Dictionary:
	return {"schedule": _entries.duplicate(true)}


static func from_dict(d: Dictionary) -> void:
	reset()
	for e in (d.get("schedule", []) as Array):
		if typeof(e) != TYPE_DICTIONARY:
			continue
		# §16.4: a scheduled id the catalogue no longer knows is dropped with a log, never a
		# crash. Content moves; saves outlive it.
		if not EvCatalog.has_card(String((e as Dictionary).get("event_id", ""))):
			push_error("[EvSchedule] dropping scheduled '%s' — no such card"
				% (e as Dictionary).get("event_id", ""))
			continue
		_entries.append(e)
	_sort()
