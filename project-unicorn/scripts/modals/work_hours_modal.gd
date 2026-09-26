extends Control

# ÇALIŞMA SAATLERİ — §8.5, onaylı 19a–19d.
#
# Sütunlar KAPSAM · BAŞLANGIÇ · SÜRE · DURUM · KAYNAK · MORAL. BAŞLANGIÇ yalnız Şirket
# satırında doludur (§8.1). Geri dönüş eylemi KAYNAK hücresinin içindedir: devralan satır
# nereden aldığını yazar, karar veren satır geri-ok çipi taşır. Kurucu listede görünmez (§2, §8.1).
#
# TAAHHÜTLÜ MODAL. Düzenlemeler `_draft`'a yazılır; `Uygula` WorkHoursSystem.apply_state'i
# çağırır, `Vazgeç` taslağı atar ("maliyet taahhütten ÖNCE okunur", §8.5). Taslak da canlı durum
# da WorkHoursSystem'in aynı çözümleyicisinden geçer (§15.2), önizleme ile tahakkuk ayrışamaz.
#
# MORAL sütunu kişinin moralini ve saatin moral YÖNÜNÜ (kademeli şevron) taşır. Katsayı yok
# (§8.5); kademenin cümlesi glifin tooltip'inde.
#
# İki bilinçli sapma (sahip hükmü): Şirket satırının BAŞLANGIÇ hücresinde sönük bitiş saati
# (sütun bu yüzden 190, esneyen KAPSAM genişliği verdi); kadro tamamen boşken DURUM ve MORAL
# başlıkları çizilmez.
#
# PanelLayer'da yaşar, ModalLayer'da değil: ModalLayer hız tuşlarını yutuyor.

signal state_changed

## KAPSAM esner, kalan beşi sabit.
const W_START := 190
const W_HOURS := 150
const W_STATE := 110
const W_SOURCE := 120
const W_MORALE := 110
const H_HEAD := 30
const H_COMPANY := 52
const H_ROW := 42
const PAD_ROW := 14
const INDENT_GROUP := 26
const INDENT_PERSON := 46
const STEP_BTN := Vector2(22, 24)
const STEP_VALUE_W := 56
const MORALE_METER := Vector2(44, 4)

@onready var _root_box: VBoxContainer = %RootBox

var _draft: Dictionary = {}


func _ready() -> void:
	(%Dimmer as ColorRect).color = UiTokens.SCRIM_MODAL


## Ev sahibi ÖNCE add_child eder, SONRA burayı çağırır. Taslak açılışta bir kez alınır;
## motora yalnız `Uygula` dokunur.
func populate() -> void:
	_draft = WorkHoursSystem.draft_state()
	_rebuild()


func _rebuild() -> void:
	for n in _root_box.get_children():
		_root_box.remove_child(n)
		n.queue_free()

	_root_box.add_child(UiFactory.make_label(tr("HR_HOURS_TITLE"), &"TitleSerif"))
	_root_box.add_child(_gap(14))
	_root_box.add_child(HRUiShared.hairline())
	_root_box.add_child(_gap(14))

	var roster: Array[Character] = CharacterRegistry.get_employees()
	_root_box.add_child(_column_head(roster.is_empty()))
	_root_box.add_child(_company_row(roster.size()))

	for group_id in HRConstants.ROSTER_GROUPS:
		var gid: String = String(group_id)
		# Boş grup da satırını taşır: grup istisnası o gruba SONRADAN katılanı da kapsar (§8.1).
		_root_box.add_child(_group_row(gid))
		for emp in roster:
			if String(HRConstants.ROLE_GROUP.get(emp.role, "")) == gid:
				_root_box.add_child(_person_row(emp))

	var cost: Control = _cost_block()
	if cost != null:
		_root_box.add_child(cost)
	_root_box.add_child(_gap(20))
	_root_box.add_child(_footer())


func _gap(h: int) -> Control:
	var pad := Control.new()
	pad.custom_minimum_size = Vector2(0, h)
	pad.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return pad


