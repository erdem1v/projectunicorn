class_name EvEffects
extends RefCounted

# THE EFFECT EXECUTOR (GDD §8). The one place an effect verb becomes a state change.
#
# I2 ("an economic delta arises only from a played decision") is STRUCTURAL here, not only a
# lint rule: `open_negotiation` (§9.4) returns effects that do not exist at build time, and the
# on_expire exception is a SIGN rule lint cannot check on a seam-derived amount. So the
# vocabulary is split by origin:
#
#   run_played()        NEUTRAL + ECONOMIC + TERMINAL      a decision the player made
#   run_expire()        NEUTRAL + ECONOMIC, negative only  the cost of not answering
#   run_ambient()       NEUTRAL                            arc auto-steps, signal handlers,
#                                                          on_invalidate — no economy at all
#   run_check_branch()  NEUTRAL + ECONOMIC, no TERMINAL    a dice outcome (I6)
#
# An ambient caller cannot reach `add_cash` by any content or refactor. `on_expire` and
# `on_invalidate` also read a differently-named field (`penalties`, not `effects`).
#
# Every write goes through the owning system's seam (WRITE-THROUGH LAW). Where no seam exists,
# the verb does not exist either.
#
# Cascades do not happen in the same tick (§8.2): an effect that makes another card's condition
# true is seen by the next tick. That closes the infinite loop and lets arc invalidation always
# read state that settled yesterday.

# --- The three vocabularies ------------------------------------------------
#
# Membership IS the enforcement. Read these as the answer to "what may this origin do".

## Anything that does not move an economic figure. Available to every origin.
const NEUTRAL_VERBS := [
	# flags and memory
	"set_flag", "clear_flag", "set_timed_flag", "stamp_day",
	# scheduling
	"schedule_event", "cancel_scheduled",
	# arcs
	"start_arc", "advance_arc", "set_arc_var", "abort_arc", "end_arc",
	# people — morale and assignment are not economy; salary is, and lives below
	"change_morale", "morale_all", "assign_to", "send_on_leave", "start_training",
	# product
	"dimension_delta", "bug_delta", "delay_days", "damage_product",
	"ship_active_build", "enter_development", "enter_beta",
	# customers — satisfaction is a relationship, not a payment
	"satisfaction_delta", "promise_create",
	# world and surfaces
	"ticker_push", "goto_tab", "unlock_content", "spend_budget", "notify",
	# investor flow that moves no money by itself
	"open_negotiation", "start_vc_meeting", "open_term_table", "advance_phase",
	"phase_gate_decline",
	# Seed rung: the money moves at the table's İMZALA, a played moment, not in a card effect;
	# decline_buyout's declined cash is cash that never arrives.
	"open_seed_table", "decline_buyout",
	# Closes one fund's expired sheet; no money.
	"decline_offer",
	"set_game_flag", "mentor_advisory",
	# B2B outcomes that move no money; b2b_retain_discount and b2b_expand move MRR and are
	# economic.
	"b2b_retain_delay", "b2b_retain_ignore", "b2b_expand_decline",
]

## The only GameState flags content may write, each because a system genuinely reads it.
## Adding a row is a design decision, not a convenience.
const GAME_FLAG_WHITELIST := ["tech_debt_birikti", "critical_bug_unfixed"]

## Verbs that move money, customers, audience or brand. Barred from ambient origins entirely,
## and sign-checked on expiry.
const ECONOMIC_VERBS := [
	"add_cash", "add_mrr", "add_brand", "add_reputation",
	"add_customer", "churn_customer", "customer_mrr_delta", "seats",
	"audience_delta", "convert_audience", "open_paid_tier",
	"change_salary", "fire_employee", "employee_leaves",
	"add_prospect", "angel_accept", "b2b_expand", "b2b_retain_discount",
]

## Ends the run. Played decisions only — never a dice branch (I6), never an expiry, never an
## ambient tick.
const TERMINAL_VERBS := ["trigger_ending"]

## `promise_create` with this feature id promises "what this account wants": the customer's own
## pain feature, resolved when the option is taken.
const PAIN_SENTINEL := "pain"

## What a consumer churn event costs when the "customer" is the whole userbase.
const B2C_CHURN_PCT := 0.15

enum Origin { PLAYED, EXPIRE, AMBIENT, CHECK_BRANCH }

