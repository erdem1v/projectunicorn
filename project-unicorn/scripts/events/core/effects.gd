class_name EvEffects
extends RefCounted

# THE EFFECT EXECUTOR (GDD §8). The one place an effect verb becomes a state change.
#
# ─────────────────────────────────────────────────────────────────────────────────────────
# I2 IS STRUCTURAL HERE, NOT A LINT RULE
# ─────────────────────────────────────────────────────────────────────────────────────────
#
# §0.3 lists I2 — "an economic delta arises only from a played decision" — as enforced by lint
# (§17.3). Lint alone is not enough, for three reasons that are each independently fatal:
#
#   1. `open_negotiation` (§9.4) returns an `effects_to_apply` list that DOES NOT EXIST AT
#      BUILD TIME. No lint pass can ever see it. A negotiation could return `add_cash` from a
#      context that forbids it and nothing would notice.
#   2. The `on_expire` exception is a SIGN rule, not a verb rule: expiry may apply a negative
#      delta and never a positive one. Lint can read a literal `-500`; it cannot read an amount
#      derived from a seam. Only dispatch-time sign checking closes that.
#   3. Lint is a thing someone runs. This is a thing that cannot be gone around.
#
# So the vocabulary is SPLIT BY ORIGIN and each origin gets its own table:
#
#   run_played()        NEUTRAL + ECONOMIC + TERMINAL     a decision the player made
#   run_expire()        NEUTRAL + ECONOMIC, negative only  the cost of not answering
#   run_ambient()       NEUTRAL                            arc auto-steps, signal handlers,
#                                                          on_invalidate — no economy at all
#   run_check_branch()  NEUTRAL + ECONOMIC, no TERMINAL    a dice outcome — and this is also
#                                                          how I6 stops being lint-only
#
# `add_cash` is not a KEY in the ambient table. An ambient caller cannot reach it — not by
# authoring new content, not by accident, not by a future refactor that forgets the rule.
# That is the difference between a rule and a wall.
#
# Reinforced once more at the schema level: `on_expire` and `on_invalidate` read their list
# from a differently-named field (`penalties`, not `effects`), so writing a positive delta in a
# non-option place means putting it in a field the loader does not read.
#
# ─────────────────────────────────────────────────────────────────────────────────────────
# EVERY WRITE GOES THROUGH THE OWNING SYSTEM'S SEAM
# ─────────────────────────────────────────────────────────────────────────────────────────
#
# CLAUDE.md's WRITE-THROUGH LAW: no event may mutate another domain's state directly. The old
# dispatcher was 42 arms and mostly obeyed this, with one live violation
# (`decline_vc_meeting` cleared `GameState.pending_meeting` with a raw field write). There are
# no raw writes here. Where a seam does not exist, the verb does not exist either, and it is
# filed — that is §21's DELTA discipline, and it is why the vocabulary is short rather than
# convenient.
#
# ─────────────────────────────────────────────────────────────────────────────────────────
# CASCADES DO NOT HAPPEN IN THE SAME TICK (§8.2)
# ─────────────────────────────────────────────────────────────────────────────────────────
#
# An effect that makes another card's condition true does not fire it now; the next tick sees
# it. That is what closes the infinite loop, and it is also what makes arc invalidation safe to
# order before the schedule — invalidation always reads state that settled yesterday.

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
	# The seed rung. NEITHER MOVES MONEY, which is why neither is economic: the seed
	# accept is not a card effect at all — the money moves at the table's İMZALA, a played
	# moment, exactly as a Series A signature does. "decline_buyout" closes the VC road and
	# writes one memory flag; the cash it declines is cash that never arrives.
	"open_seed_table", "decline_buyout",
	# The two the migration required — see their arms for why each door is this narrow.
	"set_game_flag", "mentor_advisory",
	# B2B outcomes that move no money: stalling, refusing, declining. Their two siblings that
	# DO move money (b2b_retain_discount cuts MRR, b2b_expand raises it) live in the economic
	# table instead — a verb in both lists would be a vocabulary that lies about itself, even
	# though the refusal happens to come out right either way.
	"b2b_retain_delay", "b2b_retain_ignore", "b2b_expand_decline",
]