## SÜTUNU ÇİVİLER. HBoxContainer bir çocuğun asgari boyutunu kırpmaz; içeriği bütçesini aşan
## tek hücre bütün satırı kaydırırdı. Düz `Control` yerleşim yapmaz, asgari boyutu yalnız kendi
## `custom_minimum_size`'ıdır; `clip_contents` taşanı keser. width <= 0 = esneyen KAPSAM sütunu.
func _pin(width: int, child: Control) -> Control:
	var cell := Control.new()
	if width > 0:
		cell.custom_minimum_size = Vector2(width, 0)
	else:
		cell.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cell.clip_contents = true
	cell.mouse_filter = Control.MOUSE_FILTER_PASS
	cell.add_child(child)
	child.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	return cell


## Satır kabuğu: sol boşluk girintiyi taşır, altında hairline.
func _row(height: int, indent: int, tint: bool, divider: Color, cells: Array) -> Control:
	var wrap := VBoxContainer.new()
	wrap.add_theme_constant_override("separation", 0)
	var body := PanelContainer.new()
	var sb: StyleBox = StyleBoxEmpty.new()
	if tint:
		sb = StyleBoxFlat.new()
		(sb as StyleBoxFlat).bg_color = UiTokens.SURFACE_ROW_TINT
	body.add_theme_stylebox_override("panel", sb)
	wrap.add_child(body)
	var mg := MarginContainer.new()
	mg.add_theme_constant_override("margin_left", PAD_ROW + indent)
	mg.add_theme_constant_override("margin_right", PAD_ROW)
	body.add_child(mg)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 0)
	row.custom_minimum_size = Vector2(0, height)
	for cell in cells:
		row.add_child(cell)
	mg.add_child(row)
	wrap.add_child(HRUiShared.hairline(divider))
	return wrap


# --- Sütun başlıkları ---------------------------------------------------------

## Kadro tamamen boşken DURUM ve MORAL başlıkları çizilmez; doluyken DURUM o an boş olsa da
## başlık durur, yoksa ilk istisnada tablo yeniden akardı.
func _column_head(roster_empty: bool) -> Control:
	return _row(H_HEAD, 0, false, UiTokens.CARD_BORDER, [
		_head_cell(tr("HR_HOURS_COL_SCOPE"), 0),
		_head_cell(tr("HR_HOURS_COL_START"), W_START),
		_head_cell(tr("HR_HOURS_COL_HOURS"), W_HOURS),
		_head_cell("" if roster_empty else tr("HR_HOURS_COL_STATE"), W_STATE),
		_head_cell(tr("HR_HOURS_COL_SOURCE"), W_SOURCE),
		_head_cell("" if roster_empty else tr("HR_COL_MORALE"), W_MORALE, HORIZONTAL_ALIGNMENT_RIGHT),
	])


func _head_cell(text: String, width: int, align: int = HORIZONTAL_ALIGNMENT_LEFT) -> Control:
	var lbl := UiFactory.make_label(text, &"ColumnHeader")
	lbl.horizontal_alignment = align
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	return _pin(width, lbl)


# --- Satırlar -----------------------------------------------------------------

