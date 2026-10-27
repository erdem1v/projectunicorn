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
	# people — morale, pace, hours and assignment are not economy; salary is, and lives below
	"change_morale", "morale_all", "morale_crew", "assign_to", "send_on_leave", "summer_leave", "sick_leave",
	"start_training", "productivity_mod", "work_hours",
	# product — a line's bugs: one that lands now, and the rewrite that keeps new ones off it
	"damage_product", "line_harden",
	# sprint — the card a sprint decision is about, and the sprint's work hours
	"sprint_card_effort", "sprint_card_progress", "sprint_card_carry", "sprint_card_test", "sprint_hours",
	"sprint_fix_first", "sprint_card_trim", "sprint_card_outlook", "sprint_card_first",
	# a card for the next sprint, and the effects a card's test holds back until it is done
	"queue_card", "after_test",
	# customers — satisfaction is a relationship, not a payment; whose desk an account sits on is not either
	"satisfaction_delta", "trust_delta", "promise_create", "promise_extend", "take_account",
	# the sales meeting's emphasis
	"pitch_focus",
	# the server contract: the tier stays and the capacity does not fall, which moves no money by itself
	"server_lock",
	# world and surfaces
	"ticker_push", "goto_tab", "unlock_content", "spend_budget", "notify",
	# investor flow that moves no money by itself
	"open_negotiation", "open_term_table", "advance_phase",
	"phase_gate_decline",
	# Seed rung: the money moves at the table's İMZALA, a played moment, not in a card effect;
	# decline_buyout's declined cash is cash that never arrives.
	"open_seed_table", "decline_buyout",
	# Closes one fund's expired sheet; no money. A strain cools the fund's next room.
	"decline_offer", "investor_strain",
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
	"change_salary", "fire_employee", "employee_leaves", "promote",
	"add_prospect", "angel_accept", "b2b_expand", "b2b_retain_discount", "b2b_month_discount", "marketing_push", "incident",
	"promise_break", "account_notice", "prospect_offer", "drop_prospect", "server_price",
]

## Ends the run. Played decisions only — never a dice branch (I6), never an expiry, never an
## ambient tick.
const TERMINAL_VERBS := ["trigger_ending"]

## `promise_create` with this feature id promises "what this account wants": the customer's own
## pain feature, resolved when the option is taken.
const PAIN_SENTINEL := "pain"

## A `line` / `until` argument with this value names the pending sprint decision's own line or step.
const DECISION := "decision"
## A `line` argument with this value names the line the open emergency hit.
const INCIDENT := "incident"

## What a consumer churn event costs when the "customer" is the whole userbase.
const B2C_CHURN_PCT := 0.15

enum Origin { PLAYED, EXPIRE, AMBIENT, CHECK_BRANCH }

## I3 refusals this run: a card tried to end the run with no telegraph declared, or on one that
## never fired. The harness reports the count (§19.3, "no untelegraphed loss").
static var _untelegraphed_refusals: int = 0


static func untelegraphed_refusals() -> int:
	return _untelegraphed_refusals


static func reset_counters() -> void:
	_untelegraphed_refusals = 0


# --- Entry points ----------------------------------------------------------
#
# `card_id` names the card the effects belong to ("" for an arc's own penalties): a pace row keeps
# that card's title, so the Ekip tooltip can say what slowed the person.

## A decision the player made. The only origin with the full vocabulary.
static func run_played(effects: Array, ctx: Dictionary, card_id := "") -> Array:
	return _run(effects, ctx, Origin.PLAYED, card_id)


## The cost of not answering (§8.3's one exception). Economic verbs only in the negative
## direction, checked per effect at dispatch, where a seam-derived amount is finally visible.
static func run_expire(effects: Array, ctx: Dictionary, card_id := "") -> Array:
	return _run(effects, ctx, Origin.EXPIRE, card_id)


## Arc auto-steps, signal handlers, on_invalidate. Bookkeeping only.
static func run_ambient(effects: Array, ctx: Dictionary) -> Array:
	return _run(effects, ctx, Origin.AMBIENT, "")


## A dice outcome. Full economy, no terminal — I6 ("zar öldürmez").
static func run_check_branch(effects: Array, ctx: Dictionary, card_id := "") -> Array:
	return _run(effects, ctx, Origin.CHECK_BRANCH, card_id)


# --- The dispatcher --------------------------------------------------------

## Returns the delta log: one entry per applied effect, for History's `deltas`, the debug panel
## and the ending screen. A refused effect is logged too, so a rule never acts invisibly.
static func _run(effects: Array, ctx: Dictionary, origin: Origin, card_id: String) -> Array:
	var log: Array = []
	for raw in effects:
		if typeof(raw) != TYPE_DICTIONARY:
			push_error("[EvEffects] effect is not a dictionary: %s" % str(raw))
			continue
		var effect: Dictionary = raw
		var verb: String = String(effect.get("verb", ""))

		var refusal: String = _permitted(verb, effect, origin, ctx)
		if refusal != "":
			# §8.2: loud in the log, silent to the player; the run continues.
			push_error("[EvEffects] refused '%s' from %s: %s"
				% [verb, String(Origin.find_key(origin)).to_lower(), refusal])
			log.append({"verb": verb, "refused": refusal})
			continue

		var entry: Dictionary = _apply(verb, effect, ctx, card_id)
		if not entry.is_empty():
			log.append(entry)
	return log


## "" when the verb may run from this origin. THE ENFORCEMENT.
static func _permitted(verb: String, effect: Dictionary, origin: Origin, ctx: Dictionary = {}) -> String:
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
			if is_economic and not _is_negative(effect, ctx):
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


## Is this economic effect a cost rather than a gain? A literal figure is read as it lands; a seam's
## figure by the sign of its `amount_mult`, which is how lint judges it too, because the figure the
## seam yields can round down to nothing and a cost that reads zero is still a cost.
static func _is_negative(effect: Dictionary, ctx: Dictionary) -> bool:
	# A marketing push spends money to buy growth: never only a cost, so never an expiry's.
	if String(effect.get("verb", "")) == "marketing_push":
		return false
	if String(effect.get("verb", "")) == "server_price" or effect.has("amount_seam"):
		return not is_authored_gain(effect)
	for key in ["amount", "delta", "value"]:
		if effect.has(key):
			return amount(effect, ctx) < 0
	# A verb with no signed amount at all (churn_customer, employee_leaves) is a loss by
	# nature, so expiry may apply it.
	return true


