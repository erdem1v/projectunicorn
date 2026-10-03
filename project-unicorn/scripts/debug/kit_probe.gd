extends RefCounted

# --probe-shot=kit: the dark kit's components in their states on a window body, laid out like the
# approved Ekip row sheet (SPEC §3.4 grid), beside the tags, parts, toasts, focus rings and the row
# menu's dark host. Debug only: names and figures are samples, the strings come from the CSV.

const TOAST := preload("res://scripts/ui/components/toast.gd")
const GROUP_GLYPH := "res://assets/icons/rail/hr.svg"
## SPEC §3.4, the 1352 px Ekip window: face, name, six skills, leadership, task, experience, state,
## trait, salary, morale.
const W := [48, 170, 44, 80, 172, 88, 142, 142, 80, 116]
const ROWS := [
	{"name": "Burak Şahin", "role": "SALES_REP", "skills": [3, 3, 3, 3, 6, 3], "main": 4, "lead": 2,   # LOC-DATA debug sample
		"tags": [["HR_BADGE_NEW", &""]], "trait": "picks_it_up_fast", "salary": 8300, "morale": 55},
	{"name": "Deniz Arslan", "role": "DESIGNER", "skills": [5, 6, 3, 3, 3, 3], "main": 1, "second": 0,   # LOC-DATA debug sample
		"lead": 2, "tags": [], "trait": "last_one_out", "salary": 7400, "morale": 38, "hover": true},
	{"name": "Elif Demir", "role": "PRODUCT_MANAGER", "skills": [7, 6, 4, 4, 4, 4], "main": 0, "second": 1,   # LOC-DATA debug sample
		"lead": 6, "tags": [["HR_BADGE_NEW", &""]], "trait": "takes_them_under", "salary": 9800, "morale": 72,
		"selected": true},
	{"name": "Mert Yıldız", "role": "DEVELOPER", "skills": [4, 4, 8, 7, 4, 4], "main": 2, "second": 3,   # LOC-DATA debug sample
		"lead": 3, "tags": [["HR_FOUNDER_STATE_TRAINING", &"neutral"]], "weeks": 2, "trait": "loyal",
		"salary": 11200, "morale": 61, "away": true},
	{"name": "Selin Kaya", "role": "TESTER", "skills": [3, 3, 4, 5, 3, 3], "main": 3, "second": 2,   # LOC-DATA debug sample
		"lead": 1, "tags": [["HR_BADGE_FLIGHT_RISK", &"risk"]], "trait": "double_checker", "salary": 6900,
		"morale": 22},
	{"name": "Ece Aksoy", "role": "SALES_REP", "skills": [3, 3, 3, 3, 6, 3], "main": 4, "lead": 2,   # LOC-DATA debug sample
		"tags": [["HR_BADGE_OVERLOADED_JOBS", &"warn"], ["HR_BADGE_NEW", &""]], "trait": "", "salary": 8300,
		"morale": 50},
	{"name": "Kaan Demir", "role": "CUSTOMER_REP", "skills": [3, 3, 3, 3, 3, 5], "main": 5, "lead": 1,   # LOC-DATA debug sample
		"tags": [["HR_BADGE_IDLE", &"outline"]], "trait": "cant_say_no", "salary": 2250, "morale": 34, "idle": true},
]


static func page() -> Control:
	var root := Control.new()
	root.theme = load(UiTokens.MENAJER_THEME)
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	var ground := ColorRect.new()
	ground.color = UiTokens.D_SURFACE_0
	ground.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_child(ground)
	var cols := HBoxContainer.new()
	cols.position = Vector2(UiTokens.SPACE_3XL, UiTokens.SPACE_3XL)
	cols.add_theme_constant_override("separation", UiTokens.SPACE_3XL)
	root.add_child(cols)
	cols.add_child(_window())
	cols.add_child(_samples())
	# The shell's PanelLayer, where HRPopover mounts; a CanvasLayer, so the menu's theme is its own.
	var panels := CanvasLayer.new()
	panels.name = "PanelLayer"
	root.add_child(panels)
	return root


static func _tr(key: String) -> String:
	return TranslationServer.translate(key)


