extends PanelContainer

## The company's first week, beside every onboarding step: the letterhead, the founder's file, the difficulty, the
## week's money and the guided start, filling as the steps are answered. No run exists yet, so the money is read
## from the constants the run will start from. Its two controls tell the flow, which owns the draft.

signal picked(field: String, value: Variant)

const EMBLEM := 56
const PORTRAIT := [Vector2(80, 100), Vector2(64, 80)]
const KEY_W := [96, 84]
const BAR_W := [50, 40]

## Hard opens on the profile's finished runs; the onboarding shot sets it here and never writes the profile.
var hard_open: bool = int(Settings.get_value("runs_finished", 0)) >= FounderConstants.HARD_OPENS_AFTER_RUNS
var _v := {}   # the parts show_draft fills


## Builds the sheet for a screen 1080 tall or shorter.
func lay_out(short: bool) -> void:
	UiFactory.clear(self)
	_v.clear()
	# The shorter sheet keeps every part by closing the gaps between them.
	var pad := MarginContainer.new()
	for side in ["left", "top", "right", "bottom"]:
		pad.add_theme_constant_override("margin_" + side, UiTokens.SPACE_XL if short else UiTokens.SPACE_3XL)
	add_child(pad)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", UiTokens.SPACE_M if short else UiTokens.SPACE_XL)
	pad.add_child(col)

	var head := HBoxContainer.new()
	var title := UiFactory.make_label(Fmt.upper(tr("ONB_FIRST_WEEK")), &"KeyLabel")
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(title)
	var d: Dictionary = GameState.get_date_dict(1)
	head.add_child(UiFactory.make_label(Fmt.upper(tr("ONB_WEEK_ONE").format({"month": Fmt.month_name(d.month), "year": d.year})), &"MetaMuted"))
	col.add_child(head)

	var letterhead := HBoxContainer.new()
	letterhead.add_theme_constant_override("separation", UiTokens.SPACE_XL)
	_v.slot = Control.new()
	_v.slot.custom_minimum_size = Vector2.ONE * EMBLEM
	OnboardingStep.dash(_v.slot)
	letterhead.add_child(_v.slot)
	_v.emblem = LogoEmblem.new(EMBLEM)
	letterhead.add_child(_v.emblem)
	var names := VBoxContainer.new()
	names.alignment = BoxContainer.ALIGNMENT_CENTER
	_v.company = UiFactory.make_label("", &"CompanyTitle")
	names.add_child(_v.company)
	_v.company_line = UiFactory.make_label("", &"MetaMuted")
	names.add_child(_v.company_line)
	letterhead.add_child(names)
	col.add_child(letterhead)
	col.add_child(HSeparator.new())

	var founder := HBoxContainer.new()
	founder.add_theme_constant_override("separation", UiTokens.SPACE_XL)
	var well := PanelContainer.new()
	well.theme_type_variation = &"PortraitWell"
	well.custom_minimum_size = PORTRAIT[int(short)]
	well.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	_v.face = TextureRect.new()
	_v.face.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_v.face.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	well.add_child(_v.face)
	founder.add_child(well)
	var who := VBoxContainer.new()
	who.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_v.founder = UiFactory.make_label("", &"NameTitle")
	who.add_child(_v.founder)
	_v.pending = UiFactory.make_label(tr("ONB_DOC_STEP2"), &"Caption")
	_v.pending.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	who.add_child(_v.pending)
	_v.origin = UiFactory.make_label("", &"DataText")
	who.add_child(_v.origin)
	_v.chips = HFlowContainer.new()
	_v.chips.add_theme_constant_override("h_separation", UiTokens.SPACE_S)
	_v.chips.add_theme_constant_override("v_separation", UiTokens.SPACE_S)
	who.add_child(_v.chips)
	founder.add_child(who)
	col.add_child(founder)

	# Two columns of four, read down: the six areas' first four, then sales, success, Liderlik and Karizma.
	var skills := GridContainer.new()
	skills.columns = 2
	skills.add_theme_constant_override("h_separation", UiTokens.SPACE_3XL)
	_v.skills = {}
	var half := FounderConstants.SKILLS.size() / 2
	for i in half * 2:
		var skill: String = FounderConstants.SKILLS[i / 2 + half * (i % 2)]
		var row := HBoxContainer.new()
		row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_theme_constant_override("separation", UiTokens.SPACE_S)
		var label := UiFactory.make_label(tr(FounderConstants.SKILL_NAME_KEYS[skill]), &"CondCaption")
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(label)
		var bar := SegmentBar.new()
		bar.custom_minimum_size.x = BAR_W[int(short)]
		bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		row.add_child(bar)
		var value := UiFactory.make_label("", &"CaptionPrimary")
		value.custom_minimum_size.x = UiTokens.SPACE_L
		value.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		row.add_child(value)
		skills.add_child(row)
		_v.skills[skill] = [label, bar, value]
	col.add_child(skills)
	col.add_child(HSeparator.new())

	var diff_head := HBoxContainer.new()
	var diff_title := UiFactory.make_label(Fmt.upper(tr("ONB_DIFFICULTY")), &"KeyLabel")
	diff_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	diff_head.add_child(diff_title)
	diff_head.add_child(UiFactory.make_label(tr("ONB_DIFFICULTY_NOTE"), &"Caption"))
	col.add_child(diff_head)
	var cells := HBoxContainer.new()
	cells.add_theme_constant_override("separation", UiTokens.SPACE_M)
	var group := ButtonGroup.new()
	_v.cells = {}
	for id: String in FounderConstants.DIFFICULTY_CASH_MULT:
		var cell := Button.new()
		cell.theme_type_variation = &"ChipFilter"
		cell.toggle_mode = true
		cell.button_group = group
		cell.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		cell.alignment = HORIZONTAL_ALIGNMENT_LEFT
		cell.icon_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		cell.vertical_icon_alignment = VERTICAL_ALIGNMENT_TOP
		if id == "hard" and not hard_open:
			cell.disabled = true
			cell.icon = load(UiFactory.LOCK_ICON)
		cell.pressed.connect(picked.emit.bind("difficulty", id))
		cells.add_child(cell)
		_v.cells[id] = cell
	col.add_child(cells)
	if not hard_open:
		var why := HBoxContainer.new()
		why.add_theme_constant_override("separation", UiTokens.SPACE_S)
		why.add_child(UiFactory.make_glyph(UiFactory.LOCK_ICON, UiTokens.D_ICON_TAG, UiTokens.D_INK_3))
		why.add_child(UiFactory.make_label(tr("ONB_DIFF_HARD_LOCKED"), &"Caption"))
		col.add_child(why)
	col.add_child(HSeparator.new())

	var table := GridContainer.new()
	table.columns = 3
	table.add_theme_constant_override("h_separation", UiTokens.SPACE_L)
	table.add_theme_constant_override("v_separation", UiTokens.SPACE_M)
	for row: Array in [["FIN_CAP_CASH", "cash", &"HeroValue"], ["FIN_CAP_BURN", "burn", &"ValueText"],
			["ONB_DOC_OFFICE", "office", &"ValueText"], ["ONB_DOC_TEAM", "team", &"ValueText"]]:
		var key := UiFactory.make_label(Fmt.upper(tr(row[0])), &"KeyLabel")
		key.custom_minimum_size.x = KEY_W[int(short)]
		table.add_child(key)
		_v[row[1]] = UiFactory.make_label("", row[2])
		_v[row[1]].size_flags_horizontal = Control.SIZE_EXPAND_FILL
		table.add_child(_v[row[1]])
		var note: Control = MarginContainer.new() if row[1] == "cash" \
			else UiFactory.make_label(tr("ONB_DOC_BURN") if row[1] == "burn" else "", &"Caption")
		if row[1] == "cash":
			_v.cash_tag = note
		table.add_child(note)
	_v.office.text = tr("OFFICE_NAME_HOME")
	_v.team.text = tr("ONB_TEAM_SOLO")
	col.add_child(table)

	var room := Control.new()
	room.size_flags_vertical = Control.SIZE_EXPAND_FILL
	col.add_child(room)
	col.add_child(HSeparator.new())
	# Guided start silences every card but the tutorial's, so it opens only once the guide's cards exist.
	var written := _guide_written()
	_v.guided = CheckButton.new()
	_v.guided.text = tr("ONB_GUIDED")
	_v.guided.disabled = not written
	_v.guided.toggled.connect(func(on: bool) -> void: picked.emit("frank_guided", on))
	col.add_child(_v.guided)
	_v.guided_note = UiFactory.make_label(tr("ONB_GUIDED_NOTE" if written else "ONB_GUIDED_LOCKED"), &"Caption")
	_v.guided_note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	col.add_child(_v.guided_note)


