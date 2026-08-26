class_name PublishFlow
extends VBoxContainer

# =============================================================================
# YAYIN AKIŞI — onaylı S7. v1 üç adımdır (B2C) ya da iki adımdır (B2B); v2+ tek
# onaydır. Kod-inşa, sahne yok (pricing_panel.gd ile aynı gramer).
#
# ADIM SAYISI PAZARDAN GELİR. B2B'nin FİYAT adımı YOKTUR — B2B fiyatı pitch'te
# kararlaştırılır, o yüzden bu akış onu bir daha sormaz. B2B yolu: ALTYAPI → ONAY.
#
# 02 · ALTYAPI'NIN S7 KARESİ GEÇERSİZ. Kare üç sabit paket çiziyordu ("Ekonomik /
# Standart / Yüksek" — her biri tek satırda kapasite VE fiyat taşıyan tek bir
# seçim). §10 mühürlü hükmü bunun tam tersini söylüyor: "Altyapı iki ayrı
# karardır: kimden alıyorsun (SAĞLAYICI) ve ne kadar alıyorsun (KAPASİTE). Tek
# sütuna sıkıştırılmaz." Bu adım o yüzden İKİ BÖLÜMDÜR ve ikisi hiçbir durumda
# tek bir listeye katlanmaz. Kare geçersizken bile kart ANATOMİSİ korundu: aynı
# 400px kart, aynı serif başlık, aynı kural çizgisi, aynı amber commit.
#
# SAYI ÜRETİLMEZ. Sağlayıcı fiyatı, birim boyu, aylık fatura ve önerilen ilk
# birim InfraSystem'den okunur; hiçbiri burada yeniden hesaplanmaz (HRUiShared'ın
# "bu klasörde hiçbir sayı türetilmez" kuralının ürün tarafındaki karşılığı).
# Fiyat rayının aralığı da SalesSystem.product_value()'dan gelir — pricing_panel
# ile AYNI ifadeyle, ki iki yüzey aynı ürün için aynı rayı çizsin.
#
# TASLAK ÖNCE, TAAHHÜT SONRA (work_hours_modal kalıbı). Sağlayıcı ve kapasite
# `_draft_*` alanlarında yaşar; motora yalnız adımın commit düğmesi dokunur
# (InfraSystem.set_provider / set_capacity). Fiyat adımının taahhüdü
# SalesSystem.apply_b2c_price'tır. Böylece akış içinde gezinmek tek başına
# oynanmamış bir ekonomik delta üretmez.
#
# MOUNT: PanelLayer, ModalLayer DEĞİL (hr_tab._open_atlas'ın gerekçesi). ModalLayer
# Space'i ve 1-3 hız tuşlarını yutuyor; bir yayın kararının üstünden saati
# çalıştırmak da, saati tamamen öldürmek de bu akışın işi değil. PanelLayer
# sayfanın alt ağacının DIŞINDA olduğu için kök `PROCESS_MODE_ALWAYS` taşır.
# Esc'in sahibi PanelLayer sakinidir (game_shell Guard 3) — `ui_cancel` burada
# `cancelled` olur.
# =============================================================================

signal publish_confirmed()
signal cancelled()
## Tek-adım modunda (canlı sayfadan ALTYAPI) akışın sonu bir YAYIN değildir: karar
## yazıldı, kart kapanır. Ayrı sinyal, çünkü `publish_confirmed`'a bağlanan taraf
## `ProductSystem.launch()` çağırır ve canlı bir ürünü ikinci kez yayınlamak yanlış olurdu.
signal step_committed()

## İç adım kimlikleri — İngilizce ve ekrana ham yazılmaz (başlıkları anahtardan gelir).
const STEP_PRICE := "price"
const STEP_INFRA := "infra"
const STEP_CONFIRM := "confirm"
const STEP_QUICK := "quick"     # v2+ tek onay popover'ı

## S7 kart genişliği. Üç adımın da aynı kartı olması karenin kendi kuralı.
const CARD_W := 400
const RULER_H := 22
const RULER_RAIL_H := 1.0
const RULER_FILL_H := 3.0
const RADIO_BOX := 14
const STEP_BTN := Vector2(22, 24)
const STEP_VALUE_W := 84

var _is_first_version: bool = true
var _market: String = ""
var _steps: Array[String] = []
var _index: int = 0

