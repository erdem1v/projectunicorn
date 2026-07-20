extends Control

# =============================================================================
# Ürün Detayı görünümü (Product Tab Rev3, Step 9 — post-ship ürün evi).
# TEK ekran; B2B/B2C panelleri `_is_b2b` üstünden koşullu (iki ayrı sahne fork
# drift'i yeniden getirirdi). Router load()+new()+add_child+setup ile kurar;
# repaint() her repaint sinyalinde etiketleri YERİNDE günceller — söz satırları
# yalnız açık-söz sayısı değişince yeniden kurulur.
# Yazmalar yalnız seam'lerden: start_bug_sprint / apply_b2c_price (panel içinde)
# / tab_changed. Liglig/Frank/composite/rival-geçti mantığı eski product_tab
# snapshot'ından port edildi.
# =============================================================================

signal navigate_requested(view_id: String, args: Dictionary)

const PricingPanelScript := preload("res://scripts/tabs/product/pricing_panel.gd")

# Eksen renk üçlüsü tek kaynaktan (ProductUiShared.AXIS_COLORS) — creation
# önizlemesiyle aynı legend renkleri.
const AXIS_COLORS := ProductUiShared.AXIS_COLORS

var _is_b2b := false

# başlık
var _name_label: Label = null
var _meta_label: Label = null
var _live_badge_label: Label = null
var _health_dot: Panel = null
var _health_text: Label = null
# profil kartı
var _radar: TriangleRadar = null
var _legend_rows: Dictionary = {}    # axis -> {"bar": ProgressBar, "val": Label}
var _risk_value: Label = null
var _badges_row: HBoxContainer = null
# traction
var _traction_ready_badge: Control = null
var _traction_bar: ProgressBar = null
var _traction_meta: Label = null
# DURUM stat hücreleri (key -> value Label)
var _stat_values: Dictionary = {}
# B2B söz satırları
var _promise_box: VBoxContainer = null
var _promise_rows: Array = []        # [{"label": Label, "promise": Promise}]
var _open_promise_count: int = -1
# B2C fiyat paneli
var _pricing: PanelContainer = null
# sürümler + aksiyon kartları
var _versions_label: Label = null
var _v_card: PanelContainer = null
var _v_title: Label = null
var _v_status: Label = null
var _sprint_card: PanelContainer = null
var _sprint_status: Label = null
# alt şerit
var _league_label: Label = null
var _frank_line: Label = null


func setup(_args: Dictionary) -> void:
	_is_b2b = String(GameState.get_flag("mvp_market_type", "b2c")) == "b2b"
	set_anchors_preset(Control.PRESET_FULL_RECT)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	_build()
	repaint()


func repaint() -> void:
	if _name_label == null or not GameState.get_flag("mvp_shipped", false):
		return
	var ver: int = int(GameState.get_flag("mvp_version", 1))
	var sub: String = String(GameState.get_flag("mvp_sub_product_type_id", ""))
	var bugs: int = _live_bugs()
	_repaint_header(ver, sub)
	_repaint_profile(ver, bugs)
	_repaint_traction()
	_repaint_stats(bugs)
	if _is_b2b:
		_repaint_promises()
	elif _pricing != null:
		_pricing.repaint()
	_versions_label.text = _versions_line(ver)
	_repaint_action_cards(ver, bugs)
	_repaint_bottom(sub, ver)


# --- kurulum -----------------------------------------------------------------

func _build() -> void:
	var scroll := ScrollContainer.new()
	scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(scroll)
	var margin := MarginContainer.new()
	for side in ["margin_left", "margin_top", "margin_right", "margin_bottom"]:
		margin.add_theme_constant_override(side, 16)
	margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	margin.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.add_child(margin)
	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", 12)
	margin.add_child(root)

	root.add_child(_build_header())

	# İki kolon.
	var cols := HBoxContainer.new()
	cols.add_theme_constant_override("separation", 14)
	var left := VBoxContainer.new()
	left.add_theme_constant_override("separation", 10)
	left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left.size_flags_stretch_ratio = 1.0
	var right := VBoxContainer.new()
	right.add_theme_constant_override("separation", 10)
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right.size_flags_stretch_ratio = 1.0
	cols.add_child(left)
	cols.add_child(right)
	root.add_child(cols)

	_build_left_column(left)
	_build_right_column(right)

	# Alt şerit (tam genişlik): lig satırı + Frank.
	_league_label = Label.new()
	_league_label.add_theme_font_size_override("font_size", 12)
	_league_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	root.add_child(_league_label)
	root.add_child(_build_frank_strip())


