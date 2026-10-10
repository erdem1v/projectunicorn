class_name EvDelays
extends RefCounted

# THE DELAY WINDOW (GDD §27.19). A threshold is a GATE, not a date.
#
# Before this, a card whose condition first held in week 12 arrived in week 12 of every run: the
# pool is thin, so "eligible" and "fired" were one event and the player learned the calendar
# instead of the company. A card now declares `delay_weeks: [N, M]`; the week its condition
# first holds ARMS a window, and the card is a candidate only once that window is up.
#
# THE WAIT IS DRAWN ONCE, NOT ROLLED EVERY WEEK. MTTH's weekly coin would hand a reload a fresh
# roll; one draw from EvDice's hash of (seed, d0, card, subject) cannot drift, so a reloaded
# week keeps the same due date and the window is not a save-scum.
#
# A condition that stops holding for DISARM_WEEKS running throws the window away: the situation
# the card described is over. Below that it survives a condition that comes and goes, because
# sprint-shaped conditions do exactly that, and a lost window would be a lost card.
#
# It also keeps the view the module watch compares against. Whether a module's page was
# reachable yesterday is engine memory like any other, so it rides in the same save block.

const ModuleLocks := preload("res://scripts/systems/module_locks.gd")

## Armed windows, EvLatches key -> {d0, due, last_hold}. `last_hold` is the last tick the card
## was eligible, which is what DISARM_WEEKS measures.
static var _armed: Dictionary = {}

## The last reading of ModuleLocks.is_open, module id -> bool. Empty means never read: the first
## tick of a run seeds it and names nobody, because everything open at boot was always open.
static var _modules: Dictionary = {}

## The module that opened most recently, behind the `build.last_unlocked_module` seam.
static var _last_unlocked: String = ""


# --- The window ------------------------------------------------------------

## Arm this candidate's window if it has none, write this week down as one the condition held,
## and answer whether the wait is up. Asked the week the GATE admits the card and before the
## brakes run: R6 counts the disarm from the condition, not from what the brakes allowed.
## Takes the RESOLVED context: the window is per instance, and `delay_mult` may read a leaf
## about the subject.
static func touch(card: Dictionary, context: Dictionary) -> bool:
	if _span(card).is_empty():
		return true
	var key: String = EvLatches.key_of(String(card["id"]), context)
	var entry: Dictionary = window(key)
	if entry.is_empty():
		entry = {"d0": GameState.day,
			"due": GameState.day + TimeModel.ticks(draw_weeks(card, context))}
	entry["last_hold"] = GameState.day
	_armed[key] = entry
	return GameState.day >= int(entry["due"])


## The armed window, {} when none is armed or the armed one has gone stale: a condition that has
## not held for DISARM_WEEKS running has thrown its window away. `last_hold` is the last week
## it DID hold, so the un-held run is the weeks between it and today: one sprint cadence (holds
## in week 10, holds again in week 14) survives, a fifth silent week does not. Reading neither
## arms nor disarms — --why-fire asks the same question the pool asks and must not change the
## answer; `touch` overwrites the stale row with its new draw.
static func window(key: String) -> Dictionary:
	var entry: Dictionary = _armed.get(key, {})
	if entry.is_empty() \
			or GameState.day - int(entry["last_hold"]) > TimeModel.ticks(EvTuning.DISARM_WEEKS):
		return {}
	return entry


## The wait, in weeks, for a card that declares one; 0 for a card that does not. A signal card's
## schedule entry is dated by the same draw, so a card waits the same whichever origin reaches
## it and `delay_mult` reads the same leaves on both paths.
static func draw_weeks(card: Dictionary, context: Dictionary) -> int:
	var span: Array = _span(card)
	if span.is_empty():
		return 0
	var lo: int = int(span[0])
	var hi: int = int(span[1])
	var roll: float = EvDice.unit("delay", GameState.day, String(card["id"]),
		EvGate.subject_of(context))
	var weeks: float = float(lo) + floorf(roll * float(hi - lo + 1))
	# A pressure that holds AT ARMING shortens the wait: a team at low morale does not sit on
	# its grievance for a month. Read once, here, so the due date stays a date.
	for row in (card.get("delay_mult", []) as Array):
		if EvCondition.eval(row as Dictionary, context):
			weeks *= float((row as Dictionary).get("factor", 1.0))
	return clampi(int(round(weeks)), lo, hi)


## `delay_weeks` when it asks for a wait at all. [0, 0] and a card from before schema v3 keep
## today's behaviour: no window, no entry, no dice.
static func _span(card: Dictionary) -> Array:
	var span: Array = card.get("delay_weeks", [])
	return span if span.size() == 2 and int(span[1]) > 0 else []


## Throw a window away: the card it waited for has been admitted, so the next one draws again.
static func disarm(key: String) -> void:
	_armed.erase(key)


# --- The module view -------------------------------------------------------

## The modules that went from locked to open since the last reading, and the only writer of
## `build.last_unlocked_module`.
static func module_openings() -> Array:
	var now: Dictionary = {}
	for id: String in ModuleLocks.ids():
		now[id] = ModuleLocks.is_open(id)
	var opened: Array = []
	if not _modules.is_empty():
		for id: String in now:
			if bool(now[id]) and not bool(_modules.get(id, false)):
				opened.append(id)
				_last_unlocked = id
	_modules = now
	return opened


static func last_unlocked_module() -> String:
	return _last_unlocked


# --- Lifecycle -------------------------------------------------------------

static func reset() -> void:
	_armed.clear()
	_modules.clear()
	_last_unlocked = ""


static func to_dict() -> Dictionary:
	return {"delays": _armed.duplicate(true), "modules_open": _modules.duplicate(),
		"last_unlocked_module": _last_unlocked}


static func from_dict(d: Dictionary) -> void:
	_armed = (d.get("delays", {}) as Dictionary).duplicate(true)
	_modules = (d.get("modules_open", {}) as Dictionary).duplicate()
	_last_unlocked = String(d.get("last_unlocked_module", ""))
