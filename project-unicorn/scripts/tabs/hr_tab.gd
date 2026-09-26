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
# şeridi bir gün geride, gelen dosyalar bir gün görünmez).
#
# Bu dosya hiçbir sonucu hesaplamaz: her rakam bir motor çağrısından gelir. Tek istisna
# BİÇİMLEME: kesir → yüzde ve float → int yuvarlaması.
# ============================================================================

const ATLAS_MODAL := "res://scenes/modals/HRAtlasModal.tscn"
const TRAINING_MODAL := "res://scenes/modals/TrainingModal.tscn"
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
var _header_slot: VBoxContainer = null   # başlığın evi; içeriği her kurulumda tazelenir
# Satır başına yerinde-repaint referansları: emp.id → {"bar":…, "value":…}
var _morale_refs: Dictionary = {}


func _ready() -> void:
	# Defterin sütun genişlikleri mantıksal viewport'a göre seçiliyor ve oyuncu ölçeği
	# Ayarlar'dan değiştirince viewport yeniden boyutlanıyor; tek seferlik ölçüm bayatlardı.
	get_viewport().size_changed.connect(_on_viewport_resized)
	_build_chrome()
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
	_rebuild_forced()


# --- Sayfa kromu ------------------------------------------------------------

func _build_chrome() -> void:
	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	for side in ["margin_left", "margin_right", "margin_top", "margin_bottom"]:
		margin.add_theme_constant_override(side, 16)
	add_child(margin)
	var outer := VBoxContainer.new()
	outer.add_theme_constant_override("separation", 10)
	margin.add_child(outer)

	# Başlık satırı: Ekip + özet + yerleşim çipleri · sağda saat kontrolü + İŞE ALIM BAŞLAT.
	var head := HBoxContainer.new()
	head.add_theme_constant_override("separation", 14)
	head.alignment = BoxContainer.ALIGNMENT_CENTER
	head.add_child(UiFactory.make_label(tr("HR_PAGE_TITLE"), &"PageTitleSerif"))
	_summary = UiFactory.make_label("", &"TitleRowSummary")
	# Özet yer verir, CTA vermez: dar viewport'ta uzun özet cümlesi kısalır, eylem
	# düğmesi ekran dışına itilmez.
	_summary.clip_text = true
	_summary.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	_summary.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_summary.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	head.add_child(_summary)
	_placement_chips = HBoxContainer.new()
	_placement_chips.add_theme_constant_override("separation", UiTokens.SPACE_S)
	_placement_chips.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	head.add_child(_placement_chips)
	var head_spacer := Control.new()
	head_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(head_spacer)
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

	# Sütun başlıkları kaydırma alanının DIŞINDA (sayfa kayarken görünür kalır) ve bir
	# slot'ta: kademe değiştiğinde satırlar gibi başlık da yeniden kurulmalı, yoksa bayat
	# asgari genişliği sayfanın asgarisi olur.
	_header_slot = VBoxContainer.new()
	_header_slot.add_theme_constant_override("separation", 0)
	outer.add_child(_header_slot)

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
		"payroll": HRUiShared.money(CharacterRegistry.get_total_monthly_salaries()),
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
	# geçildiğinde satırın sırası güncellenmez.
	var parts := PackedStringArray()
	parts.append("%s|%d" % [HRSearchSystem.get_state(), HRSearchSystem.days_waiting()])
	# DURUM sütunundaki saat istisnası etiketi bu iki sayıyı okuyor (§8.5, §13.3).
	parts.append("wh%d|%d" % [GameState.company_work_hours, WorkHoursSystem.override_count()])
	# MT'nin taşıdığı hesap sayısı satırın şeklinin parçası.
	for rep in CharacterRegistry.get_active_by_role(HRConstants.ROLE_CUSTOMER_REP):
		parts.append("cs%s%d" % [rep.id, CustomerRepSystem.roster_size(rep.id)])
	for emp in CharacterRegistry.get_employees():
		parts.append("%s|%s|%d|%d" % [emp.id, emp.status, emp.monthly_salary,
			HRUiShared.worst_badge_severity(emp)])
	return "/".join(parts)


