extends Control

# ============================================================================
# Kurma akışı (Rev3, plan Step 9 "Creation flow") — üç adım:
#   01 YOL (B2C/B2B yol kartları) → 02 TİP (tip kart gridi) → 03 ÖZELLİKLER
#   (feature listesi + TriangleRadar önizleme + ÜRÜN PROFİLİ + commit kartı).
# Tek Control; adım geçişinde içerik free+rebuild (açık navigasyonda meşru).
# Seçim değişikliği YALNIZ alt bandı günceller (liste yeniden kurulmaz).
#
# v2 modu (setup({step: 3, v2: true})): kimlik mvp_* flag'lerinden, tip sabit,
# ad Label (LineEdit değil); ship edilmiş feature'lar ön-işaretli, soluk,
# geri alınamaz. Havuz bittiğinde GÜÇLENDİR moduna düşer: ship edilmiş satırlar
# STRENGTHEN_MAX_PER_VERSION tavanlı güçlendirme seçimi olur.
#
# KİLİTLİ mod (setup({locked: true}) — router "tracker" id'sini buraya bağlar):
# eski kalıp geri geldi (Erdem, 2026-07-17): build sürerken AYNI Özellikler
# ekranı görünür ama kilitli — build'in seçimi işaretli, satırlar inert, seçili
# olmayanlar soluk; commit kartının yerinde build durum kartı (faz satırı +
# ilerleme + ~gün + Beta'da "Yayınla →" + iptal). Takip ayrıca yüzen Build
# Takip Kartı'nda; ikisi de aynı ProductSystem API'larını okur.
#
# Ekonomiye TEK yazma yolu: ProductSystem.start_build / start_version_build
# (maliyet tahsili start_build İÇİNDE — UI nakde asla dokunmaz, Write-Through).
#
# Working karar (done-mesajında bayraklı): feature'larda kategori alanı yok —
# 03'ün kategori grupları DOMINANT EKSEN üzerinden türetilir (İNOVASYON /
# KARARLILIK / DENEYİM), başlık "%s · %d/%d".
# ============================================================================

signal navigate_requested(view_id: String, args: Dictionary)

# Eksen legend renkleri tek kaynaktan (ProductUiShared.AXIS_COLORS) — Ürün
# Detayı ile aynı üçlü.
const AXIS_COLORS := ProductUiShared.AXIS_COLORS

const _PHASE_ORDER := ["iteration", "development", "bugfix"]
const _PHASE_DISPLAY := {"iteration": "TASARIM", "development": "GELİŞTİRME", "bugfix": "BETA"}

var _step: int = 1
var _v2_mode: bool = false
var _locked_mode: bool = false           # build sürüyor — görüntüleme, seçim yok
var _strengthen_mode: bool = false
var _market: String = ""                 # "b2c" | "b2b"
var _type_id: String = ""
var _selected: Array[String] = []        # yeni feature seçimi
var _strengthen: Array[String] = []      # GÜÇLENDİR seçimi (v2 havuz-bitti modu)
var _shipped_ids: Array[String] = []     # v2: canlı üründeki feature'lar
var _prefill: Dictionary = {}            # iptal edilen build'in {type, features, name}
var _suggest_i: int = 0

# 03 yerinde-güncelleme referansları
var _rows: Dictionary = {}               # fid -> {card, check}
var _group_headers: Array = []           # [{label, title, ids}]
var _sel_count_label: Label = null
var _radar: TriangleRadar = null
var _legend: Dictionary = {}             # axis -> {bar, plus}
var _risk_label: Label = null
var _totals_label: Label = null
var _cash_label: Label = null
var _commit_btn: Button = null
var _name_edit: LineEdit = null
var _sorumlu: OptionButton = null

# Kilitli mod durum kartı referansları
var _status_phase_labels: Array = []     # 3 Label (TASARIM/GELİŞTİRME/BETA)
var _status_bar: ProgressBar = null
var _status_line: Label = null
var _beta_line: Label = null
var _publish_btn: Button = null


