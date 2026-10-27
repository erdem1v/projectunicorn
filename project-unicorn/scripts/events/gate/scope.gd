class_name EvScope
extends RefCounted

# NAMED SCOPE SLOTS (GDD §4.3). A card declares the entities it is about, by name and by type:
#
#     scope:
#       employee:  { type: employee, required: true,  select: support_lead }
#       customer:  { type: customer, required: false }
#
# THE ONE RULE: never guess. "Asla tahmin edilmez. Belirsiz kapsam = red." An unresolvable
# slot means the card is not admitted; the engine never picks something merely plausible.
#
# The founder is a separate type: CharacterRegistry.get_employees() filters by category, so the
# employee selector cannot return him (Ekip GDD 02 §5).
#
# The frozen context is {slot: {type, id, bound_day}} — SCALARS ONLY, never the Character.
# Character is a Resource, so storing it would serialise a private copy of a departed employee
# into the save and a load would resurrect it (§20 A2). The id is enough: CharacterRegistry
# erases a removed id, so a dead subject resolves to null and re-validation drops the card.
# That rests on ids never being reused (§10.9: a rehire is a new entity with a new id).

const TYPE_EMPLOYEE := "employee"
const TYPE_FOUNDER := "founder"
const TYPE_CUSTOMER := "customer"
const TYPE_PROSPECT := "prospect"
const TYPE_RIVAL := "rival"
const TYPE_INVESTOR := "investor"

const TYPES := [TYPE_EMPLOYEE, TYPE_FOUNDER, TYPE_CUSTOMER, TYPE_PROSPECT, TYPE_RIVAL, TYPE_INVESTOR]

## A slot with this `select` binds only the entity the requester names, and stays empty (if optional) without one.
const ASKED := "asked"

## The selectors a slot may name, by type; the lint refuses any other. A name ending in ':' is a prefix and takes a
## parameter (`market_rival:giant`). `random` is seeded: the same day, card and slot pick the same entity.
const SELECTORS := {
	TYPE_EMPLOYEE: ["lowest_morale", "newest_hire", "most_senior", "top_skill:", "account_rep", "support_lead", "sprint_dev",
		"decision_dev", "quarter_pm", "leave_pair", "leave_partner", "lead_rep", "random"],
	TYPE_CUSTOMER: ["at_risk", "escalated", "expansion_ready", "open_request", "largest", "smallest", "line_top",
		"line_warehouse", "line_newest", "line_slow", "request", "random"],
	TYPE_PROSPECT: ["rep_lead", "random"],
	TYPE_RIVAL: ["sprint_rival", "market_rival:", "random"],
	TYPE_INVESTOR: ["expiring_sheet", "decision_sheet", "seed_lead", "random"],
}


# --- Resolution ------------------------------------------------------------

