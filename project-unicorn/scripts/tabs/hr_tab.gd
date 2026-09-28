extends Control

# ============================================================================
# Ekip sayfası — HR sekmesi (§13).
#
# Kod-kurulu düzen, boş .tscn kökü: grup bölümleri dinamik. Atlas, eğitim ve çalışma
# saatleri PanelLayer modalları; satır aksiyonları bir popover.
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
# Bu dosya hiçbir sonucu hesaplamaz: her rakam bir motor çağrısından gelir. Tek istisna
# BİÇİMLEME: kesir → yüzde ve float → int yuvarlaması.
# ============================================================================

const ATLAS_MODAL := "res://scenes/modals/HRAtlasModal.tscn"
const WORK_HOURS_MODAL := "res://scenes/modals/WorkHoursModal.tscn"

## Aynı kadronun iki görünümü. Görünüm değişince sayfa TAM yeniden kurulur: iki tablo
## tamamen farklı sütunlar taşıyor ve görünmez bir tabloyu beslemek bayatlık demek.
const VIEW_ROSTER := "roster"
const VIEW_ASSIGNMENTS := "assignments"

var _signals: Array = []
var _list: VBoxContainer = null
var _summary: Label = null
var _hours_control: Button = null
var _structure_key: String = ""
var _view: String = VIEW_ROSTER
var _seg_roster: Button = null
var _seg_assign: Button = null
var _placement_chips: HBoxContainer = null
var _attention_strip: VBoxContainer = null
var _header: Control = null   # KADRO sütun başlıkları; GÖREVLER görünümünde gizli
# Satır başına yerinde-repaint referansları: emp.id → {"bar":…, "value":…}
var _morale_refs: Dictionary = {}


