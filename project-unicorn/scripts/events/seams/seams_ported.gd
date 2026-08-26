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
			return (GameState.get_flag("mvp_components", []) as Array).has(c.pain_feature_id),
		"Sales", "gates the promise row: promising work already done pays for nothing")
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
			var least: int = 9999
			for sheet in GameState.active_sheets:
				least = mini(least, int(sheet.days_left(GameState.day)))
			return least,
		"Funding", "9999 when no sheet is live")
	EvSeams.register("funding.last_answer_moment", G, TYPE_BOOL,
		func() -> bool: return VCPitchSystem.is_last_answer_moment(),
		"Investment", "one sheet, one day left, and no other table to walk to")
	EvSeams.register("funding.meeting_day_arrived", G, TYPE_BOOL,
		func() -> bool:
			var pm: Dictionary = GameState.pending_meeting
			return not pm.is_empty() and int(pm.get("day", 0)) <= GameState.day,
		"Funding", "a booked meeting's day has come")