# Taslak — motora yalnız commit düğmeleri yazar.
var _draft_price: int = 0
var _draft_provider: String = ""
var _draft_units: int = 0
var _price_seeded: bool = false
var _single_step: bool = false

var _column: VBoxContainer = null
var _ruler_fill: ColorRect = null
var _slider: HSlider = null


func _ready() -> void:
	# PanelLayer sakini: sayfanın alt ağacında değiliz, o yüzden duraklamış oyunda
	# da işlemeye devam etmeliyiz — yoksa kart açıkken hiçbir düğme cevap vermez.
	process_mode = Node.PROCESS_MODE_ALWAYS
	# ANCHOR + OFFSET, yalnız anchor DEĞİL. `set_anchors_preset` çapaları koyar ama
	# offset'leri olduğu yerde bırakır, ve bir Container kendi asgari boyutunda kalır:
	# kart 400px genişliğinde SOL ÜST köşede doğar, üst barın altında yarısı kesik.
	# PanelLayer bir CanvasLayer, yani bizi boyutlandıracak bir ebeveyn Control yok —
	# tam ekranı biz istemek zorundayız.
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	# Kartın ALTINDAKİ sayfa tıklanamaz: karar veriliyor. Kare karartma çizmiyor
	# (S7'de üst bar, ray ve ticker normal duruyor), o yüzden scrim YOK — kart
	# ModalCard'ın kendi yumuşak gölgesiyle yüzüyor.
	mouse_filter = Control.MOUSE_FILTER_STOP
	alignment = BoxContainer.ALIGNMENT_CENTER

	_column = VBoxContainer.new()
	_column.add_theme_constant_override("separation", UiTokens.SPACE_M)
	_column.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	add_child(_column)


## TEK MOUNT NOKTASI. Yayın kararı üç ayrı yerden başlar (yüzen Build Takip Kartı ·
## ODA monitörü · Konsept'in yapım durum kartı) ve üçü de AYNI BuildBar'ın BETA
## aksiyonudur; mount kodunu üç eve kopyalamak yerine akış kendi kapısını taşır.
## PanelLayer kökten bulunur, yani çağıranın ağacın neresinde olduğu önemsizdir —
## ODA monitöründen basılan "Yayınla" ile sekmeden basılan aynı kartı açar.
##
## `only_step` verilirse akış O TEK ADIMDIR (§10: "Sağlayıcı canlıda her an
## değiştirilebilir"), commit'te kapanır ve HİÇBİR ŞEY YAYINLAMAZ.
static func open(only_step: String = "") -> PublishFlow:
	var tree := Engine.get_main_loop() as SceneTree
	if tree == null:
		return null
	var layer: Node = tree.get_root().find_child("PanelLayer", true, false)
	if layer == null:
		push_error("[PublishFlow] GameShell/PanelLayer yok — yayın akışı monte edilemiyor")
		return null
	for c in layer.get_children():
		if c is PublishFlow:
			return c as PublishFlow          # zaten açık; ikinci kopya açılmaz
	var pf := PublishFlow.new()
	layer.add_child(pf)                      # önce add_child, sonra setup (ev konvansiyonu)
	pf.publish_confirmed.connect(func() -> void:
		ProductSystem.launch()               # WRITE-THROUGH: kart değil seam yayınlar
		pf.queue_free())
	pf.cancelled.connect(pf.queue_free)
	pf.step_committed.connect(pf.queue_free)
	pf.setup(not ProductState.is_live(), ProductState.market_type(), only_step)
	return pf


## Ev sahibi ÖNCE add_child eder, SONRA burayı çağırır (ev kuralı — work_hours_modal.populate).
func setup(is_first_version: bool, market: String, only_step: String = "") -> void:
	_is_first_version = is_first_version
	_market = market if market != "" else ProductState.market_type()
	if not is_node_ready():
		await ready

	_steps.clear()
	_single_step = only_step != ""
	if _single_step:
		_steps.append(only_step)
	elif _is_first_version:
		# B2B'nin fiyat adımı YOK: fiyat pitch'te kararlaşır (§ pazar ayrımı).
		if not _is_b2b():
			_steps.append(STEP_PRICE)
		_steps.append(STEP_INFRA)
		_steps.append(STEP_CONFIRM)
	else:
		# v2+: fiyat ve altyapı SORULMAZ. Tek küçük onay, aynı hata tooltip'iyle.
		_steps.append(STEP_QUICK)
	_index = 0
	_seed_draft()
	_render()


