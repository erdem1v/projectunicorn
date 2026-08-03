extends Control
## DEBUG-ONLY type specimen — "Font Duruşması".
##
## Renders IDENTICAL real-game content in four candidate font sets so the director can pick a
## family before the Theme Core task hard-codes one into build_theme.gd. Reached through
## `--font-spec=a|b|c|c-opsz` (dispatched from scripts/main/main.gd, debug builds only).
##
## The candidate TTFs live in user://font_spec/ — OUTSIDE the repo — and are loaded at runtime
## with FontFile.load_dynamic_font(). Nothing is imported, so no .import sidecars and no
## .godot/imported cache entries are created, and no font binary enters git.
##
## Fairness contract (do not break when editing):
##   * every face gets the SAME nine render properties, from one code path (_load_face)
##   * sizes / weights / spacing / colors / layout are identical across sets — only families change
##   * allow_system_fallback is OFF and no fallback font is attached, so a family missing a Turkish
##     glyph renders a visible tofu box instead of silently borrowing a Windows font
##
## Colors and sizes are read from UiTokens so the specimen cannot drift from the real palette.

# --- candidate sets -----------------------------------------------------------------------
# Per role: file = filename under user://font_spec/<dir>/, wght = variable-axis weight to pin
# (0 = static face, axis untouched), opsz = [lo, hi] axis range when the family has one.
const SETS := {
	"a": {
		"dir": "a",
		"serif_reg": {"file": "SourceSerif4-Regular.ttf", "wght": 0},
		"serif_sb": {"file": "SourceSerif4-Semibold.ttf", "wght": 0},
		"serif_it": {"file": "SourceSerif4-It.ttf", "wght": 0},
		"sans_reg": {"file": "IBMPlexSans-Regular.ttf", "wght": 0},
		"sans_sb": {"file": "IBMPlexSans-SemiBold.ttf", "wght": 0},
		"mono_reg": {"file": "JetBrainsMono-Regular.ttf", "wght": 0},
	},
	"b": {
		"dir": "b",
		"serif_reg": {"file": "Spectral-Regular.ttf", "wght": 0},
		"serif_sb": {"file": "Spectral-SemiBold.ttf", "wght": 0},
		"serif_it": {"file": "Spectral-Italic.ttf", "wght": 0},
		"sans_reg": {"file": "PublicSans-VF.ttf", "wght": 400},
		"sans_sb": {"file": "PublicSans-VF.ttf", "wght": 600},
		"mono_reg": {"file": "IBMPlexMono-Regular.ttf", "wght": 0},
	},
	"c": {
		"dir": "c",
		"serif_reg": {"file": "Fraunces-VF.ttf", "wght": 400, "opsz": [9, 144]},
		"serif_sb": {"file": "Fraunces-VF.ttf", "wght": 600, "opsz": [9, 144]},
		"serif_it": {"file": "FrauncesItalic-VF.ttf", "wght": 400, "opsz": [9, 144]},
		"sans_reg": {"file": "Inter-VF.ttf", "wght": 400, "opsz": [14, 32]},
		"sans_sb": {"file": "Inter-VF.ttf", "wght": 600, "opsz": [14, 32]},
		"mono_reg": {"file": "SpaceMono-Regular.ttf", "wght": 0},
	},
}

const ROLES: Array[String] = ["serif_reg", "serif_sb", "serif_it", "sans_reg", "sans_sb", "mono_reg"]

## Specimen measure. Close to the real ending-paper column (a 2.4 : 1 split of 1920) so the
## type is judged at a line length it actually gets in game, not full-bleed across 1920.
const COLUMN_W := 1320

## Turkish diacritics + the punctuation the UI actually leans on. Probed per face with
## Font.has_char() so a coverage hole is reported as data, not left to the eye.
const PROBE := "ĞÜŞİÖÇğüşıöçÂâÎî—·'$₺"

