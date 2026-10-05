extends PanelContainer

# An option on the meeting panel's deck: its number in a key, the label (the founder's sentence, or a
# command at the price table) with the marker and the line under it, and at the right the die with its
# risk word when a roll decides it. An option that is not open shows a lock and its reason; one past
# the insult line takes the danger tone with its reason always under it. It reports a click and the
# pointer; the panel owns the pick and plays it back through dim(), choose(), spin() and land().

signal clicked
signal hovered(on: bool)

const DIE := "res://assets/icons/util/dice.svg"
## The die turns this many times round while it spins.
const SPIN_TURNS := 2.0

var id: String
## The die's odds and factors for the panel's tooltip; {} when there is no risk word to explain.
var tip: Dictionary
var has_die: bool
var _look: StringName
var _key: Label
var _label: Label
var _die: TextureRect
var _risk: Label


## `number` is the option's key (1-5), 0 for one that is not open.
func _init(option: Dictionary, number: int) -> void:
	id = option.id
	var enabled: bool = option.get("enabled", true)
	var dice: Dictionary = option.get("dice", {})
	has_die = not dice.is_empty() or option.get("dice_only", false)
	tip = dice
	var alert: bool = option.get("tone", "normal") == "alert"
	_look = UiTokens.D_variation(&"MeetOptionAlert") if alert else (&"MeetOption" if enabled else &"MeetOptionLocked")
	theme_type_variation = _look
	custom_minimum_size.y = UiTokens.D_H_OPTION

	var row := SprintUiShared.box(UiTokens.SPACE_L)
	add_child(row)
	_key = UiFactory.D_key_cap(number)
	row.add_child(_key)

	var col := SprintUiShared.column(UiTokens.SPACE_XS)
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_child(col)
	_label = SprintUiShared.prose(option.label, &"OptionLabel" if option.get("command", false) else &"SubjectStrong")
	if not enabled:
		_label.add_theme_color_override("font_color", UiTokens.D_INK_OFF)
	elif alert:
		_label.add_theme_color_override("font_color", UiTokens.D_neg_ink())
	col.add_child(_label)
	var marker: String = option.get("marker", "")
	if marker != "":
		col.add_child(UiFactory.D_tag(marker, &"outline"))
	# Under the label: a locked option's reason, an alert's, or the option's own line.
	var sub: String = option.get("lock_reason", "") if not enabled else option.get("hint" if alert else "sub", "")
	if sub != "":
		var line := SprintUiShared.prose(sub, &"Caption")
		if alert or option.get("sub_danger", false):
			line.add_theme_color_override("font_color", UiTokens.D_neg_ink())
		col.add_child(line)

	if has_die:
		var side := SprintUiShared.box(UiTokens.SPACE_S)
		side.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		row.add_child(side)
		# The last question of a sales meeting rolls with odds the table does not show: a die, no word.
		var ink: Color = UiTokens.D_INK_3 if tip.is_empty() else UiTokens.D_risk_ink(tip.chance)
		_die = UiFactory.make_glyph(DIE, UiTokens.D_ICON_DIE, ink)
		_die.pivot_offset = Vector2.ONE * UiTokens.D_ICON_DIE * 0.5
		side.add_child(_die)
		if not tip.is_empty():
			_risk = UiFactory.make_label(tr(tip.risk_key), &"Caption", ink)
			_risk.size_flags_vertical = Control.SIZE_SHRINK_CENTER
			side.add_child(_risk)

	HRUiShared.set_mouse_ignore(row)
	mouse_filter = Control.MOUSE_FILTER_STOP if enabled else Control.MOUSE_FILTER_IGNORE
	mouse_entered.connect(_hover.bind(true))
	mouse_exited.connect(_hover.bind(false))


func _gui_input(event: InputEvent) -> void:
	if UiFactory.is_left_click(event):
		clicked.emit()


## Another option was picked: this one goes off and takes no more pointer.
func dim() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	theme_type_variation = _look
	for part: Label in [_key, _label]:
		part.add_theme_color_override("font_color", UiTokens.D_INK_OFF)


## This option was picked: it keeps the hover edge while its die rolls.
func choose() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	if _look == &"MeetOption":
		theme_type_variation = &"MeetOptionHover"


## The die mid-spin, `t` from 0 to 1.
func spin(t: float) -> void:
	_die.rotation = t * TAU * SPIN_TURNS


## The roll landed: a pass reads in the gain colour, a fail stays neutral (it is not a danger).
func land(passed: bool) -> void:
	_die.rotation = 0.0
	var ink: Color = UiTokens.D_pos() if passed else UiTokens.D_INK_3
	_die.modulate = ink
	if _risk != null:
		_risk.add_theme_color_override("font_color", ink)


## A frozen option (picked, or passed over) ignores the pointer that is still on it.
func _hover(on: bool) -> void:
	if mouse_filter == Control.MOUSE_FILTER_IGNORE:
		return
	if _look == &"MeetOption":
		theme_type_variation = &"MeetOptionHover" if on else _look
	hovered.emit(on)
