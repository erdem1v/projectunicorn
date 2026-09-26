extends Control

# ============================================================================
# KONSEPT — sürüm planının kurulduğu ekran (GDD rev 6.1 §3).
#
#   v1 : 01 YOL (B2C/B2B) → 02 TİP → 03 KONSEPT
#   v2+: yol/tip SORULMAZ; akış doğrudan Konsept'te açılır.
#
# KONSEPT TEK EKRAN, İKİ SÜTUNDUR: oyuncu kademeyi seçerken kimin taşıyacağını
# görmelidir. Şeritteki "01 ÖZELLİKLER → 02 EKİP" bir ilerleme değil TELGRAFtır.
#   · sol  : FeatureLinesView — 9 hat × 3 kademe (§12)
#   · sağ  : ÜRÜN PROFİLİ (üçgen + eksen okumaları) + ProductTeamPanel
#   · alt  : onay kartı (ad · toplam efor/maliyet/süre · Onayla ve Başlat)
#
# `_selected` PLANLANMIŞ KADEME kimlikleri tutar. Bu ekran hat durumlarına ASLA
# yazmaz — plan build'e gider, kademeler yalnız yayında işlenir
# (ProductSystem._apply_line_plan_at_ship). §12.3'ün "iptal hiçbir şeyi geri
# almaz" cümlesi bu yüzden bir geri-alma koduna değil, YAPIYA dayanır.
#
# KİLİTLİ mod (setup({locked: true}) — router "tracker" id'sini buraya bağlar):
# yapım sürerken AYNI ekran görünür ama plan kilitlidir; hat listesi okunur
# kalır, tıklanmaz. Onay kartının yerinde yapım durum kartı durur. EKİP paneli
# kilitli modda da CANLIDIR — §3: "Lider yapım sürerken ayrılırsa … oyuncu ekip
# panelinden yeni lider atayabilir."
#
# İKİ YAZMA YOLU, İKİSİ DE SEAM: ekonomiye ProductSystem.start_line_build
# (maliyet tahsili onun içinde — UI nakde asla dokunmaz), kadroya
# CharacterRegistry.assign_job/unassign_job (panel ikinci bir kadro tutmaz).
# ============================================================================

signal navigate_requested(view_id: String, args: Dictionary)

# Durum kartının çubuğu yüzen BuildHUD ve ODA monitörüyle AYNI sahne. Sahne preload,
# class_name yok: paylaşılan checkout'ta class-cache tuzağı.
const _BUILD_BAR_SCENE := preload("res://scenes/ui/components/BuildBar.tscn")

## İki sütunun oranı. Hat listesi geniş (27 kademe, üç sütunlu kart gövdesi), sağ
## sütun profil+ekip taşır. Oran YERLEŞİMDİR — tema değil (UI/STYLE LAW md.4).
const COL_RATIO_LINES := 1.9
const COL_RATIO_SIDE := 1.0
const RADAR_H := 190
## Kilitli tip kartının soluklaştırması. Okunur kalmalı: kartın İŞİ Erken Erişim'in
## ne getireceğini söylemek, o yüzden silik değil YARI-GERİ çekilmiş.
const LOCKED_CARD_ALPHA := 0.55

## CharacterRegistry.assign_job'ın makine gerekçeleri → ekran sözcüğü. Listede
## olmayan her kod PROD_TEAM_REFUSE_OTHER okur.
const TEAM_REFUSAL_KEYS := {
	"job_cap": "PROD_TEAM_REFUSE_JOB_CAP",
	"not_your_job": "PROD_TEAM_REFUSE_ROLE",
	"inactive": "PROD_TEAM_REFUSE_INACTIVE",
}

var _step: int = 1
var _v2_mode: bool = false
var _locked_mode: bool = false           # build sürüyor — görüntüleme, seçim yok
var _market: String = ""                 # "b2c" | "b2b"
var _type_id: String = ""
var _selected: Array[String] = []        # planlanmış kademe kimlikleri
var _prefill: Dictionary = {}            # iptal edilen build'in ya da taslağın {type, features, name, market}
var _suggest_i: int = 0

