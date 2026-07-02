extends SceneTree

# ============================================================================
# Theme generator (run headless):
#   godot --headless --path <project> -s res://scripts/theme/build_theme.gd
#
# Builds FontVariation wrappers (carrying the symbol fallback) and generates
# themes/master_theme.tres from UiTokens. The theme is a BUILD ARTIFACT of
# UiTokens — re-run this whenever tokens or the font trio change.
#
# Fonts: Source Serif 4 (serif) + IBM Plex Sans (sans/numbers) + JetBrains Mono
# (labels/meta/ticker/badges). Fallback: Noto Sans Symbols 2.
# ============================================================================

const T = preload("res://scripts/theme/ui_tokens.gd")

const FONT_SERIF_REG := "res://assets/fonts/serif/SourceSerif4-Regular.ttf"
const FONT_SERIF_SB := "res://assets/fonts/serif/SourceSerif4-Semibold.ttf"
const FONT_SERIF_IT := "res://assets/fonts/serif/SourceSerif4-It.ttf"
const FONT_SANS_REG := "res://assets/fonts/sans/IBMPlexSans-Regular.ttf"
const FONT_SANS_SB := "res://assets/fonts/sans/IBMPlexSans-SemiBold.ttf"
const FONT_MONO_REG := "res://assets/fonts/mono/JetBrainsMono-Regular.ttf"
const FONT_SYMBOLS := "res://assets/fonts/fallback/NotoSansSymbols2-Regular.ttf"

const VAR_DIR := "res://assets/fonts/variations/"
const OUT_PATH := "res://themes/master_theme.tres"

