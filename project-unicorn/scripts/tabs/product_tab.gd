extends Control

# Ürün penceresi, sprint ekranı. Ortak koyu başlıkta Ürün ve iki ölçü (tür ile ürün adı, sürüm); altında
# denetim şeridi (SPRİNT | ÇEYREK, PM yokken gerekçesiyle kilitli, ve Geçmiş anahtarı), gövdede SPRİNT
# görünümü (alanlar · bu sprint · sonraki) ya da ÇEYREK görünümü. Her değişiklikte kaynağın modelinden
# baştan kurulur; kaynak yoksa canlı model ve eylemler SprintSystem'e gider, ürün türü seçilmemişse
# şerit yoktur ve ortada tür seçici durur. Akordeon, ses katlaması, geçmiş ve görünüm sekmenin yerel
# durumudur: modelin `ui`'sinden tohumlanır, tek sahibi `_ui`'dir; kaynağa yalnız "voices_seen" gider.

## ÇEYREK'te pencere içeriği kadar uzar (WindowLayer fit_height okur).
signal fit_changed

const INBOX := preload("res://scripts/ui/components/inbox.gd")
## Sürüm notu ekrandayken saat durur: oyuncu notu okumadan sonraki sprint işlemesin.
const HOLD_RELEASE_NOTE := "product_release_note"
const VIEW_KEYS := {"sprint": "PRODUCT_VIEW_SPRINT", "quarter": "PRODUCT_VIEW_QUARTER"}
const BODY_PAD := Vector4i(UiTokens.SPACE_3XL, UiTokens.SPACE_XL, UiTokens.SPACE_3XL, UiTokens.SPACE_3XL)

var frame_options: Dictionary
var _source: Object = null
var _ui: Dictionary = {}
var _held_speed := -1   # saati tutarken saklanan hız; -1 = bu sekme saati tutmuyor
var _closing := false   # pencere kapanıyor: ertelenmiş kurulum ölmekte olan sayfada saati yeniden tutmasın
var _rebuild_queued := false
var _kpis: HBoxContainer
var _ctl: PanelContainer
var _ctl_row: HBoxContainer
var _sprint_view: HBoxContainer
var _areas: AreaPanel
var _sprint: SprintPanel
var _quarter: QuarterView
var _picker_view: ScrollContainer


func _init() -> void:
	_kpis = HBoxContainer.new()
	_kpis.add_theme_constant_override("separation", 0)
	frame_options = {"title": "TAB_PRODUCT", "kpi": _kpis, "pad": Vector2i.ZERO}


func _ready() -> void:
	var col := SprintUiShared.column(0)
	col.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(col)
	_ctl = PanelContainer.new()
	_ctl.theme_type_variation = &"WinCtl"
	_ctl.custom_minimum_size.y = UiTokens.D_H_WIN_CTL
	_ctl_row = SprintUiShared.box(UiTokens.SPACE_L)
	_ctl.add_child(_ctl_row)
	col.add_child(_ctl)

	var body := Control.new()
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	col.add_child(body)
	_sprint_view = SprintUiShared.box(UiTokens.SPACE_XL)
	var scroll := ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.custom_minimum_size.x = UiTokens.D_W_AREAS
	_sprint_view.add_child(scroll)
	_areas = AreaPanel.new()
	_areas.action.connect(_on_action)
	_areas.ui_changed.connect(_on_ui_changed)
	# The areas end this far inside the column: the scrollbar's lane.
	var lane := SprintUiShared.pad(_areas, Vector4i(0, 0, UiTokens.SPACE_L, 0))
	lane.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(lane)
	_sprint = SprintPanel.new()
	_sprint.action.connect(_on_action)
	_sprint_view.add_child(_sprint)
	_quarter = QuarterView.new()
	_quarter.action.connect(_on_action)

	# Tür seçici ortada, içeriği kadar uzun; pencere kısaysa gövde kayar.
	_picker_view = ScrollContainer.new()
	_picker_view.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	var center := CenterContainer.new()
	center.use_top_left = false
	center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_picker_view.add_child(center)
	var frame := PanelContainer.new()
	frame.theme_type_variation = &"SprintColumn"
	frame.custom_minimum_size.x = UiTokens.D_W_PICKER
	center.add_child(frame)
	var picker := TypePicker.new()
	picker.chosen.connect(func(subtype: String, product_name: String) -> void:
		SprintSystem.choose_type(subtype, product_name))
	frame.add_child(SprintUiShared.pad(picker, Vector4i.ONE * UiTokens.SPACE_3XL))
	picker.setup()
	for view: Control in [_sprint_view, _quarter, _picker_view]:
		body.add_child(SprintUiShared.pad(view, BODY_PAD))
		view.get_parent().set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	# Canlı modelin durumu sistemlerde değişir: sprint eylemi, sürüm, gün geçişi ve masadaki kâğıtlar yeniden çizer.
	EventBus.product_state_changed.connect(_queue_rebuild)
	EventBus.day_advanced.connect(_queue_rebuild.unbind(1))
	EventBus.desk_changed.connect(_queue_rebuild)
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


## ÇEYREK'te pencere içeriği kadar uzar; öbür görünümler pencerenin boyunu doldurur.
func fit_height() -> float:
	if not _quarter.visible:
		return INF
	return _ctl.get_combined_minimum_size().y + BODY_PAD.y + BODY_PAD.w + _quarter.content_height()


