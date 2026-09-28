class_name EvFlags
extends RefCounted

# THE ENGINE'S OWN FLAG STORE (GDD §16.1). Three kinds of memory that are not History:
#
#   flags        a fact that is simply true    "frank_seed_taken"
#   timed_flags  a fact with an expiry tick    "negotiation_window_open" for 1 week
#   stamps       a tick something happened     weeks_since_flag reads these
#
# SEPARATE FROM GameState.flags ON PURPOSE. GameState.flags is SYSTEM state (FLAG_TYPES);
# letting a card write it through a generic set_flag would let content reach past every seam,
# which the WRITE-THROUGH LAW forbids. So `set_flag` in the effect vocabulary writes HERE, and
# anything touching system state gets a NAMED verb routed through the owning system's seam.
#
# PROVENANCE. Each record carries who set it and when, so the debug panel can tell "flag X"
# from "HRSystem decided" (I5).

## name -> {set_day: int, set_by: String}
static var _flags: Dictionary = {}
## name -> {expires_on: int, set_day: int, set_by: String}
static var _timed: Dictionary = {}
## name -> {day: int, set_by: String}
static var _stamps: Dictionary = {}


# --- Plain flags -----------------------------------------------------------

static func set_flag(name: String, source: String = "effect") -> void:
	_flags[name] = {"set_day": GameState.day, "set_by": source}


static func clear_flag(name: String) -> void:
	_flags.erase(name)
	_timed.erase(name)


## True when the flag is set AND, if it is a timed flag, has not expired.
## §5.3: an unknown flag is FALSE, never an error — the namespace is additive, so an old save
## that has never heard of a new flag is correct rather than broken.
static func has(name: String) -> bool:
	if _flags.has(name):
		return true
	if _timed.has(name):
		return int((_timed[name] as Dictionary)["expires_on"]) >= GameState.day
	return false


# --- Timed flags -----------------------------------------------------------

static func set_timed(name: String, weeks: int, source: String = "effect") -> void:
	_timed[name] = {
		"expires_on": GameState.day + TimeModel.ticks(weeks),
		"set_day": GameState.day,
		"set_by": source,
	}


## Weeks left before it lapses; -1 when it is not a live timed flag at all.
## -1 rather than 0 so `flag_expires_within: 0` cannot be satisfied by "there is no such flag".
static func weeks_until_expiry(name: String) -> int:
	if not _timed.has(name):
		return -1
	var left: int = int((_timed[name] as Dictionary)["expires_on"]) - GameState.day
	return left if left >= 0 else -1


## Sweep lapsed timed flags. Called once per daily tick, BEFORE any condition is read, so a
## flag can never be observed one tick past its own expiry.
static func tick_expiry() -> void:
	for name in _timed.keys():
		if int((_timed[name] as Dictionary)["expires_on"]) < GameState.day:
			_timed.erase(name)


# --- Stamps ----------------------------------------------------------------

## Mark this tick. Re-stamping MOVES the stamp: "weeks since the last time X happened" is almost
## always the question, and a stamp that refused to move would answer a different one.
static func stamp(name: String, source: String = "effect") -> void:
	_stamps[name] = {"day": GameState.day, "set_by": source}


static func has_stamp(name: String) -> bool:
	return _stamps.has(name)


## Weeks elapsed since the stamp, or -1 when it was never stamped. The caller must treat -1 as
## "no", never as a large number — see the note in EvCondition._leaf_weeks_since.
static func weeks_since(name: String) -> int:
	if not _stamps.has(name):
		return -1
	return GameState.day - int((_stamps[name] as Dictionary)["day"])


# --- Provenance (the debug panel) ------------------------------------------

## {kind, set_day, set_by, expires_on?} or {} when nothing here knows the name.
static func provenance(name: String) -> Dictionary:
	if _flags.has(name):
		var f: Dictionary = _flags[name]
		return {"kind": "flag", "set_day": f["set_day"], "set_by": f["set_by"]}
	if _timed.has(name):
		var t: Dictionary = _timed[name]
		return {"kind": "timed", "set_day": t["set_day"], "set_by": t["set_by"],
			"expires_on": t["expires_on"]}
	if _stamps.has(name):
		var s: Dictionary = _stamps[name]
		return {"kind": "stamp", "set_day": s["day"], "set_by": s["set_by"]}
	return {}


# --- Lifecycle -------------------------------------------------------------

static func reset() -> void:
	_flags.clear()
	_timed.clear()
	_stamps.clear()


static func to_dict() -> Dictionary:
	return {
		"flags": _flags.duplicate(true),
		"timed_flags": _timed.duplicate(true),
		"stamps": _stamps.duplicate(true),
	}


static func from_dict(d: Dictionary) -> void:
	_flags = (d.get("flags", {}) as Dictionary).duplicate(true)
	_timed = (d.get("timed_flags", {}) as Dictionary).duplicate(true)
	_stamps = (d.get("stamps", {}) as Dictionary).duplicate(true)
