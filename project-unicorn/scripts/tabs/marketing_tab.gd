extends Control

# ============================================================================
# Pazarlama penceresi (PRD_PAZARLAMA §3, §5 ve §7). ERP: koyu başlıkta dört ölçü (bu hafta aday, Satış'a giden, eşik
# altında, haftalık harcama); denetim şeridinde ekip (yükleriyle) ve devir eşiği; gövdede kanal satırları (bütçe, haftalık
# aday, aday başı, MRR katkısı, yürüten), kanal ekle ve Satış'ın kendi akışı (Organik). Pazaryeri: başlıkta yeni kullanıcı,
# ücretli pay ve haftalık harcama (altında satışlara oranı); şeritte ekip; satır kategoride yürür ve dört sayısını yazar
# (bütçe, yeni kullanıcı, kullanıcı başı, MRR katkısı), doyum yüksekken uyarı etiketi, kullanıcı başı geçen haftadan pahalıysa
# yukarı ok; satır iki katlıdır (adı ve yürüteni, altında sayıları). Sağ sütunda kampanya (evresi, tarihleri, hazırlığı ya da
# kalan haftası; hazırlıktayken iptali), "Kampanya kur" ve biten kampanyalar. Ürün canlı değilken gövde tek boş hâldir ve
# şartını yazar.
#
# Sayfa durumu okur ve MarketingSystem'in kapılarını tetikler, kendisi yazmaz (WRITE-THROUGH LAW). Karar beklerken
# denetimleri kapalıdır. PROCESS_MODE_ALWAYS (.tscn): duraklatılmış düğüm çizilir ama tıklama almaz.
# ============================================================================

## The window grows with its rows (WindowLayer reads fit_height).
signal fit_changed

const MarketingSystem := preload("res://scripts/systems/marketing_system.gd")
## Weekly user counts read as Pazaryeri's window writes them: one decimal under 10, a grouped whole number above.
const MpParts := preload("res://scripts/tabs/marketplace/mp_parts.gd")
const PLUS := "res://assets/icons/util/plus.svg"
const MINUS := "res://assets/icons/util/minus.svg"
const CHEVRON := "res://assets/icons/util/chevron_down.svg"
const EMPTY_GLYPH := "res://assets/icons/rail/marketing.svg"
const KIND_GLYPHS := {"content_seo": "res://assets/icons/util/doc.svg", "search_ads": "res://assets/icons/dept/marketing.svg",
	"referral": "res://assets/icons/dept/customer_success.svg", "target_sector": "res://assets/icons/util/flag.svg",
	"social_ads": "res://assets/icons/product/voices.svg", "display_ads": "res://assets/icons/util/news.svg",
	"price_compare": "res://assets/icons/channel/price_compare.svg", "affiliate": "res://assets/icons/channel/affiliate.svg",
	"email": "res://assets/icons/util/mail_open.svg", "influencer": "res://assets/icons/util/sparkle.svg"}
const ORGANIC_GLYPH := "res://assets/icons/type/erp.svg"
const ORGANIC_GLYPH_MP := "res://assets/icons/type/marketplace.svg"
const UP := "res://assets/icons/util/tri_up.svg"
const CALENDAR := "res://assets/icons/util/calendar.svg"
const CAMPAIGN_MODAL := "res://scenes/modals/CampaignModal.tscn"
## A marketplace page's right column (the campaign and the history); the channel table takes the rest.
const SIDE := 360
const STAGE_TAGS := {"prep": &"outline", "run": &"pos", "after": &"warn"}
## The handoff threshold's three positions, as MarketingSystem.HANDOFFS names them.
const HANDOFF_KEYS := ["MKT_HANDOFF_ALL", "MKT_HANDOFF_2", "MKT_HANDOFF_3"]
## Column widths of a channel row [name, budget, leads a week, per lead, MRR]; the runner takes the rest.
const W := [208, 152, 112, 112, 112]

