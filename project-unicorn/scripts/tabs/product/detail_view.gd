extends Control

# =============================================================================
# Ürün Detayı görünümü (Product Tab Rev3, Step 9 — post-ship ürün evi).
# TEK ekran; B2B/B2C panelleri `_is_b2b` üstünden koşullu (iki ayrı sahne fork
# drift'i yeniden getirirdi). Router load()+new()+add_child+setup ile kurar;
# repaint() her repaint sinyalinde etiketleri YERİNDE günceller — söz satırları
# yalnız açık-söz sayısı değişince yeniden kurulur.
# Yazmalar yalnız seam'lerden: SupportSystem.start_fix_run / end_fix_run,
# apply_b2c_price (panel içinde), tab_changed. Liglig/Frank/composite/rival-geçti
# mantığı eski product_tab snapshot'ından port edildi.
#
# OKUMA SÖZLEŞMESİ (GDD ÜRÜN rev 6.1 §17/§18): ham `mvp_*` bayrağı BU DOSYADA
# EKSEN OLARAK OKUNMAZ. Üç eksen de `ProductState.axis_readings()` üzerinden gelir
# (§11.3'ün 0-120 okuması) — üçgen, legend ve DURUM hücresi aynı çağrıyı paylaşır,
# yani monitörle üçgen ayrışamaz. Destek sayaçları ProductState'in §8 okumalarından,
# bant kararı SupportSystem'den, kapasite/marj InfraSystem'den (CapacityBlock içinde)
# okunur; hiçbir eşik ve hiçbir formül burada yeniden türetilmez.
# =============================================================================

signal navigate_requested(view_id: String, args: Dictionary)

const PricingPanelScript := preload("res://scripts/tabs/product/pricing_panel.gd")

## §8.5 ısınma çizgisinin ölçek sonu, SICAK eşiğinin katı olarak. Eşiklerin kendisi
## SupportSystem'in (20 / 40) ve buradan YENİDEN TÜRETİLMEZ — bu sabit yalnız çizginin
## sağ ucunun nerede biteceğini söyler, yani bir tasarım değil bir yerleşim kararıdır.
const WARMTH_SCALE_HEADROOM := 1.5
const WARMTH_RULE_H := 3      # ısınma çizgisinin kalınlığı (px)
const WARMTH_TICK_H := 7      # 0 / ılık / sıcak / ölçek-sonu çentiklerinin boyu (px)
const WARMTH_TICK_W := 1.0

# Eksen renk üçlüsü tek kaynaktan (ProductUiShared.axis_color) — creation
# önizlemesiyle aynı legend renkleri. Sabit kopya EMEKLİ: renk körü paleti
# "stability"yi çalışma zamanında çevirir, const bir kopya ilk renge çakılırdı.

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
var _appetite_chip_host: HBoxContainer = null   # yatırımcı iştahı durum çipi (her boyamada yeniden kurulur)
# DURUM stat hücreleri (key -> value Label)
var _stat_values: Dictionary = {}
# B2B söz satırları
var _promise_box: VBoxContainer = null
var _promise_rows: Array = []        # [{"label": Label, "promise": Promise}]
var _open_promise_count: int = -1
# B2C fiyat paneli
var _pricing: PanelContainer = null
# DESTEK bloğu (§8) — gövde her boyamada yerinde yeniden kurulur (CapacityBlock ile
# aynı gerekçe: blokta tutulan durum yok, tam yeniden çizim en ucuz doğru yol).
var _support_host: VBoxContainer = null
var _support_digest := ""             # son çizilen destek durumunun parmak izi
# KAPASİTE bloğu (§10) — kendi seam sinyallerine kendisi abone; buradan yalnız
# repaint zinciri iner.
var _capacity: CapacityBlock = null
# sürümler + aksiyon kartları
var _versions_label: Label = null
var _v_card: PanelContainer = null
var _v_title: Label = null
var _v_status: Label = null
# alt şerit
var _league_label: Label = null
var _league_strip: PanelContainer = null
var _league_icon: Control = null
var _tip_line: Label = null
# [Signal, Callable] çiftleri — bağlan/çöz simetrik (TECH_SPEC §13.3).
var _signals: Array = []


func _ready() -> void:
	# DİKKAT: router add_child'dan SONRA setup() çağırıyor, yani burada henüz hiçbir
	# düğüm yok. Bu yüzden _ready YALNIZ abone olur, boyamaz; her handler kendi
	# null/görünürlük kapısını taşır.
	#
	# §8/§9 sayaçları SAATLİK akar (SupportSystem.hourly_tick), gün sınırında değil —
	# gün-sonu kancasıyla beslenen bir DESTEK bloğu 23 saat bayat kalırdı. Kenarlar
	# (doğrulama, koşu, ısınma bandı, masa kadrosu) ayrıca dinlenir ki saat sınırını
	# beklemeden düşsünler.
	_signals = [
		[EventBus.hour_changed, _on_support_changed],
		[EventBus.bug_confirmed, _on_support_changed],
		[EventBus.fix_run_started, _on_support_changed],
		[EventBus.fix_run_finished, _on_support_changed],
		[EventBus.unconfirmed_threshold_crossed, _on_support_changed],
		[EventBus.assignment_changed, _on_support_changed],
		# §17'nin GÜNLÜK alanları (sürüm yaşı, ilgi, memnuniyet, churn) gün TAM
		# oturduktan sonra okunur — day_advanced tik'lerden ÖNCE atıyor ve dünkü
		# durumu bastırırdı (day_tick_completed'ın kendi başlığındaki gerekçe).
		[EventBus.day_tick_completed, _on_day_settled],
	]
	for s in _signals:
		(s[0] as Signal).connect(s[1])


