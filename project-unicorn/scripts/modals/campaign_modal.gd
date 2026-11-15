extends "res://scripts/tabs/hr/hr_panel.gd"

# ============================================================================
# Kampanya kur (PRD_PAZARLAMA §5 K1 ile K3): solda şablonlar (seçili kart yükselir, sol kenarında işaret), ortada seçili şablonun
# ayarları, "İndirimi kim karşılar" ve yürüten, sağda Beklenen kartı; her değişiklikte ve her hafta yeniden çizilir (saat panel açıkken
# de akar). Beklenen, MarketingSystem.preview'ın sayılarını aralık olarak yazar: aralık geçmiş kampanyalar çoğaldıkça daralır. Altında
# yürütenin hazırlıktaki yükü. "Kampanyayı başlat" planı MarketingSystem.start_campaign'e verir; panel durumu kendisi yazmaz
# (WRITE-THROUGH LAW). PanelLayer'da yaşar: ModalLayer hız tuşlarını yutuyor.
# ============================================================================

const MarketingSystem := preload("res://scripts/systems/marketing_system.gd")
const MpParts := preload("res://scripts/tabs/marketplace/mp_parts.gd")
const WIDTH := 1180
const W_TEMPLATES := 244
const W_EXPECT := 380
const CHEVRON := "res://assets/icons/util/chevron_down.svg"
## How many of a category's stores join, in words: the first bound the share stays under (none is a share of 0).
const JOIN_WORDS := [[0.25, "MKT_JOIN_FEW"], [0.6, "MKT_JOIN_HALF"], [0.95, "MKT_JOIN_MOST"], [INF, "MKT_JOIN_ALL"]]

var _kind: String = ""
var _window: String = ""
var _settings: Dictionary = {}
var _payer: String = ""
var _runner: String = ""


## The host adds the panel first, then calls this; it opens on the first template.
func populate() -> void:
	title.add_child(UiFactory.make_label(tr("MKT_CAMPAIGN_NEW"), &"TitleH2"))
	EventBus.day_tick_completed.connect(_on_week)
	_pick((MarketingSystem.cfg("campaigns.templates") as Dictionary).keys()[0])


## A week passed under the panel: the preview, the windows and the loads moved with it.
func _on_week(_day: int) -> void:
	_rebuild()


## A template with its defaults: each setting's default value and the template's payer.
func _pick(kind: String) -> void:
	var tpl: Dictionary = MarketingSystem.cfg("campaigns.templates." + kind)
	_kind = kind
	_payer = tpl.payer
	_settings = {}
	for key: String in ["depth", "weeks", "amount", "count"]:
		if tpl.get(key) is Array:
			_settings[key] = int(tpl[key][2])
	if tpl.has("shipping"):
		_settings.shipping = tpl.shipping[0]
	if tpl.has("ratio"):
		_settings.ratio = tpl.ratio.keys()[0]
	_rebuild()


