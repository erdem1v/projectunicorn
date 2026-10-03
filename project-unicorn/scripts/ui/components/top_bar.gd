extends Panel

# Üst bar: iki satırlık metrik ızgarası, koyu temada. Her yazı taban çizgisine göre yerleşir
# (y = taban - ascent); sütunlar sabittir ve TR ile EN'in en geniş değerinden ölçülüdür, böylece gün
# bloğu ve hafta çubuğu her durumda ve dilde aynı boydadır. Mantıksal genişlik
# DisplaySettings.COMPACT_SHELL_BELOW altındayken sıkışık kip: marka yalnız kare, kısa tarih, dar hız
# tuşları (rayın simge kipiyle aynı eşik). Hafta çubuğu en çok MAX_WEEK_BAR uzar; daha geniş barda
# Sıradaki yuvası ve saat bloğu gün bloğunun hemen ardından gelir, artan genişlik sağda boş kalır.
# Sıradaki yuvası hep ayrılmıştır: teklif süresi, yoksa mesai bitimi. Bir karar beklerken yuva kapıdır:
# amber nokta ve "Cevap bekliyor", altında göndericisi ya da bekleyen kararların sayısı; yuva ve saat
# bloğu amber çerçevede, hız tuşları kapalı, tıklanınca karara dönülür. Ayırıcılar ve hafta çubuğu
# _draw'da.

const INBOX := preload("res://scripts/ui/components/inbox.gd")

const PHASE_KEYS := ["FIN_PHASE_BOOTSTRAP", "FIN_PHASE_TRACTION", "FIN_PHASE_SERIES_A"]
## [tam, sıkışık]: marka bloğunun genişliği; anahtar (A, C, E, G) ve değer (B, D, F, H) sütunlarının
## sol kenarı; iki metrik grubunu ayıran kısa çizgi; gün bloğunun başı ve iç payı; yuva ve saat
## bloğunun genişliği, saatin sol payı, hız tuşunun genişliği ve saatle tuşlar arası.
const GRID := [
	{"brand": 184, "A": 204, "B": 246, "C": 414, "D": 480, "rule": 616, "E": 637, "F": 684, "G": 766,
		"H": 843, "day": 943, "pad": 20, "slot": 248, "time": 335, "time_pad": 20, "key": 40, "gap": 16},
	{"brand": 64, "A": 76, "B": 116, "C": 276, "D": 340, "rule": 468, "E": 481, "F": 526, "G": 600,
		"H": 675, "day": 767, "pad": 16, "slot": 216, "time": 269, "time_pad": 12, "key": 30, "gap": 12},
]
## Taban çizgileri: iki metrik satırı, marka adı ve evre, tarih ve saat etiketleri, yuvanın iki
## satırı, saat.
const ROW_1 := 33.0
const ROW_2 := 54.0
const NAME_LINE := 31.0
const PHASE_LINE := 50.0
const DATE_LINE := 28.0
const HOUR_LINE := 58.0
const NEXT_KEY_LINE := 29.0
const NEXT_LINE := 50.0
const GATE_LINE := 30.0
const GATE_SUB_LINE := 51.0
## The gate dot's ring: one pulse, how far it grows and how bright it starts (SPEC §7).
const PULSE_S := 1.6
const PULSE_SCALE := 4.0
const PULSE_ALPHA := 0.55
## A refused speed key blinks the frame: twice, each way this long.
const BLINK_S := 0.09
const CLOCK_LINE := 41.0
const LOGO := Vector2(20, 14)
const LOGO_COMPACT := Vector2(22, 22)
const NAME_X := 48.0
const NAME_RIGHT := 12.0
## Evre adının en geniş hâli; noktalar ondan PHASE_DOT_GAP sonra, aralarında PHASE_DOT_STEP.
const PHASE_W := 65.0
const PHASE_DOT_GAP := 8.0
const PHASE_DOT_STEP := 12.0
const PHASE_DOT_Y := 44.0
const CLOCK_W := 67.0
const KEYS_Y := 16.0
const KEY_GAP := 4.0
const UNIT_GAP := 2.0
const RULE_INSET := 12.0
## Hafta çubuğu: üst kenarı, uzunluk tavanı.
const WEEK_Y := 38.0
const MAX_WEEK_BAR := 720.0