func setup(args: Dictionary) -> void:
	_v2_mode = bool(args.get("v2", false))
	_step = clampi(int(args.get("step", 1)), 1, 3)
	var pf: Variant = args.get("prefill")
	_prefill = pf if pf is Dictionary else {}
	var lb: FeatureBuild = ProductSystem.get_active_build() if bool(args.get("locked", false)) else null
	if lb != null:
		# Kilitli görüntüleme: kimlik ve seçim AKTİF BUILD'den; v2 build'de ship
		# edilmişler frozen, yeniler işaretli. Router'ın tracker korkuluğu build
		# bitince zaten başka görünüme yönlendirir.
		_locked_mode = true
		_step = 3
		_type_id = lb.sub_product_type_id
		_market = ProductCatalog.get_market_type(_type_id)
		_v2_mode = lb.is_version_build
		if _v2_mode:
			for fid in GameState.get_flag("mvp_components", []):
				_shipped_ids.append(String(fid))
		for fid in lb.feature_ids:
			if not _shipped_ids.has(String(fid)):
				_selected.append(String(fid))
		for fid in lb.strengthened_feature_ids:
			_strengthen.append(String(fid))
		_rebuild()
		return
	if _v2_mode:
		_step = 3
		_type_id = String(GameState.get_flag("mvp_sub_product_type_id", ""))
		_market = String(GameState.get_flag("mvp_market_type", "b2c"))
		for fid in GameState.get_flag("mvp_components", []):
			_shipped_ids.append(String(fid))
		_strengthen_mode = _pool_exhausted()
	elif not _prefill.is_empty():
		# İptal edilen build'in seçimi geri gelir (yanlış-tık affı).
		_type_id = String(_prefill.get("type", ""))
		if _type_id != "":
			_market = ProductCatalog.get_market_type(_type_id)
		for fid in _prefill.get("features", []):
			_selected.append(String(fid))
	# Adım tutarlılığı: tip yoksa 03, yol yoksa 02 açılamaz.
	if _step == 3 and _type_id == "" and not _v2_mode:
		_step = 1
	if _step == 2 and _market == "":
		_step = 1
	_rebuild()


func repaint() -> void:
	# Saatlik/günlük sinyaller: yalnız alt bandın rakamları oynar (kasa, ~gün);
	# liste ve kartlara dokunulmaz (repaint-fırtınası korkuluğu).
	if _step == 3 and _radar != null and is_instance_valid(_radar):
		_update_dynamic()


# --- Kurulum ---------------------------------------------------------------

func _rebuild() -> void:
	for c in get_children():
		remove_child(c)
		c.queue_free()
	_rows.clear()
	_group_headers.clear()
	_legend.clear()
	_sel_count_label = null
	_radar = null
	_risk_label = null
	_totals_label = null
	_cash_label = null
	_commit_btn = null
	_name_edit = null
	_sorumlu = null
	_status_phase_labels.clear()
	_status_bar = null
	_status_line = null
	_beta_line = null
	_publish_btn = null

	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	for side in ["margin_left", "margin_right", "margin_top", "margin_bottom"]:
		margin.add_theme_constant_override(side, 16)
	add_child(margin)
	var outer := VBoxContainer.new()
	outer.add_theme_constant_override("separation", 10)
	margin.add_child(outer)
	if not _locked_mode:   # kilitli görüntülemede yaratım adım şeridi anlamsız
		outer.add_child(_make_breadcrumb())
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	outer.add_child(scroll)
	var body := VBoxContainer.new()
	body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation", 12)
	scroll.add_child(body)
	match _step:
		1: _build_step1(body)
		2: _build_step2(body)
		3: _build_step3(body)


func _make_breadcrumb() -> Control:
	var hb := HBoxContainer.new()
	hb.add_theme_constant_override("separation", 8)
	var items := ["01 YOL", "02 TİP", "03 ÖZELLİKLER"]
	for i in items.size():
		if i > 0:
			hb.add_child(UiFactory.make_label("→", &"SectionLabel", UiTokens.INK_DIM))
		var active: bool = (_step == i + 1)
		hb.add_child(UiFactory.make_label(items[i], &"SectionLabel",
			UiTokens.ACCENT_DEEP if active else UiTokens.INK_DIM))
	return hb


# --- 01 YOL ------------------------------------------------------------------

func _build_step1(body: VBoxContainer) -> void:
	body.add_child(UiFactory.make_label("Yolunu seç", &"TitleSerif"))
	body.add_child(UiFactory.make_label(
		"Bu seçim ürünün nasıl para kazandığını belirler. Sonradan değişmez.", &"CaptionMuted"))
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	row.add_child(_make_path_card("b2c", "KİTLE", "B2C",
		"Kitleye satarsın. Kullanıcılar gelir, gider, sayılar dalgalanır.",
		["Kitle kendiliğinden büyür", "Kullanıcı başına küçük gelir", "Kaprisli"]))
	row.add_child(_make_path_card("b2b", "KONTRAT", "B2B",
		"Şirketlere satarsın. Her kontrat büyük para, her müşteri senin eserin.",
		["Kontrat başına yüksek gelir", "Satışı sen yaparsın", "Müşteri tutmak iş ister"]))
	body.add_child(row)
	if not GameState.get_flag("product_path_frank_seen", false):
		body.add_child(_make_frank_strip())


