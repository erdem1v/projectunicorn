extends Control

# Build Takip Kartı (restore, 2026-07-17): sağ üstte yüzen KOMPAKT kart — Rev3'ün
# pasif şeridi + Product-tab gizlemesi Erdem tarafından reddedildi; kart geri geldi.
# Build sürerken HER sekmede görünür (Product dahil; in-tab tracker'la birlikte
# yaşar, ikisi de aynı ProductSystem API'larını okur).
#
# İçerik: header (ikon + ad + V·TİP + ✕ iptal), mini 3-faz şeridi
# (TASARIM/GELİŞTİRME/BETA), BuildBar (Software Inc. segment grameri, 2026-08-19: tur
# başına bir segment / tek çubuk / boşalan hata çubuğu — tracker kartı ve ODA
# monitörüyle AYNI sahne), Beta'da BULUNAN/ÇÖZÜLEN/KALAN satırı + "Yayınla →" butonu.
# Karar satırı faz başına TEK buton: TASARIM'da "Geliştirmeye geç →" (tur 1 bitince),
# GELİŞTİRME parkında "Beta'ya geç →". "Bir tur daha" YOK — turlar kendi kendine döner.
#
# SÜRÜKLENEBİLİR: kart CenterViewport'un çocuğu; Root parent rect'ine clamp'lenir
# → top bar / sol bar / sağ bar (ve ticker) yapısal olarak erişilemez. Konum
# oturum boyunca kalır (kart tab değişiminde ölmez); yeni run'da varsayılan sağ üst.
#
# İlerleme çizimi BuildBar'ın işi (kendi sinyallerini kendi dinler, kart ona hiçbir şey
# itmez). Kartın kendi refresh'i signal-driven (no _process poll): build_phase_changed +
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
@onready var build_bar: Control = $Root/Panel/VBox/BodyRow/BuildBar
@onready var beta_row: HBoxContainer = $Root/Panel/VBox/BetaRow
@onready var beta_found_val: Label = $Root/Panel/VBox/BetaRow/FoundBox/Val
@onready var beta_fixed_val: Label = $Root/Panel/VBox/BetaRow/FixedBox/Val
@onready var beta_remain_val: Label = $Root/Panel/VBox/BetaRow/RemainBox/Val
# BoxContainer, HBoxContainer DEĞİL: karar satırı Terminal'de DİKEY yığıldı (mono
# butonlar yan yana 320px kartı taşırıyordu). Tip HBoxContainer kalsaydı @onready
# ataması sessizce düşer, referans null olur ve altındaki buton bağlantıları
# "Nil üzerinde 'pressed'" hatasıyla ölürdü — battery log'unda 42 kez öyle oldu.
@onready var decision_row: BoxContainer = $Root/Panel/VBox/DecisionRow
@onready var dev_btn: Button = $Root/Panel/VBox/DecisionRow/DevBtn
@onready var promote_btn: Button = $Root/Panel/VBox/DecisionRow/PromoteBtn
@onready var action_button: Button = $Root/Panel/VBox/ActionButton

# Faz görünen adları — iç id'ler değişmedi (event/promise tüketicileri okur).
## Faz adları CSV'den; const olamaz (yükleme anında dil yok). creation_flow'un aynısı.
const _PHASE_KEYS := {"iteration": "BUILD_PHASE_DESIGN", "development": "BUILD_PHASE_DEVELOPMENT",
	"bugfix": "BUILD_PHASE_BETA"}
const _PHASE_ORDER := ["iteration", "development", "bugfix"]

# Kart boyutu (tuning): genişlik sabit; yükseklik normal fazlarda kompakt,
# karar butonu görünürken ve Beta'da (beta satırı + Yayınla) uzar. Eski kart 172 sabitti;
# BuildBar (44) eski faz hücresinden (34) 10px yüksek — üç sabit de o kadar büyüdü.
const CARD_W := 320.0
const H_NORMAL := 140.0
const H_BETA := 200.0
const H_DECISION := 172.0   # faz geçiş kararı: tek buton için uzar

# Mini şerit tonları — bir kez kurulur, paint yalnız stylebox swap eder.
var _sb_mini_done: StyleBoxFlat = null
var _sb_mini_active: StyleBoxFlat = null
var _sb_mini_pending: StyleBoxFlat = null

