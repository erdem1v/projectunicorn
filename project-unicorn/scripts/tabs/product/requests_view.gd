class_name RequestsView
extends HBoxContainer

## Ürün › Talepler: solda konular (B2B'de modül, isteyen, risk altındaki gelir, süre, durum, geciken; pazaryerinde bilet, haftada
## etkilenen sipariş, durum, geciken; çok konuda sıralama, süzgeç ve pazaryerinde taraf), sağda seçili konunun ayrıntısı (sayılar,
## pazaryerinde neden satırı, eylem, B2B'de isteyenler). Veri `ProductModel.topics()`; sıralama, süzgeç, taraf ve seçili konu sayfanın
## yerel durumudur (`ui.requests_*`).

signal action(kind: String, args: Dictionary)
signal ui_changed(key: String, value: Variant)

const CALENDAR := "res://assets/icons/util/calendar.svg"
## Pazaryeri penceresinin ortak parçaları: haftalık sipariş sayısı onun kuralıyla (`count`).
const MpParts := preload("res://scripts/tabs/marketplace/mp_parts.gd")
## Türün sıralamaları (ilki varsayılan) ve süzgeçleri.
const SORTS := {"b2b": ["count", "risk", "due"], "market": ["affected", "count"]}
const FILTERS := {"b2b": ["all", "waiting", "planned", "promised", "shipped"], "market": ["all", "waiting", "planned", "shipped"]}
const SIDES := ["all", "users", "stores"]
const SIDE_KEYS := {"all": "REQ_SIDE_ALL", "users": "MP_SIDE_USERS", "stores": "MP_SIDE_STORES"}
## Neden satırının adı, kartı olan konuların bağından: kullanıcı konusunda huninin adımı (`returning` bağı iadeyi ölçer, adı İade),
## mağaza konusunda dert.
const REASON_KEYS := {"cart": "MP_STEP_CART", "order": "MP_STEP_ORDER", "delivered": "MP_STEP_DELIVERED", "returning": "MP_RETURNS",
	"upload": "REQ_MP_ISSUE_UPLOAD"}
## Bu kadar konuya dek sıralama, süzgeç ve taraf görünmez (seçimleri de okunmaz).
const FEW := 3
## Liste sütunları: [başlık, en az genişlik, hizalama]; sondan ikincisi durum, sonuncusu geciken. Başlık ve satır genişliği `_widths`ten.
const COLUMNS := {"b2b": [["REQ_COL_COUNT", UiTokens.D_W_REQUEST_FIGURE, HORIZONTAL_ALIGNMENT_RIGHT],
	["REQ_COL_RISK", UiTokens.D_W_REQUEST_FIGURE, HORIZONTAL_ALIGNMENT_RIGHT],
	["REQ_COL_SIZE", UiTokens.D_W_REQUEST_FIGURE, HORIZONTAL_ALIGNMENT_RIGHT],
	["REQ_COL_STATUS", UiTokens.D_W_REQUEST_STATUS, HORIZONTAL_ALIGNMENT_LEFT],
	["REQ_COL_WAIT", UiTokens.D_W_REQUEST_FIGURE, HORIZONTAL_ALIGNMENT_RIGHT]],
	"market": [["REQ_COL_COUNT", UiTokens.D_W_REQUEST_FIGURE, HORIZONTAL_ALIGNMENT_RIGHT],
	["REQ_COL_ORDERS", UiTokens.D_W_REQUEST_FIGURE, HORIZONTAL_ALIGNMENT_RIGHT],
	["REQ_COL_STATUS", UiTokens.D_W_REQUEST_STATUS, HORIZONTAL_ALIGNMENT_LEFT],
	["REQ_COL_WAIT", UiTokens.D_W_REQUEST_FIGURE, HORIZONTAL_ALIGNMENT_RIGHT]]}

