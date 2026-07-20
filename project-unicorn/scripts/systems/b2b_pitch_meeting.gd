class_name B2BPitchMeeting
extends RefCounted

# View-adapter: renders the B2B sales pitch (PitchSystem) into the shared MeetingScene —
# the same data-driven dialogue view the VC pitch uses. Pure PRESENTATION; it owns NO
# pitch logic. Every decision (the 4 beats, SkillCheck reads Satış/Nüfuz, price anchor,
# outcomes SIGNED/CALLBACK/LOST, MRR/seat economics) stays in
# PitchSystem.begin/get_stage/choose/_resolve_outcome, called exactly as the retired
# PitchDialogueModal called them — an OUTCOME-INVARIANT migration.
#
# Register: routine business, not the VC ceremony — NO conviction dial and NO patience/
# stat strip (both omitted from view_state, so MeetingScene auto-hides them). The customer
# rep speaks; Frank never speaks here.
#
# The _check_line / _result_text / _result_inner voice strings are ported VERBATIM from
# the retired modal (view text, not logic) — including their existing em-dashes, which
# match the untouched pitch content in pitch_system.gd; an em-dash/voice pass across the
# whole B2B pitch is a separate follow-up.

const CHOICE_PREFIX := "c"

static var _active: bool = false
static var _prospect: Prospect = null
static var _rep_id: String = ""
static var _result: Dictionary = {}


static func is_active() -> bool:
	return _active


# --- Entry: begin the pitch and emit the first beat's view_state (the generic
#     main.gd mount handler pauses + shows it — no mount code here). ---
static func begin_meeting(prospect_id: String) -> void:
	if not PitchSystem.begin(prospect_id):
		EventBus.pitch_finished.emit()
		return
	_prospect = ProspectRegistry.get_prospect(prospect_id)  # held ref survives SIGNED removal
	_result = {}
	_active = true
	_rep_id = _assign_rep(_prospect)
	EventBus.meeting_scene_requested.emit(_stage_view_state(PitchSystem.get_stage(), {}))


# --- Beat driver. Returns {done:true} to close, or {done:false, view_state:{...}} to
#     re-populate the same scene in place (mirrors VCPitchSystem.advance). ---
static func advance(choice_id: String) -> Dictionary:
	if not _active:
		return {"done": true}
	# Result screen: the only choice ("Devam") closes.
	if not _result.is_empty():
		_finish()
		return {"done": true}
	var res: Dictionary = PitchSystem.choose(_idx_of(choice_id))
	if res.get("done", false):
		_result = res.get("result", {})
		return {"done": false, "view_state": _result_view_state(_result)}
	return {"done": false, "view_state": _stage_view_state(PitchSystem.get_stage(), res.get("check", {}))}


static func withdraw() -> void:
	# Defensive: B2B pitches set can_withdraw=false, so this is normally unreachable.
	_finish()


static func _finish() -> void:
	_active = false
	_prospect = null
	_result = {}
	_rep_id = ""
	EventBus.pitch_finished.emit()  # sales_tab / hunt_tab repaint on this


# --- View-state builders (the MeetingScene contract) ---

static func _stage_view_state(stage: Dictionary, check: Dictionary) -> Dictionary:
	var choices: Array = []
	var raw: Array = stage.get("choices", [])
	for i in raw.size():
		choices.append({"id": "%s%d" % [CHOICE_PREFIX, i], "text": String((raw[i] as Dictionary).get("label", "—"))})
	return {
		"background_path": B2BConstants.sector_room(_industry()),
		"portrait_path": FounderConstants.portrait_path(_rep_id),
		"speaker_name": _company(),
		"speaker_role": B2BConstants.sector_contact(_industry()),
		"active_line": {"text": String(stage.get("npc", "")), "speaker_tag": "", "is_monologue": false},
		"monologue_text": _monologue(stage, check),
		"choices": choices,
		"beat_label": _beat_label(String(stage.get("id", ""))),
		"can_withdraw": false,
	}


static func _result_view_state(result: Dictionary) -> Dictionary:
	var outcome: String = String(result.get("outcome", "LOST"))
	return {
		"background_path": B2BConstants.sector_room(_industry()),
		"portrait_path": FounderConstants.portrait_path(_rep_id),
		"speaker_name": _company(),
		"speaker_role": B2BConstants.sector_contact(_industry()),
		"active_line": {"text": _result_text(outcome, result), "speaker_tag": "", "is_monologue": false},
		"monologue_text": _result_inner(outcome),
		"choices": [{"id": "done", "text": "Devam"}],
		"beat_label": _outcome_label(outcome),
		"can_withdraw": false,
	}


