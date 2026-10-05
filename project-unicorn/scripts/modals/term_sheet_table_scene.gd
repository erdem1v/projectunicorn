class_name TermSheetTableScene
extends Control

# The term sheet table, a full-screen scene over TermSheetTableSystem. The head band names who holds the
# sheet (face, name, title and fund, the fund's manner), the offer's time left and the table's patience; on
# the body the sheet and its levers stand on the left, and on the right the push dial over what the last
# move did, the fund's word, the other offer and Frank's word; the foot band holds the walk, the money and
# the signature. It paints the system's view_state through one _render() and routes the clicks back (select
# a lever, push, show the other offer, sign, walk, leave): every number and rule is the system's. The bands
# run the screen's width; their content and the body's sit in one column, D_STAGE wide or the screen less
# its margins. A body taller than the screen scrolls between the bands.
#
# The .tscn root carries the dark theme, process_mode ALWAYS (live on the paused tree), the full-rect anchors
# and the click-eating mouse filter. Buttons take no focus; keys 1-3 select a lever and a blind Enter or
# Space does nothing.

signal closed()

const OPEN_S := 0.18   # the scene fades in over this long
const LEVER_KEYS := [KEY_1, KEY_2, KEY_3]
const LEVER_KEYS_KP := [KEY_KP_1, KEY_KP_2, KEY_KP_3]

var _columns: Array[MarginContainer] = []   # the bands' and the body's: their sides centre the column
var _due: PanelContainer
var _due_glyph: TextureRect
var _due_line: Label
var _patience := HBoxContainer.new()
var _rows: Array[Dictionary] = []   # one per lever: {id, row, now, arrow, ghost, odds, push}
var _dial := RadialDial.new()
var _pct: Label
var _last_roll: Control
var _result: Label
var _say := PanelContainer.new()
var _say_line: Label
var _other: VBoxContainer
var _other_text: Label
var _other_button: Button
var _other_why: Label
var _frank: Label
var _walk: Button
var _walk_why: Label
var _money: Label
var _derived: Label
var _cash: Label
var _sign: Button

var _spinning := false
var _leave_mode := false   # the fund walked out; the walk key now only leaves the room
var _pending_vs := {}


func _ready() -> void:
	# main opens the system before it mounts this scene, so the table is already set.
	var vs: Dictionary = TermSheetTableSystem.view_state()
	var ground := ColorRect.new()
	ground.color = UiTokens.D_SURFACE_0
	ground.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ground.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(ground)
	var bands := SprintUiShared.column(0)
	bands.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bands)
	bands.add_child(_band(&"StageHead", UiTokens.D_H_STAGE_HEAD, _build_head(vs)))
	var scroll := ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.add_child(_in_column(_build_body(vs), UiTokens.D_STAGE.z, UiTokens.SPACE_3XL))
	bands.add_child(scroll)
	bands.add_child(_band(&"StageFoot", UiTokens.D_H_STAGE_FOOT, _build_foot()))
	resized.connect(_fit_columns)
	_fit_columns()
	_dial.spin_finished.connect(_on_spin_finished)
	modulate.a = 0.0
	create_tween().tween_property(self, "modulate:a", 1.0, OPEN_S)
	_render(vs)


# ============================================================================
# Build
# ============================================================================

## A band the screen's width, its content in the column.
func _band(look: StringName, height: int, content: Control) -> PanelContainer:
	var band := PanelContainer.new()
	band.theme_type_variation = look
	band.custom_minimum_size.y = height
	band.add_child(_in_column(content, 0, 0))
	return band


## `content` in the column, with `top` and `bottom` above and below it.
func _in_column(content: Control, top: int, bottom: int) -> MarginContainer:
	var column := SprintUiShared.pad(content, Vector4i(0, top, 0, bottom))
	column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_columns.append(column)
	return column


## The column is D_STAGE wide, or the screen less its margins, and centred.
func _fit_columns() -> void:
	var side := int(maxf((size.x - UiTokens.D_STAGE.x) * 0.5, UiTokens.D_STAGE.z))
	for column in _columns:
		column.add_theme_constant_override("margin_left", side)
		column.add_theme_constant_override("margin_right", side)


