extends Control

# Piyasa penceresi: halka açık kataloğun sıralı listesi ve seçili şirketin rapor kartı. Hiçbir sayı burada
# hesaplanmaz: değerler MarketCatalog'un saf fonksiyonudur, oyuncunun değerlemesi GameState.get_valuation_m;
# sayfa yalnız okur ve çizer. Satır tıklaması kartı değiştirir, liste kapanmaz; ok tuşları odağı taşır, Enter
# seçer; karar beklerken de okunur (gate_reads). Sektörüm filtresi kataloğun sector_slots'unu okur, sektör
# kelimesine bakmaz. Oyuncunun sırası hiçbir yerde yazılmaz: oyuncu yalnız üçüncü karodadır.

const FILTERS := {"all": "PIYASA_FILTER_ALL", "tech": "PIYASA_FILTER_TECH", "fin": "PIYASA_FILTER_FIN",
	"mine": "PIYASA_FILTER_MINE"}
const RANGE_KEYS := ["PIYASA_RANGE_13W", "PIYASA_RANGE_1Y", "PIYASA_RANGE_5Y", "PIYASA_RANGE_ALL"]
const RANGE_13W := 0
const RANGE_1Y := 1
const RANGE_5Y := 2
const RANGE_WEEKS := [13, 52]
const EOY_ROWS := 4         # year ends on the card; the 5Y chart starts at the oldest of them
const FOUR_WEEKS := 4
const NEW_WEEKS := 4        # a listing is new (tag, no four-week figure) this long [ÇD]
const SHARE_FLOOR := 0.1    # under this share (per cent) the dial prints "<" and draws no arc [ÇD]
const CTX_FALLBACK := "PIYASA_CTX_2012"
const RISE := "▲ "
const DROP := "−"

## The window's head (WindowFrame reads it before the page is in the tree).
var frame_options: Dictionary
var _ctx: Label
var _week: int
var _rows: Array = []        # MarketCatalog.listed(_week), rank = index + 1
var _filter := "all"
var _selected := ""          # the card's company id
var _focus := -1             # the keyboard focus, an index into the shown rows
var _ring := false           # the focus ring shows after a key, not after a click
var _range := RANGE_5Y
var _tiles: HBoxContainer
var _chips: HBoxContainer
var _above: MarginContainer
var _below: MarginContainer
var _pending: MarginContainer
var _scroll: ScrollContainer
var _scroll_pad: MarginContainer
var _reveal := -1                # a row to scroll into view once the rows are laid out
var _list: VBoxContainer
var _card: VBoxContainer
var _chart: Control
var _chart_data: Dictionary = {}
var _signals: Array = []


func _init() -> void:
	_ctx = UiFactory.make_label("", &"BodyLabel", UiTokens.D_INK_3)
	_ctx.clip_text = true
	_ctx.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	frame_options = {"title": "TAB_PIYASA", "kpi": _ctx, "pad": Vector2i.ZERO}


func _ready() -> void:
	var root := SprintUiShared.column(0)
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(root)
	var strip := PanelContainer.new()
	strip.theme_type_variation = &"WinCtl"
	_tiles = SprintUiShared.box(UiTokens.SPACE_XL)
	strip.add_child(SprintUiShared.pad(_tiles, Vector4i(0, UiTokens.SPACE_XL, 0, UiTokens.SPACE_XL)))
	root.add_child(strip)
	var body := SprintUiShared.box(0)
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(body)
	body.add_child(_list_column())
	# The card scrolls under the wheel when the window is short (1536 logical); like the list, it shows no bar.
	var card := PanelContainer.new()
	card.theme_type_variation = &"MarketCard"
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var card_scroll := ScrollContainer.new()
	card_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	card_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER
	_card = SprintUiShared.column(0)
	_card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_card.size_flags_vertical = Control.SIZE_EXPAND_FILL
	card_scroll.add_child(_card)
	card.add_child(card_scroll)
	body.add_child(card)
	_signals = [EventBus.day_advanced, EventBus.equity_changed]
	for sig: Signal in _signals:
		sig.connect(_build)
	_build()


func _exit_tree() -> void:
	for sig: Signal in _signals:
		sig.disconnect(_build)