func _initialize() -> void:
	print("[build_theme] start")
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(VAR_DIR))

	var symbols: FontFile = load(FONT_SYMBOLS)
	if symbols == null:
		push_error("[build_theme] symbol fallback failed to load — run --import first")
		quit(1)
		return

	# FontVariation wrappers (base font + symbol fallback; mono_label adds tracking)
	var serif_reg := _mkfont(FONT_SERIF_REG, symbols, "serif_reg", 0.0)
	var serif_sb := _mkfont(FONT_SERIF_SB, symbols, "serif_sb", 0.0)
	var serif_it := _mkfont(FONT_SERIF_IT, symbols, "serif_it", 0.0)
	var sans_reg := _mkfont(FONT_SANS_REG, symbols, "sans_reg", 0.0)
	var sans_sb := _mkfont(FONT_SANS_SB, symbols, "sans_sb", 0.0)
	var mono_reg := _mkfont(FONT_MONO_REG, symbols, "mono_reg", 0.0)
	var mono_label := _mkfont(FONT_MONO_REG, symbols, "mono_label", 0.6)

	var th := Theme.new()
	th.set_default_font(sans_reg)
	# default_font_size left unset -> inherits engine default (16); only the
	# typeface changes universally, minimizing reflow on out-of-scope screens.

	# ---- Label variations ----
	_lbl(th, &"TitleSerif", serif_sb, T.SIZE_PLACEHOLDER_TITLE, T.INK)
	_lbl(th, &"NameSerif", serif_sb, T.SIZE_NAME, T.INK)
	_lbl(th, &"BodySerif", serif_reg, T.SIZE_BODY, T.INK)
	_lbl(th, &"QuoteSerif", serif_it, 12, T.INK_MUTED)
	_lbl(th, &"CaptionMuted", serif_reg, T.SIZE_CAPTION, T.INK_MUTED)
	_lbl(th, &"SectionLabel", mono_label, T.SIZE_SECTION_HEADER, T.INK_DIM)
	_lbl(th, &"MetricCaption", mono_label, T.SIZE_STAT_LABEL, T.CREAM_DIM)
	_lbl(th, &"MetricValue", sans_sb, T.SIZE_STAT_VALUE, T.CREAM)
	_lbl(th, &"MetricDelta", mono_reg, T.SIZE_STAT_DELTA, T.CREAM_DIM)
	_lbl(th, &"MetricUnit", mono_reg, 9, T.CREAM_DIM)
	_lbl(th, &"TabLabel", sans_reg, T.SIZE_TAB_LABEL, T.INK_DIM)
	_lbl(th, &"BadgeLabel", mono_reg, T.SIZE_BADGE, T.INK)
	_lbl(th, &"ChoiceLabel", sans_reg, 14, T.INK)
	_lbl(th, &"FeedDay", mono_reg, T.SIZE_CAPTION, T.INK_MUTED)
	_lbl(th, &"ChromeSerif", serif_reg, T.SIZE_BODY, T.CREAM)
	_lbl(th, &"ChromeLabel", mono_label, T.SIZE_STAT_LABEL, T.CREAM_DIM)
	_lbl(th, &"ChromeValue", sans_sb, T.SIZE_BODY, T.CREAM)
	_lbl(th, &"RowName", sans_sb, 12, T.INK)
	_lbl(th, &"RowMeta", mono_reg, 10, T.INK_MUTED)
	_lbl(th, &"AvatarInitial", sans_sb, 12, T.CREAM)
	_lbl(th, &"MetricValueInk", sans_sb, 18, T.INK)
	_lbl(th, &"MetricCaptionInk", mono_label, 9, T.INK_DIM)

	# ---- Panel variations ----
	_panel(th, &"TopBarPanel", "Panel", _box(T.BG_TOPBAR, 0, Color.TRANSPARENT, 0, [0,0,0,1], T.SEPARATOR))
	_panel(th, &"SidePanel", "Panel", _box(T.BG_PANEL, 0, Color.TRANSPARENT, 0, [1,1,0,0], T.DIVIDER_LIGHT))
	_panel(th, &"NewsPanel", "Panel", _box(T.BG_NEWS, 0, Color.TRANSPARENT, 0, [0,0,1,0], T.SEPARATOR))
	_panel(th, &"ViewportPanel", "Panel", _box(T.BG_BODY, 0, Color.TRANSPARENT, 0))
	_panel(th, &"ModalPanel", "Panel", _box(T.CARD_BG, 1, T.CARD_BORDER, 6))
	_panel(th, &"ArtPanel", "Panel", _box(Color(0.22, 0.188, 0.149, 1), 0, Color.TRANSPARENT, 3))
	_panel(th, &"PhaseDotActive", "Panel", _box(T.ACCENT, 0, Color.TRANSPARENT, 2))
	_panel(th, &"PhaseDotDim", "Panel", _box(Color(0.35, 0.32, 0.27, 1), 0, Color.TRANSPARENT, 2))
	_panel(th, &"SelectedBorder", "Panel", _box(Color.TRANSPARENT, 2, T.ACCENT, 4))
	_panel(th, &"TabBadge", "Panel", _box(T.ACCENT, 0, Color.TRANSPARENT, 8))
	_panel(th, &"Avatar", "Panel", _box(Color(0.45, 0.38, 0.32, 1), 0, Color.TRANSPARENT, 18))
	_panel(th, &"CapBar", "Panel", _box(Color(0.45, 0.38, 0.32, 1), 0, Color.TRANSPARENT, 2))

	# ---- PanelContainer variations (auto content margins) ----
	_panel(th, &"CardPanel", "PanelContainer", _box(T.CARD_BG, 1, T.CARD_BORDER, 4, [1,1,1,1], T.CARD_BORDER, 12, 10))
	_panel(th, &"CardPanelTight", "PanelContainer", _box(T.CARD_BG, 1, T.CARD_BORDER, 4, [1,1,1,1], T.CARD_BORDER, 10, 8))
	_panel(th, &"CardAttention", "PanelContainer", _box(T.CARD_ATTENTION_BG, 1, Color(0.80, 0.62, 0.58, 1), 4, [1,1,1,1], Color(0.80, 0.62, 0.58, 1), 12, 10))
	_panel(th, &"ChoiceCard", "PanelContainer", _box(T.CARD_BG, 1, T.CARD_BORDER, 4, [1,1,1,1], T.CARD_BORDER, 12, 8))
	_panel(th, &"HeaderBand", "PanelContainer", _box(T.ACCENT, 0, Color.TRANSPARENT, 4, [1,1,1,1], Color.TRANSPARENT, 14, 8))

	# ---- Button variations ----
	_tab_button(th, &"TabButton", false)
	_tab_button(th, &"TabButtonActive", true)
	_speed_button(th, &"SpeedButton", false)
	_speed_button(th, &"SpeedButtonActive", true)
	_commit_button(th)

	# ---- RichTextLabel variations ----
	th.set_type_variation(&"BodyRich", &"RichTextLabel")
	th.set_font("normal_font", &"BodyRich", serif_reg)
	th.set_font("bold_font", &"BodyRich", serif_sb)
	th.set_font("italic_font", &"BodyRich", serif_it)
	th.set_font("bold_italic_font", &"BodyRich", serif_sb)
	th.set_font("mono_font", &"BodyRich", mono_reg)
	th.set_font_size("normal_font_size", &"BodyRich", 14)
	th.set_color("default_color", &"BodyRich", T.INK)

	th.set_type_variation(&"NewsRich", &"RichTextLabel")
	th.set_font("normal_font", &"NewsRich", mono_reg)
	th.set_font_size("normal_font_size", &"NewsRich", 12)
	th.set_color("default_color", &"NewsRich", T.CREAM)

	# ---- ProgressBar variation (amber fill) ----
	th.set_type_variation(&"BuildProgress", &"ProgressBar")
	th.set_stylebox("background", &"BuildProgress", _box(Color(0.86, 0.83, 0.76, 1), 0, Color.TRANSPARENT, 3))
	th.set_stylebox("fill", &"BuildProgress", _box(T.ACCENT, 0, Color.TRANSPARENT, 3))

	# ---- HSlider variation for the pricing lever: transparent track so the
	# amber grabber rides directly on the colored value band drawn behind it. ----
	var grabber: Texture2D = load("res://assets/icons/slider_grabber.svg")
	th.set_type_variation(&"PriceSlider", &"HSlider")
	th.set_stylebox("slider", &"PriceSlider", StyleBoxEmpty.new())
	th.set_stylebox("grabber_area", &"PriceSlider", StyleBoxEmpty.new())
	th.set_stylebox("grabber_area_highlight", &"PriceSlider", StyleBoxEmpty.new())
	th.set_constant("center_grabber", &"PriceSlider", 1)
	if grabber != null:
		th.set_icon("grabber", &"PriceSlider", grabber)
		th.set_icon("grabber_highlight", &"PriceSlider", grabber)
		th.set_icon("grabber_disabled", &"PriceSlider", grabber)

	# ---- HSlider variation for the settings volume level: a visible neutral
	# groove with an amber fill up to the amber grabber knob (unlike PriceSlider's
	# transparent overlay track). Reuses the same slider_grabber.svg. ----
	th.set_type_variation(&"VolumeSlider", &"HSlider")
	th.set_stylebox("slider", &"VolumeSlider", _box(T.CARD_BORDER, 0, Color.TRANSPARENT, 3, [], Color.TRANSPARENT, -1, 2))
	th.set_stylebox("grabber_area", &"VolumeSlider", _box(T.ACCENT, 0, Color.TRANSPARENT, 3, [], Color.TRANSPARENT, -1, 2))
	th.set_stylebox("grabber_area_highlight", &"VolumeSlider", _box(Color(0.94, 0.71, 0.33, 1), 0, Color.TRANSPARENT, 3, [], Color.TRANSPARENT, -1, 2))
	th.set_constant("center_grabber", &"VolumeSlider", 1)
	if grabber != null:
		th.set_icon("grabber", &"VolumeSlider", grabber)
		th.set_icon("grabber_highlight", &"VolumeSlider", grabber)
		th.set_icon("grabber_disabled", &"VolumeSlider", grabber)

	# ---- CheckButton variation for the settings toggle switch (first toggle in
	# the project). Strip the default button chrome (empty styleboxes) and supply
	# light-theme on/off pill graphics; text (if any) stays INK. ----
	var sw_on: Texture2D = load("res://assets/icons/switch_on.svg")
	var sw_off: Texture2D = load("res://assets/icons/switch_off.svg")
	th.set_type_variation(&"SettingsSwitch", &"CheckButton")
	for sb in ["normal", "hover", "pressed", "focus", "disabled", "hover_pressed"]:
		th.set_stylebox(sb, &"SettingsSwitch", StyleBoxEmpty.new())
	if sw_on != null:
		th.set_icon("checked", &"SettingsSwitch", sw_on)
		th.set_icon("checked_disabled", &"SettingsSwitch", sw_on)
	if sw_off != null:
		th.set_icon("unchecked", &"SettingsSwitch", sw_off)
		th.set_icon("unchecked_disabled", &"SettingsSwitch", sw_off)
	th.set_color("font_color", &"SettingsSwitch", T.INK)

	# ---- Base Button: light secondary default for every un-varied Button (onboarding
	# Back/steppers, sales Find/Pitch, build-HUD iteration/dev, modal Continue…).
	# Variations (CommitButton/SpeedButton/TabButton) still override this. ----
	th.set_stylebox("normal", &"Button", _box(T.CARD_BG, 1, T.CARD_BORDER, 4, [], Color.TRANSPARENT, 12, 6))
	th.set_stylebox("hover", &"Button", _box(Color(0.925, 0.902, 0.847, 1), 1, T.CARD_BORDER, 4, [], Color.TRANSPARENT, 12, 6))
	th.set_stylebox("pressed", &"Button", _box(Color(0.898, 0.871, 0.816, 1), 1, T.CARD_BORDER, 4, [], Color.TRANSPARENT, 12, 6))
	th.set_stylebox("disabled", &"Button", _box(Color(0.94, 0.925, 0.89, 1), 1, Color(0.9, 0.88, 0.83, 1), 4, [], Color.TRANSPARENT, 12, 6))
	th.set_color("font_color", &"Button", T.INK)
	th.set_color("font_hover_color", &"Button", T.INK)
	th.set_color("font_pressed_color", &"Button", T.INK)
	th.set_color("font_disabled_color", &"Button", T.INK_DIM)

	# ---- Base LineEdit: light input (onboarding text fields) ----
	th.set_stylebox("normal", &"LineEdit", _box(Color(0.98, 0.969, 0.941, 1), 1, T.CARD_BORDER, 4, [], Color.TRANSPARENT, 10, 6))
	th.set_stylebox("focus", &"LineEdit", _box(Color(0.98, 0.969, 0.941, 1), 1, T.ACCENT, 4, [], Color.TRANSPARENT, 10, 6))
	th.set_stylebox("read_only", &"LineEdit", _box(T.CARD_BG, 1, T.CARD_BORDER, 4, [], Color.TRANSPARENT, 10, 6))
	th.set_color("font_color", &"LineEdit", T.INK)
	th.set_color("font_placeholder_color", &"LineEdit", T.INK_DIM)
	th.set_color("font_uneditable_color", &"LineEdit", T.INK_MUTED)
	th.set_color("caret_color", &"LineEdit", T.INK)

	var err := ResourceSaver.save(th, OUT_PATH)
	if err != OK:
		push_error("[build_theme] save failed: %d" % err)
		quit(1)
		return
	print("[build_theme] wrote %s" % OUT_PATH)
	quit(0)


