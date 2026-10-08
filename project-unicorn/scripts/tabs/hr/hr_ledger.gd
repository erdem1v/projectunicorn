class_name HRLedger
extends RefCounted

# EKİP → KADRO: the roster table and the person's actions, which the row menu and the
# dossier share (one gate, one reason, one result line). Every figure comes from an engine call.

## The table's width inside the 1352 px window; both column sets add up to it.
const TABLE_W := 1302
## The columns: face, name, the six areas (each), Liderlik, Görev, Deneyim, Durum, Huy, Maaş, Moral.
const COLUMNS := [["face", 48], ["who", 170], ["skill", 44], ["lead", 80], ["task", 172], ["xp", 88],
	["state", 142], ["trait", 142], ["salary", 80], ["morale", 116]]
## Compact: the name alone, the role title in its own column, Deneyim left to the dossier.
const COLUMNS_COMPACT := [["face", 36], ["who", 136], ["skill", 38], ["lead", 80], ["role", 176], ["task", 170],
	["state", 142], ["trait", 138], ["salary", 80], ["morale", 116]]
## The roster turns compact from this many employees. [WORKING]
const COMPACT_FROM := 12
## Left insets inside a column, shared by the head and the rows.
const INSET := {"task": UiTokens.SPACE_L, "role": UiTokens.SPACE_L, "xp": UiTokens.SPACE_XS,
	"trait": UiTokens.SPACE_XS}

## Satırın aksiyonları. ACTION_MENU satır tıklamasıdır: kişi aksiyonlarını taşıyan popover'ı
## açar. ACTION_DOSSIER ad/avatar tıklamasıdır: Ekip dosyası penceresini açar.
const ACTION_MENU := "menu"
const ACTION_DOSSIER := "dossier"
const ACTION_RAISE := "raise"
const ACTION_FIRE := "fire"
const ACTION_TRAIN := "train"
const ACTION_PROMOTE := "promote"   # §13.3 dördüncü satır

const TRAINING_MODAL := "res://scenes/modals/TrainingModal.tscn"
## Açık HR görünümleri (Ekip sayfası, Ekip dosyası) bu gruptadır ve `rebuild_view()` uygular.
const VIEWS_GROUP := &"hr_views"


## The two-tier head: Roller spans the six area glyphs, Liderlik is ruled off as in the rows.
static func head(compact: bool) -> PanelContainer:
	var band := PanelContainer.new()
	band.theme_type_variation = &"TableHead"
	band.custom_minimum_size.y = UiTokens.D_H_HEAD_TWO
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 0)
	band.add_child(row)
	for col: Array in (COLUMNS_COMPACT if compact else COLUMNS):
		var w: int = col[1]
		match col[0]:
			"face":
				row.add_child(_gap(w))
			"skill":
				row.add_child(_span(w))
			"lead":
				row.add_child(_ruled(HRUiShared.D_head(tr_key("HR_AREA_LEADERSHIP"), 0), w))
			"salary":
				row.add_child(_pad(HRUiShared.D_head(tr_key("HR_COL_SALARY"), 0, HORIZONTAL_ALIGNMENT_RIGHT), w, 0,
					UiTokens.SPACE_L))
			_:
				var key: String = {"who": "HR_COL_EMPLOYEE", "role": "HR_COL_ROLE", "task": "HR_COL_TASK",
					"xp": "HR_COL_EXPERIENCE", "state": "HR_COL_STATE", "trait": "HR_COL_TRAIT",
					"morale": "HR_COL_MORALE"}[col[0]]
				row.add_child(_pad(HRUiShared.D_head(tr_key(key), 0, HORIZONTAL_ALIGNMENT_LEFT), w,
					INSET.get(col[0], 0), 0))
	return band


