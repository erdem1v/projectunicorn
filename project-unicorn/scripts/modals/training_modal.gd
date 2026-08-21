extends Control

# EĞİTİME GÖNDER — onaylı tasarım 11c.
#
# TEK KİŞİ için. Üstte kişi satırı (baş harf + ad + rol + mevcut alan yıldızları), altında
# ALAN · MEVCUT · HEDEF · ÜCRET · SÜRE tablosu, sonra tek uyarı satırı ve alt bar.
#
# SATIRLAR: kişinin ANA + İKİNCİL alanı + LİDERLİK. rev 2 §3 altı alanı düz listede
# göstermeyi yasaklıyor ve tasarımın Selin'i tam olarak bu üçünü çiziyor. KURUCUNUN
# ana/ikincil ayrımı yok, o yüzden onda ALTI ALAN + Liderlik listelenir.
#
# SÜRE SABİT: "iki hafta" (HRConstants.TRAINING_DAYS). Bir önceki turda "süre yıldıza göre
# değişsin" diye bir hüküm vardı; REVİZE TASARIM onu geri aldı — 11c'nin üç satırında da
# aynı süre yazıyor ve bu rev 2 §8'in kendi cümlesiyle birebir örtüşüyor.
#
# PanelLayer'da yaşar, ModalLayer'da DEĞİL: HRAtlasModal'ın kalıbı. Sebebi kayıtlı
# (hr_tab.gd:_open_atlas) — ModalLayer boşluk ve 1-4 hız tuşlarını yutuyor, yani saat bir
# personel kararının üstünde koşuyordu.

signal state_changed

const PANEL_MIN := Vector2(760, 0)

var _character_id: String = ""
var _selected: String = ""
var _root_box: VBoxContainer = null


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP

	var dim := ColorRect.new()
	dim.color = UiTokens.SCRIM_MODAL
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(dim)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(center)

	var panel := PanelContainer.new()
	panel.theme_type_variation = &"ModalPanel"
	panel.custom_minimum_size = PANEL_MIN
	center.add_child(panel)

	var margin := MarginContainer.new()
	for side in ["margin_left", "margin_right", "margin_top", "margin_bottom"]:
		margin.add_theme_constant_override(side, 24)
	panel.add_child(margin)

	_root_box = VBoxContainer.new()
	_root_box.add_theme_constant_override("separation", 14)
	margin.add_child(_root_box)


## Ev sahibi ÖNCE add_child eder, SONRA burayı çağırır (ev kuralı).
func populate(character_id: String) -> void:
	_character_id = character_id
	_selected = ""
	if not is_node_ready():
		await ready
	_rebuild()


func _rebuild() -> void:
	for c in _root_box.get_children():
		_root_box.remove_child(c)
		c.queue_free()
	var c: Character = CharacterRegistry.get_character(_character_id)
	if c == null:
		_close()
		return

	# --- başlık: EĞİTİM · ALAN SEÇ ---
	var head := HBoxContainer.new()
	head.add_theme_constant_override("separation", 12)
	head.add_child(UiFactory.make_label(
		UiTokens.tr_upper(tr("HR_TRAINING")), &"SectionAmber"))
	head.add_child(UiFactory.make_label(
		tr("HR_TRAINING_STEP_AREA"), &"ColumnHeader", UiTokens.INK_DIM))
	var head_pad := Control.new()
	head_pad.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(head_pad)
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
	stack.add_child(UiFactory.make_label(
		UiTokens.tr_upper(HRConstants.role_label(c.role)), &"MicroLabel"))
	who.add_child(stack)
	var who_pad := Control.new()
	who_pad.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	who.add_child(who_pad)
	if c.category != "founder":
		who.add_child(HRUiShared.area_stars_row(c.role, c.role_stats, 13))
	_root_box.add_child(who)

	# --- tablo başlığı ---
	var cols := HBoxContainer.new()
	cols.add_theme_constant_override("separation", 0)
	cols.add_child(_head(tr("HR_TRAINING_COL_AREA"), 190, HORIZONTAL_ALIGNMENT_LEFT))
	cols.add_child(_head(tr("HR_TRAINING_COL_CURRENT"), 120))
	cols.add_child(_head(tr("HR_TRAINING_COL_TARGET"), 150))
	cols.add_child(_head(tr("HR_TRAINING_COL_FEE"), 120))
	cols.add_child(_head(tr("HR_TRAINING_COL_DURATION"), 120))
	var band := PanelContainer.new()
	band.theme_type_variation = &"HeaderBand"
	band.add_child(cols)
	_root_box.add_child(band)

	for skill_key in _rows_for(c):
		_root_box.add_child(_skill_row(c, String(skill_key)))

	# --- tek uyarı satırı (11c) ---
	var warn := PanelContainer.new()
	warn.theme_type_variation = &"CardCta"
	var warn_row := HBoxContainer.new()
	warn_row.add_theme_constant_override("separation", 10)
	warn_row.add_child(HRUiShared.lock_glyph(12, UiTokens.ACCENT))
	warn_row.add_child(UiFactory.make_label(
		tr("HR_TRAINING_WARNING"), &"RowMeta", UiTokens.INK_MUTED))
	warn.add_child(warn_row)
	_root_box.add_child(warn)

	# --- alt bar ---
	_root_box.add_child(HRUiShared.hairline())
	var footer := HBoxContainer.new()
	footer.add_theme_constant_override("separation", 14)
	footer.add_child(HRUiShared.action_button(tr("HR_ATLAS_CANCEL"), _close))
	var pad := Control.new()
	pad.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	footer.add_child(pad)
	if _selected != "":
		footer.add_child(UiFactory.make_label(
			"%s · %s" % [HRConstants.area_label(_selected), tr("HR_TRAINING_DURATION_WEEKS")],
			&"RowMeta", UiTokens.INK_DIM))
	var fee: int = CharacterRegistry.training_fee_for(_character_id, _selected) if _selected != "" else 0
	var cta: String = tr("HR_TRAINING_CTA").format({"fee": HRUiShared.money(fee)})
	if _selected == "":
		footer.add_child(HRUiShared.disabled_button(cta, tr("HR_TRAINING_STEP_AREA")))
	elif GameState.cash < fee:
		footer.add_child(HRUiShared.disabled_button(cta, tr("HR_WARN_RETAINER_CASH")))
	else:
		footer.add_child(HRUiShared.action_button(cta, _on_send, true))
	_root_box.add_child(footer)


