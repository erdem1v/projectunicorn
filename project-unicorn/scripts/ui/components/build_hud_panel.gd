extends Control

# Build Takip Kartı — sağ üstte yüzen tracker. B5.1'den sonra bu dosya artık BİR ŞEY
# ÇİZMİYOR: onaylı kart (BuildBar) kendi kendini çiziyor ve bu node yalnız ONU TAŞIYOR.
#
# NE GİTTİ ve NEDEN: eskiden burada bir header (ikon + ad + ✕ iptal), üç fazlık mini
# şerit, BETA'nın BULUNAN/ÇÖZÜLEN/KALAN satırı ve iki karar düğmesi vardı. Onaylı kartın
# üç satırı bunların hepsini zaten söylüyor (ürün · faz + iş yükü · karar), yani kart
# içinde kart çizmek aynı gerçeği iki kez söylemek olurdu. 2i'nin "karttaki tek
# basılabilir şey karar satırıdır" kuralı da mini şerit ve ✕ ile bir arada duramazdı.
#
# İPTAL DÜĞMESİ BU KARTTAN ÇIKTI ve bu raporlanan bir kayıptır: `ProductSystem.cancel_build`
# duruyor ve Ürün sayfasındaki giriş yerinde, ama yüzen tracker'dan iptal edilemiyor.
# Onaylı sayfa iptali hiçbir karede çizmiyor; uydurulmadı.
#
# SÜRÜKLENEBİLİR: Root parent rect'ine (CenterViewport) clamp'lenir → top bar / sol ray /
# ticker yapısal olarak erişilemez. Konum oturum boyunca kalır; yeni run'da sağ üst.
# Sürükleme tutamağı artık kartın KENDİSİ: BuildBar kökü MOUSE_FILTER_PASS, karar satırı
# STOP — yani karar satırının üstünde sürükleme başlamaz, kalan her yerde başlar.
#
# process_mode = ALWAYS: ağaç duraklıyken de sürüklenebilsin ve kart canlı kalsın.

@onready var root: Control = $Root
@onready var build_bar: Control = $Root/BuildBar

const CARD_W := 360.0   # onaylı tracker genişliği

var _dragging := false
var _drag_free := false

# ODA gizlemesi: "" (oda görünür) iken kart gizlenir — monitör çapası aynı build
# verisini taşır, resmin üstünde ikinci bir kart yüzmez (Erdem onayı 2026-08-06).
var _current_tab: String = ""


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	build_bar.gui_input.connect(_on_card_gui_input)
	resized.connect(_clamp_root)
	EventBus.tab_changed.connect(_on_tab_changed)
	# Kartın görünürlüğü BUILD'in varlığına bağlı, ilerlemesine değil; BuildBar kendi
	# sinyallerini kendi dinler ve bu node ona hiçbir şey itmez.
	EventBus.build_phase_changed.connect(_on_phase_changed)
	EventBus.build_progress_changed.connect(_refresh)
	_refresh()


func _exit_tree() -> void:
	if EventBus.tab_changed.is_connected(_on_tab_changed):
		EventBus.tab_changed.disconnect(_on_tab_changed)
	if EventBus.build_phase_changed.is_connected(_on_phase_changed):
		EventBus.build_phase_changed.disconnect(_on_phase_changed)
	if EventBus.build_progress_changed.is_connected(_refresh):
		EventBus.build_progress_changed.disconnect(_refresh)


func _on_tab_changed(tab_id: String) -> void:
	_current_tab = tab_id
	_refresh()


func _on_phase_changed(_new_phase: String) -> void:
	_refresh()


func _refresh() -> void:
	if _current_tab == "":
		visible = false
		return
	# Kartın kendi modeli "çizilecek bir şey var mı"nın TEK kaynağı: aktif yapım YA DA
	# yayındaki ürün (DESTEK). Burada ikinci bir koşul yazmak iki gerçek yaratırdı.
	visible = build_bar != null and build_bar.fingerprint() != ""


# --- Sürükleme ----------------------------------------------------------------

func _on_card_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		_dragging = event.pressed
		if _dragging:
			_ensure_free_position()
	elif event is InputEventMouseMotion and _dragging:
		root.position += event.relative
		_clamp_root()


func _ensure_free_position() -> void:
	# Sağ-anchor'lu varsayılan yerleşimi, global konumu koruyarak noktasal konuma
	# çevirir — sonrası position üzerinden yürür.
	if _drag_free:
		return
	_drag_free = true
	var gp: Vector2 = root.global_position
	var sz: Vector2 = root.size
	root.anchor_left = 0.0
	root.anchor_top = 0.0
	root.anchor_right = 0.0
	root.anchor_bottom = 0.0
	root.global_position = gp
	root.size = sz


func _clamp_root() -> void:
	# İzinli alan = bu node'un rect'i = CenterViewport (top bar / sol ray / ticker
	# dışarıda) — kart tamamen içeride kalır.
	if not _drag_free:
		return
	var limit: Vector2 = size - root.size
	root.position = Vector2(
		clampf(root.position.x, 0.0, maxf(0.0, limit.x)),
		clampf(root.position.y, 0.0, maxf(0.0, limit.y)))
