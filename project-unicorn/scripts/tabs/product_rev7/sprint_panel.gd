class_name SprintPanel
extends HBoxContainer

# Ürün sekmesinin orta (bu sprint) ve sağ (sonraki sprint) sütunları. Yalnız modeli çizer:
# izin ve eşikler modelden bool gelir, her tık sekmeye `action` olarak çıkar.

signal action(kind: String, args: Dictionary)

const CARD_SCENE := preload("res://scenes/tabs/product_rev7/SprintCard.tscn")
const RESULT_KEYS := {"expected": "PRODUCT_RESULT_EXPECTED", "actual": "PRODUCT_RESULT_ACTUAL"}


## Başlık ve alt sabit, arada kart yığını kayar: yığın uzasa da düğmeler yerinde kalır.
class Column extends PanelContainer:
	var head := VBoxContainer.new()
	var stack := VBoxContainer.new()
	var foot := VBoxContainer.new()

	func _init(variation: StringName, ratio: float) -> void:
		theme_type_variation = variation
		size_flags_horizontal = Control.SIZE_EXPAND_FILL
		size_flags_stretch_ratio = ratio
		var scroll := ScrollContainer.new()
		scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
		scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
		stack.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		stack.add_theme_constant_override(&"separation", UiTokens.PRODUCT_CARD_GAP)
		scroll.add_child(stack)
		head.add_theme_constant_override(&"separation", UiTokens.SPACE_L)
		foot.add_theme_constant_override(&"separation", UiTokens.SPACE_L)
		var col := VBoxContainer.new()
		col.add_theme_constant_override(&"separation", UiTokens.SPACE_L)
		col.add_child(head)
		col.add_child(scroll)
		col.add_child(foot)
		add_child(col)


func _init() -> void:
	add_theme_constant_override(&"separation", UiTokens.PRODUCT_PANEL_GAP)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	# Satırın ilk payı sol alan panelinindir; bu kutu kalan iki payı taşır.
	size_flags_stretch_ratio = UiTokens.PRODUCT_PANEL_RATIOS[1] + UiTokens.PRODUCT_PANEL_RATIOS[2]


func setup(model: Dictionary) -> void:
	UiFactory.clear(self)
	_center(model)
	_next(model.next, model.center.can_add)


