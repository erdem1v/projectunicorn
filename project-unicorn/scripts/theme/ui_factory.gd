class_name UiFactory
extends RefCounted

# Runtime UI builder. All static. Produces Control nodes that already carry the
# correct `theme_type_variation`, so runtime-created widgets match the cards and
# labels authored in the .tscn scenes. Colours/sizes come from UiTokens; the
# master theme supplies fonts and per-variation defaults.

const CLOSE_ICON := preload("res://assets/icons/util/close.svg")

static var _bust_mats := {}   # (circle, grey) -> the bust's material (avatar_bust.gdshader)


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


## A white glyph (SVG) tinted `color`, `px` square, centred in its row.
static func make_glyph(path: String, px: int, color: Color) -> TextureRect:
	var tex := TextureRect.new()
	tex.texture = load(path)
	tex.custom_minimum_size = Vector2(px, px)
	tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	tex.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	tex.modulate = color
	tex.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return tex


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


## A person's disc: the bust of their look (PersonBust), or their initials without one. `grey` is the
## face of someone away.
static func make_person_avatar(person_name: String, look: Dictionary, diameter: int, grey := false) -> Panel:
	return make_avatar(initials_of(person_name), diameter, PersonBust.texture(look, diameter), grey)


## Frank's disc: his pre-rendered portrait, already cut to the circle (FounderConstants).
static func make_mentor_avatar(diameter: int) -> TextureRect:
	var face := TextureRect.new()
	face.texture = load(FounderConstants.portrait_path(FounderConstants.MENTOR_PORTRAIT, Vector2i(diameter, diameter)))
	face.custom_minimum_size = Vector2(diameter, diameter)
	face.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	face.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	face.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return face


## Initials-in-a-circle avatar. The `Avatar` variation uses RADIUS_PILL, so it stays circular
## at any diameter. Given a person's bust (PersonBust), the disc shows the face instead.
static func make_avatar(initials_text: String, diameter: int = 24, bust: Texture2D = null, grey := false) -> Panel:
	var avatar := Panel.new()
	avatar.theme_type_variation = &"Avatar"
	avatar.custom_minimum_size = Vector2(diameter, diameter)
	avatar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	avatar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if bust != null:
		avatar.add_child(make_bust(bust, true, grey))
		return avatar
	var initial := make_label(initials_text, &"AvatarInitial")
	initial.set_anchors_preset(Control.PRESET_FULL_RECT)
	initial.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	initial.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	initial.mouse_filter = Control.MOUSE_FILTER_IGNORE
	avatar.add_child(initial)
	return avatar


## A person's bust (PersonBust.texture) filling its parent, cut to a circle when `circle`, grey when `grey`.
static func make_bust(bust: Texture2D, circle := true, grey := false) -> TextureRect:
	var face := TextureRect.new()
	face.texture = bust
	face.set_anchors_preset(Control.PRESET_FULL_RECT)
	face.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	face.stretch_mode = TextureRect.STRETCH_SCALE
	face.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	face.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var key := Vector2i(int(circle), int(grey))
	if not _bust_mats.has(key):
		var m := ShaderMaterial.new()
		m.shader = preload("res://scenes/ui/components/avatar_bust.gdshader")
		m.set_shader_parameter("circle", circle)
		m.set_shader_parameter("grey", grey)
		_bust_mats[key] = m
	face.material = _bust_mats[key]
	return face


## Up to two initials from a full name. Uppercased through tr_upper: raw to_upper()
## turns Turkish "i" into "I" instead of "İ" (İpek → Ipek).
static func initials_of(full_name: String) -> String:
	var out: String = ""
	for word in full_name.split(" ", false):
		out += UiTokens.tr_upper(word.substr(0, 1))
		if out.length() >= 2:
			break
	return out if out != "" else "?"


## Drawn dot (replaces the ● glyph): a Panel with a circular StyleBoxFlat. Every dot owns
## its stylebox override, so a caller may recolor one in place (onboarding stepper).
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


## A column that stays centred in its parent Control whatever its content grows to.
static func make_centered_column(separation: int) -> VBoxContainer:
	var col := VBoxContainer.new()
	col.set_anchors_preset(Control.PRESET_CENTER)
	col.grow_horizontal = Control.GROW_DIRECTION_BOTH
	col.grow_vertical = Control.GROW_DIRECTION_BOTH
	col.add_theme_constant_override("separation", separation)
	return col


## Centred title + one muted line: the page for a tab with nothing to show yet. Callers
## pass translated text; tr() dies in a static func.
static func make_placeholder_column(title: String, line: String) -> VBoxContainer:
	var col := make_centered_column(UiTokens.SPACE_M)
	col.alignment = BoxContainer.ALIGNMENT_CENTER
	var title_lbl := make_label(title, &"TitleSerif")
	title_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(title_lbl)
	var line_lbl := make_label(line, &"CaptionMuted")
	line_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(line_lbl)
	return col


