class_name EvQueue
extends RefCounted

# ADMITTED, NOT YET SHOWN (GDD §2, §11.2). One entry:
#
#     {event_id, context, admitted_day, class, arc_id}
#
# IDS AND SCALARS ONLY — never a card object and never rendered text.
#
# The old engine stored WHOLE SERIALISED CARDS here, and had to: factories minted synthetic
# events the catalogue had never heard of, so an id-only queue would have restored as a
# silently shorter one (event_manager.gd:263-268 says so, and it was right at the time). The
# new engine has no synthetics — every card is on disk — so the queue holds ids, and two
# properties fall out of that for free:
#
#   A LANGUAGE CHANGE MID-RUN IS SAFE (§3.2). Nothing here is text, so there is nothing to be
#   stale. A paper sitting on the desk when the player switches to English simply renders in
#   English. The old queue could hold a card whose text had been baked at build time in the
#   other locale.
#
#   A CONTENT EDIT REACHES QUEUED CARDS. Fix a card and every queued instance is fixed.
#
# DEDUPE IS BY ID. The old engine's first version compared Array.has() on Array[GameEvent],
# which compares REFERENCES — so a factory minting a fresh instance per call walked straight
# past it and the queue could hold N copies of one decision. That was fixed before this
# rebuild (event_manager.gd:138-154 carries the archaeology); it is preserved here as a
# property of the design rather than a repair, because ids are all there is to compare.
#
# ORDERING IS §11.2's, AND IT IS NOT INSERTION ORDER. Terminal telegraphs first, then a paper
# about to expire, then critical, then interrupt, paper, info, ambient. Ties break by admitted
# day and then alphabetically by id — deterministic, and deliberately NOT seeded, so the order
# two players see in the same state is the same order.

## §11.2, most urgent first.
const PRIORITY := ["terminal", "expiring", "critical", "interrupt", "paper", "info", "ambient"]

static var _entries: Array = []
## The card on screen right now. "" when nothing is.
static var _active_id: String = ""
static var _active_context: Dictionary = {}


# --- Admission (only EvGate's caller reaches this) -------------------------

## Returns false when an entry with this id is already queued or showing.
##
## The rejection is REPORTED, not swallowed. In the old engine all three admission paths
## rejected a duplicate silently, and that is exactly the shape a runaway hides behind: the
## owning system re-offers the same decision every tick, the queue absorbs it, and nothing
## anywhere counts the attempts. A debug print was added late (event_manager.gd:243-245) for
## precisely that reason; here the count is kept, because "fired once" and "tried ninety times"
## should not look identical in a run log.
static func admit(event_id: String, context: Dictionary, card_class: String,
		arc_id: String = "") -> bool:
	if has(event_id) or _active_id == event_id:
		_absorbed[event_id] = int(_absorbed.get(event_id, 0)) + 1
		return false
	_entries.append({
		"event_id": event_id,
		"context": context.duplicate(true),
		"admitted_day": GameState.day,
		"class": card_class,
		"arc_id": arc_id,
	})
	return true


static var _absorbed: Dictionary = {}

## How many times an id was offered and absorbed as a duplicate. The run log reads it.
static func absorbed_count(event_id: String) -> int:
	return int(_absorbed.get(event_id, 0))


# --- Selection -------------------------------------------------------------

## The next entry to show, or {}. §11.2's order, applied over the whole queue rather than to
## the front — the queue is a set of candidates, not a line.
static func next() -> Dictionary:
	if _entries.is_empty():
		return {}
	var best: Dictionary = {}
	var best_rank: int = PRIORITY.size() + 1
	for e in _entries:
		var entry: Dictionary = e
		var rank: int = _rank_of(entry)
		if rank < best_rank or (rank == best_rank and _earlier(entry, best)):
			best = entry
			best_rank = rank
	return best


