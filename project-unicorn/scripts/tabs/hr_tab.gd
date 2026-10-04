extends Control

# ============================================================================
# Ekip penceresi (HR, §13). Koyu başlıkta Ekip, üç KPI ve beceri lejantı; altında denetim şeridi
# (Kadro / Görevler, mesai çipi, İşe alım başlat), şeritler (kaçma riski, Atlas), yapışkan tablo
# başlığı ve kayan liste. Atlas, eğitim ve çalışma saatleri PanelLayer panelleri; satır aksiyonları
# bir popover. Kadro belli bir kişi sayısından sonra sıkı kipe geçer (HRLedger.COMPACT_FROM).
#
# TAZELEME MODELİ: ucuz bir yapı anahtarı (kadro id'leri + statüler + arayış hali + mesai
# hali) yeniden-kurma ile yerinde-güncelleme arasında karar verir. Böylece morale_changed
# tek bir barı yeniden boyar, bütün satırları serbest bırakmaz.
#
# GÜN SINIRI: day_advanced'e DEĞİL, hr_day_processed'a bağlanır. day_advanced
# GameState.advance_day() içinde, TimeManager günlük tick'leri dağıtmadan ÖNCE
# atılıyor — oraya bağlanan bir tazeleme HR durumunu tick'ten ÖNCE okur (Atlas
# şeridi bir tik geride, gelen dosyalar bir tik görünmez).
#
# Bu dosya hiçbir sonucu hesaplamaz: her rakam bir motor çağrısından gelir.
# ============================================================================

## The window grows with the list (WindowLayer reads fit_height).
signal fit_changed

const ATLAS_MODAL := "res://scenes/modals/HRAtlasModal.tscn"
const WORK_HOURS_MODAL := "res://scenes/modals/WorkHoursModal.tscn"

## Aynı kadronun iki görünümü. Görünüm değişince sayfa TAM yeniden kurulur: iki tablo
## tamamen farklı sütunlar taşıyor ve görünmez bir tabloyu beslemek bayatlık demek.
const VIEW_ROSTER := "roster"
const VIEW_ASSIGNMENTS := "assignments"
## The list ends this far inside the body's right edge: the scrollbar's lane.
const GUTTER := UiTokens.SPACE_L
## The row menu's content width.
const MENU_W := 304

var frame_options: Dictionary
var _kpis: Array = []   # employees, average morale, payroll
var _outer: VBoxContainer
var _seg_slot: HBoxContainer
var _ctl_tags: HBoxContainer
var _hours: Button
var _hire: Button
var _strips: VBoxContainer
var _head_slot: MarginContainer
var _scroll: ScrollContainer
var _list: VBoxContainer
var _signals: Array = []
var _structure_key: String = ""
var _view: String = VIEW_ROSTER
var _collapsed: Dictionary = {}   # group id -> true
var _menu_id: String = ""         # the person whose row menu is open
var _held: Dictionary = {}        # emp.id -> how many of their file, dialogs and panels are open
var _rows: Dictionary = {}        # emp.id -> row, for the selection
var _morale_refs: Dictionary = {} # emp.id -> D_morale refs


func _init() -> void:
	var slot := HBoxContainer.new()
	slot.add_theme_constant_override("separation", 0)
	for key in ["HR_KPI_EMPLOYEES", "HR_KPI_MORALE", "HR_ROW_PAYROLL"]:
		var kpi := UiFactory.D_kpi(tr(key), "")
		_kpis.append(kpi)
		slot.add_child(kpi)
	var gap := Control.new()
	gap.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slot.add_child(gap)
	slot.add_child(HRUiShared.D_skill_legend())
	frame_options = {"title": "TAB_HR", "kpi": slot, "pad": Vector2i.ZERO}


func _ready() -> void:
	_build()
	# Ekip dosyasından yapılan bir kişi aksiyonu bu sayfayı da tazeler (HRLedger).
	add_to_group(HRLedger.VIEWS_GROUP)
	# Mesai ve arayış durumu için motorda sinyal yok; onları hr_day_processed ve aksiyon
	# sonrası yerel tazeleme taşıyor. Karar kapısı açılıp kapanınca denetimler kapanıp açılır.
	_signals = [
		EventBus.character_added, EventBus.character_removed, EventBus.morale_changed,
		EventBus.headline_added, EventBus.cash_changed, EventBus.burn_changed,
		EventBus.runway_recalculated, EventBus.hr_day_processed,
		# MT satırı canlı hesap sayısı taşıyor.
		EventBus.customer_assigned,
		EventBus.employee_experience_changed, EventBus.employee_training_changed,
		EventBus.event_triggered, EventBus.event_resolved, EventBus.event_set_aside,
	]
	for sig in _signals:
		sig.connect(_on_state_changed)
	EventBus.palette_changed.connect(_on_palette_changed)
	_refresh()


