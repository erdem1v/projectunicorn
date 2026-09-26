extends Control

# ============================================================================
# Atlas Seçme & Yerleştirme modalı — §10.1 (rol + seviye) ve §10.3 (aday dosyaları).
# Tek kabuk, iki hal; hangisinin açılacağını arayışın motor durumu söyler
# (HRSearchSystem.get_state).
#
# Düzen kodda kurulur, .tscn kökü boş. process_mode = ALWAYS: pause-gated UI; saate
# dokunmaz.
#
# ADIM 2 SEVİYEDİR (§3): seviye kişide saklanır, unvanı türetir ve terfinin değiştirdiği
# alandır.
#
# ARAMA ÜCRETSİZDİR (§10): adım 2'de para okunmaz. Tek ücret komisyondur ve işe alımda,
# aday kartından okunarak ödenir; runway satırı da orada — ekonomik bağlam somut maaşın
# olduğu ana aittir.
#
# Her rakam motordan: preview_search ve preview_hire.
# ============================================================================

signal state_changed          # arayış başladı / iptal edildi / işe alım oldu → sekme tazelensin

## İki adımın genişliği tasarımdan; dosya adımı üç kartı yan yana taşıyor.
const PANEL_SEARCH := Vector2(1440, 0)
const PANEL_FILES := Vector2(1560, 0)

var _root_box: VBoxContainer = null
var _panel: PanelContainer = null
var _selected_role: String = ""
## -1 = seçilmedi. Seviye bir INT (§3: 0/1/2).
var _selected_level: int = -1


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_anchors_preset(Control.PRESET_FULL_RECT)
	var dimmer := ColorRect.new()
	dimmer.set_anchors_preset(Control.PRESET_FULL_RECT)
	dimmer.color = UiTokens.SCRIM_MODAL
	dimmer.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(dimmer)
	_panel = PanelContainer.new()
	_panel.theme_type_variation = &"ModalPanel"
	_panel.set_anchors_preset(Control.PRESET_CENTER)
	_panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_panel.grow_vertical = Control.GROW_DIRECTION_BOTH
	add_child(_panel)
	var margin := MarginContainer.new()
	for side in ["margin_left", "margin_right", "margin_top", "margin_bottom"]:
		margin.add_theme_constant_override(side, 22)
	_panel.add_child(margin)
	_root_box = VBoxContainer.new()
	_root_box.add_theme_constant_override("separation", 12)
	margin.add_child(_root_box)


func populate() -> void:
	# add_child SONRASI çağrılır (ev konvansiyonu). Pre-ready çağrıya karşı guard.
	if not is_node_ready():
		await ready
	_rebuild()


func _rebuild() -> void:
	for c in _root_box.get_children():
		_root_box.remove_child(c)
		c.queue_free()
	# Kimlik satırı: ATLAS RECRUITMENT.
	var masthead := HBoxContainer.new()
	masthead.add_theme_constant_override("separation", 13)
	masthead.add_child(UiFactory.make_avatar("A", 32))
	masthead.add_child(UiFactory.make_label(HRConstants.search_agency_name(), &"RowName"))
	_root_box.add_child(masthead)
	if HRSearchSystem.get_state() == HRConstants.SEARCH_FILES_READY:
		_panel.custom_minimum_size = PANEL_FILES
		_build_files_step()
	else:
		_panel.custom_minimum_size = PANEL_SEARCH
		_build_search_step()


# --- ADIM 1 · ROL + ADIM 2 · SEVİYE (11a) -----------------------------------

func _build_search_step() -> void:
	_root_box.add_child(_step_header(tr("HR_ATLAS_STEP_ROLE")))

	var grid := GridContainer.new()
	grid.columns = 3
	# Üç eşit sütun: GridContainer boşluğu genişleyen sütunlara eşit dağıtır — şartı her
	# kartın EXPAND_FILL taşıması (_card).
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", 12)
	grid.add_theme_constant_override("v_separation", 12)
	for role in HRConstants.EMPLOYEE_ROLES:
		var role_id: String = String(role)
		var lock_key: String = HRConstants.role_lock_reason_key(role_id)
		var card := _role_card(HRConstants.role_label(role_id),
			HRConstants.role_phase_hint(role_id), tr(lock_key) if lock_key != "" else "",
			_selected_role == role_id)
		if lock_key == "":
			_make_selectable(card, func() -> void: _selected_role = role_id)
		grid.add_child(card)
	# §10.6: gelecek rollerin kartları kilitli-görünür durur — çizilir, sönüktür, tıklanamaz,
	# gerekçesini gösterir. EMPLOYEE_ROLES'a girmezler.
	for role in HRConstants.FUTURE_ROLES:
		grid.add_child(_role_card(HRConstants.future_role_label(String(role)),
			HRConstants.future_role_hint(String(role)), tr(HRConstants.FUTURE_ROLE_LOCK_KEY), false))
	_root_box.add_child(grid)

	_root_box.add_child(_step_header(tr("HR_ATLAS_STEP_LEVEL")))
	var levels := HBoxContainer.new()
	levels.add_theme_constant_override("separation", 12)
	for level in HRConstants.LEVELS:
		levels.add_child(_level_card(int(level)))
	_root_box.add_child(levels)

	# §10'un iki cümlesi: "bir hafta sonra aday listesi gelir" ve "ücretsizdir; tek ücret
	# komisyondur".
	var meta := HBoxContainer.new()
	meta.add_theme_constant_override("separation", 10)
	meta.add_child(UiFactory.make_label(tr("HR_ATLAS_ARRIVAL").format(
		{"span": tr("HR_ATLAS_ARRIVAL_SPAN")}), &"RowMeta", UiTokens.INK_MUTED))
	meta.add_child(UiFactory.make_label("·", &"RowMeta", UiTokens.INK_DIM))
	meta.add_child(UiFactory.make_label(tr("HR_ATLAS_FREE_NOTE"), &"RowMeta", UiTokens.INK_DIM))
	_root_box.add_child(meta)

	_root_box.add_child(HRUiShared.hairline())
	_root_box.add_child(_search_footer())