## The × that closes a window or a card. No focus: game_shell reads Space as the speed key.
## Its variation carries no margins, so this square is the button's size; `dark` is the Menajer
## Masası's close, its glyph in a 40 px key.
static func make_close_button(on_close: Callable, dark := false) -> Button:
	var close := Button.new()
	close.focus_mode = Control.FOCUS_NONE
	close.tooltip_text = TranslationServer.translate("WIN_CLOSE")
	if dark:
		close.theme_type_variation = &"WinClose"
		close.icon = CLOSE_ICON
		close.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		close.custom_minimum_size = Vector2.ONE * UiTokens.D_H_BTN
	else:
		close.theme_type_variation = &"WindowClose"
		close.text = "×"
		close.custom_minimum_size = Vector2(UiTokens.SPACE_3XL, UiTokens.SPACE_3XL)
	close.pressed.connect(on_close)
	return close


# --- Menajer Masası: the dark language's entry points ---------------------------------------
# A screen taken to the dark language builds these under its menajer_theme root; the cream
# builders above stay with the screens that have not moved.

## A caps tag: "" the plain outline, "neutral" quiet on a fill, "outline" quieter still, and the
## meanings "risk", "warn" and "pos" in the palette in use.
static func D_tag(text: String, kind: StringName = &"") -> Label:
	var tag := make_label(Fmt.upper(text), {&"": &"Tag", &"neutral": &"TagNeutral", &"outline": &"TagOutline",
		&"risk": UiTokens.D_variation(&"TagRisk"), &"warn": UiTokens.D_variation(&"TagWarn"),
		&"pos": UiTokens.D_variation(&"TagPos")}[kind])
	tag.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	tag.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	return tag


## A document's stamp, tilted as on paper. The holder is a plain Control that takes the stamp's size:
## a container would lay the label out again and undo the tilt.
static func D_stamp(text: String) -> Control:
	var holder := Control.new()
	holder.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var mark := make_label(text, &"DocStamp")
	mark.rotation_degrees = -3.0
	mark.resized.connect(func() -> void:
		holder.custom_minimum_size = mark.size
		mark.pivot_offset = mark.size / 2.0)
	holder.add_child(mark)
	return holder


## An empty state: its glyph over one line, centred in whatever room the caller gives it.
static func D_empty(glyph: String, text: String, variation: StringName) -> CenterContainer:
	var center := CenterContainer.new()
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", UiTokens.SPACE_L)
	var icon := make_glyph(glyph, UiTokens.D_ICON_EMPTY, UiTokens.D_INK_4)
	icon.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	col.add_child(icon)
	col.add_child(make_label(text, variation))
	center.add_child(col)
	return center


## A portrait's well, a mail sender's or the founder's on Kişisel: `face` covers it, cropped to the well.
static func D_portrait_well(face: TextureRect) -> PanelContainer:
	var well := PanelContainer.new()
	well.theme_type_variation = &"PortraitWell"
	well.custom_minimum_size = UiTokens.D_PORTRAIT_WELL
	well.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	face.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	face.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	face.clip_contents = true
	well.add_child(face)
	return well


## A window header's figure: its caps key over its value, a rule on its left. An empty value keeps
## its line, so the key stays on the header's baseline. A `cost` reads behind the cost disc; its host builds
## it anew rather than rewriting it in place.
static func D_kpi(key: String, value: String, cost := false) -> PanelContainer:
	var cell := PanelContainer.new()
	cell.theme_type_variation = &"KpiCell"
	var col := VBoxContainer.new()
	col.alignment = BoxContainer.ALIGNMENT_CENTER
	col.add_theme_constant_override("separation", 0)
	col.add_child(make_label(Fmt.upper(key), &"KeyLabel"))
	col.add_child(D_cost(value, &"KpiValue", UiTokens.D_ICON_FIGURE) if cost else make_label(value, &"KpiValue"))
	cell.add_child(col)
	return cell


## A D_kpi cell's value line, which its host rewrites in place.
static func D_kpi_value(cell: PanelContainer) -> Label:
	return cell.get_child(0).get_child(1)


## A window's section tabs, in caps: the active one in ink over its underline, each with its count
## beside it when `counts` gives one (null: none). A click moves the underline and calls `on_pick(index)`.
static func D_seg_tabs(labels: Array, active: int, on_pick: Callable, counts: Array = []) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", UiTokens.SPACE_3XL)
	for i in labels.size():
		var cell := HBoxContainer.new()
		cell.add_theme_constant_override("separation", UiTokens.SPACE_M)
		var tab := Button.new()
		tab.text = Fmt.upper(labels[i])
		tab.focus_mode = Control.FOCUS_NONE
		tab.pressed.connect(func() -> void:
			_paint_seg_tabs(row, i)
			on_pick.call(i))
		cell.add_child(tab)
		if i < counts.size() and counts[i] != null:
			var count := make_label(str(counts[i]), &"SegCount")
			count.size_flags_vertical = Control.SIZE_SHRINK_CENTER
			cell.add_child(count)
		row.add_child(cell)
	_paint_seg_tabs(row, active)
	return row


