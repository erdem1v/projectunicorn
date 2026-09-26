class_name TermSheetTableSystem
extends RefCounted

# Term Sheet Table engine. Static, pure-logic (VCPitchSystem pattern). The push-your-luck
# negotiation over a granted TermSheet: the founder pushes three levers (Valuation or Raise /
# Dilution / Board) against a finite patience pool, each push a visible-odds skill check
# resolved on the dial, until the player SIGNS (the Series A Hard Win, or the seed round) or
# WALKS (Series A only; not a rejection).
#
# TWO state homes (mirrors VCPitchSystem):
#   * The sheet's immutable opening_terms + patience_pool live on the TermSheet (GameState).
#   * The per-SITTING working state (working terms, push counts, remaining patience, selected
#     lever, current state) lives in the static vars below — NEVER serialized. Each open() is a
#     fresh sitting (a deferred sheet re-opens clean; patience is never written back to the sheet).
#
# The scene (TermSheetTableScene) is a humble view: it calls this system and paints the single
# view_state() dict through one _render(). All push/patience/decay/money math lives HERE, so the
# headless smoke suite drives the whole negotiation with no scene mounted.

# --- Table states. The ints are pinned, gaps included: PROBE VC_PUSH prints state=%d and its
# lines are compared byte for byte across runs. push() returns the already-settled state; the
# dial spin and the sign confirmation live in the scene. ---
#   PATIENCE_ZERO — the fund's FINAL OFFER: take it or leave it, only Sign (and Walk at Series A).
#   FUND_WALKED — the fund left the table (patience ran out below its walk line, or it walked
#                 on a shown offer). The closure is ALREADY written when this state is entered;
#                 the only action left is leave().
#   OTHER_SHOWN — the player showed the other live Series A sheet and the fund answered.
enum { IDLE = 1, LEVER_SELECTED = 2, PUSH_SUCCESS = 4, PUSH_FAILURE = 5, PATIENCE_ZERO = 6,
	FUND_WALKED = 8, OTHER_SHOWN = 9 }

const LEVERS := ["valuation", "dilution", "board"]
## The seed table's rows. Lever one is the MONEY here, not the valuation: a seed round is
## negotiated as "how much, for how much of the company", and the valuation is what falls
## out of those two. At Series A it is the other way round. That inversion is the only
## structural difference between the two tables — everything else is the same object.
const SEED_LEVERS := ["raise", "dilution", "board"]

# ============================================================================
# EAGERNESS (E) — THE ONE TUNING BLOCK for the table's risk model.
# E is 0..100: how much this fund still wants the deal. It is never shown as a number; the
# player reads it off the investor's line after every push (relaxed / tense / running out).
# Every number the model reads lives here and nowhere else.
# ============================================================================

## Opening E = the meeting's conviction (stamped on the sheet at grant) + the fund's domain fit.
## A sheet with no stamp (an older save, a debug grant) assumes this conviction instead.
## Series A: a sheet only exists past the win line, so the win line is the honest floor.
const E_FALLBACK_CONV_SERIES_A := PitchConstants.WON_MIN
## Seed: the band the room produced is all an unstamped seed sheet knows.
const E_FALLBACK_CONV_SEED := {"strong": 80, "standard": 55, "harsh": 35}

## Domain fit — each fund reads its own lens, the sum is clamped to ±E_FIT_MAX.
const E_FIT_MAX := 12
const E_FIT_METRICS_MRR := 6        # Anchor: MRR at/above the room's MRR reference (+), below (−)
const E_FIT_METRICS_CHURN := 6      # Anchor: no customer lost this run (+), any lost (−)
const E_FIT_TEAM_ENGINEER := 6      # Nexus: at least one developer (+), none (−)
const E_FIT_TEAM_SIZE := 4          # Nexus: headcount at/above E_FIT_TEAM_SIZE_MIN (+)
const E_FIT_TEAM_SIZE_MIN := 4
const E_FIT_NARRATIVE_BRAND := 6    # Bosphorus: brand at/above the room's brand floor (+), below (−)
const E_FIT_NARRATIVE_WARM := 4     # Bosphorus: came through a warm intro (+)
const E_FIT_PRODUCT_SHIPPED := 4    # Meridian: MVP shipped (+), not shipped (−)
const E_FIT_PRODUCT_BUGS := 6       # Meridian: live bugs (−), none (+)
const E_FIT_PRODUCT_DIMS := 4       # Meridian: no quality axis under the floor below (+)
const E_FIT_PRODUCT_DIM_FLOOR := 40.0

## What a push costs in E. A FAILED push also costs 1 patience. The ask size is
## how far this push would drag the lever from the fund's opening offer, in steps
## (1 on the first ask, 2 once one step has been won, ...): bigger asks sting more.
const E_PUSH_FAIL_BASE := 6
const E_PUSH_FAIL_PER_STEP := 4
const E_PUSH_WIN_COST := 3          # a won push still spends a little goodwill
const E_CARE_LEVER_EXTRA := 3       # added to either cost when the push is on the fund's own lever

## Walk line: at patience zero, E below this and the fund walks (Series A only). Shorter-
## patience funds walk more easily: threshold = E_WALK_BASE − E_WALK_PER_PATIENCE × pool
## → pool 2: 55 · pool 3: 45 · pool 4: 35.
const E_WALK_BASE := 75
const E_WALK_PER_PATIENCE := 10
## Band read by the investor's line: relaxed at/above threshold + margin, tense at/above the
## threshold, "running out" below it (at Series A: the next patience-zero is a walk-out).
const E_BAND_RELAXED_MARGIN := 20

## The final counter at patience zero lands between the working terms (where the fund stops)
## and the player's last ask. share = clamp((E − threshold) / E_FINAL_SPAN, 0, 1); the fund
## concedes share × E_FINAL_MAX_SHARE of one step on the lever the last push asked for, and
## drops the asked board term only when share reaches E_FINAL_BOARD_SHARE.
const E_FINAL_SPAN := 30.0
const E_FINAL_MAX_SHARE := 0.5
const E_FINAL_BOARD_SHARE := 0.75