# --- Application -----------------------------------------------------------

static func _apply(verb: String, e: Dictionary, ctx: Dictionary, card_id: String) -> Dictionary:
	match verb:
		# --- economy -------------------------------------------------------
		"add_cash":
			# Through Finance's one-time door, so a card's money reaches the month's books and
			# the transactions list; `label` is the line the player reads there.
			var cash: int = amount(e, ctx)
			var label: String = String(e.get("label", ""))
			if cash < 0:
				FinanceSystem.apply_one_time_cost(-cash, label)
			else:
				FinanceSystem.apply_one_time_income(cash, label)
			return {"verb": verb, "amount": cash}
		"add_mrr":
			# No aggregate-MRR write seam exists: SalesSystem.reflect_mrr() derives MRR from the
			# customer book, so a raw write would be reverted. Refused rather than faked.
			push_error("[EvEffects] add_mrr has no write seam — MRR is derived from the book. "
				+ "Use customer_mrr_delta on a named account, or seats.")
			return {"verb": verb, "refused": "no aggregate MRR seam"}
		"add_brand":
			GameState.set_brand(GameState.brand + amount(e, ctx))
			return {"verb": verb, "amount": amount(e, ctx)}
		"add_reputation":
			GameState.set_reputation(GameState.reputation + amount(e, ctx))
			return {"verb": verb, "amount": amount(e, ctx)}
		"customer_mrr_delta":
			var cid: String = entity_of(e, ctx, EvScope.TYPE_CUSTOMER)
			var c: Customer = CustomerRegistry.get_customer(cid)
			if c == null:
				return _no_target(verb, cid)
			CustomerRegistry.set_mrr(cid, c.mrr + amount(e, ctx))
			SalesSystem.reflect_mrr()
			return {"verb": verb, "customer": cid, "amount": amount(e, ctx)}
		"seats":
			var sid: String = entity_of(e, ctx, EvScope.TYPE_CUSTOMER)
			var sc: Customer = CustomerRegistry.get_customer(sid)
			if sc == null:
				return _no_target(verb, sid)
			var add_seats: int = amount(e, ctx)
			var per_seat: int = int(e.get("per_seat_mrr", 0))
			CustomerRegistry.set_seats(sid, sc.seats + add_seats)
			if per_seat != 0:
				CustomerRegistry.set_mrr(sid, sc.mrr + add_seats * per_seat)
				SalesSystem.reflect_mrr()
			return {"verb": verb, "customer": sid, "seats": add_seats}
		"churn_customer":
			var chid: String = entity_of(e, ctx, EvScope.TYPE_CUSTOMER)
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
			var n: int = amount(e, ctx)
			if e.has("pct"):
				n = int(round(SalesSystem.b2c_audience() * float(e["pct"])))
			SalesSystem.add_b2c_audience(n)
			return {"verb": verb, "amount": n}
		"add_prospect":
			SalesFaucetSystem.spawn_prospect(String(e.get("archetype", "small")),
				String(e.get("source", "event")))
			return {"verb": verb, "archetype": e.get("archetype", "small")}
		"marketing_push":
			var push: Dictionary = FinanceSystem.start_marketing_push(int(e.get("burn_pct", 0)),
				int(e.get("growth_pct", 0)), int(e.get("weeks", 0)))
			push["verb"] = verb
			return push
		# An emergency's answer: when the service is back, and what the accounts or the audience are given and lose.
		"incident":
			return IncidentSystem.resolve(String(e.get("act", "")))

		# --- flags and memory ----------------------------------------------
		"set_flag":
			EvFlags.set_flag(String(e.get("name", "")), "card")
			return {"verb": verb, "name": e.get("name", "")}
		"clear_flag":
			EvFlags.clear_flag(String(e.get("name", "")))
			return {"verb": verb, "name": e.get("name", "")}
		"set_timed_flag":
			EvFlags.set_timed(String(e.get("name", "")), int(e.get("weeks", 1)), "card")
			return {"verb": verb, "name": e.get("name", ""), "weeks": e.get("weeks", 1)}
		"stamp_day":
			EvFlags.stamp(String(e.get("name", "")), "card")
			return {"verb": verb, "name": e.get("name", "")}

		# --- scheduling -----------------------------------------------------
		"schedule_event":
			# A window draws its week from the day, the card that schedules and the card it schedules, so a
			# reload and a second look at the same day get the same week.
			var span: Array = delay_bounds(e)
			var weeks: int = span[0] + floori(EvDice.unit("schedule", GameState.day, card_id,
				String(e.get("event_id", ""))) * (span[1] - span[0] + 1))
			EvSchedule.add(String(e.get("event_id", "")), weeks,
				(e.get("context", ctx) as Dictionary), String(e.get("arc_id", "")))
			return {"verb": verb, "event_id": e.get("event_id", ""), "delay_weeks": weeks}
		"cancel_scheduled":
			var dropped: int = EvSchedule.cancel(String(e.get("event_id", "")))
			return {"verb": verb, "event_id": e.get("event_id", ""), "dropped": dropped}

		# --- arcs -----------------------------------------------------------
		"start_arc":
			# The slot rides with the subject, so the arc's later steps are handed the same
			# binding under the same name (EvEngine._arc_context).
			var subject: Dictionary = {}
			var slot: String = String(e.get("subject_slot", ""))
			if slot != "" and ctx.has(slot):
				subject = (ctx[slot] as Dictionary).duplicate()
				subject["slot"] = slot
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
			var eid: String = entity_of(e, ctx, EvScope.TYPE_EMPLOYEE)
			var emp: Character = CharacterRegistry.get_character(eid)
			if emp == null:
				return _no_target(verb, eid)
			# Through HRMoraleSystem.apply_delta, where the trait multiplier and the founder's
			# Liderlik climate coefficient live; a raw write would skip both.
			if emp.category == "employee":
				HRMoraleSystem.apply_delta(emp, amount(e, ctx))
			else:
				CharacterRegistry.set_morale(eid, emp.morale + amount(e, ctx))
			return {"verb": verb, "employee": eid, "amount": amount(e, ctx)}
		"morale_all":
			for worker in CharacterRegistry.get_employees():
				HRMoraleSystem.apply_delta(worker, amount(e, ctx))
			return {"verb": verb, "amount": amount(e, ctx)}
		"morale_crew":
			var crew: Array = crew_of(e, ctx)
			if crew.is_empty():
				return _no_target(verb, String(e.get("crew", "")))
			var hit: int = amount(e, ctx)
			for id in crew:
				HRMoraleSystem.apply_delta(CharacterRegistry.get_character(id), hit)
			return {"verb": verb, "amount": hit, "names": crew_names(crew)}
		"productivity_mod":
			# The row keeps the card's title key, not text, so the tooltip reads in the live language (a variant
			# title keeps the arm its seam picks now; an inline arm is the words themselves).
			var title: String = EvPresenter.leaf_text(EvPresenter.text_block(EvCatalog.card(card_id)).get("title", ""))
			var pct: int = int(e.get("pct", 0))
			var weeks: int = int(e.get("weeks", 1))
			if String(e.get("scope", "")) == "team":
				# The running sprint's team: the people whose points make its capacity.
				var team: Array = SprintSystem.team()
				if SprintSystem.mode() != "active" or team.is_empty():
					return _no_target(verb, "team")
				var landed_all: Dictionary
				for member in team:
					landed_all = HRSystem.add_productivity_mod(member.id, pct, weeks, card_id, title)
				return {"verb": verb, "scope": "team", "pct": landed_all.pct, "weeks": landed_all.weeks}
			var pid: String = entity_of(e, ctx, EvScope.TYPE_EMPLOYEE)
			if CharacterRegistry.get_character(pid) == null:
				return _no_target(verb, pid)
			var landed: Dictionary = HRSystem.add_productivity_mod(pid, pct, weeks, card_id, title)
			return {"verb": verb, "employee": pid, "pct": landed.pct, "weeks": landed.weeks}
		# The player's leave, under the dossier action's rules: the record keeps the morale it promised.
		"send_on_leave":
			var vid: String = entity_of(e, ctx, EvScope.TYPE_EMPLOYEE)
			var away: Character = CharacterRegistry.get_character(vid)
			if away == null:
				return _no_target(verb, vid)
			var leave_weeks: int = int(e.get("weeks", HRConstants.VACATION_WEEKS_MIN))
			if not HRActions.apply_leave(away, leave_weeks):
				return {"verb": verb, "refused": HRActions.leave_block_reason(away)}
			return {"verb": verb, "employee": vid, "weeks": leave_weeks, "gain": HRActions.leave_gain(away, leave_weeks)}
		# Two colleagues' summer leaves this year (HRMoraleSystem.plan_summer_leave); the leave itself still starts on HR's tick.
		"summer_leave":
			var leave: Dictionary = summer_leave_plan(e, ctx)
			if leave.is_empty():
				return _no_target(verb, String(e.get("other", "")))
			HRMoraleSystem.apply_summer_leave(leave)
			return leave.merged({"verb": verb})
		# Sickness: out of work for a while, but not the player's leave (HRMoraleSystem.send_on_sick_leave).
		"sick_leave":
			var sid: String = entity_of(e, ctx, EvScope.TYPE_EMPLOYEE)
			var sick: Character = CharacterRegistry.get_character(sid)
			if sick == null:
				return _no_target(verb, sid)
			var sick_weeks: int = int(e.get("weeks", 1))
			if not HRMoraleSystem.send_on_sick_leave(sick, sick_weeks):
				return {"verb": verb, "refused": HRActions.leave_block_reason(sick)}
			return {"verb": verb, "employee": sid, "weeks": sick_weeks}
		# One step up the levels under the dossier's rules; the raise and the morale come with it, so no raise verb follows.
		"promote":
			var rid: String = entity_of(e, ctx, EvScope.TYPE_EMPLOYEE)
			var risen: Character = CharacterRegistry.get_character(rid)
			if risen == null:
				return _no_target(verb, rid)
			if not HRActions.apply_promotion(risen, int(e.get("pct", HRConstants.PROMOTION_MIN_PCT))):
				return {"verb": verb, "refused": HRActions.promotion_block_reason(risen)}
			return {"verb": verb, "employee": rid, "level": risen.level, "salary": risen.monthly_salary}
		"work_hours":
			var hid: String = entity_of(e, ctx, EvScope.TYPE_EMPLOYEE)
			if CharacterRegistry.get_character(hid) == null:
				return _no_target(verb, hid)
			var hours: int = int(e.get("hours", HRConstants.WORK_HOURS_DEFAULT))
			WorkHoursSystem.set_person_hours(hid, hours)
			return {"verb": verb, "employee": hid, "hours": hours}
		"employee_leaves":
			var lid: String = entity_of(e, ctx, EvScope.TYPE_EMPLOYEE)
			if CharacterRegistry.get_character(lid) == null:
				return _no_target(verb, lid)
			HRMoraleSystem.confirm_departure(lid)
			return {"verb": verb, "employee": lid, "reason": e.get("reason", "")}

		# --- customers --------------------------------------------------------
		"satisfaction_delta":
			var scid: String = entity_of(e, ctx, EvScope.TYPE_CUSTOMER)
			var sat_c: Customer = CustomerRegistry.get_customer(scid)
			if sat_c == null:
				return _no_target(verb, scid)
			CustomerRegistry.set_satisfaction(scid, sat_c.satisfaction + amount(e, ctx))
			return {"verb": verb, "customer": scid, "amount": amount(e, ctx)}
		# The lasting half of a satisfaction hit: the trust ledger, never the visible number the drift
		# erases within a tick. The row keeps what the chip showed (trust_plan).
		"trust_delta":
			var plan: Dictionary = trust_plan(e, ctx)
			if plan.accounts.is_empty():
				return _no_target(verb, String(e.get("accounts", "slot")))
			var ids: Array = plan.accounts.map(func(row: Dictionary) -> String: return row.id)
			for id in ids:
				var tc: Customer = CustomerRegistry.get_customer(id)
				CustomerRegistry.set_trust_offset(id, tc.trust_offset + plan.amount)
			if plan.per_sprint != 0:
				B2BSalesSystem.add_trust_drain(ids, plan.per_sprint, _until(e))
			return plan.merged({"verb": verb})
		# The account leaves in EXIT_NOTICE_WEEKS whatever the server does; `mail` false when the card is the notice.
		"account_notice":
			var nid: String = entity_of(e, ctx, EvScope.TYPE_CUSTOMER)
			var noticed: Customer = CustomerRegistry.get_customer(nid)
			if noticed == null:
				return _no_target(verb, nid)
			if not B2BSalesSystem.give_notice(noticed, String(e.get("reason", "")), bool(e.get("mail", true))):
				return {"verb": verb, "refused": "the account has given notice already"}
			return {"verb": verb, "customer": nid, "company": noticed.display_name(), "weeks": B2BConstants.EXIT_NOTICE_WEEKS}
		# The account's calls come to the founder's desk and stay there (cs_pinned keeps the stewardship rule off it).
		"take_account":
			var tid: String = entity_of(e, ctx, EvScope.TYPE_CUSTOMER)
			var taken: Customer = CustomerRegistry.get_customer(tid)
			if taken == null:
				return _no_target(verb, tid)
			CustomerRegistry.assign_customer(tid, "", true)
			return {"verb": verb, "customer": tid, "company": taken.display_name()}
		"promise_create":
			var pcid: String = entity_of(e, ctx, EvScope.TYPE_CUSTOMER)
			var pfid: String = String(e.get("feature_id", ""))
			if pfid == PAIN_SENTINEL:
				var pc: Customer = CustomerRegistry.get_customer(pcid)
				pfid = pc.pain_feature_id if pc != null else ""
			if pfid == "":
				return _no_target(verb, pcid)
			B2BSalesSystem.accept_promise(pcid, pfid,
				int(e.get("deadline_weeks", B2BConstants.PROMISE_DEADLINE_WEEKS)))
			return {"verb": verb, "customer": pcid, "feature": pfid}

		# The words an open promise event waits on move one sprint, or with a `scope` the oldest open word of that account;
		# what that costs the accounts is the option's own trust_delta, listed first (it reads the open words).
		"promise_extend":
			var moved: Array = promises_of(e, ctx)
			if moved.is_empty():
				return _no_target(verb, "")
			if e.has("scope"):
				moved = moved.slice(0, 1)
			for word in moved:
				PromiseRegistry.extend(word.id)
			return {"verb": verb, "n": moved.size()}
		# The player gives the words up (with a `scope`, that account's); the row keeps what the chip showed
		# (break_plan). A paper that expires after the sprint's own sweep broke them has nothing left to break.
		"promise_break":
			var broken: Dictionary = break_plan(e, ctx)
			if broken.accounts.is_empty():
				return {}
			for word in promises_of(e, ctx):
				PromiseRegistry.break_promise(word.id)
			return broken.merged({"verb": verb})

		# --- sprint -------------------------------------------------------------
		# A decision card names no card in its scope (there is no card scope type): SprintSystem
		# knows which card the pending decision is about and answers its id, or "" with none.
		# Effort and hours record the clamped value that lands, the one the chip showed.
		"sprint_card_effort":
			var effort: int = SprintSystem.effort_change(amount(e, ctx))
			return _on_card(verb, SprintSystem.decision_effort(amount(e, ctx)), effort)
		"sprint_card_progress":
			return _on_card(verb, SprintSystem.decision_progress(amount(e, ctx)), amount(e, ctx))
		"sprint_card_carry":
			return _on_card(verb, SprintSystem.decision_carry(), 0)
		# The test of the promise card (or, with `card` DECISION, of the pending decision's card) is cut in half: the test
		# catches less of its bugs (SprintBugs.catch_rate). The promise card is sent (SprintSystem.send).
		"sprint_card_test":
			var promised: bool = String(e.get("card", "")) != DECISION
			var cut_card: Dictionary = SprintSystem.promise_card() if promised else SprintSystem.decision_card()
			if promised:
				SprintSystem.send(cut_card)
			return _on_card(verb, SprintSystem.cut_test(cut_card), 0)
		"sprint_hours":
			var mult: float = float(e.get("mult", 1.0))
			var hours: float = SprintSystem.hours_after(mult)
			var sprint: int = SprintSystem.set_hours_mult(mult)
			if sprint == 0:
				return _no_target(verb, "")
			if bool(e.get("promise", false)):
				SprintSystem.send(SprintSystem.promise_card())
			return {"verb": verb, "sprint": sprint, "mult": mult, "hours": hours, "solo": SprintSystem.payers("").is_empty()}
		# A line's fix card stands first in the sprint; the row keeps the card it bumped (what the chip said).
		"sprint_fix_first":
			var fix_line: String = line_of(e)
			var bumped: Dictionary = SprintSystem.fix_first_bumps(fix_line, int(e.get("bugs", 0)))
			SprintSystem.fix_first(fix_line, int(e.get("bugs", 0)))
			return {"verb": verb, "line": fix_line, "bumps": bumped, "front": bool(e.get("front", false))}
		# The pending decision's card gives work up or ships with a bug; the row keeps the plan the chip showed.
		"sprint_card_trim":
			var trimmed: Dictionary = trim_plan(e)
			return _on_card(verb, SprintSystem.decision_trim(trimmed), 0).merged(trimmed)
		# No effect of its own: the row keeps whether the pending decision's card finishes the sprint once the option's
		# other effects have landed, which the chip said before they did.
		"sprint_card_outlook":
			var outlook_card: String = SprintSystem.decision_card().get("id", "")
			return _on_card(verb, outlook_card, 0).merged({"finishes": SprintSystem.finishes_with(outlook_card, 0)})
		# The pending decision's card stands first in the sprint; the row keeps the card it bumped (what the chip said).
		"sprint_card_first":
			var first_bumped: Dictionary = SprintSystem.decision_first_bumps()
			return _on_card(verb, SprintSystem.decision_first(), 0).merged({"bumps": first_bumped})
		# The person works only on the card for `weeks` (SprintSystem.pin_card); the row keeps the plan the chip showed.
		"assign_to":
			var pin: Dictionary = pin_plan(e, ctx)
			if SprintSystem.pin_card(pin.card, pin.employee, GameState.day + TimeModel.ticks(pin.weeks)) == "":
				return _no_target(verb, pin.card)
			return pin.merged({"verb": verb})
		# The next sprint takes a card: the area's or line's first free feature, or with a `scope` the account's new request
		# (SprintBridges.open_request). The row keeps the card's identity (what the chip said).
		"queue_card":
			var queued: Dictionary = queue_plan(e, ctx)
			var queued_id: String = String(queued.get("id", ""))
			if queued_id == "" and not queued.is_empty():
				queued_id = SprintBridges.open_request(queued.of.customer_id, queued.of.line)
			if queued_id == "":
				return _no_target(verb, "")
			SprintSystem.send_next(queued_id)
			return {"verb": verb, "card": queued_id, "of": queued.of}
		# The pending decision's card is watched: once its test is done and found a bug, `effects` land (EvWatch).
		"after_test":
			var tested: String = SprintSystem.decision_card().get("id", "")
			if tested == "":
				return _no_target(verb, tested)
			EvWatch.add(tested, e.get("effects", []), ctx, card_id)
			return {"verb": verb, "card": tested, "effects": e.get("effects", [])}
		# The line's code is rewritten: `weeks` (else sprint.json `paper.harden_weeks`) with no new bug on it.
		"line_harden":
			var hardened: String = line_of(e)
			var span: int = int(e.get("weeks", SprintCatalog.cfg("paper.harden_weeks")))
			ProductState.harden_line(hardened, span)
			return {"verb": verb, "line": hardened, "weeks": span}
		# `bugs` open bugs land on the line now, at once and whatever the line is shielded from.
		"damage_product":
			var damaged: String = line_of(e)
			var landed: int = int(e.get("bugs", 1))
			ProductState.add_bugs(damaged, landed)
			return {"verb": verb, "line": damaged, "bugs": landed}
		# --- world and surfaces -----------------------------------------------
		"ticker_push":
			# §18: the ticker is atmosphere, never the ONLY channel — anything meaningful here is
			# also in History.
			EvTicker.push(String(e.get("line_key", "")), String(e.get("priority", "world")), ctx)
			return {"verb": verb, "line_key": e.get("line_key", "")}
		"goto_tab":
			var tab_id: String = String(e.get("tab_id", ""))
			var subpage: String = String(e.get("subpage", ""))
			EventBus.goto_tab_requested.emit(tab_id, subpage)
			return {"verb": verb, "tab": tab_id, "subpage": subpage}
		"notify":
			# class: info's surface. Badge state belongs to the owning module, so this nudges it
			# rather than duplicating its counter.
			EventBus.headline_added.emit(String(e.get("source", "")), {"txt": String(e.get("text", ""))})
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
		"open_term_table":
			# A literal vc_id wins; otherwise the bound investor slot.
			var tvc: String = String(e.get("vc_id", ""))
			if tvc == "":
				tvc = entity_of(e, ctx, EvScope.TYPE_INVESTOR)
			if tvc == "":
				return _no_target(verb, tvc)
			EventBus.term_table_requested.emit(tvc, PitchConstants.STAGE_SERIES_A)
			return {"verb": verb, "vc": tvc}
		"decline_offer":
			var dvc: String = entity_of(e, ctx, EvScope.TYPE_INVESTOR)
			if dvc == "":
				return _no_target(verb, dvc)
			if not VCPitchSystem.decline_expired_sheet(dvc):
				return {"verb": verb, "refused": "no sheet awaiting a decision"}
			return {"verb": verb, "vc": dvc}
		"investor_strain":
			var svc: String = entity_of(e, ctx, EvScope.TYPE_INVESTOR)
			if svc == "":
				return _no_target(verb, svc)
			var strain: Dictionary = VCPitchSystem.add_strain(svc, amount(e, ctx), int(e.get("weeks", 0)))
			return {"verb": verb, "vc": svc, "amount": strain.amount, "weeks": strain.weeks}
		"open_seed_table":
			# The seed offer knows whose it is, and there is only ever one.
			if GameState.seed_sheet == null:
				return {"verb": verb, "refused": "no seed offer on the table"}
			EventBus.term_table_requested.emit(String(GameState.seed_sheet.vc_id), PitchConstants.STAGE_SEED)
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
			# Frank's latched line on the notice stack and the Events page: a CSV key that the
			# surfaces translate where they show it, so the line follows the live language.
			var line_key: String = String(e["line_key"])
			EventBus.mentor_advisory_changed.emit(line_key, {})
			return {"verb": verb, "line_key": line_key}

		# --- B2B outcomes, each through its owning seam ---------------------
		"b2b_retain_delay":
			B2BSalesSystem.hold(entity_of(e, ctx, EvScope.TYPE_CUSTOMER))
			return {"verb": verb}
		"b2b_retain_discount":
			var dc: String = entity_of(e, ctx, EvScope.TYPE_CUSTOMER)
			var dcust: Customer = CustomerRegistry.get_customer(dc)
			if dcust == null:
				return _no_target(verb, dc)
			# The amount is what landed: the seam refuses a discount past its cap.
			var cut_from: int = dcust.mrr
			B2BSalesSystem.apply_discount(dc,
				-int(round(float(dcust.mrr) * B2BConstants.RETAIN_DISCOUNT_PCT)))
			return {"verb": verb, "customer": dc, "amount": dcust.mrr - cut_from}
		# A month's discount on the slot's account, once: money out, the account's MRR stays.
		"b2b_month_discount":
			var gift: Dictionary = month_discount_plan(e, ctx)
			if CustomerRegistry.get_customer(gift.id) == null:
				return _no_target(verb, gift.id)
			FinanceSystem.apply_one_time_cost(-int(gift.amount), "retention")
			return gift.merged({"verb": verb})
		"b2b_retain_ignore":
			B2BSalesSystem.ignore_risk(entity_of(e, ctx, EvScope.TYPE_CUSTOMER))
			return {"verb": verb}
		"b2b_expand":
			var ec: String = entity_of(e, ctx, EvScope.TYPE_CUSTOMER)
			var ecust: Customer = CustomerRegistry.get_customer(ec)
			if ecust == null:
				return _no_target(verb, ec)
			# What landed, at the account's own seat price (B2BSalesSystem.expand).
			var seats_from: int = ecust.seats
			var mrr_from: int = ecust.mrr
			B2BSalesSystem.expand(ec, B2BConstants.expansion_seats(ecust.company_size),
				B2BConstants.EXPANSION_PER_SEAT_MRR)
			return {"verb": verb, "customer": ec, "seats": ecust.seats - seats_from,
				"amount": ecust.mrr - mrr_from}
		"b2b_expand_decline":
			B2BSalesSystem.decline_expansion(entity_of(e, ctx, EvScope.TYPE_CUSTOMER))
			return {"verb": verb}

		# --- the sales desk, each through its owning seam ----------------------
		# Terms on the lead that become the account's if it signs (B2BSalesSystem.apply_offer); the card never signs it.
		"prospect_offer":
			var oid: String = entity_of(e, ctx, EvScope.TYPE_PROSPECT)
			var offered: Prospect = ProspectRegistry.get_prospect(oid)
			if offered == null:
				return _no_target(verb, oid)
			var terms: Dictionary = {"discount_pct": e.get("discount_pct", 0.0), "discount_weeks": e.get("discount_weeks", 0),
				"promise_step": SprintCatalog.in_product(String(e.get("promise_step", ""))), "promise_weeks": e.get("promise_weeks", 0)}
			ProspectRegistry.set_offer(oid, terms)
			return terms.merged({"verb": verb, "prospect": oid, "company": offered.company_name})
		# The lead walks the way a lead the desk lost walks (SalesFinalizer.lose): out of the pipeline, locked out for a while.
		"drop_prospect":
			var did: String = entity_of(e, ctx, EvScope.TYPE_PROSPECT)
			var dropped: Prospect = ProspectRegistry.get_prospect(did)
			if dropped == null:
				return _no_target(verb, did)
			SalesFinalizer.lose(did, dropped.company_name, SalesConstants.LOSS_EVENT, "", SalesConstants.RETURN_LOCK_WEEKS)
			return {"verb": verb, "prospect": did, "company": dropped.company_name}
		# For `weeks` the sales meetings lean on `area` (SalesMeetingSystem.set_pitch_focus).
		"pitch_focus":
			var focus_weeks: int = int(e.get("weeks", 1))
			SalesMeetingSystem.set_pitch_focus(String(e.get("area", "")), GameState.day + TimeModel.ticks(focus_weeks))
			return {"verb": verb, "area": e.get("area", ""), "weeks": focus_weeks}

		# --- the servers, each through InfraSystem ------------------------------
		# The unit price scales by `mult` for good, on every tier or only on `tiers`; the row keeps the bill before and
		# after, which the chip said.
		"server_price":
			var quote: Dictionary = server_price_plan(e)
			InfraSystem.scale_price(float(e.get("mult", 1.0)), e.get("tiers", []))
			return quote.merged({"verb": verb, "mult": e.get("mult", 1.0), "tiers": e.get("tiers", [])})
		# A contract: the tier stays and the capacity does not fall under today's for `weeks`; the row keeps that capacity.
		"server_lock":
			var contract_weeks: int = int(e.get("weeks", 1))
			InfraSystem.lock(contract_weeks)
			return {"verb": verb, "weeks": contract_weeks, "capacity": InfraSystem.purchased_capacity()}

		# --- terminal -----------------------------------------------------------
		"trigger_ending":
			# _permitted already refused an untelegraphed ending.
			EndingsSystem.trigger_ending(String(e.get("ending_id", "")),
				String(e.get("requires_telegraph", "")))
			return {"verb": verb, "ending": e.get("ending_id", "")}

	push_error("[EvEffects] no application for verb '%s'" % verb)
	return {"verb": verb, "refused": "not implemented"}


