class_name UiTokens
extends RefCounted

# ============================================================================
# Project Unicorn — UI design tokens (single source of truth).
# ============================================================================
# Visual identity = the "Shiftkod" prototype: a LIGHT warm-cream editorial body
# with DARK charcoal chrome (top bar + news ticker), a single amber accent, and
# color used semantically (green positive / red negative / parchment neutral)
# in small uppercase badges.
#
# Why a GDScript constants file: it is the canonical place colors/sizes are
# defined. `themes/master_theme.tres` is GENERATED from these tokens by
# `scripts/theme/build_theme.gd` (Godot cannot read GDScript consts into .tscn
# literals, so the theme is a build artifact of this file — never hand-drift it).
# Scripts read `UiTokens.*` directly for runtime/state-dependent styling.
#
# CONTEXT RULE — text & state colors depend on the surface they sit on:
#   * On the DARK chrome (top bar, ticker): use CREAM / *_BRIGHT.
#   * On the LIGHT body (cards, panels, modal): use INK / POSITIVE / NEGATIVE.
#
# ============================================================================
# OWNERSHIP — who decides what (Tema Çekirdeği, 2026-08-03)
# ============================================================================
# UiTokens (this file) OWNS the VOCABULARY:
#   * the palette table — every Color in the game, named
#   * the 6-step type scale + the editorial-display exception tier
#   * spacing / radius / border-width / padding-pair tokens
#   * the leading (line_spacing) values per step
#   * runtime color-decision helpers (delta_color, badge_palette, health_color…)
#     and the format/locale helpers — logic a .tres cannot express
#   UiTokens knows NOTHING about Control types. It never names a Button or a Label.
#
# themes/master_theme.tres OWNS the ASSIGNMENT — which Control type / type
# variation gets which token — and it is a GENERATED ARTIFACT. Never hand-edit it.
#   Regenerate:  godot --headless --path . -s res://scripts/theme/build_theme.gd
#   (a clean checkout needs `godot --headless --path . --import` first)
#
# build_theme.gd is the ONLY file allowed to turn a token into a theme item.
#
# WITHIN the theme the split is:
#   * the SCALE owns SIZE + LEADING — a variation never overrides its step's size
#   * the VARIATION owns FACE + COLOR — that is the register axis (light body /
#     dark chrome / cinematic / newsprint) and it is deliberately free
#
# Scenes and scripts own LAYOUT ONLY (anchors, separation, margins, min sizes).
# They must not carry font sizes, colors, or styleboxes — reach for a
# theme_type_variation, or add one. Existing literals are GRANDFATHERED and
# migrate only when the surrounding lines change (the same convention TECH_SPEC's
# Decision Log set for inline Color() literals).
#
# FONT IMPORT STANDARD (documented, not re-decided here): all faces share
# antialiasing=1 (grayscale), hinting=1 (light), subpixel_positioning=4 (auto),
# msdf off, mipmaps off, oversampling=0. Changing any of these interacts with
# window/stretch/mode="canvas_items" + aspect="expand" at non-1080p sizes and
# belongs to a resolution pass, not to a theme edit.
#
# KNOWN GAPS (deliberate, not oversights): no base Control focus ring; Tree /
# ItemList / TabContainer are unstyled because the game uses none.
# ============================================================================

## Bump in the SAME commit as any token or build_theme.gd edit, then re-run the
## generator. main.gd warns at boot (debug builds) when the baked stamp differs,
## which is the cheap guard against a stale master_theme.tres shipping silently.
const THEME_STAMP := 4
# ============================================================================

# ============================================================================
# PALETTE TABLE — every color in the game lives here. No file outside this block
# may write a raw Color(...).  Format:  NAME := value   # hex · where it lives
# ============================================================================
# CONTEXT RULE (see header): dark chrome → CREAM / *_BRIGHT · light body → INK /
# POSITIVE / NEGATIVE. Picking the wrong register is the one palette mistake that
# renders text invisible rather than merely off-brand.

# --- SURFACE · dark chrome ---
const BG_TOPBAR := Color(0.125, 0.106, 0.086, 1)   # #201b16 · top bar charcoal
const BG_NEWS := Color(0.086, 0.067, 0.051, 1)     # #16110d · news ticker (deepest)
const BG_ART := Color(0.220, 0.188, 0.149, 1)      # #383026 · ArtPanel deep sepia plate
const BG_AVATAR := Color(0.450, 0.380, 0.320, 1)   # #736152 · avatar disc + cap-table bar

