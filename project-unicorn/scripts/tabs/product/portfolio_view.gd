extends Control

# ============================================================================
# Portföy — Product tab açılış görünümü (Rev3, plan Step 9 "Portföy").
# Kart listesi (liste-şekilli; bugün 0-1 ürün): canlı ürün kartı → detail,
# süren build kartı → tracker, "+ Yeni Ürün" CTA'sı (ürün de build de yokken)
# → creation, KİLİTLİ slot HER ZAMAN sonda. Kod-kurulu; UiFactory + tema
# varyasyonları. Kart kaynakları: mvp_shipped flag'i + get_active_build()
# (sprint'ler flag'dir, asla build DEĞİL — is_bug_sprint kontrolü yok).
#
# repaint(): yapı (kart kümesi) aynıysa metinleri YERİNDE günceller; küme
# değişince (ship/iptal/yeni build) listeyi yeniden kurar.
# ============================================================================

signal navigate_requested(view_id: String, args: Dictionary)

const LOCKED_SLOT_TEXT := "KİLİTLİ · Series A sonrası"

var _count_label: Label = null
var _list: VBoxContainer = null
var _structure_key: String = ""
# Yerinde-repaint referansları
var _live_numbers: Label = null
var _build_badge_label: Label = null
var _build_bar: ProgressBar = null


func setup(_args: Dictionary) -> void:
	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	for side in ["margin_left", "margin_right", "margin_top", "margin_bottom"]:
		margin.add_theme_constant_override(side, 16)
	add_child(margin)
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 10)
	margin.add_child(vb)
	vb.add_child(UiFactory.make_label("Portföy", &"TitleSerif"))
	_count_label = UiFactory.make_label("", &"CaptionMuted")
	vb.add_child(_count_label)
	_list = VBoxContainer.new()
	_list.add_theme_constant_override("separation", 10)
	vb.add_child(_list)
	_rebuild_cards()


func repaint() -> void:
	if _list == null:
		return
	if _structure_key != _compute_structure_key():
		_rebuild_cards()
		return
	_update_texts()


# --- Kart listesi -----------------------------------------------------------

func _compute_structure_key() -> String:
	return "%s|%s" % [GameState.get_flag("mvp_shipped", false),
		ProductSystem.get_active_build() != null]


func _rebuild_cards() -> void:
	_structure_key = _compute_structure_key()
	_live_numbers = null
	_build_badge_label = null
	_build_bar = null
	for c in _list.get_children():
		_list.remove_child(c)
		c.queue_free()
	var shipped: bool = GameState.get_flag("mvp_shipped", false)
	var build: FeatureBuild = ProductSystem.get_active_build()
	var n: int = (1 if shipped else 0) + (1 if build != null else 0)
	_count_label.text = "%d ürün · tıkla ve yönet" % n
	if shipped:
		_list.add_child(_make_live_card())
	if build != null:
		_list.add_child(_make_building_card(build))
	if not shipped and build == null:
		_list.add_child(_make_cta_card())
	_list.add_child(_make_locked_slot())  # HER ZAMAN sonda


func _make_live_card() -> Control:
	var market: String = String(GameState.get_flag("mvp_market_type", "b2c"))
	var type_id: String = String(GameState.get_flag("mvp_sub_product_type_id", ""))
	var st: Dictionary = ProductCatalog.get_sub_product_type_by_id(type_id)
	var pname: String = String(GameState.get_flag("mvp_product_name", ""))
	if pname == "":
		pname = String(st.get("name_human", type_id))
	var card := PanelContainer.new()
	card.theme_type_variation = &"CardPanel"
	card.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	var hb := HBoxContainer.new()
	hb.add_theme_constant_override("separation", 12)
	card.add_child(hb)
	var id_col := VBoxContainer.new()
	id_col.add_theme_constant_override("separation", 2)
	id_col.add_child(UiFactory.make_label(pname, &"NameSerif"))
	id_col.add_child(UiFactory.make_label(
		"%s · %s" % [UiTokens.tr_upper(market), UiTokens.tr_upper(String(st.get("name_human", "")))], &"RowMeta"))
	hb.add_child(id_col)
	# make_pill (uppercase=false): make_badge her şeyi büyütür, "v1"in küçük v'si
	# mockup'ın sürüm imzası — palet aynı (positive).
	var pal: Dictionary = UiTokens.badge_palette(&"positive")
	var badge := UiFactory.make_pill("CANLI v%d" % int(GameState.get_flag("mvp_version", 1)),
		pal.bg, pal.fg, false)
	hb.add_child(badge)
	_live_numbers = UiFactory.make_label(_key_numbers_text(market), &"RowMeta")
	_live_numbers.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	hb.add_child(_live_numbers)
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hb.add_child(spacer)
	hb.add_child(UiFactory.make_label("→", &"NameSerif", UiTokens.INK_DIM))
	_set_mouse_ignore(hb)
	card.gui_input.connect(_on_card_input.bind("detail", {}))
	return card


