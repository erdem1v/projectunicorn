extends Control

# ============================================================================
# SATIŞ SAYFASI (GDD SATIŞ rev 6 — §3.1 guard · §4 boru hattı · §7.2/§7.2.2 masa · §7.5 kadran)
#
# Kod-kurulu düzen, boş .tscn kökü (Ürün ve Ar-Ge sekmelerinin idiomu). Sayfa HUMBLE'dır:
# kayıtları ve okuma yüzeyini okur, seam'leri TETİKLER, ve HİÇBİR state yazmaz (WRITE-THROUGH
# LAW). Tek istisna oyuncunun kendi ayarlarıdır ve onlar da sahiplerinin setter'larından geçer
# (SalesLedger; hesap sahibi seçimi için CustomerRegistry.assign_customer).
#
# PROCESS_MODE_ALWAYS ZORUNLU (.tscn'de): Godot duraklatılmış düğümleri ÇİZMEYE devam eder ama
# `gui_input` DAĞITMAZ — hız 0'da her kart görünür, her tıklama yutulurdu.
#
# GÜN SINIRI: `EventBus.day_advanced`e ASLA bağlanmaz. O sinyal `GameState.advance_day()`
# İÇİNDE, TimeManager günlük tick'leri dağıtmadan ÖNCE atılıyor; oraya bağlanan bir görünüm
# DÜNKÜ durumu okur. Kanca `day_tick_completed`, yani günün SON satırı.
#
# DİL VE PALET: `language_changed`/`palette_changed`e BAĞLANMAZ — router sayfayı her mount'ta
# serbest bırakıp yeniden kuruyor ve dil/palet yenilemesini kendi kendini iyileştiren şey
# tam olarak bu.
#
# İKİ SÜTUN: solda BORU HATTI + SATIŞ MASASI, sağda HESAP DEFTERİ (§19'un "Korunanlar"ı).
# ============================================================================

const PAGE_MARGIN := 16
const COL_SEPARATION := 24
const LOG_ROWS := 5
# Hesap defterinde önce dikkat isteyen kartlar.
const ATTENTION_RANK := {"risk": 2, "expansion": 1}

var _signals: Array = []
var _strip: HBoxContainer = null
var _pipeline_col: VBoxContainer = null
var _portfolio_col: VBoxContainer = null


func _ready() -> void:
	_build_chrome()
	# Her satırın ne gösterdiğini değiştirebilecek her seam. Havuz sinyalleri rev 6'nın
	# kendi sözlüğünden geliyor (§14); hesap sinyalleri korunan katmandan.
	_signals = [
		EventBus.prospect_added, EventBus.prospect_removed,
		EventBus.prospect_arrived, EventBus.lead_expired,
		EventBus.lead_reserved, EventBus.lead_routed,
		EventBus.price_stance_changed, EventBus.rep_band_cap_changed,
		EventBus.rep_deal_closed, EventBus.deal_signed, EventBus.deal_walked,
		EventBus.customer_added, EventBus.customer_removed,
		EventBus.customer_health_changed, EventBus.customer_churned,
		EventBus.customer_expanded, EventBus.customer_assigned,
		EventBus.customer_satisfaction_changed, EventBus.customer_seats_changed,
		EventBus.mrr_changed, EventBus.day_tick_completed, EventBus.pitch_finished,
		EventBus.assignment_changed,
	]
	for sig in _signals:
		sig.connect(_on_state_changed)
	_refresh()


func _exit_tree() -> void:
	for sig in _signals:
		if sig.is_connected(_on_state_changed):
			sig.disconnect(_on_state_changed)


# Sinyaller 0/1/2/3 argümanlı; tek işleyiciye bağlanabilsinler diye hepsi opsiyonel.
func _on_state_changed(_a = null, _b = null, _c = null) -> void:
	_refresh()


# ============================================================================
#  Sayfa kromu
# ============================================================================