# --- helpers ----------------------------------------------------------------

func _mkfont(ttf_path: String, fallback: FontFile, vname: String, glyph_spacing: float) -> FontVariation:
	var base: FontFile = load(ttf_path)
	if base == null:
		push_error("[build_theme] font load failed: %s" % ttf_path)
		quit(1)
	var fv := FontVariation.new()
	fv.base_font = base
	fv.fallbacks = [fallback]
	if glyph_spacing != 0.0:
		fv.spacing_glyph = int(glyph_spacing * 2.0)  # px tracking at small sizes
	var path := VAR_DIR + vname + ".tres"
	ResourceSaver.save(fv, path)
	return load(path)


# bg, border width (uniform), border color, corner radius,
# optional per-side border widths [L,R,T,B] (overrides uniform) + per-side color,
# optional content margins h / v.
func _box(bg: Color, bw: int, bc: Color, radius: int, sides: Array = [], side_color: Color = Color.TRANSPARENT, mh: int = -1, mv: int = -1) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.set_corner_radius_all(radius)
	if sides.size() == 4:
		sb.border_width_left = sides[0]
		sb.border_width_right = sides[1]
		sb.border_width_top = sides[2]
		sb.border_width_bottom = sides[3]
		sb.border_color = side_color
	elif bw > 0:
		sb.set_border_width_all(bw)
		sb.border_color = bc
	if mh >= 0:
		sb.content_margin_left = mh
		sb.content_margin_right = mh
	if mv >= 0:
		sb.content_margin_top = mv
		sb.content_margin_bottom = mv
	return sb


