extends "res://scripts/tabs/hr/hr_panel.gd"

# ÇALIŞMA SAATLERİ — §8.5, onaylı 19a–19d.
#
# Üstte ofis günü bandı: 08:00'den 00:00'a tek eksen, şirket penceresi dolu, sekiz saati aşan saatler
# taralı. Altında sütunlar KAPSAM · BAŞLANGIÇ · SÜRE · DURUM · KAYNAK · MORAL. BAŞLANGIÇ yalnız Şirket
# satırında doludur (§8.1). Geri dönüş eylemi KAYNAK hücresinin içindedir: devralan satır nereden
# aldığını yazar, karar veren satır geri-ok çipi taşır. Kurucu listede görünmez (§2, §8.1).
#
# TAAHHÜTLÜ PANEL. Düzenlemeler `_draft`'a yazılır; `Uygula` WorkHoursSystem.apply_state'i
# çağırır, `Vazgeç` taslağı atar ("maliyet taahhütten ÖNCE okunur", §8.5). Taslak da canlı durum
# da WorkHoursSystem'in aynı çözümleyicisinden geçer (§15.2), önizleme ile tahakkuk ayrışamaz.
# Taslak yalnız panelde: üst bar, Kadro'nun çipi ve satırları uygulanmış günü gösterir.
#
# MORAL sütunu kişinin moralini ve saatin moral YÖNÜNÜ (kademeli şevron) taşır. Katsayı yok
# (§8.5); kademenin cümlesi glifin tooltip'inde.
#
# Kadro tamamen boşken DURUM ve MORAL başlıkları çizilmez (sahip hükmü).
#
# PanelLayer'da yaşar, ModalLayer'da değil: ModalLayer hız tuşlarını yutuyor.

const WIDTH := 1000
## KAPSAM esner, kalan beşi sabit.
const W_START := 196
const W_HOURS := 136
const W_STATE := 100
const W_SOURCE := 140
const W_MORALE := 124
const H_COMPANY := 56
const INDENT_GROUP := 16
const INDENT_PERSON := 32
const STEP_KEY := 28
const STEP_VALUE_W := 64
const BAND_H := 56
const BAND_KEY_W := 76
const BAND_TRACK := Vector2i(18, 8)   # the band's track: its top and its height
## MORAL sütunu çubuk ve sayının yanında üç şevrondan fazlasını taşımaz.
const CHEVRON_MAX := 3
## HR_HOURS_HOVER_<saat> cümleleri bu saate kadar yazılı; daha uzun günler HR_HOURS_HOVER_LONG'u paylaşır.
const HOVER_KEYED_MAX := 11

var _draft: Dictionary = {}


## Ev sahibi ÖNCE add_child eder, SONRA burayı çağırır. Taslak açılışta bir kez alınır;
## motora yalnız `Uygula` dokunur.
func populate() -> void:
	title.add_child(UiFactory.make_label(tr("HR_HOURS_TITLE"), &"TitleH2"))
	_draft = WorkHoursSystem.draft_state()
	_rebuild()


func _rebuild() -> void:
	clear()
	var roster: Array[Character] = CharacterRegistry.get_employees()
	body.add_child(_day_band(roster))
	body.add_child(_column_head(roster.is_empty()))
	body.add_child(_company_row(roster.size()))
	if SprintSystem.is_typed():
		body.add_child(_sprint_row())
	for group_id: String in HRConstants.ROSTER_GROUPS:
		# Boş grup da satırını taşır: grup istisnası o gruba SONRADAN katılanı da kapsar (§8.1).
		body.add_child(_group_row(group_id))
		for emp in roster:
			if String(HRConstants.ROLE_GROUP.get(emp.role, "")) == group_id:
				body.add_child(_person_row(emp))
	var cost: Control = _cost_block()
	if cost != null:
		body.add_child(cost)
	_footer()
	seat(WIDTH)


# --- Ofis günü bandı ----------------------------------------------------------

