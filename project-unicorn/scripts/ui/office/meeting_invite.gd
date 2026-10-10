class_name MeetingInvite
extends Control

# The call that opens an outside meeting: the phone rings over the founder's head in the office, an amber
# ring round it (the time state), and the camera closes on them; a click on the ring opens the call's card
# beside it (the hour, who calls, their line, Accept and Postpone, and a note on what putting it off
# costs), or the card is open from the first ring. While the card is shut the ring glows. Postponing shuts
# the card and the shell's toast says so; main.gd rings it (a fund whose meeting week has come, a prospect
# the player asked to meet), decides what a postponement does, and stops it once the call is gone. With the
# founder out of sight (the map, the meeting room, a trip) nothing shows and the call waits; while a
# decision waits the call is not taken. The notice stack steps aside for the card. In the dark language
# from its root.

signal accepted
signal postponed

## The card stands right of the ring, its head this far above the ring's centre, clear of the notice stack.
const CARD_RISE := 88.0
const POSTPONE_GLYPH := preload("res://assets/icons/util/calendar.svg")
## The camera closes on the founder as the phone starts: aimed this high above their feet, this
## much closer than the office's fit, over this long.
const FOCUS_RISE := 0.9
const FOCUS_ZOOM := 1.75
const FOCUS_S := 2.2

var _view: Control
var _people: OfficePeople
var _stack: Control   # the notice stack, under the card
var _ring := Control.new()
var _card := PanelContainer.new()
var _kicker: Label
var _who := HBoxContainer.new()
var _title: Label
var _line: Label
var _accept_button: Button
var _postpone_button: Button
var _note: VBoxContainer
var _note_text: Label
## The call as rung (ring()): its caller, its line, the note's and the toast line's keys and their
## arguments, translated when shown.
var _spec := {}


func _init(view: Control, people: OfficePeople, stack: Control) -> void:
	_view = view
	_people = people
	_stack = stack
	theme = load(UiTokens.MENAJER_THEME)
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_ring.custom_minimum_size = Vector2.ONE * UiTokens.D_CALL_RING
	_ring.size = _ring.custom_minimum_size
	_ring.draw.connect(_draw_ring)
	_ring.gui_input.connect(func(event: InputEvent) -> void:
		if UiFactory.is_left_click(event) and EventGate.active_id() == "":
			_open_card())
	add_child(_ring)
	_card.theme_type_variation = &"CallDoc"
	_card.custom_minimum_size.x = UiTokens.D_W_CALL
	var col := SprintUiShared.column(UiTokens.SPACE_L)
	_card.add_child(col)
	_kicker = UiFactory.make_label("", &"KeyText", UiTokens.D_ACCENT)
	col.add_child(_kicker)
	_who.add_theme_constant_override("separation", UiTokens.SPACE_L)
	col.add_child(_who)
	_line = SprintUiShared.prose("", &"BodyLabel")
	_line.add_theme_color_override("font_color", UiTokens.D_INK_1)
	col.add_child(_line)
	var keys := SprintUiShared.box(UiTokens.SPACE_M)
	# FOCUS_NONE (SprintUiShared.button): Space is the pause key, not a press of the focused button.
	_accept_button = SprintUiShared.button("", &"PrimaryButtonDarkSmall", _accept)
	_accept_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	keys.add_child(_accept_button)
	_postpone_button = SprintUiShared.button("", &"SecondaryButtonSmall", _postpone)
	keys.add_child(_postpone_button)
	col.add_child(SprintUiShared.pad(keys, Vector4i(0, UiTokens.SPACE_XS, 0, 0)))
	_note = SprintUiShared.column(UiTokens.SPACE_L)
	_note.add_child(HRUiShared.hairline(UiTokens.D_LINE_1))
	_note_text = SprintUiShared.prose("", &"Caption")
	_note.add_child(_note_text)
	col.add_child(_note)
	add_child(_card)
	EventBus.language_changed.connect(_retranslate.unbind(1))
	_retranslate()
	stop()