# 03 yerinde-güncelleme referansları
var _lines_view: FeatureLinesView = null
var _team_panel: ProductTeamPanel = null
var _radar: TriangleRadar = null
var _legend: Dictionary = {}             # axis -> {bar, value}
var _totals_label: Label = null
var _cash_label: Label = null
var _commit_btn: Button = null
var _name_edit: LineEdit = null
## Onay kartının not satırı: §5'in cila hatırlatması; ekip ataması reddedilince gerekçesi.
var _note_label: Label = null


func setup(args: Dictionary) -> void:
	_v2_mode = bool(args.get("v2", false))
	_step = clampi(int(args.get("step", 1)), 1, 3)
	_prefill = args.get("prefill", {})
	var lb: FeatureBuild = ProductSystem.get_active_build() if bool(args.get("locked", false)) else null
	if lb != null:
		# Kilitli görüntüleme: kimlik ve plan AKTİF BUILD'den. Ship edilmiş kademeler
		# hat durumlarında; hat listesi onları kendi çiziyor (soluk + ✓).
		_locked_mode = true
		_step = 3
		_type_id = lb.sub_product_type_id
		_market = ProductCatalog.get_market_type(_type_id)
		_v2_mode = lb.is_version_build
		_selected.assign(lb.planned_step_ids)
		_rebuild()
		return
	if _v2_mode:
		_step = 3
		_type_id = String(GameState.get_flag("mvp_sub_product_type_id", ""))
		_market = String(GameState.get_flag("mvp_market_type", "b2c"))
	elif not _prefill.is_empty():
		# İptal edilen build'in seçimi (yanlış-tık affı) ya da sekme değişiminde saklanan
		# TASLAK: aynı şekil, artı yalnız yol seçilmişse `market`.
		_type_id = String(_prefill.get("type", ""))
		if _type_id != "":
			_market = ProductCatalog.get_market_type(_type_id)
		else:
			_market = String(_prefill.get("market", ""))
		_selected.assign(_prefill.get("features", []))
	# Adım tutarlılığı: tip yoksa 03, yol yoksa 02 açılamaz.
	if _step == 3 and _type_id == "" and not _v2_mode:
		_step = 1
	if _step == 2 and _market == "":
		_step = 1
	_rebuild()


func repaint() -> void:
	# Saatlik/günlük sinyaller. Alt bandın rakamları oynar (kasa, ~gün) VE iki alt
	# görünüm kendi tazelemesini yapar: hat satırlarının kapı durumu ile ekip
	# satırlarının müsaitliği İK'da değişir (eğitim biter, izin döner).
	if _lines_view != null:
		_lines_view.repaint()
	if _team_panel != null:
		_team_panel.repaint()
	_update_dynamic()


# --- Kurulum ---------------------------------------------------------------

func _rebuild() -> void:
	for c in get_children():
		remove_child(c)
		c.queue_free()
	_legend.clear()
	_lines_view = null
	_team_panel = null
	_radar = null
	_totals_label = null
	_cash_label = null
	_commit_btn = null
	_name_edit = null
	_note_label = null

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
	# §3 — v1: Yol → Tip → Özellikler. v2+: yol/tip SORULMAZ; şerit iki kalemli ve
	# ikisi de bu ekranda — ilki "buradasın" diye yanar, ikincisi sağ sütunu telgraflar.
	var items := [tr("PROD_STEP_FEATURES"), tr("PROD_TEAM_HEADER")] if _v2_mode \
		else [tr("PROD_STEP_PATH"), tr("PROD_STEP_TYPE"), tr("PROD_STEP_FEATURES")]
	for i in items.size():
		if i > 0:
			hb.add_child(UiFactory.make_label("→", &"SectionLabel", UiTokens.INK_DIM))
		var active: bool = (i == 0) if _v2_mode else (_step == i + 1)
		hb.add_child(UiFactory.make_label(items[i], &"SectionLabel",
			UiTokens.ACCENT_DEEP if active else UiTokens.INK_DIM))
	return hb


func _add_back_button(host: Control, text: String, on_press: Callable) -> void:
	var back := Button.new()
	back.text = text
	back.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	back.pressed.connect(on_press)
	host.add_child(back)


# --- 01 YOL ------------------------------------------------------------------

