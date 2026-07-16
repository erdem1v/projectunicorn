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
	why.append({"d": mrr_delta, "l": "MRR güçlü" if mrr_delta >= 0 else "MRR zayıf"})

	# Brand distance to floor.
	var brand_delta: int = clampi(int(round((GameState.brand - PitchConstants.SEED_BRAND_FLOOR) * 0.4)), -PitchConstants.SEED_BRAND_MAX, PitchConstants.SEED_BRAND_MAX)
	v += brand_delta
	why.append({"d": brand_delta, "l": "Marka sağlam" if brand_delta >= 0 else "Marka düşük"})

	# Runway health.
	if GameState.shutter_days_left >= 0:
		v += PitchConstants.SEED_SHUTTER_PENALTY
		why.append({"d": PitchConstants.SEED_SHUTTER_PENALTY, "l": "Kepenk sayacı"})
	elif _gross_runway_months() < 1.0:
		v += PitchConstants.SEED_THIN_RUNWAY_PENALTY
		why.append({"d": PitchConstants.SEED_THIN_RUNWAY_PENALTY, "l": "Runway dar"})

	if GameState.unmanaged_major_scandal:
		v += PitchConstants.SEED_SCANDAL_PENALTY
		why.append({"d": PitchConstants.SEED_SCANDAL_PENALTY, "l": "Skandal izi"})
	if not GameState.active_sheets.is_empty():
		v += PitchConstants.SEED_LEVERAGE_BONUS
		why.append({"d": PitchConstants.SEED_LEVERAGE_BONUS, "l": "Cebinde teklif"})
	if inv.get("warm_intro", false):
		v += PitchConstants.SEED_WARM_INTRO_BONUS
		why.append({"d": PitchConstants.SEED_WARM_INTRO_BONUS, "l": "Frank'in tanıştırması"})
	if inv.get("domain", "") == "product" and GameState.get_flag("mvp_shipped", false):
		v += PitchConstants.SEED_DIMENSION_MATCH_BONUS
		why.append({"d": PitchConstants.SEED_DIMENSION_MATCH_BONUS, "l": "Sektör eşleşmesi"})
	if _vc(vc_id).get("reentry_bonus", false):
		v += PitchConstants.SEED_CALLBACK_BONUS
		why.append({"d": PitchConstants.SEED_CALLBACK_BONUS, "l": "Kapı yeniden açık"})

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
	EndingsSystem.trigger_ending("series_a_close", _sign_extra(vc_id, terms))


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
		return "Zaten bir hazırlık sürüyor"
	if GameState.pending_meeting.get("vc_id", "") != vc_id:
		return "Önce bu VC'yle toplantı iste"
	var days_before: int = int(GameState.pending_meeting.get("day", 0)) - GameState.day
	if days_before < PitchConstants.PREP_MIN_DAYS_BEFORE:
		return "Toplantıya %d günden az kaldı" % PitchConstants.PREP_MIN_DAYS_BEFORE
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
			EventBus.mentor_advisory_changed.emit("Kapı yeniden açıldı — %s. Tekrar iste." % inv.display_name)


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
		"stat_strip": {"left_text": "Kasa: %s · %s: %d ay · Gün %d" % [UiTokens.format_money(GameState.cash), TranslationServer.translate("RUNWAY_GROSS_LABEL"), int(floor(_gross_runway_months())), GameState.day]},
		"can_withdraw": false,
	}


static func _beat1_view_state(why: Array) -> Dictionary:
	var inv: Dictionary = InvestorRegistry.get_investor(_vc_id)
	var vs: Dictionary = _base_view_state()
	vs["active_line"] = {"text": "\"%s. Otur. Vaktim kısa — beni neden buraya çağırdığını göster.\"" % inv.get("display_name", ""), "speaker_tag": "%s — Canlı" % inv.get("display_name", ""), "is_monologue": false}
	vs["monologue_text"] = ("Odayı oku: " + " · ".join(PackedStringArray(why))) if not why.is_empty() else "Odayı oku."
	vs["beat_label"] = "Odayı Oku · 1/4"
	vs["can_withdraw"] = true                       # only before the first check (ledger)
	vs["choices"] = [{"id": "b1_read", "text": "Odayı oku — karşındakini tart.", "odds_text": _odds("Algı", PitchConstants.BEAT1_SKILL, PitchConstants.BEAT1_DIFF, 0)}]
	return vs


