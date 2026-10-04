class_name UiTokens
extends RefCounted

# ============================================================================
# Project Unicorn — UI design tokens (single source of truth).
# ============================================================================
# UiTokens owns the VOCABULARY: every Color in the game (named), the type scale,
# spacing / radius / border / padding tokens, leading, and the runtime colour
# helpers a .tres cannot express (delta_color, badge_palette…).
# It knows nothing about Control types.
#
# themes/master_theme.tres owns the ASSIGNMENT (which type / variation gets which
# token) and is GENERATED from this file by scripts/theme/build_theme.gd — the
# only file allowed to turn a token into a theme item. Never hand-edit the .tres:
#   godot --headless --path . -s res://scripts/theme/build_theme.gd
#   (a clean checkout needs `godot --headless --path . --import` first)
#
# Within the theme the SCALE owns size + leading and the VARIATION owns face +
# colour (the register axis: body / chrome / cinematic / newsprint).
# Scenes and scripts own layout only.
#
# CONTEXT RULE — the body is cream paper inside a dark chrome frame. INK is text
# on the cream body, CREAM is text on the dark frame. The frame (TopBar,
# NewsTicker) reads CREAM*, the *_CHROME twins and *_BRIGHT;
# the body reads INK*, the plain tokens and positive() / negative(). The dark
# cinematic register (DIALOGUE_*) reads the frame's side as well: CREAM*,
# ACCENT_CHROME, INK_*_CHROME, CARD_BORDER_CHROME, BORDER_HOVER_CHROME, the
# VEIL_*_CHROME whites and *_BRIGHT. The newspaper keeps its own PAPER_*
# ladder.
#
# FONT IMPORT STANDARD: all faces share antialiasing=1 (grayscale), hinting=1
# (light), subpixel_positioning=4 (auto), msdf off, mipmaps off, oversampling=0.
# oversampling=0 inherits the viewport, and under stretch mode "canvas_items"
# text is already rasterized at physical resolution (measured at 4K against a
# bilinear 2x upscale). These params interact with canvas_items + aspect="expand"
# at non-1080p sizes: do not change one as part of a theme edit.
#
# Not styled on purpose: base Control focus ring; Tree / ItemList / TabContainer
# (the game uses none).
# ============================================================================

## Bump in the SAME commit as any token or build_theme.gd edit, then re-run the
## generator. main.gd warns at boot (debug builds) when the baked stamp differs.
const THEME_STAMP := 25

# ============================================================================
# PALETTE — every colour in the game lives here. Format: NAME := value # hex · role
# Cream paper body inside a dark chrome frame. Amber is the single accent: ACCENT
# fills, ACCENT_DEEP is amber text and rules on cream. Green/red are reserved for
# meaning.
# ============================================================================

# --- SURFACE · chrome (topbar · ticker) ---
const BG_TOPBAR := Color(0.027, 0.035, 0.043, 1)   # #07090B · chrome ground
const BG_NEWS := Color(0.027, 0.035, 0.043, 1)     # #07090B · ticker (same ground as chrome)
const BG_AVATAR := Color(0.106, 0.137, 0.169, 1)   # #1B232B · avatar disc

# --- SURFACE · page body ---
const BG_BODY := Color(0.965, 0.945, 0.902, 1)     # #F6F1E6 · page ground
const BG_PANEL := Color(0.925, 0.898, 0.839, 1)    # #ECE5D6 · left rail
const CARD_BG := Color(0.984, 0.969, 0.933, 1)     # #FBF7EE · cards / panels / rows / windows
const CARD_ATTENTION_BG := Color(NEGATIVE, 0.06)   # rgba(155,59,40,.06) · attention strip fill
const CARD_FLOATING_BG := Color(CARD_BG, 0.98)     # card floating over the body (BuildHUD)

# --- SURFACE · control states ---
# Hover is EDGE emphasis, never a filled rect: SURFACE_HOVER equals the resting
# card fill and a visible hover reaches for BORDER_HOVER.
const SURFACE_INPUT := Color(1.0, 0.980, 0.941, 1)       # #FFFAF0 · input fill
const SURFACE_HOVER := CARD_BG                            # #FBF7EE · hover keeps the resting fill
const SURFACE_PRESSED := Color(0.937, 0.910, 0.855, 1)   # #EFE8DA · pressed / active key
const SURFACE_DISABLED := Color(0.937, 0.910, 0.855, 1)  # #EFE8DA · disabled button fill
const SURFACE_SUNKEN := Color(0.890, 0.855, 0.788, 1)    # #E3DAC9 · meter track
## Kadro tablosunda tabanı taşıyan satırın ve toplantı panelinin başlığının zemini: CARD_BG'den
## bir tık koyu, çünkü ikisi de altındakinin "üstü" olarak okunmalı.
const SURFACE_ROW_TINT := Color(0.945, 0.918, 0.859, 1)  # #F1EADB · defterin taban satırı · toplantı başlığı
const SURFACE_FRAME := Color(0.937, 0.910, 0.855, 1)     # #EFE8DA · inset / chip plate
const SHADOW_SOFT := Color(0.169, 0.153, 0.133, 0.18)    # rgba(43,39,34,.18) · floating card + window shadow
const SHADOW_MODAL := Color(0, 0, 0, 0.60)               # decision-modal drop shadow over the scrim

# --- INK · text on the cream body ---
const INK := Color(0.169, 0.153, 0.133, 1)         # #2B2722 · primary text / values / names
const INK_MUTED := Color(0.357, 0.329, 0.290, 1)   # #5B544A · secondary / prose
const INK_DIM := Color(0.541, 0.506, 0.459, 1)     # #8A8175 · column headers, labels, idle
const INK_FAINT := Color(0.663, 0.620, 0.557, 1)   # #A99E8E · stat captions, units, locked telegraph
const ON_INK := BG_BODY                            # #F6F1E6 · text ON an INK fill (the founder's speech bubble)

# --- CREAM · text on the dark frame and the dark cinematic register ---
const CREAM := Color(0.910, 0.929, 0.949, 1)       # #E8EDF2 · values/names on dark
const CREAM_DIM := Color(0.455, 0.510, 0.561, 1)   # #74828F · captions/labels on dark
const CREAM_DIM_DISABLED := Color(CREAM_DIM, 0.40) # disabled text on dark

# --- ACCENT · amber, the single accent ---
const ACCENT := Color(0.957, 0.769, 0.188, 1)          # #F4C430 · fills: CTA, badge, bars
const ACCENT_HOVER := Color(0.965, 0.816, 0.349, 1)    # #F6D059 · CTA hover  # WORKING (mockups show no hover)
const ACCENT_PRESSED := Color(0.843, 0.675, 0.165, 1)  # #D7AC2A · CTA pressed # WORKING
const ACCENT_DIM := Color(0.118, 0.153, 0.188, 1)      # #1E2730 · amber-keyed fill ON chrome (active speed btn)
const ACCENT_DEEP := Color(0.604, 0.416, 0.071, 1)     # #9A6A12 · amber TEXT and rules on cream
const AMBER_BG := Color(0.604, 0.416, 0.071, 0.10)     # rgba(154,106,18,.10) · amber chip fill
const AMBER_WASH := Color(0.604, 0.416, 0.071, 0.06)   # rgba(154,106,18,.06) · selected-card wash
const ON_ACCENT := Color(0.169, 0.153, 0.133, 1)   # #2B2722 · text ON the amber fill

