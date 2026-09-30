class_name MeetingPanel
extends Control

# A sitting, played in a dock at the right of the office view while the room sits at the table
# beside it. The header names who speaks for the other side (portrait, name, role and company, the
# stars and the one-line read of a customer) with the table's attitude, or at the price its
# patience, and what they remember; the transcript under it keeps the whole sitting; the deck at
# the bottom holds the options, the price ruler, the result card and Devam.
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

## The dock: this share of the office view's width.
const DOCK_SHARE := 0.34
const PORTRAIT_PX := 96
const TRANSCRIPT_PX := 38
const TRANSCRIPT_MIN_H := 80.0
const RING_POINTS := 48
## TUTUM: the gradient bar's height, the knob's size, and how near the ends the knob may go.
const BAR_H := 6.0
const KNOB_PX := 14.0
const KNOB_EDGE := 0.03
const PATIENCE_PX := 14.0
const RESULT_CAPTION_W := 112.0
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
## Rows of the beats already played stay in the transcript at this alpha.
const PAST_ALPHA := 0.55
## A step long enough to finish any playback at once.
const SKIP_S := 3600.0
const PICK_KEYS := [KEY_1, KEY_2, KEY_3, KEY_4, KEY_5]
const PICK_KEYS_KP := [KEY_KP_1, KEY_KP_2, KEY_KP_3, KEY_KP_4, KEY_KP_5]
## The glyph beside a result's title, by its badge_palette band.
const RESULT_GLYPHS := {"positive": "✓", "negative": "✕"}
## Devam carries the key that presses it.
const ENTER_MARK := "  ⏎"

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
var _patience := {}

var _dock := PanelContainer.new()
var _kicker: Label
var _badge := HBoxContainer.new()
var _portrait := MarginContainer.new()
var _name: Label
var _role: Label
var _stars := HBoxContainer.new()
var _sub: Label
var _attitude_box := VBoxContainer.new()
var _gauge := Control.new()
var _word: Label
var _odds: Label
var _patience_box := VBoxContainer.new()
var _boxes := Control.new()
var _memory_box := VBoxContainer.new()
var _memory: Label
var _scroll := ScrollContainer.new()
var _flow := VBoxContainer.new()
var _deck_area := PanelContainer.new()
var _deck := VBoxContainer.new()
var _ruler: MeetingRuler
var _content := VBoxContainer.new()
var _footer := HBoxContainer.new()
var _withdraw := Button.new()
var _continue := Button.new()
var _tip := PanelContainer.new()
var _tip_col := VBoxContainer.new()
## TUTUM's knob, 0-100; the playback slides it.
var _needle := 0.0:
	set(value):
		_needle = value
		_gauge.queue_redraw()


func _init() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	_dock.theme_type_variation = &"MeetingDock"
	add_child(_dock)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 0)
	_dock.add_child(col)
	col.add_child(_build_header())
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
	# The header stands from the first line; the playback's own pass over it then changes nothing.
	_settle_header(step)
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

