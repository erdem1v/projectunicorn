class_name EvHistory
extends RefCounted

# THE MEMORY (GDD §7). One row per resolution, and a query surface content can actually reach:
# "a decision on day 10 has a visible consequence on day 90" (§7.2) needs a card to be able to
# ask what already happened.
#
# LANGUAGE INDEPENDENCE IS STRUCTURAL (§7.4). Rows store ids only — event_id, option_id,
# outcome_id — never labels, so a callback survives a language switch mid-run.
#
# NO PRUNING (§7.5). A run resolves a few hundred cards; pruning would buy nothing and would
# break exactly the long-horizon callback the engine is for.

const RESOLUTION_CHOSEN := "chosen"
const RESOLUTION_EXPIRED := "expired"
const RESOLUTION_DROPPED := "dropped"

## Array of rows, oldest first. §7.1's shape.
static var _rows: Array = []
## event_id -> Array[int] of indices into _rows. Pure acceleration, rebuilt on load.
static var _by_event: Dictionary = {}


# --- Writing ---------------------------------------------------------------

## The single write. Every resolution goes through here, including the ones nobody played:
## an expiry and a display-time drop are both facts a later card may need.
static func record(event_id: String, resolution: String, option_id: String,
		outcome_id: String, entities: Dictionary, deltas: Array,
		arc_id: String = "", forced: bool = false) -> void:
	var row: Dictionary = {
		"event_id": event_id,
		"day": GameState.day,
		"resolution": resolution,
		"option_id": option_id,
		"outcome_id": outcome_id,
		# {slot: {type, id}} — the scope AS RESOLVED, so a later card can ask "who was it
		# about" even after that person has left the company.
		"entities": entities.duplicate(true),
		# What the effects actually did. Debug and the ending screen read it; no condition
		# does — a card asking about a delta should ask the seam for the live number instead.
		"deltas": deltas.duplicate(true),
		"arc_id": arc_id,
	}
	if forced:
		row["forced"] = true
	_by_event.get_or_add(event_id, []).append(_rows.size())
	_rows.append(row)


# --- The query surface §5.2's history leaves read --------------------------

## How many times this card has resolved, in any way. The latch's raw material.
static func fire_count(event_id: String) -> int:
	return (_by_event.get(event_id, []) as Array).size()


## Times it resolved by being PLAYED. A card that expired twice has fired twice and been chosen
## zero times, and a callback almost always means the second thing.
static func chosen_count(event_id: String) -> int:
	var n: int = 0
	for row in _rows_for(event_id):
		if String(row["resolution"]) == RESOLUTION_CHOSEN:
			n += 1
	return n


## Did the player ever take this specific option? The callback primitive (§5.2).
static func chose(event_id: String, option_id: String) -> bool:
	for row in _rows_for(event_id):
		if String(row["resolution"]) == RESOLUTION_CHOSEN and String(row["option_id"]) == option_id:
			return true
	return false


## The option taken the LAST time this card resolved, or "".
static func last_option(event_id: String) -> String:
	return String(_last_row(event_id).get("option_id", ""))


static func last_outcome(event_id: String) -> String:
	return String(_last_row(event_id).get("outcome_id", ""))


static func last_resolution(event_id: String) -> String:
	return String(_last_row(event_id).get("resolution", ""))


static func last_day(event_id: String) -> int:
	return int(_last_row(event_id).get("day", -1))


## Days since it last resolved, or -1 if it never has — so "never happened" cannot satisfy
## ">= 30".
static func days_since(event_id: String) -> int:
	var day: int = last_day(event_id)
	return -1 if day < 0 else GameState.day - day


## Was this event resolved with that entity in that slot? What lets a card be about the same
## person twice.
static func chose_about(event_id: String, slot: String, entity_id: String) -> bool:
	for row in _rows_for(event_id):
		var bound: Variant = (row["entities"] as Dictionary).get(slot, null)
		if bound != null and String((bound as Dictionary).get("id", "")) == entity_id:
			return true
	return false


## Did any telegraph for this loss fire? I3's runtime half (§8.4): a telegraph is either a flag
## ("flag:" prefix, lint's spelling) or an event that resolved.
##
## A card cannot cite itself: history is recorded AFTER the option's effects, so its own fire
## count is still zero when a terminal effect is checked. A flag set earlier in the same effect
## list is already true by then.
static func telegraph_fired(reference: String) -> bool:
	if reference == "":
		return false
	var name: String = reference.trim_prefix("flag:")
	if EvFlags.has(name) or EvFlags.has_stamp(name):
		return true
	return fire_count(reference) > 0


# --- Whole-run reads -------------------------------------------------------

static func rows() -> Array:
	return _rows.duplicate(true)


static func _rows_for(event_id: String) -> Array:
	return (_by_event.get(event_id, []) as Array).map(func(i): return _rows[int(i)])


static func _last_row(event_id: String) -> Dictionary:
	var indices: Array = _by_event.get(event_id, [])
	return {} if indices.is_empty() else _rows[int(indices[-1])]


# --- Lifecycle -------------------------------------------------------------

static func reset() -> void:
	_rows.clear()
	_by_event.clear()


## The index is not saved: it is derivable, and a saved index could disagree with its data.
static func to_dict() -> Dictionary:
	return {"rows": _rows.duplicate(true)}


static func from_dict(d: Dictionary) -> void:
	reset()
	for row in (d.get("rows", []) as Array):
		if typeof(row) != TYPE_DICTIONARY:
			continue
		_by_event.get_or_add(String(row.get("event_id", "")), []).append(_rows.size())
		_rows.append(row)
