class_name VCPitchSystem
extends RefCounted

# VC Pitch engine. Static, pure-logic (PhaseGate/Endings
# pattern). Drives the MeetingScene as a humble view: builds a view_state, emits
# EventBus.meeting_scene_requested; main.gd routes the scene's choice_selected back into
# advance(), which returns the next view_state or {done:true} once the outcome is written.
#
# TWO state homes:
#   * Persistent/serialized → GameState (vc_states, active_sheets, seed_sheet, pending_meeting, prep).
#   * Meeting-LOCAL (conviction, beat, intel) → the static vars below, NEVER serialized
#     (single sitting, no mid-meeting save).
#
# Reuses: SkillCheck.resolve (odds/bands), InvestorRegistry (static roster), PitchConstants
# (global knobs), ProductSystem capacity flag (prep cost). Writes series_a_closed /
# vc_rejections, which EndingsSystem reads (fields, not systems).
#
# NOTE: several Beat-3 domain-interrogation items read WORKING PROXIES where no dedicated
# field exists yet (churn spike, MRR concentration, rival lead). Each is marked
# `# WORKING PROXY` for Erdem's review; swap to real signals when those systems land.

## The meeting-day card, named here so cancel_meeting and on_pivot can pull a queued prompt.
const MEETING_CARD := "funding.meeting_day"
## walk_table's reason when the FUND leaves the table (patience-zero walk-out, or the walk that
## answers a shown rival offer). Distinct from the player's own "declined" on purpose: the
## fund is closed and a rejection is counted, but the player did not refuse the round, so
## EndingsSystem.road_over (an open decision in docs/ACIK_ISLER/ACIK_KARARLAR.md) does not count it.
const WALK_REASON_FUND := "fund_walked"
## The funds that have their own cold-exit Frank line; VC_FRANK_COLD_<ID> in the CSV.
const COLD_EXIT_FUNDS := ["anchor", "nexus", "bosphorus", "meridian"]

# --- Meeting-local state (never serialized) ---
static var _active: bool = false
static var _vc_id: String = ""
static var _conviction: int = 0
static var _cap: int = 100
static var _beat: int = 0            # 1..5 (5 = the result view)
static var _intel: bool = false      # Beat-1 success revealed the tell
static var _prep_focus: String = ""  # "" | "rakamlar" | "hikaye" | "prova"
static var _reentry: bool = false    # this meeting is a callback re-entry
static var _sorgu: Dictionary = {}   # {key, vc_line, mono} chosen weak point (or clean)
static var _meeting_day_mrr: int = 0 # snapshot for callback "MRR +20%"
static var _cold_exit_key: String = ""    # the Frank line this sitting's rejection shows (picked once)
# WHICH RUNG THIS SITTING IS. Meeting-local like everything else in this block, and for the
# same reason: at begin_meeting there is no sheet to read it off — the sheet is what the
# meeting PRODUCES. The TABLE reads its stage off TermSheet.stage instead, because the seed
# offer never expires and can be opened days later. reset() must clear it: walk_table reads
# it between sittings, and a leaked seed stage would make it refuse a Series A walk.
static var _stage: String = PitchConstants.STAGE_SERIES_A


# ============================================================================
# Public: meeting lifecycle (called by main.gd via the MeetingScene signals)
# ============================================================================

## The uniform name SaveManager.can_save() asks every sitting-scoped system.
static func is_active() -> bool:
	return _active


## The same read, under the name main.gd's meeting relay and the debug harnesses call.
static func is_meeting_active() -> bool:
	return _active


static func begin_meeting(vc_id: String, stage: String = PitchConstants.STAGE_SERIES_A) -> void:
	if not GameState.run_active:          # no meeting behind a terminal
		return
	var inv: Dictionary = InvestorRegistry.get_investor(vc_id)
	if inv.is_empty() or inv.get("locked", false):
		return
	_stage = stage
	# THE SEED ROOM SKIPS THE CEREMONY, and that is a design statement rather than a saving.
	# The Series A hunt makes the founder book three days ahead and spend a prep focus; the
	# seed room is the fast one, a bet on a person. So no pending_meeting to consume and no
	# prep to spend, which also keeps pending_meeting a Series-A-only field and leaves
	# funding.meeting_day and every seam that reads a booked meeting untouched by this rung.
	# ONE CALLBACK PER VC. `reentry_bonus` is only armed once the condition is met, so the
	# status is read as well: any sitting with a fund that already gave a callback is the
	# re-entry, and a second lukewarm room ends in a rejection rather than a second callback
	# that overwrites the first condition.
	var series_a: bool = _stage == PitchConstants.STAGE_SERIES_A
	_reentry = series_a and (bool(_vc(vc_id).get("reentry_bonus", false)) \
		or String(_vc(vc_id).get("status", "")) == "callback")
	if series_a:
		GameState.pending_meeting.clear()
	_active = true
	_vc_id = vc_id
	_prep_focus = _consume_prep(vc_id) if series_a else ""
	_cap = 100
	_intel = false
	_beat = 1
	_sorgu = {}
	_meeting_day_mrr = GameState.mrr
	var seed_data: Dictionary = initial_conviction(vc_id)
	_conviction = int(seed_data.value)
	# A cancelled or moved meeting costs this fund's NEXT meeting, and this is it.
	if series_a:
		_vc(vc_id).erase("move_penalty")
	EventBus.meeting_scene_requested.emit(_beat1_view_state(seed_data.why))


static func advance(choice_id: String) -> Dictionary:
	if not _active:
		return {"done": true}
	match _beat:
		1: return _resolve_beat1(choice_id)
		2: return _resolve_beat2(choice_id)
		3: return _resolve_beat3(choice_id)
		4: return _resolve_beat4(choice_id)
		_: return _finish()          # beat 5 result close


static func withdraw() -> void:
	# Available only before the first check (Beat 1). Meeting consumed,
	# VC open, no rejection. run_pitches NOT incremented (no completed pitch).
	if not _active:
		return
	GameState.pending_meeting.clear()
	reset()


# ============================================================================
# Conviction seeding — pure, GameState + registry only
# ============================================================================

## The room's starting temperature, and WHICH ROOM decides how it is read.
##
## The two profiles are the whole difference between the rungs: a Series A investor is
## auditing a business, so revenue and brand dominate; a seed investor is buying a person and
## a thesis, so the founder does. Same scene, same beats, same dial - a different set of
## things that move it.
static func initial_conviction(vc_id: String) -> Dictionary:
	if _stage == PitchConstants.STAGE_SEED:
		return _conviction_seed(vc_id)
	return _conviction_series_a(vc_id)


static func _conviction_series_a(vc_id: String) -> Dictionary:
	var inv: Dictionary = InvestorRegistry.get_investor(vc_id)
	var why: Array = []   # [{d, l}]: every term that moves the room, with its reason line

	# MRR vs traction reference (scaled up to +MAX).
	var mrr_ratio: float = clampf(float(GameState.mrr) / float(PitchConstants.CONV_MRR_REFERENCE), 0.0, 1.5)
	var mrr_delta: int = int(round((mrr_ratio - 0.5) * PitchConstants.CONV_MRR_MAX_BONUS))
	why.append({"d": mrr_delta, "l": _t("VC_WHY_MRR_STRONG" if mrr_delta >= 0 else "VC_WHY_MRR_WEAK")})

	# Brand distance to floor.
	var brand_delta: int = clampi(int(round((GameState.brand - PitchConstants.CONV_BRAND_FLOOR) * 0.4)), -PitchConstants.CONV_BRAND_MAX, PitchConstants.CONV_BRAND_MAX)
	why.append({"d": brand_delta, "l": _t("VC_WHY_BRAND_SOLID" if brand_delta >= 0 else "VC_WHY_BRAND_LOW")})

	# Runway health.
	if GameState.shutter_days_left >= 0:
		why.append({"d": PitchConstants.CONV_SHUTTER_PENALTY, "l": _t("VC_WHY_SHUTTER")})
	elif _gross_runway_months() < 1.0:
		why.append({"d": PitchConstants.CONV_THIN_RUNWAY_PENALTY, "l": _t("VC_WHY_RUNWAY_THIN")})

	if GameState.unmanaged_major_scandal:
		why.append({"d": PitchConstants.CONV_SCANDAL_PENALTY, "l": _t("VC_WHY_SCANDAL")})
	if not GameState.active_sheets.is_empty():
		why.append({"d": PitchConstants.CONV_LEVERAGE_BONUS, "l": _t("VC_WHY_LEVERAGE")})
	if inv.get("warm_intro", false):
		why.append({"d": PitchConstants.CONV_WARM_INTRO_BONUS, "l": _t("VC_WHY_WARM_INTRO")})
	if inv.get("domain", "") == "product" and GameState.get_flag("mvp_shipped", false):
		why.append({"d": PitchConstants.CONV_DIMENSION_MATCH_BONUS, "l": _t("VC_WHY_DOMAIN_MATCH")})
	if _vc(vc_id).get("reentry_bonus", false):
		why.append({"d": PitchConstants.CONV_CALLBACK_BONUS, "l": _t("VC_WHY_CALLBACK")})
	# SEEDED YOU (ch. 09 section 6). The fund that led the seed walks in already believing, and
	# the warmth carries its own reason line so it shows in the top-three breakdown - a warmth
	# the player cannot see is a number, not a relationship.
	if GameState.seed_lead != "" and GameState.seed_lead == vc_id:
		why.append({"d": SeedConstants.SEED_LEAD_WARMTH_BONUS, "l": _t("VC_WHY_SEED_LEAD")})
	# The founder moved or cancelled a meeting with this fund. Small, and it has its own
	# reason line so the player can see where the points went.
	var moved: int = int(_vc(vc_id).get("move_penalty", 0))
	if moved > 0:
		why.append({"d": -moved, "l": _t("VC_WHY_MOVED")})

	return _finish_conviction(PitchConstants.CONV_BASE, why)