# Sürükleme durumu: ilk sürüklemede sağ-anchor'lu Root serbest konuma çevrilir;
# sonrası position + clamp. Konum node yaşadıkça (oturum) korunur.
var _dragging := false
var _drag_free := false

# İki rol izler (ODA rework): (1) iptal yönlendirmesi — Product'tayken canlı
# router "cancelled" emit'inde prefill'i tüketir, tab_changed emit edilirse
# remount o navigasyonu ezer; başka sekmede/odada tab_changed şart. (2) oda
# gizlemesi — "" (oda görünür) iken kart gizlenir, _refresh başı okur.
var _current_tab: String = ""   # tab_changed aynası; "" = ODA (açılış durumu)


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build_styles()
	action_button.pressed.connect(_on_action_pressed)
	cancel_btn.pressed.connect(_on_cancel_pressed)
	dev_btn.pressed.connect(_on_dev_pressed)
	promote_btn.pressed.connect(_on_promote_pressed)
	panel.gui_input.connect(_on_panel_gui_input)
	resized.connect(_clamp_root)
	EventBus.build_phase_changed.connect(_on_build_phase_changed)
	EventBus.day_advanced.connect(func(_d: int) -> void: _refresh())
	EventBus.build_progress_changed.connect(_refresh)
	EventBus.build_iteration_decision_pending.connect(_on_iter_pending_changed)
	EventBus.tab_changed.connect(_on_tab_changed)
	EventBus.palette_changed.connect(_on_palette_changed)
	_refresh()


func _exit_tree() -> void:
	if EventBus.palette_changed.is_connected(_on_palette_changed):
		EventBus.palette_changed.disconnect(_on_palette_changed)
	if EventBus.build_phase_changed.is_connected(_on_build_phase_changed):
		EventBus.build_phase_changed.disconnect(_on_build_phase_changed)
	if EventBus.build_progress_changed.is_connected(_refresh):
		EventBus.build_progress_changed.disconnect(_refresh)
	if EventBus.build_iteration_decision_pending.is_connected(_on_iter_pending_changed):
		EventBus.build_iteration_decision_pending.disconnect(_on_iter_pending_changed)
	if EventBus.tab_changed.is_connected(_on_tab_changed):
		EventBus.tab_changed.disconnect(_on_tab_changed)


func _on_iter_pending_changed(_pending: bool) -> void:
	_refresh()


func _on_tab_changed(tab_id: String) -> void:
	_current_tab = tab_id
	# Oda ↔ sayfa geçişinde gizle/göster kararı değişir (aşağıdaki oda bekçisi).
	_refresh()


# Renk körü paleti takas edildi: stylebox'lar ve BETA satırının iki rengi
# yeniden token'dan okunur. Kart yerinde onarılır (yeniden kurulmaz) —
# language_changed'in dilbilgisi.
func _on_palette_changed(_cb: bool) -> void:
	_build_styles()
	_refresh()


func _build_styles() -> void:
	# Mini faz şeridi: biten = pozitif, aktif = amber + accent çerçeve, bekleyen = soluk.
	_sb_mini_done = StyleBoxFlat.new()
	_sb_mini_done.bg_color = UiTokens.positive_bg()
	_sb_mini_done.set_corner_radius_all(3)
	_sb_mini_active = StyleBoxFlat.new()
	_sb_mini_active.bg_color = UiTokens.AMBER_BG
	_sb_mini_active.border_color = UiTokens.ACCENT
	_sb_mini_active.set_border_width_all(1)
	_sb_mini_active.set_corner_radius_all(3)
	_sb_mini_pending = StyleBoxFlat.new()
	_sb_mini_pending.bg_color = UiTokens.NEUTRAL_BADGE_BG.lerp(UiTokens.CARD_BG, 0.6)
	_sb_mini_pending.set_corner_radius_all(3)
	_apply_semantic_colors()


# BETA satırının iki semantik rengi (ÇÖZÜLEN yeşil / KALAN kırmızı) sahnede
# BAYT-SABİT Color literalleriydi — projedeki son iki tanesi. Renk körü paleti
# çalışma zamanında takas ettiği için sahne artık renk taşımıyor: değer
# UiTokens'ın accessor'ından okunur ve palette_changed'de yeniden okunur.
func _apply_semantic_colors() -> void:
	beta_fixed_val.add_theme_color_override("font_color", UiTokens.positive())
	beta_remain_val.add_theme_color_override("font_color", UiTokens.negative())


