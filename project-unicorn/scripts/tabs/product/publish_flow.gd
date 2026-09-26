class_name PublishFlow
extends VBoxContainer

# =============================================================================
# YAYIN AKIŞI (onaylı S7). v1 B2C'de üç adımdır (FİYAT → ALTYAPI → ONAY), B2B'de iki
# (ALTYAPI → ONAY): B2B fiyatı pitch'te kararlaşır, akış onu bir daha sormaz. v2+ tek
# onaydır. Kod-inşa, sahne yok.
#
# ALTYAPI İKİ BÖLÜMDÜR (§10): "kimden alıyorsun (SAĞLAYICI) ve ne kadar alıyorsun
# (KAPASİTE). Tek sütuna sıkıştırılmaz." S7 karesinin üç sabit paketi bu yüzden
# uygulanmadı; kart anatomisi (400px, serif başlık, kural çizgisi, amber commit) korundu.
#
# SAYI ÜRETİLMEZ: sağlayıcı fiyatı, birim boyu ve önerilen ilk birim InfraSystem'den,
# fiyat rayının aralığı SalesSystem.product_value()'dan okunur (pricing_panel ile aynı
# ifade, ki iki yüzey aynı ürün için aynı rayı çizsin).
#
# TASLAK ÖNCE, TAAHHÜT SONRA: seçimler `_draft_*` alanlarında yaşar; motora yalnız adımın
# commit düğmesi dokunur (SalesSystem.apply_b2c_price · InfraSystem.set_provider /
# set_capacity). Akışta gezinmek tek başına ekonomik delta üretmez.
#
# MOUNT: PanelLayer, ModalLayer değil — ModalLayer Space'i ve 1-3 hız tuşlarını yutar;
# saati çalıştırmak da öldürmek de bu akışın işi değil. PanelLayer sayfa alt ağacının
# dışında olduğu için kök PROCESS_MODE_ALWAYS taşır. Esc'in sahibi PanelLayer sakinidir.
# =============================================================================

## İç adım kimlikleri — ekrana ham yazılmaz (başlıkları anahtardan gelir).
const STEP_PRICE := "price"
const STEP_INFRA := "infra"
const STEP_CONFIRM := "confirm"
const STEP_QUICK := "quick"     # v2+ tek onay

## S7 kart genişliği; bütün adımlar aynı kartı taşır.
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

var _column: VBoxContainer = null


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	# ANCHOR + OFFSET: PanelLayer bir CanvasLayer, bizi boyutlandıracak ebeveyn Control yok.
	# Yalnız çapa konursa Container asgari boyunda kalır ve kart sol üstte, yarısı kesik doğar.
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	# Kartın altındaki sayfa tıklanamaz. S7 karartma çizmiyor, o yüzden scrim yok.
	mouse_filter = Control.MOUSE_FILTER_STOP
	alignment = BoxContainer.ALIGNMENT_CENTER
	_column = VBoxContainer.new()
	_column.add_theme_constant_override("separation", UiTokens.SPACE_M)
	_column.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	add_child(_column)


## TEK MOUNT NOKTASI. Yayın kararı üç yerden başlar (yüzen kart · ODA monitörü · Konsept'in
## durum kartı) ve üçü de aynı BuildBar'ın BETA aksiyonudur. PanelLayer kökten bulunur, yani
## çağıranın ağaçtaki yeri önemsizdir.
##
## `only_step` verilirse akış o tek adımdır (§10: "Sağlayıcı canlıda her an
## değiştirilebilir"): commit'te kapanır ve HİÇBİR ŞEY YAYINLAMAZ.
static func open(only_step: String = "") -> void:
	var layer: Node = (Engine.get_main_loop() as SceneTree).root.find_child("PanelLayer", true, false)
	if layer == null:
		push_error("[PublishFlow] GameShell/PanelLayer yok — yayın akışı monte edilemiyor")
		return
	for c in layer.get_children():
		if c is PublishFlow:
			return   # zaten açık; ikinci kopya açılmaz
	var pf := PublishFlow.new()
	layer.add_child(pf)
	pf._start(only_step)


