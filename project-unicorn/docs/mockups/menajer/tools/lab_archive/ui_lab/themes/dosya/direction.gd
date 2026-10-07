extends RefCounted
## Dosya: a cool grey folder opened on the desk. Rail tabs are folder tabs with a slanted top-right
## shoulder; the selected one is the open folder's own tab and runs into its frame. Pages and cards
## are off-white paper in navy ink with thin rules, red ink only for attention, and the frame
## bands are navy. Titles are Space Grotesk; prose, labels and figures IBM Plex Mono; names and
## plain labels IBM Plex Sans.
## assets/make_assets.py draws the PNGs from these colours and the texture geometry below: a change
## to either needs it run again.

const PAPER := Color("#F8F8F5")
const FOLDER := Color("#E9ECEF")
const FOLDER_DEEP := Color("#DFE4E8")
const DRAWER := Color("#C9D0D7")
const RULE := Color("#CDD3DA")
const RULE_DARK := Color("#9DA8B5")
const INK := Color("#17273F")
const INK_SOFT := Color("#44536A")
const INK_DIM := Color("#6A7789")
const INK_FAINT := Color("#97A1AF")
const INK_BLUE := Color("#2B4C7E")
const RED_INK := Color("#AE2216")
const FRAME := Color("#0F1B2D")
const FRAME_LINE := Color("#26374F")
const FRAME_TEXT := Color("#EDF1F5")
const FRAME_TEXT_DIM := Color("#8E9BAD")
const FRAME_FAINT := Color("#66768B")
const FRAME_KEY := Color("#1C2F4D")
const CARD_SHADOW := Color("#17273F24")

const PALETTE := {"paper": PAPER, "folder": FOLDER, "drawer": DRAWER, "rule": RULE_DARK, "ink": INK,
	"ink_blue": INK_BLUE, "red_ink": RED_INK, "frame": FRAME}

## The code paints the rail's captions and icons in UiTokens INK_DIM and ACCENT_DEEP; on these tabs
## they read at 2.99:1 (idle, FOLDER_DEEP) and 3.98:1 (selected, FOLDER), under the master rail's
## 3.59:1 and 4.42:1.
const TOKENS := {
	"CARD_BG": PAPER,
	"ON_INK": PAPER,
	"SURFACE_INPUT": PAPER,
	"BG_BODY": FOLDER_DEEP,
	"BG_PANEL": DRAWER,
	"SURFACE_PRESSED": FOLDER,
	"SURFACE_ROW_TINT": FOLDER,
	"SURFACE_SUNKEN": FOLDER_DEEP,
	"DIVIDER_LIGHT": FOLDER_DEEP,
	"CARD_BORDER": RULE,
	"BORDER_HOVER": RULE_DARK,
	"INK": INK,
	"INK_MUTED": INK_SOFT,
	"INK_DIM": INK_DIM,
	"INK_FAINT": INK_FAINT,
	"ACCENT": INK_BLUE,
	"ACCENT_HOVER": INK_BLUE,
	"ACCENT_PRESSED": INK,
	"ACCENT_DEEP": INK_BLUE,
	"NEGATIVE": RED_INK,
	"BG_TOPBAR": FRAME,
	"SEPARATOR": FRAME_LINE,
	"BG_AVATAR": FRAME_LINE,
	"CARD_BORDER_CHROME": FRAME_LINE,
	"CREAM": FRAME_TEXT,
	"CREAM_DIM": FRAME_TEXT_DIM,
	"INK_MUTED_CHROME": FRAME_TEXT_DIM,
	"INK_DIM_CHROME": FRAME_FAINT,
	"INK_FAINT_CHROME": FRAME_FAINT,
	"BORDER_HOVER_CHROME": FRAME_FAINT,
	"DOT_IDLE_CHROME": FRAME_FAINT,
	"ACCENT_DIM": FRAME_KEY,
}

## No serif: prose reads in mono, titles in Space Grotesk. No tnum: Plex Sans and Plex Mono carry no
## such feature and their figures are already tabular.
const FONTS := {
	"serif_reg": {"file": "fonts/IBMPlexMono/IBMPlexMono-Regular.ttf"},
	"serif_sb": {"file": "fonts/SpaceGrotesk/SpaceGrotesk-VF.ttf", "axes": {"wght": 600}},
	"serif_it": {"file": "fonts/IBMPlexSans/IBMPlexSans-Italic-VF.ttf", "axes": {"wght": 400, "wdth": 100}},
	"sans_reg": {"file": "fonts/IBMPlexSans/IBMPlexSans-VF.ttf", "axes": {"wght": 400, "wdth": 100}},
	"sans_sb": {"file": "fonts/IBMPlexSans/IBMPlexSans-VF.ttf", "axes": {"wght": 600, "wdth": 100}},
	"mono_reg": {"file": "fonts/IBMPlexMono/IBMPlexMono-Regular.ttf"},
	"mono_label": {"file": "fonts/IBMPlexMono/IBMPlexMono-Medium.ttf"},
	"mono_sb": {"file": "fonts/IBMPlexMono/IBMPlexMono-SemiBold.ttf"},
}

