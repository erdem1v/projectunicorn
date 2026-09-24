class_name SalesFinalizer
extends RefCounted

# THE SIGNATURE, AND THE TWO WAYS A TABLE ENDS WITHOUT ONE (§5.3, §5.4, §6).
#
# WHY THIS IS ITS OWN FILE. `NegotiationSystem` implements the engine's §9.4 contract and must
# stay TYPE-AGNOSTIC: the same scene is called with `type: "series_a"` and there seats become
# equity and price becomes valuation. A negotiation that knew about `Customer` could not be
# reused, so the outcome APPLIER is separate — this one speaks b2b, and Series A will get its
# own without either touching the other.
#
# EVERY WRITE HERE GOES THROUGH THE OWNING SEAM (WRITE-THROUGH LAW): the customer through
# `SalesSystem.add_b2b_customer` (still the sole B2B signing path), the word given in Act 1
# through `PromiseRegistry.create`, the return lock through `SalesFaucetSystem`, the account
# memory through `SalesLedger`. Not one raw field is touched.


## Apply a finished negotiation. Safe to call with an empty or half-built result — a table
## that produced nothing writes nothing.
static func apply(result: Dictionary) -> void:
	var outcome: String = String(result.get("outcome_id", ""))
	var ctx: Dictionary = result.get("context", {}) as Dictionary
	var lead_id: String = String(ctx.get("lead_id", ""))
	var account: String = String(ctx.get("account", ""))
	if outcome == "":
		return
	match outcome:
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
			EventBus.deal_walked.emit(account)
		NegotiationSystem.OUTCOME_INSULTED:
			# §5.3 — "masa devrilir, hesap hafızasına yazılır". This one IS remembered.
			SalesLedger.record_insult(account)
			_leave(lead_id, account, SalesConstants.RETURN_LOCK_DAYS)
			EventBus.deal_walked.emit(account)


static func _leave(lead_id: String, account: String, lock_days: int) -> void:
	if account != "":
		SalesFaucetSystem.lock_return(account, lock_days)
	if lead_id != "":
		ProspectRegistry.remove(lead_id)


static func _sign(result: Dictionary, ctx: Dictionary, lead_id: String) -> void:
	var lead: Prospect = ProspectRegistry.get_prospect(lead_id)
	if lead == null:
		return
	var values: Dictionary = result.get("values", {}) as Dictionary
	var seats: int = int(values.get("units", 0))
	var price: int = int(values.get("unit_price", 0))
	# DESIGN-PARKED: THE SIGNING DISCOUNT IS NO LONGER WRITTEN, and the field is left at zero.
	# It used to be "how far under the stance anchor this table closed", which is a real and
	# readable number — but the surface it feeds is the §12 price-break trace, and the
	# price-break card is defined-and-inert (§18 puts its wiring in the event package). So the
	# account page was showing "imza indirimi %12" on every ordinary negotiation, sourced from
	# a mechanic that has never once fired. A number that names the wrong cause is worse than
	# no number: the player reads it as evidence of something that did not happen, and every
	# deal carried the same 12% because both sides of the fraction were constants.
	#
	# Placeholder taken: DROP THE WRITE. The alternative is to keep the number and rename the
	# surface honestly to "pazarlık farkı" — the distance the customer talked you down, which
	# is a fact worth showing and belongs to Act 2 rather than to the price break. That is a
	# naming decision with a string behind it, so it goes to the director rather than here.
	# The `signing_discount` field stays in the schema (dropping it is a schema change) and
	# simply stays 0 until the price-break channel is wired.
	var c: Customer = SalesSystem.add_b2b_customer(lead, seats, price,
		PitchSystem.signing_satisfaction_seed(), "founder_pitch")

	# §6 — the word given at the table becomes a real debt AT THE SIGNATURE, not before: a
	# promise made to a company that walked out was never given. One open pitch promise at a
	# time, and the ledger is what the next meeting's lock reads.
	var promised: String = String(ctx.get("promised", ""))
	if promised != "" and c != null:
		PromiseRegistry.create(c.id, promised, B2BConstants.PROMISE_DEADLINE_DAYS)
		SalesLedger.set_open_pitch_promise(c.id, promised)
		EventBus.pitch_promise_made.emit(c.company_name, promised)

	# `whale_condition_met` is NOT emitted here. Its single publisher is the faucet's daily
	# sweep, which fires it the moment the door opens (§14: one publisher per signal). By the
	# time a whale signs, that moment has already been announced — announcing it again at the
	# signature would make one event arrive twice.

	ProspectRegistry.remove(lead.id)
	if c != null:
		SalesSystem.record_sales_event("founder_close", "", c.company_name, c.mrr)
		_maybe_ticker(c, bool(ctx.get("is_whale", false)))


## §7.3 — the rule lives in `SalesLedger.is_newsworthy_signing`; this and the rep desk had two
## copies of it and both leaked every 3★ for the rest of the run.
static func _maybe_ticker(c: Customer, is_whale: bool) -> void:
	if not SalesLedger.is_newsworthy_signing(c, is_whale):
		return
	EventBus.headline_added.emit(B2BConstants.notice_source_sales(),
		TranslationServer.translate("SALES_TICKER_FOUNDER_SIGNED").format(
			{"company": c.company_name}))
	SalesLedger.credit_prestige(c, is_whale)