func _start(only_step: String) -> void:
	_market = ProductState.market_type()
	_is_first_version = not ProductState.is_live()
	if only_step != "":
		_steps = [only_step]
	elif not _is_first_version:
		_steps = [STEP_QUICK]                   # v2+: fiyat ve altyapı sorulmaz
	elif _is_b2b():
		_steps = [STEP_INFRA, STEP_CONFIRM]     # B2B'nin fiyat adımı yok
	else:
		_steps = [STEP_PRICE, STEP_INFRA, STEP_CONFIRM]
	# Sağlayıcı: durumda varsa odur, yoksa merdivenin orta basamağı (S7'nin ön-işaretli
	# seçeneği). Kapasite: durumda varsa odur, yoksa §10'un önerdiği ilk birim.
	_draft_provider = InfraSystem.provider()
	if not InfraSystem.is_provider(_draft_provider):
		_draft_provider = String(InfraSystem.PROVIDER_IDS[1])
	_draft_units = InfraSystem.units()
	if _draft_units <= InfraSystem.CAPACITY_MIN:
		_draft_units = InfraSystem.suggested_start_units()
	_render()


func _is_b2b() -> bool:
	return _market == InfraSystem.MARKET_B2B


# --- yönlendirme ---------------------------------------------------------------

func _render() -> void:
	for c in _column.get_children():
		_column.remove_child(c)
		c.queue_free()
	match _steps[_index]:
		STEP_PRICE: _build_price_step()
		STEP_INFRA: _build_infra_step()
		STEP_CONFIRM: _build_confirm_step()
		STEP_QUICK: _build_quick_step()


## Son adımı commit eden yalnız tek-adım modudur (çok adımlı akışın sonu ONAY'dır): karar
## yazıldı, kart kapanır.
func _advance() -> void:
	_index += 1
	if _index < _steps.size():
		_render()
	else:
		queue_free()


func _publish() -> void:
	ProductSystem.launch()   # WRITE-THROUGH: kart değil seam yayınlar
	queue_free()


func _card(variation: StringName, separation: int) -> VBoxContainer:
	var panel := PanelContainer.new()
	panel.theme_type_variation = variation
	panel.custom_minimum_size = Vector2(CARD_W, 0)
	panel.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", separation)
	panel.add_child(box)
	_column.add_child(panel)
	return box


func _titled_card(title_key: String, caption_key: String) -> VBoxContainer:
	# "01 · FİYAT" — sıra numarası adımın akıştaki yerinden gelir: B2B'de altyapı 01'dir.
	_column.add_child(UiFactory.make_label(tr("PROD_PUB_STEP_CAPTION").format(
		{"n": "%02d" % (_index + 1), "title": tr(caption_key)}), &"SectionLabel"))
	var box: VBoxContainer = _card(&"ModalCard", UiTokens.SPACE_L)
	box.add_child(UiFactory.make_label(tr(title_key), &"TitleSerif"))
	box.add_child(HRUiShared.hairline())
	return box


func _commit_button(text: String, on_press: Callable) -> Button:
	var btn := Button.new()
	btn.theme_type_variation = &"CommitButton"
	btn.text = text
	btn.pressed.connect(on_press)
	return btn


## Onay ve v2+ kartının yayın düğmesi; tooltip'i aynı hata sayısıdır.
func _ship_button() -> Button:
	var ship: Button = _commit_button(Fmt.upper(tr("PROD_LAUNCH_PLAIN")), _publish)
	ship.tooltip_text = _bug_text()
	return ship


# --- 01 · FİYAT ----------------------------------------------------------------
# S7 olduğu gibi: taban/optimal işareti ve hüküm rozeti yok. Altında tek bilgi satırı
# (kullanıcı başına maliyet), gerçek durumdan.

