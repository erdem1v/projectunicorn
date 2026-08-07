extends Control

# ============================================================================
# Ekip sayfası — HR sekmesi (Kare 1 anatomisi).
#
# Kod-kurulu düzen, boş .tscn kökü (Product Rev3 idiomu): departman/alt bölüm
# bölümleri dinamik, bu yüzden .tscn'de iskelet tutmak yarar sağlamıyor.
# Router YOK — sayfa tek görünüm; Atlas bir modal, aksiyonlar birer popover.
#
# TAZELEME MODELİ (portfolio_view'ın yapı-anahtarı deseni): ucuz bir anahtar
# (kadro id'leri + statüleri + arayış hali + mesai hali + açık kart) yeniden-kurma
# ile yerinde-güncelleme arasında karar verir. Böylece morale_changed tek bir barı
# yeniden boyar, bütün kartları serbest bırakmaz.
#
# GÜN SINIRI: day_advanced'e DEĞİL, hr_day_processed'a bağlanır. day_advanced
# GameState.advance_day() içinde, TimeManager günlük tick'leri dağıtmadan ÖNCE
# atılıyor — oraya bağlanan bir tazeleme HR durumunu tick'ten ÖNCE okur (Atlas
# şeridi bir gün geride, gelen dosyalar bir gün görünmez). Bu, build tracker için
# build_progress_changed'in eklenmesine yol açan tuzağın aynısı.
#
# Bu dosya hiçbir sonucu hesaplamaz: her rakam bir motor çağrısından gelir. Tek istisna
# BİÇİMLEME: kesir → yüzde ve float → int yuvarlaması (ör. average_morale'in float'ı).
#
# # WORKING TR — bu dosyadaki tüm oyuncuya görünen metin çalışma metnidir; ses geçişi
# (voice pass) sonra. Tasarım dokümanında karşılığı olan ifadeler onun sözcükleriyle.
# ============================================================================

const ATLAS_MODAL := "res://scenes/modals/HRAtlasModal.tscn"

var _signals: Array = []
var _list: VBoxContainer = null
var _summary: Label = null
var _footer: Label = null
var _structure_key: String = ""
var _expanded_id: String = ""
# Kart başına yerinde-repaint referansları: emp.id → {"bar":…, "value":…}
var _morale_refs: Dictionary = {}


func _ready() -> void:
	_build_chrome()
	# Sinyal listesi tek yerden bağlanır/çözülür (sales_tab deseni). Kadroyu, morali,
	# arayışı, parayı ve gün sınırını kapsar; mesai ve arayış durumu için sinyal YOK
	# (motorda yok — done mesajında raporlanıyor), onları hr_day_processed ve aksiyon
	# sonrası yerel tazeleme taşıyor.
	_signals = [
		EventBus.character_added, EventBus.character_removed, EventBus.morale_changed,
		EventBus.headline_added, EventBus.cash_changed, EventBus.burn_changed,
		EventBus.runway_recalculated, EventBus.hr_day_processed,
		# The MT card shows a live account count, so a stewardship change has to repaint it —
		# otherwise the number sits stale until some unrelated HR signal happens to fire.
		EventBus.customer_assigned,
	]
	for sig in _signals:
		sig.connect(_on_state_changed)
	_refresh()


func _exit_tree() -> void:
	for sig in _signals:
		if sig.is_connected(_on_state_changed):
			sig.disconnect(_on_state_changed)


# Üç opsiyonel parametre: 0/1/2 argümanlı sinyaller aynı işleyiciye bağlanabilsin.
func _on_state_changed(_a = null, _b = null, _c = null) -> void:
	_refresh()


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

	# Başlık satırı: Ekip + özet · sağda EĞİTİM · KİLİTLİ telgrafı + ARAYIŞ BAŞLAT
	var head := HBoxContainer.new()
	head.add_theme_constant_override("separation", 12)
	var title_col := VBoxContainer.new()
	title_col.add_theme_constant_override("separation", 2)
	title_col.add_child(UiFactory.make_label("Ekip", &"TitleSerif"))
	_summary = UiFactory.make_label("", &"CaptionMuted")
	title_col.add_child(_summary)
	title_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(title_col)
	head.add_child(HRUiShared.locked_telegraph("Eğitim · Kilitli"))
	head.add_child(HRUiShared.action_button("+ ARAYIŞ BAŞLAT", _open_atlas, true))
	outer.add_child(head)
	outer.add_child(HRUiShared.hairline())

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	outer.add_child(scroll)
	_list = VBoxContainer.new()
	_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_list.add_theme_constant_override("separation", 10)
	scroll.add_child(_list)

	outer.add_child(HRUiShared.hairline())
	_footer = UiFactory.make_label("", &"SectionLabel")
	outer.add_child(_footer)


