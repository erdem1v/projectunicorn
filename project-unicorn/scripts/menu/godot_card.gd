extends Control

## "Made with Godot Engine." between the boot splash and the menu, on the splash's ground. It ends after
## GODOT_CARD_S or on the first key, click or pad button, whichever comes first.

signal finished

const GODOT_CARD_S := 1.5  # [WORKING]

# Read on the real clock: the boot's first frame carries the whole load in its delta, which would cut a timer short.
var _end_msec := 0


func _ready() -> void:
	_end_msec = Time.get_ticks_msec() + int(GODOT_CARD_S * 1000)


func _process(_delta: float) -> void:
	if Time.get_ticks_msec() >= _end_msec:
		_finish()


func _input(event: InputEvent) -> void:
	if event.is_pressed():
		get_viewport().set_input_as_handled()
		_finish()


func _finish() -> void:
	# The clock and a press can both arrive: the card ends once.
	if not is_processing_input():
		return
	set_process_input(false)
	set_process(false)
	finished.emit()
