class_name UiFactory
extends RefCounted

# Runtime UI builder. All static. Produces Control nodes that already carry the
# correct `theme_type_variation`, so runtime-created widgets match the cards and
# labels authored in the .tscn scenes. Colours/sizes come from UiTokens; the
# master theme supplies fonts and per-variation defaults.


static func _chip_box(bg: Color) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.set_corner_radius_all(UiTokens.RADIUS_S)
	sb.content_margin_left = UiTokens.PAD_CHIP.x
	sb.content_margin_right = UiTokens.PAD_CHIP.x
	sb.content_margin_top = UiTokens.PAD_CHIP.y
	sb.content_margin_bottom = UiTokens.PAD_CHIP.y
	return sb


## Tinted pill (PanelContainer > Label[BadgeLabel]) with explicit colours.
static func make_pill(text: String, bg: Color, fg: Color, uppercase: bool = true) -> PanelContainer:
	var chip := PanelContainer.new()
	chip.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	chip.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	chip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	chip.add_theme_stylebox_override("panel", _chip_box(bg))
	var lbl := make_label(UiTokens.tr_upper(text) if uppercase else text, &"BadgeLabel", fg)
	lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	chip.add_child(lbl)
	return chip


## Small uppercase tinted badge. kind: "positive"|"negative"|"neutral"|"accent"|"attention".
static func make_badge(text: String, kind: StringName = &"neutral") -> PanelContainer:
	var p := UiTokens.badge_palette(kind)
	return make_pill(text, p.bg, p.fg)


## Terminal state chip: thin coloured edge + dark fill. Built at runtime rather than
## as a theme variation because the semantic pair's colourblind swap cannot live in a
## static .tres.
static func make_state_chip(text: String, fg: Color, bg: Color, border: Color) -> PanelContainer:
	var chip := PanelContainer.new()
	var sb := _chip_box(bg)
	sb.border_color = border
	sb.set_border_width_all(UiTokens.BORDER_HAIRLINE)
	chip.add_theme_stylebox_override("panel", sb)
	chip.add_child(make_label(text, &"BadgeLabel", fg))
	return chip


## Generic themed label. Optional one-off color override.
static func make_label(text: String, variation: StringName = &"BodySerif", color: Variant = null) -> Label:
	var lbl := Label.new()
	lbl.theme_type_variation = variation
	lbl.text = text
	if color != null:
		lbl.add_theme_color_override("font_color", color as Color)
	return lbl


## UPPERCASE mono section header.
static func make_section_header(text: String) -> Label:
	return make_label(UiTokens.tr_upper(text), &"SectionLabel")


## Body metric cell: VBox > [Caption(MetricCaptionInk), row(Value + optional delta badge)].
## value_color overrides the value tint (e.g. amber for a chosen price).
static func make_stat(caption: String, value_text: String, delta_value: int = 0, delta_text: String = "", value_color: Variant = null) -> VBoxContainer:
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 2)
	col.add_child(make_label(UiTokens.tr_upper(caption), &"MetricCaptionInk"))
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 5)
	var val := make_label(value_text, &"MetricValueInk", value_color)
	val.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(val)
	if delta_text != "":
		var p := UiTokens.badge_palette_for_delta(delta_value)
		row.add_child(make_pill(delta_text, p.bg, p.fg))
	col.add_child(row)
	return col


## Card wrapper; optionally embeds `content`.
static func make_card(content: Control = null, tight: bool = false, attention: bool = false) -> PanelContainer:
	var card := PanelContainer.new()
	if attention:
		card.theme_type_variation = &"CardAttention"
	else:
		card.theme_type_variation = &"CardPanelTight" if tight else &"CardPanel"
	if content != null:
		card.add_child(content)
	return card


## Initials-in-a-circle avatar placeholder. The `Avatar` variation uses RADIUS_PILL,
## so it stays circular at any diameter.
static func make_avatar(initials_text: String, diameter: int = 24) -> Panel:
	var avatar := Panel.new()
	avatar.theme_type_variation = &"Avatar"
	avatar.custom_minimum_size = Vector2(diameter, diameter)
	avatar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	avatar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var initial := make_label(initials_text, &"AvatarInitial")
	initial.set_anchors_preset(Control.PRESET_FULL_RECT)
	initial.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	initial.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	initial.mouse_filter = Control.MOUSE_FILTER_IGNORE
	avatar.add_child(initial)
	return avatar


## Up to two initials from a full name. Uppercased through tr_upper: raw to_upper()
## turns Turkish "i" into "I" instead of "İ" (İpek → Ipek).
static func initials_of(full_name: String) -> String:
	var out: String = ""
	for word in full_name.split(" ", false):
		out += UiTokens.tr_upper(word.substr(0, 1))
		if out.length() >= 2:
			break
	return out if out != "" else "?"


## Drawn dot (replaces the ● glyph): a Panel with a circular StyleBoxFlat.
static func make_dot(color: Color, diameter: int = 6) -> Panel:
	var dot := Panel.new()
	dot.custom_minimum_size = Vector2(diameter, diameter)
	dot.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	dot.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	dot.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var sb := StyleBoxFlat.new()
	sb.bg_color = color
	sb.set_corner_radius_all(int(diameter / 2.0) + 1)
	dot.add_theme_stylebox_override("panel", sb)
	return dot
