extends Panel

# Bottom news ticker — ambient UI chrome.
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
#  - LIVE LINES: EventBus.headline_added pushes a real gameplay line, which is
#    prepended to the loop and the stream is rebuilt. This is the game's only
#    non-modal notification channel — candidate arrival must raise a badge
#    and a ticker line WITHOUT interrupting the player. Rebuilding resets the scroll
#    position, so a line landing mid-scroll causes one visible jump; acceptable for a
#    once-in-a-while beat (TODO: splice the line in without resetting the scroll).
#
# Akış içeriği NewsFeedSystem.get_stream()'den gelir (sektör/rakip/biz, 50/30/≤20) ve
# gün sonunda EventBus.news_stream_changed ile tazelenir. TICKER_01..10 anahtarları
# SOĞUK-BAŞLANGIÇ yedeğidir: akış boşken (gün 1, ilk tick öncesi) ve akış kısayken
# döngüyü doldurur. ANAHTAR ADLARI SABİT SÖZLEŞMEDİR.

const SCROLL_SPEED := 50.0  # pixels per second
const SEPARATOR := "   ·   "

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

@onready var stream: RichTextLabel = $Stream

var _half_width: float = 0.0
var _live_lines: Array[Dictionary] = []


func _ready() -> void:
	EventBus.headline_added.connect(_on_headline_added)
	# Gün-sonu akış tazelemesi (post-tick sinyal — day_advanced tick'ten ÖNCE atılır,
	# ona bağlanmak dünkü akışı okurdu; sinyalin kendi yorumuna bak).
	EventBus.news_stream_changed.connect(_rebuild)
	# Ambient yedek tr() anahtarlarından geliyor — dil değişince yeniden kur.
	EventBus.language_changed.connect(_on_language_changed)
	await _rebuild()


func _exit_tree() -> void:
	if EventBus.headline_added.is_connected(_on_headline_added):
		EventBus.headline_added.disconnect(_on_headline_added)
	if EventBus.news_stream_changed.is_connected(_rebuild):
		EventBus.news_stream_changed.disconnect(_rebuild)
	if EventBus.language_changed.is_connected(_on_language_changed):
		EventBus.language_changed.disconnect(_on_language_changed)


func _on_language_changed(_locale: String) -> void:
	await _rebuild()


func _on_headline_added(source: String, text: String) -> void:
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
	stream.position.x = 0.0

	# Layout needs one frame to settle before get_content_width returns
	# a meaningful value. Same for get_content_height (used for y-center).
	await get_tree().process_frame
	_half_width = stream.get_content_width() / 2.0
	stream.position.y = (size.y - stream.get_content_height()) / 2.0


func _build_bbcode() -> String:
	var parts: PackedStringArray = []
	# Canlı satırlar önde (anlık beat'ler); ardından haber akışı (en yeni STREAM_SHOWN
	# satır). Biz-kaynaklı akış satırı zaten canlı satır olarak dönmüş olabilir —
	# aynı cümle döngüde iki kez akmasın diye metin bazlı ayıklanır. Döngü kısa
	# kalırsa (ilk günler) soğuk-başlangıç ambient anahtarları tamamlar.
	var seen_txt: Dictionary = {}
	for h in _live_lines:
		parts.append(_part(h.src, h.txt))
		seen_txt[String(h.txt)] = true
	var shown: int = 0
	for line in NewsFeedSystem.get_stream():
		if shown >= STREAM_SHOWN:
			break
		if seen_txt.has(String(line["txt"])):
			continue
		parts.append(_part(String(line["src"]), String(line["txt"])))
		seen_txt[String(line["txt"])] = true
		shown += 1
	if parts.size() < LOOP_MIN_PARTS:
		# Dolgu, koşu tohumu + günden türeyen deterministik bir kaydırmayla başlar (ev
		# kuralı: RNG yok, hash var) ve AMBIENT_KEYS boyunca dolanır: on anahtarın hepsi
		# sıra alır, açılış koşudan koşuya değişir. Rozet anahtarla eşleşir (döngü sırasıyla
		# değil), böylece bir cümle hangi pencerede çıkarsa çıksın hep aynı yayının altında akar.
		var offset: int = absi(hash("ticker_ambient|%d|%d" % [GameState.run_seed, GameState.day])) \
			% AMBIENT_KEYS.size()
		for i in AMBIENT_KEYS.size():
			if parts.size() >= LOOP_MIN_PARTS:
				break
			var k: int = (offset + i) % AMBIENT_KEYS.size()
			parts.append(_part(NewsFeedSystem.outlet_name(k), tr(String(AMBIENT_KEYS[k]))))
	return SEPARATOR.join(parts) + SEPARATOR


func _part(src: String, txt: String) -> String:
	return "[color=%s]%s[/color]  %s" % [UiTokens.ACCENT_HEX, src, txt]


func _process(delta: float) -> void:
	if _half_width <= 0.0:
		return
	stream.position.x -= SCROLL_SPEED * delta
	if stream.position.x <= -_half_width:
		stream.position.x += _half_width
