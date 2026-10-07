extends SceneTree
## Builds res://sandbox/ui_lab/themes/<yon>/theme.tres, a drop-in candidate for the project theme:
## every master type and item copied, the direction's colours resolved by token identity, its faces
## swapped in by role, its 11 canonical variations defined, and each canonical look flattened onto
## the master variations that play that role. The file is written only when no check fails.
##   "$GODOT" --headless --path . -s res://sandbox/ui_lab/core/build_direction.gd --yon=<yon>
##   --yon=_identity --identity: the copy alone with the master's own faces, to prove it faithful.
## Every load() runs in _initialize: ui_tokens.gd and direction.gd name autoloads, which the compile
## pass of a -s script cannot resolve yet.

const SELF := "res://sandbox/ui_lab/core/build_direction.gd"
const MASTER := "res://themes/master_theme.tres"
const UI_TOKENS := "res://scripts/theme/ui_tokens.gd"
const THEMES := "res://sandbox/ui_lab/themes/"
const MASTER_FACES := "res://assets/fonts/variations/"
const SYMBOLS := "res://assets/fonts/fallback/NotoSansSymbols2-Regular.ttf"

const ROLES := ["serif_reg", "serif_sb", "serif_it", "sans_reg", "sans_sb", "mono_reg", "mono_label", "mono_sb"]
## Item kinds indexed by Theme.DataType, spelled as the .tres keys spell them.
const DT := ["colors", "constants", "fonts", "font_sizes", "icons", "styles"]
const SIDES := ["L", "T", "R", "B"]
## What master_theme.tres holds; another count means the tables below no longer describe it.
const EXPECTED := {"variations": 131, "colors": 140, "styles": 151, "font_sizes": 91, "fonts": 74,
	"constants": 14, "icons": 10}
const GLYPHS := "ığüşöçİĞÜŞÖÇ"
const SAMPLE := "Kadro · İşe al · $1.2M · 0123456789 ığüşöçİĞÜŞÖÇ"

## The 11 shared names and the base each must sit on, so directions stay interchangeable.
const CANON := {
	"FolderTab": "Button", "FolderTabSelected": "Button", "FolderTabSoon": "Button",
	"PrimaryButton": "Button", "InkButton": "Button",
	"FolderWindow": "PanelContainer", "PaperCard": "PanelContainer",
	"Stamp": "Label", "AttentionBadge": "Label", "DataMono": "Label", "TickerLabel": "Label",
}
const BUTTON_ITEMS := ["styles/normal", "styles/hover", "styles/pressed", "styles/disabled",
	"colors/font_color", "colors/font_hover_color", "colors/font_pressed_color", "colors/font_disabled_color"]
## Items a canonical must define; the Button ones need BUTTON_ITEMS. Stamp and AttentionBadge draw
## their box through Label's own `normal` stylebox.
const REQUIRED := {
	"FolderWindow": ["styles/panel"], "PaperCard": ["styles/panel"],
	"Stamp": ["styles/normal", "fonts/font", "colors/font_color"],
	"AttentionBadge": ["styles/normal", "colors/font_color"],
	"DataMono": ["fonts/font", "colors/font_color"], "TickerLabel": ["fonts/font", "colors/font_color"],
}
## Canonical -> master variations that take its look. A target keeps its effective margins, sizes,
## constants, icons, focus box and set of states, so no row moves. FolderTabSoon and Stamp have no
## target on the real screens.
const ROLE_MAP := {
	"FolderTab": ["TabButton", "ChromeTabButton"],
	"FolderTabSelected": ["TabButtonActive", "ChromeTabButtonActive"],
	"FolderWindow": ["WindowPanel", "ModalCard", "ModalPanel"],
	"PaperCard": ["CardPanel", "CardPanelTight", "LedgerRow", "ChoiceCard", "CardFloating"],
	"AttentionBadge": ["TabBadge"],
	"DataMono": ["MetricValue", "MetricValueInk", "StepperValue", "MeetingFigure", "ConvictionValue"],
	"PrimaryButton": ["CommitButton"],
	"InkButton": ["Button"],
	"TickerLabel": ["NewsRich"],
}
## Hover twin -> its resting sibling. The twin takes PaperCard's box with its own edge colour.
const HOVER_TWINS := {"CardPanelTightHover": "CardPanelTight", "LedgerRowHover": "LedgerRow",
	"ChoiceCardHover": "ChoiceCard"}
