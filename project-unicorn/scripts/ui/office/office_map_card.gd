extends PanelContainer

# The office card on the city map: what an office is and brings, what it would cost (shown,
# charged nowhere), what it asks for today, and the move. Built for one office at the top right
# of the view; OfficeCity builds a new one when the pick or the language changes.

signal cancel_pressed
signal move_pressed

const WIDTH := 340.0
const THUMB_ASPECT := 1.6        # the 480x300 thumbnails

var _content := MarginContainer.new()


func _init(office_id: String) -> void:
	theme_type_variation = &"WindowPanel"
	var scroll := ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(scroll)
	for side: String in ["left", "top", "right", "bottom"]:
		_content.add_theme_constant_override("margin_" + side, UiTokens.SPACE_XL)
	_content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(_content)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", UiTokens.SPACE_L)
	_content.add_child(col)

	var office: Dictionary = OfficeConstants.CATALOG[office_id]
	var current := office_id == OfficeSystem.current()
	var reqs: Array = OfficeSystem.requirement_state(office_id)
	var unmet := reqs.filter(func(r: Dictionary) -> bool: return not r.ok).size()
	var move_money: int = office.deposit + office.move_cost

	var thumb := TextureRect.new()
	thumb.texture = load("res://assets/art/office/thumb_%s.jpg" % office_id)
	thumb.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	thumb.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	thumb.custom_minimum_size.y = (WIDTH - 2.0 * UiTokens.SPACE_XL) / THUMB_ASPECT
	col.add_child(thumb)

	var head := HBoxContainer.new()
	col.add_child(head)
	var tier := UiFactory.make_label(UiTokens.tr_upper(tr(office.tier_key)), &"MicroLabel")
	tier.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(tier)
	if current:
		head.add_child(UiFactory.make_pill(tr("OFFICE_STATUS_CURRENT"), UiTokens.BG_TOPBAR, UiTokens.CREAM, false))
	else:
		var look := UiTokens.badge_palette(&"negative" if unmet > 0 else &"positive")
		head.add_child(UiFactory.make_pill(tr("OFFICE_STATUS_BLOCKED" if unmet > 0 else "OFFICE_STATUS_MOVABLE"),
			look.bg, look.fg, false))
	col.add_child(UiFactory.make_label(tr(office.name_key), &"TitleSerif"))
	var desc := UiFactory.make_label(tr(office.desc_key), &"CaptionMuted")
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	col.add_child(desc)

	# A cost of nothing is an empty cell: the design's dash never reaches the screen.
	var cells := HBoxContainer.new()
	for cell: Array in [["OFFICE_CARD_DESKS", str(office.desks)],
			["OFFICE_CARD_RENT", UiTokens.format_money(office.rent) if office.rent > 0 else ""],
			["OFFICE_CARD_MOVE", UiTokens.format_money(move_money) if move_money > 0 else ""]]:
		var stat := UiFactory.make_stat(tr(cell[0]), cell[1])
		stat.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		cells.add_child(stat)
	col.add_child(UiFactory.make_card(cells, true))
	col.add_child(UiFactory.make_label(tr("OFFICE_CARD_MOVE_FREE") if office.rent + move_money == 0
		else tr("OFFICE_CARD_MOVE_NOTE").format({"deposit": UiTokens.format_money(office.deposit),
			"move": UiTokens.format_money(office.move_cost)}), &"RowMeta"))

	col.add_child(UiFactory.make_section_header(tr("OFFICE_CARD_ROOMS")))
	var rooms := HFlowContainer.new()
	rooms.add_theme_constant_override("h_separation", UiTokens.SPACE_XS)
	rooms.add_theme_constant_override("v_separation", UiTokens.SPACE_XS)
	var plain := UiTokens.badge_palette(&"neutral")
	for key: String in office.room_keys:
		rooms.add_child(UiFactory.make_pill(tr(key), plain.bg, plain.fg, false))
	col.add_child(rooms)

	if not reqs.is_empty():
		col.add_child(UiFactory.make_section_header(tr("OFFICE_CARD_REQS")))
		for r: Dictionary in reqs:
			col.add_child(_requirement_row(r))

	var actions := HBoxContainer.new()
	actions.add_theme_constant_override("separation", UiTokens.SPACE_M)
	col.add_child(actions)
	var cancel := Button.new()
	cancel.text = tr("OFFICE_CARD_CANCEL")
	# Space must not land on a card button: game_shell reads Space as the pause key.
	cancel.focus_mode = Control.FOCUS_NONE
	cancel.pressed.connect(cancel_pressed.emit)
	actions.add_child(cancel)
	var go := Button.new()
	go.theme_type_variation = &"CommitButton"
	go.focus_mode = Control.FOCUS_NONE
	go.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	go.disabled = true
	if current:
		go.text = tr("OFFICE_CARD_HERE")
	elif OfficeSystem.is_moving():
		var days := OfficeSystem.arrival_day() - GameState.day
		go.text = tr("OFFICE_MOVING_BADGE_ONE") if days == 1 else tr("OFFICE_MOVING_BADGE").format({"days": days})
	elif OfficeSystem.can_move_to(office_id):
		go.text = tr("OFFICE_CARD_MOVE_FOR").format({"money": UiTokens.format_money(move_money)})
		go.disabled = false
		go.pressed.connect(move_pressed.emit)
	else:
		go.text = tr("OFFICE_CARD_UNMET_ONE") if unmet == 1 else tr("OFFICE_CARD_UNMET").format({"n": unmet})
	actions.add_child(go)


func _ready() -> void:
	_content.minimum_size_changed.connect(_fit)
	get_parent().resized.connect(_fit)
	_fit()


## Top right, as tall as its content up to the view's height; the rest scrolls.
func _fit() -> void:
	var room := get_parent_area_size()
	size = Vector2(WIDTH, minf(_content.get_combined_minimum_size().y + get_combined_minimum_size().y,
		room.y - 2.0 * UiTokens.SPACE_XL))
	position = Vector2(room.x - size.x - UiTokens.SPACE_XL, UiTokens.SPACE_XL)


func _requirement_row(r: Dictionary) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", UiTokens.SPACE_M)
	row.add_child(UiFactory.make_label("✓" if r.ok else "✗", &"RowName",
		UiTokens.positive() if r.ok else UiTokens.negative()))
	var text: String
	var now: String = tr("OFFICE_REQ_NOW").format({"value": UiTokens.format_money(r.now) if r.kind == "cash" else str(r.now)})
	match r.kind:
		"angel":
			text = tr("OFFICE_REQ_ANGEL")
			now = tr("OFFICE_REQ_NOW_CLOSED" if r.now else "OFFICE_REQ_NOW_OPEN")
		"team":
			text = tr("OFFICE_REQ_TEAM").format({"n": r.value})
		"cash":
			text = tr("OFFICE_REQ_CASH").format({"money": UiTokens.format_money(r.value)})
		"brand":
			text = tr("OFFICE_REQ_BRAND").format({"n": r.value})
	var label := UiFactory.make_label(text, &"BodySerif")
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(label)
	row.add_child(UiFactory.make_label(now, &"RowMeta"))
	return row
