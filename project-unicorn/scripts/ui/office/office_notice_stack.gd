extends VBoxContainer

# The notice stack at the office's bottom right: the inbox's preview. Frank's latest line, the newest discovery
# not read yet, then what waits in the inbox (papers, then reminders, in its order), at most MAX_CARDS cards
# with a +N badge on the last for the rest. A row reads sender · subject · time left; a click opens it in the inbox.
# The decision on screen is not a row: the top bar's gate slot is. Windows are later siblings of the
# office, and the stack hides while one lies over it. In the dark language from its root.

const INBOX := preload("res://scripts/ui/components/inbox.gd")
const WIDTH := 352
const MAX_CARDS := 4
const ARRIVE_S := 0.35
const ARRIVE_SLIDE := 24.0   # px a new card slides in from the right

var _seen := {}   # ids of cards already shown once; only a new one plays the arrival
var _queued := false
var _map_open := false
var _window_cover := Rect2()


func _ready() -> void:
	theme = load(UiTokens.MENAJER_THEME)
	add_to_group(&"office_overlays")
	custom_minimum_size.x = WIDTH
	set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT, Control.PRESET_MODE_MINSIZE,
		UiTokens.SPACE_3XL)
	grow_horizontal = Control.GROW_DIRECTION_BEGIN
	grow_vertical = Control.GROW_DIRECTION_BEGIN
	alignment = BoxContainer.ALIGNMENT_END
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_theme_constant_override("separation", UiTokens.SPACE_M)
	# The inbox's signals, plus the two that repaint what it gets from a rebuild: the office is never
	# rebuilt on a palette or language switch.
	INBOX.connect_changes(_queue_refresh)
	EventBus.mentor_advisory_changed.connect(_queue_refresh)
	EventBus.palette_changed.connect(_queue_refresh)
	EventBus.language_changed.connect(_queue_refresh)
	# The desk as the office opens is not news: nothing arrives on the first fill.
	_refresh(false)
	# A new card grows the stack, maybe under a window.
	resized.connect(_show)


## The city map's office card takes the right edge while the map is open, and the founder's
## trip shows no controls (OfficeView says which).
func set_map_open(open: bool) -> void:
	_map_open = open
	_show()


## WindowLayer says where the open windows lie each time it places them.
func set_window_cover(cover: Rect2) -> void:
	_window_cover = cover
	_show()


func _show() -> void:
	visible = not _map_open and not _window_cover.intersects(get_global_rect())


## One rebuild per frame however many signals land in it, so a new card's arrival is not cut.
func _queue_refresh(_a = null, _b = null) -> void:
	if not _queued:
		_queued = true
		_refresh.call_deferred(true)


func _refresh(arrive: bool) -> void:
	_queued = false
	UiFactory.clear(self)
	var room: int = MAX_CARDS
	var key: String = GameState.mentor_line_key
	if key != "":
		room -= 1
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", UiTokens.SPACE_L)
		row.add_child(UiFactory.make_mentor_avatar(UiTokens.D_AVATAR_ROW))
		var said := VBoxContainer.new()
		said.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		said.add_theme_constant_override("separation", 0)
		said.add_child(UiFactory.make_label(INBOX.frank().name, &"MetaMuted"))
		var quote := UiFactory.make_label(tr("FIN_MENTOR_QUOTE_WRAPPED").format(
			{"quote": tr(key).format(GameState.mentor_line_args)}), &"QuoteSerif")
		quote.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		said.add_child(quote)
		row.add_child(said)
		# Keyed by the line, not its words: a language switch is not a new note.
		_add(row, EventBus.tab_changed.emit.bind("events"),
			"frank:%s%s" % [key, GameState.mentor_line_args], arrive)
	var desk: Array = INBOX.unread_discovery() + INBOX.desk()
	var shown: Array = desk.slice(0, room)
	var hidden: int = desk.size() - shown.size()
	for i in shown.size():
		var it: Dictionary = shown[i]
		var row := _row(it)
		if i == shown.size() - 1 and hidden > 0:
			var more := UiFactory.make_label("+%d" % hidden, &"BadgeCount")
			more.size_flags_vertical = Control.SIZE_SHRINK_CENTER
			row.add_child(more)
		_add(row, INBOX.show.bind(String(it.id)), String(it.id), arrive)


## sender · subject · time left; the dot says what kind of wait it is.
func _row(it: Dictionary) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", UiTokens.SPACE_M)
	var last: bool = it.kind == "paper" and (bool(it.expiring) or int(it.weeks_left) <= 1)
	var dot: Color = UiTokens.D_neg() if it.get("risk", false) else (UiTokens.D_warn() if last
		else (UiTokens.D_pos() if it.get("grow", false) else UiTokens.D_info()))
	row.add_child(UiFactory.make_dot(dot, UiTokens.SPACE_M))
	row.add_child(UiFactory.make_label(String(it.sender.name), &"MetaMuted"))
	var subject := UiFactory.make_label(String(it.subject), &"NoticeText")
	subject.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	subject.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(subject)
	if it.kind == "paper":
		var weeks: int = int(it.weeks_left)
		row.add_child(UiFactory.make_label(tr("DESK_PAPER_THIS_WEEK") if last
			else tr(Fmt.count_key("DESK_PAPER_WEEKS", weeks)).format({"n": weeks}), &"Caption",
			UiTokens.D_warn() if last else null))
	for c in row.get_children():
		c.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	return row


func _add(row: Control, on_click: Callable, id: String, arrive: bool) -> void:
	var card := PanelContainer.new()
	card.theme_type_variation = &"NoticeDoc"
	card.custom_minimum_size.y = UiTokens.D_H_STRIP
	card.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	card.gui_input.connect(func(event: InputEvent) -> void:
		if UiFactory.is_left_click(event):
			on_click.call()
			_queue_refresh())
	HRUiShared.set_mouse_ignore(row)
	card.add_child(row)
	add_child(card)
	var fresh: bool = arrive and not _seen.has(id)
	_seen[id] = true
	if not fresh:
		return
	# The box has placed the card at x 0 by the time the tween starts, so it slides home to 0.
	card.modulate.a = 0.0
	var tw := card.create_tween().set_parallel().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tw.tween_property(card, "modulate:a", 1.0, ARRIVE_S)
	tw.tween_property(card, "position:x", 0.0, ARRIVE_S).from(ARRIVE_SLIDE)
