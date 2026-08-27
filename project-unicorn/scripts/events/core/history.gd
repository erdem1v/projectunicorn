class_name EvHistory
extends RefCounted

# THE MEMORY (GDD §7). One row per resolution, and — the part that matters — a query surface
# content can actually reach.
#
# THIS IS THE DEFECT THE WHOLE REBUILD EXISTS TO CLOSE. The old engine wrote history on every
# resolution (event_manager.gd:191) and `get_history()` had ZERO callers. Not one condition
# type read it. So no card could ask "did this already happen", which means no callback, no
# arc, no promise-and-payoff — and the game's thesis, "a decision on day 10 has a visible
# consequence on day 90", was dead in the engine rather than merely unwritten in the content.
# §7.2 says it plainly. Everything else here is bookkeeping around that one sentence.
#
# LANGUAGE INDEPENDENCE IS STRUCTURAL, NOT A HABIT (§7.4). Rows store ids only — event_id,
# option_id, outcome_id — never labels. A player who takes a choice on day 10 in Turkish and
# reaches the payoff on day 90 in English gets the same callback, because nothing in the row
# was ever text. The rule that makes this hold is elsewhere: the queue never stores rendered
# text either (§3.2), so there is no path by which a label reaches persistence.
#
# NO PRUNING (§7.5). A 3-5 hour run resolves 150-400 cards. That is kilobytes. Pruning would
# buy nothing and would silently break exactly the long-horizon callback the engine is for —
# the day-90 card asking about the day-10 choice is the LAST thing you want a cache eviction
# policy anywhere near.

const RESOLUTION_CHOSEN := "chosen"
const RESOLUTION_EXPIRED := "expired"
const RESOLUTION_DROPPED := "dropped"
const RESOLUTION_FORCED := "forced"

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
		# does, deliberately — a card asking about a delta is asking about a number that has
		# since moved, and it should ask the seam instead.
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


## Times it resolved by being PLAYED. Distinct from fire_count on purpose: a card that expired
## twice has fired twice and been chosen zero times, and a callback almost always means the
## second thing.
static func chosen_count(event_id: String) -> int:
	var n: int = 0
	for row in _rows_for(event_id):
		if String((row as Dictionary)["resolution"]) == RESOLUTION_CHOSEN:
			n += 1
	return n


## Did the player ever take this specific option? THE callback primitive — §5.2 lists it as
## "callback'lerin temeli" and it is what a promise arc is built on.
static func chose(event_id: String, option_id: String) -> bool:
	for row in _rows_for(event_id):
		var d: Dictionary = row
		if String(d["resolution"]) == RESOLUTION_CHOSEN and String(d["option_id"]) == option_id:
			return true
	return false


## The option taken the LAST time this card resolved, or "". Lets a card vary its body by what
## was chosen before without asking a separate question per option.
static func last_option(event_id: String) -> String:
	var rows: Array = _rows_for(event_id)
	if rows.is_empty():
		return ""
	return String((rows[rows.size() - 1] as Dictionary)["option_id"])


static func last_outcome(event_id: String) -> String:
	var rows: Array = _rows_for(event_id)
	if rows.is_empty():
		return ""
	return String((rows[rows.size() - 1] as Dictionary)["outcome_id"])


static func last_resolution(event_id: String) -> String:
	var rows: Array = _rows_for(event_id)
	if rows.is_empty():
		return ""
	return String((rows[rows.size() - 1] as Dictionary)["resolution"])


## Days since it last resolved, or -1 if it never has. -1 rather than a huge number so a
## caller cannot accidentally satisfy ">= 30" with "never happened" — the same trap
## days_since_flag documents for absent stamps.
static func days_since(event_id: String) -> int:
	var rows: Array = _rows_for(event_id)
	if rows.is_empty():
		return -1
	return GameState.day - int((rows[rows.size() - 1] as Dictionary)["day"])


static func last_day(event_id: String) -> int:
	var rows: Array = _rows_for(event_id)
	return -1 if rows.is_empty() else int((rows[rows.size() - 1] as Dictionary)["day"])


## Was this event resolved with that entity in that slot? What lets a card be about the same
## person twice — "you talked to Melisa about this in March".
static func chose_about(event_id: String, slot: String, entity_id: String) -> bool:
	for row in _rows_for(event_id):
		var ents: Dictionary = (row as Dictionary)["entities"]
		var bound: Variant = ents.get(slot, null)
		if bound != null and String((bound as Dictionary).get("id", "")) == entity_id:
			return true
	return false


## Did any telegraph for this loss fire? I3's runtime half (§8.4): a telegraph is either a flag
## that was stamped or an event that resolved, so both are checked and the caller does not
## have to know which kind the content used.
static func telegraph_fired(reference: String) -> bool:
	if reference == "":
		return false
	# THE "flag:" PREFIX IS LINT'S VOCABULARY, AND IT WAS NEVER IMPLEMENTED HERE.
	# lint.gd §17.4 accepts a telegraph that is either a card id or a name beginning
	# "flag:", and warns on anything else. A card that obeyed that spelling would then be
	# REFUSED at runtime, because this function handed the whole string — prefix included
	# — to EvFlags.has. So the only constructions that worked were the ones lint warns
	# about. Stripping the prefix makes the documented form the working form.
	#
	# Why a card cannot simply cite itself: EvHistory.record runs AFTER the option's
	# effects (engine.gd), so at the moment a terminal effect is permitted its own fire
	# count is still zero. A flag set earlier in the same effect list is true by then.
	var name: String = reference.trim_prefix("flag:")
	if EvFlags.has(name) or EvFlags.has_stamp(name):
		return true
	return fire_count(reference) > 0


# --- Whole-run reads (the ending screen, the ticker, the debug panel) ------

static func rows() -> Array:
	return _rows.duplicate(true)


static func rows_for(event_id: String) -> Array:
	return _rows_for(event_id).duplicate(true)


## Everything that resolved on a given day, in order. The ticker's "what just happened" and
## the ending screen's narrative both walk this.
static func rows_on_day(day: int) -> Array:
	var out: Array = []
	for row in _rows:
		if int((row as Dictionary)["day"]) == day:
			out.append((row as Dictionary).duplicate(true))
	return out


static func size() -> int:
	return _rows.size()


static func _rows_for(event_id: String) -> Array:
	var out: Array = []
	for i in (_by_event.get(event_id, []) as Array):
		out.append(_rows[int(i)])
	return out


# --- Lifecycle -------------------------------------------------------------

static func reset() -> void:
	_rows.clear()
	_by_event.clear()


static func to_dict() -> Dictionary:
	# The index is NOT saved: it is derivable, and a saved index is one more thing that can
	# disagree with the data it indexes.
	return {"rows": _rows.duplicate(true)}


static func from_dict(d: Dictionary) -> void:
	reset()
	for row in (d.get("rows", []) as Array):
		if typeof(row) != TYPE_DICTIONARY:
			continue
		_by_event.get_or_add(String((row as Dictionary).get("event_id", "")), []).append(_rows.size())
		_rows.append(row)
