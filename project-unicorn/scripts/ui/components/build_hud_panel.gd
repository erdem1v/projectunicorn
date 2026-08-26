extends Control

# Yüzen takip kartı — sağ üstte. B5.1'den sonra bu dosya BİR ŞEY ÇİZMİYOR: onaylı
# kartlar (BuildBar · ResearchBar) kendi kendilerini çiziyor ve bu node yalnız
# ONLARI TAŞIYOR.
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
# İKİ ÇUBUK, TEK KART YIĞINI (Ar-Ge W2-F). Bu bir süs değil ADALET MEKANİZMASIDIR:
# §5.0'ın öğrettiği an ancak ikisi AYNI ANDA görünürken okunur — araştırma akarken
# yapım çubuğu "Kimse üzerinde değil." diyor. Tek çubuğa göre yazılmış üç varsayım
# bu yüzden söküldü:
#   1. Tek `build_bar` referansı → çubuk DİZİSİ. Sürükleme her çubuğa bağlanır,
#      yoksa ikinci karttan tutulduğunda yığın yerinde çakılı kalırdı.
#   2. `Root` sabit 360×138 bir Control'dü → VBoxContainer, offset_bottom == offset_top
#      ve aşağı doğru büyüme. Yığın artık ÇOCUKLARINA göre boyutlanıyor;
#      `_clamp_root()` zaten `root.size` okuduğu için kelepçe bedava takip ediyor.
#      (BuildBar'ın 138'i .tscn'de LİTERAL kalır — CAP_H + ROW_* toplamı 140 eder ve
#      türetilmiş bir sayı yayınlanmış bir yüzeyi sessizce 2px oynatırdı. PRESET_FULL_RECT
#      bir çocuk bir container'ın asgari boyutuna HİÇBİR ŞEY katmaz, o yüzden min-size'ı
#      ev sahibi söylemek zorunda — creation_flow.gd:670'in precedent'i.)
#   3. Görünürlük tek boole'a çöküyordu → "oda görünürken gizli" korunur, sonrası
#      "herhangi bir çubuğun parmak izi dolu mu". Çubuk BAŞINA görünürlük her çubuğun
#      KENDİ repaint'inde kalır; ev sahibi `fingerprint()` OKUR, `visible` YAZMAZ —
#      yazsaydı ikisi birbiriyle kavga ederdi.
#
# YENİ KELEPÇE KANCASI (aynı turun getirdiği gerçek hata): `resized` yalnız PANEL
# yeniden boyutlandığında ateşleniyor, ama `Root` artık oturum ORTASINDA da boy
# değiştiriyor (araştırma başlar/biter). Alt kenara sürüklenmiş bir yığın, büyüdüğünde
# ekran dışına taşardı. `root.resized` de kelepçeye bağlandı.
#
# SÜRÜKLENEBİLİR: Root parent rect'ine (CenterViewport) clamp'lenir → top bar / sol ray /
# ticker yapısal olarak erişilemez. Konum oturum boyunca kalır; yeni run'da sağ üst.
# Sürükleme tutamağı kartların KENDİSİ: çubuk kökleri MOUSE_FILTER_PASS, karar satırı ve
# bağlar STOP — yani onların üstünde sürükleme başlamaz, kalan her yerde başlar.
#
# process_mode = ALWAYS: ağaç duraklıyken de sürüklenebilsin ve kartlar canlı kalsın.

@onready var root: Control = $Root

## Ev sahibinin taşıdığı çubuklar. Sıra .tscn'in sırasıdır (yapım üstte kalır —
## yayınlanmış yüzey yerinden oynamaz), ve bu dosya çubukların İÇİNİ bilmez:
## tek istediği `fingerprint()` ve `gui_input`.
var _bars: Array[Control] = []

var _dragging := false
var _drag_free := false

