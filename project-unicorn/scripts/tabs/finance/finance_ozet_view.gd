class_name FinanceOzetView
extends Control

# ============================================================================
# Finans sekmesi Özet sayfası (Finance Tab v1 — onaylı mockup "Finans · Nakit
# & Runway"). Kod-kurulu düzen, tscn yok (HR sekmesi idiomu). Router yok:
# tek sayfa; kartlar iki kolonda.
#
# Bu dosya hiçbir sonucu HESAPLAMAZ: her rakam bir motor seam'inden gelir
# (FinanceSystem.get_monthly_flow / get_burn_breakdown_pct / get_transactions /
# get_optimistic_daily_net, GameState.get_cash_history, UiTokens.net_runway_parts).
# Tek istisna BİÇİMLEME (formatters + tarih etiketi).
#
# Mockup'tan bilinçli sapmalar (yönetmen kararı, görev spec'i):
#   * Mentor kartı KREM tonda (koyu değil); yalnız runway eşiğin altındayken.
#   * Gider dağılımı GERÇEK kalemlerden (BURN_IDS) — Pazarlama/Ofis icat edilmez.
#   * "TUR AÇ · SERIES A" yalnız KİLİTLİ durumda; tooltip gerçek kapı
#     sabitlerinden okunur (PhaseGateSystem.GATES). Üç-durumlu makine sonraki iş.
#
# Repaint modeli: cash_changed günlük tikin SON sinyalidir ve ring buffer +
# transactions ledger'ları ondan ÖNCE yazılır (FinanceSystem.daily_tick /
# apply_one_time_cost sıralaması) — hr_day_processed benzeri ek sinyal gerekmez.
# ============================================================================

const RUNWAY_WARN_MONTHS := 6.0   # WORKING: mentor uyarısı eşiği (ay)
const WARN_SNOOZE_DAYS := 14      # WORKING: ERTELE süresi (oyun günü)
const SNOOZE_FLAG := "finance_runway_warn_snooze_until_day"
const TX_SHOWN := 8               # WORKING: Son işlemler'de gösterilen satır sayısı
# Mentor warning line: FIN_MENTOR_QUOTE in strings.csv. Not a const — a const is evaluated
# when the file loads, and no locale exists yet. If RUNWAY_WARN_MONTHS moves, the copy has to
# move with it (the sentence names the threshold in words).

# Aralık düğmeleri: id -> {window: pencere gün sayısı (0 = tümü), horizon: projeksiyon günü}.
# WORKING: horizon = pencere/3; TÜMÜ için 60.
const RANGES := {
	"6ay": {"label_key": "FIN_RANGE_6M", "window": 180, "horizon": 60},
	"12ay": {"label_key": "FIN_RANGE_12M", "window": 360, "horizon": 120},
	"tum": {"label_key": "FIN_RANGE_ALL", "window": 0, "horizon": 60},
}
const RANGE_ORDER := ["6ay", "12ay", "tum"]

var _range: String = "6ay"

# Yerinde-repaint referansları
var _nakit_val: Label
var _net_val: Label
var _runway_val: Label
var _runway_note: Label
var _curve: CashCurve
var _range_btns: Dictionary = {}   # id -> Button
var _legend_current: Control       # "mevcut gidiş" göstergesi — net >= 0 iken gizli
var _flow_refs: Dictionary = {}    # key -> {bar: ProgressBar, val: Label}
var _burn_list: VBoxContainer
var _tx_list: VBoxContainer
var _cap_founder_rect: ColorRect
var _cap_investor_rect: ColorRect
var _cap_employee_rect: ColorRect   # ODA rework: RightPanel'in çalışan-hisse yarısı buraya taşındı
var _cap_rows: Label
var _cap_raised: Label
var _cap_equity_note: Label         # "%d çalışanın hissesi var" (RightPanel'den taşınan TR satırı)
var _mentor_card: PanelContainer
var _appetite_chip_host: HBoxContainer   # "Yatırımcı iştahı" durum çipi (yeniden kurulur; palet duruma bağlı)
var _appetite_line: Label                # çipin altındaki tek satır

var _signals: Array = []