func _build_price_step() -> void:
	var v: Dictionary = SalesSystem.product_value()
	var optimal: int = int(v["optimal"])
	var smax: int = maxi(optimal * 3, int(v["floor"]) + 4)   # pricing_panel ile aynı ray
	var paid_open: bool = GameState.get_flag("b2c_paid_tier_open", false)
	_draft_price = clampi(int(GameState.get_flag("b2c_price", optimal)) if paid_open else optimal,
		1, smax)

	var box: VBoxContainer = _titled_card("PROD_PUB_PRICE_TITLE", "PROD_PUB_STEP_PRICE")
	# KAREDEN SAPMA: kare 34px mono figür çiziyor; skalanın tepesi SIZE_DISPLAY 22 ve yeni
	# varyasyon THEME_STAMP artırımı ister. En büyük yasal adım TitleSerif, amber.
	var fig_row := HBoxContainer.new()
	fig_row.add_theme_constant_override("separation", UiTokens.SPACE_M)
	var figure := UiFactory.make_label("", &"TitleSerif", UiTokens.ACCENT)
	fig_row.add_child(figure)
	var per := UiFactory.make_label(tr("PROD_PER_USER_MONTH"), &"CaptionMuted")
	per.size_flags_vertical = Control.SIZE_SHRINK_END
	fig_row.add_child(per)
	box.add_child(fig_row)

	var commit: Button = _commit_button("", _on_price_commit)
	var paint := func() -> void:
		figure.text = ProductUiShared.money_tr(_draft_price)
		commit.text = tr("PROD_PRICE_COMMIT").format({"amount": ProductUiShared.money_tr(_draft_price)})
	box.add_child(_price_ruler(smax, func(value: float) -> void:
		_draft_price = int(value)
		paint.call()))

	# "Altyapı maliyeti ÷ kapasite" = birim fiyatı ÷ birim boyu; birim SAYISINDAN bağımsız.
	# Yinelenen API/lisans gideri motorda yok (katalog `cost`u build commit'inde bir kez
	# tahsil edilir), satır yalnız altyapıyı sayar.
	var per_user: float = float(InfraSystem.unit_price(_draft_provider, _market)) \
		/ float(maxi(InfraSystem.unit_size(_market), 1))
	box.add_child(UiFactory.make_label(
		tr("PROD_COST_PER_USER").format({"amount": Fmt.number(per_user, 2)}), &"MicroLabel"))

	# Yayınlanmakta olan BUILD'in eksenleri (canlı damganın değil): oyuncu birazdan
	# gönderdiği şeyi okur.
	var axes := UiFactory.make_label(tr("PROD_PUB_AXIS_SUMMARY").format({
		"inn": _axis("innovation"), "stab": _axis("stability"), "exp": _axis("experience"),
		"n": _feature_count()}), &"RowMeta")
	axes.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(axes)
	box.add_child(commit)
	paint.call()


## Ray: 1px nötr çizgi + 3px amber dolgu + PriceSlider'ın şeffaf tutamacı. İşaret yok.
func _price_ruler(smax: int, on_change: Callable) -> Control:
	var spectrum := Control.new()
	spectrum.custom_minimum_size = Vector2(0, RULER_H)
	spectrum.add_child(_rule(UiTokens.BORDER_HOVER, RULER_RAIL_H))
	var fill: ColorRect = _rule(UiTokens.ACCENT, RULER_FILL_H)
	spectrum.add_child(fill)
	var slider := HSlider.new()
	slider.theme_type_variation = &"PriceSlider"
	slider.min_value = 1
	slider.max_value = smax
	slider.step = 1
	slider.value = float(_draft_price)
	slider.anchor_right = 1.0
	slider.anchor_bottom = 1.0
	spectrum.add_child(slider)
	var paint_fill := func(value: float) -> void:
		fill.anchor_right = clampf((value - 1.0) / maxf(float(smax) - 1.0, 1.0), 0.0, 1.0)
	paint_fill.call(slider.value)
	slider.value_changed.connect(paint_fill)
	slider.value_changed.connect(on_change)
	return spectrum


## Dikey ortalı yatay çizgi; genişliğini anchor_right taşır.
func _rule(color: Color, height: float) -> ColorRect:
	var r := ColorRect.new()
	r.color = color
	r.anchor_right = 1.0
	r.anchor_top = 0.5
	r.anchor_bottom = 0.5
	r.offset_top = -height * 0.5
	r.offset_bottom = height * 0.5
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return r


func _on_price_commit() -> void:
	# Tek B2C gelir kolu; zam churn'ü seam'in içinde tetiklenir.
	SalesSystem.apply_b2c_price(_draft_price)
	_advance()


# --- 02 · ALTYAPI --------------------------------------------------------------
# İki bölüm, hiçbir zaman tek sütuna katlanmaz.

