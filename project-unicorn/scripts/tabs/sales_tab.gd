extends Control

# ============================================================================
# Satış penceresi (GDD Satış rev 6: §3.1 pazar, §4 boru hattı, §7.2 masa, §7.5 fiyat duruşu, §19 portföy).
# Koyu başlıkta Satış ve dört ölçü, denetim şeridinde fiyat duruşu. Gövdede solda boru hattı, satış masası ve
# son hareketler, sağda müşteri portföyü; iki sütun da kendi içinde kayar, pencere içeriği kadar uzar
# (fit_height). Canlı B2B ürün yokken gövde tek boş hâldir.
#
# Sayfa durumu okur ve sahiplerinin seam'lerini tetikler, kendisi yazmaz (WRITE-THROUGH LAW). Karar beklerken
# denetimleri kapalıdır. PROCESS_MODE_ALWAYS (.tscn): duraklatılmış düğüm çizilir ama tıklama almaz.
#
# GÜN SINIRI: `day_advanced` günlük tikler dağıtılmadan önce atılır ve dünkü durumu okutur; kanca
# `day_tick_completed`. Dil ve palet değişince WindowLayer pencereyi yeniden kurar.
# ============================================================================

## The window grows with its columns (WindowLayer reads fit_height).
signal fit_changed

const INBOX := preload("res://scripts/ui/components/inbox.gd")
const LOG_ROWS := 5
# Portföyde önce dikkat isteyen hesaplar.
const ATTENTION_RANK := {"risk": 2, "expansion": 1}
## A phase's tag on its account; any other phase reads healthy.
const PHASE_TAGS := {"risk": ["SALES_CHIP_RISK", &"risk"], "expansion": ["SALES_CHIP_EXPANSION", &"pos"],
	"onboarding": ["SALES_CHIP_NEW", &"neutral"]}
## Under SAT_MID the satisfaction meter reads as a warning [WORKING]; danger is the Risk phase's alone.
const SAT_MID := 50
const CLOCK := "res://assets/icons/util/clock.svg"
const CALENDAR := "res://assets/icons/util/calendar.svg"
const INFO := "res://assets/icons/util/info.svg"
const ARROW := "res://assets/icons/util/arrow_right.svg"
const MAIL := "res://assets/icons/util/mail_open.svg"
const STAR := "res://assets/icons/util/star_full.svg"
const SALES_GLYPH := "res://assets/icons/rail/sales.svg"

var frame_options: Dictionary
var _kpis: Array = []   # customers, average satisfaction, gained this month, net this month
var _outer: VBoxContainer
var _ctl: PanelContainer
var _stance: HBoxContainer
var _cols: HBoxContainer
var _left: VBoxContainer
var _right: VBoxContainer
var _empty: VBoxContainer
var _signals: Array = []


func _init() -> void:
	var slot := HBoxContainer.new()
	slot.add_theme_constant_override("separation", 0)
	for key in ["SALES_STRIP_CUSTOMERS", "SALES_STRIP_SATISFACTION", "SALES_STRIP_GAINED", "SALES_STRIP_NET"]:
		var kpi := UiFactory.D_kpi(tr(key), "")
		_kpis.append(kpi)
		slot.add_child(kpi)
	frame_options = {"title": "TAB_SALES", "kpi": slot, "pad": Vector2i.ZERO}


func _ready() -> void:
	_build()
	# Her satırın ne gösterdiğini değiştirebilecek her seam; karar kapısı açılıp kapanınca denetimler de.
	_signals = [
		EventBus.prospect_added, EventBus.prospect_removed,
		EventBus.prospect_arrived, EventBus.lead_expired,
		EventBus.lead_reserved, EventBus.lead_routed, EventBus.lead_unrouted,
		EventBus.price_stance_changed, EventBus.rep_band_cap_changed,
		EventBus.rep_deal_closed, EventBus.deal_signed, EventBus.deal_walked,
		EventBus.customer_added, EventBus.customer_removed,
		EventBus.customer_health_changed, EventBus.customer_churn_countdown_changed,
		EventBus.customer_churned,
		EventBus.customer_expanded, EventBus.customer_assigned,
		EventBus.customer_satisfaction_changed, EventBus.customer_seats_changed,
		EventBus.mrr_changed, EventBus.day_tick_completed, EventBus.pitch_finished,
		EventBus.assignment_changed,
		EventBus.event_triggered, EventBus.event_resolved, EventBus.event_set_aside,
	]
	for sig in _signals:
		sig.connect(_on_state_changed)
	_refresh()


func _exit_tree() -> void:
	for sig in _signals:
		if sig.is_connected(_on_state_changed):
			sig.disconnect(_on_state_changed)


