class_name QuarterView
extends VBoxContainer

# ÇEYREK görünümü: üstte hedef şeridi, altta dar alan paneli ve altı sprint sütunu (bu sprint, PM'in
# önerdikleri, boşlar); sütunlar en uzununun içeriği kadar uzar, onay düğmeleri kartların hemen altında.
# Yalnız modeli çizer; onay ve hedef seçimi eylem olarak çıkar.

signal action(kind: String, args: Dictionary)   # approve {sprint} · approve_all · edit {sprint} · pick_goal {area_id}

const SPRINT_CARD := preload("res://scenes/tabs/product/SprintCard.tscn")
const LOOKS := {"current": &"SprintColumnCurrent", "proposed": &"SprintColumn", "empty": &"SprintColumnNext"}
const CHEVRON := "res://assets/icons/util/chevron_down.svg"


## Hedefin on karesi: `now` kadarı dolu, `target` karesinin önünde hedef çizgisi. Doluluk yargısız,
## nötr mürekkepte.
class GoalMeter extends Control:
	var goal: Dictionary

	func _init(g: Dictionary) -> void:
		goal = g
		custom_minimum_size = Vector2(int(g.total) * (UiTokens.D_SQUARE + UiTokens.SPACE_XXS) + UiTokens.SPACE_S,
			UiTokens.D_GOAL_TICK.y)
		size_flags_vertical = Control.SIZE_SHRINK_CENTER
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func _draw() -> void:
		var px: float = UiTokens.D_SQUARE
		var step: float = px + UiTokens.SPACE_XXS
		var target: int = int(goal.target)
		var top: float = (size.y - px) / 2.0
		for i in int(goal.total):
			var r := Rect2(i * step + (UiTokens.SPACE_S if i >= target else 0), top, px, px)
			if i < int(goal.now):
				draw_rect(r, UiTokens.D_BAR_EMPH)
			else:
				draw_rect(r.grow(-UiTokens.BORDER_HAIRLINE / 2.0), UiTokens.D_LINE_3, false, UiTokens.BORDER_HAIRLINE)
		var line_x: float = target * step + (UiTokens.SPACE_S - UiTokens.SPACE_XXS - UiTokens.D_GOAL_TICK.x) / 2.0
		draw_rect(Rect2(line_x, 0.0, UiTokens.D_GOAL_TICK.x, size.y), UiTokens.D_INK_1)


## Hedef seçilmemişse şerit yok. Dar alan paneli sahnedeyken kurulur.
func setup(model: Dictionary) -> void:
	UiFactory.clear(self)
	add_theme_constant_override("separation", UiTokens.SPACE_XL)
	if model.quarter.goal != null:
		add_child(_goal_strip(model.quarter.goal, model.areas))

	var body := SprintUiShared.box(UiTokens.SPACE_XL)
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(body)
	var scroll := ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.custom_minimum_size.x = UiTokens.D_W_AREAS_NARROW
	var areas := AreaPanel.new()
	areas.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	areas.action.connect(action.emit)
	scroll.add_child(areas)
	body.add_child(scroll)
	areas.setup(model, true)

	var right := SprintUiShared.column(UiTokens.SPACE_XL)
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_child(right)
	var columns := SprintUiShared.box(UiTokens.SPACE_M)
	right.add_child(columns)
	for col in model.quarter.columns:
		columns.add_child(_column(col, col.sprint == model.next.sprint))
	var approve_all := SprintUiShared.button(tr("PRODUCT_APPROVE_ALL"), &"PrimaryButtonDark", action.emit.bind("approve_all", {}))
	approve_all.size_flags_horizontal = Control.SIZE_SHRINK_END
	right.add_child(approve_all)


