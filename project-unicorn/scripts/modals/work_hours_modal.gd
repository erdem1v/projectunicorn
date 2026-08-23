extends Control

# ÇALIŞMA SAATLERİ — §8.5, onaylı 19a–19d.
#
# Modal Kadro başlığındaki saat kontrolünden açılır ve KADRO BİÇİMİNDE kurulur: en üstte
# Şirket satırı, altında her grup kendi başlık satırıyla, her grubun altında çalışanları
# girintili. Kurucu bu listede GÖRÜNMEZ — morali olmadığı için kişisel bir istisna hiçbir şey
# ifade etmez ve çıktısı zaten şirket saatiyle orantılı değişir (§2, §8.1).
#
# YAZMA ANINDA OLUR, TAAHHÜT DÜĞMESİ YOKTUR. Gerekçe motorda yazılı: WorkHoursSystem'in beş
# yazıcısının HER BİRİ `assignment_changed` yayınlıyor, yani zaten satır satır çağrılmak üzere
# yapılmışlar; tek bir commit'te toplansalardı o yayınların hiçbirinin karşılığı olmazdı.
# §8.5'in "maliyet TAAHHÜTTEN ÖNCE okunur" cümlesi bu yüzden bir düğmeyle değil, bedel
# bloğunun her adımda yeniden çizilmesiyle karşılanıyor: para gün tick'inde çıkar, oyuncu onu
# o günden önce okur.
#
# DEVRALMA GÖRÜNÜR (§8.5): üstünden devralan satır değerini SOLUK gösterir, istisna taşıyan
# satır DOLU gösterir ve devralmaya dönmek için sessiz bir eylem taşır. KAYNAK sütunu (19b)
# bunu kelimeye çevirir — oyuncu listeyi bir kez tarayarak hangi satırın karar verdiğini,
# hangisinin takip ettiğini görür.
#
# MORAL HİÇBİR ZAMAN SAYIYLA OKUNMAZ (§8.5): ne çarpan, ne yüzde, ne oran. Çarpanın saatle
# değiştiği bilgisi satır başına HOVER CÜMLESİYLE verilir — altı kademe, altı ayrı cümle.
#
# PanelLayer'da yaşar, ModalLayer'da DEĞİL: HRAtlasModal'ın kalıbı (gerekçe hr_tab._open_atlas).

signal state_changed

const PANEL_MIN := Vector2(1080, 0)

const W_NAME := 300
const W_STEP := 132
const W_SOURCE := 150
const W_STATE := 132
const W_MORALE := 92
const W_REVERT := 128
const INDENT := 22

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
	_root_box.add_theme_constant_override("separation", 12)
	margin.add_child(_root_box)


## Ev sahibi ÖNCE add_child eder, SONRA burayı çağırır (ev kuralı).
func populate() -> void:
	if not is_node_ready():
		await ready
	_rebuild()


func _rebuild() -> void:
	for c in _root_box.get_children():
		_root_box.remove_child(c)
		c.queue_free()

	_root_box.add_child(_head())
	_root_box.add_child(HRUiShared.hairline())
	_root_box.add_child(_columns())
	_root_box.add_child(HRUiShared.hairline())

	# ŞİRKET SATIRI en üstte (§8.5). Tabanı odur; herkes onu devralarak başlar.
	_root_box.add_child(_company_row())

	for group_id in HRConstants.ROSTER_GROUPS:
		var roster: Array[Character] = []
		for emp in CharacterRegistry.get_employees():
			if String(HRConstants.ROLE_GROUP.get(emp.role, "")) == String(group_id):
				roster.append(emp)
		# Boş bir grup da satırını taşır: grup istisnası, o gruba SONRADAN KATILAN herkesi
		# kapsar (§8.1), yani boşken yazılan bir istisna anlamlıdır.
		_root_box.add_child(_group_row(String(group_id)))
		for emp in roster:
			_root_box.add_child(_person_row(emp))

	var cost: Control = _cost_block()
	if cost != null:
		_root_box.add_child(HRUiShared.hairline())
		_root_box.add_child(cost)

	_root_box.add_child(HRUiShared.hairline())
	_root_box.add_child(_footer())


