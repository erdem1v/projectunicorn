class_name PhaseGateSystem
extends RefCounted

# Phase Transition Engine — daily tick slot 8 per docs/ENDGAME_DESIGN.md §2.
#
# Gate = systemic: this system evaluates the current phase's exit condition daily; on satisfy
# it LATCHES (phase_gate_ready + pending_next_phase) and emits phase_gate_reached.
# Transition = played: the phase only changes when the player confirms inside the Frank scene
# → GameState.advance_phase() (the single write seam).
#
# THE SCENE IS NO LONGER BUILT HERE. `funding.gate_traction` and `funding.gate_series_a` are
# cards; this file sets the ratchet the cards read and nothing else. Four mechanisms died with
# the builder, and every one of them was a workaround for the same missing gate:
#
#   · `_gate_event`, the cached GameEvent that reminders re-surfaced so the queue's dedupe
#     could not stack them. A queue that dedupes by id needs no cached instance.
#   · `gate_prompt_day` + REMIND_INTERVAL_DAYS, a hand-rolled five-day clock. The card
#     declares `cooldown_days: 5` and the gate enforces it.
#   · `restore_gate_cache()`, which existed because a loaded open gate was lost FOREVER and
#     silently — the ratchet stopped conditions being re-evaluated and the reminder returned
#     early on a null cache. Nothing is cached, so nothing is lost.
#   · the two shutter early-returns (§7.4) plus on_shutter_cleared to undo them. One
#     condition leaf, `finance.shutter_days_left < 0`, says it once and can explain itself.
#
# Ratchet (§2.3): once open, a gate never re-locks; conditions are never re-evaluated after
# the latch. Subgenre-agnostic by construction — conditions run through the ONE condition
# vocabulary, which reads GameState/registry state, so B2C bar-fill and B2B signature feed the
# same evaluator (this kills the old _check_traction B2C-branch bug architecturally).
#
# Static (FinanceSystem pattern). NO system-side state at all now; everything persistent lives
# on GameState (§7.9).

# The five-day re-ask is `funding.gate_series_a`'s declared `cooldown_days`. It used to be a
# const here PLUS a `gate_prompt_day` stamp PLUS a comparison in _tick_reminder; one number in
# one place cannot drift from itself.
# Series A gate — MRR ONLY (director decisions K1 + K2, 2026-09). The revenue bar is
# SalesSystem.TRACTION_MRR_TARGET (never rendered as a figure — director ruling: the signal is
# shown, the number is not). The growth streak and the brand floor that Calibration Round A §3
# put on this gate are GONE from it: growth still sets the valuation multiple (PitchConstants
# ARR_GROWTH_* bands) and brand still moves conviction in the meeting, but neither holds the
# door. What the player reads is series_a_signal() below — a chip, no bar, no "n/3" (K3).
#
# GROWTH_MIN_PCT survives only as the `finance.growth_streak_months` seam's definition of a
# qualifying month; nothing on this gate reads it any more.
const GROWTH_MIN_PCT := 12        # [WORKING] month-over-month MRR growth, percent

# Frank's approach lines (plan §6.1, K3): the share of the revenue bar at which each of the
# three approach cards may speak. series_a_approach() turns MRR into a STEP (0 below the
# first, 1..3 between them, 4 at the bar) so the cards condition on a band and never on a
# dollar figure — the bar stays in exactly one place, the gate leaf below.
const APPROACH_PCTS := [50, 75, 90, 100]