func _company_row(headcount: int) -> Control:
	var hours: int = int(_draft["company"])
	var start: int = int(_draft["start"])

	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 2)
	col.alignment = BoxContainer.ALIGNMENT_CENTER
	col.add_child(UiFactory.make_label(tr("HR_HOURS_SCOPE_COMPANY"), &"RowName"))
	col.add_child(UiFactory.make_label(tr("HR_HOURS_COMPANY_SUB").format({"n": headcount}), &"ColumnHeader"))

	# BAŞLANGIÇ yalnız şirket kapsamında (§8.1): "Ofis tek saatte açılır; değişen, kimin ne
	# zaman çıktığıdır." Yanında sönük bitiş saati.
	var start_cell := HBoxContainer.new()
	start_cell.add_theme_constant_override("separation", 6)
	var set_start: Callable = _set_scope.bind("start")
	var start_step: Control = _stepper("%02d:00" % start,
		start > HRConstants.START_HOUR_MIN, start < HRConstants.START_HOUR_MAX,
		set_start.bind(start - 1), set_start.bind(start + 1), UiTokens.INK, false)
	start_step.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	start_cell.add_child(start_step)
	var window: Dictionary = WorkHoursSystem.company_window(hours, start)
	var end_lbl := UiFactory.make_label("→ %s" % String(window["end_text"]), &"ColumnHeader", UiTokens.INK_FAINT)
	end_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	start_cell.add_child(end_lbl)

	return _row(H_COMPANY, 0, true, UiTokens.CARD_BORDER, [
		_pin(0, col),
		_pin(W_START, start_cell),
		_hours_cell(hours, false, false, _set_scope.bind("company")),
		_state_cell(hours),
		# Şirketin üstünde devralacağı kapsam yok, dönülecek yer de yok: kaynak "temel".
		_source_text(tr("HR_HOURS_SOURCE_BASE")),
		_pin(W_MORALE, Control.new()),
	])


func _group_row(group_id: String) -> Control:
	var owns: bool = WorkHoursSystem.group_has_override_in(_draft, group_id)
	var hours: int = int((_draft["groups"] as Dictionary).get(group_id, _draft["company"]))
	var name_cell := UiFactory.make_label(UiTokens.tr_upper(HRConstants.group_label(group_id)), &"SectionAmber")
	name_cell.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	return _row(H_ROW, INDENT_GROUP, false, UiTokens.DIVIDER_LIGHT, [
		_pin(0, name_cell),
		_pin(W_START, Control.new()),
		_hours_cell(hours, not owns, false, _set_scope.bind("groups", group_id)),
		_state_cell(hours),
		_source_cell(owns, tr("HR_HOURS_SOURCE_FROM_COMPANY"), _clear_scope.bind("groups", group_id)),
		_pin(W_MORALE, Control.new()),
	])


func _person_row(emp: Character) -> Control:
	var owns: bool = WorkHoursSystem.person_has_override_in(_draft, emp)
	var hours: int = WorkHoursSystem.hours_in(_draft, emp)

	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 2)
	col.alignment = BoxContainer.ALIGNMENT_CENTER
	col.add_child(UiFactory.make_label(emp.character_name, &"RowName"))
	col.add_child(UiFactory.make_label(
		UiTokens.tr_upper(HRConstants.job_title(emp.role, emp.level)), &"ColumnHeader"))

	# `inherited_from_in` KAPSAM SÖZCÜĞÜ döner ("group"/"company"), grup id'si değil.
	var from_key: String = "HR_HOURS_SOURCE_FROM_GROUP" \
		if WorkHoursSystem.inherited_from_in(_draft, emp) == "group" \
		else "HR_HOURS_SOURCE_FROM_COMPANY"
	return _row(H_ROW, INDENT_PERSON, false, UiTokens.DIVIDER_LIGHT, [
		_pin(0, col),
		_pin(W_START, Control.new()),
		_hours_cell(hours, not owns, HRConstants.is_short_day_hours(hours), _set_scope.bind("people", emp.id)),
		_state_cell(hours),
		_source_cell(owns, tr(from_key), _clear_scope.bind("people", emp.id)),
		_morale_cell(emp, hours),
	])


# --- Hücreler -----------------------------------------------------------------

## Çivilenmiş hücre tam yükseklik alır; içerik dikeyde ortada durur.
func _centered(child: Control) -> Control:
	var box := HBoxContainer.new()
	box.add_theme_constant_override("separation", 0)
	child.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	box.add_child(child)
	return box