func _center(model: Dictionary) -> void:
	var c: Dictionary = model.center
	var col := Column.new(&"FolderColumnActive", UiTokens.PRODUCT_PANEL_RATIOS[1])
	add_child(col)
	if c.mode == "release":
		_release(col, c, model.next.sprint)
		return
	var weeks: String = (tr("PRODUCT_WEEK_OF").format({"w": c.week, "t": c.weeks}) if c.mode == "active"
		else tr(Fmt.count_key("PRODUCT_WEEKS", c.weeks)).format({"n": c.weeks}))
	col.head.add_child(_title_row(c.sprint, weeks, tr("PRODUCT_THIS_SPRINT"), &"SectionAmber"))
	if c.sprint < 0:
		return

	col.head.add_child(SprintUiShared.capacity_row(c.capacity, &"MeetingFigure"))

	var team := HBoxContainer.new()
	team.add_theme_constant_override(&"separation", UiTokens.SPACE_XS)
	for p in c.team:
		team.add_child(SprintUiShared.avatar(p.initials,
			tr("PRODUCT_PERSON_ROLE").format({"name": p.name, "role": p.role_text}), UiTokens.SPACE_3XL, p.me))
	team.add_child(RnDUiShared.spacer())
	if c.warning_text != "":
		var chip := SprintUiShared.semantic_chip(c.warning_text, &"negative")
		var inner := HBoxContainer.new()
		inner.add_theme_constant_override(&"separation", UiTokens.SPACE_S)
		inner.add_child(SprintUiShared.icon("role_test", UiTokens.PRODUCT_ICON_PX, UiTokens.negative()))
		chip.get_child(0).reparent(inner, false)
		chip.add_child(inner)
		team.add_child(chip)
	col.head.add_child(team)

	for card in c.cards:
		var node := _add_card(col.stack, card, c.can_add)
		if card.id == model.ui.hover_card:
			node.show_effort()

	col.foot.add_child(HRUiShared.hairline())
	match c.mode:
		"plan":
			if not c.forecast.is_empty():
				col.stack.add_child(HRUiShared.hairline())
				col.stack.add_child(_label(tr("PRODUCT_AT_SPRINT_END"), &"SectionAmber"))
				col.stack.add_child(SprintUiShared.effect_line(c.forecast, "forecast"))
			if c.lead_tip != null:
				var tip := _lead_row(c.lead_tip,
					_label(tr("PRODUCT_LEAD_TIP").format({"name": c.lead_tip.name}), &"SectionAmber"))
				tip.mouse_filter = Control.MOUSE_FILTER_STOP
				tip.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
				tip.gui_input.connect(func(ev: InputEvent) -> void:
					if UiFactory.is_left_click(ev):
						action.emit("apply_lead", {}))
				col.foot.add_child(tip)
			var start := _primary(tr("PRODUCT_START_SPRINT"), "start", {})
			start.disabled = not c.can_start
			if c.start_block:
				start.tooltip_text = tr("PRODUCT_START_NEED_CARD")
			col.foot.add_child(_foot_row(c.beta, start))
		"active":
			col.stack.add_child(HRUiShared.hairline())
			col.stack.add_child(_label(tr("PRODUCT_STATUS"), &"SectionAmber"))
			var s: Dictionary = c.status
			var status := HBoxContainer.new()
			status.add_theme_constant_override(&"separation", UiTokens.SPACE_S)
			for item in [
				[SprintUiShared.icon("tick", UiTokens.PRODUCT_ICON_PX, UiTokens.positive()),
					tr(Fmt.count_key("PRODUCT_STATUS_CARDS", s.done)).format({"n": s.done}), "PRODUCT_STATUS_DONE"],
				[SprintUiShared.phase_dot("active", UiTokens.ACCENT_DEEP), str(s.running), "PRODUCT_STATUS_RUNNING"],
				[SprintUiShared.icon("bubble", UiTokens.PRODUCT_ICON_PX, UiTokens.ACCENT_DEEP),
					tr(Fmt.count_key("PRODUCT_STATUS_DECISIONS", s.decisions)).format({"n": s.decisions}),
					"PRODUCT_STATUS_WAITING"],
			]:
				if status.get_child_count() > 0:
					status.add_child(_label(SprintUiShared.SEP.strip_edges(), &"RowMeta"))
				status.add_child(item[0])
				status.add_child(_label(item[1], &"RowMetaStrong"))
				status.add_child(_label(tr(item[2]), &"RowMeta"))
			col.stack.add_child(status)
			var nv: Variant = c.next_version
			if nv != null:
				var eta := PackedStringArray()
				if nv.weeks >= 0:
					eta.append(tr(Fmt.count_key("PRODUCT_IN_WEEKS", nv.weeks)).format({"n": nv.weeks}))
				if nv.beta_extra:
					eta.append(tr("PRODUCT_PLUS_ONE_SPRINT"))
				if nv.cards_left >= 0:
					eta.append(tr(Fmt.count_key("PRODUCT_CARDS_LEFT", nv.cards_left)).format({"n": nv.cards_left}))
				var version := HBoxContainer.new()
				version.add_theme_constant_override(&"separation", UiTokens.SPACE_L)
				version.add_child(_label(tr("PRODUCT_NEXT_RELEASE"), &"SectionAmber"))
				version.add_child(_label(nv.label, &"DataMonoLarge"))
				version.add_child(_label(SprintUiShared.SEP.join(eta), &"AreaSentence"))
				col.foot.add_child(version)
			col.foot.add_child(_foot_row(c.beta, null))