## The seed room. Reweighted toward the founder and the insight, away from hard metrics - and
## note what is NOT here: no leverage bonus (there is no second seed table to hold against
## this one), no callback bonus (the rung has exactly one meeting), and no Series A yardstick.
static func _conviction_seed(vc_id: String) -> Dictionary:
	var inv: Dictionary = InvestorRegistry.get_investor(vc_id)
	var why: Array = []

	# The founder IS the asset at this stage - the single largest term in the room.
	var charisma: int = GameState.get_founder_skill(SeedConstants.CONV_FOUNDER_SKILL)
	var founder_delta: int = int(round(float(charisma) / 10.0 * SeedConstants.CONV_FOUNDER_MAX))
	why.append({"d": founder_delta, "l": _t("VC_WHY_FOUNDER_STRONG" if founder_delta >= 9 else "VC_WHY_FOUNDER_WEAK")})

	# Revenue still speaks, quietly, and against the SEED bar rather than the Series A one:
	# the question here is "has anyone paid you yet", not "are you a Series A company".
	var mrr_ratio: float = clampf(
		float(GameState.mrr) / float(SeedConstants.CONV_MRR_REFERENCE), 0.0, 1.5)
	var mrr_delta: int = int(round((mrr_ratio - 0.5) * SeedConstants.CONV_MRR_MAX_BONUS))
	why.append({"d": mrr_delta, "l": _t("VC_WHY_MRR_STRONG" if mrr_delta >= 0 else "VC_WHY_MRR_WEAK")})

	var brand_delta: int = clampi(
		int(round((GameState.brand - SeedConstants.CONV_BRAND_FLOOR) * 0.3)),
		-SeedConstants.CONV_BRAND_MAX, SeedConstants.CONV_BRAND_MAX)
	why.append({"d": brand_delta, "l": _t("VC_WHY_BRAND_SOLID" if brand_delta >= 0 else "VC_WHY_BRAND_LOW")})

	# A shipped product is the thing the story can point at.
	if GameState.get_flag("mvp_shipped", false):
		why.append({"d": SeedConstants.CONV_VISION_BONUS, "l": _t("VC_WHY_SHIPPED")})
	if String(inv.get("domain", "")) == "narrative":
		why.append({"d": SeedConstants.CONV_NARRATIVE_DOMAIN_BONUS, "l": _t("VC_WHY_DOMAIN_MATCH")})
	if bool(inv.get("warm_intro", false)):
		why.append({"d": SeedConstants.CONV_WARM_INTRO_BONUS, "l": _t("VC_WHY_WARM_INTRO")})

	if GameState.shutter_days_left >= 0:
		why.append({"d": SeedConstants.CONV_SHUTTER_PENALTY, "l": _t("VC_WHY_SHUTTER")})
	elif _gross_runway_months() < 1.0:
		why.append({"d": SeedConstants.CONV_THIN_RUNWAY_PENALTY, "l": _t("VC_WHY_RUNWAY_THIN")})
	# Character is the one thing a seed investor cannot diligence away, so this term is the
	# same size it is at Series A.
	if GameState.unmanaged_major_scandal:
		why.append({"d": SeedConstants.CONV_SCANDAL_PENALTY, "l": _t("VC_WHY_SCANDAL")})

	return _finish_conviction(SeedConstants.CONV_BASE, why)


## The shared tail: the value (base + every reason's delta, clamped) and the top-3 reasons by
## absolute delta that the Beat-1 monologue shows.
static func _finish_conviction(base: int, why: Array) -> Dictionary:
	var v: int = base
	for w in why:
		v += int(w.d)
	why.sort_custom(func(a, b): return absi(a.d) > absi(b.d))
	var why_lines: Array = []
	for i in mini(3, why.size()):
		why_lines.append(why[i].l)
	return {"value": clampi(v, 0, 100), "why": why_lines}


# ============================================================================
# Beat resolution
# ============================================================================

static func _resolve_beat1(_choice_id: String) -> Dictionary:
	# Odayı Oku — perception. Success reveals the tell (Beat 2 marks the favored angle).
	var chk: Dictionary = SkillCheck.resolve(PitchConstants.BEAT1_SKILL, PitchConstants.BEAT1_DIFF, 0)
	if chk.passed:
		_intel = true
	_beat = 2
	return {"done": false, "view_state": _beat2_view_state(chk)}


static func _resolve_beat2(choice_id: String) -> Dictionary:
	# Anlatı — angle check; conviction moves by margin.
	var angle: String = choice_id.trim_prefix("b2_")
	var diff: int = _angle_diff(angle)
	var bonus: int = _beat2_bonus(angle)
	var chk: Dictionary = SkillCheck.resolve(_angle_skill(angle), diff, bonus)
	if chk.passed:
		var span: int = PitchConstants.BEAT2_SUCCESS_MAX - PitchConstants.BEAT2_SUCCESS_MIN
		_conviction += PitchConstants.BEAT2_SUCCESS_MIN + int(round(clampf(chk.margin / 0.4, 0.0, 1.0) * span))
	else:
		_conviction += PitchConstants.BEAT2_FAIL
	_conviction = clampi(_conviction, 0, 100)
	_sorgu = _pick_sorgu_target()
	_beat = 3
	return {"done": false, "view_state": _beat3_view_state(chk)}


static func _resolve_beat3(choice_id: String) -> Dictionary:
	# Sorgu — posture check. Geçiştir caps the room at 65.
	var posture: String = choice_id.trim_prefix("b3_")
	var chk: Dictionary = SkillCheck.resolve(PitchConstants.BEAT3_SKILL, _beat3_diff(posture), _beat3_bonus(posture))
	var s: int = 0
	var f: int = 0
	match posture:
		"durust": s = PitchConstants.DURUST_SUCCESS; f = PitchConstants.DURUST_FAIL
		"spin": s = PitchConstants.SPIN_SUCCESS; f = PitchConstants.SPIN_FAIL
		_: s = PitchConstants.GECISTIR_SUCCESS; f = PitchConstants.GECISTIR_FAIL; _cap = PitchConstants.GECISTIR_CAP
	_conviction = clampi(_conviction + (s if chk.passed else f), 0, 100)
	_beat = 4
	return {"done": false, "view_state": _beat4_view_state()}


