extends Control
## A direction's style tile: one fixed 1920x1080 composition, the same for every direction, drawn in
## that direction's own theme.tres. It runs alone (F6 on the StyleTile.tscn) or under the lab.

@export var yon: String

const BOARD := Vector2(1920, 1080)
## Face rows: [role, variation that draws it, sample key]. Master draws the body face through
## Label itself, which falls back to the default font.
const FACES := [
	["serif_sb", &"TitleSerif", "HR_ROLE_PRODUCT_MANAGER"],
	["sans_reg", &"Label", "TICKER_02"],
	["mono_reg", &"RowMeta", "HR_ROLE_HINT_TESTER"],
]

const Builder := preload("res://sandbox/ui_lab/core/build_direction.gd")


func _ready() -> void:
	TimeManager.hold_clock("ui_lab")
	var dir := "res://sandbox/ui_lab/themes/%s/" % yon
	if ResourceLoader.exists(dir + "theme.tres"):
		theme = load(dir + "theme.tres")
	else:
		push_warning("style_tile: %stheme.tres is not built yet" % dir)
	var direction: Dictionary = load(dir + "direction.gd").get_script_constant_map()
	var board := Control.new()
	board.size = BOARD
	add_child(board)
	var ground := Panel.new()
	ground.theme_type_variation = &"ViewportPanel"
	ground.size = BOARD
	board.add_child(ground)
	_palette(board, direction["PALETTE"])
	_faces(board, direction["FONTS"])
	_controls(board)
	_folder(board)
	_ticker(board)


func _palette(board: Control, palette: Dictionary) -> void:
	var x := 48.0
	for key in palette:
		var frame := Panel.new()
		frame.position = Vector2(x, 48)
		frame.size = Vector2(98, 74)
		board.add_child(frame)
		var swatch := ColorRect.new()
		swatch.color = palette[key]
		swatch.position = Vector2(1, 1)
		swatch.size = Vector2(96, 72)
		frame.add_child(swatch)
		_label(board, Vector2(x, 130), &"RowName", key)
		_label(board, Vector2(x, 156), &"RowMeta", "#" + palette[key].to_html(false).to_upper())
		x += 108.0


## Each row names the role, the face that really draws it, its file and the variation and size.
func _faces(board: Control, fonts: Dictionary) -> void:
	var y := 220.0
	for row in FACES:
		var rows := VBoxContainer.new()
		rows.position = Vector2(48, y)
		board.add_child(rows)
		var caption := _label(rows, Vector2.ZERO, &"SectionLabel", "")
		var sample := _label(rows, Vector2.ZERO, row[1], tr(row[2]))
		_label(rows, Vector2.ZERO, row[1], Builder.GLYPHS).add_theme_font_size_override("font_size", UiTokens.SIZE_ED_HEADLINE)
		caption.text = "%s · %s · %s · %s %d" % [row[0], Builder.face_name(sample.get_theme_font("font")),
			String(fonts.get(row[0], {}).get("file", "")).get_file(), row[1], sample.get_theme_font_size("font_size")]
		y += 136.0


func _controls(board: Control) -> void:
	var x := 48.0
	for pair in [[&"PrimaryButton", "B2B_CHOICE_RENEW_LOWER"], [&"InkButton", "WIN_CLOSE"]]:
		_label(board, Vector2(x, 660), &"SectionLabel", pair[0])
		var button := Button.new()
		button.theme_type_variation = pair[0]
		button.text = tr(pair[1])
		button.focus_mode = Control.FOCUS_NONE
		button.position = Vector2(x, 684)
		board.add_child(button)
		x += 320.0
	_label(board, Vector2(x, 660), &"SectionLabel", "Stamp")
	# A theme cannot rotate a box, so the tilt lives on a plain holder outside any container.
	var tilt := Control.new()
	tilt.position = Vector2(x, 690)
	tilt.rotation_degrees = -4.0
	board.add_child(tilt)
	var stamp := _label(tilt, Vector2.ZERO, &"Stamp", tr("SYS_SOON"))
	tilt.pivot_offset = stamp.get_combined_minimum_size() / 2.0
	_label(board, Vector2(x + 200, 660), &"SectionLabel", "AttentionBadge")
	var badge := _label(board, Vector2(x + 200, 686), &"AttentionBadge", "3")
	badge.custom_minimum_size = Vector2(16, 16)
	badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	badge.vertical_alignment = VERTICAL_ALIGNMENT_CENTER


