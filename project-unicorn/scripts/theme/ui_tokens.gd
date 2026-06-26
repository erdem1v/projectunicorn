class_name UiTokens
extends RefCounted

# Working palette, typography, and glyph tokens for the UI overhaul pass.
# These are PLACEHOLDER values — a designer pass will refine them, but every
# region uses these consistently so the refinement is a single-file change.
# See TECH_SPEC §20 Decision Log entry (2026-05-16).
#
# Why a GDScript constants file instead of populating themes/master_theme.tres:
#   - Scripts can reference UiTokens.ACCENT directly; .tscn files keep their
#     inline overrides since Godot cannot import GDScript consts into scene
#     literals. A designer pass migrates these into the Theme resource later.

# --- Backgrounds ---
const BG_TOPBAR := Color(0.122, 0.102, 0.078, 1)
const BG_SIDE_PANEL := Color(0.102, 0.082, 0.063, 1)
const BG_VIEWPORT := Color(0.165, 0.137, 0.106, 1)
const BG_NEWS := Color(0.082, 0.063, 0.047, 1)

# --- Text ---
const TEXT_PRIMARY := Color(0.96, 0.91, 0.82, 1)   # Cream — values, names
const TEXT_MUTED := Color(0.78, 0.722, 0.612, 1)   # Tan — secondary
const TEXT_DIM := Color(0.56, 0.494, 0.396, 1)     # Dim — section headers, idle tabs

# --- Accent / state ---
const ACCENT := Color(0.91, 0.733, 0.471, 1)       # Amber — active tab border, section accent
const ACCENT_HEX := "#e8bb78"                       # For BBCode in NewsTicker
const POSITIVE := Color(0.49, 0.69, 0.45, 1)       # +deltas, healthy dots
const NEGATIVE := Color(0.78, 0.51, 0.42, 1)       # -deltas, soft red
const BADGE_BG := Color(0.78, 0.31, 0.31, 1)       # Attention badge red
const BADGE_FG := Color(0.96, 0.91, 0.82, 1)       # Badge number text
const HEALTH_GREEN := Color(0.49, 0.69, 0.45, 1)
const HEALTH_AMBER := Color(0.87, 0.69, 0.31, 1)
const SEPARATOR := Color(1, 1, 1, 0.06)

# --- Font sizes ---
const SIZE_STAT_LABEL := 9     # "CASH" small-caps header above value
const SIZE_STAT_VALUE := 15    # "$50K" main stat value
const SIZE_STAT_DELTA := 10    # "+$240/d" daily delta below value
const SIZE_BODY := 13
const SIZE_SECTION_HEADER := 10
const SIZE_TAB_LABEL := 11
const SIZE_TAB_ICON := 16
const SIZE_BADGE := 9
const SIZE_PLACEHOLDER_TITLE := 22
const SIZE_PLACEHOLDER_SUB := 11

# --- Tab glyphs (placeholder pass; designer may swap to icon font) ---
const TAB_GLYPH_PRODUCT := "▣"
const TAB_GLYPH_HR := "◉"
const TAB_GLYPH_FINANCE := "$"
const TAB_GLYPH_SALES := "↗"
const TAB_GLYPH_OPS := "◇"
const TAB_GLYPH_RND := "⚡"
const TAB_GLYPH_PERSONAL := "★"
const TAB_GLYPH_EVENTS := "●"

# --- Tab definition (id, label, glyph) — canonical 8-tab list ---
const TABS := [
	{"id": "product",  "label": "Product",  "glyph": TAB_GLYPH_PRODUCT},
	{"id": "hr",       "label": "HR",       "glyph": TAB_GLYPH_HR},
	{"id": "finance",  "label": "Finance",  "glyph": TAB_GLYPH_FINANCE},
	{"id": "sales",    "label": "Sales",    "glyph": TAB_GLYPH_SALES},
	{"id": "ops",      "label": "Ops",      "glyph": TAB_GLYPH_OPS},
	{"id": "rnd",      "label": "R&D",      "glyph": TAB_GLYPH_RND},
	{"id": "personal", "label": "Personal", "glyph": TAB_GLYPH_PERSONAL},
	{"id": "events",   "label": "Events",   "glyph": TAB_GLYPH_EVENTS},
]
