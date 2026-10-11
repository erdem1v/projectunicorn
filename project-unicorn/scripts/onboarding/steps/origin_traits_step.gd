extends OnboardingStep

# Step 2, Köken: three columns, all data from FounderConstants.
#   Origin  - Self-Made selectable; the others visible and locked (GDD ch14 §3).
#   Traits  - the Software Inc. formula: one positive free, two positives owe exactly one negative
#             (FounderConstants.validate_traits).
#   Skills  - POINT_POOL points over FounderConstants.SKILLS, each capped at ONBOARDING_CAP; the figure reads on
#             the 0-10 ruler. Next stays shut until every point is spent.
# A skill whose effect the engine computes today says that effect for the points it holds; the others keep their
# description.

const COLUMNS := [[352, 400], [300, 332]]   # origin and traits widths, the skills take the rest
const SKILL_ROW_H := [58, 51]
const TRAIT_ROW_H := [44, 40]
const BAR_W := [100, 72]

var _origin_id := ""
var _trait_ids: Array[String] = []
var _alloc := {}   # skill -> points; prefill writes every SKILLS key

var _origin_cards := {}   # selectable origin_id -> PanelContainer
var _trait_rows := {}     # trait_id -> [check box, name, effect]
var _counters := {}       # polarity -> Label
var _skill_rows := {}     # skill -> {name, word, line, bar, value, minus, plus}
var _points: Label
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	var cols := HBoxContainer.new()
	cols.set_anchors_preset(Control.PRESET_FULL_RECT)
	cols.add_theme_constant_override("separation", UiTokens.SPACE_3XL if short else UiTokens.SPACE_4XL)
	add_child(cols)
	cols.add_child(_build_origins())
	cols.add_child(_build_traits())
	cols.add_child(_build_skills())


func _column(width: int, head: Control) -> VBoxContainer:
	var col := VBoxContainer.new()
	col.custom_minimum_size.x = width
	col.size_flags_horizontal = Control.SIZE_FILL if width > 0 else Control.SIZE_EXPAND_FILL
	col.add_theme_constant_override("separation", UiTokens.SPACE_M if short else UiTokens.SPACE_L)
	col.add_child(head)
	return col


# --- Origin ---

func _build_origins() -> Control:
	var col := _column(COLUMNS[int(short)][0], _head("ONB_ORIGIN_HEADER", "ONB_ORIGIN_SUB"))
	for origin: Dictionary in FounderConstants.ORIGINS:
		col.add_child(_origin_card(origin))
	return col


func _origin_card(origin: Dictionary) -> PanelContainer:
	var locked: bool = origin.locked
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", UiTokens.SPACE_M)
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var card := _card(box, not locked)
	var head := HBoxContainer.new()
	head.add_theme_constant_override("separation", UiTokens.SPACE_M)
	var title := UiFactory.make_label(tr(origin.name_key), &"OptionLabelLocked" if locked else &"OptionLabel")
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(title)
	if locked:
		head.add_child(UiFactory.make_glyph(UiFactory.LOCK_ICON, UiTokens.D_ICON_PART, UiTokens.D_INK_OFF))
		head.add_child(UiFactory.D_tag(tr("LOCK_FULL"), &"outline"))
	box.add_child(head)
	var quote := UiFactory.make_label("\"%s\"" % tr(origin.quote_key), &"CaptionFaint" if locked else &"OriginQuote")
	quote.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	# The narrow paper keeps a locked origin to its title row.
	quote.visible = not (locked and short)
	box.add_child(quote)
	if locked:
		return card
	var chips := HFlowContainer.new()
	chips.add_theme_constant_override("h_separation", UiTokens.SPACE_S)
	chips.add_theme_constant_override("v_separation", UiTokens.SPACE_S)
	for chip: Dictionary in origin.chips:
		chips.add_child(UiFactory.D_tag(tr(chip.key)))
	box.add_child(chips)
	box.add_child(HSeparator.new())
	box.add_child(UiFactory.make_label(tr("ONB_ORIGIN_PLACE").format({"place": tr("OFFICE_NAME_HOME")}), &"MetaText"))
	card.gui_input.connect(func(event: InputEvent) -> void:
		if UiFactory.is_left_click(event):
			_origin_id = origin.id
			_refresh()
			changed.emit())
	_origin_cards[origin.id] = card
	return card


