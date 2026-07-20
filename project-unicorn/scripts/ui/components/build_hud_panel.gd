extends Control

# Build Takip Kartı (restore, 2026-07-17): sağ üstte yüzen KOMPAKT kart — Rev3'ün
# pasif şeridi + Product-tab gizlemesi Erdem tarafından reddedildi; kart geri geldi.
# Build sürerken HER sekmede görünür (Product dahil; in-tab tracker'la birlikte
# yaşar, ikisi de aynı ProductSystem API'larını okur).
#
# İçerik: header (ikon + ad + V·TİP + ✕ iptal), mini 3-faz şeridi
# (TASARIM/GELİŞTİRME/BETA), amber dolgulu faz hücresi ("%N · ~N gün"),
# Beta'da BULUNAN/ÇÖZÜLEN/KALAN satırı + "Yayınla →" butonu.
# Eksen kolonu restore EDİLMEDİ: Rev3'te eksenler commit'te sabitlenir, build
# boyunca değer oynamaz (ölü gösterge olurdu).
#
# SÜRÜKLENEBİLİR: kart CenterViewport'un çocuğu; Root parent rect'ine clamp'lenir
# → top bar / sol bar / sağ bar (ve ticker) yapısal olarak erişilemez. Konum
# oturum boyunca kalır (kart tab değişiminde ölmez); yeni run'da varsayılan sağ üst.
#
# Progress AYRI BAR DEĞİL: faz hücresinin arka planı soldan sağa dolar (Track+Fill).
# Signal-driven refresh (no _process poll): build_phase_changed +
# build_progress_changed + day_advanced. process_mode = ALWAYS.

@onready var root: Control = $Root
@onready var panel: PanelContainer = $Root/Panel
@onready var icon_rect: TextureRect = $Root/Panel/VBox/HeaderRow/Icon
@onready var name_label: Label = $Root/Panel/VBox/HeaderRow/TitleBox/NameLabel
@onready var meta_label: Label = $Root/Panel/VBox/HeaderRow/TitleBox/MetaLabel
@onready var cancel_btn: Button = $Root/Panel/VBox/HeaderRow/CancelBtn
@onready var mini_design: PanelContainer = $Root/Panel/VBox/MiniPhaseRow/MiniDesign
@onready var mini_dev: PanelContainer = $Root/Panel/VBox/MiniPhaseRow/MiniDev
@onready var mini_beta: PanelContainer = $Root/Panel/VBox/MiniPhaseRow/MiniBeta
@onready var track: Panel = $Root/Panel/VBox/BodyRow/PhaseCell/Track
@onready var fill: Panel = $Root/Panel/VBox/BodyRow/PhaseCell/Track/Fill
@onready var phase_name_label: Label = $Root/Panel/VBox/BodyRow/PhaseCell/PhaseMargin/PhaseVBox/PhaseName
@onready var phase_status_label: Label = $Root/Panel/VBox/BodyRow/PhaseCell/PhaseMargin/PhaseVBox/PhaseStatus
@onready var beta_row: HBoxContainer = $Root/Panel/VBox/BetaRow
@onready var beta_found_val: Label = $Root/Panel/VBox/BetaRow/FoundBox/Val
@onready var beta_fixed_val: Label = $Root/Panel/VBox/BetaRow/FixedBox/Val
@onready var beta_remain_val: Label = $Root/Panel/VBox/BetaRow/RemainBox/Val
@onready var action_button: Button = $Root/Panel/VBox/ActionButton

# Faz görünen adları — iç id'ler değişmedi (event/promise tüketicileri okur).
const _PHASE_DISPLAY := {"iteration": "TASARIM", "development": "GELİŞTİRME", "bugfix": "BETA"}
const _PHASE_ORDER := ["iteration", "development", "bugfix"]

# Kart boyutu (tuning): genişlik sabit; yükseklik normal fazlarda kompakt,
# Beta'da beta satırı + Yayınla butonu için uzar. Eski kart 172 sabitti.
const CARD_W := 320.0
const H_NORMAL := 140.0
const H_BETA := 190.0

# Dolgu/şerit tonları — bir kez kurulur, paint yalnız stylebox swap eder.
var _sb_track: StyleBoxFlat = null
var _sb_fill: StyleBoxFlat = null
var _sb_mini_done: StyleBoxFlat = null
var _sb_mini_active: StyleBoxFlat = null
var _sb_mini_pending: StyleBoxFlat = null

# Sürükleme durumu: ilk sürüklemede sağ-anchor'lu Root serbest konuma çevrilir;
# sonrası position + clamp. Konum node yaşadıkça (oturum) korunur.
var _dragging := false
var _drag_free := false