static func _beat2_view_state(prev: Dictionary) -> Dictionary:
	var vs: Dictionary = _base_view_state()
	var react: String = _react_line(prev)
	vs["active_line"] = {"text": "%s\"Tamam. Anlat bakalım — neden sen, neden şimdi?\"" % react, "speaker_tag": "%s — Canlı" % InvestorRegistry.get_investor(_vc_id).get("display_name", ""), "is_monologue": false}
	vs["monologue_text"] = "Açı seç. Yanlış açı beni sıkar." if not _intel else ""
	vs["beat_label"] = "Anlatı · 2/4"
	var favored: String = InvestorRegistry.favored_angle(_vc_id) if _intel else ""
	var out: Array = []
	for a in [["metrik", "Metrik: rakamlar konuşsun."], ["vizyon", "Vizyon: nereye gittiğimizi göster."], ["traction", "Traction: ivmeyi anlat."]]:
		var diff: int = int(InvestorRegistry.get_investor(_vc_id).get("weights", {}).get(a[0], PitchConstants.DIFF_ORTA))
		out.append({"id": "b2_" + a[0], "text": a[1], "odds_text": _odds("Anlatı", _angle_skill(a[0]), diff, _beat2_bonus(a[0])), "marked": (a[0] == favored)})
	vs["choices"] = out
	return vs


static func _beat3_view_state(prev: Dictionary) -> Dictionary:
	var vs: Dictionary = _base_view_state()
	var react: String = _react_line(prev)
	vs["active_line"] = {"text": "%s%s" % [react, _sorgu.get("vc_line", "")], "speaker_tag": "%s — Canlı" % InvestorRegistry.get_investor(_vc_id).get("display_name", ""), "is_monologue": false}
	vs["monologue_text"] = String(_sorgu.get("mono", ""))
	vs["beat_label"] = "Sorgu · 3/4"
	var prova: bool = _prep_focus == "prova"
	vs["choices"] = [
		{"id": "b3_durust", "text": "Dürüst: kabul et, planı göster.", "odds_text": _odds("Dürüst", PitchConstants.BEAT3_SKILL, PitchConstants.DURUST_DIFF, PitchConstants.PREP_BONUS if prova else 0), "caption": "Düşük risk, dürüst duruş.", "marked": prova, "marked_text": "PROVA EDİLDİ"},
		{"id": "b3_spin", "text": "Spin: zayıflığı güce çevir.", "odds_text": _odds("Spin", PitchConstants.BEAT3_SKILL, PitchConstants.SPIN_DIFF, 0), "caption": "Yüksek risk, yüksek getiri."},
		{"id": "b3_gecistir", "text": "Geçiştir: konuyu kaydır.", "odds_text": _odds("Geçiştir", PitchConstants.BEAT3_SKILL, PitchConstants.GECISTIR_DIFF, 0), "caption": "Güvenli, ama masa buradan çıkmaz (%d tavan)." % PitchConstants.GECISTIR_CAP, "caption_danger": true},
	]
	return vs


static func _beat4_view_state() -> Dictionary:
	var vs: Dictionary = _base_view_state()
	var inv: Dictionary = InvestorRegistry.get_investor(_vc_id)
	var tag: String = "%s — Canlı" % inv.get("display_name", "")
	var zone_val: int = mini(_conviction, _cap)
	vs["beat_label"] = "Kapanış · 4/4"
	if zone_val >= PitchConstants.WON_MIN:
		vs["active_line"] = {"text": "\"Sana bir teklif göndereceğim. Beğenmeyebilirsin ama ciddi.\"", "speaker_tag": tag, "is_monologue": false}
		vs["choices"] = [{"id": "b4_ack", "text": "Teşekkürler. Bekliyorum."}]
	elif zone_val < PitchConstants.ILIK_MIN:
		vs["active_line"] = {"text": "\"Bugün olmadı. Rakamlar beni buraya getirmedi.\"", "speaker_tag": tag, "is_monologue": false}
		vs["monologue_text"] = "Soğuk oda. En azından nedenini biliyorsun."
		vs["choices"] = [{"id": "b4_leave", "text": "Anladım. Çıkıyorum."}]
	else:
		vs["active_line"] = {"text": "\"Kararsızım. Bir yol var: sana bir koşul koyayım, tuttur, geri gel. Ya da şansını burada zorla.\"", "speaker_tag": tag, "is_monologue": false}
		vs["monologue_text"] = "Ilık. Güvenli kapı mı, açgözlü kumar mı?"
		if _reentry:
			vs["choices"] = [
				{"id": "b4_zorla", "text": "Masayı zorla — şimdi karar ver.", "odds_text": _odds("Zorla", PitchConstants.BEAT4_PUSH_SKILL, PitchConstants.MASAYI_ZORLA_DIFF, 0), "caption": "Başarısızsan masa kapanır.", "caption_danger": true},
				{"id": "b4_ret", "text": "İkinci kez ılık. Bırak gitsin.", "caption": "Reddedilme sayılır."},
			]
		else:
			vs["choices"] = [
				{"id": "b4_callback", "text": "Callback'i kabul et — koşulu tuttur.", "caption": "Güvenli. Kapı açık kalır."},
				{"id": "b4_zorla", "text": "Masayı zorla — şimdi karar ver.", "odds_text": _odds("Zorla", PitchConstants.BEAT4_PUSH_SKILL, PitchConstants.MASAYI_ZORLA_DIFF, 0), "caption": "Başarısızsan masa kapanır.", "caption_danger": true},
			]
	return vs


