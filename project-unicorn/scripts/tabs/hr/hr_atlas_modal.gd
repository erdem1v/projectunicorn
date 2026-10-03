extends "res://scripts/tabs/hr/hr_panel.gd"

# ============================================================================
# Atlas Seçme & Yerleştirme paneli — §10.1 (rol + seviye) ve §10.3 (aday dosyaları).
# Tek kabuk, iki hal; hangisinin açılacağını arayışın motor durumu söyler
# (HRSearchSystem.get_state). Seçim kartı ürünün tür seçicisiyle aynı: seçili kart yükselir, sol
# kenarında işaret ve köşesinde onay diski taşır; tek amber eylem altbarda.
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

## İki adımın genişliği tasarımdan; dosya adımı üç kartı yan yana taşıyor ve pencereyi boydan örter.
const W_SEARCH := 1440
const W_FILES := 1560
const CARD_INSET := Vector4i(UiTokens.SPACE_XXL, UiTokens.SPACE_XL, UiTokens.SPACE_XXL, UiTokens.SPACE_XL)
const FILE_INSET := Vector4i(UiTokens.SPACE_XXL, UiTokens.SPACE_XL, UiTokens.SPACE_XXL, UiTokens.SPACE_XXL)

var _selected_role: String = ""
## -1 = seçilmedi. Seviye bir INT (§3: 0/1/2).
var _selected_level: int = -1
var _selected_file: int = 0


func populate() -> void:
	var agency: String = HRConstants.search_agency_name()
	title.add_child(HRUiShared.D_mono(agency.left(1), UiTokens.D_H_BTN))
	title.add_child(UiFactory.make_label(agency, &"TitleH2"))
	_rebuild()


func _rebuild() -> void:
	clear()
	if HRSearchSystem.get_state() == HRConstants.SEARCH_FILES_READY:
		_build_files_step()
		seat(W_FILES, true)
	else:
		_build_search_step()
		seat(W_SEARCH)


# --- ADIM 1 · ROL + ADIM 2 · SEVİYE (11a) -----------------------------------

