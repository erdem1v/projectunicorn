extends Control

# New game, set in the founder's flat on its first evening: three tabbed papers (Karakter · Köken · Şirket) on the
# desk, the first-week document beside them, the chosen founder standing in the room behind. The draft is the one
# source of in-progress truth; nothing reaches GameState before Found and start, and the curtain covers the run and
# the shell being built.
#
# One step scene lives at a time (OnboardingStep). The root runs while the tree is paused (process_mode ALWAYS):
# main pauses the clock before mounting the flow.

signal completed   # the run is initialised: main swaps the flow for GameShell
signal cancelled   # back to the main menu, nothing kept

const MAIN_MENU_SCRIPT := preload("res://scripts/menu/main_menu.gd")
const STEPS: Array[PackedScene] = [
	preload("res://scenes/onboarding/steps/CharacterStep.tscn"),
	preload("res://scenes/onboarding/steps/OriginTraitsStep.tscn"),
	preload("res://scenes/onboarding/steps/CompanyStep.tscn"),
]
const STEP_NAME_KEYS := ["ONB_STEP_CHARACTER", "ONB_STEP_ORIGIN", "ONB_STEP_COMPANY"]
const CONFIRM_MODAL := preload("res://scenes/modals/ConfirmModal.tscn")
const STAGE_OFFICE := "home"
const MENU_STAGE_MINUTE := 1170.0   # [WORKING] 19:30
# The layout of a screen 1080 tall, then of a shorter one (1536×864 logical): the raised paper, the first-week
# document, the portrait standing in for the founder until the flat is up, the lock-up's S.
const PAPER := [Rect2(48, 388, 1348, 660), Rect2(24, 260, 1088, 588)]
const DOC := [Rect2(1428, 88, 444, 960), Rect2(1136, 80, 376, 768)]
const BUST := [Rect2(930, 66, 384, 480), Rect2(720, 62, 300, 375)]
const TAB_H := 44
const TAB_H_NOW := 53
const LOCKUP_S := 40
const CURTAIN_EMBLEM := 112
const CURTAIN_MARK_S := 24
const CANCEL_W := 480

var draft := {
	"founder_name": "",
	"portrait_id": "",
	"origin_id": "self_made",
	"trait_ids": [],
	"skill_alloc": {},
	"company_name": "",
	"logo_style": "",
	"difficulty": "normal",
	"frank_guided": false,
}
## When the curtain was first drawn: main measures the build behind it from here.
var curtain_msec := 0

var _index := 0
var _step: OnboardingStep
var _pristine := {}
var _confirm: Control
var _committing := false


func _ready() -> void:
	%Curtain.color = UiTokens.D_SURFACE_0
	%Doc.picked.connect(func(field: String, value: Variant) -> void:
		draft[field] = value
		_refresh())
	%Exit.icon = load("res://assets/icons/util/chevron_left.svg")
	%Exit.pressed.connect(_ask_cancel)
	%Back.pressed.connect(func() -> void: _mount_step(_index - 1))
	%Next.pressed.connect(_on_next)
	_apply_layout()
	get_viewport().size_changed.connect(_apply_layout)
	_pristine = draft.duplicate(true)
	%Stage.live_ready.connect(%Bust.hide)
	%Stage.start(STAGE_OFFICE, MENU_STAGE_MINUTE, LookSystem.founder(draft.portrait_id))


## Places the papers for the logical screen, and rebuilds what sizes itself by it.
func _apply_layout() -> void:
	var short := int(get_viewport_rect().size.y < 1080.0)
	%Doc.lay_out(bool(short))
	_mount_step(_index)
	# Sized once the new content is sorted: a Control never takes a size below its minimum of that moment, and a
	# wrapping label's minimum is known only once it has a width.
	(func() -> void:
		for part: Array in [[%Paper, PAPER], [%Doc, DOC], [%Bust, BUST]]:
			var at: Rect2 = part[1][short]
			part[0].position = at.position
			part[0].size = at.size).call_deferred()
	%Tabs.position = PAPER[short].position - Vector2(0, TAB_H_NOW)
	%Tabs.size.y = TAB_H_NOW
	%Lockup.custom_minimum_size = %Lockup.texture.get_size() * LOCKUP_S / MAIN_MENU_SCRIPT.LOCKUP_AUTHORED_S
	%Mark.custom_minimum_size = %Mark.texture.get_size() * CURTAIN_MARK_S / MAIN_MENU_SCRIPT.LOCKUP_AUTHORED_S


func _mount_step(index: int) -> void:
	if _step != null:
		draft.merge(_step.collect_payload(), true)
		_step.free()
	_index = index
	_step = STEPS[index].instantiate()
	_step.set_anchors_preset(Control.PRESET_FULL_RECT)
	%Body.add_child(_step)
	_step.prefill(draft)
	_step.changed.connect(_on_step_changed)
	%Counter.text = tr("ONB_STEP_COUNTER").format({"step": index + 1, "total": STEPS.size()})
	%Back.disabled = index == 0
	%Next.text = tr("ONB_START") if index == STEPS.size() - 1 else tr("ONB_NEXT")
	_on_step_changed()


