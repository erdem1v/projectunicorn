extends Control

# ============================================================================
# KONSEPT — sürüm planının kurulduğu ekran (GDD rev 6.1 §3).
#
#   v1 : 01 YOL (B2C/B2B) → 02 TİP → 03 KONSEPT
#   v2+: yol/tip SORULMAZ; akış doğrudan Konsept'te açılır.
#
# KONSEPT TEK EKRAN, İKİ SÜTUNDUR (direktör hükmü 2026-08-25). Şeritteki
# "01 ÖZELLİKLER → 02 EKİP" bir ilerleme değil TELGRAFtır: iki kalem de aynı
# sayfada durur, çünkü oyuncu kademeyi seçerken kimin taşıyacağını görmelidir.
#   · sol  : FeatureLinesView — 9 hat × 3 kademe (§12)
#   · sağ  : ÜRÜN PROFİLİ (üçgen + eksen okumaları) + ProductTeamPanel
#   · alt  : onay kartı (ad · toplam efor/maliyet/süre · Onayla ve Başlat)
#
# HAT MODELİ, DÜZ ÖZELLİK DEĞİL. `_selected` PLANLANMIŞ KADEME kimlikleri tutar.
# Bu ekran hat durumlarına ASLA yazmaz — plan build'e gider, kademeler yalnız
# yayında işlenir (ProductSystem._apply_line_plan_at_ship). §12.3'ün "iptal
# hiçbir şeyi geri almaz" cümlesi bu yüzden bir geri-alma koduna değil, YAPIYA
# dayanır. GÜÇLENDİR modu emekli: bir hattı yükseltmek zaten güçlendirmedir.
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

# Eksen legend renkleri tek kaynaktan (ProductUiShared.axis_color) — Ürün Detayı
# ile aynı üçlü. Sabit kopya EMEKLİ: renk körü paleti "stability"yi çalışma
# zamanında çevirir, const bir kopya ilk okunan renge çakılırdı.

# Build Bar (Software Inc. segment grameri, 2026-08-19): tracker kartının çubuğu yüzen
# BuildHUD ve ODA monitörüyle AYNI sahne — sahne preload, class_name yok (paylaşılan
# checkout'ta class-cache tuzağı; center_viewport.gd:21 ihtiyatı).
const _BUILD_BAR_SCENE := preload("res://scenes/ui/components/BuildBar.tscn")

## S4a'nın iki sütunu. Hat listesi geniş (27 kademe, üç sütunlu kart gövdesi),
## sağ sütun profil+ekip taşır. Oran YERLEŞİMDİR — tema değil (UI/STYLE LAW md.4).
const COL_RATIO_LINES := 1.9
const COL_RATIO_SIDE := 1.0
const RADAR_H := 190
## Kilitli tip kartının soluklaştırması. Okunur kalmalı: kartın İŞİ Erken Erişim'in
## ne getireceğini söylemek, o yüzden silik değil YARI-GERİ çekilmiş.
const LOCKED_CARD_ALPHA := 0.55

## CharacterRegistry.assign_job'ın makine gerekçeleri → ekran sözcüğü. Kod state'te
## yaşar, sözcük CSV'de; tablo yalnız ANAHTAR tutar, o yüzden const olabilir.
const TEAM_REFUSAL_KEYS := {
	"job_cap": "PROD_TEAM_REFUSE_JOB_CAP",
	"not_your_job": "PROD_TEAM_REFUSE_ROLE",
	"inactive": "PROD_TEAM_REFUSE_INACTIVE",
	"unknown": "PROD_TEAM_REFUSE_OTHER",
	"unknown_job": "PROD_TEAM_REFUSE_OTHER",
}

var _step: int = 1
var _v2_mode: bool = false
var _locked_mode: bool = false           # build sürüyor — görüntüleme, seçim yok
var _market: String = ""                 # "b2c" | "b2b"
var _type_id: String = ""
## HAT MODELİ (rev 6.1 §12): artık düz feature kimlikleri DEĞİL, PLANLANMIŞ KADEME
## kimlikleri. Anlamı değişti, sahibi değişmedi — bu sürümün almaya niyetlendiği
## kademeler burada durur ve hat durumlarına YALNIZ YAYINDA yazılır
## (ProductSystem._apply_line_plan_at_ship). İptal bu yüzden hiçbir şeyi geri almaz.
var _selected: Array[String] = []
var _prefill: Dictionary = {}            # iptal edilen build'in {type, features, name}
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
## Onay kartının tek not satırı: plan geçersizse REDDİN GEREKÇESİ, geçerliyse §5'in
## cila hatırlatması. İki ayrı satır tutmak boş bir satır bırakırdı — not YA reddi
## YA da ipucunu söyler, ikisi aynı anda anlamlı değil.
var _note_label: Label = null

