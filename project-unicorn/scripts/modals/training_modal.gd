extends "res://scripts/tabs/hr/hr_panel.gd"

# EĞİTİME GÖNDER — tek kişi. Başta kişi ve alanlarının değeri, altında ALAN · MEVCUT · HEDEF · ÜCRET ·
# SÜRE tablosu, tek kural satırı ve alt bar: seçili alanın özeti ya da kilidin gerekçesi, tek amber
# eylem.
#
# SATIRLAR: çalışanda ANA + İKİNCİL alan + LİDERLİK (§4.4 altı alanı düz listede göstermeyi
# yasaklıyor). Kurucunun ana/ikincil ayrımı yok, onda ALTI ALAN + Liderlik listelenir.
#
# SÜRE METNİ TRAINING_WEEKS sabitinden türetilir (§5.5), sabit bir anahtara gömülmez:
# HRConstants.training_duration_text().
#
# BEDEL KADEMELİDİR VE HER SATIRDA OKUNUR (§5.5), kilitli satırda da: fark ancak her satır
# rakam taşırsa okunur; kilidin gerekçesi bir kez, düğmenin yanında.
#
# PanelLayer'da yaşar, ModalLayer'da değil: ModalLayer boşluk ve 1-4 hız tuşlarını yutuyor,
# yani saat bir personel kararının üstünde koşardı.

const WIDTH := 760
## ALAN, MEVCUT, HEDEF, ÜCRET, SÜRE.
const W := [220, 100, 120, 160, 112]

var _character_id: String = ""
var _selected: String = ""


## Ev sahibi ÖNCE add_child eder, SONRA burayı çağırır. İlk açık alan seçili gelir; kişinin Kadro
## satırı panel açıkken seçili kalır.
func populate(character_id: String) -> void:
	_character_id = character_id
	get_tree().call_group(HRLedger.VIEWS_GROUP, &"hold_person", character_id, true)
	title.add_child(UiFactory.make_label(tr("HR_TRAINING_PICK_TITLE"), &"TitleH2"))
	for key: String in _rows_for(CharacterRegistry.get_character(character_id)):
		if CharacterRegistry.can_train(character_id, key):
			_selected = key
			break
	_rebuild()


func _exit_tree() -> void:
	super()
	get_tree().call_group(HRLedger.VIEWS_GROUP, &"hold_person", _character_id, false)


func _rebuild() -> void:
	clear()
	var c: Character = CharacterRegistry.get_character(_character_id)
	if c == null:
		close()
		return

	var who := HRUiShared.D_who(c, UiTokens.D_AVATAR_DOC)
	if c.category != "founder":
		who.add_child(spring())
		for key: String in HRUiShared.role_areas(c.role):
			who.add_child(UiFactory.make_label(HRConstants.area_label(key), &"CondCaption"))
			who.add_child(HRUiShared.D_skill_figure(int(c.role_stats.get(key, 0)), HRUiShared.D_rank(c.role, key)))
	for part: Control in who.get_children():
		part.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	body.add_child(who)

	var head := PanelContainer.new()
	head.theme_type_variation = &"TableHead"
	head.custom_minimum_size.y = UiTokens.D_H_HEAD
	var cols := HBoxContainer.new()
	cols.add_theme_constant_override("separation", 0)
	head.add_child(cols)
	for i in W.size():
		var key: String = ["HR_TRAINING_COL_AREA", "HR_TRAINING_COL_CURRENT", "HR_TRAINING_COL_TARGET",
			"HR_TRAINING_COL_FEE", "HR_TRAINING_COL_DURATION"][i]
		cols.add_child(_cell(HRUiShared.D_head(tr(key), 0, [HORIZONTAL_ALIGNMENT_LEFT, HORIZONTAL_ALIGNMENT_CENTER,
			HORIZONTAL_ALIGNMENT_CENTER, HORIZONTAL_ALIGNMENT_RIGHT, HORIZONTAL_ALIGNMENT_RIGHT][i]), i))
	body.add_child(spaced(head, UiTokens.SPACE_XL))

	var blocked: String = ""
	for skill_key: String in _rows_for(c):
		body.add_child(_skill_row(c, skill_key))
		if blocked == "" and not CharacterRegistry.can_train(_character_id, skill_key):
			blocked = CharacterRegistry.training_block_reason(_character_id, skill_key)

	# Tek kural satırı.
	var fact := PanelContainer.new()
	fact.theme_type_variation = &"FactBox"
	var fact_row := HBoxContainer.new()
	fact_row.add_theme_constant_override("separation", UiTokens.SPACE_M)
	fact_row.add_child(UiFactory.make_glyph("res://assets/icons/util/lock.svg", UiTokens.D_ICON_PART, UiTokens.D_INK_4))
	fact_row.add_child(UiFactory.make_label(tr("HR_TRAINING_WARNING"), &"KeyText"))
	fact.add_child(fact_row)
	body.add_child(spaced(fact, UiTokens.SPACE_XL))

	foot.add_child(button(tr("UI_DISMISS"), &"", close))
	foot.add_child(spring())
	if _selected == "":
		# Açık alan yok: düğme kapalı, gerekçesi bir kez yanında.
		foot.add_child(UiFactory.make_label(blocked, &"MetaMuted"))
		foot.add_child(button(tr("HR_TRAINING_PICK_TITLE"), &"PrimaryButtonDark", Callable()))
	else:
		foot.add_child(UiFactory.make_label("%s · %s" % [HRConstants.area_label(_selected),
			HRConstants.training_duration_text()], &"MetaMuted"))
		# §5.4: para bir kilit değil, bedeldir. Kasa yetmese de buton basılır ve bedel kasayı
		# eksiye götürebilir; bedel butonun üstünde ve satırında okunuyor.
		foot.add_child(button(tr("HR_TRAINING_CTA").format({"fee": Fmt.money_exact(
			CharacterRegistry.training_fee_for(_character_id, _selected))}), &"PrimaryButtonDark", _on_send))
	seat(WIDTH)


