extends Panel

# Üst bar: iki satırlık metrik ızgarası, koyu temada. Her yazı taban çizgisine göre yerleşir
# (y = taban - ascent); sütunlar sabittir ve TR ile EN'in en geniş değerinden ölçülüdür, böylece gün
# bloğu ve hafta çubuğu her durumda ve dilde aynı boydadır. Mantıksal genişlik
# DisplaySettings.COMPACT_SHELL_BELOW altındayken sıkışık kip: marka yalnız kare, kısa tarih, dar hız
# tuşları (rayın simge kipiyle aynı eşik). Hafta çubuğu en çok MAX_WEEK_BAR uzar; daha geniş barda
# Sıradaki yuvası ve saat bloğu gün bloğunun hemen ardından gelir, artan genişlik sağda boş kalır.
# Yuva hedefin merdivenidir: listenin adı ve her adıma bir çentik (biten adımın çentiği dolu, sırasız bitse de), altında
# ilk bitmemiş adım; yeni biten adımın çentiği kısa bir dolmayla yanar. Liste bitip cevabını beklerken çentikler dolu,
# adım satırı boştur; liste kalmayınca yuva boştur. Üzerine gelince altında kart açılır (_paint_card). Masada teklif
# varken yuva merdivenin yerine teklifin süresini taşır. Bir karar beklerken yuva kapıdır:
# amber nokta ve "Cevap bekliyor", altında göndericisi ya da bekleyen kararların sayısı; yuva ve saat bloğu amber
# çerçevede, hız tuşları kapalı, tıklanınca karara dönülür. Son haftasındaki kâğıtlar bildirim yığınında, sprint
# kâğıdı rayın Ürün satırında, mesainin bitimi hafta çubuğunun sağ ucundadır.
# Kurucu görüşmeye giderken, masadayken ve dönerken saat tutulur: saatin altındaki satır bunu söyler
# ("Görüşmede · şirket", "Ofise dönüş"), hız tuşları kapalıdır ve amber yoktur. Çalan ya da süren görüşme hafta
# çubuğunda elmastır, ipucu saatini ve şirketi söyler. Bunların dışında saatin altındaki satır saati tutanın adını
# söyler (tuşlar kapalı). Duraklıyken satır boştur: II yanıp söner, ipucu Boşluk'la sürdüğünü söyler. Ayırıcılar ve
# hafta çubuğu _draw'da.

const INBOX := preload("res://scripts/ui/components/inbox.gd")
const ChequeRead := preload("res://scripts/systems/cheque_read.gd")
const GO_ICON := preload("res://assets/icons/util/arrow_right.svg")

## The goal ladder, after Frostpunk 2 (Erdem, N04): the list's name in sparse caps on this baseline, its notches in
## these inks (done, open); under it a ring, then the step's words narrow and semibold and its figure plain, on this
## baseline (LadderHead, LadderStep, LadderFigure).
const LADDER_HEAD_LINE := 25.0
const LADDER_ON := UiTokens.D_INK_2
const LADDER_OFF := UiTokens.D_LINE_2
const LADDER_STEP_LINE := 49.0
## Every step's words take one size, their own or less, down to this at the least (_step_size).
const LADDER_LEAST_FS := UiTokens.D_FS_14
## A notch per step after the list's name: this size, this far apart, the first this far after the name, their foot
## this far over the name's baseline. Where the name and the notches would overrun the slot the notches narrow, down
## to NOTCH_LEAST; the name is never cut.
const NOTCH := Vector2(13, 4)
const NOTCH_LEAST := 4.0
const NOTCH_GAP := 3.0
const NOTCH_LEAD := 6.0
const NOTCH_RISE := 2.0
## The ring before the step: the box it fills, its radius to the line's middle and the line, its centre this far
## over the step's baseline, the words this far after the box.
const RING_BOX := 10.0
const RING_R := 4.25
const RING_W := 1.5
const RING_RISE := 7.0
const RING_GAP := 8.0
## A step just done fills its notch over this long.
const LIT_S := 0.4
## The card's layer: over the office and its windows, under the shell's panels (9), modals and toasts.
const CARD_LAYER := 8