## SÜRE hücresi. Dört giysi, tamamı kutuda: devralan (sönük kenar, dolgusuz) · şirket tabanı ·
## kendi kararı mesai (amber) · kendi kararı kısa gün (yeşil). Stepper her satırda çizilir:
## devralan satırda basmak o satıra bir istisna YAZAR.
func _hours_cell(hours: int, inherited: bool, short_day: bool, on_set: Callable) -> Control:
	var color: Color = UiTokens.INK
	if inherited:
		color = UiTokens.INK_DIM
	elif HRConstants.is_overtime_hours(hours):
		color = UiTokens.ACCENT
	elif short_day:
		color = UiTokens.POSITIVE
	return _pin(W_HOURS, _centered(_stepper(
		tr("HR_HOURS_VALUE").format({"n": hours}),
		hours > HRConstants.WORK_HOURS_MIN, hours < HRConstants.WORK_HOURS_MAX,
		on_set.bind(hours - 1), on_set.bind(hours + 1), color, inherited)))


func _stepper(text: String, can_down: bool, can_up: bool, on_down: Callable, on_up: Callable,
		color: Color, dashed: bool) -> Control:
	var box := HBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	box.add_child(_step_button("−", can_down, on_down))

	var value := PanelContainer.new()
	var sb := StyleBoxFlat.new()
	sb.set_border_width_all(1)
	sb.set_corner_radius_all(2)
	if dashed:
		# StyleBoxFlat'te kesikli kenar yok; "ödünç" okunuşu yarı saydam kenarla verilir.
		sb.border_color = Color(UiTokens.BORDER_HOVER, 0.55)
		sb.bg_color = Color(0, 0, 0, 0)
	elif color == UiTokens.ACCENT or color == UiTokens.POSITIVE:
		sb.border_color = color
		sb.bg_color = Color(color, 0.10)
	else:
		sb.border_color = UiTokens.BORDER_STEPPER_OWN
		sb.bg_color = Color(UiTokens.INK, 0.05)
	value.add_theme_stylebox_override("panel", sb)
	var lbl := UiFactory.make_label(text, &"RowMeta" if dashed else &"StepperValue", color)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl.custom_minimum_size = Vector2(STEP_VALUE_W, STEP_BTN.y)
	value.add_child(lbl)
	box.add_child(value)

	box.add_child(_step_button("+", can_up, on_up))
	return box


## Sessiz düğme: kartın tek dolu amber öğesi `Uygula` kalmalı.
func _step_button(glyph: String, enabled: bool, on_press: Callable) -> Button:
	var btn := Button.new()
	btn.text = glyph
	btn.custom_minimum_size = STEP_BTN
	btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	btn.disabled = not enabled
	if enabled:
		btn.pressed.connect(on_press)
	return btn


## §8.5 DURUM DİLİ: 8 saat nötr ve süslemesiz · üstü amber "+Ns mesai" · altı yeşil "−Ns kısa".
func _state_cell(hours: int) -> Control:
	var delta: int = hours - HRConstants.WORK_HOURS_DEFAULT
	if delta == 0:
		return _pin(W_STATE, Control.new())
	var text: String = tr("HR_STATE_HOURS_OVER").format({"n": delta}) if delta > 0 \
		else tr("HR_STATE_HOURS_SHORT").format({"n": -delta})
	var lbl := UiFactory.make_label(text, &"RowMeta", UiTokens.ACCENT if delta > 0 else UiTokens.POSITIVE)
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	return _pin(W_STATE, lbl)


