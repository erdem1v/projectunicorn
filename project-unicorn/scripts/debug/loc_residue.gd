# LOC RESIDUE CHECKER — the BILINGUAL BIRTH LAW's proof-command (CLAUDE.md).
# Headless, read-only, exits NONZERO on any hit:
#   godot --headless --path . -s res://scripts/debug/loc_residue.gd
#
# Four checks:
#   1. Script literals: any double-quoted literal in scripts/ (the code part of a line only,
#      debug/ excluded) carrying a Turkish-charclass character. Comments that quote copy are
#      documentation, so only the part before a trailing comment is scanned; the cut tracks
#      quote state (a '#' inside a string is not a comment).
#   2. Script literals: ASCII-only Turkish — words whose Turkish identity dies under İ/ı folding
#      (KAZANILDI, MASADAN, DEVAM...) and are invisible to check 1. Whole-word,
#      case-insensitive, tested INSIDE quoted literals only (identifiers never match).
#   3. Scene text: every non-empty text/tooltip_text/placeholder_text value in scenes/ must be a
#      localization key THAT ACTUALLY EXISTS in strings.csv, or pure glyph/numeric filler. The
#      scan is whole-file so a value spanning lines is caught, and an ALL-CAPS value that is
#      not in strings.csv fails (a hardcoded caption or a typo'd key renders raw either way).
#   4. tr() inside a `static func` — it COMPILES and dies at runtime, because a static has no
#      Object to translate through; the symptom is a card that is never built and nothing
#      naming the cause.
#
# SKIP list = sanctioned exclusions, each with a reason. Additions require the reason inline.
extends SceneTree

const SCRIPT_ROOT := "res://scripts"
const SCENE_ROOT := "res://scenes"
const STRINGS_CSV := "res://localization/strings.csv"
const MAX_PRINTED := 600

# Sanctioned exclusions (path prefix match):
const SKIP_PREFIXES := [
	"res://scripts/debug/",            # developer surfaces: smoke fixtures, probes, this file
	"res://scenes/debug/",             # ThemeProbe etc.
	# The first-boot language gate names its two options in their OWN languages
	# ("Türkçe" / "English") ON PURPOSE — an option rendered in a language the player
	# cannot read is not an option. This is the one sanctioned player-visible literal.
	"res://scripts/onboarding/language_gate.gd",
]

# ASCII-only Turkish wordlist — folded forms with no Turkish charclass character left.
# Deliberately absent: English-colliding tokens (RISK, TIER, TRACTION, TEST, NET...), and
# "ARA"/"GIDER", which are a month abbreviation and a shot-kind id, i.e. data rather than copy.
const TR_ASCII_WORDS := [
	"ACIK", "ADIM", "ALIM", "ARAYIS", "ARAYISI", "ARTIDA", "AYLIK", "BASKA", "BASLA", "BASLADI",
	"BASLAT", "BEKLEYEN", "BIRAK", "BULUNAMADI", "BULUNAN", "BUTCE", "BUYUK", "BUYUME", "BUYUYOR",
	"CALISAN", "CANLI", "COZULEN", "DEGIL", "DENEYIM", "DEVAM", "DONDU", "DONEM", "DURDUR",
	"DURUM", "DUSUK", "DUSUYOR", "EGITIM", "GECERLILIK", "GELIR", "GELISTIR", "GELISTIRME", "GERI",
	"GIDIS", "GIRISIM", "GORUSME", "GUCLU", "HAZIR", "HENUZ", "HIZLI", "ILIK", "IMZA", "IMZALA",
	"INDIRIM", "INSAAT", "IPTAL", "KABUL", "KALAN", "KALDI", "KAPANDI", "KAPAT", "KAPI", "KARAR",
	"KARARLILIK", "KASA", "KAYIT", "KAZANILDI", "KILITLI", "KISA", "KISI", "KULLANICI", "MASADA",
	"MASADAKI", "MASADAN", "MASAYA", "MESAI", "MUSTERI", "ODEME", "ONAYLA", "OYALA", "PORTFOY",
	"REDDET", "SABIR", "SAGLIK", "SAGLIKLI", "SATIN", "SATIS", "SAYI", "SEKTOR", "SIMDILIK",
	"SIRKET", "SOZLESME", "SUREC", "SUREKLI", "SURUYOR", "TAMAM", "TASARIM", "TEKLIF", "TOPLANTI",
	"UCRET", "URUN", "VAZGEC", "YAKINDA", "YALNIZ", "YATIRIM", "YATIRIMCI", "YATIRIMCILAR",
	"YAYINLA", "YAZILIM", "YONETIM", "YUKSEK", "ZAYIF",
]

# Scene values that are legal without being keys: empty, glyphs, numeric/mock fillers.
const SCENE_FILLER_RE := "^[0-9xX%$+\\-—–·✕.,:/() ]*$"