# --- Tazeleme ---------------------------------------------------------------

func _refresh() -> void:
	if _list == null:
		return
	# Başlık VE alt şerit her tazelemede: alt şerit ORTALAMA MORAL yazıyor, yani yapı
	# değişmeden de oynayan bir sayı. Yalnız _rebuild'de boyanınca morale_changed'in
	# yerinde-güncelleme yolunda bayat kalıyordu.
	_paint_summary()
	_paint_footer()
	if _structure_key != _compute_structure_key():
		_rebuild()
		return
	# Yapı aynı: yalnız moral barları/sayıları tazelenir.
	for emp in CharacterRegistry.get_employees():
		if _morale_refs.has(emp.id):
			HRUiShared.repaint_morale(_morale_refs[emp.id], emp.morale)


func _compute_structure_key() -> String:
	# Kart KÜMESİNİ ve kartların şeklini değiştiren her şey buraya girer; moral
	# GİRMEZ (yerinde boyanır). Rozet ağırlığı moralle değiştiği için ayrıca yazılıyor,
	# yoksa TÜKENİYOR eşiği geçildiğinde kartın çerçevesi ve sırası güncellenmez.
	var parts := PackedStringArray()
	parts.append("%s|%d|%s" % [HRSearchSystem.get_state(),
		HRSearchSystem.days_waiting(), _expanded_id])
	for dept_id in HRConstants.DEPARTMENTS:
		parts.append("%s%d" % [dept_id, HROvertimeSystem.day_index(String(dept_id))])
	# Bir MT'nin taşıdığı hesap sayısı kartın ÜSTÜNDE yazıyor, yani kart şeklinin parçası.
	# Anahtara girmezse atama değişince satır bayat kalır (moral gibi yerinde boyanan bir
	# şey değil — kart yeniden kurulmalı).
	for rep in CharacterRegistry.get_active_by_role(HRConstants.ROLE_CUSTOMER_REP):
		parts.append("cs%s%d" % [rep.id, CustomerRepSystem.roster_size(rep.id)])
	for emp in CharacterRegistry.get_employees():
		parts.append("%s|%s|%d|%d" % [emp.id, emp.status, emp.monthly_salary,
			HRUiShared.worst_badge_severity(emp)])
	return "/".join(parts)


func _rebuild() -> void:
	_structure_key = _compute_structure_key()
	_morale_refs.clear()
	for c in _list.get_children():
		_list.remove_child(c)
		c.queue_free()

	# Atlas şeridi (Kare 3 bekleme / dosyalar hazır) en üstte.
	var strip: Control = _atlas_strip()
	if strip != null:
		_list.add_child(strip)

	for dept_id in HRConstants.DEPARTMENTS:
		_add_department(String(dept_id))

	_paint_footer()


func _paint_summary() -> void:
	if _summary == null:
		return
	# Yalnız alt şeritte OLMAYAN bilgiler (bilgi-tekrarı kuralı: her bilgi bir kez) —
	# çalışan sayısı ve maaş yükü alt şeridin işi; buradaki iki sayı dikkat çağrısı.
	# Dikkat sayısı attention_PEOPLE_count: sol raydaki rozet bekleyen aday dosyasını da
	# sayar, ama bu cümle EKİP hakkında, ve dosyaların kendi şeridi var — ikisini aynı
	# sayıda toplamak yalan olurdu.
	var parts := PackedStringArray()
	var on_leave: int = CharacterRegistry.count_on_leave()
	if on_leave > 0:
		parts.append("%d izinde" % on_leave)
	var attention: int = HRSystem.attention_people_count()
	if attention > 0:
		parts.append("%d dikkat gerektiriyor" % attention)
	_summary.text = " · ".join(parts)
	_summary.visible = not parts.is_empty()


