class_name SprintPanel
extends HBoxContainer

# Ürün sekmesinin orta (bu sprint) ve sağ (sonraki sprint) sütunları. Yalnız modeli çizer: izin ve
# eşikler modelden gelir, her tık sekmeye `action` olarak çıkar. Sütunun başlığı ve alt şeridi sabit,
# arada kart yığını kayar.

signal action(kind: String, args: Dictionary)

const CARD_SCENE := preload("res://scenes/tabs/product/SprintCard.tscn")
const PLAY := "res://assets/icons/util/play.svg"
const PAUSE := "res://assets/icons/util/pause.svg"
const INBOX_GLYPH := "res://assets/icons/util/inbox.svg"
const TEAM_GLYPH := "res://assets/icons/rail/hr.svg"
const PLUS := "res://assets/icons/util/plus.svg"


## Başlık ve alt sabit, arada kart yığını kayar: yığın uzasa da düğmeler yerinde kalır. Alt şerit ilk
## istendiğinde kurulur.
class Column extends PanelContainer:
	var head := SprintUiShared.column(UiTokens.SPACE_L)
	var stack := SprintUiShared.column(UiTokens.SPACE_M)
	var _col := SprintUiShared.column(0)
	var _foot: VBoxContainer

	func _init(variation: StringName, ratio: float) -> void:
		theme_type_variation = variation
		size_flags_horizontal = Control.SIZE_EXPAND_FILL
		size_flags_stretch_ratio = ratio
		add_child(_col)
		_col.add_child(SprintUiShared.pad(head, Vector4i(UiTokens.SPACE_XXL, UiTokens.SPACE_XL, UiTokens.SPACE_XXL, 0)))
		var scroll := ScrollContainer.new()
		scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
		scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
		stack.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		stack.size_flags_vertical = Control.SIZE_EXPAND_FILL
		var inner := SprintUiShared.pad(stack, Vector4i(UiTokens.SPACE_XXL, UiTokens.SPACE_L, UiTokens.SPACE_XXL, UiTokens.SPACE_L))
		inner.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		inner.size_flags_vertical = Control.SIZE_EXPAND_FILL
		scroll.add_child(inner)
		_col.add_child(scroll)

	func foot() -> VBoxContainer:
		if _foot == null:
			var band := PanelContainer.new()
			band.theme_type_variation = &"SprintColumnFoot"
			_foot = SprintUiShared.column(UiTokens.SPACE_XL)
			band.add_child(_foot)
			_col.add_child(band)
		return _foot


func _init() -> void:
	add_theme_constant_override("separation", UiTokens.SPACE_XL)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL


func setup(model: Dictionary) -> void:
	UiFactory.clear(self)
	_center(model)
	_next(model.next, model.center.can_add)


