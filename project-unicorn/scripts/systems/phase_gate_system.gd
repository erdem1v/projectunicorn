class_name PhaseGateSystem
extends RefCounted

# Phase Transition Engine — daily tick slot 8 per docs/ENDGAME_DESIGN.md §2.
#
# Gate = systemic: this system evaluates the current phase's exit condition
# daily; on satisfy it LATCHES (phase_gate_ready + pending_next_phase), emits
# phase_gate_reached, and queues a high-priority deterministic Frank scene.
# Transition = played: the phase only changes when the player confirms inside
# that scene → GameState.advance_phase() (the single write seam).
#
# Ratchet (§2.3): once open, a gate never re-locks; conditions are never
# re-evaluated after the latch. Subgenre-agnostic by construction: conditions
# run through EventManager.is_condition_met(), which reads GameState/registry
# state — B2C bar-fill and B2B signature feed the same evaluator (this kills
# the old _check_traction B2C-branch bug architecturally).
#
# Static (FinanceSystem pattern); the only system-side state is the cached
# Frank scene (_gate_event) — a single instance so reminders re-surface the
# SAME GameEvent and EventManager's dedupe makes stacking impossible (§7.10).
# All persistent/serialized state lives on GameState (§7.9).

const REMIND_INTERVAL_DAYS := 5  # working value (§2.4)
# Series A gate — the growth half (Calibration Round A §3, 2026-08-19). The revenue bar is
# SalesSystem.TRACTION_MRR_TARGET (never rendered as a figure — director ruling: the signal is
# shown, the number is not); the growth half is a STREAK of closed calendar months with
# month-over-month MRR growth. Both are read through series_a_signal() below, the single
# home the Finance indicator, the product page and the ODA board all paint from.
const GROWTH_STREAK_MONTHS := 3   # [WORKING] closed months of MoM growth in a row
const GROWTH_MIN_PCT := 12        # [WORKING] month-over-month MRR growth, percent

# Gate table (§2.2). Conditions use EventManager.is_condition_met() vocabulary;
# numeric values are working placeholders (§10 — numbers last).
const GATES := [
	{
		"from": 1, "to": 2,
		"event_id": "ev_phase_gate_traction",
		"conditions": [
			{"type": "mvp_shipped", "value": true},        # first product shipped
			{"type": "customer_count_min", "value": 1},    # first real customer (B2C record or B2B account)
			{"type": "mrr_above", "value": 0},             # MRR > 0
		],
		"copy_key": "TRACTION",       # GATE_TRACTION_TITLE / _BODY_0..2 in strings.csv
		"body_count": 3,
	},
	{
		"from": 2, "to": 3,
		"event_id": "ev_phase_gate_series_a",
		"conditions": [
			# mrr_above is strict ">" so target-1 ≡ "MRR ≥ TRACTION_MRR_TARGET" — single source
			# SalesSystem.TRACTION_MRR_TARGET. Never rendered as a figure (series_a_signal paints
			# a state, not the number).
			{"type": "mrr_above", "value": SalesSystem.TRACTION_MRR_TARGET - 1},
			# Sustained growth: GROWTH_STREAK_MONTHS closed months at ≥ GROWTH_MIN_PCT MoM.
			{"type": "mrr_growth_streak", "value": GROWTH_STREAK_MONTHS, "pct": GROWTH_MIN_PCT},
			{"type": "brand_above", "value": 24},          # brand ≥ 25 (working floor; calibration item)
		],  # runway deliberately NOT a condition (§2.2 — deadlock; low runway feeds pitch odds instead)
		"copy_key": "SERIES_A",       # GATE_SERIES_A_TITLE / _BODY_0..2 in strings.csv
		"body_count": 3,
	},
	# Phase 3 has no exit gate — the run resolves through terminals (§2.2 Gate 3).
]

# The ONE pending transition scene (§7.10). Built when a gate opens; reminders
# re-enqueue this same instance. Cleared when the gate resolves (advance) or
# the run ends (EventManager.flush_queue drops the queued reference; the cache
# itself is reset on the next gate open / initialize_run via a fresh process).
static var _gate_event: GameEvent = null


# --- Run boundary + save (SaveManager) ---

static func reset() -> void:
	# The cache comment above used to end "the cache itself is reset on the next gate open /
	# initialize_run via a fresh process" — that is exactly the process-relaunch dependency
	# this seam removes. A leaked _gate_event is a Frank scene belonging to a dead company,
	# and it survives an in-place restart precisely because _open_gate is the only writer and
	# the ratchet stops it re-running.
	_gate_event = null