# ODA gizlemesi: "" (oda görünür) iken kart gizlenir — monitör çapası aynı build
# verisini taşır, resmin üstünde ikinci bir kart yüzmez (Erdem onayı 2026-08-06).
var _current_tab: String = ""


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for child in root.get_children():
		var bar := child as Control
		if bar != null and bar.has_method("fingerprint"):
			_bars.append(bar)
			bar.gui_input.connect(_on_card_gui_input)
	resized.connect(_clamp_root)
	# Root artık çocuklarına göre boy değiştiriyor (araştırma başlar/biter) — panel
	# hiç yeniden boyutlanmasa bile yığın büyüyebilir, o yüzden kelepçe onu da dinler.
	root.resized.connect(_clamp_root)
	EventBus.tab_changed.connect(_on_tab_changed)
	# Kartların görünürlüğü İŞİN varlığına bağlı, ilerlemesine değil; her çubuk kendi
	# sinyallerini kendi dinler ve bu node onlara hiçbir şey itmez. Buradaki abonelikler
	# yalnız "yığında çizilecek bir şey kaldı mı" sorusunu tazelemek için.
	EventBus.build_phase_changed.connect(_on_phase_changed)
	EventBus.build_progress_changed.connect(_refresh)
	EventBus.research_started.connect(_on_research_changed)
	EventBus.research_completed.connect(_on_research_changed)
	EventBus.research_frozen.connect(_on_research_changed)
	EventBus.research_resumed.connect(_on_research_changed)
	EventBus.research_progress_changed.connect(_refresh)
	_refresh()


func _exit_tree() -> void:
	if EventBus.tab_changed.is_connected(_on_tab_changed):
		EventBus.tab_changed.disconnect(_on_tab_changed)
	if EventBus.build_phase_changed.is_connected(_on_phase_changed):
		EventBus.build_phase_changed.disconnect(_on_phase_changed)
	if EventBus.build_progress_changed.is_connected(_refresh):
		EventBus.build_progress_changed.disconnect(_refresh)
	if EventBus.research_started.is_connected(_on_research_changed):
		EventBus.research_started.disconnect(_on_research_changed)
	if EventBus.research_completed.is_connected(_on_research_changed):
		EventBus.research_completed.disconnect(_on_research_changed)
	if EventBus.research_frozen.is_connected(_on_research_changed):
		EventBus.research_frozen.disconnect(_on_research_changed)
	if EventBus.research_resumed.is_connected(_on_research_changed):
		EventBus.research_resumed.disconnect(_on_research_changed)
	if EventBus.research_progress_changed.is_connected(_refresh):
		EventBus.research_progress_changed.disconnect(_refresh)


func _on_tab_changed(tab_id: String) -> void:
	_current_tab = tab_id
	_refresh()


func _on_phase_changed(_new_phase: String) -> void:
	_refresh()


func _on_research_changed(_node_id: String) -> void:
	_refresh()


func _refresh() -> void:
	if _current_tab == "":
		visible = false
		return
	# Çubukların KENDİ modelleri "çizilecek bir şey var mı"nın TEK kaynağı: aktif yapım
	# YA DA yayındaki ürün (DESTEK), ve aktif araştırma. Burada ikinci bir koşul yazmak
	# iki gerçek yaratırdı. Çubuğun kendi görünürlüğüne DOKUNULMUYOR — o, çubuğun kendi
	# repaint'inin işi; buradan da yazılsaydı iki yazar tek alan için yarışırdı.
	var any: bool = false
	for bar in _bars:
		if is_instance_valid(bar) and String(bar.call("fingerprint")) != "":
			any = true
			break
	visible = any


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
	# dışarıda) — yığın tamamen içeride kalır.
	if not _drag_free:
		return
	var limit: Vector2 = size - root.size
	root.position = Vector2(
		clampf(root.position.x, 0.0, maxf(0.0, limit.x)),
		clampf(root.position.y, 0.0, maxf(0.0, limit.y)))