func _build_step1(body: VBoxContainer) -> void:
	body.add_child(UiFactory.make_label(tr("PROD_PATH_TITLE"), &"TitleSerif"))
	body.add_child(UiFactory.make_label(tr("PROD_PATH_SUB"), &"CaptionMuted"))
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	row.add_child(_make_path_card("b2c", tr("PROD_PATH_B2C"), "B2C",
		tr("PROD_PATH_B2C_DESC"),
		[tr("PROD_PATH_B2C_PRO"), tr("PROD_PATH_B2C_CON"), tr("PROD_PATH_B2C_CON2")]))
	row.add_child(_make_path_card("b2b", tr("PROD_PATH_B2B"), "B2B",
		tr("PROD_PATH_B2B_DESC"),
		[tr("PROD_PATH_B2B_PRO"), tr("PROD_PATH_B2B_CON1"), tr("PROD_PATH_B2B_CON2")]))
	body.add_child(row)
	if not GameState.get_flag("product_path_frank_seen", false):
		body.add_child(_make_frank_strip())


func _make_path_card(market: String, kicker: String, big: String, desc: String, bullets: Array) -> Control:
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 8)
	var card := UiFactory.make_card(vb)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vb.add_child(UiFactory.make_label(kicker, &"SectionLabel"))
	var big_lbl := UiFactory.make_label(big, &"TitleSerif")
	big_lbl.add_theme_font_size_override("font_size", 34)
	vb.add_child(big_lbl)
	var d := UiFactory.make_label(desc, &"BodySerif")
	d.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vb.add_child(d)
	vb.add_child(UiFactory.make_label(tr("PROD_TYPE_EXAMPLES"), &"SectionLabel"))
	var pills := HFlowContainer.new()
	pills.add_theme_constant_override("h_separation", 6)
	pills.add_theme_constant_override("v_separation", 4)
	# "Örnekler" OYNANABİLİR olanlardır: kilitli havuzdan bir ad, tip ekranında
	# tıklanamayan bir ürünü vaat ederdi.
	for st in ProductCatalog.playable_types(market):
		pills.add_child(UiFactory.make_pill(ProductCatalog.type_name(String(st.get("id", ""))),
			UiTokens.NEUTRAL_BADGE_BG, UiTokens.NEUTRAL_BADGE_FG, false))
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
	btn.text = tr("PROD_PATH_PICK")
	btn.pressed.connect(func() -> void:
		_market = market
		_step = 2
		_rebuild())
	vb.add_child(btn)
	return card


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
	hb.add_child(UiFactory.make_avatar("FK", 28))
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 2)
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col.add_child(UiFactory.make_label(tr("PROD_MENTOR_TAG"), &"SectionLabel", UiTokens.CREAM_DIM))
	var quote := UiFactory.make_label(tr("PROD_MENTOR_LINE"), &"QuoteSerifCream")
	quote.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	col.add_child(quote)
	hb.add_child(col)
	var ok := Button.new()
	ok.text = tr("UI_OK")
	ok.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	ok.pressed.connect(func() -> void:
		GameState.set_flag("product_path_frank_seen", true)
		panel.visible = false)
	hb.add_child(ok)
	return panel


# --- 02 TİP ------------------------------------------------------------------

func _build_step2(body: VBoxContainer) -> void:
	_add_back_button(body, tr("PROD_BACK_PATH"), func() -> void:
		_step = 1
		_rebuild())
	body.add_child(UiFactory.make_label(
		tr("PROD_TYPE_STEP_TITLE").format({"market": Fmt.upper(_market)}), &"TitleSerif"))
	body.add_child(UiFactory.make_label(tr("PROD_TYPE_STEP_SUB"), &"CaptionMuted"))
	var grid := GridContainer.new()
	grid.columns = 3
	grid.add_theme_constant_override("h_separation", 12)
	grid.add_theme_constant_override("v_separation", 12)
	body.add_child(grid)
	# §12.11 MÜHÜRLÜ: oynanabilir alt-tipler ÖNCE, sonra yol başına ÜÇ kilitli kart.
	# Hat içeriği olmayan katalog kayıtları dökülmez: tıklayan oyuncu boş bir
	# Konsept'e düşerdi.
	for st in ProductCatalog.playable_types(_market):
		grid.add_child(_make_type_card(String(st.get("id", ""))))
	for tid in ProductCatalog.locked_type_ids(_market):
		grid.add_child(_make_locked_type_card(String(tid)))