# Kilitli mod durum kartı referansı
var _status_bar: Control = null          # BuildBar örneği (kendi modelini kendi çeker)


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
		# Hat modeli: kilitli görünüm build'in PLANINI okur. Ship edilmiş kademeler
		# ayrıca taşınmaz — onlar zaten hat durumlarında (ProductState.line_tier) ve
		# hat listesi onları kendi çiziyor (soluk + ✓).
		for sid in lb.planned_step_ids:
			_selected.append(String(sid))
		_rebuild()
		return
	if _v2_mode:
		_step = 3
		_type_id = String(GameState.get_flag("mvp_sub_product_type_id", ""))
		_market = String(GameState.get_flag("mvp_market_type", "b2c"))
	elif not _prefill.is_empty():
		# İptal edilen build'in seçimi geri gelir (yanlış-tık affı) — ya da sekme değişiminde
		# saklanan TASLAK: aynı şekil, artı yalnız yol seçilmişse
		# `market`.
		_type_id = String(_prefill.get("type", ""))
		if _type_id != "":
			_market = ProductCatalog.get_market_type(_type_id)
		elif String(_prefill.get("market", "")) != "":
			_market = String(_prefill.get("market", ""))
		for fid in _prefill.get("features", []):
			_selected.append(String(fid))
	# Adım tutarlılığı: tip yoksa 03, yol yoksa 02 açılamaz.
	if _step == 3 and _type_id == "" and not _v2_mode:
		_step = 1
	if _step == 2 and _market == "":
		_step = 1
	_rebuild()


func repaint() -> void:
	# Saatlik/günlük sinyaller. Alt bandın rakamları oynar (kasa, ~gün) VE iki alt
	# görünüm kendi tazelemesini yapar: hat satırlarının kapı durumu ile ekip
	# satırlarının müsaitliği İK'da değişir (eğitim biter, izin döner) ve o değişimi
	# bu ekran üretmez — okur. İkisi de yerinde tazeler, ağacı yeniden kurmaz.
	if _step != 3:
		return
	if _lines_view != null and is_instance_valid(_lines_view):
		_lines_view.repaint()
	if _team_panel != null and is_instance_valid(_team_panel):
		_team_panel.repaint()
	if _radar != null and is_instance_valid(_radar):
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
	_status_bar = null

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
	# §3 — v1: Yol → Tip → Özellikler. v2+: yol/tip SORULMAZ, şerit S4'ün iki adımlı
	# telgrafına döner (01 ÖZELLİKLER → 02 EKİP). İkisi TEK EKRANDA yan yana duruyor
	# (direktör hükmü 2026-08-25), yani ikinci kalem bir sonraki sayfa değil, aynı
	# sayfanın sağ sütunu — şerit ilerleme değil TELGRAF.
	var items := [tr("PROD_STEP_FEATURES"), tr("PROD_TEAM_HEADER")] if _v2_mode \
		else [tr("PROD_STEP_PATH"), tr("PROD_STEP_TYPE"), tr("PROD_STEP_FEATURES")]
	for i in items.size():
		if i > 0:
			hb.add_child(UiFactory.make_label("→", &"SectionLabel", UiTokens.INK_DIM))
		# v2'de şerit iki kalemli ve HER İKİSİ de bu ekranda; ilki "buradasın" diye
		# yanar, ikincisi sağ sütunu telgraflar (S4a: 02 sönük çizilmiş).
		var active: bool = (i == 0) if _v2_mode else (_step == i + 1)
		hb.add_child(UiFactory.make_label(items[i], &"SectionLabel",
			UiTokens.ACCENT_DEEP if active else UiTokens.INK_DIM))
	return hb


# --- 01 YOL ------------------------------------------------------------------

