class_name HRPopover
extends Control

# Bağlı açılır panel (§9.2): zam kutusu, mesai paneli, kişi menüsü.
#
# GameShell/PanelLayer'a monte olur, sekmenin içine değil: CenterViewport kırpar
# (clip_contents) ve sekme düğümü BuildHUD'ın altında çizilir. PanelLayer'ın dönüşümü
# yok, dolayısıyla çapanın global_position/size değerleri aynı uzayda okunur.
#
# Kapanma: ESC (ui_cancel) ve dışarı tıklama. Aynı anda tek popover: mount() eskisini kapatır.
# process_mode = ALWAYS: saat duruyorken de tıklanabilir olmalı.

const LIFT := 6.0               # panel çapanın üst kenarından bu kadar yukarı başlar
const EDGE_MARGIN := 12.0       # ekran kenarına en az bu kadar yaklaşır
const MIN_WIDTH := 268

var _panel: PanelContainer = null
var _body: VBoxContainer = null
var _anchor_rect: Rect2 = Rect2()


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	# Offset'ler de kurulmazsa CanvasLayer çocuğu olan kök size = (0,0) bildirir.
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	# Kök tüm ekranı kaplar ve tıklamayı yutar: dışarı-tıklama kapatması böyle çalışır.
	mouse_filter = Control.MOUSE_FILTER_STOP
	_panel = PanelContainer.new()
	_panel.theme_type_variation = &"CardPanel"
	_panel.custom_minimum_size = Vector2(MIN_WIDTH, 0)
	_panel.mouse_filter = Control.MOUSE_FILTER_STOP   # panel içi tıklama köke düşmesin
	add_child(_panel)
	_body = VBoxContainer.new()
	_body.add_theme_constant_override("separation", 8)
	_panel.add_child(_body)


## İçeriği çağıran doldurur, mount'tan SONRA (_ready referansları ancak o zaman dolu).
func body() -> VBoxContainer:
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
	var screen: Vector2 = get_viewport_rect().size
	var panel_size: Vector2 = _panel.get_combined_minimum_size()
	panel_size.x = maxf(panel_size.x, float(MIN_WIDTH))
	# Tek kural: panelin sağ kenarı çapanın sağ kenarıyla hizalı. Kelepçe bir konum
	# seçimi değil korkuluk: çapa dar viewport'ta taşsa da panel ekranda kalır.
	var x: float = _anchor_rect.position.x + _anchor_rect.size.x - panel_size.x
	x = clampf(x, EDGE_MARGIN, maxf(EDGE_MARGIN, screen.x - panel_size.x - EDGE_MARGIN))
	# Dikey: çapanın üstüyle hizalı, ekrana kelepçeli.
	var y: float = clampf(_anchor_rect.position.y - LIFT,
		EDGE_MARGIN, maxf(EDGE_MARGIN, screen.y - panel_size.y - EDGE_MARGIN))
	_panel.set_anchors_preset(Control.PRESET_TOP_LEFT)
	_panel.position = Vector2(x, y)
	_panel.size = panel_size


func _gui_input(event: InputEvent) -> void:
	# Kökte (panelin DIŞINDA) tıklama → kapat.
	if event is InputEventMouseButton and (event as InputEventMouseButton).pressed:
		close()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		close()


func close() -> void:
	queue_free()


# --- Mount ------------------------------------------------------------------

## Açık popover'ı kapatır, yenisini monte edip döndürür. Sıra: mount → body()'yi doldur →
## open_at(anchor). ModalLayer değil: orada game_shell Space/1-4'ü yutar ve bir panel
## açmak saati durdurma yeteneğini elden alırdı. Popover bir panel, karar anı değil.
static func mount(anchor: Control) -> HRPopover:
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