var _hits: Array[String] = []
var _csv_keys: Dictionary = {}
var _re_quoted: RegEx
var _re_trchar: RegEx
## `lower_snake.lower_snake` — the shape of a seam id, and of nothing a player reads.
var _re_seam_id: RegEx
var _re_word: RegEx
var _re_scene_prop: RegEx
var _re_key: RegEx
var _re_filler: RegEx
var _re_logcall: RegEx
var _re_trcall: RegEx


func _initialize() -> void:
	_re_trcall = _make("\\btr\\(")
	_re_logcall = _make("\\b(print|prints|printerr|print_rich|push_warning|push_error|assert|_shot_fail)\\s*\\(")
	_re_quoted = _make("\"([^\"\\\\]*(?:\\\\.[^\"\\\\]*)*)\"")
	_re_trchar = _make("[çğıöşüÇĞİÖŞÜ]")
	_re_word = _make("(?i)\\b(" + "|".join(TR_ASCII_WORDS) + ")\\b")
	# Whole-file, multiline: [^"\\] matches newlines too, so a value spanning lines is caught.
	_re_scene_prop = _make("(?m)^[ \\t]*(text|tooltip_text|placeholder_text)[ \\t]*=[ \\t]*\"((?:[^\"\\\\]|\\\\.)*)\"")
	_re_seam_id = _make("^[a-z][a-z0-9_]*[.][a-z][a-z0-9_]*$")
	_re_key = _make("^[A-Z0-9_]+$")
	_re_filler = _make(SCENE_FILLER_RE)
	_load_csv_keys()
	_walk(SCRIPT_ROOT, "gd")
	_walk(SCENE_ROOT, "tscn")
	# --only=<kind> narrows the printout to one bucket. Without it the MAX_PRINTED cap is spent
	# on whichever kind sorts first (script hits, always). The tally below is never filtered.
	var only: String = ""
	for arg in OS.get_cmdline_args():
		if String(arg).begins_with("--only="):
			only = String(arg).trim_prefix("--only=")
	var shown: Array[String] = _hits
	if only != "":
		shown = []
		for h in _hits:
			if h.contains("[%s]" % only):
				shown.append(h)
		print("RESIDUE  (filtered to [%s]: %d of %d)" % [only, shown.size(), _hits.size()])
	var n := shown.size()
	for i in mini(n, MAX_PRINTED):
		print("RESIDUE  " + shown[i])
	if n > MAX_PRINTED:
		print("RESIDUE  ... and %d more" % (n - MAX_PRINTED))
	# Per-kind tally: a bare total hides one bucket growing while another shrinks. Printed
	# even at zero so a green run states what it checked.
	var kinds := {"tr-char": 0, "ascii-tr": 0, "static-tr": 0, "scene": 0, "scene-fakekey": 0, "scene-multiline": 0}
	for h in _hits:
		for k in kinds:
			if h.contains("[%s]" % k):
				kinds[k] = int(kinds[k]) + 1
				break
	print("LOC RESIDUE BY KIND: script tr-char=%d ascii-tr=%d static-tr=%d | scene prose=%d fakekey=%d multiline=%d" % [
		kinds["tr-char"], kinds["ascii-tr"], kinds["static-tr"], kinds["scene"],
		kinds["scene-fakekey"], kinds["scene-multiline"]])
	print("LOC RESIDUE: %d hit(s)  [%s]  (csv_keys=%d)" % [
		n, "FAIL" if n > 0 else "CLEAN", _csv_keys.size()])
	quit(1 if n > 0 else 0)


# The key set a scene value is allowed to name. Read through get_csv_line() — the same
# mechanism the Localization autoload uses — so quoted values containing commas or
# embedded newlines (the ANGEL_* event bodies) cannot shift the key column.
func _load_csv_keys() -> void:
	var f := FileAccess.open(STRINGS_CSV, FileAccess.READ)
	if f == null:
		_hits.append("%s — UNREADABLE (cannot validate scene keys)" % STRINGS_CSV)
		return
	f.get_csv_line()  # header
	while not f.eof_reached():
		var row: PackedStringArray = f.get_csv_line()
		if row.size() >= 1 and row[0].strip_edges() != "":
			_csv_keys[row[0].strip_edges()] = true


func _make(pattern: String) -> RegEx:
	var r := RegEx.new()
	var err := r.compile(pattern)
	assert(err == OK)
	return r


func _skipped(path: String) -> bool:
	for p in SKIP_PREFIXES:
		if path.begins_with(p):
			return true
	return false


func _walk(root: String, ext: String) -> void:
	var dir := DirAccess.open(root)
	if dir == null:
		return
	dir.list_dir_begin()
	var entry := dir.get_next()
	while entry != "":
		var path := root + "/" + entry
		if dir.current_is_dir():
			if not entry.begins_with("."):
				_walk(path, ext)
		elif entry.get_extension() == ext and not _skipped(path):
			_check_file(path, ext)
		entry = dir.get_next()
	dir.list_dir_end()


