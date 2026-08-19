class_name VCPitchSystem
extends RefCounted

# VC Pitch engine (Spec 4 / VC_PITCH_DESIGN.md). Static, pure-logic (PhaseGate/Endings
# pattern). Drives the Spec-5 MeetingScene as a humble view: builds a view_state, emits
# EventBus.meeting_scene_requested; main.gd routes the scene's choice_selected back into
# advance(), which returns the next view_state or {done:true} once the outcome is written.
#
# TWO state homes (canon §7):
#   * Persistent/serialized → GameState (vc_states, active_sheets, pending_meeting, prep).
#   * Meeting-LOCAL (conviction, beat, intel) → the static vars below, NEVER serialized
#     (ledger 13: single sitting, no mid-meeting save).
#
# Reuses: SkillCheck.resolve (odds/bands), InvestorRegistry (static roster), PitchConstants
# (global knobs), ProductSystem capacity flag (prep cost). Writes the existing engine fields
# series_a_closed / vc_rejections — EndingsSystem is already listening (§7.9 fields-not-systems).
#
# NOTE: several Beat-3 domain-interrogation items read WORKING PROXIES where no dedicated
# field exists yet (churn spike, MRR concentration, refused-acquisition). Each is marked
# `# WORKING PROXY` for Erdem's review; swap to real signals when those systems land.

const MEETING_PROMPT_ID := "ev_vc_meeting_prompt"
const SHEET_WARN_ID := "ev_sheet_expiry_warning"
const D179_ID := "ev_vc_d179_warning"

# --- Meeting-local state (never serialized) ---
static var _active: bool = false
static var _vc_id: String = ""
static var _conviction: int = 0
static var _cap: int = 100
static var _beat: int = 0            # 1..5 (5 = Ilık result render)
static var _intel: bool = false      # Beat-1 success revealed the tell
static var _first_check_done: bool = false
static var _prep_focus: String = ""  # "" | "rakamlar" | "hikaye" | "prova"
static var _reentry: bool = false    # this meeting is a callback re-entry
static var _sorgu: Dictionary = {}   # {key, vc_line, mono} chosen weak point (or clean)
static var _meeting_day_mrr: int = 0 # snapshot for callback "MRR +20%"
static var _pending_outcome: String = ""  # set at Beat-4 resolve, applied on result close


# ============================================================================
# Public: meeting lifecycle (called by main.gd via the MeetingScene signals)
# ============================================================================

static func is_meeting_active() -> bool:
	return _active


static func is_active() -> bool:
	# The uniform name SaveManager.can_save() asks all four sitting-scoped systems
	# (PitchSystem / B2BPitchMeeting / TermSheetTableSystem / this one). Kept as an alias
	# rather than a rename so the existing is_meeting_active() callers stay untouched.
	return _active


static func reset() -> void:
	# Run-boundary reset (SaveManager.reset_all_owners). The eleven statics below are
	# MEETING-LOCAL by design — this file's own header records that persistent VC state
	# lives on GameState (vc_states / active_sheets / pending_meeting / prep) while
	# conviction, beat and intel never leave the room. They are reset, never serialised, and
	# SaveManager.can_save() refuses while is_active() so a sitting is provably idle at every
	# save point. `pitch_prep_active` is a FLAG, so it rides in the GameState block and is
	# not touched here.
	_reset()