var frame_options: Dictionary
var _kpis: Array = []   # ERP: leads this week, handed to Sales, under the threshold · marketplace: new users, paid share
var _mp: bool = false
var _kpi_slot: HBoxContainer
var _spend: Control
var _outer: VBoxContainer
var _ctl: PanelContainer
var _team: HBoxContainer
var _handoff: HBoxContainer
var _rows: VBoxContainer
var _side: VBoxContainer   # a marketplace's campaign column; null on an ERP page
var _empty: VBoxContainer
var _signals: Array = []


func _init() -> void:
	_mp = SalesSystem.is_marketplace()
	_kpi_slot = HBoxContainer.new()
	_kpi_slot.add_theme_constant_override("separation", 0)
	for key in (["MKT_KPI_NEW_USERS", "MKT_KPI_PAID_SHARE"] if _mp else ["MKT_KPI_LEADS", "MKT_KPI_HANDED", "MKT_KPI_BELOW"]):
		_kpis.append(UiFactory.D_kpi(tr(key), ""))
		_kpi_slot.add_child(_kpis.back())
	if _mp:
		_kpis[1].tooltip_text = tr("MKT_KPI_PAID_SHARE_TIP")
	frame_options = {"title": "TAB_MARKETING", "kpi": _kpi_slot, "pad": Vector2i.ZERO}


func _ready() -> void:
	_build()
	_signals = [EventBus.day_tick_completed, EventBus.assignment_changed, EventBus.mrr_changed,
		EventBus.event_triggered, EventBus.event_resolved, EventBus.event_set_aside]
	for sig in _signals:
		sig.connect(_on_state_changed)
	_refresh()


func _exit_tree() -> void:
	for sig in _signals:
		if sig.is_connected(_on_state_changed):
			sig.disconnect(_on_state_changed)


func _on_state_changed(_a = null, _b = null, _c = null) -> void:
	_refresh()


func _build() -> void:
	_outer = VBoxContainer.new()
	_outer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_outer.add_theme_constant_override("separation", 0)
	add_child(_outer)
	_ctl = PanelContainer.new()
	_ctl.theme_type_variation = &"WinCtl"
	_ctl.custom_minimum_size.y = UiTokens.D_H_WIN_CTL
	var strip := HBoxContainer.new()
	strip.add_theme_constant_override("separation", UiTokens.SPACE_L)
	_team = HBoxContainer.new()
	_team.add_theme_constant_override("separation", UiTokens.SPACE_M)
	_team.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	strip.add_child(_team)
	_handoff = HBoxContainer.new()
	_handoff.add_theme_constant_override("separation", UiTokens.SPACE_L)
	strip.add_child(_handoff)
	_ctl.add_child(strip)
	_outer.add_child(_ctl)
	var body := MarginContainer.new()
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	for side in ["left", "right", "bottom"]:
		body.add_theme_constant_override("margin_" + side, UiTokens.SPACE_3XL)
	body.add_theme_constant_override("margin_top", UiTokens.SPACE_XL)
	_outer.add_child(body)
	var stack := VBoxContainer.new()
	stack.add_theme_constant_override("separation", 0)
	body.add_child(stack)
	var cols := HBoxContainer.new()
	cols.add_theme_constant_override("separation", UiTokens.SPACE_XL)
	stack.add_child(cols)
	_rows = VBoxContainer.new()
	_rows.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_rows.add_theme_constant_override("separation", UiTokens.SPACE_M)
	_rows.minimum_size_changed.connect(fit_changed.emit)
	cols.add_child(_rows)
	if _mp:
		_side = VBoxContainer.new()
		_side.custom_minimum_size.x = SIDE
		_side.add_theme_constant_override("separation", UiTokens.SPACE_M)
		_side.minimum_size_changed.connect(fit_changed.emit)
		cols.add_child(_side)
	_empty = VBoxContainer.new()
	_empty.custom_minimum_size.y = UiTokens.D_H_EMPTY_STATE
	_empty.alignment = BoxContainer.ALIGNMENT_CENTER
	_empty.add_theme_constant_override("separation", UiTokens.SPACE_L)
	HRUiShared.D_dashed(_empty)
	stack.add_child(_empty)


## The window's natural height: the strip, the margins and the rows.
func fit_height() -> float:
	return _outer.get_combined_minimum_size().y