## Router repaint zinciri. Adım İLERLETMEZ — yalnız o anki adımı tazeler.
func repaint() -> void:
	if _column == null:
		return
	_render()


# --- taslak -------------------------------------------------------------------

func _is_b2b() -> bool:
	return _market == InfraSystem.MARKET_B2B


func _seed_draft() -> void:
	# Sağlayıcı: durumda varsa ODUR. Yoksa merdivenin ORTA basamağı — bu bir icat
	# değil, S7'nin kendi ön-işaretli seçeneği (kare orta paketi ✓'li çiziyor).
	var live_provider: String = InfraSystem.provider()
	if InfraSystem.is_provider(live_provider):
		_draft_provider = live_provider
	else:
		_draft_provider = String(InfraSystem.PROVIDER_IDS[1])
	# Kapasite: durumda varsa ODUR, yoksa §10'un önerdiği ilk birim.
	var live_units: int = InfraSystem.units()
	_draft_units = live_units if live_units > InfraSystem.CAPACITY_MIN \
		else InfraSystem.suggested_start_units()


func _seed_price(optimal: int) -> void:
	# Grabber zıplama koruması (pricing_panel'in `_pricing_initialized`'ı): ray
	# değeri BİR KEZ tohumlanır, sonraki her boyama ondan okur.
	if _price_seeded:
		return
	var is_open: bool = GameState.get_flag("b2c_paid_tier_open", false)
	_draft_price = int(GameState.get_flag("b2c_price", optimal)) if is_open else optimal
	_price_seeded = true


# --- yönlendirme ---------------------------------------------------------------

func _render() -> void:
	_ruler_fill = null
	_slider = null
	for c in _column.get_children():
		_column.remove_child(c)
		c.queue_free()
	match _current_step():
		STEP_PRICE: _build_price_step()
		STEP_INFRA: _build_infra_step()
		STEP_CONFIRM: _build_confirm_step()
		_: _build_quick_step()


func _current_step() -> String:
	if _index < 0 or _index >= _steps.size():
		return STEP_QUICK
	return _steps[_index]


func _advance() -> void:
	if _index + 1 < _steps.size():
		_index += 1
		_render()
		return
	if _single_step:
		step_committed.emit()


func _step_caption(title_key: String) -> Control:
	# "01 · FİYAT" — sıra numarası adımın AKIŞTAKİ yerinden gelir, sabit değil:
	# B2B'de altyapı 01'dir, B2C'de 02. İki basamaklı yazılır (S7).
	var n: String = "%02d" % (_index + 1)
	return UiFactory.make_label(
		tr("PROD_PUB_STEP_CAPTION").format({"n": n, "title": tr(title_key)}), &"SectionLabel")


func _card() -> VBoxContainer:
	# S7 kart anatomisi: 400px, ModalCard (#10161C · 1px #232C34 · yumuşak gölge).
	var panel := PanelContainer.new()
	panel.theme_type_variation = &"ModalCard"
	panel.custom_minimum_size = Vector2(CARD_W, 0)
	panel.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", UiTokens.SPACE_L)
	panel.add_child(box)
	_column.add_child(panel)
	return box


func _titled_card(title_key: String, caption_key: String) -> VBoxContainer:
	_column.add_child(_step_caption(caption_key))
	var box: VBoxContainer = _card()
	box.add_child(UiFactory.make_label(tr(title_key), &"TitleSerif"))
	box.add_child(HRUiShared.hairline())
	return box


# --- 01 · FİYAT ----------------------------------------------------------------
# S7 OLDUĞU GİBİ DURUYOR: taban işareti YOK, optimal işareti YOK, hüküm rozeti YOK.
# Altında TEK bilgi satırı var (kullanıcı başına maliyet) ve o satır gerçek
# durumdan hesaplanır.

