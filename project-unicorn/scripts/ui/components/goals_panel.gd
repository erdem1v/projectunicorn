extends Control

# Hedefler paneli: rayın Hedefler satırına basınca rayın kenarında, haber bandının üstünde açılır. Sıra: başlık;
# Frank'in portresi (ipucunda son tavsiyesi), listenin adı ve sayısı; şimdiki adım büyük, sekmesine giden düğmesi
# ve sayılı adımda çubuğu; listenin merdiveni; sıradaki liste kilitli. Panel saati durdurmaz ve ofisin tıklamasını
# almaz. Açıkken GameShell/PanelLayer'da oturur, orada Esc'in sahibi odur; ✕, Esc, satır ve bir sekmenin
# açılması onu kapatır. Hedefin tek kaynağı ChequeRead; satır (LeftTabs) hedef değişince paint()'i çağırır.
# Preload'la okunur: paylaşılan checkout'ta yeni bir class_name öteki oturumların headless koşularını düşürüyor.

const ChequeRead := preload("res://scripts/systems/cheque_read.gd")
const INBOX := preload("res://scripts/ui/components/inbox.gd")
const BarKit := preload("res://scripts/ui/components/bar_kit.gd")
const GOALS_ICON := preload("res://assets/icons/world/milestone.svg")
const CHECK_ICON := preload("res://assets/icons/util/check.svg")
const LOCK_ICON := preload("res://assets/icons/util/lock.svg")
const GO_ICON := preload("res://assets/icons/util/arrow_right.svg")

const WIDTH := 392.0

var _rail: Control
var _last_row: Control
var _card := PanelContainer.new()
var _title := UiFactory.make_label("", &"FloatTitle")
var _body := SprintUiShared.column(0)
var _face: TextureRect


## `rail` panelin yaslandığı raydır, `last_row` rayın en alt satırı: rayın sağ kenarı panelin sol kenarı, o satırın
## dibi panelin dibidir.
func _init(rail: Control, last_row: Control) -> void:
	_rail = rail
	_last_row = last_row
	theme = load(UiTokens.MENAJER_THEME)
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_card.theme_type_variation = &"FloatPanel"
	_card.custom_minimum_size.x = WIDTH
	_card.grow_vertical = Control.GROW_DIRECTION_BEGIN
	_card.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	add_child(_card)
	var col := SprintUiShared.column(0)
	_card.add_child(col)
	var head := PanelContainer.new()
	head.theme_type_variation = &"FloatHead"
	col.add_child(head)
	var line := SprintUiShared.box(UiTokens.SPACE_L)
	head.add_child(line)
	line.add_child(BarKit.glyph(GOALS_ICON, UiTokens.D_ICON_TITLE, UiTokens.D_INK_2))
	_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	line.add_child(_title)
	line.add_child(UiFactory.make_close_button(queue_free, true))
	col.add_child(_body)


func _ready() -> void:
	# Offset'ler de kurulmazsa CanvasLayer çocuğu olan kökün boyu (0,0) okunur.
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	EventBus.tab_changed.connect(func(id: String) -> void:
		if id != "":
			queue_free())
	# Haber bandı açılıp kapanınca ve ray daralınca son satır yer değiştirir; panel onu izler.
	_last_row.item_rect_changed.connect(_place)
	# Tavsiye her an değişebilir ve teslim saati gelince görünür.
	EventBus.mentor_advisory_changed.connect(_tip_face.unbind(2))
	EventBus.hour_changed.connect(_tip_face.unbind(1))
	_place()
	paint()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		queue_free()


## Rayın sağında, son satırının dibine yaslı; kart içeriğiyle yukarı uzar.
func _place() -> void:
	var rail_right: float = _rail.get_global_rect().end.x
	_card.offset_left = rail_right
	_card.offset_right = rail_right + WIDTH
	_card.offset_bottom = _last_row.get_global_rect().end.y - get_viewport_rect().size.y
	_card.offset_top = _card.offset_bottom


func paint() -> void:
	_title.text = Fmt.upper(tr("GOALS_TITLE"))
	UiFactory.clear(_body)
	var goal: Dictionary = ChequeRead.summary()
	var line := SprintUiShared.box(UiTokens.SPACE_L)
	_band(line, UiTokens.SPACE_XL, UiTokens.SPACE_XL)
	_face = UiFactory.make_mentor_avatar(UiTokens.D_AVATAR_DOC)
	line.add_child(_face)
	_tip_face()
	var title := SprintUiShared.label(tr(goal.title_key), &"ValueTextStrong")
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	line.add_child(title)
	line.add_child(_count(goal, &"CardEffort"))
	_band(HSeparator.new(), 0, 0)
	if not goal.next.is_empty():
		_hero(goal.next)
	_band(_ladder(ChequeRead.steps(), UiTokens.D_H_ROW_SM, false), UiTokens.SPACE_XS, UiTokens.SPACE_XL)
	var later: String = ChequeRead.following(goal.list)
	if later == "":
		return
	_body.add_child(HSeparator.new())
	var col := SprintUiShared.column(0)
	_band(col, UiTokens.SPACE_L, UiTokens.SPACE_L)
	var row := SprintUiShared.box(UiTokens.SPACE_L)
	row.custom_minimum_size.y = UiTokens.D_H_SHEET_ROW
	row.add_child(BarKit.glyph(LOCK_ICON, UiTokens.D_ICON_ROW, UiTokens.D_INK_4))
	var after: Dictionary = ChequeRead.summary(later)
	var head := SprintUiShared.label(Fmt.upper(tr(after.title_key)), &"KeyLabel")
	head.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(head)
	row.add_child(_count(after, &"SegCount"))
	col.add_child(row)
	col.add_child(_ladder(ChequeRead.steps(later), UiTokens.D_H_SHEET_ROW, true))