static func begin_meeting(vc_id: String) -> void:
	if not GameState.run_active:          # ledger 20 — no meeting behind a terminal
		return
	var inv: Dictionary = InvestorRegistry.get_investor(vc_id)
	if inv.is_empty() or inv.get("locked", false):
		return
	# Consume the scheduled request; the prep (if any) is spent here.
	var was_reentry: bool = _vc(vc_id).get("reentry_bonus", false)
	GameState.pending_meeting.clear()
	_active = true
	_vc_id = vc_id
	_reentry = was_reentry
	_prep_focus = _consume_prep(vc_id)
	_cap = 100
	_intel = false
	_first_check_done = false
	_beat = 1
	_sorgu = {}
	_meeting_day_mrr = GameState.mrr
	var seed_data: Dictionary = seed_conviction(vc_id)
	_conviction = int(seed_data.get("value", PitchConstants.SEED_BASE))
	EventBus.meeting_scene_requested.emit(_beat1_view_state(seed_data.get("why", [])))


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
	# Available only before the first check (ledger — Beat 1). Meeting consumed,
	# VC open, no rejection. run_pitches NOT incremented (no completed pitch).
	if not _active:
		return
	GameState.pending_meeting.clear()
	_reset()


# ============================================================================
# Conviction seeding (canon §3) — pure, GameState + registry only
# ============================================================================

static func seed_conviction(vc_id: String) -> Dictionary:
	var inv: Dictionary = InvestorRegistry.get_investor(vc_id)
	var v: int = PitchConstants.SEED_BASE
	var why: Array = []   # [{delta, label}] — top 3 by |delta| shown

	# MRR vs traction reference (scaled up to +MAX).
	var mrr_ratio: float = clampf(float(GameState.mrr) / float(PitchConstants.SEED_MRR_REFERENCE), 0.0, 1.5)
	var mrr_delta: int = int(round((mrr_ratio - 0.5) * PitchConstants.SEED_MRR_MAX_BONUS))
	v += mrr_delta
	why.append({"d": mrr_delta, "l": _t("VC_WHY_MRR_STRONG") if mrr_delta >= 0 else _t("VC_WHY_MRR_WEAK")})

	# Brand distance to floor.
	var brand_delta: int = clampi(int(round((GameState.brand - PitchConstants.SEED_BRAND_FLOOR) * 0.4)), -PitchConstants.SEED_BRAND_MAX, PitchConstants.SEED_BRAND_MAX)
	v += brand_delta
	why.append({"d": brand_delta, "l": _t("VC_WHY_BRAND_SOLID") if brand_delta >= 0 else _t("VC_WHY_BRAND_LOW")})

	# Runway health.
	if GameState.shutter_days_left >= 0:
		v += PitchConstants.SEED_SHUTTER_PENALTY
		why.append({"d": PitchConstants.SEED_SHUTTER_PENALTY, "l": _t("VC_WHY_SHUTTER")})
	elif _gross_runway_months() < 1.0:
		v += PitchConstants.SEED_THIN_RUNWAY_PENALTY
		why.append({"d": PitchConstants.SEED_THIN_RUNWAY_PENALTY, "l": _t("VC_WHY_RUNWAY_THIN")})

	if GameState.unmanaged_major_scandal:
		v += PitchConstants.SEED_SCANDAL_PENALTY
		why.append({"d": PitchConstants.SEED_SCANDAL_PENALTY, "l": _t("VC_WHY_SCANDAL")})
	if not GameState.active_sheets.is_empty():
		v += PitchConstants.SEED_LEVERAGE_BONUS
		why.append({"d": PitchConstants.SEED_LEVERAGE_BONUS, "l": _t("VC_WHY_LEVERAGE")})
	if inv.get("warm_intro", false):
		v += PitchConstants.SEED_WARM_INTRO_BONUS
		why.append({"d": PitchConstants.SEED_WARM_INTRO_BONUS, "l": _t("VC_WHY_WARM_INTRO")})
	if inv.get("domain", "") == "product" and GameState.get_flag("mvp_shipped", false):
		v += PitchConstants.SEED_DIMENSION_MATCH_BONUS
		why.append({"d": PitchConstants.SEED_DIMENSION_MATCH_BONUS, "l": _t("VC_WHY_DOMAIN_MATCH")})
	if _vc(vc_id).get("reentry_bonus", false):
		v += PitchConstants.SEED_CALLBACK_BONUS
		why.append({"d": PitchConstants.SEED_CALLBACK_BONUS, "l": _t("VC_WHY_CALLBACK")})

	# Top-3 |delta| for the legibility breakdown (≤3 lines).
	why.sort_custom(func(a, b): return absi(a.d) > absi(b.d))
	var why_lines: Array = []
	for i in mini(3, why.size()):
		why_lines.append(why[i].l)
	return {"value": clampi(v, 0, 100), "why": why_lines}


