extends Control

# Ürün penceresi. Ortak koyu başlıkta Ürün ve iki ölçü (tür ile ürün adı, sürüm); altında denetim şeridi
# (GENEL BAKIŞ | SPRINT | ÇEYREK; Genel Bakış v1.0'a, ÇEYREK PM'e kadar gerekçesiyle kilitli; Geçmiş ve devir
# anahtarı), gövdede GENEL BAKIŞ (sunucu), SPRINT görünümü (alanlar · bu sprint · sonraki) ya da ÇEYREK görünümü.
# Her değişiklikte kaynağın modelinden baştan kurulur; kaynak yoksa canlı model ve eylemler sistemlere gider, ürün
# türü seçilmemişse şerit yoktur ve ortada tür seçici durur. Akordeon, geçmiş ve görünüm sekmenin yerel durumudur:
# modelin `ui`'sinden tohumlanır, tek sahibi `_ui`'dir; Destek kartı alanı `open_area` ile açar. Son açık kâğıt
# pencere kapanıp açılınca (ve dil değişince) hatırlanır, kayda yazılmaz.

## ÇEYREK'te pencere içeriği kadar uzar (WindowLayer fit_height okur).
signal fit_changed

const INBOX := preload("res://scripts/ui/components/inbox.gd")
## Sürüm notu ekrandayken saat durur: oyuncu notu okumadan sonraki sprint işlemesin.
const HOLD_RELEASE_NOTE := "product_release_note"
const VIEW_KEYS := {"overview": "PRODUCT_OV_TAB_OVERVIEW", "sprint": "PRODUCT_VIEW_SPRINT", "quarter": "PRODUCT_VIEW_QUARTER"}
const OVERVIEW := preload("res://scripts/tabs/product/overview_view.gd")
const BODY_PAD := Vector4i(UiTokens.SPACE_3XL, UiTokens.SPACE_XL, UiTokens.SPACE_3XL, UiTokens.SPACE_3XL)

## Son açık kâğıt: sekme her açılışta yeniden kurulduğu için sürece bağlı durur.
static var _last_view := "sprint"

var frame_options: Dictionary
var _source: Object = null
var _ui: Dictionary = {}
var _closing := false   # pencere kapanıyor: ertelenmiş kurulum ölmekte olan sayfada saati yeniden tutmasın
var _rebuild_queued := false
var _reveal_open := false   # Destek kartı alanı açtı: kurulunca alanın başı sütunun başına gelsin
var _kpis: HBoxContainer
var _ctl: PanelContainer
var _ctl_row: HBoxContainer
var _sprint_view: HBoxContainer
var _overview_view: ScrollContainer
var _overview: OVERVIEW
var _areas_scroll: ScrollContainer
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
	_areas_scroll = scroll
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
	_overview_view = ScrollContainer.new()
	_overview_view.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_overview = OVERVIEW.new()
	_overview.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_overview.action.connect(_on_action)
	_overview_view.add_child(_overview)

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
	# Tür seçilince liderin planı hazırdır: ilk sprint tek tıkla başlar.
	picker.chosen.connect(func(subtype: String, product_name: String) -> void:
		SprintSystem.choose_type(subtype, product_name)
		SprintSystem.apply_lead())
	frame.add_child(SprintUiShared.pad(picker, Vector4i.ONE * UiTokens.SPACE_3XL))
	picker.setup()
	for view: Control in [_overview_view, _sprint_view, _quarter, _picker_view]:
		body.add_child(SprintUiShared.pad(view, BODY_PAD))
		view.get_parent().set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	# Canlı modelin durumu sistemlerde değişir: sprint eylemi, sürüm, açık hata, gün geçişi ve masadaki kâğıtlar yeniden çizer.
	EventBus.product_state_changed.connect(_queue_rebuild)
	EventBus.build_progress_changed.connect(_queue_rebuild)
	EventBus.day_advanced.connect(_queue_rebuild.unbind(1))
	EventBus.desk_changed.connect(_queue_rebuild)
	EventBus.infra_changed.connect(_queue_rebuild)
	_rebuild()


## src: model() -> Dictionary ve act(kind, args). Aynı kaynakla yeniden çağrılınca da yerel
## durum yeni modelden tohumlanır.
func set_source(src: Object) -> void:
	_source = src
	_ui = {}
	if is_node_ready():
		_rebuild()