func _build_price_step() -> void:
	var v: Dictionary = SalesSystem.product_value()
	var optimal: int = int(v["optimal"])
	var floor_p: int = int(v["floor"])
	# Ray aralığı pricing_panel'in İFADESİYLE AYNI — iki yüzey aynı ürün için aynı
	# rayı çizsin diye. İşaretler çizilmiyor; yalnız uçlar buradan geliyor.
	var smax: int = maxi(optimal * 3, floor_p + 4)
	_seed_price(optimal)
	_draft_price = clampi(_draft_price, 1, smax)

	var box: VBoxContainer = _titled_card("PROD_PUB_PRICE_TITLE", "PROD_PUB_STEP_PRICE")

	# Büyük figür + birim kuyruğu.
	# KAREDEN SAPMA: kare 34px mono çiziyor; skalanın tepesi SIZE_DISPLAY 22 ve
	# yeni varyasyon açmak THEME_STAMP artırımı ister. En büyük yasal adım olan
	# TitleSerif alındı (pricing_panel'in fiyat figürü de bu varyasyonu okuyor),
	# rengi token'dan amber'e çevrildi.
	var fig_row := HBoxContainer.new()
	fig_row.add_theme_constant_override("separation", UiTokens.SPACE_M)
	var figure := UiFactory.make_label(
		ProductUiShared.money_tr(_draft_price), &"TitleSerif", UiTokens.ACCENT)
	fig_row.add_child(figure)
	var per := UiFactory.make_label(tr("PROD_PER_USER_MONTH"), &"CaptionMuted")
	per.size_flags_vertical = Control.SIZE_SHRINK_END
	fig_row.add_child(per)
	box.add_child(fig_row)

	# Ray: 1px nötr çizgi + 3px amber dolgu + PriceSlider'ın şeffaf tutamacı.
	# İŞARET YOK — kare bu adımdan taban/optimal çentiklerini kaldırdı.
	box.add_child(_price_ruler(smax))

	# TEK bilgi satırı.
	var cost_line := UiFactory.make_label("", &"MicroLabel")
	box.add_child(cost_line)

	# Eksen özeti (S7: "İnovasyon 10 · Kararlılık 11 · Deneyim 19 · 3 özellik").
	var axes := UiFactory.make_label(_axis_summary_text(), &"RowMeta")
	axes.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(axes)

	var commit := Button.new()
	commit.theme_type_variation = &"CommitButton"
	commit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	commit.pressed.connect(_on_price_commit)
	box.add_child(commit)

	_repaint_price_texts(figure, cost_line, commit)
	_slider.value_changed.connect(func(value: float) -> void:
		_draft_price = int(value)
		_update_ruler_fill()
		_repaint_price_texts(figure, cost_line, commit))


func _price_ruler(smax: int) -> Control:
	var spectrum := Control.new()
	spectrum.custom_minimum_size = Vector2(0, RULER_H)
	spectrum.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var rail := ColorRect.new()
	rail.color = UiTokens.BORDER_HOVER
	rail.anchor_right = 1.0
	rail.anchor_top = 0.5
	rail.anchor_bottom = 0.5
	rail.offset_top = -RULER_RAIL_H * 0.5
	rail.offset_bottom = RULER_RAIL_H * 0.5
	rail.mouse_filter = Control.MOUSE_FILTER_IGNORE
	spectrum.add_child(rail)

	_ruler_fill = ColorRect.new()
	_ruler_fill.color = UiTokens.ACCENT
	_ruler_fill.anchor_top = 0.5
	_ruler_fill.anchor_bottom = 0.5
	_ruler_fill.offset_top = -RULER_FILL_H * 0.5
	_ruler_fill.offset_bottom = RULER_FILL_H * 0.5
	_ruler_fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	spectrum.add_child(_ruler_fill)

	_slider = HSlider.new()
	_slider.theme_type_variation = &"PriceSlider"
	_slider.min_value = 1
	_slider.max_value = smax
	_slider.step = 1
	_slider.value = float(_draft_price)
	_slider.anchor_right = 1.0
	_slider.anchor_bottom = 1.0
	spectrum.add_child(_slider)

	_update_ruler_fill()
	return spectrum


func _update_ruler_fill() -> void:
	if _ruler_fill == null or _slider == null:
		return
	var span: float = maxf(_slider.max_value - _slider.min_value, 1.0)
	_ruler_fill.anchor_right = clampf((_slider.value - _slider.min_value) / span, 0.0, 1.0)


func _repaint_price_texts(figure: Label, cost_line: Label, commit: Button) -> void:
	figure.text = ProductUiShared.money_tr(_draft_price)
	cost_line.text = tr("PROD_COST_PER_USER").format({"amount": Fmt.number(_cost_per_user(), 2)})
	commit.text = tr("PROD_PRICE_COMMIT").format({"amount": ProductUiShared.money_tr(_draft_price)})