## One token value, two names: the property kind tells them apart.
const SPLIT := {
	"1b232bff": {"FILL": "BG_AVATAR", "EDGE": "SEPARATOR"},
	"f6f1e6ff": {"FILL": "BG_BODY", "FONT": "ON_INK"},
	"e3dac9ff": {"FILL": "SURFACE_SUNKEN", "LINE": "DIVIDER_LIGHT"},
	"e8edf2ff": {"FONT": "CREAM", "FILL": "PORTRAIT_FRAME"},
}
## The selected rail tile and the open window meet flush at the rail edge (x=84): a tile ends 4 px
## short of it (LeftTabs margin) and the window starts 16 px past it (WindowLayer.EDGE).
const JOIN := {"TabButtonActive": [SIDE_RIGHT, 4], "WindowPanel": [SIDE_LEFT, 16]}
## Smallest drawn size of a restyled target: a nine-slice margin pair must fit inside it.
const ENVELOPE := {
	"TabButton": Vector2(76, 64), "TabButtonActive": Vector2(76, 64),
	"ChromeTabButton": Vector2(INF, 19), "ChromeTabButtonActive": Vector2(INF, 19),
	"TabBadge": Vector2(8, 8), "LedgerRow": Vector2(INF, 40), "LedgerRowHover": Vector2(INF, 40),
	"CommitButton": Vector2(INF, 36),
}
## Fixed slots on the real screens: [variation, sample, slot width or 0, what a wider text does].
const HOT := [
	["MetricValue", "$1.234.567", 104, "clips"],
	["ChromeClock", "Hafta 52 · Ağustos 2026 · 11:00", 210, "grows"],
	["TabLabel", "Pazarlama", 76, "overflows"],
	["ModalTitleSerif", SAMPLE, 0, ""],
	["BodyRich", SAMPLE, 0, ""],
]
## Text on its ground: [text type, colour item, ground type, ground box].
const CONTRAST := [
	["BadgeLabel", "font_color", "TabBadge", "panel"],
	["NewsRich", "default_color", "NewsPanel", "panel"],
	["MetricValue", "font_color", "TopBarPanel", "panel"],
	["CommitButton", "font_color", "CommitButton", "normal"],
]
const CONTRAST_TOKENS := [["INK", "CARD_BG"], ["CREAM", "DIALOGUE_BG"], ["POSITIVE", "CARD_BG"],
	["NEGATIVE", "CARD_BG"], ["POSITIVE_CB", "CARD_BG"], ["NEGATIVE_CB", "CARD_BG"]]
## What code paints on the frame (TopBar NET, runway, KEPENK, offer and logo; the ticker source as
## ACCENT_HEX): no theme reaches it, so UiTokens' own value meets the direction's frame.
const CONTRAST_CODE := ["POSITIVE_BRIGHT", "NEGATIVE_BRIGHT", "POSITIVE_BRIGHT_CB", "NEGATIVE_BRIGHT_CB",
	"ACCENT_CHROME"]

var yon := ""
var fails := 0
var tokens := {}   # UiTokens colour constant -> value, in declaration order
var groups := {}   # 8-bit RGBA key -> the token names sharing that value
var listed := {}   # the direction's TOKENS
var sites := {}    # "<key> <kind>" -> [count, how, token] over every master colour site


func _initialize() -> void:
	var args := OS.get_cmdline_args()
	for a in args:
		if a.begins_with("--yon="):
			yon = a.trim_prefix("--yon=")
	if yon == "":
		push_error("build_direction: pass --yon=<name>")
		quit(1)
		return
	var identity := args.has("--identity")
	var dir := THEMES + yon + "/"
	var master: Theme = load(MASTER)
	_index_tokens(load(UI_TOKENS).get_script_constant_map())
	var spec = null
	var faces := {}
	if identity:
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(dir))
		for role in ROLES:
			faces[role] = load(MASTER_FACES + role + ".tres")
	else:
		spec = load(dir + "direction.gd") if ResourceLoader.exists(dir + "direction.gd") else null
		var consts := _contract(spec)
		if fails > 0:
			_finish(false)
			return
		listed = consts["TOKENS"]
		_check_listed()
		faces = _faces(consts["FONTS"], dir)
	_check_faces(faces, master)
	var th := _copy(master, faces)
	_recolor(th)
	_report_tokens()
	if not identity:
		_canonical(th, spec, dir, faces)
		_flatten(th, master)
		var before := _snapshot(th)
		spec.adjust(th, dir, faces)
		_report_adjust(before, _snapshot(th))
		_join(th, master)
	_validate(th, master)
	_report_boxes(th)
	_report_hover(th)
	_report_contrast(th, master)
	_report_hot(th, master)
	var sources := [SELF, MASTER, UI_TOKENS] if identity else [SELF, MASTER, UI_TOKENS, dir + "direction.gd"]
	_finish(fails == 0 and _write(th, dir + "theme.tres", sources))


func _finish(written: bool) -> void:
	if not written:
		_out("NOT_WRITTEN", "theme.tres is left as it was")
	_out("RESULT", "%s fails=%d" % ["PASS" if fails == 0 else "FAIL", fails])
	quit(0 if fails == 0 else 1)


func _out(kind: String, msg: String) -> void:
	print("UILAB %s %s %s" % [yon, kind, msg])


func _fail(msg: String) -> void:
	fails += 1
	_out("FAIL", msg)


func _report(msg: String) -> void:
	_out("REPORT", msg)


# --- contract ----------------------------------------------------------------------------------

func _index_tokens(consts: Dictionary) -> void:
	for name in consts:
		var c = consts[name]
		if not c is Color:
			continue
		var key := _key(c)
		if groups.has(key) and tokens[groups[key][0]] != c:
			_fail("UiTokens %s and %s round to one value #%s" % [groups[key][0], name, key])
		tokens[name] = c
		groups.get_or_add(key, []).append(name)
	_out("TOKENS", "%d colours in %d values" % [tokens.size(), groups.size()])


