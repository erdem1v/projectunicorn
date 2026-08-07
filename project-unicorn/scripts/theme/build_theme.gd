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
const FONT_MONO_SB := "res://assets/fonts/mono/JetBrainsMono-SemiBold.ttf"
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
	# mono_sb (Step 11): vurgu ağırlıklı mono — bugün tek kullanıcısı Chrome ailesinin
	# inert ChromeBadgeLabel'ı; yüz hazır, benimseme kararı ayrı ve gate'li.
	var mono_sb := _mkfont(FONT_MONO_SB, symbols, "mono_sb", 0.6)

	var th := Theme.new()
	th.set_default_font(sans_reg)
	# Stale-artifact guard: main.gd compares this against UiTokens.THEME_STAMP at boot
	# (debug builds) and warns when the .tres predates a token edit. Cheap insurance —
	# the generator is run by hand, so nothing else notices a missed regeneration.
	th.set_constant(&"stamp", &"UiTokensStamp", T.THEME_STAMP)
	# default_font_size is set with the other base-type defaults further down, after
	# the variations that must pin their own size have been declared.

	# ---- Label variations ----
	# EVERY size here is a UiTokens scale step. That is the rule the type scale exists
	# to enforce: a variation picks a step, it never invents a number. If a new
	# variation seems to need a size that is not a step, the answer is a different
	# step — not a literal. (Verified by Gate C: zero bare integers in this file.)
	_lbl(th, &"TitleSerif", serif_sb, T.SIZE_DISPLAY, T.INK)
	_lbl(th, &"NameSerif", serif_sb, T.SIZE_LEAD, T.INK)
	_lbl(th, &"BodySerif", serif_reg, T.SIZE_BODY, T.INK)
	_lbl(th, &"QuoteSerif", serif_it, T.SIZE_BODY, T.INK_MUTED)
	_lbl(th, &"CaptionMuted", serif_reg, T.SIZE_SMALL, T.INK_MUTED)
	_lbl(th, &"SectionLabel", mono_label, T.SIZE_SMALL, T.INK_DIM)
	# MicroLabel: SectionLabel'in MICRO-adım kardeşi. BuildHUD'un 6 mini-faz başlığı
	# el yapımı font_size=8 taşıyordu (skala dışı) — süpürme B3 onları buraya topladı;
	# 8→9 (+1px) Erdem onayıyla sanksiyonlu tek görünür harekettir.
	_lbl(th, &"MicroLabel", mono_label, T.SIZE_MICRO, T.INK_DIM)
	_lbl(th, &"MetricCaption", mono_label, T.SIZE_MICRO, T.CREAM_DIM)
	_lbl(th, &"MetricValue", sans_sb, T.SIZE_LEAD, T.CREAM)
	_lbl(th, &"MetricDelta", mono_reg, T.SIZE_SMALL, T.CREAM_DIM)
	_lbl(th, &"MetricUnit", mono_reg, T.SIZE_MICRO, T.CREAM_DIM)
	_lbl(th, &"TabLabel", sans_reg, T.SIZE_SMALL, T.INK_DIM)
	_lbl(th, &"BadgeLabel", mono_reg, T.SIZE_MICRO, T.INK)
	_lbl(th, &"ChoiceLabel", sans_reg, T.SIZE_LEAD, T.INK)
	_lbl(th, &"ChoiceLabelStrong", sans_sb, T.SIZE_LEAD, T.INK)
	_lbl(th, &"FeedDay", mono_reg, T.SIZE_SMALL, T.INK_MUTED)
	_lbl(th, &"ChromeSerif", serif_reg, T.SIZE_BODY, T.CREAM)
	_lbl(th, &"ChromeLabel", mono_label, T.SIZE_MICRO, T.CREAM_DIM)
	_lbl(th, &"ChromeValue", sans_sb, T.SIZE_BODY, T.CREAM)
	_lbl(th, &"RowName", sans_sb, T.SIZE_BODY, T.INK)
	_lbl(th, &"RowMeta", mono_reg, T.SIZE_SMALL, T.INK_MUTED)
	_lbl(th, &"AvatarInitial", sans_sb, T.SIZE_BODY, T.CREAM)
	_lbl(th, &"MetricValueInk", sans_sb, T.SIZE_TITLE, T.INK)
	_lbl(th, &"MetricCaptionInk", mono_label, T.SIZE_MICRO, T.INK_DIM)

	# ---- Cinematic dialogue register (Spec 5): text on the DARK charcoal column.
	# Cream tones per the context rule; the light INK-based QuoteSerif/ChoiceLabel
	# are unreadable here, so these are their dark-surface counterparts. ----
	_lbl(th, &"DialogueName", sans_sb, T.SIZE_LEAD, T.CREAM)  # counterpart name (uppercased in code)
	_lbl(th, &"DialogueRole", mono_label, T.SIZE_SMALL, T.CREAM_DIM)    # role line under the name
	_lbl(th, &"DialogueTag", mono_label, T.SIZE_MICRO, T.CREAM_DIM)  # speaker-tag chip "ANCHOR — CANLI"
	_lbl(th, &"QuoteSerifCream", serif_it, T.SIZE_LEAD, T.CREAM)     # spoken line (light QuoteSerif is INK)
	_lbl(th, &"DialogueMonologue", serif_it, T.SIZE_LEAD, T.CREAM_DIM) # interior voice
	_lbl(th, &"DialogueChoiceLabel", sans_reg, T.SIZE_LEAD, T.CREAM)   # choice text
	_lbl(th, &"DialogueOdds", mono_reg, T.SIZE_SMALL, T.CREAM_DIM)   # odds / caption line
	_lbl(th, &"DialogueNumber", mono_reg, T.SIZE_SMALL, T.CREAM_DIM) # choice number inside its ring chip
	_lbl(th, &"ZoneLabel", mono_label, T.SIZE_MICRO, T.CREAM_DIM)    # İKNA zones SOĞUK/ILIK/KAZANILDI
	_lbl(th, &"ConvictionValue", mono_reg, T.SIZE_BODY, T.CREAM)       # İKNA numeric readout
	_lbl(th, &"StatStripLabel", mono_reg, T.SIZE_SMALL, T.CREAM)     # bottom-left stat band

	# ---- Dark-register onboarding (3-page threshold ceremony) ----
	_lbl(th, &"TitleSerifCream", serif_sb, T.SIZE_ED_CEREMONY, T.CREAM)  # page title on dark ("Karakter")
	_lbl(th, &"SubtitleSerifCream", serif_it, T.SIZE_BODY, T.CREAM_DIM)  # italic page/section subtitle on dark

	# ---- Newspaper ending register ("Ekonomi Postası"): INK text on the cream PAPER
	# (a LIGHT surface — INK/INK_MUTED/INK_DIM, not the CREAM chrome tones). Masthead is
	# a large muted grey; the headline is the darkest element (mockup contrast). ----
	_lbl(th, &"MastheadSerif", serif_sb, T.SIZE_ED_MASTHEAD, T.INK_MUTED)  # "EKONOMİ POSTASI" masthead
	_lbl(th, &"NewsHeadlineSerif", serif_sb, T.SIZE_ED_HEADLINE, T.INK)    # story headline (darkest)
	_lbl(th, &"NewsDeckSerif", serif_it, T.SIZE_LEAD, T.INK_MUTED)         # italic subhead / quoted deck
	_lbl(th, &"NewsCaptionSerif", serif_it, T.SIZE_SMALL, T.INK_DIM)       # engraving caption (italic, dim)
	_lbl(th, &"NewsMeta", mono_label, T.SIZE_MICRO, T.INK_DIM)             # date / edition caps
	_lbl(th, &"NewsBodySerif", serif_reg, T.SIZE_BODY, T.INK)              # ledger-line / notice body prose
	_lbl(th, &"NewsStatSerif", serif_sb, T.SIZE_ED_FIGURE, T.INK)          # stat-row figures ("$4.0M")

	# ---- Panel variations ----
	_panel(th, &"TopBarPanel", "Panel", _box(T.BG_TOPBAR, 0, Color.TRANSPARENT, T.RADIUS_NONE, [0,0,0,T.BORDER_HAIRLINE], T.SEPARATOR))
	_panel(th, &"SidePanel", "Panel", _box(T.BG_PANEL, 0, Color.TRANSPARENT, T.RADIUS_NONE, [T.BORDER_HAIRLINE,T.BORDER_HAIRLINE,0,0], T.DIVIDER_LIGHT))
	_panel(th, &"NewsPanel", "Panel", _box(T.BG_NEWS, 0, Color.TRANSPARENT, T.RADIUS_NONE, [0,0,T.BORDER_HAIRLINE,0], T.SEPARATOR))
	_panel(th, &"ViewportPanel", "Panel", _box(T.BG_BODY, 0, Color.TRANSPARENT, T.RADIUS_NONE))
	_panel(th, &"ModalPanel", "Panel", _box(T.CARD_BG, T.BORDER_HAIRLINE, T.CARD_BORDER, T.RADIUS_L))
	_panel(th, &"ArtPanel", "Panel", _box(T.BG_ART, 0, Color.TRANSPARENT, T.RADIUS_S))
	_panel(th, &"PhaseDotActive", "Panel", _box(T.ACCENT, 0, Color.TRANSPARENT, T.RADIUS_XS))
	_panel(th, &"PhaseDotDim", "Panel", _box(T.DOT_IDLE, 0, Color.TRANSPARENT, T.RADIUS_XS))
	_panel(th, &"SelectedBorder", "Panel", _box(Color.TRANSPARENT, T.BORDER_FOCUS, T.ACCENT, T.RADIUS_M))
	_panel(th, &"TabBadge", "Panel", _box(T.ACCENT, 0, Color.TRANSPARENT, T.RADIUS_XL))
	# RADIUS_PILL (was a hand-tuned 18): StyleBoxFlat clamps to half the box, so the
	# avatar is now circular at ANY diameter — which retires ui_factory.make_avatar's
	# old "keep the diameter at or below 36" caveat. Zero delta at today's sizes.
	_panel(th, &"Avatar", "Panel", _box(T.BG_AVATAR, 0, Color.TRANSPARENT, T.RADIUS_PILL))
	_panel(th, &"CapBar", "Panel", _box(T.BG_AVATAR, 0, Color.TRANSPARENT, T.RADIUS_XS))

	# ---- PanelContainer variations (auto content margins) ----
	_panel(th, &"CardPanel", "PanelContainer", _box(T.CARD_BG, T.BORDER_HAIRLINE, T.CARD_BORDER, T.RADIUS_M, [1,1,1,1], T.CARD_BORDER, T.PAD_CARD.x, T.PAD_CARD.y))
	# CardCta: "+ Yeni Ürün" davet kartı (Rev3 Portföy). Şeffaf zemin + 1px amber
	# çerçeve — mockup'taki kesikli CTA kenarını StyleBoxFlat çizemez, düz amber
	# en yakın karşılık (plan Step 9 kararı).
	_panel(th, &"CardCta", "PanelContainer", _box(Color.TRANSPARENT, T.BORDER_HAIRLINE, T.ACCENT, T.RADIUS_M, [], Color.TRANSPARENT, T.PAD_CARD.x, T.PAD_CARD.y))
	_panel(th, &"CardPanelTight", "PanelContainer", _box(T.CARD_BG, T.BORDER_HAIRLINE, T.CARD_BORDER, T.RADIUS_M, [1,1,1,1], T.CARD_BORDER, T.PAD_CARD_TIGHT.x, T.PAD_CARD_TIGHT.y))
	_panel(th, &"CardAttention", "PanelContainer", _box(T.CARD_ATTENTION_BG, T.BORDER_HAIRLINE, T.CARD_ATTENTION_BORDER, T.RADIUS_M, [1,1,1,1], T.CARD_ATTENTION_BORDER, T.PAD_CARD.x, T.PAD_CARD.y))
	_panel(th, &"ChoiceCard", "PanelContainer", _box(T.CARD_BG, T.BORDER_HAIRLINE, T.CARD_BORDER, T.RADIUS_M, [1,1,1,1], T.CARD_BORDER, T.PAD_CHOICE.x, T.PAD_CHOICE.y))
	# ChoiceCardHover/Mentor: event-modal choice states — amber border on hover
	# (dialogue_choice_card swap precedent) and the MENTOR TAVSİYESİ endorsed card.
	# Mentor stays shadow-free: the tab chip must overlap its top edge cleanly.
	_panel(th, &"ChoiceCardHover", "PanelContainer", _box(T.CARD_BG, T.BORDER_HAIRLINE, T.ACCENT, T.RADIUS_M, [1,1,1,1], T.ACCENT, T.PAD_CHOICE.x, T.PAD_CHOICE.y))
	_panel(th, &"ChoiceCardMentor", "PanelContainer", _box(T.CARD_BG, T.BORDER_HAIRLINE, T.ACCENT, T.RADIUS_M, [1,1,1,1], T.ACCENT, T.PAD_CHOICE.x, T.PAD_CHOICE.y))
	_panel(th, &"HeaderBand", "PanelContainer", _box(T.ACCENT, 0, Color.TRANSPARENT, T.RADIUS_M, [1,1,1,1], Color.TRANSPARENT, T.PAD_BAND.x, T.PAD_BAND.y))
	# CardFloating: gövde üstünde YÜZEN kart (BuildHUD overlay'i). CardPanelTight'ın
	# 0.98-alfa + yumuşak-gölge kardeşi; BuildHUDPanel.tscn'in el yapımı SubResource'u
	# buraya emekli edildi (süpürme B5) — shadow sayıları PaperPanel emsalini izler.
	var floating_sb := _box(T.CARD_FLOATING_BG, T.BORDER_HAIRLINE, T.CARD_BORDER, T.RADIUS_L, [], Color.TRANSPARENT, T.PAD_CARD_TIGHT.x, T.PAD_CARD_TIGHT.y)
	floating_sb.shadow_color = T.SHADOW_SOFT
	floating_sb.shadow_size = 6
	_panel(th, &"CardFloating", "PanelContainer", floating_sb)

	# ---- Cinematic dialogue register (Spec 5): DARK panels ----
	# Column = floating semi-opaque charcoal (art shows through); Card = solid
	# charcoal for the Frank popup; QuoteBox carries the amber left-edge bar;
	# DialogueChoice(+Hover) swap on mouse-over; NumberChip is the choice ring.
	_panel(th, &"DialogueColumn", "Panel", _box(T.DIALOGUE_COLUMN_BG, 0, Color.TRANSPARENT, T.RADIUS_XXL))
	# RADIUS_CARD_LG / RADIUS_PORTRAIT are the two DOCUMENTED shape exceptions: snapping
	# them to the scale is visible motion (-4 / +2), an aesthetic call the polish wave owns.
	_panel(th, &"DialogueCard", "Panel", _box(T.DIALOGUE_BG, T.BORDER_HAIRLINE, T.DIALOGUE_CARD_BORDER, T.RADIUS_CARD_LG))
	_panel(th, &"PortraitFrame", "PanelContainer", _box(T.PORTRAIT_FRAME, 0, Color.TRANSPARENT, T.RADIUS_PORTRAIT, [], Color.TRANSPARENT, T.PAD_FRAME.x, T.PAD_FRAME.y))
	_panel(th, &"QuoteBox", "PanelContainer", _box(T.DIALOGUE_CARD_BG, 0, Color.TRANSPARENT, T.RADIUS_M, [T.BORDER_ACCENT,0,0,0], T.ACCENT, T.PAD_ROW.x, T.PAD_ROW.y))
	_panel(th, &"DialogueChoice", "PanelContainer", _box(T.DIALOGUE_CARD_BG, T.BORDER_HAIRLINE, T.DIALOGUE_CARD_BORDER, T.RADIUS_XL, [], Color.TRANSPARENT, T.PAD_ROW.x, T.PAD_ROW.y))
	_panel(th, &"DialogueChoiceHover", "PanelContainer", _box(T.DIALOGUE_CARD_BG, T.BORDER_HAIRLINE, T.ACCENT, T.RADIUS_XL, [], Color.TRANSPARENT, T.PAD_ROW.x, T.PAD_ROW.y))
	# RADIUS_PILL (was 11 on a ≤22px chip) — same clamp story as Avatar, zero delta.
	_panel(th, &"NumberChip", "Panel", _box(Color.TRANSPARENT, T.BORDER_HAIRLINE, T.CREAM_DIM, T.RADIUS_PILL))
	_panel(th, &"StatStrip", "PanelContainer", _box(T.STAT_STRIP_BG, 0, Color.TRANSPARENT, T.RADIUS_M, [], Color.TRANSPARENT, T.PAD_STRIP.x, T.PAD_STRIP.y))

	# ---- Dark-register onboarding panels: portrait grid cells (hairline vs 2px
	# amber ring when selected) ----
	_panel(th, &"PortraitCell", "PanelContainer", _box(T.DIALOGUE_CARD_BG, T.BORDER_HAIRLINE, T.DIALOGUE_CARD_BORDER, T.RADIUS_L, [], Color.TRANSPARENT, T.PAD_CELL.x, T.PAD_CELL.y))
	_panel(th, &"PortraitCellSelected", "PanelContainer", _box(T.DIALOGUE_CARD_BG, T.BORDER_FOCUS, T.ACCENT, T.RADIUS_L, [], Color.TRANSPARENT, T.PAD_CELL.x, T.PAD_CELL.y))

	# ---- Newspaper ending panels ----
	# PaperPanel: the cream page — a floating single sheet on the dark screen. Right/bottom
	# PAPER_EDGE border reads as the second-page edge from the mockup; a soft drop shadow
	# lifts it off DIALOGUE_BG. Generous inner margins (masthead breathing room).
	var paper_sb := _box(T.PAPER_BG, 0, Color.TRANSPARENT, T.RADIUS_XS, [0, T.BORDER_FOCUS, 0, T.BORDER_FOCUS], T.PAPER_EDGE, T.PAD_SHEET.x, T.PAD_SHEET.y)
	paper_sb.shadow_color = T.PAPER_SHADOW
	paper_sb.shadow_size = 12
	paper_sb.shadow_offset = Vector2(0, 5)
	_panel(th, &"PaperPanel", "PanelContainer", paper_sb)
	# PaperModal: the event-modal decision card — same paper register as PaperPanel
	# but modal-scaled inner margins (780×660 card, not the full ending sheet).
	var paper_modal_sb := _box(T.PAPER_BG, 0, Color.TRANSPARENT, T.RADIUS_XS, [0, T.BORDER_FOCUS, 0, T.BORDER_FOCUS], T.PAPER_EDGE, T.PAD_PAGE.x, T.PAD_PAGE.y)
	paper_modal_sb.shadow_color = T.PAPER_SHADOW
	paper_modal_sb.shadow_size = 12
	paper_modal_sb.shadow_offset = Vector2(0, 5)
	_panel(th, &"PaperModal", "PanelContainer", paper_modal_sb)
	# RailPanel: the dark meta rail — same charcoal as the screen, a left hairline divides it.
	_panel(th, &"RailPanel", "PanelContainer", _box(T.DIALOGUE_BG, 0, Color.TRANSPARENT, T.RADIUS_NONE, [T.BORDER_HAIRLINE, 0, 0, 0], T.SEPARATOR, T.PAD_RAIL.x, T.PAD_RAIL.y))
	# RailCard: Coming-Soon Tier2/Tier3 cards on the rail (a step lighter, hairline border).
	_panel(th, &"RailCard", "PanelContainer", _box(T.DIALOGUE_CARD_BG, T.BORDER_HAIRLINE, T.DIALOGUE_CARD_BORDER, T.RADIUS_M, [1,1,1,1], T.DIALOGUE_CARD_BORDER, T.PAD_CARD_RAIL.x, T.PAD_CARD_RAIL.y))
	# EngravingFrame: the illustration frame on the PAPER (light-surface counterpart to
	# PortraitFrame). Muted tan fill + thin tan border = neutral empty frame until the PNG lands.
	_panel(th, &"EngravingFrame", "PanelContainer", _box(T.SURFACE_FRAME, T.BORDER_HAIRLINE, T.CARD_BORDER, T.RADIUS_XS, [1,1,1,1], T.CARD_BORDER, 0, 0))

	# ---- Button variations ----
	_tab_button(th, &"TabButton", false)
	_tab_button(th, &"TabButtonActive", true)
	_speed_button(th, &"SpeedButton", false)
	_speed_button(th, &"SpeedButtonActive", true)
	_commit_button(th)

	# ---- DialogueGhost: quiet cream text button on the dark register ("Toplantıdan
	# çekil" withdraw affordance). Transparent until hovered. ----
	th.set_type_variation(&"DialogueGhost", &"Button")
	th.set_stylebox("normal", &"DialogueGhost", _box(Color.TRANSPARENT, 0, Color.TRANSPARENT, T.RADIUS_M, [], Color.TRANSPARENT, T.PAD_BTN_GHOST.x, T.PAD_BTN_GHOST.y))
	th.set_stylebox("hover", &"DialogueGhost", _box(T.VEIL_SOFT, 0, Color.TRANSPARENT, T.RADIUS_M, [], Color.TRANSPARENT, T.PAD_BTN_GHOST.x, T.PAD_BTN_GHOST.y))
	th.set_stylebox("pressed", &"DialogueGhost", _box(T.VEIL_FAINT, 0, Color.TRANSPARENT, T.RADIUS_M, [], Color.TRANSPARENT, T.PAD_BTN_GHOST.x, T.PAD_BTN_GHOST.y))
	th.set_stylebox("focus", &"DialogueGhost", _box(Color.TRANSPARENT, 0, Color.TRANSPARENT, T.RADIUS_NONE))
	th.set_font_size("font_size", &"DialogueGhost", T.SIZE_SMALL)
	th.set_color("font_color", &"DialogueGhost", T.CREAM_DIM)
	th.set_color("font_hover_color", &"DialogueGhost", T.CREAM)
	th.set_color("font_pressed_color", &"DialogueGhost", T.CREAM_DIM)

	# ========================================================================
	# CHROME AİLESİ (Step 10; ODA rework 2026-08-06'da YÜZEYE BİNDİ) — koyu kabuk
	# register'ı. Artık tanımlı-VE-yaşayan; yasal yüzey listesi CLAUDE.md Chrome
	# kuralında (TopBar · MonthSummary · LeftTabs rayı · TabPageChrome şeridi ·
	# OdaView koyu bilgi yüzeyleri · tooltip kabuğu). Desenler kabuğun elle
	# taşıdıklarından türetildi: SpeedButton'ın VEIL merdiveni, UiFactory çipinin
	# PAD_CHIP'i, kabuk hairline'ının SEPARATOR'u.
	# ========================================================================
	# ChromeButton: koyu kabukta standart-boy ikincil buton (SpeedButton'ın
	# PAD_BTN'li genellemesi). Metin boyutu base Button pin'inden (LEAD) miras.
	th.set_type_variation(&"ChromeButton", &"Button")
	th.set_stylebox("normal", &"ChromeButton", _box(T.VEIL_FAINT, 0, Color.TRANSPARENT, T.RADIUS_S, [], Color.TRANSPARENT, T.PAD_BTN.x, T.PAD_BTN.y))
	th.set_stylebox("hover", &"ChromeButton", _box(T.VEIL_STRONG, 0, Color.TRANSPARENT, T.RADIUS_S, [], Color.TRANSPARENT, T.PAD_BTN.x, T.PAD_BTN.y))
	th.set_stylebox("pressed", &"ChromeButton", _box(T.VEIL_SOFT, 0, Color.TRANSPARENT, T.RADIUS_S, [], Color.TRANSPARENT, T.PAD_BTN.x, T.PAD_BTN.y))
	th.set_stylebox("disabled", &"ChromeButton", _box(T.VEIL_FAINT, 0, Color.TRANSPARENT, T.RADIUS_S, [], Color.TRANSPARENT, T.PAD_BTN.x, T.PAD_BTN.y))
	th.set_stylebox("focus", &"ChromeButton", _box(Color.TRANSPARENT, 0, Color.TRANSPARENT, T.RADIUS_NONE))
	th.set_color("font_color", &"ChromeButton", T.CREAM)
	th.set_color("font_hover_color", &"ChromeButton", T.CREAM)
	th.set_color("font_pressed_color", &"ChromeButton", T.CREAM)
	th.set_color("font_disabled_color", &"ChromeButton", T.CREAM_DIM_DISABLED)
	# ChromeChip: koyu zemin çipi (açık gövdenin UiFactory çipinin kabuk karşılığı).
	_panel(th, &"ChromeChip", "PanelContainer", _box(T.VEIL_FAINT, 0, Color.TRANSPARENT, T.RADIUS_S, [], Color.TRANSPARENT, T.PAD_CHIP.x, T.PAD_CHIP.y))
	# ChromeBadgeLabel: kabuk rozeti — mono_sb'nin ilk bağlandığı rol (Step 11).
	_lbl(th, &"ChromeBadgeLabel", mono_sb, T.SIZE_MICRO, T.CREAM)
	# ChromeSeparator: kabuk hairline'ı (base ayraçlar açık gövdenin DIVIDER_LIGHT'ı).
	var chrome_vrule := StyleBoxLine.new()
	chrome_vrule.color = T.SEPARATOR
	chrome_vrule.thickness = T.BORDER_HAIRLINE
	chrome_vrule.vertical = true
	th.set_type_variation(&"ChromeSeparator", &"VSeparator")
	th.set_stylebox("separator", &"ChromeSeparator", chrome_vrule)
	th.set_constant("separation", &"ChromeSeparator", T.SPACE_XS)

	# --- ODA rework kabul dalgası (2026-08-06): ray + sayfa-şeridi rolleri ---
	# ChromeRailPanel: sol sekme rayı — TopBar ile aynı kömür (üst bar + ray =
	# L-biçimli kabuk çerçevesi); sağ hairline rayı krem sayfadan/odadan ayırır.
	_panel(th, &"ChromeRailPanel", "Panel", _box(T.BG_TOPBAR, 0, Color.TRANSPARENT, T.RADIUS_NONE, [0,T.BORDER_HAIRLINE,0,0], T.SEPARATOR))
	# ChromeTabButton(+Active): ışık rayındaki TabButton çiftinin koyu ikizi —
	# aynı geometri (üst hairline / 3px amber sol bar), kabuk register renkleri.
	_chrome_tab_button(th, &"ChromeTabButton", false)
	_chrome_tab_button(th, &"ChromeTabButtonActive", true)
	# ChromeTabLabel: ray sekme etiketi (TabLabel'in koyu ikizi).
	_lbl(th, &"ChromeTabLabel", sans_reg, T.SIZE_SMALL, T.CREAM_DIM)
	# ChromeGhost: kabuk şeridinin sessiz mono butonu ("ODAYA DÖN ✕" kümesi).
	# DialogueGhost'un stylebox merdiveni + mono_label yüzü — sinematik register
	# değil kabuk grameri olduğu için ayrı ad taşır (Chrome yasallık grep'i anlamlı kalır).
	th.set_type_variation(&"ChromeGhost", &"Button")
	th.set_stylebox("normal", &"ChromeGhost", _box(Color.TRANSPARENT, 0, Color.TRANSPARENT, T.RADIUS_M, [], Color.TRANSPARENT, T.PAD_BTN_GHOST.x, T.PAD_BTN_GHOST.y))
	th.set_stylebox("hover", &"ChromeGhost", _box(T.VEIL_SOFT, 0, Color.TRANSPARENT, T.RADIUS_M, [], Color.TRANSPARENT, T.PAD_BTN_GHOST.x, T.PAD_BTN_GHOST.y))
	th.set_stylebox("pressed", &"ChromeGhost", _box(T.VEIL_FAINT, 0, Color.TRANSPARENT, T.RADIUS_M, [], Color.TRANSPARENT, T.PAD_BTN_GHOST.x, T.PAD_BTN_GHOST.y))
	th.set_stylebox("focus", &"ChromeGhost", _box(Color.TRANSPARENT, 0, Color.TRANSPARENT, T.RADIUS_NONE))
	th.set_font("font", &"ChromeGhost", mono_label)
	th.set_font_size("font_size", &"ChromeGhost", T.SIZE_SMALL)
	th.set_color("font_color", &"ChromeGhost", T.CREAM_DIM)
	th.set_color("font_hover_color", &"ChromeGhost", T.CREAM)
	th.set_color("font_pressed_color", &"ChromeGhost", T.CREAM_DIM)
	# ChromePageStrip: sekme sayfasının üstündeki ince koyu bant (TabPageChrome);
	# alt hairline krem sayfaya dikiş atar.
	_panel(th, &"ChromePageStrip", "PanelContainer", _box(T.BG_TOPBAR, 0, Color.TRANSPARENT, T.RADIUS_NONE, [0,0,0,T.BORDER_HAIRLINE], T.SEPARATOR, T.PAD_STRIP.x, T.PAD_STRIP.y))

	# ========================================================================
	# ODA REGISTER'I — oda sahnesi üstündeki motor-çizimi bilgi yüzeyleri (ODA
	# rework 2026-08-06). Kural 4 (kontrast yasası): sahne SANATI koyu/atmosferik,
	# OKUNAN her yüzey ya koyu ekran (monitör — Dialogue/Chrome tonları) ya açık
	# kâğıt/kart (pano kartları, masa kâğıtları — newsprint/ivory).
	# ========================================================================
	# ODA ekran tipografisi (D4 — kalite turu v2: cam ~440×270px'e ölçekli adımlar;
	# skala İÇİNDE yükselme, ham boyut değil). Başlık DISPLAY, grid değerleri TITLE,
	# caption'lar SMALL — cam dolu okunur, ölü siyah alan kalmaz.
	_lbl(th, &"OdaScreenTitle", serif_sb, T.SIZE_DISPLAY, T.CREAM)
	_lbl(th, &"OdaScreenValue", sans_sb, T.SIZE_TITLE, T.CREAM)
	_lbl(th, &"OdaScreenCaption", mono_label, T.SIZE_SMALL, T.CREAM_DIM)
	# OdaMonitorScreen: monitör camının içindeki bilgi paneli (bezel sanatta boyalı).
	# Gece parlaması artık stylebox gölgesi DEĞİL (D4: sarmalayıcı klibi yarım-glow
	# üretirdi) — ScreenGlow additive node'u oda_view'da, LampGlow kalıbıyla.
	_panel(th, &"OdaMonitorScreen", "PanelContainer", _box(T.DIALOGUE_BG, 0, Color.TRANSPARENT, T.RADIUS_XS, [], Color.TRANSPARENT, T.PAD_CARD.x, T.PAD_CARD.y))
	# OdaBoardCard(+Hover): panoya raptiyeli kart (hedef / pazar payı / tarihler) —
	# newsprint. Hover ikizi (D2/F2 — kalite turu v2): DOLGU ASLA PARLAMAZ, yalnız
	# kenar amber'e döner; content margin'ler BAYT-AYNI (margin farkı hover'da
	# metni zıplatır — ChoiceCardHover emsali).
	_panel(th, &"OdaBoardCard", "PanelContainer", _box(T.PAPER_BG, T.BORDER_HAIRLINE, T.CARD_BORDER, T.RADIUS_XS, [1,1,1,1], T.CARD_BORDER, T.PAD_CARD_TIGHT.x, T.PAD_CARD_TIGHT.y))
	_panel(th, &"OdaBoardCardHover", "PanelContainer", _box(T.PAPER_BG, T.BORDER_HAIRLINE, T.ACCENT, T.RADIUS_XS, [1,1,1,1], T.ACCENT, T.PAD_CARD_TIGHT.x, T.PAD_CARD_TIGHT.y))
	# OdaPostIt: panodaki istisna post-it'i (soluk amber, çerçevesiz).
	_panel(th, &"OdaPostIt", "PanelContainer", _box(T.AMBER_BG, 0, Color.TRANSPARENT, T.RADIUS_XS, [], Color.TRANSPARENT, T.PAD_CARD_TIGHT.x, T.PAD_CARD_TIGHT.y))
	# OdaPaperCard(+Hover): masadaki bekleyen-karar kâğıdı; masadan hafif kalkar
	# (yumuşak gölge), hover amber kenar + amber gölge (ChoiceCardHover grameri).
	var oda_paper := _box(T.CARD_BG, T.BORDER_HAIRLINE, T.CARD_BORDER, T.RADIUS_XS, [1,1,1,1], T.CARD_BORDER, T.PAD_CARD_TIGHT.x, T.PAD_CARD_TIGHT.y)
	oda_paper.shadow_color = T.SHADOW_SOFT
	oda_paper.shadow_size = 4
	oda_paper.shadow_offset = Vector2(0, 2)
	_panel(th, &"OdaPaperCard", "PanelContainer", oda_paper)
	var oda_paper_hover := _box(T.CARD_BG, T.BORDER_HAIRLINE, T.ACCENT, T.RADIUS_XS, [1,1,1,1], T.ACCENT, T.PAD_CARD_TIGHT.x, T.PAD_CARD_TIGHT.y)
	oda_paper_hover.shadow_color = T.ODA_ANCHOR_GLOW_SHADOW
	oda_paper_hover.shadow_size = 8
	oda_paper_hover.shadow_offset = Vector2(0, 2)
	_panel(th, &"OdaPaperCardHover", "PanelContainer", oda_paper_hover)
	# OdaAnchorGlow: boyalı çapaların hover/tur vurgu çerçevesi — YALNIZ kenar
	# (kalite turu v2 / D2 kök nedeni: StyleBoxFlat gölgesi kutunun arkasına tüm
	# gövde boyunca çizilir ve şeffaf zeminin İÇİNDEN amber dolgu gibi görünürdü —
	# "dev amber dikdörtgen" buydu). Gölge yok, draw_center kapalı; modulate.a tween.
	var oda_glow := _box(Color.TRANSPARENT, T.BORDER_FOCUS, T.ACCENT, T.RADIUS_M)
	oda_glow.draw_center = false
	_panel(th, &"OdaAnchorGlow", "Panel", oda_glow)
	# OdaTourCard: ilk açılış turunun adım kartı (koyu — sahnenin her yerinde okunur).
	_panel(th, &"OdaTourCard", "PanelContainer", _box(T.DIALOGUE_BG, T.BORDER_HAIRLINE, T.DIALOGUE_CARD_BORDER, T.RADIUS_L, [1,1,1,1], T.DIALOGUE_CARD_BORDER, T.PAD_ROW.x, T.PAD_ROW.y))

	# ---- RichTextLabel variations ----
	# NOTE: Godot 4's RichTextLabel theme items are "italics_font"/"bold_italics_font"
	# (with the s) — the old "italic_font" keys were silently ignored and *italic*
	# spans fell back to the engine-default sans at 16px.
	th.set_type_variation(&"BodyRich", &"RichTextLabel")
	th.set_font("normal_font", &"BodyRich", serif_reg)
	th.set_font("bold_font", &"BodyRich", serif_sb)
	th.set_font("italics_font", &"BodyRich", serif_it)
	th.set_font("bold_italics_font", &"BodyRich", serif_sb)
	th.set_font("mono_font", &"BodyRich", mono_reg)
	th.set_font_size("normal_font_size", &"BodyRich", T.SIZE_LEAD)
	th.set_font_size("bold_font_size", &"BodyRich", T.SIZE_LEAD)
	th.set_font_size("italics_font_size", &"BodyRich", T.SIZE_LEAD)
	th.set_font_size("bold_italics_font_size", &"BodyRich", T.SIZE_LEAD)
	th.set_font_size("mono_font_size", &"BodyRich", T.SIZE_LEAD)
	th.set_color("default_color", &"BodyRich", T.INK)

	th.set_type_variation(&"NewsRich", &"RichTextLabel")
	th.set_font("normal_font", &"NewsRich", mono_reg)
	th.set_font_size("normal_font_size", &"NewsRich", T.SIZE_SMALL)
	th.set_color("default_color", &"NewsRich", T.CREAM)

	# ---- ProgressBar variation (amber fill) ----
	th.set_type_variation(&"BuildProgress", &"ProgressBar")
	th.set_stylebox("background", &"BuildProgress", _box(T.SURFACE_SUNKEN, 0, Color.TRANSPARENT, T.RADIUS_S))
	th.set_stylebox("fill", &"BuildProgress", _box(T.ACCENT, 0, Color.TRANSPARENT, T.RADIUS_S))

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
	th.set_stylebox("slider", &"VolumeSlider", _box(T.CARD_BORDER, 0, Color.TRANSPARENT, T.RADIUS_S, [], Color.TRANSPARENT, -1, 2))
	th.set_stylebox("grabber_area", &"VolumeSlider", _box(T.ACCENT, 0, Color.TRANSPARENT, T.RADIUS_S, [], Color.TRANSPARENT, -1, 2))
	th.set_stylebox("grabber_area_highlight", &"VolumeSlider", _box(T.ACCENT_HOVER, 0, Color.TRANSPARENT, T.RADIUS_S, [], Color.TRANSPARENT, -1, 2))
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

	# ---- SettingsDropdown / SettingsPopup: the settings screen's OptionButton and
	# the PopupMenu it opens. Both base types were COMPLETELY unthemed — an
	# un-varied OptionButton fell through to Godot's default dark slab at 16px,
	# which is the same "random flat text" the base-type block below exists to
	# kill, and its popup is a SEPARATE Window with its OWN theme type (the button's
	# stylebox never reaches it). The settings panel is the first screen with real
	# dropdowns, so the pair is defined here rather than left to a scene override.
	#
	# Register: light body, i.e. the base LineEdit's grammar (SURFACE_INPUT fill +
	# CARD_BORDER hairline, amber on focus) rather than the base Button's — a
	# dropdown reads as a FIELD you pick a value in, not as an action you press.
	th.set_type_variation(&"SettingsDropdown", &"OptionButton")
	th.set_stylebox("normal", &"SettingsDropdown", _box(T.SURFACE_INPUT, T.BORDER_HAIRLINE, T.CARD_BORDER, T.RADIUS_M, [], Color.TRANSPARENT, T.PAD_INPUT.x, T.PAD_INPUT.y))
	th.set_stylebox("hover", &"SettingsDropdown", _box(T.SURFACE_INPUT, T.BORDER_HAIRLINE, T.ACCENT, T.RADIUS_M, [], Color.TRANSPARENT, T.PAD_INPUT.x, T.PAD_INPUT.y))
	th.set_stylebox("pressed", &"SettingsDropdown", _box(T.SURFACE_PRESSED, T.BORDER_HAIRLINE, T.ACCENT, T.RADIUS_M, [], Color.TRANSPARENT, T.PAD_INPUT.x, T.PAD_INPUT.y))
	th.set_stylebox("focus", &"SettingsDropdown", _box(Color.TRANSPARENT, T.BORDER_HAIRLINE, T.ACCENT, T.RADIUS_M, [], Color.TRANSPARENT, T.PAD_INPUT.x, T.PAD_INPUT.y))
	th.set_stylebox("disabled", &"SettingsDropdown", _box(T.SURFACE_DISABLED, T.BORDER_HAIRLINE, T.BORDER_DISABLED, T.RADIUS_M, [], Color.TRANSPARENT, T.PAD_INPUT.x, T.PAD_INPUT.y))
	th.set_font_size("font_size", &"SettingsDropdown", T.SIZE_BODY)
	th.set_color("font_color", &"SettingsDropdown", T.INK)
	th.set_color("font_hover_color", &"SettingsDropdown", T.INK)
	th.set_color("font_pressed_color", &"SettingsDropdown", T.INK)
	th.set_color("font_focus_color", &"SettingsDropdown", T.INK)
	th.set_color("font_hover_pressed_color", &"SettingsDropdown", T.INK)
	th.set_color("font_disabled_color", &"SettingsDropdown", T.INK_DIM)
	# modulate_arrow = 1 tints the engine's arrow icon with the font color; without
	# it the arrow keeps its default near-white and vanishes on the cream field.
	th.set_constant("modulate_arrow", &"SettingsDropdown", 1)
	th.set_constant("arrow_margin", &"SettingsDropdown", T.SPACE_M)
	th.set_constant("h_separation", &"SettingsDropdown", T.SPACE_XS)

	# The popup is its own Window: assign this variation to it in code with
	# `option.get_popup().theme_type_variation = &"SettingsPopup"`.
	th.set_type_variation(&"SettingsPopup", &"PopupMenu")
	th.set_stylebox("panel", &"SettingsPopup", _box(T.CARD_BG, T.BORDER_HAIRLINE, T.CARD_BORDER, T.RADIUS_M, [], Color.TRANSPARENT, T.SPACE_XS, T.SPACE_XS))
	th.set_stylebox("hover", &"SettingsPopup", _box(T.SURFACE_HOVER, 0, Color.TRANSPARENT, T.RADIUS_S))
	var popup_rule := StyleBoxLine.new()
	popup_rule.color = T.DIVIDER_LIGHT
	popup_rule.thickness = T.BORDER_HAIRLINE
	th.set_stylebox("separator", &"SettingsPopup", popup_rule)
	th.set_font_size("font_size", &"SettingsPopup", T.SIZE_BODY)
	th.set_color("font_color", &"SettingsPopup", T.INK)
	th.set_color("font_hover_color", &"SettingsPopup", T.INK)
	th.set_color("font_accelerator_color", &"SettingsPopup", T.INK_DIM)
	th.set_color("font_separator_color", &"SettingsPopup", T.INK_DIM)
	# A row the readability floor has locked out must READ as unavailable, not as a
	# rendering accident — the disabled tone is the whole point of the UI-scale gate.
	th.set_color("font_disabled_color", &"SettingsPopup", T.INK_DIM)
	th.set_constant("v_separation", &"SettingsPopup", T.SPACE_XS)
	th.set_constant("h_separation", &"SettingsPopup", T.SPACE_M)
	th.set_constant("item_start_padding", &"SettingsPopup", T.SPACE_S)
	th.set_constant("item_end_padding", &"SettingsPopup", T.SPACE_S)

	# ---- Base Button: light secondary default for every un-varied Button (onboarding
	# Back/steppers, sales Find/Pitch, build-HUD iteration/dev, modal Continue…).
	# Variations (CommitButton/SpeedButton/TabButton) still override this. ----
	th.set_stylebox("normal", &"Button", _box(T.CARD_BG, T.BORDER_HAIRLINE, T.CARD_BORDER, T.RADIUS_M, [], Color.TRANSPARENT, T.PAD_BTN.x, T.PAD_BTN.y))
	th.set_stylebox("hover", &"Button", _box(T.SURFACE_HOVER, T.BORDER_HAIRLINE, T.CARD_BORDER, T.RADIUS_M, [], Color.TRANSPARENT, T.PAD_BTN.x, T.PAD_BTN.y))
	th.set_stylebox("pressed", &"Button", _box(T.SURFACE_PRESSED, T.BORDER_HAIRLINE, T.CARD_BORDER, T.RADIUS_M, [], Color.TRANSPARENT, T.PAD_BTN.x, T.PAD_BTN.y))
	th.set_stylebox("disabled", &"Button", _box(T.SURFACE_DISABLED, T.BORDER_HAIRLINE, T.BORDER_DISABLED, T.RADIUS_M, [], Color.TRANSPARENT, T.PAD_BTN.x, T.PAD_BTN.y))
	th.set_color("font_color", &"Button", T.INK)
	th.set_color("font_hover_color", &"Button", T.INK)
	th.set_color("font_pressed_color", &"Button", T.INK)
	th.set_color("font_disabled_color", &"Button", T.INK_DIM)

	# ---- DialogueInput: LineEdit for the dark onboarding register (base LineEdit
	# below is light and unreadable on charcoal) ----
	th.set_type_variation(&"DialogueInput", &"LineEdit")
	th.set_stylebox("normal", &"DialogueInput", _box(T.DIALOGUE_CARD_BG, T.BORDER_HAIRLINE, T.DIALOGUE_CARD_BORDER, T.RADIUS_M, [], Color.TRANSPARENT, T.PAD_INPUT_LG.x, T.PAD_INPUT_LG.y))
	th.set_stylebox("focus", &"DialogueInput", _box(T.DIALOGUE_CARD_BG, T.BORDER_HAIRLINE, T.ACCENT, T.RADIUS_M, [], Color.TRANSPARENT, T.PAD_INPUT_LG.x, T.PAD_INPUT_LG.y))
	th.set_stylebox("read_only", &"DialogueInput", _box(T.DIALOGUE_CARD_BG, T.BORDER_HAIRLINE, T.DIALOGUE_CARD_BORDER, T.RADIUS_M, [], Color.TRANSPARENT, T.PAD_INPUT_LG.x, T.PAD_INPUT_LG.y))
	th.set_color("font_color", &"DialogueInput", T.CREAM)
	th.set_color("font_placeholder_color", &"DialogueInput", T.CREAM_DIM)
	th.set_color("caret_color", &"DialogueInput", T.CREAM)

	# ---- DialogueStepper: square −/+ button on the dark register (skill
	# allocation). Base Button is light-styled; DialogueGhost is too quiet for a
	# repeat-press control. ----
	th.set_type_variation(&"DialogueStepper", &"Button")
	th.set_stylebox("normal", &"DialogueStepper", _box(T.DIALOGUE_CARD_BG, T.BORDER_HAIRLINE, T.DIALOGUE_CARD_BORDER, T.RADIUS_M, [], Color.TRANSPARENT, T.PAD_BTN_S.x, T.PAD_BTN_S.y))
	th.set_stylebox("hover", &"DialogueStepper", _box(T.DIALOGUE_CARD_BG, T.BORDER_HAIRLINE, T.CREAM_DIM, T.RADIUS_M, [], Color.TRANSPARENT, T.PAD_BTN_S.x, T.PAD_BTN_S.y))
	th.set_stylebox("pressed", &"DialogueStepper", _box(T.VEIL_SOFT, T.BORDER_HAIRLINE, T.CREAM_DIM, T.RADIUS_M, [], Color.TRANSPARENT, T.PAD_BTN_S.x, T.PAD_BTN_S.y))
	th.set_stylebox("disabled", &"DialogueStepper", _box(T.VEIL_FAINT, T.BORDER_HAIRLINE, T.VEIL_SOFT, T.RADIUS_M, [], Color.TRANSPARENT, T.PAD_BTN_S.x, T.PAD_BTN_S.y))
	th.set_stylebox("focus", &"DialogueStepper", _box(Color.TRANSPARENT, 0, Color.TRANSPARENT, T.RADIUS_NONE))
	th.set_font_size("font_size", &"DialogueStepper", T.SIZE_LEAD)
	th.set_color("font_color", &"DialogueStepper", T.CREAM)
	th.set_color("font_hover_color", &"DialogueStepper", T.CREAM)
	th.set_color("font_pressed_color", &"DialogueStepper", T.CREAM)
	th.set_color("font_disabled_color", &"DialogueStepper", T.CREAM_DIM_DISABLED)

	# ---- Base LineEdit: light input (onboarding text fields) ----
	th.set_stylebox("normal", &"LineEdit", _box(T.SURFACE_INPUT, T.BORDER_HAIRLINE, T.CARD_BORDER, T.RADIUS_M, [], Color.TRANSPARENT, T.PAD_INPUT.x, T.PAD_INPUT.y))
	th.set_stylebox("focus", &"LineEdit", _box(T.SURFACE_INPUT, T.BORDER_HAIRLINE, T.ACCENT, T.RADIUS_M, [], Color.TRANSPARENT, T.PAD_INPUT.x, T.PAD_INPUT.y))
	th.set_stylebox("read_only", &"LineEdit", _box(T.CARD_BG, T.BORDER_HAIRLINE, T.CARD_BORDER, T.RADIUS_M, [], Color.TRANSPARENT, T.PAD_INPUT.x, T.PAD_INPUT.y))
	th.set_color("font_color", &"LineEdit", T.INK)
	th.set_color("font_placeholder_color", &"LineEdit", T.INK_DIM)
	th.set_color("font_uneditable_color", &"LineEdit", T.INK_MUTED)
	th.set_color("caret_color", &"LineEdit", T.INK)

	# ========================================================================
	# BASE-TYPE DEFAULTS — the point of Tema Çekirdeği.
	# ========================================================================
	# Until now the theme defined base types for ONLY Button and LineEdit. Every
	# other un-varied Control fell through to Godot's default theme, which was
	# PROBED (never assumed) and reports: default_font_size 16, Label font_color
	# pure white (1,1,1), PanelContainer panel inset 0/0/0/0, HSeparator
	# separation 4. So a naive `Label.new()` rendered at 16px in WHITE on our
	# cream body — right typeface, wrong size, invisible color. That is the
	# "random flat text" this task exists to kill.

	# default_font_size governs anything that does not pin its own. Six things
	# currently ride the implicit 16, so they are pinned FIRST — otherwise this
	# one line would drag every button down 3px at once. Pinned at SIZE_LEAD (15)
	# rather than 13 deliberately: it keeps the whole pass to ±1px. Tightening
	# 15→13 later is one line per pin, and belongs to the polish wave.
	th.set_default_font_size(T.SIZE_BODY)
	for pinned in [&"Button", &"CommitButton", &"TabButton", &"TabButtonActive",
			&"ChromeTabButton", &"ChromeTabButtonActive",
			&"LineEdit", &"DialogueInput", &"SettingsSwitch"]:
		th.set_font_size("font_size", pinned, T.SIZE_LEAD)
	# Base Button had no focus color, so ConfirmModal.tscn hand-set all four states.
	# With this the whole group becomes dead weight the sweep can delete.
	th.set_color("font_focus_color", &"Button", T.INK)

	# Base Label: font and size deliberately UNSET so they inherit the defaults —
	# that inheritance is what makes a zero-styling Label on-brand. line_spacing is
	# pinned to the engine default, i.e. zero pixel delta today, but the value is
	# ours now and can no longer drift when Godot changes its default theme.
	th.set_color("font_color", &"Label", T.INK)
	th.set_constant("line_spacing", &"Label", T.LEADING_BODY)

	# Panel is NOT a Container — children are anchor-positioned, so its stylebox
	# cannot move anything. Layout-neutral by construction.
	th.set_stylebox("panel", &"Panel", _box(T.CARD_BG, T.BORDER_HAIRLINE, T.CARD_BORDER, T.RADIUS_M))
	# PanelContainer IS a Container: its content margins inset children. Godot's
	# default is 0/0/0/0 (probed), so the base MUST carry 0/0 to stay layout-neutral.
	# Giving it PAD_CARD here would silently inset every un-varied PanelContainer —
	# exactly the layout change this task forbids. CardPanel remains the real card.
	th.set_stylebox("panel", &"PanelContainer", _box(T.CARD_BG, T.BORDER_HAIRLINE, T.CARD_BORDER, T.RADIUS_M, [], Color.TRANSPARENT, 0, 0))

	# RichTextLabel: note "italics_font" WITH the s — the old "italic_font" keys are
	# silently ignored and *italic* spans fall back to engine sans at 16 (see BodyRich).
	th.set_font("normal_font", &"RichTextLabel", serif_reg)
	th.set_font("bold_font", &"RichTextLabel", serif_sb)
	th.set_font("italics_font", &"RichTextLabel", serif_it)
	th.set_font("bold_italics_font", &"RichTextLabel", serif_sb)
	th.set_font("mono_font", &"RichTextLabel", mono_reg)
	for key in ["normal_font_size", "bold_font_size", "italics_font_size",
			"bold_italics_font_size", "mono_font_size"]:
		th.set_font_size(key, &"RichTextLabel", T.SIZE_BODY)
	th.set_color("default_color", &"RichTextLabel", T.INK)
	th.set_constant("line_separation", &"RichTextLabel", T.LEADING_RICH)

	th.set_stylebox("background", &"ProgressBar", _box(T.SURFACE_SUNKEN, 0, Color.TRANSPARENT, T.RADIUS_S))
	th.set_stylebox("fill", &"ProgressBar", _box(T.ACCENT, 0, Color.TRANSPARENT, T.RADIUS_S))

	# Separators: recolor only. `separation` is pinned to Godot's probed default 4,
	# so the two live sites (HuntTab, SalesTab) change hue and nothing moves.
	var rule := StyleBoxLine.new()
	rule.color = T.DIVIDER_LIGHT
	rule.thickness = T.BORDER_HAIRLINE
	th.set_stylebox("separator", &"HSeparator", rule)
	th.set_constant("separation", &"HSeparator", T.SPACE_XS)
	var vrule := StyleBoxLine.new()
	vrule.color = T.DIVIDER_LIGHT
	vrule.thickness = T.BORDER_HAIRLINE
	vrule.vertical = true
	th.set_stylebox("separator", &"VSeparator", vrule)
	th.set_constant("separation", &"VSeparator", T.SPACE_XS)

	# Tooltips were pure Godot default (dark slab, 16px). They are chrome, so they
	# take the dark register rather than the cream body.
	th.set_stylebox("panel", &"TooltipPanel", _box(T.BG_TOPBAR, T.BORDER_HAIRLINE, T.SEPARATOR, T.RADIUS_S, [], Color.TRANSPARENT, T.PAD_TOOLTIP.x, T.PAD_TOOLTIP.y))
	th.set_font("font", &"TooltipLabel", sans_reg)
	th.set_font_size("font_size", &"TooltipLabel", T.SIZE_SMALL)
	th.set_color("font_color", &"TooltipLabel", T.CREAM)

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
		normal = _box(T.TAB_ACTIVE_BG, 0, Color.TRANSPARENT, T.RADIUS_NONE, [T.BORDER_ACCENT,0,0,0], T.ACCENT)
	else:
		normal = _box(Color.TRANSPARENT, 0, Color.TRANSPARENT, T.RADIUS_NONE, [0,0,T.BORDER_HAIRLINE,0], T.DIVIDER_LIGHT)
	var hover := _box(T.SHADE_HOVER, 0, Color.TRANSPARENT, T.RADIUS_NONE)
	th.set_stylebox("normal", name, normal)
	th.set_stylebox("hover", name, hover if not active else normal)
	th.set_stylebox("pressed", name, normal)
	th.set_stylebox("focus", name, _box(Color.TRANSPARENT, 0, Color.TRANSPARENT, T.RADIUS_NONE))
	var fc: Color = T.INK if active else T.INK_DIM
	th.set_color("font_color", name, fc)
	th.set_color("font_hover_color", name, T.INK)
	th.set_color("font_pressed_color", name, fc)
	th.set_color("font_focus_color", name, fc)


