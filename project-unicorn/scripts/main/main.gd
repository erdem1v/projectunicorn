extends Node

# Main scene root — owns the launch lifecycle:
#   1. Enforce 1280×720 minimum window (TECH_SPEC §14.1).
#   2. Pause the clock (TimeManager auto-starts at 1x in its own _ready;
#      we override it for onboarding so day/hour stay at 1/09:00).
#   3. Instance OnboardingFlow into self. GameShell is NOT instanced upfront —
#      its child components (TopBar, LeftTabs, OdaView) paint from GameState in
#      _ready(), so it can only mount after initialize_run completes.
#   4. On flow completed signal (or F12 debug skip): swap flow for GameShell,
#      then instance MentorIntroModal into GameShell/ModalLayer.
#   5. On modal dismissed: unpause via EventBus.speed_change_requested(1).

const ONBOARDING_FLOW := preload("res://scenes/onboarding/OnboardingFlow.tscn")
const GAME_SHELL := preload("res://scenes/main/GameShell.tscn")
const MENTOR_MODAL := preload("res://scenes/modals/MentorIntroModal.tscn")
const EVENT_MODAL := preload("res://scenes/modals/EventModal.tscn")
const SETTINGS_MODAL := preload("res://scenes/modals/SettingsModal.tscn")
const CONFIRM_MODAL := preload("res://scenes/modals/ConfirmModal.tscn")
const ENDING_MODAL := preload("res://scenes/modals/EndingScene.tscn")  # newspaper ceremony ("Ekonomi Postası") — same populate(ending_data) mount contract
const MONTH_SUMMARY_MODAL := preload("res://scenes/modals/MonthSummaryModal.tscn")
const MEETING_SCENE := preload("res://scenes/modals/MeetingScene.tscn")
const FRANK_POPUP := preload("res://scenes/modals/FrankPopup.tscn")
const TERM_TABLE_SCENE := preload("res://scenes/modals/TermSheetTableScene.tscn")
const SYSTEM_MENU_MODAL := preload("res://scenes/modals/SystemMenuModal.tscn")
const SAVE_LOAD_MODAL := preload("res://scenes/modals/SaveLoadModal.tscn")

var _flow: Node = null
var _shell: Node = null
var _modal: Node = null              # Mentor intro modal
var _event_modal: Node = null        # Currently-open event modal, or null
var _settings_modal: Node = null     # Currently-open settings modal, or null
var _confirm_modal: Node = null      # Currently-open confirm modal, or null
var _ending_modal: Node = null       # Ending summary modal — mounts once, never dismissed back to gameplay
var _month_modal: Node = null        # Currently-open month summary modal, or null
var _meeting_scene: Node = null      # Currently-open MeetingScene (Spec 5), or null
var _frank_popup: Node = null        # Currently-open FrankPopup (Spec 5), or null
var _term_table: Node = null         # Currently-open TermSheetTableScene (Spec 6), or null
var _deal_prompt_vc: String = ""     # VC whose deal-closed FrankPopup is showing (Spec 6), or ""
var _pending_deal_prompt_vc: String = ""  # sheet_granted queued a prompt; shown when no modal is up
var _pre_dialogue_speed: int = -1    # Speed to restore when a cinematic dialogue closes
var _pre_month_speed: int = -1       # Speed to restore when the month summary closes
var _pre_confirm_speed: int = -1     # Speed to restore when the confirm closes
# Speed to restore when the settings panel closes. Tracked separately from
# _pre_event_speed because the player can open settings at any speed (incl.
# already-paused) and we must return to exactly that.
var _pre_settings_speed: int = -1
# ESC sistem menüsü + Kaydet/Yükle modalı (SaveManager task'ı). Aynı
# yakala-ve-geri-yükle disiplini: menü hangi hızda açıldıysa oraya döner.
var _system_menu: Node = null        # Currently-open ESC system menu, or null
var _save_load_modal: Node = null    # Currently-open save/load modal, or null
var _pre_system_speed: int = -1
var _shell_mounted: bool = false
var _event_signals_wired: bool = false
# Speed at the moment the first event in a chain pauses the game. When the
# queue drains we restore this exact speed — 4x stays 4x, an already-paused
# game stays paused. -1 means "no event currently in progress."
var _pre_event_speed: int = -1

# Debug --tempo-probe only: real-clock stamp of the previous day boundary.
var _tempo_last_msec: int = 0


func _ready() -> void:
	get_window().min_size = Vector2i(1280, 720)

	# Bayat-tema bekçisi (Tema Çekirdeği): master_theme.tres UiTokens'tan ÜRETİLİR ve
	# jeneratör elle koşulur — token değişip regen unutulursa bunu başka hiçbir şey fark
	# etmez. build_theme damgayı .tres'e gömer (UiTokensStamp/stamp); burada karşılaştırıp
	# farkta bağırırız. Damgasız (eski) bir .tres'te get_constant 0 döner — o da doğru
	# şekilde uyarıya düşer.
	if OS.is_debug_build():
		var proj_theme: Theme = ThemeDB.get_project_theme()
		if proj_theme != null:
			var baked_stamp: int = proj_theme.get_constant(&"stamp", &"UiTokensStamp")
			if baked_stamp != UiTokens.THEME_STAMP:
				push_warning("[Theme] master_theme.tres BAYAT: gömülü damga %d != UiTokens.THEME_STAMP %d — regen: godot --headless --path . -s res://scripts/theme/build_theme.gd" % [baked_stamp, UiTokens.THEME_STAMP])

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
			# CLI headless runs (arg on the command line) quit so stdout flushes and the
			# process exits; the MCP editor-run path (arg via ProjectSettings main_args,
			# NOT cmdline) is left ALIVE so it can read the live log — see endgame_smoke.gd.
			if _smoke_case_on_cmdline():
				get_tree().quit()
			return

	# Debug: --tempo-probe=<speed idx> runs the REAL clock headless (no shell, no
	# modals) and prints one line per day boundary, so seconds-per-day can be
	# stopwatched end to end. The smoke harness drives ticks directly and therefore
	# cannot measure wall-clock tempo — this is the only thing that can.
	if OS.is_debug_build():
		var tempo_idx: int = _tempo_probe_requested()
		if tempo_idx >= 0:
			_run_tempo_probe(tempo_idx)
			return

	# Debug: --render-probe[=<tab id>] (+ --shot-size) mounts the real shell at one
	# window size and prints FRAME COST and TEXTURE/VIDEO MEMORY, then quits. The
	# screenshot runners prove what a frame LOOKS like and can't price it; the smoke
	# suite runs headless and has no raster at all. Written for the render-sharpness
	# pass, whose §5 asks for a frame-time and VRAM delta at 4K — a texture-import
	# change (mipmaps, svg/scale) costs memory and sampling, and "it feels fine" is
	# not a number.
	# VSYNC IS FORCED OFF here, deliberately: at 60Hz every frame measures ~16.7ms
	# and the probe would report the monitor's refresh rate instead of the game's
	# cost. Safe because this arg is registered in DisplaySettings._is_harness_arg,
	# so is_inert() is true and the player's real vsync preference is never touched.
	if OS.is_debug_build():
		var render_probe: String = _render_probe_requested()
		if render_probe != "":
			_run_render_probe(render_probe)
			return

	# Debug: --run-log=<preset>:<days>:<mode> drives a whole run headless and prints a
	# LEDGER (every event fire with its source, every choice, daily economy state) instead
	# of an assertion. mode "sim" drives the dispatch directly; mode 1-4 uses the real
	# clock at that speed index and quits itself from the day_advanced handler.
	# See scripts/debug/run_probe.gd.
	if OS.is_debug_build():
		var run_log: String = _run_log_requested()
		if run_log != "":
			RunProbe.run(run_log, _debug_payload())
			# "sim" is synchronous and has already finished by the time run() returns;
			# the real-clock modes have only ARMED their signal handlers and must be left
			# alive to tick. Same split as the smoke harness's CLI-vs-MCP quit rule.
			if run_log.ends_with(":sim") or not run_log.contains(":"):
				get_tree().quit()
			return

	# Debug: --b2b-shot=<kind> (windowed) renders one B2B Sales modal at 1920×1080,
	# saves a screenshot to user://, and quits. Visual verification of the widened
	# EventModal populated with the retention / escalation content. Debug builds only.
	if OS.is_debug_build():
		var shot_kind: String = _b2b_shot_requested()
		if shot_kind != "":
			_run_b2b_shot(shot_kind)
			return

	# Debug: --event-shot=<id> (windowed) renders one reactive-event JSON (incl. the
	# ev_debug_* fixtures the live pool skips) in the EventModal at 1920×1080, saves
	# a screenshot to user://, and quits. Visual verification of the paper-card
	# event modal against real event data. Debug builds only.
	if OS.is_debug_build():
		var event_shot: String = _event_shot_requested()
		if event_shot != "":
			_run_event_shot(event_shot)
			return

	# Debug: --sales-shot (windowed) mounts GameShell on the Sales tab with a seeded
	# B2B portfolio (healthy / YENİ / risk / expansion / CS-assigned) at 1920×1080,
	# screenshots, and quits. Visual verification of the redesigned Sales tab.
	if OS.is_debug_build():
		for arg in OS.get_cmdline_args():
			if String(arg) == "--sales-shot":
				_run_sales_shot()
				return
			if String(arg) == "--pitch-shot":
				_run_pitch_shot()
				return
			if String(arg) == "--probe-shot":
				_run_probe_shot()
				return
		var product_shot: String = _product_shot_requested()
		if product_shot != "":
			_run_product_shot(product_shot)
			return
		var ending_shot: String = _ending_shot_requested()
		if ending_shot != "":
			_run_ending_shot(ending_shot)
			return
		var hr_shot: String = _hr_shot_requested()
		if hr_shot != "":
			_run_hr_shot(hr_shot)
			return
		var finance_shot: String = _finance_shot_requested()
		if finance_shot != "":
			_run_finance_shot(finance_shot)
			return
		var font_spec: String = _font_spec_requested()
		if font_spec != "":
			_run_font_spec(font_spec)
			return
		var tab_shot: String = _tab_shot_requested()
		if tab_shot != "":
			_run_tab_shot(tab_shot)
			return
		var modal_shot: String = _modal_shot_requested()
		if modal_shot != "":
			_run_modal_shot(modal_shot)
			return
		var onboard_shot: String = _onboard_shot_requested()
		if onboard_shot != "":
			_run_onboard_shot(int(onboard_shot))
			return
		var theme_audit: String = _theme_audit_requested()
		if theme_audit != "":
			_run_theme_audit(theme_audit)
			return
		var oda_shot: String = _oda_shot_requested()
		if oda_shot != "":
			_run_oda_shot(oda_shot)
			return
		if "--display-check" in OS.get_cmdline_args():
			_run_display_check()
			return

	if OS.is_debug_build() and _skip_onboarding_requested():
		_skip_to_shell()
		return

	_mount_flow()


# Debug: --display-check (windowed) applies every display setting through the REAL
# DisplaySettings seam and prints what DisplayServer actually reports back, then quits.
# The screenshot harnesses cannot cover this ground — they own the window on purpose,
# so DisplaySettings.is_inert() switches itself off for them. The flag is deliberately
# NOT spelled "-shot"/"audit"/"smoke"/"spec", which are exactly the substrings the
# inert guard and SaveManager's harness sniffer match on.
# Asserting against DisplayServer rather than against our own setting is the whole
# point: it is the difference between "we wrote 1600×900 somewhere" and "the window is
# 1600×900".
func _run_display_check() -> void:
	print("DISPLAY_CHECK_BEGIN")
	print("inert=%s (must be false or nothing below is applied)" % str(DisplaySettings.is_inert()))

	# Tespit önce: aşağıdaki her şey bu üç sayıdan türüyor.
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

	# Snapshot and restore: these are the PERSISTING setters, so the check writes to
	# the player's settings.json. Driving apply_*() instead would be a weaker test that
	# also silently passes — apply_resolution gates on the STORED mode, so an applier-only
	# check leaves the store saying "borderless" and every resize is correctly refused.
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


