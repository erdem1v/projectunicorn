class_name EvSeamsSales
extends RefCounted

# The `musteri.`, `sales.` and `destek.` namespaces (docs/SEAM_REGISTRY.md §5).
#
# ONE THING HERE IS NOT A MECHANICAL WRAPPER AND IS WORTH READING.
#
# A B2B account carries TWO satisfaction numbers, not one. `satisfaction` is what the player
# can see; `tolerance` is the floor THIS account will put up with, seeded from its scale and
# sector (b2b_constants.gd:48) and never shown. The account goes to Risk when satisfaction
# falls under tolerance — so the same visible 45 is fine for one customer and a crisis for
# another, which is the entire reason the accounts feel like different companies.
#
# Content may CONDITION on tolerance. Content may not NAME it — a card that says "you are
# three points under their tolerance" turns a relationship into a spreadsheet and tells the
# player about a number the game deliberately hides. That is a writing rule, and it belongs in
# the vocabulary document, but the seam is registered here with the caveat attached so nobody
# meets the number without meeting the rule.
#
# `musteri.under_tolerance` exists so the common case does not require reading both.

static func install() -> void:
	var G := EvSeams.Kind.GLOBAL
	var E := EvSeams.Kind.ENTITY

	# --- Per-account --------------------------------------------------------
	EvSeams.register("musteri.satisfaction", E, TYPE_INT,
		func(id: String) -> int:
			var c: Customer = CustomerRegistry.get_customer(id)
			return c.satisfaction if c != null else 0,
		"Sales", "WRAPPER; 0-100, the number the player can see")
	EvSeams.register("musteri.tolerance", E, TYPE_INT,
		func(id: String) -> int:
			var c: Customer = CustomerRegistry.get_customer(id)
			return c.tolerance if c != null else 0,
		"Sales", "WRAPPER; HIDDEN from the player. Condition on it, never name it in copy")
	EvSeams.register("musteri.under_tolerance", E, TYPE_BOOL,
		func(id: String) -> bool:
			var c: Customer = CustomerRegistry.get_customer(id)
			return c != null and c.satisfaction < c.tolerance,
		"Sales", "the comparison that actually drives Risk")
	EvSeams.register("musteri.lifecycle_phase", E, TYPE_STRING,
		func(id: String) -> String:
			var c: Customer = CustomerRegistry.get_customer(id)
			return c.lifecycle_phase if c != null else "",
		"Sales", "onboarding | active | risk | churning | expansion")
	EvSeams.register("musteri.churn_countdown", E, TYPE_INT,
		func(id: String) -> int:
			var c: Customer = CustomerRegistry.get_customer(id)
			return c.churn_countdown if c != null else -1,
		"Sales", "WRAPPER; -1 when not counting, else days to churn")
	EvSeams.register("musteri.mrr", E, TYPE_INT,
		func(id: String) -> int:
			var c: Customer = CustomerRegistry.get_customer(id)
			return c.mrr if c != null else 0,
		"Sales", "WRAPPER")
	EvSeams.register("musteri.seats", E, TYPE_INT,
		func(id: String) -> int:
			var c: Customer = CustomerRegistry.get_customer(id)
			return c.seats if c != null else 0,
		"Sales", "WRAPPER")
	EvSeams.register("musteri.scale", E, TYPE_INT,
		func(id: String) -> int:
			var c: Customer = CustomerRegistry.get_customer(id)
			return c.scale if c != null else 0,
		"Sales", "WRAPPER; 1-5, demo binds to 1-3")
	EvSeams.register("musteri.tenure_days", E, TYPE_INT,
		func(id: String) -> int:
			var c: Customer = CustomerRegistry.get_customer(id)
			return GameState.day - c.acquired_on_day if c != null else 0,
		"Sales", "WRAPPER; days since signature")
	EvSeams.register("musteri.has_open_promise", E, TYPE_BOOL,
		func(id: String) -> bool: return PromiseRegistry.has_open_for(id),
		"Sales", "a feature was promised and has not resolved")
	EvSeams.register("musteri.is_assigned", E, TYPE_BOOL,
		func(id: String) -> bool:
			var c: Customer = CustomerRegistry.get_customer(id)
			return c != null and c.assigned_to != "",
		"Sales", "WRAPPER; a CS rep carries it, rather than the founder")

	# --- Book-wide ----------------------------------------------------------
	EvSeams.register("musteri.count", G, TYPE_INT,
		func() -> int: return CustomerRegistry.get_active().size(), "Sales", "active accounts")
	EvSeams.register("musteri.total_mrr", G, TYPE_INT,
		func() -> int: return CustomerRegistry.get_total_mrr(), "Sales", "")
	EvSeams.register("musteri.min_satisfaction", G, TYPE_INT,
		func() -> int: return CustomerRegistry.get_min_satisfaction(""), "Sales", "worst account")
	EvSeams.register("musteri.at_risk_count", G, TYPE_INT,
		func() -> int:
			var n: int = 0
			for c in CustomerRegistry.get_active():
				if (c as Customer).lifecycle_phase == "risk":
					n += 1
			return n,
		"Sales", "accounts currently in Risk")
	EvSeams.register("musteri.lost_this_run", G, TYPE_INT,
		func() -> int: return GameState.run_customers_lost, "Sales", "WRAPPER; churn counter")

	# --- Pipeline and B2C ---------------------------------------------------
	EvSeams.register("sales.pipeline_count", G, TYPE_INT,
		func() -> int: return ProspectRegistry.count(), "Sales", "live prospects")
	EvSeams.register("sales.is_b2b", G, TYPE_BOOL,
		func() -> bool: return SalesSystem.is_b2b_market(),
		"Sales", "reads the SHIPPED market, not one being built")
	EvSeams.register("sales.b2c_audience", G, TYPE_FLOAT,
		func() -> float: return SalesSystem.b2c_audience(),
		"Sales", "float: it carries a sub-unit accumulator")
	EvSeams.register("sales.b2c_price", G, TYPE_INT,
		func() -> int: return int(GameState.get_flag("b2c_price", 15)),
		"Sales", "WRAPPER; monthly price")
	EvSeams.register("sales.growth_band", G, TYPE_STRING,
		func() -> String: return SalesSystem.growth_band(), "Sales", "")
	EvSeams.register("sales.market_share_pct", G, TYPE_FLOAT,
		func() -> float: return RivalRegistry.get_player_share_pct(),
		"Sales", "one global figure; per-segment share does not exist yet")

	# --- Support ------------------------------------------------------------
	EvSeams.register("destek.desk_staffed", G, TYPE_BOOL,
		func() -> bool: return SupportSystem.desk_staffed(), "Ops", "anyone on support at all")
	EvSeams.register("destek.warmth_band", G, TYPE_STRING,
		func() -> String: return SupportSystem.warmth_band(),
		"Ops", "calm | warm | hot at 20 / 40 unvalidated reports")
	EvSeams.register("destek.absorb_ceiling", G, TYPE_INT,
		func() -> int: return CustomerRepSystem.absorb_ceiling(),
		"Ops", "requests the desk can take before escalating")
