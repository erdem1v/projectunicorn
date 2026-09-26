extends Control

# ============================================================================
# Portföy: Ürün sekmesinin açılış görünümü. Kart listesi (bugün 0-1 ürün): canlı
# ürün kartı → detail, süren build kartı → tracker, "+ Yeni Ürün" CTA'sı (ürün de
# build de yokken) → creation, kilitli slot HER ZAMAN sonda.
# repaint(): kart kümesi aynıysa metinleri YERİNDE günceller; küme değişince (ship /
# iptal / yeni build) listeyi yeniden kurar.
# ============================================================================

signal navigate_requested(view_id: String, args: Dictionary)

var _count_label: Label = null
var _list: VBoxContainer = null
var _structure_key: String = ""
# yerinde-repaint referansları
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
	vb.add_child(UiFactory.make_label(tr("PROD_PORTFOLIO"), &"TitleSerif"))
	_count_label = UiFactory.make_label("", &"CaptionMuted")
	vb.add_child(_count_label)
	_list = VBoxContainer.new()
	_list.add_theme_constant_override("separation", 10)
	vb.add_child(_list)
	_rebuild_cards()


func repaint() -> void:
	if _structure_key != _structure():
		_rebuild_cards()
		return
	if _live_numbers != null:
		_live_numbers.text = _key_numbers_text()
	if _build_bar != null:
		var pct: int = UiTokens.build_percent(ProductSystem.build_progress())
		_build_badge_label.text = _phase_pct_text(pct)
		_build_bar.value = pct


# --- Kart listesi -----------------------------------------------------------

func _structure() -> String:
	return "%s|%s" % [ProductState.is_live(), ProductSystem.get_active_build() != null]


func _rebuild_cards() -> void:
	_structure_key = _structure()
	_live_numbers = null
	_build_badge_label = null
	_build_bar = null
	ProductUiShared.clear(_list)
	var shipped: bool = ProductState.is_live()
	var build: FeatureBuild = ProductSystem.get_active_build()
	_count_label.text = tr("PROD_PORTFOLIO_COUNT").format({"n": int(shipped) + int(build != null)})
	if shipped:
		_list.add_child(_make_live_card())
	if build != null:
		_list.add_child(_make_building_card(build))
	if not shipped and build == null:
		var cta := UiFactory.make_label(tr("PROD_NEW_PRODUCT"), &"NameSerif", UiTokens.ACCENT_DEEP)
		cta.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_list.add_child(_clickable_card(&"CardCta", cta, "creation", {"step": 1}))
	# Kilitli slot. Metni zaten "KİLİTLİ" ile başlar; ayrı bir chip çift yazardı.
	var locked := PanelContainer.new()
	locked.theme_type_variation = &"CardPanelTight"
	locked.modulate.a = 0.45
	locked.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var locked_lbl := UiFactory.make_label(tr("PROD_LOCKED_SERIES_A"), &"RowMeta")
	locked_lbl.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	locked.add_child(locked_lbl)
	_list.add_child(locked)


func _clickable_card(variation: StringName, content: Control, view_id: String, args: Dictionary) -> PanelContainer:
	var card := PanelContainer.new()
	card.theme_type_variation = variation
	card.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	card.add_child(content)
	HRUiShared.set_mouse_ignore(content)   # tıklama kart kökünün gui_input'una düşsün
	card.gui_input.connect(_on_card_input.bind(view_id, args))
	return card