# --- Helpers ---------------------------------------------------------------

## The signed figure an effect names: a seam's value times `amount_mult` (a seam yields a magnitude, the
## multiplier carries the sign), else its literal `amount`, `delta` or `value`. An entity seam is read for
## the entity `amount_slot` binds in `ctx`. EvChips and the bot read the figure here too, so what a chip
## shows is what lands.
static func amount(e: Dictionary, ctx: Dictionary = {}) -> int:
	if e.has("amount_seam"):
		var seam: String = String(e["amount_seam"])
		var read: Variant = EvSeams.read_for(seam, EvScope.id_in(ctx, String(e["amount_slot"]))) \
			if e.has("amount_slot") else EvSeams.read(seam)
		return roundi(float(read) * float(e.get("amount_mult", 1.0)))
	for key in ["amount", "delta", "value"]:
		if e.has(key):
			return int(e[key])
	return 0


## Does the sign the author wrote make this effect a gain? Needs no run: a seam yields a magnitude, so
## its `amount_mult` is the signed figure; else the literal `amount` or `delta`, and an effect naming
## neither is a cost; a `server_price` is a gain when its multiplier cuts the bill. Lint and the expiry's check both ask here.
static func is_authored_gain(e: Dictionary) -> bool:
	if String(e.get("verb", "")) == "server_price":
		return float(e.get("mult", 1.0)) < 1.0
	if e.has("amount_seam"):
		return float(e.get("amount_mult", 1.0)) > 0.0
	return float(e.get("amount", e.get("delta", -1))) > 0.0