## Texture geometry, read by assets/make_assets.py too: nine-slice lines [left, top, right, bottom]
## and the shadow room a frame texture keeps outside its rule, drawn out there by expand margins. A
## tab's 45 degree shoulder spans (right - 2) px, inside its top-right corner patch. A frame's top
## slice is its shadow room, its band, the page's hairline and the three paper texels the page's
## faint shade fades out in. FolderWindow's left slice keeps one paper texel: a selected tab laid
## over it ends on the page.
const TAB_SLICE := [2, 12, 12, 2]
const CHIP_SLICE := [2, 6, 6, 2]
const WINDOW_SLICE := [16, 16, 20, 20]
const CLOSED_SLICE := [14, 16, 20, 20]
const WINDOW_SHADOW := [0, 0, 4, 4]
const FOLDER_SLICE := [24, 24, 24, 24]
const FOLDER_SHADOW := [8, 8, 8, 8]


static func canonical(th: Theme, dir: String, fonts: Dictionary) -> void:
	var tab := _tex(dir, "tab_idle.png", TAB_SLICE, UiTokens.PAD_BTN_XS)
	var tab_hover := _tex(dir, "tab_idle_hover.png", TAB_SLICE, UiTokens.PAD_BTN_XS)
	var soon := _flat(FOLDER, FOLDER, 0, UiTokens.PAD_BTN_XS)
	_button(th, &"FolderTab", [tab, tab_hover, tab_hover, soon], [INK_SOFT, INK, INK, INK_FAINT],
		fonts["mono_label"], UiTokens.SIZE_META)
	var selected := _tex(dir, "tab_selected.png", TAB_SLICE, UiTokens.PAD_BTN_XS)
	_button(th, &"FolderTabSelected", [selected, selected, selected, selected], [INK, INK, INK, INK],
		fonts["mono_label"], UiTokens.SIZE_META)
	_button(th, &"FolderTabSoon", [soon, soon, soon, soon], [INK_FAINT, INK_FAINT, INK_FAINT, INK_FAINT],
		fonts["mono_label"], UiTokens.SIZE_META)

	var cta := UiTokens.PAD_CTA
	_button(th, &"PrimaryButton", [_flat(INK, INK, 0, cta), _flat(INK_BLUE, INK_BLUE, 0, cta),
		_flat(FRAME, FRAME, 0, cta), _flat(FOLDER, RULE, UiTokens.BORDER_HAIRLINE, cta)],
		[PAPER, PAPER, PAPER, INK_DIM], fonts["mono_sb"], UiTokens.SIZE_DATA)
	var line := UiTokens.BORDER_HAIRLINE
	var pad := UiTokens.PAD_BTN
	_button(th, &"InkButton", [_flat(Color.TRANSPARENT, INK_SOFT, line, pad), _flat(Color.TRANSPARENT, INK, line, pad),
		_flat(FOLDER, INK, line, pad), _flat(Color.TRANSPARENT, RULE, line, pad)],
		[INK_SOFT, INK, INK, INK_FAINT], fonts["mono_label"], UiTokens.SIZE_DATA)

	# The folder closed: ruled on four sides, shadowed right and down only.
	var folder := _tex(dir, "window_closed.png", CLOSED_SLICE, UiTokens.PAD_PAGE)
	_grow(folder, WINDOW_SHADOW)
	th.set_stylebox("panel", &"FolderWindow", folder)
	var card := _flat(PAPER, RULE, line, UiTokens.PAD_CARD, UiTokens.RADIUS_M)
	card.shadow_color = CARD_SHADOW
	card.shadow_size = UiTokens.SPACE_XXS
	card.shadow_offset = Vector2(0, UiTokens.SPACE_XXS)
	th.set_stylebox("panel", &"PaperCard", card)

	# A square file label instead of a stamp: navy frame, a heavier left edge.
	var label := _flat(PAPER, INK, line, UiTokens.PAD_BTN_XS)
	label.border_width_left = UiTokens.BORDER_ACCENT
	_label(th, &"Stamp", fonts["mono_sb"], UiTokens.SIZE_SMALL, INK)
	th.set_stylebox("normal", &"Stamp", label)
	# A red-ink ring around the count: the digit keeps BadgeLabel's navy, so no chip text changes.
	var ring := _flat(PAPER, RED_INK, UiTokens.BORDER_FOCUS, Vector2i.ZERO, UiTokens.RADIUS_PILL)
	_label(th, &"AttentionBadge", fonts["mono_reg"], UiTokens.SIZE_MICRO, INK)
	th.set_stylebox("normal", &"AttentionBadge", ring)
	_label(th, &"DataMono", fonts["mono_sb"], UiTokens.SIZE_LEAD, INK)
	_label(th, &"TickerLabel", fonts["mono_reg"], UiTokens.SIZE_SMALL, FRAME_TEXT_DIM)


