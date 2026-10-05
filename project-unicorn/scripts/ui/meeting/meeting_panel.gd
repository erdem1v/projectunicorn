class_name MeetingPanel
extends Control

# A sitting, played in a dock at the right of the office view while the room sits at the table
# beside it. The head names who speaks for the other side (portrait, name, role and company, a
# customer's stars and one-line read), who sits at the table, the table's attitude or, at the price,
# its patience, and what they remember; the transcript under it keeps the whole sitting, its newest
# row on the deck; the deck at the bottom holds the price ruler, the options, the result card and
# Devam.
#
# It draws the steps an adapter returns (VcMeetingAdapter, SalesMeetingAdapter) and plays each one
# back. The adapter has already committed the pick when the die spins, so the playback only tells
# it, and a click or Enter skips it. The room plays along through MeetingCast: who looks at whom,
# who talks, the gestures.
#
# The panel's own rect covers the screen as a clear shield, so the top bar, the rail and the ticker
# stay inert while the sitting lasts. The tree is paused at speed 0, so it runs ALWAYS.

signal closed

const OPTION := preload("res://scripts/ui/meeting/meeting_panel_option.gd")
const ENTER := preload("res://assets/icons/util/enter.svg")
const INFO := "res://assets/icons/util/info.svg"
## The result card's glyph by its band.
const RESULT_GLYPHS := {"positive": "res://assets/icons/util/check.svg", "negative": "res://assets/icons/util/close.svg",
	"accent": "res://assets/icons/util/calendar.svg"}
## The die tooltip's tag by its risk word.
const RISK_TAGS := {"MEETING_RISK_SAFE": &"pos", "MEETING_RISK_RISKY": &"warn", "MEETING_RISK_DANGER": &"risk"}

## The dock: this share of the office view's width.
const DOCK_SHARE := 0.34
## How the room sits as the sitting opens: seats 1-3 in MeetingCast order, then the founder.
const SEAT_POSTS := [{"arms": "table"}, {"arms": "rest", "lean": -0.1}, {"write": true}]
const FOUNDER_POST := {"arms": "table"}
## Playback, in seconds; a line types at so many characters a second. [WORKING]
const SPIN_S := 0.8
const FLASH_S := 0.6
const PICK_HOLD_S := 0.4
const TYPE_CPS := 120.0
const FOUNDER_CPS := 240.0
const TYPE_MIN_S := 0.25
const TYPE_MAX_S := 1.6
const FADE_S := 0.3
const GAP_S := 0.35
const NEEDLE_S := 0.8
## A step long enough to finish any playback at once.
const SKIP_S := 3600.0
const PICK_KEYS := [KEY_1, KEY_2, KEY_3, KEY_4, KEY_5]
const PICK_KEYS_KP := [KEY_KP_1, KEY_KP_2, KEY_KP_3, KEY_KP_4, KEY_KP_5]

var _adapter   # VcMeetingAdapter or SalesMeetingAdapter: start, pick, proceed, withdraw, select
var _cast: MeetingCast
## The office view the dock stands over.
var _view: Control
## The people at the table by seat: 0 the founder, 1-3 the other side ({name, role, look}).
var _people := {}
var _company := ""
var _speaker := 0
var _playing := false
## Options are on the deck and take a pick.
var _live := false
var _tween: Tween
var _cards: Array[OPTION] = []
var _enabled: Array[OPTION] = []
var _attitude := {}

var _dock := PanelContainer.new()
var _kicker: Label
var _beat_sep: Label
var _beat: Label
var _portrait := MarginContainer.new()
var _name: Label
var _role: Label
var _read := HBoxContainer.new()
var _read_box: MarginContainer
var _badge := HBoxContainer.new()
var _seats := HBoxContainer.new()
var _attitude_row: HBoxContainer
var _gauge := Control.new()
var _word_slot := HBoxContainer.new()
var _odds: Label
var _patience_row: HBoxContainer
var _patience := HBoxContainer.new()
var _memory_row: HBoxContainer
var _memory: Label
var _scroll := ScrollContainer.new()
var _flow := VBoxContainer.new()
var _fade := Control.new()
var _deck := VBoxContainer.new()
var _ruler: MeetingRuler
var _content := VBoxContainer.new()
var _footer := HBoxContainer.new()
var _withdraw: Button
var _continue: Button
var _tip := PanelContainer.new()
var _tip_col := VBoxContainer.new()
## TUTUM's now mark, 0-100; the playback slides it.
var _needle := 0.0:
	set(value):
		_needle = value
		_gauge.queue_redraw()