func _refresh() -> void:
	var open: bool = ProductState.is_live() and (SalesFaucetSystem.market_open() or _mp)
	var off: bool = EventGate.active_id() != ""
	_ctl.visible = open
	_rows.visible = open
	if _side != null:
		_side.visible = open
	_empty.visible = not open
	for kpi: Control in _kpis:
		kpi.visible = open
	if _spend != null:
		_spend.queue_free()
		_spend = null
	UiFactory.clear(_rows)
	if open:
		_paint_kpis()
		_paint_team()
		_handoff.visible = not _mp   # the threshold is Sales' (ERP leads); a marketplace has none
		if not _mp:
			_paint_handoff(off)
		_paint_rows(off)
		if _mp:
			_paint_side(off)
	else:
		_paint_empty()
	fit_changed.emit()


func _paint_kpis() -> void:
	var week: Dictionary = GameState.marketing.get("week", {})
	# What Finance's line will carry: a marketplace row at its cap spends less than its budget.
	var spend: int = MarketingSystem.week_spend()
	if _mp:
		UiFactory.D_kpi_value(_kpis[0]).text = MpParts.count(MarketingSystem.week_new_users())
		# With no new user in four weeks the share has no value, and the cell stays empty (as per lead does with no lead).
		var paid: float = MarketingSystem.paid_share()
		UiFactory.D_kpi_value(_kpis[1]).text = Fmt.percent(paid * 100.0, 0) if paid >= 0.0 else ""
	else:
		UiFactory.D_kpi_value(_kpis[0]).text = str(int(week.get("made", 0)))
		UiFactory.D_kpi_value(_kpis[1]).text = str(int(week.get("handed", 0)))
		UiFactory.D_kpi_value(_kpis[2]).text = str(MarketingSystem.nurture().size())
	# The spend's cell carries its cost glyph, so it is built with its value; a marketplace's line under it is last week's
	# spend against the stores' sales, written only in a week that had sales.
	_spend = UiFactory.D_kpi(tr("MKT_KPI_SPEND"), Fmt.money_exact(spend), true)
	var ratio: float = MarketingSystem.sales_ratio() if _mp else -1.0
	if ratio >= 0.0:
		_spend.get_child(0).add_child(UiFactory.make_label(tr("MKT_SALES_RATIO").format({"pct": Fmt.percent(ratio * 100.0, 1)}),
			&"Caption"))
		_spend.tooltip_text = tr("MKT_SALES_RATIO_TIP")
	_kpi_slot.add_child(_spend)


## EKİP: everyone who can run a row, each with their load; the founder's share of a week is theirs alone.
func _paint_team() -> void:
	UiFactory.clear(_team)
	_team.add_child(UiFactory.make_label(Fmt.upper(tr("MKT_TEAM_CAPTION")), &"KeyLabel"))
	for c: Character in MarketingSystem.runners():
		var chip := HBoxContainer.new()
		chip.add_theme_constant_override("separation", UiTokens.SPACE_M)
		chip.add_child(UiFactory.make_person_avatar(c.character_name, c.look, UiTokens.D_AVATAR_ROW_SM))
		var words := VBoxContainer.new()
		words.add_theme_constant_override("separation", 0)
		words.add_child(_name_row(_who(c), &"DataStrong", -1.0 if c.category == "founder"
			else HRConstants.stars_for(HRSystem.skill(c, HRConstants.AREA_SALES))))
		var load: int = MarketingSystem.load_pct(c.id)
		var bar := HBoxContainer.new()
		bar.add_theme_constant_override("separation", UiTokens.SPACE_M)
		bar.add_child(HRUiShared.D_bar(UiTokens.D_LOAD_BAR, minf(load / 100.0, 1.0),
			UiTokens.D_neg() if load > 100 else UiTokens.D_BAR_FILL))
		bar.add_child(UiFactory.make_label(Fmt.percent(load, 0), &"Caption"))
		words.add_child(bar)
		chip.add_child(words)
		_team.add_child(chip)