func _build_step1(body: VBoxContainer) -> void:
	body.add_child(UiFactory.make_label(tr("PROD_PATH_TITLE"), &"TitleSerif"))
	body.add_child(UiFactory.make_label(
		tr("PROD_PATH_SUB"), &"CaptionMuted"))
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
	vb.add_child(UiFactory.make_label(tr("PROD_TYPE_EXAMPLES"), &"SectionLabel"))
	var pills := HFlowContainer.new()
	pills.add_theme_constant_override("h_separation", 6)
	pills.add_theme_constant_override("v_separation", 4)
	# "Örnekler" OYNANABİLİR olanlardır. Kilitli havuzdan bir ad göstermek yolu
	# olmayan bir kapı vaat ederdi: oyuncu B2B'yi o çipe bakarak seçer ve tip
	# ekranında o ürünü tıklayamaz.
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
	col.add_child(UiFactory.make_label(tr("PROD_MENTOR_TAG"), &"SectionLabel", UiTokens.CREAM_DIM))
	var quote := UiFactory.make_label(
		tr("PROD_MENTOR_LINE"),
		&"QuoteSerifCream")
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
	var back := Button.new()
	back.text = tr("PROD_BACK_PATH")
	back.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	back.pressed.connect(func() -> void:
		_step = 1
		_rebuild())
	body.add_child(back)
	body.add_child(UiFactory.make_label(
		tr("PROD_TYPE_STEP_TITLE").format({"market": Fmt.upper(_market)}), &"TitleSerif"))
	body.add_child(UiFactory.make_label(
		tr("PROD_TYPE_STEP_SUB"), &"CaptionMuted"))
	var grid := GridContainer.new()
	grid.columns = 3
	grid.add_theme_constant_override("h_separation", 12)
	grid.add_theme_constant_override("v_separation", 12)
	body.add_child(grid)
	# §12.11 MÜHÜRLÜ: oynanabilir alt-tipler ÖNCE, sonra yol başına ÜÇ kilitli kart.
	# Katalogdaki her B2C/B2B kaydını dökmek ARTIK YANLIŞ olurdu — o kayıtların
	# çoğunun hat içeriği yok ve kartı tıklayan oyuncu boş bir Konsept'e düşerdi.
	for st in ProductCatalog.playable_types(_market):
		grid.add_child(_make_type_card(st))
	for tid in ProductCatalog.locked_type_ids(_market):
		grid.add_child(_make_locked_type_card(String(tid)))


func _make_type_card(st: Dictionary) -> Control:
	var card := PanelContainer.new()
	card.theme_type_variation = &"CardPanel"
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 6)
	card.add_child(vb)
	vb.add_child(UiFactory.make_label(ProductCatalog.type_name(String(st.get("id", ""))), &"NameSerif"))
	vb.add_child(UiFactory.make_label(ProductCatalog.type_category(String(st.get("id", ""))), &"SectionLabel"))
	var d := UiFactory.make_label(ProductCatalog.type_desc(String(st.get("id", ""))), &"BodySerif")
	d.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vb.add_child(d)
	var pills := HFlowContainer.new()
	pills.add_theme_constant_override("h_separation", 6)
	pills.add_theme_constant_override("v_separation", 4)
	for s in ProductCatalog.type_sector_labels(String(st.get("id", ""))):
		pills.add_child(UiFactory.make_pill(String(s),
			UiTokens.NEUTRAL_BADGE_BG, UiTokens.NEUTRAL_BADGE_FG, false))
	vb.add_child(pills)
	var pm := UiFactory.make_label(ProductCatalog.type_tradeoff(String(st.get("id", ""))), &"QuoteSerif")
	pm.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vb.add_child(pm)
	HRUiShared.set_mouse_ignore(vb)
	card.gui_input.connect(_on_type_card_input.bind(String(st.get("id", ""))))
	return card


