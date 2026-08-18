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
	TranslationServer.set_locale(get_effective_language())


# --- Public API (SettingsModal drives set_language live) ---

func get_language() -> String:
	var lang: String = String(Settings.get_value(KEY_LANGUAGE, DEFAULT_LANG))
	return lang if lang in SUPPORTED else DEFAULT_LANG


## The locale this boot actually uses: `--lang=` beats the stored preference.
## WHY the override exists: verification has to be able to FORCE a language. The stored
## `language` value is whatever the developer last clicked (on this machine it is "en"),
## so a TR/EN screenshot matrix that trusted the default would silently shoot the same
## locale twice. Non-persisting by construction — it never touches Settings, so a forced
## run cannot rewrite the player's preference.
func get_effective_language() -> String:
	var forced: String = cmdline_language()
	return forced if forced != "" else get_language()


## `--lang=tr|en` from either source, "" when absent/unsupported. Dual source mirrors
## main.gd's harness flags: Godot forwards `application/run/main_args` only on an editor
## F5 run, and only real argv on a CLI run, so a flag that must work in both reads both.
func cmdline_language() -> String:
	var sources: Array[String] = []
	for a in OS.get_cmdline_args():
		sources.append(String(a))
	sources.append(String(ProjectSettings.get_setting("application/run/main_args", "")))
	for s in sources:
		for token in s.split(" ", false):
			var t: String = String(token).strip_edges()
			if not t.begins_with("--lang="):
				continue
			var loc: String = t.trim_prefix("--lang=")
			if loc in SUPPORTED:
				return loc
			push_warning("[Localization] unsupported --lang: %s" % loc)
	return ""


## Has the player never chosen a language? True only when nothing has ever been written
## to the `language` key — Settings.has_stored draws exactly this line, because get_value
## cannot tell "stored tr" apart from "defaulted to tr". Drives the first-boot gate.
## NOTE for verification: on a machine that has ever opened Settings > Language this is
## false forever, so the gate cannot be reached by playing — use --force-language-gate.
func is_first_boot() -> bool:
	return not Settings.has_stored(KEY_LANGUAGE)


## Choose between a Turkish source string and its English sibling.
##
## WHY THIS EXISTS INSTEAD OF A KEY: authored event JSON carries its prose inline, and the
## event cache is built once at boot and compared BY REFERENCE, so the text cannot be
## resolved at load time without freezing the boot locale into the cache. pick() defers the
## choice to render time, which is what makes a mid-run language switch show the next event
## in the new language.
##
## EMPTY en IS A CONTRACT, NOT A GAP: code factories (B2BEventFactory, HREventFactory)
## already write finished, localized text into the Turkish field and leave the sibling
## empty. Falling back returns that text unchanged in both locales — "already localized"
## behaviour with no discriminator field to keep in sync.
static func pick(tr_text: String, en_text: String) -> String:
	if en_text != "" and TranslationServer.get_locale().begins_with("en"):
		return en_text
	return tr_text   # TR canonical fallback


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