# --- Traits ---

func _build_traits() -> Control:
	var col := _column(COLUMNS[int(short)][1], _head("ONB_TRAITS_HEADER", "ONB_TRAITS_SUB", true))
	for polarity: String in ["positive", "negative"]:
		var box := VBoxContainer.new()
		box.add_theme_constant_override("separation", 0)
		var head := HBoxContainer.new()
		var title := UiFactory.make_label(Fmt.upper(tr("ONB_TRAITS_" + polarity.to_upper())), &"KeyLabel")
		title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		head.add_child(title)
		_counters[polarity] = UiFactory.make_label("", &"DataStrong")
		head.add_child(_counters[polarity])
		box.add_child(head)
		for t: Dictionary in FounderConstants.TRAITS:
			if t.polarity == polarity:
				box.add_child(_trait_row(t))
		col.add_child(_card(box))
	return col


func _trait_row(t: Dictionary) -> Control:
	var row := HBoxContainer.new()
	row.custom_minimum_size.y = TRAIT_ROW_H[int(short)]
	row.add_theme_constant_override("separation", UiTokens.SPACE_M if short else UiTokens.SPACE_L)
	var check := PanelContainer.new()
	check.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	check.mouse_filter = Control.MOUSE_FILTER_IGNORE
	check.add_child(UiFactory.make_glyph("res://assets/icons/util/check.svg", UiTokens.D_ICON_PART, UiTokens.D_SURFACE_2))
	row.add_child(check)
	var text := VBoxContainer.new()
	text.add_theme_constant_override("separation", 0)
	text.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	text.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var name := UiFactory.make_label(tr(t.name_key), &"DataStrong")
	text.add_child(name)
	var effect := UiFactory.make_label(tr(t.effect_key), &"CondCaption" if short else &"Caption")
	text.add_child(effect)
	row.add_child(text)
	row.gui_input.connect(func(event: InputEvent) -> void:
		if UiFactory.is_left_click(event):
			_toggle_trait(t))
	_trait_rows[t.id] = [check, name, effect]
	return row


func _toggle_trait(t: Dictionary) -> void:
	if _trait_ids.has(t.id):
		_trait_ids.erase(t.id)
	elif _count(t.polarity) < _cap(t.polarity):
		_trait_ids.append(t.id)
	else:
		return   # past the polarity's cap: the counter already reads full
	_refresh()
	changed.emit()


func _count(polarity: String) -> int:
	return _trait_ids.filter(func(id: String) -> bool: return FounderConstants.trait_by_id(id).polarity == polarity).size()


func _cap(polarity: String) -> int:
	return FounderConstants.TRAIT_MAX_POSITIVE if polarity == "positive" else FounderConstants.TRAIT_MAX_NEGATIVE


# --- Skills ---

func _build_skills() -> Control:
	var head := _head("ONB_SKILLS_HEADER", "ONB_SKILLS_SUB")
	var left := HBoxContainer.new()
	left.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	left.add_theme_constant_override("separation", UiTokens.SPACE_S)
	left.add_child(UiFactory.make_label(Fmt.upper(tr("ONB_POINTS_LEFT")), &"KeyLabel"))
	_points = UiFactory.make_label("", &"DataStrong")
	left.add_child(_points)
	head.add_child(left)
	var col := _column(0, head)
	col.add_theme_constant_override("separation", 0)
	for skill: String in FounderConstants.SKILLS:
		col.add_child(_skill_row(skill))
	return col


