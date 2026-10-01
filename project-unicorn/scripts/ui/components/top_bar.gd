extends Panel

# Persistent stat strip: paints from GameState on _ready, then follows EventBus signals.
# Active/idle look comes from theme variations (PhaseDotActive/PhaseDotDim,
# SpeedButtonActive/SpeedButton).

# Canon terms, identical in both locales — keys only so no scene or script holds the words.
const PHASE_KEYS := ["FIN_PHASE_BOOTSTRAP", "FIN_PHASE_TRACTION", "FIN_PHASE_SERIES_A"]

# Yoğunluk kademesi: %150 UI ölçeği 1080p'de mantıksal viewport'u 1280×720'ye düşürür ve
# içerik ~1331px ölçülür; şirket adı soldan, 2x/3x tuşları sağdan taşardı. Şerit bu
# genişliğin altında KIRPILMAZ, SIKIŞIR. [WORKING] ölçülen taşmanın üstündeki ilk yuvarlak adım.
const COMPACT_BELOW := 1600

@onready var company_name_label: Label = $Margin/Row/IdentityGroup/CompanyNameLabel
@onready var logo_square: ColorRect = $Margin/Row/IdentityGroup/LogoSquare
@onready var finance_group: HBoxContainer = $Margin/Row/FinanceGroup
@onready var reputation_group: HBoxContainer = $Margin/Row/ReputationGroup
@onready var time_group: HBoxContainer = $Margin/Row/TimeGroup
@onready var cash_value_label: Label = $Margin/Row/FinanceGroup/StatCol_Cash/ValueLabel
@onready var mrr_value_label: Label = $Margin/Row/FinanceGroup/StatCol_MRR/ValueLabel
@onready var burn_value_label: Label = $Margin/Row/FinanceGroup/StatCol_Burn/ValueRow/ValueLabel
@onready var net_value_label: Label = $Margin/Row/FinanceGroup/StatCol_Net/ValueRow/ValueLabel
@onready var runway_value_label: Label = $Margin/Row/FinanceGroup/StatCol_Runway/ValueRow/ValueLabel
@onready var runway_unit_label: Label = $Margin/Row/FinanceGroup/StatCol_Runway/ValueRow/UnitLabel
@onready var brand_value_label: Label = $Margin/Row/ReputationGroup/StatCol_Brand/ValueLabel
@onready var rep_value_label: Label = $Margin/Row/ReputationGroup/StatCol_Rep/ValueLabel
@onready var day_label: Label = $Margin/Row/TimeGroup/DayLabel
@onready var shutter_label: Label = $Margin/Row/TimeGroup/ShutterLabel
@onready var offer_label: Label = $Margin/Row/TimeGroup/OfferLabel
@onready var phase_name_label: Label = $Margin/Row/TimeGroup/PhaseGroup/PhaseNameLabel
@onready var phase_dots: Array[Panel] = [
	$Margin/Row/TimeGroup/PhaseGroup/PhaseDots/PhaseDot1,
	$Margin/Row/TimeGroup/PhaseGroup/PhaseDots/PhaseDot2,
	$Margin/Row/TimeGroup/PhaseGroup/PhaseDots/PhaseDot3,
]
@onready var speed_btns: Array[Button] = [
	$Margin/Row/TimeGroup/SpeedControls/PauseBtn,
	$Margin/Row/TimeGroup/SpeedControls/Speed1Btn,
	$Margin/Row/TimeGroup/SpeedControls/Speed2Btn,
	$Margin/Row/TimeGroup/SpeedControls/Speed3Btn,
	$Margin/Row/TimeGroup/SpeedControls/Speed4Btn,
]

# Teklif geri sayımının sinyali yeniden atmaz; dil ya da palet değişince çipi yeniden
# boyayabilmek için son değer burada tutulur. -1 = çip gizli.
var _offer_weeks_left: int = -1
## "Sprint otomatik başladı": teklif çipinin kardeşi, ürün durumunun notunu okur.
var _auto_start_label: Label


