extends VBoxContainer

# Pazaryeri'nin Kategoriler sayfası: altı kategorinin listesi ve seçilenin paneli. Kapalı kategori sektörün iadesini ve "Kategoriyi
# aç"ı, açık kategori iadesini, satış hacmini, komisyonu ve mağaza kazanımını taşır; komisyon adım adım seçilir, dört hafta sonraki
# farkı çiplerde okunur, Uygula yazar; kazanımı kategoriye atanan kişiler getirir, seçici onları atar ya da değiştirir. Değerler
# saklanan durumdan ve modelin saf okuyucularından gelir; yazan yalnız sahibin seam'leridir.

const PARTS := preload("res://scripts/tabs/marketplace/mp_parts.gd")
const COL := 76

var _state: Dictionary
var _world: Dictionary
var _selected: String = MarketplaceModel.cat_ids()[0]
var _low: int = MarketplaceModel.cfg("commission.min")
var _high: int = MarketplaceModel.cfg("commission.max")
var _next := {}    # category -> the commission chosen and not applied yet
var _diffs := {}   # category -> `MarketplaceModel.preview_commission` of that choice, taken when the choice or the week changes
var _diff_week := -1   # the week `_diffs` were taken in


## The band a commission can sit in, as long as its column, from the scale's low end to its high end in three zones: comfortable
## (plain), strained (lightly hatched) and leaving (hatched in the warning colour); the two boundaries are written small and faint
## under it. Today's rate is a filled marker above the bar, the previewed rate a hollow one in the tone of the zone it enters.
class RangeBar extends Control:
	var band: Dictionary   # {low, high, comfy, strained, now, preview, zone}, percent; `zone` is where the preview stands

	func _init(range_band: Dictionary) -> void:
		band = range_band
		custom_minimum_size.y = UiTokens.SPACE_M + UiTokens.SPACE_XS + UiTokens.D_H_SHARE + UiTokens.SPACE_XXS + UiTokens.SPACE_XL
		size_flags_horizontal = Control.SIZE_EXPAND_FILL
		mouse_filter = Control.MOUSE_FILTER_STOP

	## A rate's x on the bar; a rate off the scale (a zone that starts below its low end) stands at the nearer end.
	func _at(rate: float) -> float:
		return size.x * clampf((rate - float(band.low)) / float(band.high - band.low), 0.0, 1.0)

	func _draw() -> void:
		var top: float = UiTokens.SPACE_M + UiTokens.SPACE_XS
		var comfy := Rect2(0.0, top, _at(band.comfy), UiTokens.D_H_SHARE)
		var strained := Rect2(comfy.end.x, top, _at(band.strained) - comfy.end.x, UiTokens.D_H_SHARE)
		var leaving := Rect2(strained.end.x, top, size.x - strained.end.x, UiTokens.D_H_SHARE)
		draw_rect(comfy, UiTokens.D_BAR_FILL)
		StagePaint.hatch(self, strained, UiTokens.D_BAR_TRACK, UiTokens.D_INK_4, UiTokens.D_HATCH)
		StagePaint.spill(self, leaving)
		_marker(band.now, true, UiTokens.D_INK_1)
		_marker(band.preview, false,
			{"comfortable": UiTokens.D_INK_1, "strained": UiTokens.D_INK_3, "leaving": UiTokens.D_warn()}[band.zone])
		_boundary_labels(top)

	## The two boundaries' rates, centred on their marks; two marks closer than a label is wide split their labels to either side of
	## them. A label stays inside the bar.
	func _boundary_labels(top: float) -> void:
		var font: Font = get_theme_font(&"font", &"CaptionFaint")
		var font_size: int = get_theme_font_size(&"font_size", &"CaptionFaint")
		var ink: Color = get_theme_color(&"font_color", &"CaptionFaint")
		var texts: Array = [Fmt.percent(float(band.comfy), 0), Fmt.percent(float(band.strained), 0)]
		var xs: Array = [_at(band.comfy), _at(band.strained)]
		var wides: Array = texts.map(func(t: String) -> float: return font.get_string_size(t, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x)
		var apart: bool = xs[1] - xs[0] >= maxf(wides[0], wides[1])
		for i in 2:
			var left: float = xs[i] - wides[i] / 2.0 if apart else (xs[i] - wides[i] if i == 0 else xs[i])
			draw_string(font, Vector2(clampf(left, 0.0, size.x - wides[i]),
				top + UiTokens.D_H_SHARE + UiTokens.SPACE_XXS + font.get_ascent(font_size)), texts[i], HORIZONTAL_ALIGNMENT_LEFT, -1,
				font_size, ink)

	func _marker(rate: float, filled: bool, ink: Color) -> void:
		var x: float = _at(rate)
		var half: float = UiTokens.SPACE_L / 2.0
		var tri := PackedVector2Array([Vector2(x - half, 0.0), Vector2(x + half, 0.0), Vector2(x, UiTokens.SPACE_M)])
		if filled:
			draw_colored_polygon(tri, ink)
		else:
			tri.append(tri[0])
			draw_polyline(tri, ink, UiTokens.BORDER_FOCUS, true)


## Reads the state again: a choice made and not applied keeps standing, its preview taken again when the week has turned.
func refresh() -> void:
	_state = MarketplaceSystem.read_state()
	_world = MarketplaceSystem.world()
	if _world.week != _diff_week:
		_diff_week = _world.week
		for cat: String in _next.keys():
			_preview(cat)
	_paint()


## The four-close preview of a category's choice. A choice that changes nothing, or that the lock refuses, has no preview and is
## dropped.
func _preview(cat: String) -> void:
	var diff := MarketplaceModel.preview_commission(_state, _world, cat, _next[cat])
	if diff.is_empty():
		_next.erase(cat)
		_diffs.erase(cat)
	else:
		_diffs[cat] = diff


func _paint() -> void:
	UiFactory.clear(self)
	var cols := SprintUiShared.box(UiTokens.SPACE_4XL)
	var list := SprintUiShared.column(UiTokens.SPACE_M)
	list.add_child(_head())
	for cat: String in MarketplaceModel.cat_ids():
		list.add_child(_row(cat))
	var pane := SprintUiShared.column(UiTokens.SPACE_XXL)
	pane.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	pane.add_child(_title())
	if _state.cats[_selected].open:
		_paint_open(pane)
	else:
		_paint_closed(pane)
	cols.add_child(list)
	cols.add_child(pane)
	add_child(cols)


# --- Liste ----------------------------------------------------------------------------------------------

func _head() -> PanelContainer:
	var head := PanelContainer.new()
	head.theme_type_variation = &"TableHead"
	var row := SprintUiShared.box(UiTokens.SPACE_M)
	var category := HRUiShared.D_head(tr("MP_COL_CATEGORY"), 0, HORIZONTAL_ALIGNMENT_LEFT)
	category.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(category)
	for key in ["MP_KPI_STORES", "MP_COL_ORDERS", "MP_COL_COMMISSION"]:
		row.add_child(HRUiShared.D_head(tr(key), COL, HORIZONTAL_ALIGNMENT_RIGHT))
	head.add_child(SprintUiShared.pad(row, Vector4i(UiTokens.SPACE_L, 0, UiTokens.SPACE_L, 0)))
	return head


## A category's row: its name and state, then its stores, orders and commission (blank while it is closed); the chosen row carries
## the mark. The row is named by its category.
func _row(cat: String) -> PanelContainer:
	var cs: Dictionary = _state.cats[cat]
	var row := HRUiShared.D_row(cat == _selected)
	row.name = cat
	row.custom_minimum_size.y = UiTokens.D_H_ROW_LG
	row.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	var line := SprintUiShared.box(UiTokens.SPACE_M)
	line.add_child(SprintUiShared.label(tr("MP_CAT_" + cat.to_upper()), &"DataStrong"))
	line.add_child(_state_tag(cs.open))
	line.add_child(RnDUiShared.spacer())
	var figures: Array = [Fmt.group(roundi(cs.stores)), Fmt.group(roundi(cs.week.get("delivered", 0.0))), Fmt.percent(cs.commission, 0)]
	for figure: String in figures:
		line.add_child(PARTS.cell(figure if cs.open else "", &"DataText", COL, HORIZONTAL_ALIGNMENT_RIGHT))
	var inset := SprintUiShared.pad(line, Vector4i(UiTokens.SPACE_L, 0, UiTokens.SPACE_L, 0))
	HRUiShared.set_mouse_ignore(inset)
	row.add_child(inset)
	row.gui_input.connect(func(event: InputEvent) -> void:
		if UiFactory.is_left_click(event) and _selected != cat:
			_selected = cat
			_paint())
	return row


func _state_tag(open: bool) -> Label:
	return UiFactory.D_tag(tr("MP_STATE_OPEN" if open else "MP_STATE_CLOSED"), &"pos" if open else &"outline")


# --- Panel ----------------------------------------------------------------------------------------------

func _title() -> HBoxContainer:
	var row := SprintUiShared.box(UiTokens.SPACE_L)
	row.add_child(SprintUiShared.label(tr("MP_CAT_" + _selected.to_upper()), &"NameTitle"))
	row.add_child(_state_tag(_state.cats[_selected].open))
	return row


## A measured figure: its caps key over the figure, and under it, faint, what it is measured against.
func _stat(key: String, value: String, against := "") -> VBoxContainer:
	var col := SprintUiShared.column(UiTokens.SPACE_XS)
	col.add_child(SprintUiShared.label(Fmt.upper(tr(key)), &"KeySmall"))
	col.add_child(SprintUiShared.label(value, &"CapFigure"))
	if against != "":
		col.add_child(SprintUiShared.label(against, &"CaptionFaint"))
	return col


func _sector_return() -> float:
	return MarketplaceModel.cat_def(_selected).sector_return * 100.0


## A closed category: the sector's return, the one fact there is, and the button that opens it. Opening cannot be undone, which the
## button's tip says before the press.
func _paint_closed(pane: VBoxContainer) -> void:
	pane.add_child(_stat("MP_RETURNS", Fmt.percent(_sector_return(), 0), tr("MP_SECTOR_AVERAGE_CAPTION")))
	var open := SprintUiShared.button(tr("MP_OPEN_CATEGORY"), &"PrimaryButtonDarkSmall",
		func() -> void: MarketplaceSystem.open_category(_selected))
	open.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	open.tooltip_text = tr("MP_TIP_OPEN_CATEGORY")
	pane.add_child(open)


## An open category: the two measured figures, the commission with the band the stores stand in and who brings the stores.
func _paint_open(pane: VBoxContainer) -> void:
	var delivered: float = _state.cats[_selected].week.get("delivered", 0.0)
	var stats := SprintUiShared.box(UiTokens.SPACE_XL)
	var returns := _stat("MP_RETURNS", Fmt.percent(MarketplaceModel.return_rate(_state, _world, _selected) * 100.0, 0),
		tr("MP_SECTOR_AVERAGE").format({"rate": Fmt.percent(_sector_return(), 0)}))
	var volume := _stat("MP_VOLUME", tr("MP_VOLUME_WEEK").format(
		{"amount": Fmt.money_round(roundi(delivered * MarketplaceModel.cat_def(_selected).basket))}))
	for cell: Control in [returns, volume]:
		cell.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		stats.add_child(cell)
	pane.add_child(stats)
	pane.add_child(_commission())
	pane.add_child(_acquisition())


## The commission: stepper and Apply on one row, the band under it and, once a choice differs from the rate in force, the results
## it would bring. While the rate stands locked the keys are closed and the lock row counts the weeks left.
func _commission() -> VBoxContainer:
	var cs: Dictionary = _state.cats[_selected]
	var lock_left := MarketplaceModel.lock_left(cs.commission_day, _world)
	var shown: int = _next.get(_selected, cs.commission)
	var changed: bool = shown != cs.commission
	var block := SprintUiShared.column(UiTokens.SPACE_M)
	block.add_child(SprintUiShared.section("MP_COL_COMMISSION"))
	var row := SprintUiShared.box(UiTokens.SPACE_L)
	row.add_child(PARTS.stepper(Fmt.percent(shown, 0), Fmt.percent(cs.commission, 0) if changed else "",
		lock_left == 0 and shown > _low, lock_left == 0 and shown < _high, _step))
	row.add_child(RnDUiShared.spacer())
	row.add_child(PARTS.apply_cell(lock_left if lock_left > 0 else int(MarketplaceModel.cfg("rules.lock_weeks")), changed, _apply))
	block.add_child(row)
	block.add_child(_range_bar(cs.commission, shown))
	if changed:
		block.add_child(_chips(_diffs[_selected]))
	return block


## The band of the chosen category; its tip names the zone the previewed rate stands in.
func _range_bar(now: int, shown: int) -> RangeBar:
	var limits := MarketplaceModel.zone_limits(_state, _world, _selected)
	var zone := MarketplaceModel.zone_at(_state, _world, _selected, shown)
	var bar := RangeBar.new({"low": _low, "high": _high, "comfy": limits.comfortable, "strained": limits.strained, "now": now,
		"preview": shown, "zone": zone})
	bar.tooltip_text = tr("MP_ZONE_" + zone.to_upper())
	return bar


## The four results of the choice, in order, each in the tone of its sign: store earnings and monthly revenue are better up, store
## prices and nothing else are better down, a figure that rounds to none is a plain fact.
func _chips(diff: Dictionary) -> HFlowContainer:
	var earnings := snappedf(diff.store_earnings * 100.0, 1.0)
	var prices := snappedf(diff.store_prices * 100.0, 0.1)
	var orders := snappedf(diff.orders, 0.1)
	var revenue := roundi(diff.monthly_revenue)
	return PARTS.chip_flow([
		PARTS.chip(tr("MP_CHIP_STORE_EARNINGS").format({"v": _signed(earnings, Fmt.percent(absf(earnings), 0))}),
			_tone(earnings, true), [tr("MP_TIP_STORE_EARNINGS"), tr("MP_TIP_PREVIEW")]),
		PARTS.chip(tr("MP_CHIP_STORE_PRICES").format({"v": _signed(prices, Fmt.percent(absf(prices), 1))}),
			_tone(prices, false), [tr("MP_TIP_PREVIEW")]),
		PARTS.chip(tr("MP_CHIP_ORDERS").format({"v": _signed(orders, PARTS.count(absf(orders)))}),
			_tone(orders, true), [tr("MP_TIP_PREVIEW")]),
		PARTS.chip(tr("MP_CHIP_REVENUE").format({"v": _signed(revenue, Fmt.money(absi(revenue)))}),
			_tone(revenue, true), [tr("MP_TIP_PREVIEW")])])


func _tone(change: float, higher_is_better: bool) -> StringName:
	if is_zero_approx(change):
		return &"fact"
	return &"gain" if (change > 0.0) == higher_is_better else &"cost"


## A magnitude with the sign of `value` in front; a zero has none.
func _signed(value: float, magnitude: String) -> String:
	return ("+" if value > 0.0 else "-" if value < 0.0 else "") + magnitude


# --- Mağaza kazanımı ------------------------------------------------------------------------------------

## The people who bring the category its stores, a row each, and under them the free slot. Before the launch there is one line
## saying when it starts.
func _acquisition() -> VBoxContainer:
	var block := SprintUiShared.column(UiTokens.SPACE_M)
	block.add_child(SprintUiShared.section("MP_ACQUISITION"))
	if not _world.published:
		block.add_child(SprintUiShared.label(
			tr("MP_ACQ_AFTER_LAUNCH").format({"version": SprintSystem.version_label(1)}), &"NoteMuted"))
		return block
	for member: Dictionary in MarketplaceModel.crew(_state, _world, _selected):
		block.add_child(_member(member))
	block.add_child(_free_slot())
	return block


## One person of the crew: face, name and role, Sales stars, what they bring and Change, which opens the picker for their place.
func _member(member: Dictionary) -> HBoxContainer:
	var c: Character = CharacterRegistry.get_character(member.person)
	var row := SprintUiShared.box(UiTokens.SPACE_L)
	row.name = member.person
	row.add_child(_who(c))
	row.add_child(UiFactory.D_stars(MarketplaceSystem.sales_stars(c)))
	row.add_child(_brings(c, member))
	row.add_child(RnDUiShared.spacer())
	row.add_child(SprintUiShared.button(tr("MP_ACQ_CHANGE"), &"SecondaryButtonSmall",
		func() -> void: _open_picker(row, member.person)))
	return row


## What a person brings: while not at work the leave or course tag the roster shows (research, which pauses the Sales job, the tag
## the sprint's capacity shows), "starts next week" until the assignment has been through a close, else the week's stores.
func _brings(c: Character, member: Dictionary) -> Control:
	if not member.working:
		var away: Array = HRUiShared.away_state(c)
		var row := SprintUiShared.box(UiTokens.SPACE_S)
		row.add_child(UiFactory.D_tag(Fmt.cap_first(tr("PRODUCT_AWAY_RESEARCH")) if away.is_empty() else away[0], &"neutral"))
		if not away.is_empty() and away[1] > 0:
			row.add_child(SprintUiShared.label(Fmt.weeks(away[1]), &"CondCaption"))
		return row
	return SprintUiShared.label(_per_week(member.weekly) if member.live else tr("MP_ACQ_NEXT_WEEK"), &"Caption")


## Face, name and role in a column as wide as the Ekip matrix's name column: the stars and figures after it line up row under row.
func _who(c: Character) -> HBoxContainer:
	var who := HRUiShared.D_who(c, UiTokens.D_AVATAR_ROW)
	who.custom_minimum_size.x = UiTokens.D_AVATAR_ROW + UiTokens.SPACE_L + HRAssignments.W[1]
	return who


func _per_week(stores: float) -> String:
	return tr(Fmt.count_key("MP_ACQ_PER_WEEK", 1 if is_equal_approx(stores, 1.0) else 0)).format({"n": PARTS.count(stores)})


## The free slot of the crew: a dashed box with its one word, which opens the picker.
func _free_slot() -> MarginContainer:
	var slot := MarginContainer.new()
	slot.name = "AssignSlot"
	slot.custom_minimum_size.y = UiTokens.D_H_ROW
	slot.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	var row := SprintUiShared.box(UiTokens.SPACE_M)
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_child(UiFactory.make_glyph(PARTS.ICON % "plus", UiTokens.D_ICON_ROW, UiTokens.D_INK_3))
	row.add_child(SprintUiShared.label(tr("MP_ACQ_ASSIGN"), &"DataMedium", UiTokens.D_INK_3))
	HRUiShared.set_mouse_ignore(row)
	slot.add_child(row)
	HRUiShared.D_dashed(slot)
	slot.gui_input.connect(func(event: InputEvent) -> void:
		if UiFactory.is_left_click(event):
			_open_picker(slot, ""))
	return slot


## The picker under `anchor`: who can take the category, each with what they would bring a week or why they cannot, and above
## them the one line every pick shares. `replaced` is the person a Change takes the place of, "" for the free slot.
func _open_picker(anchor: Control, replaced: String) -> void:
	var pop: HRPopover = HRPopover.mount(anchor, true)
	pop.body().custom_minimum_size.x = UiTokens.D_W_STEWARD_MENU
	pop.body().add_theme_constant_override("separation", 0)
	pop.body().add_child(SprintUiShared.pad(SprintUiShared.label(tr("MP_ACQ_FIRST_WEEK"), &"Caption"),
		Vector4i(UiTokens.SPACE_M, UiTokens.SPACE_S, UiTokens.SPACE_M, UiTokens.SPACE_S)))
	for c: Character in MarketplaceSystem.assignable():
		_option(pop, c, replaced)
	pop.open_at(anchor, true, true)


## A candidate's row: face, name, stars, the category they would leave and, at the end, the week's stores they would bring, or
## why they cannot take the category: already in it, or the job cap. Under the stores, faint, the cost of a pick that hands someone
## the Sales job beside another job.
func _option(pop: HRPopover, c: Character, replaced: String) -> void:
	var now: String = _state.assign.get(c.id, {}).get("cat", "")
	var why := ""
	if now == _selected:
		why = "MP_ACQ_HERE"
	elif MarketplaceSystem.at_job_cap(c):
		why = "HR_ASSIGN_JOB_CAP"
	var weekly: float = MarketplaceModel.acquisition_of(_state, _world, _selected, int(MarketplaceSystem.sales_stars(c)))
	var row := SprintUiShared.box(UiTokens.SPACE_L)
	var who := _who(c)
	var stars := UiFactory.D_stars(MarketplaceSystem.sales_stars(c))
	row.add_child(who)
	row.add_child(stars)
	if now != "" and why == "":
		row.add_child(UiFactory.D_tag(tr("MP_CAT_" + now.to_upper()), &"outline"))
	row.add_child(RnDUiShared.spacer())
	var right := SprintUiShared.column(0)
	var figure := SprintUiShared.label(tr(why) if why != "" else _per_week(weekly), &"Caption")
	figure.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	right.add_child(figure)
	if why == "" and HRConstants.JOB_SALES not in c.assigned_job_ids + c.paused_job_ids and not c.assigned_job_ids.is_empty():
		right.add_child(SprintUiShared.label(tr("MP_ACQ_TAKES_SALES"), &"CaptionFaint"))
	row.add_child(right)
	var item := Button.new()
	item.theme_type_variation = &"MenuItem"
	item.focus_mode = Control.FOCUS_NONE
	item.disabled = why != ""
	if item.disabled:
		who.modulate.a = UiTokens.D_AWAY_ALPHA
		stars.modulate.a = UiTokens.D_AWAY_ALPHA
	for part: Control in row.get_children():
		part.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	HRUiShared.set_mouse_ignore(row)
	row.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	row.offset_left = UiTokens.SPACE_M
	row.offset_right = -UiTokens.SPACE_M
	item.add_child(row)
	pop.body().add_child(item)
	# A button does not measure its children; the row is measured once it reads the menu's theme.
	item.custom_minimum_size = Vector2(row.get_combined_minimum_size().x + 2 * UiTokens.SPACE_M, UiTokens.D_H_ROW_LG)
	if not item.disabled:
		item.pressed.connect(func() -> void:
			pop.close()
			_assign(c.id, replaced))


## The pick takes the category, and the person it replaces leaves it.
func _assign(person: String, replaced: String) -> void:
	if MarketplaceSystem.assign(person, _selected) and replaced != "":
		MarketplaceSystem.unassign(replaced)


# --- Eylemler -------------------------------------------------------------------------------------------

## One point up or down; the four-close preview is taken here, on the press, not on every repaint. The keys close at the scale's ends
## and while the rate stands locked, so a press always moves the choice.
func _step(direction: int) -> void:
	var now: int = _state.cats[_selected].commission
	var next: int = int(_next.get(_selected, now)) + direction
	if next == now:
		_next.erase(_selected)
		_diffs.erase(_selected)
	else:
		_next[_selected] = next
		_preview(_selected)
	_paint()


## The owner's seam writes and announces; the page repaints from that announcement. A refused write keeps the choice.
func _apply() -> void:
	if MarketplaceSystem.set_commission(_selected, _next[_selected]):
		_next.erase(_selected)
		_diffs.erase(_selected)
