class_name TypePicker
extends HBoxContainer

# MVP'den önce Ürün penceresinde ürünün türü ve adı seçilir. Solda pazara göre gruplu tür listesi, sağda seçilenin
# dosyası: türün tanımı, nasıl kazandığı, kime sattığı, yolun açacağı masalar ve türün artısı ile eksisi (adı olan
# kavramlar, tanımları ipucunda). Seçim taslak olarak SprintSystem'e yazılır (sayfa yeniden kurulunca kalır) ve her tıkta
# ekran baştan kurulur; onay `chosen` olarak sekmeye çıkar, sekme SprintSystem.choose_type'a iletir.

signal chosen(subtype: String, name: String)

## Per market: the group's heading key and its glyph.
const MARKETS := {"b2c": ["PROD_PATH_B2C", "res://assets/icons/type/b2c.svg"], "b2b": ["PROD_PATH_B2B", SprintUiShared.BUILDING]}
const TYPE_GLYPH := "res://assets/icons/type/%s.svg"
const CONCEPTS := {"plus": SprintUiShared.PLUS, "minus": "res://assets/icons/util/minus.svg"}

var _subtype := ""
var _name := ""


func setup() -> void:
	var draft: Dictionary = GameState.product.get("type_draft", {})
	_subtype = draft.get("subtype", "")
	_name = draft.get("name", "")
	UiFactory.clear(self)
	add_theme_constant_override("separation", UiTokens.SPACE_4XL)
	add_child(_list())
	add_child(_dossier())


func _pick_type(subtype: String) -> void:
	_subtype = subtype
	_save_draft()
	setup.call_deferred()


func _save_draft() -> void:
	SprintSystem.set_type_draft({"subtype": _subtype, "name": _name})


func _text(id: String, suffix: String) -> String:
	return tr("PROD_TYPE_%s%s" % [id.to_upper(), suffix])


func _group_label(market: String) -> Label:
	return SprintUiShared.label(Fmt.upper(tr(MARKETS[market][0])), &"Eyebrow")


func _list() -> VBoxContainer:
	var col := SprintUiShared.column(UiTokens.SPACE_XL)
	col.custom_minimum_size.x = UiTokens.D_W_TYPE_LIST
	col.add_child(UiFactory.make_label(tr("PROD_PATH_TITLE"), &"TitleH2"))
	for market: String in MARKETS:
		var head := SprintUiShared.box(UiTokens.SPACE_M)
		head.add_child(UiFactory.make_glyph(MARKETS[market][1], UiTokens.D_ICON_GROUP, UiTokens.D_INK_4))
		head.add_child(_group_label(market))
		col.add_child(SprintUiShared.pad(head, Vector4i(0, UiTokens.SPACE_L, 0, 0)))
		for st in ProductCatalog.playable_types(market):
			col.add_child(_row(String(st.id)))
	return col


## A type's row: its glyph, its name and its one line. The picked one carries the edge mark.
func _row(id: String) -> PanelContainer:
	var selected := id == _subtype
	var row := SprintUiShared.box(UiTokens.SPACE_XL)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(UiFactory.make_glyph(TYPE_GLYPH % id, UiTokens.D_ICON_TYPE, UiTokens.D_INK_1 if selected else UiTokens.D_INK_3))
	var words := SprintUiShared.column(UiTokens.SPACE_XS)
	words.mouse_filter = Control.MOUSE_FILTER_IGNORE
	words.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	words.add_child(UiFactory.make_label(ProductCatalog.type_name(id), &"OptionLabel"))
	words.add_child(SprintUiShared.prose(_text(id, "_SHORT"), &"BodyMuted"))
	row.add_child(words)
	var card := PanelContainer.new()
	card.theme_type_variation = &"PickCardSelected" if selected else &"PickCard"
	card.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	card.gui_input.connect(func(ev: InputEvent) -> void:
		if UiFactory.is_left_click(ev):
			_pick_type(id))
	if not selected:
		card.mouse_entered.connect(func() -> void: card.theme_type_variation = &"PickCardHover")
		card.mouse_exited.connect(func() -> void: card.theme_type_variation = &"PickCard")
	var layer := Control.new()
	layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if selected:
		layer.add_child(HRUiShared.D_mark())
	card.add_child(layer)
	var inner := SprintUiShared.pad(row, Vector4i(UiTokens.SPACE_XXL, UiTokens.SPACE_L, UiTokens.SPACE_XL, UiTokens.SPACE_L))
	inner.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(inner)
	return card


