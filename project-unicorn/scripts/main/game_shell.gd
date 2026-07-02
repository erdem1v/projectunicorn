extends Control

# GameShell root. process_mode = ALWAYS (set in GameShell.tscn) so this handler
# runs even while the tree is paused — that's what lets Space UN-pause the game.
#
# B1: Space = pause/resume toggle. We use _input (not _unhandled_input) so a
# focused Button can't swallow Space via ui_accept before we see it. Guards keep
# Space typing a real space inside text fields, and defer to main.gd's pause
# state machine while a blocking modal is open.

func _input(event: InputEvent) -> void:
	if not (event is InputEventKey):
		return
	var key: InputEventKey = event
	if key.keycode != KEY_SPACE or not key.pressed or key.echo:
		return
	# Guard 1: a text field is focused → let Space type a space (e.g. product name).
	var focus: Control = get_viewport().gui_get_focus_owner()
	if focus is LineEdit or focus is TextEdit:
		return
	# Guard 2: a blocking modal (event/pitch/settings) owns pause via main.gd —
	# don't desync that _pre_*_speed state machine.
	var modal_layer: Node = get_node_or_null("ModalLayer")
	if modal_layer != null and modal_layer.get_child_count() > 0:
		return
	get_viewport().set_input_as_handled()
	# Toggle: pause if running, else resume the last running speed. Routes through
	# the same signal the TopBar buttons use, so the TopBar stays in sync.
	var target: int = 0 if TimeManager.current_speed > 0 else TimeManager.last_running_speed
	EventBus.speed_change_requested.emit(target)
