extends PanelContainer

# =============================================================================
# FİYATLANDIRMA paneli (B2C): Ürün Detayı'nın düz bileşeni, routed view değil.
# Başlık + durum chip'i → büyük figür → eksen chip'leri → spektrum/slider → işaret
# satırı → stat şeridi → bölge etiketi → commit.
# floor/optimal HEP SalesSystem.product_value()'dan; tek yazma seam'i
# SalesSystem.apply_b2c_price (zam churn'ü seam içinde).
# =============================================================================

## Bölge sınırları: band boyama VE bölge etiketi aynı çifti okur.
const ZONE_LOW_RATIO := 0.85
const ZONE_HIGH_RATIO := 1.15

var _header_row: HBoxContainer = null
var _status_chip: Control = null
var _figure_label: Label = null
var _chips_row: HFlowContainer = null
var _band: HBoxContainer = null
var _notches: Control = null
var _slider: HSlider = null
var _mark_floor: Label = null
var _mark_optimal: Label = null
var _mark_top: Label = null
var _stat_row: HBoxContainer = null
var _zone_slot: HBoxContainer = null
var _apply: Button = null
# repaint'te okunur; slider sürüklenirken projeksiyon bunları yeniden sormaz.
var _optimal := 0
var _can_read := false
var _is_open := false
## Slider değeri yalnız ilk boyamada yazılır: repaint'in yazması grabber'ı oyuncunun
## elinden zıplatırdı.
var _pricing_initialized := false


func _ready() -> void:
	theme_type_variation = &"CardPanel"
	_build()
	repaint()


# --- kurulum -----------------------------------------------------------------

func _build() -> void:
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 10)
	add_child(vb)

	_header_row = HBoxContainer.new()
	var hdr := UiFactory.make_label(tr("PROD_PRICING"), &"SectionLabel")
	hdr.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hdr.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_header_row.add_child(hdr)
	vb.add_child(_header_row)

	# Büyük figür: "~$18 / kullanıcı".
	var fig_row := HBoxContainer.new()
	fig_row.add_theme_constant_override("separation", 6)
	_figure_label = UiFactory.make_label("", &"TitleSerif")
	_figure_label.add_theme_font_size_override("font_size", 24)
	fig_row.add_child(_figure_label)
	var per := UiFactory.make_label(tr("PROD_PER_USER"), &"CaptionMuted")
	per.size_flags_vertical = Control.SIZE_SHRINK_END
	fig_row.add_child(per)
	vb.add_child(fig_row)

	_chips_row = HFlowContainer.new()
	_chips_row.add_theme_constant_override("h_separation", 5)
	_chips_row.add_theme_constant_override("v_separation", 4)
	vb.add_child(_chips_row)

	# Spektrum: renkli band, üstünde çentikler, en üstte PriceSlider (şeffaf ray).
	var spectrum := Control.new()
	spectrum.custom_minimum_size = Vector2(0, 30)
	spectrum.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vb.add_child(spectrum)
	_band = HBoxContainer.new()
	_band.add_theme_constant_override("separation", 0)
	_band.anchor_right = 1.0
	_band.anchor_top = 0.5
	_band.anchor_bottom = 0.5
	_band.offset_top = -4.0
	_band.offset_bottom = 4.0
	_band.mouse_filter = Control.MOUSE_FILTER_IGNORE
	spectrum.add_child(_band)
	_notches = Control.new()
	_notches.set_anchors_preset(Control.PRESET_FULL_RECT)
	_notches.mouse_filter = Control.MOUSE_FILTER_IGNORE
	spectrum.add_child(_notches)
	_slider = HSlider.new()
	_slider.theme_type_variation = &"PriceSlider"
	_slider.min_value = 1
	_slider.max_value = 100
	_slider.step = 1
	_slider.anchor_right = 1.0
	_slider.anchor_bottom = 1.0
	_slider.value_changed.connect(func(v: float) -> void: _update_projection(int(v)))
	spectrum.add_child(_slider)

	# İşaret satırı: alt sınır | optimal | üst açık.
	var marks := HBoxContainer.new()
	_mark_floor = UiFactory.make_label("", &"MetricCaptionInk")
	_mark_floor.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	marks.add_child(_mark_floor)
	_mark_optimal = UiFactory.make_label("", &"MetricCaptionInk")
	_mark_optimal.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_mark_optimal.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	marks.add_child(_mark_optimal)
	_mark_top = UiFactory.make_label("", &"MetricCaptionInk")
	_mark_top.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_mark_top.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	marks.add_child(_mark_top)
	vb.add_child(marks)

	# Stat şeridi: SEÇİLEN / ÖDEYEN / MRR / DÖNÜŞÜM.
	var proj_card := PanelContainer.new()
	proj_card.theme_type_variation = &"CardPanelTight"
	_stat_row = HBoxContainer.new()
	_stat_row.add_theme_constant_override("separation", 18)
	proj_card.add_child(_stat_row)
	vb.add_child(proj_card)

	# Bölge etiketi (+ zam chip'i).
	_zone_slot = HBoxContainer.new()
	_zone_slot.add_theme_constant_override("separation", 5)
	vb.add_child(_zone_slot)

	_apply = Button.new()
	_apply.theme_type_variation = &"CommitButton"
	_apply.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_apply.pressed.connect(_on_apply_pressed)
	vb.add_child(_apply)