# True when the smoke arg came from the actual command line (a CLI run) vs ProjectSettings
# main_args (the MCP editor-run path). Only CLI runs quit after the case.
func _smoke_case_on_cmdline() -> bool:
	for arg in OS.get_cmdline_args():
		if String(arg).begins_with("--endgame-smoke="):
			return true
	return false


func _run_log_requested() -> String:
	# Same dual source as --endgame-smoke: cmdline for CLI runs, run/main_args for the
	# editor/MCP path (Godot only forwards main_args on editor F5).
	var sources: Array[String] = []
	for arg in OS.get_cmdline_args():
		sources.append(String(arg))
	sources.append(String(ProjectSettings.get_setting("application/run/main_args", "")))
	for src in sources:
		for token in src.split(" ", false):
			if token.begins_with("--run-log="):
				return token.trim_prefix("--run-log=")
	return ""


func _tempo_probe_requested() -> int:
	# -1 = not requested. Cmdline only (this is a stopwatch harness, not an editor path).
	for arg in OS.get_cmdline_args():
		var s: String = String(arg)
		if s.begins_with("--tempo-probe="):
			return int(s.trim_prefix("--tempo-probe="))
	return -1


## "" = not requested. Bare --render-probe defaults to the HR ledger, the densest
## text surface in the game and therefore the worst case for glyph rasterization.
func _render_probe_requested() -> String:
	for arg in OS.get_cmdline_args():
		var s: String = String(arg)
		if s == "--render-probe":
			return "hr"
		if s.begins_with("--render-probe="):
			return s.trim_prefix("--render-probe=")
	return ""


const RENDER_PROBE_WARMUP := 45
const RENDER_PROBE_FRAMES := 180


func _run_render_probe(tab_id: String) -> void:
	get_tree().paused = false
	_shot_window(Vector2i(1920, 1080))          # --shot-size overrides
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	_seed_theme_surface()
	_shell = GAME_SHELL.instantiate()
	add_child(_shell)
	await get_tree().process_frame
	await get_tree().process_frame
	EventBus.tab_changed.emit(tab_id)
	await get_tree().create_timer(0.4).timeout

	# Warm-up is not politeness: the first frames pay shader compilation and texture
	# upload, and with mipmaps the upload is the very thing under test. Averaging them
	# in would credit the change with a cost it does not have per frame.
	for _i in RENDER_PROBE_WARMUP:
		await get_tree().process_frame

	var samples: PackedFloat64Array = []
	for _i in RENDER_PROBE_FRAMES:
		var t0: int = Time.get_ticks_usec()
		await get_tree().process_frame
		samples.append(float(Time.get_ticks_usec() - t0) / 1000.0)
	var sorted_ms: Array = Array(samples)
	sorted_ms.sort()
	var total: float = 0.0
	for v in sorted_ms:
		total += float(v)
	var win: Vector2i = get_window().size

	print("RENDER_PROBE_BEGIN")
	print("WINDOW|%dx%d|scale=%.3f|vsync=off" % [
		win.x, win.y, get_window().content_scale_factor])
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