static func _result_view_state(kind: String) -> Dictionary:
	var vs: Dictionary = _base_view_state()
	var tag: String = "%s — Canlı" % InvestorRegistry.get_investor(_vc_id).get("display_name", "")
	var line := ""
	match kind:
		"callback": line = "\"Koşulu biliyorsun. Tuttur, kapı açık.\""
		"zorla_win": line = "\"Cesaretin varmış. Teklif yolda.\""
		"zorla_ret": line = "\"Zorladın ve tutmadı. Kapı kapandı.\""
		_: line = "\"Bugün olmadı.\""
	vs["active_line"] = {"text": line, "speaker_tag": tag, "is_monologue": false}
	vs["beat_label"] = "Kapanış · 4/4"
	vs["choices"] = [{"id": "b4_close", "text": "Kapat."}]
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
		return {"key": "churn", "vc_line": "\"Churn'ün konuşuyor. Kaçan müşterileri anlat — neden gittiler?\"", "mono": "Churn'ü soracak. Sayıları hazırla."}
	if GameState.mrr < PitchConstants.SEED_MRR_REFERENCE:
		return {"key": "growth_flat", "vc_line": "\"Büyüme grafiği düz. Bu çizgiyi neden yukarı kaldıramadın?\"", "mono": "Büyümenin durgunluğunu görecek."}
	if _b2b_concentration():
		return {"key": "concentration", "vc_line": "\"Gelirin tek bir müşteriye yaslanıyor. O giderse ne kalır?\"", "mono": "Gelir yoğunlaşmasını soracak."}
	return _clean_sorgu()


static func _sorgu_team() -> Dictionary:
	if GameState.unmanaged_major_scandal:
		return {"key": "scandal", "vc_line": "\"Yönetemediğin bir skandal var. Ben neden bu ekibe para vereyim?\"", "mono": "Skandalı soracak. Sorduğunda gözünü kaçırma."}
	if CharacterRegistry.count_engineers() == 0:
		return {"key": "no_engineers", "vc_line": "\"Tek mühendisin bile yok. Bu ürünü kim taşıyacak?\"", "mono": "Ekibin inceliğini görecek."}
	if CharacterRegistry.get_employees().is_empty():
		return {"key": "solo", "vc_line": "\"Tek başınasın. Sen düşersen şirket de düşer. Bu riski nasıl kapatıyorsun?\"", "mono": "Tek-kurucu riskini soracak."}
	return _clean_sorgu()


static func _sorgu_narrative() -> Dictionary:
	# WORKING PROXY: rival lead + refused-acquisition inferred from registry/flags.
	if _rival_ahead():
		return {"key": "rival", "vc_line": "\"Bir rakip senden önde. Ligde ikinci olan neden kazansın?\"", "mono": "Rakibi masaya koyacak."}
	if GameState.get_flag("acquisition_offer_rejected", false):
		return {"key": "refused_acq", "vc_line": "\"Bir satın almayı geri çevirmişsin. Kibir mi, vizyon mu?\"", "mono": "Reddettiğin teklifi soracak."}
	if GameState.reputation < 0:
		return {"key": "reputation", "vc_line": "\"İtibarın zedeli. Bu hikâyeye kim inanır?\"", "mono": "İtibarını yoklayacak."}
	return _clean_sorgu()


