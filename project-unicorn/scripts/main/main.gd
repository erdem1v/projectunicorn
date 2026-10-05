extends Node

# Main scene root — owns the launch lifecycle:
#   1. Pause the clock (TimeManager auto-starts at 1x in its own _ready) so onboarding keeps
#      day/hour at 1/08:00.
#   2. Mount OnboardingFlow. GameShell is NOT mounted upfront: its children paint from
#      GameState in _ready(), so it can only mount after initialize_run.
#   3. On flow completed (or F12 debug skip): swap the flow for GameShell and open the inbox on
#      the run's first message.
# It also owns the decision gate (a card on screen holds the clock in the inbox), routes every
# modal / cinematic surface and dispatches the debug launch flags.

const ONBOARDING_FLOW := preload("res://scenes/onboarding/OnboardingFlow.tscn")
const LANGUAGE_GATE := preload("res://scenes/onboarding/LanguageGate.tscn")
const GAME_SHELL := preload("res://scenes/main/GameShell.tscn")
const INBOX := preload("res://scripts/ui/components/inbox.gd")
const MAIL_PANE := preload("res://scripts/tabs/events/mail_pane.gd")
const SETTINGS_MODAL := preload("res://scenes/modals/SettingsModal.tscn")
const CONFIRM_MODAL := preload("res://scenes/modals/ConfirmModal.tscn")
# İK eylem modalı AYNI host'u kullanıyor (`confirm_requested`); config'deki
# `"modal": "hr_action"` yalnız SAHNEYİ seçiyor.
const HR_ACTION_MODAL := preload("res://scenes/modals/HRActionModal.tscn")
const ENDING_MODAL := preload("res://scenes/modals/EndingScene.tscn")
const TERM_TABLE_SCENE := preload("res://scenes/modals/TermSheetTableScene.tscn")
const SYSTEM_MENU_MODAL := preload("res://scenes/modals/SystemMenuModal.tscn")
const SAVE_LOAD_MODAL := preload("res://scenes/modals/SaveLoadModal.tscn")
const SAVED_GLYPH := preload("res://assets/icons/util/check.svg")
const NOT_SAVED_GLYPH := preload("res://assets/icons/util/save.svg")
const LOADED_GLYPH := preload("res://assets/icons/util/load.svg")
const MILESTONE_CLOCK_HOLD := "milestone_paper"   # TimeManager hold reason while the paper is up
const EVENT_CLOCK_HOLD := "event"                 # TimeManager hold reason while a decision waits
const TRAVEL_FREEZE := "travel"                   # TimeManager freeze reason for the founder's trip

var _flow: Node = null
var _shell: Node = null
var _shell_mounted: bool = false
var _event_signals_wired: bool = false
# Currently-open surfaces (null = closed). Each pausing surface remembers the speed it
# found (-1 = none) and hands it back on close.
var _settings_modal: Node = null
var _confirm_modal: Node = null
var _ending_modal: Node = null       # mounts once, never dismissed back to gameplay
var _milestone_modal: Node = null    # the same paper in milestone mode (EA / full)
var _meeting_panel: MeetingPanel = null   # a VC or a sales sitting
var _term_table: Node = null
var _system_menu: Node = null
var _save_load_modal: Node = null
# Speed from BEFORE the first event of a chain: cascading events re-enter the handler with
# the clock already paused by the previous card, so only the first capture counts.
var _pre_event_speed: int = -1
var _pre_settings_speed: int = -1
var _pre_confirm_speed: int = -1
var _pre_system_speed: int = -1
# The intro or the period summary opened itself in the inbox and paused the game; closing the
# inbox hands this speed back.
var _pre_note_speed: int = -1
var _pre_dialogue_speed: int = -1
var _pre_milestone_speed: int = -1
# The founder's trip to an outside meeting: set before the trip's first await, so the event
# restore and the sitting guards see it; a card that arrives during it waits for the sitting.
var _in_transit: bool = false
var _card_waiting := false
# A card's goto_tab ([tab, subpage]) waits for the decision gate to close; so does the milestone
# paper, whose [id, data] stays here from the milestone to DEVAM ET so a decision can set it aside.
var _goto_after_gate: Array = []
var _milestone_paper: Array = []
var _call := {}                    # the call ringing in the office: {kind: "vc" | "sales", id}
var _trip_label := ""              # the tower's chip on the map, both ways of a meeting's trip
var _travel_on: bool = true          # shots stage their surfaces without the trip
var _audit_spec := ""                # --theme-audit: the staged surface prints its audit, no frame

var _tempo_last_msec: int = 0   # --tempo-probe: real-clock stamp of the previous 08:00

const _ERP_SHIPPED_LINES := [
	["line_erp_ledger", 2, "line_erp_ledger_k2", 1.06],
	["line_erp_stock", 1, "line_erp_stock_k1", 1.00],
	["line_erp_invoicing", 1, "line_erp_invoicing_k1", 0.75],
]


func _ready() -> void:
	get_window().min_size = Vector2i(1280, 720)
	# TimeManager's _ready ran first (autoload order) and started the clock. Going through
	# the signal keeps TimeManager.current_speed in sync; speed 0 pauses the tree.
	EventBus.speed_change_requested.emit(0)

	if OS.is_debug_build():
		# Both themes are generated from UiTokens by hand; a forgotten regen is caught only here.
		# An unstamped .tres reads 0 and warns too.
		for th: Theme in [ThemeDB.get_project_theme(), load(UiTokens.MENAJER_THEME)]:
			var baked_stamp: int = th.get_constant(&"stamp", &"UiTokensStamp")
			if baked_stamp != UiTokens.THEME_STAMP:
				push_warning("[Theme] %s BAYAT: gömülü damga %d != UiTokens.THEME_STAMP %d — regen: godot --headless --path . -s res://scripts/theme/build_theme.gd" % [th.resource_path.get_file(), baked_stamp, UiTokens.THEME_STAMP])
		# Shift+F4 (game_shell.gd) re-triggers onboarding from a running game.
		EventBus.debug_onboarding_retrigger_requested.connect(_on_debug_onboarding_retrigger)
		if _run_debug_harness():
			return
		if "--skip-onboarding" in _run_args():
			_skip_to_shell()
			return

	# First boot picks a language before anything else builds, so the whole onboarding is
	# constructed once in the chosen locale. --force-language-gate re-opens it for testing
	# without clearing the stored preference (the gate simply writes it again).
	if Localization.is_first_boot() or (OS.is_debug_build() and "--force-language-gate" in _run_args()):
		_mount_language_gate()
		return
	_mount_flow()


func _mount_language_gate() -> void:
	var gate: Control = LANGUAGE_GATE.instantiate()
	gate.chosen.connect(func(_locale: String) -> void:
		gate.queue_free()
		_mount_flow())
	add_child(gate)


func _mount_flow() -> void:
	_flow = ONBOARDING_FLOW.instantiate()
	_flow.completed.connect(_swap_to_shell_and_modal)
	add_child(_flow)


# ============================================================================
#  DEBUG LAUNCH FLAGS (debug builds only; the list lives in CLAUDE.md, "Kapılar ve araçlar")
# ============================================================================

## Launch flags come from two sources: the command line (CLI runs) and
## application/run/main_args, which Godot forwards only on an editor F5 — the MCP
## editor-run path reads it from ProjectSettings.
func _run_args() -> PackedStringArray:
	var args: PackedStringArray = OS.get_cmdline_args()
	args.append_array(String(ProjectSettings.get_setting("application/run/main_args", "")).split(" ", false))
	return args


## Value of the first `--flag=value` among `args` (the command line by default), "" when absent.
func _flag_value(prefix: String, args: PackedStringArray = OS.get_cmdline_args()) -> String:
	for arg in args:
		if String(arg).begins_with(prefix):
			return String(arg).trim_prefix(prefix)
	return ""


func _quit_with(ok: bool) -> void:
	get_tree().quit(0 if ok else 1)


## Each harness owns the boot and ends the process itself. Returns true when one took over.
func _run_debug_harness() -> bool:
	var smoke_case: String = _flag_value("--endgame-smoke=", _run_args())
	if smoke_case != "":
		EndgameSmoke.run_case(smoke_case, _debug_payload())
		# CLI runs quit so stdout flushes; the MCP editor-run path (arg via main_args, not the
		# command line) stays alive so it can read the live log.
		if _flag_value("--endgame-smoke=") != "":
			get_tree().quit()
		return true

	# --run-log=<preset>:<weeks>:<mode>[:<seed>]. "sim" finishes inside run(); the real-clock
	# modes have only armed their handlers and must stay alive to tick.
	var run_log: String = _flag_value("--run-log=", _run_args())
	if run_log != "":
		RunProbe.run(run_log, _debug_payload())
		var rl_parts: PackedStringArray = run_log.split(":")
		if not run_log.contains(":") or (rl_parts.size() > 2 and rl_parts[2] == "sim"):
			get_tree().quit()
		return true

	var cmdline: PackedStringArray = OS.get_cmdline_args()
	var bare: Dictionary = {
		"--event-probe": func() -> void: _quit_with(EvProbe.run()),
		"--event-lint": func() -> void: _quit_with(EvLint.run(false)),
		"--event-vocab": func() -> void: _quit_with(EvVocabGen.run()),
		# Bare form measures the HR ledger: the densest text surface, the worst case for glyphs.
		"--render-probe": _run_render_probe.bind("hr"),
		"--sales-shot": _run_sales_shot.bind("pipeline"),
		"--probe-shot": _run_probe_shot.bind(""),
		"--display-check": _run_display_check,
		"--theme-contrast-audit": func() -> void: _quit_with(load("res://scripts/theme/theme_check.gd").contrast_audit(load(UiTokens.MENAJER_THEME), UiTokens)),
	}
	for flag in bare:
		if flag in cmdline:
			(bare[flag] as Callable).call()
			return true

	var valued: Dictionary = {
		"--event-lint=": func(v: String) -> void: _quit_with(EvLint.run(v == "baseline")),
		"--why-fire=": _run_why_fire,
		"--event-harness=": func(v: String) -> void: _quit_with(EvHarness.run(v)),
		"--tempo-probe=": _run_tempo_probe,
		"--render-probe=": _run_render_probe,
		"--b2b-shot=": _run_b2b_shot,
		"--event-shot=": _run_event_shot,
		"--inbox-shot=": _run_inbox_shot,
		"--meeting-shot=": _run_meeting_shot,
		"--vc-shot=": _run_vc_shot,
		"--negotiation-shot=": _run_negotiation_shot,
		"--sales-shot=": _run_sales_shot,
		"--product-shot=": _run_product_shot,
		"--ending-shot=": _run_ending_shot,
		"--hr-shot=": _run_hr_shot,
		"--finance-shot=": _run_finance_shot,
		"--tab-shot=": _run_tab_shot,
		"--personal-shot=": _run_personal_shot,
		"--rnd-shot=": _run_rnd_shot,
		"--modal-shot=": _run_modal_shot,
		"--onboard-shot=": func(v: String) -> void: _run_onboard_shot(int(v)),
		"--theme-audit=": _run_theme_audit,
		"--probe-shot=": _run_probe_shot,
		"--office-shot=": _run_office_shot,
		"--travel-shot=": _run_travel_shot,
		"--invite-shot=": _run_invite_shot,
		"--day-shot=": _run_day_shot,
		"--office-crowd-probe=": _run_office_crowd_probe,
	}
	for prefix in valued:
		var value: String = _flag_value(prefix, cmdline)
		if value != "":
			(valued[prefix] as Callable).call(value)
			return true
	return false


## --why-fire=<card id>: the gate step that refused the card, the live seam values behind the
## refusal, its latch state and whether the signal it waits on was ever emitted.
func _run_why_fire(card_id: String) -> void:
	print(EvWhy.report(card_id))
	get_tree().quit(0)


func _debug_payload() -> Dictionary:
	# skill_alloc sums to FounderConstants.POINT_POOL (6).
	return {
		"origin_id": "self_made",
		"portrait_id": "founder_01",
		"skill_alloc": {"product": 1, "design": 0, "engineering": 2, "qa": 0, "sales": 2, "customer_success": 0, "leadership": 0, "charisma": 1},
		"trait_ids": ["visionary", "stubborn"],
		"company_name": "Unicorn Inc.",
		"founder_name": "",
		"logo_style": "minimalist",
		"slogan": "",
	}


# --display-check (windowed) applies every display setting through the REAL DisplaySettings
# seam and prints what DisplayServer reports back, then quits. The screenshot harnesses own the
# window, so DisplaySettings.is_inert() switches itself off for them; this flag is deliberately
# spelled to match none of SaveManager._is_harness_arg's substrings, which the inert guard also
# uses. Asserting against DisplayServer is the point: "the window is 1600×900", not "we wrote
# 1600×900 somewhere".
func _run_display_check() -> void:
	print("DISPLAY_CHECK_BEGIN")
	print("inert=%s (must be false or nothing below is applied)" % str(DisplaySettings.is_inert()))
	print("SCREENS|count=%d|current=%d" % [
		DisplayServer.get_screen_count(), DisplayServer.window_get_current_screen()])
	print("NATIVE|%s|usable=%s|default=%s" % [
		str(DisplaySettings.native_resolution()), str(DisplaySettings.usable_size()),
		str(DisplaySettings.default_resolution())])
	var res_list: Array[Vector2i] = DisplaySettings.available_resolutions()
	var res_strs: PackedStringArray = []
	for r in res_list:
		res_strs.append("%dx%d" % [r.x, r.y])
	print("RESLIST|%d|%s" % [res_list.size(), ", ".join(res_strs)])
	print("RESLIST_HAS_NATIVE|%s" % str(res_list.has(DisplaySettings.native_resolution())))
	print("EFFECTIVE|mode=%s|shown_in_settings=%s" % [
		DisplaySettings.get_window_mode(), str(DisplaySettings.effective_resolution())])

	# The PERSISTING setters, so snapshot and restore the player's settings.json. The apply_*()
	# appliers would pass silently: apply_resolution gates on the STORED mode.
	var prev_mode: String = DisplaySettings.get_window_mode()
	var prev_res: Vector2i = DisplaySettings.get_resolution()
	var prev_vsync: bool = DisplaySettings.get_vsync()

	for mode_id in [DisplaySettings.MODE_FULLSCREEN, DisplaySettings.MODE_BORDERLESS,
			DisplaySettings.MODE_WINDOWED]:
		DisplaySettings.set_window_mode(mode_id)
		await get_tree().process_frame
		await get_tree().create_timer(0.25).timeout
		print("MODE|%s|reported=%d|borderless_flag=%s|size=%s|res_row_editable=%s" % [
			mode_id, DisplayServer.window_get_mode(),
			str(DisplayServer.window_get_flag(DisplayServer.WINDOW_FLAG_BORDERLESS)),
			str(DisplayServer.window_get_size()),
			str(DisplaySettings.is_resolution_editable())])

	# Resolution only means anything in windowed mode, which the loop above left us in.
	for res in [Vector2i(1600, 900), Vector2i(1280, 720), Vector2i(1920, 1080)]:
		DisplaySettings.set_resolution(res)
		await get_tree().process_frame
		await get_tree().create_timer(0.25).timeout
		print("RES|requested=%s|actual=%s" % [str(res), str(DisplayServer.window_get_size())])

	for on in [false, true]:
		DisplaySettings.set_vsync(on)
		await get_tree().process_frame
		print("VSYNC|requested=%s|reported=%d" % [str(on), DisplayServer.window_get_vsync_mode()])

	for step in DisplaySettings.UI_SCALE_STEPS:
		print("SCALE|%d%%|allowed=%s|clamped=%d%%" % [
			int(round(step * 100.0)), str(DisplaySettings.is_step_allowed(step)),
			int(round(DisplaySettings.clamp_step(step) * 100.0))])

	DisplaySettings.set_window_mode(prev_mode)
	DisplaySettings.set_resolution(prev_res)
	DisplaySettings.set_vsync(prev_vsync)
	print("restored mode=%s res=%s vsync=%s" % [prev_mode, str(prev_res), str(prev_vsync)])
	print("DISPLAY_CHECK_END")
	get_tree().quit()


const RENDER_PROBE_WARMUP := 45
const RENDER_PROBE_FRAMES := 180
const RENDER_PROBE_REBUILDS := 12


# --render-probe[=<tab id>[:<people>[:<speed>]]] mounts the real shell and prints FRAME COST and
# TEXTURE/VIDEO MEMORY, then quits — the number a screenshot cannot give. <people> fills the roster
# up to that many; <speed> runs the clock at that speed key while it measures, for at least three game
# hours so the hourly ticks land in the sample. A page with rebuild_view also prints the frames that
# rebuild it whole (a structure change). VSYNC IS FORCED OFF or every frame would measure the
# monitor's refresh rate; safe because SaveManager._is_harness_arg knows this flag, so the player's
# stored vsync is never touched.
func _run_render_probe(spec: String) -> void:
	var parts: PackedStringArray = spec.split(":")
	_begin_shot()
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	_seed_theme_surface()
	if parts.size() > 1:
		OfficeCrowdProbe.seed_staff(maxi(0, int(parts[1]) - CharacterRegistry.count_employees()))
	await _mount_shot_shell()
	EventBus.tab_changed.emit(parts[0])
	await get_tree().create_timer(0.4).timeout

	# The first frames pay shader compilation and texture upload — with mipmaps the upload is
	# the very thing under test, so averaging them in would misprice the steady state.
	for _i in RENDER_PROBE_WARMUP:
		await get_tree().process_frame

	var page: Node = _shell.find_child("CenterViewport", true, false).get_current_page_body()
	var rebuild_ms: Array = []
	if page != null and page.has_method(&"rebuild_view"):
		for _i in RENDER_PROBE_REBUILDS:
			var t0: int = Time.get_ticks_usec()
			page.rebuild_view()
			await get_tree().process_frame
			rebuild_ms.append(float(Time.get_ticks_usec() - t0) / 1000.0)
		rebuild_ms.sort()

	var speed: int = int(parts[2]) if parts.size() > 2 else 0
	var hour0: int = GameState.current_hour
	if speed > 0:
		EventBus.speed_change_requested.emit(speed)
	var sorted_ms: Array = []
	var until: int = Time.get_ticks_msec() + int(TimeModel.SECONDS_PER_HOUR[speed] * 3000.0)
	while sorted_ms.size() < RENDER_PROBE_FRAMES or Time.get_ticks_msec() < until:
		var t0: int = Time.get_ticks_usec()
		await get_tree().process_frame
		sorted_ms.append(float(Time.get_ticks_usec() - t0) / 1000.0)
	sorted_ms.sort()
	var total: float = 0.0
	for v in sorted_ms:
		total += float(v)
	var win: Vector2i = get_window().size

	print("RENDER_PROBE_BEGIN")
	print("LOAD|tab=%s|people=%d|speed=%d|game_hours=%d" % [parts[0], CharacterRegistry.count_employees(), speed,
		GameState.current_hour - hour0])
	if not rebuild_ms.is_empty():
		print("REBUILD_MS|median=%.3f|max=%.3f|n=%d" % [float(rebuild_ms[int(rebuild_ms.size() * 0.5)]),
			float(rebuild_ms[-1]), rebuild_ms.size()])
	# The logical viewport is where content_scale_factor (a REQUEST) can be seen to have landed.
	var vis: Vector2 = get_viewport().get_visible_rect().size
	print("WINDOW|%dx%d|scale=%.3f|viewport=%dx%d|vsync=off" % [
		win.x, win.y, get_window().content_scale_factor, int(vis.x), int(vis.y)])
	print("FRAME_MS|avg=%.3f|median=%.3f|p95=%.3f|min=%.3f|max=%.3f|n=%d" % [
		total / float(sorted_ms.size()),
		float(sorted_ms[int(sorted_ms.size() * 0.50)]),
		float(sorted_ms[int(sorted_ms.size() * 0.95)]),
		float(sorted_ms[0]), float(sorted_ms[sorted_ms.size() - 1]), sorted_ms.size()])
	print("MEM|texture_mib=%.2f|video_mib=%.2f" % [
		Performance.get_monitor(Performance.RENDER_TEXTURE_MEM_USED) / 1048576.0,
		Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED) / 1048576.0])
	print("DRAW|calls=%d|objects=%d" % [
		int(Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)),
		int(Performance.get_monitor(Performance.OBJECT_NODE_COUNT))])
	print("RENDER_PROBE_END")
	get_tree().quit()


