extends OnboardingStep

# Page 2 — Köken ve Karakter. Three sections on one page, all data-driven from
# FounderConstants (origins / traits / skills — never inline catalogs):
#   KÖKEN      — self_made selectable; heir + corporate_refugee visible-locked
#                (FULL-only per RELEASE SCOPE; disabled-card recipe).
#   KARAKTER   — Software-Inc trait formula: 1 positive free; 2 positives force
#                exactly 1 negative (FounderConstants.validate_traits).
#   YETENEKLER — 8 points across 5 skills, per-skill cap 3, SegmentBar shows the
#                ceiling-5 slots; İleri stays blocked until every point is spent.
#
# Trait EFFECTS are reserved (no system consumes them yet) — this page only
# stores the chosen ids into the draft.

var _origin_id: String = ""
var _trait_ids: Array[String] = []
var _alloc: Dictionary = {}

var _origin_cards: Dictionary = {}     # origin_id -> PanelContainer
var _trait_rows: Dictionary = {}       # trait_id -> {check: Panel, row: Control}
var _pos_counter: Label = null
var _neg_counter: Label = null
var _skill_bars: Dictionary = {}       # skill -> SegmentBar
var _skill_values: Dictionary = {}     # skill -> Label
var _skill_minus: Dictionary = {}      # skill -> Button
var _skill_plus: Dictionary = {}       # skill -> Button
var _points_value: Label = null

var _check_on: StyleBoxFlat = null
var _check_off: StyleBoxFlat = null


func _ready() -> void:
	for skill_key in FounderConstants.SKILLS:
		if not _alloc.has(skill_key):
			_alloc[skill_key] = 0
	_check_on = StyleBoxFlat.new()
	_check_on.bg_color = UiTokens.ACCENT
	_check_on.set_corner_radius_all(3)
	_check_off = StyleBoxFlat.new()
	_check_off.bg_color = Color.TRANSPARENT
	_check_off.set_border_width_all(1)
	_check_off.border_color = UiTokens.CREAM_DIM
	_check_off.set_corner_radius_all(3)
	_build()
	_refresh_all()


# --- Layout ---

func _build() -> void:
	var scroll := ScrollContainer.new()
	scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(scroll)

	var page := VBoxContainer.new()
	page.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	page.add_theme_constant_override("separation", 8)
	scroll.add_child(page)

	page.add_child(UiFactory.make_label(tr("ONB_P2_TITLE"), &"TitleSerifCream"))
	page.add_child(UiFactory.make_label(tr("ONB_P2_SUB"), &"SubtitleSerifCream"))

	page.add_child(_section_header("ONB_ORIGIN_HEADER", "ONB_ORIGIN_SUB"))
	page.add_child(_build_origins())
	page.add_child(_section_header("ONB_TRAITS_HEADER", "ONB_TRAITS_SUB"))
	page.add_child(_build_traits())
	page.add_child(_section_header("ONB_SKILLS_HEADER", "ONB_SKILLS_SUB"))
	page.add_child(_build_skills())


func _section_header(title_key: String, sub_key: String) -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	var top_pad := Control.new()
	top_pad.custom_minimum_size = Vector2(0, 8)
	var wrap := VBoxContainer.new()
	wrap.add_child(top_pad)
	wrap.add_child(row)
	row.add_child(UiFactory.make_label(tr(title_key), &"ZoneLabel", UiTokens.ACCENT))
	row.add_child(UiFactory.make_label(tr(sub_key), &"SubtitleSerifCream"))
	return wrap


# --- KÖKEN ---

func _build_origins() -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 14)
	for origin in FounderConstants.ORIGINS:
		row.add_child(_make_origin_card(origin))
	return row


func _make_origin_card(origin: Dictionary) -> PanelContainer:
	var card := PanelContainer.new()
	card.theme_type_variation = &"DialogueChoice"
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.custom_minimum_size = Vector2(0, 118)

	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 6)
	card.add_child(col)

	var head := HBoxContainer.new()
	head.add_theme_constant_override("separation", 8)
	col.add_child(head)
	var name_lbl := UiFactory.make_label(tr(origin["name_key"]), &"DialogueName")
	name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(name_lbl)
	if origin["locked"]:
		head.add_child(UiFactory.make_pill(tr(origin["locked_note_key"]),
			Color(1, 1, 1, 0.05), UiTokens.CREAM_DIM))

	var quote := UiFactory.make_label("\"%s\"" % tr(origin["quote_key"]), &"QuoteSerifCream")
	quote.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	col.add_child(quote)

	var chips := HBoxContainer.new()
	chips.add_theme_constant_override("separation", 6)
	col.add_child(chips)
	if origin["locked"]:
		chips.add_child(UiFactory.make_pill(tr("ONB_LOCKED_CHIP"),
			Color(1, 1, 1, 0.05), UiTokens.CREAM_DIM))
	else:
		for chip in origin.get("chips", []):
			var plus: bool = chip["kind"] == "plus"
			var fg: Color = UiTokens.ACCENT if plus else UiTokens.NEGATIVE_BRIGHT
			chips.add_child(UiFactory.make_pill(tr(chip["key"]),
				Color(fg.r, fg.g, fg.b, 0.12), fg))

	if origin["locked"]:
		# Disabled-card recipe (origin_step precedent): visible but inert.
		card.mouse_filter = Control.MOUSE_FILTER_IGNORE
		card.focus_mode = Control.FOCUS_NONE
		card.modulate = Color(1, 1, 1, 0.45)
	else:
		card.gui_input.connect(_on_origin_input.bind(String(origin["id"])))
	_origin_cards[String(origin["id"])] = card
	return card