func _chrome_tab_button(th: Theme, name: StringName, active: bool) -> void:
	# Işık rayının _tab_button'ının koyu ikizi: birebir aynı geometri (üst hairline /
	# 3px amber sol bar), yalnız register renkleri değişir (SEPARATOR/VEIL/CREAM).
	th.set_type_variation(name, &"Button")
	var normal: StyleBoxFlat
	if active:
		normal = _box(T.VEIL_SOFT, 0, Color.TRANSPARENT, T.RADIUS_NONE, [T.BORDER_ACCENT,0,0,0], T.ACCENT)
	else:
		normal = _box(Color.TRANSPARENT, 0, Color.TRANSPARENT, T.RADIUS_NONE, [0,0,T.BORDER_HAIRLINE,0], T.SEPARATOR)
	var hover := _box(T.VEIL_SOFT, 0, Color.TRANSPARENT, T.RADIUS_NONE)
	th.set_stylebox("normal", name, normal)
	th.set_stylebox("hover", name, hover if not active else normal)
	th.set_stylebox("pressed", name, normal)
	th.set_stylebox("focus", name, _box(Color.TRANSPARENT, 0, Color.TRANSPARENT, T.RADIUS_NONE))
	var fc: Color = T.CREAM if active else T.CREAM_DIM
	th.set_color("font_color", name, fc)
	th.set_color("font_hover_color", name, T.CREAM)
	th.set_color("font_pressed_color", name, fc)
	th.set_color("font_focus_color", name, fc)


