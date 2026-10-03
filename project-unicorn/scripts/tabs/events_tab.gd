extends Control

# Olaylar penceresi: gelen kutusu. Solda liste (Tümü / Bekleyen / Okunmamış süzgeçleri sayılarıyla,
# önce bekleyenler, sonra gün ayraçlı geçmiş), sağda seçili öğenin okuma bölmesi. Kutunun modeli
# Inbox'tadır; sayfa yalnız dizer, seçer ve klavyeyi bölmeye geçirir. Pencerenin ortak başlığı
# koyu dilde açılır, KPI'ı en yakın süredir.

const INBOX := preload("res://scripts/ui/components/inbox.gd")
const PANE := preload("res://scripts/tabs/events/mail_pane.gd")
const FILTERS := ["INBOX_ALL", "INBOX_WAITING", "INBOX_UNREAD"]
const EMPTY := ["INBOX_EMPTY_ALL", "INBOX_EMPTY_WAITING", "INBOX_EMPTY_UNREAD"]
const LIST_W := 400
const ROW_H := 96
const QUEUE_H := 44
const BAND_H := 28
const EDGE := 24          # the row's marker and dot column

var frame_options: Dictionary
var _kpi: PanelContainer
var _tabs: HBoxContainer
var _rows: VBoxContainer
var _scroll: ScrollContainer
var _pane: ScrollContainer
var _items: Array = []
var _filter := 0
var _selected := ""
var _shown: Dictionary = {}   # the item the pane reads
var _queued := false


func _init() -> void:
	_kpi = UiFactory.D_kpi(tr("INBOX_SOONEST"), "")
	# The header's slot keeps its room when there is no deadline to show.
	var slot := HBoxContainer.new()
	slot.add_child(_kpi)
	frame_options = {"title": "TAB_EVENTS", "kpi": slot, "pad": Vector2i.ZERO}


func _ready() -> void:
	add_to_group(INBOX.GROUP)
	var split := HBoxContainer.new()
	split.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	split.add_theme_constant_override("separation", 0)
	add_child(split)
	var list := PanelContainer.new()
	list.theme_type_variation = &"InboxList"
	list.custom_minimum_size.x = LIST_W
	split.add_child(list)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 0)
	list.add_child(col)
	_tabs = HBoxContainer.new()
	_tabs.custom_minimum_size.y = UiTokens.SPACE_4XL + UiTokens.SPACE_L
	var tabs_pad := MarginContainer.new()
	tabs_pad.add_theme_constant_override("margin_left", UiTokens.SPACE_3XL)
	tabs_pad.add_child(_tabs)
	col.add_child(tabs_pad)
	col.add_child(HSeparator.new())
	_scroll = ScrollContainer.new()
	_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	col.add_child(_scroll)
	_rows = VBoxContainer.new()
	_rows.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_rows.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_rows.add_theme_constant_override("separation", 0)
	_scroll.add_child(_rows)
	_pane = PANE.new()
	split.add_child(_pane)
	INBOX.connect_changes(_queue_refresh)
	_refresh()
	if _selected == "" and not _visible().is_empty():
		select(String(_visible()[0].id))


## Selects an item and reads it in the pane; an item the filter hides brings back Tümü.
func select(item_id: String) -> void:
	_items = INBOX.items()
	if _find(item_id).is_empty():
		return
	if not _visible().any(func(it: Dictionary) -> bool: return it.id == item_id):
		_filter = 0
	_selected = item_id
	_read()
	_draw_list()


## Esc on the window: an armed option is disarmed before the window closes.
func on_escape() -> bool:
	return _pane.on_escape()


# --- Harness relays (--inbox-shot) ---

func filter_for_shot(filter: int) -> void:
	_set_filter(filter)


func scroll_for_shot(px: int) -> void:
	_scroll.scroll_vertical = px


func arm_for_shot(option: int) -> void:
	_pane.arm(option)


func _unhandled_input(event: InputEvent) -> void:
	var key := event as InputEventKey
	if key == null or not key.pressed or key.echo or not is_visible_in_tree():
		return
	match key.keycode:
		KEY_UP, KEY_DOWN:
			var list: Array = _visible().filter(func(it: Dictionary) -> bool: return it.kind != "queue")
			var at: int = list.map(func(it: Dictionary) -> String: return it.id).find(_selected)
			var next: int = clampi(at + (1 if key.keycode == KEY_DOWN else -1), 0, list.size() - 1)
			if not list.is_empty() and next != at:
				select(String(list[next].id))
		KEY_ENTER, KEY_KP_ENTER:
			var it: Dictionary = _find(_selected)
			if it.get("kind", "") == "paper" and EventGate.active_id() == "":
				EventGate.open_paper(String(it.key))
			elif not _pane.on_key(key.keycode):
				return
		KEY_LEFT, KEY_RIGHT:
			if not _pane.on_key(key.keycode):
				return
		_:
			return
	get_viewport().set_input_as_handled()


## One rebuild per frame however many signals land in it.
func _queue_refresh(_a = null, _b = null) -> void:
	if not _queued:
		_queued = true
		_refresh.call_deferred()


