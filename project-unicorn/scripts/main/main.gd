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
const SETTINGS_MODAL := preload("res://scenes/modals/SettingsModal.tscn")
const CONFIRM_MODAL := preload("res://scenes/modals/ConfirmModal.tscn")
const ENDING_MODAL := preload("res://scenes/modals/EndingScene.tscn")  # newspaper ceremony ("Ekonomi Postası") — same populate(ending_data) mount contract
const MONTH_SUMMARY_MODAL := preload("res://scenes/modals/MonthSummaryModal.tscn")
const MEETING_SCENE := preload("res://scenes/modals/MeetingScene.tscn")
const FRANK_POPUP := preload("res://scenes/modals/FrankPopup.tscn")
const TERM_TABLE_SCENE := preload("res://scenes/modals/TermSheetTableScene.tscn")

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
			# CLI headless runs (arg on the command line) quit so stdout flushes and the
			# process exits; the MCP editor-run path (arg via ProjectSettings main_args,
			# NOT cmdline) is left ALIVE so it can read the live log — see endgame_smoke.gd.
			if _smoke_case_on_cmdline():
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
		var product_shot: String = _product_shot_requested()
		if product_shot != "":
			_run_product_shot(product_shot)
			return
		var ending_shot: String = _ending_shot_requested()
		if ending_shot != "":
			_run_ending_shot(ending_shot)
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


# True when the smoke arg came from the actual command line (a CLI run) vs ProjectSettings
# main_args (the MCP editor-run path). Only CLI runs quit after the case.
func _smoke_case_on_cmdline() -> bool:
	for arg in OS.get_cmdline_args():
		if String(arg).begins_with("--endgame-smoke="):
			return true
	return false


func _b2b_shot_requested() -> String:
	for arg in OS.get_cmdline_args():
		var s: String = String(arg)
		if s.begins_with("--b2b-shot="):
			return s.trim_prefix("--b2b-shot=")
	return ""


func _run_b2b_shot(kind: String) -> void:
	# Mount one B2B Sales modal into a CanvasLayer, render a couple frames, screenshot.
	get_tree().paused = false
	get_window().size = Vector2i(1920, 1080)
	GameState.initialize_run({})
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
		cs.role = CharacterRegistry.ROLE_CUSTOMER_SUCCESS
		cs.category = "employee"
		cs.monthly_salary = 5000
		cs.role_stats = {"cs_skill": 55}
		CharacterRegistry.add(cs)
		CustomerRegistry.assign_customer(c.id, cs.id)
		CustomerRegistry.set_satisfaction(c.id, 22)
		ev = B2BEventFactory.build_cs_escalation(c, cs)
	elif kind == "expansion":
		CustomerRegistry.set_lifecycle_phase(c.id, "expansion")
		ev = B2BEventFactory.build_expansion(c)
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
	var path: String = "user://b2b_shot_%s.png" % kind
	img.save_png(path)
	print("[B2BShot] saved %s" % ProjectSettings.globalize_path(path))
	get_tree().quit()


func _run_sales_shot() -> void:
	get_tree().paused = false
	get_window().size = Vector2i(1920, 1080)
	GameState.initialize_run({})
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
	img.save_png("user://sales_shot.png")
	print("[SalesShot] saved %s" % ProjectSettings.globalize_path("user://sales_shot.png"))
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


# Debug: --ending-shot=<key> (windowed). Seeds a representative Run Ledger, mounts the
# newspaper EndingScene at 1920×1080, screenshots to user://, and quits. <key> is an
# ending_id, plus the aliases bankruptcy1/2/3 (phase-layered) and series_a_agg (Aggressive
# variant). Mirrors the --b2b-shot / --product-shot harness.
func _run_ending_shot(key: String) -> void:
	get_tree().paused = false
	get_window().size = Vector2i(1920, 1080)
	GameState.initialize_run({})
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
	var path: String = "user://ending_shot_%s.png" % key
	img.save_png(path)
	print("[EndingShot] saved %s" % ProjectSettings.globalize_path(path))
	get_tree().quit()


# Debug: --product-shot=<portfoy|ozellikler|tracker|detail_b2b|detail_b2c> (windowed).
# Mounts GameShell with seeded state, drives the Product tab router to the requested
# Rev3 view at 1920×1080, screenshots to user://, and quits.
func _run_product_shot(kind: String) -> void:
	get_tree().paused = false
	get_window().size = Vector2i(1920, 1080)
	GameState.initialize_run({})
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
	var tab: Node = cv._current_tab_node
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
	var path: String = "user://product_shot_%s.png" % kind
	img.save_png(path)
	print("[ProductShot] saved %s" % ProjectSettings.globalize_path(path))
	get_tree().quit()


func _run_pitch_shot() -> void:
	# Mount GameShell, enter a B2B pitch (MeetingScene via B2BPitchMeeting), screenshot the
	# opening beat: room art + rep portrait + dialogue + choices, NO conviction/stat strip.
	get_tree().paused = false
	get_window().size = Vector2i(1920, 1080)
	GameState.initialize_run({})
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
	img.save_png("user://pitch_shot.png")
	print("[PitchShot] saved %s" % ProjectSettings.globalize_path("user://pitch_shot.png"))
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
		rep.role = CharacterRegistry.ROLE_CUSTOMER_SUCCESS
		rep.category = "employee"
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
		EventBus.settings_requested.connect(_on_settings_requested)
		EventBus.confirm_requested.connect(_on_confirm_requested)
		EventBus.run_ended.connect(_on_run_ended)
		EventBus.month_ended.connect(_on_month_ended)
		EventBus.meeting_scene_requested.connect(_on_meeting_scene_requested)
		EventBus.frank_popup_requested.connect(_on_frank_popup_requested)
		EventBus.term_table_requested.connect(_on_term_table_requested)
		EventBus.sheet_granted.connect(_on_sheet_granted_prompt)
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
		var restore: int = _pre_dialogue_speed if _pre_dialogue_speed >= 0 else 1
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
			var restore: int = _pre_dialogue_speed if _pre_dialogue_speed >= 0 else 1
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

	# Tear down the shell (frees its ModalLayer children too) and drop all modal
	# refs + speed trackers so nothing dangles into the next run.
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