const TEMPO_STOP_DAY := 3


# --tempo-probe=<speed idx>[:shell] runs the REAL clock and prints one line per week, 08:00 to
# 08:00 (the night skip lands there), with its deviation from TimeModel's target; the smoke
# drives ticks directly and cannot measure it. Headless it times the clock alone; `:shell`
# (windowed) mounts the shell, so the office's walk-out gate is in the cost. The STATE line must
# be identical across speeds for the same seed (tick purity).
func _run_tempo_probe(spec: String) -> void:
	var parts: PackedStringArray = spec.split(":")
	var idx: int = int(parts[0])
	if idx <= 0 or idx >= TimeModel.SECONDS_PER_HOUR.size():
		print("TEMPO ERROR bad speed index %d" % idx)
		get_tree().quit()
		return
	_seed_run_reproducible()
	# Give the HOURLY path real work (B2C audience flow, post-ship wear and bug accrual) and the
	# daily path a sprint, because that is where a speed-coupled bug would surface. mvp_shipped is
	# load-bearing: SalesSystem.hourly_tick gates the whole B2C half on it and ProductSystem
	# gates post-ship wear on it. Real bools, not strings: event conditions compare via bool().
	GameState.set_cash(50000)
	SprintSystem.choose_type("note_tool", "Nova")
	GameState.set_flag("mvp_shipped", true)
	GameState.set_flag("mvp_innovation", 20.0)
	GameState.set_flag("mvp_stability", 25.0)
	GameState.set_flag("mvp_experience", 22.0)
	GameState.set_flag("mvp_version", 2)
	GameState.set_flag("b2c_audience", 4000)
	SalesSystem.open_b2c_paid_tier(15)   # makes MRR derive hourly too
	# The sprint stays in planning: the first tick starts it with the lead's plan and it closes after
	# the stop day, so no release note holds the clock under `:shell`.
	if parts.size() > 1 and parts[1] == "shell":
		_begin_shot()
		await _mount_shot_shell()
	var want_ms: int = int(TimeModel.seconds_per_tick(idx) * 1000.0)
	print("TEMPO START speed=%d want_ms=%d" % [idx, want_ms])
	EventBus.night_skipped.connect(func() -> void:
		var now: int = Time.get_ticks_msec()
		var delta_ms: int = now - _tempo_last_msec
		print("TEMPO speed=%d day=%d delta_ms=%d want_ms=%d dev=%+.1f%%" % [idx, GameState.day,
			delta_ms, want_ms, 100.0 * (delta_ms - want_ms) / want_ms])
		_tempo_last_msec = now
		print("TEMPO STATE day=%d cash=%d mrr=%d brand=%d rep=%d aud=%.4f sprint=%d mode=%s done=%d" % [
			GameState.day, GameState.cash, GameState.mrr, GameState.brand, GameState.reputation,
			float(GameState.get_flag("b2c_audience", 0.0)), SprintSystem.sprint_number(), SprintSystem.mode(),
			SprintSystem.done_points()])
		if GameState.day >= TEMPO_STOP_DAY:
			print("TEMPO DONE speed=%d" % idx)
			get_tree().quit()
	)
	_tempo_last_msec = Time.get_ticks_msec()
	EventBus.speed_change_requested.emit(idx)


# ============================================================================
#  SCREENSHOT HARNESSES (windowed, 1920×1080 unless --shot-size; PNGs to user://)
# ============================================================================

## Common opening of every shot. The window drops to windowed mode first: the default mode is
## borderless, where a size assignment is silently swallowed. Headless makes all of it a no-op.
## A shot mounts its sitting at once, without the founder's trip.
func _begin_shot() -> void:
	_travel_on = false
	get_tree().paused = false
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	var win_size: Vector2i = _shot_size_override(Vector2i(1920, 1080))
	get_window().size = win_size
	# --palette=cb draws the colour-blind palette for this run only; the setting is not written.
	if _flag_value("--palette=") == "cb":
		UiTokens.set_colorblind(true)
	# --shot-scale runs the REAL gate (clamp_step): an illegal scale is clipped up just as the
	# game would. Applied a moment later on purpose: the resize takes effect only next frame,
	# and writing content_scale_factor now would scale against the OLD size and crop the view.
	# Every runner waits ≥0.35s before capturing.
	var step: float = _flag_value("--shot-scale=").to_float()
	if step > 0.0:
		var legal: float = DisplaySettings.clamp_step(step, win_size)
		get_tree().create_timer(0.15).timeout.connect(
			func() -> void: get_window().content_scale_factor = legal)
		print("[Shot] pencere %dx%d · ölçek istendi %d%% → uygulandı %d%%" % [
			win_size.x, win_size.y, int(round(step * 100.0)), int(round(legal * 100.0))])


## --shot-size=2560x1440 overrides the shot window.
func _shot_size_override(fallback: Vector2i) -> Vector2i:
	var raw: String = _flag_value("--shot-size=")
	if raw == "":
		return fallback
	var parts: PackedStringArray = raw.split("x")
	if parts.size() == 2 and parts[0].is_valid_int() and parts[1].is_valid_int():
		return Vector2i(int(parts[0]), int(parts[1]))
	push_warning("[Shot] --shot-size bozuk (beklenen GENIŞLIKxYÜKSEKLIK): %s" % raw)
	return fallback


## initialize_run seeds from Time.get_ticks_msec(), which differs per launch; a pinned seed is
## what lets a before/after screenshot pair isolate the change under test.
func _seed_run_reproducible() -> void:
	GameState.initialize_run(_debug_payload())
	GameState.run_seed = 424242
	seed(GameState.run_seed)


func _mount_shot_shell() -> void:
	_shell = GAME_SHELL.instantiate()
	add_child(_shell)
	_shell_mounted = true
	await get_tree().process_frame
	await get_tree().process_frame


## Mounts a standalone surface on its own CanvasLayer (no shell behind it).
func _on_shot_layer(node: Node) -> Node:
	var layer := CanvasLayer.new()
	add_child(layer)
	layer.add_child(node)
	return node


## The file name carries the language: TR keeps the bare name, EN gets `_en`, so both frames
## of one screen sit side by side. Read from the locale itself, however it got set; `_cb` marks
## the colour-blind palette of --palette=cb.
func _shot_path(basename: String) -> String:
	return "user://%s%s%s.png" % [basename, "_en" if Fmt.is_english() else "",
		"_cb" if _flag_value("--palette=") == "cb" else ""]


func _save_shot(basename: String) -> void:
	var path: String = _shot_path(basename)
	get_viewport().get_texture().get_image().save_png(path)
	print("[Shot] saved %s" % ProjectSettings.globalize_path(path))


func _finish_shot(basename: String, settle: float = 0.4) -> void:
	await get_tree().process_frame
	await get_tree().create_timer(settle).timeout
	if _audit_spec == "":
		_save_shot(basename)
	else:
		print("AUDIT_BEGIN %s" % _audit_spec)
		_audit_walk(_shell if _shell != null else self, "")
		print("AUDIT_END %s" % _audit_spec)
	get_tree().quit()


func _shot_fail(msg: String) -> void:
	push_error(msg)
	get_tree().quit(1)


## --b2b-shot=<retention|retention_capped|escalation|expansion|deal|angel>: one
## factory-built card in the inbox's reading pane.
func _run_b2b_shot(kind: String) -> void:
	_begin_shot()
	_seed_run_reproducible()
	GameState.set_flag("mvp_shipped", true)
	GameState.set_flag("mvp_market_type", "b2b")
	GameState.set_flag("mvp_sub_product_type_id", "ai_vector_search")
	var p := Prospect.new()
	p.id = "shot"
	p.company_name = "Ege Sigorta"
	p.industry = "insurance"
	p.star = 1
	p.pain_feature_id = "ai_vec_filter"
	var c: Customer = SalesSystem.add_b2b_customer(p, 20, 50, 70)   # 20 seats x $50 = $1.000
	var card_id: String = "customer.retention"
	var scoped: bool = true
	match kind:
		"escalation":
			var cs := Character.new()
			cs.id = "char_cs_shot"
			cs.character_name = "Burcu Çetin"   # LOC-DATA debug seed / id
			cs.role = HRConstants.ROLE_CUSTOMER_REP
			cs.category = "employee"
			cs.monthly_salary = 5000
			# Müşteri Başarısı 5: bu masanın okuduğu tek sayı (rev 2 §2).
			cs.role_stats = HRConstants.seed_skills(HRConstants.ROLE_CUSTOMER_REP, 5, 4)
			cs.traits = ["picks_it_up_fast"]
			CharacterRegistry.add(cs)
			CustomerRegistry.assign_customer(c.id, cs.id)
			CustomerRegistry.set_satisfaction(c.id, 22)
			# The `escalated` selector filters on this flag, which only a tick writes.
			c.cs_escalated = true
			card_id = "customer.cs_escalation"
		"expansion":
			# can_offer_expansion wants a MATURE account that was never offered one.
			c.acquired_on_day = GameState.day - (TimeModel.ticks(B2BConstants.EXPANSION_MATURE_WEEKS) + 1)
			CustomerRegistry.set_lifecycle_phase(c.id, "active")
			CustomerRegistry.set_satisfaction(c.id, 80)
			card_id = "customer.expansion"
		"deal":
			# Frank's portrait on an event card, the MENTOR source badge and the
			# open_term_table chip of "Masaya otur" — one frame. The offer-email card is
			# unbuilt, so this renders the card on the same edge: a sheet with a deadline.
			GameState.phase = 3
			GameState.active_sheets.append(VCPitchSystem._make_sheet("anchor", GameState.day))
			card_id = "funding.sheet_expiry"
		"angel":
			# Frank's seed card: the KABUL effect chip (an undescribed modifier renders blind)
			# and the locked REDDET row's treatment only show in a rendered frame.
			card_id = "funding.frank_cheque"
			scoped = false
		_:
			CustomerRegistry.set_lifecycle_phase(c.id, "risk")
			CustomerRegistry.set_churn_countdown(c.id, TimeModel.ticks(B2BConstants.CHURN_COUNTDOWN_WEEKS))
			if kind == "retention_capped":   # LOC-DATA debug seed / id
				# Both discounts spent: the row renders locked-visible with its reason line.
				CustomerRegistry.set_retain_discounts(c.id, B2BConstants.RETAIN_DISCOUNT_MAX_USES)
	_shot_pane(card_id, EventGate.bind_scope(card_id) if scoped else {})
	await get_tree().process_frame
	await _finish_shot("b2b_shot_%s" % kind, 0.35)


## --event-shot=<card id>: any catalogued card, `version_scope: fixture` ones included, in the
## reading pane's preview (its options drawn, not taken).
func _run_event_shot(event_id: String) -> void:
	_begin_shot()
	_seed_run_reproducible()
	if not EventGate.is_catalogued(event_id):
		_shot_fail("[EventShot] no card with id: %s" % event_id)
		return
	_shot_pane(event_id, EventGate.bind_scope(event_id))
	await get_tree().process_frame
	await _finish_shot("event_shot_%s" % event_id, 0.35)


## --inbox-shot=<state>: the Olaylar inbox over the theme seed (week 14, İş hanı) in the mockups'
## states, through the real gate (main's handler holds the clock and opens the inbox on the card):
##   offer · queue · customer (an option armed) · locked · history · paper · paper_open ·
##   paper_last_week · paper_waiting · attention · resignation · departed · summary · intro ·
##   frank_moment · rnd_note (week 14's note) · rnd_discovery (week 16's, on the Ar-Ge timeline) ·
##   weekly_sales · empty · long · team_read_only (Ekip
##   read-only over a decision) · team_tasks_read_only (its Görevler) · sales_read_only (Satış read-only) ·
##   finance_read_only (Finans read-only) · personal_read_only (Kişisel read-only) ·
##   personal_cheque_read_only (Kişisel read-only after Frank's cheque, a customer's card waiting) ·
##   held_key (a speed key refused: the frame's blink and the toast)
## Cards come through force_fire; a past decision is resolved for real at an earlier week.
func _run_inbox_shot(state: String) -> void:
	_begin_shot()
	if state == "intro":
		_seed_run_reproducible()
	else:
		_seed_theme_surface()
		GameState.current_hour = 11
		TimeManager.sync_to_current_hour()
	if state.begins_with("rnd_"):
		_seed_rnd(16 if state == "rnd_discovery" else 14)
	await _mount_shot_shell()
	_wire_modal_signals()
	var selina := "char_emp_shot_3"
	match state:
		"flow":
			await _gate_flow()
			get_tree().quit()
			return
		"intro":
			_open_note("intro")
		"offer", "team_read_only", "team_tasks_read_only", "sales_read_only", "finance_read_only", "personal_read_only", \
				"held_key":
			_shot_card("funding.frank_cheque", {}, 8)
			if state in ["sales_read_only", "finance_read_only", "personal_read_only"]:
				EventBus.tab_changed.emit(state.get_slice("_", 0))
			elif state.begins_with("team_"):
				EventBus.tab_changed.emit("hr")
				if state == "team_tasks_read_only":
					await get_tree().process_frame
					var page: Node = _shell.find_child("CenterViewport", true, false).get_current_page_body()
					page._show_view(page.VIEW_ASSIGNMENTS)
			elif state == "held_key":
				EventBus.tab_changed.emit("")
				var key := InputEventKey.new()
				key.keycode = KEY_SPACE
				key.pressed = true
				_shell._input(key)
		"personal_cheque_read_only":
			AngelRoundSystem.accept_offer()
			_shot_card("customer.retention", {"customer": "co_ege"}, 8)
			EventBus.tab_changed.emit("personal")
		"queue":
			_shot_card("funding.frank_cheque", {}, 8)
			EventGate.force_fire("customer.retention", {"customer": "co_ege"})
			EventGate.force_fire("team.resignation", {"employee": selina})
			# Queued under the card on screen, which no signal tells: the inbox reads again.
			INBOX.show("active")
		"customer", "locked":
			if state == "locked":
				_shot_answered("customer.retention", {"customer": "co_ege"}, "stall", 11)
				_shot_answered("customer.retention", {"customer": "co_ege"}, "stall", 12)
			_shot_card("customer.retention", {"customer": "co_ege"}, 8)
			if state == "customer":
				await get_tree().process_frame
				get_tree().call_group(INBOX.GROUP, &"arm_for_shot", 2)
		"history":
			_shot_answered("customer.retention", {"customer": "co_ege"}, "stall", 11)
			_shot_card("customer.retention", {"customer": "co_ege"}, 8)
			INBOX.show("h:0")
		"paper", "paper_open", "paper_waiting":
			var key: String = _shot_paper("customer.expansion", {"customer": "co_nordica"}, 2)
			if state == "paper_open":
				EventGate.open_paper(key)
			elif state == "paper_waiting":
				_shot_card("funding.frank_cheque", {}, 8)
				INBOX.show("paper:" + key)
			else:
				INBOX.show("paper:" + key)
		"paper_last_week":
			GameState.day -= 1
			var key: String = _shot_paper("customer.expansion", {"customer": "co_nordica"}, 2)
			GameState.day += 1
			INBOX.show("paper:" + key)
		"attention":
			INBOX.show("r:customer:co_ege")
		"resignation":
			_shot_card("team.resignation", {"employee": selina}, 8)
		"departed":
			_shot_answered("team.resignation", {"employee": selina}, "acknowledge", 14)
			INBOX.show("h:0")
		"frank_moment":
			_shot_card("customer.frank_intro", {}, 8)
		"summary":
			GameState.current_hour = 8
			TimeManager.sync_to_current_hour()
			var payload: Dictionary = SummarySystem._build_summary_data("quarterly", GameState.day - 1)
			MessageSystem.post("summary", String(SummarySystem.PERIOD_KEYS.quarterly.title), payload)
			EventBus.summary_ready.emit(payload)
		"rnd_note", "rnd_discovery":
			INBOX.show("m:" + String(GameState.messages[-1].id))
		"weekly_sales":
			var rows := []
			for c in CustomerRegistry.get_by_market("b2b").slice(0, 2):
				rows.append({"company": c.company_name, "star": 2, "seats": c.seats, "price": c.mrr / maxi(1, c.seats),
					"mrr": c.mrr, "rep": "Burak Şahin"})   # LOC-DATA debug seed / id
			var id: String = MessageSystem.post("sales_week", "SALES_WEEKLY_TITLE",
				{"rows": rows, "accounts": CustomerRegistry.account_count()})
			INBOX.show("m:" + id)
		"empty":
			EventBus.tab_changed.emit("events")
			get_tree().call_group(INBOX.GROUP, &"filter_for_shot", 1)
		"long":
			for row in [["customer.retention", {"customer": "co_ege"}, "stall", 5],
					["team.resignation", {"employee": "char_emp_shot_1"}, "acknowledge", 7],
					["customer.retention", {"customer": "co_ege"}, "leave_alone", 11],
					["customer.retention", {"customer": "co_ege"}, "discount", 13]]:
				_shot_answered(row[0], row[1], row[2], row[3])
			INBOX.show("h:1")
			await get_tree().process_frame
			get_tree().call_group(INBOX.GROUP, &"scroll_for_shot", 236)
		_:
			_shot_fail("[InboxShot] unknown state: %s" % state)
			return
	# The staging moved the week and the hour under a top bar that paints on ticks.
	get_tree().call_group(&"top_bar", &"_refresh")
	await get_tree().process_frame
	await _finish_shot("inbox_shot_%s" % state, 0.6)


## --inbox-shot=flow: the gate played through the shell's own input, a frame and a GATEFLOW line a
## step: the clock runs; a decision arrives (the clock is held, the inbox opens on it); Ekip opens
## and reads only (a click on its first button does nothing); a speed key is refused; Esc closes
## Ekip, Esc again brings the inbox back; the decision is taken with a click; the clock runs again.
func _gate_flow() -> void:
	var mounted := [0]   # panels that reached the panel layer at all (main frees them under a gate)
	_shell.get_node("PanelLayer").child_entered_tree.connect(func(_n: Node) -> void: mounted[0] += 1)
	var step := func(n: int, what: String) -> void:
		var page: Control = get_tree().get_first_node_in_group(&"window_layer").get_current_page_body()
		print("GATEFLOW|%02d|%s|speed=%d|held=%s|active=%s|window=%s|panels_mounted=%d" % [n, what,
			TimeManager.current_speed, TimeManager.is_clock_held(), EventGate.active_id(),
			page.name if page != null else "", mounted[0]])
		await get_tree().create_timer(0.4).timeout
		_save_shot("inbox_flow_%02d" % n)
	# The pointer moves onto the button first: the hover is what a read-only window reads.
	var click := func(button: Button) -> void:
		var move := InputEventMouseMotion.new()
		move.position = button.get_global_rect().get_center()
		move.global_position = move.position
		get_viewport().push_input(move)
		for pressed in [true, false]:
			var e := InputEventMouseButton.new()
			e.button_index = MOUSE_BUTTON_LEFT
			e.pressed = pressed
			e.position = move.position
			e.global_position = e.position
			get_viewport().push_input(e)
			await get_tree().process_frame
	var key := func(code: Key) -> void:
		var e := InputEventKey.new()
		e.keycode = code
		e.pressed = true
		_shell._input(e)
		await get_tree().process_frame
	EventBus.speed_change_requested.emit(1)
	await step.call(1, "running")
	_shot_card("funding.frank_cheque", {}, GameState.current_hour)
	await step.call(2, "decision")
	EventBus.tab_changed.emit("hr")
	await get_tree().process_frame
	var hr: Control = get_tree().get_first_node_in_group(&"window_layer").get_current_page_body()
	await click.call(hr.find_children("*", "Button", true, false).filter(
		func(b: Button) -> bool: return b.text == tr("HR_SEARCH_START"))[0])
	await step.call(3, "hr_recruit_click_refused")
	await key.call(KEY_2)
	await step.call(4, "speed_key")
	await key.call(KEY_ESCAPE)
	await step.call(5, "esc_closes_hr")
	await key.call(KEY_ESCAPE)
	await step.call(6, "esc_reopens_inbox")
	# A file opened from the office over Ekip: its own way back to the decision sits on Ekip's page.
	EventBus.tab_changed.emit("hr")
	var layer: Node = get_tree().get_first_node_in_group(&"window_layer")
	layer.open_detail("hr_dossier", {"character_id": "char_emp_shot_0"})
	await get_tree().process_frame
	await click.call(layer.find_children("*", "Button", true, false).filter(
		func(b: Button) -> bool: return b.text == tr("WIN_BACK_TO_DECISION") and b.is_visible_in_tree())[-1])
	await step.call(7, "dossier_back_to_decision")
	var label: String = (EventGate.active_card().choices[0] as EventChoice).label
	var take: Array = get_tree().root.find_children("*", "Button", true, false).filter(
		func(b: Button) -> bool: return b.text == label and b.is_visible_in_tree())
	await click.call(take[0])
	await step.call(8, "answered")