## Sürüm notu: sprint kapanınca orta sütunun yerini alır.
func _release(col: Column, c: Dictionary, next_sprint: int) -> void:
	var r: Dictionary = c.release
	var head := HBoxContainer.new()
	head.add_theme_constant_override(&"separation", UiTokens.SPACE_S)
	head.add_child(_label(tr("PRODUCT_RELEASE_NOTE"), &"SectionAmber"))
	head.add_child(_label(tr("PRODUCT_SPRINT_END").format({"n": c.sprint}), &"RowMeta"))
	col.head.add_child(head)

	if r.version == "":
		col.stack.add_child(_label(tr("PRODUCT_NO_RELEASE"), &"RowName"))
	else:
		var version := HBoxContainer.new()
		version.add_theme_constant_override(&"separation", UiTokens.SPACE_L)
		version.add_child(_label(r.version, &"DataMonoHero"))
		if not r.beta:
			version.add_child(SprintUiShared.semantic_chip(tr("PRODUCT_LIVE"), &"positive"))
		col.stack.add_child(version)
		if r.beta:
			col.stack.add_child(_label(tr("PRODUCT_RELEASE_BETA"), &"AreaSentence"))

	if not r.shipped.is_empty():
		col.stack.add_child(_label(tr("PRODUCT_SHIPPED"), &"SectionLabel"))
	for card in r.shipped:
		var row := _release_row(col.stack, card.kind, card.slot, card.name)
		row.add_child(SprintUiShared.icon("tick", UiTokens.PRODUCT_ICON_PX, UiTokens.positive()))
		row.add_child(SprintUiShared._square(_label(str(card.effort), &"DataMonoBox"), UiTokens.PRODUCT_BADGE_PX))

	if not r.carried.is_empty():
		col.stack.add_child(_label(tr("PRODUCT_CARRIED_OVER"), &"SectionLabel"))
	for item in r.carried:
		var row := _release_row(col.stack, item.kind, item.slot, item.name)
		# Biten puan dolu, kalan boş kare: devreden kart ilerlemesiyle taşınır.
		row.add_child(SprintUiShared.slices(item.done, UiTokens.PRODUCT_SLICE_PX_SMALL, UiTokens.area_color(item.slot),
			item.total))
		row.add_child(SprintUiShared.icon("arrow", UiTokens.PRODUCT_ICON_PX, UiTokens.ACCENT_DEEP))
		row.add_child(_label(tr("PRODUCT_TAG_SPRINT").format({"n": item.to_sprint}), &"SectionAmber"))

	var v: Dictionary = r.velocity
	var speed := HBoxContainer.new()
	speed.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	speed.add_theme_constant_override(&"separation", UiTokens.SPACE_L)
	speed.add_child(_label("%d/%d" % [v.done, v.total], &"DataMonoLarge"))
	speed.add_child(_wrap(tr(Fmt.count_key("PRODUCT_VELOCITY_LINE", v.total)).format({"done": v.done, "total": v.total}),
		&"AreaSentence"))
	var rows: Array = [["PRODUCT_VELOCITY", speed]]
	if r.result != null:
		rows.append(["PRODUCT_RESULT",
			_wrap(tr(RESULT_KEYS[r.result.kind]).format({"text": r.result.text}), &"RowName")])
	if r.press != "":
		rows.append(["PRODUCT_PRESS", _wrap(r.press, &"TickerLabel")])
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override(&"h_separation", UiTokens.SPACE_XL)
	grid.add_theme_constant_override(&"v_separation", UiTokens.SPACE_L)
	for pair in rows:
		grid.add_child(_label(tr(pair[0]), &"MicroLabel"))
		grid.add_child(pair[1])
	col.stack.add_child(HRUiShared.hairline())
	col.stack.add_child(grid)

	col.stack.add_child(HRUiShared.hairline())
	col.stack.add_child(_lead_row(r.lead, _label(tr("PRODUCT_LEAD_LINE").format({"name": r.lead.name}), &"RowMeta")))

	col.foot.add_child(HRUiShared.hairline())
	col.foot.add_child(_foot_row(c.beta,
		_primary(tr("PRODUCT_PLAN_SPRINT").format({"n": next_sprint}), "plan_next", {"sprint": next_sprint})))


