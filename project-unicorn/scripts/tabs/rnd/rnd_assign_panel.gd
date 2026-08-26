class_name RnDAssignPanel
extends VBoxContainer

# ============================================================================
# AR-GE → ATAMA PANELİ (onaylı R3). Detay kartının İÇİNDE açılır.
#
# NEDEN ProductTeamPanel DEĞİL — dördü de yapısal, hiçbiri zevk değil:
#   1. O panel FİLTRELER (10+ çalışanda arama/alan/müsaitlik satırı); R3 burada
#      YOKLUK istiyor — alanı tutamayan kişi sönük değil, kapalı değil, YOK.
#   2. Onun gruplama anahtarı KİŞİ BAŞINA TEK ALANDIR (`_primary_area`); iki
#      alanlı bir devam düğümünde çift-yeterli biri HER İKİ grupta da görünmek
#      zorunda. Aynı kişi iki grupta = o fonksiyonun sözleşmesinin tersi.
#   3. Onda LİDER SATIRI var; araştırmanın lideri yok (§5.4 tek toplam, R3 hükmü).
#   4. Sütun genişlikleri (W_AREA 148 + W_AVAIL 186 + yıldızlar) 424px'lik sütuna
#      TEK SATIRDA sığmıyor. R3 bu yüzden İKİ SATIRLIK satır tarif ediyor.
#
# ONDAN AYNEN ALINAN VE KAYNAĞI YAZILAN DÖRT İLKEL:
#   · grup başlığı: şevron + ad + (n) çubuğu     → team_panel._make_group_header
#   · onay kutusu                                 → team_panel._check_box
#   · 2px amber sol şeritli satır kutusu          → team_panel._row_box
#   · `StarRating.make(points, 11)`               → team_panel._area_cell
#
# BU DOSYA HİÇBİR SAYI TÜRETMEZ: havuz `RnDSystem.eligible_assignees`, hız
# `RnDSystem.days_estimate`, engel `RnDSystem.start_refusal`. Yıldız eşiği
# HRConstants.POINTS_PER_STAR ile ResearchTree.stars_of'un çarpımıdır ve o çarpım
# motorun `_area_has_star`ıyla AYNI cümledir — ikisi ayrışırsa panel "yeterli"
# derken Başlat reddeder.
# ============================================================================

## Araştırma başladı / atama uygulandı — kart kendini kapatsın.
signal started
## Oyuncu vazgeçti.
signal closed

const CHECK_PX := 14
const ROW_PAD_X := 10
const ROW_PAD_Y := 7
const SELECT_BAR_W := 2
const STAR_PX := 11
const CHEVRON_PX := 9
const MARK_MET := "✓"
const DIM_ALPHA := 0.45

var _node_id: String = ""
var _selected: Array[String] = []
var _open_groups: Dictionary = {}      # area -> bool
var _list: VBoxContainer = null
var _footer_info: Label = null
var _action_slot: HBoxContainer = null
var _reason: Label = null


func _ready() -> void:
	add_theme_constant_override("separation", UiTokens.SPACE_M)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL


## Panelin tek girişi. Aktif düğümde MEVCUT atananlar önseçilidir — `ata`
## listeyi sıfırdan doldurtmaz, var olanı düzenletir (§5.6).
func setup(node_id: String) -> void:
	_node_id = node_id
	_selected.clear()
	for cid in RnDSystem.assigned(node_id):
		_selected.append(String(cid))
	_open_groups.clear()
	for area in ResearchTree.areas_of(node_id):
		_open_groups[String(area)] = true
	_build_shell()
	_refresh_list()
	_refresh_footer()


func selected_ids() -> Array:
	return _selected.duplicate()


# ---------------------------------------------------------------- kabuk

