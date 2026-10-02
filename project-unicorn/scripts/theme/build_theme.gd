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
#
# Every size here is a UiTokens scale step: a variation picks a step, it never
# invents a number.
# ============================================================================

# Loaded in _initialize, not preloaded: ui_tokens.gd names the GameState autoload, which a
# `-s` script's own compile pass cannot resolve yet.
var T

const FONT_SERIF_REG := "res://assets/fonts/serif/SourceSerif4-Regular.ttf"
const FONT_SERIF_SB := "res://assets/fonts/serif/SourceSerif4-Semibold.ttf"
const FONT_SERIF_IT := "res://assets/fonts/serif/SourceSerif4-It.ttf"
const FONT_SANS_REG := "res://assets/fonts/sans/IBMPlexSans-Regular.ttf"
const FONT_SANS_SB := "res://assets/fonts/sans/IBMPlexSans-SemiBold.ttf"
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
	var mono_label := _mkfont(FONT_MONO_REG, symbols, "mono_label", 0.6)
	var mono_sb := _mkfont(FONT_MONO_SB, symbols, "mono_sb", 0.6)

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
	_lbl(th, &"TabLabel", mono_label, T.SIZE_META, T.INK_DIM)
	_lbl(th, &"BadgeLabel", mono_reg, T.SIZE_MICRO, T.INK)
	_lbl(th, &"ChoiceLabelStrong", sans_sb, T.SIZE_LEAD, T.INK)
	_lbl(th, &"ChoiceLabelLocked", sans_reg, T.SIZE_LEAD, T.INK_FAINT)   # an option that is not open
	_lbl(th, &"FeedDay", mono_reg, T.SIZE_SMALL, T.INK_MUTED)
	_lbl(th, &"ChromeLabel", mono_label, T.SIZE_MICRO, T.CREAM_DIM)
	_lbl(th, &"ChromeValue", sans_sb, T.SIZE_BODY, T.CREAM)
	_lbl(th, &"ChromeClock", mono_reg, T.SIZE_DATA, T.CREAM_DIM)   # TopBar tarih/saat
	# ChromeAlert: KEPENK / TEKLİF geri sayımı. Tema statiktir; renk körü takası bu
	# etiketi top_bar.gd'de yeniden boyar.
	_lbl(th, &"ChromeAlert", mono_sb, T.SIZE_SMALL, T.NEGATIVE_BRIGHT)
	_lbl(th, &"ColumnHeader", mono_label, T.SIZE_META, T.INK_DIM)  # defter sütun başlığı
	_lbl(th, &"SectionAmber", mono_label, T.SIZE_SMALL, T.ACCENT_DEEP)  # kural çizgisiyle birlikte kullanılır
	# Serif YALNIZ sayfa ve modal başlığıdır.
	_lbl(th, &"PageTitleSerif", serif_sb, T.SIZE_ED_CEREMONY, T.INK)
	_lbl(th, &"ModalTitleSerif", serif_sb, T.SIZE_ED_MODAL, T.INK)
	# Özet başlık satırında yaşar, asla kopuk bir alt şeritte değil.
	_lbl(th, &"TitleRowSummary", mono_label, T.SIZE_SMALL, T.INK_DIM)
	_lbl(th, &"EmptyRowLabel", mono_reg, T.SIZE_DATA, T.INK_FAINT)     # "Henüz kimse yok"
	_lbl(th, &"LockedTelegraph", mono_label, T.SIZE_SMALL, T.INK_FAINT) # "EĞİTİM · KİLİTLİ"
	_lbl(th, &"RowName", sans_sb, T.SIZE_BODY, T.INK)
	_lbl(th, &"RowMeta", mono_reg, T.SIZE_SMALL, T.INK_MUTED)
	_lbl(th, &"AvatarInitial", sans_sb, T.SIZE_BODY, T.CREAM)
	_lbl(th, &"MetricValueInk", sans_sb, T.SIZE_TITLE, T.INK)
	_lbl(th, &"MetricCaptionInk", mono_label, T.SIZE_MICRO, T.INK_DIM)
	# StepperValue: bir stepper'ın ortasındaki sayı. Vurgu ağırlığında, çünkü kutunun
	# devralan ve karar veren hâlleri ağırlıkla ayrışıyor — rengin tek başına
	# taşıyamadığı ayrım bu.
	_lbl(th, &"StepperValue", mono_sb, T.SIZE_DATA, T.INK)

	# ---- Meeting dock (cream body): header and transcript ----
	_lbl(th, &"MeetingSpeakerName", serif_sb, T.SIZE_ED_HEADLINE, T.INK)
	_lbl(th, &"MeetingRole", mono_label, T.SIZE_SMALL, T.INK_MUTED)
	_lbl(th, &"MeetingLine", serif_reg, T.SIZE_TITLE, T.INK)            # a counterpart's spoken line
	_lbl(th, &"MeetingFounderLine", sans_reg, T.SIZE_LEAD, T.ON_INK)    # inside MeetingFounderBubble
	_lbl(th, &"MeetingFounderName", mono_sb, T.SIZE_SMALL, T.ACCENT)
	# The panel repaints it per band from UiTokens.attitude_ink.
	_lbl(th, &"MeetingAttitudeWord", mono_sb, T.SIZE_SMALL, T.INK)
	_lbl(th, &"MeetingFigure", mono_sb, T.SIZE_LEAD, T.INK)             # a number on the price table
	# A sales table's percent: its own tone says the reasons are on hover.
	_lbl(th, &"MeetingOdds", mono_reg, T.SIZE_SMALL, T.ACCENT_DEEP)

	# ---- Cinematic dialogue register: text on the dark column ----
	_lbl(th, &"DialogueName", sans_sb, T.SIZE_LEAD, T.CREAM)  # counterpart name (uppercased in code)
	_lbl(th, &"DialogueRole", mono_label, T.SIZE_SMALL, T.CREAM_DIM)    # role line under the name
	_lbl(th, &"DialogueTag", mono_label, T.SIZE_MICRO, T.CREAM_DIM)  # speaker-tag chip "ANCHOR — CANLI"
	_lbl(th, &"QuoteSerifCream", serif_it, T.SIZE_LEAD, T.CREAM)     # spoken line
	_lbl(th, &"DialogueMonologue", serif_it, T.SIZE_LEAD, T.CREAM_DIM) # interior voice
	_lbl(th, &"DialogueChoiceLabel", sans_reg, T.SIZE_LEAD, T.CREAM)   # choice text
	_lbl(th, &"DialogueOdds", mono_reg, T.SIZE_SMALL, T.CREAM_DIM)   # odds / caption line
	_lbl(th, &"DialogueNumber", mono_reg, T.SIZE_SMALL, T.CREAM_DIM) # step counter / numeric caption
	_lbl(th, &"ZoneLabel", mono_label, T.SIZE_MICRO, T.CREAM_DIM)    # micro caption on the dark screens
	_lbl(th, &"TooltipTitle", mono_label, T.SIZE_MICRO, T.ACCENT_CHROME)  # a dark tooltip's heading
	_lbl(th, &"ConvictionValue", mono_reg, T.SIZE_BODY, T.CREAM)       # İKNA numeric readout
	_lbl(th, &"StatStripLabel", mono_reg, T.SIZE_SMALL, T.CREAM)     # term-sheet pressure strip

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
	_panel(th, &"TopBarPanel", "Panel", _sides_box(T.BG_TOPBAR, T.RADIUS_NONE, [0, 0, 0, T.BORDER_HAIRLINE], T.SEPARATOR))
	# SideRailPanel: the cream tab rail; a right hairline divides it from the office.
	_panel(th, &"SideRailPanel", "Panel", _sides_box(T.BG_PANEL, T.RADIUS_NONE, [0, T.BORDER_HAIRLINE, 0, 0], T.CARD_BORDER))
	_panel(th, &"NewsPanel", "Panel", _sides_box(T.BG_NEWS, T.RADIUS_NONE, [0, 0, T.BORDER_HAIRLINE, 0], T.SEPARATOR))
	_panel(th, &"ViewportPanel", "Panel", _box(T.BG_BODY, T.RADIUS_NONE))
	_panel(th, &"ModalPanel", "Panel", _box(T.CARD_BG, T.RADIUS_L, T.CARD_BORDER))
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
	# EmptyRow: boş departman satırı. Kesikli kenar yerine tek piksellik düz kenar,
	# dolgu yok — böylece "boş" okunuyor.
	_panel(th, &"EmptyRow", "PanelContainer", _box(Color.TRANSPARENT, T.RADIUS_M, T.BORDER_DASHED, T.PAD_ROW))
	# LedgerRow(+Hover): hover yalnız kenar; dolgu ve margin aynı kalır, yoksa satır zıplar.
	_panel(th, &"LedgerRow", "PanelContainer", _box(T.CARD_BG, T.RADIUS_M, T.CARD_BORDER, T.PAD_ROW))
	_panel(th, &"LedgerRowHover", "PanelContainer", _box(T.CARD_BG, T.RADIUS_M, T.BORDER_HOVER, T.PAD_ROW))
	# Durum çipleri: ince renkli kenar + soluk dolgu.
	_panel(th, &"ChipNeutral", "PanelContainer", _box(T.NEUTRAL_BADGE_BG, T.RADIUS_S, T.BORDER_DISABLED, T.PAD_CHIP))
	_panel(th, &"ChipAmber", "PanelContainer", _box(T.AMBER_BG, T.RADIUS_S, T.ACCENT_DEEP, T.PAD_CHIP))
	_panel(th, &"ChipPositive", "PanelContainer", _box(T.POSITIVE_BG, T.RADIUS_S, T.POSITIVE_RULE, T.PAD_CHIP))
	_panel(th, &"ChipNegative", "PanelContainer", _box(T.NEGATIVE_BG, T.RADIUS_S, T.NEGATIVE_RULE, T.PAD_CHIP))
	_panel(th, &"ChoiceCard", "PanelContainer", _box(T.CARD_BG, T.RADIUS_M, T.CARD_BORDER, T.PAD_CHOICE))
	_panel(th, &"ChoiceCardHover", "PanelContainer", _box(T.CARD_BG, T.RADIUS_M, T.ACCENT_DEEP, T.PAD_CHOICE))
	# A choice in the warning tone keeps the ChoiceCard padding, so turning alert moves no row.
	_panel(th, &"ChoiceCardAlert", "PanelContainer", _box(T.CARD_ATTENTION_BG, T.RADIUS_M, T.CARD_ATTENTION_BORDER, T.PAD_CHOICE))
	_panel(th, &"HeaderBand", "PanelContainer", _sides_box(Color.TRANSPARENT, T.RADIUS_NONE, [0, 0, 0, T.BORDER_HAIRLINE], T.BORDER_DISABLED, T.PAD_STRIP))
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

	# ---- Meeting dock (cream body) ----
	# The dock's sections pad themselves, so the dock carries only its left hairline.
	_panel(th, &"MeetingDock", "PanelContainer", _sides_box(T.BG_BODY, T.RADIUS_NONE, [T.BORDER_HAIRLINE, 0, 0, 0], T.CARD_BORDER))
	_panel(th, &"MeetingHeader", "PanelContainer", _sides_box(T.SURFACE_ROW_TINT, T.RADIUS_NONE, [0, 0, 0, T.BORDER_HAIRLINE], T.CARD_BORDER, T.PAD_MEETING_HEADER))
	_panel(th, &"MeetingDeck", "PanelContainer", _sides_box(T.SURFACE_FRAME, T.RADIUS_NONE, [0, 0, T.BORDER_HAIRLINE, 0], T.CARD_BORDER, T.PAD_MEETING_DECK))
	_panel(th, &"MeetingFounderBubble", "PanelContainer", _box(T.INK, T.RADIUS_M, Color.TRANSPARENT, T.PAD_ROW))
	# NumberChip: an option's number disc.
	_panel(th, &"NumberChip", "PanelContainer", _box(T.SURFACE_SUNKEN, T.RADIUS_PILL))

	# ---- Cinematic dialogue register: dark panels ----
	# Column = floating semi-opaque charcoal (art shows through); Card = solid
	# charcoal for the Frank popup; QuoteBox carries the amber left-edge bar;
	# DialogueChoice(+Hover) swap on mouse-over.
	_panel(th, &"DialogueColumn", "Panel", _box(T.DIALOGUE_COLUMN_BG, T.RADIUS_XXL))
	_panel(th, &"DialogueCard", "Panel", _box(T.DIALOGUE_BG, T.RADIUS_CARD_LG, T.DIALOGUE_CARD_BORDER))
	_panel(th, &"PortraitFrame", "PanelContainer", _box(T.PORTRAIT_FRAME, T.RADIUS_PORTRAIT, Color.TRANSPARENT, T.PAD_FRAME))
	_panel(th, &"QuoteBox", "PanelContainer", _sides_box(T.DIALOGUE_CARD_BG, T.RADIUS_M, [T.BORDER_ACCENT, 0, 0, 0], T.ACCENT_CHROME, T.PAD_ROW))
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
	_panel(th, &"RailPanel", "PanelContainer", _sides_box(T.DIALOGUE_BG, T.RADIUS_NONE, [T.BORDER_HAIRLINE, 0, 0, 0], T.SEPARATOR, T.PAD_RAIL))
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
	var row_hot := _sides_box(T.AMBER_WASH, T.RADIUS_NONE, [T.BORDER_FOCUS, 0, 0, 0], T.ACCENT_DEEP, T.PAD_ACTION_ROW)
	_states(th, &"ActionRow", {
		"normal": row_flat,
		"hover": row_hot,
		"pressed": row_hot,
		"disabled": row_flat,
		"focus": _no_focus(),
	})

	# StanceDial(+Active): the Sales tab's price dial. It is the single source of every B2B
	# price, so the selected position cannot be missed: amber wash, amber edge, amber text.
	for active in [false, true]:
		var name: StringName = &"StanceDialActive" if active else &"StanceDial"
		var ink: Color = T.ACCENT_DEEP if active else T.INK_DIM
		var dial := _box(T.AMBER_BG if active else T.SURFACE_INPUT, T.RADIUS_S,
			T.ACCENT_DEEP if active else T.BORDER_DISABLED, T.PAD_DIAL)
		th.set_type_variation(name, &"Button")
		_states(th, name, {"normal": dial, "hover": dial, "pressed": dial, "focus": _no_focus()})
		th.set_font_size("font_size", name, T.SIZE_META)
		th.set_color("font_color", name, ink)
		th.set_color("font_hover_color", name, ink if active else T.INK)
		th.set_color("font_pressed_color", name, ink)

	# ========================================================================
	# ÜRÜN SPRINT EKRANI — folder window, paper cards, stamps. No semantic green or
	# red here: CANLI, the warning chip, "!", the Güçlü/Zayıf words and the over-capacity
	# bar are painted at runtime through the colourblind helpers.
	# ========================================================================
	_panel(th, &"FolderWindow", "PanelContainer", window_sb)
	_panel(th, &"FolderColumn", "PanelContainer", _box(T.CARD_BG, T.RADIUS_PAPER, T.CARD_BORDER, Vector2i(T.SPACE_M, T.SPACE_M)))
	_panel(th, &"FolderColumnActive", "PanelContainer", _box(T.CARD_BG, T.RADIUS_PAPER, T.ACCENT_DEEP, Vector2i(T.SPACE_XL, T.SPACE_XL)))
	# The dashed variants draw their outline in code: StyleBoxFlat cannot dash.
	_panel(th, &"FolderColumnDashed", "PanelContainer", _box(Color.TRANSPARENT, T.RADIUS_PAPER, Color.TRANSPARENT, Vector2i(T.SPACE_XL, T.SPACE_XL)))
	_panel(th, &"PaperCard", "PanelContainer", _box(T.CARD_BG, T.RADIUS_PAPER, T.CARD_BORDER, T.PAD_PAPER_CARD))
	# Open area row and hovered card: PaperCard's margins, so the content does not move.
	_panel(th, &"PaperCardOpen", "PanelContainer", _box(T.CARD_BG, T.RADIUS_PAPER, T.ACCENT_DEEP, T.PAD_PAPER_CARD, T.BORDER_FOCUS))
	_panel(th, &"PaperCardDashed", "PanelContainer", _box(Color.TRANSPARENT, T.RADIUS_PAPER, Color.TRANSPARENT, T.PAD_PAPER_CARD))
	var hover_sb := _box(T.CARD_BG, T.RADIUS_PAPER, T.ACCENT_DEEP, Vector2i(T.SPACE_L, T.SPACE_S))
	hover_sb.shadow_color = T.SHADOW_SOFT
	hover_sb.shadow_size = T.SPACE_S
	hover_sb.shadow_offset = Vector2(0, T.SPACE_XXS)
	_panel(th, &"HoverBox", "PanelContainer", hover_sb)
	_panel(th, &"DecisionRow", "PanelContainer", _box(T.AMBER_BG, T.RADIUS_S, T.ACCENT_DEEP, T.PAD_PAPER_CARD))
	_panel(th, &"GoalStrip", "PanelContainer", _box(T.AMBER_BG, T.RADIUS_PAPER, T.ACCENT_DEEP, Vector2i(T.SPACE_XL, 0)))
	_panel(th, &"QuarterHeaderBand", "PanelContainer", _sides_box(T.AMBER_BG, T.RADIUS_NONE, [0, 0, 0, T.BORDER_HAIRLINE], T.ACCENT_DEEP, Vector2i(T.SPACE_M, T.SPACE_M)))
	_lbl(th, &"DataMono", mono_sb, T.SIZE_DATA, T.INK)
	_lbl(th, &"DataMonoLarge", mono_sb, T.SIZE_ED_MODAL, T.INK)
	_lbl(th, &"DataMonoHero", mono_sb, T.SIZE_ED_HEADLINE, T.INK)
	_lbl(th, &"TickerLabel", serif_it, T.SIZE_BODY, T.INK)
	_lbl(th, &"AreaName", mono_sb, T.SIZE_BODY, T.INK)
	_lbl(th, &"RowMetaStrong", mono_sb, T.SIZE_SMALL, T.INK)   # the named part of an effect line beside RowMeta
	_lbl(th, &"AreaSentence", sans_reg, T.SIZE_DATA, T.INK_MUTED)
	_lbl(th, &"LeadQuote", serif_it, T.SIZE_LEAD, T.INK)
	# Boxed labels. The host sets the minimum size and centres the text; AttentionBadge
	# stays neutral here and turns red through the helpers.
	var banner := _box(T.INK_DIM, T.RADIUS_S, Color.TRANSPARENT, T.PAD_STAMP)
	banner.corner_radius_top_left = 0      # the flag's pole stands on the left
	banner.corner_radius_bottom_left = 0
	for boxed in [
		[&"Stamp", T.SIZE_META, T.INK_MUTED, _box(T.SURFACE_FRAME, T.RADIUS_S, T.CARD_BORDER, T.PAD_STAMP)],
		[&"StampAmber", T.SIZE_META, T.ACCENT_DEEP, _box(T.AMBER_BG, T.RADIUS_S, T.ACCENT_DEEP, T.PAD_STAMP)],
		[&"StampGrey", T.SIZE_MICRO, T.CARD_BG, banner],
		[&"AttentionBadge", T.SIZE_SMALL, T.INK_MUTED, _box(T.SURFACE_FRAME, T.RADIUS_S, T.CARD_BORDER, Vector2i.ZERO)],
		[&"DataMonoBox", T.SIZE_SMALL, T.INK, _box(T.SURFACE_FRAME, T.RADIUS_S, T.CARD_BORDER, Vector2i(T.SPACE_XS, 0))],
		[&"AvatarChip", T.SIZE_MICRO, T.INK_MUTED, _box(T.BG_PANEL, T.RADIUS_S, T.BORDER_HOVER, Vector2i.ZERO)],
		[&"AvatarChipMe", T.SIZE_MICRO, T.ACCENT_DEEP, _box(T.AMBER_BG, T.RADIUS_S, T.ACCENT_DEEP, Vector2i.ZERO)],
	]:
		_lbl(th, boxed[0], mono_sb, boxed[1], boxed[2])
		th.set_stylebox("normal", boxed[0], boxed[3])
	_commit_button(th, &"PrimaryButton", false)
	_commit_button(th, &"PrimaryButtonSmall", false, T.PAD_BTN)
	th.set_font_size("font_size", &"PrimaryButtonSmall", T.SIZE_META)
	# InkButton: a card's square + → buttons and its remove word.
	th.set_type_variation(&"InkButton", &"Button")
	var ink_hot := _box(T.CARD_BG, T.RADIUS_S, T.ACCENT_DEEP, T.PAD_BTN_XS)
	_states(th, &"InkButton", {
		"normal": _box(T.CARD_BG, T.RADIUS_S, T.CARD_BORDER, T.PAD_BTN_XS),
		"hover": ink_hot,
		"pressed": ink_hot,
		"disabled": _box(Color.TRANSPARENT, T.RADIUS_S, T.BORDER_DISABLED, T.PAD_BTN_XS),
		"focus": _no_focus(),
	})
	th.set_font("font", &"InkButton", mono_sb)
	th.set_font_size("font_size", &"InkButton", T.SIZE_SMALL)
	th.set_color("font_color", &"InkButton", T.INK_MUTED)
	th.set_color("font_hover_color", &"InkButton", T.INK)
	th.set_color("font_pressed_color", &"InkButton", T.INK)
	th.set_color("font_disabled_color", &"InkButton", T.INK_FAINT)

	# ========================================================================
	# CHROME AİLESİ — koyu kabuk register'ı. Yasal yüzey listesi CLAUDE.md Chrome
	# kuralında; gövdeyle birlikte değişen her renk *_CHROME ikizinden okunur.
	# ========================================================================
	# ChromeTabButton(+Active): TabButton'ın birebir aynısı; Satış sekmesinin bant tavanı
	# seçicisi okur.
	_tab_button(th, &"ChromeTabButton", false)
	_tab_button(th, &"ChromeTabButtonActive", true)

	# ---- RichTextLabel variations ----
	# Godot 4's keys are "italics_font"/"bold_italics_font" (with the s); "italic_font"
	# is silently ignored and *italic* spans fall back to the engine default.
	th.set_type_variation(&"BodyRich", &"RichTextLabel")
	_rich_fonts(th, &"BodyRich", serif_reg, serif_sb, serif_it, mono_reg, T.SIZE_LEAD)
	th.set_color("default_color", &"BodyRich", T.INK)

	th.set_type_variation(&"NewsRich", &"RichTextLabel")
	th.set_font("normal_font", &"NewsRich", mono_reg)
	th.set_font_size("normal_font_size", &"NewsRich", T.SIZE_SMALL)
	th.set_color("default_color", &"NewsRich", T.CREAM_DIM)

	# ---- ProgressBar variation (amber fill) ----
	th.set_type_variation(&"BuildProgress", &"ProgressBar")
	th.set_stylebox("background", &"BuildProgress", _box(T.SURFACE_SUNKEN, T.RADIUS_S))
	th.set_stylebox("fill", &"BuildProgress", _box(T.ACCENT, T.RADIUS_S))

	# ---- HSlider variation. VolumeSlider: a visible neutral groove with an amber fill
	# up to the grabber. ----
	var grabber: Texture2D = load("res://assets/icons/slider_grabber.svg")
	th.set_type_variation(&"VolumeSlider", &"HSlider")
	_states(th, &"VolumeSlider", {
		"slider": _box(T.CARD_BORDER, T.RADIUS_S, Color.TRANSPARENT, Vector2i(-1, 2)),
		"grabber_area": _box(T.ACCENT, T.RADIUS_S, Color.TRANSPARENT, Vector2i(-1, 2)),
		"grabber_area_highlight": _box(T.ACCENT_HOVER, T.RADIUS_S, Color.TRANSPARENT, Vector2i(-1, 2)),
	})
	th.set_constant("center_grabber", &"VolumeSlider", 1)
	for key in ["grabber", "grabber_highlight", "grabber_disabled"]:
		th.set_icon(key, &"VolumeSlider", grabber)

	# ---- SettingsSwitch: CheckButton stripped to its on/off pill graphics ----
	var sw_on: Texture2D = load("res://assets/icons/switch_on.svg")
	var sw_off: Texture2D = load("res://assets/icons/switch_off.svg")
	th.set_type_variation(&"SettingsSwitch", &"CheckButton")
	for sb in ["normal", "hover", "pressed", "focus", "disabled", "hover_pressed"]:
		th.set_stylebox(sb, &"SettingsSwitch", StyleBoxEmpty.new())
	th.set_icon("checked", &"SettingsSwitch", sw_on)
	th.set_icon("checked_disabled", &"SettingsSwitch", sw_on)
	th.set_icon("unchecked", &"SettingsSwitch", sw_off)
	th.set_icon("unchecked_disabled", &"SettingsSwitch", sw_off)
	th.set_color("font_color", &"SettingsSwitch", T.INK)

	# ---- SettingsDropdown / SettingsPopup: the settings OptionButton and the PopupMenu
	# it opens (a separate Window with its own theme type — the button's stylebox never
	# reaches it). A dropdown reads as a FIELD you pick a value in, so it takes the
	# LineEdit grammar (input fill + hairline, amber on focus), not the Button's. ----
	th.set_type_variation(&"SettingsDropdown", &"OptionButton")
	_states(th, &"SettingsDropdown", {
		"normal": _box(T.SURFACE_INPUT, T.RADIUS_M, T.CARD_BORDER, T.PAD_INPUT),
		"hover": _box(T.SURFACE_INPUT, T.RADIUS_M, T.ACCENT_DEEP, T.PAD_INPUT),
		"pressed": _box(T.SURFACE_PRESSED, T.RADIUS_M, T.ACCENT_DEEP, T.PAD_INPUT),
		"focus": _box(Color.TRANSPARENT, T.RADIUS_M, T.ACCENT_DEEP, T.PAD_INPUT),
		"disabled": _box(T.SURFACE_DISABLED, T.RADIUS_M, T.BORDER_DISABLED, T.PAD_INPUT),
	})
	th.set_font_size("font_size", &"SettingsDropdown", T.SIZE_BODY)
	for key in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color",
			"font_hover_pressed_color"]:
		th.set_color(key, &"SettingsDropdown", T.INK)
	th.set_color("font_disabled_color", &"SettingsDropdown", T.INK_DIM)
	# modulate_arrow tints the engine's arrow icon with the font colour; without it the
	# arrow keeps the engine's default tint and does not follow the field's ink.
	th.set_constant("modulate_arrow", &"SettingsDropdown", 1)
	th.set_constant("arrow_margin", &"SettingsDropdown", T.SPACE_M)
	th.set_constant("h_separation", &"SettingsDropdown", T.SPACE_XS)

	# Assign in code: `option.get_popup().theme_type_variation = &"SettingsPopup"`.
	th.set_type_variation(&"SettingsPopup", &"PopupMenu")
	th.set_stylebox("panel", &"SettingsPopup", _box(T.CARD_BG, T.RADIUS_M, T.CARD_BORDER, Vector2i(T.SPACE_XS, T.SPACE_XS)))
	th.set_stylebox("hover", &"SettingsPopup", _box(T.SURFACE_HOVER, T.RADIUS_S))
	th.set_stylebox("separator", &"SettingsPopup", _rule(T.DIVIDER_LIGHT, false))
	th.set_font_size("font_size", &"SettingsPopup", T.SIZE_BODY)
	th.set_color("font_color", &"SettingsPopup", T.INK)
	th.set_color("font_hover_color", &"SettingsPopup", T.INK)
	th.set_color("font_accelerator_color", &"SettingsPopup", T.INK_DIM)
	th.set_color("font_separator_color", &"SettingsPopup", T.INK_DIM)
	# A row the readability floor has locked out must READ as unavailable.
	th.set_color("font_disabled_color", &"SettingsPopup", T.INK_DIM)
	th.set_constant("v_separation", &"SettingsPopup", T.SPACE_XS)
	th.set_constant("h_separation", &"SettingsPopup", T.SPACE_M)
	th.set_constant("item_start_padding", &"SettingsPopup", T.SPACE_S)
	th.set_constant("item_end_padding", &"SettingsPopup", T.SPACE_S)

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
	for pinned in [&"Button", &"CommitButton", &"LineEdit", &"DialogueInput", &"SettingsSwitch"]:
		th.set_font_size("font_size", pinned, T.SIZE_DATA)
	for rail in [&"TabButton", &"TabButtonActive", &"ChromeTabButton", &"ChromeTabButtonActive"]:
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
	quit(0)