func _paint_footer() -> void:
	if _footer == null:
		return
	_footer.text = UiTokens.tr_upper("Çalışan %d · Ortalama moral %d · Aylık maaş yükü %s" % [
		CharacterRegistry.count_employees(),
		int(round(HRMoraleSystem.average_morale())),
		HRUiShared.money(CharacterRegistry.get_total_monthly_salaries()),
	])


# --- Atlas şeridi (Kare 3) --------------------------------------------------

func _atlas_strip() -> Control:
	var state: String = HRSearchSystem.get_state()
	if state == HRConstants.SEARCH_IDLE:
		return null
	# CardCta: şeffaf zemin + amber çerçeve. Mockup Kare 3'ün amber vurgusu bu; CardAttention
	# (tozlu pembe) kaçma riskine ayrılmış durumda ve arayış şeridi bir UYARI değil.
	var card := PanelContainer.new()
	card.theme_type_variation = &"CardCta"
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 6)
	card.add_child(col)

	var head := HBoxContainer.new()
	head.add_theme_constant_override("separation", 10)
	head.add_child(UiFactory.make_avatar("A", 26))
	var info := VBoxContainer.new()
	info.add_theme_constant_override("separation", 2)
	info.add_child(UiFactory.make_label(
		UiTokens.tr_upper(HRConstants.SEARCH_AGENCY_NAME), &"SectionLabel"))
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	if state == HRConstants.SEARCH_FILES_READY:
		info.add_child(UiFactory.make_label(
			"%d aday dosyası masada." % HRSearchSystem.get_files().size(), &"BodySerif"))
		head.add_child(info)
		head.add_child(HRUiShared.action_button("DOSYALARI AÇ", _open_atlas, true))
		col.add_child(head)
		return card

	# Arayış sürüyor: TEK durum satırı (bilgi-tekrarı kuralı) — rol + kaçıncı gün. Bant
	# oyuncunun verilmiş kararı, burada tekrarlanmaz; "iade edilmez" uyarısı ödeme anında
	# (modal ücret bloğu) ve kayıp anında (iptal onayı) yaşıyor, bekleme şeridinde değil.
	# Rol HRSearchSystem accessor'ından; GameState.hr_search sözlüğüne UI'dan uzanmak o
	# sözlüğün sahibini atlamak olurdu.
	var role_id: String = HRSearchSystem.current_role()
	var line: String = "%s aranıyor · %d. gün" % [
		HRConstants.role_label(role_id) if role_id != "" else "Aday",
		HRSearchSystem.days_waiting(),
	]
	info.add_child(UiFactory.make_label(line, &"BodySerif"))
	head.add_child(info)
	head.add_child(HRUiShared.action_button("ARAYIŞI İPTAL ET", _on_cancel_search))
	col.add_child(head)
	return card


func _on_cancel_search() -> void:
	# İptalin önizlemesi yok (motorda preview_cancel_search bulunmuyor — raporlanıyor),
	# ama peşin ücreti yakıyor, o yüzden onay isteniyor. on_confirm bağlı METOT referansı
	# (creation_flow'un confirm şekli) — sözlük içine çok satırlı lambda gömülmüyor.
	EventBus.confirm_requested.emit({
		"title": "Arayışı iptal et",
		"body": "Atlas arayışı kapanır. Peşin ödenen %s iade edilmez." % HRUiShared.money(
			HRConstants.SEARCH_RETAINER),
		"confirm_text": "İptal et",
		"cancel_text": "Vazgeç",
		"on_confirm": _do_cancel_search,
	})


func _do_cancel_search() -> void:
	HRSearchSystem.cancel_search()
	_rebuild_forced()


# --- Departman bölümleri ---------------------------------------------------