## Roller over the six area glyphs, its rule inset from both ends.
static func _span(w: int) -> VBoxContainer:
	var block := VBoxContainer.new()
	block.add_theme_constant_override("separation", UiTokens.SPACE_XXS)
	block.alignment = BoxContainer.ALIGNMENT_END
	block.add_child(HRUiShared.D_head(tr_key("HR_COL_ROLES"), w * HRConstants.AREAS.size()))
	var inset := MarginContainer.new()
	inset.add_theme_constant_override("margin_left", UiTokens.SPACE_S)
	inset.add_theme_constant_override("margin_right", UiTokens.SPACE_S)
	var rule := ColorRect.new()
	rule.color = UiTokens.D_LINE_2
	rule.custom_minimum_size.y = UiTokens.BORDER_HAIRLINE
	inset.add_child(rule)
	block.add_child(inset)
	var glyphs := HBoxContainer.new()
	glyphs.add_theme_constant_override("separation", 0)
	for area: String in HRConstants.AREAS:
		var cell := CenterContainer.new()
		cell.custom_minimum_size.x = w
		var glyph := UiFactory.make_glyph("res://assets/icons/skill/%s.svg" % area, UiTokens.D_ICON_CONTROL, UiTokens.D_INK_3)
		glyph.mouse_filter = Control.MOUSE_FILTER_PASS
		glyph.tooltip_text = HRConstants.area_label(area)
		cell.add_child(glyph)
		glyphs.add_child(cell)
	block.add_child(glyphs)
	return block


## One employee's row. `refs` takes the morale's paint references (hr_tab repaints in place).
static func row(emp: Character, compact: bool, selected: bool, on_action: Callable, refs: Dictionary) -> PanelContainer:
	var line := HRUiShared.D_row(selected)
	if compact:
		line.custom_minimum_size.y = UiTokens.D_H_ROW_SM
	line.tooltip_text = row_tip(emp)
	line.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	line.gui_input.connect(_on_row_input.bind(emp.id, ACTION_MENU, on_action, line))
	var away: bool = emp.status == HRConstants.STATUS_ON_LEAVE
	var cells := HBoxContainer.new()
	cells.add_theme_constant_override("separation", 0)
	line.add_child(cells)
	for col: Array in (COLUMNS_COMPACT if compact else COLUMNS):
		var w: int = col[1]
		match col[0]:
			"face":
				var face := HBoxContainer.new()
				face.custom_minimum_size.x = w
				face.add_child(_gap(UiTokens.SPACE_M if compact else UiTokens.SPACE_L))
				face.add_child(UiFactory.make_person_avatar(emp.character_name, emp.look,
					UiTokens.D_AVATAR_ROW_SM if compact else UiTokens.D_AVATAR_ROW, away))
				cells.add_child(face)
			"who":
				cells.add_child(_who(emp, w, compact, away, on_action))
			"skill":
				for area: String in HRConstants.AREAS:
					var rank: StringName = HRUiShared.D_rank(emp.role, area)
					cells.add_child(HRUiShared.D_skill_cell(int(emp.role_stats.get(area, 0)), rank, w, rank != &""))
			"lead":
				var lead := CenterContainer.new()
				lead.add_child(HRUiShared.D_skill_figure(int(emp.role_stats.get(HRConstants.SKILL_LEADERSHIP, 0)), &""))
				cells.add_child(_ruled(lead, w))
			"role":
				cells.add_child(_pad(_text(HRConstants.job_title(emp.role, emp.level), &"CondCaption"), w, INSET["role"], 0))
			"task":
				var task := _text(task_text(emp), &"CondData")
				if emp.training_weeks_left > 0:
					task.add_theme_color_override("font_color", UiTokens.D_INK_4)
				cells.add_child(_pad(task, w, INSET["task"], 0))
			"xp":
				cells.add_child(_pad(HRUiShared.D_xp(emp), w, INSET["xp"], 0))
			"state":
				cells.add_child(HRUiShared.D_state_cell(emp, false, w))
			"trait":
				cells.add_child(_pad(HRUiShared.D_trait_cell(emp.traits), w, INSET["trait"], 0))
			"salary":
				var pay := _text(Fmt.money_exact(emp.monthly_salary), &"DataText")
				pay.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
				cells.add_child(_pad(pay, w, 0, UiTokens.SPACE_L))
			"morale":
				var morale := HRUiShared.D_morale(emp.morale, refs)
				morale.custom_minimum_size.x = w
				cells.add_child(morale)
	HRUiShared.set_mouse_ignore(cells)
	# Tooltips over the skill glyphs, the trait and the who cell keep their hover.
	for hover: Control in cells.find_children("*", "Control", true, false):
		if hover.tooltip_text != "":
			hover.mouse_filter = Control.MOUSE_FILTER_PASS
	cells.get_child(1).mouse_filter = Control.MOUSE_FILTER_STOP
	return line


## The row's tooltip: the person's pace and what moves it, then what the role does.
static func row_tip(emp: Character) -> String:
	var pace := PackedStringArray([tr_key("HR_PACE").format({"pct": HRSystem.productivity_figure(emp)})])
	pace.append_array(HRSystem.productivity_lines(emp))
	return "\n".join(pace) + "\n\n" + HRConstants.role_phase_hint(emp.role)


