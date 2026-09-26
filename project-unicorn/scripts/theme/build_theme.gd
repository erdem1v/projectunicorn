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

## Content margin "unset" (StyleBox default -1 = fall back to the border width).
const NO_PAD := Vector2i(-1, -1)

func _initialize() -> void:
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
	_lbl(th, &"MetricCaption", mono_label, T.SIZE_META, T.INK_FAINT)
	_lbl(th, &"MetricValue", mono_sb, T.SIZE_LEAD, T.CREAM)
	_lbl(th, &"MetricDelta", mono_reg, T.SIZE_SMALL, T.CREAM_DIM)
	_lbl(th, &"MetricUnit", mono_reg, T.SIZE_META, T.INK_FAINT)
	_lbl(th, &"TabLabel", mono_label, T.SIZE_META, T.INK_DIM)
	_lbl(th, &"BadgeLabel", mono_reg, T.SIZE_MICRO, T.INK)
	_lbl(th, &"ChoiceLabel", sans_reg, T.SIZE_LEAD, T.INK)
	_lbl(th, &"ChoiceLabelStrong", sans_sb, T.SIZE_LEAD, T.INK)
	_lbl(th, &"FeedDay", mono_reg, T.SIZE_SMALL, T.INK_MUTED)
	_lbl(th, &"ChromeSerif", serif_reg, T.SIZE_BODY, T.CREAM)
	_lbl(th, &"ChromeLabel", mono_label, T.SIZE_MICRO, T.CREAM_DIM)
	_lbl(th, &"ChromeValue", sans_sb, T.SIZE_BODY, T.CREAM)
	_lbl(th, &"ChromeClock", mono_reg, T.SIZE_DATA, T.CREAM_DIM)   # TopBar tarih/saat
	# ChromeAlert: KEPENK / TEKLİF geri sayımı. Tema statiktir; renk körü takası bu
	# etiketi top_bar.gd'de yeniden boyar.
	_lbl(th, &"ChromeAlert", mono_sb, T.SIZE_SMALL, T.NEGATIVE)
	_lbl(th, &"ColumnHeader", mono_label, T.SIZE_META, T.INK_DIM)  # defter sütun başlığı
	_lbl(th, &"SectionAmber", mono_label, T.SIZE_SMALL, T.ACCENT)  # kural çizgisiyle birlikte kullanılır
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

	# ---- Cinematic dialogue register: text on the dark column ----
	_lbl(th, &"DialogueName", sans_sb, T.SIZE_LEAD, T.CREAM)  # counterpart name (uppercased in code)
	_lbl(th, &"DialogueRole", mono_label, T.SIZE_SMALL, T.CREAM_DIM)    # role line under the name
	_lbl(th, &"DialogueTag", mono_label, T.SIZE_MICRO, T.CREAM_DIM)  # speaker-tag chip "ANCHOR — CANLI"
	_lbl(th, &"QuoteSerifCream", serif_it, T.SIZE_LEAD, T.CREAM)     # spoken line
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

	# ---- Newspaper ending register ("Ekonomi Postası"): the light island, so its
	# text reads the PAPER_INK_* ladder (INK is light and would print white on cream).
	_lbl(th, &"MastheadSerif", serif_sb, T.SIZE_ED_MASTHEAD, T.PAPER_INK_MAST)  # "EKONOMİ POSTASI"
	_lbl(th, &"NewsHeadlineSerif", serif_sb, T.SIZE_ED_HEADLINE, T.PAPER_INK)   # story headline (darkest)
	_lbl(th, &"NewsDeckSerif", serif_it, T.SIZE_LEAD, T.PAPER_INK_DECK)         # italic subhead / quoted deck
	_lbl(th, &"NewsCaptionSerif", serif_it, T.SIZE_SMALL, T.PAPER_INK_META)     # engraving caption (italic, dim)
	_lbl(th, &"NewsMeta", mono_label, T.SIZE_META, T.PAPER_INK_META)            # date / edition caps
	_lbl(th, &"NewsBodySerif", serif_reg, T.SIZE_BODY, T.PAPER_INK_BODY)        # ledger-line / notice body prose
	_lbl(th, &"NewsStatSerif", serif_sb, T.SIZE_ED_FIGURE, T.PAPER_INK)         # stat-row figures ("$4.0M")

	# ---- Panel variations ----
	_panel(th, &"TopBarPanel", "Panel", _sides_box(T.BG_TOPBAR, T.RADIUS_NONE, [0, 0, 0, T.BORDER_HAIRLINE], T.SEPARATOR))
	_panel(th, &"SidePanel", "Panel", _sides_box(T.BG_PANEL, T.RADIUS_NONE, [T.BORDER_HAIRLINE, T.BORDER_HAIRLINE, 0, 0], T.DIVIDER_LIGHT))
	_panel(th, &"NewsPanel", "Panel", _sides_box(T.BG_NEWS, T.RADIUS_NONE, [0, 0, T.BORDER_HAIRLINE, 0], T.SEPARATOR))
	_panel(th, &"ViewportPanel", "Panel", _box(T.BG_BODY, T.RADIUS_NONE))
	_panel(th, &"ModalPanel", "Panel", _box(T.CARD_BG, T.RADIUS_L, T.CARD_BORDER))
	_panel(th, &"ArtPanel", "Panel", _box(T.BG_ART, T.RADIUS_S))
	_panel(th, &"PhaseDotActive", "Panel", _box(T.ACCENT, T.RADIUS_XS))
	_panel(th, &"PhaseDotDim", "Panel", _box(T.DOT_IDLE, T.RADIUS_XS))
	_panel(th, &"SelectedBorder", "Panel", _box(Color.TRANSPARENT, T.RADIUS_M, T.ACCENT, NO_PAD, T.BORDER_FOCUS))
	_panel(th, &"TabBadge", "Panel", _box(T.ACCENT, T.RADIUS_XL))
	_panel(th, &"Avatar", "Panel", _box(T.BG_AVATAR, T.RADIUS_PILL))
	_panel(th, &"CapBar", "Panel", _box(T.BG_AVATAR, T.RADIUS_XS))

	# ---- PanelContainer variations (auto content margins) ----
	_panel(th, &"CardPanel", "PanelContainer", _box(T.CARD_BG, T.RADIUS_M, T.CARD_BORDER, T.PAD_CARD))
	# CardCta: "+ Yeni Ürün" davet kartı. StyleBoxFlat kesikli kenar çizemez; düz amber
	# en yakın karşılık.
	_panel(th, &"CardCta", "PanelContainer", _box(Color.TRANSPARENT, T.RADIUS_M, T.ACCENT, T.PAD_CARD))
	_panel(th, &"CardPanelTight", "PanelContainer", _box(T.CARD_BG, T.RADIUS_M, T.CARD_BORDER, T.PAD_CARD_TIGHT))
	_panel(th, &"CardAttention", "PanelContainer", _box(T.CARD_ATTENTION_BG, T.RADIUS_M, T.CARD_ATTENTION_BORDER, T.PAD_CARD))
	# AttentionStrip: kırmızı dikkat şeridi, sayfa başlığının hemen altında.
	_panel(th, &"AttentionStrip", "PanelContainer", _box(T.CARD_ATTENTION_BG, T.RADIUS_M, T.CARD_ATTENTION_BORDER, T.PAD_BAND))
	# EmptyRow: boş departman satırı. Kesikli kenar yerine tek piksellik düz kenar,
	# dolgu yok — böylece "boş" okunuyor.
	_panel(th, &"EmptyRow", "PanelContainer", _box(Color.TRANSPARENT, T.RADIUS_M, T.BORDER_DASHED, T.PAD_ROW))
	# LedgerRow(+Hover): hover yalnız kenar; dolgu ve margin aynı kalır, yoksa satır zıplar.
	_panel(th, &"LedgerRow", "PanelContainer", _box(T.CARD_BG, T.RADIUS_M, T.CARD_BORDER, T.PAD_ROW))
	_panel(th, &"LedgerRowHover", "PanelContainer", _box(T.CARD_BG, T.RADIUS_M, T.BORDER_HOVER, T.PAD_ROW))
	# Durum çipleri: ince renkli kenar + koyu dolgu.
	_panel(th, &"ChipNeutral", "PanelContainer", _box(T.NEUTRAL_BADGE_BG, T.RADIUS_S, T.BORDER_DISABLED, T.PAD_CHIP))
	_panel(th, &"ChipAmber", "PanelContainer", _box(T.AMBER_BG, T.RADIUS_S, T.ACCENT, T.PAD_CHIP))
	_panel(th, &"ChipPositive", "PanelContainer", _box(T.POSITIVE_BG, T.RADIUS_S, T.POSITIVE_RULE, T.PAD_CHIP))
	_panel(th, &"ChipNegative", "PanelContainer", _box(T.NEGATIVE_BG, T.RADIUS_S, T.NEGATIVE_RULE, T.PAD_CHIP))
	_panel(th, &"ChoiceCard", "PanelContainer", _box(T.CARD_BG, T.RADIUS_M, T.CARD_BORDER, T.PAD_CHOICE))
	# Event-modal choice states: amber border on hover, and the MENTOR TAVSİYESİ card.
	# Mentor stays shadow-free: the tab chip must overlap its top edge cleanly.
	_panel(th, &"ChoiceCardHover", "PanelContainer", _box(T.CARD_BG, T.RADIUS_M, T.ACCENT, T.PAD_CHOICE))
	_panel(th, &"ChoiceCardMentor", "PanelContainer", _box(T.CARD_BG, T.RADIUS_M, T.ACCENT, T.PAD_CHOICE))
	_panel(th, &"HeaderBand", "PanelContainer", _sides_box(Color.TRANSPARENT, T.RADIUS_NONE, [0, 0, 0, T.BORDER_HAIRLINE], T.BORDER_DISABLED, T.PAD_STRIP))
	# CardFloating: gövde üstünde yüzen kart (BuildHUD overlay'i).
	var floating_sb := _box(T.CARD_FLOATING_BG, T.RADIUS_L, T.CARD_BORDER, T.PAD_CARD_TIGHT)
	floating_sb.shadow_color = T.SHADOW_SOFT
	floating_sb.shadow_size = 6
	_panel(th, &"CardFloating", "PanelContainer", floating_sb)

	# ---- Cinematic dialogue register: dark panels ----
	# Column = floating semi-opaque charcoal (art shows through); Card = solid
	# charcoal for the Frank popup; QuoteBox carries the amber left-edge bar;
	# DialogueChoice(+Hover) swap on mouse-over; NumberChip is the choice ring.
	_panel(th, &"DialogueColumn", "Panel", _box(T.DIALOGUE_COLUMN_BG, T.RADIUS_XXL))
	_panel(th, &"DialogueCard", "Panel", _box(T.DIALOGUE_BG, T.RADIUS_CARD_LG, T.DIALOGUE_CARD_BORDER))
	_panel(th, &"PortraitFrame", "PanelContainer", _box(T.PORTRAIT_FRAME, T.RADIUS_PORTRAIT, Color.TRANSPARENT, T.PAD_FRAME))
	_panel(th, &"QuoteBox", "PanelContainer", _sides_box(T.DIALOGUE_CARD_BG, T.RADIUS_M, [T.BORDER_ACCENT, 0, 0, 0], T.ACCENT, T.PAD_ROW))
	_panel(th, &"DialogueChoice", "PanelContainer", _box(T.DIALOGUE_CARD_BG, T.RADIUS_XL, T.DIALOGUE_CARD_BORDER, T.PAD_ROW))
	_panel(th, &"DialogueChoiceHover", "PanelContainer", _box(T.DIALOGUE_CARD_BG, T.RADIUS_XL, T.ACCENT, T.PAD_ROW))
	_panel(th, &"NumberChip", "Panel", _box(Color.TRANSPARENT, T.RADIUS_PILL, T.CREAM_DIM))
	_panel(th, &"StatStrip", "PanelContainer", _box(T.STAT_STRIP_BG, T.RADIUS_M, Color.TRANSPARENT, T.PAD_STRIP))

	# ---- Dark-register onboarding: portrait grid cells (hairline vs 2px amber ring) ----
	_panel(th, &"PortraitCell", "PanelContainer", _box(T.DIALOGUE_CARD_BG, T.RADIUS_L, T.DIALOGUE_CARD_BORDER, T.PAD_CELL))
	_panel(th, &"PortraitCellSelected", "PanelContainer", _box(T.DIALOGUE_CARD_BG, T.RADIUS_L, T.ACCENT, T.PAD_CELL, T.BORDER_FOCUS))

	# ---- Newspaper ending panels ----
	# PaperPanel: the cream page is FLAT PRINT — 1px edge on all four sides, no radius,
	# no drop shadow — so it reads as a printed object rather than a UI card.
	_panel(th, &"PaperPanel", "PanelContainer", _box(T.PAPER_BG, T.RADIUS_NONE, T.PAPER_EDGE, T.PAD_SHEET))
	# ModalCard: the standard dark decision modal (event · Atlas · Ayarlar · ay sonu).
	var modal_card_sb := _box(T.DIALOGUE_BG, T.RADIUS_M, T.CARD_BORDER, T.PAD_PAGE)
	modal_card_sb.shadow_color = Color(0, 0, 0, 0.60)
	modal_card_sb.shadow_size = 40
	modal_card_sb.shadow_offset = Vector2(0, 10)
	_panel(th, &"ModalCard", "PanelContainer", modal_card_sb)
	# RailPanel: the dark meta rail — same charcoal as the screen, a left hairline divides it.
	_panel(th, &"RailPanel", "PanelContainer", _sides_box(T.DIALOGUE_BG, T.RADIUS_NONE, [T.BORDER_HAIRLINE, 0, 0, 0], T.SEPARATOR, T.PAD_RAIL))
	# RailCard: Coming-Soon Tier2/Tier3 cards on the rail.
	_panel(th, &"RailCard", "PanelContainer", _box(T.DIALOGUE_CARD_BG, T.RADIUS_M, T.DIALOGUE_CARD_BORDER, T.PAD_CARD_RAIL))
	# EngravingFrame: the illustration frame on the paper; reads the paper ink because
	# its only consumer is the newspaper (ODA resolves its own frozen theme).
	_panel(th, &"EngravingFrame", "PanelContainer", _box(T.PAPER_PLATE, T.RADIUS_NONE, T.PAPER_INK_META, Vector2i.ZERO))

	# ---- Button variations ----
	_tab_button(th, &"TabButton", false)
	_tab_button(th, &"TabButtonActive", true)
	_speed_button(th, &"SpeedButton", false)
	_speed_button(th, &"SpeedButtonActive", true)
	_commit_button(th)

	# DialogueGhost: quiet cream text button on the dark register ("Toplantıdan çekil").
	_ghost_button(th, &"DialogueGhost")

	# ========================================================================
	# CHROME AİLESİ — koyu kabuk register'ı. Yasal yüzey listesi CLAUDE.md Chrome
	# kuralında. Desenler kabuğun kendi grameri: SpeedButton'ın VEIL merdiveni,
	# UiFactory çipinin PAD_CHIP'i, kabuk hairline'ının SEPARATOR'u.
	# ========================================================================
	# ChromeButton: koyu kabukta standart-boy ikincil buton. Metin boyutu base Button'dan.
	th.set_type_variation(&"ChromeButton", &"Button")
	_states(th, &"ChromeButton", {
		"normal": _box(T.VEIL_FAINT, T.RADIUS_S, Color.TRANSPARENT, T.PAD_BTN),
		"hover": _box(T.VEIL_STRONG, T.RADIUS_S, Color.TRANSPARENT, T.PAD_BTN),
		"pressed": _box(T.VEIL_SOFT, T.RADIUS_S, Color.TRANSPARENT, T.PAD_BTN),
		"disabled": _box(T.VEIL_FAINT, T.RADIUS_S, Color.TRANSPARENT, T.PAD_BTN),
		"focus": _no_focus(),
	})
	th.set_color("font_color", &"ChromeButton", T.CREAM)
	th.set_color("font_hover_color", &"ChromeButton", T.CREAM)
	th.set_color("font_pressed_color", &"ChromeButton", T.CREAM)
	th.set_color("font_disabled_color", &"ChromeButton", T.CREAM_DIM_DISABLED)
	_panel(th, &"ChromeChip", "PanelContainer", _box(T.VEIL_FAINT, T.RADIUS_S, Color.TRANSPARENT, T.PAD_CHIP))
	_lbl(th, &"ChromeBadgeLabel", mono_sb, T.SIZE_MICRO, T.CREAM)
	# ChromeSeparator: kabuk hairline'ı (base ayraçlar gövdenin DIVIDER_LIGHT'ı).
	th.set_type_variation(&"ChromeSeparator", &"VSeparator")
	th.set_stylebox("separator", &"ChromeSeparator", _rule(T.SEPARATOR, true))
	th.set_constant("separation", &"ChromeSeparator", T.SPACE_XS)
	# ChromeRailPanel: sol sekme rayı — TopBar ile aynı kömür (L-biçimli kabuk
	# çerçevesi); sağ hairline rayı sayfadan ayırır.
	_panel(th, &"ChromeRailPanel", "Panel", _sides_box(T.BG_TOPBAR, T.RADIUS_NONE, [0, T.BORDER_HAIRLINE, 0, 0], T.SEPARATOR))
	# ChromeTabButton(+Active): kabuk ile gövde aynı register'da, o yüzden TabButton ile
	# birebir aynı. Ad ayrı kalır: LeftTabs bu adı okur ve Chrome yasallık grep'i anlamlı kalır.
	_tab_button(th, &"ChromeTabButton", false)
	_tab_button(th, &"ChromeTabButtonActive", true)
	_lbl(th, &"ChromeTabLabel", mono_label, T.SIZE_META, T.INK_DIM)
	# ChromeGhost: kabuk şeridinin sessiz mono butonu ("ODAYA DÖN ✕"). DialogueGhost'un
	# merdiveni + mono yüz; kabuk grameri olduğu için ayrı ad taşır.
	_ghost_button(th, &"ChromeGhost")
	th.set_font("font", &"ChromeGhost", mono_label)
	# ChromePageStrip: sekme sayfasının üstündeki ince koyu bant; alt hairline sayfaya dikiş atar.
	_panel(th, &"ChromePageStrip", "PanelContainer", _sides_box(T.BG_TOPBAR, T.RADIUS_NONE, [0, 0, 0, T.BORDER_HAIRLINE], T.SEPARATOR, T.PAD_STRIP))

	# ========================================================================
	# ODA REGISTER'I — oda sahnesi üstündeki motor-çizimi bilgi yüzeyleri. Sahne
	# sanatı koyu; okunan her yüzey ya koyu ekran (monitör) ya açık kâğıt/kart.
	# ========================================================================
	# Monitör camı ~440×270px: başlık DISPLAY, grid değerleri TITLE, caption'lar SMALL.
	_lbl(th, &"OdaScreenTitle", serif_sb, T.SIZE_DISPLAY, T.CREAM)
	_lbl(th, &"OdaScreenValue", sans_sb, T.SIZE_TITLE, T.CREAM)
	_lbl(th, &"OdaScreenCaption", mono_label, T.SIZE_SMALL, T.CREAM_DIM)
	# OdaMonitorScreen: monitör camının içindeki bilgi paneli. Gece parlaması stylebox
	# gölgesi DEĞİL (sarmalayıcı klibi yarım-glow üretirdi); ScreenGlow node'u oda_view'da.
	_panel(th, &"OdaMonitorScreen", "PanelContainer", _box(T.DIALOGUE_BG, T.RADIUS_XS, Color.TRANSPARENT, T.PAD_CARD))
	# OdaBoardCard(+Hover): panoya raptiyeli kart. Hover'da dolgu parlamaz, yalnız kenar
	# amber'e döner; margin'ler aynı kalır ki metin zıplamasın.
	_panel(th, &"OdaBoardCard", "PanelContainer", _box(T.PAPER_BG, T.RADIUS_XS, T.CARD_BORDER, T.PAD_CARD_TIGHT))
	_panel(th, &"OdaBoardCardHover", "PanelContainer", _box(T.PAPER_BG, T.RADIUS_XS, T.ACCENT, T.PAD_CARD_TIGHT))
	_panel(th, &"OdaPostIt", "PanelContainer", _box(T.AMBER_BG, T.RADIUS_XS, Color.TRANSPARENT, T.PAD_CARD_TIGHT))
	# OdaPaperCard(+Hover): masadaki bekleyen-karar kâğıdı; yumuşak gölgeyle masadan
	# kalkar, hover amber kenar + amber gölge.
	var oda_paper := _box(T.CARD_BG, T.RADIUS_XS, T.CARD_BORDER, T.PAD_CARD_TIGHT)
	oda_paper.shadow_color = T.SHADOW_SOFT
	oda_paper.shadow_size = 4
	oda_paper.shadow_offset = Vector2(0, 2)
	_panel(th, &"OdaPaperCard", "PanelContainer", oda_paper)
	var oda_paper_hover := _box(T.CARD_BG, T.RADIUS_XS, T.ACCENT, T.PAD_CARD_TIGHT)
	oda_paper_hover.shadow_color = T.ODA_ANCHOR_GLOW_SHADOW
	oda_paper_hover.shadow_size = 8
	oda_paper_hover.shadow_offset = Vector2(0, 2)
	_panel(th, &"OdaPaperCardHover", "PanelContainer", oda_paper_hover)
	# OdaAnchorGlow: boyalı çapaların vurgu çerçevesi — YALNIZ kenar. StyleBoxFlat
	# gölgesi şeffaf zeminin içinden amber dolgu gibi görünürdü; gölge yok,
	# draw_center kapalı, vurgu modulate.a tween'i.
	var oda_glow := _box(Color.TRANSPARENT, T.RADIUS_M, T.ACCENT, NO_PAD, T.BORDER_FOCUS)
	oda_glow.draw_center = false
	_panel(th, &"OdaAnchorGlow", "Panel", oda_glow)
	# OdaTourCard: ilk açılış turunun adım kartı (koyu — sahnenin her yerinde okunur).
	_panel(th, &"OdaTourCard", "PanelContainer", _box(T.DIALOGUE_BG, T.RADIUS_L, T.DIALOGUE_CARD_BORDER, T.PAD_ROW))

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

	# ---- HSlider variations. PriceSlider: transparent track so the amber grabber
	# rides on the coloured value band drawn behind it. VolumeSlider: a visible
	# neutral groove with an amber fill up to the grabber. ----
	var grabber: Texture2D = load("res://assets/icons/slider_grabber.svg")
	th.set_type_variation(&"PriceSlider", &"HSlider")
	_states(th, &"PriceSlider", {
		"slider": StyleBoxEmpty.new(),
		"grabber_area": StyleBoxEmpty.new(),
		"grabber_area_highlight": StyleBoxEmpty.new(),
	})
	th.set_constant("center_grabber", &"PriceSlider", 1)
	_grabber_icons(th, &"PriceSlider", grabber)

	th.set_type_variation(&"VolumeSlider", &"HSlider")
	_states(th, &"VolumeSlider", {
		"slider": _box(T.CARD_BORDER, T.RADIUS_S, Color.TRANSPARENT, Vector2i(-1, 2)),
		"grabber_area": _box(T.ACCENT, T.RADIUS_S, Color.TRANSPARENT, Vector2i(-1, 2)),
		"grabber_area_highlight": _box(T.ACCENT_HOVER, T.RADIUS_S, Color.TRANSPARENT, Vector2i(-1, 2)),
	})
	th.set_constant("center_grabber", &"VolumeSlider", 1)
	_grabber_icons(th, &"VolumeSlider", grabber)

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
		"hover": _box(T.SURFACE_INPUT, T.RADIUS_M, T.ACCENT, T.PAD_INPUT),
		"pressed": _box(T.SURFACE_PRESSED, T.RADIUS_M, T.ACCENT, T.PAD_INPUT),
		"focus": _box(Color.TRANSPARENT, T.RADIUS_M, T.ACCENT, T.PAD_INPUT),
		"disabled": _box(T.SURFACE_DISABLED, T.RADIUS_M, T.BORDER_DISABLED, T.PAD_INPUT),
	})
	th.set_font_size("font_size", &"SettingsDropdown", T.SIZE_BODY)
	for key in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color",
			"font_hover_pressed_color"]:
		th.set_color(key, &"SettingsDropdown", T.INK)
	th.set_color("font_disabled_color", &"SettingsDropdown", T.INK_DIM)
	# modulate_arrow tints the engine's arrow icon with the font colour; without it the
	# arrow keeps its default tint.
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
		"hover": _box(Color.TRANSPARENT, T.RADIUS_M, T.ACCENT, T.PAD_BTN),
		"pressed": _box(T.SURFACE_PRESSED, T.RADIUS_M, T.ACCENT, T.PAD_BTN),
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
		"focus": _box(T.DIALOGUE_CARD_BG, T.RADIUS_M, T.ACCENT, T.PAD_INPUT_LG),
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
		"pressed": _box(T.VEIL_SOFT, T.RADIUS_M, T.CREAM_DIM, T.PAD_BTN_S),
		"disabled": _box(T.VEIL_FAINT, T.RADIUS_M, T.VEIL_SOFT, T.PAD_BTN_S),
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
		"focus": _box(T.SURFACE_INPUT, T.RADIUS_M, T.ACCENT, T.PAD_INPUT),
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

	var err := ResourceSaver.save(th, OUT_PATH)
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
	ResourceSaver.save(fv, path)
	return load(path)


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