# --- boyama --------------------------------------------------------------------

## Router zinciri (detail_view.repaint → buraya) ve commit sonrası.
func repaint() -> void:
	var v: Dictionary = SalesSystem.product_value()
	_optimal = int(v["optimal"])
	var floor_p: int = int(v["floor"])
	_can_read = GameState.get_founder_skill("sales") >= SkillCheck.SALES_READ_THRESHOLD
	_is_open = GameState.get_flag("b2c_paid_tier_open", false)

	# Ray: alt 1, üst açık (optimal × 3).
	var smax: int = maxi(_optimal * 3, floor_p + 4)
	_slider.max_value = smax
	if not _pricing_initialized:
		_pricing_initialized = true
		_slider.value = float(GameState.get_flag("b2c_price", _optimal)) if _is_open else float(_optimal)

	# Durum chip'i TASLAK → CANLI · $N; hiç kaybolmaz.
	if _status_chip != null:
		_header_row.remove_child(_status_chip)
		_status_chip.queue_free()
	if _is_open:
		_status_chip = UiFactory.make_badge(tr("PROD_LIVE_PRICE").format(
			{"amount": Fmt.money_exact(int(GameState.get_flag("b2c_price", 0)))}), &"positive")
	else:
		_status_chip = UiFactory.make_badge(tr("PROD_DRAFT_CHIP"), &"neutral")
	_status_chip.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_header_row.add_child(_status_chip)

	_figure_label.text = ("~" + Fmt.money_exact(_optimal)) if _can_read else tr("PROD_UNKNOWN")

	ProductUiShared.clear(_chips_row)
	for chip_text in [
		tr("PROD_AXIS_INNOVATION_N").format({"n": roundi(float(GameState.get_flag("mvp_innovation", 0.0)))}),
		tr("PROD_AXIS_STABILITY_N").format({"n": roundi(float(GameState.get_flag("mvp_stability", 0.0)))}),
		tr("PROD_AXIS_EXPERIENCE_N").format({"n": roundi(float(GameState.get_flag("mvp_experience", 0.0)))}),
		tr("PROD_FEATURE_COUNT").format({"n": (GameState.get_flag("mvp_components", []) as Array).size()}),
	]:
		_chips_row.add_child(UiFactory.make_badge(chip_text, &"neutral"))

	_rebuild_bands(floor_p, smax)
	_mark_floor.text = tr("PROD_FLOOR").format({"amount": Fmt.money_exact(floor_p)})
	# Satış kapısı: optimal, düşük Satış becerisine gizli kalır.
	_mark_optimal.text = tr("PROD_OPTIMAL").format({"amount": Fmt.money_exact(_optimal)}) \
		if _can_read else tr("PROD_OPTIMAL_UNKNOWN")
	_mark_top.text = tr("PROD_UPPER_OPEN") if _can_read else ""
	_update_projection(int(_slider.value))


