extends Control

# Kişisel penceresi, kurucunun tek görüntüleme yüzeyi (Ekip GDD §2.5). Ortak koyu başlıkta kıdemi; gövdede üç
# sütun: portre, görev, deneyim ve eğitim; ad, köken, beceriler ve huylar; kilometre taşları, evre merdiveni ve
# hedefi, hisse. Bu dosya hiçbir sonucu hesaplamaz: hisse Finans'ın pay tablosudur (FinanceOzetView.cap_table),
# değerleme GameState.get_valuation_m'dir (Seed'in post-money'si, imzadan sonra Series A'nınki); tur yokken not bunu söyler.

const TRAINING_MODAL := "res://scenes/modals/TrainingModal.tscn"
const SKILL_ICON := "res://assets/icons/skill/%s.svg"
const TRAINING_ICON := "res://assets/icons/world/training.svg"
const MILESTONE_ICON := "res://assets/icons/world/milestone.svg"
const GOAL_KEYS := ["PER_GOAL_BOOTSTRAP", "PER_GOAL_TRACTION", "PER_GOAL_SERIES_A"]
## Kazanılmış taşın tek cümle notu, taşın anahtarıyla (GameState.milestones).
const MILESTONE_NOTES := {"MILESTONE_FOUNDING": "PERSONAL_MS_FOUNDING_NOTE",
	"MILESTONE_FIRST_SHIP": "PERSONAL_MS_SHIP_NOTE",
	"MILESTONE_FIRST_FUNDING": "PERSONAL_MS_FUNDING_NOTE"}

## The window keeps its 680 and grows past it by what the page needs, within the area: the read-only strip, a
## long note (WindowLayer reads fit_height).
signal fit_changed

## The window's head (WindowFrame reads it before the page is in the tree).
var frame_options: Dictionary
var _kpis: HBoxContainer
var _body: MarginContainer
var _cols: HBoxContainer
var _signals: Array = []


func _init() -> void:
	_kpis = SprintUiShared.box(0)
	frame_options = {"title": "TAB_PERSONAL", "kpi": _kpis, "pad": Vector2i.ZERO}


func _ready() -> void:
	# A short window scrolls the page; the scroll lives outside the rebuild, so a tick keeps the place read.
	var scroll := ScrollContainer.new()
	scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(scroll)
	_cols = SprintUiShared.box(UiTokens.SPACE_3XL)
	_body = SprintUiShared.pad(_cols, Vector4i(UiTokens.SPACE_3XL, UiTokens.SPACE_XL, UiTokens.SPACE_3XL,
		UiTokens.SPACE_3XL))
	_body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(_body)
	# Wrapped text knows its height only once it has its width: the window refits when it settles.
	_body.minimum_size_changed.connect(fit_changed.emit)
	_signals = [EventBus.equity_changed, EventBus.phase_changed, EventBus.hr_day_processed,
		EventBus.employee_experience_changed, EventBus.employee_training_changed, EventBus.version_shipped,
		# While a decision waits the training button is off.
		EventBus.event_triggered, EventBus.event_resolved, EventBus.event_set_aside]
	for sig: Signal in _signals:
		sig.connect(_build)
	_build()


func _exit_tree() -> void:
	for sig: Signal in _signals:
		sig.disconnect(_build)


## The page's height: its body, and never less than the 680 window leaves it.
func fit_height() -> float:
	return maxf(_body.get_combined_minimum_size().y, UiTokens.D_H_PERSONAL_BODY)


func _build(_a = null, _b = null) -> void:
	var founder: Character = CharacterRegistry.get_founder()
	UiFactory.clear(_kpis)
	# Tenure is the run's week: the founder was never hired.
	_kpis.add_child(UiFactory.D_kpi(tr("PER_TENURE_KEY"), tr("PER_TENURE_VALUE").format({"n": GameState.day})))
	UiFactory.clear(_cols)
	_cols.add_child(_work(founder))
	_cols.add_child(_sheet(founder))
	_cols.add_child(_standing())


## The portrait, what the founder is doing, the experience bar and the way to training.
func _work(founder: Character) -> VBoxContainer:
	var col := SprintUiShared.column(0)
	col.custom_minimum_size.x = UiTokens.D_PORTRAIT_WELL.x
	# A run saved before the portraits has none: the well stays empty.
	var face := TextureRect.new()
	var path: String = FounderConstants.portrait_path(GameState.founder_portrait)
	if ResourceLoader.exists(path):
		face.texture = load(path)
	col.add_child(UiFactory.D_portrait_well(face))
	col.add_child(_above(SprintUiShared.label(Fmt.upper(tr("PER_TASK_LABEL")), &"KeyLabel"), UiTokens.SPACE_XL))
	col.add_child(SprintUiShared.prose(HRSystem.founder_task_label(), &"DataText"))
	col.add_child(_above(SprintUiShared.label(Fmt.upper(tr("PER_EXPERIENCE")), &"KeyLabel"), UiTokens.SPACE_L))
	col.add_child(_above(HRUiShared.D_xp(founder, UiTokens.D_XP_BAR_WIDE), UiTokens.SPACE_S))
	var train := SprintUiShared.button(tr("HR_TRAINING_PICK_TITLE"), &"SecondaryButton", func() -> void:
		HRUiShared.mount_panel_modal(self, TRAINING_MODAL, _build, [founder.id]))
	train.icon = load(TRAINING_ICON)
	train.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	var reason: String = CharacterRegistry.training_block_reason(founder.id)
	train.disabled = reason != "" or EventGate.active_id() != ""
	col.add_child(_above(train, UiTokens.SPACE_XXL))
	# In training the task line says so; the registry's reason would speak of a bar that stays full till it ends.
	if reason != "" and founder.status == HRConstants.STATUS_ACTIVE:
		col.add_child(_above(SprintUiShared.prose(reason, &"Caption"), UiTokens.SPACE_M))
	return col