func _step_header(text: String) -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	row.add_child(UiFactory.make_label(UiTokens.tr_upper(text), &"SectionAmber"))
	var rule := HRUiShared.hairline()
	rule.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rule.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(rule)
	return row


## Seçim kartı kabuğu. SEÇİLİ: 1px amber kenar + 2px amber sol kenar + amber yıkama.
## Kart sütununu doldurur; yoksa kartlar metin uzunluğuna göre farklı genişlikte çıkar.
func _card(selected: bool, pad_v: float) -> PanelContainer:
	var card := PanelContainer.new()
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var sb := StyleBoxFlat.new()
	sb.set_corner_radius_all(UiTokens.RADIUS_S)
	sb.content_margin_left = 16.0
	sb.content_margin_right = 16.0
	sb.content_margin_top = pad_v
	sb.content_margin_bottom = pad_v
	sb.set_border_width_all(UiTokens.BORDER_HAIRLINE)
	if selected:
		sb.bg_color = UiTokens.AMBER_WASH
		sb.border_width_left = UiTokens.BORDER_FOCUS
		sb.border_color = UiTokens.ACCENT
	else:
		sb.bg_color = UiTokens.SURFACE_FRAME
		sb.border_color = UiTokens.SEPARATOR
	card.add_theme_stylebox_override("panel", sb)
	return card


func _make_selectable(card: Control, on_pick: Callable) -> void:
	card.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	card.gui_input.connect(func(ev: InputEvent) -> void:
		var mb := ev as InputEventMouseButton
		if mb != null and mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT:
			on_pick.call()
			_rebuild())


## Rol kartı. KİLİTLİ (`lock_text` dolu): %60 opaklık, ad soluk, kilit glifi, gerekçe
## amber satırda — ve tıklama hiç bağlanmıyor (kilitli kart "reddedilen" değil, "kapalı").
func _role_card(label: String, hint_text: String, lock_text: String, selected: bool) -> PanelContainer:
	var locked: bool = lock_text != ""
	var card := _card(selected, 14.0)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 7)
	card.add_child(col)

	var title_row := HBoxContainer.new()
	title_row.add_theme_constant_override("separation", 8)
	title_row.add_child(UiFactory.make_label(label, &"NameSerif",
		UiTokens.CREAM_DIM if locked else UiTokens.INK))
	if locked:
		title_row.add_child(HRUiShared.lock_glyph(12, UiTokens.CREAM_DIM))
	col.add_child(title_row)

	var hint := UiFactory.make_label(hint_text, &"RowMeta", UiTokens.CREAM_DIM)
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	col.add_child(hint)

	if locked:
		col.add_child(UiFactory.make_label(lock_text, &"RowMeta", UiTokens.ACCENT))
		card.modulate.a = 0.6
	return card


## §3 seviye kartı. Etiket seviye ADIDIR (Junior · Orta · Kıdemli) ve büyük harfe
## çevrilmez: tr_upper Türkçe büyütür ve "Junior"ı noktalı İ ile JUNİOR yapar.
func _level_card(level: int) -> Control:
	var selected: bool = _selected_level == level
	var card := _card(selected, 13.0)
	card.add_child(UiFactory.make_label(
		HRConstants.level_label(level), &"RowName",
		UiTokens.ACCENT if selected else UiTokens.INK_MUTED))
	_make_selectable(card, func() -> void: _selected_level = level)
	return card