func _build_shell() -> void:
	for c in get_children():
		remove_child(c)
		c.queue_free()

	_list = VBoxContainer.new()
	_list.add_theme_constant_override("separation", 0)
	_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_child(_list)

	add_child(RnDUiShared.hairline())

	var footer := HBoxContainer.new()
	footer.add_theme_constant_override("separation", UiTokens.SPACE_M)
	# SOL: alan + canlı gün tahmini. Her onay kutusu değişiminde yeniden okunur.
	_footer_info = UiFactory.make_label("", &"RowMeta", UiTokens.INK_MUTED)
	_footer_info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_footer_info.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_footer_info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	footer.add_child(_footer_info)
	_action_slot = HBoxContainer.new()
	_action_slot.add_theme_constant_override("separation", UiTokens.SPACE_L)
	_action_slot.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	footer.add_child(_action_slot)
	add_child(footer)

	# TEK SEBEP SATIRI, düğmenin ALTINDA (R3). Boşken görünmez.
	_reason = UiFactory.make_label("", &"RowMeta", UiTokens.INK_MUTED)
	_reason.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_reason.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_reason.visible = false
	add_child(_reason)


# ---------------------------------------------------------------- liste

func _refresh_list() -> void:
	if _list == null or not is_instance_valid(_list):
		return
	for c in _list.get_children():
		_list.remove_child(c)
		c.queue_free()

	# GEREKEN ALAN BAŞINA BİR GRUP. Kök/dal tek alan, devam iki alan (§5.2) —
	# ve çift-yeterli biri İKİ grupta birden görünür, çünkü iki alanı da
	# tutabildiği bilgisi oyuncunun kararının ta kendisi.
	for area_raw in ResearchTree.areas_of(_node_id):
		var area := String(area_raw)
		var members: Array[Character] = _group_members(area)
		var is_open: bool = bool(_open_groups.get(area, true))
		_list.add_child(_group_header(area, members, is_open))
		if not is_open:
			continue
		if members.is_empty():
			# BOŞ HAVUZ BOŞ PANEL DEĞİLDİR (R3).
			var empty := UiFactory.make_label(
				RnDUiShared.t("RND_ASSIGN_EMPTY"), &"EmptyRowLabel")
			empty.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			_list.add_child(empty)
			continue
		for c in members:
			_list.add_child(_person_row(c, area))


## Havuz motorun (§5.3): rolü alanı TUTABİLEN çalışanlar + KURUCU HER ZAMAN.
## Yeterlilik değil TUTABİLİRLİK filtresi — `eligible_assignees`ın kendi
## gerekçesi: aday üreteci herkesin her alanını doldurduğu için ham-yıldız
## filtresi bütün kadroyu listeler ve hiçbir iş görmez.
func _group_members(area: String) -> Array[Character]:
	var out: Array[Character] = []
	for c in RnDSystem.eligible_assignees(_node_id):
		if HRConstants.can_hold_area(c.role, area, c.category):
			out.append(c)
	return out


## "▾ Yazılım (3)" + KARŞILANDI/KARŞILANMADI çipi.
## Karşılandı = grupta ham puanı ★eşiğine ULAŞAN biri var. Ham puan, etkin
## yetenek DEĞİL: motorun `_area_has_star`ı da role_stats okuyor, ve izindeki
## biri şirketin yeterliliğini düşürmez (§5.2 · §12.6).
func _group_header(area: String, members: Array[Character], is_open: bool) -> Control:
	var bar := PanelContainer.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = UiTokens.SURFACE_FRAME
	sb.border_color = UiTokens.DIVIDER_LIGHT
	sb.set_border_width_all(0)
	sb.border_width_bottom = UiTokens.BORDER_HAIRLINE
	sb.set_corner_radius_all(UiTokens.RADIUS_NONE)
	sb.content_margin_left = ROW_PAD_X
	sb.content_margin_right = ROW_PAD_X
	sb.content_margin_top = ROW_PAD_Y
	sb.content_margin_bottom = ROW_PAD_Y
	sb.anti_aliasing = false
	bar.add_theme_stylebox_override("panel", sb)
	bar.mouse_filter = Control.MOUSE_FILTER_STOP
	bar.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	bar.gui_input.connect(_on_group_input.bind(area))

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", UiTokens.SPACE_M)
	row.add_child(_chevron(is_open))
	row.add_child(UiFactory.make_label(RnDUiShared.area_label(area), &"RowMeta",
		UiTokens.INK_MUTED if is_open else UiTokens.INK_DIM))
	row.add_child(UiFactory.make_label(
		RnDUiShared.t("PROD_TEAM_GROUP_COUNT").format({"n": members.size()}),
		&"MicroLabel", UiTokens.INK_FAINT))
	row.add_child(RnDUiShared.spacer())
	var met: bool = _area_met(area, members)
	row.add_child(UiFactory.make_state_chip(
		RnDUiShared.t("RND_REQ_MET" if met else "RND_REQ_UNMET"),
		UiTokens.ACCENT if met else UiTokens.INK_MUTED,
		UiTokens.AMBER_BG if met else UiTokens.SURFACE_FRAME,
		UiTokens.ACCENT if met else UiTokens.BORDER_HOVER))
	bar.add_child(row)
	HRUiShared.set_mouse_ignore(row)
	return bar