func _lbl(th: Theme, name: StringName, font: Font, size: int, color: Color) -> void:
	th.set_type_variation(name, &"Label")
	th.set_font("font", name, font)
	th.set_font_size("font_size", name, size)
	th.set_color("font_color", name, color)


func _panel(th: Theme, name: StringName, base: StringName, sb: StyleBox) -> void:
	th.set_type_variation(name, base)
	th.set_stylebox("panel", name, sb)


func _tab_button(th: Theme, name: StringName, active: bool) -> void:
	th.set_type_variation(name, &"Button")
	var normal: StyleBoxFlat
	if active:
		normal = _box(Color(0.965, 0.949, 0.910, 0.7), 0, Color.TRANSPARENT, 0, [3,0,0,0], T.ACCENT)
	else:
		normal = _box(Color.TRANSPARENT, 0, Color.TRANSPARENT, 0, [0,0,1,0], T.DIVIDER_LIGHT)
	var hover := _box(Color(0, 0, 0, 0.04), 0, Color.TRANSPARENT, 0)
	th.set_stylebox("normal", name, normal)
	th.set_stylebox("hover", name, hover if not active else normal)
	th.set_stylebox("pressed", name, normal)
	th.set_stylebox("focus", name, _box(Color.TRANSPARENT, 0, Color.TRANSPARENT, 0))
	var fc: Color = T.INK if active else T.INK_DIM
	th.set_color("font_color", name, fc)
	th.set_color("font_hover_color", name, T.INK)
	th.set_color("font_pressed_color", name, fc)
	th.set_color("font_focus_color", name, fc)