func _build(_a = null) -> void:
	_week = GameState.day
	_rows = MarketCatalog.listed(_week)
	if MarketCatalog.company(_selected).is_empty():
		_selected = String(_rows[0]["id"])
	var ctx_key: String = "PIYASA_CTX_%d" % int(GameState.get_date_dict().year)
	_ctx.text = tr(ctx_key if tr(ctx_key) != ctx_key else CTX_FALLBACK).format({"month": _month_year(_week)})
	# Sektörüm has nothing to show before the product type is picked (the placeholder type has no slots).
	_chips.get_child(FILTERS.keys().find("mine")).visible = not MarketCatalog.sector_slots(GameState.subgenre).is_empty()
	_build_tiles()
	_build_list()
	_build_card()


## Harness and chips: the list under one filter ("all", "tech", "fin", "mine").
func set_filter(filter: String) -> void:
	_filter = filter
	_focus = -1
	for i in _chips.get_child_count():
		_chips.get_child(i).theme_type_variation = &"ChipFilterOn" if FILTERS.keys()[i] == filter else &"ChipFilter"
	_build_list()


## Harness and rows: the card of one company; its row, if shown, is selected and scrolled into view.
func show_company(id: String) -> void:
	_selected = id
	_range = RANGE_13W if _is_new(MarketCatalog.company(id)) else RANGE_5Y
	for i in _list.get_child_count():
		var row: PanelContainer = _list.get_child(i)
		var here: bool = String(row.get_meta(&"id")) == id
		HRUiShared.D_select_row(row, here)
		if here:
			_reveal = i
	_update_notes.call_deferred()
	_build_card()


# --- Tiles --------------------------------------------------------------------------------------

func _build_tiles() -> void:
	UiFactory.clear(_tiles)
	# The list's four-week move reads the rows that were on it four weeks ago, so a listing does not count as growth.
	var before := 0.0
	var now := 0.0
	for c in _rows:
		if int(c["listed_week"]) <= maxi(_week - FOUR_WEEKS, 0):
			before += MarketCatalog.value(c, _week - FOUR_WEEKS)
			now += MarketCatalog.value(c, _week)
	var leader: Dictionary = _rows[0]
	_tiles.add_child(_tile("PIYASA_KPI_LIST_VALUE", Fmt.money_market(MarketCatalog.list_total(_week)),
		tr("PIYASA_KPI_LIST_DESC").format({"c": _rows.size()}), now / before - 1.0, MarketCatalog.list_series(_week)))
	_tiles.add_child(_tile("PIYASA_KPI_LEADER", Fmt.money_market(MarketCatalog.value(leader, _week)),
		tr("PIYASA_KPI_LEADER_DESC").format({"name": leader["name"], "sector": _sector(leader)}), _four_week(leader),
		MarketCatalog.series(leader, _week - MarketCatalog.TILE_WEEKS + 1, _week)))
	var valuation: float = GameState.get_valuation_m()
	var desc: String
	if valuation <= 0.0:
		desc = tr("PER_NO_VALUATION")
	elif GameState.run_valuation_m > 0:
		desc = tr("PIYASA_KPI_SERIES_A")
	else:
		desc = tr("PIYASA_KPI_POST_SEED").format({"month": _month_year(GameState.seed_closed_day)})
	_tiles.add_child(_tile("PIYASA_KPI_YOUR_VALUATION", Fmt.money_market(valuation) if valuation > 0.0 else "", desc, NAN, []))


## A raised tile: its caps key, its figure with the four-week move beside it, its description and 13 bars at
## the foot. No figure keeps the key and the foot where they are; no bars (the player's tile) leaves the foot bare.
func _tile(key: String, figure: String, desc: String, move: float, bars: Array) -> PanelContainer:
	var tile := PanelContainer.new()
	tile.theme_type_variation = &"MarketTile"
	tile.custom_minimum_size.y = UiTokens.D_H_MARKET_TILE
	tile.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var col := SprintUiShared.column(0)
	tile.add_child(col)
	col.add_child(UiFactory.make_label(Fmt.upper(tr(key)), &"KeyLabel"))
	var line := SprintUiShared.box(UiTokens.SPACE_L)
	line.add_child(UiFactory.make_label(figure, &"TileValue"))
	if not is_nan(move):
		line.add_child(_pct(move, &"DataMedium"))
	col.add_child(line)
	var gap := Control.new()
	gap.size_flags_vertical = Control.SIZE_EXPAND_FILL
	col.add_child(gap)
	var foot := SprintUiShared.box(UiTokens.SPACE_M)
	var note := UiFactory.make_label(desc, &"Caption")
	note.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	note.size_flags_vertical = Control.SIZE_SHRINK_END
	foot.add_child(note)
	if not bars.is_empty():
		foot.add_child(_bars(bars))
	col.add_child(foot)
	return tile


