class_name HRPopover
extends Control

# ============================================================================
# Bağlı açılır panel (Kare 6'nın zam kutusu, departman başlığının mesai paneli).
#
# Kod tabanında popover / anchored panel / Popup* düğümü YOK — bu dosya o eksik
# ilkeli kuruyor. İki tuzağı birlikte aşmak zorunda:
#   1. CenterViewport.clip_contents = true → sekmenin içine konan panel viewport
#      kenarında KIRPILIR.
#   2. Sekme düğümü move_child(...,0) ile en alta itiliyor (BuildHUD üstte kalsın
#      diye) → sekme içindeki panel sürüklenebilir HUD'ın ALTINDA çizilir.
# Çözüm: GameShell/ModalLayer'a (CanvasLayer, layer = 10) monte olmak. O katmanın
# dönüşümü yok, dolayısıyla çapa düğümün global_position/size değerleri birebir
# aynı koordinat uzayında okunur.
#
# Kapanma: ESC (proje konvansiyonu ui_cancel) ve dışarı tıklama. Aynı anda tek
# popover: mount() eskisini kapatır.
#
# process_mode = ALWAYS: saat duruyorken de tıklanabilir olmalı (pause-gated UI,
# bilinen ajan tuzağı). Popover saate DOKUNMAZ — bu kod tabanında sekmeler pause
# etmez, ve TimeManager.resume_if_paused'ın üretimde hiç çağıranı yok.
# ============================================================================

signal closed

const NOTCH := 7.0              # çentik yarı-yüksekliği
const GAP := 8.0                # çapa ile panel arası boşluk
const EDGE_MARGIN := 12.0       # ekran kenarına en az bu kadar yaklaşır
const MIN_WIDTH := 268

var _panel: PanelContainer = null
var _body: VBoxContainer = null
var _notch: Control = null
var _anchor_rect: Rect2 = Rect2()


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	# ANCHORS + OFFSETS: yalnız set_anchors_preset çağrıldığında bu kök (bir CanvasLayer'ın
	# çocuğu) size = (0,0) bildiriyordu ve _place'in kelepçesi her şeyi EDGE_MARGIN'e
	# çöküyordu (popover sol üst köşede açılıyordu). Offset'ler de kuruluyor, ve ekran
	# ölçüsü ayrıca get_viewport_rect()'ten okunuyor — kökün kendi size'ına güvenilmiyor.
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	# Kök tüm ekranı kaplar ve tıklamayı YUTAR: dışarı-tıklama kapatması böyle çalışır,
	# ayrıca arkadaki karta yanlışlıkla tıklanması engellenir.
	mouse_filter = Control.MOUSE_FILTER_STOP
	# Çentik panelin ALTINDA, kökün çocuğu olarak duruyor — PanelContainer tek Control
	# çocuk bekler, ikinci bir çocuk yerleşimi bozardı. Çizim `draw` sinyaliyle
	# (conviction_track.gd deseni).
	_notch = Control.new()
	_notch.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_notch.visible = false
	_notch.draw.connect(_draw_notch)
	add_child(_notch)
	_panel = PanelContainer.new()
	_panel.theme_type_variation = &"CardPanel"
	_panel.custom_minimum_size = Vector2(MIN_WIDTH, 0)
	_panel.mouse_filter = Control.MOUSE_FILTER_STOP   # panel içi tıklama köke düşmesin
	add_child(_panel)
	_body = VBoxContainer.new()
	_body.add_theme_constant_override("separation", 8)
	_panel.add_child(_body)


func body() -> VBoxContainer:
	# İçeriği çağıran doldurur — add_child SONRASI (ev konvansiyonu:
	# populate-after-add_child; _ready referansları ancak o zaman dolu).
	return _body


func open_at(anchor: Control) -> void:
	if anchor != null and is_instance_valid(anchor) and anchor.is_inside_tree():
		_anchor_rect = Rect2(anchor.global_position, anchor.size)
	else:
		_anchor_rect = Rect2()
	# Panelin gerçek boyutu içerik yerleştikten sonra biliniyor → iki kare bekle.
	await get_tree().process_frame
	await get_tree().process_frame
	if is_instance_valid(self):
		_place()


