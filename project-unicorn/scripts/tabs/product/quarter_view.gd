class_name QuarterView
extends VBoxContainer

# ÇEYREK görünümü: üstte hedef şeridi, altta dar alan paneli ve altı sprint sütunu (bu sprint,
# PM'in önerdikleri, boşlar). Yalnız modeli çizer; onay ve hedef seçimi eylem olarak çıkar.

signal action(kind: String, args: Dictionary)   # approve {sprint} · approve_all · edit {sprint} · pick_goal {area_id}

const SPRINT_CARD := preload("res://scenes/tabs/product/SprintCard.tscn")
const FRAMES := {"current": &"FolderColumnActive", "proposed": &"FolderColumn", "empty": &"FolderColumnDashed"}


## Hedefin kareleri: `now` kadarı alan renginde dolu, `target` karesinin önünde amber çizgi.
class GoalMeter extends Control:
	var goal: Dictionary

	func _init(g: Dictionary) -> void:
		goal = g
		var step: int = UiTokens.PRODUCT_SLICE_PX + UiTokens.SPACE_XXS
		custom_minimum_size = Vector2(int(g.total) * step + UiTokens.BORDER_FOCUS,
			UiTokens.PRODUCT_SLICE_PX + 2 * UiTokens.SPACE_XS)
		size_flags_vertical = Control.SIZE_SHRINK_CENTER
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func _draw() -> void:
		var px: float = UiTokens.PRODUCT_SLICE_PX
		var step: float = px + UiTokens.SPACE_XXS
		var target: int = int(goal.target)
		draw_rect(Rect2(target * step, 0.0, UiTokens.BORDER_FOCUS, size.y), UiTokens.ACCENT_DEEP)
		for i in int(goal.total):
			var x: float = i * step + (UiTokens.BORDER_FOCUS + UiTokens.SPACE_XXS if i >= target else 0)
			var r := Rect2(x, UiTokens.SPACE_XS, px, px)
			if i < int(goal.now):
				draw_rect(r, UiTokens.area_color(int(goal.slot)))
			else:
				draw_rect(r, UiTokens.CARD_BG)
				draw_rect(r.grow(-UiTokens.BORDER_HAIRLINE / 2.0), UiTokens.BORDER_HOVER, false, UiTokens.BORDER_HAIRLINE)


## Hedef seçilmemişse şerit yok. Dar alan paneli sahnedeyken kurulur.
func setup(model: Dictionary) -> void:
	UiFactory.clear(self)
	add_theme_constant_override(&"separation", UiTokens.SPACE_L)
	if model.quarter.goal != null:
		add_child(_goal_strip(model.quarter.goal, model.areas))

	var body := HBoxContainer.new()
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override(&"separation", UiTokens.PRODUCT_PANEL_GAP)
	add_child(body)
	var areas := AreaPanel.new()
	areas.action.connect(action.emit)
	var area_scroll := _vscroll(areas)
	area_scroll.custom_minimum_size.x = UiTokens.PRODUCT_QUARTER_AREA_W
	body.add_child(area_scroll)
	areas.setup(model, true)

	var right := VBoxContainer.new()
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right.add_theme_constant_override(&"separation", UiTokens.SPACE_L)
	body.add_child(right)
	var columns := HBoxContainer.new()
	columns.size_flags_vertical = Control.SIZE_EXPAND_FILL
	columns.add_theme_constant_override(&"separation", UiTokens.SPACE_M)
	right.add_child(columns)
	for col in model.quarter.columns:
		columns.add_child(_column(col, col.sprint == model.next.sprint))
	var approve_all := _button("PRODUCT_APPROVE_ALL", &"PrimaryButton", "approve_all", {})
	approve_all.size_flags_horizontal = Control.SIZE_SHRINK_END
	right.add_child(approve_all)


func _goal_strip(goal: Dictionary, areas: Array) -> PanelContainer:
	var strip := PanelContainer.new()
	strip.theme_type_variation = &"GoalStrip"
	strip.custom_minimum_size.y = UiTokens.PRODUCT_GOAL_STRIP_H
	strip.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	strip.gui_input.connect(func(ev: InputEvent) -> void:
		if UiFactory.is_left_click(ev):
			_open_goal_menu(strip, areas))
	var row := HBoxContainer.new()
	row.add_theme_constant_override(&"separation", UiTokens.SPACE_L)
	strip.add_child(row)
	row.add_child(SprintUiShared.stamp(tr("PRODUCT_THIS_QUARTER"), &"SectionAmber"))
	row.add_child(SprintUiShared.swatch(int(goal.slot), UiTokens.SPACE_M))
	row.add_child(SprintUiShared.stamp(goal.area_name, &"AreaName"))
	var sentence := SprintUiShared.stamp(SprintUiShared.SEP.lstrip(" ") + String(goal.text), &"AreaSentence")
	sentence.size_flags_horizontal = Control.SIZE_EXPAND_FILL   # kareleri ve sayıyı sağa iter
	row.add_child(sentence)
	row.add_child(GoalMeter.new(goal))
	row.add_child(SprintUiShared.stamp(goal.progress_text, &"DataMono"))
	return strip