# ============================================================================
# Beat resolution
# ============================================================================

static func _resolve_beat1(_choice_id: String) -> Dictionary:
	# Odayı Oku — perception. Success reveals the tell (favored angle + Sorgu target).
	_first_check_done = true
	var chk: Dictionary = SkillCheck.resolve(PitchConstants.BEAT1_SKILL, PitchConstants.BEAT1_DIFF, 0)
	if chk.passed:
		_intel = true
	_beat = 2
	return {"done": false, "view_state": _beat2_view_state(chk)}


static func _resolve_beat2(choice_id: String) -> Dictionary:
	# Anlatı — angle check; conviction moves by margin.
	var angle: String = choice_id.trim_prefix("b2_")
	var diff: int = int(InvestorRegistry.get_investor(_vc_id).get("weights", {}).get(angle, PitchConstants.DIFF_ORTA))
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
	var clean: bool = _sorgu.get("key", "") == "clean"
	var diff: int = _posture_diff(posture)
	if clean:
		diff = PitchConstants.DIFF_KOLAY
	var bonus: int = PitchConstants.PREP_BONUS if (_prep_focus == "prova" and posture == "durust") else 0
	var chk: Dictionary = SkillCheck.resolve(PitchConstants.BEAT3_SKILL, diff, bonus)
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
	_reset()
	return {"done": true}


# ============================================================================
# Outcome write-through
# ============================================================================

static func _grant_sheet() -> void:
	GameState.run_sheets_won += 1
	if GameState.active_sheets.size() < PitchConstants.MAX_SHEETS:
		GameState.active_sheets.append(_make_sheet(_vc_id, GameState.day))
		_vc(_vc_id).status = "offered"
		EventBus.sheet_granted.emit(_vc_id)
	else:
		# Ledger 15 — delayed delivery; validity starts when a slot frees.
		var st: Dictionary = _vc(_vc_id)
		st.pending_sheet = true
		st.status = "pending_sheet"


static func _make_sheet(vc_id: String, granted_day: int) -> TermSheet:
	var inv: Dictionary = InvestorRegistry.get_investor(vc_id)
	var sheet := TermSheet.new()
	sheet.vc_id = vc_id
	sheet.granted_day = granted_day
	sheet.expires_day = granted_day + PitchConstants.SHEET_VALIDITY_DAYS
	sheet.term_bands = inv.get("term_bands", {}).duplicate()
	sheet.patience_pool = int(inv.get("patience_pool", 0))
	sheet.opening_terms = inv.get("opening_terms", {}).duplicate()  # Spec 6 — numeric offer snapshot
	return sheet


static func _set_callback() -> void:
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


static func _reject() -> void:
	GameState.vc_rejections += 1
	_vc(_vc_id).status = "rejected"


# --- Term Sheet Table outcomes (placeholder modal calls these; Spec 6 pushes the real
# table on top). Logic lives here, not in the UI, so it is testable and single-sourced. ---

static func sign_table(vc_id: String, terms: Dictionary = {}) -> void:
	# Class A instant Hard Win — the played moment fires the ending directly. The engine
	# backstop (EndingsSystem.daily_tick reads series_a_closed) still catches it if this
	# path is bypassed; trigger_ending is idempotent so there is never a double-ending.
	# The signed terms ride into the ending extra so the later ending-screen spec can read
	# the Founder-Friendly / Aggressive variant from them (Spec 6 decision: variant deferred).
	GameState.series_a_closed = true
	_vc(vc_id).status = "signed"
	_persist_signed_terms(terms)   # Run Ledger seam — newspaper reads these off get_run_ledger()
	EndingsSystem.trigger_ending("series_a_close", _sign_extra(vc_id, terms))


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
	GameState.run_investment_amount = int(round(val * 1_000_000.0 * dil / 100.0))


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
		extra["money_raised"] = int(round(val * 1_000_000.0 * dil / 100.0))
	return extra


