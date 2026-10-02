extends SceneTree
## Checks a theme file against themes/master_theme.tres before it ships.
## - Coverage fails the run: every master type keeps its base and its items, and no font, icon or
##   box is null. A scoped theme without a variation hands its controls the base type's box. Any
##   theme but master also fails on a box that leaves its content margins to its border.
## - Contrast is a report: the WCAG ratio of each text colour over the opaque box drawn under it,
##   LOW below 4.5. The dark theme's gate is contrast_audit (main.gd --theme-contrast-audit).
##   "$GODOT" --headless --path . -s res://scripts/theme/theme_check.gd [--theme=res://themes/<ad>.tres]

const MASTER := "res://themes/master_theme.tres"
## Theme.DataType names as the .tres spells them.
const DT := ["colors", "constants", "fonts", "font_sizes", "icons", "styles"]
## Box state -> the text colour a type draws over it. Disabled text is exempt from the WCAG minimum.
const OVER := {"normal": "font_color", "hover": "font_hover_color", "pressed": "font_pressed_color"}
## Text drawn over another type's box: [text type, colour, ground type, box].
const LAYERED := [
	["BadgeLabel", "font_color", "TabBadge", "panel"],
	["NewsRich", "default_color", "NewsPanel", "panel"],
	["MetricValue", "font_color", "TopBarPanel", "panel"],
]


func _initialize() -> void:
	var path := MASTER
	for a in OS.get_cmdline_args():
		if a.begins_with("--theme="):
			path = a.trim_prefix("--theme=")
	var th: Theme = load(path)
	if th == null:
		print("THEME_CHECK|RESULT|%s|FAIL|does not load" % path)
		quit(1)
		return
	var fails := missing(th, load(MASTER))
	if path != MASTER:
		fails.append_array(unset_margins(th))
	for line in fails:
		print("THEME_CHECK|FAIL|" + line)
	for line in contrast(th):
		print("THEME_CHECK|CONTRAST|" + line)
	print("THEME_CHECK|RESULT|%s|%s|fails=%d" % [path, "PASS" if fails.is_empty() else "FAIL", fails.size()])
	quit(0 if fails.is_empty() else 1)


static func missing(th: Theme, master: Theme) -> PackedStringArray:
	var out := PackedStringArray()
	for type in master.get_type_list():
		if th.get_type_variation_base(type) != master.get_type_variation_base(type):
			out.append("%s sits on %s, master on %s" % [type, th.get_type_variation_base(type), master.get_type_variation_base(type)])
		for dt in Theme.DATA_TYPE_MAX:
			var have := th.get_theme_item_list(dt, type)
			for item in master.get_theme_item_list(dt, type):
				if not item in have:
					out.append("%s/%s/%s is missing" % [type, DT[dt], item])
	# has_font answers true for every name while a default font is set.
	var face := th.default_font
	if face == null:
		out.append("default font is null")
	th.default_font = null
	for type in th.get_type_list():
		for dt in [Theme.DATA_TYPE_FONT, Theme.DATA_TYPE_ICON, Theme.DATA_TYPE_STYLEBOX]:
			for item in th.get_theme_item_list(dt, type):
				var v = th.get_theme_item(dt, item, type) if th.has_theme_item(dt, item, type) else null
				if v == null or (v is FontVariation and v.base_font == null) or (v is StyleBoxTexture and v.texture == null):
					out.append("%s/%s/%s is null" % [type, DT[dt], item])
	th.default_font = face
	# HRUiShared.override_bar_fill recolours only a flat fill.
	for type in ["ProgressBar", "BuildProgress"]:
		if not th.get_stylebox("fill", type) is StyleBoxFlat:
			out.append("%s fill is not a StyleBoxFlat" % type)
	return out