# Sinyaller 0 ile 3 argümanlı; tek işleyiciye bağlanabilsinler diye hepsi opsiyonel.
func _on_state_changed(_a = null, _b = null, _c = null) -> void:
	_refresh()


# --- Sayfa ------------------------------------------------------------------

func _build() -> void:
	_outer = VBoxContainer.new()
	_outer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_outer.add_theme_constant_override("separation", 0)
	add_child(_outer)
	_ctl = PanelContainer.new()
	_ctl.theme_type_variation = &"WinCtl"
	_ctl.custom_minimum_size.y = UiTokens.D_H_WIN_CTL
	_stance = HBoxContainer.new()
	_stance.add_theme_constant_override("separation", UiTokens.SPACE_L)
	_ctl.add_child(_stance)
	_outer.add_child(_ctl)
	var body := MarginContainer.new()
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("margin_left", UiTokens.SPACE_3XL)
	body.add_theme_constant_override("margin_top", UiTokens.SPACE_XL)
	body.add_theme_constant_override("margin_right", UiTokens.SPACE_3XL)
	body.add_theme_constant_override("margin_bottom", UiTokens.SPACE_3XL)
	_outer.add_child(body)
	_cols = HBoxContainer.new()
	_cols.add_theme_constant_override("separation", UiTokens.SPACE_XL)
	body.add_child(_cols)
	_left = _column(UiTokens.D_W_PIPELINE)
	_right = _column(0)
	_empty = VBoxContainer.new()
	_empty.custom_minimum_size.y = UiTokens.D_H_EMPTY_STATE
	_empty.alignment = BoxContainer.ALIGNMENT_CENTER
	_empty.add_theme_constant_override("separation", UiTokens.SPACE_L)
	HRUiShared.D_dashed(_empty)
	body.add_child(_empty)


## A column of lanes that scrolls on its own; its cards keep clear of the bar while it shows. `width` 0 takes
## the rest of the row.
func _column(width: int) -> VBoxContainer:
	var scroll := ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	if width > 0:
		scroll.custom_minimum_size.x = width
	else:
		scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_cols.add_child(scroll)
	var pad := MarginContainer.new()
	pad.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(pad)
	var bar := scroll.get_v_scroll_bar()
	bar.visibility_changed.connect(func() -> void:
		pad.add_theme_constant_override("margin_right", UiTokens.SPACE_M if bar.visible else 0))
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", UiTokens.SPACE_3XL)
	pad.add_child(col)
	col.minimum_size_changed.connect(fit_changed.emit)
	return col


## The window's natural height: the strip and the margins, and the taller column whole.
func fit_height() -> float:
	var lists: float = maxf(_left.get_combined_minimum_size().y, _right.get_combined_minimum_size().y) \
		if _cols.visible else 0.0
	return _outer.get_combined_minimum_size().y + lists


func _refresh() -> void:
	var open: bool = SalesFaucetSystem.market_open()
	var off: bool = EventGate.active_id() != ""
	_ctl.visible = open
	_cols.visible = open
	_empty.visible = not open
	for kpi: Control in _kpis:
		kpi.visible = open
	UiFactory.clear(_left)
	UiFactory.clear(_right)
	if open:
		var custs: Array[Customer] = CustomerRegistry.get_by_market("b2b")
		_paint_kpis(custs)
		_paint_stance(off)
		_paint_pipeline(off)
		_paint_portfolio(custs, off)
	else:
		_paint_empty()
	fit_changed.emit()


## Müşteri sayısı, ortalama memnuniyet (hesap yokken boş), bu ay kazanılan ve net hesap.
func _paint_kpis(custs: Array[Customer]) -> void:
	var total: int = 0
	for c in custs:
		total += c.satisfaction
	var ledger: Dictionary = GameState.month_ledger
	var gained: int = GameState.run_customers_signed - int(ledger.get("customers_signed", 0))
	var net: int = gained - (GameState.run_customers_lost - int(ledger.get("customers_lost", 0)))
	UiFactory.D_kpi_value(_kpis[0]).text = str(custs.size())
	UiFactory.D_kpi_value(_kpis[1]).text = "" if custs.is_empty() \
		else Fmt.percent(roundf(float(total) / custs.size()), 0)
	for pair in [[_kpis[2], gained], [_kpis[3], net]]:
		var value: Label = UiFactory.D_kpi_value(pair[0])
		value.text = ("+%d" % pair[1]) if pair[1] > 0 else str(pair[1])
		value.add_theme_color_override("font_color", UiTokens.D_delta_color(pair[1]))