func _grabber_icons(th: Theme, name: StringName, grabber: Texture2D) -> void:
	for key in ["grabber", "grabber_highlight", "grabber_disabled"]:
		th.set_icon(key, name, grabber)


## Quiet text button, transparent until hovered (DialogueGhost / ChromeGhost).
func _ghost_button(th: Theme, name: StringName) -> void:
	th.set_type_variation(name, &"Button")
	_states(th, name, {
		"normal": _box(Color.TRANSPARENT, T.RADIUS_M, Color.TRANSPARENT, T.PAD_BTN_GHOST),
		"hover": _box(T.VEIL_SOFT, T.RADIUS_M, Color.TRANSPARENT, T.PAD_BTN_GHOST),
		"pressed": _box(T.VEIL_FAINT, T.RADIUS_M, Color.TRANSPARENT, T.PAD_BTN_GHOST),
		"focus": _no_focus(),
	})
	th.set_font_size("font_size", name, T.SIZE_SMALL)
	th.set_color("font_color", name, T.CREAM_DIM)
	th.set_color("font_hover_color", name, T.CREAM)
	th.set_color("font_pressed_color", name, T.CREAM_DIM)


# Rail item. Active: 2px amber left bar + TAB_ACTIVE_BG fill. Idle: flat, no fill.
# Hover is EDGE, not fill: the left bar turns BORDER_HOVER. On the active item hover
# equals normal (the amber bar is already there). The idle item keeps a transparent
# 2px left border so its text lines up with the active one.
func _tab_button(th: Theme, name: StringName, active: bool) -> void:
	th.set_type_variation(name, &"Button")
	var bar: Array = [T.BORDER_FOCUS, 0, 0, 0]
	var normal: StyleBoxFlat
	var hover: StyleBoxFlat
	if active:
		normal = _sides_box(T.TAB_ACTIVE_BG, T.RADIUS_NONE, bar, T.ACCENT)
		hover = normal
	else:
		normal = _sides_box(Color.TRANSPARENT, T.RADIUS_NONE, bar, Color.TRANSPARENT)
		hover = _sides_box(Color.TRANSPARENT, T.RADIUS_NONE, bar, T.BORDER_HOVER)
	_states(th, name, {"normal": normal, "hover": hover, "pressed": normal, "focus": _no_focus()})
	var fc: Color = T.INK if active else T.INK_DIM
	th.set_color("font_color", name, fc)
	th.set_color("font_hover_color", name, T.INK)
	th.set_color("font_pressed_color", name, fc)
	th.set_color("font_focus_color", name, fc)


