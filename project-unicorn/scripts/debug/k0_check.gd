class_name K0Check
extends RefCounted

# K0 link check (--k0-check): the connections of shipped content, proved in one headless launch.
# Verbs reach an executor, card placeholders fill, and no `PH:` marker reaches the player.

const EFFECTS_SRC := "res://scripts/events/core/effects.gd"
const STRINGS_CSV := "res://localization/strings.csv"

static var _found: Array[String] = []


static func run() -> bool:
	_found.clear()
	var live: Dictionary = _executors()
	var cards: Array = EvCatalog.card_ids().map(func(id): return EvCatalog.card(id)).filter(_ships)
	var arcs: Array = EvCatalog.arc_ids().map(func(id): return EvCatalog.arc(id)).filter(_ships)
	var used := {}
	for def: Dictionary in cards + arcs:
		var leaves: Array = []
		_leaves(def, "", leaves)
		for leaf in leaves:
			var path: String = leaf[0]
			var value: String = leaf[1]
			if path.begins_with("/text/"):
				if value.contains("PH:"):
					_add("PH", "%s[%s]" % [def.id, path.get_slice("/", 2)], value)
			elif path.ends_with("/verb"):
				used[value] = true
				if not live.has(value):
					_add("fiil", def.id + path.trim_suffix("/verb"), "'%s' için uygulayıcı yok" % value)

	var locale: String = TranslationServer.get_locale()
	for lang: String in Localization.SUPPORTED:
		TranslationServer.set_locale(lang)
		var unresolved: String = EndgameSmoke._case_card_body_tokens_resolve()
		if unresolved != "":
			_add("yer-tutucu", lang, unresolved)
	TranslationServer.set_locale(locale)

	var keys: int = _scan_csv()
	if not _found.is_empty():
		print("K0 FAIL · %d bulgu" % _found.size())
		for line in _found:
			print(line)
		return false
	print("K0 PASS · %d kart · %d anahtar · %d fiil" % [cards.size(), keys, used.size()])
	var stubs: Array = (EvEffects.NEUTRAL_VERBS + EvEffects.ECONOMIC_VERBS + EvEffects.TERMINAL_VERBS) \
		.filter(func(verb): return not live.has(verb))
	stubs.sort()
	if not stubs.is_empty():
		print("K0 INFO kolsuz fiil (sözlükte, kartta değil): %s" % ", ".join(stubs))
	return true


## The verbs `EvEffects._apply` really acts on, read off its `match` arms. An arm whose every `return` refuses or
## defers (a contract nothing carries out yet) only says no, like a missing arm, so it does not count.
static func _executors() -> Dictionary:
	var src: String = FileAccess.get_file_as_string(EFFECTS_SRC)
	var arms: String = src.get_slice("static func _apply(", 1).get_slice("\nstatic func ", 0)
	var label := RegEx.create_from_string("^\t\t((?:\"[a-z_0-9]+\"(?:, )?)+):\\s*$")
	var name_re := RegEx.create_from_string("\"([a-z_0-9]+)\"")
	var live := {}
	var names: Array = []
	for line in arms.split("\n"):
		var head: RegExMatch = label.search(line)
		if head != null:
			names = name_re.search_all(head.get_string(1)).map(func(m: RegExMatch): return m.get_string(1))
		elif line.strip_edges().begins_with("return ") and not (line.contains("\"refused\"") or line.contains("_no_target(")
				or line.contains("\"deferred\"")):
			for verb: String in names:
				live[verb] = true
	return live


## Rows of strings.csv, each language column checked for the placeholder marker; returns the key count.
static func _scan_csv() -> int:
	var f := FileAccess.open(STRINGS_CSV, FileAccess.READ)
	var header: PackedStringArray = f.get_csv_line()
	var keys := 0
	while not f.eof_reached():
		var row: PackedStringArray = f.get_csv_line()
		if row[0].strip_edges() == "":
			continue
		keys += 1
		for col in range(1, row.size()):
			if row[col].contains("PH:"):
				_add("PH", "%s[%s]" % [row[0], header[col]], row[col])
	return keys


static func _ships(def: Dictionary) -> bool:
	return EvTuning.SHIPPED_SCOPES.has(String(def.get("version_scope", "demo")))


## Every string under `node` as [path, value]; a path is its keys and indexes joined by "/".
static func _leaves(node: Variant, path: String, out: Array) -> void:
	match typeof(node):
		TYPE_DICTIONARY:
			for key in node:
				_leaves(node[key], "%s/%s" % [path, key], out)
		TYPE_ARRAY:
			for i in node.size():
				_leaves(node[i], "%s/%d" % [path, i], out)
		TYPE_STRING:
			out.append([path, node])


static func _add(check: String, where: String, what: String) -> void:
	_found.append("K0 %s %s: %s" % [check, where, what])