## "Show the other offer". Each fund compares on the lever it cares about, and claws back
## on another when it matches with a condition.
const CARE_LEVER := {"metrics": "valuation", "team": "dilution", "narrative": "board", "product": "valuation"}
const CLAWBACK_LEVER := {"metrics": "board", "team": "valuation", "narrative": "dilution", "product": "dilution"}
## pull = E + SHOW_PATIENCE_WEIGHT × patience left − SHOW_GAP_COST × gap (in push steps).
const SHOW_PATIENCE_WEIGHT := 5
const SHOW_GAP_COST := 12
const SHOW_MATCH_MIN := 70          # pull at/above → MATCH (closes SHOW_MATCH_MIN_SHARE..all of the gap)
const SHOW_MATCH_MIN_SHARE := 0.5
const SHOW_MATCH_FULL_SPAN := 20.0  # pull this far above SHOW_MATCH_MIN closes the whole gap
const SHOW_CONDITION_MIN := 50      # pull at/above → MATCH WITH A CONDITION; below → HOLD
const SHOW_WALK_GAP := 2.0          # WALK needs a gap this big (steps) AND E under the walk line
const SHOW_MATCH_E_COST := 4        # matching spends goodwill
const SHOW_HOLD_E_COST := 10        # holding means the move annoyed them
const SHOW_BOARD_SEAT_CAP := 2      # a board claw-back never asks past this many seats

## The investor's line bank. Relaxed / tense are generic (two each, rotated so the same line
## never plays twice in a row); "running out" is the fund's own voice.
const LINES_RELAXED := ["TERM_INV_RELAXED_1", "TERM_INV_RELAXED_2"]
const LINES_TENSE := ["TERM_INV_TENSE_1", "TERM_INV_TENSE_2"]
const LINES_RUNNING_OUT := {
	"anchor": "TERM_INV_OUT_ANCHOR", "nexus": "TERM_INV_OUT_NEXUS",
	"bosphorus": "TERM_INV_OUT_BOSPHORUS", "meridian": "TERM_INV_OUT_MERIDIAN"}
const LINE_RUNNING_OUT_FALLBACK := "TERM_INV_OUT_GENERIC"

const BAND_RELAXED := "relaxed"
const BAND_TENSE := "tense"
const BAND_RUNNING_OUT := "running_out"

const SHOW_MATCH := "match"
const SHOW_CONDITION := "condition"
const SHOW_HOLD := "hold"
const SHOW_WALK := "walk"

# --- Table-local sitting state (never serialized) ---
static var _active: bool = false
static var _vc_id: String = ""
static var _terms: Dictionary = {}          # WORKING copy of opening_terms {valuation_m or raise, dilution_pct, board_seats, board_veto}
static var _push_counts: Dictionary = {}    # lever → push attempts (the decay driver)
static var _patience: int = 0               # remaining, seeded from sheet.patience_pool each open()
static var _patience_max: int = 0
static var _selected_lever: String = "valuation"
static var _state: int = IDLE
static var _last_push_passed: bool = false
static var _last_lever_acted: String = ""   # the lever the last push touched ("" = none this sitting)
static var _last_move: String = ""          # "$18M → $22M" for the success caption
## Which rung this sitting is, read off the SHEET (TermSheet.stage) rather than handed in:
## the seed offer never expires, so a static set during the meeting is long gone by the time
## the player sits down. Cleared in _reset(), or a seed sitting's stage leaks into the next
## Series A table.
static var _stage: String = PitchConstants.STAGE_SERIES_A
# --- Eagerness / shown-offer sitting state ---
static var _e: int = 0                      # eagerness 0..100
static var _won_counts: Dictionary = {}     # lever → successful pushes (the ask-size driver)
static var _line_key: String = ""           # the investor's current line ("" = silent)
static var _line_seq: int = 0               # rotation counter for the generic line pools
static var _final_move: String = ""         # "$18M → $20M" when the final counter conceded
static var _fund_walked: bool = false       # the closure is already written; only leave() remains
static var _other_shown: bool = false       # showing the other offer is once per table
static var _show_outcome: String = ""       # SHOW_* of the fund's last answer to a shown offer
static var _show_back: String = ""          # the claw-back move text for SHOW_CONDITION
static var _other_terms: Dictionary = {}    # the real other sheet, as shown
static var _other_vc_shown: String = ""


## The rows this sitting has. Every loop over the sitting's rows walks this, the SCENE's row
## build included (term_sheet_table_scene.gd binds a lever id per row); only _terms_text, which
## prints the other Series A sheet, walks LEVERS. Walk LEVERS at a seed table and it paints
## "Valuation $0M" over the offer and negotiates a term that is not on the sheet.
static func levers() -> Array:
	return SEED_LEVERS if is_seed() else LEVERS


## The sheet this vc_id is sitting at: the seed offer if there is one, else the Series A
## sheet. Seed first because a seed offer and a Series A sheet cannot coexist for one fund
## in a legal run, and if they ever did the earlier rung is the one still unresolved.
static func _sheet_for(vc_id: String) -> TermSheet:
	var seed: TermSheet = VCPitchSystem.seed_sheet_for(vc_id)
	return seed if seed != null else VCPitchSystem.sheet_for(vc_id)


static func is_seed() -> bool:
	return _stage == PitchConstants.STAGE_SEED


static func _dil_step() -> int:
	return SeedConstants.DIL_STEP if is_seed() else PitchConstants.DIL_STEP


static func _dil_floor() -> int:
	return SeedConstants.DIL_MIN if is_seed() else PitchConstants.DIL_FLOOR


static func is_active() -> bool:
	return _active


## Run-boundary reset (SaveManager.reset_all_owners). The sitting statics are reset, never
## serialised: SaveManager.can_save() refuses while is_active(), so a table is closed at every
## save point. The SHEET persists (GameState.active_sheets, or GameState.seed_sheet at seed);
## what dies here is the negotiation in progress.
static func reset() -> void:
	_reset()