# --- STATE · semantic. Green/red carry MEANING ONLY; they are the pair the
# colourblind toggle swaps, so they are read through the accessors below. ---
const POSITIVE := Color(0.184, 0.420, 0.227, 1)          # #2F6B3A
const POSITIVE_BG := Color(0.863, 0.922, 0.827, 1)       # #DCEBD3
const POSITIVE_RULE := Color(POSITIVE, 0.45)             # chip border
const NEGATIVE := Color(0.608, 0.231, 0.157, 1)          # #9B3B28
const NEGATIVE_BG := Color(0.953, 0.851, 0.816, 1)       # #F3D9D0
const NEGATIVE_RULE := Color(NEGATIVE, 0.45)             # chip border
const POSITIVE_BRIGHT := Color(0.247, 0.839, 0.549, 1)   # #3FD68C · on the dark frame
const NEGATIVE_BRIGHT := Color(1.0, 0.361, 0.286, 1)     # #FF5C49 · on the dark frame

# --- STATE · colourblind-safe counterparts (Settings > Erişilebilirlik) ---
# Blue/orange survives all three dichromacies while green/red survives none
# (Okabe-Ito hues, deepened to read as text on cream; the *_BRIGHT_CB pair keeps
# screen brightness for the dark frame). Only the pair moves: amber already reads
# as amber to a dichromat, so ACCENT stays put.
# ALL # WORKING — Erdem's F5 seals the hues.
const POSITIVE_CB := Color(0.173, 0.435, 0.682, 1)        # #2C6FAE · blue
const POSITIVE_BG_CB := Color(0.851, 0.898, 0.941, 1)     # #D9E5F0
const POSITIVE_RULE_CB := Color(POSITIVE_CB, 0.45)
const NEGATIVE_CB := Color(0.702, 0.420, 0.0, 1)          # #B36B00 · orange
const NEGATIVE_BG_CB := Color(0.945, 0.894, 0.820, 1)     # #F1E4D1
const NEGATIVE_RULE_CB := Color(NEGATIVE_CB, 0.45)
const POSITIVE_BRIGHT_CB := Color(0.337, 0.706, 0.914, 1) # #56B4E9 · on the dark frame
const NEGATIVE_BRIGHT_CB := Color(0.902, 0.624, 0.0, 1)   # #E69F00 · on the dark frame
const DOT_IDLE := Color(0.769, 0.718, 0.624, 1)          # #C4B79F · unearned milestone dot  # WORKING

# --- BADGE / CHIP ---
const BADGE_BG := Color(0.957, 0.769, 0.188, 1)          # #F4C430 · count badge (amber pill)
const BADGE_FG := Color(0.169, 0.153, 0.133, 1)          # #2B2722 · text on the amber badge
const NEUTRAL_BADGE_BG := Color(0.937, 0.910, 0.855, 1)  # #EFE8DA · neutral chip plate
const NEUTRAL_BADGE_FG := Color(0.357, 0.329, 0.290, 1)  # #5B544A · neutral chip text
const TAB_ACTIVE_BG := Color(0.984, 0.969, 0.933, 1)     # #FBF7EE · active rail tile fill

# --- EDGE · borders, dividers, hairlines ---
const CARD_BORDER := Color(0.851, 0.816, 0.749, 1)       # #D9D0BF · 1px card border
const BORDER_HOVER := Color(0.769, 0.718, 0.624, 1)      # #C4B79F · hover/ghost edge
const CARD_ATTENTION_BORDER := Color(NEGATIVE, 0.45)   # rgba(155,59,40,.45) · attention-strip edge
const BORDER_DISABLED := Color(0.851, 0.816, 0.749, 1)   # #D9D0BF · disabled control edge
const BORDER_DASHED := Color(0.851, 0.816, 0.749, 1)     # #D9D0BF · empty-slot edge
const DIVIDER_LIGHT := Color(0.890, 0.855, 0.788, 1)     # #E3DAC9 · in-card hairline
const SEPARATOR := Color(0.106, 0.137, 0.169, 1)         # #1B232B · chrome hairline

# --- MEETING · the meeting dock on the cream body ---
# TUTUM is one needle on a cold-to-warm gradient. Its end stops are too pale to be text,
# so the band word reads a darker twin of the same hue (≥4.5:1 on BG_BODY and on the
# header's SURFACE_ROW_TINT); the middle bands read the body's own inks (attitude_ink).
const ATTITUDE_COLD := Color(0.624, 0.702, 0.784, 1)       # #9FB3C8 · gradient cold stop
const ATTITUDE_MID := Color(0.851, 0.804, 0.706, 1)        # #D9CDB4 · gradient middle stop
const ATTITUDE_WARM := Color(0.878, 0.576, 0.353, 1)       # #E0935A · gradient warm stop
const ATTITUDE_COLD_INK := Color(0.310, 0.416, 0.522, 1)   # #4F6A85 · "cold" word
const ATTITUDE_WARM_INK := Color(0.690, 0.290, 0.149, 1)   # #B04A26 · "warm" word
# The other side's seats in MeetingCast order: portrait ring and transcript name ink, so
# each is dark enough to be text on the body.
const MEETING_SEAT_1 := Color(0.541, 0.353, 0.169, 1)      # #8A5A2B · lead / buyer
const MEETING_SEAT_2 := Color(0.478, 0.247, 0.353, 1)      # #7A3F5A · partner / user lead
const MEETING_SEAT_3 := Color(0.247, 0.435, 0.478, 1)      # #3F6F7A · analyst / finance

# --- CHROME · the frame's own values ---
# Twins pinned to what the frame shows, so a body reskin never moves the frame. The
# dark cinematic register reads them as well: its stages keep the frame's palette.
const ACCENT_CHROME := Color(1.0, 0.627, 0.157, 1)          # #FFA028 · accent of the dark registers (onboarding, dialogue, emblem)
const ACCENT_HOVER_CHROME := Color(1.0, 0.698, 0.353, 1)    # #FFB25A · CommitButtonDark hover  # WORKING
const ACCENT_PRESSED_CHROME := Color(0.878, 0.541, 0.110, 1)  # #E08A1C · CommitButtonDark pressed # WORKING
const INK_MUTED_CHROME := Color(0.624, 0.690, 0.749, 1)     # #9FB0BF · idle speed key, hover text
const INK_DIM_CHROME := Color(0.337, 0.392, 0.439, 1)       # #566470 · idle speed key text
const INK_FAINT_CHROME := Color(0.275, 0.322, 0.365, 1)     # #46525D · TopBar captions + units
const CARD_BORDER_CHROME := Color(0.137, 0.173, 0.204, 1)   # #232C34 · idle speed key edge
const BORDER_HOVER_CHROME := Color(0.165, 0.204, 0.239, 1)  # #2A343D · idle speed key, hover edge
const DOT_IDLE_CHROME := Color(0.350, 0.320, 0.270, 1)      # #595245 · unreached phase dot
const VEIL_FAINT_CHROME := Color(1, 1, 1, 0.03)   # at-rest / disabled tint on dark
const VEIL_SOFT_CHROME := Color(1, 1, 1, 0.06)    # normal / pressed on dark