## Bind every declared slot. Returns {ok: bool, context: Dictionary, reason: String}, where
## `reason` says which slot refused the card and why.
##
## `given` is what the caller already knows, per slot: a bare id (a signal's payload, a request)
## or a frozen binding {type, id, ...} (an arc's subject, a scheduled entry's context). §4.3: a
## given slot binds that entity or refuses the card; only a slot the caller left out runs its
## selector. A signal can drain after its entity is gone, and the selector would then put the
## card on a different entity.
##
## A slot's optional `where` is a condition tree over that slot alone: the selector chooses only
## among the candidates it holds for, so a card about "a builder" binds a builder instead of
## binding the most senior person and then failing its condition on them. A given subject that
## fails it is refused like one of the wrong type. Slots of one group bind in declaration order,
## so an unfiltered slot declared first can take the only candidate a later `where` wanted.
##
## REQUIRED SLOTS ARE RESOLVED FIRST. With two slots of one type and one candidate, declaration
## order could hand the only candidate to an optional slot and then fail the required one.
##
## `card_id` seeds the selectors that draw (`random`, the rival ones), so asking again on the same day
## (the gate, a request, --why-fire) binds the same entity.
static func resolve(slots: Dictionary, given: Dictionary = {}, card_id: String = "") -> Dictionary:
	var context: Dictionary = {}
	var used: Dictionary = {}          # entity id -> slot that took it

	for slot_name in _required_first(slots):
		var spec: Dictionary = slots[slot_name]
		var type_id: String = String(spec.get("type", ""))
		if not TYPES.has(type_id):
			var why: String = "slot '%s' declares unknown type '%s'" % [slot_name, type_id]
			push_error("[EvScope] " + why)
			return {"ok": false, "context": {}, "reason": why}

		var chosen: String
		if given.has(slot_name):
			var g: Variant = given[slot_name]
			chosen = String((g as Dictionary).get("id", "")) \
				if typeof(g) == TYPE_DICTIONARY else String(g)
			# Type-checked too: binding the wrong kind would make the card lie about its subject.
			if not _exists(chosen, type_id) or used.has(chosen) or not _passes_where(spec, slot_name, chosen):
				return {"ok": false, "context": context,
					"reason": "slot '%s': the given %s '%s' is not a live %s, is already bound or fails its where"
						% [slot_name, type_id, chosen, type_id]}
		else:
			var hidden: Dictionary = used
			if spec.has("where"):
				hidden = used.duplicate()
				for candidate in _ids(type_id):
					if not _passes_where(spec, slot_name, candidate):
						hidden[candidate] = slot_name
			var mode: String = String(spec.get("select", ""))
			chosen = "" if mode == ASKED else _select(type_id, mode, hidden, context,
				EvDice.unit("pick", GameState.day, card_id, slot_name))
			if chosen == "":
				if bool(spec.get("required", true)):
					return {"ok": false, "context": context,
						"reason": "slot '%s' could not be filled%s" % [slot_name, " (where)" if spec.has("where") else ""]}
				continue

		used[chosen] = slot_name
		context[slot_name] = {"type": type_id, "id": chosen, "bound_day": GameState.day}

	return {"ok": true, "context": context, "reason": ""}


## Does the entity meet the slot's `where`? A slot without one admits every candidate.
static func _passes_where(spec: Dictionary, slot_name: String, entity_id: String) -> bool:
	if not spec.has("where"):
		return true
	return EvCondition.eval(spec["where"], {slot_name: {"type": String(spec["type"]), "id": entity_id}})


static func _required_first(slots: Dictionary) -> Array:
	var req: Array = []
	var opt: Array = []
	for name in slots:
		if bool((slots[name] as Dictionary).get("required", true)):
			req.append(name)
		else:
			opt.append(name)
	return req + opt


# --- Re-validation ---------------------------------------------------------

## Is every bound entity still alive? Run at display (§4.4), at resolution (§20 A2) and per
## effect (§8.2 makes effect lists non-atomic, so effect one can remove effect three's target).
static func still_valid(context: Dictionary) -> bool:
	return first_dead_slot(context) == ""


## The slot whose entity has gone, or "". What the panel and the history row report.
static func first_dead_slot(context: Dictionary) -> String:
	for slot_name in context:
		if not _alive(context[slot_name]):
			return slot_name
	return ""


static func resolved(context: Dictionary, slot_name: String) -> bool:
	return context.has(slot_name) and _alive(context[slot_name])


static func _alive(bound: Dictionary) -> bool:
	return _exists(String(bound["id"]), String(bound["type"]))


## The bound id for a slot, or "". When `slot_name` is empty the seam's namespace picks the
## slot — which is what lets a single-subject card omit the scope field entirely (§5.2).
static func id_in(context: Dictionary, slot_name: String, seam_name: String = "") -> String:
	if slot_name != "":
		return String((context.get(slot_name, {}) as Dictionary).get("id", ""))
	var want_type: String = _type_for_seam(seam_name)
	for name in context:
		if String((context[name] as Dictionary)["type"]) == want_type:
			return String((context[name] as Dictionary)["id"])
	return ""


static func _type_for_seam(seam_name: String) -> String:
	match seam_name.split(".")[0]:
		"hr": return TYPE_EMPLOYEE
		"founder": return TYPE_FOUNDER
		"musteri": return TYPE_CUSTOMER   # LOC-DATA seam namespace, not copy
		"aday": return TYPE_PROSPECT      # LOC-DATA seam namespace, not copy
		"rival": return TYPE_RIVAL
		"investor": return TYPE_INVESTOR
	return ""


