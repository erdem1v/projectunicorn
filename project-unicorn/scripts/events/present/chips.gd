class_name EvChips
extends RefCounted

# THE ONE CHIP BUILDER (EFFECT-VISIBILITY RULE). An effect a card offers, or a delta a history row
# recorded, becomes signed parts here and nowhere else:
#
#     {label, value, polarity, glyph}
#
# A part reads "label value"; `value` is the figure, "" when the part is a sentence. `polarity` is
# gain, cost, danger or neutral. Red is danger only (a departure, a lost customer, a closed road,
# the run's end); money spent, a discount and equity are costs, drawn in ink with the cost glyph
# (equity with the slice).
#
# Static, so text goes through TranslationServer: tr() compiles in a static func and dies at
# runtime.

## Effects a card carries deliberately and SILENTLY: bookkeeping with no player-visible
## consequence of its own. `event_chip_coverage` in the smoke suite fails on any card verb
## that describe() neither labels nor finds here.
const SILENT_VERBS := [
	"set_flag", "set_game_flag", "stamp_day", "cancel_scheduled",
	"start_arc", "advance_arc", "end_arc", "abort_arc", "set_arc_var",
	"mentor_advisory", "unlock_content", "spend_budget",
	# The chip names the card it bumps; a sprint with room for the fix has nothing to say.
	"sprint_fix_first", "sprint_card_first",
]

## Verbs whose part is a fixed sentence: [CSV key, polarity].
const FIXED_CHIPS := {
	"open_term_table": ["EFFECT_TERM_TABLE", "neutral"],
	"open_seed_table": ["EFFECT_SEED_TABLE", "neutral"],
	"decline_offer": ["EFFECT_FUND_CLOSES", "danger"],
	"trigger_ending": ["EFFECT_RUN_ENDS", "danger"],
	"decline_buyout": ["EFFECT_VC_ROAD_CLOSES", "danger"],
	"churn_customer": ["EFFECT_CHURN", "danger"],
	"add_prospect": ["EFFECT_NEW_PROSPECT", "gain"],
	"open_paid_tier": ["EFFECT_PAID_TIER", "gain"],
	"promise_create": ["EFFECT_PROMISE_CREATE", "cost"],
	"promise_extend": ["EFFECT_PROMISE_MOVED", "neutral"],
	"b2b_retain_delay": ["EFFECT_RETAIN_DELAY", "neutral"],
	"b2b_retain_ignore": ["EFFECT_RETAIN_IGNORE", "neutral"],
	"b2b_expand_decline": ["EFFECT_NO_CHANGE", "neutral"],
	"advance_phase": ["EFFECT_PHASE_ADVANCE", "neutral"],
	"phase_gate_decline": ["EFFECT_PHASE_HOLD", "neutral"],
	"goto_tab": ["EFFECT_TAKES_YOU_THERE", "neutral"],
	"sprint_card_carry": ["EFFECT_SPRINT_CARRY", "neutral"],
}

## How many names a crew chip lists before it counts the rest.
const NAMES_SHOWN := 4   # [WORKING]

## The chip of a group of accounts that took a trust hit together; one account reads by its name.
const TRUST_GROUP_KEYS := {"all": "EFFECT_TRUST_ACCOUNTS", "night": "EFFECT_TRUST_NIGHT_ACCOUNTS",
	"other": "EFFECT_TRUST_OTHER_ACCOUNTS"}

## The polarity's glyph (A2's icon names); a neutral part has none.
const GLYPHS := {"gain": "up", "cost": "cost", "danger": "warn", "neutral": ""}

## A card's category as its topic, where no family tag or speaker names one.
const CATEGORY_TAGS := {"customer": "EVENT_TAG_CUSTOMER", "team": "EVENT_TAG_TEAM",
	"product": "EVENT_TAG_PRODUCT", "funding": "DESK_PAPER_TAG_FUNDING"}


