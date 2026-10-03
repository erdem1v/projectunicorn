extends Control

# A PanelLayer panel of the Ekip window (Atlas, Eğitim, Mesai): a window with no scrim, seated at the
# area's top over the window that opened it, which dims under it and gives up its amber
# (WindowLayer.set_under). Its head holds the title and the close, its body scrolls when the area is
# short, its foot holds the actions. The screen around it takes no clicks; Esc closes it.
# process_mode ALWAYS: the clock may be stopped while it is open.

signal state_changed

## The head's title row (the close follows it), the body and the foot the panel fills.
var title: HBoxContainer
var body: VBoxContainer
var foot: HBoxContainer
var _box: PanelContainer
var _scroll: ScrollContainer
var _pad: MarginContainer
var _width := 0.0
var _cover := false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	_box = PanelContainer.new()
	_box.theme_type_variation = &"DialogPanel"
	add_child(_box)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 0)
	_box.add_child(col)
	var head := PanelContainer.new()
	head.theme_type_variation = &"WinHead"
	head.custom_minimum_size.y = UiTokens.D_H_WIN_HEAD
	col.add_child(head)
	var head_row := HBoxContainer.new()
	head_row.add_theme_constant_override("separation", UiTokens.SPACE_L)
	head.add_child(head_row)
	title = HBoxContainer.new()
	title.add_theme_constant_override("separation", UiTokens.SPACE_XL)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head_row.add_child(title)
	var shut := UiFactory.make_close_button(close, true)
	shut.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	head_row.add_child(shut)
	_scroll = ScrollContainer.new()
	_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	col.add_child(_scroll)
	_pad = MarginContainer.new()
	_pad.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	for side in ["left", "right", "bottom"]:
		_pad.add_theme_constant_override("margin_" + side, UiTokens.SPACE_3XL)
	_pad.add_theme_constant_override("margin_top", UiTokens.SPACE_XL)
	_scroll.add_child(_pad)
	body = VBoxContainer.new()
	body.add_theme_constant_override("separation", 0)
	_pad.add_child(body)
	# Wrapped text knows its height only once it has its width: the panel reseats when it settles.
	_pad.minimum_size_changed.connect(_seat)
	var base := PanelContainer.new()
	base.theme_type_variation = &"PanelFoot"
	col.add_child(base)
	foot = HBoxContainer.new()
	foot.add_theme_constant_override("separation", UiTokens.SPACE_L)
	base.add_child(foot)
	get_tree().call_group(&"window_layer", &"set_under", true)


func _exit_tree() -> void:
	get_tree().call_group(&"window_layer", &"set_under", false)


## Seats the panel `width` wide, as tall as its content (WindowLayer.panel_rect), once its content is
## built. With `cover` it is at least as tall as the window it covers.
func seat(width: float, cover := false) -> void:
	_width = width
	_cover = cover
	_seat()


func _seat() -> void:
	if _width == 0.0:   # the content settled before the panel was first seated
		return
	var tall: float = _box.get_combined_minimum_size().y - _scroll.get_combined_minimum_size().y \
		+ _pad.get_combined_minimum_size().y
	var rect: Rect2 = get_tree().get_first_node_in_group(&"window_layer").panel_rect(Vector2(_width, tall), _cover)
	_box.position = rect.position
	_box.size = rect.size


## Empties the body and the foot for a rebuild.
func clear() -> void:
	UiFactory.clear(body)
	UiFactory.clear(foot)


## A foot button in `look` (empty for the plain one); without `on_press` it is the closed action.
func button(text: String, look: StringName, on_press: Callable) -> Button:
	var btn := Button.new()
	btn.theme_type_variation = look
	btn.text = text
	btn.focus_mode = Control.FOCUS_NONE
	btn.disabled = not on_press.is_valid()
	if on_press.is_valid():
		btn.pressed.connect(on_press)
	return btn


## A spring in a row: what follows it sits at the row's right end.
func spring() -> Control:
	var gap := Control.new()
	gap.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return gap


## `child`, `above` px below what precedes it.
func spaced(child: Control, above: int) -> MarginContainer:
	var pad := MarginContainer.new()
	pad.add_theme_constant_override("margin_top", above)
	pad.add_child(child)
	return pad


func close() -> void:
	queue_free()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		close()