## [tam, sıkışık]: marka bloğunun genişliği; anahtar (A, C, E, G) ve değer (B, D, F, H) sütunlarının
## sol kenarı; iki metrik grubunu ayıran kısa çizgi; gün bloğunun başı ve iç payı; yuva ve saat
## bloğunun genişliği, saatin sol payı, hız tuşunun genişliği ve saatle tuşlar arası.
const GRID := [
	{"brand": 184, "A": 204, "B": 246, "C": 414, "D": 480, "rule": 616, "E": 637, "F": 684, "G": 766,
		"H": 843, "day": 943, "pad": 20, "slot": 248, "time": 291, "time_pad": 20, "key": 40, "gap": 16},
	{"brand": 64, "A": 76, "B": 116, "C": 276, "D": 340, "rule": 468, "E": 481, "F": 526, "G": 600,
		"H": 675, "day": 767, "pad": 16, "slot": 216, "time": 235, "time_pad": 12, "key": 30, "gap": 12},
]
## Taban çizgileri: iki metrik satırı, marka adı ve evre, tarih ve hafta çubuğunun saatleri (saatin durum
## satırı da bu alt çizgiye oturur), yuvanın iki satırı, saat.
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
## blink_held's blink: twice, each way this long.
const BLINK_S := 0.09
## The paused II's blink: one full cycle this long, dimming to this alpha and back.
const PAUSE_BLINK_S := 0.8
const PAUSE_BLINK_ALPHA := 0.45
const CLOCK_LINE := 35.0
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
const KEYS_Y := 10.0
const KEY_GAP := 4.0
const UNIT_GAP := 2.0
const RULE_INSET := 12.0
## Hafta çubuğu: üst kenarı, uzunluk tavanı; görüşmenin elmasının yarı köşegeni ve ortası.
const WEEK_Y := 38.0
const MAX_WEEK_BAR := 720.0
const MARK_HALF := 5.0
const MARK_Y := WEEK_Y - 1.5

@onready var speed_btns: Array[Button] = [
	$TimeBlock/PauseBtn,
	$TimeBlock/Speed1Btn,
	$TimeBlock/Speed2Btn,
	$TimeBlock/Speed3Btn,
]

## Teklif geri sayımı yalnız tikte yayılır; dil ya da palet değişince yeniden boyamak için tutulur.
## -1 = teklif yok.
var _offer_weeks_left: int = -1
## main.gd'nin oynattığı görüşme: {phase, place}. "call" çalan aramadır ve yuvada sırası gelince görünür;
## "trip", "sitting" ve "home" saati tutar.
var _meeting := {}
var _compact := false
var _g: Dictionary          # yürürlükteki ızgara; her `_refresh` kurar
var _slot_x := 0.0
var _pulse: Tween
var _pause_blink: Tween
var _queued := false
## Ölçüm sayacı: --tick-probe bir karedeki yenilemeleri buradan sayar.
var refresh_count := 0
var _week_end := 0      # gün bloğunun kurulduğu mesai bitimi; hafta çubuğu orada biter
var _clock_min := -1    # saatin gösterdiği an: gece yarısından beri dakika, CLOCK_STEP_MIN adımlı
var _now_px := -1       # hafta çubuğunun şimdi işareti, tam piksel
## The ladder as painted: {list, title_key, done (one bool per step), next}; {} while the slot shows none.
var _ladder := {}
var _lit: Array[int] = []   # the notches filling now, and how far (0 to 1)
var _notch_w: float = NOTCH.x
var _step_px := {}   # the steps' one size per language and slot width (_step_size)
var _lit_t := 1.0
var _lit_tween: Tween
var _head := Label.new()
var _step := Label.new()
var _figure := Label.new()
var _hit := Control.new()   # the slot's hover area while the ladder shows
var _card := PanelContainer.new()


func _ready() -> void:
	# Bağlantılar tek tek yazılır: sinyal manifestinin üreticisi `EventBus.<ad>.connect` biçimini okur.
	EventBus.cash_changed.connect(_queue_refresh)
	EventBus.mrr_changed.connect(_queue_refresh)
	EventBus.burn_changed.connect(_queue_refresh)
	EventBus.runway_recalculated.connect(_queue_refresh)
	EventBus.brand_changed.connect(_queue_refresh)
	EventBus.reputation_changed.connect(_queue_refresh)
	EventBus.day_advanced.connect(_queue_refresh)
	EventBus.hour_changed.connect(_queue_refresh)
	EventBus.phase_changed.connect(_queue_refresh)
	EventBus.shutter_changed.connect(_queue_refresh)
	EventBus.language_changed.connect(_queue_refresh)
	EventBus.palette_changed.connect(_queue_refresh)
	EventBus.month_ended.connect(_queue_refresh)
	EventBus.event_triggered.connect(_queue_refresh)
	EventBus.event_set_aside.connect(_queue_refresh)
	EventBus.event_resolved.connect(_queue_refresh)
	EventBus.desk_changed.connect(_queue_refresh)
	# The goal's steps move with these too: the run opens paused, with no hour_changed.
	EventBus.sprint_planned.connect(_queue_refresh)
	EventBus.sprint_started.connect(_queue_refresh)
	EventBus.version_shipped.connect(_queue_refresh)
	EventBus.customer_added.connect(_queue_refresh)
	EventBus.customer_removed.connect(_queue_refresh)
	EventBus.game_loaded.connect(_queue_refresh)
	EventBus.offer_countdown_changed.connect(_on_offer_countdown_changed)
	# A window opening over the office shuts the card; a language switch repaints it.
	EventBus.tab_changed.connect(func(id: String) -> void:
		if id != "":
			_shut_card())
	EventBus.language_changed.connect(_repaint_card.unbind(1))
	EventBus.mentor_advisory_changed.connect(_repaint_card.unbind(2))
	# Hız ve tutuş yalnız TimeManager üzerinden gelir (speed_changed, hold_changed); tuşlar ve durum satırı
	# buradan boyanır ki tutuş ve yükleme gibi başka değiştiriciler de görünsün.
	TimeManager.speed_changed.connect(_apply_speed_visual)
	TimeManager.speed_changed.connect(_refresh_state.unbind(1))
	TimeManager.hold_changed.connect(_queue_refresh)
	for i in speed_btns.size():
		speed_btns[i].pressed.connect(EventBus.speed_change_requested.emit.bind(i))
	resized.connect(_refresh)
	$GateHit.gui_input.connect(func(e: InputEvent) -> void:
		if UiFactory.is_left_click(e):
			INBOX.show("active"))
	add_to_group(&"top_bar")
	_build_ladder()
	_refresh()
	_apply_speed_visual(TimeManager.current_speed)