func _make_path_card(market: String, kicker: String, big: String, desc: String, bullets: Array) -> Control:
	var card := PanelContainer.new()
	card.theme_type_variation = &"CardPanel"
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 8)
	card.add_child(vb)
	vb.add_child(UiFactory.make_label(kicker, &"SectionLabel"))
	var big_lbl := UiFactory.make_label(big, &"TitleSerif")
	big_lbl.add_theme_font_size_override("font_size", 34)
	vb.add_child(big_lbl)
	var d := UiFactory.make_label(desc, &"BodySerif")
	d.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vb.add_child(d)
	vb.add_child(UiFactory.make_label("TİP ÖRNEKLERİ", &"SectionLabel"))
	var pills := HFlowContainer.new()
	pills.add_theme_constant_override("h_separation", 6)
	pills.add_theme_constant_override("v_separation", 4)
	var shown: int = 0
	for st in ProductCatalog.get_all_sub_product_types():
		if String(st.get("market_type", "")) != market or shown >= 3:
			continue
		pills.add_child(UiFactory.make_pill(String(st.get("name_human", "")),
			UiTokens.NEUTRAL_BADGE_BG, UiTokens.NEUTRAL_BADGE_FG, false))
		shown += 1
	vb.add_child(pills)
	for b in bullets:
		var bl := UiFactory.make_label("· %s" % b, &"BodySerif", UiTokens.INK_MUTED)
		bl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		vb.add_child(bl)
	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vb.add_child(spacer)
	var btn := Button.new()
	btn.theme_type_variation = &"CommitButton"
	btn.text = "Bu yolu seç →"
	btn.pressed.connect(_on_path_chosen.bind(market))
	vb.add_child(btn)
	return card


func _on_path_chosen(market: String) -> void:
	_market = market
	_step = 2
	_rebuild()


func _make_frank_strip() -> Control:
	# İlk girişte mentor şeridi — koyu zemin (BG_NEWS); bağlam kuralı gereği
	# metinler CREAM tonlarında (SectionLabel INK_DIM koyu zeminde okunmaz).
	var panel := PanelContainer.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = UiTokens.BG_NEWS
	sb.set_corner_radius_all(4)
	sb.content_margin_left = 14
	sb.content_margin_right = 14
	sb.content_margin_top = 10
	sb.content_margin_bottom = 10
	panel.add_theme_stylebox_override("panel", sb)
	var hb := HBoxContainer.new()
	hb.add_theme_constant_override("separation", 10)
	panel.add_child(hb)
	var avatar := Panel.new()
	avatar.theme_type_variation = &"Avatar"
	avatar.custom_minimum_size = Vector2(28, 28)
	avatar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var initials := UiFactory.make_label("FK", &"AvatarInitial")
	initials.set_anchors_preset(Control.PRESET_FULL_RECT)
	initials.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	initials.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	avatar.add_child(initials)
	hb.add_child(avatar)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 2)
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col.add_child(UiFactory.make_label("FRANK KÖSEOĞLU · MENTOR", &"SectionLabel", UiTokens.CREAM_DIM))
	var quote := UiFactory.make_label(
		"B2C'de kalabalığa satarsın, kimseyi tanımazsın. B2B'de herkesi tanırsın, herkes seni tanır. İkisi de para. Farklı dertler.",
		&"QuoteSerifCream")
	quote.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	col.add_child(quote)
	hb.add_child(col)
	var ok := Button.new()
	ok.text = "Tamam"
	ok.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	ok.pressed.connect(func() -> void:
		GameState.set_flag("product_path_frank_seen", true)
		panel.visible = false)
	hb.add_child(ok)
	return panel


# --- 02 TİP ------------------------------------------------------------------

func _build_step2(body: VBoxContainer) -> void:
	var back := Button.new()
	back.text = "← GERİ · YOL SEÇİMİ"
	back.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	back.pressed.connect(func() -> void:
		_step = 1
		_rebuild())
	body.add_child(back)
	body.add_child(UiFactory.make_label("%s · Ürün tipini seç" % UiTokens.tr_upper(_market), &"TitleSerif"))
	body.add_child(UiFactory.make_label(
		"Hangi problemi çözüyoruz? Sektör, müşterinin dünyasını belirler.", &"CaptionMuted"))
	var grid := GridContainer.new()
	grid.columns = 3
	grid.add_theme_constant_override("h_separation", 12)
	grid.add_theme_constant_override("v_separation", 12)
	body.add_child(grid)
	for st in ProductCatalog.get_all_sub_product_types():
		if String(st.get("market_type", "")) != _market:
			continue
		grid.add_child(_make_type_card(st))