func _center(model: Dictionary) -> void:
	var c: Dictionary = model.center
	var col := Column.new(&"SprintColumn", UiTokens.D_SPRINT_COLUMNS.x)
	add_child(col)
	if c.mode == "release":
		_release(col, c, model.next.sprint)
		return
	var weeks: String = (tr("PRODUCT_WEEK_OF").format({"w": c.week, "t": c.weeks}) if c.mode == "active"
		else tr(Fmt.count_key("PRODUCT_WEEKS", c.weeks)).format({"n": c.weeks}))
	col.head.add_child(_title_row(c.sprint, weeks, "PRODUCT_THIS_SPRINT"))
	if c.sprint < 0:
		return
	if c.auto_started:
		col.head.add_child(_note(PLAY, tr("PRODUCT_AUTO_STARTED"), UiTokens.D_INK_3))
	var cap: Dictionary = c.capacity
	col.head.add_child(SprintUiShared.capacity_row(cap, &"ValueTextStrong"))
	if not c.team.is_empty():
		var team := SprintUiShared.box(UiTokens.SPACE_S)
		for p in c.team:
			team.add_child(SprintUiShared.avatar(p, UiTokens.D_AVATAR_ROW))
		team.add_child(RnDUiShared.spacer())
		if c.warning_text != "":
			team.add_child(_note(SprintUiShared.BUG, c.warning_text, UiTokens.D_warn()))
		col.head.add_child(team)
	if cap.state == "over":
		var over := SprintUiShared.box(UiTokens.SPACE_XL)
		var n: int = c.cards.filter(func(card: Dictionary) -> bool: return card.spills).size()
		over.add_child(_note(SprintUiShared.WARN, tr(Fmt.count_key("PRODUCT_OVER_CAPACITY", n)).format({"n": n}),
			UiTokens.D_warn()))
		if not c.can_add:
			over.add_child(_note("", tr("PRODUCT_ADD_CLOSED").format({"pct": Fmt.percent(c.ceiling_pct, 0)}),
				UiTokens.D_INK_3))
		col.head.add_child(over)

	if c.team.is_empty() and c.cards.is_empty():
		col.stack.add_child(_nobody(c.staffed))
	for card in c.cards:
		var node := _add_card(col.stack, card, c.can_add, SprintCard.Look.WIDE)
		if card.id == model.ui.hover_card:
			node.show_effort()

	match c.mode:
		"plan":
			if not c.forecast.is_empty():
				col.stack.add_child(SprintUiShared.section("PRODUCT_AT_SPRINT_END"))
				col.stack.add_child(SprintUiShared.forecast(c.forecast))
			if c.lead_tip != null:
				var apply := SprintUiShared.button(tr("PRODUCT_LEAD_APPLY"), &"SecondaryButtonSmall",
					action.emit.bind("apply_lead", {}))
				col.foot().add_child(_lead_row(c.lead_tip, "PRODUCT_LEAD_TIP", apply))
			var start := SprintUiShared.button(tr("PRODUCT_START_SPRINT"), &"PrimaryButtonDark", action.emit.bind("start", {}))
			start.disabled = not c.can_start
			if c.start_reason != "":
				var why := _note(SprintUiShared.LOCK, c.start_reason, UiTokens.D_INK_3)
				why.size_flags_horizontal = Control.SIZE_SHRINK_END
				col.foot().add_child(why)
			col.foot().add_child(_foot_row(c.beta, start))
		"active":
			col.stack.add_child(SprintUiShared.section("PRODUCT_STATUS"))
			col.stack.add_child(_status(c.status))
			var nv: Variant = c.next_version
			if nv != null:
				var eta := PackedStringArray()
				if nv.weeks >= 0:
					eta.append(tr(Fmt.count_key("PRODUCT_IN_WEEKS", nv.weeks)).format({"n": nv.weeks}))
				if nv.beta_extra:
					eta.append(tr("PRODUCT_PLUS_ONE_SPRINT"))
				if nv.cards_left >= 0:
					eta.append(tr(Fmt.count_key("PRODUCT_CARDS_LEFT", nv.cards_left)).format({"n": nv.cards_left}))
				var version := SprintUiShared.box(UiTokens.SPACE_L)
				version.add_child(SprintUiShared.label(Fmt.upper(tr("PRODUCT_NEXT_RELEASE")), &"KeyLabel"))
				version.add_child(SprintUiShared.label(String(nv.label), &"FigureValue"))
				version.add_child(SprintUiShared.label(SprintUiShared.SEP.join(eta), &"MetaMuted"))
				col.foot().add_child(version)
			col.foot().add_child(_foot_row(c.beta, null))


## Kimse çalışamıyorken sütunun gövdesi: ekip glifi, not ve çıkış yolu (kadro yoksa işe alım, varsa Ekip).
func _nobody(staffed: bool) -> VBoxContainer:
	var empty := SprintUiShared.column(UiTokens.SPACE_L)
	empty.alignment = BoxContainer.ALIGNMENT_CENTER
	empty.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var glyph := UiFactory.make_glyph(TEAM_GLYPH, UiTokens.D_ICON_EMPTY, UiTokens.D_INK_4)
	glyph.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	empty.add_child(glyph)
	var note := UiFactory.make_label(tr("HR_EMPTY_ROW"), &"NoteMuted")
	note.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	empty.add_child(note)
	var go := SprintUiShared.button(tr("PRODUCT_GO_TEAM" if staffed else "HR_SEARCH_START"), &"SecondaryButton",
		action.emit.bind("team" if staffed else "hire", {}))
	if not staffed:
		go.icon = load(PLUS)
	go.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	empty.add_child(go)
	return empty