func _add_department(dept_id: String) -> void:
	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 10)
	header.add_child(HRUiShared.section_header(
		HRConstants.department_label(dept_id), false))
	var rule := HRUiShared.hairline()
	rule.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rule.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	header.add_child(rule)
	# EK MESAİ yalnız başlatılabilir ya da hâlihazırda çalışan bir blok varken görünür:
	# kadrosu boş bir departmanda buton ölü bir aksiyon olurdu (panel dürüst bir cümle
	# gösteriyor ama tıklanacak şey olmaması daha temiz). Karar motorun: can_start.
	if HROvertimeSystem.can_start(dept_id) or HROvertimeSystem.is_active(dept_id):
		header.add_child(_overtime_control(dept_id))
	_list.add_child(header)

	var sections: Array = HRConstants.section_ids_in_department(dept_id)
	if sections.is_empty():
		# Tek seviyeli departman (Satış, Müşteri): kartlar doğrudan ana başlığın altında.
		_add_roster(CharacterRegistry.get_in_department(dept_id), dept_id)
		return
	for section_id in sections:
		var sub := HBoxContainer.new()
		sub.add_theme_constant_override("separation", 8)
		var pad := Control.new()
		pad.custom_minimum_size = Vector2(14, 0)
		sub.add_child(pad)
		sub.add_child(HRUiShared.section_header(
			HRConstants.section_label(String(section_id)), true))
		_list.add_child(sub)
		_add_roster(CharacterRegistry.get_in_section(String(section_id)), dept_id)


func _add_roster(roster: Array[Character], dept_id: String) -> void:
	if roster.is_empty():
		_list.add_child(_empty_row(dept_id))
		return
	# Dikkat isteyen satırlar üste (sales_tab'ın grameri). Ağırlık motorun registry'sinde;
	# burada sıralanıyor, karar verilmiyor.
	# TAM SIRALAMA ŞART: sort_custom kararlı DEĞİL ve çoğu çalışanın ağırlığı 0 — yalnız
	# ağırlığa bakan bir karşılaştırıcı eşit anahtarları her yeniden kurmada farklı sırada
	# bırakabilir, yani kartlar her gün sınırında yer değiştirir. hire_day (sonra id) ile
	# kesin bir tiebreak veriliyor: sıra deterministik, göz sabit.
	var sorted: Array[Character] = roster.duplicate()
	sorted.sort_custom(func(a: Character, b: Character) -> bool:
		var sa: int = HRUiShared.worst_badge_severity(a)
		var sb: int = HRUiShared.worst_badge_severity(b)
		if sa != sb:
			return sa > sb
		if a.hire_day != b.hire_day:
			return a.hire_day < b.hire_day
		return a.id < b.id)
	for emp in sorted:
		var refs: Dictionary = {}
		_list.add_child(HREmployeeCard.build(emp, _on_card_action, emp.id == _expanded_id, refs))
		_morale_refs[emp.id] = refs


func _empty_row(_dept_id: String) -> Control:
	var card := PanelContainer.new()
	card.theme_type_variation = &"CardPanelTight"
	card.modulate = Color(1, 1, 1, 0.6)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	var lbl := UiFactory.make_label("Henüz kimse yok", &"RowMeta")
	lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lbl.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(lbl)
	row.add_child(HRUiShared.action_button("ARAYIŞ BAŞLAT", _open_atlas))
	card.add_child(row)
	return card


func _overtime_control(dept_id: String) -> Control:
	# Aktifken şerit ("EK MESAİ · N. GÜN"), değilken aksiyon butonu. İkisi de aynı
	# paneli açıyor; panel aktif blokta DURDUR gösteriyor (erken durdurma).
	var anchor_label: String = "EK MESAİ"
	if HROvertimeSystem.is_active(dept_id):
		anchor_label = "EK MESAİ · %d. GÜN" % HROvertimeSystem.day_index(dept_id)
	var btn := Button.new()
	btn.text = anchor_label
	btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	if HROvertimeSystem.is_active(dept_id):
		btn.theme_type_variation = &"CommitButton"
	btn.pressed.connect(func() -> void: _open_overtime(dept_id, btn))
	return btn


# --- Akışlar ---------------------------------------------------------------

