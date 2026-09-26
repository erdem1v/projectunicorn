extends Control

# =============================================================================
# Ürün Detayı: yayındaki ürünün evi. TEK ekran; B2B/B2C panelleri `_is_b2b` üstünden
# koşullu (iki ayrı sahne birbirinden kayardı). Router add_child + setup ile kurar;
# repaint() etiketleri YERİNDE günceller.
# Yazmalar yalnız seam'lerden: SupportSystem.start_fix_run / end_fix_run,
# SalesSystem.apply_b2c_price (fiyat paneli), tab_changed.
#
# OKUMA SÖZLEŞMESİ (GDD ÜRÜN §17/§18): ham `mvp_*` bayrağı burada EKSEN olarak okunmaz.
# Üç eksen `ProductState.axis_readings()`'ten gelir (§11.3'ün 0-120 okuması); üçgen,
# legend ve DURUM hücresi aynı sonucu paylaşır, yani monitörle üçgen ayrışamaz. Destek
# sayaçları ProductState'in §8 okumalarından, bant kararı SupportSystem'den, kapasite ve
# marj InfraSystem'den (CapacityBlock) okunur; eşik ve formül burada yeniden türetilmez.
# =============================================================================

signal navigate_requested(view_id: String, args: Dictionary)

const PricingPanelScript := preload("res://scripts/tabs/product/pricing_panel.gd")

## §8.5 ısınma çizgisinin ölçek sonu, SICAK eşiğinin katı olarak. Eşikler SupportSystem'in;
## bu sabit yalnız çizginin sağ ucunu söyler (yerleşim kararı, tasarım değil).
const WARMTH_SCALE_HEADROOM := 1.5
const WARMTH_RULE_H := 3      # ısınma çizgisinin kalınlığı (px)
const WARMTH_TICK_H := 7      # 0 / ılık / sıcak / ölçek-sonu çentiklerinin boyu (px)
const WARMTH_TICK_W := 1.0

## Ölçülecek müşteri yokken basılan işaret: metin değil noktalama, anahtarı yok.
const NO_DATA_MARK := "—"

## §8.4 ret kimliği → kapalı DÜZELTME düğmesinin gerekçesi.
const FIX_REFUSAL_KEYS := {
	SupportSystem.REFUSAL_NO_BUGS: "PROD_FIX_REFUSAL_NO_BUGS",
	SupportSystem.REFUSAL_DESK_SHUT: "PROD_FIX_REFUSAL_DESK_SHUT",
	SupportSystem.REFUSAL_ALREADY_RUNNING: "PROD_FIX_REFUSAL_RUNNING",
	SupportSystem.REFUSAL_NOT_LIVE: "PROD_FIX_REFUSAL_NOT_LIVE",
}

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
# yatırımcı iştahı
var _traction_ready_badge: Control = null
var _traction_meta: Label = null
var _appetite_chip_host: HBoxContainer = null
var _stat_values: Dictionary = {}    # DURUM hücre anahtarı -> değer Label'ı
# B2B söz satırları: açık sözlerin kimlik kümesi değişince yeniden kurulur, gün sayıları yerinde.
var _promise_box: VBoxContainer = null
var _promise_rows: Array = []        # [{"label": Label, "promise": Promise}]
var _promise_key: String = ""
var _pricing: PanelContainer = null  # B2C
# DESTEK bloğu (§8): gövde her değişimde yeniden kurulur; parmak izi değişmeyen saatleri eler.
var _support_host: VBoxContainer = null
var _support_digest := ""
var _capacity: CapacityBlock = null
# sürümler + sonraki sürüm kartı
var _versions_label: Label = null
var _v_card: PanelContainer = null
var _v_title: Label = null
var _v_status: Label = null
# alt şerit
var _league_label: Label = null
var _league_strip: PanelContainer = null
var _league_icon: Label = null
var _tip_line: Label = null
var _signals: Array = []             # [Signal, Callable] çiftleri — bağla/çöz simetrik


func _ready() -> void:
	# Router setup()'ı add_child'dan SONRA çağırır: burada henüz düğüm yok, yalnız abone olunur.
	# §8/§9 sayaçları SAATLİK akar (SupportSystem.hourly_tick); kenarlar (doğrulama, koşu,
	# ısınma bandı, masa kadrosu) saat sınırını beklemesin diye ayrıca dinlenir. §17'nin
	# GÜNLÜK alanları gün TAM oturunca okunur: day_advanced tik'lerden önce atar.
	_signals = [
		[EventBus.hour_changed, _on_support_changed],
		[EventBus.bug_confirmed, _on_support_changed],
		[EventBus.fix_run_started, _on_support_changed],
		[EventBus.fix_run_finished, _on_support_changed],
		[EventBus.unconfirmed_threshold_crossed, _on_support_changed],
		[EventBus.assignment_changed, _on_support_changed],
		[EventBus.day_tick_completed, _on_day_settled],
	]
	for s in _signals:
		(s[0] as Signal).connect(s[1])


