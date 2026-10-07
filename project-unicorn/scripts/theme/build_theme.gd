extends SceneTree

# ============================================================================
# Theme generator (run headless):
#   godot --headless --path <project> -s res://scripts/theme/build_theme.gd
#
# Builds the FontVariation wrappers and generates both themes from UiTokens; a theme is a BUILD
# ARTIFACT of UiTokens, so re-run this whenever tokens or faces change. Master is written first.
# - themes/master_theme.tres, the project theme (cream): Source Serif 4, IBM Plex Sans and
#   JetBrains Mono, every face falling back to Noto Sans Symbols 2.
# - themes/menajer_theme.tres (the dark language), set on the roots of migrated screens: Barlow
#   Condensed (falls back to Plex), IBM Plex Sans and Plex Sans Condensed, Source Serif 4; no
#   text face falls back to Noto, whose height would set every Label's line.
#
# Every size here is a UiTokens scale step: a variation picks a step, it never invents a number.
# ============================================================================

# Loaded in _initialize, not preloaded: ui_tokens.gd names the GameState autoload, which a
# `-s` script's own compile pass cannot resolve yet.
var T

const FONT_SERIF_REG := "res://assets/fonts/serif/SourceSerif4-Regular.ttf"
const FONT_SERIF_SB := "res://assets/fonts/serif/SourceSerif4-Semibold.ttf"
const FONT_SERIF_IT := "res://assets/fonts/serif/SourceSerif4-It.ttf"
const FONT_SANS_REG := "res://assets/fonts/sans/IBMPlexSans-Regular.ttf"
const FONT_SANS_SB := "res://assets/fonts/sans/IBMPlexSans-SemiBold.ttf"
const FONT_SANS_MED := "res://assets/fonts/sans/IBMPlexSans-Medium.ttf"
const FONT_SANS_B := "res://assets/fonts/sans/IBMPlexSans-Bold.ttf"
const FONT_SANSC_REG := "res://assets/fonts/sans/IBMPlexSansCondensed-Regular.ttf"
const FONT_COND_SB := "res://assets/fonts/cond/BarlowCondensed-SemiBold.ttf"
const FONT_COND_B := "res://assets/fonts/cond/BarlowCondensed-Bold.ttf"
const FONT_MONO_REG := "res://assets/fonts/mono/JetBrainsMono-Regular.ttf"
const FONT_MONO_SB := "res://assets/fonts/mono/JetBrainsMono-SemiBold.ttf"
const FONT_SYMBOLS := "res://assets/fonts/fallback/NotoSansSymbols2-Regular.ttf"

const VAR_DIR := "res://assets/fonts/variations/"
const OUT_PATH := "res://themes/master_theme.tres"

## Content margin "unset" (StyleBox default -1 = fall back to the border width).
const NO_PAD := Vector2i(-1, -1)