static func restore_gate_cache() -> void:
	# Called on load. NOTHING IS SERIALISED HERE, on purpose: the gate scene is a pure
	# function of the GATES table plus GameState (phase + the gate_declines flag picks the
	# escalation body), both of which the save already carries. Rebuilding beats storing a
	# copy that would go stale the moment the copy is edited.
	#
	# WITHOUT THIS A LOADED GATE IS LOST FOREVER, and silently: phase_gate_ready is a
	# one-way ratchet, so daily_tick takes the _tick_reminder branch and never re-evaluates
	# conditions — and _tick_reminder returns immediately on a null _gate_event. The player
	# would sit at a satisfied gate that never prompts again, with no way to advance a phase.
	if not GameState.phase_gate_ready:
		return
	var gate: Dictionary = _gate_for_phase(GameState.phase)
	if gate.is_empty():
		return
	_gate_event = _build_gate_event(gate)
	_refresh_gate_copy()   # re-apply the escalation body the decline count has earned
	# Deliberately NOT re-enqueued: saving is blocked while anything is queued or showing,
	# so at save time the scene was waiting on the reminder cadence. gate_prompt_day rode
	# along in the save, so _tick_reminder resumes that cadence exactly where it was.


static func daily_tick() -> void:
	if not GameState.run_active:
		return
	if GameState.phase_gate_ready:
		_tick_reminder()  # ratchet: gate stays open, conditions never re-checked
		return
	var gate: Dictionary = _gate_for_phase(GameState.phase)
	if gate.is_empty():
		return
	for c in gate.conditions:
		if not EventManager.is_condition_met(c):
			return
	_open_gate(gate)


static func _open_gate(gate: Dictionary) -> void:
	GameState.phase_gate_ready = true
	GameState.pending_next_phase = int(gate.to)
	EventBus.phase_gate_reached.emit(int(gate.to))
	GameState.set_flag("gate_prompt_day", GameState.day)
	GameState.set_flag("gate_declines", 0)
	GameState.submit_month_highlight(TranslationServer.translate("GATE_OPENED").format(
		{"phase": _phase_display_name(int(gate.to))}), 70)  # AYIN OLAYI (Spec 3 §4)
	_gate_event = _build_gate_event(gate)
	if OS.is_debug_build():
		print("[PhaseGateSystem] Gate open: phase %d → %d" % [int(gate.from), int(gate.to)])
	if GameState.shutter_days_left >= 0:
		return  # §7.4: Frank can't say "hazırsın, büyü" ve "kepenk iniyor" aynı anda
	EventManager.enqueue_front(_gate_event)


static func _tick_reminder() -> void:
	if _gate_event == null:
		return
	if GameState.shutter_days_left >= 0:
		return  # held while the Kepenk runs (§7.4); on_shutter_cleared re-prompts
	if GameState.day - int(GameState.get_flag("gate_prompt_day", 0)) < REMIND_INTERVAL_DAYS:
		return
	GameState.set_flag("gate_prompt_day", GameState.day)
	_refresh_gate_copy()
	EventManager.enqueue_front(_gate_event)  # no-op if still queued/active (dedupe)


static func on_gate_declined() -> void:
	# "Henüz değil" — no penalty (§2.4); escalation index advances, reminder
	# clock re-arms. Called via the "phase_gate_decline" event modifier.
	GameState.set_flag("gate_declines", int(GameState.get_flag("gate_declines", 0)) + 1)
	GameState.set_flag("gate_prompt_day", GameState.day)


# --- Shutter interplay (§7.4) — called by EndingsSystem ---

static func on_shutter_started() -> void:
	# Pull a queued (not yet shown) gate scene; the latch survives.
	if _gate_event != null:
		EventManager.remove_queued(_gate_event.id)


static func on_shutter_cleared() -> void:
	# "Shutter resolves ... then the transition returns" — promptly, not after
	# the reminder cadence catches up.
	if GameState.phase_gate_ready and _gate_event != null:
		GameState.set_flag("gate_prompt_day", GameState.day)
		EventManager.enqueue_front(_gate_event)


# --- Debug (F1) ---

static func debug_force_gate() -> void:
	# Force-open the current phase's gate regardless of conditions.
	if GameState.phase_gate_ready:
		return
	var gate: Dictionary = _gate_for_phase(GameState.phase)
	if gate.is_empty():
		print("[PhaseGateSystem] debug_force_gate: no gate for phase %d" % GameState.phase)
		return
	_open_gate(gate)


# --- The Series A signal (single home; Calibration Round A §3) ---