func _exit_tree() -> void:
	for s in _signals:
		if (s[0] as Signal).is_connected(s[1]):
			(s[0] as Signal).disconnect(s[1])


func _on_support_changed(_a = null, _b = null) -> void:
	if is_visible_in_tree() and ProductState.is_live():
		_repaint_support()


func _on_day_settled(_day = null) -> void:
	if is_visible_in_tree():
		repaint()


func setup(_args: Dictionary) -> void:
	_is_b2b = String(GameState.get_flag("mvp_market_type", "b2c")) == "b2b"
	_build()
	repaint()


func repaint() -> void:
	if not ProductState.is_live():
		return
	var ver: int = int(GameState.get_flag("mvp_version", 1))
	var sub: String = String(GameState.get_flag("mvp_sub_product_type_id", ""))
	var bugs: int = ProductSystem.live_bug_count()
	var readings: Dictionary = ProductState.axis_readings()
	var risk: String = ProductSystem.product_bug_risk()
	_repaint_header(ver, sub)
	_repaint_profile(ver, bugs, readings, risk)
	_repaint_traction()
	_repaint_stats(bugs, float(readings.get("stability", 0)))
	_repaint_support()
	if _is_b2b:
		_repaint_promises()
	else:
		_pricing.repaint()
	_versions_label.text = _versions_line(ver)
	# Blok kendi seam sinyallerine de abone; bu çağrı router zincirinin (sekmeye dönüş,
	# gün sonu) onu da tazelemesi için.
	_capacity.repaint()
	var building: bool = ProductSystem.get_active_build() != null
	_v_title.text = tr("PROD_DEV_VERSION").format({"version": ver + 1})
	_v_status.text = tr("PROD_ETA_DAYS").format({"n": maxi(3, ProductSystem.estimate_build_days([], [], ""))})
	_v_card.modulate.a = 0.55 if building else 1.0
	_v_card.mouse_filter = Control.MOUSE_FILTER_IGNORE if building else Control.MOUSE_FILTER_STOP
	_repaint_bottom(sub, ver, readings, risk)


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

	var cols := HBoxContainer.new()
	cols.add_theme_constant_override("separation", 14)
	root.add_child(cols)
	var columns: Array[VBoxContainer] = []
	for i in 2:
		var col := VBoxContainer.new()
		col.add_theme_constant_override("separation", 10)
		col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		cols.add_child(col)
		columns.append(col)
	_build_left_column(columns[0])
	_build_right_column(columns[1])

	# Pazar payı satırı. DİKKAT ŞERİDİ tasarımın tek uyarı biçimidir: bir rakip seni
	# geçtiğinde satır üçgen ikonlu kırmızı şerit olur; normalde kutusuz bir bilgi satırıdır.
	_league_strip = PanelContainer.new()
	_league_strip.theme_type_variation = &"AttentionStrip"
	var strip_row := HBoxContainer.new()
	strip_row.add_theme_constant_override("separation", UiTokens.SPACE_S)
	_league_strip.add_child(strip_row)
	# Uyarı üçgeni sembol yedeği fontundan bir glif (asset gerektirmez).
	_league_icon = UiFactory.make_label("⚠", &"RowMeta")
	_league_icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	strip_row.add_child(_league_icon)
	_league_label = Label.new()
	_league_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_league_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	strip_row.add_child(_league_label)
	root.add_child(_league_strip)

	# İpucu şeridi: sistem ipucu, Frank'in sözü değil (Frank Diyalogları v6, PROD_TIP_*).
	_tip_line = UiFactory.make_label("", &"QuoteSerif")
	_tip_line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	root.add_child(UiFactory.make_card(_tip_line, true))