# --- specimen copy (identical in every set) -----------------------------------------------
const T_MASTHEAD := "EKONOMİ POSTASI"
const T_DATELINE := "ÇAR, 9 EYLÜL 2026 · SAYI 214"
const T_HEADLINE := "Unicorn Inc. Series B ile Ligini Değiştirdi"
const T_KICKER := "Yatırımcılar masaya oturdu; kurucular ölçüyü kaçırmadı."
const T_EVENT_TITLE := "Sözleşme yenilemesi masada"
const T_EVENT_BODY_1 := "İki aydır açık kalan hatalardan şikâyetçiler."
const T_EVENT_BODY_2 := "Ya indirim, ya söz."
const T_STRIP := "CASH $62,400 · MRR $12.0K · RUNWAY 5,2 ay · Çar, 9 Eyl 2026 · 14:10"
const T_TORTURE := "ĞÜŞİÖÇ ğüşıöç — İstanbul'da şirket kurmak: yığın, çağrı, öğün, ölçü, İŞ"

var _set_id: String = ""
var _use_opsz: bool = false
var _spec: Dictionary = {}          # role -> spec dict
var _files: Dictionary = {}         # absolute path -> FontFile
var _variations: Dictionary = {}    # "<role>@<px>" -> FontVariation


## Loads the set, prints the load + Turkish-coverage report, and builds the layout.
## Returns false (after push_error) if the set id is unknown or a face fails to load.
func build(set_id: String) -> bool:
	_set_id = set_id
	_use_opsz = set_id.ends_with("-opsz")
	var base_id: String = set_id.trim_suffix("-opsz")
	if not SETS.has(base_id):
		push_error("[FontSpec] unknown set '%s' (expected a|b|c|c-opsz)" % set_id)
		return false
	_spec = SETS[base_id]

	print("[FontSpec] set=%s  opsz_pinned=%s" % [set_id.to_upper(), str(_use_opsz)])
	var dir: String = "user://font_spec/%s/" % String(_spec["dir"])
	for role in ROLES:
		var entry: Dictionary = _spec[role]
		var path: String = dir + String(entry["file"])
		var face: FontFile = _load_face(path)
		if face == null:
			push_error("[FontSpec] could not load %s" % ProjectSettings.globalize_path(path))
			return false
		var missing: String = _missing_glyphs(face)
		var wght: int = int(entry.get("wght", 0))
		print("[FontSpec]   %-10s %-28s wght=%-4s %s" % [
			role,
			String(entry["file"]),
			("static" if wght == 0 else str(wght)),
			("coverage OK" if missing == "" else "MISSING: " + missing),
		])

	_report_weight_separation()
	_build_layout()
	return true


## A variable family only *looks* like it has two weights — if the wght axis silently fails to
## apply, Regular and SemiBold render identically and the specimen would quietly lie about the
## set having a bold. Measuring the same string at both weights turns that into a number.
func _report_weight_separation() -> void:
	for pair in [["serif_reg", "serif_sb", 30], ["sans_reg", "sans_sb", 14]]:
		var px: int = int(pair[2])
		var w_reg: float = _font(String(pair[0]), px).get_string_size(
				T_HEADLINE, HORIZONTAL_ALIGNMENT_LEFT, -1, px).x
		var w_sb: float = _font(String(pair[1]), px).get_string_size(
				T_HEADLINE, HORIZONTAL_ALIGNMENT_LEFT, -1, px).x
		var delta: float = w_sb - w_reg
		print("[FontSpec]   weight sep %-9s @%dpx  reg=%.1f  sb=%.1f  delta=%+.1f px %s" % [
			String(pair[0]).trim_suffix("_reg"), px, w_reg, w_sb, delta,
			("  <-- NO SEPARATION, wght axis not applied" if absf(delta) < 0.5 else ""),
		])


# --- font plumbing ------------------------------------------------------------------------