func _ready() -> void:
	_build_chrome()
	# Ekip dosyasından yapılan bir kişi aksiyonu bu sayfayı da tazeler (HRLedger).
	add_to_group(HRLedger.VIEWS_GROUP)
	# Mesai ve arayış durumu için motorda sinyal yok; onları hr_day_processed ve aksiyon
	# sonrası yerel tazeleme taşıyor.
	_signals = [
		EventBus.character_added, EventBus.character_removed, EventBus.morale_changed,
		EventBus.headline_added, EventBus.cash_changed, EventBus.burn_changed,
		EventBus.runway_recalculated, EventBus.hr_day_processed,
		# MT satırı canlı hesap sayısı taşıyor.
		EventBus.customer_assigned,
		EventBus.employee_experience_changed, EventBus.employee_training_changed,
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
	# Yapı anahtarı palette bağlı değil; çipler çalışma zamanında erişimcilerden kurulduğu
	# için yeni paleti ancak yeniden kurulunca alır.
	rebuild_view()


# --- Sayfa kromu ------------------------------------------------------------

func _build_chrome() -> void:
	# Kenar boşluğu pencerenin (WindowFrame): başlık satırı kapatma glifiyle aynı çizgide.
	var outer := VBoxContainer.new()
	outer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	outer.add_theme_constant_override("separation", 10)
	add_child(outer)

	# Başlık satırı: Ekip + özet + yerleşim çipleri · sağda saat kontrolü + İŞE ALIM BAŞLAT.
	var head := HBoxContainer.new()
	head.add_theme_constant_override("separation", 14)
	head.alignment = BoxContainer.ALIGNMENT_CENTER
	head.add_child(UiFactory.make_label(tr("HR_PAGE_TITLE"), &"PageTitleSerif"))
	# Özet + çipler tek genişleyen grupta durur: özet kelepçelenmez, çipler cümlenin hemen
	# ardına gelir ve kalan boşluk eylem grubunu sağa iter.
	var info := HBoxContainer.new()
	info.add_theme_constant_override("separation", 14)
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(info)
	_summary = UiFactory.make_label("", &"TitleRowSummary")
	_summary.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	info.add_child(_summary)
	_placement_chips = HBoxContainer.new()
	_placement_chips.add_theme_constant_override("separation", UiTokens.SPACE_S)
	_placement_chips.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	info.add_child(_placement_chips)
	# §13.2 eylem grubu iki üyelidir: çalışma saatleri kontrolü + İŞE ALIM BAŞLAT. Eğitim
	# satır menüsündedir (§13.3), orada kişi zaten seçili.
	_hours_control = _build_hours_control()
	head.add_child(_hours_control)
	head.add_child(HRUiShared.action_button(tr("HR_SEARCH_START"), _open_atlas, true))
	outer.add_child(head)

	var tabs := HBoxContainer.new()
	tabs.add_theme_constant_override("separation", 28)
	_seg_roster = _make_segment(tr("HR_TAB_ROSTER"), VIEW_ROSTER)
	_seg_assign = _make_segment(tr("HR_TAB_ASSIGNMENTS"), VIEW_ASSIGNMENTS)
	tabs.add_child(_seg_roster)
	tabs.add_child(_seg_assign)
	outer.add_child(tabs)
	outer.add_child(HRUiShared.hairline())

	# Dikkat şeridi doğrudan sayfa başlığının altında; boşken görünmez.
	_attention_strip = VBoxContainer.new()
	_attention_strip.add_theme_constant_override("separation", 6)
	outer.add_child(_attention_strip)

	# Sütun başlıkları kaydırma alanının DIŞINDA: sayfa kayarken görünür kalır.
	_header = HRLedger.column_header()
	outer.add_child(_header)

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	outer.add_child(scroll)
	_list = VBoxContainer.new()
	_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_list.add_theme_constant_override("separation", 10)
	scroll.add_child(_list)


# --- Tazeleme ---------------------------------------------------------------

func _refresh() -> void:
	# Saat çipi ve özet yapı değişmeden de oynuyor (modalde saat, ortalama moral), o yüzden
	# her tazelemede yeniden yazılır.
	_paint_hours_control()
	_summary.text = tr("HR_SUMMARY").format({
		"count": CharacterRegistry.count_employees(),
		"morale": int(round(HRMoraleSystem.average_morale())),
		"payroll": Fmt.money_exact(CharacterRegistry.get_total_monthly_salaries()),
	})
	if _structure_key != _compute_structure_key():
		_rebuild()
		return
	for emp in CharacterRegistry.get_employees():
		if _morale_refs.has(emp.id):
			HRUiShared.repaint_morale(_morale_refs[emp.id], emp.morale)


func _compute_structure_key() -> String:
	# Satır KÜMESİNİ ve satırların şeklini değiştiren her şey buraya girer; moral GİRMEZ
	# (yerinde boyanır). Rozet ağırlığı moralle değiştiği için ayrıca yazılıyor, yoksa eşik
	# geçildiğinde satırın sırası güncellenmez. Eğitim ve izin sayaçları ile YENİ rozeti
	# yalnız yeniden kurulurken çizilir, o yüzden onlar da anahtarda.
	var parts := PackedStringArray()
	parts.append("%s|%d" % [HRSearchSystem.get_state(), HRSearchSystem.weeks_until_arrival()])
	# DURUM sütunundaki saat istisnası etiketi bu sayıları okuyor (§8.5, §13.3); süre okunurken
	# başlangıca göre kırpıldığı için başlangıç da anahtarda.
	parts.append("wh%d|%d|%d" % [GameState.company_work_hours, WorkHoursSystem.start_hour(),
		WorkHoursSystem.override_count()])
	# Müşteri masasındakilerin taşıdığı hesap sayısı satırın şeklinin parçası.
	for rep in CustomerRepSystem.ranked_reps():
		parts.append("cs%s%d" % [rep.id, CustomerRepSystem.roster_size(rep.id)])
	for emp in CharacterRegistry.get_employees():
		parts.append("%s|%s|%d|%d|%d|%d|%d" % [emp.id, emp.status, emp.monthly_salary,
			HRUiShared.worst_badge_severity(emp), emp.training_weeks_left,
			HRMoraleSystem.weeks_until_return(emp), int(HRConstants.is_new_hire(emp.hire_day, GameState.day))])
	return "/".join(parts)


func _rebuild() -> void:
	_structure_key = _compute_structure_key()
	_morale_refs.clear()
	UiFactory.clear(_list)

	_paint_placement_chips()
	_paint_attention_strip()
	_paint_segments()

	_header.visible = _view == VIEW_ROSTER
	if _view == VIEW_ASSIGNMENTS:
		_list.add_child(HRAssignments.build(_on_assignment_toggled, _open_atlas))
		return

	var strip: Control = _atlas_strip()
	if strip != null:
		_list.add_child(strip)
	for group_id in HRConstants.ROSTER_GROUPS:
		_add_group(String(group_id))


# --- Atlas şeridi (§10.1) ---------------------------------------------------

func _atlas_strip() -> Control:
	var state: String = HRSearchSystem.get_state()
	if state == HRConstants.SEARCH_IDLE:
		return null
	# CardCta (amber çerçeve): CardAttention kaçma riskine ayrılmış, arayış şeridi uyarı değil.
	var card := PanelContainer.new()
	card.theme_type_variation = &"CardCta"
	var head := HBoxContainer.new()
	head.add_theme_constant_override("separation", 10)
	head.add_child(UiFactory.make_avatar("A", 26))
	card.add_child(head)
	var info := VBoxContainer.new()
	info.add_theme_constant_override("separation", 2)
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info.add_child(UiFactory.make_label(
		UiTokens.tr_upper(HRConstants.search_agency_name()), &"SectionLabel"))
	head.add_child(info)

	if state == HRConstants.SEARCH_FILES_READY:
		info.add_child(UiFactory.make_label(
			tr("HR_FILES_ON_DESK").format({"n": HRSearchSystem.get_files().size()}), &"BodySerif"))
		head.add_child(HRUiShared.action_button(tr("HR_OPEN_FILES"), _open_atlas, true))
		return card

	# Arayış sürüyor: tek durum satırı — rol + dosyalara kalan hafta. "İade edilmez" uyarısı
	# ödeme ve iptal anında yaşıyor, bekleme şeridinde değil.
	var role_id: String = HRSearchSystem.current_role()
	var weeks: int = HRSearchSystem.weeks_until_arrival()
	info.add_child(UiFactory.make_label(tr(Fmt.count_key("HR_SEARCHING", weeks)).format({
		"role": HRConstants.role_label(role_id) if role_id != "" else tr("HR_CANDIDATE_GENERIC"),
		"n": weeks,
	}), &"BodySerif"))
	head.add_child(HRUiShared.action_button(tr("HR_SEARCH_CANCEL"), _on_cancel_search))
	return card


func _on_cancel_search() -> void:
	# İptal para yakmıyor (§10 — arama ücretsiz), BEKLENMİŞ ZAMANI yakıyor: yeni bir arayış
	# baştan bir hafta sürer. Onay bu yüzden isteniyor.
	EventBus.confirm_requested.emit({
		"title": tr("HR_SEARCH_CANCEL_TITLE"),
		"body": tr("HR_SEARCH_CANCEL_BODY").format({"span": tr("HR_ATLAS_ARRIVAL_SPAN")}),
		"confirm_text": tr("HR_SEARCH_CANCEL_OK"),
		"cancel_text": tr("UI_DISMISS"),
		"on_confirm": _do_cancel_search,
	})


func _do_cancel_search() -> void:
	HRSearchSystem.cancel_search()
	rebuild_view()


# --- Çalışma saatleri kontrolü (§13.2 / §8.5) --------------------------------

## Kenarlıklı, dolgusuz buton: İŞE ALIM BAŞLAT'ın bir tık sessizi (§13.2). Saat glifi +
## şirket penceresi; Kadro ve Görevler görünümlerinin ikisinde de görünür.
func _build_hours_control() -> Button:
	var btn := Button.new()
	btn.icon = load("res://assets/icons/clock.svg")
	btn.add_theme_constant_override("icon_max_width", 13)
	btn.add_theme_constant_override("h_separation", 8)
	btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	btn.pressed.connect(_open_hours_modal)
	return btn


## Metin ve renk AYNI koşuldan türer (§8.5): mesai ya da istisna varsa amber. Mesai varsa
## çalışan sayısı eklenir; yoksa ama kapsamlar şirketten ayrılıyorsa istisna sayısı. İkisi
## birden doğruysa mesai eki kazanır — para ve moral maliyeti orada.
func _paint_hours_control() -> void:
	var btn: Button = _hours_control
	# Pencere tek evden okunur (§15.2): modal ile çip aynı cümleyi çizmek zorunda.
	var win: Dictionary = WorkHoursSystem.company_window()
	var window: String = tr("HR_HOURS_WINDOW").format({
		"start": String(win["start_text"]),
		"end": String(win["end_text"]),
	})
	var over: int = int(WorkHoursSystem.counts()["overtime"])
	var exceptions: int = WorkHoursSystem.override_count()
	if over > 0:
		btn.text = tr("HR_HOURS_CHIP_OVERTIME").format({"window": window, "n": over})
	elif exceptions > 0:
		btn.text = tr("HR_HOURS_CHIP_OVERRIDES").format({"window": window, "n": exceptions})
	else:
		btn.text = window
	var flagged: bool = over > 0 or exceptions > 0
	var ink: Color = UiTokens.ACCENT_DEEP if flagged else UiTokens.INK_MUTED
	var edge: Color = UiTokens.ACCENT_DEEP if flagged else UiTokens.BORDER_HOVER
	btn.add_theme_color_override("font_color", ink)
	btn.add_theme_color_override("font_hover_color", UiTokens.INK)
	btn.add_theme_color_override("font_pressed_color", ink)
	btn.add_theme_color_override("icon_normal_color", ink)
	btn.add_theme_color_override("icon_hover_color", UiTokens.INK)
	for state in ["normal", "hover", "pressed", "focus"]:
		var sb := StyleBoxFlat.new()
		sb.bg_color = Color.TRANSPARENT
		sb.set_border_width_all(1)
		# Hover KENARDA yaşar, dolguda değil (Terminal reçetesi).
		sb.border_color = UiTokens.ACCENT_DEEP if state == "hover" else edge
		sb.set_corner_radius_all(2)
		sb.content_margin_left = 14
		sb.content_margin_right = 14
		sb.content_margin_top = 10
		sb.content_margin_bottom = 10
		btn.add_theme_stylebox_override(state, sb)


func _open_hours_modal() -> void:
	HRUiShared.mount_panel_modal(self, WORK_HOURS_MODAL, rebuild_view)


func _open_atlas() -> void:
	# Motorun arayış geçişleri için sinyali yok; modal haber veriyor.
	HRUiShared.mount_panel_modal(self, ATLAS_MODAL, _refresh)


# --- Kadro grupları ---------------------------------------------------------

## Bir kadro grubu (9b): amber başlık + hairline + satırlar.
func _add_group(group_id: String) -> void:
	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 10)
	header.add_child(UiFactory.make_label(
		UiTokens.tr_upper(HRConstants.group_label(group_id)), &"SectionAmber"))
	var rule := HRUiShared.hairline()
	rule.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rule.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	header.add_child(rule)
	_list.add_child(header)

	# get_employees(), get_active_employees() DEĞİL: defter izindeki ve eğitimdeki kişiyi de
	# gösterir — maaşı ödeniyor, yalnız o günkü kapasiteye girmiyor.
	var roster: Array[Character] = []
	for emp in CharacterRegistry.get_employees():
		if String(HRConstants.ROLE_GROUP.get(emp.role, "")) == group_id:
			roster.append(emp)
	if roster.is_empty():
		_list.add_child(HRLedger.empty_row(_open_atlas))
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
		_list.add_child(HRLedger.row(emp, _on_card_action, refs))
		_morale_refs[emp.id] = refs