func _build_header() -> HBoxContainer:
	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 10)
	var back := Button.new()
	back.flat = true
	back.text = tr("PROD_BACK_PORTFOLIO")
	back.pressed.connect(func() -> void: navigate_requested.emit("portfoy", {}))   # LOC-DATA route id
	header.add_child(back)
	_name_label = UiFactory.make_label("", &"NameSerif")
	_name_label.add_theme_font_size_override("font_size", 20)
	_name_label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	header.add_child(_name_label)
	_meta_label = UiFactory.make_label("", &"RowMeta")
	_meta_label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	header.add_child(_meta_label)
	var live_badge := UiFactory.make_badge("", &"positive")
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
	# ÜRÜN PROFİLİ: radar + legend + hata riski + rozetler.
	var prof := VBoxContainer.new()
	prof.add_theme_constant_override("separation", 8)
	prof.add_child(UiFactory.make_label(tr("PROD_PROFILE"), &"SectionLabel"))
	var prof_row := HBoxContainer.new()
	prof_row.add_theme_constant_override("separation", 12)
	prof.add_child(prof_row)
	_radar = TriangleRadar.new()
	_radar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	prof_row.add_child(_radar)
	var legend := VBoxContainer.new()
	legend.add_theme_constant_override("separation", 6)
	legend.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	legend.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	prof_row.add_child(legend)
	for axis in ProductUiShared.AXIS_KEYS:
		var color: Color = ProductUiShared.axis_color(axis)
		var lrow := HBoxContainer.new()
		lrow.add_theme_constant_override("separation", 6)
		lrow.add_child(UiFactory.make_dot(color, 7))
		var alabel := UiFactory.make_label(ProductUiShared.axis_label(axis), &"RowMeta", UiTokens.INK)
		alabel.custom_minimum_size = Vector2(70, 0)
		alabel.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		lrow.add_child(alabel)
		# ÖLÇEK: 100 pazar ÇITASIDIR, tavan değil; okuma onu aşar ve READING_MAX'ta kesilir.
		# Cetvel okumanın kendi tavanıdır, her yüzeyde aynı kalır.
		var abar := ProgressBar.new()
		abar.theme_type_variation = &"BuildProgress"
		abar.custom_minimum_size = Vector2(0, 6)
		abar.show_percentage = false
		abar.max_value = QualityModel.READING_MAX
		abar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		abar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		HRUiShared.override_bar_fill(abar, color)
		lrow.add_child(abar)
		var aval := UiFactory.make_label("", &"RowName")
		aval.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		lrow.add_child(aval)
		legend.add_child(lrow)
		_legend_rows[axis] = {"bar": abar, "val": aval}
	var risk_row := HBoxContainer.new()
	risk_row.add_theme_constant_override("separation", 4)
	risk_row.add_child(UiFactory.make_label(tr("PROD_BUG_RISK_CAP"), &"RowMeta"))
	_risk_value = UiFactory.make_label("", &"RowMeta")
	risk_row.add_child(_risk_value)
	prof.add_child(risk_row)
	_badges_row = HBoxContainer.new()
	_badges_row.add_theme_constant_override("separation", 6)
	prof.add_child(_badges_row)
	left.add_child(UiFactory.make_card(prof))

	# Yatırımcı iştahı: kapının sinyali, durum çipi + tek satır. Gelir çıtasının rakamı
	# hiçbir yerde basılmaz; yaklaşmayı Frank'in eşik mesajları söyler.
	var tr_body := VBoxContainer.new()
	tr_body.add_theme_constant_override("separation", 6)
	var tr_head := HBoxContainer.new()
	var tr_title := UiFactory.make_label(Fmt.upper(InvestorAppetiteUi.title_text()), &"SectionLabel")
	tr_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tr_head.add_child(tr_title)
	_appetite_chip_host = HBoxContainer.new()
	tr_head.add_child(_appetite_chip_host)
	_traction_ready_badge = UiFactory.make_badge(tr("PROD_READY_TALK_FRANK"), &"positive")
	_traction_ready_badge.visible = false
	tr_head.add_child(_traction_ready_badge)
	tr_body.add_child(tr_head)
	_traction_meta = UiFactory.make_label("", &"RowMeta")
	tr_body.add_child(_traction_meta)
	left.add_child(UiFactory.make_card(tr_body, true))

	if not _is_b2b:
		left.add_child(_status_card([
			["free_users", tr("PROD_TRYING_CAP")],
			["paying", tr("PROD_PAYING")],
			["mrr", tr("FIN_CAP_MRR")],
			["satisfaction", tr("SALES_SATISFACTION")],
			["interest", tr("PROD_INTEREST_CAP")],
			["bugs", tr("PROD_OPEN_BUGS")],
			["stab", tr("PROD_EFFECTIVE_STABILITY")],
		]))
		# DESTEK bloğu DURUM'un hemen ardında: iki kart aynı sütunda okunur (B2B'de sağda).
		left.add_child(_build_support_block())


func _build_right_column(right: VBoxContainer) -> void:
	if _is_b2b:
		right.add_child(_status_card([
			["musteri", tr("PROD_CUSTOMERS_CAP")],   # LOC-DATA stat slot id
			["mrr", tr("PROD_MRR_CONTRIB_CAP")],
			["satisfaction", tr("SALES_SATISFACTION")],
			["churn", tr("PROD_CHURN_CAP")],
			["interest", tr("PROD_INTEREST_CAP")],
			["bugs", tr("PROD_OPEN_BUGS")],
			["stab", tr("PROD_EFFECTIVE_STABILITY")],
		]))
		right.add_child(_build_support_block())
		var sales_btn := Button.new()
		sales_btn.theme_type_variation = &"CommitButton"
		sales_btn.text = tr("PROD_GO_TO_SALES")
		sales_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		sales_btn.pressed.connect(func() -> void: EventBus.tab_changed.emit("sales"))
		right.add_child(sales_btn)
		_promise_box = VBoxContainer.new()
		_promise_box.add_theme_constant_override("separation", 6)
		_promise_box.visible = false
		right.add_child(_promise_box)
	else:
		_pricing = PricingPanelScript.new()
		right.add_child(_pricing)

	_versions_label = UiFactory.make_label("", &"RowMeta")
	_versions_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	right.add_child(_versions_label)

	# KAPASİTE bloğu (§10) sarmalanmaz: tek çocuğu zaten bir kart, ikinci kart kart içinde
	# kart çizerdi.
	_capacity = CapacityBlock.new()
	_capacity.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_capacity.change_requested.connect(_on_capacity_change_requested)
	right.add_child(_capacity)

	_v_title = UiFactory.make_label("", &"NameSerif")
	_v_status = UiFactory.make_label("", &"SectionLabel")
	_v_card = _action_card(_v_title, _v_status, tr("PROD_ACTION_FEATURE_DESC"))
	_apply_amber_panel(_v_card)
	_v_card.gui_input.connect(_on_v_card_input)
	right.add_child(_v_card)

	if _is_b2b:
		# Fiyatlandır kartı İNERT: B2B'de taban fiyat/paket mekanizması yok.
		var p_card := _action_card(UiFactory.make_label(tr("PROD_ACTION_PRICE"), &"NameSerif"),
			UiFactory.make_label(tr("PROD_WITH_SALES"), &"SectionLabel"), tr("PROD_ACTION_PRICE_B2B"))
		p_card.mouse_filter = Control.MOUSE_FILTER_IGNORE
		right.add_child(p_card)