func _build_head(vs: Dictionary) -> HBoxContainer:
	var head := SprintUiShared.box(UiTokens.SPACE_XXL)
	var lead: Dictionary = vs.lead
	var face := UiFactory.make_person_avatar(lead.name, lead.look, UiTokens.D_AVATAR_NOTE)
	head.add_child(face)
	var who := SprintUiShared.column(UiTokens.SPACE_XXS)
	who.alignment = BoxContainer.ALIGNMENT_CENTER
	who.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	who.add_child(UiFactory.make_label(lead.name, &"TitleH2"))
	who.add_child(UiFactory.make_label(tr("MEETING_ROLE_LINE").format({"role": lead.title, "company": vs.display_name}),
		&"MetaText"))
	who.add_child(UiFactory.make_label(vs.archetype_line, &"MetaMuted"))
	head.add_child(who)
	# The offer's time left as the top bar's slot reads it.
	var due := SprintUiShared.box(UiTokens.SPACE_M)
	_due_glyph = UiFactory.make_glyph(SprintUiShared.CLOCK, UiTokens.D_ICON_BUTTON, UiTokens.D_warn())
	due.add_child(_due_glyph)
	_due_line = SprintUiShared.label("", &"KeyText")
	due.add_child(_due_line)
	_due = _kpi(due)
	head.add_child(_due)
	var patience := SprintUiShared.column(UiTokens.SPACE_S)
	patience.alignment = BoxContainer.ALIGNMENT_CENTER
	patience.add_child(UiFactory.make_label(Fmt.upper(tr("TERM_PATIENCE")), &"KeyLabel"))
	patience.add_child(_patience)
	head.add_child(_kpi(patience))
	return head


## A figure of the head, behind its rule.
func _kpi(content: Control) -> PanelContainer:
	var cell := PanelContainer.new()
	cell.theme_type_variation = &"StageKpi"
	content.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	cell.add_child(content)
	return cell


func _build_body(vs: Dictionary) -> HBoxContainer:
	var body := SprintUiShared.box(UiTokens.D_STAGE.z)
	var offer := SprintUiShared.column(UiTokens.SPACE_L)
	offer.custom_minimum_size.x = UiTokens.D_STAGE.y
	offer.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	offer.add_child(UiFactory.make_label(Fmt.upper(tr("TERM_OFFER_HEADER")), &"KeyLabel"))
	var sheet := PanelContainer.new()
	sheet.theme_type_variation = &"SheetDoc"
	var levers := SprintUiShared.column(0)
	sheet.add_child(levers)
	for i in vs.levers.size():
		if i > 0:
			levers.add_child(HRUiShared.hairline(UiTokens.D_LINE_1))
		levers.add_child(_build_lever(vs.levers[i], i + 1))
	offer.add_child(sheet)
	body.add_child(offer)
	body.add_child(_build_odds(vs))
	return body


## A lever's row: its key (a lock while it is closed), its name, the term now and what a won push makes it, the
## odds behind the push, and on the selected row the push. A closed lever reads off whole.
func _build_lever(lever: Dictionary, number: int) -> PanelContainer:
	var row := HRUiShared.D_row(false, &"LeverRow")
	row.custom_minimum_size.y = UiTokens.D_H_LEVER
	row.gui_input.connect(_on_lever_input.bind(lever.id))
	var line := SprintUiShared.box(UiTokens.SPACE_XXL)
	line.add_child(UiFactory.D_key_cap(0 if lever.locked else number))
	var col := SprintUiShared.column(UiTokens.SPACE_S)
	col.alignment = BoxContainer.ALIGNMENT_CENTER
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var off: Variant = UiTokens.D_INK_OFF if lever.locked else null
	col.add_child(UiFactory.make_label(Fmt.upper(lever.name_tr), &"KeyLabel", off))
	var values := SprintUiShared.box(UiTokens.SPACE_L)
	var now := UiFactory.make_label("", &"HeroValue", off)
	var arrow := UiFactory.make_label("→", &"HeroArrow", off)
	var ghost := UiFactory.make_label("", &"HeroValue", UiTokens.D_INK_OFF if lever.locked else UiTokens.D_INK_3)
	for part: Label in [now, arrow, ghost]:
		values.add_child(part)
	col.add_child(values)
	var odds := UiFactory.make_label("", &"MetaMuted")
	col.add_child(odds)
	line.add_child(col)
	var push := SprintUiShared.button(tr("TERM_PUSH"), &"SecondaryButton", _on_push_pressed)
	line.add_child(push)
	var inset := SprintUiShared.pad(line, Vector4i(UiTokens.SPACE_XXL, UiTokens.SPACE_XXL, UiTokens.SPACE_3XL, UiTokens.SPACE_XXL))
	HRUiShared.set_mouse_ignore(inset)
	push.mouse_filter = Control.MOUSE_FILTER_STOP
	row.add_child(inset)
	_rows.append({"id": lever.id, "row": row, "now": now, "arrow": arrow, "ghost": ghost, "odds": odds, "push": push})
	return row


