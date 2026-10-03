class_name EvSeamsProduct
extends RefCounted

# The `urun.` and `arge.` namespaces. Almost every row binds a query the Ürün and Ar-Ge read
# surfaces already name (ProductRead.X is the GDD's urun.X); a renamed query is a broken
# contract on their side and lint reports it.

static func install() -> void:
	_install_product()
	_install_rnd()


static func _install_product() -> void:
	var G := EvSeams.Kind.GLOBAL

	EvSeams.register("urun.is_live", G, TYPE_BOOL,
		func() -> bool: return ProductState.is_live(),
		"Product", "something has shipped")
	EvSeams.register("urun.version", G, TYPE_INT,
		func() -> int: return ProductState.version(),
		"Product", "shipped version number")
	EvSeams.register("urun.version_age", G, TYPE_INT,
		func() -> int: return ProductRead.version_age(),
		"Product", "weeks since THIS VERSION shipped, not since the product was born")
	EvSeams.register("urun.market_type", G, TYPE_STRING,
		func() -> String: return ProductState.market_type(),
		"Product", "b2b | b2c; empty until the product type is chosen")
	EvSeams.register("urun.subtype", G, TYPE_STRING,
		func() -> String: return ProductState.subtype(),
		"Product", "one of the sub-product ids")

	# Sprint. A card cannot be a scope slot, so a decision card's text names the card it is
	# about through urun.decision_card.
	EvSeams.register("urun.sprint_number", G, TYPE_INT,
		func() -> int: return SprintSystem.sprint_number(),
		"Product", "the open sprint; 0 before the product type is chosen")
	EvSeams.register("urun.sprint_week", G, TYPE_INT,
		func() -> int: return SprintSystem.week(),
		"Product", "1 or 2 inside a running sprint")
	EvSeams.register("urun.sprint_running", G, TYPE_BOOL,
		func() -> bool: return SprintSystem.mode() == "active",
		"Product", "a sprint is under way: not planning, not the release note")
	EvSeams.register("urun.decision_card", G, TYPE_STRING,
		func() -> String: return _decision_card(),
		"Product", "name of the card a sprint decision waits on; empty when none")
	EvSeams.register("urun.decision_card_late", G, TYPE_BOOL,
		func() -> bool: return SprintSystem.decision_card_late(),
		"Product", "at the team's pace the decision card will not finish this sprint; false when none waits")
	EvSeams.register("urun.decision_card_effort", G, TYPE_INT,
		func() -> int:
			var card: Dictionary = SprintSystem.decision_card()
			return 0 if card.is_empty() else roundi(SprintSystem.total(card)),
		"Product", "the decision card's effort in points; 0 when none waits")

	# Quality. Axis readings, not a single score — §17's triangle rule says the player reads
	# the asymmetry, so content asks about an axis and never about "quality" as one number.
	EvSeams.register("urun.axis_innovation", G, TYPE_INT,
		func() -> int: return ProductRead.axis_reading("", "innovation"), "Product", "0-120")
	EvSeams.register("urun.axis_stability", G, TYPE_INT,
		func() -> int: return ProductRead.axis_reading("", "stability"), "Product", "0-120")
	EvSeams.register("urun.axis_experience", G, TYPE_INT,
		func() -> int: return ProductRead.axis_reading("", "experience"), "Product", "0-120")

	# The floor ladder's trigger (Ürün §14): "" / warning at floor+20% / crossed.
	EvSeams.register("urun.floor_innovation", G, TYPE_STRING,
		func() -> String: return ProductRead.axis_floor_state("innovation"),
		"Product", "'' | warning | crossed")
	EvSeams.register("urun.floor_stability", G, TYPE_STRING,
		func() -> String: return ProductRead.axis_floor_state("stability"),
		"Product", "'' | warning | crossed")
	EvSeams.register("urun.floor_experience", G, TYPE_STRING,
		func() -> String: return ProductRead.axis_floor_state("experience"),
		"Product", "'' | warning | crossed")

	EvSeams.register("urun.bugs_confirmed", G, TYPE_INT,
		func() -> int: return ProductRead.confirmed_open(), "Product", "confirmed live bugs")
	EvSeams.register("urun.bugs_unconfirmed", G, TYPE_INT,
		func() -> int: return ProductRead.unconfirmed(), "Product", "incoming, unvalidated reports")
	EvSeams.register("urun.interest", G, TYPE_FLOAT,
		func() -> float: return ProductRead.interest(),
		"Product", "0-100, refreshed on publish, decays by a half-life counted in weeks")
	EvSeams.register("urun.usage", G, TYPE_FLOAT,
		func() -> float: return ProductRead.usage(), "Product", "load multiplier")
	EvSeams.register("urun.capacity_tier", G, TYPE_INT,
		func() -> int: return ProductRead.capacity_tier(), "Product", "provisioned infra units")
	EvSeams.register("urun.capacity_state", G, TYPE_STRING,
		func() -> String: return InfraSystem.capacity_state(),
		"Product", "normal | amber | over | unprovisioned")
	EvSeams.register("urun.enterprise_trust", G, TYPE_BOOL,
		func() -> bool: return InfraSystem.meets_enterprise_trust(),
		"Product", "the enterprise provider or security_cert research: the bar a large account checks before it signs")
	EvSeams.register("urun.support_staffed", G, TYPE_BOOL,
		func() -> bool: return ProductRead.support_staffed(),
		"Product", "the module's central pressure reads from this one boolean")
	EvSeams.register("urun.lines_open", G, TYPE_INT,
		func() -> int: return ProductRead.lines_open(), "Product", "0-9 feature lines opened")
	EvSeams.register("urun.steps_shipped", G, TYPE_INT,
		func() -> int: return ProductRead.steps_shipped(), "Product", "feature steps live")

	# Tech debt is a BOOLEAN in the demo, not a level (Ürün §20): a card may ask whether it
	# exists, not how much.
	EvSeams.register("urun.tech_debt", G, TYPE_BOOL,
		func() -> bool: return bool(GameState.get_flag("tech_debt_birikti", false)),
		"Product", "WRAPPER over a flag; boolean by design in the demo")


static func _decision_card() -> String:
	var card: Dictionary = SprintSystem.decision_card()
	return "" if card.is_empty() else SprintCatalog.card_name(card)


static func _install_rnd() -> void:
	var G := EvSeams.Kind.GLOBAL

	EvSeams.register("arge.tree_open", G, TYPE_BOOL,
		func() -> bool: return RnDSystem.tree_open(), "R&D", "the tab is reachable")
	EvSeams.register("arge.active", G, TYPE_STRING,
		func() -> String: return RnDSystem.active(),
		"R&D", "the running node id, or empty; exactly one at a time")
	EvSeams.register("arge.completed_count", G, TYPE_INT,
		func() -> int: return RnDSystem.completed_count(), "R&D", "0-20")
	EvSeams.register("arge.is_frozen", G, TYPE_BOOL,
		func() -> bool: return RnDSystem.is_frozen(),
		"R&D", "research with nobody assigned; progress is preserved, not lost")
	EvSeams.register("arge.note_pending", G, TYPE_BOOL,
		func() -> bool: return RnDSystem.note_pending(),
		"R&D", "an unread monthly product note is waiting")
	EvSeams.register("arge.attention_count", G, TYPE_INT,
		func() -> int: return RnDSystem.attention_count(), "R&D", "what the rail badge counts")
