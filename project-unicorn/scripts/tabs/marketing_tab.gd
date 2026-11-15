extends Control

# ============================================================================
# Pazarlama penceresi (PRD_PAZARLAMA §5 ve §7, ERP içeriği). Koyu başlıkta Pazarlama ve dört ölçü (bu hafta aday,
# Satış'a giden, eşik altında, haftalık harcama); denetim şeridinde ekip (yükleriyle) ve devir eşiği. Gövdede kanal
# satırları (bütçe, haftalık aday, aday başı, MRR katkısı, yürüten), kanal ekle ve Satış'ın kendi akışı (Organik).
# ERP canlı değilken gövde tek boş hâldir ve şartını yazar.
#
# Sayfa durumu okur ve MarketingSystem'in kapılarını tetikler, kendisi yazmaz (WRITE-THROUGH LAW). Karar beklerken
# denetimleri kapalıdır. PROCESS_MODE_ALWAYS (.tscn): duraklatılmış düğüm çizilir ama tıklama almaz.
# ============================================================================

## The window grows with its rows (WindowLayer reads fit_height).
signal fit_changed

const MarketingSystem := preload("res://scripts/systems/marketing_system.gd")
const PLUS := "res://assets/icons/util/plus.svg"
const MINUS := "res://assets/icons/util/minus.svg"
const CHEVRON := "res://assets/icons/util/chevron_down.svg"
const EMPTY_GLYPH := "res://assets/icons/rail/marketing.svg"
const KIND_GLYPHS := {"content_seo": "res://assets/icons/util/doc.svg", "search_ads": "res://assets/icons/dept/marketing.svg",
	"referral": "res://assets/icons/dept/customer_success.svg", "target_sector": "res://assets/icons/util/flag.svg"}
const ORGANIC_GLYPH := "res://assets/icons/type/erp.svg"
## The handoff threshold's three positions, as MarketingSystem.HANDOFFS names them.
const HANDOFF_KEYS := ["MKT_HANDOFF_ALL", "MKT_HANDOFF_2", "MKT_HANDOFF_3"]
## Column widths of a channel row [name, budget, leads a week, per lead, MRR]; the runner takes the rest.
const W := [208, 152, 112, 112, 112]

var frame_options: Dictionary
var _kpis: Array = []   # leads this week, handed to Sales, under the threshold
var _kpi_slot: HBoxContainer
var _spend: Control
var _outer: VBoxContainer
var _ctl: PanelContainer
var _team: HBoxContainer
var _handoff: HBoxContainer
var _rows: VBoxContainer
var _empty: VBoxContainer
var _signals: Array = []


func _init() -> void:
	_kpi_slot = HBoxContainer.new()
	_kpi_slot.add_theme_constant_override("separation", 0)
	for key in ["MKT_KPI_LEADS", "MKT_KPI_HANDED", "MKT_KPI_BELOW"]:
		_kpis.append(UiFactory.D_kpi(tr(key), ""))
		_kpi_slot.add_child(_kpis.back())
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
	_rows = VBoxContainer.new()
	_rows.add_theme_constant_override("separation", UiTokens.SPACE_M)
	_rows.minimum_size_changed.connect(fit_changed.emit)
	stack.add_child(_rows)
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
	var open: bool = ProductState.is_live() and SalesFaucetSystem.market_open()
	var off: bool = EventGate.active_id() != ""
	_ctl.visible = open
	_rows.visible = open
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
		_paint_handoff(off)
		_paint_rows(off)
	else:
		_paint_empty()
	fit_changed.emit()


func _paint_kpis() -> void:
	var week: Dictionary = GameState.marketing.get("week", {})
	var spend: int = 0
	for r: Dictionary in MarketingSystem.rows():
		spend += int(r.budget)
	UiFactory.D_kpi_value(_kpis[0]).text = str(int(week.get("made", 0)))
	UiFactory.D_kpi_value(_kpis[1]).text = str(int(week.get("handed", 0)))
	UiFactory.D_kpi_value(_kpis[2]).text = str(MarketingSystem.nurture().size())
	# The spend's cell carries its cost glyph, so it is built with its value.
	_spend = UiFactory.D_kpi(tr("MKT_KPI_SPEND"), Fmt.money_exact(spend), true)
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
	for i in W.size():
		var cap := UiFactory.make_label(Fmt.upper(tr(["MKT_COL_CHANNELS", "MKT_COL_BUDGET", "MKT_COL_LEADS", "MKT_COL_PER_LEAD",
			"MKT_COL_MRR"][i])), &"KeyLabel")
		cap.custom_minimum_size.x = W[i]
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
	organic.add_child(UiFactory.make_glyph(ORGANIC_GLYPH, UiTokens.D_ICON_LINE, UiTokens.D_INK_3))
	organic.add_child(UiFactory.make_label(tr("SALES_SOURCE_ORGANIC"), &"DataText"))
	organic.add_child(UiFactory.make_label(tr("MKT_PER_WEEK").format({"n": Fmt.number(SalesFaucetSystem.lead_rate_per_week())}),
		&"DataStrong"))
	_rows.add_child(_card(&"DealDoc", organic))


## One channel: its name, the stars its leads usually are and its last four weeks of leads; the budget's − and +; its leads a
## week, what a lead costs and the MRR its signings bring; its runner, whose menu also closes the row.
func _row_card(r: Dictionary, off: bool) -> PanelContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 0)
	var name_col := VBoxContainer.new()
	name_col.custom_minimum_size.x = W[0]
	name_col.add_theme_constant_override("separation", UiTokens.SPACE_XS)
	var title := HBoxContainer.new()
	title.add_theme_constant_override("separation", UiTokens.SPACE_M)
	title.add_child(UiFactory.make_glyph(KIND_GLYPHS[r.kind], UiTokens.D_ICON_LINE, UiTokens.D_INK_3))
	title.add_child(_line(MarketingSystem.row_label(r), &"DataStrong"))
	name_col.add_child(title)
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
	var rate: float = MarketingSystem.leads_per_week(r)
	row.add_child(_cell(Fmt.number(rate), W[2]))
	row.add_child(_cell(Fmt.money_exact(roundi(int(r.budget) / rate)) if rate > 0.0 and int(r.budget) > 0 else "", W[3]))
	var mrr: int = MarketingSystem.row_mrr(r)
	# A channel with no signing yet reads $0, muted; per lead stays empty with no leads (it has no value then).
	var mrr_cell := _cell("+" + Fmt.money_exact(mrr) if mrr > 0 else Fmt.money_exact(0), W[4])
	if mrr > 0:
		mrr_cell.add_theme_color_override("font_color", UiTokens.D_pos())
	else:
		mrr_cell.theme_type_variation = &"NoteMuted"
	row.add_child(mrr_cell)
	var runner: Character = CharacterRegistry.get_character(String(r.runner))
	var pick := _button(_who(runner), off, CHEVRON)
	pick.size_flags_horizontal = Control.SIZE_EXPAND | Control.SIZE_SHRINK_END
	pick.icon_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	pick.pressed.connect(_open_runner_menu.bind(r, pick))
	row.add_child(pick)
	for part: Control in row.get_children():
		part.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	return _card(&"DealDoc", row)


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