func _make_live_card() -> Control:
	var type_name: String = ProductCatalog.type_name(String(GameState.get_flag("mvp_sub_product_type_id", "")))
	var pname: String = String(GameState.get_flag("mvp_product_name", ""))
	var hb := HBoxContainer.new()
	hb.add_theme_constant_override("separation", 12)
	var id_col := VBoxContainer.new()
	id_col.add_theme_constant_override("separation", 2)
	id_col.add_child(UiFactory.make_label(pname if pname != "" else type_name, &"NameSerif"))
	id_col.add_child(UiFactory.make_label("%s · %s" % [
		Fmt.upper(String(GameState.get_flag("mvp_market_type", "b2c"))), Fmt.upper(type_name)], &"RowMeta"))
	hb.add_child(id_col)
	# make_pill (uppercase=false): make_badge her şeyi büyütür, "v1"in küçük v'si sürüm imzası.
	var pal: Dictionary = UiTokens.badge_palette(&"positive")
	hb.add_child(UiFactory.make_pill(tr("PROD_LIVE_VERSION_LC").format(
		{"version": int(GameState.get_flag("mvp_version", 1))}), pal.bg, pal.fg, false))
	_live_numbers = UiFactory.make_label(_key_numbers_text(), &"RowMeta")
	_live_numbers.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_live_numbers.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	hb.add_child(_live_numbers)
	hb.add_child(UiFactory.make_label("→", &"NameSerif", UiTokens.INK_DIM))
	return _clickable_card(&"CardPanel", hb, "detail", {})


func _key_numbers_text() -> String:
	var bugs: int = ProductSystem.live_bug_count()
	if String(GameState.get_flag("mvp_market_type", "b2c")) == "b2b":
		var custs: Array[Customer] = CustomerRegistry.get_by_market("b2b")
		var mrr_sum: int = 0
		var sat_sum: int = 0
		for c in custs:
			mrr_sum += c.mrr
			sat_sum += c.satisfaction
		var arrow: String = "→"   # müşteri yokken nötr
		if not custs.is_empty():
			var avg: float = float(sat_sum) / custs.size()
			arrow = "↗" if avg >= 60.0 else ("→" if avg >= 40.0 else "↘")
		return tr("PROD_ROW_B2B").format({"amount": Fmt.money_exact(mrr_sum), "bugs": bugs, "sat": arrow})
	var price_part: String = tr("PROD_PRICE_DRAFT")
	if GameState.get_flag("b2c_paid_tier_open", false):
		price_part = tr("PROD_PRICE_N").format({"amount": Fmt.money_exact(int(GameState.get_flag("b2c_price", 0)))})
	return tr("PROD_ROW_B2C").format(
		{"users": Fmt.group(ProductUiShared.b2c_free_users()), "bugs": bugs, "price": price_part})


func _make_building_card(build: FeatureBuild) -> Control:
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 6)
	var hb := HBoxContainer.new()
	hb.add_theme_constant_override("separation", 10)
	var name_lbl := UiFactory.make_label(build.product_name, &"NameSerif")
	name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hb.add_child(name_lbl)
	# Yüzdenin tek evi UiTokens.build_percent: yüzen build kartı aynı build'i aynı karede
	# basar, rozet ile bar da aynı int'ten türer.
	var pct: int = UiTokens.build_percent(ProductSystem.build_progress())
	var badge := UiFactory.make_badge(_phase_pct_text(pct), &"accent")
	_build_badge_label = badge.get_child(0) as Label
	hb.add_child(badge)
	vb.add_child(hb)
	_build_bar = ProgressBar.new()
	_build_bar.theme_type_variation = &"BuildProgress"
	_build_bar.show_percentage = false
	_build_bar.custom_minimum_size = Vector2(0, 8)
	_build_bar.max_value = 100.0
	_build_bar.value = pct
	vb.add_child(_build_bar)
	return _clickable_card(&"CardPanel", vb, "tracker", {})


## "TASARIM %10": rozet fazı söyler (yüzen build kartıyla aynı), sabit bir "geliştirmede"
## değil. Faz adı ProductSystem'in tek evinden; çözülemezse genel etiket.
func _phase_pct_text(pct: int) -> String:
	var key: String = ProductSystem.phase_label_key()
	if key == "":
		return tr("PROD_IN_DEV_PCT").format({"pct": Fmt.percent(pct, 0)})
	return "%s %s" % [tr(key), Fmt.percent(pct, 0)]


func _on_card_input(ev: InputEvent, view_id: String, args: Dictionary) -> void:
	var mb := ev as InputEventMouseButton
	if mb != null and mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT:
		navigate_requested.emit(view_id, args)
