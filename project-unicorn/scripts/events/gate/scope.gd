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


# --- Resolution ------------------------------------------------------------

## Bind every declared slot. Returns {ok: bool, context: Dictionary, unresolved: String}.
##
## `given` is what the caller already knows (a signal's employee_id, an arc's subject); §4.3:
## what the caller supplied wins, then the selector runs.
##
## REQUIRED SLOTS ARE RESOLVED FIRST. With two slots of one type and one candidate, declaration
## order could hand the only candidate to an optional slot and then fail the required one.
static func resolve(slots: Dictionary, given: Dictionary = {}) -> Dictionary:
	var context: Dictionary = {}
	var used: Dictionary = {}          # entity id -> slot that took it

	for slot_name in _required_first(slots):
		var spec: Dictionary = slots[slot_name]
		var type_id: String = String(spec.get("type", ""))
		if not TYPES.has(type_id):
			push_error("[EvScope] slot '%s' declares unknown type '%s'" % [slot_name, type_id])
			return {"ok": false, "context": {}, "unresolved": slot_name}

		# A given id is still type-checked: binding the wrong kind would make the card lie
		# about its own subject.
		var chosen: String = ""
		if given.has(slot_name):
			var candidate: String = String(given[slot_name])
			if _exists(candidate, type_id) and not used.has(candidate):
				chosen = candidate
		if chosen == "":
			chosen = _select(type_id, String(spec.get("select", "")), used, context)

		if chosen == "":
			if bool(spec.get("required", true)):
				return {"ok": false, "context": context, "unresolved": slot_name}
			continue

		used[chosen] = slot_name
		context[slot_name] = {"type": type_id, "id": chosen, "bound_day": GameState.day}

	return {"ok": true, "context": context, "unresolved": ""}


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
		"rival": return TYPE_RIVAL
		"investor": return TYPE_INVESTOR
	return ""


# --- Counting (the entity_count leaf) --------------------------------------

static func count_of(type_id: String) -> int:
	match type_id:
		TYPE_EMPLOYEE: return CharacterRegistry.get_employees().size()
		TYPE_FOUNDER:  return 1 if CharacterRegistry.get_founder() != null else 0
		TYPE_CUSTOMER: return CustomerRegistry.get_active().size()
		TYPE_PROSPECT: return ProspectRegistry.count()
		TYPE_RIVAL:    return RivalRegistry.get_all().size()
		TYPE_INVESTOR: return InvestorRegistry.get_active().size()
	return 0


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
# Every selector is DETERMINISTIC: no RNG, ties broken by id, so the same world state always
# selects the same subject and a reload cannot reshuffle who a card was about. An unnamed or
# unknown mode takes the first free entity by id.
#
# `bound` carries the slots resolved BEFORE this one, which is what lets a selector be relative
# to another slot (`account_rep`: the rep on the customer this card already bound).

static func _select(type_id: String, mode: String, used: Dictionary, bound: Dictionary) -> String:
	match type_id:
		TYPE_EMPLOYEE: return _select_employee(mode, used, bound)
		TYPE_FOUNDER:
			var f: Character = CharacterRegistry.get_founder()
			return f.id if f != null and not used.has(f.id) else ""
		TYPE_CUSTOMER: return _select_customer(mode, used)
		TYPE_PROSPECT: return _first_free(ProspectRegistry.get_all().map(func(o): return o.id), used)
		TYPE_RIVAL:    return _first_free(RivalRegistry.get_all().map(func(o): return o.id), used)
		TYPE_INVESTOR: return _select_investor(mode, used)
	return ""


static func _select_employee(mode: String, used: Dictionary, bound: Dictionary) -> String:
	var pool: Array = CharacterRegistry.get_employees().filter(func(c): return not used.has(c.id))
	if pool.is_empty():
		return ""
	match mode:
		# Ekip §17.3 names these two for content; the catalogue is where they belong.
		"lowest_morale": return _first_by(pool, func(c): return c.morale)
		"newest_hire": return _first_by(pool, func(c): return -c.hire_day)
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
	return _first_by(pool, func(c): return c.id)


static func _select_investor(mode: String, used: Dictionary) -> String:
	match mode:
		"expiring_sheet":
			# The sheet with the fewest business days left — the same minimum the
			# funding.sheet_days_left seam reads, so the card names the investor whose deadline
			# it prints.
			var best: String = ""
			var least: int = 9999
			for sheet in GameState.active_sheets:
				var ts: TermSheet = sheet
				var vc_id: String = String(ts.vc_id)
				if used.has(vc_id) or ts.is_decision_due(GameState.day):
					continue
				var days: int = ts.business_days_left(GameState.day)
				if days < least or (days == least and vc_id < best):
					least = days
					best = vc_id
			return best
		"decision_sheet":
			# The sheet waiting for sit-or-decline; the same helper the condition seam reads.
			var due: TermSheet = VCPitchSystem.decision_due_sheet(used)
			return "" if due == null else String(due.vc_id)
		"meeting_pending":
			var vc: String = String(GameState.pending_meeting.get("vc_id", ""))
			return "" if vc == "" or used.has(vc) else vc
		"seed_lead":
			# Before signing only the offer knows whose it is; after signing the offer is
			# cleared and GameState.seed_lead remembers. One selector covers both.
			var sheet: TermSheet = GameState.seed_sheet
			var lead: String = String(sheet.vc_id) if sheet != null else String(GameState.seed_lead)
			return "" if lead == "" or used.has(lead) else lead
	return _first_free(InvestorRegistry.get_active().map(
		func(inv): return String((inv as Dictionary).get("id", ""))), used)


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
	return _first_by(pool, func(_c): return 0)


## The id of the entity with the smallest `key`, ties broken by id; "" for an empty pool.
static func _first_by(pool: Array, key: Callable) -> String:
	if pool.is_empty():
		return ""
	pool.sort_custom(func(a, b):
		var ka = key.call(a)
		var kb = key.call(b)
		return a.id < b.id if ka == kb else ka < kb)
	return String(pool[0].id)


static func _first_free(ids: Array, used: Dictionary) -> String:
	var sorted_ids: Array = ids.duplicate()
	sorted_ids.sort()
	for entity_id in sorted_ids:
		if not used.has(entity_id):
			return String(entity_id)
	return ""