## §7.5 FİYAT DURUŞU, B2B fiyatının tek kaynağı (§15): kurucunun masasında açılış çapası, temsilcinin masasında
## kapanış fiyatı. Üç kademe hep görünür, yürürlükteki dolu, yanında ne dediği.
func _paint_stance(off: bool) -> void:
	UiFactory.clear(_stance)
	_stance.add_child(UiFactory.make_label(Fmt.upper(tr("SALES_STANCE_CAPTION")), &"KeyLabel"))
	var current: String = SalesLedger.price_stance()
	var options: Array = SalesConstants.STANCES.map(func(stance: String) -> Dictionary:
		return {"text": tr("SALES_STANCE_" + stance.to_upper()), "tip": tr("SALES_STANCE_HINT_" + stance.to_upper())})
	_stance.add_child(UiFactory.D_seg_pick(options, SalesConstants.STANCES.find(current), func(i: int) -> void:
		SalesLedger.set_price_stance(SalesConstants.STANCES[i]), off))
	_stance.add_child(UiFactory.make_label(tr("SALES_STANCE_HINT_" + current.to_upper()), &"Caption"))


## §3.1 PAZAR: canlı B2B ürün yokken gövde tek boş hâldir, nedeniyle; türü B2C seçilmiş koşuda gelirin nerede
## sayıldığıyla (tür seçilmeden pazar bayrağı yoktur).
func _paint_empty() -> void:
	UiFactory.clear(_empty)
	var glyph := UiFactory.make_glyph(SALES_GLYPH, UiTokens.D_ICON_EMPTY, UiTokens.D_INK_4)
	glyph.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_empty.add_child(glyph)
	var words := VBoxContainer.new()
	words.add_theme_constant_override("separation", UiTokens.SPACE_XS)
	words.add_child(UiFactory.make_label(tr("SALES_LOCKED_NO_B2B"), &"DataStrong"))
	if SprintSystem.is_typed() and not SalesSystem.is_b2b_market():
		words.add_child(UiFactory.make_label(tr("SALES_B2C_NOTE"), &"NoteMuted"))
	for line: Label in words.get_children():
		line.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_empty.add_child(words)


# --- Sol sütun: boru hattı (§4), satış masası (§7), son hareketler ----------------

func _paint_pipeline(off: bool) -> void:
	var leads: Array[Prospect] = ProspectRegistry.get_all()
	leads.sort_custom(func(a: Prospect, b: Prospect) -> bool:
		if a.star != b.star:
			return a.star > b.star
		return a.expires_on_day < b.expires_on_day)
	# §3: akış oyuncuya görünen bir sayıdır; temsilci almak onu büyütür ve karşılığı burada okunur.
	var lane := _lane(_left, "SALES_PIPELINE_HEADER", tr("SALES_FLOW_RATE").format(
		{"n": Fmt.number(SalesFaucetSystem.lead_rate_per_week(), 1)}))
	if leads.is_empty():
		lane.add_child(UiFactory.make_label(tr("SALES_PROSPECTS_EMPTY"), &"NoteMuted"))
	for lead in leads:
		lane.add_child(_lead_card(lead, off))
	_paint_desk(off)
	_paint_log()


## §4 LEAD: alıcının yüzü, yanında şirket, yıldızları ve kalan süre, alıcının sesi; varsa onu işleyen temsilci,
## §8'in şartı ve lig telgrafı; altta, kartın tam eninde, bu masaya kimin oturacağı.
func _lead_card(p: Prospect, off: bool) -> PanelContainer:
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", UiTokens.SPACE_M)
	var top := HBoxContainer.new()
	top.add_theme_constant_override("separation", UiTokens.SPACE_L)
	var buyer: Dictionary = CounterpartSystem.prospect_people(p)[0]
	var face := UiFactory.make_person_avatar(buyer.name, buyer.look, UiTokens.D_AVATAR_ROW)
	face.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	face.tooltip_text = "%s · %s" % [buyer.name, CounterpartSystem.title(buyer)]
	face.mouse_filter = Control.MOUSE_FILTER_PASS
	top.add_child(face)
	var words := VBoxContainer.new()
	words.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	words.add_theme_constant_override("separation", UiTokens.SPACE_XS)
	var head := _name_row(p.company_name, &"DataStrong", p.star)
	if p.routing == SalesConstants.ROUTE_RESERVED:
		head.add_child(UiFactory.D_tag(tr("SALES_ROUTE_RESERVED"), &"neutral"))
	elif p.routing == SalesConstants.ROUTE_REP:
		head.add_child(UiFactory.D_tag(tr("SALES_ROUTE_REP")))
	head.add_child(RnDUiShared.spacer())
	head.add_child(_weeks_left(p))
	words.add_child(head)
	words.add_child(_line(SalesArchetypes.voice_line(p.archetype_id), &"MetaMuted"))
	# §7.2: işlenen lead kimin masasında ve kaçıncı hafta.
	if p.is_being_worked():
		var rep: Character = CharacterRegistry.get_character(p.worked_by)
		if rep != null:
			var who := HBoxContainer.new()
			who.add_theme_constant_override("separation", UiTokens.SPACE_S)
			who.add_child(UiFactory.make_label(rep.character_name, &"CaptionName"))
			who.add_child(UiFactory.make_label("·", &"Caption"))
			who.add_child(UiFactory.make_label(tr("SALES_REP_WORKING").format({"company": p.company_name,
				"n": GameState.day - p.work_started_day + 1}), &"Caption"))
			words.add_child(_glyph_line(CLOCK, UiTokens.D_INK_3, who))
	# §8: şart masaya oturmadan telgraflanır.
	if p.whale_condition != "":
		words.add_child(_glyph_line(INFO, UiTokens.D_INK_3, UiFactory.make_label(
			tr("SALES_WHALE_" + p.whale_condition.to_upper()), &"CaptionPrimary")))
	# §4: kilit değil telgraf, kurucu her masaya oturabilir.
	if p.is_above_league(int(HRConstants.stars_for(GameState.get_founder_skill(HRConstants.AREA_SALES)))):
		words.add_child(_line(tr("SALES_ABOVE_LEAGUE"), &"Caption"))
	top.add_child(words)
	col.add_child(top)
	col.add_child(_lead_actions(p, off))
	return _card(&"DealDoc", col)