func _place() -> void:
	if _panel == null or not is_instance_valid(_panel):
		return
	var screen: Vector2 = get_viewport_rect().size
	var panel_size: Vector2 = _panel.get_combined_minimum_size()
	panel_size.x = maxf(panel_size.x, float(MIN_WIDTH))
	# Yatay: çapanın sağına; taşarsa soluna geçer.
	var flipped: bool = false
	var x: float = _anchor_rect.position.x + _anchor_rect.size.x + GAP
	if x + panel_size.x > screen.x - EDGE_MARGIN:
		x = _anchor_rect.position.x - panel_size.x - GAP
		flipped = true
	x = clampf(x, EDGE_MARGIN, maxf(EDGE_MARGIN, screen.x - panel_size.x - EDGE_MARGIN))
	# Dikey: çapanın üstüyle hizalı, ekrana kelepçeli.
	var y: float = clampf(_anchor_rect.position.y - NOTCH,
		EDGE_MARGIN, maxf(EDGE_MARGIN, screen.y - panel_size.y - EDGE_MARGIN))
	_panel.set_anchors_preset(Control.PRESET_TOP_LEFT)
	_panel.position = Vector2(x, y)
	_panel.size = panel_size
	_place_notch(flipped, x, y, panel_size)


func _place_notch(flipped: bool, px: float, py: float, panel_size: Vector2) -> void:
	# Çentik çapanın dikey ORTASINA bakar. Çapa panelin dikey aralığının dışında
	# kalıyorsa (kelepçe kaydırmıştır) çentik yalan söyler, çizilmez.
	if _anchor_rect.size == Vector2.ZERO:
		return
	var mid_y: float = _anchor_rect.position.y + _anchor_rect.size.y * 0.5
	if mid_y < py + NOTCH or mid_y > py + panel_size.y - NOTCH:
		return
	_notch.set_anchors_preset(Control.PRESET_TOP_LEFT)
	_notch.size = Vector2(NOTCH, NOTCH * 2.0)
	_notch.position = Vector2(px + panel_size.x if flipped else px - NOTCH, mid_y - NOTCH)
	_notch.set_meta("flipped", flipped)
	_notch.visible = true
	_notch.queue_redraw()


func _draw_notch() -> void:
	var flipped: bool = bool(_notch.get_meta("flipped", false))
	var pts: PackedVector2Array
	if flipped:
		pts = PackedVector2Array([Vector2(0, 0), Vector2(NOTCH, NOTCH), Vector2(0, NOTCH * 2.0)])
	else:
		pts = PackedVector2Array([Vector2(NOTCH, 0), Vector2(0, NOTCH), Vector2(NOTCH, NOTCH * 2.0)])
	_notch.draw_colored_polygon(pts, UiTokens.CARD_BG)


func _gui_input(event: InputEvent) -> void:
	# Kökte (panelin DIŞINDA) tıklama → kapat.
	if event is InputEventMouseButton and (event as InputEventMouseButton).pressed:
		close()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		close()


func close() -> void:
	closed.emit()
	queue_free()


# --- Mount ------------------------------------------------------------------

static func mount(anchor: Control) -> HRPopover:
	# PanelLayer'ı bulur, açık olan popover'ı kapatır, yenisini monte edip döndürür.
	# Çağıran sırası: mount → body()'yi doldur → open_at(anchor).
	#
	# ModalLayer DEĞİL (bkz. hr_tab._open_atlas): oradayken game_shell'in 2. bekçisi
	# Space/1-4'ü yutuyordu, yani bir mesai panelini açmak saati durdurma yeteneğini
	# sessizce elden alıyordu. Popover bir panel, bir karar anı değil.
	if anchor == null or not anchor.is_inside_tree():
		return null
	var layer: Node = anchor.get_tree().get_root().find_child("PanelLayer", true, false)
	if layer == null:
		push_error("[HRPopover] GameShell/PanelLayer bulunamadı — popover monte edilemiyor")
		return null
	for child in layer.get_children():
		if child is HRPopover:
			(child as HRPopover).close()
	var pop := HRPopover.new()
	layer.add_child(pop)
	return pop
