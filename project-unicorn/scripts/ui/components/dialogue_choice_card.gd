class_name DialogueChoiceCard
extends PanelContainer

# Shared cinematic-register choice card (Spec 5) — the dark-register counterpart to the
# light UiFactory.make_choice_card. Renders a number chip + choice text + optional odds
# line + optional caption (danger-tinted) + optional "marked" marker; hovers with an amber
# edge; supports a muted, non-interactive disabled state.
#
# Ledger 11: NEVER grabs focus. It reacts only to a left mouse click (or the consumer
# routing a number-key press via select()). A disabled row is visible but inert
# (mouse ignored, focus none) — the no-fake-choices pillar.

signal selected(id: String)

@onready var _number: Label = $Row/NumberChip/Number
@onready var _text: Label = $Row/TextCol/ChoiceText
@onready var _odds: Label = $Row/TextCol/Odds
@onready var _caption: Label = $Row/TextCol/Caption
@onready var _marked: Label = $Row/Marked

var _id: String = ""
var _disabled: bool = false


func _ready() -> void:
	gui_input.connect(_on_gui_input)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)


func setup(index: int, choice: Dictionary) -> void:
	_id = String(choice.get("id", ""))
	_disabled = bool(choice.get("disabled", false))
	_number.text = str(index + 1)
	_text.text = String(choice.get("text", "—"))

	var odds_text: String = String(choice.get("odds_text", ""))
	_odds.visible = odds_text != ""
	_odds.text = odds_text

	var caption: String = String(choice.get("caption", ""))
	_caption.visible = caption != ""
	_caption.text = caption
	# Danger captions read in the dark-surface warning tint; ordinary ones stay dim.
	var caption_col: Color = UiTokens.NEGATIVE_BRIGHT if bool(choice.get("caption_danger", false)) else UiTokens.CREAM_DIM
	_caption.add_theme_color_override("font_color", caption_col)

	_marked.visible = bool(choice.get("marked", false))
	if _marked.visible:
		_marked.text = String(choice.get("marked_text", "PROVA EDİLDİ"))

	if _disabled:
		modulate = Color(1, 1, 1, 0.5)          # muted (standard disabled alpha, not a hue)
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		focus_mode = Control.FOCUS_NONE


# Consumer-driven activation (e.g. matching number key). No-op when disabled.
func select() -> void:
	if not _disabled:
		selected.emit(_id)


func is_disabled() -> bool:
	return _disabled


func _on_gui_input(event: InputEvent) -> void:
	if _disabled:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		selected.emit(_id)


func _on_mouse_entered() -> void:
	if not _disabled:
		theme_type_variation = &"DialogueChoiceHover"


func _on_mouse_exited() -> void:
	if not _disabled:
		theme_type_variation = &"DialogueChoice"