## KAYNAK: devralan satır nereden aldığını yazar; karar veren satır geri-ok çipiyle "şirkete
## dön" taşır. Çip kendi ölçüsünü taşır: temanın buton dolgusu 120px'lik sütunu aşardı.
func _source_cell(owns: bool, from_text: String, on_revert: Callable) -> Control:
	if not owns:
		return _source_text(from_text)
	var chip := Button.new()
	chip.text = tr("HR_HOURS_BACK_TO_COMPANY")
	chip.icon = HRUiShared.revert_arrow_icon()
	chip.add_theme_constant_override("icon_max_width", 10)
	chip.add_theme_constant_override("h_separation", 5)
	chip.add_theme_font_size_override("font_size", UiTokens.SIZE_META)
	chip.add_theme_color_override("font_color", UiTokens.INK_DIM)
	chip.add_theme_color_override("font_hover_color", UiTokens.INK_MUTED)
	chip.add_theme_color_override("icon_normal_color", UiTokens.INK_DIM)
	chip.add_theme_color_override("icon_hover_color", UiTokens.INK_MUTED)
	for state in ["normal", "hover", "pressed", "focus"]:
		var sb := StyleBoxFlat.new()
		sb.bg_color = Color(0, 0, 0, 0)
		sb.set_border_width_all(1)
		sb.border_color = UiTokens.BORDER_HOVER if state == "hover" else UiTokens.CARD_BORDER
		sb.set_corner_radius_all(2)
		sb.content_margin_left = 7
		sb.content_margin_right = 7
		sb.content_margin_top = 3
		sb.content_margin_bottom = 3
		chip.add_theme_stylebox_override(state, sb)
	chip.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	chip.pressed.connect(on_revert)
	return _pin(W_SOURCE, _centered(chip))


func _source_text(text: String) -> Control:
	var lbl := UiFactory.make_label(text, &"ColumnHeader", UiTokens.INK_FAINT)
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	return _pin(W_SOURCE, lbl)


## MORAL: yön göstergesi + modalin ölçüsünde moral çubuğu ve sayı. `HRUiShared.morale_row`
## defterin 124–150px çubuğunu taşır ve 110px'lik sütunu aşardı.
func _morale_cell(emp: Character, hours: int) -> Control:
	var cell := HBoxContainer.new()
	cell.add_theme_constant_override("separation", 8)
	cell.alignment = BoxContainer.ALIGNMENT_END

	var dir: Control = _morale_direction(hours)
	if dir != null:
		cell.add_child(dir)

	var color: Color = HRUiShared.morale_color(emp.morale)
	var meter := ProgressBar.new()
	meter.theme_type_variation = &"BuildProgress"
	meter.show_percentage = false
	meter.custom_minimum_size = MORALE_METER
	meter.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	meter.min_value = float(HRConstants.MORALE_MIN)
	meter.max_value = float(HRConstants.MORALE_MAX)
	meter.value = float(emp.morale)
	HRUiShared.override_bar_fill(meter, color)
	cell.add_child(meter)

	var value := UiFactory.make_label(str(emp.morale), &"StepperValue", color)
	value.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	cell.add_child(value)
	return _pin(W_MORALE, cell)


## Kademeli şevron: 9s bir · 10s iki · 11s üç amber aşağı · 7s düz çizgi · 5-6s yeşil yukarı ·
## 8s hiç. Kademenin cümlesi tooltip'te.
func _morale_direction(hours: int) -> Control:
	var delta: int = hours - HRConstants.WORK_HOURS_DEFAULT
	if delta == 0:
		return null
	var box := HBoxContainer.new()
	box.add_theme_constant_override("separation", 1)
	box.alignment = BoxContainer.ALIGNMENT_END
	box.tooltip_text = tr("HR_HOURS_HOVER_%d" % hours)
	box.mouse_filter = Control.MOUSE_FILTER_STOP
	if delta > 0:
		for _i in delta:
			box.add_child(HRUiShared.chevron(9, UiTokens.ACCENT, false))
	elif delta == -1:
		box.add_child(HRUiShared.chevron_flat(9, UiTokens.POSITIVE))
	else:
		box.add_child(HRUiShared.chevron(9, UiTokens.POSITIVE, true))
	return box


# --- §14 bedel bloğu ----------------------------------------------------------