func _skill_row(skill: String) -> Control:
	var row := HBoxContainer.new()
	row.custom_minimum_size.y = SKILL_ROW_H[int(short)]
	row.add_theme_constant_override("separation", UiTokens.SPACE_L)
	var text := VBoxContainer.new()
	text.add_theme_constant_override("separation", 0)
	text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var top := HBoxContainer.new()
	top.add_theme_constant_override("separation", UiTokens.SPACE_M)
	# The narrow paper holds a row to the name's line and two of the description's: the name takes the caption's size,
	# and the ruler moves up beside it so the description has the whole row.
	var parts := {"name": UiFactory.make_label(tr(FounderConstants.SKILL_NAME_KEYS[skill]),
			&"CaptionStrong" if short else &"DataStrong"),
		"word": UiFactory.make_label("", &"KeySmall"),
		"line": UiFactory.make_label("", &"CondCaption" if short else &"Caption")}
	top.add_child(parts.name)
	top.add_child(parts.word)
	text.add_child(top)
	parts.line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text.add_child(parts.line)
	row.add_child(text)
	parts.bar = SegmentBar.new()
	parts.bar.custom_minimum_size.x = BAR_W[int(short)]
	parts.bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	if short:
		parts.bar.size_flags_horizontal = Control.SIZE_EXPAND | Control.SIZE_SHRINK_END
		top.add_child(parts.bar)
	else:
		row.add_child(parts.bar)
	var stepper := PanelContainer.new()
	stepper.theme_type_variation = &"StepperBox"
	stepper.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var keys := HBoxContainer.new()
	keys.add_theme_constant_override("separation", 0)
	stepper.add_child(keys)
	parts.minus = _step_key(keys, "minus", skill, -1)
	parts.value = UiFactory.make_label("", &"DataStrong")
	parts.value.custom_minimum_size.x = UiTokens.D_H_BTN_SM
	parts.value.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	keys.add_child(parts.value)
	parts.plus = _step_key(keys, "plus", skill, 1)
	row.add_child(stepper)
	_skill_rows[skill] = parts
	return row


func _step_key(parent: Control, glyph: String, skill: String, delta: int) -> Button:
	var b := Button.new()
	b.theme_type_variation = &"StepKey"
	b.icon = load("res://assets/icons/util/%s.svg" % glyph)
	b.custom_minimum_size = Vector2.ONE * (UiTokens.D_H_KEY_SM if short else UiTokens.D_H_BTN_SM)
	b.focus_mode = Control.FOCUS_NONE
	# Disabled exactly when the step would leave 0..ONBOARDING_CAP or overspend the pool (_refresh).
	b.pressed.connect(func() -> void:
		_alloc[skill] += delta
		_refresh()
		changed.emit())
	parent.add_child(b)
	return b


## What `points` in `skill` does where the engine computes it today; the description elsewhere.
func _skill_line(skill: String, points: int) -> String:
	var ruler := FounderConstants.to_ruler(points)
	match skill:
		"sales":
			return tr("ONB_EFFECT_SALES" if ruler >= SkillCheck.SALES_READ_THRESHOLD else "ONB_EFFECT_SALES_NO_READ").format({
				"stars": maxi(int(HRConstants.stars_for(ruler)), 1),
				"n": ceili(float(SkillCheck.SALES_READ_THRESHOLD) / FounderConstants.RULER_SCALE)})
		"leadership":
			# HRMoraleSystem slows the team's morale loss by this share per ruler point of the lead's Liderlik.
			var pct := roundi(HRConstants.LEAD_MORALE_PER_POINT * 100.0 * (ruler if points > 0 else FounderConstants.RULER_SCALE))
			return tr("ONB_EFFECT_LEAD" if points > 0 else "ONB_EFFECT_LEAD_NONE").format({"pct": pct})
		"charisma":
			# VCPitchSystem's seed room reads the founder strong from 9 conviction up.
			if points == 0:
				return tr("ONB_EFFECT_CHARISMA_NONE")
			var strong := roundi(ruler / 10.0 * SeedConstants.CONV_FOUNDER_MAX) >= 9
			return tr("ONB_EFFECT_CHARISMA_STRONG" if strong else "ONB_EFFECT_CHARISMA")
	return tr(FounderConstants.SKILL_DESC_KEYS[skill])