## The office day on one axis from the week's start to the latest end: the company's window filled up
## to eight hours, the hours past it hatched in the warning tone, the window's ends written above it and
## the axis hours under it (each hour once).
func _day_band(roster: Array[Character]) -> HBoxContainer:
	var start: int = int(_draft["start"])
	var longest: int = WorkHoursSystem.hours_in(_draft, null)
	for group_id: String in HRConstants.ROSTER_GROUPS:
		longest = maxi(longest, WorkHoursSystem.group_hours_in(_draft, group_id))
	for emp in roster:
		longest = maxi(longest, WorkHoursSystem.hours_in(_draft, emp))
	var end: int = start + longest
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 0)
	row.custom_minimum_size.y = BAND_H
	var key := UiFactory.make_label(Fmt.upper(tr("HR_HOURS_DAY_BAND")), &"KeyLabel")
	key.custom_minimum_size.x = BAND_KEY_W
	key.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(key)
	var band := Control.new()
	band.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	band.draw.connect(_draw_band.bind(band, start, end))
	row.add_child(band)
	return row


func _draw_band(band: Control, start: int, end: int) -> void:
	var lo: int = TimeModel.WEEK_START_HOUR
	var hi: int = TimeModel.WORKDAY_LATEST_END
	var x_of := func(hour: float) -> float: return band.size.x * (hour - lo) / float(hi - lo)
	var font: Font = band.get_theme_font(&"font", &"SmallMuted")
	var px: int = band.get_theme_font_size(&"font_size", &"SmallMuted")
	var track_y: float = BAND_TRACK.x
	var bar_h: float = BAND_TRACK.y
	band.draw_rect(Rect2(0, track_y, band.size.x, bar_h), UiTokens.D_BAR_TRACK)
	var plain_end: int = mini(end, start + HRConstants.WORK_HOURS_DEFAULT)
	band.draw_rect(Rect2(x_of.call(start), track_y, x_of.call(plain_end) - x_of.call(start), bar_h), UiTokens.D_INK_3)
	if end > plain_end:
		var x0: float = x_of.call(plain_end)
		var x1: float = x_of.call(end)
		var warn: Color = UiTokens.D_warn()
		band.draw_rect(Rect2(x0, track_y, x1 - x0, bar_h), UiTokens.D_badge_palette(&"accent").bg)
		var x: float = x0 - bar_h
		while x < x1:
			var a := Vector2(maxf(x, x0), track_y + bar_h - (maxf(x, x0) - x))
			var b := Vector2(minf(x + bar_h, x1), track_y + bar_h - (minf(x + bar_h, x1) - x))
			band.draw_line(a, b, warn, UiTokens.BORDER_FOCUS)
			x += UiTokens.SPACE_S
	var tick_y: float = track_y + bar_h + UiTokens.SPACE_XS
	for hour in range(lo, hi + 1):
		var big: bool = (hour - lo) % 4 == 0
		var x: float = x_of.call(hour)
		band.draw_line(Vector2(x, tick_y), Vector2(x, tick_y + (UiTokens.SPACE_M if big else UiTokens.SPACE_XS)),
			UiTokens.D_INK_4 if big else UiTokens.D_LINE_2, UiTokens.BORDER_HAIRLINE)
		if big and hour != start and hour != end:
			_hour_label(band, font, px, hour, x, tick_y + UiTokens.SPACE_M + font.get_ascent(px), UiTokens.D_INK_3)
	for hour in [start, end]:
		_hour_label(band, font, px, hour, x_of.call(hour), track_y - UiTokens.SPACE_XS, UiTokens.D_INK_2)


func _hour_label(band: Control, font: Font, px: int, hour: int, x: float, baseline: float, ink: Color) -> void:
	var text: String = "%02d:00" % (hour % TimeModel.HOURS_PER_DAY)
	var w: float = font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, px).x
	band.draw_string(font, Vector2(clampf(x - w / 2.0, 0.0, band.size.x - w), baseline), text,
		HORIZONTAL_ALIGNMENT_LEFT, -1, px, ink)


# --- Tablo --------------------------------------------------------------------

## A row: its scope cell (indented), then the five fixed columns. `look` is the band's variation.
func _row(height: int, indent: int, look: StringName, cells: Array) -> PanelContainer:
	var line := PanelContainer.new()
	line.theme_type_variation = look
	line.custom_minimum_size.y = height
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 0)
	line.add_child(row)
	var scope := MarginContainer.new()
	scope.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scope.add_theme_constant_override("margin_left", indent)
	scope.add_child(cells[0])
	row.add_child(scope)
	for i in range(1, cells.size()):
		var cell: Control = cells[i]
		cell.custom_minimum_size.x = [W_START, W_HOURS, W_STATE, W_SOURCE, W_MORALE][i - 1]
		row.add_child(cell)
	for part: Control in row.get_children():
		part.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	return line