func _check_file(path: String, ext: String) -> void:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		_hits.append("%s — UNREADABLE" % path)
		return
	if ext == "tscn":
		# Whole-file: a scene value may span lines, which a per-line scan cannot see.
		_check_scene_text(path, f.get_as_text())
		return
	var line_no := 0
	var in_static := false
	while not f.eof_reached():
		line_no += 1
		var line := f.get_line()
		# Track whether we are inside a `static func` (check 4). The substitute for tr()
		# there is TranslationServer.translate.
		var stripped := line.strip_edges()
		if stripped.begins_with("static func "):
			in_static = true
		elif stripped.begins_with("func ") or (line.length() > 0 and not line.begins_with("\t") \
				and not line.begins_with(" ") and not stripped.begins_with("#") and stripped != ""):
			in_static = false
		if in_static and _re_trcall.search(_code_part(line)) != null:
			_hits.append("%s:%d [static-tr] tr() inside a static func — use TranslationServer.translate" % [
				path, line_no])
		_check_script_line(path, line_no, line)


func _check_script_line(path: String, line_no: int, line: String) -> void:
	if line.strip_edges().begins_with("#"):
		return  # full-line comments are documentation, not residue
	if _re_logcall.search(line) != null:
		return  # print/push_* console output is developer-facing, not player-visible
	# `# LOC-DATA <reason>` — a per-LINE opt-out for quoted strings that are DATA, not copy
	# (a save-migration table naming legacy Turkish values, a debug seed name). Marking the
	# line beats a file-level SKIP, which would blind the checker to real copy in the same
	# file. `rg "LOC-DATA"` is the complete list, each with its reason.
	if line.contains("# LOC-DATA"):
		return
	for m in _re_quoted.search_all(_code_part(line)):
		var lit := m.get_string(1)
		if lit == "":
			continue
		if lit.begins_with("res://") or lit.begins_with("user://"):
			continue  # asset/save paths are addresses, not player-visible text
		# A NAMESPACED IDENTIFIER is an address too. The event engine's seams are named in the
		# GDD's own vocabulary — `musteri.satisfaction`, `urun.is_live` — Turkish by design, and
		# nothing player-facing looks like `lower_snake.lower_snake`. Exempting the SHAPE rather
		# than the files keeps the checker looking at the real strings in the same file.
		if _re_seam_id.search(lit) != null:
			continue
		if _re_trchar.search(lit) != null:
			_hits.append("%s:%d [tr-char] \"%s\"" % [path, line_no, lit.left(60)])
		elif _re_word.search(lit) != null:
			_hits.append("%s:%d [ascii-tr] \"%s\"" % [path, line_no, lit.left(60)])


# The part of a line before its trailing comment. Quote state is tracked because a
# '#' inside a string literal is a character, not a comment — `"#e2a33c"` must survive intact.
# Backslash escapes are stepped over so a `\"` cannot flip the state and swallow real code.
func _code_part(line: String) -> String:
	var in_quote := false
	var i := 0
	while i < line.length():
		var c := line[i]
		if c == "\\" and in_quote:
			i += 2
			continue
		if c == "\"":
			in_quote = not in_quote
		elif c == "#" and not in_quote:
			return line.substr(0, i)
		i += 1
	return line


func _check_scene_text(path: String, text: String) -> void:
	for m in _re_scene_prop.search_all(text):
		var prop := m.get_string(1)
		var val := m.get_string(2)
		if val == "":
			continue
		var line_no := text.substr(0, m.get_start()).count("\n") + 1
		if val.contains("\n"):
			# Baked multi-line prose. Never a key — keys carry no newlines. Always residue.
			_hits.append("%s:%d [scene-multiline] %s = \"%s…\"" % [
				path, line_no, prop, val.substr(0, 44).replace("\n", "\\n")])
			continue
		# FILLER IS TESTED FIRST, and the order is load-bearing: the key pattern ^[A-Z0-9_]+$
		# also matches a bare numeric placeholder ("0", "50" — badge and meter mock values).
		# Filler can never be a real key (its class holds no letters or underscore).
		if _re_filler.search(val) != null:
			continue  # glyph/numeric mock filler — legal
		if _re_key.search(val) != null:
			if _csv_keys.has(val):
				continue  # a REAL localization key — legal (auto-translate renders it)
			# Looks like a key, is not one: either a hardcoded ALL-CAPS caption or a typo.
			# Both render the raw token to the player, so both are residue.
			_hits.append("%s:%d [scene-fakekey] %s = \"%s\" — not in strings.csv" % [
				path, line_no, prop, val])
			continue
		_hits.append("%s:%d [scene] %s = \"%s\"" % [path, line_no, prop, val.left(60)])
