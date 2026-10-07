extends Panel

# Bottom news ticker, on the dark theme: outlet names in their own hue, the headline in tertiary ink.
#
# Design notes:
#  - Scrolls leftward at a fixed real-time pace, ignoring game speed
#    and game pause. The Panel sets process_mode = PROCESS_MODE_ALWAYS
#    so this _process keeps running even when SceneTree.paused is true.
#  - The label holds only the parts now on the run (_belt, left to right).
#    A part that has scrolled fully off the left edge is popped and the label moves right by its
#    width in the same frame, so the visible text never shifts; the tail is fed from _sources(),
#    which _cursor walks round. New content only rewinds the cursor, so nothing on screen jumps and
#    the newest lines are the next to enter at the right edge. A language or palette change is the
#    one thing that clears the belt (the text on it was built in the old language and hues).
#
#  - LIVE LINES: EventBus.headline_added and EventBus.ticker_live_line push a real gameplay
#    line, which leads _sources(). Only headline_added also reaches NewsFeedSystem's "Biz"
#    archive; a ticker_live_line is shown once. This is the game's only non-modal notification
#    channel — candidate arrival must raise a badge and a ticker line WITHOUT interrupting the
#    player. Live lines are unsaved and built in the current language, so a language change drops them.
#
# Akış içeriği NewsFeedSystem.get_stream()'den gelir (sektör/rakip/piyasa/biz, 45/25/10/≤20) ve
# tik sonunda EventBus.news_stream_changed ile tazelenir. TICKER_01..10 anahtarları
# SOĞUK-BAŞLANGIÇ yedeğidir: akış boşken (hafta 1, ilk tik öncesi) ve akış kısayken
# kaynak listesini doldurur. ANAHTAR ADLARI SABİT SÖZLEŞMEDİR.
#
#  - OPEN / CLOSED: the toggle cell collapses the ticker to that cell alone on the bottom-left; the
#    choice is the player's (Settings "ticker_open"), made here or in Ayarlar (set_open, group
#    news_ticker), and GameShell lays the office and the rail out around it (open_changed). Lines that
#    arrive while it is closed wait in the source list.

const SCROLL_SPEED := 50.0  # pixels per second
const SEPARATOR := "   ·   "
## The stream starts this far right of the toggle cell.
const RUN_PAD := 16.0

# Soğuk-başlangıç havuzunun anahtarları (içerik strings.csv'de; kaynak rozetleri
# NewsFeedSystem.outlet_name()'den döner — kurgusal yayın seti tek evde kalsın).
const AMBIENT_KEYS := ["TICKER_01", "TICKER_02", "TICKER_03", "TICKER_04", "TICKER_05",
	"TICKER_06", "TICKER_07", "TICKER_08", "TICKER_09", "TICKER_10"]

# Akıştan kaynak listesine giren en yeni satır sayısı + listenin hedef alt uzunluğu
# (kısa liste aynı üç cümleyi belirgin tekrar eder; eksik kalan ambient'ten dolar).
const STREAM_SHOWN := 12
const LOOP_MIN_PARTS := 8

# Live gameplay lines, newest first, capped so the source list never grows without bound.
const MAX_LIVE_LINES := 6

signal open_changed(open: bool)

@onready var stream: RichTextLabel = $Run/Stream
@onready var _toggle: Button = $Toggle
@onready var _fade: Control = $Run/Fade

var open: bool = true
var _live_lines: Array[Dictionary] = []
var _belt: Array[Dictionary] = []   # the parts on the run, left to right: {bbcode, txt, w}
var _cursor: int = 0   # the next index of _sources() to feed the belt
var _hues: Dictionary = {}   # outlet name -> hue


func _ready() -> void:
	add_to_group(&"news_ticker")
	_toggle.pressed.connect(func() -> void: set_open(not open))
	_fade.draw.connect(_draw_fade)
	_set_open(bool(Settings.get_value("ticker_open")))
	EventBus.headline_added.connect(_on_live_line)
	EventBus.ticker_live_line.connect(_on_live_line)
	# Tik-sonu akış tazelemesi (post-tick sinyal — day_advanced tik işlenmeden ÖNCE atılır,
	# ona bağlanmak önceki tikin akışını okurdu; sinyalin kendi yorumuna bak).
	EventBus.news_stream_changed.connect(_refresh)
	# Ambient yedek tr() anahtarlarından geliyor — dil değişince yeniden kur.
	EventBus.language_changed.connect(_on_language_changed)
	# Yayın renklerinin renk körü ikizi var.
	EventBus.palette_changed.connect(_reset.unbind(1))
	_reset()


func _exit_tree() -> void:
	if EventBus.headline_added.is_connected(_on_live_line):
		EventBus.headline_added.disconnect(_on_live_line)
	if EventBus.ticker_live_line.is_connected(_on_live_line):
		EventBus.ticker_live_line.disconnect(_on_live_line)
	if EventBus.news_stream_changed.is_connected(_refresh):
		EventBus.news_stream_changed.disconnect(_refresh)
	if EventBus.language_changed.is_connected(_on_language_changed):
		EventBus.language_changed.disconnect(_on_language_changed)


## The player's choice, from the toggle cell or Ayarlar: laid out and kept.
func set_open(value: bool) -> void:
	_set_open(value)
	Settings.set_value("ticker_open", value)


func _set_open(value: bool) -> void:
	open = value
	$Run.visible = open
	set_process(open)
	anchor_right = 1.0 if open else 0.0
	offset_right = 0.0 if open else _toggle.size.x
	open_changed.emit(open)