func _make_type_card(type_id: String) -> Control:
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 6)
	var card := UiFactory.make_card(vb)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	vb.add_child(UiFactory.make_label(ProductCatalog.type_name(type_id), &"NameSerif"))
	vb.add_child(UiFactory.make_label(ProductCatalog.type_category(type_id), &"SectionLabel"))
	var d := UiFactory.make_label(ProductCatalog.type_desc(type_id), &"BodySerif")
	d.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vb.add_child(d)
	var pills := HFlowContainer.new()
	pills.add_theme_constant_override("h_separation", 6)
	pills.add_theme_constant_override("v_separation", 4)
	for s in ProductCatalog.type_sector_labels(type_id):
		pills.add_child(UiFactory.make_pill(String(s),
			UiTokens.NEUTRAL_BADGE_BG, UiTokens.NEUTRAL_BADGE_FG, false))
	vb.add_child(pills)
	var pm := UiFactory.make_label(ProductCatalog.type_tradeoff(type_id), &"QuoteSerif")
	pm.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vb.add_child(pm)
	HRUiShared.set_mouse_ignore(vb)
	card.gui_input.connect(_on_type_card_input.bind(type_id))
	return card


## §3 tip ekranı telgrafı (MÜHÜRLÜ): "solo-gerçekçi olmayan alt-tipler kilitli-görünür
## kartlardır; küçük 'Erken Erişim' etiketi + gerekçe satırı 'Daha büyük ekip ister.'
## taşırlar." Kart TIKLANMAZ ve gri değil SOLUK çizilir.
##
## §12.11'in AÇIK SLOT'u ayrı bir gerekçe taşır: o bir ürün değil, henüz verilmemiş
## bir ruling. Ona ürünün gerekçesini yazmak yalan olurdu.
func _make_locked_type_card(type_id: String) -> Control:
	var is_slot: bool = type_id == ProductCatalog.TYPE_SCREEN_SLOT
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 6)
	var card := UiFactory.make_card(vb)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.modulate.a = LOCKED_CARD_ALPHA
	card.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var head := HBoxContainer.new()
	head.add_theme_constant_override("separation", 8)
	head.add_child(UiFactory.make_label(
		tr("PROD_TYPE_SLOT_NAME") if is_slot else ProductCatalog.type_name(type_id), &"NameSerif"))
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(spacer)
	head.add_child(UiFactory.make_badge(tr("PROD_TYPE_EA_TAG"), &"neutral"))
	vb.add_child(head)

	if not is_slot:
		vb.add_child(UiFactory.make_label(ProductCatalog.type_category(type_id), &"SectionLabel"))
	var reason := UiFactory.make_label(
		tr("PROD_TYPE_SLOT_REASON") if is_slot else tr("PROD_TYPE_LOCKED_REASON"),
		&"RowMeta", UiTokens.INK_MUTED)
	reason.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vb.add_child(reason)
	HRUiShared.set_mouse_ignore(vb)
	return card


func _on_type_card_input(ev: InputEvent, type_id: String) -> void:
	var mb := ev as InputEventMouseButton
	if mb == null or not mb.pressed or mb.button_index != MOUSE_BUTTON_LEFT:
		return
	if _type_id != type_id:
		_selected.clear()  # tip değişti — eski seçim havuza ait değil
	_type_id = type_id
	_step = 3
	_rebuild()


# --- 03 KONSEPT ----------------------------------------------------------------