## The rail's three tab states around an open folder: idle tabs sit behind the window, the
## selected tab is wider and drawn after it, over the window's edge.
func _folder(board: Control) -> void:
	var y := 112.0
	for tab in [[&"FolderTab", "TAB_SALES"], [&"FolderTabSoon", "TAB_MARKETING"]]:
		_tab(board, Vector2(1100, y + 72), tab[0], tr(tab[1]), 84.0)
		y += 72.0
	_label(board, Vector2(1200, 24), &"SectionLabel", "FolderWindow")
	var window := PanelContainer.new()
	window.theme_type_variation = &"FolderWindow"
	window.position = Vector2(1190, 48)
	window.custom_minimum_size = Vector2(682, 600)
	board.add_child(window)
	var page := VBoxContainer.new()
	page.add_theme_constant_override("separation", 12)
	window.add_child(page)
	_label(page, Vector2.ZERO, &"PageTitleSerif", tr("HR_PAGE_TITLE"))
	_label(page, Vector2.ZERO, &"SectionLabel", tr("HR_TAB_ROSTER"))
	var card := PanelContainer.new()
	card.theme_type_variation = &"PaperCard"
	page.add_child(card)
	var lines := VBoxContainer.new()
	card.add_child(lines)
	for line in [[&"RowName", tr("HR_ROLE_PRODUCT_MANAGER")], [&"RowMeta", tr("HR_ROLE_HINT_PRODUCT_MANAGER")],
			[&"DataMono", Fmt.money_exact(1234567)]]:
		var row := HBoxContainer.new()
		lines.add_child(row)
		_label(row, Vector2.ZERO, line[0], line[1]).size_flags_horizontal = Control.SIZE_EXPAND_FILL
		_label(row, Vector2.ZERO, &"SectionLabel", line[0])
	_label(page, Vector2.ZERO, &"SectionLabel", "PaperCard")
	# The selected tab covers the folder's frame band, so its end meets the page; a texture's outer
	# shadow pad (drawn outside by expand_margin_left) is not band.
	var box := window.get_theme_stylebox("panel")
	var band: float = box.texture_margin_left - box.expand_margin_left if box is StyleBoxTexture else float(box.border_width_left)
	_tab(board, Vector2(1100, 112), &"FolderTabSelected", tr("TAB_HR"), window.position.x + band - 1100.0)


func _tab(board: Control, at: Vector2, variation: StringName, text: String, width: float) -> void:
	_label(board, Vector2(at.x - 150, at.y + 24), &"SectionLabel", variation)
	var tab := Button.new()
	tab.theme_type_variation = variation
	tab.text = text
	tab.focus_mode = Control.FOCUS_NONE
	tab.position = at
	tab.custom_minimum_size = Vector2(width, 64)
	board.add_child(tab)


func _ticker(board: Control) -> void:
	_label(board, Vector2(48, BOARD.y - 60), &"SectionLabel", "NewsPanel · TickerLabel")
	var band := Panel.new()
	band.theme_type_variation = &"NewsPanel"
	band.position = Vector2(0, BOARD.y - 34)
	band.size = Vector2(BOARD.x, 34)
	board.add_child(band)
	var line := _label(band, Vector2(16, 0), &"TickerLabel", tr("TICKER_01"))
	line.size = Vector2(BOARD.x - 32, 34)
	line.vertical_alignment = VERTICAL_ALIGNMENT_CENTER


func _label(parent: Node, at: Vector2, variation: StringName, text: String) -> Label:
	var label := Label.new()
	label.theme_type_variation = variation
	label.text = text
	label.position = at
	parent.add_child(label)
	return label
