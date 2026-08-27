class_name SeedRoundSystem
extends RefCounted

# The seed rung — the middle step of the ladder (GDD v2 ch. 09 §1-3, director-approved
# 2026-08-20; parameters 2026-08-27). Savings → Frank's cheque → SEED → Series A.
#
# WHAT THIS FILE IS. The arithmetic and the ratchet: when the door opens, what a conviction
# value buys, what accepting moves, and how the growth expectation reads. It is the
# AngelRoundSystem pattern one rung up — that file's own header says the scene is content and
# the file is arithmetic, and the same split holds here.
#
# WHAT THIS FILE IS NOT. It does not run a meeting and it does not run a table. The seed
# REUSES VCPitchSystem and TermSheetTableSystem, and that reuse is a correctness argument, not
# a convenience one: SaveManager.can_save() and reset_all_owners() already name those two
# systems, so a seed sitting is provably idle at every save point with ZERO edits to either
# list. A third sitting-scoped system would have needed a line in each, and forgetting one
# ships a save taken mid-seed-meeting that restores with seed_pitch_used already true, no
# modal on screen, and no pitch left to spend.
#
# THIS FILE HOLDS NO STATIC STATE, ON PURPOSE. Every read walks GameState. That is why it is
# absent from SaveManager.reset_all_owners() — there is nothing to reset. THE DAY SOMEONE ADDS
# A `static var` HERE, IT MUST JOIN THAT LIST IN THE SAME COMMIT, or the next run inherits the
# last one's seed state.
#
# THE EXPECTATION IS DERIVED, NEVER STORED (§ "Growth expectation" below). month_history +
# seed_closed_day + day is enough to answer it, and a stored copy is a thing that can disagree
# with the ledger it was computed from. Same reasoning as get_runway_months and
# get_investor_equity_pct, both of which recompute rather than cache.


# ============================================================================
# The door (ruling 1) — a RATCHET, not a live predicate
# ============================================================================

## Is the seed door open right now? Reads the ratchet, never the bar.
##
## RATCHET, AND THE BUG IT PREVENTS. `seed_door_open_day` latches once and is never cleared by
## an MRR dip, exactly like PhaseGateSystem's own gate. A live `mrr >= DOOR_MRR` predicate here
## would re-lock the Finance sub-page under a player who lost a customer the day after the door
## opened — and the door card is `one_shot`, so it would never re-announce. The door opens once.
static func door_open() -> bool:
	if GameState.seed_lead != "" or GameState.seed_pitch_used:
		return false                       # already spent, either way
	if GameState.phase != SeedConstants.DOOR_PHASE:
		return false                       # Traction only; entering Series A closes it
	return GameState.seed_door_open_day >= 0


## Has the door EVER opened this run? The Finance sub-page unlock reads this rather than
## door_open(), because the page must stay reachable after the round is taken — that is where
## the cap-table row and the growth-expectation line live.
static func page_unlocked() -> bool:
	return GameState.seed_door_open_day >= 0


## Daily tick — latches the ratchet and nothing else. Dispatched right after
## PhaseGateSystem.daily_tick() so the flag is written before the day's event sweep, which is
## what lets `funding.seed_door` be proposed on the same day the bar is crossed.
##
## NOTHING IS PUSHED, for the same reason PhaseGateSystem._open_gate pushes nothing: the flag
## IS the condition the card reads (through `funding.seed_door_open`), and a `critical` card
## does not wait on a weighted draw.
static func daily_tick() -> void:
	if not GameState.run_active:
		return
	if GameState.seed_door_open_day >= 0:
		return                                       # ratchet: latched once, never re-evaluated
	if GameState.phase != SeedConstants.DOOR_PHASE:
		return
	if GameState.seed_lead != "" or GameState.seed_pitch_used:
		return
	if GameState.mrr < SeedConstants.DOOR_MRR:
		return
	GameState.seed_door_open_day = GameState.day
	EventBus.seed_door_opened.emit()
	if OS.is_debug_build():
		print("[SeedRoundSystem] Seed door open (day %d)" % GameState.day)


# ============================================================================
# Entering the room (ruling 2) — one pitch, the player's choice of fund
# ============================================================================