## Kalan süre. Son hafta yalnız birden uzun yaşamış lead'de uyarı renginde: bir haftalık lead hep son haftasındadır
## ve hiç değişmeyen renk bir şey söylemez. Temsilcinin masasındaki lead yaşlanmaz.
func _weeks_left(p: Prospect) -> HBoxContainer:
	var n: int = p.weeks_left()
	var urgent: bool = n <= 1 and not p.is_being_worked() \
		and p.expires_on_day - p.spawned_on_day > TimeModel.ticks(1)
	return _glyph_line(CLOCK, UiTokens.D_warn() if urgent else UiTokens.D_INK_4, UiFactory.make_label(
		tr(Fmt.count_key("SALES_DAYS_LEFT", n)).format({"n": n}), &"Caption", UiTokens.D_warn() if urgent else null))


## §7.2.1'in iki fiili, bu masaya kim oturuyor sorusunun iki cevabı: Ayır masayı kurucuya saklar (temsilci
## atlar), Temsilciye ver bandındaysa öne alır; basılıyken bir daha basmak geri alır. §5.0'ın giriş kapısı
## kapalıyken gerekçesi düğmelerin hemen altındadır.
func _lead_actions(p: Prospect, off: bool) -> VBoxContainer:
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", UiTokens.SPACE_XS)
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_END
	row.add_theme_constant_override("separation", UiTokens.SPACE_M)
	col.add_child(row)
	var block: String = SalesLedger.meeting_block_reason(p.id)
	if block != "":
		var why := _line(tr(block), &"Caption")
		why.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		col.add_child(why)
	for pair in [[SalesConstants.ROUTE_RESERVED, "SALES_ROUTE_RESERVE"], [SalesConstants.ROUTE_REP, "SALES_ROUTE_GIVE"]]:
		var route: String = pair[0]
		var b := _button(tr(pair[1]), off)
		b.toggle_mode = true
		b.set_pressed_no_signal(p.routing == route)
		b.pressed.connect(func() -> void:
			SalesLedger.set_routing(p.id, SalesConstants.ROUTE_NONE if p.routing == route else route))
		row.add_child(b)
	var meet := _button(tr("SALES_ACTION_MEET"), off or block != "", ARROW)
	meet.pressed.connect(func() -> void: EventBus.pitch_requested.emit(p.id))
	row.add_child(meet)
	return col


## §7.2 SATIŞ MASASI: satış işine atanmış herkes.
func _paint_desk(off: bool) -> void:
	var lane := _lane(_left, "SALES_DESK_HEADER")
	var reps: Array[Character] = HRSystem.assigned_to(HRConstants.AREA_SALES)
	if reps.is_empty():
		lane.add_child(UiFactory.make_label(tr("SALES_DESK_EMPTY"), &"NoteMuted"))
	for r in reps:
		lane.add_child(_rep_card(r, off))


