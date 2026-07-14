extends Control

# GameShell root. process_mode = ALWAYS (set in GameShell.tscn) so this handler
# runs even while the tree is paused — that's what lets Space UN-pause the game.
#
# B1: Space = pause/resume toggle. We use _input (not _unhandled_input) so a
# focused Button can't swallow Space via ui_accept before we see it. Guards keep
# Space typing a real space inside text fields, and defer to main.gd's pause
# state machine while a blocking modal is open.

# Spec 5 debug: alternates MeetingScene full ↔ extreme-length fixture across presses.
var _meeting_fixture_toggle: bool = false
# Spec 4 debug: cycles the roster across Shift+F5 presses.
var _vc_debug_idx: int = 0

func _input(event: InputEvent) -> void:
	if not (event is InputEventKey):
		return
	var key: InputEventKey = event
	if not key.pressed or key.echo:
		return
	# Debug endgame forcing (F1-F11, debug builds only) — ENDGAME_DESIGN.md §7.8:
	# every ending testable from day one, series_a_closed settable pre-VC-system.
	if OS.is_debug_build() and key.keycode >= KEY_F1 and key.keycode <= KEY_F11:
		get_viewport().set_input_as_handled()
		if key.shift_pressed and key.keycode == KEY_F4:
			# Shift+F4 = re-trigger onboarding from a running game (mockup capture).
			# Intercept BEFORE the endgame dispatch below — _debug_endgame_key ignores
			# shift, so without this Shift+F4 would fire plain-F4's action. Plain F4
			# stays the acquisition-preconditions key.
			print("[Debug] Shift+F4 → onboarding re-triggered")
			EventBus.debug_onboarding_retrigger_requested.emit()
			return
		if key.shift_pressed and key.keycode == KEY_F2:
			# Shift+F2 = MeetingScene debug fixture (Spec 5). Plain F2 = phase jump and
			# _debug_endgame_key ignores shift, so intercept here. Guard: don't stack on
			# an already-open modal. Alternates full ↔ extreme-length across (re)opens.
			var ml_mtg: Node = get_node_or_null("ModalLayer")
			if ml_mtg != null and ml_mtg.get_child_count() > 0:
				return
			_meeting_fixture_toggle = not _meeting_fixture_toggle
			var vs: Dictionary = MeetingScene.debug_fixture_full() if _meeting_fixture_toggle else MeetingScene.debug_fixture_long()
			print("[Debug] Shift+F2 → MeetingScene fixture (%s)" % ("full" if _meeting_fixture_toggle else "long"))
			EventBus.meeting_scene_requested.emit(vs)
			return
		if key.shift_pressed and key.keycode == KEY_F3:
			# Shift+F3 = FrankPopup debug fixture (Spec 5). Plain F3 = Class A hard win;
			# _debug_endgame_key ignores shift, so intercept here. Same no-stack guard.
			var ml_frank: Node = get_node_or_null("ModalLayer")
			if ml_frank != null and ml_frank.get_child_count() > 0:
				return
			print("[Debug] Shift+F3 → FrankPopup fixture")
			EventBus.frank_popup_requested.emit(FrankPopup.debug_fixture())
			return
		if key.shift_pressed and key.keycode == KEY_F5:
			# Shift+F5 = begin a REAL VC pitch (Spec 4), cycling the 4 VCs across presses.
			# Plain F5 = cash -1000; _debug_endgame_key ignores shift, so intercept here.
			var ml_vc: Node = get_node_or_null("ModalLayer")
			if ml_vc != null and ml_vc.get_child_count() > 0:
				return
			var roster: Array = InvestorRegistry.get_active()
			var inv: Dictionary = roster[_vc_debug_idx % roster.size()]
			_vc_debug_idx += 1
			print("[Debug] Shift+F5 → begin VC meeting (%s)" % inv.get("id", ""))
			VCPitchSystem.begin_meeting(String(inv.get("id", "")))
			return
		if key.keycode == KEY_F11:
			# F11 = force month summary with LIVE data; Shift+F11 = extreme-value
			# layout fixture (Spec 3 checklist 11 stays reproducible).
			print("[Debug] F11 → force month summary (extreme=%s)" % key.shift_pressed)
			MonthSummarySystem.debug_force_summary(key.shift_pressed)
			return
		_debug_endgame_key(key.keycode)
		return
	if key.keycode != KEY_SPACE:
		return
	# Guard 1: a text field is focused → let Space type a space (e.g. product name).
	var focus: Control = get_viewport().gui_get_focus_owner()
	if focus is LineEdit or focus is TextEdit:
		return
	# Guard 2: a blocking modal (event/pitch/settings) owns pause via main.gd —
	# don't desync that _pre_*_speed state machine.
	var modal_layer: Node = get_node_or_null("ModalLayer")
	if modal_layer != null and modal_layer.get_child_count() > 0:
		return
	get_viewport().set_input_as_handled()
	# Toggle: pause if running, else resume the last running speed. Routes through
	# the same signal the TopBar buttons use, so the TopBar stays in sync.
	var target: int = 0 if TimeManager.current_speed > 0 else TimeManager.last_running_speed
	EventBus.speed_change_requested.emit(target)


