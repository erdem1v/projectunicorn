extends RefCounted
## evrak: a manila folder on a notary's desk. Tabs and the window frame are manila, pages and cards
## are cream paper, text and data are black-brown ink, and the one accent is a rubber stamp's red.
## The frame bands stay dark (ink brown) so the brights that code paints on them keep their contrast.

const MANILA := Color("#F5E7C4")
const MANILA_DEEP := Color("#ECDDBA")
const FOLDER_EDGE := Color("#7A6444")
const BOARD := Color("#D6C39C")
const PAPER := Color("#FCF8EF")
const GROUND := Color("#F3ECDD")
const PRESSED := Color("#EFE6D3")
const SUNKEN := Color("#E6DAC4")
const INPUT := Color("#FFFBF3")
const INK := Color("#2A2118")
const INK_MUTED := Color("#5A4D40")
const INK_DIM := Color("#7F715F")
const INK_FAINT := Color("#A39580")
const EDGE := Color("#D6C8AD")
const EDGE_HOVER := Color("#A8957A")
const STAMP := Color("#B0281C")
const STAMP_LIGHT := Color("#C2392B")
const STAMP_DEEP := Color("#8E2016")
const FRAME := Color("#1C1612")
const FRAME_DEEP := Color("#140F0C")
const FRAME_LINE := Color("#3B3027")
const FRAME_KEY := Color("#28201A")
const FRAME_LIFT := Color("#62533F")
const FRAME_INK := Color("#8A7B67")
const CREAM := Color("#F1E8D6")
const CREAM_DIM := Color("#B3A48D")
const STAMP_BRIGHT := Color("#E65A46")
const STAMP_GLOW := Color("#EE7563")
const SHADOW := Color("#2A21181F")
const SHADOW_FLOAT := Color("#2A21182E")

const PALETTE := {"manila": MANILA, "manila_deep": MANILA_DEEP, "board": BOARD, "paper": PAPER, "ink": INK,
	"folder_edge": FOLDER_EDGE, "stamp": STAMP, "frame": FRAME}

## Selection washes (AMBER_*) are manila, the folder's own colour; the accent family is stamp red.
const TOKENS := {
	"BG_BODY": GROUND, "BG_PANEL": BOARD, "CARD_BG": PAPER, "SURFACE_INPUT": INPUT, "SURFACE_PRESSED": PRESSED,
	"SURFACE_SUNKEN": SUNKEN, "DIVIDER_LIGHT": SUNKEN, "SURFACE_ROW_TINT": GROUND,
	"INK": INK, "INK_MUTED": INK_MUTED, "INK_DIM": INK_DIM, "INK_FAINT": INK_FAINT,
	"CARD_BORDER": EDGE, "BORDER_HOVER": EDGE_HOVER,
	"ACCENT": STAMP, "ACCENT_HOVER": STAMP_LIGHT, "ACCENT_PRESSED": STAMP_DEEP, "ACCENT_DEEP": STAMP_DEEP,
	"AMBER_BG": MANILA, "AMBER_WASH": MANILA,
	"BG_TOPBAR": FRAME, "SEPARATOR": FRAME_LINE, "BG_AVATAR": FRAME_LINE, "CARD_BORDER_CHROME": FRAME_LINE,
	"BORDER_HOVER_CHROME": FRAME_LIFT, "DOT_IDLE_CHROME": FRAME_LIFT, "ACCENT_DIM": FRAME_KEY,
	"CREAM": CREAM, "PORTRAIT_FRAME": CREAM, "CREAM_DIM": CREAM_DIM, "INK_MUTED_CHROME": CREAM_DIM,
	"INK_DIM_CHROME": FRAME_INK, "INK_FAINT_CHROME": FRAME_INK,
	"ACCENT_CHROME": STAMP_BRIGHT, "ACCENT_HOVER_CHROME": STAMP_GLOW, "ACCENT_PRESSED_CHROME": STAMP_LIGHT,
	"DIALOGUE_BG": FRAME, "DIALOGUE_CARD_BG": FRAME_DEEP,
}

## Titles are serif, body text is clean sans (so serif_reg draws in Plex Sans), numbers and labels are
## mono. serif_it stays a serif italic: it draws quoted remarks, and no on-screen rich text is italic.
## No tnum: Plex Sans and Plex Mono carry no such feature and their figures are already tabular.
const FONTS := {
	"serif_reg": {"file": "fonts/IBMPlexSans/IBMPlexSans-VF.ttf", "axes": {"wght": 400, "wdth": 100}},
	"serif_sb": {"file": "fonts/SourceSerif4/SourceSerif4-VF.ttf", "axes": {"wght": 600, "opsz": 24}},
	"serif_it": {"file": "fonts/SourceSerif4/SourceSerif4-Italic-VF.ttf", "axes": {"wght": 400, "opsz": 14}},
	"sans_reg": {"file": "fonts/IBMPlexSans/IBMPlexSans-VF.ttf", "axes": {"wght": 400, "wdth": 100}},
	"sans_sb": {"file": "fonts/IBMPlexSans/IBMPlexSans-VF.ttf", "axes": {"wght": 600, "wdth": 100}},
	"mono_reg": {"file": "fonts/IBMPlexMono/IBMPlexMono-Regular.ttf"},
	"mono_label": {"file": "fonts/IBMPlexMono/IBMPlexMono-Regular.ttf"},
	"mono_sb": {"file": "fonts/IBMPlexMono/IBMPlexMono-SemiBold.ttf"},
}