func _init() -> void:
	theme = load(UiTokens.MENAJER_THEME)
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	_dock.theme_type_variation = &"Dock"
	add_child(_dock)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 0)
	_dock.add_child(col)
	col.add_child(_build_head())
	col.add_child(_build_transcript())
	col.add_child(_build_deck())
	_build_tip()


# ============================================================================
#  Public surface
# ============================================================================

## Opens the sitting on `adapter`'s first step, with `cast` the room at the table.
func open(adapter: RefCounted, cast: MeetingCast) -> void:
	_adapter = adapter
	_cast = cast
	var founder: Character = CharacterRegistry.get_founder()
	_people[0] = {"name": founder.character_name, "look": founder.look}
	var step: Dictionary = _adapter.start()
	_play(step, null)
	# The head stands from the first line; the playback's own pass over it then changes nothing.
	_settle_head(step)
	_needle = step.attitude.value
	for seat in range(1, cast.count()):
		cast.post(seat, SEAT_POSTS[seat - 1])
		cast.look(seat, 0)
	cast.post(0, FOUNDER_POST)
	_view = get_tree().get_first_node_in_group(&"office_view")
	_view.resized.connect(_place_dock)
	_place_dock()


## The founder picks option `id` (a click, a number key, the shot harness). Only while options
## are live.
func pick(id: String) -> void:
	var chosen: OPTION
	for card in _enabled:
		if card.id == id:
			chosen = card
	if not _live or chosen == null:
		return
	_tip.hide()
	for card in _cards:
		if card == chosen:
			card.choose()
		else:
			card.dim()
	_play(_adapter.pick(id), chosen)


## Ends the playback under way at once, as a click or Enter does.
func skip_playback() -> void:
	if _playing:
		_tween.custom_step(SKIP_S)


## Devam: the adapter's next beat, the price act, or the close after the result card.
func proceed() -> void:
	if _playing or not _continue.visible:
		return
	_play(_adapter.proceed(), null)


# ============================================================================
#  Build
# ============================================================================

func _build_head() -> Control:
	var head := PanelContainer.new()
	head.theme_type_variation = &"DockHead"
	var rows := SprintUiShared.column(UiTokens.SPACE_L)
	head.add_child(rows)

	# The kicker in sentence case; the beat or the act after it a step brighter.
	var kicker := SprintUiShared.box(UiTokens.SPACE_M)
	_kicker = UiFactory.make_label("", &"MetaMuted")
	_beat_sep = UiFactory.make_label("·", &"MetaMuted", UiTokens.D_INK_4)
	_beat = UiFactory.make_label("", &"MetaText")
	for part: Label in [_kicker, _beat_sep, _beat]:
		kicker.add_child(part)
	rows.add_child(kicker)

	var who := SprintUiShared.box(UiTokens.SPACE_XL)
	_portrait.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	who.add_child(_portrait)
	var id := SprintUiShared.column(UiTokens.SPACE_XXS)
	_name = UiFactory.make_label("", &"TitleH2")
	_name.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	id.add_child(_name)
	_role = UiFactory.make_label("", &"MetaMuted")
	_role.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	id.add_child(_role)
	# A customer's stars (a rule unit, so glyphs) and the one-line read; a whale's condition under it.
	_read.add_theme_constant_override("separation", UiTokens.SPACE_M)
	_read_box = SprintUiShared.pad(_read, Vector4i(0, UiTokens.SPACE_S, 0, 0))
	_read_box.hide()
	id.add_child(_read_box)
	_badge.add_theme_constant_override("separation", UiTokens.SPACE_S)
	_badge.hide()
	id.add_child(_badge)
	var id_box := SprintUiShared.pad(id, Vector4i(0, UiTokens.SPACE_S, 0, 0))
	id_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	who.add_child(id_box)
	rows.add_child(who)

	# Who sits across the table: each face and first name, the one speaking in an ink ring.
	_seats.add_theme_constant_override("separation", UiTokens.SPACE_XL)
	rows.add_child(SprintUiShared.pad(_key_row("MEETING_AT_TABLE", _seats), Vector4i(0, UiTokens.SPACE_XS, 0, 0)))

	# TUTUM: one neutral fill over the band edges, the band's word as a tag; a sales table adds its
	# persuasion, with the reasons on hover.
	_gauge.custom_minimum_size.y = UiTokens.D_H_TUT_NOW
	_gauge.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_gauge.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_gauge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_gauge.draw.connect(_draw_gauge)
	var reading := SprintUiShared.box(UiTokens.SPACE_L)
	reading.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	reading.add_child(_gauge)
	reading.add_child(_word_slot)
	_odds = UiFactory.make_label("", &"KeyText")
	_odds.mouse_filter = Control.MOUSE_FILTER_PASS
	_odds.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_odds.draw.connect(_draw_dotted.bind(_odds))
	reading.add_child(_odds)
	_attitude_row = _key_row("MEETING_ATTITUDE", reading)
	rows.add_child(_attitude_row)

	# At the price the patience boxes stand where TUTUM stood.
	_patience_row = _key_row("NEG_PATIENCE", _patience)
	_patience_row.hide()
	rows.add_child(_patience_row)

	_memory = UiFactory.make_label("", &"MetaText")
	_memory.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_memory.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_memory_row = _key_row("MEETING_MEMORY", _memory)
	_memory_row.hide()
	rows.add_child(_memory_row)
	return head