## DEVİR EŞİĞİ: which of the rows' leads reach Sales; the rest wait for İçerik and may drop.
func _paint_handoff(off: bool) -> void:
	UiFactory.clear(_handoff)
	_handoff.add_child(UiFactory.make_label(Fmt.upper(tr("MKT_HANDOFF_CAPTION")), &"KeyLabel"))
	var options: Array = HANDOFF_KEYS.map(func(key: String) -> Dictionary:
		return {"text": tr(key), "tip": tr(key + "_TIP")})
	_handoff.add_child(UiFactory.D_seg_pick(options, MarketingSystem.HANDOFFS.find(MarketingSystem.handoff()),
		func(i: int) -> void:
			MarketingSystem.set_handoff(MarketingSystem.HANDOFFS[i])
			_refresh(), off))


func _paint_rows(off: bool) -> void:
	var head := PanelContainer.new()
	head.theme_type_variation = &"TableHead"
	var cols := HBoxContainer.new()
	var caps: Array = ["MKT_COL_CHANNELS", "MKT_COL_BUDGET", "MKT_COL_NEW_USERS", "MKT_COL_PER_USER", "MKT_COL_MRR"] if _mp \
		else ["MKT_COL_CHANNELS", "MKT_COL_BUDGET", "MKT_COL_LEADS", "MKT_COL_PER_LEAD", "MKT_COL_MRR"]
	# A marketplace's per user and MRR contribution say in their tip what they are counted against (ortak kural 6).
	var tips: Array = ["", "", "", "MKT_COL_PER_USER_TIP", "MKT_COL_MRR_MP_TIP"] if _mp else ["", "", "", "", ""]
	for i in W.size():
		var cap := UiFactory.make_label(Fmt.upper(tr(caps[i])), &"KeyLabel")
		cap.custom_minimum_size.x = W[i]
		if tips[i] != "":
			cap.tooltip_text = tr(tips[i])
			cap.mouse_filter = Control.MOUSE_FILTER_PASS
		cols.add_child(cap)
	head.add_child(cols)
	_rows.add_child(head)
	for r: Dictionary in MarketingSystem.rows():
		_rows.add_child(_row_card(r, off))
	var foot := HBoxContainer.new()
	foot.add_theme_constant_override("separation", UiTokens.SPACE_L)
	var nobody: bool = MarketingSystem.free_runner() == ""
	var add := _button(tr("MKT_ADD_CHANNEL"), off or nobody or MarketingSystem.addable().is_empty(), PLUS)
	add.pressed.connect(_open_add_menu.bind(add))
	foot.add_child(add)
	if nobody:
		foot.add_child(UiFactory.make_label(tr("MKT_NEEDS_SPECIALIST"), &"Caption"))
	_rows.add_child(foot)
	var organic := HBoxContainer.new()
	organic.add_theme_constant_override("separation", UiTokens.SPACE_L)
	organic.add_child(UiFactory.make_glyph(ORGANIC_GLYPH_MP if _mp else ORGANIC_GLYPH, UiTokens.D_ICON_LINE, UiTokens.D_INK_3))
	organic.add_child(UiFactory.make_label(tr("SALES_SOURCE_ORGANIC"), &"DataText"))
	# A marketplace's organic flow is the users who came by themselves at the last close; an ERP's, Sales' own leads.
	var flow: float = MarketplaceSystem.source_new_users("organic") if _mp else SalesFaucetSystem.lead_rate_per_week()
	organic.add_child(UiFactory.make_label(tr("MKT_PER_WEEK").format({"n": MpParts.count(flow) if _mp else Fmt.number(flow)}),
		&"DataStrong"))
	_rows.add_child(_card(&"DealDoc", organic))


