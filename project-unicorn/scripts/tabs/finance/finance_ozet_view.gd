class_name FinanceOzetView
extends Control

# ============================================================================
# Finans penceresinin Özet sayfası, üç sütun: kasa eğrisi, son işlemler ve hisse dağılımı; faz hedefi ile
# yatırımcı iştahı, aylık akış ve gider dağılımı; Frank'in notu ve pazar payı. Sağ sütunda tek kart kalınca
# hisse dağılımı onun altına geçer. Sayfa içeriği kadar uzar (`content`), pencereye sığmazsa kayar.
#
# Bu dosya hiçbir sonucu HESAPLAMAZ: her rakam bir motor seam'inden gelir (FinanceSystem.get_monthly_flow /
# get_burn_breakdown_pct / get_transactions / get_optimistic_daily_net, GameState.get_cash_history,
# UiTokens.net_runway_parts, RivalRegistry.get_market_snapshot, PhaseGateSystem.series_a_signal). Tek istisna
# BİÇİMLEMEdir (tarih etiketi, çubuk oranları).
#
# Gider dağılımı yalnız gerçek kalemlerden; Series A çıtasının rakamı basılmaz, sinyali iştah etiketidir.
# Repaint modeli: FinanceSystem.daily_tick / apply_one_time_cost, ring buffer + transactions ledger'larını
# cash_changed'den ÖNCE yazar; cash_changed repaint'i taze veri okur.
# ============================================================================

const RUNWAY_WARN_MONTHS := 6.0   # WORKING: mentor uyarısı eşiği (ay)
const WARN_SNOOZE_WEEKS := 2      # WORKING: ERTELE süresi
const SNOOZE_FLAG := "finance_runway_warn_snooze_until_day"
const TX_SHOWN := 8               # WORKING: Son işlemler'de gösterilen satır sayısı

# Aralık düğmeleri (bu sırayla): id -> {window: pencere hafta sayısı (0 = tümü), horizon:
# projeksiyon haftası}. WORKING: horizon ≈ pencere/3; TÜMÜ için 9.
const RANGES := {
	"6ay": {"label_key": "FIN_RANGE_6M", "window": 26, "horizon": 9},
	"12ay": {"label_key": "FIN_RANGE_12M", "window": 52, "horizon": 17},
	"tum": {"label_key": "FIN_RANGE_ALL", "window": 0, "horizon": 9},
}
## The appetite's state → its tag (InvestorAppetiteUi words it).
const APPETITE_TAGS := {"closed": &"outline", "warming": &"warn", "open": &"pos"}

## The three columns; the window reads their height.
var content: HBoxContainer
var _cols: Array[VBoxContainer] = []
var _range: String = "6ay"
var _notes: VBoxContainer
var _range_slot: HBoxContainer
var _curve: CashCurve
var _legend: HFlowContainer
var _tx: VBoxContainer
var _cap_card: PanelContainer
var _cap: VBoxContainer
var _goal: VBoxContainer
var _flow: VBoxContainer
var _burn: VBoxContainer
var _mentor_card: PanelContainer
var _mentor_quote: Label            # rewritten per band (Frank v6, surface 20)
var _snooze: Button
var _league_card: PanelContainer
var _league: VBoxContainer

var _signals: Array = []