func _on_price_commit() -> void:
	# Tek B2C gelir kolu, ve OYNANMIŞ karar. Zam churn'ü seam'in İÇİNDE tetiklenir.
	SalesSystem.apply_b2c_price(_draft_price)
	_advance()


# --- 02 · ALTYAPI --------------------------------------------------------------
# KARE GEÇERSİZ, ÇİZİM BURADA. İki bölüm, hiçbir zaman tek sütuna katlanmaz.

func _build_infra_step() -> void:
	var box: VBoxContainer = _titled_card("PROD_PUB_INFRA_TITLE", "PROD_PUB_STEP_INFRA")

	# --- KİMDEN ALIYORSUN: sağlayıcı (birim fiyat + kalite farkı) ---
	box.add_child(HRUiShared.section_header(tr("PROD_INFRA_PROVIDER_HEAD")))
	var rows := VBoxContainer.new()
	rows.add_theme_constant_override("separation", UiTokens.SPACE_S)
	for pid in InfraSystem.PROVIDER_IDS:
		rows.add_child(_provider_row(String(pid)))
	box.add_child(rows)

	# --- NE KADAR ALIYORSUN: kapasite, ±1 birim, her an, cezasız ---
	box.add_child(HRUiShared.section_header(tr("PROD_INFRA_CAPACITY_HEAD")))
	box.add_child(_capacity_row())

	# Bu seçimin aylık faturası. InfraSystem.monthly_bill() CANLI ürün ister ve v1
	# akışında ürün henüz canlı DEĞİL, o yüzden burada taslağın kendi çarpımı
	# yazılır — motorun aynı iki sayısıyla (birim × birim fiyatı, §10).
	var bill := UiFactory.make_label(
		tr("PROD_INFRA_MONTHLY_BILL").format({"amount": ProductUiShared.money_tr(_draft_bill())}),
		&"RowMeta", UiTokens.INK)
	box.add_child(bill)

	# §10 öneri satırı — KURAL DEĞİL, öneri.
	box.add_child(UiFactory.make_label(
		tr(InfraSystem.KEY_START_HINT).format({"users": _headroom_text(
			InfraSystem.suggested_start_headroom())}), &"MicroLabel"))

	# MÜHÜRLÜ SATIR.
	box.add_child(UiFactory.make_label(tr("PROD_INFRA_CAPACITY_ONLY"), &"MicroLabel"))

	var commit := Button.new()
	commit.theme_type_variation = &"CommitButton"
	commit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	commit.text = tr("PROD_INFRA_COMMIT").format({"amount":
		tr("PROD_INFRA_MONTHLY_BILL").format({"amount": ProductUiShared.money_tr(_draft_bill())})})
	commit.pressed.connect(_on_infra_commit)
	box.add_child(commit)


func _provider_row(pid: String) -> Control:
	# HOVER KENARDA YAŞAR (UI/STYLE LAW): dolgu kıpırdamaz, yalnız çerçeve açılır.
	# Seçili satır AMBER_WASH + ACCENT kenar taşır — o bir DURUM, hover değil.
	var selected: bool = pid == _draft_provider
	var row := PanelContainer.new()
	row.mouse_filter = Control.MOUSE_FILTER_STOP
	row.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_paint_provider_row(row, selected, false)

	var line := HBoxContainer.new()
	line.add_theme_constant_override("separation", UiTokens.SPACE_L)

	line.add_child(_radio_mark(selected))

	var text_col := VBoxContainer.new()
	text_col.add_theme_constant_override("separation", UiTokens.SPACE_XXS)
	text_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_col.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	text_col.add_child(UiFactory.make_label(tr(InfraSystem.provider_name_key(pid)),
		&"RowMeta", UiTokens.INK if selected else UiTokens.INK_MUTED))
	var quality := UiFactory.make_label(tr(InfraSystem.provider_quality_key(pid)), &"MicroLabel")
	quality.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text_col.add_child(quality)
	line.add_child(text_col)

	# Birim FİYATI — paket fiyatı değil. Kaç birim alındığı ikinci karardır.
	var price := UiFactory.make_label(
		tr("PROD_INFRA_UNIT_PRICE").format({"amount":
			ProductUiShared.money_tr(InfraSystem.unit_price(pid, _market))}),
		&"RowMeta", UiTokens.INK)
	price.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	line.add_child(price)

	row.add_child(line)
	HRUiShared.set_mouse_ignore(line)   # tıklama kart kökünde toplanır (ev deseni)

	row.gui_input.connect(func(event: InputEvent) -> void:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT \
				and (event as InputEventMouseButton).pressed:
			_draft_provider = pid
			_render())
	row.mouse_entered.connect(func() -> void: _paint_provider_row(row, selected, true))
	row.mouse_exited.connect(func() -> void: _paint_provider_row(row, selected, false))
	return row


