extends Panel

# Bottom news ticker — ambient UI chrome per PROJECT_SPEC §6 (World & Drama)
# and TECH_SPEC §5.2 / §11.3.
#
# Design notes:
#  - Hardcoded dummy headline pool. Real news engine (phase-aware,
#    reactive) is a later task — see TODO below.
#  - Scrolls leftward at a fixed real-time pace, ignoring game speed
#    and game pause. The Panel sets process_mode = PROCESS_MODE_ALWAYS
#    so this _process keeps running even when SceneTree.paused is true.
#  - Seamless loop via duplicated content + half-width wrap. The label
#    contains two copies of the headline stream end-to-end; when the
#    label has scrolled past one copy width we add the same amount
#    back. Visual: zero gap, zero jump.
#
#  - LIVE LINES (HR Core): EventBus.headline_added pushes a real gameplay line, which is
#    prepended to the ambient pool and the stream is rebuilt. This is the game's only
#    non-modal notification channel — the HR spec needs candidate arrival to raise a badge
#    and a ticker line WITHOUT interrupting the player. Rebuilding resets the scroll
#    position, so a line landing mid-scroll causes one visible jump; acceptable for a
#    once-in-a-while beat, and the fix (splice without reset) belongs to the news engine.
#
# NEWS ENGINE BAĞLAMASI (Dünya İnandırıcılığı, 2026-08-06): ambient içerik artık
# NewsFeedSystem.get_stream()'den akar (üç kaynaklı gerçek akış: sektör/rakip/biz,
# 50/30/≤20) ve gün sonunda EventBus.news_stream_changed ile tazelenir. TICKER_01..10
# anahtarları SOĞUK-BAŞLANGIÇ yedeğidir: akış boşken (gün 1, ilk tick öncesi) ve akış
# kısayken döngüyü doldurur — ANAHTAR ADLARI SABİT SÖZLEŞMEDİR (ODA task'ı, Erdem
# onay düzeltmesi #3); içerikleri bu bağlamayla gerçek dünya-sesine yazıldı.
# Kalan TODO'lar: .scandal_breaking bağlantısı + kritik-haber görsel muamelesi +
# canlı satırı scroll sıfırlamadan ekleme (splice).

const SCROLL_SPEED := 50.0  # pixels per second
const SEPARATOR := "   ·   "
const SOURCE_COLOR := UiTokens.ACCENT_HEX  # amber source name (single token source)

# Soğuk-başlangıç havuzunun anahtarları (içerik strings.csv'de; kaynak rozetleri
# NewsFeedSystem.OUTLETS'ten döner — kurgusal yayın seti tek evde kalsın).
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
	EventBus.news_stream_changed.connect(_on_stream_changed)
	# Ambient yedek tr() anahtarlarından geliyor — dil değişince yeniden kur.
	EventBus.language_changed.connect(_on_language_changed)
	await _rebuild()


func _exit_tree() -> void:
	if EventBus.headline_added.is_connected(_on_headline_added):
		EventBus.headline_added.disconnect(_on_headline_added)
	if EventBus.news_stream_changed.is_connected(_on_stream_changed):
		EventBus.news_stream_changed.disconnect(_on_stream_changed)
	if EventBus.language_changed.is_connected(_on_language_changed):
		EventBus.language_changed.disconnect(_on_language_changed)


func _on_language_changed(_locale: String) -> void:
	await _rebuild()


func _on_stream_changed() -> void:
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
	_center_vertically()


func _build_bbcode() -> String:
	var parts: PackedStringArray = []
	# Canlı satırlar önde (anlık beat'ler); ardından haber akışı (en yeni STREAM_SHOWN
	# satır). Biz-kaynaklı akış satırı zaten canlı satır olarak dönmüş olabilir —
	# aynı cümle döngüde iki kez akmasın diye metin bazlı ayıklanır. Döngü kısa
	# kalırsa (ilk günler) soğuk-başlangıç ambient anahtarları tamamlar.
	var seen_txt: Dictionary = {}
	for h in _live_lines:
		parts.append("[color=%s]%s[/color]  %s" % [SOURCE_COLOR, h.src, h.txt])
		seen_txt[String(h.txt)] = true
	var shown: int = 0
	for line in NewsFeedSystem.get_stream():
		if shown >= STREAM_SHOWN:
			break
		if seen_txt.has(String(line["txt"])):
			continue
		parts.append("[color=%s]%s[/color]  %s" % [SOURCE_COLOR, String(line["src"]), String(line["txt"])])
		seen_txt[String(line["txt"])] = true
		shown += 1
	if parts.size() < LOOP_MIN_PARTS:
		# Dolgu her seferinde 0'dan başlayıp LOOP_MIN_PARTS'ta kesiliyordu: on anahtarın
		# son ikisi (TICKER_09/10) hiçbir koşuda akmıyor, soğuk başlangıç da her koşuda
		# birebir aynı sekiz cümle oluyordu. Başlangıç indeksi artık koşu tohumu +
		# günden türeyen deterministik bir kaydırma (ev kuralı: RNG yok, hash var) ve
		# tur AMBIENT_KEYS boyunca dolanıyor — onunun da sırası geliyor, açılış koşudan
		# koşuya değişiyor. Rozet anahtarla eşleşir (indeksle değil), böylece bir cümle
		# hangi pencerede çıkarsa çıksın hep aynı yayının altında akar.
		var offset: int = absi(hash("ticker_ambient|%d|%d" % [GameState.run_seed, GameState.day])) \
			% AMBIENT_KEYS.size()
		for i in AMBIENT_KEYS.size():
			if parts.size() >= LOOP_MIN_PARTS:
				break
			var k: int = (offset + i) % AMBIENT_KEYS.size()
			var outlet: String = NewsFeedSystem.OUTLETS[k % NewsFeedSystem.OUTLETS.size()]
			parts.append("[color=%s]%s[/color]  %s" % [SOURCE_COLOR, outlet, tr(String(AMBIENT_KEYS[k]))])
	return SEPARATOR.join(parts) + SEPARATOR


func _process(delta: float) -> void:
	if _half_width <= 0.0:
		return
	stream.position.x -= SCROLL_SPEED * delta
	if stream.position.x <= -_half_width:
		stream.position.x += _half_width


func _center_vertically() -> void:
	# Place the stream so its single line sits mid-panel. content_height
	# is the natural height of one wrap-free line.
	var content_h: float = stream.get_content_height()
	stream.position.y = (size.y - content_h) / 2.0