## A box whose content margin is unset falls back to its border or texture, so a restyle moves its
## children.
static func unset_margins(th: Theme) -> PackedStringArray:
	var out := PackedStringArray()
	for type in th.get_type_list():
		for item in th.get_stylebox_list(type):
			var sb := th.get_stylebox(item, type)
			for side in 4:
				if sb.get_content_margin(side) < 0.0:
					out.append("%s/styles/%s leaves its content margins to the border" % [type, item])
					break
	return out


static func contrast(th: Theme) -> PackedStringArray:
	var out := PackedStringArray()
	var types := th.get_type_list()
	types.sort()
	for type in types:
		var native := StringName(type)
		while th.get_type_variation_base(native) != &"":
			native = th.get_type_variation_base(native)
		for state in th.get_stylebox_list(type):
			if OVER.has(state):
				out.append_array(_pair(th, type, "default_color" if native == &"RichTextLabel" else OVER[state], type, state))
	for p in LAYERED:
		out.append_array(_pair(th, p[0], p[1], p[2], p[3]))
	return out


## WCAG 2 contrast of text over its ground; translucent ink is composited first.
static func ratio(fg: Color, bg: Color) -> float:
	var a := bg.blend(fg).srgb_to_linear().get_luminance()
	var b := bg.srgb_to_linear().get_luminance()
	return (maxf(a, b) + 0.05) / (minf(a, b) + 0.05)


## One report line, or none when the type sets no such colour or the box is not an opaque fill
## (a translucent box's ground is whatever lies under it).
static func _pair(th: Theme, text_type: StringName, key: StringName, ground_type: StringName, box: StringName) -> PackedStringArray:
	var fg = _up(th, Theme.DATA_TYPE_COLOR, key, text_type)
	var sb = _up(th, Theme.DATA_TYPE_STYLEBOX, box, ground_type)
	if fg == null or not (sb is StyleBoxFlat and sb.draw_center and sb.bg_color.a == 1.0):
		return []
	var r := ratio(fg, sb.bg_color)
	return ["%s/%s on %s/%s|%.2f%s" % [text_type, key, ground_type, box, r, "|LOW" if r < 4.5 else ""]]


## The item stored on the type or on the nearest base storing it, else null.
static func _up(th: Theme, dt: int, item: StringName, type: StringName):
	while type != &"":
		if th.has_theme_item(dt, item, type):
			return th.get_theme_item(dt, item, type)
		type = th.get_type_variation_base(type)
	return null


# ---- The dark theme's gate ----

## The text each class draws, as [the box it sits on, its colour]. A box that is not an opaque fill
## leaves the text on whatever ground the control sits on.
const TEXT_ON := {
	"Label": [["normal", "font_color"]],
	"RichTextLabel": [["normal", "default_color"]],
	"Button": [["normal", "font_color"], ["normal", "font_focus_color"], ["hover", "font_hover_color"],
		["pressed", "font_pressed_color"], ["pressed", "font_hover_pressed_color"], ["disabled", "font_disabled_color"]],
	"LineEdit": [["normal", "font_color"], ["normal", "font_placeholder_color"], ["read_only", "font_uneditable_color"]],
	"PopupMenu": [["panel", "font_color"], ["panel", "font_hover_color"], ["panel", "font_disabled_color"],
		["panel", "font_accelerator_color"], ["panel", "font_separator_color"]],
}
## The dark theme's text drawn over another type's box.
const LAYERED_DARK := [
	["TooltipLabel", "font_color", "TooltipPanel", "panel"],
	["RiskKey", "font_color", "RiskStrip", "panel"],
	["RiskValue", "font_color", "RiskStrip", "panel"],
	["RiskName", "font_color", "RiskStrip", "panel"],
]
const MIN_RATIO := {"body": 4.5, "large": 3.0, "ui": 3.0}