func _area_met(area: String, members: Array[Character]) -> bool:
	var want: int = ResearchTree.stars_of(_node_id) * HRConstants.POINTS_PER_STAR
	for c in members:
		if int(c.role_stats.get(area, 0)) >= want:
			return true
	return false


## Evde YALNIZ aşağı/yukarı şevron var; kapalı durum aşağı şevronun çeyrek tur
## döndürülmüşü (team_panel._chevron'un aynı gerekçesi: ikinci bir ikon dosyası
## eklemek yerine tek kaynak kalıyor).
func _chevron(is_open: bool) -> Control:
	var glyph: TextureRect = HRUiShared.chevron(CHEVRON_PX,
		UiTokens.INK_MUTED if is_open else UiTokens.INK_DIM)
	if not is_open:
		glyph.pivot_offset = Vector2(CHEVRON_PX, CHEVRON_PX) * 0.5
		glyph.rotation = -PI * 0.5
	return glyph


## İKİ SATIRLIK SATIR (R3): 1. satır ad + alan + yıldızlar, 2. satır ROL + müsaitlik.
## Tek satır 424px'lik sütuna sığmıyor — bu bir yerleşim kararı, bir gramer
## değişikliği değil: aynı beş bilgi, iki satıra bölünmüş.
func _person_row(c: Character, area: String) -> Control:
	var picked: bool = _selected.has(c.id)
	var card := PanelContainer.new()
	card.add_theme_stylebox_override("panel", _row_box(picked, false))
	card.mouse_filter = Control.MOUSE_FILTER_STOP
	card.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	card.mouse_entered.connect(_on_row_hover.bind(card, picked, true))
	card.mouse_exited.connect(_on_row_hover.bind(card, picked, false))
	card.gui_input.connect(_on_row_input.bind(c.id))

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", UiTokens.SPACE_M)
	card.add_child(row)
	row.add_child(_check_box(picked))

	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", UiTokens.SPACE_XXS)
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(col)

	# --- 1. satır: ad ................ alan + yıldızlar
	var line1 := HBoxContainer.new()
	line1.add_theme_constant_override("separation", UiTokens.SPACE_S)
	var name_lbl := UiFactory.make_label(c.character_name, &"RowName",
		UiTokens.INK if picked else UiTokens.INK_MUTED)
	name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_lbl.clip_text = true
	name_lbl.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	line1.add_child(name_lbl)
	line1.add_child(UiFactory.make_label(RnDUiShared.area_label(area), &"MicroLabel"))
	line1.add_child(StarRating.make(int(c.role_stats.get(area, 0)), STAR_PX))
	col.add_child(line1)

	# --- 2. satır: ROL ................ müsaitlik bayrağı
	var line2 := HBoxContainer.new()
	line2.add_theme_constant_override("separation", UiTokens.SPACE_S)
	line2.add_child(UiFactory.make_label(Fmt.upper(_title_of(c)), &"MicroLabel"))
	line2.add_child(RnDUiShared.spacer())
	var avail: String = _availability_text(c)
	if avail != "":
		line2.add_child(UiFactory.make_label(avail, &"MicroLabel", UiTokens.ACCENT))
	col.add_child(line2)

	if HRSystem.is_busy(c):
		# SOLUK = yalnız ALFA (palet tablosu dışına ham renk çıkmaz). Satır
		# KAPALI DEĞİL: §7 izindeki birinin atamasını silmiyor, katkısını
		# sıfırlıyor — oyuncu onu yine de seçebilmeli.
		col.modulate.a = DIM_ALPHA
	HRUiShared.set_mouse_ignore(row)
	return card