# --- Counting (the entity_count leaf) --------------------------------------

static func count_of(type_id: String) -> int:
	return _ids(type_id).size()


## The live ids of a type: the population a selector and a slot's `where` choose from.
static func _ids(type_id: String) -> Array:
	match type_id:
		TYPE_EMPLOYEE: return CharacterRegistry.get_employees().map(func(c): return c.id)
		TYPE_FOUNDER:
			var f: Character = CharacterRegistry.get_founder()
			return [f.id] if f != null else []
		TYPE_CUSTOMER: return CustomerRegistry.get_active().map(func(c): return c.id)
		TYPE_PROSPECT: return ProspectRegistry.get_all().map(func(o): return o.id)
		TYPE_RIVAL:    return RivalRegistry.get_all().map(func(o): return o.id)
		TYPE_INVESTOR: return InvestorRegistry.get_active().map(func(inv): return String(inv.get("id", "")))
	return []


static func _exists(entity_id: String, type_id: String) -> bool:
	if entity_id == "":
		return false
	match type_id:
		TYPE_EMPLOYEE:
			var c: Character = CharacterRegistry.get_character(entity_id)
			return c != null and c.category == "employee"
		TYPE_FOUNDER:
			var f: Character = CharacterRegistry.get_founder()
			return f != null and f.id == entity_id
		TYPE_CUSTOMER:
			return CustomerRegistry.get_customer(entity_id) != null
		TYPE_PROSPECT:
			return ProspectRegistry.get_prospect(entity_id) != null
		TYPE_RIVAL:
			return RivalRegistry.get_rival(entity_id) != null
		TYPE_INVESTOR:
			return not (InvestorRegistry.get_investor(entity_id) as Dictionary).is_empty()
	return false


# --- Selectors -------------------------------------------------------------
#
# Every selector is DETERMINISTIC: no RNG stream, ties broken by id, so the same world state always
# selects the same subject and a reload cannot reshuffle who a card was about. The ones that draw take
# `roll`, a hash of the day, the card and the slot (EvDice), and index the candidates sorted by id. An
# unnamed or unknown mode takes the first free entity by id.
#
# `bound` carries the slots resolved BEFORE this one, which is what lets a selector be relative
# to another slot (`account_rep`: the rep on the customer this card already bound).

static func _select(type_id: String, mode: String, used: Dictionary, bound: Dictionary, roll: float) -> String:
	if type_id == TYPE_RIVAL:
		return _select_rival(mode, used, roll)
	if mode == "random":
		return _first_free(_ids(type_id), used, roll)
	match type_id:
		TYPE_EMPLOYEE: return _select_employee(mode, used, bound)
		TYPE_CUSTOMER: return _select_customer(mode, used)
		TYPE_PROSPECT:
			if mode == "rep_lead":
				return _first_free(_rep_leads(), used, roll)
		TYPE_INVESTOR: return _select_investor(mode, used)
	return _first_free(_ids(type_id), used)