func _initialize() -> void:
	T = load("res://scripts/theme/ui_tokens.gd")
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(VAR_DIR))

	var symbols: FontFile = load(FONT_SYMBOLS)
	if symbols == null:
		push_error("[build_theme] symbol fallback failed to load — run --import first")
		quit(1)
		return

	# FontVariation wrappers (base font + symbol fallback; the label faces add tracking)
	var serif_reg := _mkfont(FONT_SERIF_REG, symbols, "serif_reg")
	var serif_sb := _mkfont(FONT_SERIF_SB, symbols, "serif_sb")
	var serif_it := _mkfont(FONT_SERIF_IT, symbols, "serif_it")
	var sans_reg := _mkfont(FONT_SANS_REG, symbols, "sans_reg")
	var sans_sb := _mkfont(FONT_SANS_SB, symbols, "sans_sb")
	var mono_reg := _mkfont(FONT_MONO_REG, symbols, "mono_reg")
	var mono_label := _mkfont(FONT_MONO_REG, symbols, "mono_label", 1)
	var mono_sb := _mkfont(FONT_MONO_SB, symbols, "mono_sb", 1)

	var th := Theme.new()
	th.set_default_font(sans_reg)
	# Stale-artifact guard: main.gd compares this against UiTokens.THEME_STAMP at boot.
	# The generator is run by hand, so nothing else notices a missed regeneration.
	th.set_constant(&"stamp", &"UiTokensStamp", T.THEME_STAMP)

	# ---- Label variations ----
	_lbl(th, &"TitleSerif", serif_sb, T.SIZE_DISPLAY, T.INK)
	_lbl(th, &"NameSerif", serif_sb, T.SIZE_LEAD, T.INK)
	_lbl(th, &"BodySerif", serif_reg, T.SIZE_BODY, T.INK)
	_lbl(th, &"QuoteSerif", serif_it, T.SIZE_BODY, T.INK_MUTED)
	_lbl(th, &"CaptionMuted", serif_reg, T.SIZE_SMALL, T.INK_MUTED)
	_lbl(th, &"SectionLabel", mono_label, T.SIZE_SMALL, T.INK_DIM)
	_lbl(th, &"MicroLabel", mono_label, T.SIZE_MICRO, T.INK_DIM)   # SectionLabel'in MICRO-adım kardeşi
	# MetricCaption / MetricValue / MetricUnit: the TopBar's stat columns, so they read the frame.
	_lbl(th, &"MetricCaption", mono_label, T.SIZE_META, T.INK_FAINT_CHROME)
	_lbl(th, &"MetricValue", mono_sb, T.SIZE_LEAD, T.CREAM)
	_lbl(th, &"MetricUnit", mono_reg, T.SIZE_META, T.INK_FAINT_CHROME)
	_lbl(th, &"BadgeLabel", mono_reg, T.SIZE_MICRO, T.INK)
	_lbl(th, &"ChromeValue", sans_sb, T.SIZE_BODY, T.CREAM)
	_lbl(th, &"ChromeClock", mono_reg, T.SIZE_DATA, T.CREAM_DIM)   # TopBar tarih/saat
	# ChromeAlert: KEPENK / TEKLİF geri sayımı. Tema statiktir; renk körü takası bu
	# etiketi top_bar.gd'de yeniden boyar.
	_lbl(th, &"ChromeAlert", mono_sb, T.SIZE_SMALL, T.NEGATIVE_BRIGHT)
	_lbl(th, &"RowName", sans_sb, T.SIZE_BODY, T.INK)
	_lbl(th, &"RowMeta", mono_reg, T.SIZE_SMALL, T.INK_MUTED)
	_lbl(th, &"AvatarInitial", sans_sb, T.SIZE_BODY, T.CREAM)
	_lbl(th, &"MetricValueInk", sans_sb, T.SIZE_TITLE, T.INK)
	_lbl(th, &"MetricCaptionInk", mono_label, T.SIZE_MICRO, T.INK_DIM)

	# ---- Cinematic dialogue register: text on the dark column ----
	_lbl(th, &"DialogueName", sans_sb, T.SIZE_LEAD, T.CREAM)  # counterpart name (uppercased in code)
	_lbl(th, &"DialogueTag", mono_label, T.SIZE_MICRO, T.CREAM_DIM)  # speaker-tag chip "ANCHOR — CANLI"
	_lbl(th, &"QuoteSerifCream", serif_it, T.SIZE_LEAD, T.CREAM)     # spoken line
	_lbl(th, &"DialogueMonologue", serif_it, T.SIZE_LEAD, T.CREAM_DIM) # interior voice
	_lbl(th, &"DialogueChoiceLabel", sans_reg, T.SIZE_LEAD, T.CREAM)   # choice text
	_lbl(th, &"DialogueOdds", mono_reg, T.SIZE_SMALL, T.CREAM_DIM)   # odds / caption line
	_lbl(th, &"DialogueNumber", mono_reg, T.SIZE_SMALL, T.CREAM_DIM) # step counter / numeric caption
	_lbl(th, &"ZoneLabel", mono_label, T.SIZE_MICRO, T.CREAM_DIM)    # micro caption on the dark screens

	# ---- Dark-register onboarding (3-page threshold ceremony) ----
	_lbl(th, &"TitleSerifCream", serif_sb, T.SIZE_ED_CEREMONY, T.CREAM)  # page title on dark ("Karakter")
	_lbl(th, &"SubtitleSerifCream", serif_it, T.SIZE_BODY, T.CREAM_DIM)  # italic page/section subtitle on dark

	# ---- Newspaper ending register ("Ekonomi Postası"): an island with its own
	# PAPER_INK_* ladder, so a body reskin never reaches the paper.
	_lbl(th, &"MastheadSerif", serif_sb, T.SIZE_ED_MASTHEAD, T.PAPER_INK_MAST)  # "EKONOMİ POSTASI"
	_lbl(th, &"NewsHeadlineSerif", serif_sb, T.SIZE_ED_HEADLINE, T.PAPER_INK)   # story headline (darkest)
	_lbl(th, &"NewsDeckSerif", serif_it, T.SIZE_LEAD, T.PAPER_INK_DECK)         # italic subhead / quoted deck
	_lbl(th, &"NewsCaptionSerif", serif_it, T.SIZE_SMALL, T.PAPER_INK_META)     # engraving caption (italic, dim)
	_lbl(th, &"NewsMeta", mono_label, T.SIZE_META, T.PAPER_INK_META)            # date / edition caps
	_lbl(th, &"NewsBodySerif", serif_reg, T.SIZE_BODY, T.PAPER_INK_BODY)        # ledger-line / notice body prose
	_lbl(th, &"NewsStatSerif", serif_sb, T.SIZE_ED_FIGURE, T.PAPER_INK)         # stat-row figures ("$4.0M")

	# ---- Panel variations ----
	_panel(th, &"TopBarPanel", "Panel", _sides_box(T.BG_TOPBAR, T.RADIUS_NONE, Vector4i(0, 0, 0, T.BORDER_HAIRLINE), T.SEPARATOR))
	# SideRailPanel: the cream tab rail; a right hairline divides it from the office.
	_panel(th, &"SideRailPanel", "Panel", _sides_box(T.BG_PANEL, T.RADIUS_NONE, Vector4i(0, 0, T.BORDER_HAIRLINE, 0), T.CARD_BORDER))
	_panel(th, &"NewsPanel", "Panel", _sides_box(T.BG_NEWS, T.RADIUS_NONE, Vector4i(0, T.BORDER_HAIRLINE, 0, 0), T.SEPARATOR))
	_panel(th, &"ViewportPanel", "Panel", _box(T.BG_BODY, T.RADIUS_NONE))
	_panel(th, &"PhaseDotActive", "Panel", _box(T.ACCENT_CHROME, T.RADIUS_XS))
	_panel(th, &"PhaseDotDim", "Panel", _box(T.DOT_IDLE_CHROME, T.RADIUS_XS))
	_panel(th, &"TabBadge", "Panel", _box(T.ACCENT, T.RADIUS_XL))
	_panel(th, &"Avatar", "Panel", _box(T.BG_AVATAR, T.RADIUS_PILL))

	# ---- PanelContainer variations (auto content margins) ----
	_panel(th, &"CardPanel", "PanelContainer", _box(T.CARD_BG, T.RADIUS_M, T.CARD_BORDER, T.PAD_CARD))
	# CardCta: "+ Yeni Ürün" davet kartı. StyleBoxFlat kesikli kenar çizemez; düz amber
	# en yakın karşılık.
	_panel(th, &"CardCta", "PanelContainer", _box(Color.TRANSPARENT, T.RADIUS_M, T.ACCENT_DEEP, T.PAD_CARD))
	_panel(th, &"CardPanelTight", "PanelContainer", _box(T.CARD_BG, T.RADIUS_M, T.CARD_BORDER, T.PAD_CARD_TIGHT))
	# CardPanelTightHover: a clickable tight card under the pointer; only the edge moves.
	_panel(th, &"CardPanelTightHover", "PanelContainer", _box(T.CARD_BG, T.RADIUS_M, T.BORDER_HOVER, T.PAD_CARD_TIGHT))
	_panel(th, &"CardAttention", "PanelContainer", _box(T.CARD_ATTENTION_BG, T.RADIUS_M, T.CARD_ATTENTION_BORDER, T.PAD_CARD))
	# AttentionStrip: kırmızı dikkat şeridi, sayfa başlığının hemen altında.
	_panel(th, &"AttentionStrip", "PanelContainer", _box(T.CARD_ATTENTION_BG, T.RADIUS_M, T.CARD_ATTENTION_BORDER, T.PAD_BAND))
	# Durum çipleri: ince renkli kenar + soluk dolgu.
	_panel(th, &"ChipNeutral", "PanelContainer", _box(T.NEUTRAL_BADGE_BG, T.RADIUS_S, T.BORDER_DISABLED, T.PAD_CHIP))
	_panel(th, &"ChipAmber", "PanelContainer", _box(T.AMBER_BG, T.RADIUS_S, T.ACCENT_DEEP, T.PAD_CHIP))
	_panel(th, &"ChipPositive", "PanelContainer", _box(T.POSITIVE_BG, T.RADIUS_S, T.POSITIVE_RULE, T.PAD_CHIP))
	_panel(th, &"ChipNegative", "PanelContainer", _box(T.NEGATIVE_BG, T.RADIUS_S, T.NEGATIVE_RULE, T.PAD_CHIP))
	_panel(th, &"ChoiceCard", "PanelContainer", _box(T.CARD_BG, T.RADIUS_M, T.CARD_BORDER, T.PAD_CHOICE))
	_panel(th, &"ChoiceCardHover", "PanelContainer", _box(T.CARD_BG, T.RADIUS_M, T.ACCENT_DEEP, T.PAD_CHOICE))
	_panel(th, &"HeaderBand", "PanelContainer", _sides_box(Color.TRANSPARENT, T.RADIUS_NONE, Vector4i(0, 0, 0, T.BORDER_HAIRLINE), T.BORDER_DISABLED, T.PAD_STRIP))
	# CardFloating: gövde üstünde yüzen kart (BuildHUD overlay'i).
	var floating_sb := _box(T.CARD_FLOATING_BG, T.RADIUS_L, T.CARD_BORDER, T.PAD_CARD_TIGHT)
	floating_sb.shadow_color = T.SHADOW_SOFT
	floating_sb.shadow_size = 6
	_panel(th, &"CardFloating", "PanelContainer", floating_sb)
	# WindowPanel: a tab's window over the office. No content margins: WindowFrame pads the page
	# itself, because its right gutter is wider than the other three sides (close glyph).
	var window_sb := _box(T.CARD_BG, T.RADIUS_WINDOW, T.CARD_BORDER)
	window_sb.shadow_color = T.SHADOW_SOFT
	window_sb.shadow_size = T.SPACE_S
	window_sb.shadow_offset = Vector2(0, T.SPACE_XXS)
	_panel(th, &"WindowPanel", "PanelContainer", window_sb)

	# ---- Cinematic dialogue register: dark panels ----
	# Card = solid charcoal for the Frank popup; DialogueChoice(+Hover) swap on mouse-over.
	_panel(th, &"DialogueCard", "Panel", _box(T.DIALOGUE_BG, T.RADIUS_CARD_LG, T.DIALOGUE_CARD_BORDER))
	_panel(th, &"PortraitFrame", "PanelContainer", _box(T.PORTRAIT_FRAME, T.RADIUS_PORTRAIT, Color.TRANSPARENT, T.PAD_FRAME))
	_panel(th, &"DialogueChoice", "PanelContainer", _box(T.DIALOGUE_CARD_BG, T.RADIUS_XL, T.DIALOGUE_CARD_BORDER, T.PAD_ROW))
	_panel(th, &"DialogueChoiceHover", "PanelContainer", _box(T.DIALOGUE_CARD_BG, T.RADIUS_XL, T.ACCENT_CHROME, T.PAD_ROW))

	# ---- Dark-register onboarding: portrait grid cells (hairline vs 2px amber ring) ----
	_panel(th, &"PortraitCell", "PanelContainer", _box(T.DIALOGUE_CARD_BG, T.RADIUS_L, T.DIALOGUE_CARD_BORDER, T.PAD_CELL))
	_panel(th, &"PortraitCellSelected", "PanelContainer", _box(T.DIALOGUE_CARD_BG, T.RADIUS_L, T.ACCENT_CHROME, T.PAD_CELL, T.BORDER_FOCUS))

	# ---- Newspaper ending panels ----
	# PaperPanel: the cream page is FLAT PRINT — 1px edge on all four sides, no radius,
	# no drop shadow — so it reads as a printed object rather than a UI card.
	_panel(th, &"PaperPanel", "PanelContainer", _box(T.PAPER_BG, T.RADIUS_NONE, T.PAPER_EDGE, T.PAD_SHEET))
	# ModalCard: the decision modal card (event · HR action · publish).
	var modal_card_sb := _box(T.CARD_BG, T.RADIUS_M, T.CARD_BORDER, T.PAD_PAGE)
	modal_card_sb.shadow_color = T.SHADOW_MODAL
	modal_card_sb.shadow_size = 40
	modal_card_sb.shadow_offset = Vector2(0, 10)
	_panel(th, &"ModalCard", "PanelContainer", modal_card_sb)
	# RailPanel: the dark meta rail — same charcoal as the screen, a left hairline divides it.
	_panel(th, &"RailPanel", "PanelContainer", _sides_box(T.DIALOGUE_BG, T.RADIUS_NONE, Vector4i(T.BORDER_HAIRLINE, 0, 0, 0), T.SEPARATOR, T.PAD_RAIL))
	# RailCard: Coming-Soon Tier2/Tier3 cards on the rail.
	_panel(th, &"RailCard", "PanelContainer", _box(T.DIALOGUE_CARD_BG, T.RADIUS_M, T.DIALOGUE_CARD_BORDER, T.PAD_CARD_RAIL))
	# EngravingFrame: the illustration frame on the paper; reads the paper ink because
	# its only consumer is the newspaper.
	_panel(th, &"EngravingFrame", "PanelContainer", _box(T.PAPER_PLATE, T.RADIUS_NONE, T.PAPER_INK_META, Vector2i.ZERO))

	# ---- Button variations ----
	_tab_button(th, &"TabButton", false)
	_tab_button(th, &"TabButtonActive", true)
	_speed_button(th, &"SpeedButton", false)
	_speed_button(th, &"SpeedButtonActive", true)
	_commit_button(th, &"CommitButton", false)
	_commit_button(th, &"CommitButtonDark", true)

	# DialogueGhost: quiet cream text button on the dark register, transparent until hovered.
	# Disabled and focus are set too: left to base Button they would draw the cream body's
	# edge and ink on the dark stage.
	th.set_type_variation(&"DialogueGhost", &"Button")
	var ghost := _box(Color.TRANSPARENT, T.RADIUS_M, Color.TRANSPARENT, T.PAD_BTN_GHOST)
	_states(th, &"DialogueGhost", {
		"normal": ghost,
		"hover": _box(T.VEIL_SOFT_CHROME, T.RADIUS_M, Color.TRANSPARENT, T.PAD_BTN_GHOST),
		"pressed": _box(T.VEIL_FAINT_CHROME, T.RADIUS_M, Color.TRANSPARENT, T.PAD_BTN_GHOST),
		"disabled": ghost,
		"focus": _no_focus(),
	})
	th.set_font_size("font_size", &"DialogueGhost", T.SIZE_SMALL)
	th.set_color("font_color", &"DialogueGhost", T.CREAM_DIM)
	th.set_color("font_hover_color", &"DialogueGhost", T.CREAM)
	th.set_color("font_pressed_color", &"DialogueGhost", T.CREAM_DIM)
	th.set_color("font_focus_color", &"DialogueGhost", T.CREAM_DIM)
	th.set_color("font_disabled_color", &"DialogueGhost", T.CREAM_DIM_DISABLED)

	# WindowClose: the × at a window's corner. Face and ink come from base Button; no
	# fill, hover moves only the edge, zero margins keep the glyph still. The host sizes it.
	th.set_type_variation(&"WindowClose", &"Button")
	var close_edge := _box(Color.TRANSPARENT, T.RADIUS_M, T.BORDER_HOVER, Vector2i.ZERO)
	_states(th, &"WindowClose", {
		"normal": _box(Color.TRANSPARENT, T.RADIUS_M, Color.TRANSPARENT, Vector2i.ZERO),
		"hover": close_edge,
		"pressed": close_edge,
		"focus": _no_focus(),
	})
	th.set_font_size("font_size", &"WindowClose", T.SIZE_BODY)

	# ActionRow: a row of a person's action list (HR). Flat until hovered; hover and press take
	# the selected-card wash and an amber left rule. Both boxes carry the same side margins, so
	# the row never jumps. Face and ink come from base Button.
	th.set_type_variation(&"ActionRow", &"Button")
	var row_flat := _box(Color.TRANSPARENT, T.RADIUS_NONE, Color.TRANSPARENT, T.PAD_ACTION_ROW)
	var row_hot := _sides_box(T.AMBER_WASH, T.RADIUS_NONE, Vector4i(T.BORDER_FOCUS, 0, 0, 0), T.ACCENT_DEEP, T.PAD_ACTION_ROW)
	_states(th, &"ActionRow", {
		"normal": row_flat,
		"hover": row_hot,
		"pressed": row_hot,
		"disabled": row_flat,
		"focus": _no_focus(),
	})

	# ---- RichTextLabel variations ----
	# Godot 4's keys are "italics_font"/"bold_italics_font" (with the s); "italic_font"
	# is silently ignored and *italic* spans fall back to the engine default.
	th.set_type_variation(&"NewsRich", &"RichTextLabel")
	th.set_font("normal_font", &"NewsRich", mono_reg)
	th.set_font_size("normal_font_size", &"NewsRich", T.SIZE_SMALL)
	th.set_color("default_color", &"NewsRich", T.CREAM_DIM)

	# ---- Base Button IS the ghost button (1px edge, mono, no fill). Hover moves the
	# BORDER to amber and leaves the fill alone, so every un-varied Button obeys the
	# hover law without a per-site decision. ----
	_states(th, &"Button", {
		"normal": _box(Color.TRANSPARENT, T.RADIUS_M, T.BORDER_HOVER, T.PAD_BTN),
		"hover": _box(Color.TRANSPARENT, T.RADIUS_M, T.ACCENT_DEEP, T.PAD_BTN),
		"pressed": _box(T.SURFACE_PRESSED, T.RADIUS_M, T.ACCENT_DEEP, T.PAD_BTN),
		"disabled": _box(Color.TRANSPARENT, T.RADIUS_M, T.BORDER_DISABLED, T.PAD_BTN),
	})
	th.set_font("font", &"Button", mono_label)
	th.set_color("font_color", &"Button", T.INK_MUTED)
	th.set_color("font_hover_color", &"Button", T.INK)
	th.set_color("font_pressed_color", &"Button", T.INK)
	th.set_color("font_disabled_color", &"Button", T.INK_DIM)

	# ---- DialogueInput: LineEdit for the dark onboarding register ----
	th.set_type_variation(&"DialogueInput", &"LineEdit")
	_states(th, &"DialogueInput", {
		"normal": _box(T.DIALOGUE_CARD_BG, T.RADIUS_M, T.DIALOGUE_CARD_BORDER, T.PAD_INPUT_LG),
		"focus": _box(T.DIALOGUE_CARD_BG, T.RADIUS_M, T.ACCENT_CHROME, T.PAD_INPUT_LG),
		"read_only": _box(T.DIALOGUE_CARD_BG, T.RADIUS_M, T.DIALOGUE_CARD_BORDER, T.PAD_INPUT_LG),
	})
	th.set_color("font_color", &"DialogueInput", T.CREAM)
	th.set_color("font_placeholder_color", &"DialogueInput", T.CREAM_DIM)
	th.set_color("caret_color", &"DialogueInput", T.CREAM)

	# ---- DialogueStepper: square −/+ button on the dark register (skill allocation);
	# DialogueGhost is too quiet for a repeat-press control. ----
	th.set_type_variation(&"DialogueStepper", &"Button")
	_states(th, &"DialogueStepper", {
		"normal": _box(T.DIALOGUE_CARD_BG, T.RADIUS_M, T.DIALOGUE_CARD_BORDER, T.PAD_BTN_S),
		"hover": _box(T.DIALOGUE_CARD_BG, T.RADIUS_M, T.CREAM_DIM, T.PAD_BTN_S),
		"pressed": _box(T.VEIL_SOFT_CHROME, T.RADIUS_M, T.CREAM_DIM, T.PAD_BTN_S),
		"disabled": _box(T.VEIL_FAINT_CHROME, T.RADIUS_M, T.VEIL_SOFT_CHROME, T.PAD_BTN_S),
		"focus": _no_focus(),
	})
	th.set_font_size("font_size", &"DialogueStepper", T.SIZE_LEAD)
	th.set_color("font_color", &"DialogueStepper", T.CREAM)
	th.set_color("font_hover_color", &"DialogueStepper", T.CREAM)
	th.set_color("font_pressed_color", &"DialogueStepper", T.CREAM)
	th.set_color("font_disabled_color", &"DialogueStepper", T.CREAM_DIM_DISABLED)

	# ---- Base LineEdit ----
	_states(th, &"LineEdit", {
		"normal": _box(T.SURFACE_INPUT, T.RADIUS_M, T.CARD_BORDER, T.PAD_INPUT),
		"focus": _box(T.SURFACE_INPUT, T.RADIUS_M, T.ACCENT_DEEP, T.PAD_INPUT),
		"read_only": _box(T.CARD_BG, T.RADIUS_M, T.CARD_BORDER, T.PAD_INPUT),
	})
	th.set_color("font_color", &"LineEdit", T.INK)
	th.set_color("font_placeholder_color", &"LineEdit", T.INK_DIM)
	th.set_color("font_uneditable_color", &"LineEdit", T.INK_MUTED)
	th.set_color("caret_color", &"LineEdit", T.INK)

	# ========================================================================
	# BASE-TYPE DEFAULTS
	# ========================================================================
	# Every un-varied Control falls through to Godot's default theme, whose probed
	# values are default_font_size 16, Label font_color white, PanelContainer inset
	# 0/0/0/0, separator separation 4. The base types below make a zero-styling
	# Control render on-brand.
	th.set_default_font_size(T.SIZE_BODY)
	# Controls are mono and small: every button in the mockups is mono 10.5-11.5, which
	# rounds to SIZE_DATA. Rail labels are a step below (SIZE_META).
	for pinned in [&"Button", &"CommitButton", &"LineEdit", &"DialogueInput"]:
		th.set_font_size("font_size", pinned, T.SIZE_DATA)
	for rail in [&"TabButton", &"TabButtonActive"]:
		th.set_font_size("font_size", rail, T.SIZE_META)
	th.set_color("font_focus_color", &"Button", T.INK)

	# Base Label: font and size deliberately UNSET so they inherit the defaults — that
	# inheritance is what makes a zero-styling Label on-brand.
	th.set_color("font_color", &"Label", T.INK)
	th.set_constant("line_spacing", &"Label", T.LEADING_BODY)

	# Panel is not a Container, so its stylebox cannot move anything.
	th.set_stylebox("panel", &"Panel", _box(T.CARD_BG, T.RADIUS_M, T.CARD_BORDER))
	# PanelContainer IS a Container: its content margins inset children, so the base
	# carries 0/0 to stay layout-neutral. CardPanel is the real card.
	th.set_stylebox("panel", &"PanelContainer", _box(T.CARD_BG, T.RADIUS_M, T.CARD_BORDER, Vector2i.ZERO))

	_rich_fonts(th, &"RichTextLabel", serif_reg, serif_sb, serif_it, mono_reg, T.SIZE_BODY)
	th.set_color("default_color", &"RichTextLabel", T.INK)
	th.set_constant("line_separation", &"RichTextLabel", T.LEADING_RICH)

	th.set_stylebox("background", &"ProgressBar", _box(T.SURFACE_SUNKEN, T.RADIUS_S))
	th.set_stylebox("fill", &"ProgressBar", _box(T.ACCENT, T.RADIUS_S))

	# Separators: recolour only; `separation` stays at Godot's default 4.
	th.set_stylebox("separator", &"HSeparator", _rule(T.DIVIDER_LIGHT, false))
	th.set_constant("separation", &"HSeparator", T.SPACE_XS)
	th.set_stylebox("separator", &"VSeparator", _rule(T.DIVIDER_LIGHT, true))
	th.set_constant("separation", &"VSeparator", T.SPACE_XS)

	# Tooltips are chrome, so they take the dark register.
	th.set_stylebox("panel", &"TooltipPanel", _box(T.BG_TOPBAR, T.RADIUS_S, T.SEPARATOR, T.PAD_TOOLTIP))
	th.set_font("font", &"TooltipLabel", sans_reg)
	th.set_font_size("font_size", &"TooltipLabel", T.SIZE_SMALL)
	th.set_color("font_color", &"TooltipLabel", T.CREAM)

	var err := _save(th, OUT_PATH)
	if err != OK:
		push_error("[build_theme] save failed: %d" % err)
		quit(1)
		return
	print("[build_theme] wrote %s" % OUT_PATH)

	var dark := _menajer(th)
	if dark == null:
		quit(1)
		return
	err = _save(dark, T.MENAJER_THEME)
	if err != OK:
		push_error("[build_theme] save failed: %d" % err)
		quit(1)
		return
	print("[build_theme] wrote %s" % T.MENAJER_THEME)
	quit(0)


# ============================================================================
# MENAJER THEME · the dark language. Every master type comes over first, with what it resolves in
# master (its own items, its bases', its class ancestors') in dark tokens and faces: a control in a
# dark root that still names a master variation keeps master's sizes and content margins. Then the
# base types and the new variations take the dark language's own ladder.
# ============================================================================