func _speed_button(th: Theme, name: StringName, active: bool) -> void:
	th.set_type_variation(name, &"Button")
	var normal: StyleBoxFlat
	if active:
		normal = _box(T.ACCENT_DIM, 0, Color.TRANSPARENT, T.RADIUS_S, [], Color.TRANSPARENT, T.PAD_BTN_XS.x, T.PAD_BTN_XS.y)
	else:
		normal = _box(T.VEIL_FAINT, 0, Color.TRANSPARENT, T.RADIUS_S, [], Color.TRANSPARENT, T.PAD_BTN_XS.x, T.PAD_BTN_XS.y)
	var hover := _box(T.VEIL_STRONG, 0, Color.TRANSPARENT, T.RADIUS_S, [], Color.TRANSPARENT, T.PAD_BTN_XS.x, T.PAD_BTN_XS.y)
	th.set_stylebox("normal", name, normal)
	th.set_stylebox("hover", name, hover if not active else normal)
	th.set_stylebox("pressed", name, normal)
	th.set_stylebox("focus", name, _box(Color.TRANSPARENT, 0, Color.TRANSPARENT, T.RADIUS_NONE))
	# The one deliberate SHRINK in the scale pass (12→11): the speed control is mono
	# meta sitting in a fixed-height chrome bar, so SMALL is its right step and −1px
	# is the safe direction inside a bar that cannot grow.
	th.set_font_size("font_size", name, T.SIZE_SMALL)
	th.set_color("font_color", name, T.CREAM if active else T.CREAM_DIM)
	th.set_color("font_hover_color", name, T.CREAM)
	th.set_color("font_pressed_color", name, T.CREAM)