var _kind: String
var _market: bool
var _topics: Array
var _next: int
var _sort: String
var _filter: String
var _side: String
## Sütun genişlikleri, başlık ve satırların tek tablosu: `COLUMNS`'un genişliği, başlığın yazısı ondan genişse onunki (yoksa başlık
## satırı satırlardan kayar).
var _widths: Array
var _list_scroll: ScrollContainer
var _askers_scroll: ScrollContainer
var _open := ""   # ayrıntıdaki konu: değişince isteyenler başa döner


func _init() -> void:
	add_theme_constant_override("separation", UiTokens.SPACE_XL)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL


func setup(ui: Dictionary) -> void:
	var data: Dictionary = ProductModel.topics()
	_kind = data.kind
	_market = _kind == "market"
	_widths = COLUMNS[_kind].map(func(spec: Array) -> int: return maxi(spec[1], ceili(_head_width(spec[0]))))
	_topics = data.topics
	_next = data.next
	var many: bool = _topics.size() > FEW
	_sort = String(ui.requests_sort) if many and String(ui.requests_sort) in SORTS[_kind] else SORTS[_kind][0]
	_filter = String(ui.requests_filter) if many and String(ui.requests_filter) in FILTERS[_kind] else "all"
	_side = String(ui.requests_side) if many and _market else "all"
	var shown: Array = _sorted(_in(_filter))
	var picked: Array = shown.filter(func(t: Dictionary) -> bool: return t.id == ui.requests_topic)
	var open: Dictionary = picked[0] if not picked.is_empty() else shown[0] if not shown.is_empty() else {}
	var list_at: int = _list_scroll.scroll_vertical if _list_scroll != null else 0
	var askers_at: int = _askers_scroll.scroll_vertical if _askers_scroll != null and _open == open.get("id", "") else 0
	_open = String(open.get("id", ""))
	_list_scroll = null
	_askers_scroll = null
	UiFactory.clear(self)
	add_child(_list(shown))
	if not open.is_empty():
		add_child(_detail(open))
	for kept: Array in [[_list_scroll, list_at], [_askers_scroll, askers_at]]:
		if kept[0] != null:
			SprintUiShared.keep_scroll(kept[0], kept[1])


# --- Liste ---------------------------------------------------------------------------------------------------------------

func _list(shown: Array) -> PanelContainer:
	var frame := _frame()
	frame.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var col := SprintUiShared.column(UiTokens.SPACE_L)
	frame.add_child(SprintUiShared.pad(col, Vector4i.ONE * UiTokens.SPACE_XL))
	var head := SprintUiShared.box(UiTokens.SPACE_L)
	head.add_child(SprintUiShared.label(Fmt.upper(tr("PRODUCT_VIEW_REQUESTS")), &"SprintTitle"))
	# Pazaryerinde bekleyen konu ve son dört haftanın bileti; B2B'de bekleyen hesap ve sözlü konu.
	var waiting: Array = _in("waiting")
	var summary := SprintUiShared.label(SprintUiShared.SEP.join([SprintUiShared.count("REQ_SUMMARY_TOPICS", _in("open").size()),
		SprintUiShared.count("REQ_SUMMARY_WAITING_TOPICS", waiting.size()) if _market \
			else SprintUiShared.count("REQ_SUMMARY_WAITING", _counted(waiting)),
		SprintUiShared.count("REQ_SUMMARY_TICKETS", _counted(_in("all"))).format(
			{"weeks": int(MarketplaceModel.cfg("topics.window_weeks"))}) if _market \
			else SprintUiShared.count("REQ_SUMMARY_PROMISED", _in("promised").size())]), &"MetaMuted")
	summary.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	head.add_child(summary)
	col.add_child(head)
	if _topics.size() > FEW:
		var sorts: Array = SORTS[_kind]
		var filters: Array = FILTERS[_kind]
		var ctl := SprintUiShared.box(UiTokens.SPACE_L)
		var eyebrow := SprintUiShared.label(Fmt.upper(tr("REQ_SORT")), &"Eyebrow")
		eyebrow.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		ctl.add_child(eyebrow)
		ctl.add_child(UiFactory.D_seg_pick(sorts.map(func(o: String) -> Dictionary: return {"text": tr("REQ_SORT_" + o.to_upper())}),
			sorts.find(_sort), func(i: int) -> void: ui_changed.emit("requests_sort", sorts[i]), false, true))
		if _market:
			ctl.add_child(UiFactory.D_seg_pick(SIDES.map(func(s: String) -> Dictionary: return {"text": tr(SIDE_KEYS[s])}),
				SIDES.find(_side), func(i: int) -> void: ui_changed.emit("requests_side", SIDES[i]), false, true))
		ctl.add_child(RnDUiShared.spacer())
		ctl.add_child(UiFactory.D_seg_tabs(filters.map(func(f: String) -> String: return tr("REQ_FILTER_" + f.to_upper())),
			filters.find(_filter), func(i: int) -> void: ui_changed.emit("requests_filter", filters[i]),
			filters.map(func(f: String) -> Variant: return null if f == "all" else _in(f).size())))
		col.add_child(ctl)
	if shown.is_empty():
		col.add_child(UiFactory.D_empty(SprintUiShared.FLAG, tr("REQ_EMPTY" if _topics.is_empty() else "REQ_EMPTY_FILTER"), &"MetaMuted"))
		return frame
	col.add_child(_head_row())
	_list_scroll = ScrollContainer.new()
	_list_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_list_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var list := SprintUiShared.column(UiTokens.SPACE_XS)
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_list_scroll.add_child(list)
	col.add_child(_list_scroll)
	for t: Dictionary in shown:
		list.add_child(_row(t))
	return frame