## KAMPANYA: the campaign in preparation, running or in its dip, and Kampanya kur, shut while one is on (one at a time) or while
## nobody can run it; GEÇMİŞ: the finished campaigns, the latest first.
func _paint_side(off: bool) -> void:
	UiFactory.clear(_side)
	_side.add_child(_side_head("MP_VISITS_CAMPAIGN"))
	var camp: Dictionary = MarketingSystem.campaign()
	if not camp.is_empty():
		_side.add_child(_campaign_card(camp, off))
	var nobody: bool = MarketingSystem.free_runner() == ""
	var setup := _button(tr("MKT_CAMPAIGN_NEW"), off or nobody or not camp.is_empty(), PLUS)
	setup.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	setup.tooltip_text = tr("MKT_CAMPAIGN_NEW_TIP") if not camp.is_empty() else (tr("MKT_NEEDS_SPECIALIST") if nobody else "")
	setup.pressed.connect(func() -> void: HRUiShared.mount_panel_modal(self, CAMPAIGN_MODAL, _refresh))
	_side.add_child(setup)
	var history: Array = GameState.marketing.get("history", [])
	if history.is_empty():
		return
	var head := MarginContainer.new()
	head.add_theme_constant_override("margin_top", UiTokens.SPACE_XL)
	head.add_child(_side_head("MKT_HISTORY"))
	_side.add_child(head)
	for i in range(history.size() - 1, -1, -1):
		var done := VBoxContainer.new()
		done.add_theme_constant_override("separation", UiTokens.SPACE_XXS)
		done.add_child(_line(_campaign_name(history[i]), &"DataText"))
		done.add_child(UiFactory.make_label(MarketingSystem.window_dates(int(history[i].start), int(history[i].weeks)), &"Caption"))
		var pad := MarginContainer.new()
		pad.add_theme_constant_override("margin_bottom", UiTokens.SPACE_M)
		pad.add_child(done)
		_side.add_child(_card(&"TableRow", pad))


## A caps key over the column's rule, as the channel table's head.
func _side_head(key: String) -> PanelContainer:
	return _card(&"TableHead", UiFactory.make_label(Fmt.upper(tr(key)), &"KeyLabel"))


## The campaign: its name and its stage, its weeks as dates; in preparation the weeks prepared of those it needs (or the day the
## preparation starts) and the way to call it off; running or in its dip, the weeks left of that stage.
func _campaign_card(c: Dictionary, off: bool) -> PanelContainer:
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", UiTokens.SPACE_S)
	var head := HBoxContainer.new()
	head.add_theme_constant_override("separation", UiTokens.SPACE_M)
	head.add_child(_line(_campaign_name(c), &"DataStrong"))
	head.add_child(UiFactory.D_tag(tr("MKT_STAGE_" + String(c.stage).to_upper()), STAGE_TAGS[c.stage]))
	col.add_child(head)
	var when := HBoxContainer.new()
	when.add_theme_constant_override("separation", UiTokens.SPACE_S)
	var glyph := UiFactory.make_glyph(CALENDAR, UiTokens.D_ICON_LINE, UiTokens.D_INK_3)
	glyph.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	when.add_child(glyph)
	when.add_child(UiFactory.make_label(MarketingSystem.window_dates(int(c.start), int(c.weeks)), &"Caption"))
	col.add_child(when)
	if c.stage != "prep":
		var left: int = int(c.weeks_left if c.stage == "run" else c.dip_left)
		col.add_child(UiFactory.make_label(tr(Fmt.count_key("MKT_CAMPAIGN_LEFT", left)).format({"n": left}), &"Caption"))
		return _card(&"DealDoc", col)
	var total: int = int(c.prep.total)
	if MarketingSystem._preparing(c):
		var prep := HBoxContainer.new()
		prep.add_theme_constant_override("separation", UiTokens.SPACE_M)
		prep.add_child(UiFactory.make_label(tr(Fmt.count_key("MKT_CAMPAIGN_PREP", total)).format({"done": int(c.prep.done),
			"total": total}), &"Caption"))
		prep.add_child(HRUiShared.D_bar(UiTokens.D_LOAD_BAR, int(c.prep.done) / float(total), UiTokens.D_BAR_FILL))
		col.add_child(prep)
	else:   # it only waits until its last prep weeks before the start
		col.add_child(UiFactory.make_label(tr("MKT_CAMPAIGN_PREP_STARTS").format(
			{"date": Fmt.day_month(GameState.get_date_dict(int(c.start) - total))}), &"Caption"))
	# Only a campaign still in preparation can be called off; the tip says what that costs.
	var cancel := _button(tr("MKT_CAMPAIGN_CANCEL"), off)
	cancel.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	cancel.tooltip_text = tr("MKT_CAMPAIGN_CANCEL_TIP")
	cancel.pressed.connect(func() -> void:
		MarketingSystem.cancel_campaign()
		_refresh())
	col.add_child(cancel)
	return _card(&"DealDoc", col)