func _make_type_card(st: Dictionary) -> Control:
	var card := PanelContainer.new()
	card.theme_type_variation = &"CardPanel"
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 6)
	card.add_child(vb)
	vb.add_child(UiFactory.make_label(String(st.get("name_human", "")), &"NameSerif"))
	vb.add_child(UiFactory.make_label(String(st.get("category_tr", "")), &"SectionLabel"))
	var d := UiFactory.make_label(String(st.get("desc_tr", "")), &"BodySerif")
	d.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vb.add_child(d)
	var pills := HFlowContainer.new()
	pills.add_theme_constant_override("h_separation", 6)
	pills.add_theme_constant_override("v_separation", 4)
	for s in st.get("sectors_tr", []):
		pills.add_child(UiFactory.make_pill(String(s),
			UiTokens.NEUTRAL_BADGE_BG, UiTokens.NEUTRAL_BADGE_FG, false))
	vb.add_child(pills)
	var pm := UiFactory.make_label(String(st.get("plus_minus_tr", "")), &"QuoteSerif")
	pm.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vb.add_child(pm)
	_set_mouse_ignore(vb)
	card.gui_input.connect(_on_type_card_input.bind(String(st.get("id", ""))))
	return card


func _on_type_card_input(ev: InputEvent, type_id: String) -> void:
	if not _is_left_click(ev):
		return
	if _type_id != type_id:
		_selected.clear()  # tip değişti — eski seçim havuza ait değil
	_type_id = type_id
	_step = 3
	_rebuild()


# --- 03 ÖZELLİKLER -----------------------------------------------------------

func _build_step3(body: VBoxContainer) -> void:
	var st: Dictionary = ProductCatalog.get_sub_product_type_by_id(_type_id)
	if _locked_mode:
		var back_p := Button.new()
		back_p.text = "← GERİ · PORTFÖY"
		back_p.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
		back_p.pressed.connect(func() -> void:
			navigate_requested.emit("portfoy", {}))
		body.add_child(back_p)
	elif not _v2_mode:
		var back := Button.new()
		back.text = "← GERİ · TİP SEÇİMİ"
		back.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
		back.pressed.connect(func() -> void:
			_step = 2
			_selected.clear()
			_rebuild())
		body.add_child(back)
	var head := HBoxContainer.new()
	head.add_theme_constant_override("separation", 10)
	if _locked_mode:
		# Ürün adı başrolde; pazar/tip meta satırına düşer (detail header grameri).
		var b: FeatureBuild = ProductSystem.get_active_build()
		var pname: String = b.product_name if b != null and b.product_name != "" else String(st.get("name_human", ""))
		head.add_child(UiFactory.make_label(pname, &"NameSerif"))
		var meta := UiFactory.make_label(
			"%s · %s" % [UiTokens.tr_upper(_market), UiTokens.tr_upper(String(st.get("name_human", "")))], &"SectionLabel")
		meta.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		head.add_child(meta)
	else:
		head.add_child(UiFactory.make_label(
			"%s / %s" % [UiTokens.tr_upper(_market), String(st.get("name_human", ""))], &"NameSerif"))
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(spacer)
	_sel_count_label = UiFactory.make_label("", &"SectionLabel", UiTokens.ACCENT_DEEP)
	head.add_child(_sel_count_label)
	if _locked_mode:
		# Kilit telgrafı: seçim sayacı yerine durum rozeti (satırlar inert).
		_sel_count_label.visible = false
		head.add_child(UiFactory.make_badge("İNŞA EDİLİYOR · SEÇİM KİLİTLİ", &"accent"))
	body.add_child(head)

	# Feature listesi — kategori = dominant eksen (working gruplama), her grup
	# başlık + iki kolonlu grid.
	var pool: Array = ProductCatalog.get_feature_pool(_type_id)
	for axis in ProductUiShared.AXIS_KEYS:
		var group_ids: Array[String] = []
		var group_feats: Array = []
		for f in pool:
			if _dominant_axis(f) == axis:
				group_ids.append(String(f.get("id", "")))
				group_feats.append(f)
		if group_feats.is_empty():
			continue
		var header := UiFactory.make_label("", &"SectionLabel")
		body.add_child(header)
		_group_headers.append({
			"label": header,
			"title": UiTokens.tr_upper(ProductUiShared.axis_label(String(axis))),
			"ids": group_ids,
		})
		var grid := GridContainer.new()
		grid.columns = 2
		grid.add_theme_constant_override("h_separation", 10)
		grid.add_theme_constant_override("v_separation", 8)
		body.add_child(grid)
		for f in group_feats:
			grid.add_child(_make_feature_row(f))

	body.add_child(_make_bottom_band())
	for fid in _rows.keys():
		_apply_row_style(String(fid))
	_update_dynamic()


func _dominant_axis(f: Dictionary) -> String:
	# Feature'ın en çok beslediği eksen (eşitlikte inno→stab→exp — engine kuralıyla aynı).
	var dc: Dictionary = f.get("dimension_contribution", {})
	var best: String = "innovation"
	var best_v: float = -INF
	for axis in ProductUiShared.AXIS_KEYS:
		var v: float = float(dc.get(axis, 0))
		if v > best_v:
			best_v = v
			best = String(axis)
	return best


