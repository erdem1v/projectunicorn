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
const TRAINING_MODAL := "res://scenes/modals/TrainingModal.tscn"

## İki görünüm, tek sayfa (9b + 10b). Router YOK demiştik; artık VAR ama en hafif
## biçimiyle: aynı kadronun iki çizimi, `visible` ile değil TAM YENİDEN KURULARAK
## değişiyor — çünkü iki tablo tamamen farklı sütunlar taşıyor ve ikisini birden
## bellekte tutmak, bayatlamış bir tabloyu görünmez halde beslemek demekti.
const VIEW_ROSTER := "roster"
const VIEW_ASSIGNMENTS := "assignments"

var _signals: Array = []
var _list: VBoxContainer = null
var _summary: Label = null
var _training_control: Control = null
var _structure_key: String = ""
var _view: String = VIEW_ROSTER
var _seg_roster: Button = null
var _seg_assign: Button = null
var _placement_chips: HBoxContainer = null
var _attention_strip: VBoxContainer = null
var _roster_header: Control = null
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
		# DENEYİM barı ve EĞİTİMDE çipi satırın parçası — kendi sinyalleri olmadan
		# yalnız gün sınırında tazelenirdi.
		EventBus.employee_experience_changed, EventBus.employee_training_changed,
		# Renk körü takası: durum çipleri ÇALIŞMA ZAMANINDA erişimcilerden kuruluyor,
		# yani yeniden kurulmadan yeni paleti almazlar.
		EventBus.palette_changed,
	]
	for sig in _signals:
		if sig == EventBus.palette_changed:
			sig.connect(_on_palette_changed)
		else:
			sig.connect(_on_state_changed)
	_refresh()


func _exit_tree() -> void:
	for sig in _signals:
		if sig.is_connected(_on_state_changed):
			sig.disconnect(_on_state_changed)
		if sig.is_connected(_on_palette_changed):
			sig.disconnect(_on_palette_changed)


# Üç opsiyonel parametre: 0/1/2 argümanlı sinyaller aynı işleyiciye bağlanabilsin.
func _on_state_changed(_a = null, _b = null, _c = null) -> void:
	_refresh()


