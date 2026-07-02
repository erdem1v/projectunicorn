class_name UiFactory
extends RefCounted

# ============================================================================
# Runtime UI builder. All static. Produces Control nodes that already carry the
# correct `theme_type_variation`, so runtime-created widgets match the cards/
# labels authored in the .tscn scenes. Colors/sizes come from UiTokens; the
# master theme supplies fonts + per-variation defaults.
#
# This centralizes the per-component helpers that used to live (duplicated) in
# event_modal.gd, product_tab.gd, etc.
# ============================================================================

const CHIP_RADIUS := 3
const CHIP_PAD_X := 6
const CHIP_PAD_Y := 2

# --- Internal: tinted chip (PanelContainer > Label[BadgeLabel]) -------------
static func _make_chip(text: String, bg: Color, fg: Color, uppercase: bool = true) -> PanelContainer:
	var chip := PanelContainer.new()
	chip.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	chip.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	chip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.set_corner_radius_all(CHIP_RADIUS)
	sb.content_margin_left = CHIP_PAD_X
	sb.content_margin_right = CHIP_PAD_X
	sb.content_margin_top = CHIP_PAD_Y
	sb.content_margin_bottom = CHIP_PAD_Y
	chip.add_theme_stylebox_override("panel", sb)
	var lbl := Label.new()
	lbl.theme_type_variation = &"BadgeLabel"
	lbl.text = text.to_upper() if uppercase else text
	lbl.add_theme_color_override("font_color", fg)
	lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	chip.add_child(lbl)
	return chip

## Small uppercase tinted badge. kind: "positive"|"negative"|"neutral"|"accent"|"attention".
static func make_badge(text: String, kind: StringName = &"neutral") -> PanelContainer:
	var p := UiTokens.badge_palette(kind)
	return _make_chip(text, p.bg, p.fg, true)

## Badge whose palette is chosen from a signed value.
static func make_delta_badge(text: String, value: int) -> PanelContainer:
	var p := UiTokens.badge_palette_for_delta(value)
	return _make_chip(text, p.bg, p.fg, true)

## Trait / relationship pill with explicit colors (kept uppercase, mixed-case allowed).
static func make_pill(text: String, bg: Color, fg: Color, uppercase: bool = true) -> PanelContainer:
	return _make_chip(text, bg, fg, uppercase)

## Mono +/- label colored by sign (for inline deltas without a chip bg).
## `bright` picks the dark-chrome palette; otherwise the light-surface palette.
static func make_delta_label(value: int, text: String, bright: bool = false) -> Label:
	var lbl := Label.new()
	lbl.theme_type_variation = &"MetricDelta"
	lbl.text = text
	lbl.add_theme_color_override("font_color", UiTokens.delta_color_bright(value) if bright else UiTokens.delta_color(value))
	return lbl

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
	return make_label(text.to_upper(), &"SectionLabel")

## Metric strip cell: VBox > [Caption, Value, (Delta)]. Children are named
## "Caption"/"Value"/"Delta" for in-place updates. `bright` = dark-chrome delta.
static func make_metric_cell(caption: String, value_text: String, delta_text: String = "", delta_value: int = 0, bright: bool = true) -> VBoxContainer:
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 1)
	var cap := make_label(caption.to_upper(), &"MetricCaption")
	cap.name = "Caption"
	col.add_child(cap)
	var val := make_label(value_text, &"MetricValue")
	val.name = "Value"
	col.add_child(val)
	if delta_text != "":
		var d := make_delta_label(delta_value, delta_text, bright)
		d.name = "Delta"
		col.add_child(d)
	return col

## Light-surface metric cell: VBox > [Caption(MetricCaptionInk), row(Value + optional delta badge)].
## value_color overrides the value tint (e.g. amber for a chosen price).
static func make_stat(caption: String, value_text: String, delta_value: int = 0, delta_text: String = "", value_color: Variant = null) -> VBoxContainer:
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 2)
	col.add_child(make_label(caption.to_upper(), &"MetricCaptionInk"))
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 5)
	var val := make_label(value_text, &"MetricValueInk", value_color)
	val.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(val)
	if delta_text != "":
		var chip := make_delta_badge(delta_text, delta_value)
		chip.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		row.add_child(chip)
	col.add_child(row)
	return col


## Card wrapper. Reparent content into it (or pass content to embed).
static func make_card(content: Control = null, tight: bool = false, attention: bool = false) -> PanelContainer:
	var card := PanelContainer.new()
	if attention:
		card.theme_type_variation = &"CardAttention"
	else:
		card.theme_type_variation = &"CardPanelTight" if tight else &"CardPanel"
	if content != null:
		card.add_child(content)
	return card

## Event choice card. Returns {root, label, row}; caller wires gui_input + badges.
static func make_choice_card(label_text: String, locked: bool = false) -> Dictionary:
	var root := PanelContainer.new()
	root.theme_type_variation = &"ChoiceCard"
	root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(row)
	var arrow := make_label("→", &"ChoiceLabel", UiTokens.INK_DIM)
	arrow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(arrow)
	var lbl := make_label(label_text, &"ChoiceLabel")
	lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(lbl)
	if locked:
		root.modulate = Color(1, 1, 1, 0.5)
	return {"root": root, "label": lbl, "row": row}

## Drawn dot (replaces the ● glyph). A Panel with a circular StyleBoxFlat.
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