func _make_feature_row(f: Dictionary) -> Control:
	var fid: String = String(f.get("id", ""))
	var shipped: bool = _shipped_ids.has(fid)
	var card := PanelContainer.new()
	card.theme_type_variation = &"CardPanelTight"
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var hb := HBoxContainer.new()
	hb.add_theme_constant_override("separation", 8)
	card.add_child(hb)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 3)
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hb.add_child(col)
	var rich := RichTextLabel.new()
	rich.theme_type_variation = &"BodyRich"
	rich.bbcode_enabled = true
	rich.fit_content = true
	rich.scroll_active = false
	rich.text = "[b]%s[/b]  %s" % [String(f.get("name", "")), String(f.get("voice", ""))]
	col.add_child(rich)
	var info := UiFactory.make_label(ProductUiShared.feature_info_line(f), &"RowMeta")
	info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	col.add_child(info)
	var check := UiFactory.make_label("✓", &"NameSerif", UiTokens.ACCENT_DEEP)
	check.visible = false
	check.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	hb.add_child(check)
	_rows[fid] = {"card": card, "check": check}

	var research_locked: bool = bool(f.get("requires_research", false)) and not shipped
	var frozen_shipped: bool = shipped and not _strengthen_mode  # v2: ön-işaretli, geri alınamaz
	if research_locked:
		var badge := UiFactory.make_badge("ARAŞTIRMA GEREKLİ", &"neutral")
		badge.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		hb.add_child(badge)
		card.modulate = Color(1, 1, 1, 0.5)
		card.mouse_filter = Control.MOUSE_FILTER_IGNORE
		card.focus_mode = Control.FOCUS_NONE
	elif _locked_mode:
		# Kilitli görüntüleme: hiçbir satır etkileşimli değil; işaret/soluma
		# _apply_row_style'da (build'in seçimi işaretli, kalanlar soluk).
		card.mouse_filter = Control.MOUSE_FILTER_IGNORE
		card.focus_mode = Control.FOCUS_NONE
	elif frozen_shipped:
		check.visible = true
		check.add_theme_color_override("font_color", UiTokens.INK_DIM)
		card.modulate = Color(1, 1, 1, 0.55)
		card.mouse_filter = Control.MOUSE_FILTER_IGNORE
		card.focus_mode = Control.FOCUS_NONE
	else:
		_set_mouse_ignore(hb)
		card.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		card.gui_input.connect(_on_feature_row_input.bind(fid))
	return card


func _on_feature_row_input(ev: InputEvent, fid: String) -> void:
	if not _is_left_click(ev):
		return
	if _strengthen_mode:
		if _strengthen.has(fid):
			_strengthen.erase(fid)
		elif _strengthen.size() < ProductSystem.STRENGTHEN_MAX_PER_VERSION:
			_strengthen.append(fid)
		else:
			return  # tavan dolu — sessiz ret
	else:
		if _selected.has(fid):
			_selected.erase(fid)
		else:
			_selected.append(fid)
	_apply_row_style(fid)
	_update_dynamic()


func _apply_row_style(fid: String) -> void:
	var row: Dictionary = _rows.get(fid, {})
	if row.is_empty():
		return
	var card: PanelContainer = row.card
	var check: Label = row.check
	var shipped: bool = _shipped_ids.has(fid)
	var picked: bool
	if _locked_mode:
		# Görüntüleme: build'in yeni seçimi VE güçlendirme pick'leri işaretli;
		# havuzun geri kalanı soluk (eski kilitli-kurma-ekranı grameri).
		picked = _selected.has(fid) or _strengthen.has(fid)
		if not picked and not shipped:
			card.modulate = Color(1, 1, 1, 0.55)
	else:
		picked = _strengthen.has(fid) if _strengthen_mode else _selected.has(fid)
	if picked:
		# Seçili satır: soluk amber zemin + 2px amber çerçeve (onaylı mockup).
		var sel: StyleBoxFlat = (card.get_theme_stylebox("panel") as StyleBoxFlat).duplicate()
		sel.bg_color = UiTokens.AMBER_BG
		sel.border_color = UiTokens.ACCENT
		sel.set_border_width_all(2)
		card.add_theme_stylebox_override("panel", sel)
	else:
		card.remove_theme_stylebox_override("panel")
	check.visible = picked or shipped
	check.add_theme_color_override("font_color",
		UiTokens.ACCENT_DEEP if picked else UiTokens.INK_DIM)


# --- Alt bant: radar + ÜRÜN PROFİLİ + commit ---------------------------------