## "" when this fund can be pitched; otherwise the reason key to show. No fake choices — the
## funding page renders the reason instead of a dead button (the prep_blocked_reason grammar).
static func pitch_blocked_reason(vc_id: String) -> String:
	if GameState.seed_lead != "":
		return "SEED_BLOCK_TAKEN"
	if GameState.seed_pitch_used:
		return "SEED_BLOCK_SPENT"
	if not door_open():
		return "SEED_BLOCK_CLOSED"
	if InvestorRegistry.is_locked(vc_id) or InvestorRegistry.get_investor(vc_id).is_empty():
		return "SEED_BLOCK_CLOSED"
	if VCPitchSystem.is_active() or TermSheetTableSystem.is_active():
		return "SEED_BLOCK_BUSY"
	return ""


## Sit down with this fund. The ONE seed pitch of the run is spent here, before the meeting
## opens, so a mid-meeting quit cannot hand it back.
##
## NO SCHEDULING CEREMONY, and that is deliberate. The Series A hunt makes you book three days
## ahead and choose a prep focus; the seed room does not, because ch. 09 §4 casts it as the
## fast room — a bet on the founder, not a diligence appointment. It also keeps
## GameState.pending_meeting a Series-A-only field, so `funding.meeting_day` and every seam
## that reads a booked meeting stay untouched by this rung.
static func begin_pitch(vc_id: String) -> bool:
	if pitch_blocked_reason(vc_id) != "":
		return false
	GameState.seed_pitch_used = true
	VCPitchSystem.begin_meeting(vc_id, PitchConstants.STAGE_SEED)
	return true


# ============================================================================
# The offer (rulings 3 + 4) — conviction buys a band, the band buys the terms
# ============================================================================

## Build the seed offer for a fund at a conviction band. Pure — the caller stores it.
##
## THE SHEET CARRIES ITS OWN STAGE. TermSheet.stage is what the table reads days later; a
## static set during the meeting is gone by then, because the offer does not expire and the
## player may sit down whenever they like.
static func make_seed_sheet(vc_id: String, band: String, granted_day: int) -> TermSheet:
	var inv: Dictionary = InvestorRegistry.get_investor(vc_id)
	var bands: Dictionary = inv.get("term_bands", {})
	var opening: Dictionary = SeedConstants.OPENING.get(band, SeedConstants.OPENING[SeedConstants.BAND_HARSH])
	var board: Dictionary = SeedConstants.BOARD.get(band, SeedConstants.BOARD[SeedConstants.BAND_HARSH])

	# The band picks the corner, the fund's archetype nudges inside it, the band clamps it back.
	var raise_amount: int = clampi(
		int(opening.raise) + int(SeedConstants.ARCH_RAISE_NUDGE.get(String(bands.get("valuation", "mid")), 0)),
		SeedConstants.RAISE_MIN, SeedConstants.RAISE_MAX)
	var dilution: int = clampi(
		int(opening.dilution_pct) + int(SeedConstants.ARCH_DIL_NUDGE.get(String(bands.get("dilution", "mid")), 0)),
		SeedConstants.DIL_MIN, SeedConstants.DIL_MAX)

	var sheet := TermSheet.new()
	sheet.vc_id = vc_id
	sheet.stage = PitchConstants.STAGE_SEED
	sheet.band = band
	sheet.granted_day = granted_day
	sheet.expires_day = SeedConstants.NO_EXPIRY_DAY   # ruling 6 — the rung is guaranteed
	sheet.term_bands = bands.duplicate()
	sheet.patience_pool = int(SeedConstants.PATIENCE_BY_BAND.get(band, 2))
	# `raise`, not `valuation_m`: at seed the MONEY is the lever and the valuation is derived
	# (TermSheetTableSystem.implied_post_money). At Series A it is the other way round. That
	# inversion is the only structural difference between the two tables.
	sheet.opening_terms = {
		"raise": raise_amount,
		"dilution_pct": dilution,
		"board_seats": int(board.seats),
		"board_veto": bool(board.veto),
	}
	return sheet


# ============================================================================
# Accepting (ruling 6) — atomic, and NOT terminal
# ============================================================================

