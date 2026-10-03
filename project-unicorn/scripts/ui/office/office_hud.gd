extends Control

# The office view's own controls: the move button at the bottom left (windows dock at the top
# left) and the countdown of a move under way beside it. The shell's toast says when a move starts
# and when it lands. OfficeCity mounts this on the view's overlay and opens the city map on
# move_pressed. While a decision waits the button is off and says so: no move, no map.

signal move_pressed

## After Frank's cheque the button breathes until the company sets off on its first move.
const PULSE_SCALE := 1.04     # [WORKING]
const PULSE_ALPHA := 0.8      # [WORKING]
const PULSE_TIME := 0.9       # [WORKING] seconds each way
const MOVE_GLYPH := preload("res://assets/icons/util/move.svg")

var _row := HBoxContainer.new()
var _button := PanelContainer.new()
var _label: Label
var _badge: Control
var _waiting: Label
var _pulse: Tween
var _map_open := false
var _window_cover := Rect2()


func _ready() -> void:
	add_to_group(&"office_overlays")
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_row.add_theme_constant_override("separation", UiTokens.SPACE_M)
	add_child(_row)

	_button.theme_type_variation = &"ChoiceCard"
	_button.mouse_filter = Control.MOUSE_FILTER_STOP
	_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	# Hover = edge; both variations share fill and margins, so the button does not jump.
	_button.mouse_entered.connect(func() -> void: _button.theme_type_variation = &"ChoiceCardHover")
	_button.mouse_exited.connect(func() -> void: _button.theme_type_variation = &"ChoiceCard")
	_button.gui_input.connect(func(event: InputEvent) -> void:
		if UiFactory.is_left_click(event) and EventGate.active_id() == "":
			move_pressed.emit())
	_button.resized.connect(func() -> void: _button.pivot_offset = _button.size * 0.5)
	_row.resized.connect(_show_row)
	_row.add_child(_button)
	var inner := HBoxContainer.new()
	inner.add_theme_constant_override("separation", UiTokens.SPACE_M)
	_button.add_child(inner)
	var glyph := Panel.new()
	glyph.theme_type_variation = &"TabBadge"
	glyph.custom_minimum_size = Vector2.ONE * UiTokens.SPACE_M
	glyph.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	inner.add_child(glyph)
	_label = UiFactory.make_label("", &"RowName")
	inner.add_child(_label)
	_waiting = UiFactory.make_label("", &"CaptionMuted")
	_waiting.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	inner.add_child(_waiting)
	HRUiShared.set_mouse_ignore(inner)

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
	_label.text = tr("OFFICE_MOVE_BTN")
	var gated: bool = EventGate.active_id() != ""
	_waiting.text = tr("TOPBAR_GATE")
	_waiting.visible = gated
	_button.mouse_default_cursor_shape = Control.CURSOR_ARROW if gated else Control.CURSOR_POINTING_HAND
	if _badge != null:
		_badge.free()
		_badge = null
	if OfficeSystem.is_moving():
		var weeks := OfficeSystem.arrival_day() - GameState.day
		_badge = UiFactory.make_pill(tr(Fmt.count_key("OFFICE_MOVING_BADGE", weeks)).format({"weeks": weeks}),
			UiTokens.BADGE_BG, UiTokens.BADGE_FG, false)
		_row.add_child(_badge)
	_row.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT, Control.PRESET_MODE_MINSIZE, UiTokens.SPACE_3XL)
	var breathe := GameState.run_angel_amount > 0 and OfficeSystem.current() == "home" and not OfficeSystem.is_moving()
	if breathe == (_pulse != null):
		return
	if not breathe:
		_pulse.kill()
		_pulse = null
		_button.scale = Vector2.ONE
		_button.modulate.a = 1.0
		return
	_pulse = create_tween().set_loops().set_trans(Tween.TRANS_SINE)
	_pulse.tween_property(_button, "scale", Vector2.ONE * PULSE_SCALE, PULSE_TIME)
	_pulse.parallel().tween_property(_button, "modulate:a", PULSE_ALPHA, PULSE_TIME)
	_pulse.tween_property(_button, "scale", Vector2.ONE, PULSE_TIME)
	_pulse.parallel().tween_property(_button, "modulate:a", 1.0, PULSE_TIME)


func _on_move_started(office_id: String, _arrival_day: int) -> void:
	_toast(office_id, "OFFICE_TOAST_MOVE_STARTED")
	_refresh()


## What happened to the move, and where to.
func _toast(office_id: String, head_key: String) -> void:
	get_tree().call_group(&"toast", &"show_toast", tr(head_key),
		tr(OfficeConstants.CATALOG[office_id].name_key), MOVE_GLYPH, UiTokens.D_INK_3)