func _ready() -> void:
	logo_square.color = UiTokens.ACCENT_CHROME
	_auto_start_label = offer_label.duplicate()
	time_group.add_child(_auto_start_label)
	time_group.move_child(_auto_start_label, offer_label.get_index() + 1)
	_refresh_all()

	EventBus.cash_changed.connect(_on_cash_changed)
	EventBus.mrr_changed.connect(_on_mrr_changed)
	EventBus.burn_changed.connect(_refresh_flow.unbind(1))
	EventBus.runway_recalculated.connect(_on_runway_changed)
	EventBus.brand_changed.connect(_on_brand_changed)
	EventBus.reputation_changed.connect(_on_reputation_changed)
	EventBus.day_advanced.connect(_update_day_label.unbind(1))
	EventBus.hour_changed.connect(_update_day_label.unbind(1))
	EventBus.phase_changed.connect(_on_phase_changed)
	EventBus.shutter_changed.connect(_on_shutter_changed)
	EventBus.offer_countdown_changed.connect(_on_offer_countdown_changed)
	EventBus.product_state_changed.connect(_refresh_auto_start)
	# Kod tarafında bestelenen metin (runway durumu, sayaçlar) ve örnek başına renk
	# override'ları kendiliğinden dönmez; ikisi de yeniden okunarak yenilenir.
	EventBus.language_changed.connect(_refresh_all.unbind(1))
	EventBus.palette_changed.connect(_refresh_all.unbind(1))
	# Ay kapanışı sessizdir; aylık rakamlar yine de kapanışta bir kez baştan okunur.
	EventBus.month_ended.connect(_refresh_all.unbind(1))
	# Hız yalnız TimeManager üzerinden gidip gelir (speed_change_requested → speed_changed);
	# gösterge buradan boyanır ki olay-duraklatma dönüşü gibi başka değiştiriciler de görünsün.
	TimeManager.speed_changed.connect(_apply_speed_visual)
	for i in speed_btns.size():
		speed_btns[i].pressed.connect(_on_speed_button.bind(i))

	get_viewport().size_changed.connect(_apply_density)
	_apply_density()


func _is_compact() -> bool:
	return get_viewport_rect().size.x < float(COMPACT_BELOW)


func _apply_density() -> void:
	var compact: bool = _is_compact()
	company_name_label.visible = not compact
	# Sütunlar hiç gitmez, hiçbir sayı gizlenmez; yalnız aralarındaki boşluk daralır.
	var gap: int = 18 if compact else 28
	finance_group.add_theme_constant_override("separation", gap)
	reputation_group.add_theme_constant_override("separation", gap)
	time_group.add_theme_constant_override("separation", 10 if compact else 16)
	day_label.custom_minimum_size.x = 0.0 if compact else 210.0
	_update_day_label()


func _refresh_all() -> void:
	company_name_label.text = GameState.company_name
	_on_cash_changed(GameState.cash)
	_on_mrr_changed(GameState.mrr)
	_on_runway_changed(GameState.get_runway_months())
	_on_brand_changed(GameState.brand)
	_on_reputation_changed(GameState.reputation)
	_update_day_label()
	_on_phase_changed(GameState.phase)
	_on_shutter_changed(GameState.shutter_weeks_left)
	_on_offer_countdown_changed(_offer_weeks_left)
	_refresh_auto_start()
	_apply_speed_visual(TimeManager.current_speed)


func _on_cash_changed(value: int) -> void:
	cash_value_label.text = UiTokens.format_money_exact(value)


func _on_mrr_changed(value: int) -> void:
	mrr_value_label.text = UiTokens.format_money_chip(value)
	_refresh_flow()


func _refresh_flow() -> void:
	# Burn ve net canlı aylık hızdır (FinanceSystem.get_monthly_flow, Finans sekmesiyle aynı
	# kaynak); net işaret renkli, "/ay" birimi sahnede sabit.
	var flow: Dictionary = FinanceSystem.get_monthly_flow()
	burn_value_label.text = UiTokens.format_money_chip(int(flow.expense))
	var net: int = int(flow.net)
	var sign_str: String = "+" if net > 0 else ("-" if net < 0 else "")
	net_value_label.text = "%s%s" % [sign_str, UiTokens.format_money_chip(absi(net))]
	net_value_label.add_theme_color_override("font_color", UiTokens.delta_color_bright(net))


