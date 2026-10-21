extends PanelContainer

# The office card on the city map: what an office is and brings, what its move costs today, and the
# move. Built for one office at the top right of the view; OfficeCity builds a new one when the
# pick or the language changes, and after every daily tick while the map is open, so today's
# readings stay today's.

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
	# The flat is never a move target, so the card of a move is any office but this one and the flat.
	var target := not current and office_id != "home"
	var upfront: int = OfficeSystem.upfront(office_id)
	var short := target and GameState.cash < upfront

	var thumb := TextureRect.new()
	thumb.texture = load("res://assets/art/office/thumb_%s.jpg" % office_id)
	thumb.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	thumb.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	thumb.custom_minimum_size.y = (WIDTH - 2.0 * UiTokens.SPACE_XL) / THUMB_ASPECT
	col.add_child(thumb)

	var head := HBoxContainer.new()
	col.add_child(head)
	# The flat is no step of the ladder (the map counts three tiers): its card names no tier, and the
	# empty label keeps the pill at the right.
	var tier := UiFactory.make_label("" if office_id == "home" else UiTokens.tr_upper(tr(office.tier_key)),
		&"MicroLabel")
	tier.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(tier)
	if current:
		head.add_child(UiFactory.make_pill(tr("OFFICE_STATUS_CURRENT"), UiTokens.BG_TOPBAR, UiTokens.CREAM, false))
	else:
		var look := UiTokens.badge_palette(&"negative" if short else &"positive")
		head.add_child(UiFactory.make_pill(tr("OFFICE_STATUS_BLOCKED" if short else "OFFICE_STATUS_MOVABLE"),
			look.bg, look.fg, false))
	col.add_child(UiFactory.make_label(tr(office.name_key), &"TitleSerif"))
	var desc := UiFactory.make_label(tr(office.desc_key), &"CaptionMuted")
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	col.add_child(desc)

	var rent: String = Fmt.money_exact(office.rent)
	var line: String
	if office_id == "home":
		line = tr("OFFICE_CARD_LINE_HOME").format({"desks": office.desks})
	elif current:
		line = tr("OFFICE_CARD_LINE_CURRENT").format({"desks": office.desks, "taken": OfficeSystem.desks_taken(),
			"rent": rent})
	else:
		line = tr("OFFICE_CARD_LINE").format({"desks": office.desks, "rent": rent})
	col.add_child(UiFactory.make_card(UiFactory.make_label(line, &"RowName"), true))

	col.add_child(UiFactory.make_section_header(tr("OFFICE_CARD_ROOMS")))
	var rooms := HFlowContainer.new()
	rooms.add_theme_constant_override("h_separation", UiTokens.SPACE_XS)
	rooms.add_theme_constant_override("v_separation", UiTokens.SPACE_XS)
	var plain := UiTokens.badge_palette(&"neutral")
	for key: String in office.room_keys:
		rooms.add_child(UiFactory.make_pill(tr(key), plain.bg, plain.fg, false))
	col.add_child(rooms)

	if target:
		col.add_child(UiFactory.make_section_header(tr("OFFICE_CARD_REQS")))
		col.add_child(_upfront_row(upfront))
		var costs: int = GameState.daily_burn * TimeModel.DAYS_PER_MONTH
		var tip := UiFactory.make_label(tr("OFFICE_MOVE_TIP").format({"rent": rent,
			"upfront": Fmt.money_exact(upfront), "old": Fmt.money_exact(costs),
			"new": Fmt.money_exact(costs + int(office.rent) - int(OfficeConstants.CATALOG[OfficeSystem.current()].rent))}),
			&"CaptionMuted")
		tip.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		col.add_child(tip)
		var team: int = OfficeSystem.desks_taken()
		if team > office.desks:
			var over := UiFactory.make_label(tr("OFFICE_MOVE_OVER_CAP").format({"team": team, "desks": office.desks}),
				&"CaptionMuted", UiTokens.badge_palette(&"accent").fg)
			over.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			col.add_child(over)

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
		var weeks := OfficeSystem.arrival_day() - GameState.day
		go.text = tr(Fmt.count_key("OFFICE_MOVING_BADGE", weeks)).format({"weeks": weeks})
	elif OfficeSystem.can_move_to(office_id):
		go.text = tr("OFFICE_CARD_MOVE_GO")
		go.disabled = false
		go.pressed.connect(move_pressed.emit)
	else:
		go.text = tr("OFFICE_CARD_UNMET_ONE")
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


## The row of the up-front rent: met or not against the cash today, with the cash on the right.
func _upfront_row(upfront: int) -> HBoxContainer:
	var ok := GameState.cash >= upfront
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", UiTokens.SPACE_M)
	row.add_child(UiFactory.make_label("✓" if ok else "✗", &"RowName", UiTokens.positive() if ok else UiTokens.negative()))
	var label := UiFactory.make_label(tr("OFFICE_REQ_CASH").format({"money": Fmt.money_exact(upfront)}), &"BodySerif")
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(label)
	row.add_child(UiFactory.make_label(tr("OFFICE_REQ_NOW").format({"value": Fmt.money_exact(GameState.cash)}), &"RowMeta"))
	return row