## A campaign as the page names it: its window and its template; one run now (outside the calendar) names its template only.
func _campaign_name(c: Dictionary) -> String:
	var template: String = tr("MKT_TEMPLATE_" + String(c.kind).to_upper())
	return template if c.window == "now" else tr("MKT_WINDOW_" + String(c.window).to_upper()) + SprintUiShared.SEP + template


## One channel: its name, the stars its leads usually are and its last four weeks of leads; the budget's − and +; its leads a
## week, what a lead costs and the MRR its signings bring; its runner, whose menu also closes the row. A marketplace row is two
## lines: its name, the saturation tag while high and its runner over its last four weeks of new users, its budget, new users,
## per user and MRR contribution (the column head reads over the second line).
func _row_card(r: Dictionary, off: bool) -> PanelContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 0)
	var title := HBoxContainer.new()
	title.add_theme_constant_override("separation", UiTokens.SPACE_M)
	title.add_child(UiFactory.make_glyph(KIND_GLYPHS[r.kind], UiTokens.D_ICON_LINE, UiTokens.D_INK_3))
	var runner: Character = CharacterRegistry.get_character(String(r.runner))
	var pick := _button(_who(runner), off, CHEVRON)
	pick.size_flags_horizontal = Control.SIZE_EXPAND | Control.SIZE_SHRINK_END
	pick.icon_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	pick.pressed.connect(_open_runner_menu.bind(r, pick))
	if _mp:
		title.add_child(UiFactory.make_label(MarketingSystem.row_label(r), &"DataStrong"))
		if float(r.get("share", 0.0)) >= float(MarketingSystem.cfg("market.warn_share")):
			title.add_child(_saturation(r))
		title.add_child(pick)
		for part: Control in title.get_children():
			part.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		var bars := _bars((r.get("weeks", []) as Array).slice(-4).map(func(w: Dictionary) -> int: return roundi(float(w.users))))
		bars.custom_minimum_size.x = W[0]
		row.add_child(bars)
	else:
		var name_col := VBoxContainer.new()
		name_col.custom_minimum_size.x = W[0]
		name_col.add_theme_constant_override("separation", UiTokens.SPACE_XS)
		title.add_child(_line(MarketingSystem.row_label(r), &"DataStrong"))
		# A gap before the budget column: a name that just fits wraps short of the − button instead of touching it.
		var title_box := MarginContainer.new()
		title_box.add_theme_constant_override("margin_right", UiTokens.SPACE_M)
		title_box.add_child(title)
		name_col.add_child(title_box)
		name_col.add_child(UiFactory.D_stars(MarketingSystem.typical_star(r)))
		name_col.add_child(_bars(r.get("hist", [])))
		row.add_child(name_col)
	var budget := HBoxContainer.new()
	budget.custom_minimum_size.x = W[1]
	budget.add_theme_constant_override("separation", UiTokens.SPACE_S)
	if bool(MarketingSystem.cfg("kinds.%s.budgeted" % r.kind)):
		var down := _button("", off or int(r.budget) == 0, MINUS)
		down.pressed.connect(func() -> void: MarketingSystem.step_budget(int(r.id), -1); _refresh())
		budget.add_child(down)
		budget.add_child(UiFactory.make_label(Fmt.money_exact(int(r.budget)), &"DataText"))
		var up := _button("", off, PLUS)
		up.pressed.connect(func() -> void: MarketingSystem.step_budget(int(r.id), 1); _refresh())
		budget.add_child(up)
	row.add_child(budget)
	if _mp and r.kind == "email":
		# E-posta brings no new user: it raises the returning visits, and that is its number.
		var lift := _cell(tr("MKT_EMAIL_LIFT").format({"pct": Fmt.percent(float(MarketingSystem.cfg("market.email_lift")) * 100.0, 0)}),
			W[2] + W[3] + W[4])
		lift.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		row.add_child(lift)
	elif _mp:
		row.add_child(_cell(MpParts.count(MarketingSystem.row_new_users(r)), W[2]))
		row.add_child(_per_user(r))
	else:
		var rate: float = MarketingSystem.leads_per_week(r)
		row.add_child(_cell(Fmt.number(rate), W[2]))
		row.add_child(_cell(Fmt.money_exact(roundi(int(r.budget) / rate)) if rate > 0.0 and int(r.budget) > 0 else "", W[3]))
	if not (_mp and r.kind == "email"):
		row.add_child(_mrr_cell(MarketingSystem.row_mrr(r)))
	if not _mp:
		row.add_child(pick)
	for part: Control in row.get_children():
		part.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	if not _mp:
		return _card(&"DealDoc", row)
	var lines := VBoxContainer.new()
	lines.add_theme_constant_override("separation", UiTokens.SPACE_S)
	lines.add_child(title)
	lines.add_child(row)
	return _card(&"DealDoc", lines)