func _rebuild_bands(floor_p: int, smax: int) -> void:
	# Yeşil (hacim) → amber (optimal bölgesi) → kırmızı (premium).
	ProductUiShared.clear(_band)
	ProductUiShared.clear(_notches)
	var a: float = maxf(1.0, _optimal * ZONE_LOW_RATIO)
	var b: float = maxf(a + 1.0, _optimal * ZONE_HIGH_RATIO)
	_add_band(UiTokens.positive(), a - 1.0)
	_add_band(UiTokens.HEALTH_AMBER, b - a)
	_add_band(UiTokens.negative(), maxf(1.0, float(smax) - b))
	if _can_read:
		var span: float = maxf(1.0, float(smax - 1))
		for price in [floor_p, _optimal]:
			_add_notch(clampf(float(price - 1) / span, 0.0, 1.0))


func _add_band(color: Color, ratio: float) -> void:
	var r := ColorRect.new()
	r.color = color
	r.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	r.size_flags_vertical = Control.SIZE_EXPAND_FILL
	r.size_flags_stretch_ratio = maxf(0.01, ratio)
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_band.add_child(r)


func _add_notch(ratio: float) -> void:
	var n := ColorRect.new()
	n.color = UiTokens.INK
	n.anchor_left = ratio
	n.anchor_right = ratio
	n.offset_left = -1.0
	n.offset_right = 1.0
	n.anchor_top = 0.5
	n.anchor_bottom = 0.5
	n.offset_top = -8.0
	n.offset_bottom = 8.0
	n.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_notches.add_child(n)


## Commit-öncesi canlı tahmin; mutasyon yok.
func _update_projection(price: int) -> void:
	var est: Dictionary = SalesSystem.estimate_price_change(price)
	var new_paying: int = int(est["new_paying"])
	var new_mrr: int = int(est["new_mrr"])
	var dpay: int = new_paying - CustomerRegistry.get_total_users()
	var dmrr: int = new_mrr - int(est["old_mrr"])
	ProductUiShared.clear(_stat_row)
	_stat_row.add_child(UiFactory.make_stat(tr("PROD_SELECTED"), Fmt.money_exact(price), 0, "", UiTokens.ACCENT_DEEP))
	_stat_row.add_child(UiFactory.make_stat(tr("PROD_PAYING"), str(new_paying), dpay,
		_delta_text(dpay, str(absi(dpay)))))
	_stat_row.add_child(UiFactory.make_stat(tr("FIN_CAP_MRR"), Fmt.money_exact(new_mrr), dmrr,
		_delta_text(dmrr, Fmt.money_exact(absi(dmrr)))))
	_stat_row.add_child(UiFactory.make_stat(tr("PROD_CONVERSION"),
		Fmt.percent(roundi(SalesSystem.conversion_rate(price) * 100.0), 0)))

	# Bölge etiketi: band'la AYNI const çifti.
	ProductUiShared.clear(_zone_slot)
	if not _can_read:
		_zone_slot.add_child(UiFactory.make_badge(tr("PROD_GUT_PRICE"), &"neutral"))
	elif price < _optimal * ZONE_LOW_RATIO:
		_zone_slot.add_child(UiFactory.make_badge(tr("PROD_PRICE_CHEAP"), &"positive"))
	elif price > _optimal * ZONE_HIGH_RATIO:
		_zone_slot.add_child(UiFactory.make_badge(tr("PROD_PRICE_EXPENSIVE"), &"negative"))
	else:
		_zone_slot.add_child(UiFactory.make_badge(tr("PROD_PRICE_OPTIMAL"), &"accent"))
	if bool(est["is_raise"]):
		_zone_slot.add_child(UiFactory.make_badge(tr("PROD_PRICE_RAISE").format(
			{"pct": Fmt.percent(roundi(float(est["audience_drop_pct"]) * 100.0), 0)}), &"negative"))

	_apply.text = tr("PROD_PRICE_COMMIT").format({"amount": Fmt.money_exact(price)})


## Stat çipinin işaretli farkı. Fiyat henüz açılmadıysa karşılaştırılacak canlı değer yok.
func _delta_text(v: int, magnitude: String) -> String:
	if not _is_open or v == 0:
		return ""
	return ("+" if v > 0 else "−") + magnitude


func _on_apply_pressed() -> void:
	# apply mrr_changed yayar (router repaint'i), ama MRR eşit kaldığında da chip/stat
	# tazelensin diye doğrudan boyanır.
	SalesSystem.apply_b2c_price(int(_slider.value))
	repaint()