## 13 bars from the lowest to the highest of the series, the last in emphasis ink.
func _bars(values: Array) -> Control:
	var bar: Vector2i = UiTokens.D_MARKET_BAR
	var heights: Vector2i = UiTokens.D_MARKET_BAR_H
	var box := Control.new()
	box.custom_minimum_size = Vector2(values.size() * bar.x + (values.size() - 1) * bar.y, heights.y)
	box.size_flags_vertical = Control.SIZE_SHRINK_END
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.draw.connect(func() -> void:
		var lo: float = values.min()
		var span: float = maxf(values.max() - lo, 1e-9)
		for i in values.size():
			var h: float = heights.x + (values[i] - lo) / span * (heights.y - heights.x)
			box.draw_rect(Rect2(i * (bar.x + bar.y), box.size.y - h, bar.x, h),
				UiTokens.D_INK_1 if i == values.size() - 1 else UiTokens.D_INK_3))
	return box


# --- List ---------------------------------------------------------------------------------------

func _list_column() -> Control:
	var col := SprintUiShared.column(0)
	col.custom_minimum_size.x = UiTokens.D_W_MARKET_LIST
	_chips = SprintUiShared.box(UiTokens.SPACE_M)
	for filter: String in FILTERS:
		var chip := SprintUiShared.button(tr(FILTERS[filter]), &"ChipFilter", set_filter.bind(filter))
		chip.set_meta(&"gate_reads", true)
		_chips.add_child(chip)
	_chips.get_child(0).theme_type_variation = &"ChipFilterOn"
	col.add_child(SprintUiShared.pad(_chips, Vector4i(0, 0, 0, UiTokens.SPACE_L)))
	_above = _note_line()
	col.add_child(_above)
	# The rows scroll under the wheel; the lines above and below say how many are out of sight.
	_scroll = ScrollContainer.new()
	_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER
	_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_scroll.focus_mode = Control.FOCUS_ALL
	_scroll.gui_input.connect(_on_list_key)
	_scroll.focus_entered.connect(_redraw_rows)
	_scroll.focus_exited.connect(_redraw_rows)
	_scroll.get_v_scroll_bar().value_changed.connect(_update_notes.unbind(1))
	_list = SprintUiShared.column(0)
	_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_scroll.add_child(_list)
	# The scroll never asks for height (a short window must be able to shrink it); the wrapper's bottom margin
	# takes what is left under the last whole row.
	_scroll_pad = SprintUiShared.pad(_scroll, Vector4i.ZERO)
	_scroll_pad.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_scroll_pad.resized.connect(_update_notes)
	col.add_child(_scroll_pad)
	_below = _note_line()
	col.add_child(_below)
	_pending = _note_line()
	col.add_child(_pending)
	return SprintUiShared.pad(col, Vector4i(UiTokens.SPACE_3XL, UiTokens.SPACE_XL, UiTokens.SPACE_XL, 0))


func _note_line() -> MarginContainer:
	var line := UiFactory.make_label("", &"Caption")
	line.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	line.custom_minimum_size.y = UiTokens.D_H_MARKET_NOTE
	var pad := SprintUiShared.pad(line, Vector4i(UiTokens.SPACE_M, 0, 0, 0))
	pad.visible = false
	return pad


func _note_text(line: MarginContainer, text: String) -> void:
	line.visible = text != ""
	(line.get_child(0) as Label).text = text


func _build_list() -> void:
	UiFactory.clear(_list)
	var mine: Array = MarketCatalog.sector_slots(GameState.subgenre)
	var shown := 0
	for i in _rows.size():
		var c: Dictionary = _rows[i]
		if _filter == "all" or (_filter == "mine" and c["id"] in mine) or String(c["group"]) == _filter:
			_list.add_child(_row(c, i + 1, shown))
			shown += 1
	# The sector's company that has not listed yet, named under the list.
	var pending := ""
	if _filter == "mine":
		for id in mine:
			var c: Dictionary = MarketCatalog.company(id)
			if String(c["status"]) == "public" and int(c["listed_week"]) > _week:
				pending = tr("PIYASA_LISTS_IN").format({"name": c["name"], "month": _month_year(int(c["listed_week"]))})
	_note_text(_pending, pending)
	_update_notes.call_deferred()