## The weeks a `schedule_event` may wait: `delay_weeks` is a number or a window [lo, hi].
static func delay_bounds(e: Dictionary) -> Array:
	var delay: Variant = e.get("delay_weeks", 1)
	return [int(delay[0]), int(delay[1])] if delay is Array else [int(delay), int(delay)]


## What a `summer_leave` does and what the player reads for it: HRMoraleSystem's plan for the pair the effect names (`scope`
## and the slot `other`), {} when either is gone.
static func summer_leave_plan(e: Dictionary, ctx: Dictionary) -> Dictionary:
	var a: Character = CharacterRegistry.get_character(entity_of(e, ctx, EvScope.TYPE_EMPLOYEE))
	var b: Character = CharacterRegistry.get_character(EvScope.id_in(ctx, String(e.get("other", ""))))
	return {} if a == null or b == null else HRMoraleSystem.plan_summer_leave(a, b, bool(e.get("apart", false)))


## What a `trust_delta` writes and what the player reads for it, worked out the way the arm applies it:
## per account, largest first, the satisfaction now and the one a tick after its ledger takes `amount`.
static func trust_plan(e: Dictionary, ctx: Dictionary) -> Dictionary:
	var delta: int = amount(e, ctx)
	var rows: Array = []
	for c in trust_accounts(e, ctx):
		rows.append({"id": c.id, "name": c.display_name(), "from": c.satisfaction, "to":
			B2BSalesSystem.satisfaction_next_tick(c, B2BConstants.clamp_trust(c.trust_offset + delta))})
	return {"amount": delta, "per_sprint": int(e.get("per_sprint", 0)), "accounts": rows,
		"until": _until(e) if e.has("until") else {},
		"group": {"others": "other", "onboarding": "new"}.get(String(e.get("accounts", "slot")), "all")}