## The dial and what the table said: the result of the last move, the fund's word, the other offer, Frank.
func _build_odds(vs: Dictionary) -> VBoxContainer:
	var col := SprintUiShared.column(UiTokens.SPACE_XL)
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col.add_child(UiFactory.make_label(Fmt.upper(tr("TERM_RESULT_HEADER")), &"KeyLabel"))
	var dial := SprintUiShared.column(UiTokens.SPACE_M)
	dial.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	dial.add_child(_dial)
	_pct = UiFactory.make_label("", &"HeroValue")
	_pct.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	dial.add_child(_pct)
	# The key under it: the arc is the push's chance, the needle the last roll once there is one.
	var key := SprintUiShared.box(UiTokens.SPACE_XXL)
	key.alignment = BoxContainer.ALIGNMENT_CENTER
	key.add_child(_key_part(UiTokens.D_KEY_ARC, UiTokens.D_BAR_EMPH, "TERM_DIAL_CHANCE"))
	_last_roll = _key_part(UiTokens.D_KEY_NEEDLE, UiTokens.D_INK_1, "TERM_DIAL_ROLL")
	key.add_child(_last_roll)
	dial.add_child(key)
	col.add_child(dial)
	_result = SprintUiShared.prose("", &"SubjectStrong")
	_result.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(_result)
	# The fund's own line after each move: the only window onto how eager they are.
	_say.theme_type_variation = &"SayBox"
	var lead: Dictionary = vs.lead
	_say_line = UiFactory.make_label("", &"SayLine")
	_say.add_child(UiFactory.D_said(UiFactory.make_person_avatar(lead.name, lead.look, UiTokens.D_AVATAR_ROW),
		lead.name, _say_line))
	col.add_child(_say)
	# The other live sheet: in the pocket, then on the table once shown.
	_other = SprintUiShared.column(UiTokens.SPACE_XS)
	var other := PanelContainer.new()
	other.theme_type_variation = &"OtherDoc"
	var row := SprintUiShared.box(UiTokens.SPACE_L)
	_other_text = SprintUiShared.prose("", &"MetaText")
	row.add_child(_other_text)
	_other_button = SprintUiShared.button(tr("TERM_SHOW_OTHER"), &"GhostButtonSmall", _on_show_other_pressed)
	row.add_child(_other_button)
	other.add_child(row)
	_other.add_child(other)
	_other_why = UiFactory.make_label(tr("TERM_SHOW_OTHER_USED"), &"Caption")
	_other_why.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_other.add_child(_other_why)
	col.add_child(_other)
	var frank := SprintUiShared.column(UiTokens.SPACE_XL)
	frank.add_child(HRUiShared.hairline(UiTokens.D_LINE_1))
	_frank = UiFactory.make_label("", &"FrankQuote", UiTokens.D_INK_1)
	frank.add_child(UiFactory.D_said(UiFactory.make_mentor_avatar(UiTokens.D_AVATAR_CARD), tr("MENTOR_NAME"), _frank,
		UiTokens.SPACE_XL, UiTokens.SPACE_XS))
	col.add_child(frank)
	return col