## A row: rank · name over its sector · price · value. The first three rows read larger; a listing of the last
## weeks carries the New tag. A click picks it for the card and takes the keyboard focus to the list.
func _row(c: Dictionary, rank: int, index: int) -> PanelContainer:
	var id := String(c["id"])
	var top: bool = rank <= 3
	var cols: Vector3i = UiTokens.D_W_MARKET_COLS
	var row := HRUiShared.D_row(id == _selected)
	row.custom_minimum_size.y = UiTokens.D_H_MARKET_ROW
	row.set_meta(&"id", id)
	row.set_meta(&"gate_reads", true)
	var grid := SprintUiShared.box(UiTokens.SPACE_M)
	var rank_label := UiFactory.make_label(str(rank), &"SmallMuted", UiTokens.D_INK_4)
	rank_label.custom_minimum_size.x = cols.x - UiTokens.SPACE_M
	grid.add_child(SprintUiShared.pad(rank_label, Vector4i(UiTokens.SPACE_M, 0, 0, 0)))
	var who := SprintUiShared.column(0)
	who.alignment = BoxContainer.ALIGNMENT_CENTER
	who.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var name_line := SprintUiShared.box(UiTokens.SPACE_M)
	name_line.add_child(UiFactory.make_label(String(c["name"]), &"ValueText" if top else &"DataStrong", UiTokens.D_INK_1))
	if _is_new(c):
		name_line.add_child(UiFactory.D_tag(tr("PIYASA_TAG_NEW"), &"neutral"))
	who.add_child(name_line)
	who.add_child(UiFactory.make_label(_sector(c), &"SmallMuted"))
	grid.add_child(who)
	var price := UiFactory.make_label(Fmt.price(MarketCatalog.price(c, _week)), &"DataText" if top else &"CaptionPrimary")
	price.custom_minimum_size.x = cols.y
	price.tooltip_text = tr("PIYASA_COL_PRICE")
	grid.add_child(price)
	var worth := UiFactory.make_label(Fmt.money_market(MarketCatalog.value(c, _week)), &"ValueText" if top else &"DataText",
		UiTokens.D_INK_1 if top else null)
	worth.custom_minimum_size.x = cols.z - UiTokens.SPACE_M
	worth.tooltip_text = tr("PIYASA_COL_VALUE")
	grid.add_child(SprintUiShared.pad(worth, Vector4i(0, 0, UiTokens.SPACE_M, 0)))
	for cell: Control in grid.get_children():
		cell.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	HRUiShared.set_mouse_ignore(grid)
	for figure: Label in [price, worth]:
		figure.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		figure.mouse_filter = Control.MOUSE_FILTER_PASS   # the column's name on hover: the list has no head
	row.add_child(grid)
	row.gui_input.connect(func(event: InputEvent) -> void:
		if UiFactory.is_left_click(event):
			_focus = index
			_ring = false
			_scroll.grab_focus()
			show_company(id))
	row.draw.connect(func() -> void:
		if _ring and _focus == index and _scroll.has_focus():
			row.draw_rect(Rect2(Vector2.ONE * UiTokens.SPACE_XXS, row.size - Vector2.ONE * 2 * UiTokens.SPACE_XXS),
				UiTokens.D_FOCUS, false, UiTokens.BORDER_FOCUS))
	return row


## Up and down move the focus ring, Enter picks the focused row for the card.
func _on_list_key(event: InputEvent) -> void:
	var count: int = _list.get_child_count()
	if count == 0 or not event.is_pressed():
		return
	if event.is_action(&"ui_down") or event.is_action(&"ui_up"):
		_focus = clampi(_focus + (1 if event.is_action(&"ui_down") else -1), 0, count - 1)
		_ring = true
		_reveal = _focus
		_update_notes()
		_redraw_rows()
		_scroll.accept_event()
	elif event.is_action(&"ui_accept") and _focus >= 0:
		show_company(String(_list.get_child(_focus).get_meta(&"id")))
		_scroll.accept_event()


func _redraw_rows() -> void:
	for row: Control in _list.get_children():
		row.queue_redraw()


## The list shows whole rows only: the wrapper's bottom margin takes the room under the last one, and the notes
## above and below say how many rows are out of sight. A row to reveal is scrolled into view here, once the
## rows have their room, and kept there while the notes settle.
func _update_notes() -> void:
	var row_h: int = UiTokens.D_H_MARKET_ROW
	var count: int = _list.get_child_count()
	var fit: int = floori(_scroll_pad.size.y / row_h)
	_scroll_pad.add_theme_constant_override("margin_bottom", int(_scroll_pad.size.y) - fit * row_h)
	if _reveal >= 0 and fit > 0:
		# Revealing a row past the first page scrolls, so the note above will take its line: fit as it will be then.
		if _reveal + 1 > fit and not _above.visible:
			fit = floori((_scroll_pad.size.y - UiTokens.D_H_MARKET_NOTE) / row_h)
		var want: int = clampi(int(_scroll.scroll_vertical), (_reveal + 1 - fit) * row_h, _reveal * row_h)
		if want == int(_scroll.scroll_vertical):
			_reveal = -1
		else:
			# Before the rows have their height the value clamps short; the pad's resize brings it back here.
			_scroll.scroll_vertical = want
			if int(_scroll.scroll_vertical) == want:
				return   # the value change calls back
	var top: float = _scroll.scroll_vertical
	var above: int = ceili(top / row_h)
	var below: int = maxi(count - floori((top + fit * row_h) / row_h), 0)
	_note_text(_above, tr("PIYASA_LIST_ABOVE").format({"c": above}) if above > 0 else "")
	_note_text(_below, tr("PIYASA_LIST_MORE").format({"c": below}) if below > 0 else "")


