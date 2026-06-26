extends OnboardingStep

# Step 3 — Trait Select per PROJECT_SPEC §4.2.
# Exactly one positive + one negative trait, both mandatory.
#
# Placeholder trait pool — real ~12+12 catalog with mechanic effects is a
# Content Phase task. All cards marked [DEBUG/TODO] so future agents know
# the names are unblessed.

const POSITIVE_IDS := ["charismatic", "pragmatic", "tech_visionary", "resilient"]
const NEGATIVE_IDS := ["imposter_syndrome", "conflict_avoidant", "burnt_out", "stubborn"]

var _positive_id: String = ""
var _negative_id: String = ""

@onready var positive_cards: Dictionary = {
	"charismatic": $Cols/Positive/Cards/Charismatic,
	"pragmatic": $Cols/Positive/Cards/Pragmatic,
	"tech_visionary": $Cols/Positive/Cards/TechVisionary,
	"resilient": $Cols/Positive/Cards/Resilient,
}
@onready var negative_cards: Dictionary = {
	"imposter_syndrome": $Cols/Negative/Cards/ImposterSyndrome,
	"conflict_avoidant": $Cols/Negative/Cards/ConflictAvoidant,
	"burnt_out": $Cols/Negative/Cards/BurntOut,
	"stubborn": $Cols/Negative/Cards/Stubborn,
}


func _ready() -> void:
	for trait_id in POSITIVE_IDS:
		var card: Panel = positive_cards[trait_id]
		card.gui_input.connect(_on_positive_input.bind(trait_id))
	for trait_id in NEGATIVE_IDS:
		var card: Panel = negative_cards[trait_id]
		card.gui_input.connect(_on_negative_input.bind(trait_id))
	_refresh_visual()


func _on_positive_input(event: InputEvent, trait_id: String) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_positive_id = trait_id
		_refresh_visual()
		validity_changed.emit(is_valid())


func _on_negative_input(event: InputEvent, trait_id: String) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_negative_id = trait_id
		_refresh_visual()
		validity_changed.emit(is_valid())


func _refresh_visual() -> void:
	for trait_id in POSITIVE_IDS:
		var card: Panel = positive_cards[trait_id]
		card.get_node("SelectedBorder").visible = (trait_id == _positive_id)
	for trait_id in NEGATIVE_IDS:
		var card: Panel = negative_cards[trait_id]
		card.get_node("SelectedBorder").visible = (trait_id == _negative_id)


# --- OnboardingStep contract ---

func prefill(draft: Dictionary) -> void:
	_positive_id = draft.get("trait_positive_id", "")
	_negative_id = draft.get("trait_negative_id", "")
	if is_node_ready():
		_refresh_visual()
		validity_changed.emit(is_valid())


func is_valid() -> bool:
	return _positive_id != "" and _negative_id != ""


func collect_payload() -> Dictionary:
	return {
		"trait_positive_id": _positive_id,
		"trait_negative_id": _negative_id,
	}
