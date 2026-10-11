extends Control

## Credits: the lock-up and the version, the role | name table from data/credits.json, the engine line and the
## © line. A role without names is not drawn, and neither is the © line while its holder is empty.

signal dismissed

const LICENSES := preload("res://scenes/menu/Licenses.tscn")
const DATA_PATH := "res://data/credits.json"
const ROLE_W := 300

@onready var _licenses_btn: Button = %LicensesBtn


func _ready() -> void:
	($Dimmer as ColorRect).color = UiTokens.D_SCRIM
	%GodotMark.modulate = UiTokens.D_INK_3
	%TitleLabel.text = Fmt.upper(tr("CREDITS_TITLE"))
	%VersionLabel.text = version_line()
	var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(DATA_PATH))
	for entry: Dictionary in data.roles:
		if entry.names.is_empty():
			continue
		var role := UiFactory.make_label(tr(entry.role), &"BodyMuted")
		role.custom_minimum_size.x = ROLE_W
		%Roles.add_child(role)
		%Roles.add_child(UiFactory.make_label("\n".join(entry.names), &"SubjectStrong"))
	%CopyrightLabel.visible = data.holder != ""
	%CopyrightLabel.text = tr("CREDITS_COPYRIGHT").format({"year": int(data.year), "holder": data.holder})
	_licenses_btn.pressed.connect(_open_licenses)
	%CloseBtn.pressed.connect(_close)
	%CloseBtn.grab_focus()


## "Demo · Version 0.1.0", under the lock-up here and in the main menu's corner.
static func version_line() -> String:
	return TranslationServer.translate("MENU_VERSION").format({
		"build": TranslationServer.translate("MENU_BUILD_" + EndingsSystem.build_scope().to_upper()),
		"version": ProjectSettings.get_setting("application/config/version")})


func _open_licenses() -> void:
	var licenses := LICENSES.instantiate()
	licenses.back.connect(func() -> void:
		visible = true
		_licenses_btn.grab_focus())
	licenses.dismissed.connect(_close)
	visible = false
	add_sibling(licenses)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_close()


func _close() -> void:
	dismissed.emit()
	queue_free()
