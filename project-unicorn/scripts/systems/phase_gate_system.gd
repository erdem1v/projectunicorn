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
# Series A gate — the growth half (Calibration Round A §3, 2026-08-19). The revenue bar is
# SalesSystem.TRACTION_MRR_TARGET (never rendered as a figure — director ruling: the signal is
# shown, the number is not); the growth half is a STREAK of closed calendar months with
# month-over-month MRR growth. Both are read through series_a_signal() below, the single
# home the Finance indicator, the product page and the ODA board all paint from.
const GROWTH_STREAK_MONTHS := 3   # [WORKING] closed months of MoM growth in a row
const GROWTH_MIN_PCT := 12        # [WORKING] month-over-month MRR growth, percent

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
			# (series_a_signal paints a state, not the number).
			{"seam": "finance.mrr", "op": ">=", "value": SalesSystem.TRACTION_MRR_TARGET},
			# Sustained growth: GROWTH_STREAK_MONTHS closed months at ≥ GROWTH_MIN_PCT MoM.
			# The percentage lives on the seam, which reads GROWTH_MIN_PCT from this file —
			# a seam takes no arguments, and that constraint moved the number to where it
			# already belonged instead of letting two call sites carry their own.
			{"seam": "finance.growth_streak_months", "op": ">=", "value": GROWTH_STREAK_MONTHS},
			{"seam": "finance.brand", "op": ">=", "value": 25},  # working floor; calibration item
		],  # runway deliberately NOT a condition (§2.2 — deadlock; low runway feeds pitch odds instead)
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
	# THE LEAVES ARE WALKED, NOT JUST EVALUATED. This readout needs to know WHICH half of the
	# gate is moving, so it switches on each leaf's seam name and reads the same condition the
	# gate itself runs. It is the reason EvCondition ships a leaf-enumeration API: nesting the
	# gate conditions would otherwise have broken this silently, and the failure would have
	# been a Series A bar that stopped moving rather than an error anyone could see.
	for leaf in EventGate.condition_leaves({"all": gate.get("conditions", [])}):
		var c: Dictionary = leaf
		match String(c.get("seam", "")):
			"finance.mrr":
				s.mrr_ok = EventGate.condition_met(c)
				s.mrr_progress = clampf(
					float(GameState.mrr) / float(maxi(1, int(c.get("value", 1)))), 0.0, 1.0)
			"finance.growth_streak_months":
				s.streak_need = int(c.get("value", GROWTH_STREAK_MONTHS))
				s.streak = GameState.get_mrr_growth_streak(GROWTH_MIN_PCT)
				s.streak_ok = s.streak >= s.streak_need
			"finance.brand":
				s.brand_ok = EventGate.condition_met(c)
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