static func _resolve_beat4(choice_id: String) -> Dictionary:
	var zone_val: int = mini(_conviction, _cap)
	# THE SEED ROOM CANNOT SAY NO (the guaranteed-rung ruling, docs/ACIK_ISLER/ACIK_KARARLAR.md).
	# Conviction still decides everything - it decides WHAT THE TERMS ARE rather than whether
	# there are any, so a floored room still ends with a sheet, just a tight one.
	# Nothing here reaches _reject(), _set_callback() or the Ilık gamble: no rejection means
	# no cascade point, and one meeting per run means no callback to come back to.
	if _stage == PitchConstants.STAGE_SEED:
		var band: String = SeedConstants.band_for(zone_val)
		_grant_seed_sheet(band)
		_beat = 5
		return {"done": false, "view_state": _result_view_state("seed_" + band)}
	if zone_val >= PitchConstants.WON_MIN:
		# Kazanıldı — ack closes.
		_grant_sheet()
		return _finish()
	if zone_val < PitchConstants.ILIK_MIN:
		# Soğuk — RET closes.
		_reject()
		return _finish()
	# Ilık fork.
	match choice_id:
		"b4_callback":
			_set_callback()
			_beat = 5
			return {"done": false, "view_state": _result_view_state("callback")}
		"b4_zorla":
			var chk: Dictionary = SkillCheck.resolve(PitchConstants.BEAT4_PUSH_SKILL, PitchConstants.MASAYI_ZORLA_DIFF, 0)
			if chk.passed:
				_grant_sheet()
				_beat = 5
				return {"done": false, "view_state": _result_view_state("zorla_win")}
			_reject()
			_beat = 5
			return {"done": false, "view_state": _result_view_state("zorla_ret")}
		_:
			# reentry "no callback" path → accept RET.
			_reject()
			_beat = 5
			return {"done": false, "view_state": _result_view_state("ret")}


static func _finish() -> Dictionary:
	GameState.run_pitches += 1
	reset()
	return {"done": true}


# ============================================================================
# Outcome write-through
# ============================================================================

## The seed offer. Deliberately NOT _grant_sheet: it touches none of the Series A economy.
##
## No run_sheets_won (that counter feeds the newspaper line about Series A tables), no
## active_sheets (see the note on GameState.seed_sheet), no MAX_SHEETS, no pending_sheet
## queue, and no vc_states status change: the fund that seeds you must still be approachable
## at Series A, warmer.
static func _grant_seed_sheet(band: String) -> void:
	GameState.seed_sheet = SeedRoundSystem.make_seed_sheet(_vc_id, band, GameState.day)
	# The room's temperature rides on the sheet into the table, where it sets the opening eagerness.
	GameState.seed_sheet.conviction = mini(_conviction, _cap)
	EventBus.seed_sheet_granted.emit(_vc_id)


static func _grant_sheet() -> void:
	GameState.run_sheets_won += 1
	GameState.vc_last_meeting_rejected = false
	# Stamped on the fund's state rather than handed to _make_sheet, because a delayed sheet
	# is built days later by _deliver_pending_sheet, long after the room closed.
	_vc(_vc_id).sheet_conviction = mini(_conviction, _cap)
	if GameState.active_sheets.size() < PitchConstants.MAX_SHEETS:
		GameState.active_sheets.append(_make_sheet(_vc_id, GameState.day))
		_vc(_vc_id).status = "offered"
		EventBus.sheet_granted.emit(_vc_id)
		# Frank v6 surface 24 (the offer e-mail card) is deliberately not raised here: open
		# decision D12 (docs/ACIK_ISLER/ACIK_KARARLAR.md).
	else:
		# Delayed delivery; validity starts when a slot frees.
		var st: Dictionary = _vc(_vc_id)
		st.pending_sheet = true
		st.status = "pending_sheet"


static func _make_sheet(vc_id: String, granted_day: int) -> TermSheet:
	var inv: Dictionary = InvestorRegistry.get_investor(vc_id)
	var sheet := TermSheet.new()
	sheet.vc_id = vc_id
	sheet.granted_day = granted_day
	# WEEKDAYS on the real calendar, not calendar days.
	sheet.expires_day = GameState.add_business_days(granted_day, PitchConstants.SHEET_VALIDITY_BUSINESS_DAYS)
	sheet.term_bands = inv.get("term_bands", {}).duplicate()
	sheet.patience_pool = int(inv.get("patience_pool", 0))
	# The meeting's closing conviction, if one was stamped (-1 = none; the table falls back).
	sheet.conviction = int(GameState.vc_states.get(vc_id, {}).get("sheet_conviction", -1))
	# THE NUMBERS ARE PRICED, NOT COPIED: the opening terms read this company's revenue and
	# growth. The four funds keep their personalities - their angle weights, their patience,
	# their domains, and their board position.
	sheet.opening_terms = _derive_series_a_terms(inv)
	return sheet


## valuation = ARR x a multiple set by how fast the company is actually growing, nudged by
## the fund's own archetype word; dilution positioned inside 15-25 % the same way.
##
## The growth band reads GameState.get_mom_growth_avg_pct - the same rolling average the
## seed expectation and the buyout multiple read. One answer to "is this company growing",
## three consumers. Board seat and veto still come from the registry: that is the archetype
## saying what kind of investor it is, which no amount of revenue changes.
static func _derive_series_a_terms(inv: Dictionary) -> Dictionary:
	var bands: Dictionary = inv.get("term_bands", {})
	var growth: int = GameState.get_mom_growth_avg_pct(PitchConstants.ARR_WINDOW_MONTHS)
	var band_key: String = "low"
	if growth != GameState.GROWTH_AVG_UNKNOWN:
		if growth >= PitchConstants.ARR_GROWTH_HIGH_PCT:
			band_key = "high"
		elif growth >= PitchConstants.ARR_GROWTH_MID_PCT:
			band_key = "mid"
	var multiple: int = int(PitchConstants.ARR_MULTIPLE.get(band_key, 8))
	var arch_pct: int = int(PitchConstants.SERIES_A_VAL_ARCH_PCT.get(
		String(bands.get("valuation", "mid")), 0))
	var arr: float = float(GameState.mrr) * 12.0
	var valuation_m: int = maxi(1, int(round(
		arr * float(multiple) / 1_000_000.0 * float(100 + arch_pct) / 100.0)))
	var dilution: int = clampi(
		int(PitchConstants.SERIES_A_DIL_BY_ARCH.get(String(bands.get("dilution", "mid")), 18)),
		PitchConstants.SERIES_A_DIL_MIN, PitchConstants.SERIES_A_DIL_MAX)
	var board: Dictionary = inv.get("opening_terms", {})
	return {
		"valuation_m": valuation_m,
		"dilution_pct": dilution,
		"board_seats": int(board.get("board_seats", 0)),
		"board_veto": bool(board.get("board_veto", false)),
	}


static func _set_callback() -> void:
	GameState.vc_last_meeting_rejected = false
	var st: Dictionary = _vc(_vc_id)
	st.status = "callback"
	st.callback = _make_callback(_vc_id)
	st.reentry_bonus = false


static func _make_callback(vc_id: String) -> Dictionary:
	# One condition per VC, by domain (working assignment).
	match InvestorRegistry.get_investor(vc_id).get("domain", ""):
		"metrics": return {"type": "mrr_growth", "target": int(round(_meeting_day_mrr * (1.0 + PitchConstants.CALLBACK_MRR_GROWTH_PCT / 100.0))), "met": false}
		"product": return {"type": "bugs_under", "target": PitchConstants.CALLBACK_BUGS_UNDER, "met": false}
		"team": return {"type": "first_engineer", "target": 1, "met": false}
		_: return {"type": "scandal_resolved", "target": 0, "met": false}


## Series A only: the seed branch of _resolve_beat4 returns before any rejection.
static func _reject() -> void:
	# Frank's cold-exit line is chosen BEFORE this rejection is written into the streak,
	# because "was the previous meeting a rejection too" is a question about the one before.
	_pick_cold_exit()
	GameState.vc_last_meeting_rejected = true
	GameState.vc_rejections += 1
	_vc(_vc_id).status = "rejected"
	# "Repeated rejections cost brand and morale" (ch. 09 section 4). Both go through their
	# owning seams, never the field: set_brand emits, and HRMoraleSystem.apply_delta is the
	# same door the morale_all effect verb uses, so a rejection reads on the Ekip page like any
	# other blow.
	GameState.set_brand(GameState.brand - PitchConstants.REJECT_BRAND_COST)
	for worker in CharacterRegistry.get_employees():
		HRMoraleSystem.apply_delta(worker, -PitchConstants.REJECT_MORALE_COST, "vc_rejection")


# --- Term Sheet Table outcomes (TermSheetTableSystem, the Hunt tab and the sheet-decision
# card call these). Logic lives here, not in the UI, so it is testable and single-sourced. ---