## One FontFile per physical TTF, cached by path. Every face gets the SAME nine properties —
## this is what makes "identical import settings" true by construction rather than by diffing
## .import sidecars. Values mirror the project's existing assets/fonts/*.ttf.import [params],
## except allow_system_fallback (see the header note).
func _load_face(path: String) -> FontFile:
	if _files.has(path):
		return _files[path]
	var f := FontFile.new()
	if f.load_dynamic_font(path) != OK:
		return null
	f.antialiasing = TextServer.FONT_ANTIALIASING_GRAY
	f.hinting = TextServer.HINTING_LIGHT
	# The importer stores 4 ("Auto except pixel fonts"); the runtime enum tops out at AUTO,
	# which is what 4 resolves to for every non-pixel font. Equivalent.
	f.subpixel_positioning = TextServer.SUBPIXEL_POSITIONING_AUTO
	f.keep_rounding_remainders = true
	f.disable_embedded_bitmaps = true
	f.multichannel_signed_distance_field = false
	f.generate_mipmaps = false
	f.force_autohinter = false
	f.oversampling = 0.0
	f.allow_system_fallback = false
	_files[path] = f
	return f


## 4-char OpenType axis tag -> the big-endian int Godot indexes variation coordinates by.
## Same packing as TextServer.name_to_tag() for 4-character names.
static func _ot_tag(s: String) -> int:
	return (s.unicode_at(0) << 24) | (s.unicode_at(1) << 16) | (s.unicode_at(2) << 8) | s.unicode_at(3)


func _missing_glyphs(face: FontFile) -> String:
	var missing: String = ""
	for i in PROBE.length():
		if not face.has_char(PROBE.unicode_at(i)):
			missing += PROBE[i]
	return missing


## role@size -> FontVariation. wght is pinned for variable families; opsz is pinned only in the
## c-opsz set, clamped into each family's axis range.
func _font(role: String, px: int) -> Font:
	var key: String = "%s@%d" % [role, px]
	if _variations.has(key):
		return _variations[key]
	var base_role: String = "mono_reg" if role == "mono_label" else role
	var entry: Dictionary = _spec[base_role]
	var fv := FontVariation.new()
	fv.base_font = _files["user://font_spec/%s/%s" % [String(_spec["dir"]), String(entry["file"])]]
	# variation_opentype keys must be INT OpenType tags. String keys ("wght") are accepted by
	# the setter but never match an axis, so the face silently renders its default instance —
	# i.e. Regular and SemiBold come out identical. _report_weight_separation() guards this.
	var axes: Dictionary = {}
	var wght: int = int(entry.get("wght", 0))
	if wght > 0:
		axes[_ot_tag("wght")] = wght
	if _use_opsz and entry.has("opsz"):
		var r: Array = entry["opsz"]
		axes[_ot_tag("opsz")] = clampi(px, int(r[0]), int(r[1]))
	if not axes.is_empty():
		fv.variation_opentype = axes
	if role == "mono_label":
		# Matches build_theme.gd:45 — _mkfont(FONT_MONO_REG, …, "mono_label", 0.6) → int(0.6 * 2.0).
		fv.spacing_glyph = 1
	_variations[key] = fv
	return fv


# --- tiny builders (per-node overrides, never a Theme resource) ----------------------------
# Overrides rather than a Theme: the project-wide gui/theme/custom = master_theme.tres would
# otherwise leak its own fonts into this subtree and quietly invalidate the comparison.

func _lbl(text: String, role: String, px: int, color: Color,
		align: int = HORIZONTAL_ALIGNMENT_LEFT) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_override("font", _font(role, px))
	l.add_theme_font_size_override("font_size", px)
	l.add_theme_color_override("font_color", color)
	l.horizontal_alignment = align
	return l


func _box(bg: Color, border_w: int, border_col: Color, radius: int,
		pad_x: int, pad_y: int) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.set_border_width_all(border_w)
	sb.border_color = border_col
	sb.set_corner_radius_all(radius)
	sb.content_margin_left = pad_x
	sb.content_margin_right = pad_x
	sb.content_margin_top = pad_y
	sb.content_margin_bottom = pad_y
	return sb


func _panel(sb: StyleBoxFlat) -> PanelContainer:
	var p := PanelContainer.new()
	p.add_theme_stylebox_override("panel", sb)
	return p


func _rule(color: Color, h: int) -> ColorRect:
	var r := ColorRect.new()
	r.color = color
	r.custom_minimum_size = Vector2(0, h)
	return r