func _build_search_step() -> void:
	body.add_child(_step(tr("HR_ATLAS_STEP_ROLE")))
	var grid := GridContainer.new()
	grid.columns = 3
	# Üç eşit sütun: GridContainer boşluğu genişleyen sütunlara eşit dağıtır — şartı her
	# kartın EXPAND_FILL taşıması.
	grid.add_theme_constant_override("h_separation", UiTokens.SPACE_L)
	grid.add_theme_constant_override("v_separation", UiTokens.SPACE_L)
	for role in HRConstants.EMPLOYEE_ROLES:
		var role_id: String = String(role)
		var lock_key: String = HRConstants.role_lock_reason_key(role_id)
		grid.add_child(_role_card(HRConstants.role_label(role_id), HRConstants.role_phase_hint(role_id),
			tr(lock_key) if lock_key != "" else "", _selected_role == role_id,
			func() -> void: _selected_role = role_id))
	# §10.6: gelecek rollerin kartları kilitli-görünür durur — çizilir, sönüktür, tıklanamaz,
	# gerekçesini gösterir. EMPLOYEE_ROLES'a girmezler.
	for role in HRConstants.FUTURE_ROLES:
		grid.add_child(_role_card(HRConstants.future_role_label(String(role)),
			HRConstants.future_role_hint(String(role)), tr(HRConstants.FUTURE_ROLE_LOCK_KEY), false, Callable()))
	body.add_child(spaced(grid, UiTokens.SPACE_L))

	body.add_child(spaced(_step(tr("HR_ATLAS_STEP_LEVEL")), UiTokens.SPACE_3XL))
	var levels := HBoxContainer.new()
	levels.add_theme_constant_override("separation", UiTokens.SPACE_L)
	for level in HRConstants.LEVELS:
		var lv: int = int(level)
		var card: Array = _card(&"PickCard", _selected_level == lv, func() -> void: _selected_level = lv,
			Vector4i(UiTokens.SPACE_XXL, 0, UiTokens.SPACE_XXL, 0))
		card[0].custom_minimum_size.y = UiTokens.D_H_BTN_LG
		card[1].alignment = BoxContainer.ALIGNMENT_CENTER
		# Etiket seviye ADIDIR (Junior · Orta · Kıdemli), büyük harfe çevrilmez.
		card[1].add_child(UiFactory.make_label(HRConstants.level_label(lv), &"FloatTitle"))
		if _selected_level == lv:
			_corner_disc(card[2], true)
		levels.add_child(card[0])
	body.add_child(spaced(levels, UiTokens.SPACE_L))

	# §10'un iki cümlesi: "bir hafta sonra aday listesi gelir" ve "ücretsizdir; tek ücret
	# komisyondur".
	var meta := HBoxContainer.new()
	meta.add_theme_constant_override("separation", UiTokens.SPACE_M)
	meta.add_child(UiFactory.make_glyph("res://assets/icons/util/calendar.svg", UiTokens.D_ICON_ROW, UiTokens.D_INK_4))
	meta.add_child(UiFactory.make_label(tr("HR_ATLAS_ARRIVAL").format({"span": tr("HR_ATLAS_ARRIVAL_SPAN")}), &"MetaMuted"))
	meta.add_child(UiFactory.make_label("·", &"CaptionFaint"))
	meta.add_child(UiFactory.make_label(tr("HR_ATLAS_FREE_NOTE"), &"MetaMuted"))
	body.add_child(spaced(meta, UiTokens.SPACE_XL))

	foot.add_child(button(tr("UI_DISMISS"), &"SecondaryButton", close))
	foot.add_child(spring())
	var cta: String = tr("HR_ATLAS_START")
	if _selected_role == "" or _selected_level < 0:
		foot.add_child(UiFactory.make_label(tr("HR_ATLAS_NEED_SELECTION"), &"MetaMuted"))
		foot.add_child(button(cta, &"PrimaryButtonDark", Callable()))
		return
	var pv: Dictionary = HRSearchSystem.preview_search(_selected_role, _selected_level)
	# Seçim özeti türetilmiş unvandır (§3): "Kıdemli Yazılım Mühendisi"; kapalıysa gerekçesi.
	var can: bool = bool(pv.get("can_start", false))
	foot.add_child(UiFactory.make_label(String(pv.get("job_title", "")) if can else _first_warning(pv), &"MetaMuted"))
	foot.add_child(button(cta, &"PrimaryButtonDark", _on_start_pressed if can else Callable()))


## A step's caps key with its rule running right.
func _step(text: String) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", UiTokens.SPACE_L)
	row.add_child(UiFactory.make_label(Fmt.upper(text), &"FloatKey"))
	var rule := HSeparator.new()
	rule.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(rule)
	return row


## A card to pick from: `[card, content, marks]`. Picked, it rises and carries the marker on its left edge
## and the check disc in its corner; a card with no `on_pick` takes no click.
func _card(look: StringName, picked: bool, on_pick: Callable, inset: Vector4i) -> Array:
	var card := PanelContainer.new()
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.theme_type_variation = StringName(look + ("Selected" if picked else ""))
	var marks := Control.new()
	marks.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(marks)
	var pad := MarginContainer.new()
	pad.add_theme_constant_override("margin_left", inset.x)
	pad.add_theme_constant_override("margin_top", inset.y)
	pad.add_theme_constant_override("margin_right", inset.z)
	pad.add_theme_constant_override("margin_bottom", inset.w)
	card.add_child(pad)
	if picked:
		marks.add_child(HRUiShared.D_mark())
	if on_pick.is_valid():
		card.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		if not picked:
			card.mouse_entered.connect(func() -> void: card.theme_type_variation = StringName(look + "Hover"))
			card.mouse_exited.connect(func() -> void: card.theme_type_variation = look)
		card.gui_input.connect(func(ev: InputEvent) -> void:
			if UiFactory.is_left_click(ev):
				on_pick.call()
				_rebuild())
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", UiTokens.SPACE_S)
	pad.add_child(content)
	return [card, content, marks]


