extends Control

# ============================================================================
# Atlas Seçme & Yerleştirme modalı — Kare 2 (rol + bütçe bandı) ve Kare 4 (aday
# dosyaları). Tek kabuk, iki hal; hangisinin açılacağını arayışın motor durumu
# söyler (HRSearchSystem.get_state).
#
# Düzen kodda kurulur, .tscn kökü boş (event_modal / ending_scene idiomu).
# process_mode = ALWAYS: pause-gated UI. Saate DOKUNULMAZ — bu kod tabanında
# sekmeler ve sekme modalları saati oynatmaz.
#
# MOCKUP'TAN BİLİNÇLİ SAPMA (tasarım dokümanı kazanır): Kare 2'nin band adımında
# "runway 5,2 → ~3,4 ay" satırı VAR, burada YOK. Tasarım dokümanı band seçiminde
# runway etkisi gösterilmez diyor; ekonomik bağlam somut maaşın olduğu ana, yani
# aday kartına ait. Runway satırı orada (Kare 4) basılıyor.
#
# Her rakam motordan: preview_search (22 anahtar) ve preview_hire (22 anahtar). Tek
# aritmetik BİÇİMLEMEdir (komisyon oranının kesirden yüzdeye çevrilmesi).
#
# # WORKING TR — oyuncuya görünen tüm metin çalışma metni; ses geçişi sonra.
# ============================================================================

signal state_changed          # arayış başladı / iptal edildi / işe alım oldu → sekme tazelensin

const PANEL_MIN := Vector2(720, 0)

var _root_box: VBoxContainer = null
var _selected_role: String = ""
var _selected_band: String = ""


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_anchors_preset(Control.PRESET_FULL_RECT)
	var dimmer := ColorRect.new()
	dimmer.set_anchors_preset(Control.PRESET_FULL_RECT)
	dimmer.color = UiTokens.SCRIM_MODAL
	dimmer.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(dimmer)
	var center := PanelContainer.new()
	center.theme_type_variation = &"ModalPanel"
	center.set_anchors_preset(Control.PRESET_CENTER)
	center.grow_horizontal = Control.GROW_DIRECTION_BOTH
	center.grow_vertical = Control.GROW_DIRECTION_BOTH
	center.custom_minimum_size = PANEL_MIN
	add_child(center)
	var margin := MarginContainer.new()
	for side in ["margin_left", "margin_right", "margin_top", "margin_bottom"]:
		margin.add_theme_constant_override(side, 22)
	center.add_child(margin)
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
	_add_masthead()
	if HRSearchSystem.get_state() == HRConstants.SEARCH_FILES_READY:
		_build_files_step()
	else:
		_build_search_step()


func _add_masthead() -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	row.add_child(UiFactory.make_avatar("A", 30))
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 2)
	col.add_child(UiFactory.make_label(
		UiTokens.tr_upper(HRConstants.search_agency_name()), &"SectionLabel"))
	col.add_child(UiFactory.make_label(
		tr("HR_ATLAS_QUOTE"), &"QuoteSerif"))
	row.add_child(col)
	_root_box.add_child(row)
	_root_box.add_child(HRUiShared.hairline())


# --- ADIM 1-2: rol + bant (Kare 2) ------------------------------------------

func _build_search_step() -> void:
	_root_box.add_child(UiFactory.make_section_header(tr("HR_ATLAS_STEP_ROLE")))
	var grid := GridContainer.new()
	grid.columns = 3
	grid.add_theme_constant_override("h_separation", 10)
	grid.add_theme_constant_override("v_separation", 8)
	for role_id in HRConstants.EMPLOYEE_ROLES:
		grid.add_child(_role_card(String(role_id)))
	_root_box.add_child(grid)

	_root_box.add_child(UiFactory.make_section_header(tr("HR_ATLAS_STEP_BAND")))
	var bands := HBoxContainer.new()
	bands.add_theme_constant_override("separation", 10)
	for band_id in HRConstants.BANDS:
		bands.add_child(_band_card(String(band_id)))
	_root_box.add_child(bands)

	_root_box.add_child(HRUiShared.hairline())
	_root_box.add_child(_fee_block())
	_root_box.add_child(_search_footer())


