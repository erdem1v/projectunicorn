extends Node

# Localization — Godot-native TranslationServer, sourced from a CSV.
#
# The persisted "language" value lives in Settings; this node applies it at boot and
# on every change, and emits EventBus.language_changed so live surfaces re-translate.
# Registered AFTER Settings + EventBus.
#
# The editor CSV-translation importer is unreliable in headless/CLI, so strings.csv is
# parsed here into one Translation per locale column — deterministic, same end result.

const STRINGS_CSV := "res://localization/strings.csv"
const DEFAULT_LANG := "tr"
const KEY_LANGUAGE := "language"
const SUPPORTED := ["tr", "en"]


func _ready() -> void:
	_load_csv_translations()
	# `--lang=` beats the stored preference so verification can FORCE a locale; it never
	# touches Settings, so a forced run cannot rewrite the player's preference.
	var forced: String = _cmdline_language()
	TranslationServer.set_locale(forced if forced != "" else get_language())


func get_language() -> String:
	var lang: String = String(Settings.get_value(KEY_LANGUAGE, DEFAULT_LANG))
	return lang if lang in SUPPORTED else DEFAULT_LANG


## `--lang=tr|en` from either source, "" when absent/unsupported. Godot forwards
## `application/run/main_args` only on an editor F5 run and real argv only on a CLI
## run, so a flag that must work in both reads both.
func _cmdline_language() -> String:
	var sources: Array[String] = []
	for a in OS.get_cmdline_args():
		sources.append(String(a))
	sources.append(String(ProjectSettings.get_setting("application/run/main_args", "")))
	for s in sources:
		for token in s.split(" ", false):
			var t: String = token.strip_edges()
			if not t.begins_with("--lang="):
				continue
			var loc: String = t.trim_prefix("--lang=")
			if loc in SUPPORTED:
				return loc
			push_warning("[Localization] unsupported --lang: %s" % loc)
	return ""


## Has the player never chosen a language? Drives the first-boot gate. On a machine
## that has ever picked a language this is false forever — use --force-language-gate.
func is_first_boot() -> bool:
	return not Settings.has_stored(KEY_LANGUAGE)


## Choose between a Turkish source string and its English sibling at render time.
## Authored event JSON carries its prose inline and the event cache is built once at
## boot, so resolving at load time would freeze the boot locale into the cache.
## An empty `en_text` is a contract: the text in `tr_text` is already localized and is
## returned in both locales.
static func pick(tr_text: String, en_text: String) -> String:
	if en_text != "" and TranslationServer.get_locale().begins_with("en"):
		return en_text
	return tr_text


func set_language(locale: String) -> void:
	if locale not in SUPPORTED:
		push_warning("[Localization] unsupported locale: %s" % locale)
		return
	TranslationServer.set_locale(locale)
	Settings.set_value(KEY_LANGUAGE, locale)
	EventBus.language_changed.emit(locale)


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
		var key: String = row[0].strip_edges() if row.size() >= 2 else ""
		if key == "":
			continue
		for col in range(1, mini(header.size(), row.size())):
			translations[col - 1].add_message(key, row[col])
	for t in translations:
		TranslationServer.add_translation(t)