## The direction's contract: three dictionaries, a 6 to 8 colour palette, two static functions.
func _contract(spec) -> Dictionary:
	if spec == null or not spec.can_instantiate():
		_fail("direction.gd is missing or does not compile")
		return {}
	var consts: Dictionary = spec.get_script_constant_map()
	for name in ["PALETTE", "TOKENS", "FONTS"]:
		if not consts.get(name) is Dictionary:
			_fail("direction.gd needs const %s as a Dictionary" % name)
	var statics := []
	for m in spec.get_script_method_list():
		if m["flags"] & METHOD_FLAG_STATIC:
			statics.append(m["name"])
	for f in ["canonical", "adjust"]:
		if not f in statics:
			_fail("direction.gd needs static func %s(th, dir, fonts)" % f)
	var palette = consts.get("PALETTE")
	if palette is Dictionary:
		if palette.size() < 6 or palette.size() > 8:
			_fail("PALETTE has %d colours, 6 to 8 expected" % palette.size())
		for name in palette:
			if not palette[name] is Color:
				_fail("PALETTE %s is not a Color" % name)
	return consts


## TOKENS keys are UiTokens colours; members of one same-valued group cannot differ, because the
## lab cannot tell their sites apart (a direction splits them per site in adjust()).
func _check_listed() -> void:
	for name in listed:
		if not tokens.has(name):
			_fail("TOKENS %s is not a UiTokens colour" % name)
		elif not listed[name] is Color:
			_fail("TOKENS %s is not a Color" % name)
	for key in groups:
		if SPLIT.has(key):
			continue
		var values := {}
		for name in groups[key]:
			if listed.get(name) is Color:
				values[listed[name]] = name
		if values.size() > 1:
			_fail("TOKENS %s share one UiTokens value #%s but differ" % [" ".join(PackedStringArray(values.values())), key])


# --- faces ---------------------------------------------------------------------------------------

func _faces(specs: Dictionary, dir: String) -> Dictionary:
	var ts := TextServerManager.get_primary_interface()
	var symbols: FontFile = load(SYMBOLS)
	var faces := {}
	for role in ROLES:
		if not specs.has(role):
			_fail("FONTS has no %s" % role)
	for role in specs:
		var spec: Dictionary = specs[role]
		var path: String = spec.get("file", "")
		if not path.begins_with("res://"):
			path = dir + path
		var base = load(path) if ResourceLoader.exists(path) else null
		if not base is FontFile:
			_fail("FONTS %s: %s does not load as a font (imported?)" % [role, path])
			continue
		var fv := FontVariation.new()
		fv.base_font = base
		fv.fallbacks = [symbols]
		var supported: Dictionary = base.get_supported_variation_list()
		var axes := {}
		for axis in spec.get("axes", {}):
			var tag := ts.name_to_tag(axis)
			var v = spec["axes"][axis]
			if not supported.has(tag) or not typeof(v) in [TYPE_INT, TYPE_FLOAT]:
				_fail("FONTS %s: axis %s=%s is not supported by %s" % [role, axis, v, path.get_file()])
				continue
			var span: Vector3i = supported[tag]
			axes[tag] = clampf(v, span.x, span.y)
			if axes[tag] != v:
				_report("font %s: %s clamped to %d" % [role, axis, axes[tag]])
		if supported.has(ts.name_to_tag("opsz")) and not spec.get("axes", {}).has("opsz"):
			_report("font %s: opsz not set, one optical size draws at every size" % role)
		fv.variation_opentype = axes
		var features := {}
		for feature in spec.get("features", {}):
			features[ts.name_to_tag(feature)] = int(spec["features"][feature])
		fv.opentype_features = features
		fv.spacing_glyph = spec.get("spacing_glyph", load(MASTER_FACES + role + ".tres").spacing_glyph if role in ROLES else 0)
		faces[role] = fv
	return faces


## Turkish glyphs on the base face itself (fallbacks and system fonts would hide a miss), faces that
## share a variable file must differ in width, and every role's metrics against the master face.
func _check_faces(faces: Dictionary, master: Theme) -> void:
	var ts := TextServerManager.get_primary_interface()
	var tnum := ts.name_to_tag("tnum")
	var sizes := _sizes_by_role(master)
	var by_file := {}
	for role in faces:
		var fv: FontVariation = faces[role]
		var base: Font = fv.base_font
		if base == null:
			_fail("font %s has no base font" % role)
			continue
		var missing := ""
		for ch in GLYPHS:
			if not ts.font_has_char(base.get_rids()[0], ch.unicode_at(0)):
				missing += ch
		if missing != "":
			_fail("font %s: %s has no %s" % [role, base.get_font_name(), missing])
		var line := "font %s %s (%s)" % [role, face_name(fv), base.resource_path.get_file()]
		if fv.opentype_features.has(tnum):
			line += " tnum " + ("ok" if base.get_supported_feature_list().has(tnum) else "UNSUPPORTED")
		if role in ROLES:
			var old: Font = load(MASTER_FACES + role + ".tres")
			for s in sizes.get(role, []):
				line += " h%d %.0f>%.0f" % [s, old.get_height(s), fv.get_height(s)]
			line += " width x%.2f" % (_width(fv, SAMPLE, 13) / _width(old, SAMPLE, 13))
		_report(line)
		by_file.get_or_add(base.resource_path, []).append(role)
	var wght := ts.name_to_tag("wght")
	for path in by_file:
		var roles: Array = by_file[path]
		if not faces[roles[0]].base_font.get_supported_variation_list().has(wght):
			continue
		for i in roles.size():
			for j in range(i + 1, roles.size()):
				var a: FontVariation = faces[roles[i]]
				var b: FontVariation = faces[roles[j]]
				if a.variation_opentype != b.variation_opentype and is_equal_approx(_width(a, SAMPLE, 16), _width(b, SAMPLE, 16)):
					_fail("font %s and %s draw one width from %s: the axes do not reach the face" % [roles[i], roles[j], path.get_file()])