func _build_chrome() -> void:
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, PAGE_MARGIN)
	add_child(margin)

	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", UiTokens.SPACE_L)
	margin.add_child(root)

	_strip = HBoxContainer.new()
	_strip.add_theme_constant_override("separation", UiTokens.SPACE_XL)
	root.add_child(_strip)
	root.add_child(HRUiShared.hairline(UiTokens.SEPARATOR))

	var cols := HBoxContainer.new()
	cols.size_flags_vertical = Control.SIZE_EXPAND_FILL
	cols.add_theme_constant_override("separation", COL_SEPARATION)
	root.add_child(cols)

	_pipeline_col = _scroll_column(cols)
	_portfolio_col = _scroll_column(cols)


func _scroll_column(parent: HBoxContainer) -> VBoxContainer:
	var scroll := ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	parent.add_child(scroll)
	var col := VBoxContainer.new()
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col.add_theme_constant_override("separation", UiTokens.SPACE_M)
	scroll.add_child(col)
	return col


func _refresh() -> void:
	var custs: Array[Customer] = CustomerRegistry.get_by_market("b2b")
	_refresh_strip(custs)
	_refresh_pipeline()
	_refresh_portfolio(custs)


# ============================================================================
#  Şerit — dört ölçü; fiyat kadranı (§7.5) burada kurulur, boru hattı sütununun başına oturur
# ============================================================================

func _refresh_strip(custs: Array[Customer]) -> void:
	for ch in _strip.get_children():
		ch.queue_free()
	var avg: int = 0
	if not custs.is_empty():
		var total: int = 0
		for c in custs:
			total += c.satisfaction
		avg = int(round(float(total) / float(custs.size())))
	var ledger: Dictionary = GameState.month_ledger
	var gained: int = GameState.run_customers_signed - int(ledger.get("customers_signed", 0))
	var net: int = gained - (GameState.run_customers_lost - int(ledger.get("customers_lost", 0)))
	_add_cell(tr("SALES_STRIP_CUSTOMERS"), str(custs.size()))
	_add_cell(tr("SALES_STRIP_SATISFACTION"), Fmt.percent(avg, 0))
	_add_cell(tr("SALES_STRIP_GAINED"), "+%d" % gained, UiTokens.delta_color(gained))
	_add_cell(tr("SALES_STRIP_NET"), ("+%d" % net) if net > 0 else str(net), UiTokens.delta_color(net))
	# THE DIAL IS NOT IN THIS STRIP, and the reason is measured rather than aesthetic: the
	# Build HUD panel floats over the viewport's top-right corner, so a fifth cell out there
	# is a control sitting under an overlay. It lives at the head of the pipeline column
	# instead — which also reads better, because the price policy is the first thing about
	# the pipeline it prices.


func _add_cell(caption: String, value: String, color: Variant = null) -> void:
	var col := VBoxContainer.new()
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col.add_theme_constant_override("separation", 2)
	col.add_child(UiFactory.make_label(caption, &"MetricCaptionInk"))
	col.add_child(UiFactory.make_label(value, &"MetricValueInk", color))
	_strip.add_child(col)


