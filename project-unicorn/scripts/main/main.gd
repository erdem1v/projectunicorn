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
const CONFIRM_MODAL := preload("res://scenes/modals/ConfirmModal.tscn")
const ENDING_MODAL := preload("res://scenes/modals/EndingModal.tscn")
const MONTH_SUMMARY_MODAL := preload("res://scenes/modals/MonthSummaryModal.tscn")
const MEETING_SCENE := preload("res://scenes/modals/MeetingScene.tscn")
const FRANK_POPUP := preload("res://scenes/modals/FrankPopup.tscn")

var _flow: Node = null
var _shell: Node = null
var _modal: Node = null              # Mentor intro modal
var _event_modal: Node = null        # Currently-open event modal, or null
var _pitch_modal: Node = null        # Currently-open pitch dialogue modal, or null
var _settings_modal: Node = null     # Currently-open settings modal, or null
var _confirm_modal: Node = null      # Currently-open confirm modal, or null
var _ending_modal: Node = null       # Ending summary modal — mounts once, never dismissed back to gameplay
var _month_modal: Node = null        # Currently-open month summary modal, or null
var _meeting_scene: Node = null      # Currently-open MeetingScene (Spec 5), or null
var _frank_popup: Node = null        # Currently-open FrankPopup (Spec 5), or null
var _pre_dialogue_speed: int = -1    # Speed to restore when a cinematic dialogue closes
var _pre_month_speed: int = -1       # Speed to restore when the month summary closes
var _pre_confirm_speed: int = -1     # Speed to restore when the confirm closes
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

	# Debug: Shift+F4 (game_shell.gd) re-triggers onboarding from a running game.
	# Wire before the skip/smoke early-returns so it works on any debug launch.
	if OS.is_debug_build():
		EventBus.debug_onboarding_retrigger_requested.connect(_on_debug_onboarding_retrigger)

	# Dev quick-boot: --skip-onboarding (debug builds only) jumps straight to
	# GameShell with the default Self-Made + AI payload, no clicks required.
	# Configure once via Project Settings → Run → Main Run Args, which writes
	# application/run/main_args in project.godot. We check ProjectSettings as
	# well as OS.get_cmdline_args() — Godot only forwards run/main_args into
	# the cmdline when launched from the editor's F5; CLI / MCP invocations
	# read it from ProjectSettings directly. F12 hotkey still works pre-shell.
	# Endgame smoke harness (debug builds only): --endgame-smoke=<case> runs one
	# headless assertion case and quits — no shell, no modals. See
	# scripts/debug/endgame_smoke.gd for the case list and output contract.
	if OS.is_debug_build():
		var smoke_case: String = _smoke_case_requested()
		if smoke_case != "":
			EndgameSmoke.run_case(smoke_case, _debug_payload())
			return

	if OS.is_debug_build() and _skip_onboarding_requested():
		_skip_to_shell()
		return

	_mount_flow()


func _skip_onboarding_requested() -> bool:
	if "--skip-onboarding" in OS.get_cmdline_args():
		return true
	var configured: String = ProjectSettings.get_setting("application/run/main_args", "")
	return "--skip-onboarding" in configured


func _smoke_case_requested() -> String:
	# Same dual source as --skip-onboarding: cmdline for CLI runs, run/main_args
	# for editor/MCP runs (Godot only forwards main_args on editor F5).
	var sources: Array[String] = []
	for arg in OS.get_cmdline_args():
		sources.append(String(arg))
	sources.append(String(ProjectSettings.get_setting("application/run/main_args", "")))
	for src in sources:
		for token in src.split(" ", false):
			if token.begins_with("--endgame-smoke="):
				return token.trim_prefix("--endgame-smoke=")
	return ""


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
		EventBus.confirm_requested.connect(_on_confirm_requested)
		EventBus.run_ended.connect(_on_run_ended)
		EventBus.month_ended.connect(_on_month_ended)
		EventBus.meeting_scene_requested.connect(_on_meeting_scene_requested)
		EventBus.frank_popup_requested.connect(_on_frank_popup_requested)
		_event_signals_wired = true

	_modal = MENTOR_MODAL.instantiate()
	_modal.dismissed.connect(_on_modal_dismissed)
	modal_layer.add_child(_modal)


func _on_modal_dismissed() -> void:
	# Stay paused. Per Spec #1, the player's first decision is the build
	# commit, which is the action that unpauses (ProductTab calls
	# TimeManager.resume_if_paused() on successful start_build — pause'dan
	# çıkarır, koşan hızı ezmez). Manual TopBar unpause also works as an
	# escape hatch.
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


# --- Confirm modal lifecycle (genel amaçlı; ilk kullanıcı build-iptal çarpısı) ---