func _paint_provider_row(row: PanelContainer, selected: bool, hovered: bool) -> void:
	var sb := StyleBoxFlat.new()
	sb.bg_color = UiTokens.AMBER_WASH if selected else Color(0, 0, 0, 0)
	sb.set_border_width_all(UiTokens.BORDER_HAIRLINE)
	if selected:
		sb.border_color = UiTokens.ACCENT
	else:
		sb.border_color = UiTokens.BORDER_HOVER if hovered else UiTokens.CARD_BORDER
	sb.set_corner_radius_all(UiTokens.RADIUS_M)
	sb.content_margin_left = UiTokens.PAD_CARD_TIGHT.x
	sb.content_margin_right = UiTokens.PAD_CARD_TIGHT.x
	sb.content_margin_top = UiTokens.PAD_CARD_TIGHT.y
	sb.content_margin_bottom = UiTokens.PAD_CARD_TIGHT.y
	row.add_theme_stylebox_override("panel", sb)


func _radio_mark(selected: bool) -> Control:
	var mark := PanelContainer.new()
	mark.custom_minimum_size = Vector2(RADIO_BOX, RADIO_BOX)
	mark.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0, 0, 0, 0)
	sb.set_border_width_all(UiTokens.BORDER_HAIRLINE)
	sb.border_color = UiTokens.ACCENT if selected else UiTokens.BORDER_HOVER
	sb.set_corner_radius_all(UiTokens.RADIUS_S)
	mark.add_theme_stylebox_override("panel", sb)
	var glyph := UiFactory.make_label("✓" if selected else "", &"BadgeLabel", UiTokens.ACCENT)
	glyph.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	glyph.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	mark.add_child(glyph)
	return mark


func _capacity_row() -> Control:
	# ±1 BİRİM, HER AN, CEZASIZ (§10). Tavan yok; taban InfraSystem.CAPACITY_MIN.
	# Stepper giysisi onaylı 19a'nın saat kutusudur (work_hours_modal ile aynı reçete).
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", UiTokens.SPACE_L)

	row.add_child(_step_button("−", _draft_units > InfraSystem.CAPACITY_MIN, -1))

	var value := PanelContainer.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(UiTokens.INK, 0.05)
	sb.set_border_width_all(UiTokens.BORDER_HAIRLINE)
	sb.border_color = UiTokens.BORDER_STEPPER_OWN
	sb.set_corner_radius_all(UiTokens.RADIUS_S)
	value.add_theme_stylebox_override("panel", sb)
	var lbl := UiFactory.make_label(
		tr("PROD_INFRA_UNITS_N").format({"n": _draft_units}), &"StepperValue")
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl.custom_minimum_size = Vector2(STEP_VALUE_W, STEP_BTN.y)
	value.add_child(lbl)
	row.add_child(value)

	row.add_child(_step_button("+", true, 1))

	# BİR BİRİM NE DEMEK: B2C'de 1.000 kullanıcı, B2B'de 50 koltuk (§10). Birim
	# etiketi pazarla değişen TEK şey — kart anatomisi aynı kalır.
	var headroom := UiFactory.make_label(
		_headroom_text(_draft_units * InfraSystem.unit_size(_market)), &"RowMeta")
	headroom.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	headroom.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	headroom.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	row.add_child(headroom)
	return row


func _step_button(glyph: String, enabled: bool, steps: int) -> Button:
	# SESSİZ düğme: kartın tek amber öğesi commit'tir, stepper onunla yarışmaz.
	var btn := Button.new()
	btn.text = glyph
	btn.custom_minimum_size = STEP_BTN
	btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	btn.disabled = not enabled
	if enabled:
		btn.pressed.connect(func() -> void:
			# CAPACITY_STEP adımın boyudur; işaret `steps`ten gelir (adjust_capacity grameri).
			_draft_units = maxi(_draft_units + steps * InfraSystem.CAPACITY_STEP,
				InfraSystem.CAPACITY_MIN)
			_render())
	return btn