# --- SURFACE · light body ---
const BG_BODY := Color(0.925, 0.902, 0.839, 1)     # #ece6d6 · center viewport / body bone
const BG_PANEL := Color(0.914, 0.886, 0.820, 1)    # #e9e2d1 · left rail + right panel
const CARD_BG := Color(0.965, 0.949, 0.910, 1)     # #f6f2e8 · cards/panels on body (ivory)
const CARD_ATTENTION_BG := Color(0.953, 0.902, 0.882, 1)  # #f3e6e1 · "attention" cards (dusty pink)
const CARD_FLOATING_BG := Color(CARD_BG, 0.98)     # gövde ÜSTÜNDE yüzen kart (BuildHUD) — %98 alfa, altı hayal meyal geçer (derived, never re-typed)

# --- SURFACE · control states (light) ---
const SURFACE_INPUT := Color(0.980, 0.969, 0.941, 1)     # #faf7f0 · LineEdit fill (lightest tier)
const SURFACE_HOVER := BG_BODY                            # #ece6d6 · Button hover (was a near-dup of BG_BODY, merged)
const SURFACE_PRESSED := Color(0.898, 0.871, 0.816, 1)   # #e5ded0 · Button pressed
const SURFACE_DISABLED := Color(0.940, 0.925, 0.890, 1)  # #f0ece3 · Button disabled fill
const SURFACE_SUNKEN := Color(0.860, 0.830, 0.760, 1)    # #dbd4c2 · progress track, disabled CTA
const SURFACE_FRAME := Color(0.898, 0.878, 0.816, 1)     # #e5e0d0 · EngravingFrame empty plate
const SHADE_HOVER := Color(0, 0, 0, 0.04)                # hover veil on the LIGHT rail
const SHADOW_SOFT := Color(0, 0, 0, 0.10)                # yüzen kart gölgesi (CardFloating; PAPER_SHADOW'un yumuşak kardeşi)

# --- INK · text on light surfaces ---
const INK := Color(0.169, 0.149, 0.125, 1)         # #2b2620 · primary text / values / names
const INK_MUTED := Color(0.431, 0.400, 0.337, 1)   # #6e6656 · secondary
const INK_DIM := Color(0.576, 0.545, 0.471, 1)     # #938b78 · labels, section headers, idle

# --- CREAM · text on dark chrome ---
const CREAM := Color(0.941, 0.918, 0.851, 1)       # #f0ead9 · values/names on chrome
const CREAM_DIM := Color(0.663, 0.620, 0.525, 1)   # #a99e86 · captions/labels on chrome
const CREAM_DIM_DISABLED := Color(CREAM_DIM, 0.40) # disabled text on dark (derived, never re-typed)

# --- ACCENT · amber, with its full state ramp ---
const ACCENT := Color(0.886, 0.639, 0.235, 1)      # #e2a33c · active tab, +action, badge counts
const ACCENT_HOVER := Color(0.940, 0.710, 0.330, 1)    # #f0b554 · CTA hover, slider highlight
const ACCENT_PRESSED := Color(0.800, 0.570, 0.200, 1)  # #cc9133 · CTA pressed
const ACCENT_DIM := Color(0.494, 0.353, 0.220, 1)      # #7e5a38 · amber fill ON charcoal (active speed btn)
const ACCENT_DEEP := Color(0.541, 0.353, 0.071, 1)     # #8a5a12 · amber TEXT on light surfaces
const AMBER_BG := Color(0.961, 0.890, 0.753, 1)        # #f5e3c0 · pale amber chip bg
const ACCENT_HEX := "#e2a33c"                      # BBCode form of ACCENT (NewsTicker source name)

