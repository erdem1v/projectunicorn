class_name TermSheet
extends Resource

# Term sheet data model (Spec 4 / VC_PITCH_DESIGN.md §5) — a granted offer with a clock.
# Lives in GameState.active_sheets (max PitchConstants.MAX_SHEETS). Created by
# VCPitchSystem on a won meeting (TermSheet.new() + field assignment, never a
# constructor — the project Resource convention). The push-your-luck Term Sheet Table
# (Spec 6) reads term_bands as its opening offer; leverage is DERIVED (not stored) so it
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
@export var expires_day: int = 0          # granted_day + PitchConstants.SHEET_VALIDITY_DAYS

# --- Opening terms (bands snapshot from InvestorRegistry at grant time; Spec 6 refines) ---
@export var term_bands: Dictionary = {}   # {valuation, dilution, board} — working bands

# --- Reserved / forward-compat (Spec 6 Term Sheet Table) ---
@export var patience_pool: int = 0        # copied from the VC at grant; the table consumes it
@export var opening_terms: Dictionary = {} # {valuation_m, dilution_pct, board_seats, board_veto} — the
                                           # table's NUMERIC opening offer (Spec 6). Snapshot from the
                                           # investor at grant. Pre-close it is shown NOWHERE but the
                                           # table (ledger 8 — valuation is a table-only secret).


func days_left(current_day: int) -> int:
	return expires_day - current_day


## Derived — true when another live sheet exists (leverage at the table). Never stored:
## a stale flag would misreport after the other sheet resolves (§6). Pass the live set.
func is_leverage_active(all_sheets: Array) -> bool:
	for s in all_sheets:
		if s is TermSheet and s != self:
			return true
	return false