# Gate table (§2.2). Conditions are written in the ENGINE's condition vocabulary and are
# byte-identical to the ones on the two gate cards — that is the point of rewriting them: the
# card decides whether to fire and this table decides whether the ratchet opens, and if the two
# ever disagreed the player would be shown a door that does not open. Numeric values are
# working placeholders (§10 — numbers last).
const GATES := [
	{
		"from": 1, "to": 2,
		"card_id": "funding.gate_traction",
		"conditions": [
			{"seam": "urun.is_live", "op": "==", "value": true},      # first product shipped
			{"seam": "musteri.count", "op": ">=", "value": 1},        # first real customer
			{"seam": "finance.mrr", "op": ">", "value": 0},           # MRR > 0
		],
		# ONE body, ONE option (Frank v6, surface 9): the card is a NOTIFICATION — the first
		# payment landed, the gear changes, there is nothing to decline. Copy, option count
		# and labels live on the card now; what stays here is the CONDITION, because
		# series_a_signal() below walks these leaves to paint the player-facing readout.
	},
	{
		"from": 2, "to": 3,
		"card_id": "funding.gate_series_a",
		"conditions": [
			# Single source SalesSystem.TRACTION_MRR_TARGET. Never rendered as a figure
			# (series_a_signal paints a state, not the number). THE ONLY LEAF (K1 + K2): the
			# growth streak and the brand floor were removed from the door, not moved.
			{"seam": "finance.mrr", "op": ">=", "value": SalesSystem.TRACTION_MRR_TARGET},
		],  # runway deliberately NOT a condition (§2.2 — deadlock; low runway feeds pitch odds instead)
		# THE CARD SPEAKS SECOND. The gate latches here; Frank's `funding.frank_door_open` line
		# says it first, and `funding.gate_series_a` waits for that line to have been answered on
		# an EARLIER day (its history leaf) — the door-open message and the decision never
		# share a day.
		# The escalating body (three variants by decline count) is the card's
		# `{by_seam: phase.gate_declines}` block. `gate_declines` itself stays here.
	},
	# Phase 3 has no exit gate — the run resolves through terminals (§2.2 Gate 3).
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
		{"phase": _phase_display_name(int(gate.to))}), 70)  # AYIN OLAYI (Spec 3 §4)
	if OS.is_debug_build():
		print("[PhaseGateSystem] Gate open: phase %d → %d" % [int(gate.from), int(gate.to)])
	# NOTHING IS PUSHED. `phase_gate_ready` is the ratchet the card's own condition reads
	# through `phase.gate_ready`, and the daily sweep proposes it — the same day, because both
	# gate cards are tagged `critical` and a critical card does not wait on a weighted draw.
	# The shutter hold (§7.4) is the card's `finance.shutter_days_left < 0` leaf.


static func on_gate_declined() -> void:
	# "Henüz değil" — no penalty (§2.4); escalation index advances, reminder
	# clock re-arms. Called via the "phase_gate_decline" event modifier.
	GameState.set_flag("gate_declines", int(GameState.get_flag("gate_declines", 0)) + 1)
	# No prompt stamp: the re-ask clock is the card's cooldown, armed by the fire it just had.


# --- Shutter interplay (§7.4) — called by EndingsSystem ---

static func on_shutter_started() -> void:
	# Pull a gate card that is queued but not yet shown; the ratchet survives. A card already
	# ON SCREEN is deliberately left alone — the player is mid-decision, and yanking the modal
	# out from under them is worse than the tonal clash §7.4 is avoiding.
	for gate in GATES:
		EventGate.remove_queued(String((gate as Dictionary).get("card_id", "")))
	# `funding.frank_door_open` is deliberately NOT pulled. Its latch is spent at admission and
	# `funding.gate_series_a` waits on its HISTORY row; a removal writes no row, so pulling it
	# here would lock the Series A door for the rest of the run. It is held out of a running
	# shutter by its own `finance.shutter_days_left < 0` leaf instead.


static func on_shutter_cleared() -> void:
	# Nothing to do, and that is the whole change. The hold was
	# `finance.shutter_days_left < 0` failing; the day it passes, the daily sweep proposes the
	# card again. This used to re-stamp gate_prompt_day so the reminder cadence would not
	# swallow the re-prompt — there is no cadence to outrun now, only the card's own cooldown,
	# and a shutter long enough to matter outlasts five days.
	pass


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

## What the player is shown instead of the revenue bar: a three-state reading of the gate.
## "open" = the door is open (gate latched/held, or phase ≥ 3, or the bar is met right now);
## "warming" = phase 2 and MRR has passed the first of Frank's approach marks
## (APPROACH_PCTS[0] of the bar) — the chip warms on the same day his first approach line may
## speak; "closed" = phase 1 (the question is not asked yet) or phase 2 below that mark.
## K3: no `progress`, no streak. The readout is a chip and a line, and neither carries a ratio.
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
## gate's own `finance.mrr` leaf, so the step can never drift from the door. Read by the
## `phase.series_a_approach` seam; Frank's approach cards condition on it.
static func series_a_approach() -> int:
	var bar: int = series_a_bar()
	var step: int = 0
	for pct in APPROACH_PCTS:
		if GameState.mrr * 100 >= bar * int(pct):
			step += 1
	return step


## The revenue bar as the gate table holds it — the value of the phase-2 gate's
## `finance.mrr` leaf. Never rendered; the approach step and the signal are its only readers.
static func series_a_bar() -> int:
	var gate: Dictionary = _gate_for_phase(2)
	for leaf in EventGate.condition_leaves({"all": gate.get("conditions", [])}):
		var c: Dictionary = leaf
		if String(c.get("seam", "")) == "finance.mrr":
			return maxi(1, int(c.get("value", 1)))
	return maxi(1, SalesSystem.TRACTION_MRR_TARGET)


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