# --- STATE · semantic ---
const POSITIVE := Color(0.243, 0.420, 0.200, 1)          # #3e6b33 · on light
const POSITIVE_BG := Color(0.882, 0.922, 0.839, 1)       # #e1ebd6
const NEGATIVE := Color(0.639, 0.200, 0.153, 1)          # #a33327 · on light
const NEGATIVE_BG := Color(0.941, 0.855, 0.831, 1)       # #f0dad4
const POSITIVE_BRIGHT := Color(0.498, 0.690, 0.408, 1)   # #7fb068 · on dark chrome
const NEGATIVE_BRIGHT := Color(0.851, 0.435, 0.353, 1)   # #d96f5a · on dark chrome
const HEALTH_GREEN := Color(0.369, 0.541, 0.275, 1)      # #5e8a46 · status dot
const HEALTH_AMBER := Color(0.788, 0.588, 0.180, 1)      # #c9962e · status dot
const DOT_IDLE := Color(0.350, 0.320, 0.270, 1)          # #595245 · unreached phase dot
const AXIS_EXPERIENCE := Color("#3b5b92")                # #3b5b92 · ürün ekseni "Deneyim" (Rev3 mavi; legend dot + ince bar). Hex form: birebir mockup değeri, float yuvarlaması yok.

# --- BADGE / CHIP ---
const BADGE_BG := Color(0.620, 0.169, 0.145, 1)          # #9e2b25 · solid "ATTENTION" red
const BADGE_FG := CREAM                                   # text on attention badge
const NEUTRAL_BADGE_BG := Color(0.906, 0.875, 0.800, 1)  # #e7dfcc · parchment trait chip
const NEUTRAL_BADGE_FG := INK_MUTED                       # was a 0.004-off near-dup of INK_MUTED, merged
const TAB_ACTIVE_BG := Color(CARD_BG, 0.70)               # active rail tab — body tint reads through

# --- EDGE · borders, dividers, hairlines ---
const CARD_BORDER := Color(0.847, 0.816, 0.737, 1)       # #d8d0bc · 1px card border (warm tan)
const CARD_ATTENTION_BORDER := Color(0.800, 0.620, 0.580, 1)  # #cc9e94 · dusty-pink card edge
const BORDER_DISABLED := Color(0.900, 0.880, 0.830, 1)   # #e6e0d4 · disabled control edge
const DIVIDER_LIGHT := Color(0, 0, 0, 0.08)              # hairline on light body
const SEPARATOR := Color(1, 1, 1, 0.08)                  # hairline on dark chrome

# --- VEIL · translucent whites on dark chrome ---
# Six alpha steps (0.02/0.03/0.04/0.05/0.06/0.09) collapsed to three. Every move
# is ≤0.01 alpha on a charcoal ground — below the perceptual threshold — and the
# one control where both normal AND hover shifted (SpeedButton) ends up with
# slightly MORE contrast between its states, which is the right direction.
const VEIL_FAINT := Color(1, 1, 1, 0.03)    # at-rest / disabled tint
const VEIL_SOFT := Color(1, 1, 1, 0.06)     # normal / pressed
const VEIL_STRONG := Color(1, 1, 1, 0.10)   # hover

# --- Cinematic dialogue register (Spec 5: MeetingScene / FrankPopup) ---
# A DARK charcoal register distinct from the light editorial modals — the game's
# cinematic layer. Text on these surfaces uses the CREAM* / *_BRIGHT tones per the
# context rule above. Amber fill/edge reuse ACCENT; danger captions reuse
# NEGATIVE_BRIGHT; monologue (interior voice) text uses CREAM_DIM. Working values
# sampled toward the approved mockups — final hues sealed by Erdem's F5 eye.
const SCRIM_MODAL := Color(0, 0, 0, 0.55)            # standard modal dimmer (matches existing modals)
const SCRIM_ROOM := Color(0, 0, 0, 0.18)              # readability scrim over full-bleed room art
const STAT_STRIP_BG := Color(0, 0, 0, 0.45)          # bottom-left translucent stat band over art
const DIALOGUE_BG := Color(0.098, 0.086, 0.075, 1)   # deep warm charcoal (solid — Frank card)
const DIALOGUE_COLUMN_BG := Color(0.098, 0.086, 0.075, 0.92)  # floating column (art shows through)
const DIALOGUE_CARD_BG := Color(0.145, 0.129, 0.114, 1)       # choice / quote card (a step lighter)
const DIALOGUE_CARD_BORDER := Color(1, 1, 1, 0.10)   # subtle hairline on dark
const CONVICTION_TRACK_BG := Color(1, 1, 1, 0.07)    # İKNA gauge groove
const PORTRAIT_FRAME := CREAM                        # was an exact re-typing of CREAM, merged

