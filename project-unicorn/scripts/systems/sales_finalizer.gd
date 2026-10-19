class_name SalesFinalizer
extends RefCounted

# THE AGREED DEAL AND ITS SIGNATURE, AND THE TWO WAYS A TABLE ENDS WITHOUT ONE (§5.3, §5.4, §6).
#
# WHY THIS IS ITS OWN FILE. `NegotiationSystem` implements the engine's §9.4 contract and must
# stay TYPE-AGNOSTIC: §5.3 reserves the same scene for Series A, where seats become equity and
# price becomes valuation. A negotiation that knew about `Customer` could not be reused, so the
# outcome APPLIER is separate and this one speaks b2b.
#
# A TABLE THAT AGREES DOES NOT SIGN. Its terms (seats, price, the word given in Act 1) wait on the
# lead as a deal whose plan the stars set; SalesRepSystem's sweep signs it when the plan has run.
#
# EVERY OTHER WRITE GOES THROUGH THE OWNING SEAM (WRITE-THROUGH LAW): the customer through
# `SalesSystem.add_b2b_customer` (the sole B2B signing path), the word given in Act 1 through
# `PromiseRegistry.create`, the return lock through `SalesFaucetSystem`, the account memory
# through `SalesLedger`.


## Apply a finished negotiation. Safe to call with an empty or half-built result — a table
## that produced nothing writes nothing.
static func apply(result: Dictionary) -> void:
	var ctx: Dictionary = result.get("context", {}) as Dictionary
	var lead_id: String = String(ctx.get("lead_id", ""))
	var account: String = String(ctx.get("account", ""))
	match String(result.get("outcome_id", "")):
		NegotiationSystem.OUTCOME_SIGNED:
			_open_deal(result, ctx, lead_id)
		NegotiationSystem.OUTCOME_WALKED:
			# TWO WAYS OFF THE SAME TABLE, and they are not the same event. A player who
			# stands up walks NEUTRALLY: a four-week lock and no trace (§5.3). A table that ran
			# out of patience is a LOSS on price (§12), and it is remembered — which is what
			# makes the re-pitch blocker have something to read next time.
			var reason: String = String((result.get("values", {}) as Dictionary).get("reason", ""))
			if reason != "":
				lose(lead_id, account, reason, "", SalesConstants.WALK_LOCK_WEEKS)
			else:
				_leave(lead_id, account, SalesConstants.WALK_LOCK_WEEKS)
		NegotiationSystem.OUTCOME_INSULTED:
			# §5.3 — "masa devrilir, hesap hafızasına yazılır". This one IS remembered.
			SalesLedger.record_insult(account)
			_leave(lead_id, account, SalesConstants.RETURN_LOCK_WEEKS)


## A lead that walks out over a named reason (§5.2): the account remembers it, and the company stays out of the pool for
## `lock_weeks`. The first act's loss and a table out of patience end here.
static func lose(lead_id: String, account: String, reason: String, target: String, lock_weeks: int) -> void:
	SalesLedger.report_loss(account, reason, target)
	_leave(lead_id, account, lock_weeks)


static func _leave(lead_id: String, account: String, lock_weeks: int) -> void:
	SalesFaucetSystem.lock_return(account, lock_weeks)
	ProspectRegistry.remove(lead_id)
	EventBus.deal_walked.emit(account)


## The plan a table's deal runs, in half weeks: the founder's star against the customer's, the
## star the table's mismatch reads.
static func table_halfweeks(lead: Prospect) -> int:
	return SalesConstants.deal_halfweeks(lead.star, SalesLedger.founder_star())


## The terms go onto the lead and its plan starts this week. A rep's deal on the same lead gives
## way (§12 "the founder outranks").
static func _open_deal(result: Dictionary, ctx: Dictionary, lead_id: String) -> void:
	var lead: Prospect = ProspectRegistry.get_prospect(lead_id)
	if lead == null:
		return
	var values: Dictionary = result.get("values", {}) as Dictionary
	lead.worked_by = CharacterRegistry.get_founder().id
	lead.work_started_day = GameState.day
	lead.work_stance = ""
	lead.price_break_raised = false
	lead.routing = SalesConstants.ROUTE_NONE
	lead.deal_halfweeks = table_halfweeks(lead)
	lead.deal_paused_halfweeks = 0
	lead.deal_seats = int(values.get("units", 0))
	lead.deal_price = int(values.get("unit_price", 0))
	lead.deal_promise = String(ctx.get("promised", ""))


## The table's deal signs at its agreed terms once its plan has run.
static func sign_deal(lead: Prospect) -> void:
	# DESIGN-PARKED: no signing discount is passed, so the account's `signing_discount` stays 0.
	# Its only source is the §7.6 price-break card, which is not wired (docs/ACIK_ISLER/ACIK_KARARLAR.md,
	# "`sales.price_break` bağlı değil"). Writing the distance under the stance anchor here would
	# show every ordinary haggle as "imza indirimi" on the account page — a number that names the
	# wrong cause is worse than none. Alternative seen: show that distance as "pazarlık farkı" —
	# a naming decision with a string behind it. The field stays in the save schema.
	var c: Customer = SalesSystem.add_b2b_customer(lead, lead.deal_seats, lead.deal_price,
		SalesSystem.signing_satisfaction_seed(), "founder_pitch")

	# §6 — the word given at the table becomes a real debt AT THE SIGNATURE, not before: a
	# promise made to a company that never signed was never given. One open pitch promise at a
	# time, and the ledger is what the next meeting's lock reads.
	if lead.deal_promise != "":
		PromiseRegistry.create(c.id, lead.deal_promise, B2BConstants.PROMISE_DEADLINE_WEEKS)
		SalesLedger.set_open_pitch_promise(c.id)
		EventBus.pitch_promise_made.emit(c.company_name, lead.deal_promise)

	# `whale_condition_met` is NOT emitted here: its single publisher is the faucet's daily
	# sweep, which already announced the door opening (§14: one publisher per signal).
	ProspectRegistry.remove(lead.id)
	SalesLedger.record_close(c, "")
	SalesSystem.record_sales_event("founder_close", "", c.company_name, c.mrr)
	SalesLedger.announce_signing(c, lead.is_whale,
		{"key": "SALES_TICKER_FOUNDER_SIGNED", "args": {"company": c.company_name}})