static func _sorgu_product() -> Dictionary:
	if int(GameState.get_flag("mvp_live_bug_count", GameState.get_flag("mvp_bug_count_at_launch", 0))) > 0:
		return {"key": "bugs", "vc_line": "\"Ürünün hata kaynıyor. Kalite senin için ne ifade ediyor?\"", "mono": "Hata sayını soracak."}
	var weak: String = _weakest_dimension()
	if weak != "":
		return {"key": "weak_dim", "vc_line": "\"%s tarafın zayıf. Sektörü bilen biri bunu ilk bakışta görür.\"" % weak, "mono": "En zayıf ekseni bulacak."}
	return _clean_sorgu()


static func _clean_sorgu() -> Dictionary:
	return {"key": "clean", "vc_line": "\"Doğrusu, saldıracak bir yer bulamadım. Bu iyi bir işaret. Devam et.\"", "mono": "Temiz alan. Nefes al."}


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
	return "%s — %s · %%%d" % [label, PitchConstants.diff_label(diff), pct]


static func _react_line(chk: Dictionary) -> String:
	# Short VC reaction to the previous check (folded into the next line; inline resolution).
	match String(chk.get("band", "")):
		"crit_success", "success": return "\"İyi.\" "
		"near_pass": return "\"Hmm. İdare eder.\" "
		"near_miss", "fail", "crit_fail": return "\"Beni ikna etmedi.\" "
		_: return ""


static func _callback_met(cb: Dictionary) -> bool:
	match String(cb.get("type", "")):
		"mrr_growth": return GameState.mrr >= int(cb.get("target", 0))
		"bugs_under": return int(GameState.get_flag("mvp_live_bug_count", GameState.get_flag("mvp_bug_count_at_launch", 0))) < int(cb.get("target", 0))
		"first_engineer": return CharacterRegistry.count_engineers() >= 1
		"scandal_resolved": return not GameState.unmanaged_major_scandal
		_: return false


static func _weakest_dimension() -> String:
	var dims := {"İnovasyon": float(GameState.get_flag("mvp_innovation", 0.0)), "Kararlılık": float(GameState.get_flag("mvp_stability", 0.0)), "Kullanılabilirlik": float(GameState.get_flag("mvp_usability", 0.0))}
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
		if r.status == "DOMINANT":
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
	ev.title = "Toplantı zamanı — %s" % inv.get("display_name", "")
	ev.subtitle = ""
	ev.illustration_path = ""
	ev.character_id = "char_mentor_frank"
	ev.body_text = "Randevu günü geldi. %s masada.\n\n\"%s\"\n\nHazırsan gir. Hazır değilsen de gir — takvim beklemez." % [inv.get("display_name", ""), inv.get("archetype_line", "")]
	ev.cooldown_days = 0
	ev.one_shot = false
	ev.priority = 10
	ev.tags = ["build_safe", "endgame"]
	ev.trigger_conditions = []
	var go := EventChoice.new()
	go.label = "Toplantıya gir"
	go.modifiers = [{"type": "start_vc_meeting", "vc_id": vc_id}]
	var skip := EventChoice.new()
	skip.label = "Bugün değil (randevu yanar)"
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
	ev.title = "Teklifin süresi doluyor"
	ev.subtitle = ""
	ev.character_id = "char_mentor_frank"
	ev.body_text = "%s'in teklifi %d gün sonra yanıyor.\n\n\"Karar ver. Masaya otur ya da bırak — ama sallanma.\"" % [inv.get("display_name", ""), days]
	ev.cooldown_days = 0
	ev.one_shot = false
	ev.priority = 9
	ev.tags = ["build_safe", "endgame"]
	ev.trigger_conditions = []
	var ack := EventChoice.new()
	ack.label = "Anlaşıldı"
	ack.modifiers = []
	var wchoices: Array[EventChoice] = []
	wchoices.append(ack)
	ev.choices = wchoices
	return ev


static func _build_d179_event() -> GameEvent:
	var ev := GameEvent.new()
	ev.id = D179_ID
	ev.category = "reactive"
	ev.title = "Yarın son gün"
	ev.subtitle = ""
	ev.character_id = "char_mentor_frank"
	ev.body_text = "Frank kapıda.\n\n\"Yarın son gün. Cebinde teklif var. İmzalayacaksan bugün imzala.\""
	ev.cooldown_days = 0
	ev.one_shot = false
	ev.priority = 10
	ev.tags = ["build_safe", "endgame"]
	ev.trigger_conditions = []
	var ack := EventChoice.new()
	ack.label = "Anlaşıldı"
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