## Temsilci: yüzü, adı ve ligi; altında unvanı ya da şu an kimle görüştüğü ("Palmiye ile görüşüyor · 2. hafta"),
## çizginin altında çalıştığı bant.
func _rep_card(rep: Character, off: bool) -> PanelContainer:
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", UiTokens.SPACE_L)
	var top := HBoxContainer.new()
	top.add_theme_constant_override("separation", UiTokens.SPACE_L)
	top.add_child(UiFactory.make_person_avatar(rep.character_name, rep.look, UiTokens.D_AVATAR_DESK))
	var who := VBoxContainer.new()
	who.add_theme_constant_override("separation", 0)
	who.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	who.add_child(_name_row(rep.character_name, &"DataStrong",
		HRConstants.stars_for(HRSystem.skill(rep, HRConstants.AREA_SALES))))
	var work: Dictionary = SalesRepSystem.processing_view(rep)
	if work.is_empty():
		who.add_child(UiFactory.make_label(HRUiShared.roster_title(rep), &"CondCaption"))
	else:
		who.add_child(_glyph_line(CLOCK, UiTokens.D_INK_3, _slotted("SALES_REP_WORKING", "company",
			String(work.company_name), {"n": int(work.week)})))
	top.add_child(who)
	col.add_child(top)
	col.add_child(HSeparator.new())
	col.add_child(_band_row(rep, off))
	return _card(&"DeskCard", col)


## §7.2.2 BANT: tam yıldız kademeleri ve en sağda Kendi ligi (varsayılan). 1★ temsilcide seçici yerine düz bilgi
## satırı: tek kademelik seçici olmayan bir karar sunar. Ayar anında işler, süren işleme bitirilir.
func _band_row(rep: Character, off: bool) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", UiTokens.SPACE_L)
	var options: Array = SalesRepSystem.band_cap_options(rep)
	if options.is_empty():
		row.add_child(UiFactory.make_label(tr("SALES_BAND_OWN_ONLY"), &"Caption"))
		return row
	row.add_child(UiFactory.make_label(tr("SALES_BAND_CAPTION"), &"Caption"))
	var picks: Array = options.map(func(cap: int) -> Dictionary:
		return {"text": tr("SALES_BAND_OWN")} if cap == SalesConstants.BAND_CAP_OWN_LEAGUE \
			else {"text": str(cap), "icon": STAR})
	row.add_child(UiFactory.D_seg_pick(picks, options.find(SalesLedger.rep_band_cap(rep.id)), func(i: int) -> void:
		SalesLedger.set_rep_band_cap(rep.id, int(options[i])), off))
	return row


## SON HAREKETLER, boru hattının hafızası: §4'ün dürüst düşme satırı ("beklemekten vazgeçti") kartla birlikte
## gider ve oyuncunun görmediği kayıp telgraflanmamış kayıptır; temsilcinin kapanışları da burada.
func _paint_log() -> void:
	var lines := PackedStringArray()
	var entries: Array = SalesSystem.get_sales_log()
	for i in range(entries.size() - 1, -1, -1):
		var line: String = _log_line(entries[i])
		if line != "":
			lines.append(line)
		if lines.size() == LOG_ROWS:
			break
	if lines.is_empty():
		return
	var lane := _lane(_left, "SALES_LOG_HEADER")
	for line in lines:
		lane.add_child(_line(line, &"Caption"))


## The log stores internal ids, never a sentence, so the mapping to copy lives here.
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


# --- Sağ sütun: müşteri portföyü (§19) --------------------------------------

## Önce dikkat isteyen hesaplar; kurucu kendi kapasitesinin üstünde hesap taşıyorsa başta söylenir.
func _paint_portfolio(custs: Array[Customer], off: bool) -> void:
	var lane := _lane(_right, "SALES_PORTFOLIO_HEADER",
		tr(Fmt.count_key("SALES_CUSTOMERS_COUNT", custs.size())).format({"n": custs.size()}))
	if custs.is_empty():
		lane.add_child(UiFactory.make_label(tr("SALES_CUSTOMERS_EMPTY"), &"NoteMuted"))
		return
	var direct: int = B2BSalesSystem.founder_managed_count()
	if direct > CustomerRepSystem.founder_account_capacity():
		lane.add_child(UiFactory.make_label(tr("SALES_FOUNDER_STRETCHED").format({"n": direct}), &"Caption",
			UiTokens.D_warn()))
	custs.sort_custom(func(a: Customer, b: Customer) -> bool:
		return int(ATTENTION_RANK.get(a.lifecycle_phase, 0)) > int(ATTENTION_RANK.get(b.lifecycle_phase, 0)))
	for c in custs:
		lane.add_child(_account_card(c, off))


