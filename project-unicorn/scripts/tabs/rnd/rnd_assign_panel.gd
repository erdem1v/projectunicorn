class_name RnDAssignPanel
extends VBoxContainer

# ============================================================================
# AR-GE → ATAMA PANELİ. Düğüm kartının İÇİNDE açılır: gereken alan başına bir grup, her
# grupta onay kutusu, yüz, ad satırı ve alanın becerisi sabit bir sayı sütununda (§8).
# Alanı tutamayan kişi sönük değil, kapalı değil, YOK; iki alanlı bir devam düğümünde
# çift-yeterli biri HER İKİ grupta da görünür. Araştırmanın lideri yok (§5.4 tek toplam).
# İzindeki kişinin satırı Ekip'in izin satırıdır: yüzü gri, adı soluk, etiketi ve kalan
# haftası; sayıları değişmez.
#
# BU DOSYA HİÇBİR SAYI TÜRETMEZ: havuz `RnDSystem.eligible_assignees`, hız
# `RnDSystem.weeks_estimate`, engel `RnDSystem.start_refusal`, yıldızı tutan izindeki kişi
# `RnDSystem.away_star_holder`.
# ============================================================================

## Araştırma başladı / atama uygulandı — kart kendini kapatsın.
signal started
## Oyuncu vazgeçti.
signal closed

const CHEVRON := "res://assets/icons/util/chevron_%s.svg"

var _node_id: String = ""
var _selected: Array[String] = []
var _open_groups: Dictionary = {}      # area -> bool
var _list: VBoxContainer = null
var _foot: HBoxContainer = null
var _why: HBoxContainer = null


func _ready() -> void:
	add_theme_constant_override("separation", UiTokens.SPACE_L)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL


## Panelin tek girişi. Aktif düğümde MEVCUT atananlar önseçilidir — `ata`
## listeyi sıfırdan doldurtmaz, var olanı düzenletir (§5.6). `switch_note` başka bir
## araştırma koşarken Başlat'ın onu durduracağını söyler (§5.7).
func setup(node_id: String, switch_note: String) -> void:
	_node_id = node_id
	for cid in RnDSystem.assigned(node_id):
		_selected.append(String(cid))
	for area in ResearchTree.areas_of(node_id):
		_open_groups[String(area)] = true
	_list = SprintUiShared.column(0)
	add_child(_list)
	if switch_note != "":
		var note := SprintUiShared.box(UiTokens.SPACE_M)
		note.add_child(UiFactory.make_glyph(RnDDetailPanel.INFO, UiTokens.D_ICON_ROW, UiTokens.D_INK_4))
		note.add_child(SprintUiShared.label(switch_note, &"MetaMuted"))
		add_child(note)
	_foot = SprintUiShared.box(UiTokens.SPACE_L)
	add_child(_foot)
	_why = SprintUiShared.box(UiTokens.SPACE_L)
	_why.alignment = BoxContainer.ALIGNMENT_END
	add_child(_why)
	_refresh_list()
	refresh_footer()


## A row's pick: the harness ticks one the same way.
func toggle(character_id: String) -> void:
	if _selected.has(character_id):
		_selected.erase(character_id)
	else:
		_selected.append(character_id)
	# ERTELENMİŞ: satırı, kendi `gui_input`'ı hâlâ akarken serbest bırakmak düğümü
	# sinyalin altından çeker. Aynı kişi iki grupta birden görünebildiği için liste
	# TAMAMEN yeniden kurulur — iki onay kutusu tek durumu göstermek zorunda.
	_refresh_list.call_deferred()
	refresh_footer()


# ---------------------------------------------------------------- liste