# --- Newspaper ending register ("Ekonomi Postası") ---
# The cream PAPER is a LIGHT surface (INK text) sitting inside the DARK screen
# (DIALOGUE_BG). It is a touch warmer/brighter than CARD_BG so the page reads as
# newsprint, not a UI card. The second-page edge + shadow give the single-sheet
# depth from the mockup. Working values — Erdem's F5 seals the final hues.
const PAPER_BG := Color(0.953, 0.933, 0.878, 1)     # newsprint cream (warmer than CARD_BG)
const PAPER_EDGE := Color(0.878, 0.851, 0.780, 1)   # right/bottom second-page edge tint
const PAPER_RULE := INK                             # was an exact re-typing of INK, merged (name kept — it reads better at its 2 sites)
const PAPER_SHADOW := Color(0, 0, 0, 0.38)          # page drop shadow on the dark screen

# --- ODA merkez görünümü (masa POV oda sahnesi; ODA rework 2026-08-06) ---
# Sahne çifti (gündüz/gece 3840×2160 sanat) + motor-çizimi bilgi katmanı. Roller:
# gece tint'i obje sprite'larına MULTIPLY biner (objeler gündüz-nötr boyandı),
# lamba halesi ADDITIVE'dir (GECE sahnesindeki baked ışık havuzunun lamba başına
# düşen payı), gün ışığı eğrisi SceneLayer modulate'ine saat başı adımla biner.
# Tüm değerler # WORKING — Erdem'in F5 gözü mühürler.
const ODA_NIGHT_TINT := Color(0.72, 0.78, 0.92, 1)   # gece: obje sprite'larına serin multiply
const ODA_LAMP_GLOW := Color(1.0, 0.78, 0.45, 1)     # gece: lamba başı additive hale
# Dört-durum ışık makinesi (kalite turu v2 / D6): GÜNDÜZ nötr (WHITE — token
# gerekmez) · AKŞAM 18 ılık · GECE 19-05 (sahne çifti + ODA_NIGHT_TINT) · ŞAFAK 06
# serin. Saatlik adım ÖLDÜ; tint yalnız durum sınırında 1.5 sn tween'lenir.
const ODA_TINT_EVENING := Color(1.0, 0.93, 0.84, 1)  # AKŞAM saati (belirgin ılık tek vuruş)
const ODA_TINT_DAWN := Color(0.92, 0.95, 1.0, 1)     # ŞAFAK saati (belirgin serin tek vuruş)
const ODA_RIM_GLOW := Color(ACCENT, 0.55)            # hover rim shader uniform'u (derived, never re-typed)
const ODA_SCREEN_GLOW := Color(ACCENT, 0.30)         # gece monitör panelinin gölge-glow'u (derived)
const ODA_ANCHOR_GLOW_SHADOW := Color(ACCENT, 0.35)  # boyalı çapa hover/tur glow gölgesi (derived)

# ============================================================================
# TYPE SCALE — six steps, and the ONLY sizes new UI may reach for.
# ============================================================================
# THE RULE: the SCALE owns SIZE and LEADING; the VARIATION owns FACE and COLOR.
# This split is forced by the data — BodySerif (serif/INK), ChromeValue
# (sans_sb/CREAM) and SubtitleSerifCream (serif_it/CREAM_DIM) all legitimately
# sit at 13. The theme's ~43 label variations differ by REGISTER (light body /
# dark chrome / cinematic / newsprint), not by size. A scale that also owned the
# typeface would need 43 steps and would stop being a scale.
#
# Sizes measured from docs/design/mockups/ at 1080p; the ratio lands at ~1.19
# (a minor third) throughout. Five of the six already existed in the theme —
# because those values were themselves derived from these same frames in an
# earlier pass. See docs/design/mockups/README.md for the per-step trace.
#
# "default face" below is the face the plurality of that step's members use; a
# variation MAY choose another face, but it may NEVER override its step's size.
#
#   token          px   default face   voice
#   SIZE_MICRO      9   mono_label     uppercase meta, badges, stat captions
#   SIZE_SMALL     11   mono_reg       data, secondary meta, tab labels
#   SIZE_BODY      13   serif_reg      reading prose
#   SIZE_LEAD      15   sans_sb        names, choices, figures, controls
#   SIZE_TITLE     18   sans_sb        stat figures, sub-heads
#   SIZE_DISPLAY   22   serif_sb       modal / screen titles
const SIZE_MICRO := 9
const SIZE_SMALL := 11
const SIZE_BODY := 13
const SIZE_LEAD := 15
const SIZE_TITLE := 18
const SIZE_DISPLAY := 22