## DURUM: "1 kart bitti · 2 sürüyor · 1 karar bekliyor".
func _status(s: Dictionary) -> HBoxContainer:
	var row := SprintUiShared.box(UiTokens.SPACE_M)
	var dot := Control.new()
	dot.custom_minimum_size = Vector2.ONE * UiTokens.D_PHASE_DOT
	dot.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	dot.draw.connect(func() -> void: dot.draw_circle(dot.size / 2.0, UiTokens.D_PHASE_DOT / 2.0, UiTokens.D_INK_1))
	for item in [
		[UiFactory.make_glyph(SprintUiShared.CHECK, UiTokens.D_ICON_ROW, UiTokens.D_pos()),
			tr(Fmt.count_key("PRODUCT_STATUS_CARDS", s.done)).format({"n": s.done}), "PRODUCT_STATUS_DONE"],
		[dot, str(s.running), "PRODUCT_STATUS_RUNNING"],
		[UiFactory.make_glyph(INBOX_GLYPH, UiTokens.D_ICON_ROW, UiTokens.D_INK_3),
			tr(Fmt.count_key("PRODUCT_STATUS_DECISIONS", s.decisions)).format({"n": s.decisions}), "PRODUCT_STATUS_WAITING"],
	]:
		if row.get_child_count() > 0:
			row.add_child(SprintUiShared.label(SprintUiShared.SEP.strip_edges(), &"MetaMuted", UiTokens.D_INK_4))
		row.add_child(item[0])
		row.add_child(SprintUiShared.label(item[1], &"TipTitle"))
		row.add_child(SprintUiShared.label(tr(item[2]), &"MetaMuted"))
	return row