## Texture geometry, read by assets/make_assets.py too: nine-slice lines [left, top, right, bottom] and
## the soft shadow the frame textures carry outside the frame, which expand margins draw out there.
## A tab's slanted shoulder spans (right - 2) x (top - 2) px. A frame's slice is its shadow, its band,
## the page's edge line and one paper texel, so the stretched page never samples the edge line.
## The windows have no shadow on the left: a selected tab laid over FolderWindow's left slice ends on
## the page, and the real window's left edge is the rail's rule.
const SLICE_TAB := [3, 16, 11, 3]
const SLICE_CHIP := [2, 8, 6, 2]
const SLICE_WINDOW := [16, 26, 26, 26]
const SLICE_MODAL := [26, 26, 26, 26]
const SLICE_STAMP := [5, 5, 5, 5]
const WINDOW_SHADOW := 10


static func canonical(th: Theme, dir: String, fonts: Dictionary) -> void:
	var tab := _tex(dir, "tab_idle.png", SLICE_TAB, UiTokens.PAD_BTN_XS)
	# A tab that is not open yet is faded and flat: no shoulder.
	var soon := _flat(PRESSED, EDGE, UiTokens.PAD_BTN_XS)
	var selected := _tex(dir, "tab_selected.png", SLICE_TAB, UiTokens.PAD_BTN_XS)
	_button(th, &"FolderTab", [tab, _tex(dir, "tab_hover.png", SLICE_TAB, UiTokens.PAD_BTN_XS), tab, soon],
		[INK_DIM, INK, INK_DIM, INK_FAINT], fonts["mono_label"], UiTokens.SIZE_META)
	_button(th, &"FolderTabSelected", [selected, selected, selected, soon], [INK, INK, INK, INK_FAINT],
		fonts["mono_label"], UiTokens.SIZE_META)
	_button(th, &"FolderTabSoon", [soon, soon, soon, soon], [INK_FAINT, INK_FAINT, INK_FAINT, INK_FAINT],
		fonts["mono_label"], UiTokens.SIZE_META)

	_button(th, &"PrimaryButton", [_flat(STAMP, STAMP_DEEP, UiTokens.PAD_CTA),
		_flat(STAMP_LIGHT, STAMP_DEEP, UiTokens.PAD_CTA), _flat(STAMP_DEEP, STAMP_DEEP, UiTokens.PAD_CTA),
		_flat(PRESSED, EDGE, UiTokens.PAD_CTA)], [PAPER, PAPER, PAPER, INK_FAINT], fonts["sans_sb"], UiTokens.SIZE_DATA)
	_button(th, &"InkButton", [_flat(Color.TRANSPARENT, INK_DIM, UiTokens.PAD_BTN),
		_flat(Color.TRANSPARENT, INK, UiTokens.PAD_BTN), _flat(PRESSED, INK, UiTokens.PAD_BTN),
		_flat(Color.TRANSPARENT, EDGE, UiTokens.PAD_BTN)], [INK_MUTED, INK, INK, INK_FAINT],
		fonts["sans_reg"], UiTokens.SIZE_DATA)

	var window := _tex(dir, "window.png", SLICE_WINDOW, UiTokens.PAD_PAGE)
	for side in [SIDE_TOP, SIDE_RIGHT, SIDE_BOTTOM]:
		window.set_expand_margin(side, WINDOW_SHADOW)
	th.set_stylebox("panel", &"FolderWindow", window)
	var card := _flat(PAPER, EDGE, UiTokens.PAD_CARD)
	card.shadow_color = SHADOW
	card.shadow_size = UiTokens.SPACE_XXS
	card.shadow_offset = Vector2(0, UiTokens.BORDER_HAIRLINE)
	th.set_stylebox("panel", &"PaperCard", card)

	th.set_stylebox("normal", &"Stamp", _tex(dir, "stamp.png", SLICE_STAMP, UiTokens.PAD_BTN))
	_label(th, &"Stamp", fonts["mono_sb"], UiTokens.SIZE_SMALL, STAMP)
	# A stamp-red ring drawn on manila: the rail count keeps BadgeLabel's ink, which the system menu's
	# bare YAKINDA label also needs on the paper page.
	var badge := _flat(MANILA, STAMP, Vector2i.ZERO)
	badge.set_border_width_all(UiTokens.BORDER_FOCUS)
	badge.set_corner_radius_all(UiTokens.RADIUS_PILL)
	th.set_stylebox("normal", &"AttentionBadge", badge)
	_label(th, &"AttentionBadge", fonts["mono_sb"], UiTokens.SIZE_MICRO, INK)
	_label(th, &"DataMono", fonts["mono_sb"], UiTokens.SIZE_LEAD, INK)
	_label(th, &"TickerLabel", fonts["mono_reg"], UiTokens.SIZE_SMALL, CREAM_DIM)