## §7.5 — FİYAT KADRANI. B2B fiyatının TEK kaynağı (§15): kurucunun masasında Perde 2'nin
## açılış çapası, temsilcinin masasında kapanış fiyatı. Üç kademe, her zaman üçü de görünür —
## seçili olan vurgulu, kilitli kademe yok.
func _stance_dial() -> Control:
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", UiTokens.SPACE_XXS)
	col.add_child(UiFactory.make_label(tr("SALES_STANCE_CAPTION"), &"MetricCaptionInk"))
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", UiTokens.SPACE_XS)
	var current: String = SalesLedger.price_stance()
	# THE SELECTED POSITION HAS TO BE UNMISTAKABLE. `ChromeTabButtonActive` and `ChromeTabButton`
	# differ by a shade in the terminal palette — enough for a tab rail where the page underneath
	# tells you where you are, not for a three-position dial that is the SINGLE source of every
	# B2B price. A code-side `StyleBoxFlat` (the one-off-shape hatch RnDUiShared's header names)
	# rather than a new theme item, so `THEME_STAMP` does not move for one dial: the active
	# position takes the amber-keyed fill AND an accent edge, the others stay flat with a
	# disabled edge.
	for stance in SalesConstants.STANCES:
		var id: String = String(stance)
		var active: bool = id == current
		var btn := _button(tr("SALES_STANCE_" + id.to_upper()),
			&"ChromeTabButtonActive" if active else &"ChromeTabButton",
			func() -> void: SalesLedger.set_price_stance(id))
		btn.tooltip_text = tr("SALES_STANCE_HINT_" + id.to_upper())
		btn.add_theme_color_override("font_color",
			UiTokens.ACCENT if active else UiTokens.INK_DIM)
		var sb := StyleBoxFlat.new()
		sb.set_corner_radius_all(UiTokens.RADIUS_S)
		sb.content_margin_left = UiTokens.SPACE_M
		sb.content_margin_right = UiTokens.SPACE_M
		sb.content_margin_top = UiTokens.SPACE_XS
		sb.content_margin_bottom = UiTokens.SPACE_XS
		sb.bg_color = UiTokens.AMBER_BG if active else UiTokens.SURFACE_INPUT
		sb.set_border_width_all(UiTokens.BORDER_HAIRLINE)
		sb.border_color = UiTokens.ACCENT if active else UiTokens.BORDER_DISABLED
		for state in ["normal", "hover", "pressed"]:
			btn.add_theme_stylebox_override(state, sb)
		row.add_child(btn)
	col.add_child(row)
	return UiFactory.make_card(col, true)


# ============================================================================
#  Sol sütun — boru hattı (§4) ve satış masası (§7)
# ============================================================================

func _refresh_pipeline() -> void:
	for ch in _pipeline_col.get_children():
		ch.queue_free()

	# §3.1 PAZAR GUARD'I. B2C koşuda musluk akmaz ve boru hattı BOŞ HÂL gösterir — nedeniyle.
	# Gizlenen bir sütun oyuncuya "böyle bir şey yok" der, kilitli-görünür olan "henüz yok,
	# sebebi bu" der.
	if not SalesFaucetSystem.market_open():
		_pipeline_col.add_child(UiFactory.make_section_header(tr("SALES_PIPELINE_HEADER")))
		_pipeline_col.add_child(UiFactory.make_label(tr("SALES_LOCKED_NO_B2B"),
			&"LockedTelegraph", UiTokens.INK_DIM))
		return

	var leads: Array[Prospect] = ProspectRegistry.get_all()
	leads.sort_custom(func(a: Prospect, b: Prospect) -> bool:
		if a.star != b.star:
			return a.star > b.star
		return a.expires_on_day < b.expires_on_day)

	_pipeline_col.add_child(_stance_dial())
	# §3 — akış oyuncuya GÖRÜNÜR bir sayıdır. Temsilci almak bu sayıyı büyütür; işe alım
	# kararının karşılığı budur ve bir hesap tablosunda değil burada okunur.
	_pipeline_col.add_child(_column_head(tr("SALES_PIPELINE_HEADER"), tr("SALES_FLOW_RATE").format(
		{"n": Fmt.number(SalesFaucetSystem.lead_rate_per_day() * SalesConstants.DAYS_PER_WEEK, 1)})))

	if leads.is_empty():
		_pipeline_col.add_child(UiFactory.make_label(tr("SALES_PROSPECTS_EMPTY"),
			&"EmptyRowLabel", UiTokens.INK_DIM))
	for lead in leads:
		_pipeline_col.add_child(_lead_card(lead))

	_pipeline_col.add_child(_desk_block())
	_pipeline_col.add_child(_activity_block())