## Kadro tamamen boşken DURUM ve MORAL başlıkları çizilmez; doluyken DURUM o an boş olsa da
## başlık durur, yoksa ilk istisnada tablo yeniden akardı.
func _column_head(roster_empty: bool) -> PanelContainer:
	var head := _row(UiTokens.D_H_HEAD, UiTokens.SPACE_L, &"TableHead", [
		HRUiShared.D_head(tr("HR_HOURS_COL_SCOPE"), 0, HORIZONTAL_ALIGNMENT_LEFT),
		HRUiShared.D_head(tr("HR_HOURS_COL_START"), 0, HORIZONTAL_ALIGNMENT_LEFT),
		HRUiShared.D_head(tr("HR_HOURS_COL_HOURS"), 0),
		HRUiShared.D_head("" if roster_empty else tr("HR_HOURS_COL_STATE"), 0, HORIZONTAL_ALIGNMENT_LEFT),
		HRUiShared.D_head(tr("HR_HOURS_COL_SOURCE"), 0, HORIZONTAL_ALIGNMENT_LEFT),
		HRUiShared.D_head("" if roster_empty else tr("HR_COL_MORALE"), 0, HORIZONTAL_ALIGNMENT_RIGHT),
	])
	for part: Control in head.get_child(0).get_children():
		part.size_flags_vertical = Control.SIZE_FILL
	return head


func _company_row(headcount: int) -> PanelContainer:
	var hours: int = WorkHoursSystem.hours_in(_draft, null)
	var start: int = int(_draft["start"])
	# BAŞLANGIÇ yalnız şirket kapsamında (§8.1): "Ofis tek saatte açılır; değişen, kimin ne
	# zaman çıktığıdır." Yanında bitiş saati.
	var start_cell := HBoxContainer.new()
	start_cell.add_theme_constant_override("separation", UiTokens.SPACE_M)
	var set_start: Callable = _set_scope.bind("start")
	start_cell.add_child(_stepper("%02d:00" % start, start > HRConstants.START_HOUR_MIN,
		start < HRConstants.START_HOUR_MAX, set_start.bind(start - 1), set_start.bind(start + 1), null, false))
	start_cell.add_child(UiFactory.make_label("→ %s" % String(WorkHoursSystem.company_window(hours, start)["end_text"]),
		&"MetaMuted"))
	for part: Control in start_cell.get_children():
		part.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	# Şirketin üstünde devralacağı kapsam yok, dönülecek yer de yok: kaynak "temel".
	return _row(H_COMPANY, UiTokens.SPACE_L, &"TableRowSelected", [
		_names(tr("HR_HOURS_SCOPE_COMPANY"), tr("HR_HOURS_COMPANY_SUB").format({"n": headcount}), false),
		start_cell,
		_hours_cell(hours, false, false, _set_scope.bind("company")),
		_state_cell(hours),
		_source_text(tr("HR_HOURS_SOURCE_BASE")),
		Control.new(),
	])


## Saatin sprinte etkisi, kurucu tek başınayken de (bedel bloğu o zaman hiç açılmaz): ekibin haftalık
## puanı önce bugünkü saatlerle, sonra taslakla; ekranda aynı okunan iki değer tek sayı yazılır. Şirket
## mesaideyse yarım verim kuralı altında.
func _sprint_row() -> PanelContainer:
	# Fmt.number tam sayıya da ondalık yazar ("2,0"); tam puan "2" okunur.
	var zero: String = tr("NUM_DECIMAL_SEP") + "0"
	var before: String = Fmt.number(SprintSystem.week_points(), 1).trim_suffix(zero)
	var after: String = Fmt.number(SprintSystem.week_points(_draft), 1).trim_suffix(zero)
	var points: String = tr("HR_HOURS_SPRINT_POINTS_NOW").format({"n": before}) if before == after \
		else tr("HR_HOURS_SPRINT_POINTS").format({"before": before, "after": after})
	var lines := VBoxContainer.new()
	lines.add_theme_constant_override("separation", 0)
	lines.add_child(UiFactory.make_label(points, &"DataText"))
	var overtime: bool = HRConstants.is_overtime_hours(WorkHoursSystem.hours_in(_draft, null))
	if overtime:
		lines.add_child(UiFactory.make_label(tr("HR_HOURS_RULE_OVERTIME_OUTPUT"), &"MetaMuted"))
	# İki satır, şirket satırının iki satırlı yüksekliğini alır.
	return _row(H_COMPANY if overtime else UiTokens.D_H_ROW, UiTokens.SPACE_L, &"TableRow", [lines])