func _dossier() -> PanelContainer:
	var panel := PanelContainer.new()
	panel.theme_type_variation = &"SprintColumn"
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var col := SprintUiShared.column(UiTokens.SPACE_3XL)
	panel.add_child(SprintUiShared.pad(col, Vector4i.ONE * UiTokens.SPACE_3XL))
	if _subtype == "":
		var hint := UiFactory.make_label(tr("PROD_PATH_EMPTY"), &"NoteMuted")
		hint.size_flags_vertical = Control.SIZE_EXPAND_FILL
		hint.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		col.add_child(hint)
		return panel
	var record: Dictionary = ProductCatalog.get_sub_product_type_by_id(_subtype)
	var market: String = record.market_type
	var top := SprintUiShared.box(UiTokens.SPACE_3XL)
	top.add_child(UiFactory.make_glyph(TYPE_GLYPH % _subtype, UiTokens.D_ICON_TYPE_HERO, UiTokens.D_INK_1))
	var words := SprintUiShared.column(UiTokens.SPACE_S)
	words.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	words.add_child(_group_label(market))
	words.add_child(UiFactory.make_label(ProductCatalog.type_name(_subtype), &"DisplayName"))
	words.add_child(SprintUiShared.prose(_text(_subtype, "_DEF"), &"LeadText"))
	top.add_child(words)
	col.add_child(top)
	col.add_child(HSeparator.new())
	col.add_child(_fact("res://assets/icons/stake/cash_in.svg", "PROD_FACT_EARN", _text(_subtype, "_EARN")))
	col.add_child(_fact(MARKETS[market][1], "PROD_FACT_WHO", _text(_subtype, "_WHO")))
	var desks: Array = record.get("desks", [])
	if not desks.is_empty():
		col.add_child(SprintUiShared.label(Fmt.upper(tr("PROD_DESKS_LABEL")), &"KeySmall"))
		col.add_child(_desks(desks))
	for side: String in CONCEPTS:
		var concept := String(record.get(side, ""))
		if concept != "":
			var key := "PROD_CONCEPT_" + concept.to_upper()
			col.add_child(_fact(CONCEPTS[side], key + "_TIP", tr(key)))
	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	col.add_child(spacer)
	col.add_child(_confirm_row())
	return panel


## A fact is its glyph and its value; what it is (Gelir, the concept's definition) is the tooltip.
func _fact(glyph: String, tip_key: String, value: String) -> HBoxContainer:
	var row := SprintUiShared.box(UiTokens.SPACE_L)
	row.tooltip_text = tr(tip_key)
	row.add_child(UiFactory.make_glyph(glyph, UiTokens.D_ICON_ROW, UiTokens.D_INK_3))
	row.add_child(SprintUiShared.prose(value, &"ValueTextStrong"))
	return row


## The desks this path opens, each a framed box at value size; the tooltip says what the desk makes the player do.
func _desks(ids: Array) -> HFlowContainer:
	var flow := HFlowContainer.new()
	flow.add_theme_constant_override("h_separation", UiTokens.SPACE_M)
	flow.add_theme_constant_override("v_separation", UiTokens.SPACE_M)
	for id: String in ids:
		var key := "PROD_DESK_" + id.to_upper()
		var desk := PanelContainer.new()
		desk.theme_type_variation = &"DeskBox"
		desk.tooltip_text = tr(key + "_TIP")
		desk.add_child(SprintUiShared.label(tr(key), &"ValueTextStrong"))
		flow.add_child(desk)
	return flow


## The choice is final, said once beside the name box and the confirmation; an empty name keeps it shut.
func _confirm_row() -> HBoxContainer:
	var row := SprintUiShared.box(UiTokens.SPACE_L)
	row.add_child(UiFactory.make_glyph(SprintUiShared.LOCK, UiTokens.D_ICON_ROW, UiTokens.D_INK_4))
	row.add_child(SprintUiShared.label(tr("PROD_PATH_FINAL"), &"NoteMuted"))
	var edit := LineEdit.new()
	edit.text = _name
	edit.placeholder_text = tr("PROD_NAME_LABEL")
	edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(edit)
	var confirm := Button.new()
	confirm.theme_type_variation = &"PrimaryButtonDark"
	confirm.text = tr("PROD_CONFIRM_START")
	confirm.disabled = _name.strip_edges() == ""
	confirm.pressed.connect(func() -> void: chosen.emit(_subtype, _name.strip_edges()))
	row.add_child(confirm)
	edit.text_changed.connect(func(text: String) -> void:
		_name = text
		_save_draft()
		confirm.disabled = text.strip_edges() == "")
	return row
