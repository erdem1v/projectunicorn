class_name EventChoice
extends Resource

# One option on a GameEvent view. Plain data: `modifiers` are the card option's effects (the
# modal's chip builder describes them; the engine applies them), `unlock_condition` is its
# `requires` tree, re-checked by the modal at render time. {} = unlocked.

@export var label: String = ""
@export var description: String = ""               # optional italic sub-line; "" = absent
@export var modifiers: Array = []
@export var unlock_condition: Dictionary = {}
@export var unlock_reason_text: String = ""        # shown on a locked choice

# English siblings, resolved at render time through Localization.pick; empty = TR fallback.
@export var label_en: String = ""
@export var description_en: String = ""
@export var unlock_reason_text_en: String = ""
