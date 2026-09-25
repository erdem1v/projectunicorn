class_name EvScope
extends RefCounted

# NAMED SCOPE SLOTS (GDD §4.3). A card declares the entities it is about, by name and by type:
#
#     scope:
#       employee_a: { type: employee, required: true,  select: lowest_morale }
#       employee_b: { type: employee, required: true }
#       customer:   { type: customer, required: false }
#
# THE ONE RULE EVERYTHING ELSE SERVES: never guess. §4.3 says it in one line — "Asla tahmin
# edilmez. Belirsiz kapsam = red. Yanlış varlık silmenin tek sebebi tahmindir." An unresolvable
# slot means the card is not admitted; it does not mean the engine picks something plausible.
# The old engine guessed by default — a customer-scoped modifier with no target fell through
# to "the most at-risk account anywhere", which in a mixed portfolio is an enterprise contract,
# and a consumer support event could therefore delete one (event_manager.gd:667-691 carries the
# scar tissue of that being fixed under a different name).
#
# THE FOUNDER IS A SEPARATE TYPE, and the data model already agrees: he is a Character with
# category "founder" (game_state.gd:948-1006), and CharacterRegistry.get_employees() filters by
# category — so the employee selector cannot return him even by accident. Ekip GDD 02 §5's
# ruling ("kurucu bir işgücü birimi değildir") holds without the engine enforcing anything.
#
# WHAT GOES IN THE FROZEN CONTEXT — and this is the part that would be a bug if written the
# obvious way. Context is {slot: {type, id, bound_day}}. SCALARS ONLY. Never the Character.
# Character extends Resource, so SaveCodec.res_to_dict would cheerfully serialise a whole
# private copy of a departed employee into the save file, and a load would hand that copy back
# as if the person were still here. §20 A2 exists to prevent exactly that resurrection; storing
# the object would create it instead. The id is enough to detect death, and detecting death is
# all the engine needs — CharacterRegistry.remove() erases the id, so a dead subject resolves
# to null and display re-validation drops the card.
#
# That guarantee rests on ids never being reused. §10.9 says a rehired employee is a NEW entity
# with a NEW id, and CharacterRegistry.add() refuses a colliding id. This is the one place
# where "silent rejection" would otherwise degrade into "silent WRONG target", which is
# strictly worse than a crash — so a smoke case pins id monotonicity across a full run.

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
## `given` is what the caller already knows — a signal that carried an employee_id, an arc that
## remembers its subject. §4.3's order: what the caller supplied wins, then the selector runs.
##
## REQUIRED SLOTS ARE RESOLVED FIRST, which the GDD does not say and needs to. With two slots
## of one type and one candidate, resolving in declaration order can hand the only candidate to
## an OPTIONAL slot and then fail the required one — the card is rejected while a perfectly good
## binding existed. Required-first cannot lose that way.
static func resolve(slots: Dictionary, given: Dictionary = {}) -> Dictionary:
	var context: Dictionary = {}
	var used: Dictionary = {}          # entity id -> slot that took it

	var ordered: Array = _required_first(slots)

	for slot_name in ordered:
		var spec: Dictionary = slots[slot_name]
		var type_id: String = String(spec.get("type", ""))
		if not TYPES.has(type_id):
			push_error("[EvScope] slot '%s' declares unknown type '%s'" % [slot_name, type_id])
			return {"ok": false, "context": {}, "unresolved": slot_name}

		var chosen: String = ""

		# 1. The caller knew. Still type-checked: a signal carrying the wrong kind of id is a
		#    bug in the emitter, and binding it anyway would make the card lie about its own
		#    subject.
		if given.has(slot_name):
			var candidate: String = String(given[slot_name])
			if _is_of_type(candidate, type_id) and not used.has(candidate):
				chosen = candidate

		# 2. The engine selects. Type-safe by construction: each selector reads one registry.
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
	req.append_array(opt)
	return req


# --- Re-validation ---------------------------------------------------------

## Is every bound entity still alive? Run at display (§4.4) and again at resolution (§20 A2),
## and once more per effect (§8.2 makes effect lists non-atomic, so effect one can remove the
## entity effect three targets).
static func still_valid(context: Dictionary) -> bool:
	for slot_name in context:
		var bound: Dictionary = context[slot_name]
		if not _exists(String(bound["id"]), String(bound["type"])):
			return false
	return true


## The slot whose entity has gone, or "". What the panel and the history row report.
static func first_dead_slot(context: Dictionary) -> String:
	for slot_name in context:
		var bound: Dictionary = context[slot_name]
		if not _exists(String(bound["id"]), String(bound["type"])):
			return slot_name
	return ""