## A part of the dial's key: a sample of the mark and its word.
func _key_part(sample: Vector2i, ink: Color, key: String) -> HBoxContainer:
	var part := SprintUiShared.box(UiTokens.SPACE_M)
	var mark := ColorRect.new()
	mark.color = ink
	mark.custom_minimum_size = sample
	mark.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	part.add_child(mark)
	part.add_child(UiFactory.make_label(tr(key), &"Caption"))
	return part


## The walk with its reason when it is closed, the money with what it is worth, the signature.
func _build_foot() -> HBoxContainer:
	var foot := SprintUiShared.box(0)
	var left := SprintUiShared.box(UiTokens.SPACE_L)
	left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_walk = SprintUiShared.button("", &"DangerButton", _on_walk_pressed)
	left.add_child(_walk)
	_walk_why = SprintUiShared.label("", &"Caption")
	left.add_child(_walk_why)
	foot.add_child(left)
	var money := SprintUiShared.column(UiTokens.SPACE_XXS)
	money.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_money = UiFactory.make_label("", &"HeroValue")
	_derived = UiFactory.make_label("", &"Caption")
	_cash = UiFactory.make_label("", &"Caption")
	for line: Label in [_money, _derived, _cash]:
		line.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		money.add_child(line)
	foot.add_child(money)
	var right := SprintUiShared.box(0)
	right.alignment = BoxContainer.ALIGNMENT_END
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_sign = SprintUiShared.button(tr("TERM_SIGN_OK"), &"PrimaryButtonDarkLarge", _on_sign_pressed)
	_sign.custom_minimum_size.x = UiTokens.D_W_SIGN
	right.add_child(_sign)
	foot.add_child(right)
	return foot


# ============================================================================
# Render: the one paint of a view_state
# ============================================================================

func _render(vs: Dictionary) -> void:
	_due.visible = vs.weeks_left >= 0
	if _due.visible:
		var offer: Dictionary = UiTokens.D_offer_reading(vs.weeks_left)
		_due_line.text = offer.text
		_due_line.add_theme_color_override("font_color", offer.ink)
		_due_glyph.modulate = offer.ink
	UiFactory.clear(_patience)
	_patience.add_child(UiFactory.D_patience(vs.patience.current, vs.patience["max"], UiTokens.D_PATIENCE.y))
	for i in _rows.size():
		_render_lever(_rows[i], vs.levers[i], vs.levers[i].id == vs.selected_lever)
	var dial: Dictionary = vs.dial
	if dial.result == "":
		_dial.set_odds(dial.chance)
	else:
		_dial.show_result_rest(dial.chance, dial.result == "success")
	_pct.text = Fmt.percent(roundi(dial.chance * 100.0), 0)
	_last_roll.visible = dial.result != ""
	# Red only when the fund leaves; the final offer is a warning; a refusal is not a danger.
	_result.text = vs.result_caption
	_result.add_theme_color_override("font_color", {TermSheetTableSystem.FUND_WALKED: UiTokens.D_neg(),
		TermSheetTableSystem.PATIENCE_ZERO: UiTokens.D_warn()}.get(vs.state, UiTokens.D_INK_1))
	_say.visible = vs.investor_line != ""
	_say_line.text = vs.investor_line
	var show_other: Dictionary = vs.show_other
	_other.visible = vs.leverage.active
	_other_text.text = vs.leverage.box_text
	_other_button.visible = show_other.visible
	_other_button.disabled = not show_other.enabled or _spinning
	_other_why.visible = show_other.used
	_frank.text = vs.frank_line
	# After a walk-out the same key is the only exit, and it only leaves: the fund closed the door when it
	# stood up. A walk the run cannot take yet stays on the bar, closed, with its reason beside it.
	_leave_mode = vs.walk_mode == "leave"
	var lock: Dictionary = vs.walk_lock
	_walk.text = tr("TERM_LEAVE" if _leave_mode else "TERM_WALK_OK")
	_walk.theme_type_variation = &"SecondaryButton" if _leave_mode else UiTokens.D_variation(&"DangerButton")
	_walk.icon = load(SprintUiShared.LOCK) if lock.locked else null
	_walk.disabled = not vs.walk_enabled or _spinning
	_walk_why.text = tr(lock.reason_key) if lock.locked else ""
	_money.text = tr("TERM_INVESTMENT").format({"amount": Fmt.money(int(vs.money_raised))})
	_derived.text = vs.derived_caption
	_derived.visible = _derived.text != ""
	var footer: Dictionary = vs.footer
	_cash.text = footer.kasa_runway_text if footer.counter_text == "" else tr("MEETING_RES_PAIR").format(
		{"first": footer.kasa_runway_text, "second": footer.counter_text})
	_sign.disabled = not vs.sign_enabled or _spinning