func _build_infra_step() -> void:
	var box: VBoxContainer = _titled_card("PROD_PUB_INFRA_TITLE", "PROD_PUB_STEP_INFRA")

	# Kimden alıyorsun: sağlayıcı (birim fiyat + kalite farkı).
	box.add_child(HRUiShared.section_header(tr("PROD_INFRA_PROVIDER_HEAD")))
	var rows := VBoxContainer.new()
	rows.add_theme_constant_override("separation", UiTokens.SPACE_S)
	for pid in InfraSystem.PROVIDER_IDS:
		rows.add_child(_provider_row(String(pid)))
	box.add_child(rows)

	# Ne kadar alıyorsun: kapasite, ±1 birim, her an, cezasız.
	box.add_child(HRUiShared.section_header(tr("PROD_INFRA_CAPACITY_HEAD")))
	box.add_child(_capacity_row())
	box.add_child(UiFactory.make_label(_bill_text(), &"RowMeta", UiTokens.INK))
	# §10 öneri satırı — kural değil, öneri.
	box.add_child(UiFactory.make_label(tr(InfraSystem.KEY_START_HINT).format(
		{"users": _headroom_text(InfraSystem.suggested_start_headroom())}), &"MicroLabel"))
	box.add_child(UiFactory.make_label(tr("PROD_INFRA_CAPACITY_ONLY"), &"MicroLabel"))
	box.add_child(_commit_button(tr("PROD_INFRA_COMMIT").format({"amount": _bill_text()}),
		_on_infra_commit))


func _provider_row(pid: String) -> Control:
	# Hover kenarda yaşar: dolgu kıpırdamaz, yalnız çerçeve açılır. Seçili satırın
	# AMBER_WASH + ACCENT kenarı bir DURUMDUR, hover değil.
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
	# Birim FİYATI, paket fiyatı değil: kaç birim alındığı ikinci karardır.
	var price := UiFactory.make_label(tr("PROD_INFRA_UNIT_PRICE").format({"amount":
		ProductUiShared.money_tr(InfraSystem.unit_price(pid, _market))}), &"RowMeta", UiTokens.INK)
	price.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	line.add_child(price)
	row.add_child(line)
	HRUiShared.set_mouse_ignore(line)   # tıklama kart kökünde toplanır

	row.gui_input.connect(func(event: InputEvent) -> void:
		var mb := event as InputEventMouseButton
		if mb != null and mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT:
			_draft_provider = pid
			_render())
	row.mouse_entered.connect(_paint_provider_row.bind(row, selected, true))
	row.mouse_exited.connect(_paint_provider_row.bind(row, selected, false))
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
	# ±1 BİRİM, HER AN, CEZASIZ (§10). Tavan yok; taban InfraSystem.CAPACITY_MIN. Stepper
	# giysisi onaylı 19a'nın saat kutusudur (work_hours_modal ile aynı reçete).
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
	# Bir birim ne demek: B2C'de kullanıcı, B2B'de koltuk (§10). Pazarla değişen tek şey bu.
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
	btn.pressed.connect(func() -> void:
		_draft_units = maxi(_draft_units + steps * InfraSystem.CAPACITY_STEP,
			InfraSystem.CAPACITY_MIN)
		_render())
	return btn


func _on_infra_commit() -> void:
	# İki ayrı karar, iki ayrı yazma. Göç bedeli yok; yeni fiyat ertesi günden işler.
	InfraSystem.set_provider(_draft_provider)
	InfraSystem.set_capacity(_draft_units)
	_advance()


# --- 03 · ONAY -----------------------------------------------------------------

func _build_confirm_step() -> void:
	var box: VBoxContainer = _titled_card("PROD_PUB_CONFIRM_TITLE", "PROD_PUB_STEP_CONFIRM")
	var rows := VBoxContainer.new()
	rows.add_theme_constant_override("separation", UiTokens.SPACE_M)
	rows.add_child(_summary_row("PROD_PUB_ROW_VERSION", _version_text()))
	if not _is_b2b():
		rows.add_child(_summary_row("PROD_PUB_ROW_PRICE",
			" ".join([ProductUiShared.money_tr(_draft_price), tr("PROD_PER_USER_MONTH")])))
	rows.add_child(_summary_row("PROD_PUB_ROW_INFRA", " · ".join([
		tr(InfraSystem.provider_name_key(_draft_provider)), _bill_text()])))
	rows.add_child(_summary_row("PROD_PUB_ROW_FEATURES", str(_feature_count())))
	box.add_child(rows)

	var chip: Control = UiFactory.make_state_chip(_bug_text(), UiTokens.INK_MUTED,
		UiTokens.SURFACE_FRAME, UiTokens.BORDER_HOVER)
	chip.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	box.add_child(chip)
	box.add_child(_ship_button())


