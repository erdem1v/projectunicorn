extends PanelContainer

# An option on the meeting panel's deck: its number on a cream disc, the label with the marker and
# the sub-line under it, and at the right the die with its risk word when a roll decides it. An
# option that is not open shows a lock and its reason. It reports a click and the pointer; the
# panel owns the pick and plays it back through dim(), choose(), spin() and land().

signal clicked
signal hovered(on: bool)

const NUMBER_PX := 24
const LOCK_PX := 12
## The die, drawn: its square and edge, and the pips on a 3x3 grid this many pixels apart.
const DIE_PX := 20.0
const DIE_LINE := 1.5
const PIP_R := 1.5
const PIP_STEP := 4.5
## The face at rest, after a pass and after a fail.
const REST_FACE := 5
const PASS_FACE := 6
const FAIL_FACE := 1
## A spin turns the die once round and shows this many faces on the way.
const SPIN_FACES := 9
## The pips of faces 1-6, in grid steps from the die's centre.
const FACES := [
	[Vector2(0, 0)],
	[Vector2(-1, -1), Vector2(1, 1)],
	[Vector2(-1, -1), Vector2(0, 0), Vector2(1, 1)],
	[Vector2(-1, -1), Vector2(1, -1), Vector2(-1, 1), Vector2(1, 1)],
	[Vector2(-1, -1), Vector2(1, -1), Vector2(0, 0), Vector2(-1, 1), Vector2(1, 1)],
	[Vector2(-1, -1), Vector2(1, -1), Vector2(-1, 0), Vector2(1, 0), Vector2(-1, 1), Vector2(1, 1)],
]
const DIM_ALPHA := 0.4
## The edge an option takes under the pointer and once chosen; an alert option keeps its own.
const HOT := {&"ChoiceCard": &"ChoiceCardHover"}

var id: String
## The die's odds and factors for the panel's tooltip; {} when there is no risk word to explain.
var tip: Dictionary
var has_die: bool
var _variation: StringName
var _die: Control
var _risk: Label
var _face := REST_FACE
var _angle := 0.0
var _ink: Color
## A landed roll washes the card in the verdict's pale tint under an edge of its colour.
var _flash := Color.TRANSPARENT
var _wash: Color


## `number` is the option's key (1-5), 0 for one that is not open.
func _init(option: Dictionary, number: int) -> void:
	id = option.id
	var enabled: bool = option.get("enabled", true)
	var dice: Dictionary = option.get("dice", {})
	has_die = not dice.is_empty() or option.get("dice_only", false)
	tip = dice
	_variation = &"ChoiceCardAlert" if option.get("tone", "normal") == "alert" else &"ChoiceCard"
	theme_type_variation = _variation
	tooltip_text = option.get("hint", "")

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", UiTokens.SPACE_L)
	add_child(row)
	var disc := PanelContainer.new()
	disc.theme_type_variation = &"NumberChip"
	disc.custom_minimum_size = Vector2(NUMBER_PX, NUMBER_PX)
	disc.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var mark := CenterContainer.new()
	disc.add_child(mark)
	row.add_child(disc)

	var col := VBoxContainer.new()
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col.alignment = BoxContainer.ALIGNMENT_CENTER
	col.add_theme_constant_override("separation", UiTokens.SPACE_XXS)
	row.add_child(col)
	var label := UiFactory.make_label(option.label, &"ChoiceLabelStrong")
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	col.add_child(label)
	var marker: String = option.get("marker", "")
	if marker != "":
		var pill := UiFactory.make_badge(marker, &"accent")
		pill.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
		col.add_child(pill)
	var sub := UiFactory.make_label(option.get("sub", ""), &"RowMeta")
	sub.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	if option.get("sub_danger", false):
		sub.add_theme_color_override("font_color", UiTokens.negative())
	col.add_child(sub)
	if enabled:
		mark.add_child(UiFactory.make_label(str(number), &"RowMeta"))
	else:
		mark.add_child(HRUiShared.lock_glyph(LOCK_PX, UiTokens.INK_FAINT))
		label.theme_type_variation = &"ChoiceLabelLocked"
		sub.text = option.get("lock_reason", "")
	sub.visible = sub.text != ""

	if has_die:
		var side := HBoxContainer.new()
		side.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		side.add_theme_constant_override("separation", UiTokens.SPACE_S)
		row.add_child(side)
		_die = Control.new()
		_die.custom_minimum_size = Vector2(DIE_PX, DIE_PX)
		_die.draw.connect(_draw_die)
		side.add_child(_die)
		# The last question of a sales meeting rolls with odds the table does not show: a die, no word.
		_ink = UiTokens.INK_MUTED if tip.is_empty() else UiTokens.risk_ink(tip.chance)
		if not tip.is_empty():
			_risk = UiFactory.make_label(tr(tip.risk_key), &"RowMeta", _ink)
			side.add_child(_risk)

	HRUiShared.set_mouse_ignore(row)
	mouse_filter = Control.MOUSE_FILTER_STOP if enabled else Control.MOUSE_FILTER_IGNORE
	mouse_entered.connect(_hover.bind(true))
	mouse_exited.connect(_hover.bind(false))


func _gui_input(event: InputEvent) -> void:
	if UiFactory.is_left_click(event):
		clicked.emit()


## Another option was picked: this one fades back and takes no more pointer.
func dim() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	theme_type_variation = _variation
	modulate.a = DIM_ALPHA


## This option was picked: it keeps the amber edge and its die turns amber until the roll lands.
func choose() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	theme_type_variation = HOT.get(_variation, _variation)
	_paint(UiTokens.ACCENT_DEEP)


## The die mid-spin, `t` from 0 to 1.
func spin(t: float) -> void:
	_angle = t * TAU
	_face = 1 + int(t * SPIN_FACES) % 6
	_die.queue_redraw()


func land(passed: bool) -> void:
	_angle = 0.0
	_face = PASS_FACE if passed else FAIL_FACE
	_paint(UiTokens.positive() if passed else UiTokens.negative())
	_flash = _ink
	_wash = UiTokens.positive_bg() if passed else UiTokens.negative_bg()
	queue_redraw()


func _paint(ink: Color) -> void:
	_ink = ink
	if _risk != null:
		_risk.add_theme_color_override("font_color", ink)
	if has_die:
		_die.queue_redraw()


## A frozen option (picked, or passed over) ignores the pointer that is still on it.
func _hover(on: bool) -> void:
	if mouse_filter == Control.MOUSE_FILTER_IGNORE:
		return
	theme_type_variation = HOT.get(_variation, _variation) if on else _variation
	hovered.emit(on)


func _draw() -> void:
	if _flash.a > 0.0:
		var box := Rect2(Vector2.ZERO, size)
		draw_rect(box, _wash)
		draw_rect(box.grow(-UiTokens.BORDER_FOCUS * 0.5), _flash, false, UiTokens.BORDER_FOCUS)


func _draw_die() -> void:
	var edge := DIE_PX - DIE_LINE
	_die.draw_set_transform(_die.size * 0.5, _angle)
	_die.draw_rect(Rect2(Vector2.ONE * -edge * 0.5, Vector2.ONE * edge), _ink, false, DIE_LINE, true)
	for pip: Vector2 in FACES[_face - 1]:
		_die.draw_circle(pip * PIP_STEP, PIP_R, _ink, true, -1.0, true)
