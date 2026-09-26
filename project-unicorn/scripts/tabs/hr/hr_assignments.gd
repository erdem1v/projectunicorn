class_name HRAssignments
extends RefCounted

# EKİP → GÖREVLER matrisi (10b, §12).
#
# Sütunlar: ÇALIŞAN · DURUM · sonra `HRConstants.JOBS`'un her işi için eşit aralıklı bir sütun.
#
# KURUCU BURADA YOK: atanabilir bir işçi değil, aktif yapımın fazını motor tarafında
# kendiliğinden takip eder (ProductSystem._reseat_founder).
#
# HÜCRE DURUMLARI (§12.3):
#   ana iş + işaretli      → dolu amber, koyu tik
#   ikincil iş + işaretli  → 1px amber kenar, amber yıkama, amber tik
#   atanabilir, işaretsiz  → 1px kenar, koyu dolgu
#   atanamaz               → 1px KESİKLİ kenar, saydam, tıklanamaz, gerekçe tooltip'te
# Stylebox'lar çalışma zamanında kuruluyor: yeni bir theme_type_variation THEME_STAMP
# artırmayı gerektirirdi.

const W_WHO := 430
const W_STATE := 210
const CELL := 22

## `on_toggle(character_id, job_id, currently_on)` — tek yazma kapısı hr_tab'da.
static func build(on_toggle: Callable, on_recruit: Callable = Callable()) -> Control:
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 0)
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col.add_child(_header())
	var roster: Array[Character] = CharacterRegistry.get_employees()
	if roster.is_empty():
		# Boş kadroda matris değil, Kadro'nun boş satırı: iki sayfada tek boşluk grameri.
		col.add_child(HRLedger.empty_row(on_recruit))
		return col
	for emp in roster:
		col.add_child(_row(emp, on_toggle))
	col.add_child(_legend())
	return col


static func _header() -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 0)
	row.custom_minimum_size = Vector2(0, 30)
	row.add_child(_head(tr_key("HR_COL_EMPLOYEE"), W_WHO, HORIZONTAL_ALIGNMENT_LEFT))
	row.add_child(_head(tr_key("HR_COL_STATE"), W_STATE, HORIZONTAL_ALIGNMENT_LEFT))
	var jobs := HBoxContainer.new()
	jobs.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	jobs.alignment = BoxContainer.ALIGNMENT_CENTER
	for job_id in HRConstants.JOBS:
		var cell := _head(HRConstants.job_label(String(job_id)), 0)
		cell.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		jobs.add_child(cell)
	row.add_child(jobs)
	var wrap := PanelContainer.new()
	wrap.theme_type_variation = &"HeaderBand"
	wrap.add_child(row)
	return wrap


static func _row(emp: Character, on_toggle: Callable) -> Control:
	var card := PanelContainer.new()
	card.theme_type_variation = &"LedgerRow"
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 0)
	card.add_child(row)

	# ÇALIŞAN: baş harf + ad + tek satırda "ROL · Ana alan ★★★ · İkincil alan ★"
	var who := HBoxContainer.new()
	who.add_theme_constant_override("separation", UiTokens.SPACE_L)
	who.custom_minimum_size = Vector2(W_WHO, 0)
	who.add_child(UiFactory.make_avatar(UiFactory.initials_of(emp.character_name), 30))
	var stack := VBoxContainer.new()
	stack.add_theme_constant_override("separation", 3)
	stack.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	stack.add_child(UiFactory.make_label(emp.character_name, &"RowName"))
	var meta := HBoxContainer.new()
	meta.add_theme_constant_override("separation", UiTokens.SPACE_S)
	meta.add_child(UiFactory.make_label(
		UiTokens.tr_upper(HRConstants.role_label(emp.role)), &"MicroLabel"))
	# Küçük yıldızlar: amaç matris okunurken kimin nesi olduğunu hatırlatmak.
	meta.add_child(HRUiShared.area_stars_row(emp.role, emp.role_stats, 11))
	stack.add_child(meta)
	who.add_child(stack)
	row.add_child(who)

	# DURUM, Kadro ile aynı sütun (§13.3). Boşta burada değil: boş bir satır zaten boş okunur.
	row.add_child(HRUiShared.status_cell(emp, W_STATE))

	var jobs := HBoxContainer.new()
	jobs.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	for job_id in HRConstants.JOBS:
		var slot := CenterContainer.new()
		slot.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		slot.add_child(_cell(emp, String(job_id), on_toggle))
		jobs.add_child(slot)
	row.add_child(jobs)
	return card


