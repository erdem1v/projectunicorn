extends VBoxContainer

# The notice stack at the office's bottom right: Frank's latest line, then the papers waiting on
# the desk, at most MAX_CARDS cards with a +N badge on the last for the rest. What a paper is and
# where its click goes is DeskPapers'; the Events window lists them all. Windows are later
# siblings of the office, and the stack hides while one lies over it.

const PAPERS := preload("res://scripts/ui/components/desk_papers.gd")
const WIDTH := 352
const MAX_CARDS := 4
const ARRIVE_S := 0.35
const ARRIVE_SLIDE := 24.0   # px a new card slides in from the right

var _seen := {}   # ids of cards already shown once; only a new one plays the arrival
var _queued := false
var _map_open := false
var _window_cover := Rect2()


func _ready() -> void:
	add_to_group(&"office_overlays")
	custom_minimum_size.x = WIDTH
	set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT, Control.PRESET_MODE_MINSIZE,
		UiTokens.SPACE_3XL)
	grow_horizontal = Control.GROW_DIRECTION_BEGIN
	grow_vertical = Control.GROW_DIRECTION_BEGIN
	alignment = BoxContainer.ALIGNMENT_END
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_theme_constant_override("separation", UiTokens.SPACE_M)
	# The Events page's signals, plus the two that repaint what it gets from a rebuild: the
	# office is never rebuilt on a palette or language switch.
	PAPERS.connect_changes(_queue_refresh)
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
		row.add_theme_constant_override("separation", UiTokens.SPACE_M)
		row.add_child(UiFactory.make_mentor_avatar(24))
		var quote := UiFactory.make_label(tr("FIN_MENTOR_QUOTE_WRAPPED").format(
			{"quote": tr(key).format(GameState.mentor_line_args)}), &"QuoteSerif")
		quote.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		quote.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(quote)
		# Keyed by the line, not its words: a language switch is not a new note.
		_add(row, EventBus.tab_changed.emit.bind("events"),
			"frank:%s%s" % [key, GameState.mentor_line_args], arrive)
	var papers: Array = PAPERS.gather()
	var shown: Array = papers.slice(0, room)
	var hidden: Array = papers.slice(room)
	for i in shown.size():
		var paper: Dictionary = shown[i]
		var row: HBoxContainer = PAPERS.make_row(paper)
		if i == shown.size() - 1 and not hidden.is_empty():
			# The desk puts the most urgent first, so what hides is the least urgent; the badge
			# still turns amber when a hidden one is running out.
			var expiring: bool = hidden.any(func(p: Dictionary) -> bool: return bool(p["expiring"]))
			row.add_child(UiFactory.make_badge("+%d" % hidden.size(),
				&"accent" if expiring else &"neutral"))
		_add(row, func() -> void: PAPERS.open(paper), String(paper["id"]), arrive)


func _add(row: Control, on_click: Callable, id: String, arrive: bool) -> void:
	var card := PanelContainer.new()
	card.theme_type_variation = &"CardPanelTight"
	card.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	# Hover moves the edge only; both variations share fill and margins, so the card holds still.
	card.mouse_entered.connect(func() -> void: card.theme_type_variation = &"CardPanelTightHover")
	card.mouse_exited.connect(func() -> void: card.theme_type_variation = &"CardPanelTight")
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