## The parts of one effect. `is_delta` false: `item` is a card effect and every figure is computed
## the way EvEffects will apply it against `ctx`, the card's frozen scope. `is_delta` true: `item`
## is a history delta and its figures are the recorded ones; `ctx` is the row's entities. `names`
## are the row's frozen names, for a person who has since left.
static func describe(item: Dictionary, ctx: Dictionary, names: Dictionary, is_delta: bool) -> Array:
	var verb: String = String(item.get("verb", ""))
	if item.has("refused"):
		return []
	if FIXED_CHIPS.has(verb):
		return [_part(_t(FIXED_CHIPS[verb][0]), "", FIXED_CHIPS[verb][1])]
	var d: int = EvEffects.amount(item, ctx)
	match verb:
		"add_cash": return [_figure("EFFECT_CASH", _money(d), _signed(d))]
		"add_brand": return [_figure("EFFECT_BRAND", _num(d), _signed(d))]
		"add_reputation": return [_figure("EFFECT_REPUTATION", _num(d), _signed(d))]
		"customer_mrr_delta": return [_figure("EFFECT_CUSTOMER_MRR", _money(d), _signed(d))]
		"satisfaction_delta": return [_figure("EFFECT_SATISFACTION", _num(d), _signed(d))]
		"seats":
			var seats: int = int(item.get("seats", d))
			return [_figure("EFFECT_SEATS", _num(seats), _signed(seats))]
		"morale_all": return [_figure("EFFECT_TEAM", _num(d), _signed(d))]
		"morale_crew":
			var crew: Array = item.get("names", []) if is_delta else EvEffects.crew_names(EvEffects.crew_of(item, ctx))
			return [_figure("EFFECT_NIGHT_CREW", _num(d), _signed(d), {"names": _name_list(crew)})]
		"trust_delta": return _trust_parts(item if is_delta else EvEffects.trust_plan(item, ctx))
		"incident": return _incident_parts(item if is_delta else IncidentSystem.plan(String(item.get("act", ""))))
		"promise_break": return _break_parts(item if is_delta else EvEffects.break_plan())
		"sprint_fix_first":
			var bumped: Dictionary = item.get("bumps", {}) if is_delta \
				else SprintSystem.fix_first_bumps(EvEffects.line_of(item), int(item.get("bugs", 0)))
			var parts: Array = []
			# A paper's fix names itself too: the player asked for it first.
			if bool(item.get("front", false)) and _line_name(item) != "":
				parts.append(_part(_t("EFFECT_FIX_FRONT").format({"card": SprintCatalog.card_name(
					{"kind": "fix", "line": EvEffects.line_of(item)})}), "", "gain"))
			if not bumped.is_empty():
				parts.append(_part(_t("EFFECT_SPRINT_BUMP").format({"card": SprintCatalog.card_name(bumped)}), "", "cost"))
			return parts
		# The card's own work: its name and the points it gains (a cost) or sheds. Work already done that is thrown
		# away reads as what it is, not as points off the card.
		"sprint_card_effort":
			var effort: int = d if is_delta else SprintSystem.effort_change(d)
			return [_card_points(item, effort, _signed(-effort))]
		"sprint_card_progress":
			if d < 0:
				return [_part(_t(Fmt.count_key("EFFECT_WORK_LOST", -d)).format({"n": -d}), "", "danger")]
			return [_card_points(item, -d, _signed(d))]
		# The option's lock says the card ships this sprint: the promise is kept. The price is the test cut in half, or
		# for the promise's overtime (`promise`) the crew's morale, its own effect; the chip names no hours. A paper's
		# test cut (`card` DECISION) keeps no promise: the card is the pending decision's.
		"sprint_card_test":
			if String(item.get("card", "")) == EvEffects.DECISION:
				return [_part(_t("EFFECT_TEST_CUT").format({"card": _card_name(item)}), "", "cost")]
			return [_part(_t("EFFECT_PROMISE_KEPT"), "", "gain"),
				_part(_t("EFFECT_TEST_CUT").format({"card": SprintSystem.promise_name()}), "", "cost")]
		# The card gives work up (points off it, work left for the next sprint) or ships with a bug.
		"sprint_card_trim": return _trim_parts(item if is_delta else EvEffects.trim_plan(item))
		# No effect of its own: whether the card finishes the sprint once the option's other effects have landed.
		"sprint_card_outlook":
			var finishes: bool = bool(item.get("finishes", false)) if is_delta \
				else SprintSystem.finishes_with(SprintSystem.decision_card().get("id", ""), d)
			return [_part(_t("EFFECT_CARD_ON_TIME" if finishes else "EFFECT_CARD_LATE").format({"card": _card_name(item)}),
				"", "neutral")]
		# The card stands first in the sprint: the card it bumps is the only word.
		"sprint_card_first":
			var shoved: Dictionary = item.get("bumps", {}) if is_delta else SprintSystem.decision_first_bumps()
			return [] if shoved.is_empty() \
				else [_part(_t("EFFECT_SPRINT_BUMP").format({"card": SprintCatalog.card_name(shoved)}), "", "cost")]
		"sprint_hours":
			if bool(item.get("promise", false)):
				return [_part(_t("EFFECT_PROMISE_KEPT"), "", "gain")]
			var mult: float = float(item.get("mult", 1.0))
			var hours: float = float(item.get("hours", mult)) if is_delta else SprintSystem.hours_after(mult)
			var alone: bool = bool(item.get("solo", false)) if is_delta else SprintSystem.payers("").is_empty()
			return [_part(_t("EFFECT_SPRINT_HOURS_SOLO" if alone else "EFFECT_SPRINT_HOURS").format(
				{"v": Fmt.number(hours, 2)}), "", _signed(int(signf(mult - 1.0))))]
		# The code is rewritten: no bug lands on the line for a while. The line is named the way the row recorded it.
		"line_harden":
			var weeks: int = int(item.get("weeks", SprintCatalog.cfg("paper.harden_weeks")))
			return [_part(_t("EFFECT_LINE_HARDEN").format({"line": _line_name(item), "weeks": weeks}), "", "gain")]
		"damage_product":
			var bugs: int = int(item.get("bugs", 1))
			return [_part(_t(Fmt.count_key("EFFECT_NEW_BUGS", bugs)).format(
				{"line": _line_name(item), "n": bugs}), "", "cost")]
		"change_morale":
			var who: String = _first_name(_employee(item, ctx, is_delta), ctx, names, _t("EFFECT_MORALE"))
			return [_figure("EFFECT_AXIS", _num(d), _signed(d), {"axis": who})]
		# The row's figures, else the terms HRSystem lands them at (the lone founder's cap included).
		"productivity_mod":
			var pace: Dictionary = item if is_delta \
				else HRSystem.productivity_terms(int(item.get("pct", 0)), int(item.get("weeks", 1)))
			var words: Dictionary = {"pct": Fmt.signed_percent(int(pace.pct)), "weeks": Fmt.weeks(int(pace.weeks))}
			var key: String = "EFFECT_PACE_TEAM"
			if String(item.get("scope", "")) != "team":
				var pid: String = _employee(item, ctx, is_delta)
				var person: Character = CharacterRegistry.get_character(pid)
				if person != null and person.category == "founder":
					key = "EFFECT_PACE_FOUNDER"
				else:
					key = "EFFECT_PACE"
					words["name"] = _first_name(pid, ctx, names, _t("EFFECT_AN_EMPLOYEE"))
			return [_part(_t(key).format(words), "", _signed(int(pace.pct)))]
		# The weeks away are the cost, the morale on return the gain, as the dossier's leave dialog reads it.
		"send_on_leave":
			var lid: String = _employee(item, ctx, is_delta)
			var away_weeks: int = int(item.get("weeks", HRConstants.VACATION_WEEKS_MIN))
			var gain: int = int(item.get("gain", 0)) if is_delta \
				else HRActions.leave_gain(CharacterRegistry.get_character(lid), away_weeks)
			return [_part(_t("EFFECT_LEAVE").format({"name": _first_name(lid, ctx, names, _t("EFFECT_AN_EMPLOYEE")),
					"weeks": Fmt.weeks(away_weeks)}), "", "cost"),
				_figure("HR_ROW_MORALE_RETURN", _num(gain), "gain")]
		# Two colleagues' summer leaves: who moves and how far, or both away the same weeks and when that starts.
		"summer_leave":
			var leave: Dictionary = item if is_delta else EvEffects.summer_leave_plan(item, ctx)
			var someone: String = _t("EFFECT_AN_EMPLOYEE")
			if bool(item.get("apart", false)):
				return [_part(_t("EFFECT_LEAVE_SHIFT").format({"name": _first_name(String(leave.get("moved_id", "")), ctx, names, someone),
					"weeks": Fmt.weeks(int(leave.get("shift", 0)))}), "", "cost")]
			return [_part(_t("EFFECT_LEAVE_TOGETHER").format({"a": _first_name(String(leave.get("a_id", "")), ctx, names, someone),
				"b": _first_name(String(leave.get("b_id", "")), ctx, names, someone),
				"weeks": Fmt.weeks(int(leave.get("weeks_away", 0)))}), "", "cost")]
		# Out for weeks, and nothing like the player's leave: no morale comes back.
		"sick_leave":
			return [_part(_t("EFFECT_SICK_LEAVE").format({"name": _first_name(_employee(item, ctx, is_delta), ctx, names, _t("EFFECT_AN_EMPLOYEE")),
				"weeks": Fmt.weeks(int(item.get("weeks", 1)))}), "", "cost")]
		# The level it lands on and the salary it lands at: the dossier's preview, or what the row recorded.
		"promote":
			var promoted: String = _employee(item, ctx, is_delta)
			var terms: Dictionary = item if is_delta \
				else HRActions.preview_promotion(CharacterRegistry.get_character(promoted), int(item.get("pct", 0)))
			if not bool(terms.get("ok", true)):
				return [_part(String(terms.reason), "", "neutral")]
			return [_part(_t("EFFECT_PROMOTION").format({"name": _first_name(promoted, ctx, names, _t("EFFECT_AN_EMPLOYEE")),
				"level": HRConstants.level_label(int(terms.level)), "v": Fmt.money_chip(int(terms.salary))}), "", "cost")]
		"work_hours":
			return [_part(_t("EFFECT_WORK_HOURS").format({"n": int(item.get("hours", HRConstants.WORK_HOURS_DEFAULT)),
				"name": _first_name(_employee(item, ctx, is_delta), ctx, names, _t("EFFECT_AN_EMPLOYEE"))}), "", "neutral")]
		"investor_strain":
			var vc: String = String(item.get("vc", "")) if is_delta \
				else EvEffects.entity_of(item, ctx, EvScope.TYPE_INVESTOR)
			var strain: Dictionary = item if is_delta else VCPitchSystem.strain_terms(d, int(item.get("weeks", 0)))
			return [_part(_t("EFFECT_INVESTOR_STRAIN").format({
				"investor": String(InvestorRegistry.get_investor(vc).get("display_name", "")),
				"v": _num(-int(strain.amount)), "n": int(strain.weeks)}), "", "cost")]
		# Spend for growth: the burn is the cost, the audience the gain, over the same weeks.
		"marketing_push":
			var push: Dictionary = item if is_delta else FinanceSystem.marketing_terms(
				int(item.get("burn_pct", 0)), int(item.get("growth_pct", 0)), int(item.get("weeks", 0)))
			var span: String = Fmt.weeks(int(push.weeks))
			return [_part(_t("EFFECT_MARKETING_BURN").format({"pct": Fmt.signed_percent(int(push.burn_pct)),
					"weeks": span}), "", "cost"),
				_part(_t("EFFECT_MARKETING_GROWTH").format({"pct": Fmt.signed_percent(int(push.growth_pct)),
					"weeks": span}), "", "gain")]
		"audience_delta":
			if item.has("pct"):
				var tenths: int = roundi(float(item["pct"]) * 1000.0)
				return [_figure("EFFECT_AUDIENCE_PCT", Fmt.signed_percent(tenths / 10.0, int(tenths % 10 != 0)),
					_signed(tenths), {"pct": ""})]
			return [_figure("EFFECT_AUDIENCE", _num(d), _signed(d))]
		"convert_audience":
			var conv: String = Fmt.percent(int(round(float(item.get("pct", 0.0)) * 100.0)), 0)
			return [_part(_t("EFFECT_CONVERT_AUDIENCE").format({"pct": conv}), "", "gain")]
		"employee_leaves":
			var leaver: String = _first_name(_employee(item, ctx, is_delta), ctx, names, _t("EFFECT_AN_EMPLOYEE"))
			return [_part(_t("EFFECT_DEPARTURE").format({"who": leaver}), "", "danger")]
		# The cut is derived the way the `b2b_retain_discount` effect derives it from the account's
		# own MRR; a history row carries the cut that landed.
		"b2b_retain_discount":
			var cut: int = d
			if not is_delta:
				var rc: Customer = CustomerRegistry.get_customer(EvEffects.entity_of(item, ctx, EvScope.TYPE_CUSTOMER))
				cut = -int(round(float(rc.mrr) * B2BConstants.RETAIN_DISCOUNT_PCT)) if rc != null else 0
			return [_figure("EFFECT_RETAIN_DISCOUNT", _money(cut), "cost")]
		# A month's discount: the account and the share it keeps (EvEffects.month_discount_plan), money out once.
		"b2b_month_discount":
			var gift: Dictionary = item if is_delta else EvEffects.month_discount_plan(item, ctx)
			return [_part(_t("EFFECT_ONE_MONTH_DISCOUNT").format({"customer": gift.get("name", ""),
				"pct": int(gift.get("pct", 0)), "v": _money(int(gift.get("amount", 0)))}), "", "cost")]
		# Seats and rate as B2BSalesSystem.expand computes them (the account's own seat price, the
		# constant only as fallback, Satış §5.4); a history row carries what landed.
		"b2b_expand":
			var seats: int = int(item.get("seats", 0))
			var mrr: int = d
			if not is_delta:
				var ec: Customer = CustomerRegistry.get_customer(EvEffects.entity_of(item, ctx, EvScope.TYPE_CUSTOMER))
				if ec != null:
					seats = B2BConstants.expansion_seats(ec.company_size)
					mrr = seats * (ec.seat_price if ec.seat_price > 0 else B2BConstants.EXPANSION_PER_SEAT_MRR)
			return [_figure("EFFECT_EXPAND", _money(mrr), "gain", {"seats": seats, "mrr": ""})]
		# What the scheduled card lands whichever way it is answered, under the wait. Those are the target
		# card's effects, not landed deltas, so a history row reads them as the live chip does.
		"schedule_event":
			var landed: Array = []
			var scheduled: Dictionary = item.get("context", ctx)
			for effect in landing(String(item.get("event_id", ""))):
				landed.append_array(describe(effect, scheduled, names, false))
			if landed.is_empty():
				return []
			var span: Array = EvEffects.delay_bounds(item)
			var wait: String = _t(Fmt.count_key("EFFECT_LATER", span[0])).format({"n": span[0]}) \
				if span[0] == span[1] else _t("EFFECT_LATER_RANGE").format({"lo": span[0], "hi": span[1]})
			return [_part(wait, "", "neutral")] + landed
		# The cheque is cash in and equity out: the equity is the decision's cost, drawn as the slice.
		"angel_accept":
			var stake: Dictionary = _part(_t("EFFECT_TO_FRANK"),
				_t("EFFECT_EQUITY").format({"equity": AngelRoundSystem.EQUITY_PCT}), "cost")
			stake.glyph = "pie"
			return [_figure("EFFECT_CASH", _money(AngelRoundSystem.CASH_AMOUNT), "gain"), stake]
	if verb != "" and not SILENT_VERBS.has(verb):
		push_warning("[EvChips] effect '%s' renders no chip — add a label or list it in SILENT_VERBS" % verb)
	return []


