class_name RnDAssignPanel
extends VBoxContainer

# ============================================================================
# AR-GE → ATAMA PANELİ. Detay kartının İÇİNDE açılır; Ekip'in alan-gruplu
# akordeonuyla aynı gramer (§8).
#
# NEDEN ProductTeamPanel DEĞİL — dördü de yapısal:
#   1. O panel FİLTRELER (arama/alan/müsaitlik satırı); burada alanı tutamayan
#      kişi sönük değil, kapalı değil, YOK.
#   2. Onun gruplama anahtarı KİŞİ BAŞINA TEK ALANDIR; iki alanlı bir devam
#      düğümünde çift-yeterli biri HER İKİ grupta da görünmek zorunda.
#   3. Onda LİDER SATIRI var; araştırmanın lideri yok (§5.4 tek toplam).
#   4. Onun sütunları dar kart sütununa TEK SATIRDA sığmıyor; bu yüzden buradaki
#      satır İKİ SATIRLIK.
#
# BU DOSYA HİÇBİR SAYI TÜRETMEZ: havuz `RnDSystem.eligible_assignees`, hız
# `RnDSystem.days_estimate`, engel `RnDSystem.start_refusal`.
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
	for cid in RnDSystem.assigned(node_id):
		_selected.append(String(cid))
	for area in ResearchTree.areas_of(node_id):
		_open_groups[String(area)] = true
	_build_shell()
	_refresh_list()
	_refresh_footer()


# ---------------------------------------------------------------- kabuk

func _build_shell() -> void:
	_list = VBoxContainer.new()
	_list.add_theme_constant_override("separation", 0)
	_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_child(_list)

	add_child(HRUiShared.hairline())

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

	# TEK SEBEP SATIRI, düğmenin ALTINDA. Boşken görünmez.
	_reason = UiFactory.make_label("", &"RowMeta", UiTokens.INK_MUTED)
	_reason.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_reason.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_reason.visible = false
	add_child(_reason)


# ---------------------------------------------------------------- liste

func _refresh_list() -> void:
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
			# BOŞ HAVUZ BOŞ PANEL DEĞİLDİR (§7: "Bu alanda kimse yok.").
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
func _group_header(area: String, members: Array[Character], is_open: bool) -> Control:
	var bar := PanelContainer.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = UiTokens.SURFACE_FRAME
	sb.border_color = UiTokens.DIVIDER_LIGHT
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

	var ink: Color = UiTokens.INK_MUTED if is_open else UiTokens.INK_DIM
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", UiTokens.SPACE_M)
	# Evde yalnız aşağı/yukarı şevron var; kapalı durum aşağı şevronun çeyrek tur
	# döndürülmüşü, ikinci bir ikon dosyası yok.
	var chevron: TextureRect = HRUiShared.chevron(CHEVRON_PX, ink)
	if not is_open:
		chevron.pivot_offset = Vector2(CHEVRON_PX, CHEVRON_PX) * 0.5
		chevron.rotation = -PI * 0.5
	row.add_child(chevron)
	row.add_child(UiFactory.make_label(HRConstants.area_label(area), &"RowMeta", ink))
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


## Karşılandı = grupta ham puanı (role_stats) ★eşiğine ULAŞAN biri var (§5.2 · §12.6).
func _area_met(area: String, members: Array[Character]) -> bool:
	var want: int = ResearchTree.stars_of(_node_id) * HRConstants.POINTS_PER_STAR
	for c in members:
		if int(c.role_stats.get(area, 0)) >= want:
			return true
	return false


## İKİ SATIRLIK SATIR: 1. satır ad + alan + yıldızlar, 2. satır ROL + müsaitlik.
## Aynı beş bilgi, dar sütuna sığsın diye iki satıra bölünmüş.
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
	line1.add_child(UiFactory.make_label(HRConstants.area_label(area), &"MicroLabel"))
	line1.add_child(StarRating.make(int(c.role_stats.get(area, 0)), STAR_PX))
	col.add_child(line1)

	# --- 2. satır: ROL ................ müsaitlik bayrağı. Kurucunun seviyesi yok,
	# `job_title` ona ön ek takardı.
	var line2 := HBoxContainer.new()
	line2.add_theme_constant_override("separation", UiTokens.SPACE_S)
	var title: String = HRConstants.role_label(HRConstants.ROLE_FOUNDER) \
		if c.category == "founder" else HRConstants.job_title(c.role, c.level)
	line2.add_child(UiFactory.make_label(Fmt.upper(title), &"MicroLabel"))
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
	sb.set_border_width_all(UiTokens.BORDER_HAIRLINE)
	sb.border_width_left = SELECT_BAR_W
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


