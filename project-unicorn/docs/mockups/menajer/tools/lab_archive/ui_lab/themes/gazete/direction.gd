extends RefCounted
## gazete: a newsprint archive. The frame and rail are printing black, folder tabs and bands are
## paper, pages are newsprint ruled in grey hairlines; one spot red marks kickers, hover and
## attention. Titles and prose set in Newsreader, labels in Libre Franklin, figures in IBM Plex Mono.

const INK := Color("#1C1B19")
const FRAME := Color("#0A0908")
const NEWSPRINT := Color("#E9E7E0")
const PAPER := Color("#F9F8F4")
const RULE := Color("#A09C93")
const RED := Color("#AC2E1C")
const INK_MUTED := Color("#4A4843")
const INK_DIM := Color("#67645D")
const INK_FAINT := Color("#908C84")
const INK_HOVER := Color("#3A3834")
const INPUT := Color("#FBFAF7")
const PRESSED := Color("#E0DED6")
const SUNKEN := Color("#D8D5CD")
const ROW_TINT := Color("#EFEEE8")
const SOON := Color("#DEDCD4")
const TICKER := Color("#BDB9B0")
const FRAME_CREAM := Color("#F0EEE7")
const FRAME_DIM := Color("#99958C")
const FRAME_FAINT := Color("#7A766E")
const FRAME_KEY := Color("#837F77")
const FRAME_KEY_HOVER := Color("#B5B1A8")
const FRAME_RULE := Color("#2E2C28")
const FRAME_EDGE := Color("#3A3733")
const FRAME_EDGE_HOVER := Color("#55514B")
const FRAME_DOT := Color("#4D4944")
const FRAME_KEY_FILL := Color("#2B2620")
const CARD_SHADOW := Color(INK, 0.12)
const BADGE_TINT := Color("#EDDAD4")  # RED at .15 over PAPER, opaque so the count's contrast is measured true

const PALETTE := {"ink": INK, "newsprint": NEWSPRINT, "paper": PAPER, "rule": RULE, "red_ink": RED,
	"dim_ink": INK_DIM, "ticker": TICKER}

## The frame keeps the news band's orange accent (ACCENT_CHROME is not listed): code paints the
## logo and the ticker sources in it and no theme reaches them.
const TOKENS := {
	"BG_BODY": NEWSPRINT, "ON_INK": PAPER, "BG_PANEL": FRAME, "CARD_BG": PAPER, "SURFACE_INPUT": INPUT,
	"SURFACE_PRESSED": PRESSED, "SURFACE_SUNKEN": SUNKEN, "SURFACE_ROW_TINT": ROW_TINT,
	"INK": INK, "INK_MUTED": INK_MUTED, "INK_DIM": INK_DIM, "INK_FAINT": INK_FAINT,
	"CARD_BORDER": RULE, "BORDER_HOVER": INK_MUTED, "DIVIDER_LIGHT": RULE,
	"ACCENT": INK, "ACCENT_HOVER": INK_HOVER, "ACCENT_PRESSED": FRAME, "ACCENT_DEEP": RED,
	"BG_TOPBAR": FRAME, "SEPARATOR": FRAME_RULE, "CREAM": FRAME_CREAM, "CREAM_DIM": FRAME_DIM,
	"INK_FAINT_CHROME": FRAME_FAINT, "INK_DIM_CHROME": FRAME_KEY, "INK_MUTED_CHROME": FRAME_KEY_HOVER,
	"CARD_BORDER_CHROME": FRAME_EDGE, "BORDER_HOVER_CHROME": FRAME_EDGE_HOVER, "DOT_IDLE_CHROME": FRAME_DOT,
	"ACCENT_DIM": FRAME_KEY_FILL,
}

## Labels, kickers and buttons set in Libre Franklin (mono_label too), as a newspaper sets them;
## figures stay in Plex Mono, where every digit has one advance. Franklin has no tnum, so its own
## figures are proportional, and its default instance is Thin, so every Franklin role names its weight.
const FONTS := {
	"serif_reg": {"file": "fonts/Newsreader/Newsreader-VF.ttf", "axes": {"wght": 400, "opsz": 14}},
	"serif_sb": {"file": "fonts/Newsreader/Newsreader-VF.ttf", "axes": {"wght": 600, "opsz": 24}},
	"serif_it": {"file": "fonts/Newsreader/Newsreader-Italic-VF.ttf", "axes": {"wght": 400, "opsz": 14}},
	"sans_reg": {"file": "fonts/LibreFranklin/LibreFranklin-VF.ttf", "axes": {"wght": 400}},
	"sans_sb": {"file": "fonts/LibreFranklin/LibreFranklin-VF.ttf", "axes": {"wght": 600}},
	"mono_reg": {"file": "fonts/IBMPlexMono/IBMPlexMono-Regular.ttf"},
	"mono_label": {"file": "fonts/LibreFranklin/LibreFranklin-VF.ttf", "axes": {"wght": 500}},
	"mono_sb": {"file": "fonts/IBMPlexMono/IBMPlexMono-SemiBold.ttf"},
	"stamp": {"file": "fonts/LibreFranklin/LibreFranklin-VF.ttf", "axes": {"wght": 700}, "spacing_glyph": 1},
}