## The ladder's labels in the slot, over them its hover area, and the card on its own layer.
func _build_ladder() -> void:
	for row in [[_head, &"LadderHead"], [_step, &"LadderStep"], [_figure, &"LadderFigure"]]:
		row[0].theme_type_variation = row[1]
		row[0].mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(row[0])
	_hit.mouse_entered.connect(_open_card)
	add_child(_hit)
	set_process_input(false)   # only while the card is open (_input)
	var layer := CanvasLayer.new()
	layer.layer = CARD_LAYER
	add_child(layer)
	# A CanvasLayer breaks the theme's inheritance: the card holds the theme itself.
	_card.theme = load(UiTokens.MENAJER_THEME)
	_card.theme_type_variation = &"FloatPanel"
	_card.custom_minimum_size.x = UiTokens.D_W_TIP
	_card.visible = false
	# A wrapped step's first measure is narrow and tall: the card follows its content down to its true height.
	_card.minimum_size_changed.connect(func() -> void: _card.reset_size())
	layer.add_child(_card)


## Saat ve hafta çubuğunun şimdi işareti akümülatörü her karede okur; yalnız gösterdikleri değişince boyanır.
func _process(_delta: float) -> void:
	_show_clock()
	var px := int(_week_x(TimeManager.day_minute() / 60.0))
	if px != _now_px:
		_now_px = px
		queue_redraw()


func _on_offer_countdown_changed(weeks_left: int) -> void:
	_offer_weeks_left = weeks_left
	_queue_refresh()


## Bir karede ne kadar sinyal gelirse gelsin tek boyama: gecenin toplu adımı onlarcasını yollar.
func _queue_refresh(_a = null, _b = null) -> void:
	if not _queued:
		_queued = true
		_refresh.call_deferred()


## main.gd: `place`'teki görüşme çalıyor ("call"), yolda ("trip"), masada ("sitting"), dönüşte ("home") ya da
## bitti ("").
func show_meeting(phase: String, place := "") -> void:
	_meeting = {"phase": phase, "place": place} if phase != "" else {}
	_refresh()


func _held() -> bool:
	return _meeting.get("phase", "") in ["trip", "sitting", "home"]


func _refresh() -> void:
	refresh_count += 1
	_queued = false
	_compact = get_viewport_rect().size.x < DisplaySettings.COMPACT_SHELL_BELOW
	var reading: Dictionary = UiTokens.D_runway_reading()
	_g = GRID[int(_compact)].duplicate()
	# RUNWAY hücresi gizliyken çizgi, ikinci metrik grubu ve gün bloğu onun bıraktığı boşluğu kapatır.
	if reading.text == "":
		var closed: int = _g.rule - _g.C
		for key in ["rule", "E", "F", "G", "H", "day"]:
			_g[key] -= closed
	_refresh_brand()
	_refresh_metrics(reading)
	_slot_x = minf(size.x - _g.time - _g.slot, _g.day + _g.pad + MAX_WEEK_BAR + _g.pad)
	_refresh_time()
	_refresh_day()
	queue_redraw()


## Marka bloğu: turuncu kare + şirketin adı ve evre; sıkışık kipte yalnız kare.
func _refresh_brand() -> void:
	$Logo.position = LOGO_COMPACT if _compact else LOGO
	$LogoName.text = GameState.company_name
	var phase: int = clampi(GameState.phase, 1, GameState.PHASE_KEYS.size())
	# Ham to_upper bilerek: İngilizce kanon terim; Fmt.upper'ın Türkçe dalı "TRACTİON" yapardı.
	$Phase.text = tr(GameState.PHASE_KEYS[phase - 1]).to_upper()
	_put($LogoName, NAME_X, NAME_LINE, _g.brand - NAME_X - NAME_RIGHT)
	_put($Phase, NAME_X, PHASE_LINE)
	for i in 3:
		var dot: Panel = get_node("PhaseDot%d" % (i + 1))
		dot.position = Vector2(NAME_X + PHASE_W + PHASE_DOT_GAP + i * PHASE_DOT_STEP, PHASE_DOT_Y)
		dot.theme_type_variation = &"PhaseDotActive" if i < phase else &"PhaseDotDim"
	for part: Control in [$LogoName, $Phase, $PhaseDot1, $PhaseDot2, $PhaseDot3]:
		part.visible = not _compact