@onready var speed_btns: Array[Button] = [
	$TimeBlock/PauseBtn,
	$TimeBlock/Speed1Btn,
	$TimeBlock/Speed2Btn,
	$TimeBlock/Speed3Btn,
	$TimeBlock/Speed4Btn,
]

## Teklif geri sayımı yalnız tikte yayılır; dil ya da palet değişince yeniden boyamak için tutulur.
## -1 = teklif yok.
var _offer_weeks_left: int = -1
var _compact := false
var _slot_x := 0.0
var _pulse: Tween


func _ready() -> void:
	# Bağlantılar tek tek yazılır: sinyal manifestinin üreticisi `EventBus.<ad>.connect` biçimini okur.
	var refresh := _refresh.unbind(1)
	EventBus.cash_changed.connect(refresh)
	EventBus.mrr_changed.connect(refresh)
	EventBus.burn_changed.connect(refresh)
	EventBus.runway_recalculated.connect(refresh)
	EventBus.brand_changed.connect(refresh)
	EventBus.reputation_changed.connect(refresh)
	EventBus.day_advanced.connect(refresh)
	EventBus.hour_changed.connect(refresh)
	EventBus.phase_changed.connect(refresh)
	EventBus.shutter_changed.connect(refresh)
	EventBus.language_changed.connect(refresh)
	EventBus.palette_changed.connect(refresh)
	EventBus.month_ended.connect(refresh)
	EventBus.event_triggered.connect(refresh)
	EventBus.event_set_aside.connect(refresh)
	EventBus.event_resolved.connect(_refresh.unbind(2))
	EventBus.offer_countdown_changed.connect(_on_offer_countdown_changed)
	# Hız yalnız TimeManager üzerinden gidip gelir (speed_change_requested → speed_changed); gösterge
	# buradan boyanır ki olay duraklatmasının dönüşü gibi başka değiştiriciler de görünsün.
	TimeManager.speed_changed.connect(_apply_speed_visual)
	for i in speed_btns.size():
		speed_btns[i].pressed.connect(EventBus.speed_change_requested.emit.bind(i))
	resized.connect(_refresh)
	$GateHit.gui_input.connect(func(e: InputEvent) -> void:
		if UiFactory.is_left_click(e):
			INBOX.show("active"))
	add_to_group(&"top_bar")
	_refresh()
	_apply_speed_visual(TimeManager.current_speed)


func _on_offer_countdown_changed(weeks_left: int) -> void:
	_offer_weeks_left = weeks_left
	_refresh()


func _refresh() -> void:
	_compact = get_viewport_rect().size.x < DisplaySettings.COMPACT_SHELL_BELOW
	var g: Dictionary = GRID[int(_compact)]
	_refresh_brand(g)
	_refresh_metrics(g)
	_slot_x = minf(size.x - g.time - g.slot, g.day + g.pad + MAX_WEEK_BAR + g.pad)
	_refresh_day(g)
	_refresh_time(g)
	queue_redraw()


## Marka bloğu: turuncu kare + "Project Unicorn" ve evre; sıkışık kipte yalnız kare.
func _refresh_brand(g: Dictionary) -> void:
	$Logo.position = LOGO_COMPACT if _compact else LOGO
	var phase: int = clampi(GameState.phase, 1, PHASE_KEYS.size())
	# Ham to_upper bilerek: İngilizce kanon terim; Fmt.upper'ın Türkçe dalı "TRACTİON" yapardı.
	$Phase.text = tr(PHASE_KEYS[phase - 1]).to_upper()
	_put($LogoName, NAME_X, NAME_LINE, g.brand - NAME_X - NAME_RIGHT)
	_put($Phase, NAME_X, PHASE_LINE)
	for i in 3:
		var dot: Panel = get_node("PhaseDot%d" % (i + 1))
		dot.position = Vector2(NAME_X + PHASE_W + PHASE_DOT_GAP + i * PHASE_DOT_STEP, PHASE_DOT_Y)
		dot.theme_type_variation = &"PhaseDotActive" if i < phase else &"PhaseDotDim"
	for part: Control in [$LogoName, $Phase, $PhaseDot1, $PhaseDot2, $PhaseDot3]:
		part.visible = not _compact