static func walk_table(vc_id: String) -> void:
	# Sheet destroyed, +1 rejection, VC closed. Any OTHER active sheet survives (§5).
	for sheet in GameState.active_sheets.duplicate():
		if sheet.vc_id == vc_id:
			GameState.active_sheets.erase(sheet)
	GameState.vc_rejections += 1
	_vc(vc_id).status = "walked"
	EventBus.sheet_walked.emit(vc_id)  # Spec 6 — HuntTab repaints after a table walk


# Read helper for the Hunt tab / table modal: the live sheet for a VC (or null).
static func sheet_for(vc_id: String) -> TermSheet:
	for sheet in GameState.active_sheets:
		if sheet.vc_id == vc_id:
			return sheet
	return null


# ============================================================================
# Scheduling + prep
# ============================================================================

static func request_meeting(vc_id: String) -> bool:
	if not GameState.pending_meeting.is_empty():
		return false                       # ledger 24 — one at a time
	if InvestorRegistry.is_locked(vc_id):
		return false
	var status: String = _vc(vc_id).get("status", "open")
	if status in ["rejected", "expired", "walked"]:
		return false                       # closed VC
	GameState.pending_meeting = {"vc_id": vc_id, "day": GameState.day + PitchConstants.MEETING_LEAD_DAYS, "prompted": false}
	_vc(vc_id).meeting_count = int(_vc(vc_id).get("meeting_count", 0)) + 1
	return true


static func prep_blocked_reason(vc_id: String) -> String:
	# "" = allowed; else the reason to show (no fake choices — ledger 24).
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
	_tick_sheets()
	_deliver_pending_sheet()
	_tick_callbacks()
	_tick_prep()
	_tick_meeting_day()
	_tick_countdown_chip()
	_tick_d179()


static func _tick_sheets() -> void:
	for sheet in GameState.active_sheets.duplicate():
		var days: int = sheet.days_left(GameState.day)
		if days <= 0:
			GameState.active_sheets.erase(sheet)
			_vc(sheet.vc_id).status = "expired"          # NOT a rejection (§5)
			EventBus.sheet_expired.emit(sheet.vc_id)
		elif days == PitchConstants.WARNING_DAYS:
			EventManager.enqueue_front(_build_expiry_warning_event(sheet.vc_id, days))


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
	var pm: Dictionary = GameState.pending_meeting
	if pm.is_empty() or pm.get("prompted", false):
		return
	if GameState.day >= int(pm.get("day", 0)):
		pm["prompted"] = true
		EventManager.enqueue_front(_build_meeting_prompt_event(String(pm.get("vc_id", ""))))
		EventBus.meeting_day.emit(String(pm.get("vc_id", "")))


static func _tick_countdown_chip() -> void:
	var min_days := 9999
	for sheet in GameState.active_sheets:
		min_days = mini(min_days, sheet.days_left(GameState.day))
	EventBus.offer_countdown_changed.emit(min_days if (min_days <= PitchConstants.WARNING_DAYS) else -1)


static func _tick_d179() -> void:
	if GameState.day == PitchConstants.DAY180_WARN_DAY and not GameState.active_sheets.is_empty():
		if not GameState.get_flag("vc_d179_warned", false):
			GameState.set_flag("vc_d179_warned", true)
			EventManager.enqueue_front(_build_d179_event())


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
	EventManager.remove_queued(MEETING_PROMPT_ID)


# ============================================================================
# View-state builders (target MeetingScene contract)
# ============================================================================