static func _monologue(stage: Dictionary, check: Dictionary) -> String:
	# The founder's read, folded into the dim monologue area: the prior beat's check
	# result (rendered on the NEXT beat, exactly as the modal did), the sales-read reveal,
	# then the interior line.
	var parts: Array = []
	var band: String = _check_line(check)
	var reveal: String = String(stage.get("reveal", ""))
	var inner: String = String(stage.get("inner", ""))
	if band != "":
		parts.append(band)
	if reveal != "":
		parts.append(reveal)
	if inner != "":
		parts.append(inner)
	return "\n\n".join(parts)


# --- Customer-rep portrait: sequential rotation over the NON-selected founder portraits,
#     persisted per-prospect (survives a CALLBACK re-meeting), no consecutive repeat. ---
static func _assign_rep(p: Prospect) -> String:
	if p != null and p.rep_portrait_id != "":
		GameState.b2b_last_rep_portrait = p.rep_portrait_id  # identity wins; record as shown
		return p.rep_portrait_id
	var pool: Array = []
	for pid in FounderConstants.PORTRAIT_IDS:
		if pid != GameState.founder_portrait:
			pool.append(pid)
	if pool.is_empty():
		pool = FounderConstants.PORTRAIT_IDS.duplicate()
	var idx: int = GameState.b2b_rep_portrait_rotation_index % pool.size()
	var chosen: String = String(pool[idx])
	# No consecutive repeat for a NEW assignment: if the sequential pick equals the last
	# face shown, take the next one.
	if chosen == GameState.b2b_last_rep_portrait and pool.size() > 1:
		idx = (idx + 1) % pool.size()
		chosen = String(pool[idx])
		GameState.b2b_rep_portrait_rotation_index += 1
	GameState.b2b_rep_portrait_rotation_index += 1
	GameState.b2b_last_rep_portrait = chosen
	if p != null:
		p.rep_portrait_id = chosen
	return chosen


static func _company() -> String:
	return _prospect.company_name if _prospect != null else ""


static func _industry() -> String:
	return _prospect.industry if _prospect != null else ""


static func _idx_of(choice_id: String) -> int:
	if choice_id.begins_with(CHOICE_PREFIX):
		return int(choice_id.trim_prefix(CHOICE_PREFIX))
	return 0


# --- Beat / outcome labels (new working TR — flag for Erdem's voice pass) ---

static func _beat_label(stage_id: String) -> String:
	match stage_id:
		"intro": return "AÇILIŞ"
		"value": return "İTİRAZ"
		"pricing": return "PAZARLIK"
		"close": return "KAPANIŞ"
		_: return "GÖRÜŞME"


static func _outcome_label(outcome: String) -> String:
	match outcome:
		"SIGNED": return "İMZA"
		"CALLBACK": return "GERİ DÖNÜŞ"
		_: return "KAPANDI"


# --- Voice helpers (ported VERBATIM from the retired PitchDialogueModal) ---

static func _check_line(check: Dictionary) -> String:
	match String(check.get("band", "")):
		"crit_success": return "→ Tam isabet. Onu yakaladın."
		"success": return "→ İyi gitti."
		"near_pass": return "→ Kıl payı tuttu."
		"near_miss": return "→ Az kalsın — kaçırdın."
		"fail", "crit_fail": return "→ Tutmadı. Hava soğudu."
		_: return ""


static func _result_text(outcome: String, result: Dictionary) -> String:
	var company: String = String(result.get("company", "Müşteri"))
	match outcome:
		"SIGNED":
			return "%s imzaladı. Aylık $%d. İlk gerçek müşterin." % [company, int(result.get("mrr", 0))]
		"CALLBACK":
			return "%s 'düşünüp döneceğim' dedi. Pipeline'da kaldı — tekrar deneyebilirsin." % company
		_:
			return "%s bu sefer olmadı. Kapı kapandı." % company


static func _result_inner(outcome: String) -> String:
	match outcome:
		"SIGNED": return "Biri, yaptığın şeye para verdi. Küçük ama gerçek."
		"CALLBACK": return "'Düşüneceğim' — satışın en kaygan cümlesi. Ama kapı tam kapanmadı."
		_: return "Olmadı. Frank ne der bilmiyorum ama bir sonraki var."