func _rebuild() -> void:
	_structure_key = _compute_structure_key()
	_morale_refs.clear()
	ProductUiShared.clear(_list)

	_paint_placement_chips()
	_paint_attention_strip()
	_paint_segments()

	# Başlık ve satırlar AYNI ölçümü okumalı: `column_header()` genişlikleri HRLedger'ın
	# statiklerinden okuyor, o yüzden ölçüm kurulumdan önce.
	HRLedger.measure(get_viewport_rect().size.x)
	ProductUiShared.clear(_header_slot)
	_header_slot.add_child(HRLedger.column_header())
	_header_slot.visible = _view == VIEW_ROSTER
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

	# Arayış sürüyor: tek durum satırı — rol + kaçıncı gün. "İade edilmez" uyarısı ödeme ve
	# iptal anında yaşıyor, bekleme şeridinde değil.
	var role_id: String = HRSearchSystem.current_role()
	info.add_child(UiFactory.make_label(tr("HR_SEARCHING").format({
		"role": HRConstants.role_label(role_id) if role_id != "" else tr("HR_CANDIDATE_GENERIC"),
		"n": HRSearchSystem.days_waiting(),
	}), &"BodySerif"))
	head.add_child(HRUiShared.action_button(tr("HR_SEARCH_CANCEL"), _on_cancel_search))
	return card


func _on_cancel_search() -> void:
	# İptal para yakmıyor (§10 — arama ücretsiz), BEKLENMİŞ GÜNLERİ yakıyor: yeni bir arayış
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
	_rebuild_forced()


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
	var ink: Color = UiTokens.ACCENT if flagged else UiTokens.INK_MUTED
	var edge: Color = UiTokens.ACCENT if flagged else UiTokens.BORDER_HOVER
	btn.add_theme_color_override("font_color", ink)
	btn.add_theme_color_override("font_hover_color", UiTokens.INK)
	btn.add_theme_color_override("font_pressed_color", ink)
	btn.add_theme_color_override("icon_normal_color", ink)
	btn.add_theme_color_override("icon_hover_color", UiTokens.INK)
	for state in ["normal", "hover", "pressed", "focus"]:
		var sb := StyleBoxFlat.new()
		sb.bg_color = Color(0, 0, 0, 0)
		sb.set_border_width_all(1)
		# Hover KENARDA yaşar, dolguda değil (Terminal reçetesi).
		sb.border_color = UiTokens.ACCENT_HOVER if state == "hover" else edge
		sb.set_corner_radius_all(2)
		sb.content_margin_left = 14
		sb.content_margin_right = 14
		sb.content_margin_top = 10
		sb.content_margin_bottom = 10
		btn.add_theme_stylebox_override(state, sb)


## PanelLayer, ModalLayer DEĞİL: ModalLayer boşluk ve 1-4 hız tuşlarını yutuyor ve dimmer'ı
## TopBar'ı kaplıyor — saat bir kadro kararının üstünde akarken oyuncunun onu durduracak
## yolu kalmazdı. Gerçek bir modal (layer 10) hâlâ üstünü örter.
func _mount_panel_modal(path: String, on_changed: Callable, args: Array = []) -> void:
	var layer: Node = get_tree().get_root().find_child("PanelLayer", true, false)
	if layer == null:
		push_error("[HRTab] GameShell/PanelLayer yok — modal monte edilemiyor: %s" % path)
		return
	var modal: Node = (load(path) as PackedScene).instantiate()
	layer.add_child(modal)   # önce add_child, sonra populate (ev konvansiyonu)
	modal.connect("state_changed", on_changed)
	modal.callv("populate", args)