## Texture geometry, read by assets/make_assets.py too: slice margins [left, top, right, bottom], and
## the shadow each folder casts outside its band, grown back so the band edge stays on the box edge.
## A tab's slanted shoulder spans (top - 2) px; a frame's slice is its shadow, its band, the page's
## hairline and one paper texel.
const TAB_SLICE := [4, 10, 12, 4]
const WINDOW_SLICE := [16, 16, 22, 22]
const WINDOW_SHADOW := [0, 0, 6, 6]
const FOLDER_SLICE := [31, 27, 31, 35]
const FOLDER_SHADOW := [15, 11, 15, 19]
const STAMP_SLICE := [4, 4, 4, 4]
## Rich text lays its lines on the drawing face's own ascent and descent, and Newsreader's line box
## is 1.0 em against Source Serif 4's 1.37: set in it, rich text runs solid and every box sized to it
## shrinks (the event card by 48 px). Each rich text type's serif faces carry the difference as
## [spacing_top, spacing_bottom] at the size it sets: 15 px 16/6 against 12/4, 13 px 14/5 against 10/4.
const RICH_LEADING := {&"BodyRich": [4, 2], &"RichTextLabel": [4, 1]}
const STATES := ["normal", "hover", "pressed", "disabled"]
const INKS := ["font_color", "font_hover_color", "font_pressed_color", "font_disabled_color"]


static func canonical(th: Theme, dir: String, fonts: Dictionary) -> void:
	var idle := _tab(dir, "tab_idle.png")
	var hover := _tab(dir, "tab_hover.png")
	var selected := _tab(dir, "tab_selected.png")
	# A tab that is not open yet is faded and flat: no shoulder.
	var soon := _flat(SOON, SOON, 0, UiTokens.PAD_BTN_XS)
	var label: Font = fonts["mono_label"]
	_button(th, &"FolderTab", [idle, hover, hover, soon], [INK_DIM, INK, INK, INK_FAINT], label, UiTokens.SIZE_META)
	_button(th, &"FolderTabSelected", [selected, selected, selected, soon], [INK, INK, INK, INK_FAINT], label, UiTokens.SIZE_META)
	_button(th, &"FolderTabSoon", [soon, soon, soon, soon], [INK_FAINT, INK_FAINT, INK_FAINT, INK_FAINT], label, UiTokens.SIZE_META)

	var cta := UiTokens.PAD_CTA
	var line := UiTokens.BORDER_HAIRLINE
	_button(th, &"PrimaryButton", [_flat(INK, INK, 0, cta), _flat(INK_HOVER, INK_HOVER, 0, cta), _flat(FRAME, FRAME, 0, cta),
		_flat(PRESSED, RULE, line, cta)], [PAPER, PAPER, PAPER, INK_DIM], fonts["sans_sb"], UiTokens.SIZE_DATA)
	var pad := UiTokens.PAD_BTN
	_button(th, &"InkButton", [_flat(Color.TRANSPARENT, INK_MUTED, line, pad), _flat(Color.TRANSPARENT, INK, line, pad),
		_flat(PRESSED, INK, line, pad), _flat(Color.TRANSPARENT, RULE, line, pad)], [INK_MUTED, INK, INK, INK_FAINT],
		label, UiTokens.SIZE_DATA)

	# The closed window casts its shadow right and down only, so its left slice holds no shadow.
	var folder := _texture(dir, "window_closed.png", WINDOW_SLICE, UiTokens.PAD_PAGE)
	_grow(folder, WINDOW_SHADOW)
	th.set_stylebox("panel", &"FolderWindow", folder)
	var card := _flat(PAPER, RULE, UiTokens.BORDER_HAIRLINE, UiTokens.PAD_CARD)
	card.shadow_color = CARD_SHADOW
	card.shadow_size = UiTokens.SPACE_XXS
	card.shadow_offset = Vector2(0, UiTokens.BORDER_HAIRLINE)
	th.set_stylebox("panel", &"PaperCard", card)

	th.set_stylebox("normal", &"Stamp", _texture(dir, "stamp.png", STAMP_SLICE, UiTokens.PAD_BTN_S))
	th.set_font("font", &"Stamp", fonts["stamp"])
	th.set_font_size("font_size", &"Stamp", UiTokens.SIZE_SMALL)
	th.set_color("font_color", &"Stamp", PAPER)
	# A red-ink ring around a pale tint: the rail count reads in BadgeLabel's own ink, which the
	# system menu's bare YAKINDA label also needs on paper.
	var ring := _flat(BADGE_TINT, RED, UiTokens.BORDER_FOCUS, Vector2i.ZERO)
	ring.set_corner_radius_all(UiTokens.RADIUS_PILL)
	th.set_stylebox("normal", &"AttentionBadge", ring)
	th.set_font("font", &"AttentionBadge", fonts["mono_sb"])
	th.set_font_size("font_size", &"AttentionBadge", UiTokens.SIZE_MICRO)
	th.set_color("font_color", &"AttentionBadge", INK)
	th.set_font("font", &"DataMono", fonts["mono_sb"])
	th.set_font_size("font_size", &"DataMono", UiTokens.SIZE_DATA)
	th.set_color("font_color", &"DataMono", INK)
	th.set_font("font", &"TickerLabel", fonts["sans_reg"])
	th.set_font_size("font_size", &"TickerLabel", UiTokens.SIZE_SMALL)
	th.set_color("font_color", &"TickerLabel", TICKER)