# --- KADRO / GÖREVLER segmentleri ------------------------------------------

func _make_segment(label: String, view_id: String) -> Button:
	var btn := Button.new()
	btn.text = label
	btn.flat = true
	btn.focus_mode = Control.FOCUS_NONE
	btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	btn.pressed.connect(_show_view.bind(view_id))
	return btn


func _show_view(view_id: String) -> void:
	if _view == view_id:
		return
	_view = view_id
	rebuild_view()


## Aktif segment: INK + 2px amber alt kenar; öteki INK_DIM ve kenarsız (9b).
func _paint_segments() -> void:
	for pair in [[_seg_roster, VIEW_ROSTER], [_seg_assign, VIEW_ASSIGNMENTS]]:
		var btn: Button = pair[0]
		var active: bool = String(pair[1]) == _view
		var sb := StyleBoxFlat.new()
		sb.bg_color = Color.TRANSPARENT
		sb.border_width_bottom = UiTokens.BORDER_FOCUS if active else 0
		sb.border_color = UiTokens.ACCENT_DEEP
		sb.content_margin_left = 2.0
		sb.content_margin_right = 2.0
		sb.content_margin_top = 0.0
		sb.content_margin_bottom = 10.0
		for state in ["normal", "hover", "pressed", "focus"]:
			btn.add_theme_stylebox_override(state, sb)
		btn.add_theme_color_override("font_color", UiTokens.INK if active else UiTokens.INK_DIM)
		btn.add_theme_color_override("font_hover_color",
			UiTokens.INK if active else UiTokens.INK_MUTED)