## A card through the real gate at `hour`: the clock stops there as at the week's start.
func _shot_card(card_id: String, given: Dictionary, hour: int) -> void:
	GameState.current_hour = hour
	TimeManager.sync_to_current_hour()
	if not EventGate.force_fire(card_id, given):
		_shot_fail("[InboxShot] %s did not fire" % card_id)


## A card answered `option` at week `day`, and the run back at its week: a history row.
func _shot_answered(card_id: String, given: Dictionary, option: String, day: int) -> void:
	var now: int = GameState.day
	GameState.day = day
	EventGate.force_fire(card_id, given)
	EvEngine._forced.clear()   # the row reads as played, which is what the inbox lists
	EventGate.resolve(card_id, option)
	GameState.day = now


## A paper on the desk for `weeks`, landed this week; its key.
func _shot_paper(card_id: String, given: Dictionary, weeks: int) -> String:
	var bound: Dictionary = EvScope.resolve(EventGate.catalogue_card(card_id).get("scope", {}), given)
	EvPapers.place(card_id, bound.context, weeks)
	return EvLatches.key_of(card_id, bound.context)


## The reading pane alone on its own layer, at the inbox's width, reading a card in preview.
func _shot_pane(card_id: String, ctx: Dictionary) -> void:
	var back := PanelContainer.new()
	back.theme = load(UiTokens.MENAJER_THEME)
	back.theme_type_variation = &"WindowPanel"
	back.position = Vector2.ONE * UiTokens.SPACE_3XL
	back.size = Vector2(840, get_window().size.y - 2 * UiTokens.SPACE_3XL)
	var pane: ScrollContainer = MAIL_PANE.new()
	back.add_child(pane)
	_on_shot_layer(back)
	pane.populate(INBOX.card_item("preview", card_id, ctx, {}, GameState.day), "preview")


## --sales-shot=<pipeline|desk|picker|inbox|edge|edge_end|stretched|empty|b2c|untyped>. `desk` puts a rep
## mid-processing on the desk; `picker` opens the steward picker on the first account, `inbox` presses its İlgilen
## (Olaylar opens on the account's mail); `edge` draws the rarer lines (a reserved lead, one given to a rep, a
## whale's condition, tables above the founder's league, the week's meetings spent, an open promise by sprint, the
## log) with three calm accounts, `edge_end` the same with both columns scrolled to their ends; `stretched` the
## founder holding one account more than he can, a 1★ rep and a lead in its last week; `empty` an open market with
## no lead, rep or account; `b2c` photographs §3.1's empty window in a B2C run, `untyped` before a type is picked.
func _run_sales_shot(kind: String) -> void:
	_begin_shot()
	_seed_sales_world()
	GameState.day = 14
	GameState.set_flag("mvp_live_bug_count", 12)  # risk reason → "sık kesinti şikayeti"
	var edge: bool = kind.begins_with("edge")
	match kind:
		"b2c":
			SprintSystem.choose_type("note_tool", "Notly")   # LOC-DATA debug seed / id
		"untyped":
			for flag in ["mvp_shipped", "mvp_market_type", "mvp_sub_product_type_id"]:
				GameState.flags.erase(flag)
		"empty":
			pass
		_:
			for star in [1, 2, 3]:
				SalesFaucetSystem.spawn(star, "faucet")
	if kind in ["desk", "picker", "inbox", "stretched"]:
		# A rep on the desk, mid-processing, so the band row and the working line both draw; at 1★ the band row
		# is the line that says the rep works their own league only.
		var rep := Character.new()
		rep.id = "char_sr_shot"
		rep.character_name = "Kerem Aydın"   # LOC-DATA debug seed / id
		rep.role = HRConstants.ROLE_SALES_REP
		rep.category = "employee"
		rep.level = HRConstants.LEVEL_MID
		rep.monthly_salary = 3200
		rep.morale = 62
		rep.role_stats = HRConstants.seed_skills(rep.role, 2 if kind == "stretched" else 5, 3)
		rep.traits = ["picks_it_up_fast"]
		CharacterRegistry.add(rep)
		rep.hire_day = GameState.day - 4   # add() stamps today
		CharacterRegistry.assign_job(rep.id, HRConstants.JOB_SALES)
		SalesRepSystem.daily_tick()
	if kind != "empty":
		_shot_customer("co_kuzey", "Kuzey İnşaat", "construction", "active", 1000, 12, 13, false)   # LOC-DATA debug seed / id
		_shot_customer("co_palmiye", "Palmiye Holding", "insurance", "active", 1500, 16, 21, true)
		_shot_customer("co_aras", "Aras Klinik", "health", "onboarding", 700, 6, 1, false)
	if edge:
		var leads: Array[Prospect] = ProspectRegistry.get_all()
		SalesLedger.set_routing(leads[0].id, SalesConstants.ROUTE_RESERVED)
		SalesLedger.set_routing(leads[1].id, SalesConstants.ROUTE_REP)
		leads[2].whale_condition = "sla_promise"   # LOC-DATA debug seed / id
		CharacterRegistry.get_founder().role_stats[HRConstants.AREA_SALES] = 2
		GameState.sales_meetings_week = {"tick": GameState.day, "count": SalesConstants.MEETINGS_PER_WEEK}
		# A shipped product has a type, and a typed product's promise is due by a sprint's end.
		SprintSystem.choose_type("erp", "Fatura")   # LOC-DATA debug seed / id
		PromiseRegistry.create("co_kuzey", "saas_ops_integration", 1)   # LOC-DATA debug seed / id
		SalesSystem.record_sales_event("lead_expired", "", "Efes Emlak", 0)   # LOC-DATA debug seed / id
		SalesSystem.record_sales_event("founder_close", "", "Aras Klinik", 700)   # LOC-DATA debug seed / id
	elif kind != "empty":
		_shot_customer("co_ege", "Ege Sigorta", "insurance", "risk", 1000, 12, 9, false)
		CustomerRegistry.set_churn_countdown("co_ege", TimeModel.ticks(B2BConstants.CHURN_COUNTDOWN_WEEKS))
		_shot_customer("co_nordica", "Nordica", "logistics", "expansion", 2000, 20, 26, false)
	if kind == "stretched":
		_shot_customer("co_lale", "Lale Lojistik", "logistics", "active", 800, 8, 5, false)   # LOC-DATA debug seed / id
		# The 3★ lead is above the 1★ rep's league, so it waits: three weeks on the board, one left.
		var last: Prospect = ProspectRegistry.get_all().filter(func(p: Prospect) -> bool: return p.star == 3)[0]
		last.spawned_on_day = GameState.day - TimeModel.ticks(3)
		last.expires_on_day = GameState.day + TimeModel.ticks(1)
	# Monthly strip figures: gained 1 / lost 2 / net -1.
	GameState.run_customers_signed = 5
	GameState.run_customers_lost = 2
	GameState.month_ledger = {"customers_signed": 4, "customers_lost": 0}
	SalesSystem.reflect_mrr()
	await _mount_shot_shell()
	EventBus.tab_changed.emit("sales")
	if kind in ["picker", "inbox", "edge_end"]:
		await get_tree().process_frame
		var page: Control = get_tree().get_first_node_in_group(&"window_layer").get_current_page_body()
		if kind == "edge_end":
			await get_tree().create_timer(0.3).timeout
			for scroll: ScrollContainer in page.find_children("*", "ScrollContainer", true, false):
				scroll.scroll_vertical = int(scroll.get_v_scroll_bar().max_value)
		elif not _press_button_labelled(page, tr("SALES_STEWARD_CHANGE" if kind == "picker" else "SALES_ACTION_RETAIN")):
			_shot_fail("[SalesShot] %s: the first account's button is missing" % kind)
			return
	await _finish_shot("sales_shot_%s" % kind, 0.6)


# Theme-matrix shots (--tab-shot / --modal-shot / --onboard-shot / --theme-audit) cover the
# UNSTYLED controls the theme's base-type defaults reach. They share one seed so a textual
# audit and a screenshot of the same tab verify each other.
func _seed_theme_surface() -> void:
	_seed_run_reproducible()
	GameState.day = 14
	GameState.set_flag("mvp_shipped", true)
	GameState.set_flag("mvp_launch_day", 6)
	GameState.set_flag("mvp_market_type", "b2b")
	GameState.set_flag("mvp_sub_product_type_id", "saas_ops")
	GameState.set_flag("mvp_innovation", 45.0)
	GameState.set_flag("mvp_stability", 70.0)
	GameState.set_flag("mvp_experience", 45.0)
	GameState.set_flag("mvp_live_bug_count", 12)
	_seed_hr_roster()
	_shot_customer("co_kuzey", "Kuzey İnşaat", "construction", "active", 1000, 12, 13, false)   # LOC-DATA debug seed / id
	_shot_customer("co_ege", "Ege Sigorta", "insurance", "risk", 1000, 12, 9, false)
	_shot_customer("co_nordica", "Nordica", "logistics", "expansion", 2000, 20, 26, false)
	SalesFaucetSystem.spawn_prospect("small", "find")
	SalesFaucetSystem.spawn_prospect("mid", "find")
	SalesSystem.reflect_mrr()


# --office-shot=<home|ishani|plaza|loft|city|meet>:<hour>[:<extra>]: the office in the GameShell,
# the clock stopped on the hour; prints frame time and render counts. extra: full = every desk
# taken and people in (the lit night interior); crowd40 = forty on the roster, a LOOKS line and four
# close frames; founders = the founder portraits beside their busts; nav = the baked floor and the
# spots' ways in drawn over the office; <tab id> = that tab's window open over it; hr_dossier = the
# Ekip window with its first employee's dossier on top. city opens the map from İş hanı as the move
# button does; card (city only) = Plaza picked, its office card open; crown (city only) = the
# investors' tower framed with its crown lit. meet is the meeting room with three on the other side
# and the founder seated, sitting and looking as at a meeting's start; cast (meet only) = the founder
# walks in from the lift (a frame every CAST_WALK_EVERY, _cast_NN), the table at rest (_NN_rest),
# then close up the lead speaking (_NN_speak) and each gesture at its middle (_NN_<gesture>).
func _run_office_shot(spec: String) -> void:
	var parts: PackedStringArray = spec.split(":")
	var office_id: String = parts[0]
	var hour: int = int(parts[1])
	var extra: String = parts[2] if parts.size() > 2 else ""
	_begin_shot()
	_seed_theme_surface()
	EventBus.speed_change_requested.emit(0)
	# Debug path: the shot writes the office straight past OfficeSystem. The map and the meeting
	# room are no office: the company sits in a real one, which the map's pin and chips read.
	GameState.office_id = "ishani" if office_id in OfficeLayout.AWAY else office_id
	GameState.set_current_hour(hour)
	TimeManager.sync_to_current_hour()
	if extra == "crowd40":
		# Forty on the roster with the fixture's five and the founder.
		OfficeCrowdProbe.seed_staff(34)
	await _mount_shot_shell()
	var view: Control = get_tree().get_first_node_in_group(&"office_view")
	var city: OfficeCity = view.get_node("Viewport3D/SubViewport/World/City")
	var people: OfficePeople = view.get_node("Viewport3D/SubViewport/World/People")
	if office_id == "city":
		await city.open()
	if office_id == "meet":
		_stage_meeting_room(CounterpartSystem.investor_people(SHOT_FUND), extra != "cast")
		if extra.is_empty():
			_shot_meeting_posts(view.cast)
	match extra:
		"":
			pass
		"card":
			city.debug_pick("plaza")
		"crown":
			(view.lighting as OfficeLighting).crown_glow = 1.0
			var cam: OfficeCamera = view.camera
			var tower: AABB = view.layout.meet_hit.box
			cam.focus(tower.get_center() + Vector3.UP * tower.size.y * 0.2, cam.fit_zoom * 2.2, 0.0)
		"cast":
			await _shot_meeting_cast(view, "office_shot_meet_%02d_cast" % hour)
		"toast":
			await _shot_toasts(view)
		"hr_dossier":
			EventBus.tab_changed.emit("hr")
			get_tree().call_group(&"window_layer", &"open_detail", "hr_dossier",
				{"character_id": CharacterRegistry.get_employees()[0].id})
		"crowd40":
			while not people._placed:
				await get_tree().physics_frame
			print("LOOKS|%s" % OfficeCrowdProbe.looks_line(people._actors.values()))
			# Four close frames, a quarter of the roster apart; the overall frame follows below.
			var cam: OfficeCamera = view.camera
			var at: Array = people._actors.values().filter(func(a: OfficeActor) -> bool: return a.visible)
			for i in 4:
				cam.focus((at[floori(i * at.size() / 4.0)] as OfficeActor).position + Vector3.UP, cam.fit_zoom * 5.0, 0.0)
				await get_tree().create_timer(0.6).timeout
				_save_shot("office_shot_%s_%02d_crowd40_close%d" % [office_id, hour, i])
			cam.focus(cam.fit_target, cam.fit_zoom, 0.0)
		"founders":
			_on_shot_layer(OfficeCrowdProbe.founder_sheet())
		"nav":
			view.get_node("Viewport3D/SubViewport/World").add_child(OfficeCrowdProbe.nav_overlay(view.layout))
		"full":
			# People write the desk states every frame. Once the floor has synced and they are
			# placed, they stop, and the states forced below hold.
			while not people._placed:
				await get_tree().physics_frame
			await get_tree().process_frame
			people.set_process(false)
			var lighting: OfficeLighting = view.lighting
			lighting.anyone_in = true
			lighting.founder_at_desk = true
			for desk in view.layout.max_n + 1:
				lighting.set_station_state(desk, true)
		_:
			EventBus.tab_changed.emit(extra)
	await get_tree().create_timer(1.2).timeout
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	var start: int = Time.get_ticks_usec()
	for i in 60:
		await get_tree().process_frame
	print("OFFICE_SHOT|%s|%d|frame_ms=%.2f|draw_calls=%d|tris=%d" % [office_id, hour,
		(Time.get_ticks_usec() - start) / 60000.0,
		Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME),
		Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME)])
	_save_shot("office_shot_%s_%02d%s" % [office_id, hour, "_" + extra if extra != "" else ""])
	get_tree().quit()


## The shell's toast through its real callers, a frame each: F5 over an open window, F5 refused, a
## sales and a VC call put off, a move under way and its arrival, then F9, which remounts the shell.
func _shot_toasts(view: Control) -> void:
	_wire_modal_signals()
	# The toast places itself when shown: wait for --shot-scale, which _begin_shot applies late.
	await get_tree().create_timer(0.4).timeout
	EventBus.tab_changed.emit("hr")
	EventBus.quicksave_requested.emit()
	await _toast_frame("saved")
	EventBus.tab_changed.emit("")
	# The one refusal a shot can stage without opening a sitting.
	GameState.run_active = false
	EventBus.quicksave_requested.emit()
	GameState.run_active = true
	await _toast_frame("not_saved")
	var invite: MeetingInvite = view.invite
	var caller: Dictionary = CounterpartSystem.lead(SHOT_FUND)
	for kind in ["sales", "vc"]:
		invite.ring({"caller": caller, "vc_id": SHOT_FUND, "line": "MEETING_INVITE_SALES", "args": {}, "open": false,
			"postpone": true, "note": "", "note_args": {}, "toast": "MEETING_POSTPONED_" + kind.to_upper()})
		invite._postpone()
		await _toast_frame("postponed_" + kind)
		invite.stop()
	EventBus.office_move_started.emit("plaza", GameState.day + 1)
	await _toast_frame("move_started")
	EventBus.office_changed.emit(GameState.office_id)
	await _toast_frame("moved")
	EventBus.quickload_requested.emit()
	await get_tree().create_timer(0.5).timeout
	await _toast_frame("loaded")


func _toast_frame(name: String) -> void:
	await get_tree().create_timer(0.5).timeout
	_save_shot("office_shot_toast_" + name)


## The meeting shots' other side: this fund's three.
const SHOT_FUND := "meridian"
## The cast shot: seconds between the walk-in's frames and the most of them; how much closer the
## gestures are framed.
const CAST_WALK_EVERY := 0.5
const CAST_WALK_MAX := 30
const CAST_CLOSE := 2.6


## The table at rest: the lead and the founder with their arms on it, the partner leaning back
## with hands in the lap, the analyst taking notes; the other side looks at the founder, the founder
## at the lead.
func _shot_meeting_posts(cast: MeetingCast) -> void:
	cast.post(0, {"arms": "table"})
	cast.post(1, {"arms": "table", "lean": 0.05})
	cast.post(2, {"arms": "rest", "lean": -0.1})
	cast.post(3, {"write": true})
	for who in range(1, cast.count()):
		cast.look(who, 0)
	cast.look(0, 1)


## The cast shot's frames: the walk in until the founder sits, the table at rest, the lead speaking,
## then each gesture at its middle.
func _shot_meeting_cast(view: Control, stem: String) -> void:
	var cast: MeetingCast = view.cast
	var n := 0
	await get_tree().create_timer(0.6).timeout
	cast.walk_in()
	# A lambda captures locals by value: the flag lives in a dictionary.
	var state := {"seated": false}
	cast.founder_seated.connect(func() -> void: state.seated = true, CONNECT_ONE_SHOT)
	while not state.seated and n < CAST_WALK_MAX:
		await get_tree().create_timer(CAST_WALK_EVERY).timeout
		_save_shot("%s_%02d" % [stem, n])
		n += 1
	print("CAST|walk_in|seated=%s|frames=%d" % [state.seated, n])
	_shot_meeting_posts(cast)
	await get_tree().create_timer(1.0).timeout
	_save_shot("%s_%02d_rest" % [stem, n])
	n += 1
	# Close over the table for the gestures, which the room's framing shows too small to judge.
	var cam: OfficeCamera = view.camera
	cam.focus(cam.target + Vector3.UP * 0.5, cam.zoom * CAST_CLOSE, 0.0)
	cast.speak(1)
	await get_tree().create_timer(1.2).timeout
	_save_shot("%s_%02d_speak" % [stem, n])
	n += 1
	cast.speak(-1)
	for g: Array in [[2, "nod"], [1, "lean"], [1, "watch"], [2, "back"], [1, "shake"], [3, "pen"], [0, "lookup"]]:
		cast.gesture(g[0], g[1])
		await get_tree().create_timer(MeetingCast.GESTURE_S * 0.45).timeout
		_save_shot("%s_%02d_%s" % [stem, n, g[1]])
		n += 1
		await get_tree().create_timer(MeetingCast.GESTURE_S * 0.7).timeout


const TRAVEL_SHOT_EVERY := 0.25    # seconds between frames
const TRAVEL_SHOT_MAX := 80        # frames of the trip out before the shot gives up on the scene
const TRAVEL_SHOT_BACK := 48       # frames of the trip home and the walk back in
const TRAVEL_SHOT_RING := 2.4      # the phone rings this long, the camera closing on the founder
const TRAVEL_SHOT_STAFF := 6


