extends PanelContainer

# The strip a waiting decision lays over a window it leaves read only and over the load dialog it stops: why,
# the decision's sender and subject, and the way back to it. Dark on any host. Preloaded by path: no global
# class cache dependency (headless trap).

const INBOX := preload("res://scripts/ui/components/inbox.gd")

var _from: Label


## `say` is the strip's reason and `on_back` takes the player to the decision; `right` keeps the strip clear
## of a cream window's close glyph.
func _init(say: String, on_back: Callable, right := 0) -> void:
	theme = load(UiTokens.MENAJER_THEME)
	theme_type_variation = &"WinReadOnly"
	custom_minimum_size.y = UiTokens.D_H_BTN_SM + UiTokens.SPACE_M
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_right", right)
	add_child(margin)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", UiTokens.SPACE_L)
	margin.add_child(row)
	var dot := Panel.new()
	dot.theme_type_variation = &"GateDot"
	dot.custom_minimum_size = Vector2.ONE * UiTokens.SPACE_M
	dot.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(dot)
	var reason := UiFactory.make_label(say, &"DataStrong")
	reason.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(reason)
	_from = UiFactory.make_label("", &"MetaMuted")
	_from.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_from.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_from.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	row.add_child(_from)
	var back := Button.new()
	back.text = tr("WIN_BACK_TO_DECISION")
	back.icon = load("res://assets/icons/util/reply.svg")
	back.theme_type_variation = &"SecondaryButtonSmall"
	back.focus_mode = Control.FOCUS_NONE
	back.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	back.pressed.connect(on_back)
	row.add_child(back)
	sync()


## Shown while a decision waits, naming it.
func sync() -> void:
	visible = EventGate.active_id() != ""
	if visible:
		var it: Dictionary = INBOX.active_item()
		_from.text = "%s · %s" % [it.sender.name, it.subject]
