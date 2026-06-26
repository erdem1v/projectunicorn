extends Control

# Onboarding flow controller per PROJECT_SPEC §3.1.
# Sequences six step scenes (Origin → Skill → Trait → Subgenre → Company →
# Confirm), holds the in-progress draft in memory, calls
# GameState.initialize_run on Confirm. Nothing is written to GameState or
# CharacterRegistry until Confirm.
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

const STEP_ORIGIN := preload("res://scenes/onboarding/steps/OriginStep.tscn")
const STEP_SKILL := preload("res://scenes/onboarding/steps/SkillStep.tscn")
const STEP_TRAIT := preload("res://scenes/onboarding/steps/TraitStep.tscn")
const STEP_SUBGENRE := preload("res://scenes/onboarding/steps/SubgenreStep.tscn")
const STEP_COMPANY := preload("res://scenes/onboarding/steps/CompanyStep.tscn")
const STEP_CONFIRM := preload("res://scenes/onboarding/steps/ConfirmStep.tscn")

var _steps: Array[PackedScene] = []
var _step_titles: Array[String] = [
	"Origin",
	"Beceriler",
	"Trait'ler",
	"Subgenre",
	"Şirket",
	"Onay",
]

var draft: Dictionary = {
	"origin_id": "",
	"skill_alloc": {"tech": 0, "markets": 0, "charisma": 0, "politics": 0},
	"trait_positive_id": "",
	"trait_negative_id": "",
	"subgenre_id": "",
	"company_name": "",
	"founder_name": "",
	"logo_style": "",
	"slogan": "",
}

var _current_step_index: int = 0
var _current_step_node: OnboardingStep = null
var _committing: bool = false

@onready var step_host: Control = $Layout/StepHost
@onready var title_label: Label = $Layout/Header/TitleLabel
@onready var step_indicator: Label = $Layout/Header/StepIndicator
@onready var back_btn: Button = $Layout/Footer/BackBtn
@onready var next_btn: Button = $Layout/Footer/NextBtn
@onready var loading_overlay: Control = $LoadingOverlay
@onready var loading_label: Label = $LoadingOverlay/CenterPanel/LoadingLabel


func _ready() -> void:
	_steps = [STEP_ORIGIN, STEP_SKILL, STEP_TRAIT, STEP_SUBGENRE, STEP_COMPANY, STEP_CONFIRM]
	loading_overlay.visible = false
	back_btn.pressed.connect(_on_back_pressed)
	next_btn.pressed.connect(_on_next_pressed)
	_mount_step(0)


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

	# Footer + header sync
	title_label.text = _step_titles[index]
	step_indicator.text = "%d / %d" % [index + 1, _steps.size()]
	back_btn.disabled = (index == 0)
	next_btn.text = "Başla" if index == _steps.size() - 1 else "İleri"
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
	loading_label.text = "Hazırlanıyor…"

	# Brief loading visual so the transition feels intentional — not an
	# artificial delay; it covers the GameShell instantiation jank in main.gd.
	await get_tree().create_timer(1.0).timeout

	GameState.initialize_run(draft)
	completed.emit()