func _build_header() -> HBoxContainer:
	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 10)
	var back := Button.new()
	back.flat = true
	back.text = "← GERİ · PORTFÖY"
	back.pressed.connect(func() -> void: navigate_requested.emit("portfoy", {}))
	header.add_child(back)
	_name_label = UiFactory.make_label("", &"NameSerif")
	_name_label.add_theme_font_size_override("font_size", 20)
	_name_label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	header.add_child(_name_label)
	_meta_label = UiFactory.make_label("", &"RowMeta")
	_meta_label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	header.add_child(_meta_label)
	var live_badge := UiFactory.make_badge("CANLI V1", &"positive")
	_live_badge_label = live_badge.get_child(0) as Label
	header.add_child(live_badge)
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(spacer)
	_health_dot = UiFactory.make_dot(UiTokens.INK_DIM, 8)
	header.add_child(_health_dot)
	_health_text = UiFactory.make_label("", &"SectionLabel")
	_health_text.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	header.add_child(_health_text)
	return header


func _build_left_column(left: VBoxContainer) -> void:
	# ÜRÜN PROFİLİ kartı: radar + legend + hata riski + rozetler.
	var prof := VBoxContainer.new()
	prof.add_theme_constant_override("separation", 8)
	prof.add_child(UiFactory.make_label("ÜRÜN PROFİLİ", &"SectionLabel"))
	var prof_row := HBoxContainer.new()
	prof_row.add_theme_constant_override("separation", 12)
	_radar = TriangleRadar.new()
	_radar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	prof_row.add_child(_radar)
	var legend := VBoxContainer.new()
	legend.add_theme_constant_override("separation", 6)
	legend.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	legend.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	for axis in ProductUiShared.AXIS_KEYS:
		var lrow := HBoxContainer.new()
		lrow.add_theme_constant_override("separation", 6)
		lrow.add_child(UiFactory.make_dot(AXIS_COLORS[axis], 7))
		var alabel := UiFactory.make_label(ProductUiShared.axis_label(axis), &"RowMeta", UiTokens.INK)
		alabel.custom_minimum_size = Vector2(70, 0)
		alabel.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		lrow.add_child(alabel)
		var abar := ProgressBar.new()
		abar.theme_type_variation = &"BuildProgress"
		abar.custom_minimum_size = Vector2(0, 6)
		abar.show_percentage = false
		abar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		abar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		_override_bar_fill(abar, AXIS_COLORS[axis])
		lrow.add_child(abar)
		var aval := UiFactory.make_label("+0", &"MetricValueInk")
		aval.add_theme_font_size_override("font_size", 14)
		aval.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		lrow.add_child(aval)
		legend.add_child(lrow)
		_legend_rows[axis] = {"bar": abar, "val": aval}
	prof_row.add_child(legend)
	prof.add_child(prof_row)
	var risk_row := HBoxContainer.new()
	risk_row.add_theme_constant_override("separation", 4)
	risk_row.add_child(UiFactory.make_label("Hata riski:", &"RowMeta"))
	_risk_value = UiFactory.make_label("", &"RowMeta")
	risk_row.add_child(_risk_value)
	prof.add_child(risk_row)
	_badges_row = HBoxContainer.new()
	_badges_row.add_theme_constant_override("separation", 6)
	prof.add_child(_badges_row)
	left.add_child(UiFactory.make_card(prof))

	# Traction şeridi.
	var tr_body := VBoxContainer.new()
	tr_body.add_theme_constant_override("separation", 6)
	var tr_head := HBoxContainer.new()
	var tr_title := UiFactory.make_label("TRACTİON'A DOĞRU", &"SectionLabel")
	tr_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tr_head.add_child(tr_title)
	_traction_ready_badge = UiFactory.make_badge("HAZIR · FRANK'LE KONUŞ", &"positive")
	_traction_ready_badge.visible = false
	tr_head.add_child(_traction_ready_badge)
	tr_body.add_child(tr_head)
	_traction_bar = ProgressBar.new()
	_traction_bar.theme_type_variation = &"BuildProgress"
	_traction_bar.custom_minimum_size = Vector2(0, 6)
	_traction_bar.show_percentage = false
	_traction_bar.max_value = 100.0
	tr_body.add_child(_traction_bar)
	_traction_meta = UiFactory.make_label("", &"RowMeta")
	tr_body.add_child(_traction_meta)
	left.add_child(UiFactory.make_card(tr_body, true))

	# [B2C] DURUM kartı solda.
	if not _is_b2b:
		var st := VBoxContainer.new()
		st.add_theme_constant_override("separation", 8)
		st.add_child(UiFactory.make_label("DURUM", &"SectionLabel"))
		var srow := HBoxContainer.new()
		srow.add_theme_constant_override("separation", 18)
		_add_stat(srow, "deneyen", "DENEYEN")
		_add_stat(srow, "bugs", "AÇIK HATA")
		_add_stat(srow, "stab", "ETKİN KARARLILIK")
		st.add_child(srow)
		left.add_child(UiFactory.make_card(st))