static func sign_table(vc_id: String, terms: Dictionary = {},
		stage: String = PitchConstants.STAGE_SERIES_A) -> void:
	# THE SEED SIGNATURE COMES THROUGH HERE TOO, and that is the point: "the money moves at
	# a played İMZALA" stays one sentence for both rungs, which is why the seed round needed
	# no economic effect verb of its own. What it must NOT touch is everything below —
	# series_a_closed, the signed-terms block, the victory ending.
	if stage == PitchConstants.STAGE_SEED:
		SeedRoundSystem.accept(vc_id, terms)
		return
	# Class A instant Hard Win — the played moment fires the ending directly. The engine
	# backstop (EndingsSystem.daily_tick reads series_a_closed) still catches it if this
	# path is bypassed; trigger_ending is idempotent so there is never a double-ending.
	# The signed terms also ride into the ending extra (_sign_extra); the Founder-Friendly /
	# Aggressive variant reads them off the Run Ledger.
	GameState.series_a_closed = true
	_vc(vc_id).status = "signed"
	_persist_signed_terms(terms)   # Run Ledger seam — newspaper reads these off get_run_ledger()
	EndingsSystem.trigger_ending("series_a_close", EndingsSystem.TELEGRAPH_WIN, _sign_extra(vc_id, terms))


## The money a Series A deal raises at these terms.
static func raised_for(valuation_m: int, dilution_pct: int) -> int:
	return int(round(valuation_m * 1_000_000.0 * dilution_pct / 100.0))


# Persist the signed deal onto the Run Ledger (write-only run_* convention). The same
# numbers also ride into the ending extra via _sign_extra (transport); GameState is the
# durable single source the ending screen and get_run_ledger() read.
static func _persist_signed_terms(terms: Dictionary) -> void:
	if terms.is_empty():
		return
	var val: int = int(terms.get("valuation_m", 0))
	var dil: int = int(terms.get("dilution_pct", 0))
	GameState.run_valuation_m = val
	GameState.run_equity_pct = dil
	GameState.run_board_seats = int(terms.get("board_seats", 0))
	GameState.run_board_veto = bool(terms.get("board_veto", false))
	GameState.run_investment_amount = raised_for(val, dil)


# Signed-terms payload for the ending (empty-safe: bare sign_table(vc_id) → just the VC id).
static func _sign_extra(vc_id: String, terms: Dictionary) -> Dictionary:
	var extra := {"signed_vc": vc_id}
	if not terms.is_empty():
		var val: int = int(terms.get("valuation_m", 0))
		var dil: int = int(terms.get("dilution_pct", 0))
		extra["valuation_m"] = val
		extra["dilution_pct"] = dil
		extra["board_seats"] = int(terms.get("board_seats", 0))
		extra["board_veto"] = bool(terms.get("board_veto", false))
		extra["money_raised"] = raised_for(val, dil)
	return extra


static func walk_table(vc_id: String, reason: String = "declined") -> void:
	# Sheet destroyed, VC closed. Any OTHER active sheet survives. A rejection is counted
	# only when the FUND walked (patience-zero walk-out, or the walk that answers a shown rival
	# offer): the player's own walk closes the fund for the run but is not a rejection, so it
	# never feeds the cascade.
	#
	# THE REASON IS NOT COSMETIC. The player's walks — the Hunt tab's walk from a granted
	# sheet and the table's own walk — pass the default "declined"; the fund's walk-out passes
	# WALK_REASON_FUND. ch. 13 §1 needs to know the Series A decision was FACED, while the
	# buyout card needs to know it was faced THIS WAY rather than by letting a door stand open
	# for a month.
	if _stage == PitchConstants.STAGE_SEED:
		push_error("[VCPitchSystem] walk_table at a seed sitting — the refusal row is locked")
		return
	GameState.mark_faced_series_a(reason)
	for sheet in GameState.active_sheets.duplicate():
		if sheet.vc_id == vc_id:
			GameState.active_sheets.erase(sheet)
	if reason == WALK_REASON_FUND:
		GameState.vc_rejections += 1
	# A fund that walked out on the player reads as a refusal on the Hunt tab ("Declined"),
	# not as the player's own walk; both are closed for the run.
	_vc(vc_id).status = "rejected" if reason == WALK_REASON_FUND else "walked"
	EventBus.sheet_walked.emit(vc_id)  # HuntTab repaints after a table walk


## "Decline": the window closed and the player said no. The fund closes for the run, and
## because it was the PLAYER'S answer it is not a rejection - no cascade point, no brand or
## morale cost. Nor does it mark the Series A decision as faced: whether a declined-at-expiry
## offer counts for the buyout road is an open decision (docs/ACIK_ISLER/ACIK_KARARLAR.md), so the
## reading stays as it was when an expiry closed silently. Only a sheet whose window has
## actually closed can be declined this way; a live sheet is refused through walk_table.
static func decline_expired_sheet(vc_id: String) -> bool:
	var sheet: TermSheet = sheet_for(vc_id)
	if sheet == null or not sheet.is_decision_due(GameState.day):
		push_warning("[VCPitchSystem] decline_expired_sheet(%s): no sheet awaiting a decision" % vc_id)
		return false
	GameState.active_sheets.erase(sheet)
	_vc(vc_id).status = "expired"          # NOT a rejection
	EventBus.sheet_expired.emit(vc_id)
	_tick_countdown_chip()
	return true


## The Series A sheet whose window has closed and is waiting for an answer, or null. Lowest
## fund id first, so two sheets closing on the same day reach the player in a stable order.
static func decision_due_sheet(skip: Dictionary = {}) -> TermSheet:
	var best: TermSheet = null
	for sheet in GameState.active_sheets:
		var ts: TermSheet = sheet
		if ts == null or skip.has(String(ts.vc_id)) or not ts.is_decision_due(GameState.day):
			continue
		if best == null or String(ts.vc_id) < String(best.vc_id):
			best = ts
	return best


## The estimated range the offer row shows before the table. {val_lo, val_hi, dil_lo,
## dil_hi}; empty for a missing sheet. Contains the true opening term, never centred on it,
## and seeded by fund id + grant day so it never rerolls between looks.
static func estimate_ranges(sheet: TermSheet) -> Dictionary:
	if sheet == null:
		return {}
	var val: int = int(sheet.opening_terms.get("valuation_m", 0))
	var dil: int = int(sheet.opening_terms.get("dilution_pct", 0))
	var h: int = absi(("%s:%d" % [String(sheet.vc_id), sheet.granted_day]).hash())
	var val_w: int = maxi(PitchConstants.EST_VAL_MIN_WIDTH_M,
		int(round(val * PitchConstants.EST_VAL_WIDTH_PCT / 100.0)))
	var dil_w: int = maxi(PitchConstants.EST_DIL_MIN_WIDTH,
		int(round(dil * PitchConstants.EST_DIL_WIDTH_PCT / 100.0)))
	var v: Array = _range_around(val, val_w, h % 1000, (h >> 10) & 1)
	var d: Array = _range_around(dil, dil_w, (h >> 12) % 1000, (h >> 22) & 1)
	return {"val_lo": v[0], "val_hi": v[1], "dil_lo": d[0], "dil_hi": d[1]}


## [lo, hi] around true_v, never below 1: the true value sits EST_POS_MIN..MAX of the width in
## from the low edge (or, with `mirror`, from the high edge). Never exactly centred after rounding.
static func _range_around(true_v: int, width: int, roll: int, mirror: int) -> Array:
	var pos: float = lerpf(PitchConstants.EST_POS_MIN, PitchConstants.EST_POS_MAX, float(roll) / 999.0)
	if mirror == 1:
		pos = 1.0 - pos
	var lo: int = floori(true_v - pos * width)
	var hi: int = ceili(true_v + (1.0 - pos) * width)
	if lo < 1:
		hi += 1 - lo
		lo = 1
	if lo + hi == 2 * true_v:
		if pos < 0.5 or lo <= 1:
			hi += 1
		else:
			lo -= 1
	return [lo, hi]


## The two range strings the Hunt offer row and the sheet-decision card print ("~$16–20M", "~18–24%").
static func estimate_valuation_text(vc_id: String) -> String:
	var r: Dictionary = estimate_ranges(sheet_for(vc_id))
	if r.is_empty():
		return ""
	return _t("HUNT_EST_VALUATION").format({"lo": r.val_lo, "hi": r.val_hi})