# Speed key: active = ACCENT_DIM fill + amber edge + amber text; idle = no fill,
# CARD_BORDER edge, INK_DIM text. Hover again moves only the edge.
func _speed_button(th: Theme, name: StringName, active: bool) -> void:
	th.set_type_variation(name, &"Button")
	var normal: StyleBoxFlat
	var hover: StyleBoxFlat
	if active:
		normal = _box(T.ACCENT_DIM, T.RADIUS_S, T.ACCENT, T.PAD_BTN_XS)
		hover = normal
	else:
		normal = _box(Color.TRANSPARENT, T.RADIUS_S, T.CARD_BORDER, T.PAD_BTN_XS)
		hover = _box(Color.TRANSPARENT, T.RADIUS_S, T.BORDER_HOVER, T.PAD_BTN_XS)
	_states(th, name, {"normal": normal, "hover": hover, "pressed": normal, "focus": _no_focus()})
	th.set_font_size("font_size", name, T.SIZE_SMALL)
	th.set_color("font_color", name, T.ACCENT if active else T.INK_DIM)
	th.set_color("font_hover_color", name, T.ACCENT if active else T.INK_MUTED)
	th.set_color("font_pressed_color", name, T.ACCENT)


# Primary button: filled amber with ON_ACCENT text (INK is light and would print
# white on amber). Disabled: SURFACE_DISABLED fill + hairline edge + INK_DIM text.
func _commit_button(th: Theme) -> void:
	var name := &"CommitButton"
	th.set_type_variation(name, &"Button")
	_states(th, name, {
		"normal": _box(T.ACCENT, T.RADIUS_M, Color.TRANSPARENT, T.PAD_CTA),
		"hover": _box(T.ACCENT_HOVER, T.RADIUS_M, Color.TRANSPARENT, T.PAD_CTA),
		"pressed": _box(T.ACCENT_PRESSED, T.RADIUS_M, Color.TRANSPARENT, T.PAD_CTA),
		"disabled": _box(T.SURFACE_DISABLED, T.RADIUS_M, T.BORDER_DISABLED, T.PAD_CTA),
		"focus": _no_focus(),
	})
	th.set_color("font_color", name, T.ON_ACCENT)
	th.set_color("font_hover_color", name, T.ON_ACCENT)
	th.set_color("font_pressed_color", name, T.ON_ACCENT)
	th.set_color("font_disabled_color", name, T.INK_DIM)