## Sizes each master role is drawn at: every type's face and size for each font key, both resolved
## up its chain.
func _sizes_by_role(master: Theme) -> Dictionary:
	var out := {"sans_reg": [master.default_font_size]}
	for type in master.get_type_list():
		for key in ["font", "normal_font", "bold_font", "italics_font", "bold_italics_font", "mono_font"]:
			var font = _up(master, Theme.DATA_TYPE_FONT, key, type)
			var size = _up(master, Theme.DATA_TYPE_FONT_SIZE, key + "_size", type)
			var at: Array = out.get_or_add(_role(font if font != null else master.default_font), [])
			var s = size if size != null else master.default_font_size
			if not s in at:
				at.append(s)
	for role in out:
		out[role].sort()
	return out


func _role(font: Font) -> String:
	return font.resource_path.get_file().get_basename()


func _width(font: Font, text: String, size: int) -> float:
	return font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x


# --- copy and colour -----------------------------------------------------------------------------

## A fresh theme holding every master type, base and item; master's objects are never touched.
## Shared boxes stay shared through one copy each.
func _copy(master: Theme, faces: Dictionary) -> Theme:
	var th := Theme.new()
	var boxes := {}
	var counts := {"variations": 0}
	for kind in DT:
		counts[kind] = 0
	for type in master.get_type_list():
		var base := master.get_type_variation_base(type)
		if base != &"":
			th.set_type_variation(type, base)
			counts["variations"] += 1
		for dt in Theme.DATA_TYPE_MAX:
			for item in master.get_theme_item_list(dt, type):
				var v = master.get_theme_item(dt, item, type)
				if dt == Theme.DATA_TYPE_FONT:
					v = faces.get(_role(v))
				elif dt == Theme.DATA_TYPE_STYLEBOX:
					if not boxes.has(v):
						boxes[v] = v.duplicate()
					v = boxes[v]
				th.set_theme_item(dt, item, type, v)
				counts[DT[dt]] += 1
	th.default_font = faces.get(_role(master.default_font))
	th.default_font_size = master.default_font_size
	var line := PackedStringArray()
	for kind in EXPECTED:
		line.append("%s=%d" % [kind, counts[kind]])
		if counts[kind] != EXPECTED[kind]:
			_fail("master holds %s=%d, the builder expects %d" % [kind, counts[kind], EXPECTED[kind]])
	_out("COPY", " ".join(line) + " boxes=%d" % boxes.size())
	return th


## One pass by token identity: a new value never feeds another lookup. Defaults nothing draws (an
## edge colour without a border width, a shadow colour without a shadow) are left alone.
func _recolor(th: Theme) -> void:
	for type in th.get_type_list():
		for item in th.get_color_list(type):
			th.set_color(item, type, _tone(th.get_color(item, type), "FONT"))
	var boxes := {}
	for type in th.get_type_list():
		for item in th.get_stylebox_list(type):
			boxes[th.get_stylebox(item, type)] = true
	for sb in boxes:
		if sb is StyleBoxFlat:
			sb.bg_color = _tone(sb.bg_color, "FILL")
			if sb.border_width_left + sb.border_width_top + sb.border_width_right + sb.border_width_bottom > 0:
				sb.border_color = _tone(sb.border_color, "EDGE")
			if sb.shadow_size > 0:
				sb.shadow_color = _tone(sb.shadow_color, "SHADOW")
		elif sb is StyleBoxLine:
			sb.color = _tone(sb.color, "LINE")
		elif sb is StyleBoxTexture:
			sb.modulate_color = _tone(sb.modulate_color, "FILL")


func _tone(c: Color, kind: String) -> Color:
	var r := _resolve(c, kind)
	var site := "%s %s" % [_key(c), kind]
	if not sites.has(site):
		sites[site] = [0, r[1], r[2]]
	sites[site][0] += 1
	return r[0]


## [value, how, token]. how: clear (alpha 0, kept) · listed · alpha (a listed opaque parent under
## the site's own alpha) · kept (a token nobody listed) · literal (no token has this value).
func _resolve(c: Color, kind: String) -> Array:
	if c.a == 0.0:
		return [c, "clear", ""]
	var key := _key(c)
	var hit := _listed(key, kind)
	if hit != "":
		return [listed[hit], "listed", hit]
	var parent := _listed(_key(Color(c, 1.0)), kind) if c.a < 1.0 else ""
	if parent != "":
		return [Color(listed[parent], c.a), "alpha", parent]
	return [c, "kept" if groups.has(key) else "literal", ""]


