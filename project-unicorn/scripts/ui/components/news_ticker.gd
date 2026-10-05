extends Panel

# Bottom news ticker, on the dark theme: outlet names in their own hue, the headline in tertiary ink.
#
# Design notes:
#  - Scrolls leftward at a fixed real-time pace, ignoring game speed
#    and game pause. The Panel sets process_mode = PROCESS_MODE_ALWAYS
#    so this _process keeps running even when SceneTree.paused is true.
#  - Seamless loop via duplicated content + half-width wrap. The label
#    contains two copies of the headline stream end-to-end; when the
#    label has scrolled past one copy width we add the same amount
#    back. Visual: zero gap, zero jump.
#
#  - LIVE LINES: EventBus.headline_added and EventBus.ticker_live_line push a real gameplay
#    line, which is prepended to the loop and the stream is rebuilt. Only headline_added
#    also reaches NewsFeedSystem's "Biz" archive; a ticker_live_line is shown once. This is
#    the game's only non-modal notification channel — candidate arrival must raise a badge
#    and a ticker line WITHOUT interrupting the player. Rebuilding resets the scroll
#    position, so a line landing mid-scroll causes one visible jump; acceptable for a
#    once-in-a-while beat (TODO: splice the line in without resetting the scroll).
#
# Akış içeriği NewsFeedSystem.get_stream()'den gelir (sektör/rakip/biz, 50/30/≤20) ve
# tik sonunda EventBus.news_stream_changed ile tazelenir. TICKER_01..10 anahtarları
# SOĞUK-BAŞLANGIÇ yedeğidir: akış boşken (hafta 1, ilk tik öncesi) ve akış kısayken
# döngüyü doldurur. ANAHTAR ADLARI SABİT SÖZLEŞMEDİR.
#
#  - OPEN / CLOSED: the toggle cell collapses the ticker to that cell alone on the bottom-left; the
#    choice is the player's (Settings "ticker_open"), made here or in Ayarlar (set_open, group
#    news_ticker), and GameShell lays the office and the rail out around it (open_changed). Lines that
#    arrive while it is closed wait in the loop.

const SCROLL_SPEED := 50.0  # pixels per second
const SEPARATOR := "   ·   "
## The stream starts this far right of the toggle cell.
const RUN_PAD := 16.0

# Soğuk-başlangıç havuzunun anahtarları (içerik strings.csv'de; kaynak rozetleri
# NewsFeedSystem.outlet_name()'den döner — kurgusal yayın seti tek evde kalsın).
const AMBIENT_KEYS := ["TICKER_01", "TICKER_02", "TICKER_03", "TICKER_04", "TICKER_05",
	"TICKER_06", "TICKER_07", "TICKER_08", "TICKER_09", "TICKER_10"]

# Akıştan ambient döngüye giren en yeni satır sayısı + döngünün hedef alt uzunluğu
# (kısa döngü aynı üç cümleyi belirgin tekrar eder; eksik kalan ambient'ten dolar).
const STREAM_SHOWN := 12
const LOOP_MIN_PARTS := 8

# Live gameplay lines, newest first, capped so the loop never grows without bound.
const MAX_LIVE_LINES := 6

signal open_changed(open: bool)

@onready var stream: RichTextLabel = $Run/Stream
@onready var _toggle: Button = $Toggle
@onready var _fade: Control = $Run/Fade

var open: bool = true
var _half_width: float = 0.0
var _live_lines: Array[Dictionary] = []


func _ready() -> void:
	add_to_group(&"news_ticker")
	_toggle.pressed.connect(func() -> void: set_open(not open))
	_fade.draw.connect(_draw_fade)
	_set_open(bool(Settings.get_value("ticker_open")))
	EventBus.headline_added.connect(_on_live_line)
	EventBus.ticker_live_line.connect(_on_live_line)
	# Tik-sonu akış tazelemesi (post-tick sinyal — day_advanced tik işlenmeden ÖNCE atılır,
	# ona bağlanmak önceki tikin akışını okurdu; sinyalin kendi yorumuna bak).
	EventBus.news_stream_changed.connect(_rebuild)
	# Ambient yedek tr() anahtarlarından geliyor — dil değişince yeniden kur.
	EventBus.language_changed.connect(_on_language_changed)
	# Yayın renklerinin renk körü ikizi var.
	EventBus.palette_changed.connect(_rebuild.unbind(1))
	await _rebuild()