## A furniture card on a window body's inset ground, in `parent`; its parts go into the column it returns.
static func D_card(parent: Control) -> VBoxContainer:
	var card := PanelContainer.new()
	card.theme_type_variation = &"BodyCard"
	var body := VBoxContainer.new()
	body.add_theme_constant_override("separation", UiTokens.SPACE_L)
	card.add_child(body)
	parent.add_child(card)
	return body


## A card's head: its caps key, a remark `beside` it and, at the far end, `right` (a figure, a count).
static func D_card_head(key: String, right: Control = null, beside: Control = null) -> HBoxContainer:
	var head := HBoxContainer.new()
	head.add_theme_constant_override("separation", UiTokens.SPACE_M)
	head.add_child(make_label(Fmt.upper(key), &"KeyLabel"))
	if beside != null:
		head.add_child(beside)
	if right != null:
		var gap := Control.new()
		gap.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		head.add_child(gap)
		head.add_child(right)
	for part: Control in head.get_children():
		part.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	return head


## A section tab that is not open yet: its glyph and caps label off; its host shows the reason beside it.
static func D_locked_tab(label: String) -> Button:
	var tab := Button.new()
	tab.theme_type_variation = &"SegTab"
	tab.text = Fmt.upper(label)
	tab.icon = load("res://assets/icons/util/lock.svg")
	tab.disabled = true
	tab.focus_mode = Control.FOCUS_NONE
	return tab


static func _paint_seg_tabs(row: HBoxContainer, active: int) -> void:
	for i in row.get_child_count():
		for part: Control in row.get_child(i).get_children():
			var base: String = "SegTab" if part is Button else "SegCount"
			part.theme_type_variation = StringName(base + ("Active" if i == active else ""))


## A rule unit in stars (a lead's or an account's size, a rep's league): five glyphs, the whole ones in
## ink, a half where the value has one, the rest faint.
static func D_stars(stars: float) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 0)
	row.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for i in HRConstants.STAR_MAX:
		var look: String = "full" if stars >= i + 1 else ("half" if stars >= i + 0.5 else "empty")
		row.add_child(make_glyph("res://assets/icons/util/star_%s.svg" % look, UiTokens.D_ICON_STAR,
			UiTokens.D_LINE_3 if look == "empty" else UiTokens.D_INK_2))
	return row


## A segmented pick: its options side by side in one box, the one in force filled and underlined. Each
## option is {text, tip?, icon?} (the icon after the text); a press on another calls `on_pick(index)`.
## `off` reads only; `small` is the caps pick over a chart.
static func D_seg_pick(options: Array, active: int, on_pick: Callable, off := false, small := false) -> PanelContainer:
	var frame := PanelContainer.new()
	frame.theme_type_variation = &"SegPickBox"
	frame.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 0)
	frame.add_child(row)
	for i in options.size():
		if i > 0:
			row.add_child(VSeparator.new())
		var b := Button.new()
		b.theme_type_variation = StringName("SegPick" + ("Sm" if small else "") + ("On" if i == active else ""))
		b.text = Fmt.upper(options[i].text) if small else options[i].text
		b.tooltip_text = options[i].get("tip", "")
		if options[i].has("icon"):
			b.icon = load(options[i].icon)
			b.icon_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		b.focus_mode = Control.FOCUS_NONE
		b.disabled = off
		if i != active:
			b.pressed.connect(on_pick.bind(i))
		row.add_child(b)
	return frame


## A cost: its value in ink behind the cost disc, never in red (a cost is not a danger).
static func D_cost(value: String, variation: StringName = &"DataText", px := UiTokens.D_ICON_PART) -> HBoxContainer:
	var part := HBoxContainer.new()
	part.add_theme_constant_override("separation", UiTokens.SPACE_S)
	part.add_child(make_glyph("res://assets/icons/stake/cost.svg", px, UiTokens.D_INK_3))
	var label := make_label(value, variation)
	label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	part.add_child(label)
	return part


## Removes every child from the tree at once (so it cannot clash with the replacements
## built in the same frame) and frees each one.
static func clear(node: Node) -> void:
	for ch in node.get_children():
		node.remove_child(ch)
		ch.queue_free()


static func is_left_click(ev: InputEvent) -> bool:
	var mb := ev as InputEventMouseButton
	return mb != null and mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT
