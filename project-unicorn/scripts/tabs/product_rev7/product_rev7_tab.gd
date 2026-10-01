extends Control

# Ürün sekmesinin sprint ekranı (bayrak arkasında): başlık satırı, SPRINT görünümü (alanlar ·
# bu sprint · sonraki) ve ÇEYREK görünümü. Her değişiklikte kaynağın modelinden baştan kurulur;
# kaynak yoksa canlı model. Akordeon, ses katlaması, geçmiş ve görünüm sekmenin yerel durumudur:
# modelin `ui`'sinden tohumlanır, tek sahibi `_ui`'dir; kaynağa yalnız "voices_seen" gider.

signal action_requested(kind: String, args: Dictionary)
signal close_requested

## Sürüm notu ekrandayken saat durur: oyuncu notu okumadan sonraki sprint işlemesin.
const HOLD_RELEASE_NOTE := "product_release_note"
const VIEW_KEYS := {"sprint": "PRODUCT_VIEW_SPRINT", "quarter": "PRODUCT_VIEW_QUARTER"}
const QUARTER_LOCK_TIPS := {"locked_no_pm": "PRODUCT_QUARTER_NEED_PM", "coming_soon": "PRODUCT_SOON"}

## WindowFrame'e: pencere zemini, iç boşluk ve × başlık satırında (sağ şerit üç panele kalır).
var frame_options := {"variation": &"FolderWindow", "pad": UiTokens.PRODUCT_WINDOW_PAD, "owns_close": true}

var _source: Object = null
var _ui: Dictionary = {}
var _held_speed := -1   # saati tutarken saklanan hız; -1 = bu sekme saati tutmuyor
var _closing := false   # pencere kapanıyor: ertelenmiş kurulum ölmekte olan sayfada saati yeniden tutmasın
var _rebuild_queued := false
var _head: HBoxContainer
var _sprint_view: HBoxContainer
var _areas: AreaPanel
var _sprint: SprintPanel
var _quarter: QuarterView


func _ready() -> void:
	var col := VBoxContainer.new()
	col.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	col.add_theme_constant_override(&"separation", UiTokens.SPACE_L)
	add_child(col)
	_head = HBoxContainer.new()
	_head.add_theme_constant_override(&"separation", UiTokens.SPACE_L)
	col.add_child(_head)

	_sprint_view = HBoxContainer.new()
	_sprint_view.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_sprint_view.add_theme_constant_override(&"separation", UiTokens.PRODUCT_PANEL_GAP)
	col.add_child(_sprint_view)
	var scroll := ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_stretch_ratio = UiTokens.PRODUCT_PANEL_RATIOS[0]
	_sprint_view.add_child(scroll)
	_areas = AreaPanel.new()
	_areas.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_areas.action.connect(_on_action)
	_areas.ui_changed.connect(_on_ui_changed)
	scroll.add_child(_areas)
	_sprint = SprintPanel.new()
	_sprint.action.connect(_on_action)
	_sprint_view.add_child(_sprint)

	_quarter = QuarterView.new()
	_quarter.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_quarter.action.connect(_on_action)
	col.add_child(_quarter)
	_rebuild()


## src: model() -> Dictionary ve act(kind, args). Aynı kaynakla yeniden çağrılınca da yerel
## durum yeni modelden tohumlanır.
func set_source(src: Object) -> void:
	_source = src
	_ui = {}
	if is_node_ready():
		_rebuild()


## Hızı bir sonraki ekranın sahibi geri verir: başka bir yüzeyin duraklatmasının altında saat
## yürümesin.
func on_page_closing() -> void:
	_closing = true
	TimeManager.release_clock(HOLD_RELEASE_NOTE)
	_held_speed = -1


func _rebuild() -> void:
	_rebuild_queued = false
	if _closing:
		return
	var m: Dictionary = _source.model() if _source != null else ProductModel.live()
	if _ui.is_empty():
		_ui = m.ui.duplicate()
	m.ui = _ui
	var view: String = _ui.view if m.quarter.state == "open" else "sprint"
	_build_head(m, view)
	_sprint_view.visible = view == "sprint"
	_quarter.visible = view == "quarter"
	if view == "quarter":
		_quarter.setup(m)
	else:
		_areas.setup(m, false)
		_sprint.setup(m)
	_hold_clock(m.center.mode == "release")


## Ad · CANLI sürüm (ya da MVP) · pazar ve tür ... Geçmiş anahtarı · SPRINT | ÇEYREK · ×.
func _build_head(m: Dictionary, view: String) -> void:
	UiFactory.clear(_head)
	var h: Dictionary = m.header
	_head.add_child(UiFactory.make_label(h.name, &"TitleSerif"))
	if h.live_version != "":
		_head.add_child(SprintUiShared.semantic_chip(
			tr("PROD_LIVE_VERSION_LC").format({"version": h.live_version}), &"positive"))
	else:
		_head.add_child(SprintUiShared.stamp(tr("PRODUCT_MVP_NOT_LIVE"), &"Stamp"))
	if h.market != "":   # ürün kurulmadan pazar ve tür boş gelir
		_head.add_child(SprintUiShared.stamp(h.market + SprintUiShared.SEP + h.type_text, &"TabLabel"))
	_head.add_child(RnDUiShared.spacer())

	_head.add_child(SprintUiShared.stamp(tr("PRODUCT_HISTORY"), &"RowMeta"))
	var history := CheckButton.new()
	history.theme_type_variation = &"SettingsSwitch"
	history.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	history.focus_mode = Control.FOCUS_NONE   # boşluk tuşu hız tuşudur; odak onu yutmasın
	history.button_pressed = _ui.history_open
	history.toggled.connect(_set_ui.bind("history_open"))
	_head.add_child(history)

	var lock_tip: String = QUARTER_LOCK_TIPS.get(m.quarter.state, "")
	var views: Array = ["sprint"] if lock_tip != "" else VIEW_KEYS.keys()
	var dial := SprintUiShared.dial(views.map(func(id: String) -> String: return tr(VIEW_KEYS[id])), views.find(view),
		func(i: int) -> void: _set_ui(views[i], "view"))
	if lock_tip != "":
		dial.add_child(_locked_segment(tr(lock_tip)))
	_head.add_child(dial)
	_head.add_child(UiFactory.make_close_button(close_requested.emit))


## Kapalı ÇEYREK: pasif düğme ipucunu taşır, kilit ve yazı onun üstünde durur (tema düğmenin
## ikonunu boyamaz, beyaz kilit krem zeminde kaybolurdu).
func _locked_segment(tip: String) -> MarginContainer:
	var seg := MarginContainer.new()
	var frame := Button.new()
	frame.theme_type_variation = &"StanceDial"
	frame.disabled = true
	frame.focus_mode = Control.FOCUS_NONE
	frame.tooltip_text = tip
	seg.add_child(frame)
	var pad := MarginContainer.new()
	pad.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pad.add_theme_constant_override(&"margin_left", UiTokens.PAD_DIAL.x)
	pad.add_theme_constant_override(&"margin_right", UiTokens.PAD_DIAL.x)
	pad.add_theme_constant_override(&"margin_top", UiTokens.PAD_DIAL.y)
	pad.add_theme_constant_override(&"margin_bottom", UiTokens.PAD_DIAL.y)
	seg.add_child(pad)
	var row := HBoxContainer.new()
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_theme_constant_override(&"separation", UiTokens.SPACE_XS)
	row.add_child(HRUiShared.lock_glyph(UiTokens.PRODUCT_ICON_PX, UiTokens.INK_DIM))
	row.add_child(UiFactory.make_label(tr("PRODUCT_VIEW_QUARTER"), &"TabLabel"))
	pad.add_child(row)
	return seg


## Yalnız yerel durum: geçmiş anahtarı ve görünüm.
func _set_ui(value: Variant, key: String) -> void:
	_ui[key] = value
	_queue_rebuild()


func _on_ui_changed(open_area: String, voices_open: bool) -> void:
	_ui.open_area = open_area
	_ui.voices_open = voices_open
	_queue_rebuild()


func _on_action(kind: String, args: Dictionary) -> void:
	_ui.hover_card = ""   # kare için zorlanan hover ilk eylemde bırakılır
	if kind == "edit":
		_ui.view = "sprint"
	action_requested.emit(kind, args)
	if _source != null:
		_source.act(kind, args)
	_queue_rebuild()


## Değişiklik bir düğmenin ya da satırın kendi girdisinden geliyor: ağaç girdi bittikten sonra,
## aynı karede gelen eylem ve durum değişikliği için bir kez kurulur.
func _queue_rebuild() -> void:
	if not _rebuild_queued:
		_rebuild_queued = true
		_rebuild.call_deferred()


## Hız saklanırken saat duruksa son yürüyen hız alınır: başka bir yüzeyin duraklatması oyuncunun
## hızını sıfırlamasın.
func _hold_clock(on: bool) -> void:
	if on == (_held_speed >= 0):
		return
	if on:
		_held_speed = TimeManager.current_speed if TimeManager.current_speed > 0 else TimeManager.last_running_speed
		TimeManager.hold_clock(HOLD_RELEASE_NOTE)
		return
	TimeManager.release_clock(HOLD_RELEASE_NOTE)
	# Bekleyen olay saati kendisi bırakır.
	if not EventGate.has_pending():
		EventBus.speed_change_requested.emit(_held_speed)
	_held_speed = -1