## §3 tip ekranı telgrafı (MÜHÜRLÜ): "solo-gerçekçi olmayan alt-tipler kilitli-görünür
## kartlardır; küçük 'Erken Erişim' etiketi + gerekçe satırı 'Daha büyük ekip ister.'
## taşırlar." Kart TIKLANMAZ ve gri değil SOLUK çizilir — okunabilir kalır, çünkü işi
## Erken Erişim'in ne getireceğini söylemek.
##
## §12.11'in AÇIK SLOT'u ayrı bir gerekçe taşır: o bir ürün değil, henüz verilmemiş
## bir ruling. Ona ürünün gerekçesini yazmak yalan olurdu.
func _make_locked_type_card(type_id: String) -> Control:
	var is_slot: bool = type_id == ProductCatalog.TYPE_SCREEN_SLOT
	var card := PanelContainer.new()
	card.theme_type_variation = &"CardPanel"
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.modulate.a = LOCKED_CARD_ALPHA
	card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 6)
	card.add_child(vb)

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
		back_p.text = tr("PROD_BACK_PORTFOLIO")
		back_p.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
		back_p.pressed.connect(func() -> void:
			navigate_requested.emit("portfoy", {}))   # LOC-DATA route id
		body.add_child(back_p)
	elif not _v2_mode:
		var back := Button.new()
		back.text = tr("PROD_BACK_TYPE")
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
		var pname: String = b.product_name if b != null and b.product_name != "" else ProductCatalog.type_name(String(st.get("id", "")))
		head.add_child(UiFactory.make_label(pname, &"NameSerif"))
		var meta := UiFactory.make_label(
			"%s · %s" % [UiTokens.tr_upper(_market), UiTokens.tr_upper(ProductCatalog.type_name(String(st.get("id", ""))))], &"SectionLabel")
		meta.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		head.add_child(meta)
	else:
		head.add_child(UiFactory.make_label(
			"%s / %s" % [UiTokens.tr_upper(_market), ProductCatalog.type_name(String(st.get("id", "")))], &"NameSerif"))
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(spacer)
	if _locked_mode:
		# Kilit telgrafı: durum rozeti (hat satırları inert).
		head.add_child(UiFactory.make_badge(tr("LOCK_BUILD_IN_PROGRESS"), &"accent"))
	body.add_child(head)

	# --- TEK EKRAN, İKİ SÜTUN (direktör hükmü 2026-08-25) ---------------------
	# S4a hat listesini, EKİP panelini ve onay bloğunu TEK artboard'da çiziyor:
	# oyuncu kademeyi seçerken kimin taşıyacağını görüyor. Şeritteki "02 EKİP"
	# bir sonraki sayfa değil, sağdaki sütun.
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
	# "→ Araştır" canlı bağı. SAVUNMALI BAĞLANIR ve dize üzerinden: sinyal Ar-Ge paketiyle
	# geliyor, ve tipli bir `_lines_view.research_requested` yazımı sinyal henüz yokken
	# DERLEME hatası olurdu — bu sayfa da o an hiç açılmazdı.
	if _lines_view.has_signal("research_requested"):
		_lines_view.connect("research_requested", _on_research_requested)
	if _locked_mode:
		# Yapım sürerken plan DEĞİŞMEZ; liste okunur kalır ama tıklanmaz.
		HRUiShared.set_mouse_ignore(_lines_view)

	var right := VBoxContainer.new()
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right.size_flags_stretch_ratio = COL_RATIO_SIDE
	right.add_theme_constant_override("separation", 12)
	cols.add_child(right)
	right.add_child(_make_profile_card())
	# §3 — ekip çoklu seçim, kurucu dahil, ve LİDER satırı. Kilitli modda da durur:
	# "Lider yapım sürerken ayrılırsa oyuncu ekip panelinden YENİ LİDER ATAYABİLİR."
	_team_panel = ProductTeamPanel.new()
	_team_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right.add_child(_team_panel)
	var lb2: FeatureBuild = ProductSystem.get_active_build()
	var seed_lead: String = lb2.lead_engineer_id if (_locked_mode and lb2 != null) else _default_lead_id()
	_team_panel.setup(_team_seed_ids(lb2), seed_lead)
	_team_panel.selection_changed.connect(_on_team_selection_changed)
	_team_panel.lead_changed.connect(_on_lead_changed)

	body.add_child(_make_bottom_band())
	_update_dynamic()


## Kurucu her zaman listede ve varsayılan taşıyıcıdır (§3).
func _default_lead_id() -> String:
	var f: Character = CharacterRegistry.get_founder()
	return f.id if f != null else ""