# --- Cinematic dialogue register ---
# Text on these surfaces uses CREAM* / *_BRIGHT. # WORKING — Erdem's F5 seals.
const SCRIM_MODAL := Color(0.020, 0.027, 0.035, 0.62)  # rgba(5,7,9,.62) · modal dimmer
# The founder's road on the city map to and from a meeting: cream dashes on a dark casing.
const ROAD_CASING := Color(0.169, 0.153, 0.133, 0.55)  # #2B2722 .55 · road casing
const ROAD_DASH := Color(1.0, 0.980, 0.941, 1)         # #FFFAF0 · road dashes
const DIALOGUE_BG := Color(0.063, 0.086, 0.110, 1)   # #10161C · modal / Frank card ground
const DIALOGUE_COLUMN_BG := Color(0.063, 0.086, 0.110, 0.92)  # floating column (art shows through)
const DIALOGUE_CARD_BG := Color(0.059, 0.078, 0.102, 1)       # #0F141A · choice / quote card (recessed)
const DIALOGUE_CARD_BORDER := Color(0.137, 0.173, 0.204, 1)   # #232C34 · card hairline
const CONVICTION_TRACK_BG := Color(0.137, 0.173, 0.204, 1)    # #232C34 · unlit dot / segment groove
const PORTRAIT_FRAME := Color(0.910, 0.929, 0.949, 1)         # #E8EDF2 · portrait rule

# --- Newspaper ending register ("Ekonomi Postası") ---
# DELIBERATE ISLAND: the paper is newsprint with its OWN ink ladder, so a body
# reskin never reaches it.
# # WORKING — Erdem's F5 seals the final hues.
const PAPER_BG := Color(0.937, 0.914, 0.863, 1)     # #EFE9DC · newsprint
const PAPER_EDGE := Color(0.227, 0.204, 0.165, 1)   # #3A342A · sheet border
const PAPER_RULE := Color(0.165, 0.141, 0.110, 1)   # #2A241C · masthead + section rules
const PAPER_INK := Color(0.149, 0.125, 0.098, 1)      # #262019 · headline
const PAPER_INK_BODY := Color(0.243, 0.212, 0.169, 1) # #3E362B · body copy
const PAPER_INK_DECK := Color(0.420, 0.384, 0.322, 1) # #6B6252 · deck / italic standfirst
const PAPER_INK_MAST := Color(0.290, 0.259, 0.220, 1) # #4A4238 · masthead
const PAPER_INK_META := Color(0.596, 0.557, 0.482, 1) # #988E7B · dateline / captions
const PAPER_PLATE := Color(0.890, 0.859, 0.792, 1)    # #E3DBCA · gazete üstündeki boş gravür plakası

# ============================================================================
# TYPE SCALE — the ONLY sizes new UI may reach for.
# ============================================================================
# The SCALE owns size and leading; the VARIATION owns face and colour. Label
# variations differ by register, not by size, so a scale that also owned the
# typeface would stop being a scale. A variation MAY choose another face but may
# NEVER override its step's size. Mockup half-steps (8.5 / 9.5 / 10.5 …) are
# rounded half-up; the ordering survives the rounding.
#
#   token         px   voice (measured site)
#   SIZE_MICRO     9   chip 8.5, phase caption 9
#   SIZE_META     10   column headers 9.5, rail labels 10, chips 10
#   SIZE_SMALL    11   section headers 10.5, ticker 11, title-row summary 11
#   SIZE_DATA     12   primary CTA 11.5, empty rows 12, clock 12, inputs
#   SIZE_BODY     13   prose 12.5-13, card names 13
#   SIZE_LEAD     15   TopBar + month-summary figures 15
#   SIZE_TITLE    16   card / context serif titles, meeting transcript line
#   SIZE_DISPLAY  22   Ayarlar + secondary page titles
const SIZE_MICRO := 9
const SIZE_META := 10
const SIZE_SMALL := 11
const SIZE_DATA := 12
const SIZE_BODY := 13
const SIZE_LEAD := 15
const SIZE_TITLE := 16
const SIZE_DISPLAY := 22

# --- Editorial display tier — a documented EXCEPTION, not extra scale steps ---
# Typographic set pieces composed against a fixed page, not part of the reading
# rhythm. Any size above SIZE_DISPLAY must be named here.
const SIZE_ED_MODAL := 24       # modal titles (event · Atlas · month summary)
const SIZE_ED_CEREMONY := 26    # PAGE titles (Ekip / Portföy / Finans / Sales …); onboarding
const SIZE_ED_HEADLINE := 32    # newspaper headline; path-card display; meeting speaker name
const SIZE_ED_FIGURE := 44      # newspaper stat figures "$1.2M"
const SIZE_ED_MASTHEAD := 52    # "EKONOMİ POSTASI"

# --- Leading ---
# Label has no line_height: its line box is the font's ascent+descent plus the
# theme constant `line_spacing`; RichTextLabel uses `line_separation`. Both are
# pinned at the engine defaults so they cannot drift with Godot's default theme.
# Raising one changes the height of every wrapping Label — a layout change.
const LEADING_BODY := 3         # == engine default
const LEADING_RICH := 0         # RichTextLabel line_separation; == engine default

# Display sizes written in screen code that predate the scale are left in place;
# new code picks a scale step.

# ============================================================================
# SPACING + SHAPE
# ============================================================================
# 4-based; 6 is the one sanctioned half-step (dense data rows). Existing literals in
# scenes and scripts migrate only when the surrounding lines change.
const SPACE_XXS := 2
const SPACE_XS := 4
const SPACE_S := 6
const SPACE_M := 8
const SPACE_L := 12
const SPACE_XL := 16
const SPACE_XXL := 20
const SPACE_3XL := 24
const SPACE_4XL := 32

# --- Corner radii ---
# Radius 2 for everything that is not a pill or a window; the named steps are
# kept so call sites keep reading their role. StyleBoxFlat clamps a radius to half
# the box, so RADIUS_PILL is a true circle or pill at any size.
const RADIUS_NONE := 0          # full-bleed chrome bands, rails, sunken tracks, focus killers
const RADIUS_XS := 2            # dots, thin bars
const RADIUS_S := 2             # chips, progress bars, speed buttons, sliders
const RADIUS_M := 2             # DEFAULT — cards, buttons, inputs
const RADIUS_L := 2             # modals, portrait cells
const RADIUS_XL := 2            # dialogue choice cards, tab badge
const RADIUS_XXL := 2           # dialogue column
const RADIUS_PILL := 999        # toggle, rail badge, avatar
const RADIUS_PORTRAIT := 2      # PortraitFrame
const RADIUS_CARD_LG := 2       # DialogueCard
const RADIUS_WINDOW := 4        # window frame, rail tiles

