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
@export var vc_id: String = ""
@export var granted_day: int = 0          # day the validity window opened (delivery day for a delayed sheet)
@export var expires_day: int = 0          # granted_day + PitchConstants.SHEET_VALIDITY_DAYS

# --- Opening terms (bands snapshot from InvestorRegistry at grant time; Spec 6 refines) ---
@export var term_bands: Dictionary = {}   # {valuation, dilution, board} — working bands

# --- Reserved / forward-compat (Spec 6 Term Sheet Table) ---
@export var patience_pool: int = 0        # copied from the VC at grant; the table consumes it


func days_left(current_day: int) -> int:
	return expires_day - current_day


## Derived — true when another live sheet exists (leverage at the table). Never stored:
## a stale flag would misreport after the other sheet resolves (§6). Pass the live set.
func is_leverage_active(all_sheets: Array) -> bool:
	for s in all_sheets:
		if s is TermSheet and s != self:
			return true
	return false