func _exit_tree() -> void:
	for s in _signals:
		if (s[0] as Signal).is_connected(s[1]):
			(s[0] as Signal).disconnect(s[1])


func _on_support_changed(_a = null, _b = null) -> void:
	if _support_host == null or not is_visible_in_tree():
		return
	_repaint_support()


func _on_day_settled(_day = null) -> void:
	if not is_visible_in_tree():
		return
	repaint()


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
	_repaint_support()
	if _is_b2b:
		_repaint_promises()
	elif _pricing != null:
		_pricing.repaint()
	_versions_label.text = _versions_line(ver)
	if _capacity != null:
		# Blok kendi seam sinyallerine zaten abone; bu çağrı router zincirinin
		# (sekmeye dönüş, gün sonu) blok'u da tazelemesi için — ikisi aynı gövdeye iner.
		_capacity.repaint()
	_repaint_action_cards(ver)
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

	# Alt şerit (tam genişlik): pazar payı satırı + Frank.
	# DİKKAT ŞERİDİ (mockup 4a — dosyadaki TEK uyarı biçimi ve kilitli reçetenin
	# uyarı grameri): bir rakip seni geçtiğinde satır çıplak kırmızı metin DEĞİL,
	# üçgen ikonlu kırmızı şerit olur. Şerit yalnız o durumda görünür; normalde
	# etiket sade bir bilgi satırıdır ve kutusuz kalır.
	_league_strip = PanelContainer.new()
	_league_strip.theme_type_variation = &"AttentionStrip"
	var strip_row := HBoxContainer.new()
	strip_row.add_theme_constant_override("separation", UiTokens.SPACE_S)
	# Uyarı üçgeni. Mockup inline SVG kullanıyor; burada sembol yedeği
	# (NotoSansSymbols2) üzerinden glif — ekstra asset gerektirmiyor ve renk
	# semantik erişimciden geliyor.
	_league_icon = UiFactory.make_label("⚠", &"RowMeta", UiTokens.negative())
	_league_icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	strip_row.add_child(_league_icon)
	_league_label = Label.new()
	_league_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_league_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	strip_row.add_child(_league_label)
	_league_strip.add_child(strip_row)
	root.add_child(_league_strip)
	root.add_child(_build_tip_strip())


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
	var live_badge := UiFactory.make_badge(tr("BUILD_LIVE_VERSION").format({"n": 1}), &"positive")
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
	prof.add_child(UiFactory.make_label(tr("PROD_PROFILE"), &"SectionLabel"))
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
		lrow.add_child(UiFactory.make_dot(ProductUiShared.axis_color(String(axis)), 7))
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
		_override_bar_fill(abar, ProductUiShared.axis_color(String(axis)))
		lrow.add_child(abar)
		var aval := UiFactory.make_label("+0", &"RowName")
		aval.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		lrow.add_child(aval)
		legend.add_child(lrow)
		_legend_rows[axis] = {"bar": abar, "val": aval}
	prof_row.add_child(legend)
	prof.add_child(prof_row)
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

	# Traction şeridi.
	var tr_body := VBoxContainer.new()
	tr_body.add_theme_constant_override("separation", 6)
	var tr_head := HBoxContainer.new()
	# "Yatırımcı iştahı" (Kalibrasyon Turu A §3): kapının sinyali — durum çipi + çubuk + tek
	# satır; gelir çıtasının rakamı hiçbir yerde basılmaz (yönetmen kararı).
	var tr_title := UiFactory.make_label(UiTokens.tr_upper(InvestorAppetiteUi.title_text()), &"SectionLabel")
	tr_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tr_head.add_child(tr_title)
	_appetite_chip_host = HBoxContainer.new()
	tr_head.add_child(_appetite_chip_host)
	_traction_ready_badge = UiFactory.make_badge(tr("PROD_READY_TALK_FRANK"), &"positive")
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
		st.add_child(UiFactory.make_label(tr("PROD_STATUS"), &"SectionLabel"))
		st.add_child(_stat_row([
			# §17 alan seti. "deneyen" ADI da emekli: sayı artık kitle DEĞİL,
			# kitleden ödeyeni düşen ÜCRETSİZ kullanıcıdır (§3'ün yeniden adlandırması
			# yalnız etiketi değil, hücrenin ne saydığını da değiştiriyor).
			["free_users", tr("PROD_TRYING_CAP")],   # LOC-DATA stat slot id
			["paying", tr("PROD_PAYING")],
			["mrr", tr("FIN_CAP_MRR")],
			["satisfaction", tr("SALES_SATISFACTION")],
			["interest", tr("PROD_INTEREST_CAP")],
			["bugs", tr("PROD_OPEN_BUGS")],
			["stab", tr("PROD_EFFECTIVE_STABILITY")],
		]))
		left.add_child(UiFactory.make_card(st))
		# [B2C] DESTEK bloğu DURUM'un hemen ardında — iki kart simetriktir ve aynı
		# sütunda yan yana okunur (B2B'de ikisi de sağ sütunda, aynı sırayla).
		left.add_child(_build_support_block())


