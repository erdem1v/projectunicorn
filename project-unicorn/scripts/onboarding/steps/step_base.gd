class_name OnboardingStep
extends Control

# Contract every onboarding step honors. The flow talks to steps only through this surface: payload shape,
# validation and the change signal. Step scenes build their own UI below the contract.
#
# Lifecycle (flow-driven):
#   1. instantiate the step scene and add it to the paper
#   2. prefill(draft): the step paints its slice of the draft (an absent field reads its default), so prefill
#      always follows add_child
#   3. every change emits `changed`; the flow merges collect_payload() into the draft and shows invalid_reason()
#      beside Next
#   4. a step with Randomize and Reset fills its fields from roll(); Reset is prefill({})

signal changed

## The layout of a screen 1080 tall, then of a shorter one (1536×864 logical).
var short: bool:
	get:
		return get_viewport_rect().size.y < 1080.0


func prefill(_draft: Dictionary) -> void:
	pass


## What still holds Next back, in the player's language; "" once the step is complete.
func invalid_reason() -> String:
	return ""


func is_valid() -> bool:
	return invalid_reason() == ""


func collect_payload() -> Dictionary:
	return {}


func roll() -> void:
	pass


## The step's head: its title and line, Randomize and Reset at the right when the step has them.
func _head(title_key: String, line_key: String, tools := false) -> HBoxContainer:
	var row := HBoxContainer.new()
	var col := VBoxContainer.new()
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var top := HBoxContainer.new()
	var title := UiFactory.make_label(Fmt.upper(tr(title_key)), &"KeyLabel")
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(title)
	col.add_child(top)
	var line := UiFactory.make_label(tr(line_key), &"Caption")
	line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	col.add_child(line)
	row.add_child(col)
	if tools:
		# The narrow paper gives the line the head's whole width: the tools ride on the title's line.
		(top if short else row).add_child(_tools())
	return row


func _tools() -> HBoxContainer:
	var tools := HBoxContainer.new()
	tools.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	var random := Button.new()
	random.theme_type_variation = &"SecondaryButtonSmall"
	random.text = tr("ONB_RANDOM")
	random.icon = load("res://assets/icons/util/dice.svg")
	random.pressed.connect(roll)
	tools.add_child(random)
	var reset := Button.new()
	reset.theme_type_variation = &"GhostButtonSmall"
	reset.text = tr("ONB_RESET")
	reset.icon = load("res://assets/icons/util/revert.svg")
	reset.pressed.connect(func() -> void:
		prefill({})
		changed.emit())
	tools.add_child(reset)
	return tools


## `content` in the PickCard frame, inside its padding. A card the player picks carries the tick show_pick lights.
func _card(content: Control, pickable := false) -> PanelContainer:
	var card := PanelContainer.new()
	card.theme_type_variation = &"PickCard"
	var pad := MarginContainer.new()
	pad.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for side in ["left", "right"]:
		pad.add_theme_constant_override("margin_" + side, UiTokens.SPACE_L if short else UiTokens.SPACE_XL)
	for side in ["top", "bottom"]:
		pad.add_theme_constant_override("margin_" + side, UiTokens.SPACE_S if short else UiTokens.SPACE_XL)
	card.add_child(pad)
	pad.add_child(content)
	if pickable:
		var tick := UiFactory.make_glyph("res://assets/icons/util/check.svg", UiTokens.D_ICON_ROW, UiTokens.D_INK_1)
		tick.name = "Tick"
		tick.size_flags_horizontal = Control.SIZE_SHRINK_END
		tick.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
		pad.add_child(tick)
	return card


## Marks a card _card made pickable as the chosen one or not.
static func show_pick(card: PanelContainer, on: bool) -> void:
	card.theme_type_variation = &"PickCardSelected" if on else &"PickCard"
	card.get_child(0).get_node("Tick").visible = on


## A dashed outline round `box`: a place something will fill (a new portrait, the company's emblem). A
## StyleBoxFlat draws no dashes.
static func dash(box: Control) -> void:
	box.draw.connect(func() -> void:
		var r := Rect2(Vector2.ONE * 0.5, box.size - Vector2.ONE)
		for side in [[r.position, Vector2(r.end.x, r.position.y)], [Vector2(r.end.x, r.position.y), r.end],
				[r.end, Vector2(r.position.x, r.end.y)], [Vector2(r.position.x, r.end.y), r.position]]:
			box.draw_dashed_line(side[0], side[1], UiTokens.D_LINE_2, 1.0, 4.0))