func _ready() -> void:
	_build()
	_signals = [
		[EventBus.cash_changed, _on_state_changed],
		[EventBus.mrr_changed, _on_state_changed],
		[EventBus.burn_changed, _on_state_changed],
		[EventBus.language_changed, _on_state_changed],
		# ODA rework: işe alım/ayrılık çalışan-hisse dilimini oynatabilir.
		[EventBus.character_added, _on_state_changed],
		[EventBus.character_removed, _on_state_changed],
		# Cap table: melek turu nakit de yazdığı için cash_changed BUGÜN yetiyordu — ama
		# bu bir tesadüf. Nakit taşımayan ilk hisse hareketi (opsiyon havuzu, ikincil
		# satış) barı sessizce bayat bırakırdı ve hiçbir test bunu yakalamazdı.
		[EventBus.equity_changed, _on_state_changed],
		# Yatırımcı iştahı (Kalibrasyon Turu A §3): büyüme serisi ay kapanışında değişir, kapı
		# ayrıca mandallanır ve faz ilerler — üçü de MRR'siz boya gerektirir.
		[EventBus.month_ended, _on_state_changed],
		[EventBus.phase_gate_reached, _on_state_changed],
		[EventBus.phase_changed, _on_state_changed],
	]
	for s in _signals:
		(s[0] as Signal).connect(s[1])
	refresh()


func _exit_tree() -> void:
	for s in _signals:
		if (s[0] as Signal).is_connected(s[1]):
			(s[0] as Signal).disconnect(s[1])


func _on_state_changed(_a = null, _b = null, _c = null) -> void:
	if not is_visible_in_tree():
		return  # gizliyken boyama yok — host görünür yaparken refresh() çağırır
	refresh()


# --- Kurulum -----------------------------------------------------------------

func _build() -> void:
	var scroll := ScrollContainer.new()
	scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(scroll)

	var page := VBoxContainer.new()
	page.add_theme_constant_override("separation", 16)
	page.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	page.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.add_child(page)

	# Başlık satırı: sayfa adı + "Yatırımcı iştahı" göstergesi (Kalibrasyon Turu A §3 —
	# eski kilitli "TUR AÇ · SERIES A" düğmesinin ve dolarlı tooltip'inin yerine; yönetmen
	# kararı: sayı gösterilmez, sinyal gösterilir).
	var title_row := HBoxContainer.new()
	page.add_child(title_row)
	var title := UiFactory.make_label(tr("TAB_FINANCE"), &"TitleSerif")
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_row.add_child(title)
	title_row.add_child(_build_appetite_group())

	# İki kolon
	var columns := HBoxContainer.new()
	columns.add_theme_constant_override("separation", 16)
	columns.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	page.add_child(columns)

	var left := VBoxContainer.new()
	left.add_theme_constant_override("separation", 16)
	left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left.size_flags_stretch_ratio = 1.6
	columns.add_child(left)

	var right := VBoxContainer.new()
	right.add_theme_constant_override("separation", 16)
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right.size_flags_stretch_ratio = 1.0
	columns.add_child(right)

	left.add_child(_build_curve_card())
	left.add_child(_build_transactions_card())

	right.add_child(_build_flow_card())
	right.add_child(_build_burn_card())
	right.add_child(_build_captable_card())
	_mentor_card = _build_mentor_card()
	right.add_child(_mentor_card)


func _card(content: VBoxContainer) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.theme_type_variation = &"CardPanel"
	panel.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	panel.add_child(content)
	return panel


func _build_appetite_group() -> Control:
	# The three-state machine this row always anticipated (kilitli / ısınıyor / açık), now
	# driven by the real gate: PhaseGateSystem.series_a_signal() — Terminal recipe, one chip
	# + one line, no figure anywhere. The tooltip names the gate's CONDITIONS from the table
	# (a revenue bar, N months of growth, brand ≥ n) — still no dollar figure.
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 4)
	box.size_flags_horizontal = Control.SIZE_SHRINK_END
	var head := HBoxContainer.new()
	head.add_theme_constant_override("separation", 8)
	head.alignment = BoxContainer.ALIGNMENT_END
	box.add_child(head)
	head.add_child(UiFactory.make_label(InvestorAppetiteUi.title_text(), &"CaptionMuted", UiTokens.INK_MUTED))
	_appetite_chip_host = HBoxContainer.new()
	head.add_child(_appetite_chip_host)
	_appetite_line = UiFactory.make_label("", &"CaptionMuted", UiTokens.INK_MUTED)
	_appetite_line.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	box.add_child(_appetite_line)
	box.tooltip_text = _series_a_tooltip()
	box.mouse_filter = Control.MOUSE_FILTER_PASS
	return box