## The dark token for each cream token master draws, by how it is drawn: FILL a box's fill, EDGE
## its border, LINE a rule, SHADOW its shadow, FONT a text colour. A master colour missing here fails
## the build, so no cream value reaches menajer_theme.tres; disabled text always takes D_INK_OFF.
## Hover and selected edges become the hover border, amber text becomes emphasis ink.
const DARK_OF := {
	"FILL": {
		"BG_BODY": "D_SURFACE_0", "BG_TOPBAR": "D_SURFACE_1", "BG_PANEL": "D_SURFACE_1",
		"DIALOGUE_CARD_BG": "D_SURFACE_2", "SURFACE_INPUT": "D_SURFACE_2", "VEIL_FAINT_CHROME": "D_SURFACE_2",
		"CARD_BG": "D_SURFACE_3", "CARD_FLOATING_BG": "D_SURFACE_3", "DIALOGUE_BG": "D_SURFACE_3",
		"SURFACE_ROW_TINT": "D_SURFACE_4", "ACCENT_DIM": "D_SURFACE_4",
		"AMBER_BG": "D_SURFACE_4", "AMBER_WASH": "D_SURFACE_4", "VEIL_SOFT_CHROME": "D_SURFACE_4",
		"SURFACE_FRAME": "D_SURFACE_5", "BG_AVATAR": "D_SURFACE_5", "INK": "D_SURFACE_5",
		"SURFACE_SUNKEN": "D_BAR_TRACK", "CARD_BORDER": "D_BAR_TRACK", "DOT_IDLE_CHROME": "D_LINE_2",
		"PORTRAIT_FRAME": "D_LINE_3", "INK_DIM": "D_INK_3",
		"ACCENT": "D_ACCENT", "ACCENT_CHROME": "D_ACCENT", "ACCENT_HOVER": "D_ACCENT_HOVER",
		"ACCENT_HOVER_CHROME": "D_ACCENT_HOVER", "ACCENT_PRESSED": "D_ACCENT_PRESSED",
		"ACCENT_PRESSED_CHROME": "D_ACCENT_PRESSED",
		"CARD_ATTENTION_BG": "D_NEG_BG", "POSITIVE_BG": "D_POS_TAG_BG", "NEGATIVE_BG": "D_NEG_TAG_BG",
		"PAPER_BG": "PAPER_BG", "PAPER_PLATE": "PAPER_PLATE",
	},
	"EDGE": {
		"SEPARATOR": "D_LINE_1", "VEIL_SOFT_CHROME": "D_LINE_1", "CARD_BORDER": "D_LINE_2",
		"CARD_BORDER_CHROME": "D_LINE_2", "BORDER_HOVER": "D_LINE_HOVER", "BORDER_HOVER_CHROME": "D_LINE_HOVER",
		"ACCENT_DEEP": "D_LINE_HOVER", "ACCENT_CHROME": "D_LINE_HOVER", "CREAM_DIM": "D_LINE_HOVER",
		"CARD_ATTENTION_BORDER": "D_NEG_LINE", "POSITIVE_RULE": "D_POS_TAG_LINE",
		"PAPER_EDGE": "PAPER_EDGE", "PAPER_INK_META": "D_PAPER_INK_META",
	},
	"LINE": {"DIVIDER_LIGHT": "D_LINE_1"},
	"SHADOW": {"SHADOW_SOFT": "D_SHADOW_FLOAT", "SHADOW_MODAL": "D_HALO"},
	"FONT": {
		"INK": "D_INK_2", "CREAM": "D_INK_2", "INK_MUTED": "D_INK_3", "INK_DIM": "D_INK_3",
		"CREAM_DIM": "D_INK_3", "INK_FAINT_CHROME": "D_INK_3", "INK_DIM_CHROME": "D_INK_3",
		"INK_FAINT": "D_INK_4", "ACCENT": "D_INK_1", "ACCENT_DEEP": "D_INK_1", "ACCENT_CHROME": "D_INK_1",
		"INK_MUTED_CHROME": "D_INK_1", "CARD_BG": "D_SURFACE_3", "NEGATIVE_BRIGHT": "D_NEG",
		"PAPER_INK": "PAPER_INK", "PAPER_INK_BODY": "PAPER_INK_BODY", "PAPER_INK_DECK": "PAPER_INK_DECK",
		"PAPER_INK_MAST": "PAPER_INK_MAST", "PAPER_INK_META": "D_PAPER_INK_META",
	},
}
## The dark theme's drawn controls: the slider grabber, the switch pair, the dropdown's arrow and its list's check.
const DARK_ICONS := "res://assets/icons/dark/"
const INK_OF := {"normal": "font_color", "hover": "font_hover_color", "pressed": "font_pressed_color",
	"disabled": "font_disabled_color"}