# Yalnız iptal yönlendirmesi için izlenir (görünürlük artık taba bağlı DEĞİL):
# Product'tayken canlı router "cancelled" emit'inde prefill'i tüketir — tab_changed
# emit edilirse remount o navigasyonu ezer. Başka sekmedeyse tab_changed şart.
var _current_tab: String = "product"   # CenterViewport default tab (UiTokens.TABS[0])


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build_styles()
	action_button.pressed.connect(_on_action_pressed)
	cancel_btn.pressed.connect(_on_cancel_pressed)
	panel.gui_input.connect(_on_panel_gui_input)
	resized.connect(_clamp_root)
	EventBus.build_phase_changed.connect(_on_build_phase_changed)
	EventBus.day_advanced.connect(func(_d: int) -> void: _refresh())
	EventBus.build_progress_changed.connect(_refresh)
	EventBus.tab_changed.connect(_on_tab_changed)
	_refresh()


func _exit_tree() -> void:
	if EventBus.build_phase_changed.is_connected(_on_build_phase_changed):
		EventBus.build_phase_changed.disconnect(_on_build_phase_changed)
	if EventBus.build_progress_changed.is_connected(_refresh):
		EventBus.build_progress_changed.disconnect(_refresh)
	if EventBus.tab_changed.is_connected(_on_tab_changed):
		EventBus.tab_changed.disconnect(_on_tab_changed)


func _on_tab_changed(tab_id: String) -> void:
	_current_tab = tab_id


func _build_styles() -> void:
	_sb_track = StyleBoxFlat.new()
	_sb_track.bg_color = UiTokens.NEUTRAL_BADGE_BG.lerp(UiTokens.CARD_BORDER, 0.5)
	_sb_track.set_corner_radius_all(4)
	track.add_theme_stylebox_override("panel", _sb_track)
	_sb_fill = StyleBoxFlat.new()
	_sb_fill.bg_color = UiTokens.ACCENT.lerp(UiTokens.CARD_BG, 0.35)   # net amber
	_sb_fill.set_corner_radius_all(4)
	fill.add_theme_stylebox_override("panel", _sb_fill)
	# Mini faz şeridi: biten = pozitif, aktif = amber + accent çerçeve, bekleyen = soluk.
	_sb_mini_done = StyleBoxFlat.new()
	_sb_mini_done.bg_color = UiTokens.POSITIVE_BG
	_sb_mini_done.set_corner_radius_all(3)
	_sb_mini_active = StyleBoxFlat.new()
	_sb_mini_active.bg_color = UiTokens.AMBER_BG
	_sb_mini_active.border_color = UiTokens.ACCENT
	_sb_mini_active.set_border_width_all(1)
	_sb_mini_active.set_corner_radius_all(3)
	_sb_mini_pending = StyleBoxFlat.new()
	_sb_mini_pending.bg_color = UiTokens.NEUTRAL_BADGE_BG.lerp(UiTokens.CARD_BG, 0.6)
	_sb_mini_pending.set_corner_radius_all(3)


func _set_fill_fraction(f: float) -> void:
	fill.anchor_right = clampf(f, 0.0, 1.0)


func _on_build_phase_changed(_new_phase: String) -> void:
	_refresh()


func _refresh() -> void:
	var b: FeatureBuild = ProductSystem.get_active_build()
	if b == null or b.is_bug_sprint or not (b.current_phase in _PHASE_ORDER):
		visible = false
		return
	visible = true
	_paint_one(b)


func _paint_one(b: FeatureBuild) -> void:
	# Başlık: ikon + ad + "V2 · AI ASSISTANT".
	name_label.text = b.product_name if b.product_name != "" else _sub_type_display(b.sub_product_type_id)
	var version: int = (int(GameState.get_flag("mvp_version", 1)) + 1) if b.is_version_build else 1
	meta_label.text = "V%d · %s" % [version, UiTokens.tr_upper(_sub_type_display(b.sub_product_type_id))]
	_paint_icon(b.sub_product_type_id)
	# Mini 3-faz şeridi: aktif fazın solu biten, sağı bekleyen.
	var idx: int = _PHASE_ORDER.find(b.current_phase)
	var cells: Array = [mini_design, mini_dev, mini_beta]
	for i in cells.size():
		var sb: StyleBoxFlat = _sb_mini_active if i == idx else (_sb_mini_done if i < idx else _sb_mini_pending)
		var cell: PanelContainer = cells[i]
		cell.add_theme_stylebox_override("panel", sb)
		var cap: Label = cell.get_child(0)
		cap.add_theme_color_override("font_color",
			UiTokens.ACCENT_DEEP if i == idx else UiTokens.INK_DIM)
	# Faz hücresi + ilerleme — Rev3 tek kaynaklar: build_progress() + build_days_remaining().
	phase_name_label.text = String(_PHASE_DISPLAY.get(b.current_phase, ""))
	var pct: int = int(floor(ProductSystem.build_progress() * 100.0))
	var status: String = "%%%d · ~%d gün" % [pct, max(0, ProductSystem.build_days_remaining())]
	# Kapasite bölünmüşse (sprint/pitch-prep ile paralel) build yarı hızda akar.
	if ProductSystem.capacity_speed_factor() < 1.0:
		status += " · yarı hız"
	phase_status_label.text = status
	_set_fill_fraction(ProductSystem.build_progress())
	# Beta: bug sayaçları + Yayınla (launch bugfix-gated; buton yalnız burada).
	var in_beta: bool = b.current_phase == "bugfix"
	beta_row.visible = in_beta
	action_button.visible = in_beta
	if in_beta:
		beta_found_val.text = str(b.bugs_found)
		beta_fixed_val.text = str(b.bugs_fixed)
		beta_remain_val.text = str(max(0, b.bugs_found - b.bugs_fixed))
	_set_card_height(H_BETA if in_beta else H_NORMAL)