# --- Başlık ------------------------------------------------------------------

func _head() -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 14)
	row.add_child(UiFactory.make_label(
		UiTokens.tr_upper(tr("HR_HOURS_TITLE")), &"SectionAmber"))

	# BAŞLANGIÇ SAATİ YALNIZ ŞİRKET KAPSAMINDADIR (§8.1): "Ofis tek saatte açılır; değişen,
	# kimin ne zaman çıktığıdır." O yüzden burada, listede değil.
	var start := HBoxContainer.new()
	start.add_theme_constant_override("separation", 8)
	start.add_child(UiFactory.make_label(tr("HR_HOURS_START"), &"RowMeta", UiTokens.INK_DIM))
	start.add_child(_stepper(
		WorkHoursSystem.start_hour(), HRConstants.START_HOUR_MIN, HRConstants.START_HOUR_MAX,
		_on_start_hour, "%02d:00" % WorkHoursSystem.start_hour()))
	row.add_child(start)

	var pad := Control.new()
	pad.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(pad)

	# §8.5 "Tümünü şirkete eşitle bütün istisnaları temizler." İstisna yokken çizilmez:
	# söyleyecek şeyi olmayan satır yoktur.
	if WorkHoursSystem.override_count() > 0:
		row.add_child(HRUiShared.action_button(tr("HR_HOURS_EQUALISE"), _on_equalise))
	return row


func _columns() -> Control:
	var cols := HBoxContainer.new()
	cols.add_theme_constant_override("separation", 0)
	cols.add_child(_head_cell("", W_NAME, HORIZONTAL_ALIGNMENT_LEFT))
	cols.add_child(_head_cell(tr("HR_HOURS_COL_HOURS"), W_STEP))
	cols.add_child(_head_cell(tr("HR_HOURS_COL_SOURCE"), W_SOURCE, HORIZONTAL_ALIGNMENT_LEFT))
	cols.add_child(_head_cell(tr("HR_HOURS_COL_STATE"), W_STATE, HORIZONTAL_ALIGNMENT_LEFT))
	cols.add_child(_head_cell(tr("HR_COL_MORALE"), W_MORALE, HORIZONTAL_ALIGNMENT_LEFT))
	cols.add_child(_head_cell("", W_REVERT, HORIZONTAL_ALIGNMENT_LEFT))
	# PANEL YOK. HeaderBand'in iç kenar boşlukları başlıkları adlandırdıkları sütundan ~20px
	# sağa itiyordu ve satırlar öyle bir kabuk taşımadığı için ikisi hiçbir zaman
	# hizalanmıyordu (çekimden okundu). Düz HBox satırlarla AYNI geometriyi taşır — hizalama
	# bir ayara değil, yapıya bağlı.
	return cols


# --- Satırlar ----------------------------------------------------------------

func _company_row() -> Control:
	var row := _row_shell(tr("HR_HOURS_SCOPE_COMPANY"), 0, true)
	var hours: int = GameState.company_work_hours
	row.add_child(_hours_cell(hours, false, _on_company_hours))
	row.add_child(_text_cell("", W_SOURCE))            # taban: devralacağı bir üst yok
	row.add_child(_state_cell(hours))
	row.add_child(_text_cell("", W_MORALE))            # şirketin morali yoktur
	row.add_child(_text_cell("", W_REVERT))
	return _hover(row, hours)


func _group_row(group_id: String) -> Control:
	var row := _row_shell(HRConstants.group_label(group_id), 0, true)
	var owns: bool = WorkHoursSystem.group_has_override(group_id)
	var hours: int = int(GameState.group_work_hours_override.get(group_id, GameState.company_work_hours))
	row.add_child(_hours_cell(hours, not owns, _on_group_hours.bind(group_id)))
	row.add_child(_text_cell(
		tr("HR_HOURS_SOURCE_OWN") if owns else tr("HR_HOURS_SCOPE_COMPANY"), W_SOURCE,
		UiTokens.INK if owns else UiTokens.INK_DIM))
	row.add_child(_state_cell(hours))
	row.add_child(_text_cell("", W_MORALE))
	row.add_child(_revert_cell(owns, tr("HR_HOURS_BACK_TO_COMPANY"),
		_on_clear_group.bind(group_id)))
	return _hover(row, hours)