func _exit_tree() -> void:
	if EventBus.headline_added.is_connected(_on_live_line):
		EventBus.headline_added.disconnect(_on_live_line)
	if EventBus.ticker_live_line.is_connected(_on_live_line):
		EventBus.ticker_live_line.disconnect(_on_live_line)
	if EventBus.news_stream_changed.is_connected(_rebuild):
		EventBus.news_stream_changed.disconnect(_rebuild)
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
	await _rebuild()


func _on_live_line(source: String, text: String) -> void:
	if text.strip_edges() == "":
		return
	_live_lines.push_front({"src": source, "txt": text})
	while _live_lines.size() > MAX_LIVE_LINES:
		_live_lines.pop_back()
	await _rebuild()


func _rebuild() -> void:
	# Two identical copies of the stream end-to-end → seamless loop.
	var single: String = _build_bbcode()
	stream.text = single + single
	stream.position.x = RUN_PAD

	# Layout needs one frame to settle before get_content_width returns
	# a meaningful value. Same for get_content_height (used for y-center).
	await get_tree().process_frame
	_half_width = stream.get_content_width() / 2.0
	stream.position.y = ($Run.size.y - stream.get_content_height()) / 2.0


func _build_bbcode() -> String:
	var parts: PackedStringArray = []
	var hues := {}
	for key: String in NewsFeedSystem.OUTLET_KEYS:
		hues[tr(key)] = UiTokens.D_outlet(key)
	# Canlı satırlar önde (anlık beat'ler); ardından haber akışı (en yeni STREAM_SHOWN
	# satır). Biz-kaynaklı akış satırı zaten canlı satır olarak dönmüş olabilir —
	# aynı cümle döngüde iki kez akmasın diye metin bazlı ayıklanır. Döngü kısa
	# kalırsa (ilk haftalar) soğuk-başlangıç ambient anahtarları tamamlar.
	var seen_txt: Dictionary = {}
	for h in _live_lines:
		parts.append(_part(h.src, h.txt, hues))
		seen_txt[String(h.txt)] = true
	var shown: int = 0
	for line in NewsFeedSystem.get_stream():
		if shown >= STREAM_SHOWN:
			break
		if seen_txt.has(String(line["txt"])):
			continue
		parts.append(_part(String(line["src"]), String(line["txt"]), hues))
		seen_txt[String(line["txt"])] = true
		shown += 1
	if parts.size() < LOOP_MIN_PARTS:
		# Dolgu, koşu tohumu + tikten türeyen deterministik bir kaydırmayla başlar (ev
		# kuralı: RNG yok, hash var) ve AMBIENT_KEYS boyunca dolanır: on anahtarın hepsi
		# sıra alır, açılış koşudan koşuya değişir. Rozet anahtarla eşleşir (döngü sırasıyla
		# değil), böylece bir cümle hangi pencerede çıkarsa çıksın hep aynı yayının altında akar.
		var offset: int = absi(hash("ticker_ambient|%d|%d" % [GameState.run_seed, GameState.day])) \
			% AMBIENT_KEYS.size()
		for i in AMBIENT_KEYS.size():
			if parts.size() >= LOOP_MIN_PARTS:
				break
			var k: int = (offset + i) % AMBIENT_KEYS.size()
			parts.append(_part(NewsFeedSystem.outlet_name(k), tr(String(AMBIENT_KEYS[k])), hues))
	var sep: String = "[color=#%s]%s[/color]" % [UiTokens.D_INK_4.to_html(false), SEPARATOR]
	return sep.join(parts) + sep


## An outlet's name in its hue; a source that is not an outlet (İçeriden, a person) in emphasis ink.
func _part(src: String, txt: String, hues: Dictionary) -> String:
	return "[b][color=#%s]%s[/color][/b]  %s" % [(hues.get(src, UiTokens.D_INK_1) as Color).to_html(false), src, txt]


## The stream fades out over the last pixels of the run.
func _draw_fade() -> void:
	var clear := Color(UiTokens.D_SURFACE_0, 0.0)
	var w: Vector2 = _fade.size
	_fade.draw_polygon(PackedVector2Array([Vector2.ZERO, Vector2(w.x, 0), w, Vector2(0, w.y)]),
		PackedColorArray([clear, UiTokens.D_SURFACE_0, UiTokens.D_SURFACE_0, clear]))


func _process(delta: float) -> void:
	if _half_width <= 0.0:
		return
	stream.position.x -= SCROLL_SPEED * delta
	if stream.position.x <= -_half_width:
		stream.position.x += _half_width
