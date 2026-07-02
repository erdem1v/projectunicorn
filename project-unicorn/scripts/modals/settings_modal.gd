extends Control

# Settings panel — a growable container that today holds only the audio section.
# Follows the MentorIntroModal convention: mounted into GameShell/ModalLayer by
# main.gd, frees ITSELF via the `dismissed` signal (main.gd restores game speed).
# Root has process_mode = ALWAYS so it stays interactive while the tree is paused,
# which also lets its _unhandled_input receive ESC while paused.
#
# Controls are LIVE — moving the slider / flipping the toggle applies immediately
# through AudioManager (no Apply button). AudioManager persists each change.

signal dismissed

@onready var _toggle: CheckButton = %MusicToggle
@onready var _slider: HSlider = %VolumeSlider
@onready var _pct: Label = %PctLabel
@onready var _close_btn: Button = %CloseBtn


func _ready() -> void:
	# Seed controls from the live audio state.
	_toggle.button_pressed = AudioManager.is_music_enabled()
	_slider.value = AudioManager.get_music_volume() * 100.0
	_slider.editable = AudioManager.is_music_enabled()
	_update_pct()

	_toggle.toggled.connect(_on_toggled)
	_slider.value_changed.connect(_on_slider_changed)
	_close_btn.pressed.connect(_close)
	_close_btn.grab_focus()


func _on_toggled(on: bool) -> void:
	AudioManager.set_music_enabled(on)
	_slider.editable = on   # dim the level control when music is off


func _on_slider_changed(v: float) -> void:
	AudioManager.set_music_volume(v / 100.0)   # 0..100 → linear 0..1, LIVE
	_update_pct()


func _update_pct() -> void:
	_pct.text = "%d%%" % int(round(_slider.value))


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):   # ESC — first cancel convention in the project
		get_viewport().set_input_as_handled()
		_close()


func _close() -> void:
	dismissed.emit()
	queue_free()
