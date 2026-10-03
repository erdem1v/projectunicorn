class_name HRAssignments
extends RefCounted

# EKİP → GÖREVLER matrisi (10b, §12): kim hangi işte. Sütunlar: yüz, ad, ana ve ikincil alanın
# değeri, Durum, sonra `HRConstants.JOBS`'un her işi.
#
# KURUCU BURADA YOK: atanabilir bir işçi değil, sprint ekibine kendiliğinden girer
# (SprintSystem.team).
#
# KUTULAR (§12.3): ana iş işaretli → dolu mürekkep; ikincil iş işaretli → çerçeveli; atanabilir boş
# kutu; atanamaz → kesikli ve boş (alanı yok) ya da kesikli ve kilitli (gerekçesi üstüne gelince).
# Araştırma sütunu salt okunurdur: araştırandaki kesikli kutu işaretlidir.

## face, name, the two areas, Durum, then Yapım ekibi, Test, Destek, Hesap sahipliği, Satış, Araştırma.
## Durum holds the risk and overload tags side by side in EN.
const W := [48, 210, 150, 240]
const W_JOBS := [104, 92, 104, 136, 92, 126]


static func head() -> PanelContainer:
	var band := PanelContainer.new()
	band.theme_type_variation = &"TableHead"
	band.custom_minimum_size.y = UiTokens.D_H_HEAD
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 0)
	band.add_child(row)
	row.add_child(HRUiShared.D_head("", W[0]))
	row.add_child(HRUiShared.D_head(tr_key("HR_COL_EMPLOYEE"), W[1], HORIZONTAL_ALIGNMENT_LEFT))
	row.add_child(HRUiShared.D_head("", W[2]))
	row.add_child(HRUiShared.D_head(tr_key("HR_COL_STATE"), W[3], HORIZONTAL_ALIGNMENT_LEFT))
	for i in HRConstants.JOBS.size():
		row.add_child(HRUiShared.D_head(HRConstants.job_label(HRConstants.JOBS[i]), W_JOBS[i]))
	return band


## `on_toggle(character_id, job_id, currently_on)` — tek yazma kapısı hr_tab'da. Karar beklerken
## (`read_only`) kutular ve boş satırın düğmesi kapalıdır.
static func build(on_toggle: Callable, on_recruit: Callable, read_only: bool) -> Control:
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 0)
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var roster: Array[Character] = CharacterRegistry.get_employees()
	if roster.is_empty():
		# Boş kadroda matris değil, Kadro'nun boş satırı: iki sayfada tek boşluk grameri.
		col.add_child(HRUiShared.D_empty_row(tr_key("HR_EMPTY_ROW"), tr_key("HR_SEARCH_START"), on_recruit, read_only))
		return col
	for emp in roster:
		col.add_child(_row(emp, on_toggle, read_only))
	col.add_child(_legend())
	return col


static func _row(emp: Character, on_toggle: Callable, read_only: bool) -> Control:
	var line := HRUiShared.D_row(false)
	line.custom_minimum_size.y = UiTokens.D_H_ROW_MATRIX
	var away: bool = emp.status == HRConstants.STATUS_ON_LEAVE
	var cells := HBoxContainer.new()
	cells.add_theme_constant_override("separation", 0)
	line.add_child(cells)

	var face := HBoxContainer.new()
	face.custom_minimum_size.x = W[0]
	face.add_theme_constant_override("separation", UiTokens.SPACE_L)
	face.add_child(Control.new())
	face.add_child(UiFactory.make_person_avatar(emp.character_name, emp.look, UiTokens.D_AVATAR_ROW, away))
	cells.add_child(face)

	var who := VBoxContainer.new()
	who.add_theme_constant_override("separation", 0)
	who.add_child(UiFactory.make_label(emp.character_name, &"DataMedium" if away else &"DataStrong",
		UiTokens.D_INK_3 if away else null))
	who.add_child(UiFactory.make_label(HRConstants.job_title(emp.role, emp.level), &"CondCaption"))
	var who_pad := MarginContainer.new()
	who_pad.custom_minimum_size.x = W[1]
	who_pad.add_theme_constant_override("margin_left", UiTokens.SPACE_M)
	who_pad.add_child(who)
	cells.add_child(who_pad)

	# Matris okunurken kimin nesi olduğunu hatırlatır: ana ve ikincil alan, değerleriyle.
	var areas := HBoxContainer.new()
	areas.custom_minimum_size.x = W[2]
	areas.add_theme_constant_override("separation", UiTokens.SPACE_XL)
	for key: String in HRUiShared.role_areas(emp.role):
		var pair := HBoxContainer.new()
		pair.add_theme_constant_override("separation", UiTokens.SPACE_S)
		pair.add_child(UiFactory.make_label(HRConstants.area_label(key), &"CondCaption"))
		pair.add_child(HRUiShared.D_skill_figure(int(emp.role_stats.get(key, 0)), HRUiShared.D_rank(emp.role, key)))
		areas.add_child(pair)
	cells.add_child(areas)

	# DURUM, Kadro ile aynı sütun (§13.3), burada her etiketiyle.
	cells.add_child(HRUiShared.D_state_cell(emp, true, W[3]))

	for i in HRConstants.JOBS.size():
		var slot := CenterContainer.new()
		slot.custom_minimum_size.x = W_JOBS[i]
		slot.add_child(_cell(emp, HRConstants.JOBS[i], on_toggle, read_only))
		cells.add_child(slot)
	for part: Control in cells.get_children():
		part.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	return line