# --travel-shot=<home|ishani|plaza|loft>[:vc]: the founder's trip to a meeting from that office at
# 10:00, as the player sees it: the phone ringing, its card, then frames of the walk out, the
# map's road and the walk in to the table, one of the meeting panel beside the table, and the trip
# home to the walk back in. A sales meeting by default; vc books the shot's fund for this week,
# whose call rings. travel_shot_<office>[_vc]_NN.png, in order.
func _run_travel_shot(spec: String) -> void:
	var office_id: String = spec.get_slice(":", 0)
	var vc: bool = spec.get_slice(":", 1) == "vc"
	var stem: String = "travel_shot_%s%s" % [office_id, "_vc" if vc else ""]
	_begin_shot()
	_travel_on = true
	_seed_sales_world()
	GameState.office_id = office_id
	GameState.set_current_hour(10)
	TimeManager.sync_to_current_hour()
	var lead: Prospect = SalesFaucetSystem.spawn(2, "faucet")
	# People at their desks, who look up as the founder leaves and asks how it went on the way back.
	OfficeCrowdProbe.seed_staff(TRAVEL_SHOT_STAFF)
	if vc:
		GameState.set_phase(3)
		GameState.pending_meeting = {"vc_id": SHOT_FUND, "day": GameState.day}
		# A shot wires no signals: the answered call's meeting reaches the panel this way.
		EventBus.meeting_scene_requested.connect(_on_meeting_scene_requested)
	await _mount_shot_shell()
	EventBus.speed_change_requested.emit(1)
	await get_tree().create_timer(1.0).timeout
	if not vc:
		# A shot wires no signals: the tab's request is made directly.
		_on_pitch_requested(lead.id)
	await get_tree().create_timer(TRAVEL_SHOT_RING).timeout
	var invite: MeetingInvite = _meeting_invite()
	if not invite.is_ringing():
		_shot_fail("[TravelShot] the phone never rang")
		return
	var frame: int = 0
	_save_shot("%s_%02d" % [stem, frame])
	invite._open_card()
	await get_tree().create_timer(TRAVEL_SHOT_EVERY).timeout
	frame += 1
	_save_shot("%s_%02d" % [stem, frame])
	invite._accept()
	while _meeting_panel == null:
		if frame == TRAVEL_SHOT_MAX:
			_shot_fail("[TravelShot] the meeting panel never mounted")
			return
		frame += 1
		await get_tree().create_timer(TRAVEL_SHOT_EVERY).timeout
		_save_shot("%s_%02d" % [stem, frame])
	await get_tree().create_timer(0.4).timeout
	frame += 1
	_save_shot("%s_%02d" % [stem, frame])
	# The sitting ends where it stands, through the panel's own close.
	_meeting_panel.closed.emit()
	for _i in TRAVEL_SHOT_BACK:
		frame += 1
		await get_tree().create_timer(TRAVEL_SHOT_EVERY).timeout
		_save_shot("%s_%02d" % [stem, frame])
	get_tree().quit()


# --invite-shot=<ring|card|vc|postpone|postpone_vc>: the call that opens an outside meeting, at İş hanı
# with people at their desks, as the player meets it: ring = a prospect's call at 14:00 ringing over the
# founder's head, its card shut; card = that card open; vc = a fund's call at 10:00, its card open from the
# first ring and the clock stopped; postpone = the prospect's call put off, still ringing, the toast saying
# so; postpone_vc = the fund's call put off, the ring gone and the toast saying the meeting moved on. The
# notice stack holds three rows (a paper, an account at risk, someone who may leave), which an open card
# stands clear of or hides. invite_shot_<kind>.png.
func _run_invite_shot(kind: String) -> void:
	var vc: bool = kind.ends_with("vc")
	_begin_shot()
	_travel_on = true
	_seed_sales_world()
	GameState.office_id = "ishani"
	GameState.set_current_hour(10 if vc else 14)
	TimeManager.sync_to_current_hour()
	var lead: Prospect = SalesFaucetSystem.spawn(2, "faucet")
	OfficeCrowdProbe.seed_staff(TRAVEL_SHOT_STAFF)
	_shot_customer("co_ege", "Ege Sigorta", "insurance", "risk", 1000, 12, 9, false)
	_shot_customer("co_nordica", "Nordica", "logistics", "expansion", 2000, 20, 26, false)
	_shot_paper("customer.expansion", {"customer": "co_nordica"}, 2)
	CharacterRegistry.set_morale("char_crowd_0", 22)
	SalesSystem.reflect_mrr()
	if vc:
		GameState.set_phase(3)
		GameState.pending_meeting = {"vc_id": SHOT_FUND, "day": GameState.day}
	await _mount_shot_shell()
	EventBus.speed_change_requested.emit(1)
	await get_tree().create_timer(1.0).timeout
	if not vc:
		# A shot wires no signals: the tab's request is made directly.
		_on_pitch_requested(lead.id)
	await get_tree().create_timer(TRAVEL_SHOT_RING).timeout
	var invite: MeetingInvite = _meeting_invite()
	if not invite.is_ringing():
		_shot_fail("[InviteShot] the phone never rang")
		return
	if kind != "ring":
		invite._open_card()
	if kind.begins_with("postpone"):
		invite._postpone()
	await get_tree().create_timer(0.5).timeout
	_save_shot("invite_shot_" + kind)
	get_tree().quit()


const DAY_SHOT_FRAMES := 24        # frames across one visible day, whatever the speed
const DAY_SHOT_AFTER := 3          # frames kept after the night skip lands on the new week


# --day-shot=<home|ishani|plaza|loft>:<speed 1-4>: one working week on the real clock, 08:00
# through the walk-out and the night skip to the next 08:00, as the player sees it. The week is
# the last of January, so the silent month close lands in the skip and its ticker line shows.
# day_shot_<office>_<speed>_NN.png plus one DAYSHOT line per frame (real ms, week, clock, night).
func _run_day_shot(spec: String) -> void:
	var parts: PackedStringArray = spec.split(":")
	var office_id: String = parts[0]
	var speed: int = int(parts[1]) if parts.size() > 1 else 1
	_begin_shot()
	_seed_theme_surface()
	GameState.office_id = office_id
	GameState.day = 5
	GameState.set_current_hour(TimeModel.WEEK_START_HOUR)
	TimeManager.sync_to_current_hour()
	await _mount_shot_shell()
	var landed: Array[bool] = [false]
	EventBus.night_skipped.connect(func() -> void: landed[0] = true, CONNECT_ONE_SHOT)
	var every: float = TimeModel.seconds_per_tick(speed) / DAY_SHOT_FRAMES
	var start: int = Time.get_ticks_msec()
	EventBus.speed_change_requested.emit(speed)
	var after: int = 0
	for frame in DAY_SHOT_FRAMES * 3:
		await get_tree().create_timer(every).timeout
		print("DAYSHOT|%02d|ms=%d|week=%d|clock=%02d:%02d|night=%s|speed=%d" % [frame,
			Time.get_ticks_msec() - start, GameState.day, int(TimeManager.day_minute()) / 60,
			int(TimeManager.day_minute()) % 60, str(TimeManager.is_night()), TimeManager.current_speed])
		_save_shot("day_shot_%s_%d_%02d" % [office_id, speed, frame])
		if landed[0]:
			after += 1
			if after == DAY_SHOT_AFTER:
				break
	get_tree().quit()


# --office-crowd-probe=<home|ishani|plaza|loft>:<people>:<speed 1-4>: that many people (the
# founder and a seeded staff, roles in turn) through one working week of the office on the real
# clock, 08:00 through the night skip into the next morning, with a second's pause at noon.
# OfficeCrowdProbe prints the CROWD lines; crowd_<office>_<people>_<speed>_NN.png at the start,
# through the day, as the night begins and after the skip.
func _run_office_crowd_probe(spec: String) -> void:
	var parts: PackedStringArray = spec.split(":")
	_begin_shot()
	_seed_run_reproducible()
	GameState.set_cash(500000)
	GameState.office_id = parts[0]
	GameState.day = 5
	GameState.set_current_hour(TimeModel.WEEK_START_HOUR)
	TimeManager.sync_to_current_hour()
	OfficeCrowdProbe.seed_staff(int(parts[1]) - 1)
	# Paused on the speed it will run at: the opening plans the walks in at that pace.
	EventBus.speed_change_requested.emit(0)
	TimeManager.last_running_speed = int(parts[2])
	await _mount_shot_shell()
	var probe := OfficeCrowdProbe.new()
	add_child(probe)
	await probe.run(get_tree().get_first_node_in_group(&"office_view"), int(parts[2]), "_".join(parts), _save_shot)
	get_tree().quit()


# --tab-shot=<product|sales|hr|finance|personal|marketing|rnd|events>. tab_changed is emitted
# directly, so a tab locked on the rail can still be framed — the lock lives on the rail.
func _run_tab_shot(tab_id: String) -> void:
	_begin_shot()
	_seed_theme_surface()
	await _mount_shot_shell()
	EventBus.tab_changed.emit(tab_id)
	await _finish_shot("tab_shot_%s" % tab_id)


# --personal-shot=<normal|cheque|ready|training|seed>: the Kişisel window on the theme seed. cheque: after Frank's
# cheque, taken through its real seam (cash, the cap table's angel slice, the first funding); ready: the founder's
# experience bar full, the training button on; training: the founder away on a course; seed: the Series A Hunt after
# the cheque and a signed seed (three parts on the cap table).
func _run_personal_shot(kind: String) -> void:
	_begin_shot()
	_seed_theme_surface()
	var founder: Character = CharacterRegistry.get_founder()
	match kind:
		"cheque":
			AngelRoundSystem.accept_offer()
		"ready", "training":
			CharacterRegistry.refresh_experience_threshold(founder)
			founder.experience_raw = founder.experience_threshold
			if kind == "training":
				CharacterRegistry.begin_training(founder.id, HRConstants.AREAS[0])
		"seed":
			GameState.set_phase(3)
			AngelRoundSystem.accept_offer()
			SeedRoundSystem.accept("anchor", {"raise": 120000, "dilution_pct": 15})
	await _mount_shot_shell()
	EventBus.tab_changed.emit("personal")
	await _finish_shot("personal_shot_%s" % kind)


## --rnd-shot=<kind>: the Ar-Ge window and its research card on the mockups' timeline (_seed_rnd, week 14, 11:00).
##   tree · detail (AI Engine picked) · detail_cash (the same with less cash than its cost: the card's one danger) ·
##   assign (its assignment open, Elif ticked) · frozen (week 15: Selin has left,
##   the research stands frozen, Mert on leave; its assignment open) · history (the window's own history, the week's
##   note read) · history_empty (before any note or discovery) · read_only (AI Engine picked while Frank's offer
##   waits) · closed (before v1, at home);
##   no window: card (the card running) · card_frozen (paused, nobody on it) · card_build (its person taken by a
##   build) · card_none (its person on leave: no contribution) · card_gate (while a decision waits) · discovery
##   (week 16: Test Otomasyonu done, its discovery on the notice stack) · first_note (the run's first monthly note
##   arrives through the engine and opens in the inbox).
func _run_rnd_shot(kind: String) -> void:
	_begin_shot()
	if kind == "closed":
		_seed_run_reproducible()
		GameState.current_hour = 10
	else:
		_seed_theme_surface()
		GameState.current_hour = 11
		if kind != "history_empty":
			_seed_rnd(16 if kind == "discovery" else 14, kind != "first_note")
	TimeManager.sync_to_current_hour()
	var selin := "char_emp_shot_3"
	match kind:
		"frozen":
			RnDSystem.drop_assignee(selin)
			CharacterRegistry.remove(selin)
			GameState.day = 15
		"detail_cash":
			GameState.set_cash(ResearchTree.cash_of("ai_engine") / 2)
		"card_frozen":
			RnDSystem.pause()
		"card_build":
			RnDSystem.drop_assignee(selin, "RND_PAUSED_BUILD")
		"card_none":
			HRMoraleSystem.send_on_leave(CharacterRegistry.get_character(selin), HRConstants.LEAVE_WEEKS, false)
	await _mount_shot_shell()
	_wire_modal_signals()
	match kind:
		"tree", "history", "history_empty", "closed":
			EventBus.tab_changed.emit("rnd")
			if kind.begins_with("history"):
				_shell.find_child("CenterViewport", true, false).get_current_page_body()._show_view(1)
		"detail", "detail_cash", "assign", "frozen", "read_only":
			if kind == "read_only":
				_shot_card("funding.frank_cheque", {}, 11)
			EventBus.tab_changed.emit("rnd")
			EventBus.rnd_node_requested.emit("test_automation" if kind == "frozen" else "ai_engine", kind in ["assign", "frozen"])
			if kind == "assign":
				await get_tree().process_frame
				get_tree().root.find_child("AssignPanel", true, false).toggle("char_emp_shot_0")
		"card_gate":
			_shot_card("funding.frank_cheque", {}, 11)
			EventBus.tab_changed.emit("")
		"first_note":
			RnDSystem._tick_note()
		"card", "card_frozen", "card_build", "card_none", "discovery":
			pass
		_:
			_shot_fail("[RndShot] unknown kind: %s" % kind)
			return
	get_tree().call_group(&"top_bar", &"_refresh")
	await _finish_shot("rnd_shot_%s" % kind, 0.6)


## The Ar-Ge timeline the mockups draw, through the engine on the theme seed's people: Tasarım Sistemi (Deniz)
## done week 8, Kullanıcı Araştırması (Deniz) 10, Veri Modeli (Elif) 11, Hata Takip Sistemi (Selin) 13; Test
## Otomasyonu (Selin) from week 13, at 36 % on week 14, when the first monthly note comes (unless `note` is
## false); what came before is read. Week 16 finishes it, the note read.
func _seed_rnd(week: int, note := true) -> void:
	for row in [["design_system", 1, 8], ["user_research", 1, 10], ["data_model", 0, 11], ["bug_tracker", 3, 13]]:
		GameState.day = row[2]
		RnDSystem.start(row[0], ["char_emp_shot_%d" % row[1]])
		RnDSystem._complete(row[0])
	RnDSystem.start("test_automation", ["char_emp_shot_3"])
	var state: Dictionary = RnDSystem.to_dict()
	state.progress["test_automation"] = 0.36 * ResearchTree.effort_of("test_automation")
	RnDSystem.from_dict(state)
	# The player has read the discoveries by now.
	for m in GameState.messages:
		MessageSystem.mark_read(String(m.id))
	GameState.day = 14
	if note:
		RnDSystem._tick_note()
	if week == 16:
		RnDSystem.mark_note_read()
		GameState.day = 16
		# The theme seed's product type is not in the line catalogue: the line this research opens registers on a
		# catalogued B2B type.
		GameState.set_flag("mvp_sub_product_type_id", "erp")
		RnDSystem._complete("test_automation")
		GameState.set_flag("mvp_sub_product_type_id", "saas_ops")


# --modal-shot=<confirm|confirm3|confirm_dark|settings|system|saveload>. Each goes through the REAL
# mount path (EventBus signal → handler here), so fixture and live behaviour cannot drift.
func _run_modal_shot(kind: String) -> void:
	_begin_shot()
	_seed_theme_surface()
	await _mount_shot_shell()
	_wire_modal_signals()
	match kind:
		"confirm":
			EventBus.confirm_requested.emit({
				"title": "Geliştirmeyi iptal et?",   # LOC-DATA debug seed / id
				"body": "Nova v3 build'i durur ve harcanan efor geri gelmez.",   # LOC-DATA debug seed / id
				"confirm_text": "İPTAL ET",   # LOC-DATA debug seed / id
				"cancel_text": "VAZGEÇ",   # LOC-DATA debug seed / id
			})
		"confirm3", "confirm_dark":
			# Üç butonlu hâl: alt_text varlığı üçüncü butonu açar. confirm_dark aynı onayı koyu dilde açar.
			EventBus.confirm_requested.emit({
				"title": tr("SYS_QUIT_TITLE"),
				"body": tr("SYS_QUIT_BODY"),
				"confirm_text": tr("SYS_QUIT_SAVE"),
				"alt_text": tr("SYS_QUIT_DISCARD"),
				"cancel_text": tr("SYS_CANCEL"),
				"theme": kind == "confirm_dark",
			})
		"settings":
			EventBus.settings_requested.emit()
		"system":
			EventBus.system_menu_requested.emit()
		"saveload":
			# Önce gerçek bir kayıt yaz ki YÜKLE listesinde gerçek bir slot satırı olsun.
			SaveManager.quicksave()
			EventBus.save_load_requested.emit("load")
		_:
			_shot_fail("[ThemeShot] unknown --modal-shot kind: %s" % kind)
			return
	await _finish_shot("modal_shot_%s" % kind)


# --onboard-shot=<0|1|2|3>. Step 0 is the language gate, mounted directly: it is unreachable
# by play once a language is stored, and the harness must not depend on a pristine settings file.
func _run_onboard_shot(step: int) -> void:
	_begin_shot()
	if step == 0:
		_mount_language_gate()
	else:
		_mount_flow()
		await get_tree().process_frame
		await get_tree().process_frame
		var idx: int = clampi(step - 1, 0, 2)
		if idx > 0:
			_flow._mount_step(idx)   # doğrudan seam: adım geçerliliği fixture'da dolu olmayabilir
	await _finish_shot("onboard_shot_%d" % step)


# --theme-audit=<tab_id | modal:<kind> | onboard:<step>> stages the surface as --tab-shot,
# --modal-shot or --onboard-shot does and prints the RESOLVED theme values of every Control in
# place of the frame: immune to anti-aliasing noise, and it names exactly which nodes changed.
func _run_theme_audit(spec: String) -> void:
	_audit_spec = spec
	var kind: String = spec.get_slice(":", 1)
	match spec.get_slice(":", 0):
		"modal":
			_run_modal_shot(kind)
		"onboard":
			_run_onboard_shot(int(kind))
		_:
			_run_tab_shot(spec)


# --probe-shot: ThemeProbe.tscn, one unstyled instance of every basic Control class. Screenshot
# and audit dump come from the same run so pixels and resolved values verify each other.
# --probe-shot=menajer mounts it under menajer_theme.tres and adds one sample of every variation
# that theme holds beyond master's. --probe-shot=kit lays out the dark kit's components in their
# states instead (scripts/debug/kit_probe.gd).
func _run_probe_shot(theme_name: String) -> void:
	_begin_shot()
	var probe: Control
	if theme_name == "kit":
		probe = load("res://scripts/debug/kit_probe.gd").page()
	else:
		probe = (load("res://scenes/debug/ThemeProbe.tscn") as PackedScene).instantiate()
	if theme_name == "menajer":
		probe.theme = load(UiTokens.MENAJER_THEME)
		_probe_variations(probe.get_node("Margin/Col"), probe.theme)
	add_child(probe)
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().create_timer(0.4).timeout
	_save_shot("probe_shot" if theme_name == "" else "probe_shot_" + theme_name)
	print("PROBE_BEGIN")
	_audit_walk(probe, "")
	print("PROBE_END")
	get_tree().quit()


func _probe_variations(col: Control, th: Theme) -> void:
	var master_types := ThemeDB.get_project_theme().get_type_list()
	var flow := HFlowContainer.new()
	flow.add_theme_constant_override("h_separation", 12)
	flow.add_theme_constant_override("v_separation", 8)
	col.add_child(flow)
	var names := th.get_type_list()
	names.sort()
	for type in names:
		var base := th.get_type_variation_base(type)
		if base == &"" or master_types.has(type):
			continue
		while th.get_type_variation_base(base) != &"":
			base = th.get_type_variation_base(base)
		var c: Control
		match base:
			&"Label":
				c = Label.new()
				c.text = type
			&"Button":
				c = Button.new()
				c.text = type
			&"RichTextLabel":
				c = RichTextLabel.new()
				c.bbcode_enabled = true
				c.fit_content = true
				c.custom_minimum_size = Vector2(320, 0)
				c.text = type + " [b]bold[/b] [i]italic[/i]"
			&"Panel":
				c = Panel.new()
				c.custom_minimum_size = Vector2(24, 24)
			_:
				c = PanelContainer.new()
				c.custom_minimum_size = Vector2(160, 40)
				var name_label := Label.new()
				name_label.text = type
				c.add_child(name_label)
		c.theme_type_variation = type
		c.tooltip_text = type
		flow.add_child(c)
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(240, 72)
	var tall := Label.new()
	tall.text = "ScrollContainer\n1\n2\n3\n4\n5\n6"
	scroll.add_child(tall)
	flow.add_child(scroll)


# Classes that DRAW text. A Panel also answers get_theme_font_size("font_size") but draws
# nothing with it. RichTextLabel's keys differ (normal_font_size/default_color).
const _AUDIT_TEXT_CLASSES := [
	"Label", "Button", "LineEdit", "CheckBox", "CheckButton", "OptionButton",
	"MenuButton", "LinkButton", "TextEdit", "SpinBox",
]


