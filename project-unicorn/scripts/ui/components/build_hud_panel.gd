extends Control

# Yüzen takip kartı yığını — sağ üstte. Bu node bir şey çizmez: onaylı kartlar (BuildBar ·
# ResearchBar) kendilerini çizer, burası onları taşır, gizler ve sürükletir. Koyu tema bu kökte
# (BuildHUDPanel.tscn); kartlar ondan çözülür.
#
# GÖRÜNÜRLÜK: herhangi bir çubuğun fingerprint()'i doluysa görünür. Pencerelerin altında çizilir
# ve üstüne bir pencere binince gizlenir; şehir haritası açıkken de gizli, çünkü haritanın ofis
# kartı sağ kenarı alır.
# Çubuk başına görünürlük çubuğun kendi repaint'inin işidir; bu node onu yalnız OKUR,
# yazsaydı iki yazar tek alan için yarışırdı.
#
# BOY: Root bir VBoxContainer ve kartlarına göre boylanır (araştırma başlar/biter), o yüzden
# kelepçe hem panelin hem Root'un `resized`'ını dinler; yoksa alt kenara sürüklenmiş yığın
# büyüyünce ekran dışına taşardı.
#
# SÜRÜKLEME: Root bu node'un rect'ine kelepçelenir; WindowLayer onu rayın sağındaki alana
# oturtur, yani top bar / sol ray / ticker yapısal olarak erişilemez. Tutamak kartların
# kendisidir: kart kökleri PASS, düğme ve bağlar STOP — onların üstünde sürükleme başlamaz.
# Konum oturum boyunca kalır.
#
# PROCESS_MODE_ALWAYS: ağaç duraklıyken de sürüklenebilsin ve kartlar canlı kalsın.

@onready var root: Control = $Root

## Taşınan çubuklar, .tscn sırasıyla (DESTEK üstte). Bu node çubukların içini bilmez: tek
## istediği `fingerprint()` ve `gui_input`.
var _bars: Array[Control] = []

var _dragging := false
var _drag_free := false
var _map_open := false
var _window_cover := Rect2()


func _ready() -> void:
	add_to_group(&"office_overlays")
	process_mode = Node.PROCESS_MODE_ALWAYS
	for child in root.get_children():
		var bar := child as Control
		if bar != null and bar.has_method("fingerprint"):
			_bars.append(bar)
			bar.gui_input.connect(_on_card_gui_input)
	resized.connect(_clamp_root)
	root.resized.connect(_clamp_root)
	# Yalnız "yığında çizilecek bir şey kaldı mı" sorusu için; çubuklar kendi sinyallerini
	# kendileri dinler ve bu node onlara hiçbir şey itmez.
	var r1: Callable = _refresh.unbind(1)
	for s: Signal in [EventBus.build_phase_changed, EventBus.research_started,
			EventBus.research_completed, EventBus.research_frozen, EventBus.research_resumed]:
		s.connect(r1)
	EventBus.build_progress_changed.connect(_refresh)
	EventBus.research_progress_changed.connect(_refresh)
	_refresh()


## OfficeView her yerleşim yüklenişinde ve kurucunun yolculuğu boyunca (örtü) `office_overlays`
## grubuna söyler.
func set_map_open(open: bool) -> void:
	_map_open = open
	_refresh()


## WindowLayer, açık pencerelerin kapladığı alanı her yerleşimde söyler.
func set_window_cover(cover: Rect2) -> void:
	_window_cover = cover
	_refresh()


func _refresh() -> void:
	visible = not _map_open and not _window_cover.intersects(root.get_global_rect()) \
		and _bars.any(func(bar: Control) -> bool: return String(bar.call("fingerprint")) != "")
	# Gizlenen kart bırakışı duyamaz; yeniden görününce imleçle kaymasın.
	if not visible:
		_dragging = false


# --- Sürükleme ----------------------------------------------------------------

func _on_card_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		_dragging = event.pressed
		if _dragging and not _drag_free:
			# Sağ-anchor'lu varsayılan yerleşimi, global konumu koruyarak noktasal konuma
			# çevir; sonrası position üzerinden yürür.
			_drag_free = true
			var gp: Vector2 = root.global_position
			var sz: Vector2 = root.size
			root.anchor_left = 0.0
			root.anchor_top = 0.0
			root.anchor_right = 0.0
			root.anchor_bottom = 0.0
			root.global_position = gp
			root.size = sz
	elif event is InputEventMouseMotion and _dragging:
		root.position += event.relative
		_clamp_root()


func _clamp_root() -> void:
	if _drag_free:
		var limit: Vector2 = size - root.size
		root.position = Vector2(
			clampf(root.position.x, 0.0, maxf(0.0, limit.x)),
			clampf(root.position.y, 0.0, maxf(0.0, limit.y)))
	_refresh()