func _exit_tree() -> void:
	for sig in _signals:
		if sig.is_connected(_on_state_changed):
			sig.disconnect(_on_state_changed)
	if EventBus.palette_changed.is_connected(_on_palette_changed):
		EventBus.palette_changed.disconnect(_on_palette_changed)


# Üç opsiyonel parametre: 0/1/2 argümanlı sinyaller aynı işleyiciye bağlanabilsin.
func _on_state_changed(_a = null, _b = null, _c = null) -> void:
	_refresh()


func _on_palette_changed(_cb: bool) -> void:
	# Yapı anahtarı palette bağlı değil; renkler çalışma zamanında erişimcilerden kurulduğu
	# için yeni paleti ancak yeniden kurulunca alır.
	rebuild_view()


# --- Sayfa ------------------------------------------------------------------

func _build() -> void:
	_outer = VBoxContainer.new()
	_outer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_outer.add_theme_constant_override("separation", 0)
	add_child(_outer)

	var ctl := PanelContainer.new()
	ctl.theme_type_variation = &"WinCtl"
	ctl.custom_minimum_size.y = UiTokens.D_H_WIN_CTL
	var bar := HBoxContainer.new()
	bar.add_theme_constant_override("separation", UiTokens.SPACE_L)
	ctl.add_child(bar)
	_seg_slot = HBoxContainer.new()
	bar.add_child(_seg_slot)
	_ctl_tags = HBoxContainer.new()
	_ctl_tags.add_theme_constant_override("separation", UiTokens.SPACE_M)
	bar.add_child(_ctl_tags)
	var gap := Control.new()
	gap.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bar.add_child(gap)
	# §13.2 eylem grubu iki üyelidir: çalışma saatleri çipi + İşe alım başlat. Eğitim satır
	# menüsündedir (§13.3), orada kişi zaten seçili.
	_hours = Button.new()
	_hours.theme_type_variation = &"ChipButton"
	_hours.focus_mode = Control.FOCUS_NONE
	_hours.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_hours.pressed.connect(_open_hours_modal)
	bar.add_child(_hours)
	_hire = Button.new()
	_hire.theme_type_variation = &"PrimaryButtonDark"
	_hire.icon = load("res://assets/icons/util/plus.svg")
	_hire.text = tr("HR_SEARCH_START")
	_hire.focus_mode = Control.FOCUS_NONE
	_hire.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_hire.pressed.connect(open_atlas)
	bar.add_child(_hire)
	_outer.add_child(ctl)

	var body := MarginContainer.new()
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("margin_left", UiTokens.SPACE_3XL)
	body.add_theme_constant_override("margin_top", UiTokens.SPACE_XL)
	body.add_theme_constant_override("margin_right", UiTokens.SPACE_3XL - GUTTER)
	body.add_theme_constant_override("margin_bottom", UiTokens.SPACE_3XL)
	_outer.add_child(body)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 0)
	body.add_child(col)
	# Şeritler ve başlık listenin çizgisinde biter; kaydırma çubuğu sağdaki payda.
	_strips = VBoxContainer.new()
	_strips.add_theme_constant_override("separation", UiTokens.SPACE_M)
	col.add_child(_gutter(_strips))
	_head_slot = _gutter(Control.new())
	col.add_child(_head_slot)
	_scroll = ScrollContainer.new()
	_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_scroll.get_v_scroll_bar().value_changed.connect(_on_scrolled)
	col.add_child(_scroll)
	# The list is the table's width; the scroll's lane sits beside it in the gutter.
	_list = VBoxContainer.new()
	_list.size_flags_horizontal = Control.SIZE_FILL
	_list.custom_minimum_size.x = HRLedger.TABLE_W
	_list.add_theme_constant_override("separation", 0)
	_scroll.add_child(_list)


func _gutter(child: Control) -> MarginContainer:
	var pad := MarginContainer.new()
	pad.add_theme_constant_override("margin_right", GUTTER)
	pad.add_child(child)
	return pad


## The page's natural height: its frame of controls plus the whole list.
func fit_height() -> float:
	return _outer.get_combined_minimum_size().y - _scroll.get_combined_minimum_size().y \
		+ _list.get_combined_minimum_size().y