func _open_hours_modal() -> void:
	_mount_panel_modal(WORK_HOURS_MODAL, _rebuild_forced)


func _open_atlas() -> void:
	# Motorun arayış geçişleri için sinyali yok; modal haber veriyor.
	_mount_panel_modal(ATLAS_MODAL, _refresh)


## Alan seçimini oyuncu yapıyor (§5.2), o yüzden onay kutusu değil eğitim modalı.
func _confirm_training(emp: Character) -> void:
	_mount_panel_modal(TRAINING_MODAL, _rebuild_forced, [emp.id])


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

	# get_employees(), get_active_by_role() DEĞİL: defter izindeki ve eğitimdeki kişiyi de
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
	_rebuild_forced()


## Aktif segment: INK + 2px amber alt kenar; öteki INK_DIM ve kenarsız (9b).
func _paint_segments() -> void:
	for pair in [[_seg_roster, VIEW_ROSTER], [_seg_assign, VIEW_ASSIGNMENTS]]:
		var btn: Button = pair[0]
		var active: bool = String(pair[1]) == _view
		var sb := StyleBoxFlat.new()
		sb.bg_color = Color(0, 0, 0, 0)
		sb.border_width_bottom = UiTokens.BORDER_FOCUS if active else 0
		sb.border_color = UiTokens.ACCENT
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
	ProductUiShared.clear(_placement_chips)
	var idle: int = HRSystem.idle_count()
	if idle > 0:
		_placement_chips.add_child(UiFactory.make_state_chip(
			tr("HR_CHIP_IDLE_COUNT").format({"n": idle}),
			UiTokens.INK_DIM, Color(0, 0, 0, 0), UiTokens.SEPARATOR))
	var over: int = 0
	for emp in CharacterRegistry.get_active_employees():
		if HRSystem.is_overloaded(emp):
			over += 1
	if over > 0:
		_placement_chips.add_child(UiFactory.make_state_chip(
			tr("HR_CHIP_OVERLOAD_COUNT").format({"n": over}),
			UiTokens.ACCENT, UiTokens.AMBER_BG, UiTokens.ACCENT))


## Kaçma riski başına bir kırmızı şerit: ad + MORAL n. Eşik motorun
## (HRConstants.is_flight_risk).
func _paint_attention_strip() -> void:
	ProductUiShared.clear(_attention_strip)
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
	_rebuild_forced()


func _on_card_action(emp_id: String, action: String, anchor: Control) -> void:
	var emp: Character = CharacterRegistry.get_character(emp_id)
	if emp == null:
		return
	match action:
		HRLedger.ACTION_MENU:
			_open_actions(emp, anchor)
		HRLedger.ACTION_RAISE:
			_open_raise(emp)
		HRLedger.ACTION_FIRE:
			_confirm_fire(emp)
		HRLedger.ACTION_TRAIN:
			_confirm_training(emp)
		HRLedger.ACTION_PROMOTE:
			_open_promotion(emp)


# --- Satır aksiyon menüsü (9e) ---------------------------------------------

