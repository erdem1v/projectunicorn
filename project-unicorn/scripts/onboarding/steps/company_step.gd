extends OnboardingStep

# Step 3, Şirket: the company's name and its emblem, one of the twelve LogoEmblem makes from the name; Make new set
# rerolls them, and a new name keeps the pick's place. The first-week document's letterhead shows both as they are
# picked; Found and start commits from here.

const NAME_W := 520
const COLUMNS := 6
const TILE_H := [160, 116]
const EMBLEM := [104, 80]

var _name_input: LineEdit
var _reroll := 0
var _pick := -1
var _set := []   # the emblems on offer
var _emblems: Array[LogoEmblem] = []
var _tiles: Array[PanelContainer] = []


func _ready() -> void:
	var page := VBoxContainer.new()
	page.set_anchors_preset(Control.PRESET_FULL_RECT)
	page.add_theme_constant_override("separation", UiTokens.SPACE_XL)
	add_child(page)
	page.add_child(_head("ONB_STEP_COMPANY", "ONB_STEP3_INTRO"))

	page.add_child(UiFactory.make_label(Fmt.upper(tr("ONB_COMPANY_LABEL")), &"KeyLabel"))
	_name_input = LineEdit.new()
	_name_input.custom_minimum_size.x = NAME_W
	_name_input.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	_name_input.max_length = 40
	_name_input.placeholder_text = tr("ONB_COMPANY_PLACEHOLDER")
	_name_input.text_changed.connect(func(_t: String) -> void:
		_refresh()
		changed.emit())
	page.add_child(_name_input)

	var logo_head := HBoxContainer.new()
	var caption := VBoxContainer.new()
	caption.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	caption.add_child(UiFactory.make_label(Fmt.upper(tr("ONB_LOGO_LABEL")), &"KeyLabel"))
	caption.add_child(UiFactory.make_label(tr("ONB_LOGO_CAPTION"), &"Caption"))
	logo_head.add_child(caption)
	var reroll := Button.new()
	reroll.theme_type_variation = &"SecondaryButtonSmall"
	reroll.text = tr("ONB_LOGO_REROLL")
	reroll.icon = load("res://assets/icons/util/dice.svg")
	reroll.size_flags_vertical = Control.SIZE_SHRINK_END
	reroll.pressed.connect(func() -> void:
		_reroll += 1
		_refresh()
		changed.emit())
	logo_head.add_child(reroll)
	page.add_child(logo_head)

	var grid := GridContainer.new()
	grid.columns = COLUMNS
	grid.add_theme_constant_override("h_separation", UiTokens.SPACE_XL)
	grid.add_theme_constant_override("v_separation", UiTokens.SPACE_XL)
	page.add_child(grid)
	for i in LogoEmblem.CANDIDATES:
		var emblem := LogoEmblem.new(EMBLEM[int(short)])
		emblem.mouse_filter = Control.MOUSE_FILTER_IGNORE
		emblem.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		emblem.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		_emblems.append(emblem)
		var tile := _card(emblem, true)
		tile.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		tile.custom_minimum_size.y = TILE_H[int(short)]
		tile.gui_input.connect(func(event: InputEvent) -> void:
			if UiFactory.is_left_click(event):
				_pick = i
				_refresh()
				changed.emit())
		_tiles.append(tile)
		grid.add_child(tile)


func _refresh() -> void:
	_set = LogoEmblem.candidates(_name_input.text.strip_edges(), _reroll)
	for i in _tiles.size():
		show_pick(_tiles[i], i == _pick)
		_emblems[i].configure(_set[i])


# --- OnboardingStep contract ---

func prefill(draft: Dictionary) -> void:
	_name_input.text = draft.get("company_name", "")
	_reroll = draft.get("logo_reroll", 0)
	_pick = LogoEmblem.candidates(_name_input.text.strip_edges(), _reroll).find(draft.get("logo", {}))
	_refresh()


func invalid_reason() -> String:
	if _name_input.text.strip_edges() == "":
		return tr("ONB_WHY_COMPANY")
	if _pick < 0:
		return tr("ONB_WHY_LOGO")
	return ""


func collect_payload() -> Dictionary:
	return {"company_name": _name_input.text.strip_edges(), "logo": _set[_pick] if _pick >= 0 else {},
		"logo_reroll": _reroll}
