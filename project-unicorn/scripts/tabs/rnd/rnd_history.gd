extends Control

# Ar-Ge's own history: the monthly notes and the discoveries, newest first, under week bands (the inbox's rows,
# without the topic pill: every one is the product's), and the inbox's reading pane beside them. There is one
# read state: reading here reads the inbox's mail (Inbox.mark_read). Empty until the first note or discovery.
# No class_name: rnd_tab preloads it.

const INBOX := preload("res://scripts/ui/components/inbox.gd")
const EVENTS := preload("res://scripts/tabs/events_tab.gd")
const PANE := preload("res://scripts/tabs/events/mail_pane.gd")
const KINDS := ["rnd_note", "rnd_discovery"]

var _split: HBoxContainer
var _empty: CenterContainer
var _rows: VBoxContainer
var _pane: ScrollContainer
var _selected := ""
var _gated := false


## The inbox's items this view lists.
static func items() -> Array:
	return INBOX.items().filter(func(it: Dictionary) -> bool: return it.kind == "message" and it.msg.kind in KINDS)


func _ready() -> void:
	_split = SprintUiShared.box(0)
	_split.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_split)
	var list := PanelContainer.new()
	list.theme_type_variation = &"InboxList"
	list.custom_minimum_size.x = EVENTS.LIST_W
	_split.add_child(list)
	var scroll := ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	list.add_child(scroll)
	_rows = SprintUiShared.column(0)
	_rows.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(_rows)
	_pane = PANE.new()
	_split.add_child(_pane)
	_empty = UiFactory.D_empty("res://assets/icons/util/history.svg", tr("RND_HISTORY_EMPTY"), &"NoteMuted")
	_empty.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_empty)


## The list again, when the view is in sight (reading marks read); the pane reads again only when its mail is
## gone or a decision came or went (an open mail keeps its scroll through a tick).
func refresh() -> void:
	var shown: Array = items()
	_empty.visible = shown.is_empty()
	_split.visible = not shown.is_empty()
	if shown.is_empty():
		return
	var keep: bool = shown.any(func(it: Dictionary) -> bool: return it.id == _selected)
	var gated: bool = EventGate.active_id() != ""
	if not keep or gated != _gated:
		_gated = gated
		_read(_selected if keep else String(shown[0].id))
	_draw_list(shown)


func _select(item_id: String) -> void:
	_read(item_id)
	_draw_list(items())


func _read(item_id: String) -> void:
	_selected = item_id
	var it: Dictionary = items().filter(func(i: Dictionary) -> bool: return i.id == item_id)[0]
	_pane.populate(it, "rnd")
	INBOX.mark_read(it)


func _draw_list(shown: Array) -> void:
	UiFactory.clear(_rows)
	var day: int = -1
	for it in shown:
		if int(it.day) != day:
			day = int(it.day)
			_rows.add_child(EVENTS.band(day))
		var row: PanelContainer = EVENTS.row(it, it.id == _selected, false, _select)
		# Reading a note is reading, also while a decision waits.
		row.set_meta(&"gate_reads", true)
		_rows.add_child(row)