## KASA tek kahraman, NET altında. Kepenk sayacı koşarken RUNWAY hücresi o sayaçtır. Kırmızı yalnız
## tehlikede: eksi kasa, kepenk, ilk runway eşiğinin altı; kasa artıdayken eksi NET mürekkeptir.
func _refresh_metrics(reading: Dictionary) -> void:
	var flow: Dictionary = FinanceSystem.get_monthly_flow()
	var net: int = int(flow.net)
	_paint($CashValue, Fmt.money_exact(GameState.cash), UiTokens.D_neg() if GameState.cash < 0 else null)
	_paint($NetValue, ("+" if net > 0 else ("-" if net < 0 else "")) + Fmt.money_chip(absi(net)), UiTokens.D_net_ink(net))
	# Kasa iki tik arasında eksiye düşebilir (olay, tek seferlik gider); kepenk sayacı sonraki tikte
	# kurulur, o arada hücre RUNWAY kalır.
	$RunwayKey.text = Fmt.upper(tr("TOPBAR_SHUTTER" if reading.shutter else "FIN_CAP_RUNWAY"))
	var runway: Label = $RunwayValue
	runway.theme_type_variation = &"ValueText" if reading.ink == null else &"ValueTextStrong"
	_paint(runway, reading.text, reading.ink)
	# Net akış eksi değilken okunacak sayaç yok: hücre çizilmez ve yeri kapanır (_refresh).
	$RunwayKey.visible = reading.text != ""
	runway.visible = reading.text != ""
	$MrrValue.text = Fmt.money_chip(GameState.mrr)
	$BrandValue.text = str(GameState.brand)
	$BurnValue.text = Fmt.money_chip(int(flow.expense))
	$RepValue.text = str(GameState.reputation)
	# Hata yüzünden itibar düştüyse sebebi ipucunda (ipucu üzerine gelmeyi ister).
	var drop_note: String = SupportSystem.neglect_note()
	for part: Label in [$RepKey, $RepValue]:
		part.tooltip_text = drop_note
		part.mouse_filter = Control.MOUSE_FILTER_IGNORE if drop_note == "" else Control.MOUSE_FILTER_STOP
	for row in [[$CashKey, $CashValue, "A", "B", ROW_1], [$NetKey, $NetValue, "A", "B", ROW_2],
			[$RunwayKey, runway, "C", "D", ROW_1], [$MrrKey, $MrrValue, "E", "F", ROW_1],
			[$BrandKey, $BrandValue, "E", "F", ROW_2], [$BurnKey, $BurnValue, "G", "H", ROW_1],
			[$RepKey, $RepValue, "G", "H", ROW_2]]:
		_put(row[0], _g[row[2]], row[4])
		_put(row[1], _g[row[3]], row[4])
	for row in [[$NetUnit, $NetValue, ROW_2], [$BurnUnit, $BurnValue, ROW_1]]:
		_put(row[0], row[1].position.x + row[1].get_minimum_size().x + UNIT_GAP, row[2])


## Gün bloğu (tarih + hafta çubuğu ve uç saatleri) ve yuva: masada teklif varken onun süresi (uyarı renginde, son
## haftasında kırmızı), yoksa hedefin merdiveni, liste yoksa boş.
func _refresh_day() -> void:
	var d: Dictionary = GameState.get_date_dict()
	$Date.text = tr("TOPBAR_DATE_COMPACT").format({"week": int(d.week), "mon": Fmt.month_abbr(int(d.month))}) \
		if _compact else Fmt.date_line(d)
	var x0: float = _g.day + _g.pad
	_put($Date, x0, DATE_LINE)
	_week_end = WorkHoursSystem.workday_end()
	$WeekStart.text = "%02d:00" % TimeModel.WEEK_START_HOUR
	$WeekEnd.text = "%02d:00" % (_week_end % 24)
	_put($WeekStart, x0, HOUR_LINE)
	_put($WeekEnd, _slot_x - _g.pad - $WeekEnd.get_minimum_size().x, HOUR_LINE)
	$NextKey.text = Fmt.upper(tr("TOPBAR_NEXT"))
	var offer: Dictionary = UiTokens.D_offer_reading(_offer_weeks_left) if _offer_weeks_left >= 0 \
		else {"text": "", "ink": null}
	_paint($NextLine, offer.text, offer.ink)
	_put($NextKey, _slot_x + _g.pad, NEXT_KEY_LINE)
	_put($NextLine, _slot_x + _g.pad, NEXT_LINE, _g.slot - 2 * _g.pad)
	_paint_ladder({} if offer.text != "" else ChequeRead.summary())
	_refresh_gate()