func _series_a_tooltip() -> String:
	var reqs: Array = []
	for gate in PhaseGateSystem.GATES:
		if int(gate["from"]) != 2:
			continue
		for cond in gate["conditions"]:
			# brand_above kesin ">" — oyuncuya "≥ eşik" olarak çevrilir (PhaseGateSystem.GATES
			# yorumundaki eşik-1 sözleşmesi). Gelir çıtası RAKAMSIZ adlandırılır (yönetmen kararı).
			match String(cond.type):
				"mrr_above":
					reqs.append(tr("FIN_REQ_MRR_BAR"))
				"mrr_growth_streak":
					reqs.append(tr("FIN_REQ_GROWTH").format({"n": int(cond.value)}))
				"brand_above":
					reqs.append(tr("FIN_REQ_BRAND").format({"n": int(cond.value) + 1}))
	return tr("FIN_REQ_OPENS").format({"reqs": " · ".join(reqs)})


func _refresh_appetite() -> void:
	if _appetite_chip_host == null:
		return
	var sig: Dictionary = PhaseGateSystem.series_a_signal()
	for c in _appetite_chip_host.get_children():
		c.queue_free()
	_appetite_chip_host.add_child(InvestorAppetiteUi.chip(String(sig.get("state", "closed"))))
	_appetite_line.text = InvestorAppetiteUi.line(sig)


func _build_curve_card() -> PanelContainer:
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 10)

	# Büyük serif başlık satırı: NAKİT · AYLIK NET · RUNWAY + aralık düğmeleri
	var head := HBoxContainer.new()
	head.add_theme_constant_override("separation", 24)
	vb.add_child(head)
	_nakit_val = _add_headline_stat(head, tr("FIN_CASH"))
	_net_val = _add_headline_stat(head, tr("FIN_MONTHLY_NET"))
	_runway_val = _add_headline_stat(head, tr("FIN_RUNWAY"))
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(spacer)
	var toggles := HBoxContainer.new()
	toggles.add_theme_constant_override("separation", 4)
	toggles.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	head.add_child(toggles)
	for id in RANGE_ORDER:
		var b := Button.new()
		b.text = tr(String(RANGES[id].label_key))
		b.focus_mode = Control.FOCUS_NONE
		b.pressed.connect(_on_range_pressed.bind(id))
		toggles.add_child(b)
		_range_btns[id] = b

	# ARTIDA alt satırı — yalnız pozitif nette görünür (neden ay sayısı yok, açıklama)
	_runway_note = UiFactory.make_label("", &"CaptionMuted", UiTokens.INK_MUTED)
	_runway_note.visible = false
	vb.add_child(_runway_note)

	_curve = CashCurve.new()
	_curve.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vb.add_child(_curve)

	# Gösterge (legend)
	var legend := HBoxContainer.new()
	legend.add_theme_constant_override("separation", 16)
	vb.add_child(legend)
	legend.add_child(_legend_chip(tr("FIN_LEGEND_ACTUAL"), UiTokens.INK))
	_legend_current = _legend_chip(tr("FIN_LEGEND_PROJECTION"), UiTokens.negative())
	legend.add_child(_legend_current)
	legend.add_child(_legend_chip(tr("FIN_LEGEND_PROJECTION_TARGET"), UiTokens.positive()))

	return _card(vb)


func _add_headline_stat(parent: HBoxContainer, caption: String) -> Label:
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 2)
	parent.add_child(col)
	col.add_child(UiFactory.make_section_header(caption))
	var val := UiFactory.make_label("", &"TitleSerif")
	col.add_child(val)
	return val


func _legend_chip(text: String, color: Color) -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	var dot := UiFactory.make_dot(color, 6)
	dot.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(dot)
	row.add_child(UiFactory.make_label(text, &"RowMeta", UiTokens.INK_MUTED))
	return row