# ============================================================================
# Lifecycle
# ============================================================================

## Seat the player at the table for a live sheet. Seeds the working terms from the sheet's
## opening offer (+ leverage notch), patience from the pool, IDLE state. Returns view_state.
static func open(vc_id: String) -> Dictionary:
	_reset()
	var sheet: TermSheet = _sheet_for(vc_id)
	if sheet == null:
		return {}   # no live sheet — caller shouldn't have routed here
	_active = true
	_vc_id = vc_id
	_stage = String(sheet.stage)
	_terms = sheet.opening_terms.duplicate()
	if not is_seed() and _leverage_active():
		# Leverage improves the OPENING one notch. Series A only: there is exactly one seed
		# round per run, so a second seed sheet to hold against this one cannot exist.
		_terms["valuation_m"] = int(_terms.get("valuation_m", 0)) + PitchConstants.LEVERAGE_OPEN_NOTCH
	_patience = int(sheet.patience_pool)
	_patience_max = _patience
	_selected_lever = String(levers()[0])
	_e = clampi(_opening_conviction(sheet) + _domain_fit(), 0, 100)
	return view_state()


## Select a lever — pure presentation: no term, patience or eagerness moves; dial and caption
## go neutral for the new lever. Ignored once pushing is locked (final offer or walk-out).
static func select_lever(lever: String) -> Dictionary:
	if not _active or _state == PATIENCE_ZERO or _state == FUND_WALKED:
		return view_state()
	if lever in levers():
		_selected_lever = lever
		_state = LEVER_SELECTED
		_last_lever_acted = ""   # fresh intention → dial rests, caption previews
	return view_state()


## True when `lever` can still be pushed (live table, patience left, lever not locked, room
## to improve).
static func can_push(lever: String) -> bool:
	if not _active or _state == PATIENCE_ZERO or _state == FUND_WALKED or _patience <= 0:
		return false
	return lever in levers() and not _lever_locked(lever) and not _lever_at_best(lever)


## A row that is on the sheet but not open to negotiation. Today that is the seed board term:
## SeedRoundSystem.accept persists raise and dilution only, so a board push would spend
## patience and eagerness on a term that vanishes at signing. The row stays visible (the fund
## still asks for it); whether seed board seats become real is an open decision (docs/ACIK_ISLER/ACIK_KARARLAR.md).
static func _lever_locked(lever: String) -> bool:
	return is_seed() and lever == "board"


## Resolve the selected lever's push. Returns the SETTLED view_state (PUSH_SUCCESS /
## PUSH_FAILURE, or PATIENCE_ZERO / FUND_WALKED if this drained the last pip). The scene
## wraps this with the dial spin.
static func push() -> Dictionary:
	if not can_push(_selected_lever):
		return view_state()
	var lever: String = _selected_lever
	var passed: bool = SkillCheck.roll_against(odds_for(lever).chance)
	_push_counts[lever] = int(_push_counts.get(lever, 0)) + 1   # decay applies on EVERY attempt, won or lost
	_last_lever_acted = lever
	_last_push_passed = passed
	GameState.run_pushes_attempted += 1
	var care: int = E_CARE_LEVER_EXTRA if lever == _care_lever() else 0
	if passed:
		var before: String = _current_text(lever)
		_apply_push(lever, _terms)
		_last_move = _moved(lever, before)
		_won_counts[lever] = int(_won_counts.get(lever, 0)) + 1
		GameState.run_pushes_won += 1
		_e = clampi(_e - E_PUSH_WIN_COST - care, 0, 100)
		_state = PUSH_SUCCESS
		_line_key = _band_line_key()
	else:
		# The ask this push made: one step beyond everything already won on this lever.
		var ask_steps: int = int(_won_counts.get(lever, 0)) + 1
		_e = clampi(_e - E_PUSH_FAIL_BASE - E_PUSH_FAIL_PER_STEP * ask_steps - care, 0, 100)
		_patience -= 1
		if _patience <= 0:
			_patience = 0
			_on_patience_zero(lever)
		else:
			_state = PUSH_FAILURE
			_line_key = _band_line_key()
	return view_state()


## Patience is gone. Above the walk line the fund puts a final take-it-or-leave-it
## counter; below it the fund walks. THE SEED FUND NEVER WALKS (the room cannot reject and
## the refusal row is locked), so a seed table always ends in the final counter.
static func _on_patience_zero(asked_lever: String) -> void:
	if not is_seed() and _e < walk_threshold():
		_fund_walks()
		return
	_final_counter(asked_lever)
	_state = PATIENCE_ZERO
	_line_key = "SEED_INV_FINAL" if is_seed() else "TERM_INV_FINAL"


## The final counter: part of the way from the working terms toward the last ask.
static func _final_counter(lever: String) -> void:
	_final_move = ""
	var share: float = clampf(float(_e - walk_threshold()) / E_FINAL_SPAN, 0.0, 1.0)
	if share <= 0.0 or _lever_at_best(lever):
		return
	var before: String = _current_text(lever)
	match lever:
		"valuation":
			var gain: int = int(round(share * E_FINAL_MAX_SHARE * PitchConstants.VAL_STEP))
			_terms["valuation_m"] = int(_terms.get("valuation_m", 0)) + gain
		"raise":
			var gain_k: int = int(round(share * E_FINAL_MAX_SHARE * SeedConstants.RAISE_STEP / 1000.0))
			_terms["raise"] = mini(int(_terms.get("raise", 0)) + gain_k * 1000, SeedConstants.RAISE_MAX)
		"dilution":
			var drop: int = int(round(share * E_FINAL_MAX_SHARE * _dil_step()))
			_terms["dilution_pct"] = maxi(int(_terms.get("dilution_pct", 0)) - drop, _dil_floor())
		"board":
			if share >= E_FINAL_BOARD_SHARE:
				_apply_push("board", _terms)
	_final_move = _moved(lever, before)


