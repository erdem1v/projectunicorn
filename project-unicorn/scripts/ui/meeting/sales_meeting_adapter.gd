class_name SalesMeetingAdapter
extends RefCounted

# A sales sitting as the meeting panel's steps: the first act's persuasion (SalesMeetingSystem)
# and, on a won table, the price (NegotiationSystem) in the same dock. The systems decide and
# write; this reads each view they hand back and says who speaks it, what the founder answered,
# how the needle moved and, at the end, what the table left behind.
#
# THE TABLE IS READ AT THE DOOR. A lost first act removes the prospect before its closing view is
# built, so the company, its people and its identity are taken from the prospect here, once.
#
# The questions go round the table in seat order; the buyer (seat 1) closes. The needle stays
# quiet: its word and percent on the header, its reasons on hover, no verdict per answer.
#
# THE PRICE ACT HAS NO SPEECH. Its transcript takes only the numbers, the founder's offer and the
# customer's counter, as state rows; the rest is the ruler, the patience boxes and the tone of the
# offer button.

const LEAD := 1
const SKIP := "skip"
## Edge of the lukewarm TUTUM word. The needle has no rule edge between its two cuts, so this
## is a word only; the warm edge is the cut to the price act (SalesConstants.CUT_HIGH).
const LUKEWARM_MIN := 40   # WORKING
## An answer that moves the needle by this share of an answer's full weight or more earns a nod;
## less, a note. [WORKING]
const NOD_SHARE := 0.5
## A modifier line's seam → the chip category it shows under on the die's tooltip.
const CHIP_BY_SEAM := {
	"hr.effective_skill": "MEETING_CHIP_SKILL",
	"founder.charisma": "MEETING_CHIP_SKILL",
	"urun.axis_reading": "MEETING_CHIP_PREP",
	"urun.capacity_tier": "MEETING_CHIP_PREP",
	"sales.price_stance": "MEETING_CHIP_PREP",
	"sales.reach_band": "MEETING_CHIP_ROOM",
	"sales.answer": "MEETING_CHIP_ROOM",
	"sales.loss_reason": "MEETING_CHIP_MEMORY",
}
## EvDice.modifier_lines' sign → the chip's sign and tone; the folded "and more" line has none.
const CHIP_SIGNS := {"▲": ["+", "pos"], "▼": ["−", "neg"]}

var _prospect: Prospect
var _people: Array
var _view: Dictionary        # the first act's view on screen, then its last
var _open_band: String       # TUTUM at the door, for the result's relationship row
var _at_table := false       # the price act is open


## Reads only the prospect, so it can be built before SalesMeetingSystem.open, which may already
## lose the table and remove the prospect.
func _init(prospect_id: String) -> void:
	_prospect = ProspectRegistry.get_prospect(prospect_id)
	_people = CounterpartSystem.prospect_people(_prospect)


func start() -> Dictionary:
	var vs := SalesMeetingSystem.view_state()
	_open_band = _band(vs.odds)
	var cast := []
	for i in _people.size():
		var p: Dictionary = _people[i]
		cast.append({"seat": i + 1, "name": p.name, "role": CounterpartSystem.title(p), "look": p.look})
	var whale := _prospect.whale_condition
	var step := {
		"kicker": tr("MEETING_KICKER_SALES"),
		"company": _prospect.company_name,
		"cast": cast,
		"identity": {"stars": _prospect.star, "sub": SalesArchetypes.voice_line(_prospect.archetype_id),
			"badge": tr("SALES_WHALE_" + whale.to_upper()) if whale != "" else ""},
		"memory": vs.memory_line,
	}
	# The catalogue can have nothing to ask of this table; then the sitting opened on the die.
	var gestures := []
	match String(vs.outcome):
		"won": gestures.append({"seat": LEAD, "name": "lean"})
		"lost": gestures.append({"seat": LEAD, "name": "watch"})
	step.merge(_act1(vs, [], gestures))
	return step


func pick(id: String) -> Dictionary:
	if _at_table:
		return _move(id)
	var label := tr("SALES_MEETING_SKIP")
	for a: Dictionary in _view.answers:
		if a.id == id:
			label = tr(a.text_key)
	var asked := _asker(_view)
	var before: float = _view.odds
	var vs: Dictionary = SalesMeetingSystem.skip_to_offer() if id == SKIP else SalesMeetingSystem.choose(id)
	var gestures := []
	if id != SKIP:
		gestures.append({"seat": asked,
			"name": "nod" if vs.odds - before >= SalesConstants.W_ANSWER * NOD_SHARE else "notes"})
	match String(vs.outcome):
		"won": gestures.append({"seat": LEAD, "name": "lean"})
		"lost": gestures.append({"seat": LEAD, "name": "back"})
	return _act1(vs, [{"kind": "founder", "text": label}], gestures)