func _rebuild() -> void:
	clear()
	var tpl: Dictionary = MarketingSystem.cfg("campaigns.templates." + _kind)
	var ahead: Array = _windows()
	# None picked yet, or a week passed and the window went by: the soonest calendar window (Hemen is the exception, not the rule).
	if not ahead.any(func(w: Dictionary) -> bool: return w.id == _window):
		_window = ahead[1].id
	# None picked yet, or the one picked left the job or filled their share: the person a new row would go to.
	if not MarketingSystem.runners().any(func(c: Character) -> bool: return c.id == _runner and _can_take(c)):
		_runner = MarketingSystem.free_runner()
	var cols := HBoxContainer.new()
	cols.add_theme_constant_override("separation", UiTokens.SPACE_3XL)
	var list := VBoxContainer.new()
	list.custom_minimum_size.x = W_TEMPLATES
	list.add_theme_constant_override("separation", UiTokens.SPACE_M)
	for kind: String in MarketingSystem.cfg("campaigns.templates"):
		list.add_child(_template_card(kind))
	cols.add_child(list)
	var mid := VBoxContainer.new()
	mid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mid.add_theme_constant_override("separation", UiTokens.SPACE_XL)
	if bool(tpl.windowed):
		var now: Dictionary = ahead.filter(func(w: Dictionary) -> bool: return w.id == _window)[0]
		mid.add_child(_setting("MKT_SET_WINDOW", _menu_pick(_window_text(now), ahead.map(func(w: Dictionary) -> Array:
			return [_window_text(w), w.id == _window, w.id]), func(id: String) -> void: _window = id)))
	match _kind:
		"first_order":
			mid.add_child(_setting("MKT_SET_DEPTH", _stepper("depth", tpl.depth, Fmt.percent(_settings.depth, 0))))
			mid.add_child(_setting("MKT_SET_WEEKS", _seg(range(int(tpl.weeks[0]), int(tpl.weeks[1]) + 1), _settings.weeks,
				func(n: int) -> String: return Fmt.weeks(n), func(n: int) -> void: _settings.weeks = n)))
		"discount_days":
			mid.add_child(_setting("MKT_SET_DEPTH", _stepper("depth", tpl.depth, Fmt.percent(_settings.depth, 0))))
			mid.add_child(_setting("MKT_SET_SHIPPING", _seg(tpl.shipping, _settings.shipping,
				func(v: String) -> String: return tr("MKT_SHIPPING_" + v.to_upper()), func(v: String) -> void: _settings.shipping = v)))
		"buy_x_pay_y":
			mid.add_child(_setting("MKT_SET_RATIO", _seg(tpl.ratio.keys(), _settings.ratio,
				func(v: String) -> String: return tr("MKT_RATIO_" + v), func(v: String) -> void: _settings.ratio = v)))
		"coupon":
			mid.add_child(_setting("MKT_SET_AMOUNT", _stepper("amount", tpl.amount, Fmt.money_exact(_settings.amount))))
			mid.add_child(_setting("MKT_SET_COUNT", _stepper("count", tpl.count, Fmt.group(_settings.count))))
	mid.add_child(_setting("MKT_SET_PAYER", _seg((MarketingSystem.cfg("campaigns.payers") as Dictionary).keys(), _payer,
		func(v: String) -> String: return tr("MKT_PAYER_" + v.to_upper()), func(v: String) -> void: _payer = v)))
	# YÜRÜTEN: the channel rows' person menu, each with their load; the founder is shut once their share is full.
	var people: Array = MarketingSystem.runners().map(func(c: Character) -> Array:
		return [_who(c) + SprintUiShared.SEP + Fmt.percent(MarketingSystem.load_pct(c.id), 0), c.id == _runner or not _can_take(c),
			c.id])
	var who: String = _who(CharacterRegistry.get_character(_runner)) if _runner != "" else tr("MKT_NEEDS_SPECIALIST")
	mid.add_child(_setting("MKT_SET_RUNNER", _menu_pick(who, people, func(id: String) -> void: _runner = id)))
	cols.add_child(mid)
	var right := VBoxContainer.new()
	right.custom_minimum_size.x = W_EXPECT
	right.add_theme_constant_override("separation", UiTokens.SPACE_L)
	_expect(right)
	cols.add_child(right)
	body.add_child(cols)
	foot.add_child(button(tr("UI_DISMISS"), &"SecondaryButton", close))
	foot.add_child(spring())
	foot.add_child(button(tr("MKT_CAMPAIGN_START"), &"PrimaryButtonDark", _start if _runner != "" else Callable()))
	seat(WIDTH)


## A template to pick, by name (the kampanya_kur frame picks its template by the card's name). Picked, it rises and carries the
## marker on its left edge.
func _template_card(kind: String) -> PanelContainer:
	var picked: bool = kind == _kind
	var card := PanelContainer.new()
	card.name = kind
	card.theme_type_variation = &"PickCardSelected" if picked else &"PickCard"
	var marks := Control.new()
	marks.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if picked:
		marks.add_child(HRUiShared.D_mark())
	card.add_child(marks)
	var pad := MarginContainer.new()
	for side: String in ["left", "right"]:
		pad.add_theme_constant_override("margin_" + side, UiTokens.SPACE_XL)
	for side: String in ["top", "bottom"]:
		pad.add_theme_constant_override("margin_" + side, UiTokens.SPACE_L)
	pad.add_child(UiFactory.make_label(tr("MKT_TEMPLATE_" + kind.to_upper()), &"DataStrong"))
	HRUiShared.set_mouse_ignore(pad)
	card.add_child(pad)
	if not picked:
		card.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		card.mouse_entered.connect(func() -> void: card.theme_type_variation = &"PickCardHover")
		card.mouse_exited.connect(func() -> void: card.theme_type_variation = &"PickCard")
		card.gui_input.connect(func(ev: InputEvent) -> void:
			if UiFactory.is_left_click(ev):
				_pick(kind))
	return card