## Kapalı kare hep aynı; gerekçesi değişir (§12.1: iş tavanı ayrı bir durum değil, atanamaz
## karenin bir gerekçesi). Kapıların sırası gerekçenin doğruluğunu belirler.
static func _cell(c: Character, job_id: String, on_toggle: Callable) -> Control:
	var coef: float = HRConstants.job_coefficient(c.role, job_id, c.category)
	var checked: bool = c.assigned_job_ids.has(job_id)

	# Önce ALAN: işi hiç yapamayan birine dünyanın hâlini anlatmak yalan olurdu.
	if coef <= 0.0:
		return _dashed_cell(tr_key("HR_ASSIGN_NOT_YOUR_AREA"))
	# Satış canlı B2B ürün yokken kilitli-görünür (Satış §3.1): gizlemek "böyle bir şey yok"
	# der, kilitli kare "henüz yok, sebebi bu".
	if job_id == HRConstants.JOB_SALES and not ProductSystem.has_b2b_product():
		return _dashed_cell(tr_key("SALES_LOCKED_NO_B2B"))
	# Araştırma sütunu salt okunur (Ar-Ge §5.3): atama düğümün üzerinde yapılır, tek bir kutu
	# yirmi düğümden hangisine diyemez. Tavandan önce: bu sütun tavan ne olursa olsun kapalı.
	if job_id == HRConstants.JOB_RESEARCH:
		return _dashed_cell(tr_key("HR_ASSIGN_RESEARCH_ELSEWHERE"))
	# İş tavanı (§12.1): boş üçüncü hücre kilitli ve görünür kalır.
	if not checked and c.assigned_job_ids.size() >= HRConstants.MAX_JOBS_PER_PERSON:
		return _dashed_cell(tr_key("HR_ASSIGN_JOB_CAP"))

	var box: PanelContainer = _box(checked, coef >= 1.0)
	var btn := Button.new()
	btn.flat = true
	btn.focus_mode = Control.FOCUS_NONE
	btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	btn.set_anchors_preset(Control.PRESET_FULL_RECT)
	btn.custom_minimum_size = Vector2(CELL, CELL)
	for state in ["normal", "hover", "pressed", "focus"]:
		btn.add_theme_stylebox_override(state, StyleBoxEmpty.new())
	btn.pressed.connect(func() -> void: on_toggle.call(c.id, job_id, checked))
	box.add_child(btn)
	return box


## Atanabilir kare: işaretliyse ana/ikincil işe göre amber dolgu ya da amber kenar + tik.
static func _box(checked: bool, primary: bool) -> PanelContainer:
	var box := PanelContainer.new()
	box.custom_minimum_size = Vector2(CELL, CELL)
	var sb := StyleBoxFlat.new()
	sb.set_corner_radius_all(UiTokens.RADIUS_S)
	if checked and primary:
		sb.bg_color = UiTokens.ACCENT
	else:
		sb.bg_color = UiTokens.AMBER_WASH if checked else UiTokens.SURFACE_FRAME
		sb.set_border_width_all(UiTokens.BORDER_HAIRLINE)
		sb.border_color = UiTokens.ACCENT if checked else UiTokens.BORDER_HOVER
	box.add_theme_stylebox_override("panel", sb)
	if checked:
		var tick := UiFactory.make_label("✓", &"BadgeLabel",
			UiTokens.ON_ACCENT if primary else UiTokens.ACCENT)
		tick.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		tick.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		box.add_child(tick)
	return box


## Atanamaz — gerçekten kesikli kare. StyleBoxFlat kesikli kenar çizemiyor ve soluk düz kenar
## ekranda atanabilir-işaretsiz kareden ayırt edilemiyordu; dört kenar elle çiziliyor.
static func _dashed_cell(reason: String) -> Control:
	var box := Control.new()
	box.custom_minimum_size = Vector2(CELL, CELL)
	box.tooltip_text = reason
	box.mouse_filter = Control.MOUSE_FILTER_STOP
	box.draw.connect(func() -> void:
		var c: Color = UiTokens.BORDER_DASHED
		var dash: float = 3.0
		var gap: float = 2.5
		var w: float = box.size.x
		var h: float = box.size.y
		var x: float = 0.0
		while x < w:
			var seg: float = minf(dash, w - x)
			box.draw_line(Vector2(x, 0.5), Vector2(x + seg, 0.5), c, 1.0)
			box.draw_line(Vector2(x, h - 0.5), Vector2(x + seg, h - 0.5), c, 1.0)
			x += dash + gap
		var y: float = 0.0
		while y < h:
			var seg2: float = minf(dash, h - y)
			box.draw_line(Vector2(0.5, y), Vector2(0.5, y + seg2), c, 1.0)
			box.draw_line(Vector2(w - 0.5, y), Vector2(w - 0.5, y + seg2), c, 1.0)
			y += dash + gap)
	return box


## ANA · İKİNCİL · ALANI YOK — matrisin altındaki üç örnek kare.
static func _legend() -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", UiTokens.SPACE_3XL)
	for spec in [
			["HR_LEGEND_PRIMARY", _box(true, true)],
			["HR_LEGEND_SECONDARY", _box(true, false)],
			["HR_LEGEND_NO_AREA", _dashed_cell(tr_key("HR_ASSIGN_NOT_YOUR_AREA"))]]:
		var item := HBoxContainer.new()
		item.add_theme_constant_override("separation", UiTokens.SPACE_M)
		item.add_child(spec[1])
		item.add_child(UiFactory.make_label(
			tr_key(String(spec[0])), &"ColumnHeader", UiTokens.INK_DIM))
		row.add_child(item)
	var pad := MarginContainer.new()
	pad.add_theme_constant_override("margin_top", 14)
	pad.add_child(row)
	return pad


static func _head(text: String, width: int, align: int = HORIZONTAL_ALIGNMENT_CENTER) -> Label:
	var l := UiFactory.make_label(text, &"ColumnHeader")
	l.horizontal_alignment = align
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	if width > 0:
		l.custom_minimum_size = Vector2(width, 0)
	return l


## `static func` içindeki tr() çalışırken ölür; çeviri TranslationServer'dan.
static func tr_key(key: String) -> String:
	return TranslationServer.translate(key)
