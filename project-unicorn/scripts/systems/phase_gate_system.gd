class_name PhaseGateSystem
extends RefCounted

# Phase Transition Engine — daily tick, after Finance and before the event slot.
#
# Gate = systemic: this system evaluates the current phase's exit condition daily; on satisfy
# it LATCHES (phase_gate_ready + pending_next_phase) and emits phase_gate_reached.
# Transition = played: the phase only changes when the player confirms inside the Frank scene
# → GameState.advance_phase() (the single write seam).
#
# The scenes are cards (`funding.gate_traction`, `funding.gate_series_a`); this file sets the
# ratchet they read and nothing else. The re-ask cadence is the Series A card's own
# `cooldown_days`; the shutter hold is the cards' `finance.shutter_days_left < 0` leaf.
#
# Ratchet: once open, a gate never re-locks; conditions are never re-evaluated after
# the latch. Subgenre-agnostic by construction — conditions run through the ONE condition
# vocabulary, which reads GameState/registry state, so B2C bar-fill and B2B signature feed the
# same evaluator.
#
# Static (FinanceSystem pattern), no system-side state; everything persistent lives on
# GameState.

# The `finance.growth_streak_months` seam's definition of a qualifying month. Not a gate
# condition.
const GROWTH_MIN_PCT := 12        # [WORKING] month-over-month MRR growth, percent

# Frank's approach lines: the share of the revenue bar at which each of the
# three approach cards may speak. series_a_approach() turns MRR into a STEP (0 below the
# first, 1..3 between them, 4 at the bar) so the cards condition on a band and never on a
# dollar figure — the bar stays in exactly one place, SalesSystem.TRACTION_MRR_TARGET.
const APPROACH_PCTS := [50, 75, 90, 100]

# Gate table. Conditions are written in the ENGINE's condition vocabulary and run by
# daily_tick() through EventGate.condition_met. The gate cards do not repeat them — they read
# the ratchet this table opens (phase.gate_ready + funding.gate_pending_phase), so an MRR dip
# after the latch cannot silence an open door. Numeric values are working placeholders
# (numbers last).
const GATES := [
	{
		"from": 1, "to": 2,
		"card_id": "funding.gate_traction",
		"conditions": [
			{"seam": "urun.is_live", "op": "==", "value": true},      # first product shipped
			{"seam": "musteri.count", "op": ">=", "value": 1},        # first real customer
			{"seam": "finance.mrr", "op": ">", "value": 0},           # MRR > 0
		],
	},
	{
		"from": 2, "to": 3,
		"card_id": "funding.gate_series_a",
		"conditions": [
			# MRR ONLY (director decision). Single source SalesSystem.TRACTION_MRR_TARGET,
			# never rendered as a figure (series_a_signal paints a state, not the number).
			# Growth sets the valuation multiple and brand moves meeting conviction; neither
			# holds the door.
			{"seam": "finance.mrr", "op": ">=", "value": SalesSystem.TRACTION_MRR_TARGET},
		],  # runway deliberately NOT a condition (deadlock; low runway feeds pitch odds instead)
		# THE CARD SPEAKS SECOND. The gate latches here; Frank's `funding.frank_door_open` line
		# says it first, and `funding.gate_series_a` waits for that line to have been answered on
		# an EARLIER day (its history leaf) — the door-open message and the decision never
		# share a day.
		# The escalating body (three variants by decline count) is the card's
		# `{by_seam: phase.gate_declines}` block. `gate_declines` itself stays here.
	},
	# Phase 3 has no exit gate — the run resolves through terminals.
]

static func daily_tick() -> void:
	if not GameState.run_active:
		return
	if GameState.phase_gate_ready:
		return  # ratchet: gate stays open, conditions never re-checked, the card re-asks
	var gate: Dictionary = _gate_for_phase(GameState.phase)
	if gate.is_empty():
		return
	for c in gate.conditions:
		if not EventGate.condition_met(c):
			return
	_open_gate(gate)