func _open_goal_menu(anchor: Control, areas: Array) -> void:
	var menu := PopupMenu.new()
	menu.theme_type_variation = &"SettingsPopup"
	for a in areas:
		menu.add_item(a.name)
	add_child(menu)
	# Ertelenmiş: sekme eylemde yeniden kurar; menü kendi sinyali akarken ağaçtan sökülmez.
	menu.id_pressed.connect(func(i: int) -> void:
		action.emit.call_deferred("pick_goal", {"area_id": areas[i].id}))
	menu.popup_hide.connect(menu.queue_free, CONNECT_ONE_SHOT)
	menu.position = Vector2i(anchor.get_screen_position()) + Vector2i(0, int(anchor.size.y))
	menu.popup()


## Düzenle SPRINT görünümünün sonraki sütununu açar; orada yalnız sonraki sprint durur.
func _column(col: Dictionary, editable: bool) -> MarginContainer:
	# Çerçeve içeriğin arkasında ayrı bir Panel: bu sprintin amber bandı sütunun kenarına
	# dayanır, tema sütunları ise içeriği kendi dolgusuyla içeri iterdi.
	var column := MarginContainer.new()
	column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var frame := Panel.new()
	frame.theme_type_variation = FRAMES[col.kind]
	column.add_child(frame)
	if col.kind == "empty":
		SprintUiShared.dashed_outline(frame)
	var outer := VBoxContainer.new()
	outer.add_theme_constant_override(&"separation", 0)
	column.add_child(outer)

	var inner := VBoxContainer.new()
	inner.add_theme_constant_override(&"separation", UiTokens.SPACE_M)
	if col.kind == "current":
		var band := PanelContainer.new()
		band.theme_type_variation = &"QuarterHeaderBand"
		band.add_child(_header(col))
		outer.add_child(band)
	else:
		inner.add_child(_header(col))
	var pad := MarginContainer.new()
	pad.size_flags_vertical = Control.SIZE_EXPAND_FILL
	for side in [&"margin_left", &"margin_top", &"margin_right", &"margin_bottom"]:
		pad.add_theme_constant_override(side, UiTokens.SPACE_M)
	pad.add_child(inner)
	outer.add_child(pad)

	var stack := VBoxContainer.new()
	stack.add_theme_constant_override(&"separation", UiTokens.PRODUCT_CARD_GAP)
	var scroll := _vscroll(stack)
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	inner.add_child(scroll)
	for c in col.cards:
		var card: SprintCard = SPRINT_CARD.instantiate()
		card.compact = true
		stack.add_child(card)
		card.setup(c, false)

	if col.kind == "proposed" and col.approved:
		var stamp := SprintUiShared.stamp(tr("PRODUCT_APPROVED"), &"Stamp")
		stamp.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		inner.add_child(stamp)
	elif col.kind == "proposed":
		var approve_row := HBoxContainer.new()
		approve_row.add_theme_constant_override(&"separation", UiTokens.SPACE_S)
		var args := {"sprint": col.sprint}
		var buttons: Array = [_button("PRODUCT_APPROVE", &"PrimaryButtonSmall", "approve", args)]
		if editable:
			buttons.append(_button("PRODUCT_EDIT", &"InkButton", "edit", args))
		for b: Button in buttons:
			b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			approve_row.add_child(b)
		inner.add_child(approve_row)
	return column


## "SPRINT N" (+ BU SPRINT | PM), kapasite çubuğu ve x/y, bayraklar.
func _header(col: Dictionary) -> VBoxContainer:
	var head := VBoxContainer.new()
	head.add_theme_constant_override(&"separation", UiTokens.SPACE_S)
	var title := HBoxContainer.new()
	title.add_theme_constant_override(&"separation", UiTokens.SPACE_S)
	head.add_child(title)
	title.add_child(SprintUiShared.stamp(tr("PRODUCT_SPRINT_TITLE").format({"n": col.sprint}),
		&"RowMeta" if col.kind == "empty" else &"RowMetaStrong"))
	if col.kind == "current":
		title.add_child(SprintUiShared.stamp(tr("PRODUCT_THIS_SPRINT"), &"SectionAmber"))
	if col.pm:
		var pm := SprintUiShared.avatar(tr("PRODUCT_PM"), "", UiTokens.PRODUCT_BADGE_PX, false)
		pm.size_flags_horizontal = Control.SIZE_EXPAND | Control.SIZE_SHRINK_END
		title.add_child(pm)
	if col.capacity != null:
		head.add_child(SprintUiShared.capacity_row(col.capacity, &"DataMono"))
	for flag in col.flags:
		head.add_child(SprintUiShared.flag(flag))
	return head


func _vscroll(child: Control) -> ScrollContainer:
	var scroll := ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	child.size_flags_horizontal = Control.SIZE_EXPAND_FILL   # kaydırıcı genişliği ancak EXPAND'li çocuğa verir
	scroll.add_child(child)
	return scroll


func _button(key: String, variation: StringName, kind: String, args: Dictionary) -> Button:
	var b := Button.new()
	b.theme_type_variation = variation
	b.text = tr(key)
	b.focus_mode = Control.FOCUS_NONE   # boşluk tuşu hız tuşudur; odak onu yutmasın
	b.pressed.connect(action.emit.bind(kind, args))
	return b
