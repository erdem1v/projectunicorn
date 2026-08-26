class_name EvLatches
extends RefCounted

# REPEAT BRAKES, OWNED BY THE ENGINE (GDD §3.1, §4.1 G3).
#
# THE DEFECT THIS CLOSES, measured rather than asserted. `GameEvent.one_shot` and
# `cooldown_days` existed on the old data model and were INERT on every injected card, because
# enqueue() bypassed the eligibility pass entirely (event_manager.gd:200-214). Result: 19
# production injection sites, and 17 of them hand-rolled their own latch in their own
# vocabulary — a GameState flag here, a field on Customer there, a static bool, a dictionary
# key, a rolling array of day stamps. Six mechanisms for one idea.
#
# The one that forgot is vc_pitch_system.gd:460, and it is worse than an omission: its card is
# built with a CONSTANT id, so when two term sheets warn on the same day the second is
# silently absorbed by the queue's dedupe and the surviving card names the wrong investor's
# deadline. Nobody could see it, because a dedupe rejection was a debug print.
#
# So the latch moves into the engine and the card declares it as data. That is not tidiness —
# it is the difference between "the author remembered" and "the author cannot forget".
#
# TWO KEYS (§3.1 latch_key).
#
#   run     one latch for the card, whatever it is about. A phase gate fires once per run.
#   entity  one latch PER SUBJECT. Two employees may each ask for a raise on the same day, and
#           that is correct — GDD §20 A6 says so. A single run-key latch would swallow the
#           second person's card and the player would never learn they were unhappy.
#
# G3 IS NOT RE-RUN AT DISPLAY (§4.4). A card admitted yesterday has already spent its cooldown;
# charging it again at display would make a queued card expire on a rule it already passed.

const ONE_SHOT := "one_shot"
const MAX_FIRES := "max_fires"
const COOLDOWN := "cooldown_days"

## §3.1: a card that declares nothing gets a 30-day cooldown, not free repetition. The default
## is deliberately conservative — an author who wants a card back sooner says so, and the
## linter warns below 7 days (§17.9).
const DEFAULT_COOLDOWN_DAYS := 30

const KEY_RUN := "run"
const KEY_ENTITY := "entity"

## latch key string -> {fires: int, last_day: int}
static var _state: Dictionary = {}


# --- The key ---------------------------------------------------------------

## "event_id" for a run latch, "event_id@entity_id" for an entity latch. The subject id comes
## from the card's PRIMARY scope slot, resolved before G3 runs — which is why G5 (scope) is
## ordered before G3 would otherwise want to be, and why the gate resolves scope early.
static func key_for(event_id: String, latch_key: String, subject_id: String) -> String:
	if latch_key == KEY_ENTITY and subject_id != "":
		return "%s@%s" % [event_id, subject_id]
	return event_id


# --- The gate's question ---------------------------------------------------

## Blocking reason, or "" when the card may pass. A STRING rather than a bool because the
## "why didn't this fire" panel has to print it, and deriving that text later from a bool is
## how a panel starts guessing.
static func blocked_reason(card_latch: Dictionary, key: String) -> String:
	var st: Dictionary = _state.get(key, {"fires": 0, "last_day": -1})
	var fires: int = int(st["fires"])
	var last_day: int = int(st["last_day"])

	if bool(card_latch.get(ONE_SHOT, false)):
		return "one_shot: already fired on day %d" % last_day if fires > 0 else ""

	if card_latch.has(MAX_FIRES):
		var cap: int = int(card_latch[MAX_FIRES])
		if fires >= cap:
			return "max_fires: %d of %d used" % [fires, cap]

	var cd: int = _cooldown_of(card_latch)
	if cd > 0 and fires > 0:
		var since: int = GameState.day - last_day
		if since < cd:
			return "cooldown: %d of %d days" % [since, cd]

	return ""


## §3.1 writes the latch field as `one_shot | max_fires:N | cooldown_days:N` — alternatives,
## not a stack. So the 30-day default applies to a card that declares NO brake at all; a card
## that says max_fires:2 has already named its brake and does not silently acquire a second
## one on top of it. (How soon a card may return is min_gap_days' job, §13.3 layer 1. Two
## different questions: "how many times ever" and "how soon again".)
static func _cooldown_of(card_latch: Dictionary) -> int:
	if card_latch.has(COOLDOWN):
		return int(card_latch[COOLDOWN])
	if card_latch.has(MAX_FIRES) or bool(card_latch.get(ONE_SHOT, false)):
		return 0
	return DEFAULT_COOLDOWN_DAYS


# --- Spending --------------------------------------------------------------

## Spend the latch. Called at ADMISSION, not at resolution — a card that reached the queue has
## consumed its slot even if the player never answers it, which is what stops a queued card
## from being re-proposed every tick while it waits.
static func spend(key: String) -> void:
	var st: Dictionary = _state.get(key, {"fires": 0, "last_day": -1})
	st["fires"] = int(st["fires"]) + 1
	st["last_day"] = GameState.day
	_state[key] = st


# --- Introspection (the debug panel) ---------------------------------------

static func fires(key: String) -> int:
	return int((_state.get(key, {}) as Dictionary).get("fires", 0))


static func last_day(key: String) -> int:
	return int((_state.get(key, {}) as Dictionary).get("last_day", -1))


## Days still owed on the cooldown, or 0. What the panel prints next to "waiting on".
static func cooldown_left(card_latch: Dictionary, key: String) -> int:
	var cd: int = _cooldown_of(card_latch)
	if cd <= 0 or fires(key) == 0:
		return 0
	return maxi(0, cd - (GameState.day - last_day(key)))


## Forget one latch. DEBUG AND SMOKE ONLY — there is no gameplay reason to un-spend a
## one_shot, and the falsification half of a one-shot case is the reason this exists: a case
## that only ever observes silence passes just as happily against a beat that never fires.
static func clear_one(key: String) -> void:
	_state.erase(key)


static func all_keys() -> Array:
	var keys: Array = _state.keys()
	keys.sort()
	return keys


# --- Lifecycle -------------------------------------------------------------

static func reset() -> void:
	_state.clear()


static func to_dict() -> Dictionary:
	return {"latches": _state.duplicate(true)}


static func from_dict(d: Dictionary) -> void:
	reset()
	for k in (d.get("latches", {}) as Dictionary):
		_state[k] = (d["latches"] as Dictionary)[k]