func _build_right_column(right: VBoxContainer) -> void:
	if _is_b2b:
		# DURUM kartı İLK.
		var st := VBoxContainer.new()
		st.add_theme_constant_override("separation", 8)
		st.add_child(UiFactory.make_label(tr("PROD_STATUS"), &"SectionLabel"))
		st.add_child(_stat_row([
			["musteri", tr("PROD_CUSTOMERS_CAP")],   # LOC-DATA stat slot id
			["mrr", tr("PROD_MRR_CONTRIB_CAP")],   # LOC-DATA stat slot id
			["satisfaction", tr("SALES_SATISFACTION")],
			["churn", tr("PROD_CHURN_CAP")],
			["interest", tr("PROD_INTEREST_CAP")],
			["bugs", tr("PROD_OPEN_BUGS")],
			["stab", tr("PROD_EFFECTIVE_STABILITY")],
		]))
		right.add_child(UiFactory.make_card(st))
		# DESTEK bloğu DURUM'un hemen ardında (B2C'de sol sütunda, aynı sırayla).
		right.add_child(_build_support_block())
		# Sales CTA.
		var sales_btn := Button.new()
		sales_btn.theme_type_variation = &"CommitButton"
		sales_btn.text = tr("PROD_GO_TO_SALES")
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

	# KAPASİTE bloğu (§10). SARMALANMAZ: kök bir VBox ama tek çocuğu zaten CardPanel'li
	# bir PanelContainer (blok kendi başlığında bunu söylüyor) — ikinci bir kart, kart
	# içinde kart çizerdi.
	_capacity = CapacityBlock.new()
	_capacity.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_capacity.change_requested.connect(_on_capacity_change_requested)
	right.add_child(_capacity)

	# Aksiyon kartları.
	var v_parts := _make_action_card("", "", tr("PROD_ACTION_FEATURE_DESC"), true)
	_v_card = v_parts["card"]
	_v_title = v_parts["title"]
	_v_status = v_parts["status"]
	_v_card.gui_input.connect(_on_v_card_input)
	right.add_child(_v_card)

	# "Sertleştir / Hata sprinti" kartı EMEKLİ (rev 6.1 §8). Yerini DESTEK bloğunun
	# DÜZELTME KOŞUSU kapısı aldı: eski kart sabit süreli bir sprint satın alıyordu,
	# yeni kapı ise oyuncunun istediği an bitirdiği bir koşudur ve masadaki kadroya
	# bağlıdır. İkisi aynı anda dursaydı aynı hata havuzuna iki ayrı çözüm kanalı
	# açılırdı. `ProductSystem.start_bug_sprint` bu dosyadan artık çağrılmıyor.

	if _is_b2b:
		# Fiyatlandır kartı: INERT — B2B'de taban fiyat/paket mekanizması yok.
		var p_parts := _make_action_card(tr("PROD_ACTION_PRICE"), tr("PROD_WITH_SALES"), tr("PROD_ACTION_PRICE_B2B"), false)
		var p_card: PanelContainer = p_parts["card"]
		p_card.mouse_filter = Control.MOUSE_FILTER_IGNORE
		right.add_child(p_card)


func _build_tip_strip() -> PanelContainer:
	# FRANK IS OFF THIS SURFACE (Frank v6, surface 21) - the one place he is removed rather
	# than rewritten. The three sentences stay; the "FK" avatar and the "FRANK" label are gone.
	# The measure the document uses is whether he has a stake in the moment: this strip is
	# derived from bug risk and the weakest axis, repaints on every visit to the page, and
	# nothing about it is his. It is a system tip and now reads as one.
	var fv := VBoxContainer.new()
	fv.add_theme_constant_override("separation", 2)
	fv.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_tip_line = UiFactory.make_label("", &"QuoteSerif")
	_tip_line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	fv.add_child(_tip_line)
	return UiFactory.make_card(fv, true)


# --- DESTEK bloğu (§8) ---------------------------------------------------------
# DURUM kartıyla SİMETRİK: aynı kart kabuğu, aynı bölüm başlığı, aynı sayı hücresi
# grameri. Yeni olan tek şey içerik — bir çizgi, bir cümle ve bir kapı.
#
# GÖVDE DURUM DEĞİŞİNCE YENİDEN KURULUR (CapacityBlock'un gerekçesiyle aynı yerden
# başlar): blokta tutulan durum yok, çentik/ok/düğme sayısı duruma göre değişiyor ve
# tam yeniden çizim yerinde-güncellemeden hem ucuz hem daha az kırılgan. Tek fark bir
# parmak izi kapısı — bu blok SAAT sınırında dinleniyor ve saatlerin çoğu hiçbir sayıyı
# oynatmıyor.