static func _open_gate(gate: Dictionary) -> void:
	GameState.phase_gate_ready = true
	GameState.pending_next_phase = int(gate.to)
	EventBus.phase_gate_reached.emit(int(gate.to))
	GameState.set_flag("gate_declines", 0)
	GameState.submit_month_highlight(TranslationServer.translate("GATE_OPENED").format(
		{"phase": GameState.phase_display_name(int(gate.to))}), 70)  # AYIN OLAYI
	# NOTHING IS PUSHED. `phase_gate_ready` is the ratchet the card's own condition reads
	# through `phase.gate_ready`, and the daily sweep proposes it — the same day, because both
	# gate cards are tagged `critical` and a critical card does not wait on a weighted draw.


static func on_gate_declined() -> void:
	# "Henüz değil" — no penalty; the escalation index advances. The re-ask clock is the
	# card's own cooldown. Called via the "phase_gate_decline" verb.
	GameState.set_flag("gate_declines", int(GameState.get_flag("gate_declines", 0)) + 1)


# --- Shutter interplay — called by EndingsSystem ---

static func on_shutter_started() -> void:
	# Pull a gate card that is queued but not yet shown; the ratchet survives. A card already
	# ON SCREEN is deliberately left alone — the player is mid-decision, and yanking the modal
	# out from under them is worse than the tonal clash the shutter hold is avoiding.
	for gate in GATES:
		EventGate.remove_queued(String(gate.card_id))
	# `funding.frank_door_open` is deliberately NOT pulled. Its latch is spent at admission and
	# `funding.gate_series_a` waits on its HISTORY row; a removal writes no row, so pulling it
	# here would lock the Series A door for the rest of the run. It is held out of a running
	# shutter by its own `finance.shutter_days_left < 0` leaf instead.


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


# --- The Series A signal (single home) ---

## What the player is shown instead of the revenue bar: a three-state reading of the gate.
## "open" = the door is open (gate latched/held, or phase ≥ 3, or the bar is met right now);
## "warming" = phase 2 and MRR has passed the first of Frank's approach marks
## (APPROACH_PCTS[0] of the bar) — the chip warms on the same day his first approach line may
## speak; "closed" = phase 1 (the question is not asked yet) or phase 2 below that mark.
## No `progress`, no streak. The readout is a chip and a line, and neither carries a ratio.
static func series_a_signal() -> Dictionary:
	var gate: Dictionary = _gate_for_phase(2)
	var s := {"state": "closed", "mrr_ok": false, "approach": 0}
	# THE LEAVES ARE WALKED, NOT JUST EVALUATED. The readout reads the same leaf the gate runs,
	# so the chip cannot disagree with the ratchet.
	for leaf in EventGate.condition_leaves({"all": gate.get("conditions", [])}):
		var c: Dictionary = leaf
		if String(c.get("seam", "")) == "finance.mrr":
			s.mrr_ok = EventGate.condition_met(c)
	s.approach = series_a_approach()
	var latched: bool = GameState.phase_gate_ready and GameState.pending_next_phase == 3
	if GameState.phase >= 3 or latched or (GameState.phase == 2 and s.mrr_ok):
		s.state = "open"
	elif GameState.phase == 2 and int(s.approach) >= 1:
		s.state = "warming"
	return s


## How far along the revenue bar MRR is, as a STEP: the count of APPROACH_PCTS marks cleared
## (0 below 50 %, 1 at 50 %, 2 at 75 %, 3 at 90 %, 4 at the bar). Integer math against the
## same constant the gate's `finance.mrr` leaf holds, so the step can never drift from the
## door. Read by the `phase.series_a_approach` seam; Frank's approach cards condition on it.
static func series_a_approach() -> int:
	var bar: int = series_a_bar()
	var step: int = 0
	for pct in APPROACH_PCTS:
		if GameState.mrr * 100 >= bar * int(pct):
			step += 1
	return step


## The revenue bar — SalesSystem.TRACTION_MRR_TARGET, the same constant the phase-2 gate's
## `finance.mrr` leaf holds. Never rendered; series_a_approach() is its reader.
static func series_a_bar() -> int:
	return maxi(1, SalesSystem.TRACTION_MRR_TARGET)


# --- Helpers ---

static func _gate_for_phase(phase: int) -> Dictionary:
	for gate in GATES:
		if int(gate.from) == phase:
			return gate
	return {}