func _build_right_column(right: VBoxContainer) -> void:
	if _is_b2b:
		# DURUM kartı İLK.
		var st := VBoxContainer.new()
		st.add_theme_constant_override("separation", 8)
		st.add_child(UiFactory.make_label("DURUM", &"SectionLabel"))
		var srow := HBoxContainer.new()
		srow.add_theme_constant_override("separation", 18)
		_add_stat(srow, "musteri", "MÜŞTERİ")
		_add_stat(srow, "mrr", "MRR KATKISI")
		_add_stat(srow, "bugs", "AÇIK HATA")
		_add_stat(srow, "stab", "ETKİN KARARLILIK")
		st.add_child(srow)
		right.add_child(UiFactory.make_card(st))
		# Sales CTA.
		var sales_btn := Button.new()
		sales_btn.theme_type_variation = &"CommitButton"
		sales_btn.text = "Sales sekmesine git →"
		sales_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		sales_btn.pressed.connect(func() -> void: EventBus.tab_changed.emit("sales"))
		right.add_child(sales_btn)
		# SÖZ VERİLDİ satırları (açık söz sayısı değişince yeniden kurulur).
		_promise_box = VBoxContainer.new()
		_promise_box.add_theme_constant_override("separation", 6)
		_promise_box.visible = false
		right.add_child(_promise_box)
	else:
		# [B2C] Fiyat paneli İLK.
		_pricing = PricingPanelScript.new()
		right.add_child(_pricing)

	# SÜRÜMLER satırı.
	_versions_label = UiFactory.make_label("", &"RowMeta")
	_versions_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	right.add_child(_versions_label)

	# Aksiyon kartları.
	var v_parts := _make_action_card("", "", "Yeni özellik / güçlendirme · daha yüksek rekabet. (Yeni özellik = yeni bug.)", true)
	_v_card = v_parts["card"]
	_v_title = v_parts["title"]
	_v_status = v_parts["status"]
	_v_card.gui_input.connect(_on_v_card_input)
	right.add_child(_v_card)

	var s_parts := _make_action_card("Hata sprinti", "", "Bug'ları temizle · kararlılık geri gelir (build'le paralelse ikisi yavaşlar).", false)
	_sprint_card = s_parts["card"]
	_sprint_status = s_parts["status"]
	_sprint_card.gui_input.connect(_on_sprint_card_input)
	right.add_child(_sprint_card)

	if _is_b2b:
		# Fiyatlandır kartı: INERT — B2B'de taban fiyat/paket mekanizması yok.
		var p_parts := _make_action_card("Fiyatlandır", "SALES İLE", "B2B'de fiyat kontratta konuşulur · paket ve taban fiyatı ayarla.", false)
		var p_card: PanelContainer = p_parts["card"]
		p_card.mouse_filter = Control.MOUSE_FILTER_IGNORE
		right.add_child(p_card)