func _head_row() -> MarginContainer:
	var row := SprintUiShared.box(UiTokens.SPACE_L)
	row.add_child(RnDUiShared.spacer(UiTokens.D_BOX_MONO))
	var topic := SprintUiShared.label(Fmt.upper(tr("REQ_COL_TOPIC")), &"Eyebrow")
	topic.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(topic)
	var specs: Array = COLUMNS[_kind]
	for i in specs.size():
		var spec: Array = specs[i]
		var cell := SprintUiShared.label(Fmt.upper(tr(spec[0])), &"Eyebrow")
		cell.custom_minimum_size.x = _widths[i]
		cell.horizontal_alignment = spec[2]
		if spec[0] in ["REQ_COL_RISK", "REQ_COL_ORDERS"]:
			cell.tooltip_text = tr(spec[0] + "_TIP").format({"weeks": int(SprintCatalog.cfg("request.risk_renew_weeks"))})
			cell.mouse_filter = Control.MOUSE_FILTER_STOP
		row.add_child(cell)
	return SprintUiShared.pad(row, Vector4i(UiTokens.SPACE_L, 0, UiTokens.SPACE_L, 0))


func _row(t: Dictionary) -> PanelContainer:
	var row := PanelContainer.new()
	row.theme_type_variation = &"ModuleRowOpen" if t.id == _open else &"ModuleRow"
	row.mouse_filter = Control.MOUSE_FILTER_STOP
	row.gui_input.connect(func(e: InputEvent) -> void:
		if e is InputEventMouseButton and e.pressed and e.button_index == MOUSE_BUTTON_LEFT:
			ui_changed.emit("requests_topic", t.id))
	var line := SprintUiShared.box(UiTokens.SPACE_L)
	line.custom_minimum_size.y = UiTokens.D_H_ROW_SM
	row.add_child(line)
	line.add_child(_mark(t))
	var topic := SprintUiShared.box(UiTokens.SPACE_M)
	topic.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var title := SprintUiShared.prose(t.name, &"DataStrong")
	title.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	topic.add_child(title)
	if not _market and t.rival and t.status != "shipped":
		topic.add_child(UiFactory.D_tag(tr("REQ_RIVAL_TAG"), &"warn"))
	line.add_child(topic)
	var columns: Array = COLUMNS[_kind]
	var cells: Array = [[SprintUiShared.count("REQ_COUNT_TICKETS", t.count), &"DataStrong"], [MpParts.count(t.affected), &"DataText"]] \
		if _market else [[SprintUiShared.count("REQ_COUNT_ACCOUNTS", t.count), &"DataStrong"],
		[_money(t.risk) if t.risk > 0 else "", &"DataText"], [_size_text(t.size), &"MetaMuted"]]
	for i in cells.size():
		var cell := SprintUiShared.label(cells[i][0], cells[i][1])
		cell.custom_minimum_size.x = _widths[i]
		cell.horizontal_alignment = columns[i][2]
		cell.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART   # uzun süre yazısı sütunu itmez, sarar
		cell.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		line.add_child(cell)
	var status := HBoxContainer.new()
	status.custom_minimum_size.x = _widths[-2]
	status.add_child(_status_tag(t))
	line.add_child(status)
	line.add_child(_late_cell(t) if _market else _wait_cell(t))
	return row