## Name and role title; the dossier opens from here, the menu from the rest of the row.
static func _who(emp: Character, w: int, compact: bool, away: bool, on_action: Callable) -> Control:
	var who := VBoxContainer.new()
	who.alignment = BoxContainer.ALIGNMENT_CENTER
	who.add_theme_constant_override("separation", 0)
	var who_name := _text(emp.character_name, &"DataMedium" if away else &"DataStrong")
	if away:
		who_name.add_theme_color_override("font_color", UiTokens.D_INK_3)
	who.add_child(who_name)
	if not compact:
		who.add_child(_text(HRConstants.job_title(emp.role, emp.level), &"CondCaption"))
	var pad := _pad(who, w, UiTokens.SPACE_M, 0)
	pad.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	pad.gui_input.connect(_on_row_input.bind(emp.id, ACTION_DOSSIER, on_action, pad))
	return pad


static func _text(text: String, variation: StringName) -> Label:
	var label := UiFactory.make_label(text, variation)
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.clip_text = true
	label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	return label


## A cell `w` wide with its content inset.
static func _pad(child: Control, w: int, left: int, right: int) -> MarginContainer:
	var pad := MarginContainer.new()
	pad.custom_minimum_size.x = w
	pad.add_theme_constant_override("margin_left", left)
	pad.add_theme_constant_override("margin_right", right)
	pad.add_child(child)
	return pad


## Liderlik is not an area: a rule on its left, in the head and in every row.
static func _ruled(child: Control, w: int) -> HBoxContainer:
	var cell := HBoxContainer.new()
	cell.add_theme_constant_override("separation", 0)
	cell.custom_minimum_size.x = w
	var rule := ColorRect.new()
	rule.color = UiTokens.D_LINE_1
	rule.custom_minimum_size.x = UiTokens.BORDER_HAIRLINE
	cell.add_child(rule)
	child.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cell.add_child(child)
	return cell


static func _gap(w: int) -> Control:
	var gap := Control.new()
	gap.custom_minimum_size.x = w
	return gap


## §12.2 GÖREV metni: tek iş → cümle; iki iş → orta noktalı kısa etiketler (cümle satırı
## taşırır); hiç iş → veri yok işareti. Ekip dosyası da buradan okur.
static func task_text(emp: Character) -> String:
	var jobs: Array[String] = emp.assigned_job_ids
	if jobs.size() >= 2:
		var labels: Array[String] = []
		for job_id in jobs:
			labels.append(_job_text(job_id, true))
		return " · ".join(labels)
	if jobs.size() == 1:
		return _job_text(jobs[0], false)
	return tr_key("HR_TASK_NONE")


## §12.2 iş metni. Sprint koşarken Build çıkacak sürümün adıyla okunur ("Notly v1.5"):
## oyuncunun kafasındaki şey o sürümdür. `short` iki iş hâlinin kısa etiketidir.
static func _job_text(job_id: String, short: bool) -> String:
	if job_id == HRConstants.JOB_BUILD:
		if SprintSystem.mode() == "active":
			var product: String = SalesSystem.product_display_name()
			var label: String = SprintSystem.version_label(ProductState.version() + 1)
			if short:
				return "%s %s" % [product, label]
			return tr_key("HR_TASK_ON_PRODUCT").format({"product": product, "version": label})
	if short:
		return HRConstants.job_label(job_id)
	var key: String = "HR_TASK_ON_JOB_%s" % job_id.to_upper()
	var sentence: String = tr_key(key)
	# Cümlesi olmayan iş (Araştırma) adıyla okunur; ham anahtar ekrana düşmez.
	return HRConstants.job_label(job_id) if sentence == key else sentence


## Satır tıklaması = kişi aksiyonları menüsü, ad/avatar tıklaması = Ekip dosyası. Sözleşme
## `(emp_id, action, anchor)`: popover kendini çapaya göre konumlandırır.
static func _on_row_input(ev: InputEvent, emp_id: String, action: String, on_action: Callable,
		anchor: Control) -> void:
	if UiFactory.is_left_click(ev):
		anchor.accept_event()
		on_action.call(emp_id, action, anchor)


# --- kişi aksiyonları -------------------------------------------------------