## Kapalı kare hep aynı; gerekçesi değişir (§12.1: iş tavanı ayrı bir durum değil, atanamaz
## karenin bir gerekçesi). Kapıların sırası gerekçenin doğruluğunu belirler.
static func _cell(c: Character, job_id: String, on_toggle: Callable, read_only: bool) -> Control:
	var coef: float = HRConstants.job_coefficient(c.role, job_id, c.category)
	var checked: bool = c.assigned_job_ids.has(job_id)
	# Önce ALAN: işi hiç yapamayan birine dünyanın hâlini anlatmak yalan olurdu.
	if coef <= 0.0:
		return _closed(tr_key("HR_ASSIGN_NOT_YOUR_AREA"), "", UiTokens.D_BOX_JOB)
	# Satış canlı B2B ürün yokken kilitli-görünür (Satış §3.1): gizlemek "böyle bir şey yok"
	# der, kilitli kare "henüz yok, sebebi bu".
	if job_id == HRConstants.JOB_SALES and not ProductSystem.has_b2b_product():
		return _closed(tr_key("SALES_LOCKED_NO_B2B"), "util/lock", UiTokens.D_BOX_JOB)
	# Araştırma sütunu salt okunur (Ar-Ge §5.3): atama düğümün üzerinde yapılır, tek bir kutu
	# yirmi düğümden hangisine diyemez. Tavandan önce: bu sütun tavan ne olursa olsun kapalı.
	if job_id == HRConstants.JOB_RESEARCH:
		return _closed(tr_key("HR_ASSIGN_RESEARCH_ELSEWHERE"), "util/check" if checked else "util/lock", UiTokens.D_BOX_JOB)
	# İş tavanı (§12.1): boş üçüncü hücre kilitli ve görünür kalır.
	if not checked and c.assigned_job_ids.size() >= HRConstants.MAX_JOBS_PER_PERSON:
		return _closed(tr_key("HR_ASSIGN_JOB_CAP"), "util/lock", UiTokens.D_BOX_JOB)
	var box := _box(checked, coef >= 1.0, UiTokens.D_BOX_JOB)
	box.disabled = read_only
	if not read_only:
		box.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	box.pressed.connect(func() -> void: on_toggle.call(c.id, job_id, checked))
	return box


## An open box: held as the main job (ink), held as a second job (outlined), or empty.
static func _box(checked: bool, primary: bool, px: int) -> Button:
	var box := Button.new()
	box.theme_type_variation = &"JobBox" if not checked else (&"JobBoxPrimary" if primary else &"JobBoxSecondary")
	box.custom_minimum_size = Vector2(px, px)
	box.focus_mode = Control.FOCUS_NONE
	box.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	if checked:
		box.icon = load("res://assets/icons/util/check.svg")
	return box


## A box no one can open here: dashed, with its glyph (none for "no area") and its reason on hover.
static func _closed(reason: String, glyph: String, px: int) -> Control:
	var box := CenterContainer.new()
	box.custom_minimum_size = Vector2(px, px)
	box.tooltip_text = reason
	box.mouse_filter = Control.MOUSE_FILTER_STOP
	HRUiShared.D_dashed(box)
	if glyph != "":
		var ink: Color = UiTokens.D_INK_2 if glyph == "util/check" else UiTokens.D_INK_OFF
		box.add_child(UiFactory.make_glyph("res://assets/icons/%s.svg" % glyph,
			UiTokens.D_ICON_ROW if glyph == "util/check" else UiTokens.D_ICON_MARK, ink))
	return box


## Lejant, başlığın harfiyle: ana · ikincil · alanı yok · kilitli; sağda Araştırma'nın gerekçesi.
static func _legend() -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", UiTokens.SPACE_4XL)
	var px: int = UiTokens.D_BOX_JOB_SM
	for spec in [[_box(true, true, px), "HR_SKILL_LEGEND_MAIN"], [_box(true, false, px), "HR_SKILL_LEGEND_SECONDARY"],
			[_closed("", "", px), "HR_LEGEND_NO_AREA"], [_closed("", "util/lock", px), "HR_LEGEND_LOCKED"]]:
		var item := HBoxContainer.new()
		item.add_theme_constant_override("separation", UiTokens.SPACE_M)
		item.add_child(spec[0])
		item.add_child(UiFactory.make_label(tr_key(spec[1]), &"Caption"))
		row.add_child(item)
	var gap := Control.new()
	gap.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(gap)
	var why := HBoxContainer.new()
	why.add_theme_constant_override("separation", UiTokens.SPACE_S)
	why.add_child(UiFactory.make_glyph("res://assets/icons/util/lock.svg", UiTokens.D_ICON_PART, UiTokens.D_INK_4))
	why.add_child(UiFactory.make_label(tr_key("HR_ASSIGN_RESEARCH_ELSEWHERE"), &"MetaMuted"))
	row.add_child(why)
	for part: Control in row.find_children("*", "Control", true, false):
		part.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	HRUiShared.set_mouse_ignore(row)
	var pad := MarginContainer.new()
	pad.add_theme_constant_override("margin_top", UiTokens.SPACE_XL)
	pad.add_child(row)
	return pad


## `static func` içindeki tr() çalışırken ölür; çeviri TranslationServer'dan.
static func tr_key(key: String) -> String:
	return TranslationServer.translate(key)