## §8.5: kimse mesaide ve kimse kısa günde değilken bedel listesi TAMAMEN kapanır (null).
func _cost_block() -> Control:
	var counts: Dictionary = WorkHoursSystem.counts_in(_draft)
	var over: int = int(counts["overtime"])
	var short_day: int = int(counts["short_day"])
	if over == 0 and short_day == 0:
		return null

	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 9)
	col.add_child(_gap(18))

	# DELTA: "önce" bugün yayınlanmış günlük burn, "sonra" taslağın ima ettiği burn.
	var published: int = int(FinanceSystem.get_burn_breakdown().get("overtime", 0))
	var before: int = GameState.daily_burn
	var after: int = before - published + WorkHoursSystem.daily_overtime_in(_draft)
	var delta := HBoxContainer.new()
	delta.add_theme_constant_override("separation", 10)
	delta.add_child(UiFactory.make_label(tr("HR_HOURS_COST_BURN"), &"RowMeta", UiTokens.INK_MUTED))
	delta.add_child(UiFactory.make_label(HRUiShared.money(before), &"RowMeta", UiTokens.CREAM_DIM))
	delta.add_child(UiFactory.make_label("→", &"RowMeta", UiTokens.INK_DIM))
	delta.add_child(UiFactory.make_label(HRUiShared.money(after), &"MetricValueInk",
		UiTokens.NEGATIVE if after > before else UiTokens.INK))
	col.add_child(delta)

	# OLGU ve KURAL: sıfır olan yarım hiç yazılmaz. Kısa gün kuralı §8.3'ün istediği satırdır:
	# maaş yükü düşmez ve bu modalde açıkça yazılır.
	var facts: Array[String] = []
	var rules := VBoxContainer.new()
	rules.add_theme_constant_override("separation", 3)
	if over > 0:
		facts.append(tr("HR_HOURS_FACT_OVER").format({"n": over}))
		rules.add_child(UiFactory.make_label(tr("HR_HOURS_RULE_OVERTIME"), &"QuoteSerif", UiTokens.INK_MUTED))
	if short_day > 0:
		facts.append(tr("HR_HOURS_FACT_SHORT").format({"n": short_day}))
		rules.add_child(UiFactory.make_label(tr("HR_HOURS_RULE_SHORT"), &"QuoteSerif", UiTokens.INK_MUTED))
	col.add_child(UiFactory.make_label(" · ".join(facts), &"RowMeta", UiTokens.CREAM_DIM))
	col.add_child(rules)
	return col


# --- Alt bar ------------------------------------------------------------------

## Solda sessiz "Tümünü şirkete eşitle" (yalnız istisna varken) · boşluk · "Vazgeç" · amber "Uygula".
func _footer() -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	if WorkHoursSystem.override_count_in(_draft) > 0:
		row.add_child(HRUiShared.action_button(tr("HR_HOURS_EQUALISE"), _on_equalise))
	var pad := Control.new()
	pad.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(pad)
	row.add_child(HRUiShared.action_button(tr("HR_HOURS_CANCEL"), _close))
	row.add_child(HRUiShared.action_button(tr("HR_HOURS_APPLY"), _on_apply, true))
	return row


# --- Taslak yazma (motora dokunmaz) --------------------------------------------
# Stepper'lar sınırda kapalı olduğu için değer hep [MIN, MAX] içinde gelir.

## bucket "company"/"start" düz değerdir; "groups"/"people" key ile adreslenen sözlüktür.
func _set_scope(value: int, bucket: String, key: String = "") -> void:
	if key == "":
		_draft[bucket] = value
	else:
		(_draft[bucket] as Dictionary)[key] = value
	_rebuild()


func _clear_scope(bucket: String, key: String) -> void:
	(_draft[bucket] as Dictionary).erase(key)
	_rebuild()


func _on_equalise() -> void:
	(_draft["groups"] as Dictionary).clear()
	(_draft["people"] as Dictionary).clear()
	_rebuild()


func _on_apply() -> void:
	WorkHoursSystem.apply_state(_draft)
	state_changed.emit()
	_close()


func _unhandled_input(ev: InputEvent) -> void:
	if ev.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_close()


## Vazgeç = kapat: taslak yereldir, geri alınacak motor yazması yok.
func _close() -> void:
	queue_free()
