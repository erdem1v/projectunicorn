class_name SalesProbes
extends RefCounted

# THE STORYLET PICKER (§11.2) and the fact dictionary it matches against (§11.6).
#
# WHY A PICKER AND NOT A DIALOGUE TREE. §1 names the second death the module has to solve:
# RNG monotony. A hand-branched tree gives every player the same four beats and pays for
# variety in combinatorial content. A criteria-scored catalogue makes "the engine cannot claim
# what it does not read" a STRUCTURAL property instead of a review rule: a row is eligible
# only if its criteria match FACTS, and FACTS is built exclusively from named queries. A
# writer cannot invent "the rival's offer is serious", because there is no fact by that name.
#
# SELECTION (§11.2). Every eligible row is scored by how many criteria it matched — MOST
# SPECIFIC WINS — and ties break on the repeat memory first (a line the run has already used
# loses to one it has not) and then on a deterministic hash, so the same state on the same day
# produces the same interrogation after a reload.
#
# THE LINES ARE CSV KEYS DERIVED FROM IDS: `SALES_PROBE_<ID>`, `SALES_ANS_<ID>_<ANSWER>` (`answer_key`) and
# `SALES_LOCK_<FACT>`. No grep for a literal finds them, so `loc_sales_derived_keys` walks this
# catalogue and asks the translation server for each one.
#
# ANSWER VERBS (§5.1, internal taxonomy — never drawn as a fixed palette, §5.1.1):
#   strength   "Gücü göster"     — open ONLY on a real strength; otherwise a locked row that
#                                  names the actual gap ("Sunucuların Ekonomik kademede.")
#   admit      "Kabul et"        — always open; some archetypes pay an honesty premium
#   promise    "Söz ver"         — §6's single-open-promise lock; narrows the Act 2 band
#   charisma   "Yönü çevir"      — open only when the founder HAS Charisma (§5.1, moment 1)
#   reference  "Referans göster" — open only with an active account at this star or above.
#                                  A REFERENCE IS NEVER ASKED FOR (§5.1 ruling): its absence
#                                  produces no ▼ and enters no input.

const VERB_STRENGTH := "strength"
const VERB_ADMIT := "admit"
const VERB_PROMISE := "promise"
const VERB_CHARISMA := "charisma"
const VERB_REFERENCE := "reference"


# ============================================================================
#  §11.6 — the fact dictionary. EVERY entry is a named query.
# ============================================================================

## Flat facts for one table. A catalogue row keyed on anything not listed here cannot be
## eligible: `matches` refuses it with a warning. §11.6's attribution linter, which would
## refuse such a row before a build, is not built.
static func facts_for(p: Prospect) -> Dictionary:
	var sub_id: String = String(GameState.get_flag("mvp_sub_product_type_id", ""))
	var ctx: Dictionary = ProductQuality.prospect_ctx(p)
	var emphasis: String = ProductQuality.emphasis(p.industry)[0]
	return {
		# --- the table itself ---
		"customer_star": p.star,
		"archetype": p.archetype_id,
		"buyer": SalesArchetypes.buyer(p.archetype_id),
		"temperament": SalesArchetypes.temperament(p.archetype_id),
		"is_whale": p.is_whale,
		"whale_condition": p.whale_condition,
		"returning": p.loss_count > 0,
		"last_loss_reason": p.last_loss_reason,
		# --- the product, through the areas this table's sector weighs (ProductQuality) ---
		"emphasis_area": emphasis,
		"emphasis_enough": ProductQuality.is_enough(emphasis, ctx),
		# An area the table's star does not look at asks nothing of the product.
		"onboarding_enough": ProductQuality.expectation("onboarding", ctx) == 0.0 or ProductQuality.is_enough("onboarding", ctx),
		# --- the product, through Ürün §19 ---
		"unconfirmed_reports": ProductRead.unconfirmed(),
		"version_age": ProductRead.version_age(),   # weeks
		"interest": int(ProductRead.interest()),
		"lines_open": ProductRead.lines_open(),
		"steps_shipped": ProductRead.steps_shipped(),
		"has_locked_next_step": locked_line() != "",
		"support_staffed": ProductRead.support_staffed(),
		# --- infrastructure, through Ürün §10 ---
		"provider": InfraSystem.provider(),
		"provider_not_economy": not InfraSystem.is_economy(),
		# --- R&D ---
		"security_cert": ResearchSeam.completed("security_cert"),
		# --- the company, through Ekip §15.3 ---
		"headcount": HRSystem.headcount(),
		"cs_staffed": not HRSystem.assigned_to(HRConstants.AREA_CUSTOMER_SUCCESS).is_empty(),
		"founder_sales_star": SalesLedger.founder_star(),
		"founder_charisma": GameState.get_founder_skill(FounderConstants.SKILL_CHARISMA),
		# --- the book ---
		"account_count": CustomerRegistry.get_by_market("b2b").size(),
		"has_reference": _has_reference(p.star),
		"open_pitch_promise": SalesLedger.open_pitch_promise() != "",
		# §11.9 — a Söz row is offered only when there is something to promise; with no target
		# the verb is absent rather than offered and then silently broken.
		"has_promise_target": B2BSalesSystem.pick_pain_feature(sub_id, 0) != "",
	}