## A channel with no signing yet reads $0, muted; per lead stays empty with no leads (it has no value then).
func _mrr_cell(mrr: int) -> Label:
	var cell := _cell("+" + Fmt.money_exact(mrr) if mrr > 0 else Fmt.money_exact(0), W[4])
	if mrr > 0:
		cell.add_theme_color_override("font_color", UiTokens.D_pos())
	else:
		cell.theme_type_variation = &"NoteMuted"
	return cell


## A marketplace row's cost per new user at the last close; empty with no spend or no user. Dearer than the week before, an
## up arrow in the warning ink beside it (a cost's language in Pazaryeri; red is for danger), and its tip the week before's
## figure and the row's saturation: the budget a player raised buys the dearer slots, and the row says so where its cost is read.
func _per_user(r: Dictionary) -> Control:
	var cell := HBoxContainer.new()
	cell.custom_minimum_size.x = W[3]
	cell.add_theme_constant_override("separation", UiTokens.SPACE_S)
	var now: float = MarketingSystem.row_per_user(r)
	if now < 0.0:
		return cell
	cell.add_child(UiFactory.make_label(Fmt.money_exact(roundi(now)), &"DataText"))
	var before: float = MarketingSystem.row_per_user_before(r)
	if before > 0.0 and roundi(now) > roundi(before):
		var up := UiFactory.make_glyph(UP, UiTokens.D_ICON_LINE, UiTokens.D_warn())
		up.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		cell.add_child(up)
		# Dearer than last week, the tip says why: last week's cost and the slots it now pays for.
		cell.mouse_filter = Control.MOUSE_FILTER_STOP
		cell.tooltip_text = tr("MKT_PER_USER_UP_TIP").format({"was": Fmt.money_exact(roundi(before)),
			"pct": Fmt.percent(float(r.get("share", 0.0)) * 100.0, 0)})
	return cell


## The saturation tag (M5): the share of the row's weekly ad slots it was shown in, while high; its tip the two counts.
func _saturation(r: Dictionary) -> Control:
	var cat: String = tr("MP_CAT_" + String(r.target).to_upper())
	var share: float = float(r.share)
	# The row already names its category; the tag stays short in the name column and the category is in its tip.
	var tag := UiFactory.D_tag(tr("MKT_SATURATION").format({"pct": Fmt.percent(share * 100.0, 0)}), &"warn")
	var slots: float = MarketingSystem.ad_slots(r)
	tag.tooltip_text = tr("MKT_SATURATION_TIP_SEARCH" if r.kind == "search_ads" else "MKT_SATURATION_TIP").format(
		{"cat": cat, "pool": Fmt.number(slots), "shown": Fmt.number(slots * share)})
	tag.mouse_filter = Control.MOUSE_FILTER_STOP
	return tag