## Select on the ruler: the price moves, and the offer button's tone moves with it.
func select(value: int) -> Dictionary:
	var vs := NegotiationSystem.select_price(value)
	return {"instrument": _instrument(vs), "options": _moves(vs)}


## Devam: a won first act opens the price act; a closed price act is signed into the world here
## (SalesFinalizer), while SalesMeetingSystem still holds the sitting and no save can land.
func proceed() -> Dictionary:
	if _at_table:
		SalesFinalizer.apply(NegotiationSystem.result())
	elif _view.outcome == "won":
		return _open_table()
	return {"closed": true}


func end_sitting() -> void:
	SalesMeetingSystem.close()


func _band(odds: float) -> String:
	return UiTokens.attitude_band(int(round(odds * 100.0)), int(round(SalesConstants.CUT_HIGH * 100.0)),
		LUKEWARM_MIN)


## The seat asking the question on screen.
func _asker(vs: Dictionary) -> int:
	return (int(vs.probe_index) - 1) % _people.size() + 1


func _act1(vs: Dictionary, entries: Array, gestures: Array) -> Dictionary:
	_view = vs
	var value := int(round(vs.odds * 100.0))
	var band := _band(vs.odds)
	var hover := []
	for m: Dictionary in vs.modifier_lines:
		hover.append(("%s %s" % [m.sign, m.label]).strip_edges())
	var step := {
		"attitude": {"value": value, "word_key": UiTokens.attitude_word_key(band), "band": band,
			"odds_text": tr("SALES_ODDS").format({"n": value}), "hover": hover,
			"edges": [UiTokens.ATTITUDE_WARY_MIN, LUKEWARM_MIN, int(round(SalesConstants.CUT_HIGH * 100.0))]},
		"entries": entries,
		"gestures": gestures,
		"roll": {"passed": vs.outcome == "won"} if vs.rolled else {},
		"options": [],
	}
	if vs.outcome == "":
		step.speaker = _asker(vs)
		entries.append({"kind": "counterpart", "seat": step.speaker, "text": tr(vs.probe_key)})
		if vs.inner_voice != "":
			entries.append({"kind": "quiet", "text": vs.inner_voice})
		step.options = _answers(vs)
		return step
	step.speaker = LEAD
	entries.append({"kind": "counterpart", "seat": LEAD, "text": tr(vs.closing_key)})
	if vs.outcome == "won":
		step.continue_key = "SALES_MEETING_OPEN_OFFER"
	else:
		step.continue_key = "MEETING_CONTINUE"
		step.result = _card("negative", "MEETING_RES_LOST",
			tr("MEETING_RES_LOCK").format({"weeks": SalesConstants.RETURN_LOCK_WEEKS}),
			tr("SALES_MEMORY_" + String(vs.closing_key).trim_prefix("SALES_LOSS_")))
	return step


## This question's answers, then "Teklife geç" from the second question on. On the last question
## the answer itself may roll the die, whose odds are the quiet needle's, so it shows the die and
## no risk word.
func _answers(vs: Dictionary) -> Array:
	var out := []
	for a: Dictionary in vs.answers:
		out.append(_option(a.id, tr(a.text_key)).merged(
			{"enabled": a.open, "lock_reason": tr(a.lock_key), "dice_only": vs.last_probe and a.open}, true))
	if vs.can_skip:
		var factors := []
		for m: Dictionary in vs.modifier_lines:
			var s: Array = CHIP_SIGNS.get(m.sign, ["", "neutral"])
			factors.append({"cat_key": CHIP_BY_SEAM.get(m.seam, ""), "text": m.label, "sign": s[0], "tone": s[1]})
		out.append(_option(SKIP, tr("SALES_MEETING_SKIP")).merged({"dice": {
			"risk_key": UiTokens.risk_key(vs.odds), "chance": vs.odds, "factors": factors}}, true))
	return out


func _option(id: String, label: String) -> Dictionary:
	return {"id": id, "label": label}


func _open_table() -> Dictionary:
	_at_table = true
	var vs := NegotiationSystem.open(NegotiationSystem.TYPE_B2B, {
		"account": _prospect.company_name,
		"lead_id": _prospect.id,
		"star": _prospect.star,
		"archetype": _prospect.archetype_id,
		"promised": SalesMeetingSystem.promised_feature(),
		"is_whale": _prospect.is_whale,
	})
	return {
		"kicker": tr("MEETING_KICKER_SALES"),
		"beat": tr(vs.title_key),
		"speaker": LEAD,
		"attitude": {},
		"patience": vs.patience,
		"instrument": _instrument(vs),
		"options": _moves(vs),
	}