func _rebuild() -> void:
	_rebuild_queued = false
	if _closing:
		return
	var m: Dictionary = _source.model() if _source != null else ProductModel.live()
	if _ui.is_empty():
		_ui = m.ui.duplicate()
	m.ui = _ui
	# Sürüm notu yalnız SPRİNT görünümünde durur ve saat onun için tutulur: notta görünüm SPRİNT'tir.
	var view: String = _ui.view if m.quarter.state == "open" and m.center.mode != "release" else "sprint"
	var picking: bool = _source == null and not SprintSystem.is_typed()
	_build_head(m.header)
	_build_ctl(m, view)
	_ctl.visible = not picking
	_picker_view.get_parent().visible = picking
	_sprint_view.get_parent().visible = view == "sprint" and not picking
	_quarter.get_parent().visible = view == "quarter" and not picking
	_quarter.visible = _quarter.get_parent().visible
	if _quarter.visible:
		_quarter.setup(m)
	elif _sprint_view.get_parent().visible:
		_areas.setup(m, false)
		_sprint.setup(m)
	_hold_clock(m.center.mode == "release")
	# Wrapped text settles in the frame after a rebuild; the window reads the quarter's height then.
	if not get_tree().process_frame.is_connected(_refit):
		get_tree().process_frame.connect(_refit, CONNECT_ONE_SHOT)


func _refit() -> void:
	fit_changed.emit()


## Başlığın ölçüleri: tür anahtarıyla ürün adı (ürün kurulunca) ve sürüm; MVP öncesi sürüm yazıyla.
func _build_head(h: Dictionary) -> void:
	UiFactory.clear(_kpis)
	if h.market != "":   # ürün kurulmadan pazar ve tür boş gelir
		_kpis.add_child(UiFactory.D_kpi(h.market + SprintUiShared.SEP + h.type_text, h.name))
	var version := UiFactory.D_kpi(tr("PRODUCT_VERSION_KEY"),
		tr("PROD_VERSION_SHORT").format({"version": h.live_version}) if h.live_version != "" else tr("PRODUCT_MVP_NOT_LIVE"))
	if h.live_version == "":
		var value := UiFactory.D_kpi_value(version)
		value.theme_type_variation = &"ValueText"
		value.add_theme_color_override("font_color", UiTokens.D_INK_3)
	_kpis.add_child(version)


## SPRİNT | ÇEYREK (PM yokken ÇEYREK kilitli, gerekçesi yanında) ... Geçmiş anahtarı.
func _build_ctl(m: Dictionary, view: String) -> void:
	UiFactory.clear(_ctl_row)
	var locked: bool = m.quarter.state != "open"
	var views: Array = ["sprint"] if locked else VIEW_KEYS.keys()
	_ctl_row.add_child(UiFactory.D_seg_tabs(views.map(func(id: String) -> String: return tr(VIEW_KEYS[id])),
		views.find(view), func(i: int) -> void: _set_ui(views[i], "view")))
	if locked:
		_ctl_row.add_child(UiFactory.D_locked_tab(tr("PRODUCT_VIEW_QUARTER")))
		_ctl_row.add_child(SprintUiShared.label(tr("PRODUCT_QUARTER_NEED_PM"), &"Caption"))
	_ctl_row.add_child(RnDUiShared.spacer())
	_ctl_row.add_child(SprintUiShared.label(tr("PRODUCT_HISTORY"), &"MetaMuted"))
	var history := CheckButton.new()
	history.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	history.focus_mode = Control.FOCUS_NONE   # boşluk tuşu hız tuşudur; odak onu yutmasın
	history.button_pressed = _ui.history_open
	history.toggled.connect(_set_ui.bind("history_open"))
	_ctl_row.add_child(history)


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
	if _source != null:
		_source.act(kind, args)
	else:
		_act(kind, args)
	_queue_rebuild()


## Kaynak yokken eylem sprint motoruna gider; fikstürün eylem tablosuyla aynı türler. Karar kartta
## cevaplanmaz: Olaylar kâğıdı seçili açılır.
func _act(kind: String, args: Dictionary) -> void:
	match kind:
		"add", "pull": SprintSystem.add(args.card_id)
		"send_next": SprintSystem.send_next(args.card_id)
		"remove": SprintSystem.remove(args.card_id)
		"start": SprintSystem.start()
		"plan_next": SprintSystem.plan_next()
		"beta": SprintSystem.set_beta(args.open)
		"apply_lead": SprintSystem.apply_lead()
		"decide": INBOX.show(args.item)
		"approve": SprintSystem.approve(args.sprint)
		"approve_all": SprintSystem.approve_all()
		"edit": SprintSystem.edit(args.sprint)
		"pick_goal": SprintSystem.pick_goal(args.area_id)
		"voices_seen": SprintSystem.voices_seen(args.area)
		"team": EventBus.tab_changed.emit("hr")
		"hire":
			EventBus.tab_changed.emit("hr")
			get_tree().get_first_node_in_group(&"window_layer").get_current_page_body().open_atlas()


## Değişiklik bir düğmenin ya da satırın kendi girdisinden geliyor: ağaç girdi bittikten sonra,
## aynı karede gelen eylem ve durum değişikliği için bir kez kurulur.
func _queue_rebuild() -> void:
	if not _rebuild_queued:
		_rebuild_queued = true
		_rebuild.call_deferred()


## Hız saklanırken saat duruksa son yürüyen hız alınır: başka bir yüzeyin duraklatmasının altında saat
## yürümesin.
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