## Every text colour of the dark theme on every ground it is drawn on, and every colour code paints
## from the D_ tokens, in both palettes. Body text needs 4.5:1, large text (24 px, or 19 px bold) and
## non-text marks 3:1; disabled text is exempt from the minimum but must stay between 1.6 and 4.5,
## seen and read as off. Text with no box of its own sits on the window grounds, surface 1 to 4.
static func contrast_audit(th: Theme, T) -> bool:
	var was: bool = T.is_colorblind()
	var pairs := 0
	var fails := 0
	for cb in [false, true]:
		T.set_colorblind(cb)
		var rows := _token_rows(T)
		if not cb:
			rows.append_array(_theme_rows(th, T))
		for r in rows:
			var lo := INF
			var hi := 0.0
			var at := ""
			for g in r[3]:
				var q := ratio(r[1], g[1])
				hi = maxf(hi, q)
				if q < lo:
					lo = q
					at = g[0]
			var ok: bool = (lo >= 1.6 and hi <= 4.5) if r[2] == "off" else lo >= MIN_RATIO[r[2]]
			pairs += 1
			fails += 0 if ok else 1
			print("CONTRAST|%s|%s|%s on %s|%.2f%s|%s" % ["cb" if cb else "std", r[2], r[0], at, lo,
				"..%.2f" % hi if r[2] == "off" else "", "ok" if ok else "FAIL"])
	T.set_colorblind(was)
	print("CONTRAST|RESULT|%s|pairs=%d|fails=%d" % ["PASS" if fails == 0 else "FAIL", pairs, fails])
	return fails == 0


## [what, colour, category, [[ground name, ground], ...]] for each text colour the theme holds.
static func _theme_rows(th: Theme, T) -> Array:
	var window := [["s1", T.D_SURFACE_1], ["s2", T.D_SURFACE_2], ["s3", T.D_SURFACE_3], ["s4", T.D_SURFACE_4]]
	var paper_inks := [T.PAPER_INK, T.PAPER_INK_BODY, T.PAPER_INK_DECK, T.PAPER_INK_MAST, T.D_PAPER_INK_META]
	var rows := []
	var types := th.get_type_list()
	types.sort()
	for type in types:
		var native := StringName(type)
		while th.get_type_variation_base(native) != &"":
			native = th.get_type_variation_base(native)
		while native != &"" and not TEXT_ON.has(String(native)):
			native = ClassDB.get_parent_class(native) if ClassDB.class_exists(native) else &""
		for on in TEXT_ON.get(String(native), []):
			var fg = _up(th, Theme.DATA_TYPE_COLOR, on[1], type)
			if fg == null:
				continue
			var grounds: Array = [["paper", T.PAPER_BG]] if fg in paper_inks else window
			var sb = _up(th, Theme.DATA_TYPE_STYLEBOX, on[0], type)
			if sb is StyleBoxFlat and sb.draw_center and sb.bg_color.a > 0.0:
				grounds = [[on[0], sb.bg_color]] if sb.bg_color.a == 1.0 \
					else grounds.map(func(g): return [on[0] + "/" + g[0], g[1].blend(sb.bg_color)])
			rows.append(["%s/%s" % [type, on[1]], fg, _category(th, type, on[1], fg, T), grounds])
	for p in LAYERED + LAYERED_DARK:
		var fg = _up(th, Theme.DATA_TYPE_COLOR, p[1], p[0])
		var sb = _up(th, Theme.DATA_TYPE_STYLEBOX, p[3], p[2])
		if fg != null and sb is StyleBoxFlat:
			rows.append(["%s/%s" % [p[0], p[1]], fg, _category(th, p[0], p[1], fg, T), [["%s/%s" % [p[2], p[3]], sb.bg_color]]])
	return rows


static func _category(th: Theme, type: StringName, key: String, fg: Color, T) -> String:
	if "disabled" in key or fg == T.D_INK_OFF:
		return "off"
	var rich := key == "default_color"
	var size = _up(th, Theme.DATA_TYPE_FONT_SIZE, "normal_font_size" if rich else "font_size", type)
	var face = _up(th, Theme.DATA_TYPE_FONT, "normal_font" if rich else "font", type)
	size = th.default_font_size if size == null else size
	face = th.default_font if face == null else face
	var bold: bool = face is FontVariation and face.base_font.resource_path.contains("-Bold")
	return "large" if size >= 24 or (bold and size >= 19) else "body"