func _on_origin_input(event: InputEvent, origin_id: String) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_origin_id = origin_id
		_refresh_origins()
		validity_changed.emit(is_valid())


func _refresh_origins() -> void:
	for origin_id in _origin_cards:
		var card: PanelContainer = _origin_cards[origin_id]
		if card.mouse_filter == Control.MOUSE_FILTER_IGNORE:
			continue   # locked cards keep their dim state
		card.theme_type_variation = &"DialogueChoiceHover" if origin_id == _origin_id else &"DialogueChoice"


# --- KARAKTER (traits) ---

func _build_traits() -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 14)
	var pos_col := _make_trait_column("ONB_TRAITS_POSITIVE", "positive")
	var neg_col := _make_trait_column("ONB_TRAITS_NEGATIVE", "negative")
	row.add_child(pos_col)
	row.add_child(neg_col)
	return row


func _make_trait_column(title_key: String, polarity: String) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.theme_type_variation = &"DialogueChoice"
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 0)
	panel.add_child(col)

	var head := HBoxContainer.new()
	col.add_child(head)
	var title := UiFactory.make_label(tr(title_key), &"ZoneLabel", UiTokens.ACCENT)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(title)
	var counter := UiFactory.make_label("", &"DialogueNumber")
	head.add_child(counter)
	if polarity == "positive":
		_pos_counter = counter
	else:
		_neg_counter = counter

	for t in FounderConstants.TRAITS:
		if t["polarity"] != polarity:
			continue
		var sep := Panel.new()
		sep.custom_minimum_size = Vector2(0, 1)
		var sep_sb := StyleBoxFlat.new()
		sep_sb.bg_color = UiTokens.SEPARATOR
		sep.add_theme_stylebox_override("panel", sep_sb)
		col.add_child(sep)
		col.add_child(_make_trait_row(t))
	return panel


func _make_trait_row(t: Dictionary) -> Control:
	var trait_id: String = String(t["id"])
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	row.mouse_filter = Control.MOUSE_FILTER_STOP

	var pad := Control.new()
	pad.custom_minimum_size = Vector2(0, 44)
	pad.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(pad)

	var check := Panel.new()
	check.custom_minimum_size = Vector2(15, 15)
	check.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	check.mouse_filter = Control.MOUSE_FILTER_IGNORE
	check.add_theme_stylebox_override("panel", _check_off)
	row.add_child(check)

	var text_col := VBoxContainer.new()
	text_col.add_theme_constant_override("separation", 1)
	text_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_col.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	text_col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var name_lbl := UiFactory.make_label(tr(t["name_key"]), &"DialogueChoiceLabel")
	name_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	text_col.add_child(name_lbl)
	var effect_lbl := UiFactory.make_label(tr(t["effect_key"]), &"DialogueOdds")
	effect_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	text_col.add_child(effect_lbl)
	row.add_child(text_col)

	row.gui_input.connect(_on_trait_input.bind(trait_id))
	_trait_rows[trait_id] = {"check": check, "row": row}
	return row


