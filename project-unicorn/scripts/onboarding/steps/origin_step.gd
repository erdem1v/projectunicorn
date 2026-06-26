extends OnboardingStep

# Step 1 — Origin Select per PROJECT_SPEC §4.1.
# Demo scope: only Self-Made Founder is selectable. Heir + Corporate Refugee
# render as Coming Soon disabled cards (visible content, no interaction).
# Disabled-card recipe: mouse_filter=IGNORE + focus_mode=NONE + modulate.

const ORIGIN_SELF_MADE := "self_made"

var _selected_id: String = ""

@onready var self_made_card: Panel = $Row/SelfMadeCard
@onready var heir_card: Panel = $Row/HeirCard
@onready var corp_card: Panel = $Row/CorpCard
@onready var self_made_selected: Panel = $Row/SelfMadeCard/SelectedBorder


func _ready() -> void:
	_apply_disabled_recipe(heir_card)
	_apply_disabled_recipe(corp_card)
	self_made_card.gui_input.connect(_on_self_made_input)
	_refresh_visual()


func _apply_disabled_recipe(card: Panel) -> void:
	# Three-part Godot recipe for "visible but not interactive":
	#   - mouse_filter=IGNORE: clicks/hovers pass through (no gui_input fires)
	#   - focus_mode=NONE: tab key can't focus it
	#   - modulate alpha: cascades to children for the muted look
	# Button.disabled was rejected — it forces Godot's generic disabled
	# stylebox which looks like a UI bug, not a deliberate "coming soon".
	card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.focus_mode = Control.FOCUS_NONE
	card.modulate = Color(1, 1, 1, 0.45)


func _on_self_made_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_selected_id = ORIGIN_SELF_MADE
		_refresh_visual()
		validity_changed.emit(is_valid())


func _refresh_visual() -> void:
	self_made_selected.visible = (_selected_id == ORIGIN_SELF_MADE)


# --- OnboardingStep contract ---

func prefill(draft: Dictionary) -> void:
	_selected_id = draft.get("origin_id", "")
	if is_node_ready():
		_refresh_visual()
		validity_changed.emit(is_valid())


func is_valid() -> bool:
	return _selected_id == ORIGIN_SELF_MADE


func collect_payload() -> Dictionary:
	return {"origin_id": _selected_id}