## What a `sprint_card_trim` gives up and what the player reads for it (SprintSystem.trim_plan): `share` takes the
## sprint.json `paper.trim_share` of the card off it, `amount` is work the card never takes, `follow` makes both a card of
## the next sprint, `bugs` open bugs land on `line` (else the card's) when the card ships.
static func trim_plan(e: Dictionary) -> Dictionary:
	return SprintSystem.trim_plan(bool(e.get("share", false)), amount(e), bool(e.get("follow", false)),
		int(e.get("bugs", 0)), _named(String(e.get("line", DECISION)), "line"))


## What a `b2b_month_discount` costs: sprint.json `paper.renewal_discount` of the slot's account's MRR, once.
static func month_discount_plan(e: Dictionary, ctx: Dictionary) -> Dictionary:
	var id: String = entity_of(e, ctx, EvScope.TYPE_CUSTOMER)
	var c: Customer = CustomerRegistry.get_customer(id)
	var pct: float = float(SprintCatalog.cfg("paper.renewal_discount"))
	return {"id": id, "name": c.display_name() if c != null else "", "pct": roundi(pct * 100.0),
		"amount": -roundi(float(c.mrr) * pct) if c != null else 0}


## What a `server_price` does to the month's bill and what the player reads for it: the bill now, and the bill once `mult`
## is on the unit price of the company's tier (every tier's, or the `tiers` named).
static func server_price_plan(e: Dictionary) -> Dictionary:
	var tiers: Array = e.get("tiers", [])
	var hit: bool = tiers.is_empty() or tiers.has(InfraSystem.provider())
	return {"before": InfraSystem.monthly_bill(),
		"after": InfraSystem.monthly_bill("", float(e.get("mult", 1.0)) if hit else 1.0)}


