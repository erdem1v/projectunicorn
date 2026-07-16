extends OnboardingStep

# Page 3 — Şirket. Company name + logo style (LogoEmblem auto-renders the
# name's initial per style — no image assets) + optional slogan + live preview
# (emblem + name + founder portrait + KURUCU · start year). "Kur ve Başla" on
# the controller commits from here — there is no separate confirm page.
#
# Founder name moved to Page 1; this step reads it (and the portrait) from the
# draft via prefill for the preview only.

var _logo_style: String = ""
var _founder_name: String = ""
var _portrait_id: String = ""

var _name_input: LineEdit = null
var _slogan_input: LineEdit = null
var _style_cards: Dictionary = {}      # style_id -> PanelContainer
var _card_emblems: Array[LogoEmblem] = []
var _preview_emblem: LogoEmblem = null
var _preview_name: Label = null
var _preview_founder: Label = null
var _preview_portrait: TextureRect = null


func _ready() -> void:
	_build()
	_refresh_visual()


func _build() -> void:
	var page := VBoxContainer.new()
	page.set_anchors_preset(Control.PRESET_FULL_RECT)
	page.add_theme_constant_override("separation", 6)
	add_child(page)

	page.add_child(UiFactory.make_label(tr("ONB_P3_TITLE"), &"TitleSerifCream"))
	page.add_child(UiFactory.make_label(tr("ONB_P3_SUB"), &"SubtitleSerifCream"))
	page.add_child(_spacer(10))

	var content := HBoxContainer.new()
	content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 28)
	page.add_child(content)

	# --- Left: fields ---
	var left := VBoxContainer.new()
	left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left.size_flags_stretch_ratio = 1.6
	left.add_theme_constant_override("separation", 8)
	content.add_child(left)

	left.add_child(UiFactory.make_label(tr("ONB_COMPANY_LABEL"), &"ZoneLabel"))
	_name_input = LineEdit.new()
	_name_input.theme_type_variation = &"DialogueInput"
	_name_input.max_length = 40
	_name_input.placeholder_text = tr("ONB_COMPANY_PLACEHOLDER")
	_name_input.text_changed.connect(_on_name_changed)
	left.add_child(_name_input)

	left.add_child(_spacer(8))
	left.add_child(UiFactory.make_label(tr("ONB_LOGO_LABEL"), &"ZoneLabel"))
	var cards := HBoxContainer.new()
	cards.add_theme_constant_override("separation", 12)
	left.add_child(cards)
	for style in FounderConstants.LOGO_STYLES:
		cards.add_child(_make_style_card(style))

	left.add_child(_spacer(8))
	left.add_child(UiFactory.make_label(tr("ONB_SLOGAN_LABEL"), &"ZoneLabel"))
	_slogan_input = LineEdit.new()
	_slogan_input.theme_type_variation = &"DialogueInput"
	_slogan_input.max_length = 80
	_slogan_input.placeholder_text = tr("ONB_SLOGAN_PLACEHOLDER")
	left.add_child(_slogan_input)

	# --- Right: live preview ---
	var right := VBoxContainer.new()
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right.add_theme_constant_override("separation", 6)
	content.add_child(right)

	right.add_child(UiFactory.make_label(tr("ONB_PREVIEW_LABEL"), &"ZoneLabel"))
	var preview := PanelContainer.new()
	preview.theme_type_variation = &"DialogueCard"
	preview.size_flags_vertical = Control.SIZE_EXPAND_FILL
	right.add_child(preview)

	var pv := VBoxContainer.new()
	pv.alignment = BoxContainer.ALIGNMENT_CENTER
	pv.add_theme_constant_override("separation", 14)
	preview.add_child(pv)

	var emblem_center := CenterContainer.new()
	_preview_emblem = LogoEmblem.new(96.0)
	emblem_center.add_child(_preview_emblem)
	pv.add_child(emblem_center)

	_preview_name = UiFactory.make_label(tr("ONB_COMPANY_EMPTY"), &"TitleSerifCream")
	_preview_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	pv.add_child(_preview_name)

	pv.add_child(_spacer(24))

	var founder_row := HBoxContainer.new()
	founder_row.alignment = BoxContainer.ALIGNMENT_CENTER
	founder_row.add_theme_constant_override("separation", 10)
	pv.add_child(founder_row)

	var frame := PanelContainer.new()
	frame.theme_type_variation = &"PortraitFrame"
	frame.custom_minimum_size = Vector2(40, 48)
	frame.clip_contents = true
	_preview_portrait = TextureRect.new()
	_preview_portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_preview_portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	frame.add_child(_preview_portrait)
	founder_row.add_child(frame)

	var founder_col := VBoxContainer.new()
	founder_col.alignment = BoxContainer.ALIGNMENT_CENTER
	founder_col.add_theme_constant_override("separation", 1)
	founder_row.add_child(founder_col)
	_preview_founder = UiFactory.make_label("Founder", &"DialogueName")
	founder_col.add_child(_preview_founder)
	founder_col.add_child(UiFactory.make_label(
		tr("ONB_PREVIEW_FOUNDER_TAG") % GameState.START_DATE.year, &"DialogueTag"))