static func _window() -> PanelContainer:
	var win := PanelContainer.new()
	win.theme_type_variation = &"WindowPanel"
	win.custom_minimum_size.x = 1352
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 0)
	win.add_child(col)

	var head := PanelContainer.new()
	head.theme_type_variation = &"WinHead"
	head.custom_minimum_size.y = UiTokens.D_H_WIN_HEAD
	var head_row := HBoxContainer.new()
	head_row.add_theme_constant_override("separation", UiTokens.SPACE_4XL)
	head.add_child(head_row)
	head_row.add_child(UiFactory.make_label(Fmt.upper(_tr("TAB_HR")), &"TitleH1"))
	var kpis := HBoxContainer.new()
	kpis.add_theme_constant_override("separation", 0)
	kpis.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	kpis.add_child(UiFactory.D_kpi(_tr("HR_COL_EMPLOYEE"), "5"))
	kpis.add_child(UiFactory.D_kpi(_tr("HR_COL_MORALE"), ""))
	kpis.add_child(UiFactory.D_kpi(_tr("HR_COL_SALARY"), Fmt.money_exact(43600)))
	var gap := Control.new()
	gap.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	kpis.add_child(gap)
	kpis.add_child(HRUiShared.D_skill_legend())
	head_row.add_child(kpis)
	col.add_child(head)

	var ctl := PanelContainer.new()
	ctl.theme_type_variation = &"WinCtl"
	ctl.custom_minimum_size.y = 56
	var ctl_row := HBoxContainer.new()
	ctl_row.add_theme_constant_override("separation", UiTokens.SPACE_L)
	ctl.add_child(ctl_row)
	var tabs := UiFactory.D_seg_tabs([_tr("HR_TAB_ROSTER"), _tr("HR_TAB_ASSIGNMENTS")], 0, func(_i: int) -> void: pass)
	tabs.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	ctl_row.add_child(tabs)
	var chip := Button.new()
	chip.theme_type_variation = &"ChipButton"
	chip.icon = load("res://assets/icons/clock.svg")
	chip.text = _tr("HR_HOURS_WINDOW").format({"start": "09:00", "end": "17:00"})
	chip.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	ctl_row.add_child(chip)
	var hire := Button.new()
	hire.theme_type_variation = &"PrimaryButtonDark"
	hire.icon = load("res://assets/icons/util/plus.svg")
	hire.text = _tr("HR_SEARCH_START_INLINE")
	hire.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	ctl_row.add_child(hire)
	col.add_child(ctl)

	var body := MarginContainer.new()
	for side in ["left", "right", "bottom"]:
		body.add_theme_constant_override("margin_" + side, UiTokens.SPACE_3XL)
	body.add_theme_constant_override("margin_top", UiTokens.SPACE_XL)
	col.add_child(body)
	var list := VBoxContainer.new()
	list.add_theme_constant_override("separation", 0)
	body.add_child(list)
	var risky := Character.new()
	risky.character_name = String(ROWS[4].name)
	risky.morale = int(ROWS[4].morale)
	list.add_child(HRUiShared.D_risk_strip(risky, func() -> void: pass))
	var space := Control.new()
	space.custom_minimum_size.y = UiTokens.SPACE_L
	list.add_child(space)
	list.add_child(_head())
	list.add_child(HRUiShared.D_group(_tr("HR_GROUP_PRODUCT_DESIGN"), GROUP_GLYPH, 0, false, func() -> void: pass))
	for r: Dictionary in ROWS:
		list.add_child(_row(r))
	list.add_child(HRUiShared.D_group(_tr("HR_GROUP_DEVELOPMENT"), GROUP_GLYPH, 14, true, func() -> void: pass))
	list.add_child(HRUiShared.D_group(_tr("HR_GROUP_CUSTOMER_SUCCESS"), GROUP_GLYPH, 0, false, func() -> void: pass))
	list.add_child(HRUiShared.D_empty_row(_tr("HR_EMPTY_ROW"), _tr("HR_SEARCH_START_INLINE"), func() -> void: pass))
	return win


static func _head() -> PanelContainer:
	var head := PanelContainer.new()
	head.theme_type_variation = &"TableHead"
	head.custom_minimum_size.y = 36
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 0)
	head.add_child(row)
	var lead := Control.new()
	lead.custom_minimum_size.x = W[0]
	row.add_child(lead)
	row.add_child(HRUiShared.D_head(_tr("HR_COL_EMPLOYEE"), W[1], HORIZONTAL_ALIGNMENT_LEFT))
	row.add_child(HRUiShared.D_head(_tr("HR_COL_ROLES"), W[2] * 6))
	var keys := ["HR_AREA_LEADERSHIP", "HR_COL_TASK", "HR_COL_EXPERIENCE", "HR_COL_STATE", "HR_COL_TRAIT",
		"HR_COL_SALARY", "HR_COL_MORALE"]
	for i in keys.size():
		row.add_child(HRUiShared.D_head(_tr(keys[i]), W[i + 3], HORIZONTAL_ALIGNMENT_LEFT if i in [1, 3, 4] else
			HORIZONTAL_ALIGNMENT_CENTER))
	return head