static func adjust(th: Theme, dir: String, _fonts: Dictionary) -> void:
	# A window opens on the rail: its left side has no rule, because the rail's own right rule
	# runs there and the selected tab covers it, so tab and band join without a line.
	var window := _texture(dir, "window.png", WINDOW_SLICE, UiTokens.PAD_PAGE)
	_grow(window, WINDOW_SHADOW)
	th.set_stylebox("panel", &"WindowPanel", _refit(th.get_stylebox("panel", &"WindowPanel"), window))
	# A modal floats over the dimmed office: its folder casts a soft shadow on every side.
	var modal := _texture(dir, "modal.png", FOLDER_SLICE, UiTokens.PAD_PAGE)
	_grow(modal, FOLDER_SHADOW)
	for type in [&"ModalCard", &"ModalPanel"]:
		th.set_stylebox("panel", type, _refit(th.get_stylebox("panel", type), modal))
	# The Sales band-cap selector is a row of small tabs away from any window: its selected tab
	# closes its right side.
	var closed := _tab(dir, "tab_selected_closed.png")
	for state in ["normal", "hover", "pressed"]:
		th.set_stylebox(state, &"ChromeTabButtonActive", _refit(th.get_stylebox(state, &"ChromeTabButtonActive"), closed))
	# A newspaper table head: a heavy ink rule over the column names, a hairline under them.
	var head: StyleBoxFlat = th.get_stylebox("panel", &"HeaderBand").duplicate()
	head.border_color = INK
	head.border_width_top = UiTokens.BORDER_FOCUS
	head.border_width_bottom = UiTokens.BORDER_HAIRLINE
	th.set_stylebox("panel", &"HeaderBand", head)
	# The founder's name was accent text on the ink bubble; with an ink accent it takes the band grey.
	th.set_color("font_color", &"MeetingFounderName", TICKER)
	for type in RICH_LEADING:
		for key in ["normal_font", "bold_font", "bold_italics_font", "italics_font"]:
			var face := th.get_font(key, type).duplicate() as FontVariation
			face.spacing_top = RICH_LEADING[type][0]
			face.spacing_bottom = RICH_LEADING[type][1]
			th.set_font(key, type, face)


static func _tab(dir: String, file: String) -> StyleBoxTexture:
	return _texture(dir, file, TAB_SLICE, UiTokens.PAD_BTN_XS)


static func _texture(dir: String, file: String, slice: Array, pad: Vector2i) -> StyleBoxTexture:
	var sb := StyleBoxTexture.new()
	sb.texture = load(dir + "assets/" + file)
	for side in 4:
		sb.set_texture_margin(side, slice[side])
	_pad(sb, pad)
	return sb


static func _flat(fill: Color, edge: Color, width: int, pad: Vector2i) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = fill
	sb.border_color = edge
	sb.set_border_width_all(width)
	sb.set_corner_radius_all(UiTokens.RADIUS_M)
	_pad(sb, pad)
	return sb


static func _pad(sb: StyleBox, pad: Vector2i) -> void:
	sb.content_margin_left = pad.x
	sb.content_margin_right = pad.x
	sb.content_margin_top = pad.y
	sb.content_margin_bottom = pad.y


static func _grow(sb: StyleBoxTexture, grow: Array) -> void:
	for side in 4:
		sb.set_expand_margin(side, grow[side])


## A copy of `sb` holding the effective content margins of the box it replaces.
static func _refit(old: StyleBox, sb: StyleBox) -> StyleBox:
	var out: StyleBox = sb.duplicate()
	for side in 4:
		out.set_content_margin(side, old.get_margin(side))
	return out


## Boxes and inks in normal, hover, pressed, disabled order; focus text follows the resting ink.
static func _button(th: Theme, name: StringName, boxes: Array, inks: Array, face: Font, size: int) -> void:
	for i in 4:
		th.set_stylebox(STATES[i], name, boxes[i])
		th.set_color(INKS[i], name, inks[i])
	th.set_color("font_focus_color", name, inks[0])
	th.set_font("font", name, face)
	th.set_font_size("font_size", name, size)