func _build_step3(body: VBoxContainer) -> void:
	var build: FeatureBuild = ProductSystem.get_active_build() if _locked_mode else null
	var type_name: String = ProductCatalog.type_name(_type_id)
	if _locked_mode:
		_add_back_button(body, tr("PROD_BACK_PORTFOLIO"), func() -> void:
			navigate_requested.emit("portfoy", {}))   # LOC-DATA route id
	elif not _v2_mode:
		_add_back_button(body, tr("PROD_BACK_TYPE"), func() -> void:
			_step = 2
			_selected.clear()
			_rebuild())
	var head := HBoxContainer.new()
	head.add_theme_constant_override("separation", 10)
	if _locked_mode:
		# Ürün adı başrolde; pazar/tip meta satırına düşer (detail header grameri).
		head.add_child(UiFactory.make_label(
			build.product_name if build.product_name != "" else type_name, &"NameSerif"))
		var meta := UiFactory.make_label("%s · %s" % [UiTokens.tr_upper(_market),
			UiTokens.tr_upper(type_name)], &"SectionLabel")
		meta.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		head.add_child(meta)
	else:
		head.add_child(UiFactory.make_label(
			"%s / %s" % [UiTokens.tr_upper(_market), type_name], &"NameSerif"))
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(spacer)
	if _locked_mode:
		head.add_child(UiFactory.make_badge(tr("LOCK_BUILD_IN_PROGRESS"), &"accent"))
	body.add_child(head)

	var cols := HBoxContainer.new()
	cols.add_theme_constant_override("separation", 14)
	cols.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_child(cols)

	var left := VBoxContainer.new()
	left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left.size_flags_stretch_ratio = COL_RATIO_LINES
	cols.add_child(left)
	_lines_view = FeatureLinesView.new()
	_lines_view.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left.add_child(_lines_view)
	_lines_view.setup(_type_id, _selected)
	_lines_view.selection_changed.connect(_on_lines_selection_changed)
	_lines_view.train_or_hire_requested.connect(_on_train_or_hire_requested)
	_lines_view.research_requested.connect(_on_research_requested)
	if _locked_mode:
		# Yapım sürerken plan DEĞİŞMEZ; liste okunur kalır ama tıklanmaz.
		HRUiShared.set_mouse_ignore(_lines_view)

	var right := VBoxContainer.new()
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right.size_flags_stretch_ratio = COL_RATIO_SIDE
	right.add_theme_constant_override("separation", 12)
	cols.add_child(right)
	right.add_child(_make_profile_card())
	# §3 — ekip çoklu seçim, kurucu dahil, ve LİDER satırı.
	_team_panel = ProductTeamPanel.new()
	_team_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right.add_child(_team_panel)
	_team_panel.setup(_team_seed_ids(), build.lead_engineer_id if _locked_mode else _default_lead_id())
	_team_panel.selection_changed.connect(_on_team_selection_changed)
	_team_panel.lead_changed.connect(_on_lead_changed)

	body.add_child(_make_build_status_card() if _locked_mode else _make_commit_card())
	_update_dynamic()


## Kurucu her zaman listede ve varsayılan taşıyıcıdır (§3).
func _default_lead_id() -> String:
	var f: Character = CharacterRegistry.get_founder()
	return f.id if f != null else ""


## Build işine ATANMIŞ olanlar (build'in ekibi de budur): oyuncu Görevler'de kimi
## build'e koyduysa Konsept onu seçili açar. Kimse yoksa kurucu.
func _team_seed_ids() -> Array:
	var out: Array[String] = []
	for c in ProductSystem.build_carriers():
		out.append(c.id)
	if out.is_empty():
		var f: Character = CharacterRegistry.get_founder()
		if f != null:
			out.append(f.id)
	return out


## §12.0 "atama açar": panelin seçimi HR'ın BUILD işine YAZILIR, panel ikinci bir kadro
## TUTMAZ — tutsaydı §6.1'in her gün okuduğu `build_carriers` ile ekranın listesi ayrışırdı.
func _on_team_selection_changed(ids: Array) -> void:
	var want: Dictionary = {}
	for raw in ids:
		want[String(raw)] = true
	for c in ProductSystem.build_carriers():
		if not want.has(c.id):
			CharacterRegistry.unassign_job(c.id, HRConstants.JOB_BUILD)
	var refusal: String = ""
	for id in want:
		if CharacterRegistry.get_character(id) == null:
			continue   # ayrılan kişi team_panel'in seçiminde bir sonraki setup()'a kadar kalır
		# Çıplak `assign_job`, `clear_jobs` DEĞİL (Ar-Ge §5.0): araştıran kurucu yapım
		# başlatırsa araştırma DURAKLAR. `clear_jobs` araştırmayı ve duraklamış defteri
		# geri dönülemez biçimde silerdi; yer değiştirmeyi tek yazar kendisi yapıyor.
		var err: String = CharacterRegistry.assign_job(id, HRConstants.JOB_BUILD)
		if err != "":
			refusal = err
	if refusal != "":
		# Reddedilen atama ekranda kabul edilmiş gibi duramaz: panel HR'dan yeniden kurulur
		# ve gerekçe not satırına yazılır. Ertelenir, paneli kendi sinyalinin altından
		# çekmemek için.
		_reseed_team.call_deferred(refusal)
		return
	_update_dynamic()