## The fund leaves. The consequence is written NOW, not when the player clicks away: a sitting
## that could be abandoned between the walk-out and its write would hand the sheet back.
## Same closure as a player walk (sheet destroyed, fund closed for the run, other sheets
## survive) and it counts as a fund rejection (the same vc_rejections counter a failed
## meeting moves). Series A only: both callers (_on_patience_zero, show_other_offer) exclude
## a seed table.
static func _fund_walks() -> void:
	_fund_walked = true
	_state = FUND_WALKED
	_line_key = "TERM_INV_WALKOUT"
	VCPitchSystem.walk_table(_vc_id, VCPitchSystem.WALK_REASON_FUND)


# ============================================================================
# Show the other offer (Series A, once per table, real sheet only)
# ============================================================================

## True when the move is on offer at all: a Series A sitting and another live Series A sheet
## from a different fund. Whether it is still usable is can_show_other().
static func show_other_available() -> bool:
	return _active and not is_seed() and _other_live_vc() != ""


static func can_show_other() -> bool:
	return show_other_available() and not _other_shown \
		and _state != PATIENCE_ZERO and _state != FUND_WALKED


## Put the other sheet on the table. The fund's answer is computed from how much better the
## other sheet is on the lever THIS fund cares about, its eagerness, and the patience left.
static func show_other_offer() -> Dictionary:
	if not can_show_other():
		return view_state()
	_other_shown = true
	_other_vc_shown = _other_live_vc()
	_other_terms = VCPitchSystem.sheet_for(_other_vc_shown).opening_terms.duplicate()
	_last_lever_acted = ""        # the dial rests; this was not a push
	_last_move = ""
	_show_back = ""
	var care: String = _care_lever()
	var gap: float = _gap_steps(care, _other_terms)
	if gap >= SHOW_WALK_GAP and _e < walk_threshold():
		_show_outcome = SHOW_WALK
		_fund_walks()
		_line_key = "TERM_INV_OTHER_WALK"
		return view_state()
	var pull: float = float(_e + SHOW_PATIENCE_WEIGHT * _patience) - SHOW_GAP_COST * gap
	if gap <= 0.0 or pull < SHOW_CONDITION_MIN:
		_show_outcome = SHOW_HOLD
		_e = clampi(_e - SHOW_HOLD_E_COST, 0, 100)
		_line_key = "TERM_INV_OTHER_HOLD"
	elif pull >= SHOW_MATCH_MIN:
		_show_outcome = SHOW_MATCH
		var share: float = clampf(
			SHOW_MATCH_MIN_SHARE + (pull - SHOW_MATCH_MIN) / SHOW_MATCH_FULL_SPAN * (1.0 - SHOW_MATCH_MIN_SHARE),
			SHOW_MATCH_MIN_SHARE, 1.0)
		_close_gap(care, share)
		_e = clampi(_e - SHOW_MATCH_E_COST, 0, 100)
		_line_key = "TERM_INV_OTHER_MATCH"
	else:
		_show_outcome = SHOW_CONDITION
		_close_gap(care, 1.0)
		var back_lever: String = String(CLAWBACK_LEVER.get(_domain(), "dilution"))
		var before: String = _current_text(back_lever)
		_claw_back(back_lever)
		_show_back = _moved(back_lever, before)
		_e = clampi(_e - SHOW_MATCH_E_COST, 0, 100)
		_line_key = "TERM_INV_OTHER_CONDITION"
	_state = OTHER_SHOWN
	return view_state()


## How much better the other sheet is on `lever`, in push steps (> 0 = theirs is better).
static func _gap_steps(lever: String, other: Dictionary) -> float:
	match lever:
		"valuation":
			return float(int(other.get("valuation_m", 0)) - int(_terms.get("valuation_m", 0))) \
				/ float(PitchConstants.VAL_STEP)
		"dilution":
			return float(int(_terms.get("dilution_pct", 0)) - int(other.get("dilution_pct", 0))) \
				/ float(PitchConstants.DIL_STEP)
		"board":
			return float(_board_weight(_terms) - _board_weight(other))
	return 0.0


## Board terms as push steps: each seat is one step, a veto is one more.
static func _board_weight(terms: Dictionary) -> int:
	return int(terms.get("board_seats", 0)) + (1 if bool(terms.get("board_veto", false)) else 0)


## Move `lever` `share` of the way to the other sheet (at least one unit when there is a gap).
static func _close_gap(lever: String, share: float) -> void:
	var before: String = _current_text(lever)
	match lever:
		"valuation":
			var gap_m: int = int(_other_terms.get("valuation_m", 0)) - int(_terms.get("valuation_m", 0))
			if gap_m > 0:
				_terms["valuation_m"] = int(_terms.get("valuation_m", 0)) + maxi(1, int(round(gap_m * share)))
		"dilution":
			var gap_pp: int = int(_terms.get("dilution_pct", 0)) - int(_other_terms.get("dilution_pct", 0))
			if gap_pp > 0:
				_terms["dilution_pct"] = maxi(
					int(_terms.get("dilution_pct", 0)) - maxi(1, int(round(gap_pp * share))), _dil_floor())
		"board":
			var steps: int = maxi(1, int(round(_gap_steps("board", _other_terms) * share)))
			for i in steps:
				if _lever_at_best("board"):
					break
				_apply_push("board", _terms)
	_last_move = _moved(lever, before)


## The condition: one step back on another lever, the fund's way.
static func _claw_back(lever: String) -> void:
	match lever:
		"valuation":
			_terms["valuation_m"] = maxi(1, int(_terms.get("valuation_m", 0)) - PitchConstants.VAL_STEP)
		"dilution":
			_terms["dilution_pct"] = mini(
				int(_terms.get("dilution_pct", 0)) + PitchConstants.DIL_STEP, PitchConstants.SERIES_A_DIL_MAX)
		"board":
			var seats: int = int(_terms.get("board_seats", 0))
			if seats < SHOW_BOARD_SEAT_CAP:
				_terms["board_seats"] = seats + 1
			elif not bool(_terms.get("board_veto", false)):
				_terms["board_veto"] = true