## A head row: its caps key in the dock's key column, then `value`.
func _key_row(key: String, value: Control) -> HBoxContainer:
	var row := SprintUiShared.box(UiTokens.SPACE_L)
	var caption := UiFactory.make_label(Fmt.upper(tr(key)), &"KeyLabel")
	caption.custom_minimum_size.x = UiTokens.D_W_DOCK_KEY
	caption.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(caption)
	row.add_child(value)
	return row


## The transcript sits on the deck: a short one leaves its room above it, a long one scrolls under
## the head behind a fade.
func _build_transcript() -> Control:
	var area := Control.new()
	area.size_flags_vertical = Control.SIZE_EXPAND_FILL
	area.custom_minimum_size.y = UiTokens.D_H_FLOW_MIN
	_scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	var bar := _scroll.get_v_scroll_bar()
	bar.changed.connect(func() -> void:
		_scroll.scroll_vertical = int(bar.max_value)
		_fade.visible = bar.max_value > bar.page)
	area.add_child(_scroll)
	_flow.add_theme_constant_override("separation", UiTokens.SPACE_XL)
	_flow.alignment = BoxContainer.ALIGNMENT_END
	_flow.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var pad := SprintUiShared.pad(_flow, Vector4i(UiTokens.SPACE_3XL, UiTokens.SPACE_XXL, UiTokens.SPACE_4XL,
		UiTokens.SPACE_XXL))
	pad.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	pad.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_scroll.add_child(pad)
	_fade.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	_fade.offset_bottom = UiTokens.D_H_FLOW_FADE
	_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fade.draw.connect(func() -> void:
		var w: float = _fade.size.x
		var h: float = _fade.size.y
		_fade.draw_polygon(PackedVector2Array([Vector2.ZERO, Vector2(w, 0), Vector2(w, h), Vector2(0, h)]),
			PackedColorArray([UiTokens.D_FLOW_FADE[0], UiTokens.D_FLOW_FADE[0], UiTokens.D_FLOW_FADE[1],
				UiTokens.D_FLOW_FADE[1]])))
	_fade.hide()
	area.add_child(_fade)
	return area


func _build_deck() -> Control:
	var deck_box := PanelContainer.new()
	deck_box.theme_type_variation = &"DockDeck"
	_deck.add_theme_constant_override("separation", UiTokens.SPACE_XL)
	deck_box.add_child(_deck)
	_content.add_theme_constant_override("separation", UiTokens.SPACE_M)
	_deck.add_child(_content)
	_footer.add_theme_constant_override("separation", UiTokens.SPACE_L)
	_footer.hide()
	_deck.add_child(_footer)
	# FOCUS_NONE: Space is the pause key, never a press of a focused button.
	_withdraw = SprintUiShared.button(tr("MEETING_WITHDRAW"), &"SecondaryButtonSmall", _withdraw_meeting)
	_footer.add_child(_withdraw)
	_footer.add_child(RnDUiShared.spacer())
	_continue = SprintUiShared.button("", &"PrimaryButtonDark", proceed)
	_continue.icon = ENTER
	_continue.icon_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_footer.add_child(_continue)
	return deck_box