## menajer_theme.tres, or null with the reasons pushed as errors: a master type, base or item it
## lacks, a box that leaves its content margins to the border, a master colour without a dark token.
func _menajer(master: Theme) -> Theme:
	var plex_reg: FontFile = load(FONT_SANS_REG)
	var plex_sb: FontFile = load(FONT_SANS_SB)
	var plex_b: FontFile = load(FONT_SANS_B)
	# Barlow's figures are proportional; Plex's are already equal width.
	var tnum := {TextServerManager.get_primary_interface().name_to_tag("tnum"): 1}
	var cond_sb := _mkfont(FONT_COND_SB, plex_sb, "d_cond_sb", 0, tnum)
	var cond_sb_caps := _mkfont(FONT_COND_SB, plex_sb, "d_cond_sb_caps", 1, tnum)
	var cond_b := _mkfont(FONT_COND_B, plex_b, "d_cond_b", 0, tnum)
	var cond_b_caps := _mkfont(FONT_COND_B, plex_b, "d_cond_b_caps", 1, tnum)
	var sans_reg := _mkfont(FONT_SANS_REG, null, "d_sans_reg")
	var sans_med := _mkfont(FONT_SANS_MED, null, "d_sans_med")
	var sans_sb := _mkfont(FONT_SANS_SB, null, "d_sans_sb")
	var sans_b := _mkfont(FONT_SANS_B, null, "d_sans_b")
	var sansc := _mkfont(FONT_SANSC_REG, plex_reg, "d_sansc_reg")
	var sansc_caps := _mkfont(FONT_SANSC_REG, plex_reg, "d_sansc_caps", 1)
	var serif_reg := _mkfont(FONT_SERIF_REG, null, "d_serif_reg")
	var serif_sb := _mkfont(FONT_SERIF_SB, null, "d_serif_sb")
	var serif_it := _mkfont(FONT_SERIF_IT, null, "d_serif_it")

	var th := Theme.new()
	# Mono's jobs move to Plex and its caps labels to Barlow.
	var errors := _copy_dark(master, th, {"serif_reg": serif_reg, "serif_sb": serif_sb,
		"serif_it": serif_it, "sans_reg": sans_reg, "sans_sb": sans_sb, "mono_reg": sans_reg,
		"mono_label": cond_sb_caps, "mono_sb": sans_sb})

	# ---- Where a cream token plays another role on the dark ground ----
	_recolor(th, &"NewsPanel", "panel", T.D_SURFACE_0)
	_recolor(th, &"PhaseDotActive", "panel", T.D_INK_2)
	_recolor(th, &"TabBadge", "panel", T.D_SURFACE_5)
	_recolor(th, &"SideRailPanel", "panel", null, T.D_LINE_1)
	# The phase dots are 6 px discs on the dark top bar.
	for dot in [&"PhaseDotActive", &"PhaseDotDim"]:
		var disc: StyleBoxFlat = th.get_stylebox("panel", dot).duplicate()
		disc.set_corner_radius_all(T.RADIUS_PILL)
		th.set_stylebox("panel", dot, disc)
	_recolor(th, &"PortraitCellSelected", "panel", null, T.D_INK_1)
	for state in ["normal", "hover", "pressed"]:
		_recolor(th, &"SpeedButtonActive", state, null, T.D_ACCENT)
		_recolor(th, &"TabButtonActive", state, T.D_SURFACE_4, T.D_SELECTED_MARK)
	for commit in [&"CommitButton", &"CommitButtonDark"]:
		for key in ["font_color", "font_hover_color", "font_pressed_color", "font_hover_pressed_color", "font_focus_color"]:
			th.set_color(key, commit, T.D_ON_ACCENT)
	# A window's shadow is its halo over the office.
	th.set_stylebox("panel", &"WindowPanel", _shadow(_flat(T.D_SURFACE_3, T.D_RADIUS_4,
		_pad_of(th.get_stylebox("panel", &"WindowPanel")), T.D_LINE_2), T.D_HALO, T.D_SHADOW_WINDOW))
	# The newspaper stays cream with its own faces and sizes; its meta line is Plex Sans Condensed.
	for row in [
		[&"MastheadSerif", serif_sb, T.D_PAPER_FS_MASTHEAD, T.PAPER_INK_MAST],
		[&"NewsHeadlineSerif", serif_sb, T.D_PAPER_FS_HEADLINE, T.PAPER_INK],
		[&"NewsStatSerif", serif_sb, T.D_PAPER_FS_FIGURE, T.PAPER_INK],
		[&"NewsDeckSerif", serif_it, T.D_FS_16, T.PAPER_INK_DECK],
		[&"NewsBodySerif", serif_reg, T.D_FS_15, T.PAPER_INK_BODY],
		[&"NewsCaptionSerif", serif_it, T.D_FS_12, T.D_PAPER_INK_META],
		[&"NewsMeta", sansc_caps, T.D_FS_12, T.D_PAPER_INK_META],
	]:
		_lbl(th, row[0], row[1], row[2], row[3])

	# ---- Base types ----
	th.default_font = sans_reg
	th.default_font_size = T.D_FS_15
	th.set_color("font_color", &"Label", T.D_INK_2)
	th.set_constant("line_spacing", &"Label", T.D_LEADING)
	_rich_fonts(th, &"RichTextLabel", sans_reg, sans_sb, serif_it, sans_reg, T.D_FS_15)
	th.set_color("default_color", &"RichTextLabel", T.D_INK_2)
	th.set_constant("line_separation", &"RichTextLabel", T.D_LEADING)
	th.set_stylebox("panel", &"Panel", _flat(T.D_SURFACE_3, T.D_RADIUS_1,
		_pad_of(th.get_stylebox("panel", &"Panel")), T.D_LINE_1))
	th.set_stylebox("panel", &"PanelContainer", _flat(T.D_SURFACE_3, T.D_RADIUS_1, Vector4.ZERO, T.D_LINE_1))
	var track := Vector4(0, T.D_H_PROGRESS * 0.5, 0, T.D_H_PROGRESS * 0.5)
	th.set_stylebox("background", &"ProgressBar", _flat(T.D_BAR_TRACK, T.D_RADIUS_1, track))
	th.set_stylebox("fill", &"ProgressBar", _flat(T.D_BAR_FILL, T.D_RADIUS_1, Vector4.ZERO))
	th.set_stylebox("separator", &"HSeparator", _pin(_rule(T.D_LINE_1, false)))
	th.set_stylebox("separator", &"VSeparator", _pin(_rule(T.D_LINE_1, true)))
	var bare := _pin(StyleBoxEmpty.new())
	th.set_stylebox("panel", &"ScrollContainer", bare)
	th.set_stylebox("focus", &"ScrollContainer", bare)

	# Focus is a 2 px ring 2 px off the control's edge.
	var thick := Vector4i(T.BORDER_FOCUS, T.BORDER_FOCUS, T.BORDER_FOCUS, T.BORDER_FOCUS)
	var ring := _flat(Color.TRANSPARENT, T.D_RADIUS_4, Vector4.ZERO, T.D_FOCUS, thick)
	ring.draw_center = false
	ring.set_expand_margin_all(T.SPACE_XS)

	# Buttons: base Button is the secondary button. {state: [fill, edge, ink]}.
	var clear := Color.TRANSPARENT
	var primary := {"normal": [T.D_ACCENT, clear, T.D_ON_ACCENT], "hover": [T.D_ACCENT_HOVER, clear, T.D_ON_ACCENT],
		"pressed": [T.D_ACCENT_PRESSED, clear, T.D_ON_ACCENT], "disabled": [T.D_SURFACE_5, clear, T.D_INK_OFF]}
	var secondary := {"normal": [clear, T.D_LINE_2, T.D_INK_2], "hover": [clear, T.D_LINE_HOVER, T.D_INK_1],
		"pressed": [T.D_SURFACE_2, T.D_LINE_HOVER, T.D_INK_1], "disabled": [clear, T.D_LINE_1, T.D_INK_OFF]}
	var ghost := {"normal": [clear, clear, T.D_INK_2], "hover": [clear, T.D_LINE_HOVER, T.D_INK_1],
		"pressed": [T.D_SURFACE_2, T.D_LINE_HOVER, T.D_INK_1], "disabled": [clear, clear, T.D_INK_OFF]}
	var regular := [cond_b, T.D_FS_18, _fit(cond_b, T.D_FS_18, T.D_H_BTN, T.SPACE_XL, T.SPACE_XL)]
	var small := [cond_sb, T.D_FS_16, _fit(cond_sb, T.D_FS_16, T.D_H_BTN_SM, T.SPACE_L, T.SPACE_L)]
	var large := [cond_b, T.D_FS_22, _fit(cond_b, T.D_FS_22, T.D_H_BTN_LG, T.SPACE_4XL, T.SPACE_4XL)]
	for row in [
		[&"Button", secondary, regular], [&"SecondaryButtonSmall", secondary, small],
		[&"PrimaryButtonDark", primary, regular], [&"PrimaryButtonDarkSmall", primary, small],
		[&"PrimaryButtonDarkLarge", primary, large], [&"GhostButton", ghost, regular],
		[&"GhostButtonSmall", ghost, small],
	]:
		_dbtn(th, row[0], row[1], row[2][0], row[2][1], row[2][2])
	th.set_stylebox("focus", &"Button", ring)
	th.set_type_variation(&"SecondaryButton", &"Button")
	# A glyph beside the label: 18 px on a button, 16 on a small one.
	th.set_constant("icon_max_width", &"Button", T.D_ICON_BUTTON)
	th.set_constant("h_separation", &"Button", T.SPACE_M)
	for small_button in [&"SecondaryButtonSmall", &"PrimaryButtonDarkSmall", &"GhostButtonSmall"]:
		th.set_constant("icon_max_width", small_button, T.D_ICON_BUTTON_SM)
		th.set_constant("h_separation", small_button, T.SPACE_S)

	var field := _fit(sans_reg, T.D_FS_15, T.D_H_INPUT, T.SPACE_L, T.SPACE_L)
	_states(th, &"LineEdit", {
		"normal": _flat(T.D_SURFACE_2, T.D_RADIUS_2, field, T.D_LINE_2),
		"focus": _flat(clear, T.D_RADIUS_2, field, T.D_INK_3),
		"read_only": _flat(clear, T.D_RADIUS_2, field, T.D_LINE_1),
	})
	th.set_font_size("font_size", &"LineEdit", T.D_FS_15)
	for row in [["font_color", T.D_INK_1], ["caret_color", T.D_INK_1], ["font_placeholder_color", T.D_INK_4],
			["font_uneditable_color", T.D_INK_3]]:
		th.set_color(row[0], &"LineEdit", row[1])

	_dbtn(th, &"OptionButton", {
		"normal": [T.D_SURFACE_2, T.D_LINE_2, T.D_INK_2], "hover": [T.D_SURFACE_2, T.D_LINE_HOVER, T.D_INK_1],
		"pressed": [T.D_SURFACE_2, T.D_INK_3, T.D_INK_1], "disabled": [clear, T.D_LINE_1, T.D_INK_OFF],
	}, sans_reg, T.D_FS_15, _fit(sans_reg, T.D_FS_15, T.D_H_INPUT, T.SPACE_L, T.SPACE_M))
	th.set_stylebox("focus", &"OptionButton", ring)
	th.set_icon("arrow", &"OptionButton", load(DARK_ICONS + "select_arrow.svg"))
	th.set_constant("modulate_arrow", &"OptionButton", 1)
	th.set_constant("arrow_margin", &"OptionButton", T.SPACE_M)
	th.set_constant("h_separation", &"OptionButton", T.SPACE_M)

	# A check box or switch is its icon and a Plex label; Button's boxes must not reach it.
	for toggle in [&"CheckBox", &"CheckButton"]:
		for state in ["normal", "hover", "pressed", "disabled", "hover_pressed"]:
			th.set_stylebox(state, toggle, bare)
		th.set_stylebox("focus", toggle, ring)
		th.set_font("font", toggle, sans_reg)
		th.set_font_size("font_size", toggle, T.D_FS_15)
		for key in ["font_color", "font_hover_color", "font_pressed_color", "font_hover_pressed_color", "font_focus_color"]:
			th.set_color(key, toggle, T.D_INK_2)
		th.set_color("font_disabled_color", toggle, T.D_INK_OFF)
		th.set_constant("h_separation", toggle, T.SPACE_M)
	for key in ["checked", "checked_disabled"]:
		th.set_icon(key, &"CheckButton", load(DARK_ICONS + "switch_on.svg"))
	for key in ["unchecked", "unchecked_disabled"]:
		th.set_icon(key, &"CheckButton", load(DARK_ICONS + "switch_off.svg"))
	# The switch keeps its drawn size: Button's glyph cap would scale it down to a glyph.
	th.set_constant("icon_max_width", &"CheckButton", 0)

	for arrow in ["up", "down"]:
		th.set_stylebox(arrow + "_background", &"SpinBox", _flat(clear, T.D_RADIUS_2, Vector4.ZERO))
		th.set_stylebox(arrow + "_background_hovered", &"SpinBox", _flat(clear, T.D_RADIUS_2, Vector4.ZERO, T.D_LINE_HOVER))
		th.set_stylebox(arrow + "_background_pressed", &"SpinBox", _flat(T.D_SURFACE_2, T.D_RADIUS_2, Vector4.ZERO, T.D_LINE_HOVER))
		th.set_stylebox(arrow + "_background_disabled", &"SpinBox", _flat(clear, T.D_RADIUS_2, Vector4.ZERO))
		th.set_color(arrow + "_icon_modulate", &"SpinBox", T.D_INK_2)
		th.set_color(arrow + "_hover_icon_modulate", &"SpinBox", T.D_INK_1)
		th.set_color(arrow + "_pressed_icon_modulate", &"SpinBox", T.D_INK_1)
		th.set_color(arrow + "_disabled_icon_modulate", &"SpinBox", T.D_INK_OFF)
	th.set_stylebox("field_and_buttons_separator", &"SpinBox", _pin(_rule(T.D_LINE_1, true)))
	th.set_stylebox("up_down_buttons_separator", &"SpinBox", _pin(_rule(T.D_LINE_1, false)))

	# Scrollbars: an 8 px lane, the thumb 1 px inside it on both long sides.
	for bar in [&"VScrollBar", &"HScrollBar"]:
		var vertical: bool = bar == &"VScrollBar"
		var lane := _flat(clear, T.RADIUS_PILL, Vector4(T.SPACE_XS, 0, T.SPACE_XS, 0) if vertical else Vector4(0, T.SPACE_XS, 0, T.SPACE_XS))
		th.set_stylebox("scroll", bar, lane)
		th.set_stylebox("scroll_focus", bar, lane)
		for row in [["grabber", T.D_LINE_3], ["grabber_highlight", T.D_INK_4], ["grabber_pressed", T.D_INK_4]]:
			var thumb := _flat(row[1], T.RADIUS_PILL, Vector4(T.SPACE_XS, T.SPACE_XS, T.SPACE_XS, T.SPACE_XS))
			for side in ([SIDE_LEFT, SIDE_RIGHT] if vertical else [SIDE_TOP, SIDE_BOTTOM]):
				thumb.set_expand_margin(side, -T.BORDER_HAIRLINE)
			th.set_stylebox(row[0], bar, thumb)

	var groove := Vector4(0, T.SPACE_XXS, 0, T.SPACE_XXS)
	_states(th, &"HSlider", {
		"slider": _flat(T.D_BAR_TRACK, T.D_RADIUS_1, groove),
		"grabber_area": _flat(T.D_INK_3, T.D_RADIUS_1, groove),
		"grabber_area_highlight": _flat(T.D_INK_2, T.D_RADIUS_1, groove),
	})
	for key in ["grabber", "grabber_highlight", "grabber_disabled"]:
		th.set_icon(key, &"HSlider", load(DARK_ICONS + "slider_grabber.svg"))
	th.set_stylebox("focus", &"HSlider", ring)
	# The grabber sits centred on its value, past the track's ends at 0 and 100 %.
	th.set_constant("center_grabber", &"HSlider", 1)

	# A menu row is 32 tall; hover is a border, never a fill.
	th.set_stylebox("panel", &"PopupMenu", _shadow(_flat(T.D_SURFACE_4, T.D_RADIUS_3,
		Vector4(T.SPACE_XS, T.SPACE_XS, T.SPACE_XS, T.SPACE_XS), T.D_LINE_2), T.D_SHADOW_FLOAT, T.D_SHADOW_FLOATING))
	th.set_stylebox("hover", &"PopupMenu", _flat(clear, T.D_RADIUS_2, Vector4.ZERO, T.D_LINE_HOVER))
	var menu_rule := _pin(_rule(T.D_LINE_1, false))
	for key in ["separator", "labeled_separator_left", "labeled_separator_right"]:
		th.set_stylebox(key, &"PopupMenu", menu_rule)
	th.set_font("font", &"PopupMenu", sans_reg)
	th.set_font_size("font_size", &"PopupMenu", T.D_FS_15)
	th.set_font("font_separator", &"PopupMenu", cond_sb_caps)
	th.set_font_size("font_separator_size", &"PopupMenu", T.D_FS_12)
	for row in [["font_color", T.D_INK_2], ["font_hover_color", T.D_INK_1], ["font_disabled_color", T.D_INK_OFF],
			["font_accelerator_color", T.D_INK_4], ["font_separator_color", T.D_INK_3]]:
		th.set_color(row[0], &"PopupMenu", row[1])
	th.set_constant("v_separation", &"PopupMenu", int(T.D_H_MENU_ITEM - sans_reg.get_height(T.D_FS_15)))
	for key in ["h_separation", "item_start_padding", "item_end_padding"]:
		th.set_constant(key, &"PopupMenu", T.SPACE_M)
	# A dropdown's list checks the value in force; the other items keep the check's room.
	for key in ["radio_checked", "radio_checked_disabled"]:
		th.set_icon(key, &"PopupMenu", load(DARK_ICONS + "menu_check.svg"))
	for key in ["radio_unchecked", "radio_unchecked_disabled"]:
		th.set_icon(key, &"PopupMenu", load(DARK_ICONS + "menu_blank.svg"))

	th.set_stylebox("panel", &"TooltipPanel", _shadow(_flat(T.D_SURFACE_0, T.D_RADIUS_2,
		_fit(sans_reg, T.D_FS_13, T.D_H_TOOLTIP, T.SPACE_L, T.SPACE_L), T.D_LINE_2), T.D_SHADOW_TOOLTIP, T.D_SHADOW_TIP))
	th.set_font("font", &"TooltipLabel", sans_reg)
	th.set_font_size("font_size", &"TooltipLabel", T.D_FS_13)
	th.set_color("font_color", &"TooltipLabel", T.D_INK_2)

	# ---- New variations: type roles in component inks ----
	for row in [
		[&"TitleH1", cond_b_caps, T.D_FS_40, T.D_INK_1],
		[&"DisplayName", cond_b, T.D_FS_40, T.D_INK_1],   # a proper noun at title size: never caps
		[&"TileValue", cond_b, T.D_FS_36, T.D_INK_1],
		[&"HeroFigure", sans_sb, T.D_FS_40, T.D_INK_1],
		[&"TitleH2", cond_b, T.D_FS_30, T.D_INK_1],
		[&"DialogTitle", cond_b, T.D_FS_22, T.D_INK_1],
		[&"NameTitle", cond_b, T.D_FS_20, T.D_INK_1],
		[&"SubheadLabel", cond_b, T.D_FS_20, T.D_INK_2],
		[&"OptionLabel", cond_b, T.D_FS_20, T.D_INK_1],
		[&"OptionLabelLocked", cond_b, T.D_FS_20, T.D_INK_OFF],
		[&"FloatTitle", cond_b, T.D_FS_18, T.D_INK_1],
		[&"GateLabel", cond_b_caps, T.D_FS_18, T.D_ACCENT],
		[&"NavLabel", cond_sb_caps, T.D_FS_16, T.D_INK_3],
		[&"NavLabelActive", cond_sb_caps, T.D_FS_16, T.D_INK_1],
		[&"NavLabelLocked", cond_sb_caps, T.D_FS_16, T.D_INK_OFF],
		[&"GroupLabel", cond_sb_caps, T.D_FS_15, T.D_INK_2],
		[&"KeyLabel", cond_sb_caps, T.D_FS_14, T.D_INK_3],
		[&"KeyLabelStrong", cond_sb_caps, T.D_FS_14, T.D_INK_1],
		[&"KeySmall", cond_sb_caps, T.D_FS_12, T.D_INK_3],
		[&"FloatKey", cond_sb_caps, T.D_FS_14, T.D_INK_2],
		[&"NavReason", cond_sb_caps, T.D_FS_12, T.D_INK_4],
		[&"PartValue", sans_b, T.D_FS_36, T.D_INK_2],
		[&"HeroValue", sans_sb, T.D_FS_30, T.D_INK_1],
		[&"HeroArrow", sans_reg, T.D_FS_30, T.D_INK_3],
		[&"KpiValue", sans_sb, T.D_FS_26, T.D_INK_2],
		[&"PartValueArmed", sans_b, T.D_FS_26, T.D_INK_2],
		[&"ClockLabel", sans_sb, T.D_FS_22, T.D_INK_2],
		[&"ValueText", sans_med, T.D_FS_18, T.D_INK_2],
		[&"ValueTextStrong", sans_sb, T.D_FS_18, T.D_INK_1],
		[&"BodyLabel", sans_reg, T.D_FS_16, T.D_INK_2],
		[&"SenderName", sans_sb, T.D_FS_16, T.D_INK_2],
		[&"RiskName", sans_sb, T.D_FS_16, T.D_INK_1],
		[&"SubjectLabel", sans_med, T.D_FS_16, T.D_INK_2],
		[&"SubjectStrong", sans_sb, T.D_FS_16, T.D_INK_1],
		[&"SkillValue", sans_med, T.D_FS_16, T.D_SKILL_3],   # its host paints D_skill(value)
		[&"SkillMain", sans_b, T.D_FS_16, T.D_SKILL_3],
		[&"SkillSecondary", sans_sb, T.D_FS_16, T.D_SKILL_3],
		[&"MoraleValue", sans_b, T.D_FS_16, T.D_INK_2],   # its host paints the morale band
		[&"DataText", sans_reg, T.D_FS_15, T.D_INK_2],
		[&"DataStrong", sans_sb, T.D_FS_15, T.D_INK_1],
		[&"DataMedium", sans_med, T.D_FS_15, T.D_INK_2],
		[&"NoticeText", sans_med, T.D_FS_15, T.D_INK_2],
		[&"NoteMuted", sans_reg, T.D_FS_15, T.D_INK_3],
		[&"CondData", sansc, T.D_FS_15, T.D_INK_2],
		[&"TipTitle", sans_sb, T.D_FS_14, T.D_INK_1],
		[&"KeyText", sans_med, T.D_FS_14, T.D_INK_2],
		[&"KeyTextMuted", sans_med, T.D_FS_14, T.D_INK_3],
		[&"MetaMuted", sans_reg, T.D_FS_14, T.D_INK_3],
		[&"Caption", sans_reg, T.D_FS_13, T.D_INK_3],
		[&"CaptionStrong", sans_b, T.D_FS_13, T.D_INK_2],
		[&"CaptionPrimary", sans_reg, T.D_FS_13, T.D_INK_2],
		[&"CaptionFaint", sans_reg, T.D_FS_13, T.D_INK_4],
		[&"CondCaption", sansc, T.D_FS_13, T.D_INK_3],
		[&"SegCount", sans_med, T.D_FS_13, T.D_INK_4],
		[&"SegCountActive", sans_med, T.D_FS_13, T.D_INK_3],
		[&"SmallMuted", sans_reg, T.D_FS_12, T.D_INK_3],
		[&"FrankQuote", serif_reg, T.D_FS_20, T.D_INK_2],
	]:
		_lbl(th, row[0], row[1], row[2], row[3])
	th.set_constant("line_spacing", &"FrankQuote", T.D_LEADING_PARA)

	# Boxed labels. Topic hues are painted at runtime from the D_ helpers, so the colour-blind palette
	# reaches them.
	var tag := _fit(cond_b_caps, T.D_FS_13, T.D_H_TAG, T.SPACE_M, T.SPACE_M)
	var pill := _fit(cond_b_caps, T.D_FS_13, T.D_H_PILL, T.SPACE_S, T.SPACE_S)
	var badge := _fit(sans_b, T.D_FS_13, T.D_H_BADGE, T.SPACE_S, T.SPACE_S)
	var badge_icon := _fit(sans_b, T.D_FS_12, T.D_H_BADGE_ICON, T.SPACE_XS, T.SPACE_XS)
	for row in [
		[&"Tag", cond_b_caps, T.D_FS_13, T.D_INK_2, _flat(clear, T.D_RADIUS_2, tag, T.D_LINE_3)],
		[&"TagNeutral", cond_b_caps, T.D_FS_13, T.D_INK_3, _flat(T.D_SURFACE_5, T.D_RADIUS_2, tag)],
		[&"TagOutline", cond_b_caps, T.D_FS_13, T.D_INK_3, _flat(clear, T.D_RADIUS_2, tag, T.D_LINE_2)],
		[&"TopicPill", cond_b_caps, T.D_FS_13, T.D_TOPIC_AGENDA,
			_flat(Color(T.D_TOPIC_AGENDA, T.D_PILL_FILL_ALPHA), T.D_RADIUS_2, pill, T.D_TOPIC_AGENDA)],
		[&"BadgeCount", sans_b, T.D_FS_13, T.D_INK_2, _flat(T.D_SURFACE_5, T.RADIUS_PILL, badge, T.D_LINE_2)],
		[&"BadgeDanger", sans_b, T.D_FS_13, T.D_ON_NEG, _flat(T.D_NEG, T.RADIUS_PILL, badge)],
		[&"BadgeCountIcon", sans_b, T.D_FS_12, T.D_INK_2, _flat(T.D_SURFACE_5, T.RADIUS_PILL, badge_icon, T.D_LINE_2)],
		[&"BadgeDangerIcon", sans_b, T.D_FS_12, T.D_ON_NEG, _flat(T.D_NEG, T.RADIUS_PILL, badge_icon)],
		[&"DocStamp", cond_b_caps, T.D_FS_14, T.D_STAMP, _flat(clear, T.D_RADIUS_1,
			_fit(cond_b_caps, T.D_FS_14, T.D_H_STAMP, T.SPACE_M, T.SPACE_M), T.D_STAMP, thick)],
		[&"FxPart", sans_med, T.D_FS_14, T.D_INK_2, _flat(T.D_SURFACE_2, T.D_RADIUS_2,
			_fit(sans_med, T.D_FS_14, T.D_H_FX, T.SPACE_M, T.SPACE_M), T.D_LINE_1)],
	]:
		_lbl(th, row[0], row[1], row[2], row[3])
		th.set_stylebox("normal", row[0], row[4])
	# The risk and attention tags, the risk strip and the danger button bake both palettes from the D_
	# helpers: the colour-blind one is the "Cb" twin, which the host picks through UiTokens.D_variation.
	var strip_pad := Vector4(T.SPACE_XL, 0, T.SPACE_L, 0)
	var meet_pad := Vector4(T.SPACE_L, T.SPACE_L, T.SPACE_XL, T.SPACE_L)
	var chip_pad := _fit(sans_med, T.D_FS_13, T.D_H_TAG, T.SPACE_S, T.SPACE_S)
	var flag_pad := Vector4(T.SPACE_M, chip_pad.y, T.SPACE_M, chip_pad.w)
	for cb in [false, true]:
		T.set_colorblind(cb)
		var twin := "Cb" if cb else ""
		for row in [["TagRisk", &"negative"], ["TagWarn", &"accent"], ["TagPos", &"positive"]]:
			var p: Dictionary = T.D_badge_palette(row[1])
			_lbl(th, row[0] + twin, cond_b_caps, T.D_FS_13, p.fg)
			th.set_stylebox("normal", row[0] + twin, _flat(p.bg, T.D_RADIUS_2, tag, p.line))
		# The danger button, in the palette in use.
		_dbtn(th, "DangerButton" + twin, {"normal": [clear, T.D_badge_palette(&"negative").line, T.D_neg_ink()],
			"hover": [clear, T.D_neg(), T.D_neg()], "pressed": [T.D_neg_bg(), T.D_neg(), T.D_neg()],
			"disabled": [clear, T.D_LINE_1, T.D_INK_OFF]}, regular[0], regular[1], regular[2])
		_lbl(th, "RiskKey" + twin, cond_sb_caps, T.D_FS_14, T.D_neg_ink())
		_lbl(th, "RiskValue" + twin, sans_b, T.D_FS_18, T.D_neg())
		_panel(th, "RiskStrip" + twin, "PanelContainer", _flat(T.D_neg_bg(), T.D_RADIUS_3, strip_pad, T.D_neg_rule()))
		var risk: Dictionary = T.D_badge_palette(&"negative")
		_panel(th, "FxChipDanger" + twin, "PanelContainer", _flat(risk.bg, T.D_RADIUS_2,
			_fit(sans_med, T.D_FS_14, T.D_H_FX, T.SPACE_M, T.SPACE_M), risk.line))
		_panel(th, "RiskStripHover" + twin, "PanelContainer", _flat(T.D_neg_bg(), T.D_RADIUS_3, strip_pad, T.D_neg()))
		# A deadline that ends this sprint or the next.
		var warn: Dictionary = T.D_badge_palette(&"accent")
		_panel(th, "FlagChipWarn" + twin, "PanelContainer", _flat(warn.bg, T.D_RADIUS_2, flag_pad, warn.line))
		# A tag with a glyph before its word: the box holds both, the word is bare.
		_panel(th, "TagWarnBox" + twin, "PanelContainer", _flat(warn.bg, T.D_RADIUS_2, tag, warn.line))
		_lbl(th, "TagWarnInk" + twin, cond_b_caps, T.D_FS_13, warn.fg)
		var gain: Dictionary = T.D_badge_palette(&"positive")
		_panel(th, "TagPosBox" + twin, "PanelContainer", _flat(gain.bg, T.D_RADIUS_2, tag, gain.line))
		_lbl(th, "TagPosInk" + twin, cond_b_caps, T.D_FS_13, gain.fg)
		# A meeting option over the insult line, on the danger ground.
		_panel(th, "MeetOptionAlert" + twin, "PanelContainer", _flat(risk.bg, T.D_RADIUS_3, meet_pad, risk.line))
	T.set_colorblind(false)

	# Boxes. Rows and bands take their height from the host; a document has its corner cut.
	var bottom := Vector4i(0, 0, 0, T.BORDER_HAIRLINE)
	# An inbox row keeps its left edge for its marker and dot.
	var row_pad := Vector4(0, 0, T.SPACE_XL, 0)
	var band_pad := Vector4(T.SPACE_3XL, 0, T.SPACE_XL, 0)
	var option_pad := Vector4(T.SPACE_XXL, 0, T.SPACE_XL, 0)
	var doc_pad := Vector4(T.SPACE_3XL, 0, T.SPACE_XXL, 0)
	# Content inside a box's 1 px border: a card the player picks from and a document read in full lay
	# out their own inset, since their selected marker sits on the box's own left edge.
	var hairline: Vector4 = Vector4.ONE * T.BORDER_HAIRLINE
	# A panel's foot and a dialog's head band follow the frame's rounded corners from inside its border.
	var foot := _flat(T.D_SURFACE_2, 0, Vector4(T.SPACE_3XL, T.SPACE_XL, T.SPACE_3XL, T.SPACE_XL), T.D_LINE_1,
		Vector4i(0, T.BORDER_HAIRLINE, 0, 0))
	foot.corner_radius_bottom_left = T.D_RADIUS_4 - T.BORDER_HAIRLINE
	foot.corner_radius_bottom_right = T.D_RADIUS_4 - T.BORDER_HAIRLINE
	var dialog_head := _flat(T.D_SURFACE_4, 0, band_pad, T.D_LINE_1, bottom)
	dialog_head.corner_radius_top_left = T.D_RADIUS_4 - T.BORDER_HAIRLINE
	dialog_head.corner_radius_top_right = T.D_RADIUS_4 - T.BORDER_HAIRLINE
	# A document's head band follows its corners the same way, the cut one included.
	var doc_head := _doc(_flat(T.D_SURFACE_4, 0, Vector4(T.SPACE_XXL, T.SPACE_XL, T.SPACE_L, T.SPACE_XL), T.D_LINE_1,
		bottom), T.D_CUT - T.BORDER_HAIRLINE)
	doc_head.corner_radius_top_left = T.D_RADIUS_1 - T.BORDER_HAIRLINE
	doc_head.corner_radius_bottom_left = 0
	doc_head.corner_radius_bottom_right = 0
	for row in [
		[&"WinHead", _flat(T.D_SURFACE_4, 0, band_pad, T.D_LINE_1, bottom)],
		[&"WinCtl", _flat(clear, 0, Vector4(T.SPACE_3XL, 0, T.SPACE_3XL, 0), T.D_LINE_1, bottom)],
		[&"WinReadOnly", _flat(T.D_SURFACE_2, 0, band_pad, T.D_LINE_1, bottom)],
		[&"KpiCell", _flat(clear, 0, Vector4(T.SPACE_3XL, 0, T.SPACE_3XL, 0), T.D_LINE_1, Vector4i(T.BORDER_HAIRLINE, 0, 0, 0))],
		[&"MarketTile", _flat(T.D_SURFACE_4, T.D_RADIUS_3, Vector4(T.SPACE_XXL, T.SPACE_L, T.SPACE_XXL, T.SPACE_L), T.D_LINE_1)],
		[&"MarketCard", _flat(T.D_SURFACE_2, 0, Vector4(T.SPACE_4XL, T.SPACE_3XL, T.SPACE_4XL, T.SPACE_3XL), T.D_LINE_1,
			Vector4i(T.BORDER_HAIRLINE, 0, 0, 0))],
		[&"TimeBlock", _flat(T.D_SURFACE_4, 0, Vector4.ZERO, T.D_LINE_1, Vector4i(T.BORDER_HAIRLINE, 0, 0, 0))],
		[&"TableHead", _flat(clear, 0, Vector4(0, 0, 0, T.SPACE_M), T.D_LINE_1, bottom)],
		[&"TableRow", _flat(clear, 0, Vector4.ZERO, T.D_ROW_RULE, bottom)],
		[&"TableRowHover", _flat(clear, T.D_RADIUS_1, Vector4.ZERO, T.D_LINE_HOVER)],
		[&"TableRowSelected", _flat(T.D_SURFACE_4, 0, Vector4.ZERO, T.D_ROW_RULE, bottom)],
		[&"TableRowSelectedHover", _flat(T.D_SURFACE_4, T.D_RADIUS_1, Vector4.ZERO, T.D_LINE_HOVER)],
		[&"TraitBox", _flat(T.D_SURFACE_5, T.D_RADIUS_2, Vector4.ONE * (T.D_TRAIT_BOX - T.D_ICON_ROW) / 2.0,
			T.D_LINE_2)],
		[&"MenuPanel", th.get_stylebox("panel", &"PopupMenu")],
		[&"InboxList", _flat(T.D_SURFACE_2, 0, Vector4(0, 0, T.SPACE_L, 0), T.D_LINE_1, Vector4i(0, 0, T.BORDER_HAIRLINE, 0))],
		[&"InboxRow", _flat(clear, 0, row_pad, T.D_LINE_1, bottom)],
		[&"InboxRowHover", _flat(clear, T.D_RADIUS_1, row_pad, T.D_LINE_HOVER)],
		[&"InboxRowSelected", _doc(_flat(T.D_SURFACE_4, 0, row_pad, T.D_LINE_1, bottom), T.D_CUT_SM)],
		[&"InboxBand", _flat(T.D_SURFACE_1, 0, band_pad, T.D_LINE_1, bottom)],
		[&"PortraitWell", _flat(T.D_PORTRAIT_EDGE, T.D_RADIUS_3, Vector4.ZERO, T.D_LINE_2)],
		[&"StakeBox", _doc(_flat(T.D_SURFACE_4, 0, doc_pad, T.D_LINE_2), T.D_CUT)],
		[&"PaperBar", _doc(_flat(T.D_SURFACE_4, 0, doc_pad, T.D_LINE_2), T.D_CUT)],
		[&"OptionBar", _flat(T.D_SURFACE_3, T.D_RADIUS_3, option_pad, T.D_LINE_2)],
		[&"OptionBarHover", _flat(T.D_SURFACE_3, T.D_RADIUS_3, option_pad, T.D_LINE_HOVER)],
		[&"OptionBarLocked", _flat(clear, T.D_RADIUS_3, option_pad, T.D_LINE_1)],
		[&"OptionArmed", _doc(_flat(T.D_SURFACE_4, 0, Vector4(T.SPACE_3XL, T.SPACE_XL, T.SPACE_XXL, T.SPACE_XXL), T.D_LINE_HOVER), T.D_CUT)],
		[&"Toast", _shadow(_doc(_flat(T.D_SURFACE_4, 0, Vector4(T.SPACE_M, 0, T.SPACE_XXL, 0), T.D_LINE_2), T.D_CUT_SM),
			T.D_SHADOW_FLOAT, T.D_SHADOW_FLOATING)],
		[&"FloatPanel", _shadow(_flat(T.D_SURFACE_3, T.D_RADIUS_3, Vector4.ZERO, T.D_LINE_1), T.D_SHADOW_FLOAT, T.D_SHADOW_FLOATING)],
		[&"FloatHead", _flat(clear, 0, Vector4(T.SPACE_XL, T.SPACE_L, T.SPACE_XL, T.SPACE_L), T.D_LINE_1, bottom)],
		[&"FloatRow", _flat(clear, 0, Vector4(T.SPACE_XL, T.SPACE_M, T.SPACE_XL, T.SPACE_M), T.D_LINE_1, bottom)],
		[&"FloatFoot", _flat(clear, 0, Vector4(T.SPACE_XL, T.SPACE_M, T.SPACE_XL, T.SPACE_M), T.D_LINE_1,
			Vector4i(0, T.BORDER_HAIRLINE, 0, 0))],
		[&"NoticeDoc", _shadow(_doc(_flat(T.D_SURFACE_3, 0, Vector4(T.SPACE_XL, 0, T.SPACE_XL, 0), T.D_LINE_1), T.D_CUT_SM),
			T.D_SHADOW_FLOAT, T.D_SHADOW_FLOATING)],
		# A document inside a mail: an answered decision, a report's highlight, a record.
		[&"NoteBox", _doc(_flat(clear, 0, Vector4(T.SPACE_3XL, T.SPACE_XL, T.SPACE_3XL, T.SPACE_XL), T.D_LINE_2), T.D_CUT)],
		# A sender with no face: a company's initials or a desk's glyph.
		[&"MonoBox", _flat(T.D_SURFACE_2, T.D_RADIUS_2, Vector4.ZERO, T.D_LINE_2)],
		# An effect part in an option's row: its glyph and its words.
		[&"FxChip", _flat(T.D_SURFACE_2, T.D_RADIUS_2, _fit(sans_med, T.D_FS_14, T.D_H_FX, T.SPACE_M, T.SPACE_M), T.D_LINE_1)],
		# A table head the list has scrolled under.
		[&"TableHeadStuck", _flat(T.D_SURFACE_2, 0, Vector4(0, 0, 0, T.SPACE_M), T.D_LINE_2, bottom)],
		# A neutral strip over a table, the risk strip's shape (the agency's search and files).
		[&"NoticeStrip", _flat(T.D_SURFACE_4, T.D_RADIUS_3, Vector4(T.SPACE_L, 0, T.SPACE_L, 0), T.D_LINE_2)],
		# A detail window is a document; a dialog or a PanelLayer panel is a window with no scrim.
		[&"DocWindow", _shadow(_doc(_flat(T.D_SURFACE_3, 0, hairline, T.D_LINE_2), T.D_CUT), T.D_HALO, T.D_SHADOW_WINDOW)],
		[&"DocHead", doc_head],
		[&"DialogPanel", _shadow(_flat(T.D_SURFACE_3, T.D_RADIUS_4, hairline, T.D_LINE_2), T.D_HALO, T.D_SHADOW_WINDOW)],
		[&"DialogHead", dialog_head],
		[&"PanelFoot", foot],
		[&"PickCard", _flat(T.D_SURFACE_3, T.D_RADIUS_3, hairline, T.D_LINE_2)],
		[&"PickCardHover", _flat(T.D_SURFACE_3, T.D_RADIUS_3, hairline, T.D_LINE_HOVER)],
		[&"PickCardSelected", _flat(T.D_SURFACE_4, T.D_RADIUS_3, hairline, T.D_LINE_2)],
		[&"FileDoc", _doc(_flat(T.D_SURFACE_3, 0, hairline, T.D_LINE_2), T.D_CUT)],
		[&"FileDocHover", _doc(_flat(T.D_SURFACE_3, 0, hairline, T.D_LINE_HOVER), T.D_CUT)],
		[&"FileDocSelected", _doc(_flat(T.D_SURFACE_4, 0, hairline, T.D_LINE_2), T.D_CUT)],
		# A fact under a table: its glyph and its sentence.
		[&"FactBox", _flat(T.D_SURFACE_2, T.D_RADIUS_2, Vector4(T.SPACE_L, T.SPACE_M, T.SPACE_L, T.SPACE_M), T.D_LINE_1)],
		[&"StepperBox", _flat(T.D_SURFACE_2, T.D_RADIUS_2, Vector4.ZERO, T.D_LINE_2)],
	]:
		_panel(th, row[0], "PanelContainer", row[1])
	# The time state's frame round the top bar's gate slot and clock while a decision waits.
	var gate_frame := _flat(clear, 0, Vector4.ZERO, T.D_ACCENT, thick)
	gate_frame.draw_center = false
	_panel(th, &"GateFrame", "Panel", gate_frame)
	_panel(th, &"GateDot", "Panel", _flat(T.D_ACCENT, T.RADIUS_PILL, Vector4.ZERO))
	_panel(th, &"IconWell", "Panel", _flat(T.D_SURFACE_2, T.D_RADIUS_2, Vector4.ZERO))
	_panel(th, &"RoleBand", "Panel", _flat(T.D_ROLE_BAND, 0, Vector4.ZERO))
	_panel(th, &"BarTrack", "Panel", _flat(T.D_BAR_TRACK, T.RADIUS_PILL, Vector4.ZERO))
	# A bar's fill is white so its host can tint it with the value's own colour.
	_panel(th, &"BarTint", "Panel", _flat(Color.WHITE, T.RADIUS_PILL, Vector4.ZERO))
	_panel(th, &"BrandMark", "Panel", _flat(T.D_BRAND_MARK, T.D_RADIUS_1, Vector4.ZERO))
	# The disc on a picked card, behind its check glyph.
	_panel(th, &"CheckDisc", "Panel", _flat(T.D_INK_1, T.RADIUS_PILL, Vector4.ZERO))
	var mark := _flat(T.D_SELECTED_MARK, T.D_RADIUS_1, Vector4.ZERO)
	mark.corner_radius_top_left = 0
	mark.corner_radius_bottom_left = 0
	_panel(th, &"RailMark", "Panel", mark)

	# Clickable rows and keys.
	_dbtn(th, &"ChipButton", secondary, sans_reg, T.D_FS_15, _fit(sans_reg, T.D_FS_15, T.D_H_BTN, T.SPACE_L, T.SPACE_L))
	_dbtn(th, &"ChipSmall", secondary, sans_reg, T.D_FS_13, _fit(sans_reg, T.D_FS_13, T.D_H_FX, T.SPACE_M, T.SPACE_M))
	th.set_constant("icon_max_width", &"ChipSmall", T.D_ICON_MARK)
	th.set_constant("h_separation", &"ChipSmall", T.SPACE_S)
	# A filter chip over a list: the one in force is ink-edged on the raised ground, never amber.
	var chip_pad_f := _fit(sans_reg, T.D_FS_15, T.D_H_MARKET_CHIP, T.SPACE_L, T.SPACE_L)
	var chip_on := [T.D_SURFACE_4, T.D_INK_1, T.D_INK_1]
	_dbtn(th, &"ChipFilter", {"normal": [clear, T.D_LINE_2, T.D_INK_3], "hover": [clear, T.D_LINE_HOVER, T.D_INK_1],
		"pressed": chip_on, "disabled": [clear, T.D_LINE_1, T.D_INK_OFF]}, sans_reg, T.D_FS_15, chip_pad_f)
	_dbtn(th, &"ChipFilterOn", {"normal": chip_on, "hover": chip_on, "pressed": chip_on,
		"disabled": [T.D_SURFACE_4, T.D_LINE_1, T.D_INK_OFF]}, sans_reg, T.D_FS_15, chip_pad_f)
	# A chip's glyph stays quiet while its label lifts on hover.
	for state in ["normal", "hover", "pressed", "hover_pressed", "focus"]:
		for chip in [&"ChipButton", &"ChipSmall"]:
			th.set_color("icon_%s_color" % state, chip, T.D_INK_3)
	# A menu row is a ghost key the size its host gives it; its parts are the host's labels.
	_dbtn(th, &"MenuItem", ghost, sans_reg, T.D_FS_15, Vector4(T.SPACE_M, 0, T.SPACE_M, 0))
	# A stepper's minus and plus keys, square, glyph only.
	_dbtn(th, &"StepKey", ghost, sans_reg, T.D_FS_15, Vector4.ZERO)
	th.set_constant("icon_max_width", &"StepKey", T.D_ICON_PART)
	# A job box in the assignment matrix: open, held as a second job, held as the main job; the check
	# glyph takes the box's ink.
	_dbtn(th, &"JobBox", {"normal": [T.D_SURFACE_2, T.D_LINE_3, T.D_INK_2], "hover": [T.D_SURFACE_2, T.D_LINE_HOVER, T.D_INK_2],
		"pressed": [T.D_SURFACE_5, T.D_LINE_HOVER, T.D_INK_2], "disabled": [clear, T.D_LINE_1, T.D_INK_OFF]}, sans_reg, T.D_FS_13, Vector4.ZERO)
	_dbtn(th, &"JobBoxSecondary", {"normal": [T.D_SURFACE_5, T.D_INK_3, T.D_INK_2],
		"hover": [T.D_SURFACE_5, T.D_LINE_HOVER, T.D_INK_1], "pressed": [T.D_SURFACE_2, T.D_LINE_HOVER, T.D_INK_1],
		"disabled": [clear, T.D_LINE_1, T.D_INK_OFF]}, sans_reg, T.D_FS_13, Vector4.ZERO)
	_dbtn(th, &"JobBoxPrimary", {"normal": [T.D_INK_2, T.D_INK_2, T.D_SURFACE_0],
		"hover": [T.D_INK_2, T.D_LINE_HOVER, T.D_SURFACE_0], "pressed": [T.D_INK_3, T.D_LINE_HOVER, T.D_SURFACE_0],
		"disabled": [clear, T.D_LINE_1, T.D_INK_OFF]}, sans_reg, T.D_FS_13, Vector4.ZERO)
	for job in [&"JobBox", &"JobBoxSecondary", &"JobBoxPrimary"]:
		th.set_constant("icon_max_width", job, T.D_ICON_ROW)
	var under := Vector4i(0, 0, 0, T.BORDER_FOCUS)
	var under_pad := Vector4(0, 0, 0, T.BORDER_FOCUS)
	_dbtn(th, &"SegTab", {"normal": [clear, clear, T.D_INK_3], "hover": [clear, T.D_LINE_HOVER, T.D_INK_3],
		"pressed": [clear, T.D_INK_1, T.D_INK_1], "disabled": [clear, clear, T.D_INK_OFF]},
		cond_sb_caps, T.D_FS_18, under_pad, 0, under)
	_dbtn(th, &"SegTabActive", {"normal": [clear, T.D_INK_1, T.D_INK_1], "hover": [clear, T.D_INK_1, T.D_INK_1],
		"pressed": [clear, T.D_INK_1, T.D_INK_1], "disabled": [clear, T.D_INK_1, T.D_INK_OFF]},
		cond_sb_caps, T.D_FS_18, under_pad, 0, under)
	var key_pad := _fit(cond_b, T.D_FS_16, T.D_H_SPEED_KEY, 0, 0)
	_dbtn(th, &"SpeedKey", {"normal": [T.D_SURFACE_5, clear, T.D_INK_3], "hover": [T.D_SURFACE_5, T.D_LINE_HOVER, T.D_INK_1],
		"pressed": [T.D_SURFACE_4, T.D_ACCENT, T.D_INK_1], "disabled": [T.D_SURFACE_2, clear, T.D_INK_OFF]},
		cond_b, T.D_FS_16, key_pad)
	# The running speed is the time state: an amber frame.
	_dbtn(th, &"SpeedKeyActive", {"normal": [T.D_SURFACE_4, T.D_ACCENT, T.D_INK_1], "hover": [T.D_SURFACE_4, T.D_ACCENT, T.D_INK_1],
		"pressed": [T.D_SURFACE_4, T.D_ACCENT, T.D_INK_1], "disabled": [T.D_SURFACE_2, clear, T.D_INK_OFF]},
		cond_b, T.D_FS_16, key_pad, T.D_RADIUS_2, thick)
	# A rail row is its box; the icon, name and badge are its children.
	var rail_pad := Vector4(T.SPACE_XXL, 0, T.SPACE_XL, 0)
	_dbtn(th, &"RailRow", {"normal": [clear, clear, T.D_INK_3], "hover": [clear, T.D_LINE_HOVER, T.D_INK_3],
		"pressed": [clear, T.D_LINE_HOVER, T.D_INK_3], "disabled": [clear, clear, T.D_INK_OFF]}, cond_sb_caps, T.D_FS_16, rail_pad)
	var inset: StyleBoxFlat = th.get_stylebox("hover", &"RailRow")
	inset.set_expand_margin(SIDE_LEFT, -T.SPACE_S)
	inset.set_expand_margin(SIDE_RIGHT, -T.SPACE_S)
	inset.set_expand_margin(SIDE_TOP, -T.SPACE_XXS)
	inset.set_expand_margin(SIDE_BOTTOM, -T.SPACE_XXS)
	_dbtn(th, &"RailRowActive", {"normal": [T.D_SURFACE_4, clear, T.D_INK_1], "hover": [T.D_SURFACE_4, clear, T.D_INK_1],
		"pressed": [T.D_SURFACE_4, clear, T.D_INK_1], "disabled": [T.D_SURFACE_4, clear, T.D_INK_OFF]}, cond_sb_caps, T.D_FS_16, rail_pad)
	var float_look := {"normal": [T.D_SURFACE_3, T.D_LINE_1, T.D_INK_2], "hover": [T.D_SURFACE_3, T.D_LINE_HOVER, T.D_INK_1],
		"pressed": [T.D_SURFACE_2, T.D_LINE_HOVER, T.D_INK_1], "disabled": [T.D_SURFACE_3, T.D_LINE_1, T.D_INK_OFF]}
	_dbtn(th, &"FloatButton", float_look, sans_med, T.D_FS_15,
		_fit(sans_med, T.D_FS_15, T.D_H_FLOAT_BTN, T.SPACE_L, T.SPACE_XL), T.D_RADIUS_3)
	for state in float_look:
		_shadow(th.get_stylebox(state, &"FloatButton"), T.D_SHADOW_FLOAT, T.D_SHADOW_FLOATING)
	_dbtn(th, &"TickerToggle", {"normal": [clear, T.D_LINE_1, T.D_INK_3], "hover": [clear, T.D_LINE_HOVER, T.D_INK_1],
		"pressed": [clear, T.D_LINE_HOVER, T.D_INK_1], "disabled": [clear, T.D_LINE_1, T.D_INK_OFF]},
		sans_reg, T.D_FS_14, Vector4.ZERO, 0, Vector4i(0, 0, T.BORDER_HAIRLINE, 0))
	th.set_constant("icon_max_width", &"TickerToggle", T.D_ICON_CONTROL)
	# A window's close: its glyph in a 40 px key, hover a border.
	_dbtn(th, &"WinClose", {"normal": [clear, clear, T.D_INK_3], "hover": [clear, T.D_LINE_HOVER, T.D_INK_1],
		"pressed": [T.D_SURFACE_2, T.D_LINE_HOVER, T.D_INK_1], "disabled": [clear, clear, T.D_INK_OFF]},
		sans_reg, T.D_FS_14, Vector4.ZERO)
	th.set_constant("icon_max_width", &"WinClose", T.D_ICON_CONTROL)
	# A float card's action is a small ghost button with a smaller glyph; its links are text keys.
	th.set_type_variation(&"FloatAction", &"GhostButtonSmall")
	th.set_constant("icon_max_width", &"FloatAction", T.D_ICON_ACTION)
	th.set_constant("h_separation", &"FloatAction", T.SPACE_S)
	_dbtn(th, &"FloatLink", ghost, sans_reg, T.D_FS_13, _fit(sans_reg, T.D_FS_13, T.D_H_LINK, T.SPACE_S, T.SPACE_S))
	# A paused progress keeps its share in a neutral fill.
	th.set_type_variation(&"ProgressPaused", &"ProgressBar")
	th.set_stylebox("fill", &"ProgressPaused", _flat(T.D_LINE_3, T.D_RADIUS_1, Vector4.ZERO))

	# ---- Ürün: the sprint screen ----
	# A sprint card is a small document, raised on its column; inside an open area row it sits a step
	# lower, and a card planned for the next sprint has no edge of its own (its host draws it dashed).
	var card_pad := Vector4(T.SPACE_XL, T.SPACE_L, T.SPACE_XL, T.SPACE_L)
	var mini_pad: Vector4 = Vector4.ONE * T.SPACE_M
	for row in [
		[&"SprintCard", T.D_SURFACE_4, T.D_LINE_2, card_pad],
		[&"SprintCardHover", T.D_SURFACE_4, T.D_LINE_HOVER, card_pad],
		[&"SprintCardLow", T.D_SURFACE_3, T.D_LINE_2, card_pad],
		[&"SprintCardLowHover", T.D_SURFACE_3, T.D_LINE_HOVER, card_pad],
		[&"SprintCardPlanned", T.D_SURFACE_3, clear, card_pad],
		[&"SprintCardMini", T.D_SURFACE_4, T.D_LINE_2, mini_pad],
		[&"SprintCardMiniPlanned", T.D_SURFACE_3, clear, mini_pad],
	]:
		_panel(th, row[0], "PanelContainer", _doc(_flat(row[1], 0, row[3], row[2]), T.D_CUT_SM))
	# The current sprint's band at the top of its quarter column follows the column's corners.
	var column_head := _flat(T.D_SURFACE_4, 0, Vector4.ZERO, T.D_LINE_1, bottom)
	column_head.corner_radius_top_left = T.D_RADIUS_3 - T.BORDER_HAIRLINE
	column_head.corner_radius_top_right = T.D_RADIUS_3 - T.BORDER_HAIRLINE
	for row in [
		# A sprint's column; the next sprint's is drawn dashed by its host.
		[&"SprintColumn", _flat(T.D_SURFACE_2, T.D_RADIUS_3, Vector4.ZERO, T.D_LINE_1)],
		[&"SprintColumnCurrent", _flat(T.D_SURFACE_2, T.D_RADIUS_3, Vector4.ZERO, T.D_LINE_3)],
		[&"SprintColumnNext", _flat(clear, T.D_RADIUS_3, Vector4.ZERO)],
		[&"SprintColumnHead", column_head],
		[&"SprintColumnFoot", _flat(clear, 0, Vector4(T.SPACE_XXL, T.SPACE_XL, T.SPACE_XXL, T.SPACE_XL), T.D_LINE_1,
			Vector4i(0, T.BORDER_HAIRLINE, 0, 0))],
		# A card's hover keys sit on the end of its effect line, on the card's own ground.
		[&"CardKeys", _flat(T.D_SURFACE_4, 0, Vector4(T.SPACE_M, 0, 0, 0))],
		[&"CardKeysPlanned", _flat(T.D_SURFACE_3, 0, Vector4(T.SPACE_M, 0, 0, 0))],
		# An area row's count of voices, and a flag in sentence case (a rival's launch, an area).
		[&"CountChip", _flat(clear, T.D_RADIUS_2, chip_pad, T.D_LINE_2)],
		[&"FlagChip", _flat(clear, T.D_RADIUS_2, flag_pad, T.D_LINE_3)],
		# The beta channel's two-way switch.
		[&"SegPickBox", _flat(clear, T.D_RADIUS_2, hairline, T.D_LINE_2)],
	]:
		_panel(th, row[0], "PanelContainer", row[1])
	# A card's points; a release note's row sits on the column, so its box is raised.
	var pts := _fit(sans_b, T.D_FS_13, T.D_H_TAG, T.SPACE_S, T.SPACE_S)
	for row in [[&"PtsBox", T.D_SURFACE_2], [&"PtsBoxRaised", T.D_SURFACE_4]]:
		_lbl(th, row[0], sans_b, T.D_FS_13, T.D_INK_2)
		th.set_stylebox("normal", row[0], _flat(row[1], T.D_RADIUS_2, pts, T.D_LINE_1))
	for row in [
		[&"ColumnTitle", cond_sb_caps, T.D_FS_18, T.D_INK_1],
		[&"FigureValue", sans_sb, T.D_FS_22, T.D_INK_1],
		[&"ReleaseValue", sans_b, T.D_FS_36, T.D_INK_1],
		[&"MetaText", sans_reg, T.D_FS_14, T.D_INK_2],
	]:
		_lbl(th, row[0], row[1], row[2], row[3])
	# A card's glyph keys (+, →, ↑): secondary keys the size their host gives them.
	_dbtn(th, &"IconKey", secondary, sans_reg, T.D_FS_15, Vector4.ZERO)
	th.set_constant("icon_max_width", &"IconKey", T.D_ICON_ROW)
	# The card's word key (Çıkar) at the glyph keys' height.
	_dbtn(th, &"CardKeyText", ghost, cond_sb, T.D_FS_16, _fit(cond_sb, T.D_FS_16, T.D_H_KEY_SM, T.SPACE_S, T.SPACE_S))
	# The two-way switch's segments: the one that is on is filled and underlined in ink.
	var seg_pad := _fit(sans_reg, T.D_FS_14, T.D_H_BTN_SM - 2 * T.BORDER_HAIRLINE, T.SPACE_L, T.SPACE_L)
	var on := [T.D_SURFACE_5, T.D_INK_1, T.D_INK_1]
	_dbtn(th, &"SegPick", {"normal": [clear, clear, T.D_INK_3], "hover": [clear, T.D_LINE_HOVER, T.D_INK_1],
		"pressed": on, "disabled": [clear, clear, T.D_INK_OFF]}, sans_reg, T.D_FS_14, seg_pad, 0, under)
	_dbtn(th, &"SegPickOn", {"normal": on, "hover": on, "pressed": on, "disabled": [T.D_SURFACE_5, T.D_INK_1, T.D_INK_OFF]},
		sans_reg, T.D_FS_14, seg_pad, 0, under)
	# A pick's glyph follows its number (the band picker's stars).
	for seg in [&"SegPick", &"SegPickOn"]:
		th.set_constant("icon_max_width", seg, T.D_ICON_STAR)
		th.set_constant("h_separation", seg, T.SPACE_XS)

	# ---- Satış: lead and account documents, the desk ----
	# A lead or an account is a small document; an account at risk sits on the danger ground, in the
	# palette in use. A rep's place on the desk is furniture: an inset box.
	_panel(th, &"DealDoc", "PanelContainer", _doc(_flat(T.D_SURFACE_4, 0, card_pad, T.D_LINE_2), T.D_CUT_SM))
	_panel(th, &"DeskCard", "PanelContainer", _flat(T.D_SURFACE_2, T.D_RADIUS_3, card_pad, T.D_LINE_1))
	# An open promise's note; its host draws the dashed edge.
	_panel(th, &"PromiseNote", "PanelContainer", _flat(clear, T.D_RADIUS_2,
		_fit(sans_reg, T.D_FS_13, T.D_H_PROMISE, T.SPACE_M, T.SPACE_M)))
	for cb in [false, true]:
		T.set_colorblind(cb)
		var twin := "Cb" if cb else ""
		_panel(th, "DealRisk" + twin, "PanelContainer", _doc(_flat(T.D_neg_bg(), 0, card_pad, T.D_neg_rule()), T.D_CUT_SM))
		# The churn countdown's weeks: the ones left filled.
		_panel(th, "PipOn" + twin, "Panel", _flat(T.D_neg(), T.D_RADIUS_1, Vector4.ZERO, T.D_neg()))
		_panel(th, "PipOff" + twin, "Panel", _flat(clear, T.D_RADIUS_1, Vector4.ZERO, T.D_badge_palette(&"negative").line))
	T.set_colorblind(false)
	for row in [
		[&"SatValue", sans_b, T.D_FS_15, T.D_INK_2],   # its host paints the satisfaction band
		[&"CaptionName", sans_sb, T.D_FS_13, T.D_INK_2],   # a name inside a caption's sentence
	]:
		_lbl(th, row[0], row[1], row[2], row[3])

	# ---- Finans: furniture cards, Frank's notes, the offers ----
	# A card in a window body is furniture on the inset ground; Frank's note and an offer are documents, the
	# note in the shutter on the danger edge of the palette in use.
	var body_pad := Vector4(T.SPACE_XXL, T.SPACE_XL, T.SPACE_XXL, T.SPACE_XL)
	for row in [
		[&"BodyCard", _flat(T.D_SURFACE_2, T.D_RADIUS_3, body_pad, T.D_LINE_1)],
		[&"FrankNote", _doc(_flat(T.D_SURFACE_4, 0, body_pad, T.D_LINE_2), T.D_CUT)],
		[&"FrankStrip", _doc(_flat(T.D_SURFACE_4, 0, Vector4(T.SPACE_M, T.SPACE_M, T.SPACE_XXL, T.SPACE_M), T.D_LINE_2),
			T.D_CUT_SM)],
		[&"OfferDoc", _doc(_flat(T.D_SURFACE_4, 0, Vector4(T.SPACE_XXL, T.SPACE_L, T.SPACE_XXL, T.SPACE_L), T.D_LINE_2),
			T.D_CUT)],
	]:
		_panel(th, row[0], "PanelContainer", row[1])
	for cb in [false, true]:
		T.set_colorblind(cb)
		_panel(th, "FrankNoteRisk" + ("Cb" if cb else ""), "PanelContainer",
			_doc(_flat(T.D_SURFACE_4, 0, body_pad, T.D_neg_rule()), T.D_CUT))
	T.set_colorblind(false)
	# Frank's line in his note: serif at body size on an amber rule, the one mark of his speaking.
	_panel(th, &"FrankSaid", "PanelContainer", _flat(clear, 0, Vector4(T.SPACE_L, 0, 0, 0), T.D_ACCENT,
		Vector4i(T.BORDER_FOCUS, 0, 0, 0)))
	_lbl(th, &"FrankSaidText", serif_reg, T.D_FS_16, T.D_INK_2)
	th.set_constant("line_spacing", &"FrankSaidText", T.D_LEADING_PARA)
	# The note on a chart's hovered week: a raised card, no shadow.
	_panel(th, &"ChartTip", "Panel", _flat(T.D_SURFACE_4, T.D_RADIUS_2, Vector4.ZERO, T.D_LINE_2))
	# An open ring: round the locked fund's lock, and a milestone not yet earned.
	_panel(th, &"LockDisc", "Panel", _flat(clear, T.RADIUS_PILL, Vector4.ZERO, T.D_LINE_2))
	for row in [
		[&"CardTitle", cond_sb, T.D_FS_15, T.D_INK_2],   # a card's title in its own case: the phase a goal leads to
		[&"MetaStrong", sans_sb, T.D_FS_14, T.D_INK_1],   # the one name a list stresses: the player's on the ladder
	]:
		_lbl(th, row[0], row[1], row[2], row[3])
	# The caps pick over a chart.
	var seg_sm := _fit(cond_sb_caps, T.D_FS_13, T.D_H_PICK_SM - 2 * T.BORDER_HAIRLINE, T.SPACE_L, T.SPACE_L)
	_dbtn(th, &"SegPickSm", {"normal": [clear, clear, T.D_INK_3], "hover": [clear, T.D_LINE_HOVER, T.D_INK_1],
		"pressed": on, "disabled": [clear, clear, T.D_INK_OFF]}, cond_sb_caps, T.D_FS_13, seg_sm, 0, under)
	_dbtn(th, &"SegPickSmOn", {"normal": on, "hover": on, "pressed": on, "disabled": [T.D_SURFACE_5, T.D_INK_1, T.D_INK_OFF]},
		cond_sb_caps, T.D_FS_13, seg_sm, 0, under)

	# ---- Kişisel: the founder's sheet ----
	# The founder's origin in their own words, under the name.
	_lbl(th, &"OriginQuote", serif_reg, T.D_FS_16, T.D_INK_3)
	th.set_constant("line_spacing", &"OriginQuote", T.D_LEADING_PARA)
	# An earned milestone's disc, round its glyph.
	_panel(th, &"MilestoneDot", "PanelContainer", _flat(T.D_SURFACE_5, T.RADIUS_PILL, Vector4.ZERO, T.D_LINE_3))

	# ---- Ar-Ge: the research tree, its node card and the tree's key ----
	# A tile by its state, its inset laid out by the host; a frozen tile's dashed edge and a locked slot are
	# drawn by their host.
	for row in [
		[&"RndTile", T.D_SURFACE_3, T.D_LINE_HOVER],
		[&"RndTileHover", T.D_SURFACE_3, T.D_INK_3],
		[&"RndTileActive", T.D_SURFACE_4, T.D_INK_2],
		[&"RndTileDone", T.D_SURFACE_5, T.D_LINE_3],
		[&"RndTileDoneHover", T.D_SURFACE_5, T.D_INK_3],
		[&"RndTileFrozen", T.D_SURFACE_4, clear],
		[&"RndTileSelected", T.D_SURFACE_4, T.D_INK_1],
	]:
		_panel(th, row[0], "Panel", _flat(row[1], T.D_RADIUS_2, Vector4.ZERO, row[2]))
	var req := _fit(sans_med, T.D_FS_15, T.D_H_REQ_CHIP, T.SPACE_L, T.SPACE_L)
	for row in [
		# The node card is a document under the tree.
		[&"NodeCard", _doc(_flat(T.D_SURFACE_4, 0, Vector4(T.SPACE_3XL, T.SPACE_XL, T.SPACE_XXL, T.SPACE_XL), T.D_LINE_2), T.D_CUT)],
		[&"ReqChip", _flat(T.D_SURFACE_2, T.D_RADIUS_2, req, T.D_LINE_1)],
		# A row's check box, empty and ticked; its glyph sits inside.
		[&"CheckSquare", _flat(T.D_SURFACE_2, T.D_RADIUS_1, Vector4.ONE * T.SPACE_XXS, T.D_LINE_3)],
		[&"CheckSquareOn", _flat(T.D_INK_2, T.D_RADIUS_1, Vector4.ONE * T.SPACE_XXS, T.D_INK_2)],
		# A picked row on a raised card sits a step higher still.
		[&"CardRowSelected", _flat(T.D_SURFACE_5, 0, Vector4.ZERO, T.D_ROW_RULE, bottom)],
		[&"CardRowSelectedHover", _flat(T.D_SURFACE_5, T.D_RADIUS_1, Vector4.ZERO, T.D_LINE_HOVER)],
		[&"WinFoot", _flat(clear, 0, Vector4(T.SPACE_3XL, 0, T.SPACE_3XL, 0), T.D_LINE_1, Vector4i(0, T.BORDER_HAIRLINE, 0, 0))],
		# What a finished research opened, inside its mail.
		[&"DiscBox", _doc(_flat(T.D_SURFACE_2, 0, Vector4(T.SPACE_XL, T.SPACE_L, T.SPACE_XL, T.SPACE_L), T.D_LINE_1), T.D_CUT_SM)],
	]:
		_panel(th, row[0], "PanelContainer", row[1])
	th.set_type_variation(&"CardRow", &"TableRow")
	th.set_type_variation(&"CardRowHover", &"TableRowHover")
	# A cost the treasury cannot meet, in the palette in use.
	for cb in [false, true]:
		T.set_colorblind(cb)
		var short: Dictionary = T.D_badge_palette(&"negative")
		_panel(th, "ReqChipRisk" + ("Cb" if cb else ""), "PanelContainer", _flat(short.bg, T.D_RADIUS_2, req, short.line))
	T.set_colorblind(false)

	# ---- Toplantı: the meeting dock, the call, the term sheet table ----
	# The dock stands over the office at its right; its head and its deck pad themselves. The founder's word
	# in the transcript is a small document, a step lower once the sitting has moved on; the inner voice is a
	# margin note on a 2 px rule. A result is a finished document, and so is the call's card.
	var top := Vector4i(0, T.BORDER_HAIRLINE, 0, 0)
	var say_pad := Vector4(T.SPACE_L, T.SPACE_M, T.SPACE_L, T.SPACE_L)
	var wide_pad := Vector4(T.SPACE_XXL, T.SPACE_XL, T.SPACE_XXL, T.SPACE_XL)
	for row in [
		[&"Dock", _shadow(_flat(T.D_SURFACE_3, 0, Vector4.ZERO, T.D_LINE_2, Vector4i(T.BORDER_HAIRLINE, 0, 0, 0)),
			T.D_SHADOW_FLOAT, T.D_SHADOW_FLOATING)],
		[&"DockHead", _flat(T.D_SURFACE_4, 0, Vector4(T.SPACE_3XL, T.SPACE_XXL, T.SPACE_3XL, T.SPACE_XL), T.D_LINE_1, bottom)],
		[&"DockDeck", _flat(T.D_SURFACE_3, 0, Vector4(T.SPACE_3XL, T.SPACE_XL, T.SPACE_3XL, T.SPACE_XXL), T.D_LINE_1, top)],
		[&"SayDoc", _doc(_flat(T.D_SURFACE_4, 0, say_pad, T.D_LINE_2), T.D_CUT_SM)],
		[&"SayDocPast", _doc(_flat(T.D_SURFACE_3, 0, say_pad, T.D_LINE_1), T.D_CUT_SM)],
		[&"QuietNote", _flat(clear, 0, Vector4(T.SPACE_L, 0, 0, 0), T.D_LINE_2, Vector4i(T.BORDER_FOCUS, 0, 0, 0))],
		[&"MeetOption", _flat(T.D_SURFACE_3, T.D_RADIUS_3, meet_pad, T.D_LINE_2)],
		[&"MeetOptionHover", _flat(T.D_SURFACE_3, T.D_RADIUS_3, meet_pad, T.D_LINE_HOVER)],
		[&"MeetOptionLocked", _flat(clear, T.D_RADIUS_3, meet_pad, T.D_LINE_1)],
		[&"ResultDoc", _doc(_flat(T.D_SURFACE_4, 0, Vector4(T.SPACE_XXL, T.SPACE_XL, T.SPACE_XXL, T.SPACE_M), T.D_LINE_2), T.D_CUT)],
		[&"CallDoc", _shadow(_doc(_flat(T.D_SURFACE_3, 0, wide_pad, T.D_LINE_1), T.D_CUT), T.D_SHADOW_FLOAT, T.D_SHADOW_FLOATING)],
		# The term sheet table: its head and foot bands, the head's figures (inset on their rule's side only, so the
		# last ends on the column's edge), the sheet and its levers (their marker on the row's own edge, so the host
		# insets their content), the fund's word, the other offer.
		[&"StageHead", _flat(T.D_SURFACE_1, 0, Vector4.ZERO, T.D_LINE_1, bottom)],
		[&"StageFoot", _flat(T.D_SURFACE_1, 0, Vector4.ZERO, T.D_LINE_1, top)],
		[&"StageKpi", _flat(clear, 0, Vector4(T.SPACE_3XL, 0, 0, 0), T.D_LINE_1, Vector4i(T.BORDER_HAIRLINE, 0, 0, 0))],
		[&"SheetDoc", _doc(_flat(T.D_SURFACE_3, 0, Vector4.ONE * T.SPACE_M, T.D_LINE_2), T.D_CUT)],
		[&"LeverRow", _flat(clear, T.D_RADIUS_1, Vector4.ZERO)],
		[&"LeverRowHover", _flat(clear, T.D_RADIUS_1, Vector4.ZERO, T.D_LINE_HOVER)],
		[&"LeverRowSelected", _flat(T.D_SURFACE_4, T.D_RADIUS_1, Vector4.ZERO)],
		[&"LeverRowSelectedHover", _flat(T.D_SURFACE_4, T.D_RADIUS_1, Vector4.ZERO, T.D_LINE_HOVER)],
		[&"SayBox", _flat(T.D_SURFACE_2, T.D_RADIUS_3, wide_pad, T.D_LINE_1)],
		[&"OtherDoc", _doc(_flat(T.D_SURFACE_3, 0, Vector4(T.SPACE_XXL, T.SPACE_L, T.SPACE_XL, T.SPACE_L), T.D_LINE_2), T.D_CUT_SM)],
		[&"TagOutlineBox", _flat(clear, T.D_RADIUS_2, tag, T.D_LINE_2)],
	]:
		_panel(th, row[0], "PanelContainer", row[1])
	# An option's or a lever's key: its number in a 24 px key, off when the option is not open.
	for row in [[&"KeyCap", T.D_INK_3, T.D_LINE_3], [&"KeyCapOff", T.D_INK_OFF, T.D_LINE_1]]:
		_lbl(th, row[0], cond_sb, T.D_FS_14, row[1])
		th.set_stylebox("normal", row[0], _flat(clear, T.D_RADIUS_2, Vector4.ZERO, row[2]))
	for row in [[&"SayLine", sans_reg, T.D_FS_16, T.D_INK_1], [&"FrankLine", serif_reg, T.D_FS_18, T.D_INK_1],
			[&"TagOutlineInk", cond_b_caps, T.D_FS_13, T.D_INK_3]]:
		_lbl(th, row[0], row[1], row[2], row[3])
	for line in [&"SayLine", &"FrankLine"]:
		th.set_constant("line_spacing", line, T.D_LEADING_PARA)

	# Message body and ticker text.
	th.set_type_variation(&"PaneBodyRich", &"RichTextLabel")
	_rich_fonts(th, &"PaneBodyRich", sans_reg, sans_sb, serif_it, sans_reg, T.D_FS_16)
	th.set_color("default_color", &"PaneBodyRich", T.D_INK_2)
	th.set_constant("line_separation", &"PaneBodyRich", T.D_LEADING_PARA)
	th.set_constant("paragraph_separation", &"PaneBodyRich", T.SPACE_XL)
	# Frank writes his mail in the serif.
	th.set_type_variation(&"PaneQuoteRich", &"RichTextLabel")
	_rich_fonts(th, &"PaneQuoteRich", serif_reg, serif_sb, serif_it, serif_reg, T.D_FS_20)
	th.set_color("default_color", &"PaneQuoteRich", T.D_INK_2)
	th.set_constant("line_separation", &"PaneQuoteRich", T.D_LEADING_PARA)
	th.set_constant("paragraph_separation", &"PaneQuoteRich", T.SPACE_XL)
	th.set_type_variation(&"TickerRich", &"RichTextLabel")
	_rich_fonts(th, &"TickerRich", sans_reg, sans_sb, serif_it, sans_reg, T.D_FS_14)
	th.set_color("default_color", &"TickerRich", T.D_INK_3)

	var check = load("res://scripts/theme/theme_check.gd")
	errors.append_array(check.missing(th, master))
	errors.append_array(check.unset_margins(th))
	for e in errors:
		push_error("[build_theme] menajer_theme: " + e)
	return th if errors.is_empty() else null


