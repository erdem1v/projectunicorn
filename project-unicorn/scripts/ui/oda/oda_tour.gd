extends Control

# ODA ilk-açılış turu (ODA rework §8): altı çapayı sırayla spotlight'lar,
# adlandırır, tek cümle açıklar. YALNIZ İLK RUN'DA — bayrak user://settings.json
# (Settings autoload, run'lardan bağımsız). GEÇ / son adımda BAŞLA / Esc — her
# çıkış yolu bayrağı yazar; tur bir daha asla görünmez.
#
# Mount: PanelLayer — ModalLayer DEĞİL (oraya girse game_shell Guard 2 Space/1-4'ü
# öldürür ve gerçek modallarla katman karışır), ama OdaView'un ÇOCUĞU da değil.
# Çocuğuyken dim rect'leri yalnız CenterViewport'u kaplıyordu: TopBar ve sol ray
# turun altında CANLI kalıyor, ilk kez oynayan biri kendisine oda tanıtılırken hız
# düğmesine basıp saati başlatabiliyordu. Artık tam ekran; çapa geometrisi ise hâlâ
# OdaView'un dikdörtgenine göre hesaplanıyor (bkz. _stage_node) — oda resmi ekranın
# yalnız orta bölgesinde duruyor, spotlight oraya nişan almak zorunda.
# Dim = spotlight rect'in etrafını çerçeveleyen DÖRT ColorRect (shader'sız delik deseni).
# Pause altında çalışır (GameShell PROCESS_MODE_ALWAYS mirası) — ve turu açan taraf
# saati DURDURUR: tur bir an, oynanış değil.

const OdaLayoutRef := preload("res://scripts/ui/oda/oda_layout.gd")

const STEPS := [
	{"rect": "monitor", "name": "ODA_ANCHOR_MONITOR", "desc": "ODA_TOUR_MONITOR_DESC"},
	{"rect": "phone", "name": "ODA_ANCHOR_PHONE", "desc": "ODA_TOUR_PHONE_DESC"},
	{"rect": "papers_zone", "name": "ODA_ANCHOR_PAPERS", "desc": "ODA_TOUR_PAPERS_DESC"},
	{"rect": "board_outer", "name": "ODA_ANCHOR_BOARD", "desc": "ODA_TOUR_BOARD_DESC"},
	{"rect": "frames_band", "name": "ODA_ANCHOR_FRAMES", "desc": "ODA_TOUR_FRAMES_DESC"},
	{"rect": "window", "name": "ODA_ANCHOR_WINDOW", "desc": "ODA_TOUR_WINDOW_DESC"},
]

var _step: int = 0
# Çapa geometrisinin ölçüldüğü dikdörtgen — OdaView'un kendisi. Her adımda yeniden
# okunuyor ki pencere yeniden boyutlandığında spotlight kaymasın.
var _stage_node: Control = null
# Tur başlamadan önceki hız; kapanışta aynen geri verilir (modallerin disiplini).
var _pre_tour_speed: int = -1
var _dims: Array[ColorRect] = []
var _spot: Panel
var _card: PanelContainer
var _name_label: Label
var _desc_label: Label
var _next_btn: Button


func set_stage(node: Control) -> void:
	_stage_node = node


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP  # arkaya tıklama sızmasın
	# Saat durur. Oyuncuya odası tanıtılırken gün ilerlemesi, para yanması, event
	# kuyruğunun dolması için bir sebep yok.
	_pre_tour_speed = TimeManager.current_speed
	EventBus.speed_change_requested.emit(0)
	# Sekmeye geçiş turu BİTİRİR. Eskiden tur OdaView'un çocuğuydu ve sekme açılınca
	# yalnız GİZLENİYORDU: görünmez tur oturum boyunca Space/1-4/Esc yutmaya devam
	# ediyor (oyuncunun ilk Esc'i "hiçbir şey yapmıyor" gibi görünüyordu — sessizce turu
	# bitiriyordu), odaya dönülünce de tur run'ın ortasında eski adımından yeniden
	# beliriyordu. Artık ayrı katmanda olduğu için gizlenme diye bir şey yok; navigasyon
	# bir çıkış yoludur ve her çıkış yolu bayrağı yazar.
	EventBus.tab_changed.connect(_on_tab_changed)
	# Tam-ekran rect'i CanvasLayer altında ilk düzen geçişinden SONRA oturur; dim'ler
	# `size`'dan ölçüldüğü için ilk yerleşim boyut gelmeden yapılırsa karartma eksik
	# kalır. Yeniden boyutlanmada da aynı yol.
	resized.connect(_apply_step)
	for i in 4:
		var dim := ColorRect.new()
		dim.color = UiTokens.SCRIM_MODAL
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
	resized.connect(_apply_step)
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
	# HER çıkış yolu bayrağı yazar — tur bir daha görünmez (task §8: asla tekrar).
	Settings.set_value("oda_intro_seen", true)
	if EventBus.tab_changed.is_connected(_on_tab_changed):
		EventBus.tab_changed.disconnect(_on_tab_changed)
	# Saati turun bulduğu yere bırak. Tur MentorIntro'nun hemen ardından açıldığı için
	# bu pratikte 0'dır; yine de varsayım değil ölçüm.
	if _pre_tour_speed >= 0:
		EventBus.speed_change_requested.emit(_pre_tour_speed)
	queue_free()


func _input(event: InputEvent) -> void:
	# Tur açıkken Esc = GEÇ; Space/1-4 tur boyunca yutulur (oyun zaten MentorIntro
	# sonrası pauselu — kazara hız değişikliği turu bölmesin).
	if not (event is InputEventKey) or not event.pressed or event.echo:
		return
	var key: InputEventKey = event
	match key.keycode:
		KEY_ESCAPE:
			get_viewport().set_input_as_handled()
			_finish()
		KEY_SPACE, KEY_1, KEY_2, KEY_3, KEY_4, KEY_KP_1, KEY_KP_2, KEY_KP_3, KEY_KP_4:
			get_viewport().set_input_as_handled()


func _apply_step() -> void:
	if _step >= STEPS.size():
		return
	var view: Vector2 = size
	if view.x < 2.0 or view.y < 2.0:
		return
	var step: Dictionary = STEPS[_step]
	# Çapalar ODA'nın dikdörtgenine göre ölçülür, turun kendi tam-ekran rect'ine göre
	# değil: oda resmi ekranın orta bölgesinde duruyor, TopBar ve ray onun dışında.
	# Ölçüyü tam ekrandan almak spotlight'ı mobilyanın olmadığı yere nişanlardı.
	var stage: Rect2 = _stage_node.get_global_rect() if _stage_node != null else Rect2(Vector2.ZERO, view)
	if stage.size.x < 2.0 or stage.size.y < 2.0:
		stage = Rect2(Vector2.ZERO, view)
	var r: Rect2 = OdaLayoutRef.place(OdaLayoutRef.RECTS[String(step["rect"])], stage.size).grow(6.0)
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