## Alt bar: VAZGEÇ · boşluk · seçim özeti · ARAYIŞ BAŞLAT. CTA'da rakam yok (§10: arama
## ücretsiz).
func _search_footer() -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 14)
	row.add_child(HRUiShared.action_button(tr("HR_ATLAS_CANCEL"), _close))
	var pad := Control.new()
	pad.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(pad)

	var cta: String = tr("HR_ATLAS_START")
	if _selected_role == "" or _selected_level < 0:
		row.add_child(HRUiShared.disabled_button(cta, tr("HR_ATLAS_NEED_SELECTION")))
		return row

	var pv: Dictionary = HRSearchSystem.preview_search(_selected_role, _selected_level)
	# Seçim özeti türetilmiş unvandır (§3): "Kıdemli Yazılım Mühendisi".
	row.add_child(UiFactory.make_label(String(pv.get("job_title", "")),
		&"RowMeta", UiTokens.INK_DIM))
	if bool(pv.get("can_start", false)):
		row.add_child(HRUiShared.action_button(cta, _on_start_pressed, true))
	else:
		row.add_child(HRUiShared.disabled_button(cta, _first_warning(pv)))
	return row


func _first_warning(pv: Dictionary) -> String:
	var warnings: Array = pv.get("warnings", []) as Array
	return String(warnings[0]) if not warnings.is_empty() else ""


# --- ADAY DOSYALARI (11b) ---------------------------------------------------

func _build_files_step() -> void:
	var files: Array = HRSearchSystem.get_files()
	_root_box.add_child(_step_header(
		tr("HR_ATLAS_FILES_COUNT").format({"n": files.size()})))

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 16)
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	for i in files.size():
		row.add_child(_file_card(i, files[i]))
	_root_box.add_child(row)

	_root_box.add_child(HRUiShared.hairline())
	var footer := HBoxContainer.new()
	footer.alignment = BoxContainer.ALIGNMENT_CENTER
	footer.add_child(HRUiShared.action_button(
		UiTokens.tr_upper(tr("HR_ATLAS_TAKE_NONE")), _on_dismiss_pressed))
	_root_box.add_child(footer)


## Aday kartı (11b): DOSYA i/n · baş harf + ad + unvan · rol açıklaması · yıldız şeridi
## (iki alan · Liderlik) · tek trait çipi · esneyen boşluk (kartlar eşit yükseklik) ·
## MAAŞ TALEBİ · İŞE AL · KOMİSYON · RUNWAY.
func _file_card(index: int, file: Dictionary) -> Control:
	var pv: Dictionary = HRSearchSystem.preview_hire(index)
	var role_id: String = String(file.get("role", ""))
	var axes: Dictionary = file.get("axes", {}) as Dictionary
	var salary: int = int(file.get("salary", 0))
	var cand_name: String = String(file.get("name", ""))

	var card := PanelContainer.new()
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var sb := StyleBoxFlat.new()
	sb.bg_color = UiTokens.SURFACE_FRAME
	sb.set_border_width_all(UiTokens.BORDER_HAIRLINE)
	sb.border_color = UiTokens.SEPARATOR
	sb.set_corner_radius_all(UiTokens.RADIUS_S)
	card.add_theme_stylebox_override("panel", sb)

	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 14)
	card.add_child(col)

	col.add_child(UiFactory.make_label(tr("HR_ATLAS_FILE_N").format(
		{"i": index + 1, "n": HRConstants.CANDIDATE_COUNT}), &"ColumnHeader", UiTokens.INK_DIM))
	col.add_child(HRUiShared.hairline())

	var head := HBoxContainer.new()
	head.add_theme_constant_override("separation", 12)
	head.add_child(UiFactory.make_avatar(UiFactory.initials_of(cand_name), 34))
	var who := VBoxContainer.new()
	who.add_theme_constant_override("separation", 3)
	who.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	who.add_child(UiFactory.make_label(cand_name, &"NameSerif"))
	# §10.3: ad, UNVAN (§3 — seviye + rol adından türer), rol açıklaması.
	who.add_child(UiFactory.make_label(
		UiTokens.tr_upper(String(pv.get("job_title", HRConstants.role_label(role_id)))),
		&"MicroLabel"))
	head.add_child(who)
	col.add_child(head)

	var hint := UiFactory.make_label(
		HRConstants.role_phase_hint(role_id), &"RowMeta", UiTokens.CREAM_DIM)
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	col.add_child(hint)

	col.add_child(HRUiShared.hairline())
	var stars := HBoxContainer.new()
	stars.add_theme_constant_override("separation", 26)
	stars.add_child(HRUiShared.area_stars_row(role_id, axes, 14))
	stars.add_child(HRUiShared._v_hairline(28))
	stars.add_child(StarRating.labelled(
		HRConstants.area_label(HRConstants.SKILL_LEADERSHIP),
		int(axes.get(HRConstants.SKILL_LEADERSHIP, 0)), 14))
	col.add_child(stars)
	col.add_child(HRUiShared.hairline())

	# Trait çipi nötr; hover ad + etki.
	var traits: Array = file.get("traits", []) as Array
	if not traits.is_empty():
		col.add_child(HRUiShared.trait_row(traits, true))

	var stretch := Control.new()
	stretch.size_flags_vertical = Control.SIZE_EXPAND_FILL
	col.add_child(stretch)

	var ask := HBoxContainer.new()
	var ask_cap := UiFactory.make_label(
		tr("HR_ATLAS_SALARY_LABEL"), &"RowMeta", UiTokens.INK_DIM)
	ask_cap.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	ask.add_child(ask_cap)
	ask.add_child(UiFactory.make_label(HRUiShared.money(salary), &"MetricValueInk"))
	ask.add_child(UiFactory.make_label(tr("HR_PER_MONTH"), &"RowMeta", UiTokens.INK_DIM))
	col.add_child(ask)

	var cta: String = tr("HR_ATLAS_HIRE").format({"amount": HRUiShared.money(salary)})
	var hire_btn: Button
	if bool(pv.get("affordable", false)):
		hire_btn = HRUiShared.action_button(cta, _on_hire_pressed.bind(index), true)
	else:
		hire_btn = HRUiShared.disabled_button(cta, _first_warning(pv))
	hire_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col.add_child(hire_btn)

	var comm := HBoxContainer.new()
	var comm_cap := UiFactory.make_label(
		tr("HR_ATLAS_COMMISSION_LABEL"), &"RowMeta", UiTokens.INK_DIM)
	comm_cap.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	comm.add_child(comm_cap)
	comm.add_child(UiFactory.make_label(
		"+ %s" % HRUiShared.money(int(pv.get("commission", 0))), &"RowMeta", UiTokens.INK_MUTED))
	col.add_child(comm)

	col.add_child(_runway_strip(pv))
	return card