func _on_step_changed() -> void:
	var face: String = draft.portrait_id
	draft.merge(_step.collect_payload(), true)
	if draft.portrait_id != face:
		%Bust.texture = load(FounderConstants.portrait_path(draft.portrait_id))
		%Stage.set_figure(LookSystem.founder(draft.portrait_id))
	_refresh()


func _refresh() -> void:
	%Reason.text = _step.invalid_reason()
	%Next.disabled = %Reason.text != ""
	%Doc.show_draft(draft, _index)
	_build_tabs()


## A tab per step over the paper: the one in hand raised; a finished one ticked, with what it settled.
func _build_tabs() -> void:
	UiFactory.clear(%Tabs)
	for i in STEPS.size():
		var tab := PanelContainer.new()
		tab.theme_type_variation = &"PickCardSelected" if i == _index else &"PickCard"
		tab.custom_minimum_size.y = TAB_H_NOW if i == _index else TAB_H
		tab.size_flags_vertical = Control.SIZE_SHRINK_END
		var pad := MarginContainer.new()
		pad.add_theme_constant_override("margin_left", UiTokens.SPACE_L)
		pad.add_theme_constant_override("margin_right", UiTokens.SPACE_XXL)
		tab.add_child(pad)
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", UiTokens.SPACE_M)
		pad.add_child(row)
		if i < _index:
			row.add_child(UiFactory.make_glyph("res://assets/icons/util/check.svg", UiTokens.D_ICON_ROW, UiTokens.D_INK_2))
		else:
			row.add_child(UiFactory.D_key_cap(i + 1))
		row.add_child(UiFactory.make_label(Fmt.upper(tr(STEP_NAME_KEYS[i])), &"NavLabelActive" if i == _index else &"NavLabel"))
		if i < _index:
			row.add_child(UiFactory.make_label(_settled(i), &"MetaMuted"))
		%Tabs.add_child(tab)


func _settled(step: int) -> String:
	if step == 1:
		return tr(FounderConstants.origin_by_id(draft.origin_id).name_key)
	return draft.founder_name if draft.founder_name != "" else tr("HR_ROLE_FOUNDER")


func _on_next() -> void:
	if _index < STEPS.size() - 1:
		_mount_step(_index + 1)
	else:
		_commit()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and not _committing:
		get_viewport().set_input_as_handled()
		_ask_cancel()


## Leaving with nothing chosen goes straight back; anything chosen asks first, staying the safe answer.
func _ask_cancel() -> void:
	draft.merge(_step.collect_payload(), true)
	if draft == _pristine:
		cancelled.emit()
		return
	if _confirm != null:
		return
	_confirm = CONFIRM_MODAL.instantiate()
	_confirm.confirmed.connect(cancelled.emit)
	_confirm.dismissed.connect(func() -> void: _confirm = null)
	add_child(_confirm)
	_confirm.populate({"title": tr("ONB_CANCEL_TITLE"), "body": tr("ONB_CANCEL_BODY"), "confirm_text": tr("SYS_MAIN_MENU"),
		"cancel_text": tr("ONB_CANCEL_STAY")})
	# Staying is the answer offered: the amber button, last in the row and holding the focus; leaving is the outline.
	var stay: Button = _confirm.get_node("%CancelBtn")
	stay.theme_type_variation = &"PrimaryButtonDark"
	stay.get_parent().move_child(stay, -1)
	_confirm.get_node("%ConfirmBtn").theme_type_variation = &""
	_confirm.get_node("%Panel").custom_minimum_size.x = CANCEL_W


## The curtain is drawn before the flat stops, and the flat is gone before the run starts: the people it stood in
## the room are a static list the shell's own crowd reads.
func _commit() -> void:
	_committing = true
	%Next.disabled = true
	_step.changed.disconnect(_on_step_changed)
	draft.merge(_step.collect_payload(), true)
	show_curtain()
	await RenderingServer.frame_post_draw
	curtain_msec = Time.get_ticks_msec()
	%Stage.stop()
	await RenderingServer.frame_post_draw
	GameState.initialize_run(draft)
	completed.emit()


func show_curtain() -> void:
	var emblem := LogoEmblem.new(CURTAIN_EMBLEM)
	emblem.configure(draft.logo_style, draft.company_name)
	%EmblemSlot.add_child(emblem)
	%CurtainName.text = draft.company_name
	var d: Dictionary = GameState.get_date_dict(1)
	%CurtainWeek.text = tr("ONB_WEEK_ONE").format({"month": Fmt.month_name(d.month), "year": d.year})
	%Curtain.show()