## What an `assign_to` pins and what the player reads for it: the slot's person, the weeks (`weeks`, else the `weeks_seam`), and the
## card, the pending decision's or with `card` "promise" the one the customer slot's oldest open word waits on in the running
## sprint ("" with none), as {employee, weeks, card, of}.
static func pin_plan(e: Dictionary, ctx: Dictionary) -> Dictionary:
	var card_id: String = ""
	if String(e.get("card", "")) == DECISION:
		card_id = SprintSystem.decision_card().get("id", "")
	else:
		var waiting: Array = SprintBridges.promise_cards(entity_of({}, ctx, EvScope.TYPE_CUSTOMER))
		card_id = "" if waiting.is_empty() else waiting[0]
	return {"employee": entity_of(e, ctx, EvScope.TYPE_EMPLOYEE), "card": card_id,
		"weeks": int(EvSeams.read(String(e["weeks_seam"]))) if e.has("weeks_seam") else int(e.get("weeks", 1)),
		"of": SprintSystem.card_ref(SprintCatalog.card_by_id(card_id)) if card_id != "" else {}}


## What a `queue_card` puts in the next sprint and what the player reads for it: with a `scope` the customer slot's new request on
## `line` (SprintBridges.request_step), else the first feature card of the `area`'s (the `line`'s area) candidates that no column
## holds and whose gate is open; {} with none. {id: "" for a request not opened yet, of}.
static func queue_plan(e: Dictionary, ctx: Dictionary) -> Dictionary:
	var line: String = line_of(e)
	if e.has("scope"):
		var account: String = entity_of(e, ctx, EvScope.TYPE_CUSTOMER)
		var step: Dictionary = SprintBridges.request_step(account, line)
		return {} if step.is_empty() else {"id": "", "of": {"kind": "request", "line": step.line_id, "step": step.id,
			"customer_id": account}}
	var area: String = String(e.get("area", SprintCatalog.area_of_line(line)))
	for c in ([] if area == "" else SprintCatalog.candidates(area)):
		if c.id.begins_with("feat:") and c.state == "candidate" and SprintCatalog.gate_reason(c.step) == "" \
				and (line == "" or c.line == line):
			return {"id": c.id, "of": SprintSystem.card_ref(c)}
	return {}


