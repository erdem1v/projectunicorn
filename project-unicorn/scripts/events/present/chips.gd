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
	"set_flag", "set_game_flag", "stamp_day", "schedule_event", "cancel_scheduled",
	"start_arc", "advance_arc", "end_arc", "abort_arc", "set_arc_var",
	"mentor_advisory", "unlock_content", "spend_budget",
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
	"b2b_retain_delay": ["EFFECT_RETAIN_DELAY", "neutral"],
	"b2b_retain_ignore": ["EFFECT_RETAIN_IGNORE", "neutral"],
	"b2b_expand_decline": ["EFFECT_NO_CHANGE", "neutral"],
	"advance_phase": ["EFFECT_PHASE_ADVANCE", "neutral"],
	"phase_gate_decline": ["EFFECT_PHASE_HOLD", "neutral"],
	"goto_tab": ["EFFECT_TAKES_YOU_THERE", "neutral"],
	"sprint_card_carry": ["EFFECT_SPRINT_CARRY", "neutral"],
	"fix_run_start": ["EFFECT_FIX_RUN_STARTS", "neutral"],
}

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
	var d: int = int(item.get("amount", item.get("delta", item.get("value", 0))))
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
		"sprint_card_effort":
			var effort: int = d if is_delta else SprintSystem.effort_change(d)
			return [_figure("EFFECT_SPRINT_EFFORT", _num(effort), _signed(-effort))]
		"sprint_card_progress": return [_figure("EFFECT_SPRINT_PROGRESS", _num(d), _signed(d))]
		"sprint_hours":
			var mult: float = float(item.get("mult", 1.0))
			var hours: float = float(item.get("hours", mult)) if is_delta else SprintSystem.hours_after(mult)
			return [_part(_t("EFFECT_SPRINT_HOURS").format({"v": Fmt.number(hours, 2)}), "",
				_signed(int(signf(mult - 1.0))))]
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
				var pts: int = int(round(float(item["pct"]) * 100.0))
				return [_figure("EFFECT_AUDIENCE_PCT", Fmt.signed_percent(pts), _signed(pts), {"pct": ""})]
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
		# The cheque is cash in and equity out: the equity is the decision's cost, drawn as the slice.
		"angel_accept":
			var stake: Dictionary = _part(_t("EFFECT_TO_FRANK"),
				_t("EFFECT_EQUITY").format({"equity": AngelRoundSystem.EQUITY_PCT}), "cost")
			stake.glyph = "pie"
			return [_figure("EFFECT_CASH", _money(AngelRoundSystem.CASH_AMOUNT), "gain"), stake]
	if verb != "" and not SILENT_VERBS.has(verb):
		push_warning("[EvChips] effect '%s' renders no chip — add a label or list it in SILENT_VERBS" % verb)
	return []


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


static func _num(value: int) -> String:
	return ("+%d" if value > 0 else "%d") % value


# The chip is the player's source of truth for what a decision costs, so it uses the
# locale-aware abbreviated money (Fmt.money_chip) with an explicit sign on both sides.
static func _money(value: int) -> String:
	return ("+" if value >= 0 else "-") + Fmt.money_chip(absi(value))


static func _t(key: String) -> String:
	return TranslationServer.translate(key)
