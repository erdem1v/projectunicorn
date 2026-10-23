class_name TypePicker
extends VBoxContainer

# MVP'den önce Ürün sekmesinde ürünün türü, pazarı ve adı tek ekranda seçilir: yan yana iki pazar sütunu, her
# sütunun başında pazarın düz başlığı, altında o pazarın oynanabilir türleri. Kartı seçmek türü ve pazarı
# birlikte yazar. Seçim taslak olarak SprintSystem'e yazılır (sayfa yeniden kurulunca kalır) ve her tıkta kutu
# baştan kurulur; onay `chosen` olarak sekmeye çıkar, sekme SprintSystem.choose_type'a iletir. Seçili kart
# yükselir ve sol kenarında işaret, sağ üstünde tik taşır.

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
	if _subtype != "":
		_market = ProductCatalog.get_market_type(_subtype)
	UiFactory.clear(self)
	add_theme_constant_override("separation", UiTokens.SPACE_XL)
	var intro := SprintUiShared.column(UiTokens.SPACE_M)
	intro.add_child(UiFactory.make_label(tr("PROD_PATH_TITLE"), &"TitleH2"))
	intro.add_child(SprintUiShared.prose(tr("PROD_PATH_SUB"), &"NoteMuted"))
	add_child(intro)
	var paths := SprintUiShared.box(UiTokens.SPACE_L)
	for market: String in PATH_KEYS:
		var col := SprintUiShared.column(UiTokens.SPACE_L)
		col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var head := SprintUiShared.column(UiTokens.SPACE_S)
		head.add_child(SprintUiShared.label(Fmt.upper(tr(PATH_KEYS[market][0])), &"KeyLabel"))
		head.add_child(UiFactory.make_label(market.to_upper(), &"OptionLabel"))
		head.add_child(SprintUiShared.prose(tr(PATH_KEYS[market][1]), &"MetaMuted"))
		col.add_child(SprintUiShared.pad(head, Vector4i(UiTokens.SPACE_XXL, 0, UiTokens.SPACE_XL, 0)))
		for st in ProductCatalog.playable_types(market):
			var id: String = st.id
			# Ad sarar: sarmayan uzun ad sütunun asgari enini büyütür ve iki sütun eşit kalmaz.
			var box := _choice(col, id == _subtype, _pick_type.bind(id),
				[SprintUiShared.prose(ProductCatalog.type_name(id), &"DataStrong"),
				SprintUiShared.label(Fmt.upper(ProductCatalog.type_category(id)), &"KeySmall")])
			box.add_child(SprintUiShared.prose(ProductCatalog.type_desc(id), &"MetaText"))
			box.add_child(SprintUiShared.prose(ProductCatalog.type_tradeoff(id), &"MetaMuted"))
		paths.add_child(col)
	add_child(paths)
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


func _pick_type(subtype: String) -> void:
	_market = ProductCatalog.get_market_type(subtype)
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
		top.add_child(UiFactory.make_glyph(SprintUiShared.CHECK, UiTokens.D_ICON_ROW, UiTokens.D_INK_1))
	box.add_child(top)
	var inner := SprintUiShared.pad(box, Vector4i(UiTokens.SPACE_XXL, UiTokens.SPACE_XL, UiTokens.SPACE_XL, UiTokens.SPACE_XL))
	inner.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(inner)
	host.add_child(card)
	return box