func _role_card(role_id: String) -> Control:
	var card := PanelContainer.new()
	card.theme_type_variation = &"CardPanelTight"
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 3)
	var head := HBoxContainer.new()
	head.add_theme_constant_override("separation", 6)
	head.add_child(UiFactory.make_label(HRConstants.role_label(role_id), &"NameSerif"))
	col.add_child(head)
	# Faz okunabilirliği aday dosyasından ÖNCE, seçim anında: oyuncu neyi hızlandıran
	# birini aradığını bilerek seçsin (Coupling'in UI yükümlülüğü).
	col.add_child(HRUiShared.phase_hint_label(role_id))
	card.add_child(col)
	HRUiShared.set_mouse_ignore(col)
	# KİLİTLİ AMA GİZLİ DEĞİL — bant kartlarının (_band_card) grameriyle birebir aynı:
	# 0.55 alfa, kilit ikonu, gui_input HİÇ bağlanmaz, işaretçi el olmaz. Fark, burada
	# kilidin bir GEREKÇESİ olması: rol neden kapalı, oyuncunun kendi diliyle yazıyor.
	# "Yakında" değil "şu koşulda açılır" — bu bir eksik değil, bir kapı.
	var lock_key: String = HRConstants.role_lock_reason_key(role_id)
	if lock_key != "":
		head.add_child(HRUiShared.lock_glyph())
		col.add_child(UiFactory.make_label(tr(lock_key), &"RowMeta", UiTokens.INK_DIM))
		card.modulate = Color(1, 1, 1, 0.55)
		return card
	card.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	if role_id == _selected_role:
		_apply_selected_style(card)
	card.gui_input.connect(func(ev: InputEvent) -> void:
		if _is_left_click(ev):
			_selected_role = role_id
			_rebuild())
	return card


func _band_card(band_id: String) -> Control:
	var card := PanelContainer.new()
	card.theme_type_variation = &"CardPanelTight"
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 3)
	col.add_child(UiFactory.make_label(
		UiTokens.tr_upper(HRConstants.band_label(band_id)), &"RowName"))
	if _selected_role != "":
		# Maaş aralığı role BAĞLI, o yüzden rol seçilmeden rakam yazılmaz (yanlış
		# rakam yazmaktan iyidir).
		var window: Array = HRConstants.salary_band(_selected_role, band_id)
		if window.size() == 2:
			col.add_child(UiFactory.make_label(
				"%s – %s/ay" % [HRUiShared.money(int(window[0])), HRUiShared.money(int(window[1]))],
				&"RowMeta", UiTokens.INK_MUTED))
	card.add_child(col)
	HRUiShared.set_mouse_ignore(col)
	if _selected_role == "":
		# Rol seçilmeden bant kartları GÖRSEL disabled — açıklama cümlesi yerine temanın
		# disabled grameri (locked_telegraph'ın 0.55 alfası). gui_input bağlanmaz; her rol
		# tıkı modalı tam yeniden kurduğu için geçişin ek state'i yok.
		card.modulate = Color(1, 1, 1, 0.55)
		return card
	card.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	if band_id == _selected_band:
		_apply_selected_style(card)
	card.gui_input.connect(func(ev: InputEvent) -> void:
		if _is_left_click(ev):
			_selected_band = band_id
			_rebuild())
	return card