func _refresh() -> void:
	_queued = false
	_items = INBOX.items()
	var now: Dictionary = _find(_selected)
	if now.is_empty():
		_selected = String(_visible()[0].id) if not _visible().is_empty() else ""
		_read()
	# Read again only when the item changed: an armed option survives a repaint.
	elif [_shown.get("kind"), _shown.get("event_id"), _shown.get("weeks_left")] \
			!= [now.kind, now.get("event_id"), now.get("weeks_left")]:
		_read()
	_draw_list()
	_paint_kpi()


func _read() -> void:
	var it: Dictionary = _find(_selected)
	_shown = it
	_pane.populate(it, {"active": "live", "history": "history"}.get(it.get("kind", ""), "preview"))
	INBOX.mark_read(it)


## A filter that hides the item read leaves the pane empty.
func _set_filter(filter: int) -> void:
	_filter = filter
	if not _visible().any(func(it: Dictionary) -> bool: return it.id == _selected):
		_selected = ""
		_read()
	_draw_list()


func _find(item_id: String) -> Dictionary:
	for it in _items:
		if it.id == item_id:
			return it
	return {}


func _visible() -> Array:
	match _filter:
		1: return _items.filter(func(it: Dictionary) -> bool: return it.waiting)
		2: return _items.filter(func(it: Dictionary) -> bool: return it.unread)
	return _items


func _paint_kpi() -> void:
	var soonest: int = -1
	var last: bool = false
	for it in _items:
		if it.has("weeks_left"):
			soonest = int(it.weeks_left) if soonest < 0 else mini(soonest, int(it.weeks_left))
			last = last or bool(it.get("expiring", false)) or int(it.weeks_left) <= 1
	_kpi.visible = soonest >= 0
	var value: Label = _kpi.get_child(0).get_child(1)
	value.text = tr("INBOX_THIS_WEEK") if last else tr(Fmt.count_key("DESK_PAPER_WEEKS", soonest)).format({"n": soonest})
	if last:
		value.add_theme_color_override("font_color", UiTokens.D_warn())
	else:
		value.remove_theme_color_override("font_color")


# --- The list ------------------------------------------------------------------------------------

func _draw_list() -> void:
	UiFactory.clear(_tabs)
	_tabs.add_child(UiFactory.D_seg_tabs(FILTERS.map(func(k: String) -> String: return tr(k)), _filter,
		_set_filter, INBOX.counts(_items)))
	UiFactory.clear(_rows)
	var shown: Array = _visible()
	if shown.is_empty():
		var center := CenterContainer.new()
		center.size_flags_vertical = Control.SIZE_EXPAND_FILL
		var col := VBoxContainer.new()
		col.add_theme_constant_override("separation", UiTokens.SPACE_L)
		var glyph := UiFactory.make_glyph("res://assets/icons/util/inbox.svg", UiTokens.SPACE_3XL, UiTokens.D_INK_4)
		glyph.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		col.add_child(glyph)
		col.add_child(UiFactory.make_label(tr(EMPTY[_filter]), &"MetaMuted"))
		center.add_child(col)
		_rows.add_child(center)
		return
	var day: int = -1
	for it in shown:
		if it.kind in ["history", "message"] and int(it.day) != day:
			day = int(it.day)
			_rows.add_child(_band(day))
		_rows.add_child(_queue_row(int(it.count)) if it.kind == "queue" else _row(it))


func _band(day: int) -> PanelContainer:
	var band := PanelContainer.new()
	band.theme_type_variation = &"InboxBand"
	band.custom_minimum_size.y = BAND_H
	band.add_child(UiFactory.make_label(INBOX.date_text(day), &"Caption"))
	return band


func _queue_row(count: int) -> PanelContainer:
	var row := _box(QUEUE_H)
	var line := HBoxContainer.new()
	line.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	line.add_theme_constant_override("separation", UiTokens.SPACE_M)
	line.add_child(UiFactory.make_glyph("res://assets/icons/util/queue.svg", UiTokens.D_ICON_ROW, UiTokens.D_INK_3))
	line.add_child(UiFactory.make_label(tr(Fmt.count_key("INBOX_QUEUE", count)).format({"n": count}), &"DataText"))
	line.add_child(RnDUiShared.spacer())
	line.add_child(UiFactory.make_label(tr("INBOX_QUEUE_AFTER"), &"Caption"))
	row.get_child(0).add_child(line)
	return row


