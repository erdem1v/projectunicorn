extends Node

# Localization (Package 5). Godot-native TranslationServer, sourced from a CSV.
#
# Preference OWNERSHIP mirrors AudioManager: the persisted "language" value lives in
# the Settings autoload (§6.1); this node applies it at boot and on every change, and
# emits EventBus.language_changed so live surfaces (TopBar runway label) re-translate.
# Registered AFTER Settings + EventBus in the autoload list so both are ready here.
#
# Mechanism: the editor CSV-translation importer is unreliable in headless/CLI, so we
# parse localization/strings.csv at _ready into one Translation per locale column and
# register them via TranslationServer.add_translation — deterministic, same end result.
# Canonical content is Turkish (CLAUDE.md law); EN is the literary translation column.

const STRINGS_CSV := "res://localization/strings.csv"
const DEFAULT_LANG := "tr"
const KEY_LANGUAGE := "language"
const SUPPORTED := ["tr", "en"]


func _ready() -> void:
	_load_csv_translations()
	TranslationServer.set_locale(get_language())


# --- Public API (SettingsModal drives set_language live) ---

func get_language() -> String:
	var lang: String = String(Settings.get_value(KEY_LANGUAGE, DEFAULT_LANG))
	return lang if lang in SUPPORTED else DEFAULT_LANG


func set_language(locale: String) -> void:
	if locale not in SUPPORTED:
		push_warning("[Localization] unsupported locale: %s" % locale)
		return
	TranslationServer.set_locale(locale)
	Settings.set_value(KEY_LANGUAGE, locale)
	EventBus.language_changed.emit(locale)


# --- CSV → TranslationServer ---

func _load_csv_translations() -> void:
	var f := FileAccess.open(STRINGS_CSV, FileAccess.READ)
	if f == null:
		push_warning("[Localization] strings CSV missing: %s" % STRINGS_CSV)
		return
	var header: PackedStringArray = f.get_csv_line()   # ["keys", "tr", "en", ...]
	if header.size() < 2:
		push_warning("[Localization] malformed strings CSV header")
		return
	# One Translation per locale column (column 0 is the key column).
	var translations: Array[Translation] = []
	for col in range(1, header.size()):
		var t := Translation.new()
		t.locale = header[col].strip_edges()
		translations.append(t)
	while not f.eof_reached():
		var row: PackedStringArray = f.get_csv_line()
		if row.size() < 2 or row[0].strip_edges() == "":
			continue
		var key: String = row[0].strip_edges()
		for col in range(1, header.size()):
			if col < row.size():
				translations[col - 1].add_message(key, row[col])
	for t in translations:
		TranslationServer.add_translation(t)
	if OS.is_debug_build():
		print("[Localization] loaded %d locales from %s" % [translations.size(), STRINGS_CSV])