# One AUDIT line per Control: path, class, variation, font size, font colour, local overrides
# (S=font_size, C=font_color, P=panel stylebox), font face, panel stylebox fingerprint, then
# _audit_layout's content margins, minimum size and theme sources, and every override (ov).
func _audit_walk(node: Node, path: String) -> void:
	for child in node.get_children():
		var p: String = path + "/" + String(child.name)
		var c := child as Control
		if c != null:
			var variation: String = String(c.theme_type_variation)
			var cls: String = c.get_class()
			var font_key: String = ""
			var size_key: String = ""
			var color_key: String = ""
			if cls == "RichTextLabel":
				font_key = "normal_font"
				size_key = "normal_font_size"
				color_key = "default_color"
			elif cls in _AUDIT_TEXT_CLASSES:
				font_key = "font"
				size_key = "font_size"
				color_key = "font_color"
			var fs: String = "-"
			var col: String = "-"
			if size_key != "" and c.has_theme_font_size(size_key):
				fs = str(c.get_theme_font_size(size_key))
			if color_key != "" and c.has_theme_color(color_key):
				col = _audit_color(c.get_theme_color(color_key))
			var ovr: String = ""
			if c.has_theme_font_size_override("font_size") or c.has_theme_font_size_override("normal_font_size"):
				ovr += "S"
			if c.has_theme_color_override("font_color") or c.has_theme_color_override("default_color"):
				ovr += "C"
			if c.has_theme_stylebox_override("panel"):
				ovr += "P"
			print("AUDIT|%s|%s|%s|%s|%s|%s|%s|%s|%s|ov:%s" % [
				p, cls, variation if variation != "" else "--", fs, col,
				ovr if ovr != "" else "-", _audit_font(c, font_key), _audit_stylebox(c),
				_audit_layout(c, font_key, size_key, color_key), _audit_overrides(c)])
		_audit_walk(child, p)


## cm: content margins (L,T,R,B) of the box the control draws, `panel` else `normal`. min: the
## combined minimum size. src: where font (f), size (s), colour (c) and box (b) resolved. A scoped
## theme that lacks a variation hands its controls the base type's box: cm collapses, src names it.
func _audit_layout(c: Control, font_key: String, size_key: String, color_key: String) -> String:
	var chain := _audit_theme_chain(c)
	var types := _audit_types(c, chain)
	var src := PackedStringArray()
	if font_key != "":
		src.append("f=" + _audit_source(c, chain, types, Theme.DATA_TYPE_FONT, font_key))
		src.append("s=" + _audit_source(c, chain, types, Theme.DATA_TYPE_FONT_SIZE, size_key))
		src.append("c=" + _audit_source(c, chain, types, Theme.DATA_TYPE_COLOR, color_key))
	var box: String = "panel" if c.has_theme_stylebox("panel") else ("normal" if c.has_theme_stylebox("normal") else "")
	var cm: String = "-"
	if box != "":
		var sb: StyleBox = c.get_theme_stylebox(box)
		cm = "%s=%.1f,%.1f,%.1f,%.1f" % [box, sb.get_margin(SIDE_LEFT), sb.get_margin(SIDE_TOP),
				sb.get_margin(SIDE_RIGHT), sb.get_margin(SIDE_BOTTOM)]
		src.append("b=" + _audit_source(c, chain, types, Theme.DATA_TYPE_STYLEBOX, box))
	var m: Vector2 = c.get_combined_minimum_size()
	return "cm:%s|min:%.1fx%.1f|src:%s" % [cm, m.x, m.y, ",".join(src) if not src.is_empty() else "-"]


## The themes Godot asks, in its order, as [label, theme]: one on the control or an ancestor up to
## the nearest CanvasLayer (a:<file or node>), then the project theme (p), then the engine's (d).
func _audit_theme_chain(c: Control) -> Array:
	var chain: Array = []
	var n: Node = c
	while n is Control or n is Window:
		var th: Theme = n.get("theme")
		if th != null:
			chain.append(["a:" + (th.resource_path.get_file().get_basename() if th.resource_path != "" else String(n.name)), th])
		n = n.get_parent()
	chain.append(["p", ThemeDB.get_project_theme()])
	chain.append(["d", ThemeDB.get_default_theme()])
	return chain


## The type chain Godot searches: the variation's bases as the first theme declaring it has
## them, then the class and its ancestors.
func _audit_types(c: Control, chain: Array) -> Array[StringName]:
	var types: Array[StringName] = []
	var cls := StringName(c.get_class())
	var v: StringName = c.theme_type_variation
	if v != &"":
		for entry in chain:
			var th: Theme = entry[1]
			if th.get_type_variation_base(v) != &"":
				while v != &"" and v != cls:
					types.append(v)
					v = th.get_type_variation_base(v)
				break
	while cls != &"":
		types.append(cls)
		cls = ClassDB.get_parent_class(cls)
	return types


## o: the control's own override, else the label of the first theme holding the item.
func _audit_source(c: Control, chain: Array, types: Array[StringName], dt: int, item: StringName) -> String:
	var own: bool
	match dt:
		Theme.DATA_TYPE_COLOR: own = c.has_theme_color_override(item)
		Theme.DATA_TYPE_FONT: own = c.has_theme_font_override(item)
		Theme.DATA_TYPE_FONT_SIZE: own = c.has_theme_font_size_override(item)
		Theme.DATA_TYPE_STYLEBOX: own = c.has_theme_stylebox_override(item)
	if own:
		return "o"
	for entry in chain:
		for t in types:
			if (entry[1] as Theme).has_theme_item(dt, item, t):
				return entry[0]
	return "-"


## Every theme item set on the control itself, as kind/item. Names a native class does not declare
## are not listed.
func _audit_overrides(c: Control) -> String:
	var ov := PackedStringArray()
	for prop in c.get_property_list():
		if String(prop.name).begins_with("theme_override_") and prop.usage & PROPERTY_USAGE_STORAGE:
			ov.append(String(prop.name).trim_prefix("theme_override_"))
	ov.sort()
	return ",".join(ov) if not ov.is_empty() else "-"


## Resolved font face file name, for text-drawing classes only.
func _audit_font(c: Control, font_key: String) -> String:
	if font_key == "":
		return "-"
	var f: Font = c.get_theme_font(font_key) if c.has_theme_font(font_key) else null
	if f == null:
		return "-"
	return f.resource_path.get_file().get_basename() if f.resource_path != "" else f.get_class()


## Resolved `panel` stylebox fingerprint; non-flat boxes pass as their class (a type change
## is a signal too).
func _audit_stylebox(c: Control) -> String:
	var sb: StyleBox = c.get_theme_stylebox("panel") if c.has_theme_stylebox("panel") else null
	if sb == null:
		return "-"
	var flat := sb as StyleBoxFlat
	if flat == null:
		return sb.get_class()
	return "bg:%s|bd:%s|w:%d,%d,%d,%d|r:%d" % [
		_audit_color(flat.bg_color), _audit_color(flat.border_color),
		flat.border_width_left, flat.border_width_top,
		flat.border_width_right, flat.border_width_bottom,
		flat.corner_radius_top_left]


func _audit_color(c: Color) -> String:
	return "%.3f,%.3f,%.3f,%.2f" % [c.r, c.g, c.b, c.a]


# --finance-shot=<ozet|artida|uyari|kepenk|signal|gider>: six weeks played through real seams (cash
# ring buffer and transaction ledger fill from the real flow), framed on the Finance tab.
#   ozet   — negatif net: mevcut gidiş projeksiyonu, iki imza; eğrinin 4. haftası üstüne gelinmiş
#   artida — MRR > burn: yeşil ARTIDA, kırmızı erime projeksiyonu yok
#   uyari  — runway < 3 ay: mentor kartı BAND 1 + ERTELE, mevcut gidiş sıfırı ufukta keser
#   kepenk — uyari'nin akışı, kasa eksiye düşüp kepenk sayacı bir hafta işleyene kadar: BAND 2
#   signal — artida'nın akışı, faz 2'de ayları takvimle kapanarak dört ay artıda kapanana kadar: yatırımcı iştahı
#            + artıda ay sayısı
#   gider  — on saatlik mesai, MVP'nin bulut sunucusu ve servis maliyeti: gider dağılımının bütün kalemleri
func _run_finance_shot(kind: String) -> void:
	_begin_shot()
	_seed_run_reproducible()
	GameState.set_flag("mvp_shipped", true)
	GameState.set_flag("mvp_market_type", "b2b")
	GameState.set_flag("mvp_sub_product_type_id", "saas_ops")
	_seed_hr_roster()
	GameState.set_cash(150000 if kind in ["uyari", "kepenk"] else 300000)
	# The curve must start from the fixture cash, not initialize_run's day-1 sample — the one
	# debug exception to the single-writer rule.
	GameState.cash_history = [{"day": GameState.day, "cash": GameState.cash}]
	if kind == "gider":   # LOC-DATA debug seed / id
		WorkHoursSystem.set_company_hours(10)
		# The server the MVP opens with (SprintBridges.on_mvp), so its bill is a line.
		InfraSystem.set_provider(InfraSystem.PROVIDER_CLOUD)
		InfraSystem.set_capacity(InfraSystem.suggested_start_units())
	# artida: 3 imza × 20K = 60K MRR → günlük gelir 2000 > kadro burn'ü (~1500).
	var profitable: bool = kind in ["artida", "signal"]   # LOC-DATA debug seed / id
	var sign_mrr: int = 20000 if profitable else 1100
	for i in range(6):
		GameState.advance_day()
		if kind == "signal":   # LOC-DATA debug seed / id
			SummarySystem.begin_day()
		if i == 1 or (profitable and (i == 2 or i == 3)):
			var pr: Prospect = SalesFaucetSystem.spawn_prospect("mid", "event")
			# §5.3 koltuk × koltuk fiyatı: 20.000 = 400 × $50, 1.100 = 22 × $50.
			SalesSystem.add_b2b_customer(pr, sign_mrr / 50, 50, 70)
			ProspectRegistry.remove(pr.id)
		if i == 3 and not profitable:
			# Bekleyen bir arayış; arama ücretsiz (§10), gider satırı eğitimden gelir.
			HRSearchSystem.start_search(HRConstants.ROLE_DEVELOPER, HRConstants.LEVEL_MID)
		if i == 4 and kind == "ozet":
			var pr2: Prospect = SalesFaucetSystem.spawn_prospect("small", "event")
			SalesSystem.add_b2b_customer(pr2, 16, 50, 72)   # 16 × $50 = $800
			ProspectRegistry.remove(pr2.id)
		if kind == "gider":   # LOC-DATA debug seed / id
			InfraSystem.daily_tick()
		FinanceSystem.daily_tick()
	if kind == "kepenk":   # LOC-DATA debug seed / id
		# The melt goes on through the real flow until the shutter's counter has run a week.
		for _i in 52:
			if GameState.shutter_weeks_left == TimeModel.ticks(EndingsSystem.SHUTTER_WEEKS - 1):
				break
			GameState.advance_day()
			FinanceSystem.daily_tick()
			EndingsSystem._tick_shutter()
	if kind == "signal":   # LOC-DATA debug seed / id
		# Traction goes on through the real flow, a month closing as the calendar turns, until four months have
		# closed in the black.
		GameState.set_phase(2)
		for _i in 52:
			if GameState.get_profitable_month_streak() >= 4:
				break
			GameState.advance_day()
			SummarySystem.begin_day()
			FinanceSystem.daily_tick()
	# Açık pipeline: iyimser projeksiyon gerçek prospect'lerden beslenir.
	SalesFaucetSystem.spawn_prospect("small", "find")
	SalesFaucetSystem.spawn_prospect("mid", "find")
	await _mount_shot_shell()
	EventBus.tab_changed.emit("finance")
	if kind == "ozet":
		# The fourth week's note, as a pointer resting on it shows it.
		await get_tree().process_frame
		get_tree().get_first_node_in_group(&"window_layer").get_current_page_body()._pages.ozet._curve._hover_at(3)
	await _finish_shot("finance_shot_%s" % kind)


## First enabled Button under `root` whose own text or any Label inside it starts with
## `label`. HR menu rows are flat Buttons whose text lives in child Labels, the first of which
## is a lock glyph — so every Label is asked. Pressing it drives the real popover/anchor code.
func _press_button_labelled(root: Node, label: String) -> bool:
	for node in root.find_children("*", "Button", true, false):
		var btn := node as Button
		if btn.disabled:
			continue
		var hit: bool = btn.text.begins_with(label)
		for lbl in btn.find_children("*", "Label", true, false):
			hit = hit or (lbl as Label).text.begins_with(label)
		if hit:
			btn.pressed.emit()
			return true
	return false


# --hr-shot=<ekip|ekip-saat|atlas|atlas-secili|dosyalar|gider|saatler|saatler-gece|gorevler|gorevler-arge|
# gorevler-bos|egitim|egitim-modal|egitim-secili|zam|menu|cikar|cikar-eksi|bos|dosya|dosya-kurucu|kalabalik>:
# a roster across all three departments (one on leave, one burning out, one fresh hire), driven to the
# requested HR surface. kalabalik = forty on the roster (the compact Kadro), Geliştirme folded and the
# list scrolled under its head; dosya = the first employee's file over Kadro; dosya-kurucu = the
# founder's file over the office; ekip-saat = Kadro with hours exceptions in Durum; atlas-secili = the
# search with a role and a level picked; gorevler-arge = Görevler with someone researching.
func _run_hr_shot(kind: String) -> void:
	_begin_shot()
	_seed_run_reproducible()
	GameState.day = 10
	if kind != "bos" and kind != "gorevler-bos":
		_seed_hr_roster()
		if kind == "kalabalik":   # LOC-DATA debug seed / id
			OfficeCrowdProbe.seed_staff(34)
		# Kasa ve burn maaşları görsün: üst bar ile önizlemeler aynı gerçeği okur.
		GameState.set_cash(240000)
		FinanceSystem.daily_tick()
	match kind:
		"gorevler-bos", "atlas", "atlas-secili", "dosya-kurucu":   # LOC-DATA debug seed / id
			pass
		"dosyalar":
			# Files on the table: the arrival window's worth of real generator output.
			HRSearchSystem.start_search(HRConstants.ROLE_DEVELOPER, HRConstants.LEVEL_MID)
			for _i in TimeModel.ticks(HRConstants.SEARCH_ARRIVAL_WEEKS):
				GameState.day += 1
				HRSearchSystem.daily_tick()
		"gider":
			# Gider dökümü: on saatlik gün "Ek mesai" kalemini doldurur (§8.2); işe alım
			# komisyonu tek seferlik gider satırını doldurur.
			WorkHoursSystem.set_company_hours(10)
			FinanceSystem.daily_tick()
			FinanceSystem.apply_one_time_cost(HRConstants.commission_for(6000), "hire")
			# The cash was written, not earned: the curve has today's point and an empty past.
			GameState.cash_history = [{"day": GameState.day, "cash": GameState.cash}]
		_:
			# Aşırı yük: ilk kişi ikinci bir alanda; rozet DURUM sütununda çıkmalı.
			var over: Array[Character] = CharacterRegistry.get_employees()
			if not over.is_empty():
				CharacterRegistry.assign_area(over[0].id,
					HRConstants.role_secondary_area(over[0].role))
			# Bekleyen bir arayış da görünsün.
			HRSearchSystem.start_search(HRConstants.ROLE_DESIGNER, HRConstants.LEVEL_SENIOR)
			GameState.day += 1
			HRSearchSystem.daily_tick()
	await _mount_shot_shell()
	_wire_modal_signals()   # cikar / zam open their modal through confirm_requested
	if kind == "egitim-secili":   # LOC-DATA debug seed / id
		# The first employee's bar is full: the panel opens on an area to train.
		var first: Character = CharacterRegistry.get_employees()[0]
		CharacterRegistry.refresh_experience_threshold(first)
		first.experience_raw = first.experience_threshold
	if kind == "egitim":   # LOC-DATA debug seed / id
		# Deneyim/eğitim satırlarının üç hâli tek karede: dolu (EĞİTİME GÖNDER), eğitimde
		# (geri sayan çip), yarı yolda. Eşik kişiye göre değiştiği için oran eşikten türer.
		var roster: Array[Character] = CharacterRegistry.get_employees()
		if roster.size() >= 3:
			for i in 3:
				CharacterRegistry.refresh_experience_threshold(roster[i])
				roster[i].experience_raw = roster[i].experience_threshold if i < 2 \
					else int(roster[i].experience_threshold * 0.42)
			CharacterRegistry.begin_training(roster[1].id,
				HRConstants.role_key_area(roster[1].role))

	# "gider" Finans sekmesinde çekilir (gider dökümü orada yaşıyor).
	if kind == "gider":
		EventBus.tab_changed.emit("finance")
		await _finish_shot("hr_shot_gider")
		return
	EventBus.tab_changed.emit("hr")
	await get_tree().process_frame
	await get_tree().process_frame
	var tab: Node = _shell.find_child("CenterViewport", true, false).get_current_page_body()
	if tab == null:
		_shot_fail("[HRShot] sekme gövdesi bulunamadı (get_current_page_body null)")
		return
	match kind:
		"atlas", "dosyalar", "atlas-secili":   # LOC-DATA debug seed / id
			tab.open_atlas()
			if kind == "atlas-secili":   # LOC-DATA debug seed / id
				var atlas: Node = get_tree().get_root().find_child("PanelLayer", true, false).get_child(-1)
				atlas._selected_role = HRConstants.ROLE_DEVELOPER
				atlas._selected_level = HRConstants.LEVEL_MID
				atlas._rebuild()
		"ekip-saat":   # LOC-DATA debug seed / id
			# Durum's hours exceptions: Geliştirme on overtime, the first employee on a short day.
			WorkHoursSystem.set_group_hours(HRConstants.GROUP_DEVELOPMENT, 10)
			WorkHoursSystem.set_person_hours(CharacterRegistry.get_employees()[0].id, 6)
			tab.rebuild_view()
		"saatler-gece":   # LOC-DATA debug seed / id
			# Mesai en geç 00:00: 08:00 başlangıç ve 16 saat, sürgüler üst sınırda.
			WorkHoursSystem.set_company_start_hour(TimeModel.WEEK_START_HOUR)
			WorkHoursSystem.set_company_hours(WorkHoursSystem.max_hours(TimeModel.WEEK_START_HOUR))
			tab._open_hours_modal()
		"saatler":   # LOC-DATA debug seed / id
			# §8.5: üç kapsam birden — şirket normalde, bir grup mesaide, bir kişi kısa günde.
			WorkHoursSystem.set_group_hours(HRConstants.GROUP_DEVELOPMENT, 10)
			var crew: Array[Character] = CharacterRegistry.get_employees()
			if not crew.is_empty():
				WorkHoursSystem.set_person_hours(crew[0].id, 6)
			tab._open_hours_modal()
		"gorevler", "gorevler-arge":   # LOC-DATA debug seed / id
			# §12.0 matrisi dört hâliyle: testçi iki işte (üçüncü hücresi §12.1'e göre kilitli),
			# tasarımcı boşta (gorevler-arge'de araştırmada), gerisi normal.
			var roster: Array[Character] = CharacterRegistry.get_employees()
			if roster.size() >= 4:
				for job_id in [HRConstants.JOB_TEST, HRConstants.JOB_BUILD]:
					if not roster[3].assigned_job_ids.has(job_id):
						CharacterRegistry.assign_job(roster[3].id, job_id)
				CharacterRegistry.clear_jobs(roster[1].id)
				if kind == "gorevler-arge":   # LOC-DATA debug seed / id
					CharacterRegistry.assign_job(roster[1].id, HRConstants.JOB_RESEARCH)
			tab._show_view(tab.VIEW_ASSIGNMENTS)
		"gorevler-bos":   # LOC-DATA debug seed / id
			tab._show_view(tab.VIEW_ASSIGNMENTS)
		"egitim-modal", "egitim-secili":   # LOC-DATA debug seed / id
			var who: Array[Character] = CharacterRegistry.get_employees()
			if not who.is_empty():
				tab._on_card_action(who[0].id, HRLedger.ACTION_TRAIN, null)
		"dosya":   # LOC-DATA debug seed / id
			tab._on_card_action(CharacterRegistry.get_employees()[0].id, HRLedger.ACTION_DOSSIER, null)
		"dosya-kurucu":   # LOC-DATA debug seed / id
			EventBus.tab_changed.emit("")
			get_tree().call_group(&"window_layer", &"open_detail", "hr_dossier",
				{"character_id": CharacterRegistry.get_founder().id})
		"kalabalik":   # LOC-DATA debug seed / id
			tab._toggle_group(HRConstants.GROUP_DEVELOPMENT)
			await get_tree().process_frame
			tab._scroll.scroll_vertical = UiTokens.D_H_GROUP + UiTokens.D_H_ROW_SM * 2
		"zam", "menu", "cikar", "cikar-eksi":
			# The row's REAL path: a row click opens the HRPopover anchored on that row.
			var target: Character = CharacterRegistry.get_employees()[0]
			var row: Control = tab._rows.get(target.id)
			if row == null:
				_shot_fail("[HRShot] defter satırı bulunamadı — popover çapasız")
				return
			tab._on_card_action(target.id,
				HRLedger.ACTION_RAISE if kind == "zam" else HRLedger.ACTION_MENU, row)
			if kind == "cikar-eksi":
				# Tazminat kasayı sıfırın altına geçirsin: yalnız sonuç değeri kırmızıya döner.
				GameState.set_cash(1200)
			if kind == "cikar" or kind == "cikar-eksi":
				# Popover yerleşimi iki kare bekliyor (HRPopover.open_at).
				await get_tree().process_frame
				await get_tree().process_frame
				await get_tree().create_timer(0.2).timeout
				var layer: Node = get_tree().get_root().find_child("PanelLayer", true, false)
				if layer == null or not _press_button_labelled(layer, TranslationServer.translate("HR_CARD_FIRE")):
					_shot_fail("[HRShot] menüde İŞTEN ÇIKAR bulunamadı")
					return
	await _finish_shot("hr_shot_%s" % kind, 0.5)