## The die's tooltip over the deck. It grows upward from where it is placed, and takes no pointer.
func _build_tip() -> void:
	_tip.theme_type_variation = &"TooltipPanel"
	_tip.grow_vertical = Control.GROW_DIRECTION_BEGIN
	_tip_col.add_theme_constant_override("separation", UiTokens.SPACE_M)
	_tip.add_child(SprintUiShared.pad(_tip_col, Vector4i.ONE * UiTokens.SPACE_XS))
	_tip.hide()
	add_child(_tip)


## The dock stands at the right of the office view, as tall as it, and the table is framed in the
## part of the view it leaves. Offsets, not size: a size is clamped to the minimum of the moment,
## which wrapping labels inflate until they have their width, and would keep that height.
func _place_dock() -> void:
	var area := _view.get_global_rect()
	area.position -= global_position
	var width := area.size.x * DOCK_SHARE
	_dock.offset_left = area.end.x - width
	_dock.offset_top = area.position.y
	_dock.offset_right = area.end.x
	_dock.offset_bottom = area.end.y
	_cast.frame_table(width)


# ============================================================================
#  Playback
# ============================================================================

## Plays `step` back. After a pick (`chosen`) the other options dim and the die spins and lands;
## then the new rows type or fade in one by one while the room acts them, the gestures follow,
## the head settles, and the deck takes what the step leaves on it.
func _play(step: Dictionary, chosen: OPTION) -> void:
	_live = false
	if step.get("closed", false):
		# The panel lives to the end of the frame: nothing on it may press again.
		_continue.hide()
		_footer.hide()
		set_process_input(false)
		closed.emit()
		return
	_playing = true
	for row: Control in _flow.get_children():
		_step_back(row)
	_frame(step)
	_tween = create_tween()
	var roll: Dictionary = step.get("roll", {})
	if chosen == null:
		_clear_deck()
	else:
		if not roll.is_empty() and chosen.has_die:
			_tween.tween_method(chosen.spin, 0.0, 1.0, SPIN_S)
			_tween.tween_callback(chosen.land.bind(roll.passed))
			_tween.tween_interval(FLASH_S)
		else:
			_tween.tween_interval(PICK_HOLD_S)
		_tween.tween_callback(_clear_deck)
	for entry: Dictionary in step.get("entries", []):
		_queue_entry(entry, roll)
	_tween.tween_callback(_gesture.bind(step.get("gestures", [])))
	_tween.tween_callback(_settle_head.bind(step))
	var attitude: Dictionary = step.get("attitude", {})
	if not attitude.is_empty():
		_tween.tween_property(self, "_needle", float(attitude.value), NEEDLE_S)
	_tween.tween_callback(_settle.bind(step))


## The other side, taken at once because the step's rows are built with their names: the people,
## the company, and a customer's stars, one-line read and condition.
func _frame(step: Dictionary) -> void:
	for person: Dictionary in step.get("cast", []):
		_people[person.seat] = person
	if step.has("cast"):
		_build_seats()
	if step.has("company"):
		_company = step.company
	if step.has("identity"):
		var identity: Dictionary = step.identity
		UiFactory.clear(_read)
		_read.add_child(UiFactory.D_stars(identity.stars))
		_read.add_child(SprintUiShared.prose(identity.sub, &"Caption"))
		_read_box.show()
		UiFactory.clear(_badge)
		_badge.visible = identity.badge != ""
		if _badge.visible:
			_badge.add_child(UiFactory.make_glyph(INFO, UiTokens.D_ICON_LINE, UiTokens.D_INK_3))
			var condition := UiFactory.make_label(identity.badge, &"CaptionPrimary")
			condition.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			condition.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			_badge.add_child(condition)