## A setting: its caps key over its control.
func _setting(key: String, control: Control) -> VBoxContainer:
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", UiTokens.SPACE_S)
	col.add_child(UiFactory.make_label(Fmt.upper(tr(key)), &"KeyLabel"))
	control.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	col.add_child(control)
	return col


## A stepper over the setting's [min, max, default] by its least value (5% of a discount, $5 of a coupon, 100 coupons).
func _stepper(key: String, bounds: Array, text: String) -> PanelContainer:
	var v: int = _settings[key]
	var low: int = int(bounds[0])
	var high: int = int(bounds[1])
	return MpParts.stepper(text, "", v > low, v < high, func(dir: int) -> void:
		_settings[key] = clampi(v + dir * low, low, high)
		_rebuild())


## A pick of `values`, the one in force `now`; each named by `name`, and a press hands its value to `choose`.
func _seg(values: Array, now: Variant, name: Callable, choose: Callable) -> PanelContainer:
	return UiFactory.D_seg_pick(values.map(func(v: Variant) -> Dictionary: return {"text": name.call(v)}), values.find(now),
		func(i: int) -> void:
			choose.call(values[i])
			_rebuild())


## The windows a windowed campaign can take, each once (its next occurrence), Hemen first.
func _windows() -> Array:
	var seen := {}
	return MarketingSystem.windows_ahead().filter(func(w: Dictionary) -> bool:
		if seen.has(w.id):
			return false
		seen[w.id] = true
		return true)


## A pick that names the choice in force and lists the choices under it on a press: `items` are [text, shut, value], and the
## one picked hands its value to `choose`.
func _menu_pick(text: String, items: Array, choose: Callable) -> Button:
	var pick := Button.new()
	pick.theme_type_variation = &"SecondaryButtonSmall"
	pick.focus_mode = Control.FOCUS_NONE   # Space is the speed key
	pick.text = text
	pick.icon = load(CHEVRON)
	pick.icon_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	pick.pressed.connect(func() -> void:
		var pop: HRPopover = HRPopover.mount(pick, true)
		pop.body().add_theme_constant_override("separation", 0)
		for it: Array in items:
			var item := button(it[0], &"MenuItem", func() -> void:
				choose.call(it[2])
				pop.close()
				_rebuild())
			item.custom_minimum_size.y = UiTokens.D_H_MENU_ITEM
			item.disabled = it[1]
			pop.body().add_child(item)
		pop.open_at(pick, true, true))
	return pick


func _window_text(w: Dictionary) -> String:
	return tr("MKT_WINDOW_" + String(w.id).to_upper()) + SprintUiShared.SEP + MarketingSystem.window_dates(int(w.start), int(w.weeks))


## Whether `c` can take the campaign: anyone on the Marketing job, the founder while their share has room.
func _can_take(c: Character) -> bool:
	return c.category != "founder" or MarketingSystem.load_pct(c.id) < 100


## A person as the page names them: the founder by role, everyone else by name.
func _who(c: Character) -> String:
	return tr("HR_ROLE_FOUNDER") if c.category == "founder" else c.character_name