## §4 — LEAD KARTI: şirket adı · yıldız satırı · arketip tek satır · kalan süre · varsa
## yönlendirme işareti. Artı §4'ün telgrafı ve §8'in şartı.
func _lead_card(p: Prospect) -> Control:
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", UiTokens.SPACE_XS)

	var top := HBoxContainer.new()
	top.add_theme_constant_override("separation", UiTokens.SPACE_S)
	var name_lbl := UiFactory.make_label(p.company_name, &"RowName")
	name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(name_lbl)
	if p.routing == SalesConstants.ROUTE_RESERVED:
		top.add_child(UiFactory.make_badge(tr("SALES_ROUTE_RESERVED"), "neutral"))
	elif p.routing == SalesConstants.ROUTE_REP:
		top.add_child(UiFactory.make_badge(tr("SALES_ROUTE_REP"), "accent"))
	col.add_child(top)

	# Ekip §4.1 grameri: satır HER ZAMAN beş yıldız çizer, sönük yıldızlar ölçek telgrafının
	# kendisidir (§2: kilitli 4★ kartı YOKTUR, sönük yıldız zaten o işi yapıyor).
	var star_row := HBoxContainer.new()
	star_row.add_theme_constant_override("separation", UiTokens.SPACE_S)
	star_row.add_child(StarRating.make_stars(float(p.star), 13))
	var days := UiFactory.make_label(tr("SALES_DAYS_LEFT").format({"n": p.days_left()}),
		&"RowMeta", UiTokens.negative() if p.days_left() <= 2 else UiTokens.INK_DIM)
	days.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	days.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	star_row.add_child(days)
	col.add_child(star_row)

	col.add_child(UiFactory.make_label(SalesArchetypes.voice_line(p.archetype_id),
		&"RowMeta", UiTokens.INK_MUTED))

	# §8 — şart masaya OTURMADAN telgraflanır. Balina kartı ne istediğini söylemeden gelmez.
	if p.whale_condition != "":
		col.add_child(UiFactory.make_label(tr("SALES_WHALE_" + p.whale_condition.to_upper()),
			&"DialogueTag", UiTokens.ACCENT))

	# §4 — "Bu masa liginin üstünde." Kilit DEĞİL, telgraf: kurucu her masaya oturabilir.
	var founder_star: int = int(HRConstants.stars_for(
		GameState.get_founder_skill(HRConstants.AREA_SALES)))
	if p.is_above_league(founder_star):
		col.add_child(UiFactory.make_label(tr("SALES_ABOVE_LEAGUE"), &"RowMeta", UiTokens.ACCENT_DIM))

	# §7.2 — işlenen lead kimin masasında ve kaçıncı gün.
	if p.is_being_worked():
		var rep: Character = CharacterRegistry.get_character(p.worked_by)
		if rep != null:
			col.add_child(UiFactory.make_label(tr("SALES_REP_WORKING").format({
				"company": rep.character_name + " · " + p.company_name,
				"n": GameState.day - p.work_started_day + 1}), &"RowMeta", UiTokens.INK_DIM))

	col.add_child(_lead_actions(p))
	return UiFactory.make_card(col)


func _lead_actions(p: Prospect) -> Control:
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_END
	row.add_theme_constant_override("separation", UiTokens.SPACE_XS)

	# §7.2.1'in iki fiili. "Ayır" masayı kurucuya saklar (temsilci atlar), "Temsilciye ver"
	# bandındaysa öne alır. İkisi de aynı satırda çünkü ikisi de aynı soruya cevap: bu masaya
	# kim oturuyor.
	row.add_child(_button(tr("SALES_ROUTE_RESERVE"), &"DialogueGhost", func() -> void:
		SalesLedger.set_routing(p.id, SalesConstants.ROUTE_RESERVED
			if p.routing != SalesConstants.ROUTE_RESERVED else SalesConstants.ROUTE_NONE)))
	row.add_child(_button(tr("SALES_ROUTE_GIVE"), &"DialogueGhost", func() -> void:
		SalesLedger.set_routing(p.id, SalesConstants.ROUTE_REP
			if p.routing != SalesConstants.ROUTE_REP else SalesConstants.ROUTE_NONE)))

	# §5.0 — giriş kapısı NEDENLİDİR. Kapalıysa buton kilitli-görünür ve hover sebebi yazar;
	# gizlenmez, çünkü gizlenen bir kapı oyuncuya neyi beklediğini söylemez.
	var block: String = SalesLedger.meeting_block_reason(p.id)
	var meet := _button(tr("SALES_ACTION_MEET"), &"CommitButton")
	if block == "":
		meet.pressed.connect(func() -> void: EventBus.pitch_requested.emit(p.id))
	else:
		meet.disabled = true
		meet.tooltip_text = tr(block)
	row.add_child(meet)
	return row