func _build_flow_card() -> PanelContainer:
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 8)
	# get_monthly_flow() ay-başından-bugüne DEĞİL, mevcut hızın 30 güne uzatılmış hali —
	# başlık bunu söylemek zorunda: ayın 5'inde "bu ay" yazıp tam ay göstermek, yanındaki
	# boş "Son işlemler" listesiyle doğrudan çelişiyordu. "mevcut gidiş" eğrinin
	# projeksiyon göstergesiyle aynı kelime (bkz. _legend_current).
	vb.add_child(UiFactory.make_section_header(tr("FIN_MONTHLY_FLOW")))
	for entry in [["income", tr("FIN_INCOME")], ["expense", tr("FIN_EXPENSE")],
			["net", tr("FIN_NET")]]:
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 8)
		vb.add_child(row)
		var l := UiFactory.make_label(String(entry[1]), &"RowMeta", UiTokens.INK_DIM)
		l.custom_minimum_size = Vector2(44, 0)
		row.add_child(l)
		var bar := ProgressBar.new()
		bar.theme_type_variation = &"BuildProgress"
		bar.show_percentage = false
		bar.custom_minimum_size = Vector2(0, 6)
		bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		row.add_child(bar)
		var v := UiFactory.make_label("", &"RowMeta", UiTokens.INK)
		v.custom_minimum_size = Vector2(64, 0)
		v.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		row.add_child(v)
		_flow_refs[String(entry[0])] = {"bar": bar, "val": v}
	return _card(vb)


func _build_burn_card() -> PanelContainer:
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 8)
	vb.add_child(UiFactory.make_section_header(tr("FIN_BURN_SECTION")))
	_burn_list = VBoxContainer.new()
	_burn_list.add_theme_constant_override("separation", 6)
	vb.add_child(_burn_list)
	return _card(vb)


func _build_transactions_card() -> PanelContainer:
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 8)
	vb.add_child(UiFactory.make_section_header(tr("FIN_RECENT_TX")))
	_tx_list = VBoxContainer.new()
	_tx_list.add_theme_constant_override("separation", 4)
	vb.add_child(_tx_list)
	return _card(vb)


func _build_captable_card() -> PanelContainer:
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 8)
	var head := HBoxContainer.new()
	vb.add_child(head)
	var h := UiFactory.make_section_header(tr("FIN_CAPTABLE_HEADER"))
	h.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(h)
	_cap_raised = UiFactory.make_label("", &"RowMeta", UiTokens.INK_MUTED)
	head.add_child(_cap_raised)

	# Çubuk: iki ColorRect, stretch_ratio doğrudan yüzde tam sayıları — hiçbir yerde
	# bölme yok (yatırım öncesi 100/0 güvenli). Yatırımcı dilimi 0 iken gizli.
	var bar := HBoxContainer.new()
	bar.add_theme_constant_override("separation", 0)
	bar.custom_minimum_size = Vector2(0, 8)
	vb.add_child(bar)
	_cap_founder_rect = ColorRect.new()
	_cap_founder_rect.color = UiTokens.INK
	_cap_founder_rect.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bar.add_child(_cap_founder_rect)
	_cap_investor_rect = ColorRect.new()
	_cap_investor_rect.color = UiTokens.ACCENT
	_cap_investor_rect.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bar.add_child(_cap_investor_rect)
	# Çalışan dilimi (ODA rework — RightPanel cap-table göçü): BG_AVATAR token
	# yorumu zaten "avatar disc + cap-table bar" diyor. Hisse 0 iken gizli.
	_cap_employee_rect = ColorRect.new()
	_cap_employee_rect.color = UiTokens.BG_AVATAR
	_cap_employee_rect.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bar.add_child(_cap_employee_rect)

	_cap_rows = UiFactory.make_label("", &"RowMeta", UiTokens.INK_MUTED)
	vb.add_child(_cap_rows)
	_cap_equity_note = UiFactory.make_label("", &"CaptionMuted")
	_cap_equity_note.visible = false
	vb.add_child(_cap_equity_note)
	# Opsiyon havuzu: motorda alan YOK (gelecek alan adayı: GameState.run_option_pool_pct).
	# Satır, state gelmeden asla kurulmaz — mockup'taki %10 icat edilmiş bir rakamdı.
	return _card(vb)