func _build_frank_strip() -> PanelContainer:
	var fr := HBoxContainer.new()
	fr.add_theme_constant_override("separation", 10)
	var avatar := Panel.new()
	avatar.theme_type_variation = &"Avatar"
	avatar.custom_minimum_size = Vector2(28, 28)
	avatar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var fk := UiFactory.make_label("FK", &"AvatarInitial")
	fk.set_anchors_preset(Control.PRESET_FULL_RECT)
	fk.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	fk.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	avatar.add_child(fk)
	fr.add_child(avatar)
	var fv := VBoxContainer.new()
	fv.add_theme_constant_override("separation", 2)
	fv.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	fv.add_child(UiFactory.make_label("FRANK", &"SectionLabel"))
	_frank_line = UiFactory.make_label("", &"QuoteSerif")
	_frank_line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	fv.add_child(_frank_line)
	fr.add_child(fv)
	return UiFactory.make_card(fr, true)


func _make_action_card(title: String, status_txt: String, desc: String, attention: bool) -> Dictionary:
	var body := VBoxContainer.new()
	body.add_theme_constant_override("separation", 4)
	var head := HBoxContainer.new()
	head.add_theme_constant_override("separation", 8)
	var t := UiFactory.make_label(title, &"NameSerif")
	head.add_child(t)
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(spacer)
	var s := UiFactory.make_label(status_txt, &"SectionLabel")
	s.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	head.add_child(s)
	body.add_child(head)
	var d := UiFactory.make_label(desc, &"RowMeta")
	d.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.add_child(d)
	var card := UiFactory.make_card(body, false, false)
	if attention:
		_apply_amber_panel(card)   # mockup grameri: vurgu kartı amber, pembe değil
	_set_mouse_ignore(body)   # tıklamalar kartın gui_input'una düşer
	return {"card": card, "title": t, "status": s, "desc": d}


# Amber vurgu paneli (SÖZ VERİLDİ satırı + vN+1 kartı): AMBER_BG zemin + 1px
# ACCENT çerçeve — creation'daki seçili-satır overridе'ıyla aynı gramer.
func _apply_amber_panel(card: PanelContainer) -> void:
	var sb := StyleBoxFlat.new()
	sb.bg_color = UiTokens.AMBER_BG
	sb.border_color = UiTokens.ACCENT
	sb.set_border_width_all(1)
	sb.set_corner_radius_all(4)
	sb.content_margin_left = 14.0
	sb.content_margin_right = 14.0
	sb.content_margin_top = 10.0
	sb.content_margin_bottom = 10.0
	card.add_theme_stylebox_override("panel", sb)


func _add_stat(row: HBoxContainer, key: String, caption: String) -> void:
	# Caption'lar önceden BÜYÜK verilir (tarihsel; factory artık UiTokens.tr_upper ile TR-güvenli).
	var cell := UiFactory.make_stat(caption, "—")
	row.add_child(cell)
	_stat_values[key] = cell.get_child(1).get_child(0) as Label


# --- repaint parçaları ---------------------------------------------------------

func _repaint_header(ver: int, sub: String) -> void:
	var type_name: String = _type_name_human(sub)
	var pname: String = String(GameState.get_flag("mvp_product_name", ""))
	_name_label.text = pname if pname != "" else type_name
	var market: String = UiTokens.tr_upper(String(GameState.get_flag("mvp_market_type", "b2c")))
	_meta_label.text = "%s · %s" % [market, _tr_upper(type_name)]
	_live_badge_label.text = "CANLI V%d" % ver
	var hs: String = ProductSystem.health_state()
	_set_dot_color(_health_dot, UiTokens.health_color(&"healthy" if hs == "saglikli" else &"warn"))
	_health_text.text = ProductUiShared.health_label(hs)


