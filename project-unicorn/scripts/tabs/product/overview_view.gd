extends HBoxContainer

# GENEL BAKIŞ kâğıdı: ürünün tek bakışlık okuması. İskelet iki sütundur (soldaki esner, sağdaki yaklaşık yüzde kırk);
# bloklar `UiFactory.D_card` kartlarıdır. Bu sürümde yalnız sağ sütunun Sunucu bloğu çizilir. Yalnız modeli çizer
# (`model.overview`); eylemler sekmeye çıkar.

signal action(kind: String, args: Dictionary)   # server_preview {id} · server_tier {id} · server_step {direction} · server_auto {on}

const GLYPH := "res://assets/icons/util/%s.svg"


func setup(model: Dictionary) -> void:
	UiFactory.clear(self)
	add_theme_constant_override("separation", UiTokens.SPACE_XL)
	var left := SprintUiShared.column(UiTokens.SPACE_XL)
	left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left.size_flags_stretch_ratio = 3.0
	add_child(left)
	var right := SprintUiShared.column(UiTokens.SPACE_XL)
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right.size_flags_stretch_ratio = 2.0
	add_child(right)
	_server_card(right, model.overview.server, String(model.ui.get("server_preview", "")))


## SUNUCU: kademe seçici (seçilince geçiş önizlemesi açılır), kapasite ve fatura, yük çubuğu ve satırı, tek satırlık not,
## adım düğmeleri ve Otomatik ayarla anahtarı.
func _server_card(parent: Control, server: Dictionary, preview: String) -> void:
	var card := UiFactory.D_card(parent)
	card.add_child(UiFactory.D_card_head(tr("PRODUCT_SERVER_HEAD")))
	card.add_child(_tiers(server, preview))
	card.add_child(SprintUiShared.label(server.capacity, &"DataStrong"))
	card.add_child(UiFactory.D_load_bar(server.percent))
	if server.load != "":
		card.add_child(SprintUiShared.label(server.load, &"KeyText"))
	if server.note != null:
		card.add_child(_note(server.note))
	card.add_child(_controls(server))
	if server.clause != "":
		card.add_child(UiFactory.D_glyph_tag(GLYPH % "shield", server.clause, &"warn"))


func _tiers(server: Dictionary, preview: String) -> VBoxContainer:
	var box := SprintUiShared.column(UiTokens.SPACE_M)
	var pick := UiFactory.D_seg_pick(server.tiers.map(func(tier: Dictionary) -> Dictionary:
		return {"text": tier.name, "tip": tier.tip, "off": tier.off}), server.active,
		func(i: int) -> void: action.emit("server_preview", {"id": server.tiers[i].id}))
	pick.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	box.add_child(pick)
	for tier: Dictionary in server.tiers:
		if tier.id == preview:
			box.add_child(_preview(tier))
	return box


## Geçiş önizlemesi: kademeden kademeye ve fatura; Kurumsal'a geçerken geri dönüşsüzlük notu da. Geç basılınca
## kademe değişir, Vazgeç önizlemeyi kapatır.
func _preview(tier: Dictionary) -> VBoxContainer:
	var box := SprintUiShared.column(UiTokens.SPACE_M)
	box.add_child(SprintUiShared.prose(tier.preview, &"KeyText"))
	if tier.final != "":
		box.add_child(SprintUiShared.prose(tier.final, &"Caption"))
		box.get_child(-1).add_theme_color_override("font_color", UiTokens.D_warn())
	var buttons := SprintUiShared.box(UiTokens.SPACE_M)
	buttons.add_child(SprintUiShared.button(tr("PRODUCT_SERVER_TIER_SWITCH"), &"PrimaryButtonDarkSmall",
		action.emit.bind("server_tier", {"id": tier.id})))
	buttons.add_child(SprintUiShared.button(tr("UI_DISMISS"), &"GhostButtonSmall", action.emit.bind("server_preview", {"id": ""})))
	box.add_child(buttons)
	return box


## Glif ve cümle, cümlenin rengi tonundan: kapasite yetmiyor tehlike, kesinti ihtimali artıyor uyarı, gerisi sessiz.
func _note(note: Dictionary) -> HBoxContainer:
	var ink: Color = {"over": UiTokens.D_neg(), "warn": UiTokens.D_warn(), "quiet": UiTokens.D_INK_3}[note.tone]
	var row := SprintUiShared.box(UiTokens.SPACE_S)
	var icon := UiFactory.make_glyph(GLYPH % note.glyph, UiTokens.D_ICON_PART, ink)
	icon.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	row.add_child(icon)
	var words := SprintUiShared.prose(note.text, &"Caption")
	words.add_theme_color_override("font_color", ink)
	row.add_child(words)
	return row


func _controls(server: Dictionary) -> HBoxContainer:
	var row := SprintUiShared.box(UiTokens.SPACE_M)
	for step: Array in [["decrease", -1], ["increase", 1]]:
		var button := SprintUiShared.button(server[step[0]].text, &"SecondaryButtonSmall",
			action.emit.bind("server_step", {"direction": step[1]}))
		button.tooltip_text = server[step[0]].tip
		button.disabled = server[step[0]].get("off", false)
		row.add_child(button)
	row.add_child(RnDUiShared.spacer())
	SprintUiShared.switch(row, tr("PRODUCT_SERVER_AUTO_TOGGLE"), server.auto.on,
		func(on: bool) -> void: action.emit("server_auto", {"on": on}), server.auto.tip)
	return row