# --- Border widths ---
const BORDER_HAIRLINE := 1      # cards, inputs, chips, tooltip
const BORDER_FOCUS := 2         # selection ring (PortraitCellSelected), ActionRow hover rule
const BORDER_ACCENT := 3        # left accent bar (QuoteBox)

# --- StyleBox content-margin pairs (h, v) — build_theme.gd only ---
const PAD_CHIP := Vector2i(6, 2)          # UiFactory chip
const PAD_BTN_XS := Vector2i(8, 3)        # SpeedButton / TabButton
const PAD_DIAL := Vector2i(8, 4)          # StanceDial
const PAD_BTN_S := Vector2i(10, 4)        # DialogueStepper
const PAD_BTN_GHOST := Vector2i(10, 5)    # DialogueGhost
const PAD_INPUT := Vector2i(10, 6)        # LineEdit
const PAD_BTN := Vector2i(12, 6)          # base Button
const PAD_CHOICE := Vector2i(12, 8)       # ChoiceCard family
const PAD_INPUT_LG := Vector2i(12, 9)     # DialogueInput (ceremony-scale field)
const PAD_CARD_TIGHT := Vector2i(10, 8)   # CardPanelTight
const PAD_CARD := Vector2i(12, 10)        # CardPanel / CardCta / CardAttention
const PAD_STRIP := Vector2i(12, 6)        # HeaderBand (same value as PAD_BTN, kept apart by role)
const PAD_BAND := Vector2i(14, 8)         # AttentionStrip
const PAD_ROW := Vector2i(14, 10)         # QuoteBox / DialogueChoice / MeetingFounderBubble
const PAD_CARD_RAIL := Vector2i(14, 12)   # RailCard
const PAD_MEETING_HEADER := Vector2i(16, 14)  # MeetingHeader
const PAD_MEETING_DECK := Vector2i(16, 12)    # MeetingDeck
const PAD_CTA := Vector2i(16, 10)         # CommitButton(Dark)
const PAD_ACTION_ROW := Vector2i(16, 0)   # ActionRow (the host sets the row height)
const PAD_TOOLTIP := Vector2i(8, 4)       # tooltip panel
const PAD_RAIL := Vector2i(20, 20)        # RailPanel
const PAD_PAGE := Vector2i(28, 22)        # ModalCard / WindowFrame
const PAD_SHEET := Vector2i(44, 36)       # PaperPanel
const PAD_FRAME := Vector2i(4, 4)         # PortraitFrame hairline inset
const PAD_CELL := Vector2i(3, 3)          # PortraitCell

# --- Rail tabs — canonical 8-tab list ---
# No `label` or `icon` field: the rail caption is the key TAB_ + ID.to_upper(), shared by
# LeftTabs.tscn and window_layer, and the icon lives only in LeftTabs.tscn, which
# draws it. LeftTabs.tscn's button order must match this
# array position-for-position (smoke `rail_tabs_match_scene_order`).
# `lock` names a gate for a visible-but-unreachable tab, resolved in
# LeftTabs._is_locked so UiTokens stays free of game state. The rail shows its icon
# and name off with the reason under the name. "ea" = Early Access scope, never opens
# in the demo; a lock means only "not in this build", so Ar-Ge (built, gated on its own
# page) carries no lock.
const TABS := [
	{"id": "product"},
	{"id": "sales"},
	{"id": "hr"},
	{"id": "finance"},
	{"id": "personal"},
	{"id": "marketing", "lock": "ea"},
	{"id": "rnd"},
	{"id": "events"},
]

## A muted sub-tab or a locked line fades as a whole.
const TAB_LOCKED_ALPHA := 0.45

# ============================================================================
# SEMANTIC PALETTE SWITCH — the accessibility swap (Settings > Erişilebilirlik).
# ============================================================================
# Semantic colour is never baked into master_theme.tres, so switching palettes is
# a pure runtime re-read. Read semantic colour through the ACCESSOR
# (`UiTokens.positive()`), never the const: a site that reaches for the const is
# invisible to the toggle. Live surfaces repaint on EventBus.palette_changed.
static var _cb_palette: bool = false

## Settings applies this at boot and on every toggle. It does NOT emit the signal —
## the caller owns that, exactly as Localization owns language_changed.
static func set_colorblind(on: bool) -> void:
	_cb_palette = on

static func is_colorblind() -> bool:
	return _cb_palette

static func positive() -> Color:
	return POSITIVE_CB if _cb_palette else POSITIVE

static func negative() -> Color:
	return NEGATIVE_CB if _cb_palette else NEGATIVE

static func positive_bg() -> Color:
	return POSITIVE_BG_CB if _cb_palette else POSITIVE_BG

static func negative_bg() -> Color:
	return NEGATIVE_BG_CB if _cb_palette else NEGATIVE_BG

static func positive_bright() -> Color:
	return POSITIVE_BRIGHT_CB if _cb_palette else POSITIVE_BRIGHT

static func negative_bright() -> Color:
	return NEGATIVE_BRIGHT_CB if _cb_palette else NEGATIVE_BRIGHT

## Çip kenarları da semantiktir: dolgu takas olup kenar sabit kalsaydı renk körü
## modunda çip iki paletten karışık okunurdu.
static func positive_rule() -> Color:
	return POSITIVE_RULE_CB if _cb_palette else POSITIVE_RULE

static func negative_rule() -> Color:
	return NEGATIVE_RULE_CB if _cb_palette else NEGATIVE_RULE

# ============================================================================
# Runtime colour-decision helpers — the single home for sign/kind → colour.
# All route through the accessors, so they inherit the palette swap.
# ============================================================================

## Delta color for body surfaces.
static func delta_color(value: int) -> Color:
	if value > 0: return positive()
	if value < 0: return negative()
	return INK_MUTED

## {bg, fg} for a tinted chip. kind: "positive" | "negative" | "neutral" | "accent" | "attention".
static func badge_palette(kind: StringName) -> Dictionary:
	match kind:
		&"positive": return {"bg": positive_bg(), "fg": positive()}
		&"negative": return {"bg": negative_bg(), "fg": negative()}
		&"accent":   return {"bg": AMBER_BG, "fg": ACCENT_DEEP}
		&"attention": return {"bg": BADGE_BG, "fg": BADGE_FG}
		_: return {"bg": NEUTRAL_BADGE_BG, "fg": NEUTRAL_BADGE_FG}

## {bg, fg} chip palette chosen from a signed delta.
static func badge_palette_for_delta(value: int) -> Dictionary:
	if value > 0: return badge_palette(&"positive")
	if value < 0: return badge_palette(&"negative")
	return badge_palette(&"neutral")

## A meeting option's die: at or above SAFE its chance reads safe, at or above RISKY risky,
## below that dangerous. The option shows only the word; the % lives in its tooltip.
const RISK_SAFE_MIN := 0.62   # WORKING
const RISK_RISKY_MIN := 0.40  # WORKING
## Edge between the cold and wary TUTUM words. It sits under both meetings' lukewarm edge and
## no rule reads it: the band is a word, the outcome stays the systems' own thresholds.
const ATTITUDE_WARY_MIN := 25  # WORKING