## The last weeks' leads as small bars, the tallest week full height.
func _bars(hist: Array) -> HBoxContainer:
	var bars := HBoxContainer.new()
	bars.add_theme_constant_override("separation", UiTokens.SPACE_XS)
	var top: int = maxi(1, hist.reduce(func(a: int, b: int) -> int: return maxi(a, b), 0))
	for n in hist:
		var bar := HRUiShared.D_bar(Vector2i(UiTokens.SPACE_M, UiTokens.D_ICON_LINE), 1.0, UiTokens.D_INK_3)
		bar.custom_minimum_size.y = maxi(UiTokens.D_LOAD_BAR.y, roundi(UiTokens.D_ICON_LINE * float(n) / top))
		bar.size_flags_vertical = Control.SIZE_SHRINK_END
		bars.add_child(bar)
	return bars


func _open_runner_menu(r: Dictionary, anchor: Button) -> void:
	var pop: HRPopover = HRPopover.mount(anchor, true)
	pop.body().add_theme_constant_override("separation", 0)
	for c: Character in MarketingSystem.runners():
		var full: bool = c.category == "founder" and MarketingSystem.load_pct(c.id) >= 100   # the founder's share is spent
		_menu_item(pop, _who(c) + SprintUiShared.SEP + Fmt.percent(MarketingSystem.load_pct(c.id), 0),
			c.id == String(r.runner) or full, func() -> void: MarketingSystem.set_runner(int(r.id), c.id))
	pop.body().add_child(HSeparator.new())
	_menu_item(pop, tr("MKT_CLOSE_ROW"), false, func() -> void: MarketingSystem.remove_row(int(r.id)))
	pop.open_at(anchor, true, true)


## Kanal ekle: each channel the company does not run yet (Hedef sektör once per buyer sector); the new row starts at budget 0
## with the least loaded person who can take it.
func _open_add_menu(anchor: Button) -> void:
	var pop: HRPopover = HRPopover.mount(anchor, true)
	pop.body().add_theme_constant_override("separation", 0)
	for pair: Array in MarketingSystem.addable():
		_menu_item(pop, MarketingSystem.row_label({"kind": pair[0], "target": pair[1]}), false,
			func() -> void: MarketingSystem.add_row(pair[0], pair[1], MarketingSystem.free_runner()))
	pop.open_at(anchor, true, true)


func _menu_item(pop: HRPopover, text: String, shut: bool, act: Callable) -> void:
	var item := Button.new()
	item.theme_type_variation = &"MenuItem"
	item.focus_mode = Control.FOCUS_NONE
	item.text = text
	item.disabled = shut
	item.custom_minimum_size.y = UiTokens.D_H_MENU_ITEM
	item.pressed.connect(func() -> void:
		act.call()
		pop.close()
		_refresh())
	pop.body().add_child(item)


## The page's condition, in the empty body: the same as the Product overview's, a channel brings leads once v1.0 ships.
func _paint_empty() -> void:
	UiFactory.clear(_empty)
	var glyph := UiFactory.make_glyph(EMPTY_GLYPH, UiTokens.D_ICON_EMPTY, UiTokens.D_INK_4)
	glyph.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_empty.add_child(glyph)
	var key: String = "PRODUCT_OV_LOCKED"
	match ProductState.subtype():
		"note_tool", "video_clip":
			key = "MKT_NEEDS_ERP"
	var why := UiFactory.make_label(tr(key), &"NoteMuted")
	why.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_empty.add_child(why)


## A person as the page names them: the founder by role, everyone else by name.
func _who(c: Character) -> String:
	return tr("HR_ROLE_FOUNDER") if c.category == "founder" else c.character_name


func _cell(text: String, width: int) -> Label:
	var cell := UiFactory.make_label(text, &"DataText")
	cell.custom_minimum_size.x = width
	return cell


func _card(look: StringName, content: Control) -> PanelContainer:
	var card := PanelContainer.new()
	card.theme_type_variation = look
	card.add_child(content)
	return card


## A name and its stars; stars below 0 leave the stars out (the founder's share is not a skill).
func _name_row(text: String, look: StringName, stars: float) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", UiTokens.SPACE_M)
	row.add_child(UiFactory.make_label(text, look))
	if stars >= 0.0:
		row.add_child(UiFactory.D_stars(stars))
	return row


func _line(text: String, look: StringName) -> Label:
	var line := UiFactory.make_label(text, look)
	line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	line.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return line


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