# --- Editorial display tier — a documented EXCEPTION, not extra scale steps ---
# A 54px masthead and a 9px badge cannot both be governed well by one interface
# scale: these are typographic set pieces composed against a fixed page, not part
# of the reading rhythm. RULE: any size above SIZE_DISPLAY must be named here, and
# may appear ONLY in the newspaper ("Ekonomi Postası") or ceremony registers.
const SIZE_ED_CEREMONY := 26    # onboarding page title; MonthSummary band title
const SIZE_ED_HEADLINE := 30    # newspaper headline; event drop-cap (retired SIZE_DROPCAP)
const SIZE_ED_FIGURE := 44      # newspaper stat figures "$1.2M"
const SIZE_ED_MASTHEAD := 54    # "EKONOMİ POSTASI"

# --- Leading (line-height) ---
# Godot's Label has NO line_height property. The line box is the font's own
# ascent+descent at that size PLUS the theme constant `constants/line_spacing`
# (engine default 3); RichTextLabel uses `constants/line_separation` (default 0).
# So leading here = px tokens fed to those two constants.
#
# ⚠ Raising a LEADING_* value changes the pixel HEIGHT of every wrapping Label —
# that is a LAYOUT change. Theme Core therefore ships them at exactly the engine
# defaults: zero pixel delta today, but the values are now OURS and can no longer
# drift when Godot changes its default theme. Raising them is a separate, gated job.
const LEADING_MICRO := 2
const LEADING_SMALL := 2
const LEADING_BODY := 3         # == engine default
const LEADING_LEAD := 3
const LEADING_TITLE := 2
const LEADING_DISPLAY := 0
const LEADING_RICH := 0         # RichTextLabel line_separation; == engine default

# --- Grandfathered display sizes (screen code, NOT on the scale) ---
# These predate the scale and were deliberately LEFT ALONE by Theme Core: moving
# them is 2-4px of visible motion, which is an aesthetic call belonging to the
# polish wave, not to a foundation task. Listed here so that wave knows where they
# live. Do NOT add to this list — new code picks a scale step.
#   creation_flow.gd:214 (34) · origin_traits_step.gd:350 (30) · :320 (20)
#   month_summary_modal.gd:168 (26) · term_sheet_table_scene.gd:264 (24)
#   pricing_panel.gd:70 (24) · detail_view.gd:141 (20)

# ============================================================================
# SPACING + SHAPE
# ============================================================================
# 4-based; 6 is the one sanctioned half-step (dense data rows). NEW separation /
# margin / gap values come from here. The ~466 existing literals in scenes and
# scripts are GRANDFATHERED and migrate only when the surrounding lines change —
# the same convention TECH_SPEC's Decision Log already set for inline Color()
# literals. Theme Core deliberately did NOT sweep them: that is layout churn.
const SPACE_0 := 0
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
# StyleBoxFlat clamps a radius to half the box, so RADIUS_PILL is a true circle
# or pill at ANY size — which is why make_avatar no longer needs its old
# "keep the diameter at or below 36" caveat.
const RADIUS_NONE := 0          # full-bleed chrome bands, rails, sunken tracks, focus killers
const RADIUS_XS := 2            # dots, cap bars, the paper sheet
const RADIUS_S := 3             # chips, progress bars, speed buttons, sliders
const RADIUS_M := 4             # DEFAULT — cards, buttons, inputs
const RADIUS_L := 6             # modals, portrait cells
const RADIUS_XL := 8            # dialogue choice cards, tab badge
const RADIUS_XXL := 12          # dialogue column, portrait frame
const RADIUS_PILL := 999        # fully rounded at any size
# Documented shape exceptions — surfaces whose radius predates the scale. Snapping
# them is visible motion (+2 / -4), so the polish wave owns that call, not this task.
const RADIUS_PORTRAIT := 10     # PortraitFrame
const RADIUS_CARD_LG := 16      # DialogueCard

# --- Border widths ---
const BORDER_HAIRLINE := 1      # cards, inputs, chips, tooltip
const BORDER_FOCUS := 2         # selection rings (SelectedBorder, PortraitCellSelected)
const BORDER_ACCENT := 3        # left accent bar (QuoteBox, TabButtonActive)

