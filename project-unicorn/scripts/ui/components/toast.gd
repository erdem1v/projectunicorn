extends PanelContainer

# The one toast of the Menajer Masası: a glyph in its well, a bold head and a quieter line. It eases
# in, holds and fades; a new toast takes the place of the one showing. The shell's toast floats
# centred right of the rail, 24 px above the ticker, on its own layer over the windows and modals
# (GameShell/ToastLayer); anything in the shell reaches it through the group. The ending's sits in
# its rail with an action and waits while the pointer is on it.
# Preloaded by path: no global class cache dependency (headless trap).

const GROUP := &"toast"
const IN_S := 0.2
const HOLD_S := 2.4
const OUT_S := 0.2
const RISE := 8.0

## The rail spans the band between the top bar and the ticker: the floating toast centres right of
## it and sits above its bottom edge. A toast in a container has none.
@export var rail: Control

var _glyph := TextureRect.new()
var _head := UiFactory.make_label("", &"DataStrong")
var _sub := UiFactory.make_label("", &"NoteMuted")
var _row := HBoxContainer.new()
var _tween: Tween


func _init() -> void:
	theme = load(UiTokens.MENAJER_THEME)
	theme_type_variation = &"Toast"
	custom_minimum_size.y = UiTokens.D_H_TOAST
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_row.add_theme_constant_override("separation", UiTokens.SPACE_L)
	add_child(_row)
	var well := Panel.new()
	well.theme_type_variation = &"IconWell"
	well.custom_minimum_size = Vector2.ONE * UiTokens.D_TOAST_WELL
	well.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_row.add_child(well)
	_glyph.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_glyph.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_glyph.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_MINSIZE,
		(UiTokens.D_TOAST_WELL - UiTokens.D_ICON_TOAST) / 2)
	well.add_child(_glyph)
	_row.add_child(_head)
	_row.add_child(_sub)
	for label in [_head, _sub]:
		label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	hide()


func _ready() -> void:
	if rail != null:
		add_to_group(GROUP)


## The ending's toast carries an action: its line yields room to the button and shortens, and the toast
## waits while the pointer is on it. The button passes the pointer on, so it counts as on the toast.
func set_action(text: String, on_press: Callable) -> void:
	mouse_filter = Control.MOUSE_FILTER_PASS
	mouse_entered.connect(func() -> void: _tween.set_speed_scale(0.0))
	mouse_exited.connect(func() -> void: _tween.set_speed_scale(1.0))
	_sub.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_sub.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	var action := Button.new()
	action.theme_type_variation = &"GhostButtonSmall"
	action.focus_mode = Control.FOCUS_NONE
	action.mouse_filter = Control.MOUSE_FILTER_PASS
	action.text = text
	action.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	action.pressed.connect(on_press)
	_row.add_child(action)


## `tone` is the glyph's ink: gain for a save or a load, attention for a refusal, ink-3 otherwise.
func show_toast(head: String, sub: String, glyph: Texture2D, tone: Color) -> void:
	_head.text = head
	_sub.text = sub
	_glyph.texture = glyph
	_glyph.modulate = tone
	modulate.a = 0.0
	show()
	if _tween != null:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(self, "modulate:a", 1.0, IN_S)
	if rail != null:
		reset_size()
		var band: Rect2 = rail.get_rect()
		position = Vector2(band.end.x + (get_viewport_rect().size.x - band.end.x - size.x) * 0.5,
			band.end.y - UiTokens.SPACE_3XL - size.y + RISE)
		_tween.parallel().tween_property(self, "position:y", position.y - RISE, IN_S)
	_tween.tween_interval(HOLD_S)
	_tween.tween_property(self, "modulate:a", 0.0, OUT_S)
	_tween.tween_callback(hide)