func _make_bottom_band() -> Control:
	var band := HBoxContainer.new()
	band.add_theme_constant_override("separation", 14)
	_radar = TriangleRadar.new()
	_radar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_radar.size_flags_stretch_ratio = 1.0
	band.add_child(_radar)

	var legend := VBoxContainer.new()
	legend.add_theme_constant_override("separation", 6)
	legend.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	legend.size_flags_stretch_ratio = 1.2
	legend.add_child(UiFactory.make_section_header("ÜRÜN PROFİLİ"))
	for axis in ProductUiShared.AXIS_KEYS:
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 8)
		row.add_child(UiFactory.make_dot(AXIS_COLORS[axis], 8))
		var name_l := UiFactory.make_label(ProductUiShared.axis_label(String(axis)), &"RowName")
		name_l.custom_minimum_size = Vector2(76, 0)
		row.add_child(name_l)
		var bar := ProgressBar.new()
		bar.theme_type_variation = &"BuildProgress"
		bar.show_percentage = false
		bar.custom_minimum_size = Vector2(0, 6)
		bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		row.add_child(bar)
		var plus := UiFactory.make_label("", &"RowMeta")
		plus.custom_minimum_size = Vector2(34, 0)
		plus.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		row.add_child(plus)
		legend.add_child(row)
		_legend[axis] = {"bar": bar, "plus": plus}
	_risk_label = UiFactory.make_label("", &"RowMeta")
	legend.add_child(_risk_label)
	band.add_child(legend)

	band.add_child(_make_build_status_card() if _locked_mode else _make_commit_card())
	return band


func _make_build_status_card() -> Control:
	# Kilitli modda commit kartının yerini alır: faz satırı + efor ilerlemesi +
	# ~gün + Beta'da bug sayaçları ve "Yayınla →" + iptal. Yüzen Build Takip
	# Kartı'yla aynı tek-kaynak API'lar (build_progress / build_days_remaining).
	var card := PanelContainer.new()
	card.theme_type_variation = &"CardPanel"
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.size_flags_stretch_ratio = 1.4
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 6)
	card.add_child(vb)
	vb.add_child(UiFactory.make_section_header("BUILD DURUMU"))
	var phase_row := HBoxContainer.new()
	phase_row.add_theme_constant_override("separation", 10)
	for phase in _PHASE_ORDER:
		var pl := UiFactory.make_label(String(_PHASE_DISPLAY[phase]), &"SectionLabel", UiTokens.INK_DIM)
		phase_row.add_child(pl)
		_status_phase_labels.append(pl)
	vb.add_child(phase_row)
	_status_bar = ProgressBar.new()
	_status_bar.theme_type_variation = &"BuildProgress"
	_status_bar.show_percentage = false
	_status_bar.custom_minimum_size = Vector2(0, 8)
	vb.add_child(_status_bar)
	_status_line = UiFactory.make_label("", &"RowMeta")
	vb.add_child(_status_line)
	_beta_line = UiFactory.make_label("", &"RowMeta", UiTokens.INK_MUTED)
	_beta_line.visible = false
	vb.add_child(_beta_line)
	_publish_btn = Button.new()
	_publish_btn.theme_type_variation = &"CommitButton"
	_publish_btn.text = "Yayınla →"
	_publish_btn.visible = false
	_publish_btn.pressed.connect(_on_publish_pressed)
	vb.add_child(_publish_btn)
	var cancel := Button.new()
	cancel.flat = true
	cancel.text = "Build'i iptal et"
	cancel.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	cancel.add_theme_color_override("font_color", UiTokens.INK_MUTED)
	cancel.pressed.connect(_on_cancel_pressed)
	vb.add_child(cancel)
	return card


func _make_commit_card() -> Control:
	var card := PanelContainer.new()
	card.theme_type_variation = &"CardPanel"
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.size_flags_stretch_ratio = 1.4
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 6)
	card.add_child(vb)
	if _v2_mode:
		vb.add_child(UiFactory.make_label(
			String(GameState.get_flag("mvp_product_name", "")), &"NameSerif"))
	else:
		var name_row := HBoxContainer.new()
		name_row.add_theme_constant_override("separation", 6)
		_name_edit = LineEdit.new()
		_name_edit.placeholder_text = "Ürün adı"
		_name_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		if not _prefill.is_empty():
			_name_edit.text = String(_prefill.get("name", ""))
		name_row.add_child(_name_edit)
		var sug := Button.new()
		sug.text = "ÖNER"
		sug.pressed.connect(_on_suggest_pressed)
		name_row.add_child(sug)
		vb.add_child(name_row)
	vb.add_child(UiFactory.make_label("SORUMLU", &"SectionLabel"))
	_sorumlu = OptionButton.new()
	var founder: Character = CharacterRegistry.get_founder()
	_sorumlu.add_item(founder.character_name if founder != null else "Kurucu")
	_sorumlu.set_item_metadata(0, founder.id if founder != null else "")
	var idx: int = 1
	for c in CharacterRegistry.get_employees():
		if c.role == "Engineer":
			_sorumlu.add_item(c.character_name)
			_sorumlu.set_item_metadata(idx, c.id)
			idx += 1
	_sorumlu.select(0)  # varsayılan: kurucu
	_sorumlu.item_selected.connect(func(_i: int) -> void: _update_dynamic())
	vb.add_child(_sorumlu)
	_totals_label = UiFactory.make_label("", &"RowMeta")
	_totals_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vb.add_child(_totals_label)
	_cash_label = UiFactory.make_label("", &"RowMeta", UiTokens.INK_MUTED)
	_cash_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vb.add_child(_cash_label)
	_commit_btn = Button.new()
	_commit_btn.theme_type_variation = &"CommitButton"
	_commit_btn.pressed.connect(_on_commit_pressed)
	vb.add_child(_commit_btn)
	return card