func _person_row(emp: Character) -> Control:
	var row := _row_shell(emp.character_name, INDENT, false)
	var owns: bool = WorkHoursSystem.person_has_override(emp)
	var hours: int = WorkHoursSystem.hours_for(emp)
	row.add_child(_hours_cell(hours, not owns, _on_person_hours.bind(emp.id)))
	# KAYNAK, kelimeyle. inherited_from KAPSAM SÖZCÜĞÜ döner ("group" / "company"), grup id'si
	# DEĞİL. Bu satır önce onu ROSTER_GROUPS'ta arıyordu ve hiç eşleşmiyordu: istisnası olan
	# bir GRUPTAN devralan herkes "Şirket" diye etiketleniyordu — yani §8.5'in okunur kılmak
	# için var olduğu sütun, kararı veren satırı yanlış gösteriyordu. Çekimden okundu.
	var source: String = tr("HR_HOURS_SOURCE_OWN")
	if not owns:
		source = HRConstants.group_label(WorkHoursSystem.group_of(emp)) \
			if WorkHoursSystem.inherited_from(emp) == "group" \
			else tr("HR_HOURS_SCOPE_COMPANY")
	row.add_child(_text_cell(source, W_SOURCE, UiTokens.INK if owns else UiTokens.INK_DIM))
	row.add_child(_state_cell(hours))
	# §8.5: "Çalışan satırları ayrıca moralini KÜÇÜK olarak taşır — bir kişiye istisna
	# yazmanın sebebi zaten odur." Sayı değil, çubuk: §8.5 moralin sayıyla okunmasını
	# yalnız SAAT ÇARPANI için yasaklıyor, ama bu sütun kadro defteriyle aynı gramerde
	# kalmalı, o yüzden oradaki morale_row'un kendisi kullanılıyor.
	var morale := HBoxContainer.new()
	morale.custom_minimum_size = Vector2(W_MORALE, 0)
	morale.add_child(HRUiShared.morale_row(emp.morale, {}, false))
	row.add_child(morale)
	# İstisna geri alınabilir; geri alınınca satır ÜSTÜNÜ devralmaya döner (§8.1) — ve
	# "üstü" gruba göre değişir, o yüzden etiket de değişir.
	var back_key: String = "HR_HOURS_BACK_TO_GROUP" if WorkHoursSystem.group_of(emp) != "" \
		else "HR_HOURS_BACK_TO_COMPANY"
	row.add_child(_revert_cell(owns, tr(back_key), _on_clear_person.bind(emp.id)))
	return _hover(row, hours)


func _row_shell(label: String, indent: int, strong: bool) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 0)
	var name_box := HBoxContainer.new()
	name_box.custom_minimum_size = Vector2(W_NAME, 0)
	if indent > 0:
		var pad := Control.new()
		pad.custom_minimum_size = Vector2(indent, 0)
		name_box.add_child(pad)
	name_box.add_child(UiFactory.make_label(label,
		&"RowName" if strong else &"BodySerif"))
	row.add_child(name_box)
	return row


# --- Hücreler ----------------------------------------------------------------

## Saat hücresi: sessiz − , sayı, sessiz + (§8.5). DEVRALAN SATIR DEĞERİNİ SOLUK GÖSTERİR —
## okunur ama ödünç alınmış olduğu bellidir; istisna taşıyan satır dolu gösterir.
func _hours_cell(hours: int, inherited: bool, on_set: Callable) -> Control:
	return _stepper(hours, HRConstants.WORK_HOURS_MIN, HRConstants.WORK_HOURS_MAX, on_set,
		tr("HR_HOURS_VALUE").format({"n": hours}), inherited)


func _stepper(value: int, lo: int, hi: int, on_set: Callable, text: String,
		dim: bool = false) -> Control:
	var box := HBoxContainer.new()
	box.custom_minimum_size = Vector2(W_STEP, 0)
	box.add_theme_constant_override("separation", 6)
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_child(_step_button("−", value > lo, on_set.bind(value - 1)))
	var num := UiFactory.make_label(text, &"MetricValueInk",
		UiTokens.INK_DIM if dim else UiTokens.INK)
	num.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	num.custom_minimum_size = Vector2(56, 0)
	box.add_child(num)
	box.add_child(_step_button("+", value < hi, on_set.bind(value + 1)))
	return box