func _group_row(group_id: String) -> PanelContainer:
	var owns: bool = WorkHoursSystem.group_has_override_in(_draft, group_id)
	var hours: int = WorkHoursSystem.group_hours_in(_draft, group_id)
	return _row(UiTokens.D_H_ROW, INDENT_GROUP, &"TableRow", [
		UiFactory.make_label(Fmt.upper(HRConstants.group_label(group_id)), &"GroupLabel"),
		Control.new(),
		_hours_cell(hours, not owns, false, _set_scope.bind("groups", group_id)),
		_state_cell(hours),
		_source_cell(owns, tr("HR_HOURS_SOURCE_FROM_COMPANY"), _clear_scope.bind("groups", group_id)),
		Control.new(),
	])


func _person_row(emp: Character) -> PanelContainer:
	var owns: bool = WorkHoursSystem.person_has_override_in(_draft, emp)
	var hours: int = WorkHoursSystem.hours_in(_draft, emp)
	var away: bool = emp.status == HRConstants.STATUS_ON_LEAVE
	# `inherited_from_in` KAPSAM SÖZCÜĞÜ döner ("group"/"company"), grup id'si değil.
	var from_key: String = "HR_HOURS_SOURCE_FROM_GROUP" \
		if WorkHoursSystem.inherited_from_in(_draft, emp) == "group" \
		else "HR_HOURS_SOURCE_FROM_COMPANY"
	# İzindeki kişi mesaide sayılmaz: Durum'u İzinde, moralinin yönü yok.
	return _row(UiTokens.D_H_ROW, INDENT_PERSON, &"TableRow", [
		_names(emp.character_name, HRConstants.job_title(emp.role, emp.level), away),
		Control.new(),
		_hours_cell(hours, not owns, HRConstants.is_short_day_hours(hours), _set_scope.bind("people", emp.id)),
		_leave_tag() if away else _state_cell(hours),
		_source_cell(owns, tr(from_key), _clear_scope.bind("people", emp.id)),
		_morale_cell(emp, hours, away),
	])


func _leave_tag() -> HBoxContainer:
	var cell := HBoxContainer.new()
	cell.add_child(UiFactory.D_tag(tr("HR_STATE_ON_LEAVE"), &"neutral"))
	return cell


func _names(top: String, sub: String, away: bool) -> VBoxContainer:
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 0)
	col.add_child(UiFactory.make_label(top, &"DataMedium" if away else &"DataStrong", UiTokens.D_INK_3 if away else null))
	col.add_child(UiFactory.make_label(sub, &"CondCaption"))
	return col


# --- Hücreler -----------------------------------------------------------------

## SÜRE hücresi. Devralan değer kesikli çerçevede ve soluk; kendi kararı mesaideyse uyarı, kısa günse
## olumlu renkte. Stepper her satırda çizilir: devralan satırda basmak o satıra bir istisna YAZAR.
func _hours_cell(hours: int, inherited: bool, short_day: bool, on_set: Callable) -> CenterContainer:
	var ink: Variant = null
	if not inherited and HRConstants.is_overtime_hours(hours):
		ink = UiTokens.D_warn()
	elif not inherited and short_day:
		ink = UiTokens.D_pos()
	var cell := CenterContainer.new()
	cell.add_child(_stepper(tr("HR_HOURS_VALUE").format({"n": hours}),
		hours > HRConstants.WORK_HOURS_MIN, hours < WorkHoursSystem.max_hours(int(_draft["start"])),
		on_set.bind(hours - 1), on_set.bind(hours + 1), ink, inherited))
	return cell