## The window fits the quarter's content: the goal strip, then the taller of the areas and the columns.
func content_height() -> float:
	var strip: float = get_child(0).get_combined_minimum_size().y + UiTokens.SPACE_XL if get_child_count() > 1 else 0.0
	var body: HBoxContainer = get_child(-1)
	var areas: AreaPanel = body.get_child(0).get_child(0)
	return strip + maxf(areas.get_combined_minimum_size().y, body.get_child(1).get_combined_minimum_size().y)


## BU ÇEYREK · alan · hedef cümlesi ... on kare ölçer · ilerleme · ok. Tık hedef menüsünü açar.
func _goal_strip(goal: Dictionary, areas: Array) -> PanelContainer:
	var strip := PanelContainer.new()
	strip.theme_type_variation = &"OptionBar"
	strip.custom_minimum_size.y = UiTokens.D_H_GOAL
	strip.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	strip.mouse_entered.connect(func() -> void: strip.theme_type_variation = &"OptionBarHover")
	strip.mouse_exited.connect(func() -> void: strip.theme_type_variation = &"OptionBar")
	strip.gui_input.connect(func(ev: InputEvent) -> void:
		if UiFactory.is_left_click(ev):
			_open_goal_menu(strip, areas, String(goal.area_id)))
	var row := SprintUiShared.box(UiTokens.SPACE_L)
	strip.add_child(row)
	row.add_child(SprintUiShared.label(Fmt.upper(tr("PRODUCT_THIS_QUARTER")), &"KeyLabel"))
	row.add_child(SprintUiShared.label(String(goal.area_name), &"DataStrong"))
	var sentence := SprintUiShared.label(String(goal.text), &"DataText")
	sentence.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sentence.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	row.add_child(sentence)
	row.add_child(GoalMeter.new(goal))
	row.add_child(SprintUiShared.label(String(goal.progress_text), &"MetaMuted"))
	row.add_child(UiFactory.make_glyph(CHEVRON, UiTokens.D_ICON_ROW, UiTokens.D_INK_3))
	for part: Control in row.get_children():
		part.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return strip


## Hedef menüsü şeridin sağ kenarına, okun altına açılır: her alan adıyla ve kendi hedef cümlesiyle;
## tik adın satırında durur. Düğme çocuğunu ölçmez: satırın boyu içeriğinden ve payından okunur.
func _open_goal_menu(anchor: Control, areas: Array, picked: String) -> void:
	var menu := HRPopover.mount(anchor, true)
	menu.body().custom_minimum_size.x = UiTokens.D_W_GOAL_MENU
	menu.body().add_theme_constant_override("separation", 0)
	for a in areas:
		var item := Button.new()
		item.theme_type_variation = &"MenuItem"
		item.focus_mode = Control.FOCUS_NONE
		var row := SprintUiShared.box(UiTokens.SPACE_M)
		var check := UiFactory.make_glyph(SprintUiShared.CHECK, UiTokens.D_ICON_ROW, UiTokens.D_INK_1)
		check.modulate.a = 1.0 if a.id == picked else 0.0
		check.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
		row.add_child(SprintUiShared.pad(check, Vector4i(0, UiTokens.SPACE_XXS, 0, 0)))
		var words := SprintUiShared.column(UiTokens.SPACE_XXS)
		words.add_child(UiFactory.make_label(String(a.name), &"DataMedium", UiTokens.D_INK_1))
		# Menüde tek başına duran cümle büyük harfle başlar; şeritte satır içinde CSV'deki gibi küçük.
		var goal: String = a.goal_text
		words.add_child(UiFactory.make_label(Fmt.upper(goal.left(1)) + goal.substr(1), &"Caption"))
		row.add_child(words)
		var inset := SprintUiShared.pad(row, Vector4i(UiTokens.SPACE_M, UiTokens.SPACE_S, UiTokens.SPACE_M, UiTokens.SPACE_S))
		inset.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		inset.mouse_filter = Control.MOUSE_FILTER_IGNORE
		item.add_child(inset)
		# Ertelenmiş: sekme eylemde yeniden kurar; menü kendi sinyali akarken ağaçtan sökülmez.
		item.pressed.connect(func() -> void:
			menu.close()
			action.emit.call_deferred("pick_goal", {"area_id": a.id}))
		menu.body().add_child(item)
		item.custom_minimum_size.y = inset.get_combined_minimum_size().y
	menu.open_at(anchor, true)


