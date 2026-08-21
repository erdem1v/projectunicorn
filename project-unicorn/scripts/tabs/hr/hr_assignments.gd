class_name HRAssignments
extends RefCounted

# EKİP → GÖREVLER matrisi — onaylı tasarım 10b.
#
# Sütunlar: ÇALIŞAN 430 · DURUM 210 · sonra YEDİ ATAMA SÜTUNU eşit aralıklı:
#   Ürün · Tasarım · Yazılım · Test · Satış · Müşteri İlişkileri · Araştırma
# Build/Destek/Hesap/Maliyet YOK — tasarım onları adıyla emekli etti ve motor
# 2026-08-22'de atama birimini işten ALANA taşıdı (HRConstants.ASSIGNABLE).
#
# KURUCU BANDI en üstte (10b): yıldızsız satır, yalnız işaretlenebilir kutular, yedi alan
# da onun. Kurucu KADRO listesinde YOKTUR ve ÇALIŞAN sayısına girmez — o sayı maaş
# bordrosunun sayısı, kurucu maaş almıyor.
#
# HÜCRENİN DÖRT DURUMU, tasarımdan birebir:
#   ana alan + işaretli    → dolu amber, koyu tik
#   ikincil alan + işaretli→ 1px amber kenar, amber yıkama, amber tik
#   atanabilir, işaretsiz  → 1px #2A343D kenar, koyu dolgu
#   alanı yok              → 1px KESİKLİ kenar, saydam, tıklanamaz
# Hepsi çalışma zamanında kuruluyor (UiFactory.make_state_chip precedent'i): yeni bir
# theme_type_variation eklemek THEME_STAMP artırmayı gerektirirdi, bu ekran gerektirmiyor.

const W_WHO := 430
const W_STATE := 210
const CELL := 22

## `on_toggle(character_id, area_id, currently_on)` — TEK yazma kapısı hr_tab'da.
## KURUCU BURADA YOK (R1, 2026-08-21). Ne satır, ne kutu, ne salt-okunur bant, ne de
## "nereye gitti" diye açıklayan bir not. Kurucu bir atanabilir işçi DEĞİL: aktif
## yapımın fazını motor tarafında kendiliğinden takip eder (ProductSystem._reseat_founder)
## ve oyuncunun onu taşıyacağı bir kapı yok.
static func build(on_toggle: Callable, on_recruit: Callable = Callable()) -> Control:
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 0)
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col.add_child(_header())
	var roster: Array[Character] = CharacterRegistry.get_employees()
	if roster.is_empty():
		# SİZE MATRİS DEĞİL BİR CÜMLE (C2). Kurucu çıktığı için taze bir koşuda bu sayfa
		# GERÇEKTEN boş; Kadro'nun zaten onaylı olan boş satırı yeniden çizilmiyor,
		# OLDUĞU GİBİ kullanılıyor — iki sayfada iki farklı boşluk grameri olmasın.
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
	var areas := HBoxContainer.new()
	areas.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	areas.alignment = BoxContainer.ALIGNMENT_CENTER
	for area_id in HRConstants.ASSIGNABLE:
		var cell := _head(HRConstants.area_label(String(area_id)), 0)
		cell.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		areas.add_child(cell)
	row.add_child(areas)
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
	# Yıldızlar burada küçük: KADRO sekmesi tam boy gösteriyor, bu satırda amaç
	# hatırlatmak (10b: "ad sütunu genişledi, alt satırdan yıldız tekrarı çıktı" —
	# tekrar çıktı, ama rolün iki alanı kaldı ki matris okunurken kimin nesi olduğu bilinsin).
	meta.add_child(HRUiShared.area_stars_row(emp.role, emp.role_stats, 11))
	stack.add_child(meta)
	who.add_child(stack)
	row.add_child(who)

	row.add_child(_state_cell(emp))
	row.add_child(_cells(emp, on_toggle))
	return card


## DURUM: AŞIRI YÜK / BOŞTA / Eğitimde · N gün — hover açıklamalarıyla (9f).
static func _state_cell(emp: Character) -> Control:
	var box := HBoxContainer.new()
	box.custom_minimum_size = Vector2(W_STATE, 0)
	box.add_theme_constant_override("separation", 6)
	box.alignment = BoxContainer.ALIGNMENT_BEGIN
	# ROZET CİPTİR, SÜTUN DEĞİL: kutu çocukları dikeyde FILL doğuyor, yani cip satırın
	# tüm yüksekliğine geriliyor ve çerçevesi bir hücre gibi okunuyordu (10b'de rozet
	# metnine yapışık). SHRINK_CENTER kutuyu kendi asgari yüksekliğine indiriyor.
	box.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	if emp.training_days_left > 0:
		box.add_child(UiFactory.make_state_chip(
			TranslationServer.translate("HR_STATE_TRAINING").format(
				{"days": emp.training_days_left}),
			UiTokens.ACCENT, UiTokens.AMBER_BG, UiTokens.ACCENT))
		return box
	if HRSystem.is_overloaded(emp):
		var over: Control = UiFactory.make_state_chip(tr_key("HR_BADGE_OVERLOADED_JOBS"),
			UiTokens.ACCENT, UiTokens.AMBER_BG, UiTokens.ACCENT)
		over.tooltip_text = tr_key("HR_OVERLOAD_HINT")
		over.mouse_filter = Control.MOUSE_FILTER_STOP
		box.add_child(over)
		return box
	if HRSystem.is_idle(emp):
		var idle: Control = UiFactory.make_state_chip(tr_key("HR_BADGE_IDLE"),
			UiTokens.INK_DIM, Color(0, 0, 0, 0), UiTokens.SEPARATOR)
		idle.tooltip_text = tr_key("HR_IDLE_HINT")
		idle.mouse_filter = Control.MOUSE_FILTER_STOP
		box.add_child(idle)
	return box