## The B2B accounts a `trust_delta` lands on, largest first: the slot's, or the users of the pending
## sprint decision's line.
static func trust_accounts(e: Dictionary, ctx: Dictionary) -> Array:
	var accounts: Array = []
	match String(e.get("accounts", "slot")):
		"slot":
			var c: Customer = CustomerRegistry.get_customer(entity_of(e, ctx, EvScope.TYPE_CUSTOMER))
			if c != null and c.market_type == "b2b":
				accounts.append(c)
		"decision_line":
			accounts = SprintCatalog.line_accounts(_named(DECISION, "line"))
		"promise":
			return promise_accounts(SprintSystem.event_promises())
		"second":
			var second: Customer = SprintCatalog.second_account(SprintSystem.decision_card())
			if second != null:
				accounts.append(second)
		# The card's own accounts: the slots it names, every B2B account, every one but the card's (those of `line` when it
		# names one), or the ones still in their onboarding window.
		"slots":
			for slot in e.get("slots", []):
				var named: Customer = CustomerRegistry.get_customer(EvScope.id_in(ctx, String(slot)))
				if named != null and named.market_type == "b2b":
					accounts.append(named)
		"all":
			accounts = CustomerRegistry.get_by_market("b2b")
		"others":
			var bound: Array = ctx.values().filter(func(b: Dictionary) -> bool: return b.type == EvScope.TYPE_CUSTOMER).map(
				func(b: Dictionary) -> String: return b.id)
			accounts = CustomerRegistry.get_by_market("b2b").filter(func(c: Customer) -> bool: return not bound.has(c.id))
			if e.has("line"):
				var users: Array = SprintCatalog.line_accounts(line_of(e))
				accounts = accounts.filter(func(c: Customer) -> bool: return users.has(c))
		"onboarding":
			accounts = CustomerRegistry.get_by_market("b2b").filter(
				func(c: Customer) -> bool: return GameState.day < c.onboarding_until)
	accounts.sort_custom(SprintCatalog.larger_account)
	return accounts


