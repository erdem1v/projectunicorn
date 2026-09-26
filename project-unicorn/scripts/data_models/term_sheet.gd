class_name TermSheet
extends Resource

# Term sheet data model — a granted offer with a clock.
# Lives in GameState.active_sheets (max PitchConstants.MAX_SHEETS). Created by
# VCPitchSystem on a won meeting (TermSheet.new() + field assignment, never a
# constructor — the project Resource convention). The push-your-luck Term Sheet Table
# reads term_bands as its opening offer; leverage is DERIVED (not stored) so it
# can never go stale — computed against the live sheet set at table time.
#
# Naming caution (mirrors Prospect/Customer): no field named `name`.

# --- Identity / clock ---
## Which rung granted this sheet: PitchConstants.STAGE_SEED or STAGE_SERIES_A.
##
## THE STAGE LIVES ON THE SHEET, NOT IN A STATIC, and the reason is the seed offer's own rule:
## it never expires (SeedConstants.NO_EXPIRY_DAY), so the player can walk away and sit down at
## the table days later. A static set during the meeting is long gone by then, and a table that
## guessed wrong would paint a `raise` lever over `valuation_m` terms and read $0.
##
## An older save has no such field and takes the declared default, which is the correct
## migration: every sheet that existed before the seed rung was a Series A sheet.
@export var stage: String = "series_a"
## Seed only: which conviction band the meeting produced ("strong" / "standard" / "harsh").
## Empty on a Series A sheet. Drives the offer card's variant body and the funding page's word.
@export var band: String = ""
@export var vc_id: String = ""
@export var granted_day: int = 0          # day the validity window opened (delivery day for a delayed sheet)
@export var expires_day: int = 0          # the day the last of PitchConstants.SHEET_VALIDITY_BUSINESS_DAYS falls on

# --- Opening terms (bands snapshot from InvestorRegistry at grant time) ---
@export var term_bands: Dictionary = {}   # {valuation, dilution, board} — working bands

# --- Reserved / forward-compat (Term Sheet Table) ---
@export var patience_pool: int = 0        # copied from the VC at grant; the table consumes it
## The meeting's closing conviction (0..100), stamped at grant; the table's opening eagerness
## starts from it. -1 = not stamped — an older save or a debug grant — and the table
## falls back to a stage default, so an old sheet loads and plays.
@export var conviction: int = -1
@export var opening_terms: Dictionary = {} # {valuation_m, dilution_pct, board_seats, board_veto} — the
                                           # table's NUMERIC opening offer. Snapshot from the
                                           # investor at grant. Pre-close it is shown NOWHERE but the
                                           # table (valuation is a table-only secret).


func days_left(current_day: int) -> int:
	return expires_day - current_day


## Weekdays left before the window closes (0 on the closing day, and after it). This is
## the number every player-facing Series A countdown shows; days_left() stays the calendar
## distance for readers that place the date on a calendar.
func business_days_left(current_day: int) -> int:
	return maxi(0, GameState.business_days_between(current_day, expires_day))


## The window has closed and the fund is waiting for a yes or a no. The sheet stays in
## active_sheets until the player answers (funding.sheet_decision); nothing closes it silently.
func is_decision_due(current_day: int) -> bool:
	return stage != PitchConstants.STAGE_SEED and current_day >= expires_day


## Derived — true when another live sheet exists (leverage at the table). Never stored:
## a stale flag would misreport after the other sheet resolves. Pass the live set.
func is_leverage_active(all_sheets: Array) -> bool:
	for s in all_sheets:
		if s is TermSheet and s != self:
			return true
	return false