static func _cells(c: Character, on_toggle: Callable) -> Control:
	var areas := HBoxContainer.new()
	areas.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	for area_id in HRConstants.ASSIGNABLE:
		var slot := CenterContainer.new()
		slot.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		slot.add_child(_cell(c, String(area_id), on_toggle))
		areas.add_child(slot)
	return areas


static func _cell(c: Character, area_id: String, on_toggle: Callable) -> Control:
	var eligible: bool = HRConstants.can_hold_area(c.role, area_id, c.category)
	var checked: bool = c.assigned_jobs.has(area_id)
	var primary: bool = area_id == HRConstants.role_key_area(c.role)

	if not eligible:
		return _dashed_cell()

	var box := PanelContainer.new()
	box.custom_minimum_size = Vector2(CELL, CELL)
	var sb := StyleBoxFlat.new()
	sb.set_corner_radius_all(UiTokens.RADIUS_S)

	if checked and primary:
		sb.bg_color = UiTokens.ACCENT
	elif checked:
		sb.bg_color = UiTokens.AMBER_WASH
		sb.set_border_width_all(UiTokens.BORDER_HAIRLINE)
		sb.border_color = UiTokens.ACCENT
	else:
		sb.bg_color = UiTokens.SURFACE_FRAME
		sb.set_border_width_all(UiTokens.BORDER_HAIRLINE)
		sb.border_color = UiTokens.BORDER_HOVER
	box.add_theme_stylebox_override("panel", sb)

	if checked:
		var tick := UiFactory.make_label("✓", &"BadgeLabel",
			UiTokens.ON_ACCENT if primary else UiTokens.ACCENT)
		tick.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		tick.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		box.add_child(tick)

	var btn := Button.new()
	btn.flat = true
	btn.focus_mode = Control.FOCUS_NONE
	btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	btn.set_anchors_preset(Control.PRESET_FULL_RECT)
	btn.custom_minimum_size = Vector2(CELL, CELL)
	for state in ["normal", "hover", "pressed", "focus"]:
		btn.add_theme_stylebox_override(state, StyleBoxEmpty.new())
	btn.pressed.connect(func() -> void: on_toggle.call(c.id, area_id, checked))
	box.add_child(btn)
	return box


## ALANI YOK · ATANAMAZ — GERÇEKTEN kesikli kare. StyleBoxFlat kesikli kenar çizemiyor ve
## "biraz daha soluk düz kenar" ölçüldüğünde işe yaramadı: ekranda atanabilir-işaretsiz
## kareyle ayırt edilemiyordu, yani oyuncu nereye tıklayabileceğini göremiyordu. Dört kenarı
## elle çiziyoruz — tasarımın kapalı karesi bu, ve tıklamayı da almıyor.
static func _dashed_cell() -> Control:
	var box := Control.new()
	box.custom_minimum_size = Vector2(CELL, CELL)
	box.tooltip_text = tr_key("HR_ASSIGN_NOT_YOUR_AREA")
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


## ANA ALAN · İKİNCİL ALAN · ALANI YOK · ATANAMAZ — matrisin altındaki üç örnek kare.
static func _legend() -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", UiTokens.SPACE_3XL)
	row.add_theme_constant_override("margin_top", UiTokens.SPACE_L)
	for spec in [
			{"key": "HR_LEGEND_PRIMARY", "state": "primary"},
			{"key": "HR_LEGEND_SECONDARY", "state": "secondary"},
			{"key": "HR_LEGEND_NO_AREA", "state": "none"}]:
		var item := HBoxContainer.new()
		item.add_theme_constant_override("separation", UiTokens.SPACE_M)
		item.add_child(_legend_swatch(String(spec["state"])))
		item.add_child(UiFactory.make_label(
			tr_key(String(spec["key"])), &"ColumnHeader", UiTokens.INK_DIM))
		row.add_child(item)
	var pad := MarginContainer.new()
	pad.add_theme_constant_override("margin_top", 14)
	pad.add_child(row)
	return pad


static func _legend_swatch(state: String) -> Control:
	var box := PanelContainer.new()
	box.custom_minimum_size = Vector2(CELL, CELL)
	var sb := StyleBoxFlat.new()
	sb.set_corner_radius_all(UiTokens.RADIUS_S)
	match state:
		"primary":
			sb.bg_color = UiTokens.ACCENT
		"secondary":
			sb.bg_color = UiTokens.AMBER_WASH
			sb.set_border_width_all(UiTokens.BORDER_HAIRLINE)
			sb.border_color = UiTokens.ACCENT
		_:
			return _dashed_cell()
	box.add_theme_stylebox_override("panel", sb)
	if state != "none":
		var tick := UiFactory.make_label("✓", &"BadgeLabel",
			UiTokens.ON_ACCENT if state == "primary" else UiTokens.ACCENT)
		tick.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		tick.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		box.add_child(tick)
	return box


static func _head(text: String, width: int, align: int = HORIZONTAL_ALIGNMENT_CENTER) -> Label:
	var l := UiFactory.make_label(text, &"ColumnHeader")
	l.horizontal_alignment = align
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	if width > 0:
		l.custom_minimum_size = Vector2(width, 0)
	return l


static func tr_key(key: String) -> String:
	return TranslationServer.translate(key)