func _build_header() -> Control:
	var header := PanelContainer.new()
	header.theme_type_variation = &"MeetingHeader"
	var rows := VBoxContainer.new()
	header.add_child(rows)
	rows.add_theme_constant_override("separation", UiTokens.SPACE_L)

	var top := HBoxContainer.new()
	top.add_theme_constant_override("separation", UiTokens.SPACE_M)
	_kicker = UiFactory.make_label("", &"SectionAmber")
	_kicker.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_kicker.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(_kicker)
	top.add_child(_badge)
	rows.add_child(top)

	var person := HBoxContainer.new()
	person.add_theme_constant_override("separation", UiTokens.SPACE_L)
	rows.add_child(person)
	_portrait.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	person.add_child(_portrait)
	var about := VBoxContainer.new()
	about.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	about.add_theme_constant_override("separation", UiTokens.SPACE_M)
	person.add_child(about)
	var who := VBoxContainer.new()
	who.add_theme_constant_override("separation", UiTokens.SPACE_XXS)
	about.add_child(who)
	_name = UiFactory.make_label("", &"MeetingSpeakerName")
	_name.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	who.add_child(_name)
	var role_row := HBoxContainer.new()
	role_row.add_theme_constant_override("separation", UiTokens.SPACE_S)
	who.add_child(role_row)
	_role = UiFactory.make_label("", &"MeetingRole")
	_role.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_role.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	role_row.add_child(_role)
	_stars.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	role_row.add_child(_stars)
	_sub = UiFactory.make_label("", &"CaptionMuted")
	_sub.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_sub.hide()
	who.add_child(_sub)

	# TUTUM: the needle on its cold-to-warm bar and the band's word; a sales table adds its percent
	# and lists the reasons on hover.
	_attitude_box.add_theme_constant_override("separation", UiTokens.SPACE_XS)
	_attitude_box.add_child(UiFactory.make_label(tr("MEETING_ATTITUDE"), &"ColumnHeader"))
	_gauge.custom_minimum_size.y = KNOB_PX
	_gauge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_gauge.draw.connect(_draw_gauge)
	_attitude_box.add_child(_gauge)
	var word_row := HBoxContainer.new()
	_word = UiFactory.make_label("", &"MeetingAttitudeWord")
	_word.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	word_row.add_child(_word)
	# The percent reads in its own tone, which says it has more behind it: the reasons, on hover.
	_odds = UiFactory.make_label("", &"MeetingOdds")
	_odds.mouse_filter = Control.MOUSE_FILTER_PASS
	word_row.add_child(_odds)
	_attitude_box.add_child(word_row)
	about.add_child(_attitude_box)

	# At the price the patience boxes stand where TUTUM stood.
	_patience_box.add_theme_constant_override("separation", UiTokens.SPACE_XS)
	_patience_box.add_child(UiFactory.make_label(tr("NEG_PATIENCE"), &"ColumnHeader"))
	_boxes.draw.connect(_draw_patience)
	_boxes.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	_patience_box.add_child(_boxes)
	_patience_box.hide()
	about.add_child(_patience_box)

	_memory_box.add_theme_constant_override("separation", UiTokens.SPACE_XXS)
	_memory_box.add_child(UiFactory.make_label(tr("MEETING_MEMORY"), &"ColumnHeader"))
	_memory = UiFactory.make_label("", &"QuoteSerif")
	_memory.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_memory_box.add_child(_memory)
	_memory_box.hide()
	rows.add_child(_memory_box)
	return header


func _build_transcript() -> Control:
	_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_scroll.custom_minimum_size.y = TRANSCRIPT_MIN_H
	_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	# The transcript follows its newest row.
	var bar := _scroll.get_v_scroll_bar()
	bar.changed.connect(func() -> void: _scroll.scroll_vertical = int(bar.max_value))
	var margin := MarginContainer.new()
	margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	for side: String in ["left", "top", "right"]:
		margin.add_theme_constant_override("margin_" + side, UiTokens.SPACE_XL)
	margin.add_theme_constant_override("margin_bottom", UiTokens.SPACE_XXL)
	_scroll.add_child(margin)
	_flow.add_theme_constant_override("separation", UiTokens.SPACE_XL)
	margin.add_child(_flow)
	return _scroll


func _build_deck() -> Control:
	_deck_area.theme_type_variation = &"MeetingDeck"
	_deck.add_theme_constant_override("separation", UiTokens.SPACE_M)
	_deck_area.add_child(_deck)
	_content.add_theme_constant_override("separation", UiTokens.SPACE_S)
	_deck.add_child(_content)
	_footer.add_theme_constant_override("separation", UiTokens.SPACE_M)
	_footer.hide()
	_deck.add_child(_footer)
	# FOCUS_NONE: Space is the pause key, never a press of a focused button.
	_withdraw.text = tr("MEETING_WITHDRAW")
	_withdraw.focus_mode = Control.FOCUS_NONE
	_withdraw.pressed.connect(_withdraw_meeting)
	_footer.add_child(_withdraw)
	var push := Control.new()
	push.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	push.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_footer.add_child(push)
	_continue.theme_type_variation = &"CommitButton"
	_continue.focus_mode = Control.FOCUS_NONE
	_continue.pressed.connect(proceed)
	_footer.add_child(_continue)
	return _deck_area


