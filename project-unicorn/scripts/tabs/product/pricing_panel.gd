extends PanelContainer

# =============================================================================
# FİYATLANDIRMA paneli (B2C) — Product Tab Rev3, Step 9.
# Eski product_tab.gd `_pricing_*` kümesinin (snapshot ~1923-2265) portu, Rev3
# yerleşimine göre yeniden giydirildi: başlık+chip → büyük figür → eksen
# chip'leri → spektrum/slider → işaret satırı → stat şeridi → bölge etiketi →
# commit. Routed view DEĞİL — detail_view'ın düz bileşeni.
#
# Portlanan davranışlar: TASLAK→CANLI chip (asla kaybolmaz), Satış can_read
# gate'i, band matematiği (tek const çifti ZONE_LOW/HIGH_RATIO — bölge etiketi
# AYNI const'ları okur), _pricing_initialized grabber koruması (repaint asla
# slider.value yazmaz), floor/optimal HEP SalesSystem.product_value()'dan.
# Tek yazma seam'i: SalesSystem.apply_b2c_price (zam churn'ü seam içinde).
# =============================================================================

# Bölge sınırları — band boyama VE bölge etiketi aynı çifti okur.
const ZONE_LOW_RATIO := 0.85
const ZONE_HIGH_RATIO := 1.15

var _header_row: HBoxContainer = null
var _status_chip: Control = null
var _figure_label: Label = null
var _chips_row: HFlowContainer = null
var _spectrum: Control = null
var _band: HBoxContainer = null
var _slider: HSlider = null
var _mark_floor: Label = null
var _mark_optimal: Label = null
var _mark_top: Label = null
var _stat_row: HBoxContainer = null
var _zone_slot: HBoxContainer = null
var _apply: Button = null
var _pricing_initialized := false


func _ready() -> void:
	theme_type_variation = &"CardPanel"
	_build()
	_paint()


## Router repaint zinciri (detail_view.repaint → buraya): stat/chip/figür
## tazelenir; slider.value'ya ASLA yazılmaz (grabber zıplama bug'ı).
func repaint() -> void:
	if _slider == null:
		return
	_paint()


# --- kurulum -----------------------------------------------------------------

func _build() -> void:
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 10)
	add_child(vb)

	# 1. Başlık: "FİYATLANDIRMA" + durum chip'i (TASLAK → CANLI · $N).
	_header_row = HBoxContainer.new()
	var hdr := UiFactory.make_label("FİYATLANDIRMA", &"SectionLabel")
	hdr.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hdr.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_header_row.add_child(hdr)
	vb.add_child(_header_row)

	# 2. Büyük figür: "~$18 / kullanıcı".
	var fig_row := HBoxContainer.new()
	fig_row.add_theme_constant_override("separation", 6)
	_figure_label = UiFactory.make_label("", &"TitleSerif")
	_figure_label.add_theme_font_size_override("font_size", 24)
	fig_row.add_child(_figure_label)
	var per := UiFactory.make_label("/ kullanıcı", &"CaptionMuted")
	per.size_flags_vertical = Control.SIZE_SHRINK_END
	fig_row.add_child(per)
	vb.add_child(fig_row)

	# 3. Eksen chip'leri (önceden BÜYÜK verilir; factory artık UiTokens.tr_upper ile TR-güvenli).
	_chips_row = HFlowContainer.new()
	_chips_row.add_theme_constant_override("h_separation", 5)
	_chips_row.add_theme_constant_override("v_separation", 4)
	vb.add_child(_chips_row)

	# 4. Spektrum: renkli band + çentikler, üstünde PriceSlider (şeffaf ray).
	_spectrum = Control.new()
	_spectrum.custom_minimum_size = Vector2(0, 30)
	_spectrum.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vb.add_child(_spectrum)
	_band = HBoxContainer.new()
	_band.add_theme_constant_override("separation", 0)
	_band.anchor_right = 1.0
	_band.anchor_top = 0.5
	_band.anchor_bottom = 0.5
	_band.offset_top = -4.0
	_band.offset_bottom = 4.0
	_band.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_spectrum.add_child(_band)
	_slider = HSlider.new()
	_slider.theme_type_variation = &"PriceSlider"
	_slider.min_value = 1
	_slider.max_value = 100
	_slider.step = 1
	_slider.anchor_right = 1.0
	_slider.anchor_bottom = 1.0
	_slider.value_changed.connect(_on_slider_changed)
	_spectrum.add_child(_slider)

	# 5. İşaret satırı: alt sınır | optimal | üst açık.
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

	# 6. Stat şeridi: SEÇİLEN / ÖDEYEN / MRR / DÖNÜŞÜM.
	var proj_card := PanelContainer.new()
	proj_card.theme_type_variation = &"CardPanelTight"
	_stat_row = HBoxContainer.new()
	_stat_row.add_theme_constant_override("separation", 18)
	proj_card.add_child(_stat_row)
	vb.add_child(proj_card)

	# Bölge etiketi (+ zam chip'i) — stat şeridinin altında.
	_zone_slot = HBoxContainer.new()
	_zone_slot.add_theme_constant_override("separation", 5)
	vb.add_child(_zone_slot)

	# 7. Commit (amber birincil).
	_apply = Button.new()
	_apply.theme_type_variation = &"CommitButton"
	_apply.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_apply.pressed.connect(_on_apply_pressed)
	vb.add_child(_apply)