static func _row(r: Dictionary) -> PanelContainer:
	var row := HRUiShared.D_row(r.get("selected", false))
	if r.get("hover", false):
		row.theme_type_variation = &"TableRowHover"
	var cells := HBoxContainer.new()
	cells.add_theme_constant_override("separation", 0)
	row.add_child(cells)
	var face := CenterContainer.new()
	face.custom_minimum_size.x = W[0]
	face.add_child(UiFactory.make_avatar(UiFactory.initials_of(r.name), UiTokens.D_AVATAR_ROW))
	cells.add_child(face)
	var who := VBoxContainer.new()
	who.custom_minimum_size.x = W[1]
	who.alignment = BoxContainer.ALIGNMENT_CENTER
	who.add_theme_constant_override("separation", 0)
	var away: bool = r.get("away", false)
	who.add_child(UiFactory.make_label(r.name, &"DataMedium" if away else &"DataStrong", UiTokens.D_INK_3 if away else null))
	who.add_child(UiFactory.make_label(_tr("HR_ROLE_" + r.role), &"CondCaption"))
	cells.add_child(who)
	for i in 6:
		var rank: StringName = &"main" if i == r.main else (&"secondary" if i == r.get("second", -1) else &"")
		cells.add_child(HRUiShared.D_skill_cell(r.skills[i], rank, W[2], rank != &""))
	cells.add_child(_text(str(r.lead), W[3], &"DataText", HORIZONTAL_ALIGNMENT_CENTER))
	cells.add_child(_text("" if r.get("idle", false) else _tr("HR_TASK_ON_JOB_BUILD"), W[4], &"CondData"))
	cells.add_child(_xp(W[5]))
	var state := HBoxContainer.new()
	state.custom_minimum_size.x = W[6]
	state.add_theme_constant_override("separation", UiTokens.SPACE_S)
	for t: Array in r.tags:
		state.add_child(UiFactory.D_tag(_tr(t[0]), t[1]))
	if r.has("weeks"):
		var weeks := UiFactory.make_label(_tr("DESK_PAPER_WEEKS").format({"n": r.weeks}), &"CondCaption")
		weeks.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		state.add_child(weeks)
	cells.add_child(state)
	var trait_cell := HRUiShared.D_trait_cell([r.trait] if r.trait != "" else [])
	trait_cell.custom_minimum_size.x = W[7]
	cells.add_child(trait_cell)
	cells.add_child(_text(Fmt.money_exact(r.salary), W[8], &"DataText", HORIZONTAL_ALIGNMENT_RIGHT))
	var morale := HRUiShared.D_morale(r.morale, {})
	morale.custom_minimum_size.x = W[9]
	morale.alignment = BoxContainer.ALIGNMENT_END
	cells.add_child(morale)
	return row


static func _text(text: String, width: int, variation: StringName,
		align := HORIZONTAL_ALIGNMENT_LEFT) -> Label:
	var label := UiFactory.make_label(text, variation)
	label.custom_minimum_size.x = width
	label.horizontal_alignment = align
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.clip_text = true
	return label


static func _xp(width: int) -> HBoxContainer:
	var xp := HBoxContainer.new()
	xp.custom_minimum_size.x = width
	xp.add_theme_constant_override("separation", UiTokens.SPACE_M)
	var track := Panel.new()
	track.theme_type_variation = &"BarTrack"
	track.custom_minimum_size = Vector2(32, 4)
	track.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	xp.add_child(track)
	var value := UiFactory.make_label(Fmt.percent(0, 0), &"MetaMuted")
	value.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	xp.add_child(value)
	return xp