func _build_mentor_card() -> PanelContainer:
	# KREM ton (yönetmen kararı): düz CardPanel — koyu Dialogue register DEĞİL,
	# CardAttention DEĞİL. Yalnız runway eşiğin altındayken görünür.
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 8)
	vb.add_child(UiFactory.make_section_header(tr("FIN_MENTOR_WARNING")))
	var quote := UiFactory.make_label(
		tr("FIN_MENTOR_QUOTE_WRAPPED").format({"quote": tr("FIN_MENTOR_QUOTE")}), &"QuoteSerif")
	quote.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vb.add_child(quote)
	var row := HBoxContainer.new()
	vb.add_child(row)
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(spacer)
	var btn := Button.new()
	btn.text = Fmt.upper(tr("FIN_SNOOZE"))
	btn.focus_mode = Control.FOCUS_NONE
	btn.pressed.connect(_on_snooze_pressed)
	row.add_child(btn)
	return _card(vb)


# --- Tazeleme ----------------------------------------------------------------

func refresh() -> void:
	if _nakit_val == null:
		return
	_refresh_header()
	_refresh_appetite()
	_refresh_curve()
	_refresh_flow()
	_refresh_burn()
	_refresh_transactions()
	_refresh_captable()
	_refresh_mentor()


func _refresh_header() -> void:
	_nakit_val.text = UiTokens.format_money_exact(GameState.cash)
	var flow: Dictionary = FinanceSystem.get_monthly_flow()
	var net: int = int(flow.net)
	var sign_str: String = "+" if net > 0 else ""
	_net_val.text = "%s%s" % [sign_str, UiTokens.format_money(net)]
	_net_val.add_theme_color_override("font_color",
			UiTokens.positive() if net > 0 else (UiTokens.negative() if net < 0 else UiTokens.INK))

	var months: float = GameState.get_runway_months()
	var p: Dictionary = UiTokens.net_runway_parts(months)
	if bool(p.get("positive", false)):
		# ARTIDA sözleşmesi: asla sonsuz ya da uydurma sayı yazılmaz — durum etiketi
		# yeşil, gerekçe alt satırda (tek ev UiTokens.net_runway_parts).
		_runway_val.text = UiTokens.tr_upper(String(p.value))
		_runway_val.add_theme_color_override("font_color", UiTokens.positive())
		_runway_note.text = String(p.get("note", ""))
		_runway_note.visible = _runway_note.text != ""
	else:
		_runway_val.text = "%s %s" % [p.value, p.unit]
		# Negatif kasa da KIRMIZI. `months` bu durumda INF olabiliyor (get_runway_months
		# yalnız günlük nete bakar, kasanın işaretine bakmaz), o yüzden tek başına eşik
		# karşılaştırması ödemesi geciken bir şirketi varsayılan mürekkeple basıyordu.
		_runway_val.add_theme_color_override("font_color",
				UiTokens.negative() if (months < RUNWAY_WARN_MONTHS or GameState.cash < 0) else UiTokens.INK)
		_runway_note.visible = false


func _refresh_curve() -> void:
	var cfg: Dictionary = RANGES[_range]
	var window: int = int(cfg.window)
	var history: Array = GameState.get_cash_history()
	var samples: Array = history
	if window > 0:
		var cutoff: int = GameState.day - window
		samples = history.filter(func(s): return int(s.day) >= cutoff)
	if samples.is_empty() and not history.is_empty():
		samples = [history[history.size() - 1]]  # pencere boş kalmasın — en taze örnek
	var horizon: int = int(cfg.horizon)
	var current_net: int = GameState.get_net_daily_flow()
	var day_min: int = int(samples[0].day) if not samples.is_empty() else GameState.day
	_curve.set_data({
		"samples": samples,
		"today_day": GameState.day,
		"cash_now": GameState.cash,
		"current_net": current_net,
		"optimistic_net": FinanceSystem.get_optimistic_daily_net(),
		"horizon_days": horizon,
		"ticks": _month_ticks(day_min, GameState.day + horizon),
	})
	# ARTIDA kuralı: kasa erimiyorken kırmızı erime projeksiyonu ne çizilir ne listelenir.
	_legend_current.visible = current_net < 0
	for id in _range_btns:
		(_range_btns[id] as Button).modulate = Color(1, 1, 1, 1) if id == _range else Color(1, 1, 1, 0.6)


func _month_ticks(day_min: int, day_max: int) -> Array:
	# Ay başlangıçları GERÇEK takvimden (GameState.get_date_dict — 28/30/31 günlü aylar),
	# asla ekonomi sabiti DAYS_PER_MONTH'tan değil. Etiket: Fmt.month_abbr (yerele göre).
	var ticks: Array = []
	for d in range(maxi(day_min, 1), day_max + 1):
		var date: Dictionary = GameState.get_date_dict(d)
		if int(date.day) == 1:
			ticks.append({"day": d,
					"label": Fmt.month_abbr(int(date.month))})
	return ticks