# --- boyama --------------------------------------------------------------------

func _paint() -> void:
	# floor/optimal HEP product_value()'dan — asla yerelde yeniden hesaplanmaz.
	var v: Dictionary = SalesSystem.product_value()
	var optimal: int = int(v["optimal"])
	var floor_p: int = int(v["floor"])
	var can_read: bool = GameState.get_founder_skill("sales") >= SkillCheck.SALES_READ_THRESHOLD
	var is_open: bool = GameState.get_flag("b2c_paid_tier_open", false)

	# Ray aralığı: alt 1, üst açık (optimal × 3) — snapshot değerleri.
	var smax: int = maxi(optimal * 3, floor_p + 4)
	_slider.min_value = 1
	_slider.max_value = smax
	if not _pricing_initialized:
		_slider.value = float(int(GameState.get_flag("b2c_price", optimal))) if is_open else float(optimal)
		_pricing_initialized = true

	_rebuild_header_chip(is_open)
	_figure_label.text = ("~%s" % ProductUiShared.money_tr(optimal)) if can_read else "belirsiz"
	_rebuild_axis_chips()
	_rebuild_bands(optimal, floor_p, smax, can_read)
	_mark_floor.text = "Alt sınır %s" % ProductUiShared.money_tr(floor_p)
	if can_read:
		_mark_optimal.text = "Optimal %s" % ProductUiShared.money_tr(optimal)
		_mark_top.text = "üst açık"
	else:
		# Satış gate'i (port): optimal düşük Satış becerisine gizli kalır.
		_mark_optimal.text = "Optimal belirsiz (Markets düşük)"
		_mark_top.text = ""
	_update_projection(int(_slider.value))


func _rebuild_header_chip(is_open: bool) -> void:
	# TASLAK → CANLI · $N (kilitli karar: chip asla kaybolmaz).
	if _status_chip != null and is_instance_valid(_status_chip):
		_header_row.remove_child(_status_chip)
		_status_chip.queue_free()
	if is_open:
		_status_chip = UiFactory.make_badge(
			"CANLI · %s" % ProductUiShared.money_tr(int(GameState.get_flag("b2c_price", 0))), &"positive")
	else:
		_status_chip = UiFactory.make_badge("TASLAK", &"neutral")
	_status_chip.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_header_row.add_child(_status_chip)


func _rebuild_axis_chips() -> void:
	_clear(_chips_row)
	var inn: int = int(round(float(GameState.get_flag("mvp_innovation", 0.0))))
	var stab: int = int(round(float(GameState.get_flag("mvp_stability", 0.0))))
	var exp: int = int(round(float(GameState.get_flag("mvp_experience", 0.0))))
	var comp_count: int = (GameState.get_flag("mvp_components", []) as Array).size()
	_chips_row.add_child(UiFactory.make_badge("İNOVASYON %d" % inn, &"neutral"))
	_chips_row.add_child(UiFactory.make_badge("KARARLILIK %d" % stab, &"neutral"))
	_chips_row.add_child(UiFactory.make_badge("DENEYİM %d" % exp, &"neutral"))
	_chips_row.add_child(UiFactory.make_badge("%d ÖZELLİK" % comp_count, &"neutral"))