## The list's name and its first open step in the slot (the notches and the ring are _draw's). A step done since the
## last paint of the same list fills its notch; a new list, the first paint and a step coming back fill none.
func _paint_ladder(goal: Dictionary) -> void:
	var was: Dictionary = _ladder
	_ladder = {} if goal.is_empty() else {"list": goal.list, "title_key": goal.title_key, "next": goal.next,
		"done": ChequeRead.steps().map(func(s: Dictionary) -> bool: return s.done)}
	if _ladder.is_empty():
		_shut_card()
		return
	if not was.is_empty() and was.list == _ladder.list:
		var lit: Array[int] = []
		for i in _ladder.done.size():
			if _ladder.done[i] and not was.done[i]:
				lit.append(i)
		if not lit.is_empty():
			_light(lit)
	if _card.visible and (was.get("done", []) != _ladder.done or was.get("list", "") != _ladder.list):
		_paint_card()
	var x: float = _slot_x + _g.pad
	_head.text = Fmt.upper(tr(goal.title_key))
	_head.reset_size()
	_put(_head, x, LADDER_HEAD_LINE)
	var right: float = _slot_x + _g.slot - _g.pad
	var n: int = _ladder.done.size()
	_notch_w = clampf((right - x - _width(_head) - NOTCH_LEAD - (n - 1) * NOTCH_GAP) / n, NOTCH_LEAST, NOTCH.x)
	var parts: PackedStringArray = _step_parts(goal.next) if not goal.next.is_empty() else PackedStringArray(["", ""])
	_step.text = parts[0]
	_figure.text = parts[1]
	x += RING_BOX + RING_GAP
	var px: int = _step_size(right - x)
	for part: Label in [_step, _figure]:
		part.add_theme_font_size_override("font_size", px)
		part.reset_size()
	_put(_step, x, LADDER_STEP_LINE)
	_put(_figure, x + _width(_step), LADDER_STEP_LINE)
	_hit.position = Vector2(_slot_x, 0)
	_hit.size = Vector2(_g.slot, size.y)


## A step's words and, for a step with a figure, the figure in its own ink: ["Aylık gelir", " $2,5K"].
func _step_parts(step: Dictionary) -> PackedStringArray:
	var parts: PackedStringArray = tr(step.text_key).split("{bar}")
	if parts.size() < 2:
		return PackedStringArray([parts[0], ""])
	return PackedStringArray([parts[0].rstrip(" "),
		(" " if parts[0].ends_with(" ") else "") + Fmt.money_chip(int(step.target)) + parts[1]])


## The one size every goal step's words take at `room` in the live language: their own, or the largest under it
## that the longest step of either list fits, never under LADDER_LEAST_FS. One size, so the words keep it from step to
## step and from list to list.
func _step_size(room: float) -> int:
	var key := "%s|%d" % [TranslationServer.get_locale(), int(room)]
	if not _step_px.has(key):
		var words_font: Font = get_theme_font("font", &"LadderStep")
		var figure_font: Font = get_theme_font("font", &"LadderFigure")
		var all: Array = (ChequeRead.steps("cheque") + ChequeRead.steps("seed")).map(_step_parts)
		var px: int = get_theme_font_size("font_size", &"LadderStep")
		while px > LADDER_LEAST_FS and all.any(func(p: PackedStringArray) -> bool:
				return words_font.get_string_size(p[0], HORIZONTAL_ALIGNMENT_LEFT, -1, px).x \
					+ figure_font.get_string_size(p[1], HORIZONTAL_ALIGNMENT_LEFT, -1, px).x > room):
			px -= 1
		_step_px[key] = px
	return _step_px[key]


## `label`'s words at its own font and size.
func _width(label: Label) -> float:
	return label.get_theme_font("font").get_string_size(label.text, HORIZONTAL_ALIGNMENT_LEFT, -1,
		label.get_theme_font_size("font_size")).x


## The notches of `lit` fill from the left over LIT_S.
func _light(lit: Array[int]) -> void:
	if _lit_tween != null:
		_lit_tween.kill()
	_lit = lit
	_lit_t = 0.0
	_lit_tween = create_tween()
	_lit_tween.tween_method(func(t: float) -> void:
		_lit_t = t
		queue_redraw(), 0.0, 1.0, LIT_S)
	_lit_tween.finished.connect(func() -> void:
		_lit = []
		queue_redraw())


func _ladder_shown() -> bool:
	return not _ladder.is_empty() and not _gated()


func _gated() -> bool:
	return GameState.run_active and EventGate.active_id() != "" and not _held()


## The pointer onto the slot opens the card under it.
func _open_card() -> void:
	if not _ladder_shown() or ChequeRead.summary().is_empty():   # a list just ended, before the slot's refresh
		return
	_paint_card()
	_card.visible = true
	set_process_input(true)