# --- Card ---------------------------------------------------------------------------------------

func _build_card() -> void:
	UiFactory.clear(_card)
	var c: Dictionary = MarketCatalog.company(_selected)
	var is_new: bool = _is_new(c)
	var value: float = MarketCatalog.value(c, _week)
	var head := SprintUiShared.box(UiTokens.SPACE_XL)
	head.add_child(UiFactory.make_label(String(c["name"]), &"DisplayName"))
	# The sector word as the catalogue writes it: a common noun in sentence case, an abbreviation in caps.
	var tag := UiFactory.make_label(_sector(c), &"TagOutline")
	tag.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	head.add_child(tag)
	var listed := UiFactory.make_label(tr("PIYASA_LISTED_YEAR").format(
		{"y": _month_year(int(c["listed_week"])) if is_new else str(int(c["ipo_year"]))}), &"Caption")
	listed.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	listed.size_flags_vertical = Control.SIZE_SHRINK_END
	listed.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	head.add_child(listed)
	_card.add_child(head)
	var people := SprintUiShared.box(UiTokens.SPACE_XL)
	for pair in [["PIYASA_FOUNDER_KEY", "founder_person_id"], ["PIYASA_CEO_KEY", "ceo_person_id"]]:
		var person: Dictionary = MarketCatalog.person(String(c[pair[1]]))
		if not person.is_empty():
			var who := SprintUiShared.box(UiTokens.SPACE_XS)
			who.add_child(UiFactory.make_label(tr(pair[0]), &"Caption"))
			who.add_child(UiFactory.make_label(String(person["name"]), &"CaptionStrong"))
			people.add_child(who)
	if people.get_child_count() == 0:
		people.add_child(UiFactory.make_label("", &"Caption"))   # the line stays when nobody is named
	_card.add_child(SprintUiShared.pad(people, Vector4i(0, UiTokens.SPACE_XXS, 0, 0)))

	var panes := SprintUiShared.box(0)
	panes.custom_minimum_size.y = UiTokens.D_H_MARKET_PANE
	var hero := SprintUiShared.column(0)
	hero.add_child(UiFactory.make_label(Fmt.money_market(value), &"HeroFigure"))
	hero.add_child(SprintUiShared.pad(UiFactory.make_label(tr("PIYASA_CARD_VALUE_DATE").format(
		{"month": _month_year(_week)}), &"Caption"), Vector4i(0, UiTokens.SPACE_XS, 0, 0)))
	var why := SprintUiShared.box(UiTokens.SPACE_S)
	why.add_child(UiFactory.make_label("", &"Caption"))   # the line stays while a listing has no four weeks
	if not is_new:
		why.add_child(_pct(_four_week(c), &"Caption"))
		why.add_child(UiFactory.make_label(tr("PIYASA_FOUR_WEEKS"), &"Caption"))
	hero.add_child(SprintUiShared.pad(why, Vector4i(0, UiTokens.SPACE_M, 0, 0)))
	panes.add_child(_pane(hero, true))
	panes.add_child(VSeparator.new())
	panes.add_child(_pane(_year_ends(c, value, is_new), false))
	panes.add_child(VSeparator.new())
	panes.add_child(_pane(_dial(MarketCatalog.share_of_list(c, _week) * 100.0), false))
	_card.add_child(SprintUiShared.pad(panes, Vector4i(0, UiTokens.SPACE_3XL, 0, 0)))

	var range_row := SprintUiShared.box(UiTokens.SPACE_L)
	range_row.custom_minimum_size.y = UiTokens.D_H_MARKET_RANGE
	var title := UiFactory.make_label(Fmt.upper(tr("PIYASA_VALUE_TITLE")), &"KeyLabel")
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	range_row.add_child(title)
	var tabs := UiFactory.D_seg_tabs(RANGE_KEYS.map(tr), _range, _set_range)
	for cell: Control in tabs.get_children():
		cell.get_child(0).set_meta(&"gate_reads", true)
	range_row.add_child(tabs)
	_card.add_child(SprintUiShared.pad(range_row, Vector4i(0, UiTokens.SPACE_3XL, 0, 0)))
	_card.add_child(HSeparator.new())
	_chart = Control.new()
	_chart.custom_minimum_size.y = UiTokens.D_H_MARKET_CHART
	_chart.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_chart.draw.connect(_draw_chart)
	_chart_data = _chart_series(c)
	_card.add_child(SprintUiShared.pad(_chart, Vector4i(0, UiTokens.SPACE_L, 0, 0)))
	var gap := Control.new()
	gap.custom_minimum_size.y = UiTokens.SPACE_3XL
	gap.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_card.add_child(gap)
	var about := SprintUiShared.box(UiTokens.SPACE_3XL)
	var key := UiFactory.make_label(Fmt.upper(tr("PIYASA_ABOUT_TITLE")), &"KeyLabel")
	key.custom_minimum_size.x = UiTokens.D_W_MARKET_KEY
	key.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	about.add_child(key)
	about.add_child(SprintUiShared.prose(tr("PIYASA_ABOUT_" + _selected.to_upper()), &"BodyLabel"))
	_card.add_child(about)


