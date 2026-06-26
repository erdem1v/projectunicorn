class_name EventChoice
extends Resource

# EventChoice data model per TECH_SPEC §7.
# One option on a GameEvent. Plain data; the modifier list and unlock condition
# are interpreted by EventManager's dispatchers at runtime — no logic lives in
# the choice itself.
#
# Modifier shape (the type vocabulary lives in EventManager._apply_modifiers):
#   {"type": "cash", "delta": -8000}
#   {"type": "brand", "delta": +3}
#   {"type": "reputation", "delta": -2}
#   {"type": "mrr", "delta": -500}
#   {"type": "morale", "character_id": "char_debug_eng_a", "delta": +5}
#   {"type": "morale_all_employees", "delta": -3}
#
# Unlock condition mirrors a single trigger condition (see GameEvent comment
# above trigger_conditions). Empty Dictionary {} means the choice is unlocked.

# --- Used now ---
@export var label: String = ""
@export var modifiers: Array = []                  # Array of Dictionaries (loose-typed; dispatcher reads "type")
@export var unlock_condition: Dictionary = {}      # {} = unlocked; otherwise same shape as a trigger condition
@export var unlock_reason_text: String = ""        # Shown on locked choices, e.g. "Reputation 10+ gerekli"