func _refresh_list() -> void:
	UiFactory.clear(_list)
	# GEREKEN ALAN BAŞINA BİR GRUP. Kök/dal tek alan, devam iki alan (§5.2).
	for area_raw in ResearchTree.areas_of(_node_id):
		var area := String(area_raw)
		var members: Array[Character] = _group_members(area)
		var is_open: bool = bool(_open_groups.get(area, true))
		_list.add_child(_group_header(area, members.size(), is_open))
		_list.add_child(HSeparator.new())
		if not is_open:
			continue
		if members.is_empty():
			# BOŞ HAVUZ BOŞ PANEL DEĞİLDİR (§7: "Bu alanda kimse yok.").
			var empty := SprintUiShared.label(RnDUiShared.t("RND_ASSIGN_EMPTY"), &"NoteMuted")
			empty.custom_minimum_size.y = UiTokens.D_H_ROW
			empty.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			_list.add_child(empty)
			continue
		for c in members:
			_list.add_child(_person_row(c, area))


## Havuz motorun (§5.3): rolü alanı TUTABİLEN çalışanlar + KURUCU HER ZAMAN.
func _group_members(area: String) -> Array[Character]:
	var out: Array[Character] = []
	for c in RnDSystem.eligible_assignees(_node_id):
		if HRConstants.can_hold_area(c.role, area, c.category):
			out.append(c)
	return out


## "▾ YAZILIM (3)" and, at the far end, whether the area's stars are met. The tag reads the engine's star gate,
## so it gives Başlat's RND_NEED_AREA answer (someone on leave does not count).
func _group_header(area: String, count: int, is_open: bool) -> HBoxContainer:
	var row := SprintUiShared.box(UiTokens.SPACE_M)
	row.custom_minimum_size.y = UiTokens.D_H_ROW_SM
	row.add_child(UiFactory.make_glyph(CHEVRON % ("down" if is_open else "right"), UiTokens.D_ICON_ROW, UiTokens.D_INK_3))
	row.add_child(SprintUiShared.label(Fmt.upper(HRConstants.area_label(area)), &"GroupLabel"))
	row.add_child(SprintUiShared.label(RnDUiShared.t("PROD_TEAM_GROUP_COUNT").format({"n": count}), &"Caption"))
	row.add_child(RnDUiShared.spacer())
	var met: bool = RnDSystem.area_has_star(_node_id, area)
	row.add_child(UiFactory.D_tag(RnDUiShared.t("RND_REQ_MET" if met else "RND_REQ_UNMET"), &"neutral" if met else &"warn"))
	HRUiShared.set_mouse_ignore(row)
	row.mouse_filter = Control.MOUSE_FILTER_STOP
	row.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	row.gui_input.connect(func(ev: InputEvent) -> void:
		if UiFactory.is_left_click(ev):
			_open_groups[area] = not is_open
			_refresh_list.call_deferred())
	return row


## Check, face, the name line (the role and what they are on; a leave or a course with its weeks) and the
## area's skill in its column.
func _person_row(c: Character, area: String) -> PanelContainer:
	var row := HRUiShared.D_row(_selected.has(c.id), &"CardRow")
	row.custom_minimum_size.y = UiTokens.D_H_ROW_SM
	row.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	row.gui_input.connect(func(ev: InputEvent) -> void:
		if UiFactory.is_left_click(ev):
			toggle(c.id))
	var cells := SprintUiShared.box(0)
	row.add_child(cells)
	var columns: Vector3i = UiTokens.D_RND_ASSIGN_COLUMNS
	var check := PanelContainer.new()
	check.theme_type_variation = &"CheckSquareOn" if _selected.has(c.id) else &"CheckSquare"
	check.custom_minimum_size = Vector2.ONE * UiTokens.D_CHECK_BOX
	if _selected.has(c.id):
		check.add_child(UiFactory.make_glyph(RnDTreeView.CHECK, UiTokens.D_ICON_PART, UiTokens.D_SURFACE_0))
	cells.add_child(_cell(check, columns.x))
	var on_leave: bool = c.status == HRConstants.STATUS_ON_LEAVE
	cells.add_child(_cell(UiFactory.make_person_avatar(c.character_name, c.look, UiTokens.D_AVATAR_ROW_SM, on_leave),
		columns.y))
	var line := SprintUiShared.box(UiTokens.SPACE_M)
	line.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	line.add_child(SprintUiShared.label(c.character_name, &"DataMedium" if on_leave else &"DataStrong",
		UiTokens.D_INK_3 if on_leave else null))
	var away: Array = HRUiShared.away_state(c)
	if not away.is_empty():
		line.add_child(UiFactory.D_tag(away[0], &"neutral"))
		line.add_child(SprintUiShared.label(Fmt.weeks(away[1]), &"CondCaption"))
	var role := SprintUiShared.label(_role_line(c, away.is_empty()), &"CondCaption")
	role.clip_text = true
	role.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	role.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	line.add_child(role)
	cells.add_child(line)
	cells.add_child(_cell(HRUiShared.D_skill_figure(int(c.role_stats.get(area, 0)), &""), columns.z))
	HRUiShared.set_mouse_ignore(cells)
	return row