## DURUM kartı; `cells` = [[anahtar, başlık], ...]. Hücreler HFlow'da: §17'nin yedi hücresi
## iki kolonlu sayfada tek satıra sığmaz, taşan alt satıra iner.
func _status_card(cells: Array) -> PanelContainer:
	var st := VBoxContainer.new()
	st.add_theme_constant_override("separation", 8)
	st.add_child(UiFactory.make_label(tr("PROD_STATUS"), &"SectionLabel"))
	var row := HFlowContainer.new()
	row.add_theme_constant_override("h_separation", 18)
	row.add_theme_constant_override("v_separation", 10)
	st.add_child(row)
	for c in cells:
		var cell := UiFactory.make_stat(c[1], NO_DATA_MARK)
		row.add_child(cell)
		_stat_values[c[0]] = cell.get_child(1).get_child(0)
	return UiFactory.make_card(st)


func _action_card(title: Label, status: Label, desc: String) -> PanelContainer:
	var body := VBoxContainer.new()
	body.add_theme_constant_override("separation", 4)
	var head := HBoxContainer.new()
	head.add_theme_constant_override("separation", 8)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(title)
	status.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	head.add_child(status)
	body.add_child(head)
	var d := UiFactory.make_label(desc, &"RowMeta")
	d.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.add_child(d)
	HRUiShared.set_mouse_ignore(body)   # tıklamalar kartın gui_input'una düşer
	return UiFactory.make_card(body)


## Amber vurgu paneli (SÖZ VERİLDİ satırı + sonraki sürüm kartı): AMBER_BG zemin + 1px
## ACCENT çerçeve. CardAttention'ın pembesi değil.
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


# --- DESTEK bloğu (§8) ---------------------------------------------------------
# DURUM kartıyla simetrik: aynı kart kabuğu, bölüm başlığı ve sayı hücresi grameri.
# Çentik/ok/düğme sayısı duruma göre değiştiği için gövde yerinde güncellenmez, yeniden kurulur.

func _build_support_block() -> PanelContainer:
	_support_host = VBoxContainer.new()
	_support_host.add_theme_constant_override("separation", UiTokens.SPACE_M)
	return UiFactory.make_card(_support_host)


func _repaint_support() -> void:
	var incoming: int = ProductState.reports_incoming()
	var confirmed: int = ProductState.bugs_confirmed()
	var running: bool = ProductState.fix_run_active()
	var fixed: int = ProductState.fix_run_fixed()
	var desk: Array[String] = _desk_sentences()
	# Blok saat sınırında dinlenir ama saatlerin çoğu hiçbir sayıyı oynatmaz; koşulsuz yeniden
	# kurmak oyuncunun altındaki düğmeyi boş yere silerdi. Parmak izi çizilen her şeyi kapsar.
	var digest: String = "%d|%d|%d|%d|%s|%s" % [incoming, confirmed, int(running), fixed, desk[0], desk[1]]
	if digest == _support_digest:
		return
	_support_digest = digest
	ProductUiShared.clear(_support_host)
	_support_host.add_child(UiFactory.make_label(tr("PROD_SUPPORT"), &"SectionLabel"))

	# §8.1'in iki sayacı. Yön oku YALNIZ koşu sürerken: ok eğilim değil o anki İŞİN yönüdür.
	# GELEN yukarı (akış durmaz, baskı), DOĞRULANMIŞ aşağı (koşu havuzu eritiyor).
	var counters := HBoxContainer.new()
	counters.add_theme_constant_override("separation", UiTokens.SPACE_XXL)
	counters.add_child(_counter_cell(tr("PROD_REPORTS_INCOMING"), incoming, running, true))
	counters.add_child(_counter_cell(tr("PROD_BUGS_CONFIRMED"), confirmed, running, false))
	_support_host.add_child(counters)
	_support_host.add_child(_warmth_line(incoming))

	# §8.2 masa cümlesi. Boş masa küçük bir sızıntı değil TAM SIFIR üretir: cümle olumsuz
	# renkte ve altında gerekçe durur.
	var desk_col := VBoxContainer.new()
	desk_col.add_theme_constant_override("separation", UiTokens.SPACE_XXS)
	var lead_color: Color = UiTokens.negative() if desk[1] != "" else UiTokens.INK_MUTED
	for line in [[desk[0], lead_color], [desk[1], UiTokens.INK_DIM]]:
		if line[0] != "":
			var lbl := UiFactory.make_label(line[0], &"RowMeta", line[1])
			lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			desk_col.add_child(lbl)
	_support_host.add_child(desk_col)
	_support_host.add_child(_fix_run_row(running, fixed))


