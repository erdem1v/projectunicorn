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

## 11a 1440px, 11b 1560px — iki adımın genişliği tasarımdan birebir. Dosya adımı daha
## geniş çünkü üç kart yan yana duruyor.
const PANEL_SEARCH := Vector2(1440, 0)
const PANEL_FILES := Vector2(1560, 0)

var _root_box: VBoxContainer = null
var _panel: PanelContainer = null
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
	_panel = center
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
		if _panel != null:
			_panel.custom_minimum_size = PANEL_FILES
		_build_files_step()
	else:
		if _panel != null:
			_panel.custom_minimum_size = PANEL_SEARCH
		_build_search_step()


## ATLAS RECRUITMENT — tek satır kimlik (11a/11b). SLOGAN YOK: tasarım Atlas'ın alıntısını
## kaldırdı, o yüzden HR_ATLAS_QUOTE bu ekrandan düştü.
func _add_masthead() -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 13)
	var disc: Panel = UiFactory.make_avatar("A", 32)
	row.add_child(disc)
	row.add_child(UiFactory.make_label(
		HRConstants.search_agency_name(), &"RowName"))
	_root_box.add_child(row)


# --- ADIM 1 · ROL + ADIM 2 · BÜTÇE BANDI (11a) ------------------------------

func _build_search_step() -> void:
	_root_box.add_child(_step_header(tr("HR_ATLAS_STEP_ROLE")))

	var grid := GridContainer.new()
	grid.columns = 3
	# ÜÇ EŞİT SÜTUN (11a): GridContainer artık boşluğu GENİŞLEYEN sütunlara eşit
	# dağıtıyor — şartı her hücrenin EXPAND_FILL taşıması (aşağıda, _role_card).
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", 12)
	grid.add_theme_constant_override("v_separation", 12)
	for role_id in HRConstants.EMPLOYEE_ROLES:
		grid.add_child(_role_card(String(role_id)))
	_root_box.add_child(grid)

	_root_box.add_child(_step_header(tr("HR_ATLAS_STEP_BAND")))
	var bands := HBoxContainer.new()
	bands.add_theme_constant_override("separation", 12)
	for band_id in HRConstants.BANDS:
		bands.add_child(_band_card(String(band_id)))
	_root_box.add_child(bands)

	# MALİYET SATIRINDA YALNIZ SÜRE (11a): ödenen tutar butonun üstünde yazıyor, iki yerde
	# göstermek aynı sayıyı iki kez sormak olurdu.
	var arrival := UiFactory.make_label(tr("HR_ATLAS_ARRIVAL").format(
		{"span": tr("HR_ATLAS_ARRIVAL_SPAN")}), &"RowMeta", UiTokens.INK_MUTED)
	_root_box.add_child(arrival)

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


## Rol kartı. SEÇİLİ: 1px amber kenar + 2px AMBER SOL KENAR + amber yıkama.
## KİLİTLİ: %60 opaklık, ad soluk, kilit glifi, gerekçe AMBER satırda — ve tıklama hiç
## bağlanmıyor (kilitli bir kart "denenip reddedilen" değil, "kapalı" olmalı).
func _role_card(role_id: String) -> Control:
	var lock_key: String = HRConstants.role_lock_reason_key(role_id)
	var locked: bool = lock_key != ""
	var selected: bool = _selected_role == role_id

	var card := PanelContainer.new()
	# Bant kartıyla AYNI kural: kart sütununu doldurur. Taşımadığında altı rol
	# metin uzunluğuna göre üç farklı genişlikte çıkıyor, panelin sağı boş kalıyordu.
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var sb := StyleBoxFlat.new()
	sb.set_corner_radius_all(UiTokens.RADIUS_S)
	sb.content_margin_left = 16.0
	sb.content_margin_right = 16.0
	sb.content_margin_top = 14.0
	sb.content_margin_bottom = 14.0
	if selected:
		sb.bg_color = UiTokens.AMBER_WASH
		sb.set_border_width_all(UiTokens.BORDER_HAIRLINE)
		sb.border_width_left = UiTokens.BORDER_FOCUS
		sb.border_color = UiTokens.ACCENT
	else:
		sb.bg_color = UiTokens.SURFACE_FRAME
		sb.set_border_width_all(UiTokens.BORDER_HAIRLINE)
		sb.border_color = UiTokens.SEPARATOR
	card.add_theme_stylebox_override("panel", sb)

	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 7)
	card.add_child(col)

	var title_row := HBoxContainer.new()
	title_row.add_theme_constant_override("separation", 8)
	title_row.add_child(UiFactory.make_label(HRConstants.role_label(role_id), &"NameSerif",
		UiTokens.CREAM_DIM if locked else UiTokens.INK))
	if locked:
		title_row.add_child(HRUiShared.lock_glyph(12, UiTokens.CREAM_DIM))
	col.add_child(title_row)

	# Rol açıklaması: tasarımın kısa nötr yer tutucusu. Nihai metin sonra gelecek.
	var hint := UiFactory.make_label(
		HRConstants.role_phase_hint(role_id), &"RowMeta", UiTokens.CREAM_DIM)
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	col.add_child(hint)

	if locked:
		col.add_child(UiFactory.make_label(tr(lock_key), &"RowMeta", UiTokens.ACCENT))
		card.modulate.a = 0.6
		return card

	card.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	card.gui_input.connect(func(ev: InputEvent) -> void:
		if _is_left_click(ev):
			_selected_role = role_id
			_rebuild())
	return card


