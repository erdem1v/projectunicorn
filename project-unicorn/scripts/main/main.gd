extends Node

# Main scene root — owns the launch lifecycle:
#   1. Pause the clock (TimeManager auto-starts at 1x in its own _ready) so onboarding keeps
#      day/hour at 1/09:00.
#   2. Mount OnboardingFlow. GameShell is NOT mounted upfront: its children paint from
#      GameState in _ready(), so it can only mount after initialize_run.
#   3. On flow completed (or F12 debug skip): swap the flow for GameShell and mount the
#      MentorIntroModal into GameShell/ModalLayer.
# It also routes every modal / cinematic surface and dispatches the debug launch flags.

const ONBOARDING_FLOW := preload("res://scenes/onboarding/OnboardingFlow.tscn")
const LANGUAGE_GATE := preload("res://scenes/onboarding/LanguageGate.tscn")
const GAME_SHELL := preload("res://scenes/main/GameShell.tscn")
const MENTOR_MODAL := preload("res://scenes/modals/MentorIntroModal.tscn")
const EVENT_MODAL := preload("res://scenes/modals/EventModal.tscn")
const SETTINGS_MODAL := preload("res://scenes/modals/SettingsModal.tscn")
const CONFIRM_MODAL := preload("res://scenes/modals/ConfirmModal.tscn")
# İK eylem modalı AYNI host'u kullanıyor (`confirm_requested`); config'deki
# `"modal": "hr_action"` yalnız SAHNEYİ seçiyor.
const HR_ACTION_MODAL := preload("res://scenes/modals/HRActionModal.tscn")
const ENDING_MODAL := preload("res://scenes/modals/EndingScene.tscn")
const MONTH_SUMMARY_MODAL := preload("res://scenes/modals/MonthSummaryModal.tscn")
const MEETING_SCENE := preload("res://scenes/modals/MeetingScene.tscn")
const TERM_TABLE_SCENE := preload("res://scenes/modals/TermSheetTableScene.tscn")
const SALES_MEETING_SCENE := preload("res://scenes/modals/SalesMeetingScene.tscn")
const NEGOTIATION_SCENE := preload("res://scenes/modals/NegotiationScene.tscn")
const SYSTEM_MENU_MODAL := preload("res://scenes/modals/SystemMenuModal.tscn")
const SAVE_LOAD_MODAL := preload("res://scenes/modals/SaveLoadModal.tscn")
const RND_CARD_MODAL := preload("res://scenes/modals/RnDCardModal.tscn")
const MILESTONE_CLOCK_HOLD := "milestone_paper"   # TimeManager hold reason while the paper is up

var _flow: Node = null
var _shell: Node = null
var _shell_mounted: bool = false
var _event_signals_wired: bool = false
# Currently-open surfaces (null = closed). Each pausing surface remembers the speed it
# found (-1 = none) and hands it back on close.
var _event_modal: Node = null
var _settings_modal: Node = null
var _confirm_modal: Node = null
var _ending_modal: Node = null       # mounts once, never dismissed back to gameplay
var _milestone_modal: Node = null    # the same paper in milestone mode (EA / full)
var _month_modal: Node = null
var _meeting_scene: Node = null
var _term_table: Node = null
var _sales_meeting: Node = null      # Satış §5.0
var _system_menu: Node = null
var _save_load_modal: Node = null
# Speed from BEFORE the first event of a chain: cascading events re-enter the handler with
# the clock already paused by the previous card, so only the first capture counts.
var _pre_event_speed: int = -1
var _pre_settings_speed: int = -1
var _pre_confirm_speed: int = -1
var _pre_system_speed: int = -1
var _pre_month_speed: int = -1
var _pre_dialogue_speed: int = -1
var _pre_milestone_speed: int = -1
# Ar-Ge kartı: aynı anda en fazla bir tane. Bir keşif ile koşunun ilk raporu aynı güne
# düşebilir ve iki üst üste scrim karartmayı ikiye katlar; ikincisi bu kuyrukta bekler.
var _rnd_card: Node = null
var _rnd_card_queue: Array[Dictionary] = []

