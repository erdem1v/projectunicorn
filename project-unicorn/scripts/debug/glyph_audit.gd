extends SceneTree
## Every character the game can draw, checked against each face of the dark language and each of its
## chains. The characters come from strings.csv (both languages), the string literals of scripts and
## scenes outside scripts/debug and scenes/debug, and the strings in data/*.json. A face that lacks
## one falls through its chain, then to a system font.
##   "$GODOT" --headless --path . -s res://scripts/debug/glyph_audit.gd
## Prints GLYPH|MISS|<face or chain>|U+XXXX|<char>|<uses>|<first use> per missing character.

const FACES := [
	"res://assets/fonts/cond/BarlowCondensed-SemiBold.ttf",
	"res://assets/fonts/cond/BarlowCondensed-Bold.ttf",
	"res://assets/fonts/sans/IBMPlexSans-Regular.ttf",
	"res://assets/fonts/sans/IBMPlexSans-Medium.ttf",
	"res://assets/fonts/sans/IBMPlexSans-SemiBold.ttf",
	"res://assets/fonts/sans/IBMPlexSans-Bold.ttf",
	"res://assets/fonts/sans/IBMPlexSansCondensed-Regular.ttf",
	"res://assets/fonts/serif/SourceSerif4-Regular.ttf",
	"res://assets/fonts/serif/SourceSerif4-Semibold.ttf",
	"res://assets/fonts/serif/SourceSerif4-It.ttf",
]
const CHAINS := "res://assets/fonts/variations/"

## char -> [uses, first use]
var _seen := {}


func _initialize() -> void:
	var csv := FileAccess.open("res://localization/strings.csv", FileAccess.READ)
	csv.get_csv_line()
	while not csv.eof_reached():
		var row := csv.get_csv_line()
		for col in range(1, row.size()):
			_add(row[col], "csv:" + row[0])
	for root in ["res://scripts", "res://scenes"]:
		_walk(root, func(path: String) -> void:
			if path.get_extension() in ["gd", "tscn"] and not path.begins_with(root + "/debug/"):
				var text := FileAccess.get_file_as_string(path)
				for lit in _literals(text):
					_add(lit[1].c_unescape(), "%s:%d" % [path.trim_prefix("res://"), lit[0]]))
	_walk("res://data", func(path: String) -> void:
		if path.get_extension() == "json":
			_strings(JSON.parse_string(FileAccess.get_file_as_string(path)), path.trim_prefix("res://")))

	var ts := TextServerManager.get_primary_interface()
	var chars := _seen.keys()
	chars.sort()
	print("GLYPH|CHARS|%d" % chars.size())
	for path in FACES:
		var face: FontFile = load(path)
		_report(path.get_file().get_basename(), chars, func(ch: int) -> bool: return ts.font_has_char(face.get_rids()[0], ch))
	for file in DirAccess.get_files_at(CHAINS):
		if file.begins_with("d_") and file.ends_with(".tres"):
			var chain: Font = load(CHAINS + file)
			_report("chain " + file.get_basename(), chars, func(ch: int) -> bool: return chain.has_char(ch))
	quit(0)


func _report(name: String, chars: Array, has: Callable) -> void:
	var misses := 0
	for ch in chars:
		if not has.call(ch):
			misses += 1
			print("GLYPH|MISS|%s|U+%04X|%s|%d|%s" % [name, ch, char(ch), _seen[ch][0], _seen[ch][1]])
	print("GLYPH|FACE|%s|missing=%d" % [name, misses])


func _add(text: String, where: String) -> void:
	for i in text.length():
		var ch := text.unicode_at(i)
		if ch < 0x20:
			continue
		if not _seen.has(ch):
			_seen[ch] = [0, where]
		_seen[ch][0] += 1


func _walk(dir: String, visit: Callable) -> void:
	for sub in DirAccess.get_directories_at(dir):
		_walk(dir + "/" + sub, visit)
	for file in DirAccess.get_files_at(dir):
		visit.call(dir + "/" + file)


func _strings(value, where: String) -> void:
	if value is String:
		_add(value, where)
	elif value is Array:
		for v in value:
			_strings(v, where)
	elif value is Dictionary:
		for v in value.values():
			_strings(v, where)


## [line, contents] of each string literal outside comments: "…", '…' and their triple forms.
func _literals(text: String) -> Array:
	var out := []
	var i := 0
	while i < text.length():
		var ch := text[i]
		if ch == "#":
			i = text.find("\n", i)
			if i < 0:
				break
		elif ch == "\"" or ch == "'":
			var close := ch.repeat(3) if text.substr(i, 3) == ch.repeat(3) else ch
			var j := i + close.length()
			while j < text.length() and text.substr(j, close.length()) != close:
				j += 2 if text[j] == "\\" else 1
			out.append([text.count("\n", 0, i) + 1, text.substr(i + close.length(), j - i - close.length())])
			i = j + close.length() - 1
		i += 1
	return out