func _open_atlas() -> void:
	# PanelLayer, ModalLayer DEĞİL. Atlas kendi başlığında "saati durdurmaz" diyor ve bu
	# bir sekme SAYFASI için doğru — ama ModalLayer'ın içindeyken tam tersi oluyordu:
	# game_shell'in 2. bekçisi ModalLayer boş değilken Space ve 1-4'ü yutuyor, dimmer de
	# TopBar'ı kaplayıp hız düğmelerini tıklanamaz yapıyordu. Yani saat 4x'te akmaya devam
	# ederken oyuncunun onu durduracak HİÇBİR yolu kalmıyordu — işe alım kararı boyunca.
	# Politika sağlamdı, yeri yanlıştı; kendi katmanına taşındı (layer 9, gerçek bir modal
	# hâlâ üstünü örter).
	var layer: Node = get_tree().get_root().find_child("PanelLayer", true, false)
	if layer == null:
		push_error("[HRTab] GameShell/PanelLayer yok — Atlas modalı monte edilemiyor")
		return
	var scene: PackedScene = load(ATLAS_MODAL) as PackedScene
	if scene == null:
		push_error("[HRTab] Atlas modal sahnesi yüklenemedi: %s" % ATLAS_MODAL)
		return
	var modal: Control = scene.instantiate() as Control
	layer.add_child(modal)                       # önce add_child
	if modal.has_signal("state_changed"):
		modal.state_changed.connect(_on_atlas_changed)
	if modal.has_method("populate"):
		modal.populate()                         # sonra populate (ev konvansiyonu)


func _on_atlas_changed() -> void:
	# Arayış başladı / işe alım oldu / dosyalar iade edildi. Motorun bu geçişler için
	# sinyali yok (hr_search_state_changed mevcut değil), o yüzden modal haber veriyor.
	_refresh()


func _open_overtime(dept_id: String, anchor: Control) -> void:
	var pop: HRPopover = HRPopover.mount(self)
	if pop == null:
		return
	HROvertimePanel.fill(dept_id, pop.body(), func() -> void:
		pop.close()
		_refresh())
	pop.open_at(anchor)


func _on_card_action(emp_id: String, action: String, anchor: Control) -> void:
	if action == "toggle":
		_expanded_id = "" if _expanded_id == emp_id else emp_id
		_refresh()
		return
	var emp: Character = CharacterRegistry.get_character(emp_id)
	if emp == null:
		return
	match action:
		HREmployeeCard.ACTION_RAISE:
			_open_raise(emp, anchor)
		HREmployeeCard.ACTION_VACATION:
			_confirm_vacation(emp)
		HREmployeeCard.ACTION_FIRE:
			_confirm_fire(emp)


# --- Zam popover (Kare 6) --------------------------------------------------

