extends Control

# First modal in the project — establishes the pattern.
# Mounted into GameShell/ModalLayer by main.gd after the shell is in place.
# Tree is still paused while this is up; root has process_mode = ALWAYS so
# the Continue button stays responsive.

signal dismissed

@onready var name_label: Label = $CenterPanel/Body/Header/HeaderText/NameLabel
@onready var role_label: Label = $CenterPanel/Body/Header/HeaderText/RoleLabel
@onready var continue_btn: Button = $CenterPanel/Body/ContinueBtn


func _ready() -> void:
	var mentor: Character = CharacterRegistry.get_mentor()
	if mentor != null:
		name_label.text = mentor.character_name
		role_label.text = mentor.role
	# Body text is keyed to Self-Made (only playable origin this turn).
	# Future variants will live in a dict keyed by GameState.origin.
	continue_btn.pressed.connect(_on_continue_pressed)
	continue_btn.grab_focus()


func _on_continue_pressed() -> void:
	dismissed.emit()
	queue_free()