## Builds an entry's row, hidden, and queues its reveal: a spoken line types in while its speaker
## talks at the table, anything else fades in.
func _queue_entry(entry: Dictionary, roll: Dictionary) -> void:
	var seat: int = entry.get("seat", 0)
	var text: String = entry.text
	var line: Label
	var row: Control
	match entry.kind:
		"counterpart":
			line = _typed(text, &"SayLine")
			row = _said(_avatar(seat, UiTokens.D_AVATAR_ROW), _people[seat].name, line)
		"founder":
			line = _typed(text, &"SayLine")
			row = _founder_row(entry.get("pill", ""), roll, line)
		"frank":
			line = _typed(text, &"FrankLine")
			# Frank's disc has no 32 bake: the 40 draws at a row's size.
			var frank := UiFactory.make_mentor_avatar(UiTokens.D_AVATAR_DOC)
			frank.custom_minimum_size = Vector2.ONE * UiTokens.D_AVATAR_ROW
			row = _said(frank, tr("MENTOR_NAME"), line)
		"state":
			row = _said(_avatar(seat, UiTokens.D_AVATAR_ROW), _people[seat].name,
				UiFactory.make_label(text, &"ValueText", UiTokens.D_INK_1))
		_:
			row = _quiet(text)
	row.hide()
	_flow.add_child(row)
	_tween.tween_callback(_reveal.bind(row, entry))
	if line == null:
		_tween.tween_property(row, "modulate:a", 1.0, FADE_S).from(0.0)
	else:
		var cps := FOUNDER_CPS if entry.kind == "founder" else TYPE_CPS
		_tween.tween_property(line, "visible_ratio", 1.0, clampf(text.length() / cps, TYPE_MIN_S, TYPE_MAX_S))
		_tween.tween_callback(_hush)
	_tween.tween_interval(GAP_S)


func _reveal(row: Control, entry: Dictionary) -> void:
	row.show()
	match entry.kind:
		"counterpart":
			_show_person(entry.seat)
			_cast.speak(entry.seat)
			_cast.look(0, entry.seat)
		"founder":
			_cast.speak(0)


func _hush() -> void:
	_cast.speak(-1)


## A gesture replaces the one its person is making, so a seat's next waits for the last. The
## waits run apart from the playback, which a skip would otherwise fire at once.
func _gesture(gestures: Array) -> void:
	var after := {}
	for g: Dictionary in gestures:
		var wait: float = after.get(g.seat, 0.0)
		if wait == 0.0:
			_cast.gesture(g.seat, g.name)
		else:
			create_tween().tween_callback(_cast.gesture.bind(g.seat, g.name)).set_delay(wait)
		after[g.seat] = wait + MeetingCast.GESTURE_S


## The head once the step is told: the beat, the speaker, TUTUM or the patience, the memory.
func _settle_head(step: Dictionary) -> void:
	if step.has("kicker"):
		_kicker.text = step.kicker
		_beat.text = step.get("beat", "")
		_beat_sep.visible = _beat.text != ""
	if step.has("speaker"):
		_speaker = step.speaker
		_show_person(_speaker)
		_cast.look(0, _speaker)
	if step.has("attitude"):
		_attitude = step.attitude
		_attitude_row.visible = not _attitude.is_empty()
		if _attitude_row.visible:
			UiFactory.clear(_word_slot)
			_word_slot.add_child(UiFactory.D_tag(tr(_attitude.word_key),
				&"pos" if _attitude.band == "warm" else &"outline"))
			_odds.text = _attitude.odds_text
			_odds.visible = _odds.text != ""
			_odds.tooltip_text = "\n".join(PackedStringArray(_attitude.hover))
	if step.has("patience"):
		_patience_row.show()
		UiFactory.clear(_patience)
		_patience.add_child(UiFactory.D_patience(step.patience.current, step.patience["max"], UiTokens.D_PATIENCE.x))
	if step.has("memory"):
		_memory.text = step.memory
		_memory_row.visible = _memory.text != ""


## What the step leaves on the deck once told: the ruler, the options, the result card, Devam and
## the way out of the first beat.
func _settle(step: Dictionary) -> void:
	_playing = false
	_tween = null
	if step.has("instrument"):
		if _ruler == null:
			_ruler = MeetingRuler.new()
			_ruler.changed.connect(_on_ruler_changed)
			_deck.add_child(_ruler)
			_deck.move_child(_ruler, 0)
		_ruler.visible = not step.instrument.is_empty()
		if _ruler.visible:
			_ruler.show_instrument(step.instrument)
	_set_options(step.get("options", []))
	var result: Dictionary = step.get("result", {})
	if not result.is_empty():
		_content.add_child(_result_card(result))
	var key: String = step.get("continue_key", "")
	if key != "":
		_continue.text = tr(key)
	_continue.visible = key != ""
	_withdraw.visible = step.get("can_withdraw", false)
	_footer.visible = _continue.visible or _withdraw.visible
	_live = not _cards.is_empty()