## The listed token that speaks for a value: the kind's own name for a split value, else any
## member of the value's group.
func _listed(key: String, kind: String) -> String:
	var names: Array = [SPLIT[key][kind]] if SPLIT.has(key) and SPLIT[key].has(kind) else groups.get(key, [])
	for name in names:
		if listed.has(name):
			return name
	return ""


func _key(c: Color) -> String:
	return c.to_html(true)


func _report_tokens() -> void:
	var unmapped := PackedStringArray()
	for name in tokens:
		var key := _key(tokens[name])
		var kind := ""
		for k in SPLIT.get(key, {}):
			if SPLIT[key][k] == name:
				kind = k
		var count := 0
		for site in sites:
			var at: PackedStringArray = site.split(" ")
			if at[0] == key and (kind == "" or at[1] == kind):
				count += sites[site][0]
		var r := _resolve(tokens[name], kind)
		if r[1] == "listed" or r[1] == "alpha":
			var how: String = "listed" if r[2] == name and r[1] == "listed" else "%s:%s" % ["group" if r[1] == "listed" else "alpha", r[2]]
			_report("token %s #%s > #%s %s sites=%d%s" % [name, key, _key(r[0]), how, count, "" if count > 0 else " (no site in the lab)"])
		elif count > 0:
			unmapped.append(name)
	_report("tokens unmapped: " + " ".join(unmapped))
	for site in _sorted(sites.keys()):
		if sites[site][1] == "literal":
			_report("colour #%s has no token, %d sites" % [site, sites[site][0]])


# --- canonical, ROLE_MAP, join ---------------------------------------------------------------

func _canonical(th: Theme, spec, dir: String, faces: Dictionary) -> void:
	for name in CANON:
		th.set_type_variation(name, CANON[name])
	spec.canonical(th, dir, faces)
	var ok := 0
	for name in CANON:
		var missing := PackedStringArray()
		for item in REQUIRED.get(name, BUTTON_ITEMS):
			var at: PackedStringArray = item.split("/")
			if not at[1] in th.get_theme_item_list(DT.find(at[0]), name):
				missing.append(item)
		if th.get_type_variation_base(name) != StringName(CANON[name]) or not missing.is_empty():
			_fail("canonical %s: base %s (needs %s) missing [%s]" % [name, th.get_type_variation_base(name), CANON[name], " ".join(missing)])
		else:
			ok += 1
	_out("CANON", "%d/%d" % [ok, CANON.size()])


## Writes each canonical's look straight onto its targets; master's base links stay as they are,
## because a target's own items would shadow any re-routed base.
func _flatten(th: Theme, master: Theme) -> void:
	for canon in ROLE_MAP:
		for target in ROLE_MAP[canon]:
			match canon:
				"AttentionBadge":
					th.set_stylebox("panel", target, _fit(th.get_stylebox("normal", canon), master.get_stylebox("panel", target)))
				"DataMono":
					th.set_font("font", target, th.get_font("font", canon))
				"TickerLabel":
					th.set_font("normal_font", target, th.get_font("font", canon))
					th.set_color("default_color", target, th.get_color("font_color", canon))
				"FolderWindow", "PaperCard":
					th.set_stylebox("panel", target, _fit(th.get_stylebox("panel", canon), master.get_stylebox("panel", target)))
				_:
					_as_button(th, master, canon, target)
	for twin in HOVER_TWINS:
		var own = th.get_stylebox("panel", twin)
		var sb = _fit(th.get_stylebox("panel", "PaperCard"), master.get_stylebox("panel", twin))
		if sb is StyleBoxFlat and own is StyleBoxFlat:
			sb.border_color = own.border_color
			for side in 4:
				sb.set_border_width(side, maxi(sb.get_border_width(side), own.get_border_width(side)))
		th.set_stylebox("panel", twin, sb)


## Every state the target defines takes the canonical's box (its normal where it has none); focus
## stays the target's. Text colours move only for keys the target defines, the face only when the
## canonical sets its own: has_font also answers true for the theme's default font.
func _as_button(th: Theme, master: Theme, canon: String, target: String) -> void:
	for state in master.get_stylebox_list(target):
		if state == "focus":
			continue
		var src := th.get_stylebox(state if th.has_stylebox(state, canon) else "normal", canon)
		th.set_stylebox(state, target, _fit(src, master.get_stylebox(state, target)))
	for key in master.get_color_list(target):
		if key.begins_with("font_") and th.has_color(key, canon):
			th.set_color(key, target, th.get_color(key, canon))
	if "font" in th.get_font_list(canon):
		th.set_font("font", target, th.get_font("font", canon))


## A copy of the canonical box carrying the target's effective content margins, written out
## explicitly (a -1 left in place would fall back to the new box's border or texture margin).
func _fit(src: StyleBox, target: StyleBox) -> StyleBox:
	var sb: StyleBox = src.duplicate()
	for side in 4:
		sb.set_content_margin(side, target.get_margin(side))
	return sb


func _join(th: Theme, master: Theme) -> void:
	for type in JOIN:
		for state in master.get_stylebox_list(type):
			if state == "focus":
				continue
			var sb = th.get_stylebox(state, type).duplicate()
			if sb is StyleBoxFlat or sb is StyleBoxTexture:
				sb.set_expand_margin(JOIN[type][0], JOIN[type][1])
			else:
				_report("join %s/%s is a %s and cannot reach the rail edge" % [type, state, sb.get_class()])
			th.set_stylebox(state, type, sb)