static func _rank_of(entry: Dictionary) -> int:
	var card: Dictionary = EvCatalog.card(String(entry["event_id"]))
	var tags: Array = card.get("tags", [])
	if tags.has("terminal_warning"):
		return 0
	if EvPapers.is_expiring_soon(String(entry["event_id"])):
		return 1
	if tags.has("critical"):
		return 2
	var idx: int = PRIORITY.find(String(entry["class"]))
	return idx if idx >= 0 else PRIORITY.size()


static func _earlier(a: Dictionary, b: Dictionary) -> bool:
	if b.is_empty():
		return true
	var da: int = int(a["admitted_day"])
	var db: int = int(b["admitted_day"])
	if da != db:
		return da < db
	return String(a["event_id"]) < String(b["event_id"])


static func take(event_id: String) -> Dictionary:
	for i in _entries.size():
		if String((_entries[i] as Dictionary)["event_id"]) == event_id:
			var entry: Dictionary = _entries[i]
			_entries.remove_at(i)
			return entry
	return {}


# --- The active card -------------------------------------------------------

static func set_active(event_id: String, context: Dictionary) -> void:
	_active_id = event_id
	_active_context = context.duplicate(true)


static func clear_active() -> void:
	_active_id = ""
	_active_context = {}


static func active_id() -> String:
	return _active_id


static func active_context() -> Dictionary:
	return _active_context


# --- Reading ---------------------------------------------------------------

static func has(event_id: String) -> bool:
	for e in _entries:
		if String((e as Dictionary)["event_id"]) == event_id:
			return true
	return false


static func size() -> int:
	return _entries.size()


static func ids() -> Array:
	var out: Array = []
	for e in _entries:
		out.append(String((e as Dictionary)["event_id"]))
	return out


static func entries() -> Array:
	return _entries.duplicate(true)


static func context_of(event_id: String) -> Dictionary:
	for e in _entries:
		if String((e as Dictionary)["event_id"]) == event_id:
			return (e as Dictionary)["context"]
	return {}


# --- Surgery ---------------------------------------------------------------

## Write back the class the tempo governor assigned. Separate from admit() because the class
## is decided over the whole day's admissions at once, not per proposal — the third card to
## arrive is not the least important one.
static func set_class(event_id: String, card_class: String) -> void:
	for e in _entries:
		if String((e as Dictionary)["event_id"]) == event_id:
			(e as Dictionary)["class"] = card_class
			return


static func remove(event_id: String) -> bool:
	return not take(event_id).is_empty()


static func drop_arc(arc_id: String) -> int:
	if arc_id == "":
		return 0
	var before: int = _entries.size()
	_entries = _entries.filter(func(e): return String(e["arc_id"]) != arc_id)
	return before - _entries.size()


## Terminal reached (§7.2 of ENDGAME_DESIGN): queued cards die with the run. The ACTIVE card is
## deliberately left alone — an open modal resolves normally, and its post-resolve speed
## restore is swallowed by the dead-run guard.
static func flush() -> void:
	_entries.clear()


# --- Lifecycle -------------------------------------------------------------

static func reset() -> void:
	_entries.clear()
	_absorbed.clear()
	clear_active()


static func to_dict() -> Dictionary:
	return {
		"queue": _entries.duplicate(true),
		"active_event_id": _active_id,
		"active_context": _active_context.duplicate(true),
	}


static func from_dict(d: Dictionary) -> void:
	reset()
	for e in (d.get("queue", []) as Array):
		if typeof(e) != TYPE_DICTIONARY:
			continue
		if not EvCatalog.has_card(String((e as Dictionary).get("event_id", ""))):
			push_error("[EvQueue] dropping queued '%s' — no such card"
				% (e as Dictionary).get("event_id", ""))
			continue
		_entries.append(e)
	_active_id = String(d.get("active_event_id", ""))
	_active_context = (d.get("active_context", {}) as Dictionary).duplicate(true)
	if _active_id != "" and not EvCatalog.has_card(_active_id):
		push_error("[EvQueue] active card '%s' no longer exists — cleared" % _active_id)
		clear_active()