## Kapanan sayfa sürüm notunun tutuşunu bırakır; saati oyuncu başlatır.
func on_page_closing() -> void:
	_closing = true
	TimeManager.release_clock(HOLD_RELEASE_NOTE)


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
		if _source == null:
			_ui.view = _last_view
	m.ui = _ui
	# Sürüm notu yalnız SPRINT görünümünde durur ve saat onun için tutulur: notta görünüm SPRINT'tir. Açık olmayan
	# kâğıt da SPRINT'e düşer; v1.0'dan önce hatırlanan GENEL BAKIŞ (önceki koşudan kalan) unutulur, yoksa yayında
	# kendiliğinden öne çıkardı.
	var view: String = _ui.view
	if view == "overview" and m.get("overview") == null:
		view = "sprint"
		_ui.view = view
		_last_view = view
	if m.center.mode == "release" or (view == "quarter" and m.quarter.state != "open"):
		view = "sprint"
	var picking: bool = _source == null and not SprintSystem.is_typed()
	_build_head(m.header)
	_build_ctl(m, view)
	_ctl.visible = not picking
	_picker_view.get_parent().visible = picking
	_overview_view.get_parent().visible = view == "overview" and not picking
	_sprint_view.get_parent().visible = view == "sprint" and not picking
	_quarter.get_parent().visible = view == "quarter" and not picking
	_quarter.visible = _quarter.get_parent().visible
	if _quarter.visible:
		_quarter.setup(m)
	elif _overview_view.get_parent().visible:
		_overview.setup(m)
	elif _sprint_view.get_parent().visible:
		_areas.setup(m, false)
		_sprint.setup(m)
		if _reveal_open:
			_reveal_open = false
			get_tree().process_frame.connect(_scroll_to_open_area, CONNECT_ONE_SHOT)
	_hold_clock(m.center.mode == "release")
	# Wrapped text settles in the frame after a rebuild; the window reads the quarter's height then.
	if not get_tree().process_frame.is_connected(_refit):
		get_tree().process_frame.connect(_refit, CONNECT_ONE_SHOT)


func _refit() -> void:
	fit_changed.emit()


## Üstteki Müşteriler listesi sütunu uzatabilir: açılan alan yerleştikten sonra, sütunun alt yarısında başlıyorsa sütunun
## başına gelir.
func _scroll_to_open_area() -> void:
	var offset: int = _areas.open_offset()
	if offset > _areas_scroll.size.y / 2.0:
		_areas_scroll.scroll_vertical = offset


## Başlığın ölçüleri, ürün kurulunca: tür anahtarıyla ürün adı ve sürüm (MVP öncesi yazıyla); canlı B2C'de
## kullanıcı ve ödeyen.
func _build_head(h: Dictionary) -> void:
	UiFactory.clear(_kpis)
	if h.market == "":   # ürün kurulmadan pazar ve tür boş gelir
		return
	_kpis.add_child(UiFactory.D_kpi(h.market + SprintUiShared.SEP + h.type_text, h.name))
	var version := UiFactory.D_kpi(tr("PRODUCT_VERSION_KEY"),
		tr("PROD_VERSION_SHORT").format({"version": h.live_version}) if h.live_version != "" else tr("PRODUCT_MVP_NOT_LIVE"))
	if h.live_version == "":
		var value := UiFactory.D_kpi_value(version)
		value.theme_type_variation = &"ValueText"
		value.add_theme_color_override("font_color", UiTokens.D_INK_3)
	_kpis.add_child(version)
	if h.users >= 0:
		_kpis.add_child(UiFactory.D_kpi(tr("PRODUCT_KPI_USERS"), Fmt.group(h.users)))
		_kpis.add_child(UiFactory.D_kpi(tr("PRODUCT_KPI_PAYING"), Fmt.group(h.paying)))