## Hesap belgesi: adı, ölçeği ve durumu; künyesi ve sesi; açık sözü; memnuniyeti ve churn sayacı; sorumlusu.
## Risk'teki hesap tehlike zeminindedir. Temsilcisi olan sakin hesabın adı bir ton geride.
func _account_card(c: Customer, off: bool) -> PanelContainer:
	var risk: bool = c.lifecycle_phase == "risk"
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", UiTokens.SPACE_M)
	var words := VBoxContainer.new()
	words.add_theme_constant_override("separation", UiTokens.SPACE_XS)
	var tag: Array = PHASE_TAGS.get(c.lifecycle_phase, ["SALES_CHIP_HEALTHY", &"outline"])
	var calm: bool = not ATTENTION_RANK.has(c.lifecycle_phase)
	var head := _name_row(c.display_name(), &"DataMedium" if calm and c.assigned_to != "" else &"DataStrong", c.scale)
	head.add_child(UiFactory.D_tag(tr(tag[0]), tag[1]))
	words.add_child(head)
	words.add_child(_line(_meta_line(c), &"MetaMuted"))
	if risk:
		words.add_child(_line(tr("SALES_REASON_PREFIX").format({"reason": INBOX.risk_reason()}), &"MetaMuted"))
	elif c.lifecycle_phase == "expansion":
		words.add_child(_line(tr("SALES_EXPANSION_FICTION"), &"MetaMuted"))
	col.add_child(words)
	_add_promise(col, c)
	col.add_child(_satisfaction_row(c))
	col.add_child(_account_foot(c, off))
	return _card(UiTokens.D_variation(&"DealRisk") if risk else &"DealDoc", col)


## "$1,0K/ay · 12 koltuk · 2 aydır müşteri", hesabın kendi koltuk fiyatı ve varsa imza indirimiyle (§5.4):
## büyüme bu fiyattan yazılır, oyuncu onu büyütmeden önce neye anlaştığını görmelidir.
func _meta_line(c: Customer) -> String:
	var months: int = int(TimeModel.months(GameState.day - c.acquired_on_day))
	var parts: Array[String] = [
		Fmt.money(c.mrr) + tr("SALES_PER_MONTH"),
		tr("SALES_SEATS").format({"n": c.seats}),
		tr("SALES_TENURE_NEW") if months < 1 else tr("SALES_TENURE").format({"n": months}),
	]
	if c.seat_price > 0:
		parts.append(tr("SALES_SEAT_PRICE").format({"price": Fmt.money_exact(c.seat_price)}))
	if c.signing_discount > 0.0:
		parts.append(tr("SALES_SIGNING_DISCOUNT").format({"pct": int(round(c.signing_discount * 100.0))}))
	return " · ".join(parts)


## AÇIK SÖZ hesabın kendi kartında, kırılırsa bedelini ödeyeceği yerde: ne söz verildi ve hangi sprintin sonuna
## kadar; tür seçilmeden verilmiş söz haftayla sayılır. Kesik kenarlı not, son haftasında uyarı renginde.
func _add_promise(col: VBoxContainer, c: Customer) -> void:
	var open: Array[Promise] = PromiseRegistry.get_open_for(c.id)
	if open.is_empty():
		return
	var p: Promise = open[0]
	var feature: String = B2BConstants.feature_label(p.feature_id)
	var text: String
	var due: bool
	if p.due_sprint >= 0:
		text = tr("SALES_PROMISE_OPEN_SPRINT").format({"feature": feature, "n": p.due_sprint})
		due = p.due_sprint <= SprintSystem.sprint_number()
	else:
		var weeks: int = p.deadline_day - GameState.day
		text = tr("SALES_PROMISE_OPEN_THIS_WEEK" if weeks <= 0 else Fmt.count_key("SALES_PROMISE_OPEN", weeks)).format(
			{"feature": feature, "n": weeks})
		due = weeks <= 1
	var note := PanelContainer.new()
	note.theme_type_variation = &"PromiseNote"
	note.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	note.add_child(_glyph_line(CALENDAR, UiTokens.D_warn() if due else UiTokens.D_INK_3,
		UiFactory.make_label(text, &"CaptionPrimary", UiTokens.D_warn() if due else null)))
	HRUiShared.D_dashed(note, UiTokens.D_badge_palette(&"accent").line if due else UiTokens.D_LINE_3)
	col.add_child(note)