func _next(next: Dictionary, can_add: bool) -> void:
	var col := Column.new(&"FolderColumnDashed", UiTokens.PRODUCT_PANEL_RATIOS[2])
	SprintUiShared.dashed_outline(col)
	add_child(col)
	col.head.add_child(_title_row(next.sprint, "", tr("PRODUCT_NEXT"), &"MicroLabel"))
	if next.sprint < 0:
		return
	for flag in next.flags:
		col.head.add_child(SprintUiShared.flag(flag))
	for card in next.cards:
		_add_card(col.stack, card, can_add)
	if next.cards.is_empty():
		col.stack.add_child(_label(tr("PRODUCT_NEXT_EMPTY"), &"EmptyRowLabel"))


## "SPRINT 7 · 2 hafta ... BU SPRINT". Sprint yokken (canlı model) yalnız sağdaki etiket kalır.
func _title_row(sprint: int, meta: String, tag: String, tag_variation: StringName) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override(&"separation", UiTokens.SPACE_S)
	if sprint >= 0:
		row.add_child(_label(tr("PRODUCT_SPRINT_TITLE").format({"n": sprint}), &"AreaName"))
		if meta != "":
			row.add_child(_label(SprintUiShared.SEP.strip_edges(), &"RowMeta"))
			row.add_child(_label(meta, &"RowMeta"))
	row.add_child(RnDUiShared.spacer())
	row.add_child(_label(tag, tag_variation))
	return row


func _add_card(box: VBoxContainer, card: Dictionary, can_add: bool) -> SprintCard:
	var node: SprintCard = CARD_SCENE.instantiate()
	box.add_child(node)
	node.setup(card, can_add)
	node.action.connect(action.emit)
	return node


## Sürüm notunun liste satırı: üstte saç teli, tür ikonu alan renginde, ad; sağ ucu çağıran doldurur.
func _release_row(box: VBoxContainer, kind: String, slot: int, card_name: String) -> HBoxContainer:
	box.add_child(HRUiShared.hairline())
	var row := HBoxContainer.new()
	row.add_theme_constant_override(&"separation", UiTokens.SPACE_M)
	row.add_child(SprintUiShared.icon("kind_" + kind, UiTokens.PRODUCT_ICON_PX, UiTokens.area_color(slot)))
	row.add_child(_label(card_name, &"DataMono"))
	row.add_child(RnDUiShared.spacer())
	box.add_child(row)
	return row


## Liderin önerisi (planlama) ve sürüm notundaki lider cümlesi: avatar, başlık, italik cümle.
func _lead_row(lead: Dictionary, caption: Label) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override(&"separation", UiTokens.SPACE_M)
	row.add_child(SprintUiShared.avatar(lead.initials, lead.name, UiTokens.SPACE_3XL, false))
	var words := VBoxContainer.new()
	words.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	words.add_theme_constant_override(&"separation", UiTokens.SPACE_XXS)
	words.add_child(caption)
	words.add_child(_wrap(lead.text, &"LeadQuote"))
	row.add_child(words)
	return row


## Alt satır: solda beta kanalı anahtarı (model veriyorsa), sağda birincil düğme (varsa).
func _foot_row(beta: Variant, button: Button) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override(&"separation", UiTokens.SPACE_M)
	if beta != null:
		row.add_child(_label(tr("PRODUCT_BETA_CHANNEL"), &"RowMetaStrong"))
		row.add_child(SprintUiShared.dial([tr("PRODUCT_OFF"), tr("PRODUCT_ON")], int(beta.open),
			func(i: int) -> void: action.emit("beta", {"open": i == 1})))
	row.add_child(RnDUiShared.spacer())
	if button != null:
		row.add_child(button)
	return row


func _primary(text: String, kind: String, args: Dictionary) -> Button:
	var b := Button.new()
	b.theme_type_variation = &"PrimaryButton"
	b.text = text
	b.pressed.connect(action.emit.bind(kind, args))
	return b


## Bir satırdaki farklı boy etiketler dikeyde ortalanır.
func _label(text: String, variation: StringName) -> Label:
	var l := UiFactory.make_label(text, variation)
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	return l


func _wrap(text: String, variation: StringName) -> Label:
	var l := _label(text, variation)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return l