## BEKLENEN: the plan's figures over the preview's horizon, each a range of value × (1 ∓ s) with s = expect_spread ÷ √(1 + n), n the
## campaigns behind the company, so the range narrows as they add up; per category how many stores join and whether they lose. Under
## it the runner's load once the preparation starts, in the warning tone past a full week.
func _expect(col: VBoxContainer) -> void:
	var n: int = (GameState.marketing.get("history", []) as Array).size()
	var pv: Dictionary = MarketingSystem.preview(_kind, _window, _settings, _payer)
	var s: float = float(MarketingSystem.cfg("campaigns.expect_spread")) / sqrt(1.0 + n)
	var card: VBoxContainer = UiFactory.D_card(col)
	card.add_child(UiFactory.D_card_head(tr(Fmt.count_key("MKT_EXPECT_HEAD", n)).format({"n": n}) if n > 0
		else tr("MKT_EXPECT_FIRST")))
	var users: float = float(pv.new_users)
	var money := func(v: float) -> String: return Fmt.money_exact(roundi(v))
	card.add_child(_figure("MKT_COL_NEW_USERS", _range(users, s, func(v: float) -> String: return Fmt.group(roundi(v)))))
	card.add_child(_figure("MKT_COL_PER_USER", _range(float(pv.cost) / users, s, money) if users >= 0.5 else ""))
	var mrr: float = float(pv.mrr)
	card.add_child(_figure("MKT_COL_MRR", _range(mrr, s, func(v: float) -> String: return ("+" if v > 0.0 else "") + money.call(v)),
		UiTokens.D_pos() if mrr > 0.0 else null))
	card.add_child(HSeparator.new())
	var net: float = float(pv.net)
	card.add_child(UiFactory.make_label(tr("MKT_EXPECT_NET").format({"span": Fmt.weeks(int(MarketingSystem.cfg("campaigns.horizon")))}),
		&"Caption"))
	card.add_child(UiFactory.make_label(_range(net, s, money), &"KpiValue",
		UiTokens.D_warn() if net < 0.0 else (UiTokens.D_pos() if net > 0.0 else null)))
	card.add_child(HSeparator.new())
	for cat: String in pv.joined:
		var share: float = float(pv.joined[cat])
		var key: String = "MKT_JOIN_NONE" if share <= 0.0 else JOIN_WORDS.filter(func(w: Array) -> bool: return share < w[0])[0][1]
		var line := UiFactory.make_label(tr(key).format({"cat": tr("MP_CAT_" + cat.to_upper())}), &"DataText")
		line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		card.add_child(line)
		if float(pv.store_gain[cat]) < float(MarketplaceModel.cfg("campaign.loss_below")):
			card.add_child(UiFactory.make_label(tr("MKT_JOIN_LOSS"), &"Caption", UiTokens.D_warn()))
	if _runner == "":
		return
	var c: Character = CharacterRegistry.get_character(_runner)
	var now: int = MarketingSystem.load_pct(_runner)
	# The founder has only founder_share_pct of a week for Marketing, so the preparation weighs on them in that proportion.
	var after: int = now + roundi(float(MarketingSystem.cfg("campaigns.prep_load_pct")) * 100.0
		/ (float(MarketingSystem.cfg("founder_share_pct")) if c.category == "founder" else 100.0))
	col.add_child(UiFactory.D_tag(tr("MKT_EXPECT_LOAD").format({"name": _who(c), "from": Fmt.percent(now, 0),
		"to": Fmt.percent(after, 0)}), &"warn" if after > 100 else &"neutral"))


## A figure of the card: its name, and its range at the right in `ink` (null: the look's own).
func _figure(key: String, text: String, ink: Variant = null) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", UiTokens.SPACE_M)
	var label := UiFactory.make_label(tr(key), &"Caption")
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(label)
	row.add_child(UiFactory.make_label(text, &"DataStrong", ink))
	return row


## A figure's range, value × (1 ∓ s), the lower end first, each end written by `write`.
func _range(v: float, s: float, write: Callable) -> String:
	var ends: Array = [v * (1.0 - s), v * (1.0 + s)]
	ends.sort()
	return tr("MKT_RANGE").format({"low": write.call(ends[0]), "high": write.call(ends[1])})


## A refused start (the week moved under the panel: a window went by, the runner's share filled) draws the panel again on today.
func _start() -> void:
	if MarketingSystem.start_campaign(_kind, _window, _settings, _payer, _runner):
		state_changed.emit()
		close()
	else:
		_rebuild()