## A row: who and the topic; the subject, with what it waits on; the first line, the choice or the
## reason. An amber dot is the decision on screen, an ink dot an unread one.
func _row(it: Dictionary) -> PanelContainer:
	var selected: bool = it.id == _selected
	var row := _box(ROW_H, selected)
	var lines := VBoxContainer.new()
	lines.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lines.alignment = BoxContainer.ALIGNMENT_CENTER
	lines.add_theme_constant_override("separation", UiTokens.SPACE_XS)
	row.get_child(0).add_child(lines)
	var one := HBoxContainer.new()
	var from := UiFactory.make_label(String(it.sender.name), &"MetaMuted")
	if it.sender.gone:
		from.text = "%s · %s" % [it.sender.name, tr("MAIL_STAMP_LEFT")]
	from.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	from.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	one.add_child(from)
	one.add_child(PANE.topic_pill(String(it.topic)))
	lines.add_child(one)
	var two := HBoxContainer.new()
	two.add_theme_constant_override("separation", UiTokens.SPACE_M)
	if it.kind == "reminder" and it.has("state"):
		two.add_child(UiFactory.D_tag(String(it.state), &"risk" if it.risk else &""))
		two.add_child(RnDUiShared.spacer())
	else:
		var subject := UiFactory.make_label(String(it.subject),
			&"SubjectStrong" if it.unread or it.kind == "active" else &"SubjectLabel")
		subject.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		subject.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		two.add_child(subject)
	var right: Control = _row_right(it)
	if right != null:
		two.add_child(right)
	lines.add_child(two)
	var line := UiFactory.make_label(String(it.line), &"MetaMuted")
	line.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	line.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lines.add_child(line)
	var edge: Control = row.get_child(0).get_child(0)
	if it.kind == "active":
		edge.add_child(_dot(Panel.new(), &"GateDot", UiTokens.SPACE_M))
	elif it.unread:
		edge.add_child(_dot(UiFactory.make_dot(UiTokens.D_INK_2, UiTokens.SPACE_S), &"", UiTokens.SPACE_S))
	HRUiShared.set_mouse_ignore(row.get_child(0))
	row.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	row.gui_input.connect(func(e: InputEvent) -> void:
		if UiFactory.is_left_click(e):
			select(String(it.id)))
	if not selected:
		row.mouse_entered.connect(func() -> void: row.theme_type_variation = &"InboxRowHover")
		row.mouse_exited.connect(func() -> void: row.theme_type_variation = &"InboxRow")
	return row


## Right of the subject: a paper's weeks, a reminder's figure, a report's kind, a past
## decision's stamp.
func _row_right(it: Dictionary) -> Control:
	match String(it.kind):
		"paper":
			var box := HBoxContainer.new()
			box.add_theme_constant_override("separation", UiTokens.SPACE_S)
			var weeks: int = int(it.weeks_left)
			var last: bool = it.expiring or weeks <= 1
			var ink: Color = UiTokens.D_warn() if last else UiTokens.D_INK_3
			box.add_child(UiFactory.make_glyph(PANE.CLOCK, UiTokens.D_ICON_PART, ink))
			box.add_child(UiFactory.make_label(tr("DESK_PAPER_THIS_WEEK") if last
				else tr(Fmt.count_key("DESK_PAPER_WEEKS", weeks)).format({"n": weeks}), &"Caption", ink))
			return box
		"reminder":
			if it.has("morale"):
				var pair := HBoxContainer.new()
				pair.add_theme_constant_override("separation", UiTokens.SPACE_S)
				pair.add_child(UiFactory.make_label(Fmt.upper(tr("HR_COL_MORALE")), &"KeyLabel"))
				pair.add_child(UiFactory.make_label(str(int(it.morale)), &"MoraleValue", UiTokens.D_neg()))
				return pair
			return UiFactory.make_label(String(it.get("value", "")), &"Caption") if it.has("value") else null
		"history":
			return PANE.stamp(String(it.stamp), int(GameState.get_date_dict(int(it.day)).week))
		"message":
			if it.right == "":
				return null
			var tag := HBoxContainer.new()
			tag.add_theme_constant_override("separation", UiTokens.SPACE_S)
			tag.add_child(UiFactory.make_glyph("res://assets/icons/util/%s.svg" % ("sparkle" if it.right == "INBOX_ROW_DISCOVERY" else "doc"),
				UiTokens.D_ICON_PART, UiTokens.D_INK_3))
			tag.add_child(UiFactory.make_label(tr(String(it.right)), &"Caption"))
			return tag
	return null


## A row's box: its marker-and-dot column, then its content.
func _box(h: int, selected := false) -> PanelContainer:
	var row := PanelContainer.new()
	row.theme_type_variation = &"InboxRowSelected" if selected else &"InboxRow"
	row.custom_minimum_size.y = h
	var inner := HBoxContainer.new()
	inner.add_theme_constant_override("separation", 0)
	row.add_child(inner)
	var edge := Control.new()
	edge.custom_minimum_size.x = EDGE
	inner.add_child(edge)
	if selected:
		var mark := Panel.new()
		mark.theme_type_variation = &"RailMark"
		mark.anchor_bottom = 1.0
		mark.offset_top = UiTokens.D_MARK.y
		mark.offset_bottom = -UiTokens.D_MARK.y
		mark.offset_right = UiTokens.D_MARK.x
		edge.add_child(mark)
	return row


## A dot centred in the row's edge column.
func _dot(dot: Control, variation: StringName, px: int) -> Control:
	if variation != &"":
		dot.theme_type_variation = variation
	dot.custom_minimum_size = Vector2(px, px)
	dot.set_anchors_preset(Control.PRESET_CENTER)
	dot.offset_left = -px / 2.0
	dot.offset_top = -px / 2.0
	dot.offset_right = px / 2.0
	dot.offset_bottom = px / 2.0
	return dot