func _counter_cell(caption: String, value: int, running: bool, pressure: bool) -> Control:
	# UiFactory.make_stat'ın yapısı, ama delta çipi yerine şevron: gösterilecek bir sayı
	# farkı yok, yalnız yön var.
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", UiTokens.SPACE_XXS)
	col.add_child(UiFactory.make_label(Fmt.upper(caption), &"MetricCaptionInk"))
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", UiTokens.SPACE_S)
	var val := UiFactory.make_label(Fmt.group(value), &"MetricValueInk")
	val.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(val)
	if running:
		row.add_child(HRUiShared.chevron(9, UiTokens.negative() if pressure else UiTokens.positive(), pressure))
	col.add_child(row)
	return col


func _warmth_line(incoming: int) -> Control:
	# §8.5 ISINMA ÇİZGİSİ: ince kural + 0 / ılık / sıcak / ölçek-sonu çentikleri. Bandı
	# SupportSystem.warmth_band() seçer, çentikler onun sabitlerinden okunur: kopya bir
	# 20/40, eşik bir gün Ar-Ge ile oynadığında çizgiyi sessizce yalancı yapardı.
	var scale_max: float = maxf(1.0, float(SupportSystem.WARMTH_HOT_AT) * WARMTH_SCALE_HEADROOM)
	var host := Control.new()
	host.custom_minimum_size = Vector2(0, WARMTH_TICK_H + 2)
	host.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	host.mouse_filter = Control.MOUSE_FILTER_IGNORE
	host.add_child(_warmth_bar(1.0, UiTokens.SURFACE_SUNKEN))
	# Ölçeği aşan birikim en sağda DURUR: çizgiyi uzatmak sıcak bandı görünmez kılardı.
	var ratio: float = clampf(float(incoming) / scale_max, 0.0, 1.0)
	if ratio > 0.0:
		var health: StringName = {SupportSystem.BAND_HOT: &"bad", SupportSystem.BAND_WARM: &"warn"}.get(
			SupportSystem.warmth_band(), &"healthy")
		host.add_child(_warmth_bar(ratio, UiTokens.health_color(health)))
	for tick in [0.0, float(SupportSystem.WARMTH_WARM_AT), float(SupportSystem.WARMTH_HOT_AT), scale_max]:
		host.add_child(_warmth_tick(clampf(float(tick) / scale_max, 0.0, 1.0)))
	return host


func _warmth_bar(to_ratio: float, color: Color) -> Panel:
	var bar := Panel.new()
	bar.anchor_right = to_ratio
	bar.anchor_top = 0.5
	bar.anchor_bottom = 0.5
	bar.offset_top = -WARMTH_RULE_H / 2.0
	bar.offset_bottom = WARMTH_RULE_H / 2.0
	bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var sb := StyleBoxFlat.new()
	sb.bg_color = color
	sb.set_corner_radius_all(UiTokens.RADIUS_XS)
	bar.add_theme_stylebox_override("panel", sb)
	return bar


func _warmth_tick(ratio: float) -> Panel:
	var tick := Panel.new()
	tick.anchor_left = ratio
	tick.anchor_right = ratio
	# Uçtaki çentik dışarı taşmasın: sol kenar 0'da 0, 1'de −1px kayar.
	tick.offset_left = -WARMTH_TICK_W * ratio
	tick.offset_right = tick.offset_left + WARMTH_TICK_W
	tick.anchor_top = 0.5
	tick.anchor_bottom = 0.5
	tick.offset_top = -WARMTH_TICK_H / 2.0
	tick.offset_bottom = WARMTH_TICK_H / 2.0
	tick.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var sb := StyleBoxFlat.new()
	sb.bg_color = UiTokens.INK_DIM
	tick.add_theme_stylebox_override("panel", sb)
	return tick