## Düzenle SPRINT görünümünün sonraki sütununu açar; orada yalnız sonraki sprint durur.
func _column(col: Dictionary, editable: bool) -> PanelContainer:
	var column := PanelContainer.new()
	column.theme_type_variation = LOOKS[col.kind]
	column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if col.kind == "empty":
		HRUiShared.D_dashed(column)
	var outer := SprintUiShared.column(0)
	column.add_child(outer)
	var inset := Vector4i(UiTokens.SPACE_M, UiTokens.SPACE_L, UiTokens.SPACE_M, UiTokens.SPACE_L)
	var head := SprintUiShared.pad(_header(col), inset)
	if col.kind == "current":
		var band := PanelContainer.new()
		band.theme_type_variation = &"SprintColumnHead"
		band.add_child(head)
		outer.add_child(band)
	else:
		outer.add_child(head)
	if col.kind == "empty":
		return column

	var stack := SprintUiShared.column(UiTokens.SPACE_S)
	stack.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var stack_pad := SprintUiShared.pad(stack, inset)
	stack_pad.size_flags_vertical = Control.SIZE_EXPAND_FILL
	outer.add_child(stack_pad)
	for c in col.cards:
		var card: SprintCard = SPRINT_CARD.instantiate()
		stack.add_child(card)
		card.setup(c, false, SprintCard.Look.MINI)

	if col.kind != "proposed":
		return column
	var foot := SprintUiShared.box(UiTokens.SPACE_S)
	outer.add_child(SprintUiShared.pad(foot, inset))
	if col.approved:
		var stamp := UiFactory.D_stamp(Fmt.upper(tr("PRODUCT_APPROVED")))
		stamp.size_flags_horizontal = Control.SIZE_EXPAND | Control.SIZE_SHRINK_CENTER
		foot.add_child(stamp)
		return column
	var args := {"sprint": col.sprint}
	var buttons: Array = [SprintUiShared.button(tr("PRODUCT_APPROVE"), &"SecondaryButtonSmall", action.emit.bind("approve", args))]
	if editable:
		buttons.append(SprintUiShared.button(tr("PRODUCT_EDIT"), &"GhostButtonSmall", action.emit.bind("edit", args)))
	for b: Button in buttons:
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		foot.add_child(b)
	return column


## "SPRİNT N" (+ BU SPRİNT | PM), kapasite çubuğu ve x/y, bayraklar.
func _header(col: Dictionary) -> VBoxContainer:
	var head := SprintUiShared.column(UiTokens.SPACE_M)
	var title := SprintUiShared.box(UiTokens.SPACE_M)
	title.custom_minimum_size.y = UiTokens.D_H_TAG
	head.add_child(title)
	title.add_child(SprintUiShared.label(Fmt.upper(tr("PRODUCT_SPRINT_TITLE").format({"n": col.sprint})),
		&"KeyLabel" if col.kind == "empty" else &"KeyLabelStrong"))
	if col.kind == "current":
		title.add_child(SprintUiShared.label(Fmt.upper(tr("PRODUCT_THIS_SPRINT")), &"KeySmall"))
	if col.pm:
		title.add_child(RnDUiShared.spacer())
		title.add_child(UiFactory.D_tag(tr("PRODUCT_PM"), &"neutral"))
	if col.capacity != null:
		head.add_child(SprintUiShared.capacity_row(col.capacity, &"DataStrong"))
	for flag in col.flags:
		head.add_child(SprintUiShared.flag(flag.text, flag.k == "deadline"))
	return head