## A PanelLayer panel is open over the window: the panel holds the one amber action.
func on_panel_over(on: bool) -> void:
	_hire.theme_type_variation = &"SecondaryButton" if on else &"PrimaryButtonDark"


# --- Tazeleme ---------------------------------------------------------------

func _refresh() -> void:
	# KPI'lar, saat çipi ve denetimler yapı değişmeden de oynuyor (ortalama moral, karar kapısı),
	# o yüzden her tazelemede yeniden yazılır.
	var count: int = CharacterRegistry.count_employees()
	UiFactory.D_kpi_value(_kpis[0]).text = str(count)
	# Kimse yokken ortalama yoktur: değer satırı boş kalır, anahtar yerinde durur.
	UiFactory.D_kpi_value(_kpis[1]).text = str(int(round(HRMoraleSystem.average_morale()))) if count > 0 else ""
	UiFactory.D_kpi_value(_kpis[2]).text = Fmt.money_exact(CharacterRegistry.get_total_monthly_salaries())
	var read_only: bool = EventGate.active_id() != ""
	_hire.disabled = read_only
	_paint_hours(read_only)
	if _structure_key != _compute_structure_key():
		_rebuild()
		return
	for emp in CharacterRegistry.get_employees():
		if _morale_refs.has(emp.id):
			HRUiShared.D_repaint_morale(_morale_refs[emp.id], emp.morale)


func _compute_structure_key() -> String:
	# Satır KÜMESİNİ ve satırların şeklini değiştiren her şey buraya girer; moral GİRMEZ
	# (yerinde boyanır). Rozet ağırlığı moralle değiştiği için ayrıca yazılıyor, yoksa eşik
	# geçildiğinde satırın sırası güncellenmez. Eğitim ve izin sayaçları ile YENİ rozeti
	# yalnız yeniden kurulurken çizilir, o yüzden onlar da anahtarda. Karar kapısı boş grubun
	# düğmesini kapatır.
	var parts := PackedStringArray()
	parts.append("%s|%d|%s" % [HRSearchSystem.get_state(), HRSearchSystem.weeks_until_arrival(),
		EventGate.active_id() != ""])
	# DURUM sütunundaki saat istisnası etiketi bu sayıları okuyor (§8.5, §13.3); süre okunurken
	# başlangıca göre kırpıldığı için başlangıç da anahtarda.
	parts.append("wh%d|%d|%d" % [GameState.company_work_hours, WorkHoursSystem.start_hour(),
		WorkHoursSystem.override_count()])
	# Müşteri masasındakilerin taşıdığı hesap sayısı satırın şeklinin parçası.
	for rep in CustomerRepSystem.ranked_reps():
		parts.append("cs%s%d" % [rep.id, CustomerRepSystem.roster_size(rep.id)])
	for emp in CharacterRegistry.get_employees():
		parts.append("%s|%s|%d|%d|%d|%d|%d|%s" % [emp.id, emp.status, emp.monthly_salary,
			HRUiShared.worst_badge_severity(emp), emp.training_weeks_left,
			HRMoraleSystem.weeks_until_return(emp), int(HRConstants.is_new_hire(emp.hire_day, GameState.day)),
			",".join(PackedStringArray(emp.assigned_job_ids))])
	return "/".join(parts)


func _rebuild() -> void:
	_structure_key = _compute_structure_key()
	_morale_refs.clear()
	_rows.clear()
	UiFactory.clear(_list)
	UiFactory.clear(_strips)
	UiFactory.clear(_ctl_tags)
	UiFactory.clear(_head_slot)
	UiFactory.clear(_seg_slot)

	_seg_slot.add_child(UiFactory.D_seg_tabs([tr("HR_TAB_ROSTER"), tr("HR_TAB_ASSIGNMENTS")],
		0 if _view == VIEW_ROSTER else 1, func(i: int) -> void: _show_view([VIEW_ROSTER, VIEW_ASSIGNMENTS][i])))
	_paint_strips()
	var compact: bool = CharacterRegistry.count_employees() >= HRLedger.COMPACT_FROM
	if _view == VIEW_ASSIGNMENTS:
		_paint_assignment_tags()
		_head_slot.add_child(HRAssignments.head())
		_list.add_child(HRAssignments.build(_on_assignment_toggled, open_atlas, EventGate.active_id() != ""))
	else:
		_head_slot.add_child(HRLedger.head(compact))
		for group_id: String in HRConstants.ROSTER_GROUPS:
			_add_group(group_id, compact)
	_on_scrolled(_scroll.get_v_scroll_bar().value)
	fit_changed.emit()