## Hangi yetenekler listelenir. Çalışan: ANA + İKİNCİL alan + Liderlik (11c birebir).
## Kurucu: ana/ikincil ayrımı olmadığı için ALTI ALAN + Liderlik.
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

	var card := PanelContainer.new()
	card.theme_type_variation = &"LedgerRowHover" if _selected == skill_key else &"LedgerRow"
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 0)
	card.add_child(row)

	row.add_child(_cell(HRConstants.area_label(skill_key), 190, HORIZONTAL_ALIGNMENT_LEFT,
		UiTokens.INK if trainable else UiTokens.INK_DIM))

	var cur_slot := CenterContainer.new()
	cur_slot.custom_minimum_size = Vector2(120, 0)
	cur_slot.add_child(StarRating.make(current, 13, not trainable))
	row.add_child(cur_slot)

	# HEDEF: bir eğitim +1 PUAN verir, yani YARIM yıldız. Tasarımın mockup'ı tam yıldız
	# adımı gösteriyordu ama o veri kalibrasyon metniydi; motorun verdiği +1'dir ve
	# ekranda uydurma bir adım göstermek yalan olurdu.
	var tgt_slot := HBoxContainer.new()
	tgt_slot.custom_minimum_size = Vector2(150, 0)
	tgt_slot.alignment = BoxContainer.ALIGNMENT_CENTER
	tgt_slot.add_theme_constant_override("separation", 8)
	tgt_slot.add_child(UiFactory.make_label("→", &"RowMeta", UiTokens.INK_DIM))
	tgt_slot.add_child(StarRating.make(mini(current + 1, HRConstants.AREA_TRAIN_CAP), 13, not trainable))
	row.add_child(tgt_slot)

	var fee: int = CharacterRegistry.training_fee_for(_character_id, skill_key)
	row.add_child(_cell(HRUiShared.money(fee) if trainable else "—", 120,
		HORIZONTAL_ALIGNMENT_CENTER, UiTokens.INK if trainable else UiTokens.INK_DIM))
	row.add_child(_cell(tr("HR_TRAINING_DURATION_WEEKS") if trainable else tr("HR_TRAINING_AT_CAP"),
		120, HORIZONTAL_ALIGNMENT_CENTER, UiTokens.INK_MUTED if trainable else UiTokens.INK_FAINT))

	if trainable:
		card.mouse_filter = Control.MOUSE_FILTER_STOP
		card.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		card.gui_input.connect(func(ev: InputEvent) -> void:
			if ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT:
				_selected = skill_key
				_rebuild())
	else:
		card.tooltip_text = tr("HR_TRAINING_AT_CAP")
		card.mouse_filter = Control.MOUSE_FILTER_STOP
	return card


func _on_send() -> void:
	if _selected == "":
		return
	if HRSystem.send_to_training(_character_id, _selected):
		state_changed.emit()
	_close()


func _cell(text: String, width: int, align: int, color: Color) -> Label:
	var l := UiFactory.make_label(text, &"RowMeta", color)
	l.horizontal_alignment = align
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	l.custom_minimum_size = Vector2(width, 0)
	return l


func _head(text: String, width: int, align: int = HORIZONTAL_ALIGNMENT_CENTER) -> Label:
	var l := UiFactory.make_label(text, &"ColumnHeader")
	l.horizontal_alignment = align
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	l.custom_minimum_size = Vector2(width, 0)
	return l


func _unhandled_input(ev: InputEvent) -> void:
	if ev.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_close()


func _close() -> void:
	queue_free()