## Frank's latest advice, the office notice stack's line: none before it arrives (MailClock) or with no advice.
func _tip_face() -> void:
	var said: bool = GameState.mentor_line_key != "" and MailClock.delivered(GameState.mentor_line_at)
	_face.mouse_filter = Control.MOUSE_FILTER_STOP if said else Control.MOUSE_FILTER_IGNORE
	_face.tooltip_text = tr("FIN_MENTOR_QUOTE_WRAPPED").format(
		{"quote": tr(GameState.mentor_line_key).format(GameState.mentor_line_args)}) if said else ""


## The step the list stands on: its words large and the button to its tab; a step with a figure has its bar.
func _hero(step: Dictionary) -> void:
	var col := SprintUiShared.column(UiTokens.SPACE_L)
	_band(col, UiTokens.SPACE_XL, UiTokens.SPACE_XL)
	var top := SprintUiShared.box(UiTokens.SPACE_L)
	col.add_child(top)
	var title := SprintUiShared.prose(INBOX.goal_step(step), &"GoalTitle")
	title.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	top.add_child(title)
	var go := Button.new()
	go.theme_type_variation = &"SecondaryButtonSmall"
	go.focus_mode = Control.FOCUS_NONE
	go.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	go.text = tr("GOAL_GO_" + String(step.tab).to_upper())
	go.icon = GO_ICON
	go.icon_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	go.pressed.connect(EventBus.tab_changed.emit.bind(String(step.tab)))
	top.add_child(go)
	if not step.has("target"):
		return
	var bar := SprintUiShared.box(UiTokens.SPACE_L)
	col.add_child(bar)
	bar.add_child(HRUiShared.D_bar(Vector2(0, UiTokens.D_H_BAR), float(step.value) / float(step.target), UiTokens.D_INK_2))
	var figure := SprintUiShared.box(UiTokens.SPACE_XS)
	figure.add_child(SprintUiShared.label(Fmt.money_chip(int(step.value)), &"DataStrong"))
	figure.add_child(SprintUiShared.label(tr("GOAL_OF").format({"target": Fmt.money_chip(int(step.target))}), &"NoteMuted"))
	bar.add_child(figure)


## A list's steps down a line through their discs: a done step a tick in its disc, the step the list stands on an ink
## ring, the rest an open ring. A locked list stands on no step and dims its words.
func _ladder(steps: Array, row_h: int, locked: bool) -> VBoxContainer:
	var col := SprintUiShared.column(0)
	var now: int = -1 if locked else steps.map(func(s: Dictionary) -> bool: return s.done).find(false)
	var mark: int = UiTokens.D_ICON_ROW
	for i in steps.size():
		var row := SprintUiShared.box(UiTokens.SPACE_L)
		row.custom_minimum_size.y = row_h
		var disc: Control = PanelContainer.new() if steps[i].done else Panel.new()
		disc.theme_type_variation = &"MilestoneDot" if steps[i].done else (&"StepNow" if i == now else &"LockDisc")
		disc.custom_minimum_size = Vector2.ONE * mark
		disc.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		if steps[i].done:
			var tick := BarKit.glyph(CHECK_ICON, UiTokens.D_ICON_MARK, UiTokens.D_pos())
			tick.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
			disc.add_child(tick)
		row.add_child(disc)
		row.add_child(SprintUiShared.label(INBOX.goal_step(steps[i]),
			&"MetaFaint" if locked else (&"DataStrong" if i == now else &"NoteMuted")))
		col.add_child(row)
	# The line runs between the discs, so an open ring stays hollow.
	col.draw.connect(func() -> void:
		var x: float = mark / 2.0 - UiTokens.BORDER_HAIRLINE / 2.0
		for i in steps.size() - 1:
			col.draw_rect(Rect2(x, i * row_h + (row_h + mark) / 2.0, UiTokens.BORDER_HAIRLINE, row_h - mark),
				UiTokens.D_LINE_2))
	return col


## "4/5", in `variation`.
func _count(goal: Dictionary, variation: StringName) -> Label:
	return SprintUiShared.label(tr("FIN_GOAL_PROGRESS").format({"met": goal.done, "total": goal.total}), variation)


## `part` as a band of the body: the card's side inset, `top` and `bottom` above and under it.
func _band(part: Control, top: int, bottom: int) -> void:
	_body.add_child(SprintUiShared.pad(part, Vector4i(UiTokens.SPACE_XXL, top, UiTokens.SPACE_XXL, bottom)))
