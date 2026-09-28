class_name EvLatches
extends RefCounted

# REPEAT BRAKES, OWNED BY THE ENGINE (GDD §3.1, §4.1 G3). The card declares its latch as data,
# so a brake is the difference between "the author remembered" and "the author cannot forget".
#
# TWO KEYS (§3.1 latch_key).
#
#   run     one latch for the card, whatever it is about. A phase gate fires once per run.
#   entity  one latch PER SUBJECT. Two employees may each ask for a raise in the same week
#           (§20 A6); a run-key latch would swallow the second person's card.
#
# G3 IS NOT RE-RUN AT DISPLAY (§4.4). A card admitted last tick has already spent its cooldown.

const ONE_SHOT := "one_shot"
const MAX_FIRES := "max_fires"
const COOLDOWN := "cooldown_weeks"

## §3.1: a card that declares nothing gets this cooldown, not free repetition. The default
## is deliberately conservative — an author who wants a card back sooner says so.
const DEFAULT_COOLDOWN_WEEKS := 4

const KEY_RUN := "run"
const KEY_ENTITY := "entity"

## latch key string -> {fires: int, last_day: int (tick)}
static var _state: Dictionary = {}


# --- The key ---------------------------------------------------------------

## "event_id" for a run latch, "event_id@entity_id" for an entity latch. The subject id comes
## from the card's PRIMARY scope slot, which is why the gate resolves scope before G3 for an
## entity-keyed card.
static func key_for(event_id: String, latch_key: String, subject_id: String) -> String:
	if latch_key == KEY_ENTITY and subject_id != "":
		return "%s@%s" % [event_id, subject_id]
	return event_id


## The key of a card bound to `context`. It is also the card's IDENTITY wherever the engine holds
## an instance (queue, desk, the day's admissions): two subjects of an entity-keyed card are two
## instances (§20 A6), and the same card about the same subject is one (§20 E2, B9).
static func key_of(event_id: String, context: Dictionary) -> String:
	return key_for(event_id, String(EvCatalog.card(event_id).get("latch_key", KEY_RUN)),
		EvGate.subject_of(context))


## key_of for a queue entry or an admission, {event_id, context, ...}.
static func key_of_entry(entry: Dictionary) -> String:
	return key_of(String(entry["event_id"]), entry["context"])


# --- The gate's question ---------------------------------------------------

## Blocking reason, or "" when the card may pass. A string because the "why didn't this fire"
## panel prints it.
static func blocked_reason(card_latch: Dictionary, key: String) -> String:
	var fired: int = fires(key)
	var last: int = last_day(key)

	if bool(card_latch.get(ONE_SHOT, false)):
		return "one_shot: already fired on tick %d" % last if fired > 0 else ""

	if card_latch.has(MAX_FIRES):
		var cap: int = int(card_latch[MAX_FIRES])
		if fired >= cap:
			return "max_fires: %d of %d used" % [fired, cap]

	var cd: int = _cooldown_of(card_latch)
	if cd > 0 and fired > 0:
		var since: int = GameState.day - last
		if since < cd:
			return "cooldown: %d of %d weeks" % [since, cd]

	return ""


## §3.1 writes the latch as `one_shot | max_fires:N | cooldown_weeks:N` — alternatives, not a
## stack. The default applies only to a card that declares NO brake; how soon a card may
## return is min_gap_weeks' job (§13.3 layer 1). Returned in ticks.
static func _cooldown_of(card_latch: Dictionary) -> int:
	if card_latch.has(COOLDOWN):
		return TimeModel.ticks(int(card_latch[COOLDOWN]))
	if card_latch.has(MAX_FIRES) or bool(card_latch.get(ONE_SHOT, false)):
		return 0
	return TimeModel.ticks(DEFAULT_COOLDOWN_WEEKS)


# --- Spending --------------------------------------------------------------

## Spend the latch. Called at ADMISSION, not at resolution, so a queued card is not re-proposed
## every tick while it waits.
static func spend(key: String) -> void:
	_state[key] = {"fires": fires(key) + 1, "last_day": GameState.day}


# --- Introspection (the debug panel) ---------------------------------------

static func fires(key: String) -> int:
	return int((_state.get(key, {}) as Dictionary).get("fires", 0))


static func last_day(key: String) -> int:
	return int((_state.get(key, {}) as Dictionary).get("last_day", -1))


## Weeks still owed on the cooldown, or 0. What the panel prints next to "waiting on".
static func cooldown_left(card_latch: Dictionary, key: String) -> int:
	var cd: int = _cooldown_of(card_latch)
	if cd <= 0 or fires(key) == 0:
		return 0
	return maxi(0, cd - (GameState.day - last_day(key)))


## Forget one latch. DEBUG AND SMOKE ONLY — a one-shot case's falsification half needs the beat
## to be able to fire again.
static func clear_one(key: String) -> void:
	_state.erase(key)


# --- Lifecycle -------------------------------------------------------------

static func reset() -> void:
	_state.clear()


static func to_dict() -> Dictionary:
	return {"latches": _state.duplicate(true)}


static func from_dict(d: Dictionary) -> void:
	reset()
	_state = (d.get("latches", {}) as Dictionary).duplicate(true)