## The parts of an option's dice: each branch that does anything, headed by its own odds. The branch that
## carries a cost or a danger is the risky one and reads as danger, whichever side of the dice it sits on.
static func describe_check(check: Dictionary, ctx: Dictionary, names: Dictionary) -> Array:
	var parts: Array = []
	if check.is_empty():
		return parts
	var pass_pct: int = roundi(clampf(float(EvSeams.read(String(check["odds_seam"]))), 0.0, 1.0) * 100.0)
	for branch in [["on_pass", pass_pct], ["on_fail", 100 - pass_pct]]:
		var chips: Array = []
		for effect in check.get(branch[0], []):
			chips.append_array(describe(effect, ctx, names, false))
		if chips.is_empty():
			continue
		var risky: bool = chips.any(func(p: Dictionary) -> bool: return p.polarity in ["cost", "danger"])
		parts.append(_part(_t("EFFECT_CHANCE").format({"pct": branch[1]}), "", "danger" if risky else "gain"))
		parts.append_array(chips)
	return parts


## The effects a scheduled card lands on every path: the ones each of its options carries, and its expiry too.
## A `schedule_event` among them is a further step of its own, not a landing.
static func landing(event_id: String) -> Array:
	var card: Dictionary = EvCatalog.card(event_id)
	var paths: Array = (card.get("options", []) as Array).map(
		func(o: Dictionary) -> Array: return o.get("effects", []))
	if card.has("on_expire"):
		paths.append(card["on_expire"].get("penalties", []))
	if paths.is_empty():
		return []
	return paths[0].filter(func(e: Dictionary) -> bool:
		return e.get("verb") != "schedule_event" and paths.all(func(path: Array) -> bool: return path.has(e)))