func _copy_dark(master: Theme, th: Theme, faces: Dictionary) -> PackedStringArray:
	var errors := PackedStringArray()
	var consts: Dictionary = T.get_script_constant_map()
	var dark_of := {}
	for kind in DARK_OF:
		for cream in DARK_OF[kind]:
			var key: String = kind + (consts[cream] as Color).to_html()
			var to: Color = consts[DARK_OF[kind][cream]]
			if dark_of.get(key, to) != to:
				errors.append("%s of %s has two dark tokens" % [kind, cream])
			dark_of[key] = to
	var boxes := {}
	for type in master.get_type_list():
		var base := master.get_type_variation_base(type)
		if base != &"":
			th.set_type_variation(type, base)
		var t := type
		while t != &"":
			for dt in Theme.DATA_TYPE_MAX:
				for item in master.get_theme_item_list(dt, t):
					if th.has_theme_item(dt, item, type):
						continue
					var at := "%s/%s" % [type, item]
					var v = master.get_theme_item(dt, item, t)
					match dt:
						Theme.DATA_TYPE_COLOR:
							v = _tone(v, "OFF" if "disabled" in item else "FONT", dark_of, errors, at)
						Theme.DATA_TYPE_FONT:
							v = faces.get(v.resource_path.get_file().get_basename())
						Theme.DATA_TYPE_STYLEBOX:
							if not boxes.has(v):
								boxes[v] = _dark_box(v, dark_of, errors, at)
							v = boxes[v]
					th.set_theme_item(dt, item, type, v)
			var up := master.get_type_variation_base(t)
			t = up if up != &"" else (ClassDB.get_parent_class(t) if ClassDB.class_exists(t) else &"")
	return errors