func _build_support_block() -> PanelContainer:
	_support_host = VBoxContainer.new()
	_support_host.add_theme_constant_override("separation", UiTokens.SPACE_M)
	_support_digest = ""
	return UiFactory.make_card(_support_host)


func _repaint_support() -> void:
	if _support_host == null:
		return
	# Canlı ürün yoksa destek edilecek bir şey de yok — sayaçlar 0 basmaz, blok susar.
	if not ProductState.is_live():
		_clear(_support_host)
		_support_digest = ""
		return
	var incoming: int = ProductState.reports_incoming()
	var confirmed: int = ProductState.bugs_confirmed()
	var running: bool = ProductState.fix_run_active()
	var roster: String = _desk_names()
	# SAATLİK TETİK, DEĞİŞİNCE ÇİZİM. Blok saat sınırında dinleniyor (sayaçlar orada
	# akıyor) ama saatlerin çoğu hiçbir sayıyı oynatmıyor; koşulsuz yeniden kurmak
	# oyuncunun altındaki düğmeyi boş yere silip yeniden yaratırdı.
	var digest: String = "%d|%d|%d|%d|%s|%s" % [incoming, confirmed, int(running),
		ProductState.fix_run_fixed(), SupportSystem.warmth_band(), roster]
	if digest == _support_digest and _support_host.get_child_count() > 0:
		return
	_support_digest = digest
	_clear(_support_host)

	_support_host.add_child(UiFactory.make_label(tr("PROD_SUPPORT"), &"SectionLabel"))

	# §8.1'in İKİ MÜHÜRLÜ SAYACI. Yön oku YALNIZ koşu sürerken çizilir, çünkü ok bir
	# eğilim değil o anki İŞİN yönüdür: GELEN yukarı (akış durmaz — baskı), DOĞRULANMIŞ
	# aşağı (koşu havuzu eritiyor — kazanılan iş).
	var counters := HBoxContainer.new()
	counters.add_theme_constant_override("separation", UiTokens.SPACE_XXL)
	counters.add_child(_counter_cell(tr("PROD_REPORTS_INCOMING"), incoming, running, true))
	counters.add_child(_counter_cell(tr("PROD_BUGS_CONFIRMED"), confirmed, running, false))
	_support_host.add_child(counters)

	_support_host.add_child(_warmth_line(incoming))
	_support_host.add_child(_desk_line(roster))
	_support_host.add_child(_fix_run_row(running))


func _counter_cell(caption: String, value: int, running: bool, pressure: bool) -> Control:
	# UiFactory.make_stat'ın yapısı, ama delta ÇİPİ yerine şevron: make_stat'ın çipi
	# işaretli bir SAYI taşır ve burada gösterilecek bir delta yok — yalnız yön var.
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", UiTokens.SPACE_XXS)
	col.add_child(UiFactory.make_label(UiTokens.tr_upper(caption), &"MetricCaptionInk"))
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", UiTokens.SPACE_S)
	var val := UiFactory.make_label(Fmt.group(value), &"MetricValueInk")
	val.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(val)
	if running:
		# İşaret → renk kararı token erişimcisinden; renk körü paleti bedavaya gelsin.
		row.add_child(HRUiShared.chevron(9,
			UiTokens.negative() if pressure else UiTokens.positive(), pressure))
	col.add_child(row)
	return col


func _warmth_line(incoming: int) -> Control:
	# §8.5 ISINMA ÇİZGİSİ: ince bir kural + 0 / ılık / sıcak / ölçek-sonu çentikleri.
	# EŞİK BURADA YOK. Rengin bandını `SupportSystem.warmth_band()` seçer; çentiklerin
	# NEREYE düşeceği için o modülün kendi sabitleri okunur (kopya bir 20/40 yazmak,
	# eşik bir gün Ar-Ge düğümüyle oynadığında çizgiyi sessizce yalancı yapardı).
	var scale_max: float = maxf(1.0, float(SupportSystem.WARMTH_HOT_AT) * WARMTH_SCALE_HEADROOM)
	var host := Control.new()
	host.custom_minimum_size = Vector2(0, WARMTH_TICK_H + 2)
	host.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	host.mouse_filter = Control.MOUSE_FILTER_IGNORE
	# Ray tam genişlik; dolgu GELEN kadar. Ölçeği aşan birikim en sağda DURUR —
	# çizgiyi uzatmak, sıcak bandın kendisini görünmez kılardı (kapasite çubuğunun
	# %100'de dolu durma kararıyla aynı gramer).
	host.add_child(_warmth_bar(0.0, 1.0, UiTokens.SURFACE_SUNKEN))
	var ratio: float = clampf(float(incoming) / scale_max, 0.0, 1.0)
	if ratio > 0.0:
		host.add_child(_warmth_bar(0.0, ratio, _warmth_color()))
	for tick in [0.0, float(SupportSystem.WARMTH_WARM_AT), float(SupportSystem.WARMTH_HOT_AT), scale_max]:
		host.add_child(_warmth_tick(clampf(float(tick) / scale_max, 0.0, 1.0)))
	return host


