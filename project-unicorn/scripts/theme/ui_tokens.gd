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
# The legacy TEXT_PRIMARY/MUTED/DIM names are the LIGHT-surface tones (the
# common case); CREAM* are their dark-chrome counterparts.
# ============================================================================

# --- Backgrounds: dark chrome ---
const BG_TOPBAR := Color(0.125, 0.106, 0.086, 1)   # top bar charcoal
const BG_NEWS := Color(0.086, 0.067, 0.051, 1)     # news ticker (deepest)

# --- Backgrounds: light body ---
const BG_BODY := Color(0.925, 0.902, 0.839, 1)     # center viewport / body bone
const BG_PANEL := Color(0.914, 0.886, 0.820, 1)    # left rail + right panel
const CARD_BG := Color(0.965, 0.949, 0.910, 1)     # cards/panels on body (ivory)
const CARD_BORDER := Color(0.847, 0.816, 0.737, 1) # 1px card border (warm tan)
const CARD_ATTENTION_BG := Color(0.953, 0.902, 0.882, 1)  # "attention" cards (dusty pink)
# Legacy aliases (older refs expected dark; now point at the light surfaces) ---
const BG_VIEWPORT := BG_BODY
const BG_SIDE_PANEL := BG_PANEL

# --- Text on LIGHT surfaces (ink) ---
const INK := Color(0.169, 0.149, 0.125, 1)         # primary text / values / names
const INK_MUTED := Color(0.431, 0.400, 0.337, 1)   # secondary
const INK_DIM := Color(0.576, 0.545, 0.471, 1)     # labels, section headers, idle
# Legacy aliases ---
const TEXT_PRIMARY := INK
const TEXT_MUTED := INK_MUTED
const TEXT_DIM := INK_DIM

# --- Text on DARK chrome (cream) ---
const CREAM := Color(0.941, 0.918, 0.851, 1)       # values/names on chrome
const CREAM_DIM := Color(0.663, 0.620, 0.525, 1)   # captions/labels on chrome

# --- Accent (amber) ---
const ACCENT := Color(0.886, 0.639, 0.235, 1)      # active tab, +action, badge counts
const ACCENT_HEX := "#e2a33c"                       # BBCode (NewsTicker source name)
const ACCENT_DEEP := Color(0.541, 0.353, 0.071, 1) # amber TEXT on light surfaces
const AMBER_BG := Color(0.961, 0.890, 0.753, 1)    # pale amber chip bg

# --- State colors: on LIGHT (badge text on pale tinted bg) ---
const POSITIVE := Color(0.243, 0.420, 0.200, 1)
const POSITIVE_BG := Color(0.882, 0.922, 0.839, 1)
const NEGATIVE := Color(0.639, 0.200, 0.153, 1)
const NEGATIVE_BG := Color(0.941, 0.855, 0.831, 1)
# --- State colors: on DARK chrome (bright, no bg) ---
const POSITIVE_BRIGHT := Color(0.498, 0.690, 0.408, 1)
const NEGATIVE_BRIGHT := Color(0.851, 0.435, 0.353, 1)

# --- Badges / chips ---
const BADGE_BG := Color(0.620, 0.169, 0.145, 1)    # solid "ATTENTION" red
const BADGE_FG := CREAM                              # text on attention badge
const NEUTRAL_BADGE_BG := Color(0.906, 0.875, 0.800, 1)  # parchment trait chip
const NEUTRAL_BADGE_FG := Color(0.431, 0.396, 0.337, 1)

# --- Health / status dots ---
const HEALTH_GREEN := Color(0.369, 0.541, 0.275, 1)
const HEALTH_AMBER := Color(0.788, 0.588, 0.180, 1)

# --- Hairlines / dividers ---
const DIVIDER_LIGHT := Color(0, 0, 0, 0.08)        # on light body
const SEPARATOR := Color(1, 1, 1, 0.08)            # on dark chrome

# --- Font sizes ---
const SIZE_STAT_LABEL := 9      # "CASH" uppercase caption
const SIZE_STAT_VALUE := 15     # "$248,400" weighted value
const SIZE_STAT_DELTA := 10     # "+$4.2K" delta
const SIZE_BODY := 13
const SIZE_NAME := 14           # card / person names
const SIZE_CAPTION := 11
const SIZE_SECTION_HEADER := 10
const SIZE_TAB_LABEL := 11
const SIZE_TAB_ICON := 16
const SIZE_BADGE := 9
const SIZE_PLACEHOLDER_TITLE := 22
const SIZE_PLACEHOLDER_SUB := 11
const SIZE_DROPCAP := 30        # event body drop-cap

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