static func _base_view_state() -> Dictionary:
	var inv: Dictionary = InvestorRegistry.get_investor(_vc_id)
	return {
		"background_path": inv.get("room_path", ""),
		"portrait_path": inv.get("portrait_path", ""),
		"speaker_name": inv.get("display_name", ""),
		"speaker_role": inv.get("role_line", ""),
		"conviction": {"value": mini(_conviction, _cap), "zone_bounds": PitchConstants.ZONE_BOUNDS},
		"stat_strip": {"left_text": _t("VC_STAT_STRIP").format({
			"cash": UiTokens.format_money(GameState.cash),
			"runway_label": _t("RUNWAY_GROSS_LABEL"),
			"months": int(floor(_gross_runway_months())),
			"day": GameState.day})},
		"can_withdraw": false,
	}


static func _beat1_view_state(why: Array) -> Dictionary:
	var inv: Dictionary = InvestorRegistry.get_investor(_vc_id)
	var vs: Dictionary = _base_view_state()
	vs["active_line"] = {
		"text": _t("VC_B1_LINE").format({"investor": inv.get("display_name", "")}),
		"speaker_tag": _speaker_tag(String(inv.get("display_name", ""))), "is_monologue": false}
	vs["monologue_text"] = _t("VC_B1_MONO_WHY").format(
		{"reasons": " · ".join(PackedStringArray(why))}) if not why.is_empty() else _t("VC_B1_MONO")
	vs["beat_label"] = _t("VC_BEAT1_LABEL")
	vs["can_withdraw"] = true                       # only before the first check (ledger)
	vs["choices"] = [{"id": "b1_read", "text": _t("VC_B1_CHOICE"), "odds_text": _odds(_t("VC_APPROACH_PERCEPTION"), PitchConstants.BEAT1_SKILL, PitchConstants.BEAT1_DIFF, 0)}]
	return vs


static func _beat2_view_state(prev: Dictionary) -> Dictionary:
	var vs: Dictionary = _base_view_state()
	var react: String = _react_line(prev)
	vs["active_line"] = {"text": react + _t("VC_B2_LINE"),
		"speaker_tag": _speaker_tag(String(InvestorRegistry.get_investor(_vc_id).get("display_name", ""))),
		"is_monologue": false}
	vs["monologue_text"] = _t("VC_B2_MONO") if not _intel else ""
	vs["beat_label"] = _t("VC_BEAT2_LABEL")
	var favored: String = InvestorRegistry.favored_angle(_vc_id) if _intel else ""
	var out: Array = []
	for a in [["metrik", _t("VC_B2_METRIC")], ["vizyon", _t("VC_B2_VISION")], ["traction", _t("VC_B2_TRACTION")]]:
		var diff: int = int(InvestorRegistry.get_investor(_vc_id).get("weights", {}).get(a[0], PitchConstants.DIFF_ORTA))
		out.append({"id": "b2_" + a[0], "text": a[1], "odds_text": _odds(_t("VC_APPROACH_NARRATIVE"), _angle_skill(a[0]), diff, _beat2_bonus(a[0])), "marked": (a[0] == favored)})
	vs["choices"] = out
	return vs