func _warmth_bar(from_ratio: float, to_ratio: float, color: Color) -> Panel:
	var bar := Panel.new()
	bar.anchor_left = from_ratio
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


func _warmth_color() -> Color:
	# Bant kimliği → sağlık rengi. `if` zinciri, `match` DEĞİL: match deseni derleme
	# zamanı sabiti ister ve bu üç ad başka bir sınıfın const'ıdır (CapacityBlock'ta
	# aynı tuzak yazılı).
	var band: String = SupportSystem.warmth_band()
	if band == SupportSystem.BAND_HOT:
		return UiTokens.health_color(&"bad")
	if band == SupportSystem.BAND_WARM:
		return UiTokens.health_color(&"warn")
	return UiTokens.health_color(&"healthy")


## §8.2 masasındaki adlar, birleştirilmiş. Boş masa "" döner — o hâlin kendisi bir
## cümledir ve ad listesi değildir.
func _desk_names() -> String:
	var names: Array[String] = []
	for c in SupportSystem.desk_roster():
		names.append(c.character_name)   # özel ad — lokalize edilmez
	return ", ".join(names)


func _desk_line(roster: String) -> Control:
	# §8.2 — masada kim var. Boş masa küçük bir sızıntı değil TAM SIFIR üretir, o yüzden
	# cümle nötr değil olumsuz renkte: bu bir bilgi satırı değil, duran bir motordur.
	var staffed: bool = SupportSystem.desk_staffed()
	var line: String = tr("PROD_DESK_STAFFED").format({"names": roster}) if staffed \
		else tr("PROD_DESK_EMPTY")
	var lbl := UiFactory.make_label(line, &"RowMeta",
		UiTokens.INK_MUTED if staffed else UiTokens.negative())
	lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return lbl


func _fix_run_row(running: bool) -> Control:
	# §8.4 KAPISI. Koşu sürerken düğme BİTİRME eylemine dönüşür (ikinci bir düğme
	# eklenmez — koşu iki yönlü bir anahtar, iki ayrı karar değil) ve yanında o
	# koşuda çözülenlerin sayısı durur.
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", UiTokens.SPACE_M)
	if running:
		row.add_child(HRUiShared.action_button(tr("PROD_FIX_RUN_END"), _on_fix_run_end, true))
		var chip := UiFactory.make_badge(
			tr("PROD_FIX_RUN_FIXED_N").format({"n": ProductState.fix_run_fixed()}), &"positive")
		chip.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		row.add_child(chip)
	elif SupportSystem.can_start_fix_run():
		row.add_child(HRUiShared.action_button(tr("PROD_FIX_RUN_START"), _on_fix_run_start, true))
	else:
		# Kapalı düğme + GEREKÇE. Ret kimliği motorundan gelir; UI kendi koşulunu
		# (ör. "doğrulanmış == 0") yeniden yazmaz.
		row.add_child(HRUiShared.disabled_button(tr("PROD_FIX_RUN_START"), _fix_refusal_text()))
	return row


func _fix_refusal_text() -> String:
	var refusal: String = SupportSystem.fix_run_refusal()
	if refusal == SupportSystem.REFUSAL_NO_BUGS:
		return tr("PROD_FIX_REFUSAL_NO_BUGS")
	if refusal == SupportSystem.REFUSAL_DESK_SHUT:
		return tr("PROD_FIX_REFUSAL_DESK_SHUT")
	if refusal == SupportSystem.REFUSAL_ALREADY_RUNNING:
		return tr("PROD_FIX_REFUSAL_RUNNING")
	return tr("PROD_FIX_REFUSAL_NOT_LIVE")


func _on_fix_run_start() -> void:
	if SupportSystem.start_fix_run():
		repaint()


func _on_fix_run_end() -> void:
	SupportSystem.end_fix_run()
	repaint()


func _on_capacity_change_requested() -> void:
	# §10: "Sağlayıcı canlıda HER AN değiştirilebilir; göç bedeli yoktur." Kararın
	# EKRANI yayın akışının ALTYAPI adımıdır — sağlayıcı ve kapasite orada zaten yan
	# yana çizili — ve o adım tek başına açılır. Router'a bir görünüm kimliği eklemek
	# yerine akış kendi kapısını taşıyor (PublishFlow.open): kart PanelLayer'da
	# yaşıyor, yani bu sayfanın alt ağacının dışında, ve commit'te kendi kapanıyor.
	# Tek-adım modu HİÇBİR ŞEY YAYINLAMAZ (step_committed, publish_confirmed değil).
	PublishFlow.open(PublishFlow.STEP_INFRA)


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


## DURUM hücre şeridi. HBox DEĞİL HFlow: §17'nin alan seti üç hücreden yediye çıktı ve
## tek satırlık bir HBox onları iki-kolonlu sayfada okunmaz genişliğe sıkıştırırdı.
## HFlow taşanı alt satıra indirir; yerleşim kararı, sıralama sözleşmesi değişmiyor.
func _stat_row(cells: Array) -> HFlowContainer:
	var row := HFlowContainer.new()
	row.add_theme_constant_override("h_separation", 18)
	row.add_theme_constant_override("v_separation", 10)
	for c in cells:
		_add_stat(row, String((c as Array)[0]), String((c as Array)[1]))
	return row