func _seed_hr_roster() -> void:
	# Üç departman: Ürün Geliştirme'nin üç alt bölümü dolu, Satış'ta bir kişi, Müşteri BOŞ
	# (empty-state satırı da görünsün). Biri izinde, biri tükeniyor, biri bugün başlamış.
	# Huylar registry'nin _validate_shape kuralına uyar (en az 1, en çok 2 pozitif, en çok 1
	# negatif). key/rest: HRConstants.seed_skills rol profilini kurar.
	var seeds: Array = [
		{"name": "Elif Demir", "role": HRConstants.ROLE_PRODUCT_MANAGER, "salary": 9800,
			"key": 7, "rest": 4, "lead": 6, "morale": 72,
			"traits": ["takes_them_under"]},
		{"name": "Deniz Arslan", "role": HRConstants.ROLE_DESIGNER, "salary": 7400,
			"key": 6, "rest": 3, "lead": 2, "morale": 38,
			"traits": ["last_one_out"]},
		{"name": "Mert Yıldız", "role": HRConstants.ROLE_DEVELOPER, "salary": 11200,   # LOC-DATA debug seed / id
			"key": 8, "rest": 4, "lead": 3, "morale": 61,
			"traits": ["loyal"]},
		{"name": "Selin Kaya", "role": HRConstants.ROLE_TESTER, "salary": 6900,
			"key": 5, "rest": 3, "lead": 1, "morale": 22,
			"traits": ["double_checker"]},
		{"name": "Burak Şahin", "role": HRConstants.ROLE_SALES_REP, "salary": 8300,   # LOC-DATA debug seed / id
			"key": 6, "rest": 3, "lead": 2, "morale": 55,
			"traits": ["picks_it_up_fast"]},
	]
	for ordinal in seeds.size():
		var seed_data: Dictionary = seeds[ordinal]
		var emp := Character.new()
		emp.id = "char_emp_shot_%d" % ordinal
		emp.character_name = String(seed_data["name"])
		emp.role = String(seed_data["role"])
		emp.category = "employee"
		emp.monthly_salary = int(seed_data["salary"])
		emp.morale = int(seed_data["morale"])
		emp.role_stats = HRConstants.seed_skills(emp.role,
			int(seed_data["key"]), int(seed_data["rest"]), int(seed_data["lead"]))
		emp.traits.assign(seed_data["traits"] as Array)
		emp.status = HRConstants.STATUS_ACTIVE
		CharacterRegistry.add(emp)
		# add() bugünü damgalar; kıdem satırının üç dalı görünsün diye geriye alınıyor.
		emp.hire_day = maxi(1, GameState.day - (ordinal * 4))
	HRMoraleSystem.send_on_leave(CharacterRegistry.get_character("char_emp_shot_2"),
		HRConstants.LEAVE_WEEKS, false)
	CharacterRegistry.get_character("char_emp_shot_4").hire_day = GameState.day   # YENİ etiketi


# --ending-shot=<key>: a representative Run Ledger on the newspaper EndingScene. <key> is an
# ending_id, plus bankruptcy1/2/3 (phase-layered), series_a_agg (Aggressive terms) and
# bootstrap_milestone (the EA / full milestone paper). Also runs the real share export, so
# every shot verifies the paper crop bounds.
func _run_ending_shot(key: String) -> void:
	_begin_shot()
	_seed_run_reproducible()
	GameState.company_name = "PromptPilot"
	GameState.founder_name = "Deniz"
	GameState.day = 23
	GameState.set_flag("mvp_version", 3)
	GameState.set_flag("mvp_version_history", [{"version": 1, "day": 6}, {"version": 2, "day": 13}, {"version": 3, "day": 20}])
	GameState.run_customers_lost = 3
	GameState.run_hires = 4
	GameState.run_pitches = 2
	GameState.run_sheets_won = 1
	GameState.vc_rejections = 1
	GameState.run_peak_mrr = 8200
	GameState.cash = 24000

	# The MÜŞTERİ and ÇALIŞAN cells read live registries, not the run counters. The customer
	# seam bumps run_customers_signed and reflects MRR, so both are written after it.
	var companies := ["Ege Sigorta", "Kule Lojistik"]
	for ci in companies.size():
		var pr := Prospect.new()
		pr.id = "shot_cust_%d" % ci
		pr.company_name = companies[ci]
		pr.industry = "insurance"
		pr.star = 1
		pr.pain_feature_id = "ai_vec_filter"
		SalesSystem.add_b2b_customer(pr, 20, 50, 70)   # 20 seats x $50 = $1.000
	GameState.run_customers_signed = 9
	GameState.mrr = 6400
	var emp_names := ["Burcu Çetin", "Mert Aydın", "Selin Koç"]   # LOC-DATA debug seed / id
	for i in emp_names.size():
		var emp := Character.new()
		emp.id = "char_shot_emp_%d" % i
		emp.character_name = emp_names[i]
		emp.role = HRConstants.ROLE_DEVELOPER
		emp.category = "employee"
		emp.monthly_salary = 6000
		emp.role_stats = HRConstants.seed_skills(emp.role, 5, 4)
		emp.traits = ["last_one_out"]
		CharacterRegistry.add(emp)

	var ending_id := key
	GameState.phase = 3
	match key:
		"bankruptcy1", "bankruptcy2", "bankruptcy3":
			ending_id = "bankruptcy"
			GameState.phase = int(key.right(1))
		"series_a_close", "series_a_agg":
			ending_id = "series_a_close"
			var aggressive := key == "series_a_agg"
			GameState.run_valuation_m = 22
			GameState.run_equity_pct = 32 if aggressive else 18
			GameState.run_board_seats = 2 if aggressive else 1
			GameState.run_board_veto = aggressive
			GameState.run_investment_amount = int(round(22_000_000.0 * GameState.run_equity_pct / 100.0))
		"running_on_fumes":
			# The soft cap's paper: a two-year run with one unsigned offer on the table.
			GameState.day = TimeModel.ticks(EndingsSystem.SOFT_CAP_WEEK)
			GameState.active_sheets.append(VCPitchSystem._make_sheet("anchor", GameState.day - 1))
		"bootstrap_milestone":
			# A milestone only exists outside the demo; pin EA unless --build= named one.
			ending_id = "profitable_bootstrap"
			if EndingsSystem.build_scope() == EndingsSystem.BUILD_DEMO:
				EndingsSystem.build_scope_override = EndingsSystem.BUILD_EA

	var data: Dictionary = EndingsSystem._build_ending_data(ending_id, {})
	if key == "bootstrap_milestone":
		data["mode"] = EndingsSystem.MODE_MILESTONE
	var scene: Control = _on_shot_layer(ENDING_MODAL.instantiate())
	scene.populate(data)
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().create_timer(0.4).timeout
	_save_shot("ending_shot_%s" % key)
	if data.get("mode", "") == EndingsSystem.MODE_MILESTONE:
		await scene._export_paper_png()
	else:
		# Sharing writes the paper's PNG and shows its toast: a second frame.
		await scene._on_share()
		await get_tree().create_timer(0.4).timeout
		_save_shot("ending_shot_%s_share" % key)
	get_tree().quit()


# --product-shot=<c1..c5|cards|flow|edge:<name>|live:<scenario>>: the Product tab. The first four
# are fed by the debug fixture source (scripts/debug/product_fixtures.gd, edge names live there)
# through the shell's debug relays, the same path an MCP session takes; flow starts from c1 and
# saves one frame after each of start, advance and plan_next; edge:goal_menu opens the quarter goal's
# menu with a click on its strip, edge:voices_open scrolls the areas to the open one. live draws
# ProductModel.live() over a run seeded through SprintSystem (_seed_product_live); live:pick_named is
# the type picker with B2C, a type and a name picked; live:decision_paper presses the decision row's
# Karara git, so the frame is Olaylar on the sprint paper.
func _run_product_shot(id: String) -> void:
	_begin_shot()
	_seed_run_reproducible()
	var stem: String = "product_shot_" + id.replace(":", "_")
	if id.begins_with("live:"):
		_seed_product_live(id.trim_prefix("live:"))
		await _mount_shot_shell()
		EventBus.tab_changed.emit("product")
		if id == "live:pick_named":
			var picker: TypePicker = _shell.find_children("*", "TypePicker", true, false)[0]
			picker._pick_market("b2c")
			await get_tree().process_frame
			picker._pick_type("note_tool")
		if id == "live:decision_paper":
			await get_tree().process_frame
			for go: Button in _shell.find_children("*", "Button", true, false):
				if go.text == tr("PRODUCT_GO_DECISION"):
					go.pressed.emit()
					break
		await _finish_shot(stem)
		return
	await _mount_shot_shell()
	_shell.debug_product_apply("c1" if id == "flow" else id.trim_prefix("edge:"))
	if id == "edge:voices_open":
		# The areas column starts at the open area's own row, so its voices are in view.
		await get_tree().process_frame
		var areas: AreaPanel = _shell.find_children("*", "AreaPanel", true, false)[0]
		for row: Control in areas.get_children():
			if row.get_meta(&"selected", false):
				(areas.get_parent().get_parent() as ScrollContainer).scroll_vertical = int(row.position.y)
	if id == "edge:goal_menu":
		await get_tree().process_frame
		var click := InputEventMouseButton.new()
		click.button_index = MOUSE_BUTTON_LEFT
		click.pressed = true
		(_shell.find_children("*", "QuarterView", true, false)[0] as QuarterView).get_child(0).gui_input.emit(click)
	if id != "flow":
		await _finish_shot(stem)
		return
	for kind in ["start", "advance", "plan_next"]:
		_shell.debug_product_act(kind)
		await get_tree().process_frame
		await get_tree().create_timer(0.4).timeout
		_save_shot("%s_%s" % [stem, kind])
	get_tree().quit()


## live:<pick|pick_named|plan|active|decision_paper|b2c_mvp|b2b_requests>. pick and pick_named leave the
## product untyped (the type picker). The rest choose a type, staff it with the HR shot roster and play
## through SprintSystem with only its own daily step ticking, so no card mounts: plan stops in Sprint 1
## planning with the lead's plan, active and decision_paper in its second week with a sprint paper on the
## desk, b2c_mvp on the CANLI v1.0 release note. b2b_requests signs two accounts once the faucet opens at
## MVP and plays one more sprint, so the next planning carries their request cards.
func _seed_product_live(scenario: String) -> void:
	if scenario.begins_with("pick"):
		return
	var b2b: bool = scenario == "b2b_requests"
	SprintSystem.choose_type("erp" if b2b else "note_tool", "Fatura" if b2b else "Notly")
	_seed_hr_roster()
	var day := func() -> void:
		GameState.advance_day()
		SprintSystem.daily_tick()
	var sprint := func() -> void:
		if SprintSystem.mode() == "release":
			SprintSystem.plan_next()
			SprintSystem.apply_lead()
			SprintSystem.start()
		while SprintSystem.mode() == "active":
			day.call()
	SprintSystem.apply_lead()
	if scenario == "plan":
		return
	SprintSystem.start()
	day.call()
	if scenario in ["active", "decision_paper"]:
		return
	for i in 12:
		sprint.call()
		if ProductState.is_live():
			break
	if not b2b:
		return
	for i in 2:
		var lead: Prospect = SalesFaucetSystem.spawn_prospect("mid", "event")
		SalesSystem.add_b2b_customer(lead, 12, 50, 85)
		ProspectRegistry.remove(lead.id)
	sprint.call()
	SprintSystem.plan_next()
	SprintSystem.apply_lead()


## Rows are [line id, tier, tier id to stamp, turn multiplier]. The readings
## (ProductState.axis_readings) multiply BOTH, so both are set.
func _seed_line_state(subtype: String, rows: Array) -> void:
	GameState.set_flag("mvp_sub_product_type_id", subtype)
	for row in rows:
		ProductState.set_line_tier(String(row[0]), int(row[1]))
		ProductState.stamp_step(String(row[2]), float(row[3]))


## The world every Satış shot stands on — one seed, so a meeting shot and a pipeline shot are
## pictures of the SAME company.
func _seed_sales_world() -> void:
	_seed_run_reproducible()
	GameState.founder_portrait = "founder_01"
	GameState.day = 9
	GameState.set_cash(48000)
	GameState.set_flag("mvp_shipped", true)
	GameState.set_flag("mvp_market_type", "b2b")
	_seed_line_state("erp", _ERP_SHIPPED_LINES)
	GameState.set_flag("mvp_launch_day", 6)
	ProductState.set_infra_provider("cloud")
	ProductState.set_infra_units(6)
	var founder: Character = CharacterRegistry.get_founder()
	founder.role_stats[HRConstants.AREA_SALES] = 6
	founder.role_stats[FounderConstants.SKILL_CHARISMA] = 4


## --vc-shot=<hunt|hunt_closed|hunt_meeting|hunt_seed|table|table_final|table_walk|table_other|seed_table|k10>:
## the Series A surfaces — the Hunt page (two offers and one queued; every fund closed; a meeting booked beside
## one offer; Traction with the seed door open), the term-sheet table in its states and the expired-offer
## decision card. Pushes go through the real table system with the SkillCheck debug force. A table's kind
## with ":shell" mounts it in the shell's ModalLayer, as the game does, over the shell (vc_shot_<kind>_shell).
func _run_vc_shot(spec: String) -> void:
	var kind: String = spec.get_slice(":", 0)
	var shelled: bool = spec.get_slice(":", 1) == "shell"
	_begin_shot()
	_seed_run_reproducible()
	GameState.company_name = "PromptPilot"
	GameState.set_flag("mvp_shipped", true)
	GameState.set_flag("mvp_market_type", "b2b")
	GameState.set_cash(330000)
	GameState.mrr = 125000
	GameState.set_phase(3)
	match kind:
		"hunt":
			# Two live offers, one queued behind them, one fund that said no.
			GameState.active_sheets.append(VCPitchSystem._make_sheet("anchor", GameState.day - 1))
			VCPitchSystem._vc("anchor")["status"] = "offered"
			GameState.active_sheets.append(VCPitchSystem._make_sheet("meridian", GameState.day))
			VCPitchSystem._vc("meridian")["status"] = "offered"
			VCPitchSystem._vc("bosphorus")["status"] = "pending_sheet"
			VCPitchSystem._vc("bosphorus")["pending_sheet"] = true
			VCPitchSystem._vc("nexus")["status"] = "rejected"
			GameState.vc_rejections = 1
		"hunt_closed":
			for pair in [["anchor", "rejected"], ["nexus", "walked"], ["bosphorus", "expired"], ["meridian", "rejected"]]:
				VCPitchSystem._vc(String(pair[0]))["status"] = String(pair[1])
			# Walking away and letting an offer lapse close a fund without counting as a no.
			GameState.vc_rejections = 2
		"hunt_meeting":
			GameState.active_sheets.append(VCPitchSystem._make_sheet("anchor", GameState.day))
			VCPitchSystem._vc("anchor")["status"] = "offered"
			VCPitchSystem._vc("nexus")["status"] = "rejected"
			GameState.vc_rejections = 1
			VCPitchSystem.request_meeting("bosphorus")
		"hunt_seed":
			GameState.set_phase(2)
			GameState.mrr = 22000
			GameState.seed_door_open_day = GameState.day
		"table", "table_final", "table_walk":
			var conv: int = 45 if kind == "table_walk" else (100 if kind == "table_final" else 83)
			VCPitchSystem._vc("bosphorus")["sheet_conviction"] = conv
			GameState.active_sheets.append(VCPitchSystem._make_sheet("bosphorus", GameState.day))
			TermSheetTableSystem.open("bosphorus", PitchConstants.STAGE_SERIES_A)
			GameState.set_flag("debug_skill_force", "fail")
			# Patience of two: one failed push is the investor's line, the second spends the
			# patience and the fund answers (final counter or walk-out).
			TermSheetTableSystem.select_lever("valuation")
			TermSheetTableSystem.push()
			if kind != "table":
				TermSheetTableSystem.select_lever("dilution")
				TermSheetTableSystem.push()
			print("[VcShot] table state=%s line=%s" % [
				TermSheetTableSystem._state, TermSheetTableSystem._line_key])
		"table_other":
			GameState.active_sheets.append(VCPitchSystem._make_sheet("anchor", GameState.day))
			GameState.active_sheets.append(VCPitchSystem._make_sheet("meridian", GameState.day))
			TermSheetTableSystem.open("anchor", PitchConstants.STAGE_SERIES_A)
			TermSheetTableSystem.show_other_offer()
		"seed_table":
			GameState.set_phase(2)
			GameState.mrr = 22000
			GameState.seed_sheet = SeedRoundSystem.make_seed_sheet("anchor", "standard", GameState.day)
			TermSheetTableSystem.open("anchor", PitchConstants.STAGE_SEED)
		"k10":
			# A sheet whose weeks ran out today: the decision card's moment.
			GameState.active_sheets.append(VCPitchSystem._make_sheet("meridian",
				GameState.day - TimeModel.ticks(PitchConstants.SHEET_VALIDITY_WEEKS)))
			VCPitchSystem._vc("meridian")["status"] = "offered"
		_:
			_shot_fail("[VcShot] unknown --vc-shot kind: %s" % kind)
			return
	if kind.begins_with("hunt"):
		await _mount_shot_shell()
		EventBus.tab_changed.emit("finance")
		await get_tree().process_frame
		EventBus.finance_subpage_requested.emit("yatirim")   # LOC-DATA sub-page id
	elif kind == "k10":
		var ctx: Dictionary = EventGate.bind_scope("funding.sheet_decision")
		if ctx.is_empty():
			_shot_fail("[VcShot] funding.sheet_decision did not bind (no decision-due sheet)")
			return
		_shot_pane("funding.sheet_decision", ctx)
	elif shelled:
		await _mount_shot_shell()
		_modal_layer().add_child(TERM_TABLE_SCENE.instantiate())
	else:
		_on_shot_layer(TERM_TABLE_SCENE.instantiate())
	await get_tree().process_frame
	await _finish_shot("vc_shot_%s%s" % [kind, "_shell" if shelled else ""], 0.5)


## First open answer of the live sales table; `last` walks on to the weakest (last) open one.
func _open_answer(last: bool) -> String:
	var picked: String = ""
	for a in (SalesMeetingSystem.view_state().get("answers", []) as Array):
		if bool((a as Dictionary).get("open", false)):
			picked = String((a as Dictionary).get("id", ""))
			if not last:
				break
	return picked


## The meeting room as the founder's trip leaves it, which the shots skip: `side` (CounterpartSystem
## people, lead first) at the table, and the founder in their chair, or at the lift unless `seated`.
func _stage_meeting_room(side: Array, seated := true) -> void:
	var view: Control = get_tree().get_first_node_in_group(&"office_view")
	view.load_layout("meet")
	view.cast.stage(side.map(func(q: Dictionary) -> Dictionary: return q.look),
		CharacterRegistry.get_founder().look, seated)