func _fee_block() -> Control:
	# Ücret cümlesi: peşin + komisyon + varış penceresi. Üç sayı da preview_search'ten;
	# rol/bant seçilmemişse motor yine geçerli bir sözlük döndürüyor (valid=false), o
	# yüzden sabitler registry'den okunuyor.
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 3)
	col.add_child(UiFactory.make_label(
		tr("HR_ATLAS_TERMS").format({
			"retainer": HRUiShared.money(HRConstants.SEARCH_RETAINER),
			"pct": int(round(HRConstants.SEARCH_COMMISSION_PCT * 100.0)),
			"min": HRConstants.SEARCH_ARRIVAL_MIN_DAYS,
			"max": HRConstants.SEARCH_ARRIVAL_MAX_DAYS,
		], &"BodySerif"))
	if _selected_role != "" and _selected_band != "":
		var pv: Dictionary = HRSearchSystem.preview_search(_selected_role, _selected_band)
		col.add_child(UiFactory.make_label(
			"Komisyon bu bantta %s – %s" % [
				HRUiShared.money(int(pv.get("commission_low", 0))),
				HRUiShared.money(int(pv.get("commission_high", 0))),
			], &"RowMeta", UiTokens.INK_MUTED))
		for warning in pv.get("warnings", []):
			col.add_child(UiFactory.make_label(String(warning), &"RowMeta", UiTokens.negative()))
	return col


func _search_footer() -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	row.add_child(HRUiShared.action_button(tr("HR_ATLAS_CANCEL"), _close))
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(spacer)
	var cta_label: String = tr("HR_ATLAS_START").format({"amount": HRUiShared.money(HRConstants.SEARCH_RETAINER)})
	if _selected_role == "" or _selected_band == "":
		row.add_child(HRUiShared.disabled_button(cta_label, tr("HR_ATLAS_NEED_SELECTION")))
		return row
	var pv: Dictionary = HRSearchSystem.preview_search(_selected_role, _selected_band)
	if not bool(pv.get("can_start", false)):
		# Gerekçe motorun `warnings` dizisinden — bu iki önizlemede `reason` anahtarı yok
		# (HRActions'ta var). İki ayrı önizleme grameri, done mesajında raporlanıyor.
		var warnings: Array = pv.get("warnings", [])
		row.add_child(HRUiShared.disabled_button(cta_label,
			String(warnings[0]) if not warnings.is_empty() else ""))
		return row
	row.add_child(HRUiShared.action_button(cta_label, _on_start_pressed, true))
	return row


func _on_start_pressed() -> void:
	if HRSearchSystem.start_search(_selected_role, _selected_band):
		state_changed.emit()
		_close()


# --- ADIM 3: aday dosyaları (Kare 4) ----------------------------------------

func _build_files_step() -> void:
	var files: Array = HRSearchSystem.get_files()
	_root_box.add_child(UiFactory.make_section_header(
		tr("HR_ATLAS_FILES_COUNT").format({"n": files.size()})))
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	for i in files.size():
		row.add_child(_file_card(i, files[i]))
	_root_box.add_child(row)

	_root_box.add_child(HRUiShared.hairline())
	# "İade edilmez" cümlesi burada YOK (bilgi-tekrarı kuralı: her bilgi bir kez, önem
	# anında) — kayıp uyarısı _on_dismiss_pressed'in onay diyaloğunda, kararın tam anında.
	var dismiss := HRUiShared.action_button(tr("HR_ATLAS_TAKE_NONE"), _on_dismiss_pressed)
	dismiss.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_root_box.add_child(dismiss)


func _file_card(index: int, file: Dictionary) -> Control:
	var pv: Dictionary = HRSearchSystem.preview_hire(index)
	var card := PanelContainer.new()
	card.theme_type_variation = &"CardPanel"
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 6)
	card.add_child(col)

	var tag := HBoxContainer.new()
	tag.add_theme_constant_override("separation", 6)
	var spacer0 := Control.new()
	spacer0.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tag.add_child(spacer0)
	tag.add_child(UiFactory.make_badge("DOSYA %d/%d" % [index + 1, HRConstants.CANDIDATE_COUNT],
		&"neutral"))
	col.add_child(tag)

	var head := HBoxContainer.new()
	head.add_theme_constant_override("separation", 8)
	head.add_child(UiFactory.make_avatar(
		UiFactory.initials_of(String(file.get("name", ""))), 28))
	var id_col := VBoxContainer.new()
	id_col.add_theme_constant_override("separation", 2)
	id_col.add_child(UiFactory.make_label(String(file.get("name", "")), &"NameSerif"))
	id_col.add_child(UiFactory.make_label(
		UiTokens.tr_upper(HRConstants.role_label(String(file.get("role", "")))),
		&"RowMeta", UiTokens.INK_DIM))
	head.add_child(id_col)
	col.add_child(head)

	col.add_child(HRUiShared.phase_hint_label(String(file.get("role", ""))))
	col.add_child(UiFactory.make_label("\"%s\"" % String(file.get("note", "")), &"QuoteSerif"))
	col.add_child(HRUiShared.axis_chips(file.get("axes", {})))
	col.add_child(UiFactory.make_label(
		tr("HR_ATLAS_SALARY_ASK").format({"amount": HRUiShared.money(int(file.get("salary", 0)))}), &"RowMeta"))
	if not Array(file.get("traits", [])).is_empty():
		col.add_child(HRUiShared.trait_row(file.get("traits", []), true))

	col.add_child(HRUiShared.hairline())
	var cta_label: String = tr("HR_ATLAS_HIRE").format({"amount": HRUiShared.money(int(file.get("salary", 0)))})
	if bool(pv.get("affordable", false)):
		var on_hire: Callable = func() -> void: _on_hire_pressed(index)
		var btn := HRUiShared.action_button(cta_label, on_hire, true)
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		col.add_child(btn)
	else:
		var warnings: Array = pv.get("warnings", [])
		var btn2 := HRUiShared.disabled_button(cta_label,
			String(warnings[0]) if not warnings.is_empty() else "")
		btn2.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		col.add_child(btn2)
	col.add_child(UiFactory.make_label(
		"+ %s komisyon" % HRUiShared.money(int(pv.get("commission", 0))),
		&"RowMeta", UiTokens.INK_MUTED))
	# Runway satırı — brief'in istediği yer burası, band adımı değil. INF-güvenli:
	# preview_hire'ın iki alanı da INF olabilir, karar UiTokens.net_runway_parts'ta.
	col.add_child(UiFactory.make_label(
		"Runway %s → %s" % [
			UiTokens.net_runway_text(float(pv.get("runway_before", 0.0))),
			UiTokens.net_runway_text(float(pv.get("runway_after", 0.0))),
		], &"RowMeta", UiTokens.INK_MUTED))
	return card


