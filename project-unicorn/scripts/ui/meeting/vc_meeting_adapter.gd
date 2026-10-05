class_name VcMeetingAdapter
extends RefCounted

# A seed or Series A pitch as the meeting panel's steps. VCPitchSystem rolls and writes; this reads
# each view it hands back and says who at the table speaks it, what the founder did, how the room
# took it, what each option risks and, at the end, what the sitting left behind.
#
# Seats are the fund's people in CounterpartSystem order. The lead opens and closes the room, the
# partner asks for the story and answers it, and the interrogation comes from whoever owns the
# fund's subject: the analyst for metrics and product, the partner for team and narrative and in
# the seed room, which does not audit.
#
# Reading the room (beat 1) is silent: the investor cannot see it, so it is the founder's inner
# line and nobody at the table reacts.

const LEAD := 1
const PARTNER := 2
const ANALYST := 3
## How the one who asked takes a roll, by its SkillCheck margin band. The pen falls from the
## note-taker's hand whoever asked.
const BAND_GESTURES := {
	"crit_success": ["lean", "nod"],
	"success": ["nod"],
	"near_pass": ["notes"],
	"near_miss": ["watch"],
	"fail": ["back"],
	"crit_fail": ["pen"],
}
## The lead's face at the closing verdict, by TUTUM band; under lukewarm they check the watch.
const VERDICT_GESTURES := {"warm": "lean", "lukewarm": "back"}

var _view: Dictionary        # the view on screen
var _vc_id: String
var _seed: bool
var _beat := 1
var _asker: int              # the seat the interrogation comes from
var _first_band: String      # TUTUM at the door, for the result's relationship row


func _init(view_state: Dictionary) -> void:
	_view = view_state
	_vc_id = view_state.vc_id
	_seed = view_state.stage == PitchConstants.STAGE_SEED
	var domain: String = InvestorRegistry.get_investor(_vc_id).get("domain", "")
	_asker = ANALYST if not _seed and domain in ["metrics", "product"] else PARTNER
	_first_band = _band(view_state)


func start() -> Dictionary:
	var cast := []
	var people := CounterpartSystem.investor_people(_vc_id)
	for i in people.size():
		var p: Dictionary = people[i]
		cast.append({"seat": i + 1, "name": p.name, "role": CounterpartSystem.title(p, _vc_id), "look": p.look})
	var step := _beat_step(_view)
	step.merge({"company": _view.speaker_name, "cast": cast, "memory": tr(_view.memory_key),
		"entries": _lines(_view)})
	return step


func pick(id: String) -> Dictionary:
	var choice: Dictionary = {}
	for c: Dictionary in _view.choices:
		if c.id == id:
			choice = c
	var asked := _speaker(_beat)
	var res := VCPitchSystem.advance(id)
	var chk: Dictionary = res.check
	var vs: Dictionary = res.view_state
	var entries := []
	var gestures := []
	if _beat == 1:
		entries.append({"kind": "quiet", "text": choice.text})
	else:
		entries.append({"kind": "founder", "text": choice.text,
			"pill": choice.get("check", {}).get("approach", "")})
		for g: String in BAND_GESTURES.get(chk.get("band", ""), []):
			gestures.append({"seat": MeetingCast.PEN_PERSON if g == "pen" else asked, "name": g})
	_beat += 1
	if _beat == 4:
		gestures.append({"seat": LEAD, "name": VERDICT_GESTURES.get(_band(vs), "watch")})
	var step := _beat_step(vs)
	entries.append_array(_lines(vs))
	step.merge({"entries": entries, "gestures": gestures,
		"roll": {} if chk.is_empty() else {"passed": chk.passed}})
	_view = vs
	return step


## Devam on the result card: the sitting closes as the room left it.
func proceed() -> Dictionary:
	VCPitchSystem.advance("b4_close")
	return {"closed": true}


## Beat 1 only. The system closes the sitting on the spot, so no card stays up: with the sitting
## closed, a save could land before end_sitting runs its clock.
func withdraw() -> Dictionary:
	VCPitchSystem.withdraw()
	return {"closed": true}


func end_sitting() -> void:
	VCPitchSystem.end_sitting()


func _speaker(beat: int) -> int:
	match beat:
		2: return PARTNER
		3: return _asker
	return LEAD


## The seed room's bands sit on the Series A room's edges (SeedConstants.BAND_*_MIN).
func _band(vs: Dictionary) -> String:
	return UiTokens.attitude_band(int(vs.conviction.value), PitchConstants.WON_MIN, PitchConstants.ILIK_MIN)


