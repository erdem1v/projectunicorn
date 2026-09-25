class_name EvSeamsPorted
extends RefCounted

# Seams the MIGRATED cards need (docs/EVENT_MIGRATION_LEDGER.md §B).
#
# Every one of these is a value a factory already read directly off a model. The factory could
# do that — it lived inside the system. Content cannot, and should not: `Customer.retain_discounts`
# is a field name, and a field name is not a contract. Naming it is what lets the discount cap
# move from 2 to 3 without touching a card.
#
# Kept in its own file rather than merged into the namespace files because these came from a
# migration and the distinction is worth being able to see: when the writing round rewrites a
# ported card, this is the list of things it was leaning on.

static func install() -> void:
	var E := EvSeams.Kind.ENTITY
	var G := EvSeams.Kind.GLOBAL

	# --- musteri. : the B2B family ---------------------------------------
	EvSeams.register("musteri.is_at_risk", E, TYPE_BOOL,
		func(id: String) -> bool:
			var c: Customer = CustomerRegistry.get_customer(id)
			return c != null and c.lifecycle_phase == "risk",
		"Sales", "the account is in a Risk episode")
	EvSeams.register("musteri.is_expansion_ready", E, TYPE_BOOL,
		func(id: String) -> bool:
			var c: Customer = CustomerRegistry.get_customer(id)
			return c != null and B2BSalesSystem.can_offer_expansion(c),
		"Sales", "mature, healthy, and never yet offered expansion")
	EvSeams.register("musteri.has_pain_feature", E, TYPE_BOOL,
		func(id: String) -> bool:
			var c: Customer = CustomerRegistry.get_customer(id)
			return c != null and c.pain_feature_id != "",
		"Sales", "the account wants a specific feature")
	EvSeams.register("musteri.pain_feature_shipped", E, TYPE_BOOL,
		func(id: String) -> bool:
			var c: Customer = CustomerRegistry.get_customer(id)
			if c == null or c.pain_feature_id == "":
				return false
			return ProductState.is_feature_live(c.pain_feature_id),
		"Sales", "gates the promise row: promising work already done pays for nothing")
	EvSeams.register("musteri.pain_buildable", E, TYPE_BOOL,
		func(id: String) -> bool:
			var c: Customer = CustomerRegistry.get_customer(id)
			if c == null or c.pain_feature_id == "":
				return false
			# A line step is buildable when its gate is open today (LineGates is the one
			# validator). A flat feature has no gate. Event revision 2026-09: without this
			# leaf a promise could name a step that needs research nobody had done, and 241
			# of the probe's broken promises were exactly that.
			if ProductLines.step(c.pain_feature_id).is_empty():
				return true
			return LineGates.is_unlocked(c.pain_feature_id),
		"Sales", "gates the promise row: nobody can promise what the company cannot build yet")
	EvSeams.register("musteri.discounts_used", E, TYPE_INT,
		func(id: String) -> int:
			var c: Customer = CustomerRegistry.get_customer(id)
			return c.retain_discounts if c != null else 0,
		"Sales", "0-2; the discount row locks at the cap")
	EvSeams.register("musteri.stalls_used", E, TYPE_INT,
		func(id: String) -> int:
			var c: Customer = CustomerRegistry.get_customer(id)
			return c.retain_stalls if c != null else 0,
		"Sales", "0-2; the stall row locks at the cap")
	EvSeams.register("musteri.cs_escalated", E, TYPE_BOOL,
		func(id: String) -> bool:
			var c: Customer = CustomerRegistry.get_customer(id)
			return c != null and c.cs_escalated,
		"Sales", "an escalation is already open on this account")
	EvSeams.register("musteri.request_kind", E, TYPE_STRING,
		func(id: String) -> String:
			var c: Customer = CustomerRegistry.get_customer(id)
			return B2BEventFactory.pick_request_kind(c) if c != null else "",
		"Sales", "complaint | feature | renewal — state-scored, no RNG")

	# Prose, not numbers. §8.4's interpolation mechanism reads these, which is how one card
	# carries fifteen sector voices instead of fifteen near-identical cards carrying one each.
	EvSeams.register("musteri.company_name", E, TYPE_STRING,
		func(id: String) -> String:
			var c: Customer = CustomerRegistry.get_customer(id)
			return c.company_name if c != null else "",
		"Sales", "for {customer} in prose")
	EvSeams.register("musteri.complaint_voice", E, TYPE_STRING,
		func(id: String) -> String:
			var c: Customer = CustomerRegistry.get_customer(id)
			return B2BConstants.complaint_voice(c.industry) if c != null else "",
		"Sales", "the per-sector complaint line")
	EvSeams.register("musteri.risk_voice", E, TYPE_STRING,
		func(id: String) -> String:
			return B2BSalesSystem.risk_voice(CustomerRegistry.get_customer(id)),
		"Sales", "what an account in Risk says, by the cause of the Risk")
	EvSeams.register("musteri.sector_contact", E, TYPE_STRING,
		func(id: String) -> String:
			var c: Customer = CustomerRegistry.get_customer(id)
			return B2BConstants.sector_contact(c.industry) if c != null else "",
		"Sales", "the speaker's role line")
	EvSeams.register("musteri.pain_feature_label", E, TYPE_STRING,
		func(id: String) -> String:
			var c: Customer = CustomerRegistry.get_customer(id)
			return B2BConstants.feature_label(c.pain_feature_id) if c != null else "",
		"Sales", "the feature the promise row names")

	# --- hr. -------------------------------------------------------------
	EvSeams.register("hr.resign_voice", E, TYPE_STRING,
		func(id: String) -> String: return HRConstants.resign_voice(id),
		"HR", "the per-person resignation line")

	# --- urun. -----------------------------------------------------------
	EvSeams.register("urun.days_since_launch", G, TYPE_INT,
		func() -> int:
			# -1 when nothing has launched, NEVER 0. A run whose product has not shipped must
			# not satisfy "one day after it shipped" — the same trap days_since_flag documents
			# for absent stamps, and the reason the paid-tier card's port needed a seam rather
			# than a stamp: mvp_launch_day is written by ProductSystem into GameState, which
			# the engine's own flag store has never heard of.
			if not GameState.has_flag("mvp_launch_day"):
				return -1
			return GameState.day - int(GameState.get_flag("mvp_launch_day", 0)),
		"Product", "-1 when nothing has shipped")
	EvSeams.register("urun.iteration_round", G, TYPE_INT,
		func() -> int:
			var b = ProductSystem.get_active_build()
			return b.iteration_count if b != null else 0,
		"Product", "design rounds completed on the active build")

	# --- funding. --------------------------------------------------------
	EvSeams.register("funding.hard_mode", G, TYPE_BOOL,
		func() -> bool: return bool(GameState.get_flag("hard_mode_unlocked", false)),
		"Funding", "RESERVED — no writer exists; the honest lock on Frank's decline row")
	EvSeams.register("funding.angel_threshold_met", G, TYPE_BOOL,
		func() -> bool: return GameState.mrr >= AngelRoundSystem.MRR_THRESHOLD,
		"Funding", "MRR has crossed the bar Frank's cheque waits on")
	EvSeams.register("funding.angel_days_since_accept", G, TYPE_INT,
		func() -> int:
			var d: int = int(GameState.get_flag(AngelRoundSystem.FLAG_ACCEPTED_DAY, 0))
			return -1 if d <= 0 else GameState.day - d,
		"Investment", "-1 when the cheque has not landed; the day stamp stays in GameState")
	EvSeams.register("funding.gate_pending_phase", G, TYPE_INT,
		func() -> int: return GameState.pending_next_phase,
		"Funding", "WRAPPER; 0 when no gate is open")
	EvSeams.register("funding.sheet_days_left", G, TYPE_INT,
		func() -> int:
			# The MINIMUM across live sheets, because the warning is about the one about to
			# lapse. 9999 with no sheets so a "<= 3" test cannot be satisfied by having none.
			# BUSINESS days since K5 (2026-09): the validity window is ten weekdays, and this
			# number is printed in Frank's warning. A sheet whose window has already closed is
			# funding.sheet_decision's, not the warning's, and is left out.
			var least: int = 9999
			for sheet in GameState.active_sheets:
				var ts: TermSheet = sheet
				if ts.is_decision_due(GameState.day):
					continue
				least = mini(least, ts.business_days_left(GameState.day))
			return least,
		"Funding", "business days; 9999 when no sheet is live")
	EvSeams.register("funding.sheet_decision_due", G, TYPE_BOOL,
		func() -> bool: return VCPitchSystem.decision_due_sheet() != null,
		"Funding", "K10: a Series A sheet's window has closed and waits for sit-or-decline")
	EvSeams.register("funding.last_answer_moment", G, TYPE_BOOL,
		func() -> bool: return VCPitchSystem.is_last_answer_moment(),
		"Investment", "one sheet, one day left, and no other table to walk to")
	EvSeams.register("funding.meeting_day_arrived", G, TYPE_BOOL,
		func() -> bool:
			var pm: Dictionary = GameState.pending_meeting
			return not pm.is_empty() and int(pm.get("day", 0)) <= GameState.day,
		"Funding", "a booked meeting's day has come")

	# --- funding. · the seed rung ---------------------------------------
	EvSeams.register("funding.seed_door_open", G, TYPE_BOOL,
		func() -> bool: return SeedRoundSystem.door_open(),
		"Funding", "the Traction-phase door is latched and unspent")
	EvSeams.register("funding.seed_taken", G, TYPE_BOOL,
		func() -> bool: return GameState.seed_lead != "",
		"Funding", "a seed round was signed this run")
	EvSeams.register("funding.seed_offer_live", G, TYPE_BOOL,
		func() -> bool: return GameState.seed_sheet != null,
		"Funding", "an unsigned seed offer is on the table; it never expires")
	EvSeams.register("funding.seed_pitch_used", G, TYPE_BOOL,
		func() -> bool: return GameState.seed_pitch_used,
		"Funding", "the run's one seed meeting has been spent")
	# INT, NOT THE BAND ID. EvPresenter._resolve_variant runs a by_seam value through int(), so
	# a String here would collapse to 0 and every variant body would render the harsh arm
	# forever — the failure would be invisible because a body still appears.
	EvSeams.register("funding.seed_band", G, TYPE_INT,
		func() -> int:
			var s: TermSheet = GameState.seed_sheet
			return SeedConstants.band_index(String(s.band)) if s != null else 0,
		"Funding", "0 harsh · 1 standard · 2 strong — an INDEX, for by_seam bodies")
	EvSeams.register("funding.seed_expectation", G, TYPE_INT,
		func() -> int: return SeedRoundSystem.expectation_state(),
		"Funding", "0 none · 1 grace · 2 on track · 3 durgun (SeedConstants.EXPECT_*)")
	EvSeams.register("funding.seed_days_since_close", G, TYPE_INT,
		func() -> int:
			var d: int = GameState.seed_closed_day
			return -1 if d < 0 else GameState.day - d,
		"Funding", "-1 until the round closes; mirrors funding.angel_days_since_accept")

	# --- funding. · the buyout offer -------------------------------------
	EvSeams.register("funding.acq_road_over", G, TYPE_BOOL,
		func() -> bool: return EndingsSystem.road_over(),
		"Funding", "faced Series A by a decline or a walk, and no table is left to walk to")
	EvSeams.register("funding.acq_days_open", G, TYPE_INT,
		func() -> int: return EndingsSystem.acq_days_open(),
		"Funding", "-1 until the road closes; the buyout window is measured from that stamp")
	# THE TWO THAT EXIST BECAUSE OF A SHIPPED BUG. The sealed buyout body carries {valuation}
	# and {offer}; neither is a scope slot, so as CSV tokens they reached the screen as literal
	# text (FRANK_VERIFY_2026-08-21.md:166). STRING, and formatted here, because the body reads
	# them through {seam:} and _interpolate does str() on whatever comes back — an INT would put
	# "1440000" in a sentence about a valuation. Formatting at READ time is not "localized text
	# in state": nothing is stored, the money mark is resolved per locale by Fmt.
	EvSeams.register("funding.acq_valuation", G, TYPE_STRING,
		func() -> String: return Fmt.money(EndingsSystem.acquisition_valuation()),
		"Funding", "the buyer's price for the whole company: ARR x multiple")
	EvSeams.register("funding.acq_offer", G, TYPE_STRING,
		func() -> String: return Fmt.money(EndingsSystem.acquisition_founder_share()),
		"Funding", "the founder's slice of that price — what the sealed line calls 'your share'")
