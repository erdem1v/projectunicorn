# LOC RESIDUE CHECKER — the BILINGUAL BIRTH LAW's proof-command (CLAUDE.md, Content & Language Laws).
# Headless, read-only, exits NONZERO on any hit:
#   godot --headless --path . -s res://scripts/debug/loc_residue.gd
#
# Three checks:
#   1. Script literals: any double-quoted literal in scripts/ (non-comment lines, debug/ excluded)
#      carrying a Turkish-charclass character.
#   2. Script literals: ASCII-only Turkish — words whose Turkish identity dies under İ/ı folding
#      (KAZANILDI, MASADAN, DEVAM...) and are invisible to check 1. Wordlist curated from the
#      2026-08-10 corpus tokenization (docs/audits/localization_phase1_2026-08-07.md §4.9); whole-word,
#      case-insensitive, tested INSIDE quoted literals only (identifiers never match).
#   3. Scene text: every non-empty text/tooltip_text/placeholder_text value in scenes/ must be a
#      localization key THAT ACTUALLY EXISTS in strings.csv, or pure glyph/numeric filler.
#
# THREE GAPS CLOSED 2026-08-18 — the instrument was passing things it should have caught:
#   a. TRAILING comments were scanned. Only FULL-LINE comments were skipped, so an
#      architectural comment quoting a UI string ("Churn'e ~N gün") counted as residue — 38 of
#      them. Comments that document copy ARE documentation; rewording them to reach zero would
#      have damaged the docs to satisfy the meter. Now only the CODE part of a line is scanned,
#      with the cut found by tracking quote state (a '#' inside a string is not a comment).
#   b. MULTI-LINE scene values were invisible. The scene regex anchored the closing quote to the
#      same line, so MentorIntroModal's 4-paragraph baked monologue — the largest single scene
#      literal in the game — was never reported. Residue could have read "zero" with it still
#      sitting in the scene. The scan is now whole-file.
#   c. FAKE KEYS passed as real ones. Any ^[A-Z0-9_]+$ value was accepted as "a key", so 29
#      hardcoded ALL-CAPS captions (TopBar's CASH/MRR/BURN/NET/RUNWAY/BRAND/REPUTATION,
#      LeftTabs' HR, HuntTab's BEKLEYEN/YATIRIMCILAR, BuildHUD's BULUNAN/KALAN/TASARIM…) were
#      indistinguishable from localization keys. A key is legal only if strings.csv HAS it —
#      which also turns a typo'd key into a failure instead of a raw token rendered on screen.
#
# SKIP list = sanctioned exclusions, each with a reason. Additions require the reason inline.
extends SceneTree

const SCRIPT_ROOT := "res://scripts"
const SCENE_ROOT := "res://scenes"
const STRINGS_CSV := "res://localization/strings.csv"
const MAX_PRINTED := 200

# Sanctioned exclusions (path prefix match):
const SKIP_PREFIXES := [
	"res://scripts/debug/",            # developer surfaces: smoke fixtures, font specimen, this file
	"res://scenes/debug/",             # ThemeProbe etc.
	"res://scripts/ui/components/right_panel.gd",  # RETIRED surface (ODA rework 2026-08-06) — not swept
	"res://scenes/ui/components/RightPanel.tscn",  # RETIRED surface — not swept
	# The first-boot language gate names its two options in their OWN languages
	# ("Türkçe" / "English") ON PURPOSE — an option rendered in a language the player
	# cannot read is not an option. This is the one sanctioned player-visible literal.
	"res://scripts/onboarding/language_gate.gd",
]

# ASCII-only Turkish wordlist — folded forms with no Turkish charclass character left.
# Sources: corpus tokenization fold (high-frequency stems) + the Phase 1 §2.6 curated set.
# English-colliding tokens (RISK, TIER, TRACTION, TEST, NET...) deliberately absent.
const TR_ASCII_WORDS := [
	"ACIK", "ADIM", "ALIM", "ARAYIS", "ARAYISI", "ARTIDA", "AYLIK", "BASKA", "BASLA", "BASLAT",
	"BASLADI", "BEKLEYEN", "BIRAK", "BULUNAN", "BULUNAMADI", "BUTCE", "BUYUK", "BUYUME", "BUYUYOR",
	"CALISAN", "CANLI", "COZULEN", "DEGIL", "DENEYIM", "DEVAM", "DONDU", "DONEM", "DURUM", "DUSUK",
	"DUSUYOR", "EGITIM", "GECERLILIK", "GELISTIR", "GELISTIRME", "GERI", "GIDIS", "GIRISIM",
	"GORUSME", "GUCLU", "HAZIR", "HENUZ", "HIZLI", "ILIK", "IMZALA", "INDIRIM", "INSAAT", "IPTAL",
	"KALAN", "KALDI", "KAPI", "KARARLILIK", "KAYIT", "KAZANILDI", "KILITLI", "KISA", "KISI",
	"KULLANICI", "MASADA", "MASADAKI", "MASADAN", "MESAI", "MUSTERI", "ODEME", "PORTFOY", "SABIR",
	"SAGLIK", "SAGLIKLI", "SATIN", "SATIS", "SAYI", "SEKTOR", "SIMDILIK", "SIRKET", "SOZLESME",
	"SUREC", "SUREKLI", "SURUYOR", "TAMAM", "TASARIM", "TEKLIF", "TOPLANTI", "UCRET", "URUN",
	"VAZGEC", "YAKINDA", "YALNIZ", "YATIRIM", "YATIRIMCI", "YATIRIMCILAR", "YAYINLA", "YAZILIM",
	"YONETIM", "YUKSEK", "ZAYIF",
]