## I3 refusals this run: a card tried to end the run on a telegraph that never fired. The harness
## reports the count (§19.3, "no untelegraphed loss").
static var _untelegraphed_refusals: int = 0


static func untelegraphed_refusals() -> int:
	return _untelegraphed_refusals


static func reset_counters() -> void:
	_untelegraphed_refusals = 0


# --- Entry points ----------------------------------------------------------

## A decision the player made. The only origin with the full vocabulary.
static func run_played(effects: Array, ctx: Dictionary) -> Array:
	return _run(effects, ctx, Origin.PLAYED)


## The cost of not answering (§8.3's one exception). Economic verbs only in the negative
## direction, checked per effect at dispatch, where a seam-derived amount is finally visible.
static func run_expire(effects: Array, ctx: Dictionary) -> Array:
	return _run(effects, ctx, Origin.EXPIRE)


## Arc auto-steps, signal handlers, on_invalidate. Bookkeeping only.
static func run_ambient(effects: Array, ctx: Dictionary) -> Array:
	return _run(effects, ctx, Origin.AMBIENT)


## A dice outcome. Full economy, no terminal — I6 ("zar öldürmez").
static func run_check_branch(effects: Array, ctx: Dictionary) -> Array:
	return _run(effects, ctx, Origin.CHECK_BRANCH)


# --- The dispatcher --------------------------------------------------------

## Returns the delta log: one entry per applied effect, for History's `deltas`, the debug panel
## and the ending screen. A refused effect is logged too, so a rule never acts invisibly.
static func _run(effects: Array, ctx: Dictionary, origin: Origin) -> Array:
	var log: Array = []
	for raw in effects:
		if typeof(raw) != TYPE_DICTIONARY:
			push_error("[EvEffects] effect is not a dictionary: %s" % str(raw))
			continue
		var effect: Dictionary = raw
		var verb: String = String(effect.get("verb", effect.get("type", "")))

		var refusal: String = _permitted(verb, effect, origin)
		if refusal != "":
			# §8.2: loud in the log, silent to the player; the run continues.
			push_error("[EvEffects] refused '%s' from %s: %s"
				% [verb, String(Origin.find_key(origin)).to_lower(), refusal])
			log.append({"verb": verb, "refused": refusal})
			continue

		var entry: Dictionary = _apply(verb, effect, ctx)
		if not entry.is_empty():
			log.append(entry)
	return log


## "" when the verb may run from this origin. THE ENFORCEMENT.
static func _permitted(verb: String, effect: Dictionary, origin: Origin) -> String:
	if verb == "":
		return "no verb named"

	var is_neutral: bool = NEUTRAL_VERBS.has(verb)
	var is_economic: bool = ECONOMIC_VERBS.has(verb)
	var is_terminal: bool = TERMINAL_VERBS.has(verb)

	if not (is_neutral or is_economic or is_terminal):
		return "unknown verb"

	match origin:
		Origin.PLAYED:
			pass                       # the full vocabulary
		Origin.CHECK_BRANCH:
			if is_terminal:
				return "I6: a dice branch may not end the run"
		Origin.EXPIRE:
			if is_terminal:
				return "I3: an expiry may not end the run"
			if is_economic and not _is_negative(effect):
				return "I2: on_expire may apply a negative delta, never a positive one"
		Origin.AMBIENT:
			if is_economic:
				return "I2: an economic delta needs a played decision"
			if is_terminal:
				return "I3: only a played decision may end the run"

	# I3's runtime half (§8.4): a loss the player was never warned about does not happen. The
	# system path (EndingsSystem._assert_telegraph) is loud but never blocking, because a
	# computed bankruptcy is already certain; an authored card is refused here instead.
	if is_terminal or bool(effect.get("is_loss_risk", false)):
		var telegraph: String = String(effect.get("requires_telegraph", ""))
		var refusal: String = ""
		if telegraph == "":
			refusal = "I3: no requires_telegraph declared"
		elif not EvHistory.telegraph_fired(telegraph):
			refusal = "I3: telegraph '%s' never fired" % telegraph
		if refusal != "" and is_terminal:
			_untelegraphed_refusals += 1
		return refusal
	return ""