func _on_trait_input(event: InputEvent, trait_id: String) -> void:
	if not (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		return
	if _trait_ids.has(trait_id):
		_trait_ids.erase(trait_id)
	else:
		# Clicks past the polarity cap are ignored — the counter reads full.
		var polarity: String = String(FounderConstants.trait_by_id(trait_id)["polarity"])
		var cap: int = FounderConstants.TRAIT_MAX_POSITIVE if polarity == "positive" else FounderConstants.TRAIT_MAX_NEGATIVE
		if _count_polarity(polarity) >= cap:
			return
		_trait_ids.append(trait_id)
	_refresh_traits()
	validity_changed.emit(is_valid())


func _count_polarity(polarity: String) -> int:
	var n: int = 0
	for trait_id in _trait_ids:
		if String(FounderConstants.trait_by_id(trait_id).get("polarity", "")) == polarity:
			n += 1
	return n


func _refresh_traits() -> void:
	for trait_id in _trait_rows:
		var selected: bool = _trait_ids.has(trait_id)
		(_trait_rows[trait_id]["check"] as Panel).add_theme_stylebox_override(
			"panel", _check_on if selected else _check_off)
	_pos_counter.text = "%d / %d" % [_count_polarity("positive"), FounderConstants.TRAIT_MAX_POSITIVE]
	_neg_counter.text = "%d / %d" % [_count_polarity("negative"), FounderConstants.TRAIT_MAX_NEGATIVE]


# --- YETENEKLER (skills) ---

func _build_skills() -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	for skill_key in FounderConstants.SKILLS:
		row.add_child(_make_skill_column(skill_key))
	row.add_child(_make_points_card())
	return row


func _make_skill_column(skill_key: String) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.theme_type_variation = &"DialogueChoice"
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 6)
	panel.add_child(col)

	col.add_child(UiFactory.make_label(tr(FounderConstants.SKILL_NAME_KEYS[skill_key]), &"DialogueChoiceLabel"))
	var desc := UiFactory.make_label(tr(FounderConstants.SKILL_DESC_KEYS[skill_key]), &"DialogueOdds")
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc.custom_minimum_size = Vector2(0, 30)
	col.add_child(desc)

	var bar := SegmentBar.new()
	bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col.add_child(bar)
	_skill_bars[skill_key] = bar

	var controls := HBoxContainer.new()
	controls.add_theme_constant_override("separation", 6)
	col.add_child(controls)

	var minus := Button.new()
	minus.theme_type_variation = &"DialogueStepper"
	minus.text = "−"
	minus.focus_mode = Control.FOCUS_NONE
	minus.pressed.connect(_on_skill_delta.bind(skill_key, -1))
	controls.add_child(minus)
	_skill_minus[skill_key] = minus

	var value := UiFactory.make_label("0", &"MetricValue", UiTokens.ACCENT)
	value.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	value.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	value.add_theme_font_size_override("font_size", 20)
	controls.add_child(value)
	_skill_values[skill_key] = value

	var plus := Button.new()
	plus.theme_type_variation = &"DialogueStepper"
	plus.text = "+"
	plus.focus_mode = Control.FOCUS_NONE
	plus.pressed.connect(_on_skill_delta.bind(skill_key, 1))
	controls.add_child(plus)
	_skill_plus[skill_key] = plus
	return panel


func _make_points_card() -> PanelContainer:
	var panel := PanelContainer.new()
	panel.theme_type_variation = &"DialogueChoiceHover"   # standing amber border — the page's checksum
	panel.custom_minimum_size = Vector2(128, 0)

	var col := VBoxContainer.new()
	col.alignment = BoxContainer.ALIGNMENT_CENTER
	col.add_theme_constant_override("separation", 4)
	panel.add_child(col)

	var title := UiFactory.make_label(tr("ONB_POINTS_LEFT"), &"ZoneLabel", UiTokens.ACCENT)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(title)

	_points_value = UiFactory.make_label("0", &"MetricValue", UiTokens.ACCENT)
	_points_value.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_points_value.add_theme_font_size_override("font_size", 30)
	col.add_child(_points_value)

	var hint := UiFactory.make_label(tr("ONB_POINTS_HINT"), &"DialogueOdds")
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(hint)
	return panel


func _on_skill_delta(skill_key: String, delta: int) -> void:
	var current: int = int(_alloc.get(skill_key, 0))
	var next: int = current + delta
	if next < 0 or next > FounderConstants.ONBOARDING_CAP:
		return
	if delta > 0 and FounderConstants.alloc_remaining(_alloc) <= 0:
		return
	_alloc[skill_key] = next
	_refresh_skills()
	validity_changed.emit(is_valid())


func _refresh_skills() -> void:
	var remaining: int = FounderConstants.alloc_remaining(_alloc)
	for skill_key in FounderConstants.SKILLS:
		var v: int = int(_alloc.get(skill_key, 0))
		(_skill_bars[skill_key] as SegmentBar).set_filled(v)
		(_skill_values[skill_key] as Label).text = str(v)
		(_skill_minus[skill_key] as Button).disabled = (v <= 0)
		(_skill_plus[skill_key] as Button).disabled = (v >= FounderConstants.ONBOARDING_CAP or remaining <= 0)
	_points_value.text = str(remaining)
	var done: bool = (remaining == 0)
	_points_value.add_theme_color_override("font_color", UiTokens.CREAM if done else UiTokens.ACCENT)


func _refresh_all() -> void:
	_refresh_origins()
	_refresh_traits()
	_refresh_skills()


# --- OnboardingStep contract ---

func prefill(draft: Dictionary) -> void:
	if not is_node_ready():
		await ready
	_origin_id = draft.get("origin_id", "")
	_trait_ids.clear()
	for trait_id in draft.get("trait_ids", []):
		_trait_ids.append(String(trait_id))
	var alloc: Dictionary = draft.get("skill_alloc", {})
	for skill_key in FounderConstants.SKILLS:
		_alloc[skill_key] = int(alloc.get(skill_key, 0))
	_refresh_all()
	validity_changed.emit(is_valid())


func is_valid() -> bool:
	return _origin_id != "" \
		and not FounderConstants.origin_by_id(_origin_id).get("locked", true) \
		and FounderConstants.validate_traits(_trait_ids) \
		and FounderConstants.alloc_remaining(_alloc) == 0


func collect_payload() -> Dictionary:
	return {
		"origin_id": _origin_id,
		"trait_ids": _trait_ids.duplicate(),
		"skill_alloc": _alloc.duplicate(),
	}