# Argless relay for MCP runtime verification (the runtime bridge can't pass
# typed args; Shift+F11 covers real keyboards). Debug builds only.
func debug_force_month_extreme() -> void:
	if OS.is_debug_build():
		MonthSummarySystem.debug_force_summary(true)


# Argless MeetingScene relays for MCP runtime verification (the bridge can't pass a
# Dictionary; Shift+F2 covers real keyboards). Spec 5, debug builds only.
func debug_force_meeting() -> void:
	if OS.is_debug_build():
		EventBus.meeting_scene_requested.emit(MeetingScene.debug_fixture_full())


func debug_force_meeting_long() -> void:
	if OS.is_debug_build():
		EventBus.meeting_scene_requested.emit(MeetingScene.debug_fixture_long())


func debug_force_frank() -> void:
	if OS.is_debug_build():
		EventBus.frank_popup_requested.emit(FrankPopup.debug_fixture())


# Argless VC-meeting relay for MCP runtime verification (Spec 4). Begins a real pitch
# with the given VC (mounts MeetingScene via meeting_scene_requested → main.gd).
func debug_force_vc_meeting(vc_id: String = "anchor") -> void:
	if OS.is_debug_build():
		VCPitchSystem.begin_meeting(vc_id)


# --- Debug endgame keys (F1-F10; OS.is_debug_build only) ---
# Class B cases set preconditions and let the NEXT daily tick (slot 8/9) fire
# them — that exercises the real scan path, not a shortcut. F3 is the Class A
# instant path by design.

func _debug_endgame_key(keycode: Key) -> void:
	match keycode:
		KEY_F1:
			print("[Debug] F1 → force-open current phase gate")
			PhaseGateSystem.debug_force_gate()
		KEY_F2:
			print("[Debug] F2 → instant phase jump (skips Frank scene)")
			GameState.phase_gate_ready = true
			GameState.pending_next_phase = GameState.phase + 1
			GameState.advance_phase()
		KEY_F3:
			print("[Debug] F3 → series_a_closed + Class A hard win")
			GameState.series_a_closed = true
			EndingsSystem.trigger_ending("series_a_close")
		KEY_F4:
			print("[Debug] F4 → force acquisition offer preconditions (phase 3, brand 40, 1 ret)")
			GameState.set_phase(3)
			GameState.set_brand(40)
			GameState.vc_rejections = maxi(GameState.vc_rejections, 1)
		KEY_F5:
			print("[Debug] F5 → cash -1000 (Kepenk starts next daily tick)")
			GameState.set_cash(-1000)
		KEY_F6:
			print("[Debug] F6 → brand collapse preconditions (brand 10, scandal, 30 gün geride)")
			GameState.set_brand(10)
			GameState.active_scandal = true
			GameState.brand_low_since_day = maxi(1, GameState.day - 30)
		KEY_F7:
			print("[Debug] F7 → cascade preconditions (3 ret, ölü metrikler)")
			GameState.vc_rejections = 3
			GameState.set_mrr(0)
		KEY_F8:
			print("[Debug] F8 → profitable bootstrap preconditions + day 179")
			GameState.cash_went_negative = false
			GameState.net_history_90.clear()
			for i in 90:
				GameState.net_history_90.append(10)
			GameState.set_mrr(6000)
			if GameState.cash < 0:
				GameState.set_cash(1000)
			GameState.day = 179
		KEY_F9:
			print("[Debug] F9 → running on fumes (cash_went_negative) + day 179")
			GameState.cash_went_negative = true
			GameState.day = 179
		KEY_F10:
			print("[Debug] F10 → pivot offer preconditions (3 ret, canlı metrikler)")
			GameState.vc_rejections = 3
			GameState.set_mrr(3000)
			if GameState.cash <= 0:
				GameState.set_cash(1000)
