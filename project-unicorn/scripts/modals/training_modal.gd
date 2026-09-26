extends Control

# EĞİTİME GÖNDER — tek kişi. Üstte kişi satırı, altında ALAN · MEVCUT · HEDEF · ÜCRET · SÜRE
# tablosu, tek uyarı satırı ve alt bar.
#
# SATIRLAR: çalışanda ANA + İKİNCİL alan + LİDERLİK (§4.4 altı alanı düz listede göstermeyi
# yasaklıyor). Kurucunun ana/ikincil ayrımı yok, onda ALTI ALAN + Liderlik listelenir.
#
# SÜRE METNİ gün sayısından türetilir (§5.5), sabit bir anahtara gömülmez:
# HRConstants.training_duration_text().
#
# BEDEL KADEMELİDİR VE HER SATIRDA OKUNUR (§5.5), kilitli satırda da: fark ancak her satır
# rakam taşırsa okunur; kilit gerekçesi kendi sütununda durur.
#
# PanelLayer'da yaşar, ModalLayer'da değil: ModalLayer boşluk ve 1-4 hız tuşlarını yutuyor,
# yani saat bir personel kararının üstünde koşardı.

signal state_changed

@onready var _root_box: VBoxContainer = %RootBox

var _character_id: String = ""
var _selected: String = ""


func _ready() -> void:
	(%Dimmer as ColorRect).color = UiTokens.SCRIM_MODAL


## Ev sahibi ÖNCE add_child eder, SONRA burayı çağırır.
func populate(character_id: String) -> void:
	_character_id = character_id
	_selected = ""
	_rebuild()


func _rebuild() -> void:
	for n in _root_box.get_children():
		_root_box.remove_child(n)
		n.queue_free()
	var c: Character = CharacterRegistry.get_character(_character_id)
	if c == null:
		_close()
		return

	# --- başlık: EĞİTİM · ALAN SEÇ ---
	var head := HBoxContainer.new()
	head.add_theme_constant_override("separation", 12)
	head.add_child(UiFactory.make_label(UiTokens.tr_upper(tr("HR_TRAINING")), &"SectionAmber"))
	head.add_child(UiFactory.make_label(tr("HR_TRAINING_STEP_AREA"), &"ColumnHeader", UiTokens.INK_DIM))
	head.add_child(_spacer())
	head.add_child(UiFactory.make_label(tr("HR_TRAINING_PICK_TITLE"), &"NameSerif"))
	_root_box.add_child(head)
	_root_box.add_child(HRUiShared.hairline())

	# --- kişi satırı ---
	var who := HBoxContainer.new()
	who.add_theme_constant_override("separation", 14)
	who.add_child(UiFactory.make_avatar(UiFactory.initials_of(c.character_name), 34))
	var stack := VBoxContainer.new()
	stack.add_theme_constant_override("separation", 3)
	stack.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	stack.add_child(UiFactory.make_label(c.character_name, &"NameSerif"))
	stack.add_child(UiFactory.make_label(UiTokens.tr_upper(HRConstants.role_label(c.role)), &"MicroLabel"))
	who.add_child(stack)
	who.add_child(_spacer())
	if c.category != "founder":
		who.add_child(HRUiShared.area_stars_row(c.role, c.role_stats, 13))
	_root_box.add_child(who)

	# --- tablo başlığı ---
	var cols := HBoxContainer.new()
	cols.add_theme_constant_override("separation", 0)
	cols.add_child(_cell(tr("HR_TRAINING_COL_AREA"), 190, HORIZONTAL_ALIGNMENT_LEFT, &"ColumnHeader"))
	cols.add_child(_cell(tr("HR_TRAINING_COL_CURRENT"), 120, HORIZONTAL_ALIGNMENT_CENTER, &"ColumnHeader"))
	cols.add_child(_cell(tr("HR_TRAINING_COL_TARGET"), 150, HORIZONTAL_ALIGNMENT_CENTER, &"ColumnHeader"))
	cols.add_child(_cell(tr("HR_TRAINING_COL_FEE"), 120, HORIZONTAL_ALIGNMENT_CENTER, &"ColumnHeader"))
	cols.add_child(_cell(tr("HR_TRAINING_COL_DURATION"), 120, HORIZONTAL_ALIGNMENT_CENTER, &"ColumnHeader"))
	var band := PanelContainer.new()
	band.theme_type_variation = &"HeaderBand"
	band.add_child(cols)
	_root_box.add_child(band)

	for skill_key in _rows_for(c):
		_root_box.add_child(_skill_row(c, String(skill_key)))

	# --- tek uyarı satırı ---
	var warn := PanelContainer.new()
	warn.theme_type_variation = &"CardCta"
	var warn_row := HBoxContainer.new()
	warn_row.add_theme_constant_override("separation", 10)
	warn_row.add_child(HRUiShared.lock_glyph(12, UiTokens.ACCENT))
	warn_row.add_child(UiFactory.make_label(tr("HR_TRAINING_WARNING"), &"RowMeta", UiTokens.INK_MUTED))
	warn.add_child(warn_row)
	_root_box.add_child(warn)

	# --- alt bar ---
	_root_box.add_child(HRUiShared.hairline())
	var footer := HBoxContainer.new()
	footer.add_theme_constant_override("separation", 14)
	footer.add_child(HRUiShared.action_button(tr("HR_ATLAS_CANCEL"), _close))
	footer.add_child(_spacer())
	# Alan seçilmeden butonda rakam yok: sıfır hiçbir şeyin bedeli değil (§14 bedeli
	# taahhütten önce okutur, uydurmaz).
	if _selected == "":
		footer.add_child(HRUiShared.disabled_button(tr("HR_TRAINING_SEND"), tr("HR_TRAINING_STEP_AREA")))
	else:
		footer.add_child(UiFactory.make_label(
			"%s · %s" % [HRConstants.area_label(_selected), HRConstants.training_duration_text()],
			&"RowMeta", UiTokens.INK_DIM))
		# §5.4: para bir kilit değil, bedeldir. Kasa yetmese de buton basılır ve bedel kasayı
		# eksiye götürebilir; bedel butonun üstünde ve satırında okunuyor.
		var fee: int = CharacterRegistry.training_fee_for(_character_id, _selected)
		footer.add_child(HRUiShared.action_button(
			tr("HR_TRAINING_CTA").format({"fee": HRUiShared.money(fee)}), _on_send, true))
	_root_box.add_child(footer)