static func _select_employee(mode: String, used: Dictionary, bound: Dictionary) -> String:
	var pool: Array = CharacterRegistry.get_employees().filter(func(c): return not used.has(c.id))
	if pool.is_empty():
		return ""
	# The best in one area (`top_skill:engineering`): the highest score on the area's ruler, ties by id.
	if mode.begins_with("top_skill:"):
		var area: String = mode.trim_prefix("top_skill:")
		return _first_by(pool, func(c): return -int(c.role_stats.get(area, 0)))
	match mode:
		# Ekip §17.3 names these two for content; the catalogue is where they belong.
		"lowest_morale": return _first_by(pool, func(c): return c.morale)
		"newest_hire": return _first_by(pool, func(c): return -c.hire_day)
		# The highest level, and among them the longest on the payroll (Arrays compare in order).
		"most_senior": return _first_by(pool, func(c): return [-c.level, c.hire_day])
		# `leave_pair`: the most senior working person whose summer leave overlaps a colleague's and starts no later than
		# theirs, early enough that the colleague's leave still fits in the window behind it (summer_leave's `apart`);
		# `leave_partner`: that colleague, relative to the already-bound `employee`.
		"leave_pair":
			var year: int = int(GameState.get_date_dict().year)
			return _first_by(pool.filter(func(c: Character) -> bool:
				var partner: Character = CharacterRegistry.get_character(HRMoraleSystem.leave_partner(c))
				var week: int = HRMoraleSystem.summer_week(c, year)
				return partner != null and c.status == HRConstants.STATUS_ACTIVE and week <= HRMoraleSystem.summer_week(partner, year) \
					and week + HRConstants.LEAVE_WEEKS < HRConstants.LEAVE_WEEK_COUNT),
				func(c): return [-c.level, c.hire_day])
		"leave_partner":
			var first: Character = CharacterRegistry.get_character(String((bound.get("employee", {}) as Dictionary).get("id", "")))
			var partner_id: String = HRMoraleSystem.leave_partner(first) if first != null else ""
			return partner_id if pool.any(func(c: Character) -> bool: return c.id == partner_id) else ""
		# The employee working the already-bound prospect (`rep_lead` picks the lead by the same fact): a lead the founder
		# works at his table names nobody.
		"lead_rep":
			var lead: Prospect = ProspectRegistry.get_prospect(String((bound.get("prospect", {}) as Dictionary).get("id", "")))
			return lead.worked_by if lead != null and pool.any(func(c: Character) -> bool: return c.id == lead.worked_by) else ""
		"account_rep":
			# The rep stewarding the already-bound customer. No rep leaves the slot UNFILLED
			# rather than handing "your rep says" to someone who is not one.
			var acct: String = String((bound.get("customer", {}) as Dictionary).get("id", ""))
			var cust: Customer = CustomerRegistry.get_customer(acct) if acct != "" else null
			if cust == null or cust.assigned_to == "" or used.has(cust.assigned_to):
				return ""
			return cust.assigned_to
		"support_lead":
			# CustomerRepSystem's own ranking, not a second one built here.
			for rep in CustomerRepSystem.ranked_reps():
				if not used.has((rep as Character).id):
					return (rep as Character).id
			return ""
		"sprint_dev":
			# A developer on the running sprint's team, by sprint share (SprintSystem.payers' order): the one a sprint
			# paper's tester or the pending card names besides the speaker.
			for id in SprintSystem.payers(""):
				var dev: Character = CharacterRegistry.get_character(id)
				if pool.has(dev) and dev.role == HRConstants.ROLE_DEVELOPER:
					return id
			return ""
		"decision_dev":
			# A developer on the pending decision's own card, first in its assignment order. The paper is asked for before the
			# card is cleared of people (a decision card gets none in the next assignment), so its assignees are still read.
			for id in SprintSystem.decision_card().get("assignees", []):
				var dev: Character = CharacterRegistry.get_character(id)
				if pool.has(dev) and dev.role == HRConstants.ROLE_DEVELOPER:
					return id
			return ""
		"quarter_pm":
			var pm: Character = SprintCatalog.quarter_pm()
			return pm.id if pm != null and pool.has(pm) else ""
	return _first_by(pool, func(c): return c.id)


## A rival of the player's market (RivalRegistry.get_by_type): the ones the sprint plan names (`sprint_rival`,
## sprint.json's rival table), one tier (`market_rival:giant`, `:established`, `:startup`), or any (`random`).
## Without a `select` it is the market's first free rival by id, undrawn.
static func _select_rival(mode: String, used: Dictionary, roll: float) -> String:
	var pool: Array = RivalRegistry.get_by_type(ProductState.subtype())
	if mode == "sprint_rival":
		var named: Array = SprintCatalog.rival_table().rivals.map(
			func(i: Variant) -> String: return "rv_%s_%d" % [ProductState.subtype(), int(i)])   # LOC-DATA rival id
		pool = pool.filter(func(r: Rival) -> bool: return named.has(r.id))
	elif mode.begins_with("market_rival:"):
		pool = pool.filter(func(r: Rival) -> bool: return r.tier == mode.trim_prefix("market_rival:"))
	return _first_free(pool.map(func(r: Rival) -> String: return r.id), used, roll if mode != "" else 0.0)


