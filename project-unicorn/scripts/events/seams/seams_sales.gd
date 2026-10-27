class_name EvSeamsSales
extends RefCounted

# The `musteri.`, `aday.`, `sales.` and `destek.` namespaces.
#
# A B2B account carries TWO satisfaction numbers: `satisfaction`, which the player sees, and
# `tolerance`, the hidden floor THIS account will put up with. It goes to Risk when the first
# falls under the second. Content may CONDITION on tolerance but never NAME it in copy — that
# would turn a relationship into a spreadsheet. `musteri.under_tolerance` covers the common case.

## An entity seam reading one Customer field, `fallback` when the account is gone.
static func customer_field(field: String, fallback: Variant) -> Callable:
	assert(field in Customer.new(), "Customer has no field '%s'" % field)
	return func(id: String) -> Variant:
		var c: Customer = CustomerRegistry.get_customer(id)
		return c.get(field) if c != null else fallback


static func _promise_row_locked_earlier(id: String) -> bool:
	return not EvSeams.read_for("musteri.has_pain_feature", id) \
		or EvSeams.read_for("musteri.pain_feature_shipped", id) \
		or not EvSeams.read_for("musteri.pain_buildable", id) \
		or EvSeams.read_for("musteri.has_open_promise", id)


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
		"Sales", "WRAPPER; -1 when not counting, else weeks to churn")
	EvSeams.register("musteri.mrr", E, TYPE_INT, customer_field("mrr", 0), "Sales", "WRAPPER")
	EvSeams.register("musteri.seats", E, TYPE_INT, customer_field("seats", 0), "Sales", "WRAPPER")
	EvSeams.register("musteri.scale", E, TYPE_INT, customer_field("scale", 0),
		"Sales", "WRAPPER; 1-5, demo binds to 1-3")
	EvSeams.register("musteri.tenure_weeks", E, TYPE_INT,
		func(id: String) -> int:
			var c: Customer = CustomerRegistry.get_customer(id)
			return GameState.day - c.acquired_on_day if c != null else 0,
		"Sales", "WRAPPER; weeks since signature")
	EvSeams.register("musteri.has_open_promise", E, TYPE_BOOL,
		func(id: String) -> bool: return PromiseRegistry.has_open_for(id),
		"Sales", "a feature was promised and has not resolved")
	# The promise row names one failing clause; when two fail it falls back to its generic text,
	# which reads "a promise is open". So the two late clauses step aside while an earlier
	# clause of the row already locks it.
	EvSeams.register("musteri.broke_promise", E, TYPE_BOOL,
		func(id: String) -> bool:
			var c: Customer = CustomerRegistry.get_customer(id)
			return c != null and B2BSalesSystem.promise_relocked(c) and not _promise_row_locked_earlier(id),
		"Sales", "a promise to this account broke inside the relock window and nothing earlier locks the promise row")
	EvSeams.register("musteri.promise_fits", E, TYPE_BOOL,
		func(id: String) -> bool:
			var c: Customer = CustomerRegistry.get_customer(id)
			return c != null and (_promise_row_locked_earlier(id) or B2BSalesSystem.promise_relocked(c)
				or SprintSystem.fits_plannable(c.pain_feature_id)),
		"Sales", "the account's wish fits the free points of the next plannable sprint, or another clause locks the promise row")
	EvSeams.register("musteri.is_assigned", E, TYPE_BOOL,
		func(id: String) -> bool:
			var c: Customer = CustomerRegistry.get_customer(id)
			return c != null and c.assigned_to != "",
		"Sales", "WRAPPER; a CS rep carries it, rather than the founder")
	EvSeams.register("musteri.thanks_variant", E, TYPE_INT,
		func(id: String) -> int: return int(SprintBridges.thanks_of(id).get("variant", 0)),
		"Sales", "which body of the release thanks note the account's latest thanks reads, for by_seam text")
	EvSeams.register("musteri.met_feature", E, TYPE_STRING,
		func(id: String) -> String:
			var step: String = String(SprintBridges.thanks_of(id).get("feature", ""))
			return SprintCatalog.step_name_key(step) if step != "" else "",
		"Sales", "the name KEY of the step the account's latest thanks is for; text reads it in the live language, a history row keeps the key")

	EvSeams.register("musteri.sector", E, TYPE_STRING, customer_field("industry", ""),
		"Sales", "WRAPPER; the sector id (health, finance, logistics ...)")
	EvSeams.register("musteri.bugs", E, TYPE_INT,
		func(id: String) -> int:
			var c: Customer = CustomerRegistry.get_customer(id)
			return B2BSalesSystem.account_bugs(c) if c != null else 0,
		"Sales", "open bugs on the lines this account uses")
	EvSeams.register("musteri.onboarding_short", E, TYPE_BOOL,
		func(id: String) -> bool:
			var c: Customer = CustomerRegistry.get_customer(id)
			if c == null:
				return false
			var ref: Dictionary = c.market_ref if not c.market_ref.is_empty() else ProductQuality.market_ref_for(c.scale, c.industry)
			return ProductQuality.level("onboarding") < float(ref.get("onboarding", 0.0)),
		"Sales", "the product's Onboarding is under what this account expects of it")
	EvSeams.register("musteri.promise_late", E, TYPE_BOOL,
		func(id: String) -> bool:
			var cards: Array = SprintBridges.promise_cards(id)
			return not cards.is_empty() and cards.all(SprintSystem.card_late),
		"Sales", "the step of the account's oldest open promise is in the running sprint and none of its cards will finish in it")
	EvSeams.register("musteri.promise_extended", E, TYPE_BOOL,
		func(id: String) -> bool:
			var open: Array = PromiseRegistry.get_open_for(id)
			return not open.is_empty() and open[0].extended,
		"Sales", "the account's oldest open promise has already moved a sprint; a word moves once")
	EvSeams.register("musteri.promise_card", E, TYPE_STRING,
		func(id: String) -> String:
			var open: Array = PromiseRegistry.get_open_for(id)
			return SprintCatalog.step_name_key(open[0].feature_id) if not open.is_empty() else "",
		"Sales", "the name KEY of the step the account's oldest open promise is for, '' with none; text reads it in the live language, a history row keeps the key")
	EvSeams.register("musteri.has_notice", E, TYPE_BOOL,
		func(id: String) -> bool:
			var c: Customer = CustomerRegistry.get_customer(id)
			return c != null and (c.exit_notice_day >= 0 or c.notice_end_day >= 0),
		"Sales", "the account has given notice, outside the server clause or under it")

	# --- Prospects ----------------------------------------------------------
	EvSeams.register("aday.sector", E, TYPE_STRING,
		func(id: String) -> String:
			var p: Prospect = ProspectRegistry.get_prospect(id)
			return p.industry if p != null else "",
		"Sales", "the lead's sector id (health, finance, logistics ...)")

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
		func() -> int: return CustomerRegistry.get_min_satisfaction(), "Sales", "worst account")
	EvSeams.register("musteri.at_risk_count", G, TYPE_INT,
		func() -> int: return B2BSalesSystem.attention_count(),
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
		func() -> String: return SalesSystem.growth_band(), "Sales", "melting | flat | steady | fast")
	# KAÇ HESAP — `musteri.count`'tan farkı B2C toplu kullanıcı tabanı kaydıdır: o bir KİTLE,
	# hesap değil, sıfır koltukludur ve "defterde N hesap var" cümlesinde sayılmaz.
	EvSeams.register("sales.account_count", G, TYPE_INT,
		func() -> int: return CustomerRegistry.account_count(),
		"Sales", "accounts in the book; excludes the B2C aggregate userbase")
	EvSeams.register("sales.big_accounts", G, TYPE_INT,
		func() -> int:
			return CustomerRegistry.get_by_market("b2b").filter(
				func(c: Customer) -> bool: return c.scale >= B2BConstants.CLAUSE_STAR).size(),
		"Sales", "B2B accounts of the server clause's size (CLAUSE_STAR stars and up)")
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