func _refresh() -> void:
	for id: String in _origin_cards:
		show_pick(_origin_cards[id], id == _origin_id)
	for id: String in _trait_rows:
		var t: Dictionary = FounderConstants.trait_by_id(id)
		var on := _trait_ids.has(id)
		var off := not on and _count(t.polarity) >= _cap(t.polarity)
		var row: Array = _trait_rows[id]
		row[0].theme_type_variation = &"CheckSquareOn" if on else &"CheckSquare"
		row[1].theme_type_variation = &"MetaFaint" if off else &"DataStrong"
		row[2].add_theme_color_override("font_color", UiTokens.D_INK_4 if off else UiTokens.D_INK_3)
	for polarity: String in _counters:
		_counters[polarity].text = "%d / %d" % [_count(polarity), _cap(polarity)]
	var remaining := FounderConstants.alloc_remaining(_alloc)
	for skill: String in FounderConstants.SKILLS:
		var v: int = _alloc[skill]
		var parts: Dictionary = _skill_rows[skill]
		parts.word.text = Fmt.upper(tr("ONB_SKILL_WORD_%d" % mini(v, 3)))
		parts.line.text = _skill_line(skill, v)
		parts.bar.set_filled(FounderConstants.to_ruler(v))
		parts.value.text = str(FounderConstants.to_ruler(v))
		parts.minus.disabled = v <= 0
		parts.plus.disabled = v >= FounderConstants.ONBOARDING_CAP or remaining <= 0
	_points.text = str(remaining)


# --- OnboardingStep contract ---

func prefill(draft: Dictionary) -> void:
	_origin_id = draft.get("origin_id", FounderConstants.ORIGINS[0].id)
	_trait_ids.assign(draft.get("trait_ids", []))
	var alloc: Dictionary = draft.get("skill_alloc", {})
	for skill: String in FounderConstants.SKILLS:
		_alloc[skill] = int(alloc.get(skill, 0))
	_refresh()


func invalid_reason() -> String:
	if FounderConstants.origin_by_id(_origin_id).get("locked", true):
		return tr("LOCK_FULL")
	var trait_why := FounderConstants.validate_traits(_trait_ids)
	if trait_why != "":
		return tr(trait_why)
	var left := FounderConstants.alloc_remaining(_alloc)
	if left != 0:
		return tr(Fmt.count_key("ONB_WHY_POINTS", left)).format({"n": left})
	return ""


func collect_payload() -> Dictionary:
	return {"origin_id": _origin_id, "trait_ids": _trait_ids.duplicate(), "skill_alloc": _alloc.duplicate()}


## Traits the formula takes (one or two positives, the negative two of them owe) and the whole pool spent.
func roll() -> void:
	var positives: Array = FounderConstants.TRAITS.filter(func(t: Dictionary) -> bool: return t.polarity == "positive")
	var negatives: Array = FounderConstants.TRAITS.filter(func(t: Dictionary) -> bool: return t.polarity == "negative")
	var picks := _rng.randi_range(1, FounderConstants.TRAIT_MAX_POSITIVE)
	_trait_ids.clear()
	for _i in picks:
		_trait_ids.append(positives.pop_at(_rng.randi_range(0, positives.size() - 1)).id)
	if picks == FounderConstants.TRAIT_MAX_POSITIVE or _rng.randi_range(0, 1) == 1:
		_trait_ids.append(negatives[_rng.randi_range(0, negatives.size() - 1)].id)
	for skill: String in FounderConstants.SKILLS:
		_alloc[skill] = 0
	for _i in FounderConstants.POINT_POOL:
		var open: Array = FounderConstants.SKILLS.filter(func(s: String) -> bool: return _alloc[s] < FounderConstants.ONBOARDING_CAP)
		_alloc[open[_rng.randi_range(0, open.size() - 1)]] += 1
	_refresh()
	changed.emit()