## Risk word key for a die's chance (0.0-1.0).
static func risk_key(chance: float) -> String:
	if chance >= RISK_SAFE_MIN: return "MEETING_RISK_SAFE"
	if chance >= RISK_RISKY_MIN: return "MEETING_RISK_RISKY"
	return "MEETING_RISK_DANGER"


## Ink of the risk word, on risk_key's edges.
static func risk_ink(chance: float) -> Color:
	if chance >= RISK_SAFE_MIN: return positive()
	if chance >= RISK_RISKY_MIN: return ACCENT_DEEP
	return negative()


## TUTUM band of a 0-100 attitude: "warm" | "lukewarm" | "wary" | "cold". The warm and
## lukewarm edges are the meeting's own rule values, passed in by its adapter.
static func attitude_band(value: int, warm_min: int, lukewarm_min: int) -> String:
	if value >= warm_min: return "warm"
	if value >= lukewarm_min: return "lukewarm"
	if value >= ATTITUDE_WARY_MIN: return "wary"
	return "cold"


## Key of the TUTUM word for an attitude_band band.
static func attitude_word_key(band: String) -> String:
	return "MEETING_ATT_" + band.to_upper()


## Ink of the TUTUM word for an attitude_band band.
static func attitude_ink(band: String) -> Color:
	match band:
		"warm": return ATTITUDE_WARM_INK
		"lukewarm": return ACCENT_DEEP
		"wary": return INK_MUTED
		_: return ATTITUDE_COLD_INK


## Portrait ring of a meeting seat: 0 is the founder, 1-3 the other side in MeetingCast order.
static func seat_ring(seat: int) -> Color:
	match seat:
		0: return ACCENT
		1: return MEETING_SEAT_1
		2: return MEETING_SEAT_2
		_: return MEETING_SEAT_3


## A seat's name as text on the cream dock: the founder's amber ring is too pale to read, so the
## founder takes the deep amber.
static func seat_ink(seat: int) -> Color:
	return ACCENT_DEEP if seat == 0 else seat_ring(seat)


## Ink of a die factor on the dark tooltip, by its tone: "pos" | "neg" | anything else neutral.
static func tooltip_tone_ink(tone: String) -> Color:
	match tone:
		"pos": return positive_bright()
		"neg": return negative_bright()
	return CREAM


# Formatting delegates kept for their existing call sites; the bodies live in Fmt,
# which owns the locale's separators. New code may call Fmt directly.
static func format_money(amount: int) -> String:
	return Fmt.money(amount)


## Exact, thousands-grouped money. CASH is shown in full because money management is precise.
static func format_money_exact(value: int) -> String:
	return Fmt.money_exact(value)


## Kept for existing callers; new code calls Fmt.upper.
static func tr_upper(s: String) -> String:
	return Fmt.upper(s)


## Net-runway display parts {value, unit, positive, note} — the single home for the
## months-vs-status decision (TopBar, Finance tab, HR previews, month-end summary).
## Uses TranslationServer because statics can't call tr(). `positive` lets a caller
## colour the status green; `note` explains why no month figure is shown.
static func net_runway_parts(months: float) -> Dictionary:
	# Empty treasury first: runway_months_for() answers INF for any non-negative daily
	# net without looking at cash, so a company at cash < 0 would otherwise be painted
	# a green "Artıda" next to a red bankruptcy countdown.
	if GameState.cash < 0:
		return {"value": "0", "unit": TranslationServer.translate("RUNWAY_UNIT_WEEKS"),
				"positive": false, "note": ""}
	if months == INF:
		return {"value": TranslationServer.translate("RUNWAY_PROFITABLE"), "unit": "",
				"positive": true, "note": TranslationServer.translate("RUNWAY_PROFITABLE_NOTE")}
	if months < 1.0:
		# Under a month a bare "0 ay" reads as insolvency; say it in weeks.
		return {"value": str(_runway_weeks(months)),
				"unit": TranslationServer.translate("RUNWAY_UNIT_WEEKS"),
				"positive": false, "note": ""}
	return {"value": str(int(round(months))), "unit": TranslationServer.translate("RUNWAY_UNIT_MONTHS"),
			"positive": false, "note": ""}


static func net_runway_text(months: float) -> String:
	var p: Dictionary = net_runway_parts(months)
	return String(p.value) if String(p.unit) == "" else "%s %s" % [p.value, p.unit]


## İki runway değeri yan yana ("önce → sonra" şeritleri). net_runway_text tam aya
## yuvarlar; iki sayı yan yana konduğunda bu, "5 ay → 5 ay" yazan bir yalan üretir. Ay
## metinleri aynı çıkıp hafta metinleri ayrışıyorsa ikisi de HAFTA'da yazılır. `changed`,
## ekrana basılan iki metnin farklı olmasıdır: aynı okunan çift kırmızıya boyanmaz.
static func net_runway_pair(before: float, after: float) -> Dictionary:
	var before_text: String = net_runway_text(before)
	var after_text: String = net_runway_text(after)
	if before_text == after_text and is_finite(before) and GameState.cash >= 0 \
			and _runway_weeks(before) != _runway_weeks(after):
		before_text = _runway_weeks_text(before)
		after_text = _runway_weeks_text(after)
	return {"before": before_text, "after": after_text, "changed": before_text != after_text}


static func _runway_weeks_text(months: float) -> String:
	return "%d %s" % [_runway_weeks(months), TranslationServer.translate("RUNWAY_UNIT_WEEKS")]


## Whole weeks of runway. floor(), not round(): a countdown must never promise a week the cash
## cannot cover.
static func _runway_weeks(months: float) -> int:
	return int(floor(maxf(months, 0.0) * TimeModel.DAYS_PER_MONTH / TimeModel.DAYS_PER_TICK))


## Build progress (0.0-1.0) as the whole percent every surface prints — the single
## home for that rounding, so the portfolio badge and the floating build card never
## disagree in one frame. Bars take build_percent(p) / 100.0, never the raw fraction.
static func build_percent(progress: float) -> int:
	return int(round(clampf(progress, 0.0, 1.0) * 100.0))


# ============================================================================
# MENAJER MASASI · the dark language. themes/menajer_theme.tres reads these tokens (and PAPER_*),
# and so does every screen whose root carries that theme; the cream tokens above stay with
# master_theme.tres. Names are roles, never grounds: surfaces darken from 5 to 0, inks lighten
# from 4 to 1. Amber fills only the one primary action and outlines only the time state, red is
# danger only, hover is a border and selected is ink. Colours with a colour-blind twin are read
# through the D_ helpers at the end of this block.
# ============================================================================
const MENAJER_THEME := "res://themes/menajer_theme.tres"