func _on_infra_commit() -> void:
	# İKİ AYRI YAZMA, çünkü İKİ AYRI KARAR. Göç bedeli yok; yeni fiyat bir sonraki
	# günden işler (InfraSystem.set_provider'ın kendi hükmü).
	InfraSystem.set_provider(_draft_provider)
	InfraSystem.set_capacity(_draft_units)
	_advance()


# --- 03 · ONAY -----------------------------------------------------------------
# S7 OLDUĞU GİBİ DURUYOR.

func _build_confirm_step() -> void:
	var box: VBoxContainer = _titled_card("PROD_PUB_CONFIRM_TITLE", "PROD_PUB_STEP_CONFIRM")

	var rows := VBoxContainer.new()
	rows.add_theme_constant_override("separation", UiTokens.SPACE_M)
	rows.add_child(_summary_row(tr("PROD_PUB_ROW_VERSION"), _version_text()))
	if not _is_b2b():
		rows.add_child(_summary_row(tr("PROD_PUB_ROW_PRICE"),
			" ".join([ProductUiShared.money_tr(_draft_price), tr("PROD_PER_USER_MONTH")])))
	rows.add_child(_summary_row(tr("PROD_PUB_ROW_INFRA"), " · ".join([
		tr(InfraSystem.provider_name_key(_draft_provider)),
		tr("PROD_INFRA_MONTHLY_BILL").format({"amount": ProductUiShared.money_tr(_draft_bill())})])))
	rows.add_child(_summary_row(tr("PROD_PUB_ROW_FEATURES"), str(_feature_count())))
	box.add_child(rows)

	var bug_text: String = _bug_text()
	var chip: Control = UiFactory.make_state_chip(bug_text, UiTokens.INK_MUTED,
		UiTokens.SURFACE_FRAME, UiTokens.BORDER_HOVER)
	chip.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	box.add_child(chip)

	var ship := Button.new()
	ship.theme_type_variation = &"CommitButton"
	ship.text = Fmt.upper(tr("PROD_LAUNCH_PLAIN"))
	ship.tooltip_text = bug_text
	ship.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	ship.pressed.connect(func() -> void: publish_confirmed.emit())
	box.add_child(ship)


func _summary_row(label: String, value: String) -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", UiTokens.SPACE_M)
	var l := UiFactory.make_label(label, &"RowMeta", UiTokens.INK_DIM)
	l.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(l)
	var v := UiFactory.make_label(value, &"RowName")
	v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	v.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	v.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	row.add_child(v)
	return row


# --- v2+ · TEK ONAY ------------------------------------------------------------
# Fiyat ve altyapı SORULMAZ. Aynı hata tooltip'i, küçük yüzen kartta.

func _build_quick_step() -> void:
	var panel := PanelContainer.new()
	panel.theme_type_variation = &"CardFloating"
	panel.custom_minimum_size = Vector2(CARD_W, 0)
	panel.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", UiTokens.SPACE_M)
	panel.add_child(box)
	_column.add_child(panel)

	box.add_child(UiFactory.make_label(
		tr("PROD_PUB_V2_TITLE").format({"name": _version_text()}), &"RowName"))
	var bug_text: String = _bug_text()
	box.add_child(UiFactory.make_label(bug_text, &"RowMeta"))

	var actions := HBoxContainer.new()
	actions.add_theme_constant_override("separation", UiTokens.SPACE_L)
	var dismiss := Button.new()
	dismiss.text = tr("UI_DISMISS")
	dismiss.pressed.connect(func() -> void: cancelled.emit())
	actions.add_child(dismiss)
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	actions.add_child(spacer)
	var ship := Button.new()
	ship.theme_type_variation = &"CommitButton"
	ship.text = Fmt.upper(tr("PROD_LAUNCH_PLAIN"))
	ship.tooltip_text = bug_text
	ship.pressed.connect(func() -> void: publish_confirmed.emit())
	actions.add_child(ship)
	box.add_child(actions)


# --- ortak okumalar -------------------------------------------------------------