func _on_palette_changed(_cb: bool) -> void:
	# Yapı anahtarı DEĞİŞMEZ (kadro aynı), o yüzden _refresh yalnız morali boyar ve
	# çipler eski palette kalırdı. Palet takası zorla yeniden kurar.
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

	# Başlık satırı: Ekip + özet · sağda EĞİTİM · KİLİTLİ telgrafı + ARAYIŞ BAŞLAT
	# BAŞLIK SATIRI (kilitli reçete): özet başlığın YANINDA yaşar, kopuk bir alt
	# şeritte değil. Eski _footer SİLİNDİ — aynı sayılar iki yerde durmuyor.
	var head := HBoxContainer.new()
	head.add_theme_constant_override("separation", 14)
	head.alignment = BoxContainer.ALIGNMENT_CENTER
	head.add_child(UiFactory.make_label(tr("HR_PAGE_TITLE"), &"PageTitleSerif"))
	_summary = UiFactory.make_label("", &"TitleRowSummary")
	_summary.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	head.add_child(_summary)
	# BOŞTA / AŞIRI YÜK sayaçları başlık satırında (9b): kaç kişinin yeri yanlış, tek
	# bakışta. Sayılar motorun türettiği okumalar — burada hiçbir şey hesaplanmıyor.
	_placement_chips = HBoxContainer.new()
	_placement_chips.add_theme_constant_override("separation", UiTokens.SPACE_S)
	_placement_chips.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	head.add_child(_placement_chips)
	var head_spacer := Control.new()
	head_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(head_spacer)
	_training_control = _build_training_control()
	head.add_child(_training_control)
	head.add_child(HRUiShared.action_button(tr("HR_SEARCH_START"), _open_atlas, true))
	outer.add_child(head)

	# KADRO / GÖREVLER — aynı kadronun iki görünümü (9b + 10b). finance_tab'ın segment
	# çifti kalıbı: kardeş görünümler, `visible` ile değiştirilir, sayfa yeniden kurulmaz.
	var tabs := HBoxContainer.new()
	tabs.add_theme_constant_override("separation", 28)
	_seg_roster = _make_segment(tr("HR_TAB_ROSTER"), VIEW_ROSTER)
	_seg_assign = _make_segment(tr("HR_TAB_ASSIGNMENTS"), VIEW_ASSIGNMENTS)
	tabs.add_child(_seg_roster)
	tabs.add_child(_seg_assign)
	outer.add_child(tabs)
	outer.add_child(HRUiShared.hairline())

	# DİKKAT ŞERİDİ: kilitli reçetenin "kırmızı şerit, doğrudan sayfa başlığının altında"
	# kuralı. İçeriği _refresh dolduruyor; boşken görünmez.
	_attention_strip = VBoxContainer.new()
	_attention_strip.add_theme_constant_override("separation", 6)
	outer.add_child(_attention_strip)

	# Sütun başlıkları tablonun başlığıdır — bir kez, kaydırma alanının DIŞINDA,
	# yani sayfa kayarken de görünür kalır. GÖREVLER kendi başlığını taşır.
	_roster_header = HRLedger.column_header()
	outer.add_child(_roster_header)

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
	if _list == null:
		return
	# Başlık VE alt şerit her tazelemede: alt şerit ORTALAMA MORAL yazıyor, yani yapı
	# değişmeden de oynayan bir sayı. Yalnız _rebuild'de boyanınca morale_changed'in
	# yerinde-güncelleme yolunda bayat kalıyordu.
	_paint_summary()
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
	parts.append("%s|%d" % [HRSearchSystem.get_state(), HRSearchSystem.days_waiting()])
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

	_paint_placement_chips()
	_paint_attention_strip()
	_paint_segments()

	if _view == VIEW_ASSIGNMENTS:
		# GÖREVLER: kendi başlığını taşıyor, defterin sütun başlığı gizleniyor.
		if _roster_header != null:
			_roster_header.visible = false
		_list.add_child(HRAssignments.build(_on_assignment_toggled))
		return
	if _roster_header != null:
		_roster_header.visible = true

	# Atlas şeridi (Kare 3 bekleme / dosyalar hazır) en üstte.
	var strip: Control = _atlas_strip()
	if strip != null:
		_list.add_child(strip)

	# DÖRT DÜZ GRUP (9b): Ürün & Tasarım · Geliştirme Ekibi · Satış · Müşteri İlişkileri.
	# Departman + alt-bölüm iki seviyeli düzeni emekli; departman yalnız EK MESAİ'nin
	# birimi olarak yaşamaya devam ediyor (bkz. _add_group).
	for group_id in HRConstants.ROSTER_GROUPS:
		_add_group(String(group_id))


func _paint_summary() -> void:
	if _summary == null:
		return
	# Yalnız alt şeritte OLMAYAN bilgiler (bilgi-tekrarı kuralı: her bilgi bir kez) —
	# çalışan sayısı ve maaş yükü alt şeridin işi; buradaki iki sayı dikkat çağrısı.
	# Dikkat sayısı attention_PEOPLE_count: sol raydaki rozet bekleyen aday dosyasını da
	# sayar, ama bu cümle EKİP hakkında, ve dosyaların kendi şeridi var — ikisini aynı
	# sayıda toplamak yalan olurdu.
	# Alt şeridin taşıdığı üç toplam buraya taşındı (kilitli reçete: özet başlık
	# satırında). Dikkat/izin sayıları GİTMEDİ — durum çipleri satırın kendisinde
	# duruyor, yani sayfa hâlâ "kaç kişi dikkat istiyor"u gösteriyor, ama artık
	# aynı bilgiyi iki ayrı cümlede tekrarlamıyor.
	_summary.text = tr("HR_SUMMARY").format({
		"count": CharacterRegistry.count_employees(),
		"morale": int(round(HRMoraleSystem.average_morale())),
		"payroll": HRUiShared.money(CharacterRegistry.get_total_monthly_salaries()),
	})
	_summary.visible = true


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
		UiTokens.tr_upper(HRConstants.search_agency_name()), &"SectionLabel"))
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	if state == HRConstants.SEARCH_FILES_READY:
		info.add_child(UiFactory.make_label(
			tr("HR_FILES_ON_DESK").format({"n": HRSearchSystem.get_files().size()}), &"BodySerif"))
		head.add_child(info)
		head.add_child(HRUiShared.action_button(tr("HR_OPEN_FILES"), _open_atlas, true))
		col.add_child(head)
		return card

	# Arayış sürüyor: TEK durum satırı (bilgi-tekrarı kuralı) — rol + kaçıncı gün. Bant
	# oyuncunun verilmiş kararı, burada tekrarlanmaz; "iade edilmez" uyarısı ödeme anında
	# (modal ücret bloğu) ve kayıp anında (iptal onayı) yaşıyor, bekleme şeridinde değil.
	# Rol HRSearchSystem accessor'ından; GameState.hr_search sözlüğüne UI'dan uzanmak o
	# sözlüğün sahibini atlamak olurdu.
	var role_id: String = HRSearchSystem.current_role()
	var line: String = tr("HR_SEARCHING").format({
		"role": HRConstants.role_label(role_id) if role_id != "" else tr("HR_CANDIDATE_GENERIC"),
		"n": HRSearchSystem.days_waiting(),
	})
	info.add_child(UiFactory.make_label(line, &"BodySerif"))
	head.add_child(info)
	head.add_child(HRUiShared.action_button(tr("HR_SEARCH_CANCEL"), _on_cancel_search))
	col.add_child(head)
	return card