# --- Aksiyonlar -------------------------------------------------------------

func _on_action_pressed() -> void:
	var b: FeatureBuild = ProductSystem.get_active_build()
	if b == null or b.current_phase != "bugfix":
		return
	ProductSystem.launch()


func _on_cancel_pressed() -> void:
	var b: FeatureBuild = ProductSystem.get_active_build()
	if b == null or b.is_bug_sprint:
		return
	var burned_days: int = max(0, GameState.day - b.start_day)
	var burned_cash: int = burned_days * GameState.daily_burn   # working yaklaşım
	var early: bool = burned_days < ProductSystem.CANCEL_FREE_DAYS
	# Seçim iptalden ÖNCE yakalanır (cancel_build build'i null'lar) → kurma
	# ekranı aynı seçimle açılır, oyuncu düzenler.
	var prefill := {
		"type": b.sub_product_type_id,
		"features": b.feature_ids.duplicate(),
		"name": b.product_name,
	}
	EventBus.confirm_requested.emit({
		"title": "Build'i iptal et?",
		"body": "Kurma ekranına dönersin — seçimlerini düzenleyip yeniden başlarsın." if early
			else "%d gün + $%d yandı — geri gelmez. Sadece bundan sonrası durur." % [burned_days, burned_cash],
		"confirm_text": "İptal et",
		"cancel_text": "Vazgeç",
		"on_confirm": _do_cancel.bind(prefill),
	})


func _do_cancel(prefill: Dictionary) -> void:
	# SIRA (tracker'daki portla aynı): önce prefill flag'i — cancel_build()
	# içindeki "cancelled" emit'i, Product açıksa canlı router'ı ANINDA prefill'li
	# kurma ekranına yönlendirir. Product açık DEĞİLSE tab_changed ile taze mount
	# tetiklenir; taze router prefill'i _ready'de tüketir. Product açıkken
	# tab_changed EMİT EDİLMEZ — remount canlı navigasyonu ezer, prefill kaybolur.
	GameState.set_flag("cancelled_build_prefill", prefill)
	ProductSystem.cancel_build()
	if _current_tab != "product":
		EventBus.tab_changed.emit("product")


# --- Sürükleme --------------------------------------------------------------

func _on_panel_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		_dragging = event.pressed
		if _dragging:
			_ensure_free_position()
	elif event is InputEventMouseMotion and _dragging:
		root.position += event.relative
		_clamp_root()


func _ensure_free_position() -> void:
	# Sağ-anchor'lu varsayılan yerleşimi, global konumu koruyarak noktasal
	# konuma çevirir — sonrası position üzerinden yürür.
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
	# İzinli alan = bu node'un rect'i = CenterViewport (top bar / sol bar /
	# sağ bar / ticker dışarıda) — kart tamamen içeride kalır.
	if not _drag_free:
		return
	var limit: Vector2 = size - root.size
	root.position = Vector2(
		clampf(root.position.x, 0.0, maxf(0.0, limit.x)),
		clampf(root.position.y, 0.0, maxf(0.0, limit.y)))


func _set_card_height(h: float) -> void:
	if _drag_free:
		root.size = Vector2(CARD_W, h)
	else:
		root.offset_bottom = root.offset_top + h
	_clamp_root()


# --- Görsel yardımcılar -----------------------------------------------------

func _paint_icon(sub_type_id: String) -> void:
	var path: String = "res://assets/icons/products/%s.svg" % sub_type_id
	if sub_type_id != "" and ResourceLoader.exists(path):
		icon_rect.texture = load(path)
		icon_rect.modulate = UiTokens.ACCENT_DEEP
		icon_rect.visible = true
	else:
		icon_rect.texture = null
		icon_rect.visible = false


func _sub_type_display(sub_type_id: String) -> String:
	# Meta satırı KISA EN etiketi kullanır ("AI ASSISTANT") — working call.
	if sub_type_id == "":
		return "Build"
	var data: Dictionary = ProductCatalog.get_sub_product_type_by_id(sub_type_id)
	if data.is_empty():
		return sub_type_id
	return String(data.get("name", sub_type_id))