## The check disc of a picked card, in the corner of `marks` or inline.
func _disc() -> PanelContainer:
	var disc := PanelContainer.new()
	disc.theme_type_variation = &"CheckDisc"
	disc.custom_minimum_size = Vector2.ONE * UiTokens.D_CHECK_DISC
	disc.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var centre := CenterContainer.new()
	centre.add_child(UiFactory.make_glyph("res://assets/icons/util/check.svg", UiTokens.D_ICON_PART, UiTokens.D_SURFACE_0))
	disc.add_child(centre)
	return disc


## The check disc at a picked card's right: in its top corner, or `centred` on a one-line card.
func _corner_disc(marks: Control, centred: bool) -> void:
	var disc := _disc()
	var inset: float = UiTokens.SPACE_XXL if centred else UiTokens.SPACE_L
	disc.anchor_left = 1.0
	disc.anchor_right = 1.0
	disc.anchor_top = 0.5 if centred else 0.0
	disc.anchor_bottom = disc.anchor_top
	disc.offset_left = -inset - UiTokens.D_CHECK_DISC
	disc.offset_right = -inset
	disc.offset_top = -UiTokens.D_CHECK_DISC / 2.0 if centred else inset
	disc.offset_bottom = disc.offset_top + UiTokens.D_CHECK_DISC
	marks.add_child(disc)


## Rol kartı. KİLİTLİ (`lock_text` dolu): ad ve glif soluk, kilit glifi; gerekçe tam mürekkeple altında —
## ve tıklama hiç bağlanmıyor (kilitli kart "reddedilen" değil, "kapalı").
func _role_card(label: String, hint_text: String, lock_text: String, picked: bool, on_pick: Callable) -> PanelContainer:
	var locked: bool = lock_text != ""
	var card: Array = _card(&"PickCard", picked, Callable() if locked else on_pick, CARD_INSET)
	var col: VBoxContainer = card[1]
	var head := HBoxContainer.new()
	head.add_theme_constant_override("separation", UiTokens.SPACE_M)
	head.add_child(UiFactory.make_label(label, &"NameTitle", UiTokens.D_INK_OFF if locked else null))
	if locked:
		var lock := UiFactory.make_glyph("res://assets/icons/util/lock.svg", UiTokens.D_ICON_PART, UiTokens.D_INK_OFF)
		lock.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		head.add_child(lock)
	col.add_child(head)
	var hint := UiFactory.make_label(hint_text, &"MetaMuted")
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	col.add_child(hint)
	if locked:
		var why := HBoxContainer.new()
		why.add_theme_constant_override("separation", UiTokens.SPACE_S)
		why.add_child(UiFactory.make_glyph("res://assets/icons/util/lock.svg", UiTokens.D_ICON_PART, UiTokens.D_INK_4))
		why.add_child(UiFactory.make_label(lock_text, &"MetaMuted", UiTokens.D_INK_2))
		col.add_child(why)
	if picked:
		_corner_disc(card[2], false)
	HRUiShared.set_mouse_ignore(col)
	return card[0]


func _first_warning(pv: Dictionary) -> String:
	var warnings: Array = pv.get("warnings", []) as Array
	return String(warnings[0]) if not warnings.is_empty() else ""


# --- ADAY DOSYALARI (11b) ---------------------------------------------------

func _build_files_step() -> void:
	var files: Array = HRSearchSystem.get_files()
	body.add_child(_step(tr("HR_ATLAS_FILES_COUNT").format({"n": files.size()})))
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", UiTokens.SPACE_XL)
	for i in files.size():
		row.add_child(_file_card(i, files[i]))
	body.add_child(spaced(row, UiTokens.SPACE_L))

	foot.add_child(button(tr("HR_ATLAS_TAKE_NONE"), &"SecondaryButton", _on_dismiss_pressed))
	foot.add_child(spring())
	var file: Dictionary = files[_selected_file]
	var pv: Dictionary = HRSearchSystem.preview_hire(_selected_file)
	var affordable: bool = bool(pv.get("affordable", false))
	foot.add_child(UiFactory.make_label("%s · %s" % [String(file.get("name", "")),
		String(pv.get("job_title", HRConstants.role_label(String(file.get("role", "")))))] if affordable
		else _first_warning(pv), &"MetaMuted"))
	foot.add_child(button(tr("HR_ATLAS_HIRE").format({"amount": Fmt.money_exact(int(file.get("salary", 0)))}),
		&"PrimaryButtonDark", _on_hire_pressed if affordable else Callable()))