func _on_range_pressed(id: String) -> void:
	_range = id
	_refresh_curve()


func _refresh_flow() -> void:
	var flow: Dictionary = FinanceSystem.get_monthly_flow()
	var biggest: int = maxi(1, maxi(absi(int(flow.income)),
			maxi(absi(int(flow.expense)), absi(int(flow.net)))))
	_set_flow_row("income", int(flow.income), biggest, UiTokens.positive(), "+")
	_set_flow_row("expense", int(flow.expense), biggest, UiTokens.negative(), "-")
	var net: int = int(flow.net)
	_set_flow_row("net", net, biggest,
			UiTokens.positive() if net >= 0 else UiTokens.negative(),
			"+" if net > 0 else ("-" if net < 0 else ""))


func _set_flow_row(key: String, amount: int, biggest: int, color: Color, sign_str: String) -> void:
	var refs: Dictionary = _flow_refs[key]
	var bar: ProgressBar = refs.bar
	bar.min_value = 0.0
	bar.max_value = float(biggest)
	bar.value = float(absi(amount))
	_override_bar_fill(bar, color)
	var v: Label = refs.val
	# Gider satırı işareti etikette: motor pozitif büyüklük döndürür, yön burada biçimleme.
	v.text = "%s%s" % [sign_str, UiTokens.format_money(absi(amount))]
	v.add_theme_color_override("font_color", color)


func _override_bar_fill(bar: ProgressBar, c: Color) -> void:
	# BuildProgress amber dolgusu → satır rengi (hr_ui_shared.override_bar_fill reçetesi;
	# varyasyon atandıktan SONRA çağrılmalı).
	var fill: StyleBox = bar.get_theme_stylebox("fill")
	if fill is StyleBoxFlat:
		var f: StyleBoxFlat = (fill as StyleBoxFlat).duplicate()
		f.bg_color = c
		bar.add_theme_stylebox_override("fill", f)


func _refresh_burn() -> void:
	for c in _burn_list.get_children():
		_burn_list.remove_child(c)
		c.queue_free()
	var rows: Array = FinanceSystem.get_burn_breakdown_pct()
	for row_data in rows:
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 8)
		var l := UiFactory.make_label(String(row_data.label), &"RowMeta", UiTokens.INK_MUTED)
		l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(l)
		var bar := ProgressBar.new()
		bar.theme_type_variation = &"BuildProgress"
		bar.show_percentage = false
		bar.custom_minimum_size = Vector2(120, 6)
		bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		bar.min_value = 0.0
		bar.max_value = 100.0
		bar.value = float(row_data.pct)
		_override_bar_fill(bar, UiTokens.INK)
		row.add_child(bar)
		var v := UiFactory.make_label(Fmt.percent(int(row_data.pct), 0), &"RowMeta", UiTokens.INK)
		v.custom_minimum_size = Vector2(36, 0)
		v.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		row.add_child(v)
		row.tooltip_text = tr("FIN_PER_DAY").format(
			{"amount": UiTokens.format_money(int(row_data.amount))})
		_burn_list.add_child(row)


func _refresh_transactions() -> void:
	for c in _tx_list.get_children():
		_tx_list.remove_child(c)
		c.queue_free()
	var txs: Array = FinanceSystem.get_transactions()
	if txs.is_empty():
		_tx_list.add_child(UiFactory.make_label(tr("FIN_NO_TX"), &"CaptionMuted", UiTokens.INK_DIM))
		return
	var start: int = maxi(0, txs.size() - TX_SHOWN)
	for i in range(txs.size() - 1, start - 1, -1):  # en yeni üstte
		var t: Dictionary = txs[i]
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 12)
		var date: Dictionary = GameState.get_date_dict(int(t.day))
		var d := UiFactory.make_label(tr("FIN_TX_DATE").format({
					"day": int(date.day), "month": Fmt.month_abbr(int(date.month))}),
				&"FeedDay", UiTokens.INK_DIM)
		d.custom_minimum_size = Vector2(52, 0)
		row.add_child(d)
		var l := UiFactory.make_label(
				FinanceSystem.one_time_label_display(String(t.label)), &"RowMeta", UiTokens.INK)
		l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(l)
		var amount: int = int(t.amount)
		var v := UiFactory.make_label(
				"%s%s" % ["+" if amount > 0 else "", UiTokens.format_money_exact(amount)],
				&"RowMeta", UiTokens.positive() if amount > 0 else UiTokens.negative())
		row.add_child(v)
		_tx_list.add_child(row)