func _add_stat(row: Container, key: String, caption: String) -> void:
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
	_live_badge_label.text = tr("BUILD_LIVE_VERSION").format({"n": ver})
	var hs: String = ProductSystem.health_state()
	_set_dot_color(_health_dot, UiTokens.health_color(&"healthy" if hs == "saglikli" else &"warn"))   # LOC-DATA health band id
	_health_text.text = ProductUiShared.health_label(hs)


func _repaint_profile(ver: int, bugs: int) -> void:
	# §11.3 — ÜÇ EKSEN TEK ÇAĞRIDAN. Üçgen, legend çubukları ve DURUM'un kararlılık
	# hücresi aynı `axis_readings()` sonucunu paylaşır; ham `mvp_*` bayrağı burada
	# artık okunmuyor, yani monitörle üçgen ayrışamaz (ProductState'in sözleşmesi).
	var vals: Dictionary = ProductState.axis_readings()
	# ÖLÇEK DÜRÜSTLÜĞÜ: 100 pazar ÇITASIDIR, tavan değil — okuma çıtayı aşabilir ve
	# gösterim 120'de kesilir (QualityModel.READING_MAX). Ölçek en büyük okumaya
	# göre BÜYÜSEYDİ çıtanın nerede olduğu her üründe kayar, en büyük okumaya
	# SABİTLENSEYDİ 100 üstü her ürün aynı kenara sıkışırdı. İkisi de yanlış; ölçek
	# okumanın kendi tavanıdır ve her yüzeyde aynı cetvel kalır.
	var maxv: float = QualityModel.READING_MAX
	_radar.set_axes(vals, maxv)
	for axis in ProductUiShared.AXIS_KEYS:
		var bar: ProgressBar = _legend_rows[axis]["bar"]
		bar.max_value = maxv
		bar.value = float(vals.get(axis, 0))
		# "+N" EMEKLİ: artı işareti bir KATKI anlatıyordu (özelliklerin eksene eklediği
		# puan). Burada basılan artık bir okumadır — mutlak bir sayı, işaretsiz.
		(_legend_rows[axis]["val"] as Label).text = str(int(vals.get(axis, 0)))
	var risk: String = ProductSystem.product_bug_risk()
	_risk_value.text = ProductUiShared.risk_label(risk)
	_risk_value.add_theme_color_override("font_color",
		UiTokens.negative_bright() if risk == "yuksek" else UiTokens.INK)   # LOC-DATA risk band id
	# Rozetler: 2 chip — palet/metin birlikte değiştiği için yeniden kurulur
	# (liste değil; tam-ağaç rebuild sayılmaz).
	_clear(_badges_row)
	var pal: Dictionary = UiTokens.bug_severity(bugs)
	_badges_row.add_child(UiFactory.make_pill(
		tr("PROD_BUGS_TREND").format(
			{"bugs": bugs, "trend": ProductUiShared.trend_label(ProductSystem.bug_trend())}),
		pal.bg, pal.fg))
	# §17 — rozet SÜRÜM yaşını söyler, ÜRÜN yaşını değil. Eskiden `mvp_launch_day`'den
	# türetiliyordu: o damga yalnız İLK yayında atılır, yani v4'ün rozeti v1'in gününü
	# sayıp "V4 · 120 gün canlı" diyordu. Yaşın tek evi ProductState'tir ve her yayında
	# `refresh_on_publish()` ile sıfırlanır.
	var live_days: int = ProductState.version_age_days()
	_badges_row.add_child(UiFactory.make_badge(tr("PROD_LIVE_DAYS").format({"version": ver, "days": live_days}), &"neutral"))


func _repaint_traction() -> void:
	_traction_ready_badge.visible = GameState.phase_gate_ready
	var sig: Dictionary = PhaseGateSystem.series_a_signal()
	_traction_bar.value = float(sig.get("progress", 0.0)) * 100.0
	_traction_meta.text = InvestorAppetiteUi.line(sig)
	if _appetite_chip_host != null:
		for c in _appetite_chip_host.get_children():
			c.queue_free()
		_appetite_chip_host.add_child(InvestorAppetiteUi.chip(String(sig.get("state", "closed"))))