func _rebuild_bands(optimal: int, floor_p: int, smax: int, can_read: bool) -> void:
	# Port: yeşil (hacim) → amber (optimal bölgesi) → kırmızı (premium);
	# sınırlar tek const çiftinden (bölge etiketiyle bire bir aynı).
	_clear(_band)
	for ch in _spectrum.get_children():
		if String(ch.name).begins_with("Notch"):
			_spectrum.remove_child(ch)
			ch.queue_free()
	var a: float = maxf(1.0, optimal * ZONE_LOW_RATIO)
	var b: float = maxf(a + 1.0, optimal * ZONE_HIGH_RATIO)
	_add_band(UiTokens.POSITIVE, a - 1.0)
	_add_band(UiTokens.HEALTH_AMBER, b - a)
	_add_band(UiTokens.NEGATIVE, maxf(1.0, float(smax) - b))
	if can_read:
		var span: float = maxf(1.0, float(smax - 1))
		_add_notch(clampf(float(floor_p - 1) / span, 0.0, 1.0))
		_add_notch(clampf(float(optimal - 1) / span, 0.0, 1.0))


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
	n.name = "Notch"
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
	_spectrum.add_child(n)
	_spectrum.move_child(n, 1)   # bandın üstünde, slider grabber'ın altında


func _on_slider_changed(value: float) -> void:
	_update_projection(int(value))


func _update_projection(price: int) -> void:
	# Canlı, commit-öncesi tahmin (mutasyon yok) — alan adları porttan:
	# new_paying / new_mrr / old_mrr / is_raise / audience_drop_pct.
	var v: Dictionary = SalesSystem.product_value()
	var optimal: int = int(v["optimal"])
	var can_read: bool = GameState.get_founder_skill("sales") >= SkillCheck.SALES_READ_THRESHOLD
	var est: Dictionary = SalesSystem.estimate_price_change(price)
	var cur_paying: int = CustomerRegistry.get_total_users()
	var new_paying: int = int(est["new_paying"])
	var new_mrr: int = int(est["new_mrr"])
	var old_mrr: int = int(est["old_mrr"])
	var conv: int = int(round(SalesSystem.conversion_rate(price) * 100.0))
	var is_open: bool = GameState.get_flag("b2c_paid_tier_open", false)

	_clear(_stat_row)
	_stat_row.add_child(UiFactory.make_stat("SEÇİLEN", ProductUiShared.money_tr(price), 0, "", UiTokens.ACCENT_DEEP))
	var dpay: int = new_paying - cur_paying
	_stat_row.add_child(UiFactory.make_stat("ÖDEYEN", str(new_paying), dpay,
		_signed(dpay) if (is_open and dpay != 0) else ""))
	var dmrr: int = new_mrr - old_mrr
	_stat_row.add_child(UiFactory.make_stat("MRR", ProductUiShared.money_tr(new_mrr), dmrr,
		_signed_money(dmrr) if (is_open and dmrr != 0) else ""))
	_stat_row.add_child(UiFactory.make_stat("DÖNÜŞÜM", "%%%d" % conv))

	# Bölge etiketi — band'la AYNI const çifti; can_read gate'i porttan.
	_clear(_zone_slot)
	if not can_read:
		_zone_slot.add_child(UiFactory.make_badge("İÇGÜDÜSEL FİYAT", &"neutral"))
	elif float(price) < float(optimal) * ZONE_LOW_RATIO:
		_zone_slot.add_child(UiFactory.make_badge("UCUZ · HIZLI BÜYÜME", &"positive"))
	elif float(price) > float(optimal) * ZONE_HIGH_RATIO:
		_zone_slot.add_child(UiFactory.make_badge("PAHALI · YAVAŞ BÜYÜME", &"negative"))
	else:
		_zone_slot.add_child(UiFactory.make_badge("OPTIMAL · DENGELİ", &"accent"))
	if bool(est["is_raise"]):
		_zone_slot.add_child(UiFactory.make_badge(
			"ZAM · KİTLE −%%%d" % int(round(float(est["audience_drop_pct"]) * 100.0)), &"negative"))

	_apply.text = "Fiyatı koy · %s" % ProductUiShared.money_tr(price)


func _on_apply_pressed() -> void:
	# Tek B2C gelir kolu — oynanmış karar. Zam churn'ü seam İÇİNDE tetiklenir;
	# burada churn kodu yok. apply mrr_changed emit eder (router repaint'i),
	# ama chip/stat'lar eşit-MRR durumunda da tazelensin diye direkt boyanır.
	SalesSystem.apply_b2c_price(int(_slider.value))
	_paint()


# --- yardımcılar ----------------------------------------------------------------

func _signed(v: int) -> String:
	if v > 0:
		return "+%d" % v
	if v < 0:
		return "−%d" % absi(v)
	return "±0"


func _signed_money(v: int) -> String:
	if v == 0:
		return ""
	return ("+%s" % ProductUiShared.money_tr(v)) if v > 0 else ("−%s" % ProductUiShared.money_tr(absi(v)))


func _clear(node: Node) -> void:
	for ch in node.get_children():
		node.remove_child(ch)
		ch.queue_free()