func _refresh_captable() -> void:
	# Mevcut state'ten: kurucu = 100 − imzalanan dilüsyon − çalışan hisseleri.
	# (ODA rework 2026-08-06: RightPanel'in çalışan-hisse yarısı buraya taşındı,
	# iki yarım görünüm birleşti.) Opsiyon havuzu alanı motorda hâlâ yok.
	# Yatırımcı dilimi TÜM turların toplamıdır (melek + imzalanan Series A) ve toplamı
	# GameState türetir — çağrı yerinde ham alanlar toplanmaz, yoksa bir sonraki tur
	# eklendiğinde bu satır sessizce eksik kalır.
	var investors: int = GameState.get_investor_equity_pct()
	var employee_frac: float = 0.0
	var employees_with_equity: int = 0
	for emp in CharacterRegistry.get_employees():
		if emp.equity_pct > 0.0:
			employees_with_equity += 1
			employee_frac += emp.equity_pct
	# equity_pct kurucu sözleşmesiyle aynı 0..1 kesir (get_founder_equity emsali);
	# emniyet kelepçesi yatırımcı payını asla taşırmaz.
	var employees: int = mini(int(round(employee_frac * 100.0)), maxi(0, 100 - investors))
	var founder: int = maxi(0, 100 - investors - employees)
	_cap_founder_rect.size_flags_stretch_ratio = float(maxi(founder, 0))
	_cap_investor_rect.size_flags_stretch_ratio = float(maxi(investors, 0))
	_cap_investor_rect.visible = investors > 0
	_cap_employee_rect.size_flags_stretch_ratio = float(maxi(employees, 0))
	_cap_employee_rect.visible = employees > 0
	var parts: Array = [tr("FIN_CAPTABLE_FOUNDER").format({"pct": Fmt.percent(founder, 0)})]
	# Melek turu KENDİ satırını alır: tek "Yatırımcılar" kalemi, bir kurucunun cap
	# table'da ayırt ettiği iki farklı şeyi (melek çeki ve imzalanan tur) tek sayıya
	# katlıyordu. Dilimler yine tek ColorRect — ayrılan okuma, çizim değil.
	if GameState.run_angel_equity_pct > 0:
		parts.append(tr("ANGEL_CAP_ROW").format({"pct": GameState.run_angel_equity_pct}))
	if GameState.run_equity_pct > 0:
		parts.append(tr("FIN_CAPTABLE_INVESTORS").format(
			{"pct": Fmt.percent(GameState.run_equity_pct, 0)}))
	if employees > 0:
		parts.append(tr("FIN_CAPTABLE_EMPLOYEES").format({"pct": Fmt.percent(employees, 0)}))
	_cap_rows.text = " · ".join(parts)
	var raised: int = GameState.get_total_raised()
	_cap_raised.text = tr("FIN_CAPTABLE_RAISED").format(
		{"amount": UiTokens.format_money(raised)}) if raised > 0 else ""
	_cap_equity_note.visible = employees_with_equity > 0
	if employees_with_equity > 0:
		_cap_equity_note.text = tr("FIN_CAPTABLE_EQUITY_NOTE").format({"n": employees_with_equity})


func _refresh_mentor() -> void:
	var months: float = GameState.get_runway_months()
	var snoozed: bool = GameState.day < int(GameState.get_flag(SNOOZE_FLAG, 0))
	_mentor_card.visible = months != INF and months < RUNWAY_WARN_MONTHS and not snoozed


func _on_snooze_pressed() -> void:
	# sales_tab "next_find_prospects_day" deseni: mutlak hedef gün state'e, karşılaştırma
	# okurken. Süre dolduktan sonra eşik hâlâ aşılıyorsa kart kendiliğinden geri gelir
	# (günlük cash_changed repaint'i _refresh_mentor'u yeniden değerlendirir).
	GameState.set_flag(SNOOZE_FLAG, GameState.day + WARN_SNOOZE_DAYS)
	refresh()