## How a part reads on a chip.
static func text(part: Dictionary) -> String:
	return String(part["label"]) if String(part["value"]) == "" \
		else "%s %s" % [part["label"], part["value"]]


## {key, text} of a card's topic. Order matters: families that NAME their source (customer /
## team / phase gate / ship moment) first, then the speaker, then the generic `endgame` topic,
## then the card's category, then GÜNDEM. `endgame` is a topic, not a source, so a Frank card
## tagged `endgame` is still MENTOR; `ship_moment` beats the speaker because it is a product beat
## even when Frank narrates it.
static func source_tag(ev: GameEvent, category := "") -> Dictionary:
	var key: String = ""
	for s in ev.tags:
		if s.begins_with("b2b_"):
			key = "EVENT_TAG_CUSTOMER"
		elif s.begins_with("hr_"):
			key = "EVENT_TAG_TEAM"
		elif s == "phase_gate":
			key = "EVENT_TAG_MENTOR"
		elif s == "ship_moment":
			key = "EVENT_TAG_PRODUCT"
		if key != "":
			break
	if key == "":
		if ev.character_id == "char_mentor_frank":
			key = "EVENT_TAG_MENTOR"
		elif ev.tags.has("endgame"):
			key = "EVENT_TAG_MARKET"
		elif CATEGORY_TAGS.has(category):
			key = CATEGORY_TAGS[category]
		else:
			key = "EVENT_TAG_AGENDA"
	return {"key": key, "text": _t(key)}