func _on_confirm_requested(config: Dictionary) -> void:
	if _confirm_modal != null:
		return  # one confirm at a time
	var modal_layer: CanvasLayer = _shell.get_node_or_null("ModalLayer") if _shell != null else null
	if modal_layer == null:
		push_error("[Main] GameShell/ModalLayer missing — confirm modal can't mount")
		return
	# Settings deseninin aynısı: onay açıkken pause, kapanınca eski hıza dön.
	_pre_confirm_speed = TimeManager.current_speed
	EventBus.speed_change_requested.emit(0)
	_confirm_modal = CONFIRM_MODAL.instantiate()
	var on_confirm: Callable = config.get("on_confirm", Callable())
	if on_confirm.is_valid():
		_confirm_modal.confirmed.connect(on_confirm)
	_confirm_modal.dismissed.connect(_on_confirm_dismissed)
	modal_layer.add_child(_confirm_modal)
	_confirm_modal.populate(config)   # add_child SONRASI — @onready ref'ler ancak o zaman dolu (EventModal deseni)


func _on_confirm_dismissed() -> void:
	_confirm_modal = null
	# Onay sırasında kuyruğa event girdiyse kendi pause/restore'unu yönetir.
	if not EventManager.has_pending():
		var restore: int = _pre_confirm_speed if _pre_confirm_speed >= 0 else 1
		EventBus.speed_change_requested.emit(restore)
	_pre_confirm_speed = -1


# --- Month summary modal lifecycle (Spec 3 / ENDGAME_DESIGN.md §1.1) ---

func _on_month_ended(summary_data: Dictionary) -> void:
	if _month_modal != null:
		return  # one at a time (paranoia — boundary fires once per month)
	var modal_layer: CanvasLayer = _shell.get_node_or_null("ModalLayer") if _shell != null else null
	if modal_layer == null:
		push_error("[Main] GameShell/ModalLayer missing — month summary can't mount")
		return
	# Settings/confirm pattern: pause while up, restore the exact prior speed.
	# If an event modal is ALREADY active (both fired inside the same daily
	# tick), the summary simply stacks on top in ModalLayer — dismissing it
	# reveals the event beneath, and the speed restore below defers to it via
	# has_pending(). Deliberate working behavior.
	_pre_month_speed = TimeManager.current_speed
	EventBus.speed_change_requested.emit(0)
	_month_modal = MONTH_SUMMARY_MODAL.instantiate()
	_month_modal.dismissed.connect(_on_month_dismissed)
	modal_layer.add_child(_month_modal)
	_month_modal.populate(summary_data)  # add_child SONRASI — @onready ref'ler ancak o zaman dolu


func _on_month_dismissed() -> void:
	_month_modal = null
	# Restore only if the run is still alive AND no event modal owns the pause
	# (spec §1: DEVAM ET restore convention).
	if GameState.run_active and not EventManager.has_pending():
		var restore: int = _pre_month_speed if _pre_month_speed >= 0 else 1
		EventBus.speed_change_requested.emit(restore)
	_pre_month_speed = -1


# --- Ending modal lifecycle (ENDGAME_DESIGN.md §3/§6) ---

func _on_run_ended(_ending_id: String, ending_data: Dictionary) -> void:
	# Terminal reached — mount the ending summary and never restore speed.
	# EndingsSystem already flushed the queue and paused the clock (§7.2-7.3);
	# TimeManager swallows any later unpause request while run_active is false,
	# so a still-resolving event modal (Class A acquisition accept) can finish
	# its dismiss path without racing us.
	if _ending_modal != null:
		return
	var modal_layer: CanvasLayer = _shell.get_node_or_null("ModalLayer") if _shell != null else null
	if modal_layer == null:
		push_error("[Main] GameShell/ModalLayer missing — ending modal can't mount")
		return
	_ending_modal = ENDING_MODAL.instantiate()
	modal_layer.add_child(_ending_modal)
	_ending_modal.populate(ending_data)  # add_child SONRASI — @onready ref'ler ancak o zaman dolu


# --- Cinematic dialogue shell lifecycle (Spec 5: MeetingScene / FrankPopup) ---
# For now these mount from DEBUG fixtures (game_shell Shift+F2/F3). Spec 4's PitchSystem
# will emit meeting_scene_requested with a real view state and connect its own listener to
# choice_selected/withdraw_requested; the closer below is a TEMPORARY debug driver that
# logs the fired id and dismisses. Pause/restore uses the strict gate (run alive AND no
# event pending), reused from MonthSummary/EndingModal.