## KASA tek kahraman, NET altında. Kepenk sayacı koşarken RUNWAY hücresi o sayaçtır. Kırmızı yalnız
## tehlikede: eksi kasa, kepenk, ilk runway eşiğinin altı; kasa artıdayken eksi NET mürekkeptir.
func _refresh_metrics(g: Dictionary) -> void:
	var flow: Dictionary = FinanceSystem.get_monthly_flow()
	var shut: bool = GameState.cash < 0
	var net: int = int(flow.net)
	var months: float = GameState.get_runway_months()
	_paint($CashValue, Fmt.money_exact(GameState.cash), UiTokens.D_neg() if shut else null)
	var net_ink = UiTokens.D_pos() if net > 0 else (UiTokens.D_neg() if shut and net < 0 else null)
	_paint($NetValue, ("+" if net > 0 else ("-" if net < 0 else "")) + Fmt.money_chip(absi(net)), net_ink)
	var weeks: int = GameState.shutter_weeks_left
	# Kasa iki tik arasında eksiye düşebilir (olay, tek seferlik gider); kepenk sayacı sonraki tikte
	# kurulur, o arada hücre RUNWAY kalır.
	var shutter: bool = shut and weeks >= 0
	var p: Dictionary = UiTokens.net_runway_parts(months)
	var alarm: bool = shut or months < FinanceSystem.RUNWAY_ALERT_MONTHS[0]
	var runway_ink = UiTokens.D_pos() if p.positive else (UiTokens.D_neg() if alarm else null)
	$RunwayKey.text = Fmt.upper(tr("TOPBAR_SHUTTER" if shutter else "FIN_CAP_RUNWAY"))
	var runway: Label = $RunwayValue
	runway.theme_type_variation = &"ValueText" if runway_ink == null else &"ValueTextStrong"
	_paint(runway, tr(Fmt.count_key("TOPBAR_SHUTTER_WEEKS", weeks)).format({"n": weeks})
		if shutter else UiTokens.net_runway_text(months), runway_ink)
	# Artıda olmanın nedeni ipucunda (Label varsayılanı IGNORE, ipucu üzerine gelmeyi ister).
	runway.tooltip_text = p.note
	runway.mouse_filter = Control.MOUSE_FILTER_STOP if p.positive else Control.MOUSE_FILTER_IGNORE
	$MrrValue.text = Fmt.money_chip(GameState.mrr)
	$BrandValue.text = str(GameState.brand)
	$BurnValue.text = Fmt.money_chip(int(flow.expense))
	$RepValue.text = str(GameState.reputation)
	for row in [[$CashKey, $CashValue, "A", "B", ROW_1], [$NetKey, $NetValue, "A", "B", ROW_2],
			[$RunwayKey, runway, "C", "D", ROW_1], [$MrrKey, $MrrValue, "E", "F", ROW_1],
			[$BrandKey, $BrandValue, "E", "F", ROW_2], [$BurnKey, $BurnValue, "G", "H", ROW_1],
			[$RepKey, $RepValue, "G", "H", ROW_2]]:
		_put(row[0], g[row[2]], row[4])
		_put(row[1], g[row[3]], row[4])
	for row in [[$NetUnit, $NetValue, ROW_2], [$BurnUnit, $BurnValue, ROW_1]]:
		_put(row[0], row[1].position.x + row[1].get_minimum_size().x + UNIT_GAP, row[2])