## The person's actions as menu rows (the row menu and the dossier): the file (menu only), raise,
## promotion, training, and dismissal ruled off below. Each row says its result on the right; a closed
## one keeps its label, greys it and gives its reason under it.
static func action_list(emp: Character, on_action: Callable, with_file: bool) -> VBoxContainer:
	var list := VBoxContainer.new()
	list.add_theme_constant_override("separation", 0)
	for spec: Dictionary in _action_specs(emp, with_file):
		var act: String = spec["action"]
		if act == ACTION_FIRE:
			list.add_child(HSeparator.new())
		list.add_child(_action_row(spec, on_action.bind(act)))
	return list


## Kapalı satırın gerekçesi preview_*'ın `reason` anahtarından okunur: can_* yalnız bool döner.
## `meta` her satırın SONUCUNU söyler (maaş · unvan · süre · kalıcı).
static func _action_specs(emp: Character, with_file: bool) -> Array:
	var specs: Array = []
	if with_file:
		specs.append({"key": "HR_MENU_OPEN_DOSSIER", "glyph": "util/doc", "preview": {"ok": true},
			"action": ACTION_DOSSIER, "meta": ""})
	var next_title: String = HRConstants.job_title(emp.role, emp.level + 1) if HRActions.can_promote(emp) else ""
	specs.append_array([
		{"key": "HR_CARD_RAISE", "glyph": "world/raise", "preview": HRActions.preview_raise(emp, HRConstants.RAISE_MIN_PCT),
			"action": ACTION_RAISE, "meta": "%s %s" % [tr_key("HR_ROW_SALARY"), Fmt.money_exact(emp.monthly_salary)]},
		# §13.3: kilitli hâli görünür kalır ve gerekçesini gösterir.
		{"key": "HR_CARD_PROMOTE", "glyph": "util/chevron_up",
			"preview": {"ok": HRActions.can_promote(emp), "reason": HRActions.promotion_block_reason(emp)},
			"action": ACTION_PROMOTE, "meta": "→ %s" % next_title if next_title != "" else ""},
		# §5.4 iki gerekçe: bar dolmadı ya da alan tavanda — metni registry seçer.
		{"key": "HR_TRAINING_PICK_TITLE", "glyph": "world/training",
			"preview": {"ok": CharacterRegistry.can_train(emp.id),
				"reason": CharacterRegistry.training_block_reason(emp.id)},
			"action": ACTION_TRAIN, "meta": HRConstants.training_duration_text()},
		{"key": "HR_CARD_FIRE", "glyph": "world/person_left", "preview": HRActions.preview_fire(emp),
			"action": ACTION_FIRE, "meta": tr_key("HR_MENU_PERMANENT")},
	])
	return specs


## A menu row: its glyph, its label and its result on the right; a closed row shows a lock and its
## reason under the label, at the row's full width.
static func _action_row(spec: Dictionary, on_press: Callable) -> Button:
	var preview: Dictionary = spec["preview"]
	var ok: bool = bool(preview.get("ok", false))
	var reason: String = String(preview.get("reason", ""))
	var danger: bool = spec["action"] == ACTION_FIRE
	var btn := Button.new()
	btn.theme_type_variation = &"MenuItem"
	btn.focus_mode = Control.FOCUS_NONE
	btn.disabled = not ok
	btn.custom_minimum_size.y = UiTokens.D_H_MENU_ITEM if ok or reason == "" else UiTokens.D_H_ROW_LG
	if ok:
		btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		btn.pressed.connect(on_press)
	var ink: Variant = UiTokens.D_INK_OFF if not ok else (UiTokens.D_neg_ink() if danger else null)
	var col := VBoxContainer.new()
	col.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	col.offset_left = UiTokens.SPACE_M
	col.offset_right = -UiTokens.SPACE_M
	col.alignment = BoxContainer.ALIGNMENT_CENTER
	col.add_theme_constant_override("separation", 0)
	var line := HBoxContainer.new()
	line.add_theme_constant_override("separation", UiTokens.SPACE_M)
	line.add_child(UiFactory.make_glyph("res://assets/icons/%s.svg" % ("util/lock" if not ok else spec["glyph"]),
		UiTokens.D_ICON_ROW, ink if ink != null else UiTokens.D_INK_3))
	var label := UiFactory.make_label(tr_key(spec["key"]), &"DataText", ink)
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	line.add_child(label)
	if spec["meta"] != "":
		line.add_child(UiFactory.make_label(spec["meta"], &"Caption"))
	for part: Control in line.get_children():
		part.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	col.add_child(line)
	if not ok and reason != "":
		var why := MarginContainer.new()
		why.add_theme_constant_override("margin_left", UiTokens.D_ICON_ROW + UiTokens.SPACE_M)
		why.add_child(UiFactory.make_label(reason, &"Caption"))
		col.add_child(why)
	HRUiShared.set_mouse_ignore(col)
	btn.add_child(col)
	return btn