# --- surfaces: warm charcoal ---
const D_SURFACE_0 := Color("#100E0B")   # ground: ticker, tooltip, page
const D_SURFACE_1 := Color("#15120F")   # chrome: top bar, rail
const D_SURFACE_2 := Color("#1A1714")   # inset: inbox list, sticky table head, input field
const D_SURFACE_3 := Color("#1E1B18")   # window body
const D_SURFACE_4 := Color("#27231F")   # raised: window header, selected row, time block, menu, stake box
const D_SURFACE_5 := Color("#2E2924")   # control fill: idle speed key, count badge, switch track

# --- lines ---
const D_LINE_1 := Color("#3A342D")       # rules and separators
const D_LINE_2 := Color("#4A4239")       # component borders: window, outline button, input, tracks
const D_LINE_3 := Color("#6A5F52")       # strong outline: tag, relation chip, scrollbar thumb
const D_LINE_HOVER := Color("#958C7E")   # the hover border
const D_ROW_RULE := Color(D_LINE_1, 0.75)   # data row separator

# --- ink ---
const D_INK_1 := Color("#FFFFFF")    # emphasis: cash, window title, row name, active label
const D_INK_2 := Color("#E9E4DA")    # primary text
const D_INK_3 := Color("#B3AA9E")    # secondary: keys, column heads, idle rail name
const D_INK_4 := Color("#9A9184")    # tertiary: idle rail icon, rail lock reason
const D_INK_OFF := Color("#6B6358")  # a disabled or locked label or glyph, never a reason

# --- accent ---
const D_ACCENT := Color("#F2B53A")
const D_ACCENT_HOVER := Color("#F7C65F")
const D_ACCENT_PRESSED := Color("#DDA12D")
const D_ON_ACCENT := Color("#17130A")       # text and glyph on amber
const D_ACCENT_GLOW := Color(D_ACCENT, 0.24)   # the ring around a waiting-decision dot

# --- meaning: gain, danger, attention, notice ---
const D_POS := Color("#4FD27A")
const D_NEG := Color("#EC6A5E")
const D_WARN := Color("#E8913A")
const D_INFO := Color("#8CC2EC")
const D_NEG_BG := Color("#2B1A17")       # danger strip fill
const D_NEG_LINE := Color("#6E3129")     # danger strip border
const D_NEG_INK := Color("#F4A39A")      # soft danger text on the strip or in a risk tag
const D_NEG_TAG_BG := Color(D_NEG, 0.16)
const D_NEG_TAG_LINE := Color(D_NEG, 0.60)
const D_POS_TAG_BG := Color(D_POS, 0.12)
const D_POS_TAG_LINE := Color(D_POS, 0.55)
const D_POS_INK := Color("#8FE3A8")      # soft gain text in a gain tag
const D_WARN_TAG_BG := Color(D_WARN, 0.12)
const D_WARN_TAG_LINE := Color(D_WARN, 0.55)
const D_ON_NEG := Color("#1B0F0D")       # text on a solid danger badge
# Colour-blind twins: gain blue, danger vermilion, attention pale yellow, notice pale blue.
const D_POS_CB := Color("#56B4E9")
const D_NEG_CB := Color("#F07A3C")
const D_WARN_CB := Color("#F6EA85")
const D_INFO_CB := Color("#C0E2F6")
const D_NEG_BG_CB := Color("#2E1D12")
const D_NEG_LINE_CB := Color("#7A4522")
const D_NEG_INK_CB := Color("#F7B48C")
const D_NEG_TAG_BG_CB := Color(D_NEG_CB, 0.16)
const D_NEG_TAG_LINE_CB := Color(D_NEG_CB, 0.60)
const D_POS_TAG_BG_CB := Color(D_POS_CB, 0.12)
const D_POS_TAG_LINE_CB := Color(D_POS_CB, 0.55)
const D_POS_INK_CB := Color("#A6D6F5")
const D_WARN_TAG_BG_CB := Color(D_WARN_CB, 0.10)
const D_WARN_TAG_LINE_CB := Color(D_WARN_CB, 0.50)
const D_ON_NEG_CB := Color("#1F1206")

# --- skill values: luminance rises with the value in both palettes ---
const D_SKILL_1 := Color("#A09789")   # 1-2
const D_SKILL_2 := Color("#B4AB9B")   # 3-4
const D_SKILL_3 := Color("#C9C3B4")   # 5-6
const D_SKILL_4 := Color("#BCDF72")   # 7-8
const D_SKILL_5 := Color("#86F7A0")   # 9-10
const D_SKILL_4_CB := Color("#A3D2F7")
const D_SKILL_5_CB := Color("#D4EEFF")
const D_ROLE_BAND := Color(D_INK_2, 0.05)   # a role's columns inside its group

# --- topic pills: a hue border and the hue at D_PILL_FILL_ALPHA as fill ---
const D_TOPIC_MENTOR := Color("#C9A8E6")
const D_TOPIC_CUSTOMER := Color("#6FC9B6")
const D_TOPIC_TEAM := Color("#7FB6DE")
const D_TOPIC_PRODUCT := Color("#9EB18C")
const D_TOPIC_FUNDING := Color("#E6A2C2")
const D_TOPIC_MARKET := Color("#D4BD8E")
const D_TOPIC_AGENDA := D_INK_3   # the generic topic stays neutral, in both palettes
const D_TOPIC_MENTOR_CB := Color("#A985E0")
const D_TOPIC_CUSTOMER_CB := Color("#B6EDED")
const D_TOPIC_TEAM_CB := Color("#85C5E0")
const D_TOPIC_PRODUCT_CB := Color("#B6D175")
const D_TOPIC_FUNDING_CB := Color("#C9945E")
const D_TOPIC_MARKET_CB := Color("#DAC7A9")
const D_PILL_FILL_ALPHA := 0.12
const D_GONE_ALPHA := 0.55   # a mail from someone who has left: the avatar fades

# --- ticker outlets ---
const D_OUTLET_SEKTOR := Color("#7FB6DE")
const D_OUTLET_EKONOMI := Color("#E6A2C2")
const D_OUTLET_TEKNOGUNDEM := Color("#6FC9B6")
const D_OUTLET_GIRISIM := Color("#C2ABEA")
const D_OUTLET_SEKTOR_CB := Color("#85C5E0")
const D_OUTLET_EKONOMI_CB := Color("#C9945E")
const D_OUTLET_TEKNOGUNDEM_CB := Color("#B6EDED")
const D_OUTLET_GIRISIM_CB := Color("#A985E0")

# --- charts and bars: ink based, red only below zero ---
const D_CHART_GRID := Color("#2F2A25")
const D_CHART_AXIS := D_LINE_3
const D_CHART_LINE := D_INK_2
const D_CHART_PROJ := D_INK_4
const D_CHART_NEG_AREA := Color(D_NEG, 0.12)
const D_CHART_NEG_AREA_CB := Color(D_NEG_CB, 0.12)
const D_CHART_POS_AREA := Color(D_INK_2, 0.05)
const D_BAR_TRACK := D_LINE_1
const D_BAR_FILL := D_INK_3   # progress that is neither good nor bad
const D_BAR_EMPH := D_INK_2   # the one share a part-to-whole bar highlights