## The whole round: cap table, ledger row, cash, latch. Together or not at all.
##
## Called from VCPitchSystem.sign_table when the sheet's stage is seed — the same seam a
## Series A signature runs through, which is what keeps "the money moves at a played İMZALA"
## true for both rungs and is why no economic effect verb was added for this.
##
## THE ORDER IS LOAD-BEARING and copied from AngelRoundSystem.accept_offer: the re-entry guard
## sits ABOVE every write, so a half-applied round is unrepresentable, and CASH GOES LAST among
## the money writes because cash_changed is synchronous and the Finance tab repaints inside it
## — it must read a settled cap table, never a one-frame 0% beside new money.
##
## NO ENDING FIRES. series_a_closed is untouched; the run continues. That is the whole point of
## the rung: it is the first term sheet the player signs and the first one that does not end
## the game.
static func accept(vc_id: String, terms: Dictionary) -> void:
	if GameState.run_seed_amount > 0:
		push_warning("[SeedRoundSystem] accept called twice — ignored")
		return
	var amount: int = int(terms.get("raise", 0))
	var equity: int = int(terms.get("dilution_pct", 0))
	if amount <= 0 or equity <= 0:
		push_warning("[SeedRoundSystem] accept with empty terms — ignored")
		return
	GameState.record_seed_round(equity, amount, vc_id)          # cap table → equity_changed
	FinanceSystem.apply_one_time_income(amount, SeedConstants.TX_LABEL)  # ledger row, then set_cash
	GameState.seed_closed_day = GameState.day                   # the expectation clock starts here
	GameState.seed_sheet = null                                 # the offer is spent
	GameState.submit_month_highlight(
		TranslationServer.translate("SEED_MONTH_HIGHLIGHT"), 78)  # above the angel's 75, below advance_phase's 80
	EventBus.seed_round_closed.emit(vc_id)
	if OS.is_debug_build():
		print("[SeedRoundSystem] seed closed: +$%d for %d%% with %s (day %d)" % [
			amount, equity, vc_id, GameState.day])


# ============================================================================
# The growth expectation (ruling 7)
# ============================================================================

## The full reading the funding page paints and the fumes paper colours from.
## {state, avg_pct, need_pct, grace_days_left}. `avg_pct` is
## GameState.GROWTH_AVG_UNKNOWN when there are too few closed months to judge.
##
## A ROLLING AVERAGE, NOT A STREAK. One flat month inside a good quarter is not a stall, and
## get_mrr_growth_streak — the helper sitting directly beside the one this reads — would have
## called it one. The expectation the investor stated out loud is an average, so the reading is.
static func expectation() -> Dictionary:
	var d := {
		"state": SeedConstants.EXPECT_NONE,
		"avg_pct": GameState.GROWTH_AVG_UNKNOWN,
		"need_pct": SeedConstants.EXPECT_MOM_PCT,
		"grace_days_left": 0,
	}
	if GameState.seed_lead == "" or GameState.seed_closed_day < 0:
		return d                                  # no money taken ⇒ nothing was promised
	var since: int = GameState.day - GameState.seed_closed_day
	d.avg_pct = GameState.get_mom_growth_avg_pct(SeedConstants.EXPECT_WINDOW_MONTHS)
	if since < SeedConstants.EXPECT_GRACE_DAYS:
		d.state = SeedConstants.EXPECT_GRACE
		d.grace_days_left = SeedConstants.EXPECT_GRACE_DAYS - since
		return d
	if int(d.avg_pct) == GameState.GROWTH_AVG_UNKNOWN:
		# Past the grace window but the calendar ledger cannot answer yet (too few closes).
		# Reading that as a stall would accuse the player on missing evidence, so it stays
		# GRACE — the honest state for "not enough months to judge".
		d.state = SeedConstants.EXPECT_GRACE
		return d
	d.state = SeedConstants.EXPECT_ON_TRACK if int(d.avg_pct) >= SeedConstants.EXPECT_MOM_PCT \
		else SeedConstants.EXPECT_STALLED
	return d


## The state alone — the shape the seams and the card conditions want.
static func expectation_state() -> int:
	return int(expectation().get("state", SeedConstants.EXPECT_NONE))