var _tempo_last_msec: int = 0   # --tempo-probe: real-clock stamp of the previous day boundary

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
		# master_theme.tres is generated from UiTokens by hand; a forgotten regen is caught
		# only here. An unstamped .tres reads 0 and warns too.
		var proj_theme: Theme = ThemeDB.get_project_theme()
		if proj_theme != null:
			var baked_stamp: int = proj_theme.get_constant(&"stamp", &"UiTokensStamp")
			if baked_stamp != UiTokens.THEME_STAMP:
				push_warning("[Theme] master_theme.tres BAYAT: gömülü damga %d != UiTokens.THEME_STAMP %d — regen: godot --headless --path . -s res://scripts/theme/build_theme.gd" % [baked_stamp, UiTokens.THEME_STAMP])
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
#  DEBUG LAUNCH FLAGS (debug builds only; the list lives in CLAUDE.md §8)
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

	# --run-log=<preset>:<days>:<mode>[:<seed>]. "sim" finishes inside run(); the real-clock
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
		"--probe-shot": _run_probe_shot,
		"--display-check": _run_display_check,
	}
	for flag in bare:
		if flag in cmdline:
			(bare[flag] as Callable).call()
			return true

	var valued: Dictionary = {
		"--event-lint=": func(v: String) -> void: _quit_with(EvLint.run(v == "baseline")),
		"--why-fire=": _run_why_fire,
		"--event-harness=": func(v: String) -> void: _quit_with(EvHarness.run(v)),
		"--tempo-probe=": func(v: String) -> void: _run_tempo_probe(int(v)),
		"--render-probe=": _run_render_probe,
		"--b2b-shot=": _run_b2b_shot,
		"--event-shot=": _run_event_shot,
		"--meeting-shot=": _run_meeting_shot,
		"--vc-shot=": _run_vc_shot,
		"--negotiation-shot=": _run_negotiation_shot,
		"--sales-shot=": _run_sales_shot,
		"--product-shot=": _run_product_shot,
		"--ending-shot=": _run_ending_shot,
		"--hr-shot=": _run_hr_shot,
		"--finance-shot=": _run_finance_shot,
		"--font-spec=": _run_font_spec,
		"--tab-shot=": _run_tab_shot,
		"--modal-shot=": _run_modal_shot,
		"--onboard-shot=": func(v: String) -> void: _run_onboard_shot(int(v)),
		"--theme-audit=": _run_theme_audit,
		"--oda-shot=": _run_oda_shot,
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
# NOT spelled with "-shot"/"audit"/"smoke"/"spec", the substrings the inert guard and
# SaveManager's harness sniffer match on. Asserting against DisplayServer is the point: "the
# window is 1600×900", not "we wrote 1600×900 somewhere".
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


# --render-probe[=<tab id>] mounts the real shell and prints FRAME COST and TEXTURE/VIDEO
# MEMORY, then quits — the number a screenshot cannot give. VSYNC IS FORCED OFF or every
# frame would measure the monitor's refresh rate; safe because DisplaySettings._is_harness_arg
# knows this flag, so the player's stored vsync is never touched.
func _run_render_probe(tab_id: String) -> void:
	_begin_shot()
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	_seed_theme_surface()
	await _mount_shot_shell()
	EventBus.tab_changed.emit(tab_id)
	await get_tree().create_timer(0.4).timeout

	# The first frames pay shader compilation and texture upload — with mipmaps the upload is
	# the very thing under test, so averaging them in would misprice the steady state.
	for _i in RENDER_PROBE_WARMUP:
		await get_tree().process_frame

	var sorted_ms: Array = []
	for _i in RENDER_PROBE_FRAMES:
		var t0: int = Time.get_ticks_usec()
		await get_tree().process_frame
		sorted_ms.append(float(Time.get_ticks_usec() - t0) / 1000.0)
	sorted_ms.sort()
	var total: float = 0.0
	for v in sorted_ms:
		total += float(v)
	var win: Vector2i = get_window().size

	print("RENDER_PROBE_BEGIN")
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


# --tempo-probe=<speed idx> runs the REAL clock headless and prints one line per day boundary,
# so seconds-per-day can be stopwatched; the smoke drives ticks directly and cannot measure it.
# The STATE line must be identical across speeds for the same seed (tick purity). Day 1 is
# only 15 in-game hours, so its boundary just starts the stopwatch.
func _run_tempo_probe(idx: int) -> void:
	if idx <= 0 or idx >= TimeManager.SECONDS_PER_DAY.size():
		print("TEMPO ERROR bad speed index %d" % idx)
		get_tree().quit()
		return
	var stop_day: int = 6
	_seed_run_reproducible()
	# Give the HOURLY path real work — build effort, B2C audience flow, post-ship wear and bug
	# accrual — because that is where a speed-coupled bug would surface. mvp_shipped is
	# load-bearing: SalesSystem.hourly_tick gates the whole B2C half on it and ProductSystem
	# gates post-ship wear on it. Real bools, not strings: event conditions compare via bool().
	GameState.set_cash(50000)
	GameState.set_flag("mvp_shipped", true)
	GameState.set_flag("mvp_market_type", "b2c")
	GameState.set_flag("mvp_sub_product_type_id", "ai_assistant")
	# Wear rate reads _shipped_total_complexity(); with no components it runs at WEAR_FLOOR.
	GameState.set_flag("mvp_components", ["ai_assistant_chat", "ai_assistant_memory"])
	GameState.set_flag("mvp_innovation", 20.0)
	GameState.set_flag("mvp_stability", 25.0)
	GameState.set_flag("mvp_experience", 22.0)
	GameState.set_flag("mvp_version", 2)
	GameState.set_flag("mvp_product_name", "Nova")
	GameState.set_flag("b2c_audience", 4000)
	SalesSystem.open_b2c_paid_tier(15)   # makes MRR derive hourly too
	ProductSystem.start_build("ai_assistant",
		["ai_assistant_chat", "ai_assistant_memory"], "", "Nova")
	# Design rounds chain by themselves; take the development seat as soon as it is offered so
	# effort keeps flowing for the whole window.
	for i in 24 * 30:
		if ProductSystem.get_active_build() == null or ProductSystem.can_enter_development():
			break
		ProductSystem.hourly_tick(i % 24)
	ProductSystem.enter_development()
	print("TEMPO START speed=%d want_ms=%d" % [idx, int(TimeManager.SECONDS_PER_DAY[idx] * 1000.0)])
	EventBus.day_advanced.connect(func(day: int) -> void:
		var now: int = Time.get_ticks_msec()
		if _tempo_last_msec > 0:
			print("TEMPO speed=%d day=%d delta_ms=%d" % [idx, day, now - _tempo_last_msec])
		_tempo_last_msec = now
		var build: FeatureBuild = ProductSystem.get_active_build()
		var efor: float = build.efor_spent if build != null else 0.0
		print("TEMPO STATE day=%d cash=%d mrr=%d brand=%d rep=%d aud=%.4f efor=%.4f" % [
			day, GameState.cash, GameState.mrr, GameState.brand, GameState.reputation,
			float(GameState.get_flag("b2c_audience", 0.0)), efor])
		if day >= stop_day:
			print("TEMPO DONE speed=%d" % idx)
			get_tree().quit()
	)
	EventBus.speed_change_requested.emit(idx)


# ============================================================================
#  SCREENSHOT HARNESSES (windowed, 1920×1080 unless --shot-size; PNGs to user://)
# ============================================================================

## Common opening of every shot. The window drops to windowed mode first: the default mode is
## borderless, where a size assignment is silently swallowed. Headless makes all of it a no-op.
func _begin_shot() -> void:
	get_tree().paused = false
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	var win_size: Vector2i = _shot_size_override(Vector2i(1920, 1080))
	get_window().size = win_size
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
## of one screen sit side by side. Read from the locale itself, however it got set.
func _shot_path(basename: String) -> String:
	return "user://%s%s.png" % [basename, "_en" if TranslationServer.get_locale().begins_with("en") else ""]


func _save_shot(basename: String) -> void:
	var path: String = _shot_path(basename)
	get_viewport().get_texture().get_image().save_png(path)
	print("[Shot] saved %s" % ProjectSettings.globalize_path(path))


func _finish_shot(basename: String, settle: float = 0.4) -> void:
	await get_tree().process_frame
	await get_tree().create_timer(settle).timeout
	_save_shot(basename)
	get_tree().quit()


func _shot_fail(msg: String) -> void:
	push_error(msg)
	get_tree().quit(1)


## --b2b-shot=<retention|retention_capped|escalation|expansion|deal|angel|weekly>: one
## factory-built card in a real EventModal.
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
			c.acquired_on_day = GameState.day - (B2BConstants.EXPANSION_MATURE_DAYS + 1)
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
		"weekly":
			# §7.3 haftalık özet: bilgi kartı karar giysisi taşımaz ve satır taşır.
			CustomerRegistry.set_lifecycle_phase(c.id, "active")
			SalesSystem.record_sales_event("founder_close", "", c.company_name, c.mrr)
			var second := Prospect.new()
			second.id = "lead_weekly_2"   # LOC-DATA debug seed / id
			second.company_name = "Kuzey İnşaat"   # LOC-DATA debug seed / id
			second.industry = "construction"   # LOC-DATA debug seed / id
			second.star = 3
			var c2: Customer = SalesSystem.add_b2b_customer(second, 24, 55, 70, "sales_rep:shot")
			if c2 != null:
				SalesSystem.record_sales_event("auto_close",
					"Burcu Cetin", c2.company_name, c2.mrr)   # LOC-DATA debug seed / id
			card_id = "sales.weekly_summary"
			scoped = false
		_:
			CustomerRegistry.set_lifecycle_phase(c.id, "risk")
			CustomerRegistry.set_churn_countdown(c.id, 8)
			if kind == "retention_capped":   # LOC-DATA debug seed / id
				# Both discounts spent: the row renders locked-visible with its reason line.
				CustomerRegistry.set_retain_discounts(c.id, B2BConstants.RETAIN_DISCOUNT_MAX_USES)
	var ev: GameEvent = EventGate.render(card_id, EventGate.bind_scope(card_id) if scoped else {})
	_on_shot_layer(EVENT_MODAL.instantiate()).populate(ev)
	await get_tree().process_frame
	await _finish_shot("b2b_shot_%s" % kind, 0.35)


## --event-shot=<card id>: any catalogued card, `version_scope: fixture` ones included.
func _run_event_shot(event_id: String) -> void:
	_begin_shot()
	_seed_run_reproducible()
	if not EventGate.is_catalogued(event_id):
		_shot_fail("[EventShot] no card with id: %s" % event_id)
		return
	var ev: GameEvent = EventGate.render(event_id, EventGate.bind_scope(event_id))
	if ev == null:
		_shot_fail("[EventShot] could not render card: %s" % event_id)
		return
	_on_shot_layer(EVENT_MODAL.instantiate()).populate(ev)
	await get_tree().process_frame
	await _finish_shot("event_shot_%s" % event_id, 0.35)


## --sales-shot=<pipeline|desk|b2c>. `b2c` photographs §3.1's locked pipeline with its reason line.
func _run_sales_shot(kind: String) -> void:
	_begin_shot()
	_seed_sales_world()
	GameState.day = 95
	GameState.set_flag("mvp_live_bug_count", 12)  # risk reason → "sık kesinti şikayeti"
	if kind == "b2c":
		GameState.set_flag("mvp_market_type", "b2c")
	else:
		for star in [1, 2, 3]:
			SalesFaucetSystem.spawn(star, "faucet")
	if kind == "desk":
		# A rep on the desk, mid-processing, so the band row and the working line both draw.
		var rep := Character.new()
		rep.id = "char_sr_shot"
		rep.character_name = "Kerem Aydın"   # LOC-DATA debug seed / id
		rep.role = HRConstants.ROLE_SALES_REP
		rep.category = "employee"
		rep.level = HRConstants.LEVEL_MID
		rep.monthly_salary = 3200
		rep.morale = 62
		rep.hire_day = GameState.day - 30
		rep.role_stats = {HRConstants.AREA_SALES: 5}
		CharacterRegistry.add(rep)
		CharacterRegistry.assign_job(rep.id, HRConstants.JOB_SALES)
		SalesRepSystem.daily_tick()
	_shot_customer("co_kuzey", "Kuzey İnşaat", "construction", "active", 1000, 12, 90, false)   # LOC-DATA debug seed / id
	_shot_customer("co_palmiye", "Palmiye Holding", "insurance", "active", 1500, 16, 150, true)
	_shot_customer("co_aras", "Aras Klinik", "health", "onboarding", 700, 6, 10, false)
	_shot_customer("co_ege", "Ege Sigorta", "insurance", "risk", 1000, 12, 60, false)
	CustomerRegistry.set_churn_countdown("co_ege", 8)
	_shot_customer("co_nordica", "Nordica", "logistics", "expansion", 2000, 20, 180, false)
	# Monthly strip figures: gained 1 / lost 2 / net -1.
	GameState.run_customers_signed = 5
	GameState.run_customers_lost = 2
	GameState.month_ledger = {"customers_signed": 4, "customers_lost": 0}
	SalesSystem.reflect_mrr()
	await _mount_shot_shell()
	EventBus.tab_changed.emit("sales")
	await _finish_shot("sales_shot_%s" % kind)


# --font-spec=<a|b|c|c-opsz> — the type specimen: identical real-game content in one candidate
# font set. Seeds no game state. The candidate TTFs live in user://font_spec/ (outside the
# repo); load() rather than preload() keeps the debug scene off the normal boot path.
func _run_font_spec(set_id: String) -> void:
	_begin_shot()
	var spec: Control = _on_shot_layer(load("res://scenes/debug/FontSpecimen.tscn").instantiate())
	if not spec.build(set_id):
		get_tree().quit(1)
		return
	await get_tree().process_frame
	await _finish_shot("font_spec_%s" % set_id, 0.35)


# Theme-matrix shots (--tab-shot / --modal-shot / --onboard-shot / --theme-audit) cover the
# UNSTYLED controls the theme's base-type defaults reach. They share one seed so a textual
# audit and a screenshot of the same tab verify each other.
func _seed_theme_surface() -> void:
	_seed_run_reproducible()
	GameState.day = 95
	GameState.set_flag("mvp_shipped", true)
	GameState.set_flag("mvp_market_type", "b2b")
	GameState.set_flag("mvp_sub_product_type_id", "saas_ops")
	GameState.set_flag("mvp_innovation", 45.0)
	GameState.set_flag("mvp_stability", 70.0)
	GameState.set_flag("mvp_experience", 45.0)
	GameState.set_flag("mvp_live_bug_count", 12)
	_seed_hr_roster()
	_shot_customer("co_kuzey", "Kuzey İnşaat", "construction", "active", 1000, 12, 90, false)   # LOC-DATA debug seed / id
	_shot_customer("co_ege", "Ege Sigorta", "insurance", "risk", 1000, 12, 60, false)
	_shot_customer("co_nordica", "Nordica", "logistics", "expansion", 2000, 20, 180, false)
	PitchSystem.spawn_prospect("small", "find")
	PitchSystem.spawn_prospect("mid", "find")
	SalesSystem.reflect_mrr()


## Faz 2 sinyal fikstürü: dört artıda ay kapanışı, +%15/ay (üç büyüme ayı).
func _seed_signal_months() -> void:
	GameState.set_phase(2)
	GameState.month_history.clear()
	var start_day: int = 1
	for m in [12000, 13900, 16000, 18400]:
		GameState.push_month_close({"start_day": start_day, "end_day": start_day + 29, "mrr_close": m,
			"income": m, "expense": 9000, "net": m - 9000, "red_days": 0})
		start_day += 30


# --oda-shot=<day|evening|night|dawn|event|tab|tour|hover|milestones|market1|market2|signal|build>
# (build = Build Bar monitor face, --build-state selects its state). MentorIntro is not
# mounted, so the intro tour never touches the player's Settings flag except under `tour`.
func _run_oda_shot(kind: String) -> void:
	_begin_shot()
	match kind:
		"market1":   # ürün piyasada değil: pay kartı yok
			_seed_run_reproducible()
		"build":
			_seed_run_reproducible()
			_seed_build_state(_build_state_arg("r1"))
		"market2":   # çıktı ama MRR 0: tek yönlendirme satırı
			_seed_run_reproducible()
			GameState.day = 40
			GameState.set_flag("mvp_shipped", true)
			GameState.set_flag("mvp_product_name", "Pulse")
			GameState.set_flag("mvp_market_type", "b2b")
			GameState.set_flag("mvp_sub_product_type_id", "saas_ops")
		_:
			_seed_theme_surface()
	if kind == "signal":   # LOC-DATA debug seed / id
		_seed_signal_months()   # pano hedef kartının faz 2 dalı: rakam yok, yalnız sinyal
	await _mount_shot_shell()
	var oda: Control = _shell.get_node_or_null("MidRow/CenterViewport/OdaView")
	if oda == null:
		_shot_fail("[OdaShot] OdaView bulunamadı")
		return
	var settle: float = 0.6
	match kind:
		"day", "hover", "market1", "market2", "signal", "build":
			GameState.set_current_hour(14)
			if kind == "hover":
				oda.debug_hover_anchors()   # dört hover muamelesi tek karede
		"night":
			# §8.1: karanlık şirket penceresine göre çizilir; 23 pencerenin dışında.
			GameState.set_current_hour(23)
			oda.debug_seed_papers()
			settle = 3.2   # LIGHT_FADE_S = 1.5 sn crossfade otursun
		"evening", "dawn":
			# Dört durumlu ışık makinesinin ara iki durumu: 18 = akşam, 6 = şafak.
			GameState.set_current_hour(18 if kind == "evening" else 6)
			settle = 3.2
		"event":
			# The modal reading OVER the ODA needs a card that mounts in an unseeded world:
			# no condition, no guards, no scope.
			_wire_modal_signals()
			if not EventGate.request("product.first_ship"):
				_shot_fail("[OdaShot] product.first_ship kabul edilmedi")
				return
			settle = 1.0
		"tab":
			EventBus.tab_changed.emit("product")
		"tour":
			# The intro tour's dim must cover edge to edge, TopBar and the left rail included.
			Settings.set_value("oda_intro_seen", false)
			GameState.set_current_hour(14)
			oda.start_intro_tour_if_unseen()
			settle = 1.0
		"milestones":
			EventBus.tab_changed.emit("milestones")
		_:
			_shot_fail("[OdaShot] bilinmeyen tür: %s" % kind)
			return
	await get_tree().process_frame
	await get_tree().create_timer(settle).timeout
	get_tree().call_group(&"build_bar", "debug_print")   # monitör barının rect + fingerprint'i
	var state: String = _build_state_arg("") if kind == "build" else ""
	_save_shot("oda_shot_%s%s" % [kind, "_" + state if state != "" else ""])
	get_tree().quit()


# --tab-shot=<product|sales|hr|finance|personal|marketing|rnd|events>. tab_changed is emitted
# directly, so a tab locked on the rail can still be framed — the lock lives on the rail.
func _run_tab_shot(tab_id: String) -> void:
	_begin_shot()
	_seed_theme_surface()
	await _mount_shot_shell()
	EventBus.tab_changed.emit(tab_id)
	await _finish_shot("tab_shot_%s" % tab_id)


# --modal-shot=<confirm|confirm3|settings|month|system|saveload|mentor|rnd-note|rnd-discovery|
# rnd-discovery-line>. Each goes through the REAL mount path (EventBus signal → handler here),
# so fixture and live behaviour cannot drift. `mentor` is the one surface whose body length is
# a design constraint (the longest text, no scrollbar) — pair it with --shot-size.
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
		"confirm3":
			# Üç butonlu hâl: alt_text varlığı üçüncü butonu açar.
			EventBus.confirm_requested.emit({
				"title": tr("SYS_QUIT_TITLE"),
				"body": tr("SYS_QUIT_BODY"),
				"confirm_text": tr("SYS_QUIT_SAVE"),
				"alt_text": tr("SYS_QUIT_DISCARD"),
				"cancel_text": tr("SYS_CANCEL"),
			})
		"settings":
			EventBus.settings_requested.emit()
		"month":
			MonthSummarySystem.debug_force_summary(false)
		"system":
			EventBus.system_menu_requested.emit()
		"mentor":
			_modal_layer().add_child(MENTOR_MODAL.instantiate())
		"saveload":
			# Önce gerçek bir kayıt yaz ki YÜKLE listesinde gerçek bir slot satırı olsun.
			SaveManager.quicksave()
			EventBus.save_load_requested.emit("load")
		"rnd-note":
			# The engine's own composer, never a hand-built dict: a copy drifts from the live card.
			var author: Character = RnDSystem.note_author()
			if author == null:
				author = CharacterRegistry.get_founder()
			EventBus.rnd_card_requested.emit("note", RnDSystem.compose_note(author))
		"rnd-discovery":
			# Hat açmayan düğüm: isteğe bağlı satır kurulu ama gizli.
			EventBus.rnd_card_requested.emit("discovery", {"node": "data_model"})
		"rnd-discovery-line":
			# Hat açan düğüm (§13.5'in tek dal seviyesi istisnası).
			EventBus.rnd_card_requested.emit("discovery", {"node": "test_automation"})
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


# --theme-audit=<tab_id> prints the RESOLVED theme values of every Control (no screenshot) —
# immune to anti-aliasing noise, and it names exactly which nodes changed.
# `--theme-audit=oda` is the ODA gate: --oda-shot frames flip between two values (tween phase),
# so the ODA is proved textually, walking only the OdaView subtree.
func _run_theme_audit(tab_id: String) -> void:
	_begin_shot()
	_seed_theme_surface()
	await _mount_shot_shell()
	var oda_mode: bool = tab_id == "oda"
	if oda_mode:
		GameState.set_current_hour(14)      # sabit ışık durumu: gündüz
		EventBus.tab_changed.emit("")       # sekme yok → OdaView görünür
	else:
		EventBus.tab_changed.emit(tab_id)
	await get_tree().process_frame
	await get_tree().create_timer(0.4).timeout
	var root: Node = _shell.get_node_or_null("MidRow/CenterViewport/OdaView") if oda_mode else _shell
	if root == null:
		_shot_fail("[ThemeAudit] OdaView bulunamadı")
		return
	print("AUDIT_BEGIN %s" % tab_id)
	_audit_walk(root, "")
	print("AUDIT_END %s" % tab_id)
	get_tree().quit()


# --probe-shot: ThemeProbe.tscn, one unstyled instance of every basic Control class. Screenshot
# and audit dump come from the same run so pixels and resolved values verify each other.
func _run_probe_shot() -> void:
	_begin_shot()
	var probe: Control = (load("res://scenes/debug/ThemeProbe.tscn") as PackedScene).instantiate()
	add_child(probe)
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().create_timer(0.4).timeout
	_save_shot("probe_shot")
	print("PROBE_BEGIN")
	_audit_walk(probe, "")
	print("PROBE_END")
	get_tree().quit()


# Classes that DRAW text. A Panel also answers get_theme_font_size("font_size") but draws
# nothing with it. RichTextLabel's keys differ (normal_font_size/default_color).
const _AUDIT_TEXT_CLASSES := [
	"Label", "Button", "LineEdit", "CheckBox", "CheckButton", "OptionButton",
	"MenuButton", "LinkButton", "TextEdit", "SpinBox",
]


# One AUDIT line per Control: path, class, variation, font size, font colour, local overrides
# (S=font_size, C=font_color, P=panel stylebox), font face, panel stylebox fingerprint.
func _audit_walk(node: Node, path: String) -> void:
	for child in node.get_children():
		var p: String = path + "/" + String(child.name)
		var c := child as Control
		if c != null:
			var variation: String = String(c.theme_type_variation)
			var cls: String = c.get_class()
			var size_key: String = ""
			var color_key: String = ""
			if cls == "RichTextLabel":
				size_key = "normal_font_size"
				color_key = "default_color"
			elif cls in _AUDIT_TEXT_CLASSES:
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
			print("AUDIT|%s|%s|%s|%s|%s|%s|%s|%s" % [
				p, cls, variation if variation != "" else "--", fs, col,
				ovr if ovr != "" else "-", _audit_font(c, size_key), _audit_stylebox(c)])
		_audit_walk(child, p)


## Resolved font face file name, for text-drawing classes only.
func _audit_font(c: Control, size_key: String) -> String:
	if size_key == "":
		return "-"
	var font_key: String = "normal_font" if size_key == "normal_font_size" else "font"
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


# --finance-shot=<ozet|artida|uyari|kepenk|signal>: ~40 days played through real seams (cash
# ring buffer and transaction ledger fill from the real flow), framed on the Finance tab.
#   ozet   — negatif net: çatallı projeksiyonlar, imza + retainer karışık işlemler
#   artida — MRR > burn: yeşil ARTIDA, kırmızı erime projeksiyonu yok
#   uyari  — runway < 6 ay: mentor kartı BAND 1 + ERTELE
#   kepenk — kasa ekside, sayaç işliyor: aynı kartın BAND 2 satırı
#   signal — faz 2 yatırımcı iştahı + artıda ay sayısı
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
	# artida: 3 imza × 20K = 60K MRR → günlük gelir 2000 > kadro burn'ü (~1500).
	var sign_mrr: int = 20000 if kind == "artida" else 1100   # LOC-DATA debug seed / id
	for i in range(40):
		GameState.advance_day()
		if i == 10 or (kind == "artida" and (i == 12 or i == 14)):   # LOC-DATA debug seed / id
			var pr: Prospect = PitchSystem.spawn_prospect("mid", "event")
			# §5.3 koltuk × koltuk fiyatı: 20.000 = 400 × $50, 1.100 = 22 × $50.
			SalesSystem.add_b2b_customer(pr, sign_mrr / 50, 50, 70)
			ProspectRegistry.remove(pr.id)
		if i == 20 and kind != "artida":   # LOC-DATA debug seed / id
			# Bekleyen bir arayış; arama ücretsiz (§10), gider satırı eğitimden gelir.
			HRSearchSystem.start_search(HRConstants.ROLE_DEVELOPER, HRConstants.LEVEL_MID)
		if i == 30 and kind == "ozet":
			var pr2: Prospect = PitchSystem.spawn_prospect("small", "event")
			SalesSystem.add_b2b_customer(pr2, 16, 50, 72)   # 16 × $50 = $800
			ProspectRegistry.remove(pr2.id)
		FinanceSystem.daily_tick()
	if kind == "kepenk":   # LOC-DATA debug seed / id
		GameState.set_cash(-4000)
		GameState.set_shutter_days_left(EndingsSystem.SHUTTER_DAYS - 3)
	# Açık pipeline: iyimser projeksiyon gerçek prospect'lerden beslenir.
	PitchSystem.spawn_prospect("small", "find")
	PitchSystem.spawn_prospect("mid", "find")
	if kind == "signal":   # LOC-DATA debug seed / id
		_seed_signal_months()
	await _mount_shot_shell()
	EventBus.tab_changed.emit("finance")
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


## The ledger's first real row: popover placement derives from the anchor's on-screen rect,
## so anchoring on the page would silently weaken the check.
func _first_ledger_row(tab: Node) -> Control:
	for child in tab._list.get_children():
		if child is PanelContainer and String(child.theme_type_variation) == "LedgerRow":
			return child
	return null


# --hr-shot=<ekip|atlas|dosyalar|gider|saatler|gorevler|gorevler-bos|egitim|egitim-modal|zam|
# menu|cikar|cikar-eksi|bos>: a roster across all three departments (one on leave, one burning
# out, one fresh hire), driven to the requested HR surface.
func _run_hr_shot(kind: String) -> void:
	_begin_shot()
	_seed_run_reproducible()
	GameState.day = 64
	if kind != "bos" and kind != "gorevler-bos":
		_seed_hr_roster()
		# Kasa ve burn maaşları görsün: üst bar ile önizlemeler aynı gerçeği okur.
		GameState.set_cash(240000)
		FinanceSystem.daily_tick()
	match kind:
		"gorevler-bos", "atlas":   # LOC-DATA debug seed / id
			pass
		"dosyalar":
			# Files on the table: the arrival window's worth of real generator output.
			HRSearchSystem.start_search(HRConstants.ROLE_DEVELOPER, HRConstants.LEVEL_MID)
			for _i in HRConstants.SEARCH_ARRIVAL_DAYS:
				GameState.day += 1
				HRSearchSystem.daily_tick()
		"gider":
			# Gider dökümü: on saatlik gün "Ek mesai" kalemini doldurur (§8.2) ve tek seferlik
			# işe alım komisyonu tick'ten SONRA işlenir (daily_tick günün defterini temizler).
			WorkHoursSystem.set_company_hours(10)
			FinanceSystem.daily_tick()
			FinanceSystem.apply_one_time_cost(HRConstants.commission_for(6000), "hire")
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
		"atlas", "dosyalar":
			tab._open_atlas()
		"saatler":   # LOC-DATA debug seed / id
			# §8.5: üç kapsam birden — şirket normalde, bir grup mesaide, bir kişi kısa günde.
			WorkHoursSystem.set_group_hours(HRConstants.GROUP_DEVELOPMENT, 10)
			var crew: Array[Character] = CharacterRegistry.get_employees()
			if not crew.is_empty():
				WorkHoursSystem.set_person_hours(crew[0].id, 6)
			tab._open_hours_modal()
		"gorevler":   # LOC-DATA debug seed / id
			# §12.0 matrisi dört hâliyle: biri iki işle (üçüncü hücresi §12.1'e göre kilitli),
			# biri boşta, gerisi normal.
			var roster: Array[Character] = CharacterRegistry.get_employees()
			if roster.size() >= 2:
				for job_id in HRConstants.JOBS:
					if not roster[0].assigned_job_ids.has(job_id) \
							and HRConstants.can_hold_job(roster[0].role, job_id, roster[0].category):
						CharacterRegistry.assign_job(roster[0].id, String(job_id))
						break
				CharacterRegistry.clear_jobs(roster[1].id)
			tab._show_view(tab.VIEW_ASSIGNMENTS)
		"gorevler-bos":   # LOC-DATA debug seed / id
			tab._show_view(tab.VIEW_ASSIGNMENTS)
		"egitim-modal":   # LOC-DATA debug seed / id
			var who: Array[Character] = CharacterRegistry.get_employees()
			if not who.is_empty():
				tab._confirm_training(who[0])
		"zam", "menu", "cikar", "cikar-eksi":
			# The row's REAL path: a row click opens the HRPopover anchored on that row.
			var row: Control = _first_ledger_row(tab)
			if row == null:
				_shot_fail("[HRShot] defter satırı bulunamadı — popover çapasız")
				return
			var target: Character = CharacterRegistry.get_employees()[0]
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
		emp.hire_day = maxi(1, GameState.day - (ordinal * 26))
	HRMoraleSystem.send_on_leave(CharacterRegistry.get_character("char_emp_shot_2"),
		HRConstants.LEAVE_DAYS, false)
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
	GameState.day = 156
	GameState.set_flag("mvp_version", 3)
	GameState.set_flag("mvp_version_history", [{"version": 1, "day": 40}, {"version": 2, "day": 90}, {"version": 3, "day": 140}])
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
			GameState.day = EndingsSystem.SOFT_CAP_DAY
			GameState.active_sheets.append(VCPitchSystem._make_sheet("anchor", GameState.day - 5))
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
	await scene._export_paper_png()
	get_tree().quit()


## --build-state=<r1|r3|r4|dev|devpark|beta|beta0|durdu>: Build Bar state for product-shot
## tracker/beta and oda-shot build. `fallback` when absent or unknown.
func _build_state_arg(fallback: String) -> String:
	var v: String = _flag_value("--build-state=")
	if v in ["r1", "r3", "r4", "dev", "devpark", "beta", "beta0", "durdu"]:
		return v
	if v != "":
		push_warning("[Shot] --build-state bilinmiyor: %s" % v)
	return fallback


## Build Bar fixture: three planned K1 tiers of `erp` (a sealed demo subtype with line content;
## all three gateless, since the fixture runs with the opening roster and §12.7's gates are
## checked at Konsept approval) driven through the player's seams to the requested state:
## r1 = tur 1 yarıda · r3 = tur 3 yarıda · r4 = tavan parkı · dev = geliştirme yarıda ·
## devpark = geliştirme bandı dolu, parkta · beta = açık hatalarla · beta0 = sıfır açık hata ·
## durdu = efor işlemiş ama taşıyabilecek herkes eğitimde. Efor is written directly only
## INSIDE a band (half fill), never to skip a phase.
func _seed_build_state(state: String) -> void:
	ProductSystem.start_line_build("erp",
		["line_erp_ledger_k1", "line_erp_stock_k1", "line_erp_cashflow_k1"],
		CharacterRegistry.get_founder().id, "Nova İki")   # LOC-DATA debug seed / id
	var b: FeatureBuild = ProductSystem.get_active_build()
	if b == null:
		push_error("[BuildState] start_line_build failed")
		return
	var design_cap: float = ProductSystem.PHASE_DESIGN_END * b.total_efor
	match state:
		"durdu":
			b.efor_spent = design_cap * 0.5
			ProductSystem.hourly_tick(9)
			for c in CharacterRegistry.get_all():
				c.status = HRConstants.STATUS_TRAINING
				c.training_days_left = 6
		"r1":
			b.efor_spent = design_cap * 0.5
			ProductSystem.hourly_tick(9)
		"r3":
			# The line model counts turns in design_turns_completed.
			for i in 24 * 200:
				if b.design_turns_completed >= 3:
					break
				ProductSystem.hourly_tick(i % 24)
		"r4":
			# Design chains itself; the cap is telegraphed by at_cap, no pending decision.
			for i in 24 * 200:
				if ProductSystem.design_turns_maxed():
					break
				ProductSystem.hourly_tick(i % 24)
		"dev", "devpark", "beta", "beta0":
			for i in 24 * 90:
				if ProductSystem.can_enter_development():
					break
				ProductSystem.hourly_tick(i % 24)
			ProductSystem.enter_development()
			if state == "dev":
				b.efor_spent = b.total_efor * 0.5
				ProductSystem.hourly_tick(9)
			else:
				# Wait for the BAND, not the gate: can_enter_beta is already true in the first
				# development hour.
				for i in 24 * 120:
					if ProductSystem.development_band_complete():
						break
					ProductSystem.hourly_tick(i % 24)
				if state == "devpark":
					return   # parkta kal: "Beta'ya geç" butonu + hazır satırları
				ProductSystem.enter_beta()
				if b.bug_count <= 0:   # dev birikimi bug üretmediyse fikstür üretir
					b.bug_count = 12
					GameState.set_flag("bug_count_at_bugfix_start_%s" % b.id, 12)
				for i in 24 * 2:   # iki gün test: bulunan/çözülen sayaçları dolsun
					ProductSystem.hourly_tick(i % 24)
				if state == "beta0":
					b.bug_count = 0
					b.bugs_found = b.bugs_fixed
	print("[BuildState] %s → phase=%s turn=%d/%d design_efor=%.2f efor=%.2f/%.2f bugs=%d" % [
		state, b.current_phase, b.design_turns_completed, ProductSystem.DESIGN_TURN_MAX,
		b.design_efor_spent, b.efor_spent, b.total_efor, b.bug_count])


# --product-shot=<portfoy|ozellikler|tracker|beta|detail_b2b|detail_care|detail_b2c|
# detail_b2c_buggy|publish>: seeded state, the Product tab ROUTER driven to the view — the
# same path the player takes.
func _run_product_shot(kind: String) -> void:
	_begin_shot()
	_seed_run_reproducible()
	var founder: Character = CharacterRegistry.get_founder()
	match kind:
		"detail_b2b", "detail_care", "portfoy":   # LOC-DATA debug seed / id
			GameState.day = 95
			GameState.set_flag("mvp_shipped", true)
			GameState.set_flag("mvp_market_type", "b2b")
			GameState.set_flag("mvp_product_name", "Nova")
			GameState.set_flag("mvp_version", 2)
			# Üç hat açık, biri K2'de: kilitli · tamamlanmış · boş hat durumları aynı karede.
			# Eksenler hat durumundan türer (ProductState.axis_readings).
			_seed_line_state("erp", _ERP_SHIPPED_LINES)
			GameState.set_flag("mvp_launch_day", 73)
			# The publish flow's ALTYAPI step is skipped, so provider and units are set here.
			ProductState.set_infra_provider("enterprise")
			ProductState.set_infra_units(3)
			GameState.set_flag("mvp_live_bug_count", 6)
			GameState.set_flag("mvp_bug_history", [2, 2, 3, 4, 4, 5, 6])
			GameState.set_flag("mvp_version_history",
				[{"version": 1, "day": 10}, {"version": 2, "day": 73}])
			var p := Prospect.new()
			p.id = "shot_ege"
			p.company_name = "Ege Sigorta"
			p.industry = "insurance"
			p.star = 1
			p.pain_feature_id = "saas_ops_integration"
			var c: Customer = SalesSystem.add_b2b_customer(p, 6, 67, 70)   # 6 seats x $67 = $402
			PromiseRegistry.create(c.id, "saas_ops_integration", 12)
			if kind == "portfoy":   # LOC-DATA debug seed / id
				# "Yapımda" satırı iki hareketi birden gösterir: Stok K2 açık bir hattı
				# yükseltir, Sipariş K1 yeni hat açar. Stok K2'nin kapısı (Yazılım ★2 ·
				# Tasarım ★1) kurucuya gerçek ham puan verilerek karşılanır (★N = ham ≥ 2N).
				founder.role_stats["engineering"] = 4
				founder.role_stats["design"] = 2
				ProductSystem.start_line_build("erp",
					["line_erp_stock_k2", "line_erp_intake_k1"], founder.id, "Nova")
				var b: FeatureBuild = ProductSystem.get_active_build()
				if b != null:
					b.efor_spent = b.total_efor * 0.64
					ProductSystem.hourly_tick(9)  # faz bandını ilerlemeye oturtur
		# `publish` shares the fixture: the flow floats over a live product.
		"detail_b2c", "detail_b2c_buggy", "publish":   # LOC-DATA debug seed / id
			GameState.set_flag("mvp_shipped", true)
			GameState.set_flag("mvp_market_type", "b2c")
			GameState.set_flag("mvp_product_name", "Fokus")
			GameState.set_flag("mvp_version", 1)
			_seed_line_state("note_tool", [
				["line_note_tool_capture", 1, "line_note_tool_capture_k1", 1.00],
				["line_note_tool_sync", 1, "line_note_tool_sync_k1", 0.75],
			])
			GameState.set_flag("mvp_launch_day", GameState.day)
			ProductState.set_infra_provider("cloud")
			ProductState.set_infra_units(2)
			# buggy: the pricing ruler's conversion projection moving under the bug penalty.
			GameState.set_flag("mvp_live_bug_count", 15 if kind == "detail_b2c_buggy" else 5)
			GameState.set_flag("mvp_bug_history", [1, 2, 2, 3, 4, 4, 5])
			GameState.set_flag("mvp_version_history", [{"version": 1, "day": GameState.day}])
			GameState.set_flag("b2c_audience", 1.0)
			# Satış okuma kapısını aç: optimal rakam gerçek değerle çizilsin.
			founder.role_stats["sales"] = SkillCheck.SALES_READ_THRESHOLD
		"tracker", "beta":
			# Same fixture as --oda-shot=build: HUD, tracker and monitor show one model.
			_seed_build_state(_build_state_arg("beta" if kind == "beta" else "r1"))
	await _mount_shot_shell()
	EventBus.tab_changed.emit("product")
	await get_tree().process_frame
	var tab: Node = _shell.find_child("CenterViewport", true, false).get_current_page_body()
	if tab == null:
		_shot_fail("[ProductShot] sekme gövdesi bulunamadı (get_current_page_body null)")
		return
	match kind:
		"ozellikler":
			tab._navigate("creation", {"step": 3, "prefill": {"type": "note_tool",
				"features": ["line_note_tool_capture_k1", "line_note_tool_sync_k1",
					"line_note_tool_search_k1"]}})
		"tracker", "beta":
			tab._navigate("tracker", {})
		"detail_b2b", "detail_b2c", "detail_b2c_buggy", "detail_care":
			# detail_care: DESTEK bandının pasif hâli — kurucunun işi yok, müşterilerle ilgileniyor.
			if kind == "detail_care":
				CharacterRegistry.clear_jobs(founder.id)
			tab._navigate("detail", {})
		"publish":
			# Through the flow's own door, the path of the player's BETA action.
			tab._navigate("detail", {})
			PublishFlow.open()
	await get_tree().process_frame
	await get_tree().create_timer(0.4).timeout
	get_tree().call_group(&"build_bar", "debug_print")   # üç ev sahibinin rect + fingerprint'i
	var state: String = _build_state_arg("")
	_save_shot("product_shot_%s%s" % [kind, "_" + state if state != "" else ""])
	get_tree().quit()


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
	GameState.day = 62
	GameState.set_cash(48000)
	GameState.set_flag("mvp_shipped", true)
	GameState.set_flag("mvp_market_type", "b2b")
	_seed_line_state("erp", _ERP_SHIPPED_LINES)
	GameState.set_flag("mvp_launch_day", 40)
	ProductState.set_infra_provider("cloud")
	ProductState.set_infra_units(6)
	var founder: Character = CharacterRegistry.get_founder()
	founder.role_stats[HRConstants.AREA_SALES] = 6
	founder.role_stats[FounderConstants.SKILL_CHARISMA] = 4


## --vc-shot=<hunt|hunt_closed|table|table_final|table_walk|table_other|seed_table|k10>: the
## Series A surfaces — the Hunt page, the term-sheet table in its states and the expired-offer
## decision card. Pushes go through the real table system with the SkillCheck debug force.
func _run_vc_shot(kind: String) -> void:
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
			GameState.active_sheets.append(VCPitchSystem._make_sheet("anchor", GameState.day - 2))
			VCPitchSystem._vc("anchor")["status"] = "offered"
			GameState.active_sheets.append(VCPitchSystem._make_sheet("meridian", GameState.day))
			VCPitchSystem._vc("meridian")["status"] = "offered"
			VCPitchSystem._vc("bosphorus")["status"] = "pending_sheet"
			VCPitchSystem._vc("bosphorus")["pending_sheet"] = true
			VCPitchSystem._vc("nexus")["status"] = "rejected"
		"hunt_closed":
			for pair in [["anchor", "rejected"], ["nexus", "walked"], ["bosphorus", "expired"], ["meridian", "rejected"]]:
				VCPitchSystem._vc(String(pair[0]))["status"] = String(pair[1])
		"table", "table_final", "table_walk":
			var conv: int = 45 if kind == "table_walk" else (100 if kind == "table_final" else 83)
			VCPitchSystem._vc("bosphorus")["sheet_conviction"] = conv
			GameState.active_sheets.append(VCPitchSystem._make_sheet("bosphorus", GameState.day))
			TermSheetTableSystem.open("bosphorus")
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
			TermSheetTableSystem.open("anchor")
			TermSheetTableSystem.show_other_offer()
		"seed_table":
			GameState.set_phase(2)
			GameState.mrr = 22000
			GameState.seed_sheet = SeedRoundSystem.make_seed_sheet("anchor", "standard", GameState.day)
			TermSheetTableSystem.open("anchor")
		"k10":
			# A sheet whose ten business days ran out today: the decision card's moment.
			var due: TermSheet = VCPitchSystem._make_sheet("meridian", GameState.day - 14)
			due.expires_day = GameState.day
			GameState.active_sheets.append(due)
			VCPitchSystem._vc("meridian")["status"] = "offered"
		_:
			_shot_fail("[VcShot] unknown --vc-shot kind: %s" % kind)
			return
	if kind in ["hunt", "hunt_closed"]:
		await _mount_shot_shell()
		EventBus.tab_changed.emit("finance")
		await get_tree().process_frame
		EventBus.finance_subpage_requested.emit("yatirim")   # LOC-DATA sub-page id
	elif kind == "k10":
		var ev: GameEvent = EventGate.render("funding.sheet_decision", EventGate.bind_scope("funding.sheet_decision"))
		if ev == null:
			_shot_fail("[VcShot] funding.sheet_decision did not render (no decision-due sheet bound)")
			return
		_on_shot_layer(EVENT_MODAL.instantiate()).populate(ev)
	else:
		_on_shot_layer(TERM_TABLE_SCENE.instantiate())
	await get_tree().process_frame
	await _finish_shot("vc_shot_%s" % kind, 0.5)


## First open answer of the live sales table; `last` walks on to the weakest (last) open one.
func _open_answer(last: bool) -> String:
	var picked: String = ""
	for a in (SalesMeetingSystem.view_state().get("answers", []) as Array):
		if bool((a as Dictionary).get("open", false)):
			picked = String((a as Dictionary).get("id", ""))
			if not last:
				break
	return picked


## --meeting-shot=<probe|locked|won|lost|handoff>: Perde 1'in dört hâli ve perde değişimi.
## `locked` proves the acceptance item "locked rows show their reason line".
func _run_meeting_shot(kind: String) -> void:
	_begin_shot()
	_seed_sales_world()
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
	_open_sales_meeting(p.id)
	await get_tree().process_frame
	if kind == "locked":
		for _i in 4:
			var vs: Dictionary = SalesMeetingSystem.view_state()
			var has_lock: bool = false
			for a in (vs.get("answers", []) as Array):
				has_lock = has_lock or not bool((a as Dictionary).get("open", true))
			var pick: String = _open_answer(false)
			if has_lock or String(vs.get("outcome", "")) != "" or pick == "":
				break
			SalesMeetingSystem.choose(pick)
	elif plays_out:
		# Play the table to its closing frame.
		for _i in 8:
			if String(SalesMeetingSystem.view_state().get("outcome", "")) != "":
				break
			var picked: String = _open_answer(kind == "lost")
			if picked == "":
				SalesMeetingSystem.skip_to_offer()
				break
			SalesMeetingSystem.choose(picked)
	if _sales_meeting != null and kind != "probe":
		_sales_meeting.call("_render", SalesMeetingSystem.view_state())
	# `handoff` is the act change itself (§5.1.1: the table turns into Perde 2 in the SAME
	# scene — room, portrait and title stay on the same pixels), run through the scene's own
	# _on_open_offer.
	if kind == "handoff" and _sales_meeting != null:
		if String(SalesMeetingSystem.view_state().get("outcome", "")) != "won":
			push_warning("[MeetingShot] handoff: masa kazanmadı, Perde 2 açılmıyor")
		_sales_meeting.call("_on_open_offer")
		await get_tree().process_frame
	_probe_pause_interactivity(_sales_meeting, "meeting/" + kind)
	await get_tree().create_timer(0.5).timeout
	_save_shot("meeting_shot_%s" % kind)
	get_tree().quit()


## THE PAUSE PROBE. Speed 0 pauses the tree, and Godot keeps DRAWING a paused Control while
## refusing it input — a surface that looks perfect and eats every click. Neither the scene
## file nor a screenshot shows this, so the probe asks can_process() with the tree paused.
func _probe_pause_interactivity(root: Node, label: String) -> void:
	if root == null:
		return
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


## --negotiation-shot=<open|countered|insult|confirm>: Perde 2'nin dört hâli. Diyalog yok
## (§5.3.1): cetvel, rakam, sabır kutuları ve buton tonu.
func _run_negotiation_shot(kind: String) -> void:
	_begin_shot()
	_seed_sales_world()
	var p: Prospect = SalesFaucetSystem.spawn(2, "faucet")
	await _mount_shot_shell()
	NegotiationSystem.open(NegotiationSystem.TYPE_B2B, {
		"account": p.company_name, "lead_id": p.id, "star": p.star,
		"archetype": p.archetype_id,
		"promised": "line_erp_ledger_k3" if kind == "confirm" else "",
		"is_whale": false,
	})
	var vs: Dictionary = NegotiationSystem.view_state()
	match kind:
		"countered":
			NegotiationSystem.select_price(int(vs.get("insult_from", 60)) - 4)
			NegotiationSystem.offer()
		"insult":
			NegotiationSystem.select_price(int(vs.get("insult_from", 60)) + 3)
		"confirm":
			NegotiationSystem.select_price(SalesConstants.SEAT_PRICE_MIN)
			NegotiationSystem.offer()
	# Perde 2 carries no ground of its own (rev 6.1 §5.1.1); the stage is what the player sees.
	var stage := SalesStage.new()
	add_child(stage)
	stage.set_identity({
		"portrait_path": "",
		"name": p.company_name,
		"star": p.star,
		"archetype_line": SalesArchetypes.voice_line(p.archetype_id),
		"whale_condition": p.whale_condition,
	})
	stage.content_host().add_child(NEGOTIATION_SCENE.instantiate())
	await get_tree().process_frame
	_probe_pause_interactivity(stage, "negotiation/" + kind)
	await get_tree().create_timer(0.4).timeout
	_save_shot("negotiation_shot_%s" % kind)
	get_tree().quit()


func _shot_customer(id: String, cname: String, industry: String, phase: String, mrr: int, seats: int, days_ago: int, cs: bool) -> void:
	var c := Customer.new()
	c.id = id
	c.company_name = cname
	c.industry = industry
	c.market_type = "b2b"
	c.mrr = mrr
	c.seats = seats
	c.satisfaction = 25 if phase == "risk" else 72
	c.lifecycle_phase = phase
	c.acquired_on_day = GameState.day - days_ago
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
	var mentor: Node = MENTOR_MODAL.instantiate()
	mentor.dismissed.connect(_on_mentor_dismissed)
	_modal_layer().add_child(mentor)


# The "repaint the world" seam: every shell child paints from GameState in its own _ready(),
# so state is restored first and the shell mounted second. A save load comes through here
# WITHOUT the mentor intro, which belongs to a new run only.
func _mount_shell() -> void:
	_shell = GAME_SHELL.instantiate()
	add_child(_shell)
	_shell_mounted = true
	# One frame so TopBar/OdaView finish their initial paint before anything mounts on top.
	await get_tree().process_frame
	_wire_modal_signals()


func _wire_modal_signals() -> void:
	if _event_signals_wired:
		return
	_event_signals_wired = true
	EventBus.modal_requested.connect(_on_event_modal_requested)
	EventBus.event_resolved.connect(_on_event_resolved)
	EventBus.pitch_requested.connect(_open_sales_meeting)
	EventBus.settings_requested.connect(_on_settings_requested)
	EventBus.confirm_requested.connect(_on_confirm_requested)
	EventBus.run_ended.connect(_on_run_ended)
	EventBus.milestone_reached.connect(_on_milestone_reached)
	EventBus.month_ended.connect(_on_month_ended)
	EventBus.meeting_scene_requested.connect(_on_meeting_scene_requested)
	EventBus.term_table_requested.connect(_on_term_table_requested)
	EventBus.system_menu_requested.connect(_on_system_menu_requested)
	EventBus.save_load_requested.connect(_on_save_load_requested)
	EventBus.quicksave_requested.connect(_on_quicksave_requested)
	EventBus.quickload_requested.connect(_on_quickload_requested)
	EventBus.rnd_card_requested.connect(_on_rnd_card_requested)
	EventBus.product_note_issued.connect(_on_product_note_issued)


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


func _on_mentor_dismissed() -> void:
	# Stay paused: the player's first decision (the build commit) is what unpauses. The ODA
	# intro tour starts now if it was never seen, and runs under pause.
	get_tree().call_group("oda_view", "start_intro_tour_if_unseen")


func _on_event_modal_requested(event: GameEvent) -> void:
	if _pre_event_speed < 0:
		_pre_event_speed = TimeManager.current_speed
	EventBus.speed_change_requested.emit(0)
	var modal_layer: CanvasLayer = _modal_layer()
	if modal_layer == null:
		return
	# Never stack two cards: game_shell guards ESC and the speed keys on the ModalLayer child
	# count and the event modal has no ui_cancel, so a second card on the first would leave no
	# keyboard way out — no pause, no menu, no save, no quit.
	if _event_modal != null:
		push_error("[Main] an event modal is already mounted (%s) — refusing to stack"
			% _event_modal.name)
		_event_modal.queue_free()
	_event_modal = EVENT_MODAL.instantiate()
	modal_layer.add_child(_event_modal)
	_event_modal.populate(event)


func _on_event_resolved(_event_id: String, _choice_idx: int) -> void:
	if _event_modal != null:
		_event_modal.queue_free()
		_event_modal = null
	# event_resolved fires BEFORE the engine pumps its queue, so has_pending() still sees the
	# next card and the clock stays paused for it. A choice can also OPEN a cinematic surface
	# (start_vc_meeting / open_term_table run before event_resolved); that surface's close
	# owns the restore.
	if not EventGate.has_pending() and _meeting_scene == null and _term_table == null:
		_restore_speed(_pre_event_speed)
		_pre_event_speed = -1


## A cinematic surface opened from an event choice finds the clock already paused by the
## card; it inherits the card's stored speed instead and owns restoring it.
func _claim_pre_dialogue_speed() -> void:
	if _pre_dialogue_speed < 0:
		_pre_dialogue_speed = _pre_event_speed if _pre_event_speed >= 0 else TimeManager.current_speed
	_pre_event_speed = -1


# THE SALES SITTING (Satış §5.0): "ODA da terminal UI da görünmez; bar notu, pause etiketi,
# HUD yoktur." Done as a subtree swap, not change_scene: tearing down Main would lose the
# modal routing, the event wiring and every harness path. GameShell is HIDDEN rather than
# removed because the tab pages disconnect their EventBus signals in _exit_tree and _ready
# runs once per instance — a re-added shell would be wired to nothing.
# The tree is paused during the sitting, so the scene carries process_mode = ALWAYS.
func _open_sales_meeting(prospect_id: String) -> void:
	if _sales_meeting != null:
		return
	if SalesMeetingSystem.block_reason(prospect_id) != "":
		return   # the tab draws the reason; reaching here at all is a UI bug, not a state one
	if SalesMeetingSystem.open(prospect_id).is_empty():
		return
	_claim_pre_dialogue_speed()
	EventBus.speed_change_requested.emit(0)
	if _shell != null:
		_shell.visible = false
	_sales_meeting = SALES_MEETING_SCENE.instantiate()
	_sales_meeting.closed.connect(_close_sales_meeting)
	add_child(_sales_meeting)           # a child of Main, so nothing of the shell is behind it


func _close_sales_meeting() -> void:
	if _sales_meeting == null:
		return
	_sales_meeting.queue_free()
	_sales_meeting = null
	# §5.0 — the clock jumps two hours HERE, after the scene is gone, so the world the player
	# comes back to is already the world those two hours produced.
	SalesMeetingSystem.close()
	if _shell != null:
		_shell.visible = true
	_restore_speed(_pre_dialogue_speed)
	_pre_dialogue_speed = -1


func _on_settings_requested() -> void:
	if _settings_modal != null:
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
	if modal_layer == null:
		return
	_pre_confirm_speed = TimeManager.current_speed
	EventBus.speed_change_requested.emit(0)
	_confirm_modal = (HR_ACTION_MODAL if String(config.get("modal", "")) == "hr_action"
		else CONFIRM_MODAL).instantiate()
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


# game_shell emits system_menu_requested only when ModalLayer AND PanelLayer are empty, so a
# forced decision stays forced: ESC never reaches this menu over an event card.
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


## §5.8 keşif kartı · §6.1 aylık ürün notu. PanelLayer'a (layer 9) monte edilir, ModalLayer'a
## (layer 10) DEĞİL: ModalLayer Space ve 1-3'ü yutuyor, yani saat oyuncunun duraklatamadığı
## bir kartın üstünde koşardı. Esc'i kart kendi `_unhandled_input`'unda alır.
func _on_rnd_card_requested(kind: String, data: Dictionary) -> void:
	if is_instance_valid(_rnd_card):
		if _rnd_card_queue.size() < 2:
			_rnd_card_queue.append({"kind": kind, "data": data})
		return
	_mount_rnd_card(kind, data)


func _mount_rnd_card(kind: String, data: Dictionary) -> void:
	var layer: Node = _shell.get_node_or_null("PanelLayer") if _shell != null else null
	if layer == null:
		push_error("[Main] GameShell/PanelLayer yok — Ar-Ge kartı monte edilemiyor")
		return
	_rnd_card = RND_CARD_MODAL.instantiate()
	_rnd_card.tree_exited.connect(_on_rnd_card_closed)
	layer.add_child(_rnd_card)
	_rnd_card.populate(kind, data)


## Deferred: `tree_exited` fires mid-removal, and adding a child to the same layer inside that
## flow would race it.
func _on_rnd_card_closed() -> void:
	_rnd_card = null
	if _rnd_card_queue.is_empty():
		return
	var next: Dictionary = _rnd_card_queue.pop_front()
	_mount_rnd_card.call_deferred(String(next.get("kind", "")), next.get("data", {}))


## §6.1 — only the run's FIRST report opens as a modal. The latch lives in the engine
## (take_first_note_modal), so save/load cannot split it from a second flag here.
func _on_product_note_issued(_day: int) -> void:
	if RnDSystem.take_first_note_modal():
		_on_rnd_card_requested("note", RnDSystem.pending_note())


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


func _on_quicksave_requested() -> void:
	if _shell_mounted and SaveManager.can_save():
		SaveManager.quicksave()


func _on_quickload_requested() -> void:
	if _shell_mounted:
		_load_slot(SaveManager.QUICK_SLOT_ID)


# The single load path. The shell is torn down BEFORE state is applied, so initialize_run's
# "no listeners yet" assumption holds here too and no signal storm is needed. The save is read
# and validated before anything is touched: "file corrupt" in a half-torn world is the worst case.
func _load_slot(slot_id: String) -> void:
	# The same rule as saving: a decision in progress (event card, VC meeting, term table, sales
	# sitting, negotiation) is not carried over. F9 bypasses the menu gate — and the hidden
	# shell still hears it during a sales sitting, which is a child of Main and would survive
	# the teardown.
	if SaveManager.cannot_save_reason_key() == "SAVE_ERR_MODAL_OPEN":
		return
	var payload: Dictionary = SaveManager.read_slot(slot_id)
	if not bool(payload.get("ok", false)):
		push_warning("[Main] yükleme reddedildi (%s): %s" % [slot_id, payload.get("error_key", "")])
		return
	_teardown_run_ui()
	# queue_free is deferred; without a frame two GameShells would share the tree.
	await get_tree().process_frame
	if not SaveManager.apply_loaded_state(payload):
		push_error("[Main] yükleme durumu uygulanamadı (%s)" % slot_id)
		return
	await _mount_shell()
	EventBus.game_loaded.emit(slot_id)


func _on_month_ended(summary_data: Dictionary) -> void:
	if _month_modal != null:
		return
	var modal_layer: CanvasLayer = _modal_layer()
	if modal_layer == null:
		return
	# If an event card is already up (both fired in one daily tick) the summary stacks on
	# top; dismissing it reveals the card, and the restore defers to it via has_pending().
	_pre_month_speed = TimeManager.current_speed
	EventBus.speed_change_requested.emit(0)
	_month_modal = MONTH_SUMMARY_MODAL.instantiate()
	_month_modal.dismissed.connect(_on_month_dismissed)
	modal_layer.add_child(_month_modal)
	_month_modal.populate(summary_data)  # add_child SONRASI — @onready ref'ler ancak o zaman dolu


func _on_month_dismissed() -> void:
	_month_modal = null
	_restore_speed(_pre_month_speed)
	_pre_month_speed = -1


# Terminal: the ending paper never restores speed. EndingsSystem already flushed the queue and
# paused the clock, and TimeManager swallows unpause requests once run_active is false.
func _on_run_ended(_ending_id: String, ending_data: Dictionary) -> void:
	if _ending_modal != null:
		return
	var modal_layer: CanvasLayer = _modal_layer()
	if modal_layer == null:
		return
	_ending_modal = ENDING_MODAL.instantiate()
	modal_layer.add_child(_ending_modal)
	_ending_modal.populate(ending_data)  # add_child SONRASI — @onready ref'ler ancak o zaman dolu


# The ending paper in milestone mode (EA / full): a win the run lives through. The clock is
# HELD while it is up, so a card, the month summary or settings closing on top of it cannot
# restart time behind it; DEVAM ET releases the hold and restores the player's speed.
func _on_milestone_reached(_milestone_id: String, data: Dictionary) -> void:
	if _ending_modal != null or _milestone_modal != null:
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
	# A card admitted earlier the same day stays ON TOP: it is answered first (its restore is
	# swallowed by the hold). Under the paper it would be hidden, and ANA MENÜ would refuse to
	# save for a decision screen the player cannot see.
	if is_instance_valid(_event_modal) and _event_modal.get_parent() == modal_layer:
		modal_layer.move_child(_milestone_modal, _event_modal.get_index())
	_milestone_modal.populate(data)  # add_child SONRASI — @onready ref'ler ancak o zaman dolu


func _on_milestone_continue() -> void:
	if _milestone_modal != null:
		_milestone_modal.queue_free()
	_milestone_modal = null
	TimeManager.release_clock(MILESTONE_CLOCK_HOLD)
	# The month summary still open on top owns the pause and restores it itself.
	if _month_modal == null:
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


# MeetingScene: a live VC meeting (VCPitchSystem) or the Shift+F2 debug fixture, which has no
# driver and simply closes.
func _on_meeting_scene_requested(view_state: Dictionary) -> void:
	if _meeting_scene != null:
		return
	var modal_layer: CanvasLayer = _modal_layer()
	if modal_layer == null:
		return
	_claim_pre_dialogue_speed()
	EventBus.speed_change_requested.emit(0)
	_meeting_scene = MEETING_SCENE.instantiate()
	_meeting_scene.choice_selected.connect(_on_dialogue_choice_selected)
	_meeting_scene.withdraw_requested.connect(_on_dialogue_withdrawn)
	modal_layer.add_child(_meeting_scene)
	_meeting_scene.populate(view_state)  # add_child SONRASI — @onready ref'ler ancak o zaman dolu


## advance() writes the outcome and returns the next view_state, or done.
func _on_dialogue_choice_selected(id: String) -> void:
	if VCPitchSystem.is_meeting_active():
		var r: Dictionary = VCPitchSystem.advance(id)
		if not r.get("done", false) and _meeting_scene != null:
			_meeting_scene.populate(r.get("view_state", {}))
			return
	_close_dialogue_scenes()


func _on_dialogue_withdrawn() -> void:
	if VCPitchSystem.is_meeting_active():
		VCPitchSystem.withdraw()
	_close_dialogue_scenes()


func _close_dialogue_scenes() -> void:
	if _meeting_scene != null:
		_meeting_scene.queue_free()
		_meeting_scene = null
	_restore_speed(_pre_dialogue_speed)
	_pre_dialogue_speed = -1


func _on_term_table_requested(vc_id: String) -> void:
	if _term_table != null:
		return
	var modal_layer: CanvasLayer = _modal_layer()
	if modal_layer == null:
		return
	if TermSheetTableSystem.open(vc_id).is_empty():
		push_warning("[Main] term_table_requested for %s with no live sheet" % vc_id)
		return
	_claim_pre_dialogue_speed()
	EventBus.speed_change_requested.emit(0)
	_term_table = TERM_TABLE_SCENE.instantiate()
	_term_table.closed.connect(_close_term_table)
	modal_layer.add_child(_term_table)


# A signature ends the run (no restore — the ending owns the freeze); a walk-out leaves it
# alive and restores the pre-table speed.
func _close_term_table() -> void:
	if _term_table != null:
		_term_table.queue_free()
		_term_table = null
	_restore_speed(_pre_dialogue_speed)
	_pre_dialogue_speed = -1


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
	_event_modal = null
	_settings_modal = null
	_confirm_modal = null
	_ending_modal = null
	_milestone_modal = null
	_month_modal = null
	_system_menu = null
	_save_load_modal = null
	_meeting_scene = null
	_term_table = null
	_rnd_card_queue.clear()
	_pre_event_speed = -1
	_pre_settings_speed = -1
	_pre_confirm_speed = -1
	_pre_month_speed = -1
	_pre_system_speed = -1
	_pre_dialogue_speed = -1
	_pre_milestone_speed = -1
