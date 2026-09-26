extends Control

# Mounted into GameShell/ModalLayer by main.gd after the shell is in place.
# Tree is still paused while this is up; root has process_mode = ALWAYS so
# the Continue button stays responsive.
# MENTOR_INTRO_BODY (set in the .tscn) is written for Self-Made, the only
# playable origin in the demo (GDD ch14 §2).

signal dismissed

@onready var name_label: Label = $CenterPanel/Body/Header/HeaderText/NameLabel
@onready var role_label: Label = $CenterPanel/Body/Header/HeaderText/RoleLabel
@onready var continue_btn: Button = $CenterPanel/Body/ContinueBtn


func _ready() -> void:
	var mentor: Character = CharacterRegistry.get_mentor()
	if mentor != null:
		name_label.text = mentor.character_name
		# role is a typed id — never print it raw (renders "Operating Partner").
		role_label.text = HRConstants.role_label(mentor.role)
	continue_btn.pressed.connect(_on_continue_pressed)
	continue_btn.grab_focus()


func _on_continue_pressed() -> void:
	dismissed.emit()
	queue_free()