# Scene values that are legal without being keys: empty, glyphs, numeric/mock fillers.
const SCENE_FILLER_RE := "^[0-9xX%$+\\-—–·✕.,:/() ]*$"

var _hits: Array[String] = []
var _csv_keys: Dictionary = {}
var _re_quoted: RegEx
var _re_trchar: RegEx
var _re_word: RegEx
var _re_scene_prop: RegEx
var _re_key: RegEx
var _re_filler: RegEx
var _re_logcall: RegEx


func _initialize() -> void:
	_re_logcall = _make("\\b(print|prints|printerr|print_rich|push_warning|push_error|assert)\\s*\\(")
	_re_quoted = _make("\"([^\"\\\\]*(?:\\\\.[^\"\\\\]*)*)\"")
	_re_trchar = _make("[çğıöşüÇĞİÖŞÜ]")
	_re_word = _make("(?i)\\b(" + "|".join(TR_ASCII_WORDS) + ")\\b")
	# Whole-file, multiline: [^"\\] matches newlines too, so a value spanning lines is caught.
	_re_scene_prop = _make("(?m)^[ \\t]*(text|tooltip_text|placeholder_text)[ \\t]*=[ \\t]*\"((?:[^\"\\\\]|\\\\.)*)\"")
	_re_key = _make("^[A-Z0-9_]+$")
	_re_filler = _make(SCENE_FILLER_RE)
	_load_csv_keys()
	_walk(SCRIPT_ROOT, "gd")
	_walk(SCENE_ROOT, "tscn")
	var n := _hits.size()
	for i in mini(n, MAX_PRINTED):
		print("RESIDUE  " + _hits[i])
	if n > MAX_PRINTED:
		print("RESIDUE  ... and %d more" % (n - MAX_PRINTED))
	# Per-kind tally. The sweep runs for nine commits and the ONLY honest progress signal is
	# each bucket shrinking; a bare total hides a batch that keyed 60 script literals while
	# quietly adding a scene one. Printed even at zero so a green run states what it checked.
	var kinds := {"tr-char": 0, "ascii-tr": 0, "scene": 0, "scene-fakekey": 0, "scene-multiline": 0}
	for h in _hits:
		for k in kinds:
			if h.contains("[%s]" % k):
				kinds[k] = int(kinds[k]) + 1
				break
	print("LOC RESIDUE BY KIND: script tr-char=%d ascii-tr=%d | scene prose=%d fakekey=%d multiline=%d" % [
		kinds["tr-char"], kinds["ascii-tr"], kinds["scene"],
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
		# Whole-file: a scene value may span lines (gap b), which a per-line scan cannot see.
		_check_scene_text(path, f.get_as_text())
		return
	var line_no := 0
	while not f.eof_reached():
		line_no += 1
		_check_script_line(path, line_no, f.get_line())


func _check_script_line(path: String, line_no: int, line: String) -> void:
	if line.strip_edges().begins_with("#"):
		return  # full-line comments are documentation, not residue
	if _re_logcall.search(line) != null:
		return  # print/push_* console output is developer-facing, not player-visible
	# `# LOC-DATA <reason>` — a per-LINE opt-out for quoted strings that are DATA, not copy.
	# The sweep meets this genuinely: a save-migration table has to name the legacy values it
	# maps FROM, and those were Turkish. Marking the line beats a file-level SKIP (which would
	# blind the checker to real copy in the same file) and beats obfuscating the data. Every
	# exception is one grep away — `rg "LOC-DATA"` is the complete list, each with its reason.
	if line.contains("# LOC-DATA"):
		return
	for m in _re_quoted.search_all(_code_part(line)):
		var lit := m.get_string(1)
		if lit == "":
			continue
		if lit.begins_with("res://") or lit.begins_with("user://"):
			continue  # asset/save paths are addresses, not player-visible text
		if _re_trchar.search(lit) != null:
			_hits.append("%s:%d [tr-char] \"%s\"" % [path, line_no, lit.left(60)])
		elif _re_word.search(lit) != null:
			_hits.append("%s:%d [ascii-tr] \"%s\"" % [path, line_no, lit.left(60)])


# The part of a line before its trailing comment (gap a). Quote state is tracked because a
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
		# FILLER IS TESTED FIRST, and the order is load-bearing: the key pattern
		# ^[A-Z0-9_]+$ also matches a bare numeric placeholder ("0", "1", "50" — the badge
		# and meter mock values), so asking "is it a key?" first reported 15 numerals as
		# fake keys. Filler can never be a real key (the filler class holds no letters or
		# underscore), so letting it answer first is safe as well as correct.
		if _re_filler.search(val) != null:
			continue  # glyph/numeric mock filler — legal
		if _re_key.search(val) != null:
			if _csv_keys.has(val):
				continue  # a REAL localization key — legal (auto-translate renders it)
			# Looks like a key, is not one: either a hardcoded ALL-CAPS caption or a typo.
			# Both render the raw token to the player, so both are residue (gap c).
			_hits.append("%s:%d [scene-fakekey] %s = \"%s\" — not in strings.csv" % [
				path, line_no, prop, val])
			continue
		_hits.append("%s:%d [scene] %s = \"%s\"" % [path, line_no, prop, val.left(60)])