## What the player is shown instead of the revenue bar: a three-state reading of the gate's
## conditions. "open" = the door is open (gate latched/held, or phase ≥ 3, or every condition
## met right now); "warming" = phase 2 and either signal is moving (the revenue bar cleared OR
## at least one month of qualifying growth); "closed" = phase 1 (the question is not asked
## yet) or phase 2 with neither. `progress` is an equal-weight composite of the two signal
## ratios — a bar that exposes no dollar figure.
static func series_a_signal() -> Dictionary:
	var gate: Dictionary = _gate_for_phase(2)
	var s := {"state": "closed", "mrr_ok": false, "streak_ok": false, "brand_ok": false,
		"streak": 0, "streak_need": GROWTH_STREAK_MONTHS, "mrr_progress": 0.0, "progress": 0.0}
	for c in gate.get("conditions", []):
		match String(c.get("type", "")):
			"mrr_above":
				s.mrr_ok = EventManager.is_condition_met(c)
				s.mrr_progress = clampf(float(GameState.mrr) / float(int(c.get("value", 0)) + 1), 0.0, 1.0)
			"mrr_growth_streak":
				s.streak_need = int(c.get("value", GROWTH_STREAK_MONTHS))
				s.streak = GameState.get_mrr_growth_streak(int(c.get("pct", GROWTH_MIN_PCT)))
				s.streak_ok = s.streak >= s.streak_need
			"brand_above":
				s.brand_ok = EventManager.is_condition_met(c)
	s.progress = 0.5 * s.mrr_progress + 0.5 * clampf(float(s.streak) / float(maxi(1, s.streak_need)), 0.0, 1.0)
	var latched: bool = GameState.phase_gate_ready and GameState.pending_next_phase == 3
	if GameState.phase >= 3 or latched or (GameState.phase == 2 and s.mrr_ok and s.streak_ok and s.brand_ok):
		s.state = "open"
		s.progress = 1.0
	elif GameState.phase == 2 and (s.mrr_ok or s.streak > 0):
		s.state = "warming"
	return s


# --- Helpers ---

static func _gate_for_phase(phase: int) -> Dictionary:
	for gate in GATES:
		if int(gate.from) == phase:
			return gate
	return {}


static func _phase_display_name(phase: int) -> String:
	# Delegates to the single home (GameState.phase_display_name). This used to hold its own
	# copy of ["Bootstrap", "Traction", "Series A"] with a "keep in sync" comment, which is
	# the comment a codebase writes instead of a seam.
	return GameState.phase_display_name(phase)


static func _build_gate_event(gate: Dictionary) -> GameEvent:
	# Synthetic deterministic beat (ship-moment pattern) — reuses EventModal
	# (§2.4, no new UI). Not one_shot: the same cached instance re-surfaces via
	# reminders; one-shot enforcement is the phase_gate_ready latch itself.
	var ev: GameEvent = GameEvent.new()
	ev.id = String(gate.event_id)
	ev.category = "reactive"
	ev.title = _gate_title(gate)
	ev.subtitle = ""
	ev.illustration_path = ""
	ev.character_id = "char_mentor_frank"
	ev.body_text = _gate_body(gate, 0)
	ev.cooldown_days = 0
	ev.one_shot = false
	ev.priority = 10
	ev.tags = ["build_safe", "phase_gate"]
	ev.trigger_conditions = []
	var advance: EventChoice = EventChoice.new()
	advance.label = TranslationServer.translate("GATE_ADVANCE")
	advance.modifiers = [{"type": "advance_phase"}]  # zero economic delta (§2.1)
	advance.unlock_condition = {}
	advance.unlock_reason_text = ""
	var decline: EventChoice = EventChoice.new()
	decline.label = TranslationServer.translate("GATE_DECLINE")
	decline.modifiers = [{"type": "phase_gate_decline"}]
	decline.unlock_condition = {}
	decline.unlock_reason_text = ""
	var choices: Array[EventChoice] = []
	choices.append(advance)
	choices.append(decline)
	ev.choices = choices
	return ev


static func _refresh_gate_copy() -> void:
	# Escalating dryness (§2.4). Safe to mutate: reminders only fire from the
	# daily tick, which never runs while a modal has the tree paused.
	if _gate_event == null:
		return
	var gate: Dictionary = _gate_for_phase(GameState.phase)
	if gate.is_empty():
		return
	# _gate_body clamps to the gate's body_count, so the decline counter can be handed over raw.
	_gate_event.body_text = _gate_body(gate, int(GameState.get_flag("gate_declines", 0)))


## Gate copy lives in strings.csv under GATE_<KEY>_TITLE / GATE_<KEY>_BODY_<n>. The table
## keeps the id and the count; a const cannot hold the words, because a const is evaluated
## when the file loads and no locale exists yet.
static func _gate_title(gate: Dictionary) -> String:
	return TranslationServer.translate("GATE_%s_TITLE" % String(gate.get("copy_key", "")))


## Body variant `idx`, clamped to the gate's count. Which variant is shown depends on how
## many times the player has declined — that arithmetic is unchanged and lives at the caller.
static func _gate_body(gate: Dictionary, idx: int) -> String:
	var n: int = int(gate.get("body_count", 1))
	return TranslationServer.translate("GATE_%s_BODY_%d" % [
		String(gate.get("copy_key", "")), clampi(idx, 0, n - 1)])