func _on_runway_changed(months: float) -> void:
	var p: Dictionary = UiTokens.net_runway_parts(months)
	runway_value_label.text = String(p.value)
	runway_unit_label.text = String(p.unit)
	runway_unit_label.visible = String(p.unit) != ""
	# Kârlı: durum kelimesi yeşil, nedeni hover notunda (Label varsayılanı IGNORE, tooltip hover ister).
	var positive: bool = bool(p.get("positive", false))
	if positive:
		runway_value_label.add_theme_color_override("font_color", UiTokens.positive_bright())
	else:
		runway_value_label.remove_theme_color_override("font_color")
	runway_value_label.tooltip_text = String(p.get("note", "")) if positive else ""
	runway_value_label.mouse_filter = Control.MOUSE_FILTER_STOP if positive else Control.MOUSE_FILTER_IGNORE


func _on_brand_changed(value: int) -> void:
	brand_value_label.text = "%d" % value


func _on_reputation_changed(value: int) -> void:
	rep_value_label.text = "%d" % value


func _update_day_label() -> void:
	# Dar viewport'ta yıl düşer ve ay kısalır ("H14 · Nis · 10:00"): yıl özet başlığında zaten
	# var. Kelimeler ve sıraları Fmt'nindir.
	var d: Dictionary = GameState.get_date_dict()
	var hour: String = "%02d" % GameState.current_hour
	if _is_compact():
		day_label.text = tr("TOPBAR_CLOCK_COMPACT").format({
			"week": int(d.week), "mon": Fmt.month_abbr(int(d.month)), "hour": hour})
	else:
		day_label.text = tr("TOPBAR_CLOCK").format({"date": Fmt.date_line(d), "hour": hour})


func _on_shutter_changed(weeks_left: int) -> void:
	# Kepenk sayacı: kasa eksideyken kırmızı geri sayım; -1 = gizli.
	shutter_label.visible = weeks_left >= 0
	shutter_label.add_theme_color_override("font_color", UiTokens.negative_bright())
	if weeks_left >= 0:
		shutter_label.text = tr(Fmt.count_key("FIN_SHUTTER_COUNTDOWN", weeks_left)).format(
			{"n": weeks_left})


func _on_offer_countdown_changed(weeks_left: int) -> void:
	# Term sheet geçerlilik çipi: son haftadan önce amber, son hafta kırmızı; -1 = gizli.
	_offer_weeks_left = weeks_left
	offer_label.visible = weeks_left >= 0
	if weeks_left >= 0:
		offer_label.text = tr(Fmt.count_key("FIN_OFFER_COUNTDOWN", weeks_left)).format(
			{"n": weeks_left})
		offer_label.add_theme_color_override("font_color", UiTokens.ACCENT_CHROME if weeks_left > 1 else UiTokens.negative_bright())


## Planlamada bir gün geçince sprint liderin önerisiyle kendiliğinden başlar; not o sprint
## sürdükçe amber kalır.
func _refresh_auto_start() -> void:
	var auto_started: int = int(GameState.product.get("auto_started", -1))
	_auto_start_label.visible = SprintSystem.mode() == "active" and auto_started == SprintSystem.sprint_number()
	_auto_start_label.text = tr("PRODUCT_AUTO_STARTED")
	_auto_start_label.add_theme_color_override("font_color", UiTokens.ACCENT_CHROME)


func _on_phase_changed(new_phase: int) -> void:
	var idx: int = clampi(new_phase - 1, 0, PHASE_KEYS.size() - 1)
	# Ham to_upper bilerek: İngilizce kanon terim; Fmt.upper'ın Türkçe dalı "TRACTİON" yapardı.
	phase_name_label.text = tr(PHASE_KEYS[idx]).to_upper()
	for i in phase_dots.size():
		phase_dots[i].theme_type_variation = &"PhaseDotActive" if i <= idx else &"PhaseDotDim"


func _on_speed_button(idx: int) -> void:
	EventBus.speed_change_requested.emit(idx)


func _apply_speed_visual(active_idx: int) -> void:
	for i in speed_btns.size():
		speed_btns[i].theme_type_variation = &"SpeedButtonActive" if i == active_idx else &"SpeedButton"
