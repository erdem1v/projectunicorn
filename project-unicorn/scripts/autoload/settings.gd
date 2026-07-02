extends Node

# Settings (TECH_SPEC §6.1) — persisted player preferences: display, audio,
# language, mentor-enabled. This turn only audio prefs (music on/off + volume)
# are written; the store is generic so future prefs share the same file.
#
# Persistence = JSON via FileAccess (TECH_SPEC §2, LOCKED convention). Settings
# live in user://settings.json, INDEPENDENT of game saves — they persist across
# runs regardless of which save slot (or none) is loaded.

const SETTINGS_PATH := "user://settings.json"
const SCHEMA_VERSION := 1

var _data: Dictionary = {}


func _ready() -> void:
	_load()


# Generic accessors. Value types round-trip through JSON (bool/float/int/String);
# callers pass a default so a missing/first-run key returns a sane value.
func get_value(key: String, default_value: Variant) -> Variant:
	return _data.get(key, default_value)


func set_value(key: String, value: Variant) -> void:
	_data[key] = value
	_save()


func _load() -> void:
	if not FileAccess.file_exists(SETTINGS_PATH):
		return
	var f := FileAccess.open(SETTINGS_PATH, FileAccess.READ)
	if f == null:
		push_warning("[Settings] could not open %s for read" % SETTINGS_PATH)
		return
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	if typeof(parsed) == TYPE_DICTIONARY:
		var values: Variant = (parsed as Dictionary).get("values", {})
		if typeof(values) == TYPE_DICTIONARY:
			_data = values


func _save() -> void:
	var f := FileAccess.open(SETTINGS_PATH, FileAccess.WRITE)
	if f == null:
		push_warning("[Settings] could not open %s for write" % SETTINGS_PATH)
		return
	f.store_string(JSON.stringify({
		"schema_version": SCHEMA_VERSION,
		"values": _data,
	}, "\t"))