## A third of the panes row, its content centred on the height; the first pane starts at the card's edge.
func _pane(content: Control, first: bool) -> MarginContainer:
	content.alignment = BoxContainer.ALIGNMENT_CENTER
	var pane := SprintUiShared.pad(content, Vector4i(0 if first else UiTokens.SPACE_4XL, 0, UiTokens.SPACE_4XL, 0))
	pane.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return pane


## The last EOY_ROWS year ends as key:value rows, then the move since the oldest; a listing of this year has none.
func _year_ends(c: Dictionary, value: float, is_new: bool) -> VBoxContainer:
	var col := SprintUiShared.column(0)
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", UiTokens.SPACE_3XL)
	grid.add_theme_constant_override("v_separation", 0)
	col.add_child(grid)
	var ends: Dictionary = {} if is_new else MarketCatalog.year_end_values(c, int(GameState.get_date_dict().year) - 1, EOY_ROWS)
	var years: Array = ends.keys()
	years.sort()
	years.reverse()
	for i in years.size():
		grid.add_child(_kv_key(tr("PIYASA_EOY_FIRST").format({"y": years[i]}) if i == 0 else str(years[i])))
		grid.add_child(_kv_value(UiFactory.make_label(Fmt.money_market(ends[years[i]]), &"DataText")))
	if not years.is_empty():
		grid.add_child(_kv_key(tr("PIYASA_SINCE_EOY").format({"y": years[0]})))
		grid.add_child(_kv_value(_pct(value / ends[years[0]] - 1.0, &"DataText", 0)))
	return col


func _kv_key(text: String) -> Label:
	var key := UiFactory.make_label(text, &"Caption")
	key.custom_minimum_size.y = UiTokens.D_H_SHEET_ROW
	key.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	return key


func _kv_value(figure: Label) -> Label:
	figure.custom_minimum_size.y = UiTokens.D_H_SHEET_ROW
	figure.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	figure.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	figure.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return figure


## The half-circle dial: the share in ink-2 over an ink-4 rest, the figure inside, the key under it. Under
## SHARE_FLOOR the figure reads "<" and no arc is drawn: an arc that short is a dot and reads as a glitch.
func _dial(share: float) -> VBoxContainer:
	var col := SprintUiShared.column(UiTokens.SPACE_XS)
	var face := Control.new()
	face.custom_minimum_size = Vector2(UiTokens.D_MARKET_DIAL)
	face.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	face.mouse_filter = Control.MOUSE_FILTER_IGNORE
	face.draw.connect(func() -> void:
		var r: float = UiTokens.D_MARKET_DIAL_R
		var w: float = UiTokens.D_MARKET_DIAL_W
		var center := Vector2(face.size.x * 0.5, face.size.y - UiTokens.SPACE_XS)
		_arc(face, center, r, w, TAU, UiTokens.D_INK_4)
		var small: bool = share < SHARE_FLOOR
		if not small:
			_arc(face, center, r, w, PI + PI * share / 100.0, UiTokens.D_INK_2)
		# Whole per cents from 1 up; a decimal under it, so a drawn arc never reads "%0".
		var text: String = tr("PIYASA_SHARE_LT").format({"p": Fmt.percent(SHARE_FLOOR, 1)}) if small \
			else Fmt.percent(share, 0 if share >= 1.0 else 1)
		var font: Font = face.get_theme_font("font", &"KpiValue")
		var fs: int = face.get_theme_font_size("font_size", &"KpiValue")
		var width: float = font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
		face.draw_string(font, Vector2(center.x - width * 0.5, center.y - UiTokens.SPACE_S), text,
			HORIZONTAL_ALIGNMENT_LEFT, -1, fs, UiTokens.D_INK_1))
	col.add_child(face)
	var key := UiFactory.make_label(tr("PIYASA_SHARE"), &"Caption")
	key.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(key)
	return col