## Kişi aksiyonlarının tek kapısı (§14 aksiyon kabuğu). `host`, eğitim modalının monte
## edileceği ağaçtaki bir düğüm.
static func run_action(host: Node, emp: Character, action: String) -> void:
	match action:
		ACTION_DOSSIER:
			host.get_tree().call_group(&"window_layer", &"open_detail", "hr_dossier", {"character_id": emp.id})
		ACTION_RAISE:
			_open_raise(emp)
		ACTION_PROMOTE:
			_open_promotion(emp)
		ACTION_TRAIN:
			# Alan seçimini oyuncu yapıyor (§5.2), o yüzden onay kutusu değil eğitim modalı.
			HRUiShared.mount_panel_modal(host, TRAINING_MODAL, _refresh_views, [emp.id])
		ACTION_FIRE:
			_confirm_fire(emp)


static func _open_raise(emp: Character) -> void:
	if not bool(HRActions.preview_raise(emp, HRConstants.RAISE_MIN_PCT).get("ok", false)):
		return
	EventBus.confirm_requested.emit({
		"modal": "hr_action",
		"title": tr_key("HR_CARD_RAISE"),
		"person": emp,
		"commit_key": "HR_APPLY_RAISE_PCT",
		"slider": {"min": HRConstants.RAISE_MIN_PCT, "max": HRConstants.RAISE_MAX_PCT,
			"start": HRConstants.RAISE_MIN_PCT},
		"preview": func(pct: int) -> Dictionary: return HRActions.preview_raise(emp, pct),
		"on_commit": _commit.bind(emp.id, HRActions.apply_raise),
	})


## §9.3: zam ile aynı kabuk; fark bir SEVİYE atlaması olması — unvan da bir delta satırı.
## Minimum %10, yani slider "terfi ettim ama zam almadım"a inmez.
static func _open_promotion(emp: Character) -> void:
	if not HRActions.can_promote(emp):
		return
	EventBus.confirm_requested.emit({
		"modal": "hr_action",
		"title": tr_key("HR_CARD_PROMOTE"),
		"person": emp,
		"commit_key": "HR_APPLY_PROMOTE_PCT",
		"slider": {"min": HRConstants.PROMOTION_MIN_PCT, "max": HRConstants.PROMOTION_MAX_PCT,
			"start": HRConstants.PROMOTION_MIN_PCT},
		"preview": func(pct: int) -> Dictionary: return HRActions.preview_promotion(emp, pct),
		"on_commit": _commit.bind(emp.id, HRActions.apply_promotion),
	})


static func _confirm_fire(emp: Character) -> void:
	var pv: Dictionary = HRActions.preview_fire(emp)
	if not bool(pv.get("ok", false)):
		return
	EventBus.confirm_requested.emit({
		"modal": "hr_action",
		"title": tr_key("HR_CARD_FIRE"),
		"person": emp,
		"rows": pv.get("rows", []),
		"commit_text": tr_key("HR_FIRE_CONFIRM_OK"),
		"danger": true,
		# Modal her eyleme tek imzayla döner; çıkarmanın slider'ı yok, gelen sıfır düşer.
		"on_commit": _commit.bind(emp.id, HRActions.fire.unbind(1)),
	})


## Onay modalının dönüşü. Kişi o arada ayrıldıysa ya da motor reddederse false: modal açık kalır.
static func _commit(pct: int, emp_id: String, apply: Callable) -> bool:
	var emp: Character = CharacterRegistry.get_character(emp_id)
	if emp == null or not apply.call(emp, pct):
		return false
	_refresh_views()
	return true


## Maaş ve seviye yazımı sinyal atmıyor: aksiyon bitince açık her HR görünümü yeniden kurulur.
static func _refresh_views() -> void:
	(Engine.get_main_loop() as SceneTree).call_group(VIEWS_GROUP, &"rebuild_view")


## Statik bağlamda çeviri: tr() bir Object ister, burada yok.
static func tr_key(key: String) -> String:
	return TranslationServer.translate(key)