func _make_style_card(style: Dictionary) -> PanelContainer:
	var style_id: String = String(style["id"])
	var card := PanelContainer.new()
	card.theme_type_variation = &"DialogueChoice"
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.custom_minimum_size = Vector2(0, 92)

	var col := VBoxContainer.new()
	col.alignment = BoxContainer.ALIGNMENT_CENTER
	col.add_theme_constant_override("separation", 8)
	col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(col)

	var emblem_center := CenterContainer.new()
	emblem_center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var emblem := LogoEmblem.new(40.0)
	emblem.style_id = style_id
	emblem.mouse_filter = Control.MOUSE_FILTER_IGNORE
	emblem_center.add_child(emblem)
	col.add_child(emblem_center)
	_card_emblems.append(emblem)

	var name_lbl := UiFactory.make_label(tr(style["name_key"]), &"ZoneLabel")
	name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_child(name_lbl)

	card.gui_input.connect(_on_style_input.bind(style_id))
	_style_cards[style_id] = card
	return card


func _on_style_input(event: InputEvent, style_id: String) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_logo_style = style_id
		_refresh_visual()
		validity_changed.emit(is_valid())


func _on_name_changed(_text: String) -> void:
	_refresh_visual()
	validity_changed.emit(is_valid())


func _refresh_visual() -> void:
	var company: String = _name_input.text.strip_edges() if _name_input != null else ""
	for style_id in _style_cards:
		(_style_cards[style_id] as PanelContainer).theme_type_variation = \
			&"DialogueChoiceHover" if style_id == _logo_style else &"DialogueChoice"
	for emblem in _card_emblems:
		emblem.configure(emblem.style_id, company)
	_preview_emblem.configure(_logo_style, company)
	_preview_name.text = company if company != "" else tr("ONB_COMPANY_EMPTY")
	_preview_founder.text = _founder_name if _founder_name != "" else "Founder"
	var path: String = FounderConstants.portrait_path(_portrait_id) if _portrait_id != "" else ""
	if path != "" and ResourceLoader.exists(path):
		_preview_portrait.texture = load(path)
	else:
		_preview_portrait.texture = null


func _spacer(height: int) -> Control:
	var s := Control.new()
	s.custom_minimum_size = Vector2(0, height)
	return s


# --- OnboardingStep contract ---

func prefill(draft: Dictionary) -> void:
	if not is_node_ready():
		await ready
	_name_input.text = draft.get("company_name", "")
	_slogan_input.text = draft.get("slogan", "")
	_logo_style = draft.get("logo_style", "")
	_founder_name = String(draft.get("founder_name", "")).strip_edges()
	_portrait_id = draft.get("portrait_id", "")
	_refresh_visual()
	validity_changed.emit(is_valid())


func is_valid() -> bool:
	return _name_input != null \
		and _name_input.text.strip_edges() != "" \
		and _logo_style != ""


func collect_payload() -> Dictionary:
	return {
		"company_name": _name_input.text.strip_edges(),
		"slogan": _slogan_input.text.strip_edges(),
		"logo_style": _logo_style,
	}