## SESSİZ düğme: kenarlıklı temanın varsayılan butonu, dar min-size'la. Dolu bir buton
## (CommitButton) burada yanlış olurdu — bir satırda iki taahhüt rengi taşımak, §8.5'in
## "kompakt saat kontrolü" tarifiyle de, sayfanın vurgu bütçesiyle de çelişir.
func _step_button(glyph: String, enabled: bool, on_press: Callable) -> Button:
	var btn := Button.new()
	btn.text = glyph
	btn.custom_minimum_size = Vector2(26, 24)
	btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	btn.disabled = not enabled
	if enabled and on_press.is_valid():
		btn.pressed.connect(on_press)
	return btn


## §8.5 DURUM DİLİ: 8 saat nötr ve SÜSLEMESİZ · 9–11 amber, son ek "+Ns mesai" ·
## 5–7 sakin aile, son ek "−Ns kısa". Sayı yok, çarpan yok.
func _state_cell(hours: int) -> Control:
	var delta: int = hours - HRConstants.WORK_HOURS_DEFAULT
	if delta == 0:
		return _text_cell("", W_STATE)
	if delta > 0:
		return _text_cell(TranslationServer.translate("HR_STATE_HOURS_OVER").format({"n": delta}),
			W_STATE, UiTokens.ACCENT)
	return _text_cell(TranslationServer.translate("HR_STATE_HOURS_SHORT").format({"n": -delta}),
		W_STATE, UiTokens.POSITIVE)


## Devralmaya dönüş: SESSİZ bir eylem (§8.5). İstisnası olmayan satırda hiç çizilmez —
## boş bir yer tutucu, olmayan bir seçeneği varmış gibi gösterirdi.
func _revert_cell(owns: bool, label: String, on_press: Callable) -> Control:
	if not owns:
		return _text_cell("", W_REVERT)
	var box := HBoxContainer.new()
	box.custom_minimum_size = Vector2(W_REVERT, 0)
	box.add_child(HRUiShared.action_button(label, on_press))
	return box


func _text_cell(text: String, width: int, color: Color = UiTokens.INK_MUTED) -> Control:
	var lbl := UiFactory.make_label(text, &"RowMeta", color)
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl.custom_minimum_size = Vector2(width, 22)
	return lbl


func _head_cell(text: String, width: int, align: int = HORIZONTAL_ALIGNMENT_CENTER) -> Label:
	var lbl := UiFactory.make_label(text, &"ColumnHeader")
	lbl.horizontal_alignment = align
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl.custom_minimum_size = Vector2(width, 0)
	return lbl


## §8.5: "Oyuncu çarpanın saatle değiştiğini BİLMELİDİR. Bu bilgi SAYIYLA DEĞİL, cümlenin
## kademeye göre değişmesiyle verilir ve SATIR BAŞINA HOVER'DA durur." Altı kademe, altı
## cümle; sekiz saatte hover YOKTUR (söyleyecek bir şey yok).
func _hover(row: Control, hours: int) -> Control:
	if hours != HRConstants.WORK_HOURS_DEFAULT:
		var key: String = "HR_HOURS_HOVER_%d" % hours
		var line: String = TranslationServer.translate(key)
		if line != key:
			row.tooltip_text = line
			row.mouse_filter = Control.MOUSE_FILTER_STOP
	return row


# --- §14 bedel bloğu ---------------------------------------------------------