## The first line whose next step exists and is NOT unlockable — the "kilitli üst kademe" a
## whale asks for (§8, Ürün §15) and the target a missing-tier loss names (§5.2). "" when every
## line's next step is reachable.
static func locked_line() -> String:
	var sub_id: String = String(GameState.get_flag("mvp_sub_product_type_id", ""))
	for line_id in ProductLines.line_ids(sub_id):
		var step_id: String = ProductRead.line_next_step("", String(line_id))
		if step_id != "" and not ProductRead.step_unlockable(step_id):
			return String(line_id)
	return ""


## §5.1 — a reference is playable when at least one ACTIVE account sits at this table's star
## or above. Its absence is never a minus; it is a card the player may or may not hold.
static func _has_reference(star: int) -> bool:
	for c in CustomerRegistry.get_by_market("b2b"):
		if (c as Customer).scale >= star:
			return true
	return false


## What every emphasis row answers: the three rows ask one question about three areas.
const EMPHASIS_ANSWERS := [
	{"id": "a_strength", "verb": VERB_STRENGTH, "delta": 1.0,
		"gate": {"emphasis_enough": true}, "lock_fact": "emphasis_enough"},
	{"id": "a_admit", "verb": VERB_ADMIT, "delta": 0.35},
	{"id": "a_charisma", "verb": VERB_CHARISMA, "delta": 0.8,
		"gate": {"founder_charisma": {"min": 1}}},
]