func _reseed_team(refusal_code: String) -> void:
	if _team_panel == null:
		return
	var lb: FeatureBuild = ProductSystem.get_active_build()
	var lead: String = lb.lead_engineer_id if (_locked_mode and lb != null) else _team_panel.lead_id()
	_team_panel.setup(_team_seed_ids(), lead)
	_update_dynamic()
	if _note_label != null:
		_note_label.text = tr(TEAM_REFUSAL_KEYS.get(refusal_code, "PROD_TEAM_REFUSE_OTHER"))


## Yapımı taşıyan lider: panelin lideri, yoksa build'in, o da yoksa kurucu — §6.1
## lidersiz de çalışır (çarpan 1,0).
func _lead_id() -> String:
	if _team_panel != null and _team_panel.lead_id() != "":
		return _team_panel.lead_id()
	var b: FeatureBuild = ProductSystem.get_active_build()
	if b != null and b.lead_engineer_id != "":
		return b.lead_engineer_id
	return _default_lead_id()


func _on_lines_selection_changed(step_ids: Array) -> void:
	_selected.assign(step_ids)
	_update_dynamic()


func _on_train_or_hire_requested() -> void:
	EventBus.tab_changed.emit("hr")   # LOC-DATA tab id — "→ Eğit / İşe al" canlı bağ


## Kilitli K3'ün "→ Araştır" bağı: Ar-Ge sekmesini aç ve düğümü göster.
## İKİ EMİR ARASINDA `self`'E DOKUNULMAZ. `tab_changed` SENKRON monte ediyor, yani ilk
## emirden döndüğümüzde bu sayfa çoktan `queue_free` edilmiştir; buradan sonra bir alan
## okumak ya da bir `await` yazmak serbest bırakılmış bir düğüme uzanmak olur. Taslak
## kaybolmaz: yönlendirici sayfayı bırakmadan önce `on_page_closing` çağırır.
func _on_research_requested(node_id: String) -> void:
	EventBus.tab_changed.emit("rnd")
	EventBus.rnd_node_requested.emit(node_id, false)


## §3 — lider yapım sürerken değiştirilebilir; yapım geriye dönük BOZULMAZ.
func _on_lead_changed(id: String) -> void:
	if _locked_mode:
		ProductSystem.set_build_lead(id)
	_update_dynamic()


# --- Sağ sütun + alt bant ------------------------------------------------------

## ÜRÜN PROFİLİ — üçgen + eksen okumaları. Yüzde ve "+N" YOK: hat modelinde kazanç
## kademenin kendi satırında yazıyor (§12.9).
func _make_profile_card() -> Control:
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 8)
	box.add_child(UiFactory.make_section_header(tr("PROD_PROFILE")))
	_radar = TriangleRadar.new()
	_radar.custom_minimum_size = Vector2(0, RADAR_H)
	box.add_child(_radar)
	for axis in ProductUiShared.AXIS_KEYS:
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 8)
		row.add_child(UiFactory.make_dot(ProductUiShared.axis_color(String(axis)), 8))
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
		var val := UiFactory.make_label("", &"RowMeta")
		val.custom_minimum_size = Vector2(40, 0)
		val.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		row.add_child(val)
		box.add_child(row)
		_legend[axis] = {"bar": bar, "value": val}
	return UiFactory.make_card(box)