## The only GameState flags content may write, and each is here because a system genuinely
## reads it. Adding a row is a design decision, not a convenience.
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


enum Origin { PLAYED, EXPIRE, AMBIENT, CHECK_BRANCH }


# --- Entry points ----------------------------------------------------------

## A decision the player made. The only origin with the full vocabulary.
## What a consumer churn event costs when the "customer" is the whole userbase. The old
## executor had this number inline at its one call site; it is named here because it is a
## calibration value and an unnamed 0.15 in an executor is invisible to the tuning pass.
const B2C_CHURN_PCT := 0.15

## I3 refusals this run: a card tried to end the run on a telegraph that had never fired and
## the executor stopped it. The harness reports this — §19.3 asks for "no untelegraphed loss"
## and the only honest way to say it is a COUNT, not a field nobody writes.
static var _untelegraphed_refusals: int = 0


static func untelegraphed_refusals() -> int:
	return _untelegraphed_refusals


static func reset_counters() -> void:
	_untelegraphed_refusals = 0


static func run_played(effects: Array, ctx: Dictionary) -> Array:
	return _run(effects, ctx, Origin.PLAYED)


## The cost of not answering (§8.3's one exception). Economic verbs are allowed but only in the
## negative direction, checked per effect at dispatch — a seam-derived amount that comes out
## positive is refused here, where a linter reading a literal could never have seen it.
static func run_expire(effects: Array, ctx: Dictionary) -> Array:
	return _run(effects, ctx, Origin.EXPIRE)


## Arc auto-steps, signal handlers, on_invalidate. Bookkeeping only.
static func run_ambient(effects: Array, ctx: Dictionary) -> Array:
	return _run(effects, ctx, Origin.AMBIENT)


## A dice outcome. Full economy, no terminal — I6 ("zar öldürmez") enforced by the table rather
## than by §17.5's lint rule, which becomes a second line of defence instead of the only one.
static func run_check_branch(effects: Array, ctx: Dictionary) -> Array:
	return _run(effects, ctx, Origin.CHECK_BRANCH)


# --- The dispatcher --------------------------------------------------------

## Returns the delta log: one entry per applied effect, for History's `deltas` field, the debug
## panel and the ending screen. A REFUSED effect is logged too — a refusal that leaves no trace
## is how a rule becomes invisible.
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
			# §8.2: refusals are loud in the log and silent to the player. The run continues —
			# a refused effect is a content bug, not a reason to strand the player mid-card.
			push_error("[EvEffects] refused '%s' from %s: %s" % [verb, _origin_name(origin), refusal])
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

	# I3's runtime half (§8.4). A loss the player was never warned about does not happen. The
	# structural half lives on EndingsSystem.trigger_ending's own signature, which has no
	# default for its telegraph argument — so all ten of its call sites must name one, not
	# just the two the engine owns.
	if is_terminal or bool(effect.get("is_loss_risk", false)):
		var telegraph: String = String(effect.get("requires_telegraph", ""))
		if telegraph == "":
			return "I3: no requires_telegraph declared"
		if not EvHistory.telegraph_fired(telegraph):
			return "I3: telegraph '%s' never fired" % telegraph
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


static func _origin_name(origin: Origin) -> String:
	match origin:
		Origin.PLAYED: return "played"
		Origin.EXPIRE: return "expire"
		Origin.AMBIENT: return "ambient"
		Origin.CHECK_BRANCH: return "check_branch"
	return "?"


# --- Application -----------------------------------------------------------