## A lever's row: the selection, the term now and what a won push makes it, the odds, and the push on the
## selected open row.
func _render_lever(row: Dictionary, lever: Dictionary, selected: bool) -> void:
	HRUiShared.D_select_row(row.row, selected)
	row.now.text = lever.current_text
	row.ghost.text = lever.ghost_text
	row.arrow.visible = lever.ghost_text != ""
	row.odds.text = lever.odds.split_text
	row.push.visible = selected and not lever.locked
	row.push.disabled = not lever.push_enabled or _spinning


# ============================================================================
# Interaction: back into the system (select, push, show the other offer, sign, walk, leave)
# ============================================================================

func _on_lever_input(event: InputEvent, lever: String) -> void:
	if not _spinning and UiFactory.is_left_click(event):
		_render(TermSheetTableSystem.select_lever(lever))


## The selected lever's push: the system rolls and settles it at once, the dial plays it.
func _on_push_pressed() -> void:
	if _spinning:
		return
	# The odds the roll is made on, before this push's own decay.
	var chance: float = TermSheetTableSystem.view_state().dial.chance
	_spinning = true
	for row in _rows:
		row.push.disabled = true
	_pending_vs = TermSheetTableSystem.push()
	_dial.spin(chance, _pending_vs.dial.result == "success")


func _on_spin_finished() -> void:
	_spinning = false
	_render(_pending_vs)


func _on_sign_pressed() -> void:
	if _spinning:
		return
	var vs: Dictionary = TermSheetTableSystem.view_state()
	EventBus.confirm_requested.emit({
		"title": tr("TERM_SIGN_Q"),
		"body": tr("TERM_SIGN_BODY").format({
			"amount": Fmt.money(int(vs.money_raised)),
			"terms": " · ".join(PackedStringArray(vs.levers.map(func(lever: Dictionary) -> String: return lever.current_text)))}),
		"confirm_text": tr("TERM_SIGN_OK"),
		"cancel_text": tr("UI_DISMISS"),
		"on_confirm": _do_sign,
	})


func _do_sign() -> void:
	TermSheetTableSystem.sign()   # Series A fires the Hard Win ending; seed closes the round (no ending)
	closed.emit()


func _on_walk_pressed() -> void:
	if _spinning:
		return
	if _leave_mode:
		TermSheetTableSystem.leave()   # nothing to confirm: the fund already closed the door
		closed.emit()
		return
	EventBus.confirm_requested.emit({
		"title": tr("TERM_WALK_Q"),
		"body": tr("TERM_WALK_BODY"),
		"confirm_text": tr("TERM_WALK_OK"),
		"cancel_text": tr("UI_DISMISS"),
		"on_confirm": _do_walk,
	})


func _do_walk() -> void:
	TermSheetTableSystem.walk()   # sheet destroyed, fund closed, others survive; the player's walk is not a rejection
	closed.emit()


func _on_show_other_pressed() -> void:
	if not _spinning:
		_render(TermSheetTableSystem.show_other_offer())


func _input(event: InputEvent) -> void:
	var key := event as InputEventKey
	if _spinning or key == null or not key.pressed or key.echo:
		return
	var i := maxi(LEVER_KEYS.find(key.keycode), LEVER_KEYS_KP.find(key.keycode))
	if i >= 0 and i < _rows.size():
		get_viewport().set_input_as_handled()
		_render(TermSheetTableSystem.select_lever(_rows[i].id))