## GENEL BAKIŞ | SPRINT | ÇEYREK (v1.0'dan önce GENEL BAKIŞ, PM yokken ÇEYREK kilitli, gerekçesi ipucunda) ...
## Geçmiş anahtarı; PM varken planlamayı ona devretme anahtarı.
func _build_ctl(m: Dictionary, view: String) -> void:
	UiFactory.clear(_ctl_row)
	var open_views: Array = VIEW_KEYS.keys().filter(func(id: String) -> bool:
		return (id != "overview" or m.get("overview") != null) and (id != "quarter" or m.quarter.state == "open"))
	if "overview" not in open_views:
		var overview := UiFactory.D_locked_tab(tr(VIEW_KEYS.overview))
		overview.tooltip_text = tr("PRODUCT_OV_LOCKED")
		_ctl_row.add_child(overview)
	_ctl_row.add_child(UiFactory.D_seg_tabs(open_views.map(func(id: String) -> String: return tr(VIEW_KEYS[id])),
		open_views.find(view), func(i: int) -> void: _set_ui(open_views[i], "view")))
	if "quarter" not in open_views:
		var quarter := UiFactory.D_locked_tab(tr(VIEW_KEYS.quarter))
		quarter.tooltip_text = tr("PRODUCT_QUARTER_NEED_PM")
		_ctl_row.add_child(quarter)
	_ctl_row.add_child(RnDUiShared.spacer())
	SprintUiShared.switch(_ctl_row, tr("PRODUCT_HISTORY"), _ui.history_open, _set_ui.bind("history_open"))
	var delegate: Variant = m.center.delegate
	if delegate != null:
		SprintUiShared.switch(_ctl_row, tr("PRODUCT_DELEGATE").format(delegate), delegate.on,
			func(on: bool) -> void: _on_action("delegate", {"on": on}))


## Yalnız yerel durum: geçmiş anahtarı, görünüm ve açık kademe önizlemesi.
func _set_ui(value: Variant, key: String) -> void:
	_ui[key] = value
	if key == "view":
		_last_view = value
	_queue_rebuild()


## SPRINT görünümünde bu alan açık: Destek kartı en çok açık hatası olan hattın alanına götürür.
func open_area(area_id: String) -> void:
	_set_ui("sprint", "view")
	_reveal_open = true
	_on_ui_changed(area_id)


func _on_ui_changed(open_area_id: String) -> void:
	_ui.open_area = open_area_id
	_queue_rebuild()


func _on_action(kind: String, args: Dictionary) -> void:
	_ui.hover_card = ""   # kare için zorlanan hover ilk eylemde bırakılır
	if kind == "server_preview":
		_set_ui(args.id, "server_preview")
		return
	if kind == "edit":
		_set_ui("sprint", "view")
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
		"skip": SprintSystem.skip()
		"delegate": SprintSystem.set_delegate(args.on)
		"plan_next": SprintSystem.plan_next()
		"publish": SprintSystem.publish()
		"apply_lead": SprintSystem.apply_lead()
		"decide": INBOX.show(args.item)
		"approve": SprintSystem.approve(args.sprint)
		"approve_all": SprintSystem.approve_all()
		"edit": SprintSystem.edit(args.sprint)
		"pick_goal": SprintSystem.pick_goal(args.area_id)
		"server_tier":
			InfraSystem.set_provider(args.id)
			_ui.server_preview = ""
		"server_step": InfraSystem.adjust_capacity(args.direction)
		"server_auto": ProductState.set_infra_auto(args.on)
		"team": EventBus.tab_changed.emit("hr")
		"rnd":
			# Önce sayfa: düğüm isteği monte olmuş Ar-Ge sayfasına düşer.
			EventBus.tab_changed.emit("rnd")
			EventBus.rnd_node_requested.emit(args.node, false)
		"hire":
			EventBus.tab_changed.emit("hr")
			get_tree().get_first_node_in_group(&"window_layer").get_current_page_body().open_atlas()


## Değişiklik bir düğmenin ya da satırın kendi girdisinden geliyor: ağaç girdi bittikten sonra,
## aynı karede gelen eylem ve durum değişikliği için bir kez kurulur.
func _queue_rebuild() -> void:
	if not _rebuild_queued:
		_rebuild_queued = true
		_rebuild.call_deferred()


## Sürüm notu açıkken saat tutulur. Her kurulumda yeniden tutmak sessizdir; bırakmak saati başlatmaz.
func _hold_clock(on: bool) -> void:
	if on:
		TimeManager.hold_clock(HOLD_RELEASE_NOTE)
	else:
		TimeManager.release_clock(HOLD_RELEASE_NOTE)