func _repaint_profile(ver: int, bugs: int) -> void:
	var vals := {}
	# Creation önizlemesiyle aynı taban ölçek: küçük ürünler dev üçgen çizmesin.
	var maxv: float = TriangleRadar.DEFAULT_MAX
	for axis in ProductUiShared.AXIS_KEYS:
		var v: float = float(GameState.get_flag("mvp_%s" % axis, 0.0))
		vals[axis] = v
		maxv = maxf(maxv, v)
	_radar.set_axes(vals, maxv)
	for axis in ProductUiShared.AXIS_KEYS:
		var bar: ProgressBar = _legend_rows[axis]["bar"]
		bar.max_value = maxv
		bar.value = float(vals[axis])
		(_legend_rows[axis]["val"] as Label).text = "+%d" % int(round(float(vals[axis])))
	var risk: String = ProductSystem.product_bug_risk()
	_risk_value.text = ProductUiShared.risk_label(risk)
	_risk_value.add_theme_color_override("font_color",
		UiTokens.NEGATIVE_BRIGHT if risk == "yuksek" else UiTokens.INK)
	# Rozetler: 2 chip — palet/metin birlikte değiştiği için yeniden kurulur
	# (liste değil; tam-ağaç rebuild sayılmaz).
	_clear(_badges_row)
	var pal: Dictionary = UiTokens.bug_severity(bugs)
	_badges_row.add_child(UiFactory.make_pill(
		"%d BUG · %s" % [bugs, ProductUiShared.trend_label(ProductSystem.bug_trend())], pal.bg, pal.fg))
	var live_days: int = max(0, GameState.day - int(GameState.get_flag("mvp_launch_day", GameState.day)))
	_badges_row.add_child(UiFactory.make_badge("V%d · %d GÜN CANLI" % [ver, live_days], &"neutral"))


func _repaint_traction() -> void:
	_traction_ready_badge.visible = GameState.phase_gate_ready
	_traction_bar.value = SalesSystem.traction_progress() * 100.0
	_traction_meta.text = "MRR %s / %s" % [
		ProductUiShared.money_tr(GameState.mrr),
		ProductUiShared.money_tr(SalesSystem.TRACTION_MRR_TARGET)]


func _repaint_stats(bugs: int) -> void:
	var raw: float = float(GameState.get_flag("mvp_stability", 0.0))
	var eff: int = int(round(QualityModel.effective_stability(raw, bugs)))
	var stab_txt := "%d / %d" % [eff, int(round(raw))]
	if _is_b2b:
		var count: int = 0
		var mrr_sum: int = 0
		for c in CustomerRegistry.get_by_market("b2b"):
			if c.status == "active":
				count += 1
				mrr_sum += c.mrr
		(_stat_values["musteri"] as Label).text = str(count)
		(_stat_values["mrr"] as Label).text = "%s /ay" % ProductUiShared.money_tr(mrr_sum)
	else:
		(_stat_values["deneyen"] as Label).text = str(int(GameState.get_flag("b2c_audience", 0)))
	(_stat_values["bugs"] as Label).text = str(bugs)
	(_stat_values["stab"] as Label).text = stab_txt


func _repaint_promises() -> void:
	var open: Array = []
	for p in PromiseRegistry.get_all():
		if p.status == "open":
			open.append(p)
	_promise_box.visible = not open.is_empty()
	if open.size() != _open_promise_count:
		_open_promise_count = open.size()
		_clear(_promise_box)
		_promise_rows.clear()
		for p in open:
			_promise_box.add_child(_make_promise_row(p))
	# Gün sayıları yerinde güncellenir (satırlar sayı değişmeden yeniden kurulmaz).
	for entry in _promise_rows:
		var days: int = max(0, int(entry["promise"].deadline_day) - GameState.day)
		(entry["label"] as Label).text = "%d gün" % days