## A sales sitting with `p` in the panel over the meeting room, its opening drawn in full.
func _shot_sales_sitting(p: Prospect) -> void:
	_stage_meeting_room(CounterpartSystem.prospect_people(p))
	_open_sales_meeting(p.id)
	_meeting_panel.skip_playback()
	await get_tree().process_frame


## One of the founder's picks in the meeting panel, its playback skipped as a click would skip it.
func _shot_pick(id: String) -> void:
	_meeting_panel.pick(id)
	_meeting_panel.skip_playback()
	await get_tree().process_frame


## The sales table played to its end in the panel: each question's first open answer, or its last
## (the weakest) when `weakest`, and the die where every answer is locked. SAFETY_CAP_PROBES ends
## every table within six answers; the bound keeps a pick the panel refused from hanging the shot.
func _shot_play_sales(weakest: bool) -> void:
	for _i in 8:
		if SalesMeetingSystem.view_state().outcome != "":
			return
		var id := _open_answer(weakest)
		await _shot_pick(id if id != "" else SalesMeetingAdapter.SKIP)


## The table's cut to the offer taken through its Devam, into Perde 2 in the same panel (§5.1.1:
## the table turns into Perde 2 in the SAME scene). False, and the shot failed, when the table
## did not cut.
func _shot_act_two() -> bool:
	if SalesMeetingSystem.view_state().outcome != "won":
		_shot_fail("[MeetingShot] the table did not cut to the offer: no Perde 2 to open")
		return false
	_meeting_panel.proceed()
	_meeting_panel.skip_playback()
	await get_tree().process_frame
	return true


## A price picked on the panel's ruler, as a drag picks it.
func _shot_price(price: int) -> void:
	_meeting_panel._ruler.changed.emit(price)
	await get_tree().process_frame


## --meeting-shot's VC kinds: the room, the rolls (forced, so the room lands where the kind needs
## it; "" forces none) and the founder's picks. Each pick's step brings the next beat's options; a
## closing pick leaves its result card up.
const MEETING_SHOT_VC := {
	"open": [PitchConstants.STAGE_SERIES_A, "", []],
	"sorgu": [PitchConstants.STAGE_SERIES_A, "pass", ["b1_read", "b2_metrik"]],
	"sheet": [PitchConstants.STAGE_SERIES_A, "pass", ["b1_read", "b2_metrik", "b3_durust", "b4_ack"]],
	"callback": [PitchConstants.STAGE_SERIES_A, "pass", ["b1_read", "b2_metrik", "b3_gecistir", "b4_callback"]],
	"ret": [PitchConstants.STAGE_SERIES_A, "fail", ["b1_read", "b2_metrik", "b3_durust", "b4_leave"]],
	"seed": [PitchConstants.STAGE_SEED, "pass", ["b1_read", "b2_metrik", "b3_durust", "b4_ack"]],
	"long": [PitchConstants.STAGE_SERIES_A, "pass", ["b1_read", "b2_metrik", "b3_gecistir"]],
}


## --meeting-shot=<kind>: a sitting in the meeting panel over the meeting room, played through the
## panel as the founder plays it, each playback skipped.
## Sales, Perde 1 and the act change: probe = the first question; locked = on to a question with a
## locked answer and its reason line; won = played to the customer's cut, its Devam into the offer
## on screen; lost = played to the loss, its result card; handoff = past that Devam into Perde 2.
## VC, with the shot's fund (the founder moved this meeting once and rehearsed for it): open = Odayı
## Oku as the room opens, the HAFIZA row and the withdraw button; sorgu = the third beat, the
## rehearsed answer marked; sheet = a won room's result card; callback = a lukewarm room's callback
## and its condition; ret = a cold room's rejection, its cost and Frank on the way out; seed = the
## seed room's result card; long = a lukewarm room's closing beat under every earlier one, the most
## the panel holds (pair it with --shot-scale=1.25 for the narrowest dock).
func _run_meeting_shot(kind: String) -> void:
	_begin_shot()
	_seed_sales_world()
	if MEETING_SHOT_VC.has(kind):
		var spec: Array = MEETING_SHOT_VC[kind]
		GameState.set_phase(3 if spec[0] == PitchConstants.STAGE_SERIES_A else 2)
		GameState.mrr = 125000
		VCPitchSystem._vc(SHOT_FUND)["move_penalty"] = PitchConstants.MEETING_RESCHEDULE_PENALTY
		GameState.prep = {"vc_id": SHOT_FUND, "focus": "prova", "done_day": GameState.day}
		GameState.set_flag("debug_skill_force", spec[1])
		await _mount_shot_shell()
		_stage_meeting_room(CounterpartSystem.investor_people(SHOT_FUND))
		# A shot wires no signals: the fund's first view reaches the panel this way.
		EventBus.meeting_scene_requested.connect(_on_meeting_scene_requested)
		VCPitchSystem.begin_meeting(SHOT_FUND, spec[0])
		_meeting_panel.skip_playback()
		await get_tree().process_frame
		for id: String in spec[2]:
			await _shot_pick(id)
	else:
		if kind == "locked" or kind == "lost":
			# Yerel sağlayıcı ve K1 merdiveni: "Gücü göster" satırı kapanır ve gerekçesini yazar.
			ProductState.set_infra_provider("local")
			_seed_line_state("erp", [["line_erp_ledger", 1, "line_erp_ledger_k1", 0.75]])
		if kind == "lost":
			# Kayıp karesi gerçekten kaybetmeli: kurucunun Satış'ı ve Karizma'sı sıfır, ürün K1,
			# sağlayıcı yerel, lead 3★ (MISMATCH_PENALTY'nin en sert kademesi). İlk cevapta iğne
			# §5.1'in alt eşiğinin altına düşer.
			var founder: Character = CharacterRegistry.get_founder()
			founder.role_stats[HRConstants.AREA_SALES] = 0
			founder.role_stats[FounderConstants.SKILL_CHARISMA] = 0
		var plays_out: bool = kind in ["won", "lost", "handoff"]
		var p: Prospect = SalesFaucetSystem.spawn(3 if plays_out else 2, "faucet")
		await _mount_shot_shell()
		await _shot_sales_sitting(p)
		if kind == "locked":
			for _i in 4:
				var vs: Dictionary = SalesMeetingSystem.view_state()
				if vs.outcome != "" or (vs.answers as Array).any(func(a: Dictionary) -> bool: return not a.open):
					break
				await _shot_pick(_open_answer(false))
		elif plays_out:
			await _shot_play_sales(kind == "lost")
			if kind == "handoff" and not (await _shot_act_two()):
				return
	_probe_pause_interactivity(_meeting_panel, "meeting/" + kind)
	await get_tree().create_timer(0.5).timeout
	_save_shot("meeting_shot_%s" % kind)
	get_tree().quit()


## THE PAUSE PROBE. Speed 0 pauses the tree, and Godot keeps DRAWING a paused Control while
## refusing it input — a surface that looks perfect and eats every click. Neither the scene
## file nor a screenshot shows this, so the probe asks can_process() with the tree paused.
func _probe_pause_interactivity(root: Node, label: String) -> void:
	var was: bool = get_tree().paused
	get_tree().paused = true
	var buttons: Array[Node] = root.find_children("*", "Button", true, false)
	if root is Button:
		buttons.append(root)
	var live: int = 0
	for b in buttons:
		if b.can_process():
			live += 1
	print("[PauseProbe] %s root_can_process=%s buttons=%d live_under_pause=%d" % [
		label, str(root.can_process()), buttons.size(), live])
	get_tree().paused = was


## --negotiation-shot=<open|countered|insult|confirm>: Perde 2 in the meeting panel, after a Perde 1
## won in it. Diyalog yok (§5.3.1): the ruler, the patience boxes and the options' tone. open = as
## the act opens; countered = an offer under the insult line and their counter; insult = a price
## over the line picked on the ruler, the offer in its alert tone; confirm = the floor price offered
## and signed, its result card.
func _run_negotiation_shot(kind: String) -> void:
	_begin_shot()
	_seed_sales_world()
	var p: Prospect = SalesFaucetSystem.spawn(3, "faucet")
	await _mount_shot_shell()
	await _shot_sales_sitting(p)
	await _shot_play_sales(false)
	if not (await _shot_act_two()):
		return
	var insult_from: int = NegotiationSystem.view_state().insult_from
	match kind:
		"countered":
			await _shot_price(insult_from - 4)
			await _shot_pick("offer")
		"insult":
			# A table whose insult line sits past the band's top cannot show it: the shot brings it in.
			NegotiationSystem._insult_from = mini(insult_from, SalesConstants.SEAT_PRICE_MAX - 6)
			await _shot_price(NegotiationSystem._insult_from + 3)
		"confirm":
			await _shot_price(SalesConstants.SEAT_PRICE_MIN)
			await _shot_pick("offer")
	_probe_pause_interactivity(_meeting_panel, "negotiation/" + kind)
	await get_tree().create_timer(0.4).timeout
	_save_shot("negotiation_shot_%s" % kind)
	get_tree().quit()


func _shot_customer(id: String, cname: String, industry: String, phase: String, mrr: int, seats: int, weeks_ago: int, cs: bool) -> void:
	var c := Customer.new()
	c.id = id
	c.company_name = cname
	c.industry = industry
	c.market_type = "b2b"
	c.mrr = mrr
	c.seats = seats
	c.satisfaction = 25 if phase == "risk" else 72
	c.lifecycle_phase = phase
	c.acquired_on_day = GameState.day - weeks_ago
	c.scale = 3
	c.pain_feature_id = "saas_ops_integration"
	if cs:
		var rep := Character.new()
		rep.id = "char_cs_" + id
		rep.character_name = "Burcu Çetin"   # LOC-DATA debug seed / id
		rep.role = HRConstants.ROLE_CUSTOMER_REP
		rep.category = "employee"
		rep.role_stats = HRConstants.seed_skills(HRConstants.ROLE_CUSTOMER_REP, 5, 4)
		rep.traits = ["picks_it_up_fast"]
		CharacterRegistry.add(rep)
		c.assigned_to = rep.id
	c.update_health_from_satisfaction()
	CustomerRegistry.add(c)


# ============================================================================
#  SHELL + MODAL ROUTING
# ============================================================================

func _swap_to_shell_and_modal() -> void:
	if _flow != null:
		_flow.queue_free()
		_flow = null
	await _mount_shell()
	# The clock stays paused past the intro: the player's first decision (the build commit) is
	# what unpauses.
	_open_note("intro")


# The "repaint the world" seam: every shell child paints from GameState in its own _ready(),
# so state is restored first and the shell mounted second. A save load comes through here
# WITHOUT opening the intro, which belongs to a new run only.
func _mount_shell() -> void:
	_shell = GAME_SHELL.instantiate()
	add_child(_shell)
	_shell_mounted = true
	# One frame so TopBar/OfficeView finish their initial paint before anything mounts on top.
	await get_tree().process_frame
	_wire_modal_signals()


func _wire_modal_signals() -> void:
	_shell.get_node("PanelLayer").child_entered_tree.connect(_on_panel_mounted)
	if _event_signals_wired:
		return
	_event_signals_wired = true
	EventBus.modal_requested.connect(_on_event_modal_requested)
	EventBus.event_resolved.connect(_on_event_resolved)
	EventBus.event_set_aside.connect(_on_event_set_aside)
	EventBus.goto_tab_requested.connect(_on_goto_tab_requested)
	EventBus.tab_changed.connect(_on_tab_changed)
	EventBus.pitch_requested.connect(_on_pitch_requested)
	EventBus.settings_requested.connect(_on_settings_requested)
	EventBus.confirm_requested.connect(_on_confirm_requested)
	EventBus.run_ended.connect(_on_run_ended)
	EventBus.milestone_reached.connect(_on_milestone_reached)
	EventBus.summary_ready.connect(_on_summary_ready)
	EventBus.product_note_issued.connect(_on_product_note_issued)
	EventBus.meeting_scene_requested.connect(_on_meeting_scene_requested)
	EventBus.term_table_requested.connect(_on_term_table_requested)
	EventBus.system_menu_requested.connect(_on_system_menu_requested)
	EventBus.save_load_requested.connect(_on_save_load_requested)
	EventBus.quicksave_requested.connect(_on_quicksave_requested)
	EventBus.quickload_requested.connect(_on_quickload_requested)


## GameShell/ModalLayer, or null (with an error) when no shell is mounted.
func _modal_layer() -> CanvasLayer:
	var layer: CanvasLayer = _shell.get_node_or_null("ModalLayer") if _shell != null else null
	if layer == null:
		push_error("[Main] GameShell/ModalLayer missing — modal can't mount")
	return layer


## Hands the clock back after a pausing surface closes: to the speed it found (-1 → the last
## running speed). A pending event chain owns the pause itself, and a dead run stays frozen.
func _restore_speed(pre: int) -> void:
	if GameState.run_active and not EventGate.has_pending():
		EventBus.speed_change_requested.emit(pre if pre >= 0 else TimeManager.last_running_speed)


# THE DECISION GATE. A card on screen opens the inbox on it and holds the clock until it is
# answered (or, a paper the player picked up, put back on the desk). The hold is taken here, in the
# shell's handler, so a harness with no shell never freezes. While it holds, every other window
# reads only (WindowFrame), the panels close, the move and the map are off, and the requests below
# that would open something else are refused.

func _on_event_modal_requested(_event: GameEvent) -> void:
	if _in_transit:
		_card_waiting = true   # shown when the sitting closes
		return
	# The milestone paper stops the night's batch, whose card then pumps under it: the paper steps
	# aside for the decision and comes back once the gate closes.
	if _milestone_modal != null:
		_milestone_modal.queue_free()
		_milestone_modal = null
		TimeManager.release_clock(MILESTONE_CLOCK_HOLD)
	# A card that lands as a sitting closes, or on the period summary, finds the clock stopped by
	# that surface; the speed to hand back is the one from before it.
	if _pre_event_speed < 0:
		_pre_event_speed = _pre_dialogue_speed if _pre_dialogue_speed >= 0 \
			else (_pre_note_speed if _pre_note_speed >= 0 else TimeManager.current_speed)
	TimeManager.hold_clock(EVENT_CLOCK_HOLD)
	for panel in _shell.get_node("PanelLayer").get_children():
		panel.queue_free()
	get_tree().call_group(&"office_view", &"close_map")
	INBOX.show("active")


# event_resolved fires BEFORE the engine pumps its queue, so has_pending() still sees the next card
# and the clock stays stopped for it. A choice can also OPEN a cinematic surface (open_term_table
# runs before event_resolved), whose trip may still be on its way to it; that surface's close owns
# the restore. The period summary still open in the inbox restores the speed when it closes.
func _on_event_resolved(_event_id: String, _choice_idx: int) -> void:
	_on_gate_closed()


func _on_event_set_aside(_event_id: String) -> void:
	_on_gate_closed()


## The queue's next card opens on the pump that follows; the pump may drop every queued card, so
## with a queue the gate settles after it.
func _on_gate_closed() -> void:
	TimeManager.release_clock(EVENT_CLOCK_HOLD)
	if EventGate.has_pending():
		_settle_gate.call_deferred()
	else:
		_settle_gate()


## No decision on screen: the clock comes back and what waited for the gate opens. A sitting the
## answer opened owns both until it closes.
func _settle_gate() -> void:
	if EventGate.active_id() != "" or _term_table != null or _in_transit:
		return
	if _pre_note_speed < 0:
		_restore_speed(_pre_event_speed)
	_pre_event_speed = -1
	_open_after_gate()


## What waited for the gate: the card's goto_tab, then the milestone paper.
func _open_after_gate() -> void:
	if EventGate.active_id() != "" or not GameState.run_active:
		return
	if not _goto_after_gate.is_empty():
		EventBus.tab_changed.emit(_goto_after_gate[0])
		if _goto_after_gate[1] != "":
			EventBus.finance_subpage_requested.emit(_goto_after_gate[1])
		_goto_after_gate = []
	if not _milestone_paper.is_empty() and _milestone_modal == null:
		_on_milestone_reached(_milestone_paper[0], _milestone_paper[1])


## A card's goto_tab runs while the card is still on screen: the tab opens once nothing waits.
func _on_goto_tab_requested(tab_id: String, subpage: String) -> void:
	_goto_after_gate = [tab_id, subpage]
	_open_after_gate()


## Leaving the inbox puts an opened paper back on the desk (an interrupt stays: the gate slot shows
## it) and hands back the speed an intro or a summary paused, unless the player has set one since.
func _on_tab_changed(tab_id: String) -> void:
	if tab_id == "events":
		return
	EventGate.set_aside()
	if _pre_note_speed >= 0:
		if TimeManager.current_speed == 0:
			_restore_speed(_pre_note_speed)
		_pre_note_speed = -1


## The intro and the period summary open themselves in the inbox and pause the game: speed 0, not a
## hold, so the night's batch they land in runs on. A decision on screen keeps the inbox's selection.
func _open_note(kind: String) -> void:
	var notes: Array = GameState.messages.filter(func(m: Dictionary) -> bool: return m.kind == kind)
	if notes.is_empty() or EventGate.active_id() != "":
		return
	if _pre_note_speed < 0:
		_pre_note_speed = TimeManager.current_speed
	EventBus.speed_change_requested.emit(0)
	INBOX.show("m:" + String(notes[-1].id))


## Nothing opens on the panel layer while a decision waits.
func _on_panel_mounted(panel: Node) -> void:
	if EventGate.active_id() != "":
		panel.queue_free()


## A waiting decision lets through only the sitting its own chosen option opens.
func _gate_shut() -> bool:
	return EventGate.active_id() != "" and not EventGate.resolving()


## A cinematic surface opened from an event choice finds the clock held by the card; it releases
## the hold, inherits the card's stored speed and owns restoring it.
func _claim_pre_dialogue_speed() -> void:
	TimeManager.release_clock(EVENT_CLOCK_HOLD)
	if _pre_dialogue_speed < 0:
		_pre_dialogue_speed = _pre_event_speed if _pre_event_speed >= 0 else TimeManager.current_speed
	_pre_event_speed = -1


## The fund whose meeting week has come calls while a sitting fits the founder's day, when nothing
## else holds the founder; a call whose moment has passed stops ringing.
func _process(_delta: float) -> void:
	var invite := _meeting_invite()
	if invite == null:
		return
	match _call.get("kind", ""):
		"vc":
			if VCPitchSystem.call_waiting() != _call.id:
				_end_call()
		"sales":
			if SalesLedger.meeting_block_reason(_call.id) != "":
				_end_call()
		_:
			var caller: String = VCPitchSystem.call_waiting()
			if caller != "" and not _in_transit and _meeting_panel == null and _term_table == null \
					and EventGate.active_id() == "" and invite.can_ring():
				_ring_fund(caller)


## The fund whose meeting week has come is on the phone, and it waits for an answer as the meeting
## card did: the windows close, the call's card is open from the first ring and the clock stops
## under it. It can be put off once (VCPitchSystem.postpone_call); the card says what that costs.
func _ring_fund(vc_id: String) -> void:
	EventBus.tab_changed.emit("")
	var once: bool = VCPitchSystem.call_postponable()
	var fund: String = InvestorRegistry.get_investor(vc_id).display_name
	var lead: Dictionary = CounterpartSystem.lead(vc_id)
	_ring_call("vc", vc_id, fund, {"line": "MEETING_INVITE_VC", "open": true, "postpone": once,
		"caller": lead, "vc_id": vc_id,
		"args": {"fund": fund, "person": lead.name},
		"note": "MEETING_POSTPONE_ONCE" if once else "MEETING_POSTPONED_ONCE",
		"note_args": {"n": PitchConstants.MEETING_RESCHEDULE_PENALTY}, "toast": "MEETING_POSTPONED_VC"})
	_pre_dialogue_speed = TimeManager.current_speed
	EventBus.speed_change_requested.emit(0)