static func resolved(context: Dictionary, slot_name: String) -> bool:
	if not context.has(slot_name):
		return false
	var bound: Dictionary = context[slot_name]
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
	var ns: String = seam_name.split(".")[0]
	match ns:
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


# --- Existence and type ----------------------------------------------------

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


static func _is_of_type(entity_id: String, type_id: String) -> bool:
	return _exists(entity_id, type_id)


# --- Selectors -------------------------------------------------------------
#
# Ekip §17.3 names the three the content actually wants — "en düşük moralli çalışan", "en
# yeni işe alınan", "şu alanın lideri" — and says they are built on the read catalogue, on the
# engine's side. That is what these are. Every one is DETERMINISTIC: no RNG, ties broken by id,
# so the same world state always selects the same subject and a reload cannot reshuffle who a
# card was about.

## `bound` carries the slots resolved BEFORE this one, which is what makes a selector able to
## be RELATIVE to another slot — `account_rep` means "the rep on the customer this card already
## bound", and there is no other way to say that without the caller doing the picking, which is
## the thing §4.3 exists to stop.
static func _select(type_id: String, mode: String, used: Dictionary,
		bound: Dictionary = {}) -> String:
	match type_id:
		TYPE_EMPLOYEE: return _select_employee(mode, used, bound)
		TYPE_FOUNDER:
			var f: Character = CharacterRegistry.get_founder()
			return f.id if f != null and not used.has(f.id) else ""
		TYPE_CUSTOMER: return _select_customer(mode, used)
		TYPE_PROSPECT: return _first_free(_ids_of(ProspectRegistry.get_all()), used)
		TYPE_RIVAL:    return _first_free(_ids_of(RivalRegistry.get_all()), used)
		TYPE_INVESTOR: return _select_investor(mode, used)
	return ""


static func _select_employee(mode: String, used: Dictionary, bound: Dictionary = {}) -> String:
	var pool: Array = []
	for c in CharacterRegistry.get_employees():
		if not used.has((c as Character).id):
			pool.append(c)
	if pool.is_empty():
		return ""

	match mode:
		"lowest_morale":
			pool.sort_custom(func(a, b): return _tie(a.morale, b.morale, a.id, b.id))
		"highest_morale":
			pool.sort_custom(func(a, b): return _tie(-a.morale, -b.morale, a.id, b.id))
		"newest_hire":
			pool.sort_custom(func(a, b): return _tie(-a.hire_day, -b.hire_day, a.id, b.id))
		"longest_tenure":
			pool.sort_custom(func(a, b): return _tie(a.hire_day, b.hire_day, a.id, b.id))
		"most_loaded":
			pool.sort_custom(func(a, b): return _tie(
				-HRSystem.job_count(a), -HRSystem.job_count(b), a.id, b.id))
		"account_rep":
			# The rep stewarding the customer this card already bound. If the account has no
			# rep the slot goes UNFILLED rather than quietly handing the line to a developer —
			# a card whose fiction is "your rep says" must not be spoken by someone who is not
			# one. A required slot then refuses at G5, which is the correct outcome.
			var acct: String = _bound_id(bound, "customer")
			if acct == "":
				return ""
			var cust: Customer = CustomerRegistry.get_customer(acct)
			if cust == null or cust.assigned_to == "" or used.has(cust.assigned_to):
				return ""
			return cust.assigned_to
		"support_lead":
			# CustomerRepSystem's own ranking, not a second one built here.
			for rep in CustomerRepSystem.ranked_reps():
				if not used.has((rep as Character).id):
					return (rep as Character).id
			return ""
		_:
			# No selector named: the roster in registry order. Stable, and deliberately not
			# "random" — a card about "an employee" should be about the same one if the world
			# has not changed.
			pool.sort_custom(func(a, b): return a.id < b.id)
	return (pool[0] as Character).id