static func _beat3_view_state(prev: Dictionary) -> Dictionary:
	var vs: Dictionary = _base_view_state()
	var react: String = _react_line(prev)
	vs["active_line"] = {"text": react + String(_sorgu.get("vc_line", "")),
		"speaker_tag": _speaker_tag(String(InvestorRegistry.get_investor(_vc_id).get("display_name", ""))),
		"is_monologue": false}
	vs["monologue_text"] = String(_sorgu.get("mono", ""))
	vs["beat_label"] = _t("VC_BEAT3_LABEL")
	var prova: bool = _prep_focus == "prova"
	vs["choices"] = [
		{"id": "b3_durust", "text": _t("VC_B3_HONEST"), "odds_text": _odds(_t("VC_APPROACH_HONEST"), PitchConstants.BEAT3_SKILL, PitchConstants.DURUST_DIFF, PitchConstants.PREP_BONUS if prova else 0), "caption": _t("VC_B3_HONEST_CAP"), "marked": prova, "marked_text": _t("VC_REHEARSED")},
		{"id": "b3_spin", "text": _t("VC_B3_SPIN"), "odds_text": _odds(_t("VC_APPROACH_SPIN"), PitchConstants.BEAT3_SKILL, PitchConstants.SPIN_DIFF, 0), "caption": _t("VC_B3_SPIN_CAP")},
		{"id": "b3_gecistir", "text": _t("VC_B3_DEFLECT"), "odds_text": _odds(_t("VC_APPROACH_DEFLECT"), PitchConstants.BEAT3_SKILL, PitchConstants.GECISTIR_DIFF, 0), "caption": _t("VC_B3_DEFLECT_CAP").format({"cap": PitchConstants.GECISTIR_CAP}), "caption_danger": true},
	]
	return vs


static func _beat4_view_state() -> Dictionary:
	var vs: Dictionary = _base_view_state()
	var inv: Dictionary = InvestorRegistry.get_investor(_vc_id)
	var tag: String = _speaker_tag(String(inv.get("display_name", "")))
	var zone_val: int = mini(_conviction, _cap)
	vs["beat_label"] = _t("VC_BEAT4_LABEL")
	if zone_val >= PitchConstants.WON_MIN:
		vs["active_line"] = {"text": _t("VC_B4_WIN_LINE"), "speaker_tag": tag, "is_monologue": false}
		vs["choices"] = [{"id": "b4_ack", "text": _t("VC_B4_WIN_CHOICE")}]
	elif zone_val < PitchConstants.ILIK_MIN:
		vs["active_line"] = {"text": _t("VC_B4_LOSS_LINE"), "speaker_tag": tag, "is_monologue": false}
		vs["monologue_text"] = _t("VC_B4_LOSS_MONO")
		vs["choices"] = [{"id": "b4_leave", "text": _t("VC_B4_LOSS_CHOICE")}]
	else:
		vs["active_line"] = {"text": _t("VC_B4_WARM_LINE"), "speaker_tag": tag, "is_monologue": false}
		vs["monologue_text"] = _t("VC_B4_WARM_MONO")
		if _reentry:
			vs["choices"] = [
				{"id": "b4_zorla", "text": _t("VC_B4_PUSH"), "odds_text": _odds(_t("VC_APPROACH_PUSH"), PitchConstants.BEAT4_PUSH_SKILL, PitchConstants.MASAYI_ZORLA_DIFF, 0), "caption": _t("VC_B4_PUSH_CAP"), "caption_danger": true},
				{"id": "b4_ret", "text": _t("VC_B4_QUIT"), "caption": _t("VC_B4_QUIT_CAP")},
			]
		else:
			vs["choices"] = [
				{"id": "b4_callback", "text": _t("VC_B4_CALLBACK"), "caption": _t("VC_B4_CALLBACK_CAP")},
				{"id": "b4_zorla", "text": _t("VC_B4_PUSH"), "odds_text": _odds(_t("VC_APPROACH_PUSH"), PitchConstants.BEAT4_PUSH_SKILL, PitchConstants.MASAYI_ZORLA_DIFF, 0), "caption": _t("VC_B4_PUSH_CAP"), "caption_danger": true},
			]
	return vs


static func _result_view_state(kind: String) -> Dictionary:
	var vs: Dictionary = _base_view_state()
	var tag: String = _speaker_tag(String(InvestorRegistry.get_investor(_vc_id).get("display_name", "")))
	var line := ""
	match kind:
		"callback": line = _t("VC_RES_CALLBACK")
		"zorla_win": line = _t("VC_RES_PUSH_WIN")
		"zorla_ret": line = _t("VC_RES_PUSH_LOSS")
		_: line = _t("VC_RES_DEFAULT")
	vs["active_line"] = {"text": line, "speaker_tag": tag, "is_monologue": false}
	vs["beat_label"] = _t("VC_BEAT4_LABEL")
	vs["choices"] = [{"id": "b4_close", "text": _t("VC_B4_CLOSE")}]
	return vs