func _vbox(sep: int) -> VBoxContainer:
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", sep)
	return v


func _hbox(sep: int) -> HBoxContainer:
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", sep)
	return h


func _spacer() -> Control:
	var c := Control.new()
	c.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return c


## Effect chip — mirrors UiFactory._make_chip (radius 3, pad 6/2, BadgeLabel = mono 9).
func _chip(text: String, bg: Color, fg: Color) -> PanelContainer:
	var p := _panel(_box(bg, 0, Color.TRANSPARENT, 3, 6, 2))
	p.size_flags_horizontal = Control.SIZE_SHRINK_END
	p.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	p.add_child(_lbl(text, "mono_reg", UiTokens.SIZE_BADGE, fg))
	return p


## Axis chip — mirrors hr_ui_shared.gd: transparent fill, 1px CARD_BORDER, radius 3, pad 7/3.
func _axis_chip(text: String) -> PanelContainer:
	var p := _panel(_box(Color(0, 0, 0, 0), 1, UiTokens.CARD_BORDER, 3, 7, 3))
	p.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	p.add_child(_lbl(text, "mono_reg", UiTokens.SIZE_BADGE, UiTokens.INK_MUTED))
	return p


# --- layout -------------------------------------------------------------------------------

func _build_layout() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)

	var bg := ColorRect.new()
	bg.color = UiTokens.BG_BODY
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var page := _vbox(0)
	page.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(page)

	page.add_child(_build_chrome())

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 40)
	margin.add_theme_constant_override("margin_right", 40)
	margin.add_theme_constant_override("margin_top", 26)
	margin.add_theme_constant_override("margin_bottom", 26)
	margin.size_flags_vertical = Control.SIZE_EXPAND_FILL
	page.add_child(margin)

	# Centered COLUMN_W column rather than the full 1920: the game's paper surfaces live in the
	# center viewport between two rails, so a full-bleed specimen would judge the type at a
	# measure it never actually gets. Expanding spacers above and below centre the block.
	var centre := _hbox(0)
	margin.add_child(centre)
	centre.add_child(_spacer())

	var body := _vbox(20)
	body.custom_minimum_size = Vector2(COLUMN_W, 0)
	body.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	centre.add_child(body)
	centre.add_child(_spacer())

	var lead := Control.new()
	lead.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(lead)
	body.add_child(_build_paper())
	body.add_child(_build_bottom_band())
	var tail := Control.new()
	tail.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(tail)


## Block 4 — dark chrome strip: the mono data strip, the top-bar caption/value grammar
## (the only place the sans is judged at 15px on dark), and the set letter.
func _build_chrome() -> PanelContainer:
	var sb := _box(UiTokens.BG_TOPBAR, 0, Color.TRANSPARENT, 0, 18, 0)
	sb.border_width_bottom = 1
	sb.border_color = UiTokens.SEPARATOR
	var strip := _panel(sb)
	strip.custom_minimum_size = Vector2(0, 56)

	var row := _hbox(24)
	row.alignment = BoxContainer.ALIGNMENT_BEGIN
	strip.add_child(row)

	for pair in [["CASH", "$62,400"], ["MRR", "$12.0K"], ["RUNWAY", "5,2 ay"]]:
		var cell := _vbox(2)
		cell.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		cell.add_child(_lbl(pair[0], "mono_label", UiTokens.SIZE_STAT_LABEL, UiTokens.CREAM_DIM))
		cell.add_child(_lbl(pair[1], "sans_sb", UiTokens.SIZE_STAT_VALUE, UiTokens.CREAM))
		row.add_child(cell)
		var sep := ColorRect.new()
		sep.color = UiTokens.SEPARATOR
		sep.custom_minimum_size = Vector2(1, 22)
		sep.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		row.add_child(sep)

	var data := _lbl(T_STRIP, "mono_reg", 11, UiTokens.CREAM)
	data.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(data)

	row.add_child(_spacer())

	var letter := _lbl(_set_id.to_upper(), "mono_reg", 28, UiTokens.ACCENT)
	letter.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(letter)
	return strip