## Targets' own boxes are copied before a texture is swapped in, so their content margins stay.
static func adjust(th: Theme, dir: String, _fonts: Dictionary) -> void:
	# A tab's window stands against the rail, whose right rule, in the folder's rule colour, is the
	# window's left edge; the selected tab breaks that rule where it runs into the frame. So this
	# frame draws no rule on its left; it keeps FolderWindow's shadow room, and the core's join
	# stretches it left to x=84.
	var window: StyleBoxTexture = th.get_stylebox("panel", &"WindowPanel").duplicate()
	th.set_stylebox("panel", &"WindowPanel", _skin(window, dir + "assets/window.png", WINDOW_SLICE))
	# Modals float over the office: their folder casts its shadow on every side.
	for type in [&"ModalCard", &"ModalPanel"]:
		var modal := _skin(th.get_stylebox("panel", type).duplicate(), dir + "assets/folder.png", FOLDER_SLICE)
		_grow(modal, FOLDER_SHADOW)
		th.set_stylebox("panel", type, modal)
	var rail: StyleBoxFlat = th.get_stylebox("panel", &"SideRailPanel").duplicate()
	rail.border_color = RULE_DARK
	th.set_stylebox("panel", &"SideRailPanel", rail)
	# The Sales band selector is 19 px tall and stands alone: small closed tabs.
	for state in ["normal", "hover", "pressed"]:
		var idle := "chip_idle.png" if state == "normal" else "chip_idle_hover.png"
		for pair in [[&"ChromeTabButton", idle], [&"ChromeTabButtonActive", "chip_selected.png"]]:
			var chip := _skin(th.get_stylebox(state, pair[0]).duplicate(), dir + "assets/" + pair[1], CHIP_SLICE)
			th.set_stylebox(state, pair[0], chip)
	# The founder's name is accent text on the meeting's ink bubble, where the blue accent does not read.
	th.set_color("font_color", &"MeetingFounderName", FRAME_TEXT_DIM)


static func _flat(fill: Color, edge: Color, width: int, pad: Vector2i, radius := UiTokens.RADIUS_NONE) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = fill
	sb.border_color = edge
	sb.set_border_width_all(width)
	sb.set_corner_radius_all(radius)
	_pad(sb, pad)
	return sb


static func _tex(dir: String, file: String, slice: Array, pad: Vector2i) -> StyleBoxTexture:
	var sb := _skin(StyleBoxTexture.new(), dir + "assets/" + file, slice)
	_pad(sb, pad)
	return sb


static func _skin(sb: StyleBoxTexture, file: String, slice: Array) -> StyleBoxTexture:
	sb.texture = load(file)
	for side in 4:
		sb.set_texture_margin(side, slice[side])
	return sb


static func _grow(sb: StyleBoxTexture, room: Array) -> void:
	for side in 4:
		sb.set_expand_margin(side, room[side])


static func _pad(sb: StyleBox, pad: Vector2i) -> void:
	sb.content_margin_left = pad.x
	sb.content_margin_right = pad.x
	sb.content_margin_top = pad.y
	sb.content_margin_bottom = pad.y


## boxes and inks in normal, hover, pressed, disabled order.
static func _button(th: Theme, name: StringName, boxes: Array, inks: Array, face: Font, size: int) -> void:
	for i in 4:
		th.set_stylebox(["normal", "hover", "pressed", "disabled"][i], name, boxes[i])
		th.set_color(["font_color", "font_hover_color", "font_pressed_color", "font_disabled_color"][i], name, inks[i])
	th.set_font("font", name, face)
	th.set_font_size("font_size", name, size)


static func _label(th: Theme, name: StringName, face: Font, size: int, ink: Color) -> void:
	th.set_font("font", name, face)
	th.set_font_size("font_size", name, size)
	th.set_color("font_color", name, ink)