static func _samples() -> VBoxContainer:
	var col := VBoxContainer.new()
	col.custom_minimum_size.x = 472
	col.add_theme_constant_override("separation", UiTokens.SPACE_XL)
	var tags := HFlowContainer.new()
	tags.add_theme_constant_override("h_separation", UiTokens.SPACE_M)
	tags.add_theme_constant_override("v_separation", UiTokens.SPACE_M)
	for t in [["HR_BADGE_NEW", &""], ["HR_BADGE_FLIGHT_RISK", &"risk"], ["SALES_CHIP_RISK", &"risk"],
			["HR_BADGE_OVERLOADED_JOBS", &"warn"], ["HR_FOUNDER_STATE_TRAINING", &"neutral"],
			["HR_BADGE_IDLE", &"outline"]]:
		tags.add_child(UiFactory.D_tag(_tr(t[0]), t[1]))
	col.add_child(tags)
	var parts := HBoxContainer.new()
	parts.add_theme_constant_override("separation", UiTokens.SPACE_3XL)
	parts.add_child(UiFactory.D_cost(Fmt.money_exact(2793)))
	parts.add_child(UiFactory.D_cost(Fmt.money_exact(3267), &"DataStrong"))
	parts.add_child(UiFactory.D_cost(Fmt.money_exact(294), &"MetaMuted"))
	col.add_child(parts)
	var when := _tr("SAVE_TOAST_WHEN").format({"week": 14, "time": "11:00"})
	for t in [
		["SAVE_TOAST_SAVED", when, "util/check", UiTokens.D_pos()],
		["SAVE_TOAST_NOT_SAVED", _tr("SAVE_ERR_MODAL_OPEN"), "util/save", UiTokens.D_warn()],
		["SAVE_TOAST_LOADED", _tr("SAVE_TOAST_LOADED_WHEN").format({"slot": _tr("SAVE_QUICK_SLOT"), "week": 14,
			"time": "11:00"}), "util/load", UiTokens.D_pos()],
		["OFFICE_TOAST_MOVE_STARTED", _tr("OFFICE_NAME_ISHANI"), "util/move", UiTokens.D_INK_3],
		["MEETING_POSTPONED", _tr("MEETING_POSTPONED_SALES"), "util/calendar", UiTokens.D_INK_3],
	]:
		col.add_child(_toast(t[0], t[1], t[2], t[3]))
	var share := _toast("ENDING_SAVED_TOAST", "gazete_series_a_close_20261003-114233.png", "util/check", UiTokens.D_pos())
	share.size_flags_horizontal = Control.SIZE_FILL
	share.set_action(_tr("ENDING_OPEN_FOLDER"), func() -> void: pass)
	col.add_child(share)
	var focus := HBoxContainer.new()
	focus.add_theme_constant_override("separation", UiTokens.SPACE_3XL)
	var button := Button.new()
	button.text = _tr("UI_DISMISS")
	focus.add_child(button)
	var slider := HSlider.new()
	slider.custom_minimum_size.x = 200
	slider.value = 40
	slider.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	focus.add_child(slider)
	col.add_child(focus)
	# Focus shows once the page is in the tree.
	button.ready.connect(button.grab_focus)
	var menu_anchor := Control.new()
	menu_anchor.ready.connect(func() -> void: _open_menu(menu_anchor), CONNECT_DEFERRED)
	col.add_child(menu_anchor)
	return col


## The row menu opened dark (HRPopover.mount(anchor, true)) with the head the Ekip menu opens with;
## its items come with the Ekip screen.
static func _open_menu(anchor: Control) -> void:
	var pop: HRPopover = HRPopover.mount(anchor, true)
	var head := MarginContainer.new()
	for side in ["left", "top", "right", "bottom"]:
		head.add_theme_constant_override("margin_" + side, UiTokens.SPACE_M)
	pop.body().add_child(head)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", UiTokens.SPACE_M)
	head.add_child(row)
	row.add_child(UiFactory.make_avatar(UiFactory.initials_of(ROWS[2].name), UiTokens.D_AVATAR_ROW))
	var who := VBoxContainer.new()
	who.add_theme_constant_override("separation", 0)
	who.add_child(UiFactory.make_label(ROWS[2].name, &"DataStrong"))
	who.add_child(UiFactory.make_label(_tr("HR_ROLE_" + ROWS[2].role), &"CondCaption"))
	row.add_child(who)
	pop.open_at(anchor)


## A toast in a column, shown once it is in the tree (its tween needs the tree).
static func _toast(head: String, sub: String, glyph: String, tone: Color) -> PanelContainer:
	var toast: PanelContainer = TOAST.new()
	toast.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	toast.ready.connect(toast.show_toast.bind(_tr(head), sub, load("res://assets/icons/%s.svg" % glyph), tone))
	return toast