static func _part(label: String, value: String, polarity: String) -> Dictionary:
	return {"label": label, "value": value, "polarity": polarity, "glyph": GLYPHS[polarity]}


## A "<words> {v}" chip split into its words and its figure. `args` fills the template's other
## slots and names the figure's own slot when it is not {v}.
static func _figure(key: String, value: String, polarity: String, args: Dictionary = {}) -> Dictionary:
	var words: Dictionary = {"v": ""}
	words.merge(args, true)
	return _part(_t(key).format(words).strip_edges(), value, polarity)


## A trust hit: the largest account's satisfaction now and a tick on (the figure the player will read,
## EvEffects.trust_plan), and the standing per-sprint cost. A card effect read as a delta (the linter)
## has no accounts yet, only its figures.
static func _trust_parts(plan: Dictionary) -> Array:
	var parts: Array = []
	var delta: int = int(plan.get("amount", 0))
	if delta != 0:
		var accounts: Array = plan.accounts if plan.get("accounts") is Array else []
		var top: Dictionary = accounts[0] if not accounts.is_empty() else {}
		parts.append(_trust_part("all", accounts.size(), delta, top))
	var per_sprint: int = int(plan.get("per_sprint", 0))
	if per_sprint != 0:
		var step: String = String((plan.get("until", {}) as Dictionary).get("step_live", ""))
		var standing: String = _t("EFFECT_TRUST_PER_SPRINT")
		var words: Dictionary = {"v": _num(per_sprint)}
		if not ProductLines.step(step).is_empty():
			standing = _t("EFFECT_TRUST_UNTIL_SHIPS")
			words["card"] = SprintCatalog.step_name(step)
		parts.append(_part(standing.format(words), "", _signed(per_sprint)))
	return parts