func _tone(c: Color, kind: String, dark_of: Dictionary, errors: PackedStringArray, at: String) -> Color:
	if c.a == 0.0:
		return c
	if kind == "OFF":
		return T.D_INK_OFF
	var key := kind + c.to_html()
	if not dark_of.has(key):
		errors.append("%s #%s (%s) has no dark token" % [at, c.to_html(), kind])
		return c
	return dark_of[key]


## A master box in dark tokens with its effective content margins written out.
func _dark_box(sb: StyleBox, dark_of: Dictionary, errors: PackedStringArray, at: String) -> StyleBox:
	var d = sb.duplicate()
	if d is StyleBoxFlat:
		if d.draw_center:
			d.bg_color = _tone(d.bg_color, "FILL", dark_of, errors, at)
		if d.border_width_left + d.border_width_top + d.border_width_right + d.border_width_bottom > 0:
			d.border_color = _tone(d.border_color, "EDGE", dark_of, errors, at)
		if d.shadow_size > 0:
			d.shadow_color = _tone(d.shadow_color, "SHADOW", dark_of, errors, at)
	elif d is StyleBoxLine:
		d.color = _tone(d.color, "LINE", dark_of, errors, at)
	return _pin(d)


## One item of one type, recoloured on its own copy of the box.
func _recolor(th: Theme, type: StringName, item: StringName, fill = null, edge = null) -> void:
	var sb: StyleBoxFlat = th.get_stylebox(item, type).duplicate()
	if fill != null:
		sb.bg_color = fill
	if edge != null:
		sb.border_color = edge
	th.set_stylebox(item, type, sb)


