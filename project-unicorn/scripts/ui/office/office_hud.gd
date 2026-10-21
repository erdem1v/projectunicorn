extends Control

# The office view's own controls: the move button at the bottom left (windows dock at the top
# left) and the countdown of a move under way beside it. The shell's toast says when a move starts
# and when it lands. OfficeCity mounts this on the view's overlay and opens the city map on
# move_pressed. While a decision waits the button is off and says so: no move, no map.
# In the dark language from its root.

signal move_pressed

## Once the seed round is signed the button breathes until the company sets off on its first move.
const PULSE_SCALE := 1.04     # [WORKING]
const PULSE_ALPHA := 0.8      # [WORKING]
const PULSE_TIME := 0.9       # [WORKING] seconds each way
const MOVE_GLYPH := preload("res://assets/icons/util/move.svg")
const GLOBE_GLYPH := preload("res://assets/icons/util/globe.svg")

var _row := HBoxContainer.new()
var _plate := PanelContainer.new()
var _button := Button.new()
var _waiting: Label
var _badge: Control
var _pulse: Tween
var _map_open := false
var _window_cover := Rect2()


func _ready() -> void:
	theme = load(UiTokens.MENAJER_THEME)
	add_to_group(&"office_overlays")
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_row.add_theme_constant_override("separation", UiTokens.SPACE_M)
	add_child(_row)

	# WinClose is the theme's glyph-in-a-40 px-key; the dark plate keeps it readable on the bright scene.
	_plate.theme_type_variation = &"FloatPanel"
	_plate.resized.connect(func() -> void: _plate.pivot_offset = _plate.size * 0.5)
	_row.resized.connect(_show_row)
	_row.add_child(_plate)
	_button.theme_type_variation = &"WinClose"
	_button.icon = GLOBE_GLYPH
	_button.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_button.custom_minimum_size = Vector2.ONE * UiTokens.D_H_BTN
	_button.focus_mode = Control.FOCUS_NONE   # Space is the speed key; focus must not swallow it
	_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_button.pressed.connect(move_pressed.emit)
	_plate.add_child(_button)
	_waiting = UiFactory.make_label("", &"CaptionMuted")
	_waiting.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_row.add_child(_waiting)

	for s: Signal in [EventBus.day_advanced, EventBus.office_changed, EventBus.equity_changed,
			EventBus.language_changed]:
		s.connect(_refresh.unbind(1))
	EventBus.event_triggered.connect(_refresh.unbind(1))
	EventBus.event_set_aside.connect(_refresh.unbind(1))
	EventBus.event_resolved.connect(_refresh.unbind(2))
	EventBus.office_move_started.connect(_on_move_started)
	EventBus.office_changed.connect(_toast.bind("OFFICE_TOAST_MOVED"))
	_refresh()


## The map's own panel takes the button's corner while it is open, and the founder's trip
## shows no controls (OfficeView says which); the toast stays.
func set_map_open(open: bool) -> void:
	_map_open = open
	_show_row()


## WindowLayer says where the open windows lie each time it places them; the button steps
## aside under one.
func set_window_cover(cover: Rect2) -> void:
	_window_cover = cover
	_show_row()


func _show_row() -> void:
	_row.visible = not _map_open and not _window_cover.intersects(_row.get_global_rect())


func _refresh() -> void:
	var gated: bool = EventGate.active_id() != ""
	_button.tooltip_text = tr("OFFICE_MOVE_BTN")
	_button.disabled = gated
	_waiting.text = tr("TOPBAR_GATE")
	_waiting.visible = gated
	if _badge != null:
		_badge.free()
		_badge = null
	if OfficeSystem.is_moving():
		var weeks := OfficeSystem.arrival_day() - GameState.day
		_badge = UiFactory.make_pill(tr(Fmt.count_key("OFFICE_MOVING_BADGE", weeks)).format({"weeks": weeks}),
			UiTokens.BADGE_BG, UiTokens.BADGE_FG, false)
		_row.add_child(_badge)
	_row.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT, Control.PRESET_MODE_MINSIZE, UiTokens.SPACE_3XL)
	var breathe := GameState.run_seed_amount > 0 and OfficeSystem.current() == "home" and not OfficeSystem.is_moving()
	if breathe == (_pulse != null):
		return
	if not breathe:
		_pulse.kill()
		_pulse = null
		_plate.scale = Vector2.ONE
		_plate.modulate.a = 1.0
		return
	_pulse = create_tween().set_loops().set_trans(Tween.TRANS_SINE)
	_pulse.tween_property(_plate, "scale", Vector2.ONE * PULSE_SCALE, PULSE_TIME)
	_pulse.parallel().tween_property(_plate, "modulate:a", PULSE_ALPHA, PULSE_TIME)
	_pulse.tween_property(_plate, "scale", Vector2.ONE, PULSE_TIME)
	_pulse.parallel().tween_property(_plate, "modulate:a", 1.0, PULSE_TIME)


func _on_move_started(office_id: String, _arrival_day: int) -> void:
	_toast(office_id, "OFFICE_TOAST_MOVE_STARTED")
	_refresh()


## What happened to the move, and where to.
func _toast(office_id: String, head_key: String) -> void:
	get_tree().call_group(&"toast", &"show_toast", tr(head_key),
		tr(OfficeConstants.CATALOG[office_id].name_key), MOVE_GLYPH, UiTokens.D_INK_3)