## Pazaryerinde geciken: konu yayında değilken ilk biletinden bu yana `topics.late_weeks`'i geçtiyse haftası, kum saatiyle. Bedeli
## Pazaryeri › Genel'in memnuniyet satırındadır; ipucu yalnız gözlem.
func _late_cell(t: Dictionary) -> HBoxContainer:
	var cell := SprintUiShared.box(UiTokens.SPACE_XS)
	cell.custom_minimum_size.x = _widths[-1]
	cell.alignment = BoxContainer.ALIGNMENT_END
	if t.late == 0:
		return cell
	cell.tooltip_text = tr("REQ_MP_LATE_TIP").format({"topic": t.name, "weeks": t.late})
	cell.mouse_filter = Control.MOUSE_FILTER_PASS
	cell.add_child(_glyph(SprintUiShared.HOURGLASS))
	var n := SprintUiShared.label(Fmt.weeks(t.late), &"DataText")
	n.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	cell.add_child(n)
	return cell


## Geciken: isteği `request.wait_weeks` haftayı geçen sözsüz hesap sayısı, kum saatiyle (bedel yazılmışsa uyarı renginde); ipucu kaçına
## bedel yazıldığını söyler. Yayındaki konuda ve geciken yokken boş; sözlü konuda sözü olmayan isteyenleri sayar.
func _wait_cell(t: Dictionary) -> HBoxContainer:
	var cell := SprintUiShared.box(UiTokens.SPACE_XS)
	cell.custom_minimum_size.x = _widths[-1]
	cell.alignment = BoxContainer.ALIGNMENT_END
	if t.overdue == 0 or t.status == "shipped":
		return cell
	var args := {"topic": t.name, "n": t.overdue, "weeks": int(SprintCatalog.cfg("request.wait_weeks")),
		"renew": int(SprintCatalog.cfg("request.risk_renew_weeks")), "v": int(SprintCatalog.cfg("request.wait_cost"))}
	var marked: String = tr(Fmt.count_key("REQ_WAIT_MARKED", t.marked)).format(args.merged({"n": t.marked}, true)) if t.marked > 0 \
		else tr("REQ_WAIT_UNMARKED").format(args)
	cell.tooltip_text = tr(Fmt.count_key("REQ_WAIT_TIP", t.overdue)).format(args) + "\n" + marked
	cell.mouse_filter = Control.MOUSE_FILTER_PASS
	cell.add_child(_glyph(SprintUiShared.HOURGLASS, UiTokens.D_warn() if t.marked > 0 else UiTokens.D_INK_3))
	var n := SprintUiShared.label(str(t.overdue), &"DataText")
	n.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	cell.add_child(n)
	return cell