func _on_hire_pressed(index: int) -> void:
	if HRSearchSystem.hire(index) != null:
		state_changed.emit()
		_close()


func _on_dismiss_pressed() -> void:
	# Sessiz kapanış değil: peşin ödenen retainer geri gelmiyor, kayıp anında onay şart.
	# hr_tab._on_cancel_search ile aynı sözleşme (bağlı METOT referansı, lambda değil);
	# ConfirmModal ModalLayer'a (layer 10) gider, bu modal PanelLayer'da (layer 9) durur —
	# yani onay her zaman üstte çizilir, artık ekleme sırasına bağlı olmadan.
	EventBus.confirm_requested.emit({
		"title": tr("HR_ATLAS_TAKE_NONE"),
		"body": tr("HR_ATLAS_CLOSE_BODY").format({"amount": HRUiShared.money(HRConstants.SEARCH_RETAINER)}),
		"confirm_text": tr("HR_ATLAS_CLOSE_OK"),
		"cancel_text": tr("UI_DISMISS"),
		"on_confirm": _do_dismiss,
	})


func _do_dismiss() -> void:
	if HRSearchSystem.dismiss_files():
		state_changed.emit()
		_close()


# --- Kroki yardımcıları -----------------------------------------------------

func _apply_selected_style(card: PanelContainer) -> void:
	# Seçili kart: amber çerçeve + amber zemin (creation_flow._apply_row_style reçetesi —
	# tema stylebox'ının kopyası üzerine yazılır, tema dosyası değişmez).
	var sb: StyleBox = card.get_theme_stylebox("panel")
	if sb is StyleBoxFlat:
		var sel: StyleBoxFlat = (sb as StyleBoxFlat).duplicate()
		sel.bg_color = UiTokens.AMBER_BG
		sel.border_color = UiTokens.ACCENT
		sel.set_border_width_all(2)
		card.add_theme_stylebox_override("panel", sel)


func _is_left_click(ev: InputEvent) -> bool:
	return ev is InputEventMouseButton and (ev as InputEventMouseButton).pressed \
		and (ev as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_close()


func _close() -> void:
	queue_free()