## Gün bloğu (tarih + hafta çubuğu ve uç saatleri) ve Sıradaki yuvası: teklif süresi uyarı rengindedir,
## son haftasında kırmızı; teklif yoksa mesainin bitimine kalan saat.
func _refresh_day(g: Dictionary) -> void:
	var d: Dictionary = GameState.get_date_dict()
	$Date.text = tr("TOPBAR_DATE_COMPACT").format({"week": int(d.week), "mon": Fmt.month_abbr(int(d.month))}) \
		if _compact else Fmt.date_line(d)
	var x0: float = g.day + g.pad
	_put($Date, x0, DATE_LINE)
	var end: int = WorkHoursSystem.workday_end()
	$WeekStart.text = "%02d:00" % TimeModel.WEEK_START_HOUR
	$WeekEnd.text = "%02d:00" % (end % 24)
	_put($WeekStart, x0, HOUR_LINE)
	_put($WeekEnd, _slot_x - g.pad - $WeekEnd.get_minimum_size().x, HOUR_LINE)
	$NextKey.text = Fmt.upper(tr("TOPBAR_NEXT"))
	var line: String = tr("TOPBAR_NEXT_WORKDAY_END").format({"n": maxi(end - GameState.current_hour, 0)})
	var ink = null
	if _offer_weeks_left > 1:
		line = tr("TOPBAR_NEXT_OFFER").format({"n": _offer_weeks_left})
		ink = UiTokens.D_warn()
	elif _offer_weeks_left >= 0:
		line = tr("TOPBAR_NEXT_OFFER_LAST")
		ink = UiTokens.D_neg()
	_paint($NextLine, line, ink)
	_put($NextKey, _slot_x + g.pad, NEXT_KEY_LINE)
	_put($NextLine, _slot_x + g.pad, NEXT_LINE, g.slot - 2 * g.pad)
	_refresh_gate(g)


## The gate: while a decision waits the slot says so and the clock's keys are off.
func _refresh_gate(g: Dictionary) -> void:
	var gated: bool = GameState.run_active and EventGate.active_id() != ""
	for part: Control in [$NextKey, $NextLine]:
		part.visible = not gated
	for part: Control in [$GateDot, $GateRing, $GateLabel, $GateLine, $GateHit, $GateFrame]:
		part.visible = gated
	for b in speed_btns:
		b.disabled = gated
	if not gated:
		if _pulse != null:
			_pulse.kill()
			_pulse = null
		return
	var dot := Vector2(_slot_x + g.pad, GATE_LINE - UiTokens.SPACE_M)
	$GateDot.position = dot
	$GateRing.position = dot
	$GateLabel.text = Fmt.upper(tr("TOPBAR_GATE"))
	var left: float = dot.x + UiTokens.SPACE_M + UiTokens.SPACE_M
	_put($GateLabel, left, GATE_LINE, _slot_x + g.slot - g.pad - left)
	var waiting: int = 1 + EventGate.queue_size()
	$GateLine.text = tr("TOPBAR_GATE_COUNT").format({"n": waiting}) if waiting > 1 \
		else String(INBOX.active_item().sender.name)
	_put($GateLine, left, GATE_SUB_LINE, _slot_x + g.slot - g.pad - left)
	$GateHit.position = Vector2(_slot_x, 0)
	$GateHit.size = Vector2(g.slot, size.y)
	$GateFrame.position = Vector2(_slot_x, 0)
	$GateFrame.size = Vector2(g.slot + g.time, size.y)
	if _pulse == null:
		_pulse = create_tween().set_loops()
		_pulse.tween_property($GateRing, "scale", Vector2.ONE * PULSE_SCALE, PULSE_S).from(Vector2.ONE)
		_pulse.parallel().tween_property($GateRing, "modulate:a", 0.0, PULSE_S).from(PULSE_ALPHA)