func _on_build_phase_changed(_new_phase: String) -> void:
	_refresh()


func _refresh() -> void:
	# ODA bekçisi (Erdem onayı 2026-08-06): oda görünürken kart gizli — monitör
	# çapası aynı build verisini taşır, resmin üstünde kart yüzmez. Sekme sayfası
	# açılınca kart bugünkü davranışıyla döner.
	if _current_tab == "":
		visible = false
		return
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
	meta_label.text = tr("PROD_META_VERSION").format(
		{"version": version, "type": Fmt.upper(_sub_type_display(b.sub_product_type_id))})
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
	# İlerleme: BuildBar kendi çizer (model türetilmiş, sinyaller onda). Kart yalnız
	# faz geçiş kararının TEK butonunu yakar: TASARIM'da "Geliştirmeye geç →" (tur 1
	# bittikten sonra; koşan yarım tur kazançsız terk edilir — tooltip söyler),
	# GELİŞTİRME parkında "Beta'ya geç →". "Bir tur daha" yok, turlar kendi döner.
	var can_dev: bool = ProductSystem.can_enter_development()
	var can_beta: bool = ProductSystem.can_enter_beta()
	dev_btn.visible = can_dev
	promote_btn.visible = can_beta
	decision_row.visible = can_dev or can_beta
	var mid_round: bool = can_dev and b.iteration_count >= 2 \
		and not b.iteration_decision_pending and b.iteration_round_days > 0.0 \
		and b.iteration_round_days < float(ProductSystem.ITER_ROUND_DAYS)
	dev_btn.tooltip_text = tr("BUILD_HALF_ROUND_TOOLTIP") if mid_round else ""
	# Beta: bug sayaçları + Yayınla (launch bugfix-gated; buton yalnız burada).
	var in_beta: bool = b.current_phase == "bugfix"
	beta_row.visible = in_beta
	action_button.visible = in_beta
	if in_beta:
		beta_found_val.text = str(b.bugs_found)
		beta_fixed_val.text = str(b.bugs_fixed)
		beta_remain_val.text = str(max(0, b.bugs_found - b.bugs_fixed))
		# Yayınla'nın bedeli butonun kendisinde: TÜM açık hatalar (bug_count) canlıya taşınır.
		action_button.tooltip_text = tr("BUILD_SHIP_TOOLTIP_BUGS").format({"n": maxi(0, b.bug_count)})
	_set_card_height(H_BETA if in_beta else (H_DECISION if decision_row.visible else H_NORMAL))


# --- Aksiyonlar -------------------------------------------------------------

func _on_action_pressed() -> void:
	var b: FeatureBuild = ProductSystem.get_active_build()
	if b == null or b.current_phase != "bugfix":
		return
	ProductSystem.launch()


func _on_dev_pressed() -> void:
	# Guard seam'de (can_enter_development) — çift tık / bayat kart zararsız.
	ProductSystem.enter_development()


func _on_promote_pressed() -> void:
	# Guard seam'de (can_enter_beta).
	ProductSystem.enter_beta()


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
		"title": tr("PROD_CANCEL_BUILD_Q"),
		"body": tr("PROD_CANCEL_BUILD_BODY") if early
			else tr("PROD_CANCEL_BUILD_COST").format(
				{"days": burned_days, "amount": Fmt.money_exact(burned_cash)}),
		"confirm_text": tr("HR_SEARCH_CANCEL_OK"),
		"cancel_text": tr("UI_DISMISS"),
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
	# B3a'ya kadar katalogdaki kısa EN "name" alanını okuyordu; o alan artık yok (sözcükler
	# CSV'ye taşındı), yani bu satır ham id basıyordu. Yerelleşmiş ada bağlandı.
	if sub_type_id == "":
		return tr("PROD_BUILD_FALLBACK")
	return ProductCatalog.type_name(sub_type_id)


## Faz id → ekran adı (creation_flow ile aynı sözleşme).
func _phase_display(phase: String) -> String:
	var key: String = String(_PHASE_KEYS.get(phase, ""))
	return tr(key) if key != "" else ""