static func estimate_dilution_text(vc_id: String) -> String:
	var r: Dictionary = estimate_ranges(sheet_for(vc_id))
	if r.is_empty():
		return ""
	return _t("HUNT_EST_DILUTION").format({"lo": r.dil_lo, "hi": r.dil_hi})


## The SEED offer for a VC, or null. Separate from sheet_for on purpose: that one scans
## active_sheets, and the seed sheet is deliberately not in it.
static func seed_sheet_for(vc_id: String) -> TermSheet:
	var sheet: TermSheet = GameState.seed_sheet
	return sheet if sheet != null and String(sheet.vc_id) == vc_id else null


# Read helper for the Hunt tab / table modal: the live SERIES A sheet for a VC (or null).
static func sheet_for(vc_id: String) -> TermSheet:
	for sheet in GameState.active_sheets:
		if sheet.vc_id == vc_id:
			return sheet
	return null


# ============================================================================
# Scheduling + prep
# ============================================================================

## Why a meeting with this fund cannot be booked right now, as an id the Hunt tab renders:
## "" (bookable) · "busy" · "cancelled_today" · "callback_unmet" · "closed" · "locked".
static func meeting_blocked_reason(vc_id: String) -> String:
	if InvestorRegistry.is_locked(vc_id):
		return "locked"
	var st: Dictionary = GameState.vc_states.get(vc_id, {})
	var status: String = String(st.get("status", "open"))
	if status in ["rejected", "expired", "walked", "signed", "offered", "pending_sheet"]:
		return "closed"
	# ONE CALLBACK PER VC: the door stays shut until the condition the fund named is met.
	if status == "callback" and not bool((st.get("callback", {}) as Dictionary).get("met", false)):
		return "callback_unmet"
	if not GameState.pending_meeting.is_empty():
		return "busy"                          # one at a time
	if GameState.vc_meeting_cancel_day == GameState.day:
		return "cancelled_today"
	return ""


## True when the Series A road has nowhere left to go: no fund that can still be met, no live
## or queued offer, no booked meeting. Read-only (vc_states.get, never _vc, which would create
## a row). The Hunt tab says so in one plain line instead of leaving the player to infer it;
## what the run does next is an open decision (docs/ACIK_ISLER/ACIK_KARARLAR.md), not this query.
static func series_a_road_closed() -> bool:
	if GameState.phase < 3:
		return false
	if GameState.pivot_used:
		return true
	if not GameState.active_sheets.is_empty() or not GameState.pending_meeting.is_empty():
		return false
	for inv in InvestorRegistry.get_active():
		var st: Dictionary = GameState.vc_states.get(String(inv.id), {})
		if bool(st.get("pending_sheet", false)):
			return false
		if String(st.get("status", "open")) in ["open", "callback", "offered", "pending_sheet"]:
			return false
	return true


static func request_meeting(vc_id: String) -> bool:
	if meeting_blocked_reason(vc_id) != "":
		return false
	GameState.pending_meeting = {"vc_id": vc_id, "day": GameState.day + PitchConstants.MEETING_LEAD_DAYS}
	_vc(vc_id).meeting_count = int(_vc(vc_id).get("meeting_count", 0)) + 1
	return true


## Can the booked meeting still be moved? Only before its day - on the day itself the
## meeting card is already the decision.
static func can_move_meeting() -> bool:
	var pm: Dictionary = GameState.pending_meeting
	return not pm.is_empty() and int(pm.get("day", 0)) > GameState.day


## "Cancel": the booking goes, a prep aimed at it goes with it, the fund remembers
## (MEETING_CANCEL_PENALTY off its next meeting), and no new meeting is booked today.
static func cancel_meeting() -> bool:
	if not can_move_meeting():
		return false
	var vc_id: String = String(GameState.pending_meeting.get("vc_id", ""))
	GameState.pending_meeting.clear()
	if String(GameState.prep.get("vc_id", "")) == vc_id:
		GameState.prep.clear()
		GameState.set_flag("pitch_prep_active", false)
	_add_move_penalty(vc_id, PitchConstants.MEETING_CANCEL_PENALTY)
	GameState.vc_meeting_cancel_day = GameState.day
	EventGate.remove_queued(MEETING_CARD)
	return true


## "Reschedule": the same lead time again, from today. The prep (if any) stays aimed at
## the same fund; the fund remembers (MEETING_RESCHEDULE_PENALTY off its next meeting).
static func reschedule_meeting() -> bool:
	if not can_move_meeting():
		return false
	var vc_id: String = String(GameState.pending_meeting.get("vc_id", ""))
	GameState.pending_meeting["day"] = GameState.day + PitchConstants.MEETING_LEAD_DAYS
	_add_move_penalty(vc_id, PitchConstants.MEETING_RESCHEDULE_PENALTY)
	return true


static func _add_move_penalty(vc_id: String, points: int) -> void:
	var st: Dictionary = _vc(vc_id)
	st["move_penalty"] = int(st.get("move_penalty", 0)) + points


static func prep_blocked_reason(vc_id: String) -> String:
	# "" = allowed; else the reason to show (no fake choices).
	if not GameState.prep.is_empty():
		return _t("VC_PREP_BUSY")
	if GameState.pending_meeting.get("vc_id", "") != vc_id:
		return _t("VC_PREP_NEED_MEETING")
	var days_before: int = int(GameState.pending_meeting.get("day", 0)) - GameState.day
	if days_before < PitchConstants.PREP_MIN_DAYS_BEFORE:
		return _t("VC_PREP_TOO_SOON").format({"days": PitchConstants.PREP_MIN_DAYS_BEFORE})
	return ""


static func start_prep(vc_id: String, focus: String) -> bool:
	if prep_blocked_reason(vc_id) != "":
		return false
	GameState.prep = {"vc_id": vc_id, "focus": focus, "done_day": GameState.day + PitchConstants.PREP_DAYS}
	GameState.set_flag("pitch_prep_active", true)   # capacity coupling (product slows)
	return true


static func _consume_prep(vc_id: String) -> String:
	# Return the focus if a completed prep targets this VC; clear it either way.
	var focus := ""
	if GameState.prep.get("vc_id", "") == vc_id:
		focus = String(GameState.prep.get("focus", ""))
	GameState.prep.clear()
	GameState.set_flag("pitch_prep_active", false)
	return focus


# ============================================================================
# Daily tick (TimeManager slot between PhaseGate and Endings)
# ============================================================================

static func daily_tick() -> void:
	if not GameState.run_active:
		return
	_deliver_pending_sheet()
	_tick_callbacks()
	_tick_prep()
	_tick_meeting_day()
	_tick_countdown_chip()


static func _deliver_pending_sheet() -> void:
	if GameState.active_sheets.size() >= PitchConstants.MAX_SHEETS:
		return
	for inv in InvestorRegistry.get_active():
		var st: Dictionary = _vc(inv.id)
		if st.get("pending_sheet", false):
			st.pending_sheet = false
			st.status = "offered"
			GameState.active_sheets.append(_make_sheet(inv.id, GameState.day))  # validity starts now
			EventBus.sheet_granted.emit(inv.id)
			# Frank v6 surface 24 is deliberately not raised here: open decision D12
			# (docs/ACIK_ISLER/ACIK_KARARLAR.md).
			return


static func _tick_callbacks() -> void:
	for inv in InvestorRegistry.get_active():
		var st: Dictionary = _vc(inv.id)
		if st.get("status", "") != "callback":
			continue
		var cb: Dictionary = st.get("callback", {})
		if cb.is_empty() or cb.get("met", false):
			continue
		if _callback_met(cb):
			cb.met = true
			st.reentry_bonus = true
			EventBus.callback_ready.emit(inv.id)
			EventBus.mentor_advisory_changed.emit(
				_t("VC_CALLBACK_REOPENED").format({"investor": inv.display_name}))


static func _tick_prep() -> void:
	if GameState.prep.is_empty():
		return
	if GameState.day >= int(GameState.prep.get("done_day", 0)):
		# Prep finished but the meeting hasn't happened — keep the focus, free capacity.
		GameState.set_flag("pitch_prep_active", false)
		GameState.prep["ready"] = true