## The card stays while the pointer is on the slot or on the card; the motion says where in the frame (the card's own
## enter and exit miss a child entered from outside, and the pointer's position is the screen's under the harness).
func _input(event: InputEvent) -> void:
	if _card.visible and event is InputEventMouseMotion:
		var at: Vector2 = (event as InputEventMouseMotion).position
		if not _hit.get_global_rect().has_point(at) and not _card.get_global_rect().has_point(at):
			_shut_card()


func _shut_card() -> void:
	_card.visible = false
	set_process_input(false)


func _repaint_card() -> void:
	if _card.visible:
		_paint_card()


## The card: Frank (his latest advice his tip, as the office's notice stack shows it), the list's name and how many of its
## steps are done, every step of the list down its mark, and the button to the tab of the step it stands on.
## No word on what the list brings, and no later list.
func _paint_card() -> void:
	UiFactory.clear(_card)
	var goal: Dictionary = ChequeRead.summary()
	if goal.is_empty():
		_shut_card()
		return
	var col := SprintUiShared.column(0)
	_card.add_child(SprintUiShared.pad(col, Vector4i(UiTokens.SPACE_XL, UiTokens.SPACE_XL, UiTokens.SPACE_XL,
		UiTokens.SPACE_XL)))
	var head := SprintUiShared.box(UiTokens.SPACE_L)
	col.add_child(head)
	var face: TextureRect = UiFactory.make_mentor_avatar(UiTokens.D_AVATAR_ROW)
	var said: bool = GameState.mentor_line_key != "" and MailClock.delivered(GameState.mentor_line_at)
	face.mouse_filter = Control.MOUSE_FILTER_STOP if said else Control.MOUSE_FILTER_IGNORE
	face.tooltip_text = tr("FIN_MENTOR_QUOTE_WRAPPED").format(
		{"quote": tr(GameState.mentor_line_key).format(GameState.mentor_line_args)}) if said else ""
	head.add_child(face)
	var title := SprintUiShared.label(Fmt.upper(tr(goal.title_key)), &"LadderHead")
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(title)
	head.add_child(SprintUiShared.label(tr("GOAL_DONE_COUNT").format({"done": goal.done, "total": goal.total}),
		&"MetaMuted"))
	col.add_child(SprintUiShared.pad(HSeparator.new(), Vector4i(0, UiTokens.SPACE_M, 0, UiTokens.SPACE_S)))
	var steps: Array = ChequeRead.steps()
	var now: int = steps.map(func(s: Dictionary) -> bool: return s.done).find(false)
	for i in steps.size():
		var row := SprintUiShared.box(UiTokens.SPACE_M)
		row.custom_minimum_size.y = UiTokens.D_H_SHEET_ROW
		var state: String = "Done" if steps[i].done else ("Now" if i == now else "Open")
		var mark := Panel.new()
		mark.theme_type_variation = StringName("LadderMark" + state)
		mark.custom_minimum_size = Vector2.ONE * UiTokens.D_ICON_MARK
		mark.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		row.add_child(mark)
		var words := SprintUiShared.prose(INBOX.goal_step(steps[i]), StringName("LadderCard" + state))
		words.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		row.add_child(words)
		col.add_child(row)
	if now >= 0:
		var go := Button.new()
		go.theme_type_variation = &"SecondaryButtonSmall"
		go.focus_mode = Control.FOCUS_NONE
		go.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
		go.text = tr("GOAL_GO_" + String(steps[now].tab).to_upper())
		go.icon = GO_ICON
		go.icon_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		go.pressed.connect(func() -> void:
			_shut_card()
			EventBus.tab_changed.emit(String(steps[now].tab)))
		col.add_child(SprintUiShared.pad(go, Vector4i(0, UiTokens.SPACE_L, 0, 0)))
	_card.reset_size()
	var left: float = global_position.x + _slot_x + UiTokens.SPACE_M
	_card.position = Vector2(minf(left, get_viewport_rect().size.x - UiTokens.D_W_TIP - UiTokens.SPACE_M),
		global_position.y + size.y - UiTokens.SPACE_XXS)