## The name and origin, the skills on their meters, the traits.
func _sheet(founder: Character) -> VBoxContainer:
	var col := SprintUiShared.column(0)
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col.add_child(SprintUiShared.prose(founder.character_name, &"TitleH2"))
	var origin: Dictionary = FounderConstants.origin_by_id(GameState.origin)
	col.add_child(_above(UiFactory.D_tag(tr(String(origin.name_key)), &"outline"), UiTokens.SPACE_M))
	col.add_child(_above(SprintUiShared.prose(tr(String(origin.quote_key)), &"OriginQuote"), UiTokens.SPACE_L))
	col.add_child(_above(_section("HR_DOSSIER_SKILLS"), UiTokens.SPACE_XXL))
	var skills := SprintUiShared.column(0)
	col.add_child(_above(skills, UiTokens.SPACE_M))
	for key: String in HRConstants.AREAS + [HRConstants.SKILL_LEADERSHIP, FounderConstants.SKILL_CHARISMA]:
		if key == HRConstants.SKILL_LEADERSHIP:
			skills.add_child(SprintUiShared.pad(HSeparator.new(), Vector4i(0, UiTokens.SPACE_S, 0, UiTokens.SPACE_S)))
		skills.add_child(_skill_row(key, int(founder.role_stats.get(key, 0))))
	# The traits' effects are not wired yet (Ekip §2.6): the picked ones by name, under SOON, on the neutral glyph.
	var head := _section("PER_TRAITS")
	var soon := UiFactory.D_tag(tr("SYS_SOON"), &"outline")
	head.add_child(soon)
	head.move_child(soon, 1)
	col.add_child(_above(head, UiTokens.SPACE_XL))
	var traits := SprintUiShared.box(UiTokens.SPACE_XL)
	for trait_id: String in founder.traits:
		var box := PanelContainer.new()
		box.theme_type_variation = &"TraitBox"
		box.add_child(UiFactory.make_glyph(HRUiShared.D_TRAIT_DIR + "unspecified.svg", UiTokens.D_ICON_ROW,
			UiTokens.D_INK_3))
		var cell := SprintUiShared.box(UiTokens.SPACE_S)
		cell.add_child(box)
		cell.add_child(SprintUiShared.label(tr(String(FounderConstants.trait_by_id(trait_id).name_key)), &"DataText"))
		traits.add_child(cell)
	col.add_child(_above(traits, UiTokens.SPACE_M))
	return col


## A skill: the area's glyph, its name, its meter and its figure in the ramp's ink.
func _skill_row(key: String, value: int) -> HBoxContainer:
	var row := SprintUiShared.box(UiTokens.SPACE_M)
	row.custom_minimum_size.y = UiTokens.D_H_SHEET_ROW
	var glyph: Control = UiFactory.make_glyph(SKILL_ICON % key, UiTokens.D_ICON_ROW, UiTokens.D_INK_3) \
		if key in HRConstants.AREAS else Control.new()
	glyph.custom_minimum_size.x = UiTokens.D_ICON_ROW
	row.add_child(glyph)
	var label := SprintUiShared.label(Fmt.upper(HRUiShared.skill_label(key)), &"KeyLabel")
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.clip_text = true
	label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	row.add_child(label)
	row.add_child(_meter(value))
	var figure := HRUiShared.D_skill_figure(value, &"")
	figure.custom_minimum_size.x = UiTokens.D_W_SKILL_FIGURE
	figure.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	row.add_child(figure)
	return row


## A cell a point, grouped by the stars of the rule; the first `value` cells in the ramp's ink.
func _meter(value: int) -> Control:
	var cell: int = UiTokens.D_SQUARE_SM
	var per: int = HRConstants.POINTS_PER_STAR
	var star_w: int = per * cell + (per - 1) * UiTokens.SPACE_XXS + UiTokens.SPACE_XS
	var meter := Control.new()
	meter.custom_minimum_size = Vector2(HRConstants.STAR_MAX * star_w - UiTokens.SPACE_XS, cell)
	meter.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	meter.draw.connect(func() -> void:
		for star in HRConstants.STAR_MAX:
			for point in per:
				meter.draw_rect(Rect2(star * star_w + point * (cell + UiTokens.SPACE_XXS), 0, cell, cell),
					UiTokens.D_skill(value) if star * per + point < value else UiTokens.D_BAR_TRACK))
	return meter


