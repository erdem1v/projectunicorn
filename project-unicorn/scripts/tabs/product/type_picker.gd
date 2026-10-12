class_name TypePicker
extends VBoxContainer

# MVP'den önce Ürün sekmesinde ürünün pazarı, türü ve adı seçilir. Seçim taslak olarak SprintSystem'e
# yazılır (sayfa yeniden kurulunca kalır) ve her tıkta kutu baştan kurulur; onay `chosen` olarak sekmeye
# çıkar, sekme SprintSystem.choose_type'a iletir. Seçili kart yükselir ve sol kenarında işaret, sağ üstünde
# tik taşır.

signal chosen(subtype: String, name: String)

const PATH_KEYS := {"b2c": ["PROD_PATH_B2C", "PROD_PATH_B2C_DESC"], "b2b": ["PROD_PATH_B2B", "PROD_PATH_B2B_DESC"]}

var _market := ""
var _subtype := ""
var _name := ""


func setup() -> void:
	var draft: Dictionary = GameState.product.get("type_draft", {})
	_market = draft.get("market", "")
	_subtype = draft.get("subtype", "")
	_name = draft.get("name", "")
	UiFactory.clear(self)
	add_theme_constant_override("separation", UiTokens.SPACE_XL)
	var intro := SprintUiShared.column(UiTokens.SPACE_M)
	intro.add_child(UiFactory.make_label(tr("PROD_PATH_TITLE"), &"TitleH2"))
	intro.add_child(SprintUiShared.prose(tr("PROD_PATH_SUB"), &"NoteMuted"))
	add_child(intro)
	var paths := SprintUiShared.box(UiTokens.SPACE_L)
	for market: String in PATH_KEYS:
		var box := _choice(paths, market == _market, _pick_market.bind(market),
			[SprintUiShared.label(Fmt.upper(tr(PATH_KEYS[market][0])), &"KeyLabel")])
		box.add_child(UiFactory.make_label(market.to_upper(), &"OptionLabel"))
		box.add_child(SprintUiShared.prose(tr(PATH_KEYS[market][1]), &"MetaMuted"))
	add_child(paths)
	if _market == "":
		return

	var step := SprintUiShared.box(UiTokens.SPACE_L)
	step.add_child(SprintUiShared.label(tr("PROD_TYPE_STEP_TITLE").format({"market": _market.to_upper()}), &"OptionLabel"))
	var rule := HSeparator.new()
	rule.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rule.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	step.add_child(rule)
	add_child(step)
	for st in ProductCatalog.playable_types(_market):
		var id: String = st.id
		var box := _choice(self, id == _subtype, _pick_type.bind(id),
			[SprintUiShared.label(ProductCatalog.type_name(id), &"DataStrong"), RnDUiShared.spacer(),
			SprintUiShared.label(Fmt.upper(ProductCatalog.type_category(id)), &"KeySmall")])
		box.add_child(SprintUiShared.prose(ProductCatalog.type_desc(id), &"MetaText"))
		box.add_child(SprintUiShared.prose(ProductCatalog.type_tradeoff(id), &"MetaMuted"))
	if _subtype == "":
		return

	add_child(SprintUiShared.section("PROD_NAME_LABEL"))
	var edit := LineEdit.new()
	edit.text = _name
	edit.placeholder_text = tr("PROD_NAME_LABEL")
	edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_child(edit)
	var confirm := Button.new()
	confirm.theme_type_variation = &"PrimaryButtonDark"
	confirm.text = tr("PROD_CONFIRM_START")
	confirm.size_flags_horizontal = Control.SIZE_SHRINK_END
	confirm.disabled = _name.strip_edges() == ""
	confirm.pressed.connect(func() -> void: chosen.emit(_subtype, _name.strip_edges()))
	add_child(confirm)
	# Elle yazılan ad seçimle birlikte saklanır; boş ad onayı kapatır.
	edit.text_changed.connect(func(text: String) -> void:
		_name = text
		_save_draft()
		confirm.disabled = text.strip_edges() == "")


func _pick_market(market: String) -> void:
	if market != _market:
		_market = market
		_subtype = ""
	_save_draft()
	setup.call_deferred()


func _pick_type(subtype: String) -> void:
	_subtype = subtype
	_save_draft()
	setup.call_deferred()


func _save_draft() -> void:
	SprintSystem.set_type_draft({"market": _market, "subtype": _subtype, "name": _name})


## Seçilebilir kart `host`'a eklenir: seçili olan yükselir, sol kenarında işaret ve sağ üstünde tik taşır;
## tık `on_pick` çağırır. Başlık satırı `head` parçalarıdır; dönen kutuya içeriği çağıran ekler.
func _choice(host: Control, selected: bool, on_pick: Callable, head: Array) -> VBoxContainer:
	var card := PanelContainer.new()
	card.theme_type_variation = &"PickCardSelected" if selected else &"PickCard"
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	card.gui_input.connect(func(ev: InputEvent) -> void:
		if UiFactory.is_left_click(ev):
			on_pick.call())
	if not selected:
		card.mouse_entered.connect(func() -> void: card.theme_type_variation = &"PickCardHover")
		card.mouse_exited.connect(func() -> void: card.theme_type_variation = &"PickCard")
	var layer := Control.new()
	layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if selected:
		layer.add_child(HRUiShared.D_mark())
	card.add_child(layer)
	var box := SprintUiShared.column(UiTokens.SPACE_S)
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var top := SprintUiShared.box(UiTokens.SPACE_M)
	top.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for part: Control in head:
		top.add_child(part)
	if selected:
		if top.get_child_count() == 1:
			top.add_child(RnDUiShared.spacer())
		top.add_child(UiFactory.make_glyph(SprintUiShared.CHECK, UiTokens.D_ICON_ROW, UiTokens.D_INK_1))
	box.add_child(top)
	var inner := SprintUiShared.pad(box, Vector4i(UiTokens.SPACE_XXL, UiTokens.SPACE_XL, UiTokens.SPACE_XL, UiTokens.SPACE_XL))
	inner.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(inner)
	host.add_child(card)
	return box