## The colours code paints from the D_ tokens, on the grounds it paints them on.
static func _token_rows(T) -> Array:
	var s := []
	for i in 6:
		s.append(["s%d" % i, T.get("D_SURFACE_%d" % i)])
	var win := s.slice(1, 5)
	var on := func(name: String, fill: Color, grounds: Array) -> Array:
		return grounds.map(func(g): return [name + "/" + g[0], g[1].blend(fill)])
	var neg: Dictionary = T.D_badge_palette(&"negative")
	var pos: Dictionary = T.D_badge_palette(&"positive")
	var warn: Dictionary = T.D_badge_palette(&"accent")
	var rows := [
		["D_INK_1", T.D_INK_1, "body", win], ["D_INK_2", T.D_INK_2, "body", s], ["D_INK_3", T.D_INK_3, "body", s],
		["D_INK_4", T.D_INK_4, "body", win], ["D_INK_OFF", T.D_INK_OFF, "off", win],
		["D_ACCENT", T.D_ACCENT, "body", [s[1], s[4]]],
		["D_ON_ACCENT", T.D_ON_ACCENT, "body", [["accent", T.D_ACCENT], ["accent-hover", T.D_ACCENT_HOVER],
			["accent-pressed", T.D_ACCENT_PRESSED]]],
		["D_pos", T.D_pos(), "body", win], ["D_warn", T.D_warn(), "body", win],
		["D_neg", T.D_neg(), "body", win + [["neg-bg", T.D_neg_bg()]]],
		["D_info", T.D_info(), "ui", [s[2], s[3]]],
		["D_neg_ink", T.D_neg_ink(), "body", [["neg-bg", T.D_neg_bg()]] + on.call("neg-tag", neg.bg, [s[2], s[3]])],
		["positive tag", pos.fg, "body", on.call("pos-tag", pos.bg, [s[2], s[3]])],
		["attention tag", warn.fg, "body", on.call("warn-tag", warn.bg, [s[2], s[3]])],
		["D_on_neg", T.D_on_neg(), "body", [["neg", T.D_neg()]]],
		["D_STAMP", T.D_STAMP, "body", [s[2], s[3], s[4]]],
		["D_FOCUS", T.D_FOCUS, "ui", [s[1], s[3], s[4], s[5]]],
		["D_LINE_HOVER", T.D_LINE_HOVER, "ui", [s[3], s[4]]],
		["D_CHART_LINE", T.D_CHART_LINE, "ui", [s[3]]], ["D_CHART_PROJ", T.D_CHART_PROJ, "ui", [s[3]]],
		["D_BAR_FILL", T.D_BAR_FILL, "ui", [s[3], s[4]]], ["D_BAR_EMPH", T.D_BAR_EMPH, "ui", [s[3]]],
	]
	for v in [1, 3, 5, 7, 9]:
		rows.append(["D_skill(%d)" % v, T.D_skill(v), "body", on.call("band", T.D_ROLE_BAND, [s[3], s[4]])])
	for key in T.D_TOPICS:
		var hue: Color = T.D_topic(key)
		rows.append([key, hue, "body", [s[2], s[4]] + on.call("pill", Color(hue, T.D_PILL_FILL_ALPHA), [s[2]])])
	for key in T.D_OUTLETS:
		rows.append([key, T.D_outlet(key), "body", [s[0]]])
	for ink in ["PAPER_INK", "PAPER_INK_BODY", "PAPER_INK_DECK", "PAPER_INK_MAST", "D_PAPER_INK_META"]:
		rows.append([ink, T.get(ink), "body", [["paper", T.PAPER_BG]]])
	return rows