# ============================================================================
# Beat-3 domain interrogation (canon §4 Beat 3, domain amendment)
# ============================================================================

static func _pick_sorgu_target() -> Dictionary:
	# Worst item WITHIN this VC's domain (per-domain priority). Clean domain → payoff.
	match InvestorRegistry.get_investor(_vc_id).get("domain", ""):
		"metrics": return _sorgu_metrics()
		"team": return _sorgu_team()
		"narrative": return _sorgu_narrative()
		"product": return _sorgu_product()
		_: return _clean_sorgu()


static func _sorgu_metrics() -> Dictionary:
	# WORKING PROXY: no churn/concentration fields yet — inferred from run counters + MRR.
	if GameState.run_customers_lost > 0:
		return {"key": "churn", "vc_line": _t("VC_Q_CHURN"), "mono": _t("VC_Q_CHURN_MONO")}
	if GameState.mrr < PitchConstants.SEED_MRR_REFERENCE:
		return {"key": "growth_flat", "vc_line": _t("VC_Q_GROWTH"), "mono": _t("VC_Q_GROWTH_MONO")}
	if _b2b_concentration():
		return {"key": "concentration", "vc_line": _t("VC_Q_CONCENTRATION"), "mono": _t("VC_Q_CONCENTRATION_MONO")}
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
	# WORKING PROXY: rival lead + refused-acquisition inferred from registry/flags.
	if _rival_ahead():
		return {"key": "rival", "vc_line": _t("VC_Q_RIVAL"), "mono": _t("VC_Q_RIVAL_MONO")}
	if GameState.get_flag("acquisition_offer_rejected", false):   # LOC-DATA run flag id
		return {"key": "refused_acq", "vc_line": _t("VC_Q_REFUSED_ACQ"), "mono": _t("VC_Q_REFUSED_ACQ_MONO")}
	if GameState.reputation < 0:
		return {"key": "reputation", "vc_line": _t("VC_Q_REPUTATION"), "mono": _t("VC_Q_REPUTATION_MONO")}
	return _clean_sorgu()


static func _sorgu_product() -> Dictionary:
	if int(GameState.get_flag("mvp_live_bug_count", GameState.get_flag("mvp_bug_count_at_launch", 0))) > 0:
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


static func _angle_skill(angle: String) -> String:
	# SKILL-RENAME: routing lives in PitchConstants.ANGLE_SKILL (vizyon reads Nüfuz,
	# everything else — metrik/traction — reads Satış).
	return String(PitchConstants.ANGLE_SKILL.get(angle, "sales"))


static func _beat2_bonus(angle: String) -> int:
	if _prep_focus == "rakamlar" and angle == "metrik":
		return PitchConstants.PREP_BONUS
	if _prep_focus == "hikaye" and angle == "vizyon":
		return PitchConstants.PREP_BONUS
	return 0


static func _posture_diff(posture: String) -> int:
	match posture:
		"durust": return PitchConstants.DURUST_DIFF
		"spin": return PitchConstants.SPIN_DIFF
		_: return PitchConstants.GECISTIR_DIFF


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
		"bugs_under": return int(GameState.get_flag("mvp_live_bug_count", GameState.get_flag("mvp_bug_count_at_launch", 0))) < int(cb.get("target", 0))
		"first_engineer": return CharacterRegistry.count_developers() >= 1
		"scandal_resolved": return not GameState.unmanaged_major_scandal
		_: return false


## The weakest quality axis, as an ID ("innovation" / "stability" / "experience") or "".
## It used to return the Turkish LABEL, because the dictionary it scanned was keyed by
## display name — so a translated string was carrying identity, which the law forbids
## ("store ids, render at display time"). The caller localizes it now.
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