## Kilitli modda build'in kendi ekibi; aksi hâlde Build işine ATANMIŞ olanlar —
## oyuncu Görevler'de kimi build'e koyduysa Konsept onu seçili açar.
func _team_seed_ids(_lb: FeatureBuild) -> Array:
	var out: Array[String] = []
	for c in ProductSystem.build_carriers():
		out.append(c.id)
	if out.is_empty():
		var f: Character = CharacterRegistry.get_founder()
		if f != null:
			out.append(f.id)
	return out


## §12.0 "atama açar": panelin seçimi HR'ın BUILD işine YAZILIR, panel ikinci bir kadro
## TUTMAZ. Tutsaydı §6.1'in her gün okuduğu liste (build_carriers) ile ekranın gösterdiği
## liste ayrışırdı — Write-Through Yasası'nın tam olarak yasakladığı şey. Yazar tek:
## CharacterRegistry; burası yalnız hangi seam'in çağrılacağına karar veriyor.
func _on_team_selection_changed(ids: Array) -> void:
	var want: Dictionary = {}
	for raw in ids:
		want[String(raw)] = true
	for c in ProductSystem.build_carriers():
		if not want.has(c.id):
			CharacterRegistry.unassign_job(c.id, HRConstants.JOB_BUILD)
	var refusal: String = ""
	for cid in want.keys():
		var id: String = String(cid)
		var c2: Character = CharacterRegistry.get_character(id)
		if c2 == null:
			continue
		# AR-GE §5.0'IN TERS YÖNÜ TAM OLARAK BU SATIR. Eskiden burada `clear_jobs` vardı —
		# "önce bırak, sonra ata" — ve o çağrı bugün araştırmayı da düşürür, duraklamış
		# defteri de siler: kurucu araştırırken oyuncu bir yapım başlatsa araştırma
		# GERİ DÖNÜLEMEZ biçimde giderdi. §5.0 bunun yerine duraklamayı emrediyor:
		# "kurucu araştırma yaparken yeni bir yapım başlatır → araştırma duraklar, yapım
		# başlar." Çıplak `assign_job` bunu kendisi yapıyor (yer değiştirme tek yazarda),
		# ve kurucuya özel dal artık gereksiz — kural kurucuya değil KİŞİYE bakıyor.
		var err: String = CharacterRegistry.assign_job(id, HRConstants.JOB_BUILD)
		if err != "":
			refusal = err
	if refusal != "":
		# Reddedilen atama ekranda KABUL EDİLMİŞ gibi duramaz: panel HR'dan yeniden kurulur
		# ve gerekçe not satırına yazılır. Erteleme, paneli kendi sinyalinin altından
		# çekmemek için (team_panel'in kendi `call_deferred` ihtiyatıyla aynı sebep).
		_reseed_team.call_deferred(refusal)
		return
	_update_dynamic()


func _reseed_team(refusal_code: String) -> void:
	if _team_panel == null or not is_instance_valid(_team_panel):
		return
	var lb: FeatureBuild = ProductSystem.get_active_build()
	var lead: String = lb.lead_engineer_id if (_locked_mode and lb != null) else _team_panel.lead_id()
	_team_panel.setup(_team_seed_ids(lb), lead)
	_update_dynamic()
	if _note_label != null:
		_note_label.text = tr(TEAM_REFUSAL_KEYS.get(refusal_code, "PROD_TEAM_REFUSE_OTHER"))


## Yapımı taşıyan lider. Panel yoksa (kilitli görünüm henüz kurulmadıysa) build'in
## kendi liderine, o da yoksa kurucuya düşer — §6.1 lidersiz de çalışır (çarpan 1,0).
func _lead_id() -> String:
	if _team_panel != null and is_instance_valid(_team_panel):
		var id: String = _team_panel.lead_id()
		if id != "":
			return id
	var b: FeatureBuild = ProductSystem.get_active_build()
	if b != null and b.lead_engineer_id != "":
		return b.lead_engineer_id
	return _default_lead_id()


func _on_lines_selection_changed(step_ids: Array) -> void:
	_selected.clear()
	for sid in step_ids:
		_selected.append(String(sid))
	_update_dynamic()


func _on_train_or_hire_requested() -> void:
	EventBus.tab_changed.emit("hr")   # LOC-DATA tab id — "→ Eğit / İşe al" canlı bağ