## Sürüm notu: sprint kapanınca orta sütunun yerini alır; açıkken oyun durur.
func _release(col: Column, c: Dictionary, next_sprint: int) -> void:
	var r: Dictionary = c.release
	var head := SprintUiShared.box(UiTokens.SPACE_M)
	head.custom_minimum_size.y = UiTokens.D_H_FX
	head.add_child(SprintUiShared.label(Fmt.upper(tr("PRODUCT_RELEASE_NOTE")), &"KeyLabel"))
	head.add_child(SprintUiShared.label(tr("PRODUCT_SPRINT_END").format({"n": c.sprint}), &"MetaMuted"))
	col.head.add_child(head)

	if r.version == "":
		col.stack.add_child(SprintUiShared.label(tr("PRODUCT_NO_RELEASE"), &"DataText"))
	else:
		var version := SprintUiShared.box(UiTokens.SPACE_XXL)
		version.add_child(SprintUiShared.label(String(r.version), &"ReleaseValue"))
		if not r.beta:
			version.add_child(UiFactory.D_stamp(Fmt.upper(tr("PRODUCT_LIVE"))))
		col.stack.add_child(version)
		if r.beta:
			col.stack.add_child(SprintUiShared.label(tr("PRODUCT_RELEASE_BETA"), &"MetaMuted"))

	if not r.shipped.is_empty():
		col.stack.add_child(SprintUiShared.section("PRODUCT_SHIPPED"))
	for card in r.shipped:
		var row := _release_row(col.stack, card.kind, card.name)
		row.add_child(UiFactory.make_glyph(SprintUiShared.CHECK, UiTokens.D_ICON_ROW, UiTokens.D_pos()))
		var pts := SprintUiShared.label(str(card.effort), &"PtsBoxRaised")
		pts.custom_minimum_size.x = UiTokens.D_W_PTS
		pts.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		row.add_child(pts)

	if not r.carried.is_empty():
		col.stack.add_child(SprintUiShared.section("PRODUCT_CARRIED_OVER"))
	for item in r.carried:
		var row := _release_row(col.stack, item.kind, item.name)
		# Biten puan dolu, kalan boş kare: devreden kart ilerlemesiyle taşınır.
		row.add_child(SprintUiShared.squares(float(item.done), UiTokens.D_SQUARE_SM, UiTokens.D_BAR_EMPH, int(item.total)))
		row.add_child(UiFactory.make_glyph(SprintUiShared.ARROW, UiTokens.D_ICON_PART, UiTokens.D_INK_4))
		row.add_child(SprintUiShared.label(tr("PRODUCT_TAG_SPRINT").format({"n": item.to_sprint}), &"KeyText"))

	var v: Dictionary = r.velocity
	var pts := {"done": SprintUiShared.points(v.done), "total": SprintUiShared.points(v.total)}
	var speed := SprintUiShared.box(UiTokens.SPACE_L)
	speed.add_child(SprintUiShared.label("%s/%s" % [pts.done, pts.total], &"FigureValue"))
	speed.add_child(SprintUiShared.prose(tr(SprintUiShared.points_key("PRODUCT_VELOCITY_LINE", pts.total)).format(pts),
		&"MetaMuted"))
	var rows: Array = [["PRODUCT_VELOCITY", speed]]
	if r.result != null:
		rows.append(["PRODUCT_RESULT", SprintUiShared.result_line(r.result, &"DataText")])
	if not r.press.is_empty():
		var press := SprintUiShared.box(UiTokens.SPACE_S)
		press.add_child(SprintUiShared.label(tr(r.press.outlet), &"DataStrong", UiTokens.D_outlet(r.press.outlet)))
		press.add_child(SprintUiShared.prose(SprintUiShared.SEP.strip_edges() + " " + String(r.press.text), &"DataText"))
		rows.append(["PRODUCT_PRESS", press])
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", UiTokens.SPACE_XL)
	grid.add_theme_constant_override("v_separation", UiTokens.SPACE_L)
	for pair in rows:
		var key := UiFactory.make_label(Fmt.upper(tr(pair[0])), &"KeyLabel")
		key.custom_minimum_size.x = UiTokens.D_W_RESULT_KEY
		grid.add_child(key)
		pair[1].size_flags_horizontal = Control.SIZE_EXPAND_FILL
		grid.add_child(pair[1])
	col.stack.add_child(SprintUiShared.pad(grid, Vector4i(0, UiTokens.SPACE_L, 0, UiTokens.SPACE_M)))
	col.stack.add_child(_lead_row(r.lead, "PRODUCT_LEAD_LINE", null))

	var hold := _note(PAUSE, tr("PRODUCT_RELEASE_HOLD"), UiTokens.D_INK_3)
	hold.size_flags_horizontal = Control.SIZE_SHRINK_END
	col.foot().add_child(hold)
	col.foot().add_child(_foot_row(c.beta, SprintUiShared.button(tr("PRODUCT_PLAN_SPRINT").format({"n": next_sprint}),
		&"PrimaryButtonDark", action.emit.bind("plan_next", {"sprint": next_sprint}))))


func _next(next: Dictionary, can_add: bool) -> void:
	var col := Column.new(&"SprintColumnNext", UiTokens.D_SPRINT_COLUMNS.y)
	HRUiShared.D_dashed(col)
	add_child(col)
	col.head.add_child(_title_row(next.sprint, "", "PRODUCT_NEXT"))
	if next.sprint < 0:
		return
	if not next.flags.is_empty():
		var flags := HFlowContainer.new()
		flags.add_theme_constant_override("h_separation", UiTokens.SPACE_S)
		flags.add_theme_constant_override("v_separation", UiTokens.SPACE_S)
		for flag in next.flags:
			flags.add_child(SprintUiShared.flag(flag.text, flag.k == "deadline"))
		col.head.add_child(flags)
	for card in next.cards:
		_add_card(col.stack, card, can_add, SprintCard.Look.NARROW)
	if next.cards.is_empty():
		col.stack.add_child(SprintUiShared.empty_line(tr("PRODUCT_NEXT_EMPTY")))


