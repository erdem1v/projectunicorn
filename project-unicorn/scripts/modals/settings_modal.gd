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
@onready var _lang_header: Label = %LanguageHeader
@onready var _lang_option: OptionButton = %LanguageOption


func _ready() -> void:
	# Seed controls from the live audio state.
	_toggle.button_pressed = AudioManager.is_music_enabled()
	_slider.value = AudioManager.get_music_volume() * 100.0
	_slider.editable = AudioManager.is_music_enabled()
	_update_pct()

	_toggle.toggled.connect(_on_toggled)
	_slider.value_changed.connect(_on_slider_changed)
	_close_btn.pressed.connect(_close)

	# Language selector (Package 5) — TR/EN via the Localization autoload (persists + set_locale).
	_lang_header.text = tr("SETTINGS_LANGUAGE")
	_lang_option.clear()
	_lang_option.add_item(tr("LANG_TR"), 0)   # id 0 = tr
	_lang_option.add_item(tr("LANG_EN"), 1)   # id 1 = en
	_lang_option.select(0 if Localization.get_language() == "tr" else 1)
	_lang_option.item_selected.connect(_on_language_selected)

	_close_btn.grab_focus()


func _on_toggled(on: bool) -> void:
	AudioManager.set_music_enabled(on)
	_slider.editable = on   # dim the level control when music is off


func _on_slider_changed(v: float) -> void:
	AudioManager.set_music_volume(v / 100.0)   # 0..100 → linear 0..1, LIVE
	_update_pct()


func _update_pct() -> void:
	_pct.text = "%d%%" % int(round(_slider.value))


func _on_language_selected(idx: int) -> void:
	Localization.set_language("tr" if idx == 0 else "en")
	# Re-translate this modal's own labels so it reflects the switch immediately.
	_lang_header.text = tr("SETTINGS_LANGUAGE")
	_lang_option.set_item_text(0, tr("LANG_TR"))
	_lang_option.set_item_text(1, tr("LANG_EN"))


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):   # ESC — first cancel convention in the project
		get_viewport().set_input_as_handled()
		_close()


func _close() -> void:
	dismissed.emit()
	queue_free()