## Blocks 1-3 on the cream paper surface (PaperPanel box from build_theme.gd).
func _build_paper() -> PanelContainer:
	var sb := _box(UiTokens.PAPER_BG, 0, Color.TRANSPARENT, 2, 44, 36)
	sb.border_width_right = 2
	sb.border_width_bottom = 2
	sb.border_color = UiTokens.PAPER_EDGE
	sb.shadow_color = UiTokens.PAPER_SHADOW
	sb.shadow_size = 12
	sb.shadow_offset = Vector2(0, 5)
	var paper := _panel(sb)

	var col := _vbox(12)
	paper.add_child(col)

	# Block 1 — gazete başlığı
	col.add_child(_lbl(T_MASTHEAD, "serif_sb", 54, UiTokens.INK_MUTED, HORIZONTAL_ALIGNMENT_CENTER))
	col.add_child(_rule(UiTokens.PAPER_RULE, 3))
	col.add_child(_lbl(T_DATELINE, "mono_label", 9, UiTokens.INK_DIM, HORIZONTAL_ALIGNMENT_CENTER))
	col.add_child(_lbl(T_HEADLINE, "serif_sb", 30, UiTokens.INK))
	col.add_child(_lbl(T_KICKER, "serif_it", 15, UiTokens.INK_MUTED))
	col.add_child(_rule(UiTokens.DIVIDER_LIGHT, 1))

	var cols := _hbox(28)
	col.add_child(cols)

	var left := _build_event_block()
	left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left.size_flags_stretch_ratio = 1.25
	cols.add_child(left)

	var right := _vbox(0)
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right.size_flags_stretch_ratio = 1.0
	right.add_child(_build_hr_card())
	cols.add_child(right)
	return paper


## Block 2 — event modal: serif title, sans body, choice rows with mono effect chips.
func _build_event_block() -> VBoxContainer:
	var v := _vbox(8)

	var head := _hbox(8)
	head.add_child(_chip("MÜŞTERİ", UiTokens.AMBER_BG, UiTokens.ACCENT_DEEP))
	head.add_child(_lbl("KARAR · GÜN 96", "mono_label", UiTokens.SIZE_SECTION_HEADER, UiTokens.INK_DIM))
	v.add_child(head)

	v.add_child(_lbl(T_EVENT_TITLE, "serif_sb", 30, UiTokens.INK))
	v.add_child(_rule(UiTokens.DIVIDER_LIGHT, 1))
	v.add_child(_lbl(T_EVENT_BODY_1, "sans_reg", 14, UiTokens.INK))
	v.add_child(_lbl(T_EVENT_BODY_2, "sans_reg", 14, UiTokens.INK))

	var choices := _vbox(8)
	v.add_child(choices)
	choices.add_child(_choice_row("İndirimi kabul et", "−$1.600/AY",
			UiTokens.NEGATIVE_BG, UiTokens.NEGATIVE))
	choices.add_child(_choice_row("Söz ver, ekibi hataya sür", "+KULLANICI",
			UiTokens.POSITIVE_BG, UiTokens.POSITIVE))
	return v


func _choice_row(label: String, chip_text: String, chip_bg: Color, chip_fg: Color) -> PanelContainer:
	var card := _panel(_box(UiTokens.CARD_BG, 1, UiTokens.CARD_BORDER, 4, 12, 8))
	var row := _hbox(10)
	card.add_child(row)
	var l := _lbl(label, "sans_sb", 14, UiTokens.INK)
	l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	l.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(l)
	row.add_child(_chip(chip_text, chip_bg, chip_fg))
	return card