## The die's tooltip over the deck. It grows upward from where it is placed, and takes no pointer.
func _build_tip() -> void:
	_tip.theme_type_variation = &"TooltipPanel"
	_tip.grow_vertical = Control.GROW_DIRECTION_BEGIN
	var pad := MarginContainer.new()
	for side: String in ["left", "top", "right", "bottom"]:
		pad.add_theme_constant_override("margin_" + side, UiTokens.SPACE_S)
	_tip.add_child(pad)
	_tip_col.add_theme_constant_override("separation", UiTokens.SPACE_M)
	pad.add_child(_tip_col)
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
## the header settles, and the deck takes what the step leaves on it.
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
		row.modulate.a = PAST_ALPHA
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
	_tween.tween_callback(_settle_header.bind(step))
	var attitude: Dictionary = step.get("attitude", {})
	if not attitude.is_empty():
		_tween.tween_property(self, "_needle", float(attitude.value), NEEDLE_S)
	_tween.tween_callback(_settle.bind(step))


## The other side, taken at once because the step's rows are built with their names: the people,
## the company, and a customer's stars, one-line read and condition badge.
func _frame(step: Dictionary) -> void:
	for person: Dictionary in step.get("cast", []):
		_people[person.seat] = person
	if step.has("company"):
		_company = step.company
	if step.has("identity"):
		var identity: Dictionary = step.identity
		UiFactory.clear(_stars)
		if identity.get("stars", 0) > 0:
			_stars.add_child(StarRating.make_stars(identity.stars, UiTokens.SIZE_SMALL))
		_sub.text = identity.get("sub", "")
		_sub.visible = _sub.text != ""
		UiFactory.clear(_badge)
		if identity.get("badge", "") != "":
			_badge.add_child(UiFactory.make_badge(identity.badge, &"accent"))


## Builds an entry's row, hidden, and queues its reveal: a spoken line types in while its speaker
## talks at the table, anything else fades in.
func _queue_entry(entry: Dictionary, roll: Dictionary) -> void:
	var seat: int = entry.get("seat", 0)
	var text: String = entry.text
	var line: Label
	var row: Control
	match entry.kind:
		"counterpart":
			line = _typed(text, &"MeetingLine")
			row = _counterpart_row(seat, line)
		"founder":
			line = _typed(text, &"MeetingFounderLine")
			row = _founder_row(entry.get("pill", ""), roll, line)
		"state":
			row = _state_row(seat, text)
		_:
			var quiet := UiFactory.make_label(text, &"QuoteSerif")
			quiet.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			row = quiet
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


## The header once the step is told: the beat, the speaker, TUTUM or the patience, the memory.
func _settle_header(step: Dictionary) -> void:
	if step.has("kicker"):
		_kicker.text = Fmt.upper(step.kicker)
	if step.has("speaker"):
		_speaker = step.speaker
		_show_person(_speaker)
		_cast.look(0, _speaker)
	if step.has("attitude"):
		var attitude: Dictionary = step.attitude
		_attitude_box.visible = not attitude.is_empty()
		if _attitude_box.visible:
			_word.text = tr(attitude.word_key)
			_word.add_theme_color_override("font_color", UiTokens.attitude_ink(attitude.band))
			_odds.text = attitude.get("odds_text", "")
			_odds.tooltip_text = "\n".join(PackedStringArray(attitude.get("hover", [])))
	if step.has("patience"):
		_patience = step.patience
		_patience_box.show()
		_boxes.custom_minimum_size = Vector2(
			_patience["max"] * (PATIENCE_PX + UiTokens.SPACE_XS) - UiTokens.SPACE_XS, PATIENCE_PX)
		_boxes.queue_redraw()
	if step.has("memory"):
		_memory.text = step.memory
		_memory_box.visible = _memory.text != ""


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
		_continue.text = tr(key) + ENTER_MARK
	_continue.visible = key != ""
	_withdraw.visible = step.get("can_withdraw", false)
	_footer.visible = _continue.visible or _withdraw.visible
	_live = not _cards.is_empty()


func _clear_deck() -> void:
	_set_options([])
	_footer.hide()


# ============================================================================
#  Header
# ============================================================================

func _show_person(seat: int) -> void:
	var person: Dictionary = _people[seat]
	UiFactory.clear(_portrait)
	_portrait.add_child(_avatar(seat, PORTRAIT_PX))
	_name.text = person.name
	_role.text = Fmt.upper(tr("MEETING_ROLE_LINE").format({"role": person.role, "company": _company}))


