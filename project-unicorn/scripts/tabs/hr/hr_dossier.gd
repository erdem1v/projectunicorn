extends VBoxContainer

# Ekip dosyası: bir kişinin ayrıntı penceresi (WindowLayer.open_detail("hr_dossier",
# {"character_id": id})), köşesi kesik bir belge. Başında yüzü, adı ve unvanı; altında ŞU AN, huy,
# YETENEKLER (tablonun yedi sütunu, kurucuda Karizma da), DURUM ve satır menüsünün aksiyonları
# (HRLedger.action_list: aynı kapı, aynı gerekçe, aynı sonuç metni). Ofisten kurucu için de açılır;
# çalışana özgü satırlar (huy, moral, maaş, aksiyonlar) onda çizilmez. Pencere içeriği kadar uzar.
# Bu dosya hiçbir sayı türetmez.

## Kişi ekipten ayrılınca pencere kendini kapatır (WindowFrame bu sinyali dinler).
signal close_requested
signal fit_changed

const KEY_W := 84   # DURUM's key column: EXPERIENCE fits

var frame_options := {"variation": &"DocWindow", "theme": true, "pad": Vector2i.ZERO, "owns_close": true}
var _id: String = ""
var _head: PanelContainer
var _scroll: ScrollContainer
var _body: MarginContainer
var _col: VBoxContainer


func _ready() -> void:
	add_theme_constant_override("separation", 0)
	_head = PanelContainer.new()
	_head.theme_type_variation = &"DocHead"
	add_child(_head)
	_scroll = ScrollContainer.new()
	_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(_scroll)
	_body = MarginContainer.new()
	_body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_body.add_theme_constant_override("margin_left", UiTokens.SPACE_XXL)
	_body.add_theme_constant_override("margin_top", UiTokens.SPACE_XS)
	_body.add_theme_constant_override("margin_right", UiTokens.SPACE_XXL)
	_body.add_theme_constant_override("margin_bottom", UiTokens.SPACE_XXL)
	_scroll.add_child(_body)
	_col = VBoxContainer.new()
	_col.add_theme_constant_override("separation", 0)
	_body.add_child(_col)
	# Wrapped text knows its height only once it has its width: the window refits when it settles.
	_body.minimum_size_changed.connect(fit_changed.emit)
	# Maaş ve seviye yazımı sinyal atmıyor: aksiyon sonrası tazeleme HRLedger'dan gelir.
	add_to_group(HRLedger.VIEWS_GROUP)
	for sig in [EventBus.morale_changed, EventBus.employee_experience_changed,
			EventBus.employee_training_changed, EventBus.employee_promoted,
			EventBus.assignment_changed]:
		sig.connect(_on_person_changed)
	# İzin haftaları ve kurucunun hazırlık durumu tik sınırında değişir.
	EventBus.hr_day_processed.connect(rebuild_view)
	EventBus.character_removed.connect(_on_person_changed)


func _exit_tree() -> void:
	get_tree().call_group(HRLedger.VIEWS_GROUP, &"hold_person", _id, false)


func populate(payload: Dictionary) -> void:
	_id = String(payload["character_id"])
	rebuild_view()
	# Ekip penceresi açıksa kişinin satırı dosya açıkken seçili kalır.
	get_tree().call_group(HRLedger.VIEWS_GROUP, &"hold_person", _id, true)


func _on_person_changed(character_id: String, _value = null) -> void:
	if character_id == _id:
		rebuild_view()


## The file's natural height: its head and its whole body.
func fit_height() -> float:
	return get_combined_minimum_size().y - _scroll.get_combined_minimum_size().y + _body.get_combined_minimum_size().y


## Sinyallerin ve kişi aksiyonlarının (HRLedger.VIEWS_GROUP) tek tazeleme yolu.
func rebuild_view() -> void:
	var c: Character = CharacterRegistry.get_character(_id)
	if c == null:
		close_requested.emit()
		return
	UiFactory.clear(_head)
	UiFactory.clear(_col)
	var employee: bool = c.category == "employee"
	_head.add_child(_identity(c, employee))
	_col.add_child(_section("HR_DOSSIER_NOW"))
	var now := UiFactory.make_label(_now_text(c), &"BodyLabel")
	now.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_col.add_child(_gap(UiTokens.SPACE_M))
	_col.add_child(now)
	if employee and not c.traits.is_empty():
		_col.add_child(_gap(UiTokens.SPACE_L))
		_col.add_child(_trait_block(String(c.traits[0])))
	_col.add_child(_section("HR_DOSSIER_SKILLS"))
	_col.add_child(_gap(UiTokens.SPACE_M))
	_col.add_child(_skills(c, employee))
	_col.add_child(_section("HR_COL_STATE"))
	_col.add_child(_kv("HR_COL_EXPERIENCE", HRUiShared.D_xp(c)))
	if employee:
		_col.add_child(_kv("HR_COL_MORALE", HRUiShared.D_morale(c.morale, {})))
		_col.add_child(_kv("HR_COL_SALARY", UiFactory.make_label(Fmt.money_exact(c.monthly_salary), &"DataText")))
		_col.add_child(_gap(UiTokens.SPACE_XXL))
		_col.add_child(HSeparator.new())
		_col.add_child(_gap(UiTokens.SPACE_M))
		_col.add_child(HRLedger.action_list(c, func(act: String) -> void: HRLedger.run_action(self, c, act), false))