func _clear_deck() -> void:
	_set_options([])
	_footer.hide()


# ============================================================================
#  Head
# ============================================================================

func _show_person(seat: int) -> void:
	var person: Dictionary = _people[seat]
	UiFactory.clear(_portrait)
	_portrait.add_child(_avatar(seat, UiTokens.D_AVATAR_SPEAKER))
	_name.text = person.name
	_role.text = tr("MEETING_ROLE_LINE").format({"role": person.role, "company": _company})
	for i in _seats.get_child_count():
		_paint_seat(_seats.get_child(i), i + 1 == seat)


## The other side's seats, each its face and first name.
func _build_seats() -> void:
	UiFactory.clear(_seats)
	for seat in range(1, _people.size()):
		var cell := SprintUiShared.box(UiTokens.SPACE_S)
		var face := _avatar(seat, UiTokens.D_AVATAR_ROW_SM)
		face.draw.connect(_draw_seat_ring.bind(face, cell))
		cell.add_child(face)
		cell.add_child(UiFactory.make_label(String(_people[seat].name).get_slice(" ", 0), &"MetaMuted"))
		_seats.add_child(cell)


## The one speaking: an ink ring round the face, the name in emphasis.
func _paint_seat(cell: HBoxContainer, on: bool) -> void:
	cell.set_meta(&"on", on)
	(cell.get_child(1) as Label).theme_type_variation = &"MetaStrong" if on else &"MetaMuted"
	cell.get_child(0).queue_redraw()


func _draw_seat_ring(face: Control, cell: HBoxContainer) -> void:
	if cell.get_meta(&"on", false):
		var r: float = face.size.x * 0.5 + UiTokens.BORDER_FOCUS * 1.5
		face.draw_arc(face.size * 0.5, r, 0.0, TAU, 48, UiTokens.D_INK_1, UiTokens.BORDER_FOCUS, true)


func _avatar(seat: int, px: int) -> Panel:
	var person: Dictionary = _people[seat]
	var disc := UiFactory.make_person_avatar(person.name, person.look, px)
	disc.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	return disc


## TUTUM: the track, its fill to the reading, the band edges as notches and the now mark.
func _draw_gauge() -> void:
	var w: float = _gauge.size.x
	var mid: float = _gauge.size.y * 0.5
	var track := float(UiTokens.D_H_PROGRESS)
	_gauge.draw_rect(Rect2(0, mid - track * 0.5, w, track), UiTokens.D_BAR_TRACK)
	var x := clampf(_needle / 100.0, 0.0, 1.0) * w
	_gauge.draw_rect(Rect2(0, mid - track * 0.5, x, track), UiTokens.D_BAR_FILL)
	for edge: int in _attitude.get("edges", []):
		var nx := edge / 100.0 * w
		_gauge.draw_rect(Rect2(nx, mid - UiTokens.D_NOTCH.y * 0.5, UiTokens.D_NOTCH.x, UiTokens.D_NOTCH.y), UiTokens.D_INK_4)
	_gauge.draw_rect(Rect2(x - UiTokens.BORDER_HAIRLINE, 0, UiTokens.BORDER_FOCUS, _gauge.size.y), UiTokens.D_INK_1)


## The persuasion's dotted underline: its reasons are on hover.
func _draw_dotted(label: Label) -> void:
	var y: float = label.size.y - UiTokens.BORDER_HAIRLINE
	var x := 0.0
	while x < label.size.x:
		label.draw_line(Vector2(x, y), Vector2(minf(x + UiTokens.SPACE_XXS, label.size.x), y), UiTokens.D_INK_4,
			UiTokens.BORDER_HAIRLINE)
		x += UiTokens.SPACE_XS


# ============================================================================
#  Transcript
# ============================================================================

## A spoken line, shaped whole from the start so its row has its final height while it types in.
func _typed(text: String, variation: StringName) -> Label:
	var line := UiFactory.make_label(text, variation)
	line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	line.visible_characters_behavior = TextServer.VC_CHARS_AFTER_SHAPING
	line.visible_ratio = 0.0
	return line