## A group of `n` accounts that took `delta` together, by its largest account's name and satisfaction now and a tick
## on; a group of one reads as that account.
static func _trust_part(group: String, n: int, delta: int, top: Dictionary) -> Dictionary:
	var key: String = TRUST_GROUP_KEYS[group] if n > 1 else "EFFECT_TRUST_ACCOUNT"
	return _part(_t(key).format({"n": n, "v": _num(delta), "customer": top.get("name", ""),
		"from": int(top.get("from", 0)), "to": int(top.get("to", 0))}), "", _signed(delta))


## A broken word (EvEffects.break_plan): the largest account's satisfaction now and a tick on, the brand it costs and
## the weeks that account cannot be promised anything. An effect that carries no figures reads the constants.
static func _break_parts(plan: Dictionary) -> Array:
	var parts: Array = []
	var accounts: Array = plan.get("accounts", [])
	if not accounts.is_empty():
		var top: Dictionary = accounts[0]
		parts.append(_trust_part("all", accounts.size(), int(top.to) - int(top.from), top))
	parts.append(_figure("EFFECT_BRAND", _num(int(plan.get("brand", B2BConstants.PROMISE_BROKEN_BRAND))), "cost"))
	parts.append(_part(_t("EFFECT_PROMISE_RELOCK").format({"n": B2BConstants.PROMISE_RELOCK_WEEKS}), "", "cost"))
	return parts