# ============================================================================
# Eagerness reads
# ============================================================================

static func eagerness() -> int:
	return _e


## This fund's walk line — lower for a patient fund, higher for a short-fused one.
static func walk_threshold() -> int:
	return E_WALK_BASE - E_WALK_PER_PATIENCE * _patience_max


static func eagerness_band() -> String:
	if _e < walk_threshold():
		return BAND_RUNNING_OUT
	if _e < walk_threshold() + E_BAND_RELAXED_MARGIN:
		return BAND_TENSE
	return BAND_RELAXED


static func _band_line_key() -> String:
	var pool: Array
	match eagerness_band():
		BAND_RUNNING_OUT:
			return String(LINES_RUNNING_OUT.get(_vc_id, LINE_RUNNING_OUT_FALLBACK))
		BAND_TENSE:
			pool = LINES_TENSE
		_:
			pool = LINES_RELAXED
	var idx: int = _line_seq % pool.size()
	if String(pool[idx]) == _line_key:
		idx = (idx + 1) % pool.size()
	_line_seq += 1
	return String(pool[idx])


static func _domain() -> String:
	return String(InvestorRegistry.get_investor(_vc_id).get("domain", ""))


static func _care_lever() -> String:
	var lever: String = String(CARE_LEVER.get(_domain(), "valuation"))
	# The seed sheet has no valuation row: a valuation-minded fund watches the money there.
	if is_seed() and lever == "valuation":
		return "raise"
	return lever


## The meeting's conviction, as stamped on the sheet at grant; a fallback when unstamped.
static func _opening_conviction(sheet: TermSheet) -> int:
	if int(sheet.conviction) >= 0:
		return int(sheet.conviction)
	if is_seed():
		return int(E_FALLBACK_CONV_SEED.get(String(sheet.band), E_FALLBACK_CONV_SEED["harsh"]))
	return E_FALLBACK_CONV_SERIES_A


## How well the company fits what THIS fund invests on. Read-only seams, one lens per fund.
static func _domain_fit() -> int:
	var inv: Dictionary = InvestorRegistry.get_investor(_vc_id)
	var fit: int = 0
	match String(inv.get("domain", "")):
		"metrics":
			var ref: int = SeedConstants.CONV_MRR_REFERENCE if is_seed() else PitchConstants.CONV_MRR_REFERENCE
			fit += E_FIT_METRICS_MRR if GameState.mrr >= ref else -E_FIT_METRICS_MRR
			fit += E_FIT_METRICS_CHURN if GameState.run_customers_lost <= 0 else -E_FIT_METRICS_CHURN
		"team":
			fit += E_FIT_TEAM_ENGINEER if CharacterRegistry.count_developers() >= 1 else -E_FIT_TEAM_ENGINEER
			if CharacterRegistry.get_employees().size() >= E_FIT_TEAM_SIZE_MIN:
				fit += E_FIT_TEAM_SIZE
		"narrative":
			var floor_b: int = SeedConstants.CONV_BRAND_FLOOR if is_seed() else PitchConstants.CONV_BRAND_FLOOR
			fit += E_FIT_NARRATIVE_BRAND if GameState.brand >= floor_b else -E_FIT_NARRATIVE_BRAND
			if bool(inv.get("warm_intro", false)):
				fit += E_FIT_NARRATIVE_WARM
		"product":
			fit += E_FIT_PRODUCT_SHIPPED if bool(GameState.get_flag("mvp_shipped", false)) else -E_FIT_PRODUCT_SHIPPED
			fit += -E_FIT_PRODUCT_BUGS if ProductSystem.live_bug_count() > 0 else E_FIT_PRODUCT_BUGS
			var weakest: float = minf(float(GameState.get_flag("mvp_innovation", 0.0)), minf(
				float(GameState.get_flag("mvp_stability", 0.0)),
				float(GameState.get_flag("mvp_experience", 0.0))))
			if weakest >= E_FIT_PRODUCT_DIM_FLOOR:
				fit += E_FIT_PRODUCT_DIMS
	return clampi(fit, -E_FIT_MAX, E_FIT_MAX)


## Sign the current terms → VC seam (Series A: fires the Hard Win ending; seed: accepts the
## round). Ends the sitting.
static func sign() -> void:
	if not _active or _fund_walked:
		return
	var vc: String = _vc_id
	var terms: Dictionary = _terms.duplicate()
	var stage: String = _stage
	_reset()
	VCPitchSystem.sign_table(vc, terms, stage)


## Walk the table → VC seam (sheet destroyed, fund closed, others survive; the player's
## walk is not a rejection). Ends the sitting.
static func walk() -> void:
	if not _active:
		return
	# The fund already walked and the closure is already written: a second walk would count
	# a second rejection for one door. Treat it as leaving the room.
	if _fund_walked:
		leave()
		return
	# THE SECOND SAFETY behind the locked row: the button renders visible and disabled with
	# its reason, the way Frank's cheque renders REDDET · ZOR MOD, and this refuses even a
	# direct call. Walking away from the seed round is ZOR MOD (docs/ACIK_ISLER/ACIK_KARARLAR.md).
	if is_seed():
		push_error("[TermSheetTableSystem] walk() at a seed table — the refusal row is ZOR MOD")
		return
	var vc: String = _vc_id
	_reset()
	VCPitchSystem.walk_table(vc)


## Leave the room after the fund walked out. Nothing is written here — _fund_walks already
## did it; this only ends the sitting. A no-op on a live table (sign or walk decide those).
static func leave() -> void:
	if not _active or not _fund_walked:
		return
	_reset()


## THE INVERSION, and it is the whole shape of the seed table. At Series A the money falls
## out of valuation x dilution; at seed the money IS the lever and the valuation falls out
## of it (implied_post_money below).
static func money_raised() -> int:
	if is_seed():
		return int(_terms.get("raise", 0))
	return VCPitchSystem.raised_for(int(_terms.get("valuation_m", 0)), int(_terms.get("dilution_pct", 0)))