static func _apply(verb: String, e: Dictionary, ctx: Dictionary) -> Dictionary:
	match verb:
		# --- economy -------------------------------------------------------
		"add_cash":
			var amount: int = _amount(e)
			GameState.set_cash(GameState.cash + amount)
			return {"verb": verb, "amount": amount}
		"add_mrr":
			# There is no aggregate-MRR write seam: SalesSystem.reflect_mrr() derives MRR from
			# the customer book every day, so a raw write is reverted by the next tick. The old
			# engine shipped an `mrr` CHIP with no dispatcher arm behind it for exactly this
			# reason — a card promised the player a number the engine could not deliver. The
			# verb is refused rather than faked.
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
			# B2C IS ONE AGGREGATE RECORD, so churn erodes the AUDIENCE and lets derived MRR
			# follow; deleting the userbase would delete the whole consumer business over one
			# complaint. B2B removes the account. (Economy Model v2; the old executor carried
			# this branch and the port had flattened it to `remove`.) The audience is read as a
			# float because it keeps a sub-unit accumulator — int()-ing first rounds the
			# erosion base down before taking 15% of it.
			if victim.market_type == "b2c":
				var aud: float = float(GameState.get_flag("b2c_audience", 0.0))
				SalesSystem.add_b2c_audience(-int(round(aud * B2C_CHURN_PCT)))
				return {"verb": verb, "customer": chid, "audience_pct": -B2C_CHURN_PCT}
			CustomerRegistry.remove(chid)
			GameState.run_customers_lost += 1
			SalesSystem.reflect_mrr()
			return {"verb": verb, "customer": chid}
		"audience_delta":
			var n: int = _amount(e)
			if e.has("pct"):
				n = int(round(float(GameState.get_flag("b2c_audience", 0.0)) * float(e["pct"])))
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
			# Through HRMoraleSystem, not set_morale: apply_delta is where the trait multiplier
			# and the founder's Liderlik climate coefficient live. A raw write would leave
			# leadership's gain side dead exactly where the design puts it to work.
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
			B2BSalesSystem.accept_promise(pcid, String(e.get("feature_id", "")),
				int(e.get("deadline_days", 14)))
			return {"verb": verb, "customer": pcid, "feature": e.get("feature_id", "")}

		# --- product ----------------------------------------------------------
		"dimension_delta":
			ProductSystem.apply_dimension_delta(String(e.get("axis", "innovation")), _amount(e))
			return {"verb": verb, "axis": e.get("axis", "innovation"), "amount": _amount(e)}
		"bug_delta":
			ProductSystem.apply_bug_delta(_amount(e))
			return {"verb": verb, "amount": _amount(e)}
		"delay_days":
			# The old chip printed "{v} gün" unconditionally while the seam no-ops with no
			# active build, so post-ship it showed a cost that never happened. The refusal is
			# explicit now and it is logged, so a card claiming time it did not take is visible.
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
			# §18: the ticker is atmosphere and confirmation, never the ONLY channel. Anything
			# meaningful pushed here is also in History, and if it belongs to a promise arc it
			# also carries a card. The old engine had no way for a card to leave a trace here
			# at all — 08_event_ve_anlati.md:208 lists it as an absent seam.
			EvTicker.push(String(e.get("line_key", "")), String(e.get("priority", "world")), ctx)
			return {"verb": verb, "line_key": e.get("line_key", "")}
		"goto_tab":
			# Seven landed card options say "go to Sales", "go to HR", "go to Funding" and
			# their buttons went nowhere, because no navigation verb existed
			# (FRANK_UNWIRED.md §5 calls it the highest-value dev item the Frank pass produced).
			# Two of them fire in a normal run.
			var tab_id: String = String(e.get("tab_id", ""))
			EventBus.tab_changed.emit(tab_id)
			var subpage: String = String(e.get("subpage", ""))
			if subpage != "":
				EventBus.finance_subpage_requested.emit(subpage)
			return {"verb": verb, "tab": tab_id, "subpage": subpage}
		"notify":
			# class: info's surface. The engine does not own badge state — the owning module
			# already does (RnDSystem.attention_count, HRSystem.attention_count) — so this
			# nudges the module rather than duplicating its counter.
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
			# The investor comes from the BOUND SLOT, the same way every other entity verb
			# resolves its subject. Reading a literal `vc_id` off the effect meant the card
			# had to name an investor at authoring time, which no card can know.
			var mvc: String = _entity(e, ctx, EvScope.TYPE_INVESTOR)
			if mvc == "":
				return _no_target(verb, mvc)
			VCPitchSystem.begin_meeting(mvc)
			return {"verb": verb, "vc": mvc}
		"open_term_table":
			EventBus.term_table_requested.emit(String(e.get("vc_id", "")))
			return {"verb": verb, "vc": e.get("vc_id", "")}
		"open_seed_table":
			# No vc_id on the effect: the seed offer knows whose it is, and there is only ever
			# one. A card naming an investor would be a card that has to know the roster.
			if GameState.seed_sheet == null:
				return {"verb": verb, "refused": "no seed offer on the table"}
			EventBus.term_table_requested.emit(String(GameState.seed_sheet.vc_id))
			return {"verb": verb, "vc": GameState.seed_sheet.vc_id}
		"decline_buyout":
			EndingsSystem.on_buyout_declined()
			return {"verb": verb}
		"open_negotiation":
			# §9.4: the engine opens the scene and does not know its insides. The return
			# contract is stamped TEMPORARY in the GDD and owned by §23 A4.
			#
			# The effects it hands back are run through run_played with the ORIGIN OF THE
			# OPTION THAT OPENED IT — they are that decision's consequences arriving late, not
			# a new unattributed source of money. Without that, §9.4's "the engine does not
			# validate the structure" would be a hole straight through I2 that no lint pass
			# could ever see, because the list does not exist until runtime.
			return {"verb": verb, "negotiation": e.get("negotiation_type", ""), "deferred": true}

		# --- the two verbs the migration required -------------------------
		"set_game_flag":
			# A NARROW, WHITELISTED door into GameState, and the whitelist is the design.
			#
			# The old engine's set_flag could write ANY of the ~83 registered GameState keys —
			# a card reaching past every seam into another domain's state, which the
			# WRITE-THROUGH LAW forbids in one sentence. It was one dispatcher arm wide, and
			# two authored cards walked through it. Those two are legitimate:
			# tech_debt_birikti and critical_bug_unfixed are genuinely read by ProductSystem,
			# and leaving debt behind is exactly what those cards are about. So the door stays
			# and admits precisely them. Anything else needs a named verb through its owning
			# system's seam, which is a decision somebody makes rather than a string they type.
			var flag_name: String = String(e.get("name", ""))
			if not GAME_FLAG_WHITELIST.has(flag_name):
				push_error("[EvEffects] set_game_flag refused '%s'; only %s may be written "
					% [flag_name, str(GAME_FLAG_WHITELIST)] + "from content")
				return {"verb": verb, "refused": "not whitelisted"}
			GameState.set_flag(flag_name, e.get("value", true))
			return {"verb": verb, "name": flag_name, "value": e.get("value", true)}

		"mentor_advisory":
			# The latched line on the ODA phone glass. Its old form carried RAW TURKISH PROSE
			# as a modifier payload with no _en sibling, so an English player read Turkish
			# there — three live JSON cards did this. It carries a KEY now, resolved at emit
			# against the live locale like every other player-facing string.
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
			# I3, AT THE EXECUTOR. `EndingsSystem._assert_telegraph` is loud and never blocking,
			# and that is right for the SYSTEM path: refusing there would strand a run whose
			# bankruptcy is already arithmetically certain. A CARD is a different case. A card
			# that ends the run off a telegraph that never fired is content that must not ship,
			# the linter says so at build time, and refusing here means it cannot ship by
			# accident either. The two enforcement points differ because the stakes differ:
			# nothing a system computes is at risk here, only what an author wrote.
			var telegraph: String = String(e.get("requires_telegraph", ""))
			if not EvHistory.telegraph_fired(telegraph):
				push_error("[EvEffects] '%s' would end the run on telegraph '%s', which has "
					% [String(e.get("ending_id", "")), telegraph]
					+ "never fired — refused (I3)")
				_untelegraphed_refusals += 1
				return {"verb": verb, "refused": "untelegraphed"}
			EndingsSystem.trigger_ending(String(e.get("ending_id", "")), telegraph)
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
## the right type. Resolved FRESH per effect, never once per list — §8.2 makes effect lists
## non-atomic, so effect one can remove the entity effect three is aiming at.
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


## §8.2: "hedef yoksa no-op" — but never a SILENT one. A verb that found nothing to act on is
## either a scope bug or an entity that died mid-list, and both are worth seeing.
static func _no_target(verb: String, entity_id: String) -> Dictionary:
	push_error("[EvEffects] '%s' found no target (id '%s')" % [verb, entity_id])
	return {"verb": verb, "refused": "no target"}