func _bug_text() -> String:
	# CEZADAN SONRAKİ sayı. ProductSystem.projected_launch_bugs() bu sorunun TEK evi:
	# ham `bug_count` yazan yüzeyler, riski göze alan oyuncuya beş eksik gösteriyordu.
	return tr("PROD_PUB_BUGS_CARRIED").format({"n": ProductSystem.projected_launch_bugs()})


func _draft_bill() -> int:
	# §10 — "aylık fatura = birim sayısı × birim fiyatı". InfraSystem.monthly_bill()
	# CANLI ürün kapısı taşıyor (v1 akışında ürün henüz canlı değil), o yüzden aynı
	# iki sayı taslak için burada çarpılır. Yeni bir kural DEĞİL, aynı kural.
	return _draft_units * InfraSystem.unit_price(_draft_provider, _market)


func _cost_per_user() -> float:
	# "Altyapı maliyeti ÷ kapasite" = birim fiyatı ÷ birim boyu. Birim SAYISINDAN
	# bağımsızdır ve olması gereken de budur: iki birim almak bir kullanıcının
	# maliyetini değiştirmez.
	var unit_size: int = maxi(InfraSystem.unit_size(_market), 1)
	return float(InfraSystem.unit_price(_draft_provider, _market)) / float(unit_size) \
		+ _api_licence_per_user_monthly()


func _api_licence_per_user_monthly() -> float:
	# SEAM MISSING (read): YİNELENEN bir API/lisans gideri motorda YOK. Katalogdaki
	# `cost` / `cost_source` ("api" | "license") build COMMIT'inde BİR KEZ tahsil
	# edilen tek seferlik kalemdir (ProductSystem → FinanceSystem.apply_one_time_cost),
	# ve FinanceSystem.BURN_IDS'te bir "api" burn kategorisi yoktur. Aylık bir payı
	# burada uydurmak, motorun taşımadığı bir aritmetiği ekrana yazmak olurdu.
	# Kategori (ya da bir ProductSystem.api_cost_monthly() okuması) doğduğu gün bu
	# fonksiyon onu döndürür ve satır kendiliğinden doğrulanır.
	return 0.0


func _headroom_text(amount: int) -> String:
	return tr("PROD_INFRA_HEADROOM_SEATS" if _is_b2b() else "PROD_INFRA_HEADROOM_USERS").format(
		{"n": Fmt.group(amount)})


func _version_text() -> String:
	# "Sable v1" / "Sable v2". Ürün adı özel isimdir, çevrilmez.
	var name: String = ProductState.product_name()
	var build: FeatureBuild = ProductSystem.active_build
	if name == "" and build != null:
		name = build.product_name
	var version: int = 1 if _is_first_version else maxi(ProductState.version(), 1) + 1
	var v: String = tr("PROD_VERSION_SHORT").format({"version": version})
	return v if name == "" else " ".join([name, v])


func _feature_count() -> int:
	# Katalog yolunda özellikler, hat modelinde kademeler sayılır — build hangisini
	# taşıyorsa o. Sayı motorun listesinden gelir, burada türetilmez.
	var build: FeatureBuild = ProductSystem.active_build
	if build == null:
		return (GameState.get_flag("mvp_components", []) as Array).size()
	if not build.feature_ids.is_empty():
		return build.feature_ids.size()
	return build.planned_step_ids.size()


func _axis_summary_text() -> String:
	# Yayınlanmakta olan BUILD'in eksenleri (canlı damganın değil): oyuncu birazdan
	# gönderdiği şeyin sayısını okur.
	var build: FeatureBuild = ProductSystem.active_build
	var inn: int = 0
	var stab: int = 0
	var exp: int = 0
	if build != null:
		inn = int(round(build.innovation))
		stab = int(round(build.stability))
		exp = int(round(build.experience))
	else:
		inn = ProductState.axis_reading("innovation")
		stab = ProductState.axis_reading("stability")
		exp = ProductState.axis_reading("experience")
	return tr("PROD_PUB_AXIS_SUMMARY").format(
		{"inn": inn, "stab": stab, "exp": exp, "n": _feature_count()})


# --- giriş ----------------------------------------------------------------------

func _unhandled_input(event: InputEvent) -> void:
	# PanelLayer sakini Esc'İN SAHİBİDİR (game_shell Guard 3 bizi görüp HANDLED
	# işaretlemeden dönüyor). Kapanma kararını ev sahibi verir: biz yalnız haber veririz.
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		cancelled.emit()