static func _select_investor(mode: String, used: Dictionary) -> String:
	match mode:
		"expiring_sheet":
			# The sheet with the fewest days left. A SELECTOR, because the seam behind the
			# card's condition is a MINIMUM across live sheets: bind the first investor by id
			# and the card reads one investor's name beside another investor's deadline. That
			# is the constant-id bug the old _build_expiry_warning_event had, and it would
			# have come straight back through the scope slot.
			var best: String = ""
			var least: int = 9999
			for sheet in GameState.active_sheets:
				var vc_id: String = String(sheet.vc_id)
				if used.has(vc_id) or (sheet as TermSheet).is_decision_due(GameState.day):
					continue
				# Business days, the same count funding.sheet_days_left returns (K5).
				var days: int = (sheet as TermSheet).business_days_left(GameState.day)
				if days < least or (days == least and vc_id < best):
					least = days
					best = vc_id
			return best
		"decision_sheet":
			# K10: the sheet whose window has closed and waits for sit-or-decline. The same
			# helper the condition seam reads, so the card names the fund it is about.
			var due: TermSheet = VCPitchSystem.decision_due_sheet(used)
			return "" if due == null else String(due.vc_id)
		"meeting_pending":
			var pm: Dictionary = GameState.pending_meeting
			var vc: String = String(pm.get("vc_id", ""))
			return "" if vc == "" or used.has(vc) else vc
		"seed_lead":
			# The fund on the seed rung. The SHEET first and the recorded lead second, because
			# the two are true at different times: before signing only the offer knows whose it
			# is, and after signing the offer is cleared and GameState.seed_lead is the memory.
			# One selector covers both, so the offer card and the buyout card bind the same slot.
			var sheet: TermSheet = GameState.seed_sheet
			var lead: String = String(sheet.vc_id) if sheet != null else String(GameState.seed_lead)
			return "" if lead == "" or used.has(lead) else lead
	return _first_free(_investor_ids(), used)


static func _select_customer(mode: String, used: Dictionary) -> String:
	var pool: Array = []
	for c in CustomerRegistry.get_active():
		if not used.has((c as Customer).id):
			pool.append(c)
	if pool.is_empty():
		return ""

	match mode:
		"lowest_satisfaction":
			pool.sort_custom(func(a, b): return _tie(a.satisfaction, b.satisfaction, a.id, b.id))
		"largest_mrr":
			pool.sort_custom(func(a, b): return _tie(-a.mrr, -b.mrr, a.id, b.id))
		"at_risk":
			pool = pool.filter(func(c): return c.lifecycle_phase == "risk")
			if pool.is_empty():
				return ""
			pool.sort_custom(func(a, b): return _tie(a.satisfaction, b.satisfaction, a.id, b.id))
		"newest":
			pool.sort_custom(func(a, b): return _tie(
				-a.acquired_on_day, -b.acquired_on_day, a.id, b.id))
		"escalated":
			# An account whose rep has raised the alarm. A SELECTOR and not just a condition,
			# because the condition is checked against ONE bound subject: selecting the
			# lowest-satisfaction account and then asking "is it escalated" silently never
			# fires whenever those two are different customers, and nothing says so.
			pool = pool.filter(func(c): return c.cs_escalated)
			if pool.is_empty():
				return ""
			pool.sort_custom(func(a, b): return _tie(a.satisfaction, b.satisfaction, a.id, b.id))
		"expansion_ready":
			pool = pool.filter(func(c): return B2BSalesSystem.can_offer_expansion(c))
			if pool.is_empty():
				return ""
			pool.sort_custom(func(a, b): return _tie(-a.mrr, -b.mrr, a.id, b.id))
		"open_request":
			pool = pool.filter(func(c): return c.support_request_since_day >= 0)
			if pool.is_empty():
				return ""
			pool.sort_custom(func(a, b): return _tie(
				a.support_request_since_day, b.support_request_since_day, a.id, b.id))
		_:
			pool.sort_custom(func(a, b): return a.id < b.id)
	return (pool[0] as Customer).id


## Ascending on the key, ties broken by id so the order is total and reproducible.
static func _tie(ka, kb, ida: String, idb: String) -> bool:
	if ka == kb:
		return ida < idb
	return ka < kb


## The id already bound into `slot_name`, or "" if that slot has not been resolved yet.
static func _bound_id(bound: Dictionary, slot_name: String) -> String:
	if not bound.has(slot_name):
		return ""
	return String((bound[slot_name] as Dictionary).get("id", ""))


static func _first_free(ids: Array, used: Dictionary) -> String:
	var sorted_ids: Array = ids.duplicate()
	sorted_ids.sort()
	for entity_id in sorted_ids:
		if not used.has(entity_id):
			return String(entity_id)
	return ""


static func _ids_of(objects: Array) -> Array:
	var out: Array = []
	for o in objects:
		out.append(o.id)
	return out


static func _investor_ids() -> Array:
	var out: Array = []
	for inv in InvestorRegistry.get_active():
		out.append(String((inv as Dictionary).get("id", "")))
	return out