func _on_cancel_search() -> void:
	# İptalin önizlemesi yok (motorda preview_cancel_search bulunmuyor — raporlanıyor),
	# ama peşin ücreti yakıyor, o yüzden onay isteniyor. on_confirm bağlı METOT referansı
	# (creation_flow'un confirm şekli) — sözlük içine çok satırlı lambda gömülmüyor.
	EventBus.confirm_requested.emit({
		"title": tr("HR_SEARCH_CANCEL_TITLE"),
		"body": tr("HR_SEARCH_CANCEL_BODY").format({
			"amount": HRUiShared.money(HRConstants.SEARCH_RETAINER)}),
		"confirm_text": tr("HR_SEARCH_CANCEL_OK"),
		"cancel_text": tr("UI_DISMISS"),
		"on_confirm": _do_cancel_search,
	})


func _do_cancel_search() -> void:
	HRSearchSystem.cancel_search()
	_rebuild_forced()


# --- EĞİTİM (DENEYİM/EĞİTİM mekaniği) ---------------------------------------
# Mockup'ta bu yüzey "EĞİTİM · KİLİTLİ" telgrafıydı. Artık CANLI: deneyimi dolan
# en az bir çalışan varsa düğmeye döner ve uygun adayların listesini açar.
# Kilitli hâli yalan söylemiyor — gerçekten yapılacak bir şey yokken kilitli.

func _build_training_control() -> Control:
	if _eligible_for_training().is_empty():
		return HRUiShared.locked_telegraph(tr("HR_TRAINING_LOCKED"))
	return HRUiShared.action_button(tr("HR_TRAINING"), _open_training_picker)


func _eligible_for_training() -> Array[Character]:
	var out: Array[Character] = []
	for emp in CharacterRegistry.get_employees():
		if CharacterRegistry.can_train(emp.id):
			out.append(emp)
	return out


func _open_training_picker() -> void:
	# Başlıktaki EĞİTİM düğmesi. Kişi seçme adımı onaylı tasarımda ÇİZİLMEDİ, o yüzden
	# icat edilmiyor: düğme ilk uygun kişiyle modalı açar, ve asıl kapı satırın ⋯
	# menüsündeki dördüncü satırdır — orada kişi zaten seçili.
	var eligible: Array[Character] = _eligible_for_training()
	if eligible.is_empty():
		return
	_confirm_training(eligible[0])


## 11c'yi açar. Eski ConfirmModal yükü (tek satır metin + Onayla) EMEKLİ: alan seçimini
## OYUNCU yapıyor artık (rev 2 §8), ve bir onay kutusu beş satırlık bir tabloyu taşıyamaz.
func _confirm_training(emp: Character) -> void:
	var layer: Node = get_tree().get_root().find_child("PanelLayer", true, false)
	if layer == null:
		push_error("[HRTab] PanelLayer bulunamadı — eğitim modalı mount edilemiyor")
		return
	var scene: PackedScene = load(TRAINING_MODAL) as PackedScene
	if scene == null:
		push_error("[HRTab] TrainingModal sahnesi yüklenemedi")
		return
	var modal: Control = scene.instantiate() as Control
	layer.add_child(modal)
	if modal.has_signal("state_changed"):
		modal.state_changed.connect(_rebuild_forced)
	if modal.has_method("populate"):
		modal.populate(emp.id)