## A flat box: content margins [L, T, R, B], where -1 leaves a side to the border; border widths
## [L, T, R, B] drawn only in a visible colour.
func _flat(bg: Color, radius: int, pad: Vector4, border := Color.TRANSPARENT, widths := Vector4i(1, 1, 1, 1)) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.set_corner_radius_all(radius)
	if border.a > 0.0:
		sb.border_color = border
		sb.border_width_left = widths.x
		sb.border_width_top = widths.y
		sb.border_width_right = widths.z
		sb.border_width_bottom = widths.w
	sb.content_margin_left = pad.x
	sb.content_margin_top = pad.y
	sb.content_margin_right = pad.z
	sb.content_margin_bottom = pad.w
	return sb


## Content margins that centre one line of the face in a box exactly h tall.
func _fit(face: Font, size: int, h: int, left: int, right: int) -> Vector4:
	var spare := h - face.get_height(size)
	var top := floorf(spare / 2.0)
	return Vector4(left, top, right, spare - top)


func _pad_of(sb: StyleBox) -> Vector4:
	return Vector4(sb.get_margin(SIDE_LEFT), sb.get_margin(SIDE_TOP), sb.get_margin(SIDE_RIGHT), sb.get_margin(SIDE_BOTTOM))


## Writes a box's effective content margins out, so it never falls back to its border.
func _pin(sb: StyleBox) -> StyleBox:
	for side in 4:
		sb.set_content_margin(side, sb.get_margin(side))
	return sb