func _repaint_stats(bugs: int) -> void:
	# GÖSTERİLEN kararlılık ProductState'in EKSEN OKUMASIDIR (§11.3); ham bayrak değil.
	# `effective_stability` olduğu yerde duruyor ve ekonominin hata-aşınmalı aritmetiğini
	# yapmaya devam ediyor — hücre o ikiliyi (etkin / okuma) yan yana basar.
	var raw: float = float(ProductState.axis_readings().get("stability", 0))
	var eff: int = int(round(QualityModel.effective_stability(raw, bugs)))
	var stab_txt := "%d / %d" % [eff, int(round(raw))]
	if _is_b2b:
		var count: int = 0
		var mrr_sum: int = 0
		for c in CustomerRegistry.get_by_market("b2b"):
			if c.status == "active":
				count += 1
				mrr_sum += c.mrr
		(_stat_values["musteri"] as Label).text = str(count)   # LOC-DATA stat slot id
		(_stat_values["mrr"] as Label).text = tr("PROD_PER_MONTH").format(
			{"amount": ProductUiShared.money_tr(mrr_sum)})
		(_stat_values["churn"] as Label).text = _b2b_churn_text()
	else:
		# §17 — ÜCRETSİZ KULLANICI = kitle − ödeyen. Kitlenin kendisi değil: kitle
		# ödeyeni de kapsıyor ve iki hücre aynı insanı iki kez saymamalı.
		var audience: int = int(floor(SalesSystem.b2c_audience()))
		var paying: int = CustomerRegistry.get_total_users()
		(_stat_values["free_users"] as Label).text = Fmt.group(maxi(0, audience - paying))   # LOC-DATA stat slot id
		(_stat_values["paying"] as Label).text = Fmt.group(paying)
		# CANLI MRR — fiyat panelindeki PROJEKSİYON değil, Satış'ın toplu kaydına
		# yerleşmiş olan sayı. Projeksiyon slider'ın nerede durduğunu, bu ise ürünün
		# bugün ne kazandığını söyler.
		(_stat_values["mrr"] as Label).text = tr("PROD_PER_MONTH").format(
			{"amount": ProductUiShared.money_tr(_b2c_live_mrr())})
	(_stat_values["satisfaction"] as Label).text = _satisfaction_text()
	# §9 — ilgi 0-100 arası bir okumadır (her yayında 100'e tazelenir, yarı ömür 30 gün).
	# Yüzde DEĞİL: bir şeyin oranı değil, talebin kendi ölçeği.
	(_stat_values["interest"] as Label).text = str(int(round(ProductRead.interest())))
	(_stat_values["bugs"] as Label).text = str(bugs)
	(_stat_values["stab"] as Label).text = stab_txt


## Ölçülecek müşteri yokken basılan işaret. Bir metin değil noktalama (hücrenin kuruluş
## değeriyle aynı işaret), o yüzden anahtarı yok.
const NO_DATA_MARK := "—"


func _b2c_live_mrr() -> int:
	# Satış'ın TEK toplu B2C kaydı. GameState.mrr değil: o bütün müşterilerin toplamı
	# ve çoklu ürün geldiğinde bu sayfanın ürününü temsil etmez.
	var base: Customer = CustomerRegistry.get_customer(SalesSystem.B2C_USERBASE_ID)
	return base.mrr if base != null else 0


func _satisfaction_text() -> String:
	# B2B'de aktif hesapların ORTALAMASI, B2C'de toplu kaydın kendi memnuniyeti —
	# ikisi de `Customer.satisfaction`, ikisi de CustomerRegistry'den okunur.
	if _is_b2b:
		var total: int = 0
		var n: int = 0
		for c in CustomerRegistry.get_by_market("b2b"):
			if c.status == "active":
				total += c.satisfaction
				n += 1
		return NO_DATA_MARK if n == 0 else str(int(round(float(total) / float(n))))
	var base: Customer = CustomerRegistry.get_customer(SalesSystem.B2C_USERBASE_ID)
	return str(base.satisfaction) if base != null else NO_DATA_MARK


func _b2b_churn_text() -> String:
	# §17 churn (B2B): churn sayacı İŞLEYEN aktif hesapların payı. `churn_countdown`
	# −1 iken sayaç kapalıdır; 0 dahil her değer "bu hesap gidiyor" demektir.
	var active: int = 0
	var counting: int = 0
	for c in CustomerRegistry.get_by_market("b2b"):
		if c.status != "active":
			continue
		active += 1
		if c.churn_countdown >= 0:
			counting += 1
	if active == 0:
		return NO_DATA_MARK
	return Fmt.percent(round(100.0 * float(counting) / float(active)), 0)


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
		(entry["label"] as Label).text = tr("PROD_DAYS").format({"n": days})


func _make_promise_row(p) -> PanelContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	row.add_child(UiFactory.make_label(tr("PROD_PROMISED"), &"SectionLabel", UiTokens.ACCENT_DEEP))
	var cname: String = tr("SALES_CUSTOMER")
	var cust = CustomerRegistry.get_customer(p.customer_id)
	if cust != null:
		cname = cust.display_name()
	var mid := UiFactory.make_label("%s · %s" % [cname, B2BConstants.feature_label(p.feature_id)], &"RowMeta")
	mid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mid.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	row.add_child(mid)
	var days_lbl := UiFactory.make_label("", &"RowName")
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
			seg += tr("PROD_LIVE_SUFFIX")
		segs.append(seg)
	if segs.is_empty():
		# Eski save'ler (history yok): canlı sürümü launch gününden türet.
		segs.append(tr("PROD_VERSION_LIVE").format({"version": current_ver,
			"date": ProductUiShared.month_year(int(GameState.get_flag("mvp_launch_day", GameState.day)))}))
	var b: FeatureBuild = ProductSystem.get_active_build()
	var next_state: String = tr("PROD_IN_DEVELOPMENT") if (b != null and b.is_version_build) else tr("PROD_UNPLANNED")
	segs.append("v%d · %s" % [current_ver + 1, next_state])
	return tr("PROD_VERSIONS") + " " + " → ".join(segs)