## The seed round's implied post-money: raise / dilution. A DERIVED CAPTION, never a lever —
## and the ruling that it cannot be pushed is enforced structurally rather than by a guard,
## because levers() has no row for it. 0 at Series A, where the valuation is a lever.
static func implied_post_money() -> int:
	var dil: int = int(_terms.get("dilution_pct", 0))
	if not is_seed() or dil <= 0:
		return 0
	return int(round(float(money_raised()) * 100.0 / float(dil)))


# ============================================================================
# Odds — skill-split + leverage + per-push decay
# ============================================================================

## Composed odds for a lever: SkillCheck.breakdown (base + skill + leverage) minus this lever's
## accumulated decay, floor-clamped. Returns {chance, split_text}.
static func odds_for(lever: String) -> Dictionary:
	# The only stage-dependent lines in the whole odds computation. Everything below —
	# SkillCheck.breakdown, the leverage units, the per-lever decay, the floor clamp and the
	# split text — is shared by both rungs.
	var skill_table: Dictionary = PitchConstants.SEED_LEVER_SKILL if is_seed() \
		else PitchConstants.LEVER_SKILL
	var diff_table: Dictionary = PitchConstants.SEED_LEVER_DIFF if is_seed() \
		else PitchConstants.LEVER_DIFF
	var skill: String = String(skill_table.get(lever, "charisma"))
	var diff: int = int(diff_table.get(lever, 1))
	var lev_units: int = PitchConstants.LEVERAGE_BONUS_UNITS if _leverage_active() else 0
	var bd: Dictionary = SkillCheck.breakdown(skill, diff, lev_units)
	var decay: float = int(_push_counts.get(lever, 0)) * PitchConstants.PUSH_DECAY
	var chance: float = clampf(
		float(bd.base) + float(bd.skill) + float(bd.bonus) - decay,
		PitchConstants.PUSH_ODDS_FLOOR, SkillCheck.MAX_CHANCE)
	return {"chance": chance, "split_text": _split_text(bd, lev_units > 0, decay)}


static func _split_text(bd: Dictionary, leverage: bool, decay: float) -> String:
	var s: String = TranslationServer.translate("TERM_SPLIT_BASE").format({"pct": Fmt.percent(_pct(bd.base), 0)})
	if float(bd.skill) > 0.0:
		s += TranslationServer.translate("TERM_SPLIT_SKILL").format({
			"pct": Fmt.percent(_pct(bd.skill), 0),
			"skill": FounderConstants.skill_label(bd.skill_name)})
	if leverage and float(bd.bonus) > 0.0:
		s += TranslationServer.translate("TERM_SPLIT_LEVERAGE").format({"pct": Fmt.percent(_pct(bd.bonus), 0)})
	if decay > 0.0:
		s += TranslationServer.translate("TERM_SPLIT_DECAY").format({"pct": Fmt.percent(_pct(decay), 0)})
	return s


# ============================================================================
# View state — the single dict _render() consumes (gap-free)
# ============================================================================

static func view_state() -> Dictionary:
	var inv: Dictionary = InvestorRegistry.get_investor(_vc_id)
	var other_vc: String = _other_live_vc()
	var lev_active: bool = other_vc != ""
	var other_name: String = InvestorRegistry.get_investor(other_vc).get("display_name", "") if lev_active else ""
	var box_text: String = ""
	if _other_shown:
		# The shown offer is the REAL other sheet, never a bluff: its numbers, from its own opening terms.
		box_text = TranslationServer.translate("TERM_OTHER_SHOWN_BOX").format({
			"investor": InvestorRegistry.get_investor(_other_vc_shown).get("display_name", ""),
			"terms": _terms_text(_other_terms)})
	elif lev_active:
		box_text = TranslationServer.translate("TERM_LEVERAGE_BOX").format({"investor": other_name})
	return {
		"state": _state,
		"display_name": inv.get("display_name", ""),
		"archetype_line": InvestorRegistry.archetype_line(_vc_id),
		"portrait_path": inv.get("portrait_path", ""),
		"patience": {"current": _patience, "max": _patience_max},
		"levers": _lever_views(),
		"selected_lever": _selected_lever,
		"dial": _dial_view(),
		"result_caption": _result_caption(),
		"leverage": {
			"active": lev_active or _other_shown,
			"other_vc_name": other_name,
			"box_text": box_text,
		},
		# The investor's own line after every move. It is the only window onto E.
		"investor_line": TranslationServer.translate(_line_key) if _line_key != "" else "",
		"eagerness_band": eagerness_band(),
		"final_offer": _state == PATIENCE_ZERO,
		"fund_walked": _fund_walked,
		# Show the other offer. Visible whenever the move exists at this table; enabled once, before the final.
		"show_other": {
			"visible": show_other_available() or _other_shown,
			"enabled": can_show_other(),
			"used": _other_shown,
			"outcome": _show_outcome,
		},
		"frank_line": _frank_line(lev_active, other_name),
		"money_raised": money_raised(),
		"footer": {
			"kasa_runway_text": _kasa_runway_text(),
			# EMPTY AT SEED. A "0/3 tables closed" counter at a table that cannot close one would
			# tell the player the opposite: the seed rung cannot reject.
			"counter_text": "" if is_seed() else TranslationServer.translate("TERM_TABLES_CLOSED").format({
				"closed": GameState.vc_rejections, "total": EndingsSystem.CASCADE_TABLES}),
		},
		"sign_enabled": _active and not _fund_walked,
		# After a walk-out the same row becomes "leave the room" (walk_mode) — the only exit.
		"walk_enabled": _active and (not is_seed() or _fund_walked),
		"walk_mode": "leave" if _fund_walked else "walk",
		# LOCKED-VISIBLE, not hidden: the row stays on screen and says why, which is the
		# grammar every other locked door in this game uses.
		"walk_lock": {
			"locked": is_seed() and not bool(GameState.get_flag(AngelRoundSystem.HARD_MODE_FLAG, false)),
			"reason_key": "SEED_WALK_LOCK",
		},
		# The seed table's derived readout. "" at Series A, where the valuation is a lever.
		"derived_caption": TranslationServer.translate("SEED_IMPLIED_POST").format(
			{"post": Fmt.money_exact(implied_post_money())}) if is_seed() else "",
	}