## §8.2 masa cümlesi ve gerekçesi: [cümle, gerekçe]; gerekçe yalnız boş masada dolu.
## Hesap sahipliği ile destek masası iki ayrı görevdir (JOB_ACCOUNTS / JOB_SUPPORT) ve
## temsilci varsayılan olarak ilkine doğar; boş masa bu yüzden hangi görevin boş olduğunu
## ve onu kimin doldurabileceğini söylemek zorunda.
func _desk_sentences() -> Array[String]:
	var roster: Array[String] = []
	for c in SupportSystem.desk_roster():
		roster.append(c.character_name)   # özel ad — lokalize edilmez
	if not roster.is_empty():
		# Pasif kurucu roster'ın içinde; ayıran, masaya ATANMIŞ başka birinin olup olmadığı.
		# Kimse atanmamışsa kaybedilen bir şey yok, masa çalışıyor: cümle nötr.
		if SupportSystem.founder_passive_care() and HRSystem.assigned_to_job(HRConstants.JOB_SUPPORT).is_empty():
			return [tr("PROD_DESK_FOUNDER_PASSIVE"), ""]
		return [tr("PROD_DESK_STAFFED").format({"names": ", ".join(roster)}), ""]
	# Masayı taşıyabilecek ama başka görevdeki herkes. Kurucu sayılmaz: masadaki yeri bir
	# atama değil, işsiz olmasının kendisidir.
	var eligible: Array[String] = []
	for c in CharacterRegistry.get_employees():
		if c.status == HRConstants.STATUS_ACTIVE and not c.assigned_job_ids.has(HRConstants.JOB_SUPPORT) \
				and HRConstants.can_hold_job(c.role, HRConstants.JOB_SUPPORT, c.category):
			eligible.append(c.character_name)   # özel ad — lokalize edilmez
	if not eligible.is_empty():
		return [tr("PROD_DESK_EMPTY"), tr("PROD_DESK_ACCOUNTS_ONLY").format({"names": ", ".join(eligible)})]
	# Canlı üründe boş masa, kurucunun başka bir işle meşgul olduğu demektir.
	return [tr("PROD_DESK_EMPTY"), tr("PROD_DESK_FOUNDER_BUSY").format({"what": HRSystem.founder_task_label()})]


func _fix_run_row(running: bool, fixed: int) -> Control:
	# §8.4 KAPISI. Koşu sürerken düğme BİTİRME eylemine döner (koşu iki yönlü bir anahtar,
	# iki ayrı karar değil) ve yanında o koşuda çözülenlerin sayısı durur.
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", UiTokens.SPACE_M)
	if running:
		row.add_child(HRUiShared.action_button(tr("PROD_FIX_RUN_END"), _on_fix_run_end, true))
		var chip := UiFactory.make_badge(tr("PROD_FIX_RUN_FIXED_N").format({"n": fixed}), &"positive")
		chip.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		row.add_child(chip)
		return row
	var refusal: String = SupportSystem.fix_run_refusal()
	if refusal == "":
		row.add_child(HRUiShared.action_button(tr("PROD_FIX_RUN_START"), _on_fix_run_start, true))
	else:
		# Kapalı düğme + gerekçe; ret kimliği motordan gelir, UI koşulu yeniden yazmaz.
		row.add_child(HRUiShared.disabled_button(tr("PROD_FIX_RUN_START"), tr(FIX_REFUSAL_KEYS[refusal])))
	return row


func _on_fix_run_start() -> void:
	if SupportSystem.start_fix_run():
		repaint()


func _on_fix_run_end() -> void:
	SupportSystem.end_fix_run()
	repaint()


func _on_capacity_change_requested() -> void:
	# §10: sağlayıcı canlıda her an değiştirilebilir. Kararın ekranı yayın akışının ALTYAPI
	# adımıdır ve tek başına açılır; tek-adım modu hiçbir şey yayınlamaz.
	PublishFlow.open(PublishFlow.STEP_INFRA)


# --- repaint parçaları ---------------------------------------------------------

func _repaint_header(ver: int, sub: String) -> void:
	var type_name: String = ProductCatalog.type_name(sub) if sub != "" else tr("PRODUCT_FALLBACK_NAME")
	var pname: String = String(GameState.get_flag("mvp_product_name", ""))
	_name_label.text = pname if pname != "" else type_name
	_meta_label.text = "%s · %s" % [Fmt.upper(String(GameState.get_flag("mvp_market_type", "b2c"))), Fmt.upper(type_name)]
	_live_badge_label.text = tr("BUILD_LIVE_VERSION").format({"n": ver})
	var hs: String = ProductSystem.health_state()
	(_health_dot.get_theme_stylebox("panel") as StyleBoxFlat).bg_color = UiTokens.health_color(
		&"healthy" if hs == "saglikli" else &"warn")   # LOC-DATA health band id
	_health_text.text = ProductUiShared.health_label(hs)


