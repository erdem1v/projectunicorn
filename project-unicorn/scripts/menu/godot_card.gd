extends Control

## "Made with Godot Engine." between the boot splash and the menu, on the splash's ground. It ends after
## GODOT_CARD_S or on the first key, click or pad button, whichever comes first.

signal finished

const GODOT_CARD_S := 1.5  # [WORKING]


func _ready() -> void:
	get_tree().create_timer(GODOT_CARD_S).timeout.connect(_finish)


func _input(event: InputEvent) -> void:
	if event.is_pressed():
		get_viewport().set_input_as_handled()
		_finish()


func _finish() -> void:
	# The timer and a press can both arrive: the card ends once.
	if not is_processing_input():
		return
	set_process_input(false)
	finished.emit()
