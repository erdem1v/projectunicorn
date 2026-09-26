class_name AngelRoundSystem
extends RefCounted

# Frank's angel round — the early-game economy bridge.
#
# Frank is an angel, not a fund. His cheque arrives once, after a played MVP and real
# revenue, with no term-sheet ceremony: one warm-dry Frank scene, one decision. Taking it
# costs 4% of the company. Refusing it is the hard path, and the hard path is not built
# yet — so that choice ships VISIBLE AND LOCKED rather than hidden, which is the game's
# standing grammar for a door the player can see but not open.
#
# THE SCENE IS CONTENT; THIS FILE IS THE ARITHMETIC. `funding.frank_cheque` carries the
# trigger, the one_shot latch and the decline lock (`requires` on the funding.hard_mode seam),
# and its accept option calls accept_offer() through the `angel_accept` verb — one atomic
# function rather than JSON modifiers a loop applies in order. The hire nudge that follows
# is `funding.hire_nudge`.
#
# The accept day, `angel_seed_accepted_day`, is a GameState flag, not an engine FlagStore one:
# HRSystem's rail badge, RunProbe and the investor.angel_taken / funding.angel_days_since_accept
# seams read it there, and moving a flag's storage silently breaks every condition that reads
# the old place.


# [WORKING] Frank's MRR bar (read by the funding.angel_threshold_met seam). Deliberately NOT
# SalesSystem.TRACTION_MRR_TARGET: a different bar with a different job, and sharing it would
# open the angel round and the Series A door on the same day.
const MRR_THRESHOLD := 2500
const CASH_AMOUNT := 25_000
const EQUITY_PCT := 4
const TX_LABEL := "angel_seed"                 # raw id; display via FinanceSystem.ONE_TIME_LABELS
const FLAG_ACCEPTED_DAY := "angel_seed_accepted_day"
const HARD_MODE_FLAG := "hard_mode_unlocked"


# --- THE ATOMIC ACCEPT SEAM (called by the "angel_accept" verb) ---

static func accept_offer() -> void:
	# Cash + ledger row + cap table + latch: together or not at all. The re-entry guard sits
	# ABOVE every write, so a partially applied round is unrepresentable.
	#
	# THE ORDER IS LOAD-BEARING, and it copies apply_one_time_cost's reasoning: the cap table
	# goes first (equity_changed fires once both scalars are written) and cash last among the
	# money writes, because cash_changed is synchronous and the Finance tab repaints inside it —
	# it must read a settled ledger and a settled cap table, never a one-frame 0% bar beside
	# $25,000 of new money.
	if GameState.run_angel_amount > 0:
		push_warning("[AngelRoundSystem] accept_offer called twice — ignored")
		return
	GameState.record_angel_round(EQUITY_PCT, CASH_AMOUNT)      # cap table → equity_changed
	FinanceSystem.apply_one_time_income(CASH_AMOUNT, TX_LABEL) # ledger row, then set_cash
	GameState.set_flag(FLAG_ACCEPTED_DAY, GameState.day)       # funding.hire_nudge's delay reads this
	GameState.submit_month_highlight(
		TranslationServer.translate("ANGEL_MONTH_HIGHLIGHT"), 75)  # below advance_phase's 80