# --- Departman bölümleri ---------------------------------------------------

## Bir KADRO GRUBU: amber başlık + hairline + satırlar. Onaylı tasarımın dört düz bandı
## (9b), eski departman + alt-bölüm iki seviyesinin yerine.
##
## EK MESAİ hâlâ DEPARTMAN başına: HROvertimeSystem üç departman sayıyor, dört grup değil.
## Düğme o departmanın İLK grup başlığına asılır (HRConstants.overtime_dept_for_group) —
## iki başlıkta iki kez göstermek oyuncuya iki ayrı mesai bloğu varmış gibi okunurdu.
func _add_group(group_id: String) -> void:
	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 10)
	header.add_child(UiFactory.make_label(
		UiTokens.tr_upper(HRConstants.group_label(group_id)), &"SectionAmber"))
	var rule := HRUiShared.hairline()
	rule.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rule.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	header.add_child(rule)
	var dept_id: String = HRConstants.overtime_dept_for_group(group_id)
	# EK MESAİ yalnız başlatılabilir ya da hâlihazırda çalışan bir blok varken görünür:
	# kadrosu boş bir departmanda buton ölü bir aksiyon olurdu. Karar motorun: can_start.
	if dept_id != "" and (HROvertimeSystem.can_start(dept_id) or HROvertimeSystem.is_active(dept_id)):
		header.add_child(_overtime_control(dept_id))
	_list.add_child(header)

	# get_employees(), get_active_by_role() DEĞİL: defter izindeki ve eğitimdeki kişiyi de
	# gösterir — maaşı ödeniyor ve satırı okunuyor, yalnız o günkü kapasiteye girmiyor.
	var roster: Array[Character] = []
	for emp in CharacterRegistry.get_employees():
		if String(HRConstants.ROLE_GROUP.get(emp.role, "")) == group_id:
			roster.append(emp)
	_add_roster(roster, dept_id)


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
		_list.add_child(HRLedger.row(emp, _on_card_action, refs))
		_morale_refs[emp.id] = refs


func _empty_row(_dept_id: String) -> Control:
	return HRLedger.empty_row(_open_atlas)


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
## Stylebox çalışma zamanında kuruluyor — yeni bir tema öğesi eklemek THEME_STAMP
## artırmayı gerektirirdi ve bu sayfa hiçbir tema öğesi eklemiyor.
func _paint_segments() -> void:
	for pair in [[_seg_roster, VIEW_ROSTER], [_seg_assign, VIEW_ASSIGNMENTS]]:
		var btn: Button = pair[0]
		if btn == null:
			continue
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
		btn.add_theme_color_override("font_color",
			UiTokens.INK if active else UiTokens.INK_DIM)
		btn.add_theme_color_override("font_hover_color",
			UiTokens.INK if active else UiTokens.INK_MUTED)


## "N BOŞTA" (nötr) + "N AŞIRI YÜK" (amber). Sıfır olan çip ÇİZİLMEZ — sıfırı göstermek
## bir uyarıyı gürültüye çevirir.
func _paint_placement_chips() -> void:
	if _placement_chips == null:
		return
	for c in _placement_chips.get_children():
		_placement_chips.remove_child(c)
		c.queue_free()
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


## Kırmızı dikkat şeridi, sayfa başlığının hemen altında (kilitli reçete). Bir satır per
## kaçma riski: ad + MORAL n. Eşik motorun (HRConstants.is_flight_risk), burada değil.
func _paint_attention_strip() -> void:
	if _attention_strip == null:
		return
	for c in _attention_strip.get_children():
		_attention_strip.remove_child(c)
		c.queue_free()
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