# --- helpers ----------------------------------------------------------------

func _mkfont(ttf_path: String, fallback: FontFile, vname: String, glyph_spacing: float = 0.0) -> FontVariation:
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


## Flat box: fill, radius, optional uniform border (colour + width) and content
## margins (h, v). A transparent border colour means "no border".
func _box(bg: Color, radius: int, border: Color = Color.TRANSPARENT, pad: Vector2i = NO_PAD,
		width: int = T.BORDER_HAIRLINE) -> StyleBoxFlat:
	var sb := _sides_box(bg, radius, [], border, pad)
	if border != Color.TRANSPARENT:
		sb.set_border_width_all(width)
		sb.border_color = border
	return sb


## Flat box with per-side border widths [L, R, T, B] in one colour. The widths are
## kept even when the colour is transparent: they still reserve the content margin.
func _sides_box(bg: Color, radius: int, sides: Array, color: Color, pad: Vector2i = NO_PAD) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.set_corner_radius_all(radius)
	if sides.size() == 4:
		sb.border_width_left = sides[0]
		sb.border_width_right = sides[1]
		sb.border_width_top = sides[2]
		sb.border_width_bottom = sides[3]
		sb.border_color = color
	sb.content_margin_left = pad.x
	sb.content_margin_right = pad.x
	sb.content_margin_top = pad.y
	sb.content_margin_bottom = pad.y
	return sb


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
		normal = _sides_box(T.TAB_ACTIVE_BG, T.RADIUS_WINDOW, [T.BORDER_ACCENT, 0, 0, 0], T.ACCENT_DEEP, T.PAD_BTN_XS)
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