## A person's disc with the ring of their seat.
func _avatar(seat: int, px: int) -> Panel:
	var person: Dictionary = _people[seat]
	var disc := UiFactory.make_person_avatar(person.name, person.look, px)
	disc.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	var ring := Control.new()
	ring.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	ring.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var ink := UiTokens.seat_ring(seat)
	ring.draw.connect(func() -> void:
		ring.draw_arc(ring.size * 0.5, (px - UiTokens.BORDER_FOCUS) * 0.5, 0.0, TAU, RING_POINTS, ink,
			UiTokens.BORDER_FOCUS, true))
	disc.add_child(ring)
	return disc


func _draw_gauge() -> void:
	var top := (_gauge.size.y - BAR_H) * 0.5
	var half := _gauge.size.x * 0.5
	var stops := [UiTokens.ATTITUDE_COLD, UiTokens.ATTITUDE_MID, UiTokens.ATTITUDE_WARM]
	for i in 2:
		var x := half * i
		_gauge.draw_polygon(
			PackedVector2Array([Vector2(x, top), Vector2(x + half, top), Vector2(x + half, top + BAR_H),
				Vector2(x, top + BAR_H)]),
			PackedColorArray([stops[i], stops[i + 1], stops[i + 1], stops[i]]))
	var knob := Vector2(clampf(_needle / 100.0, KNOB_EDGE, 1.0 - KNOB_EDGE) * _gauge.size.x, _gauge.size.y * 0.5)
	_gauge.draw_circle(knob, KNOB_PX * 0.5, UiTokens.SURFACE_INPUT)
	_gauge.draw_arc(knob, (KNOB_PX - UiTokens.BORDER_FOCUS) * 0.5, 0.0, TAU, RING_POINTS, UiTokens.INK,
		UiTokens.BORDER_FOCUS, true)


## One box per round of patience: lit while it lasts, hollow once spent, and the last one left in
## the warning colour.
func _draw_patience() -> void:
	var left: int = _patience.current
	for i: int in _patience["max"]:
		var box := Rect2(i * (PATIENCE_PX + UiTokens.SPACE_XS), 0.0, PATIENCE_PX, PATIENCE_PX)
		if i >= left:
			_boxes.draw_rect(box.grow(-UiTokens.BORDER_HAIRLINE * 0.5), UiTokens.BORDER_HOVER, false,
				UiTokens.BORDER_HAIRLINE)
		else:
			_boxes.draw_rect(box, UiTokens.negative() if left == 1 else UiTokens.ACCENT)


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


func _counterpart_row(seat: int, line: Label) -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", UiTokens.SPACE_L)
	row.add_child(_avatar(seat, TRANSCRIPT_PX))
	var col := VBoxContainer.new()
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col.add_theme_constant_override("separation", UiTokens.SPACE_XXS)
	col.add_child(UiFactory.make_label(_display_name(seat), &"MeetingRole", UiTokens.seat_ink(seat)))
	col.add_child(line)
	row.add_child(col)
	return row


## The founder's move in a dark bubble: the name, the move's pill (in the verdict's colour when a
## die decided it) and the line.
func _founder_row(pill: String, roll: Dictionary, line: Label) -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", UiTokens.SPACE_L)
	row.add_child(_avatar(0, TRANSCRIPT_PX))
	var bubble := PanelContainer.new()
	bubble.theme_type_variation = &"MeetingFounderBubble"
	bubble.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", UiTokens.SPACE_S)
	bubble.add_child(col)
	var head := HBoxContainer.new()
	head.add_theme_constant_override("separation", UiTokens.SPACE_M)
	head.add_child(UiFactory.make_label(_display_name(0), &"MeetingFounderName"))
	if pill != "":
		var fill := UiTokens.INK_MUTED
		if not roll.is_empty():
			fill = UiTokens.positive() if roll.passed else UiTokens.negative()
		head.add_child(UiFactory.make_pill(pill, fill, UiTokens.ON_INK, false))
	col.add_child(head)
	col.add_child(line)
	row.add_child(bubble)
	return row