func _on_suggest_pressed() -> void:
	if _name_edit != null:
		_name_edit.text = ProductCatalog.suggest_product_name(_suggest_i)
		_suggest_i += 1


# --- Canlı güncelleme (yalnız alt bant + sayaçlar) ----------------------------

func _update_dynamic() -> void:
	if _radar == null or not is_instance_valid(_radar):
		return
	var base: Dictionary = _base_dims()
	var axes: Dictionary = ProductSystem.projected_axes(_selected, _strengthen, base)
	var maxv: float = TriangleRadar.DEFAULT_MAX
	for axis in ProductUiShared.AXIS_KEYS:
		maxv = maxf(maxv, float(axes[axis]))
	_radar.set_axes(axes, maxv)
	for axis in ProductUiShared.AXIS_KEYS:
		var cell: Dictionary = _legend[axis]
		var bar: ProgressBar = cell.bar
		bar.max_value = maxv
		bar.value = float(axes[axis])
		var gain: int = int(round(float(axes[axis]) - float(base.get(axis, 0.0))))
		(cell.plus as Label).text = "+%d" % gain
	_risk_label.text = "Hata riski: %s" \
		% ProductUiShared.risk_label(ProductCatalog.selection_risk_band(_selected))
	# Sayaç + grup başlıkları ("%s · %d/%d") — işaretli satır sayılır.
	var picked_total: int = _selected.size() + _strengthen.size()
	_sel_count_label.text = "%d seçili" % picked_total
	for gh in _group_headers:
		var checked: int = 0
		for fid in gh.ids:
			if _selected.has(fid) or _strengthen.has(fid) \
					or (_v2_mode and not _strengthen_mode and _shipped_ids.has(fid)):
				checked += 1
		(gh.label as Label).text = "%s · %d/%d" % [gh.title, checked, (gh.ids as Array).size()]
	# Kilitli mod: commit kartı yok — durum kartı güncellenir, gerisi atlanır.
	if _locked_mode:
		_update_status()
		return
	# Toplamlar + kasa projeksiyonu + commit.
	var efor: int = ProductCatalog.sum_efor(_selected) \
		+ ProductSystem.STRENGTHEN_EFOR * _strengthen.size()
	var cost: int = ProductCatalog.sum_cost(_selected)
	var days: int = ProductSystem.estimate_build_days(_selected, _strengthen, _sorumlu_id())
	if cost > 0:
		_totals_label.text = "Toplam efor %d · Maliyet %s · Süre ~%d gün" \
			% [efor, ProductUiShared.money_tr(cost), days]
	else:
		_totals_label.text = "Toplam efor %d · Süre ~%d gün" % [efor, days]
	_cash_label.text = "Bittiğinde kasada %s kalır" \
		% ProductUiShared.money_tr(ProductUiShared.cash_after_build(cost, days))
	_commit_btn.disabled = picked_total <= 0
	var suffix: String = ""
	if cost > 0:
		suffix = " · %s kasadan düşer" % ProductUiShared.money_tr(cost)
	_commit_btn.text = "Onayla ve Başlat" + suffix


func _base_dims() -> Dictionary:
	if not _v2_mode:
		return {}  # v1: sıfır taban
	return {
		"innovation": float(GameState.get_flag("mvp_innovation", 0.0)),
		"stability": float(GameState.get_flag("mvp_stability", 0.0)),
		"experience": float(GameState.get_flag("mvp_experience", 0.0)),
	}


func _sorumlu_id() -> String:
	if _sorumlu == null or _sorumlu.selected < 0:
		return ""
	var md: Variant = _sorumlu.get_item_metadata(_sorumlu.selected)
	return String(md) if md != null else ""