func _check_box(picked: bool) -> Control:
	var box := PanelContainer.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = UiTokens.SURFACE_INPUT
	sb.border_color = UiTokens.ACCENT if picked else UiTokens.BORDER_HOVER
	sb.set_border_width_all(UiTokens.BORDER_HAIRLINE)
	sb.set_corner_radius_all(UiTokens.RADIUS_S)
	sb.anti_aliasing = false
	box.add_theme_stylebox_override("panel", sb)
	box.custom_minimum_size = Vector2(CHECK_PX, CHECK_PX)
	box.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var tick := UiFactory.make_label(MARK_MET if picked else "", &"BadgeLabel", UiTokens.ACCENT)
	tick.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tick.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	box.add_child(tick)
	return box


## SOL ŞERİT seçimi söyler (2px amber), ALT SAÇ TELİ satırları ayırır, HOVER
## YALNIZ KENARI AÇAR. Kalınlık üç durumda da aynı → satır hover'da kıpırdamaz.
func _row_box(picked: bool, hovered: bool) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = UiTokens.AMBER_WASH if picked else UiTokens.CARD_BG
	sb.set_corner_radius_all(UiTokens.RADIUS_NONE)
	sb.border_width_left = SELECT_BAR_W
	sb.border_width_top = UiTokens.BORDER_HAIRLINE
	sb.border_width_right = UiTokens.BORDER_HAIRLINE
	sb.border_width_bottom = UiTokens.BORDER_HAIRLINE
	if picked:
		sb.border_color = UiTokens.ACCENT
	elif hovered:
		sb.border_color = UiTokens.BORDER_HOVER
	else:
		sb.border_color = UiTokens.DIVIDER_LIGHT
	sb.content_margin_left = ROW_PAD_X
	sb.content_margin_right = ROW_PAD_X
	sb.content_margin_top = ROW_PAD_Y
	sb.content_margin_bottom = ROW_PAD_Y
	sb.anti_aliasing = false
	return sb


func _title_of(c: Character) -> String:
	if c.category == "founder":
		return HRConstants.role_label(HRConstants.ROLE_FOUNDER)
	return HRConstants.job_title(c.role, c.level)


## "Eğitimde · 4g sonra katılır" / "İzinde · 12g sonra katılır". Müsait kişide
## BOŞ döner. Gün sayıları domain'in kendi seam'lerinden; burada tarih
## aritmetiği yapılmıyor.
func _availability_text(c: Character) -> String:
	if c == null:
		return ""
	if c.training_days_left > 0:
		return RnDUiShared.t("PROD_TEAM_AVAIL_TRAINING").format({"n": c.training_days_left})
	if c.status == HRConstants.STATUS_ON_LEAVE:
		return RnDUiShared.t("PROD_TEAM_AVAIL_LEAVE").format({
			"n": HRMoraleSystem.days_until_return(c)})
	if c.category == "founder" and HRSystem.is_busy(c):
		return RnDUiShared.t("HR_FOUNDER_STATE_PITCH_PREP")
	return ""


# ---------------------------------------------------------------- alt bant

func _refresh_footer() -> void:
	if _footer_info == null or not is_instance_valid(_footer_info):
		return
	# SOL: "{alan} alanı · ~{n} gün", HER onay kutusu değişiminde yeniden.
	var parts := PackedStringArray()
	for area in ResearchTree.areas_of(_node_id):
		parts.append(RnDUiShared.t("RND_AREA_OF").format({
			"area": RnDUiShared.area_label(String(area))}))
	var days: float = RnDSystem.days_estimate(_node_id, _selected)
	# -1.0 = katkı yok. ASLA BÖLÜNMEZ, asla ∞ yazılmaz (§5.5) — sayı yerine
	# durumun kendi cümlesi.
	parts.append(RnDUiShared.t("RND_DAYS_EST").format({"n": maxi(1, int(ceil(days)))})
		if days > 0.0 else RnDUiShared.t("RND_DAYS_NONE"))
	_footer_info.text = " · ".join(parts)

	for c in _action_slot.get_children():
		_action_slot.remove_child(c)
		c.queue_free()
	var back := RnDUiShared.link(RnDUiShared.t("RND_ACTION_BACK"))
	back.clicked.connect(_on_back)
	_action_slot.add_child(back)

	# Aktif düğümde eylem UYGULA'dır: araştırma zaten koşuyor, değişen yalnız
	# koltuklar (§5.6). Başka her durumda BAŞLAT.
	var running: bool = RnDSystem.active() == _node_id
	var label: String = RnDUiShared.t("RND_ACTION_APPLY" if running else "RND_START")
	var refusal: String = RnDSystem.start_refusal(_node_id, _selected)
	if refusal == "":
		_action_slot.add_child(HRUiShared.action_button(label, _on_commit, true))
		_reason.visible = false
	else:
		_action_slot.add_child(HRUiShared.disabled_button(label, _refusal_text(refusal)))
		_reason.text = _refusal_text(refusal)
		_reason.add_theme_color_override("font_color",
			UiTokens.negative() if refusal == RnDSystem.REFUSE_CASH else UiTokens.INK_MUTED)
		_reason.visible = true