func _key_numbers_text(market: String) -> String:
	var bugs: int = int(GameState.get_flag("mvp_live_bug_count", 0))
	if market == "b2b":
		var custs: Array = CustomerRegistry.get_by_market("b2b")
		var mrr_sum: int = 0
		var sat_sum: int = 0
		for c in custs:
			mrr_sum += c.mrr
			sat_sum += c.satisfaction
		var arrow: String = "→"  # müşteri yokken nötr
		if not custs.is_empty():
			var avg: float = float(sat_sum) / float(custs.size())
			arrow = "↗" if avg >= 60.0 else ("→" if avg >= 40.0 else "↘")
		return "MRR katkısı %s/ay · Açık hata %d · Memnuniyet %s" \
			% [ProductUiShared.money_tr(mrr_sum), bugs, arrow]
	var deneyen: int = int(GameState.get_flag("b2c_audience", 0))
	var price_part: String = "Fiyat taslak"
	if GameState.get_flag("b2c_paid_tier_open", false):
		price_part = "Fiyat %s" % ProductUiShared.money_tr(int(GameState.get_flag("b2c_price", 0)))
	return "Deneyen %d · Açık hata %d · %s" % [deneyen, bugs, price_part]


func _make_building_card(build: FeatureBuild) -> Control:
	var card := PanelContainer.new()
	card.theme_type_variation = &"CardPanel"
	card.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 6)
	card.add_child(vb)
	var hb := HBoxContainer.new()
	hb.add_theme_constant_override("separation", 10)
	hb.add_child(UiFactory.make_label(build.product_name, &"NameSerif"))
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hb.add_child(spacer)
	var pct: int = int(round(ProductSystem.build_progress() * 100.0))
	var badge := UiFactory.make_badge("GELİŞTİRMEDE %%%d" % pct, &"accent")
	_build_badge_label = badge.get_child(0) as Label
	hb.add_child(badge)
	vb.add_child(hb)
	_build_bar = ProgressBar.new()
	_build_bar.theme_type_variation = &"BuildProgress"
	_build_bar.show_percentage = false
	_build_bar.custom_minimum_size = Vector2(0, 8)
	_build_bar.max_value = 100.0
	_build_bar.value = float(pct)
	vb.add_child(_build_bar)
	_set_mouse_ignore(vb)
	card.gui_input.connect(_on_card_input.bind("tracker", {}))
	return card


func _make_cta_card() -> Control:
	var card := PanelContainer.new()
	card.theme_type_variation = &"CardCta"
	card.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	var lbl := UiFactory.make_label("+ Yeni Ürün", &"NameSerif", UiTokens.ACCENT_DEEP)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(lbl)
	card.gui_input.connect(_on_card_input.bind("creation", {"step": 1}))
	return card


func _make_locked_slot() -> Control:
	var card := PanelContainer.new()
	card.theme_type_variation = &"CardPanelTight"
	card.modulate = Color(1, 1, 1, 0.45)
	card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.focus_mode = Control.FOCUS_NONE
	var hb := HBoxContainer.new()
	hb.add_theme_constant_override("separation", 10)
	# Tek metin: LOCKED_SLOT_TEXT zaten "KİLİTLİ" ile başlar — ayrı chip çift yazardı.
	var lbl := UiFactory.make_label(LOCKED_SLOT_TEXT, &"RowMeta")
	lbl.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	hb.add_child(lbl)
	card.add_child(hb)
	return card


# --- Yerinde güncelleme -----------------------------------------------------

func _update_texts() -> void:
	if _live_numbers != null and is_instance_valid(_live_numbers):
		_live_numbers.text = _key_numbers_text(String(GameState.get_flag("mvp_market_type", "b2c")))
	var pct: int = int(round(ProductSystem.build_progress() * 100.0))
	if _build_badge_label != null and is_instance_valid(_build_badge_label):
		_build_badge_label.text = "GELİŞTİRMEDE %%%d" % pct
	if _build_bar != null and is_instance_valid(_build_bar):
		_build_bar.value = float(pct)


# --- Girdi ------------------------------------------------------------------

func _on_card_input(ev: InputEvent, view_id: String, args: Dictionary) -> void:
	if ev is InputEventMouseButton and ev.pressed \
			and (ev as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT:
		navigate_requested.emit(view_id, args)


func _set_mouse_ignore(n: Node) -> void:
	# Kart içi çocuklar tıklamayı yutmasın — gui_input kart kökünde (eski tab deseni).
	if n is Control:
		(n as Control).mouse_filter = Control.MOUSE_FILTER_IGNORE
	for c in n.get_children():
		_set_mouse_ignore(c)