func _speed_button(th: Theme, name: StringName, active: bool) -> void:
	th.set_type_variation(name, &"Button")
	var normal: StyleBoxFlat
	if active:
		normal = _box(Color(0.494, 0.353, 0.22, 1), 0, Color.TRANSPARENT, 3, [], Color.TRANSPARENT, 8, 3)
	else:
		normal = _box(Color(1, 1, 1, 0.04), 0, Color.TRANSPARENT, 3, [], Color.TRANSPARENT, 8, 3)
	var hover := _box(Color(1, 1, 1, 0.09), 0, Color.TRANSPARENT, 3, [], Color.TRANSPARENT, 8, 3)
	th.set_stylebox("normal", name, normal)
	th.set_stylebox("hover", name, hover if not active else normal)
	th.set_stylebox("pressed", name, normal)
	th.set_stylebox("focus", name, _box(Color.TRANSPARENT, 0, Color.TRANSPARENT, 0))
	th.set_font_size("font_size", name, 12)
	th.set_color("font_color", name, T.CREAM if active else T.CREAM_DIM)
	th.set_color("font_hover_color", name, T.CREAM)
	th.set_color("font_pressed_color", name, T.CREAM)


func _commit_button(th: Theme) -> void:
	var name := &"CommitButton"
	th.set_type_variation(name, &"Button")
	th.set_stylebox("normal", name, _box(T.ACCENT, 0, Color.TRANSPARENT, 4, [], Color.TRANSPARENT, 16, 10))
	th.set_stylebox("hover", name, _box(Color(0.94, 0.71, 0.33, 1), 0, Color.TRANSPARENT, 4, [], Color.TRANSPARENT, 16, 10))
	th.set_stylebox("pressed", name, _box(Color(0.80, 0.57, 0.20, 1), 0, Color.TRANSPARENT, 4, [], Color.TRANSPARENT, 16, 10))
	th.set_stylebox("disabled", name, _box(Color(0.86, 0.83, 0.76, 1), 0, Color.TRANSPARENT, 4, [], Color.TRANSPARENT, 16, 10))
	th.set_stylebox("focus", name, _box(Color.TRANSPARENT, 0, Color.TRANSPARENT, 0))
	th.set_color("font_color", name, T.INK)
	th.set_color("font_hover_color", name, T.INK)
	th.set_color("font_pressed_color", name, T.INK)
	th.set_color("font_disabled_color", name, T.INK_DIM)