func _rows_for(c: Character) -> Array:
	if c.category == "founder":
		return HRConstants.trainable_keys()
	return HRUiShared.role_areas(c.role) + [HRConstants.SKILL_LEADERSHIP]


## A training row: the area, its value now and after the training (plain figures: the head already marks
## the main area), the fee as a cost and the length. A locked row keeps its figures; only its label and
## glyph grey.
func _skill_row(c: Character, skill_key: String) -> PanelContainer:
	var current: int = int(c.role_stats.get(skill_key, 0))
	var trainable: bool = CharacterRegistry.can_train(_character_id, skill_key)
	var row := HRUiShared.D_row(_selected == skill_key)
	row.custom_minimum_size.y = UiTokens.D_H_ROW_LG
	var cells := HBoxContainer.new()
	cells.add_theme_constant_override("separation", 0)
	row.add_child(cells)
	var area := HBoxContainer.new()
	area.add_theme_constant_override("separation", UiTokens.SPACE_M)
	if not trainable:
		area.add_child(UiFactory.make_glyph("res://assets/icons/util/lock.svg", UiTokens.D_ICON_PART, UiTokens.D_INK_OFF))
	area.add_child(UiFactory.make_label(HRConstants.area_label(skill_key), &"DataText",
		null if trainable else UiTokens.D_INK_OFF))
	cells.add_child(_cell(area, 0))
	cells.add_child(_cell(HRUiShared.D_skill_figure(current, &""), 1))
	# HEDEF: bir eğitim +1 puan; tavan 10 (§5.3).
	var target := HBoxContainer.new()
	target.alignment = BoxContainer.ALIGNMENT_CENTER
	target.add_theme_constant_override("separation", UiTokens.SPACE_M)
	target.add_child(UiFactory.make_label("→", &"CaptionFaint"))
	target.add_child(HRUiShared.D_skill_figure(mini(current + 1, HRConstants.AREA_MAX), &""))
	cells.add_child(_cell(target, 2))
	var fee := UiFactory.D_cost(Fmt.money_exact(CharacterRegistry.training_fee_for(_character_id, skill_key)))
	fee.alignment = BoxContainer.ALIGNMENT_END
	cells.add_child(_cell(fee, 3))
	var weeks := UiFactory.make_label(HRConstants.training_duration_text(), &"MetaMuted")
	weeks.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	cells.add_child(_cell(weeks, 4))
	for part: Control in cells.find_children("*", "Control", true, false):
		part.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	HRUiShared.set_mouse_ignore(cells)
	if trainable:
		row.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		row.gui_input.connect(func(ev: InputEvent) -> void:
			if UiFactory.is_left_click(ev):
				_selected = skill_key
				_rebuild())
	else:
		row.tooltip_text = CharacterRegistry.training_block_reason(_character_id, skill_key)
	return row


## Column `i`'s cell, its content inset from the row's ends: the area from the left, the length from the
## right, the fee before the length.
func _cell(child: Control, i: int) -> MarginContainer:
	var cell := MarginContainer.new()
	cell.custom_minimum_size.x = W[i]
	cell.add_theme_constant_override("margin_left", UiTokens.SPACE_L if i == 0 else 0)
	cell.add_theme_constant_override("margin_right", [0, 0, 0, UiTokens.SPACE_XXL, UiTokens.SPACE_L][i])
	if child is Label:
		child.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cell.add_child(child)
	return cell


func _on_send() -> void:
	if HRSystem.send_to_training(_character_id, _selected):
		state_changed.emit()
	close()