## The gate: while a decision waits the slot says so and the clock's keys are off. A meeting or any other
## hold turns the keys off too, without the gate's amber.
func _refresh_gate() -> void:
	var held := _held()
	var gated: bool = _gated()
	for part: Control in [$NextKey, $NextLine]:
		part.visible = not gated and $NextLine.text != ""
	for part: Control in [_head, _step, _figure, _hit]:
		part.visible = _ladder_shown()
	if not _ladder_shown():
		_shut_card()
	for part: Control in [$GateDot, $GateRing, $GateLabel, $GateLine, $GateHit, $GateFrame]:
		part.visible = gated
	for b in speed_btns:
		b.disabled = gated or held or TimeManager.is_clock_held()
	if not gated:
		if _pulse != null:
			_pulse.kill()
			_pulse = null
		return
	var dot := Vector2(_slot_x + _g.pad, GATE_LINE - UiTokens.SPACE_M)
	$GateDot.position = dot
	$GateRing.position = dot
	$GateLabel.text = Fmt.upper(tr("TOPBAR_GATE"))
	var left: float = dot.x + UiTokens.SPACE_M + UiTokens.SPACE_M
	_put($GateLabel, left, GATE_LINE, _slot_x + _g.slot - _g.pad - left)
	var waiting: int = 1 + EventGate.queue_size()
	$GateLine.text = tr("TOPBAR_GATE_COUNT").format({"n": waiting}) if waiting > 1 \
		else String(INBOX.active_item().sender.name)
	_put($GateLine, left, GATE_SUB_LINE, _slot_x + _g.slot - _g.pad - left)
	$GateHit.position = Vector2(_slot_x, 0)
	$GateHit.size = Vector2(_g.slot, size.y)
	$GateFrame.position = Vector2(_slot_x, 0)
	$GateFrame.size = Vector2(_g.slot + _g.time, size.y)
	if _pulse == null:
		_pulse = create_tween().set_loops()
		_pulse.tween_property($GateRing, "scale", Vector2.ONE * PULSE_SCALE, PULSE_S).from(Vector2.ONE)
		_pulse.parallel().tween_property($GateRing, "modulate:a", 0.0, PULSE_S).from(PULSE_ALPHA)


## A request the hold refuses (a speed key, a meeting entry): the gate's frame blinks twice, or with no gate
## the state line.
func blink_held() -> void:
	var part: Control = $GateFrame if EventGate.active_id() != "" and not _held() else $TimeBlock/State
	var tw := create_tween()
	for i in 2:
		tw.tween_property(part, "modulate:a", 0.4, BLINK_S)
		tw.tween_property(part, "modulate:a", 1.0, BLINK_S)


func _refresh_time() -> void:
	var block: Panel = $TimeBlock
	block.position = Vector2(_slot_x + _g.slot, 0)
	block.size = Vector2(_g.time, size.y)
	_show_clock()
	_put($TimeBlock/Clock, _g.time_pad, CLOCK_LINE)
	_put($TimeBlock/State, _g.time_pad, HOUR_LINE, _g.time - 2 * _g.time_pad)
	for i in speed_btns.size():
		speed_btns[i].position = Vector2(_g.time_pad + CLOCK_W + _g.gap + i * (_g.key + KEY_GAP), KEYS_Y)
		speed_btns[i].size = Vector2(_g.key, UiTokens.D_H_SPEED_KEY)
	_refresh_state()


## Saatin altındaki satır saatin neden tutulduğunu söyler: görüşme (yolda ve masada şirketiyle, dönüşte "Ofise
## dönüş") ya da tutanın adı. Bekleyen karar bunu yuvada söyler. Duraklıyken satır boştur (envanter shell-01): II yanıp
## söner, ipucu Boşluk'la sürdüğünü söyler.
func _refresh_state() -> void:
	var paused := false
	var line := ""
	if _held():
		line = tr("TOPBAR_TRIP_HOME") if _meeting.phase == "home" \
			else tr("TOPBAR_HELD_AT").format({"state": tr("TOPBAR_IN_MEETING"), "company": _meeting.place})
		# The narrow bar has no room for both: the company alone, the held clock and the diamond say it is a meeting.
		var state: Label = $TimeBlock/State
		if state.get_theme_font("font").get_string_size(Fmt.upper(line), HORIZONTAL_ALIGNMENT_LEFT, -1,
				state.get_theme_font_size("font_size")).x > _g.time - 2 * _g.time_pad:
			line = _meeting.place
	elif EventGate.active_id() == "":
		if TimeManager.is_clock_held():
			line = tr(TimeManager.hold_label())
		else:
			paused = GameState.run_active and TimeManager.current_speed == 0
	$TimeBlock/State.text = Fmt.upper(line)
	$TimeBlock/State.visible = line != ""
	var pause_btn: Button = $TimeBlock/PauseBtn
	pause_btn.tooltip_text = tr("TOPBAR_RESUME_TIP") if paused else ""
	if not paused:
		if _pause_blink != null:
			_pause_blink.kill()
			_pause_blink = null
			pause_btn.modulate.a = 1.0
	elif _pause_blink == null:
		_pause_blink = create_tween().set_loops()
		_pause_blink.tween_property(pause_btn, "modulate:a", PAUSE_BLINK_ALPHA, PAUSE_BLINK_S / 2)
		_pause_blink.tween_property(pause_btn, "modulate:a", 1.0, PAUSE_BLINK_S / 2)