## Kilitli K3'ün "→ Araştır" bağı: Ar-Ge sekmesini aç ve düğümü göster.
## İKİ EMİR ARASINDA `self`'E DOKUNULMAZ. `tab_changed` SENKRON monte ediyor, yani ilk
## emirden döndüğümüzde bu sayfa çoktan `queue_free` edilmiştir; buradan sonra bir alan
## okumak ya da bir `await` yazmak serbest bırakılmış bir düğüme uzanmak olur.
## Taslak kaybı YOK: sekme yönlendiricisi sayfayı bırakmadan önce `on_page_closing`
## çağırıyor ve o an v1 taslağı `creation_draft` bayrağına yazılmış oluyor.
func _on_research_requested(node_id: String) -> void:
	EventBus.tab_changed.emit("rnd")
	EventBus.rnd_node_requested.emit(node_id, false)


## §3 — lider yapım sürerken değiştirilebilir; yapım geriye dönük BOZULMAZ.
func _on_lead_changed(id: String) -> void:
	if _locked_mode:
		ProductSystem.set_build_lead(id)
	_update_dynamic()


# --- Alt bant: radar + ÜRÜN PROFİLİ + commit ---------------------------------

## S4a'nın sağ sütun başı: ÜRÜN PROFİLİ — üçgen + eksen okumaları.
## Yüzde ve "+N" YOK: hat modelinde kazanç kademenin kendi satırında yazıyor
## (§12.9), burada tekrarlanması aynı sayıyı iki yerde tutmak olurdu.
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


## Alt bant: yalnız onay (ya da kilitli modda durum kartı). Profil ve ekip artık
## sağ sütunda yaşıyor.
func _make_bottom_band() -> Control:
	return _make_build_status_card() if _locked_mode else _make_commit_card()


func _make_build_status_card() -> Control:
	# ONAYLI KART, DAHA BÜYÜK BOYDA (B5.3). Eskiden burada genişletilmiş bir
	# dört-faz görünümü vardı: üç faz etiketi, durum satırı, beta satırı, tavan
	# satırı ve iki geçiş düğmesi. Kartın üç satırı bunların hepsini zaten
	# söylüyor ve 2i kartta TEK basılabilir şey istiyor, yani ikisi bir arada
	# duramazdı. İPTAL kalıyor: o sayfanın kendi kontrolü, kartın parçası değil —
	# düşseydi `ProductSystem.cancel_build` oyunda erişilemez hâle gelirdi.
	var card := PanelContainer.new()
	card.theme_type_variation = &"CardPanel"
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.size_flags_stretch_ratio = 1.4
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 10)
	card.add_child(vb)
	vb.add_child(UiFactory.make_section_header(tr("PROD_BUILD_STATUS_HEADER")))
	_status_bar = _BUILD_BAR_SCENE.instantiate()
	# 1.25×: aynı düzenin büyüğü, yeni bir düzen DEĞİL. size_scale satır
	# yükseklikleriyle yazı boylarını birlikte büyütür.
	_status_bar.size_scale = 1.25
	_status_bar.custom_minimum_size = Vector2(0, 138 * 1.25)
	_status_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vb.add_child(_status_bar)
	# İptal, ESKİ BODY'DEKİ BİÇİMİYLE korundu (flat + INK_MUTED) — `GhostButton` diye bir
	# tema varyasyonu YOK ve bir yenisini icat etmek UI/STYLE LAW'un kapısını gerektirirdi.
	var cancel := Button.new()
	cancel.flat = true
	cancel.text = tr("PROD_CANCEL_BUILD")
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
		_name_edit.placeholder_text = tr("PROD_NAME_LABEL")
		_name_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		if not _prefill.is_empty():
			_name_edit.text = String(_prefill.get("name", ""))
		name_row.add_child(_name_edit)
		var sug := Button.new()
		sug.text = tr("PROD_NAME_SUGGEST")
		sug.pressed.connect(_on_suggest_pressed)
		name_row.add_child(sug)
		vb.add_child(name_row)
	# SORUMLU DROPDOWN'I GİTTİ (§3, S4a). Yerini sağ sütundaki ProductTeamPanel aldı:
	# tek lider seçen bir kutu değil, ÇOKLU SEÇİM + ayrı LİDER satırı. Ekip artık bir
	# dropdown'ın tek satırı değil, ekranın yarısı — çünkü kimin taşıdığı §6.1'in
	# efor formülünün girdisi ve oyuncu onu kademe seçerken görmeli.
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
	return card