func _open_actions(emp: Character, anchor: Control) -> void:
	# Kapalı satırın gerekçesi preview_*'ın `reason` anahtarından okunur: can_* yalnız bool döner.
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

	# Sağdaki meta her satırın SONUCUNU söylüyor (mevcut maaş · unvan · süre · kalıcı).
	for spec in [
			{"key": "HR_CARD_RAISE", "preview": HRActions.preview_raise(emp, HRConstants.RAISE_MIN_PCT),
				"action": HRLedger.ACTION_RAISE,
				"meta": HRUiShared.money(emp.monthly_salary)},
			# §13.3: kilitli hâli görünür kalır ve gerekçesini gösterir.
			{"key": "HR_CARD_PROMOTE",
				"preview": {"ok": HRActions.can_promote(emp),
					"reason": HRActions.promotion_block_reason(emp)},
				"action": HRLedger.ACTION_PROMOTE,
				"meta": HRConstants.job_title(emp.role, emp.level)},
			# §5.4 iki gerekçe: bar dolmadı ya da alan tavanda — metni registry seçer.
			{"key": "HR_TRAINING_PICK_TITLE",
				"preview": {"ok": CharacterRegistry.can_train(emp.id),
					"reason": CharacterRegistry.training_block_reason(emp.id)},
				"action": HRLedger.ACTION_TRAIN,
				"meta": HRConstants.training_duration_text()},
			{"key": "HR_CARD_FIRE", "preview": HRActions.preview_fire(emp),
				"action": HRLedger.ACTION_FIRE,
				"meta": tr("HR_MENU_PERMANENT")}]:
		# Yıkıcı eylem ayrı bölümde: İşten çıkar'ın önüne hairline.
		if String(spec["action"]) == HRLedger.ACTION_FIRE:
			body.add_child(HRUiShared.hairline())
		body.add_child(_menu_row(pop, emp, spec, anchor))

	pop.open_at(anchor)


## 46px ritim, 16px iç boşluk, sağda meta, hover'da 2px amber sol kenar + %5 zemin;
## devre dışıysa kilit glifi + gerekçe.
func _menu_row(pop: HRPopover, emp: Character, spec: Dictionary, anchor: Control) -> Control:
	var preview: Dictionary = spec["preview"]
	var ok: bool = bool(preview.get("ok", false))
	var reason: String = String(preview.get("reason", ""))

	var btn := Button.new()
	btn.flat = true
	btn.focus_mode = Control.FOCUS_NONE
	btn.custom_minimum_size = Vector2(0, 46)
	btn.disabled = not ok
	if ok:
		btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		var act: String = String(spec["action"])
		btn.pressed.connect(func() -> void:
			pop.close()
			_on_card_action(emp.id, act, anchor))
	else:
		btn.tooltip_text = reason
	var flat_sb := StyleBoxEmpty.new()
	flat_sb.content_margin_left = 16.0
	flat_sb.content_margin_right = 16.0
	var hover_sb := StyleBoxFlat.new()
	hover_sb.bg_color = Color(1, 1, 1, 0.05)
	hover_sb.border_width_left = 2
	hover_sb.border_color = UiTokens.ACCENT
	hover_sb.content_margin_left = 14.0
	hover_sb.content_margin_right = 16.0
	btn.add_theme_stylebox_override("normal", flat_sb)
	btn.add_theme_stylebox_override("disabled", flat_sb)
	btn.add_theme_stylebox_override("hover", hover_sb if ok else flat_sb)
	btn.add_theme_stylebox_override("pressed", hover_sb if ok else flat_sb)

	var row := HBoxContainer.new()
	row.set_anchors_preset(Control.PRESET_FULL_RECT)
	row.add_theme_constant_override("separation", UiTokens.SPACE_L)
	row.offset_left = 16
	row.offset_right = -16
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	# Açık satırda glif saydam kalır: etiketler kilitli satırlarla aynı hizada durur.
	row.add_child(HRUiShared.lock_glyph(13, UiTokens.INK_FAINT if not ok else Color(0, 0, 0, 0)))
	var label_col := VBoxContainer.new()
	label_col.add_theme_constant_override("separation", 1)
	label_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label_col.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	label_col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label_col.add_child(UiFactory.make_label(tr(String(spec["key"])), &"RowName",
		UiTokens.INK if ok else UiTokens.INK_DIM))
	if not ok and reason != "":
		label_col.add_child(UiFactory.make_label(reason, &"RowMeta", UiTokens.INK_FAINT))
	row.add_child(label_col)
	var meta: String = String(spec.get("meta", ""))
	if meta != "":
		var meta_lbl := UiFactory.make_label(meta, &"RowMeta", UiTokens.INK_DIM)
		meta_lbl.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		meta_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.add_child(meta_lbl)
	btn.add_child(row)
	return btn