## A figure put on the table, where the price act has no speech: whose it is, then the figure.
func _state_row(seat: int, text: String) -> Control:
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", UiTokens.SPACE_XXS)
	col.add_child(UiFactory.make_label(_display_name(seat), &"MeetingRole", UiTokens.seat_ink(seat)))
	col.add_child(UiFactory.make_label(text, &"MeetingFigure"))
	return col


## A name as the transcript prints it: the founder by first name, the other side in full.
func _display_name(seat: int) -> String:
	var full: String = _people[seat].name
	return Fmt.upper(full.get_slice(" ", 0) if seat == 0 else full)



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


## ZAR ATILACAK over the deck while the pointer is on an option with a risk word: the risk and its
## odds, then what moves them.
func _on_hover(on: bool, card: OPTION) -> void:
	if not on or card.tip.is_empty():
		_tip.hide()
		return
	var dice: Dictionary = card.tip
	UiFactory.clear(_tip_col)
	var head := HBoxContainer.new()
	head.add_theme_constant_override("separation", UiTokens.SPACE_M)
	var title := UiFactory.make_label(tr("MEETING_DICE"), &"TooltipTitle")
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(title)
	head.add_child(UiFactory.make_pill(tr("MEETING_RISK_PCT").format({"risk": tr(dice.risk_key),
		"pct": roundi(dice.chance * 100.0)}), UiTokens.risk_ink(dice.chance), UiTokens.CREAM, false))
	_tip_col.add_child(head)
	var chips := HFlowContainer.new()
	chips.add_theme_constant_override("h_separation", UiTokens.SPACE_L)
	chips.add_theme_constant_override("v_separation", UiTokens.SPACE_S)
	# The folded "and more" line has no category and no sign.
	for factor: Dictionary in dice.factors:
		var chip := VBoxContainer.new()
		chip.add_theme_constant_override("separation", 0)
		if factor.cat_key != "":
			chip.add_child(UiFactory.make_label(tr(factor.cat_key), &"ZoneLabel"))
		var text: String = factor.text if factor.sign == "" else "%s %s" % [factor.sign, factor.text]
		chip.add_child(UiFactory.make_label(text, &"TooltipLabel", UiTokens.tooltip_tone_ink(factor.tone)))
		chips.add_child(chip)
	_tip_col.add_child(chips)
	HRUiShared.set_mouse_ignore(_tip)
	var deck := _deck_area.get_global_rect()
	deck.position -= global_position
	_tip.offset_left = deck.position.x + UiTokens.SPACE_XL
	_tip.offset_right = deck.end.x - UiTokens.SPACE_XL
	_tip.offset_top = deck.position.y - UiTokens.SPACE_M
	_tip.offset_bottom = _tip.offset_top
	_tip.show()


## The sitting's outcome: a band in its colour with the title, then what it leaves behind, row by
## row.
func _result_card(result: Dictionary) -> Control:
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", UiTokens.SPACE_M)
	var look := UiTokens.badge_palette(result.band)
	var band := MarginContainer.new()
	for side: String in ["left", "top", "right", "bottom"]:
		band.add_theme_constant_override("margin_" + side, UiTokens.SPACE_M)
	band.draw.connect(func() -> void: band.draw_rect(Rect2(Vector2.ZERO, band.size), look.bg))
	var head := HBoxContainer.new()
	head.add_theme_constant_override("separation", UiTokens.SPACE_M)
	var glyph: String = RESULT_GLYPHS.get(result.band, "")
	if glyph != "":
		# The serif face draws the check as a root sign; the sans one has it.
		head.add_child(UiFactory.make_label(glyph, &"MetricValueInk", look.fg))
	var title := UiFactory.make_label(tr(result.title_key), &"TitleSerif", look.fg)
	title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(title)
	band.add_child(head)
	col.add_child(band)
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
		col.add_child(HRUiShared.hairline())
		var line := HBoxContainer.new()
		line.add_theme_constant_override("separation", UiTokens.SPACE_L)
		var caption := UiFactory.make_label(tr(caption_key), &"ColumnHeader")
		caption.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		caption.custom_minimum_size.x = RESULT_CAPTION_W
		line.add_child(caption)
		var text := UiFactory.make_label(rows[caption_key], &"BodySerif")
		text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		line.add_child(text)
		col.add_child(line)
	return UiFactory.make_card(col)


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