## Kilitli modun alt bandı: yüzen karttaki BuildBar'ın büyüğü + İPTAL. İptal bu
## sayfanın kendi kontrolüdür ve `ProductSystem.cancel_build`'in oyundaki tek girişi.
func _make_build_status_card() -> Control:
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 10)
	vb.add_child(UiFactory.make_section_header(tr("PROD_BUILD_STATUS_HEADER")))
	var bar: Control = _BUILD_BAR_SCENE.instantiate()
	# 1.25×: aynı düzenin büyüğü, yeni bir düzen DEĞİL. size_scale satır
	# yükseklikleriyle yazı boylarını birlikte büyütür.
	bar.size_scale = 1.25
	bar.custom_minimum_size = Vector2(0, 138 * 1.25)
	bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vb.add_child(bar)
	# flat + INK_MUTED: `GhostButton` diye bir tema varyasyonu yok ve yenisi UI/STYLE
	# LAW'un kapısını gerektirir.
	var cancel := Button.new()
	cancel.flat = true
	cancel.text = tr("PROD_CANCEL_BUILD")
	cancel.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	cancel.add_theme_color_override("font_color", UiTokens.INK_MUTED)
	cancel.pressed.connect(_on_cancel_pressed)
	vb.add_child(cancel)
	return UiFactory.make_card(vb)


func _make_commit_card() -> Control:
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 6)
	if _v2_mode:
		vb.add_child(UiFactory.make_label(
			String(GameState.get_flag("mvp_product_name", "")), &"NameSerif"))
	else:
		var name_row := HBoxContainer.new()
		name_row.add_theme_constant_override("separation", 6)
		_name_edit = LineEdit.new()
		_name_edit.placeholder_text = tr("PROD_NAME_LABEL")
		_name_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		_name_edit.text = String(_prefill.get("name", ""))
		name_row.add_child(_name_edit)
		var sug := Button.new()
		sug.text = tr("PROD_NAME_SUGGEST")
		sug.pressed.connect(_on_suggest_pressed)
		name_row.add_child(sug)
		vb.add_child(name_row)
	_totals_label = UiFactory.make_label("", &"RowMeta")
	_totals_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vb.add_child(_totals_label)
	_cash_label = UiFactory.make_label("", &"RowMeta", UiTokens.INK_MUTED)
	_cash_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vb.add_child(_cash_label)
	_note_label = UiFactory.make_label("", &"MicroLabel", UiTokens.INK_MUTED)
	_note_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vb.add_child(_note_label)
	_commit_btn = Button.new()
	_commit_btn.theme_type_variation = &"CommitButton"
	_commit_btn.pressed.connect(_on_commit_pressed)
	vb.add_child(_commit_btn)
	return UiFactory.make_card(vb)


func _on_suggest_pressed() -> void:
	_name_edit.text = ProductCatalog.suggest_product_name(_suggest_i)
	_suggest_i += 1


# --- Canlı güncelleme ------------------------------------------------------------

func _update_dynamic() -> void:
	if _radar == null:
		return
	# §11.2/§11.3 — eksen okumaları TEK ZİNCİRDEN gelir. Konsept'te gösterilen,
	# planın TABAN CİLA (×1,00) projeksiyonudur: tur sayısı TASARIM'da belirlenir ve
	# bu ekran onu bilemez, o yüzden kart tam tasarımı (×1,15) vaat etmez (§5).
	var dims: Dictionary = ProductSystem.projected_line_dims(_type_id, _selected)
	var maxv: float = TriangleRadar.DEFAULT_MAX
	for axis in ProductUiShared.AXIS_KEYS:
		maxv = maxf(maxv, float(dims.get(axis, 0.0)))
	_radar.set_axes(dims, maxv)
	for axis in ProductUiShared.AXIS_KEYS:
		var v: float = float(dims.get(axis, 0.0))
		var bar: ProgressBar = _legend[axis].bar
		bar.max_value = maxv
		bar.value = v
		(_legend[axis].value as Label).text = Fmt.number(v, 1)
	if _locked_mode:   # onay kartı yok, plan da değişmiyor
		return
	# §3'ün maliyet dürüstlüğü: "Toplam efor · süre · bittiğinde kasada $X kalır".
	var efor: int = ProductSystem.effort_ceiling(_selected)
	var cost: int = ProductLines.sum_license_cost(_selected)
	var days: int = ProductSystem.estimate_line_build_days(_selected, _lead_id())
	if cost > 0:
		_totals_label.text = tr("PROD_TOTALS_COST").format(
			{"efor": efor, "amount": ProductUiShared.money_tr(cost), "days": days})
	else:
		_totals_label.text = tr("PROD_TOTALS").format({"efor": efor, "days": days})
	_cash_label.text = tr("PROD_CASH_AFTER").format(
		{"amount": ProductUiShared.money_tr(ProductUiShared.cash_after_build(cost, days))})
	# Onay YALNIZ geçerli bir planla açılır; doğrulayıcı TEK (§18). Ret kimliği makine
	# kimliğidir (CSV metni yok), o yüzden ekrana yazılmaz.
	_commit_btn.disabled = ProductSystem.validate_line_plan(_type_id, _selected) != ""
	_note_label.text = tr("PROD_POLISH_NOTE")
	_commit_btn.text = tr("PROD_CONFIRM_START") + (tr("PROD_CASH_DEDUCT").format(
		{"amount": ProductUiShared.money_tr(cost)}) if cost > 0 else "")