## Minus, value and plus between rules. Its own value sits in the stepper's box; an inherited one in a
## dashed frame, quieter.
func _stepper(text: String, can_down: bool, can_up: bool, on_down: Callable, on_up: Callable,
		ink: Variant, inherited: bool) -> Control:
	var keys := HBoxContainer.new()
	keys.add_theme_constant_override("separation", 0)
	keys.add_child(_step_key("util/minus", can_down, on_down))
	keys.add_child(_rule())
	var value := UiFactory.make_label(text, &"DataText" if inherited else &"DataStrong",
		UiTokens.D_INK_3 if inherited else ink)
	value.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	value.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	value.custom_minimum_size = Vector2(STEP_VALUE_W, STEP_KEY)
	keys.add_child(value)
	keys.add_child(_rule())
	keys.add_child(_step_key("util/plus", can_up, on_up))
	if inherited:
		HRUiShared.D_dashed(keys)
		return keys
	var box := PanelContainer.new()
	box.theme_type_variation = &"StepperBox"
	box.add_child(keys)
	return box


func _step_key(glyph: String, enabled: bool, on_press: Callable) -> Button:
	var key := Button.new()
	key.theme_type_variation = &"StepKey"
	key.icon = load("res://assets/icons/%s.svg" % glyph)
	key.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	key.custom_minimum_size = Vector2(STEP_KEY, STEP_KEY)
	key.focus_mode = Control.FOCUS_NONE
	key.disabled = not enabled
	if enabled:
		key.pressed.connect(on_press)
	return key


func _rule() -> ColorRect:
	var rule := ColorRect.new()
	rule.color = UiTokens.D_LINE_1
	rule.custom_minimum_size.x = UiTokens.BORDER_HAIRLINE
	return rule


## §8.5 DURUM DİLİ: 8 saat süslemesiz · üstü "+Ns mesai" uyarı tonunda · altı "−Ns kısa" olumlu.
func _state_cell(hours: int) -> Control:
	var delta: int = hours - HRConstants.WORK_HOURS_DEFAULT
	if delta == 0:
		return Control.new()
	return UiFactory.make_label(tr("HR_STATE_HOURS_OVER" if delta > 0 else "HR_STATE_HOURS_SHORT").format(
		{"n": absi(delta)}), &"MetaMuted", UiTokens.D_warn() if delta > 0 else UiTokens.D_pos())


## KAYNAK: devralan satır nereden aldığını yazar; karar veren satır geri-ok çipiyle "şirkete dön"
## taşır.
func _source_cell(owns: bool, from_text: String, on_revert: Callable) -> Control:
	if not owns:
		return _source_text(from_text)
	var chip := Button.new()
	chip.theme_type_variation = &"ChipSmall"
	chip.text = tr("HR_HOURS_BACK_TO_COMPANY")
	chip.icon = load("res://assets/icons/util/revert.svg")
	chip.focus_mode = Control.FOCUS_NONE
	chip.pressed.connect(on_revert)
	var cell := HBoxContainer.new()
	cell.add_child(chip)
	return cell


func _source_text(text: String) -> Label:
	return UiFactory.make_label(text, &"CaptionFaint")


## MORAL: yön göstergesi, küçük moral çubuğu ve sayı. İzindekinde yön yok.
func _morale_cell(emp: Character, hours: int, away: bool) -> HBoxContainer:
	var cell := HBoxContainer.new()
	cell.add_theme_constant_override("separation", UiTokens.SPACE_M)
	cell.alignment = BoxContainer.ALIGNMENT_END
	if not away:
		var dir: Control = _morale_direction(hours)
		if dir != null:
			cell.add_child(dir)
	var ink: Color = HRUiShared.D_morale_ink(emp.morale)
	cell.add_child(HRUiShared.D_bar(UiTokens.D_MORALE_BAR_SM, emp.morale / float(HRConstants.MORALE_MAX), ink))
	var value := UiFactory.make_label(str(emp.morale), &"MoraleValue", ink)
	cell.add_child(value)
	for part: Control in cell.get_children():
		part.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	return cell


