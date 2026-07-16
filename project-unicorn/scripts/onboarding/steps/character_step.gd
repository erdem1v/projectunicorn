extends OnboardingStep

# Page 1 — Karakter. Identity framing, not stats: optional founder name +
# portrait pick from the FounderConstants.PORTRAIT_IDS pool (data-driven grid —
# an added 12th asset appears with a one-line const change). Gender is implied
# by the portrait; there is no separate field.
#
# Thin-skeleton scene: the .tscn holds only the root; the layout is built here
# from theme variations + UiTokens (term_sheet_table_scene.gd precedent).

const PORTRAIT_CARD := preload("res://scenes/ui/components/DialoguePortraitCard.tscn")

const GRID_COLUMNS := 6
const CELL_SIZE := Vector2(132, 156)

var _portrait_id: String = ""
var _cells: Dictionary = {}   # portrait_id -> PanelContainer

var _preview_card: DialoguePortraitCard = null
var _preview_name: Label = null
var _selected_chip: Label = null
var _name_input: LineEdit = null


func _ready() -> void:
	_build()
	_refresh_visual()


func _build() -> void:
	var page := VBoxContainer.new()
	page.set_anchors_preset(Control.PRESET_FULL_RECT)
	page.add_theme_constant_override("separation", 6)
	add_child(page)

	page.add_child(UiFactory.make_label(tr("ONB_P1_TITLE"), &"TitleSerifCream"))
	page.add_child(UiFactory.make_label(tr("ONB_P1_SUB"), &"SubtitleSerifCream"))
	page.add_child(_spacer(10))

	var content := HBoxContainer.new()
	content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 28)
	page.add_child(content)

	# --- Left: live preview card + name input ---
	var left := VBoxContainer.new()
	left.custom_minimum_size = Vector2(240, 0)
	left.add_theme_constant_override("separation", 6)
	content.add_child(left)

	_selected_chip = UiFactory.make_label("", &"ZoneLabel")
	left.add_child(_selected_chip)

	_preview_card = PORTRAIT_CARD.instantiate()
	_preview_card.custom_minimum_size = Vector2(240, 300)
	left.add_child(_preview_card)

	_preview_name = UiFactory.make_label("Founder", &"DialogueName")
	left.add_child(_preview_name)
	left.add_child(UiFactory.make_label(tr("ONB_FOUNDER_TAG"), &"DialogueTag"))

	left.add_child(_spacer(12))
	left.add_child(UiFactory.make_label(tr("ONB_NAME_LABEL"), &"ZoneLabel"))
	_name_input = LineEdit.new()
	_name_input.theme_type_variation = &"DialogueInput"
	_name_input.max_length = 40
	_name_input.placeholder_text = tr("ONB_NAME_PLACEHOLDER")
	_name_input.text_changed.connect(_on_name_changed)
	left.add_child(_name_input)

	# --- Right: portrait grid ---
	var right := VBoxContainer.new()
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right.add_theme_constant_override("separation", 10)
	content.add_child(right)

	right.add_child(UiFactory.make_label(
		tr("ONB_PORTRAIT_HEADER") % FounderConstants.PORTRAIT_IDS.size(), &"ZoneLabel"))

	var grid := GridContainer.new()
	grid.columns = GRID_COLUMNS
	grid.add_theme_constant_override("h_separation", 10)
	grid.add_theme_constant_override("v_separation", 10)
	right.add_child(grid)

	for portrait_id in FounderConstants.PORTRAIT_IDS:
		grid.add_child(_make_cell(portrait_id))


func _make_cell(portrait_id: String) -> PanelContainer:
	var cell := PanelContainer.new()
	cell.theme_type_variation = &"PortraitCell"
	cell.custom_minimum_size = CELL_SIZE
	cell.clip_contents = true
	var path: String = FounderConstants.portrait_path(portrait_id)
	if ResourceLoader.exists(path):
		var tex := TextureRect.new()
		tex.texture = load(path)
		tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		tex.mouse_filter = Control.MOUSE_FILTER_IGNORE
		cell.add_child(tex)
	else:
		# Missing asset — charcoal cell with the portrait number, never a crash.
		push_warning("[CharacterStep] portrait missing: %s" % path)
		var fallback := UiFactory.make_label(portrait_id.get_slice("_", 1), &"DialogueNumber")
		fallback.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		fallback.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		cell.add_child(fallback)
	cell.gui_input.connect(_on_cell_input.bind(portrait_id))
	_cells[portrait_id] = cell
	return cell


func _on_cell_input(event: InputEvent, portrait_id: String) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_portrait_id = portrait_id
		_refresh_visual()
		validity_changed.emit(is_valid())


func _on_name_changed(_text: String) -> void:
	_refresh_preview_name()


func _refresh_preview_name() -> void:
	var display: String = _name_input.text.strip_edges() if _name_input != null else ""
	_preview_name.text = display if display != "" else "Founder"


func _refresh_visual() -> void:
	for portrait_id in _cells:
		var cell: PanelContainer = _cells[portrait_id]
		var selected: bool = (portrait_id == _portrait_id)
		cell.theme_type_variation = &"PortraitCellSelected" if selected else &"PortraitCell"
		cell.modulate = Color(1, 1, 1, 1.0 if selected else 0.55)
	if _portrait_id != "":
		_preview_card.set_portrait(FounderConstants.portrait_path(_portrait_id), "")
		_selected_chip.text = tr("ONB_SELECTED_CHIP") % _portrait_id.get_slice("_", 1)
	_refresh_preview_name()


func _spacer(height: int) -> Control:
	var s := Control.new()
	s.custom_minimum_size = Vector2(0, height)
	return s


# --- OnboardingStep contract ---

func prefill(draft: Dictionary) -> void:
	if not is_node_ready():
		await ready
	_name_input.text = draft.get("founder_name", "")
	_portrait_id = draft.get("portrait_id", "")
	if _portrait_id == "" and not FounderConstants.PORTRAIT_IDS.is_empty():
		# Mockup default: first portrait pre-selected — a face from the first frame.
		_portrait_id = FounderConstants.PORTRAIT_IDS[0]
	_refresh_visual()
	validity_changed.emit(is_valid())


func is_valid() -> bool:
	return _portrait_id != ""


func collect_payload() -> Dictionary:
	return {
		"founder_name": _name_input.text.strip_edges(),
		"portrait_id": _portrait_id,
	}