## What a card gives up (EvEffects.trim_plan): the points off it, the work it leaves for the next sprint and the bugs it ships
## with. A row that carries no figures gives no parts.
static func _trim_parts(plan: Dictionary) -> Array:
	var parts: Array = []
	var cut: int = int(plan.get("cut", 0))
	if cut > 0 or bool(plan.get("share", false)):
		parts.append(_card_points(plan, -cut, "gain"))
	var work: int = int(plan.get("work", 0))
	if work > 0:
		parts.append(_part(_t(Fmt.count_key("EFFECT_NEXT_SPRINT_WORK", work)).format({"n": work}), "", "cost"))
	var bugs: int = int(plan.get("bugs", 0))
	if bugs > 0:
		parts.append(_part(_t(Fmt.count_key("EFFECT_SHIP_BUGS", bugs)).format({"line": _line_name(plan), "n": bugs}),
			"", "cost"))
	return parts


## An emergency's answer (IncidentSystem.plan): what is paid, what the accounts keep, when the service is back or the
## fix lands, and what the audience loses. An effect that carries no figures gives no parts.
static func _incident_parts(plan: Dictionary) -> Array:
	var parts: Array = []
	if plan.has("credit"):
		var credit: Dictionary = plan.credit
		parts.append(_figure(Fmt.count_key("EFFECT_OUTAGE_CREDIT", int(credit.n)), _money(-int(credit.amount)), "cost",
			{"n": credit.n, "pct": credit.pct}))
	if plan.has("free"):
		var free: Dictionary = plan.free
		parts.append(_figure("EFFECT_FREE_MONTH", _money(-int(free.amount)), "cost", {"n": free.n, "paying": free.paying}))
	for row in plan.get("trust", []):
		parts.append(_trust_part(String(row.group), int(row.n), int(row.delta), row))
	if int(plan.get("per_sprint", 0)) != 0:
		parts.append(_part(_t("EFFECT_TRUST_PER_SPRINT").format({"v": _num(int(plan.per_sprint))}), "",
			_signed(int(plan.per_sprint))))
	if plan.has("back"):
		var key: String = "EFFECT_FIXED_TOMORROW" if bool(plan.tomorrow) else "EFFECT_FIXED_AROUND"
		if plan.kind == "outage":
			key = "EFFECT_SERVICE_BACK" if plan.market == "b2b" else "EFFECT_APP_BACK"
		parts.append(_part(_t(key).format({"clock": MailClock.clock_text(int(plan.back))}), "", "neutral"))
	var audience: int = int(plan.get("audience", 0))
	if audience != 0:
		parts.append(_figure("EFFECT_AUDIENCE", _num(audience), _signed(audience)))
	if plan.has("drain"):
		parts.append(_part(_t("EFFECT_AUDIENCE_WEEKLY").format({"v": Fmt.signed_percent(-roundi(float(plan.drain) * 100.0))}),
			"", "cost"))
	return parts