static func _tick_meeting_day() -> void:
	# No latch here: `funding.meeting_day` declares `cooldown_days: 1` on `latch_key: entity`.
	# The SIGNAL is emitted because the meeting day arriving is a fact several surfaces want
	# and only one of them is a card.
	var pm: Dictionary = GameState.pending_meeting
	if pm.is_empty():
		return
	if GameState.day == int(pm.get("day", 0)):
		EventBus.meeting_day.emit(String(pm.get("vc_id", "")))


static func _tick_countdown_chip() -> void:
	# BUSINESS days. A sheet whose window has closed is the decision card's business, not
	# the chip's, so it is left out.
	var min_days := 9999
	for sheet in GameState.active_sheets:
		if (sheet as TermSheet).is_decision_due(GameState.day):
			continue
		min_days = mini(min_days, (sheet as TermSheet).business_days_left(GameState.day))
	EventBus.offer_countdown_changed.emit(min_days if (min_days <= PitchConstants.WARNING_DAYS) else -1)


## Is today the last day to answer the last table? Frank v6, surface 15. The trigger is the
## SITUATION the line describes, not a calendar date: today is the last day to answer, and
## there is nothing else left to walk to.
##
## Distinct from surface 14 (the expiry warning), which fires while an offer's clock is still
## running and can fire more than once. This one is the last day, with no other table.
##
## `funding.last_answer` reads this through the `funding.last_answer_moment` seam; the card's
## `one_shot` is the latch. Read-only (vc_states.get, never _vc): a card condition writes nothing.
static func is_last_answer_moment() -> bool:
	if GameState.active_sheets.size() != 1:
		return false                             # "elde başka masa kalmamıştır"
	var sheet: TermSheet = GameState.active_sheets[0]
	if sheet == null or sheet.business_days_left(GameState.day) != 1:
		return false                             # one weekday left ⇒ today is the last day to answer
	if not GameState.pending_meeting.is_empty():
		return false
	for inv in InvestorRegistry.get_active():
		var st: Dictionary = GameState.vc_states.get(String(inv.id), {})
		if bool(st.get("pending_sheet", false)):
			return false
		if String(st.get("status", "open")) in ["open", "callback"]:
			return false                         # another table is still reachable
	return true


# --- Pivot cleanup hook (called by EndingsSystem.on_pivot_accepted) ---
static func on_pivot() -> void:
	GameState.pending_meeting.clear()
	GameState.prep.clear()
	GameState.set_flag("pitch_prep_active", false)
	for inv in InvestorRegistry.get_active():
		var st: Dictionary = _vc(inv.id)
		if st.get("status", "") == "callback":
			st.status = "rejected"
		st.pending_sheet = false
	EventGate.remove_queued(MEETING_CARD)


# ============================================================================
# View-state builders (target MeetingScene contract)
# ============================================================================

static func _base_view_state() -> Dictionary:
	var inv: Dictionary = InvestorRegistry.get_investor(_vc_id)
	return {
		"background_path": inv.get("room_path", ""),
		"portrait_path": inv.get("portrait_path", ""),
		"speaker_name": inv.get("display_name", ""),
		"speaker_role": InvestorRegistry.role_line(_vc_id),
		"conviction": {"value": mini(_conviction, _cap)},
		"stat_strip": {"left_text": _t("VC_STAT_STRIP").format({
			"cash": UiTokens.format_money(GameState.cash),
			"runway_label": _t("RUNWAY_GROSS_LABEL"),
			"months": int(floor(_gross_runway_months())),
			"day": GameState.day})},
		"can_withdraw": false,
	}


static func _beat1_view_state(why: Array) -> Dictionary:
	var vs: Dictionary = _base_view_state()
	vs["active_line"] = _active_line(_t(_k("B1_LINE")).format(
		{"investor": InvestorRegistry.get_investor(_vc_id).get("display_name", "")}))
	# Never empty: both conviction profiles always carry the MRR and brand reasons.
	vs["monologue_text"] = _t(_k("B1_MONO_WHY")).format({"reasons": " · ".join(PackedStringArray(why))})
	vs["beat_label"] = _t("VC_BEAT1_LABEL")
	vs["can_withdraw"] = true                       # only before the first check
	vs["choices"] = [{"id": "b1_read", "text": _t("VC_B1_CHOICE"), "odds_text": _odds(_t("VC_APPROACH_PERCEPTION"), PitchConstants.BEAT1_SKILL, PitchConstants.BEAT1_DIFF, 0)}]
	return vs


static func _beat2_view_state(prev: Dictionary) -> Dictionary:
	var vs: Dictionary = _base_view_state()
	vs["active_line"] = _active_line(_react_line(prev) + _t(_k("B2_LINE")))
	vs["monologue_text"] = _t(_k("B2_MONO")) if not _intel else ""
	vs["beat_label"] = _t("VC_BEAT2_LABEL")
	var favored: String = InvestorRegistry.favored_angle(_vc_id) if _intel else ""
	var out: Array = []
	for a in [["metrik", _t(_k("B2_METRIC"))], ["vizyon", _t(_k("B2_VISION"))], ["traction", _t(_k("B2_TRACTION"))]]:
		# The resolver's own _angle_diff: the odds shown are the odds rolled.
		out.append({"id": "b2_" + a[0], "text": a[1], "odds_text": _odds(_t("VC_APPROACH_NARRATIVE"), _angle_skill(a[0]), _angle_diff(a[0]), _beat2_bonus(a[0])), "marked": (a[0] == favored)})
	vs["choices"] = out
	return vs


static func _beat3_view_state(prev: Dictionary) -> Dictionary:
	var vs: Dictionary = _base_view_state()
	vs["active_line"] = _active_line(_react_line(prev) + String(_sorgu.get("vc_line", "")))
	vs["monologue_text"] = String(_sorgu.get("mono", ""))
	vs["beat_label"] = _t("VC_BEAT3_LABEL")
	var prova: bool = _prep_focus == "prova"
	# The resolver's own _beat3_diff / _beat3_bonus: a clean question is rolled at Kolay, and the
	# odds shown are the odds rolled.
	vs["choices"] = [
		{"id": "b3_durust", "text": _t("VC_B3_HONEST"), "odds_text": _odds(_t("VC_APPROACH_HONEST"), PitchConstants.BEAT3_SKILL, _beat3_diff("durust"), _beat3_bonus("durust")), "caption": _t("VC_B3_HONEST_CAP"), "marked": prova, "marked_text": _t("VC_REHEARSED")},
		{"id": "b3_spin", "text": _t("VC_B3_SPIN"), "odds_text": _odds(_t("VC_APPROACH_SPIN"), PitchConstants.BEAT3_SKILL, _beat3_diff("spin"), _beat3_bonus("spin")), "caption": _t("VC_B3_SPIN_CAP")},
		{"id": "b3_gecistir", "text": _t("VC_B3_DEFLECT"), "odds_text": _odds(_t("VC_APPROACH_DEFLECT"), PitchConstants.BEAT3_SKILL, _beat3_diff("gecistir"), _beat3_bonus("gecistir")), "caption": _t("VC_B3_DEFLECT_CAP").format({"cap": PitchConstants.GECISTIR_CAP}), "caption_danger": true},
	]
	return vs


static func _beat4_view_state() -> Dictionary:
	var vs: Dictionary = _base_view_state()
	var zone_val: int = mini(_conviction, _cap)
	vs["beat_label"] = _t("VC_BEAT4_LABEL")
	# THREE BANDS, NO FORK. The seed room has no Ilık gamble and no callback: it says what
	# it will pay and the founder acknowledges. Even the harsh line ends with an offer, and
	# it names the price rather than the founder — Satış §11.9: the closing moment never
	# diminishes the player.
	if _stage == PitchConstants.STAGE_SEED:
		var band: String = SeedConstants.band_for(zone_val).to_upper()
		vs["active_line"] = _active_line(_t("SEED_B4_LINE_" + band))
		vs["monologue_text"] = _t("SEED_B4_MONO_" + band)
		vs["choices"] = [{"id": "b4_ack", "text": _t("SEED_B4_ACK")}]
		return vs
	if zone_val >= PitchConstants.WON_MIN:
		vs["active_line"] = _active_line(_t("VC_B4_WIN_LINE"))
		vs["choices"] = [{"id": "b4_ack", "text": _t("VC_B4_WIN_CHOICE")}]
	elif zone_val < PitchConstants.ILIK_MIN:
		vs["active_line"] = _active_line(_t("VC_B4_LOSS_LINE"))
		# The Soğuk band is decided here - _resolve_beat4 rejects whatever is clicked - so the
		# exit view already carries Frank's line.
		vs["monologue_text"] = _t("VC_B4_LOSS_MONO") + "\n\n" + _cold_exit_text()
		vs["choices"] = [{"id": "b4_leave", "text": _t("VC_B4_LOSS_CHOICE")}]
	else:
		vs["active_line"] = _active_line(_t("VC_B4_WARM_LINE"))
		vs["monologue_text"] = _t("VC_B4_WARM_MONO")
		var push_choice: Dictionary = {"id": "b4_zorla", "text": _t("VC_B4_PUSH"), "odds_text": _odds(_t("VC_APPROACH_PUSH"), PitchConstants.BEAT4_PUSH_SKILL, PitchConstants.MASAYI_ZORLA_DIFF, 0), "caption": _t("VC_B4_PUSH_CAP"), "caption_danger": true}
		if _reentry:
			vs["choices"] = [push_choice, {"id": "b4_ret", "text": _t("VC_B4_QUIT"), "caption": _t("VC_B4_QUIT_CAP")}]
		else:
			vs["choices"] = [{"id": "b4_callback", "text": _t("VC_B4_CALLBACK"), "caption": _t("VC_B4_CALLBACK_CAP")}, push_choice]
	return vs