## Kaçma riski başına bir şerit (dosyayı açar), sonra Atlas'ın şeridi; aralarında ve tablodan önce boşluk.
func _paint_strips() -> void:
	for emp in CharacterRegistry.get_employees():
		if HRConstants.is_flight_risk(emp.morale):
			_strips.add_child(HRUiShared.D_risk_strip(emp, _on_card_action.bind(emp.id, HRLedger.ACTION_DOSSIER, null)))
	var atlas: Control = _atlas_strip()
	if atlas != null:
		_strips.add_child(atlas)
	if _strips.get_child_count() > 0:
		_strips.add_child(Control.new())   # the strips' gap to the table


## The head turns into a stuck band once the list scrolls under it.
func _on_scrolled(value: float) -> void:
	if _head_slot.get_child_count() > 0:
		var band := _head_slot.get_child(0) as PanelContainer
		band.theme_type_variation = &"TableHeadStuck" if value > 0.0 else &"TableHead"


# --- Atlas şeridi (§10.1) ---------------------------------------------------

func _atlas_strip() -> Control:
	var state: String = HRSearchSystem.get_state()
	if state == HRConstants.SEARCH_IDLE:
		return null
	var strip := PanelContainer.new()
	strip.theme_type_variation = &"NoticeStrip"
	strip.custom_minimum_size.y = UiTokens.D_H_STRIP
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", UiTokens.SPACE_L)
	strip.add_child(row)
	var agency: String = HRConstants.search_agency_name()
	row.add_child(HRUiShared.D_mono(agency.left(1), UiTokens.D_AVATAR_ROW))
	row.add_child(UiFactory.make_label(agency, &"DataStrong"))
	var text: String
	var action := Button.new()
	action.focus_mode = Control.FOCUS_NONE
	if state == HRConstants.SEARCH_FILES_READY:
		text = tr("HR_FILES_ON_DESK").format({"n": HRSearchSystem.get_files().size()})
		action.theme_type_variation = &"SecondaryButtonSmall"
		action.text = tr("HR_OPEN_FILES")
		action.pressed.connect(open_atlas)
	else:
		# Arayış sürüyor: tek durum satırı — rol + dosyalara kalan hafta. "İade edilmez" uyarısı
		# ödeme ve iptal anında yaşıyor, bekleme şeridinde değil.
		var role_id: String = HRSearchSystem.current_role()
		var weeks: int = HRSearchSystem.weeks_until_arrival()
		text = tr(Fmt.count_key("HR_SEARCHING", weeks)).format({
			"role": HRConstants.role_label(role_id) if role_id != "" else tr("HR_CANDIDATE_GENERIC"),
			"n": weeks,
		})
		action.theme_type_variation = &"GhostButtonSmall"
		action.text = tr("HR_SEARCH_CANCEL")
		action.pressed.connect(_on_cancel_search)
	action.disabled = EventGate.active_id() != ""
	var line := UiFactory.make_label(text, &"DataText")
	line.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	line.clip_text = true
	line.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	row.add_child(line)
	row.add_child(action)
	for part: Control in row.get_children():
		part.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	return strip


func _on_cancel_search() -> void:
	# İptal para yakmıyor (§10 — arama ücretsiz), BEKLENMİŞ ZAMANI yakıyor: yeni bir arayış
	# baştan bir hafta sürer. Onay bu yüzden isteniyor.
	EventBus.confirm_requested.emit({
		"title": tr("HR_SEARCH_CANCEL_TITLE"),
		"body": tr("HR_SEARCH_CANCEL_BODY").format({"span": tr("HR_ATLAS_ARRIVAL_SPAN")}),
		"confirm_text": tr("HR_SEARCH_CANCEL_OK"),
		"cancel_text": tr("UI_DISMISS"),
		"on_confirm": _do_cancel_search,
		"theme": true,
	})


func _do_cancel_search() -> void:
	HRSearchSystem.cancel_search()
	rebuild_view()


# --- Çalışma saatleri çipi (§13.2 / §8.5) -------------------------------------