## The real window sits flush against the rail: the core's join draws it 16 px left to x=84, and
## the rail's right rule, in the folder's edge colour, is its left edge, so the selected tab's manila
## runs into the band without a seam. Modals float over the office, so their frame is shadowed on all
## four sides. The Sales band-cap chips are 19 px tall: a smaller cut tab.
static func adjust(th: Theme, dir: String, _fonts: Dictionary) -> void:
	_retexture(th, &"WindowPanel", "panel", dir + "assets/window_open.png", SLICE_WINDOW)
	for type in [&"ModalCard", &"ModalPanel"]:
		_retexture(th, type, "panel", dir + "assets/modal.png", SLICE_MODAL).expand_margin_left = WINDOW_SHADOW

	# In the order normal, hover, pressed: the states both variations define.
	var chips := {&"ChromeTabButton": ["chip_idle.png", "chip_hover.png", "chip_idle.png"],
		&"ChromeTabButtonActive": ["chip_selected.png", "chip_selected.png", "chip_selected.png"]}
	for type in chips:
		for i in 3:
			_retexture(th, type, ["normal", "hover", "pressed"][i], dir + "assets/" + chips[type][i], SLICE_CHIP)

	var rail: StyleBoxFlat = th.get_stylebox("panel", &"SideRailPanel").duplicate()
	rail.border_color = FOLDER_EDGE
	th.set_stylebox("panel", &"SideRailPanel", rail)
	# Floats over the 3D office, so it keeps a deeper shadow than a card lying on paper.
	var floating: StyleBoxFlat = th.get_stylebox("panel", &"CardFloating").duplicate()
	floating.shadow_color = SHADOW_FLOAT
	floating.shadow_size = UiTokens.SPACE_S
	floating.shadow_offset = Vector2(0, UiTokens.SPACE_XXS)
	th.set_stylebox("panel", &"CardFloating", floating)
	# The founder's name is accent text on the meeting's ink bubble, where stamp red does not read.
	th.set_color("font_color", &"MeetingFounderName", CREAM_DIM)


static func _tex(dir: String, file: String, slice: Array, pad: Vector2i) -> StyleBoxTexture:
	var sb := StyleBoxTexture.new()
	sb.texture = load(dir + "assets/" + file)
	for side in 4:
		sb.set_texture_margin(side, slice[side])
	_pad(sb, pad)
	return sb


## A target's texture box (its kept content margins and expand margins with it) drawing another file.
static func _retexture(th: Theme, type: StringName, item: String, path: String, slice: Array) -> StyleBoxTexture:
	var sb: StyleBoxTexture = th.get_stylebox(item, type).duplicate()
	sb.texture = load(path)
	for side in 4:
		sb.set_texture_margin(side, slice[side])
	th.set_stylebox(item, type, sb)
	return sb


static func _flat(fill: Color, edge: Color, pad: Vector2i) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = fill
	sb.border_color = edge
	sb.set_border_width_all(UiTokens.BORDER_HAIRLINE)
	sb.set_corner_radius_all(UiTokens.RADIUS_M)
	_pad(sb, pad)
	return sb


static func _pad(sb: StyleBox, pad: Vector2i) -> void:
	sb.content_margin_left = pad.x
	sb.content_margin_right = pad.x
	sb.content_margin_top = pad.y
	sb.content_margin_bottom = pad.y


## boxes and inks in normal, hover, pressed, disabled order.
static func _button(th: Theme, name: StringName, boxes: Array, inks: Array, face: Font, size: int) -> void:
	for i in 4:
		th.set_stylebox(["normal", "hover", "pressed", "disabled"][i], name, boxes[i])
		var ink: String = ["font_color", "font_hover_color", "font_pressed_color", "font_disabled_color"][i]
		th.set_color(ink, name, inks[i])
	th.set_font("font", name, face)
	th.set_font_size("font_size", name, size)


static func _label(th: Theme, name: StringName, face: Font, size: int, ink: Color) -> void:
	th.set_font("font", name, face)
	th.set_font_size("font_size", name, size)
	th.set_color("font_color", name, ink)