func _make_promise_row(p) -> PanelContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	row.add_child(UiFactory.make_label("SÖZ VERİLDİ", &"SectionLabel", UiTokens.ACCENT_DEEP))
	var cname: String = "Müşteri"
	var cust = CustomerRegistry.get_customer(p.customer_id)
	if cust != null:
		cname = cust.company_name
	var mid := UiFactory.make_label("%s · %s" % [cname, B2BConstants.feature_label(p.feature_id)], &"RowMeta")
	mid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mid.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	row.add_child(mid)
	var days_lbl := UiFactory.make_label("", &"MetricValueInk")
	days_lbl.add_theme_font_size_override("font_size", 13)
	days_lbl.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(days_lbl)
	_promise_rows.append({"label": days_lbl, "promise": p})
	var card := UiFactory.make_card(row, false, false)
	_apply_amber_panel(card)   # mockup grameri: amber vurgu (CardAttention pembesi değil)
	return card


func _versions_line(current_ver: int) -> String:
	var hist: Array = GameState.get_flag("mvp_version_history", [])
	var segs: Array = []
	for e in hist:
		var v: int = int(e.get("version", 1))
		var seg: String = "v%d · %s" % [v, ProductUiShared.month_year(int(e.get("day", GameState.day)))]
		if v == current_ver:
			seg += " · CANLI"
		segs.append(seg)
	if segs.is_empty():
		# Eski save'ler (history yok): canlı sürümü launch gününden türet.
		segs.append("v%d · %s · CANLI" % [current_ver,
			ProductUiShared.month_year(int(GameState.get_flag("mvp_launch_day", GameState.day)))])
	var b: FeatureBuild = ProductSystem.get_active_build()
	var next_state: String = "GELİŞTİRMEDE" if (b != null and b.is_version_build) else "planlanmadı"
	segs.append("v%d · %s" % [current_ver + 1, next_state])
	return "SÜRÜMLER  " + " → ".join(segs)


func _repaint_action_cards(ver: int, bugs: int) -> void:
	var building: bool = ProductSystem.get_active_build() != null
	var nextv: int = ver + 1
	_v_title.text = _dev_title(nextv)
	_v_status.text = "~%d+ GÜN" % max(3, ProductSystem.estimate_build_days([], [], ""))
	_set_card_locked(_v_card, building)
	var sprinting: bool = GameState.get_flag("mvp_bug_sprint_active", false)
	_sprint_status.text = "%d BUG · ~%d GÜN" % [bugs, ProductSystem.sprint_duration_for(bugs)]
	# Kilit kuralları (eski _paint_action_card): sprint satırı sprint sürerken /
	# temizken kilitli — build SÜRERKEN AÇIK (bedel = kapasite bölünmesi).
	_set_card_locked(_sprint_card, sprinting or bugs <= 0)


func _repaint_bottom(sub: String, ver: int) -> void:
	var comp: float = _shipped_composite(sub)
	var rank: Dictionary = RivalRegistry.get_player_rank_in_startup_league(sub, comp)
	var passer: String = _rival_passed_name(sub, comp)
	_league_label.text = String(rank["text"]) + ((" · %s seni geçti." % passer) if passer != "" else "")
	_league_label.add_theme_color_override("font_color",
		UiTokens.NEGATIVE if passer != "" else UiTokens.INK_MUTED)
	var bugs_heavy: bool = ProductSystem.product_bug_risk() == "yuksek"
	_frank_line.text = ProductUiShared.frank_line(_weakest_axis_id(), ver + 1, passer, bugs_heavy)


# --- girişler ------------------------------------------------------------------

func _on_v_card_input(ev: InputEvent) -> void:
	if not _is_left_click(ev):
		return
	if ProductSystem.get_active_build() != null:
		return   # ikinci build yok — kart zaten sönük
	navigate_requested.emit("creation", {"step": 3, "v2": true})


func _on_sprint_card_input(ev: InputEvent) -> void:
	if not _is_left_click(ev):
		return
	if GameState.get_flag("mvp_bug_sprint_active", false) or _live_bugs() <= 0:
		return
	if ProductSystem.start_bug_sprint():
		repaint()