## Rings for a call, `spec`: `caller` (the one calling, as CounterpartSystem draws them), `vc_id` (their fund
## on a fund's call, "" otherwise), `line` (the caller's line, a key formatted with `args`), `open` (the card is
## open from the first ring), `postpone` (the call can be put off), `note` (a key under the buttons, formatted
## with `note_args`; "" for none) and `toast` (the key of the toast's line when it is put off).
func ring(spec: Dictionary) -> void:
	_spec = spec
	UiFactory.clear(_who)
	var caller: Dictionary = spec.caller
	_who.add_child(UiFactory.make_person_avatar(caller.name, caller.look, UiTokens.D_AVATAR_DOC))
	var words := SprintUiShared.column(0)
	words.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	words.add_child(UiFactory.make_label(caller.name, &"SubjectStrong"))
	_title = UiFactory.make_label("", &"Caption")
	words.add_child(_title)
	_who.add_child(words)
	_retranslate()
	_postpone_button.visible = spec.postpone
	_note.visible = spec.note != ""
	_ring.visible = true
	_card.visible = spec.open
	_people.founder_calling = true
	set_process(true)
	var founder := _people.founder()
	if founder != null and founder.visible:
		var cam: OfficeCamera = _view.camera
		cam.focus(founder.position + Vector3.UP * FOCUS_RISE, cam.fit_zoom * FOCUS_ZOOM, FOCUS_S)


func stop() -> void:
	_ring.visible = false
	_card.visible = false
	_stack.set_call_cover(Rect2())
	_people.founder_calling = false
	set_process(false)


func is_ringing() -> bool:
	return _ring.visible


## The phone can show now: the founder is in the office, in sight.
func can_ring() -> bool:
	var founder := _people.founder()
	return founder != null and founder.visible and not _people.founder_away


func _process(_delta: float) -> void:
	visible = can_ring()
	_stack.set_call_cover(_card.get_global_rect() if visible and _card.visible else Rect2())
	if not visible:
		return
	var gated: bool = EventGate.active_id() != ""
	_accept_button.disabled = gated
	_ring.mouse_default_cursor_shape = Control.CURSOR_ARROW if gated else Control.CURSOR_POINTING_HAND
	var at: Vector2 = (_view.camera as Camera3D).unproject_position(_people.founder().marker())
	_ring.position = at - _ring.size * 0.5
	_ring.queue_redraw()
	if _card.visible:
		# The wrapped line is measured at the card's width only once laid out: the card fits it anew.
		_card.reset_size()
		var margin := Vector2.ONE * UiTokens.SPACE_M
		var spot := Vector2(at.x + UiTokens.D_CALL_RING * 0.5 + UiTokens.SPACE_M, at.y - CARD_RISE)
		_card.position = spot.clamp(margin, size - _card.size - margin)


## The ring round the head's phone: its 2 px line, and outside it the glow while the card is shut.
func _draw_ring() -> void:
	var c: Vector2 = _ring.size * 0.5
	var r: float = UiTokens.D_CALL_RING * 0.5
	if not _card.visible:
		_ring.draw_arc(c, r + UiTokens.BORDER_FOCUS + UiTokens.D_CALL_GLOW * 0.5, 0.0, TAU, 64, UiTokens.D_ACCENT_GLOW,
			UiTokens.D_CALL_GLOW, true)
	_ring.draw_arc(c, r + UiTokens.BORDER_FOCUS * 0.5, 0.0, TAU, 64, UiTokens.D_ACCENT, UiTokens.BORDER_FOCUS, true)


func _retranslate() -> void:
	_kicker.text = tr("MEETING_INVITE_KICKER").format({"hour": "%02d" % GameState.current_hour})
	_accept_button.text = tr("MEETING_ACCEPT")
	_postpone_button.text = tr("MEETING_POSTPONE")
	if _spec.is_empty():
		return
	_title.text = CounterpartSystem.title(_spec.caller, _spec.vc_id)
	_line.text = tr(_spec.line).format(_spec.args)
	_note_text.text = tr(_spec.note).format(_spec.note_args) if _spec.note != "" else ""


## The card opens at the hour of the click.
func _open_card() -> void:
	_retranslate()
	_card.visible = true


## A held clock does not take the call: the ring and the card stay, the shell's toast says why.
func _accept() -> void:
	if TimeManager.is_clock_held():
		get_tree().call_group(&"game_shell", &"say_held")
		return
	stop()
	accepted.emit()


func _postpone() -> void:
	_card.visible = false
	get_tree().call_group(&"toast", &"show_toast", tr("MEETING_POSTPONED"), tr(_spec.toast), POSTPONE_GLYPH,
		UiTokens.D_INK_3)
	postponed.emit()