func _summary_row(label_key: String, value: String) -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", UiTokens.SPACE_M)
	var l := UiFactory.make_label(tr(label_key), &"RowMeta", UiTokens.INK_DIM)
	l.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(l)
	var v := UiFactory.make_label(value, &"RowName")
	v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	v.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	v.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	row.add_child(v)
	return row


# --- v2+ · TEK ONAY ------------------------------------------------------------
# Fiyat ve altyapı sorulmaz. Aynı hata tooltip'i, küçük yüzen kartta.

func _build_quick_step() -> void:
	var box: VBoxContainer = _card(&"CardFloating", UiTokens.SPACE_M)
	box.add_child(UiFactory.make_label(
		tr("PROD_PUB_V2_TITLE").format({"name": _version_text()}), &"RowName"))
	box.add_child(UiFactory.make_label(_bug_text(), &"RowMeta"))
	var actions := HBoxContainer.new()
	actions.add_theme_constant_override("separation", UiTokens.SPACE_L)
	var dismiss := Button.new()
	dismiss.text = tr("UI_DISMISS")
	dismiss.pressed.connect(queue_free)
	actions.add_child(dismiss)
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	actions.add_child(spacer)
	actions.add_child(_ship_button())
	box.add_child(actions)


# --- ortak okumalar -------------------------------------------------------------

## CEZADAN SONRAKİ sayı: projected_launch_bugs() bunun tek evi. Ham `bug_count` riski göze
## alan oyuncuya kritik-hata cezası kadar eksik gösterirdi.
func _bug_text() -> String:
	return tr("PROD_PUB_BUGS_CARRIED").format({"n": ProductSystem.projected_launch_bugs()})


## §10 — aylık fatura = birim sayısı × birim fiyatı. InfraSystem.monthly_bill() canlı ürün
## ister ve v1 akışında ürün henüz canlı değil; aynı iki sayı taslak için burada çarpılır.
func _bill_text() -> String:
	return tr("PROD_INFRA_MONTHLY_BILL").format({"amount": ProductUiShared.money_tr(
		_draft_units * InfraSystem.unit_price(_draft_provider, _market))})


func _headroom_text(amount: int) -> String:
	return tr("PROD_INFRA_HEADROOM_SEATS" if _is_b2b() else "PROD_INFRA_HEADROOM_USERS").format(
		{"n": Fmt.group(amount)})


func _version_text() -> String:
	# "Sable v1" / "Sable v2". Ürün adı özel isimdir, çevrilmez.
	var pname: String = ProductState.product_name()
	var build: FeatureBuild = ProductSystem.active_build
	if pname == "" and build != null:
		pname = build.product_name
	var version: int = 1 if _is_first_version else maxi(ProductState.version(), 1) + 1
	var v: String = tr("PROD_VERSION_SHORT").format({"version": version})
	return v if pname == "" else " ".join([pname, v])


func _feature_count() -> int:
	# Katalog yolunda özellikler, hat modelinde kademeler — build hangisini taşıyorsa o.
	var build: FeatureBuild = ProductSystem.active_build
	if build == null:
		return (GameState.get_flag("mvp_components", []) as Array).size()
	if not build.feature_ids.is_empty():
		return build.feature_ids.size()
	return build.planned_step_ids.size()


func _axis(axis_id: String) -> int:
	var build: FeatureBuild = ProductSystem.active_build
	if build == null:
		return ProductState.axis_reading(axis_id)
	return int(round(float(build.get(axis_id))))


func _unhandled_input(event: InputEvent) -> void:
	# PanelLayer sakini Esc'in sahibidir (game_shell bizi görüp handled işaretlemeden döner).
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		queue_free()