# --- validation ----------------------------------------------------------------------------------

## Coverage and layout: every master base and item is there, and no content margin, font size,
## constant or icon size differs; nothing that sizes a box is added to a master type.
func _validate(th: Theme, master: Theme) -> void:
	var master_types := master.get_type_list()
	for type in master_types:
		if th.get_type_variation_base(type) != master.get_type_variation_base(type):
			_fail("%s sits on %s, master on %s" % [type, th.get_type_variation_base(type), master.get_type_variation_base(type)])
		for dt in Theme.DATA_TYPE_MAX:
			var have := th.get_theme_item_list(dt, type)
			var had := master.get_theme_item_list(dt, type)
			for item in had:
				if not item in have:
					_fail("%s/%s/%s is missing" % [type, DT[dt], item])
				elif not _same_metrics(dt, master.get_theme_item(dt, item, type), th.get_theme_item(dt, item, type)):
					_fail("%s/%s/%s changes a metric" % [type, DT[dt], item])
			if dt in [Theme.DATA_TYPE_CONSTANT, Theme.DATA_TYPE_FONT_SIZE, Theme.DATA_TYPE_STYLEBOX]:
				for item in have:
					if not item in had:
						_fail("%s/%s/%s is added to a master type" % [type, DT[dt], item])
	if th.default_font_size != master.default_font_size:
		_fail("default font size %d, master %d" % [th.default_font_size, master.default_font_size])
	if th.default_font == null:
		_fail("default font is null")
	# has_font answers true for any name while a default font is set; without it the stored item speaks.
	var face := th.default_font
	th.default_font = null
	for type in _sorted(th.get_type_list()):
		if not type in master_types and not CANON.has(type):
			_report("extra type %s" % type)
		for dt in [Theme.DATA_TYPE_FONT, Theme.DATA_TYPE_ICON, Theme.DATA_TYPE_STYLEBOX]:
			for item in th.get_theme_item_list(dt, type):
				var v = th.get_theme_item(dt, item, type) if th.has_theme_item(dt, item, type) else null
				if v == null or (v is FontVariation and v.base_font == null) or (v is StyleBoxTexture and v.texture == null):
					_fail("%s/%s/%s is null" % [type, DT[dt], item])
	th.default_font = face
	# HRUiShared recolours the morale bar only on a flat fill.
	for type in ["ProgressBar", "BuildProgress"]:
		if not th.get_stylebox("fill", type) is StyleBoxFlat:
			_fail("%s fill must stay a StyleBoxFlat" % type)


func _same_metrics(dt: int, a, b) -> bool:
	match dt:
		Theme.DATA_TYPE_STYLEBOX:
			for side in 4:
				if a.get_margin(side) != b.get_margin(side):
					return false
		Theme.DATA_TYPE_FONT_SIZE, Theme.DATA_TYPE_CONSTANT:
			return a == b
		Theme.DATA_TYPE_ICON:
			return a.get_size() == b.get_size()
	return true


# --- reports -------------------------------------------------------------------------------------

func _report_adjust(before: Dictionary, after: Dictionary) -> void:
	for at in _sorted(after.keys()):
		if before.get(at) != after[at]:
			_report("adjust %s %s" % ["changed" if before.has(at) else "added", at])
	for at in _sorted(before.keys()):
		if not after.has(at):
			_report("adjust removed %s" % at)


func _report_boxes(th: Theme) -> void:
	var restyled := HOVER_TWINS.keys()
	for canon in ROLE_MAP:
		restyled.append_array(ROLE_MAP[canon])
	for type in _sorted(th.get_type_list()):
		for state in _sorted(th.get_stylebox_list(type)):
			var sb = th.get_stylebox(state, type)
			var at := "%s/%s" % [type, state]
			if sb is StyleBoxFlat or sb is StyleBoxTexture:
				var grow := Vector4(sb.expand_margin_left, sb.expand_margin_top, sb.expand_margin_right, sb.expand_margin_bottom)
				if grow != Vector4.ZERO:
					_report("expand %s L%d T%d R%d B%d" % [at, grow.x, grow.y, grow.z, grow.w])
			if sb is StyleBoxFlat and sb.shadow_size > 0:
				_report("shadow %s size %d offset %d,%d #%s" % [at, sb.shadow_size, sb.shadow_offset.x, sb.shadow_offset.y, _key(sb.shadow_color)])
			if not type in restyled:
				continue
			var over := PackedStringArray()
			for side in 4:
				var edge: float = sb.get_border_width(side) if sb is StyleBoxFlat else (sb.get_texture_margin(side) if sb is StyleBoxTexture else 0.0)
				if edge > sb.get_margin(side):
					over.append("%s %d>%d" % [SIDES[side], edge, sb.get_margin(side)])
			if not over.is_empty():
				_report("edge wider than the kept margin %s: %s" % [at, " ".join(over)])
			if sb is StyleBoxTexture and ENVELOPE.has(type):
				var env: Vector2 = ENVELOPE[type]
				if sb.texture_margin_left + sb.texture_margin_right > env.x or sb.texture_margin_top + sb.texture_margin_bottom > env.y:
					_report("nine-slice %s: texture margins exceed the %s it is drawn at" % [at, env])