func _pool_exhausted() -> bool:
	# GÜÇLENDİR modu: havuzda seçilebilir (ship edilmemiş + araştırma kilidi
	# olmayan) feature kalmadıysa. Araştırma kilitliler sayılmaz — yoksa kilitli
	# havuz tipleri sonsuza dek güçlendirmeye geçemezdi (v-build asla kilitlenmez).
	for f in ProductCatalog.get_feature_pool(_type_id):
		var fid: String = String(f.get("id", ""))
		if not _shipped_ids.has(fid) and not bool(f.get("requires_research", false)):
			return false
	return true


func _update_status() -> void:
	# Durum kartı — yüzen kartla aynı tek-kaynak API'lar; faz etiket renkleri:
	# biten POSITIVE, aktif ACCENT_DEEP, bekleyen INK_DIM.
	var b: FeatureBuild = ProductSystem.get_active_build()
	if b == null or _status_line == null or not is_instance_valid(_status_line):
		return
	var idx: int = _PHASE_ORDER.find(b.current_phase)
	for i in _status_phase_labels.size():
		var color: Color = UiTokens.INK_DIM
		if i < idx:
			color = UiTokens.POSITIVE
		elif i == idx:
			color = UiTokens.ACCENT_DEEP
		(_status_phase_labels[i] as Label).add_theme_color_override("font_color", color)
	_status_bar.value = ProductSystem.build_progress() * 100.0
	var line: String = "%s · %%%d · ~%d gün" % [
		String(_PHASE_DISPLAY.get(b.current_phase, "")),
		int(floor(ProductSystem.build_progress() * 100.0)),
		max(0, ProductSystem.build_days_remaining())]
	if ProductSystem.capacity_speed_factor() < 1.0:
		line += " · yarı hız"
	_status_line.text = line
	var in_beta: bool = b.current_phase == "bugfix"
	_beta_line.visible = in_beta
	_publish_btn.visible = in_beta
	if in_beta:
		_beta_line.text = "Beta · bulunan %d · çözülen %d · açık %d" \
			% [b.bugs_found, b.bugs_fixed, b.bug_count]


func _on_publish_pressed() -> void:
	var b: FeatureBuild = ProductSystem.get_active_build()
	if b == null or b.current_phase != "bugfix":
		return
	ProductSystem.launch()   # router "shipped" emit'inde detaya yönlendirir


func _on_cancel_pressed() -> void:
	# Yüzen karttaki akışla aynı (yanan gün metni + prefill + confirm şekli).
	var b: FeatureBuild = ProductSystem.get_active_build()
	if b == null or b.is_bug_sprint:
		return
	var burned_days: int = max(0, GameState.day - b.start_day)
	var burned_cash: int = burned_days * GameState.daily_burn   # working yaklaşım
	var early: bool = burned_days < ProductSystem.CANCEL_FREE_DAYS
	var prefill := {
		"type": b.sub_product_type_id,
		"features": b.feature_ids.duplicate(),
		"name": b.product_name,
	}
	EventBus.confirm_requested.emit({
		"title": "Build'i iptal et?",
		"body": "Kurma ekranına dönersin · seçimlerini düzenleyip yeniden başlarsın." if early
			else "%d gün + %s yandı · geri gelmez. Sadece bundan sonrası durur." % [burned_days, ProductUiShared.money_tr(burned_cash)],
		"confirm_text": "İptal et",
		"cancel_text": "Vazgeç",
		"on_confirm": _do_cancel.bind(prefill),
	})


func _do_cancel(prefill: Dictionary) -> void:
	# SIRA: prefill ÖNCE — cancel_build() içindeki "cancelled" emit'i router'ı
	# anında prefill'li kurma ekranına yönlendirir (bu view o anda ölür).
	GameState.set_flag("cancelled_build_prefill", prefill)
	ProductSystem.cancel_build()


# --- Commit ------------------------------------------------------------------

func _on_commit_pressed() -> void:
	var ok: bool
	if _v2_mode:
		ok = ProductSystem.start_version_build(_selected, _sorumlu_id(), _strengthen)
	else:
		var pname: String = _name_edit.text if _name_edit != null else ""
		ok = ProductSystem.start_build(_type_id, _selected, _sorumlu_id(), pname)
	if ok:
		navigate_requested.emit("tracker", {})


# --- Yardımcılar ---------------------------------------------------------------

func _is_left_click(ev: InputEvent) -> bool:
	return ev is InputEventMouseButton and ev.pressed \
		and (ev as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT


func _set_mouse_ignore(n: Node) -> void:
	# Kart içi çocuklar tıklamayı yutmasın — gui_input kart kökünde (eski tab deseni).
	if n is Control:
		(n as Control).mouse_filter = Control.MOUSE_FILTER_IGNORE
	for c in n.get_children():
		_set_mouse_ignore(c)