func _ready() -> void:
	_build()
	_signals = [
		[EventBus.cash_changed, _on_state_changed],
		[EventBus.mrr_changed, _on_state_changed],
		[EventBus.burn_changed, _on_state_changed],
		# Cap table: nakit taşımayan bir hisse hareketi cash_changed yaymaz.
		[EventBus.equity_changed, _on_state_changed],
		# Yatırımcı iştahı: büyüme serisi ay kapanışında değişir, kapı
		# ayrıca mandallanır ve faz ilerler — üçü de MRR'siz boya gerektirir.
		[EventBus.month_ended, _on_state_changed],
		[EventBus.phase_gate_reached, _on_state_changed],
		[EventBus.phase_changed, _on_state_changed],
		# Faz hedefi ve pazar payı: sürüm, hesap, teklif ve rakip hareketleri.
		[EventBus.version_shipped, _on_state_changed],
		[EventBus.customer_added, _on_state_changed],
		[EventBus.customer_removed, _on_state_changed],
		[EventBus.sheet_granted, _on_state_changed],
		[EventBus.sheet_expired, _on_state_changed],
		[EventBus.sheet_walked, _on_state_changed],
		[EventBus.rival_advanced, _on_state_changed],
		[EventBus.rival_status_changed, _on_state_changed],
		[EventBus.shutter_changed, _on_state_changed],
		# Karar beklerken denetimler kapalı.
		[EventBus.event_triggered, _on_state_changed],
		[EventBus.event_resolved, _on_state_changed],
		[EventBus.event_set_aside, _on_state_changed],
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
	content = SprintUiShared.box(UiTokens.SPACE_XL)
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(content)
	var widths := UiTokens.D_FINANCE_COLUMNS
	for w in [widths.x, widths.y, widths.z]:
		var col := SprintUiShared.column(UiTokens.SPACE_XL)
		col.custom_minimum_size.x = w
		content.add_child(col)
		_cols.append(col)
	# The last column takes what the scrollbar leaves.
	_cols[2].size_flags_horizontal = Control.SIZE_EXPAND_FILL

	_build_curve_card()
	# Each card's parts, head first, are painted into its column.
	_tx = UiFactory.D_card(_cols[0])
	_goal = UiFactory.D_card(_cols[1])
	_flow = UiFactory.D_card(_cols[1])
	_burn = UiFactory.D_card(_cols[1])
	_build_mentor_card()
	_league = UiFactory.D_card(_cols[2])
	_league_card = _league.get_parent()
	_cap = UiFactory.D_card(_cols[0])
	_cap_card = _cap.get_parent()


func _build_curve_card() -> void:
	var body := UiFactory.D_card(_cols[0])
	body.add_theme_constant_override("separation", UiTokens.SPACE_M)
	var head := SprintUiShared.box(UiTokens.SPACE_XL)
	body.add_child(head)
	# Why the runway reads no months, and how far the profitability streak has come.
	_notes = SprintUiShared.column(UiTokens.SPACE_XS)
	_notes.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(_notes)
	_range_slot = SprintUiShared.box(0)
	_range_slot.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	head.add_child(_range_slot)
	_curve = CashCurve.new()
	_curve.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_child(_curve)
	_legend = HFlowContainer.new()
	_legend.add_theme_constant_override("h_separation", UiTokens.SPACE_XXL)
	_legend.add_theme_constant_override("v_separation", UiTokens.SPACE_XS)
	body.add_child(_legend)


## Frank's note: his disc, name and title, then his line on the band the runway is in, and the snooze. The card's
## look is the band's (_refresh_mentor).
func _build_mentor_card() -> void:
	var body := UiFactory.D_card(_cols[2])
	_mentor_card = body.get_parent()
	body.add_child(UiFactory.D_card_head(tr("FIN_MENTOR_WARNING")))
	var who := SprintUiShared.box(UiTokens.SPACE_L)
	who.add_child(UiFactory.make_mentor_avatar(UiTokens.D_AVATAR_NOTE))
	var names := SprintUiShared.column(0)
	names.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	names.add_child(UiFactory.make_label(tr("MENTOR_NAME"), &"DataStrong"))
	names.add_child(UiFactory.make_label(tr("HR_ROLE_MENTOR"), &"Caption"))
	who.add_child(names)
	body.add_child(who)
	_mentor_quote = UiFactory.make_label("", &"FrankQuote", UiTokens.D_INK_1)
	_mentor_quote.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.add_child(_mentor_quote)
	_snooze = SprintUiShared.button(tr("FIN_SNOOZE"), &"GhostButtonSmall", _on_snooze_pressed)
	_snooze.size_flags_horizontal = Control.SIZE_SHRINK_END
	body.add_child(_snooze)


# --- Tazeleme ----------------------------------------------------------------

func refresh() -> void:
	_refresh_curve()
	_refresh_transactions()
	_refresh_goal()
	_refresh_flow()
	_refresh_burn()
	_refresh_mentor()
	_refresh_league()
	_refresh_captable()
	# With one card left on the right, the cap table moves under it.
	var right_cards: int = int(_mentor_card.visible) + int(_league_card.visible)
	var home: VBoxContainer = _cols[2] if right_cards < 2 else _cols[0]
	if _cap_card.get_parent() != home:
		_cap_card.reparent(home, false)
	home.move_child(_cap_card, -1)


func _refresh_curve() -> void:
	UiFactory.clear(_notes)
	var p: Dictionary = UiTokens.net_runway_parts(GameState.get_runway_months())
	if p.note != "":
		_notes.add_child(SprintUiShared.prose(p.note, &"Caption"))
	_add_profit_progress()
	UiFactory.clear(_range_slot)
	var ids: Array = RANGES.keys()
	_range_slot.add_child(UiFactory.D_seg_pick(ids.map(func(id: String) -> Dictionary:
		return {"text": tr(RANGES[id].label_key)}), ids.find(_range), func(i: int) -> void:
			_range = ids[i]
			_refresh_curve(), EventGate.active_id() != "", true))

	var cfg: Dictionary = RANGES[_range]
	var history: Array = GameState.get_cash_history()
	var horizon: int = TimeModel.ticks(int(cfg.horizon))
	# The plot follows the range: back from today by its window (the run's first sample for TÜMÜ).
	var day_min: int = GameState.day - TimeModel.ticks(int(cfg.window)) if int(cfg.window) > 0 \
		else int(history[0].day)
	var day_max: int = GameState.day + horizon
	_curve.set_data({
		"samples": history.filter(func(s: Dictionary) -> bool: return int(s.day) >= day_min),
		"day_min": day_min,
		"today_day": GameState.day,
		"cash_now": GameState.cash,
		# Eğri tik ekseninde: eğimler günlük netin tik başına karşılığı.
		"current_net": int(TimeModel.per_tick(GameState.get_net_daily_flow())),
		"optimistic_net": int(TimeModel.per_tick(FinanceSystem.get_optimistic_daily_net())),
		"horizon": horizon,
		"ticks": _month_ticks(day_min, day_max),
	})
	UiFactory.clear(_legend)
	for row in [["actual", "FIN_LEGEND_ACTUAL", true], ["current", "FIN_LEGEND_PROJECTION", _curve.shows.current],
			["target", "FIN_LEGEND_PROJECTION_TARGET", _curve.shows.target],
			["below", "FIN_LEGEND_BELOW_ZERO", _curve.shows.below]]:
		if row[2]:
			var item := SprintUiShared.box(UiTokens.SPACE_S)
			item.add_child(CashCurve.legend_sample(row[0]))
			item.add_child(SprintUiShared.label(tr(row[1]), &"Caption"))
			_legend.add_child(item)


## Kârlılık bitişi her tik değerlendirilen bir KOŞUL (PROFIT_STREAK_MONTHS ardışık artıda ay kapanışı + marj +
## ölçek); ilerlemesi burada okunur: en az bir artıda ay kapanmışsa görünür, marj ya da ölçek eksikse nedenini
## tek kelimeyle söyler.
func _add_profit_progress() -> void:
	var sig: Dictionary = EndingsSystem.profitability_signal()
	var streak: int = int(sig.get("streak", 0))
	var need: int = int(sig.get("need", 1))
	if streak <= 0:
		return
	var txt: String = tr("FIN_PROFIT_PROGRESS").format({"streak": mini(streak, need), "need": need})
	if streak >= need:
		if not bool(sig.get("margin_ok", false)):
			txt += " · " + tr("FIN_PROFIT_QUAL_MARGIN")
		elif not bool(sig.get("mrr_ok", false)):
			txt += " · " + tr("FIN_PROFIT_QUAL_SCALE")
	var line := SprintUiShared.label(txt, &"Caption")
	line.tooltip_text = tr("FIN_PROFIT_NOTE").format({"need": EndingsSystem.PROFIT_STREAK_MONTHS})
	line.mouse_filter = Control.MOUSE_FILTER_PASS
	_notes.add_child(line)


func _month_ticks(day_min: int, day_max: int) -> Array:
	# Ay başlangıçları GERÇEK takvimden: bir tik Perşembesinin ayına aittir ve ayı, ayı bir
	# önceki tikinkinden farklı olan tik açar (GameState.get_date_dict), asla ekonomi sabiti
	# DAYS_PER_MONTH değil. Koşudan önceki tikler de takvimdedir. Etiket: Fmt.month_abbr (yerele göre).
	var ticks: Array = []
	var prev_month: int = int(GameState.get_date_dict(day_min).month)
	for d in range(day_min + 1, day_max + 1):
		var month: int = int(GameState.get_date_dict(d).month)
		if month != prev_month:
			ticks.append({"day": d, "label": Fmt.month_abbr(month)})
		prev_month = month
	return ticks


func _refresh_transactions() -> void:
	UiFactory.clear(_tx)
	_tx.add_child(UiFactory.D_card_head(tr("FIN_RECENT_TX")))
	var txs: Array = FinanceSystem.get_transactions()
	if txs.is_empty():
		_tx.add_child(SprintUiShared.empty_line(tr("FIN_NO_TX"), "res://assets/icons/util/doc.svg", 0))
		return
	var rows := SprintUiShared.column(0)
	_tx.add_child(rows)
	for i in range(txs.size() - 1, maxi(0, txs.size() - TX_SHOWN) - 1, -1):  # en yeni üstte
		var t: Dictionary = txs[i]
		var row := PanelContainer.new()
		row.theme_type_variation = &"TableRow"
		row.custom_minimum_size.y = UiTokens.D_H_ROW_SM
		var line := SprintUiShared.box(UiTokens.SPACE_L)
		row.add_child(line)
		var date: Dictionary = GameState.get_date_dict(int(t.day))
		var when := SprintUiShared.label(tr("FIN_TX_DATE").format({"week": int(date.week),
			"mon": Fmt.month_abbr(int(date.month)), "year": int(date.year)}), &"Caption")
		when.custom_minimum_size.x = UiTokens.D_W_TX_DATE
		line.add_child(when)
		var what := SprintUiShared.label(FinanceSystem.one_time_label_display(String(t.label)), &"DataText")
		what.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		line.add_child(what)
		var amount: int = int(t.amount)
		# Bir gider bedeldir (mürekkep, bedel glifi), bir gelir artıdır.
		line.add_child(SprintUiShared.label("+" + Fmt.money_exact(amount), &"DataMedium", UiTokens.D_pos())
			if amount > 0 else UiFactory.D_cost(Fmt.money_exact(amount), &"DataMedium"))
		rows.add_child(row)


## Faz hedefi: başlık fazın hedefi, satır ne gerektiği; ilk fazda üç koşulun ilerlemesi. Altında hedefin
## göstergesi, yatırımcı iştahı (rakamsız: kapı yalnız MRR, çıtası basılmaz). İkinci fazda kart yalnız başlığı
## taşır, iştah onun hemen altındadır.
func _refresh_goal() -> void:
	UiFactory.clear(_goal)
	var head := SprintUiShared.box(UiTokens.SPACE_M)
	_goal.add_child(head)
	var value := ""
	var title := ""
	var met: int = -1
	match GameState.phase:
		1:
			title = "FIN_GOAL_P1_LABEL"
			value = tr("FIN_GOAL_P1_META")
			met = int(ProductState.is_live()) + int(not CustomerRegistry.get_all().is_empty()) + int(GameState.mrr > 0)
		2:
			title = "FIN_GOAL_P2_LABEL"
		_:
			if GameState.series_a_closed:
				title = "FIN_GOAL_P3_CLOSED"
				value = Fmt.money(GameState.run_investment_amount)
			else:
				var n: int = GameState.active_sheets.size()
				title = "FIN_GOAL_P3_LABEL"
				value = tr(Fmt.count_key("FIN_GOAL_P3_HUNT", n)).format({"n": n})
	# Fazın adı yazıldığı gibi; anahtarın sonundaki iki nokta başlıkta kesilir.
	head.add_child(SprintUiShared.label(tr(title).trim_suffix(":"), &"CardTitle"))
	if met >= 0:
		head.add_child(RnDUiShared.spacer())
		head.add_child(SprintUiShared.label(tr("FIN_GOAL_PROGRESS").format({"met": met, "total": 3}), &"DataStrong"))
	if value != "":
		_goal.add_child(SprintUiShared.prose(value, &"BodyLabel"))
	if met >= 0:
		_goal.add_child(HRUiShared.D_bar(Vector2(0, UiTokens.D_H_PROGRESS), met / 3.0,
			UiTokens.D_BAR_EMPH if met == 3 else UiTokens.D_BAR_FILL))
	if GameState.phase != 2:
		_goal.add_child(HSeparator.new())
	var sig: Dictionary = PhaseGateSystem.series_a_signal()
	var state: String = String(sig.get("state", "closed"))
	var appetite := SprintUiShared.box(UiTokens.SPACE_M)
	appetite.add_child(SprintUiShared.label(Fmt.upper(InvestorAppetiteUi.title_text()), &"KeyLabel"))
	appetite.add_child(UiFactory.D_tag(InvestorAppetiteUi.state_text(state), APPETITE_TAGS.get(state, &"outline")))
	appetite.tooltip_text = _series_a_tooltip()
	appetite.mouse_filter = Control.MOUSE_FILTER_PASS
	_goal.add_child(appetite)
	_goal.add_child(SprintUiShared.prose(InvestorAppetiteUi.line(sig), &"Caption"))


func _series_a_tooltip() -> String:
	# Kapının KOŞULLARINI GATES tablosundan adlandırır — rakamsız (yönetmen kararı: seam adı
	# eşleşir, değeri değil). Tabloya yeni bir yaprak eklenirse burada adı yoksa sessizce
	# atlanır — bu bilinçli: bilinmeyen bir koşulu rakamıyla basmaktansa hiç basmamak.
	var reqs: Array = []
	for gate in PhaseGateSystem.GATES:
		if int(gate["from"]) != 2:
			continue
		for cond in gate["conditions"]:
			if String(cond.get("seam", "")) == "finance.mrr":
				reqs.append(tr("FIN_REQ_MRR_BAR"))
	return tr("FIN_REQ_OPENS").format({"reqs": " · ".join(reqs)})


## Aylık akış, mevcut gidişle: get_monthly_flow() ay başından bugüne DEĞİL, bugünkü hızın 30 güne uzatılmışıdır
## ve başlık bunu söyler. Gelir artıdır; gider ve kasa artıdayken eksi net bedeldir (mürekkep, bedel glifi),
## tehlike yalnız kasa eksideyken.
func _refresh_flow() -> void:
	UiFactory.clear(_flow)
	_flow.add_child(UiFactory.D_card_head(tr("FIN_MONTHLY_FLOW"), null,
		UiFactory.make_label(tr("FIN_MONTHLY_FLOW_PACE"), &"Caption")))
	var flow: Dictionary = FinanceSystem.get_monthly_flow()
	var net: int = int(flow.net)
	var income: int = int(flow.income)
	var biggest: float = max(1, income, int(flow.expense), absi(net))
	var grid := _share_grid(3)
	_flow.add_child(grid)
	for row in [["FIN_INCOME", income, UiTokens.D_pos() if income > 0 else null], ["FIN_EXPENSE", -int(flow.expense), null],
			["FIN_NET", net, UiTokens.D_net_ink(net)]]:
		var amount: int = row[1]
		grid.add_child(SprintUiShared.label(tr(row[0]), &"MetaText"))
		grid.add_child(_share(absi(amount) / biggest, UiTokens.D_BAR_FILL if row[2] == null else row[2]))
		var shown: String = Fmt.money(amount) if amount <= 0 else "+" + Fmt.money(amount)
		var value: Control = UiFactory.D_cost(shown, &"KeyText") if amount < 0 and row[2] == null \
			else SprintUiShared.label(shown, &"KeyText", row[2])
		value.size_flags_horizontal = Control.SIZE_SHRINK_END
		grid.add_child(value)


## Gider dağılımı: aylık toplamı başlıkta; bir parça-bütün çubuğu, altında her kalemin çubuğu, aylık tutarı ve
## payı. En büyük kalem vurgulu.
func _refresh_burn() -> void:
	UiFactory.clear(_burn)
	var rows: Array = FinanceSystem.get_burn_breakdown_pct()
	_burn.add_child(UiFactory.D_card_head(tr("FIN_BURN_SECTION"), UiFactory.make_label(tr("FIN_PER_MONTH").format(
		{"amount": Fmt.money(int(FinanceSystem.get_monthly_flow().expense))}), &"Caption")))
	if rows.is_empty():
		return
	var top: float = float(rows[0].pct)
	_burn.add_child(_stack(rows.map(func(r: Dictionary) -> Array:
		return [float(r.pct), UiTokens.D_BAR_EMPH if r.pct == top else UiTokens.D_BAR_FILL])))
	var grid := _share_grid(4)
	_burn.add_child(grid)
	for r in rows:
		grid.add_child(SprintUiShared.label(String(r.label), &"MetaText"))
		grid.add_child(_share(float(r.pct) / 100.0, UiTokens.D_BAR_EMPH if r.pct == top else UiTokens.D_BAR_FILL))
		# Kalemler günlük orandır; tutar üst barla aynı aylık hız.
		for cell in [[Fmt.money(int(r.amount) * TimeModel.DAYS_PER_MONTH), &"MetaMuted"],
				[Fmt.percent(int(r.pct), 0), &"KeyText"]]:
			var figure := SprintUiShared.label(cell[0], cell[1])
			figure.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
			grid.add_child(figure)


## Rows of shares: a label, a bar that takes the rest of the row, then the figures.
func _share_grid(columns: int) -> GridContainer:
	var grid := GridContainer.new()
	grid.columns = columns
	grid.add_theme_constant_override("h_separation", UiTokens.SPACE_L)
	grid.add_theme_constant_override("v_separation", UiTokens.SPACE_M)
	return grid


## A part-to-whole bar: one segment a part, [share, ink]; a part with no ink is room left empty.
func _stack(parts: Array) -> HBoxContainer:
	var bar := SprintUiShared.box(UiTokens.SPACE_XXS)
	bar.custom_minimum_size.y = UiTokens.D_H_SHARE
	bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	for part in parts:
		if part[0] <= 0.0:
			continue
		var segment: Control = Panel.new() if part[1] != null else Control.new()
		if part[1] != null:
			segment.theme_type_variation = &"BarTint"
			segment.self_modulate = part[1]
		segment.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		segment.size_flags_stretch_ratio = part[0]
		bar.add_child(segment)
	return bar


## A share's bar: its fill to `ratio` of the row, no track under it.
func _share(ratio: float, ink: Color) -> HBoxContainer:
	return _stack([[ratio, ink], [1.0 - ratio, null]])


func _refresh_captable() -> void:
	# Kurucu = 100 − yatırımcı payı. Yatırımcı dilimi TÜM turların toplamıdır (melek + seed +
	# imzalanan Series A) ve toplamı GameState türetir — çağrı yerinde ham alanlar toplanmaz,
	# yoksa bir sonraki tur eklendiğinde bu satır sessizce eksik kalır.
	# Çalışan hissesinin motorda kaynağı yok ve bu bilerek böyle: Ekip GDD §9'da (maaş, zam,
	# terfi) çalışan hissesi yok, opsiyon havuzu kurulmadı. Havuz gelirse dilimi buraya eklenir.
	UiFactory.clear(_cap)
	var raised: int = GameState.get_total_raised()
	_cap.add_child(UiFactory.D_card_head(tr("FIN_CAPTABLE_HEADER"), UiFactory.make_label(tr("FIN_CAPTABLE_RAISED").format(
		{"amount": Fmt.money(raised)}), &"Caption") if raised > 0 else null))
	var investors: int = GameState.get_investor_equity_pct()
	var founder: int = maxi(0, 100 - investors)
	_cap.add_child(_stack([[float(founder), UiTokens.D_BAR_EMPH], [float(investors), UiTokens.D_BAR_FILL]]))
	var parts := SprintUiShared.box(UiTokens.SPACE_XL)
	parts.add_child(SprintUiShared.label(tr("FIN_CAPTABLE_FOUNDER").format({"pct": Fmt.percent(founder, 0)}), &"MetaText"))
	# Melek turu KENDİ satırını alır: kurucu melek çekini ve imzalanan turu ayrı okur; seed de kendi turu,
	# yoksa kurucunun payı ekranda karşılığı olmadan on iki ile on sekiz puan düşerdi.
	if GameState.run_angel_equity_pct > 0:
		parts.add_child(SprintUiShared.label(tr("ANGEL_CAP_ROW").format({"pct": GameState.run_angel_equity_pct}), &"MetaText"))
	if GameState.run_seed_equity_pct > 0:
		parts.add_child(SprintUiShared.label(tr("SEED_CAP_ROW").format({"pct": GameState.run_seed_equity_pct}), &"MetaText"))
	if GameState.run_equity_pct > 0:
		parts.add_child(SprintUiShared.label(tr("FIN_CAPTABLE_INVESTORS").format(
			{"pct": Fmt.percent(GameState.run_equity_pct, 0)}), &"MetaText"))
	_cap.add_child(parts)


func _refresh_mentor() -> void:
	var months: float = GameState.get_runway_months()
	var snoozed: bool = GameState.day < int(GameState.get_flag(SNOOZE_FLAG, 0))
	# The shutter band is its own visibility case: once the counter runs there is no runway
	# left to be "under" the threshold, so a months < RUNWAY_WARN_MONTHS test alone
	# would hide the warning exactly when it matters most.
	var shuttered: bool = GameState.shutter_weeks_left >= 0
	_mentor_card.visible = not snoozed and (shuttered or months < RUNWAY_WARN_MONTHS)
	if not _mentor_card.visible:
		return
	_mentor_card.theme_type_variation = UiTokens.D_variation(&"FrankNoteRisk") if shuttered else &"FrankNote"
	_snooze.disabled = EventGate.active_id() != ""
	# The threshold reaches the copy only through {months} (FIN_MENTOR_QUOTE), so moving
	# RUNWAY_WARN_MONTHS cannot make the line disagree with the gate.
	var body: String = tr("FIN_MENTOR_QUOTE_SHUTTER") if shuttered \
			else tr("FIN_MENTOR_QUOTE").format({"months": int(RUNWAY_WARN_MONTHS)})
	_mentor_quote.text = tr("FIN_MENTOR_QUOTE_WRAPPED").format({"quote": body})


func _on_snooze_pressed() -> void:
	# Mutlak hedef tik state'e yazılır, karşılaştırma okurken yapılır. Süre dolduktan sonra
	# eşik hâlâ aşılıyorsa kart kendiliğinden geri gelir (her tikin cash_changed repaint'i
	# _refresh_mentor'u yeniden değerlendirir).
	GameState.set_flag(SNOOZE_FLAG, GameState.day + TimeModel.ticks(WARN_SNOOZE_WEEKS))
	refresh()


## Pazar payı merdiveni; ürün piyasada değilse kart çizilmez. Durumsuz: pay MRR'dan ve katalog tohumlarından türer.
func _refresh_league() -> void:
	var snap: Dictionary = RivalRegistry.get_market_snapshot(ProductState.subtype()) \
		if ProductState.is_live() else {"rivals": []}
	var rivals: Array = snap["rivals"]
	_league_card.visible = not rivals.is_empty()
	if rivals.is_empty():
		return
	UiFactory.clear(_league)
	var player_pct: float = float(snap["player_pct"])
	_league.add_child(UiFactory.D_card_head(tr("FIN_MARKET_TITLE"),
		UiFactory.make_label(RivalRegistry.format_share(player_pct), &"DataStrong") if GameState.mrr > 0 else null))
	# Çıktı ama MRR yok: tablo yerine tek yönlendirme satırı.
	if GameState.mrr <= 0:
		_league.add_child(SprintUiShared.prose(tr("FIN_MARKET_EMPTY"), &"FrankQuote"))
		return
	# Gerçek pay tablosu: ilk üç + oyuncunun HEMEN üstündeki rakip (tekrarsız) + SEN. Satır
	# numarası GERÇEK pazar sırasıdır; sıra atlaması aradaki mesafeyi kesik çizgiyle söyler.
	var player_name: String = ProductState.product_name()
	if player_name == "":
		player_name = GameState.company_name
	var above_count: int = 0
	var nearest_above: Dictionary = {}
	for row in rivals:
		if float(row["share_pct"]) > player_pct:
			above_count += 1
			nearest_above = row
	var picks: Array = rivals.slice(0, 3)
	if not nearest_above.is_empty() and not picks.has(nearest_above):
		picks.append(nearest_above)
	var entries: Array = []
	for pick in picks:
		entries.append({"rank": rivals.find(pick) + 1 + (1 if player_pct > float(pick["share_pct"]) else 0),
			"name": String(pick["name"]), "share": float(pick["share_pct"]), "trend": int(pick["trend"]),
			"is_player": false})
	entries.append({"rank": above_count + 1, "name": player_name, "share": player_pct, "trend": 0, "is_player": true})
	entries.sort_custom(func(a, b): return float(a["share"]) > float(b["share"]))
	var ladder := SprintUiShared.column(0)
	_league.add_child(ladder)
	var last_rank: int = 0
	for e in entries:
		if int(e.rank) > last_rank + 1 and last_rank > 0:
			ladder.add_child(_ladder_gap())
		last_rank = int(e.rank)
		ladder.add_child(_ladder_row(str(e.rank), e.name, e.is_player, int(e.trend), RivalRegistry.format_share(e.share)))
	# "Diğerleri" kuyruğu SIRASIZ: merdivene girseydi oyuncunun kıymığının üstüne basamak olur,
	# sıra atlamasının anlattığı mesafeyi bozardı. Baştaki "…" listenin bitmediğini söyler.
	var others: float = float(snap["others_pct"])
	if others >= 0.1:
		ladder.add_child(_ladder_row("…", tr("FIN_MARKET_OTHERS"), false, 0, RivalRegistry.format_share(others), true))


## A ladder row: rank, name (the player's stressed and tagged), the rival's trend, its share.
func _ladder_row(rank: String, display: String, is_player: bool, trend: int, share: String, rest := false) -> MarginContainer:
	var row := SprintUiShared.box(UiTokens.SPACE_M)
	row.custom_minimum_size.y = UiTokens.D_H_SHARE_ROW
	var no := SprintUiShared.label(rank, &"Caption" if is_player else &"CaptionFaint")
	no.custom_minimum_size.x = UiTokens.D_W_RANK
	no.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	row.add_child(no)
	var label := SprintUiShared.label(display, &"MetaStrong" if is_player else (&"MetaMuted" if rest else &"MetaText"))
	row.add_child(label)
	if is_player:
		row.add_child(UiFactory.D_tag(tr("FIN_MARKET_YOU"), &"neutral"))
		row.add_child(RnDUiShared.spacer())
	else:
		# A rival's long name gives way before its share does.
		label.clip_text = true
		label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var arrow: Control = UiFactory.make_glyph("res://assets/icons/util/tri_%s.svg" % ("up" if trend > 0 else "down"),
		UiTokens.D_ICON_TAG, UiTokens.D_INK_3) if trend != 0 else Control.new()
	arrow.custom_minimum_size.x = UiTokens.D_ICON_TAG
	row.add_child(arrow)
	var value := SprintUiShared.label(share, &"MetaStrong" if is_player else (&"MetaMuted" if rest else &"KeyText"))
	value.custom_minimum_size.x = UiTokens.D_W_SHARE
	value.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	row.add_child(value)
	return SprintUiShared.pad(row, Vector4i(UiTokens.SPACE_M, 0, UiTokens.SPACE_M, 0))


## The ladder's jump in rank: a dashed rule from the names on.
func _ladder_gap() -> MarginContainer:
	var rule := Control.new()
	rule.custom_minimum_size.y = UiTokens.BORDER_HAIRLINE
	HRUiShared.D_dashed(rule)
	return SprintUiShared.pad(rule, Vector4i(UiTokens.SPACE_M + UiTokens.D_W_RANK + UiTokens.SPACE_M, UiTokens.SPACE_XS,
		UiTokens.SPACE_M, UiTokens.SPACE_XS))