## RUNWAY şeridi: "6 ay → 1 ay", sonraki değer kırmızı. Çift okuma ve kırmızı kararı tek
## seam'den (UiTokens.net_runway_pair): tam aya yuvarlanan iki değer aynı okunurken şerit
## kırmızı yanmasın diye karar epsilon'lu.
func _runway_strip(pv: Dictionary) -> Control:
	var pair: Dictionary = UiTokens.net_runway_pair(
		float(pv.get("runway_before", 0.0)), float(pv.get("runway_after", 0.0)))
	var worse: bool = bool(pair["changed"])

	var strip := PanelContainer.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = UiTokens.negative_bg() if worse else UiTokens.SURFACE_FRAME
	sb.set_border_width_all(UiTokens.BORDER_HAIRLINE)
	sb.border_color = UiTokens.negative_rule() if worse else UiTokens.SEPARATOR
	sb.set_corner_radius_all(UiTokens.RADIUS_S)
	sb.content_margin_left = 12.0
	sb.content_margin_right = 12.0
	sb.content_margin_top = 10.0
	sb.content_margin_bottom = 10.0
	strip.add_theme_stylebox_override("panel", sb)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 9)
	row.add_child(UiFactory.make_label(
		tr("HR_ATLAS_RUNWAY_LABEL"), &"ColumnHeader", UiTokens.INK_DIM))
	row.add_child(UiFactory.make_label(
		String(pair["before"]), &"RowMeta", UiTokens.INK_MUTED))
	row.add_child(UiFactory.make_label("→", &"RowMeta", UiTokens.INK_DIM))
	row.add_child(UiFactory.make_label(String(pair["after"]), &"RowName",
		UiTokens.negative() if worse else UiTokens.INK_MUTED))
	strip.add_child(row)
	return strip


func _on_start_pressed() -> void:
	if HRSearchSystem.start_search(_selected_role, _selected_level):
		state_changed.emit()
		_close()


func _on_hire_pressed(index: int) -> void:
	if HRSearchSystem.hire(index) != null:
		state_changed.emit()
		_close()


func _on_dismiss_pressed() -> void:
	# Kayıp para değil ZAMAN (§10): onay yeniden beklenecek haftayı sayıyor. ConfirmModal
	# ModalLayer'a (layer 10) gider, bu modal PanelLayer'da (layer 9) — onay hep üstte.
	EventBus.confirm_requested.emit({
		"title": tr("HR_ATLAS_TAKE_NONE"),
		"body": tr("HR_ATLAS_CLOSE_BODY").format({"span": tr("HR_ATLAS_ARRIVAL_SPAN")}),
		"confirm_text": tr("HR_ATLAS_CLOSE_OK"),
		"cancel_text": tr("UI_DISMISS"),
		"on_confirm": _do_dismiss,
	})


func _do_dismiss() -> void:
	if HRSearchSystem.dismiss_files():
		state_changed.emit()
		_close()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_close()


func _close() -> void:
	queue_free()