## SON HAREKETLER — the pipeline's memory. §4's honest drop line ("Beklemekten vazgeçti.")
## has nowhere else to land: the card leaves with the lead, and a loss the player never sees
## is an untelegraphed loss. The rep's own closes share the surface, which is also what makes
## the weekly summary a SUMMARY rather than the only place a close is ever reported.
func _activity_block() -> Control:
	var entries: Array = SalesSystem.get_sales_log()
	if entries.is_empty():
		return Control.new()
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", UiTokens.SPACE_XXS)
	col.add_child(UiFactory.make_section_header(tr("SALES_LOG_HEADER")))
	var shown: int = 0
	for i in range(entries.size() - 1, -1, -1):
		var line: String = _log_line(entries[i])
		if line == "":
			continue
		col.add_child(UiFactory.make_label(line, &"RowMeta", UiTokens.INK_DIM))
		shown += 1
		if shown == LOG_ROWS:
			break
	return UiFactory.make_card(col, true)


## The log stores INTERNAL ids and never a sentence, so the mapping to copy lives here.
func _log_line(row: Dictionary) -> String:
	var company: String = String(row.get("company", ""))
	match String(row.get("kind", "")):
		"lead_expired":
			return tr("SALES_LOG_EXPIRED").format({"company": company})
		"auto_close":
			return tr("SALES_LOG_CLOSE").format({
				"actor": String(row.get("actor", "")), "company": company,
				"amount": Fmt.money(int(row.get("mrr", 0)))})
		"founder_close":
			return tr("SALES_LOG_FOUNDER_CLOSE").format({
				"company": company,
				"amount": Fmt.money(int(row.get("mrr", 0)))})
		"cs_absorb":
			return tr("SALES_LOG_ABSORB").format({
				"actor": String(row.get("actor", "")), "company": company})
	return ""


## §7.2 / §7.2.2 — SATIŞ MASASI. Her temsilci için: ad, yıldız satırı, çalıştığı bant, ve
## varsa şu an kimle görüştüğü.
func _desk_block() -> Control:
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", UiTokens.SPACE_S)
	col.add_child(UiFactory.make_section_header(tr("SALES_DESK_HEADER")))
	var reps: Array[Character] = HRSystem.assigned_to(HRConstants.AREA_SALES)
	if reps.is_empty():
		col.add_child(UiFactory.make_label(tr("SALES_DESK_EMPTY"), &"EmptyRowLabel", UiTokens.INK_DIM))
	for r in reps:
		col.add_child(_rep_row(r))
	return UiFactory.make_card(col, true)


func _rep_row(rep: Character) -> Control:
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", UiTokens.SPACE_XXS)
	col.add_child(_name_row(rep.character_name,
		HRConstants.stars_for(HRSystem.skill(rep, HRConstants.AREA_SALES))))
	col.add_child(_band_cap_row(rep))

	# §7.2 — "Palmiye ile görüşüyor · 3. gün".
	var work: Dictionary = SalesRepSystem.processing_view(rep)
	if not work.is_empty():
		col.add_child(UiFactory.make_label(tr("SALES_REP_WORKING").format({
			"company": String(work.get("company_name", "")),
			"n": int(work.get("day", 1))}), &"RowMeta", UiTokens.INK_MUTED))
	return col