## "Deniz, Mert, Selin"; past NAMES_SHOWN names, the first two and how many more.
static func _name_list(names: Array) -> String:
	if names.size() <= NAMES_SHOWN:
		return ", ".join(names)
	return ", ".join(names.slice(0, 2)) + " " + _t("EFFECT_NAMES_MORE").format({"n": names.size() - 2})


static func _signed(delta: int) -> String:
	if delta > 0: return "gain"
	if delta < 0: return "cost"
	return "neutral"


static func _employee(item: Dictionary, ctx: Dictionary, is_delta: bool) -> String:
	return String(item.get("employee", "")) if is_delta else EvEffects.entity_of(item, ctx, EvScope.TYPE_EMPLOYEE)


## First name of the person `id` names: the name the row froze for them, else the registry's, else
## `fallback`.
static func _first_name(id: String, ctx: Dictionary, names: Dictionary, fallback: String) -> String:
	var full: String = ""
	for slot in ctx:
		if String((ctx[slot] as Dictionary).get("id", "")) == id and names.has(slot):
			full = EvPresenter.name_text(names[slot])
	if full == "" and id != "":
		var c: Character = CharacterRegistry.get_character(id)
		full = c.character_name if c != null else ""
	return full.split(" ", false)[0] if full != "" else fallback


## "Batch Invoicing +10 points": a card and the points it gains or sheds.
static func _card_points(item: Dictionary, points: int, polarity: String) -> Dictionary:
	return _part(_t(Fmt.count_key("EFFECT_CARD_POINTS", absi(points))).format(
		{"card": _card_name(item), "v": _num(points)}), "", polarity)


## The card a sprint effect lands on: the identity the row kept (`of`), else the pending decision's card.
static func _card_name(item: Dictionary) -> String:
	var card: Dictionary = item.get("of", SprintSystem.decision_card())
	return "" if card.is_empty() else SprintCatalog.card_name(card)


## The line an effect names (`line`, DECISION for the pending decision's), "" when it names none.
static func _line_name(item: Dictionary) -> String:
	var line: String = EvEffects.line_of(item)
	return "" if ProductLines.line(line).is_empty() else SprintCatalog.cap_name(line)


static func _num(value: int) -> String:
	return ("+%d" if value > 0 else "%d") % value


# The chip is the player's source of truth for what a decision costs, so it uses the
# locale-aware abbreviated money (Fmt.money_chip) with an explicit sign on both sides.
static func _money(value: int) -> String:
	return ("+" if value >= 0 else "-") + Fmt.money_chip(absi(value))


static func _t(key: String) -> String:
	return TranslationServer.translate(key)