func _beat_step(vs: Dictionary) -> Dictionary:
	var band := _band(vs)
	var step := {
		"kicker": tr("MEETING_KICKER_SEED" if _seed else "MEETING_KICKER_VC"),
		"beat": vs.beat_label,
		"speaker": _speaker(_beat),
		"attitude": {"value": int(vs.conviction.value), "word_key": UiTokens.attitude_word_key(band),
			"band": band, "odds_text": "", "hover": [],
			"edges": [UiTokens.ATTITUDE_WARY_MIN, PitchConstants.ILIK_MIN, PitchConstants.WON_MIN]},
		"can_withdraw": vs.can_withdraw,
		"options": [],
	}
	if vs.has("result_kind"):
		step.result = _result(vs)
		step.continue_key = "MEETING_CONTINUE"
		return step
	for c: Dictionary in vs.choices:
		var chk: Dictionary = c.get("check", {})
		step.options.append({"id": c.id, "label": c.text, "sub": c.get("caption", ""),
			"sub_danger": c.get("caption_danger", false),
			"marker": c.marked_text if c.get("marked", false) else "",
			"dice": {} if chk.is_empty() else _dice(chk)})
	return step


## What the other side says in a view. A reaction to the story comes from the partner before the
## question; the founder's inner voice follows, and on a rejection Frank's word on the way out.
func _lines(vs: Dictionary) -> Array:
	var out := []
	if vs.get("reaction_line", "") != "":
		out.append({"kind": "counterpart", "seat": PARTNER, "text": vs.reaction_line})
	if vs.active_line != "":
		out.append({"kind": "counterpart", "seat": _speaker(_beat), "text": vs.active_line})
	if vs.get("monologue_text", "") != "":
		out.append({"kind": "quiet", "text": vs.monologue_text})
	if vs.get("frank_line", "") != "":
		out.append({"kind": "frank", "text": vs.frank_line})
	return out


## The option's die as chips over the terms SkillCheck sums: the founder's skill when it adds
## anything, the prep that earned a bonus, and the room's difficulty, which always takes away.
func _dice(chk: Dictionary) -> Dictionary:
	var factors := []
	if chk.skill_value > 0:
		factors.append({"cat_key": "MEETING_CHIP_SKILL", "text": FounderConstants.skill_label(chk.skill),
			"sign": "+", "tone": "pos"})
	if chk.prep != "":
		factors.append({"cat_key": "MEETING_CHIP_PREP", "text": tr(PitchConstants.FOCUS_KEYS[chk.prep]),
			"sign": "+", "tone": "pos"})
	factors.append({"cat_key": "MEETING_CHIP_ROOM", "text": PitchConstants.diff_label(chk.difficulty),
		"sign": "−", "tone": "neutral" if chk.difficulty == PitchConstants.DIFF_KOLAY else "neg"})
	return {"risk_key": UiTokens.risk_key(chk.chance), "chance": chk.chance, "factors": factors}


## The card reads what the room wrote: the fund's status, and the line it closed on (a won or cold
## room's beat-4 line was its last word, so the result view carries none). A queued sheet's
## validity starts only when a slot frees, and a rejection costs morale only where someone works.
func _result(vs: Dictionary) -> Dictionary:
	var kind: String = vs.result_kind
	var card := {"band": "positive", "title_key": "MEETING_RES_OFFER"}
	var effect: String
	if kind.begins_with("seed_"):
		effect = tr("SEED_OFFER_TERMS").format({"band": tr("SEED_BAND_" + kind.trim_prefix("seed_").to_upper())})
	else:
		var st: Dictionary = GameState.vc_states[_vc_id]
		effect = tr("HUNT_BADGE_" + String(st.status).to_upper())
		var more := ""
		match String(st.status):
			"rejected":
				card = {"band": "negative", "title_key": "MEETING_RES_NO"}
				more = tr("MEETING_RES_COST_BRAND" if CharacterRegistry.get_employees().is_empty() \
					else "MEETING_RES_COST").format({"brand": PitchConstants.REJECT_BRAND_COST,
					"morale": PitchConstants.REJECT_MORALE_COST})
			"callback":
				card = {"band": "accent", "title_key": "MEETING_RES_CALLBACK"}
				more = tr("HUNT_CONDITION").format({"condition": VCPitchSystem.callback_text(st.callback)})
			"offered":
				more = tr("MEETING_RES_VALID").format({"weeks": PitchConstants.SHEET_VALIDITY_WEEKS})
		if more != "":
			effect = tr("MEETING_RES_PAIR").format({"first": effect, "second": more})
	card.merge({"effect": effect,
		"relation": {"name": CounterpartSystem.lead(_vc_id).name, "from": _first_band, "to": _band(vs)},
		"memory": vs.active_line if vs.active_line != "" else _view.active_line})
	return card