static func _result_view_state(kind: String) -> Dictionary:
	var vs: Dictionary = _base_view_state()
	var line := ""
	match kind:
		"callback": line = _t("VC_RES_CALLBACK")
		"zorla_win": line = _t("VC_RES_PUSH_WIN")
		"zorla_ret": line = _t("VC_RES_PUSH_LOSS")
		"seed_strong": line = _t("SEED_RES_STRONG")
		"seed_standard": line = _t("SEED_RES_STANDARD")
		"seed_harsh": line = _t("SEED_RES_HARSH")
		_: line = _t("VC_RES_DEFAULT")
	vs["active_line"] = _active_line(line)
	if kind in ["zorla_ret", "ret"]:
		vs["monologue_text"] = _cold_exit_text()     # the rejection's exit view
	vs["beat_label"] = _t("VC_BEAT4_LABEL")
	vs["choices"] = [{"id": "b4_close", "text": _t("VC_B4_CLOSE")}]
	return vs


## Frank on the way out of a Series A rejection. Picked ONCE per sitting (the view may
## be built before _reject writes the streak), and the pick is written the moment it is made:
##   the previous finished Series A meeting was a rejection too  → the "two in a row" line;
##   else this fund's own line, if it has not been shown this run  → that line (remembered);
##   else                                                          → the general line.
static func _pick_cold_exit() -> String:
	if _cold_exit_key != "":
		return _cold_exit_key
	if GameState.vc_last_meeting_rejected:
		_cold_exit_key = "VC_FRANK_COLD_GENERAL_2"
	elif _vc_id in COLD_EXIT_FUNDS and not GameState.vc_frank_cold_shown.has(_vc_id):
		_cold_exit_key = "VC_FRANK_COLD_" + _vc_id.to_upper()
		GameState.vc_frank_cold_shown.append(_vc_id)
	else:
		_cold_exit_key = "VC_FRANK_COLD_GENERAL_1"
	return _cold_exit_key


static func _cold_exit_text() -> String:
	return _t("VC_FRANK_COLD_EXIT").format({"line": _t(_pick_cold_exit())})


# ============================================================================
# Beat-3 domain interrogation
# ============================================================================

static func _pick_sorgu_target() -> Dictionary:
	# Worst item WITHIN this VC's domain (per-domain priority). Clean domain → payoff.
	#
	# THE SEED ROOM ASKS DIFFERENT QUESTIONS OF THE SAME STATE. It is not auditing a
	# business, so "your churn is talking" has nothing to bite on; it wants to know where
	# the insight came from, how the first customers found you, why this team, how big this
	# gets. Same per-domain dispatch, so each fund still interrogates its own subject, and
	# every branch is still chosen by a real state read — a question nobody earned is
	# decoration, and Satış §11.9 bans decoration.
	if _stage == PitchConstants.STAGE_SEED:
		return _pick_sorgu_seed()
	match InvestorRegistry.get_investor(_vc_id).get("domain", ""):
		"metrics": return _sorgu_metrics()
		"team": return _sorgu_team()
		"narrative": return _sorgu_narrative()
		"product": return _sorgu_product()
		_: return _clean_sorgu()


static func _pick_sorgu_seed() -> Dictionary:
	match InvestorRegistry.get_investor(_vc_id).get("domain", ""):
		"metrics":
			# Distribution, not cohorts: at this size the only interesting question about
			# revenue is how anybody found you at all.
			if CustomerRegistry.get_active().size() <= 1 or GameState.run_customers_signed <= 1:
				return {"key": "first_customers", "vc_line": _t("SEED_Q_FIRST_CUSTOMERS"),
					"mono": _t("SEED_Q_FIRST_CUSTOMERS_MONO")}
		"team":
			if CharacterRegistry.get_employees().is_empty() \
				or CharacterRegistry.count_developers() == 0:
				return {"key": "team_wins", "vc_line": _t("SEED_Q_TEAM_WINS"),
					"mono": _t("SEED_Q_TEAM_WINS_MONO")}
		"narrative":
			if _rival_ahead() or GameState.reputation < 0:
				return {"key": "insight", "vc_line": _t("SEED_Q_INSIGHT"),
					"mono": _t("SEED_Q_INSIGHT_MONO")}
		"product":
			if _weakest_dimension() != "" or ProductSystem.live_bug_count() > 0:
				return {"key": "how_big", "vc_line": _t("SEED_Q_HOW_BIG"),
					"mono": _t("SEED_Q_HOW_BIG_MONO")}
	return {"key": "clean", "vc_line": _t("SEED_Q_CLEAN"), "mono": _t("SEED_Q_CLEAN_MONO")}


static func _sorgu_metrics() -> Dictionary:
	# WORKING PROXY: no churn/concentration fields yet — inferred from run counters + MRR.
	if GameState.run_customers_lost > 0:
		return {"key": "churn", "vc_line": _t("VC_Q_CHURN"), "mono": _t("VC_Q_CHURN_MONO")}
	if GameState.mrr < PitchConstants.CONV_MRR_REFERENCE:
		return {"key": "growth_flat", "vc_line": _t("VC_Q_GROWTH"), "mono": _t("VC_Q_GROWTH_MONO")}
	if _b2b_concentration():
		return {"key": "concentration", "vc_line": _t("VC_Q_CONCENTRATION"), "mono": _t("VC_Q_CONCENTRATION_MONO")}
	# NOT A PROXY — this one reads a real field. Customer.acquisition_source records who
	# closed each account ("founder_pitch" vs "sales_rep:<id>"), which is exactly the
	# Series A question "how much of this revenue is repeatable sales, and how much is
	# you". A founder who closed the whole book personally has a company that stops when
	# they do, and this room says so.
	if _founder_closed_the_book():
		return {"key": "repeatable", "vc_line": _t("VC_Q_REPEATABLE"), "mono": _t("VC_Q_REPEATABLE_MONO")}
	return _clean_sorgu()


static func _sorgu_team() -> Dictionary:
	if GameState.unmanaged_major_scandal:
		return {"key": "scandal", "vc_line": _t("VC_Q_SCANDAL"), "mono": _t("VC_Q_SCANDAL_MONO")}
	# Headcount lens, not capacity: a company whose only developer is on holiday has
	# not become an engineer-less company, so this reads the unfiltered count.
	if CharacterRegistry.count_developers() == 0:
		return {"key": "no_engineers", "vc_line": _t("VC_Q_NO_ENGINEERS"), "mono": _t("VC_Q_NO_ENGINEERS_MONO")}
	if CharacterRegistry.get_employees().is_empty():
		return {"key": "solo", "vc_line": _t("VC_Q_SOLO"), "mono": _t("VC_Q_SOLO_MONO")}
	return _clean_sorgu()


