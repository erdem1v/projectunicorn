extends OnboardingStep

# Step 1, Karakter: the founder's name and face. The face picked here is the one standing in the flat behind the
# papers, so the step shows no preview of its own. The grid holds the portraits there are, then places for faces to
# come.

const GRID_COLUMNS := 8
const CELL := [Vector2(152, 190), Vector2(119, 149)]   # [WORKING] a portrait's 4:5, eight across the paper
const NAME_W := 360

var _portrait_id := ""
var _cells := {}   # portrait_id -> Button
var _name_input: LineEdit
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	var page := VBoxContainer.new()
	page.set_anchors_preset(Control.PRESET_FULL_RECT)
	page.add_theme_constant_override("separation", UiTokens.SPACE_XL)
	add_child(page)
	page.add_child(_head("ONB_STEP_CHARACTER", "", true))

	var name_row := HBoxContainer.new()
	name_row.add_theme_constant_override("separation", UiTokens.SPACE_L)
	var name_label := UiFactory.make_label(Fmt.upper(tr("ONB_NAME_LABEL")), &"KeyLabel")
	name_row.add_child(name_label)
	_name_input = LineEdit.new()
	_name_input.custom_minimum_size.x = NAME_W
	_name_input.max_length = 40
	# An empty name is the role (envanter meet-18): the field shows it, faint, instead of a sentence beside it.
	_name_input.placeholder_text = tr("HR_ROLE_FOUNDER")
	_name_input.text_changed.connect(changed.emit.unbind(1))
	name_row.add_child(_name_input)
	page.add_child(name_row)

	var cell: Vector2 = CELL[int(short)]
	var grid := GridContainer.new()
	grid.columns = GRID_COLUMNS
	grid.add_theme_constant_override("h_separation", UiTokens.SPACE_L)
	grid.add_theme_constant_override("v_separation", UiTokens.SPACE_L)
	page.add_child(grid)
	var group := ButtonGroup.new()
	for portrait_id: String in FounderConstants.PORTRAIT_IDS:
		var b := Button.new()
		b.theme_type_variation = &"ChipFilter"
		b.custom_minimum_size = cell
		b.toggle_mode = true
		b.button_group = group
		b.pressed.connect(func() -> void:
			_portrait_id = portrait_id
			_refresh()
			changed.emit())
		var face := TextureRect.new()
		face.texture = load(FounderConstants.portrait_path(portrait_id))
		face.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		face.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		face.mouse_filter = Control.MOUSE_FILTER_IGNORE
		face.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_MINSIZE, UiTokens.SPACE_XXS)
		b.add_child(face)
		var check := UiFactory.make_glyph("res://assets/icons/util/check.svg", UiTokens.D_ICON_STRIP, UiTokens.D_INK_1)
		check.name = "Check"
		check.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT, Control.PRESET_MODE_MINSIZE, UiTokens.SPACE_M)
		b.add_child(check)
		grid.add_child(b)
		_cells[portrait_id] = b


func _refresh() -> void:
	for portrait_id: String in _cells:
		var b: Button = _cells[portrait_id]
		b.set_pressed_no_signal(portrait_id == _portrait_id)
		b.get_node("Check").visible = b.button_pressed


# --- OnboardingStep contract ---

func prefill(draft: Dictionary) -> void:
	_name_input.text = draft.get("founder_name", "")
	# An empty draft opens on the first face, so the flat is never empty.
	_portrait_id = draft.get("portrait_id", "")
	if _portrait_id == "":
		_portrait_id = FounderConstants.PORTRAIT_IDS[0]
	_refresh()


func collect_payload() -> Dictionary:
	return {"founder_name": _name_input.text.strip_edges(), "portrait_id": _portrait_id}


## A face, and a name from the candidates' pool in the language on screen, its first name the face's sex where the
## pool knows it.
func roll() -> void:
	_portrait_id = FounderConstants.PORTRAIT_IDS[_rng.randi_range(0, FounderConstants.PORTRAIT_IDS.size() - 1)]
	var sex: String = LookSystem.founder(_portrait_id).sex
	var lang := "en" if Fmt.is_english() else "tr"
	var firsts: Array = HRConstants.first_names(lang).filter(func(n: String) -> bool:
		return HRConstants.FIRST_NAME_SEX.get(n, sex) == sex)
	var lasts: Array = HRConstants.last_names(lang)
	_name_input.text = "%s %s" % [firsts[_rng.randi_range(0, firsts.size() - 1)], lasts[_rng.randi_range(0, lasts.size() - 1)]]
	_refresh()
	changed.emit()