func _on_suggest_pressed() -> void:
	if _name_edit != null:
		_name_edit.text = ProductCatalog.suggest_product_name(_suggest_i)
		_suggest_i += 1


# --- Canlı güncelleme (yalnız alt bant + sayaçlar) ----------------------------

func _update_dynamic() -> void:
	if _radar == null or not is_instance_valid(_radar):
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
		var cell: Dictionary = _legend[axis]
		var bar: ProgressBar = cell.bar
		bar.max_value = maxv
		bar.value = float(dims.get(axis, 0.0))
		(cell.value as Label).text = Fmt.number(float(dims.get(axis, 0.0)), 1)
	# Kilitli mod: onay kartı yok, plan da değişmiyor.
	if _locked_mode:
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
	# Onay YALNIZ geçerli bir planla açılır; doğrulayıcı TEK (§18) — burada ikinci
	# bir merdiven/kapı kontrolü YAZILMAZ.
	var refusal: String = ProductSystem.validate_line_plan(_type_id, _selected)
	_commit_btn.disabled = refusal != ""
	# Not satırı: red varsa gerekçe, yoksa §5'in cila hatırlatması.
	_note_label.text = refusal if refusal != "" else tr("PROD_POLISH_NOTE")
	var suffix: String = ""
	if cost > 0:
		suffix = tr("PROD_CASH_DEDUCT").format({"amount": ProductUiShared.money_tr(cost)})
	_commit_btn.text = tr("PROD_CONFIRM_START") + suffix


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
		# HAT MODELİ: geri gelen şey PLAN'dır (planned_step_ids), düz özellikler değil.
		# İptal hat durumlarına zaten dokunmadı — plan hiç yazılmamıştı — o yüzden
		# prefill'in geri verdiği kademe seti hâlâ birebir geçerli.
		"features": b.planned_step_ids.duplicate(),
		"name": b.product_name,
	}
	EventBus.confirm_requested.emit({
		"title": tr("PROD_CANCEL_BUILD_Q"),
		"body": tr("PROD_CANCEL_BUILD_BODY") if early
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
	# TEK GİRİŞ (§6): v1 ve v2 aynı seam'den geçer. start_line_build sürüm numarasını
	# ve is_version_build'i ProductState.is_live()'dan KENDİ türetir; burada iki ayrı
	# çağrı tutmak aynı kararı ikinci bir yerde tekrar vermek olurdu.
	# Ve KADEMELER BURADA YAZILMAZ: plan build'e gider, hat durumlarına yalnız
	# yayında dokunulur (_apply_line_plan_at_ship) — iptalin hiçbir şeyi geri
	# almaması bu yüzden yapısaldır, bir geri-alma koduna bağlı değil.
	var pname: String = _name_edit.text if _name_edit != null else ""
	var ok: bool = ProductSystem.start_line_build(_type_id, _selected, _lead_id(), pname)
	if ok:
		GameState.flags.erase("creation_draft")   # the draft became a build
		navigate_requested.emit("tracker", {})


## Draft guard. The tab router calls this on every page it
## frees (Esc, ✕, rail, ODA click-through, palette/language rebuild). An in-progress v1 draft
## — a chosen path, a type, ticked features, a typed name — is stashed into the typed
## `creation_draft` flag; ProductTab re-hydrates it on its next mount through the same
## prefill path a cancelled build uses. Locked views and the v2 picker (a few clicks, the
## live product's own flags) are not drafts.
func on_page_closing() -> void:
	if _locked_mode or _v2_mode:
		return
	var name_text: String = _name_edit.text if _name_edit != null else ""
	var dirty: bool = _market != "" or _type_id != "" or not _selected.is_empty() or name_text != ""
	if not dirty:
		GameState.flags.erase("creation_draft")
		return
	GameState.set_flag("creation_draft", draft_state())


## The draft as the prefill dict (also what the smoke suite reads).
func draft_state() -> Dictionary:
	var name_text: String = _name_edit.text if _name_edit != null else ""
	return {"step": _step, "market": _market, "type": _type_id, "features": _selected.duplicate(), "name": name_text}


# --- Yardımcılar ---------------------------------------------------------------

func _is_left_click(ev: InputEvent) -> bool:
	return ev is InputEventMouseButton and ev.pressed \
		and (ev as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT

