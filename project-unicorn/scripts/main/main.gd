extends Node

# Main scene root — owns the launch lifecycle:
#   1. Enforce 1280×720 minimum window (TECH_SPEC §14.1).
#   2. Pause the clock (TimeManager auto-starts at 1x in its own _ready;
#      we override it for onboarding so day/hour stay at 1/09:00).
#   3. Instance OnboardingFlow into self. GameShell is NOT instanced upfront —
#      its child components (TopBar, RightPanel) paint from GameState in
#      _ready(), so it can only mount after initialize_run completes.
#   4. On flow completed signal (or F12 debug skip): swap flow for GameShell,
#      then instance MentorIntroModal into GameShell/ModalLayer.
#   5. On modal dismissed: unpause via EventBus.speed_change_requested(1).

const ONBOARDING_FLOW := preload("res://scenes/onboarding/OnboardingFlow.tscn")
const GAME_SHELL := preload("res://scenes/main/GameShell.tscn")
const MENTOR_MODAL := preload("res://scenes/modals/MentorIntroModal.tscn")
const EVENT_MODAL := preload("res://scenes/modals/EventModal.tscn")
const PITCH_MODAL := preload("res://scenes/modals/PitchDialogueModal.tscn")
const SETTINGS_MODAL := preload("res://scenes/modals/SettingsModal.tscn")

var _flow: Node = null
var _shell: Node = null
var _modal: Node = null              # Mentor intro modal
var _event_modal: Node = null        # Currently-open event modal, or null
var _pitch_modal: Node = null        # Currently-open pitch dialogue modal, or null
var _settings_modal: Node = null     # Currently-open settings modal, or null
# Speed to restore when the settings panel closes. Tracked separately from
# _pre_event_speed because the player can open settings at any speed (incl.
# already-paused) and we must return to exactly that.
var _pre_settings_speed: int = -1
var _shell_mounted: bool = false
var _event_signals_wired: bool = false
# Speed at the moment the first event in a chain pauses the game. When the
# queue drains we restore this exact speed — 4x stays 4x, an already-paused
# game stays paused. -1 means "no event currently in progress."
var _pre_event_speed: int = -1


func _ready() -> void:
	get_window().min_size = Vector2i(1280, 720)

	# Pause before any UI loads. TimeManager's _ready ran first (autoload
	# order) and set paused=false; we override here. Sending through the
	# signal keeps TimeManager.current_speed in sync — on speed=0 it sets
	# get_tree().paused = true.
	EventBus.speed_change_requested.emit(0)

	# Dev quick-boot: --skip-onboarding (debug builds only) jumps straight to
	# GameShell with the default Self-Made + AI payload, no clicks required.
	# Configure once via Project Settings → Run → Main Run Args, which writes
	# application/run/main_args in project.godot. We check ProjectSettings as
	# well as OS.get_cmdline_args() — Godot only forwards run/main_args into
	# the cmdline when launched from the editor's F5; CLI / MCP invocations
	# read it from ProjectSettings directly. F12 hotkey still works pre-shell.
	if OS.is_debug_build() and _skip_onboarding_requested():
		_skip_to_shell()
		return

	_mount_flow()


func _skip_onboarding_requested() -> bool:
	if "--skip-onboarding" in OS.get_cmdline_args():
		return true
	var configured: String = ProjectSettings.get_setting("application/run/main_args", "")
	return "--skip-onboarding" in configured


func _mount_flow() -> void:
	_flow = ONBOARDING_FLOW.instantiate()
	_flow.completed.connect(_on_flow_completed)
	add_child(_flow)


func _on_flow_completed() -> void:
	_swap_to_shell_and_modal()


func _swap_to_shell_and_modal() -> void:
	if _flow != null:
		_flow.queue_free()
		_flow = null

	_shell = GAME_SHELL.instantiate()
	add_child(_shell)
	_shell_mounted = true

	# One frame so TopBar/RightPanel finish their initial paint from
	# GameState before the modal mounts on top.
	await get_tree().process_frame

	var modal_layer: CanvasLayer = _shell.get_node_or_null("ModalLayer")
	if modal_layer == null:
		push_error("[Main] GameShell/ModalLayer not found — mentor modal cannot mount")
		return

	# Wire event pipeline signals now that ModalLayer exists. Done once.
	if not _event_signals_wired:
		EventBus.modal_requested.connect(_on_event_modal_requested)
		EventBus.event_resolved.connect(_on_event_resolved)
		EventBus.pitch_requested.connect(_on_pitch_requested)
		EventBus.pitch_finished.connect(_on_pitch_finished)
		EventBus.settings_requested.connect(_on_settings_requested)
		_event_signals_wired = true

	_modal = MENTOR_MODAL.instantiate()
	_modal.dismissed.connect(_on_modal_dismissed)
	modal_layer.add_child(_modal)


func _on_modal_dismissed() -> void:
	# Stay paused. Per Spec #1, the player's first decision is the build
	# commit, which is the action that unpauses (ProductTab emits
	# speed_change_requested(1) on successful start_build). Manual TopBar
	# unpause also works as an escape hatch.
	_modal = null


# --- Event modal lifecycle ---

func _on_event_modal_requested(event: GameEvent) -> void:
	# Capture pre-event speed ONCE at the start of an event chain so the
	# subsequent resolve restores the exact speed the player was at. Cascading
	# events (queue chain) re-enter here with _pre_event_speed already >= 0;
	# don't overwrite — we want the speed from BEFORE the first event, not
	# the pause we just applied for the previous event in the chain.
	if _pre_event_speed < 0:
		_pre_event_speed = TimeManager.current_speed
	EventBus.speed_change_requested.emit(0)
	var modal_layer: CanvasLayer = _shell.get_node_or_null("ModalLayer") if _shell != null else null
	if modal_layer == null:
		push_error("[Main] GameShell/ModalLayer missing — event modal can't mount")
		return
	_event_modal = EVENT_MODAL.instantiate()
	modal_layer.add_child(_event_modal)
	_event_modal.populate(event)


func _on_event_resolved(_event_id: String, _choice_idx: int) -> void:
	# resolve_choice emits event_resolved BEFORE its internal _pump_queue runs,
	# so when we check has_pending() here the next queued event (if any) is
	# still in the queue. If true → don't unpause, the next modal_requested
	# will fire moments later and we'll mount a fresh modal on a still-paused
	# tree. If false → queue drained, hand control back to the player.
	if _event_modal != null:
		_event_modal.queue_free()
		_event_modal = null
	if not EventManager.has_pending():
		var restore: int = _pre_event_speed if _pre_event_speed >= 0 else 1
		_pre_event_speed = -1
		EventBus.speed_change_requested.emit(restore)


# --- Pitch dialogue modal lifecycle (Sales tab → PostShip §D) ---

func _on_pitch_requested(prospect_id: String) -> void:
	if _pitch_modal != null:
		return  # one pitch at a time
	if _pre_event_speed < 0:
		_pre_event_speed = TimeManager.current_speed
	EventBus.speed_change_requested.emit(0)
	var modal_layer: CanvasLayer = _shell.get_node_or_null("ModalLayer") if _shell != null else null
	if modal_layer == null:
		push_error("[Main] GameShell/ModalLayer missing — pitch modal can't mount")
		return
	_pitch_modal = PITCH_MODAL.instantiate()
	modal_layer.add_child(_pitch_modal)
	_pitch_modal.populate(prospect_id)


func _on_pitch_finished() -> void:
	if _pitch_modal != null:
		_pitch_modal.queue_free()
		_pitch_modal = null
	if not EventManager.has_pending():
		var restore: int = _pre_event_speed if _pre_event_speed >= 0 else 1
		_pre_event_speed = -1
		EventBus.speed_change_requested.emit(restore)


# --- Settings modal lifecycle (gear button below the left tabs) ---

func _on_settings_requested() -> void:
	if _settings_modal != null:
		return  # already open
	var modal_layer: CanvasLayer = _shell.get_node_or_null("ModalLayer") if _shell != null else null
	if modal_layer == null:
		push_error("[Main] GameShell/ModalLayer missing — settings modal can't mount")
		return
	# Pause while the panel is up (consistent with the other modals) and remember
	# the exact speed to restore on close.
	_pre_settings_speed = TimeManager.current_speed
	EventBus.speed_change_requested.emit(0)
	_settings_modal = SETTINGS_MODAL.instantiate()
	_settings_modal.dismissed.connect(_on_settings_dismissed)
	modal_layer.add_child(_settings_modal)


func _on_settings_dismissed() -> void:
	_settings_modal = null
	# Don't stomp an event/pitch that queued while settings were open — if one is
	# pending it manages its own pause/restore; otherwise return to prior speed.
	if not EventManager.has_pending():
		var restore: int = _pre_settings_speed if _pre_settings_speed >= 0 else 1
		EventBus.speed_change_requested.emit(restore)
	_pre_settings_speed = -1


# --- Debug skip (F12, debug builds only) ---

func _unhandled_input(event: InputEvent) -> void:
	if not OS.is_debug_build():
		return
	if not (event is InputEventKey):
		return
	var key_event: InputEventKey = event
	if not key_event.pressed or key_event.echo:
		return
	if key_event.keycode != KEY_F12:
		return
	if _shell_mounted:
		return  # Skip only valid before the shell mounts
	_skip_to_shell()


func _skip_to_shell() -> void:
	GameState.initialize_run(_debug_payload())
	_swap_to_shell_and_modal()


func _debug_payload() -> Dictionary:
	return {
		"origin_id": "self_made",
		"skill_alloc": {"tech": 2, "markets": 2, "charisma": 1, "politics": 1},
		"trait_positive_id": "charismatic",
		"trait_negative_id": "imposter_syndrome",
		"subgenre_id": "ai",
		"company_name": "Unicorn Inc.",
		"founder_name": "",
		"logo_style": "minimalist",
		"slogan": "",
	}