## Bant kartı. AÇIKLAMA SATIRI YOK — tasarım onları kaldırdı ("sonra eklenecek").
func _band_card(band_id: String) -> Control:
	var selected: bool = _selected_band == band_id
	var card := PanelContainer.new()
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var sb := StyleBoxFlat.new()
	sb.set_corner_radius_all(UiTokens.RADIUS_S)
	sb.content_margin_left = 16.0
	sb.content_margin_right = 16.0
	sb.content_margin_top = 13.0
	sb.content_margin_bottom = 13.0
	if selected:
		sb.bg_color = UiTokens.AMBER_WASH
		sb.set_border_width_all(UiTokens.BORDER_HAIRLINE)
		sb.border_width_left = UiTokens.BORDER_FOCUS
		sb.border_color = UiTokens.ACCENT
	else:
		sb.bg_color = UiTokens.SURFACE_FRAME
		sb.set_border_width_all(UiTokens.BORDER_HAIRLINE)
		sb.border_color = UiTokens.SEPARATOR
	card.add_theme_stylebox_override("panel", sb)
	card.add_child(UiFactory.make_label(
		UiTokens.tr_upper(HRConstants.band_label(band_id)), &"RowName",
		UiTokens.ACCENT if selected else UiTokens.INK_MUTED))
	card.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	card.gui_input.connect(func(ev: InputEvent) -> void:
		if _is_left_click(ev):
			_selected_band = band_id
			_rebuild())
	return card


## Alt bar: VAZGEÇ · boşluk · seçim özeti · ARAYIŞ BAŞLAT · $600.
func _search_footer() -> Control:
	_root_box.add_child(HRUiShared.hairline())
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 14)
	row.add_child(HRUiShared.action_button(tr("HR_ATLAS_CANCEL"), _close))
	var pad := Control.new()
	pad.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(pad)

	var cta: String = tr("HR_ATLAS_START").format(
		{"amount": HRUiShared.money(HRConstants.SEARCH_RETAINER)})
	if _selected_role == "" or _selected_band == "":
		row.add_child(HRUiShared.disabled_button(cta, tr("HR_ATLAS_NEED_SELECTION")))
		return row

	row.add_child(UiFactory.make_label("%s · %s" % [
		HRConstants.role_label(_selected_role), HRConstants.band_label(_selected_band)],
		&"RowMeta", UiTokens.INK_DIM))
	var pv: Dictionary = HRSearchSystem.preview_search(_selected_role, _selected_band)
	var warnings: Array = pv.get("warnings", []) as Array
	if not bool(pv.get("can_start", false)) or not bool(pv.get("affordable", false)):
		var reason: String = String(warnings[0]) if not warnings.is_empty() else ""
		row.add_child(HRUiShared.disabled_button(cta, reason))
	else:
		row.add_child(HRUiShared.action_button(cta, _on_start_pressed, true))
	return row


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