static func _lever_views() -> Array:
	var out: Array = []
	for lever in levers():
		out.append({
			"id": lever,
			"name_tr": _lever_name(lever),
			"current_text": _current_text(lever),
			"ghost_text": _ghost_text(lever),
			# The odds line is where the row explains itself, so a locked row says why
			# instead of quoting a chance nobody can roll.
			"odds": {"chance": 0.0, "split_text": TranslationServer.translate("SEED_BOARD_LOCKED")} \
				if _lever_locked(lever) else odds_for(lever),
			"push_enabled": can_push(lever),
		})
	return out


static func _dial_view() -> Dictionary:
	# chance = the selected lever's current odds (arc). result colours the resting needle after a
	# push (persists until the next push or a fresh lever selection). The scene animates the spin
	# only on the push() return, since IT initiates the roll.
	var chance: float = 0.0 if _lever_locked(_selected_lever) else float(odds_for(_selected_lever).chance)
	var result: String = ""
	if _last_lever_acted != "":
		result = "success" if _last_push_passed else "failure"
	return {"chance": chance, "result": result}


static func _result_caption() -> String:
	match _state:
		PUSH_SUCCESS:
			return TranslationServer.translate("TERM_RESULT_ACCEPTED").format({"move": _last_move})
		PUSH_FAILURE:
			return TranslationServer.translate("TERM_RESULT_REFUSED").format(
				{"value": _current_text(_last_lever_acted)})
		PATIENCE_ZERO:
			# The seed row has no walk, so its final caption must not offer one.
			if _final_move != "":
				return TranslationServer.translate(
					"SEED_RESULT_FINAL_MOVE" if is_seed() else "TERM_RESULT_FINAL_MOVE").format({"move": _final_move})
			return TranslationServer.translate("SEED_RESULT_FINAL" if is_seed() else "TERM_RESULT_FINAL")
		FUND_WALKED:
			return TranslationServer.translate("TERM_RESULT_WALKED")
		OTHER_SHOWN:
			# Only a MATCH or a CONDITION moves _last_move; only a CONDITION sets _show_back.
			if _last_move == "":
				return TranslationServer.translate("TERM_RESULT_OTHER_HELD")
			if _show_back != "":
				return TranslationServer.translate("TERM_RESULT_OTHER_TRADED").format(
					{"move": _last_move, "back": _show_back})
			return TranslationServer.translate("TERM_RESULT_OTHER_MOVED").format({"move": _last_move})
		_:
			if _lever_at_best(_selected_lever):
				return TranslationServer.translate("TERM_LEVER_MAXED").format({
					"lever": _lever_name(_selected_lever), "value": _current_text(_selected_lever)})
			return TranslationServer.translate("TERM_LEVER_ODDS").format({
				"lever": _lever_name(_selected_lever),
				"from": _current_text(_selected_lever),
				"to": _ghost_text(_selected_lever),
				"pct": Fmt.percent(_pct(odds_for(_selected_lever).chance), 0)})


static func _frank_line(lev_active: bool, other_name: String) -> String:
	# THE SEED TABLE HAS ITS OWN MENTOR SET, and it is not a stylistic preference: the
	# Series A lines below talk about walking to another table (TERM_FRANK_OTHER_TABLE)
	# and about having none left to walk to (TERM_FRANK_NO_TABLE). At seed the refusal row
	# is locked and there is exactly one round, so both sentences would be false — and a
	# mentor describing a door the player cannot use is worse than a silent one.
	if is_seed():
		return _seed_frank_line()
	match _state:
		PUSH_SUCCESS:
			return TranslationServer.translate("TERM_FRANK_WON").format(
				{"lever": _lever_name(_last_lever_acted)})
		PUSH_FAILURE:
			if _patience > 1:
				return TranslationServer.translate("TERM_FRANK_RESISTED").format(
					{"lever": _lever_name(_last_lever_acted)})
		PATIENCE_ZERO, FUND_WALKED:
			if lev_active:
				return TranslationServer.translate("TERM_FRANK_OTHER_TABLE").format({"investor": other_name})
			return TranslationServer.translate("TERM_FRANK_NO_TABLE")
		IDLE:
			return TranslationServer.translate("TERM_FRANK_OPENING")
	# OTHER_SHOWN lands here too: the shown offer is the investor's moment (TERM_INV_OTHER_*)
	# and Frank only counts the moves left. A Frank line for that move is his corpus, an open
	# decision (docs/ACIK_ISLER/ACIK_KARARLAR.md), so none is invented here.
	if _patience <= 1:
		return TranslationServer.translate("TERM_FRANK_LAST_MOVE")
	return TranslationServer.translate("TERM_FRANK_NEXT_MOVE")


## The seed room's mentor: patience, the move in front of you, and the one thing he can
## honestly say at the end — that this round gets signed.
static func _seed_frank_line() -> String:
	match _state:
		PUSH_SUCCESS:
			return TranslationServer.translate("SEED_FRANK_WON").format(
				{"lever": _lever_name(_last_lever_acted)})
		PUSH_FAILURE:
			if _patience > 1:
				return TranslationServer.translate("SEED_FRANK_RESISTED").format(
					{"lever": _lever_name(_last_lever_acted)})
		PATIENCE_ZERO:
			return TranslationServer.translate("SEED_FRANK_FINAL")
		IDLE:
			return TranslationServer.translate("SEED_FRANK_OPENING")
	if _patience <= 1:
		return TranslationServer.translate("SEED_FRANK_LAST_MOVE")
	return TranslationServer.translate("SEED_FRANK_NEXT_MOVE")