# --- state and overlay ---
const D_FOCUS := D_INK_1           # the keyboard focus ring
const D_SELECTED_MARK := D_INK_1   # the marker on a selected row's left edge
const D_SCRIM := Color(Color("#0A0806"), 0.62)   # true modals only
const D_HALO := Color(Color("#0A0806"), 0.66)    # a window's shadow
const D_SHADOW_FLOAT := Color(0, 0, 0, 0.42)
const D_SHADOW_TOOLTIP := Color(0, 0, 0, 0.45)

# --- portraits: the ink-outlined busts need a lit ground on charcoal ---
const D_PORTRAIT_LIT := Color("#574B3F")    # radial centre behind the head
const D_PORTRAIT_EDGE := Color("#2A2520")   # radial edge
const D_AV_RIM := D_LINE_3

# --- desk motif: a document has its top-right corner cut, a finished one is stamped ---
const D_STAMP := D_INK_3
const D_CUT := 12      # document corner bevel
const D_CUT_SM := 8    # small documents: toast, notice, selected inbox row

# --- the brand square of the top bar: the logo's own orange, not a UI accent ---
const D_BRAND_MARK := Color("#FFA028")

# --- newspaper island: cream in both themes; the dark theme's meta line reads at 4.5:1 ---
const D_PAPER_INK_META := Color("#6E6553")

# --- type ladder: twelve steps named by size; a dark variation picks one ---
const D_FS_12 := 12
const D_FS_13 := 13
const D_FS_14 := 14
const D_FS_15 := 15
const D_FS_16 := 16
const D_FS_18 := 18
const D_FS_20 := 20
const D_FS_22 := 22
const D_FS_26 := 26
const D_FS_30 := 30
const D_FS_36 := 36
const D_FS_40 := 40
# The newspaper keeps its own set pieces above the ladder.
const D_PAPER_FS_HEADLINE := 32
const D_PAPER_FS_FIGURE := 44
const D_PAPER_FS_MASTHEAD := 52
# A Label line is its face's own height; paragraphs and Frank's quotes add D_LEADING_PARA.
const D_LEADING := 0
const D_LEADING_PARA := 2

# --- shape ---
const D_RADIUS_1 := 2   # tracks, markers, a document's three straight corners
const D_RADIUS_2 := 4   # buttons, tags, inputs, speed keys, tooltip
const D_RADIUS_3 := 6   # floats, strips, option bar, portrait well, menu
const D_RADIUS_4 := 8   # windows
const D_MARK := Vector2i(3, 8)   # selected marker: width, inset from the row's top and bottom
# One shadow per box: (size, y offset).
const D_SHADOW_WINDOW := Vector2i(96, 12)
const D_SHADOW_FLOATING := Vector2i(20, 6)
const D_SHADOW_TIP := Vector2i(12, 4)

# --- control heights; the theme derives vertical content margins from them ---
const D_H_BTN := 40
const D_H_BTN_SM := 32
const D_H_BTN_LG := 56
const D_H_INPUT := 40
const D_H_SPEED_KEY := 32
const D_H_FLOAT_BTN := 44
const D_H_MENU_ITEM := 32
const D_H_TOOLTIP := 28
const D_H_STAMP := 26
const D_H_FX := 24
const D_H_TAG := 22
const D_H_PILL := 20
const D_H_BADGE := 20
const D_H_BADGE_ICON := 18   # a count on the corner of an icon (the rail's icon mode)
const D_H_LINK := 24         # a text link on a float card (the research card's pause and assign)
const D_H_PROGRESS := 6      # a progress track
const D_H_WIN_HEAD := 72     # a window's header band
# --- sizes the host lays out ---
const D_H_WIN_CTL := 56      # a window's control strip under its header
const D_H_HEAD := 36         # a table's head
const D_H_HEAD_TWO := 56     # a table's two-tier head (a span over a group of columns)
const D_H_TOAST := 48
const D_H_STAKE := 104       # a decision's stake box, at its least
const D_H_ROW := 40          # a table's data row
const D_H_ROW_SM := 32       # a compact table's data row
const D_H_ROW_LG := 44       # a row the player picks from (a training row), a menu row with its reason under it
const D_H_ROW_MATRIX := 48   # the job matrix's row
const D_H_SKILL_ROW := 30    # a skill's row in a person's file
const D_H_FACT_ROW := 28     # a fact's row on a candidate's file
const D_BOX_JOB := 24        # a job's box in the matrix
const D_BOX_JOB_SM := 20     # the matrix legend's sample box
const D_CHECK_DISC := 20     # the check disc on a picked card
const D_H_GROUP := 36        # a table's group header
const D_H_STRIP := 52        # a strip over a table (the risk strip)
const D_H_EMPTY_ROW := 52    # a group with nobody in it
const D_TOAST_WELL := 32     # the square behind a toast's glyph
const D_TRAIT_BOX := 24      # the square behind a trait's glyph
const D_AVATAR_ROW := 32     # a person's disc in a row or strip
const D_AVATAR_ROW_SM := 24  # a person's disc in a compact row
const D_AVATAR_DOC := 40     # a person's disc at the head of their file
const D_AVATAR_CARD := 48    # a candidate's disc on their file
const D_W_MORALE := 32       # the morale figure's column, right aligned, before its bar
const D_MORALE_BAR := Vector2i(76, 6)
const D_MORALE_BAR_SM := Vector2i(44, 4)   # the morale bar beside a work-hours row
const D_XP_BAR := Vector2i(32, 4)
const D_NOTCH := Vector2i(1, 12)        # the flight-risk notch across the morale bar
const D_SKILL_MARK := Vector2i(16, 2)   # the main skill's underline, just under its figure
# --- glyph sizes ---
const D_ICON_CONTROL := 20   # a control's own glyph (the ticker toggle, a window's close)
const D_ICON_TITLE := 20     # a float card's title glyph
const D_ICON_STRIP := 20     # a strip's leading and trailing glyphs
const D_ICON_BUTTON := 18    # a button's or chip's glyph
const D_ICON_GROUP := 18     # a table group's glyph
const D_ICON_TOAST := 18     # the glyph in a toast's well
const D_ICON_BUTTON_SM := 16 # a small button's glyph
const D_ICON_ROW := 16       # a row's leading glyph
const D_ICON_PART := 14      # a part's polarity glyph beside its value
const D_ICON_MARK := 12      # a mark on another glyph's corner (the rail lock)
const D_ICON_ACTION := 12    # the glyph inside a float card's action
const D_ICON_TAG := 12       # a tag's leading glyph
const D_ICON_EMPTY := 32     # an empty state's glyph
# --- the sprint screen (Ürün) ---
const D_W_AREAS := 430                # the areas column, its scrollbar lane included
const D_W_AREAS_NARROW := 280         # the areas column beside the quarter's sprints
const D_W_PICKER := 640               # the type picker's column
const D_H_SECTION := 28              # a section's caps label and its rule
const D_H_SECTION_SM := 24           # a sub-section inside an open area row
const D_SPRINT_COLUMNS := Vector2(590, 322)   # this sprint's column against the next one's
const D_SQUARE := 10                  # a level square
const D_SQUARE_SM := 8                # a level square in an effect line, a carry's progress square
const D_H_BAR := 8                    # the capacity bar
const D_BAR_TICK := Vector2i(2, 16)   # the capacity line across the bar
const D_GOAL_TICK := Vector2i(2, 18)  # the target line across the goal meter
const D_PHASE_DOT := 8                # a phase step's dot
const D_PHASE_LINK := 16              # the line between two phase steps
const D_W_PTS := 24                   # a card's points box, at its least
const D_H_KEY_SM := 28                # a card's glyph keys (+, →, ↑)
const D_H_ROW_RELEASE := 36           # a release note's card row
const D_W_RESULT_KEY := 96            # the release note's key column
const D_H_GOAL := 56                  # the quarter's goal strip
const D_W_GOAL_MENU := 560            # the quarter goal's menu