## Memnuniyetin görünen katmanı (tolerans gizli kalır): Risk'te, değeri ne olursa olsun, tehlike renginde;
## değilse SAT_MID'in altında uyarı. Risk'teki hesapta sağda churn sayacı, kalan haftası dolu kare.
func _satisfaction_row(c: Customer) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", UiTokens.SPACE_L)
	row.add_child(UiFactory.make_label(Fmt.upper(tr("SALES_ACCOUNT_SATISFACTION")), &"KeyLabel"))
	var ink: Color = UiTokens.D_neg() if c.lifecycle_phase == "risk" \
		else (UiTokens.D_warn() if c.satisfaction < SAT_MID else UiTokens.D_pos())
	var value := UiFactory.make_label(str(c.satisfaction), &"SatValue", ink)
	value.custom_minimum_size.x = UiTokens.D_W_SAT
	value.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	row.add_child(value)
	row.add_child(HRUiShared.D_bar(UiTokens.D_SAT_BAR, c.satisfaction / 100.0, ink))
	if c.churn_countdown >= 0:
		row.add_child(RnDUiShared.spacer())
		var churn := HBoxContainer.new()
		churn.add_theme_constant_override("separation", UiTokens.SPACE_M)
		churn.add_child(UiFactory.make_label(tr(Fmt.count_key("SALES_CHURN_COUNTDOWN", c.churn_countdown)).format(
			{"n": c.churn_countdown}), &"MetaMuted", UiTokens.D_neg_ink()))
		var pips := HBoxContainer.new()
		pips.add_theme_constant_override("separation", UiTokens.SPACE_XXS)
		for i in B2BConstants.CHURN_COUNTDOWN_WEEKS:
			var pip := Panel.new()
			pip.theme_type_variation = UiTokens.D_variation(&"PipOn" if i < c.churn_countdown else &"PipOff")
			pip.custom_minimum_size = Vector2.ONE * UiTokens.D_PIP
			pip.size_flags_vertical = Control.SIZE_SHRINK_CENTER
			pips.add_child(pip)
		churn.add_child(pips)
		row.add_child(churn)
	for part: Control in row.get_children():
		part.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	return row


## Sorumlu ve Değiştir; ilgi isteyen hesapta sağda onun mailini Olaylar'da açan düğme. Temsilcisinin tırmandırdığı
## hesap customer.cs_escalation'ındır, düğme sunulmaz.
func _account_foot(c: Customer, off: bool) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", UiTokens.SPACE_M)
	var who: String = "—"
	if c.assigned_to != "":
		var cs: Character = CharacterRegistry.get_character(c.assigned_to)
		if cs != null:
			who = cs.character_name
	row.add_child(_slotted("SALES_STEWARD", "name", who))
	var change := _button(tr("SALES_STEWARD_CHANGE"), off)
	change.toggle_mode = true
	change.pressed.connect(_open_steward_picker.bind(c, change))
	row.add_child(change)
	var attend: String = ""
	if c.lifecycle_phase == "expansion":
		attend = "SALES_ACTION_EXPAND"
	elif c.lifecycle_phase == "risk" and not c.cs_escalated:
		attend = "SALES_ACTION_RETAIN"
	if attend != "":
		row.add_child(RnDUiShared.spacer())
		var go := _button(tr(attend), off, MAIL)
		go.pressed.connect(func() -> void: INBOX.show(INBOX.account_item(c.id)))
		row.add_child(go)
	return row


## Sorumlu seçici Değiştir'in altında, sol kenarı onun sol kenarında; eni sabit, daha geniş bir satır onu
## büyütür. Açıkken Değiştir basılı. Kurucu da bir seçenektir ve aynı satırı okur: aynı formül, aynı kapı (tavanda
## o da seçilemez, gerekçesini söyler); kapasitesi kendi Müşteri İlişkileri puanından, yükü doğrudan taşıdığı
## hesaplar. PanelLayer'a monte olur: CenterViewport kırpar, ModalLayer Space ve 1-4'ü yutardı.
func _open_steward_picker(c: Customer, change: Button) -> void:
	var pop: HRPopover = HRPopover.mount(change, true)
	var body: VBoxContainer = pop.body()
	body.custom_minimum_size.x = UiTokens.D_W_STEWARD_MENU
	body.add_theme_constant_override("separation", 0)
	body.add_child(_inset(UiFactory.make_label(Fmt.upper(tr("SALES_STEWARD_PICK")), &"KeySmall"), UiTokens.SPACE_S))
	var reps: Array = CustomerRepSystem.ranked_reps()
	for rep: Character in reps:
		_steward_option(pop, c, rep.id, rep.character_name, CustomerRepSystem.roster_size(rep.id),
			CustomerRepSystem.capacity_of(rep))
	if not reps.is_empty():
		body.add_child(_inset(HSeparator.new(), UiTokens.SPACE_XS))
	_steward_option(pop, c, "", tr("SALES_STEWARD_FOUNDER"), B2BSalesSystem.founder_managed_count(),
		CustomerRepSystem.founder_account_capacity())
	change.set_pressed_no_signal(true)
	pop.tree_exited.connect(func() -> void:
		if is_instance_valid(change):
			change.set_pressed_no_signal(false))
	pop.open_at(change, true, true)