## A document: its top-right corner cut, the other three nearly square (detail 1 bevels them all).
func _doc(sb: StyleBoxFlat, cut: int) -> StyleBoxFlat:
	sb.set_corner_radius_all(T.D_RADIUS_1)
	sb.corner_radius_top_right = cut
	sb.corner_detail = 1
	return sb


## shadow is (size, y offset).
func _shadow(sb: StyleBoxFlat, color: Color, shadow: Vector2i) -> StyleBoxFlat:
	sb.shadow_color = color
	sb.shadow_size = shadow.x
	sb.shadow_offset = Vector2(0, shadow.y)
	return sb


## A dark button from {state: [fill, edge, ink]}; every state's box carries the same margins, so no
## state moves the label, and a glyph takes its label's ink. A class is styled in place, any other
## name becomes a Button variation.
func _dbtn(th: Theme, name: StringName, look: Dictionary, face: Font, size: int, pad: Vector4,
		radius: int = T.D_RADIUS_2, widths := Vector4i(1, 1, 1, 1)) -> void:
	if not ClassDB.class_exists(name):
		th.set_type_variation(name, &"Button")
	for state in look:
		th.set_stylebox(state, name, _flat(look[state][0], radius, pad, look[state][1], widths))
		th.set_color(INK_OF[state], name, look[state][2])
		th.set_color("icon_%s_color" % state, name, look[state][2])
	for part in ["font", "icon"]:
		th.set_color(part + "_hover_pressed_color", name, look.pressed[2])
		th.set_color(part + "_focus_color", name, look.normal[2])
	th.set_font("font", name, face)
	th.set_font_size("font_size", name, size)


# --- helpers ----------------------------------------------------------------

## A face with its fallback (none for a chain of one) and whole-pixel tracking.
func _mkfont(ttf_path: String, fallback: Font, vname: String, spacing: int = 0, features: Dictionary = {}) -> FontVariation:
	var base: FontFile = load(ttf_path)
	if base == null:
		push_error("[build_theme] font load failed: %s" % ttf_path)
		quit(1)
	var fv := FontVariation.new()
	fv.base_font = base
	fv.fallbacks = [fallback] if fallback != null else []
	fv.spacing_glyph = spacing
	fv.opentype_features = features
	var path := VAR_DIR + vname + ".tres"
	_save(fv, path)
	return load(path)


## Saves with ids derived from content instead of the saver's random ones, so an unchanged rebuild
## writes the same bytes.
func _save(res: Resource, path: String) -> Error:
	_stamp_ids(res, path, {}, {})
	return ResourceSaver.save(res, path)


## A file reference takes its id from its path, an embedded resource from its class and stored
## values, numbered when two store the same.
func _stamp_ids(res: Resource, path: String, seen: Dictionary, taken: Dictionary) -> void:
	for prop in res.get_property_list():
		if not (prop.usage & PROPERTY_USAGE_STORAGE):
			continue
		var value = res.get(prop.name)
		for v in (value if value is Array else [value]):
			if not v is Resource or seen.has(v):
				continue
			seen[v] = true
			if not v.is_built_in():
				v.set_id_for_path(path, "%s_%s" % [v.resource_path.get_file().get_basename(), v.resource_path.md5_text().left(5)])
				continue
			var stored := PackedStringArray()
			for p in v.get_property_list():
				if p.usage & PROPERTY_USAGE_STORAGE:
					var x = v.get(p.name)
					stored.append("%s=%s" % [p.name, x.resource_path if x is Resource else var_to_str(x)])
			var stem := "%s_%s" % [v.get_class(), " ".join(stored).md5_text().left(5)]
			var id := stem
			var n := 1
			while taken.has(id):
				n += 1
				id = "%s_%d" % [stem, n]
			taken[id] = true
			v.resource_scene_unique_id = id
			_stamp_ids(v, path, seen, taken)


## Flat box: fill, radius, optional uniform border (colour + width) and content margins (h, v).
func _box(bg: Color, radius: int, border: Color = Color.TRANSPARENT, pad: Vector2i = NO_PAD,
		width: int = T.BORDER_HAIRLINE) -> StyleBoxFlat:
	return _sides_box(bg, radius, Vector4i(width, width, width, width), border, pad)


## Flat box with per-side border widths [L, T, R, B] in one colour and content margins (h, v).
func _sides_box(bg: Color, radius: int, widths: Vector4i, color: Color, pad: Vector2i = NO_PAD) -> StyleBoxFlat:
	return _flat(bg, radius, Vector4(pad.x, pad.y, pad.x, pad.y), color, widths)


func _no_focus() -> StyleBoxFlat:
	return _box(Color.TRANSPARENT, T.RADIUS_NONE)


func _rule(color: Color, vertical: bool) -> StyleBoxLine:
	var line := StyleBoxLine.new()
	line.color = color
	line.thickness = T.BORDER_HAIRLINE
	line.vertical = vertical
	return line


func _states(th: Theme, name: StringName, boxes: Dictionary) -> void:
	for state in boxes:
		th.set_stylebox(state, name, boxes[state])


func _lbl(th: Theme, name: StringName, font: Font, size: int, color: Color) -> void:
	th.set_type_variation(name, &"Label")
	th.set_font("font", name, font)
	th.set_font_size("font_size", name, size)
	th.set_color("font_color", name, color)


func _panel(th: Theme, name: StringName, base: StringName, sb: StyleBox) -> void:
	th.set_type_variation(name, base)
	th.set_stylebox("panel", name, sb)


func _rich_fonts(th: Theme, name: StringName, normal: Font, bold: Font, italics: Font,
		mono: Font, size: int) -> void:
	th.set_font("normal_font", name, normal)
	th.set_font("bold_font", name, bold)
	th.set_font("italics_font", name, italics)
	th.set_font("bold_italics_font", name, bold)
	th.set_font("mono_font", name, mono)
	for key in ["normal_font_size", "bold_font_size", "italics_font_size",
			"bold_italics_font_size", "mono_font_size"]:
		th.set_font_size(key, name, size)


# Rail tile. Idle: CARD_BG fill + CARD_BORDER hairline; hover moves only the edge to
# BORDER_HOVER. Active: TAB_ACTIVE_BG + an ACCENT_DEEP left rule; hover equals normal.
# Both carry the same content margins, so a tile with its own text (the Sales tab's
# band-cap selector) does not jump when it turns active.
func _tab_button(th: Theme, name: StringName, active: bool) -> void:
	th.set_type_variation(name, &"Button")
	var normal: StyleBoxFlat
	var hover: StyleBoxFlat
	if active:
		normal = _sides_box(T.TAB_ACTIVE_BG, T.RADIUS_WINDOW, Vector4i(T.BORDER_ACCENT, 0, 0, 0), T.ACCENT_DEEP, T.PAD_BTN_XS)
		hover = normal
	else:
		normal = _box(T.CARD_BG, T.RADIUS_WINDOW, T.CARD_BORDER, T.PAD_BTN_XS)
		hover = _box(T.CARD_BG, T.RADIUS_WINDOW, T.BORDER_HOVER, T.PAD_BTN_XS)
	_states(th, name, {"normal": normal, "hover": hover, "pressed": normal, "focus": _no_focus()})
	var fc: Color = T.ACCENT_DEEP if active else T.INK_DIM
	th.set_color("font_color", name, fc)
	th.set_color("font_hover_color", name, fc if active else T.INK)
	th.set_color("font_pressed_color", name, fc)
	th.set_color("font_focus_color", name, fc)


# Speed key on the TopBar, so every colour is a frame twin: active = ACCENT_DIM fill +
# amber edge + amber text; idle = no fill, hairline edge, dim text. Hover again moves
# only the edge.
func _speed_button(th: Theme, name: StringName, active: bool) -> void:
	th.set_type_variation(name, &"Button")
	var normal: StyleBoxFlat
	var hover: StyleBoxFlat
	if active:
		normal = _box(T.ACCENT_DIM, T.RADIUS_S, T.ACCENT_CHROME, T.PAD_BTN_XS)
		hover = normal
	else:
		normal = _box(Color.TRANSPARENT, T.RADIUS_S, T.CARD_BORDER_CHROME, T.PAD_BTN_XS)
		hover = _box(Color.TRANSPARENT, T.RADIUS_S, T.BORDER_HOVER_CHROME, T.PAD_BTN_XS)
	_states(th, name, {"normal": normal, "hover": hover, "pressed": normal, "focus": _no_focus()})
	th.set_font_size("font_size", name, T.SIZE_SMALL)
	th.set_color("font_color", name, T.ACCENT_CHROME if active else T.INK_DIM_CHROME)
	th.set_color("font_hover_color", name, T.ACCENT_CHROME if active else T.INK_MUTED_CHROME)
	th.set_color("font_pressed_color", name, T.ACCENT_CHROME)


# Primary button: filled amber with ON_ACCENT text, the ink that reads on the fill. The body's
# disables onto the cream plate. The dark stages' (CommitButtonDark) take the frame's amber and
# disable onto their own recessed card: the cream plate would glare on the charcoal.
func _commit_button(th: Theme, name: StringName, dark: bool, pad: Vector2i = T.PAD_CTA) -> void:
	th.set_type_variation(name, &"Button")
	_states(th, name, {
		"normal": _box(T.ACCENT_CHROME if dark else T.ACCENT, T.RADIUS_M, Color.TRANSPARENT, pad),
		"hover": _box(T.ACCENT_HOVER_CHROME if dark else T.ACCENT_HOVER, T.RADIUS_M, Color.TRANSPARENT, pad),
		"pressed": _box(T.ACCENT_PRESSED_CHROME if dark else T.ACCENT_PRESSED, T.RADIUS_M, Color.TRANSPARENT, pad),
		"disabled": _box(T.DIALOGUE_CARD_BG if dark else T.SURFACE_DISABLED, T.RADIUS_M,
			T.DIALOGUE_CARD_BORDER if dark else T.BORDER_DISABLED, pad),
		"focus": _no_focus(),
	})
	th.set_color("font_color", name, T.ON_ACCENT)
	th.set_color("font_hover_color", name, T.ON_ACCENT)
	th.set_color("font_pressed_color", name, T.ON_ACCENT)
	th.set_color("font_disabled_color", name, T.CREAM_DIM_DISABLED if dark else T.INK_DIM)