static func _select_investor(mode: String, used: Dictionary) -> String:
	match mode:
		"expiring_sheet":
			# The sheet with the fewest weeks left — the same minimum the
			# funding.sheet_weeks_left seam reads, so the card names the investor whose deadline
			# it prints.
			var best: String = ""
			var least: int = 9999
			for sheet in GameState.active_sheets:
				var ts: TermSheet = sheet
				var vc_id: String = String(ts.vc_id)
				if used.has(vc_id) or ts.is_decision_due(GameState.day):
					continue
				var weeks: int = ts.weeks_left(GameState.day)
				if weeks < least or (weeks == least and vc_id < best):
					least = weeks
					best = vc_id
			return best
		"decision_sheet":
			# The sheet waiting for sit-or-decline; the same helper the condition seam reads.
			var due: TermSheet = VCPitchSystem.decision_due_sheet(used)
			return "" if due == null else String(due.vc_id)
		"seed_lead":
			# Before signing only the offer knows whose it is; after signing the offer is
			# cleared and GameState.seed_lead remembers. One selector covers both.
			var sheet: TermSheet = GameState.seed_sheet
			var lead: String = String(sheet.vc_id) if sheet != null else String(GameState.seed_lead)
			return "" if lead == "" or used.has(lead) else lead
	return _first_free(_ids(TYPE_INVESTOR), used)


## The leads an employee is working; one the founder works at his table is not among them.
static func _rep_leads() -> Array:
	var staff: Array = CharacterRegistry.get_employees().map(func(c: Character) -> String: return c.id)
	return ProspectRegistry.get_all().filter(func(p: Prospect) -> bool: return staff.has(p.worked_by)).map(
		func(p: Prospect) -> String: return p.id)


static func _select_customer(mode: String, used: Dictionary) -> String:
	var pool: Array = CustomerRegistry.get_active().filter(func(c): return not used.has(c.id))
	var by_satisfaction := func(c): return c.satisfaction
	match mode:
		"at_risk":
			return _first_by(pool.filter(func(c): return c.lifecycle_phase == "risk"), by_satisfaction)
		"escalated":
			# A selector and not just a condition: the condition is checked against ONE bound
			# subject, so "lowest satisfaction, then is it escalated" would silently never fire
			# whenever those are different customers.
			return _first_by(pool.filter(func(c): return c.cs_escalated), by_satisfaction)
		"expansion_ready":
			return _first_by(pool.filter(func(c): return B2BSalesSystem.can_offer_expansion(c)),
				func(c): return -c.mrr)
		"open_request":
			return _first_by(pool.filter(func(c): return c.support_request_since_day >= 0),
				func(c): return c.support_request_since_day)
		"largest":
			return _first_by(pool, func(c): return -c.mrr)
		"smallest":
			return _first_by(pool, func(c): return c.mrr)
		"line_top", "line_warehouse", "line_newest", "line_slow", "request":
			# An account of the pending sprint decision's line (SprintCatalog.paper_account).
			return SprintCatalog.paper_account(mode, used)
	return _first_by(pool, func(c): return c.id)


## The id of the entity with the smallest `key`, ties broken by id; "" for an empty pool.
static func _first_by(pool: Array, key: Callable) -> String:
	if pool.is_empty():
		return ""
	pool.sort_custom(func(a, b):
		var ka = key.call(a)
		var kb = key.call(b)
		return a.id < b.id if ka == kb else ka < kb)
	return String(pool[0].id)


## The free id at `roll` (0..1) of the ids sorted; the first free one by default.
static func _first_free(ids: Array, used: Dictionary, roll: float = 0.0) -> String:
	var free: Array = ids.filter(func(entity_id: String) -> bool: return not used.has(entity_id))
	free.sort()
	return "" if free.is_empty() else String(free[floori(roll * free.size())])