func _on_meeting_scene_requested(view_state: Dictionary) -> void:
	if _meeting_scene != null:
		return
	var modal_layer: CanvasLayer = _shell.get_node_or_null("ModalLayer") if _shell != null else null
	if modal_layer == null:
		push_error("[Main] GameShell/ModalLayer missing — meeting scene can't mount")
		return
	_pre_dialogue_speed = TimeManager.current_speed
	EventBus.speed_change_requested.emit(0)
	_meeting_scene = MEETING_SCENE.instantiate()
	_meeting_scene.choice_selected.connect(_on_dialogue_choice_selected)
	_meeting_scene.withdraw_requested.connect(_on_dialogue_withdrawn)
	modal_layer.add_child(_meeting_scene)
	_meeting_scene.populate(view_state)  # add_child SONRASI — @onready ref'ler ancak o zaman dolu


func _on_frank_popup_requested(view_state: Dictionary) -> void:
	if _frank_popup != null:
		return
	var modal_layer: CanvasLayer = _shell.get_node_or_null("ModalLayer") if _shell != null else null
	if modal_layer == null:
		push_error("[Main] GameShell/ModalLayer missing — Frank popup can't mount")
		return
	_pre_dialogue_speed = TimeManager.current_speed
	EventBus.speed_change_requested.emit(0)
	_frank_popup = FRANK_POPUP.instantiate()
	_frank_popup.choice_selected.connect(_on_dialogue_choice_selected)
	_frank_popup.withdraw_requested.connect(_on_dialogue_withdrawn)
	modal_layer.add_child(_frank_popup)
	_frank_popup.populate(view_state)  # add_child SONRASI — @onready ref'ler ancak o zaman dolu


# MeetingScene / FrankPopup choice relay. A live VC meeting drives the beat machine:
# advance() writes the outcome and returns the next view_state (re-populate) or done.
# The FrankPopup debug fixtures (Spec 5) keep the print-and-close path.
func _on_dialogue_choice_selected(id: String) -> void:
	if VCPitchSystem.is_meeting_active():
		var r: Dictionary = VCPitchSystem.advance(id)
		if r.get("done", false):
			_close_dialogue_scenes()
		elif _meeting_scene != null:
			_meeting_scene.populate(r.get("view_state", {}))
		return
	print("[Debug] choice_selected: %s" % id)
	_close_dialogue_scenes()


func _on_dialogue_withdrawn() -> void:
	if VCPitchSystem.is_meeting_active():
		VCPitchSystem.withdraw()
		_close_dialogue_scenes()
		return
	print("[Debug] withdraw_requested")
	_close_dialogue_scenes()


func _close_dialogue_scenes() -> void:
	if _meeting_scene != null:
		_meeting_scene.queue_free()
		_meeting_scene = null
	if _frank_popup != null:
		_frank_popup.queue_free()
		_frank_popup = null
	# Yield to a pending event chain / a dead run (strict gate from MonthSummary/Ending).
	if GameState.run_active and not EventManager.has_pending():
		var restore: int = _pre_dialogue_speed if _pre_dialogue_speed >= 0 else 1
		EventBus.speed_change_requested.emit(restore)
	_pre_dialogue_speed = -1


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


# --- Debug: re-trigger onboarding from a running game (Shift+F4, debug only) ---
# Screenshot/mockup aid: tears down the shell + any open modals and remounts
# OnboardingFlow from step 1 — exactly as a fresh launch presents it. Independent
# of --skip-onboarding / main_args; a pure runtime action. Restart-style: the
# in-progress run is intentionally discarded (onboarding has no cancel path — the
# only exit is Confirm → initialize_run → fresh run). Roster is cleared so the
# founder you create takes effect; customer/prospect/rival/event registries are NOT
# reset (known limitation — fine for capture; a completed run may carry stale data).
func _on_debug_onboarding_retrigger() -> void:
	if not OS.is_debug_build():
		return
	if _flow != null:
		return  # onboarding already showing — nothing to re-trigger

	# Tear down the shell (frees its ModalLayer children too) and drop all modal
	# refs + speed trackers so nothing dangles into the next run.
	if _shell != null:
		_shell.queue_free()
		_shell = null
	_shell_mounted = false
	_modal = null
	_event_modal = null
	_pitch_modal = null
	_settings_modal = null
	_confirm_modal = null
	_ending_modal = null
	_month_modal = null
	_pre_event_speed = -1
	_pre_settings_speed = -1
	_pre_confirm_speed = -1
	_pre_month_speed = -1

	# Roster reset so initialize_run re-provisions mentor + a fresh founder without
	# the char_founder id-collision (add() would otherwise drop the new founder).
	CharacterRegistry.reset()

	# Pause (mirrors _ready) and remount the flow from step 1. Completion routes
	# through _on_flow_completed → _swap_to_shell_and_modal (re-entrant; event
	# signal wiring is guarded by _event_signals_wired, so no double-connects).
	EventBus.speed_change_requested.emit(0)
	_mount_flow()
