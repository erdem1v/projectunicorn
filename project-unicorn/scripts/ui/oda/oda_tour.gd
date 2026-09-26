extends Control

# ODA ilk-açılış turu: altı çapayı sırayla spotlight'lar, adlandırır, tek cümle açıklar.
# YALNIZ İLK RUN'DA — bayrak user://settings.json'da (Settings, run'lardan bağımsız).
# GEÇ / son adımda BAŞLA / Esc / sekme geçişi — her çıkış yolu bayrağı yazar.
#
# Mount: PanelLayer, tam ekran. ModalLayer değil (game_shell Space/1-3 kısayollarını
# keser ve gerçek modallarla katman karışır); OdaView'un çocuğu da değil (dim yalnız
# CenterViewport'u kaplar, TopBar ve sol ray tur altında tıklanabilir kalırdı). Çapa
# geometrisi yine de OdaView'un rect'ine göre ölçülür (_stage_node): oda resmi ekranın
# yalnız orta bölgesinde durur.
# Dim = spotlight rect'in etrafını çerçeveleyen DÖRT ColorRect (shader'sız delik deseni).
# Tur açıkken saat durur; kapanışta turun bulduğu hıza döner.

# ODA'nın dondurulmuş teması: tur OdaView'un altında olmadığı için proje temasını
# miras alırdı ve Oda*/Chrome* varyasyonları Terminal renkleriyle çözülürdü.
const ODA_THEME := preload("res://themes/oda_frozen_theme.tres")

const STEPS := [
	{"rect": "monitor", "name": "ODA_ANCHOR_MONITOR", "desc": "ODA_TOUR_MONITOR_DESC"},
	{"rect": "phone", "name": "ODA_ANCHOR_PHONE", "desc": "ODA_TOUR_PHONE_DESC"},
	{"rect": "papers_zone", "name": "ODA_ANCHOR_PAPERS", "desc": "ODA_TOUR_PAPERS_DESC"},
	{"rect": "board_outer", "name": "ODA_ANCHOR_BOARD", "desc": "ODA_TOUR_BOARD_DESC"},
	{"rect": "frames_band", "name": "ODA_ANCHOR_FRAMES", "desc": "ODA_TOUR_FRAMES_DESC"},
	{"rect": "window", "name": "ODA_ANCHOR_WINDOW", "desc": "ODA_TOUR_WINDOW_DESC"},
]

var _step: int = 0
# Çapa geometrisinin ölçüldüğü dikdörtgen (OdaView); her adımda yeniden okunur.
var _stage_node: Control = null
var _pre_tour_speed: int = 0
var _dims: Array[ColorRect] = []
var _spot: Panel
var _card: PanelContainer
var _name_label: Label
var _desc_label: Label
var _next_btn: Button


func set_stage(node: Control) -> void:
	_stage_node = node


func _ready() -> void:
	theme = ODA_THEME
	mouse_filter = Control.MOUSE_FILTER_STOP  # arkaya tıklama sızmasın
	_pre_tour_speed = TimeManager.current_speed
	EventBus.speed_change_requested.emit(0)
	# Sekmeye geçiş turu bitirir: tur ayrı katmanda gizlenemez, görünmez hâlde
	# Space/1-3/Esc yutmaya devam ederdi.
	EventBus.tab_changed.connect(_on_tab_changed)
	for i in 4:
		var dim := ColorRect.new()
		dim.color = UiTokens.ODA_SCRIM
		dim.mouse_filter = Control.MOUSE_FILTER_STOP
		add_child(dim)
		_dims.append(dim)
	_spot = Panel.new()
	_spot.theme_type_variation = &"OdaAnchorGlow"
	_spot.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_spot)
	_card = PanelContainer.new()
	_card.theme_type_variation = &"OdaTourCard"
	add_child(_card)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", UiTokens.SPACE_M)
	_card.add_child(col)
	_name_label = UiFactory.make_label("", &"DialogueName")
	col.add_child(_name_label)
	_desc_label = UiFactory.make_label("", &"ChromeSerif")
	_desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_desc_label.custom_minimum_size = Vector2(280, 0)
	col.add_child(_desc_label)
	var btn_row := HBoxContainer.new()
	btn_row.add_theme_constant_override("separation", UiTokens.SPACE_M)
	col.add_child(btn_row)
	var skip_btn := Button.new()
	skip_btn.theme_type_variation = &"ChromeGhost"
	skip_btn.focus_mode = Control.FOCUS_NONE
	skip_btn.text = tr("ODA_TOUR_SKIP")
	skip_btn.pressed.connect(_finish)
	btn_row.add_child(skip_btn)
	var sp := Control.new()
	sp.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn_row.add_child(sp)
	_next_btn = Button.new()
	_next_btn.theme_type_variation = &"ChromeButton"
	_next_btn.focus_mode = Control.FOCUS_NONE
	_next_btn.pressed.connect(_advance)
	btn_row.add_child(_next_btn)
	# Tam-ekran rect'i CanvasLayer altında ilk düzen geçişinden SONRA oturur; dim'ler
	# `size`'dan ölçüldüğü için yerleşim her boyut değişiminde yeniden yapılır.
	resized.connect(_apply_step)
	# Metinler tr() ile çözülmüş yazılır; dil değişince açık adım yeniden boyanır.
	EventBus.language_changed.connect(_apply_step_on_language)
	_apply_step()