## "Görüşmeye git" on a prospect: the windows close and the phone rings in the office, in place of
## any call ringing; picking it up goes to the meeting, putting it off lets it ring on. With no
## office view (shots without the trip) the meeting opens at once.
func _on_pitch_requested(prospect_id: String) -> void:
	if EventGate.active_id() != "":
		return
	if _meeting_invite() == null:
		_open_sales_meeting(prospect_id)
		return
	EventBus.tab_changed.emit("")
	var p: Prospect = ProspectRegistry.get_prospect(prospect_id)
	var buyer: Dictionary = CounterpartSystem.prospect_people(p)[0]
	_ring_call("sales", prospect_id, p.company_name, {"line": "MEETING_INVITE_SALES", "open": false, "postpone": true,
		"caller": buyer, "vc_id": "",
		"args": {"company": p.company_name, "person": buyer.name},
		"note": "", "note_args": {}, "toast": "MEETING_POSTPONED_SALES"})


## Rings the office phone for a call of `kind` ("vc" | "sales") about `id` at `place` (MeetingInvite.ring);
## the top bar's slot names it next.
func _ring_call(kind: String, id: String, place: String, spec: Dictionary) -> void:
	var invite := _meeting_invite()
	_call = {"kind": kind, "id": id}
	if not invite.accepted.is_connected(_on_call_accepted):
		invite.accepted.connect(_on_call_accepted)
		invite.postponed.connect(_on_call_postponed)
	invite.ring(spec)
	get_tree().call_group(&"top_bar", &"show_meeting", "call", place)


func _end_call() -> void:
	_meeting_invite().stop()
	_call = {}
	get_tree().call_group(&"top_bar", &"show_meeting", "")


func _on_call_accepted() -> void:
	if _gate_shut():
		return
	var call := _call
	_call = {}
	get_tree().call_group(&"top_bar", &"show_meeting", "")
	if call.kind == "vc":
		VCPitchSystem.begin_meeting(call.id)
	else:
		_open_sales_meeting(call.id)


## A fund's call put off moves its meeting on and the clock runs again; a prospect's rings on.
func _on_call_postponed() -> void:
	if _call.kind != "vc":
		return
	VCPitchSystem.postpone_call()
	_end_call()
	_restore_speed(_pre_dialogue_speed)
	_pre_dialogue_speed = -1


## The office view's call, or null where there is no trip (shots, no office view).
func _meeting_invite() -> MeetingInvite:
	var view: Node = get_tree().get_first_node_in_group(&"office_view")
	return view.invite if _travel_on and view != null else null


## The founder's trip to an outside meeting, before its scene mounts: `side` sits across the table
## (CounterpartSystem people, lead first) and the tower's chip on the map reads `place` and the
## lead's name. The sitting is already open, so saving is refused and the founder is busy. The
## clock freezes and the tree runs, even under the card that opened the sitting, so the office
## walks and its lift and doors move; the windows step aside and the office view plays the walk
## out, the map and the walk in to the table. Then the clock stops at speed 0 for the scene, over
## the meeting room.
func _leave_office(side: Array, place: String) -> void:
	_in_transit = true
	_trip_label = tr("MEETING_TOWER_CHIP").format({"place": place, "person": side[0].name}) \
		if not side.is_empty() else place
	TimeManager.freeze_clock(TRAVEL_FREEZE)
	EventBus.speed_change_requested.emit(TimeManager.last_running_speed)
	get_tree().call_group(&"window_layer", &"set_veiled", true)
	get_tree().call_group(&"top_bar", &"show_meeting", "trip", place)
	var travel: Node = _office_travel()
	if travel != null:
		await travel.travel_out(side.map(func(q: Dictionary) -> Dictionary: return q.look), _trip_label)
	EventBus.speed_change_requested.emit(0)
	TimeManager.thaw_clock(TRAVEL_FREEZE)
	_in_transit = false
	get_tree().call_group(&"top_bar", &"show_meeting", "sitting", place)


## The sitting closed and its hours ran, in transit (a card they pumped waits): the trip home
## plays as the trip out did (the clock frozen, the tree running), the founder walking back in
## (not past the workday); then the windows come back and a card that arrived meanwhile is shown.
## A sitting that ended the run (a Series A signature) leaves the ending paper alone: no trip
## home, and the held card goes.
func _return_to_office() -> void:
	if not GameState.run_active:
		_in_transit = false
		_card_waiting = false
		return
	var travel: Node = _office_travel()
	if travel != null:
		TimeManager.freeze_clock(TRAVEL_FREEZE)
		EventBus.speed_change_requested.emit(TimeManager.last_running_speed)
		get_tree().call_group(&"top_bar", &"show_meeting", "home")
		await travel.travel_home(_trip_label)
		TimeManager.thaw_clock(TRAVEL_FREEZE)
	get_tree().call_group(&"top_bar", &"show_meeting", "")
	_in_transit = false
	get_tree().call_group(&"window_layer", &"set_veiled", false)
	if _card_waiting:
		_card_waiting = false
		_on_event_modal_requested(EventGate.active_card())


## The office view's trip player, or null where there is no trip (shots, no office view).
func _office_travel() -> Node:
	var view: Node = get_tree().get_first_node_in_group(&"office_view")
	return view.travel if _travel_on and view != null else null


# THE SITTING: a VC meeting, or a sales meeting and its negotiation, plays in the meeting panel
# docked over the meeting room the trip ends in; the panel's input shield keeps the shell around
# it inert. The tree is paused during the sitting, so the panel runs with process_mode ALWAYS.

## A VC sitting: VCPitchSystem.begin_meeting has opened it and sends its first view.
func _on_meeting_scene_requested(view_state: Dictionary) -> void:
	if _meeting_panel != null or _in_transit:
		return
	var vc: String = view_state.vc_id
	_open_meeting(VcMeetingAdapter.new(view_state), CounterpartSystem.investor_people(vc),
		InvestorRegistry.get_investor(vc).display_name)


## A sales sitting, opened before the trip: the meeting is counted and the founder busy from here.
## The table is read first, because open() can resolve it at once and a loss removes the prospect.
func _open_sales_meeting(prospect_id: String) -> void:
	if _meeting_panel != null or _in_transit:
		return
	if SalesLedger.meeting_block_reason(prospect_id) != "":
		return   # the tab draws the reason; reaching here at all is a UI bug, not a state one
	var p: Prospect = ProspectRegistry.get_prospect(prospect_id)
	var adapter := SalesMeetingAdapter.new(prospect_id)
	SalesMeetingSystem.open(prospect_id)
	_open_meeting(adapter, CounterpartSystem.prospect_people(p), p.company_name)


## The founder's trip to the sitting (`side` across the table, `place` on the map), then the panel
## over the meeting room with its people.
func _open_meeting(adapter: RefCounted, side: Array, place: String) -> void:
	_claim_pre_dialogue_speed()
	await _leave_office(side, place)
	var view: Node = get_tree().get_first_node_in_group(&"office_view")
	_meeting_panel = MeetingPanel.new()
	_meeting_panel.closed.connect(_close_meeting.bind(adapter))
	_modal_layer().add_child(_meeting_panel)
	_meeting_panel.open(adapter, view.cast)


## The sitting's hours run HERE, once the panel is gone, so the world the founder comes back to is
## already the one those hours made; in transit, so a card they pump waits for the trip home.
func _close_meeting(adapter: RefCounted) -> void:
	_meeting_panel.queue_free()
	_meeting_panel = null
	_in_transit = true
	adapter.end_sitting()
	await _return_to_office()
	_restore_speed(_pre_dialogue_speed)
	_pre_dialogue_speed = -1


func _on_settings_requested() -> void:
	if _settings_modal != null or _in_transit:
		return
	var modal_layer: CanvasLayer = _modal_layer()
	if modal_layer == null:
		return
	_pre_settings_speed = TimeManager.current_speed
	EventBus.speed_change_requested.emit(0)
	_settings_modal = SETTINGS_MODAL.instantiate()
	_settings_modal.dismissed.connect(_on_settings_dismissed)
	modal_layer.add_child(_settings_modal)


func _on_settings_dismissed() -> void:
	_settings_modal = null
	_restore_speed(_pre_settings_speed)
	_pre_settings_speed = -1


func _on_confirm_requested(config: Dictionary) -> void:
	if _confirm_modal != null:
		return
	var modal_layer: CanvasLayer = _modal_layer()
	# While a decision waits only a modal's own question passes (the system menu's quit).
	if modal_layer == null or (EventGate.active_id() != "" and modal_layer.get_child_count() == 0):
		return
	_pre_confirm_speed = TimeManager.current_speed
	EventBus.speed_change_requested.emit(0)
	_confirm_modal = (HR_ACTION_MODAL if String(config.get("modal", "")) == "hr_action"
		else CONFIRM_MODAL).instantiate()
	# A screen in the dark language opens its confirmation in it ("theme": true).
	if config.get("theme", false):
		_confirm_modal.theme = load(UiTokens.MENAJER_THEME)
	var on_confirm: Callable = config.get("on_confirm", Callable())
	if on_confirm.is_valid():
		_confirm_modal.confirmed.connect(on_confirm)
	# Optional third path: without alt_text the button stays hidden and nothing connects.
	var on_alt: Callable = config.get("on_alt", Callable())
	if on_alt.is_valid():
		_confirm_modal.alt_selected.connect(on_alt)
	_confirm_modal.dismissed.connect(_on_confirm_dismissed)
	modal_layer.add_child(_confirm_modal)
	_confirm_modal.populate(config)   # add_child SONRASI — @onready ref'ler ancak o zaman dolu


func _on_confirm_dismissed() -> void:
	_confirm_modal = null
	_restore_speed(_pre_confirm_speed)
	_pre_confirm_speed = -1


# game_shell emits system_menu_requested only when ModalLayer AND PanelLayer are empty and no
# decision waits: ESC over a waiting decision opens the inbox on it instead.
func _on_system_menu_requested() -> void:
	if _system_menu != null:
		return
	var modal_layer: CanvasLayer = _modal_layer()
	if modal_layer == null:
		return
	_pre_system_speed = TimeManager.current_speed
	EventBus.speed_change_requested.emit(0)
	_system_menu = SYSTEM_MENU_MODAL.instantiate()
	_system_menu.dismissed.connect(_on_system_menu_dismissed)
	modal_layer.add_child(_system_menu)


func _on_system_menu_dismissed() -> void:
	_system_menu = null
	_restore_speed(_pre_system_speed)
	_pre_system_speed = -1


# Stacks on the system menu, which already paused the game — so no speed capture of its own.
# ESC closes only the topmost (the last-added child sees _unhandled_input first).
func _on_save_load_requested(mode: String) -> void:
	if _save_load_modal != null:
		return
	var modal_layer: CanvasLayer = _modal_layer()
	if modal_layer == null:
		return
	_save_load_modal = SAVE_LOAD_MODAL.instantiate()
	_save_load_modal.dismissed.connect(func() -> void: _save_load_modal = null)
	_save_load_modal.load_requested.connect(_load_slot)
	modal_layer.add_child(_save_load_modal)
	_save_load_modal.populate(mode)   # add_child SONRASI — @onready ref'ler ancak o zaman dolu


## F5 says whether the run was saved, and when it stands; a refusal says why.
func _on_quicksave_requested() -> void:
	if not _shell_mounted:
		return
	var why: String = SaveManager.cannot_save_reason_key()
	if why == "" and not SaveManager.quicksave():
		why = "SAVE_ERR_WRITE"
	if why == "":
		get_tree().call_group(&"toast", &"show_toast", tr("SAVE_TOAST_SAVED"), _save_when("SAVE_TOAST_WHEN"),
			SAVED_GLYPH, UiTokens.D_pos())
	else:
		get_tree().call_group(&"toast", &"show_toast", tr("SAVE_TOAST_NOT_SAVED"), tr(why), NOT_SAVED_GLYPH,
			UiTokens.D_warn())


## F9 says it loaded on the shell it remounted.
func _on_quickload_requested() -> void:
	if _shell_mounted and await _load_slot(SaveManager.QUICK_SLOT_ID):
		get_tree().call_group(&"toast", &"show_toast", tr("SAVE_TOAST_LOADED"), _save_when("SAVE_TOAST_LOADED_WHEN"),
			LOADED_GLYPH, UiTokens.D_pos())


## The week and the hour the run stands at, as the top bar shows them.
func _save_when(key: String) -> String:
	return tr(key).format({"slot": tr("SAVE_QUICK_SLOT"), "week": int(GameState.get_date_dict().week),
		"time": "%02d:00" % GameState.current_hour})


# The single load path. The shell is torn down BEFORE state is applied, so initialize_run's
# "no listeners yet" assumption holds here too and no signal storm is needed. The save is read
# and validated before anything is touched: "file corrupt" in a half-torn world is the worst case.
# True once the loaded run stands on its new shell.
func _load_slot(slot_id: String) -> bool:
	# The same rule as saving: a decision in progress (event card, VC meeting, term table, sales
	# sitting, negotiation) is not carried over. F9 bypasses the menu gate and the ModalLayer
	# guard, so it reaches here during any sitting.
	if SaveManager.cannot_save_reason_key() == "SAVE_ERR_MODAL_OPEN":
		return false
	var payload: Dictionary = SaveManager.read_slot(slot_id)
	if not bool(payload.get("ok", false)):
		push_warning("[Main] yükleme reddedildi (%s): %s" % [slot_id, payload.get("error_key", "")])
		return false
	_teardown_run_ui()
	# queue_free is deferred; without a frame two GameShells would share the tree.
	await get_tree().process_frame
	if not SaveManager.apply_loaded_state(payload):
		push_error("[Main] yükleme durumu uygulanamadı (%s)" % slot_id)
		return false
	await _mount_shell()
	EventBus.game_loaded.emit(slot_id)
	# The save keeps the queue and nothing pumps it before the next tick: a waiting card shows now,
	# over the paused clock.
	EventGate.pump()
	return true


# The week's cards pump after the night batch, so a card lands on the open summary and inherits its
# saved speed; the inbox closing last restores it.
func _on_summary_ready(_data: Dictionary) -> void:
	_open_note("summary")


## The run's first monthly product note opens in the inbox once (Ar-Ge §6.1), as the intro does; the later
## ones arrive unread.
func _on_product_note_issued(_day: int) -> void:
	if RnDSystem.notes_issued() == 1:
		_open_note("rnd_note")


# Terminal: the ending paper never restores speed. EndingsSystem already flushed the queue and
# paused the clock, and TimeManager swallows unpause requests once run_active is false.
func _on_run_ended(_ending_id: String, ending_data: Dictionary) -> void:
	if not _call.is_empty():
		_end_call()
	if _ending_modal != null:
		return
	var modal_layer: CanvasLayer = _modal_layer()
	if modal_layer == null:
		return
	_ending_modal = ENDING_MODAL.instantiate()
	modal_layer.add_child(_ending_modal)
	_ending_modal.populate(ending_data)  # add_child SONRASI — @onready ref'ler ancak o zaman dolu


# The ending paper in milestone mode (EA / full): a win the run lives through. The clock is
# HELD while it is up, so a card, the period summary or settings closing on top of it cannot
# restart time behind it; DEVAM ET releases the hold and restores the player's speed. A decision
# is answered first: the paper would cover the inbox, and ANA MENÜ would refuse to save for a
# decision the player cannot see. It opens when the gate closes.
func _on_milestone_reached(milestone_id: String, data: Dictionary) -> void:
	if _ending_modal != null or _milestone_modal != null:
		return
	_milestone_paper = [milestone_id, data]
	if EventGate.active_id() != "":
		return
	var modal_layer: CanvasLayer = _modal_layer()
	if modal_layer == null:
		return
	_pre_milestone_speed = TimeManager.current_speed
	TimeManager.hold_clock(MILESTONE_CLOCK_HOLD)
	_milestone_modal = ENDING_MODAL.instantiate()
	_milestone_modal.continue_requested.connect(_on_milestone_continue)
	_milestone_modal.main_menu_requested.connect(_on_milestone_main_menu)
	modal_layer.add_child(_milestone_modal)
	_milestone_modal.populate(data)  # add_child SONRASI — @onready ref'ler ancak o zaman dolu


func _on_milestone_continue() -> void:
	if _milestone_modal != null:
		_milestone_modal.queue_free()
	_milestone_modal = null
	_milestone_paper = []
	TimeManager.release_clock(MILESTONE_CLOCK_HOLD)
	# The period summary still open in the inbox owns the pause and restores it itself. `> 0`, not
	# `>= 0`: DEVAM ET always resumes, so a paper that found the clock paused hands back the
	# last running speed.
	if _pre_note_speed < 0:
		_restore_speed(_pre_milestone_speed if _pre_milestone_speed > 0 else -1)
	_pre_milestone_speed = -1


## ANA MENÜ: keep the run in a save slot, then go where a run starts — today the boot flow,
## reached the way TEKRAR DENE reaches it (a process relaunch). A MANUAL slot, not the rolling
## autosave: the new run's third weekly autosave would overwrite the kept run.
func _on_milestone_main_menu() -> void:
	if _keep_run_for_main_menu() == "":
		var why: String = SaveManager.cannot_save_reason_key()
		if _milestone_modal != null:
			_milestone_modal.show_notice(tr(why if why != "" else "SAVE_ERR_WRITE"))
		return
	OS.set_restart_on_exit(true)
	get_tree().quit()


## The save half of ANA MENÜ, apart so the smoke can prove it without quitting the process.
## Returns the slot written, "" when the save was refused.
func _keep_run_for_main_menu() -> String:
	var slot: String = SaveManager.next_manual_slot_id()
	return slot if SaveManager.save_to_slot(slot) else ""


func _on_term_table_requested(vc_id: String, stage: String) -> void:
	if _term_table != null or _in_transit or _gate_shut():
		return
	var modal_layer: CanvasLayer = _modal_layer()
	if modal_layer == null:
		return
	if TermSheetTableSystem.open(vc_id, stage).is_empty():
		push_warning("[Main] term_table_requested for %s/%s with no live sheet" % [vc_id, stage])
		return
	_claim_pre_dialogue_speed()
	await _leave_office(CounterpartSystem.investor_people(vc_id), InvestorRegistry.get_investor(vc_id).display_name)
	_term_table = TERM_TABLE_SCENE.instantiate()
	_term_table.closed.connect(_close_term_table)
	modal_layer.add_child(_term_table)


# A signature ends the run (no restore and no return to the office: the ending owns the screen
# and the freeze); a walk-out leaves it alive and restores the pre-table speed. The table's hour
# runs once the scene is gone. A card's option that opened the table left what waits for its gate.
func _close_term_table() -> void:
	if _term_table != null:
		_term_table.queue_free()
		_term_table = null
	_in_transit = true
	TermSheetTableSystem.end_sitting()
	await _return_to_office()
	_restore_speed(_pre_dialogue_speed)
	_pre_dialogue_speed = -1
	_open_after_gate()


# --- Debug (debug builds only) ---

# F12 skips onboarding until the shell mounts.
func _unhandled_input(event: InputEvent) -> void:
	var key := event as InputEventKey
	if OS.is_debug_build() and key != null and key.pressed and not key.echo \
			and key.keycode == KEY_F12 and not _shell_mounted:
		_skip_to_shell()


func _skip_to_shell() -> void:
	GameState.initialize_run(_debug_payload())
	_swap_to_shell_and_modal()


# Shift+F4: tears down the shell and every modal and remounts OnboardingFlow from step 1, as a
# fresh launch presents it. The in-progress run is discarded (onboarding's only exit is a new
# run). SaveManager.reset_all_owners is the one reset path, shared with save loading.
func _on_debug_onboarding_retrigger() -> void:
	if _flow != null:
		return
	_teardown_run_ui()
	SaveManager.reset_all_owners()
	EventBus.speed_change_requested.emit(0)
	_mount_flow()


# Frees the shell (and its ModalLayer/PanelLayer children) and drops EVERY surface ref and
# speed tracker, so nothing from the outgoing run leaks into the next — a stale dialogue ref
# would misroute the next run's first meeting choice. Shared by Shift+F4 and save loading.
func _teardown_run_ui() -> void:
	if _shell != null:
		_shell.queue_free()
		_shell = null
	_shell_mounted = false
	_settings_modal = null
	_confirm_modal = null
	_ending_modal = null
	_milestone_modal = null
	_system_menu = null
	_save_load_modal = null
	_meeting_panel = null
	_term_table = null
	_in_transit = false
	_card_waiting = false
	_goto_after_gate = []
	_milestone_paper = []
	_call = {}
	_pre_event_speed = -1
	_pre_settings_speed = -1
	_pre_confirm_speed = -1
	_pre_note_speed = -1
	_pre_system_speed = -1
	_pre_dialogue_speed = -1
	_pre_milestone_speed = -1