func _commit_button(th: Theme) -> void:
	var name := &"CommitButton"
	th.set_type_variation(name, &"Button")
	th.set_stylebox("normal", name, _box(T.ACCENT, 0, Color.TRANSPARENT, T.RADIUS_M, [], Color.TRANSPARENT, T.PAD_CTA.x, T.PAD_CTA.y))
	th.set_stylebox("hover", name, _box(T.ACCENT_HOVER, 0, Color.TRANSPARENT, T.RADIUS_M, [], Color.TRANSPARENT, T.PAD_CTA.x, T.PAD_CTA.y))
	th.set_stylebox("pressed", name, _box(T.ACCENT_PRESSED, 0, Color.TRANSPARENT, T.RADIUS_M, [], Color.TRANSPARENT, T.PAD_CTA.x, T.PAD_CTA.y))
	th.set_stylebox("disabled", name, _box(T.SURFACE_SUNKEN, 0, Color.TRANSPARENT, T.RADIUS_M, [], Color.TRANSPARENT, T.PAD_CTA.x, T.PAD_CTA.y))
	th.set_stylebox("focus", name, _box(Color.TRANSPARENT, 0, Color.TRANSPARENT, T.RADIUS_NONE))
	th.set_color("font_color", name, T.INK)
	th.set_color("font_hover_color", name, T.INK)
	th.set_color("font_pressed_color", name, T.INK)
	th.set_color("font_disabled_color", name, T.INK_DIM)