## §7.2.2 BAND GÖSTERİMİ, MÜHÜRLÜ. Tam yıldız kademeleri + en sağda "Kendi ligi"
## (varsayılan). 1★ TEMSİLCİDE SEÇİCİ ÇİZİLMEZ, düz bilgi satırı olur — tek kademelik bir
## seçici sahte seçim görüntüsüdür ve oyuncuya olmayan bir karar sunar.
func _band_cap_row(rep: Character) -> Control:
	var options: Array = SalesRepSystem.band_cap_options(rep)
	if options.is_empty():
		return UiFactory.make_label(tr("SALES_BAND_OWN_ONLY"), &"RowMeta", UiTokens.INK_DIM)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", UiTokens.SPACE_XS)
	row.add_child(UiFactory.make_label(tr("SALES_BAND_CAPTION"), &"RowMeta", UiTokens.INK_DIM))
	var current: int = SalesLedger.rep_band_cap(rep.id)
	for opt in options:
		var cap: int = int(opt)
		var text: String = tr("SALES_BAND_OWN") if cap == SalesConstants.BAND_CAP_OWN_LEAGUE \
			else tr("SALES_BAND_STAR").format({"n": cap})
		# §7.2.2 — "Ayar anında işler; süren işleme bitirilir."
		row.add_child(_button(text, &"ChromeTabButtonActive" if cap == current else &"ChromeTabButton",
			func() -> void: SalesLedger.set_rep_band_cap(rep.id, cap)))
	return row


# ============================================================================
#  Sağ sütun — hesap defteri (§19 "Korunanlar")
# ============================================================================

func _refresh_portfolio(custs: Array[Customer]) -> void:
	for ch in _portfolio_col.get_children():
		ch.queue_free()
	_portfolio_col.add_child(_column_head(tr("SALES_PORTFOLIO_HEADER"),
		tr("SALES_CUSTOMERS_COUNT").format({"n": custs.size()})))

	if custs.is_empty():
		_portfolio_col.add_child(UiFactory.make_label(tr("SALES_CUSTOMERS_EMPTY"),
			&"EmptyRowLabel", UiTokens.INK_DIM))
		return
	custs.sort_custom(func(a: Customer, b: Customer) -> bool:
		return int(ATTENTION_RANK.get(a.lifecycle_phase, 0)) > int(ATTENTION_RANK.get(b.lifecycle_phase, 0)))
	var direct: int = B2BSalesSystem.founder_managed_count()
	if direct > CustomerRepSystem.founder_account_capacity():
		_portfolio_col.add_child(UiFactory.make_label(
			tr("SALES_FOUNDER_STRETCHED").format({"n": direct}), &"RowMeta", UiTokens.INK_DIM))
	for c in custs:
		_portfolio_col.add_child(_build_customer_card(c))


func _build_customer_card(c: Customer) -> Control:
	match c.lifecycle_phase:
		"risk": return _card_risk(c)
		"expansion": return _card_expansion(c)
		_: return _card_calm(c)


func _card_calm(c: Customer) -> Control:
	var is_new: bool = c.lifecycle_phase == "onboarding"
	var col := _card_head(c, UiTokens.INK_MUTED if c.assigned_to != "" else UiTokens.INK,
		tr("SALES_CHIP_NEW") if is_new else tr("SALES_CHIP_HEALTHY"),
		&"neutral" if is_new else &"positive")
	_add_steward_line(col, c)
	_add_promise_line(col, c)
	return UiFactory.make_card(col)


func _card_risk(c: Customer) -> Control:
	var col := _card_head(c, UiTokens.INK, tr("SALES_CHIP_RISK"), &"negative")
	var reason: String = tr("SALES_REASON_OUTAGE") \
		if ProductSystem.live_bug_count() > B2BConstants.COMPLAINT_BUG_GATE \
		else tr("SALES_REASON_SATISFACTION")
	col.add_child(UiFactory.make_label(
		tr("SALES_REASON_PREFIX").format({"reason": reason}), &"QuoteSerif"))
	if c.churn_countdown >= 0:
		col.add_child(UiFactory.make_label(
			tr("SALES_CHURN_COUNTDOWN").format({"n": c.churn_countdown}),
			&"RowMeta", UiTokens.negative()))
	_add_steward_line(col, c)
	_add_promise_line(col, c)
	# PROPOSER, not a second admission path (I1): the tab NAMES the card and the gate runs
	# G1-G8 over it. §19 keeps the retention grammar intact.
	col.add_child(_action_button(tr("SALES_ACTION_RETAIN") + " →", func() -> void:
		EventGate.request("customer.retention", {"customer": c.id})))
	return UiFactory.make_card(col, false, true)