func _report_hover(th: Theme) -> void:
	for twin in HOVER_TWINS:
		if _fp(th.get_stylebox("panel", twin)) == _fp(th.get_stylebox("panel", HOVER_TWINS[twin])):
			_report("hover %s: no visible delta" % twin)
	for canon in ["FolderTab", "FolderTabSelected", "PrimaryButton", "InkButton"]:
		for type in ROLE_MAP[canon]:
			if _fp(th.get_stylebox("normal", type)) == _fp(th.get_stylebox("hover", type)) \
					and th.get_color("font_color", type) == th.get_color("font_hover_color", type):
				_report("hover %s: no visible delta" % type)
	# feature_lines_view recolours the selected ledger row only on a flat box.
	if not th.get_stylebox("panel", "LedgerRow") is StyleBoxFlat:
		_report("warn LedgerRow panel is not flat: the Product feature lines lose their selected state")


func _report_contrast(th: Theme, master: Theme) -> void:
	for p in CONTRAST:
		_ratio_line("%s on %s" % [p[0], p[2]], _theme_pair(th, p), _theme_pair(master, p))
	for p in CONTRAST_TOKENS:
		var fg: Color = _resolve(tokens[p[0]], "FONT")[0]
		var bg: Color = _resolve(tokens[p[1]], "FILL")[0]
		_ratio_line("%s on %s" % p, _contrast(fg, bg), _contrast(tokens[p[0]], tokens[p[1]]))
	# BG_NEWS shares BG_TOPBAR's value, so one ground serves the TopBar and the ticker.
	var frame: Color = _resolve(tokens["BG_TOPBAR"], "FILL")[0]
	for fg in CONTRAST_CODE:
		_ratio_line("%s (code) on BG_TOPBAR" % fg, _contrast(tokens[fg], frame), _contrast(tokens[fg], tokens["BG_TOPBAR"]))
	# CREAM*, *_CHROME and VEIL_* also paint the dark cinematic stages.
	if frame.srgb_to_linear().get_luminance() > 0.5:
		_report("warn light frame: the dark stages keep CREAM text on DIALOGUE_BG and the VEIL_* whites")
		for veil in ["VEIL_FAINT_CHROME", "VEIL_SOFT_CHROME", "VEIL_STRONG_CHROME"]:
			if not listed.has(veil):
				_report("warn %s stays white over the light frame" % veil)


func _theme_pair(th: Theme, p: Array) -> float:
	var ground = th.get_stylebox(p[3], p[2])
	return _contrast(th.get_color(p[1], p[0]), ground.bg_color) if ground is StyleBoxFlat else -1.0


func _ratio_line(pair: String, now: float, was: float) -> void:
	if now < 0.0:
		_report("contrast %s: n/a, the ground is not flat" % pair)
		return
	var flags := ""
	if now < 4.5:
		flags += " LOW"
	if now < was - 0.05:
		flags += " WORSE"
	_report("contrast %s %.2f (master %.2f)%s" % [pair, now, was, flags])


## WCAG 2 contrast of text over its ground; translucent ink is composited first.
func _contrast(fg: Color, bg: Color) -> float:
	var a := bg.blend(fg).srgb_to_linear().get_luminance()
	var b := bg.srgb_to_linear().get_luminance()
	return (maxf(a, b) + 0.05) / (minf(a, b) + 0.05)


## Glyph metrics are not preserved by the copy: widths in the fixed slots and line heights.
func _report_hot(th: Theme, master: Theme) -> void:
	for hot in HOT:
		var native: String = hot[0]
		while master.get_type_variation_base(native) != &"":
			native = master.get_type_variation_base(native)
		var key := "normal_font" if native == "RichTextLabel" else "font"
		var was := _measure(master, hot[0], key, hot[1])
		var now := _measure(th, hot[0], key, hot[1])
		var slot: String = "" if hot[2] == 0 else " slot %d %s%s" % [hot[2], hot[3], " OVER" if now.x > hot[2] else ""]
		_report("hot %s width %.0f>%.0f height %.0f>%.0f%s" % [hot[0], was.x, now.x, was.y, now.y, slot])


func _measure(th: Theme, type: String, key: String, text: String) -> Vector2:
	var font = _up(th, Theme.DATA_TYPE_FONT, key, type)
	var size = _up(th, Theme.DATA_TYPE_FONT_SIZE, key + "_size", type)
	if font == null:
		font = th.default_font
	if size == null:
		size = th.default_font_size
	# A Label line is as tall as the tallest face in the fallback chain; a RichTextLabel line follows
	# the face that draws it.
	var height: float = font.get_height(size)
	if key == "normal_font":
		var ts := TextServerManager.get_primary_interface()
		var rid: RID = (font.base_font if font is FontVariation else font).get_rids()[0]
		height = ts.font_get_ascent(rid, size) + ts.font_get_descent(rid, size)
		if font is FontVariation:
			height += font.spacing_top + font.spacing_bottom
	return Vector2(_width(font, text, size), height)


# --- write ---------------------------------------------------------------------------------------

