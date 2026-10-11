extends OnboardingStep

# Step 3, Şirket: the company's name and its logo, a style LogoEmblem draws from the name's initial. The first-week
# document's letterhead shows both as they are picked; Found and start commits from here.

const NAME_W := 520
const EMBLEM := 56

var _logo_style := ""
var _name_input: LineEdit
var _style_cards := {}   # style_id -> PanelContainer
var _emblems: Array[LogoEmblem] = []


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

	page.add_child(UiFactory.make_label(Fmt.upper(tr("ONB_LOGO_LABEL")), &"KeyLabel"))
	var cards := HBoxContainer.new()
	cards.add_theme_constant_override("separation", UiTokens.SPACE_XL)
	page.add_child(cards)
	for style: Dictionary in FounderConstants.LOGO_STYLES:
		cards.add_child(_style_card(style))


func _style_card(style: Dictionary) -> PanelContainer:
	var col := VBoxContainer.new()
	col.alignment = BoxContainer.ALIGNMENT_CENTER
	col.add_theme_constant_override("separation", UiTokens.SPACE_M)
	col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var card := _card(col, true)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var emblem := LogoEmblem.new(EMBLEM)
	emblem.style_id = style.id
	emblem.mouse_filter = Control.MOUSE_FILTER_IGNORE
	emblem.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	col.add_child(emblem)
	_emblems.append(emblem)
	var label := UiFactory.make_label(tr(style.name_key), &"KeyLabel")
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(label)
	card.gui_input.connect(func(event: InputEvent) -> void:
		if UiFactory.is_left_click(event):
			_logo_style = style.id
			_refresh()
			changed.emit())
	_style_cards[style.id] = card
	return card


func _refresh() -> void:
	for style_id: String in _style_cards:
		show_pick(_style_cards[style_id], style_id == _logo_style)
	for emblem in _emblems:
		emblem.configure(emblem.style_id, _name_input.text)


# --- OnboardingStep contract ---

func prefill(draft: Dictionary) -> void:
	_name_input.text = draft.get("company_name", "")
	_logo_style = draft.get("logo_style", "")
	_refresh()


func invalid_reason() -> String:
	if _name_input.text.strip_edges() == "":
		return tr("ONB_WHY_COMPANY")
	if _logo_style == "":
		return tr("ONB_WHY_LOGO")
	return ""


func collect_payload() -> Dictionary:
	return {"company_name": _name_input.text.strip_edges(), "logo_style": _logo_style}