## "SPRİNT 7 · 2 hafta ... BU SPRİNT". Sprint yokken (canlı model) yalnız sağdaki etiket kalır.
func _title_row(sprint: int, meta: String, tag_key: String) -> HBoxContainer:
	var row := SprintUiShared.box(UiTokens.SPACE_M)
	row.custom_minimum_size.y = UiTokens.D_H_FX
	if sprint >= 0:
		row.add_child(SprintUiShared.label(Fmt.upper(tr("PRODUCT_SPRINT_TITLE").format({"n": sprint})), &"ColumnTitle"))
		if meta != "":
			row.add_child(SprintUiShared.label(SprintUiShared.SEP.strip_edges() + " " + meta, &"MetaMuted"))
	row.add_child(RnDUiShared.spacer())
	row.add_child(SprintUiShared.label(Fmt.upper(tr(tag_key)), &"KeyLabel"))
	return row


func _add_card(box: VBoxContainer, card: Dictionary, can_add: bool, look: SprintCard.Look) -> SprintCard:
	var node: SprintCard = CARD_SCENE.instantiate()
	box.add_child(node)
	node.setup(card, can_add, look)
	node.action.connect(action.emit)
	return node


## Sürüm notunun satırı: tür glifi ve ad; sağ ucu çağıran doldurur.
func _release_row(box: VBoxContainer, kind: String, card_name: String) -> HBoxContainer:
	var row_panel := PanelContainer.new()
	row_panel.theme_type_variation = &"TableRow"
	row_panel.custom_minimum_size.y = UiTokens.D_H_ROW_RELEASE
	var row := SprintUiShared.box(UiTokens.SPACE_M)
	row_panel.add_child(row)
	row.add_child(UiFactory.make_glyph(SprintUiShared.KIND_ICON % kind, UiTokens.D_ICON_ROW, UiTokens.D_INK_3))
	var title := SprintUiShared.label(card_name, &"DataText")
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(title)
	box.add_child(row_panel)
	return row


## Liderin önerisi (planlama) ve sürüm notundaki lider cümlesi: yüz, anahtar ve ad, cümle; planlamada
## öneriyi uygulayan düğme.
func _lead_row(lead: Dictionary, key: String, apply: Button) -> HBoxContainer:
	var row := SprintUiShared.box(UiTokens.SPACE_L)
	row.add_child(SprintUiShared.avatar(lead, UiTokens.D_AVATAR_ROW))
	var words := SprintUiShared.column(UiTokens.SPACE_XXS)
	words.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var caption := SprintUiShared.box(UiTokens.SPACE_S)
	caption.add_child(SprintUiShared.label(Fmt.upper(tr(key)), &"KeyLabel"))
	caption.add_child(SprintUiShared.label(String(lead.name), &"KeyText"))
	words.add_child(caption)
	words.add_child(SprintUiShared.prose(String(lead.text), &"DataText"))
	row.add_child(words)
	if apply != null:
		row.add_child(apply)
	return row


## Alt satır: solda beta kanalı (model veriyorsa) iki konumlu anahtarıyla, yalnız açık olmayan bölme
## basılır; sağda birincil düğme (varsa).
func _foot_row(beta: Variant, button: Button) -> HBoxContainer:
	var row := SprintUiShared.box(UiTokens.SPACE_L)
	if beta != null:
		row.add_child(SprintUiShared.label(Fmt.upper(tr("PRODUCT_BETA_CHANNEL")), &"KeyLabel"))
		row.add_child(UiFactory.D_seg_pick([{"text": tr("PRODUCT_OFF")}, {"text": tr("PRODUCT_ON")}], int(beta.open),
			func(i: int) -> void: action.emit("beta", {"open": i == 1})))
	row.add_child(RnDUiShared.spacer())
	if button != null:
		row.add_child(button)
	return row


## Uyarı ya da bilgi cümlesi: glifi (varsa) ve metni aynı mürekkepte, büyük harfsiz.
func _note(glyph_path: String, text: String, ink: Color) -> HBoxContainer:
	var row := SprintUiShared.box(UiTokens.SPACE_S)
	if glyph_path != "":
		row.add_child(UiFactory.make_glyph(glyph_path, UiTokens.D_ICON_ROW, ink))
	row.add_child(SprintUiShared.label(text, &"Caption", ink))
	row.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	return row
