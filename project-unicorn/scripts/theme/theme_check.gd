extends SceneTree
## Checks a theme file against themes/master_theme.tres before it ships.
## - Coverage fails the run: every master type keeps its base and its items, and no font, icon or
##   box is null. A scoped theme without a variation hands its controls the base type's box.
## - Contrast is a report: the WCAG ratio of each text colour over the opaque box drawn under it,
##   LOW below 4.5.
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