## An arc from the left end of the half circle to `to`, round-capped.
func _arc(on: CanvasItem, center: Vector2, r: float, w: float, to: float, color: Color) -> void:
	on.draw_arc(center, r, PI, to, 64, color, w, true)
	for angle in [PI, to]:
		on.draw_circle(center + Vector2.from_angle(angle) * r, w * 0.5, color, true, -1.0, true)


# --- Chart --------------------------------------------------------------------------------------

func _set_range(index: int) -> void:
	_range = index
	_chart_data = _chart_series(MarketCatalog.company(_selected))
	_chart.queue_redraw()


## The weekly values on the range and the marks on its axis. The axis spans the whole range; the line covers
## only the weeks since the listing, so a fresh listing is a short line at the right end with the listing mark
## at its start. Marks: the year ends on the range (the card's table reads the same ones), today at the end,
## and on the short ranges the first month when nothing else names the start.
func _chart_series(c: Dictionary) -> Dictionary:
	var year: int = int(GameState.get_date_dict().year)
	var axis_from: int
	match _range:
		RANGE_13W, RANGE_1Y:
			axis_from = _week - RANGE_WEEKS[_range] + 1
		RANGE_5Y:
			axis_from = MarketCatalog.week_at_year_end(year - EOY_ROWS)
		_:   # the oldest anchor, but not before the listing year: the year-end rows cut there too
			var oldest: int = (c["anchors"] as Dictionary).keys().map(func(k): return int(k)).min()
			axis_from = MarketCatalog.week_at_year_end(maxi(oldest, int(c["ipo_year"]) - 1))
	var listed: int = int(c["listed_week"])   # 0: listed before the run, so the line fills the axis
	var line_from: int = maxi(axis_from, listed) if listed > 0 else axis_from
	var marks: Array = []
	if listed > 0 and listed > axis_from and listed < _week:
		marks.append({"at": listed - axis_from, "text": tr("PIYASA_IPO_MARK"), "ink": UiTokens.D_INK_2, "start": true})
	elif _range <= RANGE_1Y:
		marks.append({"at": 0, "text": _month_year(axis_from), "ink": UiTokens.D_INK_3, "start": true})
	for y in range(int(GameState.get_date_dict(axis_from).year), year):
		var w: int = MarketCatalog.week_at_year_end(y)
		if w >= axis_from and w < _week:
			marks.append({"at": w - axis_from, "text": str(y), "ink": UiTokens.D_INK_3, "start": false})
	marks.append({"at": _week - axis_from, "text": _month_year(_week), "ink": UiTokens.D_INK_3, "start": false})
	marks.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return a.at < b.at)
	return {"values": MarketCatalog.series(c, line_from, _week), "span": _week - axis_from + 1,
		"offset": line_from - axis_from, "marks": marks}


