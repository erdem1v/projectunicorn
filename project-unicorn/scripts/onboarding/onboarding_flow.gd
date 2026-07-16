extends Control

# Onboarding flow controller — 3-page dark-register threshold ceremony
# (KARAKTER → KÖKEN → ŞİRKET), replacing the old 6-step cream flow. Sequences
# the step scenes, holds the in-progress draft in memory, calls
# GameState.initialize_run on the final "Kur ve Başla". Nothing is written to
# GameState or CharacterRegistry before that commit.
#
# Architecture (the pattern repeats for Quarterly Summary, VC Pitch chains,
# event-chain scenes later):
#   - One controller scene, one StepHost child container.
#   - Step scenes loaded lazily (PackedScene.instantiate) and freed when
#     leaving — only one step in the tree at a time.
#   - draft Dictionary is the single source of in-progress truth.
#   - Steps implement the OnboardingStep contract (step_base.gd) and don't
#     know about the controller or each other.
#
# Tree-pause handling:
#   - main.gd pauses the tree before instancing this scene.
#   - Root process_mode = ALWAYS (set in the .tscn) so input + buttons work
#     while paused. TimeManager stays paused; day/hour don't advance.

signal completed   # main.gd listens; frees this scene and instances GameShell

const STEP_CHARACTER := preload("res://scenes/onboarding/steps/CharacterStep.tscn")
const STEP_ORIGIN_TRAITS := preload("res://scenes/onboarding/steps/OriginTraitsStep.tscn")
const STEP_COMPANY := preload("res://scenes/onboarding/steps/CompanyStep.tscn")

# Named stepper: one CSV key per page (KARAKTER · KÖKEN · ŞİRKET).
const STEP_NAME_KEYS := ["ONB_STEP_CHARACTER", "ONB_STEP_ORIGIN", "ONB_STEP_COMPANY"]

var _steps: Array[PackedScene] = []

var draft: Dictionary = {
	"founder_name": "",
	"portrait_id": "",
	"origin_id": "",
	"trait_ids": [],
	"skill_alloc": {"tech": 0, "sales": 0, "negotiation": 0, "leadership": 0, "influence": 0},
	"company_name": "",
	"logo_style": "",
	"slogan": "",
}

var _current_step_index: int = 0
var _current_step_node: OnboardingStep = null
var _committing: bool = false
var _stepper_dots: Array[Panel] = []
var _stepper_labels: Array[Label] = []
var _step_counter: Label = null

@onready var background: Panel = $Background
@onready var step_host: Control = $Layout/StepHost
@onready var header: HBoxContainer = $Layout/Header
@onready var footer_step_label: Label = $Layout/Footer/StepLabel
@onready var back_btn: Button = $Layout/Footer/BackBtn
@onready var next_btn: Button = $Layout/Footer/NextBtn
@onready var loading_overlay: Control = $LoadingOverlay
@onready var loading_label: Label = $LoadingOverlay/CenterPanel/LoadingLabel


func _ready() -> void:
	_steps = [STEP_CHARACTER, STEP_ORIGIN_TRAITS, STEP_COMPANY]
	_apply_dark_register()
	_build_header()
	loading_overlay.visible = false
	back_btn.text = tr("ONB_BACK")
	back_btn.pressed.connect(_on_back_pressed)
	next_btn.pressed.connect(_on_next_pressed)
	_mount_step(0)


func _apply_dark_register() -> void:
	# Colors come from tokens in code, never inline in the .tscn (UiTokens law).
	var bg := StyleBoxFlat.new()
	bg.bg_color = UiTokens.DIALOGUE_BG
	background.add_theme_stylebox_override("panel", bg)
	loading_label.add_theme_color_override("font_color", UiTokens.CREAM)


func _build_header() -> void:
	# Brand mark (left) + named stepper (right). Separators are drawn hairlines,
	# not glyphs — no dash characters in player-facing chrome.
	header.add_theme_constant_override("separation", 10)
	var brand := HBoxContainer.new()
	brand.add_theme_constant_override("separation", 0)
	header.add_child(brand)
	brand.add_child(UiFactory.make_label("PROJECT ", &"ZoneLabel"))
	brand.add_child(UiFactory.make_label("UNICORN", &"ZoneLabel", UiTokens.ACCENT))

	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(spacer)

	for i in _steps.size():
		if i > 0:
			var line := Panel.new()
			line.custom_minimum_size = Vector2(18, 1)
			line.size_flags_vertical = Control.SIZE_SHRINK_CENTER
			var line_sb := StyleBoxFlat.new()
			line_sb.bg_color = UiTokens.SEPARATOR
			line.add_theme_stylebox_override("panel", line_sb)
			header.add_child(line)
		var dot := UiFactory.make_dot(UiTokens.CREAM_DIM, 6)
		header.add_child(dot)
		_stepper_dots.append(dot)
		var lbl := UiFactory.make_label(tr(STEP_NAME_KEYS[i]), &"ZoneLabel")
		header.add_child(lbl)
		_stepper_labels.append(lbl)

	_step_counter = UiFactory.make_label("", &"DialogueNumber")
	header.add_child(_step_counter)


func _refresh_stepper(index: int) -> void:
	for i in _stepper_labels.size():
		var active: bool = (i == index)
		var reached: bool = (i <= index)
		_stepper_labels[i].add_theme_color_override("font_color",
			UiTokens.ACCENT if active else (UiTokens.CREAM if reached else UiTokens.CREAM_DIM))
		# make_dot styles via an override stylebox — recolor in place.
		var sb := StyleBoxFlat.new()
		sb.bg_color = UiTokens.ACCENT if reached else UiTokens.CREAM_DIM
		sb.set_corner_radius_all(4)
		_stepper_dots[i].add_theme_stylebox_override("panel", sb)
	_step_counter.text = "%d / %d" % [index + 1, _steps.size()]


# --- Step lifecycle ---

func _mount_step(index: int) -> void:
	if index < 0 or index >= _steps.size():
		return

	# Tear down current
	if _current_step_node != null:
		if _current_step_node.validity_changed.is_connected(_on_step_validity_changed):
			_current_step_node.validity_changed.disconnect(_on_step_validity_changed)
		_current_step_node.queue_free()
		_current_step_node = null

	_current_step_index = index

	# Instantiate new
	var instance: Node = _steps[index].instantiate()
	if not (instance is OnboardingStep):
		push_error("[OnboardingFlow] Step %d does not extend OnboardingStep" % index)
		instance.queue_free()
		return
	_current_step_node = instance as OnboardingStep
	step_host.add_child(_current_step_node)
	_current_step_node.prefill(draft)
	_current_step_node.validity_changed.connect(_on_step_validity_changed)

	# Header + footer sync
	_refresh_stepper(index)
	footer_step_label.text = tr("ONB_STEP_COUNTER") % [index + 1, _steps.size()]
	back_btn.disabled = (index == 0)
	next_btn.text = tr("ONB_START") if index == _steps.size() - 1 else tr("ONB_NEXT")
	_refresh_next_enabled()


func _refresh_next_enabled() -> void:
	if _current_step_node == null:
		next_btn.disabled = true
		return
	next_btn.disabled = not _current_step_node.is_valid()


# --- Signal handlers ---

func _on_step_validity_changed(_is_valid: bool) -> void:
	_refresh_next_enabled()


func _on_back_pressed() -> void:
	if _committing:
		return
	# Capture any partial selections before leaving so they reappear on Forward.
	if _current_step_node != null:
		var partial: Dictionary = _current_step_node.collect_payload()
		_merge_into_draft(partial)
	if _current_step_index > 0:
		_mount_step(_current_step_index - 1)


func _on_next_pressed() -> void:
	if _committing or _current_step_node == null:
		return
	if not _current_step_node.is_valid():
		return
	var payload: Dictionary = _current_step_node.collect_payload()
	_merge_into_draft(payload)
	if _current_step_index < _steps.size() - 1:
		_mount_step(_current_step_index + 1)
	else:
		_commit()


# --- Draft merge ---

func _merge_into_draft(payload: Dictionary) -> void:
	for k in payload.keys():
		draft[k] = payload[k]


# --- Commit (final state-write) ---

func _commit() -> void:
	_committing = true
	back_btn.disabled = true
	next_btn.disabled = true
	loading_overlay.visible = true
	loading_label.text = tr("ONB_PREPARING")

	# Brief loading visual so the transition feels intentional — not an
	# artificial delay; it covers the GameShell instantiation jank in main.gd.
	await get_tree().create_timer(1.0).timeout

	GameState.initialize_run(draft)
	completed.emit()