const D_SKILLS := [D_SKILL_1, D_SKILL_2, D_SKILL_3, D_SKILL_4, D_SKILL_5]
const D_SKILLS_CB := [D_SKILL_1, D_SKILL_2, D_SKILL_3, D_SKILL_4_CB, D_SKILL_5_CB]
## Topic hue [standard, colour-blind] by the tag key the pill shows.
const D_TOPICS := {
	"EVENT_TAG_MENTOR": [D_TOPIC_MENTOR, D_TOPIC_MENTOR_CB],
	"EVENT_TAG_CUSTOMER": [D_TOPIC_CUSTOMER, D_TOPIC_CUSTOMER_CB],
	"EVENT_TAG_TEAM": [D_TOPIC_TEAM, D_TOPIC_TEAM_CB],
	"EVENT_TAG_PRODUCT": [D_TOPIC_PRODUCT, D_TOPIC_PRODUCT_CB],
	"DESK_PAPER_TAG_FUNDING": [D_TOPIC_FUNDING, D_TOPIC_FUNDING_CB],
	"EVENT_TAG_MARKET": [D_TOPIC_MARKET, D_TOPIC_MARKET_CB],
	"EVENT_TAG_AGENDA": [D_TOPIC_AGENDA, D_TOPIC_AGENDA],
}
## Outlet hue [standard, colour-blind] by the outlet's name key.
const D_OUTLETS := {
	"WORLD_OUTLET_SEKTOR": [D_OUTLET_SEKTOR, D_OUTLET_SEKTOR_CB],
	"WORLD_OUTLET_EKONOMI": [D_OUTLET_EKONOMI, D_OUTLET_EKONOMI_CB],
	"WORLD_OUTLET_TEKNOGUNDEM": [D_OUTLET_TEKNOGUNDEM, D_OUTLET_TEKNOGUNDEM_CB],
	"WORLD_OUTLET_GIRISIM": [D_OUTLET_GIRISIM, D_OUTLET_GIRISIM_CB],
}


static func D_pos() -> Color:
	return D_POS_CB if _cb_palette else D_POS

static func D_neg() -> Color:
	return D_NEG_CB if _cb_palette else D_NEG

static func D_warn() -> Color:
	return D_WARN_CB if _cb_palette else D_WARN

static func D_info() -> Color:
	return D_INFO_CB if _cb_palette else D_INFO

## The danger strip's fill, border and text, and the text on a solid danger badge.
static func D_neg_bg() -> Color:
	return D_NEG_BG_CB if _cb_palette else D_NEG_BG

static func D_neg_rule() -> Color:
	return D_NEG_LINE_CB if _cb_palette else D_NEG_LINE

static func D_neg_ink() -> Color:
	return D_NEG_INK_CB if _cb_palette else D_NEG_INK

static func D_on_neg() -> Color:
	return D_ON_NEG_CB if _cb_palette else D_ON_NEG

static func D_chart_neg_area() -> Color:
	return D_CHART_NEG_AREA_CB if _cb_palette else D_CHART_NEG_AREA


## Ink of a 1-10 skill value; a founder's unspent skill reads 0.
static func D_skill(value: int) -> Color:
	return (D_SKILLS_CB if _cb_palette else D_SKILLS)[(clampi(value, 1, 10) - 1) / 2]


static func D_topic(tag_key: String) -> Color:
	return D_TOPICS[tag_key][int(_cb_palette)]


static func D_outlet(outlet_key: String) -> Color:
	return D_OUTLETS[outlet_key][int(_cb_palette)]


## Delta colour on the dark ground.
static func D_delta_color(value: int) -> Color:
	if value > 0: return D_pos()
	if value < 0: return D_neg()
	return D_INK_3


## {bg, line, fg} of a tag, by badge_palette's kinds: "accent" is the attention tag, "attention"
## the neutral count badge.
static func D_badge_palette(kind: StringName) -> Dictionary:
	var cb := _cb_palette
	match kind:
		&"positive": return {"bg": D_POS_TAG_BG_CB if cb else D_POS_TAG_BG,
				"line": D_POS_TAG_LINE_CB if cb else D_POS_TAG_LINE, "fg": D_POS_INK_CB if cb else D_POS_INK}
		&"negative": return {"bg": D_NEG_TAG_BG_CB if cb else D_NEG_TAG_BG,
				"line": D_NEG_TAG_LINE_CB if cb else D_NEG_TAG_LINE, "fg": D_neg_ink()}
		&"accent": return {"bg": D_WARN_TAG_BG_CB if cb else D_WARN_TAG_BG,
				"line": D_WARN_TAG_LINE_CB if cb else D_WARN_TAG_LINE, "fg": D_warn()}
		&"attention": return {"bg": D_SURFACE_5, "line": D_LINE_2, "fg": D_INK_2}
		_: return {"bg": D_SURFACE_5, "line": Color.TRANSPARENT, "fg": D_INK_3}


## Health dot colour. state: "healthy" | "warn" | "bad".
static func D_health_color(state: StringName) -> Color:
	match state:
		&"healthy": return D_pos()
		&"warn": return D_warn()
		&"bad": return D_neg()
		_: return D_INK_3


## {line, fg, dot} of a relationship chip: the word stays neutral and the dot carries the tone.
static func D_relationship_palette(rel: String) -> Dictionary:
	var dot: Color = D_INK_4
	match rel:
		"ally": dot = D_pos()
		"friendly": dot = Color(D_pos(), 0.6)
		"wary": dot = D_warn()
		"hostile": dot = D_neg()
	return {"line": D_LINE_3, "fg": D_INK_2, "dot": dot}


## Ink of a meeting option's risk word, on risk_key's edges.
static func D_risk_ink(chance: float) -> Color:
	if chance >= RISK_SAFE_MIN: return D_pos()
	if chance >= RISK_RISKY_MIN: return D_warn()
	return D_neg()


## A meeting seat's ring and name: the other side's lead (seat 1) in emphasis, every other seat in
## secondary ink. The seats carry no hue.
static func D_seat_ink(seat: int) -> Color:
	return D_INK_1 if seat == 1 else D_INK_3


## The dark theme bakes a meaning variation in both palettes, the colour-blind one as its "Cb" twin:
## the one the palette in use reads.
static func D_variation(name: StringName) -> StringName:
	return StringName(name + "Cb") if _cb_palette else name
