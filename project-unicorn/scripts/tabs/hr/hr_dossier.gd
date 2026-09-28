extends ScrollContainer

# Ekip dosyası: bir kişinin ayrıntı penceresi (WindowLayer.open_detail("hr_dossier",
# {"character_id": id})). Yukarıdan aşağı kimlik, ŞU AN, huy, YETENEKLER, DURUM ve satır
# menüsünün aksiyonları (HRLedger.action_list: aynı kapı, aynı gerekçe, aynı sonuç metni).
# Ofisten kurucu için de açılır; çalışana özgü satırlar (huy, moral, maaş, aksiyonlar) onda
# çizilmez.
# Bu dosya hiçbir sayı türetmez.

## Kişi ekipten ayrılınca pencere kendini kapatır (WindowFrame bu sinyali dinler).
signal close_requested

const LABEL_W := 76   # DURUM etiket sütunu: en uzun başlık (EXPERIENCE) sığar

var _id: String = ""
var _col: VBoxContainer


func _ready() -> void:
	horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_col = VBoxContainer.new()
	_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_col.add_theme_constant_override("separation", UiTokens.SPACE_XL)
	add_child(_col)
	# Maaş ve seviye yazımı sinyal atmıyor: aksiyon sonrası tazeleme HRLedger'dan gelir.
	add_to_group(HRLedger.VIEWS_GROUP)
	for sig in [EventBus.morale_changed, EventBus.employee_experience_changed,
			EventBus.employee_training_changed, EventBus.employee_promoted,
			EventBus.assignment_changed]:
		sig.connect(_on_person_changed)
	# İzin haftaları ve kurucunun hazırlık durumu tik sınırında değişir.
	EventBus.hr_day_processed.connect(rebuild_view)
	EventBus.character_removed.connect(_on_person_changed)


func populate(payload: Dictionary) -> void:
	_id = String(payload["character_id"])
	rebuild_view()


func _on_person_changed(character_id: String, _value = null) -> void:
	if character_id == _id:
		rebuild_view()


## Sinyallerin ve kişi aksiyonlarının (HRLedger.VIEWS_GROUP) tek tazeleme yolu.
func rebuild_view() -> void:
	var c: Character = CharacterRegistry.get_character(_id)
	if c == null:
		close_requested.emit()
		return
	UiFactory.clear(_col)
	var employee: bool = c.category == "employee"
	_col.add_child(_identity(c))
	var now := UiFactory.make_label(_now_text(c), &"BodySerif")
	now.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_col.add_child(_section("HR_DOSSIER_NOW", now))
	if employee and not c.traits.is_empty():
		_col.add_child(_trait_block(String(c.traits[0])))
	_col.add_child(_section("HR_DOSSIER_SKILLS", _skills(c)))
	_col.add_child(_section("HR_COL_STATE", _state_rows(c, employee)))
	if employee:
		_col.add_child(HRUiShared.hairline())
		_col.add_child(HRLedger.action_list(c, func(act: String) -> void:
			HRLedger.run_action(self, c, act)))


func _identity(c: Character) -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", UiTokens.SPACE_L)
	row.add_child(UiFactory.make_avatar(UiFactory.initials_of(c.character_name), 44))
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", UiTokens.SPACE_XXS)
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	col.add_child(UiFactory.make_label(c.character_name, &"NameSerif"))
	col.add_child(UiFactory.make_label(Fmt.upper(HRUiShared.roster_title(c)), &"MicroLabel"))
	row.add_child(col)
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


func _trait_block(trait_id: String) -> Control:
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", UiTokens.SPACE_XS)
	var chip: Control = HRUiShared.trait_chip(trait_id)
	chip.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	box.add_child(chip)
	var hint := UiFactory.make_label(HRConstants.trait_effect_text(trait_id), &"CaptionMuted")
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(hint)
	return box


## Çalışanda ana + ikincil alan + Liderlik (§4.4: rolün taşımadığı alan çizilmez); kurucu her
## alanda yetenekli, altı alan + Liderlik + Karizma.
func _skills(c: Character) -> GridContainer:
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", UiTokens.SPACE_XL)
	grid.add_theme_constant_override("v_separation", UiTokens.SPACE_M)
	var keys: Array = HRConstants.AREAS + [HRConstants.SKILL_LEADERSHIP, FounderConstants.SKILL_CHARISMA] \
		if c.category == "founder" else HRUiShared.role_areas(c.role) + [HRConstants.SKILL_LEADERSHIP]
	for key in keys:
		var cell: Control = StarRating.labelled(HRUiShared.skill_label(key),
			int(c.role_stats.get(key, 0)))
		cell.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		grid.add_child(cell)
	return grid


## DURUM: deneyim · moral · maaş (moral ve maaş çalışanın). Görev ŞU AN'da.
func _state_rows(c: Character, employee: bool) -> VBoxContainer:
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", UiTokens.SPACE_S)
	box.add_child(_kv("HR_COL_EXPERIENCE", HRLedger.experience_cell(c)))
	if employee:
		box.add_child(_kv("HR_COL_MORALE", HRUiShared.morale_row(c.morale, {})))
		box.add_child(_kv("HR_COL_SALARY", UiFactory.make_label(
			Fmt.money_exact(c.monthly_salary), &"RowMeta", UiTokens.INK)))
	return box


func _kv(label_key: String, value: Control) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", UiTokens.SPACE_M)
	var caption := UiFactory.make_label(tr(label_key), &"ColumnHeader", UiTokens.INK_DIM)
	caption.custom_minimum_size = Vector2(LABEL_W, 0)
	caption.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(caption)
	value.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(value)
	return row


func _section(title_key: String, body: Control) -> VBoxContainer:
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", UiTokens.SPACE_S)
	box.add_child(HRUiShared.section_header(tr(title_key)))
	box.add_child(body)
	return box