## Aday dosyası (11b), köşesi kesik bir belge: künye ve seçim diski · yüz, ad, unvan · rol açıklaması ·
## iki alan ve Liderlik · huy · esneyen boşluk (dosyalar eşit boyda) · maaş talebi · komisyon · runway.
func _file_card(index: int, file: Dictionary) -> PanelContainer:
	var pv: Dictionary = HRSearchSystem.preview_hire(index)
	var role_id: String = String(file.get("role", ""))
	var axes: Dictionary = file.get("axes", {}) as Dictionary
	var picked: bool = index == _selected_file
	var card: Array = _card(&"FileDoc", picked, func() -> void: _selected_file = index, FILE_INSET)
	card[0].size_flags_vertical = Control.SIZE_EXPAND_FILL
	var col: VBoxContainer = card[1]
	col.add_theme_constant_override("separation", 0)

	var kicker := HBoxContainer.new()
	kicker.custom_minimum_size.y = UiTokens.D_CHECK_DISC
	var file_n := UiFactory.make_label(Fmt.upper(tr("HR_ATLAS_FILE_N").format({"i": index + 1, "n": HRConstants.CANDIDATE_COUNT})),
		&"KeySmall")
	file_n.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	kicker.add_child(file_n)
	if picked:
		kicker.add_child(_disc())
	col.add_child(kicker)

	var cand_name: String = String(file.get("name", ""))
	var who := HBoxContainer.new()
	who.add_theme_constant_override("separation", UiTokens.SPACE_L)
	who.add_child(UiFactory.make_person_avatar(cand_name, file.get("look", {}), UiTokens.D_AVATAR_CARD))
	var names := VBoxContainer.new()
	names.add_theme_constant_override("separation", 0)
	names.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	names.add_child(UiFactory.make_label(cand_name, &"NameTitle"))
	# §10.3: ad, UNVAN (§3 — seviye + rol adından türer), rol açıklaması.
	names.add_child(UiFactory.make_label(String(pv.get("job_title", HRConstants.role_label(role_id))), &"CondCaption"))
	who.add_child(names)
	col.add_child(spaced(who, UiTokens.SPACE_L))

	var hint := UiFactory.make_label(HRConstants.role_phase_hint(role_id), &"MetaMuted")
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	col.add_child(spaced(hint, UiTokens.SPACE_L))

	# İki alan ve Liderlik, aralarında ve üstte altta çizgi.
	var skills := HBoxContainer.new()
	skills.add_theme_constant_override("separation", 0)
	var keys: Array = HRUiShared.role_areas(role_id) + [HRConstants.SKILL_LEADERSHIP]
	for i in keys.size():
		if i > 0:
			skills.add_child(VSeparator.new())
		var cell := VBoxContainer.new()
		cell.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		cell.add_theme_constant_override("separation", UiTokens.SPACE_XXS)
		var key := UiFactory.make_label(HRConstants.area_label(keys[i]), &"CondCaption")
		key.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		cell.add_child(key)
		cell.add_child(HRUiShared.D_skill_figure(int(axes.get(keys[i], 0)), HRUiShared.D_rank(role_id, keys[i])))
		var inset := MarginContainer.new()
		inset.add_theme_constant_override("margin_top", UiTokens.SPACE_M)
		inset.add_theme_constant_override("margin_bottom", UiTokens.SPACE_M)
		inset.add_child(cell)
		inset.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		skills.add_child(inset)
	col.add_child(spaced(HSeparator.new(), UiTokens.SPACE_XL))
	col.add_child(skills)
	col.add_child(HSeparator.new())

	# Huy: adı ve etkisi.
	var traits: Array = file.get("traits", []) as Array
	if not traits.is_empty():
		var trait_id: String = String(traits[0])
		col.add_child(spaced(HRUiShared.D_trait_cell([trait_id], true), UiTokens.SPACE_L))
		var effect := UiFactory.make_label(HRConstants.trait_effect_text(trait_id), &"Caption")
		effect.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		col.add_child(spaced(effect, UiTokens.SPACE_XS))

	var stretch := Control.new()
	stretch.custom_minimum_size.y = UiTokens.SPACE_XL
	stretch.size_flags_vertical = Control.SIZE_EXPAND_FILL
	col.add_child(stretch)

	col.add_child(HSeparator.new())
	var ask := HBoxContainer.new()
	ask.add_theme_constant_override("separation", UiTokens.SPACE_M)
	var ask_key := UiFactory.make_label(Fmt.upper(tr("HR_ATLAS_SALARY_LABEL")), &"KeyLabel")
	ask_key.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	ask.add_child(ask_key)
	ask.add_child(UiFactory.make_label(Fmt.money_exact(int(file.get("salary", 0))), &"KpiValue", UiTokens.D_INK_1))
	ask.add_child(UiFactory.make_label(tr("HR_PER_MONTH"), &"Caption"))
	for part: Control in ask.get_children():
		part.size_flags_vertical = Control.SIZE_SHRINK_END
	col.add_child(spaced(ask, UiTokens.SPACE_L))
	# Komisyon bir bedeldir: bedel diskiyle, mürekkeple.
	var commission := Fmt.money_exact(int(pv.get("commission", 0)))
	col.add_child(_file_row("stake/cost", "HR_ATLAS_COMMISSION_LABEL", [[tr("HR_ATLAS_COMMISSION_ONCE"), &"Caption"],
		[commission, &"DataStrong"]]))
	# RUNWAY şeridi: "5 ay → 4 ay". Çift okuma tek seam'den (UiTokens.net_runway_pair): iki taraf aynı
	# okunuyorsa iki taraf da aynı yazılır. Kısalan runway bir bedeldir, tehlike değil.
	var pair: Dictionary = UiTokens.net_runway_pair(float(pv.get("runway_before", 0.0)), float(pv.get("runway_after", 0.0)))
	col.add_child(_file_row("world/runway", "HR_ATLAS_RUNWAY_LABEL", [[String(pair["before"]), &"Caption"],
		["→", &"CaptionFaint"], [String(pair["after"]), &"DataStrong"]]))
	HRUiShared.set_mouse_ignore(col)
	for hover: Control in col.find_children("*", "Control", true, false):
		if hover.tooltip_text != "":
			hover.mouse_filter = Control.MOUSE_FILTER_PASS
	return card[0]


