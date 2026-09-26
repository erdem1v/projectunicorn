class_name SalesFinalizer
extends RefCounted

# THE SIGNATURE, AND THE TWO WAYS A TABLE ENDS WITHOUT ONE (§5.3, §5.4, §6).
#
# WHY THIS IS ITS OWN FILE. `NegotiationSystem` implements the engine's §9.4 contract and must
# stay TYPE-AGNOSTIC: §5.3 reserves the same scene for Series A, where seats become equity and
# price becomes valuation. A negotiation that knew about `Customer` could not be reused, so the
# outcome APPLIER is separate and this one speaks b2b.
#
# EVERY WRITE HERE GOES THROUGH THE OWNING SEAM (WRITE-THROUGH LAW): the customer through
# `SalesSystem.add_b2b_customer` (the sole B2B signing path), the word given in Act 1 through
# `PromiseRegistry.create`, the return lock through `SalesFaucetSystem`, the account memory
# through `SalesLedger`. Not one raw field is touched.


## Apply a finished negotiation. Safe to call with an empty or half-built result — a table
## that produced nothing writes nothing.
static func apply(result: Dictionary) -> void:
	var ctx: Dictionary = result.get("context", {}) as Dictionary
	var lead_id: String = String(ctx.get("lead_id", ""))
	var account: String = String(ctx.get("account", ""))
	match String(result.get("outcome_id", "")):
		NegotiationSystem.OUTCOME_SIGNED:
			_sign(result, ctx, lead_id)
		NegotiationSystem.OUTCOME_WALKED:
			# TWO WAYS OFF THE SAME TABLE, and they are not the same event. A player who
			# stands up walks NEUTRALLY: a 30-day lock and no trace (§5.3). A table that ran
			# out of patience is a LOSS on price (§12), and it is remembered — which is what
			# makes the re-pitch blocker have something to read next time.
			var reason: String = String((result.get("values", {}) as Dictionary).get("reason", ""))
			if reason != "":
				SalesLedger.report_loss(account, reason, "")
			_leave(lead_id, account, SalesConstants.WALK_LOCK_DAYS)
		NegotiationSystem.OUTCOME_INSULTED:
			# §5.3 — "masa devrilir, hesap hafızasına yazılır". This one IS remembered.
			SalesLedger.record_insult(account)
			_leave(lead_id, account, SalesConstants.RETURN_LOCK_DAYS)


static func _leave(lead_id: String, account: String, lock_days: int) -> void:
	SalesFaucetSystem.lock_return(account, lock_days)
	ProspectRegistry.remove(lead_id)
	EventBus.deal_walked.emit(account)


static func _sign(result: Dictionary, ctx: Dictionary, lead_id: String) -> void:
	var lead: Prospect = ProspectRegistry.get_prospect(lead_id)
	if lead == null:
		return
	var values: Dictionary = result.get("values", {}) as Dictionary
	var seats: int = int(values.get("units", 0))
	var price: int = int(values.get("unit_price", 0))
	# DESIGN-PARKED: no signing discount is passed, so the account's `signing_discount` stays 0.
	# Its only source is the §7.6 price-break card, which is not wired (docs/ACIK_ISLER/ACIK_KARARLAR.md,
	# "`sales.price_break` bağlı değil"). Writing the distance under the stance anchor here would
	# show every ordinary haggle as "imza indirimi" on the account page — a number that names the
	# wrong cause is worse than none. Alternative seen: show that distance as "pazarlık farkı" —
	# a naming decision with a string behind it. The field stays in the save schema.
	var c: Customer = SalesSystem.add_b2b_customer(lead, seats, price,
		PitchSystem.signing_satisfaction_seed(), "founder_pitch")

	# §6 — the word given at the table becomes a real debt AT THE SIGNATURE, not before: a
	# promise made to a company that walked out was never given. One open pitch promise at a
	# time, and the ledger is what the next meeting's lock reads.
	var promised: String = String(ctx.get("promised", ""))
	if promised != "":
		PromiseRegistry.create(c.id, promised, B2BConstants.PROMISE_DEADLINE_DAYS)
		SalesLedger.set_open_pitch_promise(c.id, promised)
		EventBus.pitch_promise_made.emit(c.company_name, promised)

	# `whale_condition_met` is NOT emitted here: its single publisher is the faucet's daily
	# sweep, which already announced the door opening (§14: one publisher per signal).
	ProspectRegistry.remove(lead.id)
	SalesSystem.record_sales_event("founder_close", "", c.company_name, c.mrr)
	SalesLedger.announce_signing(c, bool(ctx.get("is_whale", false)),
		TranslationServer.translate("SALES_TICKER_FOUNDER_SIGNED").format({"company": c.company_name}))