static func _sorgu_narrative() -> Dictionary:
	# WORKING PROXY: rival lead inferred from the registry's DOMINANT band.
	if _rival_ahead():
		return {"key": "rival", "vc_line": _t("VC_Q_RIVAL"), "mono": _t("VC_Q_RIVAL_MONO")}
	if GameState.get_flag("acquisition_offer_rejected", false):   # LOC-DATA run flag id
		return {"key": "refused_acq", "vc_line": _t("VC_Q_REFUSED_ACQ"), "mono": _t("VC_Q_REFUSED_ACQ_MONO")}
	if GameState.reputation < 0:
		return {"key": "reputation", "vc_line": _t("VC_Q_REPUTATION"), "mono": _t("VC_Q_REPUTATION_MONO")}
	return _clean_sorgu()


static func _sorgu_product() -> Dictionary:
	if ProductSystem.live_bug_count() > 0:
		return {"key": "bugs", "vc_line": _t("VC_Q_BUGS"), "mono": _t("VC_Q_BUGS_MONO")}
	var weak: String = _weakest_dimension()
	if weak != "":
		return {"key": "weak_dim",
			"vc_line": _t("VC_Q_WEAK_DIM").format({"axis": ProductCatalog.axis_label(weak)}),
			"mono": _t("VC_Q_WEAK_DIM_MONO")}
	return _clean_sorgu()


static func _clean_sorgu() -> Dictionary:
	return {"key": "clean", "vc_line": _t("VC_Q_CLEAN"), "mono": _t("VC_Q_CLEAN_MONO")}


# ============================================================================
# Small helpers
# ============================================================================

static func _vc(vc_id: String) -> Dictionary:
	if not GameState.vc_states.has(vc_id):
		GameState.vc_states[vc_id] = {"status": "open", "callback": {}, "pending_sheet": false, "meeting_count": 0, "reentry_bonus": false}
	return GameState.vc_states[vc_id]


static func _gross_runway_months() -> float:
	# GROSS burn runway (revenue ignored — "if revenue went to zero, how long?"). The VC's
	# question; deliberately distinct from the shell's revenue-aware NET runway. Always finite.
	var burn: int = maxi(GameState.daily_burn, 1)
	return (float(GameState.cash) / float(burn) / float(GameState.DAYS_PER_MONTH)) if GameState.cash > 0 else 0.0


## The Beat-2 angle difficulty. At Series A it is the fund's own weight; in the seed room
## that weight is shifted so vision is easier and hard metrics are harder, clamped back into
## the real difficulty range. The SAME function feeds the resolver and the view - split them
## and the odds the player is shown stop matching the odds that get rolled.
static func _angle_diff(angle: String) -> int:
	var base: int = int(InvestorRegistry.get_investor(_vc_id).get("weights", {}).get(
		angle, PitchConstants.DIFF_ORTA))
	if _stage != PitchConstants.STAGE_SEED:
		return base
	return clampi(base + int(SeedConstants.CONV_ANGLE_SHIFT.get(angle, 0)),
		PitchConstants.DIFF_KOLAY, PitchConstants.DIFF_CETIN)


static func _angle_skill(angle: String) -> String:
	return String(PitchConstants.ANGLE_SKILL.get(angle, "sales"))


static func _beat2_bonus(angle: String) -> int:
	if _prep_focus == "rakamlar" and angle == "metrik":
		return PitchConstants.PREP_BONUS
	if _prep_focus == "hikaye" and angle == "vizyon":
		return PitchConstants.PREP_BONUS
	return 0


## The Beat-3 roll's difficulty: a clean question (nothing to interrogate) is Kolay whatever
## the posture. ONE function for the resolver and the view, the _angle_diff rule.
static func _beat3_diff(posture: String) -> int:
	if String(_sorgu.get("key", "")) == "clean":
		return PitchConstants.DIFF_KOLAY
	match posture:
		"durust": return PitchConstants.DURUST_DIFF
		"spin": return PitchConstants.SPIN_DIFF
		_: return PitchConstants.GECISTIR_DIFF


static func _beat3_bonus(posture: String) -> int:
	return PitchConstants.PREP_BONUS if (_prep_focus == "prova" and posture == "durust") else 0


static func _odds(label: String, skill: String, diff: int, bonus: int) -> String:
	var pct: int = int(round(SkillCheck.chance_for(skill, diff, bonus) * 100.0))
	return _t("VC_ODDS").format({
		"approach": label, "difficulty": PitchConstants.diff_label(diff), "pct": Fmt.percent(pct, 0)})


static func _react_line(chk: Dictionary) -> String:
	# Short VC reaction to the previous check (folded into the next line; inline resolution).
	match String(chk.get("band", "")):
		"crit_success", "success": return _t("VC_REACT_GOOD") + " "
		"near_pass": return _t("VC_REACT_OK") + " "
		"near_miss", "fail", "crit_fail": return _t("VC_REACT_BAD") + " "
		_: return ""


static func _callback_met(cb: Dictionary) -> bool:
	match String(cb.get("type", "")):
		"mrr_growth": return GameState.mrr >= int(cb.get("target", 0))
		"bugs_under": return ProductSystem.live_bug_count() < int(cb.get("target", 0))
		"first_engineer": return CharacterRegistry.count_developers() >= 1
		"scandal_resolved": return not GameState.unmanaged_major_scandal
		_: return false


## The weakest quality axis, as an ID ("innovation" / "stability" / "experience") or "".
## An id, never a label (store ids, render at display time): _sorgu_product localizes it
## through ProductCatalog.axis_label.
static func _weakest_dimension() -> String:
	var dims := {
		"innovation": float(GameState.get_flag("mvp_innovation", 0.0)),
		"stability": float(GameState.get_flag("mvp_stability", 0.0)),
		"experience": float(GameState.get_flag("mvp_experience", 0.0))}
	var worst := ""
	var worst_v := 999.0
	for k in dims:
		if dims[k] < worst_v:
			worst_v = dims[k]
			worst = k
	return worst if worst_v < 40.0 else ""   # only "weak" if below a working floor


## Did the founder personally close most of the book? Reads the acquisition source on the
## live accounts — no proxy, no inference. False on a one-account book, where "most" says
## nothing, and on a consumer run, which has no signing path at all.
static func _founder_closed_the_book() -> bool:
	var actives: Array = CustomerRegistry.get_active()
	if actives.size() <= 1:
		return false
	var by_founder: int = 0
	for c in actives:
		if String((c as Customer).acquisition_source) == "founder_pitch":
			by_founder += 1
	return by_founder * 2 > actives.size()


static func _b2b_concentration() -> bool:
	# WORKING PROXY: a single B2B customer > 50% of MRR.
	var actives: Array = CustomerRegistry.get_active()
	if actives.size() <= 1 or GameState.mrr <= 0:
		return false
	for c in actives:
		if int(c.mrr) * 2 > GameState.mrr:
			return true
	return false


static func _rival_ahead() -> bool:
	# A rival in the DOMINANT display band leads the league (Rival.status vocabulary).
	for r in RivalRegistry.get_all():
		if r.status == "DOMINANT":   # LOC-DATA rival status id
			return true
	return false


## Run-boundary reset (SaveManager.reset_all_owners) and the end of every sitting. The
## meeting-local statics are reset, never serialised: SaveManager.can_save() refuses while
## is_active(), so a sitting is idle at every save point. `pitch_prep_active` is a FLAG and
## rides in the GameState block, so it is not touched here.
static func reset() -> void:
	_active = false
	_vc_id = ""
	_beat = 0
	_conviction = 0
	_cap = 100
	_intel = false
	_prep_focus = ""
	_reentry = false
	_sorgu = {}
	_cold_exit_key = ""
	_stage = PitchConstants.STAGE_SERIES_A


## Which room's copy a shared beat should speak. "VC_B1_LINE" at Series A, "SEED_B1_LINE"
## in the seed room — the beats are the same shape, so the keys are the same shape too and
## only the prefix moves. A beat with no seed variant simply never calls this.
static func _k(suffix: String) -> String:
	return ("SEED_" if _stage == PitchConstants.STAGE_SEED else "VC_") + suffix


## Shorthand for TranslationServer.translate. A static func has no Object, so tr() would
## compile here and then die at run time.
static func _t(key: String) -> String:
	return TranslationServer.translate(key)


## The investor's spoken line, tagged "Kaplan Yatırım — Canlı" / "Kaplan Ventures — Live".
static func _active_line(text: String) -> Dictionary:
	var display_name: String = String(InvestorRegistry.get_investor(_vc_id).get("display_name", ""))
	return {"text": text, "speaker_tag": _t("VC_SPEAKER_LIVE").format({"name": display_name}), "is_monologue": false}