## GÖREVLER matrisindeki bir kutu tıklandı. TEK YAZAR CharacterRegistry; burası yalnız
## hangi seam'in çağrılacağına karar veriyor.
##
## KURUCU TAŞINIR, REDDEDİLMEZ: tek alan taşıdığı için işaretsiz bir alana tıklamak
## "önce bırak, sonra ata" demektir — yoksa ilk atamadan sonra her tık `founder_busy`
## döner ve matris tıklanamaz görünürdü.
func _on_assignment_toggled(char_id: String, area_id: String, currently_on: bool) -> void:
	var c: Character = CharacterRegistry.get_character(char_id)
	if c == null:
		return
	if currently_on:
		CharacterRegistry.unassign_area(char_id, area_id)
		_rebuild_forced()
		return
	if c.category == "founder" and not c.assigned_jobs.is_empty():
		for held in c.assigned_jobs.duplicate():
			CharacterRegistry.unassign_area(char_id, String(held))
	var reason: String = CharacterRegistry.assign_area(char_id, area_id)
	if reason != "":
		# SAVUNMA DALI, oyuncuya giden bir yol değil: matris atanamaz kareyi kesikli çiziyor
		# ve tıklamıyor, kurucunun ikinci alanı da yukarıda önce bırakılıyor. Buraya
		# düşülüyorsa arayüz ile motor ayrışmış demektir — sessiz kalmak yerine loga bağırır.
		# Oyuncunun "neden tıklayamıyorum" sorusunun cevabı kesikli karenin TOOLTIP'inde.
		push_warning("[HRTab] assign_area('%s', '%s') refused: %s" % [char_id, area_id, reason])
	_rebuild_forced()


func _overtime_control(dept_id: String) -> Control:
	# Aktifken şerit ("EK MESAİ · N. GÜN"), değilken aksiyon butonu. İkisi de aynı
	# paneli açıyor; panel aktif blokta DURDUR gösteriyor (erken durdurma).
	var anchor_label: String = tr("HR_OVERTIME_CHIP")
	if HROvertimeSystem.is_active(dept_id):
		anchor_label = tr("ODA_WINDOW_OVERTIME").format({"n": HROvertimeSystem.day_index(dept_id)})
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
	var emp: Character = CharacterRegistry.get_character(emp_id)
	if emp == null:
		return
	match action:
		HRLedger.ACTION_MENU:
			_open_actions(emp, anchor)
		HRLedger.ACTION_RAISE:
			_open_raise(emp, anchor)
		HRLedger.ACTION_VACATION:
			_confirm_vacation(emp)
		HRLedger.ACTION_FIRE:
			_confirm_fire(emp)
		HRLedger.ACTION_TRAIN:
			_confirm_training(emp)


# --- Satır aksiyon menüsü --------------------------------------------------

func _open_actions(emp: Character, anchor: Control) -> void:
	# Defter satırına tıklayınca açılan üçlü. Zam kendi popover'ını açar (slider'lı),
	# diğer ikisi zaten var olan onay modallarını kaldırır — bu fonksiyon hiçbir sonuç
	# HESAPLAMAZ, yalnız kapıyı açar.
	#
	# Kapalı satırın GEREKÇESİ preview_*'tan okunur, can_*'tan DEĞİL: can_* yalnız bool
	# döner, sebep dizesi yalnız preview_*'ın `reason` anahtarında yaşıyor. (Kartın
	# kilitli reçetesi buydu; kart öldü, kural kaldı.)
	var pop: HRPopover = HRPopover.mount(self)
	if pop == null:
		return
	var body: VBoxContainer = pop.body()
	body.add_theme_constant_override("separation", 0)

	# BAŞLIK SATIRI (9e): ad + rol, altında hairline.
	var head := VBoxContainer.new()
	head.add_theme_constant_override("separation", 2)
	head.add_child(UiFactory.make_label(emp.character_name, &"RowName"))
	head.add_child(UiFactory.make_label(
		UiTokens.tr_upper(HRConstants.role_label(emp.role)), &"MicroLabel"))
	body.add_child(head)
	body.add_child(HRUiShared.hairline())

	# DÖRT SATIR. Eğitim 2026-08-22'de buraya girdi: onaylı tasarım satırda EĞİTİME
	# GÖNDER düğmesi çizmiyor ve eğitim kişi başına bir karar — menü onun evi.
	# Sağdaki META her satırın SONUCUNU söylüyor (mevcut maaş · süre · kalıcı).
	var train_ok: bool = CharacterRegistry.can_train(emp.id)
	for spec in [
			{"key": "HR_CARD_RAISE", "preview": HRActions.preview_raise(emp, HRConstants.RAISE_MIN_PCT),
				"action": HRLedger.ACTION_RAISE, "icon": "raise",
				"meta": HRUiShared.money(emp.monthly_salary)},
			{"key": "HR_TRAINING_PICK_TITLE",
				"preview": {"ok": train_ok, "reason": tr("HR_TRAINING_AT_CAP")},
				"action": HRLedger.ACTION_TRAIN, "icon": "train",
				"meta": tr("HR_TRAINING_DURATION_WEEKS")},
			{"key": "HR_CARD_HOLIDAY", "preview": HRActions.preview_vacation(emp),
				"action": HRLedger.ACTION_VACATION, "icon": "leave",
				"meta": HRSystem.leave_line(emp)},
			{"key": "HR_CARD_FIRE", "preview": HRActions.preview_fire(emp),
				"action": HRLedger.ACTION_FIRE, "icon": "fire",
				"meta": tr("HR_MENU_PERMANENT")}]:
		# YIKICI EYLEM AYRI BÖLÜMDE (9e): İşten çıkar'ın önüne hairline.
		if String(spec["action"]) == HRLedger.ACTION_FIRE:
			body.add_child(HRUiShared.hairline())
		body.add_child(_menu_row(pop, emp, spec, anchor))

	pop.open_at(anchor)