# --- StyleBox content-margin pairs (h, v) ---
# Named 1:1 against the pairs already in use, so adopting them was a pure rename
# with zero pixel change. These govern build_theme.gd ONLY — container margins and
# separations inside scenes are layout and are not in scope here.
const PAD_CHIP := Vector2i(6, 2)          # UiFactory chip
const PAD_BTN_XS := Vector2i(8, 3)        # SpeedButton
const PAD_BTN_S := Vector2i(10, 4)        # DialogueStepper
const PAD_BTN_GHOST := Vector2i(10, 5)    # DialogueGhost
const PAD_INPUT := Vector2i(10, 6)        # LineEdit
const PAD_BTN := Vector2i(12, 6)          # base Button
const PAD_CHOICE := Vector2i(12, 8)       # ChoiceCard family
const PAD_INPUT_LG := Vector2i(12, 9)     # DialogueInput (ceremony-scale field)
const PAD_CARD_TIGHT := Vector2i(10, 8)   # CardPanelTight
const PAD_CARD := Vector2i(12, 10)        # CardPanel / CardCta / CardAttention
const PAD_STRIP := Vector2i(12, 6)        # StatStrip (same value as PAD_BTN, kept apart by role)
const PAD_BAND := Vector2i(14, 8)         # HeaderBand
const PAD_ROW := Vector2i(14, 10)         # QuoteBox / DialogueChoice
const PAD_CARD_RAIL := Vector2i(14, 12)   # RailCard
const PAD_CTA := Vector2i(16, 10)         # CommitButton
const PAD_TOOLTIP := Vector2i(8, 4)       # tooltip panel
const PAD_RAIL := Vector2i(20, 20)        # RailPanel
const PAD_PAGE := Vector2i(28, 22)        # PaperModal
const PAD_SHEET := Vector2i(44, 36)       # PaperPanel
const PAD_FRAME := Vector2i(4, 4)         # PortraitFrame / PortraitCell hairline inset
const PAD_CELL := Vector2i(3, 3)          # PortraitCell

# --- Tab glyphs (fallback only; SVG icons are primary — see TABS.icon) ---
const TAB_GLYPH_PRODUCT := "▣"
const TAB_GLYPH_HR := "◉"
const TAB_GLYPH_FINANCE := "$"
const TAB_GLYPH_SALES := "↗"
const TAB_GLYPH_OPS := "◇"
const TAB_GLYPH_RND := "⚡"
const TAB_GLYPH_PERSONAL := "★"
const TAB_GLYPH_EVENTS := "●"

# --- Tab definition (id, label, glyph, icon) — canonical 8-tab list ---
const TABS := [
	{"id": "product",  "label": "Product",  "glyph": TAB_GLYPH_PRODUCT,  "icon": "res://assets/icons/tabs/product.svg"},
	{"id": "hr",       "label": "HR",       "glyph": TAB_GLYPH_HR,       "icon": "res://assets/icons/tabs/hr.svg"},
	{"id": "finance",  "label": "Finance",  "glyph": TAB_GLYPH_FINANCE,  "icon": "res://assets/icons/tabs/finance.svg"},
	{"id": "sales",    "label": "Sales",    "glyph": TAB_GLYPH_SALES,    "icon": "res://assets/icons/tabs/sales.svg"},
	{"id": "ops",      "label": "Ops",      "glyph": TAB_GLYPH_OPS,      "icon": "res://assets/icons/tabs/ops.svg"},
	{"id": "rnd",      "label": "R&D",      "glyph": TAB_GLYPH_RND,      "icon": "res://assets/icons/tabs/rnd.svg"},
	{"id": "personal", "label": "Personal", "glyph": TAB_GLYPH_PERSONAL, "icon": "res://assets/icons/tabs/personal.svg"},
	{"id": "events",   "label": "Events",   "glyph": TAB_GLYPH_EVENTS,   "icon": "res://assets/icons/tabs/events.svg"},
	# Spec 6 — the standalone "Yatırım" rail tab was relocated INTO the Finance tab as a
	# sub-page (Finance>Yatırım); the 9th rail entry is gone (badge indices 1/2/7 stay valid).
]

# ============================================================================
# Runtime color-decision helpers — centralize sign/kind -> color logic so it
# isn't re-implemented across top_bar / event_modal / product_tab.
# ============================================================================