## The milestones, where the run stands and its goal, the founder's share.
func _standing() -> VBoxContainer:
	var col := SprintUiShared.column(0)
	col.custom_minimum_size.x = UiTokens.D_W_STANDING
	col.add_child(_section("PERSONAL_MILESTONES_TITLE"))
	col.add_child(_above(_milestones(), UiTokens.SPACE_L))
	col.add_child(_above(_section("PER_WHERE_AM_I"), UiTokens.SPACE_3XL))
	var ladder := SprintUiShared.column(0)
	col.add_child(_above(ladder, UiTokens.SPACE_M))
	for i in GameState.PHASE_KEYS.size():
		var here: bool = GameState.phase == i + 1
		var row := SprintUiShared.box(UiTokens.SPACE_L)
		row.custom_minimum_size.y = UiTokens.D_H_SHEET_ROW
		row.add_child(HRUiShared.D_bar(UiTokens.D_PHASE_MARK, 1.0 if here else 0.0, UiTokens.D_INK_1))
		row.add_child(SprintUiShared.label(tr(GameState.PHASE_KEYS[i]), &"DataStrong" if here else &"NoteMuted"))
		ladder.add_child(row)
	var spot := MarginContainer.new()
	spot.add_theme_constant_override("margin_top", UiTokens.SPACE_L)
	col.add_child(spot)
	var goal := UiFactory.D_card(spot)
	goal.add_theme_constant_override("separation", UiTokens.SPACE_XS)
	goal.add_child(SprintUiShared.label(Fmt.upper(tr("PER_PHASE_GOAL")), &"KeyLabel"))
	goal.add_child(SprintUiShared.label(tr(GOAL_KEYS[GameState.phase - 1]), &"SubjectStrong"))
	col.add_child(_above(_section("PER_NET_WORTH"), UiTokens.SPACE_3XL))
	var share := SprintUiShared.column(UiTokens.SPACE_M)
	FinanceOzetView.cap_table(share)
	var valuation: float = GameState.get_valuation_m()
	if valuation > 0.0:
		share.add_child(SprintUiShared.label(tr("PER_VALUATION_ROW").format(
			{"value": Fmt.money_chip(int(round(valuation * 1_000_000.0)))}), &"MetaText"))
	else:
		share.add_child(SprintUiShared.prose(tr("PER_NO_VALUATION"), &"Caption"))
	col.add_child(_above(share, UiTokens.SPACE_M))
	return col


## A ledger down the column: each milestone's disc on a line to the next; an earned one in ink with its glyph,
## date or sum and its note, the rest an open ring.
func _milestones() -> VBoxContainer:
	var ledger := SprintUiShared.column(0)
	var rows: Array = GameState.milestones()
	for i in rows.size():
		var earned: bool = rows[i].earned
		var last: bool = i == rows.size() - 1
		var row := SprintUiShared.box(UiTokens.SPACE_L)
		var rail := SprintUiShared.column(UiTokens.SPACE_XXS)
		var dot: Control = PanelContainer.new() if earned else Panel.new()
		dot.theme_type_variation = &"MilestoneDot" if earned else &"LockDisc"
		dot.custom_minimum_size = Vector2.ONE * UiTokens.D_MILESTONE_DOT
		if earned:
			dot.add_child(UiFactory.make_glyph(MILESTONE_ICON, UiTokens.D_ICON_PART, UiTokens.D_INK_1))
		rail.add_child(dot)
		if not last:
			var line := VSeparator.new()
			line.size_flags_vertical = Control.SIZE_EXPAND_FILL
			rail.add_child(line)
		row.add_child(rail)
		var text := SprintUiShared.column(UiTokens.SPACE_XXS)
		var head := SprintUiShared.box(UiTokens.SPACE_M)
		var title := SprintUiShared.label(tr(String(rows[i].key)), &"SubjectStrong" if earned else &"SubjectLabel",
			null if earned else UiTokens.D_INK_3)
		title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		head.add_child(title)
		head.add_child(SprintUiShared.label(String(rows[i].meta), &"MetaMuted"))
		text.add_child(head)
		if earned:
			text.add_child(SprintUiShared.prose(tr(MILESTONE_NOTES[rows[i].key]), &"Caption"))
		# The gap to the next milestone is inside the row, so the line runs through it.
		var body: Control = text if last else SprintUiShared.pad(text, Vector4i(0, 0, 0, UiTokens.SPACE_L))
		body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(body)
		ledger.add_child(row)
	return ledger


## A section's caps key and its rule, as tall as the key: the sheet is dense.
func _section(key: String) -> HBoxContainer:
	var head := SprintUiShared.section(key)
	head.custom_minimum_size.y = 0
	return head


## `child` a step below what comes before it.
func _above(child: Control, gap: int) -> MarginContainer:
	return SprintUiShared.pad(child, Vector4i(0, gap, 0, 0))