## One move at the price table. A counter keeps the table open and burns a patience box; the
## last box brings out the watch. Anything else closes it onto the result card.
func _move(id: String) -> Dictionary:
	var entries := []
	var vs: Dictionary
	match id:
		"offer":
			vs = NegotiationSystem.offer()
			entries.append({"kind": "state", "seat": 0,
				"text": tr("MEETING_OFFER_ROW").format({"price": Fmt.money_exact(vs.selected)})})
		"accept":
			vs = NegotiationSystem.accept_counter()
		_:
			vs = NegotiationSystem.walk()
	var step := {"patience": vs.patience, "entries": entries, "gestures": []}
	if NegotiationSystem.is_active():
		entries.append({"kind": "state", "seat": LEAD,
			"text": tr("NEG_COUNTER").format({"price": Fmt.money_exact(vs.counter)})})
		step.gestures.append({"seat": LEAD, "name": "watch" if vs.patience.current <= 1 else "notes"})
		step.merge({"instrument": _instrument(vs), "options": _moves(vs)})
		return step
	var result := NegotiationSystem.result()
	var reason: String = result.values.reason
	var lock := tr("MEETING_RES_LOCK")
	match String(result.outcome_id):
		NegotiationSystem.OUTCOME_SIGNED:
			var promised: String = result.context.promised
			step.gestures.append({"seat": LEAD, "name": "nod"})
			var deal := _deal(vs)
			step.result = _card("positive", "MEETING_RES_SIGNED",
				tr("MEETING_RES_PAIR").format({"first": deal[0], "second": deal[1]}),
				B2BConstants.feature_label(promised) if promised != "" else "")
			step.result.stamp = "HUNT_BADGE_SIGNED"
		NegotiationSystem.OUTCOME_INSULTED:
			step.gestures.append({"seat": LEAD, "name": "back"})
			step.result = _card("negative", "MEETING_RES_INSULT",
				lock.format({"weeks": SalesConstants.RETURN_LOCK_WEEKS}), tr("MEETING_RES_INSULT_MEMORY"))
		_:
			# The founder standing up walks without a trace; a table out of patience walks on price
			# and remembers it.
			var walk_lock := lock.format({"weeks": SalesConstants.WALK_LOCK_WEEKS})
			if reason == "":
				step.result = _card("neutral", "MEETING_RES_WITHDREW", walk_lock, tr("MEETING_RES_NO_TRACE"))
			else:
				step.gestures.append({"seat": LEAD, "name": "back"})
				step.result = _card("negative", "MEETING_RES_LOST",
					tr("MEETING_RES_PAIR").format({"first": tr("MEETING_RES_PRICE_OUT"), "second": walk_lock}),
					tr("SALES_MEMORY_" + reason.to_upper()))
	step.merge({"instrument": {}, "options": [], "continue_key": "MEETING_CONTINUE"})
	return step


## The price table's moves are commands. A telegraph is a state, never a line, so its reason sits
## under the move it describes. Once patience is out their number is the only deal: Accept leads
## with that reason and the offer holds our own number, in the danger tone with what it costs.
## Before that the offer carries the insult line once the price is past it.
func _moves(vs: Dictionary) -> Array:
	var offer := _option("offer", tr("NEG_OFFER"))
	var accept := _option("accept", tr("NEG_ACCEPT"))
	var out := [offer, accept] if vs.can_accept else [offer]
	if vs.last_offer:
		offer.merge({"label": tr("NEG_HOLD"), "tone": "alert", "hint": tr("NEG_HOLD_REASON")}, true)
		accept.sub = tr("NEG_LAST_OFFER_REASON")
		out = [accept, offer]
	elif vs.insulting:
		offer.merge({"tone": "alert", "hint": tr(vs.insult_reason_key)}, true)
	out.append(_option("walk", tr("NEG_WALK")))
	for move: Dictionary in out:
		move.command = true
	return out


## NegotiationSystem's view with the ruler's words: the price caption, the locked zone's reason
## and the deal the held price makes; while their number stands under it, the deal accepting signs.
func _instrument(vs: Dictionary) -> Dictionary:
	var deal := _deal(vs)
	if int(vs.confirm.unit_price) != int(vs.selected):
		deal[0] = tr("NEG_DEAL_IF_ACCEPT").format({"line": deal[0]})
	return vs.merged({"price_label": tr(vs.price_label_key), "locked_reason": tr(vs.locked_reason_key),
		"deal": deal})


## Seats × price = MRR, and the capacity those seats land in.
func _deal(vs: Dictionary) -> PackedStringArray:
	var cf: Dictionary = vs.confirm
	return PackedStringArray([
		tr("NEG_CONFIRM_LINE").format({"units": cf.units, "unit_label": tr(vs.units_label_key),
			"price": Fmt.money_exact(cf.unit_price), "mrr": Fmt.money_exact(cf.mrr)}),
		tr("NEG_CAPACITY").format({"used": Fmt.group(cf.capacity_used), "cap": Fmt.group(cf.capacity_total)}),
	])


## A result card; "" memory leaves its row out.
func _card(band: String, title_key: String, effect: String, memory: String) -> Dictionary:
	return {"band": band, "title_key": title_key, "effect": effect, "memory": memory,
		"relation": {"name": _people[0].name, "from": _open_band, "to": _band(_view.odds)}}