# ============================================================================
#  The catalogue. Rows are DATA; the picker below is the only thing that reads them.
# ============================================================================
#
# ROW SHAPE
#   id            stable, and the id the run's repeat memory records
#   family        the topic; the picker never runs two rows of one family in one sitting
#   criteria      {fact_key: matcher}. A matcher is a literal (equality) or
#                 {"min": n} / {"max": n} / {"in": [...]}. MORE CRITERIA = MORE SPECIFIC.
#   area          the product area the row's lines name as {area}, when they name one
#   answers_as    the stem of the answer lines' CSV keys (the row's id when absent): rows that ask one question in several
#                 ways share their answer lines
#   answers       2-4 contextual rows, each {id, verb, gate, delta, lock_fact}
#                   gate       optional criteria the ANSWER needs to be OPEN
#                   delta      the ▲/▼ this verb moves the needle by, as a share of the base
#                   lock_fact  which fact the lock line names when the gate fails; a locked
#                              row is drawn ONLY when it is informative (§5.1.1)
const CATALOGUE := [
	# --- The sector's emphasis: every buyer asks about the area its sector weighs most ---
	{
		"id": "probe_emphasis_trust",
		"family": "emphasis",
		"criteria": {"emphasis_area": "trust"},
		"area": "trust",
		"answers_as": "probe_emphasis",
		"answers": EMPHASIS_ANSWERS,
	},
	{
		"id": "probe_emphasis_integrations",
		"family": "emphasis",
		"criteria": {"emphasis_area": "integrations"},
		"area": "integrations",
		"answers_as": "probe_emphasis",
		"answers": EMPHASIS_ANSWERS,
	},
	{
		"id": "probe_emphasis_onboarding",
		"family": "emphasis",
		"criteria": {"emphasis_area": "onboarding"},
		"area": "onboarding",
		"answers_as": "probe_emphasis",
		"answers": EMPHASIS_ANSWERS,
	},

	# --- The ladder / integrations ----------------------------------------
	{
		"id": "probe_ladder_reach",
		"family": "ladder",
		"criteria": {},
		"answers": [
			{"id": "a_strength", "verb": VERB_STRENGTH, "delta": 1.0,
				"gate": {"steps_shipped": {"min": 4}}, "lock_fact": "steps_shipped"},
			{"id": "a_admit", "verb": VERB_ADMIT, "delta": 0.35},
			{"id": "a_promise", "verb": VERB_PROMISE, "delta": 0.9},
		],
	},
	{
		"id": "probe_ladder_locked",
		"family": "ladder",
		"criteria": {"has_locked_next_step": true, "buyer": SalesArchetypes.BUYER_TECHNICAL},
		"answers": [
			{"id": "a_admit", "verb": VERB_ADMIT, "delta": 0.4},
			{"id": "a_promise", "verb": VERB_PROMISE, "delta": 0.85},
			{"id": "a_charisma", "verb": VERB_CHARISMA, "delta": 0.75,
				"gate": {"founder_charisma": {"min": 1}}},
		],
	},

	# --- The provider / trust ---------------------------------------------
	{
		"id": "probe_provider_trust",
		"family": "provider",
		"criteria": {"customer_star": {"min": 2}},
		"answers": [
			{"id": "a_strength", "verb": VERB_STRENGTH, "delta": 1.0,
				"gate": {"provider_not_economy": true}, "lock_fact": "provider"},
			{"id": "a_admit", "verb": VERB_ADMIT, "delta": 0.35},
			{"id": "a_reference", "verb": VERB_REFERENCE, "delta": 0.7,
				"gate": {"has_reference": true}},
		],
	},

	# --- Who do I call — the support desk ---------------------------------
	{
		"id": "probe_who_do_i_call",
		"family": "support",
		"criteria": {},
		"answers": [
			{"id": "a_strength", "verb": VERB_STRENGTH, "delta": 1.0,
				"gate": {"cs_staffed": true}, "lock_fact": "cs_staffed"},
			{"id": "a_admit", "verb": VERB_ADMIT, "delta": 0.4},
			{"id": "a_charisma", "verb": VERB_CHARISMA, "delta": 0.85,
				"gate": {"founder_charisma": {"min": 1}}},
		],
	},

	# --- Switching risk ----------------------------------------------------
	{
		"id": "probe_switching_risk",
		"family": "switching",
		"criteria": {"customer_star": {"min": 2}},
		"area": "onboarding",
		"answers": [
			{"id": "a_strength", "verb": VERB_STRENGTH, "delta": 1.0,
				"gate": {"onboarding_enough": true}, "lock_fact": "onboarding_enough"},
			{"id": "a_admit", "verb": VERB_ADMIT, "delta": 0.4},
			{"id": "a_promise", "verb": VERB_PROMISE, "delta": 0.8},
		],
	},
]


# ============================================================================
#  Selection
# ============================================================================

