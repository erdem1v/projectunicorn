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
#      SCREAMING_SNAKE key or pure glyph/numeric filler — prose in a scene is a violation.
#
# SKIP list = sanctioned exclusions, each with a reason. Additions require the reason inline.
extends SceneTree

const SCRIPT_ROOT := "res://scripts"
const SCENE_ROOT := "res://scenes"

# Sanctioned exclusions (path prefix match):
const SKIP_PREFIXES := [
	"res://scripts/debug/",            # developer surfaces: smoke fixtures, font specimen, this file
	"res://scenes/debug/",             # ThemeProbe etc.
	"res://scripts/ui/components/right_panel.gd",  # RETIRED surface (ODA rework 2026-08-06) — not swept
	"res://scenes/ui/components/RightPanel.tscn",  # RETIRED surface — not swept
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
var _re_quoted: RegEx
var _re_trchar: RegEx
var _re_word: RegEx
var _re_scene_text: RegEx
var _re_key: RegEx
var _re_filler: RegEx
var _re_logcall: RegEx


func _initialize() -> void:
	_re_logcall = _make("\\b(print|prints|printerr|print_rich|push_warning|push_error|assert)\\s*\\(")
	_re_quoted = _make("\"([^\"\\\\]*(?:\\\\.[^\"\\\\]*)*)\"")
	_re_trchar = _make("[çğıöşüÇĞİÖŞÜ]")
	_re_word = _make("(?i)\\b(" + "|".join(TR_ASCII_WORDS) + ")\\b")
	_re_scene_text = _make("^\\s*(text|tooltip_text|placeholder_text)\\s*=\\s*\"(.*)\"\\s*$")
	_re_key = _make("^[A-Z0-9_]+$")
	_re_filler = _make(SCENE_FILLER_RE)
	_walk(SCRIPT_ROOT, "gd")
	_walk(SCENE_ROOT, "tscn")
	var n := _hits.size()
	for i in mini(n, 80):
		print("RESIDUE  " + _hits[i])
	if n > 80:
		print("RESIDUE  ... and %d more" % (n - 80))
	print("LOC RESIDUE: %d hit(s)  [%s]" % [n, "FAIL" if n > 0 else "CLEAN"])
	quit(1 if n > 0 else 0)


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
	var line_no := 0
	while not f.eof_reached():
		line_no += 1
		var line := f.get_line()
		if ext == "gd":
			_check_script_line(path, line_no, line)
		else:
			_check_scene_line(path, line_no, line)


func _check_script_line(path: String, line_no: int, line: String) -> void:
	if line.strip_edges().begins_with("#"):
		return  # full-line comments are documentation, not residue
	if _re_logcall.search(line) != null:
		return  # print/push_* console output is developer-facing, not player-visible
	for m in _re_quoted.search_all(line):
		var lit := m.get_string(1)
		if lit == "":
			continue
		if lit.begins_with("res://") or lit.begins_with("user://"):
			continue  # asset/save paths are addresses, not player-visible text
		if _re_trchar.search(lit) != null:
			_hits.append("%s:%d [tr-char] \"%s\"" % [path, line_no, lit.left(60)])
		elif _re_word.search(lit) != null:
			_hits.append("%s:%d [ascii-tr] \"%s\"" % [path, line_no, lit.left(60)])


func _check_scene_line(path: String, line_no: int, line: String) -> void:
	var m := _re_scene_text.search(line)
	if m == null:
		return
	var val := m.get_string(2)
	if val == "":
		return
	if _re_key.search(val) != null:
		return  # a localization KEY — legal (auto-translate renders it)
	if _re_filler.search(val) != null:
		return  # glyph/numeric mock filler — legal
	_hits.append("%s:%d [scene] %s = \"%s\"" % [path, line_no, m.get_string(1), val.left(60)])