## 9e'nin satır grameri: 46px ritim, 16px iç boşluk, solda mono ikon, sağda meta,
## hover'da 2px amber sol kenar + %5 zemin, devre dışıysa kilit glifi + gerekçe.
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
	# Kilitli satırda ikonun YERİNE kilit glifi: gerekçe ikon hizasında girinti alır (9e).
	if ok:
		row.add_child(HRUiShared.lock_glyph(13, Color(0, 0, 0, 0)))
	else:
		row.add_child(HRUiShared.lock_glyph(13, UiTokens.INK_FAINT))
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


# --- Zam popover (Kare 6) --------------------------------------------------

func _open_raise(emp: Character, anchor: Control) -> void:
	var pop: HRPopover = HRPopover.mount(self)
	if pop == null:
		return
	var body: VBoxContainer = pop.body()
	body.add_child(UiFactory.make_section_header(tr("HR_RAISE_POPOVER_TITLE")))

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
	bounds.add_child(UiFactory.make_label(Fmt.percent(HRConstants.RAISE_MIN_PCT, 0), &"RowMeta", UiTokens.INK_DIM))
	bounds.add_child(slider)
	bounds.add_child(UiFactory.make_label(Fmt.percent(HRConstants.RAISE_MAX_PCT, 0), &"RowMeta", UiTokens.INK_DIM))

	var commit := HRUiShared.action_button("", Callable(), true)
	commit.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var paint: Callable = func(pct: int) -> void:
		# Önizlemenin TAMAMI motordan: preview_raise hazır Türkçe `lines` döndürüyor
		# (moral önce→sonra, aylık yük önce→sonra), moral kazancı da ÖLÇEKLENMİŞ.
		var pv: Dictionary = HRActions.preview_raise(emp, pct)
		pct_label.text = Fmt.percent(int(pv.get("pct", pct)), 0)
		for c in lines_box.get_children():
			lines_box.remove_child(c)
			c.queue_free()
		for line in pv.get("lines", []):
			lines_box.add_child(UiFactory.make_label(String(line), &"BodySerif"))
		commit.text = tr("HR_APPLY_RAISE_PCT").format({"pct": Fmt.percent(int(pv.get("pct", pct)), 0)})

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
		"title": tr("HR_HOLIDAY_CONFIRM_TITLE").format({"name": emp.character_name}),
		"body": "\n".join(PackedStringArray(pv.get("lines", []))),
		"confirm_text": tr("HR_HOLIDAY_CONFIRM_OK"),
		"cancel_text": tr("UI_DISMISS"),
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
		"title": tr("HR_FIRE_CONFIRM_TITLE").format({"name": emp.character_name}),
		"body": "\n".join(PackedStringArray(pv.get("lines", []))),
		"confirm_text": tr("HR_FIRE_CONFIRM_OK"),
		"cancel_text": tr("UI_DISMISS"),
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
	_refresh()