# ============================================================================
# Synthetic scheduled scenes (EndingsSystem pattern)
# ============================================================================

static func _build_meeting_prompt_event(vc_id: String) -> GameEvent:
	var inv: Dictionary = InvestorRegistry.get_investor(vc_id)
	var ev := GameEvent.new()
	ev.id = MEETING_PROMPT_ID
	ev.category = "reactive"
	ev.title = _t("VC_EV_MEETING_TITLE").format({"investor": inv.get("display_name", "")})
	ev.subtitle = ""
	ev.illustration_path = ""
	ev.character_id = "char_mentor_frank"
	ev.body_text = _t("VC_EV_MEETING_BODY").format({
		"investor": inv.get("display_name", ""), "line": inv.get("archetype_line", "")})
	ev.cooldown_days = 0
	ev.one_shot = false
	ev.priority = 10
	ev.tags = ["build_safe", "endgame"]
	ev.trigger_conditions = []
	var go := EventChoice.new()
	go.label = _t("VC_EV_ENTER_MEETING")
	go.modifiers = [{"type": "start_vc_meeting", "vc_id": vc_id}]
	var skip := EventChoice.new()
	skip.label = _t("VC_EV_SKIP_MEETING")
	skip.modifiers = [{"type": "decline_vc_meeting"}]
	var choices: Array[EventChoice] = []
	choices.append(go)
	choices.append(skip)
	ev.choices = choices
	return ev


static func _build_expiry_warning_event(vc_id: String, days: int) -> GameEvent:
	var inv: Dictionary = InvestorRegistry.get_investor(vc_id)
	var ev := GameEvent.new()
	ev.id = SHEET_WARN_ID
	ev.category = "reactive"
	ev.title = _t("VC_EV_OFFER_EXPIRING_TITLE")
	ev.subtitle = ""
	ev.character_id = "char_mentor_frank"
	ev.body_text = _t("VC_EV_OFFER_EXPIRING_BODY").format(
		{"investor": inv.get("display_name", ""), "days": days})
	ev.cooldown_days = 0
	ev.one_shot = false
	ev.priority = 9
	ev.tags = ["build_safe", "endgame"]
	ev.trigger_conditions = []
	var ack := EventChoice.new()
	ack.label = _t("VC_EV_ACK")
	ack.modifiers = []
	var wchoices: Array[EventChoice] = []
	wchoices.append(ack)
	ev.choices = wchoices
	return ev


static func _build_d179_event() -> GameEvent:
	var ev := GameEvent.new()
	ev.id = D179_ID
	ev.category = "reactive"
	ev.title = _t("VC_EV_LAST_DAY_TITLE")
	ev.subtitle = ""
	ev.character_id = "char_mentor_frank"
	ev.body_text = _t("VC_EV_LAST_DAY_BODY")
	ev.cooldown_days = 0
	ev.one_shot = false
	ev.priority = 10
	ev.tags = ["build_safe", "endgame"]
	ev.trigger_conditions = []
	var ack := EventChoice.new()
	ack.label = _t("VC_EV_ACK")
	ack.modifiers = []
	var dchoices: Array[EventChoice] = []
	dchoices.append(ack)
	ev.choices = dchoices
	return ev


static func _reset() -> void:
	_active = false
	_vc_id = ""
	_beat = 0
	_conviction = 0
	_cap = 100
	_intel = false
	_first_check_done = false
	_prep_focus = ""
	_reentry = false
	_sorgu = {}
	_pending_outcome = ""


## Shorthand for TranslationServer.translate. This file is 60-odd STATIC functions, and a
## static func has no Object, so tr() would compile here and then die at run time.
static func _t(key: String) -> String:
	return TranslationServer.translate(key)


## "Kaplan Yatırım — Canlı" / "Kaplan Ventures — Live".
static func _speaker_tag(display_name: String) -> String:
	return _t("VC_SPEAKER_LIVE").format({"name": display_name})