func _on_language_changed(_locale: String) -> void:
	_live_lines.clear()
	_reset()


func _on_live_line(source: String, text: String) -> void:
	if text.strip_edges() == "":
		return
	_live_lines.push_front({"src": source, "txt": text})
	while _live_lines.size() > MAX_LIVE_LINES:
		_live_lines.pop_back()
	_refresh()


## New content: the belt keeps moving, and the newest lines are the next to be fed.
func _refresh() -> void:
	_cursor = 0


## The text on the belt no longer fits the language or the hues: start the run over.
func _reset() -> void:
	_hues.clear()
	for key: String in NewsFeedSystem.OUTLET_KEYS:
		_hues[tr(key)] = UiTokens.D_outlet(key)
	_belt.clear()
	_cursor = 0
	stream.text = ""
	stream.position.x = RUN_PAD


## What the belt cycles through, in order: live lines (newest first), then the stream's newest
## STREAM_SHOWN lines, then ambient lines up to LOOP_MIN_PARTS. A stream line that already ran as
## a live line is skipped, so one sentence never rides the belt twice.
func _sources() -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	var seen_txt: Dictionary = {}
	for h in _live_lines:
		out.append(h)
		seen_txt[String(h.txt)] = true
	var shown: int = 0
	for line in NewsFeedSystem.get_stream():
		if shown >= STREAM_SHOWN:
			break
		if seen_txt.has(String(line["txt"])):
			continue
		out.append({"src": String(line["src"]), "txt": String(line["txt"])})
		seen_txt[String(line["txt"])] = true
		shown += 1
	if out.size() < LOOP_MIN_PARTS:
		# Dolgu, koşu tohumu + tikten türeyen deterministik bir kaydırmayla başlar (ev
		# kuralı: RNG yok, hash var) ve AMBIENT_KEYS boyunca dolanır: on anahtarın hepsi
		# sıra alır, açılış koşudan koşuya değişir. Rozet anahtarla eşleşir (liste sırasıyla
		# değil), böylece bir cümle hangi pencerede çıkarsa çıksın hep aynı yayının altında akar.
		var offset: int = absi(hash("ticker_ambient|%d|%d" % [GameState.run_seed, GameState.day])) \
			% AMBIENT_KEYS.size()
		for i in AMBIENT_KEYS.size():
			if out.size() >= LOOP_MIN_PARTS:
				break
			var k: int = (offset + i) % AMBIENT_KEYS.size()
			out.append({"src": NewsFeedSystem.outlet_name(k), "txt": tr(String(AMBIENT_KEYS[k]))})
	return out


## The first source at or after the cursor whose sentence is not already on the belt, as a belt
## part; empty when every source is on it.
func _next_part(sources: Array[Dictionary]) -> Dictionary:
	for _i in sources.size():
		var source: Dictionary = sources[_cursor % sources.size()]
		_cursor += 1
		if not _belt.any(func(p: Dictionary) -> bool: return p["txt"] == source["txt"]):
			return _part(String(source["src"]), String(source["txt"]))
	return {}


## One belt part: an outlet name in its hue (a source that is not an outlet, İçeriden or a person,
## in emphasis ink), the sentence and the separator, with the width the label will give it.
func _part(src: String, txt: String) -> Dictionary:
	var hue: Color = _hues.get(src, UiTokens.D_INK_1)
	var sep: String = "[color=#%s]%s[/color]" % [UiTokens.D_INK_4.to_html(false), SEPARATOR]
	var badge_w: float = stream.get_theme_font(&"bold_font").get_string_size(
		src, HORIZONTAL_ALIGNMENT_LEFT, -1, stream.get_theme_font_size(&"bold_font_size")).x
	var body_w: float = stream.get_theme_font(&"normal_font").get_string_size(
		"  " + txt + SEPARATOR, HORIZONTAL_ALIGNMENT_LEFT, -1, stream.get_theme_font_size(&"normal_font_size")).x
	return {
		"bbcode": "[b][color=#%s]%s[/color][/b]  %s%s" % [hue.to_html(false), src, txt, sep],
		"txt": txt,
		"w": badge_w + body_w,
	}


## The stream fades out over the last pixels of the run.
func _draw_fade() -> void:
	var clear := Color(UiTokens.D_SURFACE_0, 0.0)
	var w: Vector2 = _fade.size
	_fade.draw_polygon(PackedVector2Array([Vector2.ZERO, Vector2(w.x, 0), w, Vector2(0, w.y)]),
		PackedColorArray([clear, UiTokens.D_SURFACE_0, UiTokens.D_SURFACE_0, clear]))


func _process(delta: float) -> void:
	stream.position.x -= SCROLL_SPEED * delta
	var changed: bool = false
	# A part fully off the left edge leaves; the label moves right by its width so the rest stays put.
	while not _belt.is_empty() and stream.position.x + float(_belt[0]["w"]) <= 0.0:
		stream.position.x += float(_belt.pop_front()["w"])
		changed = true
	var edge: float = $Run.size.x
	var tail: float = stream.position.x
	for part in _belt:
		tail += float(part["w"])
	if tail < edge:
		var sources: Array[Dictionary] = _sources()
		while tail < edge:
			var next: Dictionary = _next_part(sources)
			if next.is_empty():
				break
			_belt.append(next)
			tail += float(next["w"])
			changed = true
	if changed:
		stream.text = "".join(_belt.map(func(p: Dictionary) -> String: return p["bbcode"]))
		stream.position.y = ($Run.size.y - stream.get_content_height()) / 2.0