func _repaint_action_cards(ver: int) -> void:
	var building: bool = ProductSystem.get_active_build() != null
	var nextv: int = ver + 1
	_v_title.text = _dev_title(nextv)
	_v_status.text = tr("PROD_ETA_DAYS").format(
		{"n": max(3, ProductSystem.estimate_build_days([], [], ""))})
	_set_card_locked(_v_card, building)


func _repaint_bottom(sub: String, ver: int) -> void:
	var comp: float = _shipped_composite(sub)
	var passer: String = _rival_passed_name(sub, comp)
	# Pazar payı satırı (Fix 3, lig çerçevesinin yerine) — WORKING TR. Oyuncunun
	# MRR'dan türeyen dilimi + hemen üstündeki adlandırılmış rakibin dilimi: kıymık
	# küçükken bile bir sonraki basamak görünür kalır. Kalite-bazlı "seni geçti"
	# eki ayrı bir sinyaldir ve aynen kalır.
	var snap: Dictionary = RivalRegistry.get_market_snapshot(sub)
	var line: String = tr("PROD_MARKET_SHARE").format(
		{"share": RivalRegistry.format_share(float(snap["player_pct"]))})
	var above: Dictionary = _nearest_rival_above(snap)
	if not above.is_empty():
		line += " · %s %s" % [String(above["name"]), RivalRegistry.format_share(float(above["share_pct"]))]
	var passed: bool = passer != ""
	_league_label.text = line + (tr("PROD_RIVAL_PASSED").format({"rival": passer}) if passed else "")
	_league_label.add_theme_color_override("font_color",
		UiTokens.negative() if passed else UiTokens.INK_MUTED)
	# Şerit KUTUSU yalnız gerçekten bir uyarı varken çizilir. Panel'i her zaman
	# göstermek "her şey yolunda"yı da kırmızı bir çerçeveye alırdı.
	_league_strip.self_modulate.a = 1.0 if passed else 0.0
	_league_icon.visible = passed
	_league_icon.add_theme_color_override("font_color", UiTokens.negative())
	var bugs_heavy: bool = ProductSystem.product_bug_risk() == "yuksek"   # LOC-DATA risk band id
	_tip_line.text = ProductUiShared.product_tip(_weakest_axis_id(), ver + 1, passer, bugs_heavy)


func _nearest_rival_above(snap: Dictionary) -> Dictionary:
	# Payı oyuncununkinin üstünde olan EN KÜÇÜK adlandırılmış rakip (liste pay-azalan
	# sıralı gelir — sondan yürümek ilk "üstteki basamağı" verir).
	var player: float = float(snap["player_pct"])
	var rivals: Array = snap["rivals"]
	for i in range(rivals.size() - 1, -1, -1):
		if float(rivals[i]["share_pct"]) > player:
			return rivals[i]
	return {}


# --- girişler ------------------------------------------------------------------

func _on_v_card_input(ev: InputEvent) -> void:
	if not _is_left_click(ev):
		return
	if ProductSystem.get_active_build() != null:
		return   # ikinci build yok — kart zaten sönük
	navigate_requested.emit("creation", {"step": 3, "v2": true})


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
	# En zayıf eksen = ÜÇ OKUMANIN minimumu (eşitlikte innovation → stability →
	# experience sırası). Ham bayrak değil okuma: ipucu şeridi oyuncunun üçgende
	# GÖRDÜĞÜ ekseni adlandırmak zorunda, yoksa satır başka bir sayıyı işaret eder.
	var readings: Dictionary = ProductState.axis_readings()
	var worst: String = "innovation"
	var worst_v: float = INF
	for axis in ProductUiShared.AXIS_KEYS:
		var v: float = float(readings.get(axis, 0))
		if v < worst_v:
			worst_v = v
			worst = String(axis)
	return worst


# --- yardımcılar ----------------------------------------------------------------

## "Geliştir · v3". Eski metin "v3'ü geliştir"di ve 2..9 için elle yazılmış bir ek tablosu
## taşıyordu — Türkçe ünlü uyumu sayının OKUNUŞUNA bağlı olduğu için. Yasa tam da bu yüzden
## araya giren değere ek getirmeyi yasaklıyor: tablo bir sonraki dilde çöker. Sayı sona alındı.
func _dev_title(v: int) -> String:
	return tr("PROD_DEV_VERSION").format({"version": v})


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
		return tr("PRODUCT_FALLBACK_NAME")
	var data: Dictionary = ProductCatalog.get_sub_product_type_by_id(sub_type_id)
	if data.is_empty():
		return sub_type_id
	return ProductCatalog.type_name(sub_type_id)


func _tr_upper(s: String) -> String:
	# Tek ev UiTokens.tr_upper'a delege (2026-07-21 sweep eki).
	return UiTokens.tr_upper(s)


func _clear(node: Node) -> void:
	for ch in node.get_children():
		node.remove_child(ch)
		ch.queue_free()