## A speed key pressed while the decision holds the clock: the frame blinks twice.
func blink_gate() -> void:
	var tw := create_tween()
	for i in 2:
		tw.tween_property($GateFrame, "modulate:a", 0.4, BLINK_S)
		tw.tween_property($GateFrame, "modulate:a", 1.0, BLINK_S)


func _refresh_time(g: Dictionary) -> void:
	var block: Panel = $TimeBlock
	block.position = Vector2(_slot_x + g.slot, 0)
	block.size = Vector2(g.time, size.y)
	$TimeBlock/Clock.text = "%02d:00" % GameState.current_hour
	_put($TimeBlock/Clock, g.time_pad, CLOCK_LINE)
	for i in speed_btns.size():
		speed_btns[i].position = Vector2(g.time_pad + CLOCK_W + g.gap + i * (g.key + KEY_GAP), KEYS_Y)
		speed_btns[i].size = Vector2(g.key, UiTokens.D_H_SPEED_KEY)


## Yazı taban çizgisine oturur; genişlik verilirse kutu o kadardır (taşan metin üç noktayla kısalır).
func _put(label: Label, x: float, baseline: float, width := 0.0) -> void:
	label.position = Vector2(x, baseline - label.get_theme_font("font").get_ascent(label.get_theme_font_size("font_size")))
	if width > 0.0:
		label.size.x = width


## Durum rengi yalnız anlamı olan değerde; yoksa varyasyonun mürekkebi.
func _paint(label: Label, text: String, ink) -> void:
	label.text = text
	if ink == null:
		label.remove_theme_color_override("font_color")
	else:
		label.add_theme_color_override("font_color", ink)


func _draw() -> void:
	var g: Dictionary = GRID[int(_compact)]
	var h: float = size.y
	for x in [g.brand - 1, g.day, _slot_x]:
		draw_rect(Rect2(x, 0, 1, h), UiTokens.D_LINE_1)
	draw_rect(Rect2(g.rule, RULE_INSET, 1, h - 2 * RULE_INSET), UiTokens.D_LINE_1)
	var time_end: float = _slot_x + g.slot + g.time
	if time_end < size.x:
		draw_rect(Rect2(time_end, 0, 1, h), UiTokens.D_LINE_1)
	_draw_week(g.day + g.pad, _slot_x - g.pad)


## Haftanın 08:00'den mesainin bitimine kadarki saatleri: mesai öncesi ince iz, geçen saatler dolgu,
## her saat bir çentik (bitiş uzun), şimdi dikey işaret.
func _draw_week(x0: float, x1: float) -> void:
	var start: int = TimeModel.WEEK_START_HOUR
	var end: int = WorkHoursSystem.workday_end()
	var at := func(hour: float) -> float: return x0 + (hour - start) / float(end - start) * (x1 - x0)
	var open: float = at.call(clampi(WorkHoursSystem.start_hour(), start, end))
	var now: float = at.call(clampf(GameState.current_hour, start, end))
	draw_rect(Rect2(x0, WEEK_Y + 1, open - x0, 2), UiTokens.D_BAR_TRACK)
	draw_rect(Rect2(open, WEEK_Y, x1 - open, 4), UiTokens.D_BAR_TRACK)
	draw_rect(Rect2(x0, WEEK_Y, now - x0, 4), UiTokens.D_BAR_FILL)
	for hour in range(start + 1, end + 1):
		var x: float = at.call(hour)
		if hour == end:
			draw_rect(Rect2(x - 1, WEEK_Y - 4, 1, 12), UiTokens.D_INK_4)
		else:
			draw_rect(Rect2(x, WEEK_Y + 6, 1, 4), UiTokens.D_LINE_2)
	draw_rect(Rect2(now - 1, WEEK_Y - 5, 2, 14), UiTokens.D_INK_1)


func _apply_speed_visual(active_idx: int) -> void:
	for i in speed_btns.size():
		speed_btns[i].theme_type_variation = &"SpeedKeyActive" if i == active_idx else &"SpeedKey"