## A row someone speaks (UiFactory.D_said), its line stepping back with the beat.
func _said(face: Control, who: String, line: Label) -> HBoxContainer:
	var row := UiFactory.D_said(face, who, line)
	row.set_meta(&"line", line)
	return row


## The founder's move, a small document: the name, the move's tag when a die decided it (✓ in the
## gain tag when it passed, ✕ in the plain one when it failed) and the line.
func _founder_row(pill: String, roll: Dictionary, line: Label) -> HBoxContainer:
	var row := SprintUiShared.box(UiTokens.SPACE_L)
	row.add_child(_avatar(0, UiTokens.D_AVATAR_ROW))
	var doc := PanelContainer.new()
	doc.theme_type_variation = &"SayDoc"
	doc.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var col := SprintUiShared.column(UiTokens.SPACE_XXS)
	doc.add_child(col)
	var head := SprintUiShared.box(UiTokens.SPACE_M)
	head.add_child(UiFactory.make_label(_people[0].name, &"KeyTextMuted"))
	if pill != "" and not roll.is_empty():
		head.add_child(UiFactory.D_glyph_tag(RESULT_GLYPHS.positive if roll.passed else RESULT_GLYPHS.negative, pill,
			&"pos" if roll.passed else &"outline"))
	col.add_child(head)
	col.add_child(line)
	row.add_child(doc)
	row.set_meta(&"line", line)
	row.set_meta(&"doc", doc)
	return row


## The founder's inner voice or the room's read: a margin note on the text column, no speaker.
func _quiet(text: String) -> MarginContainer:
	var note := PanelContainer.new()
	note.theme_type_variation = &"QuietNote"
	var words := UiFactory.make_label(text, &"MetaMuted")
	words.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	note.add_child(words)
	return SprintUiShared.pad(note, Vector4i(UiTokens.D_AVATAR_ROW + UiTokens.SPACE_L, 0, 0, 0))


## A row of a beat already played stays readable one ink step down.
func _step_back(row: Control) -> void:
	if row.has_meta(&"line"):
		(row.get_meta(&"line") as Label).add_theme_color_override("font_color", UiTokens.D_INK_3)
	if row.has_meta(&"doc"):
		(row.get_meta(&"doc") as PanelContainer).theme_type_variation = &"SayDocPast"


# ============================================================================
#  Deck
# ============================================================================

func _set_options(options: Array) -> void:
	UiFactory.clear(_content)
	_cards.clear()
	_enabled.clear()
	_tip.hide()
	for option: Dictionary in options:
		var enabled: bool = option.get("enabled", true)
		var card := OPTION.new(option, _enabled.size() + 1 if enabled else 0)
		card.clicked.connect(pick.bind(card.id))
		card.hovered.connect(_on_hover.bind(card))
		_content.add_child(card)
		_cards.append(card)
		if enabled:
			_enabled.append(card)


## The price moved on the ruler: the adapter reads it, and the offer's tone follows.
func _on_ruler_changed(value: int) -> void:
	if not _live:
		return
	var step: Dictionary = _adapter.select(value)
	_ruler.show_instrument(step.instrument)
	_set_options(step.options)


## The die's odds over the deck while the pointer is on an option with a risk word: the risk and its
## odds, then what moves them.
func _on_hover(on: bool, card: OPTION) -> void:
	if not on or card.tip.is_empty():
		_tip.hide()
		return
	var dice: Dictionary = card.tip
	UiFactory.clear(_tip_col)
	var head := SprintUiShared.box(UiTokens.SPACE_M)
	var title := UiFactory.make_label(Fmt.upper(tr("MEETING_DICE")), &"KeyLabel")
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(title)
	head.add_child(UiFactory.D_tag(tr("MEETING_RISK_PCT").format({"risk": tr(dice.risk_key),
		"pct": roundi(dice.chance * 100.0)}), RISK_TAGS[dice.risk_key]))
	_tip_col.add_child(head)
	var chips := HFlowContainer.new()
	chips.add_theme_constant_override("h_separation", UiTokens.SPACE_L)
	chips.add_theme_constant_override("v_separation", UiTokens.SPACE_S)
	# The folded "and more" line has no category and no sign.
	for factor: Dictionary in dice.factors:
		var chip := SprintUiShared.column(0)
		if factor.cat_key != "":
			chip.add_child(UiFactory.make_label(Fmt.upper(tr(factor.cat_key)), &"KeySmall"))
		var text: String = factor.text if factor.sign == "" else "%s %s" % [factor.sign, factor.text]
		chip.add_child(UiFactory.make_label(text, &"TooltipLabel",
			{"pos": UiTokens.D_pos(), "neg": UiTokens.D_neg()}.get(factor.tone, UiTokens.D_INK_2)))
		chips.add_child(chip)
	_tip_col.add_child(chips)
	HRUiShared.set_mouse_ignore(_tip)
	var deck := _content.get_global_rect()
	deck.position -= global_position
	_tip.offset_left = deck.position.x
	_tip.offset_right = deck.end.x
	_tip.offset_top = deck.position.y - UiTokens.SPACE_M
	_tip.offset_bottom = _tip.offset_top
	_tip.show()