func _draw_chart() -> void:
	var d: Dictionary = _chart_data
	var values: Array = d.values
	var font: Font = _chart.get_theme_font("font", &"SmallMuted")
	var fs: int = _chart.get_theme_font_size("font_size", &"SmallMuted")
	var pad: Vector4i = UiTokens.D_CHART_PAD
	var x0: float = pad.x
	var x1: float = _chart.size.x - pad.z
	var y1: float = _chart.size.y - pad.w
	var step: float = _grid_step(values.max())
	var top: float = ceilf(values.max() / step) * step
	var xa := func(at: int) -> float: return x0 + float(at) / float(maxi(d.span - 1, 1)) * (x1 - x0)
	var ya := func(v: float) -> float: return y1 - v / top * (y1 - pad.y)
	var mid: float = (font.get_ascent(fs) - font.get_descent(fs)) * 0.5
	var k := 0
	while k * step <= top + 0.5:
		var gy: float = ya.call(k * step)
		_chart.draw_line(Vector2(x0, gy), Vector2(x1, gy), UiTokens.D_CHART_AXIS if k == 0 else UiTokens.D_CHART_GRID)
		if k > 0:
			var figure: String = Fmt.money_market(k * step)
			_chart.draw_string(font, Vector2(x0 - UiTokens.SPACE_M - font.get_string_size(figure, HORIZONTAL_ALIGNMENT_LEFT,
				-1, fs).x, gy + mid), figure, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, UiTokens.D_INK_3)
		k += 1
	var pts := PackedVector2Array()
	for i in values.size():
		pts.append(Vector2(xa.call(i + d.offset), ya.call(values[i])))
	if pts.size() > 1:
		var area: PackedVector2Array = pts.duplicate()
		area.insert(0, Vector2(pts[0].x, y1))
		area.append(Vector2(pts[pts.size() - 1].x, y1))
		_chart.draw_colored_polygon(area, UiTokens.D_CHART_POS_AREA)
		_chart.draw_polyline(pts, UiTokens.D_CHART_LINE, UiTokens.D_CHART_STROKE, true)
	# The marks: a tick and its word under the axis; a year label close to today's ends at its own tick. Words
	# nearer than D_W_MARKET_LABEL to the one before are left out, so a long range keeps its axis legible.
	var marks: Array = d.marks
	var last_x: float = xa.call(marks[-1].at)
	var shown_x: float = -INF
	for i in marks.size():
		var m: Dictionary = marks[i]
		var x: float = xa.call(m.at)
		var last: bool = i == marks.size() - 1
		_chart.draw_line(Vector2(x, y1), Vector2(x, y1 + UiTokens.SPACE_XS), UiTokens.D_CHART_AXIS)
		var index: int = m.at - d.offset
		if index >= 0 and not last:
			_chart.draw_circle(pts[index], UiTokens.D_MARKET_ANCHOR + UiTokens.SPACE_XXS, UiTokens.D_SURFACE_2, true, -1.0, true)
			_chart.draw_circle(pts[index], UiTokens.D_MARKET_ANCHOR, UiTokens.D_INK_4, true, -1.0, true)
		if not last and x - shown_x < UiTokens.D_W_MARKET_LABEL and i > 0:
			continue
		var width: float = font.get_string_size(m.text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
		var left: float = x - width * 0.5
		if last:
			left = x - width
		elif m.start:
			left = x
		elif last_x - x < UiTokens.D_W_MARKET_LABEL:
			left = x - UiTokens.SPACE_XS - width
		_chart.draw_string(font, Vector2(left, _chart.size.y - UiTokens.SPACE_S), m.text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, m.ink)
		shown_x = x
	var dot: Vector2 = pts[pts.size() - 1]
	_chart.draw_circle(dot, UiTokens.D_CHART_DOT + UiTokens.D_CHART_HALO, UiTokens.D_SURFACE_2, true, -1.0, true)
	_chart.draw_circle(dot, UiTokens.D_CHART_DOT, UiTokens.D_INK_1, true, -1.0, true)


## The value axis's step: a half, one, two or five times a power of ten, at most four of them to the top.
static func _grid_step(hi: float) -> float:
	var base: float = pow(10.0, floorf(log(hi) / log(10.0)))
	for m in [0.5, 1.0, 2.0, 5.0]:
		if ceilf(hi / (m * base)) <= 4.0:
			return m * base
	return 10.0 * base


# --- Readers ------------------------------------------------------------------------------------

func _is_new(c: Dictionary) -> bool:
	return int(c["listed_week"]) > 0 and _week - int(c["listed_week"]) < NEW_WEEKS


func _four_week(c: Dictionary) -> float:
	return MarketCatalog.value(c, _week) / MarketCatalog.value(c, _week - FOUR_WEEKS) - 1.0


func _sector(c: Dictionary) -> String:
	return tr("PIYASA_SECTOR_" + String(c["sector_id"]).to_upper())


func _month_year(week: int) -> String:
	var d: Dictionary = GameState.get_date_dict(week)
	return tr("PIYASA_MONTH_YEAR").format({"month": Fmt.month_name(int(d.month)), "year": int(d.year)})


## A move as a share: a rise with the up glyph in the gain colour, a drop with the minus in ink (a drop is
## not danger); `decimals` 0 for the year table.
func _pct(ratio: float, variation: StringName, decimals := 1) -> Label:
	var up: bool = ratio >= 0.0
	var figure := UiFactory.make_label((RISE if up else DROP) + Fmt.percent(absf(ratio) * 100.0, decimals), variation,
		UiTokens.D_pos() if up else UiTokens.D_INK_2)
	figure.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	return figure