func _is_left_click(ev: InputEvent) -> bool:
	return ev is InputEventMouseButton and ev.pressed \
		and (ev as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT


# --- port edilen türetmeler (eski product_tab snapshot'ı) ----------------------

func _live_bugs() -> int:
	return int(GameState.get_flag("mvp_live_bug_count", GameState.get_flag("mvp_bug_count_at_launch", 0)))


func _shipped_composite(sub: String) -> float:
	return QualityModel.composite_quality(
		QualityModel.economy_dims_from_flags(), ProductCatalog.get_quality_axes(sub))


func _rival_passed_name(sub: String, player: float) -> String:
	# Üstteki en yakın aynı-tip STARTUP rakip — ama yalnız oyuncu startup liginin
	# ALT YARISINDAYKEN anlamlı bir "geride kaldın" sinyali (2/6 bir ürün
	# "geçilmiş" sayılmaz).
	var rank: Dictionary = RivalRegistry.get_player_rank_in_startup_league(sub, player)
	if int(rank["rank"]) <= int(ceil(float(int(rank["total"])) / 2.0)):
		return ""
	var axes: Array = ProductCatalog.get_quality_axes(sub)
	var passer: String = ""
	var best: float = INF
	for r in RivalRegistry.get_by_type(sub):
		if r.tier == "startup":
			var c: float = r.composite(axes)
			if c > player and c < best:
				best = c
				passer = r.product_name
	return passer


func _weakest_axis_id() -> String:
	# En zayıf eksen = üç mvp_* eksen flag'inin minimumu (eşitlikte
	# innovation → stability → experience sırası).
	var worst: String = "innovation"
	var worst_v: float = INF
	for axis in ProductUiShared.AXIS_KEYS:
		var v: float = float(GameState.get_flag("mvp_%s" % axis, 0.0))
		if v < worst_v:
			worst_v = v
			worst = axis
	return worst


# --- yardımcılar ----------------------------------------------------------------

func _dev_title(v: int) -> String:
	# "v2'yi geliştir" — 2..9 için ek tablosu (working; tam ünlü uyumu overkill).
	var sfx: Dictionary = {2: "yi", 3: "ü", 4: "ü", 5: "i", 6: "yı", 7: "yi", 8: "i", 9: "u"}
	return "v%d'%s geliştir" % [v, String(sfx.get(v, "i"))]


func _set_card_locked(card: PanelContainer, locked: bool) -> void:
	card.modulate = Color(1, 1, 1, 0.55 if locked else 1.0)
	card.mouse_filter = Control.MOUSE_FILTER_IGNORE if locked else Control.MOUSE_FILTER_STOP


func _set_mouse_ignore(n: Node) -> void:
	if n is Control:
		(n as Control).mouse_filter = Control.MOUSE_FILTER_IGNORE
	for c in n.get_children():
		_set_mouse_ignore(c)


func _set_dot_color(dot: Panel, c: Color) -> void:
	var sb := dot.get_theme_stylebox("panel") as StyleBoxFlat
	if sb != null:
		sb.bg_color = c


func _override_bar_fill(bar: ProgressBar, c: Color) -> void:
	# BuildProgress'in amber dolgusu → eksen rengi. Variation atandıktan SONRA.
	var fill: StyleBox = bar.get_theme_stylebox("fill")
	if fill is StyleBoxFlat:
		var f: StyleBoxFlat = fill.duplicate()
		f.bg_color = c
		bar.add_theme_stylebox_override("fill", f)


func _type_name_human(sub_type_id: String) -> String:
	if sub_type_id == "":
		return "Ürün"
	var data: Dictionary = ProductCatalog.get_sub_product_type_by_id(sub_type_id)
	if data.is_empty():
		return sub_type_id
	return String(data.get("name_human", data.get("name", sub_type_id)))


func _tr_upper(s: String) -> String:
	# Tek ev UiTokens.tr_upper'a delege (2026-07-21 sweep eki).
	return UiTokens.tr_upper(s)


func _clear(node: Node) -> void:
	for ch in node.get_children():
		node.remove_child(ch)
		ch.queue_free()