## A file's fact row: glyph, caps key, then its parts at the right.
func _file_row(glyph: String, key: String, parts: Array) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.custom_minimum_size.y = UiTokens.D_H_FACT_ROW
	row.add_theme_constant_override("separation", UiTokens.SPACE_M)
	row.add_child(UiFactory.make_glyph("res://assets/icons/%s.svg" % glyph, UiTokens.D_ICON_PART, UiTokens.D_INK_3))
	var k := UiFactory.make_label(Fmt.upper(tr(key)), &"KeyLabel")
	k.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(k)
	for part: Array in parts:
		row.add_child(UiFactory.make_label(part[0], part[1]))
	for part: Control in row.get_children():
		part.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	return row


func _on_start_pressed() -> void:
	if HRSearchSystem.start_search(_selected_role, _selected_level):
		state_changed.emit()
		close()


func _on_hire_pressed() -> void:
	if HRSearchSystem.hire(_selected_file) != null:
		state_changed.emit()
		close()


func _on_dismiss_pressed() -> void:
	# Kayıp para değil ZAMAN (§10): onay yeniden beklenecek haftayı sayıyor. ConfirmModal
	# ModalLayer'a (layer 10) gider, bu panel PanelLayer'da (layer 9) — onay hep üstte.
	EventBus.confirm_requested.emit({
		"title": tr("HR_ATLAS_TAKE_NONE"),
		"body": tr("HR_ATLAS_CLOSE_BODY").format({"span": tr("HR_ATLAS_ARRIVAL_SPAN")}),
		"confirm_text": tr("HR_ATLAS_CLOSE_OK"),
		"cancel_text": tr("UI_DISMISS"),
		"on_confirm": _do_dismiss,
		"theme": true,
	})


func _do_dismiss() -> void:
	if HRSearchSystem.dismiss_files():
		state_changed.emit()
		close()