# --- Zam / terfi / çıkarma (§14 aksiyon kabuğu) -----------------------------

func _open_raise(emp: Character) -> void:
	if not bool(HRActions.preview_raise(emp, HRConstants.RAISE_MIN_PCT).get("ok", false)):
		return
	EventBus.confirm_requested.emit({
		"modal": "hr_action",
		"title": tr("HR_CARD_RAISE"),   # başlıkta yalnız eylem, ad yok
		"commit_key": "HR_APPLY_RAISE_PCT",
		"slider": {"min": HRConstants.RAISE_MIN_PCT, "max": HRConstants.RAISE_MAX_PCT,
			"start": HRConstants.RAISE_MIN_PCT},
		"preview": _preview_raise.bind(emp),
		"on_commit": _do_raise.bind(emp.id),
	})


## §9.3: zam ile aynı kabuk; fark bir SEVİYE atlaması olması — unvan da bir delta satırı.
## Minimum %10, yani slider "terfi ettim ama zam almadım"a inmez.
func _open_promotion(emp: Character) -> void:
	if not HRActions.can_promote(emp):
		return
	EventBus.confirm_requested.emit({
		"modal": "hr_action",
		"title": tr("HR_CARD_PROMOTE"),
		"commit_key": "HR_APPLY_PROMOTE_PCT",
		"slider": {"min": HRConstants.PROMOTION_MIN_PCT, "max": HRConstants.PROMOTION_MAX_PCT,
			"start": HRConstants.PROMOTION_MIN_PCT},
		"preview": _preview_promotion.bind(emp),
		"on_commit": _do_promotion.bind(emp.id),
	})


func _preview_promotion(pct: int, emp: Character) -> Dictionary:
	return HRActions.preview_promotion(emp, pct)


func _do_promotion(pct: int, emp_id: String) -> bool:
	var emp: Character = CharacterRegistry.get_character(emp_id)
	if emp == null or not HRActions.apply_promotion(emp, pct):
		return false
	_rebuild_forced()
	return true


func _preview_raise(pct: int, emp: Character) -> Dictionary:
	return HRActions.preview_raise(emp, pct)


func _do_raise(pct: int, emp_id: String) -> bool:
	var emp: Character = CharacterRegistry.get_character(emp_id)
	if emp == null or not HRActions.apply_raise(emp, pct):
		return false
	_rebuild_forced()
	return true


func _confirm_fire(emp: Character) -> void:
	var pv: Dictionary = HRActions.preview_fire(emp)
	if not bool(pv.get("ok", false)):
		return
	EventBus.confirm_requested.emit({
		"modal": "hr_action",
		"title": tr("HR_CARD_FIRE"),
		"rows": pv.get("rows", []),
		"commit_text": tr("HR_FIRE_CONFIRM_OK"),
		"on_commit": _do_fire.bind(emp.id),
	})


## `_pct`: modal her eyleme tek imzayla döner; çıkarmanın slider'ı yok ve sıfır gönderiliyor.
func _do_fire(_pct: int, emp_id: String) -> bool:
	var emp: Character = CharacterRegistry.get_character(emp_id)
	if emp == null or not HRActions.fire(emp):
		return false
	_rebuild_forced()
	return true


## Yapı anahtarını geçersiz kılıp tam yeniden kurar. set_salary ve set_status sinyal
## atmadığı için aksiyon sonrası tazeleme buradan tetikleniyor.
func _rebuild_forced() -> void:
	_structure_key = ""
	_refresh()


func _on_viewport_resized() -> void:
	if not is_inside_tree():
		return
	var was_dense: bool = HRLedger._dense
	HRLedger.measure(get_viewport_rect().size.x)
	if HRLedger._dense != was_dense:
		_rebuild_forced()   # yalnız kademe değiştiyse: her pikselde tabloyu kurmayız