## TEK SEBEP SATIRI. Motorun makine kimliği → oyuncunun cümlesi; hiçbir düğme
## sessizce sönmez (§5.3'ün kendi kuralı).
func _refusal_text(refusal: String) -> String:
	match refusal:
		RnDSystem.REFUSE_NOBODY:
			return RnDUiShared.t("RND_ASSIGN_PICK")
		RnDSystem.REFUSE_ZERO:
			return RnDUiShared.t("RND_ASSIGN_ZERO")
		RnDSystem.REFUSE_STARS:
			var areas: Array = ResearchTree.areas_of(_node_id)
			return RnDUiShared.t("RND_NEED_STARS").format({
				"n": ResearchTree.stars_of(_node_id),
				"area": RnDUiShared.area_label(String(areas[0])) if not areas.is_empty() else ""})
		RnDSystem.REFUSE_CASH:
			return RnDUiShared.t("RND_NEED_CASH").format({
				"money": RnDUiShared.money(ResearchTree.cash_of(_node_id))})
		RnDSystem.REFUSE_CROSS:
			var src: String = ResearchTree.cross_of(_node_id)
			return RnDUiShared.t("RND_NEED_CROSS_NAMED").format({
				"node": ResearchSeam.node_name(src),
				"family": RnDUiShared.family_name(ResearchSeam.family(src))})
		RnDSystem.REFUSE_LOCKED:
			return RnDUiShared.t("RND_NEED_PARENT").format({
				"node": ResearchSeam.node_name(ResearchTree.parent_of(_node_id))})
	return RnDUiShared.t("RND_TREE_CLOSED")


# ---------------------------------------------------------------- etkileşim

func _on_group_input(ev: InputEvent, area: String) -> void:
	if not RnDUiShared.is_left_click(ev):
		return
	_open_groups[area] = not bool(_open_groups.get(area, true))
	_refresh_list.call_deferred()


func _on_row_hover(card: PanelContainer, picked: bool, entered: bool) -> void:
	if card != null and is_instance_valid(card):
		card.add_theme_stylebox_override("panel", _row_box(picked, entered))


func _on_row_input(ev: InputEvent, character_id: String) -> void:
	if not RnDUiShared.is_left_click(ev):
		return
	if _selected.has(character_id):
		_selected.erase(character_id)
	else:
		_selected.append(character_id)
	# ERTELENMİŞ: satırı, kendi `gui_input`'ı hâlâ akarken serbest bırakmak
	# düğümü sinyalin altından çeker (team_panel.gd:619-622 bunu yazıyor).
	# Aynı kişi iki grupta birden görünebildiği için liste TAMAMEN yeniden
	# kurulur — iki onay kutusu tek durumu göstermek zorunda.
	_refresh_list.call_deferred()
	_refresh_footer()


func _on_back() -> void:
	closed.emit()


func _on_commit() -> void:
	if RnDSystem.active() == _node_id:
		# §5.6 — koltukları değiştir. HR bir koltuğu REDDEDEBİLİR (iki-iş
		# defteri); motor kabul ettiğini yazar, biz istediğimizi değil.
		RnDSystem.set_assignees(_selected)
		started.emit()
		return
	var refusal: String = RnDSystem.start(_node_id, _selected)
	if refusal != "":
		# Yarışan bir durum (nakit son anda düştü, kişi ayrıldı): sebebi yaz,
		# paneli kapatma.
		_reason.text = _refusal_text(refusal)
		_reason.visible = true
		_refresh_footer()
		return
	started.emit()