func _repaint_profile(ver: int, bugs: int, readings: Dictionary, risk: String) -> void:
	_radar.set_axes(readings, QualityModel.READING_MAX)
	for axis in ProductUiShared.AXIS_KEYS:
		(_legend_rows[axis]["bar"] as ProgressBar).value = float(readings.get(axis, 0))
		# Basılan bir OKUMA (mutlak sayı), özelliklerin katkısı değil: işaretsiz.
		(_legend_rows[axis]["val"] as Label).text = str(int(readings.get(axis, 0)))
	_risk_value.text = ProductUiShared.risk_label(risk)
	_risk_value.add_theme_color_override("font_color",
		UiTokens.negative_bright() if risk == "yuksek" else UiTokens.INK)   # LOC-DATA risk band id
	# İki rozet: palet ve metin birlikte değiştiği için yeniden kurulur.
	ProductUiShared.clear(_badges_row)
	var pal: Dictionary = UiTokens.bug_severity(bugs)
	_badges_row.add_child(UiFactory.make_pill(tr("PROD_BUGS_TREND").format(
		{"bugs": bugs, "trend": ProductUiShared.trend_label(ProductSystem.bug_trend())}), pal.bg, pal.fg))
	# §17: rozet SÜRÜM yaşını söyler (her yayında sıfırlanır), ürün yaşını değil.
	_badges_row.add_child(UiFactory.make_badge(tr("PROD_LIVE_DAYS").format(
		{"version": ver, "days": ProductState.version_age_days()}), &"neutral"))


func _repaint_traction() -> void:
	_traction_ready_badge.visible = GameState.phase_gate_ready
	var sig: Dictionary = PhaseGateSystem.series_a_signal()
	_traction_meta.text = InvestorAppetiteUi.line(sig)
	ProductUiShared.clear(_appetite_chip_host)
	_appetite_chip_host.add_child(InvestorAppetiteUi.chip(String(sig.get("state", "closed"))))


func _repaint_stats(bugs: int, stab_reading: float) -> void:
	if _is_b2b:
		var accounts: Array[Customer] = CustomerRegistry.get_by_market("b2b")
		var n: int = accounts.size()
		var mrr_sum: int = 0
		var sat_sum: int = 0
		var churning: int = 0
		for c in accounts:
			mrr_sum += c.mrr
			sat_sum += c.satisfaction
			# §17 churn: sayacı işleyen hesapların payı; −1 kapalı, 0 dahil her değer "gidiyor".
			if c.churn_countdown >= 0:
				churning += 1
		_stat_values["musteri"].text = str(n)   # LOC-DATA stat slot id
		_stat_values["mrr"].text = tr("PROD_PER_MONTH").format({"amount": Fmt.money_exact(mrr_sum)})
		_stat_values["satisfaction"].text = NO_DATA_MARK if n == 0 else str(roundi(float(sat_sum) / n))
		_stat_values["churn"].text = NO_DATA_MARK if n == 0 else Fmt.percent(round(100.0 * churning / n), 0)
	else:
		# Satış'ın TEK toplu B2C kaydı: canlı MRR ve memnuniyet oradan. GameState.mrr değil
		# (bütün müşterilerin toplamı), fiyat panelinin projeksiyonu da değil.
		var base: Customer = CustomerRegistry.get_customer(SalesSystem.B2C_USERBASE_ID)
		_stat_values["free_users"].text = Fmt.group(ProductUiShared.b2c_free_users())
		_stat_values["paying"].text = Fmt.group(CustomerRegistry.get_total_users())
		_stat_values["mrr"].text = tr("PROD_PER_MONTH").format(
			{"amount": Fmt.money_exact(base.mrr if base != null else 0)})
		_stat_values["satisfaction"].text = str(base.satisfaction) if base != null else NO_DATA_MARK
	# §9 ilgi 0-100 talebin kendi ölçeğidir, yüzde değil.
	_stat_values["interest"].text = str(roundi(ProductRead.interest()))
	_stat_values["bugs"].text = str(bugs)
	# Etkin (hata-aşınmalı, ekonominin kullandığı) / okuma yan yana.
	_stat_values["stab"].text = "%d / %d" % [
		roundi(QualityModel.effective_stability(stab_reading, bugs)), roundi(stab_reading)]


func _repaint_promises() -> void:
	var open: Array[Promise] = []
	var ids: Array[String] = []
	for p in PromiseRegistry.get_all():
		if p.status == "open":
			open.append(p)
			ids.append(p.id)
	_promise_box.visible = not open.is_empty()
	var key: String = ",".join(ids)
	if key != _promise_key:
		_promise_key = key
		ProductUiShared.clear(_promise_box)
		_promise_rows.clear()
		for p in open:
			_promise_box.add_child(_make_promise_row(p))
	for entry in _promise_rows:
		(entry["label"] as Label).text = tr("PROD_DAYS").format(
			{"n": maxi(0, int(entry["promise"].deadline_day) - GameState.day)})


func _make_promise_row(p: Promise) -> PanelContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	row.add_child(UiFactory.make_label(tr("PROD_PROMISED"), &"SectionLabel", UiTokens.ACCENT_DEEP))
	var cust: Customer = CustomerRegistry.get_customer(p.customer_id)
	var cname: String = cust.display_name() if cust != null else tr("SALES_CUSTOMER")
	var mid := UiFactory.make_label("%s · %s" % [cname, B2BConstants.feature_label(p.feature_id)], &"RowMeta")
	mid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mid.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	row.add_child(mid)
	var days_lbl := UiFactory.make_label("", &"RowName")
	days_lbl.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(days_lbl)
	_promise_rows.append({"label": days_lbl, "promise": p})
	var card := UiFactory.make_card(row)
	_apply_amber_panel(card)
	return card