# ============================================================================
# Term math
# ============================================================================

## One won step on `lever`, applied to `terms` (the working terms, or a copy for the ghost).
static func _apply_push(lever: String, terms: Dictionary) -> void:
	match lever:
		"valuation":
			terms["valuation_m"] = int(terms.get("valuation_m", 0)) + PitchConstants.VAL_STEP
		"raise":
			# Clamped to the TOP of the band, not left open: a seed raise has a ceiling the way
			# a Series A valuation does not, because the fund sized the round before the meeting.
			terms["raise"] = mini(
				int(terms.get("raise", 0)) + SeedConstants.RAISE_STEP, SeedConstants.RAISE_MAX)
		"dilution":
			terms["dilution_pct"] = maxi(
				int(terms.get("dilution_pct", 0)) - _dil_step(), _dil_floor())
		"board":
			if bool(terms.get("board_veto", false)):
				terms["board_veto"] = false                                   # drop veto first
			else:
				terms["board_seats"] = maxi(int(terms.get("board_seats", 0)) - 1, 0)  # then the seat


static func _lever_at_best(lever: String) -> bool:
	match lever:
		"raise":
			return int(_terms.get("raise", 0)) >= SeedConstants.RAISE_MAX
		"dilution":
			return int(_terms.get("dilution_pct", 0)) <= _dil_floor()
		"board":
			return not bool(_terms.get("board_veto", false)) and int(_terms.get("board_seats", 0)) <= 0
		_:
			return false   # valuation has no ceiling


static func _current_text(lever: String) -> String:
	return _text_of(lever, _terms)


## "$18M → $22M", or "" when `lever` has not moved from `before`.
static func _moved(lever: String, before: String) -> String:
	var after: String = _current_text(lever)
	return "%s → %s" % [before, after] if after != before else ""


## One lever's value as the table prints it, for any terms dict (the working terms, or the
## other sheet the player shows at the table).
static func _text_of(lever: String, terms: Dictionary) -> String:
	match lever:
		"valuation":
			return "$%dM" % int(terms.get("valuation_m", 0))
		"raise":
			# EXACT, not abbreviated: the player is moving this in $10K steps and "$0.1M" would
			# hide the whole negotiation.
			return Fmt.money_exact(int(terms.get("raise", 0)))
		"dilution":
			return Fmt.percent(int(terms.get("dilution_pct", 0)), 0)
		"board":
			return _board_text(int(terms.get("board_seats", 0)), bool(terms.get("board_veto", false)))
	return ""


## A Series A sheet's three terms in one line ("$22M · %18 · temiz").
static func _terms_text(terms: Dictionary) -> String:
	var parts: Array = []
	for lever in LEVERS:
		parts.append(_text_of(lever, terms))
	return " · ".join(parts)


## The value one more won push would reach ("" when the lever is already at its best).
static func _ghost_text(lever: String) -> String:
	if _lever_at_best(lever):
		return ""
	var next: Dictionary = _terms.duplicate()
	_apply_push(lever, next)
	return _text_of(lever, next)


static func _board_text(seats: int, veto: bool) -> String:
	if seats <= 0 and not veto:
		return TranslationServer.translate("TERM_BOARD_CLEAN")
	# English needs a singular form; Turkish does not inflect after a numeral, so both of
	# its rows read "{n} koltuk". Two rows, not a plural engine.
	var key: String = "TERM_BOARD_SEAT_ONE" if seats == 1 else "TERM_BOARD_SEATS"
	var s: String = TranslationServer.translate(key).format({"n": seats})
	if veto:
		s += TranslationServer.translate("TERM_BOARD_VETO")
	return s


static func _lever_name(lever: String) -> String:
	match lever:
		"valuation": return TranslationServer.translate("FIN_VALUATION")
		# EXPLICIT, and it has to be: the default arm below returns the BOARD label, so a
		# raise row without its own case would render "Board" on row one.
		"raise": return TranslationServer.translate("SEED_LEVER_RAISE")
		"dilution": return TranslationServer.translate("FIN_EQUITY")
		_: return TranslationServer.translate("TERM_LEVER_BOARD")


static func _kasa_runway_text() -> String:
	# GROSS runway in DAYS — deliberate table lens (VC side ignores revenue; the player
	# shell shows NET months). Floored at 0 like VCPitchSystem._gross_runway_months: a
	# company in the red has no runway left, not a negative one.
	var days: int = maxi(0, int(floor(float(GameState.cash) / float(maxi(GameState.daily_burn, 1)))))
	return TranslationServer.translate("TERM_CASH_RUNWAY").format({
		"cash": UiTokens.format_money(GameState.cash), "days": days})


# ============================================================================
# Leverage helpers
# ============================================================================

static func _leverage_active() -> bool:
	var sheet: TermSheet = VCPitchSystem.sheet_for(_vc_id)
	return sheet != null and sheet.is_leverage_active(GameState.active_sheets)


static func _other_live_vc() -> String:
	for sheet in GameState.active_sheets:
		if sheet is TermSheet and sheet.vc_id != _vc_id:
			return sheet.vc_id
	return ""


# ============================================================================
# Utility
# ============================================================================

static func _pct(f: float) -> int:
	return int(round(f * 100.0))


static func _reset() -> void:
	_active = false
	_vc_id = ""
	_terms = {}
	_push_counts = {}
	_patience = 0
	_patience_max = 0
	_selected_lever = "valuation"
	_state = IDLE
	_last_push_passed = false
	_last_lever_acted = ""
	_last_move = ""
	_stage = PitchConstants.STAGE_SERIES_A
	_e = 0
	_won_counts = {}
	_line_key = ""
	_line_seq = 0
	_final_move = ""
	_fund_walked = false
	_other_shown = false
	_show_outcome = ""
	_show_back = ""
	_other_terms = {}
	_other_vc_shown = ""