## A steward's row: their name, why they cannot take the account when they cannot, and their load (bar and
## count). `steward_id` "" is the founder (Customer.assigned_to).
func _steward_option(pop: HRPopover, c: Customer, steward_id: String, steward_name: String, used: int,
		cap: int) -> void:
	var why: String = "SALES_STEWARD_CURRENT" if steward_id == c.assigned_to \
		else ("SALES_STEWARD_FULL" if used >= cap else "")
	var item := Button.new()
	item.theme_type_variation = &"MenuItem"
	item.focus_mode = Control.FOCUS_NONE
	item.disabled = why != ""
	var off: Variant = UiTokens.D_INK_OFF if item.disabled else null
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", UiTokens.SPACE_L)
	var name_label := UiFactory.make_label(steward_name, &"DataText", off)
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(name_label)
	if why != "":
		row.add_child(UiFactory.make_label(tr(why), &"Caption"))
	var load := HBoxContainer.new()
	load.add_theme_constant_override("separation", UiTokens.SPACE_M)
	load.add_child(HRUiShared.D_bar(UiTokens.D_LOAD_BAR, float(used) / cap,
		UiTokens.D_INK_3 if used >= cap else UiTokens.D_BAR_FILL))
	load.add_child(UiFactory.make_label("%d/%d" % [used, cap], &"Caption", off))
	row.add_child(load)
	for part: Control in row.get_children():
		part.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	HRUiShared.set_mouse_ignore(row)
	row.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	row.offset_left = UiTokens.SPACE_M
	row.offset_right = -UiTokens.SPACE_M
	item.add_child(row)
	pop.body().add_child(item)
	# A button does not measure its children; the row is measured once it reads the menu's theme.
	item.custom_minimum_size = Vector2(row.get_combined_minimum_size().x + 2 * UiTokens.SPACE_M, UiTokens.D_H_MENU_ITEM)
	if not item.disabled:
		item.pressed.connect(func() -> void:
			# Pinned even for the founder: otherwise _delegate_excess hands it straight back at the next tick
			# and the player's choice silently evaporates.
			CustomerRegistry.assign_customer(c.id, steward_id, true)
			pop.close())


# --- Küçük yapı taşları -----------------------------------------------------

## A lane: its caps head over a rule, a figure at its right when given; its cards follow.
func _lane(parent: VBoxContainer, key: String, figure := "") -> VBoxContainer:
	var lane := VBoxContainer.new()
	lane.add_theme_constant_override("separation", UiTokens.SPACE_M)
	var head := PanelContainer.new()
	head.theme_type_variation = &"TableHead"
	var row := HBoxContainer.new()
	row.add_child(UiFactory.make_label(Fmt.upper(tr(key)), &"KeyLabel"))
	if figure != "":
		var right := UiFactory.make_label(figure, &"Caption")
		right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		right.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		row.add_child(right)
	head.add_child(row)
	lane.add_child(head)
	parent.add_child(lane)
	return lane


## A menu's head or rule, inset from the menu's sides as its rows are; `top` above it, SPACE_XS under it.
func _inset(child: Control, top: int) -> MarginContainer:
	var pad := MarginContainer.new()
	pad.add_theme_constant_override("margin_left", UiTokens.SPACE_M)
	pad.add_theme_constant_override("margin_top", top)
	pad.add_theme_constant_override("margin_right", UiTokens.SPACE_M)
	pad.add_theme_constant_override("margin_bottom", UiTokens.SPACE_XS)
	pad.add_child(child)
	return pad


func _card(look: StringName, content: Control) -> PanelContainer:
	var card := PanelContainer.new()
	card.theme_type_variation = look
	card.add_child(content)
	return card


## Ad ve yıldızları: lead, hesap ve temsilci aynı ölçeği aynı glifle okur.
func _name_row(text: String, look: StringName, stars: float) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", UiTokens.SPACE_M)
	row.add_child(UiFactory.make_label(text, look))
	row.add_child(UiFactory.D_stars(stars))
	return row


## A line that wraps at its card's width.
func _line(text: String, look: StringName) -> Label:
	var line := UiFactory.make_label(text, look)
	line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return line


## A glyph, then the line's words.
func _glyph_line(glyph: String, ink: Color, words: Control) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", UiTokens.SPACE_S)
	row.add_child(UiFactory.make_glyph(glyph, UiTokens.D_ICON_LINE, ink))
	row.add_child(words)
	return row


## A caption sentence whose one slot reads in a stronger face; the template's own words stay plain on both sides,
## in each language's order.
func _slotted(key: String, slot: String, value: String, args := {}) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 0)
	var sides: PackedStringArray = tr(key).format(args).split("{%s}" % slot)
	for i in sides.size():
		if i > 0:
			row.add_child(UiFactory.make_label(value, &"CaptionName"))
		if sides[i] != "":
			row.add_child(UiFactory.make_label(sides[i], &"Caption"))
	return row


## The cards' secondary button; `off` while a decision waits or its gate is shut.
func _button(text: String, off: bool, glyph := "") -> Button:
	var b := Button.new()
	b.theme_type_variation = &"SecondaryButtonSmall"
	b.text = text
	if glyph != "":
		b.icon = load(glyph)
	b.focus_mode = Control.FOCUS_NONE   # Space is the speed key
	b.disabled = off
	b.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	return b