## Face, name and title (the founder's company under the founder's name), and the close.
func _identity(c: Character, employee: bool) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", UiTokens.SPACE_L)
	row.add_child(UiFactory.make_person_avatar(c.character_name, c.look, UiTokens.D_AVATAR_DOC,
		c.status == HRConstants.STATUS_ON_LEAVE))
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 0)
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col.add_child(UiFactory.make_label(c.character_name, &"NameTitle"))
	col.add_child(UiFactory.make_label(HRUiShared.roster_title(c) if employee else GameState.company_name,
		&"CondCaption"))
	row.add_child(col)
	var close := UiFactory.make_close_button(close_requested.emit, true)
	close.custom_minimum_size = Vector2.ONE * UiTokens.D_H_BTN_SM
	row.add_child(close)
	for part: Control in row.get_children():
		part.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	return row


## Şu an ne yapıyor: iş ve meşguliyet (izin, eğitim) okunur.
func _now_text(c: Character) -> String:
	if c.category == "founder":
		return HRSystem.founder_task_label()
	if c.training_weeks_left > 0:
		return HRSystem.training_line(c)
	if HRSystem.is_busy(c):
		return HRSystem.leave_line(c)
	if c.assigned_job_ids.is_empty():
		return tr("HR_DOSSIER_IDLE")
	return HRLedger.task_text(c)


func _trait_block(trait_id: String) -> VBoxContainer:
	var block := VBoxContainer.new()
	block.add_theme_constant_override("separation", UiTokens.SPACE_S)
	block.add_child(HRUiShared.D_trait_cell([trait_id], true))
	var effect := UiFactory.make_label(HRConstants.trait_effect_text(trait_id), &"Caption")
	effect.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	block.add_child(effect)
	return block


## The table's seven columns in its order, Liderlik ruled off; the role's two areas on its band, the
## founder's Karizma last.
func _skills(c: Character, employee: bool) -> VBoxContainer:
	var list := VBoxContainer.new()
	list.add_theme_constant_override("separation", 0)
	var keys: Array = HRConstants.AREAS + [HRConstants.SKILL_LEADERSHIP]
	if not employee:
		keys.append(FounderConstants.SKILL_CHARISMA)
	for key: String in keys:
		if key == HRConstants.SKILL_LEADERSHIP:
			list.add_child(_gap(UiTokens.SPACE_XS))
			list.add_child(HSeparator.new())
		var rank: StringName = HRUiShared.D_rank(c.role, key) if employee else &""
		var row := PanelContainer.new()
		row.theme_type_variation = &"TableRow"
		row.custom_minimum_size.y = UiTokens.D_H_SKILL_ROW
		if rank != &"":
			var band := Panel.new()
			band.theme_type_variation = &"RoleBand"
			row.add_child(band)
		var line := HBoxContainer.new()
		var pad := MarginContainer.new()
		pad.add_theme_constant_override("margin_left", UiTokens.SPACE_M)
		pad.add_theme_constant_override("margin_right", UiTokens.SPACE_M)
		pad.add_child(line)
		row.add_child(pad)
		var label := UiFactory.make_label(HRUiShared.skill_label(key), &"CondData", UiTokens.D_INK_3)
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		line.add_child(label)
		line.add_child(HRUiShared.D_skill_figure(int(c.role_stats.get(key, 0)), rank))
		list.add_child(row)
	return list


func _kv(label_key: String, value: Control) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.custom_minimum_size.y = UiTokens.D_H_BTN_SM
	row.add_theme_constant_override("separation", UiTokens.SPACE_L)
	var key := UiFactory.make_label(Fmt.upper(tr(label_key)), &"KeyLabel")
	key.custom_minimum_size.x = KEY_W
	row.add_child(key)
	row.add_child(value)
	for part: Control in row.get_children():
		part.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	return row


## A section's caps key with its rule running right, a step below the last.
func _section(title_key: String) -> VBoxContainer:
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 0)
	box.add_child(_gap(UiTokens.SPACE_XXL))
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", UiTokens.SPACE_M)
	row.add_child(UiFactory.make_label(Fmt.upper(tr(title_key)), &"KeyLabel"))
	var rule := HSeparator.new()
	rule.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(rule)
	box.add_child(row)
	return box


func _gap(h: int) -> Control:
	var gap := Control.new()
	gap.custom_minimum_size.y = h
	return gap