func _status_tag(t: Dictionary) -> Control:
	match String(t.status):
		"promised": return UiFactory.D_glyph_tag(CALENDAR, tr("REQ_STATUS_PROMISED").format({"n": t.sprint}), &"warn")
		"planned": return UiFactory.D_glyph_tag(SprintUiShared.CHECK, tr("REQ_STATUS_PLANNED").format({"n": t.sprint}), &"outline")
		"shipped": return UiFactory.D_glyph_tag(SprintUiShared.CHECK, tr("REQ_STATUS_SHIPPED"), &"pos")
		"new": return UiFactory.D_tag(tr("REQ_STATUS_NEW"), &"pos")
		"waiting": return UiFactory.D_tag(tr("REQ_STATUS_WAITING"), &"neutral")
	# Kilitli konu "Kilitli" yazmaz: kapının ilk şartı, bütünü ipucunda.
	var tag := SprintUiShared.box(UiTokens.SPACE_XS)
	tag.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tag.tooltip_text = t.lock_full
	tag.mouse_filter = Control.MOUSE_FILTER_PASS
	tag.add_child(_glyph(SprintUiShared.LOCK))
	var why := SprintUiShared.prose(t.lock, &"Caption")
	why.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tag.add_child(why)
	return tag


# --- Ayrıntı -------------------------------------------------------------------------------------------------------------

func _detail(t: Dictionary) -> PanelContainer:
	var frame := _frame()
	frame.custom_minimum_size.x = UiTokens.D_W_REQUEST_DETAIL
	var col := SprintUiShared.column(UiTokens.SPACE_L)
	frame.add_child(SprintUiShared.pad(col, Vector4i(UiTokens.SPACE_3XL, UiTokens.SPACE_XL, UiTokens.SPACE_3XL, UiTokens.SPACE_XL)))
	col.add_child(SprintUiShared.label(Fmt.upper(_where(t)), &"Eyebrow"))
	var title := SprintUiShared.box(UiTokens.SPACE_L)
	title.add_child(_mark(t))
	var heading := SprintUiShared.prose(t.name, &"SprintTitle")
	heading.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.add_child(heading)
	if t.status != "locked":
		title.add_child(_status_tag(t))
	col.add_child(title)
	var facts := SprintUiShared.box(UiTokens.SPACE_3XL)
	if _market:
		facts.add_child(UiFactory.D_kpi(tr("REQ_COL_TICKETS"), Fmt.group(t.count)))
		facts.add_child(UiFactory.D_kpi(tr("REQ_COL_ORDERS"), MpParts.count(t.affected)))
	else:
		facts.add_child(UiFactory.D_kpi(tr("REQ_COL_COUNT"), SprintUiShared.count("REQ_COUNT_ACCOUNTS", t.count)))
		facts.add_child(UiFactory.D_kpi(tr("REQ_ACCOUNTS_REVENUE"), _money(t.value)))
		if t.size >= 0.0:
			facts.add_child(UiFactory.D_kpi(tr("REQ_COL_SIZE"), _size_text(t.size)))
	col.add_child(facts)
	if _market and t.status != "shipped":
		# Kullanıcı konusunda kaybın olduğu adım, mağaza konusunda riskin derdi; pay konunun haftalık teslime oranıdır.
		col.add_child(SprintUiShared.prose(tr("REQ_MP_LOST" if t.side == "users" else "REQ_MP_RISK").format(
			{"step": tr(REASON_KEYS[t.reason]), "pct": roundi(t.share * 100.0)}), &"Caption"))
	if t.status == "locked":
		var why := SprintUiShared.box(UiTokens.SPACE_M)
		why.add_child(_glyph(SprintUiShared.LOCK))
		var text := SprintUiShared.prose(t.lock_full, &"Caption")
		text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		why.add_child(text)
		col.add_child(why)
	var act: Control = _action(t)
	if act != null:
		col.add_child(HSeparator.new())
		col.add_child(act)
	if not _market:
		col.add_child(HSeparator.new())
		col.add_child(_askers(t))
	return frame