## Pick the next probe for this sitting. `used_families` is the sitting's memory and
## `GameState.sales_line_memory` the run's; both are consulted, the sitting's first — no family
## repeats inside one meeting, and across the run a fresh row beats one already spoken (§11.2).
##
## Returns {} when nothing is eligible, which the meeting reads as "the customer has no more
## questions" and closes on the current reading.
static func pick(facts: Dictionary, used_families: Array, seed_value: int) -> Dictionary:
	var best_score: int = -1
	var pool: Array = []
	for row in CATALOGUE:
		var r: Dictionary = row as Dictionary
		if used_families.has(String(r.get("family", ""))):
			continue
		var crit: Dictionary = r.get("criteria", {}) as Dictionary
		if not matches(crit, facts):
			continue
		var score: int = crit.size()
		if score > best_score:
			best_score = score
			pool = [r]
		elif score == best_score:
			pool.append(r)
	if pool.is_empty():
		return {}
	# Tie break 1 — the run's repeat memory: a row this run has not used yet wins outright.
	var fresh: Array = []
	for r in pool:
		if not GameState.sales_line_memory.has(String((r as Dictionary).get("id", ""))):
			fresh.append(r)
	if not fresh.is_empty():
		pool = fresh
	# Tie break 2 — deterministic. Same state, same day, same probe after a reload.
	return pool[absi(seed_value) % pool.size()] as Dictionary


## Record that a row was spoken. The run memory is what makes §11.6's repeat histogram
## measurable and what keeps a flavour slot from returning before its pool is spent.
static func remember(row_id: String) -> void:
	GameState.sales_line_memory[row_id] = int(GameState.sales_line_memory.get(row_id, 0)) + 1


## Criteria matcher. A literal compares by equality; a dictionary carries min / max / in.
static func matches(criteria: Dictionary, facts: Dictionary) -> bool:
	for key in criteria.keys():
		var k: String = String(key)
		if not facts.has(k):
			# A criterion with no fact behind it is a CONTENT ERROR, not a near miss (§11.6):
			# refusing the row means a typo drops a line rather than silently claiming one.
			push_warning("[SalesProbes] criterion '%s' has no fact — see facts_for()" % k)
			return false
		if not _matches_one(criteria[key], facts[k]):
			return false
	return true


static func _matches_one(matcher: Variant, value: Variant) -> bool:
	if typeof(matcher) != TYPE_DICTIONARY:
		return matcher == value
	var m: Dictionary = matcher as Dictionary
	if m.has("min") and float(value) < float(m["min"]):
		return false
	if m.has("max") and float(value) > float(m["max"]):
		return false
	if m.has("in") and not (m["in"] as Array).has(value):
		return false
	return true


## The answer rows for one probe, each already resolved to open / locked with its reason.
## A locked row is returned ONLY when it is informative (§5.1.1: "Kilit yalnız o an bilgi
## taşıyorsa"); an answer whose gate fails on a fact the player cannot read is dropped rather
## than drawn as a mystery. `promise_lock` is the promise row's lock fact, "" when it is open.
static func answers_for(row: Dictionary, facts: Dictionary, promise_lock: String) -> Array:
	var out: Array = []
	for a in (row.get("answers", []) as Array):
		var ans: Dictionary = (a as Dictionary).duplicate(true)
		var gate: Dictionary = ans.get("gate", {}) as Dictionary
		var open: bool = gate.is_empty() or matches(gate, facts)
		if String(ans.get("verb", "")) == VERB_PROMISE:
			if not bool(facts.get("has_promise_target", false)):
				continue   # nothing to promise; the row is absent, never a broken offer
			if promise_lock != "":
				open = false
				ans["lock_fact"] = promise_lock
		ans["open"] = open
		if not open and not ans.has("lock_fact"):
			continue   # a lock with nothing to say is not drawn
		# §5.1 ruling — a reference is a card the player holds, never a question. An
		# unplayable reference row is simply absent; it never appears as a lock.
		if not open and String(ans.get("verb", "")) == VERB_REFERENCE:
			continue
		out.append(ans)
	return out


## The CSV key of one answer's line; rows that share their answers (`answers_as`) share the lines.
static func answer_key(row: Dictionary, answer_id: String) -> String:
	return "SALES_ANS_%s_%s" % [String(row.get("answers_as", row.id)).to_upper(), answer_id.to_upper()]