## Aday kartı (11b). Üstte DOSYA i/n şeridi; sonra baş harf + ad + rol; rol açıklaması;
## hairline'lar arasında YILDIZ ŞERİDİ (ana alan · ikincil alan · ayraç · Liderlik);
## TEK trait çipi; esneyen boşluk (kartlar eşit yükseklik); MAAŞ TALEBİ; İŞE AL;
## KOMİSYON; RUNWAY şeridi.
##
## ALINTI ÇİZİLMİYOR: tasarım boş alıntıyı kaldırdı. (Eski kod alıntıyı HAM DOSYA
## dict'inden okuyordu — `note` yalnız preview_hire'da var — yani ekrana boş bir tırnak
## çifti basıyordu. Kusur alıntıyla birlikte gitti.)
func _file_card(index: int, file: Dictionary) -> Control:
	var pv: Dictionary = HRSearchSystem.preview_hire(index)
	var role_id: String = String(file.get("role", ""))
	var axes: Dictionary = file.get("axes", {}) as Dictionary
	var salary: int = int(file.get("salary", 0))

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

	# DOSYA i/n
	var file_no := UiFactory.make_label(tr("HR_ATLAS_FILE_N").format(
		{"i": index + 1, "n": HRConstants.CANDIDATE_COUNT}), &"ColumnHeader", UiTokens.INK_DIM)
	col.add_child(file_no)
	col.add_child(HRUiShared.hairline())

	# baş harf + ad + rol
	var head := HBoxContainer.new()
	head.add_theme_constant_override("separation", 12)
	head.add_child(UiFactory.make_avatar(
		UiFactory.initials_of(String(file.get("name", ""))), 34))
	var who := VBoxContainer.new()
	who.add_theme_constant_override("separation", 3)
	who.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	who.add_child(UiFactory.make_label(String(file.get("name", "")), &"NameSerif"))
	who.add_child(UiFactory.make_label(
		UiTokens.tr_upper(HRConstants.role_label(role_id)), &"MicroLabel"))
	head.add_child(who)
	col.add_child(head)

	var hint := UiFactory.make_label(
		HRConstants.role_phase_hint(role_id), &"RowMeta", UiTokens.CREAM_DIM)
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	col.add_child(hint)

	# yıldız şeridi: iki alan · ayraç · Liderlik
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

	# TEK trait çipi — olumlu yeşil, olumsuz kırmızı.
	var traits: Array = file.get("traits", []) as Array
	if not traits.is_empty():
		col.add_child(HRUiShared.trait_row(traits, true))

	var stretch := Control.new()
	stretch.size_flags_vertical = Control.SIZE_EXPAND_FILL
	col.add_child(stretch)

	# MAAŞ TALEBİ
	var ask := HBoxContainer.new()
	var ask_cap := UiFactory.make_label(
		tr("HR_ATLAS_SALARY_LABEL"), &"RowMeta", UiTokens.INK_DIM)
	ask_cap.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	ask.add_child(ask_cap)
	ask.add_child(UiFactory.make_label(HRUiShared.money(salary), &"MetricValueInk"))
	ask.add_child(UiFactory.make_label(tr("HR_PER_MONTH"), &"RowMeta", UiTokens.INK_DIM))
	col.add_child(ask)

	# İŞE AL
	var cta: String = tr("HR_ATLAS_HIRE").format({"amount": HRUiShared.money(salary)})
	var warnings: Array = pv.get("warnings", []) as Array
	var hire_btn: Button
	if bool(pv.get("affordable", false)):
		hire_btn = HRUiShared.action_button(cta, _on_hire_pressed.bind(index), true)
	else:
		hire_btn = HRUiShared.disabled_button(cta,
			String(warnings[0]) if not warnings.is_empty() else "")
	hire_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col.add_child(hire_btn)

	# KOMİSYON
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


## RUNWAY şeridi: "6 ay → 1 ay", sonraki değer KIRMIZI. net_runway_parts kullanılıyor
## (net_runway_text değil) çünkü değer ve birim ayrı boyanabilmeli. Kırmızı kararı
## DELTADAN türetiliyor — parts["positive"] yalnız "Artıda" hâli için true, bir sağlık
## bayrağı değil.
func _runway_strip(pv: Dictionary) -> Control:
	var before: float = float(pv.get("runway_before", 0.0))
	var after: float = float(pv.get("runway_after", 0.0))
	var worse: bool = after < before

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
		UiTokens.net_runway_text(before), &"RowMeta", UiTokens.INK_MUTED))
	row.add_child(UiFactory.make_label("→", &"RowMeta", UiTokens.INK_DIM))
	row.add_child(UiFactory.make_label(UiTokens.net_runway_text(after), &"RowName",
		UiTokens.negative() if worse else UiTokens.INK_MUTED))
	strip.add_child(row)
	return strip


func _on_start_pressed() -> void:
	if HRSearchSystem.start_search(_selected_role, _selected_band):
		state_changed.emit()
		_close()


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