## Konunun eylemi: bekleyen konuda "Plana al · Sprint N" (sonraki sprintin planı; söz değil, geri çekilir), planda ya da sözlüde
## "Planda gör" (durumu başlıkta), B2B'de yayındakinde "Karşılandı" satırı. B2B'de bekleyen ve kilitli konuda "Şimdilik olmaz" ve
## bedeli: her isteyene kapatma izi (`SprintBridges.close_topic`); ne olacağı ipucunda. Pazaryerinde yalnız Plana al.
func _action(t: Dictionary) -> Control:
	match String(t.status):
		"shipped":
			return null if _market \
				else SprintUiShared.prose(SprintUiShared.count("REQ_DELIVERED_LINE", t.count).format({"topic": t.name}), &"Caption")
		"planned", "promised":
			return _button(tr("REQ_ACT_SEE_PLAN"), &"SecondaryButtonSmall", func() -> void: ui_changed.emit("view", "sprint"))
	var plan: bool = t.status != "locked" and _next >= 0
	if _market and not plan:
		return null
	var col := SprintUiShared.column(UiTokens.SPACE_M)
	if plan:
		col.add_child(_button(tr("REQ_ACT_PLAN").format({"n": _next}), &"PrimaryButtonDark",
			func() -> void: action.emit("send_next", {"card_id": t.card_id})))
	if _market:
		return col
	var close := SprintUiShared.box(UiTokens.SPACE_L)
	var button := SprintUiShared.button(tr("REQ_ACT_CLOSE"), &"GhostButtonSmall",
		func() -> void: action.emit("close_topic", {"step": t.id}))
	button.tooltip_text = tr("REQ_CLOSE_TIP").format({"topic": t.name})
	close.add_child(button)
	var cost := UiFactory.D_cost(SprintUiShared.count("REQ_CLOSE_COST", t.count).format(
		{"v": int(SprintCatalog.cfg("request.close_cost"))}), &"Caption")
	cost.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	close.add_child(cost)
	col.add_child(close)
	return col


func _button(text: String, variation: StringName, on_press: Callable) -> Button:
	var button := SprintUiShared.button(text, variation, on_press)
	button.custom_minimum_size.x = UiTokens.D_W_START
	button.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	return button


func _askers(t: Dictionary) -> VBoxContainer:
	var col := SprintUiShared.column(UiTokens.SPACE_XS)
	col.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var head := SprintUiShared.box(UiTokens.SPACE_L)
	head.add_child(RnDUiShared.spacer(UiTokens.D_ICON_ROW))
	var who := SprintUiShared.label(Fmt.upper(tr("REQ_REQUESTERS")), &"Eyebrow")
	who.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(who)
	for key in ["REQ_COL_MRR", "REQ_COL_SAT", "REQ_COL_RENEW", "REQ_COL_SINCE"]:
		var cell := SprintUiShared.label(Fmt.upper(tr(key)), &"Eyebrow")
		cell.custom_minimum_size.x = UiTokens.D_W_CAP_NUMBER
		cell.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		head.add_child(cell)
	col.add_child(SprintUiShared.pad(head, Vector4i(UiTokens.SPACE_M, 0, UiTokens.SPACE_M, 0)))
	_askers_scroll = ScrollContainer.new()
	_askers_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_askers_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var list := SprintUiShared.column(UiTokens.SPACE_XXS)
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_askers_scroll.add_child(list)
	col.add_child(_askers_scroll)
	for a: Dictionary in t.askers:
		var row := PanelContainer.new()
		row.theme_type_variation = &"ModuleRow"
		row.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var line := SprintUiShared.box(UiTokens.SPACE_L)
		line.custom_minimum_size.y = UiTokens.D_H_ROW_SM
		row.add_child(line)
		line.add_child(_glyph(SprintUiShared.BUILDING))
		var account := SprintUiShared.prose(a.name, &"DataStrong")
		account.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		line.add_child(account)
		if a.promise >= 0:   # tarih ipucunda, sütunlar ayrıntının içinde kalır
			line.add_child(_glyph(CALENDAR, UiTokens.D_warn(), tr("REQ_STATUS_PROMISED").format({"n": a.promise})))
		# Geciken isteğin beklemesi kırmızı; bedeli yazılmışsa adı ipucunda.
		var mark: String = tr("SALES_REQ_MARK_WAIT").format({"topic": t.name}) if a.marked else ""
		for cell: Array in [[_money(a.mrr), false, ""], [str(a.sat), a.at_risk, ""], [Fmt.weeks(a.renew), a.soon, ""],
				[Fmt.weeks(a.waited), a.overdue, mark]]:
			var label := SprintUiShared.label(cell[0], &"DataText", UiTokens.D_neg_ink() if cell[1] else null)
			label.custom_minimum_size.x = UiTokens.D_W_CAP_NUMBER
			label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
			label.tooltip_text = cell[2]
			label.mouse_filter = Control.MOUSE_FILTER_STOP if cell[2] != "" else Control.MOUSE_FILTER_IGNORE
			line.add_child(label)
		list.add_child(row)
	return col


