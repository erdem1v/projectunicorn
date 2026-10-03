class_name MeetingInvite
extends Control

# The call that opens an outside meeting: a phone rings over the founder's head in the office, a
# ring pulsing round it, and the camera closes on them; a click on it opens the call's card beside
# it (the hour, the caller's line, Accept and Postpone, and a note on what putting it off means),
# or the card is open from the first ring. Postponing closes the card and the shell's toast says so;
# main.gd rings it (a fund whose meeting week has come, a prospect the player asked to meet),
# decides what a postponement does, and stops it once the call is gone. With the founder out of
# sight (the map, the meeting room, a trip) nothing shows and the call waits.

signal accepted
signal postponed

const RING_PX := 52.0          # the ring's full size, and the click's
const RING_S := 1.1            # one pulse, seconds
const RING_WIDTH := 2.0
const CARD_W := 272.0
## The card sits right of the phone and up a little, kept inside the view.
const CARD_OFFSET := Vector2(30.0, -44.0)
const POSTPONE_GLYPH := preload("res://assets/icons/util/calendar.svg")
## The camera closes on the founder as the phone starts: aimed this high above their feet, this
## much closer than the office's fit, over this long.
const FOCUS_RISE := 0.9
const FOCUS_ZOOM := 1.75
const FOCUS_S := 2.2

var _view: Control
var _people: OfficePeople
var _ring: Control
var _card: PanelContainer
var _kicker: Label
var _line: Label
var _accept_button: Button
var _postpone_button: Button
var _note: Label
## The call as rung (ring()): its line, the note's and the toast line's keys and their arguments,
## translated when shown.
var _spec := {}


func _init(view: Control, people: OfficePeople) -> void:
	_view = view
	_people = people
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_ring = Control.new()
	_ring.size = Vector2.ONE * RING_PX
	_ring.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_ring.draw.connect(_draw_ring)
	_ring.gui_input.connect(func(event: InputEvent) -> void:
		if UiFactory.is_left_click(event):
			_open_card())
	add_child(_ring)
	_card = PanelContainer.new()
	_card.theme_type_variation = &"CardFloating"
	_card.custom_minimum_size.x = CARD_W
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", UiTokens.SPACE_M)
	_card.add_child(col)
	_kicker = UiFactory.make_label("", &"SectionAmber")
	col.add_child(_kicker)
	_line = UiFactory.make_label("", &"NameSerif")
	_line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	col.add_child(_line)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", UiTokens.SPACE_M)
	col.add_child(row)
	# FOCUS_NONE: Space is the pause key, not a press of the focused button.
	_accept_button = Button.new()
	_accept_button.theme_type_variation = &"CommitButton"
	_accept_button.focus_mode = Control.FOCUS_NONE
	_accept_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_accept_button.pressed.connect(_accept)
	row.add_child(_accept_button)
	_postpone_button = Button.new()
	_postpone_button.focus_mode = Control.FOCUS_NONE
	_postpone_button.pressed.connect(_postpone)
	row.add_child(_postpone_button)
	_note = UiFactory.make_label("", &"RowMeta")
	_note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	col.add_child(_note)
	add_child(_card)
	EventBus.language_changed.connect(_retranslate.unbind(1))
	_retranslate()
	stop()


## Rings for a call, `spec`: `line` (the caller's line, a key formatted with `args`), `open` (the
## card is open from the first ring), `postpone` (the call can be put off), `note` (a key under the
## buttons, formatted with `note_args`; "" for none) and `toast` (the key of the toast's line when it
## is put off).
func ring(spec: Dictionary) -> void:
	_spec = spec
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
	if not visible:
		return
	var at: Vector2 = (_view.camera as Camera3D).unproject_position(_people.founder().marker())
	_ring.position = at - _ring.size * 0.5
	_ring.queue_redraw()
	if _card.visible:
		# The wrapped line is measured at the card's width only once laid out: the card fits it anew.
		_card.reset_size()
		var margin := Vector2.ONE * UiTokens.SPACE_M
		_card.position = (at + CARD_OFFSET).clamp(margin, size - _card.size - margin)


func _draw_ring() -> void:
	var k := fmod(Time.get_ticks_msec() * 0.001, RING_S) / RING_S
	_ring.draw_arc(_ring.size * 0.5, RING_PX * 0.5 * (0.6 + k), 0.0, TAU, 48, Color(UiTokens.ACCENT, 1.0 - k),
		RING_WIDTH, true)


func _retranslate() -> void:
	_kicker.text = tr("MEETING_INVITE_KICKER").format({"hour": "%02d" % GameState.current_hour})
	_accept_button.text = tr("MEETING_ACCEPT")
	_postpone_button.text = tr("MEETING_POSTPONE")
	if _spec.is_empty():
		return
	_line.text = tr(_spec.line).format(_spec.args)
	_note.text = tr(_spec.note).format(_spec.note_args) if _spec.note != "" else ""


## The card opens at the hour of the click.
func _open_card() -> void:
	_retranslate()
	_card.visible = true


func _accept() -> void:
	stop()
	accepted.emit()


func _postpone() -> void:
	_card.visible = false
	get_tree().call_group(&"toast", &"show_toast", tr("MEETING_POSTPONED"), tr(_spec.toast), POSTPONE_GLYPH,
		UiTokens.D_INK_3)
	postponed.emit()