func _apply_step_on_language(_locale: String) -> void:
	_apply_step()


func _advance() -> void:
	_step += 1
	if _step >= STEPS.size():
		_finish()
		return
	_apply_step()


func _on_tab_changed(_tab_id: String) -> void:
	_finish()


func _finish() -> void:
	Settings.set_value("oda_intro_seen", true)
	if EventBus.tab_changed.is_connected(_on_tab_changed):
		EventBus.tab_changed.disconnect(_on_tab_changed)
	if EventBus.language_changed.is_connected(_apply_step_on_language):
		EventBus.language_changed.disconnect(_apply_step_on_language)
	EventBus.speed_change_requested.emit(_pre_tour_speed)
	queue_free()


func _input(event: InputEvent) -> void:
	# Esc = GEÇ; Space/1-3 tur boyunca yutulur (kazara hız değişikliği saati başlatmasın).
	if not (event is InputEventKey) or not event.pressed or event.echo:
		return
	var key: InputEventKey = event
	match key.keycode:
		KEY_ESCAPE:
			get_viewport().set_input_as_handled()
			_finish()
		KEY_SPACE, KEY_1, KEY_2, KEY_3, KEY_KP_1, KEY_KP_2, KEY_KP_3:
			get_viewport().set_input_as_handled()


func _apply_step() -> void:
	if _step >= STEPS.size():
		return
	var view: Vector2 = size
	if view.x < 2.0 or view.y < 2.0:
		return
	var step: Dictionary = STEPS[_step]
	# Çapalar turun tam-ekran rect'ine değil ODA'nın rect'ine göre ölçülür.
	var stage: Rect2 = _stage_node.get_global_rect() if _stage_node != null else Rect2(Vector2.ZERO, view)
	if stage.size.x < 2.0 or stage.size.y < 2.0:
		stage = Rect2(Vector2.ZERO, view)
	var r: Rect2 = OdaLayout.place(OdaLayout.RECTS[String(step["rect"])], stage.size).grow(6.0)
	r.position += stage.position
	# Dört dim: üst / alt / sol / sağ — spotlight boş kalır.
	_dims[0].position = Vector2.ZERO
	_dims[0].size = Vector2(view.x, maxf(0.0, r.position.y))
	_dims[1].position = Vector2(0.0, r.end.y)
	_dims[1].size = Vector2(view.x, maxf(0.0, view.y - r.end.y))
	_dims[2].position = Vector2(0.0, r.position.y)
	_dims[2].size = Vector2(maxf(0.0, r.position.x), r.size.y)
	_dims[3].position = Vector2(r.end.x, r.position.y)
	_dims[3].size = Vector2(maxf(0.0, view.x - r.end.x), r.size.y)
	_spot.position = r.position
	_spot.size = r.size
	_name_label.text = tr(String(step["name"]))
	_desc_label.text = tr(String(step["desc"]))
	_next_btn.text = tr("ODA_TOUR_DONE") if _step == STEPS.size() - 1 else tr("ODA_TOUR_NEXT")
	# Kart: spotlight'ın altına, sığmazsa üstüne; yatayda merkezli + kelepçeli.
	await get_tree().process_frame  # kart boyutu metinden sonra otursun
	var cw: float = _card.size.x
	var ch: float = _card.size.y
	var cx: float = clampf(r.position.x + r.size.x * 0.5 - cw * 0.5, 16.0, view.x - cw - 16.0)
	var cy: float = r.end.y + 16.0
	if cy + ch > view.y - 16.0:
		cy = maxf(16.0, r.position.y - ch - 16.0)
	_card.position = Vector2(cx, cy)