## What a `promise_break` lands on and what the player reads for it: the accounts whose words are still open, largest
## first, each with its satisfaction now and a tick after the break, and the brand the broken words cost.
static func break_plan(e: Dictionary = {}, ctx: Dictionary = {}) -> Dictionary:
	var words: Array = promises_of(e, ctx)
	var rows: Array = []
	for c in promise_accounts(words):
		rows.append({"id": c.id, "name": c.display_name(), "from": c.satisfaction,
			"to": B2BSalesSystem.satisfaction_after_break(c)})
	return {"accounts": rows, "brand": words.size() * B2BConstants.PROMISE_BROKEN_BRAND}


## The open words a `promise_extend` or `promise_break` lands on: those of the slot's account when the effect names a `scope`
## (oldest first), else the open promise event's.
static func promises_of(e: Dictionary, ctx: Dictionary) -> Array:
	if e.has("scope"):
		return PromiseRegistry.get_open_for(entity_of(e, ctx, EvScope.TYPE_CUSTOMER))
	return SprintSystem.event_promises()


## The accounts these words were given to, once each, largest first.
static func promise_accounts(words: Array) -> Array:
	var accounts: Array = []
	for word in words:
		var account: Customer = CustomerRegistry.get_customer(word.customer_id)
		if not accounts.has(account):
			accounts.append(account)
	accounts.sort_custom(SprintCatalog.larger_account)
	return accounts


## The people a `morale_crew` lands on, by id: employees only, the founder's morale is not managed.
## `incident_crew` pays by SprintSystem.payers on `line`; `card_crew` is the pending decision card's
## assignees; `promise_crew` is the promise event's card's; `sprint_crew` is the running sprint's team
## (everyone the sprint's hours reach); `speaker` is the card's employee slot.
static func crew_of(e: Dictionary, ctx: Dictionary) -> Array:
	var ids: Array = []
	match String(e.get("crew", "")):
		"incident_crew":
			ids = SprintSystem.payers(line_of(e))
		"card_crew":
			ids = SprintSystem.decision_card().get("assignees", [])
		"promise_crew":
			ids = SprintSystem.promise_crew()
		"sprint_crew":
			ids = SprintSystem.payers("")
		"speaker":
			ids = [entity_of(e, ctx, EvScope.TYPE_EMPLOYEE)]
	return ids.filter(func(id: String) -> bool:
		var person: Character = CharacterRegistry.get_character(id)
		return person != null and person.category == "employee")


## First names of these people, in order: what a chip reads and a history row keeps.
static func crew_names(ids: Array) -> Array:
	return ids.map(func(id: String) -> String:
		return CharacterRegistry.get_character(id).character_name.split(" ", false)[0])


## How a standing `per_sprint` cost ends (B2BSalesSystem.add_trust_drain).
static func _until(e: Dictionary) -> Dictionary:
	var until: Dictionary = e["until"]
	if until.has("line_cleared"):
		return {"line_cleared": _named(String(until["line_cleared"]), "line")}
	return {"step_live": _named(String(until["step_live"]), "step")}


## The line an effect names (`line`): as written, the pending sprint decision's, or the open emergency's.
static func line_of(e: Dictionary) -> String:
	return _named(String(e.get("line", "")), "line")


## `token` as written (a shared line or step by its base id reads as the product's own, SprintCatalog.in_product), the
## pending sprint decision card's `field` when it is DECISION, or the open emergency's line when it is INCIDENT.
static func _named(token: String, field: String) -> String:
	match token:
		DECISION:
			return String(SprintSystem.decision_card().get(field, ""))
		INCIDENT:
			return IncidentSystem.hit_line()
	return SprintCatalog.in_product(token)


## The entity this effect targets: an explicit id, else the named slot, else the first slot of
## the right type. Resolved fresh per effect — §8.2 lists are non-atomic, so an earlier effect
## can remove the entity a later one aims at.
static func entity_of(e: Dictionary, ctx: Dictionary, want_type: String) -> String:
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


static func _on_card(verb: String, card_id: String, amount: int) -> Dictionary:
	if card_id == "":
		return _no_target(verb, card_id)
	return {"verb": verb, "card": card_id, "amount": amount,
		"of": SprintSystem.card_ref(SprintCatalog.card_by_id(card_id))}