## Kademeli şevron: 9s bir · 10s iki · 11s ve üstü üç aşağı, uyarı tonunda · 7s düz çizgi · 5-6s
## yukarı, olumlu · 8s hiç. Kademenin cümlesi tooltip'te.
func _morale_direction(hours: int) -> Control:
	var delta: int = hours - HRConstants.WORK_HOURS_DEFAULT
	if delta == 0:
		return null
	var box := HBoxContainer.new()
	box.add_theme_constant_override("separation", -UiTokens.SPACE_XS)
	box.tooltip_text = tr("HR_HOURS_HOVER_LONG" if hours > HOVER_KEYED_MAX else "HR_HOURS_HOVER_%d" % hours)
	box.mouse_filter = Control.MOUSE_FILTER_STOP
	var glyph: String = "util/chevron_down" if delta > 0 else ("util/flat" if delta == -1 else "util/chevron_up")
	for _i in (mini(delta, CHEVRON_MAX) if delta > 0 else 1):
		box.add_child(UiFactory.make_glyph("res://assets/icons/%s.svg" % glyph, UiTokens.D_ICON_MARK,
			UiTokens.D_warn() if delta > 0 else UiTokens.D_pos()))
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
	col.add_theme_constant_override("separation", UiTokens.SPACE_M)
	var gap := Control.new()
	gap.custom_minimum_size.y = UiTokens.SPACE_XL
	col.add_child(gap)
	# DELTA: "önce" TopBar'ın canlı aylık burn'ü, "sonra" taslağın ima ettiği aylık burn. Mesai
	# tahakkuku günlük orandır ve aya TopBar'ınkiyle aynı çarpanla (DAYS_PER_MONTH) çevrilir.
	# Bir bedeldir, tehlike değil: mürekkeple, bedel diskiyle.
	var published: int = int(FinanceSystem.get_burn_breakdown().get("overtime", 0))
	var before: int = int(FinanceSystem.get_monthly_flow()["expense"])
	var after: int = before + (WorkHoursSystem.daily_overtime_in(_draft) - published) * TimeModel.DAYS_PER_MONTH
	var burn := HBoxContainer.new()
	burn.add_theme_constant_override("separation", UiTokens.SPACE_M)
	burn.add_child(UiFactory.make_glyph("res://assets/icons/stake/cost.svg", UiTokens.D_ICON_ROW, UiTokens.D_INK_3))
	burn.add_child(UiFactory.make_label(tr("HR_HOURS_COST_BURN"), &"DataText", UiTokens.D_INK_3))
	burn.add_child(UiFactory.make_label(Fmt.money_exact(before), &"DataText", UiTokens.D_INK_3))
	burn.add_child(UiFactory.make_label("→", &"CaptionFaint"))
	burn.add_child(UiFactory.make_label(Fmt.money_exact(after), &"ValueTextStrong"))
	for part: Control in burn.get_children():
		part.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	col.add_child(burn)
	# OLGU ve KURAL: sıfır olan yarım hiç yazılmaz. Kısa gün kuralı §8.3'ün istediği satırdır:
	# maaş yükü düşmez ve bu panelde açıkça yazılır.
	var facts: Array[String] = []
	var rules: Array[String] = []
	if over > 0:
		facts.append(tr("HR_HOURS_FACT_OVER").format({"n": over}))
		rules.append(tr("HR_HOURS_RULE_OVERTIME"))
	if short_day > 0:
		facts.append(tr("HR_HOURS_FACT_SHORT").format({"n": short_day}))
		rules.append(tr("HR_HOURS_RULE_SHORT"))
	col.add_child(UiFactory.make_label(" · ".join(facts), &"MetaMuted"))
	for rule in rules:
		var line := HBoxContainer.new()
		line.add_theme_constant_override("separation", UiTokens.SPACE_M)
		line.add_child(UiFactory.make_glyph("res://assets/icons/util/info.svg", UiTokens.D_ICON_PART, UiTokens.D_INK_4))
		line.add_child(UiFactory.make_label(rule, &"MetaMuted"))
		col.add_child(line)
	return col


# --- Alt bar ------------------------------------------------------------------

## Solda "Tümünü şirkete eşitle" (yalnız istisna varken) · boşluk · "Vazgeç" · amber "Uygula".
func _footer() -> void:
	if WorkHoursSystem.override_count_in(_draft) > 0:
		var equalise := button(tr("HR_HOURS_EQUALISE"), &"GhostButton", _on_equalise)
		equalise.icon = load("res://assets/icons/util/revert.svg")
		foot.add_child(equalise)
	foot.add_child(spring())
	foot.add_child(button(tr("UI_DISMISS"), &"", close))
	foot.add_child(button(tr("HR_HOURS_APPLY"), &"PrimaryButtonDark", _on_apply))


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
	close()