## "Eğitimde · 4g sonra katılır" / "İzinde · 12g sonra katılır". Müsait kişide
## BOŞ döner. Gün sayıları domain'in kendi seam'lerinden; burada tarih
## aritmetiği yapılmıyor.
func _availability_text(c: Character) -> String:
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
	var parts: PackedStringArray = RnDUiShared.area_parts(_node_id)
	var days: float = RnDSystem.days_estimate(_node_id, _selected)
	# -1.0 = katkı yok (§5.5): sayı yerine durumun kendi cümlesi, asla ∞.
	parts.append(RnDUiShared.t("RND_DAYS_EST").format({"n": RnDUiShared.whole_days(days)})
		if days > 0.0 else RnDUiShared.t("RND_DAYS_NONE"))
	_footer_info.text = " · ".join(parts)

	for c in _action_slot.get_children():
		_action_slot.remove_child(c)
		c.queue_free()
	var back := RnDUiShared.link(RnDUiShared.t("RND_ACTION_BACK"))
	back.clicked.connect(closed.emit)
	_action_slot.add_child(back)

	# Aktif düğümde eylem UYGULA'dır: araştırma zaten koşuyor, değişen yalnız
	# koltuklar (§5.6). Başka her durumda BAŞLAT.
	var label: String = RnDUiShared.t(
		"RND_ACTION_APPLY" if RnDSystem.active() == _node_id else "RND_START")
	var refusal: String = RnDSystem.start_refusal(_node_id, _selected)
	_reason.visible = refusal != ""
	if refusal == "":
		_action_slot.add_child(HRUiShared.action_button(label, _on_commit, true))
		return
	var why: String = RnDUiShared.refusal_text(_node_id, refusal)
	_action_slot.add_child(HRUiShared.disabled_button(label, why))
	_reason.text = why
	_reason.add_theme_color_override("font_color",
		UiTokens.negative() if refusal == RnDSystem.REFUSE_CASH else UiTokens.INK_MUTED)


# ---------------------------------------------------------------- etkileşim

func _on_group_input(ev: InputEvent, area: String) -> void:
	if not RnDUiShared.is_left_click(ev):
		return
	_open_groups[area] = not bool(_open_groups.get(area, true))
	_refresh_list.call_deferred()


func _on_row_hover(card: PanelContainer, picked: bool, entered: bool) -> void:
	card.add_theme_stylebox_override("panel", _row_box(picked, entered))


func _on_row_input(ev: InputEvent, character_id: String) -> void:
	if not RnDUiShared.is_left_click(ev):
		return
	if _selected.has(character_id):
		_selected.erase(character_id)
	else:
		_selected.append(character_id)
	# ERTELENMİŞ: satırı, kendi `gui_input`'ı hâlâ akarken serbest bırakmak düğümü
	# sinyalin altından çeker. Aynı kişi iki grupta birden görünebildiği için liste
	# TAMAMEN yeniden kurulur — iki onay kutusu tek durumu göstermek zorunda.
	_refresh_list.call_deferred()
	_refresh_footer()


func _on_commit() -> void:
	if RnDSystem.active() == _node_id:
		# §5.6 — koltukları değiştir. HR bir koltuğu REDDEDEBİLİR; motor kabul
		# edileni yazar, panelin istediğini değil.
		RnDSystem.set_assignees(_selected)
		started.emit()
	elif RnDSystem.start(_node_id, _selected) == "":
		started.emit()
	else:
		# Yarışan bir durum (nakit son anda düştü, kişi ayrıldı): panel açık kalır,
		# alt bant sebebi yeniden okur.
		_refresh_footer()
