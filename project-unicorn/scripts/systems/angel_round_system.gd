class_name AngelRoundSystem
extends RefCounted

# Frank's angel round — the early-game economy bridge (canon, July 2026).
#
# Frank is an angel, not a fund. His cheque arrives once, after a played MVP and real
# revenue, with no term-sheet ceremony: one warm-dry Frank scene, one decision. Taking it
# costs 4% of the company. Refusing it is the hard path, and the hard path is not built
# yet — so that choice ships VISIBLE AND LOCKED rather than hidden, which is the game's
# standing grammar for a door the player can see but not open.
#
# THE SCENE IS NOW CONTENT; THIS FILE IS THE ARITHMETIC. Three things once kept the cheque
# out of the event pool, and the rebuilt engine answered all three:
#   1. "one_shot cannot survive the enqueue path, so the latch has to be a GameState flag."
#      There is no enqueue path any more. `funding.frank_cheque` declares `one_shot` and the
#      gate enforces it, so `angel_seed_offered` is gone — with it the class of bug where a
#      card's declared latch was inert and a hand-rolled flag was the real one.
#   2. "Two JSON modifiers are two writes a loop applies in order." Still true, and still the
#      reason `accept_offer()` below stays one atomic function. The card names it through the
#      `angel_accept` verb instead of describing the round in modifiers.
#   3. "The vocabulary has no flag_unset." It has `flag_unset`, `none` and `not` now. The
#      hard-mode lock is `requires: {flag: hard_mode_unlocked}` on the decline option, which
#      is the same honest lock expressed in data.
#
# WHAT REMAINS PERSISTENT is one day stamp, `angel_seed_accepted_day`, and it stays in
# GameState because three other readers want it (HRSystem's rail badge, RunProbe, and the
# `funding.angel_days_since_accept` seam). It did NOT move into the engine FlagStore: moving
# a flag's storage silently breaks every condition that reads the old place.


# WORKING (director, 2026-08-17). The bar was ruled down from 5,000 after the collision
# was measured: at 5,000 this scene and the Traction→Series A gate share one MRR bar
# (phase_gate_system.gd reads SalesSystem.TRACTION_MRR_TARGET - 1), so the angel round and
# the Series A door opened on the same day — and $25,000 against a 5,000-MRR company is no
# bridge at all. Deliberately NOT wired to TRACTION_MRR_TARGET: this is a different bar
# with a different job, and sharing the constant would silently re-create the collision.
const MRR_THRESHOLD := 2500
const CASH_AMOUNT := 25_000
const EQUITY_PCT := 4
const TX_LABEL := "angel_seed"                 # raw id; display via FinanceSystem.ONE_TIME_LABELS
const FLAG_ACCEPTED_DAY := "angel_seed_accepted_day"
const HARD_MODE_FLAG := "hard_mode_unlocked"

# The hire nudge — Frank, a day or two after the money lands, on the subject of being one
# person — is `funding.hire_nudge` and lives in data. It kept the delay (two days, read back
# through `funding.angel_days_since_accept`), lost `angel_nudge_shown`, and gained the thing
# the flag was standing in for: `one_shot`, declared on the card and enforced by the gate.
#
# THIS FILE NO LONGER HAS A daily_tick. TRIGGER_CONDITIONS moved onto `funding.frank_cheque`
# as `urun.is_live` + `funding.angel_threshold_met` + `investor.angel_taken == false`, which
# is the same three questions asked in the vocabulary that can also explain a refusal.


# --- THE ATOMIC ACCEPT SEAM (called by the "angel_accept" modifier) ---

static func accept_offer() -> void:
	# Cash + ledger row + cap table + latch: together or not at all.
	#
	# "Atomic" here means one function, one call site, and no observable intermediate. The
	# re-entry guard sits ABOVE every write, so a partially applied round is
	# unrepresentable; the first signal any listener can see (equity_changed) fires after
	# the ledger row is appended and both cap-table scalars are written.
	#
	# THE ORDER IS LOAD-BEARING, and it copies apply_one_time_cost's reasoning: cash goes
	# LAST because cash_changed is synchronous and the Finance tab repaints inside it — it
	# must read a settled ledger and a settled cap table, never a half-applied round.
	# Moving the cash write up by one line ships a one-frame bar reading 0% beside $25,000
	# of new money.
	if GameState.run_angel_amount > 0:
		push_warning("[AngelRoundSystem] accept_offer called twice — ignored")
		return
	GameState.record_angel_round(EQUITY_PCT, CASH_AMOUNT)      # cap table → equity_changed
	FinanceSystem.apply_one_time_income(CASH_AMOUNT, TX_LABEL) # ledger row, then set_cash
	GameState.set_flag(FLAG_ACCEPTED_DAY, GameState.day)       # Step 3's hire nudge reads this
	GameState.submit_month_highlight(
		TranslationServer.translate("ANGEL_MONTH_HIGHLIGHT"), 75)  # below advance_phase's 80
	if OS.is_debug_build():
		print("[AngelRoundSystem] seed taken: +$%d for %d%% (day %d)" % [
			CASH_AMOUNT, EQUITY_PCT, GameState.day])