# --- Yardımcılar ---------------------------------------------------------------------------------------------------------

func _frame() -> PanelContainer:
	var frame := PanelContainer.new()
	frame.theme_type_variation = &"SprintColumn"
	return frame


func _glyph(path: String, ink: Color = UiTokens.D_INK_3, tip := "") -> TextureRect:
	var glyph := UiFactory.make_glyph(path, UiTokens.D_ICON_ROW, ink)
	glyph.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	glyph.tooltip_text = tip
	glyph.mouse_filter = Control.MOUSE_FILTER_STOP if tip != "" else Control.MOUSE_FILTER_IGNORE
	return glyph


## Konunun modülü: ikon kutusu, yeri (`_where`) ipucunda; tık satıra geçer.
func _mark(t: Dictionary) -> PanelContainer:
	var box := AreaPanel.module_mark(t.line, t.area)
	box.tooltip_text = _where(t)
	box.mouse_filter = Control.MOUSE_FILTER_PASS
	return box


## Konunun yeri: modülün adı, pazaryerinde önce tarafı.
func _where(t: Dictionary) -> String:
	return SprintUiShared.SEP.join([tr(SIDE_KEYS[t.side]), t.module]) if _market else t.module


## Konuların isteyen sayısı toplamı (pazaryerinde bilet).
func _counted(ts: Array) -> int:
	return ts.reduce(func(s: int, t: Dictionary) -> int: return s + t.count, 0)


func _money(v: int) -> String:
	return Fmt.money_chip(v) + tr("SALES_PER_MONTH")


## Kartın süresi sprint cinsinden: sprintin dörtte biri, yarısı, sonra tam sprint sayısı; bilinmiyorsa boş.
func _size_text(size: float) -> String:
	if size < 0.0:
		return ""
	if size <= 0.25:
		return tr("REQ_SIZE_QUARTER")
	if size <= 0.5:
		return tr("REQ_SIZE_HALF")
	return SprintUiShared.count("REQ_SIZE_SPRINTS", ceili(size))


## Sütun başlığının yazısının genişliği (`Eyebrow`, büyük harf; yerleşimden önce, `StagePaint.text_width`).
func _head_width(key: String) -> float:
	return StagePaint.text_width(Fmt.upper(tr(key)), &"Eyebrow")


## Süzgecin konuları, seçili tarafta; "open" yayında olmayanlar, "waiting" bekleyenler (`ProductModel.is_waiting`, kilitli dahil).
func _in(f: String) -> Array:
	var on_side: Array = _topics.filter(func(t: Dictionary) -> bool: return _side == "all" or t.side == _side)
	return on_side.filter(func(t: Dictionary) -> bool:
		match f:
			"open": return t.status != "shipped"
			"waiting": return ProductModel.is_waiting(t)
			"planned", "promised", "shipped": return t.status == f
		return true)


## Yayındakiler sonda; önce seçili ölçü (isteyen, risk altındaki gelir, en yakın söz ya da etkilenen sipariş), eşitse isteyen sayısı.
func _sorted(ts: Array) -> Array:
	var out := ts.duplicate()
	out.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		var sa: int = int(a.status == "shipped")
		var sb: int = int(b.status == "shipped")
		if sa != sb:
			return sa < sb
		var ka: int = _key(a)
		var kb: int = _key(b)
		return ka > kb if ka != kb else a.count > b.count)
	return out


func _key(t: Dictionary) -> int:
	match _sort:
		"risk": return t.risk
		"due": return -t.sprint if t.status == "promised" else -9999
		"affected": return t.affected
	return t.count