## The sitting's outcome, a finished document: the outcome in glyph, word and colour (a signed deal
## stamped; a withdrawal is neither, in ink without a glyph), then what it leaves behind, row by row.
func _result_card(result: Dictionary) -> Control:
	var card := PanelContainer.new()
	card.theme_type_variation = &"ResultDoc"
	var col := SprintUiShared.column(0)
	card.add_child(col)
	var ink: Color = {"positive": UiTokens.D_pos(), "negative": UiTokens.D_neg_ink(),
		"accent": UiTokens.D_warn()}.get(result.band, UiTokens.D_INK_1)
	var head := SprintUiShared.box(UiTokens.SPACE_M)
	if RESULT_GLYPHS.has(result.band):
		head.add_child(UiFactory.make_glyph(RESULT_GLYPHS[result.band], UiTokens.D_ICON_RESULT, ink))
	var title := UiFactory.make_label(tr(result.title_key), &"DialogTitle", ink)
	title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(title)
	if result.get("stamp", "") != "":
		head.add_child(UiFactory.D_stamp(Fmt.upper(tr(result.stamp))))
	col.add_child(SprintUiShared.pad(head, Vector4i(0, 0, 0, UiTokens.SPACE_L)))
	var relation: Dictionary = result.relation
	var rows := {
		"MEETING_RES_EFFECT": result.effect,
		"MEETING_RES_RELATION": tr("MEETING_RES_RELATION_LINE").format({"name": relation.name,
			"from": tr(UiTokens.attitude_word_key(relation.from)), "to": tr(UiTokens.attitude_word_key(relation.to))}),
		"MEETING_RES_MEMORY": result.memory,
	}
	for caption_key: String in rows:
		if rows[caption_key] == "":
			continue
		col.add_child(HRUiShared.hairline(UiTokens.D_LINE_1))
		var line := SprintUiShared.box(UiTokens.SPACE_L)
		var caption := UiFactory.make_label(Fmt.upper(tr(caption_key)), &"KeyLabel")
		caption.custom_minimum_size.x = UiTokens.D_W_RESULT_ROW_KEY
		caption.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
		line.add_child(caption)
		var text := UiFactory.make_label(rows[caption_key], &"DataText")
		text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		line.add_child(text)
		col.add_child(SprintUiShared.pad(line, Vector4i(0, UiTokens.SPACE_M, 0, UiTokens.SPACE_M)))
	return card


func _withdraw_meeting() -> void:
	_play(_adapter.withdraw(), null)


# ============================================================================
#  Input
# ============================================================================

## A click or Enter skips the playback under way; Enter is Devam, and never a pick. The number
## keys pick among the open options, Esc withdraws where the first beat allows it.
func _input(event: InputEvent) -> void:
	if _playing and UiFactory.is_left_click(event):
		get_viewport().set_input_as_handled()
		skip_playback()
		return
	var key := event as InputEventKey
	if key == null or not key.pressed or key.echo:
		return
	var n := maxi(PICK_KEYS.find(key.keycode), PICK_KEYS_KP.find(key.keycode))
	if key.keycode == KEY_ENTER or key.keycode == KEY_KP_ENTER:
		get_viewport().set_input_as_handled()
		if _playing:
			skip_playback()
		else:
			proceed()
	elif key.keycode == KEY_ESCAPE and _live and _withdraw.visible:
		get_viewport().set_input_as_handled()
		_withdraw_meeting()
	elif _live and n >= 0 and n < _enabled.size():
		get_viewport().set_input_as_handled()
		pick(_enabled[n].id)