## HH:MM, CLOCK_STEP_MIN dakikalık adımlarla; 24:00'te biten mesai gece beklerken 00:00 okunur.
func _show_clock() -> void:
	var m: int = int(TimeManager.day_minute()) / TimeModel.CLOCK_STEP_MIN * TimeModel.CLOCK_STEP_MIN
	if m != _clock_min:
		_clock_min = m
		$TimeBlock/Clock.text = "%02d:%02d" % [(m / 60) % 24, m % 60]


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
	var h: float = size.y
	for x in [_g.brand - 1, _g.day, _slot_x]:
		draw_rect(Rect2(x, 0, 1, h), UiTokens.D_LINE_1)
	draw_rect(Rect2(_g.rule, RULE_INSET, 1, h - 2 * RULE_INSET), UiTokens.D_LINE_1)
	var time_end: float = _slot_x + _g.slot + _g.time
	if time_end < size.x:
		draw_rect(Rect2(time_end, 0, 1, h), UiTokens.D_LINE_1)
	_draw_week()
	_draw_ladder()


## The ladder's notches after the list's name, a done step's filled, one just done filling from the left, and the ring
## before the step.
func _draw_ladder() -> void:
	if not _ladder_shown():
		return
	var x: float = _head.position.x + _width(_head) + NOTCH_LEAD
	var y: float = LADDER_HEAD_LINE - NOTCH_RISE - NOTCH.y
	for i in _ladder.done.size():
		var at := Rect2(x + i * (_notch_w + NOTCH_GAP), y, _notch_w, NOTCH.y)
		var filling: bool = i in _lit
		draw_rect(at, LADDER_ON if _ladder.done[i] and not filling else LADDER_OFF)
		if filling:
			draw_rect(Rect2(at.position, Vector2(_notch_w * _lit_t, NOTCH.y)), LADDER_ON)
	if not _ladder.next.is_empty():
		draw_arc(Vector2(_slot_x + _g.pad + RING_BOX / 2.0, LADDER_STEP_LINE - RING_RISE), RING_R, 0.0, TAU, 24,
			UiTokens.D_INK_3, RING_W, true)


## Görüşmenin elmasının üstünde: saati ve şirketi.
func _get_tooltip(at_position: Vector2) -> String:
	if _meeting.get("phase", "") not in ["call", "trip", "sitting"] \
			or at_position.distance_to(Vector2(_now_px, MARK_Y)) > MARK_HALF + UiTokens.SPACE_XS:
		return ""
	return tr("TOPBAR_NEXT_MEETING").format({"time": $TimeBlock/Clock.text, "company": _meeting.place})


## Hafta çubuğunda `hour`'un x'i: 08:00 sol uçta, mesainin bitimi sağ uçta; aralık dışındaki saat uca oturur.
func _week_x(hour: float) -> float:
	var start: int = TimeModel.WEEK_START_HOUR
	return remap(clampf(hour, start, _week_end), start, _week_end, _g.day + _g.pad, _slot_x - _g.pad)


## Haftanın 08:00'den mesainin bitimine kadarki saatleri: mesai öncesi ince iz, geçen süre dolgu,
## her saat bir çentik (bitiş uzun), görüşmenin saati elmas, şimdi dikey işaret.
func _draw_week() -> void:
	var x0: float = _week_x(TimeModel.WEEK_START_HOUR)
	var x1: float = _week_x(_week_end)
	var open: float = _week_x(WorkHoursSystem.start_hour())
	var now: float = _week_x(TimeManager.day_minute() / 60.0)
	draw_rect(Rect2(x0, WEEK_Y + 1, open - x0, 2), UiTokens.D_BAR_TRACK)
	draw_rect(Rect2(open, WEEK_Y, x1 - open, 4), UiTokens.D_BAR_TRACK)
	draw_rect(Rect2(x0, WEEK_Y, now - x0, 4), UiTokens.D_BAR_FILL)
	for hour in range(TimeModel.WEEK_START_HOUR + 1, _week_end + 1):
		var x: float = _week_x(hour)
		if hour == _week_end:
			draw_rect(Rect2(x - 1, WEEK_Y - 4, 1, 12), UiTokens.D_INK_4)
		else:
			draw_rect(Rect2(x, WEEK_Y + 6, 1, 4), UiTokens.D_LINE_2)
	# The meeting is now: its diamond sits under the now mark.
	if _meeting.get("phase", "") in ["call", "trip", "sitting"]:
		draw_colored_polygon(PackedVector2Array([Vector2(now, MARK_Y - MARK_HALF), Vector2(now + MARK_HALF, MARK_Y),
			Vector2(now, MARK_Y + MARK_HALF), Vector2(now - MARK_HALF, MARK_Y)]), UiTokens.D_INK_2)
	draw_rect(Rect2(now - 1, WEEK_Y - 5, 2, 14), UiTokens.D_INK_1)


func _apply_speed_visual(active_idx: int) -> void:
	for i in speed_btns.size():
		speed_btns[i].theme_type_variation = &"SpeedKeyActive" if i == active_idx else &"SpeedKey"