func _open_raise(emp: Character, anchor: Control) -> void:
	var pop: HRPopover = HRPopover.mount(self)
	if pop == null:
		return
	var body: VBoxContainer = pop.body()
	body.add_child(UiFactory.make_section_header("Zam yap"))

	var pct_label := UiFactory.make_label("", &"TitleSerif", UiTokens.ACCENT_DEEP)
	pct_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var lines_box := VBoxContainer.new()
	lines_box.add_theme_constant_override("separation", 3)

	var slider := HSlider.new()
	slider.theme_type_variation = &"VolumeSlider"
	slider.min_value = float(HRConstants.RAISE_MIN_PCT)
	slider.max_value = float(HRConstants.RAISE_MAX_PCT)
	slider.step = 1.0
	slider.custom_minimum_size = Vector2(0, 24)
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	# value YALNIZCA burada, kurulumda yazılır — tazelemede slider.value'ya asla
	# dokunulmaz (pricing_panel'in grabber-zıplama korkuluğu).
	slider.value = float(HRConstants.RAISE_MIN_PCT)

	var bounds := HBoxContainer.new()
	bounds.add_theme_constant_override("separation", 8)
	bounds.add_child(UiFactory.make_label("%%%d" % HRConstants.RAISE_MIN_PCT, &"RowMeta", UiTokens.INK_DIM))
	bounds.add_child(slider)
	bounds.add_child(UiFactory.make_label("%%%d" % HRConstants.RAISE_MAX_PCT, &"RowMeta", UiTokens.INK_DIM))

	var commit := HRUiShared.action_button("", Callable(), true)
	commit.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var paint: Callable = func(pct: int) -> void:
		# Önizlemenin TAMAMI motordan: preview_raise hazır Türkçe `lines` döndürüyor
		# (moral önce→sonra, aylık yük önce→sonra), moral kazancı da ÖLÇEKLENMİŞ.
		var pv: Dictionary = HRActions.preview_raise(emp, pct)
		pct_label.text = "%%%d" % int(pv.get("pct", pct))
		for c in lines_box.get_children():
			lines_box.remove_child(c)
			c.queue_free()
		for line in pv.get("lines", []):
			lines_box.add_child(UiFactory.make_label(String(line), &"BodySerif"))
		commit.text = "ZAMMI UYGULA · +%%%d" % int(pv.get("pct", pct))

	slider.value_changed.connect(func(v: float) -> void: paint.call(int(v)))
	commit.pressed.connect(func() -> void:
		if HRActions.apply_raise(emp, int(slider.value)):
			pop.close()
			# set_salary sinyal ATMIYOR (registry'de eksik-sinyal notu duruyor), o yüzden
			# tazeleme aksiyondan sonra yerel olarak tetikleniyor.
			_rebuild_forced())

	body.add_child(pct_label)
	body.add_child(bounds)
	body.add_child(lines_box)
	body.add_child(HRUiShared.hairline())
	body.add_child(commit)
	paint.call(HRConstants.RAISE_MIN_PCT)
	pop.open_at(anchor)


# --- Tatil / çıkarma onayları ----------------------------------------------

func _confirm_vacation(emp: Character) -> void:
	# Gövde MOTORUN hazır Türkçe satırları (preview_vacation.lines: 7 gün, dönüş günü,
	# ölçeklenmiş moral kazancı, yıllık izin tüketimi). UI hiçbirini yeniden yazmıyor.
	var pv: Dictionary = HRActions.preview_vacation(emp)
	if not bool(pv.get("ok", false)):
		return
	EventBus.confirm_requested.emit({
		"title": "%s · tatile gönder" % emp.character_name,
		"body": "\n".join(PackedStringArray(pv.get("lines", []))),
		"confirm_text": "Tatile gönder",
		"cancel_text": "Vazgeç",
		"on_confirm": _do_vacation.bind(emp.id),
	})


func _do_vacation(emp_id: String) -> void:
	# Kimlikle bağlanıyor, nesneyle değil: onay modalı açıkken kayıt değişebilir
	# (istifa akışı kişiyi kaldırabilir), bayat bir Character referansı üzerinde
	# aksiyon almak yerine kayıttan yeniden okunuyor.
	var emp: Character = CharacterRegistry.get_character(emp_id)
	if emp != null and HRActions.send_on_vacation(emp):
		_rebuild_forced()


func _confirm_fire(emp: Character) -> void:
	var pv: Dictionary = HRActions.preview_fire(emp)
	if not bool(pv.get("ok", false)):
		return
	EventBus.confirm_requested.emit({
		"title": "%s · işten çıkar" % emp.character_name,
		"body": "\n".join(PackedStringArray(pv.get("lines", []))),
		"confirm_text": "İşten çıkar",
		"cancel_text": "Vazgeç",
		"on_confirm": _do_fire.bind(emp.id),
	})


func _do_fire(emp_id: String) -> void:
	var emp: Character = CharacterRegistry.get_character(emp_id)
	if emp != null and HRActions.fire(emp):
		_rebuild_forced()


func _rebuild_forced() -> void:
	# Yapı anahtarını geçersiz kılıp tam yeniden kurar. set_salary ve set_status
	# sinyal atmadığı için zam/tatil sonrası yapı anahtarı kendiliğinden değişse de
	# tetikleyici sinyal gelmiyor; çağrı buradan yapılıyor.
	_structure_key = ""
	_expanded_id = ""
	_refresh()
