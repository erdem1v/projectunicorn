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
	# §5.4 — the signing discount is INSIDE the price and visible as its own trace. It is the
	# distance the customer talked the anchor down, as a fraction, so it stays readable when
	# the seat count later moves.
	var anchor: int = SalesLedger.seat_price_anchor()
	var discount: float = 0.0
	if anchor > 0 and price < anchor:
		discount = clampf(1.0 - float(price) / float(anchor), 0.0, 1.0)

	var c: Customer = SalesSystem.add_b2b_customer(lead, seats, price,
		PitchSystem.signing_satisfaction_seed(), "founder_pitch", discount)

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
		_maybe_ticker(c)


## §7.3 — the ticker sees NEWS ONLY: a league-above signing, a whale, or a 3★. A routine close
## reaches the player through the weekly summary and the account list, not the ticker.
static func _maybe_ticker(c: Customer) -> void:
	if c.scale < SalesConstants.TICKER_NEWSWORTHY_STAR \
			and c.scale <= SalesFaucetSystem.reach_band():
		return
	EventBus.headline_added.emit(B2BConstants.notice_source_sales(),
		TranslationServer.translate("SALES_TICKER_FOUNDER_SIGNED").format(
			{"company": c.company_name}))