## Stable sub-resource and external ids, the file's uid kept and a digest of every source file in
## the metadata, so an unchanged rebuild is byte-identical and a stale file is detectable.
func _write(th: Theme, out: String, sources: Array) -> bool:
	var internal := []
	var external := []
	for type in _sorted(th.get_type_list()):
		for dt in [Theme.DATA_TYPE_FONT, Theme.DATA_TYPE_ICON, Theme.DATA_TYPE_STYLEBOX]:
			for item in _sorted(th.get_theme_item_list(dt, type)):
				_walk(th.get_theme_item(dt, item, type), internal, external)
	_walk(th.default_font, internal, external)
	var files := {}
	for path in sources:
		files[path] = true
	for r in external:
		files[r.resource_path] = true
		if r.resource_path.get_extension() == "tres":
			var deps := []
			for p in r.get_property_list():
				if p.usage & PROPERTY_USAGE_STORAGE:
					_walk(r.get(p.name), [], deps)
			for d in deps:
				files[d.resource_path] = true
	var lines := PackedStringArray()
	for path in _sorted(files.keys()):
		lines.append("%s %s" % [path, FileAccess.get_sha256(path)])
	var digest := "\n".join(lines).sha256_text()
	th.set_meta(&"uilab_source_digest", digest)
	for i in internal.size():
		internal[i].resource_scene_unique_id = "%s_%d" % [internal[i].get_class(), i + 1]
	for i in external.size():
		external[i].set_id_for_path(out, "%d_%s" % [i + 1, external[i].resource_path.md5_text().left(5)])
	var uid := _uid_of(out)
	if uid == ResourceUID.INVALID_ID:
		uid = ResourceUID.create_id_for_path(out)
	var err := ResourceSaver.save(th, out)
	if err == OK:
		err = ResourceSaver.set_uid(out, uid)
	if err != OK or _uid_of(out) != uid or FileAccess.file_exists(out + ".uidren"):
		_fail("could not write %s with uid %s (error %d)" % [out, ResourceUID.id_to_text(uid), err])
		return false
	_out("WROTE", "%s sha256 %s %s digest %s" % [out, FileAccess.get_sha256(out), ResourceUID.id_to_text(uid), digest])
	return true


## The uid in a text resource's header; ResourceLoader.get_resource_uid reads it only through the
## editor's file system.
func _uid_of(path: String) -> int:
	if not FileAccess.file_exists(path):
		return ResourceUID.INVALID_ID
	var found := RegEx.create_from_string("uid=\"(uid://[a-z0-9]+)\"").search(FileAccess.open(path, FileAccess.READ).get_line())
	return ResourceUID.text_to_id(found.get_string(1)) if found else ResourceUID.INVALID_ID


## Collects what the saver will embed (path-less resources, walked into) and reference (resources
## with their own file) in a stable order.
func _walk(v, internal: Array, external: Array) -> void:
	if v is Array:
		for x in v:
			_walk(x, internal, external)
	elif v is Resource:
		if v.resource_path != "" and not v.resource_path.contains("::"):
			if not v in external:
				external.append(v)
		elif not v in internal:
			internal.append(v)
			for p in v.get_property_list():
				if p.usage & PROPERTY_USAGE_STORAGE:
					_walk(v.get(p.name), internal, external)


# --- helpers -------------------------------------------------------------------------------------

## A face as it draws: the family and the axes its FontVariation sets. A variable file's own style
## name is its default instance, not what the variation draws, so it stands only for static faces.
static func face_name(font: Font) -> String:
	var base: Font = font.base_font if font is FontVariation else font
	var axes := PackedStringArray()
	if font is FontVariation:
		var ts := TextServerManager.get_primary_interface()
		for tag in font.variation_opentype:
			axes.append("%s %s" % [ts.tag_to_name(tag), font.variation_opentype[tag]])
	return "%s %s" % [base.get_font_name(), ", ".join(axes) if not axes.is_empty() else base.get_font_style_name()]


## An item stored on the type or the nearest base that stores it, else null. Stored lists, because
## has_theme_item answers true for every font and font size once the theme has defaults.
func _up(th: Theme, dt: int, item: String, type: String):
	while type != "":
		if item in th.get_theme_item_list(dt, type):
			return th.get_theme_item(dt, item, type)
		type = th.get_type_variation_base(type)
	return null


func _snapshot(th: Theme) -> Dictionary:
	var snap := {}
	for type in th.get_type_list():
		for dt in Theme.DATA_TYPE_MAX:
			for item in th.get_theme_item_list(dt, type):
				snap["%s/%s/%s" % [type, DT[dt], item]] = _fp(th.get_theme_item(dt, item, type))
	return snap


## A value as text: a file resource by path, an embedded one by its stored properties.
func _fp(v) -> String:
	if v is Resource:
		if v.resource_path != "" and not v.resource_path.contains("::"):
			return v.resource_path
		var parts := PackedStringArray([v.get_class()])
		for p in v.get_property_list():
			if p.usage & PROPERTY_USAGE_STORAGE and not p.name in ["resource_local_to_scene", "resource_name", "script"]:
				parts.append("%s=%s" % [p.name, _fp(v.get(p.name))])
		return " ".join(parts)
	if v is Array:
		return "[%s]" % ",".join(PackedStringArray(v.map(_fp)))
	return var_to_str(v)


func _sorted(list) -> Array:
	var a := Array(list)
	a.sort()
	return a