## A column `width` wide, its part centred.
func _cell(part: Control, width: int) -> CenterContainer:
	var cell := CenterContainer.new()
	cell.custom_minimum_size.x = width
	cell.add_child(part)
	return cell


## The role, and what they are on today; the founder's row is the founder's task alone, someone away their role.
func _role_line(c: Character, at_work: bool) -> String:
	if c.category == "founder":
		return HRSystem.founder_task_label()
	var title: String = HRUiShared.roster_title(c)
	return "%s · %s" % [title, HRLedger.task_text(c)] if at_work else title


# ---------------------------------------------------------------- alt bant

## The area and the live estimate, then Geri and Başlat (Uygula on the running research); under them what
## keeps Başlat closed, and for a star gate held by someone away, who. Read again on every tick of a box and
## while a decision waits.
func refresh_footer() -> void:
	UiFactory.clear(_foot)
	_foot.add_child(UiFactory.make_glyph(RnDDetailPanel.CLOCK, UiTokens.D_ICON_ROW, UiTokens.D_INK_3))
	_foot.add_child(SprintUiShared.label(" · ".join(RnDUiShared.area_parts(_node_id)), &"NoteMuted"))
	_foot.add_child(SprintUiShared.label("·", &"CaptionFaint"))
	var weeks: float = RnDSystem.weeks_estimate(_node_id, _selected)
	# -1.0 = katkı yok (§5.5): sayı yerine durumun kendi cümlesi, asla ∞.
	_foot.add_child(SprintUiShared.label(RnDUiShared.weeks_line("RND_WEEKS_EST", weeks) if weeks > 0.0
		else RnDUiShared.t("RND_WEEKS_NONE"), &"DataText"))
	_foot.add_child(RnDUiShared.spacer())
	_foot.add_child(SprintUiShared.button(RnDUiShared.t("RND_ACTION_BACK"), &"GhostButton", closed.emit))
	# Aktif düğümde eylem UYGULA'dır: araştırma zaten koşuyor, değişen yalnız koltuklar (§5.6).
	var go := SprintUiShared.button(RnDUiShared.t("RND_ACTION_APPLY" if RnDSystem.active() == _node_id else "RND_START"),
		&"PrimaryButtonDark", _on_commit)
	var gated: bool = EventGate.active_id() != ""
	var refusal: String = RnDSystem.start_refusal(_node_id, _selected)
	go.disabled = gated or refusal != ""
	_foot.add_child(go)
	UiFactory.clear(_why)
	if gated:
		_why.add_child(SprintUiShared.label(RnDUiShared.t("GATE_ANSWER_FIRST"), &"MetaMuted"))
	elif refusal != "":
		var holder: Character = RnDSystem.away_star_holder(_node_id) if refusal == RnDSystem.REFUSE_STARS else null
		if holder != null:
			_why.add_child(SprintUiShared.label(RnDUiShared.t("RND_NEED_AREA_AWAY").format({"name": holder.character_name}),
				&"MetaMuted"))
			_why.add_child(VSeparator.new())
		_why.add_child(RnDUiShared.refusal_line(_node_id, refusal, &"MetaText"))
	_why.visible = _why.get_child_count() > 0


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
		refresh_footer()