## Delta color for LIGHT surfaces (rationale rows, etc.).
static func delta_color(value: int) -> Color:
	if value > 0: return POSITIVE
	if value < 0: return NEGATIVE
	return INK_MUTED

## Delta color for the DARK chrome (top-bar metric deltas).
static func delta_color_bright(value: int) -> Color:
	if value > 0: return POSITIVE_BRIGHT
	if value < 0: return NEGATIVE_BRIGHT
	return CREAM_DIM

## {bg, fg} for a tinted chip. kind: "positive" | "negative" | "neutral" | "accent" | "attention".
static func badge_palette(kind: StringName) -> Dictionary:
	match kind:
		&"positive": return {"bg": POSITIVE_BG, "fg": POSITIVE}
		&"negative": return {"bg": NEGATIVE_BG, "fg": NEGATIVE}
		&"accent":   return {"bg": AMBER_BG, "fg": ACCENT_DEEP}
		&"attention": return {"bg": BADGE_BG, "fg": BADGE_FG}
		_: return {"bg": NEUTRAL_BADGE_BG, "fg": NEUTRAL_BADGE_FG}

## {bg, fg} chip palette chosen from a signed delta.
static func badge_palette_for_delta(value: int) -> Dictionary:
	if value > 0: return badge_palette(&"positive")
	if value < 0: return badge_palette(&"negative")
	return badge_palette(&"neutral")

## Health dot color. state: "healthy" | "warn" | "bad".
static func health_color(state: StringName) -> Color:
	match state:
		&"healthy": return HEALTH_GREEN
		&"warn": return HEALTH_AMBER
		&"bad": return NEGATIVE
		_: return INK_DIM

## {bg, fg} chip palette for a relationship tier (event character strip).
static func relationship_palette(rel: String) -> Dictionary:
	match rel:
		"ally", "friendly": return badge_palette(&"positive")
		"wary": return badge_palette(&"accent")
		"hostile": return badge_palette(&"negative")
		_: return badge_palette(&"neutral")

## {bg, fg} chip palette for a bug count (product build indicator).
static func bug_severity(bug_count: int) -> Dictionary:
	if bug_count <= 0: return badge_palette(&"positive")
	if bug_count <= 2: return badge_palette(&"accent")
	return badge_palette(&"negative")


## Game-wide money format (Spec 3 §6 — the single convention going forward).
## < $1K → "$800" · ≥ $1K → one-decimal K ("$2.1K", "$10.0K") · ≥ $1M →
## one-decimal M ("$4.0M") · ≥ $10M drops a .0 decimal ("$22M"). Negative →
## leading "-". TopBar's variants moved here (format_money_chip/exact, 2026-07-21
## sweep); remaining local formatters are deliberate: ProductUiShared.money_tr
## (Rev3 exact dot-grouping), EventModal._fmt_money_delta. NEW code must use this.
static func format_money(amount: int) -> String:
	var a: int = absi(amount)
	var s: String
	if a >= 1_000_000:
		var millions: float = a / 1_000_000.0
		if a >= 10_000_000 and a % 1_000_000 == 0:
			s = "$%dM" % int(millions)
		else:
			s = "$%.1fM" % millions
	elif a >= 1_000:
		s = "$%.1fK" % (a / 1_000.0)
	else:
		s = "$%d" % a
	return ("-" + s) if amount < 0 else s


## TopBar finance-chip format (moved verbatim from top_bar.gd — 2026-07-21 sweep).
## MRR/BURN/NET stay abbreviated (K/M) so they can't widen FinanceGroup and shove the speed
## controls. One decimal below $10K keeps MRR precise ("$3.5K"), no decimal above ("$50K",
## "$350K"), M above a million ("$1.2M"). NOTE: thresholds deliberately diverge from
## format_money (the ≥$10K no-decimal branch) — merge decision belongs to the curve session.
## Negative → leading "-", exactly like format_money.
static func format_money_chip(value: int) -> String:
	# The sign is peeled off ONCE and re-attached around the finished magnitude form.
	# The branches pick on absi() so they must also DIVIDE absi(): dividing the signed
	# value strands the minus inside the number ("$-12K" instead of "-$12K"). Positive
	# output stays byte-identical — fmt_probe.gd's chip column pins it.
	var a: int = absi(value)
	var s: String
	if a >= 1000000:
		s = "$%.1fM" % (a / 1000000.0)
	elif a >= 10000:
		s = "$%.0fK" % (a / 1000.0)
	elif a >= 1000:
		s = "$%.1fK" % (a / 1000.0)
	else:
		s = "$%d" % a
	return ("-" + s) if value < 0 else s