func _card_expansion(c: Customer) -> Control:
	var col := _card_head(c, UiTokens.INK, tr("SALES_CHIP_EXPANSION"), &"accent")
	col.add_child(UiFactory.make_label(tr("SALES_EXPANSION_FICTION"), &"QuoteSerif"))
	_add_steward_line(col, c)
	_add_promise_line(col, c)
	col.add_child(_action_button(tr("SALES_ACTION_EXPAND") + " →", func() -> void:
		EventGate.request("customer.expansion", {"customer": c.id})))
	return UiFactory.make_card(col)


## §2 — hesap kartı da yıldız satırı taşır: aynı ölçek, aynı gramer, aynı beş glif. Lead
## kartından müşteri kartına geçerken oyuncunun okuduğu şey değişmez. Altında durum çipi ve
## meta satırı. UiFactory çipi kurar, sayfa yalnız yerleştirir (UI/STYLE LAW 4).
func _card_head(c: Customer, ink: Color, chip_text: String, chip_kind: StringName) -> VBoxContainer:
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", UiTokens.SPACE_XXS)
	col.add_child(_name_row(c.display_name(), float(c.scale), ink))
	var chip := UiFactory.make_badge(chip_text, chip_kind)
	chip.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	col.add_child(chip)
	col.add_child(UiFactory.make_label(_meta_line(c), &"RowMeta", UiTokens.INK_MUTED))
	return col


## AÇIK SÖZ HESABIN KENDİ KARTINDA GÖRÜNÜR. Ürün sayfası bütün açık sözleri bir arada listeler;
## hesabın kartı ise sözün verildiği ve kırıldığında bedelini ödeyecek yerdir. Tek satır: ne söz
## verildi ve kaç gün kaldı.
func _add_promise_line(col: VBoxContainer, c: Customer) -> void:
	var open: Array[Promise] = PromiseRegistry.get_open_for(c.id)
	if open.is_empty():
		return
	var p: Promise = open[0]
	col.add_child(UiFactory.make_label(tr("SALES_PROMISE_OPEN").format({
		"feature": B2BConstants.feature_label(p.feature_id),
		"days": maxi(0, p.deadline_day - GameState.day),
	}), &"RowMeta", UiTokens.ACCENT_DEEP))


func _add_steward_line(col: VBoxContainer, c: Customer) -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", UiTokens.SPACE_S)
	var who: String = "—"
	if c.assigned_to != "":
		var cs: Character = CharacterRegistry.get_character(c.assigned_to)
		if cs != null:
			who = cs.character_name
	row.add_child(UiFactory.make_label(tr("SALES_STEWARD").format({"name": who}),
		&"RowMeta", UiTokens.INK_DIM))
	row.add_child(RnDUiShared.spacer())
	var btn := _button(tr("SALES_STEWARD_CHANGE"), &"DialogueGhost")
	btn.pressed.connect(func() -> void: _open_steward_picker(c, btn))
	row.add_child(btn)
	col.add_child(row)


func _open_steward_picker(c: Customer, anchor: Button) -> void:
	# HRPopover mounts into GameShell/PanelLayer, so it escapes CenterViewport's
	# clip_contents — a raw popup parented into this tab would be clipped. PanelLayer rather
	# than ModalLayer is what keeps Space/1-3 alive while it is open.
	var pop: HRPopover = HRPopover.mount(self)
	if pop == null:
		return
	var body: VBoxContainer = pop.body()
	body.add_child(UiFactory.make_section_header(tr("SALES_STEWARD_PICK")))
	for rep in CharacterRegistry.get_active_by_role(HRConstants.ROLE_CUSTOMER_REP):
		body.add_child(_steward_option(pop, c, rep.id, rep.character_name,
			CustomerRepSystem.roster_size(rep.id), CustomerRepSystem.capacity_of(rep)))
	body.add_child(HRUiShared.hairline())
	# KURUCU DA BİR SEÇENEKTİR VE AYNI SATIRI OKUR — özel kural yok: aynı formül, aynı biçim,
	# aynı kapı (tavanda o da seçilemez ve gerekçesini söyler). Kapasitesi kendi MÜŞTERİ
	# İLİŞKİLERİ yıldızından çıkıyor (`founder_account_capacity`), yükü doğrudan taşıdığı hesaplar.
	body.add_child(_steward_option(pop, c, "", tr("SALES_STEWARD_FOUNDER"),
		B2BSalesSystem.founder_managed_count(), CustomerRepSystem.founder_account_capacity()))
	pop.open_at(anchor)