## The company's window, and after it who is on overtime (in the warning tone) or how many exceptions
## the scopes hold; while a decision waits it reads only.
func _paint_hours(read_only: bool) -> void:
	UiFactory.clear(_hours)
	_hours.disabled = read_only
	# Pencere tek evden okunur (§15.2): modal ile çip aynı cümleyi çizmek zorunda.
	var win: Dictionary = WorkHoursSystem.company_window()
	var parts := HBoxContainer.new()
	parts.add_theme_constant_override("separation", UiTokens.SPACE_M)
	var off: Variant = UiTokens.D_INK_OFF if read_only else null
	parts.add_child(UiFactory.make_glyph("res://assets/icons/util/clock.svg", UiTokens.D_ICON_BUTTON,
		UiTokens.D_INK_OFF if read_only else UiTokens.D_INK_3))
	parts.add_child(UiFactory.make_label(tr("HR_HOURS_WINDOW").format(
		{"start": String(win["start_text"]), "end": String(win["end_text"])}), &"DataText", off))
	var over: int = int(WorkHoursSystem.counts()["overtime"])
	var exceptions: int = WorkHoursSystem.override_count()
	if over > 0 or exceptions > 0:
		parts.add_child(UiFactory.make_label("·", &"CaptionFaint", off))
		parts.add_child(UiFactory.make_label(
			tr("HR_HOURS_FACT_OVER").format({"n": over}) if over > 0
				else tr(Fmt.count_key("HR_HOURS_CHIP_OVERRIDES", exceptions)).format({"n": exceptions}),
			&"DataText", off if read_only else (UiTokens.D_warn() if over > 0 else UiTokens.D_INK_3)))
	for part: Control in parts.get_children():
		part.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	HRUiShared.set_mouse_ignore(parts)
	_hours.add_child(parts)
	parts.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	parts.offset_left = UiTokens.SPACE_L
	parts.offset_right = -UiTokens.SPACE_L
	_hours.custom_minimum_size = Vector2(parts.get_combined_minimum_size().x + 2 * UiTokens.SPACE_L, UiTokens.D_H_BTN)


func _open_hours_modal() -> void:
	HRUiShared.mount_panel_modal(self, WORK_HOURS_MODAL, rebuild_view)


## Atlas panelini açar; Ürün'ün boş sprint sütunu da buradan işe alım başlatır.
func open_atlas() -> void:
	# Motorun arayış geçişleri için sinyali yok; modal haber veriyor.
	HRUiShared.mount_panel_modal(self, ATLAS_MODAL, _refresh)


# --- Kadro grupları ---------------------------------------------------------

## A roster group: its head (click folds it), then its people, or the empty row's way to hire.
func _add_group(group_id: String, compact: bool) -> void:
	# get_employees(), get_active_employees() DEĞİL: defter izindeki ve eğitimdeki kişiyi de
	# gösterir — maaşı ödeniyor, yalnız o günkü kapasiteye girmiyor.
	var roster: Array[Character] = []
	for emp in CharacterRegistry.get_employees():
		if String(HRConstants.ROLE_GROUP.get(emp.role, "")) == group_id:
			roster.append(emp)
	var folded: bool = _collapsed.has(group_id)
	_list.add_child(HRUiShared.D_group(HRConstants.group_label(group_id),
		"res://assets/icons/dept/%s.svg" % group_id, roster.size(), folded, _toggle_group.bind(group_id)))
	if folded:
		return
	if roster.is_empty():
		_list.add_child(HRUiShared.D_empty_row(tr("HR_EMPTY_ROW"), tr("HR_SEARCH_START"), open_atlas,
			EventGate.active_id() != ""))
		return
	# Dikkat isteyen satırlar üste. sort_custom kararlı DEĞİL ve çoğu ağırlık 0, o yüzden
	# hire_day ve id ile kesin tiebreak: sıra her yeniden kurmada aynı kalır.
	roster.sort_custom(func(a: Character, b: Character) -> bool:
		var sa: int = HRUiShared.worst_badge_severity(a)
		var sb: int = HRUiShared.worst_badge_severity(b)
		if sa != sb:
			return sa > sb
		if a.hire_day != b.hire_day:
			return a.hire_day < b.hire_day
		return a.id < b.id)
	for emp in roster:
		var refs: Dictionary = {}
		var line := HRLedger.row(emp, compact, _is_selected(emp.id), _on_card_action, refs)
		_rows[emp.id] = line
		_morale_refs[emp.id] = refs
		_list.add_child(line)


func _toggle_group(group_id: String) -> void:
	if not _collapsed.erase(group_id):
		_collapsed[group_id] = true
	rebuild_view()


