class_name GameEvent
extends Resource

# GameEvent data model per TECH_SPEC §7.
# Loaded from JSON in data/events/reactive/*.json at startup by EventManager.
# Plain data container — eligibility checks and outcome application live in
# EventManager's dispatchers, not on the event itself.
#
# Naming caution (TECH_SPEC §7): class is GameEvent, not Event — Godot
# reserves the name `Event` at engine level (input events). Field is `title`,
# not `name`, mirroring Character.character_name policy.
#
# Trigger condition shape (vocabulary lives in EventManager.is_condition_met):
#   {"type": "day_min", "value": 3}
#   {"type": "day_max", "value": 90}
#   {"type": "phase", "value": 1}
#   {"type": "cash_below", "value": 30000}     (also cash_above)
#   {"type": "brand_below", "value": 30}        (also brand_above)
#   {"type": "reputation_below", "value": 0}    (also reputation_above)
#   {"type": "subgenre", "value": "ai"}
#   {"type": "random", "chance": 0.30}
#
# All trigger_conditions must evaluate true (AND logic) for the event to be
# eligible. Cooldown and one_shot are NOT trigger conditions — they live as
# their own fields and are checked separately against EventManager._history.

# --- Identity (used now) ---
@export var id: String = ""                        # "ev_<num>_<slug>" per TECH_SPEC §12
@export var category: String = "reactive"          # "reactive" | "industry" | "scandal" | "opportunity"
@export var title: String = ""
@export var subtitle: String = ""                  # e.g. "Cihangir · 13:42"

# --- Presentation (used now) ---
@export var illustration_path: String = ""         # Placeholder this turn; future asset path
@export var character_id: String = ""              # Empty when no character context strip
@export var body_text: String = ""                 # **bold** *italic* via markdown→BBCode in modal

# --- Synthetic speaker context (B2B Sales System). When character_id is EMPTY but
#     speaker_name is set, the modal renders a non-Character speaker strip (a customer
#     speaking in their own voice) from these fields directly, no CharacterRegistry
#     lookup. Lets the retention modal show the account avatar + name + status. ---
@export var speaker_name: String = ""              # display name (e.g. a customer company)
@export var speaker_role: String = ""              # sub-line after the name (contact role)
@export var speaker_status: String = ""            # status pill text (e.g. "RİSK ALTINDA")
@export var speaker_status_kind: String = "neutral" # UiFactory badge kind for the pill
@export var speaker_chips: Array = []              # extra chips: Array of {text, kind}
@export var speaker_initial: String = ""           # avatar initials; "" → derived from speaker_name

# --- Behavior (used now) ---
@export var choices: Array[EventChoice] = []
@export var trigger_conditions: Array = []         # Array of Dictionaries
@export var cooldown_days: int = 0                 # 0 = no cooldown
@export var one_shot: bool = false                 # true = fires at most once per run
@export var priority: int = 0                      # Higher fires first when multiple eligible same day

# --- Categorization ---
# Used by EventManager._is_eligible() during active builds: events without a
# matching build_phase trigger condition are suppressed unless they carry the
# "build_safe" tag (e.g. the ship-moment cinematic, system narrators).
@export var tags: Array[String] = []


func has_tag(tag: String) -> bool:
	return tag in tags


func has_random_trigger() -> bool:
	# True when eligibility includes a random dice roll. Used by EventManager's
	# per-day rate-limit (Faz 1 bug 1.6): only the ambient random pool is throttled
	# to ≤1/tick; deterministic state-gated "beat" events (no random roll — e.g.
	# paid-tier, first-revenue, Frank intro, traction-ready) fire the moment their
	# condition holds, never delayed in the one-per-day queue.
	for cond in trigger_conditions:
		if typeof(cond) == TYPE_DICTIONARY and String(cond.get("type", "")) == "random":
			return true
	return false