func _on_cancel_pressed() -> void:
	var b: FeatureBuild = ProductSystem.get_active_build()
	if b == null or b.is_bug_sprint:
		return
	var burned_days: int = maxi(0, GameState.day - b.start_day)
	var burned_cash: int = burned_days * GameState.daily_burn   # working yaklaşım
	# Geri gelen şey PLAN'dır: iptal hat durumlarına dokunmadı (plan hiç yazılmamıştı),
	# o yüzden prefill'in geri verdiği kademe seti hâlâ birebir geçerli.
	var prefill := {
		"type": b.sub_product_type_id,
		"features": b.planned_step_ids.duplicate(),
		"name": b.product_name,
	}
	EventBus.confirm_requested.emit({
		"title": tr("PROD_CANCEL_BUILD_Q"),
		"body": tr("PROD_CANCEL_BUILD_BODY") if burned_days < ProductSystem.CANCEL_FREE_DAYS
			else tr("PROD_CANCEL_BUILD_COST").format(
				{"days": burned_days, "amount": ProductUiShared.money_tr(burned_cash)}),
		"confirm_text": tr("HR_SEARCH_CANCEL_OK"),
		"cancel_text": tr("UI_DISMISS"),
		"on_confirm": _do_cancel.bind(prefill),
	})


func _do_cancel(prefill: Dictionary) -> void:
	# SIRA: prefill ÖNCE — cancel_build() içindeki "cancelled" emit'i router'ı
	# anında prefill'li kurma ekranına yönlendirir (bu view o anda ölür).
	GameState.set_flag("cancelled_build_prefill", prefill)
	ProductSystem.cancel_build()


# --- Commit ------------------------------------------------------------------

func _on_commit_pressed() -> void:
	# TEK GİRİŞ (§6): v1 ve v2 aynı seam'den geçer; sürüm numarasını start_line_build
	# ProductState.is_live()'dan kendi türetir. Kademeler burada yazılmaz: plan build'e
	# gider, hat durumlarına yalnız yayında dokunulur.
	var pname: String = _name_edit.text if _name_edit != null else ""
	if ProductSystem.start_line_build(_type_id, _selected, _lead_id(), pname):
		GameState.flags.erase("creation_draft")   # the draft became a build
		navigate_requested.emit("tracker", {})


## Draft guard. The tab router calls this on every page it frees (Esc, ✕, rail, ODA
## click-through, palette/language rebuild). An in-progress v1 draft — a chosen path, a
## type, ticked steps, a typed name — is stashed into the typed `creation_draft` flag;
## ProductTab re-hydrates it on its next mount through the same prefill path a cancelled
## build uses. Locked views and the v2 picker (the live product's own flags) are not drafts.
func on_page_closing() -> void:
	if _locked_mode or _v2_mode:
		return
	var draft: Dictionary = draft_state()
	if _market == "" and _type_id == "" and _selected.is_empty() and draft["name"] == "":
		GameState.flags.erase("creation_draft")
	else:
		GameState.set_flag("creation_draft", draft)


## The draft as the prefill dict.
func draft_state() -> Dictionary:
	var name_text: String = _name_edit.text if _name_edit != null else ""
	return {"step": _step, "market": _market, "type": _type_id, "features": _selected.duplicate(), "name": name_text}
