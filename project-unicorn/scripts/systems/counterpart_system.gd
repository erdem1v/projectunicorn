class_name CounterpartSystem
extends RefCounted

# The people across the table at an outside meeting. Each fund has three, drawn once per run and
# kept (GameState.investor_people): its lead, of the sex its copy gives them when it gives one, a
# partner and an analyst, their looks apart from the team's at the start and from each other's. A
# sales prospect brings as many as its stars (the buyer, then the user team's manager, then
# finance), drawn from its id each time they are needed and never kept, their looks apart from the
# founder's and each other's. Names come from the pool of the language the run began in
# (GameState.name_lang), no two alike at one table. Their looks are not issued to the run
# (GameState.issued_looks): none of them works in the office.

const ROLE_LEAD := "vc_lead"
const ROLE_PARTNER := "vc_partner"
const ROLE_ANALYST := "vc_analyst"
const FUND_ROLES := [ROLE_LEAD, ROLE_PARTNER, ROLE_ANALYST]
const ROLE_BUYER := "buyer"
const ROLE_USER := "user_lead"
const ROLE_FINANCE := "finance"
const PROSPECT_ROLES := [ROLE_BUYER, ROLE_USER, ROLE_FINANCE]
## Role -> its title's key. A fund's lead carries the fund's own title (InvestorRegistry.role_line).
const ROLE_KEYS := {
	ROLE_PARTNER: "MEETING_ROLE_PARTNER",
	ROLE_ANALYST: "MEETING_ROLE_ANALYST",
	ROLE_BUYER: "MEETING_ROLE_BUYER",
	ROLE_USER: "MEETING_ROLE_USER",
	ROLE_FINANCE: "MEETING_ROLE_FINANCE",
}


## Draws every fund's three when the run has none yet (a new run, or a save from before them), and
## draws the look of a kept one who wears Frank's (LookSystem.is_franks) again.
static func fill_investor_people() -> void:
	var around := CharacterRegistry.looks_around()
	if GameState.investor_people.is_empty():
		for inv: Dictionary in InvestorRegistry.get_active():
			GameState.investor_people[inv.id] = _people_for(inv.id, FUND_ROLES, around, inv.get("lead_sex", ""))
	for vc_id: String in GameState.investor_people:
		var side: Array = GameState.investor_people[vc_id]
		for person: Dictionary in side:
			if LookSystem.is_franks(person.look):
				person.look = _look(_draw(vc_id, person.role), person.name, person.role,
					around + side.map(func(q: Dictionary) -> Dictionary: return q.look))


## `vc_id`'s three, lead first: [{role, name, look}].
static func investor_people(vc_id: String) -> Array:
	return GameState.investor_people.get(vc_id, [])


static func lead(vc_id: String) -> Dictionary:
	return investor_people(vc_id)[0]


## The prospect's side of the table, as many as its stars: [{role, name, look}].
static func prospect_people(p: Prospect) -> Array:
	return _people_for(p.id, PROSPECT_ROLES.slice(0, p.star), [CharacterRegistry.get_founder().look])


## The buyer an account was won from: its lead's first person (an account's id is its lead's).
static func buyer_of(c: Customer) -> Dictionary:
	return _people_for(c.id.trim_prefix("co_"), [ROLE_BUYER], [CharacterRegistry.get_founder().look])[0]


## `person`'s title in the live locale; a lead's is its fund's (`vc_id`).
static func title(person: Dictionary, vc_id := "") -> String:
	if person.role == ROLE_LEAD:
		return InvestorRegistry.role_line(vc_id)
	return TranslationServer.translate(ROLE_KEYS[person.role])


## One person per role for `identity`: no two share a first or a last name, the first is named for
## `first_sex` ("m" / "w") when given, and each look stands apart from `around` and from the ones
## drawn before it, which join `around`.
static func _people_for(identity: String, roles: Array, around: Array, first_sex := "") -> Array:
	var used_first := []
	var used_last := []
	var out := []
	for role: String in roles:
		var draw := _draw(identity, role)
		var sex := first_sex if out.is_empty() else ""
		var firsts := HRConstants.first_names(GameState.name_lang).filter(func(n: String) -> bool:
			return sex.is_empty() or HRConstants.FIRST_NAME_SEX.get(n, "") == sex)
		var person_name := "%s %s" % [
			HRCandidateGenerator.take_unused(firsts, used_first, draw),
			HRCandidateGenerator.take_unused(HRConstants.last_names(GameState.name_lang), used_last,
				SalesConstants.mix_seed(draw, SalesConstants.SALT_PEOPLE))]
		var look := _look(draw, person_name, role, around)
		around.append(look)
		out.append({"role": role, "name": person_name, "look": look})
	return out


## The seed `identity`'s person in `role` is drawn from.
static func _draw(identity: String, role: String) -> int:
	return SalesConstants.mix("%s:%s" % [identity, role], SalesConstants.SALT_PEOPLE)


## That person's look, from its own seed: a name worn by both sexes draws the sex from it.
static func _look(draw: int, person_name: String, role: String, around: Array) -> Dictionary:
	return LookSystem.for_person(SalesConstants.mix_seed(draw, SalesConstants.SALT_LOOK), person_name, role, around)