## Block 3 — HR card. Name is NameSerif (serif Semibold 14), matching the live
## hr_employee_card.gd; the brief's "sans medium" was overridden so the specimen does not
## drift from the real card.
func _build_hr_card() -> PanelContainer:
	var card := _panel(_box(UiTokens.CARD_BG, 1, UiTokens.CARD_BORDER, 4, 12, 10))
	var v := _vbox(6)
	card.add_child(v)

	var ident := _hbox(10)
	v.add_child(ident)

	var avatar := _panel(_box(Color(0.45, 0.38, 0.32, 1), 0, Color.TRANSPARENT, 18, 0, 0))
	avatar.custom_minimum_size = Vector2(30, 30)
	avatar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var initials := _lbl("ZŞ", "sans_sb", 12, UiTokens.CREAM, HORIZONTAL_ALIGNMENT_CENTER)
	initials.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	avatar.add_child(initials)
	ident.add_child(avatar)

	var who := _vbox(2)
	who.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	who.add_child(_lbl("Zeynep Şahin", "serif_sb", UiTokens.SIZE_NAME, UiTokens.INK))
	who.add_child(_lbl("TEST UZMANI", "mono_reg", 10, UiTokens.INK_DIM))
	ident.add_child(who)

	var money := _vbox(2)
	money.alignment = BoxContainer.ALIGNMENT_END
	money.add_child(_lbl("Maaş $4.200/ay", "mono_reg", 10, UiTokens.INK_DIM,
			HORIZONTAL_ALIGNMENT_RIGHT))
	money.add_child(_lbl("11 aydır ekipte", "mono_reg", 10, UiTokens.INK_DIM,
			HORIZONTAL_ALIGNMENT_RIGHT))
	ident.add_child(money)

	var axes := _hbox(5)
	for chip in ["UZMANLIK 6", "HIZ 4", "UYUM 3"]:
		axes.add_child(_axis_chip(chip))
	axes.add_child(_spacer())
	v.add_child(axes)

	var morale := _hbox(8)
	morale.alignment = BoxContainer.ALIGNMENT_END
	morale.add_child(_lbl("MORAL", "mono_label", UiTokens.SIZE_SECTION_HEADER, UiTokens.INK_DIM))
	var bar := ProgressBar.new()
	bar.show_percentage = false
	bar.min_value = 0
	bar.max_value = 100
	bar.value = 62
	bar.custom_minimum_size = Vector2(150, 6)
	bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	bar.add_theme_stylebox_override("background", _box(Color(0.86, 0.83, 0.76, 1), 0,
			Color.TRANSPARENT, 3, 0, 0))
	bar.add_theme_stylebox_override("fill", _box(UiTokens.HEALTH_GREEN, 0,
			Color.TRANSPARENT, 3, 0, 0))
	morale.add_child(bar)
	morale.add_child(_lbl("62", "sans_sb", 12, UiTokens.HEALTH_GREEN))
	v.add_child(morale)
	return card


## Blocks 5-6 — the diacritic torture line at body sizes, then at the micro sizes our labels
## actually use (9 badge/caption, 10 row meta, 11 tab label / caption).
func _build_bottom_band() -> PanelContainer:
	var band := _panel(_box(UiTokens.CARD_BG, 1, UiTokens.CARD_BORDER, 4, 22, 16))
	var v := _vbox(9)
	band.add_child(v)

	v.add_child(_torture_row("SERİF 13", "serif_reg", UiTokens.SIZE_BODY))
	v.add_child(_torture_row("SANS 14", "sans_reg", 14))
	v.add_child(_torture_row("MONO 11", "mono_reg", 11))
	v.add_child(_rule(UiTokens.DIVIDER_LIGHT, 1))
	v.add_child(_torture_row("MONO 9", "mono_label", UiTokens.SIZE_BADGE))
	v.add_child(_torture_row("MONO 10", "mono_reg", 10))
	v.add_child(_torture_row("SANS 11", "sans_reg", UiTokens.SIZE_TAB_LABEL))
	v.add_child(_torture_row("SERİF 11", "serif_reg", UiTokens.SIZE_CAPTION))
	return band


func _torture_row(tag: String, role: String, px: int) -> HBoxContainer:
	var row := _hbox(14)
	var t := _lbl(tag, "mono_label", 9, UiTokens.INK_DIM)
	t.custom_minimum_size = Vector2(78, 0)
	t.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(t)
	var line := _lbl(T_TORTURE, role, px, UiTokens.INK)
	line.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(line)
	return row