## "N BOŞTA" (nötr) + "N AŞIRI YÜK" (amber). Sıfır olan çip çizilmez — sıfırı göstermek
## bir uyarıyı gürültüye çevirir.
func _paint_placement_chips() -> void:
	UiFactory.clear(_placement_chips)
	var idle: int = HRSystem.idle_count()
	if idle > 0:
		_placement_chips.add_child(UiFactory.make_state_chip(
			tr("HR_CHIP_IDLE_COUNT").format({"n": idle}),
			UiTokens.INK_DIM, Color.TRANSPARENT, UiTokens.CARD_BORDER))
	var over: int = 0
	for emp in CharacterRegistry.get_active_employees():
		if HRSystem.is_overloaded(emp):
			over += 1
	if over > 0:
		_placement_chips.add_child(UiFactory.make_state_chip(
			tr("HR_CHIP_OVERLOAD_COUNT").format({"n": over}),
			UiTokens.ACCENT_DEEP, UiTokens.AMBER_BG, UiTokens.ACCENT_DEEP))


## Kaçma riski başına bir kırmızı şerit: ad + MORAL n. Eşik motorun
## (HRConstants.is_flight_risk).
func _paint_attention_strip() -> void:
	UiFactory.clear(_attention_strip)
	for emp in CharacterRegistry.get_employees():
		if not HRConstants.is_flight_risk(emp.morale):
			continue
		var strip := PanelContainer.new()
		strip.theme_type_variation = &"AttentionStrip"
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 10)
		row.add_child(HRUiShared.warning_glyph(13, UiTokens.negative()))
		row.add_child(UiFactory.make_label(emp.character_name, &"RowName"))
		row.add_child(UiFactory.make_label(
			"%s %d" % [UiTokens.tr_upper(tr("HR_COL_MORALE")), emp.morale],
			&"RowName", UiTokens.negative()))
		strip.add_child(row)
		_attention_strip.add_child(strip)
	_attention_strip.visible = _attention_strip.get_child_count() > 0


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
	match action:
		HRLedger.ACTION_MENU:
			_open_actions(emp, anchor)
		HRLedger.ACTION_DOSSIER:
			get_tree().call_group(&"window_layer", &"open_detail", "hr_dossier", {"character_id": emp.id})
		_:
			HRLedger.run_action(self, emp, action)


# --- Satır aksiyon menüsü (9e) ---------------------------------------------

func _open_actions(emp: Character, anchor: Control) -> void:
	var pop: HRPopover = HRPopover.mount(self)
	if pop == null:
		return
	var body: VBoxContainer = pop.body()
	body.add_theme_constant_override("separation", 0)

	var head := VBoxContainer.new()
	head.add_theme_constant_override("separation", 2)
	head.add_child(UiFactory.make_label(emp.character_name, &"RowName"))
	head.add_child(UiFactory.make_label(
		UiTokens.tr_upper(HRConstants.role_label(emp.role)), &"MicroLabel"))
	body.add_child(head)
	body.add_child(HRUiShared.hairline())
	body.add_child(HRLedger.action_list(emp, func(act: String) -> void:
		pop.close()
		HRLedger.run_action(self, emp, act)))

	pop.open_at(anchor)


## Yapı anahtarını geçersiz kılıp tam yeniden kurar. set_salary ve set_status sinyal
## atmadığı için aksiyon sonrası tazeleme buradan tetikleniyor (HRLedger.VIEWS_GROUP).
func rebuild_view() -> void:
	_structure_key = ""
	_refresh()