## §8.5: "Kimse mesaide ve kimse kısa günde değilken bedel listesi TAMAMEN KAPANIR: ne
## delta, ne olgu, ne kural. Sıfırlanmış ya da soluk satır gösterilmez; söyleyecek şeyi
## olmayan satır yoktur." null döner ve çağıran hairline'ı da çizmez.
func _cost_block() -> Control:
	var counts: Dictionary = WorkHoursSystem.counts()
	var over: int = int(counts["overtime"])
	var short_day: int = int(counts["short_day"])
	if over == 0 and short_day == 0:
		return null

	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 8)

	# DELTA — bloğun en ağır elemanı (§8.5). "Önce" bugün YAYINLANMIŞ günlük burn'dür;
	# "sonra" bu saatlerin ima ettiği burn. Mesai gün tick'inde tahakkuk eder, yani oyuncu
	# rakamı onu ödemeden önce okur.
	var accrual: int = WorkHoursSystem.overtime_pay_accrued_today()
	var published: int = int(FinanceSystem.get_burn_breakdown().get("overtime", 0))
	var before: int = GameState.daily_burn
	var after: int = before - published + accrual
	var delta := HBoxContainer.new()
	delta.add_theme_constant_override("separation", 10)
	delta.add_child(UiFactory.make_label(tr("HR_HOURS_COST_BURN"), &"RowMeta", UiTokens.INK_DIM))
	delta.add_child(UiFactory.make_label(HRUiShared.money(before), &"RowMeta", UiTokens.INK_MUTED))
	delta.add_child(UiFactory.make_label("→", &"RowMeta", UiTokens.INK_DIM))
	delta.add_child(UiFactory.make_label(HRUiShared.money(after), &"MetricValueInk",
		UiTokens.NEGATIVE if after > before else UiTokens.INK))
	col.add_child(delta)

	# OLGU — kaç kişi hangi kademede. Sıfır olan yarım hiç yazılmaz.
	var facts: Array[String] = []
	if over > 0:
		facts.append(tr("HR_HOURS_FACT_OVER").format({"n": over}))
	if short_day > 0:
		facts.append(tr("HR_HOURS_FACT_SHORT").format({"n": short_day}))
	col.add_child(UiFactory.make_label(" · ".join(facts), &"RowMeta", UiTokens.INK_MUTED))

	# KURAL — yalnız geçerli olanı. Kısa gün kuralı §8.3'ün adıyla istediği satırdır:
	# "Maaş yükü düşmez ... ve bu modalde AÇIKÇA YAZILIR — yoksa oyuncu tasarruf bekler
	# ve sistemi bozuk sanır."
	if over > 0:
		col.add_child(_rule(tr("HR_HOURS_RULE_OVERTIME")))
	if short_day > 0:
		col.add_child(_rule(tr("HR_HOURS_RULE_SHORT")))
	return col


func _rule(text: String) -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 9)
	row.add_child(HRUiShared.lock_glyph(11, UiTokens.INK_DIM))
	row.add_child(UiFactory.make_label(text, &"RowMeta", UiTokens.INK_DIM))
	return row


func _footer() -> Control:
	var row := HBoxContainer.new()
	var pad := Control.new()
	pad.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(pad)
	# "KAPAT", "VAZGEÇ" DEĞİL: saatler anında yazıldı, geri alınacak bir taahhüt yok.
	# Bir vazgeç düğmesi olmayan bir geri-alma vaat ederdi.
	row.add_child(HRUiShared.action_button(tr("HR_HOURS_CLOSE"), _close, true))
	return row


# --- Yazma (hepsi WorkHoursSystem üzerinden; bu dosya hiçbir alanı doğrudan yazmaz) ---

func _on_company_hours(hours: int) -> void:
	WorkHoursSystem.set_company_hours(hours)
	_after_change()


func _on_start_hour(hour: int) -> void:
	WorkHoursSystem.set_company_start_hour(hour)
	_after_change()


func _on_group_hours(hours: int, group_id: String) -> void:
	WorkHoursSystem.set_group_hours(group_id, hours)
	_after_change()


func _on_person_hours(hours: int, id: String) -> void:
	WorkHoursSystem.set_person_hours(id, hours)
	_after_change()


func _on_clear_group(group_id: String) -> void:
	WorkHoursSystem.clear_group_hours(group_id)
	_after_change()


func _on_clear_person(id: String) -> void:
	WorkHoursSystem.clear_person_hours(id)
	_after_change()


func _on_equalise() -> void:
	WorkHoursSystem.equalise_all()
	_after_change()


func _after_change() -> void:
	state_changed.emit()
	_rebuild()


func _unhandled_input(ev: InputEvent) -> void:
	if ev.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_close()


func _close() -> void:
	queue_free()