## One steward row: "ad · yük/kapasite". `steward_id` "" is the founder (Customer.assigned_to).
func _steward_option(pop: HRPopover, c: Customer, steward_id: String, steward_name: String,
		used: int, cap: int) -> Button:
	var label: String = "%s  ·  %d/%d" % [steward_name, used, cap]
	if steward_id == c.assigned_to:
		return HRUiShared.disabled_button(label, tr("SALES_STEWARD_CURRENT"))
	if used >= cap:
		return HRUiShared.disabled_button(label, tr("SALES_STEWARD_FULL"))
	return HRUiShared.action_button(label, func() -> void:
		# pinned=true even for the founder: otherwise _delegate_excess hands it straight
		# back tomorrow morning and the player's choice silently evaporates.
		CustomerRegistry.assign_customer(c.id, steward_id, true)
		pop.close())


func _meta_line(c: Customer) -> String:
	var months: int = (GameState.day - c.acquired_on_day) / GameState.DAYS_PER_MONTH
	var parts: Array[String] = [
		Fmt.money(c.mrr) + tr("SALES_PER_MONTH"),
		tr("SALES_SEATS").format({"n": c.seats}),
		tr("SALES_TENURE_NEW") if months < 1 else tr("SALES_TENURE").format({"n": months}),
	]
	# §5.4 — the account's OWN seat price, and the discount trace beside it when there is one.
	# It is here rather than hidden because expansion charges this number: the player must be
	# able to see what they agreed to before they grow it.
	if c.seat_price > 0:
		parts.append(tr("SALES_SEAT_PRICE").format({"price": Fmt.money_exact(c.seat_price)}))
	if c.signing_discount > 0.0:
		parts.append(tr("SALES_SIGNING_DISCOUNT").format(
			{"pct": int(round(c.signing_discount * 100.0))}))
	return " · ".join(parts)


# ============================================================================
#  Küçük yapı taşları
# ============================================================================

## Sütun başı: bölüm başlığı solda, tek satırlık ölçü sağda.
func _column_head(title: String, meta: String) -> HBoxContainer:
	var head := HBoxContainer.new()
	head.add_theme_constant_override("separation", UiTokens.SPACE_M)
	head.add_child(UiFactory.make_section_header(title))
	head.add_child(RnDUiShared.spacer())
	head.add_child(UiFactory.make_label(meta, &"RowMeta", UiTokens.INK_DIM))
	return head


## Ad solda, yıldız satırı sağda: temsilci satırı ve hesap kartı aynı grameri okur.
func _name_row(text: String, stars: float, ink: Variant = null) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", UiTokens.SPACE_S)
	var name_lbl := UiFactory.make_label(text, &"RowName", ink)
	name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(name_lbl)
	row.add_child(StarRating.make_stars(stars, 12))
	return row


func _button(text: String, variation: StringName, on_press: Callable = Callable()) -> Button:
	var b := Button.new()
	b.text = text
	b.theme_type_variation = variation
	b.focus_mode = Control.FOCUS_NONE
	if on_press.is_valid():
		b.pressed.connect(on_press)
	return b


func _action_button(label: String, on_press: Callable) -> Button:
	var btn := _button(label, &"CommitButton", on_press)
	btn.size_flags_horizontal = Control.SIZE_SHRINK_END
	return btn