func _versions_line(current_ver: int) -> String:
	var segs: Array[String] = []
	for e in GameState.get_flag("mvp_version_history", []):
		var v: int = int(e.get("version", 1))
		var seg: String = "v%d · %s" % [v, ProductUiShared.month_year(int(e.get("day", GameState.day)))]
		if v == current_ver:
			seg += tr("PROD_LIVE_SUFFIX")
		segs.append(seg)
	if segs.is_empty():
		# Geçmişi olmayan durum (fikstürler): canlı sürümü ilk yayın gününden türet.
		segs.append(tr("PROD_VERSION_LIVE").format({"version": current_ver,
			"date": ProductUiShared.month_year(int(GameState.get_flag("mvp_launch_day", GameState.day)))}))
	var b: FeatureBuild = ProductSystem.get_active_build()
	var next_state: String = tr("PROD_IN_DEVELOPMENT") if (b != null and b.is_version_build) else tr("PROD_UNPLANNED")
	segs.append("v%d · %s" % [current_ver + 1, next_state])
	return tr("PROD_VERSIONS") + " " + " → ".join(segs)


func _repaint_bottom(sub: String, ver: int, readings: Dictionary, risk: String) -> void:
	var passer: String = _rival_passed_name(sub)
	var passed: bool = passer != ""
	# Pazar payı: oyuncunun MRR'dan türeyen dilimi + hemen üstündeki adlandırılmış rakibin
	# dilimi, kıymık küçükken de bir sonraki basamak görünsün. "Seni geçti" eki ayrı ve
	# kalite-bazlı bir sinyaldir.
	var snap: Dictionary = RivalRegistry.get_market_snapshot(sub)
	var player: float = float(snap["player_pct"])
	var line: String = tr("PROD_MARKET_SHARE").format({"share": RivalRegistry.format_share(player)})
	# Liste pay-azalan sıralı: sondan yürümek ilk "üstteki basamağı" verir.
	var rivals: Array = snap["rivals"]
	for i in range(rivals.size() - 1, -1, -1):
		var share: float = float(rivals[i]["share_pct"])
		if share > player:
			line += " · %s %s" % [String(rivals[i]["name"]), RivalRegistry.format_share(share)]
			break
	if passed:
		line += tr("PROD_RIVAL_PASSED").format({"rival": passer})
	_league_label.text = line
	_league_label.add_theme_color_override("font_color", UiTokens.negative() if passed else UiTokens.INK_MUTED)
	# Şerit kutusu yalnız gerçek uyarıda çizilir; hep görünseydi "her şey yolunda" da kırmızı
	# çerçevede dururdu.
	_league_strip.self_modulate.a = 1.0 if passed else 0.0
	_league_icon.visible = passed
	_league_icon.add_theme_color_override("font_color", UiTokens.negative())
	# En zayıf eksen üç OKUMANIN minimumu (eşitlikte AXIS_KEYS sırası): şerit oyuncunun
	# üçgende gördüğü ekseni adlandırmalı.
	var weakest: String = ProductUiShared.AXIS_KEYS[0]
	for axis in ProductUiShared.AXIS_KEYS:
		if float(readings.get(axis, 0)) < float(readings.get(weakest, 0)):
			weakest = axis
	_tip_line.text = ProductUiShared.product_tip(weakest, ver + 1, passer, risk == "yuksek")   # LOC-DATA risk band id


## Üstteki en yakın aynı-tip STARTUP rakip; yalnız oyuncu startup liginin ALT YARISINDAYKEN
## anlamlı bir "geride kaldın" sinyali (2/6 bir ürün "geçilmiş" sayılmaz).
func _rival_passed_name(sub: String) -> String:
	var axes: Array = ProductCatalog.get_quality_axes(sub)
	var player: float = QualityModel.composite_quality(QualityModel.economy_dims_from_flags(), axes)
	var rank: Dictionary = RivalRegistry.get_player_rank_in_startup_league(sub, player)
	if int(rank["rank"]) <= ceili(int(rank["total"]) / 2.0):
		return ""
	var passer: String = ""
	var best: float = INF
	for r in RivalRegistry.get_by_type(sub):
		if r.tier == "startup":
			var c: float = r.composite(axes)
			if c > player and c < best:
				best = c
				passer = r.product_name
	return passer


# --- girişler ------------------------------------------------------------------

func _on_v_card_input(ev: InputEvent) -> void:
	var mb := ev as InputEventMouseButton
	# Build sürerken kart zaten sönük; ikinci build yok.
	if mb != null and mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT \
			and ProductSystem.get_active_build() == null:
		navigate_requested.emit("creation", {"step": 3, "v2": true})