# --- KADRO / GÖREVLER -------------------------------------------------------

func _show_view(view_id: String) -> void:
	if _view == view_id:
		return
	_view = view_id
	_scroll.scroll_vertical = 0
	rebuild_view()


## Görevler'de sekmelerin yanında: kaç kişi boşta (çizgi etiket) ve kaçı aşırı yükte (uyarı). Sıfır
## olan çizilmez — sıfırı göstermek bir uyarıyı gürültüye çevirir.
func _paint_assignment_tags() -> void:
	var idle: int = HRSystem.idle_count()
	if idle > 0:
		_ctl_tags.add_child(UiFactory.D_tag(tr("HR_CHIP_IDLE_COUNT").format({"n": idle}), &"outline"))
	var over: int = 0
	for emp in CharacterRegistry.get_active_employees():
		if HRSystem.is_overloaded(emp):
			over += 1
	if over > 0:
		_ctl_tags.add_child(UiFactory.D_tag(tr("HR_CHIP_OVERLOAD_COUNT").format({"n": over}), &"warn"))


## GÖREVLER matrisindeki bir kutu tıklandı. Tek yazar CharacterRegistry; yer değiştirmeyi
## ve kurucunun duraklamasını (Ar-Ge §5.0) `assign_job` kendi içinde yapıyor.
func _on_assignment_toggled(char_id: String, job_id: String, currently_on: bool) -> void:
	if currently_on:
		CharacterRegistry.unassign_job(char_id, job_id)
	else:
		var reason: String = CharacterRegistry.assign_job(char_id, job_id)
		# Matris atanamaz kareyi tıklanamaz çiziyor; buraya düşülüyorsa arayüz ile motor
		# ayrışmış demektir.
		if reason != "":
			push_warning("[HRTab] assign_job('%s', '%s') refused: %s" % [char_id, job_id, reason])
	rebuild_view()


func _on_card_action(emp_id: String, action: String, anchor: Control) -> void:
	var emp: Character = CharacterRegistry.get_character(emp_id)
	if emp == null:
		return
	if action == HRLedger.ACTION_MENU:
		_open_actions(emp, anchor)
	else:
		HRLedger.run_action(self, emp, action)


# --- Satır menüsü ve seçim -------------------------------------------------

## The row menu (9e): who it is for, then the person's actions with the file first.
func _open_actions(emp: Character, anchor: Control) -> void:
	var pop: HRPopover = HRPopover.mount(anchor, true)
	if pop == null:
		return
	var body: VBoxContainer = pop.body()
	body.add_theme_constant_override("separation", 0)
	body.custom_minimum_size.x = MENU_W
	var head := MarginContainer.new()
	for side in ["left", "top", "right", "bottom"]:
		head.add_theme_constant_override("margin_" + side, UiTokens.SPACE_M)
	head.add_child(HRUiShared.D_who(emp, UiTokens.D_AVATAR_ROW, UiTokens.SPACE_M))
	body.add_child(head)
	body.add_child(HSeparator.new())
	body.add_child(HRLedger.action_list(emp, func(act: String) -> void:
		pop.close()
		HRLedger.run_action(self, emp, act), true))
	pop.tree_exited.connect(_on_menu_closed.bind(emp.id))
	pop.open_at(anchor)
	_menu_id = emp.id
	_paint_selection()


## A menu replaced by the next one closes after it opened: only the open menu's person is cleared.
func _on_menu_closed(character_id: String) -> void:
	if _menu_id == character_id:
		_menu_id = ""
		_paint_selection()


## A person's file, dialog or panel says it opened or closed (HRLedger.VIEWS_GROUP), so their row stays
## raised while any of them is open; a file replaced by the next one closes after it opened.
func hold_person(character_id: String, on: bool) -> void:
	var n: int = int(_held.get(character_id, 0)) + (1 if on else -1)
	if n > 0:
		_held[character_id] = n
	else:
		_held.erase(character_id)
	_paint_selection()


func _is_selected(character_id: String) -> bool:
	return character_id == _menu_id or _held.has(character_id)


func _paint_selection() -> void:
	for id: String in _rows:
		HRUiShared.D_select_row(_rows[id], _is_selected(id))


## Yapı anahtarını geçersiz kılıp tam yeniden kurar. set_salary ve set_status sinyal
## atmadığı için aksiyon sonrası tazeleme buradan tetikleniyor (HRLedger.VIEWS_GROUP).
func rebuild_view() -> void:
	_structure_key = ""
	_refresh()