func _run_tempo_probe(idx: int) -> void:
	# Prints "TEMPO speed=<i> day=<d> delta_ms=<n>" per day boundary, then quits.
	# Day 1 is only 15 in-game hours (INITIAL_HOUR 09:00), so the first boundary is
	# short and is used purely to start the stopwatch — the printed deltas are all
	# full 24-hour days.
	if idx <= 0 or idx >= TimeManager.SECONDS_PER_DAY.size():
		print("TEMPO ERROR bad speed index %d" % idx)
		get_tree().quit()
		return
	var stop_day: int = 6
	GameState.initialize_run(_debug_payload())
	# Force the seed so two runs at DIFFERENT speeds are comparable. initialize_run
	# seeds from Time.get_ticks_msec(), which would differ per launch and mask the
	# very thing this probe proves (tick purity: real tempo must not touch outcomes).
	GameState.run_seed = 424242
	seed(GameState.run_seed)
	# Give the HOURLY path real work to do — build effort, B2C audience flow, post-ship
	# wear and bug accrual all tick hourly, and that is where a speed-coupled bug would
	# surface. A daily-burn-only run would pass this probe trivially.
	#
	# mvp_shipped is LOAD-BEARING and was missing: SalesSystem.hourly_tick gates the whole
	# B2C half on it, and ProductSystem gates post-ship wear on it, so without it the
	# audience sat frozen at its seed value, MRR held whatever open_b2c_paid_tier derived
	# once, and the fingerprint's aud= column was a constant. The probe was proving tick
	# purity by CONSTRUCTION rather than by measurement. Real bools, not strings — event
	# conditions compare through bool() and a String-typed flag reads differently there.
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
	SalesSystem.open_b2c_paid_tier(15)   # real seam — makes MRR derive hourly too
	ProductSystem.start_build("ai_assistant",
		["ai_assistant_chat", "ai_assistant_memory"], "", "Nova")
	# start_build parks at the design band edge (PHASE_DESIGN_END) and waits for a PLAYER
	# seam. The probe never sat in that seat, so from day 3 efor= was a frozen number and
	# the build channel measured nothing. Take the seat: drive to the decision, then enter
	# development so effort keeps flowing for the probe's whole window.
	for i in 24 * 3:
		var pb: FeatureBuild = ProductSystem.get_active_build()
		if pb == null or pb.iteration_decision_pending:
			break
		ProductSystem.hourly_tick(i % 24)
	ProductSystem.enter_development()
	print("TEMPO START speed=%d want_ms=%d" % [idx, int(TimeManager.SECONDS_PER_DAY[idx] * 1000.0)])
	EventBus.day_advanced.connect(func(day: int) -> void:
		var now: int = Time.get_ticks_msec()
		if _tempo_last_msec > 0:
			print("TEMPO speed=%d day=%d delta_ms=%d" % [idx, day, now - _tempo_last_msec])
		_tempo_last_msec = now
		# State fingerprint — must be IDENTICAL across speeds for the same seed.
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


func _b2b_shot_requested() -> String:
	for arg in OS.get_cmdline_args():
		var s: String = String(arg)
		if s.begins_with("--b2b-shot="):
			return s.trim_prefix("--b2b-shot=")
	return ""


func _run_b2b_shot(kind: String) -> void:
	# Mount one B2B Sales modal into a CanvasLayer, render a couple frames, screenshot.
	get_tree().paused = false
	_shot_window(Vector2i(1920, 1080))
	_seed_run_reproducible()   # initialize_run + pinned seed (see the helper's note)
	GameState.set_flag("mvp_shipped", true)
	GameState.set_flag("mvp_market_type", "b2b")
	GameState.set_flag("mvp_sub_product_type_id", "ai_vector_search")
	var p := Prospect.new()
	p.id = "shot"
	p.company_name = "Ege Sigorta"
	p.industry = "Sigorta"
	p.archetype = "small"
	p.pain_feature_id = "ai_vec_filter"
	var c: Customer = SalesSystem.add_b2b_customer(p, 1000, 70)
	var ev: GameEvent
	if kind == "escalation":
		var cs := Character.new()
		cs.id = "char_cs_shot"
		cs.character_name = "Burcu Çetin"
		cs.role = HRConstants.ROLE_CUSTOMER_REP
		cs.category = "employee"
		cs.monthly_salary = 5000
		# expertise 5 converts to legacy cs_skill 55 EXACTLY (HRConstants shim table),
		# so this rep's churn dampen is unchanged by the axis migration.
		cs.role_stats = {"expertise": 5, "pace": 5, "rapport": 5}
		cs.traits = ["warms_up_fast"]
		CharacterRegistry.add(cs)
		CustomerRegistry.assign_customer(c.id, cs.id)
		CustomerRegistry.set_satisfaction(c.id, 22)
		ev = B2BEventFactory.build_cs_escalation(c, cs)
	elif kind == "expansion":
		CustomerRegistry.set_lifecycle_phase(c.id, "expansion")
		ev = B2BEventFactory.build_expansion(c)
	elif kind == "angel":
		# Frank's seed card. Not a B2B customer scene, but this is the harness that already
		# mounts one factory-built GameEvent in a real EventModal, and the seed card has two
		# things only a rendered frame can check: the KABUL effect chip (a modifier with no
		# _describe_modifier entry renders BLIND, and no headless case can see that) and the
		# locked REDDET row's dimmed, chip-less, non-interactive treatment.
		ev = AngelRoundSystem.build_offer_event()
	else:
		CustomerRegistry.set_lifecycle_phase(c.id, "risk")
		CustomerRegistry.set_churn_countdown(c.id, 8)
		ev = B2BEventFactory.build_retention(c)
	var layer := CanvasLayer.new()
	add_child(layer)
	var modal: Control = EVENT_MODAL.instantiate()
	layer.add_child(modal)
	modal.populate(ev)
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().create_timer(0.35).timeout
	var img: Image = get_viewport().get_texture().get_image()
	var path: String = _shot_path("b2b_shot_%s" % kind)
	img.save_png(path)
	print("[B2BShot] saved %s" % ProjectSettings.globalize_path(path))
	get_tree().quit()


func _event_shot_requested() -> String:
	for arg in OS.get_cmdline_args():
		var s: String = String(arg)
		if s.begins_with("--event-shot="):
			return s.trim_prefix("--event-shot=")
	return ""


func _run_event_shot(event_id: String) -> void:
	# Mount one reactive-event JSON into the EventModal, render, screenshot.
	# Mirrors _run_b2b_shot; loads via EventManager.debug_build_event_from_file
	# so the ev_debug_* fixtures (skipped from the live pool) stay reachable.
	get_tree().paused = false
	_shot_window(Vector2i(1920, 1080))
	_seed_run_reproducible()   # initialize_run + pinned seed (see the helper's note)
	var ev: GameEvent = EventManager.debug_build_event_from_file(
		"res://data/events/reactive/%s.json" % event_id)
	if ev == null:
		push_error("[EventShot] could not load event: %s" % event_id)
		get_tree().quit()
		return
	var layer := CanvasLayer.new()
	add_child(layer)
	var modal: Control = EVENT_MODAL.instantiate()
	layer.add_child(modal)
	modal.populate(ev)
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().create_timer(0.35).timeout
	var img: Image = get_viewport().get_texture().get_image()
	var path: String = _shot_path("event_shot_%s" % event_id)
	img.save_png(path)
	print("[EventShot] saved %s" % ProjectSettings.globalize_path(path))
	get_tree().quit()


func _run_sales_shot() -> void:
	get_tree().paused = false
	_shot_window(Vector2i(1920, 1080))
	_seed_run_reproducible()   # initialize_run + pinned seed (see the helper's note)
	GameState.day = 95
	GameState.set_flag("mvp_shipped", true)
	GameState.set_flag("mvp_market_type", "b2b")
	GameState.set_flag("mvp_sub_product_type_id", "saas_ops")
	GameState.set_flag("mvp_innovation", 45.0)
	GameState.set_flag("mvp_stability", 70.0)
	GameState.set_flag("mvp_experience", 45.0)
	GameState.set_flag("mvp_live_bug_count", 12)  # risk reason → "sık kesinti şikayeti"
	PitchSystem.spawn_prospect("small", "find")
	PitchSystem.spawn_prospect("mid", "find")
	PitchSystem.spawn_prospect("small", "find")
	_shot_customer("co_kuzey", "Kuzey İnşaat", "İnşaat", "active", 1000, 12, 90, false)
	_shot_customer("co_palmiye", "Palmiye Holding", "Sigorta", "active", 1500, 16, 150, true)
	_shot_customer("co_aras", "Aras Klinik", "Sağlık", "onboarding", 700, 6, 10, false)
	_shot_customer("co_ege", "Ege Sigorta", "Sigorta", "risk", 1000, 12, 60, false)
	CustomerRegistry.set_churn_countdown("co_ege", 8)
	_shot_customer("co_nordica", "Nordica", "Lojistik", "expansion", 2000, 20, 180, false)
	# Monthly strip figures: gained 1 / lost 2 / net -1 (mockup).
	GameState.run_customers_signed = 5
	GameState.run_customers_lost = 2
	GameState.month_ledger = {"customers_signed": 4, "customers_lost": 0}
	SalesSystem.reflect_mrr()
	_shell = GAME_SHELL.instantiate()
	add_child(_shell)
	await get_tree().process_frame
	await get_tree().process_frame
	EventBus.tab_changed.emit("sales")
	await get_tree().process_frame
	await get_tree().create_timer(0.4).timeout
	var img: Image = get_viewport().get_texture().get_image()
	var path: String = _shot_path("sales_shot")
	img.save_png(path)
	print("[SalesShot] saved %s" % ProjectSettings.globalize_path(path))
	get_tree().quit()


func _product_shot_requested() -> String:
	for arg in OS.get_cmdline_args():
		var s: String = String(arg)
		if s.begins_with("--product-shot="):
			return s.trim_prefix("--product-shot=")
	return ""


func _ending_shot_requested() -> String:
	for arg in OS.get_cmdline_args():
		var s: String = String(arg)
		if s.begins_with("--ending-shot="):
			return s.trim_prefix("--ending-shot=")
	return ""


func _hr_shot_requested() -> String:
	for arg in OS.get_cmdline_args():
		var s: String = String(arg)
		if s.begins_with("--hr-shot="):
			return s.trim_prefix("--hr-shot=")
	return ""


func _finance_shot_requested() -> String:
	for arg in OS.get_cmdline_args():
		var s: String = String(arg)
		if s.begins_with("--finance-shot="):
			return s.trim_prefix("--finance-shot=")
	return ""


func _font_spec_requested() -> String:
	for arg in OS.get_cmdline_args():
		var s: String = String(arg)
		if s.begins_with("--font-spec="):
			return s.trim_prefix("--font-spec=")
	return ""


# Debug: --font-spec=<a|b|c|c-opsz> (windowed) — "Font Duruşması", the type specimen the
# Theme Core task picks a family from. Renders IDENTICAL real-game content (gazete başlığı,
# event modal, HR kartı, veri şeridi, Türkçe diakritik satırı, mikro boy satırı) in one
# candidate font set at 1920×1080, screenshots, and quits.
#   a       — current: Source Serif 4 / IBM Plex Sans / JetBrains Mono
#   b       — literary: Spectral / Public Sans / IBM Plex Mono
#   c       — warm: Fraunces / Inter / Space Mono (variable axes at family defaults)
#   c-opsz  — same as c with the opsz axis pinned to each label's px size
# Unlike every other shot flag this one seeds NO game state — the specimen is pure type. The
# candidate TTFs live in user://font_spec/ (outside the repo) and are loaded at runtime, so
# nothing is imported into the project. Throwaway harness; remove once Theme Core is verified.
func _run_font_spec(set_id: String) -> void:
	get_tree().paused = false
	_shot_window(Vector2i(1920, 1080))
	var layer := CanvasLayer.new()
	add_child(layer)
	# load() not preload(): the normal boot path never touches the debug scene, and deleting
	# the debug folder after the pick cannot break main.gd.
	var spec: Control = load("res://scenes/debug/FontSpecimen.tscn").instantiate()
	layer.add_child(spec)
	if not spec.build(set_id):
		get_tree().quit(1)
		return
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().create_timer(0.35).timeout
	var img: Image = get_viewport().get_texture().get_image()
	var path: String = _shot_path("font_spec_%s" % set_id)
	img.save_png(path)
	print("[FontSpec] saved %s (%dx%d)" % [
		ProjectSettings.globalize_path(path), img.get_width(), img.get_height()])
	get_tree().quit()


# ============================================================================
# Tema Çekirdeği doğrulama koşumu (2026-08-03) — --tab-shot / --modal-shot /
# --onboard-shot / --theme-audit. Hepsi debug-only ve YALNIZ cmdline okur
# (main_args istisnası --endgame-smoke'a ait, orada kalıyor).
#
# Neden ayrı bir aile: temanın base-type varsayılanları (default_font_size, base
# Label font_color, base Panel stylebox) STİLSİZ kontrolleri etkiler — yani tam
# olarak mevcut shot harness'larının kadraja almadığı yüzeyleri. Bu dördü o boşluğu
# kapatır ve before/after karşılaştırmasını mümkün kılar.
# ============================================================================

# Her shot harness'ının ortak açılışı. `initialize_run` payload'ı boş GEÇİLEMEZ
# (iki kurucu validator'ı da takılır), ama asıl mesele ikinci satır:
#
# initialize_run tohumu `Time.get_ticks_msec()`ten alır — yani her başlatmada FARKLI.
# Ekran görüntüsü matrisi bunu kaldıramaz: before/after karşılaştırması, temanın
# değiştirdiği pikselleri tohumun değiştirdiklerinden ayırt edemez ve hash-eşitlik
# kapısı anlamını yitirir. Sabitlenmiş tohum karşılaştırmayı geçerli kılan şeydir.
# Aynı gerekçeyle _run_tempo_probe zaten 424242'yi elle sabitliyordu (orada tick
# saflığını ölçebilmek için); bu yardımcı o kararı tüm shot ailesine yayıyor.
func _seed_run_reproducible() -> void:
	GameState.initialize_run(_debug_payload())
	GameState.run_seed = 424242
	seed(GameState.run_seed)


# Her shot harness'ının ikinci ortak satırı. Ham `get_window().size = ...` ARTIK
# YETMİYOR: Settings task'ıyla birlikte varsayılan pencere modu KENARLIKSIZ oldu ve
# kenarlıksız/tam-ekran bir pencerede boyut ataması sessizce yutulur — 15 harness da
# ekranın gerçek çözünürlüğünde kadraj alır, tüm PNG baseline'ları kayar. Önce
# pencereli moda düşürüp sonra boyutu vermek bunu kapatır.
# Headless'ta DisplayServer no-op'tur; çağrı zararsızdır, koşul eklemeye gerek yok.
func _shot_window(size: Vector2i) -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	var win_size: Vector2i = _shot_size_override(size)
	get_window().size = win_size
	# Ölçek doğrulaması (--shot-scale). 15 runner'ın hepsi 1920×1080'e sabitlenmiş
	# olduğu için ölçek matrisi başka türlü ÖLÇÜLEMEZ: %75 yalnız 1440p ve üstünde
	# yasal, 1080p'de kapıya takılır — yani sabit pencerede çekilen bir "%75 shot"
	# aslında %100 olurdu ve hiçbir şey kanıtlamazdı. Kapının KENDİSİNİ çalıştırıyoruz
	# (clamp_step), atlamıyoruz: ölçek yasadışıysa shot da tıpkı oyun gibi yukarı kırpar.
	var step: float = _shot_scale_override()
	if step > 0.0:
		var legal: float = DisplaySettings.clamp_step(step, win_size)
		# GECİKTİRİLMİŞ uygulama, ve bu ŞART. Pencere yeniden boyutlanması bir sonraki
		# kareye kadar yürürlüğe girmiyor; content_scale_factor'ü hemen burada yazarsak
		# viewport ESKİ boyuta göre hesaplanır ve mantıksal görünüm hiç küçülmez —
		# sonuç, 1920'lik tasarımın 1.5x büyütülüp KIRPILMASI olur (TopBar'ın iki ucu
		# birden kesilir). Gerçek oyunda bu tuzak yok: DisplaySettings.apply_ui_scale
		# zaten yerleşmiş bir pencereye yazıyor. Runner'lar yakalamadan önce ≥0.35s
		# bekliyor, yani 0.15s buraya rahat sığıyor.
		get_tree().create_timer(0.15).timeout.connect(
			func() -> void: get_window().content_scale_factor = legal)
		print("[Shot] pencere %dx%d · ölçek istendi %d%% → uygulandı %d%%" % [
			win_size.x, win_size.y, int(round(step * 100.0)), int(round(legal * 100.0))])


# Her shot harness'ının ÜÇÜNCÜ ortak satırı: çıktı yolu. Dosya adı DİLİ taşır, çünkü
# lokalizasyon doğrulaması aynı ekranın TR ve EN çiftini yan yana okumak zorunda —
# sabit adlarla ikinci koşu birincinin üstüne yazar ve matris sessizce tek dil olur.
# TR tarihsel adı KORUR (`tab_shot_product.png`), yani süpürme öncesi çekilen her
# baseline yolu geçerli kalır; yalnız EN koşusu `_en` eki alır. Kaynak locale'in
# KENDİSİ, `--lang` değil: Ayarlar'dan gelen dil de, zorlanan dil de aynı biçimde
# adlandırılsın (bir EN shot'ı hangi yolla EN olduğuna bakılmaksızın _en'dir).
func _shot_path(basename: String) -> String:
	var suffix: String = "_en" if TranslationServer.get_locale().begins_with("en") else ""
	return "user://%s%s.png" % [basename, suffix]


## --shot-size=2560x1440 → shot penceresini büyütür (varsayılan: runner'ın verdiği boy).
func _shot_size_override(fallback: Vector2i) -> Vector2i:
	for arg in OS.get_cmdline_args():
		var s: String = String(arg)
		if s.begins_with("--shot-size="):
			var parts: PackedStringArray = s.trim_prefix("--shot-size=").split("x")
			if parts.size() == 2 and parts[0].is_valid_int() and parts[1].is_valid_int():
				return Vector2i(int(parts[0]), int(parts[1]))
			push_warning("[Shot] --shot-size bozuk (beklenen GENIŞLIKxYÜKSEKLIK): %s" % s)
	return fallback


## --shot-scale=0.75 → arayüz ölçeği adımı. 0.0 = dokunma.
func _shot_scale_override() -> float:
	for arg in OS.get_cmdline_args():
		var s: String = String(arg)
		if s.begins_with("--shot-scale="):
			return String(s.trim_prefix("--shot-scale=")).to_float()
	return 0.0


func _tab_shot_requested() -> String:
	for arg in OS.get_cmdline_args():
		var s: String = String(arg)
		if s.begins_with("--tab-shot="):
			return s.trim_prefix("--tab-shot=")
	return ""


func _modal_shot_requested() -> String:
	for arg in OS.get_cmdline_args():
		var s: String = String(arg)
		if s.begins_with("--modal-shot="):
			return s.trim_prefix("--modal-shot=")
	return ""


func _onboard_shot_requested() -> String:
	for arg in OS.get_cmdline_args():
		var s: String = String(arg)
		if s.begins_with("--onboard-shot="):
			return s.trim_prefix("--onboard-shot=")
	return ""


func _theme_audit_requested() -> String:
	for arg in OS.get_cmdline_args():
		var s: String = String(arg)
		if s.begins_with("--theme-audit="):
			return s.trim_prefix("--theme-audit=")
	return ""


func _oda_shot_requested() -> String:
	for arg in OS.get_cmdline_args():
		var s: String = String(arg)
		if s.begins_with("--oda-shot="):
			return s.trim_prefix("--oda-shot=")
	return ""


# Debug: --oda-shot=<day|evening|night|dawn|event|tab|tour|hover|market1|market2>
# (windowed). ODA merkez görünümünün dört
# durum fotoğrafı (task doğrulama #9): day = temiz masa + canlı ürün monitörü;
# night = saat 23 + mesai + masada kâğıtlar (crossfade otursun diye uzun bekleme);
# event = gerçek pipeline'dan debug olayı (telefon buzz + telefondan doğan kart);
# tab = sekme sayfası + ODAYA DÖN ✕. Tur burada TETİKLENMEZ (MentorIntro mount
# edilmiyor) — Settings bayrağına yazmayız, Erdem'in gerçek dosyası kirlenmez.
func _run_oda_shot(kind: String) -> void:
	get_tree().paused = false
	_shot_window(Vector2i(1920, 1080))
	# D3 durum fixture'ları: market1 = ürün piyasada değil (pay kartı YOK);
	# market2 = çıktı ama MRR 0 (tek yönlendirme satırı). Diğerleri ortak yüzey
	# seed'i (shipped + 3 müşteri → durum-3 tablosu).
	if kind == "market1":
		_seed_run_reproducible()
	elif kind == "market2":
		_seed_run_reproducible()
		GameState.day = 40
		GameState.set_flag("mvp_shipped", true)
		GameState.set_flag("mvp_product_name", "Pulse")
		GameState.set_flag("mvp_market_type", "b2b")
		GameState.set_flag("mvp_sub_product_type_id", "saas_ops")
	else:
		_seed_theme_surface()
	_shell = GAME_SHELL.instantiate()
	add_child(_shell)
	_shell_mounted = true
	await get_tree().process_frame
	await get_tree().process_frame
	var oda: Control = _shell.get_node_or_null("MidRow/CenterViewport/OdaView")
	if oda == null:
		push_error("[OdaShot] OdaView bulunamadı")
		get_tree().quit(1)
		return
	var settle: float = 0.6
	match kind:
		"day":
			GameState.set_current_hour(14)
		"night":
			HROvertimeSystem.start("product_dev", 3)
			GameState.set_current_hour(23)
			oda.debug_seed_papers()
			settle = 3.2   # gece crossfade'i (LIGHT_FADE_S = 1.5 sn) otursun, payla
		# Dört-durum ışık makinesinin ARA iki durumu (mühürlü sanat turu 2026-08-17).
		# Eskiden shot yüzeyi yoktu, yani AKŞAM ve ŞAFAK tint'leri contact sheet'te
		# hiç görünmüyordu — üstelik gece ILIK olunca akşamın hâlâ ayrı bir vuruş
		# olarak okuyup okumadığı tam da gözle karara kalan şey. _light_state_for_hour
		# eşikleri: 18 = akşam, 6 = şafak (19-05 gece, kalanı gündüz).
		"evening":
			GameState.set_current_hour(18)
			settle = 3.2
		"dawn":
			GameState.set_current_hour(6)
			settle = 3.2
		"event":
			if not _event_signals_wired:
				EventBus.modal_requested.connect(_on_event_modal_requested)
				_event_signals_wired = true
			var ev: GameEvent = EventManager.debug_build_event_from_file(
				"res://data/events/reactive/ev_debug_002_press_inquiry.json")
			if ev == null:
				push_error("[OdaShot] debug olayı yüklenemedi")
				get_tree().quit(1)
				return
			EventManager.enqueue(ev)
			settle = 1.0
		"tab":
			EventBus.tab_changed.emit("product")
		"tour":
			# Açılış turunun TEK doğrulama yüzeyi. Turun kendi kapsama alanı yoktu, ve
			# tam olarak orada bir hata yaşıyordu: OdaView'un çocuğuyken dim'i yalnız
			# CenterViewport'u kaplıyor, TopBar ile sol ray altında canlı kalıyordu.
			# Bu shot'ın kanıtlaması gereken şey, karartmanın kenardan kenara olduğu.
			Settings.set_value("oda_intro_seen", false)
			GameState.set_current_hour(14)
			oda.start_intro_tour_if_unseen()
			settle = 1.0
		"hover":
			# G2 kapısı kanıtı: dört hover muamelesi tek karede (rim ×2 + kart
			# kenarı + çerçeve halkaları) — dikdörtgen/dolgu parlarsa burada görünür.
			GameState.set_current_hour(14)
			oda.debug_hover_anchors()
		"milestones":
			# D5 dokümanı kanıtı: çerçeve tıkının rotası.
			EventBus.tab_changed.emit("milestones")
		"market1", "market2":
			GameState.set_current_hour(14)
		_:
			push_error("[OdaShot] bilinmeyen tür: %s" % kind)
			get_tree().quit(1)
			return
	await get_tree().process_frame
	await get_tree().create_timer(settle).timeout
	var img: Image = get_viewport().get_texture().get_image()
	var path: String = _shot_path("oda_shot_%s" % kind)
	img.save_png(path)
	print("[OdaShot] saved %s" % ProjectSettings.globalize_path(path))
	get_tree().quit()


# Tema matrisinin ORTAK seed'i: --tab-shot ile --theme-audit AYNI durumu görmeli,
# yoksa metinsel denetim ile ekran görüntüsü birbirini doğrulayamaz. Sekmelerin
# dolu render etmesi yeter — bu bir görsel regresyon fixture'ı, ekonomi testi değil.
func _seed_theme_surface() -> void:
	_seed_run_reproducible()   # initialize_run + pinned seed (see the helper's note)
	GameState.day = 95
	GameState.set_flag("mvp_shipped", true)
	GameState.set_flag("mvp_market_type", "b2b")
	GameState.set_flag("mvp_sub_product_type_id", "saas_ops")
	GameState.set_flag("mvp_innovation", 45.0)
	GameState.set_flag("mvp_stability", 70.0)
	GameState.set_flag("mvp_experience", 45.0)
	GameState.set_flag("mvp_live_bug_count", 12)
	_seed_hr_roster()
	_shot_customer("co_kuzey", "Kuzey İnşaat", "İnşaat", "active", 1000, 12, 90, false)
	_shot_customer("co_ege", "Ege Sigorta", "Sigorta", "risk", 1000, 12, 60, false)
	_shot_customer("co_nordica", "Nordica", "Lojistik", "expansion", 2000, 20, 180, false)
	PitchSystem.spawn_prospect("small", "find")
	PitchSystem.spawn_prospect("mid", "find")
	SalesSystem.reflect_mrr()


# Debug: --tab-shot=<product|hr|finance|sales|ops|rnd|personal|events> (windowed).
# 8 ray sekmesinin HEPSİ tek seed'li durumdan 1920×1080. Ops/R&D/Personal/Events'in
# sahnesi yok — kod-boyalı placeholder render ederler (TabPageChrome sarmalayıcısı
# içinde). NOT (ODA rework, 2026-08-06): sarmalayıcı şeridi + RightPanel emekliliği
# TÜM tab-shot baseline'larını bilinçli yeniden kurdu; bayt-diff referansı o günün
# after-set'idir, Tema Çekirdeği baseline'ı değil.
func _run_tab_shot(tab_id: String) -> void:
	get_tree().paused = false
	_shot_window(Vector2i(1920, 1080))
	_seed_theme_surface()
	_shell = GAME_SHELL.instantiate()
	add_child(_shell)
	await get_tree().process_frame
	await get_tree().process_frame
	EventBus.tab_changed.emit(tab_id)
	await get_tree().process_frame
	await get_tree().create_timer(0.4).timeout
	var img: Image = get_viewport().get_texture().get_image()
	var path: String = _shot_path("tab_shot_%s" % tab_id)
	img.save_png(path)
	print("[TabShot] saved %s" % ProjectSettings.globalize_path(path))
	get_tree().quit()


# Debug: --modal-shot=<confirm|confirm3|settings|month|system|saveload> (windowed).
# Modal katmanını kadraja alır.
# Her biri GERÇEK mount yolundan geçer (EventBus sinyali → main.gd handler'ı), böylece
# fixture ile canlı davranış ayrışamaz. `confirm` ayrıca ConfirmModal.tscn'in 4 ölü
# font-rengi override'ına ulaşır (süpürme batch 1'in kanıtı).
func _run_modal_shot(kind: String) -> void:
	get_tree().paused = false
	_shot_window(Vector2i(1920, 1080))
	_seed_theme_surface()
	_shell = GAME_SHELL.instantiate()
	add_child(_shell)
	_shell_mounted = true
	await get_tree().process_frame
	await get_tree().process_frame
	# The normal flow wires these in _swap_to_shell_and_modal; this shot mounts the shell
	# by hand, so without them all three emits below land in the VOID and the harness
	# saves three byte-identical pictures of the empty room — which is what the team was
	# byte-diffing its modal baselines against. Guarded is_connected form (the --pitch-shot
	# precedent) rather than the shared _event_signals_wired latch, which guards a
	# different, larger connect set.
	if not EventBus.confirm_requested.is_connected(_on_confirm_requested):
		EventBus.confirm_requested.connect(_on_confirm_requested)
	if not EventBus.settings_requested.is_connected(_on_settings_requested):
		EventBus.settings_requested.connect(_on_settings_requested)
	if not EventBus.month_ended.is_connected(_on_month_ended):
		EventBus.month_ended.connect(_on_month_ended)
	if not EventBus.system_menu_requested.is_connected(_on_system_menu_requested):
		EventBus.system_menu_requested.connect(_on_system_menu_requested)
	if not EventBus.save_load_requested.is_connected(_on_save_load_requested):
		EventBus.save_load_requested.connect(_on_save_load_requested)
	match kind:
		"confirm":
			EventBus.confirm_requested.emit({
				"title": "Geliştirmeyi iptal et?",
				"body": "Nova v3 build'i durur ve harcanan efor geri gelmez.",
				"confirm_text": "İPTAL ET",
				"cancel_text": "VAZGEÇ",
			})
		"confirm3":
			# Üç butonlu hâl (SaveManager task'ı): panel genişlemesinin kanıtı. Aynı
			# gerçek yoldan geçer — alt_text varlığı butonu açar, yokluğu gizli tutar.
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
		"saveload":
			# Önce gerçek bir kayıt yaz, sonra YÜKLE modunda aç — boş liste yerine
			# gerçek bir slot satırı (meta biçimi + aksiyon butonları) kadraja girsin.
			SaveManager.quicksave()
			EventBus.save_load_requested.emit("load")
		_:
			push_error("[ThemeShot] unknown --modal-shot kind: %s" % kind)
			get_tree().quit(1)
			return
	await get_tree().process_frame
	await get_tree().create_timer(0.4).timeout
	var img: Image = get_viewport().get_texture().get_image()
	var path: String = _shot_path("modal_shot_%s" % kind)
	img.save_png(path)
	print("[ModalShot] saved %s" % ProjectSettings.globalize_path(path))
	get_tree().quit()


# Debug: --onboard-shot=<1|2|3> (windowed). Onboarding'in KOYU register'ı — açık gövde
# varsayılanlarının koyu yüzeye sızmadığını gösteren tek kontrol noktası. Ayrıca
# OnboardingFlow.tscn:108'deki ham `font_size = 18`e ulaşır.
func _run_onboard_shot(step: int) -> void:
	get_tree().paused = false
	_shot_window(Vector2i(1920, 1080))
	_mount_flow()
	await get_tree().process_frame
	await get_tree().process_frame
	var idx: int = clampi(step - 1, 0, 2)
	if idx > 0:
		_flow._mount_step(idx)   # doğrudan seam: adım geçerliliği fixture'da doldurulmuş olmayabilir
		await get_tree().process_frame
	await get_tree().create_timer(0.4).timeout
	var img: Image = get_viewport().get_texture().get_image()
	var path: String = _shot_path("onboard_shot_%d" % step)
	img.save_png(path)
	print("[OnboardShot] saved %s" % ProjectSettings.globalize_path(path))
	get_tree().quit()


# Debug: --theme-audit=<tab_id> (windowed, ekran görüntüsü YOK). Monte edilmiş ağacı
# gezer ve her Control için ÇÖZÜMLENMİŞ tema değerlerini basar. Bu, matrisin BİRİNCİL
# kanıtıdır: metinsel diff kenar yumuşatma gürültüsüne bağışıktır ve "hangi 40 düğüm
# neden değişti" sorusunu ekran görüntüsünün cevaplayamadığı kesinlikte cevaplar.
# Son alan yerel override bayrağı — S=font_size, C=font_color, P=panel stylebox:
# süpürmenin avladığı şey tam olarak odur.
## `--theme-audit=oda` ODA'nın KAPISIDIR ve ayrı bir moddur. Terminal reskin'i
## sırasında "ODA kımıldamadı" iddiasının PİKSELLE kanıtlanamayacağı ölçüldü:
## --oda-shot kareleri iki değer arasında gidip geliyor (night/market1/market2/
## event/tab/tour üç koşuda bimodal çıktı — tween fazı/kare yarışı, tema değil).
## Bu yüzden ODA kapısı METİNSEL: yalnız OdaView alt ağacını gezer ve her düğümün
## ÇÖZÜMLENMİŞ tema değerlerini basar. Zamanlamaya bağışıktır, kabuk değişikliğinden
## etkilenmez (kabuk ağacın dışında kalır) ve tam olarak değiştirdiğim şeyi —
## tema çözümlemesini — ölçer.
func _run_theme_audit(tab_id: String) -> void:
	get_tree().paused = false
	_shot_window(Vector2i(1920, 1080))
	_seed_theme_surface()
	_shell = GAME_SHELL.instantiate()
	add_child(_shell)
	await get_tree().process_frame
	await get_tree().process_frame
	var oda_mode: bool = tab_id == "oda"
	if oda_mode:
		GameState.set_current_hour(14)      # sabit ışık durumu: gündüz
		EventBus.tab_changed.emit("")       # sekme yok → OdaView görünür
	else:
		EventBus.tab_changed.emit(tab_id)
	await get_tree().process_frame
	await get_tree().create_timer(0.4).timeout
	var root: Node = _shell
	if oda_mode:
		root = _shell.get_node_or_null("MidRow/CenterViewport/OdaView")
		if root == null:
			push_error("[ThemeAudit] OdaView bulunamadı")
			get_tree().quit(1)
			return
	print("AUDIT_BEGIN %s" % tab_id)
	_audit_walk(root, "")
	print("AUDIT_END %s" % tab_id)
	get_tree().quit()


# Debug: --probe-shot (windowed, 1920×1080). ThemeProbe.tscn — SIFIR-stil kontrol
# envanteri: her temel Control sınıfından varyasyonsuz/override'sız birer örnek. Base-type
# varsayılanlarının çıplak bir Control'ü marka içinde render ettiğinin kalıcı kanıtı; oyun
# durumu GEREKMEZ (sahne saf Control). Ekran görüntüsü + _audit_walk dökümü AYNI koşudan
# basılır (PROBE_BEGIN/END), piksel ile çözümlenmiş değer birbirini doğrular.
func _run_probe_shot() -> void:
	get_tree().paused = false
	_shot_window(Vector2i(1920, 1080))
	var probe: Control = (load("res://scenes/debug/ThemeProbe.tscn") as PackedScene).instantiate()
	add_child(probe)
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().create_timer(0.4).timeout
	var img: Image = get_viewport().get_texture().get_image()
	var path: String = _shot_path("probe_shot")
	img.save_png(path)
	print("[ProbeShot] saved %s" % ProjectSettings.globalize_path(path))
	print("PROBE_BEGIN")
	_audit_walk(probe, "")
	print("PROBE_END")
	get_tree().quit()


# Metin ÇİZEN sınıflar. Bir Panel ya da ColorRect için get_theme_font_size("font_size")
# de 16 döner ama o değer hiçbir yere çizilmez — denetime karışırsa gerçek sinyali
# gömer. RichTextLabel bilerek ayrı: onun anahtarları normal_font_size/default_color,
# "font_size" sorarsak sessizce motor varsayılanına düşer ve 16 diye YALAN söyler.
const _AUDIT_TEXT_CLASSES := [
	"Label", "Button", "LineEdit", "CheckBox", "CheckButton", "OptionButton",
	"MenuButton", "LinkButton", "TextEdit", "SpinBox",
]


func _audit_walk(node: Node, path: String) -> void:
	for child in node.get_children():
		var p: String = path + "/" + String(child.name)
		var c := child as Control
		if c != null:
			var variation: String = String(c.theme_type_variation)
			if variation == "":
				variation = "--"
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
			if ovr == "":
				ovr = "-"
			# YÜZ ve YÜZEY (Terminal reskin'iyle eklendi). Renk+boyut tek başına bir
			# tema parmak izi DEĞİL: kart arka planı ya da font yüzü değiştiğinde
			# eski altı alan kımıldamıyordu. `font` yüz dosyasının adı, `sb` ise
			# çözümlenmiş `panel` stylebox'ının dolgu/kenar/yarıçapı — ODA kapısının
			# arka plan repaint'ini yakalayabilmesi tam olarak buna bağlı.
			print("AUDIT|%s|%s|%s|%s|%s|%s|%s|%s" % [
				p, cls, variation, fs, col, ovr, _audit_font(c, size_key), _audit_stylebox(c)])
		_audit_walk(child, p)


## Çözümlenmiş yazı yüzünün dosya adı ("mono_label" gibi) — yalnız metin çizen
## sınıflar için; ötekilerde motor varsayılanı döner ve gürültü olur.
func _audit_font(c: Control, size_key: String) -> String:
	if size_key == "":
		return "-"
	var font_key: String = "normal_font" if size_key == "normal_font_size" else "font"
	if not c.has_theme_font(font_key):
		return "-"
	var f: Font = c.get_theme_font(font_key)
	if f == null:
		return "-"
	return f.resource_path.get_file().get_basename() if f.resource_path != "" else f.get_class()


## Çözümlenmiş `panel` stylebox'ının parmak izi. StyleBoxFlat olmayanlar (çizgi,
## boş) sınıf adıyla geçilir — tip değişimi de bir sinyaldir.
func _audit_stylebox(c: Control) -> String:
	if not c.has_theme_stylebox("panel"):
		return "-"
	var sb: StyleBox = c.get_theme_stylebox("panel")
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


# Debug: --finance-shot=<ozet|artida|uyari> (windowed). Finance Tab v1 doğrulaması: gerçek
# seam'lerle ~40 gün oynanmış durum kurar (nakit ring buffer + işlem ledger'ı gerçek
# akıştan dolar), GameShell'i Finans sekmesinde 1920×1080 açar, screenshot alır, çıkar.
#   ozet   — negatif net: çatallı projeksiyonlar, son işlemlerde imza + retainer karışık
#   artida — MRR > burn: yeşil ARTIDA durumu, kırmızı erime projeksiyonu YOK
#   uyari  — runway < 6 ay: krem mentor kartı + ERTELE görünür
func _run_finance_shot(kind: String) -> void:
	get_tree().paused = false
	_shot_window(Vector2i(1920, 1080))
	_seed_run_reproducible()   # initialize_run + pinned seed (see the helper's note)
	GameState.set_flag("mvp_shipped", true)
	GameState.set_flag("mvp_market_type", "b2b")
	GameState.set_flag("mvp_sub_product_type_id", "saas_ops")
	_seed_hr_roster()
	var start_cash: int = 150000 if kind == "uyari" else 300000
	GameState.set_cash(start_cash)
	# Fixture nakdi gün-1 örneğinin üstüne yazılır — tek-yazar kuralının TEK debug istisnası
	# (initialize_run origin nakdiyle örnekledi; eğri fixture nakdinden başlamalı).
	GameState.cash_history = [{"day": GameState.day, "cash": GameState.cash}]
	# artida: 3 imza × 20K = 60K MRR → günlük gelir 2000 > kadro burn'ü (~1500) → net pozitif
	var sign_mrr: int = 20000 if kind == "artida" else 1100
	for i in range(40):
		GameState.advance_day()
		if i == 10 or (kind == "artida" and (i == 12 or i == 14)):
			var pr: Prospect = PitchSystem.spawn_prospect("mid", "find")
			SalesSystem.add_b2b_customer(pr, sign_mrr, 70)   # pozitif işlem satırı + MRR
			ProspectRegistry.remove(pr.id)
		if i == 20 and kind != "artida":
			# Peşin arayış ücreti → negatif işlem satırı ("İşe alım")
			HRSearchSystem.start_search(HRConstants.ROLE_DEVELOPER, "mid")
		if i == 30 and kind == "ozet":
			var pr2: Prospect = PitchSystem.spawn_prospect("small", "find")
			SalesSystem.add_b2b_customer(pr2, 800, 72)
			ProspectRegistry.remove(pr2.id)
		FinanceSystem.daily_tick()
	# Açık pipeline kalsın: iyimser projeksiyon gerçek prospect'lerden beslenir.
	PitchSystem.spawn_prospect("small", "find")
	PitchSystem.spawn_prospect("mid", "find")
	_shell = GAME_SHELL.instantiate()
	add_child(_shell)
	await get_tree().process_frame
	await get_tree().process_frame
	EventBus.tab_changed.emit("finance")
	await get_tree().process_frame
	await get_tree().create_timer(0.4).timeout
	var img: Image = get_viewport().get_texture().get_image()
	var path: String = _shot_path("finance_shot_%s" % kind)
	img.save_png(path)
	print("[FinanceShot] saved %s" % ProjectSettings.globalize_path(path))
	get_tree().quit()


# Debug: --hr-shot=<ekip|atlas|dosyalar|zam|mesai> (windowed). Seeds a roster across all
# three departments (one on leave, one burning out, one fresh hire), mounts GameShell on the
# HR tab at 1920×1080, drives it to the requested surface, screenshots to user://, and quits.
# Mirrors the --product-shot harness. Debug builds only.
func _run_hr_shot(kind: String) -> void:
	get_tree().paused = false
	_shot_window(Vector2i(1920, 1080))
	_seed_run_reproducible()   # initialize_run + pinned seed (see the helper's note)
	GameState.day = 64
	if kind != "bos":
		_seed_hr_roster()
		# Beş kişilik bir kadro $10K başlangıç nakdiyle tutarsız (runway anında 0 okur ve
		# işe alım önizlemesi anlamsızlaşır). Seri-A öncesi bir şirketin kasası + burn'ün
		# maaşları görmesi için tek finans tick'i: üst bar ile önizlemeler aynı gerçeği okur.
		GameState.set_cash(240000)
		FinanceSystem.daily_tick()
	match kind:
		"dosyalar":
			# Files ON THE TABLE: start a search, then run the arrival window's worth of
			# HR ticks so the generator's real output is what renders.
			HRSearchSystem.start_search(HRConstants.ROLE_DEVELOPER, "mid")
			for _i in HRConstants.SEARCH_ARRIVAL_MAX_DAYS:
				GameState.day += 1
				HRSearchSystem.daily_tick()
		"atlas":
			pass   # temiz modal: rol/bant seçimi
		"mesai":
			pass   # panel departman başlığından açılır, aşağıda
		"gider":
			# §5 doğrulaması: bir arayış başlat (peşin ücret) ve bir mesai bloğu çalıştır,
			# sonra Finans sekmesine geç — gider dökümünde hem "İşe alım" tek seferlik
			# satırı hem de "Ek mesai" kalemi görünmeli.
			HRSearchSystem.start_search(HRConstants.ROLE_DEVELOPER, "mid")
			HROvertimeSystem.start(HRConstants.DEPT_PRODUCT_DEV, 7)
			HROvertimeSystem.daily_tick()
			FinanceSystem.daily_tick()
			# daily_tick ledger'ı temizler (yeni gün), o yüzden tek seferlik gider tick'ten
			# SONRA yeniden işleniyor — oyunda da böyle olur: harcama gün içinde yapılır.
			FinanceSystem.apply_one_time_cost(
				HRConstants.SEARCH_RETAINER, HRConstants.COST_LABEL_HIRE)
		_:
			# "ekip": bekleyen bir arayış da görünsün (Kare 3 şeridi).
			HRSearchSystem.start_search(HRConstants.ROLE_DESIGNER, "senior")
			GameState.day += 1
			HRSearchSystem.daily_tick()
	_shell = GAME_SHELL.instantiate()
	add_child(_shell)
	await get_tree().process_frame
	await get_tree().process_frame
	# "egitim": DENEYİM/EĞİTİM satır durumlarının TEK görsel kanıtı. Biri deneyimi
	# dolmuş (EĞİTİME GÖNDER görünür), biri eğitimde (geri sayan çip), biri yarı yolda
	# (mini bar dolu değil) — üç durum tek karede.
	if kind == "egitim":
		var roster: Array[Character] = CharacterRegistry.get_employees()
		if roster.size() >= 3:
			CharacterRegistry.add_experience(roster[0].id, HRConstants.EXPERIENCE_MAX)
			CharacterRegistry.add_experience(roster[1].id, HRConstants.EXPERIENCE_MAX)
			CharacterRegistry.begin_training(roster[1].id)
			CharacterRegistry.add_experience(roster[2].id, 42)

	# "gider" Finans sekmesinde çekilir (gider dökümü orada yaşıyor), diğerleri HR'da.
	EventBus.tab_changed.emit("finance" if kind == "gider" else "hr")
	if kind == "gider":
		await get_tree().process_frame
		await get_tree().create_timer(0.4).timeout
		var gimg: Image = get_viewport().get_texture().get_image()
		var gpath: String = _shot_path("hr_shot_gider")
		gimg.save_png(gpath)
		print("[HRShot] saved %s" % ProjectSettings.globalize_path(gpath))
		get_tree().quit()
		return
	await get_tree().process_frame
	await get_tree().process_frame
	var cv: Node = _shell.find_child("CenterViewport", true, false)
	var tab: Node = cv.get_current_page_body()   # TabPageChrome sarmalayıcısı içinden (ODA rework onarımı)
	if tab == null:
		push_error("[HRShot] sekme gövdesi bulunamadı (get_current_page_body null)")
		get_tree().quit(1)
		return
	match kind:
		"atlas", "dosyalar":
			tab._open_atlas()
		"zam":
			# TERMINAL DEFTERİ ONARIMI (2026-08-08). Eskiden kart açılıp satır İÇİNDEKİ
			# "ZAM YAP" butonuna basılıyordu. Defter düzeninde satır içi aksiyon butonu
			# YOK — aksiyonlar satır tıklamasının açtığı HRPopover'da yaşıyor, yani
			# `_press_button_labelled` sessizce hiçbir şey bulamıyor ve bu shot çıplak
			# defteri çekiyordu (ölçüldü: hr_shot_zam popover'sız çıktı). Artık satırın
			# GERÇEK yolu sürülüyor: `_on_card_action("open", id)` — popover'ın konum
			# kodu (sağa yerleş / taşarsa sola dön / kenara kelepçele) doğrulanmış kalır.
			var target: Character = CharacterRegistry.get_employees()[0]
			# ÇAPA GERÇEK SATIR OLMALI: popover konum kodu (sağa yerleş / taşarsa sola
			# dön / kenara kelepçele) çapanın ekrandaki dikdörtgeninden türüyor, o yüzden
			# sayfayı çapa geçmek testi sessizce zayıflatırdı.
			var row_anchor: Control = null
			for child in tab._list.get_children():
				if child is PanelContainer and String(child.theme_type_variation) == "LedgerRow":
					row_anchor = child
					break
			if row_anchor == null:
				push_error("[HRShot] defter satırı bulunamadı — zam popover'ı çapasız")
				get_tree().quit(1)
				return
			tab._on_card_action(target.id, HREmployeeCard.ACTION_RAISE, row_anchor)
		"mesai":
			_press_button_labelled(tab, "EK MESAİ")
		_:
			pass
	await get_tree().process_frame
	await get_tree().create_timer(0.5).timeout
	var img: Image = get_viewport().get_texture().get_image()
	var path: String = _shot_path("hr_shot_%s" % kind)
	img.save_png(path)
	print("[HRShot] saved %s" % ProjectSettings.globalize_path(path))
	get_tree().quit()


func _press_button_labelled(root: Node, label: String) -> bool:
	# Ağaçta metni eşleşen İLK etkin Button'a basar. Shot harness'ı gerçek etkileşimi
	# taklit etsin diye: doğrudan _open_* çağırmak popover'ın çapa/konum kodunu atlar.
	if root is Button and not (root as Button).disabled \
			and String((root as Button).text).begins_with(label):
		(root as Button).pressed.emit()
		return true
	for child in root.get_children():
		if _press_button_labelled(child, label):
			return true
	return false


func _seed_hr_roster() -> void:
	# Üç departmanın hepsinde kadro: Ürün Geliştirme'nin üç alt bölümü dolu, Satış'ta bir
	# kişi, Müşteri BOŞ (empty-state satırı da görünsün). Biri izinde, biri tükeniyor,
	# biri de bugün başlamış (YENİ etiketi).
	# Huylar TRAIT_MIN_POSITIVE..MAX kuralına uymak ZORUNDA (registry _validate_shape'i
	# reddeder): en az 1, en çok 2 pozitif, en çok 1 negatif.
	var seeds: Array = [
		{"name": "Elif Demir", "role": HRConstants.ROLE_PRODUCT_MANAGER, "salary": 9800,
			"axes": {"expertise": 7, "pace": 5, "rapport": 6}, "morale": 72,
			"traits": ["natural_leader"]},
		{"name": "Deniz Arslan", "role": HRConstants.ROLE_DESIGNER, "salary": 7400,
			"axes": {"expertise": 6, "pace": 7, "rapport": 5}, "morale": 38,
			"traits": ["pressure_proof", "works_alone"]},
		{"name": "Mert Yıldız", "role": HRConstants.ROLE_DEVELOPER, "salary": 11200,
			"axes": {"expertise": 8, "pace": 6, "rapport": 4}, "morale": 61,
			"traits": ["wont_jump_ship"]},
		{"name": "Selin Kaya", "role": HRConstants.ROLE_TESTER, "salary": 6900,
			"axes": {"expertise": 5, "pace": 6, "rapport": 7}, "morale": 22,
			"traits": ["mentors_peers"]},
		{"name": "Burak Şahin", "role": HRConstants.ROLE_SALES_REP, "salary": 8300,
			"axes": {"expertise": 6, "pace": 5, "rapport": 8}, "morale": 55,
			"traits": ["warms_up_fast"]},
	]
	var ordinal: int = 0
	for seed_data in seeds:
		var emp := Character.new()
		emp.id = "char_emp_shot_%d" % ordinal
		emp.character_name = String(seed_data["name"])
		emp.role = String(seed_data["role"])
		emp.category = "employee"
		emp.monthly_salary = int(seed_data["salary"])
		emp.morale = int(seed_data["morale"])
		emp.role_stats = (seed_data["axes"] as Dictionary).duplicate()
		emp.traits.assign(seed_data["traits"] as Array)
		emp.status = HRConstants.STATUS_ACTIVE
		CharacterRegistry.add(emp)
		# add() bugünü damgalar; kıdem satırının üç dalını da göstermek için geriye alınıyor.
		emp.hire_day = maxi(1, GameState.day - (ordinal * 26))
		ordinal += 1
	# Biri izinde (Kare 7): seam üzerinden, alan doğrudan yazılmadan.
	var on_leave: Character = CharacterRegistry.get_character("char_emp_shot_2")
	if on_leave != null:
		HRMoraleSystem.send_on_leave(on_leave, HRConstants.LEAVE_DAYS, false)
	# Biri bugün başlamış (YENİ etiketi).
	var fresh: Character = CharacterRegistry.get_character("char_emp_shot_4")
	if fresh != null:
		fresh.hire_day = GameState.day


# Debug: --ending-shot=<key> (windowed). Seeds a representative Run Ledger, mounts the
# newspaper EndingScene at 1920×1080, screenshots to user://, and quits. <key> is an
# ending_id, plus the aliases bankruptcy1/2/3 (phase-layered) and series_a_agg (Aggressive
# variant). Mirrors the --b2b-shot / --product-shot harness.
func _run_ending_shot(key: String) -> void:
	get_tree().paused = false
	_shot_window(Vector2i(1920, 1080))
	_seed_run_reproducible()   # initialize_run + pinned seed (see the helper's note)
	GameState.company_name = "PromptPilot"
	GameState.founder_name = "Deniz"
	GameState.day = 156

	# Common representative ledger (every ledger-driven line populated).
	GameState.set_flag("mvp_version", 3)
	GameState.set_flag("mvp_version_history", [{"version": 1, "day": 40}, {"version": 2, "day": 90}, {"version": 3, "day": 140}])
	GameState.run_customers_signed = 9
	GameState.run_customers_lost = 3
	GameState.run_hires = 4
	GameState.run_pitches = 2
	GameState.run_sheets_won = 1
	GameState.vc_rejections = 1
	GameState.run_peak_mrr = 8200
	GameState.mrr = 6400
	GameState.cash = 24000

	# 2 live B2B customers so the MÜŞTERİ (customers_active) stat cell renders non-zero —
	# it reads CustomerRegistry live records, not the run counter. Seeded through the
	# sanctioned seam; the explicit run_customers_signed = 9 above stays authoritative
	# for the counter (the seam bumped it, we overwrite after).
	for ci in range(2):
		var pr := Prospect.new()
		pr.id = "shot_cust_%d" % ci
		pr.company_name = ["Ege Sigorta", "Kule Lojistik"][ci]
		pr.industry = "Sigorta"
		pr.archetype = "small"
		pr.pain_feature_id = "ai_vec_filter"
		SalesSystem.add_b2b_customer(pr, 1000, 70)
	GameState.run_customers_signed = 9
	GameState.mrr = 6400   # re-assert after the seam's MRR bridge reflected the 2 records

	# 3 minimal employees so the ÇALIŞAN stat cell renders non-zero — ledger.employees
	# reads CharacterRegistry live headcount, not run_hires (mirrors the _run_b2b_shot
	# seeding pattern).
	var emp_names := ["Burcu Çetin", "Mert Aydın", "Selin Koç"]
	for i in range(emp_names.size()):
		var emp := Character.new()
		emp.id = "char_shot_emp_%d" % i
		emp.character_name = emp_names[i]
		emp.role = HRConstants.ROLE_DEVELOPER
		emp.category = "employee"
		emp.monthly_salary = 6000
		emp.role_stats = {"expertise": 5, "pace": 5, "rapport": 5}
		emp.traits = ["pressure_proof"]   # 1 positive satisfies the employee trait formula
		CharacterRegistry.add(emp)

	# Resolve the shot key → real ending_id + phase + signed terms.
	var ending_id := key
	match key:
		"bankruptcy1":
			ending_id = "bankruptcy"; GameState.phase = 1
		"bankruptcy2":
			ending_id = "bankruptcy"; GameState.phase = 2
		"bankruptcy3", "bankruptcy":
			ending_id = "bankruptcy"; GameState.phase = 3
		"series_a_close", "series_a_agg":
			ending_id = "series_a_close"
			GameState.phase = 3
			var aggressive := key == "series_a_agg"
			GameState.run_valuation_m = 22
			GameState.run_equity_pct = 32 if aggressive else 18
			GameState.run_board_seats = 2 if aggressive else 1
			GameState.run_board_veto = aggressive
			GameState.run_investment_amount = int(round(22_000_000.0 * (32 if aggressive else 18) / 100.0))
		"running_on_fumes", "acquisition", "vc_rejection_cascade", "brand_collapse", "profitable_bootstrap":
			GameState.phase = 3
		_:
			GameState.phase = 3

	var data: Dictionary = EndingsSystem._build_ending_data(ending_id, {})
	var layer := CanvasLayer.new()
	add_child(layer)
	var scene: Control = ENDING_MODAL.instantiate()
	layer.add_child(scene)
	scene.populate(data)
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().create_timer(0.4).timeout
	var img: Image = get_viewport().get_texture().get_image()
	var path: String = _shot_path("ending_shot_%s" % key)
	img.save_png(path)
	print("[EndingShot] saved %s" % ProjectSettings.globalize_path(path))
	# Also run the real share export so every shot verifies the paper crop bounds.
	await scene._export_paper_png()
	get_tree().quit()


# Debug: --product-shot=<portfoy|ozellikler|tracker|detail_b2b|detail_b2c> (windowed).
# Mounts GameShell with seeded state, drives the Product tab router to the requested
# Rev3 view at 1920×1080, screenshots to user://, and quits.
func _run_product_shot(kind: String) -> void:
	get_tree().paused = false
	_shot_window(Vector2i(1920, 1080))
	_seed_run_reproducible()   # initialize_run + pinned seed (see the helper's note)
	var founder_id: String = CharacterRegistry.get_founder().id
	match kind:
		"detail_b2b", "portfoy":
			GameState.day = 95
			GameState.set_flag("mvp_shipped", true)
			GameState.set_flag("mvp_market_type", "b2b")
			GameState.set_flag("mvp_sub_product_type_id", "saas_ops")
			GameState.set_flag("mvp_product_name", "Nova")
			GameState.set_flag("mvp_version", 2)
			GameState.set_flag("mvp_innovation", 9.0)
			GameState.set_flag("mvp_stability", 14.0)
			GameState.set_flag("mvp_experience", 6.0)
			GameState.set_flag("mvp_components",
				["saas_ops_workflow", "saas_ops_reporting", "saas_ops_integration"])
			GameState.set_flag("mvp_launch_day", 73)
			GameState.set_flag("mvp_live_bug_count", 6)
			GameState.set_flag("mvp_bug_history", [2, 2, 3, 4, 4, 5, 6])
			GameState.set_flag("mvp_version_history",
				[{"version": 1, "day": 10}, {"version": 2, "day": 73}])
			var p := Prospect.new()
			p.id = "shot_ege"
			p.company_name = "Ege Sigorta"
			p.industry = "Sigorta"
			p.archetype = "small"
			p.pain_feature_id = "saas_ops_integration"
			var c: Customer = SalesSystem.add_b2b_customer(p, 402, 70)
			PromiseRegistry.create(c.id, "saas_ops_integration", 12)
			if kind == "portfoy":
				ProductSystem.start_version_build(["saas_ops_scheduling"], founder_id, [])
				var b: FeatureBuild = ProductSystem.get_active_build()
				if b != null:
					b.efor_spent = b.total_efor * 0.64
					ProductSystem.hourly_tick(9)  # faz bandını ilerlemeye oturtur
		"detail_b2c":
			GameState.set_flag("mvp_shipped", true)
			GameState.set_flag("mvp_market_type", "b2c")
			GameState.set_flag("mvp_sub_product_type_id", "ai_assistant")
			GameState.set_flag("mvp_product_name", "Fokus")
			GameState.set_flag("mvp_version", 1)
			GameState.set_flag("mvp_innovation", 1.0)
			GameState.set_flag("mvp_stability", 0.0)
			GameState.set_flag("mvp_experience", 5.0)
			GameState.set_flag("mvp_components", ["ai_assistant_chat", "ai_assistant_memory"])
			GameState.set_flag("mvp_launch_day", GameState.day)
			GameState.set_flag("mvp_live_bug_count", 5)
			GameState.set_flag("mvp_bug_history", [1, 2, 2, 3, 4, 4, 5])
			GameState.set_flag("mvp_version_history", [{"version": 1, "day": GameState.day}])
			GameState.set_flag("b2c_audience", 1.0)
			# Satış okuma kapısını aç: optimal rakam "belirsiz" yerine gerçek değerle çizilsin.
			CharacterRegistry.get_founder().role_stats["sales"] = SkillCheck.SALES_READ_THRESHOLD
		"tracker", "beta":
			ProductSystem.start_build("saas_ops",
				["saas_ops_workflow", "saas_ops_reporting", "saas_ops_integration"],
				founder_id, "Nova İki")
			var b: FeatureBuild = ProductSystem.get_active_build()
			if b != null:
				b.efor_spent = b.total_efor * (0.9 if kind == "beta" else 0.5)
				ProductSystem.hourly_tick(9)
		_:
			pass  # "ozellikler": temiz açılış, navigasyon aşağıda
	_shell = GAME_SHELL.instantiate()
	add_child(_shell)
	await get_tree().process_frame
	await get_tree().process_frame
	EventBus.tab_changed.emit("product")
	await get_tree().process_frame
	var cv: Node = _shell.find_child("CenterViewport", true, false)
	var tab: Node = cv.get_current_page_body()   # TabPageChrome sarmalayıcısı içinden (ODA rework onarımı)
	if tab == null:
		push_error("[ProductShot] sekme gövdesi bulunamadı (get_current_page_body null)")
		get_tree().quit(1)
		return
	match kind:
		"ozellikler":
			tab._navigate("creation", {"step": 3, "prefill": {"type": "saas_ops",
				"features": ["saas_ops_workflow", "saas_ops_reporting", "saas_ops_integration"]}})
		"tracker", "beta":
			tab._navigate("tracker", {})
		"detail_b2b", "detail_b2c":
			tab._navigate("detail", {})
		_:
			pass  # portfoy: varsayılan iniş görünümü
	await get_tree().process_frame
	await get_tree().create_timer(0.4).timeout
	var img: Image = get_viewport().get_texture().get_image()
	var path: String = _shot_path("product_shot_%s" % kind)
	img.save_png(path)
	print("[ProductShot] saved %s" % ProjectSettings.globalize_path(path))
	get_tree().quit()


func _run_pitch_shot() -> void:
	# Mount GameShell, enter a B2B pitch (MeetingScene via B2BPitchMeeting), screenshot the
	# opening beat: room art + rep portrait + dialogue + choices, NO conviction/stat strip.
	get_tree().paused = false
	_shot_window(Vector2i(1920, 1080))
	_seed_run_reproducible()   # initialize_run + pinned seed (see the helper's note)
	GameState.founder_portrait = "founder_01"
	GameState.set_flag("mvp_shipped", true)
	GameState.set_flag("mvp_market_type", "b2b")
	GameState.set_flag("mvp_sub_product_type_id", "ai_vector_search")
	var p := PitchSystem.spawn_prospect("mid", "find")
	_shell = GAME_SHELL.instantiate()
	add_child(_shell)
	await get_tree().process_frame
	await get_tree().process_frame
	# The normal flow wires this in _swap_to_shell_and_modal; the shot mounts the shell
	# manually, so connect the dialogue-mount handler here before entering the pitch.
	if not EventBus.meeting_scene_requested.is_connected(_on_meeting_scene_requested):
		EventBus.meeting_scene_requested.connect(_on_meeting_scene_requested)
	B2BPitchMeeting.begin_meeting(p.id)
	await get_tree().process_frame
	await get_tree().create_timer(0.5).timeout
	var img: Image = get_viewport().get_texture().get_image()
	var path: String = _shot_path("pitch_shot")
	img.save_png(path)
	print("[PitchShot] saved %s" % ProjectSettings.globalize_path(path))
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
		rep.character_name = "Burcu Çetin"
		rep.role = HRConstants.ROLE_CUSTOMER_REP
		rep.category = "employee"
		rep.role_stats = HRConstants.default_axes()
		rep.traits = ["warms_up_fast"]
		CharacterRegistry.add(rep)
		c.assigned_to = rep.id
	c.update_health_from_satisfaction()
	CustomerRegistry.add(c)


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

	await _mount_shell()

	var modal_layer: CanvasLayer = _shell.get_node_or_null("ModalLayer") if _shell != null else null
	if modal_layer == null:
		return   # _mount_shell already reported it

	_modal = MENTOR_MODAL.instantiate()
	_modal.dismissed.connect(_on_modal_dismissed)
	modal_layer.add_child(_modal)


# Instances GameShell and wires the event pipeline. Split out of
# _swap_to_shell_and_modal because a save LOAD remounts the world WITHOUT the
# mentor intro — the intro belongs to a new run, not to a restored one.
# Every shell child paints from GameState in its own _ready(), so this is the
# "repaint the world" seam: restore state first, mount second.
func _mount_shell() -> void:
	_shell = GAME_SHELL.instantiate()
	add_child(_shell)
	_shell_mounted = true

	# One frame so TopBar/OdaView finish their initial paint from
	# GameState before anything mounts on top.
	await get_tree().process_frame

	var modal_layer: CanvasLayer = _shell.get_node_or_null("ModalLayer")
	if modal_layer == null:
		push_error("[Main] GameShell/ModalLayer not found — modal pipeline cannot wire")
		return

	# Wire event pipeline signals now that ModalLayer exists. Done once.
	if not _event_signals_wired:
		EventBus.modal_requested.connect(_on_event_modal_requested)
		EventBus.event_resolved.connect(_on_event_resolved)
		EventBus.pitch_requested.connect(_on_pitch_requested)
		EventBus.settings_requested.connect(_on_settings_requested)
		EventBus.confirm_requested.connect(_on_confirm_requested)
		EventBus.run_ended.connect(_on_run_ended)
		EventBus.month_ended.connect(_on_month_ended)
		EventBus.meeting_scene_requested.connect(_on_meeting_scene_requested)
		EventBus.frank_popup_requested.connect(_on_frank_popup_requested)
		EventBus.term_table_requested.connect(_on_term_table_requested)
		EventBus.sheet_granted.connect(_on_sheet_granted_prompt)
		# SaveManager task'ı: ESC menüsü, Kaydet/Yükle modalı, F5/F9.
		EventBus.system_menu_requested.connect(_on_system_menu_requested)
		EventBus.save_load_requested.connect(_on_save_load_requested)
		EventBus.quicksave_requested.connect(_on_quicksave_requested)
		EventBus.quickload_requested.connect(_on_quickload_requested)
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
	# ODA ilk-açılış turu: MentorIntro kapandıktan sonra, yalnız bayrak
	# görülmemişse (Settings 'oda_intro_seen'). Pause altında çalışır.
	get_tree().call_group("oda_view", "start_intro_tour_if_unseen")


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
		var restore: int = _pre_event_speed if _pre_event_speed >= 0 else TimeManager.last_running_speed
		_pre_event_speed = -1
		EventBus.speed_change_requested.emit(restore)


# --- B2B pitch (Sales tab → PostShip §D). The pitch now renders in the shared
#     MeetingScene via the B2BPitchMeeting view-adapter, which emits
#     meeting_scene_requested → the generic dialogue mount below handles pause/mount/
#     teardown. Choice/withdraw routing lives in _on_dialogue_* (B2B branch). ---

func _on_pitch_requested(prospect_id: String) -> void:
	B2BPitchMeeting.begin_meeting(prospect_id)


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
		var restore: int = _pre_settings_speed if _pre_settings_speed >= 0 else TimeManager.last_running_speed
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
	# İSTEĞE BAĞLI üçüncü yol (SaveManager task'ı): config'de alt_text yoksa buton
	# gizli kalır ve bu bağlantı hiç kurulmaz — mevcut yedi çağıran etkilenmedi.
	# İlk kullanıcı: "Kaydedilmemiş ilerleme var" → Kaydet ve çık / Çık / Vazgeç.
	var on_alt: Callable = config.get("on_alt", Callable())
	if on_alt.is_valid():
		_confirm_modal.alt_selected.connect(on_alt)
	_confirm_modal.dismissed.connect(_on_confirm_dismissed)
	modal_layer.add_child(_confirm_modal)
	_confirm_modal.populate(config)   # add_child SONRASI — @onready ref'ler ancak o zaman dolu (EventModal deseni)


func _on_confirm_dismissed() -> void:
	_confirm_modal = null
	# Onay sırasında kuyruğa event girdiyse kendi pause/restore'unu yönetir.
	if not EventManager.has_pending():
		var restore: int = _pre_confirm_speed if _pre_confirm_speed >= 0 else TimeManager.last_running_speed
		EventBus.speed_change_requested.emit(restore)
	_pre_confirm_speed = -1


# --- ESC sistem menüsü (SaveManager task'ı §4) ---
# game_shell yalnız ModalLayer VE PanelLayer boşken system_menu_requested emit eder,
# yani buraya geldiğimizde üstte hiçbir şey yok. Zorunlu karar zorunlu kalır: olay
# modalı açıkken ESC bu menüye hiç ulaşmaz.

func _on_system_menu_requested() -> void:
	if _system_menu != null:
		return  # already open
	var modal_layer: CanvasLayer = _shell.get_node_or_null("ModalLayer") if _shell != null else null
	if modal_layer == null:
		push_error("[Main] GameShell/ModalLayer missing — system menu can't mount")
		return
	_pre_system_speed = TimeManager.current_speed
	EventBus.speed_change_requested.emit(0)
	_system_menu = SYSTEM_MENU_MODAL.instantiate()
	_system_menu.dismissed.connect(_on_system_menu_dismissed)
	modal_layer.add_child(_system_menu)


func _on_system_menu_dismissed() -> void:
	_system_menu = null
	if not EventManager.has_pending():
		var restore: int = _pre_system_speed if _pre_system_speed >= 0 else TimeManager.last_running_speed
		EventBus.speed_change_requested.emit(restore)
	_pre_system_speed = -1


# --- Kaydet / Yükle modalı ---
# Sistem menüsünün ÜSTÜNE yığılır (ModalLayer'da add_child sırası = z sırası) ve ESC
# yalnız en üsttekini kapatır: _unhandled_input ağacı ters sırada gezdiği için en son
# eklenen önce görür ve olayı tüketir. Kendi hız yakalaması YOK — altındaki menü zaten
# oyunu duraklattı; ikinci bir _pre_*_speed o durum makinesini bozardı.

func _on_save_load_requested(mode: String) -> void:
	if _save_load_modal != null:
		return
	var modal_layer: CanvasLayer = _shell.get_node_or_null("ModalLayer") if _shell != null else null
	if modal_layer == null:
		push_error("[Main] GameShell/ModalLayer missing — save/load modal can't mount")
		return
	_save_load_modal = SAVE_LOAD_MODAL.instantiate()
	_save_load_modal.dismissed.connect(_on_save_load_dismissed)
	_save_load_modal.load_requested.connect(_load_slot)
	modal_layer.add_child(_save_load_modal)
	_save_load_modal.populate(mode)   # add_child SONRASI — @onready ref'ler ancak o zaman dolu


func _on_save_load_dismissed() -> void:
	_save_load_modal = null


# --- F5 / F9 ---

func _on_quicksave_requested() -> void:
	if not _shell_mounted:
		return
	if not SaveManager.can_save():
		print("[Main] hızlı kayıt reddedildi: %s" % SaveManager.cannot_save_reason_key())
		return
	if SaveManager.quicksave():
		print("[Main] hızlı kayıt yazıldı")


func _on_quickload_requested() -> void:
	if not _shell_mounted:
		return
	_load_slot(SaveManager.QUICK_SLOT_ID)


# --- Yükleme sırası: TEK yol (§5.3) ---
# Sıralama tesadüf değil. initialize_run alanlara setter'lardan DEĞİL doğrudan yazar
# ve gerekçesini kendi içinde yazıyor: "GameShell henüz instance edilmedi, dinleyici
# yok." Shell'i ÖNCE yıkarak o varsayımı yükleme yolunda da doğru tutuyoruz — yani
# hiçbir yayın fırtınası gerekmiyor. Kayıt okuma, hiçbir şeye dokunmadan önce
# doğrulanır: yarısı yıkılmış bir dünyada "dosya bozuk" demek en kötü sonuçtur.
func _load_slot(slot_id: String) -> void:
	# Çözülmemiş bir zorunlu karar varken yükleme YOK. Kaydet/Yükle modalından
	# buraya zaten gelinemez (ESC menüsü olay modalı üstündeyken açılmıyor), ama
	# F9 o kapıdan geçmiyor — tek bir tuş vuruşu, oyuncunun önündeki cevaplanmamış
	# seçimi sessizce çöpe atardı. Kaydetmeyle AYNI kural (SaveManager.can_save):
	# yarıda kalan karar taşınmaz.
	if EventManager._active_event_id != "":
		print("[Main] yükleme reddedildi: %s" % "SAVE_ERR_MODAL_OPEN")
		return
	var payload: Dictionary = SaveManager.read_slot(slot_id)
	if not bool(payload.get("ok", false)):
		push_warning("[Main] yükleme reddedildi (%s): %s" % [slot_id, payload.get("error_key", "")])
		return

	_teardown_run_ui()
	# Shell queue_free() ERTELENMİŞTİR; bir kare beklemeden yeni shell'i mount edersek
	# iki GameShell aynı anda ağaçta olur (iki _input, iki tab_changed dinleyicisi).
	await get_tree().process_frame

	if not SaveManager.apply_loaded_state(payload):
		push_error("[Main] yükleme durumu uygulanamadı (%s)" % slot_id)
		return

	await _mount_shell()
	EventBus.game_loaded.emit(slot_id)


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
		var restore: int = _pre_month_speed if _pre_month_speed >= 0 else TimeManager.last_running_speed
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
	if _deal_prompt_vc != "":
		_on_deal_prompt_choice(id)
		return
	if VCPitchSystem.is_meeting_active():
		var r: Dictionary = VCPitchSystem.advance(id)
		if r.get("done", false):
			_close_dialogue_scenes()
		elif _meeting_scene != null:
			_meeting_scene.populate(r.get("view_state", {}))
		return
	if B2BPitchMeeting.is_active():
		var rb: Dictionary = B2BPitchMeeting.advance(id)
		if rb.get("done", false):
			_close_dialogue_scenes()
		elif _meeting_scene != null:
			_meeting_scene.populate(rb.get("view_state", {}))
		return
	print("[Debug] choice_selected: %s" % id)
	_close_dialogue_scenes()


func _on_dialogue_withdrawn() -> void:
	if VCPitchSystem.is_meeting_active():
		VCPitchSystem.withdraw()
		_close_dialogue_scenes()
		return
	if B2BPitchMeeting.is_active():
		B2BPitchMeeting.withdraw()
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
		var restore: int = _pre_dialogue_speed if _pre_dialogue_speed >= 0 else TimeManager.last_running_speed
		EventBus.speed_change_requested.emit(restore)
	_pre_dialogue_speed = -1
	# A won meeting grants a sheet mid-scene; its deal-closed prompt waits until now (§2).
	_maybe_show_deal_prompt()


# --- Term Sheet Table (Spec 6) — deal-closed Frank prompt + table mount ---

func _on_sheet_granted_prompt(vc_id: String) -> void:
	# A sheet was just granted (won meeting or delayed delivery). Queue the deal-closed prompt;
	# it shows once nothing else is on screen (a won meeting is still closing when this fires).
	_pending_deal_prompt_vc = vc_id
	_maybe_show_deal_prompt()


func _maybe_show_deal_prompt() -> void:
	if _pending_deal_prompt_vc == "":
		return
	if not GameState.run_active or GameState.phase < 3:
		_pending_deal_prompt_vc = ""
		return
	if VCPitchSystem.sheet_for(_pending_deal_prompt_vc) == null:
		_pending_deal_prompt_vc = ""   # sheet gone (expired/walked) before we could offer it
		return
	# Don't stack over any modal / dialogue / table / confirm — retried from the close paths.
	if _frank_popup != null or _meeting_scene != null or _term_table != null \
			or _event_modal != null or _confirm_modal != null:
		return
	var vc: String = _pending_deal_prompt_vc
	_pending_deal_prompt_vc = ""
	_deal_prompt_vc = vc
	EventBus.frank_popup_requested.emit(_deal_prompt_view_state(vc))


func _deal_prompt_view_state(vc_id: String) -> Dictionary:
	var inv: Dictionary = InvestorRegistry.get_investor(vc_id)
	var sheet: TermSheet = VCPitchSystem.sheet_for(vc_id)
	var days: int = sheet.days_left(GameState.day) if sheet != null else PitchConstants.SHEET_VALIDITY_DAYS
	return {
		"portrait_path": "res://assets/art/investors/portrait_frank.webp",
		"speaker_name": "Frank Köseoğlu",
		"speaker_role": "Mentor / Operating Partner",
		"active_line": {
			"text": "\"%s teklif verdi. %d gün geçerli. İstersen masaya şimdi otur, şartları zorla. İstersen teklifi cebine koy, başka VC'lerle de görüş — cebinde ikinci teklif olduğunda pazarlık gücün artar.\"" % [String(inv.get("display_name", "")), days],
			"speaker_tag": "Frank",
			"is_monologue": false,
		},
		"choices": [
			{"id": "open_table", "text": "Masaya şimdi otur.", "marked": true, "marked_text": "Geçerlilik: %d gün" % days},
			{"id": "defer", "text": "Sonra — teklifi al, başka VC'lerle görüş."},
		],
		"beat_label": "%s — Term Sheet" % String(inv.get("display_name", "")),
		"can_withdraw": false,
	}


func _on_deal_prompt_choice(id: String) -> void:
	var vc: String = _deal_prompt_vc
	_deal_prompt_vc = ""
	if _frank_popup != null:
		_frank_popup.queue_free()
		_frank_popup = null
	if id == "open_table":
		EventBus.term_table_requested.emit(vc)   # table inherits _pre_dialogue_speed (kept below)
	else:
		# Defer — the sheet waits in Finance>Yatırım with its clock running. Restore speed.
		if GameState.run_active and not EventManager.has_pending():
			var restore: int = _pre_dialogue_speed if _pre_dialogue_speed >= 0 else TimeManager.last_running_speed
			EventBus.speed_change_requested.emit(restore)
		_pre_dialogue_speed = -1


func _on_term_table_requested(vc_id: String) -> void:
	if _term_table != null:
		return
	var modal_layer: CanvasLayer = _shell.get_node_or_null("ModalLayer") if _shell != null else null
	if modal_layer == null:
		push_error("[Main] GameShell/ModalLayer missing — term table can't mount")
		return
	if TermSheetTableSystem.open(vc_id).is_empty():
		push_warning("[Main] term_table_requested for %s with no live sheet" % vc_id)
		return
	if _pre_dialogue_speed < 0:
		_pre_dialogue_speed = TimeManager.current_speed
	EventBus.speed_change_requested.emit(0)
	_term_table = TERM_TABLE_SCENE.instantiate()
	_term_table.closed.connect(_close_term_table)
	modal_layer.add_child(_term_table)


func _close_term_table() -> void:
	if _term_table != null:
		_term_table.queue_free()
		_term_table = null
	# Sign ended the run (run_active false → no restore, the ending owns the freeze); a walk
	# leaves the run alive → restore to the pre-table speed.
	if GameState.run_active and not EventManager.has_pending():
		var restore: int = _pre_dialogue_speed if _pre_dialogue_speed >= 0 else TimeManager.last_running_speed
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
	# Mirrors the 3-page onboarding draft shape (Stage D). Alloc sums to
	# FounderConstants.POINT_POOL (6) and keeps odds parity at every read site:
	# sales=2 (valuation lever + prospect read), negotiation=1 (dilution),
	# influence=1 (board + VC beats), tech=2 (product); leadership has no reads yet.
	return {
		"origin_id": "self_made",
		"portrait_id": "founder_01",
		"skill_alloc": {"tech": 2, "sales": 2, "negotiation": 1, "leadership": 0, "influence": 1},
		"trait_ids": ["visionary", "stubborn"],
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

	_teardown_run_ui()

	# TEK sıfırlama yolu. Burası eskiden üç kaydı elle temizliyordu (roster + olay
	# hattı + söz defteri) ve müşteri/aday/rakip kayıtları AÇIKTA kalıyordu — audit
	# S3-39'un "restart tarzı bir sıfırlama ölü koşuyu gösteren hiçbir şeyi
	# bırakmamalı" bulgusu tam olarak buydu. SaveManager yükleme için zaten on yedi
	# sahibin tamamını kapsayan bir sıfırlama kurdu; ikinci bir liste tutmak, iki
	# listenin zamanla ayrışması demekti. Aynı çağrı, aynı sıra, iki giriş noktası.
	SaveManager.reset_all_owners()

	# Pause (mirrors _ready) and remount the flow from step 1. Completion routes
	# through _on_flow_completed → _swap_to_shell_and_modal (re-entrant; event
	# signal wiring is guarded by _event_signals_wired, so no double-connects).
	EventBus.speed_change_requested.emit(0)
	_mount_flow()


# Frees the shell (which frees its ModalLayer/PanelLayer children with it) and drops
# EVERY modal ref + speed tracker, so nothing from the outgoing run dangles into the
# next one. Extracted from the Shift+F4 restart because a SAVE LOAD needs the exact
# same teardown — one UI-teardown path, not two that drift apart.
#
# The cinematic-dialogue six are here for a reason (audit S3-40): they used to leak, so
# run 2 started holding references to run 1's freed scenes and, worse, a _deal_prompt_vc
# naming an investor at a company that no longer existed — enough to misroute the next
# run's first meeting choice.
func _teardown_run_ui() -> void:
	if _shell != null:
		_shell.queue_free()
		_shell = null
	_shell_mounted = false
	_modal = null
	_event_modal = null
	_settings_modal = null
	_confirm_modal = null
	_ending_modal = null
	_month_modal = null
	_system_menu = null
	_save_load_modal = null
	_pre_event_speed = -1
	_pre_settings_speed = -1
	_pre_confirm_speed = -1
	_pre_month_speed = -1
	_pre_system_speed = -1
	_meeting_scene = null
	_frank_popup = null
	_term_table = null
	_pre_dialogue_speed = -1
	_deal_prompt_vc = ""
	_pending_deal_prompt_vc = ""