func _rows_for(c: Character) -> Array:
	if c.category == "founder":
		return HRConstants.trainable_keys()
	var out: Array = []
	for key in [HRConstants.role_key_area(c.role), HRConstants.role_secondary_area(c.role),
			HRConstants.SKILL_LEADERSHIP]:
		var k: String = String(key)
		if k != "" and not out.has(k):
			out.append(k)
	return out


func _skill_row(c: Character, skill_key: String) -> Control:
	var current: int = int(c.role_stats.get(skill_key, 0))
	var trainable: bool = CharacterRegistry.can_train(_character_id, skill_key)
	var ink: Color = UiTokens.INK if trainable else UiTokens.INK_DIM

	var card := PanelContainer.new()
	card.theme_type_variation = &"LedgerRowHover" if _selected == skill_key else &"LedgerRow"
	card.mouse_filter = Control.MOUSE_FILTER_STOP
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 0)
	card.add_child(row)

	row.add_child(_cell(HRConstants.area_label(skill_key), 190, HORIZONTAL_ALIGNMENT_LEFT, &"RowMeta", ink))

	var cur_slot := CenterContainer.new()
	cur_slot.custom_minimum_size = Vector2(120, 0)
	cur_slot.add_child(StarRating.make(current, 13, not trainable))
	row.add_child(cur_slot)

	# HEDEF: bir eğitim +1 PUAN, yani YARIM yıldız verir; tavan 5,0 yıldız (§5.3).
	var tgt_slot := HBoxContainer.new()
	tgt_slot.custom_minimum_size = Vector2(150, 0)
	tgt_slot.alignment = BoxContainer.ALIGNMENT_CENTER
	tgt_slot.add_theme_constant_override("separation", 8)
	tgt_slot.add_child(UiFactory.make_label("→", &"RowMeta", UiTokens.INK_DIM))
	tgt_slot.add_child(StarRating.make(mini(current + 1, HRConstants.AREA_MAX), 13, not trainable))
	row.add_child(tgt_slot)

	var fee: int = CharacterRegistry.training_fee_for(_character_id, skill_key)
	row.add_child(_cell(HRUiShared.money(fee), 120, HORIZONTAL_ALIGNMENT_CENTER, &"RowMeta", ink))
	# Son sütun: açıkken SÜRE, kilitliyken §5.4'ün iki gerekçesinden doğru olanı.
	var reason: String = CharacterRegistry.training_block_reason(_character_id, skill_key)
	row.add_child(_cell(HRConstants.training_duration_text() if trainable else reason,
		120, HORIZONTAL_ALIGNMENT_CENTER, &"RowMeta",
		UiTokens.INK_MUTED if trainable else UiTokens.INK_FAINT))

	if trainable:
		card.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		card.gui_input.connect(func(ev: InputEvent) -> void:
			if ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT:
				_selected = skill_key
				_rebuild())
	else:
		card.tooltip_text = reason
	return card


func _on_send() -> void:
	if HRSystem.send_to_training(_character_id, _selected):
		state_changed.emit()
	_close()


func _cell(text: String, width: int, align: int, variation: StringName, color: Variant = null) -> Label:
	var l := UiFactory.make_label(text, variation, color)
	l.horizontal_alignment = align
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	l.custom_minimum_size = Vector2(width, 0)
	return l


func _spacer() -> Control:
	var pad := Control.new()
	pad.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return pad


func _unhandled_input(ev: InputEvent) -> void:
	if ev.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_close()


func _close() -> void:
	queue_free()
