class_name TypePicker
extends VBoxContainer

# MVP'den önce Ürün sekmesinde ürünün pazarı, türü ve adı seçilir. Seçim yereldir ve her tıkta
# kutu baştan kurulur; onay `chosen` olarak sekmeye çıkar, sekme SprintSystem.choose_type'a iletir.

signal chosen(subtype: String, name: String)

const PATH_KEYS := {"b2c": ["PROD_PATH_B2C", "PROD_PATH_B2C_DESC"], "b2b": ["PROD_PATH_B2B", "PROD_PATH_B2B_DESC"]}

var _market := ""
var _subtype := ""
var _name := ""
var _suggest_i := 0


func setup() -> void:
	UiFactory.clear(self)
	add_theme_constant_override(&"separation", UiTokens.SPACE_L)
	add_child(UiFactory.make_label(tr("PROD_PATH_TITLE"), &"AreaName"))
	add_child(_wrap(tr("PROD_PATH_SUB"), &"AreaSentence"))
	var paths := HBoxContainer.new()
	paths.add_theme_constant_override(&"separation", UiTokens.PRODUCT_CARD_GAP)
	for market: String in PATH_KEYS:
		var card := _choice(market == _market, _pick_market.bind(market))
		card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var box: VBoxContainer = card.get_child(0)
		box.add_child(UiFactory.make_label(tr(PATH_KEYS[market][0]), &"SectionAmber"))
		box.add_child(UiFactory.make_label(market.to_upper(), &"AreaName"))
		box.add_child(_wrap(tr(PATH_KEYS[market][1]), &"AreaSentence"))
		paths.add_child(card)
	add_child(paths)
	if _market == "":
		return

	_section(tr("PROD_TYPE_STEP_TITLE").format({"market": _market.to_upper()}))
	for st in ProductCatalog.playable_types(_market):
		var id: String = st.id
		var card := _choice(id == _subtype, _pick_type.bind(id))
		var box: VBoxContainer = card.get_child(0)
		var head := HBoxContainer.new()
		head.add_theme_constant_override(&"separation", UiTokens.SPACE_S)
		var title := UiFactory.make_label(ProductCatalog.type_name(id), &"AreaName")
		title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		head.add_child(title)
		head.add_child(SprintUiShared.stamp(ProductCatalog.type_category(id), &"MicroLabel"))
		box.add_child(head)
		box.add_child(_wrap(ProductCatalog.type_desc(id), &"AreaSentence"))
		box.add_child(_wrap(ProductCatalog.type_tradeoff(id), &"LeadQuote"))
		add_child(card)
	if _subtype == "":
		return

	_section(tr("PROD_NAME_LABEL"))
	var row := HBoxContainer.new()
	row.add_theme_constant_override(&"separation", UiTokens.SPACE_S)
	var edit := LineEdit.new()
	edit.text = _name
	edit.placeholder_text = tr("PROD_NAME_LABEL")
	edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(edit)
	var suggest := Button.new()
	suggest.theme_type_variation = &"InkButton"
	suggest.text = tr("PROD_NAME_SUGGEST")
	suggest.focus_mode = Control.FOCUS_NONE   # boşluk tuşu hız tuşudur; odak onu yutmasın
	suggest.pressed.connect(func() -> void:
		_suggest_i += 1
		_name = ProductCatalog.suggest_product_name(_suggest_i)
		edit.text = _name)
	row.add_child(suggest)
	add_child(row)
	var confirm := Button.new()
	confirm.theme_type_variation = &"PrimaryButton"
	confirm.text = tr("PROD_CONFIRM_START")
	confirm.size_flags_horizontal = Control.SIZE_SHRINK_END
	confirm.disabled = _name.strip_edges() == ""
	confirm.pressed.connect(func() -> void: chosen.emit(_subtype, _name.strip_edges()))
	add_child(confirm)
	# Elle yazılan ad seçimle birlikte saklanır; boş ad onayı kapatır.
	edit.text_changed.connect(func(text: String) -> void:
		_name = text
		confirm.disabled = text.strip_edges() == "")


func _pick_market(market: String) -> void:
	if market != _market:
		_market = market
		_subtype = ""
	setup.call_deferred()


func _pick_type(subtype: String) -> void:
	_subtype = subtype
	if _name == "":
		_name = ProductCatalog.suggest_product_name(_suggest_i)
	setup.call_deferred()


## Seçilebilir kâğıt kart: seçili olan açık kenarlı; tık `on_pick` çağırır. Çocuk 0 içerik kutusudur.
func _choice(selected: bool, on_pick: Callable) -> PanelContainer:
	var card := PanelContainer.new()
	card.theme_type_variation = &"PaperCardOpen" if selected else &"PaperCard"
	card.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	card.gui_input.connect(func(ev: InputEvent) -> void:
		if UiFactory.is_left_click(ev):
			on_pick.call())
	var box := VBoxContainer.new()
	box.add_theme_constant_override(&"separation", UiTokens.SPACE_XS)
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(box)
	return card


func _section(text: String) -> void:
	add_child(HRUiShared.hairline())
	add_child(UiFactory.make_label(text, &"SectionAmber"))


func _wrap(text: String, variation: StringName) -> Label:
	var l := UiFactory.make_label(text, variation)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return l
