extends OnboardingStep

# Step 4 — Subgenre Select per PROJECT_SPEC §4.4.
# Demo scope: AI and SaaS are selectable; Social is Coming Soon disabled.
# Same card-grid recipe as OriginStep — see origin_step.gd for the
# rationale on mouse_filter + focus_mode + modulate.

const SUBGENRE_AI := "ai"
const SUBGENRE_SAAS := "saas"

var _selected_id: String = ""

@onready var ai_card: Panel = $Row/AICard
@onready var saas_card: Panel = $Row/SaaSCard
@onready var social_card: Panel = $Row/SocialCard
@onready var ai_selected: Panel = $Row/AICard/SelectedBorder
@onready var saas_selected: Panel = $Row/SaaSCard/SelectedBorder


func _ready() -> void:
	_apply_disabled_recipe(social_card)
	ai_card.gui_input.connect(_on_ai_input)
	saas_card.gui_input.connect(_on_saas_input)
	_refresh_visual()


func _apply_disabled_recipe(card: Panel) -> void:
	card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.focus_mode = Control.FOCUS_NONE
	card.modulate = Color(1, 1, 1, 0.45)


func _on_ai_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_selected_id = SUBGENRE_AI
		_refresh_visual()
		validity_changed.emit(is_valid())


func _on_saas_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_selected_id = SUBGENRE_SAAS
		_refresh_visual()
		validity_changed.emit(is_valid())


func _refresh_visual() -> void:
	ai_selected.visible = (_selected_id == SUBGENRE_AI)
	saas_selected.visible = (_selected_id == SUBGENRE_SAAS)


# --- OnboardingStep contract ---

func prefill(draft: Dictionary) -> void:
	_selected_id = draft.get("subgenre_id", "")
	if is_node_ready():
		_refresh_visual()
		validity_changed.emit(is_valid())


func is_valid() -> bool:
	return _selected_id == SUBGENRE_AI or _selected_id == SUBGENRE_SAAS


func collect_payload() -> Dictionary:
	return {"subgenre_id": _selected_id}