## Is this economic effect a cost rather than a gain? Reads the amount AS COMPUTED, which is
## the whole point — a literal is easy, a seam-derived figure is what lint cannot see.
static func _is_negative(effect: Dictionary) -> bool:
	for key in ["amount", "delta", "value"]:
		if effect.has(key):
			return float(effect[key]) < 0.0
	# A verb with no signed amount at all (churn_customer, employee_leaves) is a loss by
	# nature, so expiry may apply it.
	return true


# --- Application -----------------------------------------------------------

static func _apply(verb: String, e: Dictionary, ctx: Dictionary) -> Dictionary:
	match verb:
		# --- economy -------------------------------------------------------
		"add_cash":
			var amount: int = _amount(e)
			GameState.set_cash(GameState.cash + amount)
			return {"verb": verb, "amount": amount}
		"add_mrr":
			# No aggregate-MRR write seam exists: SalesSystem.reflect_mrr() derives MRR from the
			# customer book, so a raw write would be reverted. Refused rather than faked.
			push_error("[EvEffects] add_mrr has no write seam — MRR is derived from the book. "
				+ "Use customer_mrr_delta on a named account, or seats.")
			return {"verb": verb, "refused": "no aggregate MRR seam"}
		"add_brand":
			GameState.set_brand(GameState.brand + _amount(e))
			return {"verb": verb, "amount": _amount(e)}
		"add_reputation":
			GameState.set_reputation(GameState.reputation + _amount(e))
			return {"verb": verb, "amount": _amount(e)}
		"customer_mrr_delta":
			var cid: String = _entity(e, ctx, EvScope.TYPE_CUSTOMER)
			var c: Customer = CustomerRegistry.get_customer(cid)
			if c == null:
				return _no_target(verb, cid)
			CustomerRegistry.set_mrr(cid, c.mrr + _amount(e))
			SalesSystem.reflect_mrr()
			return {"verb": verb, "customer": cid, "amount": _amount(e)}
		"seats":
			var sid: String = _entity(e, ctx, EvScope.TYPE_CUSTOMER)
			var sc: Customer = CustomerRegistry.get_customer(sid)
			if sc == null:
				return _no_target(verb, sid)
			var add_seats: int = _amount(e)
			var per_seat: int = int(e.get("per_seat_mrr", 0))
			CustomerRegistry.set_seats(sid, sc.seats + add_seats)
			if per_seat != 0:
				CustomerRegistry.set_mrr(sid, sc.mrr + add_seats * per_seat)
				SalesSystem.reflect_mrr()
			return {"verb": verb, "customer": sid, "seats": add_seats}
		"churn_customer":
			var chid: String = _entity(e, ctx, EvScope.TYPE_CUSTOMER)
			var victim: Customer = CustomerRegistry.get_customer(chid)
			if victim == null:
				return _no_target(verb, chid)
			# B2C is one aggregate record, so churn erodes the AUDIENCE and derived MRR follows;
			# removing it would delete the whole consumer business. B2B removes the account.
			if victim.market_type == "b2c":
				SalesSystem.add_b2c_audience(-int(round(SalesSystem.b2c_audience() * B2C_CHURN_PCT)))
				return {"verb": verb, "customer": chid, "audience_pct": -B2C_CHURN_PCT}
			CustomerRegistry.remove(chid)
			GameState.run_customers_lost += 1
			SalesSystem.reflect_mrr()
			return {"verb": verb, "customer": chid}
		"audience_delta":
			var n: int = _amount(e)
			if e.has("pct"):
				n = int(round(SalesSystem.b2c_audience() * float(e["pct"])))
			SalesSystem.add_b2c_audience(n)
			return {"verb": verb, "amount": n}
		"add_prospect":
			PitchSystem.spawn_prospect(String(e.get("archetype", "small")),
				String(e.get("source", "event")))
			return {"verb": verb, "archetype": e.get("archetype", "small")}

		# --- flags and memory ----------------------------------------------
		"set_flag":
			EvFlags.set_flag(String(e.get("name", "")), "card")
			return {"verb": verb, "name": e.get("name", "")}
		"clear_flag":
			EvFlags.clear_flag(String(e.get("name", "")))
			return {"verb": verb, "name": e.get("name", "")}
		"set_timed_flag":
			EvFlags.set_timed(String(e.get("name", "")), int(e.get("days", 1)), "card")
			return {"verb": verb, "name": e.get("name", ""), "days": e.get("days", 1)}
		"stamp_day":
			EvFlags.stamp(String(e.get("name", "")), "card")
			return {"verb": verb, "name": e.get("name", "")}

		# --- scheduling -----------------------------------------------------
		"schedule_event":
			EvSchedule.add(String(e.get("event_id", "")), int(e.get("delay_days", 1)),
				(e.get("context", ctx) as Dictionary), String(e.get("arc_id", "")))
			return {"verb": verb, "event_id": e.get("event_id", ""),
				"delay_days": e.get("delay_days", 1)}
		"cancel_scheduled":
			var dropped: int = EvSchedule.cancel(String(e.get("event_id", "")))
			return {"verb": verb, "event_id": e.get("event_id", ""), "dropped": dropped}

		# --- arcs -----------------------------------------------------------
		"start_arc":
			var subject: Dictionary = {}
			var slot: String = String(e.get("subject_slot", ""))
			if slot != "" and ctx.has(slot):
				subject = ctx[slot]
			return {"verb": verb, "arc": e.get("arc_id", ""),
				"started": EvArcs.start(String(e.get("arc_id", "")), subject)}
		"advance_arc":
			return {"verb": verb, "arc": e.get("arc_id", ""),
				"step": EvArcs.advance(String(e.get("arc_id", "")), int(e.get("step", -1)))}
		"set_arc_var":
			EvArcs.set_var(String(e.get("arc_id", "")), String(e.get("key", "")), e.get("value"))
			return {"verb": verb, "arc": e.get("arc_id", ""), "key": e.get("key", "")}
		"abort_arc":
			EvArcs.abort(String(e.get("arc_id", "")), String(e.get("reason", "unspecified")))
			return {"verb": verb, "arc": e.get("arc_id", "")}
		"end_arc":
			EvArcs.end(String(e.get("arc_id", "")), String(e.get("outcome", "")))
			return {"verb": verb, "arc": e.get("arc_id", ""), "outcome": e.get("outcome", "")}

		# --- people ----------------------------------------------------------
		"change_morale":
			var eid: String = _entity(e, ctx, EvScope.TYPE_EMPLOYEE)
			var emp: Character = CharacterRegistry.get_character(eid)
			if emp == null:
				return _no_target(verb, eid)
			# Through HRMoraleSystem.apply_delta, where the trait multiplier and the founder's
			# Liderlik climate coefficient live; a raw write would skip both.
			if emp.category == "employee":
				HRMoraleSystem.apply_delta(emp, _amount(e), "event")
			else:
				CharacterRegistry.set_morale(eid, emp.morale + _amount(e))
			return {"verb": verb, "employee": eid, "amount": _amount(e)}
		"morale_all":
			for worker in CharacterRegistry.get_employees():
				HRMoraleSystem.apply_delta(worker, _amount(e), "event")
			return {"verb": verb, "amount": _amount(e)}
		"employee_leaves":
			var lid: String = _entity(e, ctx, EvScope.TYPE_EMPLOYEE)
			if CharacterRegistry.get_character(lid) == null:
				return _no_target(verb, lid)
			HRMoraleSystem.confirm_departure(lid)
			return {"verb": verb, "employee": lid, "reason": e.get("reason", "")}

		# --- customers --------------------------------------------------------
		"satisfaction_delta":
			var scid: String = _entity(e, ctx, EvScope.TYPE_CUSTOMER)
			var sat_c: Customer = CustomerRegistry.get_customer(scid)
			if sat_c == null:
				return _no_target(verb, scid)
			CustomerRegistry.set_satisfaction(scid, sat_c.satisfaction + _amount(e))
			return {"verb": verb, "customer": scid, "amount": _amount(e)}
		"promise_create":
			var pcid: String = _entity(e, ctx, EvScope.TYPE_CUSTOMER)
			var pfid: String = String(e.get("feature_id", ""))
			if pfid == PAIN_SENTINEL:
				var pc: Customer = CustomerRegistry.get_customer(pcid)
				pfid = pc.pain_feature_id if pc != null else ""
			if pfid == "":
				return _no_target(verb, pcid)
			B2BSalesSystem.accept_promise(pcid, pfid, int(e.get("deadline_days", 14)))
			return {"verb": verb, "customer": pcid, "feature": pfid}

		# --- product ----------------------------------------------------------
		"dimension_delta":
			ProductSystem.apply_dimension_delta(String(e.get("axis", "innovation")), _amount(e))
			return {"verb": verb, "axis": e.get("axis", "innovation"), "amount": _amount(e)}
		"bug_delta":
			ProductSystem.apply_bug_delta(_amount(e))
			return {"verb": verb, "amount": _amount(e)}
		"delay_days":
			# The seam no-ops without an active build; logging the refusal keeps a card from
			# silently claiming time it did not take.
			if ProductSystem.get_active_build() == null:
				return {"verb": verb, "refused": "no active build; a day cost cannot apply"}
			ProductSystem.apply_speed_bonus(int(e.get("days", 0)))
			return {"verb": verb, "days": e.get("days", 0)}
		"ship_active_build":
			ProductSystem.ship_active_build()
			return {"verb": verb}
		"enter_development":
			ProductSystem.enter_development()
			return {"verb": verb}
		"enter_beta":
			ProductSystem.enter_beta()
			return {"verb": verb}

		# --- world and surfaces -----------------------------------------------
		"ticker_push":
			# §18: the ticker is atmosphere, never the ONLY channel — anything meaningful here is
			# also in History.
			EvTicker.push(String(e.get("line_key", "")), String(e.get("priority", "world")), ctx)
			return {"verb": verb, "line_key": e.get("line_key", "")}
		"goto_tab":
			var tab_id: String = String(e.get("tab_id", ""))
			EventBus.tab_changed.emit(tab_id)
			var subpage: String = String(e.get("subpage", ""))
			if subpage != "":
				EventBus.finance_subpage_requested.emit(subpage)
			return {"verb": verb, "tab": tab_id, "subpage": subpage}
		"notify":
			# class: info's surface. Badge state belongs to the owning module, so this nudges it
			# rather than duplicating its counter.
			EventBus.headline_added.emit(String(e.get("source", "")), String(e.get("text", "")))
			return {"verb": verb, "module": e.get("module", "")}
		"unlock_content":
			EvFlags.set_flag("unlocked_%s" % String(e.get("content_id", "")), "card")
			return {"verb": verb, "content": e.get("content_id", "")}
		"spend_budget":
			var budget: String = String(e.get("name", ""))
			var left: int = EvBudgets.spend(budget)
			return {"verb": verb, "budget": budget, "left": left}

		# --- investor flow -----------------------------------------------------
		"advance_phase":
			GameState.advance_phase()
			return {"verb": verb, "phase": GameState.phase}
		"phase_gate_decline":
			PhaseGateSystem.on_gate_declined()
			return {"verb": verb}
		"angel_accept":
			AngelRoundSystem.accept_offer()
			return {"verb": verb}
		"start_vc_meeting":
			# The investor comes from the bound slot; no card can name one at authoring time.
			var mvc: String = _entity(e, ctx, EvScope.TYPE_INVESTOR)
			if mvc == "":
				return _no_target(verb, mvc)
			VCPitchSystem.begin_meeting(mvc)
			return {"verb": verb, "vc": mvc}
		"open_term_table":
			# A literal vc_id wins; otherwise the bound investor slot.
			var tvc: String = String(e.get("vc_id", ""))
			if tvc == "":
				tvc = _entity(e, ctx, EvScope.TYPE_INVESTOR)
			if tvc == "":
				return _no_target(verb, tvc)
			EventBus.term_table_requested.emit(tvc)
			return {"verb": verb, "vc": tvc}
		"decline_offer":
			var dvc: String = _entity(e, ctx, EvScope.TYPE_INVESTOR)
			if dvc == "":
				return _no_target(verb, dvc)
			if not VCPitchSystem.decline_expired_sheet(dvc):
				return {"verb": verb, "refused": "no sheet awaiting a decision"}
			return {"verb": verb, "vc": dvc}
		"open_seed_table":
			# The seed offer knows whose it is, and there is only ever one.
			if GameState.seed_sheet == null:
				return {"verb": verb, "refused": "no seed offer on the table"}
			EventBus.term_table_requested.emit(String(GameState.seed_sheet.vc_id))
			return {"verb": verb, "vc": GameState.seed_sheet.vc_id}
		"decline_buyout":
			EndingsSystem.on_buyout_declined()
			return {"verb": verb}
		"open_negotiation":
			# §9.4, return contract TEMPORARY in the GDD (§23 A4). Not wired: nothing opens a
			# scene yet. When it is, the effects it hands back must run with the origin of the
			# option that opened it, or they would be a hole through I2.
			return {"verb": verb, "negotiation": e.get("negotiation_type", ""), "deferred": true}

		# --- narrow doors ---------------------------------------------------
		"set_game_flag":
			# A whitelisted door into GameState (WRITE-THROUGH LAW): anything else needs a named
			# verb through its owning system's seam.
			var flag_name: String = String(e.get("name", ""))
			if not GAME_FLAG_WHITELIST.has(flag_name):
				push_error("[EvEffects] set_game_flag refused '%s'; only %s may be written "
					% [flag_name, str(GAME_FLAG_WHITELIST)] + "from content")
				return {"verb": verb, "refused": "not whitelisted"}
			GameState.set_flag(flag_name, e.get("value", true))
			return {"verb": verb, "name": flag_name, "value": e.get("value", true)}

		"mentor_advisory":
			# The latched line on the ODA phone glass: a key, resolved at emit in the live locale.
			EventBus.mentor_advisory_changed.emit(
				TranslationServer.translate(String(e.get("line_key", ""))))
			return {"verb": verb, "line_key": e.get("line_key", "")}

		# --- B2B outcomes, each through its owning seam ---------------------
		"b2b_retain_delay":
			B2BSalesSystem.hold(_entity(e, ctx, EvScope.TYPE_CUSTOMER))
			return {"verb": verb}
		"b2b_retain_discount":
			var dc: String = _entity(e, ctx, EvScope.TYPE_CUSTOMER)
			var dcust: Customer = CustomerRegistry.get_customer(dc)
			if dcust == null:
				return _no_target(verb, dc)
			B2BSalesSystem.apply_discount(dc,
				-int(round(float(dcust.mrr) * B2BConstants.RETAIN_DISCOUNT_PCT)))
			return {"verb": verb, "customer": dc}
		"b2b_retain_ignore":
			B2BSalesSystem.ignore_risk(_entity(e, ctx, EvScope.TYPE_CUSTOMER))
			return {"verb": verb}
		"b2b_expand":
			var ec: String = _entity(e, ctx, EvScope.TYPE_CUSTOMER)
			var ecust: Customer = CustomerRegistry.get_customer(ec)
			if ecust == null:
				return _no_target(verb, ec)
			B2BSalesSystem.expand(ec, B2BConstants.expansion_seats(ecust.company_size),
				B2BConstants.EXPANSION_PER_SEAT_MRR)
			return {"verb": verb, "customer": ec}
		"b2b_expand_decline":
			B2BSalesSystem.decline_expansion(_entity(e, ctx, EvScope.TYPE_CUSTOMER))
			return {"verb": verb}

		# --- terminal -----------------------------------------------------------
		"trigger_ending":
			# _permitted already refused an untelegraphed ending.
			EndingsSystem.trigger_ending(String(e.get("ending_id", "")),
				String(e.get("requires_telegraph", "")))
			return {"verb": verb, "ending": e.get("ending_id", "")}

	push_error("[EvEffects] no application for verb '%s'" % verb)
	return {"verb": verb, "refused": "not implemented"}


# --- Helpers ---------------------------------------------------------------

static func _amount(e: Dictionary) -> int:
	for key in ["amount", "delta", "value"]:
		if e.has(key):
			return int(e[key])
	return 0


## The entity this effect targets: an explicit id, else the named slot, else the first slot of
## the right type. Resolved fresh per effect — §8.2 lists are non-atomic, so an earlier effect
## can remove the entity a later one aims at.
static func _entity(e: Dictionary, ctx: Dictionary, want_type: String) -> String:
	if e.has("entity_id"):
		return String(e["entity_id"])
	var slot: String = String(e.get("scope", ""))
	if slot != "":
		return String((ctx.get(slot, {}) as Dictionary).get("id", ""))
	for name in ctx:
		if String((ctx[name] as Dictionary).get("type", "")) == want_type:
			return String((ctx[name] as Dictionary)["id"])
	return ""


## §8.2: "hedef yoksa no-op" — but never a silent one.
static func _no_target(verb: String, entity_id: String) -> Dictionary:
	push_error("[EvEffects] '%s' found no target (id '%s')" % [verb, entity_id])
	return {"verb": verb, "refused": "no target"}