## `step` is the step on screen (0, 1, 2): the company stands on the letterhead from the third.
func show_draft(draft: Dictionary, step: int) -> void:
	var company: String = draft.company_name
	var named := step == 2 and company != ""
	_v.slot.visible = not named
	_v.emblem.visible = named
	_v.emblem.configure(draft.logo)
	_v.company.visible = named
	_v.company.text = company
	var founder: String = draft.founder_name
	var line := tr("ONB_FOUNDER_LINE").format({"name": founder})
	if founder == "":
		# An unnamed founder goes by the role, which the line opens with: the role once, not twice.
		founder = tr("HR_ROLE_FOUNDER")
		line = founder
	_v.company_line.text = line if named else tr("ONB_DOC_COMPANY_EMPTY")

	_v.face.texture = load(FounderConstants.portrait_path(draft.portrait_id))
	_v.founder.text = founder
	_v.pending.visible = step == 0
	_v.origin.visible = step > 0
	_v.chips.visible = step > 0
	_v.origin.text = tr(FounderConstants.origin_by_id(draft.origin_id).name_key)
	UiFactory.clear(_v.chips)
	for id: String in draft.trait_ids:
		var t: Dictionary = FounderConstants.trait_by_id(id)
		_v.chips.add_child(UiFactory.D_tag(tr(t.name_key), &"pos" if t.polarity == "positive" else &"risk"))
	for skill: String in _v.skills:
		var ruler := FounderConstants.to_ruler(int(draft.skill_alloc.get(skill, 0)))
		var row: Array = _v.skills[skill]
		row[0].add_theme_color_override("font_color", UiTokens.D_INK_3 if ruler == 0 else UiTokens.D_INK_1)
		row[1].set_filled(ruler)
		row[2].text = str(ruler)

	for id: String in _v.cells:
		_v.cells[id].text = "%s\n%s" % [Fmt.upper(tr("ONB_DIFF_" + id.to_upper())),
			Fmt.money_exact(FounderConstants.starting_cash(draft.origin_id, id))]
		_v.cells[id].set_pressed_no_signal(id == draft.difficulty)
	var cash := FounderConstants.starting_cash(draft.origin_id, draft.difficulty)
	_v.cash.text = Fmt.money_exact(cash)
	UiFactory.clear(_v.cash_tag)
	_v.cash_tag.add_child(UiFactory.D_tag(tr("ONB_DIFF_" + draft.difficulty.to_upper()), &"outline"))
	# The run opens with nothing to pay and no revenue: there is no runway to read, so the table has no row for it.
	_v.burn.text = Fmt.money_chip(FinanceSystem.starting_daily_burn() * TimeModel.DAYS_PER_MONTH)
	_v.guided.set_pressed_no_signal(draft.frank_guided)
	_v.guided_note.visible = _v.guided.disabled or draft.frank_guided


## A card tagged for the tutorial ships in this build.
static func _guide_written() -> bool:
	return EvCatalog.card_ids().any(func(id: String) -> bool:
		var card := EvCatalog.card(id)
		return (card.tags as Array).has("tutorial") and EvTuning.SHIPPED_SCOPES.has(String(card.get("version_scope", "demo"))))
