class_name EvSeamsSales
extends RefCounted

# The `musteri.`, `sales.` and `destek.` namespaces.
#
# A B2B account carries TWO satisfaction numbers: `satisfaction`, which the player sees, and
# `tolerance`, the hidden floor THIS account will put up with. It goes to Risk when the first
# falls under the second. Content may CONDITION on tolerance but never NAME it in copy — that
# would turn a relationship into a spreadsheet. `musteri.under_tolerance` covers the common case.

## An entity seam reading one Customer field, `fallback` when the account is gone.
static func customer_field(field: String, fallback: Variant) -> Callable:
	return func(id: String) -> Variant:
		var c: Customer = CustomerRegistry.get_customer(id)
		return c.get(field) if c != null else fallback


static func install() -> void:
	var G := EvSeams.Kind.GLOBAL
	var E := EvSeams.Kind.ENTITY

	# --- Per-account --------------------------------------------------------
	EvSeams.register("musteri.satisfaction", E, TYPE_INT, customer_field("satisfaction", 0),
		"Sales", "WRAPPER; 0-100, the number the player can see")
	EvSeams.register("musteri.tolerance", E, TYPE_INT, customer_field("tolerance", 0),
		"Sales", "WRAPPER; HIDDEN from the player. Condition on it, never name it in copy")
	EvSeams.register("musteri.under_tolerance", E, TYPE_BOOL,
		func(id: String) -> bool:
			var c: Customer = CustomerRegistry.get_customer(id)
			return c != null and c.satisfaction < c.tolerance,
		"Sales", "the comparison that actually drives Risk")
	EvSeams.register("musteri.lifecycle_phase", E, TYPE_STRING, customer_field("lifecycle_phase", ""),
		"Sales", "onboarding | active | risk | churning | expansion")
	EvSeams.register("musteri.churn_countdown", E, TYPE_INT, customer_field("churn_countdown", -1),
		"Sales", "WRAPPER; -1 when not counting, else days to churn")
	EvSeams.register("musteri.mrr", E, TYPE_INT, customer_field("mrr", 0), "Sales", "WRAPPER")
	EvSeams.register("musteri.seats", E, TYPE_INT, customer_field("seats", 0), "Sales", "WRAPPER")
	EvSeams.register("musteri.scale", E, TYPE_INT, customer_field("scale", 0),
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
	# RECORDS, NOT ACCOUNTS, and the difference is load-bearing: the Traction gate asks
	# `musteri.count >= 1` for "your first real customer", and on a B2C run that customer IS
	# the aggregate userbase record. "How many ACCOUNTS" is `sales.account_count` below.
	EvSeams.register("musteri.count", G, TYPE_INT,
		func() -> int: return CustomerRegistry.get_active().size(),
		"Sales", "active customer RECORDS — includes the B2C aggregate; see sales.account_count")
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
	# §7.3'ün haftalık özeti SATIR ister, cümle değil; aritmetik ve biçim Satış'ta durur.
	EvSeams.register("sales.weekly_closes", G, TYPE_STRING,
		func() -> String: return SalesLedger.weekly_close_lines(),
		"Sales", "this week's closes, one line each, with a total")
	# KAÇ HESAP — `musteri.count`'tan farkı B2C toplu kullanıcı tabanı kaydıdır: o bir KİTLE,
	# hesap değil, sıfır koltukludur ve "defterde N hesap var" cümlesinde sayılmaz.
	EvSeams.register("sales.account_count", G, TYPE_INT,
		func() -> int: return CustomerRegistry.account_count(),
		"Sales", "accounts in the book; excludes the B2C aggregate userbase")
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