## Exact money, comma-grouped (moved verbatim from top_bar.gd — 2026-07-21 sweep).
## CASH is shown in FULL with thousands separators (Erdem: money management is precise, wants
## the exact figure) — "$12,340", "$1,234,567". Godot has no locale grouping, so group manually.
## The StatCol_Cash width bound (+ clip_text) keeps even 7-digit values from shoving the chrome.
static func format_money_exact(value: int) -> String:
	var digits: String = str(absi(value))
	var out: String = ""
	var c: int = 0
	for i in range(digits.length() - 1, -1, -1):
		out = digits[i] + out
		c += 1
		if c % 3 == 0 and i > 0:
			out = "," + out
	return ("-$" if value < 0 else "$") + out


## Turkish-aware uppercase — the single home. Godot's String.to_upper() is not
## locale-aware: "i" → "I" (dotless — wrong in Turkish, must be "İ"). Pre-substitute
## i→İ, then to_upper; "ı" → "I" already maps correctly via the default Unicode rules.
## Player-facing uppercasing goes through this, never raw to_upper().
static func tr_upper(s: String) -> String:
	return s.replace("i", "İ").to_upper()


## Net-runway display (Package 5): revenue-aware runway. INF (net_burn ≤ 0) → the
## "default alive" status word ("Artıda"); finite → whole months. Uses TranslationServer
## because statics can't call tr(). The single home for the months-vs-status +
## localization decision, feeding every net-runway surface (TopBar, Finance tab,
## HR previews, Month-End summary) — one edit here flips them all.
## `positive` lets a caller color the status green; `note` is the hover/sub-line
## explaining why no month figure is shown (never render infinity or a fake number).
## Two sub-month truths the month figure alone cannot tell, in branch order:
## cash below zero → NO runway (zero days, never the status word), and a finite
## runway shorter than a month → whole DAYS, because "0 ay" would read as insolvency.
static func net_runway_parts(months: float) -> Dictionary:
	# The empty treasury is asked about FIRST, before INF: GameState.runway_months_for()
	# answers INF for any non-negative daily net without ever looking at the cash, so a
	# company that committed a build it could not afford sits at cash < 0 and still gets
	# painted a green "Artıda" — two TopBar cells from a red bankruptcy countdown. Below
	# zero there is no runway, said with the vocabulary this function already owns.
	if GameState.cash < 0:
		return {"value": "0", "unit": TranslationServer.translate("RUNWAY_UNIT_DAYS"),
				"positive": false, "note": ""}
	if months == INF:
		return {"value": TranslationServer.translate("RUNWAY_PROFITABLE"), "unit": "",
				"positive": true, "note": TranslationServer.translate("RUNWAY_PROFITABLE_NOTE")}
	if months < 1.0:
		# Under a month the month figure rounds to a bare "0 ay" — insolvency, printed at a
		# company that still pays its bills for most of a week. Same runway, said in days.
		# floor(), not round(): a countdown must never promise a day the cash cannot cover.
		return {"value": str(int(floor(months * GameState.DAYS_PER_MONTH))),
				"unit": TranslationServer.translate("RUNWAY_UNIT_DAYS"),
				"positive": false, "note": ""}
	return {"value": str(int(round(months))), "unit": TranslationServer.translate("RUNWAY_UNIT_MONTHS"),
			"positive": false, "note": ""}


static func net_runway_text(months: float) -> String:
	var p: Dictionary = net_runway_parts(months)
	return String(p.value) if String(p.unit) == "" else "%s %s" % [p.value, p.unit]


## Build progress (ProductSystem.build_progress(), 0.0-1.0) as the WHOLE percent every
## surface prints — the single home for that rounding, the same way net_runway_parts is
## the single home for the months decision. The floating build card lives over the tab
## pages, so the portfolio badge and the card render the SAME build in one frame: one
## site rounding and the other flooring turns 0.4761 into "%48" beside "%47".
## Bars take build_percent(p) / 100.0 (or the int as a 0-100 value), never the raw
## fraction — a bar fed the unrounded number disagrees with the figure next to it.
static func build_percent(progress: float) -> int:
	return int(round(clampf(progress, 0.0, 1.0) * 100.0))
